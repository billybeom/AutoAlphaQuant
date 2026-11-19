// 골든벡터 GV-1~4(국면 — 방향 점수 · 지표 · 익스포저 게이트 · 이력) 판정(E11o-a · 설계 13 §8 R162).
//
// 🔴 옛 시험(`test/golden/gv01~04_*_test.dart`)의 판정을 한 글자도 바꾸지 않고 옮겼다 — 시험은 이제 이 케이스를 부른다.
// 🔴 정답지 · 출처 · 허용오차 = 05 v1.22 본문(test/golden/vectors/SOURCES.md) · 파일럿1 옛 벡터는 쓰지 않는다.

import '../signals/exposure_gate.dart' show exposureGate, trendFactor;
import '../signals/hysteresis.dart'
    show
        DirectionHysteresis,
        TrendHysteresis,
        applyHysteresis,
        applyTrendHysteresis;
import '../signals/indicators.dart'
    show adx, atr, bbw, chop, rmaStep, trueRange;
import '../signals/regime_score.dart'
    show
        CategoryInput,
        DirectionScore,
        IndicatorScore,
        RegimeCategory,
        RegimeStatus,
        aggregateDirection,
        directionFromCategoryScores;
import '../signals/regime_states.dart' show DirectionState, TrendState;
import 'golden_runner.dart';

/// 03 §0-4 «스코어 1e-4»(GV-1a~1d 블록엔 값이 없다 · 1e 와 같은 값).
const double _scoreTolerance = 1e-4;

Map<RegimeCategory, double?> _scores(Object? json) => <RegimeCategory, double?>{
  for (final MapEntry<String, Object?> e in gvObject(json).entries)
    RegimeCategory.fromCode(e.key): e.value == null ? null : gvDouble(e.value),
};

/// GV-1 방향 스코어 — 카테고리 재정규화(05 §GV-1 · 03 §1-1).
class Gv1RegimeScore implements GoldenFamily {
  /// 만든다.
  const Gv1RegimeScore();

  @override
  String get id => 'GV-1';

  @override
  Set<String> get files => const <String>{
    'gv01a_all_valid.json',
    'gv01b_two_missing.json',
    'gv01c_category_exclusion.json',
    'gv01d_all_missing.json',
    'gv01e_zero_is_not_missing.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> e = b.json('gv01e_zero_is_not_missing.json');
    final double tolE = gvDouble(e['tolerance']);
    return <GvCase>[
      for (final (String id, String file) in <(String, String)>[
        ('1a', 'gv01a_all_valid.json'),
        ('1b', 'gv01b_two_missing.json'),
      ])
        GvCase('GV-$id', () {
          final Map<String, Object?> v = b.json(file);
          final DirectionScore r = directionFromCategoryScores(
            _scores(gvObject(v['input'])['category_scores']),
          );
          return (GvProbe()
                ..same(r.status, RegimeStatus.ok, 'status')
                ..close(
                  r.direction,
                  gvDouble(gvObject(v['expected'])['direction']),
                  _scoreTolerance,
                  'direction(결측 카테고리에 50점을 넣으면 오답)',
                ))
              .failure;
        }),
      GvCase('GV-1c', () {
        final Map<String, Object?> v = b.json('gv01c_category_exclusion.json');
        final Map<String, Object?> input = gvObject(v['input']);
        final Map<String, Object?> defined = gvObject(
          input['category_definitions'],
        );
        final Map<String, Object?> available = gvObject(
          input['available_indicators'],
        );
        final Map<String, Object?> means = gvObject(input['indicator_means']);
        // 벡터는 지표 수와 평균만 준다 — 평균이 같은 지표 n개로 펼쳐 집계 함수에 넣는다(05 §GV-1c 📌).
        final DirectionScore r = aggregateDirection(
          <RegimeCategory, CategoryInput>{
            for (final String code in defined.keys)
              RegimeCategory.fromCode(code): CategoryInput(
                definedCount: gvInt(defined[code]),
                available: List<IndicatorScore>.filled(
                  gvInt(available[code]),
                  IndicatorScore(gvDouble(means[code])),
                ),
              ),
          },
          minValidRatio: 0.5,
        ); // 설정 키 regime.category_min_valid_ratio 기본값(05 §GV-1c)
        final Map<String, Object?> expected = gvObject(v['expected']);
        return (GvProbe()
              ..same(
                r.excluded.map((RegimeCategory c) => c.code).toList(),
                gvStringList(expected['excluded_categories']),
                'excluded',
              )
              ..close(
                r.direction,
                gvDouble(expected['direction']),
                _scoreTolerance,
                'direction(50% 임계를 빠뜨리면 70.0)',
              ))
            .failure;
      }),
      GvCase('GV-1d', () {
        final Map<String, Object?> v = b.json('gv01d_all_missing.json');
        final DirectionScore r = directionFromCategoryScores(
          _scores(gvObject(v['input'])['category_scores']),
        );
        final Map<String, Object?> expected = gvObject(v['expected']);
        return (GvProbe()
              ..same(r.status.code, gvString(expected['status']), 'status')
              ..none(r.direction, 'direction')
              ..none(expected['direction'], '정답지 direction'))
            .failure;
      }),
      for (final Map<String, Object?> c in gvObjectList(e['cases']))
        GvCase('GV-1${gvString(c['id'])}', () {
          final DirectionScore r = directionFromCategoryScores(
            _scores(gvObject(c['input'])['category_scores']),
          );
          final Map<String, Object?> expected = gvObject(c['expected']);
          return (GvProbe()
                ..same(r.status.code, gvString(expected['status']), 'status')
                ..close(
                  r.direction,
                  gvDouble(expected['direction']),
                  tolE,
                  'direction',
                ))
              .failure;
        }),
    ];
  }
}

