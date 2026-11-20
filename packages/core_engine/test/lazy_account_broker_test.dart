// E11q-c1d — 처음 쓸 때 만드는 계좌 브로커(설계 13 §8 R207 · 실전 개시).
//
// 🔴 만들기 = 처음 부를 때 한 번(현금만 읽는 회차가 다른 계좌 키를 요구하지 않게) · 다섯 포트가 그대로 넘어간다 ·
//    만들기 실패 = 그 호출이 그 오류로 던진다(조용히 0원 · 빈 잔고로 돌지 않는다).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart' show FakeOrderBroker;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;
import 'package:test/test.dart';

void main() {
  late FakeOrderBroker inner;
  late int makes;
  late LazyAccountBroker lazy;

  setUp(() {
    inner = FakeOrderBroker(cashKrw: Decimal.parse('1234567'))
      ..holdings['069500'] = 3;
    makes = 0;
    lazy = LazyAccountBroker(() async {
      makes++;
      return inner;
    });
  });

  test('🔴 만들기 = 처음 부를 때 한 번 · 만들기만으로는 브로커를 부르지 않는다', () async {
    expect(makes, 0);
    expect(await lazy.orderableCashKrw(), Decimal.parse('1234567'));
    expect(makes, 1);
    await lazy.orderableCashKrw();
    await lazy.balance();
    expect(makes, 1);
    expect((inner.cashReads, inner.balanceReads), (2, 1));
  });

  test('다섯 포트가 그대로 넘어간다(주문 · 취소 · 체결 · 예수금 · 잔고)', () async {
    final BrokerSubmitResult s = await lazy.submit(
      BrokerOrderRequest(
        symbol: '069500',
        side: OrderSide.buy,
        quantity: 1,
        orderType: OrderTypes.limit,
        limitPrice: Decimal.parse('35000'),
      ),
    );
    expect(s, isA<BrokerAccepted>());
    expect(inner.submitted.single.symbol, '069500');
    await lazy.cancel('0000000001');
    expect(inner.cancelled, <String>['0000000001']);
    expect(await lazy.dailyFills(const TradeDate('2026-11-02')), isEmpty);
    expect(inner.fillReads, 1);
    final BrokerBalance b = await lazy.balance();
    expect(b.holdings, <String, int>{'069500': 3});
    expect(b.cashKrw, Decimal.parse('1234567'));
    expect(makes, 1);
  });

  test('🔴 만들기 실패 = 그 호출이 그 오류로 던진다(0원으로 돌지 않는다) · 다시 만들지 않는다', () async {
    final LazyAccountBroker failing = LazyAccountBroker(() async {
      makes++;
      throw StateError('키 없음(시험)');
    });
    await expectLater(failing.orderableCashKrw(), throwsA(isA<StateError>()));
    await expectLater(failing.balance(), throwsA(isA<StateError>()));
    expect(makes, 1);
  });
}
