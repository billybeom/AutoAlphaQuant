// chart_probe.dart — S7-2 차트의 «그리기 기록» 하네스 (ui_analytics · M2 소유 · 계약 v1.3)
//
// 무엇을 하나: 화면에 올라온 `CustomPaint(key: Key('s72-chart'))` 의 painter 를 기록용 캔버스에
//   다시 그려, «무엇을 · 어디에 · 어떤 색·굵기로» 그렸는지를 값으로 읽는다. 그리고 그 기록이
//   넘겨받은 픽스처(`PerformanceSeries`)의 정규값과 맞는지 **단언까지 여기서 한다**.
//
// 왜 있나(01 §13 · 03 §6 수용 (a)):
//   · 골든 비교기는 옅은 채움·점선·±2px 어긋남을 못 본다. «결측에서 선이 끊겼다»·«띠가 있다»의
//     주 증명은 이 하네스다. 골든은 보조다.
//   · 기대값을 화면 담당이 쓰지 않는다 — 기대는 전부 픽스처에서 이 파일이 계산한다.
//
// 쓰는 법(화면 담당):
//     final series = singleFixture(FixturePaths.m7M7PerfDailyGap, PerformanceSeries.fromJson);
//     …화면을 띄운다…
//     final scheme = chartSchemeOf(tester);
//     final recording = recordChart(tester);
//     expectMainLineMatches(recording, series, scheme);
//     expectBenchmarkMatches(recording, series, scheme);
//     expectBandsMatch(recording, series, scheme);
//     expectTicksMatch(recording, series, scheme);
//
// 층을 가르는 열쇠 = (그리기 방식 · 색 · 굵기 · 방향). 표는 01 §13-2 와
//   test/golden/reference/chart/perf_chart_painter.dart 머리 주석에 있다(고정).
// 비교는 **비율**이다 — 가로 = x ÷ 그림 폭 · 세로 = 1 − y ÷ 그림 높이 · 허용 ±0.02.
//   그림 영역 = CustomPaint 의 크기 전체(안쪽 여백 없음).
//
// 🔴 화면 담당은 이 파일을 고치지 않는다(고치면 반려). 맞지 않으면 질문 표에 적는다.
// 🔴 한국어 문자열 리터럴을 두지 않는다 — 실패 메시지는 ASCII 다.
// 🔴 본보기 구현(reference/)을 import 하지 않는다 — 기대 계산은 이 파일 혼자 한다.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 비율 비교의 허용 오차.
const double kChartProbeTolerance = 0.02;

/// 차트 그림의 기본 열쇠.
const Key kChartProbeKey = Key('s72-chart');

/// `drawPath` 로 그린 윤곽 1개(획). 기록하는 순간 값으로 읽어 둔 것이다.
class ProbeContour {
  const ProbeContour({
    required this.seq,
    required this.color,
    required this.strokeWidth,
    required this.cap,
    required this.join,
    required this.bounds,
    required this.length,
    required this.samples,
    required this.turns,
  });

  /// 그린 순서(0 부터).
  final int seq;
  final int color;
  final double strokeWidth;
  final StrokeCap cap;
  final StrokeJoin join;
  final Rect bounds;
  final double length;

  /// 윤곽을 따라 0.5 간격으로 읽은 자리들(양 끝 포함).
  final List<Offset> samples;

  /// 이웃한 두 자리 사이에서 방향이 바뀐 횟수. 직선 꺾은선이면 꼭짓점 수를 넘지 않는다.
  final int turns;
}

/// `drawLine` 1회.
class ProbeLine {
  const ProbeLine({
    required this.seq,
    required this.from,
    required this.to,
    required this.color,
    required this.strokeWidth,
    required this.clip,
  });

  final int seq;
  final Offset from;
  final Offset to;
  final int color;
  final double strokeWidth;

  /// 그릴 때 걸려 있던 `clipRect`(없으면 null).
  final Rect? clip;
}

/// `drawRect` 1회.
class ProbeRect {
  const ProbeRect({
    required this.seq,
    required this.rect,
    required this.color,
    required this.style,
  });

  final int seq;
  final Rect rect;
  final int color;
  final PaintingStyle style;
}

/// `drawCircle` 1회.
class ProbeCircle {
  const ProbeCircle({
    required this.seq,
    required this.center,
    required this.radius,
    required this.color,
    required this.style,
  });

  final int seq;
  final Offset center;
  final double radius;
  final int color;
  final PaintingStyle style;
}

/// painter 가 한 번 그린 기록 전체.
class ChartRecording {
  const ChartRecording({
    required this.size,
    required this.contours,
    required this.fills,
    required this.lines,
    required this.rects,
    required this.circles,
    required this.violations,
  });

  /// 그림 영역의 크기(= CustomPaint 의 크기).
  final Size size;

  /// 획으로 그린 `drawPath` 의 윤곽들.
  final List<ProbeContour> contours;

  /// 채움으로 그린 `drawPath` 의 순번(층 표에 없다 — 있으면 실패).
  final List<int> fills;
  final List<ProbeLine> lines;
  final List<ProbeRect> rects;
  final List<ProbeCircle> circles;

  /// 층 표가 금지한 호출(saveLayer · translate · 글자 그리기 · 그라디언트 …).
  final List<String> violations;
}

/// [key] 가 붙은 `CustomPaint` 를 둘러싼 테마의 색 묶음.
ColorScheme chartSchemeOf(WidgetTester tester, {Key key = kChartProbeKey}) {
  final Finder finder = find.byKey(key);
  expect(finder, findsOneWidget, reason: 'chart_probe: no widget with $key');
  return Theme.of(tester.element(finder)).colorScheme;
}

