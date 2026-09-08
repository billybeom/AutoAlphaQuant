// 01 §2-4 «성과·세후» 축(인벤토리 §2-5).
//
// 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간 차액도 금지 —
//    C-30 이 검사한다.
// 🔴 «정직 기대»·사다리 4자리 수치를 코드·라벨·주석에 옮기지 않는다(01 §2-4 조문).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-4 · `rm_performance_point.metric`.
/// 🔵 `twr` 은 **외부 현금흐름 보정판**이다(P 회차 실측으로 MWR 과 유의한 차가 확인됐다).
enum PerfMetric {
  @JsonValue('TWR')
  twr('TWR'),
  @JsonValue('MWR')
  mwr('MWR');

  const PerfMetric(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-4 — 시계열 간격.
enum PerfGranularity {
  @JsonValue('DAILY')
  daily('DAILY'),
  @JsonValue('WEEKLY')
  weekly('WEEKLY'),
  @JsonValue('MONTHLY')
  monthly('MONTHLY'),
  @JsonValue('YEARLY')
  yearly('YEARLY');

  const PerfGranularity(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-4 — 구간의 성격.
///
/// 🔴 `manualExecuted`(X7)는 `simExcluded` 와 달리 **합산에 포함**되고 경계는 실선이다(D6).
///    겹치면 `freshAuto` 절단선이 이긴다.
enum SegmentKind {
  @JsonValue('MEASURED')
  measured('MEASURED'),
  @JsonValue('UNAVAILABLE')
  unavailable('UNAVAILABLE'),
  @JsonValue('SIM_EXCLUDED')
  simExcluded('SIM_EXCLUDED'),
  @JsonValue('MANUAL_EXECUTED')
  manualExecuted('MANUAL_EXECUTED');

  const SegmentKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-4(P 회차) — 세후 사다리의 갈래. `m2-8_naming.md` A-7 확정.
///
/// 🔴 **갈래는 계좌 배치가 정한다**(SAF-309) — 화면·인자로 고르는 경로를 만들지 않는다.
///    `PerformanceRepository.afterTaxLadder({required String fiscalYear})` 의 인자는 연도 하나다.
enum TaxLadderBranch {
  @JsonValue('SPEC_POT_TAX_FREE')
  specPotTaxFree('SPEC_POT_TAX_FREE'),
  @JsonValue('CF_POT_TAXABLE_COMP26')
  cfPotTaxableComp26('CF_POT_TAXABLE_COMP26'),
  @JsonValue('CF_POT_TAXABLE_COMP38')
  cfPotTaxableComp38('CF_POT_TAXABLE_COMP38'),
  @JsonValue('CF_POT_TAXABLE_FLAT')
  cfPotTaxableFlat('CF_POT_TAXABLE_FLAT');

  const TaxLadderBranch(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
