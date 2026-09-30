// C-10 결측·null 렌더 — 01 §7 표 C-10 · 인벤토리 §9(🟡 화면 · 🟢 뷰모델 층).
//
// 정의: 「`PerfPoint.value == null` 구간이 보간되지 않고 공백인지」.
// 잡는 것: **결측 은폐**.
//
// 🟢 뷰모델 층에서 지금 고정할 수 있는 것: ① 결측이 `null` 로 실려 오고(0 이나 앞값이
//    아니라) ② 그 자리에 **사유 코드**가 함께 오며 ③ 같은 구간이 `PerfSegment` 의
//    `UNAVAILABLE` 로도 표시된다 — 셋이 다 있어야 화면이 「선을 잇지 않을」 근거를 갖는다.
// 🟡 「선을 잇지 않았다」 자체는 렌더 결과다 — 렌더 증명 =
//    `ui_analytics/test/golden/chart_probe.dart`(R10 · 계약 v1.3).
// 🆕 v1.3(01 §13-1 · §13-3) — 그래프는 정규 자리로 그린다. 그래서 결측의 짝도 정규 자리로 고정한다.
//   ⑤ 전 점(본선·벤치마크): `value == null ⇔ yNormalized == null`.
//   ⑥ 결측 점은 `UNAVAILABLE` 또는 `SIM_EXCLUDED` 구간의 `[start, end]` 정규 범위 안에 있다.
//   ⑦ `SIM_EXCLUDED` 구간 안의 점은 전부 null 이고 사유가 `SIM_EXCLUDED` 다 ·
//      `MANUAL_EXECUTED` 구간 안의 점은 전부 값이 있다 ·
//      `UNAVAILABLE` 구간 안의 점(본선)은 전부 null 이다(빗금 띠 위로 선이 지나가지 않는다).
// 🆕 v1.4(01 §14-10 · 설계 Δ4 «C-10 goal path 편입») — 목표 경로(`GoalPathVm`)도 같은 결측 규약을 진다.
//   ⑧ 목표 경로 행: ⑤ 는 계획선·실제선 모두 · ⑥⑦ 은 **실제선만**(계획선은 갭 띠 안에서도 값이 있다 — C-39 ②).
// 🔴 ⑤⑥⑦⑧ 은 **망가뜨린 사본**(메모리 안)으로 실패하는 것을 «자체 검증» 테스트가 고정한다.
//    규칙 본문은 `support/perf_line_rules.dart`(C-36·C-39 와 공용 · 위반 문장 무변경).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';
import 'support/perf_line_rules.dart';
import 'support/perf_series_rows.dart';

