// 아침 · 저녁 잡 본체 넷(설계 13 §8 R47 F2~F9 · 🆕 06 M1-28).
//
// 🔵 잡는 것: ① daily_data = KR 대상만(KQ11 + 계획 종목) · 수집 실패는 잡을 멈추지 않고 P1 코드 · KR 하루 판정 → data_gap
//    ② us_data = US 대상만 · 매크로 실패 = P1 코드 ③ daily_signal = 시드에서 국면 계산 · 덧붙이기(다시 = 0)
//    ④ equity_snapshot = 원가 종가 × 보유 + D+2 현금 · 모드 칸 · 같은 날 덮어쓰기 · HWM 은 앞 날로 · 🔴 실패 = 쓰지 않음.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.t);
  DateTime t;
  @override
  DateTime nowUtc() => t;
}

DateTime _kst(int m, int d, int h, [int min = 0]) =>
    DateTime.utc(2026, m, d, h, min).subtract(const Duration(hours: 9));

class _Feed implements DailyQuoteFeed {
  final Map<(String, PriceAdjust), List<QuoteBar>> history =
      <(String, PriceAdjust), List<QuoteBar>>{};
  final Set<String> down = <String>{};
  final List<String> calls = <String>[];

  @override
  MarketDataSource get source => MarketDataSource.kis;

  @override
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  }) async {
    calls.add('${market.code}:$symbol:${adjust.name}');
    if (down.contains(symbol)) {
      throw const QuoteFeedDown('HTTP 503', attempts: 4);
    }
    return QuoteFetch(
      bars: <QuoteBar>[
        for (final QuoteBar b
            in history[(symbol, adjust)] ?? const <QuoteBar>[])
          if (b.date.compareTo(from) >= 0 && b.date.compareTo(to) <= 0) b,
      ],
      pageBodies: <String>['{"page":"$symbol ${adjust.name}"}'],
      attempts: 1,
    );
  }
}

QuoteBar _bar(String d, double c) =>
    QuoteBar(date: d, close: c, open: c, high: c + 1, low: c - 1, volume: 1000);

const String _seedAt = '2026-10-27T00:00:00.000Z';
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final ExchangeCalendar _us = frozenExchangeCalendar(Market.us);

void _seedKq(Database db) => SqliteMarketStore(db).insertBars(
  'KR',
  MarketSymbols.kosdaq,
  <PriceBar>[
    const PriceBar(
      tradeDate: '2026-10-27',
      open: 10,
      high: 11,
      low: 9,
      close: 10,
      volume: 5,
    ),
  ],
  source: MarketDataSource.seedBundle,
  fetchedAt: _seedAt,
);

void _krHistory(_Feed f, List<String> symbols) {
  f.history[(MarketSymbols.kosdaq, PriceAdjust.raw)] = <QuoteBar>[
    _bar('2026-10-27', 10),
    _bar('2026-10-28', 10.5),
    _bar('2026-10-29', 10.6),
  ];
  for (final String s in symbols) {
    for (final PriceAdjust a in <PriceAdjust>[
      PriceAdjust.adjusted,
      PriceAdjust.raw,
    ]) {
      f.history[(s, a)] = <QuoteBar>[
        _bar('2026-10-27', 100),
        _bar('2026-10-28', 101),
        _bar('2026-10-29', 102),
      ];
    }
  }
}

void _price(Database db, String symbol, String day, double closeUnadj) =>
    db.execute(
      'INSERT OR REPLACE INTO daily_prices(trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
      "VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 1)",
      <Object?>[
        day,
        symbol,
        closeUnadj,
        closeUnadj,
        closeUnadj,
        closeUnadj * 0.9,
        closeUnadj,
      ],
    );

