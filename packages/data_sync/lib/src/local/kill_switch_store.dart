// 킬스위치 저장 · 집행(SPEC v2.40 04 §3-6 · 02 `kill_switch_state` · `kill_switch_event` · 설계 13 §8 R57 B1~B7).
//
// 🔴 발동 = 꺼져 있으면 새 발동 · 켜져 있으면 행 그대로(첫 시각 유지) · 누를 때마다 이력 1행 · 시각 = 신뢰 시각(모르면 기기 시계 — 발동은 막지 않는다).
// 🔴 확인 · 재개 = core 판정 통과 뒤 한 트랜잭션(저널 + 상태 + 이력 + 명령 기록) · 확인 시각 = 신뢰 시각만.
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, DecisionJournalKinds;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// 🔴 시차 없는 · 깨진 시각 = 던진다(기기 지역 시각으로 읽혀 48h 가 밀리지 않게) — 주문 경로는 던짐을 막음으로 받는다
/// (1단계 = 원장 불가 · 7단계 직전 = SKIPPED).
DateTime? _ts(Object? v) {
  if (v == null) return null;
  if (v is! String || !_offset.hasMatch(v)) {
    throw FormatException('kill_switch_state 시각에 시차가 없다', v);
  }
  return DateTime.parse(v).toUtc();
}

String _kstDay(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year.toString().padLeft(4, '0')}-${two(k.month)}-${two(k.day)}';
}

/// `kill_switch_state` 행(id = 1 · 없으면 꺼짐).
KillSwitchRecord readKillSwitchRecord(Database db) {
  final ResultSet rs = db.select(
    'SELECT activated_at, activated_by, checklist_confirmed_at, cleared_at, decision_id '
    'FROM kill_switch_state WHERE id = 1',
  );
  if (rs.isEmpty) return const KillSwitchRecord();
  final Row r = rs.first;
  return KillSwitchRecord(
    activatedAtUtc: _ts(r['activated_at']),
    checklistConfirmedAtUtc: _ts(r['checklist_confirmed_at']),
    clearedAtUtc: _ts(r['cleared_at']),
    decisionId: r['decision_id'] as String?,
    activatedByDeviceLabel: r['activated_by'] as String?,
  );
}

/// 명령 결과.
class KillCommandResult {
  /// 결과를 만든다.
  const KillCommandResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
    this.decisionId,
    this.p0 = false,
    this.activation,
  });

  /// 실행됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;

  /// 만든 저널(확인 · 재개).
  final String? decisionId;

  /// 🔴 P0 를 다시 올린다(확인 3 이 엔진 미체결과 어긋남).
  final bool p0;

  /// 발동이면 그 결과(재전달이면 null).
  final KillActivationResult? activation;
}

/// 킬스위치 저장 · 집행(R57).
class SqliteKillSwitchStore implements KillSwitchStore {
  /// 저장을 만든다.
  SqliteKillSwitchStore(
    this._db, {
    required this._clock,
    required this._trusted,
    this._cfg = kP0sKillSwitchConfig,
  });

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final KillSwitchConfig _cfg;
  int _seq = 0;

  DateTime _now() => (_trusted.trustedNowUtc() ?? _clock.nowUtc()).toUtc();

  String _eventId(String kind, DateTime at) =>
      'KS-${at.microsecondsSinceEpoch}-$kind-${_seq++}';

