// SQLite 주문 원장(설계 13 §8 R36 W2~W10 · 04 §3-1 · §1 · 02 §2-4 · §2-6 · §3-2).
//
// 🔴 `test_intent_before_order` 진짜판 — 파일 SQLite + **둘째 연결**: 브로커 호출 순간 둘째 연결에서 행이 보여야
//    한다(04 §3-1 v1.5 · AC-S04). 같은 연결의 SELECT 는 미커밋 행도 보이므로 판정 근거가 될 수 없다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
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
    lease: FakeLeaseGate(),
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

    test('🆕 E13d1 1.5 — 집행일 이하 마지막 스냅숏 · 없으면 NORMAL · STOPPED = REJECTED BREAKER_STOPPED · 모르는 코드 = 원장 불가', () async {
      expect(await ledger.breakerLevel(_exec), BreakerLevel.normal);
      db.execute(
        'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, cash_usd, fx_rate, positions_value, high_water_mark, drawdown, breaker_level, mode) '
        "VALUES ('2026-10-30', 60, 60, 0, NULL, 0, 100, -0.4, 'HALTED', 'LIVE'), ('2026-11-02', 60, 60, 0, NULL, 0, 100, -0.4, 'STOPPED', 'LIVE'), "
        "('2026-11-03', 60, 60, 0, NULL, 0, 100, -0.4, 'NORMAL', 'LIVE')",
      );
      expect(await ledger.breakerLevel(_exec), BreakerLevel.stopped);
      expect(
        await ledger.breakerLevel(const TradeDate('2026-11-01')),
        BreakerLevel.halted,
      );
      expect(
        await ledger.breakerLevel(const TradeDate('2026-11-03')),
        BreakerLevel.normal,
      );
      final ExecutionOutcome o = await executeIntent(
        _draft(logical: 'BS-1'),
        _ok,
        ctx(FakeOrderBroker()),
      );
      expect(
        (o.status, o.message),
        (ExecutionStatus.rejected, 'BREAKER_STOPPED'),
      );
      db.execute(
        "UPDATE equity_snapshot SET breaker_level = 'WEIRD' WHERE trade_date = '2026-11-02'",
      );
      await expectLater(ledger.breakerLevel(_exec), throwsArgumentError);
      final ExecutionOutcome f = await executeIntent(
        _draft(logical: 'BS-2'),
        _ok,
        ctx(FakeOrderBroker()),
      );
      expect(f.message, startsWith('RISK_UNAVAILABLE: 원장 확인 불가'));
    });

    test(
      '킬스위치 = 🆕 E13b SPEC v2.40 식 — 확인 뒤 48h 지나 해제해야만 꺼진다(손으로 고친 행은 못 푼다)',
      () async {
        db.execute(
          "INSERT INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, '2026-11-01T00:00:00Z', 'test')",
        );
        expect(await ledger.killSwitchActive(), isTrue);
        db.execute(
          "UPDATE kill_switch_state SET cleared_at = '2026-11-02T00:00:00Z', decision_id = 'J-1'",
        );
        expect(await ledger.killSwitchActive(), isTrue); // 확인 없음
        db.execute(
          "UPDATE kill_switch_state SET checklist_confirmed_at = '2026-11-01T00:30:00Z'",
        );
        expect(await ledger.killSwitchActive(), isTrue); // 23.5h
        db.execute(
          "UPDATE kill_switch_state SET cleared_at = '2026-11-03T00:30:00Z'",
        );
        expect(await ledger.killSwitchActive(), isFalse); // 48h
        // 🔴 시차 없는 시각 = 던진다(주문 경로는 막음으로 받는다).
        db.execute(
          "UPDATE kill_switch_state SET cleared_at = '2026-11-03T00:30:00'",
        );
        await expectLater(ledger.killSwitchActive(), throwsFormatException);
        final ExecutionOutcome o = await executeIntent(
          _draft(logical: 'K-1'),
          _ok,
          ctx(FakeOrderBroker()),
        );
        expect(o.status, isNot(ExecutionStatus.submitted));
      },
    );

    test('🆕 E13c1 🔴 파생 불일치는 어떤 심각도 · 상태에서도 주문을 막지 않는다 — LEDGER_INTEGRITY 는 막는다(R58 C8)', () async {
      int n = 0;
      for (final LedgerPair p in <LedgerPair>[
        LedgerPair.canonSupabase,
        LedgerPair.canonGithub,
        LedgerPair.canonCalendar,
        LedgerPair.canonSelfReport,
      ]) {
        for (final DiffSeverity sev in DiffSeverity.values) {
          for (final DiffStatus st in DiffStatus.values) {
            db.execute(
              'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, '
              'severity, origin_code, status, detected_at, applicable) '
              "VALUES (?, ?, 'EXECUTION_ROW', '2026-11-01', '{}', 'x', ?, NULL, ?, '2026-11-01T00:00:00Z', 1)",
              <Object?>['ld-${n++}', p.wire, sev.wire, st.wire],
            );
          }
        }
      }
      expect(n, 24);
      expect(await ledger.activeBlockFlags(), isEmpty);
      final ExecutionOutcome o = await executeIntent(
        _draft(logical: 'D-1'),
        _ok,
        ctx(FakeOrderBroker()),
      );
      expect(o.status, ExecutionStatus.submitted);
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-11-02T00:00:00Z', 't')",
      );
      final ExecutionOutcome k = await executeIntent(
        _draft(logical: 'D-2', side: OrderSide.sell),
        _ok,
        ctx(FakeOrderBroker()),
      );
      expect(k.status, ExecutionStatus.rejected);
      expect(k.message, contains('LEDGER_INTEGRITY'));
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

  group('🆕 E10e1 체결 원장(FillLedger · R38 Z2~Z6 · Z9)', () {
    const FillCostRates rates = FillCostRates(
      commissionRate: 0.00015,
      sellTaxRate: 0,
    );
    final DateTime intraday = DateTime.utc(2026, 11, 2, 1);
    final DateTime afterClose = DateTime.utc(2026, 11, 2, 6, 41);

    DailyFillRow fill(
      int cum,
      String amount, {
      int remaining = 0,
      int qty = 5,
      OrderSide side = OrderSide.buy,
      String odno = '0000000001',
    }) => DailyFillRow(
      orderDate: _exec,
      odno: odno,
      isCancelRow: false,
      symbol: '133690',
      side: side,
      orderQty: qty,
      cumFilledQty: cum,
      cumFilledAmount: Decimal.parse(amount),
      remainingQty: remaining,
    );

    Future<FillSyncReport> sync(
      FakeOrderBroker broker, {
      required bool dayEnd,
    }) => runFillSync(
      ledger: ledger,
      brokers: <String, OrderBroker>{'pension': broker},
      tradeDate: _exec,
      nowUtc: dayEnd ? afterClose : intraday,
      dayEnd: dayEnd,
      costs: rates,
    );

    Row brokerOrder() => db.select('SELECT * FROM broker_orders').single;
    List<Row> positions() =>
        db.select('SELECT * FROM positions ORDER BY symbol').toList();

    test(
      '주문 → 장중 부분 체결 → 마감 실효 — 실행 행 · 누적 정본 · 평단 · 의도 상태(한 트랜잭션씩)',
      () async {
        final FakeOrderBroker broker = FakeOrderBroker();
        final OrderIntentDraft d = _draft();
        await executeIntent(d, _ok, ctx(broker));
        final String id = intentIdFor(d.idempotencyKey);
        expect(
          (await ledger.openIntents(_exec)).single.brokerOrderNo,
          '2026-11-02:0000000001',
        );
        expect(await ledger.recordedFill('2026-11-02:0000000001'), isNull);

        broker.fills['2026-11-02'] = <DailyFillRow>[
          fill(3, '522541', remaining: 2),
        ];
        FillSyncReport r = await sync(broker, dayEnd: false);
        expect(r.applied.single.status, IntentStatus.partial);
        final Row e = db.select('SELECT * FROM executions').single;
        expect(e['execution_id'], '2026-11-02:0000000001#3');
        expect(e['quantity'], 3);
        expect(e['price'], closeTo(174180.3333333333, 1e-6));
        expect(e['commission'], closeTo(78.38115, 1e-9));
        expect(e['tax'], 0);
        expect(e['fill_origin'], 'BROKER');
        expect(e['cost_source'], 'ESTIMATED');
        expect(e['executed_at'], intraday.toIso8601String());
        expect(e['authored_at'], intraday.toIso8601String());
        Row bo = brokerOrder();
        expect(bo['status'], 'PARTIAL');
        expect(bo['filled_qty'], 3);
        expect(bo['remaining_qty'], 2);
        final RecordedFill rec = (await ledger.recordedFill(
          '2026-11-02:0000000001',
        ))!;
        expect(rec.quantity, 3);
        expect(
          rec.amount,
          Decimal.parse('522541'),
        ); // 🔴 정확한 누적(REAL 단가로는 되살리지 못한다)
        expect(intentRow(db, id)['status'], 'PARTIAL');
        Row pos = positions().single;
        expect(pos['quantity'], 3);
        expect(pos['entry_date'], '2026-11-02');
        expect(pos['entry_decision_id'], 'B-SMA-2026-10-30@2026-11-02');

        // 같은 누적을 다시 보면 행이 늘지 않는다(멱등).
        r = await sync(broker, dayEnd: false);
        expect(r.applied, isEmpty);
        expect(db.select('SELECT 1 FROM executions'), hasLength(1));

        broker.fills['2026-11-02'] = <DailyFillRow>[
          fill(4, '696720', remaining: 1),
        ];
        r = await sync(broker, dayEnd: true);
        expect(r.expired.single.expiredQty, 1);
        expect(
          db
              .select(
                'SELECT execution_id FROM executions ORDER BY execution_id',
              )
              .map((Row x) => x['execution_id']),
          <Object?>['2026-11-02:0000000001#3', '2026-11-02:0000000001#4'],
        );
        bo = brokerOrder();
        expect(bo['status'], 'EXPIRED');
        expect(bo['avg_fill_price'], 174180);
        expect(intentRow(db, id)['status'], 'EXPIRED');
        expect(intentRow(db, id)['error_message'], 'EXPIRED: 마감 실효 1주');
        pos = positions().single;
        expect(pos['quantity'], 4);
        expect(pos['avg_price'], closeTo(174180, 1e-6));
        expect(await ledger.openIntents(_exec), isEmpty);
      },
    );

    test(
      '매도로 0주 = 포지션 행을 지운다 · 보유를 넘는 매도는 StateError + 롤백(아무것도 안 쓴다)',
      () async {
        db.execute(
          'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
          "VALUES ('KR', '133690', 'P0S_B', 2, 170000, '2026-10-01', 't')",
        );
        final FakeOrderBroker broker = FakeOrderBroker();
        final OrderIntentDraft sell = _draft(
          side: OrderSide.sell,
          logical: 'BAND-B-2026-10-30',
        );
        await executeIntent(sell, _ok, ctx(broker));
        broker.fills['2026-11-02'] = <DailyFillRow>[
          fill(5, '870900', side: OrderSide.sell),
        ];
        await expectLater(sync(broker, dayEnd: false), throwsStateError);
        expect(db.select('SELECT 1 FROM executions'), isEmpty);
        expect(brokerOrder()['filled_qty'], 0);
        expect(
          intentRow(db, intentIdFor(sell.idempotencyKey))['status'],
          'SUBMITTED',
        );
        expect(positions().single['quantity'], 2);
        expect(db.autocommit, isTrue);

        db.execute("UPDATE positions SET quantity = 5 WHERE symbol = '133690'");
        final FillSyncReport r = await sync(broker, dayEnd: false);
        expect(r.applied.single.status, IntentStatus.filled);
        expect(positions(), isEmpty);
      },
    );

    test('일 마감 조회 실패 = UNKNOWN(DAY_END_UNAVAILABLE) · 열린 의도가 아니면 markUnresolved 는 StateError', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      final OrderIntentDraft d = _draft();
      await executeIntent(d, _ok, ctx(broker));
      broker.fillsError = StateError('조회 실패');
      final FillSyncReport r = await sync(broker, dayEnd: true);
      expect(r.unresolved.single.$2, startsWith('DAY_END_UNAVAILABLE'));
      final Map<String, Object?> row = intentRow(
        db,
        intentIdFor(d.idempotencyKey),
      );
      expect(row['status'], 'UNKNOWN');
      expect(
        await ledger.hasUnresolvedUnknown(
          'KR',
          '133690',
          P0sStrategyIds.sleeveB,
        ),
        isTrue,
      );
      await expectLater(
        ledger.markUnresolved(intentIdFor(d.idempotencyKey), 'x'),
        throwsStateError,
      );
    });

    test('기록된 누적의 꼴이 틀리면 StateError · 없는 주문번호도 StateError', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      await executeIntent(_draft(), _ok, ctx(broker));
      db.execute(
        "UPDATE broker_orders SET raw_response = '{\"tot_ccld_qty\":\"3\"}'",
      );
      await expectLater(
        ledger.recordedFill('2026-11-02:0000000001'),
        throwsStateError,
      );
      await expectLater(ledger.recordedFill('2026-11-02:9'), throwsStateError);
    });

    test('같은 의도에 브로커 주문이 둘이면 openIntents 가 StateError(이 판은 하나뿐이다)', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      final OrderIntentDraft d = _draft();
      await executeIntent(d, _ok, ctx(broker));
      db.execute(
        "INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) VALUES ('2026-11-02:7', ?, 't', 'SUBMITTED')",
        <Object?>[intentIdFor(d.idempotencyKey)],
      );
      await expectLater(ledger.openIntents(_exec), throwsStateError);
    });
  });

  group('🆕 E10e2 이월 · 해소 원장(CarryLedger · UnknownLedger · R39 T2 · T4 · T9)', () {
    const FillCostRates rates = FillCostRates(
      commissionRate: 0.00015,
      sellTaxRate: 0,
    );

    DailyFillRow row({
      int cum = 0,
      int remaining = 5,
      int cancelled = 0,
      String odno = '0000000001',
      TradeDate date = _exec,
    }) => DailyFillRow(
      orderDate: date,
      odno: odno,
      isCancelRow: false,
      symbol: '133690',
      side: OrderSide.buy,
      orderQty: 5,
      orderPrice: Decimal.parse('174180'),
      orderTime: '091005',
      cumFilledQty: cum,
      cumFilledAmount: Decimal.fromInt(174180 * cum),
      remainingQty: remaining,
      cancelConfirmedQty: cancelled,
    );

    Future<FillSyncReport> dayEnd(FakeOrderBroker broker, TradeDate day) =>
        runFillSync(
          ledger: ledger,
          brokers: <String, OrderBroker>{'pension': broker},
          tradeDate: day,
          nowUtc: DateTime.parse('${day.yyyyMmDd}T06:41:00Z'),
          dayEnd: true,
          costs: rates,
        );

    Future<void> submitted(OrderIntentDraft d, {DailyFillRow? fill}) async {
      final FakeOrderBroker broker = FakeOrderBroker(
        orderDate: d.executionDate,
      );
      final ExecutionOutcome o = await executeIntent(d, _ok, ctx(broker));
      expect(o.status, ExecutionStatus.submitted);
      if (fill != null) {
        broker.fills[d.executionDate.yyyyMmDd] = <DailyFillRow>[fill];
        await dayEnd(broker, d.executionDate);
      }
    }

    Future<void> rejectedBefore7(OrderIntentDraft d) async {
      expect(
        await ledger.insertIntent(
          IntentRow.fromDraft(
            d,
            status: IntentStatus.rejected,
            configHash: 'cfg-test',
            execPolicy: ExecPolicy.execute,
            operatingMode: OperatingMode.autoTrade,
            errorMessage: 'SAF-104: 한도',
          ),
        ),
        isTrue,
      );
    }

    setUp(() {
      for (final String s in <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
      ]) {
        db.execute(
          "INSERT INTO tier_b_judgement VALUES ('2026-09', ?, 't', 0, 0, 0, 0)",
          <Object?>[s],
        );
      }
    });

    String status(String intentId) =>
        db.select(
              'SELECT status FROM order_intents WHERE intent_id = ?',
              <Object?>[intentId],
            ).single['status']
            as String;

    test('실효 = 주문 − 누적 체결 − 취소 확인 · 사용 세션 = 서로 다른 집행일 수(막힌 날 포함 · `@` 앞만 같은 id 는 아니다)', () async {
      await rejectedBefore7(_draft(exec: const TradeDate('2026-10-30')));
      await submitted(
        _draft(
          logical: 'B-SMA-2026-10-30X',
          exec: const TradeDate('2026-10-29'),
        ),
      );
      await submitted(_draft(), fill: row(cum: 2, remaining: 2, cancelled: 1));
      final ExpiredIntent e = (await ledger.expiredIntents(_exec)).single;
      expect(e.logicalDecisionId, 'B-SMA-2026-10-30');
      expect(e.expiredQty, 2);
      expect(e.sessionsUsed, 2);
      expect(
        (e.strategyId, e.symbol, e.side),
        (P0sStrategyIds.sleeveB, '133690', OrderSide.buy),
      );
      expect(
        await ledger.expiredIntents(const TradeDate('2026-10-30')),
        isEmpty,
      );
      expect(
        planCarryOver(<ExpiredIntent>[e]).targets.single.sizing,
        isA<ShareSizing>(),
      );
    });

    test('🔴 `LIKE` 함정 — `_` 가 든 논리 id 는 그 id 만 센다(세션 · 분할 진행)', () async {
      await submitted(
        _draft(logical: 'DEP-plX1', exec: const TradeDate('2026-10-30')),
        fill: row(date: const TradeDate('2026-10-30'), cum: 1, remaining: 4),
      );
      await submitted(_draft(logical: 'DEP-pl_1'), fill: row());
      final ExpiredIntent e = (await ledger.expiredIntents(_exec)).single;
      expect(e.logicalDecisionId, 'DEP-pl_1');
      expect(e.sessionsUsed, 1);
      final SplitProgress p = await ledger.splitProgress(
        'DEP-pl_1',
        strategyId: P0sStrategyIds.sleeveB,
        symbol: '133690',
        before: const TradeDate('2026-11-03'),
      );
      expect((p.planned, p.filled), (5, 0));
    });

    test('분할 진행 = 앞 집행일 · 7단계를 지난 것(브로커 거절 · UNKNOWN_NOT_FOUND 포함 · SKIPPED · 1~5단계 거부 · 오늘 제외)', () async {
      const String logical = 'SEAS-A-IN-2026-11-04';
      // 10-26 결과 불명 → 해소 거절(UNKNOWN_NOT_FOUND) — 계획에 센다.
      final OrderIntentDraft unk = _draft(
        logical: logical,
        exec: const TradeDate('2026-10-26'),
      );
      await expectLater(
        executeIntent(
          unk,
          _ok,
          ctx(FakeOrderBroker(script: <FakeSubmitStep>[const FakeUnknown()])),
        ),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      await ledger.rejectUnknown(
        intentIdFor(unk.idempotencyKey),
        '$kUnknownNotFoundPrefix시험',
      );
      // 10-27 1~5단계 거부 · 10-28 DRY_RUN — 세지 않는다.
      await rejectedBefore7(
        _draft(logical: logical, exec: const TradeDate('2026-10-27')),
      );
      final ExecutionOutcome dry = await executeIntent(
        _draft(logical: logical, exec: const TradeDate('2026-10-28')),
        _ok,
        ctx(FakeOrderBroker(), policy: ExecPolicy.dryRun),
      );
      expect(dry.status, ExecutionStatus.skipped);
      // 10-29 접수 · 마감 3 체결 — 계획 5 · 체결 3.
      await submitted(
        _draft(logical: logical, exec: const TradeDate('2026-10-29')),
        fill: row(date: const TradeDate('2026-10-29'), cum: 3, remaining: 2),
      );
      // 10-30 브로커 거절 — 계획에 센다(7단계를 지났다).
      final ExecutionOutcome rej = await executeIntent(
        _draft(logical: logical, exec: const TradeDate('2026-10-30')),
        _ok,
        ctx(
          FakeOrderBroker(
            script: <FakeSubmitStep>[const FakeReject('APBK0919', '거절')],
          ),
        ),
      );
      expect(rej.status, ExecutionStatus.rejected);
      // 오늘(11-02) 접수 — 앞날이 아니다.
      await submitted(_draft(logical: logical));

      final SplitProgress p = await ledger.splitProgress(
        logical,
        strategyId: P0sStrategyIds.sleeveB,
        symbol: '133690',
        before: _exec,
      );
      expect((p.planned, p.filled), (15, 3));
      final SplitProgress other = await ledger.splitProgress(
        logical,
        strategyId: P0sStrategyIds.sleeveC,
        symbol: '133690',
        before: _exec,
      );
      expect((other.planned, other.filled), (0, 0));
    });

    test('UNKNOWN 해소 — 연결 = broker_orders 행 + SUBMITTED(한 트랜잭션) → 체결 동기화가 이어 쓴다 · 이미 붙은 주문번호 = 롤백', () async {
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[const FakeUnknown(), const FakeUnknown()],
      );
      final OrderIntentDraft d = _draft();
      final OrderIntentDraft c = _draft(
        strategy: P0sStrategyIds.sleeveC,
        logical: 'C-REB-2026-10-30',
      );
      // 예약 시각 순 — d 가 앞이다(같은 시각이면 intent_id 순).
      for (final (OrderIntentDraft x, int s) in <(OrderIntentDraft, int)>[
        (d, 0),
        (c, 1),
      ]) {
        clock.at = _t0.add(Duration(seconds: s));
        await expectLater(
          executeIntent(x, _ok, ctx(broker)),
          throwsA(isA<OrderOutcomeUnknown>()),
        );
      }
      final String id = intentIdFor(d.idempotencyKey);
      final String idC = intentIdFor(c.idempotencyKey);
      final List<UnknownIntent> u = await ledger.unknownIntents();
      expect(u.map((UnknownIntent x) => x.intentId), <String>[id, idC]);
      expect(
        (
          u.first.limitPrice,
          u.first.createdAtUtc,
          u.first.account,
          u.first.quantity,
        ),
        (174180.0, _t0, 'pension', 5),
      );

      broker.fills['2026-11-02'] = <DailyFillRow>[row()];
      clock.at = _t0.add(const Duration(minutes: 10));
      final UnknownResolutionReport report = await resolveUnknownOrders(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': broker},
        nowUtc: clock.at,
      );
      expect(
        report.resolutions.map((UnknownResolution r) => r.runtimeType),
        <Type>[UnknownLinked, UnknownMissed],
      );
      final Row b = db.select('SELECT * FROM broker_orders').single;
      expect(b['broker_order_no'], '2026-11-02:0000000001');
      expect(b['intent_id'], id);
      expect(b['status'], 'SUBMITTED');
      expect(b['submitted_at'], _t0.toIso8601String());
      expect(b['remaining_qty'], 5);
      expect(status(id), 'SUBMITTED');
      expect(
        await ledger.hasUnresolvedUnknown(
          'KR',
          '133690',
          P0sStrategyIds.sleeveB,
        ),
        isFalse,
      );
      expect(
        await ledger.linkedOrderNos(<String>[
          '2026-11-02:0000000001',
          '2026-11-02:9',
        ]),
        <String>{'2026-11-02:0000000001'},
      );
      expect(await ledger.linkedOrderNos(const <String>[]), isEmpty);

      // 이미 붙은 주문번호 · 이미 연결된 의도 = StateError · 아무것도 남지 않는다.
      await expectLater(
        ledger.linkUnknown(idC, '2026-11-02:0000000001'),
        throwsStateError,
      );
      await expectLater(
        ledger.linkUnknown(id, '2026-11-02:0000000002'),
        throwsStateError,
      );
      expect(db.select('SELECT * FROM broker_orders'), hasLength(1));
      expect(status(idC), 'UNKNOWN');
      expect(db.autocommit, isTrue);

      broker.fills['2026-11-02'] = <DailyFillRow>[row(cum: 5, remaining: 0)];
      final FillSyncReport fills = await runFillSync(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': broker},
        tradeDate: _exec,
        nowUtc: DateTime.utc(2026, 11, 2, 1),
        dayEnd: false,
        costs: rates,
      );
      expect(fills.applied.single.status, IntentStatus.filled);
      expect(status(id), 'FILLED');
    });

    test('UNKNOWN 해소 — 놓침 표시 → 3분 뒤 REJECTED(UNKNOWN_NOT_FOUND) · orders_today 에 센다 · 그 밖 전이 = 오류', () async {
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[const FakeUnknown()],
      );
      final OrderIntentDraft d = _draft();
      await expectLater(
        executeIntent(d, _ok, ctx(broker)),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      final String id = intentIdFor(d.idempotencyKey);
      final String original =
          db
                  .select('SELECT error_message FROM order_intents')
                  .single['error_message']
              as String;
      expect(await ledger.ordersToday(_exec), 1);

      final DateTime t1 = _t0.add(const Duration(minutes: 10));
      final Map<String, OrderBroker> brokers = <String, OrderBroker>{
        'pension': broker,
      };
      await resolveUnknownOrders(ledger: ledger, brokers: brokers, nowUtc: t1);
      expect(
        db
            .select('SELECT error_message FROM order_intents')
            .single['error_message'],
        withUnknownMiss(original, t1),
      );
      expect(status(id), 'UNKNOWN');

      await resolveUnknownOrders(
        ledger: ledger,
        brokers: brokers,
        nowUtc: t1.add(kUnknownMissGap),
      );
      expect(status(id), 'REJECTED');
      expect(
        db
            .select('SELECT error_message FROM order_intents')
            .single['error_message'],
        startsWith(kUnknownNotFoundPrefix),
      );
      expect(await ledger.ordersToday(_exec), 1);
      expect(await ledger.unknownIntents(), isEmpty);

      await expectLater(
        ledger.noteUnknownMiss(id, 'UNKNOWN_MISS@x'),
        throwsStateError,
      );
      await expectLater(
        ledger.rejectUnknown(id, '${kUnknownNotFoundPrefix}again'),
        throwsStateError,
      );
      await expectLater(ledger.rejectUnknown(id, '사유'), throwsArgumentError);
    });

    test('주문번호가 있는 UNKNOWN(일 마감 조회 실패)은 해소 대상이 아니다 · 거절도 못 한다', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      final OrderIntentDraft d = _draft();
      await executeIntent(d, _ok, ctx(broker));
      broker.fillsError = StateError('조회 실패');
      await dayEnd(broker, _exec);
      final String id = intentIdFor(d.idempotencyKey);
      expect(status(id), 'UNKNOWN');
      expect(await ledger.unknownIntents(), isEmpty);
      await expectLater(
        ledger.rejectUnknown(id, '${kUnknownNotFoundPrefix}x'),
        throwsStateError,
      );
      await expectLater(
        ledger.linkUnknown(id, '2026-11-02:0000000009'),
        throwsStateError,
      );
      expect(status(id), 'UNKNOWN');
    });

    test('실효 행의 기록된 취소 확인 꼴이 틀리면 StateError', () async {
      await submitted(_draft(), fill: row());
      db.execute(
        "UPDATE broker_orders SET raw_response = '{\"tot_ccld_qty\":0,\"tot_ccld_amt\":\"0\"}'",
      );
      await expectLater(ledger.expiredIntents(_exec), throwsStateError);
    });
  });

  group('🆕 E10f 대사 원장(ReconLedger · R40 A2 · A7 · A8 · 04 §7)', () {
    const Map<String, String> map = <String, String>{
      P0sStrategyIds.sleeveB: 'pension',
    };
    final DateTime at = DateTime.utc(2026, 11, 2, 6, 45);

    void position(String symbol, int qty, {String market = 'KR'}) => db.execute(
      'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
      'VALUES (?, ?, ?, ?, 174180, ?, ?)',
      <Object?>[market, symbol, P0sStrategyIds.sleeveB, qty, '2026-10-30', 't'],
    );

    void journal(String id, String? kind) => db.execute(
      'INSERT INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, kind, created_at) '
      "VALUES (?, '2026-11-02', ?, '{}', '{}', ?, 't')",
      <Object?>[id, P0sStrategyIds.sleeveB, kind],
    );

    Future<ReconReport> recon(FakeOrderBroker broker, {DateTime? now}) =>
        runReconciliation(
          ledger: ledger,
          brokers: <String, OrderBroker>{'pension': broker},
          balances: <String, BrokerBalanceSource>{'pension': broker},
          accountByStrategy: map,
          tradeDate: _exec,
          nowUtc: () => now ?? at,
          sleep: (Duration d) async {},
        );

    Row flag() => db
        .select("SELECT * FROM trading_block WHERE flag_id = 'RECON_MISMATCH'")
        .single;

    test('대사 기록 = 한 트랜잭션 — reconciliation_log · ledger_diff(CANON_BROKER · BLOCKING · OPEN · applicable 1) · RECON_MISMATCH · 같은 어긋남 재실행 = 한 행', () async {
      position('133690', 5);
      final FakeOrderBroker broker = FakeOrderBroker()..holdings['133690'] = 3;
      final ReconReport r = await recon(broker);
      expect(r.action, ReconAction.blocked);

      final Row log = db.select('SELECT * FROM reconciliation_log').single;
      expect(log['recon_id'], r.reconId);
      expect(log['matched'], 0);
      expect(log['action_taken'], 'BLOCKED');
      expect(log['run_at'], at.toIso8601String());
      final Row d = db.select('SELECT * FROM ledger_diff').single;
      expect(d['diff_id'], ledgerDiffIdOf(_exec, r.blocking.single));
      expect(
        (
          d['pair'],
          d['axis'],
          d['authored_date'],
          d['severity'],
          d['status'],
          d['applicable'],
          d['origin_code'],
        ),
        ('CANON_BROKER', 'QUANTITY', '2026-11-02', 'BLOCKING', 'OPEN', 1, null),
      );
      expect(d['delta_label'], 'pension · 133690 보유 — 원장 5주 · 브로커 3주');
      expect(flag()['cleared_at'], isNull);
      expect(flag()['reason'], contains(r.reconId));
      final Object? setAt = flag()['set_at'];

      await recon(broker);
      expect(db.select('SELECT * FROM ledger_diff'), hasLength(1));
      // 같은 시각 두 판도 id 가 겹치지 않는다(원장이 시각 + 일련으로 매긴다).
      expect(
        db
            .select('SELECT recon_id FROM reconciliation_log ORDER BY recon_id')
            .map((Row x) => x['recon_id']),
        <String>[
          'rc-${at.toIso8601String()}#1',
          'rc-${at.toIso8601String()}#2',
        ],
      );
      expect(flag()['set_at'], setAt);
      // 이미 서 있으면 다시 쓰지 않는다(뒤 시각의 판도 set_at 그대로).
      await recon(broker, now: at.add(const Duration(minutes: 9)));
      expect(flag()['set_at'], setAt);
      expect(db.select('SELECT * FROM ledger_diff'), hasLength(1));
      // 🔴 자동 수정 없음.
      expect(db.select('SELECT quantity FROM positions').single['quantity'], 5);
    });

    test(
      'krHoldings = KR 만 · orderFills = 그날 KR 주문의 체결 합(체결 0 주문 포함)',
      () async {
        position('133690', 5);
        position('QQQ', 2, market: 'US');
        expect(
          (await ledger.krHoldings()).map(
            (LedgerHolding h) => (h.strategyId, h.symbol, h.quantity),
          ),
          <(String, String, int)>[(P0sStrategyIds.sleeveB, '133690', 5)],
        );
        final FakeOrderBroker broker = FakeOrderBroker();
        await executeIntent(_draft(), _ok, ctx(broker));
        await executeIntent(_draft(symbol: '411060'), _ok, ctx(broker));
        broker.fills['2026-11-02'] = <DailyFillRow>[
          DailyFillRow(
            orderDate: _exec,
            odno: '0000000001',
            isCancelRow: false,
            symbol: '133690',
            side: OrderSide.buy,
            orderQty: 5,
            cumFilledQty: 3,
            cumFilledAmount: Decimal.parse('522540'),
            remainingQty: 2,
          ),
        ];
        await runFillSync(
          ledger: ledger,
          brokers: <String, OrderBroker>{'pension': broker},
          tradeDate: _exec,
          nowUtc: DateTime.utc(2026, 11, 2, 1),
          dayEnd: false,
          costs: const FillCostRates(commissionRate: 0, sellTaxRate: 0),
        );
        expect(
          (await ledger.orderFills(_exec)).map(
            (LedgerOrderFill f) =>
                (f.brokerOrderNo, f.account, f.symbol, f.filledQty),
          ),
          <(String, String, String, int)>[
            ('2026-11-02:0000000001', 'pension', '133690', 3),
            ('2026-11-02:0000000002', 'pension', '411060', 0),
          ],
        );
        expect(await ledger.orderFills(const TradeDate('2026-11-03')), isEmpty);
      },
    );

    test('🔴 test_reconcile_mismatch_blocks(SQLite) — 다음 주문 SAF-407 거부 · 브로커 호출 0 · 일치 대사도 플래그를 풀지 않는다', () async {
      position('133690', 5);
      final FakeOrderBroker broker = FakeOrderBroker()..holdings['133690'] = 3;
      await recon(broker);
      final ExecutionOutcome o = await executeIntent(
        _draft(side: OrderSide.sell),
        _ok,
        ctx(broker),
      );
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, contains(FlagIds.reconMismatch));
      expect(broker.submitCount, 0);

      broker.holdings['133690'] = 5;
      expect((await recon(broker)).action, ReconAction.matched);
      expect(await ledger.reconBlocked(), isTrue);
      expect(flag()['cleared_at'], isNull);
    });

    test('🔴 test_clear_recon_without_decision_id_rejected(SQLite) — 저널은 kind = RECON_CLEAR · 해제 = 플래그 · RESOLVED · 해제 로그 한 트랜잭션 · 다시 보이면 다시 연다', () async {
      journal('dj-discretion', 'DISCRETION');
      journal('dj-recon', 'RECON_CLEAR');
      position('133690', 5);
      final FakeOrderBroker broker = FakeOrderBroker()..holdings['133690'] = 3;
      await recon(broker);

      for (final String id in <String>['', 'dj-none', 'dj-discretion']) {
        await expectLater(
          clearRecon(
            ledger,
            originCode: OriginCodes.fillLag,
            decisionId: id,
            clearedBy: 'telegram:owner',
            nowUtc: at,
          ),
          throwsA(isA<JournalRequired>()),
          reason: id,
        );
      }
      expect(await ledger.reconBlocked(), isTrue);

      final DateTime cAt = at.add(const Duration(minutes: 5));
      final ReconClearOutcome out = await clearRecon(
        ledger,
        originCode: OriginCodes.manualOrder,
        decisionId: 'dj-recon',
        clearedBy: 'telegram:owner',
        nowUtc: cAt,
      );
      expect(out.postmortemDueUtc, cAt.add(const Duration(days: 7)));
      final Row f = flag();
      expect(
        (f['cleared_at'], f['cleared_by'], f['decision_id'], f['origin_code']),
        (cAt.toIso8601String(), 'telegram:owner', 'dj-recon', 'MANUAL_ORDER'),
      );
      final Row d = db.select('SELECT * FROM ledger_diff').single;
      expect((d['status'], d['origin_code']), ('RESOLVED', 'MANUAL_ORDER'));
      final Row log = db
          .select(
            "SELECT * FROM reconciliation_log WHERE action_taken = 'CLEARED'",
          )
          .single;
      expect(jsonDecode(log['discrepancies'] as String), <String, Object?>{
        'origin_code': 'MANUAL_ORDER',
        'decision_id': 'dj-recon',
        'cleared_by': 'telegram:owner',
        'resolved': 1,
      });
      expect(await ledger.reconBlocked(), isFalse);

      // 원장이 그대로면 다음 대사가 같은 행을 다시 연다(정정 경로 = E13).
      await recon(broker);
      final Row again = db.select('SELECT * FROM ledger_diff').single;
      expect((again['status'], again['origin_code']), ('OPEN', null));
      expect(flag()['cleared_at'], isNull);
      expect(flag()['decision_id'], isNull);
    });

    test(
      '플래그가 없을 때 · 이미 풀렸을 때 해제 = StateError · 아무것도 남지 않는다(한 트랜잭션)',
      () async {
        final ReconClearance c = ReconClearance(
          originCode: OriginCodes.fillLag,
          decisionId: 'dj-recon',
          clearedBy: 'x',
          clearedAtUtc: at,
        );
        await expectLater(ledger.clearReconBlock(c), throwsStateError);
        expect(db.select('SELECT * FROM reconciliation_log'), isEmpty);
        expect(db.autocommit, isTrue);

        position('133690', 5);
        final FakeOrderBroker broker = FakeOrderBroker()
          ..holdings['133690'] = 3;
        await recon(broker);
        await ledger.clearReconBlock(c);
        final int logs = db.select('SELECT * FROM reconciliation_log').length;
        final Object? clearedAt = flag()['cleared_at'];
        await expectLater(
          ledger.clearReconBlock(
            ReconClearance(
              originCode: OriginCodes.dbError,
              decisionId: 'dj-other',
              clearedBy: 'y',
              clearedAtUtc: at.add(const Duration(minutes: 1)),
            ),
          ),
          throwsStateError,
        );
        expect(db.select('SELECT * FROM reconciliation_log'), hasLength(logs));
        expect(flag()['cleared_at'], clearedAt);
        expect(flag()['origin_code'], OriginCodes.fillLag);
        expect(db.autocommit, isTrue);
      },
    );

    test('🆕 E13e2 🔴 MANUAL_ORDER 해제 = 같은 트랜잭션에 SEV2 7일 — 건 쓰기 실패 = 해제도 없음(04 §3-5 ④ · R63 V1)', () async {
      position('133690', 5);
      await recon(FakeOrderBroker()..holdings['133690'] = 3);
      final SafetyIncident inc = manualOrderIncidentOf(
        decisionId: 'dj-m',
        clearedAtUtc: at,
      );
      ReconClearance c() => ReconClearance(
        originCode: OriginCodes.manualOrder,
        decisionId: 'dj-m',
        clearedBy: 'app',
        clearedAtUtc: at,
        incident: inc,
      );
      db.execute(
        "CREATE TRIGGER no_inc BEFORE INSERT ON incidents BEGIN SELECT RAISE(ABORT, 'x'); END",
      );
      await expectLater(
        ledger.clearReconBlock(c()),
        throwsA(isA<SqliteException>()),
      );
      expect(flag()['cleared_at'], isNull);
      expect(
        db.select('SELECT status FROM ledger_diff').single['status'],
        'OPEN',
      );
      expect(
        db.select(
          "SELECT 1 FROM reconciliation_log WHERE action_taken = 'CLEARED'",
        ),
        isEmpty,
      );
      db.execute('DROP TRIGGER no_inc');
      await ledger.clearReconBlock(c());
      final Row i = db.select('SELECT * FROM incidents').single;
      expect(
        (
          i['incident_id'],
          i['severity'],
          i['category'],
          i['due_at'],
          i['resolved_at'],
          i['postmortem'],
        ),
        (
          'SEV2-MANUAL_ORDER-dj-m',
          'SEV2',
          'MANUAL_ORDER',
          at.add(const Duration(days: 7)).toIso8601String(),
          null,
          null,
        ),
      );
      expect(flag()['origin_code'], OriginCodes.manualOrder);
    });

    test('🆕 E13c1 🔴 원인 코드 쓰기 화이트리스트 — 파생 · 옛 CORP_ACTION · 열거 밖 = ArgumentError · 아무것도 안 씀(R58 C7)', () async {
      position('133690', 5);
      await recon(FakeOrderBroker()..holdings['133690'] = 3);
      final int logs = db.select('SELECT * FROM reconciliation_log').length;
      for (final String code in <String>[
        OriginCodes.pushLag,
        OriginCodes.corpActionLegacy,
        '확인함',
      ]) {
        await expectLater(
          ledger.clearReconBlock(
            ReconClearance(
              originCode: code,
              decisionId: 'dj-recon',
              clearedBy: 'x',
              clearedAtUtc: at,
            ),
          ),
          throwsArgumentError,
        );
      }
      expect(flag()['cleared_at'], isNull);
      expect(db.select('SELECT * FROM reconciliation_log'), hasLength(logs));
      expect(
        db.select('SELECT status FROM ledger_diff').single['status'],
        'OPEN',
      );
      expect(db.autocommit, isTrue);
    });

    test('🔴 test_resume_does_not_clear_recon_block(SQLite) — 킬스위치 해제 행 · SAF-408 · 410 판정 · 일치 대사 뒤에도 RECON_MISMATCH 는 남는다', () async {
      position('133690', 5);
      final FakeOrderBroker broker = FakeOrderBroker()..holdings['133690'] = 3;
      await recon(broker);
      db.execute(
        'INSERT INTO kill_switch_state (id, activated_at, activated_by, checklist_confirmed_at, cleared_at, decision_id) '
        "VALUES (1, '2026-11-01T00:00:00Z', 'telegram', '2026-11-01T00:10:00Z', '2026-11-03T00:10:00Z', 'dj-resume')",
      );
      expect(await ledger.killSwitchActive(), isFalse);
      await ledger.journalMissing();
      await ledger.tierBUnjudged(_exec);
      broker.holdings['133690'] = 5;
      expect((await recon(broker)).action, ReconAction.matched);
      expect(await ledger.reconBlocked(), isTrue);
      expect(await ledger.activeBlockFlags(), contains(FlagIds.reconMismatch));
    });
  });

  group('🆕 E15c1 가상 체결 브로커 × sim 원장(R83 Y3 · Y5 · Y6)', () {
    test('주문 → 15:40 앞 = 미판정 · 예약 현금 · 마감 = 당일 봉 체결(SIMULATED) · 닿지 않음 = 실효 · 잔고 · 현금 = 원장', () async {
      final Database sdb = openLocalLedger(
        dir.path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sdb.close);
      final SqliteOrderLedger sl = SqliteOrderLedger(
        sdb,
        mode: RunMode.simInternal,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
      );
      sdb.execute(
        'INSERT INTO cash_flow (flow_id, trade_date, amount, kind, account_alias) VALUES '
        "('F1', '2026-10-30', 5000000, 'DEPOSIT', 'pension'), ('F2', '2026-10-30', 999, 'DEPOSIT', 'general')",
      );
      sdb.execute(
        'INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
        <Object?>[P0sStrategyIds.sleeveB, 'LIVE', '2026-10-01', 1.0],
      );
      final SqliteSimLedgerView view = SqliteSimLedgerView(
        sdb,
        account: 'pension',
        strategies: <String>{P0sStrategyIds.sleeveB},
        clock: clock,
      );
      final _SimBars bars = _SimBars()
        ..bars['133690'] = const QuoteBar(
          date: '2026-11-02',
          close: 174500,
          open: 174000,
          high: 175000,
          low: 173000,
        )
        ..bars['069500'] = const QuoteBar(
          date: '2026-11-02',
          close: 181000,
          open: 181000,
          high: 182000,
          low: 180000,
        );
      DateTime now = _t0;
      final SimInternalBroker broker = SimInternalBroker(
        ledger: view,
        bars: bars,
        nowUtc: () => now,
      );
      final ExecutionContext sctx = ExecutionContext(
        ledger: sl,
        lease: FakeLeaseGate(),
        broker: broker,
        limitConfig: _limits,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg-test',
      );
      await executeIntent(_draft(), _ok, sctx);
      await executeIntent(
        _draft(symbol: '069500', logical: 'B-SMA-2026-10-30-X'),
        _ok,
        sctx,
      );
      final List<SimOrder> orders = await view.ordersOf(_exec);
      expect(
        orders.map(
          (SimOrder o) =>
              (o.odno, o.symbol, o.side, o.quantity, o.orderType, o.limitPrice),
        ),
        <(String, String, OrderSide, int, String, double?)>[
          ('SIM0000001', '133690', OrderSide.buy, 5, 'LIMIT', 174180),
          ('SIM0000002', '069500', OrderSide.buy, 5, 'LIMIT', 174180),
        ],
      );
      expect(await view.ordersOf(const TradeDate('2026-11-03')), isEmpty);
      expect((await view.orderNo('2026-11-02:SIM0000002'))!.symbol, '069500');
      expect(await view.orderNo('2026-11-02:SIM0000009'), isNull);
      expect(await view.maxSimSeq(_exec), 2);
      expect(await view.maxSimSeq(const TradeDate('2026-11-03')), 0);
      expect(await view.openBuys(), hasLength(2));
      expect(await view.cashFlowSum(), 5000000);
      expect(
        await broker.orderableCashKrw(),
        Decimal.parse('3258200'),
        reason: '5,000,000 − 판정 전 매수 2 × 5 × 174,180',
      );
      expect(
        view.orderableCashTextNow(),
        (await broker.orderableCashKrw()).toString(),
        reason: '🆕 E11q1 — 보유 화면 동기 셈 = 브로커 셈(예약 포함)',
      );
      expect(
        (await broker.dailyFills(_exec))
            .map((DailyFillRow r) => r.remainingQty),
        <int>[5, 5],
      );
      now = DateTime.utc(2026, 11, 2, 6, 41); // 15:41 KST
      await runFillSync(
        ledger: sl,
        brokers: <String, OrderBroker>{'pension': broker},
        tradeDate: _exec,
        nowUtc: now,
        dayEnd: true,
        costs: const FillCostRates(commissionRate: 0.00015, sellTaxRate: 0),
      );
      final Row e = sdb.select('SELECT * FROM executions').single;
      expect(
        (
          e['broker_order_no'],
          e['quantity'],
          e['price'],
          e['fill_origin'],
          e['cost_source'],
        ),
        ('2026-11-02:SIM0000001', 5, 174000.0, 'SIMULATED', 'ESTIMATED'),
      );
      expect(
        sdb
            .select('SELECT symbol, status FROM order_intents ORDER BY symbol')
            .map((Row r) => (r['symbol'], r['status'])),
        <(Object?, Object?)>[('069500', 'EXPIRED'), ('133690', 'FILLED')],
      );
      expect(await view.holdings(), <String, int>{'133690': 5});
      expect(await view.openBuys(), isEmpty);
      final List<SimExecution> ex = await view.executions();
      expect(
        (ex.single.side, ex.single.quantity, ex.single.price),
        (OrderSide.buy, 5, 174000.0),
      );
      final double fee =
          (e['commission'] as num).toDouble() + (e['tax'] as num).toDouble();
      expect(
        await broker.orderableCashKrw(),
        Decimal.parse('5000000') -
            Decimal.parse('870000') -
            Decimal.parse('$fee'),
      );
      expect((await broker.balance()).holdings, <String, int>{'133690': 5});
      expect(
        view.orderableCashTextNow(),
        (await broker.orderableCashKrw()).toString(),
        reason: '🆕 E11q1 — 체결 뒤(대금 + 비용)도 같은 셈',
      );
      expect(sdb.select('SELECT * FROM data_gap'), isEmpty);
      final SqliteSimLedgerView other = SqliteSimLedgerView(
        sdb,
        account: 'general',
        strategies: const <String>{},
        clock: clock,
      );
      expect(await other.ordersOf(_exec), isEmpty);
      expect(await other.holdings(), isEmpty);
      expect(await other.cashFlowSum(), 999);
      expect(await other.executions(), isEmpty);
      expect(await other.maxSimSeq(_exec), 2);
      expect(await other.orderNo('2026-11-02:SIM0000001'), isNull);
      expect(
        await SqliteSimLedgerView(
          sdb,
          account: 'pension',
          strategies: <String>{P0sStrategyIds.sleeveC},
          clock: clock,
        ).holdings(),
        isEmpty,
      );
    });

    test('봉 공백 기록 = 1행(같은 날 · 종목 다시 = 그대로)', () async {
      final Database sdb = openLocalLedger(
        dir.path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sdb.close);
      final SqliteSimLedgerView view = SqliteSimLedgerView(
        sdb,
        account: 'pension',
        strategies: const <String>{},
        clock: clock,
      );
      await view.recordBarGap(_exec, '133690');
      await view.recordBarGap(_exec, '133690');
      final Row g = sdb.select('SELECT * FROM data_gap').single;
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
          'GAP-SIMBAR-2026-11-02-133690',
          'sim_fill_bar',
          '2026-11-02',
          '2026-11-02',
          0,
          'SIM_BAR_MISSING',
        ),
      );
    });
  });
}

class _SimBars implements DailyQuoteFeed {
  final Map<String, QuoteBar> bars = <String, QuoteBar>{};

  @override
  MarketDataSource get source => MarketDataSource.kis;

  @override
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  }) async => QuoteFetch(
    bars: <QuoteBar>[?bars[symbol]],
    pageBodies: const <String>[],
    attempts: 1,
  );
}
