// test/golden/m9s01_golden_test.dart — M9 S01 settings home golden (3 names x light/dark = 6 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s01_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s01Tall = Size(390, 1120);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.size,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final SettingsHomeVm vm;
  final Size size;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final SettingsHomeVm homeVm = singleFixture(
    FixturePaths.m9SettingsHome,
    SettingsHomeVm.fromJson,
  );
  final SettingsHomeVm noReviewVm = singleFixture(
    FixturePaths.m9SettingsHomeNoReview,
    SettingsHomeVm.fromJson,
  );
  final SettingsHomeVm viewerVm = singleFixture(
    FixturePaths.m9SettingsHomeViewer,
    SettingsHomeVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s01_home',
      vm: homeVm,
      size: _kM9s01Tall,
      bottom: const Key('m9s01-asof'),
      head: const Key('m9s01-chip'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s01_no_review',
      vm: noReviewVm,
      size: _kM9s01Tall,
      bottom: const Key('m9s01-asof'),
      head: const Key('m9s01-chip'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s01_viewer',
      vm: viewerVm,
      size: kGoldenPhoneSize,
      bottom: const Key('m9s01-asof'),
      head: const Key('m9s01-chip'),
      steps: (WidgetTester t) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const SettingsHome(),
          brightness: b,
          logicalSize: flow.size,
          wrapApp: (Widget app) => ProviderScope(
            overrides: settingsHomeOverrides(
              repo: FakeSettingsRepository(home: (int call) => one(flow.vm)),
              opener: RecordingLinkOpener(),
              clock: FixedClock(kGoldenNowUtc),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(flow.size.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
