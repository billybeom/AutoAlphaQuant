// M1-7 → M1-2 국면 입력 조립 — 원천 시리즈 한 벌 → 원지표 13개 → 정규화 → 방향 → 추세성 → FSM
// (설계 13 §8 R23 D6 · R24 B2 · E8b2).
//
// 🔵 E6 재현 하네스(`test/replay/replay_regime.dart` `ReplayRegime.build`)에서 옮겼다 — 하네스가 이것을 부르므로
//    26년 재현 비트 일치가 회귀 시험이다(참조 엔진 백테스트6 `regime.build_raw_indicators` · `market.build`).
// 🔴 달력 = ^GSPC 세션(1985-01-02 ~) — 확장 백분위와 FSM 이 처음부터 누적된다. 오늘 값 하나로는 계산할 수 없다
//    (시드 = 동결 번들 · R23 D9).
// 🔴 발표 지연은 [kPublishLagDays](달력일) · as-of 는 [alignWithLag](같은 날짜 포함 — 미국 달력 위의 일이다).
// 🔴 신선도 상한([RegimeFreshnessCaps])은 **실전 경로만**이다 — 참조 엔진은 ffill 이 무제한이라, 재현(골든)은 상한 없이
//    돌리고 하네스가 «상한이 걸렸을 날»을 세어 단언한다(R23 D6). 상한을 넘은 값은 결측(null)이 되고 카테고리 안
//    재정규화가 이어받는다(03 §1-1 · R23 D4 미국·매크로 갈래).

import '../signals/hysteresis.dart';
import '../signals/indicators.dart';
import '../signals/regime_pipeline.dart';
import '../signals/regime_score.dart';
import 'dated_series.dart';
import 'pit_align.dart';

/// 🆕 E8d1(설계 13 §8 R27 I1 · R28 K2) — `dist_days` 가 읽는 거래량.
enum DistVolumeSource {
  /// ^GSPC 거래량 — 참조 엔진 골든(재현 하네스 · 정답지 `regime_parity.json`).
  gspcIndex,

  /// SPY 거래량(같은 날짜만) — 실전 P0S. KIS 는 ^GSPC 거래량을 0 으로만 준다(실험 5 · 07 §6-2).
  /// 참조 엔진 V6a_w(E8-0b) = 골든과 CAGR +0.0004 · MDD +0.0130%p · 정답지 `regime_parity_v6a.json`.
  spyEtf,
}

/// 실전 P0S 의 `dist_days` 거래량(R27 I1 — 발주자 2026-10-29 «V6a 로 정해»).
const DistVolumeSource kP0sDistVolume = DistVolumeSource.spyEtf;

/// 국면 원천 시리즈 한 벌 — 수집(E8c)이 저장소에서 채우고, 재현 하네스는 동결 번들 CSV 에서 채운다.
class RegimeSources {
  const RegimeSources({
    required this.usDates,
    required this.usClose,
    required this.usHigh,
    required this.usLow,
    required this.usVolume,
    required this.spyAdjClose,
    required this.spyVolume,
    required this.rspAdjClose,
    required this.vix,
    required this.vix3m,
    required this.ofrFsi,
    required this.nfci,
    required this.cfnaiMa3,
    required this.t10y3m,
    required this.sahm,
    required this.distVolume,
  });

  /// ^GSPC 세션(= 국면 달력) · 종가 · 고가 · 저가 · 거래량(null = 결측).
  final List<String> usDates;
  final List<double?> usClose, usHigh, usLow, usVolume;

  /// SPY · RSP 수정종가 · ^VIX · ^VIX3M 종가 · OFR FSI · NFCI · CFNAIMA3 · T10Y3M · SAHMREALTIME(NaN = 결측).
  final DatedSeries spyAdjClose, rspAdjClose, vix, vix3m;
  final DatedSeries ofrFsi, nfci, cfnaiMa3, t10y3m, sahm;

  /// 🆕 SPY 거래량(NaN = 결측) — [DistVolumeSource.spyEtf] 일 때 `dist_days` 가 읽는다(달력 위 **같은 날짜만** ·
  /// as-of 채움 없음 — 그날 없으면 결측이고 [maskVolumeGaps] 가 창 26봉을 결측으로 만든다 · R28 K3·K4).
  final DatedSeries spyVolume;

