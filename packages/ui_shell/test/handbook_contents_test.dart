// test/handbook_contents_test.dart - B01-01 ~ B01-08 (B-01 handbook contents).

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

(IconData, Color) wantState(ColorScheme cs, HandbookEntryState s) =>
    switch (s) {
      HandbookEntryState.ready => (Icons.menu_book_outlined, cs.primary),
      HandbookEntryState.preparing => (
        Icons.hourglass_empty,
        cs.onSurfaceVariant,
      ),
      HandbookEntryState.archived => (Icons.inventory_2_outlined, cs.outline),
    };

typedef _IconCase = ({
  String name,
  HandbookEntry entry,
  HandbookEntryState want,
  Key key,
});

typedef _TapCase = ({String name, HandbookEntry entry, Key key});

typedef _StateCase = ({
  String name,
  Stream<HandbookIndex> Function(int call) stream,
  Matcher loadingWant,
  Matcher failWant,
});

typedef _TextCase = ({String name, HandbookIndex v});

void main() {
  final HandbookIndex index = singleFixture(
    FixturePaths.m8HandbookIndex,
    HandbookIndex.fromJson,
  );
  final HandbookIndex indexOutdated = singleFixture(
    FixturePaths.m8HandbookIndexOutdated,
    HandbookIndex.fromJson,
  );

  FakeShellHandbookRepository repoOf(HandbookIndex v) =>
      FakeShellHandbookRepository(
        index: (int call) => one(v),
        page: (int call) => const Stream<HandbookPage>.empty(),
      );

  List<Override> overridesOf(
    FakeShellHandbookRepository? repo,
    RecordingLinkOpener opener,
  ) => handbookOverrides(
    repo: repo,
    opener: opener,
    clock: FixedClock(kGoldenNowUtc),
  );

  // B01-01 entry order, words and children.
  testWidgets('B01-01 entry order and words', (WidgetTester tester) async {
    final FakeShellHandbookRepository repo = repoOf(index);
    await pumpHandbookContents(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
    );
    expect(index.entries, hasLength(8));
    expect(index.entries[1].children, hasLength(4));
    final List<Key> chain = <Key>[
      for (final (int i, HandbookEntry e) in index.entries.indexed) ...<Key>[
        ValueKey<String>('b01-entry-$i'),
        for (final (int j, HandbookEntry _) in e.children.indexed)
          ValueKey<String>('b01-entry-$i-$j'),
      ],
    ];
    final List<double> tops = chain
        .map((Key k) => tester.getTopLeft(find.byKey(k)).dy)
        .toList();
    for (int i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]));
    }
    for (final (int i, HandbookEntry e) in index.entries.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('b01-entry-$i'))),
        <String?>[e.title, ?e.stateLabel],
      );
      for (final (int j, HandbookEntry c) in e.children.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('b01-entry-$i-$j'))),
          <String?>[c.title, ?c.stateLabel],
        );
      }
    }
    expect(find.byKey(const ValueKey<String>('b01-entry-8')), findsNothing);
    expect(find.byKey(const ValueKey<String>('b01-entry-1-4')), findsNothing);
    expect(find.byKey(const ValueKey<String>('b01-entry-0-0')), findsNothing);
    expect(find.byKey(const Key('b01-outdated')), findsNothing);
    expect(repo.indexCalls, 1);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B01-02 state -> icon and color.
  final List<_IconCase> iconCases = <_IconCase>[
    (
      name: 'ready',
      entry: index.entries[0],
      want: HandbookEntryState.ready,
      key: const ValueKey<String>('b01-state-0'),
    ),
    (
      name: 'preparing',
      entry: index.entries[5],
      want: HandbookEntryState.preparing,
      key: const ValueKey<String>('b01-state-5'),
    ),
    (
      name: 'archived',
      entry: index.entries[1].children[3],
      want: HandbookEntryState.archived,
      key: const ValueKey<String>('b01-state-1-3'),
    ),
  ];

  for (final _IconCase c in iconCases) {
    testWidgets('B01-02 state icon ${c.name}', (WidgetTester tester) async {
      expect(c.entry.state, c.want); // pre
      await pumpHandbookContents(
        tester,
        overrides: overridesOf(repoOf(index), RecordingLinkOpener()),
      );
      final ColorScheme cs = Theme.of(tester.element(find.byKey(c.key)))
          .colorScheme;
      final Icon icon = tester.widget<Icon>(find.byKey(c.key));
      expect(icon.icon, wantState(cs, c.want).$1);
      expect(icon.color, wantState(cs, c.want).$2);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // B01-03 tap on an entry with a link opens the received link.
  final List<_TapCase> linkCases = <_TapCase>[
    (
      name: 'top',
      entry: index.entries[0],
      key: const ValueKey<String>('b01-entry-0'),
    ),
    (
      name: 'child',
      entry: index.entries[1].children[1],
      key: const ValueKey<String>('b01-entry-1-1'),
    ),
  ];

  for (final _TapCase c in linkCases) {
    testWidgets('B01-03 tap opens link ${c.name}', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpHandbookContents(
        tester,
        overrides: overridesOf(repoOf(index), opener),
      );
      await tester.tap(find.byKey(c.key));
      await tester.pump();
      expect(opener.opened, <String>[c.entry.deepLink!]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // B01-04 a preparing entry has no link and no tap.
  testWidgets('B01-04 preparing entry has no tap', (WidgetTester tester) async {
    expect(index.entries[5].deepLink, isNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpHandbookContents(
      tester,
      overrides: overridesOf(repoOf(index), opener),
    );
    expect(find.byKey(const ValueKey<String>('b01-entry-5')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('b01-entry-5')));
    await tester.pump();
    expect(opener.opened, <String>[]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B01-05 outdated notice is data, on top, no close.
  testWidgets('B01-05 outdated notice on top', (WidgetTester tester) async {
    expect(indexOutdated.outdatedNotice, isNotNull); // pre
    await pumpHandbookContents(
      tester,
      overrides: overridesOf(repoOf(indexOutdated), RecordingLinkOpener()),
    );
    expect(shownTexts(tester, find.byKey(const Key('b01-outdated'))), <String?>[
      indexOutdated.outdatedNotice,
    ]);
    expect(
      tester.getTopLeft(find.byKey(const Key('b01-outdated'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey<String>('b01-entry-0'))).dy,
      ),
    );
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    expect(find.byType(IconButton), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B01-06 null injection keeps the placeholder.
  testWidgets('B01-06 null injection placeholder', (WidgetTester tester) async {
    await pumpHandbookContents(
      tester,
      overrides: overridesOf(null, RecordingLinkOpener()),
    );
    expect(find.byType(ShellPlaceholder), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('b01-entry-0')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B01-07 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<HandbookIndex>.multi(
        (MultiStreamController<HandbookIndex> c) {},
      ),
      loadingWant: findsOneWidget,
      failWant: findsNothing,
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(index),
      loadingWant: findsNothing,
      failWant: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('B01-07 state branch ${c.name}', (WidgetTester tester) async {
      await pumpHandbookContents(
        tester,
        overrides: overridesOf(
          FakeShellHandbookRepository(
            index: c.stream,
            page: (int call) => const Stream<HandbookPage>.empty(),
          ),
          RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('b01-loading')), c.loadingWant);
      expect(find.byKey(const Key('b01-fail')), c.failWant);
      expect(find.byKey(const ValueKey<String>('b01-entry-0')), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('B01-07 retry', (WidgetTester tester) async {
    final FakeShellHandbookRepository repo = FakeShellHandbookRepository(
      index: (int call) => call == 0
          ? Stream<HandbookIndex>.error(StateError('fail'))
          : one(index),
      page: (int call) => const Stream<HandbookPage>.empty(),
    );
    await pumpHandbookContents(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
    );
    expect(find.byKey(const Key('b01-fail')), findsOneWidget);
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('b01-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('b01-entry-0')), findsOneWidget);
    expect(repo.indexCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // B01-08 every shown Text is engine text; no buttons; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'index', v: index),
    (name: 'index_outdated', v: indexOutdated),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('B01-08 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpHandbookContents(
        tester,
        overrides: overridesOf(repoOf(c.v), RecordingLinkOpener()),
      );
      final Set<String> allowed = handbookIndexAllowed(c.v);
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
}
