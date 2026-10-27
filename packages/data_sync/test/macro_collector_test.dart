// E8c — 매크로·신용 수집기(설계 13 §8 R23 D9·D10 · R26 H3·H5·H6 · FR-110 · FR-111). 네트워크 0(`MockClient`).
//
// 🔵 잡는 것: ① 시드 뒤 첫 실행 = 백필(마지막 저장일부터 하루 겹쳐 받고 새 날만 덧붙임 · 원천 = 실제 받은 길) ② 같은 날
//    다시 돌리면 EMPTY ③ 원천이 과거를 고쳐도 원장은 그대로(개정 수만 기록) ④ 🔴 끝내 실패 = FAILED 기록 + `data_gap(macro ·
//    MISSING_ROW · recoverable)` → 다음 날 또 실패해도 결측 1행(끝날짜만 늘어남) → 성공하면 빠진 날을 소급 ⑤ 시드 없이는
//    돌지 않는다 ⑥ 맡는 계열 = 평소 원천이 FRED·OFR 인 5개 ⑦ 🔴 기록·결과 어디에도 키가 없다.

import 'dart:convert';
import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const String _key = 'k3y-should-never-leak';

class _Clock implements Clock {
  _Clock(this.t);
  DateTime t;
  @override
  DateTime nowUtc() => t;
}

/// 원천 흉내 — 픽스처가 있으면 200, 없으면 [missing](기본 404). [down] 이면 그 호스트는 503.
MockClient _sources({Set<String> down = const <String>{}, int missing = 404}) =>
    MockClient((http.Request r) async {
      if (down.contains(r.url.host)) return http.Response('', 503);
      final String? path = switch (r.url.host) {
        'api.stlouisfed.org' =>
          'fred/${r.url.queryParameters['series_id']}.json',
        'fred.stlouisfed.org' => 'fred_csv/${r.url.queryParameters['id']}.csv',
        'www.financialresearch.gov' => 'ofr/fsi.csv',
        _ => null,
      };
      final File f = File('test/fixtures/$path');
      if (path == null || !f.existsSync()) return http.Response('', missing);
      return http.Response.bytes(utf8.encode(f.readAsStringSync()), 200);
    });

/// 시드 흉내 — 계열마다 번들 마지막 값 한 줄(번들과 같은 값).
void _seed(Database db, {double nfci = -0.549}) {
  final SqliteMarketStore s = SqliteMarketStore(db);
  for (final (String id, String d, double v) in <(String, String, double)>[
    (MarketSeriesIds.ofrFsi, '2026-08-13', -2.782),
    (MarketSeriesIds.nfci, '2026-08-07', nfci),
    (MarketSeriesIds.cfnaiMa3, '2026-06-01', -0.05),
    (MarketSeriesIds.t10y3m, '2026-08-14', 0.82),
    (MarketSeriesIds.sahm, '2026-07-01', -0.03),
  ]) {
    s.insertSeries(
      id,
      <SeriesObs>[SeriesObs(d, v)],
      source: MarketDataSource.seedBundle,
      fetchedAt: '2026-10-27T00:00:00.000Z',
    );
  }
}

