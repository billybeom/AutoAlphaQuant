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
      // 🆕 E14d2b — 갭 1세션 = 소급 불가 공백 1 → P2 묶음 더함.
      expect(r.alerts, <String>{
        kResumeCompletedAlertCode,
        kResumeDataGapAlertCode,
      });
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
    expect(r.alerts, <String>{
      kResumeTradingHaltedAlertCode,
      kResumeDataGapAlertCode,
    });
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
    expect(r.alerts, <String>{
      kResumeTradingHaltedAlertCode,
      kResumeDataGapAlertCode,
    });
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
    // 🆕 E14e1 — R6 이 남긴 항목(`resume_item`)이 집계 원천.
    db.execute(
      'INSERT INTO resume_item VALUES (?, ?, 0, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        open2.resumeRunId,
        'PW-X',
        'x',
        'p',
        'r',
        'EXECUTED_AS_REEVALUATED',
        '재판정 값으로 집행 예정',
        'REEVALUATED',
      ],
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

  test('🆕 E14d2b R5 — 갭 세션 = data_gap 1행(equity_snapshot · 복구 불가 · RESUME_GAP) · 집계 · P2 알림 · 이어가도 한 행', () async {
    await lastSuccess('2026-10-30');
    final ResumeJobReport r = await job().run(_today);
    final Row g = db.select('SELECT * FROM data_gap').single;
    expect(
      (
        g['gap_id'],
        g['dataset'],
        g['from_date'],
        g['to_date'],
        g['recoverable'],
        g['reason_code'],
      ),
      (
        'GAP-RR-2026-11-13-1-equity_snapshot',
        'equity_snapshot',
        '2026-11-02',
        '2026-11-12',
        0,
        'RESUME_GAP',
      ),
    );
    expect(r.counts!.unrecoverable, 1);
    expect(r.alerts, contains(kResumeDataGapAlertCode));
    // 갭 0 · 플래그만 = 공백 행 0.
    await lastSuccess('2026-11-12');
    final ResumeJobReport r2 = await job().run(_today);
    expect(r2.counts!.unrecoverable, 0);
    expect(r2.alerts, isNot(contains(kResumeDataGapAlertCode)));
    expect(db.select('SELECT * FROM data_gap'), hasLength(1));
  });

  test('🆕 E14d2b 계절 사람 선택 — 축소 = 재판정 집행 + 결정 행(HUMAN_REDUCED · parent) · 건너뛰기 = 대체 · 거부 차례', () async {
    seasonalPlan('AAA-SEAS-IN', 'BUY');
    seasonalPlan('BBB-SEAS-IN', 'BUY');
    monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
    final ResumeJob j = job();
    Future<String?> pick(
      String work,
      SeasonalWindowChoice c, {
      String decision = 'D-H1',
      TradeDate day = _today,
    }) => j.applySeasonalChoice(
      workId: work,
      choice: c,
      decisionId: decision,
      today: day,
    );
    expect(
      await pick('PW-AAA-SEAS-IN', SeasonalWindowChoice.reduced, decision: ' '),
      SeasonalChoiceCodes.decisionMissing,
    );
    expect(
      await pick('PW-MONTH-END-2026-10-30', SeasonalWindowChoice.asIs),
      SeasonalChoiceCodes.notSeasonalEntry,
    );
    expect(
      await pick('PW-NONE', SeasonalWindowChoice.asIs),
      PlannedWorkCodes.unknown,
    );
    expect(
      await pick(
        'PW-AAA-SEAS-IN',
        SeasonalWindowChoice.asIs,
        day: const TradeDate('2026-11-30'),
      ),
      SeasonalChoiceCodes.pastDue,
    );
    expect(await pick('PW-AAA-SEAS-IN', SeasonalWindowChoice.reduced), isNull);
    final Row w = db
        .select("SELECT * FROM planned_work WHERE work_id = 'PW-AAA-SEAS-IN'")
        .single;
    expect(
      (w['state'], w['verdict_code']),
      ('REEVALUATED', 'EXECUTED_AS_REEVALUATED'),
    );
    expect(
      db
          .select(
            "SELECT decision_id FROM planned_work_transition WHERE work_id = 'PW-AAA-SEAS-IN' AND to_state = 'REEVALUATED'",
          )
          .single['decision_id'],
      'D-H1',
    );
    final Row d = db
        .select("SELECT * FROM decision_log WHERE decision_id = 'D-H1'")
        .single;
    expect(
      (d['kind'], d['reason_code'], d['parent_decision_id'], d['strategy_id']),
      ('ENTRY', 'HUMAN_REDUCED', 'AAA-SEAS-IN', P0sStrategyIds.sleeveA),
    );
    expect(
      await pick('PW-AAA-SEAS-IN', SeasonalWindowChoice.skip, decision: 'D-H2'),
      SeasonalChoiceCodes.notPending,
    );
    expect(
      await pick('PW-BBB-SEAS-IN', SeasonalWindowChoice.skip, decision: 'D-H3'),
      isNull,
    );
    expect(
      db
          .select(
            "SELECT state FROM planned_work WHERE work_id = 'PW-BBB-SEAS-IN'",
          )
          .single['state'],
      'SUPERSEDED',
    );
  });

  test('🆕 E14d2b 실행 기록이 없어도(기준 없음) 플래그만으로 연 회차 = R5 건너뜀 · 끝까지', () async {
    db.execute(
      "INSERT INTO trading_block(flag_id, set_at, reason) VALUES ('RESUME_INCOMPLETE', 'x', 'y')",
    );
    final ResumeJobReport r = await job().run(_today);
    expect((r.gapTradingDays, r.counts!.unrecoverable), (0, 0));
    expect(run1()['phase'], 'R8');
    expect(db.select('SELECT * FROM data_gap'), isEmpty);
  });

  test(
    '🆕 E14d2b 계절 선택 — 마지막 회차 FULL = 축소 · 그대로 거부(안전 정지) · 건너뛰기는 받음',
    () async {
      await lastSuccess('2026-10-23'); // 갭 > 10 = RECOVERY_FULL
      await job().run(_today);
      expect(run1()['mode'], 'RECOVERY_FULL');
      seasonalPlan('AAA-SEAS-IN', 'BUY');
      final ResumeJob j = job();
      expect(
        await j.applySeasonalChoice(
          workId: 'PW-AAA-SEAS-IN',
          choice: SeasonalWindowChoice.asIs,
          decisionId: 'D-H1',
          today: _today,
        ),
        ResumeReasonCodes.safetyStop,
      );
      expect(
        db.select("SELECT * FROM decision_log WHERE decision_id = 'D-H1'"),
        isEmpty,
      );
      expect(
        await j.applySeasonalChoice(
          workId: 'PW-AAA-SEAS-IN',
          choice: SeasonalWindowChoice.skip,
          decisionId: 'D-H2',
          today: _today,
        ),
        isNull,
      );
    },
  );

  group('🆕 E14e1 리포트 항목 저장 · 읽기 창구(R78)', () {
    test('열린 회차만 = null · 끝난 회차 둘 = 늦은 쪽 · 같은 항목 두 번 = 처음 그대로', () async {
      final SqliteResumeStore st = SqliteResumeStore(db, clock: _Clock());
      final ResumeRunRow open = st.startRun(
        today: _today,
        gapTradingDays: 1,
        mode: ResumeMode.normal,
      );
      expect(SqliteResumeRepository(db).latest(), isNull);
      ResumeItem it(String line) => ResumeItem(
        workId: 'PW-X',
        oneLine: line,
        plannedLine: 'p',
        reevaluatedLine: 'r',
        verdictCode: 'EXPIRED',
        verdictLabel: '만료',
      );
      st.writeItem(
        open.resumeRunId,
        seq: 0,
        item: it('첫'),
        reasonCode: 'DUE_PASSED',
      );
      st.writeItem(open.resumeRunId, seq: 5, item: it('둘'), reasonCode: 'X');
      final Row row = db.select('SELECT * FROM resume_item').single;
      expect(
        (row['one_line'], row['seq'], row['reason_code']),
        ('첫', 0, 'DUE_PASSED'),
      );
      db.execute('DELETE FROM resume_run');
      db.execute('DELETE FROM resume_item');
      await job().run(_today);
      db.execute(
        "INSERT INTO trading_block(flag_id, set_at, reason) VALUES ('RESUME_INCOMPLETE', 'x', 'y') "
        'ON CONFLICT (flag_id) DO UPDATE SET cleared_at = NULL',
      );
      final ResumeJobReport second = await job().run(_today);
      expect(second.resumeRunId, 'RR-2026-11-13-2');
      expect(
        SqliteResumeRepository(db).latest()!.resumeRunId,
        'RR-2026-11-13-2',
      );
    });

    test('R6 항목 = resume_item(차례 · 사유) · 리포트 = 끝난 회차를 그대로 · 공백 라벨', () async {
      await lastSuccess('2026-11-06'); // 갭 4 = CONSERVATIVE
      monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
      seasonalPlan('ZZZ-SEAS-OUT', 'SELL');
      final ResumeJobReport r = await job().run(_today);
      final List<Row> rows = db.select(
        'SELECT * FROM resume_item ORDER BY seq',
      );
      expect(
        rows
            .map((Row x) => (x['seq'], x['work_id'], x['reason_code']))
            .toList(),
        <(Object?, Object?, Object?)>[
          (0, 'PW-ZZZ-SEAS-OUT', 'REEVALUATED'),
          (1, 'PW-MONTH-END-2026-10-30', 'CONSERVATIVE_DEFER'),
        ],
      );
      // 같은 회차 접두의 복구 가능 공백은 리포트에 안 실린다.
      db.execute(
        "INSERT INTO data_gap VALUES (?, 'prices', '2026-11-09', '2026-11-09', 1, 'MISSING_ROW', 'x')",
        <Object?>['GAP-${r.resumeRunId}-prices'],
      );
      final ResumeReport rep = SqliteResumeRepository(db).latest()!;
      expect(rep.resumeRunId, r.resumeRunId);
      expect(rep.items, r.items);
      expect(rep.counts, r.counts);
      expect(rep.headline, r.headline);
      expect(
        (rep.mode, rep.gapTradingDays, rep.phase, rep.modeLabel),
        (ResumeMode.conservative, 4, ResumePhase.r8, '4거래일 미실행 — 보수'),
      );
      expect(rep.finishedAt, isNotNull);
      final DataGapRow g = rep.unrecoverableGaps.single;
      expect(
        (g.dataset, g.recoverable, g.reasonCode, g.label),
        (
          'equity_snapshot',
          false,
          'RESUME_GAP',
          '11월 9일~11월 12일 평가액 스냅샷 없음 — 복구 불가',
        ),
      );
    });

    test('회차 없음 = null · 열린 회차는 건너뛰고 앞의 끝난 회차 · 재판정 실패도 항목', () async {
      final SqliteResumeRepository repo = SqliteResumeRepository(db);
      expect(repo.latest(), isNull);
      await lastSuccess('2026-11-11');
      monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
      reeval.throwingFor.add('PW-MONTH-END-2026-10-30');
      final ResumeJobReport done = await job().run(_today);
      expect(
        db.select('SELECT reason_code FROM resume_item').single['reason_code'],
        'REEVALUATION_FAILED',
      );
      SqliteResumeStore(
        db,
        clock: _Clock(),
      ).startRun(today: _today, gapTradingDays: 1, mode: ResumeMode.normal);
      expect(repo.latest()!.resumeRunId, done.resumeRunId);
      expect(
        await repo.watchLatest().first,
        isA<ResumeReport>().having(
          (ResumeReport x) => x.resumeRunId,
          'id',
          done.resumeRunId,
        ),
      );
    });

    test('계획 목록 = planned_work → 요약(상태 라벨 · 행 판 · epoch 0 · 원문 없음)', () async {
      monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
      seasonalPlan('AAA-SEAS-IN', 'BUY');
      SqlitePlannedWorkStore(db, carry: ledger, clock: _Clock()).transition(
        'PW-AAA-SEAS-IN',
        PlannedWorkState.blocked,
        today: _today,
        verdictCode: VerdictCodes.blocked,
      );
      final List<PlannedWorkSummary> l = SqliteResumeRepository(db)
          .plannedWork();
      expect(
        l
            .map(
              (PlannedWorkSummary x) =>
                  (x.workId, x.stateLabel, x.rowVersion, x.leaseEpoch),
            )
            .toList(),
        <(String, String, int, int)>[
          ('PW-AAA-SEAS-IN', '차단', 1, 0),
          ('PW-MONTH-END-2026-10-30', '예정', 0, 0),
        ],
      );
      expect(l.last.oneLine, '10월말 정기 리밸런싱');
      expect(l.last.digest, hasLength(12));
      expect(l.last.dueBy, const TradeDate('2026-11-27'));
      expect(
        (await SqliteResumeRepository(db).watchPlannedWork().first).length,
        2,
      );
    });
  });

  group('🆕 E14e2 홈 한 줄 · recovery · 미러 행(R79)', () {
    SqliteResumeStatus status() => SqliteResumeStatus(db, kr: _kr);

    test(
      '홈 한 줄 — 실행 기록 없음 = null · D+n · 대기 = PLANNED · BLOCKED 만 · 링크',
      () async {
        expect(status().resumeLine(_today), isNull);
        await lastSuccess('2026-11-12');
        expect(
          status().resumeLine(_today),
          const LinkAction(
            label: '마지막 성공 거래일 D+0 · 대기 작업 없음',
            deepLink: AppRoutes.x2ResumeReport,
          ),
        );
        monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
        seasonalPlan('AAA-SEAS-IN', 'BUY');
        seasonalPlan('BBB-SEAS-IN', 'BUY');
        final SqlitePlannedWorkStore pw = SqlitePlannedWorkStore(
          db,
          carry: ledger,
          clock: _Clock(),
        );
        pw.transition(
          'PW-AAA-SEAS-IN',
          PlannedWorkState.blocked,
          today: _today,
          verdictCode: VerdictCodes.blocked,
        );
        pw.transition(
          'PW-BBB-SEAS-IN',
          PlannedWorkState.superseded,
          today: _today,
          verdictCode: VerdictCodes.superseded,
        );
        await lastSuccess('2026-11-06');
        expect(status().resumeLine(_today)!.label, '마지막 성공 거래일 D+0 · 대기 작업 2건');
        db.execute("DELETE FROM job_run WHERE session_day = '2026-11-12'");
        expect(status().resumeLine(_today)!.label, '마지막 성공 거래일 D+4 · 대기 작업 2건');
      },
    );

    test('recovery — 플래그 ∧ 최근 회차 DRY · FULL 만', () async {
      expect(status().recoveryActive(), isFalse);
      db.execute(
        "INSERT INTO trading_block(flag_id, set_at, reason) VALUES ('RESUME_INCOMPLETE', 'x', 'y')",
      );
      expect(status().recoveryActive(), isFalse);
      await lastSuccess('2026-10-30'); // 갭 9 = DRY(플래그 유지)
      await job().run(_today);
      expect(status().recoveryActive(), isTrue);
      final Object? st = db
          .select('SELECT started_at FROM resume_run')
          .first['started_at'];
      db.execute(
        'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
        "VALUES ('RR-2026-11-13-0', ?, ?, 0, 'NORMAL', 'R8', '{}', 'h')",
        <Object?>[st, st],
      );
      db.execute(
        'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
        "VALUES ('RR-2026-11-13-9', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z', 0, 'NORMAL', 'R8', '{}', 'h')",
      );
      expect(
        status().recoveryActive(),
        isTrue,
      ); // 같은 시각 = id 큰 쪽 · 더 이른 회차 = 무시
      db.execute("UPDATE resume_run SET mode = 'RECOVERY_FULL'");
      expect(status().recoveryActive(), isTrue);
      db.execute("UPDATE resume_run SET mode = 'CONSERVATIVE'");
      expect(status().recoveryActive(), isFalse);
      db.execute("UPDATE resume_run SET mode = 'RECOVERY_DRY'");
      db.execute(
        "UPDATE trading_block SET cleared_at = 'x' WHERE flag_id = 'RESUME_INCOMPLETE'",
      );
      expect(status().recoveryActive(), isFalse);
    });

    test(
      '🔴 미러 행 — 칸 정확히(원문 0) · 모드 · epoch · 원격 epoch 이 더 높으면 0행 · 같으면 행',
      () async {
        await lastSuccess('2026-11-11');
        monthlyPlan('MONTH-END-2026-10-30', '2026-11-27');
        await job().run(_today);
        final ResumeMirrorPayload p = status().mirrorPayload(
          mode: RunMode.simInternal,
          leaseEpoch: 3,
          remoteEpoch: 3,
        );
        expect(p.plannedWork, hasLength(1));
        expect(p.plannedWork.single.keys.toSet(), <String>{
          'work_id',
          'mode',
          'digest',
          'one_line',
          'due_by',
          'state',
          'row_version',
          'lease_epoch',
        });
        expect(
          (
            p.plannedWork.single['work_id'],
            p.plannedWork.single['mode'],
            p.plannedWork.single['state'],
            p.plannedWork.single['row_version'],
            p.plannedWork.single['lease_epoch'],
            p.plannedWork.single['due_by'],
          ),
          (
            'PW-MONTH-END-2026-10-30',
            'SIM_INTERNAL',
            'REEVALUATED',
            1,
            3,
            '2026-11-27',
          ),
        );
        final Row pw = db
            .select('SELECT digest, one_line FROM planned_work')
            .first;
        expect(
          (p.plannedWork.single['digest'], p.plannedWork.single['one_line']),
          (pw['digest'], pw['one_line']),
        );
        expect(p.resumeRuns.single.keys.toSet(), <String>{
          'resume_run_id',
          'gap_trading_days',
          'mode',
          'phase',
          'headline',
        });
        expect(
          (
            p.resumeRuns.single['resume_run_id'],
            p.resumeRuns.single['gap_trading_days'],
            p.resumeRuns.single['mode'],
            p.resumeRuns.single['phase'],
          ),
          ('RR-2026-11-13-1', 1, 'SIM_INTERNAL', 'R8'),
        );
        expect(
          p.resumeRuns.single['headline'],
          db.select('SELECT headline FROM resume_run').first['headline'],
        );
        expect(
          status()
              .mirrorPayload(
                mode: RunMode.live,
                leaseEpoch: 0,
                remoteEpoch: null,
              )
              .plannedWork
              .single['mode'],
          'LIVE',
        );
        final ResumeMirrorPayload low = status().mirrorPayload(
          mode: RunMode.simInternal,
          leaseEpoch: 2,
          remoteEpoch: 3,
        );
        expect(low.plannedWork, isEmpty);
        expect(low.resumeRuns, isEmpty);
      },
    );
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
