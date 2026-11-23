// E11q-q5c2 — M7 S7-3b 슬리브 기여 분해 VM(설계 13 §8 R228 · 03 §8 · 표본 `m7/m7_contrib_*`).
//
// 🔴 `3sleeve` 표본 = 원장 값을 맞춰 넣으면 막대(최대 대비 — 표본은 몫 눈금)만 빼고 DTO 째로 같다 · `partial` 표본 = C 가격 결측
//    사유 · 산식 주석 · 기준이 같다 · 셈 = TWR 지수 연결(슬리브 손익만이면 행의 합 = 그 기간 TWR).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m7';

ContributionVm _fixture(String file) => ContributionVm.fromJson(
  ((jsonDecode(File('$_fx/$file').readAsStringSync())
                  as Map<String, Object?>)['rows']!
              as List<Object?>)
          .first!
      as Map<String, Object?>,
);

final DateTime _now = DateTime.utc(2026, 8, 31, 9);

const DateRange _aug = DateRange(
  from: TradeDate('2026-08-01'),
  to: TradeDate('2026-08-31'),
);

ContributionFill _buy(
  String strategy,
  String symbol,
  String day,
  int q,
  double price, {
  double commission = 0,
  OrderSide side = OrderSide.buy,
  FillKind kind = FillKind.original,
}) => ContributionFill(
  strategyId: strategy,
  symbol: symbol,
  tradeDate: day,
  side: side,
  kind: kind,
  quantity: q,
  price: price,
  commission: commission,
);

ContributionVm _vm({
  DateRange range = _aug,
  required List<EquityPoint> equity,
  List<LedgerHolding> holdings = const <LedgerHolding>[],
  List<ContributionFill> fills = const <ContributionFill>[],
  Map<String, Map<String, double>> closes =
      const <String, Map<String, double>>{},
  List<ContributionEvent> events = const <ContributionEvent>[],
  bool integrity = false,
}) => contributionVmOf(
  range: range,
  equity: equity,
  holdingsNow: holdings,
  fills: fills,
  closes: closes,
  events: events,
  nowUtc: _now,
  integrityHidden: integrity,
);

/// 세 슬리브 1000주씩 · 7월 말 10,000원 → 8월 말 [a] · [b] · [c] — 평가액 1억 → 손익만큼.
ContributionVm _three(
  double a,
  double b,
  double c, {
  List<String> gapDaysC = const <String>[],
  List<String> mid = const <String>[],
}) {
  final List<String> days = <String>['2026-07-31', ...mid, '2026-08-31'];
  Map<String, double> line(
    double endPrice, {
    List<String> gaps = const <String>[],
  }) => <String, double>{
    for (final String d in days)
      if (!gaps.contains(d)) d: d == '2026-08-31' ? endPrice : 10000,
  };
  return _vm(
    equity: <EquityPoint>[
      for (final String d in days)
        EquityPoint(
          d,
          d == '2026-08-31' ? 1e8 + (a + b + c - 30000) * 1000 : 1e8,
        ),
    ],
    holdings: const <LedgerHolding>[
      LedgerHolding('P0S_A', 'AAA', 1000),
      LedgerHolding('P0S_B', 'BBB', 1000),
      LedgerHolding('P0S_C', 'CCC', 1000),
    ],
    closes: <String, Map<String, double>>{
      'AAA': line(a),
      'BBB': line(b),
      'CCC': line(c, gaps: gapDaysC),
    },
  );
}

