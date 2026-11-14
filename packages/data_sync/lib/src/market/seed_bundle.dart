// 동결 번들 시드 — 국면 원천 11파일을 로컬 원장에 한 번 적재한다(설계 13 §8 R23 D9 · R26 H2·H8 · E8c).
//
// 🔴 왜: 국면 백분위가 expanding 이라(1985~ 전 이력) 오늘 값 하나로는 국면을 계산할 수 없다. 시드 = E6 재현 번들
//    (`core_engine/test/replay/data` · 기준일 2026-08-14 · 발주자 2026-10-20 R3)의 국면 부분집합을 **앱 자산**으로
//    동봉한 것(Yahoo 유래 포함 — 발주자 2026-10-22 D9). 파일은 번들과 바이트가 같다(시험이 MANIFEST 와 맞댄다).
// 🔴 기준일([kSeedAsOf]) **이하** 행만 넣는다 — 그 뒤(2026-08-15~)는 실전 원천이 `source` 를 남기며 채운다(백필).
// 🔴 fail-closed — 파일 하나라도 없거나 sha256 이 다르면 아무것도 쓰지 않고 [StateError]. 쓰기는 한 트랜잭션(전부 또는 0).
// 🔵 멱등 — 이미 적재했으면(수집 기록 11행) 읽지도 않고 돌아온다 · 다시 돌려도 행은 늘지 않는다(덧붙이기만).
// 🆕 E8d1(R28 K6) — 파일 하나가 행선지 여럿일 수 있다: `spy` = `SPY_ADJ` 계열 + `daily_prices` US `SPY` 일봉
//    (`dist_days` 거래량 · R27 I1 V6a). 수집 기록은 여전히 파일마다 1행(11행)이다.
// 🔵 자산을 앱에 싣는 일(Flutter 자산 선언 · 첫 실행 배선)은 E11 — 여기는 «바이트 → 원장»만 한다.

import 'dart:convert';
import 'dart:io' show gzip;

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;
import 'package:sqlite3/sqlite3.dart';

import 'csv_table.dart';
import 'fetch_log.dart';
import 'market_ids.dart';
import 'market_store.dart';

/// 시드 기준일(번들 MANIFEST `as_of`).
const String kSeedAsOf = '2026-08-14';

/// 시드 수집 기록의 요청 종류.
const String kSeedRequestKind = 'SEED';

/// 시드 파일 하나가 어디로 가나.
sealed class SeedTarget {
  const SeedTarget();
}

/// `daily_prices` 로(OHLCV · 종가 칸 이름).
final class SeedBars extends SeedTarget {
  const SeedBars(this.market, this.symbol, {this.tradeValue, this.marketCap});

  final String market, symbol;

  /// 거래대금 · 시가총액 칸(없으면 null).
  final String? tradeValue, marketCap;
}

/// `market_series` 로(칸 하나).
final class SeedSeries extends SeedTarget {
  const SeedSeries(this.seriesId, this.column);

  final String seriesId, column;
}

/// 시드 파일(`{name}.csv.gz`) · 번들 MANIFEST 의 `gz_sha256` · 행선지([target] + [also]).
class SeedFile {
  const SeedFile(
    this.name,
    this.gzSha256,
    this.target, {
    this.also = const <SeedTarget>[],
  });

  final String name, gzSha256;
  final SeedTarget target;

  /// 같은 파일의 다른 행선지.
  final List<SeedTarget> also;

  /// 행선지 전부.
  List<SeedTarget> get targets => <SeedTarget>[target, ...also];

  /// 자산 파일 이름.
  String get fileName => '$name.csv.gz';
}

