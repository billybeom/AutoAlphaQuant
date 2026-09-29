// test/explore_fakes.dart
// S7-2G / S7-2 테스트 공용 가짜·띄우기 도우미.
//
// 🔴 가짜는 받침대 extends — implements 금지.
// 🔴 받은 인자 전부 기록 · 호출마다 새 Future/Stream.
// R10c 가 이 파일에 더하기만 한다(기존 심볼 삭제·변경 금지).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/screens/explore/performance_explore_body.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';

// ── 가짜 PerformanceRepository ────────────────────────────────────────────

/// series() 의 기본 답 = performance24m 행 0.
/// 생성자 인자 [seriesResult] 로 답을 바꿀 수 있다(null = 기본).
class FakePerformanceRepository extends UnimplementedPerformanceRepository {
  FakePerformanceRepository({
    this._gateStream,
    this._seriesResult,
    this._gateStreamFactory,
  });

  final Stream<DisclosureGateVm> Function()? _gateStreamFactory;
  final Stream<DisclosureGateVm>? _gateStream;
  final PerformanceSeries? _seriesResult;

  // watchDisclosureGate 인자 기록
  int watchDisclosureGateCalls = 0;

  // series 인자 기록 — 호출마다 append
  final List<
    ({
      PerfMetric metric,
      PerfGranularity granularity,
      bool cumulative,
      DateRange? range,
    })
  >
  seriesCalls = [];

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() {
    watchDisclosureGateCalls++;
    if (_gateStreamFactory != null) return _gateStreamFactory();
    if (_gateStream != null) return _gateStream;
    throw StateError('gateStream not provided');
  }

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) {
    seriesCalls.add((
      metric: metric,
      granularity: granularity,
      cumulative: cumulative,
      range: range,
    ));
    final result = _seriesResult ?? _defaultSeries();
    return Future<PerformanceSeries>.value(result);
  }
}

PerformanceSeries _defaultSeries() {
  return listFixture(
    FixturePaths.performance24m,
    PerformanceSeries.fromJson,
  ).rows[0];
}

// ── 가짜 CommandApi ──────────────────────────────────────────────────────

/// recordDisclosureView 와 watchCommand 를 둘 다 override 한다.
/// watchCommand 의 기본 답 = recordDisclosureView 가 돌려준 바로 그 접수증 스트림.
class FakeCommandApi extends UnimplementedCommandApi {
  FakeCommandApi({this._recordFn, this._watchFn});

  final Future<CommandReceipt> Function(DisclosureViewEvent)? _recordFn;
  final Stream<CommandReceipt> Function(String commandId)? _watchFn;

  final List<DisclosureViewEvent> recordedEvents = [];
  final List<String> watchedIds = [];

  /// recordDisclosureView 가 돌려준 최근 접수증 (watchCommand 기본 답에 쓴다)
  CommandReceipt? _lastReceipt;

  @override
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event) {
    recordedEvents.add(event);
    if (_recordFn != null) {
      return _recordFn(event).then((CommandReceipt r) {
        _lastReceipt = r;
        return r;
      });
    }
    // 기본: receipts 픽스처 행 0 을 돌려준다
    final receipt = listFixture(
      FixturePaths.m7M7DisclosureViewReceipts4,
      CommandReceipt.fromJson,
    ).rows[0];
    _lastReceipt = receipt;
    return Future<CommandReceipt>.value(receipt);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    watchedIds.add(commandId);
    if (_watchFn != null) return _watchFn(commandId);
    // 기본: recordDisclosureView 가 돌려준 접수증 스트림
    final receipt =
        _lastReceipt ??
        listFixture(
          FixturePaths.m7M7DisclosureViewReceipts4,
          CommandReceipt.fromJson,
        ).rows[0];
    return Stream<CommandReceipt>.value(receipt);
  }
}

// ── 가짜 SafetyRepository ────────────────────────────────────────────────

