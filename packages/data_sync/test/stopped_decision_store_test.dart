// E13d2 — STOPPED 결정 저장 · 결정 B 집행(설계 13 §8 R61 T1~T8 · SPEC v2.40 04 §2 이름 시험).
//
// 🔵 잡는 것: ① 에피소드 = 저장 역사 재생 · 진입 날 ② 거부 = 명령 기록만(저널 · 재개 · 전략 · 램프 0)
//    ③ test_decision_b_releases_to_halted_once — B = 한 트랜잭션(저널 · SEV1 닫음 · 재개 행 · RETIRED 아닌 전 전략 CANDIDATE 상한 0 ·
//    전략 로그 · 램프 L1 · 명령) · 다음 스냅숏 = HALTED · 두 번째 결정 = 거부 ④ test_decision_a_c_keep_stopped — 기록 · SEV1 닫음만
//    ⑤ 명령 재전달 = 처음 결과 그대로 ⑥ 저널 id 중복 ⑦ 한 트랜잭션(램프 쓰기 실패 = 아무것도 안 남음) ⑧ 앞 에피소드 결정은 막지 않는다.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
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

final DateTime _t0 = DateTime.utc(
  2026,
  9,
  30,
  16,
); // 🔴 한국 10-01 01:00(UTC 날짜와 다르다)

