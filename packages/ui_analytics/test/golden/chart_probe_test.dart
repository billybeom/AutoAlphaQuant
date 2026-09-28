// chart_probe_test.dart — 차트 하네스(chart_probe.dart)의 자체 검증 (ui_analytics · M2 소유 · 계약 v1.3)
//
// 하네스가 «무엇을 통과시키고 무엇을 잡는가»를 코드로 고정한다. 이것이 깨지면 S7-2 수용 (a) 의
// 뜻이 바뀐 것이다 — chart_probe.dart 를 고치기 전에 이 파일을 먼저 읽는다.
//
//   통과: 본보기 painter(reference/) — 성과 픽스처 정상 6건 × light·dark · 크기 3가지 ·
//         실제로 띄운 PerfChart · 같은 Path 를 고쳐 가며 다시 쓰는 painter
//   자리: 실제로 띄운 PerfChart 의 눈금 글자는 전부 그림 왼쪽 바깥 열에 있다(선·띠를 덮지 않는다)
//   잡음: ① 결측을 이어 그림 ② 띠를 빼먹음 ③ 세로를 뒤집음 ④ 벤치마크를 빼먹음
//         ⑤ 본선의 가로 자리를 0.9배로 그림
//         + 빗금만/경계만 빼먹음 · 경계의 점선·실선 뒤바뀜 · 눈금선 빼먹음·어긋남 ·
//           곡선 · 벤치마크를 실선으로 · 벤치마크가 없는데 그림 · 본선을 맨 아래 층에 ·
//           saveLayer · 점 1개짜리 범위를 빼먹음 · 벤치마크 결측을 이어 그림
//
// 🔴 화면 담당은 이 파일을 고치지 않는다.
// 🔴 한국어 문자열 리터럴을 두지 않는다.
// 🔵 미리보기 PNG: 환경 변수 AAQ_CHART_PREVIEW_DIR 에 폴더를 주고 이 파일만 돌리면 그 폴더에
//    본보기 차트를 찍어 둔다(눈 확인용 · 저장소 goldens 와 무관 · 변수가 없으면 아무것도 안 한다).

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_probe.dart';
import 'golden_support.dart';
import 'reference/chart/perf_chart_geometry.dart';
import 'reference/chart/perf_chart_painter.dart';
import 'reference/widgets/perf_chart.dart';

/// painter 를 바로 기록할 때의 그림 크기 — 폰 폭 390 · 상자 220 에서 위아래 12 를 뺀 높이.
/// (비교는 비율이라 크기에 기대지 않는다 — «other sizes» 테스트가 고정한다.)
const Size _plotSize = Size(390, 196);

/// 실제로 띄운 `PerfChart` 의 그림 크기 — 폰 폭 390 에서 눈금 글자 열 56 과 빈칸 8 을 뺀 폭.
const Size _widgetPlotSize = Size(390 - 56 - 8, 196);

/// 눈금 글자 열의 폭과 그림 사이 빈칸(본보기 `PerfChart` 의 짜임).
const double _tickColumnWidth = 56;
const double _tickColumnGap = 8;

enum _Fault {
  none,
  joinGaps,
  skipBands,
  skipHatch,
  skipEdges,
  swapEdgeStyle,
  flipVertical,
  skipBenchmark,
  squeezeHorizontal,
  skipTicks,
  shiftTicks,
  curved,
  solidBenchmark,
  benchmarkFromMain,
  mainLineFirst,
  useSaveLayer,
  skipDots,
  joinBenchmarkGaps,
  reusePath,
}

typedef _Check = void Function(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
);

const Map<String, _Check> _checks = <String, _Check>{
  'main': expectMainLineMatches,
  'benchmark': expectBenchmarkMatches,
  'bands': expectBandsMatch,
  'ticks': expectTicksMatch,
};

ColorScheme _scheme(Brightness b) =>
    ThemeData(useMaterial3: true, brightness: b).colorScheme;

ChartRecording _reference(
  PerformanceSeries s,
  ColorScheme scheme, {
  Size size = _plotSize,
}) => recordPainter(
  PerfChartPainter(series: s, colors: PerfChartColors.fromScheme(scheme)),
  size,
);

ChartRecording _faulty(
  PerformanceSeries s,
  ColorScheme scheme,
  _Fault fault, {
  Size size = _plotSize,
}) => recordPainter(_FaultyPainter(s, scheme, fault), size);