/// 05 §GV-2f 생성식 — 난수 없음.
({List<double?> high, List<double?> low, List<double?> close}) _generatorBars(
  int count,
) {
  final List<double> base = <double>[
    for (int i = 0; i < count; i++)
      100.0 + 0.10 * i + 6.0 * (((i % 40) / 20.0) - 1.0).abs(),
  ];
  return (
    high: <double?>[for (final double x in base) x + 1.5],
    low: <double?>[for (final double x in base) x - 1.5],
    close: <double?>[for (final double x in base) x + 0.5],
  );
}

/// GV-2 기술 지표(05 §GV-2 · 03 §0-3 · §1-5).
class Gv2Indicators implements GoldenFamily {
  /// 만든다.
  const Gv2Indicators();

  @override
  String get id => 'GV-2';

  @override
  Set<String> get files => const <String>{
    'gv02a_atr_wilder.json',
    'gv02b_chop.json',
    'gv02c_adx_warmup.json',
    'gv02d_wilder_rma.json',
    'gv02d_tolerance.json',
    'gv02e_bbw.json',
    'gv02f_adx_values.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    // GV-2a · 2b 공통 입력(05 §GV-2b «위와 동일 입력»).
    final Map<String, Object?> gv2a = b.json('gv02a_atr_wilder.json');
    final Map<String, Object?> input = gvObject(gv2a['input']);
    final List<double?> high = gvNumList(input['high']);
    final List<double?> low = gvNumList(input['low']);
    final List<double?> close = gvNumList(input['close']);
    final int period = gvInt(input['period']);
    final Map<String, Object?> exp2a = gvObject(gv2a['expected']);
    final double tol2a = gvDouble(gv2a['tolerance']);
    final Map<String, Object?> f = b.json('gv02f_adx_values.json');
    final Map<String, Object?> in2f = gvObject(f['input']);
    final double tol2f = gvDouble(f['tolerance']);
    final RegExp key = RegExp(r'^adx\[(\d+)\]$');
    List<double?>? adx2f;
    List<double?> adx2fOnce() {
      final ({List<double?> high, List<double?> low, List<double?> close}) s =
          _generatorBars(200);
      return adx2f ??= adx(
        s.high,
        s.low,
        s.close,
        period: gvInt(in2f['period']),
        warmup: gvInt(in2f['warmup']),
      );
    }

    return <GvCase>[
      GvCase(
        'GV-2a TR',
        () =>
            (GvProbe()..series(
                  trueRange(high, low, close),
                  gvNumList(exp2a['tr']),
                  tol2a,
                  'tr',
                ))
                .failure,
      ),
      GvCase(
        'GV-2a ATR',
        () =>
            (GvProbe()..series(
                  atr(high, low, close, period),
                  gvNumList(exp2a['atr']),
                  tol2a,
                  'atr',
                ))
                .failure,
      ),
      GvCase('GV-2b CHOP', () {
        final Map<String, Object?> v = b.json('gv02b_chop.json');
        return (GvProbe()..series(
              chop(high, low, close, period),
              gvNumList(gvObject(v['expected'])['chop']),
              gvDouble(v['tolerance']),
              'chop',
            ))
            .failure;
      }),
      GvCase('GV-2c ADX 워밍업', () {
        final Map<String, Object?> v = b.json('gv02c_adx_warmup.json');
        final Map<String, Object?> in2c = gvObject(v['input']);
        final int bars = gvInt(in2c['bars']);
        final ({List<double?> high, List<double?> low, List<double?> close}) s =
            _generatorBars(bars);
        final List<double?> result = adx(
          s.high,
          s.low,
          s.close,
          period: gvInt(in2c['period']),
          warmup: 150, // 05 §GV-2c «워밍업 150봉» · 03 §0-3 하드 게이트
        );
        return (GvProbe()
              ..none(gvObject(v['expected'])['adx'], '정답지 adx')
              ..same(result.length, bars, '길이')
              ..truth(
                result.every((double? x) => x == null),
                '149봉이면 전부 결측이어야 한다',
              ))
            .failure;
      }),
      GvCase('GV-2d Wilder 한 걸음', () {
        final Map<String, Object?> v = b.json('gv02d_wilder_rma.json');
        final Map<String, Object?> in2d = gvObject(v['input']);
        return (GvProbe()..close(
              rmaStep(
                gvDouble(in2d['prev_rma']),
                gvDouble(in2d['new_value']),
                gvInt(in2d['period']),
              ),
              gvDouble(gvObject(v['expected'])['rma']),
              gvDouble(b.json('gv02d_tolerance.json')['tolerance']),
              'rma(α = 1/n)',
            ))
            .failure;
      }),
      GvCase('GV-2e BBW', () {
        final Map<String, Object?> v = b.json('gv02e_bbw.json');
        final Map<String, Object?> in2e = gvObject(v['input']);
        return (GvProbe()..series(
              bbw(
                gvNumList(in2e['close']),
                period: gvInt(in2e['period']),
                numStd: gvDouble(in2e['num_std']),
              ),
              gvNumList(gvObject(v['expected'])['bbw']),
              gvDouble(v['tolerance']),
              'bbw(ddof 0)',
            ))
            .failure;
      }),
      GvCase(
        'GV-2f 생성식',
        () =>
            (GvProbe()
                  ..same(
                    gvString(in2f['generator']),
                    'base[i] = 100.0 + 0.10*i + 6.0*abs(((i % 40)/20.0) - 1.0),  i = 0..199',
                    'generator',
                  )
                  ..same(gvString(in2f['high']), 'base + 1.5', 'high')
                  ..same(gvString(in2f['low']), 'base - 1.5', 'low')
                  ..same(gvString(in2f['close']), 'base + 0.5', 'close'))
                .failure,
      ),
      for (final MapEntry<String, Object?> e in gvObject(f['expected']).entries)
        GvCase('GV-2f ${e.key}', () {
          final RegExpMatch? m = key.firstMatch(e.key);
          if (m == null) return '키 꼴이 아니다: ${e.key}';
          final double? got = adx2fOnce()[int.parse(m.group(1)!)];
          final Object? want = e.value;
          return want == null
              ? (GvProbe()..none(got, '워밍업 구간')).failure
              : (GvProbe()..close(got, gvDouble(want), tol2f, e.key)).failure;
        }),
    ];
  }
}

