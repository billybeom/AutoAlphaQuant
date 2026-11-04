// 일일 평가 스냅숏 계산(설계 13 §8 R47 F6~F8 · 04 §2 · 02 `equity_snapshot`).
//
// 🔵 잡는 것: ① 보유 평가 = 종목 합 × 종가 · 0 수량 빼기 · 종가 없음 · 음수 = 던짐 ② HWM = 앞 HWM 과 오늘 중 큰 값 ·
//    드로다운 = 평가 ÷ HWM − 1 ③ 브레이커 = 역사 재생(악화 즉시 · 완화는 유지 + 조건 · STOPPED 자격 1회)
//    ④ P0S 설정 = 04 §2 값 ⑤ 🔴 현금 = 받은 D+2 값 그대로 · 종가 · 현금 실패 = 던짐(금액 0).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

EquitySnapshotRow _row(
  String d,
  double total, {
  double? hwm,
  double dd = 0,
  BreakerLevel level = BreakerLevel.normal,
}) => EquitySnapshotRow(
  tradeDate: d,
  totalEquity: total,
  cashKrw: 0,
  positionsValue: total,
  highWaterMark: hwm ?? total,
  drawdown: dd,
  breakerLevel: level,
);

(double?, bool) _noRegime(String _) => (null, false);

