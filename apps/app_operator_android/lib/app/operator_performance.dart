// 🆕 E11q-q5a — M7 `S7-7` 연간 리뷰 · `S7-10` 이행 갭 읽기 모델(설계 13 §8 R220 · 나눔 계획 R169 q5).
//
// 🔴 연간 리뷰 = 엔진 `annualReviewVmOf` — 창 = 실행 묶음의 신뢰 시각(모르면 «모름») · 운영 첫 해 = S12 목차와 같은 원천
//    (`operatorFirstOperatingYear`) · 세후 = 골든 참고치 · 판 지문 = 모의 개시 판(없으면 빈 글자 — 설정 없음) ·
//    A 행 탐색 링크 = 등록된 화면만([hasBody]).
// 🔴 이행 갭 = 엔진 `executionGapResultOf` — 운영 방식 = 화면 상태(마지막 깨어남의 원장 표지) · 화면 상태 없음 = 운용 전.
// 🔴 나머지 M7 창구(월간 리포트 · 아카이브 · 탐색 · 드로다운 · 기여 · 목표 경로 · 열람 게이트 · 롤링 갭)는 원천 조각 전 —
//    지어내지 않고 «원천 없음» 오류(월간 리포트 = 미결 209 ⓔ 레인 · 나머지 = q5 뒤 조각).

import 'package:core_engine/core_engine.dart'
    show annualReviewVmOf, executionGapResultOf;
import 'package:data_sync/data_sync.dart'
    show OpsConfigRead, OpsConfigReady, currentP0sOpsConfig;
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
        ReportArchiveVm;

import 'operator_ops_status.dart' show operatorFirstOperatingYear;
import 'operator_runtime.dart' show OperatorRuntime;

/// M7 성과 · 리포트 창구 — 🆕 `S7-7` 연간 리뷰만 원천이 있다.
class OperatorPerformanceRepository implements PerformanceRepository {
  /// 만든다.
  OperatorPerformanceRepository(this._rt, {required this.hasBody});

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

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
  }) => _noneNow('series');

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
      Stream<DisclosureGateVm>.error(
        UnsupportedError('watchDisclosureGate: 원천 없음(R220)'),
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
    Future<T>.error(UnsupportedError('$what: 원천 없음(R220 · q5 뒤 조각)'));
