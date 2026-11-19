// 골든벡터 GV-31 드로다운 서킷브레이커(AC-S16 · 안전 게이트) · s_h5_1(v2.29 STOPPED 재개 자격) · GV-18 슬리브별 승수
// 판정(E11o-c1 · 설계 13 §8 R164).
//
// 🔴 옛 시험(`test/golden/gv31_breaker_test.dart`)의 판정을 한 글자도 바꾸지 않고 옮겼다(시험 = 폰 같은 판정 · 두 벌 0).
// 정답지: gv31_breaker_vectors.json(파일럿4 원본 · 단발 23 + 시퀀스 6 · v1.13 재생성 · dd_stop −0.35) ·
//   gv31_s_h5_1_J1_stopped.json(백테스트6 `runs/J1_stopped/J1_stopped.json` vectorB_deterministic) ·
//   gv18_exposure_multiplier.json(05 §GV-18 블록 원문).
// 🔴 s_h5_1 의 입력 시퀀스는 정답 파일에 없다 — 05 §GV-31 계열 s_h5_1 «입력 시퀀스» 문단과
//    `exp/J1_stopped_vector.py` vectorB 블록대로 여기서 만든다(numpy linspace 의 계산 순서까지).

import '../risk/breaker.dart'
    show
        BreakerConfig,
        BreakerLevel,
        BreakerState,
        BreakerStep,
        SleeveMultipliers,
        evaluateBreaker,
        exposureMultiplier,
        releaseStoppedToHalted,
        stepBreaker;
import 'golden_runner.dart';

/// 정답지 `_meta.config` + 04 §2 v2.29 의 재개 자격 2키(파일럿4 벡터는 v2.29 이전에 만들어졌다).
BreakerConfig _config(Map<String, Object?> c) => BreakerConfig(
  alertDd: gvDouble(c['alert_dd']),
  reduceDd: gvDouble(c['reduce_dd']),
  haltDd: gvDouble(c['halt_dd']),
  stopDd: gvDouble(c['stopped_dd']),
  alertReleaseDd: gvDouble(c['alert_release_dd']),
  reduceReleaseDd: gvDouble(c['reduce_release_dd']),
  haltReleaseDd: gvDouble(c['halt_release_dd']),
  recoverHoldBars: gvInt(c['recover_hold_bars']),
  haltReleaseBullStreak: gvInt(c['halt_release_bull_streak']),
  stopReleaseDd: -0.25, // 04 §2 v2.29 `breaker.stop_release_dd`
  stopReleaseBullStreak: 5, // 04 §2 v2.29 `breaker.stop_release_bull_streak`
);

double? _score(Object? v) => v == null ? null : gvDouble(v);

/// numpy `linspace(start, stop, num)` — `arange(num) * step + start` 후 마지막 칸을 stop 으로.
List<double> _linspace(double start, double stop, int num) {
  final double step = (stop - start) / (num - 1);
  return <double>[
    for (int i = 0; i < num; i++) i == num - 1 ? stop : i * step + start,
  ];
}

typedef _Run = ({
  List<({int day, String move, double ddPct})> transitions,
  List<({int day, int held, double ddPct, int bull})> eligible,
  BreakerLevel last,
});

/// s_h5_1 시퀀스 — 130 영업일(d0~d129) · hwm 100 · equity = 100 × (1 + dd)(스크립트 271~277행과 같은 구성).
/// [releaseOnEligible] 이면 자격 봉에 사람이 재개했다고 보고 HALTED 로 내린다(참조 엔진 `stopped_release_enabled = true` 근사).
_Run _runSh51(BreakerConfig config, {required bool releaseOnEligible}) {
  final List<double> ddv = <double>[
    ..._linspace(0.0, -0.36, 21),
    ..._linspace(-0.36, -0.24, 20),
    ..._linspace(-0.24, -0.10, 30),
    for (int d = 71; d <= 129; d++) -0.05,
  ];
  BreakerState state = const BreakerState(
    level: BreakerLevel.normal,
    barsSinceChange: 0,
  );
  double hwm = 100.0;
  int streak = 0;
  final List<({int day, String move, double ddPct})> transitions =
      <({int day, String move, double ddPct})>[];
  final List<({int day, int held, double ddPct, int bull})> eligible =
      <({int day, int held, double ddPct, int bull})>[];
  for (int d = 0; d < ddv.length; d++) {
    final double equity = 100.0 * (1 + ddv[d]);
    hwm = equity > hwm ? equity : hwm;
    final double dd = equity / hwm - 1.0;
    streak = d >= 50 ? streak + 1 : 0; // d0~49 BEAR · d50~ BULL
    final BreakerLevel before = state.level;
    final BreakerStep step = stepBreaker(
      state,
      drawdown: dd,
      directionScore: 60.0,
      bullStreak: streak,
      config: config,
    );
    state = step.state;
    if (step.releaseEligible) {
      eligible.add((
        day: d,
        held: step.state.barsSinceChange,
        ddPct: dd * 100,
        bull: streak,
      ));
      if (releaseOnEligible) state = releaseStoppedToHalted(state);
    }
    if (state.level != before) {
      transitions.add((
        day: d,
        move: '${before.code} -> ${state.level.code}',
        ddPct: dd * 100,
      ));
    }
  }
  return (transitions: transitions, eligible: eligible, last: state.level);
}

/// GV-31 단발 23 · 시퀀스 6 · s_h5_1 off · on · GV-18 슬리브별 승수 5.
class Gv31Breaker implements GoldenFamily {
  /// 만든다.
  const Gv31Breaker();