void main() {
  group('C-10 결측·null (01 §7)', () {
    test('C-10 월간 성과에 결측이 null 로 실려 있고 0 으로 메워지지 않았다', () {
      final List<PerformanceSeries> series = _series(
        FixturePaths.performance24m,
      );
      expect(series, hasLength(2), reason: 'TWR·MWR 두 계열이다(인벤토리 §8-2).');

      for (final PerformanceSeries s in series) {
        final List<PerfPoint> gaps = s.points
            .where((PerfPoint p) => p.value == null)
            .toList();
        expect(
          gaps,
          hasLength(1),
          reason: '${s.metric} — 결측 구간 1 이 픽스처의 계약이다(인벤토리 §8-2).',
        );
        expect(
          gaps.single.value,
          isNull,
          reason: '🔴 결측을 0 으로 바꾸면 「손실 0%」로 읽힌다 — 은폐다.',
        );
        expect(
          gaps.single.gapReasonCode,
          isNotNull,
          reason: '결측에는 사유 코드가 함께 온다(01 §3 · GapReasonCodes).',
        );
        expect(
          ContractCodes.isRegisteredIn(
            'gap_reason_code',
            gaps.single.gapReasonCode!,
          ),
          isTrue,
        );
      }
    });

    test('C-10 결측 점의 날짜는 UNAVAILABLE 구간 안에 있다', () {
      for (final String path in <String>[
        FixturePaths.performance24m,
        FixturePaths.m7M7PerfDailyGap,
      ]) {
        for (final PerformanceSeries s in _series(path)) {
          final List<PerfSegment> unavailable = s.segments
              .where((PerfSegment seg) => seg.kind == SegmentKind.unavailable)
              .toList();
          expect(
            unavailable,
            isNotEmpty,
            reason:
                '$path — 결측이 있는데 UNAVAILABLE 구간이 없다. 화면은 구간으로 '
                '공백을 그리므로 둘이 짝이 아니면 선이 이어진다.',
          );

          for (final PerfPoint p in s.points.where(
            (PerfPoint p) => p.value == null,
          )) {
            final bool covered = unavailable.any(
              (PerfSegment seg) =>
                  seg.from.yyyyMmDd.compareTo(p.date.yyyyMmDd) <= 0 &&
                  seg.to.yyyyMmDd.compareTo(p.date.yyyyMmDd) >= 0,
            );
            expect(
              covered,
              isTrue,
              reason:
                  '$path — 결측 점 ${p.date.yyyyMmDd} 를 덮는 UNAVAILABLE 구간이 없다.',
            );
          }
        }
      }
    });

    test('C-10 측정 구간에는 결측이 없다(구간 표시와 점이 어긋나지 않는다)', () {
      for (final PerformanceSeries s in _series(
        FixturePaths.m7M7PerfDailyGap,
      )) {
        for (final PerfSegment seg in s.segments.where(
          (PerfSegment seg) => seg.kind == SegmentKind.measured,
        )) {
          final Iterable<PerfPoint> inside = s.points.where(
            (PerfPoint p) =>
                seg.from.yyyyMmDd.compareTo(p.date.yyyyMmDd) <= 0 &&
                seg.to.yyyyMmDd.compareTo(p.date.yyyyMmDd) >= 0,
          );
          expect(
            inside.where((PerfPoint p) => p.value == null),
            isEmpty,
            reason: '측정 구간 안에 결측 점이 있다 — 구간 라벨이 사실과 다르다.',
          );
        }
      }
    });

    test('C-10 결측은 왕복해도 null 로 남는다(기본값으로 채워지지 않는다)', () {
      final PerformanceSeries s = _series(FixturePaths.performance24m).first;
      final PerformanceSeries round = PerformanceSeries.fromJson(s.toJson());
      final List<PerfPoint> before = s.points
          .where((PerfPoint p) => p.value == null)
          .toList();
      final List<PerfPoint> after = round.points
          .where((PerfPoint p) => p.value == null)
          .toList();
      expect(after.length, before.length);
      expect(after.single.gapReasonCode, before.single.gapReasonCode);
    });

    test('C-10 ⑤ 값이 없는 점은 세로 자리도 없다(본선·벤치마크 전 점)', () {
      _expectClean(_valuePairViolations);
    });

    test('C-10 ⑥ 결측 점은 UNAVAILABLE·SIM_EXCLUDED 구간의 정규 범위 안에 있다', () {
      _expectClean(_gapCoverViolations);
      // 입력 확인 — 결측 점이 실제로 있다(없으면 이 검사는 아무것도 보지 않는다).
      final int gaps = allPerfSeriesRows()
          .expand((PerfSeriesRow r) => r.series.points)
          .where((PerfPoint p) => p.yNormalized == null)
          .length;
      expect(gaps, greaterThanOrEqualTo(8), reason: '결측 점 표본이 줄었다.');
    });

    test('C-10 ⑦ 모의·불가 구간의 점은 전부 비고, 수동 집행 구간의 점은 전부 값이 있다', () {
      _expectClean(_segmentKindViolations);
      // 입력 확인 — 세 구간 모두 점을 덮는 표본이 있다.
      for (final SegmentKind kind in <SegmentKind>[
        SegmentKind.simExcluded,
        SegmentKind.manualExecuted,
        SegmentKind.unavailable,
      ]) {
        final int inside = allPerfSeriesRows()
            .map((PerfSeriesRow r) => r.series)
            .expand(
              (PerformanceSeries s) => s.segments
                  .where((PerfSegment seg) => seg.kind == kind)
                  .expand(
                    (PerfSegment seg) =>
                        s.points.where((PerfPoint p) => inBand(seg, p)),
                  ),
            )
            .length;
        expect(inside, greaterThan(0), reason: '${kind.wire} 구간 안의 점 표본이 없다.');
      }
      expect(
        ContractCodes.isRegisteredIn(
          'gap_reason_code',
          GapReasonCodes.simExcluded,
        ),
        isTrue,
      );
    });

    test('C-10 ⑧ 목표 경로의 결측도 같은 규약이다(⑤ 두 선 · ⑥⑦ 실제선)', () {
      final List<GoalPathRow> rows = allGoalPathRows();
      expect(
        <String>{for (final GoalPathRow r in rows) r.path},
        containsAll(knownGoalPathFixtures),
        reason: '목표 경로 픽스처가 검사 입력에서 빠졌다 — 입력 없는 검사는 늘 통과한다.',
      );
      final List<String> bad = <String>[
        for (final GoalPathRow r in rows) ..._goalPathViolations(r.where, r.vm),
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
      // 입력 확인 — 실제선 결측이 갭 띠 안에 실제로 있다(없으면 ⑥⑦ 이 아무것도 보지 않는다).
      final int gaps = rows
          .expand((GoalPathRow r) => r.vm.actual)
          .where((PerfPoint p) => p.yNormalized == null)
          .length;
      expect(gaps, greaterThanOrEqualTo(2), reason: '목표 경로 실제선 결측 표본이 줄었다.');
      // 계획선은 갭 띠 안에서도 값이 있다 — ⑦ 을 계획선에 걸지 않는 까닭의 표본.
      final GoalPathVm real = goalPathRow(FixturePaths.m7M7GoalPathRealworld)
          .vm;
      expect(
        real.planned.where(
          (PerfPoint p) =>
              real.segments.any((PerfSegment seg) => inBand(seg, p)),
        ),
        isNotEmpty,
      );
    });

    test('C-10 자체 검증 — 망가뜨린 사본은 ⑤⑥⑦ 에 걸린다', () {
      final PerfSeriesRow daily = perfSeriesRow(FixturePaths.m7M7PerfDailyGap);
      final PerfSeriesRow monthly = perfSeriesRow(FixturePaths.performance24m);
      final PerfSeriesRow sim = perfSeriesRow(
        FixturePaths.m7M7PerfMonthlySimSplit,
      );
      final PerfSeriesRow manual = perfSeriesRow(
        FixturePaths.m7M7PerfDailyManual,
      );
      final PerfSeriesRow period = perfSeriesRow(
        FixturePaths.m7M7PerfMonthlyPeriod,
      );
      final List<_Mutation> mutations = <_Mutation>[
        _Mutation(
          '⑤ 값은 있는데 세로 자리가 없다',
          ' points[3] ',
          _valuePairViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'points')[3]['y_normalized'] = null;
          },
        ),
        _Mutation(
          '⑤ 결측인데 세로 자리가 있다(0 으로 메움)',
          ' points[13] ',
          _valuePairViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'points')[13]['y_normalized'] = 0.0;
          },
        ),
        _Mutation(
          '⑤ 벤치마크 점',
          'benchmark.points[2]',
          _valuePairViolations,
          monthly,
          (Map<String, Object?> j) {
            jsonObjects(
              j['benchmark']! as Map<String, Object?>,
              'points',
            )[2]['value'] = null;
          },
        ),
        _Mutation(
          '⑥ 결측을 덮던 구간이 측정 구간으로 바뀌었다',
          'points[13]',
          _gapCoverViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'segments')[1]['kind'] = 'MEASURED';
          },
        ),
        _Mutation(
          '⑥ 띠가 결측 점 하나를 덮지 못한다',
          'points[14]',
          _gapCoverViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'segments')[1]['end_normalized'] = 0.66;
          },
        ),
        _Mutation(
          '⑥ 구간 밖에 결측이 하나 더 생겼다',
          'points[2]',
          _gapCoverViolations,
          daily,
          (Map<String, Object?> j) {
            final Map<String, Object?> p = jsonObjects(j, 'points')[2];
            p['value'] = null;
            p['y_normalized'] = null;
          },
        ),
        _Mutation(
          '⑥ 수동 집행 구간은 결측을 덮지 못한다',
          'points[14]',
          _gapCoverViolations,
          daily,
          (Map<String, Object?> j) {
            jsonObjects(j, 'segments')[1]['kind'] = 'MANUAL_EXECUTED';
          },
        ),
        _Mutation(
          '⑦ 모의 구간의 점에 값이 실렸다',
          'points[1] — 모의 구간 안인데 값이 있다',
          _segmentKindViolations,
          sim,
          (Map<String, Object?> j) {
            final Map<String, Object?> p = jsonObjects(j, 'points')[1];
            p['value'] = 0.01;
            p['y_normalized'] = 0.125;
          },
        ),
        _Mutation(
          '⑦ 모의 구간의 점 사유가 다르다',
          'points[0] — 모의 구간 안인데 사유가 RESUME_GAP',
          _segmentKindViolations,
          sim,
          (Map<String, Object?> j) {
            jsonObjects(j, 'points')[0]['gap_reason_code'] =
                GapReasonCodes.resumeGap;
          },
        ),
        _Mutation(
          '⑦ 모의 구간의 점에 사유가 없다',
          'points[2] — 모의 구간 안인데 사유가 null',
          _segmentKindViolations,
          sim,
          (Map<String, Object?> j) {
            jsonObjects(j, 'points')[2].remove('gap_reason_code');
          },
        ),
        _Mutation(
          '⑦ 수동 집행 구간의 점이 비었다',
          'points[6] — 수동 집행 구간 안인데 값이 없다',
          _segmentKindViolations,
          manual,
          (Map<String, Object?> j) {
            final Map<String, Object?> p = jsonObjects(j, 'points')[6];
            p['value'] = null;
            p['y_normalized'] = null;
          },
        ),
        _Mutation(
          '⑦ 불가 구간의 점에 값이 실렸다',
          'points[7] — 불가 구간 안인데 값이 있다',
          _segmentKindViolations,
          period,
          (Map<String, Object?> j) {
            final Map<String, Object?> p = jsonObjects(j, 'points')[7];
            p['value'] = 0.0085;
            p['y_normalized'] = 0.7125;
            p.remove('gap_reason_code');
          },
        ),
      ];
      final Set<String> covered = <String>{};
      for (final _Mutation m in mutations) {
        expect(
          m.rule(m.row.where, m.row.series),
          isEmpty,
          reason: '${m.name} — 고치기 전 원본이 이미 걸린다.',
        );
        expect(
          m.rule(m.row.where, m.row.mutated(m.edit)),
          contains(contains(m.hit)),
          reason: '${m.name} — 망가뜨렸는데 검사가 통과한다(검사가 늘 참이다).',
        );
        covered.add(m.name.split(' ').first);
      }
      expect(covered, <String>{'⑤', '⑥', '⑦'});

      // 🆕 v1.4 ⑧ — 목표 경로 사본.
      final GoalPathRow real = goalPathRow(FixturePaths.m7M7GoalPathRealworld);
      final GoalPathRow on = goalPathRow(FixturePaths.m7M7GoalPathOn);
      final List<_GoalMutation> goal = <_GoalMutation>[
        _GoalMutation('⑧ 계획선 점이 비었다(⑤)', 'planned[2] — value null', on, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'planned')[2]['value'] = null;
        }),
        _GoalMutation(
          '⑧ 갭 띠 안 실제선 점에 값이 실렸다(⑦)',
          'actual[3] — 불가 구간 안인데 값이 있다',
          real,
          (Map<String, Object?> j) {
            final Map<String, Object?> p = jsonObjects(j, 'actual')[3];
            p['value'] = 22000000.0;
            p['y_normalized'] = 0.3333;
            p.remove('gap_reason_code');
          },
        ),
        _GoalMutation('⑧ 실제선 결측을 덮는 띠가 없다(⑥)', 'actual[4] x=', real, (
          Map<String, Object?> j,
        ) {
          jsonObjects(j, 'segments')[0]['end_normalized'] = 0.5;
        }),
      ];
      for (final _GoalMutation g in goal) {
        expect(
          _goalPathViolations(g.row.where, g.row.vm),
          isEmpty,
          reason: '${g.name} — 고치기 전 원본이 이미 걸린다.',
        );
        expect(
          _goalPathViolations(g.row.where, g.row.mutated(g.edit)),
          contains(contains(g.hit)),
          reason: '${g.name} — 망가뜨렸는데 검사가 통과한다(검사가 늘 참이다).',
        );
      }
    });

    test(
      'C-10 화면이 결측 구간을 보간하지 않고 공백으로 그리는지',
      () {},
      skip:
          '렌더 증명 = ui_analytics/test/golden/chart_probe.dart(R10 · 계약 v1.3). '
          '이 패키지는 순수 Dart 라 그림을 그리지 못한다 — 뷰모델 층(위 검사)은 «결측이 null 로, '
          '사유와 함께, 구간의 정규 범위 안에 온다»까지를 고정한다.',
    );
  });
}

