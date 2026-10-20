// 리스크 한도 판정 + 동시 발동 우선순위 — `06_시스템설계/04_안전장치.md` §1 · §1-5(P1~P6) · fail-closed.
// 05 GV-32(AC-S17) · GV-39(P2 검사 순서 trace) · GV-17(AC-S14).
//
// 참조 구현 = `08_파일럿/파일럿4/impl/qtrade/risk/limits.py`(GV-32 생성기) — 평가 순서는 그대로 두고
// v2.23 의 `trace` 관측면(GV-39 · 파일럿5 생성기)을 더했다.
//
// 🔴 P1 거부 계열이 축소 계열보다 항상 우선 · P2 검사 순서 L4 → L3 → L2 → L1(레벨 안 ID 오름차순,
//    단 L1 은 101 → 103 → 102 → 104) · P3 거부 판정은 원 요청 수량으로 · P4 축소가 여럿이면 min ·
//    P5 축소 후 qty < 1 이면 SKIPPED(SAF-207 게이트 닫힘은 예외 — REJECTED + ALERT) ·
//    P6 판정에 필요한 입력이 하나라도 null 이면 [RiskCheckUnavailable](기본값·대체값 금지).
// 🔴 금액은 Decimal 이다(01 §0). 참조 구현의 `+ 1e-9` 여유는 float 잡음을 덮으려던 것이라 Decimal 에서는
//    정확 비교로 같은 결과가 된다.
// ⚠️ 적용 범위(설계 13 §8 R10): 참조 구현·정답지(GV-39 g05)는 SAF-101·102·103 을 **슬리브 구분 없이
//    모든 매수**에 건다 — P0S 의 ETF 주문(손절가 없음 · 슬리브 B 42%)에 그대로 쓰면 매수가 막힌다.
//    이 파일은 정답지대로 두고, 어느 주문이 이 판정을 지나는지는 주문 경로(E10) 전에 정한다.

import 'package:decimal/decimal.dart';

import '../decimal_rules.dart';

/// 한도를 확인할 수 없다 — 주문을 거부하라(NR-4 · 04 §1 fail-closed). 조용한 거부가 아니라 예외다.
class RiskCheckUnavailable implements Exception {
  /// 예외를 만든다.
  const RiskCheckUnavailable(this.message);

  /// 사유.
  final String message;

  @override
  String toString() => 'RiskCheckUnavailable: $message';
}

/// 주문 방향.
enum LimitSide {
  /// 매수.
  buy('BUY'),

  /// 매도.
  sell('SELL');

  const LimitSide(this.code);

  /// 저장·골든 표기.
  final String code;
}

/// 판정 결과 상태(04 §1 v1.5 표 — 새 값 금지).
enum LimitStatus {
  /// 통과(축소됐을 수 있다).
  allow('ALLOW'),

  /// 거부.
  rejected('REJECTED'),

  /// 수량 0 등 사전 검증 탈락.
  skipped('SKIPPED');

  const LimitStatus(this.code);

  /// 저장·골든 표기.
  final String code;
}

/// 한도 판정에 들어가는 주문 의도.
class LimitIntent {
  /// 의도를 만든다.
  const LimitIntent({
    required this.side,
    required this.isUsMarket,
    required this.orderType,
    required this.quantity,
    required this.limitPrice,
    required this.entryPrice,
    required this.stopPrice,
    required this.isSatellite,
  });

  /// 방향.
  final LimitSide side;

  /// 미국 시장 주문이면 true — 환율이 필요하다.
  final bool isUsMarket;

  /// 주문 유형(SAF-404 화이트리스트 대상).
  final String orderType;

  /// 요청 수량.
  final int quantity;

  /// 지정가(없으면 [entryPrice] 를 단가로 쓴다).
  final Decimal? limitPrice;

  /// 진입가.
  final Decimal? entryPrice;

  /// 손절가.
  final Decimal? stopPrice;

  /// 새틀라이트 슬리브 주문이면 true — L2(SAF-203·206·207)가 걸린다.
  final bool isSatellite;
}

