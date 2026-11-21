// test/strategy_allocation_test.dart
//
// M9 S04 - StrategyAllocation widget tests (view only, first board).
//
// ASCII only. No Korean literals. No collection-if. No bare if statements.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

void main() {
  final AllocationEditorVm editor = singleFixture(
    FixturePaths.m9AllocationEditor,
    AllocationEditorVm.fromJson,
  );
  final AllocationEditorVm stale = singleFixture(
    FixturePaths.m9AllocationEditorStale,
    AllocationEditorVm.fromJson,
  );

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.error(StateError('no write')),
  );
  SettingsActions? noActions() => null;

  // -- M9S04-01: block order texts - card, sections, path, asof, no button ----

  for (final c in <({String name, SettingsActions? Function() actionsFactory})>[
    (name: 'default', actionsFactory: okActions),
    (name: 'viewer', actionsFactory: noActions),
  ]) {
    testWidgets('M9S04-01 block order texts ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsAllocationRepository repo =
          FakeSettingsAllocationRepository(
            allocation: (int call) => one(editor),
          );
      await pumpAllocation(
        tester,
        overrides: allocationOverrides(
          repo: repo,
          actions: c.actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final List<Key> chain = <Key>[
        const Key('m9s04-current'),
        const Key('m9s04-sections'),
        const Key('m9s04-path'),
        const Key('m9s04-asof'),
      ];
      expect(find.byKey(const Key('m9s04-sections')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s04-current'))),
        allocationCardTexts(editor),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s04-sections'))),
        allocationSectionsTexts(editor),
      );
      expect(
        find.byWidgetPredicate(isAllocationSection),
        findsNWidgets(editor.sections.length),
      );
      expect(
        find.byWidgetPredicate(isAllocationRow),
        findsNWidgets(allocationRows(editor).length),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s04-path'))),
        allocationPathTexts(editor),
      );
      expect(shownTexts(tester, find.byKey(const Key('m9s04-asof'))), <String?>[
        editor.asOf.label,
      ]);
      for (int i = 1; i < chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
        );
      }
      expect(find.byWidgetPredicate(isAnyButton), findsNothing);
      expect(find.byKey(const Key('m9s04-stale')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S04-02: section and row keys - received texts in received order ------

  testWidgets('M9S04-02 section and row keys default', (
    WidgetTester tester,
  ) async {
    expect(editor.sections, isNotEmpty); // pre
    final FakeSettingsAllocationRepository repo =
        FakeSettingsAllocationRepository(allocation: (int call) => one(editor));
    await pumpAllocation(
      tester,
      overrides: allocationOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    for (final (int i, AllocationReadOnlySection s)
        in editor.sections.indexed) {
      expect(
        shownTexts(tester, find.byKey(Key('m9s04-section-$i'))),
        allocationSectionTexts(s),
      );
      for (final (int j, AllocationReadOnlyRow r) in s.rows.indexed) {
        expect(
          shownTexts(tester, find.byKey(Key('m9s04-row-$i-$j'))),
          allocationRowTexts(r),
        );
      }
    }
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S04-03: taps write nothing and open nothing - no link, no input ------

  testWidgets('M9S04-03 taps write nothing and open nothing default', (
    WidgetTester tester,
  ) async {
    expect(allocationRows(editor), isNotEmpty); // pre
    final FakeSettingsAllocationRepository repo =
        FakeSettingsAllocationRepository(allocation: (int call) => one(editor));
    final FakeSettingsActions actions = okActions();
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAllocation(
      tester,
      overrides: allocationOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
    expect(find.byType(EditableText), findsNothing);
    await tester.tap(find.byKey(const Key('m9s04-current')));
    for (final (int i, AllocationReadOnlySection s)
        in editor.sections.indexed) {
      for (final (int j, AllocationReadOnlyRow _) in s.rows.indexed) {
        await tester.tap(find.byKey(Key('m9s04-row-$i-$j')));
      }
    }
    await tester.tap(find.byKey(const Key('m9s04-path')));
    await tester.pump();
    expect(opener.opened, <String>[]);
    expect(actions.ids, <SettingsActionId>[]);
    expect(actions.watchCalls, 0);
    expect(repo.allocationCalls, 1);
    expect(
      shownTexts(tester, find.byKey(const Key('m9s04-sections'))),
      allocationSectionsTexts(editor),
    );
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S04-04: asof and stale banner ----------------------------------------

  for (final c
      in <
        ({
          String name,
          AllocationEditorVm v,
          Clock clock,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[
        (
          name: 'fresh',
          v: editor,
          clock: FixedClock(editor.asOf.observedAt),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s04-current'), const Key('m9s04-asof')],
        ),
        (
          name: 'stale',
          v: stale,
          clock: FixedClock(
            stale.asOf.observedAt
                .add(stale.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?stale.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s04-stale'),
            const Key('m9s04-current'),
            const Key('m9s04-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S04-04 asof and stale banner ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(stale.asOf.staleLabel, isNotNull); // pre
      final FakeSettingsAllocationRepository repo =
          FakeSettingsAllocationRepository(allocation: (int call) => one(c.v));
      await pumpAllocation(
        tester,
        overrides: allocationOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s04-asof')), findsOneWidget);
      expect(shownTexts(tester, find.byKey(const Key('m9s04-asof'))), <String?>[
        c.v.asOf.label,
      ]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s04-stale'))),
        c.staleTexts,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s04-current'))),
        allocationCardTexts(c.v),
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S04-05: state branch - loading and error -----------------------------

  for (final c
      in <
        ({
          String name,
          Stream<AllocationEditorVm> Function(int call) allocation,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          allocation: (int call) => Stream<AllocationEditorVm>.multi(
            (MultiStreamController<AllocationEditorVm> m) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          allocation: (int call) =>
              Stream<AllocationEditorVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S04-05 state branch ${c.name}', (WidgetTester tester) async {
      final FakeSettingsAllocationRepository repo =
          FakeSettingsAllocationRepository(allocation: c.allocation);
      await pumpAllocation(
        tester,
        overrides: allocationOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s04-loading')), c.loading);
      expect(find.byKey(const Key('m9s04-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const Key('m9s04-current')), findsNothing);
    });
  }

  // -- M9S04-06: retry after error - subscribes once more ---------------------

  testWidgets('M9S04-06 retry after error', (WidgetTester tester) async {
    final FakeSettingsAllocationRepository repo =
        FakeSettingsAllocationRepository(
          allocation: (int call) => call == 0
              ? Stream<AllocationEditorVm>.error(StateError('fail'))
              : one(editor),
        );
    await pumpAllocation(
      tester,
      overrides: allocationOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('m9s04-fail')), findsNothing);
    expect(find.byKey(const Key('m9s04-current')), findsOneWidget);
    expect(repo.allocationCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S04-07: all texts allowed large font - every Text is received data ---

  for (final c in <({String name, SettingsActions? Function() actionsFactory})>[
    (name: 'default', actionsFactory: okActions),
    (name: 'viewer', actionsFactory: noActions),
  ]) {
    testWidgets('M9S04-07 all texts allowed large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final FakeSettingsAllocationRepository repo =
          FakeSettingsAllocationRepository(
            allocation: (int call) => one(editor),
          );
      await pumpAllocation(
        tester,
        overrides: allocationOverrides(
          repo: repo,
          actions: c.actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s04-asof')), findsOneWidget);
      final Set<String> allowed = allocationAllowed(editor);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(find.byType(EditableText), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }
}
