// 본인 서약문 저장 · 지금 판 읽기 · DD 최초 도달 재생 대상 · «재생함» 기록
// (M5-8 · 02 §2 `pledge` · `pledge_replay` v2.40 · 설계 13 §8 R67 Z1~Z8).
//
// 🔴 append-only — 편집 = 새 판(옛 판은 그대로).
// 🔴 원문은 한 번만(첫 판) · 편집 = 12월 창만 · 재생처는 `currentPledge()` 만 읽는다.
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// `command_inbox.kind` — 첫 판 · 편집.
const String kPledgeWriteKind = 'PLEDGE_WRITE', kPledgeEditKind = 'PLEDGE_EDIT';

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

/// 서약 쓰기 결과.
class PledgeResult {
  /// 결과를 만든다.
  const PledgeResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
  });

  /// 실행됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;
}

/// 서약 저장(R67).
class SqlitePledgeStore {
  /// 저장을 만든다 — `clock` = 명령 접수 · 재생 표시 시각(기기) · `trusted` = 쓴 시각 · 12월 창.
  SqlitePledgeStore(this._db, {required this._clock, required this._trusted});

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;

  /// 지금 판(가장 높은 판) — 없으면 null(재생처 = 블록 부재).
  Pledge? currentPledge() {
    final ResultSet rs = _db.select(
      'SELECT version, sentence_1, sentence_2, sentence_3, written_at FROM pledge ORDER BY version DESC LIMIT 1',
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    return Pledge(
      version: r['version'] as int,
      lines: List<String>.unmodifiable(<String>[
        r['sentence_1'] as String,
        r['sentence_2'] as String,
        r['sentence_3'] as String,
      ]),
      writtenAtUtc: _instant(r['written_at'] as String),
    );
  }

  /// 재생처가 읽는 줄(0줄 = 블록 부재 · J-3 `pledgeLines` 선례).
  List<String> pledgeLines() => currentPledge()?.lines ?? const <String>[];

  PledgeResult? _replay(String commandId) {
    final ResultSet rs = _db.select(
      'SELECT state, reject_reason_code FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (rs.isEmpty) return null;
    return PledgeResult(
      executed: rs.first['state'] == 'EXECUTED',
      replayed: true,
      reasonCode: rs.first['reject_reason_code'] as String?,
    );
  }

  void _command(
    String kind,
    String commandId,
    String digest, {
    String? rejectCode,
    String? decisionId,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?)',
    <Object?>[
      commandId,
      kind,
      _clock.nowUtc().toUtc().toIso8601String(),
      rejectCode == null ? 'EXECUTED' : 'REJECTED',
      rejectCode == null ? '실행됨' : '거부됨 — $rejectCode',
      rejectCode,
      decisionId,
      digest,
    ],
  );

  PledgeResult _save(
    String kind,
    String commandId,
    String digest,
    int version,
    List<String> lines,
    DateTime now,
    String decisionId,
  ) {
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO pledge(pledge_id, version, sentence_1, sentence_2, sentence_3, written_at, decision_id) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          'PL-$version',
          version,
          lines[0],
          lines[1],
          lines[2],
          now.toIso8601String(),
          decisionId,
        ],
      );
      _command(kind, commandId, digest, decisionId: decisionId);
    });
    return const PledgeResult(executed: true);
  }

  /// 첫 판을 쓴다(온보딩 · R67 Z1).
  PledgeResult writeFirst({
    required String commandId,
    required String payloadDigest,
    required List<String> sentences,
    required String decisionId,
  }) {
    final PledgeResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final String? code = pledgeWriteRejectCode(
      nowUtc: now,
      current: currentPledge(),
      sentences: sentences,
      decisionId: decisionId,
    );
    if (code != null) {
      _command(
        kPledgeWriteKind,
        commandId,
        payloadDigest,
        rejectCode: code,
        decisionId: decisionId,
      );
      return PledgeResult(executed: false, reasonCode: code);
    }
    return _save(
      kPledgeWriteKind,
      commandId,
      payloadDigest,
      1,
      pledgeSentencesOf(sentences)!,
      now!,
      decisionId,
    );
  }

  bool _journalLinked(String decisionId) {
    if (decisionId.trim().isEmpty) return false;
    final ResultSet rs = _db.select(
      'SELECT rationale_before, expected_outcome, rule_cited FROM decision_journal WHERE journal_id = ?',
      <Object?>[decisionId],
    );
    bool filled(Object? v) => v is String && v.trim().isNotEmpty;
    return rs.isNotEmpty &&
        filled(rs.first['rationale_before']) &&
        filled(rs.first['expected_outcome']) &&
        filled(rs.first['rule_cited']) &&
        _db.select('SELECT 1 FROM pledge WHERE decision_id = ?', <Object?>[
          decisionId,
        ]).isEmpty;
  }

  /// 서약을 고친다(새 판 · 12월 창만 · R67 Z2).
  PledgeResult edit({
    required String commandId,
    required String payloadDigest,
    required List<String> sentences,
    required String decisionId,
  }) {
    final PledgeResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final Pledge? current = currentPledge();
    final String? code = pledgeEditRejectCode(
      nowUtc: now,
      current: current,
      sentences: sentences,
      journalLinked: _journalLinked(decisionId),
    );
    if (code != null) {
      _command(
        kPledgeEditKind,
        commandId,
        payloadDigest,
        rejectCode: code,
        decisionId: decisionId,
      );
      return PledgeResult(executed: false, reasonCode: code);
    }
    return _save(
      kPledgeEditKind,
      commandId,
      payloadDigest,
      current!.version + 1,
      pledgeSentencesOf(sentences)!,
      now!,
      decisionId,
    );
  }

  DrawdownEpisode? _episode() => currentEpisodeOf(<DrawdownPoint>[
    for (final Row r in _db.select(
      'SELECT trade_date, drawdown FROM equity_snapshot',
    ))
      DrawdownPoint(
        r['trade_date'] as String,
        (r['drawdown'] as num).toDouble(),
      ),
  ]);

  /// 재생 대상(R67 Z6 · Z8) — 없으면 null.
  PledgeReplayDue? replayDue() {
    final DrawdownEpisode? ep = _episode();
    return pledgeReplayDueOf(
      hasPledge: currentPledge() != null,
      episode: ep,
      shownThresholds: ep == null
          ? const <double>{}
          : <double>{
              for (final Row r in _db.select(
                'SELECT threshold_dd FROM pledge_replay WHERE episode_peak_date = ?',
                <Object?>[ep.peakDate],
              ))
                (r['threshold_dd'] as num).toDouble(),
            },
    );
  }

  /// «재생함»을 적는다(R67 Z7) — 지금 대상 전부를 한 번에 · 대상 없음 = 0행. 적은 행 수를 돌려준다.
  int markReplayShown() {
    final PledgeReplayDue? due = replayDue();
    if (due == null) return 0;
    final String at = _clock.nowUtc().toUtc().toIso8601String();
    inLedgerTransaction(_db, () {
      for (final double t in due.thresholds) {
        _db.execute(
          'INSERT OR IGNORE INTO pledge_replay(replay_id, threshold_dd, episode_peak_date, shown_at) '
          'VALUES (?, ?, ?, ?)',
          <Object?>['PR-${due.peakDate}-$t', t, due.peakDate, at],
        );
      }
    });
    return due.thresholds.length;
  }
}
