// test/golden/s72g_golden_test.dart
// S7-2G 게이트 골든 — 8장 (s72g_first · s72g_frequent · s72g_closed · s72g_not_accepted
//                          × light/dark)
//
// 📐 크기: 390 × 844 (kGoldenPhoneSize)
// 🔴 찍기 전 위치 전제 — s72g-back 의 아래 끝 < 844.
// 🔴 s72g_not_accepted : 「그래도 보기」 1회 후 takeException(isNotNull) 먼저.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../explore_fakes.dart';
import 'golden_support.dart';

void main() {
  // Fixtures
  final DisclosureGateVm gateFirst = listFixture(
    FixturePaths.m7M7DisclosureGateFirst,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final DisclosureGateVm gateFrequent = listFixture(
    FixturePaths.m7M7DisclosureGateFrequent,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final DisclosureGateVm gateClosed = listFixture(
    FixturePaths.m7M7DisclosureGateClosed,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final DisclosureGateVm gateOpen = listFixture(
    FixturePaths.m7M7DisclosureGate,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final SafetyState safety = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[0],
  );

  // ── s72g_first ────────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72g_first ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStream: Stream<DisclosureGateVm>.value(gateFirst)
            .asBroadcastStream(),
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(
              RecordingLinkOpener(),
            ),
            performanceRepositoryProvider.overrideWithValue(repo),
            safetyRepositoryProvider.overrideWithValue(
              FakeSafetyRepository(safety),
            ),
            analyticsCommandApiProvider.overrideWithValue(api),
          ],
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
      );

      // Position precondition: back button bottom < height
      expect(
        tester.getBottomLeft(find.byKey(const Key('s72g-back'))).dy,
        lessThan(kGoldenPhoneSize.height),
      );

      await expectGolden('s72g_first', b);
    });
  }

  // ── s72g_frequent ─────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72g_frequent ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStream: Stream<DisclosureGateVm>.value(gateFrequent)
            .asBroadcastStream(),
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(
              RecordingLinkOpener(),
            ),
            performanceRepositoryProvider.overrideWithValue(repo),
            safetyRepositoryProvider.overrideWithValue(
              FakeSafetyRepository(safety),
            ),
            analyticsCommandApiProvider.overrideWithValue(api),
          ],
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
      );

      expect(
        tester.getBottomLeft(find.byKey(const Key('s72g-back'))).dy,
        lessThan(kGoldenPhoneSize.height),
      );

      await expectGolden('s72g_frequent', b);
    });
  }

  // ── s72g_closed ───────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72g_closed ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStream: Stream<DisclosureGateVm>.value(gateClosed)
            .asBroadcastStream(),
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(
              RecordingLinkOpener(),
            ),
            performanceRepositoryProvider.overrideWithValue(repo),
            safetyRepositoryProvider.overrideWithValue(
              FakeSafetyRepository(safety),
            ),
            analyticsCommandApiProvider.overrideWithValue(api),
          ],
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
      );

      expect(
        tester.getBottomLeft(find.byKey(const Key('s72g-back'))).dy,
        lessThan(kGoldenPhoneSize.height),
      );

      await expectGolden('s72g_closed', b);
    });
  }

  // ── s72g_not_accepted ─────────────────────────────────────────────────────
  // Open gate + throwing command fake, tap Continue, take exception, then snap.
  for (final Brightness b in Brightness.values) {
    testWidgets('s72g_not_accepted ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStream: Stream<DisclosureGateVm>.value(gateOpen)
            .asBroadcastStream(),
      );
      final api = FakeCommandApi(
        recordFn: (_) =>
            Future<CommandReceipt>.error(Exception('command-rejected')),
        watchFn: (_) => const Stream<CommandReceipt>.empty(),
      );

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(
              RecordingLinkOpener(),
            ),
            performanceRepositoryProvider.overrideWithValue(repo),
            safetyRepositoryProvider.overrideWithValue(
              FakeSafetyRepository(safety),
            ),
            analyticsCommandApiProvider.overrideWithValue(api),
          ],
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
      );

      // Tap continue, let it fail
      await tester.tap(find.byKey(const Key('s72g-continue')));
      await tester.pump();
      await tester.pump();

      // Consume reported error before snapping
      expect(tester.takeException(), isNotNull);

      // Position precondition
      expect(
        tester.getBottomLeft(find.byKey(const Key('s72g-back'))).dy,
        lessThan(kGoldenPhoneSize.height),
      );

      await expectGolden('s72g_not_accepted', b);
    });
  }
}
