// E11p3d-2b — H-01 운영 홈 · H-02 운영 리듬 읽기 모델(설계 13 §8 R133 · 발주자 «H-01 맡아» 2026-11-16).
//
// 🔴 오늘 요약 · 리듬 = 화면 상태(마지막 깨어남의 원장 · 모드)의 `SqliteOpsHomeSource` — 원장이 바뀌면 · 1분마다(날짜 ·
//    D-day 넘어감) · 화면 상태가 바뀌면 다시 낸다(`followView`).
// 🔴 신뢰 시각 = 실행 묶음의 것(🆕 E11k-a R197) — 연결 전 · 못 잼 = 모름 → 재량 예산 = 엔진 문장 «신뢰 시각 확인 중».
// 🔴 홈의 나머지 셋(안내 요약 · 슬리브 비중 · 원장 실사 배지)은 원천이 없다 — 지어내지 않고 «원천 없음» 오류를 낸다
//    (안내 · 실사 = 블록 부재 · 비중 = 블록 다시 시도 · 04 §4-1 표시 조건 그대로).

import 'package:core_engine/core_engine.dart'
    show EngineWhatIfApi, nextRebalanceVmOf;
import 'package:data_sync/data_sync.dart'
    show
        SqliteHoldingsOverviewSource,
        SqliteOpsHomeSource,
        SqlitePlanSnapshotStore,
        SqliteRebalanceSource,
        SqliteSafetyRepository,
        SqliteWhatIfStateSource,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceInboxSummary,
        AdviceItem,
        AdviceRepository,
        AdviceStatus,
        CostEstimate,
        DateRange,
        DepositPlan,
        DepositPreviewResult,
        HoldingDetailVm,
        HoldingRow,
        HoldingsOverviewVm,
        HoldingsRepository,
        LedgerTrustBadge,
        LedgerTrustRepository,
        ListResult,
        ManualFillFormSpec,
        NextRebalanceVm,
        OpsDailySummary,
        OpsRhythmRow,
        OpsSummaryRepository,
        RebalanceEvent,
        RebalancePreviewResult,
        RebalanceRepository,
        SelfReportSession,
        SleeveAllocationVm,
        TradeDate,
        TradeJournalEntry,
        WhatIfApi,
        WithdrawalPlan;

import 'operator_runtime.dart';
import 'operator_self_report.dart'
    show OperatorSelfReport, OperatorSelfReportSessions, mergeKicks;
import 'operator_view.dart';
import 'view_stream.dart';

/// 홈 오늘 요약 · 운영 리듬(operator).
class OperatorOpsSummaryRepository implements OpsSummaryRepository {
  /// 만든다 — [tick] = 날짜 · D-day 넘어감 확인 주기.
  OperatorOpsSummaryRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  SqliteOpsHomeSource _src(OperatorView v) => SqliteOpsHomeSource(
    v.db,
    clock: _rt.clock,
    trusted: _rt.trusted,
    kr: _rt.calendars.kr,
    runMode: v.flags.runMode,
    operatingMode: v.flags.operatingMode,
  );

  Stream<T> _follow<T>(T Function(SqliteOpsHomeSource s) read, String what) =>
      followView<T>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<T>(
          v.db,
          SqliteOpsHomeSource.watchedTables,
          () => read(_src(v)),
        ),
        now: (OperatorView v) => read(_src(v)),
        tick: tick,
        noView: () => StateError('$what: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Stream<OpsDailySummary> watchToday() =>
      _follow((SqliteOpsHomeSource s) => s.today(), '운영 홈');

  @override
  Stream<ListResult<OpsRhythmRow>> watchRhythm() =>
      _follow((SqliteOpsHomeSource s) => s.rhythm(), '운영 리듬');
}

Stream<T> _none<T>(String what) =>
    Stream<T>.error(UnsupportedError('$what: 원천 없음(R133)'));

Future<T> _noneNow<T>(String what) =>
    Future<T>.error(UnsupportedError('$what: 원천 없음(R133)'));

/// 안내(X7) — 원천 없음(엔진 E18 전 · 홈 블록 3b = 부재).
class OperatorAdviceRepository implements AdviceRepository {
  /// 만든다.
  const OperatorAdviceRepository();

  @override
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  }) => _none('watchInbox');

  @override
  Stream<AdviceInboxSummary> watchSummary() => _none('watchSummary');

  @override
  Future<AdviceItem?> findById(String adviceId) => _noneNow('findById');

  @override
  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range}) =>
      _none('watchHistory');

  @override
  Stream<ManualFillFormSpec> watchManualFillFormSpec() =>
      _none('watchManualFillFormSpec');

  @override
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId) =>
      _noneNow('fillsOfAdvice');
}

