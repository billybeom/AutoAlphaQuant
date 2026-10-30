// test/golden/n02_golden_test.dart -- N-02 alert detail golden (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/n02_golden_test.dart

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
  final AlertDetailVm vm;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final AlertDetailVm fullV = singleFixture(
    FixturePaths.m8AlertDetailFull,
    AlertDetailVm.fromJson,
  );
  final AlertDetailVm bareV = singleFixture(
    FixturePaths.m8AlertDetailNoLink,
    AlertDetailVm.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture(
    FixturePaths.m8AlertAckReceipts3,
    CommandReceipt.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'n02_detail',
      vm: fullV,
      bottom: const ValueKey<String>('n02-ack'),
      steps: (_) async {},
    ),
    _Flow(
      name: 'n02_no_link',
      vm: bareV,
      bottom: const Key('n02-action'),
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
              center: (int call) =>
                  Stream<AlertCenterVm>.error(StateError('unused')),
              detail: (int call) => one(flow.vm),
            );
        await pumpForGolden(
          tester,
          AlertDetail(alertId: flow.vm.item!.alertId),
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
        expect(tester.getTopLeft(find.byKey(const Key('n02-asof'))).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
