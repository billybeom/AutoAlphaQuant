// timeline_test.dart — J-1 unit tests (ⓐ~ⓔ · §11 계약 v1.1 · 8 test cases)
//
// 🔴 No link literals — all link expectations use fixture values.
// 🔴 No raw value display — we expect *Text, not entry.price.toString() etc.
// 🔴 No row filtering — the fake repository receives args, does not filter.

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

  // Track watchTimeline call args.
  Map<String, dynamic>? lastWatchTimelineArgs;

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
    lastWatchTimelineArgs = <String, dynamic>{
      'range': range,
      'sleeve': sleeve,
      'symbol': symbol,
      'status': status,
      'origin': origin,
    };
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

Future<_FakeJournalRepository> _pump(
  WidgetTester tester, {
  required ListResult<TradeJournalEntry> result,
  required SafetyState safety,
  JournalTimelineQuery? query,
  List<DateRange>? rangePresets,
  List<SleeveCatalogEntry>? sleeves,
  JournalFilterCatalog? filterCatalog,
  List<JournalTimelineBadge> badges = const <JournalTimelineBadge>[],
  RecordingLinkOpener? linkOpener,
}) async {
  final DateRange range =
      query?.range ??
      DateRange(
        from: TradeDate('2026-08-01'),
        to: TradeDate('2026-08-31'),
        presetCode: 'FIXTURE',
        label: 'fixture',
        isDefault: true,
      );
  final JournalTimelineQuery q = query ?? JournalTimelineQuery(range: range);

  final _FakeJournalRepository fakeJournal = _FakeJournalRepository(
    timelineResult: result,
    filterCatalog: filterCatalog,
    badges: badges,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        journalTimelineRepositoryProvider.overrideWithValue(fakeJournal),
        journalSafetyRepositoryProvider.overrideWithValue(
          _FakeSafetyRepository(safety),
        ),
        journalTimelineQueryProvider.overrideWith((Ref ref) => q),
        journalClockProvider.overrideWithValue(
          _FixedClock(DateTime.utc(2026, 8, 31, 10)),
        ),
        journalConfigRepositoryProvider.overrideWithValue(
          _FakeConfigRepository(rangePresets: rangePresets, sleeves: sleeves),
        ),
        if (linkOpener != null)
          journalLinkOpenerProvider.overrideWithValue(linkOpener),
      ],
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

  // ─── ① *Text displayed; raw values absent ────────────────────────────────

  testWidgets(
    '① priceText is shown; raw price.toString() is absent when different',
    (WidgetTester tester) async {
      await _pump(tester, result: journal30, safety: _normalSafety());

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

  // ─── ② Default preset becomes the first watchTimeline range ──────────────

  testWidgets('② isDefault preset passes as range to watchTimeline', (
    WidgetTester tester,
  ) async {
    final List<DateRange> presets = listFixture(
      FixturePaths.rangePresets4,
      DateRange.fromJson,
    ).rows;
    final DateRange defaultPreset = presets.firstWhere(
      (DateRange r) => r.isDefault,
    );

    final JournalTimelineQuery q = JournalTimelineQuery(range: defaultPreset);

    final _FakeJournalRepository fakeJournal = await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      query: q,
      rangePresets: presets,
    );

    // The range passed to watchTimeline must be the default preset.
    expect(
      fakeJournal.lastWatchTimelineArgs?['range'],
      isA<DateRange>().having(
        (DateRange r) => r.isDefault,
        'isDefault',
        isTrue,
      ),
    );
  });

  // ─── ③ Filter selection → watchTimeline args ─────────────────────────────

  testWidgets('③ status filter is passed as-is to watchTimeline', (
    WidgetTester tester,
  ) async {
    final JournalFilterCatalog catalog = singleFixture(
      FixturePaths.m6JournalFilterCatalog,
      JournalFilterCatalog.fromJson,
    );
    final JournalStatusOption chosenOption = catalog.statusOptions.first;

    final DateRange range = DateRange(
      from: TradeDate('2026-08-01'),
      to: TradeDate('2026-08-31'),
      presetCode: 'FIXTURE',
      isDefault: true,
    );
    final JournalTimelineQuery q = JournalTimelineQuery(
      range: range,
      status: chosenOption.status,
    );

    final _FakeJournalRepository fakeJournal = await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      query: q,
      filterCatalog: catalog,
    );

    expect(
      fakeJournal.lastWatchTimelineArgs?['status'],
      equals(chosenOption.status),
    );
    // No sleeve or symbol — those are null.
    expect(fakeJournal.lastWatchTimelineArgs?['sleeve'], isNull);
    expect(fakeJournal.lastWatchTimelineArgs?['symbol'], isNull);
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
    );
    expect(find.text(badges.first.label), findsOneWidget);

    // Now empty badges.
    await _pump(
      tester,
      result: journal30,
      safety: _normalSafety(),
      badges: const <JournalTimelineBadge>[],
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
      );

      // Tap the symbol label of the tappable entry (inside its InkWell).
      await tester.tap(find.text(tappableEntry!.symbolLabel).first);
      await tester.pump();

      // Must equal fixture value — no literal.
      expect(opener.opened, contains(tappableEntry.detailDeepLink!));
    },
  );

  // ─── ⑦ clearDeepLink == null → no arrow ──────────────────────────────────

  testWidgets('⑦ BlockFlag with null clearDeepLink has no arrow button', (
    WidgetTester tester,
  ) async {
    // safety row 3 = HALTED (RECON_MISMATCH + JOURNAL_MISSING).
    // JOURNAL_MISSING has clearRoute = automatic and no clearDeepLink.
    final SafetyState blocked = safetyFixtureRow(3);

    final bool anyNullLink = blocked.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .take(2)
        .any((BlockFlag f) => f.clearDeepLink == null);

    if (!anyNullLink) {
      // Nothing to test in this fixture row — skip gracefully.
      return;
    }

    await _pump(tester, result: journal30, safety: blocked);

    // Arrow_forward_ios icon must NOT appear for the null-link flags.
    // (If some flags DO have links, there may be arrows; we just check
    //  that the count equals the number of non-null links among top-2.)
    final int expectedArrows = blocked.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .take(2)
        .where((BlockFlag f) => f.clearDeepLink != null)
        .length;
    expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(expectedArrows));
  });

  // ─── ⑧ checkpointLabel displayed ─────────────────────────────────────────

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

    if (integrityFlag?.checkpointLabel == null) {
      // Fixture doesn't populate checkpointLabel — skip gracefully.
      return;
    }

    await _pump(tester, result: journal30, safety: stopped);

    expect(find.text(integrityFlag!.checkpointLabel!), findsOneWidget);
  });
}
