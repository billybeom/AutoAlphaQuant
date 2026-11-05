// test/incident_banner_test.dart - D01-01 ~ D01-11 (D-01 incident banner).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

IconData wantKind(IncidentKind k) => switch (k) {
  IncidentKind.phoneDown => Icons.phonelink_erase,
  IncidentKind.networkDown => Icons.wifi_off,
  IncidentKind.tokenExpired => Icons.vpn_key_off,
  IncidentKind.orderRejected => Icons.assignment_late_outlined,
  IncidentKind.other => Icons.info_outline,
};

Color wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => cs.primary,
  UiLevel.info => cs.onSurfaceVariant,
  UiLevel.watch => cs.tertiary,
  UiLevel.act => cs.secondary,
  UiLevel.blocked => cs.error,
};

typedef _KindCase = ({String name, IncidentBannerVm v, void Function() pre});

typedef _LinkCase = ({String name, IncidentBannerVm v});

typedef _ShellCase = ({String name, ShellPlatform platform, Size size});

typedef _StateCase = ({
  String name,
  Stream<IncidentBannerVm> Function(int call) stream,
  Matcher failWant,
});

void main() {
  final IncidentBannerVm tokenExpired = singleFixture(
    FixturePaths.m8IncidentBannerTokenExpired,
    IncidentBannerVm.fromJson,
  );
  final IncidentBannerVm orderRejected = singleFixture(
    FixturePaths.m8IncidentBannerOrderRejected,
    IncidentBannerVm.fromJson,
  );
  final IncidentBannerVm networkDown = singleFixture(
    FixturePaths.m8IncidentBannerNetworkDown,
    IncidentBannerVm.fromJson,
  );
  final IncidentBannerVm phoneDown = singleFixture(
    FixturePaths.m8IncidentBannerPhoneDown,
    IncidentBannerVm.fromJson,
  );
  final IncidentBannerVm other = singleFixture(
    FixturePaths.m8IncidentBannerOther,
    IncidentBannerVm.fromJson,
  );
  final IncidentBannerVm none = singleFixture(
    FixturePaths.m8IncidentBannerNone,
    IncidentBannerVm.fromJson,
  );

  FakeShellIncidentRepository repoOf(IncidentBannerVm v) =>
      FakeShellIncidentRepository(incident: (int call) => one(v));

  ColorScheme csOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme;

  List<Override> shellWith(
    IncidentBannerVm v,
    FeatureFlags flags,
    ShellPlatform platform,
  ) => <Override>[
    ...shellOverrides(
      platform: platform,
      config: flagsOf(flags),
      alerts: alertsOf(const <AlertItem>[]),
      bodies: dummyBodies(AppRoutes.all, <String>[]),
    ),
    ...incidentOverrides(repo: repoOf(v), opener: RecordingLinkOpener()),
  ];

  // D01-01 block order and words.
  testWidgets('D01-01 banner block order and words', (
    WidgetTester tester,
  ) async {
    expect(tokenExpired.banner?.actionLink, isNotNull); // pre
    await pumpIncidentBanner(
      tester,
      overrides: incidentOverrides(
        repo: repoOf(tokenExpired),
        opener: RecordingLinkOpener(),
      ),
    );
    final IncidentBanner b = tokenExpired.banner!;
    expect(shownTexts(tester, find.byKey(const Key('d01-banner'))), <String?>[
      b.title,
      b.bodyText,
      b.actionLink?.label,
    ]);
    expect(
      tester.getTopLeft(find.byKey(const Key('d01-icon'))).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.text(b.title)).dy),
    );
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(1),
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D01-02 kind drives the icon, level drives the color.
  final List<_KindCase> kindCases = <_KindCase>[
    (
      name: 'token_expired',
      v: tokenExpired,
      pre: () {
        expect(tokenExpired.banner?.kind, IncidentKind.tokenExpired); // pre
      },
    ),
    (
      name: 'order_rejected',
      v: orderRejected,
      pre: () {
        expect(orderRejected.banner?.kind, IncidentKind.orderRejected); // pre
      },
    ),
    (
      name: 'network_down',
      v: networkDown,
      pre: () {
        expect(networkDown.banner?.kind, IncidentKind.networkDown); // pre
      },
    ),
    (
      name: 'phone_down',
      v: phoneDown,
      pre: () {
        expect(phoneDown.banner?.kind, IncidentKind.phoneDown); // pre
      },
    ),
    (
      name: 'other',
      v: other,
      pre: () {
        expect(other.banner?.kind, IncidentKind.other); // pre
      },
    ),
  ];

  for (final _KindCase c in kindCases) {
    testWidgets('D01-02 kind icon level color ${c.name}', (
      WidgetTester tester,
    ) async {
      c.pre();
      await pumpIncidentBanner(
        tester,
        overrides: incidentOverrides(
          repo: repoOf(c.v),
          opener: RecordingLinkOpener(),
        ),
      );
      final ColorScheme cs = csOf(tester);
      final Icon icon = tester.widget<Icon>(find.byKey(const Key('d01-icon')));
      expect(icon.icon, wantKind(c.v.banner!.kind));
      expect(icon.color, wantLevel(cs, c.v.banner!.level));
      expect(shownTexts(tester, find.byKey(const Key('d01-banner'))), <String?>[
        c.v.banner!.title,
        c.v.banner!.bodyText,
        ?c.v.banner!.actionLink?.label,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // D01-03 action tap opens the received link.
  final List<_LinkCase> linkCases = <_LinkCase>[
    (name: 'token_expired', v: tokenExpired),
    (name: 'order_rejected', v: orderRejected),
  ];

  for (final _LinkCase c in linkCases) {
    testWidgets('D01-03 action tap link ${c.name}', (
      WidgetTester tester,
    ) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeShellIncidentRepository repo = repoOf(c.v);
      await pumpIncidentBanner(
        tester,
        overrides: incidentOverrides(repo: repo, opener: opener),
      );
      await tester.tap(find.byKey(const Key('d01-action')));
      await tester.pump();
      expect(opener.opened, <String>[c.v.banner!.actionLink!.deepLink]);
      expect(repo.incidentCalls, 1);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // D01-04 no action means no button; dragging does not dismiss.
  testWidgets('D01-04 no action no button no dismiss', (
    WidgetTester tester,
  ) async {
    expect(networkDown.banner?.actionLink, isNull); // pre
    await pumpIncidentBanner(
      tester,
      overrides: incidentOverrides(
        repo: repoOf(networkDown),
        opener: RecordingLinkOpener(),
      ),
    );
    expect(find.byKey(const Key('d01-action')), findsNothing);
    expect(find.text(tokenExpired.banner!.actionLink!.label), findsNothing);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    expect(find.byKey(const Key('d01-banner')), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('d01-banner')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('d01-banner')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D01-05 no banner in the data draws nothing inside the shell.
  testWidgets('D01-05 no banner draws nothing in shell', (
    WidgetTester tester,
  ) async {
    expect(none.banner, isNull); // pre
    final FakeShellIncidentRepository repo = repoOf(none);
    await pumpShell(
      tester,
      overrides: <Override>[
        ...shellOverrides(
          platform: ShellPlatform.androidOperator,
          config: flagsOf(kFlagsLiveAuto),
          alerts: alertsOf(const <AlertItem>[]),
          bodies: dummyBodies(AppRoutes.all, <String>[]),
        ),
        ...incidentOverrides(repo: repo, opener: RecordingLinkOpener()),
      ],
    );
    expect(repo.incidentCalls, 1);
    expect(find.byKey(const Key('d01-banner')), findsNothing);
    expect(find.byKey(const Key('d01-fail')), findsNothing);
    expect(tester.getSize(find.byType(IncidentBannerSlot)).height, 0.0);
    expect(find.byKey(const Key('s01-tabs')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D01-06 the banner sits above the tab body in both shell frames.
  final List<_ShellCase> shellCases = <_ShellCase>[
    (
      name: 'android',
      platform: ShellPlatform.androidOperator,
      size: const Size(390, 844),
    ),
    (name: 'web', platform: ShellPlatform.web, size: const Size(1280, 800)),
  ];

  for (final _ShellCase c in shellCases) {
    testWidgets('D01-06 shell frame wiring ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(tokenExpired.banner, isNotNull); // pre
      await pumpShell(
        tester,
        overrides: shellWith(tokenExpired, kFlagsLiveAuto, c.platform),
        size: c.size,
      );
      expect(find.byKey(const Key('d01-banner')), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('d01-banner'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('s01-home-slot'))).dy),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // D01-07 no injection means no banner and an untouched shell.
  testWidgets('D01-07 no injection no banner', (WidgetTester tester) async {
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.androidOperator,
        config: flagsOf(kFlagsLiveAuto),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, <String>[]),
      ),
    );
    expect(find.byKey(const Key('d01-banner')), findsNothing);
    expect(find.byKey(const Key('d01-fail')), findsNothing);
    expect(tester.getSize(find.byType(IncidentBannerSlot)).height, 0.0);
    expect(find.byKey(const Key('s01-tabs')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D01-08 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<IncidentBannerVm>.multi(
        (MultiStreamController<IncidentBannerVm> c) {},
      ),
      failWant: findsNothing,
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(tokenExpired),
      failWant: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('D01-08 state branch ${c.name}', (WidgetTester tester) async {
      await pumpIncidentBanner(
        tester,
        overrides: incidentOverrides(
          repo: FakeShellIncidentRepository(incident: c.stream),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('d01-fail')), c.failWant);
      expect(find.byKey(const Key('d01-banner')), findsNothing);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // D01-09 retry subscribes once more.
  testWidgets('D01-09 retry', (WidgetTester tester) async {
    final FakeShellIncidentRepository repo = FakeShellIncidentRepository(
      incident: (int call) => call == 0
          ? Stream<IncidentBannerVm>.error(StateError('fail'))
          : one(tokenExpired),
    );
    await pumpIncidentBanner(
      tester,
      overrides: incidentOverrides(repo: repo, opener: RecordingLinkOpener()),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('d01-fail')), findsNothing);
    expect(find.byKey(const Key('d01-banner')), findsOneWidget);
    expect(repo.incidentCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D01-10 every shown Text is engine text; button count; large font.
  final List<_LinkCase> textCases = <_LinkCase>[
    (name: 'token_expired', v: tokenExpired),
    (name: 'order_rejected', v: orderRejected),
    (name: 'network_down', v: networkDown),
  ];

  for (final _LinkCase c in textCases) {
    testWidgets('D01-10 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpIncidentBanner(
        tester,
        overrides: incidentOverrides(
          repo: repoOf(c.v),
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = incidentAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNWidgets(c.v.banner?.actionLink == null ? 0 : 1),
      );
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // D01-11 shell overlap: band with two chips + banner + 200 percent font.
  testWidgets('D01-11 shell overlap band banner large font', (
    WidgetTester tester,
  ) async {
    expect(tokenExpired.banner?.actionLink, isNotNull); // pre
    await pumpShell(
      tester,
      overrides: shellWith(
        tokenExpired,
        kFlagsSimAdvisory,
        ShellPlatform.androidOperator,
      ),
    );
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(
      () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey<String>('s01-band-chip-1')),
      findsOneWidget,
    );
    expect(
      tester.getBottomLeft(find.byKey(const Key('s01-band'))).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const Key('d01-banner'))).dy,
      ),
    );
    expect(
      tester.getBottomLeft(find.byKey(const Key('d01-banner'))).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const Key('s01-home-slot'))).dy,
      ),
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
