// 🆕 E15d1 — 온보딩 쓰기: O-00b 선택 · 모의 개시 · O-04 ⑥ 커밋 · 개시 행 제외
// (설계 13 §8 R85 AA2~AA6 · SPEC v2.44 02 §2-7 ⓐ · 01 §8-23 · 앱 06 X6-5 ⓑ).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        BootMode,
        BootModeResolved,
        EquityPoint,
        LedgerCashRow,
        P0sStrategyIds,
        SimOpeningCodes,
        TierBCard;
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

final DateTime _t0 = DateTime.utc(2026, 12, 21, 1); // KST 12-21 10:00

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

const TierBCard _card = TierBCard(
  b1R12mFloor: -0.15,
  b2DdFloor: -0.34,
  b3TuwMonths: 31,
);

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

SelfReportBalance _report({
  String cash = '10000000',
  SelfReportPurpose purpose = SelfReportPurpose.simOpening,
  List<SelfReportLine> lines = const <SelfReportLine>[],
}) => SelfReportBalance(
  asOfTradeDate: const TradeDate('2026-12-21'),
  purpose: purpose,
  sessionStartedAt: _t0,
  lines: lines,
  cashKrw: Decimal.parse(cash),
  accountAlias: 'general',
  declaredComplete: true,
  context: _ctx,
);

