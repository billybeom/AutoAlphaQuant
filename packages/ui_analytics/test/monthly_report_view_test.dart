// packages/ui_analytics/test/monthly_report_view_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';

class _FakePerformanceRepository extends UnimplementedPerformanceRepository {
  _FakePerformanceRepository(this._report);
  final MonthlyReport _report;

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async => _report;
}

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  final report = singleFixture(
    FixturePaths.m7M7Monthly202608,
    MonthlyReport.fromJson,
  );
  final pendingReport = singleFixture(
    FixturePaths.m7M7MonthlyPending,
    MonthlyReport.fromJson,
  );
  final maskedIntegrityReport = singleFixture(
    FixturePaths.m7M7MonthlyMaskedIntegrity,
    MonthlyReport.fromJson,
  );

  final safetyEnvelope = fixtureEnvelope(FixturePaths.safetyStates);
  final safetyRow0 = SafetyState.fromJson(safetyEnvelope.rows[0]);
  final safetyRow1 = SafetyState.fromJson(safetyEnvelope.rows[1]);
  final safetyRow2 = SafetyState.fromJson(safetyEnvelope.rows[2]);
  final safetyRow3 = SafetyState.fromJson(safetyEnvelope.rows[3]);
  final safetyRow4 = SafetyState.fromJson(safetyEnvelope.rows[4]);

  testWidgets('S7-1 13개 항목 title 전수 렌더 및 픽스처 데이터 표시 검증', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (final item in report.items) {
      expect(find.text(item.title), findsOneWidget);
      expect(find.text(item.valueText), findsOneWidget);
    }

    expect(find.text(report.trust.label), findsOneWidget);
    expect(find.text(report.goalLine), findsOneWidget);
    expect(find.text(report.disclosureViewCountText), findsOneWidget);
    if (report.backdateFootnote != null) {
      expect(find.text(report.backdateFootnote!), findsOneWidget);
    }
  });

  testWidgets('S7-1 신선도 검사: staleAfter 초과 시 오래된 데이터 제목 노출', (
    WidgetTester tester,
  ) async {
    final expiredClock = FixedClock(kGoldenNowUtc.add(const Duration(days: 3)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(expiredClock),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
  });

  testWidgets('S7-1 차단 배너 label 표시 검증 (safety_states row 3)', (
    WidgetTester tester,
  ) async {
    final blockingFlag = safetyRow3.activeFlags.firstWhere(
      (f) => !FlagIds.markerOnly.contains(f.flagId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow3),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(blockingFlag.label), findsOneWidget);
    expect(find.text(blockingFlag.clearInstruction), findsOneWidget);
  });

  testWidgets('S7-1 표식 칩 표시 검증 (safety_states row 1 SELF_AUDIT_DUE)', (
    WidgetTester tester,
  ) async {
    final markerFlag = safetyRow1.activeFlags.firstWhere(
      (f) => FlagIds.markerOnly.contains(f.flagId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow1),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(markerFlag.label), findsOneWidget);
  });

  testWidgets('S7-1 ① 링크 있는 항목에만 「자세히」 버튼 노출 (2026_08: 3개, pending: 0개)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final expectedDetailCount = report.items
        .where((i) => i.detailDeepLink != null)
        .length;

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AnalyticsLabels.detailButton),
      findsNWidgets(expectedDetailCount),
    );

    // pending 리포트는 detailDeepLink 가 0개
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(pendingReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: pendingReport.yyyyMm),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.detailButton), findsNothing);
  });

  testWidgets('S7-1 ② 「자세히」 탭 시 해당 항목의 detailDeepLink 가 그대로 전달', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();
    final firstLinkedItem = report.items.firstWhere(
      (i) => i.detailDeepLink != null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AnalyticsLabels.detailButton).first);
    await tester.pumpAndSettle();

    expect(opener.opened, <String>[firstLinkedItem.detailDeepLink!]);
  });

  testWidgets('S7-1 ③ pendingNoticeText 표시 및 미표시 검증', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // pendingReport: pendingNoticeText 있음
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(pendingReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: pendingReport.yyyyMm),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(pendingReport.pendingNoticeText!), findsOneWidget);

    // normal report: pendingNoticeText null
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(pendingReport.pendingNoticeText!), findsNothing);
  });

  testWidgets('S7-1 ④ generatedAtText 및 configHash 표시/미표시 검증', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 2026_08: generatedAtText, configHash 있음
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(report.generatedAtText!), findsOneWidget);
    expect(find.text(report.configHash!), findsOneWidget);

    // pending: 둘 다 null
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(pendingReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: pendingReport.yyyyMm),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(report.generatedAtText!), findsNothing);
    expect(find.text(report.configHash!), findsNothing);
  });

  testWidgets('S7-1 ⑤ trust.actionDeepLink 버튼 유무 및 탭 시 링크 전달 검증', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();

    // 2026_08: actionDeepLink 없음
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.actionViewButton), findsNothing);

    // maskedIntegrityReport: actionDeepLink 있음
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(maskedIntegrityReport),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: maskedIntegrityReport.yyyyMm),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.actionViewButton), findsOneWidget);
    await tester.tap(find.text(AnalyticsLabels.actionViewButton));
    await tester.pumpAndSettle();

    expect(opener.opened, <String>[
      maskedIntegrityReport.trust.actionDeepLink!,
    ]);
  });

  testWidgets('S7-1 ⑥·⑦ 배너 chevron(4행 있음 / 2행 없음) 및 checkpointLabel 표시 검증', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();
    final flagRow4 = safetyRow4.activeFlags.first;

    // safetyRow4: clearDeepLink 있음, checkpointLabel 있음
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow4),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(flagRow4.checkpointLabel!), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(opener.opened, <String>[flagRow4.clearDeepLink!]);

    // safetyRow2: clearDeepLink 없음 (화살표 부재)
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow2),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('S7-1 ⑧ 「지난 리포트」 탭 시 AppRoutes.reportArchive 링크 전달 검증', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.pastReportsButton), findsOneWidget);
    await tester.tap(find.text(AnalyticsLabels.pastReportsButton));
    await tester.pumpAndSettle();

    expect(opener.opened, <String>[AppRoutes.reportArchive]);
  });

  testWidgets('TA-1 value column right edge', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          analyticsLinkOpenerProvider.overrideWithValue(opener),
          performanceRepositoryProvider.overrideWithValue(
            _FakePerformanceRepository(report),
          ),
          safetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthlyReportScreen(yyyyMm: report.yyyyMm)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(report.items, hasLength(13));
    for (final item in report.items) {
      final Rect valueRect = tester.getRect(find.text(item.valueText));
      final Finder cardFinder = find.ancestor(
        of: find.text(item.valueText),
        matching: find.byType(Card),
      );
      final Rect cardRect = tester.getRect(cardFinder);
      expect(valueRect.right, closeTo(cardRect.right - 12, 0.5));
    }
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final (String name, String fixturePath) in <(String, String)>[
    ('202608', FixturePaths.m7M7Monthly202608),
    ('gap', FixturePaths.m7M7MonthlyGap),
  ]) {
    testWidgets('TA-2 goal link opens deep link $name', (
      WidgetTester tester,
    ) async {
      final MonthlyReport taReport = singleFixture(
        fixturePath,
        MonthlyReport.fromJson,
      );
      tester.view.physicalSize = const Size(390, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final opener = RecordingLinkOpener();
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(opener),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(taReport),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyRow0),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: MonthlyReportScreen(yyyyMm: taReport.yyyyMm)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(taReport.goalDeepLink, isNotNull);
      expect(find.byKey(const Key('s71-goal-link')), findsOneWidget);
      expect(find.text(AnalyticsLabels.goalPathDetailButton), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(taReport.goalLine)).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('s71-goal-link'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('s71-goal-link'))).dy,
        lessThan(tester.getTopLeft(find.byType(Divider)).dy),
      );
      expect(
        tester.getTopLeft(find.byType(Divider)).dy,
        lessThan(
          tester.getTopLeft(find.text(taReport.disclosureViewCountText)).dy,
        ),
      );
      await tester.tap(find.byKey(const Key('s71-goal-link')));
      await tester.pump();
      expect(opener.opened, <String>[taReport.goalDeepLink!]);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final (String name, String fixturePath) in <(String, String)>[
    ('masked_integrity', FixturePaths.m7M7MonthlyMaskedIntegrity),
    ('masked_recon', FixturePaths.m7M7MonthlyMaskedRecon),
    ('pending', FixturePaths.m7M7MonthlyPending),
  ]) {
    testWidgets('TA-3 goal link absent $name', (WidgetTester tester) async {
      final MonthlyReport taReport = singleFixture(
        fixturePath,
        MonthlyReport.fromJson,
      );
      tester.view.physicalSize = const Size(390, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(
              RecordingLinkOpener(),
            ),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(taReport),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyRow0),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: MonthlyReportScreen(yyyyMm: taReport.yyyyMm)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(taReport.goalDeepLink, isNull);
      expect(find.byKey(const Key('s71-goal-link')), findsNothing);
      expect(find.text(AnalyticsLabels.goalPathDetailButton), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }
}
