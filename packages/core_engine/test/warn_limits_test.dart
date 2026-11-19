// SAF 경고 한도 판정 단위 시험(E3c · 설계 13 §8 R166) — 골든 GV-40a~c(`test/golden/gv40abc_warn_limits_test.dart`)가
// 못 보는 몫: 조치 표 · fail-closed · P0S 새틀 없음 · 랭크 정렬 · 같은 랭크 차례 · 경계 이진 정확성.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

final WarnLimitConfig _cfg = WarnLimitConfig(
  satelliteRcMax: 0.40,
  singleRcMax: 0.30,
  minDefensivePct: 0.10,
  kellyFraction: 0.5,
  maxUsdExposurePct: 0.50,
  satelliteBandLow: 0.15,
  satelliteBandHigh: 0.21,
  annualFinancialIncomeCapKrw: Decimal.fromInt(20000000),
  sleeveAMaxPositions: 20,
  sleeveAMaxPerSector: 4,
);

List<List<double>> _diag(List<double> v) => <List<double>>[
  for (int i = 0; i < v.length; i++)
    <double>[for (int j = 0; j < v.length; j++) i == j ? v[i] : 0.0],
];

const List<String> _sym5 = <String>['CORE1', 'SAT1', 'SAT2', 'SAT3', 'SAT4'];
const List<double> _w5 = <double>[0.5, 0.0625, 0.0625, 0.0625, 0.0625];

List<WarnHolding> _holdings(
  List<String> symbols,
  List<double> weights, {
  bool Function(String s)? satellite,
}) => <WarnHolding>[
  for (int i = 0; i < symbols.length; i++)
    WarnHolding(
      symbol: symbols[i],
      isSatellite: (satellite ?? (String s) => s.startsWith('SAT'))(symbols[i]),
      weight: weights[i],
    ),
];

DailyWarnResult _daily({
  List<WarnHolding>? holdings,
  List<List<double>>? cov,
  double defensivePct = 0.20,
  double usdExposurePct = 0.30,
  double riskyExposure = 0.45,
  double variance = 0.0625,
}) => judgeDailyWarnLimits(
  holdings: holdings ?? _holdings(_sym5, _w5),
  covariance:
      cov ?? _diag(<double>[0.029296875, 0.0625, 0.0625, 0.0625, 0.0625]),
  defensivePct: defensivePct,
  usdExposurePct: usdExposurePct,
  riskyExposure: riskyExposure,
  meanReturn: 0.09375,
  riskFree: 0.03125,
  variance: variance,
  config: _cfg,
);

Matcher get _unavailable => throwsA(isA<RiskCheckUnavailable>());

