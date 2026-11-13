// E14d1 — 재개 실행기 뼈대 R0~R8(설계 13 §8 R75 N1~N9).
//
// 🔵 잡는 것: ① 할 일 없음(기준 없음 · 갭 0 · 플래그 없음 = 회차 0) ② NORMAL = 재판정 위임 → REEVALUATED + child(RESUME ·
//    parent) · 회차 행(R8 · 집계 · 머리말) · 플래그 세웠다 풂 · 완료 알림 ③ 할 일 없음 = 대체 · child 0 ④ CONSERVATIVE =
//    정기 리밸런싱 대체(재판정 안 부름) · 풂 ⑤ RECOVERY_DRY = 차단(관찰) · 플래그 유지 · 정지 알림 ⑥ 안내 = 유지
//    ⑦ 재판정 실패 = 항목 그대로 · 유지 · 머리말 꼬리 ⑧ 기한 지남 = EXPIRED ⑨ 크래시 — 열린 회차를 다음 단계부터 ·
//    R6 끝난 회차 = 전이에서 센다 ⑩ 플래그만 서 있어도 새 회차 ⑪ live — UNKNOWN 남음 = 전제 실패 · 정지 사유 ·
//    자기 플래그는 정지 사유 아님 ⑫ 원장 읽기 2(UNKNOWN 전체 · 잔류)
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _now = DateTime.utc(2026, 11, 13); // KST 09:00 금
const TradeDate _today = TradeDate('2026-11-13');
final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

class _Clock implements Clock {
  @override
  DateTime nowUtc() => _now;
}

