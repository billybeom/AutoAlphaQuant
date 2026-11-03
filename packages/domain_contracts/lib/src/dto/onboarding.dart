// packages/domain_contracts/lib/src/dto/onboarding.dart
//
// 🆕 계약 v1.16(01 §25 · R15 선행 · 발주자 결정 2026-11-03 ①~④) — X3 온보딩 위저드(04 §9) **한 화면 VM 7종** + 부품 5종.
//
// 🔴 판정·게이트·순서·문구 = 전부 엔진(04 §9 머리 «게이트 판정은 전부 Claude»). 화면은 받은 차례 그대로 그리고 null = 부재.
// 🔴 asOf 칸이 없다(K6 ⓐ · K10) — 온보딩 화면 공통 상태 = 로딩·에러 둘(04 §2-3 예외 · 01 §8 미결 148).
//    모르는 id = 값(`missingLabel`) · 스트림 에러 = 읽기 실패.
// 🔴 링크 = 데이터(01 §4-4) — 문자열 칸 = `*DeepLink` · 글자 + 링크 = [LinkAction](같은 뜻 같은 이름 · K9).
// 🔴 🔒 자리 = 슬롯 이름(`OnboardingSlotIds`)만 싣는다 — 위젯은 조립 앱이 주입한다(K22 · 06 M4-11).
// 🔴 `OperatingModeView`(M9 `S05`)는 여기서 쓰지 않는다 — `current` 가 required 라 «아직 안 고름»을 표현하지 못한다(K12).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';
import '../enums/mode.dart';
import '../enums/onboarding.dart';
import '../enums/ui.dart';
import 'common.dart';
import 'handover.dart';
import 'safety.dart';

part 'onboarding.freezed.dart';
part 'onboarding.g.dart';

/// `O-00` 첫 실행 갈래(04 §9-1 · K11). 🔴 운영 방식은 갈래가 아니다 — 넷째 갈래 0.
@freezed
abstract class OnboardingStartVm with _$OnboardingStartVm {
  const factory OnboardingStartVm({
    /// 첫 화면 머리 — 엔진 문장.
    required String headline,

    /// 계정 축 갈래(처음 · 다시) — 엔진 차례 그대로.
    required List<OnboardingTrackCard> tracks,

    /// 조회 전용 갈래 한 칸(🔵 청사진 §9-1b ⑦ 권고 선반영 · 되돌림 = 엔진이 null). null = 첫 화면에 내지 않는다.
    OnboardingTrackCard? viewerTrack,
  }) = _OnboardingStartVm;

  factory OnboardingStartVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStartVmFromJson(json);
}
// JSON 키: headline · tracks · viewer_track

/// `O-00` 갈래 카드 1장(K11).
@freezed
abstract class OnboardingTrackCard with _$OnboardingTrackCard {
  const factory OnboardingTrackCard({
    /// 엔진 표지 — 🔴 화면은 이 값으로 분기·글자·아이콘을 고르지 않는다.
    required OnboardingTrack track,

    /// «처음 시작하기» — 엔진.
    required String title,

    /// «약 60~90분» — 엔진(🔴 화면이 시간을 셈하지 않는다).
    required String estimatedText,

    /// 다음 화면(엔진 완성 · `aaq://onboarding/mode` 등). null = 탭 없음.
    String? deepLink,
  }) = _OnboardingTrackCard;

  factory OnboardingTrackCard.fromJson(Map<String, dynamic> json) =>
      _$OnboardingTrackCardFromJson(json);
}
// JSON 키: track · title · estimated_text · deep_link

/// `O-00b` 운영 방식 선택(04 §9-1b · K12). 🔴 기본값 없음 — [selected] null = 아직 안 고름.
@freezed
abstract class OnboardingModeChoiceVm with _$OnboardingModeChoiceVm {
  const factory OnboardingModeChoiceVm({
    required String headline,

    /// 카드 2장(엔진 차례 · 기존 [OperatingModeOption] — M9 `S05` 와 같은 타입). 🔴 크기·색·순서 우대 0.
    required List<OperatingModeOption> options,

    /// 고른 값(엔진이 `onboarding_choice` 에서 읽은 것). null = 아직 안 고름(진입 때 체크·포커스·«다음» 0).
    OperatingMode? selected,

    /// 하단 고정 고지 «투자 안내에서는 … 기록하지 않은 매매는 시스템이 알 수 없습니다.» — 엔진.
    required String recordGapNotice,

    /// 정직 고지 한 문단 — 엔진(🔴 기대치 숫자는 이 문장 안에만 · 화면 리터럴 0).
    required String honestyText,

    /// `O-01` 링크 — 엔진이 **고른 뒤에만** 준다(`aaq://onboarding/steps`). null = «다음» 부재.
    String? nextDeepLink,

    /// `committed_at` 뒤 읽기 전용 문장. non-null = 카드 탭 부재(이후 변경 = 🔒 `M5-11`).
    String? lockedLabel,
  }) = _OnboardingModeChoiceVm;