/// [failing] 에 든 단언은 실패하고(메시지가 그 무늬와 맞는다), 나머지는 통과한다.
void _expectOnlyTheseFail(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
  Map<String, String> failing,
) {
  expect(_checks.keys, containsAll(failing.keys));
  for (final MapEntry<String, _Check> e in _checks.entries) {
    final String? why = failing[e.key];
    if (why == null) {
      e.value(r, s, scheme);
      continue;
    }
    expect(
      () => e.value(r, s, scheme),
      _failsWith(why),
      reason: '${e.key} check must fail',
    );
  }
}

/// `TestFailure` 로 실패하고 그 메시지가 [pattern](정규식)과 맞는다.
Matcher _failsWith(String pattern) => throwsA(
  isA<TestFailure>().having(
    (TestFailure f) => f.message,
    'message',
    matches(RegExp(pattern)),
  ),
);

void _expectAllFail(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
  String why,
) {
  _expectOnlyTheseFail(r, s, scheme, <String, String>{
    for (final String name in _checks.keys) name: why,
  });
}

void _expectAllPass(ChartRecording r, PerformanceSeries s, ColorScheme scheme) {
  _expectOnlyTheseFail(r, s, scheme, const <String, String>{});
}

bool _hasGap(PerformanceSeries s) =>
    s.points.any((PerfPoint p) => p.yNormalized == null) &&
    splitRuns(s.points).length > 1;

bool _hasBand(PerformanceSeries s) =>
    s.segments.any((PerfSegment seg) => seg.kind != SegmentKind.measured);

/// 🔴 합성 입력 — 이 파일(하네스 자체 검증)에 한해 허용. 값을 짓지 않고 있는 점을 결측으로만 바꾼다.
PerformanceSeries _withBenchmarkHole(PerformanceSeries s) {
  final BenchmarkSeries b = s.benchmark!;
  return s.copyWith(
    benchmark: b.copyWith(
      points: <PerfPoint>[
        for (int i = 0; i < b.points.length; i++)
          if (i == 10 || i == 11)
            b.points[i].copyWith(yNormalized: null, value: null)
          else
            b.points[i],
      ],
    ),
  );
}

/// 🔴 합성 입력 — 점 [index] 를 결측으로 바꾼다(띠는 그대로 둔다 — 본선 검사에만 쓴다).
PerformanceSeries _withHoleAt(PerformanceSeries s, int index) => s.copyWith(
  points: <PerfPoint>[
    for (int i = 0; i < s.points.length; i++)
      if (i == index)
        s.points[i].copyWith(yNormalized: null, value: null)
      else
        s.points[i],
  ],
);

/// 🔴 합성 입력 — 점 60개(계약의 상한)짜리 시리즈. 자리만 짓고 글자는 [template] 의 것을 쓴다.
/// 두 선 모두 평평하다(틈을 이어도 선에서 벗어나지 않는다 — 틈 검사만이 잡는다).
/// 본선은 점 20 이, 벤치마크는 점 40 이 결측이다. 구간·눈금은 [template] 그대로다.
PerformanceSeries _dense(PerformanceSeries template) {
  final PerfPoint seed = template.points.first;
  List<PerfPoint> line(int hole, int lift) => <PerfPoint>[
    for (int i = 0; i < 60; i++)
      seed.copyWith(
        xNormalized: i / 59,
        yNormalized: i == hole ? null : (20 + lift) / 100,
        value: null,
        gapReasonCode: null,
      ),
  ];
  return template.copyWith(
    segments: <PerfSegment>[
      for (final PerfSegment seg in template.segments)
        if (seg.kind == SegmentKind.measured) seg,
    ],
    points: line(20, 0),
    benchmark: template.benchmark!.copyWith(points: line(40, 10)),
  );
}

