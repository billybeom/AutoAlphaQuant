// j1_golden_test.dart — J-1 위젯 골든 (계약 v1.1 · R1b)
//
// 기존 4종 재생성: 표시가 *Text 로 전환됐으므로 이 PR에서 다시 찍습니다
//   (M2 승인 — PR 본문에 「계약 v1.1 표시 전환으로 재생성」 명시).
// 신규 3종: j1_masked_integrity · j1_badges · j1_filter_open × light/dark.
//
// 🔴 픽스처를 고치지 않는다. 가짜 리포지토리는 받침대를 상속한다.
// 🔴 link literal 없음. 시계는 FixedClock 으로 주입.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

/// Journal repository that serves a fixed timeline result and optionally
/// serves filter catalog / badges from fixtures.
class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository(
    this._result, {
    this.filterCatalog,
    this.badges = const <JournalTimelineBadge>[],
  });

  final ListResult<TradeJournalEntry> _result;
  final JournalFilterCatalog? filterCatalog;
  final List<JournalTimelineBadge> badges;

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
  }) => Stream<ListResult<TradeJournalEntry>>.value(_result);

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
  _FakeSafetyRepository(this._state);
  final SafetyState _state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
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

// ── Fixture helpers ───────────────────────────────────────────────────────────

DateRange _fixtureRange() => DateRange(
  from: TradeDate('2026-08-01'),
  to: TradeDate('2026-08-31'),
  presetCode: 'FIXTURE',
  isDefault: true,
);

// ── Golden pump helper ────────────────────────────────────────────────────────

Future<void> _pumpGolden(
  WidgetTester tester, {
  required ListResult<TradeJournalEntry> result,
  required SafetyState safety,
  required Brightness brightness,
  JournalFilterCatalog? filterCatalog,
  List<JournalTimelineBadge> badges = const <JournalTimelineBadge>[],
  List<DateRange>? rangePresets,
  List<SleeveCatalogEntry>? sleeves,
  DateRange? range,
}) async {
  final DateRange r = range ?? _fixtureRange();
  await pumpForGolden(
    tester,
    ProviderScope(
      overrides: <Override>[
        journalTimelineRepositoryProvider.overrideWithValue(
          _FakeJournalRepository(
            result,
            filterCatalog: filterCatalog,
            badges: badges,
          ),
        ),
        journalSafetyRepositoryProvider.overrideWithValue(
          _FakeSafetyRepository(safety),
        ),
        journalTimelineQueryProvider.overrideWith(
          (Ref ref) => JournalTimelineQuery(range: r),
        ),
        journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
        journalConfigRepositoryProvider.overrideWithValue(
          _FakeConfigRepository(rangePresets: rangePresets, sleeves: sleeves),
        ),
        // No AppLinkOpener — goldens do not test navigation.
      ],
      child: const JournalTimeline(),
    ),
    brightness: brightness,
  );
}

// ── Main ──────────────────────────────────────────────────────────────────────

void main() {
  // ── Fixtures ──────────────────────────────────────────────────────────────

  final ListResult<TradeJournalEntry> all = journalFixture(
    FixturePaths.journal30,
  );
  final ListResult<TradeJournalEntry> empty = journalFixture(
    FixturePaths.m6JournalEmpty,
  );
  final ListResult<TradeJournalEntry> prevented = journalSlice(
    all,
    (TradeJournalEntry e) => e.status == JournalStatus.prevented,
  );
  // Masked-integrity fixture (j1_masked_integrity).
  final ListResult<TradeJournalEntry> masked = journalFixture(
    FixturePaths.m6JournalMaskedIntegrity,
  );

  final SafetyState normal = safetyFixtureRow(0);
  final SafetyState blocked = safetyFixtureRow(3);
  final SafetyState stopped = safetyFixtureRow(4); // LEDGER_INTEGRITY

  // Badges fixture (j1_badges).
  final List<JournalTimelineBadge> badges = listFixture(
    FixturePaths.m6JournalBadges2,
    JournalTimelineBadge.fromJson,
  ).rows;

  // Filter catalog + range/sleeve for j1_filter_open.
  final JournalFilterCatalog filterCatalog = singleFixture(
    FixturePaths.m6JournalFilterCatalog,
    JournalFilterCatalog.fromJson,
  );
  final List<DateRange> rangePresets = listFixture(
    FixturePaths.rangePresets4,
    DateRange.fromJson,
  ).rows;
  final List<SleeveCatalogEntry> sleeves = listFixture(
    FixturePaths.sleeveCatalog4,
    SleeveCatalogEntry.fromJson,
  ).rows;
  final DateRange defaultRange = rangePresets.firstWhere(
    (DateRange r) => r.isDefault,
  );

  // ── Existing 4 goldens — re-generated (계약 v1.1 표시 전환으로 재생성) ───

  final Map<String, (ListResult<TradeJournalEntry>, SafetyState)>
  existingCases = <String, (ListResult<TradeJournalEntry>, SafetyState)>{
    'j1_normal': (all, normal),
    'j1_blocked': (all, blocked),
    'j1_empty': (empty, normal),
    'j1_prevented': (prevented, normal),
  };

  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, (ListResult<TradeJournalEntry>, SafetyState)> c
        in existingCases.entries) {
      testWidgets('${c.key} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await _pumpGolden(
          tester,
          result: c.value.$1,
          safety: c.value.$2,
          brightness: b,
          rangePresets: rangePresets,
          sleeves: sleeves,
        );
        await expectGolden(c.key, b);
      });
    }
  }

  // ── New golden: j1_masked_integrity ────────────────────────────────────────
  // masked_integrity fixture + safety row 4 (LEDGER_INTEGRITY).

  for (final Brightness b in Brightness.values) {
    testWidgets('j1_masked_integrity ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      await _pumpGolden(
        tester,
        result: masked,
        safety: stopped,
        brightness: b,
        rangePresets: rangePresets,
        sleeves: sleeves,
      );
      await expectGolden('j1_masked_integrity', b);
    });
  }

  // ── New golden: j1_badges ──────────────────────────────────────────────────
  // journal_30 + 2 badges.

  for (final Brightness b in Brightness.values) {
    testWidgets('j1_badges ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      await _pumpGolden(
        tester,
        result: all,
        safety: normal,
        brightness: b,
        badges: badges,
        rangePresets: rangePresets,
        sleeves: sleeves,
      );
      await expectGolden('j1_badges', b);
    });
  }

  // ── New golden: j1_filter_open ─────────────────────────────────────────────
  // Filter bottom sheet open state — we render with a status filter active
  // so the active chip is visible.

  for (final Brightness b in Brightness.values) {
    testWidgets('j1_filter_open ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final JournalStatusOption chosenStatus =
          filterCatalog.statusOptions.first;
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            journalTimelineRepositoryProvider.overrideWithValue(
              _FakeJournalRepository(all, filterCatalog: filterCatalog),
            ),
            journalSafetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(normal),
            ),
            journalTimelineQueryProvider.overrideWith(
              (Ref ref) => JournalTimelineQuery(
                range: defaultRange,
                status: chosenStatus.status,
              ),
            ),
            journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            journalConfigRepositoryProvider.overrideWithValue(
              _FakeConfigRepository(
                rangePresets: rangePresets,
                sleeves: sleeves,
              ),
            ),
          ],
          child: const JournalTimeline(),
        ),
        brightness: b,
      );
      await expectGolden('j1_filter_open', b);
    });
  }
}
