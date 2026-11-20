// 규칙 변경 요청 큐 · 취소 · 승인 · CHANGELOG · SAF-405 기동 판정 읽기
// (03_운영 §6-4 · §6-5 · §6-8 · 04 §1 SAF-405 · 02 §2 `rule_change_request` · `rule_change_decision` · `config_versions` ·
//  설계 13 §8 R66 Y2~Y8).
//
// 🔴 append-only — 요청 · 결정 행은 고치지 않는다(결정 = 요청 하나에 한 번).
// 🔴 승인 = 한 트랜잭션: 결정 행 + 승인 목록 = 후 hash 하나(나머지 0) + 명령 · 자동 적용 0.
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// `command_inbox.kind` — 요청 · 취소 · 승인.
const String kRuleChangeRequestKind = 'RULE_CHANGE_REQUEST',
    kRuleChangeCancelKind = 'RULE_CHANGE_CANCEL',
    kRuleChangeApproveKind = 'RULE_CHANGE_APPROVE';

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

/// 명령 결과.
class RuleChangeResult {
  /// 결과를 만든다.
  const RuleChangeResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
    this.requestId,
  });

  /// 실행됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;

  /// 요청 id(요청 명령 · 실행 때).
  final String? requestId;
}

/// 미결정 요청 한 줄(R66 Y8).
class RuleChangeQueueItem {
  /// 줄을 만든다.
  const RuleChangeQueueItem({
    required this.requestId,
    required this.changeType,
    required this.hashBefore,
    required this.hashAfter,
    required this.requestedAtUtc,
    required this.firstApproval,
  });

  /// 요청 id.
  final String requestId;

  /// 유형.
  final RuleChangeType changeType;

  /// hash 전 · 후.
  final String hashBefore, hashAfter;

  /// 요청 시각.
  final DateTime requestedAtUtc;

  /// 첫 승인 요청인가(전 = `NONE`).
  final bool firstApproval;

  /// 냉각 끝.
  DateTime get coolingEndsAtUtc => requestedAtUtc.add(kRuleChangeCooling);
}

/// CHANGELOG 한 행(03_운영 §6-8 **10칸**).
class ChangelogEntry {
  /// 행을 만든다.
  const ChangelogEntry({
    required this.decidedAtUtc,
    required this.changeType,
    required this.goldenChanged,
    required this.hashBefore,
    required this.hashAfter,
    required this.reason,
    required this.approver,
    required this.requestedAtUtc,
    required this.approvalDd,
    required this.rollbackMethod,
    required this.decisionId,
  });

  /// ① 날짜(승인일).
  final DateTime decidedAtUtc;

  /// ② 변경 유형.
  final RuleChangeType changeType;

  /// ③ 골든파일 영향 여부.
  final bool goldenChanged;

  /// ④ `config_hash` 전 · 후.
  final String hashBefore, hashAfter;

  /// ⑤ 사유 · ⑥ 승인자.
  final String reason, approver;

  /// ⑦ 요청일(냉각 계산용).
  final DateTime requestedAtUtc;

  /// ⑧ 승인 시점 DD.
  final double approvalDd;

  /// ⑨ 롤백 방법 · ⑩ 관련 decision_id.
  final String rollbackMethod, decisionId;
}

class _Req {
  const _Req(this.facts, this.decisionId, this.hashAfter);
  final RuleChangeRequestFacts facts;
  final String decisionId, hashAfter;
}

/// 규칙 변경 저장(R66).
class SqliteRuleChangeStore {
  /// 저장을 만든다 — `clock` = 명령 접수 시각(기기) · `trusted` = 요청 · 결정 시각.
  SqliteRuleChangeStore(
    this._db, {
    required this._clock,
    required this._trusted,
  });

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;

  /// 지금 승인된 config hash — 없으면 `NONE` · 🔴 둘 이상 = 원장이 규칙(하나)을 어겼다.
  String approvedConfigHash() {
    final ResultSet rs = _db.select(
      'SELECT config_hash FROM config_versions WHERE approved = 1',
    );
    if (rs.length > 1) {
      throw StateError('승인된 config 가 ${rs.length}개다(승인 목록 = 하나)');
    }
    return rs.isEmpty ? kNoApprovedConfig : rs.first['config_hash'] as String;
  }

