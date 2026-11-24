// 🆕 E11-viewer-223(설계 13 §8 R250 · 01 §8 미결 223 · 계약 v1.36 §45) — 뷰어 계약 창구 뼈대: 읽기 모델 22표 → 계약 저장소.
//
// 🔴 창구가 서는 것 = 계약 상수만으로 «어느 행 · 어떤 차례»가 정해지는 것뿐이다:
//    모드별 1행 표 · 키 한 행 · jsonb 목록 열(받은 순서) · 시리즈 점(`date` 오름차순 — 계약 제외 사유) ·
//    `is_default` 행(미결 223 ⓓ) · 목록 봉투(`rm_list_envelope`).
// 🔴 서지 않는 것 = 던진다(빈 VM · 기본 글자 · 지어낸 차례 0):
//    ① 행 표 목록(일지 · 보유 · 회차 · 안내 · 차이 · blind · 알림 · 체인) — 엔진 차례 · 소속을 실을 열이 없다
//       → [_noOrder](계약 창 대기 · 미결 223 꼬리) · 봉투 · limit+1 · 필터 빈 문장 규칙은 `listResultOf` 에 이미 있다.
//    ② 한 표가 아닌 조립 VM · 폰 전용 창구 → [_noSource](미결 223 ⓒ).
//    ③ 사용자 지정 구간 · 구간 지정 시리즈 → [_noRange](미결 223 ⓓ — 행 = 프리셋 · 엔진 기본 구간뿐).
// 🔴 모드 = [ViewerReadModels.mode](조립 앱이 정한다 — 화면 상태 모드 · 모드 인자가 있는 창구는 지금 서지 않는다).
// 🔴 쓰기 0 — 뷰어 명령(INSERT)은 E11m(`CommandApi`) 몫이다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart'
    show
        AccountMappingVm,
        AdviceInboxSummary,
        AdviceItem,
        AdviceRepository,
        AdviceStatus,
        AfterTaxLadder,
        AlertCenterVm,
        AlertDetailVm,
        AlertItem,
        AlertLevel,
        AlertRepository,
        AllocationEditorVm,
        AnnualReviewIndexVm,
        AnnualReviewVm,
        BackupVm,
        BlindReviewCard,
        ConfigRepository,
        ConnectionsVm,
        ContributionSetting,
        ContributionVm,
        CredentialListVm,
        DateRange,
        DecisionDetailVm,
        DecisionJournalVm,
        DeviceAccessVm,
        DeviceRiskVm,
        DiagnosticsScreenVm,
        DiagnosticsVm,
        DisclosureGateVm,
        DrawdownContextVm,
        ExecutionGapReport,
        ExecutionGapRepository,
        ExecutionGapResult,
        ExternalHoldingRow,
        FeatureFlags,
        FillOrigin,
        GoalPathVm,
        HoldingDetailVm,
        HoldingRow,
        HoldingsOverviewVm,
        HoldingsRepository,
        JournalDraftFormSpec,
        JournalFilterCatalog,
        JournalRebalanceScope,
        JournalRepository,
        JournalStatus,
        JournalTimelineBadge,
        LedgerDiffRow,
        LedgerRepairRow,
        LedgerRepository,
        LedgerTrustBadge,
        LedgerTrustRepository,
        ListResult,
        ManualFillFormSpec,
        MonthlyContributionVm,
        MonthlyReport,
        NextRebalanceVm,
        OperationsVm,
        OpsDailySummary,
        OpsRhythmRow,
        OpsStatusRepository,
        OpsSummaryRepository,
        PerfGranularity,
        PerfMetric,
        PerformanceRepository,
        PerformanceSeries,
        ReadModelListCodes,
        ReadModelTable,
        ReadModelTables,
        RebalanceEvent,
        RebalanceRepository,
        ReportArchiveVm,
        RunMode,
        SafetyRepository,
        SafetyState,
        SelfReportSession,
        SettingsHomeVm,
        SettingsRepository,
        SleeveAllocationVm,
        SleeveCatalogEntry,
        SleeveId,
        TradeJournalEntry,
        UnknownBoardVm,
        WatchdogBoardVm;

