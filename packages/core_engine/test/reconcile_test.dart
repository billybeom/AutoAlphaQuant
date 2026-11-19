// 일일 대사 · 해제(04 §3-5 · v2.33 X5 · 06 M1-10 · 설계 13 §8 R40 A3~A10).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _day = TradeDate('2026-11-02');
final DateTime _t0 = DateTime.utc(2026, 11, 2, 6, 45); // 15:45 KST

const FillCostRates _rates = FillCostRates(
  commissionRate: 0.00015,
  sellTaxRate: 0,
);

DailyFillRow _row({
  String odno = '0000000001',
  int qty = 5,
  int cum = 5,
  bool cancelRow = false,
  String symbol = '133690',
}) => DailyFillRow(
  orderDate: _day,
  odno: odno,
  isCancelRow: cancelRow,
  symbol: symbol,
  side: OrderSide.buy,
  orderQty: qty,
  cumFilledQty: cum,
  cumFilledAmount: Decimal.fromInt(174180 * cum),
  remainingQty: qty - cum,
);

LedgerOrderFill _fill(String odno, int qty, {String account = 'pension'}) =>
    LedgerOrderFill(
      brokerOrderNo: '2026-11-02:$odno',
      account: account,
      symbol: '133690',
      filledQty: qty,
    );

List<ReconDiff> _acct({
  Map<String, int> broker = const <String, int>{},
  List<LedgerHolding> holdings = const <LedgerHolding>[],
  List<DailyFillRow> rows = const <DailyFillRow>[],
  List<LedgerOrderFill> fills = const <LedgerOrderFill>[],
}) => reconcileAccount(
  account: 'pension',
  balance: BrokerBalance(holdings: broker, cashKrw: null),
  rows: rows,
  holdings: holdings,
  fills: fills,
);