/// GV-3 익스포저 게이트(곱셈) · GV-3c UNKNOWN fail-closed(05 §GV-3 · 03 §1-8).
class Gv3ExposureGate implements GoldenFamily {
  /// 만든다.
  const Gv3ExposureGate();

  @override
  String get id => 'GV-3';

  @override
  Set<String> get files => const <String>{
    'gv03_exposure_gate.json',
    'gv03c_unknown_fail_closed.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) => <GvCase>[
    for (final (String tag, String file) in <(String, String)>[
      ('GV-3', 'gv03_exposure_gate.json'),
      ('GV-3c', 'gv03c_unknown_fail_closed.json'),
    ])
      for (final Map<String, Object?> c in gvObjectList(b.json(file)['cases']))
        GvCase(
          '$tag ${gvString(c['direction_state'])} × ${gvString(c['trend_state'])}',
          () =>
              (GvProbe()..close(
                    exposureGate(
                      DirectionState.fromCode(gvString(c['direction_state'])),
                      TrendState.fromCode(gvString(c['trend_state'])),
                    ),
                    gvDouble(c['expected_exposure']),
                    gvDouble(b.json(file)['tolerance']),
                    'exposure',
                  ))
                  .failure,
        ),
  ];
}

/// 방향 FSM 을 봉마다 돌려 (상태 코드, 나이) 목록(03 §1-7 호출 규약 — 시리즈를 한 봉씩 늘린다).
({List<String> states, List<int> bars}) _runDirection(
  List<double?> series,
  DirectionHysteresis config,
  DirectionState initialState,
  int initialBars,
) {
  DirectionState state = initialState;
  int bars = initialBars;
  final List<String> states = <String>[];
  final List<int> barsOut = <int>[];
  for (int t = 1; t <= series.length; t++) {
    final ({DirectionState state, int barsInState}) r = applyHysteresis(
      series.sublist(0, t),
      state,
      bars,
      config,
    );
    state = r.state;
    bars = r.barsInState;
    states.add(state.code);
    barsOut.add(bars);
  }
  return (states: states, bars: barsOut);
}

