// packages/ui_analytics/test/annual_review_fakes.dart
// S7-7 테스트 공용 가짜·띄우기 도우미.
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

class FakeAnnualReviewRepository extends UnimplementedPerformanceRepository {
  FakeAnnualReviewRepository({this.vm, this.error, this.completer});

  final AnnualReviewVm? vm;
  final Object? error;
  final Completer<AnnualReviewVm>? completer;

  final List<String?> annualReviewCalls = <String?>[];
  final List<String> afterTaxLadderCalls = <String>[];
  final List<String> monthlyReportCalls = <String>[];

  @override
  Future<AnnualReviewVm> annualReview({String? year}) {
    annualReviewCalls.add(year);
    if (completer != null) {
      return completer!.future;
    }
    if (error != null) {
      return Future<AnnualReviewVm>.error(error!);
    }
    return Future<AnnualReviewVm>.value(vm!);
  }

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) {
    afterTaxLadderCalls.add(fiscalYear);
    return Future<AfterTaxLadder>.error(UnimplementedError('afterTaxLadder'));
  }

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) {
    monthlyReportCalls.add(yyyyMm);
    return Future<MonthlyReport>.error(UnimplementedError('monthlyReport'));
  }
}

List<Override> annualReviewOverrides({
  required FakeAnnualReviewRepository repo,
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

Future<void> pumpAnnualReview(
  WidgetTester tester, {
  required FakeAnnualReviewRepository repo,
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
      overrides: annualReviewOverrides(
        repo: repo,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      ),
      child: const MaterialApp(home: Scaffold(body: AnnualReviewScreen())),
    ),
  );
  await tester.pump();
}
