// 🆕 미결 220 ⓔⓕ — `J-3` 사전 저널 쓰기 저장소(`JOURNAL_DRAFT` 명령 · 계약 v1.35 01 §44 K296 ~ K300 · 설계 13 §8 R245).
//
// 🔴 키 = 저널 id · 갈래 = 엔진(core `journalDraftTargetOf` · `journalDraftRejectOf`): 채우기 = 빈 칸만(채워진 칸 · kind 유지 ·
//    SAF-408 자동 해제 — 안전 읽기 모델이 같은 원장을 다시 읽는다) · 새 행 = 키에 실린 목적(kind · `is_deviation` 재량 1 · 서약 편집 0).
// 🔴 저널 쓰기와 접수(`command_inbox`)는 한 트랜잭션(고아 저널 0 · K299) · 거부 = 접수 행 1개뿐(원장 쓰기 0).
// 🔴 멱등 = 같은 `command_id` 재제출 = 같은 접수(기존 수신함 규칙) — 단 보관(`HELD_FOR_INTEGRITY`) 행은 무결성 표시가 풀린 뒤
//    같은 명령을 다시 받으면 그때 집행한다(§3-8 «접수하되 보관 · 해제 뒤 집행» · 그 행을 고쳐 쓴다).
// 🔴 `LEDGER_INTEGRITY` 서 있음 = 보관(원장 쓰기 0 · 초안은 기기에 남는다 — 정기 실사 · 실입금 등록 선례).
// 🔴 신뢰 시각 비의존(K299) — 시각 = 기기 시계 UTC · 저널 `trade_date` = 한국 날.

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart'
    show
        JournalDraftFill,
        JournalDraftNew,
        JournalDraftTarget,
        P0sStrategyIds,
        journalDraftRejectOf,
        journalDraftStateLabelOf,
        journalDraftTargetOf,
        kstDateText;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        CommandKind,
        CommandState,
        DecisionJournalKinds,
        FlagIds,
        JournalDraft,
        OperatingMode,
        RunMode;
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet, Row;

import '../market/market_store.dart' show inLedgerTransaction;

/// J-3 제출 결과(접수증 재료 — 글자 = 엔진 `journalDraftStateLabelOf`).
class JournalDraftWriteResult {
  /// 만든다.
  const JournalDraftWriteResult({
    required this.state,
    required this.stateLabel,
    this.rejectCode,
    this.replayed = false,
  });

  /// 접수 상태(EXECUTED · REJECTED · HELD_FOR_INTEGRITY).
  final CommandState state;

  /// 접수증 문장(엔진).
  final String stateLabel;

  /// 거부 코드(`JournalDraftRejectCodes`).
  final String? rejectCode;

  /// 같은 명령 id 의 처음 접수 그대로인가.
  final bool replayed;
}

/// J-3 저장소(원장 한 파일).
class SqliteJournalDraftStore {
  /// 만든다 — [clock] = 기기 시계(K299).
  SqliteJournalDraftStore(this._db, {required this.clock});

  final Database _db;

  /// 기기 시계.
  final Clock clock;

