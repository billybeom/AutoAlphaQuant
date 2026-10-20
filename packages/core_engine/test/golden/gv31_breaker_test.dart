// GV-31 드로다운 서킷브레이커(AC-S16 · 안전 게이트) · s_h5_1(v2.29 STOPPED 재개 자격) · GV-18 슬리브별 승수.
//
// 정답지(vectors/SOURCES.md):
//   gv31_breaker_vectors.json      — 파일럿4 원본 통째(단발 23 + 시퀀스 6 · v1.13 재생성 · dd_stop −0.35)
//   gv31_s_h5_1_J1_stopped.json    — 백테스트6 `runs/J1_stopped/J1_stopped.json` 통째(vectorB_deterministic)
//   gv18_exposure_multiplier.json  — 05 §GV-18 블록 원문
// 🔴 s_h5_1 의 입력 시퀀스는 정답 파일에 없다 — 05 §GV-31 계열 s_h5_1 «입력 시퀀스» 문단과
//    `exp/J1_stopped_vector.py` vectorB 블록대로 여기서 만든다(numpy linspace 의 계산 순서까지).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

/// 정답지 `_meta.config` + 04 §2 v2.29 의 재개 자격 2키(파일럿4 벡터는 v2.29 이전에 만들어졌다).
BreakerConfig _config(Map<String, Object?> c) => BreakerConfig(
  alertDd: asDouble(c['alert_dd']),
  reduceDd: asDouble(c['reduce_dd']),
  haltDd: asDouble(c['halt_dd']),
  stopDd: asDouble(c['stopped_dd']),
  alertReleaseDd: asDouble(c['alert_release_dd']),
  reduceReleaseDd: asDouble(c['reduce_release_dd']),
  haltReleaseDd: asDouble(c['halt_release_dd']),
  recoverHoldBars: asInt(c['recover_hold_bars']),
  haltReleaseBullStreak: asInt(c['halt_release_bull_streak']),
  stopReleaseDd: -0.25, // 04 §2 v2.29 `breaker.stop_release_dd`
  stopReleaseBullStreak: 5, // 04 §2 v2.29 `breaker.stop_release_bull_streak`
);

double? _score(Object? v) => v == null ? null : asDouble(v);

/// numpy `linspace(start, stop, num)` — `arange(num) * step + start` 후 마지막 칸을 stop 으로.
List<double> _linspace(double start, double stop, int num) {
  final double step = (stop - start) / (num - 1);
  return <double>[
    for (int i = 0; i < num; i++) i == num - 1 ? stop : i * step + start,
  ];
}

