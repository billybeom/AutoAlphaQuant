// M6 보유 VM — H6-1 보유 현황(E11q1 · 설계 13 §8 R171) · 🆕 H6-2 종목 상세 · H6-3 슬리브 배분(E11q1b · R172) ·
// 나눔 계획 R169 q1 · 01 §17 · 02 H6-1~3.
//
// 🔴 회계 귀속 = 월말 계획기와 한 원천(`monthEndStateFromLedger`) — 화면용 셈을 따로 만들지 않는다 · 세 화면 = 한 장부(`_Book`).
//    A = A 자산(POT 제외) · POT = POT 자산 + POT 현금(A 소속 · A 하위 행) · B = B 자산 + B 파킹 · C = 채권 + 금 + C 로 재분류한
//    파킹 + 예약 · 🆕 R172 원화 현금(POT · 예약을 뺀 나머지) = «원화 현금 대기» 행(02 H6-3 P 회차 · 표본 — C 비중에 넣지 않는다).
// 🔴 비중 줄 = What-if 미리보기와 같은 생산(`sleeveWeightOf` — «B 42.6% (목표 42.0%, 편차 +0.6%p, 밴드 여유 2.4%p)») ·
//    밴드 = B 만(K27) · A = «계절 슬리브 · 밴드 판정 없음» · C = «목표 잔여 — 게이지 없음».
// 🔴 가림 = 엔진이 글자 안에서 끝낸다 — `LEDGER_INTEGRITY` = «숨김»(비율 null) · `RECON_MISMATCH` = 끝 «?»(01 §11-2) —
//    🆕 R172 표본 꼴: 금액 · 비율 · 수량 · 비중 · 비중 문장 · 손익에만 · 평단 · 트랜치는 그대로(대사가 다투는 값이 아니다).
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
        HoldingDetailVm,
        HoldingPnl,
        HoldingRow,
        HoldingScope,
        HoldingsOverviewVm,
        HoldingsSleeveCard,
        LinkAction,
        ReasonChip,
        SleeveAllocationRow,
        SleeveAllocationVm,
        SleeveBandState,
        SleeveId,
        SleeveWeight,
        StopLineNormalized,
        TradeDate,
        TradeJournalEntry;

import '../orders/order_draft.dart' show P0sStrategyIds;
import '../orders/reconcile.dart' show LedgerHolding;
import '../portfolio/month_end_plan.dart' show MonthEndState;
import '../portfolio/sleeve_weight_view.dart'
    show sleeveBandGaugeOf, sleeveBandStateOf, sleeveWeightOf;
import '../signals/sleeve_b_tranche.dart' show sleeveBTargetWeight;
import '../whatif/what_if_config.dart' show WhatIfConfig;
import 'month_end_inputs.dart' show monthEndStateFromLedger;

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
    this.fillCounts = const <(String, String), int>{},
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
    Map<(String, String), int> fillCounts = const <(String, String), int>{},
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
      fillCounts: fillCounts,
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

  /// (전략, 종목) → 체결 건수(원 체결만 · H6-2 최근 체결 문장 · 없으면 0).
  final Map<(String, String), int> fillCounts;
}

/// 보유 현황 글자(엔진 · 표본 그대로).
abstract final class HoldingsTexts {
  /// 가림.
  static const String hidden = '숨김';

  /// 해당 없음(트랜치).
  static const String notApplicable = '해당 없음';

  /// B 파킹 문장.
  static const String bParkingNote = '신호가 켜지지 않은 몫은 파킹 ETF 에 둡니다.';

  /// A 행 엔진 열 문장.
  static const String engineColumnNote =
      '엔진 원장 열에서는 POT 가 C 쪽에 합산됩니다 — 여기 비중은 회계 기준입니다';

  /// 🆕 R172 — POT 행 엔진 열 문장(표본 `allocation_*` · `realized_alloc_S7` POT 행).
  static const String potEngineColumnNote = '회계상 POT 는 A 로 올라갑니다(03 §2-9-3).';

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

  /// POT 서브북(보유 행).
  static String subBook(String alias) => 'POT 서브북 · A 하위($alias)';

  /// 🆕 R172 — 배분 행 이름(표본 `allocation_*`).
  static String sleeveRowLabel(SleeveId s) => switch (s) {
    SleeveId.pot => 'POT 서브북 (A 하위)',
    SleeveId.cash => '원화 현금 대기',
    _ => '슬리브 ${s.wire}',
  };