class FakeSafetyRepository extends UnimplementedSafetyRepository {
  FakeSafetyRepository(this._state);
  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

// ── 띄우기 도우미 ─────────────────────────────────────────────────────────

/// S7-2G/S7-2 화면 프로바이더 오버라이드 5개 목록 생성 도우미.
List<Override> exploreOverrides({
  required FakePerformanceRepository repo,
  required FakeCommandApi commandApi,
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
    analyticsCommandApiProvider.overrideWithValue(commandApi),
  ];
}

/// S7-2G/S7-2 화면 공용 띄우기 도우미.
///
/// 기본값: 정상 안전 상태(safetyStates 행 0) · kGoldenNowUtc 시계 · RecordingLinkOpener.
Future<void> pumpExplore(
  WidgetTester tester, {
  required FakePerformanceRepository repo,
  required FakeCommandApi commandApi,
  SafetyState? safetyState,
  Clock? clock,
  RecordingLinkOpener? opener,
  CommandReceipt? bodyReceipt,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: exploreOverrides(
        repo: repo,
        commandApi: commandApi,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      ),
      child: MaterialApp(
        home: Scaffold(
          body: bodyReceipt == null
              ? const PerformanceExploreScreen()
              : PerformanceExploreBody(receipt: bodyReceipt),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// S7-2 게이트 통과 도우미: 「그래도 보기」 누른 뒤 두 번 pump 하여 본문으로 진입.
Future<void> passGate(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('s72g-continue')));
  await tester.pump();
  await tester.pump();
}

/// 인자에 따라 매핑된 픽스처 시리즈를 돌려주는 가짜 레포지토리.
class TableFakePerformanceRepository extends FakePerformanceRepository {
  TableFakePerformanceRepository({super.gateStreamFactory});

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) {
    unawaited(
      super.series(
        metric: metric,
        granularity: granularity,
        cumulative: cumulative,
        range: range,
      ),
    );

    if (metric == PerfMetric.twr &&
        granularity == PerfGranularity.monthly &&
        cumulative == true) {
      return Future<PerformanceSeries>.value(
        listFixture(
          FixturePaths.performance24m,
          PerformanceSeries.fromJson,
        ).rows[0],
      );
    }
    if (metric == PerfMetric.mwr &&
        granularity == PerfGranularity.monthly &&
        cumulative == true) {
      return Future<PerformanceSeries>.value(
        listFixture(
          FixturePaths.performance24m,
          PerformanceSeries.fromJson,
        ).rows[1],
      );
    }
    if (metric == PerfMetric.twr &&
        granularity == PerfGranularity.daily &&
        cumulative == true) {
      return Future<PerformanceSeries>.value(
        singleFixture(
          FixturePaths.m7M7PerfDailyGap,
          PerformanceSeries.fromJson,
        ),
      );
    }
    if (metric == PerfMetric.twr &&
        granularity == PerfGranularity.yearly &&
        cumulative == true) {
      return Future<PerformanceSeries>.value(
        singleFixture(
          FixturePaths.m7M7PerfYearly,
          PerformanceSeries.fromJson,
        ),
      );
    }
    if (metric == PerfMetric.twr &&
        granularity == PerfGranularity.monthly &&
        cumulative == false) {
      return Future<PerformanceSeries>.value(
        singleFixture(
          FixturePaths.m7M7PerfMonthlyPeriod,
          PerformanceSeries.fromJson,
        ),
      );
    }

    return Future<PerformanceSeries>.value(
      listFixture(
        FixturePaths.performance24m,
        PerformanceSeries.fromJson,
      ).rows[0],
    );
  }
}

/// series() 호출 시 예외를 던지는 가짜 레포지토리.
class ThrowingFakePerformanceRepository extends FakePerformanceRepository {
  ThrowingFakePerformanceRepository({super.gateStreamFactory});

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) {
    unawaited(
      super.series(
        metric: metric,
        granularity: granularity,
        cumulative: cumulative,
        range: range,
      ),
    );
    return Future<PerformanceSeries>.error(
      StateError('Simulated series error'),
    );
  }
}

/// 첫 요청은 정상 완료되고, 이후 재요청은 Completer 에 매달려 로딩 상태를 유지하는 가짜 레포지토리.
class CompleterFakePerformanceRepository extends FakePerformanceRepository {
  CompleterFakePerformanceRepository({
    super.gateStreamFactory,
    required this.completer,
  });

  final Completer<PerformanceSeries> completer;

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) {
    unawaited(
      super.series(
        metric: metric,
        granularity: granularity,
        cumulative: cumulative,
        range: range,
      ),
    );
    if (seriesCalls.length == 1) {
      return Future<PerformanceSeries>.value(
        listFixture(
          FixturePaths.performance24m,
          PerformanceSeries.fromJson,
        ).rows[0],
      );
    }
    return completer.future;
  }
}
