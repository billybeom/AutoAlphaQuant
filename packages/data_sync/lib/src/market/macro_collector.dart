// 매크로·신용 계열 수집 — FRED 4 · OFR 1 → `market_series` + `fetch_log` (+ 실패면 `data_gap`)
// (설계 13 §8 R23 D7·D9·D10 · R26 H3·H5·H6 · E8c · FR-110 · FR-111).
//
// 🔴 시드 없이는 돌지 않는다([StateError]) — 확장 백분위는 1985~ 이력이 있어야 뜻이 있다(R23 D9).
// 🔴 요청 시작 = 그 계열의 마지막 저장일(포함) — 하루 겹쳐 받아 «같은 날 값»을 맞대고(R23 D9 대조 · 다르면 세기만),
//    새 날만 덧붙인다. 그래서 시드 뒤 첫 실행이 곧 2026-08-15~ 백필이고, 실패한 날 뒤 다음 성공이 곧 소급이다(D10).
// 🔴 끝내 실패 = `fetch_log` FAILED + `data_gap(macro, MISSING_ROW, recoverable 1)` — P1 `DATA_SOURCE_DOWN` 알림은
//    잡(E11)이 [SeriesCollectResult.failed] 를 보고 낸다. 미국·매크로 결측은 그날 계획을 멈추지 않는다(재정규화 · D4).
// 🔵 KIS 가 평소 원천인 4계열(SPY·RSP·VIX·VIX3M)과 ^GSPC·KOSDAQ 일봉은 E8d — 여기서 받지 않는다.
//    🆕 단 VIX·VIX3M 은 KIS 지수 코드를 아직 재지 않아 FRED 가 대신 받는다([standIns] · 설계 13 §8 R30 N5).

import 'package:core_engine/core_engine.dart' show DataGapCause, plusDays;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, MarketDataSource;
import 'package:sqlite3/sqlite3.dart';

import 'fetch_log.dart';
import 'gap_store.dart';
import 'market_ids.dart';
import 'market_store.dart';
import 'series_clients.dart';

/// 수집 기록의 요청 종류.
const String kSeriesRequestKind = 'SERIES';

/// 계열 하나의 수집 결과.
class SeriesCollectResult {
  const SeriesCollectResult({
    required this.seriesId,
    required this.outcome,
    required this.fetchId,
    this.source,
    this.write,
    this.gapId,
    this.detail,
  });

  final String seriesId;
  final FetchOutcome outcome;
  final String fetchId;

  /// 실제로 받은 길(실패면 null).
  final MarketDataSource? source;

  /// 쓰기 결과(실패면 null).
  final WriteCount? write;

  /// 실패면 기록한 결측 id.
  final String? gapId;

  /// 수집 기록에 남긴 문장.
  final String? detail;

  /// 끝내 받지 못했다(잡이 P1 을 낸다).
  bool get failed => outcome == FetchOutcome.failed;
}

/// FRED·OFR 이 평소 원천인 계열을 받아 원장에 쌓는다.
class MacroCollector {
  MacroCollector(
    this._db, {
    required this._fred,
    required this._ofr,
    required this._clock,
  });

  final Database _db;
  final FredClient _fred;
  final OfrClient _ofr;
  final Clock _clock;

  /// 이 수집기가 맡는 계열(평소 원천 = FRED · OFR).
  static final List<SeriesPlan> plans = <SeriesPlan>[
    for (final SeriesPlan p in kRegimeSeriesPlans)
      if (p.primary == MarketDataSource.fred ||
          p.primary == MarketDataSource.ofr)
        p,
  ];

  /// 🆕 KIS 가 평소 원천인데 KIS 지수 코드를 아직 재지 않은 계열(VIX · VIX3M) — FRED 길만 남긴 원천 순서
  /// (FR-111 폴백 순서의 둘째 길을 당분간 평소 길로 · 설계 13 §8 R30 N5). 행 `source` = 실제 받은 길.
  /// KIS 실호출 확인(network 시험 · 발주자 승인) 뒤 비운다.
  static final List<SeriesPlan> standIns = <SeriesPlan>[
    for (final SeriesPlan p in kRegimeSeriesPlans)
      if (p.seriesId == MarketSeriesIds.vix ||
          p.seriesId == MarketSeriesIds.vix3m)
        SeriesPlan(p.seriesId, <SeriesFeed>[
          for (final SeriesFeed f in p.feeds)
            if (f.source == MarketDataSource.fred) f,
        ]),
  ];

