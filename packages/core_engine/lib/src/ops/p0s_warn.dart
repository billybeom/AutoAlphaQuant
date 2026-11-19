// P0S 일간 경고 한도 — 노출 셈(방어 · 금 · 달러 · 원화 유동성) · 판정(SAF-302 · 307 · 308) · «넘은 첫날» 알림
// (04 §1 Level 3 v2.46 · §5-3 v2.46 · 설계 13 §8 R175 · R176 · R177 · 계획서 `10_리뷰/2026-11-19_E3d_경고한도_운영배선_계획.md`).
//
// 🔴 순수 계산이다(저장 · 조회 0) — 부르는 곳 = E3d-2 일간 잡(`equity_snapshot` 안 단계).
// 🔴 셈의 분모 = 평가 잡과 같은 총자산(보유 평가 [positionsValueKrw] + 원화 현금 + 달러 현금 원화 환산) — 04 v2.8 분모.
// 🔴 경계: 302 = 하한 포함(== 통과) · 307 · 308 · 원화 유동성 = 엄격(H2 `share > 0.20` 규약 · 04 v2.30 «< 1%»).
// 🔴 경고는 주문을 막지 않는다 — 셈할 수 없으면(종가 없음 · 총자산 0 이하) [RiskCheckUnavailable] 를 던지고, 잡이 받아
//    «그날 계측 없음 · 알림 0»으로 둔다(04 v2.46 · 거부로 승격하지 않는다).
// 🔴 알림 = «넘은 첫날» 1건(엣지) — 머무는 동안 다시 내지 않는다 · 어제 계측이 없으면 «넘지 않았다»로 본다(놓치지 않게 —
//    공백 뒤 한 번 더 낼 수 있다). 26.6년 실측(`백테스트6/exp/E3d1_warn_episodes.py`): 308 걸린 날 1,269 → 엣지 66 ·
//    302 = 첫해 램프 1 · 원화 유동성 0.
// 🔵 범주 = 운영 설정의 슬리브 종목 표 한 곳([p0sExposureMap]) — 방어 = 슬리브 C 보유(채권 + 금 · 현금 · 파킹 제외) ·
//    금 = 금 ETF 전부(B 몫 + C 몫) · 달러 = 해외 기초자산 ETF 전부 + 달러 현금 · 원화 유동성 = 원화 현금 + 파킹.
// 🔵 305 는 P0S 계측 0(04 v2.46 · 판정은 `risk/warn_limits.dart` 에 보존) · 306 = 월간(E3d-3).

import 'package:decimal/decimal.dart';

import '../orders/order_draft.dart' show P0sStrategyIds;
import '../orders/reconcile.dart' show LedgerHolding;
import '../risk/limits.dart' show RiskCheckUnavailable;
import '../risk/warn_limits.dart' show WarnAction, WarnLimitIds, kWarnActions;
import '../whatif/what_if_config.dart'
    show kP0sParkingSymbol, p0sMonthEndConfig;
import 'equity_snapshot.dart' show positionsValueKrw;

/// SAF-302 방어 하한 — 넘은 첫날(P1 · 04 §5-3 v2.46 · 등재 대기 제안).
const String kDefensiveFloorAlertCode = 'DEFENSIVE_FLOOR_BREACHED';

/// SAF-308 금 총비중 — 넘은 첫날(P1 · 04 v2.27 «경고 + P1 알림»의 코드 · 등재 대기 제안).
const String kGoldShareAlertCode = 'GOLD_SHARE_HIGH';

/// SAF-307 부속 원화 유동성 < 하한 — 넘은 첫날(P2 · 등재 대기 제안).
const String kKrwLiquidityAlertCode = 'KRW_LIQUIDITY_LOW';

/// SAF-306 연 금융소득 — 과세연도 첫 초과 월 1건(P1 · 월간 · E3d-3 · 등재 대기 제안).
const String kFinancialIncomeAlertCode = 'FINANCIAL_INCOME_CAP_EXCEEDED';

/// P0S 일간 경고 문턱(값은 02 §4 · 04 §1 — 여기서 정하지 않는다).
class P0sWarnConfig {
  /// 만든다.
  const P0sWarnConfig({
    required this.minDefensivePct,
    required this.goldTotalMonitorPct,
    required this.usdBaselinePct,
    required this.krwLiquidityFloorPct,
  });

