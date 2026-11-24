// 🆕 E11q-j4s — J-4 blind 리뷰 결과 문장(설계 SPEC v2.47 · 02 §3-3 ② · 06 M1-25 ⑥ · 01 §16-7 K6 · 13 §8 R257).
//
// 🔴 갈래 차례(첫 갈래) = ⓐ 가림(«결과: 숨김» — 호출자) › ⓑ 체결 없음 › ⓒ 셀 수 없음(기업 행사 · 원장 어긋남 · 축 모르는 수기 체결 ·
//    달력 밖) › ⓓ 미청산 › ⓔ «결과: 수익률 ±x.x% · 보유 n거래일».
// 🔴 로트 = 살아 있는 체결(`REVERSAL` 아님 · 되돌려지지 않음 — X5-3 체결 재생과 같은 판정) · 축 = (strategy_id, 종목) FIFO ·
//    차례 = 거래일 → 체결 시각 → 체결 id · 취득 = 수량 × 가격 + 수수료 + 세금 · 청산 = 수량 × 가격 − 수수료 − 세금 ·
//    결정의 조각 = 결정이 연 로트의 조각 + 결정의 매도가 만든 조각(한 번씩) · `trades` 표는 읽지 않는다.
// 🔴 금액(원) 0(K6) — 문장에 원 글자 없음 · 셈 중간값은 이 파일 밖으로 나가지 않는다(결과 = 비율 · 거래일 수).
// 🔴 셈 = 십진(원장 글자 그대로 · 규약 5조 `mulDiv` · `divide`) · 반올림 = 백분율 소수 첫째 자리 절댓값 half-up · 0 = «0.0%».

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show FillKind, OrderSide, TradeDate;

import '../decimal_rules.dart' show divide, mulDiv;
import 'journal_view.dart'
    show JournalFacts, JournalFillFact, JournalIntentFact;

/// 결과 갈래(02 §3-3 ② ⓑ ~ ⓔ · ⓐ 가림은 호출자가 먼저 본다).
enum BlindReviewOutcomeKind {
  /// ⓑ 결정의 살아 있는 체결 0.
  noFill,

  /// ⓒ 셀 수 없음.
  uncountable,

  /// ⓓ 결정이 연 로트에 남은 수량 있음.
  open,

  /// ⓔ 전부 청산.
  closed,
}

/// 결과(비율 · 거래일 수만 — 금액 0).
class BlindReviewOutcome {
  const BlindReviewOutcome._(
    this.kind, {
    this.returnRatio,
    this.holdingSessions,
  });

  /// ⓑ.
  static const BlindReviewOutcome noFill = BlindReviewOutcome._(
    BlindReviewOutcomeKind.noFill,
  );

  /// ⓒ.
  static const BlindReviewOutcome uncountable = BlindReviewOutcome._(
    BlindReviewOutcomeKind.uncountable,
  );

  /// ⓓ.
  static const BlindReviewOutcome open = BlindReviewOutcome._(
    BlindReviewOutcomeKind.open,
  );

  /// ⓔ — [returnRatio] = 청산 ÷ 취득 − 1 · [holdingSessions] = 보유 KR 세션 수.
  factory BlindReviewOutcome.closed(Decimal returnRatio, int holdingSessions) =>
      BlindReviewOutcome._(
        BlindReviewOutcomeKind.closed,
        returnRatio: returnRatio,
        holdingSessions: holdingSessions,
      );

  /// 갈래.
  final BlindReviewOutcomeKind kind;

  /// ⓔ 수익률(비율 · 예 0.006).
  final Decimal? returnRatio;

  /// ⓔ 보유 거래일 수.
  final int? holdingSessions;
}

/// 결과 문장 글자(표본 `m6/blind_review_card_revealed*` · 표본 밖 = 엔진 — SPEC 02 §3-3 ②).
abstract final class BlindReviewOutcomeTexts {
  /// ⓐ 가림(`LEDGER_INTEGRITY` · 정기 실사 세션).
  static const String hidden = '결과: 숨김';

  /// ⓑ.
  static const String noFill = '체결 없음 — 결과 없음';

  /// ⓒ.
  static const String uncountable = '셀 수 없음 — 결과 미확정';

  /// ⓓ(표본 `blind_review_card_revealed_open`).
  static const String open = '미청산 — 결과 미확정';

  /// ⓔ(표본 «결과: 수익률 +0.6% · 보유 12거래일»).
  static String closed(String pctText, int sessions) =>
      '결과: 수익률 $pctText · 보유 $sessions거래일';
}