  /// 🆕 `dist_days` 거래량을 어디서 읽나 — 만드는 쪽이 고른다(골든 재현 = [DistVolumeSource.gspcIndex] ·
  /// 실전 = [kP0sDistVolume]).
  final DistVolumeSource distVolume;
}

/// [s] 의 `dist_days` 거래량을 국면 달력 위에 놓는다(R28 K2 — SPY 는 같은 날짜만).
List<double?> distVolumeOnCalendar(RegimeSources s) => switch (s.distVolume) {
  DistVolumeSource.gspcIndex => s.usVolume,
  DistVolumeSource.spyEtf => <double?>[
    for (final String d in s.usDates)
      () {
        final double? v = s.spyVolume.at(d);
        return v == null || v.isNaN ? null : v;
      }(),
  ],
};

/// P0S 방향 히스테리시스(02 §4 기본값 · 03 §1-7).
final DirectionHysteresis kP0sDirectionHysteresis = DirectionHysteresis(
  up: 60,
  down: 40,
  confirmBars: 3,
  minHoldBars: 10,
);

/// P0S 추세성 히스테리시스(02 §4 기본값).
final TrendHysteresis kP0sTrendHysteresis = TrendHysteresis(
  trendIn: 35,
  trendOut: 45,
  confirmBars: 3,
);

/// 국면 계산 한 벌.
class RegimeComputation {
  const RegimeComputation({
    required this.calendar,
    required this.raw,
    required this.normalized,
    required this.direction,
    required this.trendinessParts,
    required this.trendiness,
    required this.fsm,
  });

  /// US 세션(국면 달력).
  final List<String> calendar;

  /// 원지표 13개 · 정규화 13개.
  final Map<String, List<double?>> raw, normalized;

  /// 날마다 방향 스코어.
  final List<DirectionScore> direction;

  /// 추세성 세 부분(chop · adx · bbw) · 추세성 스코어.
  final Map<String, List<double?>> trendinessParts;
  final List<double?> trendiness;

  /// FSM(03 방식 — R9).
  final List<RegimeDay> fsm;
}

List<double?> _nullable(List<double> v) => <double?>[
  for (final double x in v) x.isNaN ? null : x,
];

/// 원지표 13개(참조 엔진 `build_raw_indicators` — 같은 연산 순서).
Map<String, List<double?>> regimeRawIndicators(RegimeSources s) {
  final List<String> cal = s.usDates;
  final List<double?> vol = distVolumeOnCalendar(s);
  final Map<String, List<double?>> raw = <String, List<double?>>{
    ...trendIndicators(s.usClose),
    'dist_days': maskVolumeGaps(distributionDays(s.usClose, vol), vol),
  };

  final DatedSeries spy = s.spyAdjClose.dropNa();
  final DatedSeries rsp = s.rspAdjClose.dropNa();
  final DatedSeries ratio = DatedSeries(rsp.dates, <double>[
    for (int i = 0; i < rsp.length; i++)
      rsp.values[i] / (spy.at(rsp.dates[i]) ?? double.nan),
  ]).dropNa();
  final List<double?> ratioSma = sma(_nullable(ratio.values), 50);
  raw['rsp_spy_ratio'] = _nullable(
    alignWithLag(
      DatedSeries(ratio.dates, <double>[
        for (int i = 0; i < ratio.length; i++)
          ratio.values[i] / (ratioSma[i] ?? double.nan) - 1.0,
      ]),
      cal,
    ).values,
  );

  final DatedSeries vix = s.vix.dropNa();
  raw['vix_level'] = _nullable(alignWithLag(vix, cal).values);
  final DatedSeries v3 = s.vix3m.dropNa();
  raw['vix_term'] = _nullable(
    alignWithLag(
      DatedSeries(v3.dates, <double>[
        for (int i = 0; i < v3.length; i++)
          (vix.at(v3.dates[i]) ?? double.nan) / v3.values[i],
      ]).dropNa(),
      cal,
    ).values,
  );

  for (final (String name, DatedSeries src) in <(String, DatedSeries)>[
    ('ofr_fsi', s.ofrFsi),
    ('nfci', s.nfci),
    ('cfnai_ma3', s.cfnaiMa3),
    ('yield_curve', s.t10y3m),
    ('sahm', s.sahm),
  ]) {
    raw[name] = _nullable(
      alignWithLag(src, cal, lag: kPublishLagDays[name]!).values,
    );
  }
  return raw;
}

