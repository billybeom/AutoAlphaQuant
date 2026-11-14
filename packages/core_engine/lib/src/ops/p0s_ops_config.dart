// P0S 운영 설정 원천(E11p3b-1 · 설계 13 §8 R90 · 정본 = 06 04_안전장치 §1 · 02 §4 · 03 §5-3).
//
// 🔴 SPEC 값만 옮겨 적는다:
//    · 한도 = 04 §1 SAF-101 5% · 102 0.35% · 203 8 · 206 3 · 301 85% · 303 1.0 · 304 30 · 401 60 · 402 2,000만 ·
//      403 −3%(양수로 적는다) · 404 [LIMIT, MARKET].
//    · 체결 비용 = 02 §4 `costs.kr` 수수료 0.015% · 국내 ETF 매도세 0.
//    · 지정가 여유 = `seasonality.limit_offset_pct` 0.005(03 §5-3).
//    · 월말 · 계절 A · 브레이커 = 이미 있는 P0S 기본판(`p0sMonthEndConfig` · `SeasonalAConfig()` · `p0sBreakerConfig`).
// 🔴 사람 값(슬리브 A 종목 · 전략 → 계좌 별칭)은 **기본값 없는 필수 입력**이다 — lib 에 리터럴 0
//    (체크리스트 P0-① · P0-② ⬜ · 02 §2-4 v2.38 계좌 대응표 «설정값으로 두고 코드 상수 금지»).
// 🔴 P0S 는 ETF 만 산다 → 계획 종목 + 슬리브 A 종목 = 전부 `ETF`(04 §1 v2.38 — 칸이 비면 개별주로 보아 L1 이 매수를 막는다).
// 🔵 R90 결정: 매수 비용률 = 수수료 + 슬리피지 0.00115(월말 계획기와 같은 값 — 예수금을 넘지 않게 보수적) ·
//    국면 지문 = SPEC 판 + 파이프라인 이름(국면 상수는 코드 `regime_pipeline` 에 있다 · 판이 바뀌면 바뀐다).

import 'package:decimal/decimal.dart';

import '../orders/fill_sync.dart' show FillCostRates;
import '../orders/order_draft.dart'
    show DraftConfig, OrderTypes, P0sStrategyIds;
import '../portfolio/month_end_plan.dart' show MonthEndConfig;
import '../portfolio/seasonal_a.dart' show SeasonalAConfig;
import '../risk/breaker.dart' show BreakerConfig;
import '../risk/limits.dart' show InstrumentKind, LimitConfig;
import '../whatif/what_if_config.dart' show p0sKrPlanSymbols, p0sMonthEndConfig;
import 'config_fingerprint.dart';
import 'equity_snapshot.dart' show p0sBreakerConfig;

/// 지문에 들어가는 SPEC 판(판이 바뀌면 지문도 바뀐다).
const String kP0sConfigSpecVersion = 'v2.44';

/// 지정가 여유(`seasonality.limit_offset_pct` · 03 §5-3).
const double kP0sLimitOffsetPct = 0.005;

/// 매수 비용률(R90 — 수수료 0.015% + 슬리피지 0.10% · 월말 계획기 비용과 같다).
const double kP0sBuyCostRate = 0.00115;

/// 체결 비용(02 §4 `costs.kr` — 수수료 0.015% · 국내 ETF 매도세 0).
const FillCostRates kP0sFillCostRates = FillCostRates(
  commissionRate: 0.00015,
  sellTaxRate: 0,
);

/// 계좌 대응이 있어야 하는 전략(02 §2-4 v2.38 대응표 — 입금 `P0S` 는 계좌별 행이라 빠진다).
const List<String> kP0sMappedStrategies = <String>[
  P0sStrategyIds.sleeveA,
  P0sStrategyIds.sleeveB,
  P0sStrategyIds.sleeveC,
  P0sStrategyIds.pot,
];

final RegExp _krSymbol = RegExp(r'^[0-9A-Z]{6}$');

/// 한도(04 §1 SAF-101~404).
LimitConfig p0sLimitConfig() => LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: Decimal.fromInt(20000000),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
);

