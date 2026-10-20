// 국면 파이프라인 — 원지표 → 정규화 → 방향 스코어 · 추세성 스코어 → 히스테리시스 FSM(봉 루프) ·
// KOSDAQ 추세 점수 — `06_시스템설계/03_알고리즘.md` §1-1 · §1-2 · §1-3 · §1-7 · §1-8 · §5-3-2.
//
// 🔴 지표의 부호·이진·가중·카테고리는 설정(02 §4 `regime.indicator_meta` · `categories`)이다 — 기본값 표
//    [kRegimeIndicatorMeta] · [kRegimeCategories] 는 참조 엔진(백테스트6 `regime.py`)과 같은 값이다.
// 🔴 데이터 부족(방향·추세성 둘 중 하나라도 결측)인 봉: 상태 = UNKNOWN 저장 · 익스포저 0 · 나이·추세성은
//    **직전 값 그대로**(03 §1-1 v1.4 표) — 다음 봉은 UNKNOWN 에서 판정한다(설계 13 §8 R9 결정 2026-10-20).
//    참조 엔진은 내부 상태를 이어 가므로 첫 유효 봉 직후 9봉(1985-11-14~26)만 다르고 그 뒤는 같다(실측).
// 🔵 발표 지연(PIT) 맞추기와 외부 시리즈 정렬은 데이터 수집 쪽 몫이다(M1-7) — 여기는 같은 달력에 놓인
//    시리즈만 받는다.

import 'dart:math' as math;

import 'exposure_gate.dart';
import 'hysteresis.dart';
import 'indicators.dart';
import 'percentile.dart';
import 'regime_score.dart';
import 'regime_states.dart';

/// 지표 부호 — 높을수록 강세(DIRECT) / 약세(INVERSE).
enum IndicatorSign {
  /// 높을수록 강세.
  direct,

  /// 높을수록 약세 — `100 − 백분위`.
  inverse,
}

/// 지표 하나의 설정(02 §4 `regime.indicator_meta`).
class RegimeIndicatorMeta {
  /// 설정을 만든다.
  const RegimeIndicatorMeta({
    required this.sign,
    required this.binary,
    this.weight = 1.0,
  });

  /// 부호.
  final IndicatorSign sign;

  /// 이진 지표(참 → 100 · 거짓 → 0 · 백분위·부호 반전 없음).
  final bool binary;

  /// 카테고리 안 가중치.
  final double weight;
}

/// 기본 지표 설정 — 참조 엔진 `INDICATOR_META` 와 같다.
const Map<String, RegimeIndicatorMeta>
kRegimeIndicatorMeta = <String, RegimeIndicatorMeta>{
  'ma200_gap': RegimeIndicatorMeta(sign: IndicatorSign.direct, binary: false),
  'golden_cross': RegimeIndicatorMeta(sign: IndicatorSign.direct, binary: true),
  'ma200_slope': RegimeIndicatorMeta(sign: IndicatorSign.direct, binary: true),
  'mom_12_1': RegimeIndicatorMeta(sign: IndicatorSign.direct, binary: false),
  'dist_days': RegimeIndicatorMeta(
    sign: IndicatorSign.inverse,
    binary: false,
    weight: 0.5,
  ),
  'rsp_spy_ratio': RegimeIndicatorMeta(
    sign: IndicatorSign.direct,
    binary: false,
  ),
  'vix_level': RegimeIndicatorMeta(sign: IndicatorSign.inverse, binary: false),
  'vix_term': RegimeIndicatorMeta(sign: IndicatorSign.inverse, binary: false),
  'ofr_fsi': RegimeIndicatorMeta(sign: IndicatorSign.inverse, binary: false),
  'nfci': RegimeIndicatorMeta(sign: IndicatorSign.inverse, binary: false),
  'cfnai_ma3': RegimeIndicatorMeta(sign: IndicatorSign.direct, binary: false),
  'yield_curve': RegimeIndicatorMeta(sign: IndicatorSign.direct, binary: false),
  'sahm': RegimeIndicatorMeta(sign: IndicatorSign.inverse, binary: false),
};

/// 기본 카테고리 — 참조 엔진 `CATEGORIES` 와 같다(순서 = 합산 순서).
const Map<RegimeCategory, List<String>> kRegimeCategories =
    <RegimeCategory, List<String>>{
      RegimeCategory.trend: <String>[
        'ma200_gap',
        'golden_cross',
        'ma200_slope',
        'mom_12_1',
      ],
      RegimeCategory.breadth: <String>['dist_days', 'rsp_spy_ratio'],
      RegimeCategory.volatility: <String>['vix_level', 'vix_term'],
      RegimeCategory.credit: <String>['ofr_fsi', 'nfci'],
      RegimeCategory.macro: <String>['cfnai_ma3', 'yield_curve', 'sahm'],
    };