/// 화면에 올라온 `CustomPaint(key: …)` 의 painter 를 기록용 캔버스에 다시 그린다.
ChartRecording recordChart(WidgetTester tester, {Key key = kChartProbeKey}) {
  final Finder finder = find.byKey(key);
  expect(finder, findsOneWidget, reason: 'chart_probe: no widget with $key');
  final Widget widget = tester.widget(finder);
  if (widget is! CustomPaint) {
    fail('chart_probe: $key is ${widget.runtimeType}, expected CustomPaint');
  }
  final CustomPainter? painter = widget.painter;
  if (painter == null) {
    fail('chart_probe: CustomPaint($key).painter is null');
  }
  if (widget.foregroundPainter != null) {
    fail('chart_probe: CustomPaint($key) must not use foregroundPainter');
  }
  return recordPainter(painter, tester.getSize(finder));
}

/// [painter] 를 [size] 로 한 번 그려 기록한다(위젯 없이 painter 만 볼 때).
ChartRecording recordPainter(CustomPainter painter, Size size) {
  final _ProbeCanvas canvas = _ProbeCanvas();
  painter.paint(canvas, size);
  return canvas.finish(size);
}

// ─────────────────────────────────────────────────────────────────────────────
// 단언 4종
// ─────────────────────────────────────────────────────────────────────────────

/// 본선 — 색 primary · 획 · 굵기 3 · 둥근 끝·이음.
///
/// · 윤곽(또는 점 1개짜리 원)의 수 == 값이 이어진 범위의 수. 결측을 건너 잇지 않았다.
/// · 범위마다: 점 전부가 윤곽 위에 있고, 윤곽 전부가 점을 직선으로 이은 꺾은선 위에 있다(±0.02).
/// · 세로 뒤집힘: yNormalized 가 가장 큰 점이 가장 위다.
/// · 직선만 — 곡선이면 실패한다. 본선이 맨 위 층이다.
void expectMainLineMatches(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
) {
  _expectCommon(r, scheme);
  final int color = scheme.primary.toARGB32();
  final List<ProbeContour> contours = <ProbeContour>[
    for (final ProbeContour c in r.contours)
      if (c.color == color) c,
  ];
  final List<ProbeCircle> dots = <ProbeCircle>[
    for (final ProbeCircle c in r.circles)
      if (c.color == color) c,
  ];
  for (final ProbeContour c in contours) {
    _near(c.strokeWidth, 3, 0.01, 'main line stroke width');
    expect(c.cap, StrokeCap.round, reason: 'main line: strokeCap');
    expect(c.join, StrokeJoin.round, reason: 'main line: strokeJoin');
  }
  _expectPolyline(
    what: 'main line',
    size: r.size,
    points: s.points,
    contours: contours,
    dots: dots,
    dashed: false,
  );
  _expectTopmost(
    what: 'main line',
    size: r.size,
    points: s.points,
    r: r,
    color: color,
  );
}

/// 벤치마크 — 색 tertiary · 획 · 굵기 2 · 점선(6 그리고 4 띄움).
///
/// · `benchmark == null` 이면 그 색의 획·원이 0 이다.
/// · 있으면: 가로 범위가 자기 범위(자기 결측에서만 끊는다)와 맞고, 점선 조각 전부가
///   점을 직선으로 이은 꺾은선 위에 있다(±0.02). 실선이면 실패한다.
void expectBenchmarkMatches(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
) {
  _expectCommon(r, scheme);
  final int color = scheme.tertiary.toARGB32();
  final List<ProbeContour> contours = <ProbeContour>[
    for (final ProbeContour c in r.contours)
      if (c.color == color) c,
  ];
  final List<ProbeCircle> dots = <ProbeCircle>[
    for (final ProbeCircle c in r.circles)
      if (c.color == color) c,
  ];
  final BenchmarkSeries? benchmark = s.benchmark;
  if (benchmark == null) {
    expect(
      contours.length,
      0,
      reason: 'benchmark is null but tertiary strokes were drawn',
    );
    expect(
      dots.length,
      0,
      reason: 'benchmark is null but tertiary circles were drawn',
    );
    return;
  }
  for (final ProbeContour c in contours) {
    _near(c.strokeWidth, 2, 0.01, 'benchmark stroke width');
  }
  _expectPolyline(
    what: 'benchmark',
    size: r.size,
    points: benchmark.points,
    contours: contours,
    dots: dots,
    dashed: true,
  );
}

