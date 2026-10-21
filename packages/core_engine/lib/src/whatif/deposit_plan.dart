// M3-1 입금 미리보기 계산 — `WhatIfApi.simulateDeposit` 의 본체(06 M3-1 · 01 §14-3~§14-5 · C-38).
//
// 🔵 설계 13 §8 R18 D-1(발주자 2026-10-21 · 추천안): **배분은 03 §5-5b, 주문 초안은 «대기 자리»로만.**
//    · 배분 = [allocateDeposit](부족분 큰 순 · 연금 한도가 남으면 B 먼저 · 한도까지만 · 한도 0 이면 B 제외 · GV-28d)
//    · B 몫 = 연금저축 계좌의 파킹 ETF 매수 1건(트랜치 전개는 다음 월말 B 규칙) — 참조 엔진 `_pension_contribute` 와 같다
//    · A 몫 = 원화 대기(계절 캘린더가 진입 시점을 정한다) · C 몫·잔여 = 원화 대기(다음 정기 리밸런싱 — SPEC v2.28 ② D2)
//    → 납입이 리밸런싱을 일으키지 않는다(03 §5-5b 표 «거래비용이 납입 빈도에 비례해 늘지 않게»).
// 🔵 목표 금액 = 목표 비중 × (현재 평가 합 + 입금액) — 입금 뒤의 총자산 기준(참조 엔진 `_process_deposits` 와 같다).
// 🔴 금액은 원 단위 정수로 끊는다 — 슬리브 몫은 원 미만 버림, 버린 몫은 잔여에 더한다(C-38 ⑤ 합 = 입금액 그대로).
// 🔴 매수 초안은 지정가(as-of 종가 · D-8)를 갖고 «매수액 + 수수료 ≤ 그 슬리브 몫»을 지킨다(D-7 · C-38 ⑥).
//    수수료 = 매수액 × 수수료율 원 미만 버림 · 국내상장 ETF 매수는 거래세 0.
// 🔴 입금 계획의 `fundingSteps` 는 늘 null 이다(D-15 — 입금은 쓸 돈을 스스로 들고 온다 · 조달은 리밸런싱 미리보기 몫).
// 🔴 계획 id · 계산 시각은 받는다 — 스냅샷 저장·조회·만료 재판정은 E7a2-3 몫이다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../portfolio/deposit.dart';
import 'what_if_config.dart';
import 'what_if_gates.dart';
import 'what_if_state.dart';
import 'what_if_text.dart';

/// 입금 계획 문장(픽스처에 있는 것은 글자 그대로 · 없는 것은 같은 꼴로 지었다).
abstract final class DepositPlanTexts {
  static const String previewNotice = '미리보기입니다. 실제 입금이 확인되면 다시 계산합니다.';
  static const String ordersTitle = '주문 초안';
  static const String ordersEmpty =
      '이번 입금으로 낼 주문 초안이 없습니다. 입금액은 원화 현금으로 대기하고 다음 정기 리밸런싱에서 배분합니다.';
  static const String routingB = '해외 ETF 는 연금저축 계좌에서 삽니다(과세 이연).';
  static const String routingA = '계절 캘린더가 진입할 때까지 원화 현금으로 대기합니다.';
  static const String routingC = '다음 정기 리밸런싱에서 채권·금으로 배분할 때까지 원화 현금으로 대기합니다.';
  static const String quotaExhausted =
      '올해 연금 납입한도를 다 써서 이번 달에는 슬리브 B 몫을 채우지 못합니다.';
  static const String suggestionGeneral = '이번 입금은 일반 계좌로 넣도록 제안합니다.';
  static const String pending = '직전 주문 1건이 체결 확인 중이라 수량이 바뀔 수 있습니다.';
  static const String sideBuy = '매수';
  static const String reasonLabel = '월 납입 배분';
  static const String reasonLink = 'handbook://plan/deposit';
  static const String costNone = '주문이 없어 예상 비용이 없습니다';
  static const String costSource = '추정치';
  static const String costBasis = '수수료·세금은 접수 전 추정치이며 체결 후 브로커 원장으로 대체됩니다.';
}

