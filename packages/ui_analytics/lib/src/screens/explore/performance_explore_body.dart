// lib/src/screens/explore/performance_explore_body.dart
// S7-2 수익률 탐색 본문 껍데기 — 기록 줄 + watchCommand 구독 + series 호출까지.
// 🔵 R10b 병합 뒤 탐색 본문은 값이 와도 AnalyticsSkeleton(blocks: 3) 이다
//    (라우트·진입점이 아직 없어 사용자에게 보이지 않는다).
// R10c 가 이 파일을 채운다: 기록 줄·구독·series watch 는 그대로 두고 나머지를 더한다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/analytics_providers.dart';
import '../../widgets/analytics_error_view.dart';
import '../../widgets/analytics_skeleton.dart';

/// S7-2 수익률 탐색 본문. 생성자 인자: [receipt] — 게이트를 통과한 접수증.
class PerformanceExploreBody extends ConsumerStatefulWidget {
  const PerformanceExploreBody({super.key, required this.receipt});

  final CommandReceipt receipt;

  @override
  ConsumerState<PerformanceExploreBody> createState() =>
      _PerformanceExploreBodyState();
}

class _PerformanceExploreBodyState
    extends ConsumerState<PerformanceExploreBody> {
  // ── 상태 ─────────────────────────────────────────────────────────────────

  /// 첫 요청: 시간가중·월·누적 (R10b 에서 바뀌지 않아 final)
  final PerfSeriesQuery _query = (
    metric: PerfMetric.twr,
    granularity: PerfGranularity.monthly,
    cumulative: true,
  );

  /// watchCommand 구독으로 갱신되는 기록 줄 접수증
  late CommandReceipt _shown;

  StreamSubscription<CommandReceipt>? _subscription;

  // ── 생명 주기 ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _shown = widget.receipt;
    // 기록 줄 구독 — StreamProvider 로 감싸지 않는다(에러가 삼켜진다 · 01 §4-2)
    _subscription = ref
        .read(analyticsCommandApiProvider)
        .watchCommand(widget.receipt.commandId)
        .listen(
          (next) {
            if (mounted) setState(() => _shown = next);
          },
          onError: (Object error, StackTrace stack) {
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stack,
                library: 'ui_analytics',
              ),
            );
            // 에러 시 마지막 _shown 유지
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ── 빌드 ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(performanceSeriesProvider(_query));

    return Column(
      children: <Widget>[
        // 기록 줄 — 항상 표시 · 상태로 고르지 않는다
        Text(_shown.stateLabel, key: const Key('s72-record-line')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              seriesAsync.when(
                loading: () => const AnalyticsSkeleton(blocks: 3),
                error: (_, __) => AnalyticsErrorView(
                  onRetry: () =>
                      ref.invalidate(performanceSeriesProvider(_query)),
                  lastAsOfLabel: null,
                ),
                // 값이 와도 스켈레톤 — R10c 가 채운다
                data: (_) => const AnalyticsSkeleton(blocks: 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
