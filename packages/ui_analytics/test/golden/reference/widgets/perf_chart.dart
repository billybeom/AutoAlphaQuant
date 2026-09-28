// packages/ui_analytics/lib/src/widgets/perf_chart.dart
//
// S7-2 차트 상자(계약 v1.3 · 01 §13-2). 높이 220 고정 · 가로는 부모 전체.
//
//   SizedBox(높이 220) → Padding(위아래 12)
//     → Row[ 눈금 글자 열(폭 56 · Stack) , 빈칸(폭 8) , 그림(CustomPaint · 남은 폭 전부) ]
//
// 🔴 받는 것은 시리즈 하나뿐이다. 콜백·선택 상태·제스처가 없다(숫자는 값 표가 말한다).
// 🔴 눈금 글자는 그림 **왼쪽 바깥 열**에 둔다 — 글자가 선과 띠를 덮지 않는다
//    (누적 시리즈의 첫 점은 늘 왼쪽 아래 끝에 온다).
// 🔴 눈금 글자의 자리는 엔진이 준 정규값을 Align 에 그대로 넘긴다 — 글자 높이로 셈하지 않는다.
//    가로는 열의 오른쪽 끝에 붙인다(그림 쪽).
// 🔴 그림 영역 = CustomPaint 의 크기 전체다. 그림 안쪽에는 여백도 글자도 없다.
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 56,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (var i = 0; i < ticks.length; i++)
                    Align(
                      alignment: FractionalOffset(1, 1 - ticks[i].normalized),
                      child: Text(
                        ticks[i].label,
                        key: ValueKey<String>('s72-tick-$i'),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomPaint(
                key: const Key('s72-chart'),
                painter: PerfChartPainter(
                  series: series,
                  colors: PerfChartColors.fromScheme(colorScheme),
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