/// 결과 → 문장(ⓑ ~ ⓔ).
String blindReviewOutcomeTextOf(BlindReviewOutcome o) => switch (o.kind) {
  BlindReviewOutcomeKind.noFill => BlindReviewOutcomeTexts.noFill,
  BlindReviewOutcomeKind.uncountable => BlindReviewOutcomeTexts.uncountable,
  BlindReviewOutcomeKind.open => BlindReviewOutcomeTexts.open,
  BlindReviewOutcomeKind.closed => BlindReviewOutcomeTexts.closed(
    blindReviewPctText(o.returnRatio!),
    o.holdingSessions!,
  ),
};

/// 수익률 글자 — 백분율 소수 첫째 자리 · 절댓값 half-up · 양 «+» · 음 «−»(U+2212) · 반올림 뒤 0 = «0.0%».
String blindReviewPctText(Decimal ratio) {
  final Decimal pct = ratio * Decimal.fromInt(100);
  // 절댓값을 십 배 해 0.5 를 더하고 내린다 = 절댓값 half-up(부호와 무관 — 음수의 tie 도 0 에서 멀어진다).
  final BigInt tenths = (pct.abs() * Decimal.ten + Decimal.parse('0.5'))
      .floor()
      .toBigInt();
  if (tenths == BigInt.zero) return '0.0%';
  final BigInt ten = BigInt.from(10);
  final String body = '${tenths ~/ ten}.${tenths % ten}';
  return '${pct.sign > 0 ? '+' : '−'}$body%';
}

/// 로트 셈 입력 체결 한 줄(의도에서 방향 · 축 · 거래일 · 결정을 붙인 살아 있는 체결).
class BlindReviewFill {
  /// 만든다 — 수량 0 이하 = [ArgumentError].
  BlindReviewFill({
    required this.executionId,
    required this.decisionId,
    required this.side,
    required this.strategyId,
    required this.account,
    required this.symbol,
    required this.tradeDate,
    required this.executedAt,
    required this.quantity,
    required this.price,
    required this.commission,
    required this.tax,
  }) {
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', '양수');
  }

  /// 체결 id.
  final String executionId;

  /// 의도의 결정 키.
  final String decisionId;

  /// 의도 방향.
  final OrderSide side;

  /// 의도 전략(축).
  final String strategyId;

  /// 의도 계좌 별칭(기업 행사 대조).
  final String account;

  /// 종목(축).
  final String symbol;

  /// 의도 거래일(`YYYY-MM-DD`).
  final String tradeDate;

  /// 체결 시각(UTC).
  final DateTime executedAt;

  /// 수량.
  final int quantity;

  /// 가격.
  final Decimal price;

  /// 수수료.
  final Decimal commission;

  /// 세금.
  final Decimal tax;
}

/// 원장 사실 → 살아 있는 체결(`REVERSAL` 아님 · 되돌려지지 않음) · 의도 방향 · 축 · 거래일 · 결정.
List<BlindReviewFill> blindReviewFillsOf(JournalFacts f) {
  final Set<String> reversed = <String>{
    for (final JournalIntentFact i in f.intents)
      for (final JournalFillFact x in i.fills)
        if (x.kindWire == FillKind.reversal.wire && x.reversesFillId != null)
          x.reversesFillId!,
  };
  return <BlindReviewFill>[
    for (final JournalIntentFact i in f.intents)
      for (final JournalFillFact x in i.fills)
        if (x.kindWire != FillKind.reversal.wire &&
            !reversed.contains(x.executionId))
          BlindReviewFill(
            executionId: x.executionId,
            decisionId: i.decisionId,
            side: OrderSide.values.firstWhere(
              (OrderSide s) => s.wire == i.sideWire,
              orElse: () => throw StateError('모르는 방향: ${i.sideWire}'),
            ),
            strategyId: i.strategyId,
            account: i.account,
            symbol: i.symbol,
            tradeDate: i.tradeDate.yyyyMmDd,
            executedAt: x.executedAt.toUtc(),
            quantity: x.quantity,
            price: Decimal.parse(x.priceText),
            commission: Decimal.parse(x.commissionText),
            tax: Decimal.parse(x.taxText),
          ),
  ];
}

