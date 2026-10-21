// holding_detail_test.dart — H6-2 HoldingDetail widget tests (T62-01~T62-11).
// No Korean string literals. All test names ASCII.
// imports: directives_ordering — as verified by analyze.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holding_detail_fakes.dart';
import 'holdings_overview_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

void main() {
  late HoldingDetailVm noStop;
  late HoldingDetailVm pnl;
  late HoldingDetailVm withStops;
  late HoldingDetailVm recon;
  late HoldingDetailVm integrity;

  setUpAll(() {
    noStop = singleFixture(
      FixturePaths.m6HoldingDetailNoStop,
      HoldingDetailVm.fromJson,
    );
    pnl = singleFixture(
      FixturePaths.m6HoldingDetailPnl,
      HoldingDetailVm.fromJson,
    );
    withStops = singleFixture(
      FixturePaths.m6HoldingDetailWithStops,
      HoldingDetailVm.fromJson,
    );
    recon = singleFixture(
      FixturePaths.m6HoldingDetailRecon,
      HoldingDetailVm.fromJson,
    );
    integrity = singleFixture(
      FixturePaths.m6HoldingDetailIntegrity,
      HoldingDetailVm.fromJson,
    );
  });

  // T62-01: entry, summary, link
  testWidgets('T62-01 entry summary link noStop', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(noStop, pnl);
    final String id = noStop.holding.holdingId;
    await pumpHoldingDetail(
      tester,
      overrides: holdingDetailOverrides(repo: repo, opener: opener),
      holdingId: id,
    );

    expect(repo.calls, <(String, bool)>[(id, false)]);

    expect(
      holdingsShownTexts(tester, const Key('h62-asof')),
      <String>[noStop.asOf.label],
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('h62-sleeve'))).data,
      noStop.sleeveLabel,
    );

    expect(
      holdingsShownTexts(tester, const Key('h62-summary')),
      holdingDetailSummaryTexts(noStop.holding),
    );

    if (noStop.holding.pendingText != null) {
      expect(find.byKey(const Key('h62-pending')), findsOneWidget);
    } else {
      expect(find.byKey(const Key('h62-pending')), findsNothing);
    }

    if (noStop.holding.subBookLabel != null) {
      expect(find.byKey(const Key('h62-subbook')), findsOneWidget);
    } else {
      expect(find.byKey(const Key('h62-subbook')), findsNothing);
    }

    final Finder summary = find.byKey(const Key('h62-summary'));
    for (final TrancheStep s in noStop.holding.smaTranches) {
      expect(
        holdingsChipIcon(tester, summary, s.label),
        s.filled ? Icons.check_circle : Icons.radio_button_unchecked,
      );
    }

    for (final GateBadge g in noStop.holding.gates) {
      expect(g.state, GateState.pass);
      expect(
        holdingsChipIcon(tester, summary, g.label),
        Icons.check_circle_outline,
      );
    }

    expect(
      find.descendant(
        of: find.byKey(const Key('h62-entry-link')),
        matching: find.text(noStop.entryDecisionLink.label),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('h62-entry-link')));
    await tester.tap(find.byKey(const Key('h62-entry-link')));
    await tester.pump();
    expect(opener.opened, <String>[noStop.entryDecisionLink.deepLink]);

    expect(noStop.stopLines, isEmpty);
    expect(find.byKey(const Key('h62-stop-0')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('h62-no-stop'))).data,
      noStop.noStopLineText,
    );

    expect(noStop.recentEntries, isEmpty);
    expect(find.byKey(const Key('h62-entry-0')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('h62-recent-empty'))).data,
      noStop.recentEmptyLabel,
    );

    expect(find.byKey(const Key('h62-pnl')), findsNothing);
    expect(noStop.pnlToggleLabel, isNotNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('h62-pnl-toggle')),
        matching: find.text(noStop.pnlToggleLabel!),
      ),
      findsOneWidget,
    );

    final double dyAsof = tester.getTopLeft(find.byKey(const Key('h62-asof'))).dy;
    final double dySleeve = tester.getTopLeft(find.byKey(const Key('h62-sleeve'))).dy;
    final double dySummary = tester.getTopLeft(find.byKey(const Key('h62-summary'))).dy;
    final double dyToggle = tester.getTopLeft(find.byKey(const Key('h62-pnl-toggle'))).dy;
    final double dyLink = tester.getTopLeft(find.byKey(const Key('h62-entry-link'))).dy;
    final double dyNoStop = tester.getTopLeft(find.byKey(const Key('h62-no-stop'))).dy;
    final double dyRecentEmpty = tester.getTopLeft(find.byKey(const Key('h62-recent-empty'))).dy;
    expect(dyAsof, lessThan(dySleeve));
    expect(dySleeve, lessThan(dySummary));
    expect(dySummary, lessThan(dyToggle));
    expect(dyToggle, lessThan(dyLink));
    expect(dyLink, lessThan(dyNoStop));
    expect(dyNoStop, lessThan(dyRecentEmpty));

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T62-02: stop line text rows
  testWidgets('T62-02 stop line text rows', (WidgetTester tester) async {
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(withStops, pnl);
    final String id = withStops.holding.holdingId;
    await pumpHoldingDetail(
      tester,
      overrides: holdingDetailOverrides(repo: repo),
      holdingId: id,
    );

    expect(withStops.stopLines, hasLength(1));
    for (final (int i, StopLineNormalized s) in withStops.stopLines.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h62-stop-$i')),
        holdingDetailStopTexts(s),
      );
      final Text tierText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(ValueKey<String>('h62-stop-$i')),
          matching: find.text(s.tierLabel),
        ),
      );
      expect(
        tierText.style?.fontWeight,
        s.isActive ? FontWeight.bold : FontWeight.normal,
      );
    }

    expect(find.byKey(const ValueKey<String>('h62-stop-1')), findsNothing);
    expect(withStops.noStopLineText, isNull);
    expect(find.byKey(const Key('h62-no-stop')), findsNothing);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T62-03: recent entries from VM
  testWidgets('T62-03 recent entries from VM', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(withStops, pnl);
    final String id = withStops.holding.holdingId;
    await pumpHoldingDetail(
      tester,
      overrides: holdingDetailOverrides(repo: repo, opener: opener),
      holdingId: id,
    );

    expect(withStops.recentEntries, hasLength(3));

    for (final (int k, TradeJournalEntry e)
        in withStops.recentEntries.indexed) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('h62-entry-$k')),
          matching: find.text(e.symbolLabel),
        ),
        findsOneWidget,
      );
    }

    final double dy0 = tester.getTopLeft(find.byKey(const ValueKey<String>('h62-entry-0'))).dy;
    final double dy1 = tester.getTopLeft(find.byKey(const ValueKey<String>('h62-entry-1'))).dy;
    final double dy2 = tester.getTopLeft(find.byKey(const ValueKey<String>('h62-entry-2'))).dy;
    expect(dy0, lessThan(dy1));
    expect(dy1, lessThan(dy2));

    expect(find.byKey(const ValueKey<String>('h62-entry-3')), findsNothing);
    expect(find.byKey(const Key('h62-recent-empty')), findsNothing);

    for (final (int k, TradeJournalEntry e)
        in withStops.recentEntries.indexed) {
      expect(e.detailDeepLink, isNotNull);
      await tester.tap(
        find.descendant(
          of: find.byKey(ValueKey<String>('h62-entry-$k')),
          matching: find.text(e.symbolLabel),
        ),
      );
      await tester.pump();
    }

    expect(
      opener.opened,
      <String>[
        for (final TradeJournalEntry e in withStops.recentEntries)
          e.detailDeepLink!,
      ],
    );

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T62-04: pnl expand = resubscribe, collapse, re-entry
  testWidgets('T62-04 pnl expand resubscribe collapse reentry',
      (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(noStop, pnl);
    final String id = noStop.holding.holdingId;
    final List<Override> overrides =
        holdingDetailOverrides(repo: repo, opener: opener);
    await pumpHoldingDetail(tester, overrides: overrides, holdingId: id);

    expect(repo.calls, <(String, bool)>[(id, false)]);
    expect(find.byKey(const Key('h62-pnl')), findsNothing);

    await tapHoldingDetailPnlToggle(tester);
    expect(repo.calls, <(String, bool)>[(id, false), (id, true)]);
    expect(pnl.holding.pnl, isNotNull);

    final HoldingPnl p = pnl.holding.pnl!;
    expect(
      holdingsShownTexts(tester, const Key('h62-pnl')),
      <String?>[p.pnlText, p.pnlPctText, p.disclosureNote],
    );
    expect(
      holdingsShownTexts(tester, const Key('h62-summary')),
      holdingDetailSummaryTexts(pnl.holding),
    );

    await tapHoldingDetailPnlToggle(tester);
    expect(repo.calls, <(String, bool)>[(id, false), (id, true)]);
    expect(find.byKey(const Key('h62-pnl')), findsNothing);

    await tapHoldingDetailPnlToggle(tester);
    expect(repo.calls, <(String, bool)>[(id, false), (id, true)]);
    expect(
      find.descendant(
        of: find.byKey(const Key('h62-pnl-toggle')),
        matching: find.byIcon(Icons.expand_less),
      ),
      findsOneWidget,
    );

    await pumpHoldingDetail(
      tester,
      overrides: overrides,
      holdingId: id,
      screenKey: const ValueKey<String>('again'),
    );
    await tester.pump();
    expect(repo.calls, <(String, bool)>[(id, false), (id, true)]);
    expect(find.byKey(const Key('h62-pnl')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('h62-pnl-toggle')),
        matching: find.byIcon(Icons.expand_more),
      ),
      findsOneWidget,
    );

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T62-05: RECON = text only, no warning icon
  testWidgets('T62-05 RECON text only no warning icon',
      (WidgetTester tester) async {
    final SafetyState safety = safetyFixtureRow(3);
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(recon, pnl);
    await pumpHoldingDetail(
      tester,
      overrides: holdingDetailOverrides(repo: repo, safety: safety),
      holdingId: recon.holding.holdingId,
    );

    for (final BlockFlag f in safety.activeFlags) {
      expect(find.text(f.label), findsOneWidget);
    }
    expect(
      holdingsShownTexts(tester, const Key('h62-summary')),
      holdingDetailSummaryTexts(recon.holding),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('h62-summary')),
        matching: find.byIcon(Icons.warning_amber_rounded),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('h62-summary')),
        matching: find.byIcon(Icons.error_outline),
      ),
      findsNothing,
    );

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T62-06: INTEGRITY = masked text, chips absent
  testWidgets('T62-06 INTEGRITY masked text chips absent',
      (WidgetTester tester) async {
    final SafetyState safety = safetyFixtureRow(4);
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(integrity, pnl);
    await pumpHoldingDetail(
      tester,
      overrides: holdingDetailOverrides(repo: repo, safety: safety),
      holdingId: integrity.holding.holdingId,
    );

    for (final BlockFlag f in safety.activeFlags) {
      expect(find.text(f.label), findsOneWidget);
    }
    expect(integrity.holding.smaTranches, isEmpty);
    expect(integrity.holding.pendingText, isNull);
    expect(
      holdingsShownTexts(tester, const Key('h62-summary')),
      holdingDetailSummaryTexts(integrity.holding),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('h62-summary')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('h62-pending')), findsNothing);

    expect(integrity.stopLines, hasLength(1));
    for (final (int i, StopLineNormalized s) in integrity.stopLines.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h62-stop-$i')),
        holdingDetailStopTexts(s),
      );
    }

    expect(integrity.recentEntries.length, 2);
    for (final (int k, TradeJournalEntry _) in integrity.recentEntries.indexed) {
      expect(find.byKey(ValueKey<String>('h62-entry-$k')), findsOneWidget);
    }

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T62-07: all Text widgets in allowed set (two cases, for-loop testWidgets)
  final List<(String, Future<void> Function(WidgetTester))> t62Cases07 =
      <(String, Future<void> Function(WidgetTester))>[
    ('closed', (_) async {}),
    ('expanded', (WidgetTester t) async { await tapHoldingDetailPnlToggle(t); }),
  ];

  for (final (String caseName, Future<void> Function(WidgetTester) steps) in t62Cases07) {
    testWidgets('T62-07 all screen texts in allowed set $caseName',
        (WidgetTester tester) async {
      final FakeHoldingDetailRepository repo = fakeHoldingDetail(noStop, pnl);
      await pumpHoldingDetail(
        tester,
        overrides: holdingDetailOverrides(repo: repo),
        holdingId: noStop.holding.holdingId,
      );
      await steps(tester);

      final Set<String> allowedSet = caseName == 'closed'
          ? holdingDetailAllowed(noStop)
          : holdingDetailAllowed(pnl);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowedSet));
      }

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T62-08: branch x banner — for-loop testWidgets per case
  final DateTime t62StaleNow = kGoldenNowUtc.add(const Duration(days: 2));

  for (final (
    String caseName,
    FakeHoldingDetailRepository Function() repoFactory,
    Clock clock,
    Future<void> Function(WidgetTester) steps,
    bool wantSkeleton,
    bool wantError,
    bool wantHead,
    bool wantBanner,
    bool wantStale,
  ) in <(
    String,
    FakeHoldingDetailRepository Function(),
    Clock,
    Future<void> Function(WidgetTester),
    bool,
    bool,
    bool,
    bool,
    bool,
  )>[
    (
      'loading',
      () {
        final StreamController<HoldingDetailVm> ctrl =
            StreamController<HoldingDetailVm>();
        return FakeHoldingDetailRepository(
          detail: (String id, bool inc, int c) {
            addTearDown(() {
              unawaited(ctrl.close());
            });
            return inc ? Stream<HoldingDetailVm>.value(pnl) : ctrl.stream;
          },
        );
      },
      FixedClock(kGoldenNowUtc),
      (_) async {},
      true, false, false, false, false,
    ),
    (
      'fail',
      () => FakeHoldingDetailRepository(
        detail: (String id, bool inc, int c) => inc
            ? Stream<HoldingDetailVm>.value(pnl)
            : Stream<HoldingDetailVm>.error(StateError('fail')),
      ),
      FixedClock(kGoldenNowUtc),
      (_) async {},
      false, true, false, false, false,
    ),
    (
      'normal',
      () => fakeHoldingDetail(noStop, pnl),
      FixedClock(kGoldenNowUtc),
      (_) async {},
      false, false, true, true, false,
    ),
    (
      'normal_stale',
      () => fakeHoldingDetail(noStop, pnl),
      FixedClock(t62StaleNow),
      (_) async {},
      false, false, true, true, true,
    ),
    (
      'integrity',
      () => fakeHoldingDetail(integrity, pnl),
      FixedClock(kGoldenNowUtc),
      (_) async {},
      false, false, true, true, false,
    ),
    (
      'pnl_loading',
      () {
        final StreamController<HoldingDetailVm> ctrl =
            StreamController<HoldingDetailVm>();
        return FakeHoldingDetailRepository(
          detail: (String id, bool inc, int c) {
            addTearDown(() {
              unawaited(ctrl.close());
            });
            return inc ? ctrl.stream : Stream<HoldingDetailVm>.value(noStop);
          },
        );
      },
      FixedClock(kGoldenNowUtc),
      (WidgetTester t) async {
        await tapHoldingDetailPnlToggle(t);
      },
      true, false, false, false, false,
    ),
    (
      'pnl_fail',
      () => FakeHoldingDetailRepository(
        detail: (String id, bool inc, int c) => inc
            ? Stream<HoldingDetailVm>.error(StateError('fail'))
            : Stream<HoldingDetailVm>.value(noStop),
      ),
      FixedClock(kGoldenNowUtc),
      (WidgetTester t) async {
        await tapHoldingDetailPnlToggle(t);
      },
      false, true, false, false, false,
    ),
  ]) {
    testWidgets('T62-08 branch x banner $caseName', (WidgetTester tester) async {
      final SafetyState safety = safetyFixtureRow(3);
      final FakeHoldingDetailRepository repo = repoFactory();

      await pumpHoldingDetail(
        tester,
        overrides: holdingDetailOverrides(
          repo: repo,
          safety: safety,
          clock: clock,
        ),
        holdingId: noStop.holding.holdingId,
      );

      await steps(tester);

      expect(
        find.byKey(const Key('h62-loading')),
        wantSkeleton ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const Key('h62-fail')),
        wantError ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const Key('h62-asof')),
        wantHead ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.text(JournalLabels.staleBannerTitle),
        wantStale ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.text(JournalLabels.retry),
        wantError ? findsOneWidget : findsNothing,
        reason: caseName,
      );

      for (final BlockFlag f in safety.activeFlags) {
        expect(
          find.text(f.label),
          wantBanner ? findsOneWidget : findsNothing,
          reason: '$caseName flag ${f.label}',
        );
      }

      expect(find.byType(CircularProgressIndicator), findsNothing, reason: caseName);
      expect(find.byType(LinearProgressIndicator), findsNothing, reason: caseName);
    });
  }

  // T62-09: error and retry — for-loop testWidgets per case
  for (final (
    String caseName,
    FakeHoldingDetailRepository Function() repoFactory,
    String? Function() wantLastAsOfFn,
    List<(String, bool)> Function(String) wantCalls,
    Future<void> Function(WidgetTester) steps,
  ) in <(
    String,
    FakeHoldingDetailRepository Function(),
    String? Function(),
    List<(String, bool)> Function(String),
    Future<void> Function(WidgetTester),
  )>[
    (
      'detail_fail',
      () {
        int callCount = 0;
        return FakeHoldingDetailRepository(
          detail: (String id, bool inc, int c) {
            callCount++;
            if (callCount == 1) {
              return Stream<HoldingDetailVm>.error(StateError('fail'));
            }
            return Stream<HoldingDetailVm>.value(noStop);
          },
        );
      },
      () => null,
      (String id) => <(String, bool)>[(id, false), (id, false)],
      (_) async {},
    ),
    (
      'pnl_fail',
      () {
        int pnlCallCount = 0;
        return FakeHoldingDetailRepository(
          detail: (String id, bool inc, int c) {
            if (!inc) {
              return Stream<HoldingDetailVm>.value(noStop);
            }
            pnlCallCount++;
            if (pnlCallCount == 1) {
              return Stream<HoldingDetailVm>.error(StateError('fail'));
            }
            return Stream<HoldingDetailVm>.value(pnl);
          },
        );
      },
      () => null,
      (String id) => <(String, bool)>[(id, false), (id, true), (id, true)],
      (WidgetTester t) async {
        await tapHoldingDetailPnlToggle(t);
      },
    ),
    (
      'value_then_fail',
      () => FakeHoldingDetailRepository(
        detail: (String id, bool inc, int call) {
          if (call == 0) {
            return valueThenFail(noStop);
          }
          return Stream<HoldingDetailVm>.value(noStop);
        },
      ),
      () => noStop.asOf.label,
      (String id) => <(String, bool)>[(id, false), (id, false)],
      (_) async {},
    ),
  ]) {
    testWidgets('T62-09 error and retry $caseName', (WidgetTester tester) async {
      final SafetyState safety = safetyFixtureRow(3);
      final FakeHoldingDetailRepository repo = repoFactory();
      final String id = noStop.holding.holdingId;
      await pumpHoldingDetail(
        tester,
        overrides: holdingDetailOverrides(repo: repo, safety: safety),
        holdingId: id,
      );

      await steps(tester);

      expect(find.byKey(const Key('h62-fail')), findsOneWidget, reason: caseName);
      final JournalErrorView errorView =
          tester.widget<JournalErrorView>(find.byKey(const Key('h62-fail')));
      expect(errorView.lastAsOfLabel, wantLastAsOfFn(), reason: caseName);
      for (final BlockFlag f in safety.activeFlags) {
        expect(find.text(f.label), findsNothing, reason: caseName);
      }

      await tester.ensureVisible(find.text(JournalLabels.retry));
      await tester.tap(find.text(JournalLabels.retry));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('h62-fail')), findsNothing, reason: caseName);
      expect(find.byKey(const Key('h62-asof')), findsOneWidget, reason: caseName);
      expect(repo.calls, wantCalls(id), reason: caseName);

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T62-10: large font — for-loop testWidgets per case
  for (final (
    String caseName,
    HoldingDetailVm Function() closedFn,
    HoldingDetailVm Function() openFn,
    Future<void> Function(WidgetTester) steps,
  ) in <(
    String,
    HoldingDetailVm Function(),
    HoldingDetailVm Function(),
    Future<void> Function(WidgetTester),
  )>[
    ('with_stops', () => withStops, () => pnl, (_) async {}),
    (
      'expanded',
      () => noStop,
      () => pnl,
      (WidgetTester t) async {
        await tapHoldingDetailPnlToggle(t);
      },
    ),
  ]) {
    testWidgets('T62-10 large font $caseName', (WidgetTester tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final HoldingDetailVm closed = closedFn();
      final HoldingDetailVm open = openFn();
      final FakeHoldingDetailRepository repo = fakeHoldingDetail(closed, open);
      await pumpHoldingDetail(
        tester,
        overrides: holdingDetailOverrides(repo: repo),
        holdingId: closed.holding.holdingId,
      );
      await steps(tester);

      expect(tester.takeException(), isNull, reason: caseName);
      expect(find.byKey(const Key('h62-asof')), findsOneWidget, reason: caseName);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T62-11: pnl row = data (not _pnlOpen)
  testWidgets('T62-11 pnl row from data not pnlOpen',
      (WidgetTester tester) async {
    final FakeHoldingDetailRepository repo = fakeHoldingDetail(pnl, noStop);
    final String id = pnl.holding.holdingId;
    await pumpHoldingDetail(
      tester,
      overrides: holdingDetailOverrides(repo: repo),
      holdingId: id,
    );

    expect(pnl.holding.pnl, isNotNull);
    expect(repo.calls, <(String, bool)>[(id, false)]);
    expect(find.byKey(const Key('h62-pnl')), findsOneWidget);

    await tapHoldingDetailPnlToggle(tester);
    expect(repo.calls, <(String, bool)>[(id, false), (id, true)]);
    expect(find.byKey(const Key('h62-pnl')), findsNothing);

    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
