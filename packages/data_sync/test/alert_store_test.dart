// E13h1 — 운영 기기 알림 저장 · 확인 · 사다리 틱(설계 13 §8 R68 H3~H6).
//
// 🔵 잡는 것: ① 적기 = 등급 · 낸 곳 · 묶음 키 · 같은 날 다시 = 새 행 0 · 다음 날 · 다른 체크 = 새 행
//    ② 🔴 모르는 코드 하나 = 아무것도 안 적고 던짐 ③ 빈 집합 = 0 ④ 확인 갈래(P0 · 멱등 · 모르는 id · P1 · 손절 안내)
//    ⑤ 재전달 = 처음 결과 ⑥ 확인 한 트랜잭션 ⑦ 사다리 = 15분 · 60분 · 건너뛰기 0 · 확인 = 멈춤 · 손절 안내 · P1 제외
//    ⑧ 🔴 채널 실패 = 미기록 · 다음 틱에 다시 · 뒤 단계 안 감.
import 'dart:io';

import 'package:core_engine/core_engine.dart' show AlertEscalationChannel;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Channel implements AlertEscalationChannel {
  final List<String> sent = <String>[];
  bool fail = false;
  @override
  Future<void> escalate({
    required String alertId,
    required String code,
    required int step,
  }) async {
    if (fail) throw StateError('채널 실패');
    sent.add('$alertId#$step');
  }
}

