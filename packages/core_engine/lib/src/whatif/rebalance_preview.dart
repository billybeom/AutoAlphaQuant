// M3-1 리밸런싱 미리보기 — `WhatIfApi.previewRebalance` 의 본체(06 M3-1 v1.6 · 01 §15-4 · C-41 ①②).
//
// 🔴 실집행과 같은 코드 경로(06 M3-1 게이트 · P2) — 월말 계획기 [planMonthEnd](E7a3-1 · 26년 하네스 일치)를 그대로
//    돌리고, 그 행동을 주문 초안으로 옮길 뿐이다. 지금 as-of 데이터로 «다음 정기 회차»를 미리 본다(01 §15-4 ④).
// 🔵 지정가 = as-of 종가의 원 단위 반올림 · 수량 = 금액 ÷ 지정가 버림.
// 🔵 설계 13 §8 R18: D-9 회차 = 월말 판정 다음 세션([nextRegularRebalance] — `watchNext` 와 같은 판정) ·
//    D-10 · H64 차단 표(E7a2-1 [rebalancePreflight]) · D-11 사유 칩 = `RebalanceReasonCodes`(원화 조달 = `PENSION_FUNDING`) ·
//    D-8 지정가 = as-of 종가.
// 🔴 초안 = 계획 행동 중 매매(B 신호 · C 리밸런싱 · B 재원 매도 · POT · 원화 조달) — 정수 주(금액 ÷ 종가 버림 · 0주면 뺀다).
//    계좌 안 이체(재분류 · 환원)는 초안이 아니다. 연금 **납입**(램프 · 코어 밴드)은 사람이 돈을 옮겨야 하므로 경고 줄로 알린다.
// 🔴 전후 비중 = 회계 기준 A(POT 포함) · B · C(재분류 파킹 포함) 세 줄 — P0S 에서 밴드는 B 에만 있다(코어 밴드 ± band).
//    R12 화면은 이 칸을 그리지 않는다(C-42 · 01 §8 미결 92).
// 🔴 결과 캐시 0(01 §15-4 ②) — 저장하지 않는다. 계획 id 는 순번만 받는다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/next_rebalance.dart';
import '../portfolio/month_end_plan.dart';
import 'what_if_config.dart';
import 'what_if_gates.dart';
import 'what_if_state.dart';
import 'what_if_text.dart';

/// 리밸런싱 미리보기 문장(픽스처에 있는 것은 글자 그대로).
abstract final class RebalancePreviewTexts {
  static const String previewNotice = '미리보기입니다. 회차일 종가로 다시 계산하며 주문을 내지 않습니다.';
  static const String ordersTitle = '주문 초안';
  static const String ordersEmpty = '모든 슬리브가 밴드 안이라 이번 회차에 낼 초안이 없습니다.';
  static const String warnEmpty = '예정일까지 가격이 움직이면 초안이 생길 수 있습니다.';
  static const String costNone = '예상 비용 없음';
  static const String costSource = '추정치';
  static const String costBasis = '수수료·세금은 가정 비율의 추정치이며 체결 뒤 실측으로 바뀝니다.';
  static const String pending = '직전 주문 1건이 체결 확인 중이라 수량이 바뀔 수 있습니다.';
  static const String fundingRule = '03 §5-5b';

  /// 🆕 E8b2(R23 D5) — 국면 UNKNOWN 월말.
  static const String warnRegimeUnknown =
      '시장 국면을 판정할 수 없어 이번 회차의 슬리브 B 추세 조정은 보류합니다(지난달 비율 유지).';
}

const Map<MonthEndActionKind, (String, String, String?)> _reasons =
    <MonthEndActionKind, (String, String, String?)>{
      MonthEndActionKind.sleeveBOrder: (
        RebalanceReasonCodes.sleeveBSignal,
        'B 추세 신호 조정',
        null,
      ),
      MonthEndActionKind.sleeveBFundingSell: (
        RebalanceReasonCodes.rebalanceBand,
        'B 목표 대비 이탈 조정',
        'handbook://rebalance/band',
      ),
      MonthEndActionKind.sleeveCOrder: (
        RebalanceReasonCodes.sleeveCRebalance,
        'C 채권·금 비중 조정',
        null,
      ),
      MonthEndActionKind.potTrade: (
        RebalanceReasonCodes.potSignal,
        'POT 추세 신호 조정',
        null,
      ),
      MonthEndActionKind.raiseKrw: (
        LedgerEventCodes.pensionFunding,
        '연금 납입 조달',
        null,
      ),
    };