void main() {
  group('계좌 대사(reconcileAccount · R40 A3 · A4)', () {
    test('일치 = 빈 목록 — 두 전략의 합이 브로커 보유와 같다', () {
      expect(
        _acct(
          broker: const <String, int>{'133690': 5},
          holdings: const <LedgerHolding>[
            LedgerHolding(P0sStrategyIds.sleeveB, '133690', 3),
            LedgerHolding(P0sStrategyIds.sleeveC, '133690', 2),
          ],
          rows: <DailyFillRow>[_row()],
          fills: <LedgerOrderFill>[_fill('0000000001', 5)],
        ),
        isEmpty,
      );
    });

    test('수량 축 — 원장만 · 브로커만 · 값 다름 = QTY(종목 순 · 0 오차)', () {
      final List<ReconDiff> d = _acct(
        broker: const <String, int>{'133690': 3, '069500': 4},
        holdings: const <LedgerHolding>[
          LedgerHolding(P0sStrategyIds.sleeveB, '133690', 5),
          LedgerHolding(P0sStrategyIds.sleeveB, '411060', 2),
        ],
      );
      expect(
        d.map((ReconDiff x) => (x.kind, x.axis, x.key, x.ledger, x.broker)),
        <(ReconKind, LedgerAxis, String, int, int)>[
          (ReconKind.quantity, LedgerAxis.quantity, '069500', 0, 4),
          (ReconKind.quantity, LedgerAxis.quantity, '133690', 5, 3),
          (ReconKind.quantity, LedgerAxis.quantity, '411060', 2, 0),
        ],
      );
      expect(d[1].label, 'pension · 133690 보유 — 원장 5주 · 브로커 3주');
    });

    test('체결 축 ⓐ 원장에 없는 주문의 체결 = UNKNOWN_ORDER · 누적 0 · 취소 행은 아니다', () {
      final List<ReconDiff> d = _acct(
        rows: <DailyFillRow>[
          _row(odno: '0000000007', cum: 2),
          _row(odno: '0000000008', cum: 0),
          _row(odno: '0000000009', cancelRow: true),
        ],
      );
      expect(d.single.kind, ReconKind.unknownOrder);
      expect(d.single.axis, LedgerAxis.executionRow);
      expect(
        (d.single.key, d.single.ledger, d.single.broker),
        ('2026-11-02:0000000007', 0, 2),
      );
      expect(d.single.candidateOriginCodes, contains(OriginCodes.manualOrder));
    });

    test('ⓑ 원장 체결 합 ≠ 브로커 누적 = FILL_COUNT · ⓒ 원장에만 체결 = GHOST_FILL · 체결 0 주문은 조회에 없어도 된다', () {
      final List<ReconDiff> d = _acct(
        rows: <DailyFillRow>[_row(cum: 5)],
        fills: <LedgerOrderFill>[
          _fill('0000000001', 3),
          _fill('0000000002', 2),
          _fill('0000000003', 0),
        ],
      );
      expect(
        d.map((ReconDiff x) => (x.kind, x.key, x.ledger, x.broker)),
        <(ReconKind, String, int, int)>[
          (ReconKind.fillCount, '2026-11-02:0000000001', 3, 5),
          (ReconKind.ghostFill, '2026-11-02:0000000002', 2, 0),
        ],
      );
    });

    test('체결조회에 같은 원주문 행이 둘이면 StateError', () {
      expect(
        () => _acct(rows: <DailyFillRow>[_row(), _row()]),
        throwsStateError,
      );
    });

    test('diff_id = 내용 해시(같은 어긋남 = 같은 id · 값 · 날이 다르면 다른 id) · delta JSON', () {
      const ReconDiff a = ReconDiff(
        account: 'pension',
        kind: ReconKind.quantity,
        key: '133690',
        ledger: 5,
        broker: 3,
      );
      const ReconDiff b = ReconDiff(
        account: 'pension',
        kind: ReconKind.quantity,
        key: '133690',
        ledger: 5,
        broker: 4,
      );
      expect(ledgerDiffIdOf(_day, a), ledgerDiffIdOf(_day, a));
      expect(ledgerDiffIdOf(_day, a), matches(RegExp(r'^ld-[0-9a-f]{24}$')));
      expect(ledgerDiffIdOf(_day, a), isNot(ledgerDiffIdOf(_day, b)));
      expect(
        ledgerDiffIdOf(_day, a),
        isNot(ledgerDiffIdOf(const TradeDate('2026-11-03'), a)),
      );
      expect(jsonDecode(a.deltaJson), <String, Object?>{
        'account': 'pension',
        'kind': 'QTY',
        'key': '133690',
        'ledger': 5,
        'broker': 3,
        'candidates': a.candidateOriginCodes,
      });
    });
  });

  group('대사 실행(runReconciliation · R40 A6 · A7)', () {
    late FakeOrderLedger ledger;
    late FakeOrderBroker broker;
    late List<Duration> sleeps;
    void Function()? onSleep;

    setUp(() {
      ledger = ledgerOf();
      broker = FakeOrderBroker();
      sleeps = <Duration>[];
      onSleep = null;
    });

    Future<ReconReport> run({
      Map<String, String> map = const <String, String>{
        P0sStrategyIds.sleeveB: 'pension',
      },
      Map<String, FakeOrderBroker>? brokers,
    }) {
      final Map<String, FakeOrderBroker> bs =
          brokers ?? <String, FakeOrderBroker>{'pension': broker};
      return runReconciliation(
        ledger: ledger,
        brokers: bs,
        balances: bs,
        accountByStrategy: map,
        tradeDate: _day,
        nowUtc: () => _t0,
        sleep: (Duration d) async {
          sleeps.add(d);
          onSleep?.call();
        },
      );
    }

    void held(int ledgerQty, int brokerQty) {
      ledger.positions[(P0sStrategyIds.sleeveB, '133690')] = ledgerQty;
      broker.holdings['133690'] = brokerQty;
    }

    test('일치 = MATCHED · 재대사 없음 · 플래그 없음 · 기록 1', () async {
      held(5, 5);
      final ReconReport r = await run();
      expect(r.action, ReconAction.matched);
      expect(r.rechecked, isFalse);
      expect(sleeps, isEmpty);
      expect(r.alertCodes, isEmpty);
      expect(ledger.reconRecords.single.matched, isTrue);
      expect(ledger.flags, isNot(contains(FlagIds.reconMismatch)));
    });

    test('일시 — 첫 판 어긋남이 재대사(30초 뒤)에서 사라짐 = TRANSIENT · 차단 없음', () async {
      held(5, 3);
      onSleep = () => broker.holdings['133690'] = 5;
      final ReconReport r = await run();
      expect(sleeps, <Duration>[kReconRecheckDelay]);
      expect(kReconRecheckDelay, const Duration(seconds: 30));
      expect(r.action, ReconAction.transient);
      expect(r.blocking, isEmpty);
      expect(r.transient.single.broker, 3);
      expect(ledger.flags, isNot(contains(FlagIds.reconMismatch)));
      expect(ledger.ledgerDiffs, isEmpty);
      expect(ledger.reconRecords.single.matched, isFalse);
    });

    test(
      '🔴 재대사 뒤 잔존 = BLOCKED · RECON_MISMATCH · P0 · ledger_diff OPEN',
      () async {
        held(5, 3);
        final ReconReport r = await run();
        expect(r.action, ReconAction.blocked);
        expect(r.blocking.single.key, '133690');
        expect(r.alertCodes, <String>{AlertCodes.reconMismatch});
        expect(ledger.flags, contains(FlagIds.reconMismatch));
        final (ReconDiff d, DiffStatus s, String? o) =
            ledger.ledgerDiffs.values.single;
        expect((d.ledger, d.broker, s, o), (5, 3, DiffStatus.open, null));
        expect(broker.balanceReads, 2);
      },
    );

    test('재대사에서 값이 바뀌면 잔존이 아니다(두 값 모두 일시)', () async {
      held(5, 3);
      onSleep = () => broker.holdings['133690'] = 4;
      final ReconReport r = await run();
      expect(r.blocking, isEmpty);
      expect(r.transient.map((ReconDiff d) => d.broker), <int>[3, 4]);
      expect(ledger.flags, isNot(contains(FlagIds.reconMismatch)));
    });

    test('🔴 test_reconcile_mismatch_blocks — 대사 차단 뒤 다음 주문은 SAF-407 거부 · 브로커 호출 0', () async {
      held(5, 3);
      await run();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, startsWith('SAF-407'));
      expect(o.message, contains(FlagIds.reconMismatch));
      expect(broker.submitCount, 0);
    });

    test('조회 실패 · 브로커 없음 = UNAVAILABLE · 차단 없음', () async {
      held(5, 3);
      broker.balanceError = StateError('잔고 조회 실패');
      ReconReport r = await run();
      expect(r.action, ReconAction.unavailable);
      expect(r.unavailable, <String>['pension']);
      expect(ledger.flags, isNot(contains(FlagIds.reconMismatch)));
      broker.balanceError = null;
      broker.fillsError = StateError('체결조회 실패');
      r = await run();
      expect(r.unavailable, <String>['pension']);
      r = await run(brokers: <String, FakeOrderBroker>{});
      expect(r.unavailable, <String>['pension']);
      expect(ledger.flags, isNot(contains(FlagIds.reconMismatch)));
    });

    test('재대사에서 조회가 실패한 계좌의 첫 판 어긋남은 차단하지 않는다(확인 못 함)', () async {
      held(5, 3);
      onSleep = () => broker.balanceError = StateError('잔고 조회 실패');
      final ReconReport r = await run();
      expect(r.blocking, isEmpty);
      expect(r.unavailable, <String>['pension']);
      expect(r.action, ReconAction.transient);
    });

    test(
      '🔴 맵에 없는 전략의 보유 = UNMAPPED_STRATEGY 차단(fail-closed) · 0주는 아니다',
      () async {
        held(5, 5);
        ledger.positions[(P0sStrategyIds.pot, '411060')] = 2;
        ledger.positions[('satellite_kr', '005930')] = 0;
        final ReconReport r = await run();
        expect(r.blocking.single.kind, ReconKind.unmappedStrategy);
        expect(r.blocking.single.account, '?${P0sStrategyIds.pot}');
        expect(r.blocking.single.axis, LedgerAxis.quantity);
        expect(ledger.flags, contains(FlagIds.reconMismatch));
      },
    );

    test('현금 = 관측만 — 예수금이 무엇이든 어긋남이 아니다 · 로그 JSON 에 남는다', () async {
      held(5, 5);
      broker.cashKrw = Decimal.parse('123');
      final ReconReport r = await run();
      expect(r.action, ReconAction.matched);
      expect(r.cashKrw, <String, Decimal?>{'pension': Decimal.parse('123')});
      final Map<String, Object?> j = jsonDecode(
        ledger.reconRecords.single.discrepanciesJson,
      ) as Map<String, Object?>;
      expect(j['cash_krw_observed'], <String, Object?>{'pension': '123'});
      expect(j['first'], isEmpty);
      expect(j.containsKey('recheck'), isFalse);
    });

    test(
      '🔴 대사는 플래그를 풀지 않는다 — 같은 어긋남 재실행 = 한 행 · 맞춰진 뒤 일치 대사도 플래그 그대로',
      () async {
        held(5, 3);
        await run();
        await run();
        expect(ledger.ledgerDiffs, hasLength(1));
        broker.holdings['133690'] = 5;
        final ReconReport r = await run();
        expect(r.action, ReconAction.matched);
        expect(ledger.flags, contains(FlagIds.reconMismatch));
        expect(ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 5);
      },
    );

    test('체결 축 실행 경로 — 주문 → 장중 부분 체결 동기화 → 브로커가 앞서면 QTY · FILL_COUNT 잔존 · 자동 수정 없음', () async {
      await executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker));
      broker.fills['2026-11-02'] = <DailyFillRow>[_row(cum: 3)];
      await runFillSync(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': broker},
        tradeDate: _day,
        nowUtc: DateTime.utc(2026, 11, 2, 1),
        dayEnd: false,
        costs: _rates,
      );
      broker.holdings['133690'] = 3;
      expect((await run()).action, ReconAction.matched);

      broker.fills['2026-11-02'] = <DailyFillRow>[_row(cum: 5)];
      broker.holdings['133690'] = 5;
      final ReconReport r = await run();
      expect(
        r.blocking.map((ReconDiff d) => (d.kind, d.ledger, d.broker)),
        <(ReconKind, int, int)>[
          (ReconKind.quantity, 3, 5),
          (ReconKind.fillCount, 3, 5),
        ],
      );
      expect(ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 3);
      expect(ledger.executions, hasLength(1));
    });
  });

  group('해제(clearRecon · 04 §3-5 ①~④ · R40 A8)', () {
    late FakeOrderLedger ledger;

    Future<void> block() async {
      final FakeOrderBroker b = FakeOrderBroker()..holdings['133690'] = 3;
      ledger.positions[(P0sStrategyIds.sleeveB, '133690')] = 5;
      await runReconciliation(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': b},
        balances: <String, BrokerBalanceSource>{'pension': b},
        accountByStrategy: const <String, String>{
          P0sStrategyIds.sleeveB: 'pension',
        },
        tradeDate: _day,
        nowUtc: () => _t0,
        sleep: (Duration d) async {},
      );
      expect(ledger.flags, contains(FlagIds.reconMismatch));
    }

    Future<ReconClearOutcome> clear(String origin, String decision) =>
        clearRecon(
          ledger,
          originCode: origin,
          decisionId: decision,
          clearedBy: 'telegram:owner',
          nowUtc: _t0,
        );

    setUp(() {
      ledger = ledgerOf()..reconClearJournals.add('dj-recon-1');
    });

    test('🔴 test_clear_recon_without_decision_id_rejected — 빈 id · 없는 저널 = JournalRequired · 플래그 그대로', () async {
      await block();
      for (final String id in <String>['', '  ', 'dj-other']) {
        await expectLater(
          clear(OriginCodes.fillLag, id),
          throwsA(isA<JournalRequired>()),
          reason: id,
        );
      }
      // 저널이 없으면 원인 코드가 틀려도 JournalRequired 가 먼저다.
      await expectLater(clear('확인함', ''), throwsA(isA<JournalRequired>()));
      expect(ledger.flags, contains(FlagIds.reconMismatch));
      expect(ledger.clearances, isEmpty);
    });

    test(
      '① 원인 코드 — 자유 서술 · 파생 계열 · 옛 표기 = RecheckRequired · 허용 = 브로커 6 + X7 6',
      () async {
        await block();
        for (final String c in <String>[
          '확인함',
          OriginCodes.pushLag,
          OriginCodes.chainBroken,
          OriginCodes.corpActionLegacy,
        ]) {
          await expectLater(
            clear(c, 'dj-recon-1'),
            throwsA(isA<RecheckRequired>()),
            reason: c,
          );
        }
        expect(kReconClearOriginCodes, hasLength(12));
        expect(
          kReconClearOriginCodes,
          containsAll(<String>[
            OriginCodes.fillLag,
            OriginCodes.manualOrder,
            OriginCodes.dbError,
            OriginCodes.brokerError,
            OriginCodes.externalCashflow,
            OriginCodes.corporateAction,
            OriginCodes.advisoryFill,
          ]),
        );
        expect(ledger.flags, contains(FlagIds.reconMismatch));
      },
    );

    test('해제 = 플래그 풀림 · OPEN 행 RESOLVED + 원인 코드 · ④ MANUAL_ORDER 만 postmortem 기한 7일', () async {
      await block();
      ReconClearOutcome o = await clear(OriginCodes.fillLag, 'dj-recon-1');
      expect(o.postmortemDueUtc, isNull);
      expect(ledger.flags, isNot(contains(FlagIds.reconMismatch)));
      final (ReconDiff _, DiffStatus s, String? origin) =
          ledger.ledgerDiffs.values.single;
      expect((s, origin), (DiffStatus.resolved, OriginCodes.fillLag));
      expect(ledger.clearances.single.decisionId, 'dj-recon-1');

      // 해제 뒤 같은 어긋남이 다시 보이면 다시 연다.
      await block();
      expect(ledger.ledgerDiffs.values.single.$2, DiffStatus.open);
      o = await clear(OriginCodes.manualOrder, 'dj-recon-1');
      expect(o.postmortemDueUtc, _t0.add(const Duration(days: 7)));
      expect(kManualOrderPostmortemDue, const Duration(days: 7));
    });

    test('플래그가 없으면 StateError · 빈 해제자 = ArgumentError', () async {
      await expectLater(
        clear(OriginCodes.fillLag, 'dj-recon-1'),
        throwsStateError,
      );
      // 원장에 닿기 전에 막는다.
      expect(ledger.calls, isNot(contains('clearReconBlock')));
      await block();
      await expectLater(
        clearRecon(
          ledger,
          originCode: OriginCodes.fillLag,
          decisionId: 'dj-recon-1',
          clearedBy: ' ',
          nowUtc: _t0,
        ),
        throwsArgumentError,
      );
      expect(ledger.flags, contains(FlagIds.reconMismatch));
    });

    test('🔴 test_resume_does_not_clear_recon_block — 408 · 410 판정 갱신 · 일치 대사 뒤에도 RECON_MISMATCH 는 남는다', () async {
      await block();
      await ledger.journalMissing();
      await ledger.tierBUnjudged(_day);
      final FakeOrderBroker ok = FakeOrderBroker()..holdings['133690'] = 5;
      final ReconReport r = await runReconciliation(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': ok},
        balances: <String, BrokerBalanceSource>{'pension': ok},
        accountByStrategy: const <String, String>{
          P0sStrategyIds.sleeveB: 'pension',
        },
        tradeDate: _day,
        nowUtc: () => _t0,
        sleep: (Duration d) async {},
      );
      expect(r.action, ReconAction.matched);
      expect(ledger.flags, contains(FlagIds.reconMismatch));
    });
  });
}
