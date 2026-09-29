// packages/ui_analytics/lib/src/chart/perf_chart_geometry.dart
//
// S7-2 차트의 순수 기하 함수(계약 v1.3 · 01 §13-2). 위젯·BuildContext·색을 모른다.
//
// 🔴 입력은 엔진이 준 0.0~1.0 정규값뿐이다. 여기서 하는 산술은 «정규값 × 폭·높이» 하나다.
//    최솟값·최댓값·합·차·평균을 구하지 않는다. 정규값을 글자로 바꾸지 않는다.
// 🔴 점의 원시 값과 구간의 날짜는 읽지 않는다 — 자리는 전부 정규값으로 온다.
//
// 본보기 원본 = packages/ui_analytics/test/golden/reference/chart/ (M2 소유).
// 이 파일은 그 원본을 글자 그대로 옮긴 것이다 — 고칠 일이 생기면 질문 표에 적는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/rendering.dart';

/// 값이 끊기지 않고 이어지는 점 순번의 범위(양 끝 포함).
typedef IndexRun = ({int start, int end});

/// [points] 를 «값이 있는 점이 이어진 범위»로 나눈다.
///
/// `yNormalized == null`(결측)에서 끊는다 — 결측을 건너뛰어 잇지 않는다(C-10).
/// 점이 없거나 전부 결측이면 빈 목록이다.
List<IndexRun> splitRuns(List<PerfPoint> points) {
  final runs = <IndexRun>[];
  int? open;
  for (var i = 0; i < points.length; i++) {
    final has = points[i].yNormalized != null;
    if (has && open == null) {
      open = i;
    }
    if (!has && open != null) {
      runs.add((start: open, end: i - 1));
      open = null;
    }
  }
  if (open != null) {
    runs.add((start: open, end: points.length - 1));
  }
  return runs;
}

/// 가로 자리. 0.0 = [plot] 의 왼쪽 끝 · 1.0 = 오른쪽 끝. 범위 밖 값은 끝에 붙인다.
double xOf(double xNormalized, Rect plot) =>
    plot.left + xNormalized.clamp(0.0, 1.0) * plot.width;

/// 세로 자리. 0.0 = [plot] 의 아래 끝 · 1.0 = 위 끝. 범위 밖 값은 끝에 붙인다.
double yOf(double yNormalized, Rect plot) =>
    plot.bottom - yNormalized.clamp(0.0, 1.0) * plot.height;

/// 구간의 띠. 가로는 엔진이 준 시작·끝 정규값 그대로이고 세로는 [plot] 전체다.
Rect bandOf(PerfSegment seg, Rect plot) => Rect.fromLTRB(
  xOf(seg.startNormalized, plot),
  plot.top,
  xOf(seg.endNormalized, plot),
  plot.bottom,
);
