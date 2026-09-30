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

  testWidgets('T74-21 step 1 layout chain', (tester) async {
    final whatIf = FakeWhatIfApi();
    final safetyState = SafetyState.fromJson(
      fixtureEnvelope(FixturePaths.safetyStates).rows[0],
    );

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
}
