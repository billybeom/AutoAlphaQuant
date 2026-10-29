// E8d2b — 일봉 시세 수집기(설계 13 §8 R30 N3~N10 · R29 L8·L11). 원천 = 가짜 포트(네트워크 0 · KIS 모름).
//
// 🔵 잡는 것: ① 받는 창 = 마지막 저장일(포함) ~ 끝난 세션(KR 그날 18:00 · US 다음 날 07:00 KST) · 그 뒤 행은 버리고 센다
//    ② 이미 최신이면 부르지 않는다(기록 없음) ③ 국면 대상 5 의 행선지(일봉 · 계열)와 요청 종류 · sha256 · as_of
//    ④ KR 계획 종목 = 첫 창 400일 · close = 수정 · close_unadj = 원(원에 없는 날 null) ⑤ 🔴 끝내 실패 = FAILED + 결측
//    (다음 실패에도 한 행 · 끝날짜만 늘어남) · 다른 대상은 계속 ⑥ 빠진 세션 = 하루짜리 MISSING_ROW(KR 은 계획 판정과
//    같은 id) · 첫 수집은 받은 가장 이른 날 앞을 보지 않는다 ⑦ 값이 모자란 행 = 쓰지 않고 거부로 센다 ⑧ 시드 없는 국면 대상
//    = StateError ⑨ VIX·VIX3M = FRED 대신 받기(`MacroCollector.standIns`).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
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

/// KST 벽시계 → UTC.
DateTime _kst(int m, int d, int h) =>
    DateTime.utc(2026, m, d, h).subtract(const Duration(hours: 9));

typedef _Req = ({
  Market market,
  String symbol,
  QuoteKind kind,
  PriceAdjust adjust,
  String from,
  String to,
});

/// 원천 흉내 — (심볼 · 꼴) → 원천 이력. 요청 범위 안의 행 + [extra](범위 뒤 «장중» 행)를 준다.
class _Feed implements DailyQuoteFeed {
  final Map<(String, PriceAdjust), List<QuoteBar>> history =
      <(String, PriceAdjust), List<QuoteBar>>{};
  final Map<(String, PriceAdjust), List<QuoteBar>> extra =
      <(String, PriceAdjust), List<QuoteBar>>{};
  final Set<(String, PriceAdjust)> down = <(String, PriceAdjust)>{};
  final List<_Req> calls = <_Req>[];

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
    calls.add((
      market: market,
      symbol: symbol,
      kind: kind,
      adjust: adjust,
      from: from,
      to: to,
    ));
    if (down.contains((symbol, adjust))) {
      throw const QuoteFeedDown('HTTP 503', attempts: 4);
    }
    return QuoteFetch(
      bars: <QuoteBar>[
        for (final QuoteBar b
            in history[(symbol, adjust)] ?? const <QuoteBar>[])
          if (b.date.compareTo(from) >= 0 && b.date.compareTo(to) <= 0) b,
        ...?extra[(symbol, adjust)],
      ],
      pageBodies: <String>['{"page":"$symbol ${adjust.name}"}'],
      attempts: 1,
    );
  }
}

QuoteBar _bar(String d, double c, {double v = 1000, bool full = true}) =>
    QuoteBar(
      date: d,
      close: c,
      open: full ? c : null,
      high: full ? c + 1 : null,
      low: full ? c - 1 : null,
      volume: v,
    );

const String _seedAt = '2026-10-27T00:00:00.000Z';