/// 11파일 — 열 이름은 참조 엔진 `load_all`(재현 하네스 `regimeSourcesFromBundle`)과 같다.
const List<SeedFile> kSeedFiles = <SeedFile>[
  SeedFile(
    'gspc',
    'e2d9f7a766e2cbe855176a3cce6324c496f859ef0f87e9b961c4f94fe09205f7',
    SeedBars('US', MarketSymbols.gspc),
  ),
  SeedFile(
    'kq11',
    'ac3878fe757b648e1b1659f5eec2de583a52046c57a4191e72fab3ca1870458d',
    SeedBars(
      'KR',
      MarketSymbols.kosdaq,
      tradeValue: 'Amount',
      marketCap: 'MarCap',
    ),
  ),
  SeedFile(
    'spy',
    '7d325b5f2aff5b949e5ca26cce006401fb63e7141b5f92e2579f8aba2b2d3b3d',
    SeedSeries(MarketSeriesIds.spyAdjClose, 'Adj Close'),
    also: <SeedTarget>[SeedBars('US', MarketSymbols.spy)],
  ),
  SeedFile(
    'rsp',
    'e5147d08573012d71277f16078a33bb8a76023cc5760d9e00163e76405bf0ad3',
    SeedSeries(MarketSeriesIds.rspAdjClose, 'Adj Close'),
  ),
  SeedFile(
    'vix',
    '84619cc04a570acbcdca50f4184e2081954c8bba540bbd042fe56280a6b6f255',
    SeedSeries(MarketSeriesIds.vix, 'Close'),
  ),
  SeedFile(
    'vix3m',
    'bd0e0ffedd0e00818b0eb2a8036015d308841dcf8c6d398718f757767f10f848',
    SeedSeries(MarketSeriesIds.vix3m, 'Close'),
  ),
  SeedFile(
    'ofr_fsi',
    '6bfd530be8a8942bc059dbb4d11e9c77c417a1aa24ceb8382ec8e93de9f8108a',
    SeedSeries(MarketSeriesIds.ofrFsi, 'OFR FSI'),
  ),
  SeedFile(
    'nfci',
    'de71ae185113e3880ebc8ec75712fabdc47a6a8975e7c54a566c3f78d5320ab6',
    SeedSeries(MarketSeriesIds.nfci, 'NFCI'),
  ),
  SeedFile(
    'cfnai_ma3',
    '5c97fe536db43b5a38bc03999f5033dfdd9807ec7991141453642ed2710191af',
    SeedSeries(MarketSeriesIds.cfnaiMa3, 'CFNAIMA3'),
  ),
  SeedFile(
    't10y3m',
    'a99c1afd80117d4610e7e72fd5a5611cd47b613c1bc8ceb5434cc8a0632965cf',
    SeedSeries(MarketSeriesIds.t10y3m, 'T10Y3M'),
  ),
  SeedFile(
    'sahm',
    '16b124be01aacf3108804df3f00eb872e027f91763c747282c1aad9e4d165e09',
    SeedSeries(MarketSeriesIds.sahm, 'SAHMREALTIME'),
  ),
];

/// 시드 적재 결과.
class SeedImportReport {
  const SeedImportReport({required this.alreadyImported, required this.rows});

  /// 이미 적재돼 있어 아무것도 하지 않았다.
  final bool alreadyImported;

  /// 행선지([seedTargetKey]) → 새로 쓴 행 수.
  final Map<String, int> rows;
}

/// 행선지 이름 — `daily_prices` = `{market}/{symbol}` · `market_series` = `series_id`.
String seedTargetKey(SeedTarget t) => switch (t) {
  final SeedBars s => '${s.market}/${s.symbol}',
  final SeedSeries s => s.seriesId,
};

/// 수집 기록의 시드 `fetch_id`.
String seedFetchId(SeedFile f) =>
    '${MarketDataSource.seedBundle.wire}:$kSeedRequestKind:${f.name}';

/// 🆕 E11p3b-3(R93) — 시드를 이미 다 적재했나(자산을 읽기 전에 묻는다 · 아래 적재와 같은 판정).
bool seedBundleImported(Database db) =>
    (db.select(
          'SELECT COUNT(*) AS n FROM fetch_log WHERE source = ? AND request_kind = ?',
          <Object>[MarketDataSource.seedBundle.wire, kSeedRequestKind],
        ).first['n']
        as int) ==
    kSeedFiles.length;

