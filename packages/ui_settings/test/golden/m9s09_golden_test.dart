// test/golden/m9s09_golden_test.dart -- M9 S09 backup restore golden (4 names x light/dark = 8 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s09_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s09Tall = Size(390, 520);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final BackupVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final BackupVm normal = singleFixture(
    FixturePaths.m9Backup,
    BackupVm.fromJson,
  );
  final BackupVm ageWarn = singleFixture(
    FixturePaths.m9BackupAgeWarn,
    BackupVm.fromJson,
  );
  final BackupVm sim = singleFixture(
    FixturePaths.m9BackupSim,
    BackupVm.fromJson,
  );
  final BackupVm locked = singleFixture(
    FixturePaths.m9BackupLocked,
    BackupVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s09_default',
      vm: normal,
      bottom: const Key('m9s09-asof'),
      head: const Key('m9s09-last'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s09_age_warn',
      vm: ageWarn,
      bottom: const Key('m9s09-asof'),
      head: const Key('m9s09-last'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s09_sim',
      vm: sim,
      bottom: const Key('m9s09-asof'),
      head: const Key('m9s09-last'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s09_locked',
      vm: locked,
      bottom: const Key('m9s09-asof'),
      head: const Key('m9s09-locked'),
      steps: (WidgetTester tester) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const BackupRestore(),
          brightness: b,
          logicalSize: _kM9s09Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: backupOverrides(
              repo: FakeSettingsBackupRepository(
                backup: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
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
          lessThan(_kM9s09Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
