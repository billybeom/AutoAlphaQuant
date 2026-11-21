// 🆕 E11q-q5a — M7 `S7-7` 연간 리뷰 · `S7-10` 이행 갭 읽기 모델(설계 13 §8 R220 · 나눔 계획 R169 q5).
//
// 🔴 연간 리뷰 = 엔진 `annualReviewVmOf` — 창 = 실행 묶음의 신뢰 시각(모르면 «모름») · 운영 첫 해 = S12 목차와 같은 원천
//    (`operatorFirstOperatingYear`) · 세후 = 골든 참고치 · 판 지문 = 모의 개시 판(없으면 빈 글자 — 설정 없음) ·
//    A 행 탐색 링크 = 등록된 화면만([hasBody]).
// 🔴 이행 갭 = 엔진 `executionGapResultOf` — 운영 방식 = 화면 상태(마지막 깨어남의 원장 표지) · 화면 상태 없음 = 운용 전.
// 🆕 E11q-q5b(R223) — `S7-2` 성과 탐색 시리즈 · `S7-2G` 열람 게이트 = 원장 원천 `SqlitePerformanceSource`(화면 상태의 원장 ·
//    세션 = KR 달력 · 게이트 = 원장 변경 · [tick] 마다 다시 — 달이 바뀌면 열람 수 0) · 임의 구간 = 원천 없음(화면은 인자 없이 부른다).
// 🔴 나머지 M7 창구(월간 리포트 · 아카이브 · 드로다운 · 기여 · 목표 경로 · 롤링 갭)는 원천 조각 전 — 지어내지 않고 «원천 없음» 오류
//    (월간 리포트 = 미결 209 ⓔ 레인 · 나머지 = q5c · q5d).

import 'package:core_engine/core_engine.dart'
    show annualReviewVmOf, executionGapResultOf;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigRead,
        OpsConfigReady,
        SqlitePerformanceSource,
        currentP0sOpsConfig,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AfterTaxLadder,
        AnnualReviewVm,
        ContributionVm,
        DateRange,
        DisclosureGateVm,
        DrawdownContextVm,
        ExecutionGapReport,
        ExecutionGapRepository,
        ExecutionGapResult,
        GoalPathVm,
        MonthlyReport,
        PerfGranularity,
        PerfMetric,
        PerformanceRepository,
        PerformanceSeries,
        ReportArchiveVm,
        TradeDate;

import 'operator_ops_status.dart' show operatorFirstOperatingYear;
import 'operator_runtime.dart' show OperatorRuntime;
import 'operator_view.dart' show OperatorView;
import 'view_stream.dart' show followView;

/// M7 성과 · 리포트 창구 — `S7-7` 연간 리뷰 · 🆕 `S7-2` 시리즈 · `S7-2G` 게이트.
class OperatorPerformanceRepository implements PerformanceRepository {
  /// 만든다.
  OperatorPerformanceRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 게이트 다시 셈 주기(달 넘어감).
  final Duration tick;

  SqlitePerformanceSource _src(OperatorView v) =>
      SqlitePerformanceSource(v.db, clock: _rt.clock);

  @override
  Future<AnnualReviewVm> annualReview({String? year}) async {
    final OpsConfigRead cfg = currentP0sOpsConfig(_rt.files.sim);
    return annualReviewVmOf(
      trustedNowUtc: _rt.trusted.trustedNowUtc(),
      nowUtc: _rt.clock.nowUtc(),
      firstOperatingYear: operatorFirstOperatingYear(_rt),
      configHash: cfg is OpsConfigReady ? cfg.configHash : '',
      hasBody: hasBody,
      year: year,
    );
  }

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) async {
    if (range != null) {
      throw UnsupportedError('성과 탐색: 임의 구간 = 원천 없음(엔진 기본 구간만)');
    }
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('성과 탐색: 화면 상태 없음(온보딩 전)');
    return _src(v).series(
      metric: metric,
      granularity: granularity,
      cumulative: cumulative,
      isSession: (String d) => _rt.calendars.kr.isSession(TradeDate(d)),
    );
  }

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) =>
      _noneNow('monthlyReport');

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) =>
      _noneNow('afterTaxLadder');

  @override
  Future<ReportArchiveVm> reportArchive() => _noneNow('reportArchive');

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() =>
      followView<DisclosureGateVm>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<DisclosureGateVm>(
          v.db,
          SqlitePerformanceSource.watchedTables,
          () => _src(v).gate(),
        ),
        now: (OperatorView v) => _src(v).gate(),
        tick: tick,
        noView: () => StateError('열람 게이트: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) =>
      _noneNow('drawdownContext');

  @override
  Future<ContributionVm> contribution({required DateRange range}) =>
      _noneNow('contribution');

  @override
  Future<GoalPathVm> goalPath({required String yyyyMm}) => _noneNow('goalPath');
}

/// `S7-10` 이행 갭 창구 — 자동 매매 = 해당 없음 · 운용 전 = 발행된 안내 0 · 안내 모드 = 원천 없음(X7 조각 전).
class OperatorExecutionGapRepository implements ExecutionGapRepository {
  /// 만든다.
  OperatorExecutionGapRepository(this._rt);

  final OperatorRuntime _rt;

  @override
  Future<ExecutionGapResult> monthly({String? yyyyMm}) async =>
      executionGapResultOf(
        mode: _rt.view.value?.flags.operatingMode,
        nowUtc: _rt.clock.nowUtc(),
        yyyyMm: yyyyMm,
      );

  @override
  Stream<ExecutionGapReport> watchRolling() => Stream<ExecutionGapReport>.error(
    UnsupportedError('watchRolling: 원천 없음(롤링 창 정의 전 · 06 X7-4)'),
  );
}

Future<T> _noneNow<T>(String what) =>
    Future<T>.error(UnsupportedError('$what: 원천 없음(R223 · q5c · q5d · 209 ⓔ)'));