  /// 🆕 R172 — 배분 고지.
  static const String allocationNotice = '회계 기준입니다 — POT 는 A 에 포함됩니다';

  /// 🆕 R172 — 배분 빈 상태(총평가 0).
  static const String allocationEmpty = '배분 현황이 없습니다 · 첫 입금이 반영되면 엔진이 채웁니다';

  /// 🆕 R172 — 종목 손익 펼침.
  static const String pnlToggle = '종목 손익';

  /// 🆕 R172 — 손익 고지(기준 종가 날짜를 그대로 — 표본 «전일 종가»는 저녁 배치 뒤엔 그날 종가라 날짜로 말한다).
  static String pnlDisclosure(TradeDate day) => '${day.yyyyMmDd} 종가 기준 · 평가 손익';

  /// 🆕 R172 — 매수 결정 링크.
  static const String entryDecisionLink = '매수 결정 보기';

  /// 🆕 R172 — 손절선 없음(B · C = 리밸런싱 · A · POT = 계절 규칙).
  static const String noStopRebalance = '이 슬리브는 개별 손절선을 쓰지 않습니다 — 리밸런싱 규칙으로 관리';

  /// 🆕 R172 — 손절선 없음(A · POT).
  static const String noStopSeasonal = '이 슬리브는 개별 손절선을 쓰지 않습니다 — 계절 규칙으로 관리';

  /// 🆕 R172 — 최근 체결 없음(표본).
  static const String recentEmpty = '이 보유의 최근 체결이 없습니다';

  /// 🆕 R172 — 최근 체결이 있으나 목록 원천(매매일지 읽기 · q4a) 전 — 행을 지어내지 않는다.
  static String recentPending(int n) =>
      '이 보유의 체결 $n건 — 목록은 아직 준비 중입니다(매매일지 조립 뒤)';
}

String _pct(double x) => '${(x * 100).toStringAsFixed(1)}%';

