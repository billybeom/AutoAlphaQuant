// packages/ui_analytics/lib/src/widgets/perf_chart.dart
//
// S7-2 차트 상자(계약 v1.3 · 01 §13-2). 높이 220 고정 · 가로는 부모 전체.
//
//   SizedBox(높이 220) → Padding(위아래 12) → Stack[ 그림(CustomPaint) , 눈금 글자 … ]
//
// 🔴 받는 것은 시리즈 하나뿐이다. 콜백·선택 상태·제스처가 없다(숫자는 값 표가 말한다).
// 🔴 눈금 글자의 자리는 엔진이 준 정규값을 Align 에 그대로 넘긴다 — 글자 높이로 셈하지 않는다.
// 🔴 색은 Theme.of(context).colorScheme 에서만 뽑는다.
//
// 본보기 원본 = packages/ui_analytics/test/golden/reference/widgets/ (M2 소유).
// 이 파일은 그 원본을 글자 그대로 옮긴 것이다 — 고칠 일이 생기면 질문 표에 적는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import '../chart/perf_chart_painter.dart';

class PerfChart extends StatelessWidget {
  const PerfChart({super.key, required this.series});

  final PerformanceSeries series;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ticks = series.yTicks;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              key: const Key('s72-chart'),
              painter: PerfChartPainter(
                series: series,
                colors: PerfChartColors.fromScheme(colorScheme),
              ),
              size: Size.infinite,
            ),
            for (var i = 0; i < ticks.length; i++)
              Align(
                alignment: FractionalOffset(0, 1 - ticks[i].normalized),
                child: Text(
                  ticks[i].label,
                  key: ValueKey<String>('s72-tick-$i'),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
