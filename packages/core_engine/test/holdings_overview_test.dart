// E11q1 — M6 H6-1 보유 현황 VM(설계 13 §8 R171).
//
// 🔴 회계 = 월말 계획기와 한 원천(`monthEndStateFromLedger` · `sleeveWeightsOf`) · 비중 줄 = 미리보기와 한 생산 ·
//    가림(«숨김» · «?») = 엔진 · 없는 화면 링크 0 · 빈 보유 = 표본 `m6/holdings_overview_empty` 값 그대로.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _day = TradeDate('2026-08-31');
final DateTime _now = DateTime.utc(2026, 8, 31, 9);

HoldingPositionFact _p(
  String strategy,
  String symbol,
  int qty,
  String avg, {
  bool decision = true,
}) => HoldingPositionFact(
  strategyId: strategy,
  symbol: symbol,
  quantity: qty,
  avgPrice: _d(avg),
  entryDate: const TradeDate('2026-08-03'),
  entryDecision: decision
      ? DecisionRef(
          decisionId: 'd_$strategy$symbol',
          intentId: 'i_$symbol',
          configHash: 'cfg_t',
        )
      : null,
);

String _alias(String s) => switch (s) {
  P0sStrategyIds.sleeveB => '연금저축',
  P0sStrategyIds.sleeveC => '일반 위탁',
  _ => 'ISA',
};

HoldingsOverviewFacts _facts({
  List<HoldingPositionFact>? positions,
  Map<String, Decimal>? closes,
  String cash = '1000000',
  String pot = '0',
  Map<String, int?> tranches = const <String, int?>{'133690': 2, '411060': 2},
  bool integrity = false,
  bool recon = false,
  bool Function(String)? hasBody,
}) => HoldingsOverviewFacts(
  positions:
      positions ??
      <HoldingPositionFact>[
        _p(P0sStrategyIds.sleeveA, '229200', 100, '10000'),
        _p(P0sStrategyIds.sleeveB, '133690', 200, '20000'),
        _p(P0sStrategyIds.sleeveB, '214980', 10, '100000'),
        _p(P0sStrategyIds.sleeveC, '0085P0', 50, '10000'),
        _p(P0sStrategyIds.pot, '133690', 5, '20000'),
      ],
  closes:
      closes ??
      <String, Decimal>{
        '229200': _d('10000'),
        '133690': _d('21000'),
        '214980': _d('100000'),
        '0085P0': _d('10000'),
        '411060': _d('20000'),
      },
  closeDate: _day,
  cashKrw: _d(cash),
  potCash: _d(pot),
  config: WhatIfConfig.defaults,
  accountAliasOf: _alias,
  bTranches: tranches,
  nextTrancheDate: const TradeDate('2026-09-30'),
  integrityHidden: integrity,
  reconSuspect: recon,
  hasBody: hasBody ?? (String _) => false,
  nowUtc: _now,
);

