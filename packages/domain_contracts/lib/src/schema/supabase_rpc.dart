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

// ── 🆕 계약 v1.40(01 §49 · K353~ · 01 §8 미결 229 · 222 ⓕ · 06 M4-1 · 06 X2-7 · 13 §8 R270 W1~W8) 운영 폰 공유 표 push RPC ──────────────
// 🔴 `rm_*` 밖 배치 D 쓰기 표 다섯(`OpsPushTables`) = 이 RPC 1창구 — 쓰는 주체 = 다섯 다 운영 폰 엔진 · 리스 보유자(뷰어 · 서버 쓰기 0 ·
//    클라이언트 INSERT · UPDATE · DELETE 정책 0 그대로). `rm_push`(v1.38)로 받지 않는다 — 열 관례가 다르다(`row_version` 없는 표 2 ·
//    시각 칸 `acked_at` · `updated_at` · `stamped_at` · epoch 칸 `operator_epoch`) · `rm_push` 표 목록 = `ReadModelTables` 22 그대로(C-71).
//    SQL 본문 · 부트스트랩 다섯째 조각 · 대조 시험 = 엔진(data_sync `sql/supabase_ops_push_rpc.sql`). 여기는 **글자만**(지도 X18).
// 🔴 한 호출 = 한 표 · 한 트랜잭션 — 행 하나라도 못 넣으면 그 호출 전부 0행(`OPS_PUSH_ROWS_INVALID`) · 삭제 0 · 표마다 정적 SQL(동적 SQL 0).
// 🔴 반환 = 한 행(`OpsPushRpcColumns` 넷 = `ReadModelPushRpcColumns` 글자) · 거부 = [LeaseRpcResultCodes] 의 `LEASE_LOST` ·
//    `LEASE_DEVICE_NOT_ELIGIBLE` ∪ `OpsPushResultCodes` · 성공 = `code` null · 시각 = 서버 `now()`.

/// 운영 폰 공유 표 push RPC 이름(06 M4-1 «쓰기 = security definer RPC · 클라이언트 upsert 0»).
abstract final class OpsPushRpcNames {
  /// 한 표의 행 묶음을 올린다 — 기기 · 리스 판정 = [ReadModelPushRpcNames.push] 와 **같은 문장**(부른 사용자 = 그 기기 `auth_uid` =
  /// `owner_uid` ∧ role `operator` ∧ `ACTIVE`(아니면 `LEASE_DEVICE_NOT_ELIGIBLE`) ∧ 리스 행 = 그 기기 ∧ epoch 같음 ∧ 만료 전(아니면
  /// `LEASE_LOST`) · 같은 advisory 잠금 공유) · 표 ∈ [OpsPushTables.all](아니면 `OPS_PUSH_TABLE_UNKNOWN`) · 행 = JSON 배열(열 이름 키 =
  /// 배치 D 그 표 열 · 🔴 epoch 칸(`lease_epoch` · `operator_epoch`) = 인자 epoch · 시각 칸(`acked_at` · `updated_at` · `stamped_at`) =
  /// 서버 `now()` 로 덮어쓴다 — 행이 실은 값 무시). 표마다 충돌 규칙:
  /// `command_ack` = **append-only**(같은 `ack_id` = 건너뜀 · 바꾸지 않음 · `command_id` = 부른 사용자 소유 명령만 · 한 호출에 같은 명령 두 번 =
  /// `OPS_PUSH_ROWS_INVALID` — `acked_at` 이 트랜잭션 시각 하나라 뷰어가 차례를 못 가른다) · `planned_work_mirror` = `row_version` 이 **큰**
  /// 행만(같거나 작으면 건너뜀) · `resume_run_mirror` · `ledger_stamp`(재생성 = 같은 날 다시 씀) · `calendar_sync_status` = 덮는다.
  static const String push = 'op_push';

  static const Set<String> values = <String>{push};
}

