// packages/ui_analytics/test/rebalance_fakes.dart
// S7-6a·S7-6b 테스트 공용 가짜·띄우기 도우미.
//
// 가짜는 받침대 extends — implements 금지.
// 받은 인자 전부 기록 · 호출마다 새 Stream.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'explore_fakes.dart' show FakeSafetyRepository;
import 'golden/golden_support.dart';

class FakeRebalanceRepository extends UnimplementedRebalanceRepository {
  FakeRebalanceRepository({
    this.events,
    this.event,
    this.error,
    this.eventsController,
    this.eventController,
  });

  final ListResult<RebalanceEvent>? events;
  final RebalanceEvent? event;
  final Object? error;
  final StreamController<ListResult<RebalanceEvent>>? eventsController;
  final StreamController<RebalanceEvent>? eventController;

  final List<DateRange?> watchEventsCalls = <DateRange?>[];
  final List<String> watchEventCalls = <String>[];

  @override
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range}) {
    watchEventsCalls.add(range);
    if (eventsController != null) {
      return eventsController!.stream;
    }
    if (error != null) {
      return Stream<ListResult<RebalanceEvent>>.error(error!);
    }
    return Stream<ListResult<RebalanceEvent>>.value(events!);
  }

  @override
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId) {
    watchEventCalls.add(rebalanceEventId);
    if (eventController != null) {
      return eventController!.stream;
    }
    if (error != null) {
      return Stream<RebalanceEvent>.error(error!);
    }
    return Stream<RebalanceEvent>.value(event!);
  }
}

/// rebalance_6 의 계절 회차 · 월간 정기 회차를 고르는 id(표시 글자 아님).
const String kSeasonalEventId = 're_20261030_01';
const String kMonthlyEventId = 're_20260701_01';

/// rebalance_6 픽스처 행을 id 로 고르는 슬라이스.
RebalanceEvent rebalance6Event(String eventId) => listFixture(
  FixturePaths.rebalance6,
  RebalanceEvent.fromJson,
).rows.firstWhere((RebalanceEvent e) => e.eventId == eventId);

List<Override> rebalanceOverrides({
  required FakeRebalanceRepository repo,
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
    rebalanceRepositoryProvider.overrideWithValue(repo),
    safetyRepositoryProvider.overrideWithValue(FakeSafetyRepository(safety)),
  ];
}

Future<void> pumpRebalance(
  WidgetTester tester, {
  required FakeRebalanceRepository repo,
  required Widget screen,
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
      overrides: rebalanceOverrides(
        repo: repo,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      ),
      child: MaterialApp(home: Scaffold(body: screen)),
    ),
  );
  await tester.pump();
}