/// 입금 미리보기 — [amountInput](입력칸 글자 그대로)과 상태로 결과 세 갈래 중 하나를 낸다(C-38 ①).
/// 🔴 계산할 수 없는 상태(가격 없음 · 슬리브 집합 불일치)는 [StateError] — `Future` 에러 = «계산을 못 했다».
DepositPreviewResult simulateDepositPreview(
  WhatIfState s,
  String amountInput,
  WhatIfConfig cfg, {
  required String planId,
  required DateTime computedAt,
}) {
  final DepositPreflight pre = depositPreflight(s, amountInput, cfg);
  if (pre.stop != null) return pre.stop!;
  return DepositPreviewResult(
    plan: buildDepositPlan(
      s,
      pre.amount!,
      cfg,
      gate: pre.gate,
      planId: planId,
      computedAt: computedAt,
    ),
  );
}

/// 입금 [amount] 원의 계획을 조립한다(관문을 통과한 뒤 — [gate] 의 등록 불가 문장을 싣는다).
DepositPlan buildDepositPlan(
  WhatIfState s,
  Decimal amount,
  WhatIfConfig cfg, {
  required WhatIfGate gate,
  required String planId,
  required DateTime computedAt,
}) {
  if (!s.sleeveValues.keys.toSet().containsAll(cfg.targetWeights.keys) ||
      s.sleeveValues.length != cfg.targetWeights.length) {
    throw StateError('슬리브 평가액과 목표 비중의 슬리브가 다르다');
  }
  final Decimal total = s.sleeveValues.values.fold(
    Decimal.zero,
    (Decimal a, Decimal b) => a + b,
  );
  final Decimal post = total + amount;
  final Decimal quota = cfg.pensionAnnualLimit - s.pensionUsedThisYear;
  final DepositAllocation alloc = allocateDeposit(
    amount: amount,
    currents: s.sleeveValues,
    targets: <SleeveId, Decimal>{
      for (final MapEntry<SleeveId, Decimal> e in cfg.targetWeights.entries)
        e.key: e.value * post,
    },
    remainingPensionQuota: quota > Decimal.zero ? quota : Decimal.zero,
  );

  // 원 미만 버림 — 버린 몫은 잔여로.
  final Map<SleeveId, Decimal> share = <SleeveId, Decimal>{};
  for (final DepositFill f in alloc.filled) {
    share[f.sleeve] = (share[f.sleeve] ?? Decimal.zero) + f.amount.floor();
  }
  final Decimal shared = share.values.fold(
    Decimal.zero,
    (Decimal a, Decimal b) => a + b,
  );
  final Decimal residual = amount - shared;
  final Decimal bShare = share[SleeveId.b] ?? Decimal.zero;
  final Decimal bGap =
      cfg.targetWeights[SleeveId.b]! * post - s.sleeveValues[SleeveId.b]!;
  final bool quotaBlocksB = quota <= Decimal.zero && bGap > Decimal.zero;

  final List<SleeveAllocation> allocations = <SleeveAllocation>[
    for (final SleeveId sl in <SleeveId>[SleeveId.a, SleeveId.b, SleeveId.c])
      if ((share[sl] ?? Decimal.zero) > Decimal.zero)
        SleeveAllocation(
          sleeve: sl,
          label: cfg.sleeveLabels[sl] ?? sl.wire,
          amount: share[sl]!,
          amountText: wonText(share[sl]!),
          accountAlias: sl == SleeveId.b
              ? s.accounts.pensionAlias
              : s.accounts.generalAlias,
          routingReasonText: switch (sl) {
            SleeveId.b => DepositPlanTexts.routingB,
            SleeveId.a => DepositPlanTexts.routingA,
            _ => DepositPlanTexts.routingC,
          },
        ),
  ];

  // 주문 초안 — B 몫의 파킹 ETF 매수 1건(정수 주 · 지정가 · 수수료 포함 ≤ B 몫).
  final List<OrderDraft> drafts = <OrderDraft>[];
  Decimal commission = Decimal.zero;
  if (bShare > Decimal.zero) {
    final Decimal? price = s.prices[cfg.parkingSymbol];
    if (price == null || price <= Decimal.zero) {
      throw StateError('파킹 ETF ${cfg.parkingSymbol} 의 as-of 종가가 없다');
    }
    int qty = (bShare / price).floor().toInt();
    while (qty > 0 &&
        price * Decimal.fromInt(qty) + _commission(price, qty, cfg) > bShare) {
      qty--;
    }
    if (qty > 0) {
      commission = _commission(price, qty, cfg);
      drafts.add(
        OrderDraft(
          symbol: cfg.parkingSymbol,
          symbolLabel: cfg.symbolLabels[cfg.parkingSymbol] ?? cfg.parkingSymbol,
          sleeve: SleeveId.b,
          accountAlias: s.accounts.pensionAlias!,
          side: OrderSide.buy,
          sideLabel: DepositPlanTexts.sideBuy,
          quantity: qty,
          quantityText: sharesText(qty),
          reasons: const <ReasonChip>[
            ReasonChip(
              code: PlannerReasonCodes.depositRouting,
              label: DepositPlanTexts.reasonLabel,
              tone: ChipTone.neutral,
              detailDeepLink: DepositPlanTexts.reasonLink,
            ),
          ],
          limitPrice: price,
          limitPriceText: commaWonText(price),
          pendingNoteText: s.unknownSymbols.contains(cfg.parkingSymbol)
              ? DepositPlanTexts.pending
              : null,
        ),
      );
    }
  }

  final Decimal consumed = s.pensionUsedThisYear + bShare;
  return DepositPlan(
    planId: planId,
    computedAt: computedAt,
    asOfTradeDate: s.asOfTradeDate,
    expiresAt: computedAt.add(cfg.planTtl),
    configHash: s.configHash,
    asOf: AsOf(
      observedAt: s.observedAt,
      tradeDate: s.asOfTradeDate,
      source: s.source,
      staleAfter: cfg.asOfStaleAfter,
      label: '계획 기준 ${s.asOfTradeDate.yyyyMmDd} 종가',
    ),
    depositAmount: amount,
    depositAmountText: wonText(amount),
    allocations: allocations,
    pensionLimitConsumed: consumed,
    pensionLimit: _pensionLimit(s, consumed, cfg, quotaBlocksB: quotaBlocksB),
    residualKrwCash: residual,
    residualKrwCashText: residual > Decimal.zero
        ? '${wonText(residual)}은 원화 현금으로 대기합니다(다음 리밸런싱 재원).'
        : null,
    orderDraftsTitle: DepositPlanTexts.ordersTitle,
    orderDrafts: drafts,
    ordersEmptyText: drafts.isEmpty ? DepositPlanTexts.ordersEmpty : null,
    costs: CostEstimate(
      commission: commission,
      tax: Decimal.zero,
      total: commission,
      totalText: drafts.isEmpty
          ? DepositPlanTexts.costNone
          : '약 ${commaWonText(commission)}',
      source: CostSource.estimated,
      sourceLabel: DepositPlanTexts.costSource,
      basisNote: DepositPlanTexts.costBasis,
    ),
    previewNotice: DepositPlanTexts.previewNotice,
    warningLines: <String>[
      ...gate.warningLines,
      if (quotaBlocksB) DepositPlanTexts.quotaExhausted,
    ],
    registerBlockedText: gate.registerBlockedText,
  );
}

