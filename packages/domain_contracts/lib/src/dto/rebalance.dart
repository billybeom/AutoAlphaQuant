// 01 §2-5 — 리밸런싱(M7 요구 5) · §2-6 배분 현황 행(P 회차) · 다음 회차 예고.
//
// 🔴 `SleeveWeight.basis` 는 `accounting` 외 값을 갖지 않는다(01 §2-5). 엔진 원장
//    열의 값은 `SleeveAllocationRow.engineColumnNote`(문자열)로만 흐르며, 두 기준을
//    한 표에 섞어 합계 100% 를 만들지 않는다 — C-31 이 basis 혼합과 `A + POT`
//    산술을 탐지한다.
// 🔴 P 회차 실측 수치(엔진 열 vs 회계 열)를 코드·주석에 상수로 옮기지 않는다.
// 🆕 v1.6(01 §15-4 · R12 선행) — `RebalanceEvent.thresholds`(J-2 `ThresholdCompare` 재사용 · `common.dart`)·
//    `modeLabel`·`sectionLabel` · `asOf` = 읽기 모델 관측 시각 · `SleeveWeight.label` = 완성 문장 ·
//    `NextRebalanceVm` 두 글자 nullable + `asOf`. 🔴 `// 🔴 ui 미참조(C-42)` 표식 = R12 화면이 읽지 않는 원값.
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/rebalance.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';

part 'rebalance.freezed.dart';
part 'rebalance.g.dart';

