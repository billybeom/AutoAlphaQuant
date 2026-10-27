// test/ops_home_test.dart — T01-01 ~ T01-12
//
// H-01 ops home tests — ⓡ 11 (T01-01·02·03·04·05·06·07·08·10·11·12) · ⓗ 3 (T01-05·06·07).

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

// wantIcon/wantColor for T01-06
IconData _wantIcon(UiLevel l) => switch (l) {
  UiLevel.ok => Icons.check_circle_outline,
  UiLevel.info => Icons.info_outline,
  UiLevel.watch => Icons.visibility_outlined,
  UiLevel.act => Icons.error_outline,
  UiLevel.blocked => Icons.block,
};

Color _wantColor(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => cs.primary,
  UiLevel.info => cs.onSurfaceVariant,
  UiLevel.watch => cs.tertiary,
  UiLevel.act => cs.secondary,
  UiLevel.blocked => cs.error,
};

void main() {
  final OpsDailySummary normal = singleFixture(
    FixturePaths.m8OpsHomeNormal,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary resume = singleFixture(
    FixturePaths.m8OpsHomeResumeGap7,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary adviceT = singleFixture(
    FixturePaths.m8OpsHomeAdviceOpen,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary zeroT = singleFixture(
    FixturePaths.m8OpsHomeAdviceZero,
    OpsDailySummary.fromJson,
  );
  final AdviceInboxSummary open = extraFixture(
    FixturePaths.m8OpsHomeAdviceOpen,
    'advice_summary',
    AdviceInboxSummary.fromJson,
  );
  final AdviceInboxSummary zero = extraFixture(
    FixturePaths.m8OpsHomeAdviceZero,
    'advice_summary',
    AdviceInboxSummary.fromJson,
  );
  final AdviceInboxSummary none = zero.copyWith(hasSuppressedNotice: false);
  final AdviceInboxSummary suppressed = extraFixture(
    FixturePaths.m6AdviceNoAction,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final AdviceInboxSummary sdue = extraFixture(
    FixturePaths.m8OpsHomeAdviceSuppressedDue,
    'advice_summary',
    AdviceInboxSummary.fromJson,
  );
  final SafetyState safe0 = safetyFixtureRow(0);
  final SafetyState safe1 = safetyFixtureRow(1);
  final SafetyState safe3 = safetyFixtureRow(3);
  final SleeveAllocationVm alloc = singleFixture(
    FixturePaths.m6AllocationInBand,
    SleeveAllocationVm.fromJson,
  );
  final SleeveAllocationVm empty = singleFixture(
    FixturePaths.m6AllocationEmpty,
    SleeveAllocationVm.fromJson,
  );
  final DiagnosticsVm diff = singleFixture(
    FixturePaths.m8ReconBoardDiff,
    DiagnosticsVm.fromJson,
  );
  final DiagnosticsVm ok = singleFixture(
    FixturePaths.m8ReconBoardOk,
    DiagnosticsVm.fromJson,
  );
  final LedgerTrustBadge trustDue = singleFixture(
    FixturePaths.m7LedgerTrustSelfAuditDue,
    LedgerTrustBadge.fromJson,
  );
  final LedgerTrustBadge viewer = trustDue.copyWith(actionDeepLink: null);

  final List<SleeveAllocationRow> top = alloc.rows
      .where((SleeveAllocationRow r) => r.parentSleeve == null)
      .toList();

  final Clock clock = FixedClock(kGoldenNowUtc);

  // ── T01-01 block order ──────────────────────────────────────────────────────

  final List<
    (
      String,
      OpsDailySummary,
      SafetyState,
      AdviceInboxSummary,
      List<String>,
      List<String>,
    )
  >
  cases01 =
      <
        (
          String,
          OpsDailySummary,
          SafetyState,
          AdviceInboxSummary,
          List<String>,
          List<String>,
        )
      >[
        (
          'normal',
          normal,
          safe0,
          none,
          <String>[
            'h01-asof',
            'h01-status',
            'h01-alloc',
            'h01-process',
            'h01-recon',
            'h01-today',
            'h01-upcoming',
            'h01-more',
          ],
          <String>['h01-resume', 'h01-blocked', 'h01-advice', 'h01-audit'],
        ),
        (
          'full',
          resume,
          safe3,
          open,
          <String>[
            'h01-asof',
            'h01-status',
            'h01-resume',
            'h01-blocked',
            'h01-advice',
            'h01-alloc',
            'h01-process',
            'h01-recon',
            'h01-today',
            'h01-upcoming',
            'h01-more',
          ],
          <String>['h01-audit'],
        ),
      ];

  for (final (
        String name,
        OpsDailySummary todayF,
        SafetyState safetyF,
        AdviceInboxSummary adviceF,
        List<String> chain,
        List<String> absent,
      )
      in cases01) {
    testWidgets('T01-01 block order\n$name', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeShellSafetyRepository safetyRepo = FakeShellSafetyRepository(
        state: (int call) => one(safetyF),
      );
      final FakeShellOpsTodayRepository todayRepo = FakeShellOpsTodayRepository(
        today: (int call) => one(todayF),
      );
      final FakeShellAdviceRepository adviceRepo = FakeShellAdviceRepository(
        summary: (int call) => one(adviceF),
      );
      final FakeShellHoldingsRepository allocRepo = FakeShellHoldingsRepository(
        allocation: (int call) => one(alloc),
      );
      final FakeShellOpsStatusRepository diagRepo =
          FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok));
      final FakeShellLedgerTrustRepository trustRepo =
          FakeShellLedgerTrustRepository(grade: (int call) => one(trustDue));
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: safetyRepo,
          today: todayRepo,
          advice: adviceRepo,
          alloc: allocRepo,
          diag: diagRepo,
          trust: trustRepo,
          opener: opener,
          clock: clock,
        ),
      );
      expect(safetyRepo.calls, 1);
      expect(todayRepo.calls, 1);
      expect(adviceRepo.calls, 1);
      expect(allocRepo.calls, 1);
      expect(diagRepo.calls, 1);
      expect(trustRepo.calls, 1);
      expect(shownTexts(tester, find.byKey(const Key('h01-asof'))), <String>[
        todayF.asOf.label,
      ]);
      expect(find.text(ShellLabels.staleBannerTitle), findsNothing);
      for (int i = 1; i < chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(ValueKey<String>(chain[i]))).dy,
          greaterThan(
            tester.getTopLeft(find.byKey(ValueKey<String>(chain[i - 1]))).dy,
          ),
          reason: '$name: ${chain[i]} below ${chain[i - 1]}',
        );
      }
      for (final String k in absent) {
        expect(
          find.byKey(ValueKey<String>(k)),
          findsNothing,
          reason: '$name: $k absent',
        );
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-02 block 2 resume ───────────────────────────────────────────────────

  final List<(String, OpsDailySummary)> cases02 = <(String, OpsDailySummary)>[
    ('resume_gap7', resume),
    ('normal', normal),
  ];

  for (final (String name, OpsDailySummary todayF) in cases02) {
    testWidgets('T01-02 block 2 resume\n$name', (WidgetTester tester) async {
      expect(resume.resumeLine, isNotNull); // pre
      expect(normal.resumeLine, isNull); // pre
      final String? want = name == 'resume_gap7'
          ? resume.resumeLine!.label
          : null;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(todayF)),
          advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(alloc),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(ok),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: opener,
          clock: clock,
        ),
      );
      if (want != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('h01-resume'))),
          <String>[want],
        );
        await tester.tap(find.byKey(const Key('h01-resume')));
        await tester.pump();
        expect(opener.opened, <String>[resume.resumeLine!.deepLink]);
      } else {
        expect(find.byKey(const Key('h01-resume')), findsNothing);
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-03 block 3 blocking only ────────────────────────────────────────────

  final List<String> wantHalted = safe3.activeFlags
      .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
      .map((BlockFlag f) => f.label)
      .toList();

  final List<(String, SafetyState)> cases03 = <(String, SafetyState)>[
    ('halted', safe3),
    ('marker_only', safe1),
    ('none', safe0),
  ];

  for (final (String name, SafetyState safetyF) in cases03) {
    testWidgets('T01-03 block 3 blocking only\n$name', (
      WidgetTester tester,
    ) async {
      expect(wantHalted, isNotEmpty); // pre
      expect(safe1.activeFlags, isNotEmpty); // pre
      final List<String>? want = name == 'halted' ? wantHalted : null;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safetyF)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(alloc),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(ok),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: opener,
          clock: clock,
        ),
      );
      if (want != null) {
        expect(shownTexts(tester, find.byKey(const Key('h01-blocked'))), want);
        await tester.tap(find.byKey(const Key('h01-blocked')));
        await tester.pump();
        expect(opener.opened[0], AppRoutes.m5BlockBoard);
        await tester.tap(find.byKey(const Key('h01-status')));
        await tester.pump();
        expect(opener.opened[1], AppRoutes.m5BlockBoard);
      } else {
        expect(find.byKey(const Key('h01-blocked')), findsNothing);
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-04 block 3b ─────────────────────────────────────────────────────────

  final List<(String, AdviceInboxSummary, List<String>?)> cases04 =
      <(String, AdviceInboxSummary, List<String>?)>[
        (
          'open',
          open,
          <String>[open.headline, open.dueSoonLabel!, open.trust.label],
        ),
        ('zero_none', none, null),
        ('suppressed', suppressed, <String>[suppressed.headline]),
        ('suppressed_due', sdue, <String>[sdue.headline]),
      ];

  for (final (String name, AdviceInboxSummary adviceF, List<String>? want)
      in cases04) {
    testWidgets('T01-04 block 3b\n$name', (WidgetTester tester) async {
      expect(open.openCount, isNot(0)); // pre
      expect(open.dueSoonLabel, isNotNull); // pre
      expect(zero.openCount, 0); // pre
      expect(zero.hasSuppressedNotice, isTrue); // pre
      expect(suppressed.hasSuppressedNotice, isTrue); // pre
      expect(sdue.hasSuppressedNotice, isTrue); // pre
      expect(sdue.dueSoonLabel, isNotNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
          today: FakeShellOpsTodayRepository(
            today: (int call) => one(name == 'open' ? adviceT : zeroT),
          ),
          advice: FakeShellAdviceRepository(
            summary: (int call) => one(adviceF),
          ),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(alloc),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(ok),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: opener,
          clock: clock,
        ),
      );
      if (want != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('h01-advice'))),
          want,
          reason: name,
        );
        if (name == 'open') {
          await tester.tap(find.byKey(const Key('h01-advice')));
          await tester.pump();
          expect(opener.opened, <String>[AppRoutes.adviceInbox]);
        } else {
          expect(opener.opened, isEmpty, reason: name);
        }
      } else {
        expect(find.byKey(const Key('h01-advice')), findsNothing, reason: name);
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-05 block 4 top rows, pct only, no amounts ───────────────────────────

  final List<(String, SleeveAllocationVm, Future<void> Function(WidgetTester))>
  cases05 = <(String, SleeveAllocationVm, Future<void> Function(WidgetTester))>[
    (
      'band',
      alloc,
      (WidgetTester t) async {
        expect(top, hasLength(4)); // ⓗ
        for (final (int i, SleeveAllocationRow r) in top.indexed) {
          expect(
            shownTexts(t, find.byKey(ValueKey<String>('h01-sleeve-$i'))),
            <String?>[
              r.sleeveLabel,
              ?r.sleeveWeight?.label,
              ?r.bandStateLabel,
              ?r.bandNoteText,
              ShellLabels.homeDeployed,
              r.deployedPctText,
              ShellLabels.homeParking,
              r.parkingPctText,
            ],
            reason: 'sleeve $i',
          );
        }
        expect(
          find.byKey(const ValueKey<String>('h01-sleeve-4')),
          findsNothing,
        );
        for (final SleeveAllocationRow r in alloc.rows) {
          expect(find.text(r.deployedText), findsNothing);
          expect(find.text(r.parkingText), findsNothing);
        }
        final List<SleeveAllocationRow> potRows = alloc.rows
            .where((SleeveAllocationRow r) => r.parentSleeve != null)
            .toList();
        for (final SleeveAllocationRow r in potRows) {
          expect(find.text(r.sleeveLabel), findsNothing);
        }
      },
    ),
    (
      'empty',
      empty,
      (WidgetTester t) async {
        expect(shownTexts(t, find.byKey(const Key('h01-alloc'))), <String>[
          empty.emptyLabel!,
        ]);
        expect(
          find.byKey(const ValueKey<String>('h01-sleeve-0')),
          findsNothing,
        );
      },
    ),
  ];

  for (final (
        String name,
        SleeveAllocationVm allocF,
        Future<void> Function(WidgetTester) steps,
      )
      in cases05) {
    testWidgets('T01-05 block 4 rows\n$name', (WidgetTester tester) async {
      expect(top.length, lessThan(alloc.rows.length)); // pre
      expect(empty.rows, isEmpty); // pre
      expect(empty.noticeText, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(allocF),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(ok),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: opener,
          clock: clock,
        ),
      );
      await steps(tester);
      await tester.tap(find.byKey(const Key('h01-alloc')));
      await tester.pump();
      expect(opener.opened, <String>[
        AppRoutes.holdingsAllocation,
      ], reason: name);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-06 block 6 cells ────────────────────────────────────────────────────

  final List<(String, DiagnosticsVm)> cases06 = <(String, DiagnosticsVm)>[
    ('diff', diff),
    ('ok', ok),
  ];

  for (final (String name, DiagnosticsVm diagF) in cases06) {
    testWidgets('T01-06 block 6 cells\n$name', (WidgetTester tester) async {
      expect(
        diff.cells.any((DiagnosticCell x) => !x.applicable),
        isTrue,
      ); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(alloc),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(diagF),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: opener,
          clock: clock,
        ),
      );
      expect(diagF.cells, hasLength(5), reason: name); // ⓗ
      final ColorScheme cs = Theme.of(tester.element(find.byType(OpsHome)))
          .colorScheme;
      for (final (int i, DiagnosticCell cell) in diagF.cells.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('h01-cell-$i'))),
          <String>[cell.label, cell.stateLabel],
          reason: '$name cell $i',
        );
        final Icon icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(ValueKey<String>('h01-cell-$i')),
            matching: find.byType(Icon),
          ),
        );
        expect(icon.icon, _wantIcon(cell.level), reason: '$name cell $i icon');
        expect(
          icon.color,
          _wantColor(cs, cell.level),
          reason: '$name cell $i color',
        );
      }
      expect(find.byKey(const ValueKey<String>('h01-cell-5')), findsNothing);
      expect(find.text(diagF.headline), findsOneWidget);
      await tester.tap(find.byKey(const Key('h01-recon')));
      await tester.pump();
      expect(opener.opened, <String>[AppRoutes.ledgerDiffs], reason: name);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-07 blocks 5·7·8 ─────────────────────────────────────────────────────

  testWidgets('T01-07 blocks 5 7 8', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpOpsHome(
      tester,
      overrides: homeOverrides(
        safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
        today: FakeShellOpsTodayRepository(today: (int call) => one(normal)),
        advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
        alloc: FakeShellHoldingsRepository(
          allocation: (int call) => one(alloc),
        ),
        diag: FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
        trust: FakeShellLedgerTrustRepository(
          grade: (int call) => one(trustDue),
        ),
        opener: opener,
        clock: clock,
      ),
    );
    expect(shownTexts(tester, find.byKey(const Key('h01-process'))), <String>[
      normal.streakText,
      normal.discretionBudgetText,
      normal.nextRebalanceDDayText,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('h01-today'))), <String>[
      normal.todayOrdersText,
      normal.todayErrorsText,
      normal.signalMatchText,
    ]);
    expect(normal.upcoming, hasLength(3)); // ⓗ
    for (final (int i, OpsRhythmRow r) in normal.upcoming.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('h01-up-$i'))),
        <String?>[r.title, r.whenText, ?r.dDayText],
        reason: 'upcoming $i',
      );
    }
    expect(find.byKey(const ValueKey<String>('h01-up-3')), findsNothing);
    await tester.tap(find.byKey(const Key('h01-today')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('h01-up-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('h01-more')));
    await tester.pump();
    expect(opener.opened, <String>[
      AppRoutes.opsRhythm,
      AppRoutes.opsRhythm,
      AppRoutes.opsRhythm,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
  });

  // ── T01-08 block 9b self audit ──────────────────────────────────────────────

  final List<(String, SafetyState, LedgerTrustBadge, bool, bool)> cases08 =
      <(String, SafetyState, LedgerTrustBadge, bool, bool)>[
        ('due', safe1, trustDue, true, true),
        ('viewer', safe1, viewer, true, false),
        ('none', safe0, trustDue, false, false),
      ];

  for (final (
        String name,
        SafetyState safetyF,
        LedgerTrustBadge trustF,
        bool wantCard,
        bool wantButton,
      )
      in cases08) {
    testWidgets('T01-08 block 9b audit\n$name', (WidgetTester tester) async {
      expect(trustDue.level, UiLevel.info); // pre
      expect(trustDue.actionDeepLink, isNotNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safetyF)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(alloc),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(ok),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustF),
          ),
          opener: opener,
          clock: clock,
        ),
      );
      expect(
        find.byKey(const Key('h01-audit')),
        wantCard ? findsOneWidget : findsNothing,
        reason: name,
      );
      if (wantCard) {
        final List<String?> texts = shownTexts(
          tester,
          find.byKey(const Key('h01-audit')),
        );
        expect(texts[0], trustF.label, reason: name);
        expect(texts[1], trustF.consequenceLine, reason: name);
        expect(
          find.byKey(const Key('h01-audit-action')),
          wantButton ? findsOneWidget : findsNothing,
          reason: name,
        );
        final ColorScheme cs = Theme.of(tester.element(find.byType(OpsHome)))
            .colorScheme;
        if (name == 'due') {
          await tester.tap(find.byKey(const Key('h01-audit-action')));
          await tester.pump();
          expect(opener.opened, <String>[trustDue.actionDeepLink!]);
          final Card card = tester.widget<Card>(
            find.byKey(const Key('h01-audit')),
          );
          expect(card.color, cs.surfaceContainerHighest, reason: 'info color');
          expect(card.color, isNot(cs.errorContainer), reason: 'not error');
        } else {
          expect(opener.opened, isEmpty, reason: name);
        }
      } else {
        expect(
          find.byKey(const Key('h01-audit-action')),
          findsNothing,
          reason: name,
        );
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-09 state branches ───────────────────────────────────────────────────

  final List<
    (
      String,
      FakeShellOpsTodayRepository Function(),
      FakeShellSafetyRepository Function(),
      FakeShellHoldingsRepository Function(),
      FakeShellOpsStatusRepository Function(),
      FakeShellAdviceRepository Function(),
      FakeShellLedgerTrustRepository Function(),
      Clock,
      List<String>,
      List<String>,
      bool,
      Future<void> Function(WidgetTester),
    )
  >
  cases09 =
      <
        (
          String,
          FakeShellOpsTodayRepository Function(),
          FakeShellSafetyRepository Function(),
          FakeShellHoldingsRepository Function(),
          FakeShellOpsStatusRepository Function(),
          FakeShellAdviceRepository Function(),
          FakeShellLedgerTrustRepository Function(),
          Clock,
          List<String>,
          List<String>,
          bool,
          Future<void> Function(WidgetTester),
        )
      >[
        (
          'today_loading',
          () => FakeShellOpsTodayRepository(
            today: (int call) {
              final StreamController<OpsDailySummary> ctrl =
                  StreamController<OpsDailySummary>();
              addTearDown(() {
                unawaited(ctrl.close());
              });
              return ctrl.stream;
            },
          ),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-loading'],
          <String>['h01-fail', 'h01-status', 'h01-alloc'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'today_fail',
          () => FakeShellOpsTodayRepository(
            today: (int call) =>
                Stream<OpsDailySummary>.error(StateError('fail')),
          ),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-fail'],
          <String>['h01-loading', 'h01-status', 'h01-alloc'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'today_value_then_fail',
          () => FakeShellOpsTodayRepository(
            today: (int call) => valueThenFail(normal),
          ),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-asof'],
          <String>['h01-fail'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'today_stale',
          () => FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
          <String>['h01-asof', 'h01-status'],
          <String>[],
          true,
          (WidgetTester t) async {
            expect(
              t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
              lessThan(t.getTopLeft(find.byKey(const Key('h01-status'))).dy),
            );
          },
        ),
        (
          'safety_fail',
          () => FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          () => FakeShellSafetyRepository(
            state: (int call) => Stream<SafetyState>.error(StateError('fail')),
          ),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-status-fail'],
          <String>['h01-status', 'h01-blocked', 'h01-audit'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'alloc_fail',
          () => FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () => FakeShellHoldingsRepository(
            allocation: (int call) =>
                Stream<SleeveAllocationVm>.error(StateError('fail')),
          ),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-alloc-fail'],
          <String>['h01-alloc'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'diag_fail',
          () => FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () => FakeShellOpsStatusRepository(
            diagnostics: (int call) =>
                Stream<DiagnosticsVm>.error(StateError('fail')),
          ),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-recon-fail'],
          <String>['h01-recon'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'advice_fail',
          () => FakeShellOpsTodayRepository(today: (int call) => one(adviceT)),
          () => FakeShellSafetyRepository(state: (int call) => one(safe0)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(
            summary: (int call) =>
                Stream<AdviceInboxSummary>.error(StateError('fail')),
          ),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          clock,
          <String>['h01-asof'],
          <String>['h01-advice'],
          false,
          (WidgetTester t) async {},
        ),
        (
          'trust_fail',
          () => FakeShellOpsTodayRepository(today: (int call) => one(normal)),
          () => FakeShellSafetyRepository(state: (int call) => one(safe1)),
          () =>
              FakeShellHoldingsRepository(allocation: (int call) => one(alloc)),
          () =>
              FakeShellOpsStatusRepository(diagnostics: (int call) => one(ok)),
          () => FakeShellAdviceRepository(summary: (int call) => one(none)),
          () => FakeShellLedgerTrustRepository(
            grade: (int call) =>
                Stream<LedgerTrustBadge>.error(StateError('fail')),
          ),
          clock,
          <String>['h01-asof'],
          <String>['h01-audit'],
          false,
          (WidgetTester t) async {},
        ),
      ];

  for (final (
        String name,
        FakeShellOpsTodayRepository Function() todayFactory,
        FakeShellSafetyRepository Function() safetyFactory,
        FakeShellHoldingsRepository Function() allocFactory,
        FakeShellOpsStatusRepository Function() diagFactory,
        FakeShellAdviceRepository Function() adviceFactory,
        FakeShellLedgerTrustRepository Function() trustFactory,
        Clock c,
        List<String> present,
        List<String> absent,
        bool stale,
        Future<void> Function(WidgetTester) flow,
      )
      in cases09) {
    testWidgets('T01-09 state branches\n$name', (WidgetTester tester) async {
      final FakeShellOpsTodayRepository todayRepo = todayFactory();
      final FakeShellSafetyRepository safetyRepo = safetyFactory();
      final FakeShellHoldingsRepository allocRepo = allocFactory();
      final FakeShellOpsStatusRepository diagRepo = diagFactory();
      final FakeShellAdviceRepository adviceRepo = adviceFactory();
      final FakeShellLedgerTrustRepository trustRepo = trustFactory();
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: safetyRepo,
          today: todayRepo,
          advice: adviceRepo,
          alloc: allocRepo,
          diag: diagRepo,
          trust: trustRepo,
          opener: RecordingLinkOpener(),
          clock: c,
        ),
      );
      await tester.pump();
      for (final String k in present) {
        expect(
          find.byKey(ValueKey<String>(k)),
          findsOneWidget,
          reason: '$name: $k present',
        );
      }
      for (final String k in absent) {
        expect(
          find.byKey(ValueKey<String>(k)),
          findsNothing,
          reason: '$name: $k absent',
        );
      }
      expect(
        find.text(ShellLabels.staleBannerTitle),
        stale ? findsOneWidget : findsNothing,
        reason: '$name stale=$stale',
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await flow(tester);
    });
  }

  // ── T01-10 retry ────────────────────────────────────────────────────────────

  final List<(String, String, String)> cases10 = <(String, String, String)>[
    ('today', 'h01-fail', 'h01-asof'),
    ('safety', 'h01-status-fail', 'h01-status'),
    ('alloc', 'h01-alloc-fail', 'h01-alloc'),
    ('diag', 'h01-recon-fail', 'h01-recon'),
  ];

  for (final (String which, String failKey, String successKey) in cases10) {
    testWidgets('T01-10 retry\n$which', (WidgetTester tester) async {
      final FakeShellSafetyRepository safetyRepo = FakeShellSafetyRepository(
        state: (int call) => which == 'safety'
            ? (call == 0
                  ? Stream<SafetyState>.error(StateError('fail'))
                  : one(safe0))
            : one(safe0),
      );
      final FakeShellOpsTodayRepository todayRepo = FakeShellOpsTodayRepository(
        today: (int call) => which == 'today'
            ? (call == 0
                  ? Stream<OpsDailySummary>.error(StateError('fail'))
                  : one(normal))
            : one(normal),
      );
      final FakeShellHoldingsRepository allocRepo = FakeShellHoldingsRepository(
        allocation: (int call) => which == 'alloc'
            ? (call == 0
                  ? Stream<SleeveAllocationVm>.error(StateError('fail'))
                  : one(alloc))
            : one(alloc),
      );
      final FakeShellOpsStatusRepository diagRepo =
          FakeShellOpsStatusRepository(
            diagnostics: (int call) => which == 'diag'
                ? (call == 0
                      ? Stream<DiagnosticsVm>.error(StateError('fail'))
                      : one(ok))
                : one(ok),
          );
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: safetyRepo,
          today: todayRepo,
          advice: FakeShellAdviceRepository(summary: (int call) => one(none)),
          alloc: allocRepo,
          diag: diagRepo,
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: RecordingLinkOpener(),
          clock: clock,
        ),
      );
      expect(find.byKey(ValueKey<String>(failKey)), findsOneWidget);
      await tester.tap(find.text(ShellLabels.retry));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(ValueKey<String>(failKey)), findsNothing);
      expect(find.byKey(ValueKey<String>(successKey)), findsOneWidget);
      final int calls = which == 'today'
          ? todayRepo.calls
          : which == 'safety'
          ? safetyRepo.calls
          : which == 'alloc'
          ? allocRepo.calls
          : diagRepo.calls;
      expect(calls, 2, reason: '$which calls');
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── T01-11 foreground resume ─────────────────────────────────────────────────

  testWidgets('T01-11 foreground resume', (WidgetTester tester) async {
    final FakeShellSafetyRepository safetyRepo = FakeShellSafetyRepository(
      state: (int call) => one(safe0),
    );
    final FakeShellOpsTodayRepository todayRepo = FakeShellOpsTodayRepository(
      today: (int call) => one(normal),
    );
    final FakeShellAdviceRepository adviceRepo = FakeShellAdviceRepository(
      summary: (int call) => one(none),
    );
    final FakeShellHoldingsRepository allocRepo = FakeShellHoldingsRepository(
      allocation: (int call) => one(alloc),
    );
    final FakeShellOpsStatusRepository diagRepo = FakeShellOpsStatusRepository(
      diagnostics: (int call) => one(ok),
    );
    final FakeShellLedgerTrustRepository trustRepo =
        FakeShellLedgerTrustRepository(grade: (int call) => one(trustDue));
    await pumpOpsHome(
      tester,
      overrides: homeOverrides(
        safety: safetyRepo,
        today: todayRepo,
        advice: adviceRepo,
        alloc: allocRepo,
        diag: diagRepo,
        trust: trustRepo,
        opener: RecordingLinkOpener(),
        clock: clock,
      ),
    );
    expect(safetyRepo.calls, 1);
    expect(todayRepo.calls, 1);
    expect(adviceRepo.calls, 1);
    expect(allocRepo.calls, 1);
    expect(diagRepo.calls, 1);
    expect(trustRepo.calls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    await tester.pump();
    expect(safetyRepo.calls, 1);
    expect(todayRepo.calls, 1);
    expect(adviceRepo.calls, 1);
    expect(allocRepo.calls, 1);
    expect(diagRepo.calls, 1);
    expect(trustRepo.calls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(safetyRepo.calls, 2);
    expect(todayRepo.calls, 2);
    expect(adviceRepo.calls, 2);
    expect(allocRepo.calls, 2);
    expect(diagRepo.calls, 2);
    expect(trustRepo.calls, 2);
    expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
  });

  // ── T01-12 all texts on screen + large font ──────────────────────────────────

  final List<(String, Set<String>)> cases12 = <(String, Set<String>)>[
    (
      'advice_open',
      homeAllowed(
        today: adviceT,
        safety: safe0,
        advice: open,
        alloc: alloc,
        diag: ok,
        trust: trustDue,
      ),
    ),
    (
      'self_audit_due',
      homeAllowed(
        today: normal,
        safety: safe1,
        advice: none,
        alloc: alloc,
        diag: ok,
        trust: trustDue,
      ),
    ),
  ];

  for (final (String name, Set<String> allowed) in cases12) {
    testWidgets('T01-12 all texts large font\n$name', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(
            state: (int call) =>
                name == 'self_audit_due' ? one(safe1) : one(safe0),
          ),
          today: FakeShellOpsTodayRepository(
            today: (int call) =>
                name == 'advice_open' ? one(adviceT) : one(normal),
          ),
          advice: FakeShellAdviceRepository(
            summary: (int call) =>
                name == 'advice_open' ? one(open) : one(none),
          ),
          alloc: FakeShellHoldingsRepository(
            allocation: (int call) => one(alloc),
          ),
          diag: FakeShellOpsStatusRepository(
            diagnostics: (int call) => one(ok),
          ),
          trust: FakeShellLedgerTrustRepository(
            grade: (int call) => one(trustDue),
          ),
          opener: RecordingLinkOpener(),
          clock: clock,
        ),
      );
      final List<Text> allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .toList();
      expect(allTexts, isNotEmpty, reason: name);
      for (final Text t in allTexts) {
        final String data = t.data ?? '';
        expect(
          data.isEmpty || allowed.contains(data),
          isTrue,
          reason: '$name unexpected text: $data',
        );
      }
      expect(tester.takeException(), isNull, reason: name);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
    });
  }
}