/// 검사 1종 — 위반을 문장 목록으로 돌려준다(빈 목록 = 통과).
typedef _Rule = List<String> Function(String where, PerformanceSeries s);

/// 변이 1건(자체 검증용 — 픽스처 파일은 고치지 않는다).
class _Mutation {
  const _Mutation(this.name, this.hit, this.rule, this.row, this.edit);

  final String name;

  /// 걸려야 하는 조항의 글자 — 위반 문장 가운데 하나가 이 글자를 담아야 한다
  /// (엉뚱한 조항에 걸려 통과하는 것을 막는다).
  final String hit;
  final _Rule rule;
  final PerfSeriesRow row;
  final void Function(Map<String, Object?> json) edit;
}

void _expectClean(_Rule rule) {
  final List<PerfSeriesRow> rows = allPerfSeriesRows();
  expect(
    <String>{for (final PerfSeriesRow r in rows) r.path},
    containsAll(knownPerfSeriesFixtures),
    reason: '성과 픽스처가 검사 입력에서 빠졌다.',
  );
  final List<String> bad = <String>[
    for (final PerfSeriesRow r in rows) ...rule(r.where, r.series),
  ];
  expect(bad, isEmpty, reason: bad.join('\n'));
}

/// ⑤ `value == null ⇔ yNormalized == null`(본선·벤치마크 — 규칙 본문은 `support/perf_line_rules.dart`).
List<String> _valuePairViolations(String where, PerformanceSeries s) =>
    valuePairViolations(where, <String, List<PerfPoint>>{
      'points': s.points,
      if (s.benchmark != null) 'benchmark.points': s.benchmark!.points,
    });

