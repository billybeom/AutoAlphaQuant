// E16f2 — 체결 재생 · 포지션 다시 세기(순수 · 설계 13 §8 R128 K7 · K12).
//
// 🔵 잡는 것: ① 살아 있는 체결 = REVERSAL · 되돌려진 행 빼고 · 다시 적은 행은 뿌리 자리에 ② 체인 깊이
//    ③ 포지션 재생 = 증분 `_position` 과 같은 셈(평단 Decimal · 매도 = 수량만 · 0 = 비움 · 다시 매수 = 새 진입)
//    ④ 중간 음수 = null ⑤ 저장 행 비교(수량 · 평단 허용) ⑥ 주문 합 · 평단 ⑦ 꼴이 틀린 입력 = 오류.
import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

LedgerFillRow _row(
  String id, {
  FillKind kind = FillKind.original,
  OrderSide side = OrderSide.buy,
  int q = 1,
  double px = 100,
  String order = 'o1',
  String day = '2026-11-02',
  String decision = 'D-1',
  String? reverses,
  String? restates,
}) => LedgerFillRow(
  executionId: id,
  kind: kind,
  side: side,
  quantity: q,
  price: px,
  brokerOrderNo: order,
  tradeDate: day,
  decisionId: decision,
  reversesFillId: reverses,
  restatesFillId: restates,
);

LedgerFillRow _rev(String target, {int q = 1, double px = 100}) => _row(
  '$target|REV',
  kind: FillKind.reversal,
  q: q,
  px: px,
  reverses: target,
);

List<String> _ids(List<LedgerFillRow> rows) => <String>[
  for (final LedgerFillRow r in rows) r.executionId,
];

