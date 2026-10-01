// packages/ui_analytics/lib/src/goal_path/goal_path_chart.dart
//
// S7-9 목표 경로 차트 상자(계약 v1.4 · 01 §14 · 설계 D12). 높이 220 고정 · 가로는 부모 전체.
//
//   SizedBox(높이 220) → Padding(위아래 12)
//     → Row[ 눈금 글자 열(폭 56 · Stack) , 빈칸(폭 8) , 그림(CustomPaint · 남은 폭 전부) ]
//
// 🔵 S7-2 의 PerfChart 와 같은 짜임이다. Key 접두만 다르다(`'s79-chart'` · `'s79-tick-$i'`).
// 🔴 받는 것은 경로 하나뿐이다. 콜백·선택 상태·제스처가 없다(숫자는 값 표가 말한다).
// 🔴 `chartUnavailableLabel != null` 인 경로는 이 상자를 띄우지 않는다 — 화면이 그 문장 카드를
//    대신 둔다(C-39 ③). 이 상자는 상태를 고르지 않는다.
// 🔴 눈금 글자는 그림 **왼쪽 바깥 열**에 둔다 — 글자가 선과 띠를 덮지 않는다
//    (두 선의 첫 점은 늘 왼쪽 아래 끝에 온다).
// 🔴 눈금 글자의 자리는 엔진이 준 정규값을 Align 에 그대로 넘긴다 — 글자 높이로 셈하지 않는다.
//    가로는 열의 오른쪽 끝에 붙인다(그림 쪽).
// 🔴 그림 영역 = CustomPaint 의 크기 전체다. 그림 안쪽에는 여백도 글자도 없다.
// 🔴 색은 Theme.of(context).colorScheme 에서만 뽑는다.
// 🔵 그림의 왼쪽 변은 상자 왼쪽에서 [plotInsetLeft] 만큼 들어간 자리다 — 차트 아래 x 양 끝 글자 줄이
//    이 값만큼 왼쪽을 띄워 그림과 줄을 맞춘다.
//
// 본보기 원본 = packages/ui_analytics/test/golden/reference/goal_path/ (M2 소유).
// 이 파일은 그 원본을 글자 그대로 옮긴 것이다 — 고칠 일이 생기면 질문 표에 적는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import 'goal_path_chart_painter.dart';

class GoalPathChart extends StatelessWidget {
  const GoalPathChart({super.key, required this.path});

  /// 눈금 글자 열의 폭.
  static const double tickColumnWidth = 56;

  /// 눈금 글자 열과 그림 사이 빈칸.
  static const double tickColumnGap = 8;

  /// 상자 왼쪽 끝에서 그림의 왼쪽 변까지(눈금 글자 열 + 빈칸).
  static const double plotInsetLeft = 64;

  final GoalPathVm path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ticks = path.yTicks;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: tickColumnWidth,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (var i = 0; i < ticks.length; i++)
                    Align(
                      alignment: FractionalOffset(1, 1 - ticks[i].normalized),
                      child: Text(
                        ticks[i].label,
                        key: ValueKey<String>('s79-tick-$i'),
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
            const SizedBox(width: tickColumnGap),
            Expanded(
              child: CustomPaint(
                key: const Key('s79-chart'),
                painter: GoalPathChartPainter(
                  path: path,
                  colors: GoalPathChartColors.fromScheme(colorScheme),
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