int _count(Database db, String table, [String where = '1=1']) =>
    db.select('SELECT COUNT(*) AS n FROM $table WHERE $where').first['n']!
        as int;

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15d1_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  SqliteOnboardingStore store() => SqliteOnboardingStore(sim, clock: clock);

  OnboardingOutcome declare(
    SqliteOnboardingStore s, {
    String cash = '10000000',
  }) => s.declareSimOpening(
    _report(cash: cash),
    accountByStrategy: _accounts,
    configHash: 'cfg-1',
  );

  void nothingCommitted() {
    expect(_count(sim, 'mode_transition'), 0);
    expect(_count(sim, 'strategy_state_current'), 0);
    expect(_count(sim, 'strategy_state_log'), 0);
    expect(
      sim
          .select('SELECT committed_at FROM onboarding_choice')
          .first['committed_at'],
      isNull,
    );
  }

  test('🔴 sim 파일만 — 실전 원장으로는 만들지 않는다', () {
    expect(
      () => SqliteOnboardingStore(live, clock: clock),
      throwsA(isA<StateError>()),
    );
  });

  group('O-00b 운영 방식 선택', () {
    test('없으면 null · 고르면 행 하나 · 커밋 전엔 덮어쓴다', () {
      final SqliteOnboardingStore s = store();
      expect(s.choice(), isNull);
      expect(s.selectOperatingMode(OperatingMode.advisory).ok, isTrue);
      expect(s.choice()!.operatingMode, OperatingMode.advisory);
      clock.at = _t0.add(const Duration(minutes: 5));
      final OnboardingOutcome o = s.selectOperatingMode(
        OperatingMode.autoTrade,
      );
      expect(o.ok, isTrue);
      expect(o.headline, contains('자동 매매'));
      expect(s.choice()!.operatingMode, OperatingMode.autoTrade);
      expect(s.choice()!.committed, isFalse);
      expect(_count(sim, 'onboarding_choice'), 1);
      expect(
        sim
            .select('SELECT chosen_at FROM onboarding_choice')
            .first['chosen_at'],
        clock.at.toIso8601String(),
      );
    });
  });

  group('X6-5 ⓑ 가상 초기금 선언', () {
    test('🔴 개시 결정 1행 + 계좌별 입금 행(P0S 목표 비중) · 실전 원장 0행', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      final OnboardingOutcome o = declare(s);
      expect(o.ok, isTrue);
      expect(o.headline, contains('10,000,000원'));
      expect(o.headline, contains('2곳'));
      final ResultSet d = sim.select(
        'SELECT decision_id, trade_date, mode, kind, strategy_id, reason_code, config_hash FROM decision_log',
      );
      expect(d, hasLength(1));
      expect(d.first['decision_id'], 'SIMOPEN-2026-12-21');
      expect(d.first['trade_date'], '2026-12-21');
      expect(d.first['mode'], 'SIM_INTERNAL');
      expect(d.first['kind'], 'MANUAL');
      expect(d.first['strategy_id'], 'P0S');
      expect(d.first['reason_code'], 'SIM_OPENING_BALANCE');
      expect(d.first['config_hash'], 'cfg-1');
      expect(s.openingDecisionId(), 'SIMOPEN-2026-12-21');
      final List<(String, String, double, String, String)> c =
          <(String, String, double, String, String)>[
            for (final Row r in sim.select(
              'SELECT flow_id, account_alias, amount, kind, note FROM cash_flow ORDER BY flow_id',
            ))
              (
                r['flow_id'] as String,
                r['account_alias'] as String,
                (r['amount'] as num).toDouble(),
                r['kind'] as String,
                r['note'] as String,
              ),
          ];
      expect(c, <(String, String, double, String, String)>[
        (
          'SIMOPEN-2026-12-21-general',
          'general',
          5800000,
          'DEPOSIT',
          'SIM_OPENING_BALANCE',
        ),
        (
          'SIMOPEN-2026-12-21-pension',
          'pension',
          4200000,
          'DEPOSIT',
          'SIM_OPENING_BALANCE',
        ),
      ]);
      expect(_count(live, 'decision_log'), 0);
      expect(_count(live, 'cash_flow'), 0);
      expect(_count(sim, 'self_report_balance'), 0);
      expect(_count(sim, 'ledger_diff'), 0);
    });

    test('🔴 두 번째 선언 = 거부(append-only) · 행 그대로', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      expect(declare(s).ok, isTrue);
      final OnboardingOutcome o = declare(s, cash: '20000000');
      expect(o.reasonCode, SimOpeningCodes.alreadyDeclared);
      expect(o.headline, contains('폐기'));
      expect(_count(sim, 'decision_log'), 1);
      expect(_count(sim, 'cash_flow'), 2);
    });

    test('선행 · 입력 거부 — 아무것도 쓰지 않는다', () {
      final SqliteOnboardingStore s = store();
      expect(declare(s).reasonCode, SimOpeningCodes.choiceMissing);
      s.selectOperatingMode(OperatingMode.advisory);
      expect(declare(s).reasonCode, SimOpeningCodes.advisoryNotReady);
      s.selectOperatingMode(OperatingMode.autoTrade);
      expect(declare(s, cash: '0').reasonCode, SimOpeningCodes.notPositive);
      expect(declare(s, cash: '12.5').reasonCode, SimOpeningCodes.notWholeWon);
      expect(
        s
            .declareSimOpening(
              _report(purpose: SelfReportPurpose.periodicAudit),
              accountByStrategy: _accounts,
              configHash: 'cfg-1',
            )
            .reasonCode,
        SimOpeningCodes.wrongPurpose,
      );
      expect(
        s
            .declareSimOpening(
              _report(
                lines: const <SelfReportLine>[
                  SelfReportLine(
                    symbol: '133690',
                    symbolLabel: 'TIGER 미국나스닥100',
                    quantity: 1,
                  ),
                ],
              ),
              accountByStrategy: _accounts,
              configHash: 'cfg-1',
            )
            .reasonCode,
        SimOpeningCodes.linesNotAllowed,
      );
      expect(
        s
            .declareSimOpening(
              _report(),
              accountByStrategy: const <String, String>{
                P0sStrategyIds.sleeveA: 'general',
              },
              configHash: 'cfg-1',
            )
            .reasonCode,
        SimOpeningCodes.accountUnmapped,
      );
      expect(_count(sim, 'decision_log'), 0);
      expect(_count(sim, 'cash_flow'), 0);
    });
  });

  group('O-04 ⑥ 커밋(DRY_RUN 시작)', () {
    test('🔴 한 트랜잭션: 모드 행 + 전략 시딩 4 + 상태 기록 4 + committed_at', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      declare(s);
      // 🔴 UTC 12-21 15:30 = KST 12-22 00:30 — 시딩 날(since)은 한국 날짜다.
      clock.at = DateTime.utc(2026, 12, 21, 15, 30);
      final OnboardingOutcome o = s.dryRunStart(card: _card);
      expect(o.ok, isTrue);
      expect(o.headline, contains('정기 리밸런싱'));
      expect(o.headline, contains('현금으로 기다립니다'));
      final ResultSet m = sim.select(
        'SELECT axis, mode, exec_policy, decision_id FROM mode_transition',
      );
      expect(m, hasLength(1));
      expect(m.first['axis'], 'RUN_MODE');
      expect(m.first['mode'], 'SIM_INTERNAL');
      expect(m.first['exec_policy'], 'EXECUTE');
      expect(m.first['decision_id'], 'SIMOPEN-2026-12-21');
      expect(
        <(String, String, String, double)>[
          for (final Row r in sim.select(
            'SELECT strategy_id, state, since, capital_cap FROM strategy_state_current ORDER BY strategy_id',
          ))
            (
              r['strategy_id'] as String,
              r['state'] as String,
              r['since'] as String,
              (r['capital_cap'] as num).toDouble(),
            ),
        ],
        <(String, String, String, double)>[
          ('P0S_A', 'ACTIVE', '2026-12-22', 1.0),
          ('P0S_B', 'ACTIVE', '2026-12-22', 1.0),
          ('P0S_C', 'ACTIVE', '2026-12-22', 1.0),
          ('P0S_POT', 'ACTIVE', '2026-12-22', 1.0),
        ],
      );
      final ResultSet log = sim.select(
        'SELECT log_id, from_state, to_state, reason FROM strategy_state_log ORDER BY log_id',
      );
      expect(log, hasLength(4));
      expect(log.first['log_id'], 'SIMOPEN-2026-12-21-P0S_A');
      expect(log.first['from_state'], isNull);
      expect(log.first['to_state'], 'ACTIVE');
      expect(log.first['reason'], 'SIM_OPENING');
      expect(
        sim
            .select('SELECT committed_at FROM onboarding_choice')
            .first['committed_at'],
        clock.at.toIso8601String(),
      );
      expect(s.choice()!.committed, isTrue);
      expect(_count(live, 'mode_transition'), 0);
      expect(_count(live, 'strategy_state_current'), 0);
    });

    test('커밋 뒤: 정본 = simInternal × execute × 자동 매매 · 기동 해석 = sim 파일', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      declare(s);
      s.dryRunStart(card: _card);
      final SqliteModeStore simStore = SqliteModeStore(
        sim,
        LedgerFile.sim,
        clock: clock,
      );
      final ModeSnapshot snap = simStore.snapshot()!;
      expect(snap.runMode, RunMode.simInternal);
      expect(snap.execPolicy, ExecPolicy.execute);
      expect(snap.operatingMode, OperatingMode.autoTrade);
      final BootMode boot = bootModeOf(
        live: SqliteModeStore(live, LedgerFile.live, clock: clock),
        sim: simStore,
      );
      expect(boot, isA<BootModeResolved>());
      expect((boot as BootModeResolved).runMode, RunMode.simInternal);
      expect(boot.execPolicy, ExecPolicy.execute);
      expect(boot.file, LedgerFile.sim);
    });

    test('🔴 커밋 뒤 = 다시 커밋 · 다시 선택 · 다시 선언 모두 ONBOARDING_CHOICE_COMMITTED', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      declare(s);
      expect(s.dryRunStart(card: _card).ok, isTrue);
      expect(
        s.dryRunStart(card: _card).reasonCode,
        OnboardingResultCodes.choiceCommitted,
      );
      expect(
        s.selectOperatingMode(OperatingMode.advisory).reasonCode,
        OnboardingResultCodes.choiceCommitted,
      );
      expect(s.choice()!.operatingMode, OperatingMode.autoTrade);
      expect(declare(s).reasonCode, OnboardingResultCodes.choiceCommitted);
      expect(_count(sim, 'mode_transition'), 1);
      expect(_count(sim, 'strategy_state_current'), 4);
      expect(_count(sim, 'cash_flow'), 2);
    });

    test('🔴 계층 B 카드 미등록 = 체험 시작 거부(D8) · 아무것도 쓰지 않는다', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      declare(s);
      final OnboardingOutcome o = s.dryRunStart(card: null);
      expect(o.reasonCode, SimOpeningCodes.tierBCardMissing);
      expect(o.headline, contains('계층 B'));
      nothingCommitted();
    });

    test('선행 거부 — 선택 없음 · 선언 없음 · 투자 안내', () {
      final SqliteOnboardingStore s = store();
      expect(
        s.dryRunStart(card: _card).reasonCode,
        SimOpeningCodes.choiceMissing,
      );
      s.selectOperatingMode(OperatingMode.autoTrade);
      expect(
        s.dryRunStart(card: _card).reasonCode,
        SimOpeningCodes.notDeclared,
      );
      nothingCommitted();
      s.selectOperatingMode(OperatingMode.advisory);
      expect(
        s.dryRunStart(card: _card).reasonCode,
        SimOpeningCodes.advisoryNotReady,
      );
      nothingCommitted();
    });

    test('🔴 중간 실패 = 전부 되돌림 → DRY_RUN_START_ROLLED_BACK · 고친 뒤 다시 하면 된다', () {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      declare(s);
      sim.execute(
        "INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES ('P0S_C', 'X', '2026-01-01', 0)",
      );
      final OnboardingOutcome o = s.dryRunStart(card: _card);
      expect(o.reasonCode, OnboardingResultCodes.dryRunStartRolledBack);
      expect(o.headline, contains('바뀐 것은 없습니다'));
      expect(_count(sim, 'mode_transition'), 0);
      expect(_count(sim, 'strategy_state_log'), 0);
      expect(_count(sim, 'strategy_state_current'), 1);
      expect(s.choice()!.committed, isFalse);
      sim.execute(
        "DELETE FROM strategy_state_current WHERE strategy_id = 'P0S_C'",
      );
      expect(s.dryRunStart(card: _card).ok, isTrue);
      expect(_count(sim, 'strategy_state_current'), 4);
      expect(_count(sim, 'mode_transition'), 1);
    });
  });

  group('개시 행 제외(R85 AA5)', () {
    void openAndCommit() {
      final SqliteOnboardingStore s = store()
        ..selectOperatingMode(OperatingMode.autoTrade);
      declare(s);
      s.dryRunStart(card: _card);
    }

    test('🔴 연금 납입 누계 입력 = 개시 행 제외 · 정상 입금은 포함', () {
      openAndCommit();
      expect(SqliteDepositLedger(sim).cashRows('pension'), isEmpty);
      sim.execute(
        'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, account_alias) '
        "VALUES ('pl-1-PENSION', '2027-01-05', 100000, 'KRW', 'DEPOSIT', 'pl_20270105_01', '2027-01-05T00:00:00.000Z', 'pension')",
      );
      expect(
        SqliteDepositLedger(sim)
            .cashRows('pension')
            .map((LedgerCashRow r) => r.amount),
        <Decimal>[Decimal.fromInt(100000)],
      );
      expect(openingCashTradeDate(sim), '2026-12-21');
      expect(openingCashTradeDate(live), isNull);
    });

    test('실전 개시 note(OPENING_BALANCE)도 같은 규칙', () {
      live.execute(
        'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, account_alias) '
        "VALUES ('OPEN-1', '2027-01-20', 3000000, 'KRW', 'DEPOSIT', 'OPENING_BALANCE', '2027-01-20T00:00:00.000Z', 'pension')",
      );
      expect(SqliteDepositLedger(live).cashRows('pension'), isEmpty);
      expect(openingCashTradeDate(live), '2027-01-20');
    });

    test('🔴 계층 B TWR — 지수 첫날 = 개시 날 이후 첫 스냅숏 · 개시 행은 외부 흐름 아님', () {
      openAndCommit();
      void snap(String day, double equity) => sim.execute(
        'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
        "VALUES (?, ?, 0, ?, ?, 0, 'SIM_INTERNAL')",
        <Object?>[day, equity, equity, equity],
      );
      snap('2026-12-18', 0);
      snap('2026-12-21', 10000000);
      snap('2027-01-05', 10200000);
      sim.execute(
        'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, account_alias) '
        "VALUES ('pl-2-GENERAL', '2027-01-05', 50000, 'KRW', 'DEPOSIT', 'pl_20270105_01', '2027-01-05T00:00:00.000Z', 'general')",
      );
      final List<EquityPoint> pts = tierBSeries(sim, '2027-01-31');
      expect(pts.map((EquityPoint p) => p.date), <String>[
        '2026-12-21',
        '2027-01-05',
      ]);
      expect(pts.first.flow, 0);
      expect(pts.last.flow, 50000);
    });

    test('시뮬레이터 현금(계좌 현금)에는 개시 행이 들어간다', () async {
      openAndCommit();
      final SqliteSimLedgerView v = SqliteSimLedgerView(
        sim,
        account: 'pension',
        strategies: const <String>{P0sStrategyIds.sleeveB},
        clock: clock,
      );
      expect(await v.cashFlowSum(), 4200000);
    });
  });
}