/// 국면 한 벌 — 원지표 → 정규화 → 방향 → 추세성(chop·adx·bbw 평균 · 하나 이상) → FSM.
/// [raw] 를 주면 그것을 쓴다(신선도 상한을 건 원지표 — [applyFreshnessCaps]).
RegimeComputation computeRegime(
  RegimeSources s, {
  Map<String, List<double?>>? raw,
  DirectionHysteresis? directionConfig,
  TrendHysteresis? trendConfig,
}) {
  final Map<String, List<double?>> r = raw ?? regimeRawIndicators(s);
  final Map<String, List<double?>> norm = normalizeIndicators(r);
  final List<DirectionScore> dir = directionScores(norm);
  final Map<String, List<double?>> tParts = trendinessParts(
    high: s.usHigh,
    low: s.usLow,
    close: s.usClose,
  );
  final List<double?> trend = meanOfAvailable(<List<double?>>[
    tParts['chop']!,
    tParts['adx']!,
    tParts['bbw']!,
  ], minValid: 1);
  final List<RegimeDay> fsm = runRegimeFsm(
    <double?>[for (final DirectionScore d in dir) d.direction],
    trend,
    directionConfig: directionConfig ?? kP0sDirectionHysteresis,
    trendConfig: trendConfig ?? kP0sTrendHysteresis,
  );
  return RegimeComputation(
    calendar: s.usDates,
    raw: r,
    normalized: norm,
    direction: dir,
    trendinessParts: tParts,
    trendiness: trend,
    fsm: fsm,
  );
}

/// 원천 시리즈의 갱신 주기(R23 D6).
enum SeriesCadence {
  /// 일간 — 상한 = 국면 달력 세션 수.
  daily,

  /// 주간(NFCI) — 상한 = 달력일.
  weekly,

  /// 월간(CFNAI · Sahm) — 상한 = 발표 지연 뒤 달력일.
  monthly,
}

/// 신선도 상한(R23 D6) — 마지막 관측(발표 지연을 더한 날) 뒤로 이만큼 지나면 그 값을 쓰지 않는다.
class RegimeFreshnessCaps {
  const RegimeFreshnessCaps({
    this.dailySessions = 5,
    this.weeklyDays = 21,
    this.monthlyDays = 45,
  });

  /// 일간: 국면 달력 세션 수(기본 5).
  final int dailySessions;

  /// 주간: 달력일(기본 21).
  final int weeklyDays;

  /// 월간: 발표 지연 뒤 달력일(기본 45).
  final int monthlyDays;
}

/// 원지표 → (원천 · 주기). 🔴 ^GSPC 에서 나오는 지표(TREND 4 · dist_days)는 달력 자체라 여기 없다 —
/// 달력이 늦는지는 미국 세션 표로 따로 본다([usCalendarLagSessions]). 🆕 `dist_days` 가 SPY 거래량을 읽을 때
/// ([DistVolumeSource.spyEtf])도 상한이 따로 없다 — 같은 날짜만 읽으므로 SPY 가 늦거나 빠진 날은 결측이고
/// [maskVolumeGaps] 가 그 창을 결측으로 만든다(R28 K4).
const Map<String, SeriesCadence> kRegimeSourceCadence = <String, SeriesCadence>{
  'rsp_spy_ratio': SeriesCadence.daily,
  'vix_level': SeriesCadence.daily,
  'vix_term': SeriesCadence.daily,
  'ofr_fsi': SeriesCadence.daily,
  'nfci': SeriesCadence.weekly,
  'cfnai_ma3': SeriesCadence.monthly,
  'yield_curve': SeriesCadence.daily,
  'sahm': SeriesCadence.monthly,
};