/// 결정 하나의 결과(02 §3-3 ② ⓑ ~ ⓔ — 순수).
///
/// [fills] = 그 원장의 살아 있는 체결 전부(모든 축) · [corporateActionAxes] = 되돌리지 않은 기업 행사(효력일 ≤ 오늘)의
/// (계좌 별칭, 종목) · [unattributedFills] = 의도에 닿지 않는 살아 있는 수기 체결이 있나 · [sessionsBetween] = (시작 제외 · 끝 포함)
/// KR 세션 수(달력 밖 = [StateError] → 셀 수 없음).
BlindReviewOutcome blindReviewOutcomeOf({
  required String decisionId,
  required List<BlindReviewFill> fills,
  required Set<(String, String)> corporateActionAxes,
  required bool unattributedFills,
  required int Function(String fromExclusive, String toInclusive)
  sessionsBetween,
}) {
  final List<BlindReviewFill> mine = <BlindReviewFill>[
    for (final BlindReviewFill x in fills)
      if (x.decisionId == decisionId) x,
  ];
  if (mine.isEmpty) return BlindReviewOutcome.noFill;
  if (unattributedFills) return BlindReviewOutcome.uncountable;
  for (final BlindReviewFill x in mine) {
    for (final BlindReviewFill y in fills) {
      if (y.strategyId == x.strategyId &&
          y.symbol == x.symbol &&
          corporateActionAxes.contains((y.account, y.symbol))) {
        return BlindReviewOutcome.uncountable;
      }
    }
  }
  final Set<(String, String)> axes = <(String, String)>{
    for (final BlindReviewFill x in mine) (x.strategyId, x.symbol),
  };
  Decimal cost = Decimal.zero;
  Decimal proceeds = Decimal.zero;
  String? firstOpen;
  String? lastClose;
  bool open = false;
  for (final (String strategyId, String symbol) in axes) {
    final List<BlindReviewFill> axis =
        <BlindReviewFill>[
          for (final BlindReviewFill x in fills)
            if (x.strategyId == strategyId && x.symbol == symbol) x,
        ]..sort((BlindReviewFill a, BlindReviewFill b) {
          final int d = a.tradeDate.compareTo(b.tradeDate);
          if (d != 0) return d;
          final int t = a.executedAt.compareTo(b.executedAt);
          return t != 0 ? t : a.executionId.compareTo(b.executionId);
        });
    final List<_Lot> lots = <_Lot>[];
    for (final BlindReviewFill x in axis) {
      final Decimal gross = x.price * Decimal.fromInt(x.quantity);
      if (x.side == OrderSide.buy) {
        lots.add(_Lot(x, gross + x.commission + x.tax));
        continue;
      }
      final Decimal net = gross - x.commission - x.tax;
      int left = x.quantity;
      for (final _Lot l in lots) {
        if (left == 0) break;
        if (l.left == 0) continue;
        final int take = l.left < left ? l.left : left;
        l.left -= take;
        left -= take;
        if (l.fill.decisionId != decisionId && x.decisionId != decisionId) {
          continue;
        }
        // 조각 — 취득 = 로트 원가 × 덜어낸 수 ÷ 로트 수량 · 청산 = 매도 순수령 × 덜어낸 수 ÷ 매도 수량(곱셈 먼저).
        cost += mulDiv(
          l.cost,
          Decimal.fromInt(take),
          Decimal.fromInt(l.fill.quantity),
        );
        proceeds += mulDiv(
          net,
          Decimal.fromInt(take),
          Decimal.fromInt(x.quantity),
        );
        if (firstOpen == null || l.fill.tradeDate.compareTo(firstOpen) < 0) {
          firstOpen = l.fill.tradeDate;
        }
        if (lastClose == null || x.tradeDate.compareTo(lastClose) > 0) {
          lastClose = x.tradeDate;
        }
      }
      if (left > 0) return BlindReviewOutcome.uncountable;
    }
    for (final _Lot l in lots) {
      if (l.fill.decisionId == decisionId && l.left > 0) open = true;
    }
  }
  if (open) return BlindReviewOutcome.open;
  if (firstOpen == null || lastClose == null) {
    // 결정의 체결이 있는데 조각이 없다 = 닿은 로트가 없다(일어나지 않는다 — 매수면 열림 · 매도면 조각) → 셀 수 없음.
    return BlindReviewOutcome.uncountable;
  }
  final int sessions;
  try {
    sessions = sessionsBetween(firstOpen, lastClose);
  } on StateError {
    return BlindReviewOutcome.uncountable;
  }
  return BlindReviewOutcome.closed(divide(proceeds - cost, cost), sessions);
}

/// KR 세션 수(시작 제외 · 끝 포함 · 같은 날 = 0) — 달력 밖 = [StateError].
int krSessionsBetween(
  JournalFacts f,
  String fromExclusive,
  String toInclusive,
) {
  if (toInclusive.compareTo(fromExclusive) <= 0) return 0;
  int n = 0;
  TradeDate d = TradeDate(fromExclusive);
  while (true) {
    d = f.kr.nextSession(d);
    if (d.yyyyMmDd.compareTo(toInclusive) > 0) return n;
    n++;
  }
}

class _Lot {
  _Lot(this.fill, this.cost) : left = fill.quantity;

  final BlindReviewFill fill;
  final Decimal cost;
  int left;
}
