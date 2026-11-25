// 🆕 계약 v1.29(01 §39 · K223~ · E11k-b 계약 창) — Supabase 연결(o_07 ②) · 신뢰 시각 · operator 리스의 코드 사전.
//
// 🔴 타입 이름 ≠ 엔진(data_sync `SupabaseInputProblem` · `SupabaseTimeFailure` · 🆕 v1.31 `SupabaseAuthFailure` — 같으면 엔진 시험이
//    두 배럴을 함께 import 해 `ambiguous_import` · K80). 엔진 enum 은 와이어 글자가 없다 — enum → 이 글자 매핑 = 엔진 숙제(E11k-c ·
//    01 §8 미결 213).
// 🔴 리스 무효 `LEASE_INVALID`(주문 거부 · core `kLeaseInvalidCode`)는 v1.18 `JournalReasonCodes.leaseInvalid` 한 벌 — 여기 다시 두지 않는다.
// 🔴 화면은 이 글자로 분기 · 아이콘 · 색 · 문구를 고르지 않는다 — 결과 줄 = `ActionResult.headline` + `reasonCode` 원문.
// 🔴 주소 · 키 · 토큰 값은 어떤 코드 · 결과 · 로그에도 싣지 않는다(종류만).

/// o_07 ② 연결 값 입력 문제(도메인 `supabase_input_result` · data_sync `supabase/supabase_server_time.dart` `SupabaseInputProblem` 6 1:1 ·
/// `connectionTest{target: SUPABASE}` 의 `ActionResult.reasonCode` · 🔴 망에 가기 전 판정).
abstract final class SupabaseInputResultCodes {
  /// 비었다.
  static const String empty = 'SUPABASE_INPUT_EMPTY';

  /// 빈칸 · 줄바꿈 · 따옴표가 섞였다.
  static const String whitespace = 'SUPABASE_INPUT_WHITESPACE';

  /// 프로젝트 주소 꼴(`https://<ref>.supabase.co`)이 아니다.
  static const String notProjectUrl = 'SUPABASE_URL_INVALID';

  /// 🔴 비밀 키(`sb_secret_…`)다 — 앱은 받지 않는다.
  static const String secretKey = 'SUPABASE_SECRET_KEY_REJECTED';

  /// 🔴 service_role JWT 다 — 앱은 받지 않는다.
  static const String serviceRoleKey = 'SUPABASE_SERVICE_ROLE_REJECTED';

  /// 공개 키(publishable · 옛 anon) 꼴이 아니다.
  static const String notPublishableKey = 'SUPABASE_KEY_INVALID';

  static const Set<String> values = <String>{
    empty,
    whitespace,
    notProjectUrl,
    secretKey,
    serviceRoleKey,
    notPublishableKey,
  };
}

/// 서버 시각 읽기 실패(도메인 `supabase_time_result` · data_sync `supabase/supabase_server_time.dart` `SupabaseTimeFailure` 8 1:1).
/// 🔴 o_07 ② 연결 검증(`connectionTest{target: SUPABASE}`)에서 나오는 것 = 망 다섯([unauthorized] · [server] · [badResponse] ·
///    [noDate] · [network]) · 금고 셋([notConfigured] · [badConfig] · [vault]) = 신뢰 시각 기준점(엔진 깨어남 · 앞 화면 주기)이 금고를
///    읽을 때만(연결 진단 · S07 줄 · 로그 축).
abstract final class SupabaseTimeResultCodes {
  /// 금고에 주소 · 키가 없다(o_07 ② 전) — 망에 가지 않았다.
  static const String notConfigured = 'SUPABASE_NOT_CONFIGURED';

  /// 금고 값이 꼴이 아니다 — 망에 가지 않았다.
  static const String badConfig = 'SUPABASE_CONFIG_INVALID';

  /// 금고를 읽지 못했다.
  static const String vault = 'SUPABASE_VAULT_UNREADABLE';

  /// 키가 틀렸다(401 · 403).
  static const String unauthorized = 'SUPABASE_UNAUTHORIZED';

  /// 서버 오류(5xx).
  static const String server = 'SUPABASE_SERVER_ERROR';

