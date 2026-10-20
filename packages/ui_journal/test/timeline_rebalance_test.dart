// timeline_rebalance_test.dart - J-1 rebalance chip (contract v1.5 - S-12).
//
// T1-3f ~ T1-3o: constructor seed, rebalance chip, chip close, reset, entry
// isolation, pending / error scope. Own fakes extend the testing.dart bases.
// No fixture is edited; expected text comes from fixtures.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// -- Fakes ------------------------------------------------------------------

class _Call {
  const _Call({
    required this.range,
    required this.sleeve,
    required this.symbol,
    required this.status,
    required this.origin,
    required this.rebalanceEventId,
  });

  final DateRange range;
  final SleeveId? sleeve;
  final String? symbol;
  final JournalStatus? status;
  final FillOrigin? origin;
  final String? rebalanceEventId;
}

class _RebalanceRepo extends UnimplementedJournalRepository {
  _RebalanceRepo({
    required this.timeline,
    required this.catalog,
    required this.scopeFor,
  });

  final ListResult<TradeJournalEntry> timeline;
  final JournalFilterCatalog catalog;
  final Stream<JournalRebalanceScope?> Function(String id) scopeFor;

  final List<_Call> calls = <_Call>[];
  final List<String> scopeCalls = <String>[];

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
    calls.add(
      _Call(
        range: range,
        sleeve: sleeve,
        symbol: symbol,
        status: status,
        origin: origin,
        rebalanceEventId: rebalanceEventId,
      ),
    );
    return Stream<ListResult<TradeJournalEntry>>.value(timeline);
  }

  @override
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) {
    scopeCalls.add(rebalanceEventId);
    return scopeFor(rebalanceEventId);
  }

  @override
  Stream<JournalFilterCatalog> watchFilterCatalog() =>
      Stream<JournalFilterCatalog>.value(catalog);

  @override
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  }) => Stream<List<JournalTimelineBadge>>.value(<JournalTimelineBadge>[]);
}

class _RebalanceSafety extends UnimplementedSafetyRepository {
  _RebalanceSafety(this._state);

  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

class _RebalanceConfig extends UnimplementedConfigRepository {
  _RebalanceConfig(this._presets, this._sleeves, this._presetsStream);

  final List<DateRange> _presets;
  final List<SleeveCatalogEntry> _sleeves;
  final Stream<List<DateRange>> Function()? _presetsStream;

  @override
  Stream<List<DateRange>> watchRangePresets() =>
      _presetsStream?.call() ?? Stream<List<DateRange>>.value(_presets);

  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() =>
      Stream<List<SleeveCatalogEntry>>.value(_sleeves);
}

// -- Helpers ----------------------------------------------------------------

const Key _chipKey = Key('j1-chip-rebalance');

List<Override> _overrides(
  _RebalanceRepo repo,
  List<DateRange> presets,
  List<SleeveCatalogEntry> sleeves, {
  JournalTimelineQuery? query,
  Stream<List<DateRange>> Function()? presetsStream,
}) => <Override>[
  journalTimelineRepositoryProvider.overrideWithValue(repo),
  journalSafetyRepositoryProvider.overrideWithValue(
    _RebalanceSafety(safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
  journalConfigRepositoryProvider.overrideWithValue(
    _RebalanceConfig(presets, sleeves, presetsStream),
  ),
  ?(query == null
      ? null
      : journalTimelineQueryProvider.overrideWith((Ref ref) => query)),
];

Future<void> _pumpApp(
  WidgetTester tester,
  List<Override> overrides,
  Widget home,
) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: Scaffold(body: home)),
    ),
  );
  await tester.pump();
}

/// Opens the filter sheet, picks [label] and taps apply.
Future<void> _applyOption(WidgetTester tester, String label) async {
  await tester.tap(find.text(JournalLabels.filter));
  await tester.pumpAndSettle();
  final Finder sheetScroll = find.byType(Scrollable).last;
  await tester.scrollUntilVisible(
    find.text(label),
    120,
    scrollable: sheetScroll,
  );
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text(JournalLabels.filterApply),
    120,
    scrollable: sheetScroll,
  );
  await tester.ensureVisible(find.text(JournalLabels.filterApply));
  await tester.pumpAndSettle();
  await tester.tap(find.text(JournalLabels.filterApply));
  await tester.pumpAndSettle();
}