/// 운영 폰 공유 표 push RPC 인자 이름(PostgREST `rpc/op_push` 본문 키 · [ReadModelPushRpcParams] 글자 그대로).
abstract final class OpsPushRpcParams {
  /// 부르는 기기(= [LeaseRpcParams.deviceId]).
  static const String deviceId = ReadModelPushRpcParams.deviceId;

  /// 지금 보유 리스 epoch(= [LeaseRpcParams.epoch] · 행의 epoch 칸 원천).
  static const String epoch = ReadModelPushRpcParams.epoch;

  /// 표 이름([OpsPushTables.all] 가운데 하나 · 배치 D 표 이름 그대로).
  static const String table = ReadModelPushRpcParams.table;

  /// 행 묶음(JSON 배열 · 행 = 열 이름 → 와이어 값 · 빈 배열 = 0행 성공).
  static const String rows = ReadModelPushRpcParams.rows;

  static const Set<String> values = <String>{deviceId, epoch, table, rows};
}

/// 운영 폰 공유 표 push RPC 반환 칸(한 행 · [ReadModelPushRpcColumns] 글자 그대로).
abstract final class OpsPushRpcColumns {
  /// 거부 코드 · 성공 = null.
  static const String code = ReadModelPushRpcColumns.code;

  /// 지금 리스 epoch(성공 = 인자 epoch · 거부 = 지금 값 또는 null).
  static const String epoch = ReadModelPushRpcColumns.epoch;

  /// 넣거나 바꾼 행 수(성공 · 거부 = 0).
  static const String accepted = ReadModelPushRpcColumns.accepted;

  /// 건너뛴 행 수(`command_ack` 같은 `ack_id` · `planned_work_mirror` `row_version` 이 크지 않음 · 거부 = 0).
  static const String skipped = ReadModelPushRpcColumns.skipped;

  static const Set<String> values = <String>{code, epoch, accepted, skipped};
}

/// `op_push` 가 받는 표 다섯(배치 D `ddl/batch_d_supabase.sql` 표 이름 · 차례 = 그 파일 차례 · `rm_*` 와 서로소).
abstract final class OpsPushTables {
  /// 명령 소비 ack(엔진 E11m) — append-only · 명령당 여러 행.
  static const String commandAck = 'command_ack';

  /// X2 작업 원장 미러(digest + 한 줄 · 원문 0) — `row_version` 큰 쪽.
  static const String plannedWorkMirror = 'planned_work_mirror';

  /// X2 재개 회차 미러 — 마지막 보낸 값.
  static const String resumeRunMirror = 'resume_run_mirror';

  /// X5 `canonSupabase` 파생 스탬프 — 같은 날 다시 씀 · `operator_epoch` = 쓴 기기 epoch(FORK 재료).
  static const String ledgerStamp = 'ledger_stamp';

  /// X4 캘린더 동기 상태(모드마다 한 행 · ⏸ 실전 뒤 K107).
  static const String calendarSyncStatus = 'calendar_sync_status';

  static const List<String> all = <String>[
    commandAck,
    plannedWorkMirror,
    resumeRunMirror,
    ledgerStamp,
    calendarSyncStatus,
  ];
}

// ── 🆕 계약 v1.41(01 §50 · K360~ · 01 §8 미결 246 · 178 · 156 · 182 · 01 §10-8 G-26 · 06 M4-2 · 13 §8 R272 Y1~Y4) 뷰어 페어링 · 명령 표 읽기 ──
// 🔴 o_07 ① 첫 판 묶음 여섯째 조각(data_sync `sql/supabase_command_pairing_rpc.sql`) — 묶음은 적용 뒤 첫 문장에서 멈추고 이주 장치가 없어서
//    함수를 첫 판에 싣는다(R272 Y1). 여기는 **글자만**(지도 X18 — 이름 · 인자 · 반환 칸 · 상한) · 본문 = 같은 PR 엔진 커밋.
// 🔴 쓰는 RPC 셋 = security definer · 반환 = 한 행 [LeaseRpcColumns] 셋(`code` · `epoch` · `expires_at`) · 거부 = [LeaseRpcResultCodes] 의
//    `LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`(발급 · 폐기의 부르는 기기) ∪ `PairingRpcResultCodes` · 성공 = `code` null · 시각 = 서버 `now()`.
// 🔴 읽는 함수 둘 = **security invoker** · `stable` · RLS 그대로(권한 상승 0) — 판정 재료(명령 · ack · 리스)가 부른 사용자에게 다 보인다
//    (`command_select_own` · `command_ack_select` · `lease_select`). G-26 ⓑ «security definer RPC» = «서버가 판정한다»의 뜻으로 읽는다(K364).
// 🔴 뷰어 세션(Auth 사용자 · 새로고침 토큰)의 원천 = 미결 247(Edge Function `viewer-pair` ★) — 그 함수도 이 `pairing_claim` 을 뷰어 사용자 JWT 로 부른다.

