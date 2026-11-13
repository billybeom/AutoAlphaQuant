// 01 §3 · 🆕 계약 v1.18(01 §27 · K-n ⓗ · K-s · K-u) — M9 설정 코드 사전 3축.
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

  static const Set<String> values = <String>{
    biometricUnavailable,
    connectionTestFailed,
    syncAlreadyRunning,
  };
}
