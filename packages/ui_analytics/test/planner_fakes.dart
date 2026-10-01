// test/planner_fakes.dart

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/planner.dart';
import 'package:ui_analytics/src/providers/analytics_providers.dart';

import 'explore_fakes.dart' show FakeSafetyRepository;
import 'golden/golden_support.dart';

class FakeWhatIfApi extends UnimplementedWhatIfApi {
  FakeWhatIfApi({this.answerFn});

  final Future<DepositPreviewResult> Function(String amountInput)? answerFn;
  final List<String> simulateCalls = [];
  final List<String> otherCalls = [];

  @override
  Future<DepositPreviewResult> simulateDeposit({required String amountInput}) {
    simulateCalls.add(amountInput);
    if (answerFn != null) {
      return answerFn!(amountInput);
    }
    return Future<DepositPreviewResult>.value(
      singleFixture(
        FixturePaths.m7M7DepositPlanDefault,
        DepositPreviewResult.fromJson,
      ),
    );
  }

  @override
  Future<WithdrawalPlan> simulateWithdrawal({required amount}) {
    otherCalls.add('simulateWithdrawal');
    return super.simulateWithdrawal(amount: amount);
  }

  @override
  Future<RebalancePreview> previewRebalance({plannedDate}) {
    otherCalls.add('previewRebalance');
    return super.previewRebalance(plannedDate: plannedDate);
  }

  @override
  Future<CostEstimate> estimateCosts(planId) {
    otherCalls.add('estimateCosts');
    return super.estimateCosts(planId);
  }

  @override
  Future<DepositPlan?> findPlan(planId) {
    otherCalls.add('findPlan');
    return super.findPlan(planId);
  }
}

class FakeConfigRepository extends UnimplementedConfigRepository {
  FakeConfigRepository({this.settingStreamFactory});

  final Stream<ContributionSetting> Function()? settingStreamFactory;
  int watchContributionSettingCalls = 0;

  @override
  Stream<ContributionSetting> watchContributionSetting() {
    watchContributionSettingCalls++;
    if (settingStreamFactory != null) {
      return settingStreamFactory!();
    }
    return Stream<ContributionSetting>.value(
      singleFixture(
        FixturePaths.m9ContributionSettingDefault,
        ContributionSetting.fromJson,
      ),
    );
  }
}

class FakePlannerCommandApi extends UnimplementedCommandApi {
  FakePlannerCommandApi({this.registerFn, this.watchFn});

  final Future<CommandReceipt> Function(DepositRegistration registration)?
  registerFn;
  final Stream<CommandReceipt> Function(String commandId)? watchFn;

  final List<DepositRegistration> registrations = [];
  final List<String> watchedIds = [];
  CommandReceipt? _lastReceipt;

  @override
  Future<CommandReceipt> registerDeposit(DepositRegistration registration) {
    registrations.add(registration);
    if (registerFn != null) {
      return registerFn!(registration);
    }
    final receipt = listFixture(
      FixturePaths.m7M7DepositRegisterReceipts4,
      CommandReceipt.fromJson,
    ).rows[0];
    _lastReceipt = receipt;
    return Future<CommandReceipt>.value(receipt);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    watchedIds.add(commandId);
    if (watchFn != null) {
      return watchFn!(commandId);
    }
    final receipt =
        _lastReceipt ??
        listFixture(
          FixturePaths.m7M7DepositRegisterReceipts4,
          CommandReceipt.fromJson,
        ).rows[0];
    return Stream<CommandReceipt>.value(receipt);
  }
}

List<Override> plannerOverrides({
  required WhatIfApi whatIf,
  ConfigRepository? config,
  CommandApi? commandApi,
  SafetyState? safetyState,
  Clock? clock,
  AppLinkOpener? opener,
}) {
  final SafetyState defaultSafety = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[0],
  );
  return [
    analyticsClockProvider.overrideWithValue(
      clock ?? FixedClock(kGoldenNowUtc),
    ),
    analyticsLinkOpenerProvider.overrideWithValue(
      opener ?? RecordingLinkOpener(),
    ),
    safetyRepositoryProvider.overrideWithValue(
      FakeSafetyRepository(safetyState ?? defaultSafety),
    ),
    plannerWhatIfApiProvider.overrideWithValue(whatIf),
    plannerConfigRepositoryProvider.overrideWithValue(
      config ?? FakeConfigRepository(),
    ),
    plannerCommandApiProvider.overrideWithValue(
      commandApi ?? FakePlannerCommandApi(),
    ),
  ];
}

Future<void> pumpPlanner(
  WidgetTester tester, {
  required WhatIfApi whatIf,
  ConfigRepository? config,
  CommandApi? commandApi,
  SafetyState? safetyState,
  Clock? clock,
  AppLinkOpener? opener,
  Size viewSize = const Size(390, 2400),
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: plannerOverrides(
        whatIf: whatIf,
        config: config,
        commandApi: commandApi,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      ),
      child: const MaterialApp(home: Scaffold(body: DepositPlannerScreen())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> tapAndSettle(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
  await tester.pump();
}
