// SQLite 주문 원장(설계 13 §8 R36 W2~W10 · 04 §3-1 · §1 · 02 §2-4 · §2-6 · §3-2).
//
// 🔴 `test_intent_before_order` 진짜판 — 파일 SQLite + **둘째 연결**: 브로커 호출 순간 둘째 연결에서 행이 보여야
//    한다(04 §3-1 v1.5 · AC-S04). 같은 연결의 SELECT 는 미커밋 행도 보이므로 판정 근거가 될 수 없다.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 2, 0, 10); // KST 09:10
const TradeDate _exec = TradeDate('2026-11-02');

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final LimitConfig _limits = LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: Decimal.parse('20000000'),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
);

const LimitState _portfolio = LimitState(
  totalEquity: null, // 아래 _ok 에서 채운다
  ordersToday: null,
  riskExposureAfter: 0.5,
  leverageAfter: 0.9,
  positionsAfter: 5,
  satellitePositionsAfter: null,
  satelliteSectorCountAfter: null,
  satelliteAllocation: null,
  satelliteExposure: null,
  satelliteDeployedBefore: null,
  dailyPnlPct: 0,
  fxRateUsdKrw: null,
  strategyRegistered: null,
  tradingBlocked: null,
  journalMissing: null,
  tierBUnjudged: null,
);

final LimitState _ok = LimitState(
  totalEquity: Decimal.parse('100000000'),
  ordersToday: _portfolio.ordersToday,
  riskExposureAfter: _portfolio.riskExposureAfter,
  leverageAfter: _portfolio.leverageAfter,
  positionsAfter: _portfolio.positionsAfter,
  satellitePositionsAfter: null,
  satelliteSectorCountAfter: null,
  satelliteAllocation: null,
  satelliteExposure: null,
  satelliteDeployedBefore: null,
  dailyPnlPct: 0,
  fxRateUsdKrw: null,
  strategyRegistered: null,
  tradingBlocked: null,
  journalMissing: null,
  tierBUnjudged: null,
);

OrderIntentDraft _draft({
  String symbol = '133690',
  OrderSide side = OrderSide.buy,
  String strategy = P0sStrategyIds.sleeveB,
  String logical = 'B-SMA-2026-10-30',
  TradeDate exec = _exec,
}) => OrderIntentDraft(
  executionDate: exec,
  account: 'pension',
  strategyId: strategy,
  symbol: symbol,
  side: side,
  quantity: 5,
  orderType: OrderTypes.limit,
  limitPrice: Decimal.parse('174180'),
  sizingPrice: Decimal.parse('174180'),
  logicalDecisionId: logical,
  decisionId: DecisionIds.forExecution(logical, exec),
  instrument: InstrumentKind.etf,
);

