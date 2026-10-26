// E8c — 동결 번들 시드(설계 13 §8 R23 D9 · R26 H2·H8).
//
// 🔵 잡는 것: ① 자산 11파일 = 재현 번들(MANIFEST gz_sha256 · 바이트 같음) ② 기준일 이하·결측 제외 행 수 · 수집 기록 11 ·
//    다시 돌려도 그대로(멱등) ③ fail-closed — sha256 이 다르거나 파일이 없으면 0행 ④ 🔴 **원장에서 읽은 국면 = 참조 엔진
//    정답지**(`core_engine/test/replay/fixtures/regime_parity.json` — 정규화 13 · 카테고리 5 · 방향 · 추세성 · FSM ·
//    KOSDAQ 추세 점수) — 시드 → SQLite → 엔진이 골든 경로를 비트로 지킨다 ⑤ 국면 행 저장 ⑥ «번들 vs 실전 원천» 겹친 날
//    대조(D9 — 픽스처의 기준일 이하 값은 번들 값이다).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const String _bundle = '../core_engine/test/replay/data';
const String _parity = '../core_engine/test/replay/fixtures/regime_parity.json';
const String _at = '2026-10-27T00:00:00.000Z';

Map<String, List<int>> _assets() => <String, List<int>>{
  for (final SeedFile f in kSeedFiles)
    f.fileName: File('assets/seed/${f.fileName}').readAsBytesSync(),
};

/// 참조 엔진 정답지 해시와 같은 규약(core_engine `test/replay/parity_hash.dart`).
String _floatHash(Iterable<double?> values) {
  final List<double?> v = values.toList();
  final ByteData b = ByteData(8 * v.length);
  for (int i = 0; i < v.length; i++) {
    final double? x = v[i];
    if (x == null || x.isNaN) {
      b.setUint64(8 * i, 0x7ff8000000000000, Endian.little);
    } else {
      b.setFloat64(8 * i, x, Endian.little);
    }
  }
  return sha256.convert(b.buffer.asUint8List()).toString();
}

String _lineHash(Iterable<Object> lines) => sha256
    .convert(utf8.encode(lines.map((Object l) => '$l\n').join()))
    .toString();

int _nans(List<double?> v) =>
    v.where((double? x) => x == null || x.isNaN).length;

/// 파일 → 기준일 이하·결측 제외 행 수(참조 엔진 CSV 를 파이썬으로 센 값).
const Map<String, int> _rows = <String, int>{
  'gspc.csv.gz': 10485,
  'kq11.csv.gz': 7541,
  'spy.csv.gz': 8443,
  'rsp.csv.gz': 5860,
  'vix.csv.gz': 9223,
  'vix3m.csv.gz': 5032,
  'ofr_fsi.csv.gz': 6736,
  'nfci.csv.gz': 2901,
  'cfnai_ma3.csv.gz': 710,
  't10y3m.csv.gz': 11157,
  'sahm.csv.gz': 799,
};