/// 한도 판정 입력 상태. 🔴 확보하지 못한 값은 null 로 둔다(기본값 금지 — 02 §3-1 v1.5).
class LimitState {
  /// 상태를 만든다.
  const LimitState({
    required this.totalEquity,
    required this.ordersToday,
    required this.riskExposureAfter,
    required this.leverageAfter,
    required this.positionsAfter,
    required this.satellitePositionsAfter,
    required this.satelliteSectorCountAfter,
    required this.satelliteAllocation,
    required this.satelliteExposure,
    required this.satelliteDeployedBefore,
    required this.dailyPnlPct,
    required this.fxRateUsdKrw,
    required this.strategyRegistered,
    required this.tradingBlocked,
    required this.journalMissing,
    required this.tierBUnjudged,
  });

  /// 총자산(원).
  final Decimal? totalEquity;

  /// 오늘 이미 낸 주문 수.
  final int? ordersToday;

  /// 주문 후 위험자산 익스포저 비율.
  final double? riskExposureAfter;

  /// 주문 후 레버리지.
  final double? leverageAfter;

  /// 주문 후 동시 보유 종목 수.
  final int? positionsAfter;

  /// 주문 후 새틀라이트 종목 수.
  final int? satellitePositionsAfter;

  /// 주문 종목 섹터의 새틀라이트 종목 수(주문 포함).
  final int? satelliteSectorCountAfter;

  /// 새틀라이트 배정액(원).
  final Decimal? satelliteAllocation;

  /// 익스포저 게이트 값 0~1.
  final double? satelliteExposure;

  /// 주문 전 새틀라이트 전개액(원).
  final Decimal? satelliteDeployedBefore;

  /// 오늘 손익률.
  final double? dailyPnlPct;

  /// 원/달러 환율.
  final Decimal? fxRateUsdKrw;

  /// 전략 상태가 등록돼 있는가(SAF-406).
  final bool? strategyRegistered;

  /// 매매 차단 플래그(대사 불일치 등 — SAF-407).
  final bool? tradingBlocked;

  /// 이탈 저널 미작성(SAF-408).
  final bool? journalMissing;

  /// 계층 B 월간 판정 누락(SAF-410).
  final bool? tierBUnjudged;
}

/// 한도 설정(02 §4 `risk.*` — 값은 config 에서 온다).
class LimitConfig {
  /// 설정을 만든다.
  const LimitConfig({
    required this.maxNotionalPct,
    required this.riskBudgetPct,
    required this.satelliteMaxPositions,
    required this.satelliteMaxPerSector,
    required this.maxRiskExposure,
    required this.maxLeverage,
    required this.maxPositions,
    required this.maxOrdersPerDay,
    required this.maxOrderValueKrw,
    required this.maxDailyLossPct,
    required this.orderTypeWhitelist,
  });

  /// SAF-101 종목당 명목 상한(총자산 대비).
  final double maxNotionalPct;

  /// SAF-102 종목당 리스크 예산(총자산 대비).
  final double riskBudgetPct;

  /// SAF-203.
  final int satelliteMaxPositions;

  /// SAF-206.
  final int satelliteMaxPerSector;

  /// SAF-301.
  final double maxRiskExposure;

  /// SAF-303.
  final double maxLeverage;

  /// SAF-304.
  final int maxPositions;

  /// SAF-401.
  final int maxOrdersPerDay;

  /// SAF-402(원).
  final Decimal maxOrderValueKrw;

  /// SAF-403 — 🔴 **양수**로 적고 판정은 `daily_pnl <= −값`(04 §1-5 부속 규칙).
  final double maxDailyLossPct;

  /// SAF-404.
  final Set<String> orderTypeWhitelist;
}

/// 한도 판정 결과(04 §1-5 `LimitCheckResult`).
class LimitCheckResult {
  /// 결과를 만든다.
  const LimitCheckResult({
    required this.status,
    required this.violated,
    required this.adjustedQuantity,
    required this.reductions,
    required this.alert,
  });

  /// 상태.
  final LimitStatus status;

  /// ALLOW 만 true.
  bool get allowed => status == LimitStatus.allow;

  /// 위반 ID 전부(오름차순 · 거부·축소 구분 없이 — 감사용).
  final List<String> violated;

  /// ALLOW: 최종 수량 · SKIPPED: 0 · REJECTED: null.
  final int? adjustedQuantity;

  /// 축소 계열별 개별 계산값(로그용).
  final Map<String, int> reductions;

  /// 🔴 ALERT 를 동반해야 하는 거부(SAF-207 게이트 닫힘 — 발주자 결정 SA-11 2-b).
  final bool alert;
}