/// 뷰어 페어링 RPC 이름 3(06 M4-3 · S06 `devicePairingTicketCreate` · `deviceTokenRevoke` · V-01 클레임 · 04 §9-7).
abstract final class PairingRpcNames {
  /// 티켓 발급 — 부르는 기기 · 리스 판정 = [OpsPushRpcNames.push] 와 **같은 문장**(운영 사용자의 operator `ACTIVE` 기기 ∧ 리스 행 = 그 기기 ∧
  /// epoch 같음 ∧ 만료 전 · 아니면 `LEASE_DEVICE_NOT_ELIGIBLE` · `LEASE_LOST`) → 해시 꼴(sha256 16진 64 소문자) ∧ 수명
  /// [PairingTicketLimits.ttlMinutesMin] ~ [PairingTicketLimits.ttlMinutesMax] 분(아니면 `PAIRING_TICKET_INVALID`) → 소유자의 티켓 한 행을
  /// **바꿔 넣는다**(쓰지 않은 옛 티켓 = 무효 · 재발급 = 다시 부름). 반환 `epoch` = 지금 리스 epoch · `expires_at` = **티켓 만료 시각**
  /// (서버 `now()` + 수명 — QR 카드 만료 글자 원천).
  static const String ticketIssue = 'pairing_ticket_issue';

  /// 클레임(뷰어 기기 · V-01) — 부른 사용자(뷰어 Auth 사용자 · 지도 D5)의 기기 행 0 ∧ 새 기기 id ∧ 라벨 있음(아니면 `PAIRING_DEVICE_NOT_ELIGIBLE`) ·
  /// 논스 sha256 = 대기 티켓 해시 ∧ 티켓을 낸 기기가 아직 operator `ACTIVE`(비상 회수 · 은퇴 뒤 옛 티켓 = 무효 · 아니면 `PAIRING_TICKET_INVALID`) · 부른 사용자 ≠ 티켓 소유자(아니면 `PAIRING_DEVICE_NOT_ELIGIBLE`) · 만료 전
  /// (서버 `now()` · 아니면 `PAIRING_TICKET_EXPIRED`) → **한 트랜잭션**: `app_device`(role `viewer` · status **`ACTIVE`** · `owner_uid` = 티켓 소유자 ·
  /// `auth_uid` = 부른 사용자) + 티켓 지움(한 번만 쓴다). 반환 `epoch` · `expires_at` = null(뜻 = `code` 하나).
  static const String claim = 'pairing_claim';

  /// 뷰어 폐기(S06 · 04 §9-7 «즉시 차단») — 부르는 기기 · 리스 판정 = 발급과 같다 → 대상 = 같은 소유자 · role `viewer` 행(아니면
  /// `PAIRING_DEVICE_NOT_ELIGIBLE`) → status `REVOKED`(모든 RLS 정책이 `ACTIVE` 를 보므로 곧바로 읽기 · 쓰기 0 = 뷰어 `PAIRING_TOKEN_REVOKED` 경로) ·
  /// 이미 `REVOKED` = 성공(바뀜 0 · 멱등 재시도). 반환 `epoch` = 지금 리스 epoch · `expires_at` = null. 🔴 운영 폰 행은 이 RPC 로 못 바꾼다
  /// (운영 폰 은퇴 = `device_retire` · 비상 = `lease_revoke`).
  static const String revoke = 'pairing_revoke';