void main() {
  final List<PerformanceSeries> monthly = listFixture(
    FixturePaths.performance24m,
    PerformanceSeries.fromJson,
  ).rows;
  final Map<String, PerformanceSeries> fixtures = <String, PerformanceSeries>{
    'performance_24m[0]': monthly[0],
    'performance_24m[1]': monthly[1],
    'm7_perf_daily_gap': singleFixture(
      FixturePaths.m7M7PerfDailyGap,
      PerformanceSeries.fromJson,
    ),
    'm7_perf_monthly_sim_split': singleFixture(
      FixturePaths.m7M7PerfMonthlySimSplit,
      PerformanceSeries.fromJson,
    ),
    'm7_perf_daily_manual': singleFixture(
      FixturePaths.m7M7PerfDailyManual,
      PerformanceSeries.fromJson,
    ),
    'm7_perf_monthly_period': singleFixture(
      FixturePaths.m7M7PerfMonthlyPeriod,
      PerformanceSeries.fromJson,
    ),
    'm7_perf_yearly': singleFixture(
      FixturePaths.m7M7PerfYearly,
      PerformanceSeries.fromJson,
    ),
  };
  final PerformanceSeries dailyGap = fixtures['m7_perf_daily_gap']!;
  final PerformanceSeries simSplit = fixtures['m7_perf_monthly_sim_split']!;
  final PerformanceSeries manual = fixtures['m7_perf_daily_manual']!;
  final ColorScheme light = _scheme(Brightness.light);

  test('fixtures cover every layer of the table', () {
    // 픽스처가 바뀌어 어떤 층의 표본이 사라지면 아래 검증이 조용히 비게 된다 — 먼저 막는다.
    expect(monthly, hasLength(2));
    expect(fixtures.values.where(_hasGap), hasLength(4));
    expect(fixtures.values.where(_hasBand), hasLength(6));
    expect(
      fixtures.values.where((PerformanceSeries s) => s.benchmark != null),
      hasLength(3),
    );
    for (final SegmentKind kind in SegmentKind.values) {
      expect(
        fixtures.values.any(
          (PerformanceSeries s) =>
              s.segments.any((PerfSegment seg) => seg.kind == kind),
        ),
        isTrue,
        reason: 'no fixture has a ${kind.wire} segment',
      );
    }
    for (final PerformanceSeries s in fixtures.values) {
      expect(s.unavailableLabel, isNull);
      expect(s.points, isNotEmpty);
      expect(s.yTicks, isNotEmpty);
    }
  });

  group('reference painter passes', () {
    for (final MapEntry<String, PerformanceSeries> e in fixtures.entries) {
      test('${e.key} light and dark', () {
        for (final Brightness b in Brightness.values) {
          final ColorScheme scheme = _scheme(b);
          _expectAllPass(_reference(e.value, scheme), e.value, scheme);
        }
      });
    }

    test('other sizes (ratio comparison does not depend on size)', () {
      for (final Size size in const <Size>[
        Size(320, 150),
        Size(800, 300),
        Size(1200, 196),
      ]) {
        for (final PerformanceSeries s in fixtures.values) {
          _expectAllPass(_reference(s, light, size: size), s, light);
        }
      }
    });

    test('expected runs match the M2 table', () {
      // build_B1 «M2 기대 표» — 본선 런.
      List<IndexRun> runs(String name) => splitRuns(fixtures[name]!.points);
      expect(runs('performance_24m[0]'), <IndexRun>[
        (start: 0, end: 5),
        (start: 7, end: 23),
      ]);
      expect(runs('performance_24m[1]'), <IndexRun>[
        (start: 0, end: 5),
        (start: 7, end: 23),
      ]);
      expect(runs('m7_perf_daily_gap'), <IndexRun>[
        (start: 0, end: 12),
        (start: 15, end: 20),
      ]);
      expect(runs('m7_perf_monthly_sim_split'), <IndexRun>[
        (start: 3, end: 17),
      ]);
      expect(runs('m7_perf_daily_manual'), <IndexRun>[(start: 0, end: 20)]);
      expect(runs('m7_perf_monthly_period'), <IndexRun>[
        (start: 0, end: 5),
        (start: 8, end: 23),
      ]);
      expect(runs('m7_perf_yearly'), <IndexRun>[(start: 0, end: 2)]);
    });

    test('recording holds what the table says', () {
      final ChartRecording r = _reference(monthly[0], light);
      int count(Color c) =>
          r.contours.where((ProbeContour k) => k.color == c.toARGB32()).length;
      expect(r.size, _plotSize);
      expect(r.violations, isEmpty);
      expect(count(light.primary), 2);
      expect(count(light.tertiary), greaterThan(10));
      expect(r.rects, hasLength(1));
      expect(r.circles, isEmpty);
      expect(
        r.lines.where((ProbeLine l) => l.clip != null).length,
        greaterThanOrEqualTo(2),
      );
    });

    test('single-point run is drawn as a circle (synthetic hole)', () {
      // daily_gap 의 점 11 을 결측으로 → 범위 (0,10) · 점 12 혼자 · (15,20)
      final PerformanceSeries s = _withHoleAt(dailyGap, 11);
      final ChartRecording r = _reference(s, light);
      expectMainLineMatches(r, s, light);
      expect(
        r.circles.where((ProbeCircle c) => c.color == light.primary.toARGB32()),
        hasLength(1),
      );
    });

    test('benchmark breaks at its own null points (synthetic hole)', () {
      final PerformanceSeries s = _withBenchmarkHole(monthly[0]);
      final ChartRecording r = _reference(s, light);
      expectBenchmarkMatches(r, s, light);
      expectMainLineMatches(r, s, light);
    });

    test('a painter that reuses one Path object still reads correctly', () {
      for (final PerformanceSeries s in fixtures.values) {
        _expectAllPass(_faulty(s, light, _Fault.reusePath), s, light);
      }
    });
  });

  group('faulty painter baseline', () {
    test('no fault: passes every check on every fixture', () {
      // 아래 «잡음» 검증이 뜻을 가지려면, 결함을 넣지 않은 같은 painter 가 통과해야 한다.
      for (final Brightness b in Brightness.values) {
        final ColorScheme scheme = _scheme(b);
        for (final PerformanceSeries s in fixtures.values) {
          _expectAllPass(_faulty(s, scheme, _Fault.none), s, scheme);
        }
      }
    });
  });

  group('faulty painters are caught', () {
    test('1. joins across null points', () {
      int seen = 0;
      for (final PerformanceSeries s in fixtures.values.where(_hasGap)) {
        if (s.points.first.yNormalized == null) {
          continue; // 앞머리 결측뿐인 시리즈는 이을 틈이 없다.
        }
        seen++;
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.joinGaps),
          s,
          light,
          const <String, String>{'main': 'A gap must break the line'},
        );
      }
      expect(seen, 4);
    });

    test('2. leaves out bands', () {
      int seen = 0;
      for (final PerformanceSeries s in fixtures.values.where(_hasBand)) {
        seen++;
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.skipBands),
          s,
          light,
          const <String, String>{
            'bands': 'band fills: expected|no vertical line drawn',
          },
        );
      }
      expect(seen, 6);
    });

    test('2b. leaves out hatch only', () {
      _expectOnlyTheseFail(
        _faulty(dailyGap, light, _Fault.skipHatch),
        dailyGap,
        light,
        const <String, String>{'bands': 'clipped diagonal lines'},
      );
    });

    test('2c. leaves out band edges only', () {
      for (final PerformanceSeries s in <PerformanceSeries>[simSplit, manual]) {
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.skipEdges),
          s,
          light,
          const <String, String>{'bands': 'no vertical line drawn'},
        );
      }
    });

    test('2d. swaps dashed and solid band edges', () {
      for (final PerformanceSeries s in <PerformanceSeries>[simSplit, manual]) {
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.swapEdgeStyle),
          s,
          light,
          const <String, String>{
            'bands': 'expected a dashed line|expected a solid line',
          },
        );
      }
    });

    test('3. flips vertically', () {
      for (final PerformanceSeries s in fixtures.values) {
        final ChartRecording r = _faulty(s, light, _Fault.flipVertical);
        expect(
          () => expectMainLineMatches(r, s, light),
          _failsWith('away from the straight lines|vertical flip'),
        );
        // 눈금이 위아래 대칭이면(기준선이 한가운데) 뒤집어도 같은 그림이다 — 그때는 보지 않는다.
        final bool symmetric = s.yTicks.every(
          (PerfAxisTick t) => s.yTicks.any(
            (PerfAxisTick o) =>
                (o.normalized - (1 - t.normalized)).abs() < 1e-9 &&
                o.isBaseline == t.isBaseline,
          ),
        );
        if (!symmetric) {
          expect(
            () => expectTicksMatch(r, s, light),
            throwsA(isA<TestFailure>()),
          );
        }
        if (s.benchmark != null) {
          expect(
            () => expectBenchmarkMatches(r, s, light),
            throwsA(isA<TestFailure>()),
          );
        }
      }
    });

    test('4. leaves out the benchmark', () {
      int seen = 0;
      for (final PerformanceSeries s in fixtures.values) {
        if (s.benchmark == null) {
          continue;
        }
        seen++;
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.skipBenchmark),
          s,
          light,
          const <String, String>{'benchmark': 'no strokes were drawn'},
        );
      }
      expect(seen, 3);
    });

    test('5. draws the main line at 0.9 times the x position', () {
      for (final PerformanceSeries s in fixtures.values) {
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.squeezeHorizontal),
          s,
          light,
          const <String, String>{'main': 'left end|right end'},
        );
      }
    });

    test('6. leaves out tick lines', () {
      for (final PerformanceSeries s in fixtures.values) {
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.skipTicks),
          s,
          light,
          const <String, String>{'ticks': 'tick lines: expected'},
        );
      }
    });

    test('6b. tick lines at the wrong height', () {
      for (final PerformanceSeries s in fixtures.values) {
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.shiftTicks),
          s,
          light,
          const <String, String>{'ticks': 'tick line #'},
        );
      }
    });

    test('7. curves instead of straight lines', () {
      for (final PerformanceSeries s in fixtures.values) {
        _expectOnlyTheseFail(
          _faulty(s, light, _Fault.curved),
          s,
          light,
          const <String, String>{
            'main': 'curves are not allowed|away from the straight lines',
          },
        );
      }
    });

    test('8. benchmark as a solid line', () {
      _expectOnlyTheseFail(
        _faulty(monthly[0], light, _Fault.solidBenchmark),
        monthly[0],
        light,
        const <String, String>{'benchmark': 'not a solid line'},
      );
    });

    test('8b. benchmark drawn although the series has none', () {
      _expectOnlyTheseFail(
        _faulty(dailyGap, light, _Fault.benchmarkFromMain),
        dailyGap,
        light,
        const <String, String>{'benchmark': 'benchmark is null'},
      );
    });

    test('8c. benchmark joined across its own null points', () {
      final PerformanceSeries s = _withBenchmarkHole(monthly[0]);
      _expectOnlyTheseFail(
        _faulty(s, light, _Fault.joinBenchmarkGaps),
        s,
        light,
        const <String, String>{'benchmark': 'Gaps must stay empty'},
      );
    });

    test('8d. benchmark joined across a narrow gap (60 points)', () {
      // 점이 60개면 결측 1점의 틈은 폭의 0.034 다 — 허용 오차(0.02)의 두 배보다 좁다.
      final PerformanceSeries s = _dense(monthly[0]);
      const Size wide = Size(1200, 196);
      _expectAllPass(_reference(s, light), s, light);
      _expectAllPass(_reference(s, light, size: wide), s, light);
      // 폰 폭: 틈 안의 점선 조각이 범위 끝에서 허용 오차보다 멀리 나간다.
      _expectOnlyTheseFail(
        _faulty(s, light, _Fault.joinBenchmarkGaps),
        s,
        light,
        const <String, String>{'benchmark': 'away from the straight lines'},
      );
      // 넓은 폭: 조각이 짧아 위 검사를 빠져나간다 — 틈 검사가 잡는다.
      _expectOnlyTheseFail(
        _faulty(s, light, _Fault.joinBenchmarkGaps, size: wide),
        s,
        light,
        const <String, String>{'benchmark': 'A gap must break the line'},
      );
      _expectOnlyTheseFail(
        _faulty(s, light, _Fault.joinGaps),
        s,
        light,
        const <String, String>{'main': 'A gap must break the line'},
      );
    });

    test('9. main line below the other layers', () {
      _expectAllFail(
        _faulty(monthly[0], light, _Fault.mainLineFirst),
        monthly[0],
        light,
        'layer order',
      );
    });

    test('10. saveLayer', () {
      _expectAllFail(
        _faulty(monthly[0], light, _Fault.useSaveLayer),
        monthly[0],
        light,
        'calls the layer table forbids',
      );
    });

    test('11. leaves out a single-point run', () {
      final PerformanceSeries s = _withHoleAt(dailyGap, 11);
      final ChartRecording r = _faulty(s, light, _Fault.skipDots);
      expect(
        () => expectMainLineMatches(r, s, light),
        _failsWith('single-point run'),
      );
    });

    test('12. colors from the wrong theme', () {
      final ChartRecording r = _reference(monthly[0], _scheme(Brightness.dark));
      _expectAllFail(r, monthly[0], light, 'outside the fixed layer table');
    });

    test('13. a series other than the one drawn', () {
      final ChartRecording r = _reference(dailyGap, light);
      expect(
        () => expectMainLineMatches(r, monthly[0], light),
        throwsA(isA<TestFailure>()),
      );
      expect(
        () => expectBandsMatch(r, simSplit, light),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  group('PerfChart widget', () {
    for (final MapEntry<String, PerformanceSeries> e in fixtures.entries) {
      testWidgets('${e.key}: recordChart finds the chart and checks pass', (
        WidgetTester tester,
      ) async {
        final PerformanceSeries s = e.value;
        await pumpForGolden(
          tester,
          PerfChart(series: s),
          brightness: Brightness.light,
        );
        final ColorScheme scheme = chartSchemeOf(tester);
        final ChartRecording r = recordChart(tester);
        expect(r.size, _widgetPlotSize);
        expect(tester.getSize(find.byKey(kChartProbeKey)), _widgetPlotSize);
        expect(tester.getSize(find.byType(PerfChart)), const Size(390, 220));
        _expectAllPass(r, s, scheme);

        // 눈금 글자 — 픽스처 글자 그대로 · 눈금이 높을수록 위에 있다.
        double? below;
        for (int i = 0; i < s.yTicks.length; i++) {
          final Finder label = find.byKey(ValueKey<String>('s72-tick-$i'));
          expect(label, findsOneWidget);
          expect(tester.widget<Text>(label).data, s.yTicks[i].label);
          final double top = tester.getTopLeft(label).dy;
          if (below != null) {
            expect(top, lessThan(below));
          }
          below = top;
        }
      });
    }

    testWidgets('tick labels sit in the column left of the plot', (
      WidgetTester tester,
    ) async {
      // 눈금 글자가 그림(선·띠)을 덮지 않는다 — 글자 전부가 그림의 왼쪽 변보다 왼쪽에 있다.
      int seen = 0;
      for (final PerformanceSeries s in fixtures.values) {
        await pumpForGolden(
          tester,
          PerfChart(series: s),
          brightness: Brightness.light,
        );
        final Rect box = tester.getRect(find.byType(PerfChart));
        final Rect plot = tester.getRect(find.byKey(kChartProbeKey));
        // 그림 = 상자에서 위아래 12 · 왼쪽으로 글자 열과 빈칸을 뺀 자리.
        expect(plot.left, box.left + _tickColumnWidth + _tickColumnGap);
        expect(plot.right, box.right);
        expect(plot.top, box.top + 12);
        expect(plot.bottom, box.bottom - 12);
        for (int i = 0; i < s.yTicks.length; i++) {
          final Rect label = tester.getRect(
            find.byKey(ValueKey<String>('s72-tick-$i')),
          );
          seen++;
          expect(
            label.right,
            lessThanOrEqualTo(plot.left),
            reason: 'tick label #$i overlaps the plot',
          );
          expect(
            label.right,
            box.left + _tickColumnWidth,
            reason: 'tick label #$i is not flush with the column right edge',
          );
          expect(label.left, greaterThanOrEqualTo(box.left));
          expect(label.width, greaterThan(0));
          // 세로 — 글자는 그림 높이 안에 있고, 그 눈금선의 높이가 글자의 위아래 사이에 든다.
          expect(label.top, greaterThanOrEqualTo(plot.top));
          expect(label.bottom, lessThanOrEqualTo(plot.bottom));
          final double line =
              plot.top + plot.height * (1 - s.yTicks[i].normalized);
          expect(label.top, lessThanOrEqualTo(line + 0.001));
          expect(label.bottom, greaterThanOrEqualTo(line - 0.001));
        }
      }
      expect(seen, greaterThanOrEqualTo(7 * 3));
    });

    testWidgets('dark theme', (WidgetTester tester) async {
      await pumpForGolden(
        tester,
        PerfChart(series: monthly[0]),
        brightness: Brightness.dark,
      );
      final ColorScheme scheme = chartSchemeOf(tester);
      expect(scheme.brightness, Brightness.dark);
      _expectAllPass(recordChart(tester), monthly[0], scheme);
    });

    testWidgets('recordChart fails when the chart is not on screen', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        const SizedBox.shrink(),
        brightness: Brightness.light,
      );
      expect(() => recordChart(tester), throwsA(isA<TestFailure>()));
    });

    testWidgets('recordChart fails when the key is not a CustomPaint', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        const SizedBox(key: kChartProbeKey, height: 10),
        brightness: Brightness.light,
      );
      expect(() => recordChart(tester), throwsA(isA<TestFailure>()));
    });
  });

  final String? previewDir = Platform.environment['AAQ_CHART_PREVIEW_DIR'];
  if (previewDir != null && previewDir.isNotEmpty) {
    group('preview png', () {
      for (final MapEntry<String, PerformanceSeries> e in fixtures.entries) {
        for (final Brightness b in Brightness.values) {
          testWidgets('${e.key} ${brightnessSuffix(b)}', (
            WidgetTester tester,
          ) async {
            await pumpForGolden(
              tester,
              Padding(
                padding: const EdgeInsets.all(16),
                child: PerfChart(series: e.value),
              ),
              brightness: b,
              logicalSize: const Size(390, 252),
            );
            final RenderRepaintBoundary boundary = tester
                .renderObject<RenderRepaintBoundary>(
                  find.byKey(goldenBoundaryKey),
                );
            await tester.runAsync(() async {
              final ui.Image image = await boundary.toImage(pixelRatio: 2);
              final ByteData? png = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              final String name = e.key
                  .replaceAll('[', '_')
                  .replaceAll(']', '');
              Directory(previewDir).createSync(recursive: true);
              File('$previewDir/${name}_${brightnessSuffix(b)}.png')
                  .writeAsBytesSync(png!.buffer.asUint8List());
            });
          });
        }
      }
    });
  }
}