void main() {
  test('빈 보유 = 표본 m6/holdings_overview_empty 그대로', () {
    final Map<String, Object?> d = jsonDecode(
      File('../domain_contracts/fixtures/m6/holdings_overview_empty.json')
          .readAsStringSync(),
    ) as Map<String, Object?>;
    final Object? row = d['rows'] is List<Object?>
        ? (d['rows']! as List<Object?>).first
        : d;
    expect(
      holdingsOverviewVmOf(_facts(positions: const <HoldingPositionFact>[])),
      HoldingsOverviewVm.fromJson(row! as Map<String, Object?>),
    );
  });

  group('회계 = 월말 계획기와 한 원천', () {
    // A 100×10,000 = 100만 · B 200×21,000 = 420만 + 파킹 10×100,000 = 100만 · C 50×10,000 = 50만
    // · POT 5×21,000 = 10.5만 + POT 현금 0 · 현금 100만(= C 원화) → 총 780.5만.
    final HoldingsOverviewVm vm = holdingsOverviewVmOf(_facts());

    test('카드 A · B · C 차례 · 제목 = 엔진 이름표', () {
      expect(vm.cards.map((HoldingsSleeveCard c) => c.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.b,
        SleeveId.c,
      ]);
      expect(vm.cards.first.titleText, 'A · 국내 지수 ETF');
      expect(vm.emptyLabel, isNull);
      expect(vm.external, isNull);
      expect(vm.asOf.label, '잔고 기준 2026-08-31 종가 · 엔진은 일 1회 배치');
    });

    test('🔴 B 비중 줄 = 미리보기와 같은 생산 · 밴드 · 막대', () {
      final SleeveAllocationRow b = vm.cards[1].allocation;
      final SleeveWeight w = sleeveWeightOf(
        SleeveId.b,
        _d('5200000'),
        _d('7805000'),
        _d('0.42'),
        _d('0.03'),
      );
      expect(b.sleeveWeight, w);
      expect(b.sleeveWeight!.label, startsWith('B 66.6% (목표 42.0%'));
      expect(b.bandState, SleeveBandState.outOfBand);
      expect(b.bandStateLabel, HoldingsTexts.outOfBand);
      expect(b.gauge!.actualNormalized, 1.0, reason: '밴드 밖 = 끝에서 자름');
      expect(b.deployedText, '420만원');
      expect(b.parkingText, '100만원');
      expect(b.parkingNoteText, HoldingsTexts.bParkingNote);
      expect(b.trancheStateText, 'B 트랜치 2/3 — SMA 신호 2개 점등');
      expect(b.bandNoteText, isNull);
    });

    test('A 줄 = POT 포함 비중 · 계절 슬리브 문장 · C = 목표 잔여 · 밴드 0', () {
      final SleeveAllocationRow a = vm.cards[0].allocation;
      final Map<String, double> sw = sleeveWeightsOf(
        monthEndStateFromLedger(
          holdings: const <LedgerHolding>[
            LedgerHolding(P0sStrategyIds.sleeveA, '229200', 100),
            LedgerHolding(P0sStrategyIds.sleeveB, '133690', 200),
            LedgerHolding(P0sStrategyIds.sleeveB, '214980', 10),
            LedgerHolding(P0sStrategyIds.sleeveC, '0085P0', 50),
            LedgerHolding(P0sStrategyIds.pot, '133690', 5),
          ],
          closes: <String, Decimal>{
            '229200': _d('10000'),
            '133690': _d('21000'),
            '214980': _d('100000'),
            '0085P0': _d('10000'),
            '411060': _d('20000'),
          },
          cashKrw: _d('1000000'),
          potCash: Decimal.zero,
          reservedKrw: Decimal.zero,
          pensionUsedThisYear: Decimal.zero,
          monthIndex: 1,
          regimeState: null,
          monthlyCloses: const <String, List<double>>{},
          hasNextKrSession: false,
          hasNextUsSession: false,
          config: WhatIfConfig.defaults.monthEnd,
          parkingSymbol: WhatIfConfig.defaults.parkingSymbol,
        ),
      );
      final String aPct =
          '${(((sw['A'] ?? 0) + (sw['POT'] ?? 0)) * 100).toStringAsFixed(1)}%';
      expect(a.bandNoteText, 'A $aPct · 목표 20.0% — 계절 슬리브 · 밴드 판정 없음');
      expect(a.sleeveWeight, isNull);
      expect(a.bandState, isNull);
      expect(a.gauge, isNull);
      expect(a.trancheStateText, HoldingsTexts.notApplicable);
      expect(a.engineColumnNote, HoldingsTexts.engineColumnNote);
      final SleeveAllocationRow c = vm.cards[2].allocation;
      final String cPct = '${((sw['C'] ?? 0) * 100).toStringAsFixed(1)}%';
      expect(c.bandNoteText, 'C $cPct · 목표 잔여 — 게이지 없음');
      expect(c.deployedText, '150만원', reason: 'C = 채권 50만 + 원화 100만');
    });

    test('행 = 평가액 내림차순 · POT 는 A 카드 맨 끝 · 서브북 · 표시 글자', () {
      final List<HoldingRow> a = vm.cards[0].rows;
      expect(a.map((HoldingRow r) => r.symbol), <String>['229200', '133690']);
      expect(a.last.sleeve, SleeveId.pot);
      expect(a.last.subBookLabel, 'POT 서브북 · A 하위(ISA)');
      expect(a.first.subBookLabel, isNull);
      expect(a.first.symbolLabel, '229200', reason: '이름표 없음 = 코드 그대로');
      final List<HoldingRow> b = vm.cards[1].rows;
      expect(b.map((HoldingRow r) => r.symbol), <String>['133690', '214980']);
      expect(b.first.symbolLabel, '133690 TIGER 미국나스닥100');
      expect(b.first.accountAlias, '연금저축');
      expect(b.first.quantityText, '200주');
      expect(b.first.avgPriceText, '20,000원');
      expect(b.first.weightText, '비중 53.8%');
      expect(b.first.entryDecision.decisionId, 'd_P0S_B133690');
      expect(b.first.entryReasons.single.code, 'MONTHLY_REGULAR');
      expect(b.first.detailDeepLink, isNull, reason: 'H6-2 미등록');
      expect(vm.allocationLink, isNull, reason: 'H6-3 미등록');
    });
  });

  test('등록되면 상세 · 배분 링크가 선다', () {
    final HoldingsOverviewVm vm = holdingsOverviewVmOf(
      _facts(hasBody: (String _) => true),
    );
    expect(
      vm.cards[1].rows.first.detailDeepLink,
      'aaq://holdings/detail/h_P0S_B_133690',
    );
    expect(vm.allocationLink?.deepLink, AppRoutes.holdingsAllocation);
  });

  test('🔴 LEDGER_INTEGRITY = «숨김» · 비율 · 밴드 칸 null', () {
    final HoldingsOverviewVm vm = holdingsOverviewVmOf(_facts(integrity: true));
    final SleeveAllocationRow b = vm.cards[1].allocation;
    expect(b.deployedText, HoldingsTexts.hidden);
    expect(b.parkingPctText, HoldingsTexts.hidden);
    expect(b.trancheStateText, HoldingsTexts.hidden);
    expect(b.deployedRatio, isNull);
    expect(b.parkingRatio, isNull);
    expect(b.sleeveWeight, isNull);
    expect(b.gauge, isNull);
    expect(b.bandNoteText, HoldingsTexts.hidden);
    expect(vm.cards[0].allocation.bandNoteText, HoldingsTexts.hidden);
    expect(vm.cards[0].allocation.trancheStateText, HoldingsTexts.hidden);
    expect(vm.cards[2].allocation.trancheStateText, HoldingsTexts.hidden);
    expect(vm.cards[1].rows.first.quantityText, HoldingsTexts.hidden);
    expect(vm.cards[1].rows.first.weightText, HoldingsTexts.hidden);
  });

  test('🔴 RECON_MISMATCH = 끝 «?»', () {
    final HoldingsOverviewVm vm = holdingsOverviewVmOf(_facts(recon: true));
    expect(vm.cards[1].allocation.deployedText, '420만원?');
    expect(vm.cards[1].rows.first.quantityText, '200주?');
    expect(vm.cards[1].allocation.deployedRatio, isNotNull);
  });

  test('트랜치 = 자산마다 다르면 자산별 · 하나라도 모르면 «모자랍니다»', () {
    expect(
      holdingsOverviewVmOf(
        _facts(tranches: const <String, int?>{'133690': 2, '411060': 3}),
      ).cards[1].allocation.trancheStateText,
      'B 트랜치 133690 2/3 · 411060 3/3 — SMA 신호 점등',
    );
    expect(
      holdingsOverviewVmOf(
        _facts(tranches: const <String, int?>{'133690': 2, '411060': null}),
      ).cards[1].allocation.trancheStateText,
      HoldingsTexts.trancheUnknown,
    );
  });

  test('🔴 진입 결정 없는 보유 = 실패(행을 지어내지 않는다) · 귀속 불가 = 실패', () {
    expect(
      () => holdingsOverviewVmOf(
        _facts(
          positions: <HoldingPositionFact>[
            _p(P0sStrategyIds.sleeveB, '133690', 1, '1', decision: false),
          ],
        ),
      ),
      throwsStateError,
    );
    expect(
      () => holdingsOverviewVmOf(
        _facts(
          positions: <HoldingPositionFact>[_p('SAT_X', '005930', 1, '1')],
          closes: <String, Decimal>{'005930': _d('1')},
        ),
      ),
      throwsA(isA<Object>()),
    );
  });

  group('🔴 원장 글자 → 사실(data_sync 는 Decimal 을 쓰지 않는다)', () {
    HoldingsOverviewFacts ledger({
      Map<String, String> closes = const <String, String>{'133690': '21000'},
      Map<String, String> cash = const <String, String>{
        'pension': '1000',
        'general': '250.5',
      },
      String pot = '0',
    }) => HoldingsOverviewFacts.ledger(
      positions: <HoldingPositionFact>[
        HoldingPositionFact.ledger(
          strategyId: P0sStrategyIds.sleeveB,
          symbol: '133690',
          quantity: 1,
          avgPrice: 20000.5,
          entryDate: const TradeDate('2026-08-03'),
          entryDecision: null,
        ),
      ],
      closeTexts: closes,
      closeDate: _day,
      cashTexts: cash,
      potCashText: pot,
      config: WhatIfConfig.defaults,
      accountAliasOf: _alias,
      bTranches: const <String, int?>{},
      nextTrancheDate: null,
      integrityHidden: false,
      reconSuspect: false,
      hasBody: (String _) => false,
      nowUtc: _now,
    );

    test('현금 = 계좌 글자 합 · 평단 = 실수 그대로 · 종가 = 숫자이고 0 보다 큰 것만', () {
      final HoldingsOverviewFacts f = ledger(
        closes: const <String, String>{
          '133690': '21000',
          '214980': '0',
          '411060': '-1',
          '0085P0': 'abc',
        },
      );
      expect(f.cashKrw, _d('1250.5'));
      expect(f.potCash, Decimal.zero);
      expect(f.closes, <String, Decimal>{'133690': _d('21000')});
      expect(f.positions.single.avgPrice, _d('20000.5'));
    });

    test('🔴 현금 · POT 글자가 숫자가 아니거나 POT 음수 = 실패(0 으로 지어내지 않는다)', () {
      expect(
        () => ledger(cash: const <String, String>{'general': 'x'}),
        throwsArgumentError,
      );
      expect(() => ledger(pot: '-1'), throwsArgumentError);
      expect(() => ledger(pot: 'x'), throwsArgumentError);
      expect(ledger(pot: '3').potCash, _d('3'));
    });
  });

  group('밴드 상태 · 막대 · 점등 수', () {
    SleeveWeight w(double weight) => SleeveWeight(
      sleeve: SleeveId.b,
      weight: weight,
      targetWeight: 0.42,
      bandLow: 0.39,
      bandHigh: 0.45,
      label: '',
      basis: AllocationBasis.accounting,
    );
    test('경계 근접 = 밴드 반폭의 20% 안', () {
      expect(sleeveBandStateOf(w(0.42)), SleeveBandState.inBand);
      expect(sleeveBandStateOf(w(0.445)), SleeveBandState.nearEdge);
      expect(sleeveBandStateOf(w(0.436)), SleeveBandState.inBand);
      expect(
        sleeveBandStateOf(w(0.441)),
        SleeveBandState.inBand,
        reason: '여유 0.9%p > 반폭 3%p × 20%',
      );
      expect(sleeveBandStateOf(w(0.46)), SleeveBandState.outOfBand);
      expect(sleeveBandStateOf(w(0.38)), SleeveBandState.outOfBand);
    });
    test('막대 = 밴드 0.25~0.75 · 목표 0.5 · 표본 꼴(0.426 → 0.55)', () {
      final SleeveBandGauge g = sleeveBandGaugeOf(w(0.426));
      expect(g.actualNormalized, closeTo(0.55, 1e-9));
      expect(g.targetNormalized, 0.5);
      expect(g.bandLowNormalized, 0.25);
      expect(g.bandHighNormalized, 0.75);
      expect(sleeveBandGaugeOf(w(0.30)).actualNormalized, 0.0);
    });
    test('점등 수 = 월말 계획기 함수 × 3 · 짧으면 null', () {
      final List<double> up = <double>[for (int i = 1; i <= 13; i++) 100.0 + i];
      final Map<String, int?> t = bTrancheSignalsOf(<String, List<double>>{
        '133690': up,
        '411060': const <double>[1, 2, 3],
      }, WhatIfConfig.defaults);
      expect(t['133690'], 3);
      expect(t['411060'], isNull);
    });
    test('만원 표기 = 반올림 · 쉼표', () {
      expect(holdingsManwonText(_d('14150000')), '1,415만원');
      expect(holdingsManwonText(_d('4999')), '0만원');
      expect(holdingsManwonText(_d('5000')), '1만원');
    });
  });
}