/// 03 §1-2 `mom_12_1` — 1개월 전 종가 / 12개월 전 종가 − 1(«12개월 − 1개월» 이 아니다).
List<double?> momentum12Minus1(List<double?> close) => <double?>[
  for (int t = 0; t < close.length; t++)
    () {
      if (t < 252) return null;
      final double? a = close[t - 21];
      final double? b = close[t - 252];
      if (a == null || b == null || a.isNaN || b.isNaN) return null;
      final double r = a / b - 1.0;
      return r.isNaN ? null : r;
    }(),
];

/// 03 §1-3 분산일 — 최근 [window] 봉(오늘 포함 · 그 앞 봉 제외)에서 «−[dropPct] 이하 하락 + 거래량 증가»였고
/// 그 뒤 최고 종가가 [recoveryPct] 만큼 회복하지 **못한** 날의 수. 모든 봉에 값이 있다.
List<double> distributionDays(
  List<double?> close,
  List<double?> volume, {
  int window = 25,
  double dropPct = 0.002,
  double recoveryPct = 0.05,
}) {
  if (close.length != volume.length) {
    throw ArgumentError('종가 ${close.length} · 거래량 ${volume.length}');
  }
  final int n = close.length;
  final List<double> c = <double>[
    for (final double? x in close) x ?? double.nan,
  ];
  final List<double> v = <double>[
    for (final double? x in volume) x ?? double.nan,
  ];
  final List<bool> isDist = List<bool>.filled(n, false);
  for (int i = 1; i < n; i++) {
    final double ret = c[i] / c[i - 1] - 1.0;
    isDist[i] = ret <= -dropPct && v[i] > v[i - 1]; // NaN 비교는 거짓
  }
  final List<double> out = List<double>.filled(n, 0.0);
  for (int t = 0; t < n; t++) {
    final int lo = math.max(0, t - window);
    int count = 0;
    double? maxAfter; // max(close[i+1 .. t])
    for (int i = t; i > lo; i--) {
      final double after = i == t ? c[t] : maxAfter!;
      if (isDist[i] && !(after / c[i] - 1.0 >= recoveryPct)) count++;
      maxAfter = maxAfter == null ? c[t] : math.max(maxAfter, c[i]);
    }
    out[t] = count.toDouble();
  }
  return out;
}

/// 03 §1-2 TREND 카테고리 4지표(원값 — 이진은 1.0/0.0).
Map<String, List<double?>> trendIndicators(List<double?> close) {
  final List<double?> s50 = sma(close, 50);
  final List<double?> s200 = sma(close, 200);
  bool ok(double? x) => x != null && !x.isNaN;
  return <String, List<double?>>{
    'ma200_gap': <double?>[
      for (int t = 0; t < close.length; t++)
        ok(close[t]) && ok(s200[t]) ? close[t]! / s200[t]! - 1.0 : null,
    ],
    'golden_cross': <double?>[
      for (int t = 0; t < close.length; t++)
        ok(s50[t]) && ok(s200[t]) ? (s50[t]! > s200[t]! ? 1.0 : 0.0) : null,
    ],
    'ma200_slope': <double?>[
      for (int t = 0; t < close.length; t++)
        t >= 21 && ok(s200[t - 21])
            ? (ok(s200[t]) && s200[t]! > s200[t - 21]! ? 1.0 : 0.0)
            : null,
    ],
    'mom_12_1': momentum12Minus1(close),
  };
}

/// 03 §1-1 정규화 — 이진은 ×100, 연속은 [pitPercentile](INVERSE 면 `100 − pct`).
Map<String, List<double?>> normalizeIndicators(
  Map<String, List<double?>> raw, {
  Map<String, RegimeIndicatorMeta> meta = kRegimeIndicatorMeta,
  int minPeriods = 756,
}) => <String, List<double?>>{
  for (final MapEntry<String, List<double?>> e in raw.entries)
    e.key: () {
      final RegimeIndicatorMeta m =
          meta[e.key] ?? (throw ArgumentError('지표 설정이 없다: ${e.key}'));
      if (m.binary) {
        return <double?>[
          for (final double? x in e.value)
            x == null || x.isNaN ? null : x * 100.0,
        ];
      }
      final List<double?> pct = pitPercentile(e.value, minPeriods: minPeriods);
      if (m.sign == IndicatorSign.direct) return pct;
      return <double?>[
        for (final double? p in pct) p == null ? null : 100.0 - p,
      ];
    }(),
};

/// 03 §1-1 방향 스코어 — 날마다 카테고리 가중 평균(살아 있는 지표만) → 유효 카테고리 단순 평균.
List<DirectionScore> directionScores(
  Map<String, List<double?>> normalized, {
  Map<RegimeCategory, List<String>> categories = kRegimeCategories,
  Map<String, RegimeIndicatorMeta> meta = kRegimeIndicatorMeta,
  double minValidRatio = 0.5,
}) {
  final int n = normalized.values.first.length;
  return <DirectionScore>[
    for (int t = 0; t < n; t++)
      aggregateDirection(<RegimeCategory, CategoryInput>{
        for (final MapEntry<RegimeCategory, List<String>> c
            in categories.entries)
          c.key: CategoryInput(
            definedCount: c.value.length,
            available: <IndicatorScore>[
              for (final String name in c.value)
                if (normalized[name] != null &&
                    normalized[name]![t] != null &&
                    !normalized[name]![t]!.isNaN)
                  IndicatorScore(
                    normalized[name]![t]!,
                    weight: meta[name]!.weight,
                  ),
            ],
          ),
      }, minValidRatio: minValidRatio),
  ];
}