  /// 그 밖의 HTTP 상태.
  static const String badResponse = 'SUPABASE_BAD_RESPONSE';

  /// 2xx 인데 `Date` 머리가 없거나 읽을 수 없다.
  static const String noDate = 'SUPABASE_DATE_MISSING';

  /// 망 · 시간 초과.
  static const String network = 'SUPABASE_NETWORK';

  static const Set<String> values = <String>{
    notConfigured,
    badConfig,
    vault,
    unauthorized,
    server,
    badResponse,
    noDate,
    network,
  };
}

/// 🆕 v1.31(01 §40 · K240 · E11k-d2) — Supabase 로그인 · 세션 고유 실패(도메인 `supabase_auth_result` · data_sync
/// `supabase/supabase_auth.dart` `SupabaseAuthFailure` 12 가운데 6 · 🔴 타입 이름 ≠ 엔진).
/// 🔴 전송 6(`notConfigured` · `badConfig` · `unauthorized` · `server` · `badResponse` · `network`) = [SupabaseTimeResultCodes] 글자 한 벌
///    (같은 사건 · 새 글자 0) · 🔴 금고 = 여기 [vault](읽기 «또는 쓰기» 실패 — 시각 쪽 `SUPABASE_VAULT_UNREADABLE` 은 읽기만이라 다른 뜻).
/// 🔴 `supabaseSignIn` 결과에 나오는 것 = [badInput] · [invalidCredentials] · [rateLimited] · [vault] + 전송 · [notSignedIn] · [sessionLost] =
///    토큰 갱신 축(엔진 깨어남 · S07 · 로그).
abstract final class SupabaseAuthResultCodes {
  /// 이메일 · 비밀번호 꼴이 아니다(빈칸 등) — 망에 가지 않았다.
  static const String badInput = 'SUPABASE_AUTH_INPUT_INVALID';

  /// 로그인한 적이 없다(금고에 새로고침 토큰 없음) — 망에 가지 않았다.
  static const String notSignedIn = 'SUPABASE_NOT_SIGNED_IN';

  /// 이메일 · 비밀번호가 틀렸다(로그인 400).
  static const String invalidCredentials = 'SUPABASE_CREDENTIALS_REJECTED';

  /// 세션을 잃었다(새로고침 400 — 만료 · 재사용 · 철회) — 금고 칸을 지웠다 · 다시 로그인.
  static const String sessionLost = 'SUPABASE_SESSION_LOST';

  /// 과속(429).
  static const String rateLimited = 'SUPABASE_RATE_LIMITED';

  /// 금고를 읽거나 쓰지 못했다.
  static const String vault = 'SUPABASE_AUTH_VAULT_FAILED';

  static const Set<String> values = <String>{
    badInput,
    notSignedIn,
    invalidCredentials,
    sessionLost,
    rateLimited,
    vault,
  };
}

/// 🆕 v1.39(01 §48 · K349 ④ · 13 §8 R267 L4 · 리뷰 3차 C-2 = I-U2) — o_07 공개 가입 확인(도메인 `supabase_signup_result`).
/// 🔴 자리 = `supabaseSignIn`(o_07 ③) 로그인 통과 뒤 `GET /auth/v1/settings`(공개 키 · 인증 0) 1회 — `disable_signup == true` 만 통과.
///    열림 = [signupOpen](o_07 = VERIFIED 아님 · IN_PROGRESS 그대로 · 새로고침 토큰은 금고에 둔다 — 로그인 자체는 성공) · 읽기 실패 =
///    `SupabaseTimeResultCodes` 전송 글자 그대로(새 글자 0) · 칸 없음 · 꼴 아님 = `SUPABASE_BAD_RESPONSE`(모름 = 통과 아님).
/// 🔴 끄는 곳 = 발주자(Supabase 대시보드 «Allow new users to sign up» · 17 절차서 §3-7 · ✅ 2026-11-24) — 앱은 확인만 한다(설정 바꾸기 0).
abstract final class SupabaseSignupResultCodes {
  /// 공개 가입이 열려 있다(아무나 계정을 만들어 리스 · 읽기 모델을 넘볼 수 있다).
  static const String signupOpen = 'SUPABASE_SIGNUP_OPEN';

