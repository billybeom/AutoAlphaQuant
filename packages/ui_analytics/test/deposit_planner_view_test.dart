// test/deposit_planner_view_test.dart

import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/l10n/labels.dart';
import 'package:ui_analytics/planner.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/src/widgets/safety_block_banner.dart';
import 'package:ui_analytics/src/widgets/stale_banner.dart';

import 'golden/golden_support.dart';
import 'planner_fakes.dart';

void main() {
  testWidgets('T74-01 entry with default setting and plan', (tester) async {
    final whatIf = FakeWhatIfApi();
    final config = FakeConfigRepository();
    final settingDefault = singleFixture(
      FixturePaths.m9ContributionSettingDefault,
      ContributionSetting.fromJson,
    );

    await pumpPlanner(tester, whatIf: whatIf, config: config);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    expect(whatIf.simulateCalls, isEmpty);
    expect(whatIf.otherCalls, isEmpty);
    expect(config.watchContributionSettingCalls, 1);

    expect(find.text(AnalyticsLabels.plannerStepAmountTitle), findsOneWidget);
    expect(find.text(AnalyticsLabels.plannerIntroLine), findsOneWidget);
    expect(find.text(AnalyticsLabels.plannerCurrentSettingHeader), findsOneWidget);
    expect(find.text(settingDefault.amountText), findsOneWidget);
    expect(find.text(settingDefault.equivalentNoteText), findsOneWidget);
    expect(find.text(settingDefault.appliesFromText), findsOneWidget);
    expect(find.text(settingDefault.asOf.label), findsOneWidget);

    expect(find.text(settingDefault.lastChangedText), findsNothing);
    expect(find.byKey(const Key('s74-preview-notice')), findsNothing);
    expect(find.byType(StaleBanner), findsNothing);

    // default fixture has pensionLimitNoteText
    expect(find.byKey(const Key('s74-setting-limit-note')), findsOneWidget);
    expect(find.text(settingDefault.pensionLimitNoteText!), findsOneWidget);

    // Now test with noLimitNote fixture
    final settingNoLimit = singleFixture(
      FixturePaths.m9ContributionSettingNoLimitNote,
      ContributionSetting.fromJson,
    );
    final configNoLimit = FakeConfigRepository(
      settingStreamFactory: () => Stream.value(settingNoLimit),
    );
    await pumpPlanner(tester, whatIf: whatIf, config: configNoLimit);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    expect(find.byKey(const Key('s74-setting-limit-note')), findsNothing);
  });

  testWidgets('T74-02 input field initial value and seed protection', (tester) async {
    final defaultSetting = singleFixture(
      FixturePaths.m9ContributionSettingDefault,
      ContributionSetting.fromJson,
    );
    final noLimitSetting = singleFixture(
      FixturePaths.m9ContributionSettingNoLimitNote,
      ContributionSetting.fromJson,
    );

    // Scene A: first value added -> text seeded -> user edits -> second value added -> text kept
    {
      final streamController = StreamController<ContributionSetting>();
      addTearDown(() {
        unawaited(streamController.close());
      });
      final config = FakeConfigRepository(
        settingStreamFactory: () => streamController.stream,
      );
      final whatIf = FakeWhatIfApi();

      await pumpPlanner(tester, whatIf: whatIf, config: config);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      streamController.add(defaultSetting);
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        defaultSetting.amountInputText,
      );

      await tester.enterText(
        find.byKey(const Key('s74-amount-field')),
        '${defaultSetting.amountInputText}0',
      );
      await tester.pump();

      streamController.add(noLimitSetting);
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        '${defaultSetting.amountInputText}0',
      );
      expect(find.byKey(const Key('s74-setting-limit-note')), findsNothing);
    }

    // Scene B: user enters text before first value arrives -> first value added -> user text kept
    {
      final streamController = StreamController<ContributionSetting>();
      addTearDown(() {
        unawaited(streamController.close());
      });
      final config = FakeConfigRepository(
        settingStreamFactory: () => streamController.stream,
      );
      final whatIf = FakeWhatIfApi();

      await pumpPlanner(tester, whatIf: whatIf, config: config);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tester.enterText(
        find.byKey(const Key('s74-amount-field')),
        defaultSetting.amountInputText,
      );
      await tester.pump();

      streamController.add(defaultSetting);
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        defaultSetting.amountInputText,
      );
      expect(find.text(defaultSetting.amountText), findsOneWidget);
    }

    // Scene C: no user edit -> first value arrives -> second value with different amountInputText arrives -> first value kept
    {
      final streamController = StreamController<ContributionSetting>();
      addTearDown(() {
        unawaited(streamController.close());
      });
      final config = FakeConfigRepository(
        settingStreamFactory: () => streamController.stream,
      );
      final whatIf = FakeWhatIfApi();

      await pumpPlanner(tester, whatIf: whatIf, config: config);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      streamController.add(defaultSetting);
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        defaultSetting.amountInputText,
      );

      final secondModified = noLimitSetting.copyWith(
        amountInputText: '${defaultSetting.amountInputText}0',
      );
      streamController.add(secondModified);
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        defaultSetting.amountInputText,
      );
      expect(find.byKey(const Key('s74-setting-limit-note')), findsNothing);
    }
  });

  testWidgets('T74-03 calculate argument is passed exactly as entered', (tester) async {
    final setting = singleFixture(
      FixturePaths.m9ContributionSettingDefault,
      ContributionSetting.fromJson,
    );
    final whatIf = FakeWhatIfApi();

    await pumpPlanner(tester, whatIf: whatIf);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    final rawInput = ' ${setting.amountInputText} ';
    await tester.enterText(find.byKey(const Key('s74-amount-field')), rawInput);
    await tapAndSettle(tester, 's74-calculate');

    expect(whatIf.simulateCalls, [rawInput]);
  });

  testWidgets('T74-04 pending calculation shows loading skeleton', (tester) async {
    final completer = Completer<DepositPreviewResult>();
    final whatIf = FakeWhatIfApi(answerFn: (_) => completer.future);

    await pumpPlanner(tester, whatIf: whatIf);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');

    expect(find.byKey(const Key('s74-result-loading')), findsOneWidget);
    final skeleton = tester.widget<AnalyticsSkeleton>(find.byKey(const Key('s74-result-loading')));
    expect(skeleton.blocks, 3);

    expect(find.text(AnalyticsLabels.plannerStepAmountTitle), findsOneWidget);
    expect(find.byKey(const Key('s74-amount-field')), findsOneWidget);
    expect(find.byKey(const Key('s74-calculate')), findsOneWidget);
    expect(find.byKey(const Key('s74-preview-notice')), findsNothing);

    final defaultPlanResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    completer.complete(defaultPlanResult);
    await tester.pump();
    await tester.pump();

    expect(find.text(AnalyticsLabels.plannerStepAllocationTitle), findsOneWidget);
    expect(find.byKey(const Key('s74-result-loading')), findsNothing);
  });

  testWidgets('T74-05 calculation error displays error view and retry works', (tester) async {
    final whatIf = FakeWhatIfApi(
      answerFn: (_) => Future.error(StateError('x')),
    );

    await pumpPlanner(tester, whatIf: whatIf);

    final initialText = tester
        .widget<TextField>(find.byKey(const Key('s74-amount-field')))
        .controller!
        .text;

    await tapAndSettle(tester, 's74-calculate');

    expect(find.byKey(const Key('s74-result-error')), findsOneWidget);
    expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
    expect(tester.takeException(), isNull);

    expect(
      tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
      initialText,
    );

    await tapAndSettle(tester, 's74-result-error');
    expect(whatIf.simulateCalls, hasLength(2));
    expect(whatIf.simulateCalls[0], whatIf.simulateCalls[1]);
  });

  testWidgets('T74-06 rejected and blocked stay on step one', (tester) async {
    // ⓐ Input rejected
    {
      final rejectedResult = singleFixture(
        FixturePaths.m7M7DepositPlanInputRejected,
        DepositPreviewResult.fromJson,
      );
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(rejectedResult));

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      final initialText = tester
          .widget<TextField>(find.byKey(const Key('s74-amount-field')))
          .controller!
          .text;

      await tapAndSettle(tester, 's74-calculate');

      expect(
        find.text(rejectedResult.inputRejectedText!),
        findsOneWidget,
      );
      expect(find.text(AnalyticsLabels.plannerStepAmountTitle), findsOneWidget);
      expect(find.byKey(const Key('s74-blocked-card')), findsNothing);
      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        initialText,
      );

      final fieldDy = tester.getTopLeft(find.byKey(const Key('s74-amount-field'))).dy;
      final rejectedDy = tester.getTopLeft(find.byKey(const Key('s74-input-rejected'))).dy;
      final calcDy = tester.getTopLeft(find.byKey(const Key('s74-calculate'))).dy;
      expect(fieldDy, lessThan(rejectedDy));
      expect(rejectedDy, lessThan(calcDy));
    }

    // ⓑ Blocked (2 rows)
    final blockedList = listFixture(
      FixturePaths.m7M7DepositPlanBlocked,
      DepositPreviewResult.fromJson,
    );
    expect(blockedList.rows, hasLength(2));

    for (int i = 0; i < blockedList.rows.length; i++) {
      final row = blockedList.rows[i];
      final opener = RecordingLinkOpener();
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(row));

      await pumpPlanner(tester, whatIf: whatIf, opener: opener);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');

      expect(find.byKey(const Key('s74-blocked-card')), findsOneWidget);
      expect(find.text(row.blockedText!), findsOneWidget);
      expect(find.byKey(const Key('s74-input-rejected')), findsNothing);

      final calcDy = tester.getTopLeft(find.byKey(const Key('s74-calculate'))).dy;
      final cardDy = tester.getTopLeft(find.byKey(const Key('s74-blocked-card'))).dy;
      expect(calcDy, lessThan(cardDy));

      if (row.blockedAction != null) {
        expect(find.byKey(const Key('s74-blocked-action')), findsOneWidget);
        expect(find.text(row.blockedAction!.label), findsOneWidget);
        await tapAndSettle(tester, 's74-blocked-action');
        expect(opener.opened, [row.blockedAction!.deepLink]);
      } else {
        expect(find.byKey(const Key('s74-blocked-action')), findsNothing);
        expect(opener.opened, isEmpty);
      }
    }
  });

  testWidgets('T74-07 step 2 allocations render accurately', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final fundingResult = singleFixture(
      FixturePaths.m7M7DepositPlanFunding,
      DepositPreviewResult.fromJson,
    );

    for (final res in [defaultResult, fundingResult]) {
      final plan = res.plan!;
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(res));

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');

      expect(find.text(plan.depositAmountText), findsOneWidget);
      expect(plan.allocations, hasLength(3));

      for (int i = 0; i < plan.allocations.length; i++) {
        final a = plan.allocations[i];
        final allocFinder = find.byKey(Key('s74-allocation-$i'));
        expect(allocFinder, findsOneWidget);
        expect(
          find.descendant(of: allocFinder, matching: find.text(a.label)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: allocFinder, matching: find.text(a.amountText)),
          findsOneWidget,
        );

        if (a.accountAlias != null) {
          expect(find.byKey(Key('s74-allocation-$i-account')), findsOneWidget);
          expect(
            find.descendant(of: allocFinder, matching: find.text(a.accountAlias!)),
            findsOneWidget,
          );
        } else {
          expect(find.byKey(Key('s74-allocation-$i-account')), findsNothing);
        }

        if (a.routingReasonText != null) {
          expect(find.byKey(Key('s74-allocation-$i-reason')), findsOneWidget);
          expect(
            find.descendant(of: allocFinder, matching: find.text(a.routingReasonText!)),
            findsOneWidget,
          );
        } else {
          expect(find.byKey(Key('s74-allocation-$i-reason')), findsNothing);
        }
      }
      expect(find.byKey(Key('s74-allocation-${plan.allocations.length}')), findsNothing);

      if (plan.residualKrwCashText != null) {
        expect(find.byKey(const Key('s74-residual')), findsOneWidget);
        expect(find.text(plan.residualKrwCashText!), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s74-residual')), findsNothing);
      }
    }
  });

  testWidgets('T74-08 pension limit card render and absent branches', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final limitResult = singleFixture(
      FixturePaths.m7M7DepositPlanLimit,
      DepositPreviewResult.fromJson,
    );
    final fundingResult = singleFixture(
      FixturePaths.m7M7DepositPlanFunding,
      DepositPreviewResult.fromJson,
    );
    final nullPensionPlan = defaultResult.plan!.copyWith(pensionLimit: null);
    final nullPensionResult = defaultResult.copyWith(plan: nullPensionPlan);

    for (final res in [defaultResult, limitResult, fundingResult, nullPensionResult]) {
      final plan = res.plan!;
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(res));

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');

      if (plan.pensionLimit != null) {
        final pl = plan.pensionLimit!;
        expect(find.byKey(const Key('s74-pension-limit')), findsOneWidget);
        expect(find.text(AnalyticsLabels.plannerPensionLimitTitle), findsOneWidget);
        expect(find.text(pl.annualLimitText), findsOneWidget);
        expect(find.text(pl.taxCreditText), findsOneWidget);
        expect(find.text(pl.deadlineText), findsOneWidget);

        if (pl.suggestionText != null) {
          expect(find.byKey(const Key('s74-pension-suggestion')), findsOneWidget);
          expect(find.text(pl.suggestionText!), findsOneWidget);
        } else {
          expect(find.byKey(const Key('s74-pension-suggestion')), findsNothing);
        }

        if (pl.fundingNoteText != null) {
          expect(find.byKey(const Key('s74-pension-funding-note')), findsOneWidget);
          expect(find.text(pl.fundingNoteText!), findsOneWidget);
        } else {
          expect(find.byKey(const Key('s74-pension-funding-note')), findsNothing);
        }
      } else {
        expect(find.byKey(const Key('s74-pension-limit')), findsNothing);
        expect(find.text(AnalyticsLabels.plannerPensionLimitTitle), findsNothing);
      }
    }
  });

  testWidgets('T74-09 preview notice fixed outside scroll in steps 2 and 3', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final plan = defaultResult.plan!;

    // Step 2 test
    {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));
      await pumpPlanner(tester, whatIf: whatIf, viewSize: const Size(390, 600));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');

      expect(find.text(plan.previewNotice), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(const Key('s74-preview-notice')),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.byKey(const Key('s74-asof')),
          matching: find.byType(Scrollable),
        ),
        findsOneWidget,
      );

      final noticeDyBefore = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
      final asOfDyBefore = tester.getTopLeft(
        find.byKey(const Key('s74-asof'), skipOffstage: false),
      ).dy;

      await tester.drag(find.byKey(const Key('s74-list-allocation')), const Offset(0, -40));
      await tester.pumpAndSettle();

      final noticeDyAfter = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
      final asOfDyAfter = tester.getTopLeft(
        find.byKey(const Key('s74-asof'), skipOffstage: false),
      ).dy;

      expect(noticeDyAfter, noticeDyBefore);
      expect(asOfDyAfter, lessThan(asOfDyBefore));
    }

    // Step 3 test
    {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));
      await pumpPlanner(tester, whatIf: whatIf, viewSize: const Size(390, 600));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');

      await tester.ensureVisible(find.byKey(const Key('s74-next'), skipOffstage: false));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, 's74-next');

      expect(
        tester
            .state<ScrollableState>(
              find.descendant(
                of: find.byKey(const Key('s74-list-result')),
                matching: find.byType(Scrollable),
              ),
            )
            .position
            .pixels,
        0.0,
      );

      expect(find.text(plan.previewNotice), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(const Key('s74-preview-notice')),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.byKey(const Key('s74-asof')),
          matching: find.byType(Scrollable),
        ),
        findsOneWidget,
      );

      final noticeDyBefore = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
      final asOfDyBefore = tester.getTopLeft(
        find.byKey(const Key('s74-asof'), skipOffstage: false),
      ).dy;

      await tester.drag(find.byKey(const Key('s74-list-result')), const Offset(0, -40));
      await tester.pumpAndSettle();

      final noticeDyAfter = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
      final asOfDyAfter = tester.getTopLeft(
        find.byKey(const Key('s74-asof'), skipOffstage: false),
      ).dy;

      expect(noticeDyAfter, noticeDyBefore);
      expect(asOfDyAfter, lessThan(asOfDyBefore));
    }
  });

  testWidgets('T74-10 warning lines in steps 2 and 3', (tester) async {
    final limitResult = singleFixture(
      FixturePaths.m7M7DepositPlanLimit,
      DepositPreviewResult.fromJson,
    );
    final plan = limitResult.plan!;
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(limitResult));

    await pumpPlanner(tester, whatIf: whatIf);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');

    expect(plan.warningLines, hasLength(1));
    expect(find.byKey(const Key('s74-warning-0')), findsOneWidget);
    expect(find.text(plan.warningLines[0]), findsOneWidget);
    expect(find.byKey(const Key('s74-warning-1')), findsNothing);

    await tapAndSettle(tester, 's74-next');

    expect(find.byKey(const Key('s74-warning-0')), findsOneWidget);
    expect(find.text(plan.warningLines[0]), findsOneWidget);
    expect(find.byKey(const Key('s74-warning-1')), findsNothing);

    // default fixture has 0 warnings
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final whatIfDefault = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));
    await pumpPlanner(tester, whatIf: whatIfDefault);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    expect(find.byKey(const Key('s74-warning-0')), findsNothing);
  });

  testWidgets('T74-11 step 3 order drafts and reason chips', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final fundingResult = singleFixture(
      FixturePaths.m7M7DepositPlanFunding,
      DepositPreviewResult.fromJson,
    );

    for (final res in [defaultResult, fundingResult]) {
      final plan = res.plan!;
      final opener = RecordingLinkOpener();
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(res));

      await pumpPlanner(tester, whatIf: whatIf, opener: opener);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');

      expect(find.text(plan.orderDraftsTitle), findsOneWidget);
      expect(find.byKey(const Key('s74-orders-empty')), findsNothing);
      expect(plan.orderDrafts, hasLength(4));

      for (int i = 0; i < plan.orderDrafts.length; i++) {
        final d = plan.orderDrafts[i];
        final orderFinder = find.byKey(Key('s74-order-$i'));
        expect(orderFinder, findsOneWidget);
        expect(
          find.descendant(of: orderFinder, matching: find.text(d.symbolLabel)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: orderFinder, matching: find.text(d.accountAlias)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: orderFinder, matching: find.text(d.sideLabel)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: orderFinder, matching: find.text(d.quantityText)),
          findsOneWidget,
        );

        if (d.limitPriceText != null) {
          expect(find.byKey(Key('s74-order-$i-limit')), findsOneWidget);
          expect(find.text(d.limitPriceText!), findsOneWidget);
        } else {
          expect(find.byKey(Key('s74-order-$i-limit')), findsNothing);
        }

        if (d.pendingNoteText != null) {
          expect(find.byKey(Key('s74-order-$i-pending')), findsOneWidget);
          expect(find.text(d.pendingNoteText!), findsOneWidget);
        } else {
          expect(find.byKey(Key('s74-order-$i-pending')), findsNothing);
        }

        expect(d.reasons, hasLength(1));
        final chipsInOrder = find.descendant(
          of: orderFinder,
          matching: find.byType(Chip),
        );
        expect(chipsInOrder, findsNWidgets(d.reasons.length));
        for (final chip in d.reasons) {
          expect(
            find.descendant(of: orderFinder, matching: find.text(chip.label)),
            findsOneWidget,
          );
        }
      }
      expect(find.byKey(Key('s74-order-${plan.orderDrafts.length}')), findsNothing);
      expect(find.byType(ActionChip), findsNothing);

      // Tap first chip
      await tester.tap(find.byType(Chip).first);
      await tester.pump();
      expect(opener.opened, isEmpty);
    }

    // 4 Tone branches
    for (final tone in ChipTone.values) {
      final firstDraft = defaultResult.plan!.orderDrafts[0];
      final modifiedFirstChip = firstDraft.reasons[0].copyWith(tone: tone);
      final modifiedReasons = [
        modifiedFirstChip,
        ...firstDraft.reasons.skip(1),
      ];
      final modifiedDraft = firstDraft.copyWith(reasons: modifiedReasons);
      final modifiedDrafts = [
        modifiedDraft,
        ...defaultResult.plan!.orderDrafts.skip(1),
      ];
      final modifiedPlan = defaultResult.plan!.copyWith(orderDrafts: modifiedDrafts);
      final modifiedResult = defaultResult.copyWith(plan: modifiedPlan);

      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(modifiedResult));
      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');

      final chipWidget = tester.widget<Chip>(
        find.descendant(
          of: find.byKey(const Key('s74-order-0')),
          matching: find.byType(Chip),
        ).first,
      );

      final ColorScheme scheme = Theme.of(
        tester.element(find.byKey(const Key('s74-order-0'))),
      ).colorScheme;
      final expectedColor = switch (tone) {
        ChipTone.caution => scheme.errorContainer,
        ChipTone.blocked => scheme.error,
        ChipTone.neutral => scheme.surfaceContainerHighest,
        ChipTone.prevented => scheme.surfaceContainerHighest,
      };

      expect(chipWidget.backgroundColor, expectedColor);
    }
  });

  testWidgets('T74-12 empty drafts shows ordersEmptyText', (tester) async {
    final limitResult = singleFixture(
      FixturePaths.m7M7DepositPlanLimit,
      DepositPreviewResult.fromJson,
    );
    final plan = limitResult.plan!;
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(limitResult));

    await pumpPlanner(tester, whatIf: whatIf);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');

    expect(find.text(plan.ordersEmptyText!), findsOneWidget);
    expect(find.byKey(const Key('s74-orders-empty')), findsOneWidget);
    expect(find.byKey(const Key('s74-order-0')), findsNothing);
    expect(find.byKey(const Key('s74-orders-title')), findsOneWidget);
    expect(find.byKey(const Key('s74-costs')), findsOneWidget);
    expect(find.text(plan.costs.totalText), findsOneWidget);
  });

  testWidgets('T74-13 funding section renders accurately', (tester) async {
    final fundingResult = singleFixture(
      FixturePaths.m7M7DepositPlanFunding,
      DepositPreviewResult.fromJson,
    );
    final plan = fundingResult.plan!;
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(fundingResult));

    await pumpPlanner(tester, whatIf: whatIf);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');

    expect(find.byKey(const Key('s74-funding')), findsOneWidget);
    expect(find.text(AnalyticsLabels.plannerFundingHeader), findsOneWidget);
    expect(plan.fundingSteps!, hasLength(1));
    expect(find.byKey(const Key('s74-funding-0')), findsOneWidget);
    expect(find.text(plan.fundingSteps![0].label), findsOneWidget);
    expect(find.byKey(const Key('s74-funding-1')), findsNothing);

    // Default fixture has null fundingSteps
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final whatIfDefault = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));
    await pumpPlanner(tester, whatIf: whatIfDefault);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');

    expect(find.byKey(const Key('s74-funding')), findsNothing);
    expect(find.text(AnalyticsLabels.plannerFundingHeader), findsNothing);
  });

  testWidgets('T74-14 expired plan blocks registration and recalculate works', (tester) async {
    final expiredResult = singleFixture(
      FixturePaths.m7M7DepositPlanExpired,
      DepositPreviewResult.fromJson,
    );
    final plan = expiredResult.plan!;

    int callCount = 0;
    final completer = Completer<DepositPreviewResult>();
    final whatIf = FakeWhatIfApi(
      answerFn: (_) {
        callCount++;
        if (callCount == 1) return Future.value(expiredResult);
        return completer.future;
      },
    );

    await pumpPlanner(tester, whatIf: whatIf);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');

    expect(find.byKey(const Key('s74-register')), findsNothing);
    expect(find.byKey(const Key('s74-register-blocked')), findsOneWidget);
    expect(find.text(plan.registerBlockedText!), findsOneWidget);
    expect(find.byKey(const Key('s74-recalculate')), findsOneWidget);

    await tapAndSettle(tester, 's74-recalculate');

    expect(find.byKey(const Key('s74-result-loading')), findsOneWidget);
    expect(find.byKey(const Key('s74-register-blocked')), findsNothing);
    expect(find.byKey(const Key('s74-recalculate')), findsNothing);
    expect(find.byKey(const Key('s74-preview-notice')), findsOneWidget);

    completer.complete(expiredResult);
    await tester.pump();
    await tester.pump();

    expect(find.text(AnalyticsLabels.plannerStepResultTitle), findsOneWidget);
    expect(whatIf.simulateCalls, hasLength(2));
    expect(whatIf.simulateCalls[1], whatIf.simulateCalls[0]);
  });

  testWidgets('T74-15 registration slot branches across fixtures', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final expiredResult = singleFixture(
      FixturePaths.m7M7DepositPlanExpired,
      DepositPreviewResult.fromJson,
    );
    final fundingResult = singleFixture(
      FixturePaths.m7M7DepositPlanFunding,
      DepositPreviewResult.fromJson,
    );

    for (final res in [defaultResult, expiredResult, fundingResult]) {
      final plan = res.plan!;
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(res));

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');

      if (plan.registerBlockedText != null) {
        expect(find.byKey(const Key('s74-register-blocked')), findsOneWidget);
        expect(find.text(plan.registerBlockedText!), findsOneWidget);
        expect(find.byKey(const Key('s74-register')), findsNothing);
      } else {
        expect(find.byKey(const Key('s74-register')), findsOneWidget);
        expect(find.byKey(const Key('s74-register-blocked')), findsNothing);
      }

      if (identical(res, fundingResult)) {
        expect(find.byKey(const Key('s74-funding')), findsOneWidget);
      }
    }
  });

  testWidgets('T74-16 single registration submission and arg verification', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final completer = Completer<CommandReceipt>();
    final commandApi = FakePlannerCommandApi(
      registerFn: (_) => completer.future,
    );
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));

    await pumpPlanner(tester, whatIf: whatIf, commandApi: commandApi);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');

    await tapAndSettle(tester, 's74-register');

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('s74-register'))).onPressed,
      isNull,
    );
    expect(
      tester.widget<OutlinedButton>(find.byKey(const Key('s74-recalculate'))).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextButton>(find.byKey(const Key('s74-back'))).onPressed,
      isNull,
    );

    await tapAndSettle(tester, 's74-register');
    expect(commandApi.registrations, hasLength(1));

    final receipt0 = listFixture(
      FixturePaths.m7M7DepositRegisterReceipts4,
      CommandReceipt.fromJson,
    ).rows[0];
    completer.complete(receipt0);
    await tester.pump();
    await tester.pump();

    final expectedPlanId = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    ).plan!.planId;
    expect(commandApi.registrations.single.planId, expectedPlanId);
  });

  testWidgets('T74-17 receipt lock and stream updates', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final receipts = listFixture(
      FixturePaths.m7M7DepositRegisterReceipts4,
      CommandReceipt.fromJson,
    ).rows;

    final streamController = StreamController<CommandReceipt>();
    addTearDown(() {
      unawaited(streamController.close());
    });

    final commandApi = FakePlannerCommandApi(
      registerFn: (_) => Future.value(receipts[0]),
      watchFn: (_) => streamController.stream,
    );
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));

    await pumpPlanner(tester, whatIf: whatIf, commandApi: commandApi);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');
    await tapAndSettle(tester, 's74-register');

    expect(find.byKey(const Key('s74-receipt')), findsOneWidget);
    expect(find.text(receipts[0].stateLabel), findsOneWidget);
    expect(commandApi.watchedIds, [receipts[0].commandId]);
    expect(find.byKey(const Key('s74-register')), findsNothing);
    expect(find.byKey(const Key('s74-recalculate')), findsNothing);
    expect(find.byKey(const Key('s74-back')), findsNothing);

    streamController.add(receipts[1]);
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(find.text(receipts[1].stateLabel), findsOneWidget);

    streamController.add(receipts[2]); // EXPIRED
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(find.text(receipts[2].stateLabel), findsOneWidget);
    expect(find.byKey(const Key('s74-register')), findsNothing);
    expect(find.byKey(const Key('s74-back')), findsNothing);

    streamController.addError(StateError('error'));
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(tester.takeException(), isNotNull);
    expect(find.text(receipts[2].stateLabel), findsOneWidget);
  });

  testWidgets('T74-18 registration failure line and retry recovery', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );

    int callCount = 0;
    final completer = Completer<CommandReceipt>();
    final commandApi = FakePlannerCommandApi(
      registerFn: (_) {
        callCount++;
        if (callCount == 1) return Future.error(StateError('x'));
        return completer.future;
      },
    );
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));

    await pumpPlanner(tester, whatIf: whatIf, commandApi: commandApi);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');
    await tapAndSettle(tester, 's74-register');

    expect(tester.takeException(), isNotNull);
    expect(find.byKey(const Key('s74-register-not-accepted')), findsOneWidget);
    expect(find.text(AnalyticsLabels.plannerRegisterNotAccepted), findsOneWidget);

    final errorTextWidget = tester.widget<Text>(find.byKey(const Key('s74-register-not-accepted')));
    final ColorScheme scheme = Theme.of(
      tester.element(find.byKey(const Key('s74-register-not-accepted'))),
    ).colorScheme;
    expect(errorTextWidget.style?.color, scheme.error);

    final notAcceptedDy = tester.getTopLeft(find.byKey(const Key('s74-register-not-accepted'))).dy;
    final registerDy = tester.getTopLeft(find.byKey(const Key('s74-register'))).dy;
    expect(notAcceptedDy, lessThan(registerDy));

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('s74-register'))).onPressed,
      isNotNull,
    );
    expect(find.byKey(const Key('s74-receipt')), findsNothing);

    // Tap register again -> during submission notAccepted text disappears
    await tapAndSettle(tester, 's74-register');
    expect(find.byKey(const Key('s74-register-not-accepted')), findsNothing);
    expect(commandApi.registrations, hasLength(2));

    // Scene B: registration failure cleared by recalculation
    final commandApiB = FakePlannerCommandApi(
      registerFn: (_) => Future.error(StateError('x')),
    );
    await pumpPlanner(tester, whatIf: whatIf, commandApi: commandApiB);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');
    await tapAndSettle(tester, 's74-register');

    expect(tester.takeException(), isNotNull);
    expect(find.byKey(const Key('s74-register-not-accepted')), findsOneWidget);

    await tapAndSettle(tester, 's74-recalculate');
    expect(find.byKey(const Key('s74-register-not-accepted')), findsNothing);
    expect(find.byKey(const Key('s74-register')), findsOneWidget);
  });

  testWidgets('T74-20 out-of-order calculation responses', (tester) async {
    final setting = singleFixture(
      FixturePaths.m9ContributionSettingDefault,
      ContributionSetting.fromJson,
    );
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final rejectedResult = singleFixture(
      FixturePaths.m7M7DepositPlanInputRejected,
      DepositPreviewResult.fromJson,
    );

    // Scene A: A then B -> B completes with plan -> A completes with rejected -> step allocation kept
    {
      final completerA = Completer<DepositPreviewResult>();
      final completerB = Completer<DepositPreviewResult>();
      int callCount = 0;

      final whatIf = FakeWhatIfApi(
        answerFn: (_) {
          callCount++;
          if (callCount == 1) return completerA.future;
          return completerB.future;
        },
      );

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tester.enterText(
        find.byKey(const Key('s74-amount-field')),
        '${setting.amountInputText}0',
      );
      await tapAndSettle(tester, 's74-calculate');

      completerB.complete(defaultResult);
      await tester.pump();
      await tester.pump();

      expect(find.text(AnalyticsLabels.plannerStepAllocationTitle), findsOneWidget);

      completerA.complete(rejectedResult);
      await tester.pump();
      await tester.pump();

      expect(find.text(AnalyticsLabels.plannerStepAllocationTitle), findsOneWidget);
      expect(find.byKey(const Key('s74-input-rejected')), findsNothing);
      expect(whatIf.simulateCalls, hasLength(2));
    }

    // Scene B: A then B -> A completes with plan -> ignored -> B completes with rejected -> step input with rejected
    {
      final completerA = Completer<DepositPreviewResult>();
      final completerB = Completer<DepositPreviewResult>();
      int callCount = 0;

      final whatIf = FakeWhatIfApi(
        answerFn: (_) {
          callCount++;
          if (callCount == 1) return completerA.future;
          return completerB.future;
        },
      );

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tester.enterText(
        find.byKey(const Key('s74-amount-field')),
        '${setting.amountInputText}0',
      );
      await tapAndSettle(tester, 's74-calculate');

      completerA.complete(defaultResult);
      await tester.pump();
      await tester.pump();

      expect(find.text(AnalyticsLabels.plannerStepAmountTitle), findsOneWidget);
      expect(find.byKey(const Key('s74-result-loading')), findsOneWidget);

      completerB.complete(rejectedResult);
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('s74-input-rejected')), findsOneWidget);
      expect(whatIf.simulateCalls, hasLength(2));
    }
  });

  testWidgets('T74-21 layout chains across all three steps', (tester) async {
    final whatIf = FakeWhatIfApi();
    final safetyState = SafetyState.fromJson(
      fixtureEnvelope(FixturePaths.safetyStates).rows[0],
    );

    // Step 1
    await pumpPlanner(tester, whatIf: whatIf, safetyState: safetyState);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    final titleDy = tester.getTopLeft(find.byKey(const Key('s74-step-title'))).dy;
    final introDy = tester.getTopLeft(find.byKey(const Key('s74-intro'))).dy;
    final headerDy = tester.getTopLeft(find.byKey(const Key('s74-setting-header'))).dy;
    final amountDy = tester.getTopLeft(find.byKey(const Key('s74-setting-amount'))).dy;
    final equivDy = tester.getTopLeft(find.byKey(const Key('s74-setting-equivalent'))).dy;
    final appliesDy = tester.getTopLeft(find.byKey(const Key('s74-setting-applies'))).dy;
    final limitNoteDy = tester.getTopLeft(find.byKey(const Key('s74-setting-limit-note'))).dy;
    final asOfDy = tester.getTopLeft(find.byKey(const Key('s74-setting-asof'))).dy;
    final fieldDy = tester.getTopLeft(find.byKey(const Key('s74-amount-field'))).dy;
    final calcDy = tester.getTopLeft(find.byKey(const Key('s74-calculate'))).dy;

    expect(titleDy, lessThan(introDy));
    expect(introDy, lessThan(headerDy));
    expect(headerDy, lessThan(amountDy));
    expect(amountDy, lessThan(equivDy));
    expect(equivDy, lessThan(appliesDy));
    expect(appliesDy, lessThan(limitNoteDy));
    expect(limitNoteDy, lessThan(asOfDy));
    expect(asOfDy, lessThan(fieldDy));
    expect(fieldDy, lessThan(calcDy));

    // Step 2
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final limitResult = singleFixture(
      FixturePaths.m7M7DepositPlanLimit,
      DepositPreviewResult.fromJson,
    );
    final fundingResult = singleFixture(
      FixturePaths.m7M7DepositPlanFunding,
      DepositPreviewResult.fromJson,
    );

    for (final res in [defaultResult, limitResult, fundingResult]) {
      final whatIfStep2 = FakeWhatIfApi(answerFn: (_) => Future.value(res));
      await pumpPlanner(tester, whatIf: whatIfStep2);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');

      final pNoticeDy = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
      final pTitleDy = tester.getTopLeft(find.byKey(const Key('s74-step-title'))).dy;
      final pAsOfDy = tester.getTopLeft(find.byKey(const Key('s74-asof'))).dy;
      expect(pNoticeDy, lessThan(pTitleDy));
      expect(pTitleDy, lessThan(pAsOfDy));

      double currentDy = pAsOfDy;
      if (res.plan!.warningLines.isNotEmpty) {
        final warnDy = tester.getTopLeft(find.byKey(const Key('s74-warning-0'))).dy;
        expect(currentDy, lessThan(warnDy));
        currentDy = warnDy;
      } else {
        expect(find.byKey(const Key('s74-warning-0')), findsNothing);
      }

      final depAmtDy = tester.getTopLeft(find.byKey(const Key('s74-deposit-amount'))).dy;
      expect(currentDy, lessThan(depAmtDy));
      currentDy = depAmtDy;

      final alloc0Dy = tester.getTopLeft(find.byKey(const Key('s74-allocation-0'))).dy;
      expect(currentDy, lessThan(alloc0Dy));
      currentDy = alloc0Dy;

      if (res.plan!.residualKrwCashText != null) {
        final resDy = tester.getTopLeft(find.byKey(const Key('s74-residual'))).dy;
        expect(currentDy, lessThan(resDy));
        currentDy = resDy;
      } else {
        expect(find.byKey(const Key('s74-residual')), findsNothing);
      }

      if (res.plan!.pensionLimit != null) {
        final plDy = tester.getTopLeft(find.byKey(const Key('s74-pension-limit'))).dy;
        expect(currentDy, lessThan(plDy));
        currentDy = plDy;
      } else {
        expect(find.byKey(const Key('s74-pension-limit')), findsNothing);
      }

      final nextDy = tester.getTopLeft(find.byKey(const Key('s74-next'))).dy;
      expect(currentDy, lessThan(nextDy));

      final backDy = tester.getTopLeft(find.byKey(const Key('s74-back'))).dy;
      expect(nextDy, lessThan(backDy));
    }

    // Step 3
    final expiredResult = singleFixture(
      FixturePaths.m7M7DepositPlanExpired,
      DepositPreviewResult.fromJson,
    );
    final resultsForStep3 = [defaultResult, limitResult, expiredResult, fundingResult];

    int staleCount = 0;
    for (final res in resultsForStep3) {
      final isStale = res.plan!.asOf.observedAt.add(res.plan!.asOf.staleAfter).isBefore(kGoldenNowUtc);
      if (isStale) staleCount++;
    }
    expect(staleCount, 1);

    for (final res in resultsForStep3) {
      final whatIfStep3 = FakeWhatIfApi(answerFn: (_) => Future.value(res));
      await pumpPlanner(tester, whatIf: whatIfStep3);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');

      final pNoticeDy = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
      double currentDy = pNoticeDy;

      final isStale = res.plan!.asOf.observedAt.add(res.plan!.asOf.staleAfter).isBefore(kGoldenNowUtc);
      if (isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
        final staleDy = tester.getTopLeft(find.text(AnalyticsLabels.staleBannerTitle)).dy;
        expect(currentDy, lessThan(staleDy));
        currentDy = staleDy;
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }

      final asOfDy = tester.getTopLeft(find.byKey(const Key('s74-asof'))).dy;
      expect(currentDy, lessThan(asOfDy));
      currentDy = asOfDy;

      if (res.plan!.warningLines.isNotEmpty) {
        final warnDy = tester.getTopLeft(find.byKey(const Key('s74-warning-0'))).dy;
        expect(currentDy, lessThan(warnDy));
        currentDy = warnDy;
      } else {
        expect(find.byKey(const Key('s74-warning-0')), findsNothing);
      }

      if (res.plan!.ordersEmptyText != null) {
        final emptyDy = tester.getTopLeft(find.byKey(const Key('s74-orders-empty'))).dy;
        expect(currentDy, lessThan(emptyDy));
        currentDy = emptyDy;
      } else {
        final order0Dy = tester.getTopLeft(find.byKey(const Key('s74-order-0'))).dy;
        expect(currentDy, lessThan(order0Dy));
        currentDy = order0Dy;
      }

      final costsDy = tester.getTopLeft(find.byKey(const Key('s74-costs'))).dy;
      expect(currentDy, lessThan(costsDy));
      currentDy = costsDy;

      if (res.plan!.fundingSteps != null && res.plan!.fundingSteps!.isNotEmpty) {
        final fundingDy = tester.getTopLeft(find.byKey(const Key('s74-funding'))).dy;
        expect(currentDy, lessThan(fundingDy));
        currentDy = fundingDy;
      } else {
        expect(find.byKey(const Key('s74-funding')), findsNothing);
      }

      if (res.plan!.registerBlockedText != null) {
        final regBlockedDy = tester.getTopLeft(find.byKey(const Key('s74-register-blocked'))).dy;
        expect(currentDy, lessThan(regBlockedDy));
        currentDy = regBlockedDy;
      } else {
        final regDy = tester.getTopLeft(find.byKey(const Key('s74-register'))).dy;
        expect(currentDy, lessThan(regDy));
        currentDy = regDy;
      }

      final recalcDy = tester.getTopLeft(find.byKey(const Key('s74-recalculate'))).dy;
      expect(currentDy, lessThan(recalcDy));

      final backDy = tester.getTopLeft(find.byKey(const Key('s74-back'))).dy;
      expect(recalcDy, lessThan(backDy));
    }
  });

  testWidgets('T74-22 planner library export structure', (tester) async {
    final plannerFile = File('lib/planner.dart');
    final content = plannerFile.readAsStringSync();
    final exportLines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('export '))
        .toSet();

    expect(exportLines, {
      "export 'src/planner/deposit_planner_screen.dart';",
      "export 'src/planner/planner_providers.dart';",
    });

    final checkDirs = [
      'lib/ui_analytics.dart',
      'lib/src/screens',
      'lib/src/widgets',
      'lib/src/providers',
    ];

    for (final path in checkDirs) {
      if (FileSystemEntity.isFileSync(path)) {
        final text = File(path).readAsStringSync();
        expect(text.contains('planner'), isFalse, reason: 'File $path must not contain planner');
      } else if (FileSystemEntity.isDirectorySync(path)) {
        for (final file in Directory(path).listSync(recursive: true)) {
          if (file is File && file.path.endsWith('.dart')) {
            final text = file.readAsStringSync();
            expect(text.contains('planner'), isFalse, reason: 'File ${file.path} must not contain planner');
          }
        }
      }
    }
  });

  testWidgets('T74-23 safety block banner in steps 1 and 2', (tester) async {
    final safetyStates = fixtureEnvelope(FixturePaths.safetyStates).rows;
    final row3 = SafetyState.fromJson(safetyStates[3]);
    final row4 = SafetyState.fromJson(safetyStates[4]);
    final row0 = SafetyState.fromJson(safetyStates[0]);

    for (final sState in [row3, row4]) {
      final whatIf = FakeWhatIfApi();
      final opener = RecordingLinkOpener();

      await pumpPlanner(tester, whatIf: whatIf, safetyState: sState, opener: opener);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      final expectedFlagsCount = identical(sState, row3) ? 2 : 1;
      expect(sState.activeFlags, hasLength(expectedFlagsCount));

      for (final flag in sState.activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
      }

      final bannerDy = tester.getTopLeft(find.byType(SafetyBlockBanner)).dy;
      final titleDy = tester.getTopLeft(find.byKey(const Key('s74-step-title'))).dy;
      expect(bannerDy, lessThan(titleDy));

      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).enabled,
        isNot(false),
      );
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('s74-calculate'))).onPressed,
        isNotNull,
      );

      final chevrons = find.descendant(
        of: find.byType(SafetyBlockBanner),
        matching: find.byIcon(Icons.chevron_right),
      );
      for (int i = 0; i < sState.activeFlags.length; i++) {
        expect(sState.activeFlags[i].clearDeepLink, isNotNull);
        await tester.tap(chevrons.at(i));
        await tester.pump();
        expect(opener.opened.last, sState.activeFlags[i].clearDeepLink);
      }
    }

    // Normal safety state (row 0) -> no banner
    final whatIfNormal = FakeWhatIfApi();
    await pumpPlanner(tester, whatIf: whatIfNormal, safetyState: row0);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    expect(find.byType(SafetyBlockBanner), findsNothing);

    // Step 2 banner position check
    final whatIfStep2 = FakeWhatIfApi();
    await pumpPlanner(tester, whatIf: whatIfStep2, safetyState: row3);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');

    final noticeDy = tester.getTopLeft(find.byKey(const Key('s74-preview-notice'))).dy;
    final bannerDyStep2 = tester.getTopLeft(find.byType(SafetyBlockBanner)).dy;
    final titleDyStep2 = tester.getTopLeft(find.byKey(const Key('s74-step-title'))).dy;

    expect(noticeDy, lessThan(bannerDyStep2));
    expect(bannerDyStep2, lessThan(titleDyStep2));
  });

  testWidgets('T74-24 stale banner presence based on clock', (tester) async {
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));

    // Fresh clock (kGoldenNowUtc)
    await pumpPlanner(tester, whatIf: whatIf, clock: FixedClock(kGoldenNowUtc));
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
    await tapAndSettle(tester, 's74-next');
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);

    // Stale clock (+3 days)
    final staleClock = FixedClock(kGoldenNowUtc.add(const Duration(days: 3)));
    await pumpPlanner(tester, whatIf: whatIf, clock: staleClock);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // In step 1 with stale clock, no stale banner
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
    await tapAndSettle(tester, 's74-next');
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
  });

  testWidgets('T74-25 setting stream loading and error states', (tester) async {
    // ⓐ Setting loading state
    {
      final streamController = StreamController<ContributionSetting>();
      addTearDown(() {
        unawaited(streamController.close());
      });
      final config = FakeConfigRepository(
        settingStreamFactory: () => streamController.stream,
      );
      final whatIf = FakeWhatIfApi();

      await pumpPlanner(tester, whatIf: whatIf, config: config);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      expect(find.byKey(const Key('s74-setting-loading')), findsOneWidget);
      expect(
        tester.widget<AnalyticsSkeleton>(find.byKey(const Key('s74-setting-loading'))).blocks,
        2,
      );
      expect(find.byKey(const Key('s74-setting-amount')), findsNothing);
      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        isEmpty,
      );
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('s74-calculate'))).onPressed,
        isNotNull,
      );
    }

    // ⓑ Setting error state and retry
    {
      int callCount = 0;
      final defaultSetting = singleFixture(
        FixturePaths.m9ContributionSettingDefault,
        ContributionSetting.fromJson,
      );
      final config = FakeConfigRepository(
        settingStreamFactory: () {
          callCount++;
          if (callCount == 1) {
            return Stream<ContributionSetting>.error(StateError('x'));
          }
          return Stream<ContributionSetting>.value(defaultSetting);
        },
      );
      final whatIf = FakeWhatIfApi();

      await pumpPlanner(tester, whatIf: whatIf, config: config);

      expect(find.byKey(const Key('s74-setting-error')), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
      expect(find.byKey(const Key('s74-amount-field')), findsOneWidget);
      expect(find.byKey(const Key('s74-calculate')), findsOneWidget);

      await tapAndSettle(tester, 's74-setting-error');

      expect(config.watchContributionSettingCalls, 2);
      expect(find.byKey(const Key('s74-setting-amount')), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        defaultSetting.amountInputText,
      );
    }
  });

  testWidgets('T74-26 return to step 1 on recalculate rejection or back buttons', (tester) async {
    final setting = singleFixture(
      FixturePaths.m9ContributionSettingDefault,
      ContributionSetting.fromJson,
    );
    final defaultResult = singleFixture(
      FixturePaths.m7M7DepositPlanDefault,
      DepositPreviewResult.fromJson,
    );
    final rejectedResult = singleFixture(
      FixturePaths.m7M7DepositPlanInputRejected,
      DepositPreviewResult.fromJson,
    );
    final blockedList = listFixture(
      FixturePaths.m7M7DepositPlanBlocked,
      DepositPreviewResult.fromJson,
    );

    // ⓐ Recalculate leads to rejected, blocked, error
    final secondAnswers = [
      rejectedResult,
      blockedList.rows[0],
      null, // error
    ];

    for (int i = 0; i < secondAnswers.length; i++) {
      final answer = secondAnswers[i];
      int callCount = 0;
      final whatIf = FakeWhatIfApi(
        answerFn: (_) {
          callCount++;
          if (callCount == 1) return Future.value(defaultResult);
          if (answer != null) return Future.value(answer);
          return Future.error(StateError('calc error'));
        },
      );

      await pumpPlanner(tester, whatIf: whatIf);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');
      await tapAndSettle(tester, 's74-recalculate');

      expect(find.text(AnalyticsLabels.plannerStepAmountTitle), findsOneWidget);
      expect(find.byKey(const Key('s74-preview-notice')), findsNothing);
      expect(
        tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
        setting.amountInputText,
      );

      if (i == 0) {
        expect(find.byKey(const Key('s74-input-rejected')), findsOneWidget);
      } else if (i == 1) {
        expect(find.byKey(const Key('s74-blocked-card')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s74-result-error')), findsOneWidget);
        await tapAndSettle(tester, 's74-result-error');
        expect(whatIf.simulateCalls, hasLength(3));
        expect(whatIf.simulateCalls[0], whatIf.simulateCalls[1]);
        expect(whatIf.simulateCalls[1], whatIf.simulateCalls[2]);
      }
    }

    // ⓑ Back button navigation from step 3 to step 2 to step 1
    final whatIfNav = FakeWhatIfApi(answerFn: (_) => Future.value(defaultResult));
    await pumpPlanner(tester, whatIf: whatIfNav);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    await tapAndSettle(tester, 's74-next');

    // On step 3, tap back -> step 2
    await tapAndSettle(tester, 's74-back');
    expect(find.text(AnalyticsLabels.plannerStepAllocationTitle), findsOneWidget);
    expect(find.byKey(const Key('s74-next')), findsOneWidget);

    // On step 2, tap back -> step 1
    await tapAndSettle(tester, 's74-back');
    expect(find.text(AnalyticsLabels.plannerStepAmountTitle), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(const Key('s74-amount-field'))).controller!.text,
      setting.amountInputText,
    );
    expect(find.byKey(const Key('s74-preview-notice')), findsNothing);

    await tapAndSettle(tester, 's74-calculate');
    expect(whatIfNav.simulateCalls, hasLength(2));
  });
}
