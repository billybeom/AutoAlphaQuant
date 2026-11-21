// 🆕 E11q-q5a — M7 `S7-7` 연간 리뷰 · `S7-10` 이행 갭 읽기 모델(설계 13 §8 R220 · 나눔 계획 R169 q5).
//
// 🔴 연간 리뷰 = 엔진 `annualReviewVmOf` — 창 = 실행 묶음의 신뢰 시각(모르면 «모름») · 운영 첫 해 = S12 목차와 같은 원천
//    (`operatorFirstOperatingYear`) · 세후 = 골든 참고치 · 판 지문 = 모의 개시 판(없으면 빈 글자 — 설정 없음) ·
//    A 행 탐색 링크 = 등록된 화면만([hasBody]).
// 🔴 이행 갭 = 엔진 `executionGapResultOf` — 운영 방식 = 화면 상태(마지막 깨어남의 원장 표지) · 화면 상태 없음 = 운용 전.
// 🆕 E11q-q5b(R223) — `S7-2` 성과 탐색 시리즈 · `S7-2G` 열람 게이트 = 원장 원천 `SqlitePerformanceSource`(화면 상태의 원장 ·
//    세션 = KR 달력 · 게이트 = 원장 변경 · [tick] 마다 다시 — 달이 바뀌면 열람 수 0) · 임의 구간 = 원천 없음(화면은 인자 없이 부른다).
// 🆕 E11q-q5c(R226) — `S7-3` 드로다운 맥락 = 같은 원천(운용 전체 · 결측 = KR 달력).
// 🆕 E11q-q5c2(R228) — `S7-3b` 슬리브 기여 = 같은 원천(받은 구간 = 셸이 넘긴 엔진 기본 구간 · 체결 + 원가 종가로 슬리브 손익 재구성).
// 🆕 E11q-q5e(R231 · 미결 209 ⓔ-2 · ⓔ-3 · ⓔ-5) — `S7-1` 월간 리포트 = 화면 상태의 원장 `SqliteMonthlyReportSource.reportOnRead`
//    (읽을 때 짓기 · 자동 매매만 — 신뢰 배지 = 브로커 대사 · 보유 · 안전 상태 · 재량 · 노출 집계 = 잡 · 셸과 같은 원천 ·
//    「자세히」 = 등록된 화면만). 안내 모드 = 원천 없음(X7 신뢰 등급 사다리 · 이행 갭 조각 전).
// 🔴 나머지 M7 창구(아카이브 · 목표 경로 · 롤링 갭)는 원천 조각 전 — 지어내지 않고 «원천 없음» 오류
//    (아카이브 = 209 ⓔ-4 스냅숏 뒤 · 목표 경로 = q5d).

import 'package:core_engine/core_engine.dart'
    show P0sWarnSetup, annualReviewVmOf, executionGapResultOf, p0sExposureMap;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigRead,
        OpsConfigReady,
        SqliteDiscretionStore,
        SqliteMonthlyReportSource,
        SqliteOrderLedger,
        SqlitePerformanceSource,
        SqliteSafetyRepository,
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
        OperatingMode,
        PerfGranularity,
        PerfMetric,
        PerformanceRepository,
        PerformanceSeries,
        ReportArchiveVm,
        RunMode,
        TradeDate;

import 'operator_ops_status.dart' show operatorFirstOperatingYear;
import 'operator_runtime.dart' show OperatorRuntime;
import 'operator_view.dart' show OperatorView;
import 'view_stream.dart' show followView;

/// M7 성과 · 리포트 창구 — `S7-7` 연간 리뷰 · 🆕 `S7-2` 시리즈 · `S7-2G` 게이트 · `S7-3` 드로다운 · `S7-3b` 기여 · `S7-1` 월간 리포트.
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

  /// 🆕 E11q-q5e(R231) — `S7-1` 월간 리포트(받은 달 · 읽을 때 짓기 · 생성 시각 = 지금 · 판 지문 = 지금 설정).
  /// 화면 상태 없음 = [StateError] · 안내 모드 = [UnsupportedError](원천 없음) · 닫히지 않은 달 · 개시 전 달 = 원천의 실패.
  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('월간 리포트: 화면 상태 없음(온보딩 전)');
    if (v.flags.operatingMode != OperatingMode.autoTrade) {
      throw UnsupportedError('월간 리포트: 안내 모드 = 원천 없음(X7 신뢰 등급 사다리 · 이행 갭 조각 전)');
    }
    final OpsConfigRead cfg = currentP0sOpsConfig(v.db);
    final RunMode mode = v.flags.runMode;
    return SqliteMonthlyReportSource(
      v.db,
      mode: mode,
      kr: _rt.calendars.kr,
      // 월 잡과 같은 보유(원장 KR) · 셸과 같은 안전 상태 · 재량 사용 날.
      holdings: SqliteOrderLedger(
        v.db,
        mode: mode,
        clock: _rt.clock,
        kr: _rt.calendars.kr,
      ).krHoldings,
      safety: SqliteSafetyRepository(
        v.db,
        mode: mode,
        clock: _rt.clock,
        trusted: _rt.trusted,
        deviceId: _rt.deviceId,
      ).state,
      discretionUseDates: SqliteDiscretionStore(
        v.db,
        clock: _rt.clock,
        trusted: _rt.trusted,
      ).useDates,
      // D2 메모 = 월 잡과 같은 노출 집계 설정(지금 설정 · 못 얻으면 메모 없음).
      exposure: cfg is OpsConfigReady
          ? P0sWarnSetup(map: p0sExposureMap(cfg.config.monthEnd))
          : null,
    ).reportOnRead(
      yyyyMm,
      nowUtc: _rt.clock.nowUtc(),
      configHash: cfg is OpsConfigReady ? cfg.configHash : '',
      hasBody: hasBody,
    );
  }

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

  /// 🆕 E11q-q5c(R226) — `S7-3` 드로다운 맥락(운용 전체 · KR 달력 = 결측 셈) · 임의 구간 = 원천 없음.
  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) async {
    if (range != null) {
      throw UnsupportedError('드로다운: 임의 구간 = 원천 없음(엔진 기본 구간만)');
    }
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('드로다운: 화면 상태 없음(온보딩 전)');
    return _src(v).drawdownContext(
      isSession: (String d) => _rt.calendars.kr.isSession(TradeDate(d)),
    );
  }

  /// 🆕 E11q-q5c2(R228) — `S7-3b` 슬리브 기여(받은 구간 — 셸 = 엔진 기본 구간 `contributionDefaultRange`).
  @override
  Future<ContributionVm> contribution({required DateRange range}) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('기여: 화면 상태 없음(온보딩 전)');
    return _src(v).contribution(range: range);
  }

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
    Future<T>.error(UnsupportedError('$what: 원천 없음(R223 · q5d · 209 ⓔ-4)'));