  @override
  String get id => 'GV-31';

  @override
  Set<String> get files => const <String>{
    'gv31_breaker_vectors.json',
    'gv31_s_h5_1_J1_stopped.json',
    'gv18_exposure_multiplier.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> vectors = b.json('gv31_breaker_vectors.json');
    final BreakerConfig config = _config(
      gvObject(gvObject(vectors['_meta'])['config']),
    );
    final Map<String, Object?> g18 = b.json('gv18_exposure_multiplier.json');
    final double tol18 = gvDouble(g18['tolerance']);
    return <GvCase>[
      for (final Map<String, Object?> c in gvObjectList(vectors['step_cases']))
        GvCase(
          'GV-31 단발 ${gvString(c['id'])} ${c['note'] ?? ''}',
          () =>
              (GvProbe()..same(
                    evaluateBreaker(
                      drawdown: gvDouble(c['dd']),
                      previous: BreakerLevel.fromCode(gvString(c['prev'])),
                      barsSinceChange: gvInt(c['bars_since_change']),
                      directionScore: _score(c['direction_score']),
                      bullStreak: gvInt(c['bull_streak']),
                      config: config,
                    ).code,
                    gvString(c['expected']),
                    'level',
                  ))
                  .failure,
        ),
      for (final MapEntry<String, Object?> q in gvObject(
        vectors['sequence_cases'],
      ).entries)
        GvCase('GV-31 시퀀스 ${q.key}', () {
          final Map<String, Object?> s = gvObject(q.value);
          BreakerState state = BreakerState(
            level: BreakerLevel.fromCode(gvString(s['initial'])),
            barsSinceChange: gvInt(s['initial_bars_since_change']),
          );
          final List<String> levels = <String>[];
          for (final Map<String, Object?> bar in gvObjectList(s['bars'])) {
            state = stepBreaker(
              state,
              drawdown: gvDouble(bar['dd']),
              directionScore: _score(bar['direction_score']),
              bullStreak: gvInt(bar['bull_streak'] ?? 0),
              config: config,
            ).state;
            levels.add(state.level.code);
          }
          return (GvProbe()
                ..same(levels, gvStringList(s['expected_levels']), 'levels'))
              .failure;
        }),
      for (final (String branch, bool release) in <(String, bool)>[
        ('off', false),
        ('on', true),
      ])
        GvCase('GV-31 s_h5_1 $branch — 전이 · 자격 이벤트 · 최종 레벨', () {
          final Map<String, Object?> vectorB = gvObject(
            b.json('gv31_s_h5_1_J1_stopped.json')['vectorB_deterministic'],
          );
          final Map<String, Object?> want = gvObject(vectorB[branch]);
          final _Run got = _runSh51(config, releaseOnEligible: release);
          final GvProbe p = GvProbe();

          final List<Map<String, Object?>> wantMoves = gvObjectList(
            want['transitions'],
          );
          p.same(got.transitions.length, wantMoves.length, '전이 수');
          for (int i = 0; i < wantMoves.length; i++) {
            if (i >= got.transitions.length) break;
            p
              ..same(got.transitions[i].day, gvInt(wantMoves[i]['day']), 'day')
              ..same(
                got.transitions[i].move,
                gvString(wantMoves[i]['move']),
                'move',
              )
              ..close(
                got.transitions[i].ddPct,
                gvDouble(wantMoves[i]['dd_pct']),
                5e-5,
                'dd_pct',
              );
          }

          final List<Map<String, Object?>> wantEvents = gvObjectList(
            want['eligible_events'],
          );
          p.same(got.eligible.length, wantEvents.length, '자격 이벤트 수');
          final RegExp detail = RegExp(
            r'^held=(\d+) dd=(-?[\d.]+) bull=(\d+)$',
          );
          for (int i = 0; i < wantEvents.length; i++) {
            if (i >= got.eligible.length) break;
            final RegExpMatch? m = detail.firstMatch(
              gvString(wantEvents[i]['detail']),
            );
            if (m == null) {
              p.truth(false, 'detail 꼴이 아니다');
              continue;
            }
            p
              ..same(got.eligible[i].day, gvInt(wantEvents[i]['day']), 'day')
              ..same(got.eligible[i].held, int.parse(m.group(1)!), 'held')
              ..same(got.eligible[i].bull, int.parse(m.group(3)!), 'bull')
              ..close(
                got.eligible[i].ddPct,
                gvDouble(wantEvents[i]['dd_pct']),
                5e-5,
                'dd_pct',
              );
          }

          return (p
                ..same(got.last.code, gvString(want['final_level']), '최종')
                ..same(vectorB['ok'], true, 'ok'))
              .failure;
        }),
      for (final Map<String, Object?> c in gvObjectList(g18['cases']))
        GvCase('GV-18 ${gvString(c['level'])}', () {
          final SleeveMultipliers m = exposureMultiplier(
            BreakerLevel.fromCode(gvString(c['level'])),
          );
          final Map<String, Object?> e = gvObject(c['expected']);
          return (GvProbe()
                ..close(m.sleeveA, gvDouble(e['sleeve_a']), tol18, 'sleeve_a')
                ..close(m.sleeveB, gvDouble(e['sleeve_b']), tol18, 'sleeve_b')
                ..close(
                  m.satellite,
                  gvDouble(e['satellite']),
                  tol18,
                  'satellite',
                )
                ..close(m.sleeveC, gvDouble(e['sleeve_c']), tol18, 'sleeve_c'))
              .failure;
        }),
    ];
  }
}
