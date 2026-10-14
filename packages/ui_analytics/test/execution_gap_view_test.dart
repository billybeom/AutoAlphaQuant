import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/src/widgets/trust_badge_view.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'execution_gap_fakes.dart';
import 'golden/golden_support.dart';

void main() {
  final ExecutionGapResult cant = singleFixture(
    FixturePaths.m7ExecutionGapCant,
    ExecutionGapResult.fromJson,
  );
  final ExecutionGapResult wont = singleFixture(
    FixturePaths.m7ExecutionGapWont,
    ExecutionGapResult.fromJson,
  );
  final ExecutionGapResult mixed = singleFixture(
    FixturePaths.m7ExecutionGapMixed,
    ExecutionGapResult.fromJson,
  );
  final ExecutionGapResult gap1 = singleFixture(
    FixturePaths.m7ExecutionGap1,
    ExecutionGapResult.fromJson,
  );
  final ExecutionGapResult maskedRecon = singleFixture(
    FixturePaths.m7ExecutionGapMaskedRecon,
    ExecutionGapResult.fromJson,
  );
  final ExecutionGapResult empty = singleFixture(
    FixturePaths.m7ExecutionGapEmpty,
    ExecutionGapResult.fromJson,
  );
  final ExecutionGapResult notApplicable = singleFixture(
    FixturePaths.m7ExecutionGapNotApplicable,
    ExecutionGapResult.fromJson,
  );
  final String monthFixture = singleFixture(
    FixturePaths.m7M7Monthly202608,
    MonthlyReport.fromJson,
  ).yyyyMm;

  final SafetyState safety0 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[0],
  );
  final SafetyState safety1 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[1],
  );
  final SafetyState safety3 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[3],
  );
  final SafetyState safety4 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[4],
  );

  // ── T710-01 ────────────────────────────────────────────────────────────────
  testWidgets('T710-01 default yyyyMm call', (WidgetTester tester) async {
    final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
      result: gap1,
    );
    await pumpExecutionGap(tester, repo: repo);
    await tester.pump();

    expect(repo.monthlyCalls, hasLength(1));
    expect(repo.monthlyCalls, <String?>[null]);
    expect(find.byKey(const Key('s710-root')), findsOneWidget);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  // ── T710-02 ────────────────────────────────────────────────────────────────
  testWidgets('T710-02 given yyyyMm call', (WidgetTester tester) async {
    final String m = monthFixture;
    final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
      result: gap1,
    );
    await pumpExecutionGap(tester, repo: repo, yyyyMm: m);
    await tester.pump();

    expect(repo.monthlyCalls, hasLength(1));
    expect(repo.monthlyCalls, <String?>[m]);
    expect(find.text(m), findsNothing);
    expect(find.byKey(const Key('s710-root')), findsOneWidget);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  // ── T710-03 ────────────────────────────────────────────────────────────────
  for (final (
        String caseName,
        ExecutionGapResult result,
        Clock clock,
        SafetyState safety,
        bool isStale,
      )
      in <(String, ExecutionGapResult, Clock, SafetyState, bool)>[
        ('wont', wont, FixedClock(kGoldenNowUtc), safety0, false),
        (
          'mixed',
          mixed,
          FixedClock(kGoldenNowUtc.add(const Duration(days: 3))),
          safety3,
          true,
        ),
        (
          'masked_recon',
          maskedRecon,
          FixedClock(kGoldenNowUtc),
          safety1,
          false,
        ),
      ]) {
    testWidgets('T710-03 layout chain $caseName', (WidgetTester tester) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(
        tester,
        repo: repo,
        safetyState: safety,
        clock: clock,
      );
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      final List<Finder> chain = <Finder>[];

      if (isStale) {
        chain.add(find.text(AnalyticsLabels.staleBannerTitle));
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }

      if (safety.activeFlags.isNotEmpty) {
        chain.add(find.text(safety.activeFlags.first.label));
      } else {
        expect(find.byIcon(Icons.block), findsNothing);
      }

      chain.add(find.text(report.periodLabel));
      chain.add(find.text(report.trust.label));

      if (report.complianceRateNormalized != null) {
        chain.add(find.byKey(const Key('s710-gauge')));
      } else {
        expect(find.byKey(const Key('s710-gauge')), findsNothing);
      }

      chain.add(find.text(report.complianceRateLabel));
      for (int i = 0; i < 3; i++) {
        chain.add(find.byKey(ValueKey<String>('s710-count-$i')));
      }
      chain.add(find.text(report.medianDelayLabel));
      chain.add(find.text(report.priceGapLabel));

      if (report.correctionLines.isNotEmpty) {
        for (int i = 0; i < report.correctionLines.length; i++) {
          chain.add(find.byKey(ValueKey<String>('s710-correction-$i')));
        }
      } else {
        expect(
          find.byKey(const ValueKey<String>('s710-correction-0')),
          findsNothing,
        );
      }

      chain.add(find.text(report.amendChainMaxLabel));

      if (report.skipReasonBuckets.isNotEmpty) {
        chain.add(find.text(AnalyticsLabels.executionGapSkipReasonsHeader));
        chain.add(
          find.widgetWithText(Chip, report.skipReasonBuckets.first.label),
        );
      } else {
        expect(
          find.text(AnalyticsLabels.executionGapSkipReasonsHeader),
          findsNothing,
        );
      }

      if (report.selectiveExecutionChips.isNotEmpty) {
        chain.add(
          find.widgetWithText(Chip, report.selectiveExecutionChips.first.label),
        );
      } else {
        expect(
          find.byType(Chip),
          findsNWidgets(report.skipReasonBuckets.length),
        );
      }

      if (report.modeAdviceLine != null) {
        chain.add(find.byKey(const Key('s710-advice')));
      } else {
        expect(find.byKey(const Key('s710-advice')), findsNothing);
      }

      chain.add(find.byKey(const Key('s710-asof')));

      for (final Finder f in chain) {
        expect(f, findsOneWidget);
      }
      for (int i = 0; i < chain.length - 1; i++) {
        expect(
          tester.getTopLeft(chain[i]).dy,
          lessThan(tester.getTopLeft(chain[i + 1]).dy),
        );
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-04 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('wont', wont),
        ('mixed', mixed),
        ('gap1', gap1),
        ('masked_recon', maskedRecon),
        ('empty', empty),
        ('not_applicable', notApplicable),
      ]) {
    testWidgets('T710-04 result branch $caseName', (WidgetTester tester) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      if (result.report != null) {
        final ExecutionGapReport report = result.report!;
        expect(find.byType(TrustBadgeView), findsOneWidget);
        expect(find.text(report.periodLabel), findsOneWidget);
        expect(find.byKey(const Key('s710-empty')), findsNothing);
      } else {
        expect(find.byKey(const Key('s710-empty')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('s710-empty'))).data,
          result.emptyLabel,
        );
        expect(find.byType(TrustBadgeView), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('s710-count-0')),
          findsNothing,
        );
        expect(find.byKey(const Key('s710-gauge')), findsNothing);
        expect(find.byKey(const Key('s710-advice')), findsNothing);
        expect(find.byType(Chip), findsNothing);
        expect(find.byType(Card), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(const Key('s710-empty'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const Key('s710-asof'))).dy),
        );
      }

      expect(find.byKey(const Key('s710-asof')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('s710-asof'))).data,
        result.asOf.label,
      );
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-05 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('wont', wont),
        ('mixed', mixed),
        ('gap1', gap1),
        ('masked_recon', maskedRecon),
      ]) {
    testWidgets('T710-05 count lines $caseName', (WidgetTester tester) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      expect(report.countLines, hasLength(3));

      for (int i = 0; i < 3; i++) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('s710-count-$i')))
              .data,
          report.countLines[i],
        );
      }
      for (int i = 0; i < 2; i++) {
        expect(
          tester.getTopLeft(find.byKey(ValueKey<String>('s710-count-$i'))).dy,
          lessThan(
            tester
                .getTopLeft(find.byKey(ValueKey<String>('s710-count-${i + 1}')))
                .dy,
          ),
        );
      }

      expect(find.byKey(const ValueKey<String>('s710-count-3')), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-06 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result, int correctionCount)
      in <(String, ExecutionGapResult, int)>[
        ('cant', cant, 2),
        ('wont', wont, 0),
        ('mixed', mixed, 2),
        ('gap1', gap1, 0),
        ('masked_recon', maskedRecon, 2),
      ]) {
    testWidgets('T710-06 correction lines $caseName', (
      WidgetTester tester,
    ) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      expect(report.correctionLines, hasLength(correctionCount));

      for (int i = 0; i < report.correctionLines.length; i++) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('s710-correction-$i')))
              .data,
          report.correctionLines[i],
        );
      }
      for (int i = 0; i < report.correctionLines.length - 1; i++) {
        expect(
          tester
              .getTopLeft(find.byKey(ValueKey<String>('s710-correction-$i')))
              .dy,
          lessThan(
            tester
                .getTopLeft(
                  find.byKey(ValueKey<String>('s710-correction-${i + 1}')),
                )
                .dy,
          ),
        );
      }

      expect(
        find.byKey(
          ValueKey<String>('s710-correction-${report.correctionLines.length}'),
        ),
        findsNothing,
      );
      expect(find.text(report.amendChainMaxLabel), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-07 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('wont', wont),
        ('mixed', mixed),
        ('gap1', gap1),
        ('masked_recon', maskedRecon),
      ]) {
    testWidgets('T710-07 gauge width and color $caseName', (
      WidgetTester tester,
    ) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      if (report.complianceRateNormalized != null) {
        final double normalized = report.complianceRateNormalized!;
        expect(find.byKey(const Key('s710-gauge')), findsOneWidget);
        final Finder filledBar = find
            .descendant(
              of: find.byKey(const Key('s710-gauge')),
              matching: find.byType(ColoredBox),
            )
            .last;
        final double filledWidth = tester.getSize(filledBar).width;
        final double totalWidth = tester
            .getSize(find.byKey(const Key('s710-gauge')))
            .width;
        expect(filledWidth / totalWidth, closeTo(normalized, 0.01));
        expect(
          tester.widget<ColoredBox>(filledBar).color,
          Theme.of(tester.element(find.byKey(const Key('s710-gauge'))))
              .colorScheme
              .primary,
        );
      } else {
        expect(find.byKey(const Key('s710-gauge')), findsNothing);
        expect(find.byType(FractionallySizedBox), findsNothing);
      }

      expect(find.text(report.complianceRateLabel), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-08 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('wont', wont),
        ('mixed', mixed),
        ('gap1', gap1),
      ]) {
    testWidgets('T710-08 advice line $caseName', (WidgetTester tester) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      if (report.modeAdviceLine != null) {
        expect(find.byKey(const Key('s710-advice')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('s710-advice'))).data,
          report.modeAdviceLine,
        );
        final String otherAdvice = caseName == 'cant'
            ? wont.report!.modeAdviceLine!
            : cant.report!.modeAdviceLine!;
        expect(find.text(otherAdvice), findsNothing);
        expect(
          find.ancestor(
            of: find.byKey(const Key('s710-advice')),
            matching: find.byWidgetPredicate(
              (Widget w) => w is ButtonStyleButton || w is InkWell,
            ),
          ),
          findsNothing,
        );
      } else {
        expect(find.byKey(const Key('s710-advice')), findsNothing);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-09 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('wont', wont),
        ('mixed', mixed),
        ('gap1', gap1),
        ('masked_recon', maskedRecon),
      ]) {
    testWidgets('T710-09 chips and header $caseName', (
      WidgetTester tester,
    ) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      final List<String?> chipLabels = tester
          .widgetList<Chip>(find.byType(Chip))
          .map((Chip c) => (c.label as Text).data)
          .toList();
      final List<String> expectedChipLabels = <String>[
        for (final ReasonChip c in report.skipReasonBuckets) c.label,
        for (final ReasonChip c in report.selectiveExecutionChips) c.label,
      ];
      expect(chipLabels, expectedChipLabels);

      if (report.skipReasonBuckets.isNotEmpty) {
        expect(
          find.text(AnalyticsLabels.executionGapSkipReasonsHeader),
          findsOneWidget,
        );
      } else {
        expect(
          find.text(AnalyticsLabels.executionGapSkipReasonsHeader),
          findsNothing,
        );
      }

      expect(find.byType(ActionChip), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-10 ────────────────────────────────────────────────────────────────
  testWidgets('T710-10 loading state', (WidgetTester tester) async {
    final Completer<ExecutionGapResult> completer =
        Completer<ExecutionGapResult>();
    final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
      completer: completer,
    );
    await pumpExecutionGap(tester, repo: repo, safetyState: safety3);

    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s710-root')), findsNothing);
    for (final BlockFlag flag in safety3.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  // ── T710-11 ────────────────────────────────────────────────────────────────
  testWidgets('T710-11 error state and retry', (WidgetTester tester) async {
    final String m = monthFixture;
    final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
      error: Exception('network error'),
    );
    await pumpExecutionGap(tester, repo: repo, yyyyMm: m, safetyState: safety3);
    await tester.pump();

    expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
    expect(find.byType(AnalyticsSkeleton), findsNothing);
    expect(
      tester
          .widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView))
          .lastAsOfLabel,
      isNull,
    );
    for (final BlockFlag flag in safety3.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.byKey(const Key('s710-root')), findsNothing);

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();

    expect(repo.monthlyCalls, hasLength(2));
    expect(repo.monthlyCalls, <String?>[m, m]);
  });

  // ── T710-12 ────────────────────────────────────────────────────────────────
  for (final (String caseName, Clock clock, bool isStale)
      in <(String, Clock, bool)>[
        ('normal', FixedClock(kGoldenNowUtc), false),
        ('stale', FixedClock(kGoldenNowUtc.add(const Duration(days: 3))), true),
      ]) {
    testWidgets('T710-12 stale banner $caseName', (WidgetTester tester) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: cant,
      );
      await pumpExecutionGap(tester, repo: repo, clock: clock);
      await tester.pump();

      if (isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(AnalyticsLabels.staleBannerTitle),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-13 ────────────────────────────────────────────────────────────────
  for (final (
        String caseName,
        SafetyState safety,
        int flagCount,
        int blockCount,
        bool hasTap,
      )
      in <(String, SafetyState, int, int, bool)>[
        ('row0', safety0, 0, 0, false),
        ('row1', safety1, 1, 0, false),
        ('row3', safety3, 2, 2, false),
        ('row4', safety4, 1, 1, true),
      ]) {
    testWidgets('T710-13 safety banner $caseName', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: cant,
      );
      await pumpExecutionGap(
        tester,
        repo: repo,
        safetyState: safety,
        opener: opener,
      );
      await tester.pump();

      expect(safety.activeFlags, hasLength(flagCount));
      for (final BlockFlag flag in safety.activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(flag.label),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      }

      if (blockCount == 0) {
        expect(find.byIcon(Icons.block), findsNothing);
      } else {
        expect(find.byIcon(Icons.block), findsNWidgets(blockCount));
      }

      if (hasTap) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
        expect(opener.opened, <String>[
          safety.activeFlags.single.clearDeepLink!,
        ]);
      } else {
        expect(opener.opened, isEmpty);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-14 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[('mixed', mixed), ('cant', cant)]) {
    testWidgets('T710-14 trust badge action $caseName', (
      WidgetTester tester,
    ) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo, opener: opener);
      await tester.pump();

      final ExecutionGapReport report = result.report!;
      expect(find.text(report.trust.label), findsOneWidget);

      if (report.trust.actionDeepLink != null) {
        expect(find.text(AnalyticsLabels.actionViewButton), findsOneWidget);
        await tester.tap(find.text(AnalyticsLabels.actionViewButton));
        await tester.pump();
        expect(opener.opened, <String>[report.trust.actionDeepLink!]);
      } else {
        expect(find.text(AnalyticsLabels.actionViewButton), findsNothing);
        expect(opener.opened, isEmpty);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-15 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('mixed', mixed),
        ('masked_recon', maskedRecon),
        ('empty', empty),
      ]) {
    testWidgets('T710-15 allowed text set $caseName', (
      WidgetTester tester,
    ) async {
      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      final ExecutionGapReport? report = result.report;
      final Set<String> allowed = <String>{
        result.asOf.label,
        if (report != null) ...<String>[
          report.periodLabel,
          report.complianceRateLabel,
          ...report.countLines,
          report.medianDelayLabel,
          report.priceGapLabel,
          ...report.correctionLines,
          report.amendChainMaxLabel,
          if (report.modeAdviceLine != null) report.modeAdviceLine!,
          for (final ReasonChip c in report.skipReasonBuckets) c.label,
          for (final ReasonChip c in report.selectiveExecutionChips) c.label,
          report.trust.label,
          report.trust.consequenceLine,
          if (report.trust.upgradeHint != null) report.trust.upgradeHint!,
        ] else ...<String>[result.emptyLabel!],
        AnalyticsLabels.executionGapSkipReasonsHeader,
        AnalyticsLabels.actionViewButton,
      };

      final RegExp moneyRegex = RegExp(
        r'[0-9][0-9,.]*\s*(\uC5B5\uC6D0|\uB9CC\uC6D0|\uC6D0)|\u20A9',
      );
      final RegExp forbiddenRegex = RegExp(
        r'\uCD94\uCC9C|\uAD8C\uC720|\uC790\uBB38|\uC2DC\uADF8\uB110',
      );

      for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
        final String? data = text.data;
        if (data != null && data.isNotEmpty) {
          expect(
            allowed.contains(data),
            isTrue,
            reason: 'Text must be in allowed set',
          );
          expect(
            moneyRegex.hasMatch(data),
            isFalse,
            reason: 'Text must not match money regex',
          );
          expect(
            forbiddenRegex.hasMatch(data),
            isFalse,
            reason: 'Text must not match forbidden regex',
          );
        }
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T710-16 ────────────────────────────────────────────────────────────────
  testWidgets('T710-16 barrel exports', (WidgetTester tester) async {
    final String content = File('lib/ui_analytics.dart').readAsStringSync();
    final List<String> exports = RegExp(
      r"^export '([^']+)';",
      multiLine: true,
    ).allMatches(content).map((RegExpMatch m) => m.group(1)!).toList();
    expect(exports, hasLength(13));
    expect(exports.toSet(), <String>{
      'l10n/labels.dart',
      'src/providers/analytics_providers.dart',
      'src/screens/annual_review_screen.dart',
      'src/screens/contribution_screen.dart',
      'src/screens/drawdown_context_screen.dart',
      'src/screens/execution_gap_screen.dart',
      'src/screens/goal_path_screen.dart',
      'src/screens/monthly_report_screen.dart',
      'src/screens/performance_explore_screen.dart',
      'src/screens/rebalance_event_screen.dart',
      'src/screens/rebalance_preview_screen.dart',
      'src/screens/rebalance_timeline_screen.dart',
      'src/screens/report_archive_screen.dart',
    });
  });

  // ── T710-17 ────────────────────────────────────────────────────────────────
  testWidgets('T710-17 autoDispose', (WidgetTester tester) async {
    final String content = File('lib/src/providers/analytics_providers.dart')
        .readAsStringSync();
    final List<String> autoDisposeLines = content
        .split('\n')
        .where((String line) => line.contains('autoDispose'))
        .toList();
    expect(autoDisposeLines, hasLength(9));
  });

  // ── T710-18 ────────────────────────────────────────────────────────────────
  for (final (String caseName, ExecutionGapResult result)
      in <(String, ExecutionGapResult)>[
        ('cant', cant),
        ('masked_recon', maskedRecon),
      ]) {
    testWidgets('T710-18 text scale 2.0 $caseName', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final FakeExecutionGapRepository repo = FakeExecutionGapRepository(
        result: result,
      );
      await pumpExecutionGap(tester, repo: repo);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('s710-root')), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }
}
