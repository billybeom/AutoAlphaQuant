// P0S 월간 SAF-306(04 §1 Level 3 v2.46 306 행 · 설계 13 §8 R175 · E3d-3) — 평균 단가 양의 실현이익 · 분배금 ·
// 과세연도 경계 · 상한 포함(== 통과) · 과세연도 첫 초과 월 1건 · 종목 거르기 · fail-closed.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

LedgerFillRow _f(
  String id, {
  OrderSide side = OrderSide.buy,
  required int q,
  required double px,
  required String day,
  FillKind kind = FillKind.original,
  String? reverses,
}) => LedgerFillRow(
  executionId: id,
  kind: kind,
  side: side,
  quantity: q,
  price: px,
  brokerOrderNo: 'o-$id',
  tradeDate: day,
  decisionId: 'D-$id',
  reversesFillId: reverses,
);

LedgerFillRow _sell(String id, int q, double px, String day) =>
    _f(id, side: OrderSide.sell, q: q, px: px, day: day);

/// 0085P0(과세 해외 ETF) — 평균 단가 10,000 고정(매도는 평단을 바꾸지 않는다).
/// 2026-12-20 이익 400만(지난해) · 2027-01 1,500만 · 02 분배금 300만 · 03 200만(누계 = 상한 정확히) ·
/// 04 100원(넘음) · 05 손실(버림) · 2028-01 2,200만 200원(새 해 다시 넘음).
final List<LedgerFillRow> _bond = <LedgerFillRow>[
  _f('b1', q: 2000, px: 10000, day: '2026-12-15'),
  _sell('s0', 100, 50000, '2026-12-20'),
  _sell('s1', 1000, 25000, '2027-01-20'),
  _sell('s2', 500, 14000, '2027-03-31'),
  _sell('s3', 100, 10001, '2027-04-30'),
  _sell('s4', 100, 9000, '2027-05-10'),
  _sell('s5', 200, 120001, '2028-01-14'),
];

final List<P0sDistribution> _dist = <P0sDistribution>[
  P0sDistribution(
    effectiveDate: '2027-02-28',
    symbol: '0085P0',
    amountKrw: _d('3000000'),
  ),
  // 파킹(국내 ETF) — 세지 않는다.
  P0sDistribution(
    effectiveDate: '2027-04-10',
    symbol: '214980',
    amountKrw: _d('5000000'),
  ),
  // 6월 1일 = 6월 몫(5월 누계에 들지 않는다 — 달 경계).
  P0sDistribution(
    effectiveDate: '2027-06-01',
    symbol: '0085P0',
    amountKrw: _d('1'),
  ),
];

final P0sIncomeWarnSetup _setup = P0sIncomeWarnSetup(
  taxableAccountAlias: 'GEN',
);

P0sIncomeWarnStep _step(
  String month, {
  Map<String, List<LedgerFillRow>>? fills,
  List<P0sDistribution>? dist,
}) => p0sMonthlyIncomeWarnStep(
  month: month,
  fillsBySymbol: fills ?? <String, List<LedgerFillRow>>{'0085P0': _bond},
  distributions: dist ?? _dist,
  setup: _setup,
);