DatedSeries _sourceOf(RegimeSources s, String name) {
  switch (name) {
    case 'rsp_spy_ratio':
      final DatedSeries spy = s.spyAdjClose.dropNa();
      final DatedSeries rsp = s.rspAdjClose.dropNa();
      return DatedSeries(rsp.dates, <double>[
        for (int i = 0; i < rsp.length; i++)
          rsp.values[i] / (spy.at(rsp.dates[i]) ?? double.nan),
      ]).dropNa();
    case 'vix_level':
      return s.vix.dropNa();
    case 'vix_term':
      final DatedSeries vix = s.vix.dropNa();
      final DatedSeries v3 = s.vix3m.dropNa();
      return DatedSeries(v3.dates, <double>[
        for (int i = 0; i < v3.length; i++)
          (vix.at(v3.dates[i]) ?? double.nan) / v3.values[i],
      ]).dropNa();
    case 'ofr_fsi':
      return s.ofrFsi.dropNa();
    case 'nfci':
      return s.nfci.dropNa();
    case 'cfnai_ma3':
      return s.cfnaiMa3.dropNa();
    case 'yield_curve':
      return s.t10y3m.dropNa();
    case 'sahm':
      return s.sahm.dropNa();
  }
  throw ArgumentError.value(name, 'name', '신선도 원천이 없는 지표');
}

/// 지표마다 «상한을 넘은 날»(국면 달력 위) — 마지막 관측(+ 발표 지연)부터 상한보다 오래 지난 날.
/// 관측이 아직 하나도 없는 날(이력 시작 전)은 넣지 않는다 — 그것은 «오래됨»이 아니라 «아직 없음»이다.
Map<String, List<String>> regimeStaleDays(
  RegimeSources s, {
  RegimeFreshnessCaps caps = const RegimeFreshnessCaps(),
}) {
  final List<String> cal = s.usDates;
  final DatedSeries calIndex = DatedSeries(cal, <double>[
    for (int i = 0; i < cal.length; i++) i.toDouble(),
  ]);
  final Map<String, List<String>> out = <String, List<String>>{};
  for (final MapEntry<String, SeriesCadence> e
      in kRegimeSourceCadence.entries) {
    final DatedSeries src = _sourceOf(s, e.key);
    final int lag = kPublishLagDays[e.key] ?? 0;
    final List<String> known = <String>[
      for (final String d in src.dates) lag == 0 ? d : plusDays(d, lag),
    ];
    final List<String> stale = <String>[];
    int p = -1;
    for (int t = 0; t < cal.length; t++) {
      while (p + 1 < known.length && known[p + 1].compareTo(cal[t]) <= 0) {
        p++;
      }
      if (p < 0) continue;
      final bool over = switch (e.value) {
        SeriesCadence.daily =>
          t - calIndex.lastAtOrBefore(known[p]) > caps.dailySessions,
        SeriesCadence.weekly => daysBetween(known[p], cal[t]) > caps.weeklyDays,
        SeriesCadence.monthly =>
          daysBetween(known[p], cal[t]) > caps.monthlyDays,
      };
      if (over) stale.add(cal[t]);
    }
    out[e.key] = stale;
  }
  return out;
}

/// 신선도 상한을 건 원지표 — [regimeStaleDays] 의 날은 그 지표를 결측(null)으로 바꾼다(실전 경로 · R23 D6).
Map<String, List<double?>> applyFreshnessCaps(
  RegimeSources s,
  Map<String, List<double?>> raw, {
  RegimeFreshnessCaps caps = const RegimeFreshnessCaps(),
}) {
  final Map<String, List<String>> stale = regimeStaleDays(s, caps: caps);
  final Map<String, int> pos = <String, int>{
    for (int i = 0; i < s.usDates.length; i++) s.usDates[i]: i,
  };
  return <String, List<double?>>{
    for (final MapEntry<String, List<double?>> e in raw.entries)
      e.key: () {
        final List<String>? days = stale[e.key];
        if (days == null || days.isEmpty) return e.value;
        final List<double?> v = List<double?>.of(e.value);
        for (final String d in days) {
          v[pos[d]!] = null;
        }
        return v;
      }(),
  };
}

/// 국면 달력(^GSPC)이 미국 세션 표보다 몇 세션 늦나 — 마지막 데이터 날짜 뒤 [asOf] 까지의 미국 세션 수.
/// 상한(일간 5)을 넘으면 미국 계열 전체가 낡은 것이다(R23 D6). [usSessions] = 동결 XNYS 세션(오름차순).
int usCalendarLagSessions(
  String lastUsDate,
  String asOf,
  List<String> usSessions,
) {
  int n = 0;
  for (final String d in usSessions) {
    if (d.compareTo(lastUsDate) > 0 && d.compareTo(asOf) <= 0) n++;
  }
  return n;
}