  /// SAF-405 기동 판정(R66 Y6) — 행 없음 = `approved` null.
  StartupGate startupGate(String configHash, RunMode runMode) {
    final ResultSet rs = _db.select(
      'SELECT approved FROM config_versions WHERE config_hash = ?',
      <Object?>[configHash],
    );
    return startupConfigGate(
      runMode: runMode,
      approved: rs.isEmpty ? null : rs.first['approved'] as int,
    );
  }

  RuleChangeResult? _replay(String commandId) {
    final ResultSet rs = _db.select(
      'SELECT state, reject_reason_code, decision_id FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (rs.isEmpty) return null;
    final bool ok = rs.first['state'] == 'EXECUTED';
    return RuleChangeResult(
      executed: ok,
      replayed: true,
      reasonCode: rs.first['reject_reason_code'] as String?,
      requestId: ok ? 'RC-${rs.first['decision_id']}' : null,
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

  RuleChangeResult _reject(
    String kind,
    String commandId,
    String digest,
    String code,
    String? decisionId,
  ) {
    _command(kind, commandId, digest, rejectCode: code, decisionId: decisionId);
    return RuleChangeResult(executed: false, reasonCode: code);
  }

  bool _journalLinked(String? decisionId) {
    if (decisionId == null || decisionId.trim().isEmpty) return false;
    final ResultSet rs = _db.select(
      'SELECT rationale_before, expected_outcome, rule_cited FROM decision_journal WHERE journal_id = ?',
      <Object?>[decisionId],
    );
    return ruleChangeJournalLinked(
      exists: rs.isNotEmpty,
      rationaleBefore: rs.isEmpty
          ? null
          : rs.first['rationale_before'] as String?,
      expectedOutcome: rs.isEmpty
          ? null
          : rs.first['expected_outcome'] as String?,
      ruleCited: rs.isEmpty ? null : rs.first['rule_cited'] as String?,
      alreadyUsed: _db.select(
        'SELECT 1 FROM rule_change_request WHERE decision_id = ?',
        <Object?>[decisionId],
      ).isNotEmpty,
    );
  }

  /// 규칙 변경을 요청한다(R66 Y2 · 언제든 — DD · 12월 무관).
  RuleChangeResult request({
    required String commandId,
    required String payloadDigest,
    required RuleChangeType changeType,
    required String hashBefore,
    required String hashAfter,
    required String reason,
    required String rollbackMethod,
    required String decisionId,
  }) {
    final RuleChangeResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final String? code = ruleChangeRequestRejectCode(
      nowUtc: now,
      hashBefore: hashBefore,
      hashAfter: hashAfter,
      reason: reason,
      rollbackMethod: rollbackMethod,
      currentApproved: approvedConfigHash(),
      afterKnown: _db.select(
        'SELECT 1 FROM config_versions WHERE config_hash = ?',
        <Object?>[hashAfter],
      ).isNotEmpty,
      journalLinked: _journalLinked(decisionId),
    );
    if (code != null) {
      return _reject(
        kRuleChangeRequestKind,
        commandId,
        payloadDigest,
        code,
        decisionId,
      );
    }
    final String id = 'RC-$decisionId';
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO rule_change_request(request_id, requested_at, change_type, config_hash_before, '
        'config_hash_after, reason, rollback_method, decision_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          now!.toIso8601String(),
          changeType.wire,
          hashBefore,
          hashAfter,
          reason.trim(),
          rollbackMethod.trim(),
          decisionId,
        ],
      );
      _command(
        kRuleChangeRequestKind,
        commandId,
        payloadDigest,
        decisionId: decisionId,
      );
    });
    return RuleChangeResult(executed: true, requestId: id);
  }