/// 띠 — 측정 아닌 구간마다.
///
/// · unavailable  = 채움 1(surfaceContainerHighest) + 그 띠로 자른 45° 빗금(outline · 1.5 · 간격 8)
/// · simExcluded  = 채움 1 + 양 끝 세로 **점선**(outline · 2)
/// · manualExecuted = 채움 0 + 양 끝 세로 **실선**(outline · 2)
/// · measured     = 아무것도 없다
/// 가로 범위 비율 == (startNormalized, endNormalized) ±0.02 · 세로는 그림 전체.
void expectBandsMatch(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
) {
  _expectCommon(r, scheme);
  final double w = r.size.width;
  final double h = r.size.height;

  // ① 채움
  final List<PerfSegment> filled = <PerfSegment>[
    for (final PerfSegment seg in s.segments)
      if (_hasFill(seg.kind)) seg,
  ];
  final List<ProbeRect> rects = <ProbeRect>[...r.rects]
    ..sort((ProbeRect a, ProbeRect b) => a.rect.left.compareTo(b.rect.left));
  expect(
    rects.length,
    filled.length,
    reason:
        'band fills: expected ${filled.length} '
        '(UNAVAILABLE + SIM_EXCLUDED segments), drew ${rects.length}',
  );
  final List<PerfSegment> filledByStart = <PerfSegment>[...filled]
    ..sort(
      (PerfSegment a, PerfSegment b) =>
          a.startNormalized.compareTo(b.startNormalized),
    );
  for (int i = 0; i < filledByStart.length; i++) {
    final PerfSegment seg = filledByStart[i];
    final Rect rect = rects[i].rect;
    final String what = 'band fill #$i (${seg.kind.wire})';
    _near(
      rect.left / w,
      seg.startNormalized,
      kChartProbeTolerance,
      '$what left',
    );
    _near(
      rect.right / w,
      seg.endNormalized,
      kChartProbeTolerance,
      '$what right',
    );
    _near(rect.top / h, 0, kChartProbeTolerance, '$what top');
    _near(rect.bottom / h, 1, kChartProbeTolerance, '$what bottom');
  }

  // ② 빗금 — unavailable 띠마다 있고, 다른 곳에는 없다.
  final List<ProbeLine> hatch = <ProbeLine>[
    for (final ProbeLine l in r.lines)
      if (_isDiagonal(l)) l,
  ];
  final List<PerfSegment> hatched = <PerfSegment>[
    for (final PerfSegment seg in s.segments)
      if (seg.kind == SegmentKind.unavailable) seg,
  ];
  final Map<int, List<ProbeLine>> hatchBySegment = <int, List<ProbeLine>>{};
  for (final ProbeLine l in hatch) {
    final Rect clip = l.clip!;
    int? owner;
    for (int i = 0; i < hatched.length; i++) {
      if ((clip.left / w - hatched[i].startNormalized).abs() <=
              kChartProbeTolerance &&
          (clip.right / w - hatched[i].endNormalized).abs() <=
              kChartProbeTolerance) {
        owner = i;
        break;
      }
    }
    if (owner == null) {
      fail(
        'hatch line #${l.seq} is clipped to '
        '${_f(clip.left / w)}..${_f(clip.right / w)} '
        'which is not an UNAVAILABLE segment',
      );
    }
    hatchBySegment.putIfAbsent(owner, () => <ProbeLine>[]).add(l);
  }
  for (int i = 0; i < hatched.length; i++) {
    final List<ProbeLine> lines = hatchBySegment[i] ?? <ProbeLine>[];
    final String what =
        'hatch of UNAVAILABLE '
        '${_f(hatched[i].startNormalized)}..${_f(hatched[i].endNormalized)}';
    expect(
      lines.length,
      greaterThanOrEqualTo(2),
      reason: '$what: expected 2 or more clipped diagonal lines',
    );
    // 간격 8 — 같은 높이(아래 끝)에서 잰 가로 간격.
    final List<double> feet = <double>[
      for (final ProbeLine l in lines) _xAtY(l, h),
    ]..sort();
    for (int k = 1; k < feet.length; k++) {
      _near(feet[k] - feet[k - 1], 8, 1, '$what: spacing between lines');
    }
    // 띠를 실제로 덮는다 — 띠의 왼쪽 끝과 오른쪽 끝을 지나는 빗금이 있다.
    final double left = hatched[i].startNormalized * w;
    final double right = hatched[i].endNormalized * w;
    final double lo = lines
        .map((ProbeLine l) => math.min(l.from.dx, l.to.dx))
        .reduce(math.min);
    final double hi = lines
        .map((ProbeLine l) => math.max(l.from.dx, l.to.dx))
        .reduce(math.max);
    expect(
      lo <= left + 8 && hi >= right - 8,
      isTrue,
      reason: '$what: lines do not cover the band',
    );
  }

  // ③ 경계 — simExcluded(점선)·manualExecuted(실선)의 양 끝에만 있다.
  final List<_Edge> edges = <_Edge>[];
  for (final PerfSegment seg in s.segments) {
    final bool? solid = _edgeSolid(seg.kind);
    if (solid == null) {
      continue;
    }
    for (final double at in <double>[seg.startNormalized, seg.endNormalized]) {
      _Edge? same;
      for (final _Edge e in edges) {
        if ((e.at - at).abs() <= kChartProbeTolerance) {
          same = e;
          break;
        }
      }
      if (same == null) {
        edges.add(_Edge(at)..note(solid: solid));
      } else {
        same.note(solid: solid);
      }
    }
  }
  for (final ProbeLine l in r.lines) {
    if (!_isVertical(l)) {
      continue;
    }
    final double at = l.from.dx / w;
    _Edge? owner;
    for (final _Edge e in edges) {
      if ((e.at - at).abs() <= kChartProbeTolerance) {
        owner = e;
        break;
      }
    }
    if (owner == null) {
      fail(
        'vertical line #${l.seq} at ${_f(at)} is not at the edge of a '
        'SIM_EXCLUDED or MANUAL_EXECUTED segment',
      );
    }
    owner.spans.add((
      math.min(l.from.dy, l.to.dy) / h,
      math.max(l.from.dy, l.to.dy) / h,
    ));
  }
  for (final _Edge e in edges) {
    final String what = 'band edge at ${_f(e.at)}';
    expect(e.spans, isNotEmpty, reason: '$what: no vertical line drawn');
    final double top = e.spans
        .map(((double, double) v) => v.$1)
        .reduce(math.min);
    final double bottom = e.spans
        .map(((double, double) v) => v.$2)
        .reduce(math.max);
    _near(top, 0, kChartProbeTolerance, '$what top');
    // 점선은 마지막 조각 뒤의 빈칸만큼 모자랄 수 있다.
    expect(
      bottom,
      greaterThanOrEqualTo(1 - kChartProbeTolerance - 4 / h),
      reason: '$what bottom: drew down to ${_f(bottom)}',
    );
    final double covered = _coveredLength(e.spans);
    if (e.wantsSolid) {
      expect(
        covered,
        greaterThanOrEqualTo(0.95),
        reason: '$what: expected a solid line, covered ${_f(covered)}',
      );
    } else {
      expect(
        e.spans.length,
        greaterThanOrEqualTo(2),
        reason: '$what: expected a dashed line (2 or more pieces)',
      );
      expect(
        covered,
        inInclusiveRange(0.3, 0.8),
        reason:
            '$what: expected a dashed line (6 on, 4 off), '
            'covered ${_f(covered)}',
      );
    }
  }
}

