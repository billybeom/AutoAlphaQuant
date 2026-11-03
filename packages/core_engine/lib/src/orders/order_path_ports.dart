// 주문 경로 포트 묶음(설계 13 §8 R42 S2) — 잡(trading_runtime)이 «원장 하나 · 계좌 브로커 하나»를 한 이름으로 받게 한다.
//
// 🔵 Dart 에는 교집합 타입이 없다 — 잡이 같은 객체를 다섯 번 받지 않게 이름을 하나 둔다. 새 메서드는 없다.

import 'carry_over.dart';
import 'fill_sync.dart';
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
