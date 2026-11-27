// 🆕 E11q-j4s — `J-4` blind 리뷰 채점 기록기(`BLIND_REVIEW_SCORE` 명령 · SPEC v2.47 02 §2-6 `blind_review_score` · §3-3 ① ·
// 06 M1-25 ① ⑤ · 01 §16 K10 · K12 · K24 · 설계 13 §8 R257).
//
// 🔴 한 트랜잭션 · 판정 차례(02 §3-3 ①): 같은 명령 다시 = 처음 접수(보관 행은 무결성이 풀린 뒤 다시 받으면 집행) →
//    `LEDGER_INTEGRITY` = 보관(원장 쓰기 0) → 이미 채점 = `ALREADY_SCORED`(답보다 먼저 · 먼저 집행된 채점이 이긴다) →
//    카드 = 지금 원장에서 엔진이 다시 지은 큐 카드(화면이 본 카드를 믿지 않는다 · 대상 아님 · sim 원장 K24 = `ANSWERS_INVALID`) →
//    답 판정 = core `blindReviewRejectOf` → 통과 = 채점 1행 + 수신함 `EXECUTED` 1행.
// 🔴 거부 · 보관 = 수신함 1행뿐(원장 쓰기 0) · 수신함 `decision_id` = NULL(채점은 결정을 만들지 않는다 — 결정 키는 채점 표가 가진다).
// 🔴 신뢰 시각 비의존(J-3 K299 선례) — 시각 = 기기 시계 UTC · 선후 = PK 와 트랜잭션 차례.
// 🔴 그 갱신에서 그 결정 = 큐 · J-1 배지에서 빠지고 카드 1건 창구에 결과가 실린다(같은 원장 · 감시 표 `blind_review_score`).

import 'package:core_engine/core_engine.dart'
    show
        blindReviewAnswersJsonOf,
        blindReviewProcessScoreOf,
        blindReviewQueueOf,
        blindReviewRejectOf,
        blindReviewStateLabelOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        BlindReviewCard,
        BlindReviewRejectCodes,
        BlindReviewScore,
        Clock,
        CommandKind,
        CommandState,
        FlagIds,
        OperatingMode,
        RunMode;
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet, Row;

import '../market/market_store.dart' show inLedgerTransaction;
import 'journal_source.dart' show SqliteJournalSource;

/// J-4 제출 결과(접수증 재료 — 글자 = 엔진 `blindReviewStateLabelOf`).
class BlindReviewWriteResult {
  /// 만든다.
  const BlindReviewWriteResult({
    required this.state,
    required this.stateLabel,
    this.rejectCode,
    this.replayed = false,
  });

  /// 접수 상태(EXECUTED · REJECTED · HELD_FOR_INTEGRITY).
  final CommandState state;

  /// 접수증 문장(엔진).
  final String stateLabel;

  /// 거부 코드(`BlindReviewRejectCodes`).
  final String? rejectCode;

  /// 같은 명령 id 의 처음 접수 그대로인가.
  final bool replayed;
}

/// J-4 채점 기록기(원장 한 파일 · 카드 = 같은 원장의 [SqliteJournalSource]).
class SqliteBlindReviewStore {
  /// 만든다 — [source] = 같은 원장의 일지 원천(카드를 다시 짓는다) · [clock] = 기기 시계.
  SqliteBlindReviewStore(this._db, {required this.source, required this.clock});

  final Database _db;

  /// 같은 원장의 일지 원천.
  final SqliteJournalSource source;

  /// 기기 시계.
  final Clock clock;

  /// `LEDGER_INTEGRITY` 가 서 있나(보관 조건).
  bool integrityBroken() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// 그 결정이 이미 채점됐나.
  bool scored(String decisionId) => _db.select(
    'SELECT 1 FROM blind_review_score WHERE decision_id = ?',
    <Object?>[decisionId],
  ).isNotEmpty;

  /// 🔴 제출 — 한 트랜잭션(판정 · 채점 · 접수).
  BlindReviewWriteResult submit({
    required String commandId,
    required String payloadDigest,
    required BlindReviewScore score,
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
      return BlindReviewWriteResult(
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
        runMode.wire,
        operatingMode.wire,
        leaseEpoch,
        payloadDigest,
        commandId,
      ];
      if (wasHeld) {
        _db.execute(
          'UPDATE command_inbox SET ingested_at = ?, state = ?, state_label = ?, reject_reason_code = ?, '
          'decision_id = NULL, run_mode = ?, operating_mode = ?, lease_epoch = ?, payload_digest = ? '
          'WHERE command_id = ?',
          args,
        );
      } else {
        _db.execute(
          'INSERT INTO command_inbox(ingested_at, state, state_label, reject_reason_code, decision_id, '
          'run_mode, operating_mode, lease_epoch, payload_digest, command_id, kind) '
          'VALUES (?, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?)',
          <Object?>[...args, CommandKind.blindReviewScore.wire],
        );
      }
    }

    BlindReviewWriteResult rejected(String code) {
      final String label = blindReviewStateLabelOf(code);
      inbox(CommandState.rejected, label, code);
      return BlindReviewWriteResult(
        state: CommandState.rejected,
        stateLabel: label,
        rejectCode: code,
      );
    }

    if (integrityBroken()) {
      final String label = blindReviewStateLabelOf(null, held: true);
      inbox(CommandState.heldForIntegrity, label, null);
      return BlindReviewWriteResult(
        state: CommandState.heldForIntegrity,
        stateLabel: label,
      );
    }
    if (scored(score.decisionId)) {
      return rejected(BlindReviewRejectCodes.alreadyScored);
    }
    BlindReviewCard? card;
    for (final BlindReviewCard c in blindReviewQueueOf(source.facts()).rows) {
      if (c.decisionId == score.decisionId) card = c;
    }
    final String? code = card == null
        ? BlindReviewRejectCodes.answersInvalid
        : blindReviewRejectOf(card, score, alreadyScored: false);
    if (code != null) return rejected(code);
    _db.execute(
      'INSERT INTO blind_review_score(decision_id, command_id, answers_json, process_score, scored_at) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>[
        card!.decisionId,
        commandId,
        blindReviewAnswersJsonOf(score.answers),
        blindReviewProcessScoreOf(score.answers),
        now.toIso8601String(),
      ],
    );
    final String label = blindReviewStateLabelOf(null);
    inbox(CommandState.executed, label, null);
    return BlindReviewWriteResult(
      state: CommandState.executed,
      stateLabel: label,
    );
  });
}
