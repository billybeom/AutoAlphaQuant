// 슬리브 A 계절 판정 · POT 현금 재계산(설계 13 §8 R49 Q2 · Q3 · Q6 · 참조 = 시험 하네스 `ReplayEngine._seasonalCheck` ·
// `_split` · `_potDeposit` · `_potLiquidate` · S7).
//
// 🔴 판정 날 = 그 달 마지막 3 KR 세션의 첫날(부르는 쪽이 고른다) · 입력 = **직전 세션** 값(평가 · KOSDAQ 추세 점수 —
//    하네스의 same-bar 제거와 같다). 🟡 하네스는 A 평가를 그날 가격으로 쓰지만 08:00 에는 직전 종가뿐이다(기록).
// 🔴 10월 진입 — 점수 < 60(HALTED · STOPPED 아님 · 점수 있음)이면 연기 → 다음 달들 재시도 · 2번 연기 뒤 강제 · 점수 없음 = 진입.
//    진입 날 POT 를 청산한다(HALTED · STOPPED 라 사지 않는 10월에도 청산한다 — 하네스 그대로).
// 🔴 4월 청산 = A 보유 전량 · 분할은 주 단위(v2.38 정답지 · GV-30).
// 🔴 예약 원화는 S7 에서 늘 0 — POT 청산 직후 0 으로 되돌린다. 그래서 이 판은 예약을 다루지 않는다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show OrderSide;

import '../decimal_rules.dart' show divide;
import '../orders/order_draft.dart' show P0sStrategyIds;
import '../orders/order_ports.dart' show OrderBroker;
import '../orders/reconcile.dart' show LedgerHolding;
import '../risk/breaker.dart' show BreakerLevel;

/// 계절 A 설정(03 §5-3 · P0S · 하네스 `P0sConfig` · `ReplayVariant.s7`).
class SeasonalAConfig {
  /// 설정을 만든다.
  const SeasonalAConfig({
    this.entryMonth = 10,
    this.exitMonth = 4,
    this.gateScore = 60,
    this.deferMax = 2,
    this.rampMonths = 6,
    this.splitDays = 3,
  });

  /// 진입 달.
  final int entryMonth;

  /// 청산 달.
  final int exitMonth;

  /// 진입 문턱 점수(0 = 문턱 없음).
  final double gateScore;

  /// 연기 최대 횟수(넘으면 강제 진입).
  final int deferMax;

  /// 램프 달 수.
  final int rampMonths;

  /// 분할 일수.
  final int splitDays;
}

/// P0S 슬리브 A 목표 비중(0.20 · 03 §2-7-1).
final Decimal kP0sAllocA = Decimal.parse('0.20');

/// 진입을 건너뛰는 최소 차이(평가의 0.1% · 하네스 `eq * 0.001`).
final Decimal kSeasonalMinDeltaFraction = Decimal.parse('0.001');

/// 판정 결과 종류.
enum SeasonalAOutcome {
  /// 할 일 없음.
  nothing('NONE'),

  /// 진입 연기(F1_ENTRY_DEFER).
  defer('F1_ENTRY_DEFER'),

  /// 10월 진입(SEASONAL_ENTRY).
  enter('SEASONAL_ENTRY'),

  /// 연기 뒤 진입(F1_ENTRY_LATE).
  lateEnter('F1_ENTRY_LATE'),

  /// 4월 청산(SEASONAL_EXIT).
  exit('SEASONAL_EXIT'),

  /// 브레이커로 건너뜀(BREAKER_SKIP).
  breakerSkip('BREAKER_SKIP');

  const SeasonalAOutcome(this.reasonCode);

  /// `decision_log.reason_code`.
  final String reasonCode;
}

/// 판정 입력(직전 세션 값).
class SeasonalAInput {
  /// 입력을 만든다.
  const SeasonalAInput({
    required this.month,
    required this.deferCount,
    required this.score,
    required this.breaker,
    required this.prevEquity,
    required this.aValue,
    required this.aPrevClose,
    required this.aHeldShares,
    required this.monthCount,
  });

  /// 판정 날의 달(1~12).
  final int month;

  /// 이번 시즌 연기 횟수.
  final int deferCount;

  /// 직전 세션 KOSDAQ 추세 점수(없으면 null — 진입한다).
  final double? score;

  /// 브레이커 레벨.
  final BreakerLevel breaker;

  /// 직전 세션 총평가.
  final Decimal prevEquity;

