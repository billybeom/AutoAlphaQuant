// 영역 H — 🆕 계약 v1.29(01 §39 · §6-4 · K228 · 지도 X18 · D15) operator 리스 RPC 표(이름 · 인자 · 반환 칸).
//
// 🔴 RPC 본문(SQL · security definer)은 여기 없다 — E11k-e 부트스트랩 SQL 묶음(E11l1 `rm_*` 생성기와 같은 판). 여기는 **글자만** 둔다:
//    data_sync 클라이언트와 SQL 이 같은 이름 · 인자 · 반환 칸을 쓰게 하는 자리다(엔진 · SQL 이 각자 짓지 않는다 — X18).
// 🔴 모든 RPC 의 반환 = 한 행(`code` · `epoch` · `expires_at`) — `code` = `LeaseRpcResultCodes` ∪ null(성공). 클라이언트는 HTTP 상태 ·
//    오류 문장으로 코드를 짓지 않는다. 시각 = 서버 `now()` 기준(🔴 `server_now` RPC 0 — 신뢰 시각 원천 = 게이트웨이 `Date` · T1).
// 🔴 리스 수명 T(30분) · 갱신 T/3 = 서버 상수 · 엔진 상수(`kLeaseTtl` · R43 D3) — 클라이언트 인자 0.

/// 리스 RPC 이름 3(06 M4-3 · 배치 D `operator_lease` 단일 행 · 조건부 쓰기(CAS)만).
abstract final class LeaseRpcNames {
  /// 클레임 — 빈 행(첫 클레임 · 🔴 복구 코드 해시 필수 · 같은 트랜잭션) · 같은 기기 → 이 기기 · 🆕 v1.39(01 §48 K349 ①) 다른 기기 보유 ∧ 만료 =
  /// 그 기기가 REVOKED · RETIRED 일 때만 이 기기(epoch+1 · 아니면 `LEASE_HELD_BY_OTHER`) · 첫 클레임 뒤 = 운영 사용자만(`recovery_secret.owner_uid`).
  static const String claim = 'lease_claim';

  /// 갱신 — 보유 ∧ epoch 같음 ∧ 만료 전 → `expires_at` = 서버 `now()` + T.
  static const String renew = 'lease_renew';

  /// 비상 회수(X1-3 ①) — 복구 코드 대조 → 같은 트랜잭션: epoch+1 · 옛 보유 기기 `REVOKED` · 즉시 만료 · 복구 코드 해시 교체.
  static const String revoke = 'lease_revoke';

  static const Set<String> values = <String>{claim, renew, revoke};
}

/// 리스 RPC 인자 이름(PostgREST `rpc/<이름>` 본문 키).
abstract final class LeaseRpcParams {
  /// 부르는 기기(`app_device.device_id` · 🔴 그 기기의 `auth_uid` = `auth.uid()` 여야 한다 — D5).
  static const String deviceId = 'p_device_id';

  /// 지금 보유 epoch(`lease_renew`).
  static const String epoch = 'p_epoch';

  /// 첫 클레임 때 복구 코드 해시(`lease_claim` · 평문 0 · 그 밖 클레임 = null).
  static const String recoveryCodeHash = 'p_recovery_code_hash';

  /// 복구 코드 평문(`lease_revoke` · 서버가 해시와 대조 · 🔴 저장 · 로그 0).
  static const String recoveryCode = 'p_recovery_code';

  /// 새 복구 코드 해시(`lease_revoke` · 같은 트랜잭션에서 교체).
  static const String newRecoveryCodeHash = 'p_new_recovery_code_hash';

  static const Set<String> values = <String>{
    deviceId,
    epoch,
    recoveryCodeHash,
    recoveryCode,
    newRecoveryCodeHash,
  };
}

/// 리스 RPC 반환 칸(한 행).
abstract final class LeaseRpcColumns {
  /// 거부 코드(`LeaseRpcResultCodes`) · 성공 = null.
  static const String code = 'code';

  /// 리스 epoch(성공 = 그 뒤 값 · 거부 = 지금 값 또는 null).
  static const String epoch = 'epoch';

