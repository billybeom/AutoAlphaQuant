// 01 §2-5 — 리밸런싱(M7 요구 5) · §2-6 배분 현황 행(P 회차) · 다음 회차 예고.
//
// 🔴 `SleeveWeight.basis` 는 `accounting` 외 값을 갖지 않는다(01 §2-5). 엔진 원장
//    열의 값은 `SleeveAllocationRow.engineColumnNote`(문자열)로만 흐르며, 두 기준을
//    한 표에 섞어 합계 100% 를 만들지 않는다 — C-31 이 basis 혼합과 `A + POT`
//    산술을 탐지한다.
// 🔴 P 회차 실측 수치(엔진 열 vs 회계 열)를 코드·주석에 상수로 옮기지 않는다.
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/rebalance.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';

part 'rebalance.freezed.dart';
part 'rebalance.g.dart';

/// 01 §2-5 — 리밸런싱 1회차.
@freezed
abstract class RebalanceEvent with _$RebalanceEvent {
  const factory RebalanceEvent({
    required String eventId,
    required RunMode mode,
    @TradeDateConverter() required TradeDate tradeDate,
    required RebalanceKind kind,

    /// 엔진 생성.
    required String kindLabel,
    required List<SleeveWeight> before,
    required List<SleeveWeight> after,

    /// 당시 국면·신호 원값·밴드 여유.
    required TriggerSnapshot trigger,
    required List<String> orderIntentIds,
    required AsOf asOf,

    /// 실측 슬리피지 vs 가정치·미체결률 — m2-8 F-10.
    ExecutionQuality? quality,
  }) = _RebalanceEvent;

  factory RebalanceEvent.fromJson(Map<String, dynamic> json) =>
      _$RebalanceEventFromJson(json);
}

/// 01 §2-5 — 슬리브 비중 1행. 홈의 «목표 대비 편차·밴드 여유»가 이 타입이다.
/// 🔴 `basis` 는 M2-2 배치 전까지 **nullable** 이며 null = 미표기 →
///    목표·밴드와 비교하지 않는다. 승격은 M2 하나가 하며, 올리면 이 타입을
///    싣는 모든 픽스처·C-1 골든이 동시에 깨진다(01 §2-5).
@freezed
abstract class SleeveWeight with _$SleeveWeight {
  const factory SleeveWeight({
    required SleeveId sleeve,
    required double weight,
    required double targetWeight,
    required double bandLow,
    required double bandHigh,

    /// "B 42.0% (목표 42.0%, 밴드 여유 1.8%p)" — 엔진 생성.
    required String label,

    /// 🆕 P 회차 — 기준 축. 🔴 `accounting` 외 값을 갖지 않는다.
    AllocationBasis? basis,
  }) = _SleeveWeight;

  factory SleeveWeight.fromJson(Map<String, dynamic> json) =>
      _$SleeveWeightFromJson(json);
}

/// 01 §2-5 — 판정 근거 스냅샷. 🔴 수치는 전부 엔진이 포맷한 문자열이다.
@freezed
abstract class TriggerSnapshot with _$TriggerSnapshot {
  const factory TriggerSnapshot({
    required String configHash,

    /// 지표명 → 엔진 포맷 문자열. 계절 게이트 키는 `trend_score_kr`.
    required Map<String, String> rawValues,

    /// 엔진 생성 한 줄.
    required String summary,
    @DecimalStringConverter() Decimal? triggerPrice,

    /// 🔴 사전 등록 임계값 — 사후 변경 감사용.
    double? thresholdRegistered,
  }) = _TriggerSnapshot;

  factory TriggerSnapshot.fromJson(Map<String, dynamic> json) =>
      _$TriggerSnapshotFromJson(json);
}

/// 01 §2-5 · m2-8 F-10 — 실행 품질. 🔴 실측 vs 가정치 비교 문장도 엔진이 만든다.
@freezed
abstract class ExecutionQuality with _$ExecutionQuality {
  const factory ExecutionQuality({
    required String slippageText,
    required String assumedSlippageText,
    required String unfilledRateText,
    required String summary,
  }) = _ExecutionQuality;

  factory ExecutionQuality.fromJson(Map<String, dynamic> json) =>
      _$ExecutionQualityFromJson(json);
}

/// 01 §2-6 · m2-8 C-7 · E-7 — 배분 현황 1행(`H-1`·`H-3`).
/// 🔴 `SleeveWeight`·`AllocationBasis` 와 **같은 파일**에 둔다 — C-31 이 한
///    트리에서 basis 혼합을 검사할 수 있어야 한다(E-7).
/// 🔴 `SleeveAllocation`(플래너 충당액 · `plan.dart`)과 **다른 타입**이다.
@freezed
abstract class SleeveAllocationRow with _$SleeveAllocationRow {
  const factory SleeveAllocationRow({
    required SleeveId sleeve,
    required AllocationBasis basis,

    /// 투입분 금액 문자열 — 🔴 홈으로 새면 04 §2-6 금지에 걸린다.
    required String deployedText,
    required String parkingText,

    /// 🔴 막대 세그먼트 **기하 전용**. 여집합 `1 − x` 를 화면이 계산하지 않도록
    ///    두 값을 모두 준다.
    required double deployedRatio,
    required double parkingRatio,
    required String trancheStateText,

    /// 🔴 홈 재사용은 **비중(%) 전용 필드**로만 한다(금액 문자열 금지).
    required String deployedPctText,
    required String parkingPctText,

    /// POT → A 의 하위 행(회계 소속 · 03 §2-9-3).
    SleeveId? parentSleeve,

    /// 엔진 원장 열 값의 유일한 출구 — 🔴 문자열이며 비교·합산하지 않는다.
    String? engineColumnNote,
    String? parkingNoteText,
  }) = _SleeveAllocationRow;

  factory SleeveAllocationRow.fromJson(Map<String, dynamic> json) =>
      _$SleeveAllocationRowFromJson(json);
}

/// 01 §4-1 · m2-8 F-5 — 다음 회차 예고(`S7-6c`·`H-02`).
/// 🔴 리포지토리 반환은 **nullable 이 아니다**(N-4) — 「예정 없음」도 값으로 오며
///    그때 `emptyLabel` 이 non-null 이면 카운트다운 카드를 그리지 않고 이 문장만
///    그린다(계약 3조 ③).
/// 🔴 `dDayText`·`expectedDateText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지
///    않는다.
@freezed
abstract class NextRebalanceVm with _$NextRebalanceVm {
  const factory NextRebalanceVm({
    required String expectedDateText,
    required String dDayText,
    String? emptyLabel,
    RebalanceKind? expectedKind,
    String? kindLabel,
    String? previewRoute,
    String? noticeText,
  }) = _NextRebalanceVm;

  factory NextRebalanceVm.fromJson(Map<String, dynamic> json) =>
      _$NextRebalanceVmFromJson(json);
}