import 'list_envelope.dart' show listEnvelopeOfRow, listResultOf;
import 'read_model_rows.dart'
    show
        ReadModelReader,
        ReadModelReaders,
        ReadModelRow,
        opsRhythmOfRow,
        performanceSeriesOfRows,
        sleeveCatalogOfRow;
import 'read_model_source.dart'
    show ReadModelOrder, ReadModelQuery, ReadModelRowMissing, ReadModelSource;
import 'version_gate.dart' show ReadModelGate, readModelGateOfRow;

/// 엔진 차례 · 소속(어느 행이 그 목록에 드는가)을 실을 열이 없다.
const String _noOrder = '행 차례 · 소속 열 없음(계약 창 대기 — 01 §8 미결 223 꼬리)';

/// 읽기 모델 원천 열 0(조립 VM · 폰 전용).
const String _noSource = '뷰어 원천 없음(읽기 모델 열 0 — 01 §8 미결 223 ⓒ)';

/// 사용자 지정 구간 · 구간 지정 시리즈.
const String _noRange =
    '사용자 지정 구간 = 뷰어 불가(행 = 프리셋 · 엔진 기본 구간 — 01 §8 미결 223 ⓓ)';

/// 뷰어 읽기 창구 묶음 — 원천 하나 · 화면 모드 하나.
final class ViewerReadModels {
  /// 묶음을 만든다.
  ViewerReadModels({required this.source, required this.mode});

  /// 읽기 모델 원천.
  final ReadModelSource source;

  /// 화면 상태 모드(창구에 모드 인자가 없을 때).
  final RunMode mode;

  /// 매매일지(M6).
  late final JournalRepository journal = _ViewerJournal(this);

  /// 투자 안내(X7).
  late final AdviceRepository advice = _ViewerAdvice(this);

  /// 보유(H6).
  late final HoldingsRepository holdings = _ViewerHoldings(this);

  /// 성과(M7).
  late final PerformanceRepository performance = _ViewerPerformance(this);

  /// 리밸런싱(M7).
  late final RebalanceRepository rebalance = _ViewerRebalance(this);

  /// 알림(N-01).
  final AlertRepository alerts = const _ViewerAlerts();

  /// 안전 상태.
  late final SafetyRepository safety = _ViewerSafety(this);

  /// 설정 보기(플래그 · 슬리브 · 월 납입).
  late final ConfigRepository config = _ViewerConfig(this);

  /// 설정(M9 — 배분 보기만).
  late final SettingsRepository settings = _ViewerSettings(this);

  /// 원장 대조(L-1).
  final LedgerRepository ledger = const _ViewerLedger();

  /// 운영 상태(W-01 워치독).
  late final OpsStatusRepository opsStatus = _ViewerOpsStatus(this);

  /// 운영 요약(H-01 · H-02).
  late final OpsSummaryRepository opsSummary = _ViewerOpsSummary(this);

  /// 원장 신뢰 등급.
  late final LedgerTrustRepository ledgerTrust = _ViewerLedgerTrust(this);

  /// 이행 갭(S7-10).
  late final ExecutionGapRepository executionGap = _ViewerExecutionGap(this);

  /// 스키마 버전 게이트(M4-8) — 이 모드의 `rm_config_view` 행. 🔴 행 없음 · 여럿 · 원천 오류(RLS 거부 · 표 부재) =
  /// `incompatible`(«모름» 상태 없음).
  Stream<ReadModelGate> watchGate() => source
      .watch(_query(ReadModelTables.configView))
      .map(
        (List<ReadModelRow> rows) =>
            readModelGateOfRow(rows.length == 1 ? rows.single : null),
      )
      .transform(
        StreamTransformer<ReadModelGate, ReadModelGate>.fromHandlers(
          handleError: (
            Object _,
            StackTrace _,
            EventSink<ReadModelGate> sink,
          ) => sink.add(ReadModelGate.incompatible),
        ),
      );

  /// 조회 — 이 묶음의 화면 모드 행만(🔵 모드 인자가 있는 창구 = 일지 · 배지 · blind 대기 = 지금 서지 않는다 ·
  /// 서면 그 인자를 여기로 넘긴다).
  ReadModelQuery _query(
    ReadModelTable table, {
    Map<String, Object?> where = const <String, Object?>{},
    List<ReadModelOrder> orderBy = const <ReadModelOrder>[],
  }) => ReadModelQuery(
    table,
    equals: <String, Object?>{'mode': mode.wire, ...where},
    orderBy: orderBy,
  );