void main() {
  late Directory dir;
  late Database db;
  late SqliteOrderLedger ledger;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_orders_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    for (final String s in <String>[
      P0sStrategyIds.sleeveB,
      P0sStrategyIds.sleeveC,
    ]) {
      db.execute(
        'INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
        <Object?>[s, 'LIVE', '2026-10-01', 1.0],
      );
    }
    ledger = SqliteOrderLedger(
      db,
      mode: RunMode.live,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  ExecutionContext ctx(
    OrderBroker broker, {
    ExecPolicy policy = ExecPolicy.execute,
  }) => ExecutionContext(
    ledger: ledger,
    broker: broker,
    limitConfig: _limits,
    execPolicy: policy,
    operatingMode: OperatingMode.autoTrade,
    configHash: 'cfg-test',
  );

  Database second() {
    final Database b = openLedgerDatabase(
      '${dir.path}/${LedgerFile.of(RunMode.live).fileName}',
    );
    addTearDown(b.close);
    return b;
  }

  Map<String, Object?> intentRow(Database on, String intentId) => on.select(
    'SELECT * FROM order_intents WHERE intent_id = ?',
    <Object?>[intentId],
  ).single;

  group('04 §7 test_intent_before_order — 둘째 연결', () {
    test(
      '브로커 호출 순간 둘째 연결에서 SUBMITTING 행이 보인다 · 접수 뒤 broker_orders 행',
      () async {
        final Database other = second();
        final OrderIntentDraft d = _draft();
        final String id = intentIdFor(d.idempotencyKey);
        final List<Object?> seen = <Object?>[];
        final FakeOrderBroker broker = FakeOrderBroker(
          onSubmit: (BrokerOrderRequest r) async {
            seen.add(
              other
                  .select(
                    'SELECT status FROM order_intents WHERE intent_id = ?',
                    <Object?>[id],
                  )
                  .map((Row row) => row['status'])
                  .toList(),
            );
            // 브로커 응답은 1초 뒤 — submitted_at 은 «호출 직전»(SUBMITTING 시각)이어야 한다.
            clock.at = _t0.add(const Duration(seconds: 1));
          },
        );
        final ExecutionOutcome o = await executeIntent(d, _ok, ctx(broker));
        expect(o.status, ExecutionStatus.submitted);
        expect(seen, <Object?>[
          <Object?>['SUBMITTING'],
        ]);
        final Map<String, Object?> row = intentRow(other, id);
        expect(row['status'], 'SUBMITTED');
        expect(row['decision_id'], 'B-SMA-2026-10-30@2026-11-02');
        expect(row['mode'], 'LIVE');
        expect(row['operating_mode'], 'AUTO_TRADE');
        expect(row['dry_run'], 0);
        expect(row['created_at'], _t0.toIso8601String());
        final Row bo = other.select('SELECT * FROM broker_orders').single;
        expect(bo['broker_order_no'], '2026-11-02:0000000001');
        expect(bo['intent_id'], id);
        expect(bo['status'], 'SUBMITTED');
        expect(bo['remaining_qty'], 5);
        expect(bo['filled_qty'], 0);
        expect(bo['submitted_at'], _t0.toIso8601String());
        expect(
          row['updated_at'],
          _t0.add(const Duration(seconds: 1)).toIso8601String(),
        );
      },
    );

    test(
      '🔴 대조군 — 열린 트랜잭션 안의 행은 둘째 연결에서 안 보인다(판정이 가른다) · 원장은 그 INSERT 를 거절',
      () async {
        final Database other = second();
        db.execute('BEGIN');
        db.execute(
          "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('X_PROBE', 'now', 'probe')",
        );
        expect(
          db.select("SELECT 1 FROM trading_block WHERE flag_id = 'X_PROBE'"),
          hasLength(1),
        );
        expect(
          other.select("SELECT 1 FROM trading_block WHERE flag_id = 'X_PROBE'"),
          isEmpty,
        );
        final IntentRow row = IntentRow.fromDraft(
          _draft(),
          status: IntentStatus.reserved,
          configHash: 'cfg-test',
          execPolicy: ExecPolicy.execute,
          operatingMode: OperatingMode.autoTrade,
        );
        await expectLater(ledger.insertIntent(row), throwsStateError);
        db.execute('ROLLBACK');
        expect(await ledger.insertIntent(row), isTrue);
        expect(other.select('SELECT 1 FROM order_intents'), hasLength(1));
      },
    );
  });

  group('순서기 주요 경로(SQLite 원장)', () {
    test('같은 결정 두 번 = PREVENTED · 행 1 · 제출 1', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      await executeIntent(_draft(), _ok, ctx(broker));
      final ExecutionOutcome b = await executeIntent(
        _draft(),
        _ok,
        ctx(broker),
      );
      expect(b.status, ExecutionStatus.prevented);
      expect(broker.submitCount, 1);
      expect(db.select('SELECT 1 FROM order_intents'), hasLength(1));
    });

    test('결과 불명 = UNKNOWN · 같은 (시장 · 종목 · 전략) 다음 의도는 막고 다른 전략은 낸다', () async {
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[const FakeUnknown()],
      );
      final OrderIntentDraft d = _draft();
      await expectLater(
        executeIntent(d, _ok, ctx(broker)),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      expect(intentRow(db, intentIdFor(d.idempotencyKey))['status'], 'UNKNOWN');
      expect(
        await ledger.hasUnresolvedUnknown(
          'KR',
          '133690',
          P0sStrategyIds.sleeveB,
        ),
        isTrue,
      );
      expect(
        await ledger.hasUnresolvedUnknown(
          'KR',
          '133690',
          P0sStrategyIds.sleeveC,
        ),
        isFalse,
      );
      final ExecutionOutcome next = await executeIntent(
        _draft(
          side: OrderSide.sell,
          logical: 'BAND-B-2026-10-30',
          exec: const TradeDate('2026-11-03'),
        ),
        _ok,
        ctx(broker),
      );
      expect(next.message, startsWith('UNKNOWN_UNRESOLVED'));
      final ExecutionOutcome other = await executeIntent(
        _draft(strategy: P0sStrategyIds.sleeveC, logical: 'C-REBAL-2026-10-30'),
        _ok,
        ctx(broker),
      );
      expect(other.status, ExecutionStatus.submitted);
    });

    test('DRY_RUN = SKIPPED · dry_run 1 · 제출 0', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      final OrderIntentDraft d = _draft();
      final ExecutionOutcome o = await executeIntent(
        d,
        _ok,
        ctx(broker, policy: ExecPolicy.dryRun),
      );
      expect(o.message, 'DRY_RUN');
      final Map<String, Object?> row = intentRow(
        db,
        intentIdFor(d.idempotencyKey),
      );
      expect(row['status'], 'SKIPPED');
      expect(row['error_message'], 'DRY_RUN');
      expect(row['dry_run'], 1);
      expect(broker.submitCount, 0);
    });

    test(
      '브로커 거절 = REJECTED «BROKER: …» · orders_today 에 센다 · 1~5단계 거부는 안 센다(D22)',
      () async {
        final OrderIntentDraft a = _draft(logical: 'R-1');
        await executeIntent(
          a,
          _ok,
          ctx(
            FakeOrderBroker(
              script: <FakeSubmitStep>[const FakeReject('40580000', '장종료')],
            ),
          ),
        );
        expect(
          intentRow(db, intentIdFor(a.idempotencyKey))['error_message'],
          'BROKER: 40580000: 장종료',
        );
        db.execute(
          "INSERT INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, '2026-11-02T00:11:00Z', 'test')",
        );
        final ExecutionOutcome k = await executeIntent(
          _draft(logical: 'R-2'),
          _ok,
          ctx(FakeOrderBroker()),
        );
        expect(k.message, 'KILL_SWITCH');
        await executeIntent(
          _draft(logical: 'R-3', side: OrderSide.sell),
          _ok,
          ctx(FakeOrderBroker()),
        );
        expect(await ledger.ordersToday(_exec), 1);
        expect(await ledger.ordersToday(const TradeDate('2026-11-03')), 0);
      },
    );

    test('킬스위치 = cleared_at 이 NULL 인 동안만', () async {
      db.execute(
        "INSERT INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, '2026-11-01T00:00:00Z', 'test')",
      );
      expect(await ledger.killSwitchActive(), isTrue);
      db.execute(
        "UPDATE kill_switch_state SET cleared_at = '2026-11-02T00:00:00Z', decision_id = 'J-1'",
      );
      expect(await ledger.killSwitchActive(), isFalse);
    });

    test(
      '묶음 판정 SQL — 활성 RECON_MISMATCH 는 막고 · 해제된 행 · 표식 · LEDGER_FIX 는 읽지 않는다',
      () async {
        db.execute(
          "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('RECON_MISMATCH', 't', 'r'), "
          "('DST_WEEK', 't', 'r'), ('LEDGER_FIX', 't', 'r'), ('ADVICE_LEDGER_UNVERIFIED', 't', 'r')",
        );
        db.execute(
          'INSERT INTO trading_block (flag_id, set_at, reason, cleared_at, cleared_by) '
          "VALUES ('RESUME_INCOMPLETE', 't', 'r', 't2', 'auto:x')",
        );
        expect(await ledger.activeBlockFlags(), <String>{
          FlagIds.reconMismatch,
          FlagIds.adviceLedgerUnverified,
        });
        final ExecutionOutcome o = await executeIntent(
          _draft(),
          _ok,
          ctx(FakeOrderBroker()),
        );
        expect(o.message, 'SAF-407: RECON_MISMATCH');
      },
    );

    test('등록 안 된 전략 = SAF-406', () async {
      final ExecutionOutcome o = await executeIntent(
        _draft(strategy: P0sStrategyIds.pot, logical: 'POT-SMA-2026-10-30'),
        _ok,
        ctx(FakeOrderBroker()),
      );
      expect(o.message, startsWith('SAF-406'));
    });
  });

  group('SAF-408 · 410 판정 SQL(자동 설정 · 해제)', () {
    void deviation({required bool filled}) => db.execute(
      'INSERT OR REPLACE INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, '
      'is_deviation, rationale_before, expected_outcome, rule_cited, created_at) VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?, ?)',
      <Object?>[
        'J-dev',
        '2026-10-30',
        P0sStrategyIds.sleeveB,
        '{}',
        '{}',
        filled ? '근거' : null,
        filled ? '기대' : null,
        filled ? '03 §4-1' : null,
        't',
      ],
    );

    Row flag(String id) => db.select(
      'SELECT * FROM trading_block WHERE flag_id = ?',
      <Object?>[id],
    ).single;

    test('사전 필드가 빈 이탈 행 → 매수 차단 + 플래그 · 채우면 다음 매수에서 자동 해제(auto:SAF-408)', () async {
      deviation(filled: false);
      // 브로커 한 벌 — 같은 날 주문번호가 겹치면 broker_orders PK 가 막는다(그 경우 UNKNOWN · R36 🟡).
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome blocked = await executeIntent(
        _draft(logical: 'J-1'),
        _ok,
        ctx(broker),
      );
      expect(blocked.message, 'SAF-407: JOURNAL_MISSING');
      expect(flag(FlagIds.journalMissing)['cleared_at'], isNull);
      // 매도는 막지 않는다.
      final ExecutionOutcome sell = await executeIntent(
        _draft(logical: 'J-2', side: OrderSide.sell),
        _ok,
        ctx(broker),
      );
      expect(sell.status, ExecutionStatus.submitted);
      deviation(filled: true);
      final ExecutionOutcome ok = await executeIntent(
        _draft(logical: 'J-3'),
        _ok,
        ctx(broker),
      );
      expect(ok.status, ExecutionStatus.submitted);
      expect(flag(FlagIds.journalMissing)['cleared_by'], 'auto:SAF-408');
      // 다시 비면 같은 행을 다시 세운다(PK = flag_id).
      db.execute(
        "UPDATE decision_journal SET rule_cited = NULL WHERE journal_id = 'J-dev'",
      );
      expect(await ledger.journalMissing(), isTrue);
      expect(flag(FlagIds.journalMissing)['cleared_at'], isNull);
    });

    test('월말 뒤 3거래일은 유예 — 2026-03 은 3/2 대체공휴일이라 3/3 · 3/4 · 3/5 유예 · 3/6 부터 차단(04 §1)', () async {
      for (final String day in <String>[
        '2026-03-03',
        '2026-03-04',
        '2026-03-05',
      ]) {
        expect(
          await ledger.tierBUnjudged(TradeDate(day)),
          isFalse,
          reason: day,
        );
      }
      expect(await ledger.tierBUnjudged(const TradeDate('2026-03-06')), isTrue);
      expect(
        flag(FlagIds.tierBUnjudged)['reason'],
        contains('2026-02 계층 B 판정 누락: P0S_B,P0S_C'),
      );
      // 유예 안에서는 이미 선 플래그를 그대로 둔다.
      expect(await ledger.tierBUnjudged(const TradeDate('2026-04-01')), isTrue);
    });

    test('전략마다 판정 행이 다 있으면 자동 해제(auto:SAF-410) · 하나라도 없으면 그대로', () async {
      const TradeDate d = TradeDate(
        '2026-11-06',
      ); // 11월 4번째 거래일(11/2 · 3 · 4 · 5 · 6 → 5)
      expect(await ledger.tierBUnjudged(d), isTrue);
      db.execute(
        "INSERT INTO tier_b_judgement VALUES ('2026-10', 'P0S_B', 't', 0, 0, 0, 0)",
      );
      expect(await ledger.tierBUnjudged(d), isTrue);
      db.execute(
        "INSERT INTO tier_b_judgement VALUES ('2026-10', 'P0S_C', 't', 0, 0, 0, 0)",
      );
      expect(await ledger.tierBUnjudged(d), isFalse);
      expect(flag(FlagIds.tierBUnjudged)['cleared_by'], 'auto:SAF-410');
    });

    test('1월 집행일은 전년 12월 판정을 본다 · 달력 범위 밖 = StateError', () async {
      expect(await ledger.tierBUnjudged(const TradeDate('2027-01-08')), isTrue);
      expect(flag(FlagIds.tierBUnjudged)['reason'], startsWith('2026-12 '));
      await expectLater(
        ledger.tierBUnjudged(const TradeDate('2030-01-10')),
        throwsStateError,
      );
    });
  });

  group('기록 규칙', () {
    IntentRow row(IntentStatus status, {String logical = 'W-1', int qty = 5}) {
      final OrderIntentDraft d = _draft(logical: logical);
      return IntentRow.fromDraft(
        d,
        status: status,
        configHash: 'cfg-test',
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        quantity: qty,
      );
    }

    test('상태 전이는 앞 상태에서만 — 아니면 StateError', () async {
      final IntentRow r = row(IntentStatus.reserved);
      expect(await ledger.insertIntent(r), isTrue);
      await expectLater(
        ledger.markSubmitted(r.intentId, '2026-11-02:1'),
        throwsStateError,
      );
      await expectLater(ledger.markUnknown(r.intentId, 'x'), throwsStateError);
      await ledger.markSubmitting(r.intentId);
      await expectLater(ledger.markSkipped(r.intentId, 'x'), throwsStateError);
      await expectLater(ledger.markSubmitting(r.intentId), throwsStateError);
      await expectLater(ledger.markSubmitting('oi-none'), throwsStateError);
      expect(db.select('SELECT 1 FROM broker_orders'), isEmpty);
    });

    test(
      'INSERT 는 RESERVED · REJECTED · SKIPPED 만 · CHECK 위반은 false 가 아니라 예외',
      () async {
        await expectLater(
          ledger.insertIntent(row(IntentStatus.submitted)),
          throwsStateError,
        );
        await expectLater(
          ledger.insertIntent(
            row(IntentStatus.reserved, logical: 'W-2', qty: 0),
          ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test('접수 기록이 실패하면 broker_orders 도 남지 않는다(한 트랜잭션)', () async {
      final IntentRow r = row(IntentStatus.reserved);
      await ledger.insertIntent(r);
      await ledger.markSubmitting(r.intentId);
      db.execute(
        "INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) VALUES ('2026-11-02:9', ?, 't', 'X')",
        <Object?>[r.intentId],
      );
      await expectLater(
        ledger.markSubmitted(r.intentId, '2026-11-02:9'),
        throwsA(isA<SqliteException>()),
      );
      expect(db.autocommit, isTrue);
      expect(intentRow(db, r.intentId)['status'], 'SUBMITTING');
    });

    test('SIM 파일 — 그 파일의 mode 로 쓴다 · 다른 mode 로 열면 배치 A CHECK 가 막는다', () async {
      final Database sim = openLocalLedger(
        dir.path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sim.close);
      final SqliteOrderLedger simLedger = SqliteOrderLedger(
        sim,
        mode: RunMode.simInternal,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
      );
      expect(await simLedger.insertIntent(row(IntentStatus.reserved)), isTrue);
      expect(
        sim.select('SELECT mode FROM order_intents').single['mode'],
        'SIM_INTERNAL',
      );
      final SqliteOrderLedger wrong = SqliteOrderLedger(
        sim,
        mode: RunMode.live,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
      );
      await expectLater(
        wrong.insertIntent(row(IntentStatus.reserved, logical: 'W-3')),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
