// 운영 기기 알림 저장 · P0 수신 확인 · ack 승급 사다리 틱
// (06 M5-15 · 04 §5-3 · 앱 04 §5-4 · 02 §2 v2.41 `alert_event` · `alert_ack` · `alert_escalation` · 설계 13 §8 R68 H2~H6).
//
// 🔴 append-only — 같은 사건(묶음 키) = 1행 · 확인 · 사다리 단계 = 뒤 행.
// 🔴 등급은 엔진 표(core `kAlertLevels`) · 모르는 코드 = 오류(한 건도 적지 않는다).
// 🔴 확인 = 효력 없음(사다리 정지만) · 사다리 = 보낸 뒤 적는다(실패 = 미기록 · 다음 틱에 다시).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AlertLevel, Clock, CommandKind;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

/// 확인 결과.
class AlertAckResult {
  /// 결과를 만든다.
  const AlertAckResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
  });

  /// 실행됐나(재전달이면 처음 결과 · 이미 확인한 알림의 두 번째 확인도 실행 — 멱등).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;
}

/// 사다리 틱에서 오른 단계 하나.
class AlertEscalationStep {
  /// 단계를 만든다.
  const AlertEscalationStep(this.alertId, this.step);

  /// 알림 id.
  final String alertId;

  /// 단계(1 · 2).
  final int step;
}

/// 운영 기기 알림 저장(R68) — 잡의 [AlertSink] 구현.
class SqliteAlertSink implements AlertSink {
  /// 저장을 만든다 — 시각 = 기기 시계(발생 기록 · 사다리 기준 — 마찰 시간이 아니다).
  SqliteAlertSink(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// [check] 잡이 낸 알림 코드를 적는다(R68 H3) — 같은 날 같은 체크의 같은 코드 = 새 행 0.
  @override
  Future<void> emit(String check, Set<String> codes) async {
    if (codes.isEmpty) return;
    final DateTime now = _clock.nowUtc().toUtc();
    final List<(String, AlertLevel)> rows = _levels(codes);
    inLedgerTransaction(_db, () => _write(check, rows, now));
  }

  /// 🆕 E15f3a(R98 AG8) — 바깥 트랜잭션 안에서 적는다(커밋과 함께 정확히 1회 · 되돌리면 같이 사라진다).
  /// 트랜잭션 밖 = [StateError] · 모르는 코드 = [ArgumentError](아무것도 적지 않는다).
  void emitInTransaction(String check, Set<String> codes) {
    if (_db.autocommit) {
      throw StateError('emitInTransaction 은 바깥 트랜잭션 안에서만');
    }
    if (codes.isEmpty) return;
    _write(check, _levels(codes), _clock.nowUtc().toUtc());
  }

  // 🔴 등급을 먼저 전부 판정 — 모르는 코드가 하나라도 있으면 아무것도 적지 않고 던진다.
  List<(String, AlertLevel)> _levels(Set<String> codes) =>
      <(String, AlertLevel)>[
        for (final String c in codes.toList()..sort()) (c, alertLevelOf(c)),
      ];

  void _write(String check, List<(String, AlertLevel)> rows, DateTime now) {
    for (final (String code, AlertLevel level) in rows) {
      _db.execute(
        'INSERT OR IGNORE INTO alert_event(alert_id, raised_at, code, level, source, dedupe_key) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>[
          alertIdOf(code: code, source: check, raisedAtUtc: now),
          now.toIso8601String(),
          code,
          level.wire,
          check,
          alertDedupeKey(code: code, source: check, raisedAtUtc: now),
        ],
      );
    }
  }

  void _command(String commandId, String digest, {String? rejectCode}) =>
      _db.execute(
        'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
        'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
        'VALUES (?, ?, ?, ?, ?, ?, NULL, NULL, NULL, NULL, ?)',
        <Object?>[
          commandId,
          CommandKind.alertAck.wire,
          _clock.nowUtc().toUtc().toIso8601String(),
          rejectCode == null ? 'EXECUTED' : 'REJECTED',
          rejectCode == null ? '실행됨' : '거부됨 — $rejectCode',
          rejectCode,
          digest,
        ],
      );

  /// P0 수신 확인(R68 H4) — 🔴 효력 없음(사다리 정지만) · 두 번째 확인 = 실행(새 행 0).
  AlertAckResult acknowledge({
    required String commandId,
    required String payloadDigest,
    required String alertId,
  }) {
    final ResultSet again = _db.select(
      'SELECT state, reject_reason_code FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (again.isNotEmpty) {
      return AlertAckResult(
        executed: again.first['state'] == 'EXECUTED',
        replayed: true,
        reasonCode: again.first['reject_reason_code'] as String?,
      );
    }
    final ResultSet rs = _db.select(
      'SELECT code FROM alert_event WHERE alert_id = ?',
      <Object?>[alertId],
    );
    final String? code = alertAckRejectCode(
      code: rs.isEmpty ? null : rs.first['code'] as String,
    );
    if (code != null) {
      _command(commandId, payloadDigest, rejectCode: code);
      return AlertAckResult(executed: false, reasonCode: code);
    }
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT OR IGNORE INTO alert_ack(alert_id, acked_at, command_id) VALUES (?, ?, ?)',
        <Object?>[
          alertId,
          _clock.nowUtc().toUtc().toIso8601String(),
          commandId,
        ],
      );
      _command(commandId, payloadDigest);
    });
    return const AlertAckResult(executed: true);
  }

  /// 사다리 틱(R68 H5 · H6) — 미확인 P0(손절 안내 빼고)의 오를 단계를 차례대로 보내고 적는다.
  ///
  /// 🔴 보낸 뒤 적는다 — [channel] 이 던지면 그 단계는 적지 않고 그대로 던진다(다음 틱에 다시 · 뒤 단계는 앞 단계 뒤에만).
  Future<List<AlertEscalationStep>> escalationTick(
    AlertEscalationChannel channel,
  ) async {
    final DateTime now = _clock.nowUtc().toUtc();
    final List<AlertEscalationStep> out = <AlertEscalationStep>[];
    for (final Row r in _db.select(
      'SELECT e.alert_id, e.code, e.raised_at, a.alert_id IS NOT NULL AS acked FROM alert_event e '
      "LEFT JOIN alert_ack a ON a.alert_id = e.alert_id WHERE e.level = 'P0' "
      'ORDER BY e.raised_at, e.alert_id',
    )) {
      final String id = r['alert_id'] as String;
      final String code = r['code'] as String;
      if (!alertHasLadder(code)) continue;
      final Set<int> done = <int>{
        for (final Row s in _db.select(
          'SELECT step FROM alert_escalation WHERE alert_id = ?',
          <Object?>[id],
        ))
          s['step'] as int,
      };
      for (final int step in dueEscalationSteps(
        raisedAtUtc: _instant(r['raised_at'] as String),
        nowUtc: now,
        acked: r['acked'] == 1,
        done: done,
      )) {
        await channel.escalate(alertId: id, code: code, step: step);
        _db.execute(
          'INSERT INTO alert_escalation(alert_id, step, escalated_at) VALUES (?, ?, ?)',
          <Object?>[id, step, now.toIso8601String()],
        );
        out.add(AlertEscalationStep(id, step));
      }
    }
    return out;
  }
}