  /// 전부 받는다 — [asOf] = 이번 실행의 기준일(실패 결측의 끝날짜 · 기록의 `as_of`).
  /// 🆕 [withStandIns] = [standIns] 도 받는다(잡 배선 E11 은 참으로 부른다 — 시드에 VIX·VIX3M 이 있어야 한다).
  Future<List<SeriesCollectResult>> collect({
    required String asOf,
    bool withStandIns = false,
  }) async => <SeriesCollectResult>[
    for (final SeriesPlan p in <SeriesPlan>[
      ...plans,
      if (withStandIns) ...standIns,
    ])
      await collectOne(p, asOf: asOf),
  ];

  /// 계열 하나.
  Future<SeriesCollectResult> collectOne(
    SeriesPlan plan, {
    required String asOf,
  }) async {
    final SqliteMarketStore store = SqliteMarketStore(_db);
    final String? last = store.lastSeriesDate(plan.seriesId);
    if (last == null) {
      throw StateError('${plan.seriesId} — 시드가 없다(시드 먼저 · R23 D9)');
    }
    final SeriesFeed feed = plan.feeds.first;
    final SeriesFetch got;
    try {
      got = feed.source == MarketDataSource.ofr
          ? await _ofr.fsi(start: last)
          : await _fred.observations(feed.code, start: last);
    } on SourceDownError catch (e) {
      return _failed(plan, last: last, asOf: asOf, error: e);
    }
    final String at = _clock.nowUtc().toIso8601String();
    final String id = _fetchId(got.source, plan.seriesId, at);
    return inLedgerTransaction(_db, () {
      final WriteCount w = store.insertSeries(
        plan.seriesId,
        got.obs,
        source: got.source,
        fetchedAt: at,
      );
      final String detail = <String>[
        '${plan.seriesId} ${feed.code} $last부터',
        '새 ${w.inserted} · 겹침 같음 ${w.overlapSame} · 개정 ${w.overlapRevised}(고치지 않음)',
        if (w.rejected.isNotEmpty) '거부 ${w.rejected.length}',
        if (got.fallbackReason != null) '폴백 — ${got.fallbackReason}',
        '시도 ${got.attempts}',
      ].join(' · ');
      final FetchOutcome outcome = w.inserted > 0
          ? FetchOutcome.ok
          : FetchOutcome.empty;
      SqliteFetchLog(_db).record(
        FetchRecord(
          fetchId: id,
          source: got.source,
          requestKind: kSeriesRequestKind,
          asOf: asOf,
          rowCount: w.inserted,
          bodySha256: got.bodySha256,
          fetchedAt: at,
          outcome: outcome,
          detail: detail,
        ),
      );
      return SeriesCollectResult(
        seriesId: plan.seriesId,
        outcome: outcome,
        fetchId: id,
        source: got.source,
        write: w,
        detail: detail,
      );
    });
  }

  SeriesCollectResult _failed(
    SeriesPlan plan, {
    required String last,
    required String asOf,
    required SourceDownError error,
  }) {
    final String at = _clock.nowUtc().toIso8601String();
    final String id = _fetchId(error.source, plan.seriesId, at);
    final String from = plusDays(last, 1);
    final String detail =
        '${plan.seriesId} $last부터 — 받지 못함: ${error.reason} · 시도 ${error.attempts}';
    return inLedgerTransaction(_db, () {
      SqliteFetchLog(_db).record(
        FetchRecord(
          fetchId: id,
          source: error.source,
          requestKind: kSeriesRequestKind,
          asOf: asOf,
          rowCount: 0,
          fetchedAt: at,
          outcome: FetchOutcome.failed,
          detail: detail,
        ),
      );
      final String gap = SqliteGapStore(_db).record(
        dataset: GapDataset.macro,
        key: plan.seriesId,
        fromDate: from,
        toDate: asOf.compareTo(from) < 0 ? from : asOf,
        cause: DataGapCause.missingRow,
        detectedAt: at,
      );
      return SeriesCollectResult(
        seriesId: plan.seriesId,
        outcome: FetchOutcome.failed,
        fetchId: id,
        gapId: gap,
        detail: detail,
      );
    });
  }

  static String _fetchId(MarketDataSource s, String seriesId, String at) =>
      '${s.wire}:$kSeriesRequestKind:$seriesId:$at';
}
