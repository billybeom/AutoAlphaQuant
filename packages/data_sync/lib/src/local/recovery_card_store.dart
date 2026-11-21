// O-04 ⑤ 복구 카드 첫 클레임 기록(E11k-e3 · 설계 13 §8 R229 F5 · ③ 생체 `biometric_sign_store.dart` 선례 — 스키마 무변경).
//
// 🔴 행 = `command_inbox`(kind `ONBOARDING_RECOVERY_CARD` · sim 원장 = 온보딩 원장) · 사건마다 새 행(덧붙이기만 · 고치지 않는다) ·
//    마지막 행이 지금 상태: `PENDING_LEASE_CONFIRM` = 종이 확인됨 · 서버 등록 남음 / `EXECUTED` = 리스 얻음(`lease_epoch`) /
//    `REJECTED` = 서버 거부(`reject_reason_code` = 서버 글자 · 그 카드 무효).
// 🔴 평문 0 — 해시만(`payload_digest` = `sha256:<소금>:<요약>` · «원문 재저장 금지 — digest 만»). 100비트 무작위 코드라 되돌릴 수 없다.

import 'package:core_engine/core_engine.dart' show kRecoveryCardKind;
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

/// 복구 카드 기록 상태.
enum RecoveryCardState {
  /// 종이 확인됨 · 서버 등록 남음.
  pending('PENDING_LEASE_CONFIRM', '서버 등록 대기'),

  /// 리스를 얻었다.
  claimed('EXECUTED', '실행됨'),

  /// 서버가 거부했다(그 카드 무효).
  rejected('REJECTED', '거부됨');

  const RecoveryCardState(this.wire, this.label);

  /// `command_inbox.state` 글자.
  final String wire;

  /// `command_inbox.state_label`(엔진 문구).
  final String label;
}

/// 마지막 기록 한 행(🔴 평문 0).
class RecoveryCardRecord {
  /// 만든다.
  const RecoveryCardRecord({
    required this.state,
    required this.hash,
    this.epoch,
    this.rejectCode,
  });

  /// 상태.
  final RecoveryCardState state;

  /// 그 카드의 해시.
  final String hash;

  /// 얻은 epoch([RecoveryCardState.claimed] 만).
  final int? epoch;

  /// 서버 거부 글자([RecoveryCardState.rejected] 만).
  final String? rejectCode;

  /// 리스는 얻었지만 계정에 예전 카드가 있다 — 첫 클레임(epoch 1)이 아니면 서버는 이 해시를 읽지 않았다(R221 S5).
  bool get existingCard => state == RecoveryCardState.claimed && epoch != 1;

  @override
  String toString() => 'RecoveryCardRecord(${state.wire} · epoch $epoch)';
}

/// 복구 카드 기록 저장소(sim 원장 `command_inbox`).
class SqliteRecoveryCardStore {
  /// 만든다.
  SqliteRecoveryCardStore(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 마지막 기록(없음 = null).
  RecoveryCardRecord? latest() {
    final ResultSet rs = _db.select(
      'SELECT state, payload_digest, lease_epoch, reject_reason_code FROM command_inbox '
      'WHERE kind = ? ORDER BY rowid DESC LIMIT 1',
      <Object?>[kRecoveryCardKind],
    );
    if (rs.isEmpty) return null;
    final Row r = rs.single;
    final String wire = r['state'] as String;
    return RecoveryCardRecord(
      state: RecoveryCardState.values.firstWhere(
        (RecoveryCardState s) => s.wire == wire,
        orElse: () => throw FormatException('복구 카드 기록 상태가 아니다', wire),
      ),
      hash: r['payload_digest'] as String,
      epoch: r['lease_epoch'] as int?,
      rejectCode: r['reject_reason_code'] as String?,
    );
  }

  /// 이 기기가 첫 클레임으로 얻은 epoch(마지막이 [RecoveryCardState.claimed] 일 때 · 그 밖 = 0).
  int claimedEpoch() {
    final RecoveryCardRecord? r = latest();
    return r != null && r.state == RecoveryCardState.claimed ? r.epoch ?? 0 : 0;
  }

  /// 🔴 한 행 덧붙인다.
  void append({
    required String commandId,
    required RecoveryCardState state,
    required String hash,
    int? epoch,
    String? rejectCode,
  }) {
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      'VALUES (?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?, ?)',
      <Object?>[
        commandId,
        kRecoveryCardKind,
        _clock.nowUtc().toUtc().toIso8601String(),
        state.wire,
        state.label,
        rejectCode,
        epoch,
        hash,
      ],
    );
  }
}
