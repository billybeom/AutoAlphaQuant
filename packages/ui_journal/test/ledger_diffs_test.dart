// test/ledger_diffs_test.dart — L-1 LedgerDiffs widget tests (L1-01 ~ L1-11).
//
// Rules: extends-only fakes, fixture-sourced expected strings, ASCII test names,
// no Korean literals, no collection-if, no name/which comparison.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'ledger_fakes.dart';

// ── Expected icon/color from card _severityLook ───────────────────────────────

IconData _wantIcon(DiffSeverity s) => switch (s) {
  DiffSeverity.blocking => Icons.block,
  DiffSeverity.observational => Icons.visibility_outlined,
};

Color _wantColor(ColorScheme cs, DiffSeverity s) => switch (s) {
  DiffSeverity.blocking => cs.error,
  DiffSeverity.observational => cs.onSurfaceVariant,
};

// ── L1-04 cases ───────────────────────────────────────────────────────────────

class _L104Case {
  const _L104Case({
    required this.name,
    required this.input,
    required this.want,
    required this.steps,
    required this.opened,
  });
  final String name;
  final List<int> input;
  final String? want;
  final Future<void> Function(WidgetTester) steps;
  final List<String> opened;
}

// ── L1-07 cases ───────────────────────────────────────────────────────────────

class _L107Case {
  const _L107Case({
    required this.name,
    required this.diffs,
    required this.clock,
    required this.present,
    required this.absent,
    required this.stale,
    required this.asOfText,
  });
  final String name;
  final Stream<ListResult<LedgerDiffRow>> Function(int) diffs;
  final Clock? clock;
  final List<Key> present;
  final List<Key> absent;
  final Matcher stale;
  final Matcher asOfText;
}