void main() {
  test('조치 표 = 04 §1 «위반 시» 열 — 경고 한도에 거부 없음', () {
    expect(kWarnActions, <String, WarnAction>{
      'SAF-201': WarnAction.rebalance,
      'SAF-202': WarnAction.warnNextRebalance,
      'SAF-204': WarnAction.topN,
      'SAF-205': WarnAction.dropExcess,
      'SAF-208': WarnAction.warnNextRebalance,
      'SAF-302': WarnAction.warn,
      'SAF-305': WarnAction.warn,
      'SAF-306': WarnAction.warn,
      'SAF-307': WarnAction.warn,
    });
  });

  group('일간', () {
    test('🔴 경계 이진 정확 — 202 몫 정확히 0.4 · 208 최대 정확히 0.3(생성기 단언)', () {
      final DailyWarnResult a04 = _daily(
        cov: _diag(<double>[0.005859375, 0.0625, 0.0625, 0.0625, 0.0625]),
      );
      expect(a04.satelliteRcShareOfPortfolio, 0.4);
      expect(a04.triggered, isEmpty);
      final DailyWarnResult a05 = _daily(
        cov: _diag(<double>[0.029296875, 0.1875, 0.1875, 0.1875, 0.0625]),
      );
      expect(
        a05.satelliteInnerRcShares.values.reduce((double a, double b) {
          return a > b ? a : b;
        }),
        0.3,
      );
      expect(a05.triggered, isEmpty);
    });

    test('🔵 P0S 새틀 없음 = 202 몫 0 · 208 건너뜀(참조의 «분산 0» 예외 대신)', () {
      final DailyWarnResult r = _daily(
        holdings: _holdings(_sym5, _w5, satellite: (_) => false),
      );
      expect(r.satelliteRcShareOfPortfolio, 0);
      expect(r.satelliteInnerRcShares, isEmpty);
      expect(r.triggered, isEmpty);
    });

    test('🔵 새틀 비중이 전부 0 = 208 건너뜀', () {
      final DailyWarnResult r = _daily(
        holdings: _holdings(_sym5, <double>[1, 0, 0, 0, 0]),
      );
      expect(r.satelliteInnerRcShares, isEmpty);
      expect(r.triggered, isNot(contains('SAF-208')));
    });

    test('🔴 fail-closed — 판정할 수 없으면 던진다(«경고 없음» 아님)', () {
      expect(
        () => _daily(
          holdings: _holdings(_sym5, <double>[
            0.5,
            double.nan,
            0.0625,
            0.0625,
            0.0625,
          ]),
        ),
        _unavailable,
        reason: '비중 NaN',
      );
      expect(() => _daily(defensivePct: double.nan), _unavailable);
      expect(() => _daily(usdExposurePct: double.infinity), _unavailable);
      expect(() => _daily(riskyExposure: double.nan), _unavailable);
      expect(() => _daily(variance: 0), _unavailable, reason: '켈리 분산 0');
      expect(
        () => _daily(cov: _diag(<double>[0.1, 0.1, 0.1, 0.1])),
        _unavailable,
        reason: '행렬 꼴',
      );
      expect(
        () => _daily(holdings: _holdings(_sym5, <double>[0, 0, 0, 0, 0])),
        _unavailable,
        reason: '포트폴리오 분산 0',
      );
      expect(
        () => _daily(cov: _diag(<double>[0.03, 0, 0, 0, 0])),
        _unavailable,
        reason: '새틀 분산 0(비중은 있음)',
      );
      expect(
        () => judgeDailyWarnLimits(
          holdings: const <WarnHolding>[],
          covariance: const <List<double>>[],
          defensivePct: 0.2,
          usdExposurePct: 0.3,
          riskyExposure: 0.45,
          meanReturn: 0.09375,
          riskFree: 0.03125,
          variance: 0.0625,
          config: _cfg,
        ),
        _unavailable,
        reason: '보유 없음',
      );
    });
  });

  group('월간', () {
    test('소득은 Decimal 로 비교 — 상한 + 0.5원 = 발동', () {
      final MonthlyWarnResult r = judgeMonthlyWarnLimits(
        satelliteAllocPct: 0.18,
        ytdFinancialIncomeKrw: Decimal.parse('20000000.5'),
        config: _cfg,
      );
      expect(r.triggered, <String>['SAF-306']);
    });

    test('🔴 fail-closed — 배분 NaN = 던진다', () {
      expect(
        () => judgeMonthlyWarnLimits(
          satelliteAllocPct: double.nan,
          ytdFinancialIncomeKrw: Decimal.zero,
          config: _cfg,
        ),
        _unavailable,
      );
    });
  });

  group('리밸런싱', () {
    test('랭크 오름차순으로 다시 세운다(들어온 차례가 아님)', () {
      final SleeveASelection r = judgeRebalanceWarnLimits(<SleeveACandidate>[
        const SleeveACandidate(symbol: 'C', rank: 3, sector: 'TECH'),
        const SleeveACandidate(symbol: 'A', rank: 1, sector: 'TECH'),
        const SleeveACandidate(symbol: 'E', rank: 5, sector: 'TECH'),
        const SleeveACandidate(symbol: 'B', rank: 2, sector: 'TECH'),
        const SleeveACandidate(symbol: 'D', rank: 4, sector: 'TECH'),
      ], config: _cfg);
      expect(r.selected, <String>['A', 'B', 'C', 'D']);
      expect(r.excludedBySectorCap, <String>['E']);
      expect(r.triggered, <String>['SAF-205']);
    });

    test('같은 랭크 = 들어온 차례(안정 정렬 · 40종)', () {
      final List<SleeveACandidate> cands = <SleeveACandidate>[
        for (int i = 0; i < 40; i++)
          SleeveACandidate(symbol: 'S$i', rank: 1, sector: null),
      ];
      final SleeveASelection r = judgeRebalanceWarnLimits(cands, config: _cfg);
      expect(r.selected, <String>[for (int i = 0; i < 20; i++) 'S$i']);
      expect(r.excludedByMaxPositions, <String>[
        for (int i = 20; i < 40; i++) 'S$i',
      ]);
      expect(r.triggered, <String>['SAF-204']);
    });

    test('섹터 글자 «UNKNOWN» 도 같은 버킷 — 205 면제', () {
      final SleeveASelection r = judgeRebalanceWarnLimits(<SleeveACandidate>[
        for (int i = 1; i <= 6; i++)
          SleeveACandidate(
            symbol: 'U$i',
            rank: i,
            sector: kUnknownSectorBucket,
          ),
      ], config: _cfg);
      expect(r.selected, hasLength(6));
      expect(r.triggered, isEmpty);
    });

    test('정원 · 섹터 문턱은 config 에서 온다', () {
      final WarnLimitConfig small = WarnLimitConfig(
        satelliteRcMax: 0.40,
        singleRcMax: 0.30,
        minDefensivePct: 0.10,
        kellyFraction: 0.5,
        maxUsdExposurePct: 0.50,
        satelliteBandLow: 0.15,
        satelliteBandHigh: 0.21,
        annualFinancialIncomeCapKrw: Decimal.fromInt(20000000),
        sleeveAMaxPositions: 2,
        sleeveAMaxPerSector: 1,
      );
      final SleeveASelection r = judgeRebalanceWarnLimits(<SleeveACandidate>[
        const SleeveACandidate(symbol: 'A', rank: 1, sector: 'X'),
        const SleeveACandidate(symbol: 'B', rank: 2, sector: 'X'),
        const SleeveACandidate(symbol: 'C', rank: 3, sector: 'Y'),
        const SleeveACandidate(symbol: 'D', rank: 4, sector: 'Z'),
      ], config: small);
      expect(r.selected, <String>['A', 'C']);
      expect(r.excludedBySectorCap, <String>['B']);
      expect(r.excludedByMaxPositions, <String>['D']);
      expect(r.triggered, <String>['SAF-204', 'SAF-205']);
      expect(r.actions, <String, WarnAction>{
        'SAF-204': WarnAction.topN,
        'SAF-205': WarnAction.dropExcess,
      });
    });

    test('후보 없음 = 무발동', () {
      final SleeveASelection r = judgeRebalanceWarnLimits(
        const <SleeveACandidate>[],
        config: _cfg,
      );
      expect(r.selected, isEmpty);
      expect(r.triggered, isEmpty);
      expect(r.candidateCount, 0);
    });
  });
}
