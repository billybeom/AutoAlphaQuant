// goal_path_probe_test.dart — 목표 경로 차트 하네스(chart_probe.dart 의 expectGoalPathMatches)와
// 본보기(reference/goal_path/)의 자체 검증 (ui_analytics · M2 소유 · 🆕 계약 v1.4 · 설계 D12)
//
// 하네스가 «무엇을 통과시키고 무엇을 잡는가»를 코드로 고정한다. S7-9 차트의 주 증명이 이것이다
// (골든은 보조). chart_probe.dart 를 고치기 전에 이 파일과 chart_probe_test.dart 를 먼저 읽는다.
//
//   통과: 본보기 painter — 목표 경로 픽스처 3건(on · off · realworld) × light·dark · 크기 3가지 ·
//         성과 픽스처의 띠를 얹은 경로(SegmentKind 4값) · 실제로 띄운 GoalPathChart
//   부재: hold(chartUnavailableLabel) — 본보기 painter 는 아무것도 그리지 않고, 하네스를 부르면 실패한다
//   잡음: ① 보간 — 실제선의 결측을 건너 이어 그림
//         ② 층 바꿈 — 실제선을 계획선 아래에 그림 / 두 선의 붓을 서로 바꿔 그림
//
// 🔴 화면 담당은 이 파일을 고치지 않는다.
// 🔴 한국어 문자열 리터럴을 두지 않는다.
// 🔴 나쁜 painter 는 본보기 painter 에 **고친 입력**을 주거나 두 번 불러 만든다 — 그리기 코드를
//    새로 짜지 않는다(본보기와 다른 곳이 결함 하나뿐이도록).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_probe.dart';
import 'golden_support.dart';
import 'reference/chart/perf_chart_geometry.dart';
import 'reference/goal_path/goal_path_chart.dart';
import 'reference/goal_path/goal_path_chart_painter.dart';

/// painter 를 바로 기록할 때의 그림 크기 — 폰 폭 390 · 상자 220 에서 위아래 12 를 뺀 높이.
const Size _plotSize = Size(390, 196);

/// 실제로 띄운 `GoalPathChart` 의 그림 크기 — 폰 폭 390 에서 눈금 글자 열 56 과 빈칸 8 을 뺀 폭.
const Size _widgetPlotSize = Size(390 - 56 - 8, 196);

ColorScheme _scheme(Brightness b) =>
    ThemeData(useMaterial3: true, brightness: b).colorScheme;

ChartRecording _record(
  GoalPathVm path,
  ColorScheme scheme, {
  Size size = _plotSize,
}) => recordPainter(
  GoalPathChartPainter(
    path: path,
    colors: GoalPathChartColors.fromScheme(scheme),
  ),
  size,
);

/// `TestFailure` 로 실패하고 그 메시지가 [pattern](정규식 · 여러 줄에 걸쳐 맞춘다)과 맞는다.
Matcher _failsWith(String pattern) => throwsA(
  isA<TestFailure>().having(
    (TestFailure f) => f.message,
    'message',
    matches(RegExp(pattern, dotAll: true)),
  ),
);

/// 🔴 합성 입력 — 이 파일(하네스 자체 검증)에 한해 허용. 실제선의 결측 점을 **빼서**
/// 본보기 painter 가 그 앞뒤 점을 직선으로 잇게 한다(= 보간). 값을 짓지 않는다.
GoalPathVm _withoutActualGaps(GoalPathVm path) => path.copyWith(
  actual: <PerfPoint>[
    for (final PerfPoint p in path.actual)
      if (p.yNormalized != null) p,
  ],
);

/// ② 층 바꿈(순서) — 띠·눈금·실제선을 먼저, 계획선을 나중에 그린다.
class _ActualUnderPlannedPainter extends CustomPainter {
  _ActualUnderPlannedPainter(this.path, this.colors);

  final GoalPathVm path;
  final GoalPathChartColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    GoalPathChartPainter(
      path: path.copyWith(planned: <PerfPoint>[]),
      colors: colors,
    ).paint(canvas, size);
    GoalPathChartPainter(
      path: path.copyWith(
        actual: <PerfPoint>[],
        segments: <PerfSegment>[],
        yTicks: <PerfAxisTick>[],
      ),
      colors: colors,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_ActualUnderPlannedPainter oldDelegate) => true;
}

/// ② 층 바꿈(붓) — 계획선을 실제선의 붓(primary 실선)으로, 실제선을 계획선의 붓으로 그린다.
GoalPathVm _swapLines(GoalPathVm path) =>
    path.copyWith(planned: path.actual, actual: path.planned);

