// E16e — X1-4 갭 재구성 계획(설계 13 §8 R124 I2~I8).
//
// 🔵 잡는 것: ① 갭 창 = [백업 날 · 복구 날 − 1](한국 날) · 빈 창 · 세션만 ② 백업 갭 달력일 · ≥ 7 = RECOVERY_FULL
//    ③ 복구 대상 = 취소 · 체결 0 · 원장 번호 제외 · 같은 번호 한 번 ④ 복구 행(rcv- id · 종결 상태 · 사유 · authored = 복구 ·
//    제출 = 주문 시각 · raw 왕복 · 체결 id · 가격) ⑤ 위반(대응 없음 · 중간 음수 · 보유 어긋남) ⑥ 브레이커 완화 0 · 봉인.
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

/// 2026-11-09(월) ~ 11-16(월) · 11-11(수) 휴장.
final ExchangeCalendar _kr = ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    for (final String d in <String>[
      '2026-11-09',
      '2026-11-10',
      '2026-11-12',
      '2026-11-13',
      '2026-11-16',
    ])
      TradeDate(d),
  ],
  coverageStart: const TradeDate('2026-11-01'),
  coverageEnd: const TradeDate('2026-11-30'),
);

/// 복구 = 11-16 10:00 한국.
final DateTime _recovery = DateTime.utc(2026, 11, 16, 1);

DailyFillRow _row(
  String date,
  String odno, {
  OrderSide side = OrderSide.buy,
  String symbol = '069500',
  int qty = 10,
  int cum = 10,
  int remaining = 0,
  int cancelled = 0,
  bool cancelRow = false,
  String? time = '093015',
}) => DailyFillRow(
  orderDate: TradeDate(date),
  odno: odno,
  isCancelRow: cancelRow,
  symbol: symbol,
  side: side,
  orderQty: qty,
  cumFilledQty: cum,
  cumFilledAmount: Decimal.fromInt(cum * 35000),
  remainingQty: remaining,
  orderPrice: Decimal.fromInt(35000),
  orderTime: time,
  cancelConfirmedQty: cancelled,
);

