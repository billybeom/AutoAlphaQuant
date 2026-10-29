// test/golden/a4_golden_test.dart — A-4 AdviceSkipForm golden (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/a4_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/journal_draft.dart';

import '../advice_skip_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1000);

class _Flow {
  const _Flow({
    required this.name,
    required this.bottom,
    required this.opened,
    required this.steps,
  });

  final String name;
  final Key bottom;
  final List<String> opened;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final AdviceItem ad0001 = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  ).rows[3];
  final ManualFillFormSpec spec = singleFixture<ManualFillFormSpec>(
    FixturePaths.m6FillFormSpec,
    ManualFillFormSpec.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'a4_reasons',
      bottom: const ValueKey<String>('a4-reason-5'),
      opened: <String>[],
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'a4_budget_push',
      bottom: const ValueKey<String>('a4-reason-5'),
      opened: <String>[spec.skipReasons[0].deepLink!],
      steps: (WidgetTester t) async {
        final Finder first = find.byKey(const ValueKey<String>('a4-reason-0'));
        await t.ensureVisible(first);
        await t.tap(first);
        await t.pump();
      },
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final RecordingLinkOpener opener = RecordingLinkOpener();
        final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
          item: (int call) => Future<AdviceItem?>.value(ad0001),
          spec: (int call) => Stream<ManualFillFormSpec>.value(spec),
        );
        await pumpForGolden(
          tester,
          AdviceSkipForm(adviceId: ad0001.adviceId),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: adviceSkipOverrides(
              repo: repo,
              cmd: UnimplementedCommandApi(),
              store: RecordingDraftStore(),
              opener: opener,
            ),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pump();

        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(opener.opened, flow.opened);
        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('a4-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
