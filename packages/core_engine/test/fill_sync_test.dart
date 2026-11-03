// 체결 동기화 · 일 마감 · 다음 날 가드(설계 13 §8 R38 Z3 · Z5 · Z7 · Z8 · 04 §3-1 ③ v2.38 · R31 · R32 O3).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'order_path_fixture.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _day = TradeDate('2026-11-02');

/// 15:41 KST(일 마감 확인 가능) · 10:00 KST(장중).
final DateTime _afterClose = DateTime.utc(2026, 11, 2, 6, 41);
final DateTime _intraday = DateTime.utc(2026, 11, 2, 1);

const FillCostRates _rates = FillCostRates(
  commissionRate: 0.00015,
  sellTaxRate: 0,
);

OpenIntent _open({
  String no = '2026-11-02:0000000001',
  int qty = 5,
  OrderSide side = OrderSide.buy,
  IntentStatus status = IntentStatus.submitted,
}) => OpenIntent(
  intentId: 'oi-1',
  brokerOrderNo: no,
  tradeDate: _day,
  market: 'KR',
  account: 'pension',
  strategyId: P0sStrategyIds.sleeveB,
  symbol: '133690',
  side: side,
  quantity: qty,
  decisionId: 'B-SMA-2026-10-30@2026-11-02',
  status: status,
);

DailyFillRow _row({
  String odno = '0000000001',
  int qty = 5,
  int cum = 0,
  String amount = '0',
  int remaining = 5,
  int cancelled = 0,
  bool cancelRow = false,
  TradeDate date = _day,
  OrderSide side = OrderSide.buy,
}) => DailyFillRow(
  orderDate: date,
  odno: odno,
  isCancelRow: cancelRow,
  symbol: '133690',
  side: side,
  orderQty: qty,
  cumFilledQty: cum,
  cumFilledAmount: _d(amount),
  remainingQty: remaining,
  cancelConfirmedQty: cancelled,
);

FillVerdict _one(
  DailyFillRow? row, {
  bool dayEnd = true,
  OpenIntent? intent,
  Map<String, RecordedFill> recorded = const <String, RecordedFill>{},
}) => reconcileFills(
  intents: <OpenIntent>[intent ?? _open()],
  rows: <DailyFillRow>[?row],
  recorded: recorded,
  dayEnd: dayEnd,
).single;

