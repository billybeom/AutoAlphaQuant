// advice_detail_test.dart — AdviceDetail widget tests A2-01 ~ A2-10.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_detail_fakes.dart';
import 'advice_fakes.dart';
import 'golden/golden_support.dart';

class _CloseCase {
  const _CloseCase({
    required this.name,
    required this.item,
    required this.close,
  });

  final String name;
  final AdviceItem item;
  final String? close;
}

class _StateCase {
  const _StateCase({
    required this.name,
    required this.item,
    required this.fills,
    required this.clock,
    required this.present,
    required this.absent,
    required this.stale,
    required this.skeleton,
  });

  final String name;
  final Future<AdviceItem?> Function(int call) item;
  final Future<List<TradeJournalEntry>> Function(int call) fills;
  final Clock? clock;
  final List<Key> present;
  final List<Key> absent;
  final Matcher stale;
  final Matcher skeleton;
}

class _RetryCase {
  const _RetryCase({
    required this.name,
    required this.item,
    required this.fills,
    required this.retryKey,
    required this.findArgs,
    required this.fillsArgs,
  });

  final String name;
  final Future<AdviceItem?> Function(int call) item;
  final Future<List<TradeJournalEntry>> Function(int call) fills;
  final Key retryKey;
  final List<String> findArgs;
  final List<String> fillsArgs;
}