  /// 리스 만료 시각(서버 `now()` 기준 · `lease_revoke` = 즉시 만료 시각).
  static const String expiresAt = 'expires_at';

  static const Set<String> values = <String>{code, epoch, expiresAt};
}

// ── 🆕 계약 v1.37(01 §46 · K324 · K325 · 01 §8 미결 218 ⓕ · 13 §8 R244 넘김 (가)(나)(다)) X1 계획 이전 리스 넘김 ──────────
// 🔴 **엔진 예고** — SQL 본문 · data_sync 클라이언트 · 부트스트랩 대조 시험 = 01 §8 미결 228. 위 세 표(`LeaseRpcNames` · `Params` ·
//    `Columns`)는 지금 SQL 이 쓰는 글자 그대로 둔다(부트스트랩 시험 «계약 밖 함수 0» · «거부 글자 = 사전 5» 가 깨지지 않게 · K291 결) —
//    엔진이 SQL 을 지을 때 두 표의 합집합으로 넓힌다.
// 🔴 반환 = 같은 한 행(`LeaseRpcColumns` 셋) · 거부 = `LeaseRpcResultCodes` ∪ `LeaseHandoverResultCodes` · 시각 = 서버 `now()`.
// 🔴 티켓 TTL 값 = 운영 설정 `migration.ticket_ttl_minutes`(SPEC 02 §4 · 잠정 값 · 발주자 확정 대기 — 서버 상수 0 · 계약 수치 0).

/// 계획 이전 리스 넘김 RPC 이름(06 X1-2 «RETIRED 서명» 단계).
abstract final class LeaseHandoverRpcNames {
  /// 옛 폰 은퇴 — **한 트랜잭션**: 그 기기 `app_device.status = 'RETIRED'` · 리스 즉시 만료(`expires_at = now()`) · 넘김 티켓
  /// 해시 · 만료 기록(`operator_lease.ticket_hash` · `ticket_expires_at`). 조건 = 부른 사용자 = 그 기기 `auth_uid` ∧ 리스 행 =
  /// 그 기기 ∧ epoch 같음(만료됐어도 그 뒤 다른 기기가 안 가져갔으면) · 거부 = 다른 기기 · epoch 다름 `LEASE_LOST` · 남의 기기 ·
  /// `REVOKED` `LEASE_DEVICE_NOT_ELIGIBLE` · 해시 없음 `LEASE_TICKET_REQUIRED`. 🔵 이미 `RETIRED` ∧ 같은 epoch ∧ 아직 아무도
  /// 클레임 안 함 = 티켓 교체(재발급 · 멱등 재시도). 반환 `expires_at` = **티켓 만료 시각**(리스는 이미 끝났다 · 엔진 티켓 `exp` 원천).
  /// 🔴 RETIRED 쓰기 · 리스 놓기를 둘로 나누지 않는다 — «RETIRED 인데 리스 보유» 중간 상태 0(K324).
  static const String retire = 'device_retire';

  static const Set<String> values = <String>{retire};
}

/// 계획 이전 리스 넘김 RPC 인자 이름.
abstract final class LeaseHandoverRpcParams {
  /// 넘김 티켓 논스의 sha256(16진 64 · `device_retire` · 평문 0 — 평문은 QR 페이로드에만(엔진 `TransferTicket.nonce`)).
  static const String ticketNonceHash = 'p_ticket_nonce_hash';

  /// 티켓 수명(분 · `device_retire` · 값 = 운영 설정 `migration.ticket_ttl_minutes` · 0 이하 = 서버가 받지 않는다).
  static const String ticketTtlMinutes = 'p_ticket_ttl_minutes';

  /// 넘김 티켓 논스 평문(`lease_claim` 셋째 인자 · `text default null` · 서버가 sha256 으로 대조 · 🔴 저장 · 로그 0).
  /// 대기 티켓이 있으면: 없음 `LEASE_TICKET_REQUIRED` · 다름 `LEASE_TICKET_INVALID` · 만료 `LEASE_TICKET_EXPIRED` · 맞음 = 클레임
  /// (epoch+1 · 그 기기 operator `ACTIVE` · 티켓 지움). 대기 티켓 없음 = 기존 규칙(논스 무시). `lease_revoke`(비상) = 대기 티켓도 지운다.
  static const String ticketNonce = 'p_ticket_nonce';

