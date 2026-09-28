// 01 §4-1 — 성과·리포트(M7) 읽기 창구.
//
// 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간 차액도
//    금지이며 C-30 이 검사한다(01 §2-4).

import '../dto/performance.dart';
import '../enums/performance.dart';
import '../primitives/date_range.dart';

/// 성과 시리즈 · 월간 리포트 · 세후 사다리 + G-41 뷰모델 6종의 창구.
abstract interface class PerformanceRepository {
  /// `S7-2` 성과 시리즈.
  /// 🆕 v1.3 — `range == null` = **엔진 기본 구간**(주기마다 엔진이 고른다).
  ///    무엇이 골라졌는지는 `PerformanceSeries.periodLabel` 이 말한다.
  /// 🔴 `granularity: weekly` 는 v1.3 에서 화면이 부르지 않는다(01 §8 미결 54 — 주 경계).
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  });

  /// 기본 창구.
  Future<MonthlyReport> monthlyReport(String yyyyMm);

  /// 🆕 P 회차 — 세후 사다리(§2-4). 기존 2종에 **추가**되는 세 번째 창구다.
  /// 🔴 갈래는 인자가 아니라 **계좌 매핑에서 파생**한다 — 화면이 갈래를 고르지 못한다.
  /// 🔴 인자는 **연도 하나**다. 임의 구간(`DateRange`)을 받지 않는다 — 세후는 연 1회
  ///    산출이고, 구간을 화면이 고르면 «어느 창의 세후가 진짜인가»를 화면이 판정하게 된다.
  /// 🔴 보정판 산식 확정 전에는 `isReferenceOnly == true` 인 골든 참고 사다리만 돌아온다(§8-18).
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear});

  // ───── 🆕 G-41 — M7 뷰모델 6종의 창구 ─────

  /// `S7-1b` — 🔴 수치 필드가 없는 월 목록이다.
  /// 🆕 v1.3 — `rows` 는 엔진이 **최신 달부터** 정렬해서 준다. 화면은 재정렬·묶기를 하지 않는다.
  Future<ReportArchiveVm> reportArchive();

  /// `S7-2G` 열람 게이트. 🔴 이번 달 열람 횟수는 **명령 테이블(append-only)의 집계**이며
  ///    화면이 세지 않는다(G-42). 화면이 「n회」를 숫자로 조립하지 않는다.
  Stream<DisclosureGateVm> watchDisclosureGate();

  /// `S7-3` 드로다운 맥락.
  /// 🆕 v1.1(C4 R2-Gem Q1) — `range == null` = **엔진 기본 구간**. 그 결과가 무엇인지는
  ///    `DrawdownContextVm.periodLabel` 이 말한다 — 화면은 기본 구간을 알 필요가 없다.
  Future<DrawdownContextVm> drawdownContext({DateRange? range});

  /// `S7-3b` 슬리브 기여 분해.
  /// 🔴 월 납입 설정과 무관한 타입이다 — `MonthlyContributionVm` 과 이름을 공유하지 않는다(§2-6).
  Future<ContributionVm> contribution({required DateRange range});

  /// `S7-7` — 🔴 묶음이지 재집계가 아니다. 화면이 `windowState` 를 «달»로 판정하지 않는다.
  Future<AnnualReviewVm> annualReview({required String year});
}