  Stream<T> _watchOne<T extends Object>(
    ReadModelReader<T> reader, {
    Map<String, Object?> where = const <String, Object?>{},
  }) => _watchRow(reader.table, where: where).map(reader.fromRow);

  Stream<ReadModelRow> _watchRow(
    ReadModelTable table, {
    Map<String, Object?> where = const <String, Object?>{},
  }) {
    final ReadModelQuery q = _query(table, where: where);
    return source.watch(q).map((List<ReadModelRow> rows) => _one(q, rows));
  }

  Future<T> _selectOne<T extends Object>(
    ReadModelReader<T> reader, {
    Map<String, Object?> where = const <String, Object?>{},
  }) async {
    final ReadModelQuery q = _query(reader.table, where: where);
    return reader.fromRow(_one(q, await source.select(q)));
  }
}

ReadModelRow _one(ReadModelQuery q, List<ReadModelRow> rows) {
  if (rows.isEmpty) throw ReadModelRowMissing(q.table.name, q.equals);
  if (rows.length > 1) {
    throw FormatException(
      '${q.table.name}: ${q.equals} 행 ${rows.length}개(키 하나에 한 행)',
    );
  }
  return rows.single;
}

Stream<T> _none<T>(String what, String why) =>
    Stream<T>.error(UnsupportedError('$what: $why'));

Future<T> _noneNow<T>(String what, String why) =>
    Future<T>.error(UnsupportedError('$what: $why'));

/// 두 스트림의 최신 값 짝(둘 다 한 번씩 낸 뒤부터 · 한쪽 오류 = 그 오류).
Stream<R> _latest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A, B) combine,
) {
  late StreamController<R> out;
  StreamSubscription<A>? sa;
  StreamSubscription<B>? sb;
  (A,)? la;
  (B,)? lb;
  int done = 0;
  void finish() {
    if (++done == 2) unawaited(out.close());
  }

  void emit() {
    final (A,)? x = la;
    final (B,)? y = lb;
    if (x == null || y == null) return;
    try {
      out.add(combine(x.$1, y.$1));
    } on Object catch (e, st) {
      out.addError(e, st);
    }
  }

  out = StreamController<R>(
    onListen: () {
      sa = a.listen(
        (A v) {
          la = (v,);
          emit();
        },
        onError: out.addError,
        onDone: finish,
      );
      sb = b.listen(
        (B v) {
          lb = (v,);
          emit();
        },
        onError: out.addError,
        onDone: finish,
      );
    },
    onPause: () {
      sa?.pause();
      sb?.pause();
    },
    onResume: () {
      sa?.resume();
      sb?.resume();
    },
    onCancel: () async {
      await sa?.cancel();
      await sb?.cancel();
    },
  );
  return out.stream;
}

final class _ViewerJournal implements JournalRepository {
  _ViewerJournal(this._m);

  final ViewerReadModels _m;

  @override
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  }) => _none('watchTimeline', _noOrder);

  @override
  Future<TradeJournalEntry?> findByDecisionId(String decisionId) =>
      _noneNow('findByDecisionId', _noOrder);

  @override
  Future<List<TradeJournalEntry>> chainOf(String decisionId) =>
      _noneNow('chainOf', _noOrder);

  @override
  Future<List<TradeJournalEntry>> fillChain(String entryId) =>
      _noneNow('fillChain', _noOrder);

  @override
  Stream<JournalFilterCatalog> watchFilterCatalog() =>
      _none('watchFilterCatalog', _noSource);

  @override
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  }) => _none('watchTimelineBadges', _noSource);

  @override
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId) =>
      _none('watchDecisionDetail', _noSource);

  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) =>
      _noneNow('draftFormSpec', _noSource);

  @override
  Stream<UnknownBoardVm> watchUnknownBoard() =>
      _none('watchUnknownBoard', _noSource);

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) =>
      _none('watchDecisionJournal', _noSource);

  /// 그 회차 행의 `scope_` 칸 — 행 없음 = null(칩 부재) · `scope_` 두 칸 다 null = null(엔진이 칩을 내지 않았다).
  @override
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) {
    final ReadModelQuery q = _m._query(
      ReadModelTables.rebalanceEvent,
      where: <String, Object?>{'event_id': rebalanceEventId},
    );
    return _m.source.watch(q).map((List<ReadModelRow> rows) {
      if (rows.isEmpty) return null;
      final ReadModelRow row = _one(q, rows);
      if (row['scope_label'] == null && row['scope_range'] == null) {
        return null;
      }
      return ReadModelReaders.rebalanceScope.fromRow(row);
    });
  }

  @override
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  }) => _none('watchBlindReviewQueue', _noOrder);

  @override
  Stream<BlindReviewCard> watchBlindReviewCard(String decisionId) =>
      _m._watchOne(
        ReadModelReaders.blindReview,
        where: <String, Object?>{'decision_id': decisionId},
      );
}

