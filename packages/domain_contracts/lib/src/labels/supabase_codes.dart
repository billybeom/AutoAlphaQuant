// 🆕 계약 v1.29(01 §39 · K223~ · E11k-b 계약 창) — Supabase 연결(o_07 ②) · 신뢰 시각 · operator 리스의 코드 사전.
//
// 🔴 타입 이름 ≠ 엔진(data_sync `SupabaseInputProblem` · `SupabaseTimeFailure` — 같으면 엔진 시험이
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
