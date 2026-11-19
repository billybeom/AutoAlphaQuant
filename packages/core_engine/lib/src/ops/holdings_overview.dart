// M6 H6-1 보유 현황 VM(E11q1 · 설계 13 §8 R171 · 나눔 계획 R169 q1 · 01 §17 · 02 H6-1).
//
// 🔴 회계 귀속 = 월말 계획기와 한 원천(`monthEndStateFromLedger` · `sleeveWeightsOf`) — 화면용 셈을 따로 만들지 않는다.
//    A = A 자산(POT 제외) · POT = POT 자산 + POT 현금(A 소속) · B = B 자산 + B 파킹 · C = 채권 + 금 + C 로 재분류한 파킹 +
//    원화 현금(+ 예약). 현금은 POT · 예약을 뺀 나머지가 모두 C 원화다(03 §2-9).
// 🔴 비중 줄 = What-if 미리보기와 같은 생산(`sleeveWeightOf` — «B 42.6% (목표 42.0%, 편차 +0.6%p, 밴드 여유 2.4%p)») ·
//    밴드 = B 만(K27) · A = «계절 슬리브 · 밴드 판정 없음» · C = «목표 잔여 — 게이지 없음».
// 🔴 가림 = 엔진이 글자 안에서 끝낸다 — `LEDGER_INTEGRITY` = «숨김»(비율 null) · `RECON_MISMATCH` = 끝 «?»(01 §11-2).
// 🔴 없는 화면으로 보내지 않는다 — `allocationLink` · `detailDeepLink` = 등록된 화면만(S01 원칙).
// 🔴 원값 · 키(수량 · 평단 · 종목 · 슬리브 · 결정)는 ui 미참조 칸에만 · 표시 = `*Text`.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationBasis,
        AppRoutes,
        AsOf,
        AsOfSource,
        ChipTone,
        DecisionRef,
        HoldingRow,
        HoldingScope,
        HoldingsOverviewVm,
        HoldingsSleeveCard,
        LinkAction,
        ReasonChip,
        SleeveAllocationRow,
        SleeveBandState,
        SleeveId,
        SleeveWeight,
        TradeDate;

import '../orders/order_draft.dart' show P0sStrategyIds;
import '../orders/reconcile.dart' show LedgerHolding;
import '../portfolio/sleeve_weight_view.dart'
    show sleeveBandGaugeOf, sleeveBandStateOf, sleeveWeightOf;
import '../signals/sleeve_b_tranche.dart' show sleeveBTargetWeight;
import '../whatif/what_if_config.dart' show WhatIfConfig;
import 'month_end_inputs.dart' show monthEndStateFromLedger, sleeveWeightsOf;

/// 보유 현황 기준 유효 시간(표본 26시간).
const Duration kHoldingsStaleAfter = Duration(hours: 26);

/// 원장 보유 한 줄(`positions` · 진입 결정 역추적).
class HoldingPositionFact {
  /// 만든다.
  const HoldingPositionFact({
    required this.strategyId,
    required this.symbol,
    required this.quantity,
    required this.avgPrice,
    required this.entryDate,
    required this.entryDecision,
  });

  /// 원장 원값으로 만든다(`positions.avg_price` = REAL — data_sync 는 Decimal 을 쓰지 않는다 · 01 §1-1).
  factory HoldingPositionFact.ledger({
    required String strategyId,
    required String symbol,
    required int quantity,
    required double avgPrice,
    required TradeDate entryDate,
    required DecisionRef? entryDecision,
  }) => HoldingPositionFact(
    strategyId: strategyId,
    symbol: symbol,
    quantity: quantity,
    avgPrice: Decimal.parse('$avgPrice'),
    entryDate: entryDate,
    entryDecision: entryDecision,
  );

  /// 전략(`P0S_A` · `P0S_B` · `P0S_C` · `P0S_POT`).
  final String strategyId;

  /// 종목.
  final String symbol;

  /// 수량.
  final int quantity;

  /// 평단(원).
  final Decimal avgPrice;

  /// 진입일.
  final TradeDate entryDate;

