// 한도 판정 규약 중 정답지(GV-32·39·17)가 직접 보지 않는 것 — 04 §1-5 P5 예외의 ALERT 표시.
//
// GV-32 정답지에는 `alert` 칸이 없다. 04 §1-5 v2.23 블록 «LimitCheckResult.alert=True 로 표시하고
// 주문 경로가 ALERT 를 보낸다» 를 여기서 고정한다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

final LimitConfig _config = LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: Decimal.parse('20000000'),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: <String>{'LIMIT', 'MARKET'},
);

LimitIntent _buy() => LimitIntent(
  side: LimitSide.buy,
  isUsMarket: false,
  orderType: 'LIMIT',
  quantity: 100,
  limitPrice: Decimal.parse('10000'),
  entryPrice: Decimal.parse('10000'),
  stopPrice: Decimal.parse('9500'),
  isSatellite: true,
);

LimitState _state({
  double exposure = 1.0,
  String deployed = '20000000',
  int orders = 10,
}) => LimitState(
  totalEquity: Decimal.parse('200000000'),
  ordersToday: orders,
  riskExposureAfter: 0.5,
  leverageAfter: 0.9,
  positionsAfter: 10,
  satellitePositionsAfter: 5,
  satelliteSectorCountAfter: 2,
  satelliteAllocation: Decimal.parse('36000000'),
  satelliteExposure: exposure,
  satelliteDeployedBefore: Decimal.parse(deployed),
  dailyPnlPct: -0.01,
  fxRateUsdKrw: Decimal.parse('1300'),
  strategyRegistered: true,
  tradingBlocked: false,
  journalMissing: false,
  tierBUnjudged: false,
);

void main() {
  test('게이트가 닫힌(BEAR) 새틀라이트 매수는 REJECTED + ALERT', () {
    final LimitCheckResult r = checkAllLimits(
      _buy(),
      _state(exposure: 0, deployed: '0'),
      _config,
    );
    expect(r.status, LimitStatus.rejected);
    expect(r.violated, <String>['SAF-207']);
    expect(r.alert, isTrue);
  });

  test('이미 초과 전개(room < 0)도 같은 거부 + ALERT', () {
    final LimitCheckResult r = checkAllLimits(
      _buy(),
      _state(deployed: '40000000'),
      _config,
    );
    expect(r.status, LimitStatus.rejected);
    expect(r.alert, isTrue);
  });

  test('다른 거부(SAF-401)에는 ALERT 표시가 붙지 않는다', () {
    final LimitCheckResult r = checkAllLimits(
      _buy(),
      _state(orders: 60),
      _config,
    );
    expect(r.status, LimitStatus.rejected);
    expect(r.violated, <String>['SAF-401']);
    expect(r.alert, isFalse);
  });

  test('통과 결과는 축소 기록이 비어 있고 ALERT 가 없다', () {
    final LimitCheckResult r = checkAllLimits(_buy(), _state(), _config);
    expect(r.allowed, isTrue);
    expect(r.adjustedQuantity, 100);
    expect(r.reductions, isEmpty);
    expect(r.alert, isFalse);
  });
}
