// 주문 경로 포트 묶음(설계 13 §8 R42 S2) — 잡(trading_runtime)이 «원장 하나 · 계좌 브로커 하나»를 한 이름으로 받게 한다.
//
// 🔵 Dart 에는 교집합 타입이 없다 — 잡이 같은 객체를 다섯 번 받지 않게 이름을 하나 둔다. 새 메서드는 없다.
// 🆕 E11q-c1d(R207 · 실전 개시) [LazyAccountBroker] — 계좌 브로커를 처음 쓸 때 만든다(현금만 읽는 회차가 다른 계좌 키를
//    요구하지 않게 · 못 만들면 그 호출이 그 오류로 던진다 — 조용히 0원 · 빈 잔고로 돌지 않는다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import 'carry_over.dart';
import 'fill_sync.dart';
import 'fills.dart' show DailyFillRow;
import 'order_ports.dart';
import 'reconcile.dart';
import 'unknown_resolution.dart';

/// 주문 경로 원장 — 순서기 · 체결 · 이월 · 해소 · 대사 원장(구현 = data_sync `SqliteOrderLedger` · 시험 `FakeOrderLedger`).
abstract interface class OrderPathLedger
    implements
        OrderLedger,
        FillLedger,
        CarryLedger,
        UnknownLedger,
        ReconLedger {}

/// 계좌 하나의 브로커 — 주문 · 체결조회 · 예수금 · 잔고(구현 = broker_gateway `KisOrderBroker` · 시험 `FakeOrderBroker`).
abstract interface class AccountBroker
    implements OrderBroker, BrokerBalanceSource {}

/// 🆕 R207 — 처음 쓸 때 [make] 로 만드는 계좌 브로커(한 번 만들면 같은 것을 쓴다 · 실패도 그 회차 안에서는 같은 실패).
final class LazyAccountBroker implements AccountBroker {
  /// 만든다.
  LazyAccountBroker(this._make);

  final Future<AccountBroker> Function() _make;
  Future<AccountBroker>? _made;

  Future<AccountBroker> get _broker => _made ??= _make();

  @override
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request) async =>
      (await _broker).submit(request);

  @override
  Future<BrokerSubmitResult> cancel(String brokerOrderNo) async =>
      (await _broker).cancel(brokerOrderNo);

  @override
  Future<List<DailyFillRow>> dailyFills(TradeDate orderDate) async =>
      (await _broker).dailyFills(orderDate);

  @override
  Future<Decimal> orderableCashKrw() async =>
      (await _broker).orderableCashKrw();

  @override
  Future<BrokerBalance> balance() async => (await _broker).balance();
}