  /// 진입 결정(`positions.entry_decision_id` → 주문 의도 · 없으면 null = 행을 지어내지 않고 실패).
  final DecisionRef? entryDecision;
}

/// H6-1 사실.
class HoldingsOverviewFacts {
  /// 만든다.
  const HoldingsOverviewFacts({
    required this.positions,
    required this.closes,
    required this.closeDate,
    required this.cashKrw,
    required this.potCash,
    required this.config,
    required this.accountAliasOf,
    required this.bTranches,
    required this.nextTrancheDate,
    required this.integrityHidden,
    required this.reconSuspect,
    required this.hasBody,
    required this.nowUtc,
    this.reservedKrw,
  });

  /// 원장 글자로 만든다 — 월말 잡(`computeMonthEndRun`)과 같은 꼴: 종가 = 글자(숫자 아님 · 0 이하 = 빠진다) ·
  /// [cashTexts] = 계좌 별칭 → 가상 현금(`simOrderableCashOf` · 합 = 현금) · [potCashText] = POT 현금(`potCashOf`) ·
  /// 예약 = 0(S7 · R49).
  /// 🔴 현금 · POT 글자가 숫자가 아니거나 POT 가 음수 = [ArgumentError](0 으로 지어내지 않는다).
  factory HoldingsOverviewFacts.ledger({
    required List<HoldingPositionFact> positions,
    required Map<String, String> closeTexts,
    required TradeDate closeDate,
    required Map<String, String> cashTexts,
    required String potCashText,
    required WhatIfConfig config,
    required String Function(String strategyId) accountAliasOf,
    required Map<String, int?> bTranches,
    required TradeDate? nextTrancheDate,
    required bool integrityHidden,
    required bool reconSuspect,
    required bool Function(String route) hasBody,
    required DateTime nowUtc,
  }) {
    Decimal cash = Decimal.zero;
    for (final String a in cashTexts.keys.toList()..sort()) {
      final Decimal? v = Decimal.tryParse(cashTexts[a]!);
      if (v == null) throw ArgumentError.value(cashTexts[a], 'cashTexts[$a]');
      cash += v;
    }
    final Decimal? pot = Decimal.tryParse(potCashText);
    if (pot == null || pot < Decimal.zero) {
      throw ArgumentError.value(potCashText, 'potCashText');
    }
    return HoldingsOverviewFacts(
      positions: positions,
      closes: <String, Decimal>{
        for (final MapEntry<String, String> e in closeTexts.entries)
          if (Decimal.tryParse(e.value) case final Decimal v
              when v > Decimal.zero)
            e.key: v,
      },
      closeDate: closeDate,
      cashKrw: cash,
      potCash: pot,
      config: config,
      accountAliasOf: accountAliasOf,
      bTranches: bTranches,
      nextTrancheDate: nextTrancheDate,
      integrityHidden: integrityHidden,
      reconSuspect: reconSuspect,
      hasBody: hasBody,
      nowUtc: nowUtc,
    );
  }

  /// 원장 보유.
  final List<HoldingPositionFact> positions;

  /// 잔고 기준 종가(종목 → 원).
  final Map<String, Decimal> closes;

  /// 잔고 기준 종가일.
  final TradeDate closeDate;

  /// 현금(원 · 모의 = 가상 현금).
  final Decimal cashKrw;

  /// POT 서브북 현금(원).
  final Decimal potCash;

  /// A 재진입 예약 원화(원 · 없으면 0 — S7 · R49).
  final Decimal? reservedKrw;

  /// 목표 · 밴드 · 종목 · 슬리브 이름 · 파킹 종목(엔진 설정 한 벌).
  final WhatIfConfig config;

  /// 전략 → 계좌 별칭(«연금저축» — 계좌 번호 0).
  final String Function(String strategyId) accountAliasOf;

  /// B 자산별 트랜치 점등 수(0~3 · null = 판정할 시세가 모자라다 · [bTrancheSignalsOf]).
  final Map<String, int?> bTranches;

  /// 다음 트랜치 판정일(빈 보유 문장 · null = 예정 없음).
  final TradeDate? nextTrancheDate;

