// 이월 · 계절 분할 진행 · UNKNOWN 해소 · G-FB(설계 13 §8 R39 T2~T10 · R33 D6 · D8 · D16 · 04 §3-3 v2.38).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _d1 = TradeDate('2026-11-02');
const TradeDate _d2 = TradeDate('2026-11-03');
const TradeDate _d3 = TradeDate('2026-11-04');

const FillCostRates _rates = FillCostRates(
  commissionRate: 0.00015,
  sellTaxRate: 0,
);

/// [day] 의 KST 시각(UTC 값).
DateTime _kst(TradeDate day, int h, int m, [int s = 0]) =>
    DateTime.parse('${day.yyyyMmDd}T00:00:00Z')
        .add(Duration(hours: h - 9, minutes: m, seconds: s));

ExpiredIntent _e({
  String logical = 'B-SMA-2026-10-30',
  int qty = 4,
  int sessions = 1,
  String symbol = '133690',
}) => ExpiredIntent(
  intentId: 'oi-$logical-$sessions',
  logicalDecisionId: logical,
  strategyId: P0sStrategyIds.sleeveB,
  symbol: symbol,
  side: OrderSide.buy,
  expiredQty: qty,
  sessionsUsed: sessions,
);

UnknownIntent _u({
  int qty = 5,
  double? limit = 174180,
  DateTime? created,
  String? msg = '제출 결과 불명 — 시간 초과',
}) => UnknownIntent(
  intentId: 'oi-u',
  tradeDate: _d1,
  account: 'pension',
  symbol: '133690',
  side: OrderSide.buy,
  quantity: qty,
  limitPrice: limit,
  createdAtUtc: created ?? _kst(_d1, 9, 10),
  errorMessage: msg,
);

DailyFillRow _r({
  String odno = '0000000001',
  int qty = 5,
  String? price = '174180',
  String? time = '091005',
  String symbol = '133690',
  OrderSide side = OrderSide.buy,
  TradeDate date = _d1,
  bool cancelRow = false,
  int cum = 0,
}) => DailyFillRow(
  orderDate: date,
  odno: odno,
  isCancelRow: cancelRow,
  symbol: symbol,
  side: side,
  orderQty: qty,
  orderPrice: price == null ? null : _d(price),
  orderTime: time,
  cumFilledQty: cum,
  cumFilledAmount: Decimal.fromInt(174180 * cum),
  remainingQty: qty - cum,
);

UnknownResolution _res(
  UnknownIntent it,
  List<DailyFillRow> rows, {
  Set<String> linked = const <String>{},
  DateTime? now,
}) => resolveUnknown(
  it,
  rows: rows,
  linkedOrderNos: linked,
  nowUtc: now ?? _kst(_d1, 9, 20),
);

Future<FillSyncReport> _dayEnd(
  FakeOrderLedger ledger,
  FakeOrderBroker broker,
  TradeDate day,
) => runFillSync(
  ledger: ledger,
  brokers: <String, OrderBroker>{'pension': broker},
  tradeDate: day,
  nowUtc: _kst(day, 15, 41),
  dayEnd: true,
  costs: _rates,
);

