// packages/domain_contracts/lib/src/dto/safety.dart
//
// 01 §2-10 «AlertItem · SafetyState · OnboardingStep» + m2-8 D-1~D-3(`KillSwitchView`·
// `AckState`·`GaugeProgress`) · C-5(`EntryRampProgress`) · C-6(`RampLevel`)
// · 인벤토리 §3-7 · §3-14(영역 B).
//
// 🔴 소유 경계는 «타입»이 아니라 «무엇을 그리는가»다(01 §2-10 표) — 상태 표시는 허용,
//    **상태를 바꾸는 경로를 만드는 것은 금지**다. §7 C-7 이 그 표대로 검사한다.
// 🔴 신뢰 시각(킬스위치 48h·냉각 30일)은 **Supabase 서버 시각**이다 — 로컬 시계로
//    카운트다운을 만들지 말고 `releaseProgress` 를 그대로 표시한다(01 §1-3).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/onboarding.dart';
import '../enums/safety.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';

part 'safety.freezed.dart';
part 'safety.g.dart';

/// 운영 램프 단계 — **OpsRamp** L0~L5(03_실행 §9 자금 투입 단계 · `ramp_state` 단일 행).
///
/// 🔴 전략 §12-⑫ 의 **EntryRamp**(초기 진입 6개월 분할)와 **다른 것**이다
///    (01 §2-6 말미 · m2-8 C-6) — 하나의 «램프 진행» 위젯으로 합치지 않는다.
/// ⚠️ 인벤토리 §2 열거형 52종 표에는 이 이름이 없고 §3-14 가 이 파일(영역 B)로
///    배정했다 — 영역 A 가 `enums/` 에 같은 이름을 만들면 통합 단계에서 한쪽을 지운다.
enum RampLevel {
  @JsonValue('L0')
  l0,
  @JsonValue('L1')
  l1,
  @JsonValue('L2')
  l2,
  @JsonValue('L3')
  l3,
  @JsonValue('L4')
  l4,
  @JsonValue('L5')
  l5,
}

/// 알림 1건(01 §2-10).
///
/// 🔴 **손익 필드 없음**(결정 8).
/// 🔴 `level` 의 표시 계층 사적 재분류 금지(결정 7c).
/// 🔴 `bodyText`(무슨 일인가)와 `actionLine`(지금 할 일)은 **분리**돼야
///    「조치가 다르면 다르게 말한다」가 지켜진다(04 §5-3).
@freezed
abstract class AlertItem with _$AlertItem {
  const factory AlertItem({
    required String alertId,
    required AlertLevel level,
    required DateTime raisedAt,

    /// 'SAF-407' · 'RESUME_INCOMPLETE' · 'WATCHDOG_LATE'
    /// (코드 목록은 영역 E 의 `labels/alert_codes.dart` 가 정본)
    required String code,
    required String title,

    /// 「무슨 일인가」 문단 — 엔진 생성
    required String bodyText,

    /// 「지금 할 일」 한 줄 — 조치가 같으면 엔진이 이미 묶었다
    required String actionLine,
    required int groupedCount,
    String? deepLink,

    /// P0 수신 확인 사다리 ⚠️ 쓰기 경로 미결(01 §8-10 · m2-8 J-3)
    AckState? ack,
  }) = _AlertItem;

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      _$AlertItemFromJson(json);
}

/// P0 수신 확인 상태(m2-8 D-2).
///
/// ⚠️ 쓰기 경로(`alertAck` 명령의 뷰어 허용 여부)는 01 §8-10 미결이다 —
///    m2-8 J-3 권고는 «허용하지 않는다»(현행 viewer 4종 화이트리스트 유지).
/// 🔴 ack 는 `SafetyState` 에 아무 효력이 없다(A5 — P0 승급 사다리 정지만).
@freezed
abstract class AckState with _$AckState {
  const factory AckState({
    required bool acked,
    DateTime? ackedAt,
    required String stateLabel,
    required int escalationStep,
  }) = _AckState;

  factory AckState.fromJson(Map<String, dynamic> json) =>
      _$AckStateFromJson(json);
}

/// 안전 상태(01 §2-10).
///
/// 🔴 **읽기 전용**이다 — 화면은 상태를 바꾸지 않는다. 킬스위치 «발동»만 01 §4-2 명령 API 다.
/// 🔴 `killSwitch`·`releaseProgress`·`stoppedReleaseEligible` **판정 UI** 는 M5 소유다.
@freezed
abstract class SafetyState with _$SafetyState {
  const factory SafetyState({
    required BreakerLevel breakerLevel,
    required String breakerLabel,
    required double drawdown,
    required List<BlockFlag> activeFlags,
    required KillSwitchView killSwitch,

    /// v2.29 STOPPED_RELEASE_ELIGIBLE
    required bool stoppedReleaseEligible,

    /// 48h 카운트다운 · dd 회복 잔여 · BULL 연속일
    required List<GaugeProgress> releaseProgress,

    /// v2.30 — 🔵 v2.31 대상 없음(문구는 엔진 판단)
    required bool alertBlockSatEntry,

    /// 🔵 OpsRamp(L0~L5) — 초기 진입 분할(EntryRamp)이 아니다(01 §2-6)
    required RampLevel rampLevel,
    required RunMode mode,
    required AsOf asOf,
  }) = _SafetyState;

  factory SafetyState.fromJson(Map<String, dynamic> json) =>
      _$SafetyStateFromJson(json);
}

