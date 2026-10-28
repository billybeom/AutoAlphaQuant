// advice_history_test.dart — AdviceHistory widget tests AH-01 ~ AH-08.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_fakes.dart';
import 'golden/golden_support.dart';

FakeAdviceHistoryRepository _hist(
  Stream<ListResult<AdviceItem>> Function(int call) history,
) => FakeAdviceHistoryRepository(history: history);

FakeAdviceRangeConfig _config(
  Stream<List<DateRange>> Function(int call) presets,
) => FakeAdviceRangeConfig(presets: presets);

class _EmptyCase {
  const _EmptyCase({
    required this.name,
    required this.history,
    required this.empty,
    required this.firstRow,
  });

  final String name;
  final ListResult<AdviceItem> history;
  final String? empty;
  final Matcher firstRow;
}

class _StateCase {
  const _StateCase({
    required this.name,
    required this.presets,
    required this.history,
    required this.clock,
    required this.present,
    required this.absent,
    required this.stale,
    required this.asOfText,
    required this.ranges,
  });

  final String name;
  final Stream<List<DateRange>> Function(int call) presets;
  final Stream<ListResult<AdviceItem>> Function(int call) history;
  final Clock? clock;
  final List<String> present;
  final List<String> absent;
  final Matcher stale;
  final Matcher asOfText;
  final List<DateRange> ranges;
}

class _RetryCase {
  const _RetryCase({
    required this.name,
    required this.presets,
    required this.history,
    required this.presetCalls,
    required this.ranges,
  });

  final String name;
  final Stream<List<DateRange>> Function(int call) presets;
  final Stream<ListResult<AdviceItem>> Function(int call) history;
  final int presetCalls;
  final List<DateRange> ranges;
}

