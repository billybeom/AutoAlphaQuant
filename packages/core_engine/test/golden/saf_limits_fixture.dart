// GV-32·GV-39 정답지의 `base_intent`·`base_state`·`cfg_risk` 를 엔진 타입으로 옮기는 하네스.
//
// 케이스는 기준값 위에 덮어쓰기(override)만 준다 — 여기서 그 규칙을 한 곳에 둔다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';

import 'golden_vectors.dart';

Decimal? _decOrNull(Object? v) => v == null ? null : asDecimal(v);
double? _dblOrNull(Object? v) => v == null ? null : asDouble(v);
int? _intOrNull(Object? v) => v == null ? null : asInt(v);
bool? _boolOrNull(Object? v) {
  if (v == null) return null;
  if (v is bool) return v;
  throw StateError('정답지에서 참·거짓을 기대했다: $v');
}

/// 기준 객체 위에 케이스 덮어쓰기를 얹는다(JSON null 도 «값을 지운다»로 덮어쓴다).
Map<String, Object?> overlay(
  Map<String, Object?> base,
  Map<String, Object?> override,
) => <String, Object?>{...base, ...override};

/// 정답지 의도 → [LimitIntent].
LimitIntent intentFrom(Map<String, Object?> j) => LimitIntent(
  side: switch (asString(j['side'])) {
    'BUY' => LimitSide.buy,
    'SELL' => LimitSide.sell,
    final String s => throw StateError('모르는 side: $s'),
  },
  isUsMarket: asString(j['market']) == 'US',
  orderType: asString(j['order_type']),
  quantity: asInt(j['quantity']),
  limitPrice: _decOrNull(j['limit_price']),
  entryPrice: _decOrNull(j['entry_price']),
  stopPrice: _decOrNull(j['stop_price']),
  isSatellite: asString(j['sleeve']) == 'satellite',
);

/// 정답지 상태 → [LimitState].
LimitState stateFrom(Map<String, Object?> j) => LimitState(
  totalEquity: _decOrNull(j['total_equity']),
  ordersToday: _intOrNull(j['orders_today']),
  riskExposureAfter: _dblOrNull(j['risk_exposure_after']),
  leverageAfter: _dblOrNull(j['leverage_after']),
  positionsAfter: _intOrNull(j['positions_after']),
  satellitePositionsAfter: _intOrNull(j['satellite_positions_after']),
  satelliteSectorCountAfter: _intOrNull(j['satellite_sector_count_after']),
  satelliteAllocation: _decOrNull(j['satellite_allocation']),
  satelliteExposure: _dblOrNull(j['satellite_exposure']),
  satelliteDeployedBefore: _decOrNull(j['satellite_deployed_before']),
  dailyPnlPct: _dblOrNull(j['daily_pnl_pct']),
  fxRateUsdKrw: _decOrNull(j['fx_rate_usdkrw']),
  strategyRegistered: _boolOrNull(j['strategy_registered']),
  tradingBlocked: _boolOrNull(j['trading_blocked']),
  journalMissing: _boolOrNull(j['journal_missing']),
  tierBUnjudged: _boolOrNull(j['tier_b_unjudged']),
);

/// GV-32 `_meta.cfg_risk` → [LimitConfig]. GV-39 는 «파일럿4 와 동일» 기본값이라 같은 값을 쓴다.
LimitConfig configFrom(Map<String, Object?> cfgRisk) {
  final Map<String, Object?> position = asObject(cfgRisk['position']);
  final Map<String, Object?> sleeve = asObject(cfgRisk['sleeve']);
  final Map<String, Object?> portfolio = asObject(cfgRisk['portfolio']);
  final Map<String, Object?> system = asObject(cfgRisk['system']);
  return LimitConfig(
    maxNotionalPct: asDouble(position['max_notional_pct']),
    riskBudgetPct: asDouble(position['risk_budget_pct']),
    satelliteMaxPositions: asInt(sleeve['satellite_max_positions']),
    satelliteMaxPerSector: asInt(sleeve['satellite_max_per_sector']),
    maxRiskExposure: asDouble(portfolio['max_risk_exposure']),
    maxLeverage: asDouble(portfolio['max_leverage']),
    maxPositions: asInt(portfolio['max_positions']),
    maxOrdersPerDay: asInt(system['max_orders_per_day']),
    maxOrderValueKrw: asDecimal(system['max_order_value_krw']),
    maxDailyLossPct: asDouble(system['max_daily_loss_pct']),
    orderTypeWhitelist: asStringList(system['order_type_whitelist']).toSet(),
  );
}
