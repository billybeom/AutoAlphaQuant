// E13f2 — 수동 개입 5단계 저장(설계 13 §8 R65 X3~X9).
//
// 🔵 잡는 것: ① 1→5 전 과정(신뢰 시각 · 냉각 24h · 같은 저널) · 행 = append ② 거부 = 명령 기록만
//    ③ 🔴 한 번에 한 세션 · 만료 세션은 새 세션을 막지 않는다 ④ 3단계 저널 6갈래(없음 · 이탈 아님 ·
//    사전 필드 빈칸 · 다른 세션이 씀 · 🔴 예산 소진 = 메모) ⑤ 신뢰 시각 모름 = 닫기도 거부
//    ⑥ 재전달 = 처음 결과(닫힘 포함) ⑦ 한 트랜잭션 ⑧ 최근 열린 세션.
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show InterventionOutcome, InterventionState, TrustedClock;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 11, 5, 23);
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 5);
const InterventionOutcome _pass = InterventionOutcome.passed;

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  late SqliteInterventionStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_iv_');
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteInterventionStore(db, clock: _Clock(), trusted: trusted);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void journal(
    String id, {
    int dev = 1,
    String? before = '근거',
    String? expected = '기대',
    String? rule = 'RULE_DISCRETION_BUDGET',
    String? note,
  }) => db.execute(
    'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
    "rationale_before, expected_outcome, rule_cited, kind, note, created_at) VALUES (?, '2026-11-05', 'P0S', '{}', '{}', ?, ?, ?, ?, 'DISCRETION', ?, '2026-11-05T00:00:00.000Z')",
    <Object?>[id, dev, before, expected, rule, note],
  );

  int n = 0;
  InterventionStepResult step(
    String sid,
    int stage, {
    InterventionOutcome outcome = _pass,
    String? decisionId,
    String? cmd,
  }) => store.advance(
    commandId: cmd ?? 'c-${n++}',
    payloadDigest: 'dg',
    sessionId: sid,
    stage: stage,
    outcome: outcome,
    decisionId: decisionId,
  );

  void at(Duration d) => trusted.at = _t0.add(d);

  /// s 를 3단계(저널 J)까지 통과 — 3단계 = t0 + 1h.
  void toJournal(String sid, {String j = 'J'}) {
    journal(j);
    expect(step(sid, 1).executed, isTrue);
    expect(step(sid, 2).executed, isTrue);
    at(const Duration(hours: 1));
    expect(step(sid, 3, decisionId: j).executed, isTrue);
  }

  test('1→5 전 과정 — 신뢰 시각 · 냉각 24h · 같은 저널 · 5단계 = 닫힘', () {
    toJournal('s1');
    at(const Duration(hours: 24, minutes: 59));
    expect(step('s1', 4).reasonCode, 'INTERVENTION_COOLING');
    at(const Duration(hours: 25));
    expect(step('s1', 4).executed, isTrue);
    expect(
      step('s1', 5, decisionId: 'K').reasonCode,
      'INTERVENTION_JOURNAL_MISSING',
    );
    final InterventionStepResult last = step('s1', 5, decisionId: 'J');
    expect((last.executed, last.closed), (true, true));
    expect(
      db
          .select(
            'SELECT stage, occurred_at, outcome, decision_id FROM intervention_step ORDER BY stage',
          )
          .map((Row r) => r.values)
          .toList(),
      <List<Object?>>[
        <Object?>[1, _t0.toIso8601String(), 'PASSED', null],
        <Object?>[2, _t0.toIso8601String(), 'PASSED', null],
        <Object?>[
          3,
          _t0.add(const Duration(hours: 1)).toIso8601String(),
          'PASSED',
          'J',
        ],
        <Object?>[
          4,
          _t0.add(const Duration(hours: 25)).toIso8601String(),
          'PASSED',
          null,
        ],
        <Object?>[
          5,
          _t0.add(const Duration(hours: 25)).toIso8601String(),
          'PASSED',
          'J',
        ],
      ],
    );
    final InterventionState s = store.session('s1')!;
    expect((s.closed, s.closedOutcome), (true, InterventionOutcome.passed));
    expect(step('s1', 6).reasonCode, 'INTERVENTION_CLOSED');
    expect(
      db
          .select(
            "SELECT state, state_label, reject_reason_code FROM command_inbox WHERE kind = 'INTERVENTION_STEP' AND state = 'REJECTED' ORDER BY command_id",
          )
          .map((Row r) => r.values)
          .toList(),
      hasLength(3),
    );
  });

  test('🔴 한 번에 한 세션 · 만료 세션은 새 세션을 막지 않는다 · 닫으면 새 세션', () {
    toJournal('s1');
    expect(step('s2', 1).reasonCode, 'INTERVENTION_SESSION_OPEN');
    // 실행 창 끝 = 3단계(t0 + 1h) + 냉각 24h + 창 24h = t0 + 49h.
    at(const Duration(hours: 48, minutes: 59));
    expect(step('s2', 1).reasonCode, 'INTERVENTION_SESSION_OPEN');
    at(const Duration(hours: 49));
    expect(step('s1', 4).reasonCode, 'INTERVENTION_EXPIRED');
    expect(step('s2', 1).executed, isTrue);
    // 만료 세션 = 닫기만 된다.
    expect(
      step('s1', 4, outcome: InterventionOutcome.doNothing).closed,
      isTrue,
    );
    expect(step('s3', 1).reasonCode, 'INTERVENTION_SESSION_OPEN');
    expect(
      step('s2', 2, outcome: InterventionOutcome.abandoned).closed,
      isTrue,
    );
    expect(step('s3', 1).executed, isTrue);
  });

  test('🔴 3단계 저널 6갈래 · 예산 소진이면 메모', () {
    journal('nodev', dev: 0);
    journal('blank', rule: '  ');
    journal('ok');
    journal('nonote');
    journal('withnote', note: '정식 메모');
    expect(step('s1', 1).executed, isTrue);
    expect(step('s1', 2).executed, isTrue);
    for (final String? id in <String?>[null, 'NONE', 'nodev', 'blank']) {
      expect(
        step('s1', 3, decisionId: id).reasonCode,
        'INTERVENTION_JOURNAL_MISSING',
        reason: id,
      );
    }
    expect(step('s1', 3, decisionId: 'ok').executed, isTrue);
    // 다른 세션이 쓴 저널.
    expect(
      step('s1', 4, outcome: InterventionOutcome.abandoned).closed,
      isTrue,
    );
    expect(step('s2', 1).executed, isTrue);
    expect(step('s2', 2).executed, isTrue);
    expect(
      step('s2', 3, decisionId: 'ok').reasonCode,
      'INTERVENTION_JOURNAL_MISSING',
    );
    // 예산 소진(12개월 4회) = 메모 없는 저널은 미연결.
    for (int i = 0; i < 4; i++) {
      db.execute(
        "INSERT INTO discretion_adjustment(adjustment_id, applied_at, delta_pct, decision_id, reason) VALUES (?, '2026-0${i + 1}-01T00:00:00.000Z', 0.05, ?, '근거')",
        <Object?>['a$i', 'd$i'],
      );
    }
    expect(
      step('s2', 3, decisionId: 'nonote').reasonCode,
      'INTERVENTION_JOURNAL_MISSING',
    );
    expect(step('s2', 3, decisionId: 'withnote').executed, isTrue);
  });

  test('🔴 신뢰 시각 모름 = 나아가기도 닫기도 거부(행 0)', () {
    trusted.at = null;
    expect(step('s1', 1).reasonCode, 'TRUSTED_TIME_UNKNOWN');
    trusted.at = _t0;
    expect(step('s1', 1).executed, isTrue);
    trusted.at = null;
    expect(
      step('s1', 2, outcome: InterventionOutcome.doNothing).reasonCode,
      'TRUSTED_TIME_UNKNOWN',
    );
    expect(
      db.select('SELECT COUNT(*) AS n FROM intervention_step').single['n'],
      1,
    );
  });

  test('같은 command_id 재전달 = 처음 결과(닫힘 포함) · 새 행 0', () {
    expect(step('s1', 1, cmd: 'a').executed, isTrue);
    final InterventionStepResult close = step(
      's1',
      2,
      outcome: InterventionOutcome.doNothing,
      cmd: 'b',
    );
    expect(close.closed, isTrue);
    final InterventionStepResult again = step('s1', 2, cmd: 'b');
    expect(
      (again.executed, again.replayed, again.closed, again.reasonCode),
      (true, true, true, null),
    );
    final InterventionStepResult open = step('s1', 1, cmd: 'a');
    expect((open.replayed, open.closed), (true, false));
    final InterventionStepResult rej = step('s1', 3, cmd: 'r');
    final InterventionStepResult rejAgain = step('s1', 3, cmd: 'r');
    expect((rej.replayed, rej.reasonCode), (false, 'INTERVENTION_CLOSED'));
    expect(
      (
        rejAgain.executed,
        rejAgain.replayed,
        rejAgain.reasonCode,
        rejAgain.closed,
      ),
      (false, true, 'INTERVENTION_CLOSED', false),
    );
    expect(
      db.select('SELECT COUNT(*) AS n FROM intervention_step').single['n'],
      2,
    );
    expect(db.select('SELECT COUNT(*) AS n FROM command_inbox').single['n'], 3);
  });

  test('🔴 한 트랜잭션 — 명령 기록이 실패하면 단계 행도 남지 않는다', () {
    db.execute(
      "CREATE TRIGGER no_cmd BEFORE INSERT ON command_inbox BEGIN SELECT RAISE(ABORT, 'x'); END",
    );
    expect(() => step('s1', 1), throwsA(isA<SqliteException>()));
    expect(db.select('SELECT 1 FROM intervention_step'), isEmpty);
    expect(db.autocommit, isTrue);
  });

  test('최근 열린 세션 = 닫히지 않은 것 가운데 가장 늦게 연 것 · 상태 = 행에서', () {
    expect(store.latestOpenSession(), isNull);
    expect(store.session('s1'), isNull);
    toJournal('s1');
    expect(store.latestOpenSession()!.sessionId, 's1');
    at(const Duration(hours: 49)); // s1 만료
    expect(step('s2', 1).executed, isTrue);
    final InterventionState latest = store.latestOpenSession()!;
    expect((latest.sessionId, latest.nextStage), ('s2', 2));
    expect(
      step('s2', 2, outcome: InterventionOutcome.doNothing).closed,
      isTrue,
    );
    final InterventionState s1 = store.latestOpenSession()!;
    expect((s1.sessionId, s1.expiredAt(trusted.at!)), ('s1', true));
    expect(store.session('s1')!.journalId, 'J');
  });

  test('오프셋 없는 시각 · 모르는 결과 = 형식 오류', () {
    db.execute(
      "INSERT INTO intervention_step(session_id, stage, occurred_at, outcome, decision_id) VALUES ('x', 1, '2026-11-05T00:00:00', 'PASSED', NULL)",
    );
    expect(() => store.session('x'), throwsFormatException);
  });
}