/// ⑥ 결측 점을 덮는 띠가 있다(본선 — 띠는 본선의 구간이다).
List<String> _gapCoverViolations(String where, PerformanceSeries s) =>
    gapCoverViolations(where, s.segments, 'points', s.points);

/// ⑦ 구간 종류와 그 안의 점.
List<String> _segmentKindViolations(String where, PerformanceSeries s) =>
    segmentKindViolations(where, s.segments, 'points', s.points);

/// 🆕 v1.4 — 목표 경로 변이 1건(⑧ 자체 검증용 — 픽스처 파일은 고치지 않는다).
class _GoalMutation {
  const _GoalMutation(this.name, this.hit, this.row, this.edit);

  final String name;
  final String hit;
  final GoalPathRow row;
  final void Function(Map<String, Object?> json) edit;
}

/// 🆕 v1.4 ⑧ — 목표 경로 1행에 ⑤⑥⑦ 을 건다.
///
/// 🔴 ⑤ 는 두 선 모두 · ⑥⑦ 은 **실제선(`actual`)에만** — 띠는 실제선의 구간이고, 계획선(`planned`)은
///    갭 띠 안에서도 값이 있다(계획선 결측 없음 · C-39 ②). 계획선에 ⑦ 을 걸면 정상 픽스처가 걸린다.
List<String> _goalPathViolations(String where, GoalPathVm vm) => <String>[
  ...valuePairViolations(where, <String, List<PerfPoint>>{
    'planned': vm.planned,
    'actual': vm.actual,
  }),
  ...gapCoverViolations(where, vm.segments, 'actual', vm.actual),
  ...segmentKindViolations(where, vm.segments, 'actual', vm.actual),
];

List<PerformanceSeries> _series(String path) =>
    decodeEnvelope(readFixture(path)).rows
        .map(PerformanceSeries.fromJson)
        .toList();
