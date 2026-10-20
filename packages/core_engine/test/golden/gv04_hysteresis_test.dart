// GV-4 히스테리시스 — 방향(4 · 4b · 4c · 4d · 4e · 4g) · 추세성(4f · 4f-b · 4f-n)
// (05 §GV-4 계열 · AC-B04 서브케이스 13) · 03 §1-7 · §1-8.
//
// 정답지: 05 v1.22 본문 JSON 블록 9개 원문(vectors/SOURCES.md).
// 🔴 파일럿1 `GV-4_hysteresis.json` 은 쓰지 않는다 — 4b~4g·4f-b·4f-n 이 없다.
// 🔴 함수는 봉 하나를 처리한다 — 시리즈를 한 봉씩 늘려 가며 봉 수만큼 부른다(03 §1-7 호출 규약).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

/// 방향 FSM 을 봉마다 돌려 (상태 코드, 나이) 목록을 돌려준다.
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

/// 추세성 FSM 을 봉마다 돌린다.
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
      up: asDouble(input['up']),
      down: asDouble(input['down']),
      confirmBars: asInt(input['confirm_bars']),
      minHoldBars: asInt(input['min_hold_bars']),
    );

TrendHysteresis _trendConfig(Map<String, Object?> json) => TrendHysteresis(
  trendIn: asDouble(json['trend_in']),
  trendOut: asDouble(json['trend_out']),
  confirmBars: asInt(json['confirm_bars']),
);

List<int> _ints(Object? value) => <int>[
  for (final Object? v in value! as List<Object?>) asInt(v),
];

void main() {
  // GV-4 본 벡터의 설정 — GV-4b 는 «GV-4 와 동일»이라 이 값을 쓴다(05 §GV-4b).
  final Map<String, Object?> gv4 = loadVector('gv04_hysteresis.json');
  final Map<String, Object?> gv4Input = asObject(gv4['input']);
  final DirectionHysteresis gv4Config = _directionConfig(gv4Input);

  group('GV-4 방향 25봉 — 3봉 확인 · 최소 유지 10봉 · 나이는 판정 전에 +1', () {
    final ({List<String> states, List<int> bars}) r = _runDirection(
      asNumList(gv4Input['direction_series']),
      gv4Config,
      DirectionState.fromCode(asString(gv4Input['initial_state'])),
      asInt(gv4Input['initial_bars_in_state']),
    );
    final Map<String, Object?> expected = asObject(gv4['expected']);
    test('states', () {
      expect(r.states, asStringList(expected['states']));
    });
    test('bars_in_state', () {
      expect(r.bars, _ints(expected['bars_in_state']));
    });
  });

  group('GV-4b 확인 구간의 결측은 전환하지 않는다(fail-closed)', () {
    final Map<String, Object?> v = loadVector('gv04b_nan_fail_closed.json');
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      test('GV-4b ${asString(c['id'])}', () {
        final ({List<String> states, List<int> bars}) r = _runDirection(
          asNumList(c['direction_series']),
          gv4Config,
          DirectionState.fromCode(asString(c['initial_state'])),
          asInt(c['initial_bars_in_state']),
        );
        final Map<String, Object?> expected = asObject(c['expected']);
        expect(r.states, asStringList(expected['states']));
        expect(r.bars, _ints(expected['bars_in_state']));
      });
    }
  });

  for (final (String id, String file, String why) in <(String, String, String)>[
    ('4c', 'gv04c_downward_immediate.json', '최소 유지 중에도 하방 전이는 즉시'),
    ('4d', 'gv04d_bull_to_neutral.json', 'BULL→NEUTRAL 은 즉시'),
    ('4e', 'gv04e_bear_to_neutral_wait.json', 'BEAR→NEUTRAL 은 10봉 대기'),
    ('4g', 'gv04g_boundary_mid.json', '경계값 40.0·60.0 은 mid 가 받는다'),
  ]) {
    test('GV-$id $why', () {
      final Map<String, Object?> v = loadVector(file);
      final Map<String, Object?> input = asObject(v['input']);
      final ({List<String> states, List<int> bars}) r = _runDirection(
        asNumList(input['direction_series']),
        _directionConfig(input),
        DirectionState.fromCode(asString(input['initial_state'])),
        asInt(input['initial_bars_in_state']),
      );
      final Map<String, Object?> expected = asObject(v['expected']);
      expect(r.states, asStringList(expected['states']));
      expect(r.bars, _ints(expected['bars_in_state']));
    });
  }

  test('GV-4f 추세성 dead-band(35~45) · 3봉 확인 · 초기 LOW', () {
    final Map<String, Object?> v = loadVector('gv04f_trend_deadband.json');
    final Map<String, Object?> input = asObject(v['input']);
    final List<TrendState> r = _runTrend(
      asNumList(input['trendiness_series']),
      _trendConfig(input),
      TrendState.fromCode(asString(input['initial_trend'])),
    );
    final Map<String, Object?> expected = asObject(v['expected']);
    expect(
      r.map((TrendState s) => s.code).toList(),
      asStringList(expected['trend_states']),
    );
    expect(r.map(trendFactor).toList(), asNumList(expected['g']));
  });

  for (final (String id, String file) in <(String, String)>[
    ('4f-b', 'gv04fb_trend_strict.json'),
    ('4f-n', 'gv04fn_trend_nan.json'),
  ]) {
    group('GV-$id', () {
      final Map<String, Object?> v = loadVector(file);
      final TrendHysteresis config = _trendConfig(v);
      for (final Map<String, Object?> c in asObjectList(v['cases'])) {
        test(asString(c['id']), () {
          final List<TrendState> r = _runTrend(
            asNumList(c['trendiness_series']),
            config,
            TrendState.fromCode(asString(c['initial_trend'])),
          );
          expect(
            r.map((TrendState s) => s.code).toList(),
            asStringList(asObject(c['expected'])['trend_states']),
          );
        });
      }
    });
  }
}
