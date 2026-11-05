// STOPPED 결정 A/B/C 기록 · 결정 B 집행(SPEC v2.40 04 §2 · 03_운영 §6-4b · 설계 13 §8 R61 T1~T7).
//
// 🔴 판정 재료 = 저장된 스냅숏 역사를 **지금** 다시 재생한 결과(상태를 따로 두지 않는다 · F8).
// 🔴 모든 결정 = 한 트랜잭션: 저널(STOPPED_DECISION) + 이 에피소드 SEV1 닫음 + 명령 기록.
//    B 만 더해: `breaker_release`(오늘 · 다음 스냅숏부터 HALTED) + RETIRED 아닌 전 전략 CANDIDATE(상한 0) + 램프 L1.
//    A · C = 레벨 · 전략 · 램프 무변경(엔진은 STOPPED 유지 · 실행은 사람이 증권사 앱에서).
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/daily_jobs.dart' show SqliteEquitySnapshotStore, regimeLookupOf;
import '../market/market_store.dart' show inLedgerTransaction;

/// `decision_journal.kind` · `command_inbox.kind`.
const String kStoppedDecisionKind = 'STOPPED_DECISION';

/// 저널 id 중복.
const String kStoppedJournalTaken = 'JOURNAL_ID_TAKEN';

/// 결정 결과.
class StoppedDecisionResult {
  /// 결과를 만든다.
  const StoppedDecisionResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
    this.decisionId,
    this.releaseId,
  });

  /// 실행됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;

  /// 저널 id.
  final String? decisionId;

  /// 결정 B 의 `breaker_release.release_id`.
  final String? releaseId;
}

/// 지금 STOPPED 에피소드의 모습.
class StoppedEpisode {
  /// 모습을 만든다.
  const StoppedEpisode({required this.replay, this.entryDate});

  /// 지금 다시 재생한 결과.
  final BreakerReplay replay;

  /// 진입 날(STOPPED 가 아니면 null).
  final String? entryDate;
}

/// STOPPED 결정 저장(R61).
class SqliteStoppedDecisionStore {
  /// 저장을 만든다.
  SqliteStoppedDecisionStore(
    this._db, {
    required this._mode,
    required this._clock,
    this._config,
  });

  final Database _db;
  final RunMode _mode;
  final Clock _clock;
  final BreakerConfig? _config;

  /// 지금 에피소드(R61 T1) — 진입 날 = 마지막 행에서 유지 봉만큼 앞.
  StoppedEpisode episode() {
    final List<EquitySnapshotRow> rows = SqliteEquitySnapshotStore(
      _db,
      mode: _mode,
    ).before('9999-12-31');
    final BreakerReplay r = replayStoredBreaker(
      rows,
      regimeLookupOf(_db),
      releaseDates: <String>[
        for (final Row x in _db.select(
          'SELECT trade_date FROM breaker_release ORDER BY trade_date',
        ))
          x['trade_date'] as String,
      ],
      config: _config,
    );
    final bool stopped = r.state.level == BreakerLevel.stopped;
    return StoppedEpisode(
      replay: r,
      entryDate: stopped ? rows[rows.length - 1 - r.heldBars].tradeDate : null,
    );
  }