/// 국면 대상 5 의 시드 — 마지막 저장일 US 10-26 · KR 10-27.
void _seed(Database db) {
  final SqliteMarketStore s = SqliteMarketStore(db);
  for (final (String m, String sym, String d) in <(String, String, String)>[
    ('US', MarketSymbols.gspc, '2026-10-26'),
    ('US', MarketSymbols.spy, '2026-10-26'),
    ('KR', MarketSymbols.kosdaq, '2026-10-27'),
  ]) {
    s.insertBars(
      m,
      sym,
      <PriceBar>[
        PriceBar(
          tradeDate: d,
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
}

/// 원천 이력 — US 10-26~10-28 · KR 10-27~10-29(시드 날 값 = 시드와 같다).
void _history(_Feed f) {
  for (final String s in <String>[MarketSymbols.gspc, MarketSymbols.spy]) {
    f.history[(s, PriceAdjust.raw)] = <QuoteBar>[
      _bar('2026-10-26', 10, v: 5),
      _bar('2026-10-27', 11),
      _bar('2026-10-28', 12),
    ];
  }
  for (final String s in <String>[MarketSymbols.spy, 'RSP']) {
    f.history[(s, PriceAdjust.adjusted)] = <QuoteBar>[
      _bar('2026-10-26', 10),
      _bar('2026-10-27', 10.5),
      _bar('2026-10-28', 11.5),
    ];
  }
  f.history[(MarketSymbols.kosdaq, PriceAdjust.raw)] = <QuoteBar>[
    _bar('2026-10-27', 10, v: 5),
    _bar('2026-10-28', 20),
    _bar('2026-10-29', 21),
  ];
}

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Feed feed;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_quote_');
    db = openLocalLedger(dir.path, RunMode.live);
    // 10-29(목) 20:00 KST — KR 끝난 세션 = 10-29 · US = 10-28.
    clock = _Clock(_kst(10, 29, 20));
    feed = _Feed();
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  QuoteCollector collector() => QuoteCollector(db, feed: feed, clock: clock);
  SqliteMarketStore store() => SqliteMarketStore(db);
  List<String> gaps() => <String>[
    for (final StoredGap g in SqliteGapStore(db).all())
      '${g.gapId} ~${g.toDate}',
  ];

  test('국면 대상 5 — 창 · 행선지 · 요청 종류 · 기록 · 장중 행 버림', () async {
    _seed(db);
    _history(feed);
    // 미국 10-29 «장중» 행 — 끝난 세션(10-28) 뒤라 저장하지 않는다(L11).
    feed.extra[(MarketSymbols.spy, PriceAdjust.raw)] = <QuoteBar>[
      _bar('2026-10-29', 99),
    ];
    final List<QuoteCollectResult> r = await collector().collect();
    expect(
      <String>[
        for (final _Req c in feed.calls)
          '${c.market.code} ${c.symbol} ${c.kind.name} ${c.adjust.name} ${c.from}~${c.to}',
      ],
      <String>[
        'US ^GSPC stockIndex raw 2026-10-26~2026-10-28',
        'US SPY stock raw 2026-10-26~2026-10-28',
        'US SPY stock adjusted 2026-10-26~2026-10-28',
        'US RSP stock adjusted 2026-10-26~2026-10-28',
        'KR KQ11 stockIndex raw 2026-10-27~2026-10-29',
      ],
    );
    expect(
      <String>[
        for (final QuoteCollectResult x in r)
          '${x.key} ${x.outcome!.wire} ${x.write!.inserted}/${x.write!.overlapSame}',
      ],
      <String>[
        '^GSPC OK 2/1',
        'SPY OK 2/1',
        'SPY_ADJ OK 2/1',
        'RSP_ADJ OK 2/1',
        'KQ11 OK 2/1',
      ],
    );
    expect(r[1].droppedUnfinished, 1);
    expect(r[1].detail, contains('장중 제외 1'));
    expect(store().lastBarDate('US', MarketSymbols.spy), '2026-10-28');
    expect(store().lastBarDate('KR', MarketSymbols.kosdaq), '2026-10-29');
    expect(store().readSeries(MarketSeriesIds.rspAdjClose).values, <double>[
      10,
      10.5,
      11.5,
    ]);
    final List<FetchRecord> log = SqliteFetchLog(db).all();
    expect(
      <String>[
        for (final FetchRecord l in log)
          '${l.fetchId.split(':').take(3).join(':')} ${l.asOf} ${l.rowCount}',
      ],
      // 읽기 순서 = 시각 · fetch_id(한 실행은 시각이 같다).
      <String>[
        'KIS:KR_DAILY:KQ11 2026-10-29 2',
        'KIS:SERIES:RSP_ADJ 2026-10-28 2',
        'KIS:SERIES:SPY_ADJ 2026-10-28 2',
        'KIS:US_DAILY:SPY 2026-10-28 2',
        'KIS:US_DAILY:^GSPC 2026-10-28 2',
      ],
    );
    expect(log.every((FetchRecord l) => l.bodySha256!.length == 64), isTrue);
    expect(
      log.map((FetchRecord l) => l.bodySha256).toSet(),
      hasLength(5),
      reason: '대상마다 쪽 본문이 다르다(SPY 원 일봉 ≠ SPY_ADJ)',
    );
    final Row spy = db
        .select(
          "SELECT source, fetched_at FROM daily_prices WHERE symbol = 'SPY' AND trade_date = '2026-10-28'",
        )
        .single;
    expect(spy['source'], 'KIS');
    expect(spy['fetched_at'], clock.t.toIso8601String());
    expect(gaps(), isEmpty);
  });

  test('이미 최신 = 부르지 않는다 · 기록 없음 · 다음 날 아침 = US 하루 더', () async {
    _seed(db);
    _history(feed);
    await collector().collect();
    final int logs = SqliteFetchLog(db).all().length;
    feed.calls.clear();
    final List<QuoteCollectResult> again = await collector().collect();
    expect(again.every((QuoteCollectResult x) => x.upToDate), isTrue);
    expect(feed.calls, isEmpty);
    expect(SqliteFetchLog(db).all(), hasLength(logs));
    // 10-30(금) 07:00 KST — US 10-29 가 끝났다 · KR 10-30 은 아직(18:00 전).
    clock.t = _kst(10, 30, 7);
    for (final String s in <String>[MarketSymbols.gspc, MarketSymbols.spy]) {
      feed.history[(s, PriceAdjust.raw)]!.add(_bar('2026-10-29', 13));
    }
    final List<QuoteCollectResult> next = await collector().collect();
    expect(
      <String>[
        for (final QuoteCollectResult x in next)
          '${x.key} ${x.upToDate ? '최신' : '${x.from}~${x.to} ${x.write!.inserted}'}',
      ],
      <String>[
        '^GSPC 2026-10-28~2026-10-29 1',
        'SPY 2026-10-28~2026-10-29 1',
        // 원천에 10-29 수정종가가 없다 → 빠진 세션.
        'SPY_ADJ 2026-10-28~2026-10-29 0',
        'RSP_ADJ 2026-10-28~2026-10-29 0',
        'KQ11 최신',
      ],
    );
    expect(next[2].outcome, FetchOutcome.empty);
    expect(gaps(), <String>[
      'macro:RSP_ADJ:2026-10-29:MISSING_ROW ~2026-10-29',
      'macro:SPY_ADJ:2026-10-29:MISSING_ROW ~2026-10-29',
    ]);
  });

  test('KR 계획 종목 — 첫 창 400일 · 수정/원 · 빠진 세션 · 상장 전은 안 본다', () async {
    _seed(db);
    _history(feed);
    feed.history[('133690', PriceAdjust.adjusted)] = <QuoteBar>[
      _bar('2026-10-26', 100),
      _bar('2026-10-27', 101),
      // 10-28 없음 → 빠진 세션.
      _bar('2026-10-29', 103),
    ];
    feed.history[('133690', PriceAdjust.raw)] = <QuoteBar>[
      _bar('2026-10-26', 100.2),
      // 10-27 원 없음 → close_unadj null.
      _bar('2026-10-29', 103),
    ];
    final List<QuoteCollectResult> r = await collector().collect(
      krSymbols: <String>['133690'],
    );
    final QuoteCollectResult k = r.last;
    expect(k.key, '133690');
    expect('${k.from}~${k.to}', '2025-09-24~2026-10-29');
    expect(
      <String>[
        for (final _Req c in feed.calls.where((_Req c) => c.symbol == '133690'))
          '${c.adjust.name} ${c.from}~${c.to}',
      ],
      <String>['adjusted 2025-09-24~2026-10-29', 'raw 2025-09-24~2026-10-29'],
    );
    expect(
      <String>[
        for (final PriceBar b in store().readBars('KR', '133690'))
          '${b.tradeDate} ${b.close} ${b.closeUnadj}',
      ],
      <String>[
        '2026-10-26 100.0 100.2',
        '2026-10-27 101.0 null',
        '2026-10-29 103.0 103.0',
      ],
    );
    expect(k.gapIds, <String>['prices:133690:2026-10-28:MISSING_ROW']);
    expect(k.detail, contains('빠진 세션 1'));
    // 계획 판정이 같은 날을 다시 적어도 한 행(같은 gap_id).
    SqliteGapStore(db).recordKrVerdict(
      judgeKrPlanDay(
        const TradeDate('2026-10-28'),
        <String>['133690'],
        store().krBars(
          <String>['133690'],
          from: '2026-10-26',
          to: '2026-10-28',
        ),
        frozenExchangeCalendar(Market.kr),
      ),
      detectedAt: clock.t.toIso8601String(),
    );
    // (종목이 하나라 «전 종목 공백» = 캘린더 의심 행도 함께 생긴다 — 그건 calendar 묶음.)
    expect(gaps().where((String g) => g.startsWith('prices:')), <String>[
      'prices:133690:2026-10-28:MISSING_ROW ~2026-10-28',
    ]);
  });

  test('🔴 끝내 실패 = FAILED + 결측 · 다른 대상은 계속 · 다음 실패도 한 행 · 성공이 소급', () async {
    _seed(db);
    _history(feed);
    feed.down.add(('RSP', PriceAdjust.adjusted));
    final List<QuoteCollectResult> r = await collector().collect();
    final QuoteCollectResult rsp = r[3];
    expect(rsp.failed, isTrue);
    expect(rsp.gapIds, <String>['macro:RSP_ADJ:2026-10-27:MISSING_ROW']);
    expect(
      rsp.detail,
      'RSP_ADJ 2026-10-26~2026-10-28 — 받지 못함: HTTP 503 · 시도 4',
    );
    expect(r[4].outcome, FetchOutcome.ok, reason: '다음 대상(KQ11)은 계속');
    final FetchRecord fl = SqliteFetchLog(db)
        .all()
        .singleWhere((FetchRecord l) => l.outcome == FetchOutcome.failed);
    expect(fl.requestKind, 'SERIES');
    expect(fl.rowCount, 0);
    expect(fl.bodySha256, isNull);
    expect(fl.asOf, '2026-10-28');
    // 다음 날도 실패 — 결측 한 행 · 끝날짜만 늘어남.
    clock.t = _kst(10, 30, 8);
    await collector().collectOne(kRegimeQuoteTargets[3]);
    expect(gaps(), <String>[
      'macro:RSP_ADJ:2026-10-27:MISSING_ROW ~2026-10-29',
    ]);
    // 살아나면 마지막 저장일부터 다시 받아 빠진 날을 채운다.
    feed.down.clear();
    feed.history[('RSP', PriceAdjust.adjusted)]!.add(_bar('2026-10-29', 12));
    final QuoteCollectResult ok = await collector().collectOne(
      kRegimeQuoteTargets[3],
    );
    expect(
      '${ok.from}~${ok.to} ${ok.write!.inserted}',
      '2026-10-26~2026-10-29 3',
    );
    expect(store().lastSeriesDate(MarketSeriesIds.rspAdjClose), '2026-10-29');
  });

  test('KR 계획 종목 — 원(두 번째 요청)이 실패해도 아무것도 쓰지 않는다', () async {
    _seed(db);
    feed.history[('133690', PriceAdjust.adjusted)] = <QuoteBar>[
      _bar('2026-10-29', 103),
    ];
    feed.down.add(('133690', PriceAdjust.raw));
    final QuoteCollectResult r = await collector().collectOne(
      const QuoteTarget.krPlan('133690'),
    );
    expect(r.failed, isTrue);
    expect(r.detail, endsWith('시도 5'));
    expect(store().readBars('KR', '133690'), isEmpty);
    expect(r.gapIds, <String>['prices:133690:2025-09-24:MISSING_ROW']);
  });

  test('값이 모자란 행 = 쓰지 않고 거부 · 그 날은 빠진 세션', () async {
    _seed(db);
    _history(feed);
    feed.history[(MarketSymbols.gspc, PriceAdjust.raw)] = <QuoteBar>[
      _bar('2026-10-27', 11, full: false),
      _bar('2026-10-28', 12, v: 1.5),
    ];
    final QuoteCollectResult r = await collector().collectOne(
      kRegimeQuoteTargets.first,
    );
    expect(r.write!.inserted, 0);
    expect(r.write!.rejected, <String>['2026-10-27', '2026-10-28']);
    expect(r.outcome, FetchOutcome.empty);
    expect(r.detail, contains('거부 2'));
    expect(r.gapIds, <String>[
      'macro:^GSPC:2026-10-27:MISSING_ROW',
      'macro:^GSPC:2026-10-28:MISSING_ROW',
    ]);
  });

  test('시드 없는 국면 대상 = StateError · 원천을 부르지 않는다', () async {
    await expectLater(
      collector().collectOne(kRegimeQuoteTargets.first),
      throwsStateError,
    );
    expect(feed.calls, isEmpty);
  });

  test('VIX·VIX3M = FRED 가 대신 받는다(standIns) · 행 source = FRED', () async {
    expect(
      MacroCollector.standIns.map(
        (SeriesPlan p) =>
            '${p.seriesId} ${p.feeds.map((SeriesFeed f) => '${f.source.wire}:${f.code}').join(',')}',
      ),
      <String>['VIXCLS FRED:VIXCLS', 'VXVCLS FRED:VXVCLS'],
    );
    final SqliteMarketStore s = store();
    for (final String id in <String>[
      MarketSeriesIds.vix,
      MarketSeriesIds.vix3m,
    ]) {
      s.insertSeries(
        id,
        const <SeriesObs>[SeriesObs('2026-10-27', 18)],
        source: MarketDataSource.seedBundle,
        fetchedAt: _seedAt,
      );
    }
    final MockClient fred = MockClient((http.Request r) async {
      final String code = r.url.queryParameters['series_id']!;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode(<String, Object>{
            'observations': <Map<String, String>>[
              <String, String>{'date': '2026-10-27', 'value': '18'},
              <String, String>{
                'date': '2026-10-28',
                'value': code == 'VIXCLS' ? '19.5' : '21.25',
              },
            ],
          }),
        ),
        200,
      );
    });
    final MacroCollector m = MacroCollector(
      db,
      fred: FredClient(fred, apiKey: 'k', sleep: (Duration _) async {}),
      ofr: OfrClient(fred, sleep: (Duration _) async {}),
      clock: clock,
    );
    final List<SeriesCollectResult> r = <SeriesCollectResult>[
      for (final SeriesPlan p in MacroCollector.standIns)
        await m.collectOne(p, asOf: '2026-10-28'),
    ];
    expect(
      r.map(
        (SeriesCollectResult x) =>
            '${x.seriesId} ${x.source!.wire} ${x.write!.inserted}',
      ),
      <String>['VIXCLS FRED 1', 'VXVCLS FRED 1'],
    );
    expect(s.readSeries(MarketSeriesIds.vix3m).values.last, 21.25);
  });
}