  /// `LEDGER_INTEGRITY` 가 서 있나(금액 · 비율 «숨김»).
  final bool integrityHidden;

  /// `RECON_MISMATCH` 가 서 있나(글자 끝 «?»).
  final bool reconSuspect;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 기기 시각(기준 줄).
  final DateTime nowUtc;
}

/// 보유 현황 글자(엔진 · 표본 그대로).
abstract final class HoldingsTexts {
  /// 가림.
  static const String hidden = '숨김';

  /// 해당 없음(트랜치).
  static const String notApplicable = '해당 없음';

  /// B 파킹 문장.
  static const String bParkingNote = '신호가 켜지지 않은 몫은 파킹 ETF 에 둡니다.';

  /// A 카드 엔진 열 문장.
  static const String engineColumnNote =
      '엔진 원장 열에서는 POT 가 C 쪽에 합산됩니다 — 여기 비중은 회계 기준입니다';

  /// 비중 보기 링크.
  static const String allocationLink = '비중 보기';

  /// 시스템 관리.
  static const String managed = '시스템 관리';

  /// 슬리브에 보유 없음.
  static const String rowsEmpty = '이 슬리브에 보유 종목이 없습니다';

  /// 월간 정기 사유 칩.
  static const String monthlyRegular = '월간 정기 리밸런싱';

  /// 밴드 상태.
  static const String inBand = '밴드 내';

  /// 밴드 경계 근접.
  static const String nearEdge = '경계 근접';

  /// 밴드 이탈(실행 예고 아님).
  static const String outOfBand = '밴드 이탈 — 다음 배치에서 리밸런싱 대상';

  /// B 트랜치 판정 불가.
  static const String trancheUnknown = 'B 트랜치 — 판정할 시세가 모자랍니다';

  /// B 트랜치(자산 점등 수가 모두 같을 때 — 표본 꼴).
  static String tranche(int n) => 'B 트랜치 $n/3 — SMA 신호 $n개 점등';

  /// B 트랜치(자산마다 다를 때).
  static String tranchePerAsset(List<(String, int)> xs) =>
      'B 트랜치 ${xs.map(((String, int) x) => '${x.$1} ${x.$2}/3').join(' · ')} — SMA 신호 점등';

  /// 빈 보유.
  static String empty(TradeDate? next) => next == null
      ? '보유 종목이 없습니다'
      : '보유 종목이 없습니다 · 다음 트랜치 판정 ${next.yyyyMmDd}(SMA 신호)';

  /// POT 서브북.
  static String subBook(String alias) => 'POT 서브북 · A 하위($alias)';
}

String _pct(double x) => '${(x * 100).toStringAsFixed(1)}%';

/// 만원 단위(반올림 · 천 단위 쉼표).
String holdingsManwonText(Decimal won) {
  final BigInt man = (won / Decimal.fromInt(10000))
      .toDecimal(scaleOnInfinitePrecision: 6)
      .round()
      .toBigInt();
  return '${_comma(man.toString())}만원';
}

String _comma(String digits) {
  final bool neg = digits.startsWith('-');
  final String d = neg ? digits.substring(1) : digits;
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < d.length; i++) {
    if (i > 0 && (d.length - i) % 3 == 0) b.write(',');
    b.write(d[i]);
  }
  return '${neg ? '-' : ''}$b';
}

String _won(Decimal v) {
  final String s = v.round().toBigInt().toString();
  return '${_comma(s)}원';
}

/// B 트랜치 문장 — 하나라도 모르면 «모자랍니다» · 모두 같으면 표본 꼴 · 다르면 자산별.
String _trancheText(Map<String, int?> t) {
  if (t.isEmpty || t.values.any((int? n) => n == null)) {
    return HoldingsTexts.trancheUnknown;
  }
  final Set<int> distinct = <int>{for (final int? n in t.values) n!};
  if (distinct.length == 1) return HoldingsTexts.tranche(distinct.single);
  return HoldingsTexts.tranchePerAsset(<(String, int)>[
    for (final MapEntry<String, int?> e in t.entries) (e.key, e.value!),
  ]);
}

