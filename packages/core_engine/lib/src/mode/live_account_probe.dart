// simToAuto 커밋 직전 계좌 조회 어댑터 — 브로커 포트 → `LiveAccountProbe`(설계 13 §8 R98 AG9 · R103 AI6).
//
// 🔴 포트만 쓴다(네트워크 = 구현 몫) · 조회 예외 = null(그 계좌 «조회 없음» → 게이트 `PROBE_MISSING` 한 규칙).
// 🔴 보유 = 수량 > 0 종목 수(전 종목) · 예수금 = D+2 주문가능 원 단위 내림 · 오늘 활동 = 일별주문체결 행 수(취소 행 포함 — 보수).
// 🔴 조회 시각 = 부르는 쪽이 조회 전에 잡은 시각(보수 — 신선도 5분이 조회 시작부터 센다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import '../orders/fills.dart' show DailyFillRow;
import '../orders/order_path_ports.dart' show AccountBroker;
import '../orders/reconcile.dart' show BrokerBalance;
import 'sim_to_auto_commit.dart' show LiveAccountProbe;

/// 계좌 [alias] 를 [broker] 로 조회한다 — 실패 = null.
Future<LiveAccountProbe?> probeLiveAccount({
  required String alias,
  required AccountBroker broker,
  required TradeDate today,
  required DateTime fetchedAtUtc,
}) async {
  try {
    final BrokerBalance b = await broker.balance();
    final Decimal cash = await broker.orderableCashKrw();
    final List<DailyFillRow> fills = await broker.dailyFills(today);
    return LiveAccountProbe(
      alias: alias,
      holdingsCount: b.holdings.values.where((int q) => q > 0).length,
      orderableCashKrw: cash.floor().toBigInt().toInt(),
      activityToday: fills.length,
      fetchedAtUtc: fetchedAtUtc,
    );
  } on Object {
    return null;
  }
}
