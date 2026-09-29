// packages/ui_analytics/test/golden/s73_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden_support.dart';

class _FakePerformanceRepository extends UnimplementedPerformanceRepository {
  _FakePerformanceRepository({this.drawdownVm, this.contributionVm});

  final DrawdownContextVm? drawdownVm;
  final ContributionVm? contributionVm;

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) async {
    final vm = drawdownVm;
    if (vm != null) {
      return vm;
    }
    throw UnimplementedError();
  }

  @override
  Future<ContributionVm> contribution({required DateRange range}) async {
    final vm = contributionVm;
    if (vm != null) {
      return vm;
    }
    throw UnimplementedError();
  }
}

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository(this._state);

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
  final contrib = singleFixture(
    FixturePaths.m7M7Contrib3sleeve,
    ContributionVm.fromJson,
  );
  final contribPartial = singleFixture(
    FixturePaths.m7M7ContribPartial,
    ContributionVm.fromJson,
  );
  final safetyState = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[0],
  );
  const testRange = DateRange(
    from: TradeDate('2026-08-01'),
    to: TradeDate('2026-08-31'),
    presetCode: 'FIXTURE',
  );

  for (final b in Brightness.values) {
    testWidgets('s73_normal ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(drawdownVm: normal),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyState),
            ),
          ],
          child: const DrawdownContextScreen(),
        ),
        brightness: b,
      );
      await expectGolden('s73_normal', b);
    });

    testWidgets('s73_deep_dd ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(drawdownVm: deep),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyState),
            ),
          ],
          child: const DrawdownContextScreen(),
        ),
        brightness: b,
      );
      await expectGolden('s73_deep_dd', b);
    });

    testWidgets('s73b_three_sleeves ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(contributionVm: contrib),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyState),
            ),
          ],
          child: const ContributionScreen(range: testRange),
        ),
        brightness: b,
      );
      await expectGolden('s73b_three_sleeves', b);
    });

    // S7-3b Partial (결측 슬리브)
    testWidgets('s73b_partial ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(contributionVm: contribPartial),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyState),
            ),
          ],
          child: const ContributionScreen(range: testRange),
        ),
        brightness: b,
      );
      await expectGolden('s73b_partial', b);
    });
  }
}