void main() {
  final GoalPathVm on = singleFixture(
    FixturePaths.m7M7GoalPathOn,
    GoalPathVm.fromJson,
  );
  final GoalPathVm off = singleFixture(
    FixturePaths.m7M7GoalPathOff,
    GoalPathVm.fromJson,
  );
  final GoalPathVm realworld = singleFixture(
    FixturePaths.m7M7GoalPathRealworld,
    GoalPathVm.fromJson,
  );
  final GoalPathVm hold = singleFixture(
    FixturePaths.m7M7GoalPathHold,
    GoalPathVm.fromJson,
  );
  final Map<String, GoalPathVm> drawn = <String, GoalPathVm>{
    'm7_goal_path_on': on,
    'm7_goal_path_off': off,
    'm7_goal_path_realworld': realworld,
  };
  final ColorScheme light = _scheme(Brightness.light);

  test('fixtures cover what the goal path harness needs', () {
    // 픽스처가 바뀌어 끊김·띠의 표본이 사라지면 아래 검증이 조용히 비게 된다 — 먼저 막는다.
    for (final MapEntry<String, GoalPathVm> e in drawn.entries) {
      final GoalPathVm p = e.value;
      expect(p.chartUnavailableLabel, isNull, reason: e.key);
      expect(p.actual, isNotEmpty, reason: e.key);
      expect(p.planned, hasLength(p.actual.length), reason: e.key);
      expect(p.yTicks, isNotEmpty, reason: e.key);
      expect(splitRuns(p.planned), hasLength(1), reason: e.key);
    }
    expect(splitRuns(on.actual), <IndexRun>[(start: 0, end: 7)]);
    expect(splitRuns(off.actual), <IndexRun>[(start: 0, end: 7)]);
    expect(splitRuns(realworld.actual), <IndexRun>[
      (start: 0, end: 2),
      (start: 5, end: 7),
    ]);
    expect(realworld.segments.map((PerfSegment s) => s.kind), <SegmentKind>[
      SegmentKind.unavailable,
    ]);
    expect(hold.chartUnavailableLabel, isNotNull);
    expect(hold.planned, isEmpty);
    expect(hold.actual, isEmpty);
    expect(hold.yTicks, isEmpty);
    expect(hold.segments, isEmpty);
  });

  group('reference painter passes', () {
    for (final MapEntry<String, GoalPathVm> e in drawn.entries) {
      test('${e.key} light and dark', () {
        for (final Brightness b in Brightness.values) {
          final ColorScheme scheme = _scheme(b);
          expectGoalPathMatches(_record(e.value, scheme), e.value, scheme);
        }
      });
    }

    test('other sizes (ratio comparison does not depend on size)', () {
      for (final Size size in const <Size>[
        Size(320, 150),
        Size(800, 300),
        Size(1200, 196),
      ]) {
        for (final GoalPathVm p in drawn.values) {
          expectGoalPathMatches(_record(p, light, size: size), p, light);
        }
      }
    });

    test(
      'realworld: one solid primary line per run, dashed planned, one band',
      () {
        // T79-09 가 세는 것 — 실선 primary 는 끊김 1번으로 윤곽 2 · 점선 tertiary · 띠 채움 1.
        final ChartRecording r = _record(realworld, light);
        int count(Color c) => r.contours
            .where((ProbeContour k) => k.color == c.toARGB32())
            .length;
        expect(r.violations, isEmpty);
        expect(count(light.primary), 2);
        expect(count(light.tertiary), greaterThan(10));
        expect(r.rects, hasLength(1));
        expect(r.circles, isEmpty);
        final ChartRecording whole = _record(on, light);
        expect(
          whole.contours.where(
            (ProbeContour k) => k.color == light.primary.toARGB32(),
          ),
          hasLength(1),
        );
        expect(whole.rects, isEmpty);
      },
    );

    test(
      'bands of every SegmentKind (segments borrowed from perf fixtures)',
      () {
        // 🔴 합성 입력 — 목표 경로 픽스처의 띠는 UNAVAILABLE 뿐이다. 성과 픽스처의 띠를 그대로 얹어
        //    본보기 painter 의 SegmentKind 4값 갈래가 층 표대로인지 본다(값을 짓지 않는다).
        final List<PerformanceSeries> donors = <PerformanceSeries>[
          singleFixture(
            FixturePaths.m7M7PerfDailyGap,
            PerformanceSeries.fromJson,
          ),
          singleFixture(
            FixturePaths.m7M7PerfMonthlySimSplit,
            PerformanceSeries.fromJson,
          ),
          singleFixture(
            FixturePaths.m7M7PerfDailyManual,
            PerformanceSeries.fromJson,
          ),
        ];
        final Set<SegmentKind> seen = <SegmentKind>{};
        for (final PerformanceSeries donor in donors) {
          final GoalPathVm p = realworld.copyWith(segments: donor.segments);
          seen.addAll(donor.segments.map((PerfSegment s) => s.kind));
          for (final Brightness b in Brightness.values) {
            final ColorScheme scheme = _scheme(b);
            expectGoalPathMatches(_record(p, scheme), p, scheme);
          }
        }
        expect(seen, SegmentKind.values.toSet());
      },
    );
  });

  group('hold (chartUnavailableLabel) has no chart', () {
    test('reference painter draws nothing', () {
      final ChartRecording r = _record(hold, light);
      expect(r.contours, isEmpty);
      expect(r.lines, isEmpty);
      expect(r.rects, isEmpty);
      expect(r.circles, isEmpty);
      expect(r.violations, isEmpty);
    });

    test('calling the harness on hold fails', () {
      expect(
        () => expectGoalPathMatches(_record(hold, light), hold, light),
        _failsWith('chartUnavailableLabel is set'),
      );
    });
  });

  group('faulty painters are caught', () {
    test('1. interpolation: joins the actual line across null points', () {
      for (final Brightness b in Brightness.values) {
        final ColorScheme scheme = _scheme(b);
        final ChartRecording r = _record(_withoutActualGaps(realworld), scheme);
        expect(
          () => expectGoalPathMatches(r, realworld, scheme),
          _failsWith('^goal path actual line.*A gap must break the line'),
        );
      }
    });

    test('2a. layer swap: actual line drawn under the planned line', () {
      for (final GoalPathVm p in drawn.values) {
        for (final Brightness b in Brightness.values) {
          final ColorScheme scheme = _scheme(b);
          final ChartRecording r = recordPainter(
            _ActualUnderPlannedPainter(
              p,
              GoalPathChartColors.fromScheme(scheme),
            ),
            _plotSize,
          );
          expect(
            () => expectGoalPathMatches(r, p, scheme),
            _failsWith('^goal path .*layer order'),
          );
        }
      }
    });

    test('2b. layer swap: the two lines use each other\'s paint', () {
      for (final GoalPathVm p in drawn.values) {
        for (final Brightness b in Brightness.values) {
          final ColorScheme scheme = _scheme(b);
          final ChartRecording r = _record(_swapLines(p), scheme);
          expect(
            () => expectGoalPathMatches(r, p, scheme),
            _failsWith('^goal path (actual|planned) line'),
          );
        }
      }
    });
  });

  group('GoalPathChart widget', () {
    for (final MapEntry<String, GoalPathVm> e in drawn.entries) {
      testWidgets('${e.key}: recordChart finds the chart and checks pass', (
        WidgetTester tester,
      ) async {
        final GoalPathVm p = e.value;
        await pumpForGolden(
          tester,
          GoalPathChart(path: p),
          brightness: Brightness.light,
        );
        expect(find.byKey(kChartProbeKey), findsNothing);
        final ColorScheme scheme = chartSchemeOf(
          tester,
          key: kGoalPathChartProbeKey,
        );
        final ChartRecording r = recordChart(
          tester,
          key: kGoalPathChartProbeKey,
        );
        expect(r.size, _widgetPlotSize);
        expect(
          tester.getSize(find.byType(GoalPathChart)),
          const Size(390, 220),
        );
        expectGoalPathMatches(r, p, scheme);

        // 그림 = 상자에서 위아래 12 · 왼쪽으로 글자 열과 빈칸을 뺀 자리.
        final Rect box = tester.getRect(find.byType(GoalPathChart));
        final Rect plot = tester.getRect(find.byKey(kGoalPathChartProbeKey));
        expect(plot.left, box.left + GoalPathChart.plotInsetLeft);
        expect(
          GoalPathChart.plotInsetLeft,
          GoalPathChart.tickColumnWidth + GoalPathChart.tickColumnGap,
        );
        expect(plot.right, box.right);
        expect(plot.top, box.top + 12);
        expect(plot.bottom, box.bottom - 12);

        // 눈금 글자 — 픽스처 글자 그대로 · 그림 왼쪽 바깥 열 · 눈금이 높을수록 위.
        double? below;
        for (int i = 0; i < p.yTicks.length; i++) {
          final Finder label = find.byKey(ValueKey<String>('s79-tick-$i'));
          expect(label, findsOneWidget);
          expect(tester.widget<Text>(label).data, p.yTicks[i].label);
          final Rect at = tester.getRect(label);
          expect(at.right, lessThanOrEqualTo(plot.left));
          expect(at.right, box.left + GoalPathChart.tickColumnWidth);
          if (below != null) {
            expect(at.top, lessThan(below));
          }
          below = at.top;
        }
        expect(
          find.byKey(ValueKey<String>('s79-tick-${p.yTicks.length}')),
          findsNothing,
        );
      });
    }

    testWidgets('dark theme: checks pass with dark colors', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        GoalPathChart(path: realworld),
        brightness: Brightness.dark,
      );
      final ColorScheme scheme = chartSchemeOf(
        tester,
        key: kGoalPathChartProbeKey,
      );
      expect(scheme.brightness, Brightness.dark);
      expectGoalPathMatches(
        recordChart(tester, key: kGoalPathChartProbeKey),
        realworld,
        scheme,
      );
    });
  });
}