void main() {
  group('LedgerFillRow 꼴', () {
    test('수량 · 가격 0 이하 = ArgumentError', () {
      expect(() => _row('a', q: 0), throwsArgumentError);
      expect(() => _row('a', px: 0), throwsArgumentError);
    });
    test('종류와 링크가 맞지 않으면 ArgumentError', () {
      expect(() => _row('a', reverses: 'x'), throwsArgumentError);
      expect(() => _row('a', restates: 'x'), throwsArgumentError);
      expect(() => _row('a', kind: FillKind.reversal), throwsArgumentError);
      expect(
        () => _row('a', kind: FillKind.reversal, reverses: 'x', restates: 'y'),
        throwsArgumentError,
      );
      expect(() => _row('a', kind: FillKind.restatement), throwsArgumentError);
      expect(
        () =>
            _row('a', kind: FillKind.restatement, restates: 'x', reverses: 'y'),
        throwsArgumentError,
      );
    });
  });

  group('되돌린 체결 · 살아 있는 체결', () {
    test('🔴 REVERSAL · 되돌려진 행을 빼고 · 다시 적은 행은 뿌리 자리에', () {
      final List<LedgerFillRow> rows = <LedgerFillRow>[
        _row('a'),
        _row('b'),
        _rev('a'),
        _row('a|RST', kind: FillKind.restatement, restates: 'a'),
      ];
      expect(reversedFillIdsOf(rows), <String>{'a'});
      expect(_ids(effectiveFillsOf(rows)), <String>['a|RST', 'b']);
    });

    test('정정의 정정 — 마지막 판만 살고 자리는 처음 뿌리', () {
      final List<LedgerFillRow> rows = <LedgerFillRow>[
        _row('a'),
        _row('b'),
        _row('c'),
        _rev('b'),
        _row('b|RST', kind: FillKind.restatement, restates: 'b'),
        _rev('b|RST'),
        _row('b|RST|RST', kind: FillKind.restatement, restates: 'b|RST'),
      ];
      expect(_ids(effectiveFillsOf(rows)), <String>['a', 'b|RST|RST', 'c']);
    });

    test('같은 뿌리 안에서는 입력 차례', () {
      // 뿌리가 같은 살아 있는 행이 둘인 꼴은 저장소가 만들지 않지만 차례는 정해져 있어야 한다.
      final List<LedgerFillRow> rows = <LedgerFillRow>[
        _row('a'),
        _row('x', kind: FillKind.restatement, restates: 'a'),
        _row('y', kind: FillKind.restatement, restates: 'a'),
        _rev('a'),
      ];
      expect(_ids(effectiveFillsOf(rows)), <String>['x', 'y']);
    });

    test('없는 대상 · 되돌림의 되돌림 · 두 번 되돌림 = StateError', () {
      expect(
        () => reversedFillIdsOf(<LedgerFillRow>[_rev('zz')]),
        throwsStateError,
      );
      expect(
        () => reversedFillIdsOf(<LedgerFillRow>[
          _row('a'),
          _rev('a'),
          _row('a|REV|REV', kind: FillKind.reversal, reverses: 'a|REV'),
        ]),
        throwsStateError,
      );
      expect(
        () => reversedFillIdsOf(<LedgerFillRow>[
          _row('a'),
          _rev('a'),
          _row('a|REV2', kind: FillKind.reversal, reverses: 'a'),
        ]),
        throwsStateError,
      );
    });

    test('겹친 id = ArgumentError · 없는 체결을 다시 적음 = StateError', () {
      expect(
        () => effectiveFillsOf(<LedgerFillRow>[_row('a'), _row('a')]),
        throwsArgumentError,
      );
      expect(
        () => effectiveFillsOf(<LedgerFillRow>[
          _row('x', kind: FillKind.restatement, restates: 'zz'),
        ]),
        throwsStateError,
      );
    });

    test('도는 체인 = StateError', () {
      final List<LedgerFillRow> loop = <LedgerFillRow>[
        _row('x', kind: FillKind.restatement, restates: 'y'),
        _row('y', kind: FillKind.restatement, restates: 'x'),
      ];
      expect(() => effectiveFillsOf(loop), throwsStateError);
      expect(() => fillChainDepthOf('x', loop), throwsStateError);
    });
  });

  group('체인 깊이', () {
    final List<LedgerFillRow> rows = <LedgerFillRow>[
      _row('a'),
      _row('a|RST', kind: FillKind.restatement, restates: 'a'),
      _row('a|RST|RST', kind: FillKind.restatement, restates: 'a|RST'),
    ];
    test('원본 0 · 하나마다 +1', () {
      expect(fillChainDepthOf('a', rows), 0);
      expect(fillChainDepthOf('a|RST', rows), 1);
      expect(fillChainDepthOf('a|RST|RST', rows), 2);
    });
    test('없는 id = StateError', () {
      expect(() => fillChainDepthOf('zz', rows), throwsStateError);
    });
  });

  group('🔴 포지션 재생', () {
    test('매수 둘 = 평단 Decimal 셈 · 진입 = 첫 매수', () {
      final ReplayedPosition p = replayPositionOf(<LedgerFillRow>[
        _row('a', q: 3, px: 174180, day: '2026-11-02', decision: 'D-a'),
        _row('b', q: 2, px: 175000, day: '2026-11-03', decision: 'D-b'),
      ])!;
      expect(
        (p.quantity, p.avgPrice, p.entryDate, p.entryDecisionId),
        (5, 174508.0, '2026-11-02', 'D-a'),
      );
    });

    test('증분 averagePriceAfterBuy 와 같은 답', () {
      double avg = 101.37;
      int q = 7;
      for (final (int n, String px) in <(int, String)>[
        (3, '99.11'),
        (11, '103.07'),
        (1, '0.5'),
      ]) {
        avg = averagePriceAfterBuy(
          heldQty: q,
          heldAvg: avg,
          buy: FillDelta(
            executionId: 'x',
            brokerOrderNo: 'o',
            symbol: 'S',
            side: OrderSide.buy,
            quantity: n,
            price: Decimal.parse(px),
            cumulativeQuantity: 0,
            cumulativeAmount: Decimal.zero,
          ),
        );
        q += n;
      }
      final ReplayedPosition p = replayPositionOf(<LedgerFillRow>[
        _row('a', q: 7, px: 101.37),
        _row('b', q: 3, px: 99.11),
        _row('c', q: 11, px: 103.07),
        _row('d', px: 0.5),
      ])!;
      expect((p.quantity, p.avgPrice), (q, avg));
    });

    test('매도 = 수량만(평단 · 진입 그대로)', () {
      final ReplayedPosition p = replayPositionOf(<LedgerFillRow>[
        _row('a', q: 4, px: 100, decision: 'D-a'),
        _row('b', side: OrderSide.sell, q: 1, px: 130, decision: 'D-b'),
      ])!;
      expect(
        (p.quantity, p.avgPrice, p.entryDate, p.entryDecisionId),
        (3, 100.0, '2026-11-02', 'D-a'),
      );
    });

    test('0 = 비움 · 다시 매수 = 새 진입(평단 처음부터)', () {
      final ReplayedPosition z = replayPositionOf(<LedgerFillRow>[
        _row('a', q: 2, px: 100),
        _row('b', side: OrderSide.sell, q: 2, px: 110),
      ])!;
      expect(
        (z.quantity, z.avgPrice, z.entryDate, z.entryDecisionId),
        (0, null, null, null),
      );
      final ReplayedPosition p = replayPositionOf(<LedgerFillRow>[
        _row('a', q: 2, px: 100),
        _row('b', side: OrderSide.sell, q: 2, px: 110),
        _row('c', q: 1, px: 90, day: '2026-11-05', decision: 'D-c'),
      ])!;
      expect(
        (p.quantity, p.avgPrice, p.entryDate, p.entryDecisionId),
        (1, 90.0, '2026-11-05', 'D-c'),
      );
    });

    test('🔴 중간 음수 = null(뒤에 다시 채워져도)', () {
      expect(
        replayPositionOf(<LedgerFillRow>[
          _row('s', side: OrderSide.sell),
          _row('a', q: 5),
        ]),
        isNull,
      );
    });

    test('빈 입력 = 0 · REVERSAL 입력 = ArgumentError', () {
      expect(replayPositionOf(const <LedgerFillRow>[])!.quantity, 0);
      expect(
        () => replayPositionOf(<LedgerFillRow>[_row('a'), _rev('a')]),
        throwsArgumentError,
      );
    });
  });

  group('🔴 저장 행 비교', () {
    const ReplayedPosition p = ReplayedPosition(quantity: 3, avgPrice: 1000);
    test('수량이 다르면 아니다', () {
      expect(
        positionReplayMatches(p, storedQuantity: 2, storedAvgPrice: 1000),
        isFalse,
      );
    });
    test('평단 = 상대 허용 안 · 밖', () {
      expect(
        positionReplayMatches(
          p,
          storedQuantity: 3,
          storedAvgPrice: 1000 + 1000 * kReplayAvgTolerance * 0.5,
        ),
        isTrue,
      );
      expect(
        positionReplayMatches(
          p,
          storedQuantity: 3,
          storedAvgPrice: 1000 + 1000 * kReplayAvgTolerance * 2,
        ),
        isFalse,
      );
    });
    test('평단이 1 보다 작으면 절대 허용', () {
      const ReplayedPosition s = ReplayedPosition(quantity: 1, avgPrice: 0.5);
      expect(
        positionReplayMatches(
          s,
          storedQuantity: 1,
          storedAvgPrice: 0.5 + kReplayAvgTolerance * 0.5,
        ),
        isTrue,
      );
      expect(
        positionReplayMatches(
          s,
          storedQuantity: 1,
          storedAvgPrice: 0.5 + kReplayAvgTolerance * 1.5,
        ),
        isFalse,
      );
    });
    test('0 = 행 없음이어야 · 저장 평단이 없으면 아니다', () {
      const ReplayedPosition z = ReplayedPosition(quantity: 0);
      expect(
        positionReplayMatches(z, storedQuantity: 0, storedAvgPrice: null),
        isTrue,
      );
      expect(
        positionReplayMatches(z, storedQuantity: 0, storedAvgPrice: 1),
        isFalse,
      );
      expect(
        positionReplayMatches(p, storedQuantity: 3, storedAvgPrice: null),
        isFalse,
      );
    });
  });

  group('주문 합', () {
    test('수량 합 · 평단 = Σ(수량 × 가격) ÷ 수량', () {
      final ({int quantity, double? avgPrice}) t = orderFillTotalsOf(
        <LedgerFillRow>[
          _row('a', q: 4, px: 174000),
          _row('b', q: 2, px: 175000),
        ],
      );
      expect((t.quantity, t.avgPrice), (6, 1046000 / 6));
    });
    test('0 = 평단 null · REVERSAL 입력 = ArgumentError', () {
      final ({int quantity, double? avgPrice}) z = orderFillTotalsOf(
        const <LedgerFillRow>[],
      );
      expect((z.quantity, z.avgPrice), (0, null));
      expect(
        () => orderFillTotalsOf(<LedgerFillRow>[_rev('a')]),
        throwsArgumentError,
      );
    });
  });
}