  /// 키의 저널 행(없음 = null — 빈 칸 = null 그대로).
  JournalDraftFill? rowOf(String key) {
    final ResultSet rs = _db.select(
      'SELECT is_deviation, kind, rationale_before, expected_outcome, rule_cited '
      'FROM decision_journal WHERE journal_id = ?',
      <Object?>[key],
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    return JournalDraftFill(
      key,
      isDeviation: (r['is_deviation'] as int) != 0,
      kind: r['kind'] as String?,
      rationaleBefore: r['rationale_before'] as String?,
      expectedOutcome: r['expected_outcome'] as String?,
      ruleCited: r['rule_cited'] as String?,
    );
  }

  /// 키 → 갈래(채우기 · 새 행 · 모름 = null).
  JournalDraftTarget? targetOf(String key) =>
      journalDraftTargetOf(key, rowOf(key));

  /// `LEDGER_INTEGRITY` 가 서 있나(보관 조건).
  bool integrityBroken() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// 🔴 제출 — 한 트랜잭션(판정 · 저널 · 접수).
  JournalDraftWriteResult submit({
    required String commandId,
    required String payloadDigest,
    required JournalDraft draft,
    required RunMode runMode,
    required OperatingMode operatingMode,
    int? leaseEpoch,
  }) => inLedgerTransaction(_db, () {
    final ResultSet prior = _db.select(
      'SELECT state, state_label, reject_reason_code FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    // 🆕 R280(K319) — `M5-13` 일괄 확정이 `RECEIVED` 로 옮긴 보관 행도 같은 명령이 다시 오면 그때 집행한다(보통 소비 규칙).
    final bool wasHeld =
        prior.isNotEmpty &&
        (prior.first['state'] == CommandState.heldForIntegrity.wire ||
            prior.first['state'] == CommandState.received.wire);
    if (prior.isNotEmpty && (!wasHeld || integrityBroken())) {
      final Row p = prior.first;
      return JournalDraftWriteResult(
        state: CommandState.values.firstWhere(
          (CommandState s) => s.wire == p['state'],
        ),
        stateLabel: p['state_label'] as String,
        rejectCode: p['reject_reason_code'] as String?,
        replayed: true,
      );
    }
    final DateTime now = clock.nowUtc().toUtc();
    void inbox(CommandState state, String label, String? code) {
      final List<Object?> args = <Object?>[
        now.toIso8601String(),
        state.wire,
        label,
        code,
        code == null && state == CommandState.executed
            ? draft.decisionId
            : null,
        runMode.wire,
        operatingMode.wire,
        leaseEpoch,
        payloadDigest,
        commandId,
      ];
      if (wasHeld) {
        _db.execute(
          'UPDATE command_inbox SET ingested_at = ?, state = ?, state_label = ?, reject_reason_code = ?, '
          'decision_id = ?, run_mode = ?, operating_mode = ?, lease_epoch = ?, payload_digest = ? '
          'WHERE command_id = ?',
          args,
        );
      } else {
        _db.execute(
          'INSERT INTO command_inbox(ingested_at, state, state_label, reject_reason_code, decision_id, '
          'run_mode, operating_mode, lease_epoch, payload_digest, command_id, kind) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[...args, CommandKind.journalDraft.wire],
        );
      }
    }

    if (integrityBroken()) {
      final String label = journalDraftStateLabelOf(held: true);
      inbox(CommandState.heldForIntegrity, label, null);
      return JournalDraftWriteResult(
        state: CommandState.heldForIntegrity,
        stateLabel: label,
      );
    }
    final JournalDraftTarget? target = targetOf(draft.decisionId);
    final String? code = journalDraftRejectOf(target, draft);
    if (code != null) {
      final String label = journalDraftStateLabelOf(rejectCode: code);
      inbox(CommandState.rejected, label, code);
      return JournalDraftWriteResult(
        state: CommandState.rejected,
        stateLabel: label,
        rejectCode: code,
      );
    }
    final String rationale = draft.rationaleBefore.trim();
    final String expected = draft.expectedOutcome.trim();
    final String? note = (draft.note ?? '').trim().isEmpty
        ? null
        : draft.note!.trim();
    switch (target!) {
      case JournalDraftFill():
        // 빈 칸만 채운다 — 채워진 칸 · kind · 이탈 여부는 그대로(K297 ⓐ).
        _db.execute(
          'UPDATE decision_journal SET rationale_before = COALESCE(rationale_before, ?), '
          'expected_outcome = COALESCE(expected_outcome, ?), rule_cited = COALESCE(rule_cited, ?), '
          'note = COALESCE(note, ?) WHERE journal_id = ?',
          <Object?>[
            rationale,
            expected,
            draft.ruleCited,
            note,
            draft.decisionId,
          ],
        );
      case JournalDraftNew(:final String purpose, :final bool isDeviation):
        // 🔴 kind = 계약 사전의 새 행 목적만(K294 · K297 — 엔진 키 해석이 이미 거른다 · 어긋나면 되돌림).
        if (!DecisionJournalKinds.draftPurposes.contains(purpose)) {
          throw StateError('J-3 새 행 목적 아님: $purpose');
        }
        _db.execute(
          'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
          'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            draft.decisionId,
            kstDateText(now),
            P0sStrategyIds.deposit,
            jsonEncode(<String, Object?>{'journal_draft_purpose': purpose}),
            jsonEncode(<String, Object?>{'journal_draft': 'WRITTEN'}),
            isDeviation ? 1 : 0,
            rationale,
            expected,
            draft.ruleCited,
            purpose,
            note,
            now.toIso8601String(),
          ],
        );
    }
    final String label = journalDraftStateLabelOf();
    inbox(CommandState.executed, label, null);
    return JournalDraftWriteResult(
      state: CommandState.executed,
      stateLabel: label,
    );
  });
}