void main() {
  late Directory dir;
  late Database db;
  late SqliteOrderLedger ledger;
  late FakeResumeReevaluator reeval;
  late FakeLeaseGate lease;
  late RunMode runMode;

  Database open(RunMode m) {
    runMode = m;
    db = openLocalLedger(dir.path, m, clock: () => _now);
    ledger = SqliteOrderLedger(db, mode: m, clock: _Clock(), kr: _kr);
    return db;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_resume_');
    reeval = FakeResumeReevaluator();
    lease = FakeLeaseGate();
    open(RunMode.simInternal);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  ResumeJob job({OperatingMode op = OperatingMode.autoTrade}) => ResumeJob(
    db,
    runMode: runMode,
    operatingMode: op,
    kr: _kr,
    clock: _Clock(),
    ledger: ledger,
    brokers: const <String, AccountBroker>{},
    accountByStrategy: const <String, String>{},
    lease: lease,
    reevaluator: reeval,
    ladder: ResumeLadder.defaults,
    recheckDelay: Duration.zero,
    sleep: (Duration d) async {},
  );

  Future<void> lastSuccess(String day) => SqliteJobRunLog(db).record(
    JobRunEntry(
      rid: 'rid-$day',
      checkName: '${runMode.isSim ? 'sim' : 'live'}-auto-equity_snapshot',
      sessionDay: TradeDate(day),
      startedAtUtc: _now.subtract(const Duration(days: 30)),
      finishedAtUtc: _now.subtract(const Duration(days: 30)),
      status: JobRunStatus.success,
    ),
  );

  void monthlyPlan(String decision, String due) {
    db.execute(
      'INSERT INTO decision_log(decision_id, created_at, trade_date, mode, kind, strategy_id, reason, reason_code, '
      "config_hash) VALUES (?, '2026-10-31T00:00:00.000Z', '2026-10-30', ?, 'REBALANCE', ?, 'r', 'MONTHLY_REGULAR', 'cfg')",
      <Object?>[decision, runMode.wire, P0sStrategyIds.deposit],
    );
    inLedgerTransaction(
      db,
      () => registerPlannedWork(
        db,
        kind: ResumeWorkKinds.monthlyPlan,
        decisionId: decision,
        dueBy: TradeDate(due),
        oneLine: '10월말 정기 리밸런싱',
        payloadJson: '{}',
        createdAtUtc: '2026-10-31T00:00:00.000Z',
      ),
    );
  }

  int count(String sql, [List<Object?> args = const <Object?>[]]) =>
      db.select('SELECT COUNT(*) AS n FROM $sql', args).first['n']! as int;

  bool flag() => SqliteResumeStore(db, clock: _Clock()).flagActive();

  Row run1() => db.select('SELECT * FROM resume_run').single;

  test('① 할 일 없음 — 기준 없음 · 갭 0 · 플래그 없음 = 회차 0', () async {
    expect((await job().run(_today)).resumeRunId, isNull);
    await lastSuccess('2026-11-12');
    final ResumeJobReport r = await job().run(_today);
    expect(r.resumeRunId, isNull);
    expect(r.alerts, isEmpty);
    expect(r.items, isEmpty);
    expect(count('resume_run'), 0);
    expect(flag(), isFalse);
  });

  test(
    '② NORMAL = 재판정 위임 → REEVALUATED + child · 회차 행 · 플래그 풂 · 완료 알림',
    () async {
      await lastSuccess('2026-11-11'); // 갭 1
      monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
      final ResumeJobReport r = await job().run(_today);
      expect(r.resumeRunId, 'RR-2026-11-13-1');
      expect(
        (r.mode, r.gapTradingDays, r.continued, r.lease),
        (ResumeMode.normal, 1, false, LeaseVerdict.valid),
      );
      expect(reeval.calls, <(String, TradeDate)>[
        ('PW-MONTH-END-2026-10-30', _today),
      ]);
      final Row w = db.select('SELECT * FROM planned_work').single;
      expect(
        (w['state'], w['verdict_code']),
        ('REEVALUATED', 'EXECUTED_AS_REEVALUATED'),
      );
      final Row t = db
          .select(
            "SELECT * FROM planned_work_transition WHERE transition_id LIKE '%#1'",
          )
          .single;
      expect(
        (t['resume_run_id'], t['decision_id']),
        ('RR-2026-11-13-1', 'PW-MONTH-END-2026-10-30#RESUME-2026-11-13'),
      );
      final Row c = db
          .select("SELECT * FROM decision_log WHERE kind = 'RESUME'")
          .single;
      expect(
        (c['decision_id'], c['parent_decision_id'], c['reason_code']),
        (
          'PW-MONTH-END-2026-10-30#RESUME-2026-11-13',
          'MONTH-END-2026-10-30',
          'RESUME_CHILD',
        ),
      );
      final Row rr = run1();
      expect(
        (rr['phase'], rr['gap_trading_days'], rr['mode']),
        ('R8', 1, 'NORMAL'),
      );
      expect(rr['finished_at'], isNotNull);
      expect(rr['headline'], r.headline);
      expect(r.headline, startsWith('1거래일 미실행: 재판정 1 / 만료 0'));
      expect(r.counts!.executed, 1);
      expect((r.flagReleased, flag(), r.haltReason), (true, false, null));
      expect(r.alerts, <String>{kResumeCompletedAlertCode});
      final Row b = db
          .select(
            "SELECT cleared_by FROM trading_block WHERE flag_id = 'RESUME_INCOMPLETE'",
          )
          .single;
      expect(b['cleared_by'], kResumeClearedBy);
      expect(r.items.single.verdictLabel, '재판정 값으로 집행 예정');
      // 다시 돌리면 = 갭 그대로지만 열린 회차 0 · 플래그 0 → 새 회차(이미 끝난 항목은 건드리지 않음).
      final ResumeJobReport again = await job().run(_today);
      expect(again.resumeRunId, 'RR-2026-11-13-2');
      expect(again.items, isEmpty);
      expect(count("decision_log WHERE kind = 'RESUME'"), 1);
    },
  );

  test('③ 재판정 결과 할 일 없음 = REEVALUATED + 대체 · child 0', () async {
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    reeval.fallback = false;
    final ResumeJobReport r = await job().run(_today);
    final Row w = db.select('SELECT * FROM planned_work').single;
    expect((w['state'], w['verdict_code']), ('REEVALUATED', 'SUPERSEDED'));
    expect(count("decision_log WHERE kind = 'RESUME'"), 0);
    expect(r.counts!.superseded, 1);
    expect(r.flagReleased, isTrue);
  });

  test('④ CONSERVATIVE(갭 4) = 정기 리밸런싱 대체 · 재판정 안 부름 · 풂', () async {
    await lastSuccess('2026-11-06');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    final ResumeJobReport r = await job().run(_today);
    expect((r.mode, r.gapTradingDays), (ResumeMode.conservative, 4));
    expect(reeval.calls, isEmpty);
    expect(
      db.select('SELECT state FROM planned_work').single['state'],
      'SUPERSEDED',
    );
    expect(r.flagReleased, isTrue);
  });

  test('⑤ RECOVERY_DRY(갭 9) = 차단(관찰) · 플래그 유지 · 정지 알림 · 머리말 꼬리', () async {
    await lastSuccess('2026-10-30');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    final ResumeJobReport r = await job().run(_today);
    expect((r.mode, r.gapTradingDays), (ResumeMode.recoveryDry, 9));
    expect(
      db.select('SELECT state FROM planned_work').single['state'],
      'BLOCKED',
    );
    expect(r.items.single.reevaluatedLine, '관찰 회차라 다음 회차에 재판정합니다');
    expect(
      (r.flagReleased, flag(), r.haltReason),
      (false, true, ResumeReasonCodes.observing),
    );
    expect(r.alerts, <String>{kResumeTradingHaltedAlertCode});
    expect(r.headline, endsWith('관찰 회차라 발주하지 않습니다.'));
    expect(run1()['finished_at'], isNotNull);
  });

  test('⑥ 안내 모드 = 차단 · 유지(미결 19)', () async {
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    final ResumeJobReport r = await job(op: OperatingMode.advisory).run(_today);
    expect(r.haltReason, ResumeReasonCodes.advisoryPending);
    expect((r.flagReleased, flag()), (false, true));
    expect(reeval.calls, isEmpty);
  });

  test('⑦ 재판정 실패 = 항목 그대로 · 플래그 유지 · 실패 수 · 머리말 꼬리', () async {
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    reeval.throwingFor.add('PW-MONTH-END-2026-10-30');
    final ResumeJobReport r = await job().run(_today);
    expect(
      db.select('SELECT state, row_version FROM planned_work').single['state'],
      'PLANNED',
    );
    expect(
      (r.reevaluationFailures, r.haltReason, r.flagReleased),
      (1, ResumeReasonCodes.reevaluationFailed, false),
    );
    expect(r.items.single.reevaluatedLine, '재판정에 필요한 자료가 없어 미뤄 둡니다');
    expect(r.counts!.blocked, 1);
    expect(r.headline, endsWith('재판정을 마치지 못해 매매를 멈춰 둡니다.'));
    expect(r.alerts, <String>{kResumeTradingHaltedAlertCode});
  });

  test('⑧ 기한 지남 = EXPIRED(재판정 안 부름)', () async {
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-09-30', '2026-11-12');
    final ResumeJobReport r = await job().run(_today);
    final Row w = db.select('SELECT * FROM planned_work').single;
    expect((w['state'], w['verdict_code']), ('EXPIRED', 'EXPIRED'));
    expect(reeval.calls, isEmpty);
    expect(r.counts!.expired, 1);
  });

  test('⑨ 크래시 — 열린 회차를 다음 단계부터(R0 · 리스 다시 안 봄) · R6 끝난 회차 = 전이에서 센다', () async {
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    final SqliteResumeStore s = SqliteResumeStore(db, clock: _Clock());
    final ResumeRunRow open = s.startRun(
      today: _today,
      gapTradingDays: 1,
      mode: ResumeMode.normal,
    );
    s.commitPhase(open.resumeRunId, ResumePhase.r5);
    final ResumeJobReport r = await job().run(_today);
    expect(
      (r.resumeRunId, r.continued, r.lease),
      (open.resumeRunId, true, null),
    );
    expect(lease.calls, 0);
    expect(r.counts!.executed, 1);
    expect(run1()['phase'], 'R8');
    // R6 끝난 뒤 끊긴 회차(R7 전) — 집계는 이 회차의 전이에서 · 재판정 다시 안 부름.
    final ResumeRunRow open2 = s.startRun(
      today: _today,
      gapTradingDays: 1,
      mode: ResumeMode.normal,
    );
    monthlyPlan('MONTH-END-2026-11-30', '2026-12-30');
    s.commitPhase(open2.resumeRunId, ResumePhase.r6);
    db.execute(
      'UPDATE planned_work_transition SET resume_run_id = ? WHERE resume_run_id = ?',
      <Object?>[open2.resumeRunId, open.resumeRunId],
    );
    final ResumeJobReport r2 = await job().run(_today);
    expect(r2.resumeRunId, open2.resumeRunId);
    expect(r2.items, isEmpty);
    expect(reeval.calls, hasLength(1));
    expect(r2.counts!.executed, 1);
    expect(
      db
          .select(
            "SELECT state FROM planned_work WHERE work_id = 'PW-MONTH-END-2026-11-30'",
          )
          .single['state'],
      'PLANNED',
    );
  });

  test('⑩ 갭 0 이어도 플래그가 서 있으면 새 회차(NORMAL) → 풂', () async {
    await lastSuccess('2026-11-12');
    db.execute(
      "INSERT INTO trading_block(flag_id, set_at, reason) VALUES ('RESUME_INCOMPLETE', 'x', 'y')",
    );
    final ResumeJobReport r = await job().run(_today);
    expect((r.mode, r.gapTradingDays), (ResumeMode.normal, 0));
    expect(r.flagReleased, isTrue);
  });

  test('⑪ live — UNKNOWN 남음 = 전제 실패 · 정지 사유(자기 플래그 빼고) · 유지', () async {
    db.close();
    open(RunMode.live);
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES ('u1', 'ku1', 'x', "
      "'2026-11-11', 'KR', 'main', ?, 'X@2026-11-11', 'S1', 'BUY', 'LIMIT', 1, 'UNKNOWN', 'c', 'x', 'LIVE')",
      <Object?>[P0sStrategyIds.deposit],
    );
    final ResumeJobReport r = await job().run(_today);
    expect(r.stopReasons, contains('UNKNOWN_ORDERS'));
    expect(r.stopReasons, isNot(contains('RESUME_INCOMPLETE')));
    expect(r.haltReason, ResumeReasonCodes.unknownOrders);
    expect(
      db.select('SELECT state FROM planned_work').single['state'],
      'BLOCKED',
    );
    expect((r.flagReleased, flag()), (false, true));
  });

  void seasonalPlan(String decision, String side) {
    db.execute(
      'INSERT INTO decision_log(decision_id, created_at, trade_date, mode, kind, strategy_id, reason, reason_code, '
      "config_hash) VALUES (?, '2026-10-28T00:00:00.000Z', '2026-10-28', ?, 'ENTRY', ?, 'r', 'SEASONAL_ENTRY', 'cfg')",
      <Object?>[decision, runMode.wire, P0sStrategyIds.sleeveA],
    );
    db.execute(
      'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
      "weights_before, weights_after, config_hash, created_at) VALUES (?, '2026-10-28', ?, 'SEASONAL', ?, ?, '[]', '[]', 'c', 'x')",
      <Object?>[
        'EV-$decision',
        runMode.wire,
        decision,
        '{"side":"$side","target_shares":10,"a_symbol":"A1"}',
      ],
    );
    inLedgerTransaction(
      db,
      () => registerPlannedWork(
        db,
        kind: ResumeWorkKinds.seasonalWindow,
        decisionId: decision,
        dueBy: const TradeDate('2026-11-27'),
        oneLine: '계절',
        payloadJson: '{}',
        createdAtUtc: '2026-10-28T00:00:00.000Z',
      ),
    );
  }

  test(
    '⑬ 리스 무효여도 회차는 끝까지(보고만) · 계절 진입 = 사람 결정 · 청산 = 방어 재판정 · 우선순위 차례',
    () async {
      await lastSuccess('2026-11-11');
      lease.verdict = LeaseVerdict.invalid;
      monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
      seasonalPlan('AAA-SEAS-IN', 'BUY');
      seasonalPlan('ZZZ-SEAS-OUT', 'SELL');
      final ResumeJobReport r = await job().run(_today);
      expect(r.lease, LeaseVerdict.invalid);
      expect(run1()['phase'], 'R8');
      expect(r.items.map((ResumeItem i) => i.workId).toList(), <String>[
        'PW-ZZZ-SEAS-OUT',
        'PW-MONTH-END-2026-10-30',
        'PW-AAA-SEAS-IN',
      ]);
      expect(
        r.items.map((ResumeItem i) => i.reevaluatedLine).last,
        '계절 진입은 직접 결정해야 합니다',
      );
      expect(
        reeval.calls.map(((String, TradeDate) c) => c.$1).toList(),
        <String>['PW-ZZZ-SEAS-OUT', 'PW-MONTH-END-2026-10-30'],
      );
    },
  );

  test('⑭ simInternal = 대사 · 해소 자동 충족 — UNKNOWN 이 원장에 있어도 풂(D17)', () async {
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES ('u1', 'ku1', 'x', "
      "'2026-11-11', 'KR', 'main', ?, 'X@2026-11-11', 'S1', 'BUY', 'LIMIT', 1, 'UNKNOWN', 'c', 'x', ?)",
      <Object?>[P0sStrategyIds.deposit, runMode.wire],
    );
    final ResumeJobReport r = await job().run(_today);
    expect(r.stopReasons, contains('UNKNOWN_ORDERS'));
    expect((r.haltReason, r.flagReleased), (null, true));
  });

  test('⑮ live — 대사 불일치 플래그 = 전제 실패(대사 우선)', () async {
    db.close();
    open(RunMode.live);
    await lastSuccess('2026-11-11');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    db.execute(
      "INSERT INTO trading_block(flag_id, set_at, reason) VALUES ('RECON_MISMATCH', 'x', 'y')",
    );
    final ResumeJobReport r = await job().run(_today);
    expect(r.stopReasons, contains('RECON_MISMATCH'));
    expect(r.haltReason, ResumeReasonCodes.reconMismatch);
    expect(r.flagReleased, isFalse);
  });

  test('⑫ 원장 읽기 — UNKNOWN 전체 · RESERVED/SUBMITTING 잔류', () {
    void intent(String id, String status) => db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
      "'2026-11-11', 'KR', 'main', ?, ?, 'S1', 'BUY', 'LIMIT', 1, ?, 'c', 'x', ?)",
      <Object?>[
        id,
        'k$id',
        P0sStrategyIds.deposit,
        'D$id@2026-11-11',
        status,
        runMode.wire,
      ],
    );
    expect((ledger.unknownCount(), ledger.residualCount()), (0, 0));
    intent('a', 'UNKNOWN');
    intent('b', 'RESERVED');
    intent('c', 'SUBMITTING');
    intent('d', 'SUBMITTED');
    intent('e', 'UNKNOWN');
    expect((ledger.unknownCount(), ledger.residualCount()), (2, 2));
  });
}
