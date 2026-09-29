// packages/ui_analytics/lib/src/widgets/analytics_skeleton.dart

import 'package:flutter/material.dart';

/// 로딩 상태 스켈레톤 — 회색 상자 [blocks] 개를 Column 으로 쌓는다.
/// 🔴 스크롤 없음(ListView 안에 들어간다).
/// 🔴 R10b·R10c 가 blocks: 2·3 으로 부른다 — 생성자 모양을 바꾸지 않는다.
class AnalyticsSkeleton extends StatelessWidget {
  const AnalyticsSkeleton({super.key, this.blocks = 4});

  final int blocks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < blocks; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
      ],
    );
  }
}