  static const Set<String> values = <String>{signupOpen};
}

/// 리스 RPC 거부(도메인 `lease_rpc_result` · RPC 표 = 01 §6-4 · `schema/supabase_rpc.dart` · 본문 = E11k-e · 🔴 SQL 이 이 글자를
/// 돌려주고 data_sync 클라이언트가 그대로 읽는다 — 클라이언트가 HTTP 상태로 코드를 짓지 않는다).
abstract final class LeaseRpcResultCodes {
  /// 다른 기기가 유효한 리스를 가졌다(`lease_claim` CAS 실패).
  static const String heldByOther = 'LEASE_HELD_BY_OTHER';

  /// 이 기기가 보유자가 아니거나 epoch 가 다르거나 만료됐다(`lease_renew` · 자발 반납).
  static const String lost = 'LEASE_LOST';

  /// 이 기기를 쓸 수 없다(이 인증 사용자의 기기가 아님 · `REVOKED` · `RETIRED`).
  static const String deviceNotEligible = 'LEASE_DEVICE_NOT_ELIGIBLE';

  /// 첫 클레임인데 복구 코드 해시가 없다(M4-3 — 첫 클레임과 같은 트랜잭션에서 발급).
  static const String recoveryCodeRequired = 'RECOVERY_CODE_REQUIRED';

  /// 복구 코드가 맞지 않는다(`lease_revoke` · 🔴 쓴 코드도 여기 — 같은 트랜잭션에서 새 해시로 갈아 끼워 옛 코드는 «틀림»이 된다).
  static const String recoveryCodeInvalid = 'RECOVERY_CODE_INVALID';

  static const Set<String> values = <String>{
    heldByOther,
    lost,
    deviceNotEligible,
    recoveryCodeRequired,
    recoveryCodeInvalid,
  };
}

/// 🆕 v1.37(01 §46 · K324 · K325 · 01 §8 미결 218 ⓕ) — X1 계획 이전 리스 넘김 거부(도메인 `lease_handover_result` · 🔵 **엔진 예고** —
/// SQL 본문 · 클라이언트 = 01 §8 미결 228). `device_retire` · `lease_claim`(티켓 논스) 이 돌려준다.
/// 🔴 [LeaseRpcResultCodes] 와 따로 둔다 — 그 사전 5 = 지금 SQL(E11k-e2) 이 쓰는 글자 전부라는 data_sync 부트스트랩 대조 시험이
///    서 있다(K291 결 · 엔진이 SQL 을 지을 때 두 사전 합집합으로 시험을 넓힌다). 공용 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는
///    [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다.
abstract final class LeaseHandoverResultCodes {
  /// 티켓이 있어야 한다(`device_retire` 에 논스 해시 없음 · 넘김 대기 중 `lease_claim` 에 논스 없음).
  static const String ticketRequired = 'LEASE_TICKET_REQUIRED';

  /// 논스가 대기 티켓 해시와 맞지 않는다.
  static const String ticketInvalid = 'LEASE_TICKET_INVALID';

  /// 대기 티켓이 만료됐다(서버 `now()` 기준) — 옛 폰이 `device_retire` 를 다시 불러 티켓을 바꾸거나(재발급) 비상 경로.
  static const String ticketExpired = 'LEASE_TICKET_EXPIRED';

  static const Set<String> values = <String>{
    ticketRequired,
    ticketInvalid,
    ticketExpired,
  };
}

/// 🆕 v1.38(01 §47 · K333) — 읽기 모델 push RPC 고유 거부(도메인 `read_model_push_result` · RPC 표 = `schema/supabase_rpc.dart`
/// `ReadModelPushRpc*` · 본문 = 엔진 E11l2 · 01 §8 미결 222 ⓑ). 🔴 리스 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는
/// [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다(v1.37 [LeaseHandoverResultCodes] 결).
abstract final class ReadModelPushResultCodes {
  /// 표 이름이 `ReadModelTables` 에 없다(SQL 은 표 이름을 그 목록과만 맞춘다 — 동적 SQL 은 목록 안 이름만).
  static const String tableUnknown = 'READ_MODEL_TABLE_UNKNOWN';

