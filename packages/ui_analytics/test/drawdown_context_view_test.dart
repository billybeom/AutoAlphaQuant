// packages/ui_analytics/test/drawdown_context_view_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';

class FakePerformanceRepository extends UnimplementedPerformanceRepository {
  FakePerformanceRepository({this.drawdownVm});

  final DrawdownContextVm? drawdownVm;

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) async {
    final vm = drawdownVm;
    if (vm != null) {
      return vm;
    }
    throw UnimplementedError();
  }
}

class FakeSafetyRepository implements SafetyRepository {
  FakeSafetyRepository(this._state);

  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  final normal = singleFixture(
    FixturePaths.m7M7DdContextNormal,
    DrawdownContextVm.fromJson,
  );
  final deep = singleFixture(
    FixturePaths.m7M7DdContextDeep,
    DrawdownContextVm.fromJson,
  );
  final safetyEnvelope = fixtureEnvelope(FixturePaths.safetyStates);
  final safetyRow0 = SafetyState.fromJson(safetyEnvelope.rows[0]);
  final safetyRow1 = SafetyState.fromJson(safetyEnvelope.rows[1]);
  final safetyRow3 = SafetyState.fromJson(safetyEnvelope.rows[3]);

  testWidgets('S7-3 정상 픽스처 렌더 검증: 지표·게이지 표시 및 단서 미표시', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(drawdownVm: normal),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DrawdownContextScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(normal.periodLabel), findsOneWidget);
    expect(find.text(normal.currentDdText), findsOneWidget);
    expect(find.text(normal.maxDdText), findsOneWidget);
    expect(find.text(normal.tuwText), findsOneWidget);
    if (normal.referenceBandText != null) {
      expect(find.text(normal.referenceBandText!), findsOneWidget);
    }
    expect(find.text(deep.referenceBandCaveatText!), findsNothing);
  });

  testWidgets('S7-3 심화 픽스처 렌더 검증: 단서 전문 표시', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(drawdownVm: deep),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DrawdownContextScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(deep.referenceBandCaveatText!), findsOneWidget);
  });

  testWidgets('S7-3 신선도 검사: staleAfter 초과 시 오래된 데이터 배너 제목 노출', (
    WidgetTester tester,
  ) async {
    final expiredClock = FixedClock(kGoldenNowUtc.add(const Duration(days: 3)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(expiredClock),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(drawdownVm: normal),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DrawdownContextScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
  });

  testWidgets('S7-3 차단 배너 및 표식 칩 표시 검증', (WidgetTester tester) async {
    final blockingFlag = safetyRow3.activeFlags.firstWhere(
      (f) => !FlagIds.markerOnly.contains(f.flagId),
    );
    final markerFlag = safetyRow1.activeFlags.firstWhere(
      (f) => FlagIds.markerOnly.contains(f.flagId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(drawdownVm: normal),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow3),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DrawdownContextScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(blockingFlag.label), findsOneWidget);
    expect(find.text(blockingFlag.clearInstruction), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(drawdownVm: normal),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow1),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DrawdownContextScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(markerFlag.label), findsOneWidget);
  });

  testWidgets('S7-3 세 값 Text 조상에 FittedBox 부재 검증', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(drawdownVm: deep),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DrawdownContextScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.ancestor(
        of: find.text(deep.currentDdText),
        matching: find.byType(FittedBox),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.text(deep.maxDdText),
        matching: find.byType(FittedBox),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.text(deep.tuwText),
        matching: find.byType(FittedBox),
      ),
      findsNothing,
    );
  });
}