final class _ViewerAdvice implements AdviceRepository {
  _ViewerAdvice(this._m);

  final ViewerReadModels _m;

  @override
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  }) => _none('watchInbox', _noOrder);

  @override
  Stream<AdviceInboxSummary> watchSummary() =>
      _m._watchOne(ReadModelReaders.adviceSummary);

  /// 그 id 의 행(키 = 거래일 · id — 안내 id 는 거래일을 넘어 하나) · 없음 = null.
  @override
  Future<AdviceItem?> findById(String adviceId) async {
    final ReadModelQuery q = _m._query(
      ReadModelTables.advice,
      where: <String, Object?>{'advice_id': adviceId},
    );
    final List<ReadModelRow> rows = await _m.source.select(q);
    if (rows.isEmpty) return null;
    return ReadModelReaders.advice.fromRow(_one(q, rows));
  }

  @override
  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range}) =>
      _none('watchHistory', _noOrder);

  @override
  Stream<ManualFillFormSpec> watchManualFillFormSpec() =>
      _none('watchManualFillFormSpec', _noSource);

  /// 🔴 뷰어 판 = 빈 목록(v1.12 K40 · A6 마스킹의 연장).
  @override
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId) =>
      Future<List<TradeJournalEntry>>.value(const <TradeJournalEntry>[]);
}

final class _ViewerHoldings implements HoldingsRepository {
  _ViewerHoldings(this._m);

  final ViewerReadModels _m;

  @override
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false}) =>
      _none('watchHoldings', _noOrder);

  @override
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false}) =>
      _none('watchHoldingsOverview', _noSource);

  @override
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  }) => _none('watchHoldingDetail', _noSource);

  @override
  Stream<SleeveAllocationVm> watchAllocation() =>
      _m._watchOne(ReadModelReaders.sleeveAllocation);
}

final class _ViewerPerformance implements PerformanceRepository {
  _ViewerPerformance(this._m);

  final ViewerReadModels _m;

  /// 행 = 엔진 기본 구간 시리즈 하나 + 그 점(`date` 오름차순). 🔴 [range] 지정 = 불가.
  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) async {
    if (range != null) throw UnsupportedError('series(range): $_noRange');
    final Map<String, Object?> key = <String, Object?>{
      'metric': metric.wire,
      'granularity': granularity.wire,
      'cumulative': cumulative,
    };
    final ReadModelQuery head = _m._query(
      ReadModelTables.performanceSeries,
      where: key,
    );
    final ReadModelRow seriesRow = _one(head, await _m.source.select(head));
    final List<ReadModelRow> points = await _m.source.select(
      _m._query(
        ReadModelTables.performancePoint,
        where: key,
        orderBy: const <ReadModelOrder>[ReadModelOrder('date')],
      ),
    );
    return performanceSeriesOfRows(seriesRow, points);
  }

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) => _m._selectOne(
    ReadModelReaders.monthlyReport,
    where: <String, Object?>{'yyyy_mm': yyyyMm},
  );

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) =>
      _noneNow('afterTaxLadder', _noSource);

  @override
  Future<ReportArchiveVm> reportArchive() =>
      _m._selectOne(ReadModelReaders.reportArchive);

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() =>
      _m._watchOne(ReadModelReaders.disclosureGate);

  /// null = `is_default` 행 · 프리셋 = 그 `range_preset_code` 행 · 사용자 지정 = 불가(미결 223 ⓓ).
  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) {
    final Map<String, Object?>? where = _presetWhere(
      range,
      nullIsDefault: true,
    );
    if (where == null) return _noneNow('drawdownContext(range)', _noRange);
    return _m._selectOne(ReadModelReaders.drawdownContext, where: where);
  }

  /// 프리셋 = 그 `range_preset_code` 행 · 사용자 지정 = 불가(미결 223 ⓓ).
  @override
  Future<ContributionVm> contribution({required DateRange range}) {
    final Map<String, Object?>? where = _presetWhere(
      range,
      nullIsDefault: false,
    );
    if (where == null) return _noneNow('contribution(range)', _noRange);
    return _m._selectOne(ReadModelReaders.contribution, where: where);
  }

  @override
  Future<AnnualReviewVm> annualReview({String? year}) =>
      _noneNow('annualReview', _noSource);

  @override
  Future<GoalPathVm> goalPath({required String yyyyMm}) =>
      _noneNow('goalPath', _noSource);
}