/// 눈금선 — `yTicks` 마다 가로선 1개.
///
/// · 세로 자리 비율 == normalized ±0.02 · 가로는 그림 전체
/// · 기준선(isBaseline) = outline · 2 / 그 밖 = outlineVariant · 1
void expectTicksMatch(
  ChartRecording r,
  PerformanceSeries s,
  ColorScheme scheme,
) {
  _expectCommon(r, scheme);
  final double w = r.size.width;
  final double h = r.size.height;
  final int strong = scheme.outline.toARGB32();
  final int soft = scheme.outlineVariant.toARGB32();

  final List<ProbeLine> drawn = <ProbeLine>[
    for (final ProbeLine l in r.lines)
      if (_isHorizontal(l)) l,
  ]..sort((ProbeLine a, ProbeLine b) => b.from.dy.compareTo(a.from.dy));
  final List<PerfAxisTick> ticks = <PerfAxisTick>[...s.yTicks]
    ..sort(
      (PerfAxisTick a, PerfAxisTick b) => a.normalized.compareTo(b.normalized),
    );
  expect(
    drawn.length,
    ticks.length,
    reason: 'tick lines: expected ${ticks.length}, drew ${drawn.length}',
  );
  for (int i = 0; i < ticks.length; i++) {
    final PerfAxisTick tick = ticks[i];
    final ProbeLine line = drawn[i];
    final String what = 'tick line #$i (normalized ${_f(tick.normalized)})';
    _near(
      1 - line.from.dy / h,
      tick.normalized,
      kChartProbeTolerance,
      '$what y',
    );
    _near(
      math.min(line.from.dx, line.to.dx) / w,
      0,
      kChartProbeTolerance,
      '$what left',
    );
    _near(
      math.max(line.from.dx, line.to.dx) / w,
      1,
      kChartProbeTolerance,
      '$what right',
    );
    expect(
      line.color,
      tick.isBaseline ? strong : soft,
      reason:
          '$what color: baseline uses outline, '
          'other ticks use outlineVariant',
    );
    _near(
      line.strokeWidth,
      tick.isBaseline ? 2 : 1,
      0.01,
      '$what stroke width',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 공통 단언
// ─────────────────────────────────────────────────────────────────────────────

/// 네 단언이 모두 먼저 보는 것: 금지 호출 0 · 층 표 밖의 그림 0 · 층의 순서.
void _expectCommon(ChartRecording r, ColorScheme scheme) {
  expect(
    r.size.width > 0 && r.size.height > 0,
    isTrue,
    reason: 'chart_probe: chart size is empty (${r.size})',
  );
  expect(
    r.violations,
    isEmpty,
    reason: 'chart_probe: calls the layer table forbids',
  );
  expect(
    r.fills,
    isEmpty,
    reason: 'chart_probe: drawPath with fill style is outside the layer table',
  );

  final int primary = scheme.primary.toARGB32();
  final int tertiary = scheme.tertiary.toARGB32();
  final int band = scheme.surfaceContainerHighest.toARGB32();
  final int strong = scheme.outline.toARGB32();
  final int soft = scheme.outlineVariant.toARGB32();

  // 층 번호: 0 = 띠(채움·빗금·경계) · 1 = 눈금선 · 2 = 벤치마크 · 3 = 본선
  final List<(int, int, String)> layered = <(int, int, String)>[];
  final Set<String> strays = <String>{};

  for (final ProbeContour c in r.contours) {
    if (c.color == primary) {
      layered.add((c.seq, 3, 'main line'));
    } else if (c.color == tertiary) {
      layered.add((c.seq, 2, 'benchmark'));
    } else {
      strays.add('#${c.seq} drawPath stroke color ${_hex(c.color)}');
    }
  }
  for (final ProbeCircle c in r.circles) {
    final bool shape =
        c.style == PaintingStyle.fill && (c.radius - 3).abs() <= 0.01;
    if (shape && c.color == primary) {
      layered.add((c.seq, 3, 'main line dot'));
    } else if (shape && c.color == tertiary) {
      layered.add((c.seq, 2, 'benchmark dot'));
    } else {
      strays.add(
        '#${c.seq} drawCircle radius ${_f(c.radius)} '
        '${c.style.name} color ${_hex(c.color)}',
      );
    }
  }
  for (final ProbeRect c in r.rects) {
    if (c.style == PaintingStyle.fill && c.color == band) {
      layered.add((c.seq, 0, 'band fill'));
    } else {
      strays.add('#${c.seq} drawRect ${c.style.name} color ${_hex(c.color)}');
    }
  }
  for (final ProbeLine l in r.lines) {
    final bool w1 = (l.strokeWidth - 1).abs() <= 0.01;
    final bool w15 = (l.strokeWidth - 1.5).abs() <= 0.01;
    final bool w2 = (l.strokeWidth - 2).abs() <= 0.01;
    if (_isHorizontal(l) &&
        ((l.color == soft && w1) || (l.color == strong && w2))) {
      layered.add((l.seq, 1, 'tick line'));
    } else if (_isVertical(l) && l.color == strong && w2) {
      layered.add((l.seq, 0, 'band edge'));
    } else if (_isDiagonal(l) && l.color == strong && w15) {
      layered.add((l.seq, 0, 'hatch'));
    } else {
      strays.add(
        '#${l.seq} drawLine ${l.from} -> ${l.to} '
        'width ${_f(l.strokeWidth)} color ${_hex(l.color)} '
        'clip ${l.clip}',
      );
    }
  }
  expect(
    strays,
    isEmpty,
    reason: 'chart_probe: draw calls outside the fixed layer table',
  );

  layered.sort(((int, int, String) a, (int, int, String) b) => a.$1 - b.$1);
  int highest = 0;
  String holder = '';
  for (final (int seq, int layer, String name) in layered) {
    if (layer < highest) {
      fail(
        'chart_probe: layer order — "$name" (#$seq) was drawn after '
        '"$holder". Order is bands, tick lines, benchmark, main line.',
      );
    }
    if (layer > highest) {
      highest = layer;
      holder = name;
    }
  }
}

/// [points] 를 값이 이어진 범위로 나눈다. 🔴 하네스 자신의 계산이다(본보기를 부르지 않는다).
List<(int, int)> _runsOf(List<PerfPoint> points) {
  final List<(int, int)> runs = <(int, int)>[];
  int? open;
  for (int i = 0; i < points.length; i++) {
    if (points[i].yNormalized != null) {
      open ??= i;
    } else if (open != null) {
      runs.add((open, i - 1));
      open = null;
    }
  }
  if (open != null) {
    runs.add((open, points.length - 1));
  }
  return runs;
}

/// 정규 좌표(가로 0~1 · 세로 0~1 위가 1).
Offset _unit(Offset pixel, Size size) =>
    Offset(pixel.dx / size.width, 1 - pixel.dy / size.height);

Offset _expected(PerfPoint p) =>
    Offset(p.xNormalized.clamp(0.0, 1.0), p.yNormalized!.clamp(0.0, 1.0));

void _expectPolyline({
  required String what,
  required Size size,
  required List<PerfPoint> points,
  required List<ProbeContour> contours,
  required List<ProbeCircle> dots,
  required bool dashed,
}) {
  final List<(int, int)> runs = _runsOf(points);
  final List<(int, int)> lineRuns = <(int, int)>[
    for (final (int, int) run in runs)
      if (run.$1 != run.$2) run,
  ];
  final List<(int, int)> dotRuns = <(int, int)>[
    for (final (int, int) run in runs)
      if (run.$1 == run.$2) run,
  ];

  // 점 1개짜리 범위 = 원.
  expect(
    dots.length,
    dotRuns.length,
    reason:
        '$what: expected ${dotRuns.length} single-point run(s) drawn as '
        'circles, drew ${dots.length}',
  );
  for (final (int, int) run in dotRuns) {
    final Offset want = _expected(points[run.$1]);
    final bool found = dots.any(
      (ProbeCircle c) =>
          _chebyshev(_unit(c.center, size), want) <= kChartProbeTolerance,
    );
    expect(
      found,
      isTrue,
      reason: '$what: no circle at point #${run.$1} ${_o(want)}',
    );
  }

  if (!dashed) {
    expect(
      contours.length,
      lineRuns.length,
      reason:
          '$what: expected ${lineRuns.length} contour(s) — one per run of '
          'consecutive non-null points ${_runsText(lineRuns)} — drew '
          '${contours.length}. A gap must break the line.',
    );
  } else if (lineRuns.isEmpty) {
    expect(
      contours,
      isEmpty,
      reason: '$what: nothing to draw but drew strokes',
    );
  } else {
    expect(contours, isNotEmpty, reason: '$what: no strokes were drawn');
  }

  // 윤곽을 범위에 나눠 준다 — 윤곽의 가로 가운데가 드는 범위.
  final Map<int, List<ProbeContour>> byRun = <int, List<ProbeContour>>{};
  for (final ProbeContour c in contours) {
    final double mid = c.bounds.center.dx / size.width;
    int? owner;
    for (int i = 0; i < lineRuns.length; i++) {
      final double a = points[lineRuns[i].$1].xNormalized;
      final double b = points[lineRuns[i].$2].xNormalized;
      if (mid >= a - kChartProbeTolerance && mid <= b + kChartProbeTolerance) {
        owner = i;
        break;
      }
    }
    if (owner == null) {
      fail(
        '$what: a stroke spans ${_f(c.bounds.left / size.width)}..'
        '${_f(c.bounds.right / size.width)} which is inside no run '
        '${_runsText(lineRuns)}. Gaps must stay empty.',
      );
    }
    byRun.putIfAbsent(owner, () => <ProbeContour>[]).add(c);
  }

  for (int i = 0; i < lineRuns.length; i++) {
    final (int start, int end) = lineRuns[i];
    final String label = '$what run ($start,$end)';
    final List<ProbeContour> mine = byRun[i] ?? <ProbeContour>[];
    expect(mine, isNotEmpty, reason: '$label: nothing was drawn');
    if (!dashed) {
      expect(
        mine.length,
        1,
        reason: '$label: expected exactly 1 contour, drew ${mine.length}',
      );
    }
    final List<Offset> wanted = <Offset>[
      for (int k = start; k <= end; k++) _expected(points[k]),
    ];

    // 가로 범위.
    final double left =
        mine.map((ProbeContour c) => c.bounds.left).reduce(math.min) /
        size.width;
    final double right =
        mine.map((ProbeContour c) => c.bounds.right).reduce(math.max) /
        size.width;
    final double slack = dashed ? 4 / size.width : 0;
    _near(left, wanted.first.dx, kChartProbeTolerance, '$label left end');
    _near(
      right,
      wanted.last.dx,
      kChartProbeTolerance + slack,
      '$label right end',
    );

    // 그린 자리 전부가 기대 꺾은선 위에 있다.
    for (final ProbeContour c in mine) {
      for (final Offset sample in c.samples) {
        final Offset at = _unit(sample, size);
        final double d = _distanceToPolyline(at, wanted);
        if (d > kChartProbeTolerance) {
          fail(
            '$label: drew at ${_o(at)} which is ${_f(d)} away from the '
            'straight lines through the fixture points',
          );
        }
      }
    }

    // 기대 점 전부가 그린 선 위에 있다.
    final List<Offset> drawn = <Offset>[
      for (final ProbeContour c in mine)
        for (final Offset sample in c.samples) _unit(sample, size),
    ];
    final double reach =
        kChartProbeTolerance +
        (dashed ? 4 / math.min(size.width, size.height) : 0);
    for (int k = 0; k < wanted.length; k++) {
      double best = double.infinity;
      for (final Offset at in drawn) {
        best = math.min(best, _chebyshev(at, wanted[k]));
      }
      if (best > reach) {
        fail(
          '$label: point #${start + k} ${_o(wanted[k])} is not on the '
          'drawn line (nearest ${_f(best)})',
        );
      }
    }

    if (!dashed) {
      // 직선만 — 방향이 바뀌는 자리는 꼭짓점뿐이다.
      final int limit = 2 * wanted.length + 2;
      expect(
        mine.single.turns,
        lessThanOrEqualTo(limit),
        reason:
            '$label: direction changed ${mine.single.turns} times along the '
            'contour (limit $limit) — curves are not allowed, use lineTo only',
      );
    } else {
      // 점선 — 조각은 짧고(6), 그린 길이는 전체의 0.6 안팎이다.
      for (final ProbeContour c in mine) {
        expect(
          c.length,
          lessThanOrEqualTo(6.5),
          reason:
              '$label: a stroke piece is ${_f(c.length)} long — expected '
              'dashes (6 on, 4 off), not a solid line',
        );
      }
      double whole = 0;
      for (int k = 1; k < wanted.length; k++) {
        whole += Offset(
          (wanted[k].dx - wanted[k - 1].dx) * size.width,
          (wanted[k].dy - wanted[k - 1].dy) * size.height,
        ).distance;
      }
      if (whole >= 40) {
        final double inked =
            mine.fold<double>(0, (double a, ProbeContour c) => a + c.length) /
            whole;
        expect(
          inked,
          inInclusiveRange(0.45, 0.75),
          reason:
              '$label: dashes cover ${_f(inked)} of the line — expected '
              'about 0.6 (6 on, 4 off)',
        );
      }
    }
  }

  // 범위와 범위 사이(결측)는 비어 있다 — 사이의 가운데 절반에 그린 자리가 없다.
  for (int i = 1; i < runs.length; i++) {
    final double from = points[runs[i - 1].$2].xNormalized * size.width;
    final double to = points[runs[i].$1].xNormalized * size.width;
    final double margin = math.min(
      kChartProbeTolerance * size.width,
      (to - from) / 4,
    );
    for (final ProbeContour c in contours) {
      for (final Offset sample in c.samples) {
        if (sample.dx > from + margin && sample.dx < to - margin) {
          fail(
            '$what: drew at x ${_f(sample.dx / size.width)} inside the gap '
            'between point #${runs[i - 1].$2} and point #${runs[i].$1}. '
            'A gap must break the line — do not join across null points.',
          );
        }
      }
    }
  }
}

/// 세로 뒤집힘 검출 — yNormalized 가 가장 큰 점이 그 색으로 그린 것 가운데 가장 위다.
void _expectTopmost({
  required String what,
  required Size size,
  required List<PerfPoint> points,
  required ChartRecording r,
  required int color,
}) {
  double? best;
  for (final PerfPoint p in points) {
    final double? y = p.yNormalized;
    if (y != null && (best == null || y > best)) {
      best = y;
    }
  }
  if (best == null) {
    return;
  }
  final List<double> wantedAt = <double>[
    for (final PerfPoint p in points)
      if (p.yNormalized != null && (p.yNormalized! - best).abs() <= 1e-9)
        p.xNormalized,
  ];
  Offset? top;
  for (final ProbeContour c in r.contours) {
    if (c.color != color) {
      continue;
    }
    for (final Offset sample in c.samples) {
      if (top == null || sample.dy < top.dy) {
        top = sample;
      }
    }
  }
  for (final ProbeCircle c in r.circles) {
    if (c.color == color && (top == null || c.center.dy < top.dy)) {
      top = c.center;
    }
  }
  if (top == null) {
    return;
  }
  final Offset at = _unit(top, size);
  _near(
    at.dy,
    best.clamp(0.0, 1.0),
    kChartProbeTolerance,
    '$what: height of the topmost drawn spot (vertical flip?)',
  );
  // 꼭대기가 평평하면(같은 높이가 이어지면) 가로 자리는 그 사이 어디든 된다.
  final double lo = wantedAt.reduce(math.min) - kChartProbeTolerance;
  final double hi = wantedAt.reduce(math.max) + kChartProbeTolerance;
  expect(
    at.dx >= lo && at.dx <= hi,
    isTrue,
    reason:
        '$what: the topmost drawn spot is at x ${_f(at.dx)} but the point '
        'with the largest yNormalized is at x '
        '${wantedAt.map(_f).join(' / ')} (vertical flip?)',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 작은 도우미
// ─────────────────────────────────────────────────────────────────────────────

bool _hasFill(SegmentKind kind) => switch (kind) {
  SegmentKind.measured => false,
  SegmentKind.unavailable => true,
  SegmentKind.simExcluded => true,
  SegmentKind.manualExecuted => false,
};

/// 경계선이 실선인가. null = 경계선이 없는 구간.
bool? _edgeSolid(SegmentKind kind) => switch (kind) {
  SegmentKind.measured => null,
  SegmentKind.unavailable => null,
  SegmentKind.simExcluded => false,
  SegmentKind.manualExecuted => true,
};

class _Edge {
  _Edge(this.at);

  final double at;
  bool wantsSolid = false;
  final List<(double, double)> spans = <(double, double)>[];

  /// 같은 자리에 점선과 실선이 겹치면 실선이 이긴다.
  void note({required bool solid}) {
    wantsSolid = wantsSolid || solid;
  }
}

/// 겹치는 조각을 합친 뒤의 길이 합.
double _coveredLength(List<(double, double)> spans) {
  final List<(double, double)> sorted = <(double, double)>[...spans]
    ..sort(((double, double) a, (double, double) b) => a.$1.compareTo(b.$1));
  double total = 0;
  double? from;
  double? to;
  for (final (double a, double b) in sorted) {
    if (to == null || a > to) {
      if (from != null && to != null) {
        total += to - from;
      }
      from = a;
      to = b;
    } else if (b > to) {
      to = b;
    }
  }
  if (from != null && to != null) {
    total += to - from;
  }
  return total;
}

bool _isHorizontal(ProbeLine l) =>
    (l.from.dy - l.to.dy).abs() <= 0.01 && (l.from.dx - l.to.dx).abs() > 0.01;

bool _isVertical(ProbeLine l) =>
    (l.from.dx - l.to.dx).abs() <= 0.01 && (l.from.dy - l.to.dy).abs() > 0.01;

bool _isDiagonal(ProbeLine l) {
  final double dx = (l.from.dx - l.to.dx).abs();
  final double dy = (l.from.dy - l.to.dy).abs();
  return l.clip != null && dx > 0.01 && (dx - dy).abs() <= 0.01 * dx;
}

/// 빗금 [l] 을 늘였을 때 세로 자리 [y] 에서의 가로 자리.
double _xAtY(ProbeLine l, double y) {
  final double slope = (l.to.dx - l.from.dx) / (l.to.dy - l.from.dy);
  return l.from.dx + (y - l.from.dy) * slope;
}

double _chebyshev(Offset a, Offset b) =>
    math.max((a.dx - b.dx).abs(), (a.dy - b.dy).abs());

double _distanceToPolyline(Offset p, List<Offset> line) {
  if (line.length == 1) {
    return (p - line.single).distance;
  }
  double best = double.infinity;
  for (int i = 1; i < line.length; i++) {
    final Offset a = line[i - 1];
    final Offset ab = line[i] - a;
    final double len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    double t = 0;
    if (len2 > 0) {
      t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(
        0.0,
        1.0,
      );
    }
    best = math.min(best, (p - (a + ab * t)).distance);
  }
  return best;
}

void _near(double actual, double expected, double tolerance, String what) {
  if ((actual - expected).abs() > tolerance) {
    fail(
      '$what: expected ${_f(expected)} (+-${_f(tolerance)}), '
      'got ${_f(actual)}',
    );
  }
}

String _f(double v) => v.toStringAsFixed(4);

String _o(Offset v) => '(${_f(v.dx)}, ${_f(v.dy)})';

String _hex(int argb) => '0x${argb.toRadixString(16).padLeft(8, '0')}';

String _runsText(List<(int, int)> runs) =>
    '[${runs.map(((int, int) r) => '(${r.$1},${r.$2})').join(' ')}]';

// ─────────────────────────────────────────────────────────────────────────────
// 기록용 캔버스
// ─────────────────────────────────────────────────────────────────────────────

/// `flutter_test` 의 [TestRecordingCanvas] 위에, 그리는 **그 순간** 값을 읽어 두는 층을 얹는다.
///
/// 🔴 `TestRecordingCanvas.drawPath` 는 `Path` **원본 참조**를 기록한다. painter 가 같은 `Path` 를
///    고쳐 가며 다시 쓰면 나중에 읽은 값이 바뀌어 있다 — 그래서 여기서 바로 값으로 바꾼다.
class _ProbeCanvas extends TestRecordingCanvas {
  final List<ProbeContour> _contours = <ProbeContour>[];
  final List<int> _fills = <int>[];
  final List<ProbeLine> _lines = <ProbeLine>[];
  final List<ProbeRect> _rects = <ProbeRect>[];
  final List<ProbeCircle> _circles = <ProbeCircle>[];
  final List<String> _violations = <String>[];
  final List<Rect?> _clipStack = <Rect?>[];
  Rect? _clip;
  int _seq = 0;

  static const Set<Symbol> _drawCallsOutsideTable = <Symbol>{
    #drawRRect,
    #drawDRRect,
    #drawArc,
    #drawPaint,
    #drawRSuperellipse,
    #drawOval,
    #drawImage,
    #drawImageRect,
    #drawImageNine,
    #drawPoints,
    #drawRawPoints,
    #drawVertices,
    #drawAtlas,
    #drawRawAtlas,
  };

  void _checkPaint(String call, Paint paint) {
    if (paint.shader != null) {
      _violations.add('$call: Paint.shader (gradient) is not allowed');
    }
    if (paint.maskFilter != null) {
      _violations.add('$call: Paint.maskFilter is not allowed');
    }
    if (paint.colorFilter != null) {
      _violations.add('$call: Paint.colorFilter is not allowed');
    }
    if (paint.imageFilter != null) {
      _violations.add('$call: Paint.imageFilter is not allowed');
    }
    if (paint.blendMode != BlendMode.srcOver) {
      _violations.add('$call: Paint.blendMode ${paint.blendMode.name}');
    }
  }

  @override
  void save() {
    super.save();
    _clipStack.add(_clip);
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    super.saveLayer(bounds, paint);
    _clipStack.add(_clip);
    _violations.add('saveLayer is not allowed');
  }

  @override
  void restore() {
    if (_clipStack.isEmpty) {
      _violations.add('restore without a matching save');
      return;
    }
    super.restore();
    _clip = _clipStack.removeLast();
  }

  @override
  void drawPath(Path path, Paint paint) {
    super.drawPath(path, paint);
    _checkPaint('drawPath', paint);
    final int seq = _seq++;
    if (paint.style != PaintingStyle.stroke) {
      _fills.add(seq);
      return;
    }
    for (final ui.PathMetric metric in path.computeMetrics()) {
      final List<Offset> samples = <Offset>[];
      int turns = 0;
      Offset? heading;
      final double length = metric.length;
      final int steps = math.max(1, (length / 0.5).ceil());
      for (int i = 0; i <= steps; i++) {
        final ui.Tangent? tangent = metric.getTangentForOffset(
          length * i / steps,
        );
        if (tangent == null) {
          continue;
        }
        samples.add(tangent.position);
        final Offset now = tangent.vector;
        if (heading != null) {
          final double cross = heading.dx * now.dy - heading.dy * now.dx;
          final double dot = heading.dx * now.dx + heading.dy * now.dy;
          if (math.atan2(cross, dot).abs() > 1e-3) {
            turns++;
          }
        }
        heading = now;
      }
      if (samples.isEmpty) {
        continue;
      }
      double left = samples.first.dx;
      double right = samples.first.dx;
      double top = samples.first.dy;
      double bottom = samples.first.dy;
      for (final Offset sample in samples) {
        left = math.min(left, sample.dx);
        right = math.max(right, sample.dx);
        top = math.min(top, sample.dy);
        bottom = math.max(bottom, sample.dy);
      }
      _contours.add(
        ProbeContour(
          seq: seq,
          color: paint.color.toARGB32(),
          strokeWidth: paint.strokeWidth,
          cap: paint.strokeCap,
          join: paint.strokeJoin,
          bounds: Rect.fromLTRB(left, top, right, bottom),
          length: length,
          samples: samples,
          turns: turns,
        ),
      );
    }
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    super.drawLine(p1, p2, paint);
    _checkPaint('drawLine', paint);
    _lines.add(
      ProbeLine(
        seq: _seq++,
        from: p1,
        to: p2,
        color: paint.color.toARGB32(),
        strokeWidth: paint.strokeWidth,
        clip: _clip,
      ),
    );
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    super.drawRect(rect, paint);
    _checkPaint('drawRect', paint);
    _rects.add(
      ProbeRect(
        seq: _seq++,
        rect: rect,
        color: paint.color.toARGB32(),
        style: paint.style,
      ),
    );
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    super.drawCircle(c, radius, paint);
    _checkPaint('drawCircle', paint);
    _circles.add(
      ProbeCircle(
        seq: _seq++,
        center: c,
        radius: radius,
        color: paint.color.toARGB32(),
        style: paint.style,
      ),
    );
  }

  /// `TestRecordingCanvas` 가 따로 구현하지 않은 호출은 전부 여기로 온다
  /// (clipRect · translate · scale · rotate · drawParagraph …).
  @override
  void noSuchMethod(Invocation invocation) {
    super.noSuchMethod(invocation);
    final Symbol name = invocation.memberName;
    if (name == #clipRect) {
      final Rect rect = invocation.positionalArguments.first as Rect;
      final Rect? current = _clip;
      _clip = current == null ? rect : current.intersect(rect);
      if (_clipStack.isEmpty) {
        _violations.add('clipRect outside save/restore');
      }
      return;
    }
    _violations.add('${_nameOf(name)} is not allowed');
  }

  ChartRecording finish(Size size) {
    if (_clipStack.isNotEmpty) {
      _violations.add(
        'save/restore are not balanced (${_clipStack.length} left open)',
      );
    }
    // 위에서 가로채지 않은 그리기 호출(drawRRect · drawOval …)은 층 표에 없다.
    for (final RecordedInvocation recorded in invocations) {
      final Symbol name = recorded.invocation.memberName;
      if (_drawCallsOutsideTable.contains(name)) {
        _violations.add('${_nameOf(name)} is outside the layer table');
      }
    }
    return ChartRecording(
      size: size,
      contours: List<ProbeContour>.unmodifiable(_contours),
      fills: List<int>.unmodifiable(_fills),
      lines: List<ProbeLine>.unmodifiable(_lines),
      rects: List<ProbeRect>.unmodifiable(_rects),
      circles: List<ProbeCircle>.unmodifiable(_circles),
      violations: List<String>.unmodifiable(_violations),
    );
  }

  static String _nameOf(Symbol name) {
    // Symbol("clipRect") → clipRect
    final String text = name.toString();
    final int open = text.indexOf('"');
    final int close = text.lastIndexOf('"');
    return open >= 0 && close > open ? text.substring(open + 1, close) : text;
  }
}
