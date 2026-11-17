// 01 §3 · 🆕 계약 v1.18(01 §27 · K-n ⓗ · K-s · K-u) — M9 설정 코드 사전 3축.
// 🆕 계약 v1.19(01 §28 · K14 · K16) — `EngineStopReasonCodes`(S05 엔진 중지 사유 · 사람) · `SettingsResultCodes` +2.
// 🆕 계약 v1.20(01 §29 · K8 · K9 · K13 · K32) — `CredentialKindCodes`(겹침 몫 · 엔진 `KisKeySet.wire` 1:1) · `SettingsSlotIds` · `SettingsResultCodes` +3.
// 🆕 계약 v1.23(01 §32 · K80) — `ContributionResultCodes`(S13 월 납입 거부 · 엔진 `ContributionRejectCodes` 7 − 공용 1).
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다(labels.dart 머리) — 문구는 엔진이 함께 싣는다
//    (`ConnectionRow.label` · `NotifyChannelOption.label` · `ActionResult.headline`). 화면은 코드로 분기·아이콘·색을 고르지 않는다.

/// `ConnectionRow.target` · `connectionTest`·`connectionSyncNow` args `target` 의 값(도메인 `connection_target` · 01 §8 미결 151).
abstract final class ConnectionTargetCodes {
  /// Supabase 미러(읽기 모델 push · 무료 티어 일시정지 경고).
  static const String supabase = 'SUPABASE';

  /// GitHub 아카이브(운영 이력 · `sim/` · PAT = 만료일만).
  static const String githubArchive = 'GITHUB_ARCHIVE';

  /// 알림 채널(텔레그램/카카오톡 — 선택 = `ConnectionRow.channelPicker`).
  static const String notifyChannel = 'NOTIFY_CHANNEL';

  /// healthchecks.io 생존 신호(목록 = `W-01` · 행 = 요약 1 + `opsWatchdog` 링크).
  static const String healthchecks = 'HEALTHCHECKS';

  /// 구글 캘린더(X4 · `calendarEnabled == false` 면 행 0 · 상세 = `S08`).
  static const String calendar = 'CALENDAR';

  /// 증권사(KIS) 연결 — `m8/incident_token_expired` 행 · 키 관리 = `S02`.
  static const String brokerKis = 'BROKER_KIS';

  static const Set<String> values = <String>{
    supabase,
    githubArchive,
    notifyChannel,
    healthchecks,
    calendar,
    brokerKis,
  };
}

/// `NotifyChannelOption.code` · `notifyChannelSelect` args `channel` 의 값(도메인 `notify_channel`).
abstract final class NotifyChannelCodes {
  /// 텔레그램 — 원격 `/stop` 가능.
  static const String telegram = 'TELEGRAM';

  /// 카카오톡 «나에게 보내기» — 발신 전용(원격 정지 불가 · 토큰 주기 만료).
  static const String kakao = 'KAKAO';

  static const Set<String> values = <String>{telegram, kakao};
}

/// M9 `ActionResult.reasonCode` 의 앱 코드(도메인 `settings_result`). 🔴 전수 아님 — 뒤 카드(R6c~R9)가 늘린다.
abstract final class SettingsResultCodes {
  /// 운영 등급 동작 거부 — 생체 실패·미등록·세션 만료(`blocked` · 다시 들어와 인증).
  static const String biometricUnavailable = 'BIOMETRIC_UNAVAILABLE';

  /// 연결 테스트 실패 — 원인 = `headline`(엔진 문장).
  static const String connectionTestFailed = 'CONNECTION_TEST_FAILED';

  /// 지금 동기화 중복 요청 — 이미 도는 중(멱등 접수 · `info`).
  static const String syncAlreadyRunning = 'SYNC_ALREADY_RUNNING';

  /// 🆕 v1.19(01 §28 · K16) — 엔진 시작 중복 요청(이미 돌고 있음 · 멱등 접수 · `info`).
  static const String engineAlreadyRunning = 'ENGINE_ALREADY_RUNNING';

  /// 🆕 v1.19(01 §28 · K16) — 엔진 중지 중복 요청(이미 멈춰 있음 · 멱등 접수 · `info`).
  static const String engineAlreadyStopped = 'ENGINE_ALREADY_STOPPED';

