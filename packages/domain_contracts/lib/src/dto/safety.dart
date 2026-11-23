// packages/domain_contracts/lib/src/dto/safety.dart
//
// 🆕 v1.16 — `OnboardingStep` 표시 칸 6(01 §25) · 온보딩 한 화면 VM = `onboarding.dart`.
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
import 'common.dart';

part 'safety.freezed.dart';
part 'safety.g.dart';

/// 운영 램프 단계 — **OpsRamp** L0~L5(03_실행 §9 자금 투입 단계 · `ramp_state` 단일 행).
///
/// 🔴 전략 §12-⑫ 의 **EntryRamp**(초기 진입 6개월 분할)와 **다른 것**이다
///    (01 §2-6 말미 · m2-8 C-6) — 하나의 «램프 진행» 위젯으로 합치지 않는다.
/// ⚠️ 인벤토리 §2 열거형 52종 표에는 이 이름이 없고 §3-14 가 이 파일(영역 B)로
///    배정했다 — 영역 A 가 `enums/` 에 같은 이름을 만들면 통합 단계에서 한쪽을 지운다.
/// 🆕 v1.19(01 §28 · K11) — 🔴 v1 엔진은 **L0 을 내지 않는다**(발행 집합 L1~L5 · `rampLevelOf` D19 · `ramp_state.level`
///    CHECK 1..5 · 행 없음 = L1 fail-closed) · `l0` 은 삭제하지 않는다(major) · `S05` 는 이 열거를 쓰지 않는다(`RampBoard.levelLabel`).
/// 🆕 v1.21 F3 — `safety_states` L0 행 → L1(C-55 ⑲).
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

    /// 🔴 표시용 아님 — 화면은 [raisedAtText] 만 그린다(🆕 v1.15 · 01 §24).
    required DateTime raisedAt,

    /// 'SAF-407' · 'RESUME_INCOMPLETE' · 'WATCHDOG_LATE'
    /// (코드 목록은 영역 E 의 `labels/alert_codes.dart` 가 정본)
    required String code,
    required String title,

    /// 「무슨 일인가」 문단 — 엔진 생성
    required String bodyText,

    /// 「지금 할 일」 한 줄 — 조치가 같으면 엔진이 이미 묶었다
    required String actionLine,

    /// 🔴 화면은 이 수로 글자를 만들지 않는다 — [groupedText](🆕 v1.15).
    required int groupedCount,
    String? deepLink,

    /// P0 수신 확인 사다리 ⚠️ 쓰기 경로 미결(01 §8-10 · m2-8 J-3)
    /// 🆕 v1.15(01 §24 · K14) — 🔴 P0 만 · `ADVICE_EXIT_URGENT` 엔 오지 않는다(04 §5-4 · C-49 ⑥).
    AckState? ack,

    /// 🆕 v1.15(01 §24 · K5) — 표시 시각 «10:05»(엔진 글자 · 기기 시간대).
    /// null = 부재(묶음이 시각 하나로 말할 수 없을 때 등).
    String? raisedAtText,

    /// 🆕 v1.15(K5) — 묶음 배지 «2건»(엔진 글자 · [groupedCount] ≤ 1 이면 null).
    String? groupedText,

    /// 🆕 v1.15(K9 · `AdviceItem.detailDeepLink` 선례) — `N-02` 상세 링크
    /// (`aaq://alerts/detail/<alertId>` · 엔진이 완성). null = 행 탭 없음.
    String? detailDeepLink,
  }) = _AlertItem;

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      _$AlertItemFromJson(json);
}

/// 🆕 v1.15(01 §24 · K2 · K10) — `N-01` 알림 센터 한 화면. 고정·묶음·접힘·정렬 = 엔진이 끝냈다.
///
/// 🔴 화면은 받은 차례 그대로 그린다(재분류·재정렬·재그룹·건수 집계 0) · `level` 은 아이콘·색에만.
/// 🔴 불변식(엔진 의무 · C-49 ②~⑤) — [pinned] = P0 만 · 섹션 `rows` = P1 만 · `digestRows` = P2 만 ·
///    [emptyLabel] non-null ⇔ [pinned] 0 ∧ [sections] 0 · `watchCenter(p0Only: true)` ⇒ [sections] 0.
@freezed
abstract class AlertCenterVm with _$AlertCenterVm {
  const factory AlertCenterVm({
    required AsOf asOf,

    /// 고정 P0(엔진 순서 · 🔴 P0 만 · 확인됨 포함 · 고정을 언제 푸는지 = 엔진).
    required List<AlertItem> pinned,

    /// 날짜 묶음(엔진 순서 · 최신 날 먼저). `watchCenter(p0Only: true)` 이면 빈 목록.
    required List<AlertSection> sections,

    /// 고정·묶음이 다 빌 때만 non-null(«정상 = 무소식» 엔진 문장 · 04 §5-2). 행이 있으면 null.
    String? emptyLabel,
  }) = _AlertCenterVm;

