// 🆕 E15d2 — 모의 체험 판정 입력(모의 파일 원 기록 읽기) · 시나리오(설계 13 §8 R87 AB1 · AB2 · AB10).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        JobRunEntry,
        JobRunStatus,
        Market,
        P0sStrategyIds,
        SimTrialFacts,
        SimTrialItem,
        SimTrialItemResult,
        SimTrialItemState,
        SimTrialReport,
        TierBCard,
        frozenExchangeCalendar,
        judgeSimTrial;
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

String _iso(DateTime t) => t.toUtc().toIso8601String();

/// O-04 ⑥ 커밋 = 12-21(월) 15:30.
final DateTime _commit = _k('2026-12-21', 15, 30);

/// 12-22 ~ 01-07 = 10세션(12-25 · 12-31 · 01-01 휴장).
const List<String> _ten = <String>[
  '2026-12-22',
  '2026-12-23',
  '2026-12-24',
  '2026-12-28',
  '2026-12-29',
  '2026-12-30',
  '2027-01-04',
  '2027-01-05',
  '2027-01-06',
  '2027-01-07',
];

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15d2_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _commit);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _commit);
    clock = _Clock(_commit);
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  /// 실제 온보딩 쓰기로 체험을 시작한다(O-00b → 개시 → O-04 ⑥).
  void commit() {
    final SqliteOnboardingStore s = SqliteOnboardingStore(sim, clock: clock)
      ..selectOperatingMode(OperatingMode.autoTrade);
    expect(
      s
          .declareSimOpening(
            SelfReportBalance(
              asOfTradeDate: const TradeDate('2026-12-21'),
              purpose: SelfReportPurpose.simOpening,
              sessionStartedAt: _commit,
              lines: const <SelfReportLine>[],
              cashKrw: Decimal.parse('10000000'),
              accountAlias: 'general',
              declaredComplete: true,
              context: _ctx,
            ),
            accountByStrategy: const <String, String>{
              P0sStrategyIds.sleeveA: 'general',
              P0sStrategyIds.sleeveB: 'pension',
              P0sStrategyIds.sleeveC: 'general',
              P0sStrategyIds.pot: 'general',
            },
            configHash: 'cfg-1',
          )
          .ok,
      isTrue,
    );
    expect(
      s
          .dryRunStart(
            card: const TierBCard(
              b1R12mFloor: -0.15,
              b2DdFloor: -0.34,
              b3TuwMonths: 31,
            ),
          )
          .ok,
      isTrue,
    );
  }

  Future<void> batch(
    String day, {
    String job = 'kr_order',
    JobRunStatus status = JobRunStatus.success,
    String check = 'sim-auto',
    int hour = 9,
  }) => SqliteJobRunLog(sim).record(
    JobRunEntry(
      rid: '$check-$job-$day-${status.wire}',
      checkName: '$check-$job',
      sessionDay: TradeDate(day),
      startedAtUtc: _k(day, hour, 10),
      finishedAtUtc: _k(day, hour, 11),
      status: status,
    ),
  );

  void rebalance(String id, String kind, String tradeDate, DateTime created) =>
      sim.execute(
        'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
        "weights_before, weights_after, config_hash, created_at) VALUES (?, ?, 'SIM_INTERNAL', ?, ?, '{}', '[]', '[]', 'cfg-1', ?)",
        <Object?>[id, tradeDate, kind, 'D-$id', _iso(created)],
      );

  void recon(String id, DateTime at, {required bool matched}) => sim.execute(
    'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
    "VALUES (?, ?, ?, '[]', 'NONE')",
    <Object?>[id, _iso(at), matched ? 1 : 0],
  );

  void diff(String id, String status) => sim.execute(
    'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, origin_code, status, detected_at, applicable) '
    "VALUES (?, 'CANON_BROKER', 'QUANTITY', '2026-12-22', '{}', '차이', 'BLOCKING', NULL, ?, ?, 1)",
    <Object?>[id, status, _iso(_k('2026-12-22', 16))],
  );

  void resumeRun(
    String id,
    DateTime started, {
    DateTime? finished,
    int gap = 1,
  }) => sim.execute(
    'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
    "VALUES (?, ?, ?, ?, 'NORMAL', 'R8', '{}', NULL)",
    <Object?>[id, _iso(started), finished == null ? null : _iso(finished), gap],
  );

  void kill(String id, String kind, DateTime at) => sim.execute(
    'INSERT INTO kill_switch_event (event_id, occurred_at, kind, channel, decision_id, summary) '
    "VALUES (?, ?, ?, 'app', ?, '{}')",
    <Object?>[id, _iso(at), kind, kind == 'ACTIVATED' ? null : 'D-$id'],
  );

  void alert(String id, DateTime at) => sim.execute(
    'INSERT INTO alert_event(alert_id, raised_at, code, level, source, dedupe_key) '
    "VALUES (?, ?, 'RECON_MISMATCH', 'P1', 'sim-auto-kr_order', ?)",
    <Object?>[id, _iso(at), 'k-$id'],
  );

  void step(String session, int stage, DateTime at) => sim.execute(
    'INSERT INTO intervention_step(session_id, stage, occurred_at, outcome, decision_id) '
    "VALUES (?, ?, ?, 'PASSED', ?)",
    <Object?>[
      session,
      stage,
      _iso(at),
      stage == 3 || stage == 5 ? 'D-$session' : null,
    ],
  );

  test('🔴 모의 파일만 — 실전 원장으로는 만들지 않는다', () {
    expect(
      () => SqliteSimTrialFacts(live, clock: clock),
      throwsA(isA<StateError>()),
    );
  });

  test('커밋 전 = 시작점 없음 · 모드 없음 · 체험 전', () async {
    final SqliteSimTrialFacts f = SqliteSimTrialFacts(sim, clock: clock);
    final SimTrialFacts x = await f.facts();
    expect(x.anchorUtc, isNull);
    expect(x.runMode, isNull);
    expect(judgeSimTrial(x, kr: _kr).started, isFalse);
  });

  test('시작점 = 첫 RUN_MODE 커밋 시각 · 뒤 RUN_MODE 행은 보지 않는다', () {
    commit();
    final SqliteSimTrialFacts f = SqliteSimTrialFacts(sim, clock: clock);
    expect(f.anchorUtc(), _commit);
    sim.execute(
      'INSERT INTO mode_transition (transition_id, axis, mode, exec_policy, from_mode, from_exec_policy, '
      "decision_id, handover_session_id, committed_at) VALUES ('MT-000002', 'RUN_MODE', 'SIM_BROKER', 'EXECUTE', "
      "'SIM_INTERNAL', 'EXECUTE', 'D-2', NULL, ?)",
      <Object?>[_iso(_k('2026-12-28', 10))],
    );
    expect(f.anchorUtc(), _commit);
    expect(f.read().runMode, RunMode.simBroker);
  });

  test('원 기록 읽기 — kr_order 만 · 성공 · 지연 · rc- 만 · 열린 차이 · 1단계만', () async {
    commit();
    await batch('2026-12-22');
    await batch('2026-12-23', status: JobRunStatus.late);
    await batch('2026-12-24', status: JobRunStatus.failed);
    await batch('2026-12-28', status: JobRunStatus.failed);
    await batch('2026-12-28', hour: 10);
    await batch('2026-12-29', job: 'close');
    await batch('2026-12-30', check: 'live-auto');
    recon('rc-2026-12-22T07:00:00.000Z', _k('2026-12-22', 16), matched: true);
    recon(
      'rc-clear-2026-12-22T08:00:00.000Z',
      _k('2026-12-22', 17),
      matched: false,
    );
    recon('li-2026-12-22T09:00:00.000Z', _k('2026-12-22', 18), matched: false);
    diff('d-1', 'OPEN');
    diff('d-2', 'RESOLVED');
    step('s1', 1, _k('2026-12-29', 9));
    step('s1', 2, _k('2026-12-29', 10));
    resumeRun('RR-u', _k('2026-12-29', 7), gap: 2);
    final SimTrialFacts x = SqliteSimTrialFacts(sim, clock: clock).read();
    expect(x.runMode, RunMode.simInternal);
    expect(x.batchOkDays, <String>{
      '2026-12-22',
      '2026-12-23',
      '2026-12-28',
      '2026-12-30',
    });
    expect(x.recons, hasLength(1));
    expect(x.recons.single.matched, isTrue);
    expect(x.recons.single.runAtUtc, _k('2026-12-22', 16));
    expect(x.openLedgerDiffs, 1);
    expect(x.resumeRuns.single.finished, isFalse);
    expect(x.resumeRuns.single.gapTradingDays, 2);
    expect(x.interventionStartedUtc, <DateTime>[_k('2026-12-29', 9)]);
  });

  test('시각에 시차가 없으면 FormatException', () {
    commit();
    sim.execute(
      'INSERT INTO alert_event(alert_id, raised_at, code, level, source, dedupe_key) '
      "VALUES ('x', '2026-12-22T00:00:00', 'RECON_MISMATCH', 'P1', 's', 'k')",
    );
    expect(
      () => SqliteSimTrialFacts(sim, clock: clock).read(),
      throwsFormatException,
    );
  });

  test('AB10 시나리오 — 2거래주 + 월말 1회 + 재개 + 킬스위치 연습 = 5항목 · 카운터', () async {
    // 커밋 앞 기록(체험 밖).
    alert('a0', _k('2026-12-21', 10));
    step('s0', 1, _k('2026-12-21', 11));
    commit();
    // 매 세션 kr_order · 12-23 저녁 20:30 놓침 → 12-24 아침 재개(갭 1).
    for (final String d in _ten) {
      await batch(d);
    }
    resumeRun('RR-1', _k('2026-12-24', 7), finished: _k('2026-12-24', 7, 5));
    resumeRun(
      'RR-0',
      _k('2026-12-24', 6),
      gap: 0,
      finished: _k('2026-12-24', 6, 1),
    );
    // 킬스위치 연습: 12-24 발동 · 확인 → 48h 뒤 12-28 재개.
    kill('K1', 'ACTIVATED', _k('2026-12-24', 10));
    kill('K2', 'CHECKLIST_CONFIRMED', _k('2026-12-24', 10, 5));
    kill('K3', 'RESUMED', _k('2026-12-28', 11));
    // 12-30 월말 → 01-04 08:00 계획.
    rebalance('R1', 'MONTHLY_REGULAR', '2026-12-30', _k('2027-01-04', 8));
    alert('a1', _k('2026-12-24', 10));
    alert('a2', _k('2027-01-05', 9));
    step('s1', 1, _k('2026-12-29', 9));

    clock.at = _k('2027-01-06', 18);
    final SimTrialReport mid = judgeSimTrial(
      SqliteSimTrialFacts(sim, clock: clock).read(),
      kr: _kr,
    );
    expect(mid.complete, isFalse);
    expect(mid.of(SimTrialItem.twoTradingWeeks).detail, '연속 정상 배치 9/10세션');

    clock.at = _k('2027-01-07', 18);
    final SimTrialReport r = judgeSimTrial(
      await SqliteSimTrialFacts(sim, clock: clock).facts(),
      kr: _kr,
    );
    expect(r.started, isTrue);
    expect(
      <SimTrialItemState>[for (final SimTrialItemResult i in r.items) i.state],
      <SimTrialItemState>[
        SimTrialItemState.passed,
        SimTrialItemState.passed,
        SimTrialItemState.autoPassed,
        SimTrialItemState.passed,
        SimTrialItemState.passed,
      ],
    );
    expect(r.complete, isTrue);
    expect(r.needsWarning, isFalse);
    expect(r.headline, '체험 5항목을 모두 채웠습니다.');
    expect(r.counters.text, '체험 18일 · 배치 10회 · 리밸런싱 1회 · 경보 2건 · 개입 1회');
  });
}