  static const Set<String> values = <String>{
    ticketNonceHash,
    ticketTtlMinutes,
    ticketNonce,
  };
}

// ── 🆕 계약 v1.38(01 §47 · K330~K337 · 01 §8 미결 222 ⓑ · 06 M4-1 · 13 §8 R251) 읽기 모델 push RPC ──────────────────────────
// 🔴 `rm_*` 쓰기 = 이 RPC 1창구(security definer · 리스 epoch 검사 · 클라이언트 upsert 0 — 01 §6-4 말미 · 규칙 5조 ④).
//    SQL 본문 · data_sync 클라이언트 · 부트스트랩 대조 시험 = 엔진(E11l2 · 미결 222 ⓑ). 여기는 **글자만**(지도 X18).
// 🔴 한 호출 = 한 표 · 한 트랜잭션 — 행 하나라도 못 넣으면 그 호출 전부 0행(`READ_MODEL_ROWS_INVALID`) · 삭제 0.
// 🔴 반환 = 한 행(`ReadModelPushRpcColumns` 넷) · 거부 = [LeaseRpcResultCodes] 의 `LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE` ∪
//    `ReadModelPushResultCodes` · 성공 = `code` null · 시각 = 서버 `now()`.

/// 읽기 모델 push RPC 이름(06 M4-1 «1개 창구»).
abstract final class ReadModelPushRpcNames {
  /// 한 표의 행 묶음을 올린다 — 조건 = 부른 사용자 = 그 기기 `auth_uid` = `owner_uid` ∧ role `operator` ∧ `ACTIVE` ∧
  /// 리스 행 = 그 기기 ∧ epoch 같음 ∧ 만료 전(아니면 `LEASE_LOST` · 남의 기기 · 뷰어 · `REVOKED` · `RETIRED` = `LEASE_DEVICE_NOT_ELIGIBLE`) ·
  /// 표 ∈ `ReadModelTables`(아니면 `READ_MODEL_TABLE_UNKNOWN`) · 행 = JSON 배열(열 이름 키 = `ReadModelTables` 열 · 규칙 5조
  /// `row_version` · `mode` · 키 · 🔴 `lease_epoch` · `pushed_at` 은 서버가 덮어쓴다 = 인자 epoch · `now()`) ·
  /// 기본 키 충돌 = `row_version` 이 **큰** 행만 반영(같거나 작으면 건너뜀 · 규칙 5조 ②).
  static const String push = 'rm_push';

  static const Set<String> values = <String>{push};
}

/// 읽기 모델 push RPC 인자 이름(PostgREST `rpc/rm_push` 본문 키).
abstract final class ReadModelPushRpcParams {
  /// 부르는 기기(= [LeaseRpcParams.deviceId] 와 같은 글자).
  static const String deviceId = LeaseRpcParams.deviceId;

  /// 지금 보유 리스 epoch(= [LeaseRpcParams.epoch] 와 같은 글자 · 행의 `lease_epoch` 원천).
  static const String epoch = LeaseRpcParams.epoch;

  /// 표 이름(`ReadModelTable.name` 그대로 · `rm_` 접두).
  static const String table = 'p_table';

  /// 행 묶음(JSON 배열 · 행 = 열 이름 → 와이어 값 · 빈 배열 = 0행 성공).
  static const String rows = 'p_rows';

  static const Set<String> values = <String>{deviceId, epoch, table, rows};
}

/// 읽기 모델 push RPC 반환 칸(한 행).
abstract final class ReadModelPushRpcColumns {
  /// 거부 코드 · 성공 = null.
  static const String code = 'code';

  /// 지금 리스 epoch(성공 = 인자 epoch · 거부 = 지금 값 또는 null).
  static const String epoch = 'epoch';

  /// 넣거나 바꾼 행 수(성공 · 거부 = 0).
  static const String accepted = 'accepted';

  /// `row_version` 이 크지 않아 건너뛴 행 수(성공 · 거부 = 0).
  static const String skipped = 'skipped';

  static const Set<String> values = <String>{code, epoch, accepted, skipped};
}