void main() {
  group('표본', () {
    test('세 슬리브(3sleeve) — 막대만 다른 눈금(최대 대비) · 나머지 DTO 째로 같다', () {
      final ContributionVm want = _fixture('m7_contrib_3sleeve.json');
      final ContributionVm got = _three(10420, 10710, 9770);
      expect(
        got.copyWith(
          rows: <ContributionRow>[
            for (final ContributionRow r in got.rows) r.copyWith(normalized: 0),
          ],
        ),
        want.copyWith(
          rows: <ContributionRow>[
            for (final ContributionRow r in want.rows)
              r.copyWith(normalized: 0),
          ],
        ),
      );
      // 표본 = 몫 눈금(0.31 · 0.52 · 0.17) · 엔진 = 가장 큰 |기여| 대비.
      expect(
        <double>[for (final ContributionRow r in got.rows) r.normalized],
        <double>[0.59, 1.0, 0.32],
      );
    });

    test('일부 결측(partial) — C 8월 12~14일 종가 없음 = «산출 불가» 행 · 막대 0 · A · B 는 그대로(100% 로 맞추지 않음)', () {
      final ContributionVm want = _fixture('m7_contrib_partial.json');
      final ContributionVm got = _three(
        10420,
        10710,
        9770,
        mid: const <String>['2026-08-12', '2026-08-13', '2026-08-14'],
        gapDaysC: const <String>['2026-08-12', '2026-08-13', '2026-08-14'],
      );
      expect(got.periodLabel, want.periodLabel);
      expect(got.methodNoteText, want.methodNoteText);
      expect(got.fxNoteText, want.fxNoteText);
      expect(got.asOf, want.asOf);
      expect(got.rows, hasLength(3));
      for (int i = 0; i < 3; i++) {
        expect(got.rows[i].sleeve, want.rows[i].sleeve);
        expect(got.rows[i].label, want.rows[i].label);
        expect(got.rows[i].contributionText, want.rows[i].contributionText);
        expect(got.rows[i].unavailableLabel, want.rows[i].unavailableLabel);
      }
      expect(got.rows[2].normalized, 0);
      // 표본 0.31 · 0.52 = 몫 눈금 그대로 둔 값 · 엔진 = 최대 대비(A + B ≠ 1 — 나머지를 100% 로 다시 맞추지 않는다).
      expect(got.rows[0].normalized, 0.59);
      expect(got.rows[1].normalized, 1.0);
    });
  });

  group('셈', () {
    test('🔴 슬리브 손익만 = 행의 합이 그 기간 TWR · 입금 = 수익 아님 · 수수료 · 매도 · POT = A 행', () {
      // 현금 + 평가 = 마감 평가액(원장과 같은 꼴).
      const String d0 = '2026-07-31',
          d1 = '2026-08-03',
          d2 = '2026-08-04',
          d3 = '2026-08-05';
      final List<ContributionFill> fills = <ContributionFill>[
        _buy('P0S_A', 'AAA', d1, 100, 10000, commission: 150),
        _buy('P0S_POT', 'AAA', d1, 10, 10000, commission: 15),
        _buy('P0S_B', 'BBB', d1, 200, 20000, commission: 600),
        _buy('P0S_C', 'CCC', d2, 50, 30000, commission: 225),
        _buy(
          'P0S_B',
          'BBB',
          d3,
          50,
          21000,
          commission: 157.5,
          side: OrderSide.sell,
        ),
      ];
      final Map<String, Map<String, double>> closes =
          <String, Map<String, double>>{
            'AAA': <String, double>{d1: 10100, d2: 10300, d3: 10200},
            'BBB': <String, double>{d1: 19900, d2: 20500, d3: 21000},
            'CCC': <String, double>{d2: 29000, d3: 29500},
          };
      double cash = 10000000;
      final Map<String, Map<String, int>> held = <String, Map<String, int>>{};
      final List<EquityPoint> eq = <EquityPoint>[EquityPoint(d0, cash)];
      for (final (String d, double flow) in <(String, double)>[
        (d1, 0),
        (d2, 1000000),
        (d3, 0),
      ]) {
        cash += flow;
        for (final ContributionFill f in fills.where(
          (ContributionFill f) => f.tradeDate == d,
        )) {
          cash += f.cash;
          (held[f.strategyId] ??= <String, int>{})[f.symbol] =
              (held[f.strategyId]?[f.symbol] ?? 0) + f.holdingDelta;
        }
        double mv = 0;
        held.forEach((String _, Map<String, int> m) {
          m.forEach((String sym, int q) => mv += q * closes[sym]![d]!);
        });
        eq.add(EquityPoint(d, cash + mv, flow: flow));
      }
      final ContributionVm vm = _vm(
        equity: eq,
        holdings: <LedgerHolding>[
          for (final MapEntry<String, Map<String, int>> s in held.entries)
            for (final MapEntry<String, int> h in s.value.entries)
              LedgerHolding(s.key, h.key, h.value),
        ],
        fills: fills,
        closes: closes,
      );
      final double twr = twrIndex(eq).last - 1;
      double sum = 0;
      for (final ContributionRow r in vm.rows) {
        expect(r.unavailableLabel, isNull);
        final String t = r.contributionText
            .replaceAll('%p', '')
            .replaceAll('−', '-');
        sum += double.parse(t) / 100;
      }
      // 글자 = 두 자리 반올림 → 행마다 0.005%p 안.
      expect(sum, closeTo(twr, 0.00015));
      expect(vm.rows.map((ContributionRow r) => r.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.b,
        SleeveId.c,
      ]);
      expect(vm.methodNoteText, ContributionTexts.methodFull);
      expect(vm.asOf.label, '기여 분해 기준 $d3');
    });

    test('정확 합 — 셈 값(반올림 전) = TWR(복리 잔차 0)', () {
      // 같은 슬리브 하나 · 두 구간 · 입금 — 기여 = I_{k−1} × 손익 ÷ E_{k−1} 의 합 = 지수 − 1.
      const List<EquityPoint> eq = <EquityPoint>[
        EquityPoint('2026-07-31', 1000),
        EquityPoint('2026-08-03', 1100),
        EquityPoint('2026-08-04', 1650, flow: 500),
      ];
      final ContributionVm vm = _vm(
        equity: eq,
        holdings: const <LedgerHolding>[LedgerHolding('P0S_C', 'CCC', 10)],
        closes: const <String, Map<String, double>>{
          'CCC': <String, double>{
            '2026-07-31': 100,
            '2026-08-03': 110,
            '2026-08-04': 115,
          },
        },
      );
      // 손익 100 ÷ 1000 + 1.1 × 50 ÷ 1100 = 0.15 = 지수(1.1 × 1.0454…) − 1.
      expect(twrIndex(eq).last - 1, closeTo(0.15, 1e-12));
      expect(vm.rows[2].contributionText, '+15.00%p');
      expect(vm.rows[0].contributionText, '0.00%p');
      expect(vm.rows[0].normalized, 0);
      expect(vm.rows[2].normalized, 1.0);
    });

    test('시작 기준 = 구간 앞 마지막 마감 · 개시가 구간 안이면 그 첫 마감(개시 날 체결 = 시작 평가에 들어 있다)', () {
      final ContributionVm before = _vm(
        equity: const <EquityPoint>[
          EquityPoint('2026-07-30', 1000),
          EquityPoint('2026-07-31', 1000),
          EquityPoint('2026-08-03', 1010),
        ],
        holdings: const <LedgerHolding>[LedgerHolding('P0S_B', 'BBB', 1)],
        closes: const <String, Map<String, double>>{
          'BBB': <String, double>{'2026-07-31': 100, '2026-08-03': 110},
        },
      );
      expect(before.rows[1].contributionText, '+1.00%p');
      final ContributionVm opening = _vm(
        equity: const <EquityPoint>[
          EquityPoint('2026-08-05', 1000),
          EquityPoint('2026-08-06', 1020),
        ],
        holdings: const <LedgerHolding>[LedgerHolding('P0S_B', 'BBB', 2)],
        fills: <ContributionFill>[_buy('P0S_B', 'BBB', '2026-08-05', 2, 100)],
        closes: const <String, Map<String, double>>{
          'BBB': <String, double>{'2026-08-05': 100, '2026-08-06': 110},
        },
      );
      expect(opening.rows[1].contributionText, '+2.00%p');
      // 개시 날만 = 구간 0 → 0.
      final ContributionVm only = _vm(
        equity: const <EquityPoint>[EquityPoint('2026-08-31', 1000)],
        holdings: const <LedgerHolding>[LedgerHolding('P0S_B', 'BBB', 2)],
        closes: const <String, Map<String, double>>{
          'BBB': <String, double>{'2026-08-31': 100},
        },
      );
      expect(
        <String>[for (final ContributionRow r in only.rows) r.contributionText],
        <String>['0.00%p', '0.00%p', '0.00%p'],
      );
      expect(only.methodNoteText, ContributionTexts.methodFull);
    });

    test('REVERSAL = 원 체결 상쇄(보유 · 현금) · 끝 뒤 체결 = 보유 재구성에만', () {
      const ContributionFill f = ContributionFill(
        strategyId: 'P0S_A',
        symbol: 'AAA',
        tradeDate: '2026-08-03',
        side: OrderSide.sell,
        kind: FillKind.reversal,
        quantity: 3,
        price: 100,
        commission: 1,
        tax: 2,
      );
      expect(f.holdingDelta, 3);
      expect(f.cash, -297);
      // 8월 31일 뒤(9월 1일) 매수 10주 — 8월 말 보유 = 지금 15 − 10 = 5.
      final ContributionVm vm = _vm(
        equity: const <EquityPoint>[
          EquityPoint('2026-07-31', 1000),
          EquityPoint('2026-08-31', 1050),
          EquityPoint('2026-09-01', 2000),
        ],
        holdings: const <LedgerHolding>[LedgerHolding('P0S_A', 'AAA', 15)],
        fills: <ContributionFill>[_buy('P0S_A', 'AAA', '2026-09-01', 10, 100)],
        closes: const <String, Map<String, double>>{
          'AAA': <String, double>{'2026-07-31': 100, '2026-08-31': 110},
        },
      );
      expect(vm.rows[0].contributionText, '+5.00%p');
      expect(vm.asOf.tradeDate, const TradeDate('2026-08-31'));
    });
  });

  group('산출 불가(표본 partial 꼴)', () {
    test('이어지지 않은 결측 = 첫 이어짐 «외 n일» · 보유 0 인 날의 결측은 결측이 아니다', () {
      final ContributionVm vm = _three(
        10420,
        10710,
        9770,
        mid: const <String>['2026-08-12', '2026-08-13', '2026-08-20'],
        gapDaysC: const <String>['2026-08-12', '2026-08-20'],
      );
      expect(
        vm.rows[2].unavailableLabel,
        '8월 12일 외 1일 가격 결측 — 이 슬리브는 산출할 수 없습니다',
      );
      expect(
        ContributionTexts.dayRun('2026-08-31', '2026-09-01'),
        '8월 31일~9월 1일',
      );
      final ContributionVm zero = _vm(
        equity: const <EquityPoint>[
          EquityPoint('2026-07-31', 1000),
          EquityPoint('2026-08-31', 1000),
        ],
        holdings: const <LedgerHolding>[LedgerHolding('P0S_C', 'CCC', 0)],
      );
      expect(zero.rows[2].unavailableLabel, isNull);
      expect(zero.rows[2].contributionText, '0.00%p');
    });

    test('🆕 구간 안 마감 0(달 첫날 마감 전) = 전 행 · 기준 = 앞 달 마지막 마감', () {
      final ContributionVm vm = _vm(
        range: const DateRange(
          from: TradeDate('2026-09-01'),
          to: TradeDate('2026-09-01'),
        ),
        equity: const <EquityPoint>[
          EquityPoint('2026-08-28', 1000),
          EquityPoint('2026-08-31', 1000),
        ],
      );
      expect(vm.periodLabel, '2026년 9월');
      for (final ContributionRow r in vm.rows) {
        expect(r.contributionText, '산출 불가');
        expect(r.normalized, 0);
        expect(r.unavailableLabel, '이 기간 마감 평가 아직 없음 — 이 슬리브는 산출할 수 없습니다');
      }
      expect(vm.methodNoteText, ContributionTexts.methodPartial);
      expect(vm.asOf.label, '기여 분해 기준 2026-08-31');
    });

    test('🆕 귀속 못 하는 전략 · 보유 재구성 음수', () {
      const List<EquityPoint> eq = <EquityPoint>[
        EquityPoint('2026-07-31', 1000),
        EquityPoint('2026-08-31', 1000),
      ];
      final ContributionVm unknown = _vm(
        equity: eq,
        holdings: const <LedgerHolding>[LedgerHolding('SAT_1', 'ZZZ', 1)],
      );
      expect(
        unknown.rows.map((ContributionRow r) => r.unavailableLabel).toSet(),
        <String>{'SAT_1 전략 기록(슬리브 귀속 불가) — 이 슬리브는 산출할 수 없습니다'},
      );
      final ContributionVm neg = _vm(
        equity: eq,
        holdings: const <LedgerHolding>[LedgerHolding('P0S_B', 'BBB', 5)],
        fills: <ContributionFill>[_buy('P0S_B', 'BBB', '2026-08-31', 8, 100)],
        closes: const <String, Map<String, double>>{
          'BBB': <String, double>{'2026-07-31': 100, '2026-08-31': 100},
        },
      );
      expect(
        neg.rows[1].unavailableLabel,
        '7월 31일 보유 수량 재구성 불일치 — 이 슬리브는 산출할 수 없습니다',
      );
      expect(neg.rows[0].unavailableLabel, isNull);
    });

    test('🆕 귀속 규칙 전 원장 사건 = 전 행 · 창 밖 사건은 거른다 · 기업행위는 끝 뒤여도', () {
      const List<EquityPoint> eq = <EquityPoint>[
        EquityPoint('2026-07-31', 1000),
        EquityPoint('2026-08-31', 1000),
      ];
      final ContributionVm dist = _vm(
        equity: eq,
        events: const <ContributionEvent>[
          ContributionEvent('2026-07-31', ContributionEventKind.distribution),
          ContributionEvent('2026-09-02', ContributionEventKind.manualFill),
          ContributionEvent('2026-08-20', ContributionEventKind.distribution),
        ],
      );
      expect(
        dist.rows.map((ContributionRow r) => r.unavailableLabel).toSet(),
        <String>{'8월 20일 분배금 기록(슬리브 귀속 전) — 이 슬리브는 산출할 수 없습니다'},
      );
      final ContributionVm outside = _vm(
        equity: eq,
        events: const <ContributionEvent>[
          ContributionEvent('2026-07-31', ContributionEventKind.taxWithheld),
          ContributionEvent('2026-09-02', ContributionEventKind.cashInLieu),
        ],
      );
      expect(
        outside.rows.every((ContributionRow r) => r.unavailableLabel == null),
        true,
      );
      final ContributionVm ca = _vm(
        equity: eq,
        events: const <ContributionEvent>[
          ContributionEvent(
            '2026-09-02',
            ContributionEventKind.corporateAction,
          ),
        ],
      );
      expect(
        ca.rows.first.unavailableLabel,
        '9월 2일 기업행위 기록(슬리브 귀속 전) — 이 슬리브는 산출할 수 없습니다',
      );
    });
  });

  group('실패 · 기본 구간 · 글자', () {
    test('무결성 점검 중 · 마감 0 · 구간이 첫 마감 전 = 실패 · 시작 > 끝 · 순서 어긋남 = 인자 오류', () {
      const List<EquityPoint> eq = <EquityPoint>[EquityPoint('2026-08-31', 1)];
      expect(() => _vm(equity: eq, integrity: true), throwsStateError);
      expect(() => _vm(equity: const <EquityPoint>[]), throwsStateError);
      expect(
        () => _vm(equity: const <EquityPoint>[EquityPoint('2026-09-01', 1)]),
        throwsStateError,
      );
      expect(
        () => _vm(
          equity: eq,
          range: const DateRange(
            from: TradeDate('2026-08-31'),
            to: TradeDate('2026-08-01'),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => _vm(
          equity: const <EquityPoint>[
            EquityPoint('2026-08-03', 1),
            EquityPoint('2026-08-03', 1),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('기본 구간 = 이번 달(한국) 1일 ~ 오늘 · 이름 · 프리셋 · 기본 표지', () {
      expect(
        contributionDefaultRange(DateTime.utc(2026, 11, 21, 3)),
        const DateRange(
          from: TradeDate('2026-11-01'),
          to: TradeDate('2026-11-21'),
          presetCode: kContributionDefaultPreset,
          label: '2026년 11월',
          isDefault: true,
        ),
      );
      // UTC 11-30 16시 = 한국 12-01.
      final DateRange dec = contributionDefaultRange(
        DateTime.utc(2026, 11, 30, 16),
      );
      expect(dec.from, const TradeDate('2026-12-01'));
      expect(dec.to, const TradeDate('2026-12-01'));
      expect(dec.label, '2026년 12월');
    });

    test('글자 — 부호 · 0 · 기간 이름', () {
      expect(ContributionTexts.pct(0.0042), '+0.42%p');
      expect(ContributionTexts.pct(-0.0023), '−0.23%p');
      expect(ContributionTexts.pct(0.00004), '0.00%p');
      expect(ContributionTexts.pct(-0.00004), '0.00%p');
      expect(ContributionTexts.period('2026-08-01', '2026-08-31'), '2026년 8월');
      expect(
        ContributionTexts.period('2026-08-03', '2026-08-20'),
        '2026-08-03 ~ 2026-08-20',
      );
      expect(
        ContributionTexts.period('2026-08-01', '2026-09-30'),
        '2026-08-01 ~ 2026-09-30',
      );
    });
  });
}