  factory OnboardingModeChoiceVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingModeChoiceVmFromJson(json);
}
// JSON 키: headline · options · selected · record_gap_notice · honesty_text · next_deep_link · locked_label

/// `O-01` 단계 목록(04 §9-2 · K17). 🔴 갈래 인자 0 — 엔진이 `onboarding_choice` 로 고른 목록이다.
@freezed
abstract class OnboardingStepsVm with _$OnboardingStepsVm {
  const factory OnboardingStepsVm({
    /// «1/12 완료» — 엔진(🔴 비율 계산 0).
    required String progressText,

    /// 단계 행(받은 차례 그대로).
    required List<OnboardingStep> rows,

    /// 행 0 일 때만 non-null(엔진 문장).
    String? emptyLabel,

    /// `O-04` 링크(`aaq://onboarding/finish`) — 엔진이 필수 통과·게이트를 판정한 뒤에만. null = «다음» 부재.
    String? finishDeepLink,
  }) = _OnboardingStepsVm;

  factory OnboardingStepsVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepsVmFromJson(json);
}
// JSON 키: progress_text · rows · empty_label · finish_deep_link

/// `O-02` 단계 상세 + `O-03` 검증(04 §9-3·§9-4 · K18). [step] non-null XOR [missingLabel] non-null.
@freezed
abstract class OnboardingStepDetailVm with _$OnboardingStepDetailVm {
  const factory OnboardingStepDetailVm({
    /// 그 단계(목록의 같은 `stepId` 객체와 같은 값).
    OnboardingStep? step,

    /// 모르는·지난 id = 엔진 문장(🔴 스트림 에러가 아니라 값이다).
    String? missingLabel,

    /// «어디서 받나» — 엔진 글자(🔴 결정 ② · 외부 열기 = 플랫폼 · 화면 링크 0).
    String? whereText,

    /// «어떻게 검증하나» — 엔진 글자.
    String? howText,

    /// 검증 동작(엔진이 id·args 완성). null = 버튼 부재.
    OnboardingAction? verify,

    /// 시크릿 자리 이름(`OnboardingSlotIds` · `SecretField` = 조립 앱 슬롯). null = 자리 없음.
    String? secretSlotId,
  }) = _OnboardingStepDetailVm;

  factory OnboardingStepDetailVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepDetailVmFromJson(json);
}
// JSON 키: step · missing_label · where_text · how_text · verify · secret_slot_id

/// 엔진이 완성한 `SettingsActions.run` 호출 1개(K19 · 검증 · DRY_RUN 공용).
/// 🔴 화면은 [id]·[args] 를 **그대로** 넘긴다(키·값을 짓지 않는다 · 화이트리스트 = `settings_actions.dart`).
@freezed
abstract class OnboardingAction with _$OnboardingAction {
  const factory OnboardingAction({
    required SettingsActionId id,
    required Map<String, String> args,

    /// 버튼 글자 «검증 실행» · «모의 운영 시작» — 엔진.
    required String label,
  }) = _OnboardingAction;

  factory OnboardingAction.fromJson(Map<String, dynamic> json) =>
      _$OnboardingActionFromJson(json);
}
// JSON 키: id · args · label

/// `O-04` 마무리(04 §9-5 · K23). 🔴 6단계 순서 고정 · 건너뛰기 0 · 열림 = 엔진 · 모드 선택 컨트롤 0.
@freezed
abstract class OnboardingFinishVm with _$OnboardingFinishVm {
  const factory OnboardingFinishVm({
    required String headline,

    /// 6단계(엔진 차례 · 🔴 화면이 순번으로 칸 뜻을 고르지 않는다 — 칸은 단계 객체가 싣는다).
    required List<OnboardingFinishStage> stages,

    /// DRY_RUN 시작 뒤 문장(모의투자 진입). null = 아직.
    String? doneLabel,

    /// 완료 체크(X3 배관 점검 — 판정 = 서버 · DRY_RUN 시작 전 = 빈 목록).
    required List<OnboardingFinishCheck> checks,
  }) = _OnboardingFinishVm;

  factory OnboardingFinishVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFinishVmFromJson(json);
}
// JSON 키: headline · stages · done_label · checks