/// `rm_perf_context` 행 고르기 — null(사용자 지정 · 기본 불가) = 원천 없음.
Map<String, Object?>? _presetWhere(
  DateRange? range, {
  required bool nullIsDefault,
}) {
  if (range == null) {
    return nullIsDefault ? <String, Object?>{'is_default': true} : null;
  }
  final String? preset = range.presetCode;
  if (preset == null) return null;
  return <String, Object?>{'range_preset_code': preset};
}

final class _ViewerRebalance implements RebalanceRepository {
  _ViewerRebalance(this._m);

  final ViewerReadModels _m;

  @override
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range}) =>
      _none('watchEvents', _noOrder);

  @override
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId) => _m._watchOne(
    ReadModelReaders.rebalanceEvent,
    where: <String, Object?>{'event_id': rebalanceEventId},
  );

  @override
  Stream<NextRebalanceVm> watchNext() => _none('watchNext', _noSource);
}

/// 🔵 알림 창구 셋 다 지금 원천이 서지 않는다(`rm_alert` = 행 차례 열 없음 · N-01 · N-02 = 조립 VM).
final class _ViewerAlerts implements AlertRepository {
  const _ViewerAlerts();

  @override
  Stream<List<AlertItem>> watchInbox({AlertLevel? min}) =>
      _none('watchInbox', _noOrder);

  @override
  Stream<AlertCenterVm> watchCenter({required bool p0Only}) =>
      _none('watchCenter', _noSource);

  @override
  Stream<AlertDetailVm> watchAlert(String alertId) =>
      _none('watchAlert', _noSource);
}

final class _ViewerSafety implements SafetyRepository {
  _ViewerSafety(this._m);

  final ViewerReadModels _m;

  @override
  Stream<SafetyState> watchState() =>
      _m._watchOne(ReadModelReaders.safetyState);
}

final class _ViewerConfig implements ConfigRepository {
  _ViewerConfig(this._m);

  final ViewerReadModels _m;

  @override
  Stream<FeatureFlags> watchFlags() =>
      _m._watchOne(ReadModelReaders.featureFlags);

  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() =>
      _m._watchRow(ReadModelTables.configView).map(sleeveCatalogOfRow);

  @override
  Stream<List<DateRange>> watchRangePresets() =>
      _none('watchRangePresets', _noSource);

  @override
  Stream<ContributionSetting> watchContributionSetting() =>
      _m._watchOne(ReadModelReaders.contributionSetting);
}

final class _ViewerSettings implements SettingsRepository {
  _ViewerSettings(this._m);

  final ViewerReadModels _m;

  @override
  Stream<SettingsHomeVm> watchHome() => _none('watchHome', _noSource);

  @override
  Stream<OperationsVm> watchOperations() => _none('watchOperations', _noSource);

  @override
  Stream<CredentialListVm> watchCredentials() =>
      _none('watchCredentials', _noSource);

  @override
  Stream<AccountMappingVm> watchAccountMapping() =>
      _none('watchAccountMapping', _noSource);

  @override
  Stream<MonthlyContributionVm> watchContribution() =>
      _none('watchContribution', _noSource);

