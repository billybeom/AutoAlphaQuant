// test/handbook_page_view_test.dart - B02-01 ~ B02-10 (B-02 handbook page).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/src/common/shell_common.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

(IconData, Color) wantLive(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.pending_actions_outlined, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

typedef _LiveCase = ({String name, int block});

typedef _LinkCase = ({String name, int block, List<String> want});

typedef _NoticeCase = ({String name, HandbookPage v, int linkBlock});

typedef _ShellCase = ({
  String name,
  ShellPlatform platform,
  Size size,
  FakeShellHandbookRepository? repo,
  Future<void> Function(WidgetTester t, FakeShellHandbookRepository? repo) flow,
});

typedef _StateCase = ({
  String name,
  Stream<HandbookPage> Function(int call) stream,
  Matcher loadingWant,
  Matcher failWant,
});

typedef _TextCase = ({String name, HandbookPage v});

typedef _AsOfCase = ({
  String name,
  DateTime now,
  Future<void> Function(WidgetTester t) flow,
});

void main() {
  final HandbookPage sleeveB = singleFixture(
    FixturePaths.m8HandbookPageSleeveB,
    HandbookPage.fromJson,
  );
  final HandbookPage outdated = singleFixture(
    FixturePaths.m8HandbookPageOutdated,
    HandbookPage.fromJson,
  );
  final HandbookPage missing = singleFixture(
    FixturePaths.m8HandbookPageMissing,
    HandbookPage.fromJson,
  );
  final HandbookPage archived = singleFixture(
    FixturePaths.m8HandbookPageArchived,
    HandbookPage.fromJson,
  );
  final HandbookIndex index = singleFixture(
    FixturePaths.m8HandbookIndex,
    HandbookIndex.fromJson,
  );

  FakeShellHandbookRepository repoOf(HandbookPage v) =>
      FakeShellHandbookRepository(
        index: (int call) => const Stream<HandbookIndex>.empty(),
        page: (int call) => one(v),
      );

  List<Override> overridesOf(
    FakeShellHandbookRepository? repo,
    RecordingLinkOpener opener, {
    DateTime? now,
  }) => handbookOverrides(
    repo: repo,
    opener: opener,
    clock: FixedClock(now ?? kGoldenNowUtc),
  );

  List<String?> blockTexts(HandbookBlock b) => <String?>[
    ?b.live?.label,
    b.text,
  ];

  // B02-01 block order, words, one text look.
  testWidgets('B02-01 block order and words', (WidgetTester tester) async {
    expect(sleeveB.blocks[3].kind, 'CAUTION'); // pre
    expect(sleeveB.blocks[3].live, isNull); // pre
    final FakeShellHandbookRepository repo = repoOf(sleeveB);
    await pumpHandbookPage(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
      anchor: sleeveB.anchor,
    );
    expect(sleeveB.blocks, hasLength(5));
    final List<Key> chain = <Key>[
      const Key('b02-asof'),
      const Key('b02-title'),
      for (int i = 0; i < 5; i++) ValueKey<String>('b02-block-$i'),
    ];
    final List<double> tops = chain
        .map((Key k) => tester.getTopLeft(find.byKey(k)).dy)
        .toList();
    for (int i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]));
    }
    expect(shownTexts(tester, find.byKey(const Key('b02-title'))), <String?>[
      sleeveB.title,
    ]);
    final TextStyle? firstStyle = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const ValueKey<String>('b02-block-0')),
            matching: find.text(sleeveB.blocks[0].text),
          ),
        )
        .style;
    for (final (int i, HandbookBlock blk) in sleeveB.blocks.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('b02-block-$i'))),
        blockTexts(blk),
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(ValueKey<String>('b02-block-$i')),
                matching: find.text(blk.text),
              ),
            )
            .style,
        firstStyle,
      );
      // C4r16b-3(C4O-7 · P11): 블록 안 Icon = live 행 것만.
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('b02-block-$i')),
          matching: find.byType(Icon),
        ),
        findsNWidgets(blk.live == null ? 0 : 1),
      );
    }
    expect(find.byKey(const ValueKey<String>('b02-block-5')), findsNothing);
    expect(repo.pageAnchors, <String>[sleeveB.anchor]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B02-02 live value -> icon and color; blocks without one draw nothing.
  final List<_LiveCase> liveCases = <_LiveCase>[
    (name: 'live', block: 1),
    (name: 'no_live', block: 0),
  ];

  for (final _LiveCase c in liveCases) {
    testWidgets('B02-02 live value ${c.name}', (WidgetTester tester) async {
      expect(sleeveB.blocks[1].live, isNotNull); // pre
      final HandbookLiveValue? live = sleeveB.blocks[c.block].live;
      await pumpHandbookPage(
        tester,
        overrides: overridesOf(repoOf(sleeveB), RecordingLinkOpener()),
        anchor: sleeveB.anchor,
      );
      final Finder row = find.byKey(ValueKey<String>('b02-live-${c.block}'));
      expect(
        find.byKey(ValueKey<String>('b02-block-${c.block}')),
        findsOneWidget,
      );
      if (live != null) {
        final ColorScheme cs = Theme.of(tester.element(row)).colorScheme;
        final Icon icon = tester.widget<Icon>(
          find.descendant(of: row, matching: find.byType(Icon)),
        );
        expect(icon.icon, wantLive(cs, live.level).$1);
        expect(icon.color, wantLive(cs, live.level).$2);
        expect(shownTexts(tester, row), <String?>[live.label]);
      } else {
        expect(row, findsNothing);
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // B02-03 block tap opens the received link.
  final List<_LinkCase> linkCases = <_LinkCase>[
    (name: 'link', block: 3, want: <String>[sleeveB.blocks[3].deepLink!]),
    (name: 'no_link', block: 0, want: <String>[]),
  ];

  for (final _LinkCase c in linkCases) {
    testWidgets('B02-03 block tap ${c.name}', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpHandbookPage(
        tester,
        overrides: overridesOf(repoOf(sleeveB), opener),
        anchor: sleeveB.anchor,
      );
      expect(
        find.byKey(ValueKey<String>('b02-block-${c.block}')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(ValueKey<String>('b02-block-${c.block}')));
      await tester.pump();
      expect(opener.opened, c.want);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // B02-04 outdated notice x block links.
  final List<_NoticeCase> noticeCases = <_NoticeCase>[
    (name: 'outdated', v: outdated, linkBlock: 1),
    (name: 'no_notice', v: sleeveB, linkBlock: 3),
  ];

  for (final _NoticeCase c in noticeCases) {
    testWidgets('B02-04 outdated notice and links ${c.name}', (
      WidgetTester tester,
    ) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpHandbookPage(
        tester,
        overrides: overridesOf(repoOf(c.v), opener),
        anchor: c.v.anchor,
      );
      final String? notice = c.v.outdatedNotice;
      if (notice != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('b02-outdated'))),
          <String?>[notice],
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('b02-outdated'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const Key('b02-title'))).dy),
        );
        expect(
          find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
          findsNothing,
        );
        expect(find.byType(IconButton), findsNothing);
        // C4r16b-3(C4O-7 · P09d): 고지 자리 안 탭 위젯 0.
        // 양성 기준점 = 고지 안 경고 Icon 1 · 링크 블록 안 GestureDetector 1.
        expect(
          find.descendant(
            of: find.byKey(const Key('b02-outdated')),
            matching: find.byType(Icon),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('b02-outdated')),
            matching: find.byType(InkWell),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('b02-outdated')),
            matching: find.byType(GestureDetector),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('b02-block-${c.linkBlock}')),
            matching: find.byType(GestureDetector),
          ),
          findsOneWidget,
        );
      } else {
        expect(find.byKey(const Key('b02-outdated')), findsNothing);
        expect(find.text(outdated.outdatedNotice!), findsNothing);
        expect(find.byKey(const Key('b02-title')), findsOneWidget);
      }
      await tester.tap(
        find.byKey(ValueKey<String>('b02-block-${c.linkBlock}')),
      );
      await tester.pump();
      expect(opener.opened, <String>[c.v.blocks[c.linkBlock].deepLink!]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // B02-05 unknown anchor -> received sentence.
  testWidgets('B02-05 unknown anchor sentence', (WidgetTester tester) async {
    expect(missing.blocks, isEmpty); // pre
    expect(missing.missingLabel, isNotNull); // pre
    await pumpHandbookPage(
      tester,
      overrides: overridesOf(repoOf(missing), RecordingLinkOpener()),
      anchor: missing.anchor,
    );
    expect(shownTexts(tester, find.byKey(const Key('b02-missing'))), <String?>[
      missing.missingLabel,
    ]);
    // C4r16b-3(C4O-7 · X12): 없는 장이어도 제목 = 받은 글자.
    expect(shownTexts(tester, find.byKey(const Key('b02-title'))), <String?>[
      missing.title,
    ]);
    expect(find.byKey(const ValueKey<String>('b02-block-0')), findsNothing);
    expect(find.byKey(const Key('b02-missing')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B02-06 archived page shows the received paragraph as is.
  testWidgets('B02-06 archived page paragraph', (WidgetTester tester) async {
    await pumpHandbookPage(
      tester,
      overrides: overridesOf(repoOf(archived), RecordingLinkOpener()),
      anchor: archived.anchor,
    );
    for (final (int i, HandbookBlock blk) in archived.blocks.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('b02-block-$i'))),
        blockTexts(blk),
      );
    }
    expect(find.byKey(const Key('b02-title')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B02-07 shell wiring.
  final List<_ShellCase> shellCases = <_ShellCase>[
    (
      name: 'phone_injected',
      platform: ShellPlatform.androidOperator,
      size: const Size(390, 844),
      repo: repoOf(sleeveB),
      flow: (WidgetTester t, FakeShellHandbookRepository? repo) async {
        await openLink(t, 'handbook://${sleeveB.anchor}');
        expect(find.byKey(const Key('s01-handbook-slot')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('s01-handbook-slot')),
            matching: find.byKey(const Key('b02-title')),
          ),
          findsOneWidget,
        );
        expect(repo!.pageAnchors, <String>[sleeveB.anchor]);
      },
    ),
    (
      name: 'phone_null',
      platform: ShellPlatform.androidOperator,
      size: const Size(390, 844),
      repo: null,
      flow: (WidgetTester t, FakeShellHandbookRepository? repo) async {
        await openLink(t, 'handbook://${sleeveB.anchor}');
        expect(
          find.descendant(
            of: find.byKey(const Key('s01-handbook-slot')),
            matching: find.byType(ShellPlaceholder),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('b02-title')), findsNothing);
      },
    ),
    (
      name: 'web_sidebar_fifth',
      platform: ShellPlatform.web,
      size: const Size(1280, 800),
      repo: FakeShellHandbookRepository(
        index: (int call) => one(index),
        page: (int call) => const Stream<HandbookPage>.empty(),
      ),
      flow: (WidgetTester t, FakeShellHandbookRepository? repo) async {
        await t.tap(find.byKey(const ValueKey<String>('s02-item-4')));
        await t.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byKey(const Key('s02-handbook-slot')),
            matching: find.byKey(const ValueKey<String>('b01-entry-0')),
          ),
          findsOneWidget,
        );
      },
    ),
  ];

  for (final _ShellCase c in shellCases) {
    testWidgets('B02-07 shell wiring ${c.name}', (WidgetTester tester) async {
      await pumpShell(
        tester,
        overrides: <Override>[
          ...shellOverrides(
            platform: c.platform,
            config: flagsOf(kFlagsLiveAuto),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
          ),
          shellHandbookRepositoryProvider.overrideWithValue(c.repo),
        ],
        size: c.size,
      );
      await c.flow(tester, c.repo);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // B02-08 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<HandbookPage>.multi(
        (MultiStreamController<HandbookPage> c) {},
      ),
      loadingWant: findsOneWidget,
      failWant: findsNothing,
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(sleeveB),
      loadingWant: findsNothing,
      failWant: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('B02-08 state branch ${c.name}', (WidgetTester tester) async {
      await pumpHandbookPage(
        tester,
        overrides: overridesOf(
          FakeShellHandbookRepository(
            index: (int call) => const Stream<HandbookIndex>.empty(),
            page: c.stream,
          ),
          RecordingLinkOpener(),
        ),
        anchor: sleeveB.anchor,
      );
      expect(find.byKey(const Key('b02-loading')), c.loadingWant);
      expect(find.byKey(const Key('b02-fail')), c.failWant);
      expect(find.byKey(const Key('b02-title')), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('B02-08 retry', (WidgetTester tester) async {
    final FakeShellHandbookRepository repo = FakeShellHandbookRepository(
      index: (int call) => const Stream<HandbookIndex>.empty(),
      page: (int call) => call == 0 ? valueThenFail(sleeveB) : one(sleeveB),
    );
    await pumpHandbookPage(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
      anchor: sleeveB.anchor,
    );
    expect(
      tester
          .widget<ShellErrorView>(find.byKey(const Key('b02-fail')))
          .lastAsOfLabel,
      sleeveB.asOf!.label,
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('b02-fail')), findsNothing);
    expect(find.byKey(const Key('b02-title')), findsOneWidget);
    expect(repo.pageAnchors, <String>[sleeveB.anchor, sleeveB.anchor]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B02-09 every shown Text is engine text; no buttons; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'sleeve_b', v: sleeveB),
    (name: 'outdated', v: outdated),
    (name: 'missing', v: missing),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('B02-09 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpHandbookPage(
        tester,
        overrides: overridesOf(repoOf(c.v), RecordingLinkOpener()),
        anchor: c.v.anchor,
      );
      final Set<String> allowed = handbookPageAllowed(c.v);
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
        findsNothing,
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

  // B02-10 asOf header and stale banner for live pages only.
  final List<_AsOfCase> asOfCases = <_AsOfCase>[
    (
      name: 'fresh',
      now: kGoldenNowUtc,
      flow: (WidgetTester t) async {
        expect(find.byKey(const Key('b02-asof')), findsOneWidget);
        expect(shownTexts(t, find.byKey(const Key('b02-asof'))), <String?>[
          sleeveB.asOf!.label,
        ]);
        expect(find.byKey(const Key('b02-stale')), findsNothing);
        expect(
          t.getTopLeft(find.byKey(const Key('b02-asof'))).dy,
          lessThan(t.getTopLeft(find.byKey(const Key('b02-title'))).dy),
        );
      },
    ),
    (
      name: 'stale',
      now: kGoldenNowUtc.add(const Duration(days: 2)),
      flow: (WidgetTester t) async {
        expect(find.byKey(const Key('b02-stale')), findsOneWidget);
        expect(shownTexts(t, find.byKey(const Key('b02-stale'))), <String?>[
          ShellLabels.staleBannerTitle,
          sleeveB.asOf!.staleLabel,
        ]);
        final double asofTop = t
            .getTopLeft(find.byKey(const Key('b02-asof')))
            .dy;
        final double staleTop = t
            .getTopLeft(find.byKey(const Key('b02-stale')))
            .dy;
        final double titleTop = t
            .getTopLeft(find.byKey(const Key('b02-title')))
            .dy;
        expect(asofTop, lessThan(staleTop));
        expect(staleTop, lessThan(titleTop));
      },
    ),
  ];

  for (final _AsOfCase c in asOfCases) {
    testWidgets('B02-10 asof header and stale banner ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(sleeveB.asOf, isNotNull); // pre
      await pumpHandbookPage(
        tester,
        overrides: overridesOf(
          repoOf(sleeveB),
          RecordingLinkOpener(),
          now: c.now,
        ),
        anchor: sleeveB.anchor,
      );
      await c.flow(tester);
      expect(
        shownTexts(tester, find.byKey(const ValueKey<String>('b02-block-1'))),
        blockTexts(sleeveB.blocks[1]),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }
}