  static const Set<String> values = <String>{ticketIssue, claim, revoke};
}

/// 뷰어 페어링 RPC 인자 이름(PostgREST `rpc/<이름>` 본문 키) — 🔴 같은 꼴 = 같은 글자(기기 · epoch = 리스 · 논스 해시 · 논스 · 수명 = X1 넘김 티켓).
abstract final class PairingRpcParams {
  /// 부르는 기기 — 발급 · 폐기 = 운영 폰(= [LeaseRpcParams.deviceId]) · 클레임 = **새 뷰어 기기 id**(뷰어가 지은 값 · 이미 있는 id = 거부).
  static const String deviceId = LeaseRpcParams.deviceId;

  /// 지금 보유 리스 epoch(발급 · 폐기 · = [LeaseRpcParams.epoch]).
  static const String epoch = LeaseRpcParams.epoch;

  /// 티켓 논스의 sha256(16진 64 소문자 · 발급 · 평문 0 — 평문은 QR 페이로드에만 · = [LeaseHandoverRpcParams.ticketNonceHash]).
  static const String ticketNonceHash = LeaseHandoverRpcParams.ticketNonceHash;

  /// 티켓 수명(분 · 발급 · 값 = 운영 설정 · 미결 182 잠정 15분 · = [LeaseHandoverRpcParams.ticketTtlMinutes]).
  static const String ticketTtlMinutes =
      LeaseHandoverRpcParams.ticketTtlMinutes;

  /// 티켓 논스 평문(클레임 · QR 에서 읽은 값 · 서버가 sha256 으로 대조 · 🔴 저장 · 로그 0 · = [LeaseHandoverRpcParams.ticketNonce]).
  static const String ticketNonce = LeaseHandoverRpcParams.ticketNonce;

  /// 새 뷰어 기기 라벨(클레임 · `app_device.label` · 비면 거부).
  static const String label = 'p_label';

  /// 새 뷰어 기기 플랫폼(클레임 · `app_device.platform` · null 허용).
  static const String platform = 'p_platform';

  /// 폐기할 뷰어 기기(폐기 · 같은 소유자 · role `viewer`).
  static const String targetDeviceId = 'p_target_device_id';

  static const Set<String> values = <String>{
    deviceId,
    epoch,
    ticketNonceHash,
    ticketTtlMinutes,
    ticketNonce,
    label,
    platform,
    targetDeviceId,
  };
}

/// 뷰어 페어링 RPC 반환 칸(한 행 · [LeaseRpcColumns] 글자 그대로 — 클라이언트 해석기 하나).
abstract final class PairingRpcColumns {
  /// 거부 코드 · 성공 = null.
  static const String code = LeaseRpcColumns.code;

  /// 지금 리스 epoch(발급 · 폐기 · 거부 = 지금 값 또는 null · 클레임 = null).
  static const String epoch = LeaseRpcColumns.epoch;

  /// 티켓 만료 시각(발급 성공만 · 그 밖 = null).
  static const String expiresAt = LeaseRpcColumns.expiresAt;

  static const Set<String> values = <String>{code, epoch, expiresAt};
}

/// 페어링 티켓 수명의 **받는 범위**(서버 경계 검사 · 실수 막이) — 🔴 값(운영 설정 · 미결 182 잠정 15분)이 아니다.
/// 범위 밖 = `PAIRING_TICKET_INVALID`(쓰기 0) · 값이 정해져도(182) 범위 안이면 설정만 바꾼다(이주 SQL 0).
abstract final class PairingTicketLimits {
  /// 하한(분).
  static const int ttlMinutesMin = 1;

  /// 상한(분 · QR 한 장이 1시간 넘게 살지 않는다 · 182 후보 = X1 넘김 티켓 15분).
  static const int ttlMinutesMax = 60;
}

