// test/golden/s74_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/planner.dart';

import '../planner_fakes.dart';
import 'golden_support.dart';

const double kHeightStep1Default = 844;
const double kHeightStep2Normal = 844;
const double kHeightStep3Normal = 1100;
const double kHeightPensionLimitHit = 844;
const double kHeightExpired = 1100;
const double kHeightFunding = 1300;
const double kHeightBlocked = 844;

void main() {
  final settingDefault = singleFixture(
    FixturePaths.m9ContributionSettingDefault,
    ContributionSetting.fromJson,
  );
  final planDefault = singleFixture(
    FixturePaths.m7M7DepositPlanDefault,
    DepositPreviewResult.fromJson,
  );
  final planLimit = singleFixture(
    FixturePaths.m7M7DepositPlanLimit,
    DepositPreviewResult.fromJson,
  );
  final planExpired = singleFixture(
    FixturePaths.m7M7DepositPlanExpired,
    DepositPreviewResult.fromJson,
  );
  final planFunding = singleFixture(
    FixturePaths.m7M7DepositPlanFunding,
    DepositPreviewResult.fromJson,
  );
  final planBlockedList = listFixture(
    FixturePaths.m7M7DepositPlanBlocked,
    DepositPreviewResult.fromJson,
  );
  final safetyRows = fixtureEnvelope(FixturePaths.safetyStates).rows;
  final safetyRow0 = SafetyState.fromJson(safetyRows[0]);
  final safetyRow3 = SafetyState.fromJson(safetyRows[3]);
  final safetyRow4 = SafetyState.fromJson(safetyRows[4]);

  for (final Brightness b in Brightness.values) {
    testWidgets('s74_step1_default ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi();
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow0,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightStep1Default),
      );

      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-calculate'))).dy,
        lessThan(kHeightStep1Default),
      );

      await expectGolden('s74_step1_default', b);
    });

    testWidgets('s74_step2_normal ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(planDefault));
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow0,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightStep2Normal),
      );

      await tapAndSettle(tester, 's74-calculate');
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-back'))).dy,
        lessThan(kHeightStep2Normal),
      );

      await expectGolden('s74_step2_normal', b);
    });

    testWidgets('s74_step3_normal ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(planDefault));
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow0,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightStep3Normal),
      );

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-back'))).dy,
        lessThan(kHeightStep3Normal),
      );

      await expectGolden('s74_step3_normal', b);
    });

    testWidgets('s74_pension_limit_hit ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(planLimit));
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow0,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightPensionLimitHit),
      );

      await tapAndSettle(tester, 's74-calculate');
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-back'))).dy,
        lessThan(kHeightPensionLimitHit),
      );

      await expectGolden('s74_pension_limit_hit', b);
    });

    testWidgets('s74_expired ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(planExpired));
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow0,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightExpired),
      );

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-back'))).dy,
        lessThan(kHeightExpired),
      );

      await expectGolden('s74_expired', b);
    });

    testWidgets('s74_funding ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi(answerFn: (_) => Future.value(planFunding));
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow3,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightFunding),
      );

      await tapAndSettle(tester, 's74-calculate');
      await tapAndSettle(tester, 's74-next');
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-back'))).dy,
        lessThan(kHeightFunding),
      );

      await expectGolden('s74_funding', b);
    });

    testWidgets('s74_blocked ${brightnessSuffix(b)}', (tester) async {
      final whatIf = FakeWhatIfApi(
        answerFn: (_) => Future.value(planBlockedList.rows[0]),
      );
      final config = FakeConfigRepository(
        settingStreamFactory: () => Stream.value(settingDefault),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: plannerOverrides(
            whatIf: whatIf,
            config: config,
            safetyState: safetyRow4,
          ),
          child: const DepositPlannerScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, kHeightBlocked),
      );

      await tapAndSettle(tester, 's74-calculate');
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const Key('s74-blocked-card'))).dy,
        lessThan(kHeightBlocked),
      );

      await expectGolden('s74_blocked', b);
    });
  }
}
