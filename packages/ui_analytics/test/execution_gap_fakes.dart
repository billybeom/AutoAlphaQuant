import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'explore_fakes.dart' show FakeSafetyRepository;
import 'golden/golden_support.dart';

class FakeExecutionGapRepository extends UnimplementedExecutionGapRepository {
  FakeExecutionGapRepository({this.result, this.error, this.completer});

  final ExecutionGapResult? result;
  final Object? error;
  final Completer<ExecutionGapResult>? completer;

  final List<String?> monthlyCalls = <String?>[];

  @override
  Future<ExecutionGapResult> monthly({String? yyyyMm}) {
    monthlyCalls.add(yyyyMm);
    if (completer != null) {
      return completer!.future;
    }
    if (error != null) {
      return Future<ExecutionGapResult>.error(error!);
    }
    return Future<ExecutionGapResult>.value(result!);
  }
}

List<Override> executionGapOverrides({
  required FakeExecutionGapRepository repo,
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
    executionGapRepositoryProvider.overrideWithValue(repo),
    safetyRepositoryProvider.overrideWithValue(FakeSafetyRepository(safety)),
  ];
}
