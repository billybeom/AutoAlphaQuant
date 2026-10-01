// packages/ui_analytics/lib/src/goal_path/goal_path_chart_painter.dart
//
// S7-9 목표 경로 차트를 그리는 painter(계약 v1.4 · 01 §14 · 설계 D12). 층·색·굵기는 아래 표로
// **고정**이다. 테스트 하네스(test/golden/chart_probe.dart 의 expectGoalPathMatches)가 이 표로 층을 가른다.
//
//   층(아래 → 위)                   방식                          색                        굵기
//   띠 채움(unavailable·simExcluded) drawRect 채움                 surfaceContainerHighest   —
//   빗금(unavailable)               띠 clipRect 안 drawLine 45°    outline                   1.5 (간격 8)
//   띠 경계                         세로 drawLine · 양 끝 1개씩     outline                   2
//                                   (simExcluded = 점선 6·4 / manualExecuted = 실선)
//   눈금선                          가로 drawLine                  outlineVariant            1
//                                   (기준선은 outline · 2)
//   계획선(planned)                 drawPath 획 · 점선 6·4          tertiary                  2
//   실제선(actual)                  drawPath 획 · 둥근 끝·이음      primary                   3
//                                   (점 1개짜리 범위는 drawCircle 반지름 3)
//
// 🔵 S7-2 차트(01 §13-2)와 같은 층 표다 — 벤치마크 자리에 계획선이, 본선 자리에 실제선이 온다.
// 🔴 받는 것은 경로 하나(GoalPathVm)뿐이다. 두 목록(planned · actual)을 **따로** 그린다 —
//    계열을 문자열로 가르지 않는다.
// 🔴 그림 영역 = 받은 크기 전체다(안쪽 여백 없음). 바깥 여백은 위젯(GoalPathChart)이 준다.
// 🔴 직선만 긋는다. 곡선·보간·0 대입을 하지 않는다. 결측(yNormalized == null)에서 선을 끊는다(C-10).
// 🔴 여기서 글자를 그리지 않는다 — 글자는 전부 Text 위젯이다.
// 🔴 색은 밖에서 받는다(GoalPathChartColors). 값의 부호·크기·판정으로 색을 고르지 않는다.
// 🔴 점의 원시 값과 구간의 날짜는 읽지 않는다 — 자리는 전부 엔진이 준 정규값이다.
//
// 본보기 원본 = packages/ui_analytics/test/golden/reference/goal_path/ (M2 소유).
// 이 파일은 그 원본을 글자 그대로 옮긴 것이다 — 고칠 일이 생기면 질문 표에 적는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import '../chart/perf_chart_geometry.dart';

/// 목표 경로 차트가 쓰는 색 묶음. 전부 `ColorScheme` 에서 뽑는다.
@immutable
class GoalPathChartColors {
  const GoalPathChartColors({
    required this.actual,
    required this.planned,
    required this.bandFill,
    required this.strong,
    required this.soft,
  });

  /// [scheme] 에서 다섯 색을 뽑는다.
  GoalPathChartColors.fromScheme(ColorScheme scheme)
    : actual = scheme.primary,
      planned = scheme.tertiary,
      bandFill = scheme.surfaceContainerHighest,
      strong = scheme.outline,
      soft = scheme.outlineVariant;

  /// 실제선.
  final Color actual;

  /// 계획선(점선).
  final Color planned;

  /// 띠 채움.
  final Color bandFill;

  /// 빗금 · 띠 경계 · 기준선.
  final Color strong;

  /// 기준선이 아닌 눈금선.
  final Color soft;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalPathChartColors &&
          other.actual == actual &&
          other.planned == planned &&
          other.bandFill == bandFill &&
          other.strong == strong &&
          other.soft == soft;

  @override
  int get hashCode => Object.hash(actual, planned, bandFill, strong, soft);
}

/// 점선의 그리는 길이.
const double _dash = 6;

/// 점선의 띄우는 길이.
const double _gap = 4;

/// 빗금 사이의 가로 간격.
const double _hatchStep = 8;

/// 점 1개짜리 범위를 찍는 원의 반지름.
const double _dotRadius = 3;

class GoalPathChartPainter extends CustomPainter {
  const GoalPathChartPainter({required this.path, required this.colors});

  final GoalPathVm path;
  final GoalPathChartColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final plot = Offset.zero & size;
    _paintBands(canvas, plot);
    _paintBandEdges(canvas, plot);
    _paintTickLines(canvas, plot);
    _paintPlanned(canvas, path.planned, plot);
    _paintActual(canvas, path.actual, plot);
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
    for (final seg in path.segments) {
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
    for (final seg in path.segments) {
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
    for (final tick in path.yTicks) {
      final y = yOf(tick.normalized, plot);
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        tick.isBaseline ? strong : soft,
      );
    }
  }

  // ── 계획선(점선) ────────────────────────────────────────────────────────
  void _paintPlanned(Canvas canvas, List<PerfPoint> points, Rect plot) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.planned
      ..strokeWidth = 2;
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.planned;
    for (final run in splitRuns(points)) {
      if (run.start == run.end) {
        canvas.drawCircle(_spot(points[run.start], plot), _dotRadius, dot);
        continue;
      }
      canvas.drawPath(_dashed(_lineOf(points, run, plot)), stroke);
    }
  }

  // ── 실제선 ──────────────────────────────────────────────────────────────
  void _paintActual(Canvas canvas, List<PerfPoint> points, Rect plot) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = colors.actual
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.actual;
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
    final line = Path()..moveTo(first.dx, first.dy);
    for (var i = run.start + 1; i <= run.end; i++) {
      final next = _spot(points[i], plot);
      line.lineTo(next.dx, next.dy);
    }
    return line;
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
  bool shouldRepaint(GoalPathChartPainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.colors != colors;
}