// 한국 2026-11-05 10:00.
final DateTime _t0 = DateTime.utc(2026, 11, 5, 1);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteAlertSink sink;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_al_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    sink = SqliteAlertSink(db, clock: clock);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  List<List<Object?>> events() => db
      .select(
        'SELECT alert_id, raised_at, code, level, source, dedupe_key FROM alert_event ORDER BY alert_id',
      )
      .map((Row r) => r.values)
      .toList();

  void at(Duration d) => clock.at = _t0.add(d);

  test('적기 = 등급 · 낸 곳 · 묶음 키 · 같은 날 다시 = 새 행 0', () async {
    await sink.emit('kr_order', <String>{
      'ORDER_REJECTED',
      'ORDER_OUTCOME_UNKNOWN',
    });
    expect(events(), <List<Object?>>[
      <Object?>[
        'AL-2026-11-05-kr_order-ORDER_OUTCOME_UNKNOWN',
        _t0.toIso8601String(),
        'ORDER_OUTCOME_UNKNOWN',
        'P0',
        'kr_order',
        '2026-11-05|kr_order|ORDER_OUTCOME_UNKNOWN',
      ],
      <Object?>[
        'AL-2026-11-05-kr_order-ORDER_REJECTED',
        _t0.toIso8601String(),
        'ORDER_REJECTED',
        'P1',
        'kr_order',
        '2026-11-05|kr_order|ORDER_REJECTED',
      ],
    ]);
    at(const Duration(hours: 5));
    await sink.emit('kr_order', <String>{'ORDER_REJECTED'});
    expect(events(), hasLength(2));
    // 처음 시각 그대로.
    expect(events()[1][1], _t0.toIso8601String());
    // 다른 체크 = 새 행.
    await sink.emit('kr_close', <String>{'ORDER_REJECTED'});
    expect(events(), hasLength(3));
    // 한국 다음 날(UTC 15:00 넘김) = 새 행.
    clock.at = DateTime.utc(2026, 11, 5, 15);
    await sink.emit('kr_order', <String>{'ORDER_REJECTED'});
    expect(
      events().map((List<Object?> r) => r[0]),
      contains('AL-2026-11-06-kr_order-ORDER_REJECTED'),
    );
  });

  test('🔴 모르는 코드 하나 = 아무것도 안 적고 던짐 · 빈 집합 = 0', () async {
    await expectLater(
      sink.emit('kr_order', <String>{'ORDER_REJECTED', 'SOMETHING_NEW'}),
      throwsArgumentError,
    );
    expect(events(), isEmpty);
    await sink.emit('kr_order', const <String>{});
    expect(events(), isEmpty);
  });

  test(
    '확인 갈래 — P0 = 실행 · 두 번째 = 실행(새 행 0) · 모르는 id · P1 · 손절 안내 = INPUT_INVALID',
    () async {
      await sink.emit('kr_order', <String>{'RECON_MISMATCH', 'ORDER_REJECTED'});
      await sink.emit('advice', <String>{'ADVICE_EXIT_URGENT'});
      const String p0 = 'AL-2026-11-05-kr_order-RECON_MISMATCH';
      at(const Duration(minutes: 3));
      AlertAckResult ack(String id, String cmd) =>
          sink.acknowledge(commandId: cmd, payloadDigest: 'dg', alertId: id);
      expect((ack(p0, 'a').executed, ack(p0, 'b').executed), (true, true));
      expect(
        db
            .select('SELECT alert_id, acked_at, command_id FROM alert_ack')
            .single
            .values,
        <Object?>[
          p0,
          _t0.add(const Duration(minutes: 3)).toIso8601String(),
          'a',
        ],
      );
      for (final (String id, String cmd) in <(String, String)>[
        ('AL-NONE', 'c'),
        ('AL-2026-11-05-kr_order-ORDER_REJECTED', 'd'),
        ('AL-2026-11-05-advice-ADVICE_EXIT_URGENT', 'e'),
      ]) {
        expect(ack(id, cmd).reasonCode, 'INPUT_INVALID', reason: id);
      }
      expect(
        db
            .select(
              "SELECT kind, state FROM command_inbox WHERE command_id = 'a'",
            )
            .single
            .values,
        <Object?>['ALERT_ACK', 'EXECUTED'],
      );
    },
  );

  test('같은 command_id 재전달 = 처음 결과 · 새 행 0', () async {
    await sink.emit('kr_order', <String>{'RECON_MISMATCH'});
    const String p0 = 'AL-2026-11-05-kr_order-RECON_MISMATCH';
    expect(
      sink
          .acknowledge(commandId: 'x', payloadDigest: 'dg', alertId: 'AL-NONE')
          .executed,
      isFalse,
    );
    final AlertAckResult again = sink.acknowledge(
      commandId: 'x',
      payloadDigest: 'dg',
      alertId: p0,
    );
    expect(
      (again.executed, again.replayed, again.reasonCode),
      (false, true, 'INPUT_INVALID'),
    );
    expect(db.select('SELECT 1 FROM alert_ack'), isEmpty);
    expect(db.select('SELECT COUNT(*) AS n FROM command_inbox').single['n'], 1);
  });

  test('🔴 확인 한 트랜잭션 — 명령 기록이 실패하면 확인도 남지 않는다', () async {
    await sink.emit('kr_order', <String>{'RECON_MISMATCH'});
    db.execute(
      "CREATE TRIGGER no_cmd BEFORE INSERT ON command_inbox BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    expect(
      () => sink.acknowledge(
        commandId: 'a',
        payloadDigest: 'dg',
        alertId: 'AL-2026-11-05-kr_order-RECON_MISMATCH',
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(db.select('SELECT 1 FROM alert_ack'), isEmpty);
    expect(db.autocommit, isTrue);
  });

  test('🔴 사다리 — 15분 · 60분 · 건너뛰기 0 · 확인 = 멈춤 · 손절 안내 · P1 제외', () async {
    await sink.emit('kr_order', <String>{
      'RECON_MISMATCH',
      'ORDER_REJECTED',
      'BROKER_AUTH_FAILED',
    });
    await sink.emit('advice', <String>{'ADVICE_EXIT_URGENT'});
    final _Channel ch = _Channel();
    at(const Duration(minutes: 14, seconds: 59));
    expect(await sink.escalationTick(ch), isEmpty);
    at(const Duration(minutes: 15));
    expect(
      (await sink.escalationTick(ch))
          .map((AlertEscalationStep s) => '${s.alertId}#${s.step}'),
      <String>[
        'AL-2026-11-05-kr_order-BROKER_AUTH_FAILED#1',
        'AL-2026-11-05-kr_order-RECON_MISMATCH#1',
      ],
    );
    expect(await sink.escalationTick(ch), isEmpty);
    // RECON 확인 → 그 알림은 멈춤.
    sink.acknowledge(
      commandId: 'a',
      payloadDigest: 'dg',
      alertId: 'AL-2026-11-05-kr_order-RECON_MISMATCH',
    );
    at(const Duration(minutes: 60));
    expect(
      (await sink.escalationTick(ch))
          .map((AlertEscalationStep s) => '${s.alertId}#${s.step}'),
      <String>['AL-2026-11-05-kr_order-BROKER_AUTH_FAILED#2'],
    );
    expect(ch.sent, <String>[
      'AL-2026-11-05-kr_order-BROKER_AUTH_FAILED#1',
      'AL-2026-11-05-kr_order-RECON_MISMATCH#1',
      'AL-2026-11-05-kr_order-BROKER_AUTH_FAILED#2',
    ]);
    expect(
      db
          .select(
            'SELECT alert_id, step, escalated_at FROM alert_escalation ORDER BY escalated_at, alert_id, step',
          )
          .map((Row r) => r.values)
          .toList(),
      <List<Object?>>[
        <Object?>[
          'AL-2026-11-05-kr_order-BROKER_AUTH_FAILED',
          1,
          _t0.add(const Duration(minutes: 15)).toIso8601String(),
        ],
        <Object?>[
          'AL-2026-11-05-kr_order-RECON_MISMATCH',
          1,
          _t0.add(const Duration(minutes: 15)).toIso8601String(),
        ],
        <Object?>[
          'AL-2026-11-05-kr_order-BROKER_AUTH_FAILED',
          2,
          _t0.add(const Duration(minutes: 60)).toIso8601String(),
        ],
      ],
    );
  });

  test('🔴 늦게 돈 틱 = 1 → 2 차례로 한 번에(건너뛰기 0)', () async {
    await sink.emit('kr_order', <String>{'ORDER_OUTCOME_UNKNOWN'});
    final _Channel ch = _Channel();
    at(const Duration(hours: 3));
    expect(await sink.escalationTick(ch), hasLength(2));
    expect(ch.sent, <String>[
      'AL-2026-11-05-kr_order-ORDER_OUTCOME_UNKNOWN#1',
      'AL-2026-11-05-kr_order-ORDER_OUTCOME_UNKNOWN#2',
    ]);
  });

  test('🔴 채널 실패 = 미기록 · 던짐 · 다음 틱에 다시 · 뒤 단계 안 감', () async {
    await sink.emit('kr_order', <String>{'ORDER_OUTCOME_UNKNOWN'});
    final _Channel ch = _Channel()..fail = true;
    at(const Duration(hours: 3));
    await expectLater(sink.escalationTick(ch), throwsStateError);
    expect(db.select('SELECT 1 FROM alert_escalation'), isEmpty);
    ch.fail = false;
    expect(await sink.escalationTick(ch), hasLength(2));
    expect(
      db.select('SELECT COUNT(*) AS n FROM alert_escalation').single['n'],
      2,
    );
  });

  test('오프셋 없는 시각 = 형식 오류', () async {
    db.execute(
      "INSERT INTO alert_event(alert_id, raised_at, code, level, source, dedupe_key) VALUES ('x', '2026-11-05T00:00:00', 'RECON_MISMATCH', 'P0', 's', 'k')",
    );
    await expectLater(sink.escalationTick(_Channel()), throwsFormatException);
  });
}