/// 03 §1-8 추세성 스코어 세 부분 — `pit(100 − CHOP14)` · `pit(ADX14 · 150봉)` · `rolling(BBW20·2σ, 126)`.
Map<String, List<double?>> trendinessParts({
  required List<double?> high,
  required List<double?> low,
  required List<double?> close,
  int minPeriods = 756,
}) {
  final List<double?> ch = chop(high, low, close, 14);
  return <String, List<double?>>{
    'chop': pitPercentile(<double?>[
      for (final double? x in ch) x == null ? null : 100.0 - x,
    ], minPeriods: minPeriods),
    'adx': pitPercentile(
      adx(high, low, close, period: 14, warmup: 150),
      minPeriods: minPeriods,
    ),
    'bbw': rollingPercentile(bbw(close, period: 20, numStd: 2.0), 126),
  };
}

/// 살아 있는 값의 평균 — [minValid] 개보다 적으면 null(`mean(axis=1, skipna)` + `.where(count ≥ k)`).
List<double?> meanOfAvailable(
  List<List<double?>> parts, {
  required int minValid,
}) {
  final int n = parts.first.length;
  return <double?>[
    for (int t = 0; t < n; t++)
      () {
        double sum = 0;
        int count = 0;
        for (final List<double?> p in parts) {
          final double? v = p[t];
          if (v != null && !v.isNaN) {
            sum += v;
            count++;
          }
        }
        return count >= minValid && count > 0 ? sum / count : null;
      }(),
  ];
}

/// 국면 한 봉의 결과.
class RegimeDay {
  /// 결과를 만든다.
  const RegimeDay({
    required this.status,
    required this.directionState,
    required this.barsInState,
    required this.trendState,
    required this.exposure,
  });

  /// OK · INSUFFICIENT_DATA.
  final RegimeStatus status;

  /// 방향 상태(데이터 부족이면 UNKNOWN).
  final DirectionState directionState;

  /// 그 상태에 머문 봉 수.
  final int barsInState;

  /// 추세성 상태.
  final TrendState trendState;

  /// 익스포저 = f(방향) × g(추세성) — 데이터 부족이면 0.
  final double exposure;
}

/// 03 §1-1 ③ · §1-7 · §1-8 — 봉 루프. 초기 상태 = NEUTRAL · 나이 0 · 추세성 LOW.
List<RegimeDay> runRegimeFsm(
  List<double?> direction,
  List<double?> trendiness, {
  required DirectionHysteresis directionConfig,
  required TrendHysteresis trendConfig,
}) {
  if (direction.length != trendiness.length) {
    throw ArgumentError('방향 ${direction.length} · 추세성 ${trendiness.length}');
  }
  DirectionState state = DirectionState.neutral;
  int bars = 0;
  TrendState trend = TrendState.low;
  final List<RegimeDay> out = <RegimeDay>[];
  for (int t = 0; t < direction.length; t++) {
    final double? d = direction[t];
    final double? tr = trendiness[t];
    if (d == null || d.isNaN || tr == null || tr.isNaN) {
      state = DirectionState.unknown; // 저장 — 다음 봉은 UNKNOWN 에서 판정(R9)
      out.add(
        RegimeDay(
          status: RegimeStatus.insufficientData,
          directionState: state,
          barsInState: bars,
          trendState: trend,
          exposure: 0.0,
        ),
      );
      continue;
    }
    // 창 = 최근 확인 봉 수(앞쪽 결측이 섞이면 판정하지 않는다 — 참조 엔진과 같다).
    final ({DirectionState state, int barsInState}) next = applyHysteresis(
      direction.sublist(
        math.max(0, t - directionConfig.confirmBars + 1),
        t + 1,
      ),
      state,
      bars,
      directionConfig,
    );
    state = next.state;
    bars = next.barsInState;
    trend = applyTrendHysteresis(
      trendiness.sublist(math.max(0, t - trendConfig.confirmBars + 1), t + 1),
      trend,
      trendConfig,
    );
    out.add(
      RegimeDay(
        status: RegimeStatus.ok,
        directionState: state,
        barsInState: bars,
        trendState: trend,
        exposure: exposureGate(state, trend),
      ),
    );
  }
  return out;
}

/// 03 §5-3-2 `trend_score_kr` — KOSDAQ 에 TREND 4지표만(부호 반전 없음) · 살아 있는 지표 2개 이상.
List<double?> trendScoreKr(List<double?> close, {int minPeriods = 756}) {
  final Map<String, List<double?>> parts = normalizeIndicators(
    trendIndicators(close),
    minPeriods: minPeriods,
  );
  return meanOfAvailable(<List<double?>>[
    parts['ma200_gap']!,
    parts['golden_cross']!,
    parts['ma200_slope']!,
    parts['mom_12_1']!,
  ], minValid: (0.5 * 4).ceil());
}
