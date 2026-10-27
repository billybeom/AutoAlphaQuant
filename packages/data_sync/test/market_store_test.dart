// E8c — 시세·지표 · 결측 · 수집 기록 저장소(설계 13 §8 R23 D4·D7·D8 · R26 H3·H5).
//
// 🔵 잡는 것: ① 덧붙이기만 — 있는 날은 고치지 않고 «같음/개정»만 센다 ② CHECK 를 넘지 못하는 행(종가 ≤ 0 · 거래량 < 0 ·
//    NaN)은 쓰지 않고 돌려준다 ③ 원장 일봉 → `judgeKrPlanDay` → `data_gap`(결정적 id · 다시 기록해도 1행 · 캘린더 의심 =
//    `calendar`) ④ 결측 끝날짜는 늘기만 한다 ⑤ 수집 기록은 같은 id 를 두 번 쓰지 않는다 · 원천·결과 글자 = 계약.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const String _at = '2026-08-31T11:00:00.000Z';

PriceBar _bar(String d, double c, {int v = 1000}) => PriceBar(
  tradeDate: d,
  open: c,
  high: c,
  low: c,
  close: c,
  closeUnadj: c,
  volume: v,
);

void main() {
  late Directory dir;
  late Database db;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_market_');
    db = openLocalLedger(dir.path, RunMode.live);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  group('일봉 · 계열 — 덧붙이기만', () {
    test('일봉: 새로 씀 · 같은 날 같은 값 = 같음 · 다른 값 = 개정(고치지 않음) · 원천·시각 기록', () {
      final SqliteMarketStore s = SqliteMarketStore(db);
      final WriteCount a = s.insertBars(
        'KR',
        '133690',
        <PriceBar>[_bar('2026-08-28', 150000), _bar('2026-08-31', 151000)],
        source: MarketDataSource.kis,
        fetchedAt: _at,
      );
      expect((a.inserted, a.overlapSame, a.overlapRevised), (2, 0, 0));
      final WriteCount b = s.insertBars(
        'KR',
        '133690',
        <PriceBar>[_bar('2026-08-28', 150000), _bar('2026-08-31', 999999)],
        source: MarketDataSource.manual,
        fetchedAt: '2026-09-01T00:00:00.000Z',
      );
      expect((b.inserted, b.overlapSame, b.overlapRevised), (0, 1, 1));
      expect(s.readBars('KR', '133690').last.close, 151000);
      expect(
        db
            .select(
              "SELECT DISTINCT source, fetched_at FROM daily_prices WHERE symbol = '133690'",
            )
            .map((Row r) => '${r['source']} ${r['fetched_at']}'),
        <String>['KIS $_at'],
      );
      expect(s.lastBarDate('KR', '133690'), '2026-08-31');
      expect(s.lastBarDate('US', '133690'), isNull);
    });

    test('🔴 종가 ≤ 0 · 거래량 < 0 은 쓰지 않고 돌려준다(FR-112)', () {
      final WriteCount w = SqliteMarketStore(db).insertBars(
        'KR',
        '411060',
        <PriceBar>[
          _bar('2026-08-26', 0),
          // 시가·고가·저가는 멀쩡하고 종가만 0 — 종가 검사 하나만 잡는다.
          const PriceBar(
            tradeDate: '2026-08-27',
            open: 15000,
            high: 15000,
            low: 15000,
            close: 0,
            volume: 1,
          ),
          _bar('2026-08-28', 15000, v: -1),
          _bar('2026-08-31', 15100),
        ],
        source: MarketDataSource.kis,
        fetchedAt: _at,
      );
      expect(w.inserted, 1);
      expect(w.rejected, <String>['2026-08-26', '2026-08-27', '2026-08-28']);
    });

    test('계열: NaN·무한대 거부 · 겹침 같음/개정 · 날짜 오름차순으로 읽는다', () {
      final SqliteMarketStore s = SqliteMarketStore(db);
      final WriteCount a = s.insertSeries(
        MarketSeriesIds.nfci,
        const <SeriesObs>[
          SeriesObs('2026-08-14', -0.552),
          SeriesObs('2026-08-07', -0.549),
          SeriesObs('2026-08-21', double.nan),
          SeriesObs('2026-08-22', double.infinity),
        ],
        source: MarketDataSource.fred,
        fetchedAt: _at,
      );
      expect(a.inserted, 2);
      expect(a.rejected, <String>['2026-08-21', '2026-08-22']);
      final WriteCount b = s.insertSeries(
        MarketSeriesIds.nfci,
        const <SeriesObs>[
          SeriesObs('2026-08-07', -0.549),
          SeriesObs('2026-08-14', -0.5),
        ],
        source: MarketDataSource.fredCsv,
        fetchedAt: _at,
      );
      expect((b.inserted, b.overlapSame, b.overlapRevised), (0, 1, 1));
      final DatedSeries r = s.readSeries(MarketSeriesIds.nfci);
      expect(r.dates, <String>['2026-08-07', '2026-08-14']);
      expect(r.values, <double>[-0.549, -0.552]);
      expect(s.lastSeriesDate(MarketSeriesIds.nfci), '2026-08-14');
      expect(s.lastSeriesDate(MarketSeriesIds.sahm), isNull);
    });

    test('트랜잭션 안에서 던지면 아무것도 남지 않는다', () {
      expect(
        () => inLedgerTransaction(db, () {
          SqliteMarketStore(db).insertSeries(
            MarketSeriesIds.sahm,
            const <SeriesObs>[SeriesObs('2026-08-01', 0.1)],
            source: MarketDataSource.fred,
            fetchedAt: _at,
          );
          throw StateError('중간 실패');
        }),
        throwsA(isA<StateError>()),
      );
      expect(
        SqliteMarketStore(db).lastSeriesDate(MarketSeriesIds.sahm),
        isNull,
      );
    });
  });

  group('KR 판정 → data_gap', () {
    final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);
    const TradeDate day = TradeDate('2026-08-31');
    const List<String> targets = <String>['133690', '411060'];

    test('한 종목 결측 — 그날 계획 중단 · prices 1행 · 다시 기록해도 1행', () {
      final SqliteMarketStore s = SqliteMarketStore(db);
      s.insertBars(
        'KR',
        '133690',
        <PriceBar>[_bar('2026-08-28', 150000), _bar('2026-08-31', 151000)],
        source: MarketDataSource.kis,
        fetchedAt: _at,
      );
      s.insertBars(
        'KR',
        '411060',
        <PriceBar>[_bar('2026-08-28', 15000)],
        source: MarketDataSource.kis,
        fetchedAt: _at,
      );
      final KrDayVerdict v = judgeKrPlanDay(
        day,
        targets,
        s.krBars(targets, from: '2026-08-01', to: '2026-08-31'),
        kr,
      );
      expect(v.proceed, isFalse);
      final SqliteGapStore g = SqliteGapStore(db);
      expect(g.recordKrVerdict(v, detectedAt: _at), <String>[
        'prices:411060:2026-08-31:MISSING_ROW',
      ]);
      g.recordKrVerdict(v, detectedAt: '2026-08-31T12:00:00.000Z');
      final List<StoredGap> all = g.all();
      expect(all, hasLength(1));
      expect(
        (
          all.single.dataset,
          all.single.fromDate,
          all.single.toDate,
          all.single.recoverable,
          all.single.reasonCode,
          all.single.detectedAt,
        ),
        ('prices', '2026-08-31', '2026-08-31', true, 'MISSING_ROW', _at),
      );
    });

    test('전 종목 결측 — 캘린더 의심은 calendar · 종목은 prices', () {
      final KrDayVerdict v = judgeKrPlanDay(
        day,
        targets,
        SqliteMarketStore(db)
            .krBars(targets, from: '2026-08-01', to: '2026-08-31'),
        kr,
      );
      expect(v.calendarSuspect, isTrue);
      SqliteGapStore(db).recordKrVerdict(v, detectedAt: _at);
      expect(
        SqliteGapStore(db)
            .all(dataset: GapDataset.calendar)
            .map((StoredGap x) => x.gapId),
        <String>['calendar:*:2026-08-31:CALENDAR_SUSPECT'],
      );
      expect(SqliteGapStore(db).all(dataset: GapDataset.prices), hasLength(2));
    });

    test('결측 끝날짜는 늘기만 한다(같은 id)', () {
      final SqliteGapStore g = SqliteGapStore(db);
      String put(String to) => g.record(
        dataset: GapDataset.macro,
        key: MarketSeriesIds.ofrFsi,
        fromDate: '2026-08-14',
        toDate: to,
        cause: DataGapCause.missingRow,
        detectedAt: _at,
      );
      put('2026-08-20');
      put('2026-08-25');
      put('2026-08-22');
      expect(g.all().single.toDate, '2026-08-25');
    });

    test('사유 글자 ⊂ 계약 사전 GapReasonCodes · dataset 글자 = DDL 주석', () {
      for (final DataGapCause c in DataGapCause.values) {
        expect(GapReasonCodes.values, contains(c.wire));
      }
      expect(GapDataset.values.map((GapDataset d) => d.wire), <String>[
        'prices',
        'macro',
        'regime',
        'calendar',
      ]);
    });
  });

  group('수집 기록', () {
    test('같은 fetch_id 는 한 번 · 원천·결과 글자 = 계약 · 원문 칸 없음', () {
      final SqliteFetchLog log = SqliteFetchLog(db);
      const FetchRecord r = FetchRecord(
        fetchId: 'FRED:SERIES:NFCI:$_at',
        source: MarketDataSource.fred,
        requestKind: 'SERIES',
        asOf: '2026-08-31',
        rowCount: 3,
        bodySha256: 'ab',
        fetchedAt: _at,
        outcome: FetchOutcome.ok,
        detail: 'NFCI',
      );
      expect(log.record(r), isTrue);
      expect(log.record(r), isFalse);
      expect(log.all(), hasLength(1));
      expect(log.all().single.source, MarketDataSource.fred);
      expect(FetchOutcome.values.map((FetchOutcome o) => o.wire), <String>[
        'OK',
        'EMPTY',
        'FAILED',
      ]);
      expect(
        db.select('PRAGMA table_info(fetch_log)').map((Row x) => x['name']),
        isNot(contains('body')),
      );
    });
  });
}