/// 추세성 FSM 을 봉마다.
List<TrendState> _runTrend(
  List<double?> series,
  TrendHysteresis config,
  TrendState initial,
) {
  TrendState trend = initial;
  return <TrendState>[
    for (int t = 1; t <= series.length; t++)
      trend = applyTrendHysteresis(series.sublist(0, t), trend, config),
  ];
}

DirectionHysteresis _directionConfig(Map<String, Object?> input) =>
    DirectionHysteresis(
      up: gvDouble(input['up']),
      down: gvDouble(input['down']),
      confirmBars: gvInt(input['confirm_bars']),
      minHoldBars: gvInt(input['min_hold_bars']),
    );

TrendHysteresis _trendConfig(Map<String, Object?> json) => TrendHysteresis(
  trendIn: gvDouble(json['trend_in']),
  trendOut: gvDouble(json['trend_out']),
  confirmBars: gvInt(json['confirm_bars']),
);

String? _directionCheck(
  Map<String, Object?> input,
  DirectionHysteresis config,
  Map<String, Object?> expected,
) {
  final ({List<String> states, List<int> bars}) r = _runDirection(
    gvNumList(input['direction_series']),
    config,
    DirectionState.fromCode(gvString(input['initial_state'])),
    gvInt(input['initial_bars_in_state']),
  );
  return (GvProbe()
        ..same(r.states, gvStringList(expected['states']), 'states')
        ..same(r.bars, gvIntList(expected['bars_in_state']), 'bars_in_state'))
      .failure;
}

/// GV-4 이력 — 방향(4 · 4b · 4c · 4d · 4e · 4g) · 추세성(4f · 4f-b · 4f-n)(05 §GV-4 · 03 §1-7 · §1-8).
class Gv4Hysteresis implements GoldenFamily {
  /// 만든다.
  const Gv4Hysteresis();

  @override
  String get id => 'GV-4';

