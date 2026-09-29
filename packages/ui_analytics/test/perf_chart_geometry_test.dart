// test/perf_chart_geometry_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/chart/perf_chart_geometry.dart';

import 'golden/golden_support.dart';

void main() {
  group('perf_chart_geometry', () {
    test('U1 splitRuns on fixtures matches expected runs', () {
      final perf24m = listFixture(
        FixturePaths.performance24m,
        PerformanceSeries.fromJson,
      ).rows;
      final dailyGap = singleFixture(
        FixturePaths.m7M7PerfDailyGap,
        PerformanceSeries.fromJson,
      );
      final simSplit = singleFixture(
        FixturePaths.m7M7PerfMonthlySimSplit,
        PerformanceSeries.fromJson,
      );
      final dailyManual = singleFixture(
        FixturePaths.m7M7PerfDailyManual,
        PerformanceSeries.fromJson,
      );
      final monthlyPeriod = singleFixture(
        FixturePaths.m7M7PerfMonthlyPeriod,
        PerformanceSeries.fromJson,
      );
      final yearly = singleFixture(
        FixturePaths.m7M7PerfYearly,
        PerformanceSeries.fromJson,
      );

      // performance24m rows 0 and 1
      expect(splitRuns(perf24m[0].points), <IndexRun>[
        (start: 0, end: 5),
        (start: 7, end: 23),
      ]);
      expect(splitRuns(perf24m[0].benchmark!.points), <IndexRun>[
        (start: 0, end: 23),
      ]);

      expect(splitRuns(perf24m[1].points), <IndexRun>[
        (start: 0, end: 5),
        (start: 7, end: 23),
      ]);
      expect(splitRuns(perf24m[1].benchmark!.points), <IndexRun>[
        (start: 0, end: 23),
      ]);

      // m7M7PerfDailyGap
      expect(splitRuns(dailyGap.points), <IndexRun>[
        (start: 0, end: 12),
        (start: 15, end: 20),
      ]);

      // m7M7PerfMonthlySimSplit
      expect(splitRuns(simSplit.points), <IndexRun>[(start: 3, end: 17)]);

      // m7M7PerfDailyManual
      expect(splitRuns(dailyManual.points), <IndexRun>[(start: 0, end: 20)]);

      // m7M7PerfMonthlyPeriod
      expect(splitRuns(monthlyPeriod.points), <IndexRun>[
        (start: 0, end: 5),
        (start: 8, end: 23),
      ]);
      expect(splitRuns(monthlyPeriod.benchmark!.points), <IndexRun>[
        (start: 0, end: 23),
      ]);

      // m7M7PerfYearly
      expect(splitRuns(yearly.points), <IndexRun>[(start: 0, end: 2)]);
    });

    test('U2 edge cases for splitRuns', () {
      PerfPoint makePt(double? y) => PerfPoint(
        date: const TradeDate('2026-08-31'),
        xNormalized: 0.0,
        yNormalized: y,
        dateText: 'd',
        valueText: 'v',
      );

      expect(splitRuns(<PerfPoint>[]), <IndexRun>[]);
      expect(splitRuns([makePt(null)]), <IndexRun>[]);
      expect(splitRuns([makePt(0.5)]), <IndexRun>[(start: 0, end: 0)]);
      expect(splitRuns([makePt(null), makePt(0.5), makePt(null)]), <IndexRun>[
        (start: 1, end: 1),
      ]);
      expect(
        splitRuns([makePt(0.1), makePt(null), makePt(null), makePt(0.9)]),
        <IndexRun>[(start: 0, end: 0), (start: 3, end: 3)],
      );
    });

    test(
      'U4 xOf and yOf map 0 and 1 to plot boundaries and clamp outliers',
      () {
        const plot = Rect.fromLTRB(50.0, 10.0, 250.0, 110.0);

        expect(xOf(0.0, plot), 50.0);
        expect(xOf(1.0, plot), 250.0);
        expect(xOf(-0.5, plot), 50.0);
        expect(xOf(1.5, plot), 250.0);

        expect(yOf(0.0, plot), 110.0);
        expect(yOf(1.0, plot), 10.0);
        expect(yOf(-0.5, plot), 110.0);
        expect(yOf(1.5, plot), 10.0);
      },
    );
  });
}
