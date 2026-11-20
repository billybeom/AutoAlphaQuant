// 영역 H — 🆕 계약 v1.29(01 §39 · §6-4 · K228 · 지도 X18 · D15) operator 리스 RPC 표(이름 · 인자 · 반환 칸).
//
// 🔴 RPC 본문(SQL · security definer)은 여기 없다 — E11k-e 부트스트랩 SQL 묶음(E11l1 `rm_*` 생성기와 같은 판). 여기는 **글자만** 둔다:
//    data_sync 클라이언트와 SQL 이 같은 이름 · 인자 · 반환 칸을 쓰게 하는 자리다(엔진 · SQL 이 각자 짓지 않는다 — X18).
// 🔴 모든 RPC 의 반환 = 한 행(`code` · `epoch` · `expires_at`) — `code` = `LeaseRpcResultCodes` ∪ null(성공). 클라이언트는 HTTP 상태 ·
//    오류 문장으로 코드를 짓지 않는다. 시각 = 서버 `now()` 기준(🔴 `server_now` RPC 0 — 신뢰 시각 원천 = 게이트웨이 `Date` · T1).
// 🔴 리스 수명 T(30분) · 갱신 T/3 = 서버 상수 · 엔진 상수(`kLeaseTtl` · R43 D3) — 클라이언트 인자 0.

/// 리스 RPC 이름 3(06 M4-3 · 배치 D `operator_lease` 단일 행 · 조건부 쓰기(CAS)만).
abstract final class LeaseRpcNames {
  /// 클레임 — 빈 행(첫 클레임 · 🔴 복구 코드 해시 필수 · 같은 트랜잭션) · 만료 · 같은 기기 → 이 기기(다른 기기에서 넘어옴 = epoch+1).
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