/// 사람 값(체크리스트 P0-① · P0-② — 발주자가 정한다).
class P0sHumanInputs {
  /// 만든다 — 🔴 [aSymbol] = KR 6자리 · [accountByStrategy] = `kP0sMappedStrategies` 넷 정확히(빈 별칭 금지).
  P0sHumanInputs({
    required this.aSymbol,
    required Map<String, String> accountByStrategy,
  }) : accountByStrategy = Map<String, String>.unmodifiable(accountByStrategy) {
    if (!_krSymbol.hasMatch(aSymbol)) {
      throw ArgumentError.value(aSymbol, 'aSymbol', 'KR 6자리 종목 코드가 아니다');
    }
    final Set<String> want = kP0sMappedStrategies.toSet();
    final Set<String> got = accountByStrategy.keys.toSet();
    if (got.length != want.length || !got.containsAll(want)) {
      throw ArgumentError.value(
        accountByStrategy.keys.toList(),
        'accountByStrategy',
        '전략 → 계좌는 ${kP0sMappedStrategies.join(' · ')} 넷이어야 한다',
      );
    }
    for (final MapEntry<String, String> e in accountByStrategy.entries) {
      if (e.value.trim().isEmpty) {
        throw ArgumentError.value(e.value, e.key, '계좌 별칭이 비었다');
      }
    }
  }

  /// 슬리브 A 종목.
  final String aSymbol;

  /// 전략 → 계좌 별칭.
  final Map<String, String> accountByStrategy;
}

/// P0S 운영 설정 — 잡 · 주문 경로가 받는 설정 묶음 + 지문.
class P0sOpsConfig {
  P0sOpsConfig._(this.human)
    : limits = p0sLimitConfig(),
      monthEnd = p0sMonthEndConfig(),
      seasonalA = const SeasonalAConfig(),
      breaker = p0sBreakerConfig();

  /// [human] 으로 만든다.
  factory P0sOpsConfig.of(P0sHumanInputs human) => P0sOpsConfig._(human);

  /// 사람 값.
  final P0sHumanInputs human;

  /// 한도.
  final LimitConfig limits;

  /// 월말 계획기.
  final MonthEndConfig monthEnd;

  /// 계절 A.
  final SeasonalAConfig seasonalA;

  /// 브레이커.
  final BreakerConfig breaker;

  /// 체결 비용.
  FillCostRates get fillCosts => kP0sFillCostRates;

  /// 매수 비용률(예수금 축소 · 금액 → 주수).
  double get buyCostRate => kP0sBuyCostRate;

  /// 초안 설정.
  DraftConfig get draft => DraftConfig(
    limitOffsetPct: kP0sLimitOffsetPct,
    buyCostRate: kP0sBuyCostRate,
    accountByStrategy: human.accountByStrategy,
  );

  /// 슬리브 A 종목.
  String get aSymbol => human.aSymbol;

  /// 연금 계좌 별칭(= 슬리브 B 의 계좌 · 02 §2-4 ✅).
  String get pensionAlias => human.accountByStrategy[P0sStrategyIds.sleeveB]!;

  /// KR 계획 종목 전부(계획 종목 + 슬리브 A) — 오름차순.
  List<String> get krSymbols =>
      (<String>{...p0sKrPlanSymbols(), human.aSymbol}.toList()..sort());

  /// 🆕 E11p3b-2(R91) — 위험 종목(SAF-301 분자) = 슬리브 A + 슬리브 B 의 주식 자산(금 = 방어 쪽 · C 와 같은 종목) ·
  /// 채권 · 파킹 · 금 · 현금은 넣지 않는다.
  Set<String> get riskSymbols => <String>{
    human.aSymbol,
    for (final (String s, _) in monthEnd.bAssets)
      if (s != monthEnd.cGoldSymbol) s,
  };

  /// 상품 구분 — P0S 는 전부 ETF.
  Map<String, InstrumentKind> get instruments => <String, InstrumentKind>{
    for (final String s in krSymbols) s: InstrumentKind.etf,
  };

