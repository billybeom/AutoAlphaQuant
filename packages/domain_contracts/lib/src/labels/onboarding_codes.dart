// 01 §3 · 🆕 계약 v1.16(01 §25 · K21) — X3 온보딩·페어링 코드 사전 3축.
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다(labels.dart 머리) — 문구는 엔진이
//    함께 싣는다(`ActionResult.headline` · `PairingResult.headline`). 화면은 코드로 분기·아이콘·색을 고르지 않는다.

/// `ActionResult.reasonCode`·`PairingResult.reasonCode` 의 온보딩 앱 코드(도메인 `onboarding_result`).
abstract final class OnboardingResultCodes {
  /// `O-00b` 재선택 거부 — `onboarding_choice.committed_at` 뒤(`O-04` 완료 · 01 §8-23). 이후 변경 = 🔒 `M5-11`.
  static const String choiceCommitted = 'ONBOARDING_CHOICE_COMMITTED';

  /// `O-03` 검증 거절 — 다시 눌러도 같다(키를 다시 발급·입력해야 한다 · `retryable` false).
  static const String credentialRejected = 'CREDENTIAL_REJECTED';

  /// `O-04` ⑥ DRY_RUN 시작 실패 — `committed_at` 도 함께 되돌렸다(01 §8-23).
  static const String dryRunStartRolledBack = 'DRY_RUN_START_ROLLED_BACK';

  /// `V-01` 폐기된 연결 코드(M9 `S06` 이 폐기 · 즉시 차단 · 04 §9-7).
  static const String pairingTokenRevoked = 'PAIRING_TOKEN_REVOKED';

  static const Set<String> values = <String>{
    choiceCommitted,
    credentialRejected,
    dryRunStartRolledBack,
    pairingTokenRevoked,
  };
}

/// 브로커 원문 코드(도메인 `broker_raw`) — 엔진이 받은 그대로 `reasonCode` 에 싣는 외부 코드 중 **계약 표본이 쓰는 것**.
/// 🔴 전수 목록이 아니다 — 실 응답 등재는 엔진 레인이 늘린다(SPEC 02 §5-1 에러표 · 13 §8 R33 D15 · 01 §8 미결 157).
abstract final class BrokerRawCodes {
  /// KIS — 접근토큰 발급 제한(1분 1회 · 잠시 뒤 재시도 = `retryable` true).
  static const String kisTokenRateLimited = 'EGW00133';

  /// 🆕 v1.22(01 §31 · K66 · core `sim/sim_internal_broker.dart:23 · 26 · 29`) — 모의 가상 체결 브로커 거부
  /// (표본 `m6/journal_sim_broker_reject` 칩 · 축 = J-1 `ReasonChip.code`). 수량·주문 꼴이 맞지 않음.
  static const String simInvalidOrder = 'SIM_INVALID_ORDER';

  /// 🆕 v1.22 — 취소 거부 · 모르는 주문.
  static const String simOrderNotFound = 'SIM_ORDER_NOT_FOUND';

  /// 🆕 v1.22 — 취소 거부 · 이미 판정했거나 취소했다.
  static const String simCancelTooLate = 'SIM_CANCEL_TOO_LATE';

  static const Set<String> values = <String>{
    kisTokenRateLimited,
    simInvalidOrder,
    simOrderNotFound,
    simCancelTooLate,
  };
}

/// 온보딩 🔒 슬롯 이름(도메인 `onboarding_slot`) — VM 칸 `secretSlotId`·`slotId`·`loginSlotId`·`scannerSlotId` 의 값.
/// 🔴 `ui_shell` 은 이름을 해석하지 않는다 — 주입된 슬롯 빌더에 그대로 넘긴다. 이름 → 위젯 = 조립 앱(06 M4-11).
/// 🔴 더할 때 = 엔진(VM 산출)·조립 앱(빌더)이 같은 회차에 — 01 §8 미결 152.
abstract final class OnboardingSlotIds {
  /// `O-02` KIS 모의 앱키 — M4-4 `SecretField`.
  static const String secretKisMock = 'SECRET_KIS_MOCK';

  /// `O-04` ② 본인 서약문 3문장 — 🔒 M5-8(프리필 0 · 건너뛰기 0).
  static const String pledgeWrite = 'PLEDGE_WRITE';

  /// `O-04` ③ 생체 서명 — 🔒 M5.
  static const String biometricSign = 'BIOMETRIC_SIGN';

  /// `O-04` ④ 골든벡터 셀프테스트 실행 버튼 — 🔒 M9(`selftestGoldenRun` 은 위젯 안에서).
  static const String selftestRun = 'SELFTEST_RUN';

  /// `O-04` ⑤ 복구 카드 체크섬 입력 — 🔒 M9 입력 위젯(06 M4-10 · 결정 ②).
  static const String recoveryChecksum = 'RECOVERY_CHECKSUM';

  /// `R-01` ① 복구 카드 로그인 — 플랫폼(06 M4-11) · 🆕 v1.29(01 §39 · E11k T8) 방식 = 이메일 + 비밀번호(새로고침 토큰만 금고 ·
  /// 공개 가입 끔 = o_07 ④) — ~~매직링크/OTP~~ 정정.
  static const String recoveryLogin = 'RECOVERY_LOGIN';

  /// `V-01` QR 스캔·토큰 클레임 — 플랫폼(06 M4-11 · 01 §8 미결 13).
  static const String viewerQrScan = 'VIEWER_QR_SCAN';

  /// 🆕 v1.29(01 §39 · E11k-b) — `o_07` ② Supabase 연결 값 붙여넣기(프로젝트 주소 + 공개 키 두 칸) — 🔒 조립 앱 슬롯(06 M4-11 ·
  /// `secretSlotId` 자리 = `SECRET_` 접두 · C-50 ⑮).
  /// 🔴 값 = 슬롯 ↔ `connectionTest{target: SUPABASE}` 구현 사이만(VM · args · 결과 · 로그 0) · 비밀 키 · service_role = 거부
  ///    (`SupabaseInputResultCodes`) · 통과 = 서버 시각 1회 확인 뒤 금고(`supabase.project_url` · `supabase.publishable_key`).
  static const String supabaseConnect = 'SECRET_SUPABASE_CONNECT';

  static const Set<String> values = <String>{
    secretKisMock,
    pledgeWrite,
    biometricSign,
    selftestRun,
    recoveryChecksum,
    recoveryLogin,
    viewerQrScan,
    supabaseConnect,
  };
}