void main() {
  Database openIn(Directory dir) {
    final Database db = openLocalLedger(dir.path, RunMode.live);
    addTearDown(db.close);
    return db;
  }

  int count(Database db, String table) =>
      db.select('SELECT COUNT(*) AS n FROM $table').first['n'] as int;

  group('자산 = 재현 번들', () {
    test('11파일 · sha256 = 상수 = 번들 MANIFEST · 바이트 같음', () {
      final Map<String, Object?> manifest = jsonDecode(
        File('$_bundle/MANIFEST.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final Map<String, Object?> files =
          manifest['files']! as Map<String, Object?>;
      expect((manifest['meta']! as Map<String, Object?>)['as_of'], kSeedAsOf);
      expect(kSeedFiles, hasLength(11));
      expect(
        Directory('assets/seed')
            .listSync()
            .whereType<File>()
            .where((File f) => f.path.endsWith('.gz'))
            .length,
        11,
        reason: '자산 폴더에 다른 시드가 섞이지 않는다',
      );
      for (final SeedFile f in kSeedFiles) {
        final List<int> a = File('assets/seed/${f.fileName}').readAsBytesSync();
        expect(sha256.convert(a).toString(), f.gzSha256, reason: f.name);
        expect(
          (files[f.name]! as Map<String, Object?>)['gz_sha256'],
          f.gzSha256,
          reason: '${f.name} — 번들 MANIFEST',
        );
        expect(
          a,
          File('$_bundle/${f.fileName}').readAsBytesSync(),
          reason: f.name,
        );
      }
    });
  });

  group('적재', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('aaq_seed_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('기준일 이하 · 결측 제외 · 수집 기록 11 · 다시 돌리면 아무것도 안 한다', () {
      final Database db = openIn(dir);
      final SeedImportReport r = importSeedBundle(
        db,
        _assets(),
        importedAt: _at,
      );
      expect(r.alreadyImported, isFalse);
      expect(r.rows, _rows);
      expect(count(db, 'daily_prices'), 10485 + 7541);
      expect(count(db, 'market_series'), 68887 - 10485 - 7541);
      expect(
        db.select(
          "SELECT COUNT(*) AS n FROM daily_prices WHERE source = 'SEED_BUNDLE' "
          'AND fetched_at = ? AND trade_date <= ?',
          <Object>[_at, kSeedAsOf],
        ).first['n'],
        10485 + 7541,
      );
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM market_series WHERE source <> 'SEED_BUNDLE'",
            )
            .first['n'],
        0,
      );
      final List<FetchRecord> log = SqliteFetchLog(db).all();
      expect(log, hasLength(11));
      for (final FetchRecord l in log) {
        expect(l.source, MarketDataSource.seedBundle);
        expect(l.requestKind, kSeedRequestKind);
        expect(l.asOf, kSeedAsOf);
        expect(l.outcome, FetchOutcome.ok);
        expect(
          l.bodySha256,
          kSeedFiles
              .firstWhere((SeedFile f) => seedFetchId(f) == l.fetchId)
              .gzSha256,
        );
      }
      // 기준일 뒤 행(번들에 있는 2026-08-17 T10Y3M · 2026-08-18 KOSDAQ)은 들어가지 않는다 — 백필 몫.
      final SqliteMarketStore s = SqliteMarketStore(db);
      expect(s.lastSeriesDate(MarketSeriesIds.t10y3m), kSeedAsOf);
      expect(s.lastBarDate('KR', MarketSymbols.kosdaq), kSeedAsOf);
      expect(s.lastSeriesDate(MarketSeriesIds.vix3m), '2026-07-17');

      final SeedImportReport again = importSeedBundle(
        db,
        _assets(),
        importedAt: '2026-10-28T00:00:00.000Z',
      );
      expect(again.alreadyImported, isTrue);
      expect(count(db, 'fetch_log'), 11);
      expect(count(db, 'daily_prices'), 10485 + 7541);
    });

    test('🔴 sha256 이 하나라도 다르면 아무것도 쓰지 않는다', () {
      final Database db = openIn(dir);
      final Map<String, List<int>> a = _assets();
      a['sahm.csv.gz'] = <int>[...a['sahm.csv.gz']!, 0];
      expect(
        () => importSeedBundle(db, a, importedAt: _at),
        throwsA(isA<StateError>()),
      );
      expect(count(db, 'daily_prices'), 0);
      expect(count(db, 'market_series'), 0);
      expect(count(db, 'fetch_log'), 0);
    });

    test('🔴 파일이 없으면 아무것도 쓰지 않는다', () {
      final Database db = openIn(dir);
      final Map<String, List<int>> a = _assets()..remove('kq11.csv.gz');
      expect(
        () => importSeedBundle(db, a, importedAt: _at),
        throwsA(isA<StateError>()),
      );
      expect(count(db, 'daily_prices'), 0);
      expect(count(db, 'fetch_log'), 0);
    });
  });

  group('🔴 원장에서 읽은 국면 = 참조 엔진 정답지', () {
    late Directory dir;
    late Database db;
    late RegimeComputation g;
    final Map<String, Object?> want =
        jsonDecode(File(_parity).readAsStringSync()) as Map<String, Object?>;
    Map<String, Object?> obj(Object? o) => o! as Map<String, Object?>;

    setUpAll(() {
      dir = Directory.systemTemp.createTempSync('aaq_seed_regime_');
      db = openLocalLedger(dir.path, RunMode.live);
      importSeedBundle(db, _assets(), importedAt: _at);
      g = computeRegime(SqliteMarketStore(db).regimeSources());
    });
    tearDownAll(() {
      db.close();
      dir.deleteSync(recursive: true);
    });

    test('달력 = ^GSPC 세션 1985-01-02 ~ 2026-08-14', () {
      final Map<String, Object?> c = obj(want['calendar']);
      expect(g.calendar, hasLength(c['n']));
      expect(g.calendar.first, c['first']);
      expect(g.calendar.last, c['last']);
    });

    test('정규화 13 · 카테고리 5 · 방향 · 추세성 세 부분 · 추세성 — 비트 일치', () {
      for (final MapEntry<String, Object?> e in obj(
        want['normalized'],
      ).entries) {
        expect(_nans(g.normalized[e.key]!), obj(e.value)['nan'], reason: e.key);
        expect(
          _floatHash(g.normalized[e.key]!),
          obj(e.value)['sha256'],
          reason: e.key,
        );
      }
      for (final MapEntry<String, Object?> e in obj(
        want['categories'],
      ).entries) {
        final RegimeCategory c = RegimeCategory.values.firstWhere(
          (RegimeCategory x) => x.name == e.key,
        );
        expect(
          _floatHash(<double?>[
            for (final DirectionScore d in g.direction) d.categories[c],
          ]),
          e.value,
          reason: e.key,
        );
      }
      expect(
        _floatHash(<double?>[
          for (final DirectionScore d in g.direction) d.direction,
        ]),
        obj(want['direction'])['sha256'],
      );
      for (final MapEntry<String, Object?> e in obj(
        want['trendiness_parts'],
      ).entries) {
        expect(_floatHash(g.trendinessParts[e.key]!), e.value, reason: e.key);
      }
      expect(_floatHash(g.trendiness), obj(want['trendiness'])['sha256']);
    });

    test('FSM — 데이터 부족 봉 · 첫 유효 봉 · 비교 시작일부터 상태·나이·추세성', () {
      final Map<String, Object?> f = obj(want['fsm']);
      expect(
        g.fsm
            .where((RegimeDay d) => d.status == RegimeStatus.insufficientData)
            .length,
        f['insufficient_days'],
      );
      expect(
        g.calendar[g.fsm.indexWhere(
          (RegimeDay d) => d.status == RegimeStatus.ok,
        )],
        f['first_ok'],
      );
      final List<RegimeDay> tail = g.fsm.sublist(
        g.calendar.indexOf(f['compare_from']! as String),
      );
      expect(
        _lineHash(tail.map((RegimeDay d) => d.directionState.code)),
        f['state_from_sha256'],
      );
      expect(
        _lineHash(tail.map((RegimeDay d) => d.barsInState)),
        f['bars_from_sha256'],
      );
      expect(
        _lineHash(tail.map((RegimeDay d) => d.trendState.code)),
        f['trend_from_sha256'],
      );
    });

    test('KOSDAQ 추세 점수 — 기준일 이하 표본 같음 · 결측 수 같음(번들의 2026-08-18 한 행만 없다)', () {
      final Map<String, Object?> t = obj(want['tskr']);
      final List<PriceBar> kq = SqliteMarketStore(db)
          .readBars('KR', MarketSymbols.kosdaq);
      expect(kq, hasLength((obj(t['calendar'])['n']! as int) - 1));
      expect(kq.first.tradeDate, obj(t['calendar'])['first']);
      final List<double?> tskr = trendScoreKr(<double?>[
        for (final PriceBar b in kq) b.close,
      ]);
      expect(_nans(tskr), t['nan']);
      final Map<String, int> pos = <String, int>{
        for (int i = 0; i < kq.length; i++) kq[i].tradeDate: i,
      };
      int n = 0;
      for (final MapEntry<String, Object?> e in obj(t['samples']).entries) {
        final String w = e.value! as String;
        final double? v = tskr[pos[e.key]!];
        if (w == 'nan') {
          expect(v == null || v.isNaN, isTrue, reason: e.key);
        } else {
          expect(v, double.parse(w), reason: e.key);
        }
        n++;
      }
      expect(n, 26);
    });

    test('국면 행 저장 — 전 기간 10,485행 · LIVE · 다시 쓰면 0 · 마지막 날 = FSM', () {
      final SqliteRegimeStore rs = SqliteRegimeStore(db);
      expect(
        rs.writeComputation(
          g,
          fromDate: '1985-01-02',
          source: RegimeRowSource.live,
          configHash: 'cfg_p0s',
        ),
        10485,
      );
      expect(
        rs.writeComputation(
          g,
          fromDate: '1985-01-02',
          source: RegimeRowSource.backfill,
          configHash: 'cfg_p0s',
        ),
        0,
        reason: '덧붙이기만 — 있는 날은 고치지 않는다',
      );
      expect(rs.lastDate(), kSeedAsOf);
      final Map<String, Object?> last = rs.row(kSeedAsOf)!;
      expect(last['source'], 'LIVE');
      expect(last['direction_state'], g.fsm.last.directionState.code);
      expect(last['bars_in_state'], g.fsm.last.barsInState);
      expect(last['direction_score'], g.direction.last.direction);
      expect(last['excluded_categories'], '[]');
      final Map<String, Object?> first = rs.row('1985-01-02')!;
      expect(first['status'], 'INSUFFICIENT_DATA');
      expect(first['direction_state'], 'UNKNOWN');
      expect(first['direction_score'], isNull);
      // 제외된 카테고리 = 코드 JSON 배열 · 그 칸은 NULL(1985~ 은 BREADTH 원천이 없다 — RSP 는 2003~).
      final int t = g.direction.indexWhere(
        (DirectionScore d) =>
            d.status == RegimeStatus.ok && d.excluded.isNotEmpty,
      );
      final Map<String, Object?> ex = rs.row(g.calendar[t])!;
      expect(
        ex['excluded_categories'],
        jsonEncode(<String>[
          for (final RegimeCategory c in g.direction[t].excluded) c.code,
        ]),
      );
      expect(ex['excluded_categories'], contains('BREADTH'));
      expect(ex['cat_breadth'], isNull);
      expect(ex['cat_trend'], g.direction[t].categories[RegimeCategory.trend]);
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM regime_score_daily WHERE direction_state = 'BEAR'",
            )
            .first['n'],
        obj(obj(want['fsm'])['state_counts'])['BEAR'],
      );
    });
  });

  group('«번들 vs 실전 원천» 겹친 날 대조(D9)', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('aaq_seed_overlap_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('FRED JSON · fredgraph CSV · OFR CSV — 기준일 이하는 번들과 같고 새 날만 덧붙는다', () {
      final Database db = openIn(dir);
      importSeedBundle(db, _assets(), importedAt: _at);
      final SqliteMarketStore s = SqliteMarketStore(db);
      String fx(String p) => File('test/fixtures/$p').readAsStringSync();
      const String at = '2026-09-08T00:00:00.000Z';

      final WriteCount nfci = s.insertSeries(
        MarketSeriesIds.nfci,
        parseFredJson(fx('fred/NFCI.json'), start: '2026-07-24'),
        source: MarketDataSource.fred,
        fetchedAt: at,
      );
      expect((nfci.overlapSame, nfci.overlapRevised, nfci.inserted), (3, 0, 3));

      final WriteCount t10 = s.insertSeries(
        MarketSeriesIds.t10y3m,
        parseFredCsv(fx('fred_csv/T10Y3M.csv'), start: '2026-08-11'),
        source: MarketDataSource.fredCsv,
        fetchedAt: at,
      );
      expect((t10.overlapSame, t10.overlapRevised, t10.inserted), (4, 0, 2));
      // 번들에 있던 기준일 뒤 실제 값(2026-08-17 = 0.85)이 실전 원천으로 들어온다.
      expect(s.readSeries(MarketSeriesIds.t10y3m).at('2026-08-17'), 0.85);

      final WriteCount ofr = s.insertSeries(
        MarketSeriesIds.ofrFsi,
        parseOfrCsv(fx('ofr/fsi.csv'), start: '2026-08-10'),
        source: MarketDataSource.ofr,
        fetchedAt: at,
      );
      expect((ofr.overlapSame, ofr.overlapRevised, ofr.inserted), (4, 0, 2));
      expect(
        db
            .select(
              "SELECT source, COUNT(*) AS n FROM market_series WHERE source <> 'SEED_BUNDLE' "
              'GROUP BY source ORDER BY source',
            )
            .map((Row r) => '${r['source']}=${r['n']}'),
        <String>['FRED=3', 'FRED_CSV=2', 'OFR=2'],
      );
    });
  });
}
