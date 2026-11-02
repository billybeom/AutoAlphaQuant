// 체결 델타(R31 (a) · 02 §3-2 v2.38 · 설계 13 §8 R33 D3 · D4 · R34 U9) — 누적수량 키 · 멱등 · 취소 행 · 앞뒤 안 맞음.
//
// 행 값은 실험 8 next 단계 체결조회(07 §6-3 · 설계 `tool/kis-exp278/results/20261030_083706_next/`)의 133690 행을
// 본뜬 것이다(주문번호는 가림 자리표시라 숫자로 바꿨다).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _day = TradeDate('2026-10-29');

DailyFillRow _row(
  String odno, {
  int cum = 0,
  String amount = '0',
  int remaining = 0,
  bool cancel = false,
  OrderSide side = OrderSide.buy,
  TradeDate date = _day,
}) => DailyFillRow(
  orderDate: date,
  odno: odno,
  isCancelRow: cancel,
  symbol: '133690',
  side: side,
  orderQty: 3,
  cumFilledQty: cum,
  cumFilledAmount: _d(amount),
  remainingQty: remaining,
);

void main() {
  group('키 꼴', () {
    test(
      'broker_order_no = {주문일}:{ODNO} · execution_id = {broker_order_no}#{누적}',
      () {
        final String no = brokerOrderNoOf(_day, '0000012345');
        expect(no, '2026-10-29:0000012345');
        expect(executionIdOf(no, 2), '2026-10-29:0000012345#2');
        expect(_row('0000012345').brokerOrderNo, no);
      },
    );

    test('같은 ODNO 라도 주문일이 다르면 다른 키(날마다 새로 매겨질 수 있다 — R31)', () {
      expect(
        brokerOrderNoOf(const TradeDate('2026-10-30'), '0000012345'),
        isNot(brokerOrderNoOf(_day, '0000012345')),
      );
    });

    test('모호한 값은 거절', () {
      expect(() => brokerOrderNoOf(_day, ''), throwsArgumentError);
      expect(() => brokerOrderNoOf(_day, '12 34'), throwsArgumentError);
      expect(() => brokerOrderNoOf(_day, '12#3'), throwsArgumentError);
      expect(() => brokerOrderNoOf(_day, '12:3'), throwsArgumentError);
      expect(
        () => brokerOrderNoOf(const TradeDate('20261029'), '1'),
        throwsArgumentError,
      );
      expect(() => executionIdOf('2026-10-29:1', 0), throwsArgumentError);
      expect(() => executionIdOf('2026-10-29:1#2', 3), throwsArgumentError);
    });
  });

  group('델타', () {
    test('처음 본 체결 = 누적 그대로 한 행 · 단가 = 금액 ÷ 수량', () {
      final List<FillDelta> out = fillDeltas(<DailyFillRow>[
        _row('1', cum: 1, amount: '173312'),
      ], const <String, RecordedFill>{});
      final FillDelta f = out.single;
      expect(f.executionId, '2026-10-29:1#1');
      expect(f.quantity, 1);
      expect(f.price, _d('173312'));
      expect(f.cumulativeQuantity, 1);
      expect(f.cumulativeAmount, _d('173312'));
    });

    test('🔴 같은 누적은 행을 만들지 않는다(다시 조회해도 멱등)', () {
      final Map<String, RecordedFill> rec = <String, RecordedFill>{
        '2026-10-29:1': RecordedFill(1, _d('173312')),
      };
      expect(
        fillDeltas(<DailyFillRow>[_row('1', cum: 1, amount: '173312')], rec),
        isEmpty,
      );
    });

    test('누적이 늘면 늘어난 만큼만 · 단가 = Δ금액 ÷ Δ수량', () {
      final Map<String, RecordedFill> rec = <String, RecordedFill>{
        '2026-10-29:1': RecordedFill(1, _d('173312')),
      };
      final FillDelta f = fillDeltas(<DailyFillRow>[
        _row('1', cum: 3, amount: '519946'),
      ], rec).single;
      expect(f.executionId, '2026-10-29:1#3');
      expect(f.quantity, 2);
      expect(f.price, _d('173317')); // (519946 − 173312) ÷ 2
    });

    test('나누어떨어지지 않으면 Decimal 나눗셈(유효숫자 28)', () {
      final FillDelta f = fillDeltas(<DailyFillRow>[
        _row('1', cum: 3, amount: '100'),
      ], const <String, RecordedFill>{}).single;
      expect(f.price, divide(_d('100'), _d('3')));
    });

    test('취소 행 · 미체결(누적 0) · 누적 감소는 행이 없다', () {
      final List<FillDelta> out = fillDeltas(
        <DailyFillRow>[
          _row('9', cum: 1, amount: '1000', cancel: true),
          _row('2', remaining: 1),
          _row('3', cum: 1, amount: '1000'),
        ],
        <String, RecordedFill>{'2026-10-29:3': RecordedFill(2, _d('2000'))},
      );
      expect(out, isEmpty);
    });

    test('취소 행은 원주문과 같은 번호여도 «중복»으로 세지 않는다', () {
      final List<FillDelta> out = fillDeltas(<DailyFillRow>[
        _row('1', cum: 1, amount: '173312'),
        _row('1', cancel: true),
      ], const <String, RecordedFill>{});
      expect(out, hasLength(1));
    });

    test('여러 주문 · 행 순서를 지킨다 · 매도 방향도 그대로', () {
      final List<FillDelta> out = fillDeltas(<DailyFillRow>[
        _row('3', cum: 1, amount: '173317', side: OrderSide.sell),
        _row('4', cum: 1, amount: '173312'),
      ], const <String, RecordedFill>{});
      expect(
        out.map((FillDelta f) => (f.executionId, f.side)),
        <(String, OrderSide)>[
          ('2026-10-29:3#1', OrderSide.sell),
          ('2026-10-29:4#1', OrderSide.buy),
        ],
      );
    });
  });

  group('🔴 앞뒤가 안 맞으면 StateError(만들지도 조용히 버리지도 않는다)', () {
    test('수량이 늘었는데 금액이 늘지 않았다', () {
      expect(
        () => fillDeltas(
          <DailyFillRow>[_row('1', cum: 2, amount: '173312')],
          <String, RecordedFill>{'2026-10-29:1': RecordedFill(1, _d('173312'))},
        ),
        throwsStateError,
      );
      expect(
        () => fillDeltas(<DailyFillRow>[
          _row('1', cum: 1),
        ], const <String, RecordedFill>{}),
        throwsStateError,
      );
    });

    test('한 조회에 같은 주문번호 원주문 행이 둘', () {
      expect(
        () => fillDeltas(<DailyFillRow>[
          _row('1', cum: 1, amount: '1'),
          _row('1', cum: 1, amount: '1'),
        ], const <String, RecordedFill>{}),
        throwsStateError,
      );
    });

    test('누적 값이 음수', () {
      expect(
        () => fillDeltas(<DailyFillRow>[
          _row('1', cum: -1),
        ], const <String, RecordedFill>{}),
        throwsStateError,
      );
    });
  });
}
