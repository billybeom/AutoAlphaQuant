// E11q2 — 원장 사실 → What-if 상태(설계 13 §8 R173 · R18 D-4 실데이터 어댑터).
//
// 🔴 보유 현황 장부(H6-1)와 같은 장부 · 회계 평가액 = 미리보기 비중과 같은 셈 · 연금 누계 = 등록과 같은 함수 ·
//    미리보기는 이 상태로 실집행과 같은 경로(월말 계획기)를 돈다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _day = TradeDate('2026-08-31');
final DateTime _now = DateTime.utc(2026, 8, 31, 9);

HoldingPositionFact _p(String strategy, String symbol, int qty) =>
    HoldingPositionFact(
      strategyId: strategy,
      symbol: symbol,
      quantity: qty,
      avgPrice: _d('10000'),
      entryDate: const TradeDate('2026-08-03'),
      entryDecision: DecisionRef(
        decisionId: 'd_$symbol',
        intentId: 'i_$symbol',
        configHash: 'cfg_t',
      ),
    );

HoldingsOverviewFacts _facts({String cash = '20000000', String pot = '0'}) =>
    HoldingsOverviewFacts(
      positions: <HoldingPositionFact>[
        _p(P0sStrategyIds.sleeveA, '229200', 1000),
        _p(P0sStrategyIds.sleeveB, '133690', 2000),
        _p(P0sStrategyIds.sleeveC, '0085P0', 2000),
        _p(P0sStrategyIds.pot, '133690', 50),
      ],
      closes: <String, Decimal>{
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
      accountAliasOf: (String s) => s,
      bTranches: const <String, int?>{'133690': 2, '411060': 2},
      nextTrancheDate: const TradeDate('2026-09-30'),
      integrityHidden: false,
      reconSuspect: false,
      hasBody: (String _) => false,
      nowUtc: _now,
      fillCounts: const <(String, String), int>{},
    );

LedgerCashRow _cash(String alias, String amount, String day) => LedgerCashRow(
  kind: CashFlowKind.deposit,
  accountAlias: alias,
  amount: _d(amount),
  tradeDate: TradeDate(day),
);

WhatIfState _state({
  HoldingsOverviewFacts? facts,
  List<BlockFlag> flags = const <BlockFlag>[],
  bool recovery = false,
  String outside = '100000',
  String? pension = '연금저축',
}) => whatIfStateFromLedger(
  facts: facts ?? _facts(),
  pensionRows: <LedgerCashRow>[
    _cash('연금저축', '3000000', '2026-03-02'),
    _cash('연금저축', '5000000', '2025-12-01'),
    _cash('일반 위탁', '7000000', '2026-03-02'),
  ],
  pensionOutsideText: outside,
  monthIndex: 3,
  regimeState: null,
  monthlyCloses: const <String, List<double>>{},
  hasNextKrSession: true,
  hasNextUsSession: true,
  configHash: 'cfg_t',
  activeFlags: flags,
  recovery: recovery,
  accounts: WhatIfAccounts(pensionAlias: pension, generalAlias: '일반 위탁'),
  krCalendar: frozenExchangeCalendar(Market.kr),
  unknownSymbols: const <String>{'133690'},
);

class _Src implements WhatIfStateSource {
  _Src(this.s);
  final WhatIfState s;
  @override
  Future<WhatIfState> load() async => s;
}

class _Clock implements Clock {
  @override
  DateTime nowUtc() => _now;
}

Future<RebalancePreviewResult> _preview(WhatIfState s) => EngineWhatIfApi(
  source: _Src(s),
  store: InMemoryPlanSnapshotStore(),
  clock: _Clock(),
).previewRebalance();

void main() {
  test('장부 그대로 — 기준일 · 지정가 기준 = 원가 종가 · 연금 누계(그해 · 연금 계좌만 + 밖 신고) · 회차 번호', () {
    final HoldingsOverviewFacts f = _facts();
    final WhatIfState s = _state(facts: f);
    expect(s.asOfTradeDate, _day);
    expect(s.prices, f.closes);
    expect(s.observedAt, _now);
    expect(s.source, AsOfSource.localSqlite);
    expect(s.configHash, 'cfg_t');
    expect(s.pensionUsedThisYear, _d('3100000'));
    expect(s.monthEnd!.pensionUsedThisYear, _d('3100000'));
    expect(s.monthEnd!.monthIndex, 3);
    expect(s.unknownSymbols, <String>{'133690'});
    // 1000×10,000 + 2050×21,000 + 2000×10,000 + 현금 2,000만 = 9,305만.
    expect(s.monthEnd!.totalEquity, _d('93050000'));
    expect(
      _state(pension: null).pensionUsedThisYear,
      _d('100000'),
      reason: '연금 계좌 매핑 전 = 밖 신고만',
    );
    expect(() => _state(outside: '-1'), throwsArgumentError);
  });

  test('회계 평가액 = 미리보기 비중과 같은 셈(A = POT 포함 · C = 원화 현금 · 채권) · 합 = 총평가', () {
    final WhatIfState s = _state();
    expect(s.sleeveValues, accountingSleeveValuesOf(s.monthEnd!));
    expect(
      s.sleeveValues[SleeveId.a],
      _d('11050000'),
      reason: 'A 1,000만 + POT 105만',
    );
    expect(s.sleeveValues[SleeveId.b], _d('42000000'));
    expect(s.sleeveValues[SleeveId.c], _d('40000000'));
    expect(
      s.sleeveValues.values.fold(Decimal.zero, (Decimal a, Decimal b) => a + b),
      s.monthEnd!.totalEquity,
    );
  });

  test(
    '미리보기 = 이 상태로 계산(다음 정기 회차 · 전 비중 = 평가액 · 체결 확인 중 종목 문장) · 차단 · 복구 = 그 갈래',
    () async {
      final WhatIfState s = _state();
      final RebalancePreview p = (await _preview(s)).preview!;
      expect(p.plannedDate, const TradeDate('2026-09-01'));
      expect(p.asOf.tradeDate, _day);
      expect(p.before.map((SleeveWeight w) => w.weight), <double>[
        for (final SleeveId x in <SleeveId>[SleeveId.a, SleeveId.b, SleeveId.c])
          (s.sleeveValues[x]! / s.monthEnd!.totalEquity)
              .toDecimal(scaleOnInfinitePrecision: 12)
              .toDouble(),
      ]);
      expect(p.orderDrafts, isNotEmpty, reason: 'B 45.1% = 밴드 상단 밖');
      for (final OrderDraft d in p.orderDrafts) {
        expect(
          d.pendingNoteText,
          d.symbol == '133690' ? RebalancePreviewTexts.pending : isNull,
        );
      }
      final RebalancePreviewResult blocked = await _preview(
        _state(
          flags: <BlockFlag>[
            BlockFlag.fromJson(<String, Object?>{
              'flag_id': FlagIds.ledgerIntegrity,
              'label': '무결성',
              'set_at': '2026-08-28T01:00:00Z',
              'clear_route': 'WIZARD_ONLY',
              'clear_instruction': '해소 안내',
              'clear_deep_link': null,
            }),
          ],
        ),
      );
      expect(blocked.preview, isNull);
      expect(blocked.blockedText, RebalanceGateTexts.integrity);
      expect(
        (await _preview(_state(recovery: true))).blockedText,
        RebalanceGateTexts.recovery,
      );
    },
  );
}