void main() {
  group('보유 평가', () {
    test('전략 합 × 종가 · 0 수량은 종가가 없어도 된다', () {
      expect(
        positionsValueKrw(
          const <LedgerHolding>[
            LedgerHolding('P0S_B', '133690', 3),
            LedgerHolding('P0S_POT', '133690', 2),
            LedgerHolding('P0S_C', '411060', 10),
            LedgerHolding('P0S_C', '0085P0', 0),
          ],
          <String, Decimal>{'133690': _d('166990'), '411060': _d('15025.5')},
        ),
        _d('985205'),
      );
    });

    test('수량이 있는데 종가 없음 · 음수 수량 = StateError', () {
      expect(
        () => positionsValueKrw(const <LedgerHolding>[
          LedgerHolding('P0S_B', '133690', 1),
        ], const <String, Decimal>{}),
        throwsStateError,
      );
      expect(
        () => positionsValueKrw(
          const <LedgerHolding>[LedgerHolding('P0S_B', '133690', -1)],
          <String, Decimal>{'133690': _d('1')},
        ),
        throwsStateError,
      );
    });
  });

  group('HWM · 드로다운(F7)', () {
    test('첫날 = HWM 오늘 · dd 0 · NORMAL', () {
      final EquitySnapshotStep s = nextEquitySnapshot(
        tradeDate: '2026-11-04',
        positionsValue: _d('167000'),
        cashKrw: _d('49832955'),
        history: const <EquitySnapshotRow>[],
        regimeOf: _noRegime,
      );
      expect(
        (s.row.totalEquity, s.row.highWaterMark, s.row.drawdown),
        (49999955.0, 49999955.0, 0.0),
      );
      expect((s.row.cashKrw, s.row.positionsValue), (49832955.0, 167000.0));
      expect((s.row.cashUsd, s.row.fxRate), (0.0, null));
      expect(s.row.breakerLevel, BreakerLevel.normal);
      expect(s.releaseEligibleToday, isFalse);
    });

    test('내려가면 앞 HWM 유지 · 오르면 새 HWM · dd = 평가 ÷ HWM − 1', () {
      final EquitySnapshotStep down = nextEquitySnapshot(
        tradeDate: '2026-11-05',
        positionsValue: Decimal.zero,
        cashKrw: _d('90'),
        history: <EquitySnapshotRow>[_row('2026-11-04', 100)],
        regimeOf: _noRegime,
      );
      expect(down.row.highWaterMark, 100.0);
      expect(down.row.drawdown, closeTo(-0.10, 1e-12));
      final EquitySnapshotStep up = nextEquitySnapshot(
        tradeDate: '2026-11-06',
        positionsValue: _d('110'),
        cashKrw: Decimal.zero,
        history: <EquitySnapshotRow>[
          _row('2026-11-04', 100),
          _row('2026-11-05', 90, hwm: 100, dd: -0.1),
        ],
        regimeOf: _noRegime,
      );
      expect((up.row.highWaterMark, up.row.drawdown), (110.0, 0.0));
    });

    test('history 에 오늘 · 이후 행 · 순서 어긋남 · 음수 현금 = ArgumentError', () {
      EquitySnapshotStep go(List<EquitySnapshotRow> h, {String cash = '1'}) =>
          nextEquitySnapshot(
            tradeDate: '2026-11-05',
            positionsValue: Decimal.zero,
            cashKrw: _d(cash),
            history: h,
            regimeOf: _noRegime,
          );
      expect(
        () => go(<EquitySnapshotRow>[_row('2026-11-05', 1)]),
        throwsArgumentError,
      );
      expect(
        () => go(<EquitySnapshotRow>[_row('2026-11-06', 1)]),
        throwsArgumentError,
      );
      expect(
        () => go(<EquitySnapshotRow>[
          _row('2026-11-04', 1),
          _row('2026-11-03', 1),
        ]),
        throwsArgumentError,
      );
      expect(
        () => go(const <EquitySnapshotRow>[], cash: '-1'),
        throwsArgumentError,
      );
    });
  });

  group('브레이커 재생(F8 · 04 §2)', () {
    test('P0S 설정 = 04 §2 값', () {
      final BreakerConfig c = p0sBreakerConfig();
      expect(
        (c.alertDd, c.reduceDd, c.haltDd, c.stopDd),
        (-0.15, -0.20, -0.25, -0.35),
      );
      expect(
        (c.alertReleaseDd, c.reduceReleaseDd, c.haltReleaseDd),
        (-0.13, -0.12, -0.15),
      );
      expect(
        (
          c.recoverHoldBars,
          c.haltReleaseBullStreak,
          c.stopReleaseDd,
          c.stopReleaseBullStreak,
        ),
        (20, 3, -0.25, 5),
      );
    });

    test(
      '악화 = 즉시(−15 ALERT · −20 REDUCED · −25 HALTED · −35 STOPPED) · 경계 ≤',
      () {
        BreakerLevel at(List<double> dds) => replayBreaker(<BreakerDay>[
          for (final double dd in dds)
            BreakerDay(drawdown: dd, directionScore: 40, bull: false),
        ], p0sBreakerConfig()).state.level;
        expect(at(<double>[0, -0.1499]), BreakerLevel.normal);
        expect(at(<double>[0, -0.15]), BreakerLevel.alert);
        expect(at(<double>[0, -0.20]), BreakerLevel.reduced);
        expect(at(<double>[0, -0.25]), BreakerLevel.halted);
        expect(at(<double>[-0.35]), BreakerLevel.stopped);
        // 한 번에 깊게 = 바로 그 레벨.
        expect(at(<double>[0, -0.30]), BreakerLevel.halted);
      },
    );

    test('완화 = 유지 20봉 + 조건 · 한 단계씩 — REDUCED 해제는 dd ≥ −12% 와 방향 ≥ 50', () {
      final List<BreakerDay> days = <BreakerDay>[
        const BreakerDay(drawdown: -0.21, directionScore: 40, bull: false),
        for (int i = 0; i < 19; i++)
          const BreakerDay(drawdown: -0.10, directionScore: 60, bull: true),
      ];
      expect(
        replayBreaker(days, p0sBreakerConfig()).state.level,
        BreakerLevel.reduced,
      );
      final List<BreakerDay> more = <BreakerDay>[
        ...days,
        const BreakerDay(drawdown: -0.10, directionScore: 60, bull: true),
      ];
      expect(
        replayBreaker(more, p0sBreakerConfig()).state.level,
        BreakerLevel.alert,
      );
      final List<BreakerDay> lowScore = <BreakerDay>[
        ...days,
        const BreakerDay(drawdown: -0.10, directionScore: 49, bull: true),
      ];
      expect(
        replayBreaker(lowScore, p0sBreakerConfig()).state.level,
        BreakerLevel.reduced,
      );
    });

    test('HALTED 해제 = bull 3 연속 — 중간에 끊기면 다시 센다', () {
      List<BreakerDay> days(List<bool> tail) => <BreakerDay>[
        const BreakerDay(drawdown: -0.26, directionScore: 30, bull: false),
        for (int i = 0; i < 19; i++)
          const BreakerDay(drawdown: -0.10, directionScore: 60, bull: false),
        for (final bool b in tail)
          BreakerDay(drawdown: -0.10, directionScore: 60, bull: b),
      ];
      BreakerLevel at(List<bool> tail) =>
          replayBreaker(days(tail), p0sBreakerConfig()).state.level;
      expect(at(<bool>[true, true, true]), BreakerLevel.reduced);
      expect(at(<bool>[true, true, false, true]), BreakerLevel.halted);
      expect(
        at(<bool>[true, true, false, true, true, true]),
        BreakerLevel.reduced,
      );
    });

    test('🔴 STOPPED 는 스스로 풀리지 않는다 · 자격 이벤트는 에피소드에 1번(그날만 true)', () {
      final List<BreakerDay> days = <BreakerDay>[
        const BreakerDay(drawdown: -0.36, directionScore: 30, bull: false),
        for (int i = 0; i < 30; i++)
          const BreakerDay(drawdown: -0.05, directionScore: 70, bull: true),
      ];
      int firstTrue = -1;
      int trues = 0;
      for (int n = 1; n <= days.length; n++) {
        final BreakerReplay r = replayBreaker(
          days.sublist(0, n),
          p0sBreakerConfig(),
        );
        expect(r.state.level, BreakerLevel.stopped);
        if (r.releaseEligibleToday) {
          trues++;
          if (firstTrue < 0) firstTrue = n;
        }
      }
      expect(trues, 1);
      expect(firstTrue, 21, reason: '진입 뒤 20봉 · bull 5 · dd ≥ −25%');
    });

    test('nextEquitySnapshot 은 저장된 dd 역사 + 오늘로 재생한다(방향 · bull 은 날짜별 조회)', () {
      final List<EquitySnapshotRow> hist = <EquitySnapshotRow>[
        _row('2026-10-01', 100),
        _row('2026-10-02', 70, hwm: 100, dd: -0.30, level: BreakerLevel.halted),
      ];
      final EquitySnapshotStep s = nextEquitySnapshot(
        tradeDate: '2026-10-05',
        positionsValue: _d('70'),
        cashKrw: Decimal.zero,
        history: hist,
        regimeOf: (String d) => (60, true),
      );
      expect(s.row.breakerLevel, BreakerLevel.halted);
      expect(s.row.drawdown, closeTo(-0.30, 1e-12));
    });
  });

  group('computeEquitySnapshot(F6)', () {
    test('종가 글자 · 🔴 현금 = orderableCashKrw(D+2) 합 · 계좌 여럿', () async {
      final EquitySnapshotStep s = await computeEquitySnapshot(
        tradeDate: '2026-11-04',
        holdings: const <LedgerHolding>[LedgerHolding('P0S_B', '133690', 1)],
        closeTexts: const <String, String>{'133690': '167000.0'},
        cashAccounts: <String, OrderBroker>{
          'main': FakeOrderBroker(cashKrw: _d('49832955')),
          'isa': FakeOrderBroker(cashKrw: _d('1000')),
        },
        history: const <EquitySnapshotRow>[],
        regimeOf: _noRegime,
      );
      expect(s.row.cashKrw, 49833955.0);
      expect(s.row.positionsValue, 167000.0);
      expect(s.row.totalEquity, 50000955.0);
    });

    test('종가 없음 · 0 이하 · 현금 실패 = EquitySnapshotError(종목 · 별칭만 · 금액 0) · 계좌 없음 = ArgumentError', () async {
      Future<EquitySnapshotStep> go(
        Map<String, String> closes, {
        Map<String, OrderBroker>? cash,
      }) => computeEquitySnapshot(
        tradeDate: '2026-11-04',
        holdings: const <LedgerHolding>[
          LedgerHolding('P0S_B', '133690', 1),
          LedgerHolding('P0S_B', '411060', 0),
        ],
        closeTexts: closes,
        cashAccounts: cash ?? <String, OrderBroker>{'main': FakeOrderBroker()},
        history: const <EquitySnapshotRow>[],
        regimeOf: _noRegime,
      );
      for (final Map<String, String> c in <Map<String, String>>[
        const <String, String>{},
        const <String, String>{'133690': '0'},
        const <String, String>{'133690': 'x'},
      ]) {
        await expectLater(
          go(c),
          throwsA(
            isA<EquitySnapshotError>().having(
              (EquitySnapshotError e) => e.reason,
              'reason',
              '종가 없음: 133690',
            ),
          ),
        );
      }
      await expectLater(
        go(
          const <String, String>{'133690': '100'},
          cash: <String, OrderBroker>{
            'isa': FakeOrderBroker(cashError: StateError('49832955 원')),
          },
        ),
        throwsA(
          isA<EquitySnapshotError>().having(
            (EquitySnapshotError e) => '$e',
            'str',
            'EquitySnapshotError(현금 조회 실패: isa)',
          ),
        ),
      );
      await expectLater(
        go(const <String, String>{
          '133690': '100',
        }, cash: <String, OrderBroker>{}),
        throwsArgumentError,
      );
    });
  });

  test('P0S KR 계획 종목 = B 자산 · C 채권 · C 금 · 파킹(정렬 · 중복 0)', () {
    expect(p0sKrPlanSymbols(), <String>[
      '0085P0',
      '133690',
      '214980',
      '411060',
    ]);
    expect(kP0sParkingSymbol, '214980');
  });
}