/// 미리볼 회차 — [override](엔진·시험용) 또는 지금 as-of 의 다음 정기 회차(D-9 · 달력 없으면 null).
TradeDate? plannedRebalanceDate(WhatIfState s, TradeDate? override) =>
    override ??
    (s.krCalendar == null
        ? null
        : nextRegularRebalance(s.krCalendar!, s.asOfTradeDate)?.planned);

/// 리밸런싱 미리보기 — 차단이면 차단 갈래 · 아니면 초안(정확히 한 갈래 · C-41 ①).
/// 🔴 계산할 수 없는 상태(월말 계획기 입력 없음 · 초안 종목 가격 없음)는 [StateError](Future 에러 = 인프라).
RebalancePreviewResult previewRebalancePlan(
  WhatIfState s,
  WhatIfConfig cfg, {
  required TradeDate? planned,
  required String planId,
}) {
  final RebalancePreviewResult? stop = rebalancePreflight(
    s,
    hasPlannedDate: planned != null,
  );
  if (stop != null) return stop;
  final MonthEndState? input = s.monthEnd;
  if (input == null) {
    throw StateError('월말 계획기 입력이 없다 — 리밸런싱 미리보기를 계산할 수 없다');
  }
  final WhatIfGate gate = rebalanceGate(s, hasPlannedDate: true);
  final MonthEndConfig mc = cfg.monthEnd;
  final MonthEndPlan plan = planMonthEnd(input, mc);

  final List<OrderDraft> drafts = <OrderDraft>[];
  final List<FundingStep> funding = <FundingStep>[];
  Decimal commission = Decimal.zero;
  Decimal contribution = Decimal.zero;
  for (final MonthEndAction a in plan.actions) {
    if (a.kind == MonthEndActionKind.rampContribution ||
        a.kind == MonthEndActionKind.coreBandContribution) {
      contribution += a.amount;
      continue;
    }
    final (String, String, String?)? reason = _reasons[a.kind];
    if (reason == null || a.symbol == null || a.isBuy == null) continue;
    final String sym = a.symbol!;
    final Decimal? close = s.prices[sym];
    if (close == null || close <= Decimal.zero) {
      throw StateError('초안 종목 $sym 의 as-of 종가가 없다');
    }
    // 지정가 = as-of 종가를 원 단위로(국내 ETF 종가는 원 단위 — 호가 단위 반영은 실주문 E10 몫).
    final Decimal price = close.round();
    if (price <= Decimal.zero) continue;
    final int qty = (a.amount / price).floor().toInt();
    if (qty <= 0) continue;
    final (SleeveId sleeve, String? account) = switch (a.kind) {
      MonthEndActionKind.sleeveBOrder ||
      MonthEndActionKind.sleeveBFundingSell => (
        SleeveId.b,
        s.accounts.pensionAlias,
      ),
      MonthEndActionKind.potTrade => (SleeveId.pot, s.accounts.pensionAlias),
      _ => (SleeveId.c, s.accounts.generalAlias),
    };
    if (account == null) {
      throw StateError('$sleeve 계좌 별칭이 없다 — 계좌 매핑 미완');
    }
    final Decimal notional = price * Decimal.fromInt(qty);
    commission += (notional * cfg.commissionRate).floor();
    drafts.add(
      OrderDraft(
        symbol: sym,
        symbolLabel: cfg.symbolLabels[sym] ?? sym,
        sleeve: sleeve,
        accountAlias: account,
        side: a.isBuy! ? OrderSide.buy : OrderSide.sell,
        sideLabel: a.isBuy! ? '매수' : '매도',
        quantity: qty,
        quantityText: sharesText(qty),
        reasons: <ReasonChip>[
          ReasonChip(
            code: reason.$1,
            label: reason.$2,
            tone: ChipTone.neutral,
            detailDeepLink: reason.$3,
          ),
        ],
        limitPrice: price,
        limitPriceText: commaWonText(price),
        pendingNoteText: s.unknownSymbols.contains(sym)
            ? RebalancePreviewTexts.pending
            : null,
      ),
    );
    if (a.kind == MonthEndActionKind.raiseKrw) {
      funding.add(
        FundingStep(
          order: funding.length + 1,
          sourceSleeve: SleeveId.c,
          quantity: qty,
          expectedProceeds: notional,
          ruleCited: RebalancePreviewTexts.fundingRule,
          label:
              '${cfg.symbolLabels[sym] ?? sym} ${sharesText(qty)} 매도로 연금 납입 재원 마련',
          symbol: sym,
          symbolLabel: cfg.symbolLabels[sym] ?? sym,
        ),
      );
    }
  }

  return RebalancePreviewResult(
    preview: RebalancePreview(
      planId: planId,
      plannedDate: planned!,
      plannedDateText: '${koreanDateText(planned)} 회차',
      asOf: AsOf(
        observedAt: s.observedAt,
        tradeDate: s.asOfTradeDate,
        source: s.source,
        staleAfter: cfg.asOfStaleAfter,
        label: '초안 기준 ${s.asOfTradeDate.yyyyMmDd} 종가',
      ),
      before: _weights(input, cfg),
      after: _weights(plan.after, cfg),
      orderDraftsTitle: RebalancePreviewTexts.ordersTitle,
      orderDrafts: drafts,
      ordersEmptyText: drafts.isEmpty
          ? RebalancePreviewTexts.ordersEmpty
          : null,
      costs: CostEstimate(
        commission: commission,
        tax: Decimal.zero,
        total: commission,
        totalText: commission > Decimal.zero
            ? '약 ${commaWonText(commission)}'
            : RebalancePreviewTexts.costNone,
        source: CostSource.estimated,
        sourceLabel: RebalancePreviewTexts.costSource,
        basisNote: RebalancePreviewTexts.costBasis,
      ),
      previewNotice: RebalancePreviewTexts.previewNotice,
      warningLines: <String>[
        ...gate.warningLines,
        if (contribution >= Decimal.one)
          '이번 회차에는 연금저축으로 ${wonText(contribution.floor())} 납입이 함께 필요합니다.',
        if (plan.sleeveBHeld) RebalancePreviewTexts.warnRegimeUnknown,
        if (drafts.isEmpty) RebalancePreviewTexts.warnEmpty,
      ],
      fundingSteps: funding.isEmpty ? null : funding,
    ),
  );
}

