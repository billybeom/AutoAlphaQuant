// packages/ui_analytics/lib/src/chart/perf_chart_painter.dart
//
// S7-2 차트를 그리는 painter(계약 v1.3 · 01 §13-2). 층·색·굵기는 아래 표로 **고정**이다.
// 테스트 하네스(test/golden/chart_probe.dart)가 이 표로 층을 가른다.
//
//   층(아래 → 위)                   방식                          색                        굵기
//   띠 채움(unavailable·simExcluded) drawRect 채움                 surfaceContainerHighest   —
//   빗금(unavailable)               띠 clipRect 안 drawLine 45°    outline                   1.5 (간격 8)
//   띠 경계                         세로 drawLine · 양 끝 1개씩     outline                   2
//                                   (simExcluded = 점선 6·4 / manualExecuted = 실선)
//   눈금선                          가로 drawLine                  outlineVariant            1
//                                   (기준선은 outline · 2)
//   벤치마크                        drawPath 획 · 점선 6·4          tertiary                  2
//   본선                            drawPath 획 · 둥근 끝·이음      primary                   3
//                                   (점 1개짜리 범위는 drawCircle 반지름 3)
//
// 🔴 그림 영역 = 받은 크기 전체다(안쪽 여백 없음). 바깥 여백은 위젯(PerfChart)이 준다.
// 🔴 직선만 긋는다. 곡선·보간·0 대입을 하지 않는다. 결측에서 선을 끊는다(C-10).
// 🔴 여기서 글자를 그리지 않는다 — 글자는 전부 Text 위젯이다.
// 🔴 색은 밖에서 받는다(PerfChartColors). 값의 부호·크기로 색을 고르지 않는다.
//
// 본보기 원본 = packages/ui_analytics/test/golden/reference/chart/ (M2 소유).
// 이 파일은 그 원본을 글자 그대로 옮긴 것이다 — 고칠 일이 생기면 질문 표에 적는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import 'perf_chart_geometry.dart';

/// 차트가 쓰는 색 묶음. 전부 `ColorScheme` 에서 뽑는다.
@immutable
class PerfChartColors {
  const PerfChartColors({
    required this.line,
    required this.benchmark,
    required this.bandFill,
    required this.strong,
    required this.soft,
  });

  /// [scheme] 에서 다섯 색을 뽑는다.
  PerfChartColors.fromScheme(ColorScheme scheme)
    : line = scheme.primary,
      benchmark = scheme.tertiary,
      bandFill = scheme.surfaceContainerHighest,
      strong = scheme.outline,
      soft = scheme.outlineVariant;

  /// 본선.
  final Color line;

  /// 벤치마크(점선).
  final Color benchmark;

  /// 띠 채움.
  final Color bandFill;

  /// 빗금 · 띠 경계 · 기준선.
  final Color strong;

  /// 기준선이 아닌 눈금선.
  final Color soft;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerfChartColors &&
          other.line == line &&
          other.benchmark == benchmark &&
          other.bandFill == bandFill &&
          other.strong == strong &&
          other.soft == soft;

  @override
  int get hashCode => Object.hash(line, benchmark, bandFill, strong, soft);
}

/// 점선의 그리는 길이.
const double _dash = 6;

/// 점선의 띄우는 길이.
const double _gap = 4;

/// 빗금 사이의 가로 간격.
const double _hatchStep = 8;

/// 점 1개짜리 범위를 찍는 원의 반지름.
const double _dotRadius = 3;

class PerfChartPainter extends CustomPainter {
  const PerfChartPainter({required this.series, required this.colors});

