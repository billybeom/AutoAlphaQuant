// P0S 일간 경고(04 §1 Level 3 v2.46 · 설계 13 §8 R177 · E3d-1) — 노출 셈 · 판정 경계 · 조치 · «넘은 첫날» 알림 · fail-closed.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show AlertLevel;
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

/// 총자산 1,000만 — A 200 · B(나스닥 300 · 금 50 · 파킹 100) · C(채권 200 · 금 100) · 원화 현금 50(만 원).
const List<LedgerHolding> _book = <LedgerHolding>[
  LedgerHolding('P0S_A', 'A_ETF', 100),
  LedgerHolding('P0S_B', '133690', 100),
  LedgerHolding('P0S_B', '411060', 50),
  LedgerHolding('P0S_B', '214980', 10),
  LedgerHolding('P0S_C', '0085P0', 200),
  LedgerHolding('P0S_C', '411060', 100),
];

final Map<String, Decimal> _closes = <String, Decimal>{
  'A_ETF': _d('20000'),
  '133690': _d('30000'),
  '411060': _d('10000'),
  '214980': _d('100000'),
  '0085P0': _d('10000'),
};

P0sExposure _exp({
  double defensive = 0.30,
  double gold = 0.15,
  double usd = 0.40,
  double krw = 0.15,
}) => P0sExposure(
  totalKrw: _d('10000000'),
  defensivePct: defensive,
  goldSharePct: gold,
  usdExposurePct: usd,
  krwLiquidityPct: krw,
);

P0sDailyWarn _judge(P0sExposure e) => judgeP0sDailyWarnings(e, p0sWarnConfig());

Matcher get _unavailable => throwsA(isA<RiskCheckUnavailable>());

