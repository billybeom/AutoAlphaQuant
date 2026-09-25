// timeline_test.dart — J-1 unit tests (ⓐ~ⓔ · §11 계약 v1.1 · G4 R1b)
//
// 🔴 No link literals — all link expectations use fixture values.
// 🔴 No raw value display — we expect *Text, not entry.price.toString() etc.
// 🔴 No row filtering — the fake repository receives args, does not filter.
// 🔴 G4: tests ② and ③ exercise actual UI (no direct query injection).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository({
    this.timelineResult,
    this.filterCatalog,
    this.badges = const <JournalTimelineBadge>[],
  });

  final ListResult<TradeJournalEntry>? timelineResult;
  final JournalFilterCatalog? filterCatalog;
  final List<JournalTimelineBadge> badges;

  // Track every watchTimeline call.
  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];

  Map<String, dynamic>? get lastWatchTimelineArgs =>
      calls.isEmpty ? null : calls.last;

  @override
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  }) {
    calls.add(<String, dynamic>{
      'range': range,
      'sleeve': sleeve,
      'symbol': symbol,
      'status': status,
      'origin': origin,
      'rebalanceEventId': rebalanceEventId,
      'mode': mode,
      'limit': limit,
    });
    if (timelineResult != null) {
      return Stream<ListResult<TradeJournalEntry>>.value(timelineResult!);
    }
    return const Stream<ListResult<TradeJournalEntry>>.empty();
  }

  @override
  Stream<JournalFilterCatalog> watchFilterCatalog() => filterCatalog != null
      ? Stream<JournalFilterCatalog>.value(filterCatalog!)
      : const Stream<JournalFilterCatalog>.empty();

  @override
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  }) => Stream<List<JournalTimelineBadge>>.value(badges);
}

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository(this.state);
  final SafetyState state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

class _FakeConfigRepository extends UnimplementedConfigRepository {
  _FakeConfigRepository({this.rangePresets, this.sleeves});
  final List<DateRange>? rangePresets;
  final List<SleeveCatalogEntry>? sleeves;

  @override
  Stream<List<DateRange>> watchRangePresets() => rangePresets != null
      ? Stream<List<DateRange>>.value(rangePresets!)
      : const Stream<List<DateRange>>.empty();

  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() => sleeves != null
      ? Stream<List<SleeveCatalogEntry>>.value(sleeves!)
      : const Stream<List<SleeveCatalogEntry>>.empty();
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime nowUtc() => _now;
}

// ── Helper: pump JournalTimeline with injected fakes ─────────────────────────
//
// G4: ProviderScope is placed ABOVE MaterialApp (wrapApp pattern) so that
// bottom sheet modals see the same injections.  This matches the golden
// harness `wrapApp` approach and the real app structure.

Future<_FakeJournalRepository> _pump(
  WidgetTester tester, {
  required ListResult<TradeJournalEntry> result,
  required SafetyState safety,

  /// Explicit initial query override (null = let screen auto-resolve from presets).
  JournalTimelineQuery? query,
  List<DateRange>? rangePresets,
  List<SleeveCatalogEntry>? sleeves,
  JournalFilterCatalog? filterCatalog,
  List<JournalTimelineBadge> badges = const <JournalTimelineBadge>[],
  RecordingLinkOpener? linkOpener,
}) async {
  final _FakeJournalRepository fakeJournal = _FakeJournalRepository(
    timelineResult: result,
    filterCatalog: filterCatalog,
    badges: badges,
  );

  final List<Override> overrides = <Override>[
    journalTimelineRepositoryProvider.overrideWithValue(fakeJournal),
    journalSafetyRepositoryProvider.overrideWithValue(
      _FakeSafetyRepository(safety),
    ),
    // G1: default is null → auto-resolve from presets.
    // Caller may pass an explicit query via overrideWith.
    if (query != null)
      journalTimelineQueryProvider.overrideWith((Ref ref) => query),
    journalClockProvider.overrideWithValue(
      _FixedClock(DateTime.utc(2026, 8, 31, 10)),
    ),
    journalConfigRepositoryProvider.overrideWithValue(
      _FakeConfigRepository(rangePresets: rangePresets, sleeves: sleeves),
    ),
    if (linkOpener != null)
      journalLinkOpenerProvider.overrideWithValue(linkOpener),
  ];

  // G4: ProviderScope above MaterialApp so modals (bottom sheets) see injections.
  // Set phone-sized viewport so DraggableScrollableSheet items are reachable.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: JournalTimeline())),
    ),
  );
  await tester.pump();
  return fakeJournal;
}