/// 수수료 = 매수액 × 수수료율 · 원 미만 버림(D-7).
Decimal _commission(Decimal price, int qty, WhatIfConfig cfg) =>
    (price * Decimal.fromInt(qty) * cfg.commissionRate).floor();

/// 연금 한도 카드 세 줄(+ 한도 소진이면 제안 한 줄) — 픽스처 꼴.
PensionLimitVm _pensionLimit(
  WhatIfState s,
  Decimal consumed,
  WhatIfConfig cfg, {
  required bool quotaBlocksB,
}) {
  final bool annualFull = consumed >= cfg.pensionAnnualLimit;
  final bool bandFull = consumed >= cfg.taxCreditBand;
  final String limit = wonText(cfg.pensionAnnualLimit);
  final String band = wonText(cfg.taxCreditBand);
  return PensionLimitVm(
    annualLimitText: annualFull
        ? '올해 연금 합산 납입한도 $limit을 모두 썼습니다.'
        : '올해 연금 합산 납입한도 $limit 가운데 ${wonText(consumed)}을 썼습니다(이번 입금 포함).',
    taxCreditText: bandFull
        ? '세액공제 대상 구간 $band${annualFull ? '도' : '을'} 모두 채웠습니다.'
        : '세액공제 대상 구간 $band 가운데 ${wonText(consumed)}을 채웠습니다.',
    deadlineText:
        '올해 납입 마감(12월 31일)까지 ${daysToYearEnd(s.asOfTradeDate)}일 남았습니다.',
    suggestionText: quotaBlocksB ? DepositPlanTexts.suggestionGeneral : null,
  );
}
