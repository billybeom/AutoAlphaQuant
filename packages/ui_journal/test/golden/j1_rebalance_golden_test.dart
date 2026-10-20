// j1_rebalance_golden_test.dart - J-1 rebalance chip goldens (contract v1.5 - S-12).
//
// j1_rebalance_chip    : JournalTimeline(rebalanceEventId: reId) + scope_1 + the
//                        journal_30 rows of that rebalance.
// j1_rebalance_unknown : unknown rebalance + scope null + journal_rebalance_unknown.
// Each name x light/dark = 4 PNG. Size = kGoldenPhoneSize (390x844).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

class _GoldenRepo extends UnimplementedJournalRepository {
  _GoldenRepo(this._timeline, this._scope);

  final ListResult<TradeJournalEntry> _timeline;
  final JournalRebalanceScope? _scope;

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
  }) => Stream<ListResult<TradeJournalEntry>>.value(_timeline);

  @override
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) =>
      Stream<JournalRebalanceScope?>.value(_scope);

  @override
  Stream<JournalFilterCatalog> watchFilterCatalog() =>
      const Stream<JournalFilterCatalog>.empty();

  @override
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  }) => Stream<List<JournalTimelineBadge>>.value(<JournalTimelineBadge>[]);
}

class _GoldenSafety extends UnimplementedSafetyRepository {
  _GoldenSafety(this._state);

  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

class _GoldenConfig extends UnimplementedConfigRepository {
  _GoldenConfig(this._presets, this._sleeves);

  final List<DateRange> _presets;
  final List<SleeveCatalogEntry> _sleeves;

  @override
  Stream<List<DateRange>> watchRangePresets() =>
      Stream<List<DateRange>>.value(_presets);

  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() =>
      Stream<List<SleeveCatalogEntry>>.value(_sleeves);
}

void main() {
  final JournalRebalanceScope scope = singleFixture(
    FixturePaths.m6JournalRebalanceScope1,
    JournalRebalanceScope.fromJson,
  );
  final String reId = scope.rebalanceEventId;
  final ListResult<TradeJournalEntry> journal30 = journalFixture(
    FixturePaths.journal30,
  );
  final ListResult<TradeJournalEntry> reRows = journalSlice(
    journal30,
    (TradeJournalEntry e) => e.rebalanceEventId == reId,
  );
  final ListResult<TradeJournalEntry> unknown = journalFixture(
    FixturePaths.m6JournalRebalanceUnknown,
  );
  final List<DateRange> presets = listFixture(
    FixturePaths.rangePresets4,
    DateRange.fromJson,
  ).rows;
  final List<SleeveCatalogEntry> sleeves = listFixture(
    FixturePaths.sleeveCatalog4,
    SleeveCatalogEntry.fromJson,
  ).rows;
  final DateRange defaultPreset = presets
      .where((DateRange r) => r.isDefault)
      .single;
  final SafetyState normal = safetyFixtureRow(0);

  // (name, timeline, scope)
  final List<(String, ListResult<TradeJournalEntry>, JournalRebalanceScope?)>
  cases = <(String, ListResult<TradeJournalEntry>, JournalRebalanceScope?)>[
    ('j1_rebalance_chip', reRows, scope),
    ('j1_rebalance_unknown', unknown, null),
  ];

  for (final Brightness b in Brightness.values) {
    for (final (
          String name,
          ListResult<TradeJournalEntry> timeline,
          JournalRebalanceScope? known,
        )
        in cases) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        expect(reRows.rows, isNotEmpty);
        expect(unknown.emptyLabel, isNotNull);
        await pumpForGolden(
          tester,
          JournalTimeline(rebalanceEventId: reId),
          brightness: b,
          wrapApp: (Widget app) => ProviderScope(
            overrides: <Override>[
              journalTimelineRepositoryProvider.overrideWithValue(
                _GoldenRepo(timeline, known),
              ),
              journalSafetyRepositoryProvider.overrideWithValue(
                _GoldenSafety(normal),
              ),
              journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
              journalConfigRepositoryProvider.overrideWithValue(
                _GoldenConfig(presets, sleeves),
              ),
            ],
            child: app,
          ),
        );
        await tester.pumpAndSettle();

        final Finder bottom = known == null
            ? find.text(unknown.emptyLabel!)
            : find.byKey(const Key('j1-chip-rebalance'));
        expect(bottom, findsOneWidget);
        await Scrollable.ensureVisible(
          tester.element(bottom),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
        await tester.pumpAndSettle();

        // Position precondition: bottom widget inside the phone frame.
        final Finder rangeChip = find.text(
          known == null ? defaultPreset.label! : scope.range.label!,
        );
        expect(rangeChip, findsOneWidget);
        expect(
          tester.getBottomLeft(rangeChip).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(
          tester.getBottomRight(bottom).dx,
          lessThanOrEqualTo(kGoldenPhoneSize.width),
        );
        expect(
          tester.getBottomLeft(bottom).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        await expectGolden(name, b);
      });
    }
  }
}