void main() {
  final Map<String, Object?> vectors = loadVector('gv31_breaker_vectors.json');
  final BreakerConfig config = _config(
    asObject(asObject(vectors['_meta'])['config']),
  );

  group('GV-31 단발 — evaluate_breaker 한 번', () {
    for (final Map<String, Object?> c in asObjectList(vectors['step_cases'])) {
      test('${asString(c['id'])} ${c['note'] ?? ''}', () {
        expect(
          evaluateBreaker(
            drawdown: asDouble(c['dd']),
            previous: BreakerLevel.fromCode(asString(c['prev'])),
            barsSinceChange: asInt(c['bars_since_change']),
            directionScore: _score(c['direction_score']),
            bullStreak: asInt(c['bull_streak']),
            config: config,
          ).code,
          asString(c['expected']),
        );
      });
    }
  });

  group('GV-31 시퀀스 — 봉마다 +1 후 판정 · 바뀐 봉에서 0', () {
    asObject(vectors['sequence_cases']).forEach((String id, Object? raw) {
      final Map<String, Object?> q = asObject(raw);
      test(id, () {
        BreakerState state = BreakerState(
          level: BreakerLevel.fromCode(asString(q['initial'])),
          barsSinceChange: asInt(q['initial_bars_since_change']),
        );
        final List<String> levels = <String>[];
        for (final Map<String, Object?> bar in asObjectList(q['bars'])) {
          state = stepBreaker(
            state,
            drawdown: asDouble(bar['dd']),
            directionScore: _score(bar['direction_score']),
            bullStreak: asInt(bar['bull_streak'] ?? 0),
            config: config,
          ).state;
          levels.add(state.level.code);
        }
        expect(levels, asStringList(q['expected_levels']));
      });
    });
  });

  group('GV-31 계열 s_h5_1 — STOPPED 재개 자격(v2.29)', () {
    final Map<String, Object?> vectorB = asObject(
      loadVector('gv31_s_h5_1_J1_stopped.json')['vectorB_deterministic'],
    );

    // 입력 — 130 영업일(d0~d129) · hwm 100 · equity = 100 × (1 + dd)(스크립트 271~277행과 같은 구성).
    final List<double> ddv = <double>[
      ..._linspace(0.0, -0.36, 21),
      ..._linspace(-0.36, -0.24, 20),
      ..._linspace(-0.24, -0.10, 30),
      for (int d = 71; d <= 129; d++) -0.05,
    ];

    /// 시퀀스를 돌린다 — [releaseOnEligible] 이면 자격 봉에 사람이 재개했다고 보고 HALTED 로 내린다
    /// (참조 엔진의 `stopped_release_enabled = true` 근사).
    ({
      List<({int day, String move, double ddPct})> transitions,
      List<({int day, int held, double ddPct, int bull})> eligible,
      BreakerLevel last,
    })
    run({required bool releaseOnEligible}) {
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

    for (final (String branch, bool release) in <(String, bool)>[
      ('off', false),
      ('on', true),
    ]) {
      test('$branch — 전이 날짜·방향·낙폭 · 자격 이벤트 1회 · 최종 레벨', () {
        final Map<String, Object?> want = asObject(vectorB[branch]);
        final ({
          List<({int day, String move, double ddPct})> transitions,
          List<({int day, int held, double ddPct, int bull})> eligible,
          BreakerLevel last,
        })
        got = run(releaseOnEligible: release);

        final List<Map<String, Object?>> wantMoves = asObjectList(
          want['transitions'],
        );
        expect(got.transitions, hasLength(wantMoves.length));
        for (int i = 0; i < wantMoves.length; i++) {
          expect(got.transitions[i].day, asInt(wantMoves[i]['day']));
          expect(got.transitions[i].move, asString(wantMoves[i]['move']));
          expect(
            got.transitions[i].ddPct,
            closeTo(asDouble(wantMoves[i]['dd_pct']), 5e-5),
          );
        }

        final List<Map<String, Object?>> wantEvents = asObjectList(
          want['eligible_events'],
        );
        expect(got.eligible, hasLength(wantEvents.length));
        final RegExp detail = RegExp(r'^held=(\d+) dd=(-?[\d.]+) bull=(\d+)$');
        for (int i = 0; i < wantEvents.length; i++) {
          final RegExpMatch m = detail.firstMatch(
            asString(wantEvents[i]['detail']),
          )!;
          expect(got.eligible[i].day, asInt(wantEvents[i]['day']));
          expect(got.eligible[i].held, int.parse(m.group(1)!));
          expect(got.eligible[i].bull, int.parse(m.group(3)!));
          expect(
            got.eligible[i].ddPct,
            closeTo(asDouble(wantEvents[i]['dd_pct']), 5e-5),
          );
        }

        expect(got.last.code, asString(want['final_level']));
        expect(vectorB['ok'], isTrue);
      });
    }
  });

  group('GV-18 슬리브별 승수', () {
    final Map<String, Object?> v = loadVector('gv18_exposure_multiplier.json');
    final double tolerance = asDouble(v['tolerance']);
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      final String level = asString(c['level']);
      test(level, () {
        final SleeveMultipliers m = exposureMultiplier(
          BreakerLevel.fromCode(level),
        );
        final Map<String, Object?> e = asObject(c['expected']);
        expect(m.sleeveA, closeTo(asDouble(e['sleeve_a']), tolerance));
        expect(m.sleeveB, closeTo(asDouble(e['sleeve_b']), tolerance));
        expect(m.satellite, closeTo(asDouble(e['satellite']), tolerance));
        expect(m.sleeveC, closeTo(asDouble(e['sleeve_c']), tolerance));
      });
    }
  });
}