void main() {
  final ListResult<LedgerDiffRow> full = listFixture(
    FixturePaths.ledgerDiffs4,
    LedgerDiffRow.fromJson,
  );

  // ── L1-04 case definitions (uses full) ───────────────────────────────────────

  List<_L104Case> l104cases() => <_L104Case>[
    _L104Case(
      name: 'broker_qty',
      input: <int>[0],
      want: full.rows[0].actionLink!.label,
      steps: (WidgetTester t) async {
        await t.tap(
          find.descendant(
            of: find.byKey(const ValueKey<String>('l1-row-0')),
            matching: find.byType(FilledButton),
          ),
        );
        await t.pump();
      },
      opened: <String>[full.rows[0].actionLink!.deepLink],
    ),
    _L104Case(
      name: 'push_lag',
      input: <int>[1],
      want: null,
      steps: (WidgetTester t) async {},
      opened: <String>[],
    ),
  ];

  // ── L1-07 case definitions ────────────────────────────────────────────────────

  final List<_L107Case> l107cases = <_L107Case>[
    _L107Case(
      name: 'loading',
      diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.fromFuture(
        Completer<ListResult<LedgerDiffRow>>().future,
      ),
      clock: null,
      present: <Key>[const Key('l1-loading')],
      absent: <Key>[
        const Key('l1-asof'),
        const Key('l1-fail'),
        const Key('l1-repairs-link'),
      ],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _L107Case(
      name: 'fail',
      diffs: (int call) =>
          Stream<ListResult<LedgerDiffRow>>.error(StateError('fail')),
      clock: null,
      present: <Key>[const Key('l1-fail')],
      absent: <Key>[
        const Key('l1-loading'),
        const Key('l1-asof'),
        const Key('l1-repairs-link'),
      ],
      stale: findsNothing,
      asOfText: findsNothing,
    ),
    _L107Case(
      name: 'value_then_fail',
      diffs: (int call) => ledgerValueThenFail(full),
      clock: null,
      present: <Key>[const Key('l1-fail')],
      absent: <Key>[
        const Key('l1-asof'),
        const ValueKey<String>('l1-row-0'),
        const Key('l1-repairs-link'),
      ],
      stale: findsNothing,
      asOfText: findsOneWidget,
    ),
    _L107Case(
      name: 'stale',
      diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
      clock: ledgerStaleClock(),
      present: <Key>[
        const Key('l1-asof'),
        const ValueKey<String>('l1-row-0'),
        const Key('l1-repairs-link'),
      ],
      absent: <Key>[const Key('l1-loading'), const Key('l1-fail')],
      stale: findsOneWidget,
      asOfText: findsOneWidget,
    ),
  ];

  // L1-01 full list, received order, texts
  testWidgets('L1-01 full list received order texts', (
    WidgetTester tester,
  ) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeLedgerDiffsRepository repo = FakeLedgerDiffsRepository(
      diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
    );
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(repo: repo, opener: opener),
    );
    expect(full.rows, hasLength(4)); // pre
    for (final (int i, LedgerDiffRow r) in full.rows.indexed) {
      expect(
        ledgerShownTexts(tester, find.byKey(ValueKey<String>('l1-row-$i'))),
        ledgerDiffTexts(r),
      );
    }
    expect(find.byKey(const ValueKey<String>('l1-row-4')), findsNothing);
    expect(ledgerShownTexts(tester, find.byKey(const Key('l1-asof'))), <String>[
      full.asOf.label,
    ]);
    final double dyAsOf = tester
        .getTopLeft(find.byKey(const Key('l1-asof')))
        .dy;
    final double dyRow0 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('l1-row-0')))
        .dy;
    final double dyRow1 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('l1-row-1')))
        .dy;
    final double dyRow2 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('l1-row-2')))
        .dy;
    final double dyRow3 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('l1-row-3')))
        .dy;
    final double dyRepairs = tester
        .getTopLeft(find.byKey(const Key('l1-repairs-link')))
        .dy;
    expect(dyAsOf, lessThan(dyRow0));
    expect(dyRow0, lessThan(dyRow1));
    expect(dyRow1, lessThan(dyRow2));
    expect(dyRow2, lessThan(dyRow3));
    expect(dyRow3, lessThan(dyRepairs));
    expect(find.text(JournalLabels.ledgerCandidateOrigins), findsNWidgets(4));
    expect(find.text(JournalLabels.ledgerEvidence), findsNWidgets(4));
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    expect(repo.calls, 1);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-02 severity icon/color = exhaustive switch
  testWidgets('L1-02 severity icon color exhaustive switch', (
    WidgetTester tester,
  ) async {
    expect(
      <DiffSeverity>{for (final LedgerDiffRow r in full.rows) r.severity},
      <DiffSeverity>{DiffSeverity.blocking, DiffSeverity.observational},
    ); // pre
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
        ),
      ),
    );
    final ColorScheme cs = Theme.of(tester.element(find.byType(LedgerDiffs)))
        .colorScheme;
    for (final (int i, LedgerDiffRow r) in full.rows.indexed) {
      final Finder rowFinder = find.byKey(ValueKey<String>('l1-row-$i'));
      expect(
        find.descendant(of: rowFinder, matching: find.byType(Icon)),
        findsOneWidget,
      );
      final Icon icon = tester.widget<Icon>(
        find.descendant(of: rowFinder, matching: find.byType(Icon)),
      );
      expect(icon.icon, _wantIcon(r.severity));
      expect(icon.color, _wantColor(cs, r.severity));
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-03 accepted = resolved same weight
  testWidgets('L1-03 accepted resolved same style weight', (
    WidgetTester tester,
  ) async {
    expect(full.rows[2].status, DiffStatus.accepted); // pre
    expect(full.rows[3].status, DiffStatus.resolved); // pre
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
        ),
      ),
    );
    final TextStyle? styleAccepted = tester
        .widget<Text>(find.text(full.rows[2].statusLabel))
        .style;
    final TextStyle? styleResolved = tester
        .widget<Text>(find.text(full.rows[3].statusLabel))
        .style;
    final TextStyle? styleRow0 = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const ValueKey<String>('l1-row-0')),
            matching: find.text(full.rows[0].statusLabel),
          ),
        )
        .style;
    expect(styleAccepted, styleResolved);
    expect(styleAccepted, styleRow0);
    expect(
      find.ancestor(
        of: find.text(full.rows[2].statusLabel),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-04 action link present/absent — per case
  for (final _L104Case c in l104cases()) {
    testWidgets('L1-04 action link ${c.name}', (WidgetTester tester) async {
      expect(full.rows[0].actionLink, isNotNull); // pre
      expect(full.rows[1].actionLink, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final ListResult<LedgerDiffRow> input = ledgerDiffSlice(full, c.input);
      await pumpLedgerDiffs(
        tester,
        overrides: ledgerOverrides(
          repo: FakeLedgerDiffsRepository(
            diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(input),
          ),
          opener: opener,
        ),
      );
      final String? want = c.want;
      if (want != null) {
        expect(
          ledgerShownTexts(
            tester,
            find.descendant(
              of: find.byKey(const ValueKey<String>('l1-row-0')),
              matching: find.byType(FilledButton),
            ),
          ),
          <String?>[want],
        );
      } else {
        expect(
          find.descendant(
            of: find.byKey(const ValueKey<String>('l1-row-0')),
            matching: find.byType(FilledButton),
          ),
          findsNothing,
        );
      }
      await c.steps(tester);
      expect(opener.opened, c.opened);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // L1-05 candidate origin chips received order read-only chip tap = handbook
  testWidgets('L1-05 candidate origin chips received order', (
    WidgetTester tester,
  ) async {
    expect(full.rows[0].candidateOrigins[0].detailDeepLink, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
        ),
        opener: opener,
      ),
    );
    expect(full.rows[0].candidateOrigins, hasLength(2));
    final Finder row0 = find.byKey(const ValueKey<String>('l1-row-0'));
    expect(
      find.descendant(of: row0, matching: find.byType(JournalReasonChip)),
      findsNWidgets(2),
    );
    for (final ReasonChip chip in full.rows[0].candidateOrigins) {
      expect(
        find.descendant(of: row0, matching: find.text(chip.label)),
        findsOneWidget,
      );
    }
    await tester.tap(
      find.descendant(
        of: row0,
        matching: find.text(full.rows[0].candidateOrigins[0].label),
      ),
    );
    await tester.pump();
    expect(opener.opened, <String>[
      full.rows[0].candidateOrigins[0].detailDeepLink!,
    ]);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(Radio), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-06 bottom repairs link = constant
  testWidgets('L1-06 bottom repairs link constant', (
    WidgetTester tester,
  ) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
        ),
        opener: opener,
      ),
    );
    await tester.tap(find.byKey(const Key('l1-repairs-link')));
    await tester.pump();
    expect(opener.opened, <String>[AppRoutes.ledgerRepairs]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-07 state x branches — per case
  for (final _L107Case c in l107cases) {
    testWidgets('L1-07 state branches ${c.name}', (WidgetTester tester) async {
      await pumpLedgerDiffs(
        tester,
        overrides: ledgerOverrides(
          repo: FakeLedgerDiffsRepository(diffs: c.diffs),
          clock: c.clock,
        ),
      );
      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.text(full.asOf.label), c.asOfText);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // L1-08 retry
  testWidgets('L1-08 retry invalidates and reloads', (
    WidgetTester tester,
  ) async {
    final FakeLedgerDiffsRepository repo = FakeLedgerDiffsRepository(
      diffs: (int call) => call == 0
          ? Stream<ListResult<LedgerDiffRow>>.error(StateError('fail'))
          : Stream<ListResult<LedgerDiffRow>>.value(full),
    );
    await pumpLedgerDiffs(tester, overrides: ledgerOverrides(repo: repo));
    await tester.tap(find.text(JournalLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('l1-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('l1-row-0')), findsOneWidget);
    expect(repo.calls, 2);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-09 safety banner = shared component
  testWidgets('L1-09 safety banner shared component', (
    WidgetTester tester,
  ) async {
    final SafetyState safety3 = safetyFixtureRow(3);
    expect(safety3.activeFlags, isNotEmpty); // pre
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
        ),
        safety: safety3,
      ),
    );
    final String firstFlagLabel = safety3.activeFlags.first.label;
    expect(find.text(firstFlagLabel), findsOneWidget);
    final double dyBanner = tester.getTopLeft(find.text(firstFlagLabel)).dy;
    final double dyAsOf = tester
        .getTopLeft(find.byKey(const Key('l1-asof')))
        .dy;
    final double dyRow0 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('l1-row-0')))
        .dy;
    expect(dyBanner, greaterThan(dyAsOf));
    expect(dyBanner, lessThan(dyRow0));
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-10 empty slice rows=0 emptyLabel=null
  testWidgets('L1-10 empty slice rows 0 emptyLabel null', (
    WidgetTester tester,
  ) async {
    expect(full.emptyLabel, isNull); // pre
    final ListResult<LedgerDiffRow> emptySlice = ledgerDiffSlice(full, <int>[]);
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) =>
              Stream<ListResult<LedgerDiffRow>>.value(emptySlice),
        ),
      ),
    );
    expect(find.byKey(const ValueKey<String>('l1-row-0')), findsNothing);
    expect(find.byKey(const Key('l1-empty')), findsNothing);
    expect(find.byKey(const Key('l1-asof')), findsOneWidget);
    expect(find.byKey(const Key('l1-repairs-link')), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // L1-11 all screen texts large font
  testWidgets('L1-11 all screen texts large font scale', (
    WidgetTester tester,
  ) async {
    final Set<String> allowed = ledgerDiffsAllowed(full);
    await pumpLedgerDiffs(
      tester,
      overrides: ledgerOverrides(
        repo: FakeLedgerDiffsRepository(
          diffs: (int call) => Stream<ListResult<LedgerDiffRow>>.value(full),
        ),
      ),
    );
    final List<String?> shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data)
        .toList();
    expect(shown, isNotEmpty);
    for (final String? data in shown) {
      expect(data, isIn(allowed));
    }
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
