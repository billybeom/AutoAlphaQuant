// test/golden/a2_golden_test.dart — A-2 AdviceDetail golden (3 names x light/dark = 6 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/a2_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../advice_detail_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1400);

class _Flow {
  const _Flow({
    required this.name,
    required this.item,
    required this.fills,
    required this.bottom,
  });

  final String name;
  final AdviceItem item;
  final List<TradeJournalEntry> fills;
  final Key bottom;
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
  final AdviceItem viewer = listFixture<AdviceItem>(
    FixturePaths.m6AdviceViewer4,
    AdviceItem.fromJson,
  ).rows[2];

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'a2_partial',
      item: partial,
      fills: fills,
      bottom: const ValueKey<String>('a2-fill-0'),
    ),
    _Flow(
      name: 'a2_onhold',
      item: onhold,
      fills: <TradeJournalEntry>[],
      bottom: const Key('a2-decision'),
    ),
    _Flow(
      name: 'a2_viewer',
      item: viewer,
      fills: <TradeJournalEntry>[],
      bottom: const Key('a2-decision'),
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final FakeAdviceDetailRepository repo = FakeAdviceDetailRepository(
          item: (int call) => Future<AdviceItem?>.value(flow.item),
          fills: (int call) =>
              Future<List<TradeJournalEntry>>.value(flow.fills),
        );
        await pumpForGolden(
          tester,
          AdviceDetail(adviceId: flow.item.adviceId),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: adviceDetailOverrides(repo: repo),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('a2-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