/// 회계 기준 A(POT 포함) · B · C(재분류 파킹 포함) 비중 — 목표 = 설정 비중 · 밴드는 B 에만(코어 밴드).
List<SleeveWeight> _weights(MonthEndState st, WhatIfConfig cfg) {
  final Decimal total = st.totalEquity;
  final Decimal b = st.bAssets.values.fold(
    st.bParking,
    (Decimal a, Decimal? v) => v == null ? a : a + v,
  );
  final Decimal c =
      st.krwCash +
      st.cBond +
      (st.cGold ?? Decimal.zero) +
      st.bParkingReclassified;
  final Decimal a = total - b - c;
  Decimal t(SleeveId x) => cfg.targetWeights[x] ?? Decimal.zero;
  return <SleeveWeight>[
    _row(SleeveId.a, a, total, t(SleeveId.a), null),
    _row(SleeveId.b, b, total, t(SleeveId.b), cfg.monthEnd.coreBand),
    _row(SleeveId.c, c, total, t(SleeveId.c), null),
  ];
}

SleeveWeight _row(
  SleeveId sleeve,
  Decimal value,
  Decimal total,
  Decimal target,
  Decimal? band,
) {
  final double w = total > Decimal.zero
      ? (value / total).toDecimal(scaleOnInfinitePrecision: 12).toDouble()
      : 0.0;
  final double t = target.toDouble();
  final double lo = band == null ? 0.0 : (target - band).toDouble();
  final double hi = band == null ? 1.0 : (target + band).toDouble();
  String pct(double x) => '${(x * 100).toStringAsFixed(1)}%';
  String pp(double x) {
    final String v = (x.abs() * 100).toStringAsFixed(1);
    if (v == '0.0') return '0.0%p';
    return '${x > 0 ? '+' : '−'}$v%p';
  }

  final String bandText = band == null
      ? ''
      : w > hi
      ? ', 밴드 상단 ${((w - hi) * 100).toStringAsFixed(1)}%p 초과'
      : w < lo
      ? ', 밴드 하단 ${((lo - w) * 100).toStringAsFixed(1)}%p 미달'
      : ', 밴드 여유 ${((w - lo < hi - w ? w - lo : hi - w) * 100).toStringAsFixed(1)}%p';
  return SleeveWeight(
    sleeve: sleeve,
    weight: w,
    targetWeight: t,
    bandLow: lo,
    bandHigh: hi,
    label: '${sleeve.wire} ${pct(w)} (목표 ${pct(t)}, 편차 ${pp(w - t)}$bandText)',
    basis: AllocationBasis.accounting,
  );
}