String _day(int i) => DateTime.utc(
  2026,
  9,
  1,
).add(Duration(days: i)).toIso8601String().substring(0, 10);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteStoppedDecisionStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_sd_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteStoppedDecisionStore(db, mode: RunMode.live, clock: clock);
    for (final (String id, String state, double cap)
        in <(String, String, double)>[
          (P0sStrategyIds.sleeveB, 'ACTIVE', 1.0),
          (P0sStrategyIds.sleeveC, 'PROBATION', 0.5),
          ('OLD', 'RETIRED', 0.0),
        ]) {
      db.execute(
        'INSERT INTO strategy_state_current(strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
        <Object?>[id, state, '2026-01-01', cap],
      );
    }
    db.execute(
      "INSERT INTO ramp_state(id, level, pre_dst_level, updated_at) VALUES (1, 3, 2, 't')",
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  /// 스냅숏(날마다 낙폭) + 국면(bullFrom 부터 BULL).
  void seed(List<double> dds, {int bullFrom = 1 << 30, int from = 0}) {
    for (final (int k, double dd) in dds.indexed) {
      final int i = from + k;
      db.execute(
        'INSERT OR REPLACE INTO equity_snapshot(trade_date, total_equity, cash_krw, cash_usd, fx_rate, positions_value, '
        "high_water_mark, drawdown, breaker_level, mode) VALUES (?, ?, ?, 0, NULL, 0, 100, ?, 'NORMAL', 'LIVE')",
        <Object?>[_day(i), 100 * (1 + dd), 100 * (1 + dd), dd],
      );
      db.execute(
        'INSERT OR REPLACE INTO regime_score_daily(trade_date, status, direction_score, direction_state, config_hash) '
        "VALUES (?, 'OK', ?, ?, 'cfg')",
        <Object?>[
          _day(i),
          i >= bullFrom ? 60 : 40,
          i >= bullFrom ? 'BULL' : 'BEAR',
        ],
      );
    }
  }

  void eligible() => seed(<double>[
    -0.36,
    for (int i = 0; i < 19; i++) -0.30,
    for (int i = 0; i < 5; i++) -0.20,
  ], bullFrom: 20);

  void postmortem(String? text, {String entry = '2026-09-01'}) => db.execute(
    'INSERT OR REPLACE INTO incidents(incident_id, occurred_at, severity, category, description, resolved_at, postmortem, due_at) '
    "VALUES (?, 't', 'SEV1', 'BREAKER_STOPPED', 'd', NULL, ?, 'due')",
    <Object?>[stoppedIncidentIdOf(entry), text],
  );

  StoppedDecisionAnswers answers(
    StoppedDecisionKind k, {
    String id = 'J-SD-1',
    bool family = true,
  }) => StoppedDecisionAnswers(
    kind: k,
    decisionId: id,
    rationaleBefore: '원인 정리',
    expectedOutcome: '페이퍼부터',
    ruleCited: '03_운영 §6-4b',
    familyAgreement: family,
  );

  StoppedDecisionResult decide(
    StoppedDecisionKind k, {
    String cmd = 'c-1',
    String id = 'J-SD-1',
    bool family = true,
  }) => store.decide(
    commandId: cmd,
    payloadDigest: 'dg',
    answers: answers(k, id: id, family: family),
  );

  int count(String table, [String where = '1 = 1']) =>
      db.select('SELECT COUNT(*) AS n FROM $table WHERE $where').first['n']
          as int;

  List<(Object?, Object?, Object?)> strategies() =>
      <(Object?, Object?, Object?)>[
        for (final Row r in db.select(
          'SELECT strategy_id, state, capital_cap FROM strategy_state_current ORDER BY strategy_id',
        ))
          (r['strategy_id'], r['state'], r['capital_cap']),
      ];

  test('에피소드 = 저장 역사 재생 · 진입 날 · STOPPED 아니면 진입 날 없음', () {
    expect(
      (store.episode().replay.state.level, store.episode().entryDate),
      (BreakerLevel.normal, null),
    );
    seed(<double>[-0.10, -0.12]);
    seed(<double>[-0.36, -0.30, -0.30], from: 2);
    final StoppedEpisode e = store.episode();
    expect(
      (e.replay.state.level, e.replay.heldBars, e.entryDate),
      (BreakerLevel.stopped, 2, '2026-09-03'),
    );
  });

  test('거부 = 명령 기록만 — 아님 · 20일 · postmortem 없음 · 빈칸 · 가족 · 자격', () {
    expect(
      decide(StoppedDecisionKind.b, cmd: 'c0').reasonCode,
      'STOPPED_NOT_ACTIVE',
    );
    seed(<double>[-0.36, for (int i = 0; i < 10; i++) -0.30]);
    expect(
      decide(StoppedDecisionKind.a, cmd: 'c1').reasonCode,
      'STOPPED_WAIT_20D',
    );
    seed(<double>[for (int i = 0; i < 10; i++) -0.30], from: 11);
    expect(
      decide(StoppedDecisionKind.a, cmd: 'c2').reasonCode,
      'POSTMORTEM_MISSING',
    );
    postmortem(null);
    expect(
      decide(StoppedDecisionKind.a, cmd: 'c3').reasonCode,
      'POSTMORTEM_MISSING',
    );
    postmortem('   ');
    expect(
      decide(StoppedDecisionKind.a, cmd: 'c4').reasonCode,
      'POSTMORTEM_MISSING',
    );
    postmortem('원인 = 동조 하락');
    expect(
      decide(StoppedDecisionKind.a, cmd: 'c5', family: false).reasonCode,
      'FAMILY_AGREEMENT_MISSING',
    );
    expect(
      decide(StoppedDecisionKind.a, cmd: 'c6', id: ' ').reasonCode,
      'JOURNAL_REQUIRED',
    );
    expect(
      decide(StoppedDecisionKind.b, cmd: 'c7').reasonCode,
      'STOPPED_NOT_ELIGIBLE',
    );
    expect(
      count(
        'command_inbox',
        "state = 'REJECTED' AND kind = 'STOPPED_DECISION'",
      ),
      8,
    );
    expect(count('decision_journal'), 0);
    expect(count('breaker_release'), 0);
    expect(
      db.select('SELECT resolved_at FROM incidents').single['resolved_at'],
      isNull,
    );
    expect(
      db
          .select(
            "SELECT reject_reason_code, state_label, run_mode FROM command_inbox WHERE command_id = 'c7'",
          )
          .single
          .values,
      <Object?>['STOPPED_NOT_ELIGIBLE', '거부됨 — STOPPED_NOT_ELIGIBLE', null],
    );
  });

  test('🔴 test_decision_b_releases_to_halted_once — 한 트랜잭션 · 다음 스냅숏 HALTED · 두 번째 결정 거부', () {
    eligible();
    postmortem('원인 = 동조 하락');
    final StoppedDecisionResult r = decide(StoppedDecisionKind.b);
    expect(
      (r.executed, r.replayed, r.reasonCode, r.decisionId, r.releaseId),
      (true, false, null, 'J-SD-1', 'BR-J-SD-1'),
    );
    final Row j = db
        .select("SELECT * FROM decision_journal WHERE journal_id = 'J-SD-1'")
        .single;
    expect(
      (
        j['kind'],
        j['trade_date'],
        j['strategy_id'],
        j['is_deviation'],
        j['rationale_before'],
        j['expected_outcome'],
        j['rule_cited'],
      ),
      (
        'STOPPED_DECISION',
        '2026-10-01',
        P0sStrategyIds.deposit,
        0,
        '원인 정리',
        '페이퍼부터',
        '03_운영 §6-4b',
      ),
    );
    expect(jsonDecode(j['signal_value'] as String), <String, Object?>{
      'decision': 'B',
      'held_bars': 24,
      'eligible': true,
      'entry_date': '2026-09-01',
      'incident_id': 'SEV1-BREAKER_STOPPED-2026-09-01',
      'family_agreement': true,
    });
    expect(
      db.select('SELECT resolved_at FROM incidents').single['resolved_at'],
      _t0.toIso8601String(),
    );
    expect(db.select('SELECT * FROM breaker_release').single.values, <Object?>[
      'BR-J-SD-1',
      '2026-10-01',
      'J-SD-1',
      _t0.toIso8601String(),
    ]);
    expect(strategies(), <(Object?, Object?, Object?)>[
      ('OLD', 'RETIRED', 0.0),
      (P0sStrategyIds.sleeveB, 'CANDIDATE', 0.0),
      (P0sStrategyIds.sleeveC, 'CANDIDATE', 0.0),
    ]);
    expect(
      db
          .select(
            'SELECT strategy_id, from_state, to_state, trigger_value, threshold_registered, reason FROM strategy_state_log ORDER BY strategy_id',
          )
          .map((Row x) => x.values)
          .toList(),
      <List<Object?>>[
        <Object?>[
          P0sStrategyIds.sleeveB,
          'ACTIVE',
          'CANDIDATE',
          -0.20,
          -0.25,
          'STOPPED_DECISION_B · J-SD-1',
        ],
        <Object?>[
          P0sStrategyIds.sleeveC,
          'PROBATION',
          'CANDIDATE',
          -0.20,
          -0.25,
          'STOPPED_DECISION_B · J-SD-1',
        ],
      ],
    );
    expect(
      db.select('SELECT level, pre_dst_level FROM ramp_state').single.values,
      <Object?>[1, null],
    );
    expect(
      db
          .select(
            "SELECT state, decision_id FROM command_inbox WHERE command_id = 'c-1'",
          )
          .single
          .values,
      <Object?>['EXECUTED', 'J-SD-1'],
    );
    // 오늘 스냅숏 전 = 아직 STOPPED · 두 번째 결정 = 이미 결정.
    expect(store.episode().replay.state.level, BreakerLevel.stopped);
    expect(
      decide(StoppedDecisionKind.b, cmd: 'c-2', id: 'J-SD-2').reasonCode,
      'DECISION_ALREADY_MADE',
    );
    // 다음 스냅숏(오늘) = HALTED(재개 행 날 이상인 첫 재생 날).
    seed(<double>[-0.20], from: 30, bullFrom: 20); // 2026-10-01
    expect(
      (store.episode().replay.state.level, store.episode().replay.heldBars),
      (BreakerLevel.halted, 0),
    );
    expect(
      decide(StoppedDecisionKind.b, cmd: 'c-3', id: 'J-SD-3').reasonCode,
      'STOPPED_NOT_ACTIVE',
    );
    expect(count('breaker_release'), 1);
  });

  test(
    '🔴 test_decision_a_c_keep_stopped — 기록 · SEV1 닫음만 · 레벨 · 전략 · 램프 무변경',
    () {
      for (final StoppedDecisionKind k in <StoppedDecisionKind>[
        StoppedDecisionKind.a,
        StoppedDecisionKind.c,
      ]) {
        db.execute('DELETE FROM decision_journal');
        db.execute('DELETE FROM command_inbox');
        eligible();
        postmortem('원인 정리');
        final StoppedDecisionResult r = decide(k);
        expect((r.executed, r.releaseId), (true, null));
        expect(
          (jsonDecode(
            db
                    .select('SELECT signal_value FROM decision_journal')
                    .single['signal_value']
                as String,
          ) as Map<String, dynamic>)['decision'],
          k.code,
        );
        expect(
          db
              .select('SELECT action_taken FROM decision_journal')
              .single['action_taken'],
          '{"stopped_decision":"${k.code}"}',
        );
        expect(
          db.select('SELECT resolved_at FROM incidents').single['resolved_at'],
          isNotNull,
        );
        expect(count('breaker_release'), 0);
        expect(strategies(), <(Object?, Object?, Object?)>[
          ('OLD', 'RETIRED', 0.0),
          (P0sStrategyIds.sleeveB, 'ACTIVE', 1.0),
          (P0sStrategyIds.sleeveC, 'PROBATION', 0.5),
        ]);
        expect(count('strategy_state_log'), 0);
        expect(
          db
              .select('SELECT level, pre_dst_level FROM ramp_state')
              .single
              .values,
          <Object?>[3, 2],
        );
        expect(store.episode().replay.state.level, BreakerLevel.stopped);
        expect(
          decide(StoppedDecisionKind.b, cmd: 'c-x', id: 'J-X').reasonCode,
          'DECISION_ALREADY_MADE',
        );
      }
    },
  );

  test('같은 command_id 재전달 = 처음 결과 그대로(재개 id 포함) · 새 행 0 · 저널 id 중복', () {
    eligible();
    postmortem('원인');
    db.execute(
      "INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, created_at) VALUES ('J-TAKEN', '2026-08-01', 'P0S', '{}', '{}', 't')",
    );
    expect(
      decide(StoppedDecisionKind.b, cmd: 'c-0', id: 'J-TAKEN').reasonCode,
      'JOURNAL_ID_TAKEN',
    );
    decide(StoppedDecisionKind.b);
    final StoppedDecisionResult again = decide(StoppedDecisionKind.b);
    expect(
      (again.executed, again.replayed, again.decisionId, again.releaseId),
      (true, true, 'J-SD-1', 'BR-J-SD-1'),
    );
    final StoppedDecisionResult rejectedAgain = decide(
      StoppedDecisionKind.b,
      cmd: 'c-0',
      id: 'J-TAKEN',
    );
    expect(
      (
        rejectedAgain.executed,
        rejectedAgain.replayed,
        rejectedAgain.reasonCode,
        rejectedAgain.releaseId,
      ),
      (false, true, 'JOURNAL_ID_TAKEN', null),
    );
    expect(count('breaker_release'), 1);
    expect(count('command_inbox'), 2);
  });

  test('🔴 한 트랜잭션 — 램프 쓰기가 실패하면 저널 · 재개 · 전략 · SEV1 · 명령 모두 없음', () {
    eligible();
    postmortem('원인');
    db.execute(
      "CREATE TRIGGER no_ramp BEFORE INSERT ON ramp_state BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    db.execute('DELETE FROM ramp_state');
    expect(
      () => decide(StoppedDecisionKind.b),
      throwsA(isA<SqliteException>()),
    );
    expect(
      (
        count('decision_journal'),
        count('breaker_release'),
        count('strategy_state_log'),
        count('command_inbox'),
      ),
      (0, 0, 0, 0),
    );
    expect(
      db.select('SELECT resolved_at FROM incidents').single['resolved_at'],
      isNull,
    );
    expect(strategies()[1], (P0sStrategyIds.sleeveB, 'ACTIVE', 1.0));
    expect(db.autocommit, isTrue);
  });

  test('앞 에피소드의 결정은 이번 에피소드를 막지 않는다', () {
    db.execute(
      "INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, kind, created_at) VALUES ('J-OLD', '2026-08-31', 'P0S', '{}', '{}', 'STOPPED_DECISION', 't')",
    );
    // 이번 에피소드 안의 다른 저널(킬스위치 기록)도 막지 않는다.
    db.execute(
      "INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, kind, created_at) VALUES ('J-KS', '2026-09-10', 'P0S', '{}', '{}', 'KILL_SWITCH_CHECKLIST', 't')",
    );
    eligible();
    postmortem('원인');
    expect(decide(StoppedDecisionKind.a).executed, isTrue);
  });
}