/// 명령 표 읽는 함수 이름 2(06 M4-2 · 01 §10-8 G-26 · 13 §8 R272 Y2 ⓔ · Y4 · Y5) — security invoker · RLS 그대로.
abstract final class CommandReadRpcNames {
  /// 소비기 당김(운영 폰 · E11m-a) — 보이는 명령 가운데 **종단 ack**(`EXECUTED` · `REJECTED` · `EXPIRED`) 없는 것 · 차례 = 킬스위치 먼저 →
  /// `requested_at` → `command_id` · 상한 [CommandReadLimits.openMax] · 반환 = `command_queue` 행([CommandOpenColumns]).
  /// 🔴 리스 보유 판정은 하지 않는다 — 소비기는 리스 원격 확인을 통과한 뒤에만 부른다(Y5 · 소비 주체 = 리스 보유자 하나).
  static const String open = 'command_open';

  /// 명령 상태(뷰어 `CommandApi.watchCommand` · E11m-b) — 인자 id 가운데 보이는 명령마다 한 행([CommandStatusColumns]) · 보이지 않거나 없는 id = 행 0.
  /// 판정(**서버 `now()`** · G-26 ⓑ): 최신 ack(`acked_at` 내림 · 같으면 종단 먼저 · 그다음 `ack_id`)가 종단 = 그 ack · 아니면(ack 없음 · 비종단)
  /// 유효 리스(만료 전) 없음 = **`NO_OPERATOR`** · ack 없음 ∧ 유효 리스 = **`REQUESTED`**(보냄 · 수신 대기) · 비종단 ack ∧ 유효 리스 = 그 ack.
  /// 서버가 지은 두 상태(`NO_OPERATOR` · `REQUESTED`)의 `state_label` · ack 칸 = null — 글자 = 계약 카탈로그 `CommandStatusText`(뷰어 구현이 고른다).
  static const String status = 'command_status';

  static const Set<String> values = <String>{open, status};
}

/// 명령 표 읽는 함수 인자 이름.
abstract final class CommandReadRpcParams {
  /// `command_open` 행 수(null · 1 미만 · 상한 초과 = 상한 [CommandReadLimits.openMax]).
  static const String limit = 'p_limit';

  /// `command_status` 명령 id 배열(uuid[] · 화면 = 보고 있는 명령들).
  static const String commandIds = 'p_command_ids';

  static const Set<String> values = <String>{limit, commandIds};
}

/// `command_open` 반환 칸 = 배치 D `command_queue` 열(그 표 차례 그대로 · `setof public.command_queue`).
abstract final class CommandOpenColumns {
  static const List<String> all = <String>[
    'command_id',
    'kind',
    'payload',
    'issued_by_device',
    'nonce',
    'requested_at',
    'expires_at',
    'owner_uid',
    'run_mode',
    'operating_mode',
    'lease_epoch',
  ];
}

/// `command_status` 반환 칸(명령마다 한 행 · ack 칸 = 최신 ack · 서버가 지은 상태면 null).
abstract final class CommandStatusColumns {
  /// 명령 id.
  static const String commandId = 'command_id';

  /// `CommandState.wire`(`REQUESTED` 포함 9값 — `REQUESTED` · `NO_OPERATOR` = 서버 판정 · 나머지 = 최신 ack).
  static const String state = 'state';

  /// 최신 ack 의 엔진 글자 · 서버 판정 상태 = null(뷰어 구현이 `CommandStatusText` 에서 고른다).
  static const String stateLabel = 'state_label';

  /// 최신 ack 의 거부 코드(`REJECTED` 일 때 · 그 밖 null).
  static const String rejectReasonCode = 'reject_reason_code';

  /// 최신 ack 의 결정 id(있으면).
  static const String decisionId = 'decision_id';

  /// 최신 ack 시각(서버 · 서버 판정 상태 = null).
  static const String ackedAt = 'acked_at';

  static const List<String> all = <String>[
    commandId,
    state,
    stateLabel,
    rejectReasonCode,
    decisionId,
    ackedAt,
  ];
}

/// 명령 표 읽기 상한.
abstract final class CommandReadLimits {
  /// `command_open` 한 번에 돌려주는 행 상한(뷰어 명령은 하루 몇 건 · 넘치면 다음 당김).
  static const int openMax = 100;
}
