// 수동 개입 5단계 저장(M5-6 · 02 §2 `intervention_step` v2.40 · 설계 13 §8 R65 X3~X9).
//
// 🔴 append-only — 세션 상태는 행에서 다시 만든다(따로 저장하지 않는다).
// 🔴 살아 있는 세션은 한 번에 하나 · 실행 창 24h(발주자 결정 2026-11-05).
// 🔴 3단계 저널 연결의 «예산 소진» = 재량 예산 셈 하나(E13f1 · 지도 D24).
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'discretion_store.dart' show SqliteDiscretionStore;

/// `command_inbox.kind`.
const String kInterventionCommandKind = 'INTERVENTION_STEP';

const String _executed = '실행됨';
const String _executedClosed = '실행됨 — 세션 닫힘';

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

/// 한 단계 쓰기 결과.
class InterventionStepResult {
  /// 결과를 만든다.
  const InterventionStepResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
    this.closed = false,
  });

  /// 기록됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;

  /// 이 단계가 세션을 닫았나.
  final bool closed;
}

/// 수동 개입 저장(R65).
class SqliteInterventionStore {
  /// 저장을 만든다 — `clock` = 명령 접수 시각(기기) · `trusted` = 단계 시각 · 냉각 · 실행 창.
  SqliteInterventionStore(
    this._db, {
    required Clock clock,
    required TrustedClock trusted,
  }) : _clock = clock,
       _trusted = trusted,
       _discretion = SqliteDiscretionStore(_db, clock: clock, trusted: trusted);

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final SqliteDiscretionStore _discretion;

  Map<String, List<InterventionStep>> _rows({String? sessionId}) {
    final Map<String, List<InterventionStep>> out =
        <String, List<InterventionStep>>{};
    for (final Row r in _db.select(
      sessionId == null
          ? 'SELECT * FROM intervention_step'
          : 'SELECT * FROM intervention_step WHERE session_id = ?',
      <Object?>[?sessionId],
    )) {
      (out[r['session_id'] as String] ??= <InterventionStep>[]).add(
        InterventionStep(
          stage: r['stage'] as int,
          occurredAtUtc: _instant(r['occurred_at'] as String),
          outcome: InterventionOutcome.fromWire(r['outcome'] as String),
          decisionId: r['decision_id'] as String?,
        ),
      );
    }
    return out;
  }

  /// 세션 상태 — 행 없음 = null.
  InterventionState? session(String sessionId) => interventionStateOf(
    sessionId,
    _rows(sessionId: sessionId)[sessionId] ?? const <InterventionStep>[],
  );

  /// 닫히지 않은 세션 가운데 가장 늦게 연 것(만료 여부는 상태가 신뢰 시각으로 판정) — 없으면 null.
  InterventionState? latestOpenSession() {
    InterventionState? best;
    for (final MapEntry<String, List<InterventionStep>> e in _rows().entries) {
      final InterventionState s = interventionStateOf(e.key, e.value)!;
      if (s.closed) continue;
      if (best == null ||
          s.steps.first.occurredAtUtc.isAfter(best.steps.first.occurredAtUtc) ||
          (s.steps.first.occurredAtUtc == best.steps.first.occurredAtUtc &&
              s.sessionId.compareTo(best.sessionId) > 0)) {
        best = s;
      }
    }
    return best;
  }

  void _command(
    String commandId,
    String digest, {
    String? rejectCode,
    String? decisionId,
    bool closed = false,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?)',
    <Object?>[
      commandId,
      kInterventionCommandKind,
      _clock.nowUtc().toUtc().toIso8601String(),
      rejectCode == null ? 'EXECUTED' : 'REJECTED',
      rejectCode == null
          ? (closed ? _executedClosed : _executed)
          : '거부됨 — $rejectCode',
      rejectCode,
      decisionId,
      digest,
    ],
  );

  InterventionJournalFacts? _journal(String? decisionId) {
    if (decisionId == null || decisionId.trim().isEmpty) return null;
    final ResultSet rs = _db.select(
      'SELECT is_deviation, rationale_before, expected_outcome, rule_cited, note FROM decision_journal WHERE journal_id = ?',
      <Object?>[decisionId],
    );
    if (rs.isEmpty) return null;
    return InterventionJournalFacts(
      isDeviation: rs.first['is_deviation'] == 1,
      rationaleBefore: rs.first['rationale_before'] as String?,
      expectedOutcome: rs.first['expected_outcome'] as String?,
      ruleCited: rs.first['rule_cited'] as String?,
      note: rs.first['note'] as String?,
      // 이 세션의 3단계 통과 행은 아직 없다(있으면 3단계는 이미 차례 밖) — 있는 행 = 다른 세션.
      alreadyUsed: _db.select(
        "SELECT 1 FROM intervention_step WHERE stage = ? AND outcome = 'PASSED' AND decision_id = ?",
        <Object?>[kJournalStage, decisionId],
      ).isNotEmpty,
    );
  }

  /// 한 단계를 쓴다(R65 X1~X8).
  InterventionStepResult advance({
    required String commandId,
    required String payloadDigest,
    required String sessionId,
    required int stage,
    required InterventionOutcome outcome,
    String? decisionId,
  }) {
    final ResultSet again = _db.select(
      'SELECT state, state_label, reject_reason_code FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (again.isNotEmpty) {
      return InterventionStepResult(
        executed: again.first['state'] == 'EXECUTED',
        replayed: true,
        reasonCode: again.first['reject_reason_code'] as String?,
        closed: again.first['state_label'] == _executedClosed,
      );
    }
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final Map<String, List<InterventionStep>> all = _rows();
    final InterventionState? s = interventionStateOf(
      sessionId,
      all[sessionId] ?? const <InterventionStep>[],
    );
    // 살아 있는 세션이 있나 — 이 세션이 이미 있으면 1단계는 차례 밖이라 자기를 빼지 않아도 같다.
    final bool otherLive =
        now != null &&
        all.entries.any(
          (MapEntry<String, List<InterventionStep>> e) =>
              interventionStateOf(e.key, e.value)!.liveAt(now),
        );
    // 3단계 통과일 때만 저널 · 예산을 본다.
    bool linked = false;
    if (now != null &&
        stage == kJournalStage &&
        outcome == InterventionOutcome.passed) {
      linked = interventionJournalLinked(
        _journal(decisionId),
        budgetExhausted: discretionBudgetOf(
          _discretion.useDates(),
          kstDateText(now),
        ).exhausted,
      );
    }
    final String? code = interventionRejectCode(
      session: s,
      otherLiveSession: otherLive,
      stage: stage,
      outcome: outcome,
      nowUtc: now,
      journalLinked: linked,
      decisionId: decisionId,
    );
    if (code != null) {
      _command(
        commandId,
        payloadDigest,
        rejectCode: code,
        decisionId: decisionId,
      );
      return InterventionStepResult(executed: false, reasonCode: code);
    }
    final bool closes =
        outcome != InterventionOutcome.passed || stage == kExecuteStage;
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO intervention_step(session_id, stage, occurred_at, outcome, decision_id) '
        'VALUES (?, ?, ?, ?, ?)',
        <Object?>[
          sessionId,
          stage,
          now!.toIso8601String(),
          outcome.wire,
          decisionId,
        ],
      );
      _command(
        commandId,
        payloadDigest,
        decisionId: decisionId,
        closed: closes,
      );
    });
    return InterventionStepResult(executed: true, closed: closes);
  }
}