/// [gzBytes](자산 파일 이름 → 바이트)를 원장 [db] 에 적재한다. [importedAt] = ISO8601 UTC(`fetched_at`).
SeedImportReport importSeedBundle(
  Database db,
  Map<String, List<int>> gzBytes, {
  required String importedAt,
}) {
  if (seedBundleImported(db)) {
    return const SeedImportReport(alreadyImported: true, rows: <String, int>{});
  }
  for (final SeedFile f in kSeedFiles) {
    final List<int>? b = gzBytes[f.fileName];
    if (b == null) throw StateError('시드 파일이 없다: ${f.fileName}');
    final String got = sha256.convert(b).toString();
    if (got != f.gzSha256) {
      throw StateError('시드 sha256 불일치: ${f.fileName} $got ≠ ${f.gzSha256}');
    }
  }
  final SqliteMarketStore store = SqliteMarketStore(db);
  final SqliteFetchLog log = SqliteFetchLog(db);
  return inLedgerTransaction(db, () {
    final Map<String, int> rows = <String, int>{};
    for (final SeedFile f in kSeedFiles) {
      final CsvTable t = CsvTable.parse(
        utf8.decode(gzip.decode(gzBytes[f.fileName]!)),
      );
      int inserted = 0;
      for (final SeedTarget target in f.targets) {
        final WriteCount w = switch (target) {
          final SeedBars s => store.insertBars(
            s.market,
            s.symbol,
            _bars(t, s),
            source: MarketDataSource.seedBundle,
            fetchedAt: importedAt,
          ),
          final SeedSeries s => store.insertSeries(
            s.seriesId,
            _series(t, s.column),
            source: MarketDataSource.seedBundle,
            fetchedAt: importedAt,
          ),
        };
        if (w.rejected.isNotEmpty) {
          throw StateError(
            '시드 ${f.fileName} → ${_where(target)} — CHECK 위반 ${w.rejected.take(5)}',
          );
        }
        rows[seedTargetKey(target)] = w.inserted;
        inserted += w.inserted;
      }
      log.record(
        FetchRecord(
          fetchId: seedFetchId(f),
          source: MarketDataSource.seedBundle,
          requestKind: kSeedRequestKind,
          asOf: kSeedAsOf,
          rowCount: inserted,
          bodySha256: f.gzSha256,
          fetchedAt: importedAt,
          outcome: inserted > 0 ? FetchOutcome.ok : FetchOutcome.empty,
          detail:
              '시드 ${f.fileName} → ${f.targets.map(_where).join(' · ')} · 기준일 $kSeedAsOf 이하',
        ),
      );
    }
    return SeedImportReport(alreadyImported: false, rows: rows);
  });
}

String _where(SeedTarget t) => switch (t) {
  final SeedBars s => 'daily_prices ${s.market} ${s.symbol}',
  final SeedSeries s => 'market_series ${s.seriesId}',
};

/// 기준일 이하 · 종가 결측 행 제외(재현 하네스 `Ohlcv.fromFrame` 과 같음 — 종가 NaN 행은 버린다).
List<PriceBar> _bars(CsvTable t, SeedBars s) {
  final int d = t.indexOf('date');
  final int o = t.indexOf('Open'), h = t.indexOf('High'), l = t.indexOf('Low');
  final int c = t.indexOf('Close'), v = t.indexOf('Volume');
  final int? tv = s.tradeValue == null ? null : t.indexOf(s.tradeValue!);
  final int? mc = s.marketCap == null ? null : t.indexOf(s.marketCap!);
  double? opt(List<String> r, int? i) {
    if (i == null) return null;
    final double x = csvNumber(r[i]);
    return x.isNaN ? null : x;
  }

  return <PriceBar>[
    for (final List<String> r in t.rows)
      if (r[d].compareTo(kSeedAsOf) <= 0 && !csvNumber(r[c]).isNaN)
        PriceBar(
          tradeDate: r[d],
          open: csvNumber(r[o]),
          high: csvNumber(r[h]),
          low: csvNumber(r[l]),
          close: csvNumber(r[c]),
          closeUnadj: csvNumber(r[c]),
          volume: _wholeVolume(r[v], r[d]),
          tradeValue: opt(r, tv),
          marketCap: opt(r, mc),
        ),
  ];
}

/// 기준일 이하 · 값 결측 행 제외(참조 엔진의 모든 계열 정렬이 `dropna` 를 먼저 한다).
List<SeriesObs> _series(CsvTable t, String column) {
  final int d = t.indexOf('date');
  final int c = t.indexOf(column);
  return <SeriesObs>[
    for (final List<String> r in t.rows)
      if (r[d].compareTo(kSeedAsOf) <= 0 && !csvNumber(r[c]).isNaN)
        SeriesObs(r[d], csvNumber(r[c])),
  ];
}

int _wholeVolume(String cell, String date) {
  final double x = csvNumber(cell);
  if (x.isNaN || x != x.truncateToDouble()) {
    throw FormatException('거래량이 정수가 아니다: $date «$cell»');
  }
  return x.toInt();
}