  /// 지문에 들어가는 내용(운영 파라미터 제외).
  Map<String, Object?> content() => <String, Object?>{
    'spec': kP0sConfigSpecVersion,
    'accounts': human.accountByStrategy,
    'sleeve_a_symbol': human.aSymbol,
    'instruments': <String, Object?>{
      for (final MapEntry<String, InstrumentKind> e in instruments.entries)
        e.key: e.value.code,
    },
    'limits': <String, Object?>{
      'max_notional_pct': limits.maxNotionalPct,
      'risk_budget_pct': limits.riskBudgetPct,
      'satellite_max_positions': limits.satelliteMaxPositions,
      'satellite_max_per_sector': limits.satelliteMaxPerSector,
      'max_risk_exposure': limits.maxRiskExposure,
      'max_leverage': limits.maxLeverage,
      'max_positions': limits.maxPositions,
      'max_orders_per_day': limits.maxOrdersPerDay,
      'max_order_value_krw': limits.maxOrderValueKrw,
      'max_daily_loss_pct': limits.maxDailyLossPct,
      'order_type_whitelist': limits.orderTypeWhitelist.toList()..sort(),
    },
    'costs': <String, Object?>{
      'commission_rate': fillCosts.commissionRate,
      'sell_tax_rate': fillCosts.sellTaxRate,
      'buy_cost_rate': buyCostRate,
    },
    'draft': <String, Object?>{'limit_offset_pct': kP0sLimitOffsetPct},
    'month_end': _monthEndContent(monthEnd),
    'seasonal_a': <String, Object?>{
      'entry_month': seasonalA.entryMonth,
      'exit_month': seasonalA.exitMonth,
      'gate_score': seasonalA.gateScore,
      'defer_max': seasonalA.deferMax,
      'ramp_months': seasonalA.rampMonths,
      'split_days': seasonalA.splitDays,
    },
    'breaker': <String, Object?>{
      'alert_dd': breaker.alertDd,
      'reduce_dd': breaker.reduceDd,
      'halt_dd': breaker.haltDd,
      'stop_dd': breaker.stopDd,
      'alert_release_dd': breaker.alertReleaseDd,
      'reduce_release_dd': breaker.reduceReleaseDd,
      'halt_release_dd': breaker.haltReleaseDd,
      'recover_hold_bars': breaker.recoverHoldBars,
      'halt_release_bull_streak': breaker.haltReleaseBullStreak,
      'stop_release_dd': breaker.stopReleaseDd,
      'stop_release_bull_streak': breaker.stopReleaseBullStreak,
    },
  };

  /// 🔴 설정 지문(`config_hash` — 주문 · 결정 기록에 붙는다 · SAF-405 승인 단위).
  String get configHash => configFingerprint(content());

  /// 국면 설정 지문(R90 — SPEC 판 + 파이프라인 이름 · = [p0sRegimeConfigHash]).
  String get regimeConfigHash => p0sRegimeConfigHash();
}

/// 🆕 E11p3c-1 — 국면 설정 지문(R90 — SPEC 판 + 파이프라인 이름). 🔴 사람 값(A 종목 · 계좌)이 들지 않는다 —
/// 사람 값이 정해지기 전에도 `daily_signal` 이 같은 지문으로 국면을 쌓는다.
String p0sRegimeConfigHash() => configFingerprint(<String, Object?>{
  'spec': kP0sConfigSpecVersion,
  'regime_pipeline': 'computeRegime',
});

Map<String, Object?> _monthEndContent(MonthEndConfig m) => <String, Object?>{
  'alloc_b': m.allocB,
  'core_band': m.coreBand,
  'ramp_months': m.rampMonths,
  'b_assets': <Object?>[
    for (final (String s, Decimal w) in m.bAssets) <Object?>[s, w],
  ],
  'lookback_months': m.lookbackMonths,
  'assist': <String, Object?>{
    'floor': m.assist.floor,
    'cut_state': m.assist.cutState?.code,
    'cut': m.assist.cut,
  },
  'c_bond_symbol': m.cBondSymbol,
  'c_gold_symbol': m.cGoldSymbol,
  'c_bond_weight': m.cBondWeight,
  'c_gold_weight': m.cGoldWeight,
  'max_gold_pct_of_total': m.maxGoldPctOfTotal,
  'c_relative_band': m.cRelativeBand,
  'b_order_threshold': m.bOrderThreshold,
  'c_order_threshold': m.cOrderThreshold,
  'pot_order_threshold': m.potOrderThreshold,
  'topup_min_fraction': m.topupMinFraction,
  'krw_usable_fraction': m.krwUsableFraction,
  'pension_annual_limit': m.pensionAnnualLimit,
  'pension_funding': m.pensionFunding,
  'b_sell_cost_rate': m.bSellCostRate,
  'c_sell_cost_rate': m.cSellCostRate,
  'pot_cost_rate': m.potCostRate,
};
