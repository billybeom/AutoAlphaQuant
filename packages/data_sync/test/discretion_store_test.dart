// E13f1 — 재량 예산 원장 쓰기 · 예산 셈 읽기(설계 13 §8 R64 W3~W6).
//
// 🔵 잡는 것: ① 반영 = 한 트랜잭션: 조정 1행(id `DA-{저널}` · 신뢰 시각 · reason = 저널 근거) + 명령
//    ② 거부 = 명령 기록만 · 사유 전부 오름차순 · 첫 사유 = reject_reason_code ③ 저널 연결 4갈래(없음 · 다른 kind ·
//    사전 필드 빈칸 · 이미 쓴 저널) ④ 신뢰 시각 모름 = 거부 ⑤ 명령 재전달 = 처음 결과 ⑥ 한 트랜잭션
//    ⑦ 롤링 셈 = 한국 날짜(UTC 15시 넘은 시각 = 다음 날) · 5회째 거부 ⑧ 예산 = 신뢰 시각 모름 → null.
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show DiscretionBudget, TrustedClock, discretionBudgetText;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 24, 1);
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

// 한국 2026-08-24 09:00.
final DateTime _t0 = DateTime.utc(2026, 8, 24);

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  late SqliteDiscretionStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_disc_');
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteDiscretionStore(db, clock: _Clock(), trusted: trusted);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void journal(
    String id, {
    String? kind = 'DISCRETION',
    String? before = '  추세 전환 근거  ',
    String? expected = '기대',
    String? rule = 'RULE_DISCRETION_BUDGET',
  }) => db.execute(
    'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
    "rationale_before, expected_outcome, rule_cited, kind, note, created_at) VALUES (?, '2026-08-24', 'P0S', '{}', '{}', 1, ?, ?, ?, ?, NULL, '2026-08-24T00:00:00.000Z')",
    <Object?>[id, before, expected, rule, kind],
  );

  void used(String id, String appliedAt, {String? decisionId}) => db.execute(
    'INSERT INTO discretion_adjustment(adjustment_id, applied_at, delta_pct, decision_id, reason) VALUES (?, ?, 0.05, ?, ?)',
    <Object?>[id, appliedAt, decisionId ?? 'old-$id', '옛 근거'],
  );

  DiscretionResult ask(
    String cmd, {
    double delta = 0.05,
    String? decisionId = 'DJ-1',
  }) => store.requestAdjustment(
    commandId: cmd,
    payloadDigest: 'dg',
    deltaPct: delta,
    decisionId: decisionId,
  );

  List<Object?> command(String id) => db
      .select(
        'SELECT kind, state, state_label, reject_reason_code, decision_id FROM command_inbox WHERE command_id = ?',
        <Object?>[id],
      )
      .single
      .values;

  test('반영 = 조정 1행(신뢰 시각 · 저널 근거) + 명령 EXECUTED', () {
    journal('DJ-1');
    final DiscretionResult r = ask('c-1', delta: -0.10);
    expect((r.executed, r.replayed, r.adjustmentId), (true, false, 'DA-DJ-1'));
    expect(r.reasonCodes, isEmpty);
    expect(
      db.select('SELECT * FROM discretion_adjustment').single.values,
      <Object?>['DA-DJ-1', _t0.toIso8601String(), -0.10, 'DJ-1', '추세 전환 근거'],
    );
    expect(command('c-1'), <Object?>[
      'DISCRETION_ADJUST',
      'EXECUTED',
      '실행됨',
      null,
      'DJ-1',
    ]);
  });

  test('🔴 거부 = 명령만 · 사유 전부 오름차순 · 첫 사유 = 코드 칸', () {
    for (final String d in <String>[
      '2026-01-01',
      '2026-02-01',
      '2026-03-01',
      '2026-04-01',
    ]) {
      used(d, '${d}T00:00:00.000Z');
    }
    final DiscretionResult r = ask('c-1', delta: 0.2, decisionId: null);
    expect(r.executed, isFalse);
    expect(r.reasonCodes, <String>[
      'COUNT_EXCEEDED',
      'DELTA_EXCEEDED',
      'JOURNAL_MISSING',
    ]);
    expect(command('c-1'), <Object?>[
      'DISCRETION_ADJUST',
      'REJECTED',
      '거부됨 — COUNT_EXCEEDED · DELTA_EXCEEDED · JOURNAL_MISSING',
      'COUNT_EXCEEDED',
      null,
    ]);
    expect(
      db.select('SELECT COUNT(*) AS n FROM discretion_adjustment').single['n'],
      4,
    );
  });

  test('🔴 저널 연결 4갈래 = JOURNAL_MISSING', () {
    journal('K', kind: 'KILL_SWITCH_RESUME');
    journal('B', expected: '  ');
    journal('U');
    used('x', '2026-01-01T00:00:00.000Z', decisionId: 'U');
    for (final (String cmd, String? id) in <(String, String?)>[
      ('a', 'NONE'),
      ('b', 'K'),
      ('c', 'B'),
      ('d', 'U'),
      ('e', '  '),
    ]) {
      expect(ask(cmd, decisionId: id).reasonCodes, <String>[
        'JOURNAL_MISSING',
      ], reason: cmd);
    }
    expect(
      db.select('SELECT COUNT(*) AS n FROM discretion_adjustment').single['n'],
      1,
    );
  });

  test('신뢰 시각 모름 = 거부(조정 0) · 예산 = null', () {
    journal('DJ-1');
    trusted.at = null;
    final DiscretionResult r = ask('c-1');
    expect(r.executed, isFalse);
    expect(r.reasonCodes, <String>['TRUSTED_TIME_UNKNOWN']);
    expect(command('c-1')[3], 'TRUSTED_TIME_UNKNOWN');
    expect(db.select('SELECT 1 FROM discretion_adjustment'), isEmpty);
    expect(store.budget(), isNull);
  });

  test('같은 command_id 재전달 = 처음 결과(반영 · 거부 사유 전부) · 새 행 0', () {
    journal('DJ-1');
    ask('c-1');
    final DiscretionResult again = ask('c-1', delta: 0.5);
    expect(
      (again.executed, again.replayed, again.adjustmentId),
      (true, true, 'DA-DJ-1'),
    );
    expect(again.reasonCodes, isEmpty);
    final DiscretionResult rej = ask('r', delta: 0.5, decisionId: null);
    final DiscretionResult rejAgain = ask('r');
    expect(rej.replayed, isFalse);
    expect(
      (rejAgain.executed, rejAgain.replayed, rejAgain.adjustmentId),
      (false, true, null),
    );
    expect(rejAgain.reasonCodes, <String>['DELTA_EXCEEDED', 'JOURNAL_MISSING']);
    expect(
      db.select('SELECT COUNT(*) AS n FROM discretion_adjustment').single['n'],
      1,
    );
    expect(db.select('SELECT COUNT(*) AS n FROM command_inbox').single['n'], 2);
  });

  test('🔴 한 트랜잭션 — 명령 기록이 실패하면 조정도 남지 않는다', () {
    journal('DJ-1');
    db.execute(
      "CREATE TRIGGER no_cmd BEFORE INSERT ON command_inbox BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    expect(() => ask('c-1'), throwsA(isA<SqliteException>()));
    expect(db.select('SELECT 1 FROM discretion_adjustment'), isEmpty);
    expect(db.autocommit, isTrue);
  });

  test('롤링 셈 = 한국 날짜 — UTC 전날 15시 넘은 사용은 다음 날 · 5회째 거부 · 예산 문장', () {
    // 한국 2025-08-24 00:30 = UTC 2025-08-23 15:30 → 오늘(2026-08-24) 창 첫날에 든다.
    used('a', '2025-08-23T15:30:00.000Z');
    used('b', '2025-08-23T14:59:00.000Z'); // 한국 2025-08-23 23:59 → 창 밖
    used('c', '2026-01-15T00:00:00+09:00');
    used('d', '2026-05-20T00:00:00.000Z');
    expect(store.useDates()..sort(), <String>[
      '2025-08-23',
      '2025-08-24',
      '2026-01-15',
      '2026-05-20',
    ]);
    final DiscretionBudget b = store.budget()!;
    expect((b.used, b.remaining, b.nextRecoveryDate), (3, 1, '2026-08-25'));
    journal('DJ-1');
    journal('DJ-2');
    expect(ask('c-1', decisionId: 'DJ-1').executed, isTrue);
    expect(ask('c-2', decisionId: 'DJ-2').reasonCodes, <String>[
      'COUNT_EXCEEDED',
    ]);
    expect(
      discretionBudgetText(store.budget()),
      '재량 예산 소진 — 12개월 4회 중 4회 사용 · 다음 회복 2026-08-25',
    );
  });

  test('오프셋 없는 시각 = 형식 오류(기기 지역 시각으로 읽지 않는다)', () {
    used('a', '2026-01-01T00:00:00');
    expect(store.useDates, throwsFormatException);
  });
}