/// 본보기와 같은 층 표로 그리되, [fault] 하나만 일부러 틀리게 그리는 painter.
class _FaultyPainter extends CustomPainter {
  const _FaultyPainter(this.series, this.scheme, this.fault);

  final PerformanceSeries series;
  final ColorScheme scheme;
  final _Fault fault;

  double _x(double n, Size size) => n * size.width;

  double _y(double n, Size size) => fault == _Fault.flipVertical
      ? n * size.height
      : size.height - n * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    if (fault == _Fault.useSaveLayer) {
      canvas.saveLayer(Offset.zero & size, Paint());
    }
    if (fault == _Fault.mainLineFirst) {
      _mainLine(canvas, size);
    }
    _bands(canvas, size);
    _edges(canvas, size);
    _ticks(canvas, size);
    _benchmark(canvas, size);
    if (fault != _Fault.mainLineFirst) {
      _mainLine(canvas, size);
    }
    if (fault == _Fault.useSaveLayer) {
      canvas.restore();
    }
  }

  void _bands(Canvas canvas, Size size) {
    if (fault == _Fault.skipBands) {
      return;
    }
    final Paint fill = Paint()
      ..style = PaintingStyle.fill
      ..color = scheme.surfaceContainerHighest;
    final Paint hatch = Paint()
      ..style = PaintingStyle.stroke
      ..color = scheme.outline
      ..strokeWidth = 1.5;
    for (final PerfSegment seg in series.segments) {
      final Rect band = Rect.fromLTRB(
        _x(seg.startNormalized, size),
        0,
        _x(seg.endNormalized, size),
        size.height,
      );
      final bool filled = switch (seg.kind) {
        SegmentKind.measured => false,
        SegmentKind.unavailable => true,
        SegmentKind.simExcluded => true,
        SegmentKind.manualExecuted => false,
      };
      if (!filled) {
        continue;
      }
      canvas.drawRect(band, fill);
      if (seg.kind != SegmentKind.unavailable || fault == _Fault.skipHatch) {
        continue;
      }
      canvas.save();
      canvas.clipRect(band);
      for (double at = band.left - band.height; at < band.right; at += 8) {
        canvas.drawLine(
          Offset(at, band.bottom),
          Offset(at + band.height, band.top),
          hatch,
        );
      }
      canvas.restore();
    }
  }

  void _edges(Canvas canvas, Size size) {
    if (fault == _Fault.skipBands || fault == _Fault.skipEdges) {
      return;
    }
    final Paint edge = Paint()
      ..style = PaintingStyle.stroke
      ..color = scheme.outline
      ..strokeWidth = 2;
    for (final PerfSegment seg in series.segments) {
      final bool? solid = switch (seg.kind) {
        SegmentKind.measured => null,
        SegmentKind.unavailable => null,
        SegmentKind.simExcluded => fault == _Fault.swapEdgeStyle,
        SegmentKind.manualExecuted => fault != _Fault.swapEdgeStyle,
      };
      if (solid == null) {
        continue;
      }
      for (final double n in <double>[seg.startNormalized, seg.endNormalized]) {
        final double x = _x(n, size);
        if (solid) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), edge);
          continue;
        }
        for (double at = 0; at < size.height; at += 10) {
          final double until = at + 6 < size.height ? at + 6 : size.height;
          canvas.drawLine(Offset(x, at), Offset(x, until), edge);
        }
      }
    }
  }

  void _ticks(Canvas canvas, Size size) {
    if (fault == _Fault.skipTicks) {
      return;
    }
    for (final PerfAxisTick tick in series.yTicks) {
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = tick.isBaseline ? scheme.outline : scheme.outlineVariant
        ..strokeWidth = tick.isBaseline ? 2 : 1;
      double y = _y(tick.normalized, size);
      if (fault == _Fault.shiftTicks) {
        y = y * 0.9 + size.height * 0.1;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _benchmark(Canvas canvas, Size size) {
    if (fault == _Fault.skipBenchmark) {
      return;
    }
    final List<PerfPoint>? points = fault == _Fault.benchmarkFromMain
        ? series.points
        : series.benchmark?.points;
    if (points == null) {
      return;
    }
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = scheme.tertiary
      ..strokeWidth = 2;
    final Paint dot = Paint()
      ..style = PaintingStyle.fill
      ..color = scheme.tertiary;
    for (final Path path in _paths(
      canvas,
      points,
      size,
      dot,
      join: fault == _Fault.joinBenchmarkGaps,
      squeeze: false,
      curved: false,
    )) {
      canvas.drawPath(
        fault == _Fault.solidBenchmark ? path : _dashed(path),
        stroke,
      );
    }
  }

  void _mainLine(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = scheme.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint dot = Paint()
      ..style = PaintingStyle.fill
      ..color = scheme.primary;
    if (fault == _Fault.reusePath) {
      // 같은 Path 하나를 비워 가며 다시 쓴다 — 기록이 «그리는 순간»의 값이어야 통과한다.
      final Path shared = Path();
      for (final IndexRun run in splitRuns(series.points)) {
        if (run.start == run.end) {
          canvas.drawCircle(_spot(series.points[run.start], size), 3, dot);
          continue;
        }
        shared.reset();
        _trace(shared, series.points, run, size);
        canvas.drawPath(shared, stroke);
      }
      shared.reset();
      return;
    }
    for (final Path path in _paths(
      canvas,
      series.points,
      size,
      fault == _Fault.skipDots ? null : dot,
      join: fault == _Fault.joinGaps,
      squeeze: fault == _Fault.squeezeHorizontal,
      curved: fault == _Fault.curved,
    )) {
      canvas.drawPath(path, stroke);
    }
  }

  Offset _spot(PerfPoint p, Size size, {bool squeeze = false}) => Offset(
    _x(p.xNormalized, size) * (squeeze ? 0.9 : 1),
    _y(p.yNormalized!, size),
  );

  void _trace(
    Path path,
    List<PerfPoint> points,
    IndexRun run,
    Size size, {
    bool squeeze = false,
    bool curved = false,
  }) {
    Offset last = _spot(points[run.start], size, squeeze: squeeze);
    path.moveTo(last.dx, last.dy);
    for (int i = run.start + 1; i <= run.end; i++) {
      final Offset next = _spot(points[i], size, squeeze: squeeze);
      if (curved) {
        final double mid = (last.dx + next.dx) / 2;
        path.cubicTo(mid, last.dy, mid, next.dy, next.dx, next.dy);
      } else {
        path.lineTo(next.dx, next.dy);
      }
      last = next;
    }
  }

  /// 범위마다 윤곽 1개. 점 1개짜리 범위는 [dot] 으로 원을 찍는다(null 이면 빼먹는다).
  /// [join] 이면 결측을 건너뛰고 값이 있는 점을 전부 한 윤곽으로 잇는다.
  List<Path> _paths(
    Canvas canvas,
    List<PerfPoint> points,
    Size size,
    Paint? dot, {
    required bool join,
    required bool squeeze,
    required bool curved,
  }) {
    if (join) {
      final List<PerfPoint> present = <PerfPoint>[
        for (final PerfPoint p in points)
          if (p.yNormalized != null) p,
      ];
      if (present.length < 2) {
        return <Path>[];
      }
      final Path path = Path();
      _trace(path, present, (start: 0, end: present.length - 1), size);
      return <Path>[path];
    }
    final List<Path> out = <Path>[];
    for (final IndexRun run in splitRuns(points)) {
      if (run.start == run.end) {
        if (dot != null) {
          canvas.drawCircle(
            _spot(points[run.start], size, squeeze: squeeze),
            3,
            dot,
          );
        }
        continue;
      }
      final Path path = Path();
      _trace(path, points, run, size, squeeze: squeeze, curved: curved);
      out.add(path);
    }
    return out;
  }

  Path _dashed(Path source) {
    final Path out = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double at = 0;
      while (at < metric.length) {
        out.addPath(metric.extractPath(at, at + 6), Offset.zero);
        at += 10;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_FaultyPainter oldDelegate) => true;
}