void main() {
  group('이월 계획(planCarryOver · R39 T3 · D6)', () {
    test('사용 세션 1 · 2 = 다음 세션 대상(실효 수량 · 같은 논리 id) · 3 = 버림(P1)', () {
      final CarryPlan plan = planCarryOver(
        <ExpiredIntent>[
          _e(),
          _e(logical: 'C-REB-2026-10-30', qty: 2, sessions: 2),
          _e(logical: 'POT-SMA-2026-10-30', qty: 1, sessions: 3),
        ],
        instruments: const <String, InstrumentKind>{
          '133690': InstrumentKind.etf,
        },
      );
      expect(
        plan.targets.map(
          (OrderTarget t) => (
            t.logicalDecisionId,
            (t.sizing as ShareSizing).shares,
            t.instrument,
            t.side,
            t.strategyId,
            t.symbol,
          ),
        ),
        <(String, int, InstrumentKind, OrderSide, String, String)>[
          (
            'B-SMA-2026-10-30',
            4,
            InstrumentKind.etf,
            OrderSide.buy,
            P0sStrategyIds.sleeveB,
            '133690',
          ),
          (
            'C-REB-2026-10-30',
            2,
            InstrumentKind.etf,
            OrderSide.buy,
            P0sStrategyIds.sleeveB,
            '133690',
          ),
        ],
      );
      expect(plan.dropped.single.logicalDecisionId, 'POT-SMA-2026-10-30');
      expect(plan.seasonal, isEmpty);
      expect(kCarrySessionLimit, 3);
    });

    test('실효 0 은 건너뛴다 · 상품 맵에 없는 종목은 개별주(fail-closed)', () {
      final CarryPlan plan = planCarryOver(<ExpiredIntent>[
        _e(qty: 0),
        _e(symbol: '005930', qty: 1),
      ]);
      expect(plan.targets.single.symbol, '005930');
      expect(plan.targets.single.instrument, InstrumentKind.stock);
      expect(plan.dropped, isEmpty);
    });

    test(
      '🔴 계절(SEAS-A-IN · SEAS-A-OUT · 결합 id 의 한 조각)은 이월하지 않는다 — 세션이 남아도',
      () {
        final CarryPlan plan = planCarryOver(<ExpiredIntent>[
          _e(logical: 'SEAS-A-IN-2026-11-30'),
          _e(logical: 'SEAS-A-OUT-2026-04-30', sessions: 3),
          _e(logical: 'B-SMA-2026-10-30+SEAS-A-IN-2026-11-30'),
          _e(logical: 'B-SEAS-A-IN-x'),
        ]);
        expect(
          plan.seasonal.map((ExpiredIntent e) => e.logicalDecisionId),
          <String>[
            'SEAS-A-IN-2026-11-30',
            'SEAS-A-OUT-2026-04-30',
            'B-SMA-2026-10-30+SEAS-A-IN-2026-11-30',
          ],
        );
        expect(plan.targets.single.logicalDecisionId, 'B-SEAS-A-IN-x');
        expect(plan.dropped, isEmpty);
      },
    );

    test('논리 id = decision_id 의 `@` 앞 · 꼴이 틀리면 ArgumentError', () {
      expect(logicalIdOf('B-SMA-2026-10-30@2026-11-02'), 'B-SMA-2026-10-30');
      expect(logicalIdOf('A+B@2026-11-02'), 'A+B');
      expect(() => logicalIdOf('B-SMA-2026-10-30'), throwsArgumentError);
      expect(() => logicalIdOf('@2026-11-02'), throwsArgumentError);
    });
  });

  group('계절 분할 진행(seasonalShareToday · R39 T4 · D8 · GV-30 e4)', () {
    test(
      'e4 — 1일 4(2 체결) → 2일 3(0 체결) → 3일 8(시장가 = 목표 − 누적 체결) · 계절은 이월 목록에 없다',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        final String logical = DecisionIds.seasonalAEntry(_d3);
        final List<TradeDate> days = <TradeDate>[_d1, _d2, _d3];
        const List<int> fills = <int>[2, 0];
        final List<SplitDay> shares = <SplitDay>[];
        for (int i = 0; i < days.length; i++) {
          final TradeDate day = days[i];
          final SplitDay s = await seasonalShareToday(
            ledger,
            logicalDecisionId: logical,
            strategyId: 'sleeve_a_kr',
            symbol: '360750',
            target: 10,
            executionDays: days,
            today: day,
          );
          shares.add(s);
          if (i == days.length - 1) break;
          ledger.clock = () => _kst(day, 9, 10);
          final FakeOrderBroker broker = FakeOrderBroker(orderDate: day);
          final ExecutionOutcome o = await executeIntent(
            draftOf(
              symbol: '360750',
              strategyId: 'sleeve_a_kr',
              logical: logical,
              quantity: s.quantity,
              executionDate: day,
            ),
            portfolioOk(),
            ctxOf(ledger, broker),
          );
          expect(o.status, ExecutionStatus.submitted);
          broker.fills[day.yyyyMmDd] = <DailyFillRow>[
            _r(symbol: '360750', qty: s.quantity, date: day, cum: fills[i]),
          ];
          await _dayEnd(ledger, broker, day);
          final CarryPlan plan = planCarryOver(
            await ledger.expiredIntents(day),
          );
          expect(plan.targets, isEmpty);
          expect(plan.seasonal.single.expiredQty, s.quantity - fills[i]);
        }
        expect(shares.map((SplitDay s) => s.quantity), <int>[4, 3, 8]);
        expect(shares.map((SplitDay s) => s.marketOrder), <bool>[
          false,
          false,
          true,
        ]);
        final SplitProgress p = await ledger.splitProgress(
          logical,
          strategyId: 'sleeve_a_kr',
          symbol: '360750',
          before: _d3,
        );
        expect((p.planned, p.filled), (7, 2));
      },
    );

    test(
      '앞날 진행은 그 (논리 id · 전략 · 종목)의 앞 집행일만 · SKIPPED · 1~5단계 거부는 빼고 센다',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        const String logical = 'SEAS-A-IN-2026-11-04';
        Future<void> run(
          OrderIntentDraft d, {
          ExecPolicy policy = ExecPolicy.execute,
        }) async {
          await executeIntent(
            d,
            portfolioOk(),
            ctxOf(
              ledger,
              FakeOrderBroker(orderDate: d.executionDate),
              execPolicy: policy,
            ),
          );
        }

        // 셀 것은 1일 4주(접수) 하나 — 다른 종목 · 다른 전략 · 오늘(2일) · 접두만 같은 id · DRY_RUN(SKIPPED) · 거부는 아니다.
        await run(
          draftOf(
            symbol: '360750',
            strategyId: 'sleeve_a_kr',
            logical: logical,
            quantity: 4,
            executionDate: _d1,
          ),
        );
        await run(
          draftOf(
            symbol: '379800',
            strategyId: 'sleeve_a_kr',
            logical: logical,
            quantity: 9,
            executionDate: _d1,
          ),
        );
        // 멱등키에는 strategy_id 가 없다 — 계좌가 달라야 다른 의도다.
        await run(
          draftOf(
            symbol: '360750',
            account: 'general',
            logical: logical,
            quantity: 9,
            executionDate: _d1,
          ),
        );
        await run(
          draftOf(
            symbol: '360750',
            strategyId: 'sleeve_a_kr',
            logical: logical,
            quantity: 3,
            executionDate: _d2,
          ),
        );
        // 🔴 접두 함정 — 논리 id 가 앞을 같이 쓰는 다른 결정은 세지 않는다(`LIKE` · `@` 없는 접두 비교 금지).
        await run(
          draftOf(
            symbol: '360750',
            strategyId: 'sleeve_a_kr',
            logical: '${logical}X',
            quantity: 9,
            executionDate: _d1,
          ),
        );
        await run(
          draftOf(
            symbol: '360750',
            strategyId: 'sleeve_a_kr',
            logical: logical,
            quantity: 9,
            executionDate: const TradeDate('2026-10-29'),
          ),
          policy: ExecPolicy.dryRun,
        );
        // 1~5단계 거부(미등록 전략은 SAF-406) — 같은 논리 id 지만 전략이 등록되지 않았다.
        ledger.registeredStrategies.remove('sleeve_a_kr');
        await run(
          draftOf(
            symbol: '360750',
            strategyId: 'sleeve_a_kr',
            logical: logical,
            quantity: 2,
            executionDate: const TradeDate('2026-10-30'),
          ),
        );
        expect(
          ledger.records.values.map((FakeIntentRecord r) => r.status),
          <IntentStatus>[
            IntentStatus.submitted,
            IntentStatus.submitted,
            IntentStatus.submitted,
            IntentStatus.submitted,
            IntentStatus.submitted,
            IntentStatus.skipped,
            IntentStatus.rejected,
          ],
        );
        final SplitProgress p = await ledger.splitProgress(
          logical,
          strategyId: 'sleeve_a_kr',
          symbol: '360750',
          before: _d2,
        );
        expect((p.planned, p.filled), (4, 0));
      },
    );

    test('오늘이 분할 집행일이 아니면 ArgumentError · 첫날은 원장 값을 넣지 않는다', () async {
      final FakeOrderLedger ledger = ledgerOf();
      await expectLater(
        seasonalShareToday(
          ledger,
          logicalDecisionId: 'SEAS-A-IN-2026-11-04',
          strategyId: 'sleeve_a_kr',
          symbol: '360750',
          target: 10,
          executionDays: const <TradeDate>[_d1, _d3],
          today: _d2,
        ),
        throwsArgumentError,
      );
      // 앞 집행일에 같은 논리 id 기록이 있어도 첫날 몫은 목표만으로 정한다.
      await executeIntent(
        draftOf(
          symbol: '360750',
          strategyId: 'sleeve_a_kr',
          logical: 'SEAS-A-IN-2026-11-04',
          quantity: 2,
          executionDate: const TradeDate('2026-10-30'),
        ),
        portfolioOk(),
        ctxOf(
          ledger,
          FakeOrderBroker(orderDate: const TradeDate('2026-10-30')),
        ),
      );
      final SplitDay first = await seasonalShareToday(
        ledger,
        logicalDecisionId: 'SEAS-A-IN-2026-11-04',
        strategyId: 'sleeve_a_kr',
        symbol: '360750',
        target: 10,
        executionDays: const <TradeDate>[_d1, _d2, _d3],
        today: _d1,
      );
      expect((first.quantity, first.marketOrder), (4, false));
    });
  });

  group('UNKNOWN 맞추기(resolveUnknown · R39 T5 · T6)', () {
    test('정확히 1행 = 연결', () {
      final UnknownResolution r = _res(_u(), <DailyFillRow>[_r()]);
      expect(r, isA<UnknownLinked>());
      expect((r as UnknownLinked).row.brokerOrderNo, '2026-11-02:0000000001');
    });

    test('2행 이상 = UNKNOWN 유지 + P0(ambiguous)', () {
      final UnknownResolution r = _res(_u(), <DailyFillRow>[
        _r(),
        _r(odno: '0000000002', time: '091006'),
      ]);
      expect((r as UnknownAmbiguous).candidates, 2);
    });

    test('🔴 이미 다른 의도에 붙은 주문번호는 후보가 아니다', () {
      final UnknownResolution r = _res(
        _u(),
        <DailyFillRow>[_r(), _r(odno: '0000000002')],
        linked: <String>{'2026-11-02:0000000001'},
      );
      expect((r as UnknownLinked).row.odno, '0000000002');
    });

    test('종목 · 방향 · 수량 · 단가 · 주문일이 다르거나 취소 행이면 맞지 않는다', () {
      for (final DailyFillRow row in <DailyFillRow>[
        _r(symbol: '411060'),
        _r(side: OrderSide.sell),
        _r(qty: 4),
        _r(price: '174185'),
        _r(date: _d2),
        _r(cancelRow: true),
      ]) {
        expect(
          _res(_u(), <DailyFillRow>[row]),
          isA<UnknownMissed>(),
          reason: '$row',
        );
      }
    });

    test('시각 — 주문 시각 ≥ 예약 − 60초(KST)만 · 시각이 없거나 꼴이 틀린 행은 맞추지 않는다', () {
      expect(
        _res(_u(), <DailyFillRow>[_r(time: '090900')]),
        isA<UnknownLinked>(),
      );
      for (final String? t in <String?>['090859', null, '9100', '0909001']) {
        expect(
          _res(_u(), <DailyFillRow>[_r(time: t)]),
          isA<UnknownMissed>(),
          reason: '$t',
        );
      }
      expect(kUnknownTimeMargin, const Duration(seconds: 60));
    });

    test('예약이 집행일 앞날이면 하한이 없다 · 뒷날이면 맞추지 않는다(fail-closed)', () {
      // KST 11-02 00:00:30 − 60초 = 11-01 23:59:30 → 하한 없음.
      expect(
        _res(_u(created: _kst(_d1, 0, 0, 30)), <DailyFillRow>[
          _r(time: '000010'),
        ]),
        isA<UnknownLinked>(),
      );
      expect(
        _res(_u(created: _kst(_d1, -4, 0)), <DailyFillRow>[_r(time: '000000')]),
        isA<UnknownLinked>(),
      );
      expect(
        _res(_u(created: _kst(_d2, 9, 0)), <DailyFillRow>[_r(time: '235959')]),
        isA<UnknownMissed>(),
      );
    });

    test('시장가 = 행 단가 0 · 없음만 · 지정가는 같은 값만', () {
      for (final String? p in <String?>['0', null]) {
        expect(
          _res(_u(limit: null), <DailyFillRow>[_r(price: p)]),
          isA<UnknownLinked>(),
          reason: '$p',
        );
      }
      expect(_res(_u(limit: null), <DailyFillRow>[_r()]), isA<UnknownMissed>());
      expect(
        _res(_u(), <DailyFillRow>[_r(price: '174180.0')]),
        isA<UnknownLinked>(),
      );
      expect(_res(_u(), <DailyFillRow>[_r(price: null)]), isA<UnknownMissed>());
      expect(_res(_u(), <DailyFillRow>[_r(price: '0')]), isA<UnknownMissed>());
    });

    test('0행 — 첫 놓침 = 표시 · 같은 KST 날 3분 뒤 = NOT_FOUND · 3분 전 = 그대로', () {
      final DateTime t0 = _kst(_d1, 9, 20);
      final UnknownResolution first = _res(
        _u(),
        const <DailyFillRow>[],
        now: t0,
      );
      expect((first as UnknownMissed).first, isTrue);
      expect(first.at, t0);
      final String marked = withUnknownMiss(_u().errorMessage, t0);
      final UnknownResolution early = _res(
        _u(msg: marked),
        const <DailyFillRow>[],
        now: t0.add(const Duration(minutes: 2, seconds: 59)),
      );
      expect((early as UnknownMissed).first, isFalse);
      expect(early.at, t0);
      expect(
        _res(
          _u(msg: marked),
          const <DailyFillRow>[],
          now: t0.add(kUnknownMissGap),
        ),
        isA<UnknownNotFound>(),
      );
      expect(kUnknownMissGap, const Duration(minutes: 3));
    });

    test('다른 KST 날의 놓침은 세지 않는다 — UTC 날이 같아도 · 4분이 지났어도', () {
      // 놓침 KST 11-02 23:58(UTC 14:58) · 지금 KST 11-03 00:02(UTC 15:02) — UTC 날은 같다.
      final String marked = withUnknownMiss(null, _kst(_d1, 23, 58));
      final UnknownResolution r = _res(
        _u(msg: marked),
        const <DailyFillRow>[],
        now: _kst(_d2, 0, 2),
      );
      expect((r as UnknownMissed).first, isTrue);
      expect(r.at, _kst(_d2, 0, 2));
    });

    test('«놓침» 표시 꼴 — 앞선 표시는 갈아 끼우고 원래 사유는 뒤에 남는다', () {
      final DateTime t1 = DateTime.utc(2026, 11, 2, 0, 20);
      final DateTime t2 = DateTime.utc(2026, 11, 2, 0, 25);
      expect(
        withUnknownMiss(null, t1),
        'UNKNOWN_MISS@2026-11-02T00:20:00.000Z',
      );
      final String once = withUnknownMiss('시간 초과', t1);
      expect(once, 'UNKNOWN_MISS@2026-11-02T00:20:00.000Z · 시간 초과');
      expect(
        withUnknownMiss(once, t2),
        'UNKNOWN_MISS@2026-11-02T00:25:00.000Z · 시간 초과',
      );
      expect(unknownMissAt(once), t1);
      expect(unknownMissAt(withUnknownMiss(null, t1)), t1);
      expect(unknownMissAt('시간 초과'), isNull);
      expect(unknownMissAt('UNKNOWN_MISS@없음 · 시간 초과'), isNull);
      expect(unknownMissAt(null), isNull);
    });
  });

  group('해소 실행(resolveUnknownOrders · R39 T8 · T9)', () {
    Future<(FakeOrderLedger, FakeOrderBroker)> unknownOne() async {
      final FakeOrderLedger ledger = ledgerOf()..clock = () => _kst(_d1, 9, 10);
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[const FakeUnknown()],
      );
      await expectLater(
        executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker)),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      expect(ledger.records.values.single.status, IntentStatus.unknown);
      return (ledger, broker);
    }

    Future<UnknownResolutionReport> resolve(
      FakeOrderLedger ledger,
      Map<String, OrderBroker> brokers,
      DateTime now,
    ) => resolveUnknownOrders(ledger: ledger, brokers: brokers, nowUtc: now);

    test(
      '1행 = 연결(SUBMITTED · 주문번호) → 2.5단계가 풀린다 → 다음 체결 동기화가 체결을 쓴다',
      () async {
        final (FakeOrderLedger ledger, FakeOrderBroker broker) =
            await unknownOne();
        broker.fills['2026-11-02'] = <DailyFillRow>[_r(cum: 5)];
        UnknownResolutionReport report = await resolve(
          ledger,
          <String, OrderBroker>{'pension': broker},
          _kst(_d1, 9, 20),
        );
        expect(report.resolutions.single, isA<UnknownLinked>());
        final FakeIntentRecord rec = ledger.records.values.single;
        expect(rec.status, IntentStatus.submitted);
        expect(rec.brokerOrderNo, '2026-11-02:0000000001');
        expect(
          await ledger.hasUnresolvedUnknown(
            rec.row.market,
            rec.row.symbol,
            rec.row.strategyId,
          ),
          isFalse,
        );
        final FillSyncReport fills = await runFillSync(
          ledger: ledger,
          brokers: <String, OrderBroker>{'pension': broker},
          tradeDate: _d1,
          nowUtc: _kst(_d1, 10, 0),
          dayEnd: false,
          costs: _rates,
        );
        expect(fills.applied.single.status, IntentStatus.filled);
        expect(ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 5);

        report = await resolve(ledger, <String, OrderBroker>{
          'pension': broker,
        }, _kst(_d1, 10, 1));
        expect(report.resolutions, isEmpty);
      },
    );

    test('0행 — 첫 놓침 표시 → 2분 뒤 그대로 → 3분 뒤 REJECTED(UNKNOWN_NOT_FOUND · orders_today 에 남는다)', () async {
      final (FakeOrderLedger ledger, FakeOrderBroker broker) =
          await unknownOne();
      final Map<String, OrderBroker> brokers = <String, OrderBroker>{
        'pension': broker,
      };
      final FakeIntentRecord rec = ledger.records.values.single;
      final String original = rec.errorMessage!;
      final DateTime t0 = _kst(_d1, 9, 20);

      await resolve(ledger, brokers, t0);
      expect(rec.status, IntentStatus.unknown);
      expect(rec.errorMessage, withUnknownMiss(original, t0));

      final UnknownResolutionReport early = await resolve(
        ledger,
        brokers,
        t0.add(const Duration(minutes: 2)),
      );
      expect((early.resolutions.single as UnknownMissed).first, isFalse);
      expect(rec.errorMessage, withUnknownMiss(original, t0));
      expect(
        ledger.calls.where((String c) => c == 'noteUnknownMiss'),
        hasLength(1),
      );

      final UnknownResolutionReport late = await resolve(
        ledger,
        brokers,
        t0.add(const Duration(minutes: 3)),
      );
      expect(late.resolutions.single, isA<UnknownNotFound>());
      expect(rec.status, IntentStatus.rejected);
      expect(rec.errorMessage, startsWith(kUnknownNotFoundPrefix));
      expect(await ledger.ordersToday(_d1), 1);
      expect(
        await ledger.hasUnresolvedUnknown(
          'KR',
          '133690',
          P0sStrategyIds.sleeveB,
        ),
        isFalse,
      );
      expect(broker.submitCount, 1);
    });

    test('2행 이상 = 그대로 + ambiguous(P0) · 원장에 쓰지 않는다', () async {
      final (FakeOrderLedger ledger, FakeOrderBroker broker) =
          await unknownOne();
      broker.fills['2026-11-02'] = <DailyFillRow>[_r(), _r(odno: '0000000002')];
      final UnknownResolutionReport report = await resolve(
        ledger,
        <String, OrderBroker>{'pension': broker},
        _kst(_d1, 9, 20),
      );
      expect(report.ambiguous.single.candidates, 2);
      final FakeIntentRecord rec = ledger.records.values.single;
      expect(rec.status, IntentStatus.unknown);
      expect(rec.errorMessage, isNot(startsWith(kUnknownMissPrefix)));
      expect(
        ledger.calls.where(
          (String c) => const <String>{
            'linkUnknown',
            'rejectUnknown',
            'noteUnknownMiss',
          }.contains(c),
        ),
        isEmpty,
      );
    });

    test('조회 실패 · 브로커 없음 = 그대로 두고 unavailable 로 보고', () async {
      final (FakeOrderLedger ledger, FakeOrderBroker broker) =
          await unknownOne();
      broker.fillsError = StateError('조회 실패');
      for (final Map<String, OrderBroker> brokers in <Map<String, OrderBroker>>[
        <String, OrderBroker>{'pension': broker},
        <String, OrderBroker>{},
      ]) {
        final UnknownResolutionReport report = await resolve(
          ledger,
          brokers,
          _kst(_d1, 9, 20),
        );
        expect(report.unavailable, <(String, TradeDate)>[('pension', _d1)]);
        expect(report.resolutions, isEmpty);
      }
      final FakeIntentRecord rec = ledger.records.values.single;
      expect(rec.status, IntentStatus.unknown);
      expect(rec.errorMessage, isNot(startsWith(kUnknownMissPrefix)));
    });

    test('🔴 같은 조회의 한 행을 두 의도가 가져가지 않는다 — 앞 의도가 연결 · 뒤 의도는 놓침', () async {
      final FakeOrderLedger ledger = ledgerOf()..clock = () => _kst(_d1, 9, 10);
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[const FakeUnknown(), const FakeUnknown()],
      );
      for (final OrderIntentDraft d in <OrderIntentDraft>[
        draftOf(),
        draftOf(
          strategyId: P0sStrategyIds.sleeveC,
          logical: 'C-REB-2026-10-30',
        ),
      ]) {
        await expectLater(
          executeIntent(d, portfolioOk(), ctxOf(ledger, broker)),
          throwsA(isA<OrderOutcomeUnknown>()),
        );
      }
      broker.fills['2026-11-02'] = <DailyFillRow>[_r()];
      final UnknownResolutionReport report = await resolve(
        ledger,
        <String, OrderBroker>{'pension': broker},
        _kst(_d1, 9, 20),
      );
      expect(
        report.resolutions.map((UnknownResolution r) => r.runtimeType),
        <Type>[UnknownLinked, UnknownMissed],
      );
      expect(broker.fillReads, 1);
      expect(
        ledger.records.values.map((FakeIntentRecord r) => r.status),
        <IntentStatus>[IntentStatus.submitted, IntentStatus.unknown],
      );
    });

    test('주문번호가 있는 UNKNOWN(일 마감 조회 실패)은 해소 대상이 아니다', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      await executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker));
      broker.fillsError = StateError('조회 실패');
      await _dayEnd(ledger, broker, _d1);
      expect(ledger.records.values.single.status, IntentStatus.unknown);
      expect(await ledger.unknownIntents(), isEmpty);
      final int reads = broker.fillReads;
      final UnknownResolutionReport report = await resolve(
        ledger,
        <String, OrderBroker>{'pension': broker},
        _kst(_d1, 15, 50),
      );
      expect(report.resolutions, isEmpty);
      expect(report.unavailable, isEmpty);
      expect(broker.fillReads, reads);
    });
  });

  group('G-FB — 잔존 미체결 + 다음 날 배치 → 총 발주 ≤ 목표(R39 T10 · D6)', () {
    test('목표 10 — 1일 6 체결 · 2일 이월 4(2 체결) · 3일 이월 2(1 체결) · 4일 버림 · 같은 날 재실행 = PREVENTED', () async {
      final FakeOrderLedger ledger = ledgerOf();
      const String logical = 'B-SMA-2026-10-30';
      final DraftQuote quote = DraftQuote(
        previousClose: _d('173315'),
        tickSize: _d('5'),
        upperLimit: _d('225305'),
        lowerLimit: _d('121325'),
      );
      final DraftConfig cfg = DraftConfig(
        limitOffsetPct: 0.005,
        buyCostRate: 0.00015,
        accountByStrategy: <String, String>{P0sStrategyIds.sleeveB: 'pension'},
      );
      Future<BatchOutcome> batch(
        List<OrderIntentDraft> drafts,
        FakeOrderBroker broker,
      ) => runOrderBatch(
        drafts,
        brokers: <String, OrderBroker>{'pension': broker},
        ledger: ledger,
        lease: FakeLeaseGate(),
        limitStateFor: (OrderIntentDraft d) async => portfolioOk(),
        limitConfig: kLimitConfig,
        buyCostRate: 0,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg-test',
      );

      const List<TradeDate> days = <TradeDate>[_d1, _d2, _d3];
      const List<int> fills = <int>[6, 2, 1];
      List<OrderIntentDraft> drafts = <OrderIntentDraft>[
        draftOf(quantity: 10, logical: logical),
      ];
      int filledTotal = 0;
      final List<int> ordered = <int>[];
      for (int i = 0; i < days.length; i++) {
        final TradeDate day = days[i];
        ledger.clock = () => _kst(day, 9, 10);
        final FakeOrderBroker broker = FakeOrderBroker(orderDate: day);
        final int qty = drafts.single.quantity;
        ordered.add(qty);
        expect(
          filledTotal + qty,
          lessThanOrEqualTo(10),
          reason: '$day 체결 합 + 오늘 발주',
        );
        expect(drafts.single.decisionId, '$logical@${day.yyyyMmDd}');
        BatchOutcome o = await batch(drafts, broker);
        expect(o.outcomes.single.status, ExecutionStatus.submitted);
        o = await batch(drafts, broker);
        expect(o.outcomes.single.status, ExecutionStatus.prevented);
        expect(broker.submitCount, 1);

        broker.fills[day.yyyyMmDd] = <DailyFillRow>[
          _r(qty: qty, date: day, cum: fills[i]),
        ];
        final FillSyncReport r = await _dayEnd(ledger, broker, day);
        expect(r.expired.single.expiredQty, qty - fills[i]);
        filledTotal += fills[i];

        final CarryPlan carry = planCarryOver(
          await ledger.expiredIntents(day),
          instruments: const <String, InstrumentKind>{
            '133690': InstrumentKind.etf,
          },
        );
        if (i == days.length - 1) {
          expect(carry.targets, isEmpty);
          expect(carry.dropped.single.expiredQty, 1);
          expect(carry.dropped.single.sessionsUsed, kCarrySessionLimit);
          break;
        }
        expect(carry.targets.single.logicalDecisionId, logical);
        expect(
          (carry.targets.single.sizing as ShareSizing).shares,
          qty - fills[i],
        );
        final DraftResult next = draftOrders(
          carry.targets,
          executionDate: days[i + 1],
          quotes: <String, DraftQuote>{'133690': quote},
          holdings: const <(String, String), int>{},
          config: cfg,
        );
        expect(next.issues, isEmpty);
        drafts = next.drafts;
      }
      expect(ordered, <int>[10, 4, 2]);
      expect(filledTotal, 9);
      expect(filledTotal, lessThanOrEqualTo(10));
      expect(ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 9);
    });
  });
}