  /// 🆕 v1.20(01 §29 · K13) — 다른 환경의 키(모의 칸에 실전 키 등 · 엔진 `KisGuardError`) — 저장하지 않았다(`act`).
  /// 🔴 기동 거부 `ModeStartupCodes.credentialEnvMismatch`(저장된 키 ↔ 지금 모드)와 다른 뜻.
  static const String wrongKeySet = 'WRONG_KEY_SET';

  /// 🆕 v1.20(K13) — 잔고 드라이런 실패로 매핑을 바꾸지 않았거나 전체 검증을 마치지 못했다(`act`).
  static const String mappingVerifyFailed = 'MAPPING_VERIFY_FAILED';

  /// 🆕 v1.20(K13) — 이미 폐기된 기기의 폐기 요청(멱등 접수 · `info`).
  static const String deviceAlreadyRevoked = 'DEVICE_ALREADY_REVOKED';

  // 🔴 S02 검증 거절 = `OnboardingResultCodes.credentialRejected` 한 벌(K32 — `CREDENTIAL_VERIFY_FAILED` · `CREDENTIAL_NOT_VERIFIED` 0).
  static const Set<String> values = <String>{
    biometricUnavailable,
    connectionTestFailed,
    syncAlreadyRunning,
    engineAlreadyRunning,
    engineAlreadyStopped,
    wrongKeySet,
    mappingVerifyFailed,
    deviceAlreadyRevoked,
  };
}

/// 🆕 v1.19(01 §28 · K14) — `runtimeEngineStop` args `reason_code` 의 값(도메인 `engine_stop_reason` · 사람이 고르는 사유).
/// 🔵 잠정 2 — 값 확정 = 엔진 SPEC 판(01 §8 미결 173 · 추가 = 추가형 minor).
/// 🔴 «시장이 불안해서» 류 사유를 넣지 않는다(시장 판단 중지 = 재량 개입 — 킬스위치·개입 경로) · 기기 이전 = X1 마법사(두 길 0).
/// 🔴 엔진이 기동을 거부한 사유는 이 사전이 아니다 — `ModeStartupCodes`(labels/sim_codes.dart).
abstract final class EngineStopReasonCodes {
  /// 계획 점검(앱·OS 업데이트 · 기기 손질).
  static const String plannedMaintenance = 'PLANNED_MAINTENANCE';

  /// 이상 조사(알림·잡·연결이 이상해 원인을 볼 동안).
  static const String troubleshooting = 'TROUBLESHOOTING';

  static const Set<String> values = <String>{
    plannedMaintenance,
    troubleshooting,
  };
}

/// 🆕 v1.20(01 §29 · K8 · 01 §8 미결 151 ✅) — 증권사 KIS 키 세트 종류(도메인 `credential_kind`) —
/// `CredentialCardVm.kind` · `credentialVerify` args `kind` 의 값.
/// 🔴 엔진 `broker_gateway` `KisKeySet.wire` 와 **같은 글자**다(실물 = `paper('KIS_PAPER')` · 나머지 3 = 엔진이 이 사전을 보고 더한다 —
///    `kis_credential_vault.dart:8` «계약 창(R7) 뒤» · 06 변경 이력 «2026-11-15 · 계약 v1.20»).
/// 🔴 `SECRET_KIS_MOCK`(슬롯 이름)은 이 사전의 값이 아니다 — 자리 이름과 키 세트는 다른 축(v1.16 표본 `KIS_MOCK` = v1.20 에서 `KIS_PAPER` 로 정정).
/// 🔴 화면은 이 값으로 분기·아이콘·색을 고르지 않는다(카드 글자 = `kindLabel` · 색 = `level`).
abstract final class CredentialKindCodes {
  /// 실전 종합계좌(위탁 01 + 연금저축 22 공유) — 주문·조회.
  static const String kisLive = 'KIS_LIVE';

  /// ISA 중개형 전용 종합계좌.
  static const String kisIsa = 'KIS_ISA';

  /// 모의투자(SIM 계열 · 내부 시뮬레이터도 시세는 이 키 — 01 §9-5 ②).
  static const String kisPaper = 'KIS_PAPER';

  /// X7 대사 전용(`CredentialUse.reconcileOnly` · 주문 경로 봉인).
  static const String kisReconcile = 'KIS_RECONCILE';