  @override
  Stream<DiagnosticsScreenVm> watchDiagnosticsScreen() =>
      _none('watchDiagnosticsScreen', _noSource);

  @override
  Stream<AllocationEditorVm> watchAllocationEditor() =>
      _m._watchOne(ReadModelReaders.allocationEditor);
}

/// 🔵 원장 창구 셋 다 지금 원천이 서지 않는다(`rm_ledger_diff` = 행 차례 · 소속 열 없음 · 나머지 = 원천 0).
final class _ViewerLedger implements LedgerRepository {
  const _ViewerLedger();

  @override
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs() =>
      _none('watchOpenDiffs', _noOrder);

  @override
  Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings() =>
      _none('watchExternalHoldings', _noSource);

  @override
  Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50}) =>
      _none('watchRepairs', _noSource);
}

final class _ViewerOpsStatus implements OpsStatusRepository {
  _ViewerOpsStatus(this._m);

  final ViewerReadModels _m;

  @override
  Stream<WatchdogBoardVm> watchWatchdog() =>
      _m._watchOne(ReadModelReaders.watchdog);

  @override
  Stream<ConnectionsVm> watchConnections() =>
      _none('watchConnections', _noSource);

  @override
  Stream<DeviceAccessVm> watchDeviceAccess() =>
      _none('watchDeviceAccess', _noSource);

  @override
  Stream<BackupVm> watchBackup() => _none('watchBackup', _noSource);

  @override
  Stream<DiagnosticsVm> watchDiagnostics() =>
      _none('watchDiagnostics', _noSource);

  @override
  Stream<AnnualReviewIndexVm> watchAnnualReview() =>
      _none('watchAnnualReview', _noSource);

  @override
  Stream<DeviceRiskVm> watchDeviceRisk() => _none('watchDeviceRisk', _noSource);
}

final class _ViewerOpsSummary implements OpsSummaryRepository {
  _ViewerOpsSummary(this._m);

  final ViewerReadModels _m;

  @override
  Stream<OpsDailySummary> watchToday() =>
      _m._watchOne(ReadModelReaders.opsDailySummary);

  /// 행 = `rm_ops_summary.rhythm`(받은 순서 · 전부) · 봉투 = `rm_list_envelope` 그 목록 창구 행(K310).
  @override
  Stream<ListResult<OpsRhythmRow>> watchRhythm() {
    const String code = ReadModelListCodes.opsSummaryWatchRhythm;
    final ReadModelQuery env = _m._query(
      ReadModelTables.listEnvelope,
      where: const <String, Object?>{'list_code': code},
    );
    return _latest2<ReadModelRow, List<ReadModelRow>, ListResult<OpsRhythmRow>>(
      _m._watchRow(ReadModelTables.opsSummary),
      _m.source.watch(env),
      (ReadModelRow row, List<ReadModelRow> envRows) => listResultOf(
        fetched: opsRhythmOfRow(row),
        envelope: envRows.isEmpty
            ? null
            : listEnvelopeOfRow(_one(env, envRows), listCode: code),
        listCode: code,
      ),
    );
  }
}

final class _ViewerLedgerTrust implements LedgerTrustRepository {
  _ViewerLedgerTrust(this._m);

  final ViewerReadModels _m;

  @override
  Stream<LedgerTrustBadge> watchGrade() =>
      _m._watchOne(ReadModelReaders.ledgerTrust);

  @override
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  ) => _none('watchSelfReportSession', _noSource);
}

final class _ViewerExecutionGap implements ExecutionGapRepository {
  _ViewerExecutionGap(this._m);

  final ViewerReadModels _m;

  /// null = `is_default` 행(엔진 기본 달 · 미결 223 ⓓ) · 달 = 그 `yyyy_mm` 행.
  @override
  Future<ExecutionGapResult> monthly({String? yyyyMm}) => _m._selectOne(
    ReadModelReaders.executionGap,
    where: yyyyMm == null
        ? const <String, Object?>{'is_default': true}
        : <String, Object?>{'yyyy_mm': yyyyMm},
  );

  /// 롤링 = 표 밖(K312 · 06 X7-4 정의 전).
  @override
  Stream<ExecutionGapReport> watchRolling() => _none('watchRolling', _noSource);
}