void _regime(Database db, String day, String state, double score) => db.execute(
  'INSERT OR REPLACE INTO regime_score_daily(trade_date, status, direction_score, direction_state, config_hash) '
  "VALUES (?, 'OK', ?, ?, 'cfg')",
  <Object?>[day, score, state],
);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Feed feed;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_jobs_');
    db = openLocalLedger(dir.path, RunMode.live);
    clock = _Clock(_kst(10, 29, 18, 30));
    feed = _Feed();
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  QuoteCollector collector() =>
      QuoteCollector(db, feed: feed, clock: clock, kr: _kr, us: _us);

  group('daily_data(F3)', () {
    const List<String> plan = <String>['133690', '411060'];

    test('KR 대상만(KQ11 + 계획 종목 · US 0) · 성공 = 알림 0 · 판정 진행', () async {
      _seedKq(db);
      _krHistory(feed, plan);
      final DailyDataJob job = DailyDataJob(
        db,
        collector: collector(),
        kr: _kr,
        clock: clock,
        krSymbols: plan,
      );
      expect(job.targets.map((QuoteTarget t) => t.key), <String>[
        MarketSymbols.kosdaq,
        '133690',
        '411060',
      ]);
      final DailyDataReport r = await job.run(const TradeDate('2026-10-29'));
      expect(feed.calls.every((String c) => c.startsWith('KR:')), isTrue);
      expect(r.failedKeys, isEmpty);
      expect(r.verdict.proceed, isTrue);
      expect(r.alerts, isEmpty);
      expect(SqliteMarketStore(db).lastBarDate('KR', '133690'), '2026-10-29');
    });

    test(
      '한 종목 실패 = 나머지는 모은다 · P1 DATA_SOURCE_DOWN · 판정 멈춤 → data_gap',
      () async {
        _seedKq(db);
        _krHistory(feed, plan);
        feed.down.add('411060');
        final DailyDataReport r = await DailyDataJob(
          db,
          collector: collector(),
          kr: _kr,
          clock: clock,
          krSymbols: plan,
        ).run(const TradeDate('2026-10-29'));
        expect(r.failedKeys, <String>['411060']);
        expect(r.verdict.proceed, isFalse);
        expect(r.alerts, <String>{AlertCodes.dataSourceDown});
        expect(SqliteMarketStore(db).lastBarDate('KR', '133690'), '2026-10-29');
        expect(
          db.select('SELECT COUNT(*) AS n FROM data_gap').first['n'] as int,
          greaterThan(0),
        );
      },
    );

    test('🔴 앞 세션 대비 60% 넘게 뛰면 판정 멈춤 · PRICE_JUMP 가 data_gap 에 남는다', () async {
      _seedKq(db);
      _krHistory(feed, plan);
      for (final PriceAdjust a in <PriceAdjust>[
        PriceAdjust.adjusted,
        PriceAdjust.raw,
      ]) {
        feed.history[('411060', a)] = <QuoteBar>[
          _bar('2026-10-27', 100),
          _bar('2026-10-28', 101),
          _bar('2026-10-29', 200),
        ];
      }
      final DailyDataReport r = await DailyDataJob(
        db,
        collector: collector(),
        kr: _kr,
        clock: clock,
        krSymbols: plan,
      ).run(const TradeDate('2026-10-29'));
      expect(r.failedKeys, isEmpty);
      expect(r.verdict.proceed, isFalse);
      expect(r.verdict.issues.map((DataIssue i) => i.cause), <DataGapCause>[
        DataGapCause.priceJump,
      ]);
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM data_gap WHERE reason_code = 'PRICE_JUMP'",
            )
            .first['n'],
        1,
      );
    });

    test('수집은 됐는데 그날 행이 없다 = 판정 멈춤만으로도 P1 코드 · 판정 사유', () async {
      _seedKq(db);
      _krHistory(feed, plan);
      for (final PriceAdjust a in <PriceAdjust>[
        PriceAdjust.adjusted,
        PriceAdjust.raw,
      ]) {
        feed.history[('411060', a)] = <QuoteBar>[
          _bar('2026-10-27', 100),
          _bar('2026-10-28', 101),
        ];
      }
      final DailyDataReport r = await DailyDataJob(
        db,
        collector: collector(),
        kr: _kr,
        clock: clock,
        krSymbols: plan,
      ).run(const TradeDate('2026-10-29'));
      expect(r.failedKeys, isEmpty);
      expect(r.verdict.proceed, isFalse);
      expect(r.verdict.issues.map((DataIssue i) => i.key), <String>['411060']);
      expect(r.alerts, <String>{AlertCodes.dataSourceDown});
    });

    test(
      'KQ11 시드 없음(StateError) = 던지지 않고 실패로 센다 · 계획 종목 없음 = ArgumentError',
      () async {
        _krHistory(feed, plan);
        final DailyDataReport r = await DailyDataJob(
          db,
          collector: collector(),
          kr: _kr,
          clock: clock,
          krSymbols: plan,
        ).run(const TradeDate('2026-10-29'));
        expect(r.failedKeys, <String>[MarketSymbols.kosdaq]);
        expect(r.results.first.detail, 'StateError');
        expect(r.alerts, <String>{AlertCodes.dataSourceDown});
        expect(
          () => DailyDataJob(
            db,
            collector: collector(),
            kr: _kr,
            clock: clock,
            krSymbols: const <String>[],
          ),
          throwsArgumentError,
        );
      },
    );
  });

  group('us_data(F4)', () {
    test('US 국면 대상 4만 · 매크로 실패 = P1 코드(시세는 모은다)', () async {
      final UsDataJob job = UsDataJob(
        collector: collector(),
        macro: MacroCollector(
          db,
          fred: FredClient(
            MockClient((http.Request r) async => http.Response('down', 503)),
          ),
          ofr: OfrClient(
            MockClient((http.Request r) async => http.Response('down', 503)),
          ),
          clock: clock,
        ),
      );
      expect(job.targets.map((QuoteTarget t) => t.market).toSet(), <Market>{
        Market.us,
      });
      expect(job.targets, hasLength(4));
      final UsDataReport r = await job.run(const TradeDate('2026-10-28'));
      expect(r.quotes, hasLength(4));
      expect(r.alerts, <String>{AlertCodes.dataSourceDown});
      expect(feed.calls.where((String c) => c.startsWith('KR:')), isEmpty);
    });

    test('시세는 다 받았고 매크로만 실패 = 매크로 실패 하나로도 P1 코드', () async {
      final SqliteMarketStore s = SqliteMarketStore(db);
      for (final String sym in <String>[
        MarketSymbols.gspc,
        MarketSymbols.spy,
      ]) {
        s.insertBars(
          'US',
          sym,
          <PriceBar>[
            const PriceBar(
              tradeDate: '2026-10-26',
              open: 10,
              high: 11,
              low: 9,
              close: 10,
              volume: 5,
            ),
          ],
          source: MarketDataSource.seedBundle,
          fetchedAt: _seedAt,
        );
        feed.history[(sym, PriceAdjust.raw)] = <QuoteBar>[
          _bar('2026-10-26', 10),
          _bar('2026-10-27', 11),
          _bar('2026-10-28', 12),
        ];
      }
      for (final String id in <String>[
        MarketSeriesIds.spyAdjClose,
        MarketSeriesIds.rspAdjClose,
      ]) {
        s.insertSeries(
          id,
          const <SeriesObs>[SeriesObs('2026-10-26', 10)],
          source: MarketDataSource.seedBundle,
          fetchedAt: _seedAt,
        );
      }
      for (final String sym in <String>[MarketSymbols.spy, 'RSP']) {
        feed.history[(sym, PriceAdjust.adjusted)] = <QuoteBar>[
          _bar('2026-10-26', 10),
          _bar('2026-10-27', 10.5),
          _bar('2026-10-28', 11),
        ];
      }
      clock.t = _kst(10, 29, 7, 30);
      final UsDataReport r = await UsDataJob(
        collector: collector(),
        macro: MacroCollector(
          db,
          fred: FredClient(
            MockClient((http.Request r) async => http.Response('down', 503)),
          ),
          ofr: OfrClient(
            MockClient((http.Request r) async => http.Response('down', 503)),
          ),
          clock: clock,
        ),
      ).run(const TradeDate('2026-10-28'));
      expect(r.quotes.where((QuoteCollectResult q) => q.failed), isEmpty);
      expect(r.seriesFailed, isTrue);
      expect(r.alerts, <String>{AlertCodes.dataSourceDown});
    });
  });

  group('daily_signal(F5)', () {
    test('시드 → 국면 계산 · LIVE 로 덧붙이기 · 다시 돌리면 0', () async {
      final Map<String, List<int>> gz = <String, List<int>>{
        for (final SeedFile f in kSeedFiles)
          f.fileName: File('assets/seed/${f.fileName}').readAsBytesSync(),
      };
      importSeedBundle(db, gz, importedAt: _seedAt);
      final DailySignalJob job = DailySignalJob(db, configHash: 'cfg_p0s');
      final DailySignalReport a = await job.run(const TradeDate('2026-08-14'));
      expect(a.written, greaterThan(10000));
      expect(a.lastDate, kSeedAsOf);
      expect(a.last, isNotNull);
      expect(a.alerts, isEmpty);
      final Map<String, Object?> row = SqliteRegimeStore(db).row(kSeedAsOf)!;
      expect((row['source'], row['config_hash']), ('LIVE', 'cfg_p0s'));
      expect(row['direction_state'], a.last!.directionState.code);
      final DailySignalReport b = await job.run(const TradeDate('2026-08-14'));
      expect(b.written, 0);
    });
  });

  group('equity_snapshot(F6~F9)', () {
    EquitySnapshotJob job({
      Map<String, OrderBroker>? cash,
      List<LedgerHolding> held = const <LedgerHolding>[
        LedgerHolding('P0S_B', '133690', 1),
      ],
    }) => EquitySnapshotJob(
      db,
      cash:
          cash ??
          <String, OrderBroker>{
            'main': FakeOrderBroker(cashKrw: Decimal.parse('49832955')),
          },
      mode: RunMode.live,
      holdings: () async => held,
    );

    test('원가 종가 × 보유 + D+2 현금 · 모드 칸 LIVE · 행 = 되읽은 값', () async {
      _price(db, '133690', '2026-11-04', 167000);
      _regime(db, '2026-11-03', 'BULL', 60);
      final EquitySnapshotReport r = await job().run(
        const TradeDate('2026-11-04'),
      );
      expect(r.row.totalEquity, 49999955.0);
      expect((r.row.positionsValue, r.row.cashKrw), (167000.0, 49832955.0));
      expect((r.row.highWaterMark, r.row.drawdown), (49999955.0, 0.0));
      expect(r.row.breakerLevel, BreakerLevel.normal);
      expect(r.alerts, isEmpty);
      final SqliteEquitySnapshotStore s = SqliteEquitySnapshotStore(
        db,
        mode: RunMode.live,
      );
      expect(s.at('2026-11-04'), r.row);
      expect(
        db
            .select(
              "SELECT mode FROM equity_snapshot WHERE trade_date = '2026-11-04'",
            )
            .first['mode'],
        'LIVE',
      );
    });

    test('같은 날 다시 = 덮어쓴다(행 1) · HWM 은 앞 날 행으로 · 다음 날 내려가면 dd', () async {
      _price(db, '133690', '2026-11-04', 167000);
      _price(db, '133690', '2026-11-05', 100000);
      await job().run(const TradeDate('2026-11-04'));
      await job(
        cash: <String, OrderBroker>{
          'main': FakeOrderBroker(cashKrw: Decimal.parse('1000')),
        },
      ).run(const TradeDate('2026-11-04'));
      expect(
        db.select('SELECT COUNT(*) AS n FROM equity_snapshot').first['n'],
        1,
      );
      final SqliteEquitySnapshotStore s = SqliteEquitySnapshotStore(
        db,
        mode: RunMode.live,
      );
      expect(s.at('2026-11-04')!.highWaterMark, 168000.0);
      final EquitySnapshotReport d = await job(
        cash: <String, OrderBroker>{
          'main': FakeOrderBroker(cashKrw: Decimal.parse('1000')),
        },
      ).run(const TradeDate('2026-11-05'));
      expect(d.row.highWaterMark, 168000.0);
      expect(d.row.drawdown, closeTo(101000 / 168000 - 1, 1e-12));
      expect(
        s.before('2026-11-06').map((EquitySnapshotRow r) => r.tradeDate),
        <String>['2026-11-04', '2026-11-05'],
      );
    });

    test('🔴 종가 없음 · 현금 실패 = EquitySnapshotError · 행을 쓰지 않는다', () async {
      await expectLater(
        job().run(const TradeDate('2026-11-06')),
        throwsA(isA<EquitySnapshotError>()),
      );
      _price(db, '133690', '2026-11-06', 100);
      await expectLater(
        job(
          cash: <String, OrderBroker>{
            'main': FakeOrderBroker(cashError: StateError('끊김')),
          },
        ).run(const TradeDate('2026-11-06')),
        throwsA(isA<EquitySnapshotError>()),
      );
      expect(
        db.select('SELECT COUNT(*) AS n FROM equity_snapshot').first['n'],
        0,
      );
    });

    test('보유 0 = 현금만 · 국면 조회 = 같은 날짜 포함 as-of(앞 미국 세션)', () async {
      _regime(db, '2026-11-02', 'BEAR', 20);
      _regime(db, '2026-11-03', 'BULL', 70);
      _regime(db, '2026-11-05', 'BEAR', 10);
      final EquitySnapshotReport r = await job(held: const <LedgerHolding>[])
          .run(const TradeDate('2026-11-04'));
      expect((r.row.positionsValue, r.row.totalEquity), (0.0, 49832955.0));
    });

    test('국면 조회 = 같은 날짜 포함 as-of · 앞에 없으면 (null, false) · 순서 무관', () {
      final (double?, bool) Function(String) f = regimeAsOfLookup(
        const <(String, double?, String?)>[
          ('2026-11-05', 10, 'BEAR'),
          ('2026-11-02', 20, 'BEAR'),
          ('2026-11-03', 70, 'BULL'),
        ],
      );
      expect(f('2026-11-04'), (70.0, true));
      expect(f('2026-11-03'), (70.0, true));
      expect(f('2026-11-02'), (20.0, false));
      expect(f('2026-11-01'), (null, false));
      expect(f('2026-11-09'), (10.0, false));
    });

    test('현금 계좌 없음 = ArgumentError', () {
      expect(
        () => EquitySnapshotJob(
          db,
          cash: const <String, OrderBroker>{},
          mode: RunMode.live,
          holdings: () async => const <LedgerHolding>[],
        ),
        throwsArgumentError,
      );
    });
  });
}