  /// A 평가(직전 종가).
  final Decimal aValue;

  /// A 직전 종가.
  final Decimal aPrevClose;

  /// A 보유 주수.
  final int aHeldShares;

  /// 지난 월말 수(램프).
  final int monthCount;
}

/// 판정.
class SeasonalADecision {
  /// 판정을 만든다.
  SeasonalADecision(
    this.outcome, {
    required this.deferCountAfter,
    this.liquidatePot = false,
    this.side,
    this.targetShares = 0,
    Decimal? deltaKrw,
  }) : deltaKrw = deltaKrw ?? Decimal.zero;

  /// 종류.
  final SeasonalAOutcome outcome;

  /// 판정 뒤 연기 횟수.
  final int deferCountAfter;

  /// POT 를 청산하나.
  final bool liquidatePot;

  /// A 방향(살 · 팔 것이 없으면 null).
  final OrderSide? side;

  /// A 목표 주수(분할 전 합).
  final int targetShares;

  /// 진입 금액 차이(평가 × 비율 − A 평가).
  final Decimal deltaKrw;

  @override
  String toString() =>
      'SeasonalADecision(${outcome.reasonCode} · ${side?.wire ?? '-'} $targetShares · 연기 $deferCountAfter${liquidatePot ? ' · POT 청산' : ''})';
}

bool _halted(BreakerLevel l) =>
    l == BreakerLevel.halted || l == BreakerLevel.stopped;

/// 계절 A 판정(R49 Q2 · Q3 · 하네스 `_seasonalCheck` 의 규칙 그대로).
SeasonalADecision decideSeasonalA(
  SeasonalAInput i, {
  SeasonalAConfig config = const SeasonalAConfig(),
}) {
  if (i.month < 1 || i.month > 12) throw ArgumentError.value(i.month, 'month');
  if (i.deferCount < 0 || i.aHeldShares < 0 || i.monthCount < 0) {
    throw ArgumentError('연기 · 보유 · 월말 수는 음수가 아니다');
  }
  final double? sc = i.score == null || i.score!.isNaN || !i.score!.isFinite
      ? null
      : i.score;
  SeasonalADecision buy(SeasonalAOutcome kind) {
    final Decimal f = config.rampMonths <= 0
        ? Decimal.one
        : (i.monthCount >= config.rampMonths
              ? Decimal.one
              : divide(
                  Decimal.fromInt(i.monthCount),
                  Decimal.fromInt(config.rampMonths),
                ));
    final Decimal delta = i.prevEquity * kP0sAllocA * f - i.aValue;
    final bool enough =
        delta > i.prevEquity * kSeasonalMinDeltaFraction &&
        i.aPrevClose > Decimal.zero;
    final int shares = enough
        ? divide(delta, i.aPrevClose).floor().toBigInt().toInt()
        : 0;
    return SeasonalADecision(
      kind,
      deferCountAfter: 0,
      liquidatePot: true,
      side: shares > 0 ? OrderSide.buy : null,
      targetShares: shares,
      deltaKrw: delta,
    );
  }

  if (i.deferCount > 0 && i.month != config.entryMonth) {
    if (_halted(i.breaker)) {
      return SeasonalADecision(
        SeasonalAOutcome.breakerSkip,
        deferCountAfter: i.deferCount,
      );
    }
    final bool ok = sc != null && sc >= config.gateScore;
    if (!(ok || i.deferCount >= config.deferMax)) {
      return SeasonalADecision(
        SeasonalAOutcome.defer,
        deferCountAfter: i.deferCount + 1,
      );
    }
    return buy(SeasonalAOutcome.lateEnter);
  }
  if (i.month == config.entryMonth) {
    if (config.gateScore > 0 &&
        !_halted(i.breaker) &&
        sc != null &&
        sc < config.gateScore) {
      return SeasonalADecision(SeasonalAOutcome.defer, deferCountAfter: 1);
    }
    if (_halted(i.breaker)) {
      return SeasonalADecision(
        SeasonalAOutcome.breakerSkip,
        deferCountAfter: 0,
        liquidatePot: true,
      );
    }
    return buy(SeasonalAOutcome.enter);
  }
  if (i.month == config.exitMonth && i.aHeldShares > 0) {
    return SeasonalADecision(
      SeasonalAOutcome.exit,
      deferCountAfter: 0,
      side: OrderSide.sell,
      targetShares: i.aHeldShares,
    );
  }
  return SeasonalADecision(
    SeasonalAOutcome.nothing,
    deferCountAfter: i.deferCount,
  );
}

