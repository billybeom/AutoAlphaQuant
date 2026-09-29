// lib/src/screens/explore/performance_explore_body.dart
// S7-2 수익률 탐색 본문 — 토글 · 차트 · 글자 · 캡션 · 고지 · 값 표 · 불가 카드 · 이동 버튼.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/labels.dart';
import '../../providers/analytics_providers.dart';
import '../../widgets/analytics_error_view.dart';
import '../../widgets/analytics_skeleton.dart';
import '../../widgets/perf_chart.dart';
import '../../widgets/safety_block_banner.dart';
import '../../widgets/stale_banner.dart';

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

  /// 첫 요청: 시간가중·월·누적
  PerfSeriesQuery _query = (
    metric: PerfMetric.twr,
    granularity: PerfGranularity.monthly,
    cumulative: true,
  );

  /// 값 표 접힘/펼침 상태 (기본값 = 접힘)
  bool _valuesOpen = false;

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
    final safetyAsync = ref.watch(safetyStateStreamProvider);
    final activeFlags =
        safetyAsync.valueOrNull?.activeFlags ?? const <BlockFlag>[];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        // 0 기록 줄 — 항상 표시 · 상태로 고르지 않는다
        Text(_shown.stateLabel, key: const Key('s72-record-line')),

        // 1 SafetyBlockBanner (있을 때) — 시리즈 로딩/에러와 무관하게 안전 상태에서 옴
        if (activeFlags.isNotEmpty)
          SafetyBlockBanner(
            activeFlags: activeFlags,
            onOpenLink: (link) =>
                ref.read(analyticsLinkOpenerProvider).open(link),
          ),

        // ── 이하 Expanded(ListView(padding 16)[ … ]) ──
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // 2 토글 3줄
              // 지표 토글: 시간가중 · 금액가중
              SegmentedButton<PerfMetric>(
                key: const Key('s72-toggle-metric'),
                showSelectedIcon: false,
                segments: const <ButtonSegment<PerfMetric>>[
                  ButtonSegment<PerfMetric>(
                    value: PerfMetric.twr,
                    label: Text(AnalyticsLabels.metricTwr),
                  ),
                  ButtonSegment<PerfMetric>(
                    value: PerfMetric.mwr,
                    label: Text(AnalyticsLabels.metricMwr),
                  ),
                ],
                selected: <PerfMetric>{_query.metric},
                onSelectionChanged: (Set<PerfMetric> next) {
                  if (next.isNotEmpty) {
                    setState(
                      () => _query = (
                        metric: next.first,
                        granularity: _query.granularity,
                        cumulative: _query.cumulative,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),

              // 주기 토글: 일 · 월 · 년 (주간 없음)
              SegmentedButton<PerfGranularity>(
                key: const Key('s72-toggle-granularity'),
                showSelectedIcon: false,
                segments: const <ButtonSegment<PerfGranularity>>[
                  ButtonSegment<PerfGranularity>(
                    value: PerfGranularity.daily,
                    label: Text(AnalyticsLabels.granularityDaily),
                  ),
                  ButtonSegment<PerfGranularity>(
                    value: PerfGranularity.monthly,
                    label: Text(AnalyticsLabels.granularityMonthly),
                  ),
                  ButtonSegment<PerfGranularity>(
                    value: PerfGranularity.yearly,
                    label: Text(AnalyticsLabels.granularityYearly),
                  ),
                ],
                selected: <PerfGranularity>{_query.granularity},
                onSelectionChanged: (Set<PerfGranularity> next) {
                  if (next.isNotEmpty) {
                    setState(
                      () => _query = (
                        metric: _query.metric,
                        granularity: next.first,
                        cumulative: _query.cumulative,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),

              // 누적 토글: 누적 · 기간별
              SegmentedButton<bool>(
                key: const Key('s72-toggle-cumulative'),
                showSelectedIcon: false,
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(AnalyticsLabels.cumulativeOn),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(AnalyticsLabels.cumulativeOff),
                  ),
                ],
                selected: <bool>{_query.cumulative},
                onSelectionChanged: (Set<bool> next) {
                  if (next.isNotEmpty) {
                    setState(
                      () => _query = (
                        metric: _query.metric,
                        granularity: _query.granularity,
                        cumulative: next.first,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3 series 로딩 / 에러 / 데이터 갈래
              ...seriesAsync.when(
                loading: () => const <Widget>[AnalyticsSkeleton(blocks: 3)],
                error: (_, __) => <Widget>[
                  AnalyticsErrorView(
                    onRetry: () =>
                        ref.invalidate(performanceSeriesProvider(_query)),
                    lastAsOfLabel: null,
                  ),
                ],
                data: (PerformanceSeries series) {
                  final benchmark = series.benchmark;
                  final unavailableLabel = series.unavailableLabel;

                  return <Widget>[
                    // 4 StaleBanner
                    StaleBanner(asOf: series.asOf),

                    // 5 Text(asOf.label) · Text(periodLabel)
                    Text(series.asOf.label, key: const Key('s72-asof')),
                    Text(series.periodLabel, key: const Key('s72-period')),
                    const SizedBox(height: 16),

                    if (unavailableLabel != null) ...<Widget>[
                      // 불가 카드
                      Text(
                        unavailableLabel,
                        key: const Key('s72-unavailable'),
                      ),
                    ] else ...<Widget>[
                      // 6 PerfChart
                      PerfChart(series: series),

                      // 7 x 양 끝 글자
                      Padding(
                        padding: const EdgeInsets.only(
                          left: PerfChart.plotInsetLeft,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                series.points.first.dateText,
                                key: const Key('s72-x-first'),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                series.points.last.dateText,
                                key: const Key('s72-x-last'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 8 범례
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 24,
                            height: 3,
                            child: ColoredBox(color: colorScheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              series.seriesLabel,
                              key: const Key('s72-legend-main'),
                            ),
                          ),
                        ],
                      ),
                      if (benchmark != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 6,
                                  height: 2,
                                  child: ColoredBox(
                                    color: colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 6,
                                  height: 2,
                                  child: ColoredBox(
                                    color: colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 6,
                                  height: 2,
                                  child: ColoredBox(
                                    color: colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                benchmark.label,
                                key: const Key('s72-legend-benchmark'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 9 구간 캡션 (kind != SegmentKind.measured 인 구간만)
                      for (var i = 0; i < series.segments.length; i++)
                        if (series.segments[i].kind != SegmentKind.measured)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              series.segments[i].label,
                              key: ValueKey<String>('s72-segment-caption-$i'),
                            ),
                          ),

                      // 11 (benchmark != null) Text(benchmark.compositionNote)
                      if (benchmark != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          benchmark.compositionNote,
                          key: const Key('s72-benchmark-note'),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 12 「값 보기」/「값 접기」 TextButton + (펴졌을 때) 값 표
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          key: const Key('s72-values-toggle'),
                          onPressed: () {
                            setState(() => _valuesOpen = !_valuesOpen);
                          },
                          child: Text(
                            _valuesOpen
                                ? AnalyticsLabels.valuesHideButton
                                : AnalyticsLabels.valuesShowButton,
                          ),
                        ),
                      ),
                      if (_valuesOpen) ...<Widget>[
                        const SizedBox(height: 8),
                        Column(
                          key: const Key('s72-values-table'),
                          children: <Widget>[
                            // 머리 1줄
                            Row(
                              children: <Widget>[
                                const Expanded(child: SizedBox.shrink()),
                                const SizedBox(
                                  width: 88,
                                  child: Text(
                                    AnalyticsLabels.valuesColumnMain,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                if (benchmark != null)
                                  const SizedBox(
                                    width: 88,
                                    child: Text(
                                      AnalyticsLabels.valuesColumnBenchmark,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(),
                            // 점마다 1줄
                            for (var i = 0; i < series.points.length; i++)
                              Row(
                                key: ValueKey<String>('s72-value-row-$i'),
                                children: <Widget>[
                                  Expanded(
                                    child: Text(series.points[i].dateText),
                                  ),
                                  SizedBox(
                                    width: 88,
                                    child: Text(
                                      series.points[i].valueText,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  if (benchmark != null)
                                    SizedBox(
                                      width: 88,
                                      child: Text(
                                        benchmark.points[i].valueText,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),

                    // 10 고지 카드
                    Card(
                      key: const Key('s72-disclosure'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(series.disclosure.sampleSizeLine),
                            const SizedBox(height: 4),
                            Text(series.disclosure.honestExpectationLine),
                            if (series.disclosure.drawdownCaveatLine != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(series.disclosure.drawdownCaveatLine!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 13 이동 버튼 2개 (세로로 쌓음 · 각 전체 폭)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: const Key('s72-link-drawdown'),
                        onPressed: () => ref
                            .read(analyticsLinkOpenerProvider)
                            .open(AppRoutes.performanceDrawdown),
                        child: const Text(AnalyticsLabels.drawdownLinkButton),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: const Key('s72-link-contribution'),
                        onPressed: () => ref
                            .read(analyticsLinkOpenerProvider)
                            .open(AppRoutes.performanceContribution),
                        child: const Text(
                          AnalyticsLabels.contributionLinkButton,
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
