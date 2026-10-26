// test/golden/h02_golden_test.dart — H-02 운영 리듬 골든 (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/h02_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

class _Flow {
  const _Flow({
    required this.name,
    required this.fixture,
    required this.bottomKey,
    required this.steps,
  });

  final String name;
  final ListResult<OpsRhythmRow> fixture;
  final Key bottomKey;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final ListResult<OpsRhythmRow> rows = listFixture(
    FixturePaths.m8OpsRhythmRows,
    OpsRhythmRow.fromJson,
  );
  final ListResult<OpsRhythmRow> empty = listFixture(
    FixturePaths.m8OpsRhythmEmpty,
    OpsRhythmRow.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'h02_rows',
      fixture: rows,
      bottomKey: const ValueKey<String>('h02-row-4'),
      steps: (_) async {},
    ),
    _Flow(
      name: 'h02_not_loaded',
      fixture: empty,
      bottomKey: const Key('h02-empty'),
      steps: (_) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final RecordingLinkOpener opener = RecordingLinkOpener();
        await pumpForGolden(
          tester,
          const OpsRhythm(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: opsRhythmOverrides(
              ops: FakeShellOpsSummaryRepository(
                rhythm: (int call) =>
                    Stream<ListResult<OpsRhythmRow>>.value(flow.fixture),
              ),
              opener: opener,
              clock: FixedClock(kGoldenNowUtc),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        // 위치 전제 둘
        expect(
          tester.getBottomLeft(find.byKey(flow.bottomKey)).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('h02-asof'))).dy,
          0.0,
        );

        await expectGolden(flow.name, b);
      });
    }
  }
}