/// `O-04` 한 단계(K23).
@freezed
abstract class OnboardingFinishStage with _$OnboardingFinishStage {
  const factory OnboardingFinishStage({
    required String title,
    required StepState state,

    /// 열림·잠금(엔진 판정 · `unknown` = 진행 차단). null = 게이트 없음.
    GateBadge? gate,

    /// 엔진 글자 줄(배분·금 상한(config)·`config_hash` · «통과 n/전체 n» · 복구 카드 4칸 · 램프 L1·종착 조합).
    required List<String> lines,

    /// ① 정직한 기대치 한 줄(04 §9-5 ⚠️ `expectationLine?` = 이 칸) — 값이 없으면 null(줄 0).
    String? expectationLine,

    /// 🔒 자리 이름(②~⑤ · 열린 단계만 · 닫힌·끝난 단계 = null).
    String? slotId,

    /// ⑥ 시작 상태 선언(두 갈래 · 결정 ③ · 선언 뒤 = null).
    LinkAction? link,

    /// ⑥ DRY_RUN 시작(앞 단계 미통과·선언 전 = null — 엔진 판정).
    OnboardingAction? action,
  }) = _OnboardingFinishStage;

  factory OnboardingFinishStage.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFinishStageFromJson(json);
}
// JSON 키: title · state · gate · lines · expectation_line · slot_id · link · action

/// 완료 체크 한 줄(04 §9-5 «체크리스트로 보이되 판정은 전부 서버» · 그림 20 `CHK`).
@freezed
abstract class OnboardingFinishCheck with _$OnboardingFinishCheck {
  const factory OnboardingFinishCheck({
    required String label,
    required StepState state,
  }) = _OnboardingFinishCheck;

  factory OnboardingFinishCheck.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFinishCheckFromJson(json);
}
// JSON 키: label · state

/// `R-01` 기존 계정에서 다시 시작(04 §9-6 · K26). 🔴 3)에서 역할 끝 — 분기 = 엔진이 고른 링크 · 갭 일수 판정 0.
@freezed
abstract class RestartVm with _$RestartVm {
  const factory RestartVm({
    required String headline,

    /// ① 복구 카드 로그인 자리(매직링크/OTP = 플랫폼). null = 이미 로그인.
    String? loginSlotId,

    /// ② 기기 원장 요약(구 폰 라벨 · 마지막 접속 · 리스 잔여 — 엔진 글자). null = 로그인 전(원장을 아직 못 읽음).
    List<String>? ledgerLines,

    /// 리스·기기 원장 3상(`unknown` = 진행 차단 · 엔진이 그때 [branches] 를 비운다).
    GateBadge? leaseGate,

    /// ③ 분기(엔진이 고른 목록 · 모름·로그인 전 = 빈 목록).
    required List<LinkAction> branches,

    /// 킬스위치·차단 플래그 승계 고지(🔴 «초기화» 선택지 0).
    String? inheritNotice,
  }) = _RestartVm;

  factory RestartVm.fromJson(Map<String, dynamic> json) =>
      _$RestartVmFromJson(json);
}
// JSON 키: headline · login_slot_id · ledger_lines · lease_gate · branches · inherit_notice

/// `V-01` 조회 전용 QR 페어링(04 §9-7 · K27). 🔴 스캔·클레임 = 플랫폼 · 수동 입력 대체 경로 0.
@freezed
abstract class PairingVm with _$PairingVm {
  const factory PairingVm({
    required String headline,

    /// 스캐너 자리(플랫폼 카메라 · 대기·재시도 때). null = 자리 없음(성공 뒤).
    String? scannerSlotId,

    /// 클레임 결과. null = 아직 스캔 전.
    PairingResult? result,
  }) = _PairingVm;

  factory PairingVm.fromJson(Map<String, dynamic> json) =>
      _$PairingVmFromJson(json);
}
// JSON 키: headline · scanner_slot_id · result

/// `V-01` 클레임 결과(판정 = 엔진·플랫폼 · 폐기된 토큰 = 즉시 차단).
@freezed
abstract class PairingResult with _$PairingResult {
  const factory PairingResult({
    required UiLevel level,
    required String headline,

    /// 원문 코드(`OnboardingResultCodes` 등). `OK` 밖이면 non-null.
    String? reasonCode,

    /// 다음 화면(`OK` 일 때만 · 엔진 완성). null = 부재.
    LinkAction? nextLink,
  }) = _PairingResult;

  factory PairingResult.fromJson(Map<String, dynamic> json) =>
      _$PairingResultFromJson(json);
}
// JSON 키: level · headline · reason_code · next_link
