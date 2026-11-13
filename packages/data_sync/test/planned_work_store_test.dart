// E14c2 — `planned_work` 등록 · 전이 · 평시 정리(계절)(설계 13 §8 R74 M1~M4).
//
// 🔵 잡는 것: ① 등록 = 트랜잭션 밖 오류 · 같은 결정 두 번 = 트랜잭션째 실패 · 한 줄 · digest ② 전이 = 허용(현재값 ·
//    판 +1 · 전이 행 칸) · 거부(종단 · 기한 뒤 DONE · BLOCKED → DONE · 모르는 행 = 쓰기 0) ③ 상태 걸러 읽기
//    ④ 계절 정리 = 체결 누계 ≥ 목표 · 기준 날 몫 냄 = DONE · 아니면 그대로 · 진행은 오늘 포함(before = 다음 날) ·
//    기한 뒤 = EXPIRED · 모르는 kind = 그대로
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 10, 29, 6);

class _Clock implements Clock {
  @override
  DateTime nowUtc() => _t0;
}

class _Carry implements CarryLedger {
  int filled = 0;
  final List<(String, String, String, TradeDate)> asked =
      <(String, String, String, TradeDate)>[];

  @override
  Future<List<ExpiredIntent>> expiredIntents(TradeDate tradeDate) async =>
      const <ExpiredIntent>[];

  @override
  Future<SplitProgress> splitProgress(
    String logicalDecisionId, {
    required String strategyId,
    required String symbol,
    required TradeDate before,
  }) async {
    asked.add((logicalDecisionId, strategyId, symbol, before));
    return SplitProgress(planned: filled, filled: filled);
  }
}

const String _seas = 'SEAS-A-IN-2026-10-30';

