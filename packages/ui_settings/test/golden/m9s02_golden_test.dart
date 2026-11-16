// test/golden/m9s02_golden_test.dart -- M9 S02 credentials golden (4 names x light/dark = 8 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s02_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s02Tall = Size(390, 960);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final CredentialListVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final CredentialListVm live = singleFixture(
    FixturePaths.m9Credentials,
    CredentialListVm.fromJson,
  );
  final CredentialListVm simSealed = singleFixture(
    FixturePaths.m9CredentialsSimSealed,
    CredentialListVm.fromJson,
  );
  final CredentialListVm advisory = singleFixture(
    FixturePaths.m9CredentialsAdvisory,
    CredentialListVm.fromJson,
  );
  final CredentialListVm locked = singleFixture(
    FixturePaths.m9CredentialsLocked,
    CredentialListVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s02_live',
      vm: live,
      bottom: const Key('m9s02-asof'),
      head: const ValueKey<String>('m9s02-card-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s02_sim_sealed',
      vm: simSealed,
      bottom: const Key('m9s02-asof'),
      head: const Key('m9s02-notice'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s02_advisory',
      vm: advisory,
      bottom: const Key('m9s02-asof'),
      head: const ValueKey<String>('m9s02-card-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s02_locked',
      vm: locked,
      bottom: const Key('m9s02-asof'),
      head: const Key('m9s02-locked'),
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
          const Credentials(),
          brightness: b,
          logicalSize: _kM9s02Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: credentialsOverrides(
              repo: FakeSettingsCredentialsRepository(
                credentials: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
              slots: FakeSettingsSlotRecorder().build,
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
          lessThan(_kM9s02Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
