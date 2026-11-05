// E13e2 — postmortem 쓰기 · 기한 넘김 읽기(설계 13 §8 R63 V2 · V3).
//
// 🔵 잡는 것: ① 거부 = 명령 기록만(없음 · 빈칸 · 이미) ② 통과 = 한 트랜잭션: 글(앞뒤 공백 뺌) + SEV2 · SEV3 닫음 + 명령 ·
//    SEV1 = 열린 채(STOPPED 결정이 닫는다) · 이미 닫힌 건의 닫힌 시각은 그대로 ③ 🔴 한 번만 ④ 명령 재전달 = 처음 결과
//    ⑤ 한 트랜잭션 ⑥ 기한 넘김 = 빈칸 ∧ 기한 < 지금 · 기한 오름차순.
import 'dart:io';

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

final DateTime _t0 = DateTime.utc(2026, 11, 5, 3);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteIncidentStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_inc_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteIncidentStore(db, clock: clock);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void incident(
    String id,
    String severity, {
    String? due,
    String? postmortem,
    String? resolved,
  }) => db.execute(
    'INSERT INTO incidents(incident_id, occurred_at, severity, category, description, resolved_at, postmortem, due_at) '
    "VALUES (?, '2026-11-01T00:00:00.000Z', ?, 'C', 'd', ?, ?, ?)",
    <Object?>[id, severity, resolved, postmortem, due],
  );

  Row row(String id) => db.select(
    'SELECT * FROM incidents WHERE incident_id = ?',
    <Object?>[id],
  ).single;

  PostmortemResult write(String id, String text, {String cmd = 'c-1'}) =>
      store.recordPostmortem(
        commandId: cmd,
        payloadDigest: 'dg',
        incidentId: id,
        text: text,
      );

  test('거부 = 명령 기록만 — 없음 · 빈칸 · 이미', () {
    incident('S2', 'SEV2', postmortem: '앞 글');
    incident('S2b', 'SEV2');
    expect(write('NONE', '글', cmd: 'a').reasonCode, 'INCIDENT_NOT_FOUND');
    expect(write('S2b', '  ', cmd: 'b').reasonCode, 'POSTMORTEM_BLANK');
    expect(
      write('S2', '새 글', cmd: 'c').reasonCode,
      'POSTMORTEM_ALREADY_RECORDED',
    );
    expect(row('S2')['postmortem'], '앞 글');
    expect(row('S2b')['postmortem'], isNull);
    expect(
      db
          .select(
            'SELECT command_id, kind, state, reject_reason_code, decision_id FROM command_inbox ORDER BY command_id',
          )
          .map((Row r) => r.values)
          .toList(),
      <List<Object?>>[
        <Object?>[
          'a',
          'INCIDENT_POSTMORTEM',
          'REJECTED',
          'INCIDENT_NOT_FOUND',
          'NONE',
        ],
        <Object?>[
          'b',
          'INCIDENT_POSTMORTEM',
          'REJECTED',
          'POSTMORTEM_BLANK',
          'S2b',
        ],
        <Object?>[
          'c',
          'INCIDENT_POSTMORTEM',
          'REJECTED',
          'POSTMORTEM_ALREADY_RECORDED',
          'S2',
        ],
      ],
    );
  });

  test('🔴 SEV2 = 글 + 닫음 · SEV1 = 글만(열린 채) · 이미 닫힌 건 = 닫힌 시각 그대로 · 한 번만', () {
    incident('S2', 'SEV2');
    incident('S1', 'SEV1');
    incident('S3', 'SEV3', resolved: '2026-11-02T00:00:00.000Z');
    final PostmortemResult a = write('S2', '  원인 = 수동 주문  ', cmd: 'a');
    expect(
      (a.executed, a.replayed, a.reasonCode, a.closed),
      (true, false, null, true),
    );
    expect(
      (row('S2')['postmortem'], row('S2')['resolved_at']),
      ('원인 = 수동 주문', _t0.toIso8601String()),
    );
    final PostmortemResult b = write('S1', '원인 = 동조 하락', cmd: 'b');
    expect((b.executed, b.closed), (true, false));
    expect(
      (row('S1')['postmortem'], row('S1')['resolved_at']),
      ('원인 = 동조 하락', null),
    );
    write('S3', '글', cmd: 'c');
    expect(row('S3')['resolved_at'], '2026-11-02T00:00:00.000Z');
    expect(
      write('S2', '두 번째', cmd: 'd').reasonCode,
      'POSTMORTEM_ALREADY_RECORDED',
    );
    expect(
      db
          .select(
            "SELECT state, decision_id FROM command_inbox WHERE command_id = 'a'",
          )
          .single
          .values,
      <Object?>['EXECUTED', 'S2'],
    );
  });

  test('같은 command_id 재전달 = 처음 결과(닫힘 포함) · 새 행 0', () {
    incident('S2', 'SEV2');
    write('S2', '원인');
    final PostmortemResult again = write('S2', '다른 글');
    expect(
      (again.executed, again.replayed, again.closed, again.reasonCode),
      (true, true, true, null),
    );
    expect(row('S2')['postmortem'], '원인');
    final PostmortemResult rej = write('NONE', '글', cmd: 'r');
    final PostmortemResult rejAgain = write('NONE', '글', cmd: 'r');
    expect(
      (
        rej.replayed,
        rejAgain.replayed,
        rejAgain.executed,
        rejAgain.reasonCode,
        rejAgain.closed,
      ),
      (false, true, false, 'INCIDENT_NOT_FOUND', false),
    );
    expect(db.select('SELECT COUNT(*) AS n FROM command_inbox').single['n'], 2);
  });

  test('🔴 한 트랜잭션 — 명령 기록이 실패하면 글도 남지 않는다', () {
    incident('S2', 'SEV2');
    db.execute(
      "CREATE TRIGGER no_cmd BEFORE INSERT ON command_inbox BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    expect(() => write('S2', '원인'), throwsA(isA<SqliteException>()));
    expect((row('S2')['postmortem'], row('S2')['resolved_at']), (null, null));
    expect(db.autocommit, isTrue);
  });

  test('기한 넘김 = 빈칸 ∧ 기한 < 지금 · 기한 오름차순 · 기한 없는 건 제외', () {
    incident('late-2', 'SEV2', due: '2026-11-04T00:00:00.000Z');
    incident(
      'late-1',
      'SEV1',
      due: '2026-11-03T00:00:00.000Z',
      postmortem: '  ',
    );
    incident('done', 'SEV2', due: '2026-11-01T00:00:00.000Z', postmortem: '글');
    incident('future', 'SEV2', due: '2026-11-09T00:00:00.000Z');
    incident('now', 'SEV2', due: _t0.toIso8601String());
    incident('nodue', 'SEV3');
    final List<OverduePostmortem> o = store.overduePostmortems();
    expect(
      o.map(
        (OverduePostmortem x) =>
            (x.incidentId, x.severity, x.category, x.dueAtUtc),
      ),
      <(String, String, String, DateTime)>[
        ('late-1', 'SEV1', 'C', DateTime.utc(2026, 11, 3)),
        ('late-2', 'SEV2', 'C', DateTime.utc(2026, 11, 4)),
      ],
    );
    clock.at = DateTime.utc(2026, 11, 10);
    expect(
      store.overduePostmortems().map((OverduePostmortem x) => x.incidentId),
      <String>['late-1', 'late-2', 'now', 'future'],
    );
  });
}
