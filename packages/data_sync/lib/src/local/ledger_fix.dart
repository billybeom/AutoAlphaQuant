// `LEDGER_FIX` — X5 정정 트랜잭션의 뮤텍스(SPEC v2.40 04 §3-1 · 앱 계약 01 §3-5 · 설계 13 §8 R58 C6).
//
// 🔴 판정 집합 밖(04 §3-1 판정 SQL 은 이 플래그를 읽지 않는다) · 자동 · 사람 해제가 둘 다 없다 —
//    한 트랜잭션 안에서 세우고 지운다. 실패 = ROLLBACK 이라 행도 함께 사라진다. 다른 연결은 끝내 보지 못한다.
// 🔴 이미 서 있으면(중첩 · 남은 행) 거부 — 정정은 한 번에 하나다. 호출자 = X5-3 정정(E16).

import 'package:domain_contracts/domain_contracts.dart' show FlagIds;
import 'package:sqlite3/sqlite3.dart';

/// 정정을 시작할 수 없다(다른 정정 · 열린 트랜잭션 · 남은 행).
class LedgerFixBusy implements Exception {
  /// 거부를 만든다.
  const LedgerFixBusy(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'LedgerFixBusy: $reason';
}

/// 지금 `LEDGER_FIX` 행이 보이나(이 연결의 시야).
bool ledgerFixVisible(Database db) => db.select(
  'SELECT 1 FROM trading_block WHERE flag_id = ?',
  <Object?>[FlagIds.ledgerFix],
).isNotEmpty;

/// [body] 를 `LEDGER_FIX` 아래 한 트랜잭션으로 돌린다(R58 C6) — [body] 는 동기여야 한다.
T withLedgerFix<T>(
  Database db, {
  required String reason,
  required DateTime atUtc,
  required T Function() body,
}) {
  if (!db.autocommit) throw const LedgerFixBusy('이미 트랜잭션 안이다');
  db.execute('BEGIN IMMEDIATE');
  try {
    if (ledgerFixVisible(db)) throw const LedgerFixBusy('LEDGER_FIX 행이 남아 있다');
    db.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[FlagIds.ledgerFix, atUtc.toUtc().toIso8601String(), reason],
    );
    final T out = body();
    db.execute('DELETE FROM trading_block WHERE flag_id = ?', <Object?>[
      FlagIds.ledgerFix,
    ]);
    db.execute('COMMIT');
    return out;
  } catch (_) {
    if (!db.autocommit) db.execute('ROLLBACK');
    rethrow;
  }
}