const Set<String> _rejectIds = <String>{
  'SAF-103',
  'SAF-203',
  'SAF-206',
  'SAF-301',
  'SAF-303',
  'SAF-304',
  'SAF-401',
  'SAF-402',
  'SAF-403',
  'SAF-404',
  'SAF-406',
  'SAF-407',
  'SAF-408',
  'SAF-410',
};

/// 04 §1-5 `check_all_limits`. [trace] 를 넘기면 **평가를 시작한** SAF ID 를 순서대로 덧붙인다(GV-39) —
/// [RiskCheckUnavailable] 경로에서도 부분 trace 가 남고 마지막 원소가 입력이 없던 검사다.
LimitCheckResult checkAllLimits(
  LimitIntent intent,
  LimitState state,
  LimitConfig config, {
  List<String>? trace,
}) {
  try {
    return _check(intent, state, config, trace ?? <String>[]);
  } on RiskCheckUnavailable {
    rethrow;
  } on Object catch (e) {
    // 🔴 예외를 삼키고 통과시키지 않는다.
    throw RiskCheckUnavailable('한도 확인 불가: $e');
  }
}

T _require<T extends Object>(T? value, String name) {
  if (value == null) throw RiskCheckUnavailable('입력 누락: $name');
  return value;
}

LimitCheckResult _check(
  LimitIntent it,
  LimitState st,
  LimitConfig cfg,
  List<String> trace,
) {
  final bool isBuy = it.side == LimitSide.buy;

  // ── 프렐류드 — 여기서 실패하면 trace 는 비어 있다.
  final Decimal? price = it.limitPrice ?? it.entryPrice;
  if (price == null || price <= Decimal.zero) {
    throw const RiskCheckUnavailable('가격 없음');
  }
  final Decimal fx = it.isUsMarket
      ? _require(st.fxRateUsdKrw, 'fx_rate_usdkrw')
      : Decimal.one;
  final Decimal equity = _require(st.totalEquity, 'total_equity');
  final Decimal unitKrw = price * fx;
  final Decimal orderValueKrw = Decimal.fromInt(it.quantity) * unitKrw;

  final List<String> violated = <String>[];
  final Map<String, int> reductions = <String, int>{};
  bool gateClosed = false;

  void start(String id) => trace.add(id);

  // ── Level 4 시스템 ──────────────────────────────────────────────────
  start('SAF-401');
  if (_require(st.ordersToday, 'orders_today') + 1 > cfg.maxOrdersPerDay) {
    violated.add('SAF-401');
  }
  start('SAF-402');
  if (orderValueKrw > cfg.maxOrderValueKrw) violated.add('SAF-402');
  if (isBuy) {
    start('SAF-403');
    if (_require(st.dailyPnlPct, 'daily_pnl_pct') <= -cfg.maxDailyLossPct) {
      violated.add('SAF-403');
    }
  }
  start('SAF-404');
  if (!cfg.orderTypeWhitelist.contains(it.orderType)) violated.add('SAF-404');
  start('SAF-406');
  if (_require(st.strategyRegistered, 'strategy_registered') == false) {
    violated.add('SAF-406');
  }
  start('SAF-407');
  if (_require(st.tradingBlocked, 'trading_blocked')) violated.add('SAF-407');
  if (isBuy) {
    start('SAF-408');
    if (_require(st.journalMissing, 'journal_missing')) violated.add('SAF-408');
    start('SAF-410');
    if (_require(st.tierBUnjudged, 'tier_b_unjudged')) violated.add('SAF-410');
  }

  // ── Level 3 포트폴리오 ──────────────────────────────────────────────
  if (isBuy) {
    start('SAF-301');
    if (_require(st.riskExposureAfter, 'risk_exposure_after') >
        cfg.maxRiskExposure) {
      violated.add('SAF-301');
    }
  }
  start('SAF-303');
  if (_require(st.leverageAfter, 'leverage_after') > cfg.maxLeverage) {
    violated.add('SAF-303');
  }
  if (isBuy) {
    start('SAF-304');
    if (_require(st.positionsAfter, 'positions_after') > cfg.maxPositions) {
      violated.add('SAF-304');
    }
  }

  // ── Level 2 슬리브(새틀라이트 매수만) ────────────────────────────────
  if (it.isSatellite && isBuy) {
    start('SAF-203');
    if (_require(st.satellitePositionsAfter, 'satellite_positions_after') >
        cfg.satelliteMaxPositions) {
      violated.add('SAF-203');
    }
    start('SAF-206');
    if (_require(st.satelliteSectorCountAfter, 'satellite_sector_count_after') >
        cfg.satelliteMaxPerSector) {
      violated.add('SAF-206');
    }
    start('SAF-207');
    final Decimal allocation = _require(
      st.satelliteAllocation,
      'satellite_allocation',
    );
    final double exposure = _require(
      st.satelliteExposure,
      'satellite_exposure',
    );
    final Decimal deployed = _require(
      st.satelliteDeployedBefore,
      'satellite_deployed_before',
    );
    final Decimal room =
        multiply(allocation, promoteRatio(exposure)) - deployed;
    if (room <= Decimal.zero) {
      // 🔴 게이트 닫힘(BEAR 등)에서 들어온 매수 의도는 시그널 층 결함 신호 — 축소가 아니라 거부 + ALERT.
      violated.add('SAF-207');
      gateClosed = true;
    } else if (orderValueKrw > room) {
      violated.add('SAF-207');
      reductions['SAF-207'] = _floorDiv(room, unitKrw);
    }
  }

  // ── Level 1 종목(매수만 · 104 는 전부) ──────────────────────────────
  if (isBuy) {
    start('SAF-101');
    final Decimal capNotional = multiply(
      equity,
      promoteRatio(cfg.maxNotionalPct),
    );
    if (orderValueKrw > capNotional) {
      violated.add('SAF-101');
      reductions['SAF-101'] = _floorDiv(capNotional, unitKrw);
    }
    start('SAF-103');
    final Decimal entry = _require(it.entryPrice, 'entry_price');
    final Decimal stop = _require(it.stopPrice, 'stop_price');
    if (!(stop < entry && entry > Decimal.zero && stop > Decimal.zero)) {
      violated.add('SAF-103');
    } else {
      // 102 의 risk_per_share 는 103 통과를 전제한다 — 103 위반이면 102 를 평가하지 않는다.
      start('SAF-102');
      final Decimal riskPerShare = (entry - stop) * fx;
      final Decimal capRisk = multiply(equity, promoteRatio(cfg.riskBudgetPct));
      if (Decimal.fromInt(it.quantity) * riskPerShare > capRisk) {
        violated.add('SAF-102');
        reductions['SAF-102'] = _floorDiv(capRisk, riskPerShare);
      }
    }
  }
  start('SAF-104');
  if (it.quantity < 1) violated.add('SAF-104');

  final List<String> sorted = violated.toSet().toList()..sort();
  final bool rejected =
      gateClosed || sorted.any((String id) => _rejectIds.contains(id));
  if (rejected) {
    // P1 · P3 — 축소를 적용하지 않는다.
    return LimitCheckResult(
      status: LimitStatus.rejected,
      violated: sorted,
      adjustedQuantity: null,
      reductions: reductions,
      alert: gateClosed,
    );
  }
  if (sorted.contains('SAF-104')) {
    return LimitCheckResult(
      status: LimitStatus.skipped,
      violated: sorted,
      adjustedQuantity: 0,
      reductions: reductions,
      alert: false,
    );
  }
  if (reductions.isNotEmpty) {
    final int q = reductions.values.reduce((int a, int b) => a < b ? a : b);
    if (q < 1) {
      // P5 — 축소 후 0주면 SKIPPED(거부가 아니다).
      return LimitCheckResult(
        status: LimitStatus.skipped,
        violated: <String>{...sorted, 'SAF-104'}.toList()..sort(),
        adjustedQuantity: 0,
        reductions: reductions,
        alert: false,
      );
    }
    return LimitCheckResult(
      status: LimitStatus.allow,
      violated: sorted,
      adjustedQuantity: q,
      reductions: reductions,
      alert: false,
    );
  }
  return LimitCheckResult(
    status: LimitStatus.allow,
    violated: const <String>[],
    adjustedQuantity: it.quantity,
    reductions: const <String, int>{},
    alert: false,
  );
}

/// floor(a / b) — 수량 계산(03 §0-4 «수량은 내림 후 정수»). 음수는 0 으로.
int _floorDiv(Decimal a, Decimal b) {
  final int q = divide(a, b).floor().toBigInt().toInt();
  return q < 0 ? 0 : q;
}