void main() {
  late Directory dir;
  late Database db;
  late _Carry carry;
  late SqlitePlannedWorkStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_pw_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    carry = _Carry();
    store = SqlitePlannedWorkStore(db, carry: carry, clock: _Clock());
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void register(String kind, String decision, String due) =>
      inLedgerTransaction(
        db,
        () => registerPlannedWork(
          db,
          kind: kind,
          decisionId: decision,
          dueBy: TradeDate(due),
          oneLine: '한 줄',
          payloadJson: '{"a":1}',
          createdAtUtc: '2026-10-29T06:00:00.000Z',
        ),
      );

  void seasonalEvent({int shares = 90}) => db.execute(
    'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
    "weights_before, weights_after, config_hash, created_at) VALUES ('REB-SEAS-2026-10-30', '2026-10-28', 'LIVE', "
    "'SEASONAL', ?, ?, '[]', '[]', 'c', 'x')",
    <Object?>[
      _seas,
      '{"a_symbol":"A1","side":"BUY","target_shares":$shares,"execution_days":["2026-10-28","2026-10-29","2026-10-30"]}',
    ],
  );

  void intent(String id, String decision, {String side = 'BUY'}) => db.execute(
    'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
    "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
    "'2026-10-30', 'KR', 'main', 'P0S_A', ?, 'A1', ?, 'LIMIT', 30, 'SUBMITTED', 'c', 'x', 'LIVE')",
    <Object?>[id, 'k$id', decision, side],
  );

  int count(String t) =>
      db.select('SELECT COUNT(*) AS n FROM $t').first['n']! as int;

  group('등록', () {
    test('🔴 트랜잭션 밖 = 오류 · 같은 결정 두 번 = 트랜잭션째 실패', () {
      expect(
        () => registerPlannedWork(
          db,
          kind: ResumeWorkKinds.monthlyPlan,
          decisionId: 'D1',
          dueBy: const TradeDate('2026-10-30'),
          oneLine: 'x',
          payloadJson: '{}',
          createdAtUtc: 't',
        ),
        throwsStateError,
      );
      register(ResumeWorkKinds.monthlyPlan, 'D1', '2026-10-30');
      expect(
        () => register(ResumeWorkKinds.monthlyPlan, 'D1', '2026-10-31'),
        throwsA(isA<SqliteException>()),
      );
      expect((count('planned_work'), count('planned_work_transition')), (1, 1));
      expect(store.rows().single.dueBy, const TradeDate('2026-10-30'));
    });

    test('한 줄 · digest · id 꼴', () {
      expect(monthlyPlanOneLine('2026-07-31'), '7월말 정기 리밸런싱');
      expect(monthlyPlanOneLine('2026-12-30'), '12월말 정기 리밸런싱');
      expect(
        seasonalPlanOneLine('2026-10-30', OrderSide.buy),
        '10월 계절 A 진입 분할 집행',
      );
      expect(
        seasonalPlanOneLine('2027-04-30', OrderSide.sell),
        '4월 계절 A 청산 분할 집행',
      );
      expect(plannedWorkDigestOf('{"a":1}'), '015abd7f5cc5');
      expect(plannedWorkIdOf('X'), 'PW-X');
      expect(plannedWorkTransitionIdOf('PW-X', 3), 'PWT-PW-X#3');
    });
  });

  group('전이', () {
    test('허용 = 현재값 · 판 +1 · 전이 행 칸(verdict · 재개 회차 · 결정 · 시각)', () {
      register(ResumeWorkKinds.monthlyPlan, 'D1', '2026-10-30');
      expect(
        store.transition(
          'PW-D1',
          PlannedWorkState.blocked,
          today: const TradeDate('2026-10-29'),
          verdictCode: VerdictCodes.blocked,
          decisionId: 'DX',
          resumeRunId: 'rr1',
        ),
        isNull,
      );
      final PlannedWorkRow w = store.rows().single;
      expect(
        (w.state, w.verdictCode, w.rowVersion),
        (PlannedWorkState.blocked, 'BLOCKED', 1),
      );
      final Row t = db
          .select(
            "SELECT * FROM planned_work_transition WHERE transition_id = 'PWT-PW-D1#1'",
          )
          .single;
      expect(
        (
          t['work_id'],
          t['from_state'],
          t['to_state'],
          t['verdict_code'],
          t['resume_run_id'],
          t['decision_id'],
          t['occurred_at'],
        ),
        (
          'PW-D1',
          'PLANNED',
          'BLOCKED',
          'BLOCKED',
          'rr1',
          'DX',
          '2026-10-29T06:00:00.000Z',
        ),
      );
    });

    test('🔴 거부 = 쓰기 0 — BLOCKED → DONE · 기한 뒤 DONE · 종단 · 모르는 행', () {
      register(ResumeWorkKinds.monthlyPlan, 'D1', '2026-10-30');
      store.transition(
        'PW-D1',
        PlannedWorkState.blocked,
        today: const TradeDate('2026-10-29'),
      );
      String? tr(PlannedWorkState to, String today) =>
          store.transition('PW-D1', to, today: TradeDate(today));
      expect(tr(PlannedWorkState.done, '2026-10-29'), PlannedWorkCodes.illegal);
      expect(
        tr(PlannedWorkState.reevaluated, '2026-10-31'),
        PlannedWorkCodes.pastDue,
      );
      expect(
        (store.rows().single.rowVersion, count('planned_work_transition')),
        (1, 2),
      );
      expect(tr(PlannedWorkState.expired, '2026-10-31'), isNull);
      expect(
        tr(PlannedWorkState.blocked, '2026-10-31'),
        PlannedWorkCodes.terminal,
      );
      expect(
        store.transition(
          'PW-NONE',
          PlannedWorkState.done,
          today: const TradeDate('2026-10-29'),
        ),
        PlannedWorkCodes.unknown,
      );
      expect(
        (store.rows().single.rowVersion, count('planned_work_transition')),
        (2, 3),
      );
    });

    test('상태 걸러 읽기 · work_id 차례', () {
      register(ResumeWorkKinds.monthlyPlan, 'D2', '2026-10-30');
      register(ResumeWorkKinds.monthlyPlan, 'D1', '2026-10-30');
      store.transition(
        'PW-D2',
        PlannedWorkState.blocked,
        today: const TradeDate('2026-10-29'),
      );
      expect(
        store.rows().map((PlannedWorkRow r) => r.workId).toList(),
        <String>['PW-D1', 'PW-D2'],
      );
      expect(
        store
            .rows(state: PlannedWorkState.planned)
            .map((PlannedWorkRow r) => r.workId)
            .toList(),
        <String>['PW-D1'],
      );
      final PlannedWorkRow r = store.rows().first;
      expect(
        (r.kind, r.decisionId, r.oneLine, r.origin, r.digest),
        (ResumeWorkKinds.monthlyPlan, 'D1', '한 줄', 'LOCAL', '015abd7f5cc5'),
      );
    });
  });

  group('계절 정리(R74 M4)', () {
    setUp(() {
      seasonalEvent();
      register(ResumeWorkKinds.seasonalWindow, _seas, '2026-10-30');
    });

    test('아직 = 그대로 · 진행은 오늘 포함(before = 다음 날) · 목표 · 종목 · 전략', () async {
      carry.filled = 89;
      expect(await store.settle(const TradeDate('2026-10-29')), 0);
      expect(carry.asked.single, (
        _seas,
        P0sStrategyIds.sleeveA,
        'A1',
        const TradeDate('2026-10-30'),
      ));
      expect(store.rows().single.state, PlannedWorkState.planned);
    });

    test('체결 누계 ≥ 목표 = DONE(기준 날 전이어도)', () async {
      carry.filled = 90;
      expect(await store.settle(const TradeDate('2026-10-29')), 1);
      expect(store.rows().single.state, PlannedWorkState.done);
    });

    test('기준 날 몫을 냈다 = DONE · 다른 날 · 다른 방향 몫은 아니다', () async {
      intent('i1', '$_seas@2026-10-29');
      // 🔴 그날 몫이 아니라 기준 날 몫 — 10-29 몫만 있는 10-29 = 그대로.
      expect(await store.settle(const TradeDate('2026-10-29')), 0);
      intent('i2', '$_seas@2026-10-30', side: 'SELL');
      expect(await store.settle(const TradeDate('2026-10-30')), 0);
      intent('i3', '$_seas@2026-10-30');
      expect(await store.settle(const TradeDate('2026-10-30')), 1);
      expect(store.rows().single.state, PlannedWorkState.done);
    });

    test('🔴 기한 뒤 = EXPIRED · 끝났어도 기한 뒤 처음 보면 EXPIRED(DONE 0)', () async {
      carry.filled = 90;
      expect(await store.settle(const TradeDate('2026-10-31')), 1);
      final PlannedWorkRow w = store.rows().single;
      expect((w.state, w.verdictCode), (PlannedWorkState.expired, 'EXPIRED'));
      expect(carry.asked, isEmpty);
    });
  });

  test('모르는 kind · 결정 없는 계절 행 = 그대로', () async {
    register('OTHER', 'D9', '2026-10-30');
    register(
      ResumeWorkKinds.seasonalWindow,
      'SEAS-A-IN-2026-12-30',
      '2026-12-30',
    );
    expect(await store.settle(const TradeDate('2026-10-30')), 0);
    expect(
      store.rows().map((PlannedWorkRow r) => r.state).toSet(),
      <PlannedWorkState>{PlannedWorkState.planned},
    );
  });
}