void main() {
  final AdviceItem partial = singleFixture<AdviceItem>(
    FixturePaths.m6AdviceDetailPartial,
    AdviceItem.fromJson,
  );
  final List<TradeJournalEntry> fills = listFixture<TradeJournalEntry>(
    FixturePaths.m6AdviceFillsAd0005,
    TradeJournalEntry.fromJson,
  ).rows;
  final AdviceItem onhold = singleFixture<AdviceItem>(
    FixturePaths.m6AdviceDetailOnhold,
    AdviceItem.fromJson,
  );
  final List<AdviceItem> advice12 = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  ).rows;
  final AdviceItem viewer = listFixture<AdviceItem>(
    FixturePaths.m6AdviceViewer4,
    AdviceItem.fromJson,
  ).rows[2];
  final AdviceItem revoked = advice12[11];
  final AdviceItem opViewer = advice12[6];

  Future<AdviceItem?> Function(int call) itemOf(AdviceItem? v) =>
      (int call) => Future<AdviceItem?>.value(v);
  Future<List<TradeJournalEntry>> Function(int call) fillsOf(
    List<TradeJournalEntry> rows,
  ) =>
      (int call) => Future<List<TradeJournalEntry>>.value(rows);

  Future<void> tapKey(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pump();
  }

  double dyOf(WidgetTester tester, Key k) =>
      tester.getTopLeft(find.byKey(k)).dy;

  testWidgets('A2-01 partial texts order and calls', (
    WidgetTester tester,
  ) async {
    expect(partial.recordedDeviationChips, isNotEmpty); // pre
    expect(partial.decisionLink, isNotNull); // pre
    final FakeAdviceDetailRepository repo = FakeAdviceDetailRepository(
      item: itemOf(partial),
      fills: fillsOf(fills),
    );
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(repo: repo),
      adviceId: partial.adviceId,
    );

    expect(
      adviceShownTexts(tester, find.byKey(const Key('a2-asof'))),
      <String?>[partial.asOf.label],
    );
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a2-card'))),
      adviceCardTexts(partial),
    );
    expect(find.byKey(const Key('a2-close-reason')), findsNothing);
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a2-deviation'))),
      <String?>[
        for (final ReasonChip c in partial.recordedDeviationChips) c.label,
      ],
    );
    expect(
      adviceShownTexts(tester, find.byKey(const Key('a2-decision'))),
      <String?>[partial.decisionLink!.label],
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('a2-fills-title'))).data,
      JournalLabels.adviceRecordedFills,
    );
    expect(fills, hasLength(1));
    for (final (int i, TradeJournalEntry e) in fills.indexed) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('a2-fill-$i')),
          matching: find.text(e.symbolLabel),
        ),
        findsOneWidget,
      );
    }
    expect(find.byKey(const ValueKey<String>('a2-fill-1')), findsNothing);
    final List<double> dys = <double>[
      dyOf(tester, const Key('a2-asof')),
      dyOf(tester, const Key('a2-card')),
      dyOf(tester, const Key('a2-deviation')),
      dyOf(tester, const Key('a2-decision')),
      dyOf(tester, const Key('a2-fills-title')),
      dyOf(tester, const ValueKey<String>('a2-fill-0')),
    ];
    for (int i = 1; i < dys.length; i = i + 1) {
      expect(dys[i], greaterThan(dys[i - 1]));
    }
    expect(repo.findArgs, <String>[partial.adviceId]);
    expect(repo.fillsArgs, <String>[partial.adviceId]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A2-02 five links in order', (WidgetTester tester) async {
    expect(partial.actions.length, 2); // pre
    expect(partial.reasons.first.detailDeepLink, isNotNull); // pre
    expect(fills.first.detailDeepLink, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(
        repo: FakeAdviceDetailRepository(
          item: itemOf(partial),
          fills: fillsOf(fills),
        ),
        opener: opener,
      ),
      adviceId: partial.adviceId,
    );

    final Finder card = find.byKey(const Key('a2-card'));
    await tapKey(
      tester,
      find.descendant(of: card, matching: find.text(partial.actions[0].label)),
    );
    await tapKey(
      tester,
      find.descendant(of: card, matching: find.text(partial.actions[1].label)),
    );
    await tapKey(
      tester,
      find.descendant(of: card, matching: find.text(partial.reasons[0].label)),
    );
    await tapKey(tester, find.byKey(const Key('a2-decision')));
    await tapKey(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey<String>('a2-fill-0')),
        matching: find.text(fills[0].symbolLabel),
      ),
    );

    expect(opener.opened, <String>[
      partial.actions[0].deepLink,
      partial.actions[1].deepLink,
      partial.reasons[0].detailDeepLink!,
      partial.decisionLink!.deepLink,
      fills[0].detailDeepLink!,
    ]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A2-03 on hold has no fills and no deviation chips', (
    WidgetTester tester,
  ) async {
    expect(onhold.holdReasonLabel, isNotNull); // pre
    expect(onhold.recordedDeviationChips, isEmpty); // pre
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(
        repo: FakeAdviceDetailRepository(
          item: itemOf(onhold),
          fills: fillsOf(<TradeJournalEntry>[]),
        ),
      ),
      adviceId: onhold.adviceId,
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('a2-card')),
        matching: find.text(onhold.holdReasonLabel!),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('a2-deviation')),
        matching: find.byType(JournalReasonChip),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('a2-deviation')), findsOneWidget);
    expect(find.byKey(const Key('a2-fills-title')), findsNothing);
    expect(find.byKey(const ValueKey<String>('a2-fill-0')), findsNothing);
    expect(find.byKey(const Key('a2-fills-fail')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A2-04 viewer has no buttons and only received texts', (
    WidgetTester tester,
  ) async {
    expect(viewer.actions, isEmpty); // pre
    expect(viewer.phoneOnlyLabel, isNotNull); // pre
    expect(opViewer.adviceId, viewer.adviceId); // pre
    expect(opViewer.symbolLabel, isNotNull); // pre
    expect(opViewer.priceBand, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(
        repo: FakeAdviceDetailRepository(
          item: itemOf(viewer),
          fills: fillsOf(<TradeJournalEntry>[]),
        ),
        opener: opener,
      ),
      adviceId: viewer.adviceId,
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('a2-card')),
        matching: find.byType(OutlinedButton),
      ),
      findsNothing,
    );
    expect(find.text(viewer.phoneOnlyLabel!), findsOneWidget);
    expect(find.text(opViewer.symbolLabel!), findsNothing);
    expect(find.text(opViewer.priceBand!.label), findsNothing);
    expect(find.byKey(const Key('a2-decision')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('a2-fill-0')), findsNothing);
    final Set<String> allowed = adviceDetailAllowed(viewer);
    final List<String?> shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data)
        .toList();
    expect(shown, isNotEmpty);
    for (final String? data in shown) {
      expect(data, isIn(allowed));
    }
    await tapKey(tester, find.byKey(const Key('a2-decision')));
    expect(opener.opened, <String>[viewer.decisionLink!.deepLink]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('A2-05 absent when findById returns null', (
    WidgetTester tester,
  ) async {
    final FakeAdviceDetailRepository repo = FakeAdviceDetailRepository(
      item: itemOf(null),
      fills: fillsOf(<TradeJournalEntry>[]),
    );
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(repo: repo),
      adviceId: partial.adviceId,
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('a2-absent'))).data,
      JournalLabels.adviceNotFound,
    );
    expect(find.byKey(const Key('a2-asof')), findsNothing);
    expect(find.byKey(const Key('a2-card')), findsNothing);
    expect(
      tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList(),
      <String?>[JournalLabels.adviceNotFound],
    );
    expect(repo.fillsArgs, <String>[]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  final List<_CloseCase> closeCases = <_CloseCase>[
    _CloseCase(name: 'revoked', item: revoked, close: revoked.closeReasonLabel),
    _CloseCase(name: 'partial', item: partial, close: null),
  ];
  for (final _CloseCase c in closeCases) {
    testWidgets('A2-06 close reason sentence ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(revoked.closeReasonLabel, isNotNull); // pre
      expect(partial.closeReasonLabel, isNull); // pre
      await pumpAdviceDetail(
        tester,
        overrides: adviceDetailOverrides(
          repo: FakeAdviceDetailRepository(
            item: itemOf(c.item),
            fills: fillsOf(<TradeJournalEntry>[]),
          ),
        ),
        adviceId: c.item.adviceId,
      );

      expect(find.byKey(const Key('a2-card')), findsOneWidget);
      final String? want = c.close;
      if (want != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('a2-close-reason'))).data,
          want,
        );
        expect(
          dyOf(tester, const Key('a2-close-reason')),
          greaterThan(dyOf(tester, const Key('a2-card'))),
        );
        expect(
          dyOf(tester, const Key('a2-close-reason')),
          lessThan(dyOf(tester, const Key('a2-deviation'))),
        );
      } else {
        expect(find.byKey(const Key('a2-close-reason')), findsNothing);
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  final List<_StateCase> stateCases = <_StateCase>[
    _StateCase(
      name: 'item_loading',
      item: (int call) => Completer<AdviceItem?>().future,
      fills: fillsOf(fills),
      clock: null,
      present: const <Key>[Key('a2-loading')],
      absent: const <Key>[Key('a2-asof'), Key('a2-fail'), Key('a2-absent')],
      stale: findsNothing,
      skeleton: findsOneWidget,
    ),
    _StateCase(
      name: 'item_fail',
      item: (int call) => Future<AdviceItem?>.error(StateError('fail')),
      fills: fillsOf(fills),
      clock: null,
      present: const <Key>[Key('a2-fail')],
      absent: const <Key>[Key('a2-loading'), Key('a2-asof'), Key('a2-absent')],
      stale: findsNothing,
      skeleton: findsNothing,
    ),
    _StateCase(
      name: 'fills_loading',
      item: itemOf(partial),
      fills: (int call) => Completer<List<TradeJournalEntry>>().future,
      clock: null,
      present: const <Key>[Key('a2-asof'), Key('a2-card'), Key('a2-decision')],
      absent: const <Key>[
        Key('a2-fills-title'),
        Key('a2-fill-0'),
        Key('a2-fills-fail'),
      ],
      stale: findsNothing,
      skeleton: findsNothing,
    ),
    _StateCase(
      name: 'fills_fail',
      item: itemOf(partial),
      fills: (int call) =>
          Future<List<TradeJournalEntry>>.error(StateError('fail')),
      clock: null,
      present: const <Key>[Key('a2-card'), Key('a2-fills-fail')],
      absent: const <Key>[Key('a2-fills-title'), Key('a2-fill-0')],
      stale: findsNothing,
      skeleton: findsNothing,
    ),
    _StateCase(
      name: 'stale',
      item: itemOf(partial),
      fills: fillsOf(fills),
      clock: adviceStaleClock(),
      present: const <Key>[Key('a2-asof'), Key('a2-card'), Key('a2-fill-0')],
      absent: const <Key>[Key('a2-loading'), Key('a2-fail')],
      stale: findsOneWidget,
      skeleton: findsNothing,
    ),
  ];
  for (final _StateCase c in stateCases) {
    testWidgets('A2-07 state branches ${c.name}', (WidgetTester tester) async {
      await pumpAdviceDetail(
        tester,
        overrides: adviceDetailOverrides(
          repo: FakeAdviceDetailRepository(item: c.item, fills: c.fills),
          clock: c.clock,
        ),
        adviceId: partial.adviceId,
      );

      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.text(JournalLabels.staleBannerTitle), c.stale);
      expect(find.byType(JournalSkeleton), c.skeleton);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  final List<_RetryCase> retryCases = <_RetryCase>[
    _RetryCase(
      name: 'item',
      item: (int call) => call == 0
          ? Future<AdviceItem?>.error(StateError('fail'))
          : Future<AdviceItem?>.value(partial),
      fills: fillsOf(fills),
      retryKey: const Key('a2-fail'),
      findArgs: <String>[partial.adviceId, partial.adviceId],
      fillsArgs: <String>[partial.adviceId],
    ),
    _RetryCase(
      name: 'fills',
      item: itemOf(partial),
      fills: (int call) => call == 0
          ? Future<List<TradeJournalEntry>>.error(StateError('fail'))
          : Future<List<TradeJournalEntry>>.value(fills),
      retryKey: const Key('a2-fills-fail'),
      findArgs: <String>[partial.adviceId],
      fillsArgs: <String>[partial.adviceId, partial.adviceId],
    ),
  ];
  for (final _RetryCase c in retryCases) {
    testWidgets('A2-08 retry ${c.name}', (WidgetTester tester) async {
      final FakeAdviceDetailRepository repo = FakeAdviceDetailRepository(
        item: c.item,
        fills: c.fills,
      );
      await pumpAdviceDetail(
        tester,
        overrides: adviceDetailOverrides(repo: repo),
        adviceId: partial.adviceId,
      );

      await tapKey(
        tester,
        find.descendant(
          of: find.byKey(c.retryKey),
          matching: find.text(JournalLabels.retry),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('a2-fill-0')), findsOneWidget);
      expect(repo.findArgs, c.findArgs);
      expect(repo.fillsArgs, c.fillsArgs);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  testWidgets('A2-09 every Text is allowed and large font has no overflow', (
    WidgetTester tester,
  ) async {
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(
        repo: FakeAdviceDetailRepository(
          item: itemOf(onhold),
          fills: fillsOf(<TradeJournalEntry>[]),
        ),
      ),
      adviceId: onhold.adviceId,
    );

    final Set<String> allowed = adviceDetailAllowed(onhold);
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

  testWidgets('A2-10 safety banner sits above the card', (
    WidgetTester tester,
  ) async {
    expect(safetyFixtureRow(3).activeFlags, isNotEmpty); // pre
    await pumpAdviceDetail(
      tester,
      overrides: adviceDetailOverrides(
        repo: FakeAdviceDetailRepository(
          item: itemOf(partial),
          fills: fillsOf(fills),
        ),
        safety: safetyFixtureRow(3),
      ),
      adviceId: partial.adviceId,
    );

    final Finder flag = find.text(safetyFixtureRow(3).activeFlags.first.label);
    expect(flag, findsOneWidget);
    expect(
      tester.getTopLeft(flag).dy,
      greaterThan(dyOf(tester, const Key('a2-asof'))),
    );
    expect(
      tester.getTopLeft(flag).dy,
      lessThan(dyOf(tester, const Key('a2-card'))),
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