  /// 🆕 E11q-c0(설계 13 §8 R188 · 01 §35 K180 · 미결 206 요청 몫) — 규칙 변경 요청 + 사전 저널을 **한 트랜잭션**으로 쓴다
  /// («저널 함께 쓰기» 판 — [request] 는 이미 있는 저널을 요구하고 둘 다 `BEGIN IMMEDIATE` 라 겹쳐 부를 수 없다).
  /// 저널 id = 구현([journalId] · 겹치면 `JOURNAL_ID_TAKEN`) · 저널 세 칸 빈칸 = `RULE_CHANGE_JOURNAL_MISSING` · 그 밖 판정 =
  /// [request] 와 같다(`ruleChangeRequestRejectCode` — 신뢰 시각 모름이 맨 먼저) · 거부 = 쓰기 0(명령 행만).
  RuleChangeResult requestWithJournal({
    required String commandId,
    required String payloadDigest,
    required RuleChangeType changeType,
    required String hashBefore,
    required String hashAfter,
    required String reason,
    required String rollbackMethod,
    required String journalId,
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) {
    final RuleChangeResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final String? code =
        ruleChangeRequestRejectCode(
          nowUtc: now,
          hashBefore: hashBefore,
          hashAfter: hashAfter,
          reason: reason,
          rollbackMethod: rollbackMethod,
          currentApproved: approvedConfigHash(),
          afterKnown: _db.select(
            'SELECT 1 FROM config_versions WHERE config_hash = ?',
            <Object?>[hashAfter],
          ).isNotEmpty,
          journalLinked: ruleChangeJournalLinked(
            exists: true,
            rationaleBefore: rationaleBefore,
            expectedOutcome: expectedOutcome,
            ruleCited: ruleCited,
            alreadyUsed: false,
          ),
        ) ??
        (_db.select(
              'SELECT 1 FROM decision_journal WHERE journal_id = ?',
              <Object?>[journalId],
            ).isNotEmpty
            ? kJournalIdTaken
            : null);
    if (code != null) {
      return _reject(
        kRuleChangeRequestKind,
        commandId,
        payloadDigest,
        code,
        null,
      );
    }
    final String id = 'RC-$journalId';
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
        'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
        "VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, 'RULE_CHANGE_REQUEST', NULL, ?)",
        <Object?>[
          journalId,
          kstDateText(now!),
          P0sStrategyIds.deposit,
          jsonEncode(<String, Object?>{
            'change_type': changeType.wire,
            'config_hash_before': hashBefore,
            'config_hash_after': hashAfter,
          }),
          jsonEncode(<String, Object?>{
            'request_id': id,
            'reason': reason.trim(),
            'rollback_method': rollbackMethod.trim(),
          }),
          rationaleBefore.trim(),
          expectedOutcome.trim(),
          ruleCited.trim(),
          now.toIso8601String(),
        ],
      );
      _db.execute(
        'INSERT INTO rule_change_request(request_id, requested_at, change_type, config_hash_before, '
        'config_hash_after, reason, rollback_method, decision_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          now.toIso8601String(),
          changeType.wire,
          hashBefore,
          hashAfter,
          reason.trim(),
          rollbackMethod.trim(),
          journalId,
        ],
      );
      _command(
        kRuleChangeRequestKind,
        commandId,
        payloadDigest,
        decisionId: journalId,
      );
    });
    return RuleChangeResult(executed: true, requestId: id);
  }

  _Req? _request(String requestId) {
    final ResultSet rs = _db.select(
      'SELECT r.requested_at, r.config_hash_before, r.config_hash_after, r.decision_id, '
      'd.request_id IS NOT NULL AS decided FROM rule_change_request r '
      'LEFT JOIN rule_change_decision d ON d.request_id = r.request_id WHERE r.request_id = ?',
      <Object?>[requestId],
    );
    if (rs.isEmpty) return null;
    return _Req(
      RuleChangeRequestFacts(
        requestedAtUtc: _instant(rs.first['requested_at'] as String),
        hashBefore: rs.first['config_hash_before'] as String,
        decided: rs.first['decided'] == 1,
      ),
      rs.first['decision_id'] as String,
      rs.first['config_hash_after'] as String,
    );
  }

  /// 요청을 취소한다(R66 Y3 — 쉽게: 새 입력 0 · decision_id = 요청 저널).
  RuleChangeResult cancel({
    required String commandId,
    required String payloadDigest,
    required String requestId,
  }) {
    final RuleChangeResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final _Req? r = _request(requestId);
    final String? code = ruleChangeCancelRejectCode(
      nowUtc: now,
      request: r?.facts,
    );
    if (code != null) {
      return _reject(
        kRuleChangeCancelKind,
        commandId,
        payloadDigest,
        code,
        r?.decisionId,
      );
    }
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO rule_change_decision(request_id, decided_at, outcome, golden_changed, approver, '
        "approval_dd, third_party_notified, decision_id) VALUES (?, ?, 'CANCELLED', NULL, NULL, NULL, NULL, ?)",
        <Object?>[requestId, now!.toIso8601String(), r!.decisionId],
      );
      _command(
        kRuleChangeCancelKind,
        commandId,
        payloadDigest,
        decisionId: r.decisionId,
      );
    });
    return RuleChangeResult(executed: true, requestId: requestId);
  }

  /// 🆕 E11q-c0 — 게이트 «승인할 수 있나» 판정이 쓰는 지금 DD(승인과 같은 원천).
  double currentDrawdown() => _drawdown();

  /// 최근 스냅숏의 DD — 없으면 0(R66 Y4 · E13e1 U2 와 같은 원천).
  double _drawdown() {
    final ResultSet rs = _db.select(
      'SELECT drawdown FROM equity_snapshot ORDER BY trade_date DESC LIMIT 1',
    );
    return rs.isEmpty ? 0.0 : (rs.first['drawdown'] as num).toDouble();
  }

  /// 요청을 승인한다(R66 Y4 · Y5).
  RuleChangeResult approve({
    required String commandId,
    required String payloadDigest,
    required String requestId,
    required bool? goldenChanged,
    required String? approver,
    required bool thirdPartyNotified,
  }) {
    final RuleChangeResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final _Req? r = _request(requestId);
    final double dd = _drawdown();
    final String? code = ruleChangeApproveRejectCode(
      nowUtc: now,
      request: r?.facts,
      currentApproved: approvedConfigHash(),
      drawdown: dd,
      goldenChanged: goldenChanged,
      approver: approver,
      thirdPartyNotified: thirdPartyNotified,
    );
    if (code != null) {
      return _reject(
        kRuleChangeApproveKind,
        commandId,
        payloadDigest,
        code,
        r?.decisionId,
      );
    }
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO rule_change_decision(request_id, decided_at, outcome, golden_changed, approver, '
        "approval_dd, third_party_notified, decision_id) VALUES (?, ?, 'APPROVED', ?, ?, ?, 1, ?)",
        <Object?>[
          requestId,
          now!.toIso8601String(),
          goldenChanged! ? 1 : 0,
          approver!.trim(),
          dd,
          r!.decisionId,
        ],
      );
      // 🔴 승인 목록 = 하나(발주자 결정 ⓐ).
      _db.execute(
        'UPDATE config_versions SET approved = CASE WHEN config_hash = ? THEN 1 ELSE 0 END',
        <Object?>[r.hashAfter],
      );
      _command(
        kRuleChangeApproveKind,
        commandId,
        payloadDigest,
        decisionId: r.decisionId,
      );
    });
    return RuleChangeResult(executed: true, requestId: requestId);
  }

  /// 미결정 요청(요청 시각 오름차순).
  List<RuleChangeQueueItem> queue() => <RuleChangeQueueItem>[
    for (final Row r in _db.select(
      'SELECT r.* FROM rule_change_request r LEFT JOIN rule_change_decision d ON d.request_id = r.request_id '
      'WHERE d.request_id IS NULL ORDER BY r.requested_at, r.request_id',
    ))
      RuleChangeQueueItem(
        requestId: r['request_id'] as String,
        changeType: RuleChangeType.fromWire(r['change_type'] as String),
        hashBefore: r['config_hash_before'] as String,
        hashAfter: r['config_hash_after'] as String,
        requestedAtUtc: _instant(r['requested_at'] as String),
        firstApproval: isFirstApproval(r['config_hash_before'] as String),
      ),
  ];

  /// CHANGELOG(승인 행 10칸 · 승인일 오름차순).
  List<ChangelogEntry> changelog() => <ChangelogEntry>[
    for (final Row r in _db.select(
      'SELECT r.*, d.decided_at, d.golden_changed, d.approver, d.approval_dd FROM rule_change_decision d '
      "JOIN rule_change_request r ON r.request_id = d.request_id WHERE d.outcome = 'APPROVED' "
      'ORDER BY d.decided_at, d.request_id',
    ))
      ChangelogEntry(
        decidedAtUtc: _instant(r['decided_at'] as String),
        changeType: RuleChangeType.fromWire(r['change_type'] as String),
        goldenChanged: r['golden_changed'] == 1,
        hashBefore: r['config_hash_before'] as String,
        hashAfter: r['config_hash_after'] as String,
        reason: r['reason'] as String,
        approver: r['approver'] as String,
        requestedAtUtc: _instant(r['requested_at'] as String),
        approvalDd: (r['approval_dd'] as num).toDouble(),
        rollbackMethod: r['rollback_method'] as String,
        decisionId: r['decision_id'] as String,
      ),
  ];
}