  /// 행 묶음을 넣지 못했다(JSON 배열 아님 · 기본 키 · `mode` · 형 · check 위반) — 🔴 그 호출 전부 0행(부분 반영 0).
  static const String rowsInvalid = 'READ_MODEL_ROWS_INVALID';

  static const Set<String> values = <String>{tableUnknown, rowsInvalid};
}

/// 🆕 v1.40(01 §49 · 01 §8 미결 229 · 13 §8 R270) — 운영 폰 공유 표 push RPC 고유 거부(도메인 `ops_push_result` · RPC 표 =
/// `schema/supabase_rpc.dart` `OpsPushRpc*` · `OpsPushTables` · 본문 = data_sync `sql/supabase_ops_push_rpc.sql`).
/// 🔴 리스 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는 [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다(v1.38
///    [ReadModelPushResultCodes] 결) · 읽기 모델 push 거부(`READ_MODEL_*`)와 다른 글자 — 표 무리가 다르다(조치는 같다 = 앱 ↔ 서버 표 어긋남).
abstract final class OpsPushResultCodes {
  /// 표 이름이 `OpsPushTables.all` 에 없다(표마다 정적 SQL — 목록 밖 이름 = 0행).
  static const String tableUnknown = 'OPS_PUSH_TABLE_UNKNOWN';

  /// 행 묶음을 넣지 못했다(JSON 배열 아님 · 형 · 기본 키 · not null · check · 참조 위반 · 같은 키 두 번 · `command_ack` 남의 명령 ·
  /// 한 호출에 같은 명령 두 번) — 🔴 그 호출 전부 0행(부분 반영 0).
  static const String rowsInvalid = 'OPS_PUSH_ROWS_INVALID';

  static const Set<String> values = <String>{tableUnknown, rowsInvalid};
}

/// 🆕 v1.41(01 §50 · 01 §8 미결 246 · 156 · 13 §8 R272 Y2) — 뷰어 페어링 RPC 고유 거부(도메인 `pairing_rpc_result` · RPC 표 =
/// `schema/supabase_rpc.dart` `PairingRpc*` · 본문 = data_sync `sql/supabase_command_pairing_rpc.sql`).
/// 🔴 발급 · 폐기의 부르는 기기 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는 [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다(v1.38 ·
///    v1.40 결). 클레임 실패 사유 = V-01 `PairingResult.reasonCode` 축(티켓 무효 · 만료 · 기기 자격 — 미결 156) · 폐기된 뒤 뷰어 읽기 · 쓰기
///    거부 = `OnboardingResultCodes.pairingTokenRevoked`(RLS 0행 · 클라이언트 판정 = E11m-b/c · 이 사전 밖).
abstract final class PairingRpcResultCodes {
  /// 티켓이 맞지 않는다 — 클레임: 논스 없음 · 대기 티켓 해시와 다름(이미 쓴 · 바뀐 티켓 포함) · 티켓을 낸 기기가 더는 operator `ACTIVE` 아님(비상 회수 · 은퇴 뒤) / 발급: 해시 꼴(16진 64) 아님 · 수명이
  /// `PairingTicketLimits` 범위 밖(쓰기 0).
  static const String ticketInvalid = 'PAIRING_TICKET_INVALID';

  /// 티켓이 만료됐다(서버 `now()` 기준) — 운영 폰에서 새 QR 을 띄운다(재발급 = 발급 다시 부름).
  static const String ticketExpired = 'PAIRING_TICKET_EXPIRED';

  /// 이 기기 · 사용자로는 페어링할 수 없다 — 클레임: 로그인 0 · 이미 기기 행이 있는 사용자 · 이미 있는 기기 id · 기기 id · 라벨 없음 ·
  /// 티켓 소유자 본인 / 폐기: 대상이 같은 소유자의 뷰어 기기가 아님.
  static const String deviceNotEligible = 'PAIRING_DEVICE_NOT_ELIGIBLE';

  static const Set<String> values = <String>{
    ticketInvalid,
    ticketExpired,
    deviceNotEligible,
  };
}