void main() {
  final List<DateRange> presets4 = listFixture<DateRange>(
    FixturePaths.rangePresets4,
    DateRange.fromJson,
  ).rows;
  final ListResult<AdviceItem> open4 = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  );
  final ListResult<AdviceItem> closed = adviceSlice(open4, <int>[
    7,
    8,
    9,
    10,
    11,
  ]);
  final ListResult<AdviceItem> advEmpty = listFixture<AdviceItem>(
    FixturePaths.m6AdviceEmpty,
    AdviceItem.fromJson,
  );

  Stream<List<DateRange>> presetsValue(int call) =>
      Stream<List<DateRange>>.value(presets4);
  Stream<ListResult<AdviceItem>> closedValue(int call) =>
      Stream<ListResult<AdviceItem>>.value(closed);

  testWidgets('AH-01 default range once in received order and row tap', (
    WidgetTester tester,
  ) async {
    expect(presets4[0].isDefault, isTrue); // pre
    expect(presets4[0].label, isNotNull); // pre
    final FakeAdviceHistoryRepository hist = _hist(closedValue);
    final FakeAdviceRangeConfig config = _config(presetsValue);
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceHistory(
      tester,
      overrides: adviceHistoryOverrides(
        repo: hist,
        config: config,
        opener: opener,
      ),
    );

    expect(hist.ranges, <DateRange>[presets4[0]]);
    expect(config.calls, 1);
    expect(
      adviceShownTexts(tester, find.byKey(const Key('ah-range'))),
      <String?>[presets4[0].label],
    );
    expect(closed.rows, hasLength(5));
    for (final (int i, AdviceItem r) in closed.rows.indexed) {
      expect(
        adviceShownTexts(tester, find.byKey(ValueKey<String>('ah-row-$i'))),
        adviceCardTexts(r),
      );
    }
    expect(find.byKey(const ValueKey<String>('ah-row-5')), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('ah-row-0')));
    await tester.pump();
    expect(opener.opened, <String>[closed.rows[0].detailDeepLink]);
    expect(find.byType(TextButton), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('AH-02 presets before first value is a skeleton', (
    WidgetTester tester,
  ) async {
    final FakeAdviceHistoryRepository hist = _hist(closedValue);
    final FakeAdviceRangeConfig config = _config(
      (int call) => Stream<List<DateRange>>.fromFuture(
        Completer<List<DateRange>>().future,
      ),
    );
    await pumpAdviceHistory(
      tester,
      overrides: adviceHistoryOverrides(repo: hist, config: config),
    );

    expect(find.byKey(const Key('ah-loading')), findsOneWidget);
    expect(find.byKey(const Key('ah-asof')), findsNothing);
    expect(hist.ranges, <DateRange>[]);
  });

  testWidgets('AH-03 no default range is a skeleton without history call', (
    WidgetTester tester,
  ) async {
    expect(
      presets4.sublist(1).any((DateRange r) => r.isDefault),
      isFalse,
    ); // pre
    final FakeAdviceHistoryRepository hist = _hist(closedValue);
    final FakeAdviceRangeConfig config = _config(
      (int call) => Stream<List<DateRange>>.value(presets4.sublist(1)),
    );
    await pumpAdviceHistory(
      tester,
      overrides: adviceHistoryOverrides(repo: hist, config: config),
    );

    expect(find.byKey(const Key('ah-loading')), findsOneWidget);
    expect(hist.ranges, <DateRange>[]);
  });

  final List<_EmptyCase> emptyCases = <_EmptyCase>[
    _EmptyCase(
      name: 'empty',
      history: advEmpty,
      empty: advEmpty.emptyLabel,
      firstRow: findsNothing,
    ),
    _EmptyCase(
      name: 'closed',
      history: closed,
      empty: null,
      firstRow: findsOneWidget,
    ),
  ];

  for (final _EmptyCase c in emptyCases) {
    testWidgets('AH-04 empty sentence ${c.name}', (WidgetTester tester) async {
      expect(advEmpty.emptyLabel, isNotNull); // pre
      await pumpAdviceHistory(
        tester,
        overrides: adviceHistoryOverrides(
          repo: _hist(
            (int call) => Stream<ListResult<AdviceItem>>.value(c.history),
          ),
          config: _config(presetsValue),
        ),
      );

      final String? wantEmpty = c.empty;
      if (wantEmpty != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('ah-empty'))).data,
          wantEmpty,
        );
      } else {
        expect(find.byKey(const Key('ah-empty')), findsNothing);
      }
      expect(find.byKey(const ValueKey<String>('ah-row-0')), c.firstRow);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  final List<_StateCase> stateCases = <_StateCase>[
    _StateCase(
      name: 'presets_fail',
      presets: (int call) => Stream<List<DateRange>>.error(StateError('fail')),
      history: closedValue,
      clock: null,
      present: <String>['ah-fail'],
      absent: <String>['ah-loading', 'ah-asof'],
      stale: findsNothing,
      asOfText: findsNothing,
      ranges: <DateRange>[],
    ),
    _StateCase(
      name: 'history_fail',
      presets: presetsValue,
      history: (int call) =>
          Stream<ListResult<AdviceItem>>.error(StateError('fail')),
      clock: null,
      present: <String>['ah-fail'],
      absent: <String>['ah-loading', 'ah-asof'],
      stale: findsNothing,
      asOfText: findsNothing,
      ranges: <DateRange>[presets4[0]],
    ),
    _StateCase(
      name: 'history_value_then_fail',
      presets: presetsValue,
      history: (int call) =>
          adviceValueThenFail<ListResult<AdviceItem>>(closed),
      clock: null,
      present: <String>['ah-fail'],
      absent: <String>['ah-asof', 'ah-row-0'],
      stale: findsNothing,
      asOfText: findsOneWidget,
      ranges: <DateRange>[presets4[0]],
    ),
    _StateCase(
      name: 'stale',
      presets: presetsValue,
      history: closedValue,
      clock: adviceStaleClock(),
      present: <String>['ah-asof', 'ah-row-0'],
      absent: <String>['ah-loading', 'ah-fail'],
      stale: findsOneWidget,
      asOfText: findsOneWidget,
      ranges: <DateRange>[presets4[0]],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('AH-05 state branches ${c.name}', (WidgetTester tester) async {
      final FakeAdviceHistoryRepository hist = _hist(c.history);
      await pumpAdviceHistory(
        tester,
        overrides: adviceHistoryOverrides(
          repo: hist,
          config: _config(c.presets),
          clock: c.clock,
        ),
      );

      for (final String k in c.present) {
        expect(find.byKey(Key(k)), findsOneWidget);
      }
      for (final String k in c.absent) {
        expect(find.byKey(Key(k)), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.text(closed.asOf.label), c.asOfText);
      expect(hist.ranges, c.ranges);
    });
  }

  final List<_RetryCase> retryCases = <_RetryCase>[
    _RetryCase(
      name: 'presets_fail',
      presets: (int call) => call == 0
          ? Stream<List<DateRange>>.error(StateError('fail'))
          : Stream<List<DateRange>>.value(presets4),
      history: closedValue,
      presetCalls: 2,
      ranges: <DateRange>[presets4[0]],
    ),
    _RetryCase(
      name: 'history_fail',
      presets: presetsValue,
      history: (int call) => call == 0
          ? Stream<ListResult<AdviceItem>>.error(StateError('fail'))
          : Stream<ListResult<AdviceItem>>.value(closed),
      presetCalls: 1,
      ranges: <DateRange>[presets4[0], presets4[0]],
    ),
  ];

  for (final _RetryCase c in retryCases) {
    testWidgets('AH-06 retry ${c.name}', (WidgetTester tester) async {
      final FakeAdviceHistoryRepository hist = _hist(c.history);
      final FakeAdviceRangeConfig config = _config(c.presets);
      await pumpAdviceHistory(
        tester,
        overrides: adviceHistoryOverrides(repo: hist, config: config),
      );

      await tester.tap(find.text(JournalLabels.retry));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('ah-row-0')), findsOneWidget);
      expect(config.calls, c.presetCalls);
      expect(hist.ranges, c.ranges);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('AH-07 every Text is allowed and large font has no overflow', (
    WidgetTester tester,
  ) async {
    await pumpAdviceHistory(
      tester,
      overrides: adviceHistoryOverrides(
        repo: _hist(closedValue),
        config: _config(presetsValue),
      ),
    );

    final Set<String> allowed = adviceHistoryAllowed(closed, presets4[0]);
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

  testWidgets('AH-08 safety banner is the shared piece', (
    WidgetTester tester,
  ) async {
    expect(safetyFixtureRow(3).activeFlags, isNotEmpty); // pre
    await pumpAdviceHistory(
      tester,
      overrides: adviceHistoryOverrides(
        repo: _hist(closedValue),
        config: _config(presetsValue),
        safety: safetyFixtureRow(3),
      ),
    );

    final Finder flag = find.text(safetyFixtureRow(3).activeFlags.first.label);
    expect(flag, findsOneWidget);
    expect(
      tester.getTopLeft(flag).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('ah-asof'))).dy),
    );
    expect(
      tester.getTopLeft(flag).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('ah-range'))).dy),
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