void main() {
  group('판정(reconcileFills · R38 Z3)', () {
    test('전량 체결 = FILLED · 체결 행 1(R31 키)', () {
      final FillVerdict v = _one(_row(cum: 5, amount: '870900', remaining: 0));
      expect(v.status, IntentStatus.filled);
      expect(v.deltas.single.executionId, '2026-11-02:0000000001#5');
      expect(v.deltas.single.price, _d('174180'));
      expect(v.changed, isTrue);
    });

    test('일 마감 · 부분 체결 + 잔여 = EXPIRED(실효 = 잔여) · 체결분은 행', () {
      final FillVerdict v = _one(_row(cum: 3, amount: '522540', remaining: 2));
      expect(v.status, IntentStatus.expired);
      expect(v.expiredQty, 2);
      expect(v.message, 'EXPIRED: 마감 실효 2주');
      expect(v.deltas.single.quantity, 3);
    });

    test('장중 · 부분 체결 = PARTIAL · 체결 0 = 그대로(쓸 것 없음) · 실효를 쓰지 않는다', () {
      expect(
        _one(
          _row(cum: 3, amount: '522540', remaining: 2),
          dayEnd: false,
        ).status,
        IntentStatus.partial,
      );
      final FillVerdict none = _one(_row(), dayEnd: false);
      expect(none.status, IntentStatus.submitted);
      expect(none.changed, isFalse);
      expect(none.expiredQty, 0);
    });

    test('잔여 0 · 취소 확인 > 0 = CANCELLED(장중 · 마감 모두)', () {
      for (final bool dayEnd in <bool>[true, false]) {
        final FillVerdict v = _one(
          _row(cum: 1, amount: '174180', remaining: 0, cancelled: 4),
          dayEnd: dayEnd,
        );
        expect(v.status, IntentStatus.cancelled);
        expect(v.message, 'CANCELLED: 취소 확인 4주');
      }
    });

    test('일 마감 · 잔여 0 · 취소 0 인데 덜 체결 = EXPIRED(주문 − 누적 − 취소)', () {
      final FillVerdict v = _one(_row(cum: 2, amount: '348360', remaining: 0));
      expect(v.status, IntentStatus.expired);
      expect(v.expiredQty, 3);
    });

    test(
      '🔴 원주문 행이 없다 — 일 마감 = UNKNOWN(ORDER_MISSING) · 장중 = 판정 없음(조회 지연)',
      () {
        final FillVerdict v = _one(null);
        expect(v.status, IntentStatus.unknown);
        expect(v.message, startsWith('ORDER_MISSING'));
        expect(
          reconcileFills(
            intents: <OpenIntent>[_open()],
            rows: const <DailyFillRow>[],
            recorded: const <String, RecordedFill>{},
            dayEnd: false,
          ),
          isEmpty,
        );
      },
    );

    test('같은 누적을 다시 보면 체결 행 0(멱등) · 취소 행은 판정에 쓰지 않는다', () {
      final FillVerdict v = _one(
        _row(cum: 3, amount: '522540', remaining: 2),
        dayEnd: false,
        intent: _open(status: IntentStatus.partial),
        recorded: <String, RecordedFill>{
          '2026-11-02:0000000001': RecordedFill(3, _d('522540')),
        },
      );
      expect(v.deltas, isEmpty);
      expect(v.changed, isFalse);
      final List<FillVerdict> withCancel = reconcileFills(
        intents: <OpenIntent>[_open()],
        rows: <DailyFillRow>[
          _row(cum: 5, amount: '870900', remaining: 0),
          _row(odno: '0000000001', cancelRow: true, remaining: 0),
        ],
        recorded: const <String, RecordedFill>{},
        dayEnd: true,
      );
      expect(withCancel.single.status, IntentStatus.filled);
    });

    test('누적이 주문 수량을 넘거나 원주문 행이 둘이면 StateError', () {
      expect(
        () => _one(_row(cum: 6, amount: '1045080', remaining: 0)),
        throwsStateError,
      );
      expect(
        () => reconcileFills(
          intents: <OpenIntent>[_open()],
          rows: <DailyFillRow>[_row(), _row()],
          recorded: const <String, RecordedFill>{},
          dayEnd: true,
        ),
        throwsStateError,
      );
    });
  });

  group('비용 · 저장 꼴(R38 Z4 · Z5 · Z6)', () {
    test('추정 비용 = 체결 금액 × 수수료율 · 매도면 × 매도세율', () {
      final FillDelta buy = fillDeltas(<DailyFillRow>[
        _row(cum: 5, amount: '1000000', remaining: 0),
      ], const <String, RecordedFill>{}).single;
      final ({Decimal commission, Decimal tax}) b = estimateFillCost(
        buy,
        _rates,
      );
      expect(b.commission, _d('150'));
      expect(b.tax, Decimal.zero);
      // 매도세율이 있어도 매수에는 세금이 없다.
      expect(
        estimateFillCost(
          buy,
          const FillCostRates(commissionRate: 0.00015, sellTaxRate: 0.002),
        ).tax,
        Decimal.zero,
      );
      final FillDelta sell = fillDeltas(<DailyFillRow>[
        _row(cum: 5, amount: '1000000', remaining: 0, side: OrderSide.sell),
      ], const <String, RecordedFill>{}).single;
      final ({Decimal commission, Decimal tax}) s = estimateFillCost(
        sell,
        const FillCostRates(commissionRate: 0.00015, sellTaxRate: 0.002),
      );
      expect(s.tax, _d('2000'));
    });

    test('누적 기록 꼴 왕복 · 꼴이 틀리면 FormatException · 평균 단가', () {
      final DailyFillRow r = _row(cum: 3, amount: '522541', remaining: 2);
      final RecordedFill back = parseRecordedFillJson(
        recordedFillJson(r, _afterClose),
      );
      expect(back.quantity, 3);
      expect(back.amount, _d('522541'));
      expect(
        recordedFillJson(r, _afterClose),
        contains('"seen_at":"2026-11-02T06:41:00.000Z"'),
      );
      expect(
        () => parseRecordedFillJson('{"tot_ccld_qty":"3"}'),
        throwsFormatException,
      );
      expect(averageFillPrice(_row()), isNull);
      expect(
        averageFillPrice(_row(cum: 2, amount: '348361', remaining: 3)),
        closeTo(174180.5, 1e-9),
      );
    });

    test('매수 뒤 평단 = (q × a + Δ × p) ÷ 새 수량 · 매도는 거절', () {
      final FillDelta buy = fillDeltas(<DailyFillRow>[
        _row(cum: 10, amount: '1100', remaining: 0, qty: 10),
      ], const <String, RecordedFill>{}).single;
      expect(averagePriceAfterBuy(heldQty: 10, heldAvg: 100, buy: buy), 105);
      expect(averagePriceAfterBuy(heldQty: 0, heldAvg: 0, buy: buy), 110);
      final FillDelta sell = fillDeltas(<DailyFillRow>[
        _row(cum: 1, amount: '110', remaining: 0, qty: 1, side: OrderSide.sell),
      ], const <String, RecordedFill>{}).single;
      expect(
        () => averagePriceAfterBuy(heldQty: 1, heldAvg: 1, buy: sell),
        throwsArgumentError,
      );
    });
  });

  group('실행(runFillSync · R38 Z7)', () {
    Future<(FakeOrderLedger, FakeOrderBroker)> submitted() async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(o.brokerOrderNo, '2026-11-02:0000000001');
      return (ledger, broker);
    }

    Future<FillSyncReport> sync(
      FakeOrderLedger ledger,
      Map<String, OrderBroker> brokers, {
      required bool dayEnd,
      DateTime? now,
    }) => runFillSync(
      ledger: ledger,
      brokers: brokers,
      tradeDate: _day,
      nowUtc: now ?? (dayEnd ? _afterClose : _intraday),
      dayEnd: dayEnd,
      costs: _rates,
    );

    test(
      '주문 → 장중 부분 체결(PARTIAL) → 마감(EXPIRED · 실효 1) — 체결 행 · 포지션 · 누적',
      () async {
        final (FakeOrderLedger ledger, FakeOrderBroker broker) =
            await submitted();
        broker.fills['2026-11-02'] = <DailyFillRow>[
          _row(cum: 3, amount: '522540', remaining: 2),
        ];
        FillSyncReport r = await sync(ledger, <String, OrderBroker>{
          'pension': broker,
        }, dayEnd: false);
        expect(r.applied.single.status, IntentStatus.partial);
        expect(r.expired, isEmpty);
        expect(ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 3);

        broker.fills['2026-11-02'] = <DailyFillRow>[
          _row(cum: 4, amount: '696720', remaining: 1),
        ];
        r = await sync(ledger, <String, OrderBroker>{
          'pension': broker,
        }, dayEnd: true);
        expect(r.applied.single.status, IntentStatus.expired);
        expect(r.expired.single.expiredQty, 1);
        expect(
          ledger.executions.map((FillDelta d) => (d.executionId, d.quantity)),
          <(String, int)>[
            ('2026-11-02:0000000001#3', 3),
            ('2026-11-02:0000000001#4', 1),
          ],
        );
        expect(ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 4);
        expect(ledger.records.values.single.errorMessage, 'EXPIRED: 마감 실효 1주');

        // 다시 돌려도 열린 의도가 없다(멱등).
        r = await sync(ledger, <String, OrderBroker>{
          'pension': broker,
        }, dayEnd: true);
        expect(r.applied, isEmpty);
        expect(ledger.executions, hasLength(2));
      },
    );

    test('🔴 일 마감은 15:40 KST 뒤에만 — 15:39 는 StateError', () async {
      final (FakeOrderLedger ledger, FakeOrderBroker broker) =
          await submitted();
      await expectLater(
        sync(
          ledger,
          <String, OrderBroker>{'pension': broker},
          dayEnd: true,
          now: DateTime.utc(2026, 11, 2, 6, 39),
        ),
        throwsStateError,
      );
      // 다음 날 아침의 일 마감(지난 날 확인)은 된다.
      broker.fills['2026-11-02'] = <DailyFillRow>[_row(remaining: 5)];
      final FillSyncReport r = await sync(
        ledger,
        <String, OrderBroker>{'pension': broker},
        dayEnd: true,
        now: DateTime.utc(2026, 11, 2, 23, 30),
      );
      expect(r.expired.single.expiredQty, 5);
    });

    test(
      '🔴 일 마감 조회 실패 · 브로커 없음 = 열린 의도 UNKNOWN(이월하지 않는다) · 장중 실패 = 그대로',
      () async {
        (FakeOrderLedger, FakeOrderBroker) s = await submitted();
        s.$2.fillsError = StateError('조회 실패');
        FillSyncReport r = await sync(s.$1, <String, OrderBroker>{
          'pension': s.$2,
        }, dayEnd: false);
        expect(r.unavailableAccounts, <String>['pension']);
        expect(s.$1.records.values.single.status, IntentStatus.submitted);
        r = await sync(s.$1, <String, OrderBroker>{
          'pension': s.$2,
        }, dayEnd: true);
        expect(r.unresolved.single.$2, startsWith('DAY_END_UNAVAILABLE'));
        expect(s.$1.records.values.single.status, IntentStatus.unknown);
        expect(r.expired, isEmpty);

        s = await submitted();
        r = await sync(s.$1, <String, OrderBroker>{}, dayEnd: true);
        expect(s.$1.records.values.single.status, IntentStatus.unknown);
        expect(r.unresolved.single.$2, contains('브로커가 없다'));
      },
    );

    test('일 마감에 원주문 행이 없으면 UNKNOWN(ORDER_MISSING)', () async {
      final (FakeOrderLedger ledger, FakeOrderBroker broker) =
          await submitted();
      final FillSyncReport r = await sync(ledger, <String, OrderBroker>{
        'pension': broker,
      }, dayEnd: true);
      expect(r.unresolved.single.$2, startsWith('ORDER_MISSING'));
      expect(ledger.records.values.single.status, IntentStatus.unknown);
    });

    test('매도가 보유를 넘으면 StateError(원장이 틀렸다 — 쓰지 않는다)', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      await executeIntent(
        draftOf(side: OrderSide.sell, quantity: 2),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      broker.fills['2026-11-02'] = <DailyFillRow>[
        _row(
          cum: 2,
          amount: '344900',
          remaining: 0,
          qty: 2,
          side: OrderSide.sell,
        ),
      ];
      await expectLater(
        sync(ledger, <String, OrderBroker>{'pension': broker}, dayEnd: false),
        throwsStateError,
      );
      expect(ledger.executions, isEmpty);
      expect(ledger.records.values.single.status, IntentStatus.submitted);
    });
  });

  group('다음 날 가드(R38 Z8 · 04 §3-1 ③ ⑤)', () {
    test('오늘 조회에 지난 날 원주문 행 = 그 계좌 배치 보류 · 취소 행 · 오늘 행은 아니다', () async {
      expect(
        staleOrderRows(<DailyFillRow>[
          _row(),
          _row(odno: '9', cancelRow: true, date: const TradeDate('2026-10-30')),
        ], _day),
        isEmpty,
      );
      final FakeOrderBroker broker = FakeOrderBroker(
        fills: <String, List<DailyFillRow>>{
          '2026-11-02': <DailyFillRow>[
            _row(date: const TradeDate('2026-10-30')),
          ],
        },
      );
      final FakeOrderLedger ledger = ledgerOf();
      final BatchOutcome o = await runOrderBatch(
        <OrderIntentDraft>[
          draftOf(),
          draftOf(side: OrderSide.sell, logical: 'S-1'),
        ],
        brokers: <String, OrderBroker>{'pension': broker},
        ledger: ledger,
        limitStateFor: (OrderIntentDraft d) async => portfolioOk(),
        limitConfig: kLimitConfig,
        buyCostRate: 0,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg-test',
      );
      expect(
        o.held.map(((OrderIntentDraft, String) h) => h.$2).toSet(),
        <String>{'STALE_ORDERS'},
      );
      expect(o.held, hasLength(2));
      expect(broker.submitCount, 0);
      expect(ledger.records, isEmpty);
    });

    test('가드 조회가 실패해도 보류(STALE_GUARD_UNAVAILABLE · fail-closed)', () async {
      final FakeOrderBroker broker = FakeOrderBroker(
        fillsError: StateError('조회 실패'),
      );
      final BatchOutcome o = await runOrderBatch(
        <OrderIntentDraft>[draftOf()],
        brokers: <String, OrderBroker>{'pension': broker},
        ledger: ledgerOf(),
        limitStateFor: (OrderIntentDraft d) async => portfolioOk(),
        limitConfig: kLimitConfig,
        buyCostRate: 0,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg-test',
      );
      expect(o.held.single.$2, 'STALE_GUARD_UNAVAILABLE');
      expect(broker.submitCount, 0);
      expect(broker.fillReads, 1);
    });
  });
}
