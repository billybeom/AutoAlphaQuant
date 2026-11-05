// test/golden/d01_golden_test.dart - D-01 incident banner golden (2 names x light/dark = 4 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/d01_golden_test.dart

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
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final IncidentBannerVm fixture;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final IncidentBannerVm tokenExpired = singleFixture(
    FixturePaths.m8IncidentBannerTokenExpired,
    IncidentBannerVm.fromJson,
  );
  final IncidentBannerVm networkDown = singleFixture(
    FixturePaths.m8IncidentBannerNetworkDown,
    IncidentBannerVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'd01_token_expired',
      fixture: tokenExpired,
      bottom: const Key('d01-action'),
      head: const Key('d01-banner'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'd01_network_down',
      fixture: networkDown,
      bottom: const Key('d01-banner'),
      head: const Key('d01-banner'),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[IncidentBannerSlot()],
          ),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: incidentOverrides(
              repo: FakeShellIncidentRepository(
                incident: (int call) => one(flow.fixture),
              ),
              opener: RecordingLinkOpener(),
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
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