  StoppedDecisionResult? _replay(String commandId) {
    final ResultSet rs = _db.select(
      'SELECT state, reject_reason_code, decision_id FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (rs.isEmpty) return null;
    final String? decisionId = rs.first['decision_id'] as String?;
    final ResultSet rel = _db.select(
      'SELECT release_id FROM breaker_release WHERE decision_id = ?',
      <Object?>[decisionId],
    );
    return StoppedDecisionResult(
      executed: rs.first['state'] == 'EXECUTED',
      replayed: true,
      reasonCode: rs.first['reject_reason_code'] as String?,
      decisionId: decisionId,
      releaseId: rel.isEmpty ? null : rel.first['release_id'] as String,
    );
  }

  void _command(
    String commandId,
    String payloadDigest, {
    String? rejectCode,
    String? decisionId,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?)',
    <Object?>[
      commandId,
      kStoppedDecisionKind,
      _clock.nowUtc().toUtc().toIso8601String(),
      rejectCode == null ? 'EXECUTED' : 'REJECTED',
      rejectCode == null ? '실행됨' : '거부됨 — $rejectCode',
      rejectCode,
      decisionId,
      payloadDigest,
    ],
  );

  StoppedDecisionResult _reject(String commandId, String digest, String code) {
    _command(commandId, digest, rejectCode: code);
    return StoppedDecisionResult(executed: false, reasonCode: code);
  }

  bool _postmortemRecorded(String entryDate) {
    final ResultSet rs = _db.select(
      'SELECT postmortem FROM incidents WHERE incident_id = ?',
      <Object?>[stoppedIncidentIdOf(entryDate)],
    );
    final Object? pm = rs.isEmpty ? null : rs.first['postmortem'];
    return pm is String && pm.trim().isNotEmpty;
  }

  bool _decisionMade(String entryDate) => _db.select(
    'SELECT 1 FROM decision_journal WHERE kind = ? AND trade_date >= ?',
    <Object?>[kStoppedDecisionKind, entryDate],
  ).isNotEmpty;

  /// 결정을 받는다(R61 T2~T5).
  StoppedDecisionResult decide({
    required String commandId,
    required String payloadDigest,
    required StoppedDecisionAnswers answers,
  }) {
    final StoppedDecisionResult? again = _replay(commandId);
    if (again != null) return again;
    final StoppedEpisode ep = episode();
    final String? entry = ep.entryDate;
    final StoppedDecisionVerdict v = judgeStoppedDecision(
      answers,
      replay: ep.replay,
      decisionAlreadyMade: entry != null && _decisionMade(entry),
      postmortemRecorded: entry != null && _postmortemRecorded(entry),
      config: _config,
    );
    if (!v.allowed) return _reject(commandId, payloadDigest, v.code!);
    final String jid = answers.decisionId.trim();
    if (_db.select(
      'SELECT 1 FROM decision_journal WHERE journal_id = ?',
      <Object?>[jid],
    ).isNotEmpty) {
      return _reject(commandId, payloadDigest, kStoppedJournalTaken);
    }
    final DateTime now = _clock.nowUtc().toUtc();
    final String at = now.toIso8601String();
    final String today = kstDateText(now);
    final String incidentId = stoppedIncidentIdOf(entry!);
    final String? releaseId = v.releases ? 'BR-$jid' : null;
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
        'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
        'VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, NULL, ?)',
        <Object?>[
          jid,
          today,
          P0sStrategyIds.deposit,
          jsonEncode(<String, Object?>{
            'decision': answers.kind.code,
            'held_bars': ep.replay.heldBars,
            'eligible': ep.replay.stoppedReleaseEligible,
            'entry_date': entry,
            'incident_id': incidentId,
            'family_agreement': answers.familyAgreement,
          }),
          jsonEncode(<String, Object?>{'stopped_decision': answers.kind.code}),
          answers.rationaleBefore.trim(),
          answers.expectedOutcome.trim(),
          answers.ruleCited.trim(),
          kStoppedDecisionKind,
          at,
        ],
      );
      _db.execute(
        'UPDATE incidents SET resolved_at = ? WHERE incident_id = ? AND resolved_at IS NULL',
        <Object?>[at, incidentId],
      );
      if (releaseId != null) {
        _db.execute(
          'INSERT INTO breaker_release(release_id, trade_date, decision_id, created_at) VALUES (?, ?, ?, ?)',
          <Object?>[releaseId, today, jid, at],
        );
        final BreakerConfig cfg = _config ?? p0sBreakerConfig();
        for (final Row r in _db.select(
          "SELECT strategy_id, state FROM strategy_state_current WHERE state <> 'RETIRED' ORDER BY strategy_id",
        )) {
          final String id = r['strategy_id'] as String;
          _db.execute(
            "UPDATE strategy_state_current SET state = 'CANDIDATE', since = ?, capital_cap = 0 WHERE strategy_id = ?",
            <Object?>[today, id],
          );
          _db.execute(
            'INSERT INTO strategy_state_log(log_id, strategy_id, changed_at, from_state, to_state, trigger_value, '
            "threshold_registered, reason) VALUES (?, ?, ?, ?, 'CANDIDATE', ?, ?, ?)",
            <Object?>[
              'SD-$jid-$id',
              id,
              at,
              r['state'],
              ep.replay.lastDrawdown,
              cfg.stopReleaseDd,
              'STOPPED_DECISION_B · $jid',
            ],
          );
        }
        _db.execute(
          'INSERT OR REPLACE INTO ramp_state(id, level, pre_dst_level, updated_at) VALUES (1, 1, NULL, ?)',
          <Object?>[at],
        );
      }
      _command(commandId, payloadDigest, decisionId: jid);
    });
    return StoppedDecisionResult(
      executed: true,
      decisionId: jid,
      releaseId: releaseId,
    );
  }
}