/// 🔴 B 자산별 트랜치 점등 수 — 월말 계획기와 같은 함수(`sleeveBTargetWeight` · 비율 × 3) · 가장 긴 룩백보다 짧으면 null.
Map<String, int?> bTrancheSignalsOf(
  Map<String, List<double>> monthlyCloses,
  WhatIfConfig config,
) {
  final List<int> lb = config.monthEnd.lookbackMonths;
  final int need = lb.reduce((int a, int b) => a > b ? a : b);
  return <String, int?>{
    for (final (String sym, Decimal _) in config.monthEnd.bAssets)
      sym: (monthlyCloses[sym] ?? const <double>[]).length < need
          ? null
          : (sleeveBTargetWeight(monthlyCloses[sym]!, lookbackMonths: lb) *
                    lb.length)
                .round(),
  };
}

SleeveId _sleeveOf(String strategyId) => switch (strategyId) {
  P0sStrategyIds.sleeveA => SleeveId.a,
  P0sStrategyIds.sleeveB => SleeveId.b,
  P0sStrategyIds.sleeveC => SleeveId.c,
  P0sStrategyIds.pot => SleeveId.pot,
  final String other => throw StateError('귀속 불가 전략: $other'),
};

/// 🔴 H6-1 VM.
HoldingsOverviewVm holdingsOverviewVmOf(HoldingsOverviewFacts f) {
  final WhatIfConfig cfg = f.config;
  final String day = f.closeDate.yyyyMmDd;
  final AsOf asOf = AsOf(
    observedAt: f.nowUtc.toUtc(),
    tradeDate: f.closeDate,
    source: AsOfSource.localSqlite,
    staleAfter: kHoldingsStaleAfter,
    label: '잔고 기준 $day 종가 · 엔진은 일 1회 배치',
  );
  final List<HoldingPositionFact> held = <HoldingPositionFact>[
    for (final HoldingPositionFact p in f.positions)
      if (p.quantity > 0) p,
  ];
  if (held.isEmpty) {
    return HoldingsOverviewVm(
      cards: const <HoldingsSleeveCard>[],
      emptyLabel: HoldingsTexts.empty(f.nextTrancheDate),
      asOf: asOf,
    );
  }
  // 회계 — 월말 계획기와 같은 귀속(계획기 전용 칸은 값에 쓰이지 않는다).
  final state = monthEndStateFromLedger(
    holdings: <LedgerHolding>[
      for (final HoldingPositionFact p in held)
        LedgerHolding(p.strategyId, p.symbol, p.quantity),
    ],
    closes: f.closes,
    cashKrw: f.cashKrw,
    potCash: f.potCash,
    reservedKrw: f.reservedKrw ?? Decimal.zero,
    pensionUsedThisYear: Decimal.zero,
    monthIndex: 1,
    regimeState: null,
    monthlyCloses: const <String, List<double>>{},
    hasNextKrSession: false,
    hasNextUsSession: false,
    config: cfg.monthEnd,
    parkingSymbol: cfg.parkingSymbol,
  );
  final Map<String, double> w = sleeveWeightsOf(state);
  final Decimal total = state.totalEquity;
  Decimal sum(Iterable<Decimal?> vs) =>
      vs.fold(Decimal.zero, (Decimal x, Decimal? y) => y == null ? x : x + y);
  final Decimal pot = state.potCash + sum(state.potAssets.values);
  final Decimal bDeployed = sum(state.bAssets.values);
  final Decimal cDeployed =
      state.cBond + (state.cGold ?? Decimal.zero) + state.krwCash;
  final Decimal cParking = state.bParkingReclassified + state.reservedKrw;
  final Decimal aValue =
      total - bDeployed - state.bParking - cDeployed - cParking - pot;

  String money(String s) =>
      f.integrityHidden ? HoldingsTexts.hidden : (f.reconSuspect ? '$s?' : s);
  double? ratio(Decimal part, Decimal whole) =>
      f.integrityHidden || whole <= Decimal.zero
      ? null
      : (part / whole).toDecimal(scaleOnInfinitePrecision: 12).toDouble();
  String pctOfTotal(Decimal v) => money(
    _pct(
      total > Decimal.zero
          ? (v / total).toDecimal(scaleOnInfinitePrecision: 12).toDouble()
          : 0.0,
    ),
  );

  SleeveAllocationRow row(
    SleeveId s, {
    required Decimal deployed,
    required Decimal parking,
    required Decimal sleeveValue,
  }) {
    final Decimal both = deployed + parking;
    final Decimal? band = s == SleeveId.b ? cfg.monthEnd.coreBand : null;
    final SleeveWeight? sw = band == null
        ? null
        : sleeveWeightOf(
            s,
            sleeveValue,
            total,
            cfg.targetWeights[s] ?? Decimal.zero,
            band,
          );
    final String weightPct = _pct(
      total > Decimal.zero
          ? (sleeveValue / total)
                .toDecimal(scaleOnInfinitePrecision: 12)
                .toDouble()
          : 0.0,
    );
    final String? note = sw != null
        ? null
        : money(switch (s) {
            SleeveId.a =>
              'A $weightPct · 목표 ${_pct((cfg.targetWeights[SleeveId.a] ?? Decimal.zero).toDouble())} — 계절 슬리브 · 밴드 판정 없음',
            SleeveId.c => 'C $weightPct · 목표 잔여 — 게이지 없음',
            _ => '${s.wire} $weightPct',
          });
    final String tranche = s == SleeveId.b
        ? money(_trancheText(f.bTranches))
        : (f.integrityHidden
              ? HoldingsTexts.hidden
              : HoldingsTexts.notApplicable);
    final bool hide = f.integrityHidden;
    return SleeveAllocationRow(
      sleeve: s,
      basis: AllocationBasis.accounting,
      deployedText: money(holdingsManwonText(deployed)),
      parkingText: money(holdingsManwonText(parking)),
      deployedRatio: ratio(deployed, both),
      parkingRatio: ratio(parking, both),
      trancheStateText: tranche,
      deployedPctText: pctOfTotal(deployed),
      parkingPctText: pctOfTotal(parking),
      engineColumnNote: s == SleeveId.a ? HoldingsTexts.engineColumnNote : null,
      parkingNoteText: s == SleeveId.b ? HoldingsTexts.bParkingNote : null,
      sleeveLabel: '슬리브 ${s.wire}',
      sleeveWeight: hide ? null : sw,
      bandState: hide || sw == null ? null : sleeveBandStateOf(sw),
      bandStateLabel: hide || sw == null
          ? null
          : switch (sleeveBandStateOf(sw)) {
              SleeveBandState.inBand => HoldingsTexts.inBand,
              SleeveBandState.nearEdge => HoldingsTexts.nearEdge,
              SleeveBandState.outOfBand => HoldingsTexts.outOfBand,
            },
      gauge: hide || sw == null ? null : sleeveBandGaugeOf(sw),
      bandNoteText: hide && sw != null ? HoldingsTexts.hidden : note,
      stateChips: const <ReasonChip>[],
    );
  }

  HoldingRow holding(HoldingPositionFact p) {
    final Decimal close = f.closes[p.symbol]!;
    final Decimal value = close * Decimal.fromInt(p.quantity);
    final DecisionRef? d = p.entryDecision;
    if (d == null) {
      throw StateError('진입 결정 없음: ${p.strategyId} ${p.symbol}');
    }
    final SleeveId sleeve = _sleeveOf(p.strategyId);
    final String alias = f.accountAliasOf(p.strategyId);
    final String id = 'h_${p.strategyId}_${p.symbol}';
    final String detail = '${AppRoutes.holdingsDetail.split('/:').first}/$id';
    return HoldingRow(
      symbol: p.symbol,
      symbolLabel: cfg.symbolLabels[p.symbol] ?? p.symbol,
      sleeve: sleeve,
      accountAlias: alias,
      quantity: p.quantity,
      avgPrice: p.avgPrice,
      entryDate: p.entryDate,
      entryDecision: d,
      entryReasons: const <ReasonChip>[
        ReasonChip(
          code: 'MONTHLY_REGULAR',
          label: HoldingsTexts.monthlyRegular,
          tone: ChipTone.neutral,
          detailDeepLink: 'handbook://rebalance/monthly',
        ),
      ],
      smaTranches: const [],
      gates: const [],
      scope: HoldingScope.managed,
      scopeLabel: HoldingsTexts.managed,
      asOf: AsOf(
        observedAt: f.nowUtc.toUtc(),
        tradeDate: f.closeDate,
        source: AsOfSource.localSqlite,
        staleAfter: kHoldingsStaleAfter,
        label: '잔고 기준 $day 종가',
      ),
      holdingId: id,
      quantityText: money('${_comma(p.quantity.toString())}주'),
      avgPriceText: money(_won(p.avgPrice)),
      weightText: money(
        '비중 ${_pct(total > Decimal.zero ? (value / total).toDecimal(scaleOnInfinitePrecision: 12).toDouble() : 0.0)}',
      ),
      subBookLabel: sleeve == SleeveId.pot
          ? HoldingsTexts.subBook(alias)
          : null,
      detailDeepLink: f.hasBody(AppRoutes.holdingsDetail) ? detail : null,
    );
  }

  List<HoldingRow> rowsOf(Set<String> strategies) {
    final List<HoldingPositionFact> ps = <HoldingPositionFact>[
      for (final HoldingPositionFact p in held)
        if (strategies.contains(p.strategyId)) p,
    ];
    Decimal v(HoldingPositionFact p) =>
        f.closes[p.symbol]! * Decimal.fromInt(p.quantity);
    ps.sort((HoldingPositionFact x, HoldingPositionFact y) {
      // POT 행 = A 카드 맨 끝 · 그 밖 = 평가액 내림차순 · 같으면 종목.
      final bool xp = x.strategyId == P0sStrategyIds.pot;
      final bool yp = y.strategyId == P0sStrategyIds.pot;
      if (xp != yp) return xp ? 1 : -1;
      final int c = v(y).compareTo(v(x));
      return c != 0 ? c : x.symbol.compareTo(y.symbol);
    });
    return <HoldingRow>[for (final HoldingPositionFact p in ps) holding(p)];
  }

  HoldingsSleeveCard card(
    SleeveId s,
    Set<String> strategies,
    SleeveAllocationRow allocation,
  ) {
    final List<HoldingRow> rows = rowsOf(strategies);
    return HoldingsSleeveCard(
      sleeve: s,
      titleText: cfg.sleeveLabels[s] ?? '슬리브 ${s.wire}',
      allocation: allocation,
      rows: rows,
      rowsEmptyText: rows.isEmpty ? HoldingsTexts.rowsEmpty : null,
    );
  }

  final double aWeight = (w['A'] ?? 0) + (w['POT'] ?? 0);
  assert(aWeight >= 0);
  return HoldingsOverviewVm(
    cards: <HoldingsSleeveCard>[
      card(
        SleeveId.a,
        const <String>{P0sStrategyIds.sleeveA, P0sStrategyIds.pot},
        row(
          SleeveId.a,
          deployed: aValue,
          parking: Decimal.zero,
          sleeveValue: aValue + pot,
        ),
      ),
      card(
        SleeveId.b,
        const <String>{P0sStrategyIds.sleeveB},
        row(
          SleeveId.b,
          deployed: bDeployed,
          parking: state.bParking,
          sleeveValue: bDeployed + state.bParking,
        ),
      ),
      card(
        SleeveId.c,
        const <String>{P0sStrategyIds.sleeveC},
        row(
          SleeveId.c,
          deployed: cDeployed,
          parking: cParking,
          sleeveValue: cDeployed + cParking,
        ),
      ),
    ],
    allocationLink: f.hasBody(AppRoutes.holdingsAllocation)
        ? const LinkAction(
            label: HoldingsTexts.allocationLink,
            deepLink: AppRoutes.holdingsAllocation,
          )
        : null,
    asOf: asOf,
  );
}