/// 만원 단위(반올림 · 천 단위 쉼표) · 🆕 R172 — 정확히 0 = «0원»(표본).
String holdingsManwonText(Decimal won) {
  if (won == Decimal.zero) return '0원';
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

/// 부호 붙은 원(«+158,420원» · «−81,080원» · 0 = «0원» — 빼기 = U+2212 표본).
String _signedWon(Decimal v) {
  final BigInt n = v.round().toBigInt();
  if (n == BigInt.zero) return '0원';
  return '${n > BigInt.zero ? '+' : '−'}${_comma(n.abs().toString())}원';
}

/// 부호 붙은 %(소수 둘째 자리 · «+1.93%» · «−0.45%»).
String _signedPct(double x) {
  final String a = (x.abs() * 100).toStringAsFixed(2);
  if (a == '0.00') return '0.00%';
  return '${x > 0 ? '+' : '−'}$a%';
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

/// 보유 id(H6-1 행 · H6-2 열쇠).
String holdingIdOf(String strategyId, String symbol) =>
    'h_${strategyId}_$symbol';

/// 회계 장부 한 벌 — 🔴 H6-1 카드 · H6-2 행 · H6-3 배분이 같은 셈을 쓴다(월말 계획기 원천).
class _Book {
  _Book(this.f)
    : held = <HoldingPositionFact>[
        for (final HoldingPositionFact p in f.positions)
          if (p.quantity > 0) p,
      ] {
    final MonthEndState s = monthEndStateFromLedger(
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
      config: f.config.monthEnd,
      parkingSymbol: f.config.parkingSymbol,
    );
    Decimal sum(Iterable<Decimal?> vs) =>
        vs.fold(Decimal.zero, (Decimal x, Decimal? y) => y == null ? x : x + y);
    total = s.totalEquity;
    potAssets = sum(s.potAssets.values);
    potCash = s.potCash;
    bDeployed = sum(s.bAssets.values);
    bParking = s.bParking;
    // 🆕 R172 — C = 채권 + 금(투입) · 재분류 파킹 + 예약(파킹) · 원화 현금 = «원화 현금 대기» 행(02 H6-3 P 회차 · 표본).
    cDeployed = s.cBond + (s.cGold ?? Decimal.zero);
    cParking = s.bParkingReclassified + s.reservedKrw;
    krwCash = s.krwCash;
    aValue =
        total -
        potAssets -
        potCash -
        bDeployed -
        bParking -
        cDeployed -
        cParking -
        krwCash;
  }

  final HoldingsOverviewFacts f;
  final List<HoldingPositionFact> held;
  late final Decimal total;
  late final Decimal aValue;
  late final Decimal potAssets;
  late final Decimal potCash;
  late final Decimal bDeployed;
  late final Decimal bParking;
  late final Decimal cDeployed;
  late final Decimal cParking;
  late final Decimal krwCash;

  WhatIfConfig get cfg => f.config;

  /// 금액 · 비율 글자 가림 — INTEGRITY = «숨김» · RECON = 끝 «?».
  String money(String s) =>
      f.integrityHidden ? HoldingsTexts.hidden : (f.reconSuspect ? '$s?' : s);

  /// RECON 이 건드리지 않는 글자(평단 · 트랜치 — 표본) · INTEGRITY 만 가린다.
  String hideOnly(String s) => f.integrityHidden ? HoldingsTexts.hidden : s;

  double share(Decimal v) => total > Decimal.zero
      ? (v / total).toDecimal(scaleOnInfinitePrecision: 12).toDouble()
      : 0.0;

  double? ratio(Decimal part, Decimal whole) =>
      f.integrityHidden || whole <= Decimal.zero
      ? null
      : (part / whole).toDecimal(scaleOnInfinitePrecision: 12).toDouble();

  AsOf asOf(String label) => AsOf(
    observedAt: f.nowUtc.toUtc(),
    tradeDate: f.closeDate,
    source: AsOfSource.localSqlite,
    staleAfter: kHoldingsStaleAfter,
    label: label,
  );

  /// 배분 한 행.
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
    final String weightPct = _pct(share(sleeveValue));
    final String? note = sw != null
        ? null
        : money(switch (s) {
            SleeveId.a =>
              'A $weightPct · 목표 ${_pct((cfg.targetWeights[SleeveId.a] ?? Decimal.zero).toDouble())} — 계절 슬리브 · 밴드 판정 없음',
            SleeveId.pot => 'POT $weightPct — A 에 포함(회계 기준)',
            SleeveId.c => 'C $weightPct · 목표 잔여 — 게이지 없음',
            SleeveId.cash => '원화 현금 대기 $weightPct — 유휴가 아닙니다',
            _ => '${s.wire} $weightPct',
          });
    final bool hide = f.integrityHidden;
    return SleeveAllocationRow(
      sleeve: s,
      basis: AllocationBasis.accounting,
      deployedText: money(holdingsManwonText(deployed)),
      parkingText: money(holdingsManwonText(parking)),
      deployedRatio: ratio(deployed, both),
      parkingRatio: ratio(parking, both),
      trancheStateText: s == SleeveId.b
          ? hideOnly(_trancheText(f.bTranches))
          : hideOnly(HoldingsTexts.notApplicable),
      deployedPctText: money(_pct(share(deployed))),
      parkingPctText: money(_pct(share(parking))),
      parentSleeve: s == SleeveId.pot ? SleeveId.a : null,
      engineColumnNote: switch (s) {
        SleeveId.a => HoldingsTexts.engineColumnNote,
        SleeveId.pot => HoldingsTexts.potEngineColumnNote,
        _ => null,
      },
      parkingNoteText: s == SleeveId.b ? HoldingsTexts.bParkingNote : null,
      sleeveLabel: HoldingsTexts.sleeveRowLabel(s),
      sleeveWeight: hide || sw == null
          ? null
          : (f.reconSuspect ? sw.copyWith(label: '${sw.label}?') : sw),
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

  /// 🔴 배분 다섯 행(A → POT → B → C → 원화 현금 대기 · 표본 차례) — H6-1 카드 = 이 중 A · B · C 그대로.
  late final List<SleeveAllocationRow> rows = <SleeveAllocationRow>[
    row(
      SleeveId.a,
      deployed: aValue,
      parking: Decimal.zero,
      sleeveValue: aValue + potAssets + potCash,
    ),
    row(
      SleeveId.pot,
      deployed: potAssets,
      parking: potCash,
      sleeveValue: potAssets + potCash,
    ),
    row(
      SleeveId.b,
      deployed: bDeployed,
      parking: bParking,
      sleeveValue: bDeployed + bParking,
    ),
    row(
      SleeveId.c,
      deployed: cDeployed,
      parking: cParking,
      sleeveValue: cDeployed + cParking,
    ),
    row(
      SleeveId.cash,
      deployed: Decimal.zero,
      parking: krwCash,
      sleeveValue: krwCash,
    ),
  ];

  SleeveAllocationRow rowOf(SleeveId s) =>
      rows.firstWhere((SleeveAllocationRow r) => r.sleeve == s);

  /// 보유 한 행 — [includePnl] = 종목 손익(평단 · 기준 종가).
  HoldingRow holding(HoldingPositionFact p, {required bool includePnl}) {
    final Decimal close = f.closes[p.symbol]!;
    final Decimal value = close * Decimal.fromInt(p.quantity);
    final DecisionRef? d = p.entryDecision;
    if (d == null) {
      throw StateError('진입 결정 없음: ${p.strategyId} ${p.symbol}');
    }
    final SleeveId sleeve = _sleeveOf(p.strategyId);
    final String alias = f.accountAliasOf(p.strategyId);
    final String id = holdingIdOf(p.strategyId, p.symbol);
    final String detail = '${AppRoutes.holdingsDetail.split('/:').first}/$id';
    HoldingPnl? pnl;
    if (includePnl) {
      final Decimal unrealized =
          (close - p.avgPrice) * Decimal.fromInt(p.quantity);
      final double pct = p.avgPrice > Decimal.zero
          ? (close / p.avgPrice)
                    .toDecimal(scaleOnInfinitePrecision: 12)
                    .toDouble() -
                1
          : 0.0;
      pnl = HoldingPnl(
        unrealizedPnl: unrealized,
        pnlPct: pct,
        disclosureNote: HoldingsTexts.pnlDisclosure(f.closeDate),
        pnlText: money(_signedWon(unrealized)),
        pnlPctText: money(_signedPct(pct)),
      );
    }
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
      asOf: asOf('잔고 기준 ${f.closeDate.yyyyMmDd} 종가'),
      holdingId: id,
      pnl: pnl,
      quantityText: money('${_comma(p.quantity.toString())}주'),
      avgPriceText: hideOnly(_won(p.avgPrice)),
      weightText: money('비중 ${_pct(share(value))}'),
      subBookLabel: sleeve == SleeveId.pot
          ? HoldingsTexts.subBook(alias)
          : null,
      detailDeepLink: f.hasBody(AppRoutes.holdingsDetail) ? detail : null,
    );
  }

  List<HoldingRow> rowsOf(Set<String> strategies, {required bool includePnl}) {
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
    return <HoldingRow>[
      for (final HoldingPositionFact p in ps)
        holding(p, includePnl: includePnl),
    ];
  }
}

AsOf _overviewAsOf(HoldingsOverviewFacts f) => AsOf(
  observedAt: f.nowUtc.toUtc(),
  tradeDate: f.closeDate,
  source: AsOfSource.localSqlite,
  staleAfter: kHoldingsStaleAfter,
  label: '잔고 기준 ${f.closeDate.yyyyMmDd} 종가 · 엔진은 일 1회 배치',
);

/// 🔴 H6-1 VM — [includePnl] = 종목 손익 펼침(🆕 R172 · 평단 · 기준 종가).
HoldingsOverviewVm holdingsOverviewVmOf(
  HoldingsOverviewFacts f, {
  bool includePnl = false,
}) {
  if (!f.positions.any((HoldingPositionFact p) => p.quantity > 0)) {
    return HoldingsOverviewVm(
      cards: const <HoldingsSleeveCard>[],
      emptyLabel: HoldingsTexts.empty(f.nextTrancheDate),
      asOf: _overviewAsOf(f),
    );
  }
  final _Book b = _Book(f);
  final WhatIfConfig cfg = f.config;

  HoldingsSleeveCard card(SleeveId s, Set<String> strategies) {
    final List<HoldingRow> rows = b.rowsOf(strategies, includePnl: includePnl);
    return HoldingsSleeveCard(
      sleeve: s,
      titleText: cfg.sleeveLabels[s] ?? '슬리브 ${s.wire}',
      allocation: b.rowOf(s),
      rows: rows,
      rowsEmptyText: rows.isEmpty ? HoldingsTexts.rowsEmpty : null,
    );
  }

  return HoldingsOverviewVm(
    cards: <HoldingsSleeveCard>[
      card(SleeveId.a, const <String>{
        P0sStrategyIds.sleeveA,
        P0sStrategyIds.pot,
      }),
      card(SleeveId.b, const <String>{P0sStrategyIds.sleeveB}),
      card(SleeveId.c, const <String>{P0sStrategyIds.sleeveC}),
    ],
    allocationLink: f.hasBody(AppRoutes.holdingsAllocation)
        ? const LinkAction(
            label: HoldingsTexts.allocationLink,
            deepLink: AppRoutes.holdingsAllocation,
          )
        : null,
    pnlToggleLabel: HoldingsTexts.pnlToggle,
    asOf: _overviewAsOf(f),
  );
}

/// 🆕 R172 — H6-2 종목 상세 VM · 🔴 보유 행 = H6-1 과 같은 셈 · 없는 보유 = 실패(지어내지 않는다).
///
/// 손절선 = P0S 슬리브는 개별 손절선이 없다(B · C = 리밸런싱 규칙 · A · POT = 계절 규칙) · 최근 체결 = 체결이 없으면
/// 표본 문장 · 있으면 «준비 중» 문장(목록 원천 = 매매일지 읽기 · q4a — 행을 지어내지 않는다).
HoldingDetailVm holdingDetailVmOf(
  HoldingsOverviewFacts f,
  String holdingId, {
  bool includePnl = false,
}) {
  final HoldingPositionFact? p = f.positions
      .where(
        (HoldingPositionFact x) =>
            x.quantity > 0 && holdingIdOf(x.strategyId, x.symbol) == holdingId,
      )
      .firstOrNull;
  if (p == null) throw StateError('보유 없음: $holdingId');
  final _Book b = _Book(f);
  final HoldingRow row = b.holding(p, includePnl: includePnl);
  final SleeveId s = row.sleeve;
  final int fills = f.fillCounts[(p.strategyId, p.symbol)] ?? 0;
  final String sleeveLabel = s == SleeveId.pot
      ? '${f.config.sleeveLabels[SleeveId.a] ?? '슬리브 A'} · POT 서브북'
      : (f.config.sleeveLabels[s] ?? '슬리브 ${s.wire}');
  return HoldingDetailVm(
    holding: row,
    sleeveLabel: sleeveLabel,
    entryDecisionLink: LinkAction(
      label: HoldingsTexts.entryDecisionLink,
      deepLink:
          '${AppRoutes.journalDecision.split('/:').first}/${row.entryDecision.decisionId}',
    ),
    stopLines: const <StopLineNormalized>[],
    noStopLineText: s == SleeveId.a || s == SleeveId.pot
        ? HoldingsTexts.noStopSeasonal
        : HoldingsTexts.noStopRebalance,
    recentEntries: const <TradeJournalEntry>[],
    recentEmptyLabel: fills == 0
        ? HoldingsTexts.recentEmpty
        : HoldingsTexts.recentPending(fills),
    pnlToggleLabel: HoldingsTexts.pnlToggle,
    asOf: _overviewAsOf(f),
  );
}

/// 🆕 R172 — H6-3 슬리브 배분 VM — 🔴 행 = H6-1 카드와 같은 셈(A → POT → B → C → 원화 현금 대기) · 총평가 0 = 빈 상태.
SleeveAllocationVm sleeveAllocationVmOf(HoldingsOverviewFacts f) {
  final AsOf asOf = AsOf(
    observedAt: f.nowUtc.toUtc(),
    tradeDate: f.closeDate,
    source: AsOfSource.localSqlite,
    staleAfter: kHoldingsStaleAfter,
    label: '배분 기준 ${f.closeDate.yyyyMmDd} 종가',
  );
  final _Book b = _Book(f);
  if (b.total <= Decimal.zero) {
    return SleeveAllocationVm(
      rows: const <SleeveAllocationRow>[],
      emptyLabel: HoldingsTexts.allocationEmpty,
      asOf: asOf,
    );
  }
  return SleeveAllocationVm(
    rows: b.rows,
    noticeText: HoldingsTexts.allocationNotice,
    asOf: asOf,
  );
}