Future<void> _noSleep(Duration _) async {}

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_macro_');
    db = openLocalLedger(dir.path, RunMode.live);
    clock = _Clock(DateTime.utc(2026, 9, 8, 11));
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  MacroCollector collector(MockClient c, {String? key = _key}) =>
      MacroCollector(
        db,
        fred: FredClient(c, apiKey: key, sleep: _noSleep),
        ofr: OfrClient(c, sleep: _noSleep),
        clock: clock,
      );

  String dump() => <String>[
    for (final FetchRecord r in SqliteFetchLog(db).all())
      '${r.fetchId} ${r.outcome.wire} ${r.rowCount} ${r.detail}',
    for (final StoredGap g in SqliteGapStore(db).all()) g.gapId,
    for (final Row r in db.select(
      'SELECT series_id, obs_date, source FROM market_series',
    ))
      '${r['series_id']} ${r['obs_date']} ${r['source']}',
  ].join('\n');

  test('맡는 계열 = 평소 원천 FRED·OFR 인 5개(KIS 몫 4개는 E8d)', () {
    expect(MacroCollector.plans.map((SeriesPlan p) => p.seriesId), <String>[
      MarketSeriesIds.ofrFsi,
      MarketSeriesIds.nfci,
      MarketSeriesIds.cfnaiMa3,
      MarketSeriesIds.t10y3m,
      MarketSeriesIds.sahm,
    ]);
  });

  test('시드 뒤 첫 실행 = 백필 · 원천 = 받은 길 · 같은 날 다시 = EMPTY · 🔴 키 없음', () async {
    _seed(db);
    final List<SeriesCollectResult> r = await collector(_sources(missing: 400))
        .collect(asOf: '2026-09-07');
    expect(
      r.map(
        (SeriesCollectResult x) =>
            '${x.seriesId} ${x.outcome.wire} ${x.source!.wire} ${x.write!.inserted}/${x.write!.overlapSame}',
      ),
      <String>[
        'OFR_FSI OK OFR 2/1',
        'NFCI OK FRED 3/1',
        'CFNAIMA3 OK FRED 1/1',
        // JSON 픽스처가 없다 → 400(다시 안 함) → 키 없는 CSV.
        'T10Y3M OK FRED_CSV 2/1',
        'SAHMREALTIME OK FRED 1/1',
      ],
    );
    expect(r[3].detail, contains('폴백 — FRED: HTTP 400'));
    expect(SqliteGapStore(db).all(), isEmpty);
    final List<FetchRecord> log = SqliteFetchLog(db).all();
    expect(log, hasLength(5));
    expect(log.every((FetchRecord l) => l.bodySha256!.length == 64), isTrue);
    expect(log.every((FetchRecord l) => l.asOf == '2026-09-07'), isTrue);
    expect(
      log.map((FetchRecord l) => l.fetchId),
      contains('OFR:SERIES:OFR_FSI:2026-09-08T11:00:00.000Z'),
    );

    clock.t = DateTime.utc(2026, 9, 8, 13);
    final List<SeriesCollectResult> again = await collector(
      _sources(missing: 400),
    ).collect(asOf: '2026-09-07');
    expect(
      again.map((SeriesCollectResult x) => x.outcome),
      everyElement(FetchOutcome.empty),
    );
    expect(SqliteFetchLog(db).all(), hasLength(10));
    expect(dump(), isNot(contains(_key)));
  });

  test('키 없으면 FRED 는 CSV 만 — CSV 가 없는 계열은 실패로 기록', () async {
    _seed(db);
    final List<SeriesCollectResult> r = await collector(
      _sources(),
      key: null,
    ).collect(asOf: '2026-09-07');
    expect(
      r.map(
        (SeriesCollectResult x) =>
            '${x.seriesId} ${x.outcome.wire} ${x.source?.wire}',
      ),
      <String>[
        'OFR_FSI OK OFR',
        'NFCI OK FRED_CSV',
        'CFNAIMA3 FAILED null',
        'T10Y3M OK FRED_CSV',
        'SAHMREALTIME FAILED null',
      ],
    );
  });

  test('🔴 원천이 과거를 고쳐도 원장은 그대로 — 개정 수만 남긴다', () async {
    _seed(db, nfci: -0.540);
    final SeriesCollectResult r = await collector(_sources())
        .collectOne(MacroCollector.plans[1], asOf: '2026-09-07');
    expect(r.write!.overlapRevised, 1);
    expect(r.detail, contains('개정 1(고치지 않음)'));
    expect(
      SqliteMarketStore(db).readSeries(MarketSeriesIds.nfci).at('2026-08-07'),
      -0.540,
    );
  });

  test('🔴 끝내 실패 → FAILED + 결측 1행 → 다음 날도 실패면 끝날짜만 → 성공하면 소급', () async {
    _seed(db);
    final SeriesPlan ofr = MacroCollector.plans.first;
    final MockClient down = _sources(
      down: <String>{'www.financialresearch.gov'},
    );
    clock.t = DateTime.utc(2026, 8, 31, 11);

    final SeriesCollectResult f1 = await collector(down)
        .collectOne(ofr, asOf: '2026-08-31');
    expect(f1.failed, isTrue);
    expect(f1.gapId, 'macro:OFR_FSI:2026-08-14:MISSING_ROW');
    expect(f1.detail, 'OFR_FSI 2026-08-13부터 — 받지 못함: OFR: HTTP 503 · 시도 4');
    final FetchRecord l1 = SqliteFetchLog(db).all().single;
    expect(
      (l1.source, l1.outcome, l1.rowCount, l1.bodySha256),
      (MarketDataSource.ofr, FetchOutcome.failed, 0, null),
    );

    clock.t = DateTime.utc(2026, 9, 1, 11);
    await collector(down).collectOne(ofr, asOf: '2026-09-01');
    final StoredGap g = SqliteGapStore(db).all().single;
    expect(
      (g.dataset, g.fromDate, g.toDate, g.recoverable, g.reasonCode),
      ('macro', '2026-08-14', '2026-09-01', true, 'MISSING_ROW'),
    );

    clock.t = DateTime.utc(2026, 9, 2, 11);
    final SeriesCollectResult ok = await collector(_sources())
        .collectOne(ofr, asOf: '2026-09-02');
    expect(ok.outcome, FetchOutcome.ok);
    expect(ok.write!.inserted, 2, reason: '빠진 2026-08-14 · 08-17 을 소급');
    expect(
      SqliteFetchLog(db).all().map((FetchRecord l) => l.outcome.wire),
      <String>['FAILED', 'FAILED', 'OK'],
    );
  });

  test('시드가 없으면 수집하지 않는다(StateError)', () async {
    await expectLater(
      collector(_sources()).collect(asOf: '2026-09-07'),
      throwsA(isA<StateError>()),
    );
    expect(SqliteFetchLog(db).all(), isEmpty);
  });
}