  factory AlertCenterVm.fromJson(Map<String, dynamic> json) =>
      _$AlertCenterVmFromJson(json);
}

/// 🆕 v1.15(01 §24 · K10) — 날짜 묶음 1개(머리 · 펼친 P1 행 · 접힌 P2 묶음).
///
/// 🔴 `rows ∪ digestRows` 는 비지 않는다 · [digestLabel] non-null ⇔ [digestRows] non-empty.
@freezed
abstract class AlertSection with _$AlertSection {
  const factory AlertSection({
    /// «오늘» · «2026-08-30» — 엔진 글자.
    required String headerText,

    /// 펼친 행 — 🔴 P1 만(엔진 순서).
    required List<AlertItem> rows,

    /// 접힌 묶음 머리 «P2 3건» — 엔진 글자 · [digestRows] 가 비면 null.
    String? digestLabel,

    /// 접힌 행 — 🔴 P2 만 · 펼침 여부 = 화면 표시 상태(데이터 0 · 기본 접힘).
    required List<AlertItem> digestRows,
  }) = _AlertSection;

  factory AlertSection.fromJson(Map<String, dynamic> json) =>
      _$AlertSectionFromJson(json);
}

/// 🆕 v1.15(01 §24 · K2 · K11 · 발주자 결정 ②(a)) — `N-02` 알림 상세 한 화면.
///
/// 🔴 [item] non-null XOR [missingLabel] non-null · [item] = 센터의 같은 `alertId` 객체와 같은 값(같은 엔진 산출).
@freezed
abstract class AlertDetailVm with _$AlertDetailVm {
  const factory AlertDetailVm({
    required AsOf asOf,

    /// 그 알림(센터의 같은 `alertId` 객체와 같은 값).
    AlertItem? item,

    /// 모르는·지난 id = 엔진 문장 — 🔴 스트림 에러가 아니라 값이다.
    String? missingLabel,
  }) = _AlertDetailVm;

  factory AlertDetailVm.fromJson(Map<String, dynamic> json) =>
      _$AlertDetailVmFromJson(json);
}

