// test/performance_explore_gate_test.dart
// S7-2G 열람 게이트 단위 테스트 G1~G14.
//
// 🔴 한국어 리터럴 없음(주석도 영어·ASCII) — AnalyticsLabels 상수로 참조한다.
// 🔴 가짜는 receives 받침대 extends (explore_fakes.dart).

import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'explore_fakes.dart';
import 'golden/golden_support.dart';

void main() {
  // Load fixtures once
  final List<CommandReceipt> receipts = listFixture(
    FixturePaths.m7M7DisclosureViewReceipts4,
    CommandReceipt.fromJson,
  ).rows;

  final DisclosureGateVm gateOpen = listFixture(
    FixturePaths.m7M7DisclosureGate,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final DisclosureGateVm gateFirst = listFixture(
    FixturePaths.m7M7DisclosureGateFirst,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final DisclosureGateVm gateClosed = listFixture(
    FixturePaths.m7M7DisclosureGateClosed,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final SafetyState safetyRow3 = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[3],
  );

  // ── G1 ────────────────────────────────────────────────────────────────────
  // Pump with open gate: headline/viewCountText/frictionLine present,
  // two buttons, no chart key, no record-line, no series call, no command.
  testWidgets('G1 open gate shows headline count friction 2 buttons', (
    WidgetTester tester,
  ) async {
    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi();
    final opener = RecordingLinkOpener();

    await pumpExplore(tester, repo: repo, commandApi: api, opener: opener);

    // Positive anchor
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // Fixture text present
    expect(find.text(gateOpen.headline), findsOneWidget);
    expect(find.text(gateOpen.viewCountText), findsOneWidget);
    expect(find.text(gateOpen.frictionLine!), findsOneWidget);

    // Two buttons
    expect(find.byKey(const Key('s72g-back')), findsOneWidget);
    expect(find.byKey(const Key('s72g-continue')), findsOneWidget);

    // Chart key absent (R10c will add it)
    expect(find.byKey(const Key('s72-chart')), findsNothing);

    // Record line absent (gate state)
    expect(find.byKey(const Key('s72-record-line')), findsNothing);

    // No series call, no command call
    expect(repo.seriesCalls, isEmpty);
    expect(api.recordedEvents, isEmpty);
  });

  // ── G2 ────────────────────────────────────────────────────────────────────
  // "Back" button opens AppNavActions.back, no command, no series.
  testWidgets('G2 back: opens AppNavActions.back, no command', (
    WidgetTester tester,
  ) async {
    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi();
    final opener = RecordingLinkOpener();

    await pumpExplore(tester, repo: repo, commandApi: api, opener: opener);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tester.tap(find.byKey(const Key('s72g-back')));
    await tester.pump();

    expect(opener.opened, <String>[AppNavActions.back]);
    expect(api.recordedEvents, isEmpty);
    expect(repo.seriesCalls, isEmpty);
  });

  // ── G3 ────────────────────────────────────────────────────────────────────
  // "Continue" with receipt row 0: command 1, surfaceCode correct, viewedAt,
  // durationSec 0, record-line shows, series 1, watchCommand id matches,
  // no link opened.
  testWidgets('G3 continue: command recorded, enters explore body', (
    WidgetTester tester,
  ) async {
    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi(
      recordFn: (_) => Future<CommandReceipt>.value(receipts[0]),
      watchFn: (_) => Stream<CommandReceipt>.value(receipts[0]),
    );
    final opener = RecordingLinkOpener();

    await pumpExplore(
      tester,
      repo: repo,
      commandApi: api,
      opener: opener,
      clock: FixedClock(kGoldenNowUtc),
    );

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();

    // Command called once
    expect(api.recordedEvents.length, 1);
    final DisclosureViewEvent event = api.recordedEvents[0];
    expect(event.surfaceCode, DisclosureSurfaceCodes.performanceExplore);
    expect(event.viewedAt, kGoldenNowUtc);
    expect(event.durationSec, 0);

    // Record line visible
    expect(find.byKey(const Key('s72-record-line')), findsOneWidget);
    expect(find.text(receipts[0].stateLabel), findsOneWidget);

    // Series called once
    expect(repo.seriesCalls.length, 1);
    expect(repo.seriesCalls, <
      ({
        PerfMetric metric,
        PerfGranularity granularity,
        bool cumulative,
        DateRange? range,
      })
    >[
      (
        metric: PerfMetric.twr,
        granularity: PerfGranularity.monthly,
        cumulative: true,
        range: null,
      ),
    ]);

    // watchCommand received correct id
    expect(api.watchedIds, <String>[receipts[0].commandId]);

    // No link opened by continue
    expect(opener.opened, isEmpty);
  });

  // ── G4 ────────────────────────────────────────────────────────────────────
  // Command in flight (Completer): continue disabled, back still works,
  // second tap => still only 1 command. Unmount before completer => no error.
  testWidgets('G4 submitting: continue disabled, back works, no double-call', (
    WidgetTester tester,
  ) async {
    final completer = Completer<CommandReceipt>();
    addTearDown(() async {
      if (!completer.isCompleted) completer.complete(receipts[0]);
    });

    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi(
      recordFn: (_) => completer.future,
      watchFn: (_) => Stream<CommandReceipt>.value(receipts[0]),
    );
    final opener = RecordingLinkOpener();

    await pumpExplore(tester, repo: repo, commandApi: api, opener: opener);

    // Tap continue to start the inflight command
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();

    // Continue button is now disabled
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('s72g-continue')))
          .onPressed,
      isNull,
    );

    // Second tap => still only 1 command
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    expect(api.recordedEvents.length, 1);

    // Back is still active
    await tester.tap(find.byKey(const Key('s72g-back')));
    await tester.pump();
    expect(opener.opened.length, 1);
    expect(opener.opened[0], AppNavActions.back);

    // Unmount before completer finishes => no exception
    await tester.pumpWidget(const SizedBox());
    completer.complete(receipts[0]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // ── G5 ────────────────────────────────────────────────────────────────────
  // Command throws: stays on gate, record-not-accepted visible, exception
  // reported; retry with success => label gone, enters body.
  testWidgets('G5 command error: gate, not-accepted, then retry succeeds', (
    WidgetTester tester,
  ) async {
    bool shouldFail = true;
    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi(
      recordFn: (_) {
        if (shouldFail) return Future<CommandReceipt>.error(Exception('oops'));
        return Future<CommandReceipt>.value(receipts[0]);
      },
      watchFn: (_) => Stream<CommandReceipt>.value(receipts[0]),
    );

    await pumpExplore(tester, repo: repo, commandApi: api);

    // First tap fails
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();

    // Still on gate
    expect(find.byKey(const Key('s72g-card')), findsOneWidget);

    // record-not-accepted shown
    expect(find.byKey(const Key('s72g-record-not-accepted')), findsOneWidget);

    // Exception reported
    expect(tester.takeException(), isNotNull);

    // No series yet
    expect(repo.seriesCalls, isEmpty);

    // F12: Check layout and labels during not-accepted state before retry
    expect(find.text(gateOpen.asOf.label), findsOneWidget);
    expect(find.text(gateOpen.route!), findsNothing);
    expect(find.text(AnalyticsLabels.recordNotAccepted), findsOneWidget);
    final Finder line = find.byKey(const Key('s72g-record-not-accepted'));
    expect(
      find.descendant(of: find.byType(SnackBar), matching: line),
      findsNothing,
    );
    expect(
      tester.getBottomLeft(find.byKey(const Key('s72g-card'))).dy,
      lessThan(tester.getTopLeft(line).dy),
    );
    expect(
      tester.getTopLeft(line).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('s72g-back'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('s72g-back'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const Key('s72g-continue'))).dx),
    );
    expect(
      tester.getSize(find.byKey(const Key('s72g-back'))),
      tester.getSize(find.byKey(const Key('s72g-continue'))),
    );

    // Second tap succeeds
    shouldFail = false;
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();

    // record-not-accepted gone
    expect(find.byKey(const Key('s72g-record-not-accepted')), findsNothing);

    // 2 total commands
    expect(api.recordedEvents.length, 2);

    // Now in explore body
    expect(find.byKey(const Key('s72-record-line')), findsOneWidget);
  });

  // ── G5b ───────────────────────────────────────────────────────────────────
  // F11: not-accepted line clears as soon as the next submit starts.
  testWidgets(
    'G5b not-accepted line clears as soon as the next submit starts',
    (WidgetTester tester) async {
      final completer = Completer<CommandReceipt>();
      int callCount = 0;
      final repo = FakePerformanceRepository(
        gateStream: Stream<DisclosureGateVm>.value(gateOpen),
      );
      final api = FakeCommandApi(
        recordFn: (_) {
          callCount++;
          if (callCount == 1) {
            return Future<CommandReceipt>.error(Exception('first-fail'));
          }
          return completer.future;
        },
      );

      await pumpExplore(tester, repo: repo, commandApi: api);

      // First tap fails
      await tester.tap(find.byKey(const Key('s72g-continue')));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNotNull);
      expect(find.byKey(const Key('s72g-record-not-accepted')), findsOneWidget);

      // Second tap starts in-flight submit
      await tester.tap(find.byKey(const Key('s72g-continue')));
      await tester.pump();

      // Clears immediately upon next submit starting
      expect(find.byKey(const Key('s72g-record-not-accepted')), findsNothing);
      expect(find.byKey(const Key('s72g-card')), findsOneWidget);

      // Unmount before complete
      await tester.pumpWidget(const SizedBox());
      completer.complete(receipts[0]);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  // ── G6 ────────────────────────────────────────────────────────────────────
  // Each receipt row (0-3) shows stateLabel in record line.
  // F7: FakeCommandApi default watchCommand returns recorded receipt, so watchFn is not needed.
  for (int i = 0; i < 4; i++) {
    testWidgets('G6 receipt row $i: stateLabel shown in record-line', (
      WidgetTester tester,
    ) async {
      final receipt = receipts[i];
      final repo = FakePerformanceRepository(
        gateStream: Stream<DisclosureGateVm>.value(gateOpen),
      );
      final api = FakeCommandApi(
        recordFn: (_) => Future<CommandReceipt>.value(receipt),
      );
      final opener = RecordingLinkOpener();

      await pumpExplore(tester, repo: repo, commandApi: api, opener: opener);

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      await tester.tap(find.byKey(const Key('s72g-continue')));
      await tester.pump();
      await tester.pump();

      // In explore body
      expect(find.byKey(const Key('s72-record-line')), findsOneWidget);
      expect(find.text(receipt.stateLabel), findsOneWidget);

      // No link opened
      expect(opener.opened, isEmpty);
    });
  }

  // ── G7 ────────────────────────────────────────────────────────────────────
  // watchCommand stream updates: label changes; error keeps last label.
  testWidgets('G7 watchCommand updates and error keeps last label', (
    WidgetTester tester,
  ) async {
    final controller = StreamController<CommandReceipt>();
    addTearDown(() {
      unawaited(controller.close());
    });

    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi(
      recordFn: (_) => Future<CommandReceipt>.value(receipts[0]),
      watchFn: (_) => controller.stream,
    );

    await pumpExplore(tester, repo: repo, commandApi: api);

    // Enter explore body
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();

    // Push row 0 first
    controller.add(receipts[0]);
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(find.text(receipts[0].stateLabel), findsOneWidget);

    // Update to row 1
    controller.add(receipts[1]);
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(find.text(receipts[1].stateLabel), findsOneWidget);

    // Stream error: keep last label
    controller.addError(Exception('stream-err'));
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(find.text(receipts[1].stateLabel), findsOneWidget);

    // Exception is consumed by FlutterError.reportError
    expect(tester.takeException(), isNotNull);
  });

  // ── G8 ────────────────────────────────────────────────────────────────────
  // Closed gate: no continue button, back full-width (== card width), no cmd.
  testWidgets('G8 closed gate: no continue, back full-width', (
    WidgetTester tester,
  ) async {
    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateClosed),
    );
    final api = FakeCommandApi();

    await pumpExplore(tester, repo: repo, commandApi: api);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // No continue button
    expect(find.byKey(const Key('s72g-continue')), findsNothing);

    // Back button present
    expect(find.byKey(const Key('s72g-back')), findsOneWidget);

    // Headline visible
    expect(find.text(gateClosed.headline), findsOneWidget);

    // No command
    expect(api.recordedEvents, isEmpty);

    // Back button width equals card width
    final double backWidth = tester
        .getSize(find.byKey(const Key('s72g-back')))
        .width;
    final double cardWidth = tester
        .getSize(find.byKey(const Key('s72g-card')))
        .width;
    expect(backWidth, cardWidth);
  });

  // ── G9 ────────────────────────────────────────────────────────────────────
  // First-time gate: no frictionLine, viewCountText present.
  testWidgets('G9 first-time gate: no friction, viewCountText shown', (
    WidgetTester tester,
  ) async {
    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateFirst),
    );
    final api = FakeCommandApi();

    await pumpExplore(tester, repo: repo, commandApi: api);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    expect(find.byKey(const Key('s72g-friction')), findsNothing);
    expect(find.text(gateFirst.viewCountText), findsOneWidget);
  });

  // ── G10 ───────────────────────────────────────────────────────────────────
  // After passing, unmount and re-mount: gate shown again; pass again => 2 cmds.
  // F7: Single fake with gateStreamFactory used across both mounts.
  testWidgets('G10 re-mount always shows gate first', (
    WidgetTester tester,
  ) async {
    final repo = FakePerformanceRepository(
      gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi(
      recordFn: (_) => Future<CommandReceipt>.value(receipts[0]),
    );

    // First mount + pass
    await pumpExplore(tester, repo: repo, commandApi: api);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('s72-record-line')), findsOneWidget);

    // Unmount
    await tester.pumpWidget(const SizedBox());

    // Re-mount with the same fake repo (uses gateStreamFactory)
    await pumpExplore(tester, repo: repo, commandApi: api);

    // Gate shown again
    expect(find.byKey(const Key('s72g-card')), findsOneWidget);
    expect(find.byKey(const Key('s72-record-line')), findsNothing);

    // Pass again
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();
    expect(api.recordedEvents.length, 2);
    expect(repo.watchDisclosureGateCalls, 2);
  });

  // ── G10b ──────────────────────────────────────────────────────────────────
  // F10: same ProviderContainer: leaving and coming back shows the gate again
  testWidgets(
    'G10b same ProviderContainer: leaving and coming back shows the gate again',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
      );
      final api = FakeCommandApi(
        recordFn: (_) => Future<CommandReceipt>.value(receipts[0]),
      );

      final container = ProviderContainer(
        overrides: exploreOverrides(repo: repo, commandApi: api),
      );
      addTearDown(container.dispose);

      Widget app(bool show) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: show ? const PerformanceExploreScreen() : const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(app(true));
      await tester.pump();
      await tester.tap(find.byKey(const Key('s72g-continue')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('s72-record-line')), findsOneWidget);

      await tester.pumpWidget(app(false));
      await tester.pumpWidget(app(true));
      await tester.pump();

      expect(find.byKey(const Key('s72g-card')), findsOneWidget);
      expect(find.byKey(const Key('s72-record-line')), findsNothing);
    },
  );

  // ── G11 ───────────────────────────────────────────────────────────────────
  // Loading / error states: skeleton or retryButton shown; both with
  // stale+3d safety-row3 => no banners during loading/error.
  // F6, F9: Full-width back check, blocking list iteration with precondition.
  testWidgets('G11 loading: skeleton back no continue; error: retry back', (
    WidgetTester tester,
  ) async {
    final List<BlockFlag> blocking = safetyRow3.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(
      blocking,
      hasLength(2),
    ); // precondition — row 3 = RECON_MISMATCH · JOURNAL_MISSING

    final staleController = StreamController<DisclosureGateVm>();
    addTearDown(() {
      unawaited(staleController.close());
    });

    final repo = FakePerformanceRepository(gateStream: staleController.stream);
    final api = FakeCommandApi();

    await pumpExplore(
      tester,
      repo: repo,
      commandApi: api,
      safetyState: safetyRow3,
      clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 3))),
    );

    // Loading state
    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byKey(const Key('s72g-back')), findsOneWidget);
    expect(find.byKey(const Key('s72g-continue')), findsNothing);
    expect(
      tester.widget<AnalyticsSkeleton>(find.byType(AnalyticsSkeleton)).blocks,
      2,
    );
    expect(
      tester.getSize(find.byKey(const Key('s72g-back'))).width,
      tester.getSize(find.byType(AnalyticsSkeleton)).width,
    );

    // No banners in loading (values not arrived yet)
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
    for (final BlockFlag flag in blocking) {
      expect(find.text(flag.label), findsNothing);
    }

    // Emit error
    staleController.addError(Exception('gate-error'));
    await tester.pump(Duration.zero);
    await tester.pump();

    expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
    expect(find.byKey(const Key('s72g-back')), findsOneWidget);
    expect(find.byKey(const Key('s72g-continue')), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('s72g-back'))).width,
      tester.getSize(find.byType(AnalyticsErrorView)).width,
    );

    // Still no banners in error (still no data)
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
    for (final BlockFlag flag in blocking) {
      expect(find.text(flag.label), findsNothing);
    }
  });

  // ── G11c ──────────────────────────────────────────────────────────────────
  // F9: error after a value: no banners, last asOf label, retry resubscribes
  testWidgets(
    'G11c error after a value: no banners, last asOf label, retry resubscribes',
    (WidgetTester tester) async {
      final List<BlockFlag> blocking = safetyRow3.activeFlags
          .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
          .toList();
      expect(blocking, hasLength(2));

      final StreamController<DisclosureGateVm> c =
          StreamController<DisclosureGateVm>.broadcast();
      addTearDown(() {
        unawaited(c.close());
      });

      final repo = FakePerformanceRepository(gateStreamFactory: () => c.stream);
      final api = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: api,
        safetyState: safetyRow3,
        clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 3))),
      );

      c.add(gateOpen);
      await tester.pump(Duration.zero);
      await tester.pump();
      expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);

      c.addError(Exception('gate-error'));
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
      expect(find.text(gateOpen.asOf.label), findsOneWidget);
      expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      for (final BlockFlag flag in blocking) {
        expect(find.text(flag.label), findsNothing);
      }
      expect(repo.watchDisclosureGateCalls, 1);

      await tester.tap(find.text(AnalyticsLabels.retryButton));
      await tester.pump();
      expect(repo.watchDisclosureGateCalls, 2);
    },
  );

  // ── G12 ───────────────────────────────────────────────────────────────────
  // After passing, a new closed gate value arrives: explore body is unchanged.
  testWidgets('G12 gate stream update after passing: body stays', (
    WidgetTester tester,
  ) async {
    final controller = StreamController<DisclosureGateVm>();
    addTearDown(() {
      unawaited(controller.close());
    });

    final repo = FakePerformanceRepository(gateStream: controller.stream);
    final api = FakeCommandApi(
      recordFn: (_) => Future<CommandReceipt>.value(receipts[0]),
      watchFn: (_) => Stream<CommandReceipt>.value(receipts[0]),
    );

    await pumpExplore(tester, repo: repo, commandApi: api);

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // Emit open gate
    controller.add(gateOpen);
    await tester.pump(Duration.zero);
    await tester.pump();

    // Pass gate
    await tester.tap(find.byKey(const Key('s72g-continue')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('s72-record-line')), findsOneWidget);

    // Emit closed gate while in explore body
    controller.add(gateClosed);
    await tester.pump(Duration.zero);
    await tester.pump();

    // Still in explore body
    expect(find.byKey(const Key('s72-record-line')), findsOneWidget);
    expect(find.byKey(const Key('s72g-card')), findsNothing);
  });

  // ── G13 ───────────────────────────────────────────────────────────────────
  // Barrel keeps each of the 7 R10 paths exactly once, and exports nothing
  // from the internal folders (planner, chart, explore, goal_path).
  // Contract v1.4 (design D15, M2 PR): the exact-set check moved out of this
  // file so the R11 cards can add exports without editing it. Exact set
  // ownership: R11a T74-22 (planner.dart) and R11b T79-14 (barrel == 8).
  // This is an ownership transfer, not a weaker assertion.
  testWidgets('G13 barrel keeps the 7 paths and no internal folders', (
    WidgetTester tester,
  ) async {
    final String content = File('lib/ui_analytics.dart').readAsStringSync();
    final List<String> exportPaths = RegExp(
      r"^export '([^']+)';",
      multiLine: true,
    ).allMatches(content).map((m) => m.group(1)!).toList();

    expect(exportPaths, hasLength(greaterThanOrEqualTo(7)));
    for (final String path in const <String>[
      'l10n/labels.dart',
      'src/providers/analytics_providers.dart',
      'src/screens/contribution_screen.dart',
      'src/screens/drawdown_context_screen.dart',
      'src/screens/monthly_report_screen.dart',
      'src/screens/performance_explore_screen.dart',
      'src/screens/report_archive_screen.dart',
    ]) {
      expect(
        exportPaths.where((String p) => p == path),
        hasLength(1),
        reason: 'barrel must export $path exactly once',
      );
    }
    for (final String internal in const <String>[
      'src/planner',
      'src/chart/',
      'src/screens/explore/',
      'src/goal_path/',
    ]) {
      expect(
        exportPaths.where((String p) => p.startsWith(internal)),
        isEmpty,
        reason: 'barrel must not export anything under $internal',
      );
    }
  });

  // ── G14 ───────────────────────────────────────────────────────────────────
  // Stale +3 days shows staleBannerTitle; safetyRow3 shows flag labels
  // above card dy.
  // F6: Precondition expect, target list iteration, stale above safety check.
  testWidgets('G14 stale and safety banners shown above card', (
    WidgetTester tester,
  ) async {
    final List<BlockFlag> blocking = safetyRow3.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(
      blocking,
      hasLength(2),
    ); // precondition — row 3 = RECON_MISMATCH · JOURNAL_MISSING

    final repo = FakePerformanceRepository(
      gateStream: Stream<DisclosureGateVm>.value(gateOpen),
    );
    final api = FakeCommandApi();

    await pumpExplore(
      tester,
      repo: repo,
      commandApi: api,
      safetyState: safetyRow3,
      clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 3))),
    );

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // Stale banner shown
    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);

    // Stale sits above safety
    expect(
      tester.getTopLeft(find.text(AnalyticsLabels.staleBannerTitle)).dy,
      lessThan(tester.getTopLeft(find.text(blocking.first.label)).dy),
    );

    // Blocking flag labels shown
    for (final BlockFlag flag in blocking) {
      expect(find.text(flag.label), findsOneWidget);

      // Flag dy < card dy
      final double flagDy = tester.getTopLeft(find.text(flag.label)).dy;
      final double cardDy = tester
          .getTopLeft(find.byKey(const Key('s72g-card')))
          .dy;
      expect(flagDy, lessThan(cardDy));
    }
  });
}
