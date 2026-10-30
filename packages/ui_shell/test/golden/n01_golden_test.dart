// test/golden/n01_golden_test.dart -- N-01 alert center golden (3 names x light/dark = 6 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/n01_golden_test.dart

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
    required this.vm,
    required this.bottom,
    required this.steps,
  });

  final String name;
  final AlertCenterVm vm;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final AlertCenterVm p0ack = singleFixture(
    FixturePaths.m8AlertCenterP0Ack,
    AlertCenterVm.fromJson,
  );
  final AlertCenterVm digest = singleFixture(
    FixturePaths.m8AlertCenterDigest,
    AlertCenterVm.fromJson,
  );
  final AlertCenterVm empty = singleFixture(
    FixturePaths.m8AlertCenterEmpty,
    AlertCenterVm.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture(
    FixturePaths.m8AlertAckReceipts3,
    CommandReceipt.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'n01_p0_ack',
      vm: p0ack,
      bottom: const ValueKey<String>('n01-row-0-1'),
      steps: (_) async {},
    ),
    _Flow(
      name: 'n01_digest',
      vm: digest,
      bottom: const ValueKey<String>('n01-digest-1'),
      steps: (_) async {},
    ),
    _Flow(
      name: 'n01_empty',
      vm: empty,
      bottom: const Key('n01-empty'),
      steps: (_) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final FakeShellAlertCommandApi api = FakeShellAlertCommandApi(
          receipt: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
        );
        final FakeShellAlertCenterRepository alerts =
            FakeShellAlertCenterRepository(
              center: (int call) => one(flow.vm),
              detail: (int call) =>
                  Stream<AlertDetailVm>.error(StateError('unused')),
            );
        await pumpForGolden(
          tester,
          const AlertCenter(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: alertOverrides(
              alerts: alerts,
              api: api,
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
          lessThan(kGoldenPhoneSize.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('n01-asof'))).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