/// P0 수신 확인 상태(m2-8 D-2).
///
/// ⚠️ 쓰기 경로(`alertAck` 명령의 뷰어 허용 여부)는 01 §8-10 미결이다 —
///    m2-8 J-3 권고는 «허용하지 않는다»(현행 viewer 4종 화이트리스트 유지).
/// 🔴 ack 는 `SafetyState` 에 아무 효력이 없다(A5 — P0 승급 사다리 정지만).
/// 🆕 v1.15(01 §24 · K5 · K14) — P0 만 · `ADVICE_EXIT_URGENT` 엔 오지 않는다(04 §5-4) ·
///    사다리 단계 줄 = 부재(01 §8 미결 138).
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

    /// 🆕 v1.19(01 §28 · K21 · 엔진 E15b R82 W7) — 기동은 하되 배치를 멈추는 hold 사유(값 ⊆ `SafetyHoldCodes` ·
    /// 읽을 때 파생 = 엔진 `ModeStartupGate.holds`). 빈 = hold 없음. 🔴 기동 거부(`ModeStartupCodes`)는 여기 오지 않는다.
    /// 🆕 v1.35(01 §44 · K295 · 미결 219) — 🔴 **화면 미참조**(코드 축 · 표시는 [holdLabels]).
    @Default(<String>[]) List<String> holds,

    /// 🆕 v1.35(01 §44 · K295 · 미결 219 · 01 §1-5 «열거값에는 짝 Label») — hold 한 줄 문장(엔진 완성 · 예 «실전 키 검증 전 —
    /// 자동 매매 배치를 멈췄습니다»). 🔴 `holds[i]` ↔ `holdLabels[i]` **같은 차례 · 같은 길이**(C-68 ⑥) · 화면은 이 문장을
    /// 차례대로 그대로 그린다(hold 줄 한 꼴 · 색 · 아이콘을 코드로 고르지 않는다 · 빈 = 줄 없음) · 문장 사전 = 엔진 한 벌
    /// (S05 `RunModeCard.holdLabel` 과 같은 문장 — 미결 220 ⓓ).
    @Default(<String>[]) List<String> holdLabels,
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
  // 🆕 v1.21 — 재개 게이트(M5-2) 한 화면 = `KillResumeGateVm`(`safety_gate.dart`).

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
    /// 🆕 v1.21(01 §30) — 값 ∈ `GaugeCodes`(`DD_RECOVERY` · `HOLD` · `BULL_STREAK` · `COOLDOWN` · 검사 = C-55 ⑭).
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

    /// 🔴 **해제가 어떤 성격인가**(자동·원인 코드 필요·수동 경로 없음·마법사 전용)이지
    ///    이동 목적지가 아니다 — 목적지는 [clearDeepLink] 다.
    required ClearRoute clearRoute,
    required String clearInstruction,
    String? originCode,

    /// 🆕 v1.1(§8 미결 39) — "마지막 검증 09-05 18:10" · `LEDGER_INTEGRITY` 배너의
    ///    «마지막 검증 체크포인트 시각»(02 §2-2 표). 엔진 완성 문자열(01 §1-3).
    String? checkpointLabel,

    /// 🆕 v1.1(§8 미결 36) — 조치 진입점 링크(`aaq://m5/…` · `aaq://journal/draft/…` 등).
    /// 🔴 null 이면 배너에 이동 화살표·버튼이 **없다**(`LEDGER_FIX` 처럼 해제 경로가 없는 것).
    /// 🔴 화면이 `flagId`·`clearRoute` 로 목적지를 고르지 않는다(그 표가 곧 판정이다).
    String? clearDeepLink,
  }) = _BlockFlag;

  factory BlockFlag.fromJson(Map<String, dynamic> json) =>
      _$BlockFlagFromJson(json);
}

/// 온보딩 단계 1행 — X3(01 §2-10). 🆕 v1.16(01 §25 · K15) — 표시 칸 6.
///
/// 🔴 화면이 `Duration` 을 포맷하지 않는다(01 §1-3) — 표시는 `estimatedText` 다.
/// 🔴 화면 미참조 = [stepId] · [track] · [order] · [estimated] · [requirement] · [verifiedUntil] · [whereDeepLink]
///    (값으로 글자·차단·정렬·Key 를 고르지 않는다 — 글자는 `*Label`·`*Text` 칸).
@freezed
abstract class OnboardingStep with _$OnboardingStep {
  const factory OnboardingStep({
    required String stepId,
    required OnboardingTrack track,
    required int order,
    required String title,

    /// 왜 필요한가 — 엔진 생성
    required String whyLine,

    /// 🔵 v1.16(K16) — 화면 미참조(옛 뜻 = 자기 단계 링크 · «어디서 받나» = `OnboardingStepDetailVm.whereText` ·
    ///    외부 열기 = 플랫폼 · 01 §8 미결 150). 신설 표본은 null.
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

    /// 검증 유효기간(KIS 접근토큰 24h · PAT 만료일 등) — 🔵 v1.16 화면 미참조(표시 = [verifiedUntilText]).
    DateTime? verifiedUntil,
    String? failureReasonCode,

    /// 🆕 v1.16 — 등급 글자 «필수»·«권장»·«선택»(엔진). 🔴 화면은 [requirement] 로 글자·차단을 고르지 않는다.
    required String requirementLabel,

    /// 🆕 v1.16 — 권장 미통과 경고 배지(엔진 판정 · null = 부재). 🔴 차단이 아니다 — 차단 = [gate].
    String? warningLabel,

    /// 🆕 v1.16 — 만료 글자 «2026-11-30까지» · «2026-08-30에 만료됨»(엔진 · [verifiedUntil] non-null ⇒ non-null · C-50 ⑥).
    String? verifiedUntilText,

    /// 🆕 v1.16 — 실패 문장(엔진 · [failureReasonCode] 원문과 **함께** 그린다 · 요약·의역 0).
    String? failureText,

    /// 🆕 v1.16 — 단계 게이트(엔진 판정 · null = 게이트 없음 · `unknown` = 진행 차단 · 04 §9-8).
    GateBadge? gate,

    /// 🆕 v1.16 — `O-02` 링크(`aaq://onboarding/<stepId>` · 엔진 완성). null = 행 탭 없음.
    String? detailDeepLink,
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
