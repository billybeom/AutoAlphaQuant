// 01 §4-3 · §5-5 — 설정·진단 «동작». ⚠️ `CommandApi` 가 아니다.
//
// 🔴 M9 의 «적용»·«검증»·«백업»·«셀프테스트»와 M8 온보딩의 «검증 드라이런 실행»은 Supabase
//    명령 테이블을 거치지 않는다 — **폰 로컬에서 Claude 소유 구현체가 직접 수행**한다
//    (시크릿이 관여하므로 뷰어에 경로가 있어서는 안 된다).
// 🔴 **폰(operator) 빌드에만 구현체가 주입된다.** 뷰어 빌드에서는 `null` 이고 그때 화면은
//    컨트롤을 **렌더하지 않는다**(«비활성»이 아니라 **부재** — 05 §5-2).
// 🔴 **«동작»만이다**(G-29) — 상태 구독은 `OpsStatusRepository`·`OpsSummaryRepository` 다.
//    화면이 `run()` 을 폴링해 상태를 만들면 경계 규칙 ① 위반이다.
// 🔴 «적용»류는 **`run()` 1회 + `handoffRoute` 이동**으로 끝난다. 냉각 30일·12월 창·48h
//    대기·체크리스트 7항 UI 를 화면이 만들면 반려다.
// 🆕 v1.16(01 §25) — 온보딩 args 화이트리스트(`onboardingOperatingModeSelect` · `onboardingDryRunStart` · 검증 3) ·
//    O-00b·O-03·O-04 는 결과를 읽는다.
// 🆕 v1.18(01 §27) — M9 `S07` args 화이트리스트(`connectionTest`·`connectionSyncNow` = `{target}` ·
//    `notifyChannelSelect` = `{channel}`) · S07 은 결과를 읽는다(`SettingsResultCodes`).
// 🆕 v1.19(01 §28) — M9 `S05` args 화이트리스트(전환 2 · 엔진 시작·중지 · 승격) · S05 는 결과를 읽는다.
// 🆕 v1.20(01 §29) — M9 `S02`·`S06`·`S03` args 화이트리스트(검증 1단 · 발급 · 폐기 · 매핑 · 전체 검증) · 🔴 시크릿 값 args 0.
// 🆕 v1.22(01 §31 · K56) — `M5-11` simToAuto 위저드 args 화이트리스트(handover +3 · 확정 = 기존 `handoverCommit`).
// 🆕 v1.23(01 §32 · K77) — M9 `S13` 월 납입 = 원문 제출 DTO `ContributionUpdateSubmission` + `runContributionUpdate`(표면 run·runContributionUpdate·watch 셋 — C-7) · `run` 화이트리스트 밖.
// 🆕 v1.24(01 §33 · K120) — M9 `S09`·`S10` args 화이트리스트(`backupRunNow`·`selftestGoldenRun`·`selftestIntegrityRun` = `{}`) · `backupRestoreStart` = 화면 미호출 · 두 화면은 결과를 읽는다.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';
import '../enums/ui.dart';

part 'settings_actions.freezed.dart';
part 'settings_actions.g.dart';

