// 수동 개입 5단계 저장(M5-6 · 02 §2 `intervention_step` v2.40 · 설계 13 §8 R65 X3~X9).
//
// 🔴 append-only — 세션 상태는 행에서 다시 만든다(따로 저장하지 않는다).
// 🔴 살아 있는 세션은 한 번에 하나 · 실행 창 24h(발주자 결정 2026-11-05).
// 🔴 3단계 저널 연결의 «예산 소진» = 재량 예산 셈 하나(E13f1 · 지도 D24).
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).
// 🆕 E16j-a(01 §8 미결 217 ⓖ · 계약 v1.32 K252) — 3단계 사전 저널 쓰기(`writeJournalStage`): 살아 있는 세션 하나에 붙인다 ·
//    이탈 저널(사전 3칸 원문 · 저널 id = 호출자) + 3단계 통과 + 명령 행 = 한 트랜잭션 · 판정 = 기존 3단계 규칙 그대로(저널 연결 ·
//    예산 소진이면 메모 필요 — 이 제출에는 메모가 없어 거부) · 🆕 `decision_journal.kind` = `INTERVENTION_JOURNAL`(미결 220 ⓒ · 계약 v1.35 K294 · 옛 행 = NULL).
//    정정 · 새 기준점의 5단계 통과는 정정 트랜잭션 안에서 쓴다(`insertInterventionStep` · ledger_repair_store).

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, DecisionJournalKinds, SafetyActionId, SafetyCommonResultCodes;
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