  final PerformanceSeries series;
  final PerfChartColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final plot = Offset.zero & size;
    _paintBands(canvas, plot);
    _paintBandEdges(canvas, plot);
    _paintTickLines(canvas, plot);
    final benchmark = series.benchmark;
    if (benchmark != null) {
      _paintBenchmark(canvas, benchmark.points, plot);
    }
    _paintMainLine(canvas, series.points, plot);
  }

  // ── 띠 채움 + 빗금 ──────────────────────────────────────────────────────
  void _paintBands(Canvas canvas, Rect plot) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.bandFill;
    final hatch = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.strong
      ..strokeWidth = 1.5;
    for (final seg in series.segments) {
      final band = bandOf(seg, plot);
      if (band.isEmpty) {
        continue;
      }
      switch (seg.kind) {
        case SegmentKind.measured:
          break;
        case SegmentKind.unavailable:
          canvas.drawRect(band, fill);
          _paintHatch(canvas, band, hatch);
        case SegmentKind.simExcluded:
          canvas.drawRect(band, fill);
        case SegmentKind.manualExecuted:
          break;
      }
    }
  }

  void _paintHatch(Canvas canvas, Rect band, Paint hatch) {
    canvas.save();
    canvas.clipRect(band);
    for (var at = band.left - band.height; at < band.right; at += _hatchStep) {
      canvas.drawLine(
        Offset(at, band.bottom),
        Offset(at + band.height, band.top),
        hatch,
      );
    }
    canvas.restore();
  }

  // ── 띠 경계 ─────────────────────────────────────────────────────────────
  void _paintBandEdges(Canvas canvas, Rect plot) {
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.strong
      ..strokeWidth = 2;
    for (final seg in series.segments) {
      final band = bandOf(seg, plot);
      switch (seg.kind) {
        case SegmentKind.measured:
          break;
        case SegmentKind.unavailable:
          break;
        case SegmentKind.simExcluded:
          _paintDashedEdge(canvas, band.left, plot, edge);
          _paintDashedEdge(canvas, band.right, plot, edge);
        case SegmentKind.manualExecuted:
          _paintSolidEdge(canvas, band.left, plot, edge);
          _paintSolidEdge(canvas, band.right, plot, edge);
      }
    }
  }

  void _paintSolidEdge(Canvas canvas, double x, Rect plot, Paint edge) {
    canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), edge);
  }

  void _paintDashedEdge(Canvas canvas, double x, Rect plot, Paint edge) {
    for (var at = plot.top; at < plot.bottom; at += _dash + _gap) {
      final until = at + _dash;
      canvas.drawLine(
        Offset(x, at),
        Offset(x, until < plot.bottom ? until : plot.bottom),
        edge,
      );
    }
  }

  // ── 눈금선 ──────────────────────────────────────────────────────────────
  void _paintTickLines(Canvas canvas, Rect plot) {
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.soft
      ..strokeWidth = 1;
    final strong = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.strong
      ..strokeWidth = 2;
    for (final tick in series.yTicks) {
      final y = yOf(tick.normalized, plot);
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        tick.isBaseline ? strong : soft,
      );
    }
  }

  // ── 벤치마크(점선) ──────────────────────────────────────────────────────
  void _paintBenchmark(Canvas canvas, List<PerfPoint> points, Rect plot) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.benchmark
      ..strokeWidth = 2;
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.benchmark;
    for (final run in splitRuns(points)) {
      if (run.start == run.end) {
        canvas.drawCircle(_spot(points[run.start], plot), _dotRadius, dot);
        continue;
      }
      canvas.drawPath(_dashed(_lineOf(points, run, plot)), stroke);
    }
  }

  // ── 본선 ────────────────────────────────────────────────────────────────
  void _paintMainLine(Canvas canvas, List<PerfPoint> points, Rect plot) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.line
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.line;
    for (final run in splitRuns(points)) {
      if (run.start == run.end) {
        canvas.drawCircle(_spot(points[run.start], plot), _dotRadius, dot);
        continue;
      }
      canvas.drawPath(_lineOf(points, run, plot), stroke);
    }
  }

  /// 값이 있는 점 1개의 자리. 🔴 [splitRuns] 가 고른 범위 안의 점에만 부른다.
  Offset _spot(PerfPoint point, Rect plot) =>
      Offset(xOf(point.xNormalized, plot), yOf(point.yNormalized!, plot));

  /// 범위 하나 = 윤곽 하나. 직선으로만 잇는다.
  Path _lineOf(List<PerfPoint> points, IndexRun run, Rect plot) {
    final first = _spot(points[run.start], plot);
    final path = Path()..moveTo(first.dx, first.dy);
    for (var i = run.start + 1; i <= run.end; i++) {
      final next = _spot(points[i], plot);
      path.lineTo(next.dx, next.dy);
    }
    return path;
  }

  /// [source] 를 따라 6 그리고 4 띄운 점선 윤곽들.
  Path _dashed(Path source) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        final until = at + _dash;
        out.addPath(
          metric.extractPath(at, until < metric.length ? until : metric.length),
          Offset.zero,
        );
        at = until + _gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(PerfChartPainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.colors != colors;
}