/// 보유 · 슬리브 비중 — 🆕 E11q1(R171) H6-1 보유 현황 · 🆕 E11q1b(R172) H6-2 종목 상세 · H6-3 슬리브 배분(= 홈 블록 4) =
/// 원장(모의 = 가상 현금 · 엔진 VM · 세 화면 = 한 장부) · 보유 목록(`watchHoldings`) = 원천 없음(계약 경로 · 화면 0).
///
/// 🔴 화면 상태의 원장 — 원장이 바뀌면 · 1분마다(기준 줄) · 화면 상태가 바뀌면 다시 낸다(`followView`) ·
///    [includePnl] = 종목 손익(평단 · 기준 종가) · 링크 = 등록된 화면만([hasBody]).
class OperatorHoldingsRepository implements HoldingsRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 기준 줄 갱신 주기.
  OperatorHoldingsRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
    this.selfReportSessions,
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 다시 읽는 주기.
  final Duration tick;

  /// 🆕 E11q-q6 — `L-3` 실사 세션 장부(열린 동안 = «숨김» · 바뀌면 곧바로 다시 읽는다 · 없음 = 가림 0).
  final OperatorSelfReportSessions? selfReportSessions;

  SqliteHoldingsOverviewSource _src(OperatorView v) => _holdingsSourceOf(
    _rt,
    v,
    hasBody,
    selfReportSessionOpen: selfReportSessions?.anyOpen,
  );

  @override
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false}) =>
      _none('watchHoldings');

  Stream<T> _follow<T>(
    T Function(SqliteHoldingsOverviewSource s) read,
    String what,
  ) => followView<T>(
    view: _rt.view,
    changes: (OperatorView v) => mergeKicks<T>(
      watchLedgerQuery<T>(
        v.db,
        SqliteHoldingsOverviewSource.watchedTables,
        () => read(_src(v)),
      ),
      selfReportSessions?.changes ?? const Stream<void>.empty(),
      () => read(_src(v)),
    ),
    now: (OperatorView v) => read(_src(v)),
    tick: tick,
    noView: () => StateError('$what: 화면 상태 없음(온보딩 전)'),
  );

  @override
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false}) =>
      _follow(
        (SqliteHoldingsOverviewSource s) => s.overview(includePnl: includePnl),
        '보유 현황',
      );

  @override
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  }) => _follow(
    (SqliteHoldingsOverviewSource s) =>
        s.detail(holdingId, includePnl: includePnl),
    '종목 상세',
  );

  @override
  Stream<SleeveAllocationVm> watchAllocation() =>
      _follow((SqliteHoldingsOverviewSource s) => s.allocation(), '슬리브 배분');
}

/// 보유 현황 원천(H6-* · 리밸런싱 미리보기가 같은 장부를 쓴다 · R173).
SqliteHoldingsOverviewSource _holdingsSourceOf(
  OperatorRuntime rt,
  OperatorView v,
  bool Function(String route) hasBody, {
  bool Function()? selfReportSessionOpen,
}) => SqliteHoldingsOverviewSource(
  v.db,
  clock: rt.clock,
  kr: rt.calendars.kr,
  runMode: v.flags.runMode,
  accountLabels: rt.humanDecision?.accountLabels ?? const <String, String>{},
  hasBody: hasBody,
  selfReportSessionOpen: selfReportSessionOpen,
);

/// 🆕 R173 — 리밸런싱 원천(회차 · 미리보기 상태) · 차단 = 안전 읽기 모델과 같은 셈 · 🆕 R174 입금 등록 판정 상태도 이것.
SqliteRebalanceSource operatorRebalanceSourceOf(
  OperatorRuntime rt,
  OperatorView v,
  bool Function(String route) hasBody,
) => SqliteRebalanceSource(
  v.db,
  clock: rt.clock,
  kr: rt.calendars.kr,
  us: rt.calendars.us,
  holdings: _holdingsSourceOf(rt, v, hasBody),
  activeFlags: () => SqliteSafetyRepository(
    v.db,
    mode: v.flags.runMode,
    clock: rt.clock,
    trusted: rt.trusted,
  ).state().activeFlags,
  hasBody: hasBody,
);

/// 🆕 E11q1b(R172) — 리밸런싱 — 다음 회차(H6-3 하단 · 엔진 `nextRebalanceVmOf` · 홈 · 리듬과 같은 달력 원천) ·
/// 🆕 E11q2(R173) 회차 목록 · 한 회차(원장 `rebalance_event` → 엔진 `rebalanceEventsVmOf`).
///
/// 🔴 다음 회차 = 시간만 흐르는 값 — 1분마다 다시 셈(같은 값 = 다시 내지 않음) · 미리보기 · 상세 링크 = 등록된 화면만([hasBody]).
/// 🔴 회차 = 원장 변경 · 주기마다 다시 읽음 · 기간 인자 = 원천 없음(R12 화면은 인자 없이 부른다 · 거르기 = 엔진 몫).
class OperatorRebalanceRepository implements RebalanceRepository {
  /// 만든다.
  OperatorRebalanceRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 다시 셈 주기.
  final Duration tick;