  void _event(
    String kind,
    DateTime at, {
    String? channel,
    String? decisionId,
    required String summary,
  }) => _db.execute(
    'INSERT INTO kill_switch_event(event_id, occurred_at, kind, channel, decision_id, summary) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    <Object?>[
      _eventId(kind, at),
      at.toIso8601String(),
      kind,
      channel,
      decisionId,
      summary,
    ],
  );

  @override
  Future<KillSwitchRecord> read() async => readKillSwitchRecord(_db);

  @override
  Future<KillSwitchRecord> activate({
    required DateTime atUtc,
    required String channel,
    String? deviceLabel,
  }) async {
    inLedgerTransaction(_db, () {
      final bool active = killSwitchActive(
        readKillSwitchRecord(_db),
        cfg: _cfg,
      );
      if (!active) {
        _db.execute(
          'INSERT OR REPLACE INTO kill_switch_state(id, activated_at, activated_by, checklist_confirmed_at, '
          'cleared_at, decision_id) VALUES (1, ?, ?, NULL, NULL, NULL)',
          <Object?>[atUtc.toUtc().toIso8601String(), deviceLabel ?? channel],
        );
      }
      _event(
        'ACTIVATED',
        atUtc.toUtc(),
        channel: channel,
        summary: jsonEncode(<String, Object?>{'repeat': active}),
      );
    });
    return readKillSwitchRecord(_db);
  }

  @override
  Future<void> recordCancelReport(
    KillCancelReport report,
    DateTime atUtc,
  ) async =>
      _event('CANCEL_REPORT', atUtc.toUtc(), summary: report.summaryJson());

  /// 오늘(한국 날짜)의 취소 후보(R57 B5) — 의도별 가장 최근 브로커 주문의 잔량.
  List<KillCancelCandidate> cancelCandidates() {
    final String day = _kstDay(_now());
    return <KillCancelCandidate>[
      for (final Row r in _db.select(
        'SELECT i.intent_id, i.account, i.symbol, i.status, b.broker_order_no, b.remaining_qty '
        'FROM order_intents i LEFT JOIN broker_orders b ON b.broker_order_no = ('
        'SELECT broker_order_no FROM broker_orders WHERE intent_id = i.intent_id '
        'ORDER BY submitted_at DESC, broker_order_no DESC LIMIT 1) '
        'WHERE i.trade_date = ? ORDER BY i.intent_id',
        <Object?>[day],
      ))
        KillCancelCandidate(
          intentId: r['intent_id'] as String,
          account: r['account'] as String,
          symbol: r['symbol'] as String,
          status: IntentStatus.values.firstWhere(
            (IntentStatus s) => s.code == r['status'],
          ),
          brokerOrderNo: r['broker_order_no'] as String?,
          remainingQty: (r['remaining_qty'] as int?) ?? 0,
        ),
    ];
  }

  /// 엔진이 본 남은 미체결 수(확인 3 의 교차 대조).
  int openOrderCount() => planKillCancels(cancelCandidates()).$1.length;

  KillCommandResult? _replay(String commandId) {
    final ResultSet rs = _db.select(
      'SELECT state, reject_reason_code, decision_id FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (rs.isEmpty) return null;
    return KillCommandResult(
      executed: rs.first['state'] == 'EXECUTED',
      replayed: true,
      reasonCode: rs.first['reject_reason_code'] as String?,
      decisionId: rs.first['decision_id'] as String?,
    );
  }

  void _command(
    String commandId,
    String kind,
    String payloadDigest, {
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
      payloadDigest,
    ],
  );

  KillCommandResult _reject(
    String commandId,
    String kind,
    String digest,
    String code, {
    bool p0 = false,
  }) {
    _command(commandId, kind, digest, rejectCode: code);
    return KillCommandResult(executed: false, reasonCode: code, p0: p0);
  }

  bool _journalTaken(String id) => _db.select(
    'SELECT 1 FROM decision_journal WHERE journal_id = ?',
    <Object?>[id],
  ).isNotEmpty;

  /// operator 로컬 단락(R57 B7) — 저장 + 취소 즉시. [brokers] = 계좌 별칭 → 브로커.
  Future<KillCommandResult> activateLocal({
    required String commandId,
    required String payloadDigest,
    required Map<String, OrderBroker> brokers,
    required String channel,
    String? deviceLabel,
  }) async {
    final KillCommandResult? again = _replay(commandId);
    if (again != null) return again;
    final KillActivationResult r = await activateKillSwitch(
      store: this,
      brokers: brokers,
      candidates: () async => cancelCandidates(),
      nowUtc: _now(),
      channel: channel,
      deviceLabel: deviceLabel,
    );
    _command(commandId, 'KILL_SWITCH_ACTIVATE', payloadDigest);
    return KillCommandResult(executed: true, activation: r);
  }

  /// (가) 발동 뒤 기록 확인(R57 B2).
  KillCommandResult confirmChecklist({
    required String commandId,
    required String payloadDigest,
    required KillActivationAnswers answers,
    required KillAckAnswers ack,
  }) {
    const String kind = 'KILL_CHECKLIST_CONFIRM';
    final KillCommandResult? again = _replay(commandId);
    if (again != null) return again;
    final DateTime? trusted = _trusted.trustedNowUtc();
    if (trusted == null) {
      return _reject(commandId, kind, payloadDigest, 'TRUSTED_TIME_UNKNOWN');
    }
    final KillSwitchRecord cur = readKillSwitchRecord(_db);
    if (!killSwitchActive(cur, cfg: _cfg)) {
      return _reject(commandId, kind, payloadDigest, 'KILL_SWITCH_NOT_ACTIVE');
    }
    final KillChecklistVerdict v = activationChecklistVerdict(
      answers,
      ack,
      engineOpenOrders: openOrderCount(),
    );
    if (!v.passed) {
      return _reject(commandId, kind, payloadDigest, v.code!, p0: v.p0);
    }
    final String jid = answers.journalDecisionId.trim();
    if (_journalTaken(jid)) {
      return _reject(commandId, kind, payloadDigest, 'JOURNAL_ID_TAKEN');
    }
    final DateTime at = trusted.toUtc();
    final bool emotion = answers.reasonKind == KillReasonKind.emotion;
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
        'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          jid,
          _kstDay(at),
          P0sStrategyIds.deposit,
          jsonEncode(<String, Object?>{
            'rule_action': answers.ruleAction.trim(),
            'reason': answers.reasonKind.name,
            if (emotion) 'emotion': answers.emotion!.trim(),
            if (emotion) 'intensity': answers.intensity,
            if (emotion) 'sleep_hours': answers.sleepHours,
            'scenario': answers.scenarioNone
                ? null
                : answers.scenarioId!.trim(),
            'resume_condition': answers.resumeCondition.trim(),
            'scope': answers.scope.name,
            'ack': <String, Object?>{
              'open_orders_queried': ack.openOrdersQueried,
              'open_orders_cancelled': ack.openOrdersCancelled,
              'remaining_count_zero': ack.remainingCountZero,
            },
          }),
          jsonEncode(<String, Object?>{'kill_switch': 'CHECKLIST_CONFIRMED'}),
          emotion ? 1 : 0,
          emotion
              ? '감정: ${answers.emotion!.trim()} (강도 ${answers.intensity} · 수면 ${answers.sleepHours}시간)'
              : '규칙: ${answers.ruleAction.trim()}',
          answers.resumeCondition.trim(),
          answers.scenarioNone ? '해당 없음' : answers.scenarioId!.trim(),
          // 🆕 미결 220 ⓒ — 저널 kind = 계약 사전(명령 와이어 `KILL_CHECKLIST_CONFIRM` 과 다르다 · K294 예외).
          DecisionJournalKinds.killSwitchChecklist,
          ack.note.trim(),
          at.toIso8601String(),
        ],
      );
      // 🔴 이미 있으면 그대로 — 다시 확인해도 48h 를 늦추거나 당기지 않는다.
      _db.execute(
        'UPDATE kill_switch_state SET checklist_confirmed_at = COALESCE(checklist_confirmed_at, ?) WHERE id = 1',
        <Object?>[at.toIso8601String()],
      );
      _event(
        'CHECKLIST_CONFIRMED',
        at,
        decisionId: jid,
        summary: jsonEncode(<String, Object?>{'scope': answers.scope.name}),
      );
      _command(commandId, kind, payloadDigest, decisionId: jid);
    });
    return KillCommandResult(executed: true, decisionId: jid);
  }

  /// (나) 재개(R57 B3).
  KillCommandResult resume({
    required String commandId,
    required String payloadDigest,
    required ResumeChecklist checklist,
  }) {
    const String kind = 'KILL_SWITCH_RESUME';
    final KillCommandResult? again = _replay(commandId);
    if (again != null) return again;
    final ResumeDecision d = tryResume(
      readKillSwitchRecord(_db),
      _trusted.trustedNowUtc(),
      checklist,
      cfg: _cfg,
    );
    if (!d.allowed) return _reject(commandId, kind, payloadDigest, d.code!);
    final String jid = d.decisionId!;
    if (_journalTaken(jid)) {
      return _reject(commandId, kind, payloadDigest, 'JOURNAL_ID_TAKEN');
    }
    final DateTime at = d.clearedAtUtc!;
    final ResumeItemAnswer j = checklist.journal!;
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
        'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
        'VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?, NULL, ?)',
        <Object?>[
          jid,
          _kstDay(at),
          P0sStrategyIds.deposit,
          jsonEncode(<Object?>[
            for (final ResumeItemAnswer a in checklist.accepted)
              <String, Object?>{
                'item': a.itemNo,
                if (a.text != null) 'text': a.text!.trim(),
                if (a.emotion != null) 'emotion': a.emotion!.trim(),
                if (a.intensity != null) 'intensity': a.intensity,
                if (a.sleepHours != null) 'sleep_hours': a.sleepHours,
                if (a.scenario != null) 'scenario': a.scenario!.name,
                if (a.condition != null) 'condition': a.condition!.name,
                if (a.itemNo == 5 || a.itemNo == 6)
                  'acknowledged': a.acknowledged,
              },
          ]),
          jsonEncode(<String, Object?>{'kill_switch': 'RESUMED'}),
          j.rationaleBefore!.trim(),
          j.expectedOutcome!.trim(),
          j.ruleCited!.trim(),
          // 🆕 미결 220 ⓒ — 저널 kind = 계약 사전(명령 kind 는 위 지역 글자 — 축이 다르다).
          DecisionJournalKinds.killSwitchResume,
          at.toIso8601String(),
        ],
      );
      _db.execute(
        'UPDATE kill_switch_state SET cleared_at = ?, decision_id = ? WHERE id = 1',
        <Object?>[at.toIso8601String(), jid],
      );
      _event('RESUMED', at, decisionId: jid, summary: '{}');
      _command(commandId, kind, payloadDigest, decisionId: jid);
    });
    return KillCommandResult(executed: true, decisionId: jid);
  }
}