  /// SAF-302 방어 하한(`risk.min_defensive_pct` · 포함).
  final double minDefensivePct;

  /// SAF-308 금 총비중 감시선(`sleeve_c.gold_total_monitor_pct` · 엄격).
  final double goldTotalMonitorPct;

  /// SAF-307 달러 노출 계측 기준선(`risk.max_usd_exposure_pct` — 한도 아님 · 엄격).
  final double usdBaselinePct;

  /// SAF-307 부속 원화 유동성 하한(04 §1 SAF-307 행 «< 1% 기록» · 엄격).
  final double krwLiquidityFloorPct;
}

/// P0S 문턱(02 §4 `risk.min_defensive_pct` 0.10 · `sleeve_c.gold_total_monitor_pct` 0.20 ·
/// `risk.max_usd_exposure_pct` 0.50 · 04 §1 SAF-307 행 원화 유동성 1%).
P0sWarnConfig p0sWarnConfig() => const P0sWarnConfig(
  minDefensivePct: 0.10,
  goldTotalMonitorPct: 0.20,
  usdBaselinePct: 0.50,
  krwLiquidityFloorPct: 0.01,
);

/// 종목 · 슬리브 → 범주(04 §1 Level 3 v2.46).
class P0sExposureMap {
  /// 만든다.
  const P0sExposureMap({
    required this.defensiveStrategyIds,
    required this.goldSymbols,
    required this.usdUnderlyingSymbols,
    required this.parkingSymbols,
  });

  /// 방어 슬리브(보유 행의 strategy_id).
  final Set<String> defensiveStrategyIds;

  /// 금 ETF.
  final Set<String> goldSymbols;

  /// 해외 기초자산 ETF(경제적 달러 노출).
  final Set<String> usdUnderlyingSymbols;

  /// 파킹(원화 유동성에 든다).
  final Set<String> parkingSymbols;
}

/// P0S 범주 표 — 운영 설정의 슬리브 종목(B 자산 · C 채권 · C 금 · 파킹)에서 짓는다.
P0sExposureMap p0sExposureMap() {
  final m = p0sMonthEndConfig();
  return P0sExposureMap(
    defensiveStrategyIds: const <String>{P0sStrategyIds.sleeveC},
    goldSymbols: <String>{m.cGoldSymbol},
    usdUnderlyingSymbols: <String>{
      for (final (String s, _) in m.bAssets) s,
      m.cBondSymbol,
      m.cGoldSymbol,
    },
    parkingSymbols: const <String>{kP0sParkingSymbol},
  );
}

/// 그날 노출(비율 · 0~1).
class P0sExposure {
  /// 만든다.
  const P0sExposure({
    required this.totalKrw,
    required this.defensivePct,
    required this.goldSharePct,
    required this.usdExposurePct,
    required this.krwLiquidityPct,
  });

  /// 총자산(원).
  final Decimal totalKrw;

  /// SAF-302 — 방어 슬리브 보유 ÷ 총자산.
  final double defensivePct;

  /// SAF-308 — 금 ETF ÷ 총자산.
  final double goldSharePct;

  /// SAF-307 — (해외 기초자산 ETF + 달러 현금) ÷ 총자산.
  final double usdExposurePct;

  /// SAF-307 부속 — (원화 현금 + 파킹) ÷ 총자산.
  final double krwLiquidityPct;
}

double _ratio(Decimal part, Decimal total) => (part / total).toDouble();