Future<void> _tapChipClose(WidgetTester tester) async {
  final Finder close = find.descendant(
    of: find.byKey(_chipKey),
    matching: find.byIcon(Icons.close),
  );
  expect(close, findsOneWidget);
  await tester.ensureVisible(close);
  await tester.pumpAndSettle();
  await tester.tap(close);
  await tester.pumpAndSettle();
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
  final JournalFilterCatalog catalog = singleFixture(
    FixturePaths.m6JournalFilterCatalog,
    JournalFilterCatalog.fromJson,
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

  _RebalanceRepo repoWith(
    Stream<JournalRebalanceScope?> Function(String id) scopeFor, {
    ListResult<TradeJournalEntry>? timeline,
  }) => _RebalanceRepo(
    timeline: timeline ?? reRows,
    catalog: catalog,
    scopeFor: scopeFor,
  );

  Stream<JournalRebalanceScope?> knownScope(String id) =>
      Stream<JournalRebalanceScope?>.value(id == reId ? scope : null);

  Stream<JournalRebalanceScope?> noScope(String id) =>
      Stream<JournalRebalanceScope?>.value(null);

  testWidgets('T1-3f constructor seeds range and chip', (
    WidgetTester tester,
  ) async {
    expect(reRows.rows, isNotEmpty);
    expect(scope.range.label, isNotNull);
    final _RebalanceRepo repo = repoWith(knownScope);
    await _pumpApp(
      tester,
      _overrides(repo, presets, sleeves),
      JournalTimeline(rebalanceEventId: reId),
    );
    await tester.pumpAndSettle();

    expect(repo.calls, isNotEmpty);
    final _Call first = repo.calls.first;
    expect(first.rebalanceEventId, reId);
    expect(first.range, scope.range);
    expect(first.sleeve, isNull);
    expect(first.symbol, isNull);
    expect(first.status, isNull);
    expect(first.origin, isNull);
    expect(repo.scopeCalls, <String>[reId]);

    expect(find.byKey(_chipKey), findsOneWidget);
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(_chipKey),
              matching: find.byType(Text),
            ),
          )
          .data,
      scope.label,
    );
    expect(find.text(scope.range.label!), findsOneWidget);
    expect(find.byType(JournalEntryCard), findsNWidgets(reRows.rows.length));
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3g reset clears rebalance', (WidgetTester tester) async {
    final StreamController<List<DateRange>> presetsCtrl =
        StreamController<List<DateRange>>();
    final StreamController<JournalRebalanceScope?> scopeCtrl =
        StreamController<JournalRebalanceScope?>.broadcast();
    addTearDown(() {
      unawaited(presetsCtrl.close());
      unawaited(scopeCtrl.close());
    });
    final _RebalanceRepo repo = repoWith((String id) => scopeCtrl.stream);
    await _pumpApp(
      tester,
      _overrides(
        repo,
        presets,
        sleeves,
        presetsStream: () => presetsCtrl.stream,
      ),
      JournalTimeline(rebalanceEventId: reId),
    );
    expect(repo.calls, isEmpty);
    presetsCtrl.add(presets);
    scopeCtrl.add(scope);
    await tester.pumpAndSettle();
    expect(repo.calls.first.rebalanceEventId, reId);
    expect(find.byKey(_chipKey), findsOneWidget);

    await tester.tap(find.text(JournalLabels.filter));
    await tester.pumpAndSettle();
    await tester.tap(find.text(JournalLabels.filterReset));
    await tester.pumpAndSettle();

    final int afterReset = repo.calls.length;
    expect(repo.calls.last.rebalanceEventId, isNull);
    expect(repo.calls.last.range, defaultPreset);
    expect(find.byKey(_chipKey), findsNothing);

    presetsCtrl.add(presets);
    scopeCtrl.add(scope);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    for (int i = afterReset - 1; i < repo.calls.length; i++) {
      expect(repo.calls[i].rebalanceEventId, isNull);
    }
    expect(repo.calls.last.range, defaultPreset);
    expect(find.byKey(_chipKey), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3h chip close keeps other axes', (WidgetTester tester) async {
    expect(catalog.statusOptions, isNotEmpty);
    final JournalStatusOption pick = catalog.statusOptions
        .where((JournalStatusOption o) => o.status == JournalStatus.reversed)
        .single;
    final _RebalanceRepo repo = repoWith(knownScope);
    await _pumpApp(
      tester,
      _overrides(repo, presets, sleeves),
      JournalTimeline(rebalanceEventId: reId),
    );
    await tester.pumpAndSettle();
    await _applyOption(tester, pick.label);

    expect(repo.calls.last.status, pick.status);
    expect(repo.calls.last.rebalanceEventId, reId);
    expect(repo.calls.last.range, scope.range);
    expect(find.byKey(_chipKey), findsOneWidget);

    await _tapChipClose(tester);

    expect(repo.calls.last.rebalanceEventId, isNull);
    expect(repo.calls.last.status, pick.status);
    expect(repo.calls.last.range, scope.range);
    expect(repo.calls.last.origin, isNull);
    expect(find.byKey(_chipKey), findsNothing);
    expect(find.text(scope.range.label!), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3i unknown scope has no chip and keeps the envelope', (
    WidgetTester tester,
  ) async {
    expect(unknown.rows, isEmpty);
    expect(unknown.emptyLabel, isNotNull);
    final _RebalanceRepo repo = repoWith(noScope, timeline: unknown);
    await _pumpApp(
      tester,
      _overrides(repo, presets, sleeves),
      JournalTimeline(rebalanceEventId: reId),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(_chipKey), findsNothing);
    expect(find.textContaining(reId), findsNothing);
    expect(repo.calls.first.rebalanceEventId, reId);
    expect(repo.calls.first.range, defaultPreset);
    expect(find.text(unknown.emptyLabel!), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3j no argument never subscribes to the scope', (
    WidgetTester tester,
  ) async {
    final _RebalanceRepo repo = repoWith(knownScope);
    await _pumpApp(
      tester,
      _overrides(repo, presets, sleeves),
      const JournalTimeline(),
    );
    await tester.pumpAndSettle();

    expect(repo.calls, isNotEmpty);
    expect(repo.calls.first.rebalanceEventId, isNull);
    expect(repo.scopeCalls, isEmpty);
    expect(find.byKey(_chipKey), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3k entry B starts from its own seed after entry A', (
    WidgetTester tester,
  ) async {
    const String otherId = 're_test_unknown';
    final _RebalanceRepo repo = repoWith(knownScope);
    final List<Override> overrides = _overrides(repo, presets, sleeves);
    await _pumpApp(
      tester,
      overrides,
      JournalTimeline(key: ValueKey<String>(reId), rebalanceEventId: reId),
    );
    await tester.pumpAndSettle();
    expect(repo.calls.first.rebalanceEventId, reId);

    await _tapChipClose(tester);
    expect(repo.calls.last.rebalanceEventId, isNull);

    final int before = repo.calls.length;
    await _pumpApp(
      tester,
      overrides,
      JournalTimeline(
        key: const ValueKey<String>(otherId),
        rebalanceEventId: otherId,
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.calls.length, greaterThan(before));
    expect(repo.calls[before].rebalanceEventId, otherId);
    expect(repo.calls[before].range, defaultPreset);
    expect(find.byKey(_chipKey), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3l no argument entry after a rebalance entry is clean', (
    WidgetTester tester,
  ) async {
    final _RebalanceRepo repo = repoWith(knownScope);
    final List<Override> overrides = _overrides(repo, presets, sleeves);
    await _pumpApp(tester, overrides, JournalTimeline(rebalanceEventId: reId));
    await tester.pumpAndSettle();
    expect(repo.calls.first.rebalanceEventId, reId);
    expect(find.byKey(_chipKey), findsOneWidget);

    final int before = repo.calls.length;
    await _pumpApp(tester, overrides, const JournalTimeline());
    await tester.pumpAndSettle();

    expect(repo.calls.length, greaterThan(before));
    expect(repo.calls[before].rebalanceEventId, isNull);
    expect(find.byKey(_chipKey), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T1-3m a filter chosen without argument does not hide the seed', (
    WidgetTester tester,
  ) async {
    expect(catalog.statusOptions, isNotEmpty);
    final JournalStatusOption pick = catalog.statusOptions
        .where((JournalStatusOption o) => o.status == JournalStatus.reversed)
        .single;
    final _RebalanceRepo repo = repoWith(knownScope);
    final List<Override> overrides = _overrides(repo, presets, sleeves);
    await _pumpApp(tester, overrides, const JournalTimeline());
    await tester.pumpAndSettle();
    await _applyOption(tester, pick.label);
    expect(repo.calls.last.status, pick.status);

    final int before = repo.calls.length;
    await _pumpApp(tester, overrides, JournalTimeline(rebalanceEventId: reId));
    await tester.pumpAndSettle();

    expect(repo.calls.length, greaterThan(before));
    expect(repo.calls[before].status, isNull);
    expect(repo.calls[before].rebalanceEventId, reId);
    expect(repo.calls[before].range, scope.range);
    expect(find.byKey(_chipKey), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  for (final (String caseName, bool useOverride) in <(String, bool)>[
    ('constructor', false),
    ('override', true),
  ]) {
    testWidgets('T1-3n scope pending shows loading, then seed $caseName', (
      WidgetTester tester,
    ) async {
      final StreamController<JournalRebalanceScope?> scopeCtrl =
          StreamController<JournalRebalanceScope?>();
      addTearDown(() {
        unawaited(scopeCtrl.close());
      });
      final _RebalanceRepo repo = repoWith((String id) => scopeCtrl.stream);
      await _pumpApp(
        tester,
        _overrides(
          repo,
          presets,
          sleeves,
          query: useOverride
              ? JournalTimelineQuery(range: scope.range, rebalanceEventId: reId)
              : null,
        ),
        useOverride
            ? const JournalTimeline()
            : JournalTimeline(rebalanceEventId: reId),
      );
      await tester.pump();

      expect(repo.scopeCalls, <String>[reId]);
      expect(repo.calls, isEmpty);
      expect(find.byType(JournalSkeleton), findsOneWidget);
      expect(find.byType(JournalEntryCard), findsNothing);
      expect(find.byKey(_chipKey), findsNothing);

      scopeCtrl.add(scope);
      await tester.pumpAndSettle();

      expect(repo.calls.first.rebalanceEventId, reId);
      expect(repo.calls.first.range, scope.range);
      expect(repo.calls.first.status, isNull);
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(_chipKey),
                matching: find.byType(Text),
              ),
            )
            .data,
        scope.label,
      );
      expect(find.byType(JournalEntryCard), findsNWidgets(reRows.rows.length));
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  for (final (String caseName, bool useOverride) in <(String, bool)>[
    ('constructor', false),
    ('override', true),
  ]) {
    testWidgets('T1-3o scope error shows the common error, $caseName', (
      WidgetTester tester,
    ) async {
      final _RebalanceRepo repo = repoWith(
        (String id) =>
            Stream<JournalRebalanceScope?>.error(StateError('scope')),
      );
      await _pumpApp(
        tester,
        _overrides(
          repo,
          presets,
          sleeves,
          query: useOverride
              ? JournalTimelineQuery(range: scope.range, rebalanceEventId: reId)
              : null,
        ),
        useOverride
            ? const JournalTimeline()
            : JournalTimeline(rebalanceEventId: reId),
      );
      await tester.pumpAndSettle();

      expect(find.text(JournalLabels.retry), findsOneWidget);
      expect(find.byType(JournalEntryCard), findsNothing);
      expect(find.byKey(_chipKey), findsNothing);
      expect(repo.calls, isEmpty);
    });
  }
}
