// packages/domain_contracts/lib/src/dto/common.dart
//
// 01 §2-1 «공통 값 객체» · 인벤토리 §3-1(영역 B).
// 사유 칩 · 결정 체인 참조 · 게이트 배지 · 피처 플래그 · 슬리브 카탈로그 ·
// 🆕 v1.6 임계값 대조 1행(`ThresholdCompare` — `journal.dart` 에서 이동 · 01 §15-4).
//
// 🔴 문구(`label`)는 전부 **엔진 생성**이다(01 §1-5) — 화면이 코드→문구 매핑을
//    만들면 §7 C-5 가 빌드를 깨뜨린다.
// 🔴 계산 getter 0건(01 §1-4).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';

part 'common.freezed.dart';
part 'common.g.dart';

/// 사유 칩 — 진입 사유·청산 티어·거부 사유의 표시 단위(01 §2-1).
///
/// 🔴 `label` 은 엔진 생성이며 화면은 조립하지 않는다.
@freezed
abstract class ReasonChip with _$ReasonChip {
  const factory ReasonChip({
    /// 'TIER_1B' · 'SAF309_ACCOUNT_UNVERIFIED' · 'REBALANCE_BAND' (코드 목록은 영역 E 의 사전이 정본)
    required String code,

    /// "TIER 1B 절대손절 −7.0% 도달" — 엔진 생성
    required String label,
    required ChipTone tone,

    /// M8 핸드북 앵커 'handbook://exit/tier1b'
    String? detailDeepLink,
  }) = _ReasonChip;

  factory ReasonChip.fromJson(Map<String, dynamic> json) =>
      _$ReasonChipFromJson(json);
}

/// 🆕 v1.1 — 엔진이 준 «이동 버튼 1개»(01 §4-4 내비게이션 계약).
///
/// 🔴 버튼 문구(`label`)도 목적지(`deepLink`)도 엔진이 준다. 화면은 이 객체가 **null 이면
///    버튼을 그리지 않고**(비활성 아님) non-null 이면 `label` 을 찍고 탭에서
///    `AppLinkOpener.open(deepLink)` 를 부른다 — 그것이 전부다.
@freezed
abstract class LinkAction with _$LinkAction {
  const factory LinkAction({
    /// "이 회차 보기" · "원행 보기" · "저널 작성" — 엔진 생성
    required String label,

    /// `aaq://…` 또는 `handbook://…` — 화면은 해석하지 않는다.
    required String deepLink,
  }) = _LinkAction;

  factory LinkAction.fromJson(Map<String, dynamic> json) =>
      _$LinkActionFromJson(json);
}

/// 결정 체인 참조 — 매매일지 상세의 뼈대(01 §2-1).
@freezed
abstract class DecisionRef with _$DecisionRef {
  const factory DecisionRef({
    required String decisionId,

    /// X2 재판정 child 의 원행
    String? parentDecisionId,
    String? intentId,
    String? brokerOrderNo,
    String? executionId,
    required String configHash,
  }) = _DecisionRef;

  factory DecisionRef.fromJson(Map<String, dynamic> json) =>
      _$DecisionRefFromJson(json);
}

/// 국면·진입 게이트 배지(01 §2-1).
///
/// 🔴 `GateState.unknown` 은 `notApplicable` 과 다르다 — «모름»이며 진행 차단이다(04 §9-8).
@freezed
abstract class GateBadge with _$GateBadge {
  const factory GateBadge({
    required String code,
    required String label,
    required GateState state,
    String? blockedReasonCode,
  }) = _GateBadge;

  factory GateBadge.fromJson(Map<String, dynamic> json) =>
      _$GateBadgeFromJson(json);
}

/// 피처 플래그(01 §2-1).
///
/// 🔴 화면이 «지금 슬리브가 3칸»을 상수로 아는 것을 막는 유일한 통로다.
/// 🔴 `ExecPolicy` 를 여기에 **넣지 않는다**(01 §10-1) — 넣는 순간 화면이 3축을 곱해 분기한다.
/// 🔴 `operatingMode` 에 기본값을 주지 않는다(m2-8 C-2 · J-1) — «온보딩 미완»은 «자동 매매»가
///    아니다(G-02). 뷰어가 명시적으로 죽는 쪽이 조용한 전제보다 낫다.
@freezed
abstract class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    /// v2.31 P0S = false. 🔵 되살아나면 목록에 행이 늘 뿐 화면은 그대로다.
    required bool satelliteEnabled,

    /// Q-D 미결(01 §8-2) — 발주자 판단까지 레이아웃 분기만
    required bool webViewerEnabled,

    /// X4 채택 미결(01 §8-5) — false 면 M9 캘린더 화면 자체가 없다
    required bool calendarEnabled,

    /// 🆕 X6(01 §9) — 모드 판정의 유일한 통로. 🔴 화면은 이 값으로 타이틀 접두를
    /// 만들지 않는다(셸이 주입 · C-17 이 강제).
    required RunMode runMode,

    /// 🆕 X7(01 §10) — `runMode` 와 대칭. 🔴 접두·띠는 셸 주입(C-18).
    required OperatingMode operatingMode,

    /// 🔴 C-13 핸드북 정합 게이트의 입력
    required String configHash,
  }) = _FeatureFlags;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsFromJson(json);
}

/// 슬리브 목록의 유일한 창구(01 §2-1).
///
/// 🔴 화면이 `SleeveId` 를 순회하며 `satellite` 를 걸러내는 코드를 쓰지 않는다 —
///    거르는 규칙이 화면에 생기면 그것이 판정이다.
@freezed
abstract class SleeveCatalogEntry with _$SleeveCatalogEntry {
  const factory SleeveCatalogEntry({
    required SleeveId sleeve,

    /// "A · KOSDAQ 지수 ETF" — 엔진 생성
    required String label,

    /// P 회차: POT → A (회계 소속, 03 §2-9-3). 화면이 아니라 엔진이 정한다.
    SleeveId? rollsUpTo,
    required int order,
  }) = _SleeveCatalogEntry;

  factory SleeveCatalogEntry.fromJson(Map<String, dynamic> json) =>
      _$SleeveCatalogEntryFromJson(json);
}

/// 임계값 대조 1행(02 §8-1 · m2-8 E-2).
///
/// 🔴 수치는 전부 **엔진 포맷 문자열**이다 — 화면이 비교식을 만들지 않는다.
/// 🆕 v1.6(01 §15-4) — `journal.dart` 에서 옮겼다(이름·필드·JSON·배럴 export 무변경). J-2
///    `DecisionDetailVm.thresholds` 와 `S7-6b` `RebalanceEvent.thresholds` 가 같은 타입을 쓴다
///    (`journal.dart` → `rebalance.dart` import 방향 때문에 순환을 피해 공통 파일에 둔다).
@freezed
abstract class ThresholdCompare with _$ThresholdCompare {
  const factory ThresholdCompare({
    required String metricKey,
    required String metricLabel,
    required String observedText,
    required String thresholdText,
    required bool passed,
    required String verdictLabel,
  }) = _ThresholdCompare;

  factory ThresholdCompare.fromJson(Map<String, dynamic> json) =>
      _$ThresholdCompareFromJson(json);
}