  NextRebalanceVm _next() => nextRebalanceVmOf(
    kr: _rt.calendars.kr,
    nowUtc: _rt.clock.nowUtc(),
    hasBody: hasBody,
  );

  @override
  Stream<NextRebalanceVm> watchNext() => followView<NextRebalanceVm>(
    view: _rt.view,
    changes: (OperatorView _) => Stream<NextRebalanceVm>.value(_next()),
    now: (OperatorView _) => _next(),
    tick: tick,
    noView: () => StateError('다음 리밸런싱: 화면 상태 없음(온보딩 전)'),
  );

  Stream<T> _follow<T>(T Function(SqliteRebalanceSource s) read, String what) =>
      followView<T>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<T>(
          v.db,
          SqliteRebalanceSource.watchedTables,
          () => read(operatorRebalanceSourceOf(_rt, v, hasBody)),
        ),
        now: (OperatorView v) =>
            read(operatorRebalanceSourceOf(_rt, v, hasBody)),
        tick: tick,
        noView: () => StateError('$what: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range}) =>
      range != null
      ? _none('watchEvents(range)')
      : _follow((SqliteRebalanceSource s) => s.events(), '리밸런싱 회차');

  @override
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId) => _follow(
    (SqliteRebalanceSource s) => s.event(rebalanceEventId),
    '리밸런싱 회차 상세',
  );
}

/// 🆕 E11q2(R173) — What-if 창구(S7-6c «지금 기준 초안 보기») — 엔진 `EngineWhatIfApi` + 원장 상태 어댑터.
///
/// 🔴 화면 상태(원장 파일)마다 엔진 창구 하나(계획 id 순번 = 그 창구의 메모리 · 호출마다 새 id).
/// 🆕 E11q3(R174) — 입금 미리보기 · 계획 찾기 · 비용 = 같은 엔진 창구(읽기 · 계획 스냅숏 = 계산 보관) · 시각 = 기기 시계
/// (읽기는 신뢰 시각을 모르면 기기 시계 — R54 J6 · 등록 = 명령 API 가 신뢰 시각으로 판정) · 인출 = 원천 없음(인출 규칙 미결 79).
class OperatorWhatIfApi implements WhatIfApi {
  /// 만든다.
  OperatorWhatIfApi(this._rt, {required this.hasBody});

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  final Expando<EngineWhatIfApi> _apis = Expando<EngineWhatIfApi>();

  EngineWhatIfApi _api() {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('리밸런싱 미리보기: 화면 상태 없음(온보딩 전)');
    return _apis[v.db] ??= EngineWhatIfApi(
      source: SqliteWhatIfStateSource(
        operatorRebalanceSourceOf(_rt, v, hasBody),
      ),
      store: SqlitePlanSnapshotStore(v.db),
      clock: _rt.clock,
    );
  }

  @override
  Future<RebalancePreviewResult> previewRebalance({TradeDate? plannedDate}) =>
      Future<EngineWhatIfApi>(_api).then(
        (EngineWhatIfApi a) => a.previewRebalance(plannedDate: plannedDate),
      );

  @override
  Future<DepositPreviewResult> simulateDeposit({required String amountInput}) =>
      Future<EngineWhatIfApi>(_api).then(
        (EngineWhatIfApi a) => a.simulateDeposit(amountInput: amountInput),
      );

  /// 🔴 인자 타입 = 부모에서 추론(`Decimal` — 앱 lib 은 decimal 을 들이지 않는다 · 금액 = core).
  @override
  Future<WithdrawalPlan> simulateWithdrawal({required amount}) =>
      _q3('simulateWithdrawal');

  @override
  Future<CostEstimate> estimateCosts(String planId) =>
      Future<EngineWhatIfApi>(_api)
          .then((EngineWhatIfApi a) => a.estimateCosts(planId));

  @override
  Future<DepositPlan?> findPlan(String planId) =>
      Future<EngineWhatIfApi>(_api)
          .then((EngineWhatIfApi a) => a.findPlan(planId));

  static Future<T> _q3<T>(String what) =>
      Future<T>.error(UnsupportedError('$what: 원천 없음(인출 규칙 미결 79)'));
}

/// 원장 신뢰 배지 · 실사 — 🆕 E11q-q6c 배지 = [selfReport] 의 지금 등급(투자 안내 = 실사 갭 · 그 밖 = 브로커 대사 · 홈 블록 9b) ·
/// E11q-q6 `L-3` 세션 = [selfReport](없음 = 둘 다 원천 없음).
class OperatorLedgerTrustRepository implements LedgerTrustRepository {
  /// 만든다.
  const OperatorLedgerTrustRepository({this.selfReport});

  /// 🆕 E11q-q6 — 정기 실사(세션 VM 흐름).
  final OperatorSelfReport? selfReport;

  @override
  Stream<LedgerTrustBadge> watchGrade() =>
      selfReport?.watchGrade() ?? _none('watchGrade');

  @override
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  ) =>
      selfReport?.watch(yyyyMm, accountAlias) ??
      _none('watchSelfReportSession');
}
