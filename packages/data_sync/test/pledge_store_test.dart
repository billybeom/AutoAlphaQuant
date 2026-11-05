// E13g2 — 서약 저장 · 지금 판 · 재생 대상 · «재생함» 기록(설계 13 §8 R67 Z1~Z8).
//
// 🔵 잡는 것: ① 첫 판 = 언제든 · 한 번만 · 문장 앞뒤 공백 뺌 · 판 1 ② 편집 = 12월만 · 새 판(옛 판 그대로) · 같은 문장 ·
//    저널 4갈래(없음 · 사전 필드 빈칸 · 다른 판이 씀 · 빈 id) ③ 신뢰 시각 모름 ④ 재전달 = 처음 결과 ⑤ 한 트랜잭션
//    ⑥ 재생 = 서약 · 스냅숏 있을 때만 · 건너뛰어도 «재생함» 한 번에 · 회복해도 남음 · 새 고점 = 새 에피소드
//    ⑦ 0줄 = 블록 부재 ⑧ 오프셋 없는 시각.
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show Pledge, PledgeReplayDue, TrustedClock;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 1, 9, 12);
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 3, 1);
final DateTime _dec = DateTime.utc(2026, 12, 10);

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  late SqlitePledgeStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_pl_');
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqlitePledgeStore(db, clock: _Clock(), trusted: trusted);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void journal(
    String id, {
    String? before = '근거',
    String? expected = '기대',
    String? rule = 'RULE_OTHER',
  }) => db.execute(
    'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
    "rationale_before, expected_outcome, rule_cited, kind, note, created_at) VALUES (?, '2026-12-10', 'P0S', '{}', '{}', 0, ?, ?, ?, NULL, NULL, '2026-12-10T00:00:00.000Z')",
    <Object?>[id, before, expected, rule],
  );

  void dd(String date, double v) => db.execute(
    'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, 100, 0, 100, 120, ?, 'LIVE')",
    <Object?>[date, v],
  );

  int n = 0;
  PledgeResult first(List<String> s, {String id = 'ON-1', String? cmd}) =>
      store.writeFirst(
        commandId: cmd ?? 'w-${n++}',
        payloadDigest: 'dg',
        sentences: s,
        decisionId: id,
      );

  PledgeResult edit(List<String> s, String id, {String? cmd}) => store.edit(
    commandId: cmd ?? 'e-${n++}',
    payloadDigest: 'dg',
    sentences: s,
    decisionId: id,
  );

  test('첫 판 = 언제든(3월) · 앞뒤 공백 뺌 · 판 1 · 한 번만', () {
    expect(store.currentPledge(), isNull);
    expect(store.pledgeLines(), isEmpty);
    expect(first(const <String>[' 하나 ', '둘', '셋']).executed, isTrue);
    final Pledge p = store.currentPledge()!;
    expect((p.version, p.writtenAtUtc), (1, _t0));
    expect(p.lines, <String>['하나', '둘', '셋']);
    expect(store.pledgeLines(), <String>['하나', '둘', '셋']);
    expect(
      db.select('SELECT pledge_id, decision_id FROM pledge').single.values,
      <Object?>['PL-1', 'ON-1'],
    );
    expect(
      first(const <String>['가', '나', '다']).reasonCode,
      'PLEDGE_ALREADY_WRITTEN',
    );
    expect(
      first(const <String>['가', ' ', '다']).reasonCode,
      'PLEDGE_ALREADY_WRITTEN',
    );
  });

  test('첫 판 거부 = 명령만 — 문장 빈칸 · 빈 id', () {
    expect(
      first(const <String>['하나', '  ', '셋']).reasonCode,
      'PLEDGE_SENTENCES_MISSING',
    );
    expect(
      first(const <String>['하나', '둘', '셋'], id: ' ').reasonCode,
      'PLEDGE_JOURNAL_MISSING',
    );
    expect(db.select('SELECT 1 FROM pledge'), isEmpty);
    expect(
      db
          .select(
            "SELECT COUNT(*) AS n FROM command_inbox WHERE kind = 'PLEDGE_WRITE' AND state = 'REJECTED'",
          )
          .single['n'],
      2,
    );
  });

  test('🔴 편집 = 12월만 · 새 판(옛 판 그대로) · 같은 문장 · 저널 4갈래', () {
    expect(
      edit(const <String>['가', '나', '다'], 'J1').reasonCode,
      'PLEDGE_NOT_WRITTEN',
    );
    expect(first(const <String>['하나', '둘', '셋']).executed, isTrue);
    journal('J1');
    journal('J2', rule: ' ');
    journal('J3', before: null);
    journal('J4', expected: '  ');
    expect(
      edit(const <String>['가', '나', '다'], 'J1').reasonCode,
      'PLEDGE_OUT_OF_WINDOW',
    );
    trusted.at = _dec;
    expect(
      edit(const <String>['하나', '둘', '셋'], 'J1').reasonCode,
      'PLEDGE_UNCHANGED',
    );
    expect(
      edit(const <String>['가', '나', '다'], 'NONE').reasonCode,
      'PLEDGE_JOURNAL_MISSING',
    );
    expect(
      edit(const <String>['가', '나', '다'], 'J2').reasonCode,
      'PLEDGE_JOURNAL_MISSING',
    );
    for (final String id in <String>['J3', 'J4']) {
      expect(
        edit(const <String>['가', '나', '다'], id).reasonCode,
        'PLEDGE_JOURNAL_MISSING',
        reason: id,
      );
    }
    expect(
      edit(const <String>['가', '나', '다'], ' ').reasonCode,
      'PLEDGE_JOURNAL_MISSING',
    );
    expect(edit(const <String>[' 가', '나', '다 '], 'J1').executed, isTrue);
    final Pledge p = store.currentPledge()!;
    expect((p.version, p.writtenAtUtc), (2, _dec));
    expect(p.lines, <String>['가', '나', '다']);
    // 같은 저널로 다시 = 이미 쓴 저널.
    expect(
      edit(const <String>['라', '마', '바'], 'J1').reasonCode,
      'PLEDGE_JOURNAL_MISSING',
    );
    expect(
      db
          .select(
            'SELECT version, sentence_1, decision_id FROM pledge ORDER BY version',
          )
          .map((Row r) => r.values)
          .toList(),
      <List<Object?>>[
        <Object?>[1, '하나', 'ON-1'],
        <Object?>[2, '가', 'J1'],
      ],
    );
  });

  test('신뢰 시각 모름 = 첫 판 · 편집 모두 거부', () {
    trusted.at = null;
    expect(
      first(const <String>['하나', '둘', '셋']).reasonCode,
      'TRUSTED_TIME_UNKNOWN',
    );
    trusted.at = _t0;
    expect(first(const <String>['하나', '둘', '셋']).executed, isTrue);
    journal('J1');
    trusted.at = null;
    expect(
      edit(const <String>['가', '나', '다'], 'J1').reasonCode,
      'TRUSTED_TIME_UNKNOWN',
    );
    expect(db.select('SELECT COUNT(*) AS n FROM pledge').single['n'], 1);
  });

  test('같은 command_id 재전달 = 처음 결과 · 새 행 0', () {
    expect(first(const <String>['하나', '둘', '셋'], cmd: 'w').executed, isTrue);
    final PledgeResult again = first(const <String>['가', '나', '다'], cmd: 'w');
    expect(
      (again.executed, again.replayed, again.reasonCode),
      (true, true, null),
    );
    final PledgeResult rej = edit(const <String>['가', '나', '다'], 'J', cmd: 'e');
    final PledgeResult rejAgain = edit(
      const <String>['가', '나', '다'],
      'J',
      cmd: 'e',
    );
    expect((rej.replayed, rej.reasonCode), (false, 'PLEDGE_OUT_OF_WINDOW'));
    expect(
      (rejAgain.executed, rejAgain.replayed, rejAgain.reasonCode),
      (false, true, 'PLEDGE_OUT_OF_WINDOW'),
    );
    expect(db.select('SELECT COUNT(*) AS n FROM pledge').single['n'], 1);
  });

  test('🔴 한 트랜잭션 — 명령 기록이 실패하면 판도 남지 않는다', () {
    db.execute(
      "CREATE TRIGGER no_cmd BEFORE INSERT ON command_inbox BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    expect(
      () => first(const <String>['하나', '둘', '셋']),
      throwsA(isA<SqliteException>()),
    );
    expect(db.select('SELECT 1 FROM pledge'), isEmpty);
    expect(db.autocommit, isTrue);
  });

  test('🔴 재생 — 서약 · 스냅숏 있을 때만 · 건너뛰어도 한 번에 · 회복해도 남음 · 새 고점 = 다시', () {
    dd('2026-01-01', 0);
    dd('2026-01-02', -0.16);
    // 서약 없음 = 대상 없음.
    expect(store.replayDue(), isNull);
    expect(store.markReplayShown(), 0);
    expect(first(const <String>['하나', '둘', '셋']).executed, isTrue);
    final PledgeReplayDue d = store.replayDue()!;
    expect((d.peakDate, d.deepest), ('2026-01-01', -0.15));
    expect(d.thresholds, <double>[-0.10, -0.15]);
    // 회복해도(−0.05) 같은 에피소드 = 아직 남음.
    dd('2026-01-05', -0.05);
    expect(store.replayDue()!.thresholds, <double>[-0.10, -0.15]);
    expect(store.markReplayShown(), 2);
    expect(store.replayDue(), isNull);
    expect(store.markReplayShown(), 0);
    expect(
      db
          .select(
            'SELECT threshold_dd, episode_peak_date, shown_at FROM pledge_replay ORDER BY threshold_dd DESC',
          )
          .map((Row r) => r.values)
          .toList(),
      <List<Object?>>[
        <Object?>[
          -0.10,
          '2026-01-01',
          DateTime.utc(2026, 1, 9, 12).toIso8601String(),
        ],
        <Object?>[
          -0.15,
          '2026-01-01',
          DateTime.utc(2026, 1, 9, 12).toIso8601String(),
        ],
      ],
    );
    // 더 깊어지면 새 임계만.
    dd('2026-01-06', -0.21);
    expect(store.replayDue()!.thresholds, <double>[-0.20]);
    // 새 고점 = 새 에피소드 — 다시 −10% 에 닿으면 다시.
    dd('2026-01-07', 0);
    expect(store.replayDue(), isNull);
    dd('2026-01-08', -0.10);
    final PledgeReplayDue again = store.replayDue()!;
    expect(again.peakDate, '2026-01-07');
    expect(again.thresholds, <double>[-0.10]);
  });

  test('오프셋 없는 시각 = 형식 오류', () {
    db.execute(
      "INSERT INTO pledge(pledge_id, version, sentence_1, sentence_2, sentence_3, written_at, decision_id) VALUES ('x', 1, 'a', 'b', 'c', '2026-01-01T00:00:00', 'd')",
    );
    expect(store.currentPledge, throwsFormatException);
  });
}
