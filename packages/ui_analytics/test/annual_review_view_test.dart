// packages/ui_analytics/test/annual_review_view_test.dart

import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'annual_review_fakes.dart';
import 'golden/golden_support.dart';

void main() {
  // ── 픽스처 ────────────────────────────────────────────────────────────────
  final AnnualReviewVm vm2026 = singleFixture(
    FixturePaths.m7M7Annual2026,
    AnnualReviewVm.fromJson,
  );
  final AnnualReviewVm vmFirstYear = singleFixture(
    FixturePaths.m7M7AnnualFirstYear,
    AnnualReviewVm.fromJson,
  );
  final AnnualReviewVm vmOffwindow = singleFixture(
    FixturePaths.m7M7AnnualOffwindow,
    AnnualReviewVm.fromJson,
  );
  final SafetyState safety0 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[0],
  );
  final SafetyState safety3 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[3],
  );
  final SafetyState safety4 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[4],
  );

  // ── T77-01 ────────────────────────────────────────────────────────────────
  testWidgets('T77-01 provider call 2026', (WidgetTester tester) async {
    final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
      vm: vm2026,
    );
    await pumpAnnualReview(tester, repo: repo);

    expect(repo.annualReviewCalls, hasLength(1));
    expect(repo.annualReviewCalls, <String?>[null]);
    expect(repo.afterTaxLadderCalls, isEmpty);
    expect(repo.monthlyReportCalls, isEmpty);
    expect(find.byKey(const Key('s77-root')), findsOneWidget);
    expect(find.text(vm2026.year), findsNothing);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  // ── T77-02 ────────────────────────────────────────────────────────────────
  final List<(AnnualReviewVm, Clock, SafetyState)> t02Cases =
      <(AnnualReviewVm, Clock, SafetyState)>[
        (vm2026, FixedClock(kGoldenNowUtc), safety0),
        (
          vmFirstYear,
          FixedClock(kGoldenNowUtc.add(const Duration(days: 3))),
          safety4,
        ),
        (vmOffwindow, FixedClock(kGoldenNowUtc), safety3),
      ];

  for (final (AnnualReviewVm vm, Clock clk, SafetyState safety) in t02Cases) {
    testWidgets(
      'T77-02 chain layout ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(
          tester,
          repo: repo,
          safetyState: safety,
          clock: clk,
        );

        expect(vm.afterTax, isNotNull);
        expect(vm.afterTaxCounterfactual, isNotNull);

        final List<BlockFlag> activeFlags = safety.activeFlags;
        final bool isStale = vm.asOf.observedAt
            .add(vm.asOf.staleAfter)
            .isBefore(clk.nowUtc());

        final List<Finder> chain = <Finder>[];

        if (isStale) {
          chain.add(find.text(AnalyticsLabels.staleBannerTitle));
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

        if (activeFlags.isNotEmpty) {
          chain.add(find.text(activeFlags.first.label));
          expect(
            find.ancestor(
              of: find.text(activeFlags.first.label),
              matching: find.byType(Scrollable),
            ),
            findsNothing,
          );
        } else {
          expect(find.byIcon(Icons.block), findsNothing);
        }

        chain.add(find.byKey(const Key('s77-year')));
        chain.add(find.byKey(const Key('s77-window')));
        chain.add(find.byKey(const Key('s77-aftertax')));
        for (final (int i, AnnualReviewSection _) in vm.sections.indexed) {
          chain.add(find.byKey(ValueKey<String>('s77-section-$i')));
        }
        chain.add(find.byKey(const Key('s77-asof')));

        for (final Finder f in chain) {
          expect(f, findsOneWidget);
        }
        for (int i = 1; i < chain.length; i++) {
          expect(
            tester.getTopLeft(chain[i]).dy,
            greaterThan(tester.getTopLeft(chain[i - 1]).dy),
          );
        }

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-03 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[
    vm2026,
    vmFirstYear,
    vmOffwindow,
  ]) {
    testWidgets(
      'T77-03 key text == vm field ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo);

        expect(
          tester.widget<Text>(find.byKey(const Key('s77-year'))).data,
          vm.yearLabel,
        );
        expect(
          tester.widget<Text>(find.byKey(const Key('s77-window'))).data,
          vm.windowStateLabel,
        );
        expect(
          tester.widget<Text>(find.byKey(const Key('s77-asof'))).data,
          vm.asOf.label,
        );

        final List<String?> cfToggleTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const Key('s77-cf-toggle')),
                matching: find.byType(Text),
              ),
            )
            .map((Text t) => t.data)
            .toList();
        expect(cfToggleTexts, <String?>[
          vm.afterTaxCounterfactual!.branchLabel,
        ]);

        expect(find.text(vm.yearLabel), findsOneWidget);
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-04 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[
    vm2026,
    vmFirstYear,
    vmOffwindow,
  ]) {
    testWidgets(
      'T77-04 main ladder steps ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo);

        final AfterTaxLadder ladder = vm.afterTax!;
        expect(ladder.steps, hasLength(6));

        for (final (int i, AfterTaxStep step) in ladder.steps.indexed) {
          final Finder stepFinder = find.descendant(
            of: find.byKey(const Key('s77-aftertax')),
            matching: find.byKey(ValueKey<String>('s77-step-$i')),
          );
          expect(stepFinder, findsOneWidget);

          final List<String?> texts = tester
              .widgetList<Text>(
                find.descendant(of: stepFinder, matching: find.byType(Text)),
              )
              .map((Text t) => t.data)
              .toList();
          expect(texts, <String?>[
            step.label,
            step.valueText,
            if (step.noteLine != null) step.noteLine,
          ]);
        }

        for (int i = 1; i < ladder.steps.length; i++) {
          expect(
            tester
                .getTopLeft(
                  find.descendant(
                    of: find.byKey(const Key('s77-aftertax')),
                    matching: find.byKey(ValueKey<String>('s77-step-${i - 1}')),
                  ),
                )
                .dy,
            lessThan(
              tester
                  .getTopLeft(
                    find.descendant(
                      of: find.byKey(const Key('s77-aftertax')),
                      matching: find.byKey(ValueKey<String>('s77-step-$i')),
                    ),
                  )
                  .dy,
            ),
          );
        }

        expect(
          find.descendant(
            of: find.byKey(const Key('s77-aftertax')),
            matching: find.byKey(
              ValueKey<String>('s77-step-${ladder.steps.length}'),
            ),
          ),
          findsNothing,
        );

        expect(
          find.byWidgetPredicate(
            (Widget w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('s77-step-'),
          ),
          findsNWidgets(ladder.steps.length),
        );

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-05 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[
    vm2026,
    vmFirstYear,
    vmOffwindow,
  ]) {
    testWidgets(
      'T77-05 aftertax block texts ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo);

        final AfterTaxLadder ladder = vm.afterTax!;
        expect(ladder.referenceOnlyLabel, isNotNull);

        final List<String?> texts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const Key('s77-aftertax')),
                matching: find.byType(Text),
              ),
            )
            .map((Text t) => t.data)
            .toList();

        expect(texts, <String?>[
          ladder.branchLabel,
          for (final AfterTaxStep s in ladder.steps) ...<String?>[
            s.label,
            s.valueText,
            if (s.noteLine != null) s.noteLine,
          ],
          ladder.honestExpectationLine,
          ladder.basisNote,
          ladder.referenceOnlyLabel,
          vm.afterTaxCounterfactual!.branchLabel,
        ]);

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-06 ────────────────────────────────────────────────────────────────
  testWidgets('T77-06 counterfactual toggle 2026', (WidgetTester tester) async {
    final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
      vm: vm2026,
    );
    await pumpAnnualReview(tester, repo: repo);

    final AfterTaxLadder cf = vm2026.afterTaxCounterfactual!;

    expect(find.byKey(const Key('s77-cf')), findsOneWidget);
    expect(find.byKey(const Key('s77-cf-toggle')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('s77-cf')),
        matching: find.byKey(const ValueKey<String>('s77-step-0')),
      ),
      findsNothing,
    );
    expect(find.text(cf.honestExpectationLine), findsNothing);

    await tester.tap(find.byKey(const Key('s77-cf-toggle')));
    await tester.pumpAndSettle();

    expect(cf.steps, hasLength(6));

    for (final (int i, AfterTaxStep step) in cf.steps.indexed) {
      expect(
        find.descendant(
          of: find.byKey(const Key('s77-cf')),
          matching: find.byKey(ValueKey<String>('s77-step-$i')),
        ),
        findsOneWidget,
      );
      final List<String?> texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.descendant(
                of: find.byKey(const Key('s77-cf')),
                matching: find.byKey(ValueKey<String>('s77-step-$i')),
              ),
              matching: find.byType(Text),
            ),
          )
          .map((Text t) => t.data)
          .toList();
      expect(texts, <String?>[
        step.label,
        step.valueText,
        if (step.noteLine != null) step.noteLine,
      ]);
    }

    final List<String?> cfTexts = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('s77-cf')),
            matching: find.byType(Text),
          ),
        )
        .map((Text t) => t.data)
        .toList();
    expect(cfTexts, <String?>[
      cf.branchLabel,
      for (final AfterTaxStep s in cf.steps) ...<String?>[
        s.label,
        s.valueText,
        if (s.noteLine != null) s.noteLine,
      ],
      cf.honestExpectationLine,
      cf.basisNote,
      cf.referenceOnlyLabel,
    ]);

    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('s77-step-'),
      ),
      findsNWidgets(vm2026.afterTax!.steps.length + cf.steps.length),
    );

    await tester.tap(find.byKey(const Key('s77-cf-toggle')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('s77-cf')),
        matching: find.byKey(const ValueKey<String>('s77-step-0')),
      ),
      findsNothing,
    );
    final List<String?> cfCollapsedTexts = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('s77-cf')),
            matching: find.byType(Text),
          ),
        )
        .map((Text t) => t.data)
        .toList();
    expect(cfCollapsedTexts, <String?>[cf.branchLabel]);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  // ── T77-07 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[
    vm2026,
    vmFirstYear,
    vmOffwindow,
  ]) {
    testWidgets(
      'T77-07 section cards in order ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo);

        expect(vm.sections, hasLength(4));

        for (final (int i, AnnualReviewSection section)
            in vm.sections.indexed) {
          final Finder cardFinder = find.byKey(
            ValueKey<String>('s77-section-$i'),
          );
          expect(cardFinder, findsOneWidget);

          final List<String?> texts = tester
              .widgetList<Text>(
                find.descendant(of: cardFinder, matching: find.byType(Text)),
              )
              .map((Text t) => t.data)
              .toList();
          expect(texts, <String?>[
            section.title,
            ...section.lines,
            if (section.route != null) AnalyticsLabels.detailButton,
          ]);
        }

        for (int i = 1; i < vm.sections.length; i++) {
          expect(
            tester
                .getTopLeft(
                  find.byKey(ValueKey<String>('s77-section-${i - 1}')),
                )
                .dy,
            lessThan(
              tester
                  .getTopLeft(find.byKey(ValueKey<String>('s77-section-$i')))
                  .dy,
            ),
          );
        }

        expect(
          find.byKey(ValueKey<String>('s77-section-${vm.sections.length}')),
          findsNothing,
        );

        for (final (int i, AnnualReviewSection section)
            in vm.sections.indexed) {
          final Finder cardFinder = find.byKey(
            ValueKey<String>('s77-section-$i'),
          );
          if (section.route != null) {
            expect(
              find.descendant(
                of: cardFinder,
                matching: find.byType(TextButton),
              ),
              findsOneWidget,
            );
          } else {
            expect(
              find.descendant(
                of: cardFinder,
                matching: find.byType(TextButton),
              ),
              findsNothing,
            );
          }
        }

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-08 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[vm2026, vmOffwindow]) {
    testWidgets(
      'T77-08 section detail button opens route ${vm == vm2026 ? "2026" : "offwindow"}',
      (WidgetTester tester) async {
        final RecordingLinkOpener opener = RecordingLinkOpener();
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo, opener: opener);

        expect(vm.sections.first.route, isNotNull);

        await tester.tap(
          find.descendant(
            of: find.byKey(const ValueKey<String>('s77-section-0')),
            matching: find.byType(TextButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(opener.opened, <String>[vm.sections.first.route!]);

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-09 ────────────────────────────────────────────────────────────────
  testWidgets('T77-09 loading state', (WidgetTester tester) async {
    final Completer<AnnualReviewVm> completer = Completer<AnnualReviewVm>();
    final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
      completer: completer,
    );
    await pumpAnnualReview(tester, repo: repo, safetyState: safety3);

    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s77-year')), findsNothing);

    for (final BlockFlag flag in safety3.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  // ── T77-10 ────────────────────────────────────────────────────────────────
  testWidgets('T77-10 error state', (WidgetTester tester) async {
    final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
      error: Exception('test error'),
    );
    await pumpAnnualReview(tester, repo: repo, safetyState: safety3);

    expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
    expect(
      tester
          .widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView))
          .lastAsOfLabel,
      isNull,
    );

    for (final BlockFlag flag in safety3.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.byKey(const Key('s77-year')), findsNothing);

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();

    expect(repo.annualReviewCalls, hasLength(2));
    expect(repo.annualReviewCalls, <String?>[null, null]);
  });

  // ── T77-11 ────────────────────────────────────────────────────────────────
  for (final (String caseName, Clock clk) in <(String, Clock)>[
    ('fresh', FixedClock(kGoldenNowUtc)),
    ('stale', FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))),
  ]) {
    testWidgets('T77-11 stale banner $caseName', (WidgetTester tester) async {
      final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
        vm: vm2026,
      );
      await pumpAnnualReview(tester, repo: repo, clock: clk);

      final bool isStale = vm2026.asOf.observedAt
          .add(vm2026.asOf.staleAfter)
          .isBefore(clk.nowUtc());

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

  // ── T77-12 ────────────────────────────────────────────────────────────────
  for (final (String caseName, SafetyState safety) in <(String, SafetyState)>[
    ('row0', safety0),
    ('row3', safety3),
    ('row4', safety4),
  ]) {
    testWidgets('T77-12 safety banner $caseName', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
        vm: vm2026,
      );
      await pumpAnnualReview(
        tester,
        repo: repo,
        safetyState: safety,
        opener: opener,
      );

      final List<BlockFlag> activeFlags = safety.activeFlags;
      expect(
        activeFlags,
        hasLength(
          caseName == 'row0'
              ? 0
              : caseName == 'row3'
              ? 2
              : 1,
        ),
      );

      for (final BlockFlag flag in activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(flag.label),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      }

      if (activeFlags.isEmpty) {
        expect(find.byIcon(Icons.block), findsNothing);
      } else {
        expect(
          find.byIcon(Icons.block),
          findsNWidgets(caseName == 'row3' ? 2 : 1),
        );
      }

      if (caseName == 'row4') {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
        expect(opener.opened, <String>[
          safety4.activeFlags.single.clearDeepLink!,
        ]);
      } else {
        expect(opener.opened, isEmpty);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  // ── T77-13 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[
    vm2026,
    vmFirstYear,
    vmOffwindow,
  ]) {
    testWidgets(
      'T77-13 allowed text set ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo);

        expect(vm.afterTaxCounterfactual, isNotNull);

        await tester.tap(find.byKey(const Key('s77-cf-toggle')));
        await tester.pumpAndSettle();

        final AfterTaxLadder ladder = vm.afterTax!;
        final AfterTaxLadder cf = vm.afterTaxCounterfactual!;

        final Set<String?> allowed = <String?>{
          vm.yearLabel,
          vm.windowStateLabel,
          vm.asOf.label,
          ladder.branchLabel,
          for (final AfterTaxStep s in ladder.steps) ...<String?>[
            s.label,
            s.valueText,
            if (s.noteLine != null) s.noteLine,
          ],
          ladder.honestExpectationLine,
          ladder.basisNote,
          if (ladder.referenceOnlyLabel != null) ladder.referenceOnlyLabel,
          cf.branchLabel,
          for (final AfterTaxStep s in cf.steps) ...<String?>[
            s.label,
            s.valueText,
            if (s.noteLine != null) s.noteLine,
          ],
          cf.honestExpectationLine,
          cf.basisNote,
          if (cf.referenceOnlyLabel != null) cf.referenceOnlyLabel,
          for (final AnnualReviewSection s in vm.sections) ...<String?>[
            s.title,
            ...s.lines,
          ],
          AnalyticsLabels.detailButton,
        };

        final List<String> forbidden = <String>[
          '\u{CD94}\u{CC9C}',
          '\u{AD8C}\u{C720}',
          '\u{C790}\u{BB38}',
          '\u{C2DC}\u{ADF8}\u{B110}',
        ];

        for (final Text textWidget in tester.widgetList<Text>(
          find.byType(Text),
        )) {
          final String? data = textWidget.data;
          expect(allowed.contains(data), isTrue, reason: 'Unexpected: $data');
          for (final String word in forbidden) {
            expect(
              data?.contains(word) ?? false,
              isFalse,
              reason: 'Forbidden word in: $data',
            );
          }
        }

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }

  // ── T77-14 ────────────────────────────────────────────────────────────────
  testWidgets('T77-14 file checks', (WidgetTester tester) async {
    final String screenContent = File(
      'lib/src/screens/annual_review_screen.dart',
    ).readAsStringSync();

    expect(
      RegExp(
        r'ReviewSectionVm|changeWindowNoticeText|oathText|KeyValueVm|AsOfStamp|afterTaxLadder|OpsStatusRepository|monthlyReport|ExpansionTile',
      ).hasMatch(screenContent),
      isFalse,
    );

    expect(Directory('lib/src/annual_review').existsSync(), isFalse);

    final String barrelContent = File('lib/ui_analytics.dart')
        .readAsStringSync();
    final List<String> exports = RegExp(r"^export '([^']+)';", multiLine: true)
        .allMatches(barrelContent)
        .map((RegExpMatch m) => m.group(1)!)
        .where((String e) => e == 'src/screens/annual_review_screen.dart')
        .toList();
    expect(exports, <String>['src/screens/annual_review_screen.dart']);

    expect(exports.any((String e) => e.contains('annual_review/')), isFalse);
  });

  // ── T77-15 ────────────────────────────────────────────────────────────────
  for (final AnnualReviewVm vm in <AnnualReviewVm>[
    vm2026,
    vmFirstYear,
    vmOffwindow,
  ]) {
    testWidgets(
      'T77-15 no action widgets ${vm == vm2026
          ? "2026"
          : vm == vmFirstYear
          ? "first_year"
          : "offwindow"}',
      (WidgetTester tester) async {
        final FakeAnnualReviewRepository repo = FakeAnnualReviewRepository(
          vm: vm,
        );
        await pumpAnnualReview(tester, repo: repo);

        expect(find.byType(FilledButton), findsNothing);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
        expect(find.byType(IconButton), findsNothing);
        expect(find.byType(Checkbox), findsNothing);
        expect(find.byType(Switch), findsNothing);
        expect(find.byType(Radio<dynamic>), findsNothing);

        final int routeCount = vm.sections
            .where((AnnualReviewSection s) => s.route != null)
            .length;
        expect(find.byType(TextButton), findsNWidgets(routeCount));

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );
  }
}
