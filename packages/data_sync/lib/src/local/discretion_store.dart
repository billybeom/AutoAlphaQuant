// 재량 예산 원장 쓰기 · 예산 셈 읽기(SAF-409 · FR-709 · 04 §1 v2.11 ④ · 05 AC-S18 · 설계 13 §8 R64 W3~W6).
//
// 🔴 횟수를 DB 가 센다 — 조정은 `discretion_adjustment` 행이 있어야 조정이다.
// 🔴 v1 은 이 창구를 부르는 곳이 없다(지도 D5 — `/adjust_exposure` 안 만듦) — 기계(원장 · GV-40e)만 있다.
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).
// 🔴 시각 = 신뢰 시각 · 모르면 거부(조정 0) · 롤링 셈 = 한국 날짜(지도 D23 · X21).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// `command_inbox.kind`.
const String kDiscretionCommandKind = 'DISCRETION_ADJUST';

const String _rejectedPrefix = '거부됨 — ';

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// 🔴 오프셋 없는 시각 = 형식 오류(기기 지역 시각으로 읽지 않는다).
DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

/// 재량 조정 요청 결과.
class DiscretionResult {
  /// 결과를 만든다.
  const DiscretionResult({
    required this.executed,
    this.replayed = false,
    this.reasonCodes = const <String>[],
    this.adjustmentId,
  });

  /// 반영됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 사유(오름차순 — GV-40e e9).
  final List<String> reasonCodes;

  /// 반영된 조정 id.
  final String? adjustmentId;
}

/// 재량 예산 원장(R64).
class SqliteDiscretionStore {
  /// 원장을 만든다 — `clock` = 명령 접수 시각(기기) · `trusted` = 조정 시각 · 롤링 셈.
  SqliteDiscretionStore(
    this._db, {
    required this._clock,
    required this._trusted,
  });

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;

  void _command(
    String commandId,
    String digest, {
    List<String> rejectCodes = const <String>[],
    String? decisionId,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?)',
    <Object?>[
      commandId,
      kDiscretionCommandKind,
      _clock.nowUtc().toUtc().toIso8601String(),
      rejectCodes.isEmpty ? 'EXECUTED' : 'REJECTED',
      rejectCodes.isEmpty
          ? '실행됨'
          : '$_rejectedPrefix${rejectCodes.join(' · ')}',
      rejectCodes.isEmpty ? null : rejectCodes.first,
      decisionId,
      digest,
    ],
  );

  /// 예산 셈의 원천(한국 날짜 · R64 W6) — 🔵 X7 예산 사건 2종은 E18 이 같은 목록에 더한다.
  List<String> useDates() => <String>[
    for (final Row r in _db.select(
      'SELECT applied_at FROM discretion_adjustment',
    ))
      kstDateText(_instant(r['applied_at'] as String)),
  ];

  /// 재량 예산(R64 W6) — 신뢰 시각 모름 = null.
  DiscretionBudget? budget() {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) return null;
    return discretionBudgetOf(useDates(), kstDateText(now));
  }

  DiscretionJournalFacts? _journal(String? decisionId) {
    if (decisionId == null || decisionId.trim().isEmpty) return null;
    final ResultSet rs = _db.select(
      'SELECT kind, rationale_before, expected_outcome, rule_cited FROM decision_journal WHERE journal_id = ?',
      <Object?>[decisionId],
    );
    if (rs.isEmpty) return null;
    return DiscretionJournalFacts(
      kind: rs.first['kind'] as String?,
      rationaleBefore: rs.first['rationale_before'] as String?,
      expectedOutcome: rs.first['expected_outcome'] as String?,
      ruleCited: rs.first['rule_cited'] as String?,
      alreadyUsed: _db.select(
        'SELECT 1 FROM discretion_adjustment WHERE decision_id = ?',
        <Object?>[decisionId],
      ).isNotEmpty,
    );
  }

  /// 재량 조정을 요청한다(SAF-409 · R64 W2~W5).
  DiscretionResult requestAdjustment({
    required String commandId,
    required String payloadDigest,
    required double deltaPct,
    required String? decisionId,
  }) {
    final ResultSet again = _db.select(
      'SELECT state, state_label, decision_id FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (again.isNotEmpty) {
      final bool ok = again.first['state'] == 'EXECUTED';
      final String label = again.first['state_label'] as String;
      final String? id = again.first['decision_id'] as String?;
      return DiscretionResult(
        executed: ok,
        replayed: true,
        reasonCodes: ok || !label.startsWith(_rejectedPrefix)
            ? const <String>[]
            : label.substring(_rejectedPrefix.length).split(' · '),
        adjustmentId: ok ? 'DA-$id' : null,
      );
    }
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      const List<String> codes = <String>[DiscretionCodes.trustedTimeUnknown];
      _command(
        commandId,
        payloadDigest,
        rejectCodes: codes,
        decisionId: decisionId,
      );
      return const DiscretionResult(executed: false, reasonCodes: codes);
    }
    final DiscretionJournalFacts? journal = _journal(decisionId);
    final DiscretionJudgement j = judgeDiscretion(
      deltaPct: deltaPct,
      journalLinked: discretionJournalLinked(journal),
      priorUseDates: useDates(),
      today: kstDateText(now),
    );
    if (!j.applies) {
      _command(
        commandId,
        payloadDigest,
        rejectCodes: j.rejectReasons,
        decisionId: decisionId,
      );
      return DiscretionResult(executed: false, reasonCodes: j.rejectReasons);
    }
    final String id = 'DA-$decisionId';
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO discretion_adjustment(adjustment_id, applied_at, delta_pct, decision_id, reason) '
        'VALUES (?, ?, ?, ?, ?)',
        <Object?>[
          id,
          now.toUtc().toIso8601String(),
          deltaPct,
          decisionId,
          journal!.rationaleBefore!.trim(),
        ],
      );
      _command(commandId, payloadDigest, decisionId: decisionId);
    });
    return DiscretionResult(executed: true, adjustmentId: id);
  }
}