/// 01 §2-5 — 리밸런싱 1회차.
/// 🆕 v1.6(01 §15-4) — `thresholds`·`modeLabel`·`sectionLabel` · `asOf` 뜻 고정(관측 시각).
@freezed
abstract class RebalanceEvent with _$RebalanceEvent {
  const factory RebalanceEvent({
    required String eventId, // 🔴 표시 금지 · Key 전용
    required RunMode mode, // 🔴 ui 미참조(C-42) — 배지는 [modeLabel]
    // 표시 = `tradeDate.yyyyMmDd` 그대로(카드 예외 1개)
    @TradeDateConverter() required TradeDate tradeDate,
    required RebalanceKind kind, // 🔴 ui 미참조(C-42) — 칩은 [kindLabel]
    /// 엔진 생성.
    required String kindLabel,
    required List<SleeveWeight> before,
    required List<SleeveWeight> after,

    /// 당시 국면·신호 원값·밴드 여유.
    required TriggerSnapshot trigger,
    required List<String> orderIntentIds, // 🔴 ui 미참조(C-42 · C-40 ⑧)
    /// 🆕 v1.6 뜻 고정(01 §15-4) — **읽기 모델의 관측 시각**(마지막 배치) = 목록 봉투 `as_of` 와
    /// 같은 값. 회차 시각이 아니다(회차 일자 = [tradeDate]). `S7-6b` 하단·StaleBanner 의 원천.
    required AsOf asOf,

    /// 실측 슬리피지 vs 가정치·미체결률 — m2-8 F-10. null = 패널 부재.
    ExecutionQuality? quality,

    /// 🆕 v1.6 — 사전 등록 임계 ↔ 실제값 대조(03 §11-b 수용 (a) · J-2 `DecisionDetailVm.thresholds`
    /// 와 같은 타입) · 엔진 포맷 행 · 0건 = 표 부재.
    /// 🔴 비어 있지 않음 ⇔ `trigger.thresholdRegistered != null`(C-41 ④).
    required List<ThresholdCompare> thresholds,

    /// 🆕 v1.6 — 「모의」 배지 글자. non-null ⇔ `mode != LIVE`(C-41 ④). 🔴 화면이 `mode` 로 고르지 않는다.
    String? modeLabel,

    /// 🆕 v1.6 — non-null 이면 **이 행 위에** 머리글 1줄(«모의투자 회차»). 같은 모드 묶음의 첫 행에만
    /// 엔진이 싣는다 — 화면은 앞 행과 비교하지 않는다(`ReportArchiveRow.sectionLabel` 선례).
    /// 🔴 LIVE·SIM 이 섞인 목록에서 «시간 역순»과 «모드 묶음의 첫 행»은 함께 성립하지 않는다 —
    ///    섞인 목록의 정렬 키는 §8 미결 89 · 그때까지 표본은 SIM 단독 봉투(C-41 ④ 한정 · 비평 #23).
    String? sectionLabel,

    /// 🆕 v1.5(01 §15-3 · §8 미결 49) — `S7-6b` 하단 «이 회차의 … N건» 버튼 **하나**
    /// (목적지 = `J-1` 회차 조건 · `AppRoutes.journalRebalance` 를 엔진이 완성).
    /// `label` = 엔진 완성 문장. N = 그 회차에 묶인 일지 행 **전체** 수(정정 행 포함 · 기간 무관) —
    /// 링크가 처음 여는 목록의 행 수와 같다(씨앗 기간 = `JournalRebalanceScope.range`).
    /// 낱말(자동 갈래 «주문» · advisory 갈래는 행을 가리키는 말 — 03 §11-d)도 이 글자 안에서 끝난다.
    /// 🔴 null = 버튼 **부재**(비활성 아님) — 엔진은 그 회차에 묶인 일지 행이 0 이면 null 로 준다.
    /// 🔴 화면이 `orderIntentIds.length` 로 N 을 세거나 `eventId` 로 링크를 조립하면 반려.
    LinkAction? journalTimelineLink,

    /// 🆕 v1.5(01 §15-3) — `S7-6a` 행 탭 → `S7-6b`(`AppRoutes.rebalanceEvent` 를 엔진이 완성).
    /// 🔴 null 이면 행 탭에 반응이 없다. 화면이 `eventId` 로 링크를 조립하지 않는다.
    /// `S7-6b` 안에서는 쓰지 않는다(자기 자신 — `TradeJournalEntry.detailDeepLink` 와 같은 규약).
    String? detailDeepLink,
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
    required SleeveId sleeve, // 🔴 ui 미참조(C-42 ⑧)
    required double weight, // 🔴 ui 미참조(C-42) — 표시는 [label]
    required double targetWeight, // 〃
    required double bandLow, // 〃
    required double bandHigh, // 〃
    /// "B 42.0% (목표 42.0%, 밴드 여유 1.8%p)" — 엔진 생성.
    ///
    /// 🆕 v1.6 뜻 고정(정본 = 이 타입 머리 «목표 대비 편차·밴드 여유» + 기존 예시 «B 42.0% (목표 42.0%,
    /// 밴드 여유 1.8%p)»의 요소) — 이 행의 **완성 문장**: 현재·목표·편차·밴드 여유를 엔진이 한 줄에 담고,
    /// 밴드 밖이면 여유 자리에 초과폭을 말한다(«B 42.0% (목표 42.0%, 편차 0.0%p, 밴드 여유 5.0%p)» ·
    /// «B 47.8% (목표 42.0%, 편차 +5.8%p, 밴드 상단 0.8%p 초과)»). 🔴 이름만 싣지 않는다(C-41 ④ `%`).
    /// 🔴 기존 주석 예시(:75)는 바꾸지 않는다 — 홈 블록 4 가 같은 타입이다(K11 · 비평 #13).
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
    /// 🔴 ui 미참조(C-42 · J-2 ⓒ).
    required Map<String, String> rawValues,

    /// 엔진 생성 한 줄.
    required String summary,

    /// 🔴 ui 미참조(C-42 · J-2 ⓒ).
    @DecimalStringConverter() Decimal? triggerPrice,

    /// 🔴 사전 등록 임계값 — 사후 변경 감사용.
    /// 🔴 ui 미참조(C-42 · J-2 ⓒ) — 표시는 `RebalanceEvent.thresholds`(v1.6).
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
    /// 🆕 v1.6 nullable — null ⇔ [emptyLabel] non-null(C-41 ③). 엔진 생성 · 화면이 날짜를 빼지 않는다.
    String? expectedDateText,
    String? dDayText,

    /// non-null = «예정 없음» — 화면은 이 문장**만** 그린다(카운트다운·초안 버튼 부재).
    String? emptyLabel,
    RebalanceKind? expectedKind, // 🔴 ui 미참조(C-42)
    String? kindLabel, // null = 줄 부재
    /// 🔴 `S7-6c` 안에서 쓰지 않는다(자기 자신 · `H-02`·알림 행 몫) · non-null 이면 `AppRoutes.rebalancePreview`.
    String? previewRoute,
    String? noticeText, // null = 줄 부재
    /// 🆕 v1.6 — 봉투 as_of 를 행으로(`DepositPlan.asOf` 선례 · `H-02` 도 같은 필드).
    required AsOf asOf,
  }) = _NextRebalanceVm;

  factory NextRebalanceVm.fromJson(Map<String, dynamic> json) =>
      _$NextRebalanceVmFromJson(json);
}
