// 리스 판정 · 봉인 · 파생 쓰기 판정(X1-1 · SPEC v2.42 04 §3-1 NR-1 0 · 6.9 · v2.42 ① · 설계 13 §8 R71 L3~L6).
//
// 🔴 판정 차례 = 봉인(`sync_state` SUPABASE 행 `SEALED`)이 먼저 → 실물(E11k RPC 어댑터 = [remote]) →
//    실물 전에는 `simInternal` 만 «로컬 단독 리스»(epoch 0) · `live` · `simBroker` = 모름(막는다).
// 🔴 봉인은 있는 행만 바꾼다 — 행을 새로 만들지 않는다(행이 생기면 5칸 대조 보드가 «대상 있음»으로 읽는다 · E13c2).
// 🔴 킬스위치 발동 · 기록 명령 · 대사 · 읽기는 리스로 막지 않는다(리스 = 발주 · 파생 쓰기만).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';

/// 리스가 사는 `sync_state.target`.
const String kLeaseSyncTarget = 'SUPABASE';

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

/// 🆕 리뷰 3차 C-3(01 §8 미결 236 ⓒ · 설계 13 §8 R267) — 기록된 사실만으로 읽는 판정(원격 호출 0 · 원장 쓰기 0).
/// 🔴 화면 표시용이다(S06 기기 화면이 `sync_state` 를 따라가도 다시 울리지 않게) — 발주 · 파생 쓰기 판정은 늘 [LeaseGate.check].
abstract interface class RecordedLeaseGate {
  /// 기록만 읽은 판정 — 유효 = 마지막 원격 성공이 T 안 · 무효 = 쥔 적 없음 · 모름 = 그 밖(다음 주문 직전에 원격이 다시 판정).
  LeaseVerdict recorded();
}

/// 🆕 리뷰 3차 C-1(미결 236 ⓐ) — 리스 행을 봉인한다(R71 L4) — 있는 행만 · 봉인했으면 true(이미 봉인 · 행 없음 = false).
bool sealLeaseRow(Database db, Clock clock) {
  db.execute(
    "UPDATE sync_state SET status = 'SEALED', updated_at = ? "
    "WHERE target = ? AND status <> 'SEALED'",
    <Object?>[clock.nowUtc().toUtc().toIso8601String(), kLeaseSyncTarget],
  );
  return db.updatedRows > 0;
}

/// 운영 기기 리스 판정(R71 L3).
class SqliteLeaseGate implements LeaseGate, RecordedLeaseGate {
  /// 판정을 만든다 — [mode] = 이 원장 파일의 실행 모드 · [remote] = 리스 실물(E11k · 없으면 실물 전).
  SqliteLeaseGate(
    this._db, {
    required this._mode,
    required this._clock,
    this._remote,
  });

  final Database _db;
  final RunMode _mode;
  final Clock _clock;
  final LeaseGate? _remote;

  ResultSet _row() => _db.select(
    'SELECT status, last_ok_at FROM sync_state WHERE target = ?',
    <Object?>[kLeaseSyncTarget],
  );

  /// 🆕 E15f4a(R103 AI3) — 지금 리스 세대(`sync_state` SUPABASE 행 `operator_epoch` · 행 없음 = 0 · 로컬 단독 리스).
  int epoch() {
    final ResultSet rs = _db.select(
      'SELECT operator_epoch FROM sync_state WHERE target = ?',
      <Object?>[kLeaseSyncTarget],
    );
    return rs.isEmpty ? 0 : rs.first['operator_epoch'] as int;
  }

  /// 봉인됐나.
  bool sealed() {
    final ResultSet rs = _row();
    return rs.isNotEmpty && rs.first['status'] == 'SEALED';
  }

  @override
  Future<LeaseVerdict> check() async {
    try {
      if (sealed()) return LeaseVerdict.invalid;
    } on Object {
      return LeaseVerdict.unknown;
    }
    final LeaseGate? remote = _remote;
    if (remote != null) return readLease(remote);
    return _mode == RunMode.simInternal
        ? LeaseVerdict.valid
        : LeaseVerdict.unknown;
  }

  /// 🆕 리뷰 3차 C-3(미결 236 ⓒ) — 기록된 사실만(원격 호출 · 쓰기 0) — 차례는 [check] 와 같다: 봉인 → 원격([RecordedLeaseGate] 만 ·
  /// 그 밖 원격 = 모름) → 실물 전 모드 규칙. 읽기 실패 = 모름.
  @override
  LeaseVerdict recorded() {
    try {
      if (sealed()) return LeaseVerdict.invalid;
      final LeaseGate? remote = _remote;
      if (remote case final RecordedLeaseGate r) return r.recorded();
      if (remote != null) return LeaseVerdict.unknown;
    } on Object {
      return LeaseVerdict.unknown;
    }
    return _mode == RunMode.simInternal
        ? LeaseVerdict.valid
        : LeaseVerdict.unknown;
  }

  /// 봉인한다(R71 L4) — 리스 행이 있을 때만 · 봉인했으면 true(이미 봉인 · 행 없음 = false).
  bool seal() => sealLeaseRow(_db, _clock);

  /// 갱신이 T 넘게 끊겼으면 봉인한다(R71 L4) — 행 없음 · 갱신 기록 없음 = 아직 리스 전(아무것도 안 함).
  bool sealIfStale() {
    final ResultSet rs = _row();
    if (rs.isEmpty || rs.first['last_ok_at'] == null) return false;
    if (!leaseStale(
      lastOkAtUtc: _instant(rs.first['last_ok_at'] as String),
      nowUtc: _clock.nowUtc().toUtc(),
    )) {
      return false;
    }
    return seal();
  }

  /// 파생 쓰기(push · 아카이브 전송 · 캘린더)를 해도 되나(R71 L5) — 리스 유효일 때만.
  Future<bool> derivedWritesAllowed() async =>
      await readLease(this) == LeaseVerdict.valid;
}