/// 🆕 E16j-a — 저장 행 → 세션별 단계 행([sessionId] = 그 세션만).
Map<String, List<InterventionStep>> interventionStepRowsOf(
  Database db, {
  String? sessionId,
}) {
  final Map<String, List<InterventionStep>> out =
      <String, List<InterventionStep>>{};
  for (final Row r in db.select(
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

/// 🆕 E16j-a — 세션 상태 전부(id → 상태 · 닫힌 것 포함).
Map<String, InterventionState> interventionSessionsOf(Database db) =>
    <String, InterventionState>{
      for (final MapEntry<String, List<InterventionStep>> e
          in interventionStepRowsOf(db).entries)
        e.key: interventionStateOf(e.key, e.value)!,
    };

/// 🆕 E16j-a — 세션 하나의 상태(행 없음 = null).
InterventionState? interventionSessionOf(Database db, String sessionId) =>
    interventionStateOf(
      sessionId,
      interventionStepRowsOf(db, sessionId: sessionId)[sessionId] ??
          const <InterventionStep>[],
    );

/// 🆕 E16j-a — 마법사 대상([targetId])의 닫히지 않은 세션 가운데 가장 늦게 연 것의 id(없음 = null · 만료 판정 = 커밋 관문).
String? x5OpenSessionIdOf(Database db, String targetId) {
  final String prefix = x5SessionPrefixOf(targetId);
  InterventionState? best;
  for (final InterventionState s in interventionSessionsOf(db).values) {
    if (!s.sessionId.startsWith(prefix) || s.closed) continue;
    if (best == null ||
        s.steps.first.occurredAtUtc.isAfter(best.steps.first.occurredAtUtc) ||
        (s.steps.first.occurredAtUtc == best.steps.first.occurredAtUtc &&
            s.sessionId.compareTo(best.sessionId) > 0)) {
      best = s;
    }
  }
  return best?.sessionId;
}

/// 🆕 E16j-a — 단계 행 하나를 넣는다(🔴 부르는 쪽 트랜잭션 안 · 판정은 부르는 쪽).
void insertInterventionStep(
  Database db, {
  required String sessionId,
  required int stage,
  required DateTime atUtc,
  required InterventionOutcome outcome,
  String? decisionId,
}) => db.execute(
  'INSERT INTO intervention_step(session_id, stage, occurred_at, outcome, decision_id) '
  'VALUES (?, ?, ?, ?, ?)',
  <Object?>[
    sessionId,
    stage,
    atUtc.toUtc().toIso8601String(),
    outcome.wire,
    decisionId,
  ],
);

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

  Map<String, List<InterventionStep>> _rows({String? sessionId}) =>
      interventionStepRowsOf(_db, sessionId: sessionId);

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
    String kind = kInterventionCommandKind,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?)',
    <Object?>[
      commandId,
      kind,
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
      insertInterventionStep(
        _db,
        sessionId: sessionId,
        stage: stage,
        atUtc: now!,
        outcome: outcome,
        decisionId: decisionId,
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

  /// 🆕 E16j-a(01 §8 미결 217 ⓖ · 계약 v1.32 K252) — 3단계 사전 저널: 살아 있는 세션(없음 = 차례 밖) 하나에 이탈 저널을 붙여
  /// 3단계를 통과시킨다 — 저널 + 단계 + 명령 행 한 트랜잭션 · 거부 = 명령 행만(저널 0) · 같은 command_id = 처음 결과.
  ///
  /// 판정 차례 = 신뢰 시각 → 저널 id 겹침 → 기존 3단계 규칙(닫힘 · 차례 · 만료 · 저널 연결 — 예산 소진 = 메모 필요).
  InterventionStepResult writeJournalStage({
    required String commandId,
    required String payloadDigest,
    required String journalId,
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) {
    if (journalId.trim().isEmpty) {
      throw ArgumentError.value(journalId, 'journalId', '비었다');
    }
    return inLedgerTransaction(_db, () {
      final ResultSet again = _db.select(
        'SELECT state, reject_reason_code FROM command_inbox WHERE command_id = ?',
        <Object?>[commandId],
      );
      if (again.isNotEmpty) {
        return InterventionStepResult(
          executed: again.first['state'] == 'EXECUTED',
          replayed: true,
          reasonCode: again.first['reject_reason_code'] as String?,
        );
      }
      InterventionStepResult reject(String code) {
        _command(
          commandId,
          payloadDigest,
          rejectCode: code,
          kind: SafetyActionId.interventionJournal.wire,
        );
        return InterventionStepResult(executed: false, reasonCode: code);
      }

      final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
      if (now == null) {
        return reject(SafetyCommonResultCodes.trustedTimeUnknown);
      }
      if (_db.select(
        'SELECT 1 FROM decision_journal WHERE journal_id = ?',
        <Object?>[journalId],
      ).isNotEmpty) {
        return reject(SafetyCommonResultCodes.journalIdTaken);
      }
      InterventionState? live;
      for (final InterventionState s in interventionSessionsOf(_db).values) {
        if (s.liveAt(now)) live = s;
      }
      final String? code = interventionRejectCode(
        session: live,
        otherLiveSession: false,
        stage: kJournalStage,
        outcome: InterventionOutcome.passed,
        nowUtc: now,
        journalLinked: interventionJournalLinked(
          InterventionJournalFacts(
            isDeviation: true,
            rationaleBefore: rationaleBefore,
            expectedOutcome: expectedOutcome,
            ruleCited: ruleCited,
            note: null,
            alreadyUsed: false,
          ),
          budgetExhausted: discretionBudgetOf(
            _discretion.useDates(),
            kstDateText(now),
          ).exhausted,
        ),
        decisionId: journalId,
      );
      if (code != null) return reject(code);
      final String iso = now.toIso8601String();
      _db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
        'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
        'VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?, ?, NULL, ?)',
        <Object?>[
          journalId,
          kstDateText(now),
          P0sStrategyIds.deposit,
          jsonEncode(<String, Object?>{'session_id': live!.sessionId}),
          jsonEncode(<String, Object?>{'intervention_stage': kJournalStage}),
          rationaleBefore.trim(),
          expectedOutcome.trim(),
          ruleCited.trim(),
          // 🆕 미결 220 ⓒ(계약 v1.35 §44 K294) — 개입 3단계 저널 kind(옛 행 = NULL · 읽기 호환 · SAF-408 은 kind 를 보지 않는다).
          DecisionJournalKinds.interventionJournal,
          iso,
        ],
      );
      insertInterventionStep(
        _db,
        sessionId: live.sessionId,
        stage: kJournalStage,
        atUtc: now,
        outcome: InterventionOutcome.passed,
        decisionId: journalId,
      );
      _command(
        commandId,
        payloadDigest,
        decisionId: journalId,
        kind: SafetyActionId.interventionJournal.wire,
      );
      return const InterventionStepResult(executed: true);
    });
  }
}