  static const Set<String> values = <String>{
    kisLive,
    kisIsa,
    kisPaper,
    kisReconcile,
  };
}

/// 🆕 v1.20(01 §29 · K9 · K15 · K31 · 01 §8 미결 152 🟡) — M9 🔒/플랫폼 슬롯 이름(도메인 `settings_slot`) —
/// `CredentialCardVm.credentialSlotId` · `PairingTicketCard.qrSlotId` 의 값.
/// 🔴 화면(`ui_settings`)은 이름을 해석하지 않는다 — 주입된 슬롯 빌더에 그대로 넘긴다. 이름 → 위젯 = 조립 앱(06 `M4-12` ⑦).
/// 🔴 모의 키 카드 = `OnboardingSlotIds.secretKisMock` 재사용(같은 금고 칸 = 같은 자리 · 05 §4-1 «두 벌 금지») — 두 번째 이름을 만들지 않는다.
/// 🔴 세 슬롯 사전(`onboarding_slot` · `ops_slot` · `settings_slot`) 값 겹침 0(C-54 ④).
abstract final class SettingsSlotIds {
  /// `S02` 실전 키 입력 — 06 `M4-4` `SecretField`.
  static const String secretKisLive = 'SECRET_KIS_LIVE';

  /// `S02` ISA 키 입력 — 같은 위젯.
  static const String secretKisIsa = 'SECRET_KIS_ISA';

  /// `S02` 대사 전용 키 입력 — 같은 위젯(X7).
  static const String secretKisReconcile = 'SECRET_KIS_RECONCILE';

  /// `S06` viewer 페어링 QR 표시 — 플랫폼(QR 그리기 · 페이로드는 위젯 안에서만 · `VIEWER_QR_SCAN` 의 짝).
  static const String pairingQrDisplay = 'PAIRING_QR_DISPLAY';

  static const Set<String> values = <String>{
    secretKisLive,
    secretKisIsa,
    secretKisReconcile,
    pairingQrDisplay,
  };
}

/// 🆕 v1.23(01 §32 · K80 · v1.21 K45) — M9 `S13` 월 납입 변경 거부(도메인 `contribution_result` · 엔진 core
/// `ops/contribution_setting.dart:241` `ContributionRejectCodes` 7 − 공용 `TRUSTED_TIME_UNKNOWN`(`SafetyCommonResultCodes` 한 벌)).
/// 🔴 타입 이름 ≠ 엔진 — 같으면 core `test/contribution_setting_test.dart` · ds `test/operating_param_store_test.dart` 가 두 배럴을
///    `hide BreakerLevel` 만 붙여 함께 import 해 `ambiguous_import`(v1.21 K33 · v1.22 K49 결) · 엔진이 계약 참조로 옮길 때 지역 선언을 지운다.
/// 🔴 엔진 판정 차례 = 빈칸 → 음수 → 숫자 아님 → 상한 → (신뢰 시각 = 공용) → 시계 전진 → 같은 값(`decideContributionChange` :304).
///    화면은 이 값으로 분기·아이콘·색을 고르지 않는다(결과 줄 = `headline` + `reasonCode` 원문).
abstract final class ContributionResultCodes {
  /// 빈칸.
  static const String blank = 'CONTRIBUTION_INPUT_BLANK';

  /// 음수.
  static const String negative = 'CONTRIBUTION_INPUT_NEGATIVE';

  /// 원 단위 숫자 아님(콤마·앞뒤 공백은 엔진이 지운 뒤 판정).
  static const String notNumber = 'CONTRIBUTION_INPUT_NOT_NUMBER';

  /// 상한 초과(상한 = 엔진 config `maxAmount` · 숫자 = 발주자 대기 05 §8-16).
  static const String overMax = 'CONTRIBUTION_INPUT_OVER_MAX';

  /// 신뢰 시각이 마지막 기록보다 앞서지 않음(같은 순간 · 되감김).
  static const String clockNotAdvanced = 'CONTRIBUTION_CLOCK_NOT_ADVANCED';

  /// 바뀌는 게 없음(가장 최근에 접수된 값 — 예정 포함 — 과 같다).
  static const String unchanged = 'CONTRIBUTION_UNCHANGED';

  static const Set<String> values = <String>{
    blank,
    negative,
    notNumber,
    overMax,
    clockNotAdvanced,
    unchanged,
  };
}