void main() {
  group('설정', () {
    test('과세 종목 = 해외 ETF(B 자산 · C 채권 · C 금) · 파킹 빠짐 · 상한 2,000만', () {
      expect(_setup.taxableSymbols, <String>{'133690', '411060', '0085P0'});
      expect(_setup.capKrw, _d('20000000'));
      expect(p0sFinancialIncomeCapKrw(), _d('20000000'));
      expect(
        () => P0sIncomeWarnSetup(taxableAccountAlias: ''),
        throwsArgumentError,
      );
    });

    test('판정 한 줄 — 상한 포함(== 통과) · 1원 넘으면 발동', () {
      expect(financialIncomeCapExceeded(_d('20000000'), _d('20000000')), false);
      expect(financialIncomeCapExceeded(_d('20000001'), _d('20000000')), true);
      expect(financialIncomeCapExceeded(_d('19999999'), _d('20000000')), false);
    });

    test('분배금 0 이하 = ArgumentError', () {
      expect(
        () => P0sDistribution(
          effectiveDate: '2027-01-02',
          symbol: '0085P0',
          amountKrw: Decimal.zero,
        ),
        throwsArgumentError,
      );
    });
  });

  group('양의 실현이익(평균 단가)', () {
    test('두 번 산 평단 · 손실 건은 버린다 · 이익은 매도 거래일에', () {
      final List<(String, Decimal)> g = positiveRealizedGainsOf(<LedgerFillRow>[
        _f('a', q: 100, px: 10000, day: '2027-01-02'),
        _f('b', q: 100, px: 12000, day: '2027-01-03'),
        _sell('c', 50, 13000, '2027-01-04'), // 50 × (13,000 − 11,000)
        _sell('d', 50, 9000, '2027-01-05'), // 손실 — 버림
      ]);
      expect(g, <(String, Decimal)>[('2027-01-04', _d('100000'))]);
    });

    test('매도는 평단을 바꾸지 않는다 — 부분 매도 뒤 산 값이 평단에 섞인다', () {
      final List<(String, Decimal)> g = positiveRealizedGainsOf(<LedgerFillRow>[
        _f('a', q: 100, px: 100, day: '2027-01-02'),
        _sell('b', 50, 100, '2027-01-03'), // 0
        _f(
          'c',
          q: 50,
          px: 200,
          day: '2027-01-04',
        ), // 평단 (5,000 + 10,000) ÷ 100 = 150
        _sell('d', 100, 160, '2027-01-05'), // 100 × 10
      ]);
      expect(g, <(String, Decimal)>[('2027-01-05', _d('1000'))]);
    });

    test('되돌린 매수는 평단에 들지 않는다(REVERSAL)', () {
      final List<(String, Decimal)> g = positiveRealizedGainsOf(<LedgerFillRow>[
        _f('a', q: 10, px: 100, day: '2027-01-02'),
        _f('b', q: 10, px: 300, day: '2027-01-02'),
        _f(
          'b|REV',
          kind: FillKind.reversal,
          reverses: 'b',
          q: 10,
          px: 300,
          day: '2027-01-02',
        ),
        _sell('c', 10, 200, '2027-01-03'), // 평단 100 → 1,000(되돌림을 세면 평단 200 → 0)
      ]);
      expect(g, <(String, Decimal)>[('2027-01-03', _d('1000'))]);
    });

    test('다 판 뒤 다시 사면 새 평단', () {
      final List<(String, Decimal)> g = positiveRealizedGainsOf(<LedgerFillRow>[
        _f('a', q: 3, px: 100, day: '2027-01-02'),
        _sell('b', 3, 150, '2027-01-03'), // 150
        _f('c', q: 3, px: 200, day: '2027-01-04'),
        _sell('d', 3, 210, '2027-01-05'), // 30
      ]);
      expect(g, <(String, Decimal)>[
        ('2027-01-03', _d('150')),
        ('2027-01-05', _d('30')),
      ]);
    });

    test('🔴 매도 > 보유(평균 단가 모름) · 산 적 없는 매도 · 링크 깨짐 = RiskCheckUnavailable', () {
      expect(
        () => positiveRealizedGainsOf(<LedgerFillRow>[
          _f('a', q: 1, px: 100, day: '2027-01-02'),
          _sell('b', 2, 100, '2027-01-03'),
        ]),
        throwsA(isA<RiskCheckUnavailable>()),
      );
      expect(
        () => positiveRealizedGainsOf(<LedgerFillRow>[
          _sell('b', 1, 100, '2027-01-03'),
        ]),
        throwsA(isA<RiskCheckUnavailable>()),
      );
      expect(
        () => positiveRealizedGainsOf(<LedgerFillRow>[
          _f(
            'x|REV',
            kind: FillKind.reversal,
            reverses: 'x',
            q: 1,
            px: 100,
            day: '2027-01-02',
          ),
        ]),
        throwsA(isA<RiskCheckUnavailable>()),
      );
    });
  });

  group('월간 단계 — 과세연도 누계 · 첫 초과 월', () {
    test('1월 = 지난해 이익을 세지 않는다 · 지난달 누계 0', () {
      final P0sIncomeWarnStep s = _step('2027-01');
      expect(s.ytd!.realizedGainKrw, _d('15000000'));
      expect(s.ytd!.distributionKrw, Decimal.zero);
      expect(s.previousYtd!.totalKrw, Decimal.zero);
      expect(s.exceeded, false);
      expect(s.alerts, isEmpty);
      expect(s.unavailable, isNull);
    });

    test('12월 = 그해 끝까지(다음 해 1월 매도는 빠진다)', () {
      final P0sIncomeWarnStep s = _step('2026-12');
      expect(s.ytd!.totalKrw, _d('4000000'));
      expect(s.previousYtd!.totalKrw, Decimal.zero);
    });

    test('분배금 = 달 마지막 날까지 든다 · 국내 ETF(파킹) 분배금은 빠진다', () {
      expect(_step('2027-01').ytd!.distributionKrw, Decimal.zero);
      final P0sIncomeWarnStep feb = _step('2027-02');
      expect(feb.ytd!.distributionKrw, _d('3000000'));
      expect(feb.ytd!.totalKrw, _d('18000000'));
      expect(_step('2027-04').ytd!.distributionKrw, _d('3000000'));
    });

    test('상한과 같다 = 통과(3월 누계 2,000만 정확히)', () {
      final P0sIncomeWarnStep s = _step('2027-03');
      expect(s.ytd!.totalKrw, _d('20000000'));
      expect(s.exceeded, false);
      expect(s.alerts, isEmpty);
    });

    test('🔴 넘은 첫 달만 알림 — 4월 넘음 = 1건 · 5월 머묾 = 0', () {
      final P0sIncomeWarnStep apr = _step('2027-04');
      expect(apr.ytd!.totalKrw, _d('20000100'));
      expect(apr.previousYtd!.totalKrw, _d('20000000'));
      expect(apr.exceeded, true);
      expect(apr.alerts, <String>[kFinancialIncomeAlertCode]);

      final P0sIncomeWarnStep may = _step('2027-05');
      expect(may.ytd!.totalKrw, _d('20000100')); // 5월 손실은 통산하지 않는다
      expect(may.exceeded, true);
      expect(may.alerts, isEmpty);

      final P0sIncomeWarnStep jun = _step('2027-06');
      expect(jun.ytd!.totalKrw, _d('20000101')); // 6월 1일 분배금
      expect(jun.alerts, isEmpty);
    });

    test('새 과세연도 = 다시 첫 초과 월(1월에 넘으면 1건)', () {
      final P0sIncomeWarnStep s = _step('2028-01');
      expect(s.ytd!.totalKrw, _d('22000200'));
      expect(s.previousYtd!.totalKrw, Decimal.zero);
      expect(s.alerts, <String>[kFinancialIncomeAlertCode]);
      expect(_step('2027-12').alerts, isEmpty);
    });

    test('과세 종목 밖 체결은 보지 않는다(국내 종목의 깨진 체결도 셈을 막지 않는다)', () {
      final P0sIncomeWarnStep s = _step(
        '2027-04',
        fills: <String, List<LedgerFillRow>>{
          '0085P0': _bond,
          'A_ETF': <LedgerFillRow>[_sell('x', 5, 100, '2027-04-01')],
          '214980': <LedgerFillRow>[
            _f('p1', q: 1, px: 100, day: '2027-01-02'),
            _sell('p2', 1, 900000000, '2027-04-02'),
          ],
        },
      );
      expect(s.unavailable, isNull);
      expect(s.ytd!.totalKrw, _d('20000100'));
    });

    test('여러 과세 종목의 이익을 더한다(금 · 나스닥)', () {
      final P0sIncomeWarnStep s = _step(
        '2027-01',
        fills: <String, List<LedgerFillRow>>{
          '0085P0': _bond,
          '411060': <LedgerFillRow>[
            _f('g1', q: 10, px: 10000, day: '2026-06-01'),
            _sell('g2', 10, 11000, '2027-01-05'),
          ],
          '133690': <LedgerFillRow>[
            _f('n1', q: 10, px: 10000, day: '2026-06-01'),
            _sell('n2', 10, 10500, '2027-01-06'),
          ],
        },
      );
      expect(s.ytd!.realizedGainKrw, _d('15015000'));
    });

    test('🔴 셈 실패 = 판정 없음 · 알림 0 · 까닭', () {
      final P0sIncomeWarnStep s = _step(
        '2027-04',
        fills: <String, List<LedgerFillRow>>{
          '0085P0': <LedgerFillRow>[
            _f('a', q: 1, px: 100, day: '2027-01-02'),
            _sell('b', 2, 100000000, '2027-04-03'),
          ],
        },
      );
      expect(s.ytd, isNull);
      expect(s.previousYtd, isNull);
      expect(s.exceeded, false);
      expect(s.alerts, isEmpty);
      expect(s.unavailable, contains('평균 단가 모름'));
    });

    test('달 꼴이 틀리면 ArgumentError', () {
      for (final String m in <String>[
        '2027-13',
        '2027-00',
        '2027-1',
        '202701',
      ]) {
        expect(() => _step(m), throwsArgumentError, reason: m);
      }
    });
  });
}
