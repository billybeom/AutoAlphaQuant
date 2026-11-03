// test/onboarding_start_test.dart - O00-01 ~ O00-06 (O-00 first run branches).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

FakeShellOnboardingRepository _repoOf(
  Stream<OnboardingStartVm> Function(int call) start,
) => FakeShellOnboardingRepository(
  start: start,
  modeChoice: (int call) =>
      Stream<OnboardingModeChoiceVm>.error(StateError('unused')),
);

typedef _TapCase = ({
  String name,
  OnboardingStartVm v,
  Key key,
  List<String> want,
  bool tappable,
});

typedef _ViewerCase = ({String name, OnboardingStartVm v});

typedef _StateCase = ({
  String name,
  Stream<OnboardingStartVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

void main() {
  final OnboardingStartVm start = singleFixture(
    FixturePaths.m8OnboardingStart,
    OnboardingStartVm.fromJson,
  );
  final OnboardingStartVm noViewer = singleFixture(
    FixturePaths.m8OnboardingStartNoViewer,
    OnboardingStartVm.fromJson,
  );

  // O00-01 headline, two tracks, viewer track: text and received order.
  testWidgets('O00-01 headline tracks viewer text order', (
    WidgetTester tester,
  ) async {
    expect(start.viewerTrack, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeShellOnboardingRepository repo = _repoOf(
      (int call) => one(start),
    );
    await pumpOnboardingStart(
      tester,
      overrides: onboardingOverrides(repo: repo, actions: null, opener: opener),
    );
    expect(repo.startCalls, 1);

    final List<Finder> chain = <Finder>[
      find.byKey(const Key('o00-headline')),
      find.byKey(const ValueKey<String>('o00-track-0')),
      find.byKey(const ValueKey<String>('o00-track-1')),
      find.byKey(const Key('o00-viewer')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }

    expect(shownTexts(tester, find.byKey(const Key('o00-headline'))), <String>[
      start.headline,
    ]);
    expect(start.tracks, hasLength(2));
    for (final (int i, OnboardingTrackCard t) in start.tracks.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('o00-track-$i'))),
        trackCardTexts(t),
      );
    }
    expect(find.byKey(const ValueKey<String>('o00-track-2')), findsNothing);
    expect(
      shownTexts(tester, find.byKey(const Key('o00-viewer'))),
      trackCardTexts(start.viewerTrack!),
    );
    expect(find.byKey(const Key('o00b-next')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O00-02 track tap = link from data, no judgement.
  final List<_TapCase> tapCases = <_TapCase>[
    (
      name: 'fresh',
      v: start,
      key: const ValueKey<String>('o00-track-0'),
      want: <String>[start.tracks[0].deepLink!],
      tappable: true,
    ),
    (
      name: 'reconnect',
      v: start,
      key: const ValueKey<String>('o00-track-1'),
      want: <String>[start.tracks[1].deepLink!],
      tappable: true,
    ),
    (
      name: 'viewer',
      v: start,
      key: const Key('o00-viewer'),
      want: <String>[start.viewerTrack!.deepLink!],
      tappable: true,
    ),
    (
      name: 'unlinked',
      v: noViewer,
      key: const ValueKey<String>('o00-track-1'),
      want: <String>[],
      tappable: false,
    ),
  ];

  for (final _TapCase c in tapCases) {
    testWidgets('O00-02 tap link ${c.name}', (WidgetTester tester) async {
      expect(start.tracks[0].deepLink, isNotNull); // pre
      expect(start.tracks[1].deepLink, isNotNull); // pre
      expect(start.viewerTrack!.deepLink, isNotNull); // pre
      expect(noViewer.tracks[1].deepLink, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOnboardingStart(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(c.v)),
          actions: null,
          opener: opener,
        ),
      );
      expect(
        tester
            .widget<InkWell>(
              find.descendant(
                of: find.byKey(c.key),
                matching: find.byType(InkWell),
              ),
            )
            .onTap,
        c.tappable ? isNotNull : isNull,
      );
      await tester.tap(find.byKey(c.key));
      await tester.pump();
      expect(opener.opened, c.want);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O00-03 viewer track = data (own widget, null means absent).
  final List<_ViewerCase> viewerCases = <_ViewerCase>[
    (name: 'present', v: start),
    (name: 'absent', v: noViewer),
  ];

  for (final _ViewerCase c in viewerCases) {
    testWidgets('O00-03 viewer track data ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(start.viewerTrack, isNotNull); // pre
      expect(noViewer.viewerTrack, isNull); // pre
      await pumpOnboardingStart(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(c.v)),
          actions: null,
          opener: RecordingLinkOpener(),
        ),
      );
      final OnboardingTrackCard? viewer = c.v.viewerTrack;
      if (viewer != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('o00-viewer'))),
          trackCardTexts(viewer),
        );
      } else {
        expect(find.byKey(const Key('o00-viewer')), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('o00-track-1')),
          findsOneWidget,
        );
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O00-04 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<OnboardingStartVm>.multi(
        (MultiStreamController<OnboardingStartVm> c) {},
      ),
      present: <Key>[const Key('o00-loading')],
      absent: <Key>[const Key('o00-headline'), const Key('o00-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) => Stream<OnboardingStartVm>.error(StateError('fail')),
      present: <Key>[const Key('o00-fail')],
      absent: <Key>[const Key('o00-headline'), const Key('o00-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(start),
      present: <Key>[const Key('o00-fail')],
      absent: <Key>[const Key('o00-headline'), const Key('o00-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('O00-04 state branch ${c.name}', (WidgetTester tester) async {
      await pumpOnboardingStart(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf(c.stream),
          actions: null,
          opener: RecordingLinkOpener(),
        ),
      );
      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // O00-05 retry.
  testWidgets('O00-05 retry', (WidgetTester tester) async {
    final FakeShellOnboardingRepository repo = _repoOf(
      (int call) => call == 0
          ? Stream<OnboardingStartVm>.error(StateError('fail'))
          : one(start),
    );
    await pumpOnboardingStart(
      tester,
      overrides: onboardingOverrides(
        repo: repo,
        actions: null,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('o00-fail')), findsNothing);
    expect(find.byKey(const Key('o00-headline')), findsOneWidget);
    expect(repo.startCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O00-06 every shown Text is engine text; large font.
  final List<_ViewerCase> textCases = <_ViewerCase>[
    (name: 'start', v: start),
    (name: 'no_viewer', v: noViewer),
  ];

  for (final _ViewerCase c in textCases) {
    testWidgets('O00-06 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpOnboardingStart(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(c.v)),
          actions: null,
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = onboardingStartAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }
}
