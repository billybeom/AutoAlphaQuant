// packages/ui_analytics/test/goal_path_fakes.dart
// S7-9 테스트 공용 가짜·띄우기 도우미.
//
// 가짜는 받침대 extends — implements 금지.
// 받은 인자 전부 기록 · 호출마다 새 Future.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'explore_fakes.dart' show FakeSafetyRepository;
import 'golden/golden_support.dart';

class FakeGoalPathRepository extends UnimplementedPerformanceRepository {
  FakeGoalPathRepository({
    this.vm,
    this.error,
    this.completer,
  });

  final GoalPathVm? vm;
  final Object? error;
  final Completer<GoalPathVm>? completer;

  final List<String> goalPathCalls = <String>[];

  @override
  Future<GoalPathVm> goalPath({required String yyyyMm}) {
    goalPathCalls.add(yyyyMm);
    if (completer != null) {
      return completer!.future;
    }
    if (error != null) {
      return Future<GoalPathVm>.error(error!);
    }
    return Future<GoalPathVm>.value(vm!);
  }
}

List<Override> goalPathOverrides({
  required FakeGoalPathRepository repo,
  SafetyState? safetyState,
  Clock? clock,
  RecordingLinkOpener? opener,
}) {
  final SafetyState safety =
      safetyState ??
      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[0]);
  final Clock effectiveClock = clock ?? FixedClock(kGoldenNowUtc);
  final RecordingLinkOpener effectiveOpener = opener ?? RecordingLinkOpener();
  return <Override>[
    analyticsClockProvider.overrideWithValue(effectiveClock),
    analyticsLinkOpenerProvider.overrideWithValue(effectiveOpener),
    performanceRepositoryProvider.overrideWithValue(repo),
    safetyRepositoryProvider.overrideWithValue(FakeSafetyRepository(safety)),
  ];
}

Future<void> pumpGoalPath(
  WidgetTester tester, {
  required FakeGoalPathRepository repo,
  required String yyyyMm,
  SafetyState? safetyState,
  Clock? clock,
  RecordingLinkOpener? opener,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: goalPathOverrides(
        repo: repo,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      ),
      child: MaterialApp(
        home: Scaffold(body: GoalPathScreen(yyyyMm: yyyyMm)),
      ),
    ),
  );
  await tester.pump();
}
