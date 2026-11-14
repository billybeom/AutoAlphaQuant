// 01 §3 · 🆕 계약 v1.18(01 §27 · K-n ⓗ · K-s · K-u) — M9 설정 코드 사전 3축.
// 🆕 계약 v1.19(01 §28 · K14 · K16) — `EngineStopReasonCodes`(S05 엔진 중지 사유 · 사람) · `SettingsResultCodes` +2.
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

  static const Set<String> values = <String>{
    biometricUnavailable,
    connectionTestFailed,
    syncAlreadyRunning,
    engineAlreadyRunning,
    engineAlreadyStopped,
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