/// 설정·진단 동작의 주입 콜백.
///
/// 🔴 **`args` 는 화이트리스트다** — 「무엇을 뺄까」가 아니라 「무엇만 넣을까」로 정의한다.
///    키는 **snake_case** 다(H-7 — `Map<String, String>` 이므로 Dart 관례가 아니라 전송 규약을 따른다):
///
///    · `handoverAdoptionSet`      = `{handover_session_id, symbol, disposition ∈ {ADOPT, EXTERNAL}}`
///    · `handoverExternalRegister` = `{handover_session_id, symbol, quantity, account_alias,
///                                     action ∈ {REGISTER, RELEASE}}`
///    · `handoverCommit`           = `{handover_session_id}`
///
///    🔴 `handover_session_id` 는 세 동작 모두 **필수**이고 그 토큰의 정의처는 §6-6
///    `handover_session` 이다(G-02). 🔴 세 동작 모두 `decision_log(kind='MANUAL')` 1행을
///    **엔진이** 낳으며, 그 세 갈래는 재량 예산·이탈 집계의 모집단이 **아니다**(§10-3).
///
///    🆕 v1.12(01 §21 · K9) — `L-3` 실사 세션(폰 로컬 · 뷰어 경로 0):
///    · `selfReportSessionStart` = `{yyyy_mm, account_alias}`(라우트 두 값 그대로 · 🔴 계좌 전체번호 금지)
///    · `selfReportSessionStop`  = `{yyyy_mm, account_alias}`
///    🔴 가림 범위 = **그 폰 한 대**(뷰어 iOS·웹은 가리지 않는다 · ✅ 발주자 2026-10-22). 화면은 [ActionResult] 를
///    읽지 않는다(갈래 = `SelfReportSession.sessionClosedText` 하나) · `dispose` 의 stop 은 `initState` 에서 잡아 둔
///    인스턴스로 부른다(`dispose` 안 `ref` 0 · C-46 ㉔).
///
///    🆕 v1.16(01 §25 · K13 · K19 · K24) — X3 온보딩(폰 로컬 · 뷰어 경로 0):
///    · `onboardingOperatingModeSelect` = `{operating_mode ∈ {AUTO_TRADE, ADVISORY}}`(값 = `OperatingMode.wire` —
///      화면이 고른 카드의 `OperatingModeOption.mode.wire` 그대로) · 결과 = 접수(`ok`) / 거부(`blocked` ·
///      `ONBOARDING_CHOICE_COMMITTED` · `committed_at` 뒤 — 이후 변경 = `runtimeOperatingModeSwitchRequest` → 🔒 `M5-11`) ·
///      같은 값 재선택 = 접수(멱등)
///    · `onboardingDryRunStart`        = `{}`(O-04 ⑥ · 종착 조합은 엔진이 `onboarding_choice` 로 안다 ·
///      첫 `committed_at` 과 같은 트랜잭션 · 실패 = 둘 다 되돌림 `DRY_RUN_START_ROLLED_BACK`)
///    · 검증 동작 — `OnboardingAction` 이 id·args 를 **완성해서** 싣는다(🔴 화면은 그대로 넘긴다 · 짓지 않는다):
///      `credentialVerify` = `{kind}` · `connectionTest` = `{target}` · `accountVerifyMapping` = `{}`
///      (`kind`·`target` 값 = 엔진 표기 — 05 §7 꼴 · 값 사전 = 01 §8 미결 151)
///    🔴 `O-00b`·`O-03`·`O-04` 는 [ActionResult] 를 **읽는다** — `headline` + `reasonCode` 원문
///      (`O-03` 은 + `retryable` · `O-00b`·`O-04` 는 다시 시도 갈래가 없다 — 표본 `retryable` 전부 false)
///      (표본 = `m8/onboarding_mode_select_results` · `m8/onboarding_verify_results` · `m8/onboarding_finish_results`).
///      `level`·`handoffRoute`·`actionRunId` 로 화면이 분기하지 않는다(아이콘 = `level` 5값 전수).
///
///    🆕 v1.18(01 §27 · K-r · K-s · K-u) — M9 `S07`(폰 로컬 · 운영 등급 · 뷰어 경로 0):
///    · `connectionTest`·`connectionSyncNow` = `{target ∈ ConnectionTargetCodes}`(엔진이 `ConnectionRow.actions` 에 완성 —
///      값 = 그 행의 `target` · 🔴 화면은 그대로 넘긴다 · 01 §8 미결 151 의 `target` 몫 해소)
///    · `notifyChannelSelect` = `{channel ∈ NotifyChannelCodes}`(`NotifyChannelOption.selectAction`)
///    🔴 `S07` 은 [ActionResult] 를 읽는다 — `headline` + `reasonCode` 원문(`SettingsResultCodes`) · `retryable` 전부 false
///      (버튼 = 행 `actions` 뿐 · 05 «재시도 무한 버튼 0») · `handoffRoute` null(표본 = `m9/settings_action_results`).
///    🆕 v1.19(01 §28 · K6 · K7 · K16) — M9 `S05`(폰 로컬 · 운영 등급 · 뷰어 경로 0 · 엔진이 `SettingsActionCall` 에 완성):
///    · `runtimeModeSwitchRequest`          = `{run_mode ∈ RunMode.wire}`(`RunModeCard.switchActions` · 실전 전환 =
///      `handoffRoute` `m5HandoverWizard`(K-h) · advisory 안내 개시 = `m5HandoverGate` — 목적지 = 엔진)
///    · `runtimeOperatingModeSwitchRequest` = `{operating_mode ∈ OperatingMode.wire}`(`OperatingModeView.switchActions` ·
///      값 ≠ 지금 `current` · 목적지 `M5-10`/`M5-11` = 엔진)
///    · `runtimeEngineStart`                = `{}`(`EngineControl.startAction` · 기동 거부 = `reasonCode` ∈ `ModeStartupCodes` ∪
///      `AdviceRejectCodes.modeCombinationDenied`)
///    · `runtimeEngineStop`                 = `{reason_code ∈ EngineStopReasonCodes}`(`EngineControl.stopActions` — 사유마다 1)
///    · 🆕 `runtimeLivePromotion`           = `{}`(`RunModeCard.promotionAction` · 생체 1회 = 구현 · 결과 `reasonCode` ∈
///      `LiveObservationBlockCodes` ∪ `LivePromotionResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`})
///    🔴 키 `target` 을 쓰지 않는다(C-5 `connection_target` 사전 키). `S05` 는 [ActionResult] 를 읽는다 — `headline` + `reasonCode`
///      원문 · `handoffRoute` 가 있으면 `AppLinkOpener.open(handoffRoute)` 하고 끝 · `retryable` 전부 false(버튼 = VM 의 호출뿐)
///      (표본 = `m9/operations_action_results`).
///    🆕 v1.20(01 §29 · K5 · K6 · K15 · K19 · K32 · K33) — M9 `S02`·`S06`·`S03`(폰 로컬 · 운영 등급 · 뷰어 경로 0 · 엔진이 `SettingsActionCall` 에 완성):
///    · `credentialVerify`          = `{kind ∈ CredentialKindCodes}`(`CredentialCardVm.verifyAction` · 🔴 1단 — 통과 = 구현이 Keystore 에 저장 ·
///      값은 슬롯 위젯 ↔ 이 구현 사이(조립 앱 내부)로만 · args·VM·결과 어디에도 0) · 거절 = `CREDENTIAL_REJECTED`(온보딩 한 벌) ·
///      다른 환경 키 = `WRONG_KEY_SET` · 생체 = `BIOMETRIC_UNAVAILABLE`
///    · `credentialRegister`        = 🔴 화면 미호출(1단 · 조립·엔진 내부 — 회전 마법사 `M4-4` 등 · args 미정 유지)
///    · `devicePairingTicketCreate` = `{}`(`PairingTicketCard.issueAction` · 티켓·QR = VM 스트림 + 슬롯 — 결과에 페이로드 0)
///    · `deviceTokenRevoke`         = `{device_id}`(`DeviceRow.revokeAction` · 값 = 그 행 `deviceId` — 🔴 화면은 읽지 않는다 ·
///      중복 = `DEVICE_ALREADY_REVOKED`)
///    · `accountMapSleeve`          = `{sleeve ∈ {A, B, C}, account_alias}`(`AccountMappingOption.selectAction` · 🔴 계좌번호 키 0 · 엔진이 안에서
///      드라이런 + SAF-309 재확인 뒤 원자 저장 · 거부 = `Saf309Codes` · `MAPPING_VERIFY_FAILED`)
///    · `accountVerifyMapping`      = `{}`(v1.16 그대로 · `AccountMappingVm.verifyAction` = 전체 검증)
///    🔴 R7 세 화면은 [ActionResult] 의 `headline` + `reasonCode` 원문만 읽는다 — `handoffRoute`·`retryable` 미참조(표본 null·false ·
///      다시 시도 = VM 의 같은 버튼)(표본 = `m9/credential_action_results` · `m9/device_action_results` · `m9/account_mapping_action_results`).
///    🆕 v1.23(01 §32 · K77) — `settingsContributionUpdate` = **제출 경로**(`runContributionUpdate(ContributionUpdateSubmission)`) ·
///      🔴 `run` 화이트리스트 **밖**(사람이 친 금액 = 원문 제출 DTO — K7 이 표면 고정을 이긴다 · v1.22 K52 선례 · `run(settingsContributionUpdate)`
///      = 구현 `ArgumentError`) · 결과 id = 늘 `settingsContributionUpdate` · `reasonCode` ∈ `ContributionResultCodes` ∪
///      {`TRUSTED_TIME_UNKNOWN`, `BIOMETRIC_UNAVAILABLE`} ∪ null(접수) · `handoffRoute` null · `retryable` false
///      (표본 = `m9/contribution_action_results`) · R9 동작 = 🆕 v1.24(아래).
///    🆕 v1.24(01 §33 · K111 · K112 · K114 · K115 · K120 · K132) — M9 `S09`·`S10`(폰 로컬 · 운영 등급 · 뷰어 경로 0 · 엔진이 `SettingsActionCall` 에 완성):
///    · `backupRunNow`         = `{}`(`BackupVm.runAction` · 구현 권고 = X1 스냅숏 `take` — live 원장만 · 트랜잭션 밖 · 아카이브 `IN_SYNC` 일 때만 ·
///      결과 `reasonCode` ∈ `BackupResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`} ∪ null(접수))
///    · `backupRestoreStart`   = 🔴 화면 미호출(복원 = X1 마법사 · 새 폰 `R-01` — 같은 폰 복원 = 엔진 `X1_LIVE_EXISTS` · args 미정 유지)
///    · `selftestGoldenRun`    = `{}`(`DiagnosticsScreenVm.golden.runAction` · 실행기 = E11o — 전 = 버튼 부재 · 결과 `reasonCode` ∈
///      {`BIOMETRIC_UNAVAILABLE`} ∪ null — 통과·불일치 = `headline` 만 · 코드를 지어내지 않는다)
///    · `selftestIntegrityRun` = `{}`(`DiagnosticsScreenVm.integrity.runAction` · 구현 권고 = 정본 자가 대조(로컬 · 브로커 0) · 🔴 불일치 =
///      `LEDGER_INTEGRITY` 차단(일일 잡과 같은 fail-closed — 엔진 headline 이 말한다) · 결과 `reasonCode` ∈ `LedgerIntegrityResultCodes` ∪
///      {`BIOMETRIC_UNAVAILABLE`} ∪ null(일치))
///    🔴 두 화면은 [ActionResult] 의 `headline` + `reasonCode` 원문만 읽는다 — `handoffRoute`(늘 null)·`retryable`(늘 false)·`level` 분기 0
///      (표본 = `m9/backup_action_results` · `m9/selftest_action_results`). ⏸ `calendarSyncNow`·`calendarRebackfill`·`calendarReconnect`
///      = X4(⏸ R9d · 01 §8 미결 5 · 196) · `settingsGeneralUpdate` = S11 창(⏸ R9e · 미결 197) — args 미정 유지.
///    🆕 v1.22(01 §31 · K56) — `M5-11` simToAuto 위저드(🔒 `ui_safety` · 폰 로컬 · 뷰어 경로 0 · M9 `S05` 는 부르지 않는다):
///    · `handoverSimLedgerFate` = `{fate ∈ {KEEP, DISCARD}}`(엔진 `SimLedgerFate.wire` · 🔴 **세션 전** — 5단계는 6단계 생체(세션 열림) 앞이라
///      `handover_session_id` 를 넣지 않는다 · 결과 `reasonCode` ∈ {`SIM_LEDGER_FATE_SIM_CLOSED`, `SIM_TO_AUTO_NOT_SIM_AUTO`})
///    · `handoverSessionStart`  = `{path ∈ {SIM_TO_AUTO}}`(1.22.0 화이트리스트 = 하나 · 생체 1회 = 구현 · 결과 `reasonCode` ∈
///      `SimToAutoResultCodes` ∪ `SimToAutoStepIds` ∪ `HandoverSessionResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`})
///    · `handoverSessionCancel` = `{handover_session_id}`(결과 = 정상 · `HANDOVER_SESSION_INVALID`)
///    · `handoverCommit`(simToAuto) = 위 그대로 `{handover_session_id}` · 결과 `reasonCode` ∈ `SimToAutoCommitResultCodes` ∪ `SimToAutoResultCodes` ∪
///      `SimToAutoStepIds` ∪ {`HANDOVER_SESSION_INVALID`, `LEASE_INVALID`}(구현 = 엔진 오케스트레이터 `SimToAutoSwitchResult`)
///    🔴 위 «세 동작 모두 필수»(`handover_session_id`)는 adoption·external·commit 셋의 조문이다 — `handoverSimLedgerFate` 는 그 밖.
///    🔴 결과 문구 = 엔진 `headline`(확정 성공 문장 = 금액을 품는다 → 표본 0) · 🆕 v1.26 위저드 읽기 창구·VM = `HandoverRepository.watchWizard` · `HandoverWizardVm`(01 §35 · K167~K169 · 미결 187 닫음 · 단계별 허용 id = 행 머리).
///
/// 🔴 **`Config.fx_overlay` 계열 키를 `strategyPreview`·`strategyApplyRequest` 의 args 에
///    넣지 않는다** — 영구 기각된 규칙의 부활 경로다(P 회차 실측: 반사실 부호 역전).
///
/// ⚠️ 나머지 동작(🆕 v1.24 기준 = `strategyPreview`·`strategyApplyRequest`(S04 창) · `credentialRegister`·`backupRestoreStart`(화면 미호출) ·
///    calendar 3 · `settingsGeneralUpdate`)의 args 스키마는 **미확정**이다(§4-3 말미 · 05 §7 표가 입력) — 확정 전에는
///    화면이 키를 지어내지 않는다.
abstract interface class SettingsActions {
  /// ⚠️ 01 §4-3 원문은 `{Map<String, String> args}` 이지만 Dart 에서 non-nullable 선택
  ///    명명 인자는 기본값 없이는 선언되지 않는다 — **의미(선택·비어 있을 수 있음)를 지키는
  ///    최소 보정**으로 `const {}` 기본값을 둔다. 타입·이름은 원문 그대로다.
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  });

  /// 🆕 v1.23(01 §32 · K77) — M9 `S13` 월 납입 운영값 변경(운영 등급 · 생체 = 구현). 🔴 화면은 입력칸 글자를 **원문 그대로** 싣는다
  ///    (손질·파싱·범위 판정·버튼 비활성 0 · 빈칸·0 도 보낸다) · `actionRunId`·기기 id·신뢰 시각 = 구현.
  ///    🔴 E11k(신뢰 시각) 전에는 형식이 맞는 입력 전부 `TRUSTED_TIME_UNKNOWN`(fail-closed · K98).
  Future<ActionResult> runContributionUpdate(
    ContributionUpdateSubmission submission,
  );

  Stream<ActionResult> watch(String actionRunId);
}