// ── Fixture loading helpers ───────────────────────────────────────────────────

SafetyState _normalSafety() => safetyFixtureRow(0);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // Load the journal_30 fixture once.
  final ListResult<TradeJournalEntry> journal30 = journalFixture(
    FixturePaths.journal30,
  );
  final TradeJournalEntry firstEntry = journal30.rows.first;

  // Range presets + filter catalog (used in multiple tests).
  final List<DateRange> rangePresets4 = listFixture(
    FixturePaths.rangePresets4,
    DateRange.fromJson,
  ).rows;
  final DateRange defaultPreset = rangePresets4.firstWhere(
    (DateRange r) => r.isDefault,
  );
  final JournalFilterCatalog filterCatalog = singleFixture(
    FixturePaths.m6JournalFilterCatalog,
    JournalFilterCatalog.fromJson,
  );

  // A14~A17 prep vars — defined after filterCatalog (compile order dependency).
  final DateRange nonDefaultPreset = rangePresets4.firstWhere(
    (DateRange r) => !r.isDefault,
  );
  final String reId = journal30.rows
      .firstWhere((TradeJournalEntry e) => e.rebalanceEventId != null)
      .rebalanceEventId!;
  final FillOriginOption originPick = filterCatalog.originOptions.first;

  // ─── ① *Text displayed; raw values absent ────────────────────────────────

  testWidgets(
    '① priceText is shown; raw price.toString() is absent when different',
    (WidgetTester tester) async {
      await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        query: JournalTimelineQuery(range: defaultPreset),
        rangePresets: rangePresets4,
      );

      // The engine-completed priceText must be visible.
      expect(find.text(firstEntry.priceText), findsWidgets);

      // sideLabel must appear; side.wire (BUY/SELL) must not.
      expect(find.text(firstEntry.sideLabel), findsWidgets);

      // If priceText differs from raw price.toString(), the raw value is absent.
      if (firstEntry.priceText != firstEntry.price.toString()) {
        expect(find.text(firstEntry.price.toString()), findsNothing);
      }
      // quantityText visible (engine string); raw quantity absent when different.
      expect(find.text(firstEntry.quantityText), findsWidgets);
      if (firstEntry.quantityText != firstEntry.quantity.toString()) {
        expect(find.text(firstEntry.quantity.toString()), findsNothing);
      }
    },
  );

  // ─── ② Default preset → first watchTimeline call (G4: no query override) ─
  //
  // The screen is pumped WITHOUT an explicit query override.
  // journalEffectiveQueryProvider auto-selects the isDefault preset from the
  // rangePresets4 fixture.  We verify that the FIRST watchTimeline call
  // received that preset as its range argument.

  testWidgets(
    '② isDefault preset auto-selected and passed as range to watchTimeline',
    (WidgetTester tester) async {
      // No `query` arg → null StateProvider → effective query resolves from presets.
      final _FakeJournalRepository fakeJournal = await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        rangePresets: rangePresets4,
      );

      // Wait for the stream to resolve.
      await tester.pumpAndSettle();

      // The range passed to watchTimeline must equal the default preset.
      expect(fakeJournal.calls, isNotEmpty);
      expect(fakeJournal.calls.first['range'], equals(defaultPreset));
    },
  );

  // ─── ②a No isDefault → error state ─────────────────────────────────────
  //
  // When rangePresets contains no isDefault item the effective query provider
  // emits an error and the screen shows a retry button.

  testWidgets('②a No isDefault preset → error state (retry button visible)', (
    WidgetTester tester,
  ) async {
    // Build a presets list where none is the default.
    final List<DateRange> noDefault = rangePresets4
        .map(
          (DateRange r) => DateRange(
            from: r.from,
            to: r.to,
            presetCode: r.presetCode,
            label: r.label,
            isDefault: false,
          ),
        )
        .toList();

    await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      rangePresets: noDefault,
    );
    await tester.pumpAndSettle();

    // JournalTimeline shows error → retry button.
    expect(find.text(JournalLabels.retry), findsOneWidget);
  });

  // ─── ③ Filter sheet: status tap → watchTimeline arg (G4: real UI) ────────
  //
  // Open the filter sheet, tap the «상쇄됨» (REVERSED) status option, tap
  // 「적용」, and verify that the LAST watchTimeline call received the
  // chosen status.  This exercises the actual sheet UI rather than injecting
  // a query directly.

  testWidgets(
    '③ tap status in filter sheet → watchTimeline receives that status',
    (WidgetTester tester) async {
      final _FakeJournalRepository fakeJournal = await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        rangePresets: rangePresets4,
        filterCatalog: filterCatalog,
      );
      await tester.pumpAndSettle();

      // Open filter sheet.
      await tester.tap(find.text(JournalLabels.filter));
      await tester.pumpAndSettle();

      expect(find.text(JournalLabels.filterReset), findsOneWidget);

      // Pick a status option that is unlikely to appear in the timeline rows
      // (REVERSED = «상쇄됨»).
      final JournalStatusOption pick = filterCatalog.statusOptions.firstWhere(
        (JournalStatusOption o) => o.status == JournalStatus.reversed,
      );

      final Finder sheetScroll = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text(pick.label),
        120,
        scrollable: sheetScroll,
      );
      await tester.ensureVisible(find.text(pick.label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(pick.label));
      await tester.pumpAndSettle();

      // Tap 「적용」.
      await tester.scrollUntilVisible(
        find.text(JournalLabels.filterApply),
        120,
        scrollable: sheetScroll,
      );
      await tester.ensureVisible(find.text(JournalLabels.filterApply));
      await tester.pumpAndSettle();
      await tester.tap(find.text(JournalLabels.filterApply));
      await tester.pumpAndSettle();

      // Sheet is closed.
      expect(find.text(JournalLabels.filterApply), findsNothing);

      // The last watchTimeline call must have the picked status.
      expect(fakeJournal.calls.last['status'], equals(pick.status));
    },
  );

  // ─── ③a Reset → status/sleeve/symbol/origin null + range = default ───────
  // A15: start from a non-default range so that «revert to default» is observable.

  testWidgets(
    '③a filter reset → watchTimeline gets null filters and default range',
    (WidgetTester tester) async {
      // Start with a status filter and a non-default range pre-selected (A15).
      final JournalStatusOption pick = filterCatalog.statusOptions.firstWhere(
        (JournalStatusOption o) => o.status == JournalStatus.reversed,
      );
      final _FakeJournalRepository fakeJournal = await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        rangePresets: rangePresets4,
        filterCatalog: filterCatalog,
        query: JournalTimelineQuery(
          range: nonDefaultPreset,
          status: pick.status,
        ),
      );
      await tester.pumpAndSettle();

      // A15: precondition — initial call used non-default range.
      expect(fakeJournal.calls.first['range'], equals(nonDefaultPreset));

      // Open filter sheet.
      await tester.tap(find.text(JournalLabels.filter));
      await tester.pumpAndSettle();

      // Tap 「초기화」 — this resets and closes the sheet.
      final Finder sheetScroll = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text(JournalLabels.filterReset),
        120,
        scrollable: sheetScroll,
      );
      await tester.ensureVisible(find.text(JournalLabels.filterReset));
      await tester.pumpAndSettle();
      await tester.tap(find.text(JournalLabels.filterReset));
      await tester.pumpAndSettle();

      // Sheet closed.
      expect(find.text(JournalLabels.filterApply), findsNothing);

      // G1: after reset the StateProvider is null → effective query resolves
      // to isDefault preset.  Verify a new watchTimeline call went out with
      // null filters and the default range.
      expect(fakeJournal.calls.last['status'], isNull);
      expect(fakeJournal.calls.last['sleeve'], isNull);
      expect(fakeJournal.calls.last['symbol'], isNull);
      expect(fakeJournal.calls.last['origin'], isNull);
      expect(fakeJournal.calls.last['range'], equals(defaultPreset));
    },
  );

  // ─── ③b Active chip ✕ tap → that filter cleared; other filters preserved ─
  // A15: tapping ✕ on the status chip must clear only status — range, origin,
  // and rebalanceEventId must survive unchanged.

  testWidgets(
    '③b active status chip ✕ removes status; range/origin/rebalanceEventId kept',
    (WidgetTester tester) async {
      final JournalStatusOption pick = filterCatalog.statusOptions.firstWhere(
        (JournalStatusOption o) => o.status == JournalStatus.reversed,
      );

      final _FakeJournalRepository fakeJournal = await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        rangePresets: rangePresets4,
        filterCatalog: filterCatalog,
        query: JournalTimelineQuery(
          range: nonDefaultPreset,
          status: pick.status,
          origin: originPick.origin,
          rebalanceEventId: reId,
        ),
      );
      await tester.pumpAndSettle();

      // The active status chip must be visible.
      expect(find.text(pick.label), findsWidgets);

      // Tap the ✕ on the status chip — find.descendant ensures we get the ✕
      // that lives inside the chip labelled pick.label (not some other ✕).
      final Finder chipFinder = find.widgetWithText(Chip, pick.label);
      final Finder closeInsideChip = find.descendant(
        of: chipFinder,
        matching: find.byIcon(Icons.close),
      );
      expect(closeInsideChip, findsOneWidget);
      await tester.ensureVisible(closeInsideChip);
      await tester.tap(closeInsideChip);
      await tester.pumpAndSettle();

      // A15: status cleared; the other three preserved.
      expect(fakeJournal.calls.last['status'], isNull);
      expect(fakeJournal.calls.last['range'], equals(nonDefaultPreset));
      expect(fakeJournal.calls.last['origin'], equals(originPick.origin));
      expect(fakeJournal.calls.last['rebalanceEventId'], equals(reId));
    },
  );

  // ─── ③c Wire text never shown when catalog absent ─────────────────────────
  //
  // G2: if catalog is not loaded, active status/sleeve chips must NOT be
  // displayed — internal wire strings must not appear in the UI.

  testWidgets(
    '③c no catalog → status/sleeve/origin wire strings absent from screen',
    (WidgetTester tester) async {
      final JournalStatusOption pick = filterCatalog.statusOptions.firstWhere(
        (JournalStatusOption o) => o.status == JournalStatus.filled,
      );

      // Pump with status+sleeve+origin filters but NO filter catalog (Stream.empty).
      // A15: sleeve and origin wire must also be absent.
      await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        rangePresets: rangePresets4,
        // No filterCatalog supplied → _journalFilterCatalogProvider emits nothing.
        query: JournalTimelineQuery(
          range: defaultPreset,
          status: pick.status,
          sleeve: SleeveId.pot,
          origin: originPick.origin,
        ),
      );
      await tester.pumpAndSettle();

      // Wire strings must NOT appear.
      expect(find.text(JournalStatus.filled.wire), findsNothing);
      expect(find.text(SleeveId.pot.wire), findsNothing);
      expect(find.text(originPick.origin.wire), findsNothing);
    },
  );

  // ─── ④ Badge label and tap link ─────────────────────────────────────────

  // ─── ③d A14 — filter apply keeps rebalanceEventId from initial query ──────

  testWidgets('③d filter apply keeps rebalanceEventId from the initial query', (
    WidgetTester tester,
  ) async {
    final JournalStatusOption pick = filterCatalog.statusOptions.firstWhere(
      (JournalStatusOption o) => o.status == JournalStatus.reversed,
    );

    final _FakeJournalRepository fakeJournal = await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      rangePresets: rangePresets4,
      filterCatalog: filterCatalog,
      query: JournalTimelineQuery(range: defaultPreset, rebalanceEventId: reId),
    );
    await tester.pumpAndSettle();

    // Precondition: initial call carried rebalanceEventId.
    expect(fakeJournal.calls.first['rebalanceEventId'], equals(reId));

    // Open filter sheet.
    await tester.tap(find.text(JournalLabels.filter));
    await tester.pumpAndSettle();

    // Pick the same REVERSED status as ③.
    final Finder sheetScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text(pick.label),
      120,
      scrollable: sheetScroll,
    );
    await tester.ensureVisible(find.text(pick.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(pick.label));
    await tester.pumpAndSettle();

    // Tap 「적용」.
    await tester.scrollUntilVisible(
      find.text(JournalLabels.filterApply),
      120,
      scrollable: sheetScroll,
    );
    await tester.ensureVisible(find.text(JournalLabels.filterApply));
    await tester.pumpAndSettle();
    await tester.tap(find.text(JournalLabels.filterApply));
    await tester.pumpAndSettle();

    // Sheet closed.
    expect(find.text(JournalLabels.filterApply), findsNothing);

    // A14: rebalanceEventId must survive apply, and the chosen status is set.
    expect(fakeJournal.calls.last['status'], equals(pick.status));
    expect(fakeJournal.calls.last['rebalanceEventId'], equals(reId));
  });

  // ─── ③e A14 — filter reset clears rebalanceEventId ──────────────────────

  testWidgets('③e filter reset clears rebalanceEventId too', (
    WidgetTester tester,
  ) async {
    final _FakeJournalRepository fakeJournal = await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      rangePresets: rangePresets4,
      filterCatalog: filterCatalog,
      query: JournalTimelineQuery(
        range: nonDefaultPreset,
        rebalanceEventId: reId,
      ),
    );
    await tester.pumpAndSettle();

    // Preconditions.
    expect(fakeJournal.calls.first['rebalanceEventId'], equals(reId));
    expect(fakeJournal.calls.first['range'], equals(nonDefaultPreset));

    // Open filter sheet.
    await tester.tap(find.text(JournalLabels.filter));
    await tester.pumpAndSettle();

    // Tap 「초기화」.
    final Finder sheetScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text(JournalLabels.filterReset),
      120,
      scrollable: sheetScroll,
    );
    await tester.ensureVisible(find.text(JournalLabels.filterReset));
    await tester.pumpAndSettle();
    await tester.tap(find.text(JournalLabels.filterReset));
    await tester.pumpAndSettle();

    // A14: reset writes null to StateProvider → effective query resolves to
    // isDefault preset. rebalanceEventId must be null after reset.
    // _reset() is unchanged (A14 rule).
    expect(fakeJournal.calls.last['rebalanceEventId'], isNull);
    expect(fakeJournal.calls.last['range'], equals(defaultPreset));
  });

  // ─── ④ Badge label and tap link ─────────────────────────────────────────

  testWidgets('④ badge label is shown; tap fires deepLink', (
    WidgetTester tester,
  ) async {
    final List<JournalTimelineBadge> badges = listFixture(
      FixturePaths.m6JournalBadges2,
      JournalTimelineBadge.fromJson,
    ).rows;
    final JournalTimelineBadge badge = badges.first;

    final RecordingLinkOpener opener = RecordingLinkOpener();

    await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      badges: badges,
      linkOpener: opener,
      query: JournalTimelineQuery(range: defaultPreset),
      rangePresets: rangePresets4,
    );

    expect(find.text(badge.label), findsOneWidget);

    // Tap the badge chip.
    await tester.tap(find.text(badge.label));
    await tester.pump();

    // deepLink must be the fixture value — no literal.
    expect(opener.opened, <String>[badge.deepLink!]);
  });

  // ─── ⑤ Empty badge list → no badge row ──────────────────────────────────

  testWidgets('⑤ empty badge list → badge row absent', (
    WidgetTester tester,
  ) async {
    final List<JournalTimelineBadge> badges = listFixture(
      FixturePaths.m6JournalBadges2,
      JournalTimelineBadge.fromJson,
    ).rows;
    // Verify that with non-empty badges they appear.
    await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      badges: badges,
      query: JournalTimelineQuery(range: defaultPreset),
      rangePresets: rangePresets4,
    );
    expect(find.text(badges.first.label), findsOneWidget);

    // Now empty badges.
    await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      badges: const <JournalTimelineBadge>[],
      query: JournalTimelineQuery(range: defaultPreset),
      rangePresets: rangePresets4,
    );
    expect(find.text(badges.first.label), findsNothing);
  });

  // ─── ⑥ Row tap + chip tap ────────────────────────────────────────────────

  testWidgets(
    '⑥ row tap fires entry.detailDeepLink; chip tap fires chip.detailDeepLink',
    (WidgetTester tester) async {
      // Find an entry with a non-null detailDeepLink.
      final TradeJournalEntry? tappableEntry = journal30.rows
          .cast<TradeJournalEntry?>()
          .firstWhere(
            (TradeJournalEntry? e) => e?.detailDeepLink != null,
            orElse: () => null,
          );
      expect(
        tappableEntry,
        isNotNull,
        reason: 'journal_30 must have an entry with detailDeepLink',
      );

      final RecordingLinkOpener opener = RecordingLinkOpener();
      await _pump(
        tester,
        result: journal30,
        safety: _normalSafety(),
        linkOpener: opener,
        query: JournalTimelineQuery(range: defaultPreset),
        rangePresets: rangePresets4,
      );

      // Tap the symbol label of the tappable entry (inside its InkWell).
      await tester.tap(find.text(tappableEntry!.symbolLabel).first);
      await tester.pump();

      // Must equal fixture value — no literal.
      expect(opener.opened, contains(tappableEntry.detailDeepLink!));

      // A17: chip tap — find a reason chip with a detailDeepLink and tap it.
      final ReasonChip linkedChip = tappableEntry.reasons.firstWhere(
        (ReasonChip c) => c.detailDeepLink != null,
      );
      await tester.tap(
        find
            .descendant(
              of: find.byType(ActionChip),
              matching: find.text(linkedChip.label),
            )
            .first,
      );
      await tester.pump();

      // Row tap then chip tap: opened list has both links; chip tap does NOT
      // re-fire the row's link.
      expect(opener.opened, <String>[
        tappableEntry.detailDeepLink!,
        linkedChip.detailDeepLink!,
      ]);
    },
  );

  // ─── ⑦ clearDeepLink == null → no arrow (A16) ────────────────────────────
  // A16: use safetyFixtureRow(2) which has TIER_B_UNJUDGED (no clearDeepLink).
  // Replace silent return with expect so the fixture contract is pinned.

  testWidgets('⑦ BlockFlag with null clearDeepLink has no arrow button', (
    WidgetTester tester,
  ) async {
    // safety row 2 = REDUCED (TIER_B_UNJUDGED — no clearDeepLink).
    final SafetyState reduced = safetyFixtureRow(2);

    final List<BlockFlag> blockingFlags = reduced.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .take(2)
        .toList();

    final bool anyNullLink = blockingFlags.any(
      (BlockFlag f) => f.clearDeepLink == null,
    );
    // A16: precondition as expect — if fixture changes, test fails loudly.
    expect(
      anyNullLink,
      isTrue,
      reason:
          'safetyFixtureRow(2) must have at least one blocking flag without '
          'a clearDeepLink so that the «no arrow» rule is observable.',
    );

    await _pump(
      tester,
      result: journal30,
      safety: reduced,
      query: JournalTimelineQuery(range: defaultPreset),
      rangePresets: rangePresets4,
    );

    // The flag label must be visible.
    final BlockFlag nullLinkFlag = blockingFlags.firstWhere(
      (BlockFlag f) => f.clearDeepLink == null,
    );
    expect(find.text(nullLinkFlag.label), findsOneWidget);

    // No arrow icon because clearDeepLink is null.
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
  });

  // ─── ⑦b BlockFlag with clearDeepLink shows arrow; tap opens link (A16) ───

  testWidgets(
    '⑦b BlockFlag with clearDeepLink shows arrow; tap opens that link',
    (WidgetTester tester) async {
      // safety row 3 = HALTED (RECON_MISMATCH + JOURNAL_MISSING).
      final SafetyState halted = safetyFixtureRow(3);
      final RecordingLinkOpener opener = RecordingLinkOpener();

      final List<String> links = halted.activeFlags
          .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
          .take(2)
          .map((BlockFlag f) => f.clearDeepLink)
          .whereType<String>()
          .toList();

      expect(
        links.length,
        2,
        reason:
            'safetyFixtureRow(3) must have exactly 2 blocking flags '
            'with non-null clearDeepLink.',
      );

      await _pump(
        tester,
        result: journal30,
        safety: halted,
        linkOpener: opener,
        query: JournalTimelineQuery(range: defaultPreset),
        rangePresets: rangePresets4,
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(2));

      // Tap the first arrow.
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      await tester.pump();

      expect(opener.opened, <String>[links.first]);
    },
  );

  // ─── ⑧ checkpointLabel displayed (A16) ───────────────────────────────────
  // A16: replace silent return with expect so the fixture contract is pinned.

  testWidgets('⑧ checkpointLabel is shown when non-null', (
    WidgetTester tester,
  ) async {
    // safety row 4 = STOPPED (LEDGER_INTEGRITY) which should have checkpointLabel.
    final SafetyState stopped = safetyFixtureRow(4);

    final BlockFlag? integrityFlag = stopped.activeFlags
        .cast<BlockFlag?>()
        .firstWhere(
          (BlockFlag? f) => f?.flagId == FlagIds.ledgerIntegrity,
          orElse: () => null,
        );

    // A16: precondition as expect — if fixture changes, test fails loudly.
    expect(
      integrityFlag?.checkpointLabel,
      isNotNull,
      reason:
          'safetyFixtureRow(4) must have a LEDGER_INTEGRITY flag with a '
          'non-null checkpointLabel so that the checkpoint label rule can be '
          'verified.',
    );

    await _pump(
      tester,
      result: journal30,
      safety: stopped,
      query: JournalTimelineQuery(range: defaultPreset),
      rangePresets: rangePresets4,
    );

    expect(find.text(integrityFlag!.checkpointLabel!), findsOneWidget);
  });
}