/// 킬스위치 상태(m2-8 D-1).
///
/// 🔒 **M5 만 렌더**한다(결정 6). 🔴 «해제» 필드·버튼을 만들지 않는다 —
///    킬스위치 해제 명령은 계약에 존재하지 않는다(01 §4-2).
@freezed
abstract class KillSwitchView with _$KillSwitchView {
  const factory KillSwitchView({
    required bool active,
    required String stateLabel,
    DateTime? activatedAt,

    /// 🔴 기기 별칭 — 기기 식별자 원문을 화면에 싣지 않는다
    String? activatedByDeviceLabel,
    String? checklistStateLabel,

    /// "해제 가능 예정 09-10 14:00" — 엔진 생성(신뢰 시각 기준)
    String? releaseEtaText,
  }) = _KillSwitchView;

  factory KillSwitchView.fromJson(Map<String, dynamic> json) =>
      _$KillSwitchViewFromJson(json);
}

/// 진행 게이지 1칸(m2-8 D-3).
///
/// 🔴 `normalized` 는 **게이지 폭 전용**이고 표시는 `valueText` 다
///    (§2-11 `complianceRateNormalized` 와 같은 형식).
@freezed
abstract class GaugeProgress with _$GaugeProgress {
  const factory GaugeProgress({
    required String code,
    required String label,

    /// 0.0~1.0
    required double normalized,
    required String valueText,
  }) = _GaugeProgress;

  factory GaugeProgress.fromJson(Map<String, dynamic> json) =>
      _$GaugeProgressFromJson(json);
}

/// 차단 플래그 1건(01 §2-10).
///
/// 🔴 `clearInstruction` 은 **플래그마다 다른 문구**다(경보 피로 규칙) —
///    화면이 하나의 문장으로 뭉치지 않는다.
@freezed
abstract class BlockFlag with _$BlockFlag {
  const factory BlockFlag({
    /// 01 §3-5 의 12종 — 정본은 영역 E 의 `labels/flag_ids.dart`
    required String flagId,
    required String label,
    required DateTime setAt,
    required ClearRoute clearRoute,
    required String clearInstruction,
    String? originCode,
  }) = _BlockFlag;

  factory BlockFlag.fromJson(Map<String, dynamic> json) =>
      _$BlockFlagFromJson(json);
}

/// 온보딩 단계 1행 — X3(01 §2-10).
///
/// 🔴 화면이 `Duration` 을 포맷하지 않는다(01 §1-3) — 표시는 `estimatedText` 다.
@freezed
abstract class OnboardingStep with _$OnboardingStep {
  const factory OnboardingStep({
    required String stepId,
    required OnboardingTrack track,
    required int order,
    required String title,

    /// 왜 필요한가 — 엔진 생성
    required String whyLine,
    String? whereDeepLink,

    /// 정렬·집계용. JSON 키는 `*_seconds`(01 §1-2 `DurationSecondsConverter`)
    @JsonKey(name: 'estimated_seconds')
    @DurationSecondsConverter()
    required Duration estimated,

    /// "약 20분" — 엔진 생성
    required String estimatedText,
    required StepRequirement requirement,
    required StepState state,

    /// "KIS 토큰 발급 + 잔고 조회 1회" — 엔진 생성
    String? verificationLabel,

    /// 검증 유효기간(KIS 접근토큰 24h · PAT 만료일 등)
    DateTime? verifiedUntil,
    String? failureReasonCode,
  }) = _OnboardingStep;

  factory OnboardingStep.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepFromJson(json);
}

/// 초기 진입 램프(**EntryRamp**) 진행 — 슬리브별 상태 목록(m2-8 C-5).
///
/// 🔴 «n/6» **단일 게이지가 아니다** — A(계절 캘린더)·C(첫 달 즉시 배분)에 n/6 을
///    그리면 거짓 진행률이다(01 §2-6 말미).
/// 🔴 `RampLevel`(OpsRamp)과 하나의 위젯으로 합치지 않는다.
/// ⚠️ 파일 배정 주의 — 인벤토리 §3-14 «공통·안전» 행은 이 타입을 영역 B 로 두면서도
///    «앞 4 = safety.dart · 뒤 3 = resume.dart» 로만 갈라 이 타입의 파일을 남겨 두지
///    않았다. 이름·필드는 m2-8 C-5 확정본 그대로이고 **파일만 잠정**이다.
@freezed
abstract class EntryRampProgress with _$EntryRampProgress {
  const factory EntryRampProgress({
    required List<EntryRampSleeveState> sleeves,
  }) = _EntryRampProgress;

  factory EntryRampProgress.fromJson(Map<String, dynamic> json) =>
      _$EntryRampProgressFromJson(json);
}

/// 초기 진입 램프의 슬리브 1행(m2-8 C-5).
///
/// `stateCode` ∈ {`MONTHLY_SPLIT`, `COMPLETED_IMMEDIATELY`, `AWAITING_SEASONAL_GATE`}.
/// 🔴 조기 종료 여부는 엔진이 판정해 `stepLabel` 로 준다 — 화면이 한도 소진을 계산하지 않는다.
@freezed
abstract class EntryRampSleeveState with _$EntryRampSleeveState {
  const factory EntryRampSleeveState({
    required SleeveId sleeve,
    required String stateCode,
    required String stepLabel,
  }) = _EntryRampSleeveState;

  factory EntryRampSleeveState.fromJson(Map<String, dynamic> json) =>
      _$EntryRampSleeveStateFromJson(json);
}