/// 동작 1회의 결과.
@freezed
abstract class ActionResult with _$ActionResult {
  const factory ActionResult({
    required String actionRunId,
    required SettingsActionId id,
    required UiLevel level,

    /// 결과 문구 — 🔴 엔진 생성(요약·의역 금지).
    /// 🔴 월 납입 범위 판정 같은 «허용/불허»도 이 문장과 `reasonCode` 로만 돌아온다 —
    ///    화면이 범위를 미리 알면 「저장 버튼 비활성」이라는 **화면의 판정**이 생긴다(§2-6).
    required String headline,

    /// 원문 코드(예 `'EGW00133'`)가 있으면 함께 온다.
    /// 🆕 v1.16 — 값 = 사전 등재 코드(`OnboardingResultCodes` · `BrokerRawCodes` 등 · C-5) · 화면은 글자 그대로(분기 0).
    String? reasonCode,

    /// 🔴 게이트가 필요한 동작은 여기로 넘긴다(M5).
    /// ⏸ H-9 — 반환값은 M5·X1·X2·X5 라우트 **권고 확정 목록에 있는 이름만**이며 화면이
    ///    이름을 지어 쓰지 않는다.
    String? handoffRoute,
    required bool retryable,
  }) = _ActionResult;

  factory ActionResult.fromJson(Map<String, dynamic> json) =>
      _$ActionResultFromJson(json);
}

/// 🆕 v1.23(01 §32 · K77 · K103) — M9 `S13` 월 납입 변경 «화면 제출»(core `decideContributionChange(amountInput …)` :304 ·
/// ds `ContributionSettingSource.change({amountInput, actionRunId})` :119 의 사람 몫 1 칸).
/// 🔴 [amountInput] = 입력칸 글자 **원문 그대로**(콤마·공백·빈칸·음수·글자 포함 가능 — 판정 = 엔진 차례 빈칸 → 음수 → 숫자 아님 →
///    상한 → 신뢰 시각 → 시계 전진 → 같은 값) · `actionRunId`(재생 멱등 = 같은 회차만)·기기 id·신뢰 시각 = 구현이 붙인다(화면 생성 0).
@freezed
abstract class ContributionUpdateSubmission
    with _$ContributionUpdateSubmission {
  const factory ContributionUpdateSubmission({required String amountInput}) =
      _ContributionUpdateSubmission;

  factory ContributionUpdateSubmission.fromJson(Map<String, dynamic> json) =>
      _$ContributionUpdateSubmissionFromJson(json);
}
// JSON 키: amount_input
