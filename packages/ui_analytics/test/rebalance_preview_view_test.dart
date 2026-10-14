import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';
import 'rebalance_preview_fakes.dart';

void main() {
  testWidgets('T76c-01 entry', (WidgetTester tester) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: countdown,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

    expect(repo.watchNextCalls, 1);
    expect(repo.otherCalls, isEmpty);
    expect(whatIf.previewCalls, isEmpty);
    expect(whatIf.otherCalls, isEmpty);
    expect(find.byKey(const Key('s76c-root')), findsOneWidget);
    expect(find.byKey(const Key('s76c-preview-button')), findsOneWidget);
    expect(find.text(AnalyticsLabels.rebalanceDraftButton), findsOneWidget);
    expect(find.byKey(const Key('s76c-draft')), findsNothing);
    expect(find.byKey(const Key('s76c-notice')), findsNothing);
    expect(find.byKey(const Key('s76c-blocked')), findsNothing);
    expect(find.byType(AnalyticsSkeleton), findsNothing);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final ({String name, bool stripped}) d
      in <({String name, bool stripped})>[
        (name: 'default', stripped: false),
        (name: 'stripped', stripped: true),
      ]) {
    testWidgets('T76c-02 countdown text chain ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm raw = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final NextRebalanceVm vm = d.stripped
          ? raw.copyWith(kindLabel: null, noticeText: null)
          : raw;
      expect(vm.kindLabel, d.stripped ? isNull : isNotNull);

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: vm,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

      await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

      final List<String?> texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('s76c-countdown')),
              matching: find.byType(Text),
            ),
          )
          .map((Text t) => t.data)
          .toList();
      final List<String?> expected = <String?>[
        vm.dDayText,
        vm.expectedDateText,
        if (vm.kindLabel != null) vm.kindLabel,
        if (vm.noticeText != null) vm.noticeText,
      ];
      expect(texts, expected);
      expect(
        tester.widget<Text>(find.byKey(const Key('s76c-asof'))).data,
        vm.asOf.label,
      );
      expect(find.byKey(const Key('s76c-empty')), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-03 none', (WidgetTester tester) async {
    final NextRebalanceVm none = singleFixture(
      FixturePaths.m7M7NextRebalanceNone,
      NextRebalanceVm.fromJson,
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: none,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

    expect(
      tester.widget<Text>(find.byKey(const Key('s76c-empty'))).data,
      none.emptyLabel,
    );
    expect(find.byKey(const Key('s76c-countdown')), findsNothing);
    expect(find.byKey(const Key('s76c-preview-button')), findsNothing);
    expect(find.text(AnalyticsLabels.rebalanceDraftButton), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('s76c-asof'))).data,
      none.asOf.label,
    );
    expect(find.byKey(const Key('s76c-draft')), findsNothing);
    expect(whatIf.previewCalls, isEmpty);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final ({String name, String path, bool isNone}) d
      in <({String name, String path, bool isNone})>[
        (
          name: 'countdown',
          path: FixturePaths.m7M7NextRebalanceCountdown,
          isNone: false,
        ),
        (name: 'none', path: FixturePaths.m7M7NextRebalanceNone, isNone: true),
      ]) {
    testWidgets('T76c-04 viewer null whatif ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm vm = singleFixture(
        d.path,
        NextRebalanceVm.fromJson,
      );
      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: vm,
      );

      await pumpRebalancePreview(tester, repo: repo, whatIf: null);

      expect(find.byKey(const Key('s76c-preview-button')), findsNothing);
      expect(find.text(AnalyticsLabels.rebalanceDraftButton), findsNothing);
      expect(find.byKey(const Key('s76c-draft')), findsNothing);
      expect(find.byKey(const Key('s76c-blocked')), findsNothing);
      if (d.isNone) {
        expect(find.byKey(const Key('s76c-empty')), findsOneWidget);
        expect(find.byKey(const Key('s76c-countdown')), findsNothing);
      } else {
        expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
        expect(find.byKey(const Key('s76c-empty')), findsNothing);
      }
      expect(find.byKey(const Key('s76c-asof')), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-05 preview only after tap no args', (
    WidgetTester tester,
  ) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: countdown,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

    expect(whatIf.previewCalls, isEmpty);
    await tester.tap(find.byKey(const Key('s76c-preview-button')));
    await tester.pump();
    await tester.pump();

    expect(whatIf.previewCalls, hasLength(1));
    expect(whatIf.previewCalls.single, isNull);
    expect(whatIf.otherCalls, isEmpty);
    expect(repo.watchNextCalls, 1);
    expect(repo.otherCalls, isEmpty);
    expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tester.tap(find.byKey(const Key('s76c-preview-button')));
    await tester.pump();
    await tester.pump();

    expect(whatIf.previewCalls.length, 2);
    expect(whatIf.previewCalls[1], isNull);
    expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
  });

  for (final ({String name, int caseIndex}) d
      in <({String name, int caseIndex})>[
        (name: 'default', caseIndex: 0),
        (name: 'in_band', caseIndex: 1),
        (name: 'in_band_two_warnings', caseIndex: 2),
      ]) {
    testWidgets('T76c-06 draft text chain ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final RebalancePreviewResult result;
      if (d.caseIndex == 0) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewDefault,
          RebalancePreviewResult.fromJson,
        );
      } else if (d.caseIndex == 1) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewInBand,
          RebalancePreviewResult.fromJson,
        );
      } else {
        final RebalancePreviewResult inBand = singleFixture(
          FixturePaths.m7M7RebalancePreviewInBand,
          RebalancePreviewResult.fromJson,
        );
        result = inBand.copyWith(
          preview: inBand.preview!.copyWith(
            warningLines: <String>[
              inBand.preview!.warningLines.single,
              inBand.preview!.previewNotice,
            ],
          ),
        );
        expect(
          result.preview!.warningLines.first,
          isNot(result.preview!.warningLines.last),
        );
      }
      final RebalancePreview preview = result.preview!;

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        result: result,
      );

      await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();

      expect(preview.orderDrafts, hasLength(d.caseIndex == 0 ? 2 : 0));

      final List<String?> texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('s76c-draft')),
              matching: find.byType(Text),
            ),
          )
          .map((Text t) => t.data)
          .toList();

      final List<String?> expected = <String?>[
        preview.plannedDateText,
        preview.orderDraftsTitle,
        if (preview.ordersEmptyText != null)
          preview.ordersEmptyText
        else
          for (final OrderDraft draft in preview.orderDrafts) ...<String?>[
            draft.symbolLabel,
            draft.accountAlias,
            draft.sideLabel,
            draft.quantityText,
            if (draft.limitPriceText != null) draft.limitPriceText,
            if (draft.pendingNoteText != null) draft.pendingNoteText,
            for (final ReasonChip chip in draft.reasons) chip.label,
          ],
        AnalyticsLabels.rebalanceDraftCostsHeader,
        preview.costs.totalText,
        preview.costs.sourceLabel,
        preview.costs.basisNote,
        ...preview.warningLines,
        preview.asOf.label,
      ];
      expect(texts, expected);

      if (preview.ordersEmptyText != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('s76c-draft-empty'))).data,
          preview.ordersEmptyText,
        );
      } else {
        expect(find.byKey(const Key('s76c-draft-empty')), findsNothing);
      }

      expect(
        tester.widget<Text>(find.byKey(const Key('s76c-draft-asof'))).data,
        preview.asOf.label,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('s76c-notice'))).data,
        preview.previewNotice,
      );
      expect(countdown.asOf.label, isNot(preview.asOf.label));
      expect(
        tester.widget<Text>(find.byKey(const Key('s76c-asof'))).data,
        countdown.asOf.label,
      );
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final ({String name, int rowIndex}) d in <({String name, int rowIndex})>[
    (name: 'row0', rowIndex: 0),
    (name: 'row1', rowIndex: 1),
  ]) {
    testWidgets('T76c-07 blocked ${d.name}', (WidgetTester tester) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final List<RebalancePreviewResult> rows = listFixture(
        FixturePaths.m7M7RebalancePreviewBlocked,
        RebalancePreviewResult.fromJson,
      ).rows;
      final RecordingLinkOpener opener = RecordingLinkOpener();

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        result: rows[d.rowIndex],
      );

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: whatIf,
        opener: opener,
      );
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();

      expect(rows, hasLength(2));
      expect(find.byKey(const Key('s76c-blocked')), findsOneWidget);

      final List<String?> texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('s76c-blocked')),
              matching: find.byType(Text),
            ),
          )
          .map((Text t) => t.data)
          .toList();
      final RebalancePreviewResult row = rows[d.rowIndex];
      final List<String?> expected = <String?>[
        row.blockedText,
        if (row.blockedAction != null) row.blockedAction!.label,
      ];
      expect(texts, expected);
      expect(opener.opened, isEmpty);

      if (row.blockedAction != null) {
        expect(find.byKey(const Key('s76c-blocked-action')), findsOneWidget);
        await tester.tap(find.byKey(const Key('s76c-blocked-action')));
        await tester.pump();
        expect(opener.opened, <String>[row.blockedAction!.deepLink]);
      } else {
        expect(find.byKey(const Key('s76c-blocked-action')), findsNothing);
      }

      expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
      expect(find.byKey(const Key('s76c-preview-button')), findsOneWidget);
      expect(find.byKey(const Key('s76c-draft')), findsNothing);
      expect(find.byKey(const Key('s76c-notice')), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-08 pending skeleton and button stays enabled', (
    WidgetTester tester,
  ) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final Completer<RebalancePreviewResult> completer =
        Completer<RebalancePreviewResult>();
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: countdown,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
      answerFn: (int call) => completer.future,
    );

    await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);
    await tester.tap(find.byKey(const Key('s76c-preview-button')));
    await tester.pump();
    await tester.pump();

    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('s76c-preview-button')))
          .onPressed,
      isNotNull,
    );
    expect(find.byKey(const Key('s76c-draft')), findsNothing);
    expect(find.byKey(const Key('s76c-notice')), findsNothing);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    final RebalancePreviewResult defaultResult = singleFixture(
      FixturePaths.m7M7RebalancePreviewDefault,
      RebalancePreviewResult.fromJson,
    );
    completer.complete(defaultResult);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
    expect(find.byType(AnalyticsSkeleton), findsNothing);
  });

  for (final ({String name, bool useErrorViewRetry}) d
      in <({String name, bool useErrorViewRetry})>[
        (name: 'retry_view', useErrorViewRetry: true),
        (name: 'preview_button', useErrorViewRetry: false),
      ]) {
    testWidgets('T76c-09 error and retry ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final RebalancePreviewResult defaultResult = singleFixture(
        FixturePaths.m7M7RebalancePreviewDefault,
        RebalancePreviewResult.fromJson,
      );
      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        answerFn: (int call) {
          if (call == 1) {
            return Future<RebalancePreviewResult>.error(StateError('x'));
          }
          return Future<RebalancePreviewResult>.value(defaultResult);
        },
      );

      await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AnalyticsErrorView), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
      expect(find.byKey(const Key('s76c-preview-button')), findsOneWidget);
      expect(find.byKey(const Key('s76c-draft')), findsNothing);

      if (d.useErrorViewRetry) {
        await tester.tap(find.text(AnalyticsLabels.retryButton));
      } else {
        await tester.tap(find.byKey(const Key('s76c-preview-button')));
      }
      await tester.pump();
      await tester.pump();

      expect(whatIf.previewCalls, hasLength(2));
      expect(whatIf.previewCalls[0], isNull);
      expect(whatIf.previewCalls[1], isNull);
      expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
      expect(find.byType(AnalyticsErrorView), findsNothing);
    });
  }

  for (final ({String name, bool bFirst, bool aFails}) d
      in <({String name, bool bFirst, bool aFails})>[
        (name: 'b_then_a', bFirst: true, aFails: false),
        (name: 'a_then_b', bFirst: false, aFails: false),
        (name: 'b_then_a_error', bFirst: true, aFails: true),
      ]) {
    testWidgets('T76c-10 last request only ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final RebalancePreviewResult defaultResult = singleFixture(
        FixturePaths.m7M7RebalancePreviewDefault,
        RebalancePreviewResult.fromJson,
      );
      final RebalancePreviewResult blockedResult = listFixture(
        FixturePaths.m7M7RebalancePreviewBlocked,
        RebalancePreviewResult.fromJson,
      ).rows[0];

      final Completer<RebalancePreviewResult> completerA =
          Completer<RebalancePreviewResult>();
      final Completer<RebalancePreviewResult> completerB =
          Completer<RebalancePreviewResult>();

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        answerFn: (int call) {
          if (call == 1) return completerA.future;
          return completerB.future;
        },
      );

      await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();

      if (d.bFirst) {
        completerB.complete(defaultResult);
        await tester.pump();
        await tester.pump();
        expect(find.byKey(const Key('s76c-draft')), findsOneWidget);

        if (d.aFails) {
          completerA.completeError(StateError('x'));
        } else {
          completerA.complete(blockedResult);
        }
        await tester.pump();
        await tester.pump();
        expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
        expect(find.byKey(const Key('s76c-blocked')), findsNothing);
        expect(find.byType(AnalyticsErrorView), findsNothing);
      } else {
        completerA.complete(defaultResult);
        await tester.pump();
        await tester.pump();
        expect(find.byType(AnalyticsSkeleton), findsOneWidget);
        expect(find.byKey(const Key('s76c-draft')), findsNothing);

        completerB.complete(blockedResult);
        await tester.pump();
        await tester.pump();
        expect(find.byKey(const Key('s76c-blocked')), findsOneWidget);
        expect(find.byKey(const Key('s76c-draft')), findsNothing);
      }

      expect(whatIf.previewCalls, hasLength(2));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-11 preview notice outside scroll', (
    WidgetTester tester,
  ) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final RebalancePreviewResult defaultResult = singleFixture(
      FixturePaths.m7M7RebalancePreviewDefault,
      RebalancePreviewResult.fromJson,
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: countdown,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
      result: defaultResult,
    );

    await pumpRebalancePreview(
      tester,
      repo: repo,
      whatIf: whatIf,
      viewSize: const Size(390, 600),
    );
    await tester.tap(find.byKey(const Key('s76c-preview-button')));
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<Text>(find.byKey(const Key('s76c-notice'))).data,
      defaultResult.preview!.previewNotice,
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('s76c-notice')),
        matching: find.byType(Scrollable),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('s76c-countdown')),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );

    final double noticeDy = tester
        .getTopLeft(find.byKey(const Key('s76c-notice')))
        .dy;
    final double countdownDy = tester
        .getTopLeft(find.byKey(const Key('s76c-countdown')))
        .dy;

    await tester.drag(find.byType(ListView), const Offset(0, -40));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('s76c-notice'))).dy,
      noticeDy,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('s76c-countdown'))).dy,
      lessThan(countdownDy),
    );
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final ({String name, bool isStale, int safetyIndex, int expectedFlags}) d
      in <({String name, bool isStale, int safetyIndex, int expectedFlags})>[
        (name: 'stale_row3', isStale: true, safetyIndex: 3, expectedFlags: 2),
        (name: 'fresh_row0', isStale: false, safetyIndex: 0, expectedFlags: 0),
        (name: 'fresh_row4', isStale: false, safetyIndex: 4, expectedFlags: 1),
      ]) {
    testWidgets('T76c-12 banners ${d.name}', (WidgetTester tester) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final SafetyState safetyState = SafetyState.fromJson(
        fixtureEnvelope(FixturePaths.safetyStates).rows[d.safetyIndex],
      );
      final List<BlockFlag> activeFlags = safetyState.activeFlags;
      final RecordingLinkOpener opener = RecordingLinkOpener();

      final Clock clock = d.isStale
          ? FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))
          : FixedClock(kGoldenNowUtc);

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: whatIf,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      );

      expect(activeFlags, hasLength(d.expectedFlags));

      if (d.isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(AnalyticsLabels.staleBannerTitle),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }

      for (final BlockFlag flag in activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(flag.label),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      }

      if (activeFlags.isEmpty) {
        expect(find.byIcon(Icons.block), findsNothing);
      } else {
        expect(find.byIcon(Icons.block), findsNWidgets(activeFlags.length));
      }

      final List<Finder> chain = <Finder>[
        if (d.isStale) find.text(AnalyticsLabels.staleBannerTitle),
        if (activeFlags.isNotEmpty) find.text(activeFlags.first.label),
        find.byKey(const Key('s76c-countdown')),
      ];
      for (int i = 0; i < chain.length - 1; i++) {
        expect(
          tester.getTopLeft(chain[i]).dy,
          lessThan(tester.getTopLeft(chain[i + 1]).dy),
        );
      }

      if (d.safetyIndex == 4) {
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
        expect(opener.opened, <String>[activeFlags.single.clearDeepLink!]);
      } else {
        expect(opener.opened, isEmpty);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-13a loading skeleton no banners', (
    WidgetTester tester,
  ) async {
    final StreamController<NextRebalanceVm> controller =
        StreamController<NextRebalanceVm>();
    addTearDown(() {
      unawaited(controller.close());
    });

    final SafetyState safetyState = SafetyState.fromJson(
      fixtureEnvelope(FixturePaths.safetyStates).rows[3],
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      streamFactory: (int call) => controller.stream,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(
      tester,
      repo: repo,
      whatIf: whatIf,
      safetyState: safetyState,
    );

    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s76c-root')), findsNothing);
    for (final BlockFlag flag in safetyState.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  testWidgets('T76c-13b error view and retry', (WidgetTester tester) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final SafetyState safetyState = SafetyState.fromJson(
      fixtureEnvelope(FixturePaths.safetyStates).rows[3],
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      streamFactory: (int call) {
        if (call == 1) {
          return Stream<NextRebalanceVm>.error(StateError('x'));
        }
        return Stream<NextRebalanceVm>.value(countdown);
      },
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(
      tester,
      repo: repo,
      whatIf: whatIf,
      safetyState: safetyState,
    );

    expect(find.byType(AnalyticsErrorView), findsOneWidget);
    expect(
      tester
          .widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView))
          .lastAsOfLabel,
      isNull,
    );
    for (final BlockFlag flag in safetyState.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.byKey(const Key('s76c-root')), findsNothing);
    expect(find.byKey(const Key('s76c-preview-button')), findsNothing);

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();
    await tester.pump();

    expect(repo.watchNextCalls, 2);
    expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
    expect(whatIf.previewCalls, isEmpty);
  });

  for (final ({
        String name,
        String vmPath,
        bool isNone,
        int? previewIndex,
        bool isStale,
        int safetyIndex,
      })
      d
      in <
        ({
          String name,
          String vmPath,
          bool isNone,
          int? previewIndex,
          bool isStale,
          int safetyIndex,
        })
      >[
        (
          name: 'default',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          isNone: false,
          previewIndex: 0,
          isStale: false,
          safetyIndex: 0,
        ),
        (
          name: 'in_band_stale',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          isNone: false,
          previewIndex: 1,
          isStale: true,
          safetyIndex: 3,
        ),
        (
          name: 'blocked',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          isNone: false,
          previewIndex: 2,
          isStale: false,
          safetyIndex: 4,
        ),
        (
          name: 'none',
          vmPath: FixturePaths.m7M7NextRebalanceNone,
          isNone: true,
          previewIndex: null,
          isStale: false,
          safetyIndex: 0,
        ),
      ]) {
    testWidgets('T76c-14 layout chain ${d.name}', (WidgetTester tester) async {
      final NextRebalanceVm vm = singleFixture(
        d.vmPath,
        NextRebalanceVm.fromJson,
      );
      final SafetyState safetyState = SafetyState.fromJson(
        fixtureEnvelope(FixturePaths.safetyStates).rows[d.safetyIndex],
      );
      final List<BlockFlag> activeFlags = safetyState.activeFlags;
      final Clock clock = d.isStale
          ? FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))
          : FixedClock(kGoldenNowUtc);

      final RebalancePreviewResult? result;
      if (d.previewIndex == 0) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewDefault,
          RebalancePreviewResult.fromJson,
        );
      } else if (d.previewIndex == 1) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewInBand,
          RebalancePreviewResult.fromJson,
        );
      } else if (d.previewIndex == 2) {
        result = listFixture(
          FixturePaths.m7M7RebalancePreviewBlocked,
          RebalancePreviewResult.fromJson,
        ).rows[0];
      } else {
        result = null;
      }

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: vm,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        result: result,
      );

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: whatIf,
        safetyState: safetyState,
        clock: clock,
      );

      if (d.previewIndex != null) {
        await tester.tap(find.byKey(const Key('s76c-preview-button')));
        await tester.pump();
        await tester.pump();
      }

      final bool hasPreview = result?.preview != null;
      final bool isBlocked = result?.blockedText != null;

      final List<Finder> chain = <Finder>[
        if (d.isStale) find.text(AnalyticsLabels.staleBannerTitle),
        if (activeFlags.isNotEmpty) find.text(activeFlags.first.label),
        if (hasPreview) find.byKey(const Key('s76c-notice')),
        if (d.isNone)
          find.byKey(const Key('s76c-empty'))
        else
          find.byKey(const Key('s76c-countdown')),
        find.byKey(const Key('s76c-asof')),
        if (!d.isNone) find.byKey(const Key('s76c-preview-button')),
        if (hasPreview) ...<Finder>[
          find.byKey(const Key('s76c-draft')),
          find.byKey(const Key('s76c-draft-asof')),
        ],
        if (isBlocked) find.byKey(const Key('s76c-blocked')),
      ];

      for (int i = 0; i < chain.length - 1; i++) {
        expect(chain[i], findsOneWidget);
        expect(chain[i + 1], findsOneWidget);
        expect(
          tester.getTopLeft(chain[i]).dy,
          lessThan(tester.getTopLeft(chain[i + 1]).dy),
        );
      }

      if (d.isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }
      if (activeFlags.isNotEmpty) {
        expect(find.text(activeFlags.first.label), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.block), findsNothing);
      }
      if (hasPreview) {
        expect(find.byKey(const Key('s76c-notice')), findsOneWidget);
        expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s76c-notice')), findsNothing);
        expect(find.byKey(const Key('s76c-draft')), findsNothing);
      }
      if (d.isNone) {
        expect(find.byKey(const Key('s76c-preview-button')), findsNothing);
        expect(find.byKey(const Key('s76c-countdown')), findsNothing);
      } else {
        expect(find.byKey(const Key('s76c-empty')), findsNothing);
      }
      if (isBlocked) {
        expect(find.byKey(const Key('s76c-blocked')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s76c-blocked')), findsNothing);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final ({String name, String vmPath, bool doTap, int? resultType}) d
      in <({String name, String vmPath, bool doTap, int? resultType})>[
        (
          name: 'countdown_no_tap',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          doTap: false,
          resultType: null,
        ),
        (
          name: 'none',
          vmPath: FixturePaths.m7M7NextRebalanceNone,
          doTap: false,
          resultType: null,
        ),
        (
          name: 'default',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          doTap: true,
          resultType: 0,
        ),
        (
          name: 'in_band',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          doTap: true,
          resultType: 1,
        ),
        (
          name: 'blocked_row1',
          vmPath: FixturePaths.m7M7NextRebalanceCountdown,
          doTap: true,
          resultType: 2,
        ),
      ]) {
    testWidgets('T76c-15 no fabricated strings ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm vm = singleFixture(
        d.vmPath,
        NextRebalanceVm.fromJson,
      );
      final RebalancePreviewResult? result;
      if (d.resultType == 0) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewDefault,
          RebalancePreviewResult.fromJson,
        );
      } else if (d.resultType == 1) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewInBand,
          RebalancePreviewResult.fromJson,
        );
      } else if (d.resultType == 2) {
        result = listFixture(
          FixturePaths.m7M7RebalancePreviewBlocked,
          RebalancePreviewResult.fromJson,
        ).rows[1];
      } else {
        result = null;
      }

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: vm,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        result: result,
      );

      await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

      if (d.doTap) {
        await tester.tap(find.byKey(const Key('s76c-preview-button')));
        await tester.pump();
        await tester.pump();
      }

      final Set<String> allowed = <String>{
        if (vm.dDayText != null) vm.dDayText!,
        if (vm.expectedDateText != null) vm.expectedDateText!,
        if (vm.kindLabel != null) vm.kindLabel!,
        if (vm.noticeText != null) vm.noticeText!,
        if (vm.emptyLabel != null) vm.emptyLabel!,
        vm.asOf.label,
        if (result?.preview case final RebalancePreview preview) ...<String>{
          preview.plannedDateText,
          preview.orderDraftsTitle,
          if (preview.ordersEmptyText != null) preview.ordersEmptyText!,
          preview.previewNotice,
          ...preview.warningLines,
          preview.asOf.label,
          for (final OrderDraft draft in preview.orderDrafts) ...<String>[
            draft.symbolLabel,
            draft.accountAlias,
            draft.sideLabel,
            draft.quantityText,
            if (draft.limitPriceText != null) draft.limitPriceText!,
            if (draft.pendingNoteText != null) draft.pendingNoteText!,
            for (final ReasonChip chip in draft.reasons) chip.label,
          ],
          AnalyticsLabels.rebalanceDraftCostsHeader,
          preview.costs.totalText,
          preview.costs.sourceLabel,
          preview.costs.basisNote,
        },
        if (result?.blockedText != null) result!.blockedText!,
        if (result?.blockedAction != null) result!.blockedAction!.label,
        if (vm.emptyLabel == null) AnalyticsLabels.rebalanceDraftButton,
      };

      final List<String?> renderedTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();

      for (final String? text in renderedTexts) {
        expect(text, isNotNull);
        expect(allowed.contains(text!), isTrue);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final ChipTone tone in ChipTone.values) {
    testWidgets('T76c-16 chip tone color ${tone.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final RebalancePreviewResult raw = singleFixture(
        FixturePaths.m7M7RebalancePreviewDefault,
        RebalancePreviewResult.fromJson,
      );
      final OrderDraft firstDraft = raw.preview!.orderDrafts.first;
      final ReasonChip firstChip = firstDraft.reasons.first;
      final RebalancePreviewResult result = raw.copyWith(
        preview: raw.preview!.copyWith(
          orderDrafts: <OrderDraft>[
            firstDraft.copyWith(
              reasons: <ReasonChip>[
                firstChip.copyWith(tone: tone),
                ...firstDraft.reasons.skip(1),
              ],
            ),
            ...raw.preview!.orderDrafts.skip(1),
          ],
        ),
      );

      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        result: result,
      );

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: whatIf,
        opener: opener,
      );
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();

      final ColorScheme colorScheme = Theme.of(
        tester.element(find.byKey(const Key('s76c-draft'))),
      ).colorScheme;

      final Color expectedColor = switch (tone) {
        ChipTone.caution => colorScheme.errorContainer,
        ChipTone.blocked => colorScheme.error,
        ChipTone.neutral => colorScheme.surfaceContainerHighest,
        ChipTone.prevented => colorScheme.surfaceContainerHighest,
      };

      final Chip chip = tester.widget<Chip>(
        find
            .descendant(
              of: find.byKey(const Key('s76c-draft')),
              matching: find.byType(Chip),
            )
            .first,
      );
      expect(chip.backgroundColor, expectedColor);
      expect(find.byType(ActionChip), findsNothing);
      expect(find.byType(InputChip), findsNothing);

      await tester.tap(
        find
            .descendant(
              of: find.byKey(const Key('s76c-draft')),
              matching: find.byType(Chip),
            )
            .first,
      );
      expect(opener.opened, isEmpty);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  test('T76c-17 file inspect', () {
    final String content = File('lib/src/screens/rebalance_preview_screen.dart')
        .readAsStringSync();
    expect(content.contains('planner'), isFalse);
    expect(
      RegExp(r'Scaffold|AppBar|SafeArea|SnackBar').hasMatch(content),
      isFalse,
    );
    expect(RegExp(r'previewRebalance').allMatches(content).length, 1);
    expect(RegExp(r'DateTime').hasMatch(content), isFalse);
    expect(Directory('lib/src/rebalance/preview').existsSync(), isFalse);
  });

  for (final ({String name, int resultType, Key expectedAreaKey}) d
      in <({String name, int resultType, Key expectedAreaKey})>[
        (
          name: 'default',
          resultType: 0,
          expectedAreaKey: const Key('s76c-draft'),
        ),
        (
          name: 'in_band',
          resultType: 1,
          expectedAreaKey: const Key('s76c-draft'),
        ),
        (
          name: 'blocked',
          resultType: 2,
          expectedAreaKey: const Key('s76c-blocked'),
        ),
      ]) {
    testWidgets('T76c-18 large font ${d.name}', (WidgetTester tester) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final RebalancePreviewResult result;
      if (d.resultType == 0) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewDefault,
          RebalancePreviewResult.fromJson,
        );
      } else if (d.resultType == 1) {
        result = singleFixture(
          FixturePaths.m7M7RebalancePreviewInBand,
          RebalancePreviewResult.fromJson,
        );
      } else {
        result = listFixture(
          FixturePaths.m7M7RebalancePreviewBlocked,
          RebalancePreviewResult.fromJson,
        ).rows[1];
      }

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi(
        result: result,
      );

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: whatIf,
        textScaler: const TextScaler.linear(2.0),
      );
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
      expect(find.byKey(d.expectedAreaKey), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }
}
