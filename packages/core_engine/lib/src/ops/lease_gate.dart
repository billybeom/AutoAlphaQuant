// 리스(이 기기의 발주권) 판정 포트 · 상수(X1-1 · SPEC v2.42 04 §3-1 NR-1 0 · 6.9 · v2.42 ① · 06 M4-3 ·
// 설계 13 §8 R43 D3 · R71).
//
// 🔴 발주 · 파생 쓰기는 리스가 «유효»일 때만 — 무효 · 모름 = 막는다(fail-closed · 01 §2-1 `GateState.unknown`).
// 🔴 킬스위치 발동 · 기록 명령 · 대사 · 읽기는 리스로 막지 않는다.
// 🔴 실물(Supabase RPC · 신뢰 시각) = E11k — 그 전에는 `simInternal` 만 «로컬 단독 리스»(data_sync).

/// 리스 판정 3상.
enum LeaseVerdict {
  /// 이 기기가 리스를 가졌다.
  valid,

  /// 리스가 없다 · 봉인됐다.
  invalid,

  /// 모른다(연결 · 실물 없음) — 🔴 막는다.
  unknown,
}

/// 리스 포트(R71 L0) — 구현 = data_sync `SqliteLeaseGate`(+ E11k RPC 어댑터).
abstract interface class LeaseGate {
  /// 지금 판정.
  Future<LeaseVerdict> check();
}

/// NR-1 0단계 거부 · 6.9 건너뜀 사유(R71 L7 — 계약 등재 = 계약 창).
const String kLeaseInvalidCode = 'LEASE_INVALID';

/// 리스 수명 T(R43 D3).
const Duration kLeaseTtl = Duration(minutes: 30);

/// 갱신 주기 T/3(R43 D3).
const Duration kLeaseRenewEvery = Duration(minutes: 10);

/// 봉인할 때인가(R71 L4) — 마지막 갱신 성공에서 T 이상 지났다.
bool leaseStale({required DateTime lastOkAtUtc, required DateTime nowUtc}) =>
    nowUtc.difference(lastOkAtUtc) >= kLeaseTtl;

/// 포트를 읽는다 — 🔴 예외 = 모름(막는다).
Future<LeaseVerdict> readLease(LeaseGate gate) async {
  try {
    return await gate.check();
  } on Object {
    return LeaseVerdict.unknown;
  }
}
