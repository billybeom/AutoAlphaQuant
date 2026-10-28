// test/golden/a1_history_golden_test.dart — AdviceHistory golden (1 name x light/dark = 2 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/a1_history_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../advice_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1700);

class _Flow {
  const _Flow({required this.name, required this.steps});

  final String name;
  final Future<void> Function(WidgetTester tester) steps;
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

  final List<_Flow> flows = <_Flow>[
    _Flow(name: 'a1_history', steps: (_) async {}),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const AdviceHistory(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: adviceHistoryOverrides(
              repo: FakeAdviceHistoryRepository(
                history: (int call) =>
                    Stream<ListResult<AdviceItem>>.value(closed),
              ),
              config: FakeAdviceRangeConfig(
                presets: (int call) => Stream<List<DateRange>>.value(presets4),
              ),
              safety: safetyFixtureRow(0),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pump();

        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester
              .getBottomLeft(find.byKey(const ValueKey<String>('ah-row-4')))
              .dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('ah-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
