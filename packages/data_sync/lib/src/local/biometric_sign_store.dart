// O-04 ③ 생체 서명 기록 · 읽기(설계 13 §8 R159).
//
// 🔴 저장처 = `command_inbox` 실행 행(종류 `ONBOARDING_BIOMETRIC_SIGN` · 지문 = 서명 대상 · 저널 id = 서약 판 id) —
//    스키마 무변경(서약 쓰기 `PLEDGE_WRITE` 선례). 시각 = 기기 시계(받은 시각 칸 — 서약 판의 신뢰 시각과 다르다).
// 🔴 같은 지문 = 한 번만 적는다(두 번째 = 효과 0) · 사실 = 지금 서명 대상 지문의 실행 행이 있나.

import 'package:core_engine/core_engine.dart' show kBiometricSignKind;
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

/// ③ 생체 서명 기록.
class SqliteBiometricSignStore {
  /// 만든다.
  SqliteBiometricSignStore(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// [digest] 에 서명한 실행 행이 있나.
  bool signed(String digest) => _db.select(
    'SELECT 1 FROM command_inbox WHERE kind = ? AND state = ? AND payload_digest = ? LIMIT 1',
    <Object?>[kBiometricSignKind, 'EXECUTED', digest],
  ).isNotEmpty;

  /// 🔴 서명을 적는다 — 이미 같은 지문이 있으면 쓰지 않고 false.
  bool record({
    required String commandId,
    required String digest,
    required String pledgeId,
  }) {
    if (signed(digest)) return false;
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      'VALUES (?, ?, ?, ?, ?, NULL, ?, NULL, NULL, NULL, ?)',
      <Object?>[
        commandId,
        kBiometricSignKind,
        _clock.nowUtc().toUtc().toIso8601String(),
        'EXECUTED',
        '실행됨',
        pledgeId,
        digest,
      ],
    );
    return true;
  }
}
