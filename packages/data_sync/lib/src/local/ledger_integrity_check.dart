// 정본 자가 무결성 검사 — `PRAGMA integrity_check` + 체인 자가 대조 → `LEDGER_INTEGRITY`(SPEC v2.40 04 §3-1 · 설계 13 §8 R58 C2~C5).
//
// 🔴 한 번 돌 때마다 `reconciliation_log` 1행(해시 모집단 밖 · E13e 가 마지막 `INTEGRITY_OK` 로 `checkpointLabel` 을 만든다).
// 🔴 불일치 = 같은 트랜잭션에서 `trading_block` `LEDGER_INTEGRITY` 세움(이미 서 있으면 그대로) · **일치해도 풀지 않는다**(해제 = X5-3 · E16).
// 🔴 재계산 불가(귀속 실패) = 불일치(fail-closed) — 다시 셀 수 없으면 일치를 말할 수 없다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock, FlagIds;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'ledger_hash_stamper.dart' show ledgerLinesByDay;

/// `reconciliation_log.action_taken`(R58 C4).
const String kIntegrityOk = 'INTEGRITY_OK';

/// `reconciliation_log.action_taken` — 불일치.
const String kIntegrityFailed = 'INTEGRITY_FAILED';

/// 검사 한 번의 보고.
class LedgerIntegrityReport {
  /// 보고를 만든다.
  const LedgerIntegrityReport({
    required this.verdict,
    required this.reconId,
    required this.flagRaised,
  });

  /// 판정.
  final LedgerIntegrityVerdict verdict;

  /// 남긴 `reconciliation_log.recon_id`.
  final String reconId;

  /// 🔴 이번에 `LEDGER_INTEGRITY` 를 새로 세웠나(이미 서 있었으면 false).
  final bool flagRaised;

  /// 제안 알림(불일치 = P0 · 계약 = E13i1).
  Set<String> get alerts =>
      verdict.ok ? const <String>{} : const <String>{kLedgerIntegrityAlertCode};
}

/// `PRAGMA integrity_check` 의 결과 줄.
List<String> sqliteIntegrityLines(Database db) => <String>[
  for (final Row r in db.select('PRAGMA integrity_check'))
    r.values.first.toString(),
];

/// 정본 자가 무결성 검사(R58 C1).
class LedgerIntegrityCheck {
  /// 검사를 만든다 — [sqliteIntegrity] = 시험 주입(기본 = `PRAGMA integrity_check`).
  LedgerIntegrityCheck(
    this._db, {
    required this._clock,
    List<String> Function(Database db)? sqliteIntegrity,
  }) : _sqliteIntegrity = sqliteIntegrity ?? sqliteIntegrityLines;

  final Database _db;
  final Clock _clock;
  final List<String> Function(Database db) _sqliteIntegrity;

  LedgerIntegrityVerdict _verdict() {
    final List<String> pragma = _sqliteIntegrity(_db);
    if (pragma.length != 1 || pragma.single != 'ok') {
      return const LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.sqliteIntegrity,
        daysChecked: 0,
      );
    }
    final List<StoredDayStamp> stamps = <StoredDayStamp>[
      for (final Row r in _db.select(
        'SELECT authored_date, day_hash, chain_hash, hash_format_version '
        'FROM ledger_daily_hash ORDER BY authored_date',
      ))
        StoredDayStamp(
          authoredDate: r['authored_date'] as String,
          dayHash: r['day_hash'] as String,
          chainHash: r['chain_hash'] as String,
          hashFormatVersion: r['hash_format_version'] as int,
        ),
    ];
    if (stamps.isEmpty) {
      return const LedgerIntegrityVerdict.ok(
        daysChecked: 0,
        checkedThrough: null,
      );
    }
    final Map<String, Map<String, List<String>>> lines;
    try {
      lines = ledgerLinesByDay(_db);
    } on LedgerHashError {
      return const LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.attribution,
        daysChecked: 0,
      );
    }
    return verifyLedgerChain(stamps, lines);
  }

  /// 한 번 돈다 — 한 트랜잭션(대조 · 기록 · 플래그).
  LedgerIntegrityReport run() {
    final String at = _clock.nowUtc().toUtc().toIso8601String();
    return inLedgerTransaction(_db, () {
      final LedgerIntegrityVerdict v = _verdict();
      final int n =
          _db.select(
                'SELECT COUNT(*) AS n FROM reconciliation_log WHERE run_at = ?',
                <Object?>[at],
              ).single['n']
              as int;
      final String reconId = 'li-$at#${n + 1}';
      _db.execute(
        'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
        'VALUES (?, ?, ?, ?, ?)',
        <Object?>[
          reconId,
          at,
          v.ok ? 1 : 0,
          v.summaryJson(),
          v.ok ? kIntegrityOk : kIntegrityFailed,
        ],
      );
      bool raised = false;
      if (!v.ok) {
        final bool active = _db.select(
          'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
          <Object?>[FlagIds.ledgerIntegrity],
        ).isNotEmpty;
        if (!active) {
          _db.execute(
            'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?) '
            'ON CONFLICT(flag_id) DO UPDATE SET set_at = excluded.set_at, '
            'reason = excluded.reason, origin_code = NULL, cleared_at = NULL, '
            'cleared_by = NULL, decision_id = NULL',
            <Object?>[
              FlagIds.ledgerIntegrity,
              at,
              '정본 자가 대조 불일치 — ${v.firstBadDate ?? '날짜 모름'} ${v.reason!.code} ($reconId)',
            ],
          );
          raised = true;
        }
      }
      return LedgerIntegrityReport(
        verdict: v,
        reconId: reconId,
        flagRaised: raised,
      );
    });
  }
}