void main() {
  test('범주 표 = 운영 설정의 슬리브 종목(방어 = 슬리브 C · 금 · 해외 기초 · 파킹)', () {
    final P0sExposureMap m = p0sExposureMap();
    expect(m.defensiveStrategyIds, <String>{'P0S_C'});
    expect(m.goldSymbols, <String>{'411060'});
    expect(m.usdUnderlyingSymbols, <String>{'133690', '411060', '0085P0'});
    expect(m.parkingSymbols, <String>{'214980'});
  });

  test('문턱 = 02 §4 · 04 §1(0.10 · 0.20 · 0.50 · 0.01)', () {
    final P0sWarnConfig c = p0sWarnConfig();
    expect(
      <double>[
        c.minDefensivePct,
        c.goldTotalMonitorPct,
        c.usdBaselinePct,
        c.krwLiquidityFloorPct,
      ],
      <double>[0.10, 0.20, 0.50, 0.01],
    );
  });

  group('노출 셈', () {
    test('방어 = 슬리브 C 보유만 · 금 = B · C 합 · 달러 = 해외 기초 전부 · 원화 = 현금 + 파킹', () {
      final P0sExposure e = p0sExposureOf(
        holdings: _book,
        closes: _closes,
        cashKrw: _d('500000'),
        map: p0sExposureMap(),
      );
      expect(e.totalKrw, _d('10000000'));
      expect(e.defensivePct, 0.30);
      expect(e.goldSharePct, 0.15);
      expect(e.usdExposurePct, 0.65);
      expect(e.krwLiquidityPct, 0.15);
    });

    test('분모 = 평가 잡과 같은 총자산(보유 평가 + 원화 현금 + 달러 현금)', () {
      final P0sExposure e = p0sExposureOf(
        holdings: _book,
        closes: _closes,
        cashKrw: _d('500000'),
        cashUsdKrw: _d('1000000'),
        map: p0sExposureMap(),
      );
      expect(
        e.totalKrw,
        positionsValueKrw(_book, _closes) + _d('500000') + _d('1000000'),
      );
      expect(e.usdExposurePct, 7.5 / 11);
    });

    test('수량 0 행은 종가가 없어도 된다', () {
      final P0sExposure e = p0sExposureOf(
        holdings: <LedgerHolding>[
          ..._book,
          const LedgerHolding('P0S_C', 'GONE', 0),
        ],
        closes: _closes,
        cashKrw: _d('500000'),
        map: p0sExposureMap(),
      );
      expect(e.totalKrw, _d('10000000'));
    });

    test('🔴 셈할 수 없으면 던진다(잡이 받아 «계측 없음 · 알림 0»)', () {
      expect(
        () => p0sExposureOf(
          holdings: _book,
          closes: <String, Decimal>{..._closes}..remove('0085P0'),
          cashKrw: _d('500000'),
          map: p0sExposureMap(),
        ),
        _unavailable,
        reason: '종가 없음',
      );
      expect(
        () => p0sExposureOf(
          holdings: _book,
          closes: <String, Decimal>{..._closes, '0085P0': Decimal.zero},
          cashKrw: _d('500000'),
          map: p0sExposureMap(),
        ),
        _unavailable,
        reason: '종가 0',
      );
      expect(
        () => p0sExposureOf(
          holdings: const <LedgerHolding>[],
          closes: const <String, Decimal>{},
          cashKrw: Decimal.zero,
          map: p0sExposureMap(),
        ),
        _unavailable,
        reason: '총자산 0',
      );
      expect(
        () => p0sExposureOf(
          holdings: _book,
          closes: _closes,
          cashKrw: _d('-1'),
          map: p0sExposureMap(),
        ),
        _unavailable,
        reason: '현금 음수',
      );
    });
  });

  group('판정 경계 · 조치', () {
    test('302 = 하한 포함(== 통과)', () {
      expect(_judge(_exp(defensive: 0.10)).triggered, isEmpty);
      expect(_judge(_exp(defensive: 0.0999)).triggered, <String>['SAF-302']);
    });

    test('308 = 엄격(0.20 통과 · 넘으면 걸림)', () {
      expect(_judge(_exp(gold: 0.20)).triggered, isEmpty);
      expect(_judge(_exp(gold: 0.2001)).triggered, <String>['SAF-308']);
    });

    test('307 = 엄격 · 조치 = 기록만', () {
      expect(_judge(_exp(usd: 0.50)).triggered, isEmpty);
      final P0sDailyWarn w = _judge(_exp(usd: 0.5001));
      expect(w.triggered, <String>['SAF-307']);
      expect(w.actions, <String, WarnAction>{'SAF-307': WarnAction.record});
    });

    test('원화 유동성 = 엄격(0.01 통과)', () {
      expect(_judge(_exp(krw: 0.01)).krwLiquidityLow, isFalse);
      expect(_judge(_exp(krw: 0.0099)).krwLiquidityLow, isTrue);
    });

    test('셋 다 = 오름차순 · 302 · 308 = 경고', () {
      final P0sDailyWarn w = _judge(
        _exp(defensive: 0.05, gold: 0.25, usd: 0.9),
      );
      expect(w.triggered, <String>['SAF-302', 'SAF-307', 'SAF-308']);
      expect(w.actions, <String, WarnAction>{
        'SAF-302': WarnAction.warn,
        'SAF-307': WarnAction.record,
        'SAF-308': WarnAction.warn,
      });
    });
  });

  group('🔴 넘은 첫날 알림(엣지)', () {
    final P0sDailyWarn calm = _judge(_exp());
    final P0sDailyWarn all = _judge(
      _exp(defensive: 0.05, gold: 0.25, usd: 0.9, krw: 0.005),
    );

    test('어제 안 넘음 → 오늘 넘음 = 1건씩(오름차순) · 307 은 알림 없음', () {
      expect(p0sWarnEdgeAlerts(today: all, yesterday: calm), <String>[
        'DEFENSIVE_FLOOR_BREACHED',
        'GOLD_SHARE_HIGH',
        'KRW_LIQUIDITY_LOW',
      ]);
    });

    test('머무는 동안 = 0건', () {
      expect(p0sWarnEdgeAlerts(today: all, yesterday: all), isEmpty);
    });

    test('어제 계측 없음 = 넘지 않았다로 본다(놓치지 않게)', () {
      expect(p0sWarnEdgeAlerts(today: all), hasLength(3));
    });

    test('내려왔다 다시 넘으면 다시 1건', () {
      expect(p0sWarnEdgeAlerts(today: calm, yesterday: all), isEmpty);
      expect(
        p0sWarnEdgeAlerts(today: _judge(_exp(gold: 0.21)), yesterday: calm),
        <String>['GOLD_SHARE_HIGH'],
      );
    });

    test('알림 등급 = P1 · P1 · P1 · P2(04 §5-3 v2.46)', () {
      expect(
        <AlertLevel>[
          alertLevelOf(kDefensiveFloorAlertCode),
          alertLevelOf(kGoldShareAlertCode),
          alertLevelOf(kFinancialIncomeAlertCode),
          alertLevelOf(kKrwLiquidityAlertCode),
        ],
        <AlertLevel>[
          AlertLevel.p1,
          AlertLevel.p1,
          AlertLevel.p1,
          AlertLevel.p2,
        ],
      );
    });
  });
}
