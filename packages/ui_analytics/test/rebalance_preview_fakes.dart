import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'explore_fakes.dart' show FakeSafetyRepository;
import 'golden/golden_support.dart';

class FakeNextRebalanceRepository extends UnimplementedRebalanceRepository {
  FakeNextRebalanceRepository({this.vm, this.streamFactory});

  final NextRebalanceVm? vm;
  final Stream<NextRebalanceVm> Function(int call)? streamFactory;

  int watchNextCalls = 0;
  final List<String> otherCalls = <String>[];

  @override
  Stream<NextRebalanceVm> watchNext() {
    watchNextCalls += 1;
    if (streamFactory != null) {
      return streamFactory!(watchNextCalls);
    }
    return Stream<NextRebalanceVm>.value(vm!);
  }

  @override
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range}) {
    otherCalls.add('watchEvents');
    return super.watchEvents(range: range);
  }

  @override
  Stream<RebalanceEvent> watchEvent(String id) {
    otherCalls.add('watchEvent');
    return super.watchEvent(id);
  }
}

class FakeRebalancePreviewApi extends UnimplementedWhatIfApi {
  FakeRebalancePreviewApi({this.result, this.answerFn});

  final RebalancePreviewResult? result;
  final Future<RebalancePreviewResult> Function(int call)? answerFn;

  final List<TradeDate?> previewCalls = <TradeDate?>[];
  final List<String> otherCalls = <String>[];

  @override
  Future<RebalancePreviewResult> previewRebalance({TradeDate? plannedDate}) {
    previewCalls.add(plannedDate);
    if (answerFn != null) {
      return answerFn!(previewCalls.length);
    }
    return Future<RebalancePreviewResult>.value(
      result ??
          singleFixture(
            FixturePaths.m7M7RebalancePreviewDefault,
            RebalancePreviewResult.fromJson,
          ),
    );
  }

  @override
  Future<DepositPreviewResult> simulateDeposit({required String amountInput}) {
    otherCalls.add('simulateDeposit');
    return super.simulateDeposit(amountInput: amountInput);
  }

  @override
  Future<WithdrawalPlan> simulateWithdrawal({required amount}) {
    otherCalls.add('simulateWithdrawal');
    return super.simulateWithdrawal(amount: amount);
  }

  @override
  Future<CostEstimate> estimateCosts(String planId) {
    otherCalls.add('estimateCosts');
    return super.estimateCosts(planId);
  }

  @override
  Future<DepositPlan?> findPlan(String planId) {
    otherCalls.add('findPlan');
    return super.findPlan(planId);
  }
}

List<Override> rebalancePreviewOverrides({
  required FakeNextRebalanceRepository repo,
  FakeRebalancePreviewApi? whatIf,
  SafetyState? safetyState,
  Clock? clock,
  RecordingLinkOpener? opener,
}) {
  final SafetyState state =
      safetyState ??
      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[0]);
  return <Override>[
    analyticsClockProvider.overrideWithValue(
      clock ?? FixedClock(kGoldenNowUtc),
    ),
    analyticsLinkOpenerProvider.overrideWithValue(
      opener ?? RecordingLinkOpener(),
    ),
    safetyRepositoryProvider.overrideWithValue(FakeSafetyRepository(state)),
    rebalanceRepositoryProvider.overrideWithValue(repo),
    analyticsWhatIfApiProvider.overrideWithValue(whatIf),
  ];
}

Future<void> pumpRebalancePreview(
  WidgetTester tester, {
  required FakeNextRebalanceRepository repo,
  FakeRebalancePreviewApi? whatIf,
  SafetyState? safetyState,
  Clock? clock,
  RecordingLinkOpener? opener,
  Size viewSize = const Size(390, 2400),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: rebalancePreviewOverrides(
        repo: repo,
        whatIf: whatIf,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      ),
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(body: RebalancePreviewScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}