/// POT 현금 흐름 종류(R49 Q6).
enum PotCashFlowKind {
  /// 계절 A 청산 매도 순대금 → POT.
  aExitSell,

  /// POT 매도 순대금.
  potSell,

  /// POT 매수 대금.
  potBuy,
}

/// POT 현금 흐름 한 건(체결 · 글자 값).
class PotCashFlow {
  /// 흐름을 만든다.
  const PotCashFlow(
    this.kind, {
    required this.quantity,
    required this.priceText,
    this.commissionText = '0',
    this.taxText = '0',
  });

  /// 종류.
  final PotCashFlowKind kind;

  /// 수량.
  final int quantity;

  /// 체결가 · 수수료 · 세금(글자).
  final String priceText, commissionText, taxText;
}

/// POT 현금 = 흐름 합(매도 = 대금 − 수수료 − 세금 · 매수 = −(대금 + 수수료 + 세금)) — 글자가 숫자가 아니면 FormatException.
Decimal potCashOf(Iterable<PotCashFlow> flows) {
  Decimal d(String s) =>
      Decimal.tryParse(s) ?? (throw FormatException('숫자가 아니다: $s'));
  Decimal sum = Decimal.zero;
  for (final PotCashFlow f in flows) {
    final Decimal gross = d(f.priceText) * Decimal.fromInt(f.quantity);
    final Decimal fee = d(f.commissionText) + d(f.taxText);
    sum += switch (f.kind) {
      PotCashFlowKind.aExitSell || PotCashFlowKind.potSell => gross - fee,
      PotCashFlowKind.potBuy => -(gross + fee),
    };
  }
  return sum;
}

/// 판정 입력 조립 실패 — 🔴 사유 = 종목 · 계좌 별칭만(금액 0).
class SeasonalAInputError implements Exception {
  /// 실패를 만든다.
  const SeasonalAInputError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'SeasonalAInputError($reason)';
}

/// 원장 보유 · 직전 세션 종가 글자 · 계좌 현금(D+2) → 판정 입력(R49 Q2).
///
/// 🔴 수량이 있는 보유의 종가가 없거나 A 종가가 없으면 [SeasonalAInputError](지어내지 않는다).
Future<SeasonalAInput> seasonalAInputFromLedger({
  required int month,
  required int deferCount,
  required double? score,
  required BreakerLevel breaker,
  required List<LedgerHolding> holdings,
  required Map<String, String> closeTexts,
  required Map<String, OrderBroker> cashAccounts,
  required String aSymbol,
  required int monthCount,
}) async {
  if (cashAccounts.isEmpty) throw ArgumentError('현금 계좌가 없다');
  Decimal? close(String s) {
    final Decimal? v = Decimal.tryParse(closeTexts[s] ?? '');
    return v != null && v > Decimal.zero ? v : null;
  }

  final Decimal? aClose = close(aSymbol);
  if (aClose == null) throw SeasonalAInputError('A 종가 없음: $aSymbol');
  Decimal positions = Decimal.zero;
  Decimal aValue = Decimal.zero;
  int aShares = 0;
  for (final LedgerHolding h in holdings) {
    if (h.quantity == 0) continue;
    if (h.quantity < 0) {
      throw SeasonalAInputError('보유 수량 음수: ${h.strategyId} ${h.symbol}');
    }
    final Decimal? px = close(h.symbol);
    if (px == null) {
      throw SeasonalAInputError('종가 없음: ${h.strategyId} ${h.symbol}');
    }
    final Decimal v = px * Decimal.fromInt(h.quantity);
    positions += v;
    if (h.strategyId == P0sStrategyIds.sleeveA && h.symbol == aSymbol) {
      aValue += v;
      aShares += h.quantity;
    }
  }
  Decimal cash = Decimal.zero;
  for (final String a in cashAccounts.keys.toList()..sort()) {
    try {
      cash += await cashAccounts[a]!.orderableCashKrw();
    } on Object {
      throw SeasonalAInputError('현금 조회 실패: $a');
    }
  }
  return SeasonalAInput(
    month: month,
    deferCount: deferCount,
    score: score,
    breaker: breaker,
    prevEquity: positions + cash,
    aValue: aValue,
    aPrevClose: aClose,
    aHeldShares: aShares,
    monthCount: monthCount,
  );
}