void main() {
  group('갭 창 · 백업 갭', () {
    test('🔴 창 = [백업 날 · 복구 날 − 1] · 한국 날 경계', () {
      final GapWindow w = gapWindowOf(
        backupAuthoredDate: '2026-11-10',
        recoveryAtUtc: _recovery,
      )!;
      expect((w.fromDate, w.toDate), ('2026-11-10', '2026-11-15'));
      final GapWindow late = gapWindowOf(
        backupAuthoredDate: '2026-11-10',
        recoveryAtUtc: DateTime.utc(2026, 11, 15, 15),
      )!;
      expect(late.toDate, '2026-11-15', reason: 'UTC 15시 = 한국 다음 날 0시');
    });

    test('백업 날 ≥ 복구 날 = 빈 창 · 날 꼴', () {
      expect(
        gapWindowOf(backupAuthoredDate: '2026-11-16', recoveryAtUtc: _recovery),
        isNull,
      );
      expect(
        gapWindowOf(backupAuthoredDate: '2026-11-17', recoveryAtUtc: _recovery),
        isNull,
      );
      expect(
        () => gapWindowOf(
          backupAuthoredDate: '2026-11-1',
          recoveryAtUtc: _recovery,
        ),
        throwsArgumentError,
      );
    });

    test('세션만 — 주말 · 휴장 빼고 날 차례', () {
      final GapWindow w = gapWindowOf(
        backupAuthoredDate: '2026-11-09',
        recoveryAtUtc: _recovery,
      )!;
      expect(gapSessionsOf(w, _kr).map((TradeDate t) => t.yyyyMmDd), <String>[
        '2026-11-09',
        '2026-11-10',
        '2026-11-12',
        '2026-11-13',
      ]);
    });

    test('🔴 백업 갭 = 달력일 · ≥ 7 = RECOVERY_FULL(세션 갭 0 이어도)', () {
      expect(
        backupGapDaysOf(
          backupAuthoredDate: '2026-11-09',
          recoveryAtUtc: _recovery,
        ),
        7,
      );
      expect(
        backupGapDaysOf(
          backupAuthoredDate: '2026-11-20',
          recoveryAtUtc: _recovery,
        ),
        0,
      );
      expect(
        gapResumeModeOf(
          gapSessions: 0,
          backupAuthoredDate: '2026-11-09',
          recoveryAtUtc: _recovery,
          ladder: ResumeLadder.defaults,
        ),
        ResumeMode.recoveryFull,
      );
      expect(
        gapResumeModeOf(
          gapSessions: 0,
          backupAuthoredDate: '2026-11-10',
          recoveryAtUtc: _recovery,
          ladder: ResumeLadder.defaults,
        ),
        isNot(ResumeMode.recoveryFull),
      );
    });
  });

  group('복구 대상 · 복구 행', () {
    test('🔴 취소 행 · 체결 0 · 원장에 있는 번호 = 빼고 · 같은 번호 = 한 번(번호 차례)', () {
      final List<DailyFillRow> got = gapFillsToRecover(
        <DailyFillRow>[
          _row('2026-11-12', '0000000002'),
          _row('2026-11-10', '0000000001', cum: 5, remaining: 5),
          _row('2026-11-10', '0000000001'),
          _row('2026-11-10', '0000000003', cancelRow: true),
          _row('2026-11-10', '0000000004', cum: 0, remaining: 10),
          _row('2026-11-13', '0000000005'),
        ],
        knownBrokerOrderNos: <String>{
          brokerOrderNoOf(const TradeDate('2026-11-13'), '0000000005'),
        },
      );
      expect(
        got.map((DailyFillRow r) => (r.odno, r.cumFilledQty)),
        <(String, int)>[('0000000001', 10), ('0000000002', 10)],
      );
    });

    test('종결 상태 — 다 채움 = FILLED · 잔량 0 ∧ 취소 = CANCELLED · 그 밖 = EXPIRED', () {
      expect(recoveredStatusOf(_row('2026-11-10', '1')), IntentStatus.filled);
      expect(
        recoveredStatusOf(
          _row('2026-11-10', '1', cum: 4, remaining: 0, cancelled: 6),
        ),
        IntentStatus.cancelled,
      );
      expect(
        recoveredStatusOf(_row('2026-11-10', '1', cum: 4, remaining: 6)),
        IntentStatus.expired,
      );
      expect(
        recoveredStatusOf(_row('2026-11-10', '1', cum: 4, remaining: 0)),
        IntentStatus.expired,
        reason: '잔량 0 이어도 취소 확인이 없으면 실효',
      );
    });

    test(
      '🔴 복구 행 — rcv- id · 멱등 키 · 사유 · authored = 복구 · 제출 = 주문 시각 · raw · 체결',
      () {
        final DailyFillRow r = _row(
          '2026-11-12',
          '0000000002',
          qty: 12,
          cum: 10,
          remaining: 2,
        );
        final RecoveredFillPlan p = recoveredFillPlanOf(
          r,
          account: 'acct-b',
          strategyId: 'P0S_B',
          declarationDecisionId: 'dec-x1',
          configHash: 'cfg_1',
          recoveryAtUtc: _recovery,
        );
        final String no = brokerOrderNoOf(
          const TradeDate('2026-11-12'),
          '0000000002',
        );
        expect(p.intentId, 'rcv-$no');
        expect(p.idempotencyKey, matches(RegExp(r'^[0-9a-f]{64}$')));
        expect(
          p.idempotencyKey,
          isNot(
            recoveredFillPlanOf(
              _row('2026-11-12', '0000000009'),
              account: 'acct-b',
              strategyId: 'P0S_B',
              declarationDecisionId: 'dec-x1',
              configHash: 'cfg_1',
              recoveryAtUtc: _recovery,
            ).idempotencyKey,
          ),
        );
        expect(
          (p.status, p.reasonCode, p.fillOrigin, p.decisionId),
          (
            IntentStatus.expired,
            'X1_RECOVERED',
            'BROKER_RECOVERED',
            'dec-x1@2026-11-12',
          ),
        );
        expect(
          (p.createdAtUtc, p.configHash, p.strategyId),
          (_recovery, 'cfg_1', 'P0S_B'),
        );
        expect(p.submittedAtUtc, DateTime.utc(2026, 11, 12, 0, 30, 15));
        expect((p.filledQty, p.remainingQty, p.orderQuantity), (10, 2, 12));
        expect(p.executionId, executionIdOf(no, 10));
        expect(p.executionPrice, 35000.0);
        expect(
          (jsonDecode(p.rawResponse) as Map<String, Object?>).isNotEmpty,
          isTrue,
        );
        expect(p.rawResponse, recordedFillJson(r, _recovery));
      },
    );

    test('주문 시각 없음 = 주문일 09:00 · 취소 행 · 체결 0 · 빈 결정 = ArgumentError', () {
      final RecoveredFillPlan p = recoveredFillPlanOf(
        _row('2026-11-12', '7', time: null),
        account: 'a',
        strategyId: 's',
        declarationDecisionId: 'd',
        configHash: 'c',
        recoveryAtUtc: _recovery,
      );
      expect(p.submittedAtUtc, DateTime.utc(2026, 11, 12));
      for (final DailyFillRow bad in <DailyFillRow>[
        _row('2026-11-12', '8', cancelRow: true),
        _row('2026-11-12', '9', cum: 0, remaining: 10),
      ]) {
        expect(
          () => recoveredFillPlanOf(
            bad,
            account: 'a',
            strategyId: 's',
            declarationDecisionId: 'd',
            configHash: 'c',
            recoveryAtUtc: _recovery,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => recoveredFillPlanOf(
          _row('2026-11-12', '7'),
          account: 'a',
          strategyId: 's',
          declarationDecisionId: ' ',
          configHash: 'c',
          recoveryAtUtc: _recovery,
        ),
        throwsArgumentError,
      );
    });
  });

  group('«봇 전용 계좌» 위반', () {
    bool all(String _) => true;

    test('복원 + 갭 체결 = 브로커 보유면 위반 0', () {
      expect(
        gapViolationsOf(
          restoredHoldings: <String, int>{'069500': 100},
          recovered: <DailyFillRow>[
            _row('2026-11-10', '1', qty: 20, cum: 20),
            _row('2026-11-12', '2', side: OrderSide.sell, qty: 5, cum: 5),
          ],
          brokerHoldings: <String, int>{'069500': 115},
          strategyMapped: all,
        ),
        isEmpty,
      );
    });

    test('🔴 보유 어긋남 · 브로커만 가진 종목 = mismatch', () {
      final List<GapViolation> v = gapViolationsOf(
        restoredHoldings: <String, int>{'069500': 100},
        recovered: <DailyFillRow>[_row('2026-11-10', '1', qty: 20, cum: 20)],
        brokerHoldings: <String, int>{'069500': 110, '114800': 3},
        strategyMapped: all,
      );
      expect(
        v.map((GapViolation x) => (x.kind, x.symbol, x.ledgerAfter, x.broker)),
        <(GapViolationKind, String, int?, int?)>[
          (GapViolationKind.mismatch, '069500', 120, 110),
          (GapViolationKind.mismatch, '114800', 0, 3),
        ],
      );
    });

    test('🔴 중간 음수(보유보다 먼저 팖) = oversold — 끝 수량이 맞아도', () {
      final List<GapViolation> v = gapViolationsOf(
        restoredHoldings: <String, int>{'069500': 5},
        recovered: <DailyFillRow>[
          _row('2026-11-12', '2', qty: 10, cum: 10),
          _row('2026-11-10', '1', side: OrderSide.sell, qty: 8, cum: 8),
        ],
        brokerHoldings: <String, int>{'069500': 7},
        strategyMapped: all,
      );
      expect(v.single.kind, GapViolationKind.oversold);
    });

    test('🔴 전략 대응 없음 = unmapped(먼저)', () {
      final List<GapViolation> v = gapViolationsOf(
        restoredHoldings: const <String, int>{},
        recovered: <DailyFillRow>[_row('2026-11-10', '1', symbol: 'ZZZ')],
        brokerHoldings: <String, int>{'ZZZ': 10},
        strategyMapped: (String s) => s != 'ZZZ',
      );
      expect(
        v.map((GapViolation x) => (x.kind, x.symbol)),
        <(GapViolationKind, String)>[(GapViolationKind.unmapped, 'ZZZ')],
      );
    });
  });

  test('🔴 브레이커 = 무거운 쪽(완화 0) · 재구성 차례', () {
    expect(
      conservativeBreakerLevel(BreakerLevel.halted, BreakerLevel.normal),
      BreakerLevel.halted,
    );
    expect(
      conservativeBreakerLevel(BreakerLevel.alert, BreakerLevel.stopped),
      BreakerLevel.stopped,
    );
    expect(kGapRecomputeOrder, <GapRecompute>[
      GapRecompute.positions,
      GapRecompute.strategyState,
      GapRecompute.ramp,
      GapRecompute.breakerReplay,
      GapRecompute.regimeBackfill,
    ]);
  });

  test('🔴 복구 봉인 — 재구성 전 · RECOVERY_FULL = 거부 · 그 밖 = 없음', () {
    expect(
      recoveryOrderSealCode(gapRebuildDone: false, mode: ResumeMode.normal),
      RecoverySealCodes.inProgress,
    );
    expect(
      recoveryOrderSealCode(
        gapRebuildDone: true,
        mode: ResumeMode.recoveryFull,
      ),
      RecoverySealCodes.full,
    );
    for (final ResumeMode m in <ResumeMode>[
      ResumeMode.normal,
      ResumeMode.conservative,
      ResumeMode.recoveryDry,
    ]) {
      expect(recoveryOrderSealCode(gapRebuildDone: true, mode: m), isNull);
    }
  });
}
