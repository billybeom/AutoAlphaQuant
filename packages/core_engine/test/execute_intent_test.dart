// NR-1 순서기 — 04 §7 안전 시험 포트 수준 9종 + 04 §1 상태 표 · §3-3 결과 불명 · 안내 분기
// (04 §3-1 · 01 §6 `execute_intent` · 설계 13 §8 R35 V5~V7 · V10).
//
// 🔵 `test_intent_before_order` 의 진짜 판정(별도 커넥션에서 행이 보이는가)은 SQLite 원장 시험(E10c)이 한다 —
//    여기는 «제출 순간 원장에 SUBMITTING 행이 있고, INSERT 가 제출보다 먼저다»를 포트 수준에서 본다.

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'order_path_fixture.dart';

void main() {
  group('04 §7 안전 시험(포트 수준)', () {
    test(
      'test_intent_before_order — 제출 순간 원장에 SUBMITTING 행이 있다 · 단계 순서',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        final OrderIntentDraft d = draftOf();
        final String id = intentIdFor(d.idempotencyKey);
        final List<IntentStatus?> seenAtSubmit = <IntentStatus?>[];
        final FakeOrderBroker broker = FakeOrderBroker(
          onSubmit: (BrokerOrderRequest r) async =>
              seenAtSubmit.add(ledger.records[id]?.status),
        );
        final List<String> steps = <String>[];
        final ExecutionOutcome o = await executeIntent(
          d,
          portfolioOk(),
          ctxOf(ledger, broker),
          steps: steps,
        );
        expect(o.status, ExecutionStatus.submitted);
        expect(seenAtSubmit, <IntentStatus>[IntentStatus.submitting]);
        expect(steps, <String>[
          '0',
          '1',
          '1.5', // 🆕 E13d1 — 브레이커 STOPPED 확인(R60 B1).
          '2',
          '2.5',
          '3',
          '4',
          '5',
          '6',
          '6.5',
          '7',
          '8',
          '9',
        ]);
        expect(
          ledger.transitions.map(((String, IntentStatus) t) => t.$2),
          <IntentStatus>[
            IntentStatus.reserved,
            IntentStatus.submitting,
            IntentStatus.submitted,
          ],
        );
        expect(o.brokerOrderNo, '2026-11-02:0000000001');
        expect(ledger.records[id]!.brokerOrderNo, '2026-11-02:0000000001');
        // 최초 INSERT 값 = RESERVED · 행 값 = 초안 그대로.
        final IntentRow row = ledger.records[id]!.row;
        expect(row.status, IntentStatus.reserved);
        expect(row.decisionId, 'B-SMA-2026-10-30@2026-11-02');
        expect(row.execPolicy, ExecPolicy.execute);
        expect(row.configHash, 'cfg-test');
        expect(broker.submitted.single.toString(), '133690 BUY 5 LIMIT 174180');
      },
    );

    test('test_idempotency_duplicate_call — 같은 결정 두 번 → 제출 1회 · 둘째 = PREVENTED(행 없음)', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome a = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      final ExecutionOutcome b = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(a.status, ExecutionStatus.submitted);
      expect(b.status, ExecutionStatus.prevented);
      expect(b.quantity, isNull);
      expect(broker.submitCount, 1);
      expect(ledger.records, hasLength(1));
    });

    test(
      'test_timeout_no_retry — 결과 불명 → OrderOutcomeUnknown · 제출 1회 · UNKNOWN',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        final FakeOrderBroker broker = FakeOrderBroker(
          script: <FakeSubmitStep>[const FakeUnknown('ReadTimeout')],
        );
        final OrderIntentDraft d = draftOf();
        await expectLater(
          executeIntent(d, portfolioOk(), ctxOf(ledger, broker)),
          throwsA(
            isA<OrderOutcomeUnknown>().having(
              (OrderOutcomeUnknown e) => e.intentId,
              'intentId',
              intentIdFor(d.idempotencyKey),
            ),
          ),
        );
        expect(broker.submitCount, 1);
        expect(ledger.records.values.single.status, IntentStatus.unknown);
      },
    );

    test(
      'test_kill_switch_blocks_orders — 매수 · 매도 모두 REJECTED KILL_SWITCH · 제출 0',
      () async {
        final FakeOrderLedger ledger = ledgerOf()..killSwitch = true;
        final FakeOrderBroker broker = FakeOrderBroker();
        for (final OrderSide side in OrderSide.values) {
          final ExecutionOutcome o = await executeIntent(
            draftOf(side: side, logical: 'K-${side.wire}'),
            portfolioOk(),
            ctxOf(ledger, broker),
          );
          expect(o.status, ExecutionStatus.rejected);
          expect(o.message, 'KILL_SWITCH');
          expect(o.alertCode, AlertCodes.orderRejected);
        }
        expect(broker.submitCount, 0);
        // 1~5단계 거부도 그 키로 행을 남긴다(D21).
        expect(
          ledger.records.values.map(
            (FakeIntentRecord r) => (r.status, r.errorMessage),
          ),
          <(IntentStatus, String?)>[
            (IntentStatus.rejected, 'KILL_SWITCH'),
            (IntentStatus.rejected, 'KILL_SWITCH'),
          ],
        );
      },
    );

    test('🆕 E13b — 1단계 뒤 · 제출 전에 눌린 킬스위치 = SKIPPED KILL_SWITCH · 제출 0(04 §3-6 «매 주문 직전»)', () async {
      final FakeOrderLedger ledger = ledgerOf();
      ledger.failOn = (String m) {
        if (m == 'insertIntent') ledger.killSwitch = true;
        return null;
      };
      final FakeOrderBroker broker = FakeOrderBroker();
      final List<String> steps = <String>[];
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
        steps: steps,
      );
      expect((o.status, o.message), (ExecutionStatus.skipped, 'KILL_SWITCH'));
      expect(broker.submitCount, 0);
      expect(steps, containsAllInOrder(<String>['1', '6', '6.5', '6.9']));
      expect(steps, isNot(contains('7')));
      final FakeIntentRecord r = ledger.records.values.single;
      expect((r.status, r.errorMessage), (IntentStatus.skipped, 'KILL_SWITCH'));
    });

    test('🆕 E13b — 제출 전 재확인을 읽지 못하면 막는다(fail-closed)', () async {
      final FakeOrderLedger ledger = ledgerOf();
      int reads = 0;
      ledger.failOn = (String m) {
        if (m == 'killSwitchActive' && ++reads == 2) return StateError('디스크');
        return null;
      };
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect((o.status, o.message), (ExecutionStatus.skipped, 'KILL_SWITCH'));
      expect(broker.submitCount, 0);
      expect(reads, 2);
    });

    test('test_limit_check_failure_rejects — 한도 입력 없음 · 원장 읽기 실패 = REJECTED RISK_UNAVAILABLE', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(equityKnown: false),
        ctxOf(ledger, broker),
      );
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, startsWith('RISK_UNAVAILABLE: 입력 누락: total_equity'));

      final FakeOrderLedger failing = ledgerOf()
        ..failOn = (String m) => m == 'ordersToday' ? StateError('디스크') : null;
      o = await executeIntent(draftOf(), portfolioOk(), ctxOf(failing, broker));
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, startsWith('RISK_UNAVAILABLE: 원장 확인 불가'));
      expect(failing.records.values.single.status, IntentStatus.rejected);
      expect(broker.submitCount, 0);
    });

    test('test_strategy_state_missing_rejects — 등록 안 된 전략 = SAF-406', () async {
      final FakeOrderLedger ledger = ledgerOf(strategies: <String>{});
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, startsWith('SAF-406'));
      expect(broker.submitCount, 0);
    });

    test(
      'test_reconcile_mismatch_blocks — RECON_MISMATCH 면 매수 · 매도 모두 거부',
      () async {
        final FakeOrderLedger ledger = ledgerOf()
          ..flags.add(FlagIds.reconMismatch);
        final FakeOrderBroker broker = FakeOrderBroker();
        for (final OrderSide side in OrderSide.values) {
          final ExecutionOutcome o = await executeIntent(
            draftOf(side: side, logical: 'R-${side.wire}'),
            portfolioOk(),
            ctxOf(ledger, broker),
          );
          expect(o.message, 'SAF-407: RECON_MISMATCH');
        }
        expect(broker.submitCount, 0);
      },
    );

    test(
      'test_dry_run_no_broker_call — DRY_RUN = 6.5 까지 · SKIPPED DRY_RUN · 제출 0',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        final FakeOrderBroker broker = FakeOrderBroker();
        final List<String> steps = <String>[];
        final ExecutionOutcome o = await executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(ledger, broker, execPolicy: ExecPolicy.dryRun),
          steps: steps,
        );
        expect(o.status, ExecutionStatus.skipped);
        expect(o.message, 'DRY_RUN');
        expect(broker.submitCount, 0);
        expect(steps.last, '6.5');
        expect(
          ledger.transitions.map(((String, IntentStatus) t) => t.$2),
          <IntentStatus>[IntentStatus.reserved, IntentStatus.skipped],
        );
        expect(ledger.records.values.single.row.execPolicy, ExecPolicy.dryRun);
      },
    );

    test('test_order_type_whitelist — 목록 밖 주문유형 = SAF-404 · 제출 0', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      ExecutionOutcome o = await executeIntent(
        draftOf(orderType: 'STOP'),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, contains('SAF-404'));
      final LimitConfig limitOnly = LimitConfig(
        maxNotionalPct: kLimitConfig.maxNotionalPct,
        riskBudgetPct: kLimitConfig.riskBudgetPct,
        satelliteMaxPositions: kLimitConfig.satelliteMaxPositions,
        satelliteMaxPerSector: kLimitConfig.satelliteMaxPerSector,
        maxRiskExposure: kLimitConfig.maxRiskExposure,
        maxLeverage: kLimitConfig.maxLeverage,
        maxPositions: kLimitConfig.maxPositions,
        maxOrdersPerDay: kLimitConfig.maxOrdersPerDay,
        maxOrderValueKrw: kLimitConfig.maxOrderValueKrw,
        maxDailyLossPct: kLimitConfig.maxDailyLossPct,
        orderTypeWhitelist: const <String>{OrderTypes.limit},
      );
      o = await executeIntent(
        draftOf(orderType: OrderTypes.market, logical: 'M-1'),
        portfolioOk(),
        ctxOf(ledger, broker, limitConfig: limitOnly),
      );
      expect(o.message, contains('SAF-404'));
      expect(broker.submitCount, 0);
    });
  });

  group('2단계 묶음 · 2.5 · 한도 · 원장 값', () {
    test('신규 매수 차단(JOURNAL_MISSING)은 매수만 · 표식은 막지 않는다', () async {
      final FakeOrderLedger ledger = ledgerOf()
        ..journalMissingValue = true
        ..flags.add(FlagIds.dstWeek);
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome buy = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      final ExecutionOutcome sell = await executeIntent(
        draftOf(side: OrderSide.sell, logical: 'S-1'),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(buy.message, 'SAF-407: JOURNAL_MISSING');
      expect(sell.status, ExecutionStatus.submitted);
      expect(broker.submitCount, 1);
    });

    test('진입 안내 중단 묶음은 안내 모드의 매수만 · 자동 모드는 그대로 낸다', () async {
      final FakeOrderLedger ledger = ledgerOf()
        ..flags.add(FlagIds.adviceLedgerUnverified);
      final FakeOrderBroker broker = FakeOrderBroker();
      final RecordingAdviceSink sink = RecordingAdviceSink();
      final ExecutionOutcome auto = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      final ExecutionOutcome adv = await executeIntent(
        draftOf(logical: 'A-1'),
        portfolioOk(),
        ctxOf(ledger, broker, mode: OperatingMode.advisory, advice: sink),
      );
      expect(auto.status, ExecutionStatus.submitted);
      expect(adv.message, 'SAF-407: ADVICE_LEDGER_UNVERIFIED');
      expect(sink.published, isEmpty);
    });

    test(
      '2.5 — UNKNOWN 이 남은 (시장 · 종목 · 전략)은 방향 · 날 무관 거부 · 다른 전략은 낸다',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        final FakeOrderBroker broker = FakeOrderBroker(
          script: <FakeSubmitStep>[const FakeUnknown()],
        );
        await expectLater(
          executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker)),
          throwsA(isA<OrderOutcomeUnknown>()),
        );
        final ExecutionOutcome sameNextDay = await executeIntent(
          draftOf(
            side: OrderSide.sell,
            logical: 'BAND-B-2026-10-30',
            executionDate: const TradeDate('2026-11-03'),
          ),
          portfolioOk(),
          ctxOf(ledger, broker),
        );
        expect(sameNextDay.message, startsWith('UNKNOWN_UNRESOLVED'));
        final ExecutionOutcome otherStrategy = await executeIntent(
          draftOf(
            strategyId: P0sStrategyIds.pot,
            logical: 'POT-SMA-2026-10-30',
          ),
          portfolioOk(),
          ctxOf(ledger, broker),
        );
        expect(otherStrategy.status, ExecutionStatus.submitted);
        expect(broker.submitCount, 2);
      },
    );

    test('🔴 한 번 선 JOURNAL_MISSING · TIER_B_UNJUDGED 도 판정이 풀리면 다음 매수는 낸다(자동 해제 · R36 W9)', () async {
      final FakeOrderLedger ledger = ledgerOf()
        ..flags.addAll(<String>{FlagIds.journalMissing, FlagIds.tierBUnjudged});
      final FakeOrderBroker broker = FakeOrderBroker();
      final List<String> steps = <String>[];
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
        steps: steps,
      );
      expect(o.status, ExecutionStatus.submitted);
      expect(ledger.flags, isEmpty);
      expect(ledger.lastTierBDate, kExec);
      // 판정은 묶음을 읽기 전에 돈다.
      expect(
        ledger.calls.indexOf('tierBUnjudged'),
        lessThan(ledger.calls.indexOf('activeBlockFlags')),
      );
      expect(
        ledger.calls.indexOf('journalMissing'),
        lessThan(ledger.calls.indexOf('activeBlockFlags')),
      );
    });

    test('SAF-410 판정이 서면 매수만 막는다', () async {
      final FakeOrderLedger ledger = ledgerOf()..tierBUnjudgedValue = true;
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome buy = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      final ExecutionOutcome sell = await executeIntent(
        draftOf(side: OrderSide.sell, logical: 'S-9'),
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(buy.message, 'SAF-407: TIER_B_UNJUDGED');
      expect(sell.status, ExecutionStatus.submitted);
    });

    test('한도 위반(SAF-402 주문 금액) = REJECTED 「SAF-402: 한도 위반」', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome o = await executeIntent(
        draftOf(quantity: 200), // 200 × 174,180 = 3,483만 > 2,000만
        portfolioOk(),
        ctxOf(ledger, broker),
      );
      expect(o.message, 'SAF-402: 한도 위반');
      expect(broker.submitCount, 0);
    });

    test(
      '원장 값이 포트폴리오 입력을 덮는다 — orders_today(SAF-401) · 매수만 SAF-408 · 410',
      () async {
        final FakeOrderLedger ledger = ledgerOf()..journalMissingValue = true;
        final FakeOrderBroker broker = FakeOrderBroker();
        final ExecutionOutcome buy = await executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(ledger, broker),
        );
        // 2단계 앞 SAF-408 판정이 JOURNAL_MISSING 을 세우고 2단계가 막는다(R36 W9).
        expect(buy.message, 'SAF-407: JOURNAL_MISSING');
        ledger.calls.clear();
        final ExecutionOutcome sell = await executeIntent(
          draftOf(side: OrderSide.sell, logical: 'S-2'),
          portfolioOk(),
          ctxOf(ledger, broker),
        );
        expect(sell.status, ExecutionStatus.submitted);
        // 매도는 408 · 410 SQL 을 부르지 않는다(04 §1 P6 «필요한 것만»).
        expect(ledger.calls, isNot(contains('journalMissing')));
        expect(ledger.calls, isNot(contains('tierBUnjudged')));

        final FakeOrderLedger busy = ledgerOf();
        for (int i = 0; i < 60; i++) {
          await executeIntent(
            draftOf(side: OrderSide.sell, logical: 'X-$i'),
            portfolioOk(),
            ctxOf(busy, FakeOrderBroker()),
          );
        }
        final ExecutionOutcome over = await executeIntent(
          draftOf(side: OrderSide.sell, logical: 'X-60'),
          portfolioOk(),
          ctxOf(busy, FakeOrderBroker()),
        );
        expect(over.message, 'SAF-401: 한도 위반');
      },
    );

    test(
      '브로커 거절은 7단계를 지났다 — orders_today 에 센다(D22) · 1~5단계 거부는 세지 않는다',
      () async {
        final FakeOrderLedger ledger = ledgerOf();
        await executeIntent(
          draftOf(logical: 'R-1'),
          portfolioOk(),
          ctxOf(
            ledger,
            FakeOrderBroker(
              script: <FakeSubmitStep>[const FakeReject('40580000', '장종료')],
            ),
          ),
        );
        ledger.killSwitch = true;
        await executeIntent(
          draftOf(logical: 'R-2'),
          portfolioOk(),
          ctxOf(ledger, FakeOrderBroker()),
        );
        expect(await ledger.ordersToday(kExec), 1);
      },
    );
  });

  group('9단계 · 결과 불명 · 기록 실패', () {
    test('브로커 거절 = REJECTED 「{코드}: {메시지}」 + ORDER_REJECTED', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(
          ledger,
          FakeOrderBroker(
            script: <FakeSubmitStep>[const FakeReject('40580000', '장종료')],
          ),
        ),
      );
      expect(o.status, ExecutionStatus.rejected);
      expect(o.message, '40580000: 장종료');
      expect(o.alertCode, AlertCodes.orderRejected);
      expect(ledger.records.values.single.brokerRejected, isTrue);
    });

    test('🔴 포트의 그 밖 예외도 결과 불명 — UNKNOWN · 제출 1회', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[FakeThrow(StateError('가드'))],
      );
      await expectLater(
        executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker)),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      expect(broker.submitCount, 1);
      expect(ledger.records.values.single.status, IntentStatus.unknown);
    });

    test(
      '🔴 브로커 접수 뒤 기록 실패 = UNKNOWN · 브로커 재호출 없음(04 §3-3 «DB 기록 실패»)',
      () async {
        final FakeOrderLedger ledger = ledgerOf()
          ..failOn = (String m) =>
              m == 'markSubmitted' ? StateError('디스크 가득') : null;
        final FakeOrderBroker broker = FakeOrderBroker();
        await expectLater(
          executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker)),
          throwsA(isA<OrderOutcomeUnknown>()),
        );
        expect(broker.submitCount, 1);
        expect(ledger.records.values.single.status, IntentStatus.unknown);
      },
    );

    test('거절 응답 기록 실패도 UNKNOWN', () async {
      final FakeOrderLedger ledger = ledgerOf()
        ..failOn = (String m) =>
            m == 'markBrokerRejected' ? StateError('디스크') : null;
      await expectLater(
        executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(
            ledger,
            FakeOrderBroker(
              script: <FakeSubmitStep>[const FakeReject('40580000', '장종료')],
            ),
          ),
        ),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      expect(ledger.records.values.single.status, IntentStatus.unknown);
    });

    test('UNKNOWN 기록이 한 번 실패하면 한 번 더 · 두 번 다 실패하면 예외가 그것을 말한다', () async {
      int tries = 0;
      final FakeOrderLedger once = ledgerOf()
        ..failOn = (String m) =>
            m == 'markUnknown' && tries++ == 0 ? StateError('잠김') : null;
      await expectLater(
        executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(
            once,
            FakeOrderBroker(script: <FakeSubmitStep>[const FakeUnknown()]),
          ),
        ),
        throwsA(isA<OrderOutcomeUnknown>()),
      );
      expect(once.records.values.single.status, IntentStatus.unknown);

      final FakeOrderLedger never = ledgerOf()
        ..failOn = (String m) => m == 'markUnknown' ? StateError('잠김') : null;
      await expectLater(
        executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(
            never,
            FakeOrderBroker(script: <FakeSubmitStep>[const FakeUnknown()]),
          ),
        ),
        throwsA(
          isA<OrderOutcomeUnknown>().having(
            (OrderOutcomeUnknown e) => e.message,
            'message',
            contains('UNKNOWN 기록도 실패'),
          ),
        ),
      );
      expect(never.calls.where((String c) => c == 'markUnknown'), hasLength(2));
    });

    test('INSERT · SUBMITTING 기록이 실패하면 예외 그대로 — 제출 0(주문이 나가지 않는다)', () async {
      for (final String failing in <String>['insertIntent', 'markSubmitting']) {
        final FakeOrderLedger ledger = ledgerOf()
          ..failOn = (String m) => m == failing ? StateError(failing) : null;
        final FakeOrderBroker broker = FakeOrderBroker();
        await expectLater(
          executeIntent(draftOf(), portfolioOk(), ctxOf(ledger, broker)),
          throwsStateError,
        );
        expect(broker.submitCount, 0, reason: failing);
      }
    });
  });

  group('안내 모드(04 §3-1 ② — 6.5 뒤 한 곳)', () {
    test('1~6 을 다 지난 뒤 안내로 넘긴다 · 제출 0 · 의도는 RESERVED', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      final RecordingAdviceSink sink = RecordingAdviceSink();
      final List<String> steps = <String>[];
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledger, broker, mode: OperatingMode.advisory, advice: sink),
        steps: steps,
      );
      expect(o.status, ExecutionStatus.advised);
      expect(steps.last, '6.5');
      expect(broker.submitCount, 0);
      expect(sink.published.single.operatingMode, OperatingMode.advisory);
      expect(ledger.records.values.single.status, IntentStatus.reserved);
    });

    test('안내 모드도 리스크 게이트를 지난다 — 킬스위치면 안내하지 않는다', () async {
      final FakeOrderLedger ledger = ledgerOf()..killSwitch = true;
      final RecordingAdviceSink sink = RecordingAdviceSink();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(
          ledger,
          FakeOrderBroker(),
          mode: OperatingMode.advisory,
          advice: sink,
        ),
      );
      expect(o.message, 'KILL_SWITCH');
      expect(sink.published, isEmpty);
    });

    test('안내 모드인데 받는 쪽이 없으면 거절(ArgumentError)', () async {
      await expectLater(
        executeIntent(
          draftOf(),
          portfolioOk(),
          ctxOf(ledgerOf(), FakeOrderBroker(), mode: OperatingMode.advisory),
        ),
        throwsArgumentError,
      );
    });
  });

  test('intent_id = oi- + 멱등키 앞 24자 · 결정적', () {
    final String key = draftOf().idempotencyKey;
    expect(intentIdFor(key), 'oi-${key.substring(0, 24)}');
    expect(intentIdFor(draftOf().idempotencyKey), intentIdFor(key));
    expect(() => intentIdFor('xyz'), throwsArgumentError);
    expect(() => intentIdFor(key.toUpperCase()), throwsArgumentError);
  });

  test('시장가 초안은 지정가 없이 제출한다', () async {
    final FakeOrderBroker broker = FakeOrderBroker();
    await executeIntent(
      draftOf(orderType: OrderTypes.market, logical: 'SEAS-A-IN-2026-10-30'),
      portfolioOk(),
      ctxOf(ledgerOf(), broker),
    );
    expect(broker.submitted.single.limitPrice, isNull);
    expect(broker.submitted.single.orderType, OrderTypes.market);
  });

  test('평가액이 없어도 매도는 낸다(D23)', () async {
    final FakeOrderBroker broker = FakeOrderBroker();
    final ExecutionOutcome o = await executeIntent(
      draftOf(side: OrderSide.sell),
      portfolioOk(equityKnown: false),
      ctxOf(ledgerOf(), broker),
    );
    expect(o.status, ExecutionStatus.submitted);
    expect(o.quantity, 5);
    expect(Decimal.parse('174180'), broker.submitted.single.limitPrice);
  });
}