  @override
  Set<String> get files => const <String>{
    'gv04_hysteresis.json',
    'gv04b_nan_fail_closed.json',
    'gv04c_downward_immediate.json',
    'gv04d_bull_to_neutral.json',
    'gv04e_bear_to_neutral_wait.json',
    'gv04g_boundary_mid.json',
    'gv04f_trend_deadband.json',
    'gv04fb_trend_strict.json',
    'gv04fn_trend_nan.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    // GV-4 본 벡터의 설정 — GV-4b 는 «GV-4 와 동일»(05 §GV-4b).
    final Map<String, Object?> gv4 = b.json('gv04_hysteresis.json');
    final Map<String, Object?> gv4Input = gvObject(gv4['input']);
    final DirectionHysteresis gv4Config = _directionConfig(gv4Input);
    ({List<String> states, List<int> bars})? gv4Run;
    ({List<String> states, List<int> bars}) gv4Once() =>
        gv4Run ??= _runDirection(
          gvNumList(gv4Input['direction_series']),
          gv4Config,
          DirectionState.fromCode(gvString(gv4Input['initial_state'])),
          gvInt(gv4Input['initial_bars_in_state']),
        );
    return <GvCase>[
      // 옛 시험처럼 states · bars_in_state 두 케이스(이식 전후 같은 케이스 수).
      GvCase(
        'GV-4 방향 25봉 states',
        () =>
            (GvProbe()..same(
                  gv4Once().states,
                  gvStringList(gvObject(gv4['expected'])['states']),
                  'states',
                ))
                .failure,
      ),
      GvCase(
        'GV-4 방향 25봉 bars_in_state',
        () =>
            (GvProbe()..same(
                  gv4Once().bars,
                  gvIntList(gvObject(gv4['expected'])['bars_in_state']),
                  'bars_in_state',
                ))
                .failure,
      ),
      for (final Map<String, Object?> c in gvObjectList(
        b.json('gv04b_nan_fail_closed.json')['cases'],
      ))
        GvCase(
          'GV-4b ${gvString(c['id'])}',
          () => _directionCheck(c, gv4Config, gvObject(c['expected'])),
        ),
      for (final (String id, String file) in <(String, String)>[
        ('4c', 'gv04c_downward_immediate.json'),
        ('4d', 'gv04d_bull_to_neutral.json'),
        ('4e', 'gv04e_bear_to_neutral_wait.json'),
        ('4g', 'gv04g_boundary_mid.json'),
      ])
        GvCase('GV-$id', () {
          final Map<String, Object?> v = b.json(file);
          final Map<String, Object?> input = gvObject(v['input']);
          return _directionCheck(
            input,
            _directionConfig(input),
            gvObject(v['expected']),
          );
        }),
      GvCase('GV-4f 추세성 dead-band', () {
        final Map<String, Object?> v = b.json('gv04f_trend_deadband.json');
        final Map<String, Object?> input = gvObject(v['input']);
        final List<TrendState> r = _runTrend(
          gvNumList(input['trendiness_series']),
          _trendConfig(input),
          TrendState.fromCode(gvString(input['initial_trend'])),
        );
        final Map<String, Object?> expected = gvObject(v['expected']);
        return (GvProbe()
              ..same(
                r.map((TrendState s) => s.code).toList(),
                gvStringList(expected['trend_states']),
                'trend_states',
              )
              ..same(
                r.map(trendFactor).toList(),
                gvNumList(expected['g']),
                'g',
              ))
            .failure;
      }),
      for (final (String id, String file) in <(String, String)>[
        ('4f-b', 'gv04fb_trend_strict.json'),
        ('4f-n', 'gv04fn_trend_nan.json'),
      ])
        for (final Map<String, Object?> c in gvObjectList(
          b.json(file)['cases'],
        ))
          GvCase('GV-$id ${gvString(c['id'])}', () {
            final List<TrendState> r = _runTrend(
              gvNumList(c['trendiness_series']),
              _trendConfig(b.json(file)),
              TrendState.fromCode(gvString(c['initial_trend'])),
            );
            return (GvProbe()..same(
                  r.map((TrendState s) => s.code).toList(),
                  gvStringList(gvObject(c['expected'])['trend_states']),
                  'trend_states',
                ))
                .failure;
          }),
    ];
  }
}

/// 🔴 기기판 G-GV 실행기 — 지금 = GV-1~4 만(E11o-a) · 전 계열 이식 전 = `complete` 거짓(R161 O5).
const GoldenSuite kDeviceGoldenSuite = GoldenSuite(<GoldenFamily>[
  Gv1RegimeScore(),
  Gv2Indicators(),
  Gv3ExposureGate(),
  Gv4Hysteresis(),
], complete: false);
