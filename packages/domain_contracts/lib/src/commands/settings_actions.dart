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
/// 🔴 **`Config.fx_overlay` 계열 키를 `strategyPreview`·`strategyApplyRequest` 의 args 에
///    넣지 않는다** — 영구 기각된 규칙의 부활 경로다(P 회차 실측: 반사실 부호 역전).
///
/// ⚠️ 나머지 동작의 args 스키마는 **미확정**이다(§4-3 말미 · 05 §7 표가 입력) — 확정 전에는
///    화면이 키를 지어내지 않는다.
abstract interface class SettingsActions {
  /// ⚠️ 01 §4-3 원문은 `{Map<String, String> args}` 이지만 Dart 에서 non-nullable 선택
  ///    명명 인자는 기본값 없이는 선언되지 않는다 — **의미(선택·비어 있을 수 있음)를 지키는
  ///    최소 보정**으로 `const {}` 기본값을 둔다. 타입·이름은 원문 그대로다.
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  });

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