/// 보유 · 종가 · 현금 → 노출. 🔴 수량이 0 이 아닌 종목의 종가가 없거나 0 이하 · 총자산 0 이하 = [RiskCheckUnavailable].
///
/// [cashKrw] = 평가 잡이 더하는 원화 현금(D+2 예수금) · [cashUsdKrw] = 달러 현금의 원화 환산(P0S 앱 = 0).
P0sExposure p0sExposureOf({
  required List<LedgerHolding> holdings,
  required Map<String, Decimal> closes,
  required Decimal cashKrw,
  Decimal? cashUsdKrw,
  required P0sExposureMap map,
}) {
  final Decimal usdCash = cashUsdKrw ?? Decimal.zero;
  if (cashKrw < Decimal.zero || usdCash < Decimal.zero) {
    throw const RiskCheckUnavailable('경고 계측 — 현금이 음수');
  }
  Decimal defensive = Decimal.zero;
  Decimal gold = Decimal.zero;
  Decimal usd = usdCash;
  Decimal krwLiquid = cashKrw;
  for (final LedgerHolding h in holdings) {
    if (h.quantity == 0) continue;
    final Decimal? px = closes[h.symbol];
    if (px == null || px <= Decimal.zero) {
      throw RiskCheckUnavailable('경고 계측 — 종가 없음: ${h.symbol}');
    }
    final Decimal v = px * Decimal.fromInt(h.quantity);
    if (map.defensiveStrategyIds.contains(h.strategyId)) defensive += v;
    if (map.goldSymbols.contains(h.symbol)) gold += v;
    if (map.usdUnderlyingSymbols.contains(h.symbol)) usd += v;
    if (map.parkingSymbols.contains(h.symbol)) krwLiquid += v;
  }
  final Decimal total = positionsValueKrw(holdings, closes) + cashKrw + usdCash;
  if (total <= Decimal.zero) {
    throw const RiskCheckUnavailable('경고 계측 — 총자산 0 이하');
  }
  return P0sExposure(
    totalKrw: total,
    defensivePct: _ratio(defensive, total),
    goldSharePct: _ratio(gold, total),
    usdExposurePct: _ratio(usd, total),
    krwLiquidityPct: _ratio(krwLiquid, total),
  );
}

/// 그날 판정.
class P0sDailyWarn {
  /// 만든다.
  const P0sDailyWarn({
    required this.exposure,
    required this.triggered,
    required this.actions,
    required this.krwLiquidityLow,
  });

  /// 노출.
  final P0sExposure exposure;

  /// 걸린 SAF(오름차순 — 302 · 307 · 308).
  final List<String> triggered;

  /// SAF → 조치(04 §1 표 — 302 · 308 = 경고 · 307 = 기록만).
  final Map<String, WarnAction> actions;

  /// 원화 유동성이 하한 밑(SAF-307 부속 · 엄격).
  final bool krwLiquidityLow;

  /// 302 가 걸렸나.
  bool get defensiveLow => triggered.contains(WarnLimitIds.defensiveFloor);

  /// 308 이 걸렸나.
  bool get goldHigh => triggered.contains(WarnLimitIds.goldTotal);
}

/// 04 §1 Level 3 v2.46 일간 판정(302 · 307 · 308 · 원화 유동성).
P0sDailyWarn judgeP0sDailyWarnings(P0sExposure e, P0sWarnConfig c) {
  final List<String> ids = <String>[
    if (e.defensivePct < c.minDefensivePct) WarnLimitIds.defensiveFloor,
    if (e.usdExposurePct > c.usdBaselinePct) WarnLimitIds.usdExposure,
    if (e.goldSharePct > c.goldTotalMonitorPct) WarnLimitIds.goldTotal,
  ]..sort();
  return P0sDailyWarn(
    exposure: e,
    triggered: List<String>.unmodifiable(ids),
    actions: Map<String, WarnAction>.unmodifiable(<String, WarnAction>{
      for (final String id in ids) id: kWarnActions[id]!,
    }),
    krwLiquidityLow: e.krwLiquidityPct < c.krwLiquidityFloorPct,
  );
}

/// 🔴 «넘은 첫날» 알림 코드(오름차순) — [yesterday] = 어제 판정(계측 없음 = null = 넘지 않았다로 본다).
/// 307 의 기준선 초과는 알림이 없다(월간 보고 «초과 일수»).
List<String> p0sWarnEdgeAlerts({
  required P0sDailyWarn today,
  P0sDailyWarn? yesterday,
}) => <String>[
  if (today.defensiveLow && !(yesterday?.defensiveLow ?? false))
    kDefensiveFloorAlertCode,
  if (today.goldHigh && !(yesterday?.goldHigh ?? false)) kGoldShareAlertCode,
  if (today.krwLiquidityLow && !(yesterday?.krwLiquidityLow ?? false))
    kKrwLiquidityAlertCode,
]..sort();
