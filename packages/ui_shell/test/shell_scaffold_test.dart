// test/shell_scaffold_test.dart — TS-01 ~ TS-09
//
// 셸 화면 테스트 — ⓡ 8줄(TS-01·02·03·04·05·07·08·09) · ⓗ 0줄.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

void main() {
  // ── TS-01 탭 5 · 이름 · 제목 ───────────────────────────────────────────────
  testWidgets('TS-01 tabs 5 names and titles', (WidgetTester tester) async {
    final ListResult<AlertItem> digest = listFixture(
      FixturePaths.m8AlertsDigest,
      AlertItem.fromJson,
    );
    final FakeShellConfigRepository config = flagsOf(kFlagsLiveAuto);
    final FakeShellAlertRepository alerts = alertsOf(digest.rows);
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.androidOperator,
        config: config,
        alerts: alerts,
        bodies: dummyBodies(AppRoutes.all, <String>[]),
      ),
    );
    expect(
      tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .map((NavigationDestination d) => d.label)
          .toList(),
      <String>[
        ShellLabels.tabHome,
        ShellLabels.tabJournal,
        ShellLabels.tabHoldings,
        ShellLabels.tabPlan,
        ShellLabels.tabMore,
      ],
    );
    final List<String> labels = <String>[
      ShellLabels.tabHome,
      ShellLabels.tabJournal,
      ShellLabels.tabHoldings,
      ShellLabels.tabPlan,
      ShellLabels.tabMore,
    ];
    for (final String label in labels) {
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('s01-tabs')),
          matching: find.text(label),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
        label,
      );
      if (label == ShellLabels.tabHome) {
        expect(find.byKey(const Key('s01-home-slot')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s01-home-slot')), findsNothing);
      }
    }
    expect(config.calls, 1);
    expect(alerts.mins, <AlertLevel?>[null]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── TS-02 탭 배지 = P0 미확인 점 ─────────────────────────────────────────
  group('TS-02 tab badge p0', () {
    final ListResult<AlertItem> alerts12 = listFixture(
      FixturePaths.alerts12,
      AlertItem.fromJson,
    );
    final ListResult<AlertItem> p0Ack = listFixture(
      FixturePaths.m8AlertsP0Ack,
      AlertItem.fromJson,
    );
    final ListResult<AlertItem> digest = listFixture(
      FixturePaths.m8AlertsDigest,
      AlertItem.fromJson,
    );

    final List<
      ({String name, FeatureFlags flags, List<AlertItem> alerts, bool want})
    >
    cases =
        <
          ({String name, FeatureFlags flags, List<AlertItem> alerts, bool want})
        >[
          (
            name: 'p0_unacked',
            flags: kFlagsLiveAuto,
            alerts: alerts12.rows,
            want: true,
          ),
          (
            name: 'p0_unacked_advisory',
            flags: kFlagsLiveAdvisory,
            alerts: alerts12.rows,
            want: true,
          ),
          (
            name: 'p0_mixed',
            flags: kFlagsLiveAuto,
            alerts: p0Ack.rows,
            want: true,
          ),
          (
            name: 'p0_acked_only',
            flags: kFlagsLiveAuto,
            alerts: <AlertItem>[p0Ack.rows[1]],
            want: false,
          ),
          (
            name: 'p1_only',
            flags: kFlagsLiveAuto,
            alerts: <AlertItem>[alerts12.rows[3]],
            want: false,
          ),
          (
            name: 'p2_digest',
            flags: kFlagsLiveAuto,
            alerts: digest.rows,
            want: false,
          ),
        ];

    for (final c in cases) {
      testWidgets('TS-02 ${c.name}', (WidgetTester tester) async {
        // 전제 (if 밖)
        expect(p0Ack.rows[1].level, AlertLevel.p0); // pre
        expect(p0Ack.rows[1].ack?.acked, isTrue); // pre
        expect(alerts12.rows[3].level, AlertLevel.p1); // pre
        expect(alerts12.rows[3].ack?.acked, isNot(isTrue)); // pre
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(c.flags),
            alerts: alertsOf(c.alerts),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
          ),
        );
        expect(
          find.byKey(const Key('s01-p0-dot')),
          c.want ? findsOneWidget : findsNothing,
        );
        expect(find.byType(Badge), c.want ? findsOneWidget : findsNothing);
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }

    // 점 = 수 없음 — Badge.label null(C4r13a-3 · 배지 수 변이 S06 을 위젯 테스트로)
    testWidgets('TS-02 p0 dot has no count label', (WidgetTester tester) async {
      await pumpShell(
        tester,
        overrides: shellOverrides(
          platform: ShellPlatform.androidOperator,
          config: flagsOf(kFlagsLiveAuto),
          alerts: alertsOf(alerts12.rows),
          bodies: dummyBodies(AppRoutes.all, <String>[]),
        ),
      );
      expect(find.byKey(const Key('s01-p0-dot')), findsOneWidget);
      expect(
        tester.widget<Badge>(find.byKey(const Key('s01-p0-dot'))).label,
        isNull,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('s01-p0-dot')),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  });

  // ── TS-03 탭 전환 = 상태 보존 + 홈 칸 ────────────────────────────────────
  group('TS-03 tab switch state preservation', () {
    final List<({String name, FeatureFlags flags, List<String> first})> cases =
        <({String name, FeatureFlags flags, List<String> first})>[
          (
            name: 'auto',
            flags: kFlagsLiveAuto,
            first: <String>[
              kHomeTag,
              AppRoutes.journalTimeline,
              AppRoutes.holdingsOverview,
            ],
          ),
          (
            name: 'advisory',
            flags: kFlagsLiveAdvisory,
            first: <String>[
              kHomeTag,
              AppRoutes.adviceInbox,
              AppRoutes.journalTimeline,
              AppRoutes.holdingsOverview,
            ],
          ),
        ];

    for (final c in cases) {
      testWidgets('TS-03 ${c.name}', (WidgetTester tester) async {
        final List<String> log = <String>[];
        final ShellRouteBodies bodies = ShellRouteBodies(
          dummyBodies(AppRoutes.all, log).byPattern,
          home: (BuildContext ctx) => DummyBody(
            tag: kHomeTag,
            params: const <String, String>{},
            log: log,
          ),
        );
        await pumpShell(
          tester,
          overrides: <Override>[
            shellPlatformProvider.overrideWithValue(
              ShellPlatform.androidOperator,
            ),
            shellConfigRepositoryProvider.overrideWithValue(flagsOf(c.flags)),
            shellAlertRepositoryProvider.overrideWithValue(
              alertsOf(const <AlertItem>[]),
            ),
            shellRouteBodiesProvider.overrideWithValue(bodies),
            shellClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            shellOpsSummaryRepositoryProvider.overrideWithValue(
              UnimplementedOpsSummaryRepository(),
            ),
          ],
        );
        expect(log, c.first);
        expect(dummyOf(kHomeTag), findsOneWidget);
        expect(find.byKey(const Key('s01-home-slot')), findsNothing);

        // 탭 2 · 1 · 0 · 2 차례로
        for (final int i in <int>[2, 1, 0, 2]) {
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('s01-tabs')),
              matching: find.text(
                <String>[
                  ShellLabels.tabHome,
                  ShellLabels.tabJournal,
                  ShellLabels.tabHoldings,
                  ShellLabels.tabPlan,
                  ShellLabels.tabMore,
                ][i],
              ),
            ),
          );
          await tester.pump();
        }
        expect(log, c.first);
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }

    // iosViewer = 폰 셸 · 보유 탭 = 보유 본문(C4r13a-3 · X03)
    testWidgets('TS-03 ios viewer', (WidgetTester tester) async {
      final List<String> log = <String>[];
      final ShellRouteBodies bodies = ShellRouteBodies(
        dummyBodies(AppRoutes.all, log).byPattern,
        home: (BuildContext ctx) => DummyBody(
          tag: kHomeTag,
          params: const <String, String>{},
          log: log,
        ),
      );
      await pumpShell(
        tester,
        overrides: shellOverrides(
          platform: ShellPlatform.iosViewer,
          config: flagsOf(kFlagsLiveAuto),
          alerts: alertsOf(const <AlertItem>[]),
          bodies: bodies,
        ),
      );
      expect(log, <String>[
        kHomeTag,
        AppRoutes.journalTimeline,
        AppRoutes.holdingsOverview,
      ]);
      expect(dummyOf(kHomeTag), findsOneWidget);
      expect(dummyOf(AppRoutes.holdingsOverview), findsNothing);

      // 보유 탭 → 보유 본문 · 가드 글자 0
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('s01-tabs')),
          matching: find.text(ShellLabels.tabHoldings),
        ),
      );
      await tester.pump();
      expect(dummyOf(AppRoutes.holdingsOverview), findsOneWidget);
      expect(find.byKey(const Key('s01-guard')), findsNothing);
      expect(log, <String>[
        kHomeTag,
        AppRoutes.journalTimeline,
        AppRoutes.holdingsOverview,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  });

  // ── TS-04 일지 세그먼트 ────────────────────────────────────────────────────
  group('TS-04 journal segment', () {
    final List<
      ({
        String name,
        FeatureFlags flags,
        bool advisory,
        Future<void> Function(WidgetTester t) steps,
      })
    >
    cases =
        <
          ({
            String name,
            FeatureFlags flags,
            bool advisory,
            Future<void> Function(WidgetTester t) steps,
          })
        >[
          (
            name: 'advisory',
            flags: kFlagsLiveAdvisory,
            advisory: true,
            steps: (WidgetTester t) async {
              expect(
                t
                    .widget<SegmentedButton<int>>(
                      find.byKey(const Key('s01-segment')),
                    )
                    .selected,
                <int>{0},
              );
              expect(dummyOf(AppRoutes.adviceInbox), findsOneWidget);
              expect(dummyOf(AppRoutes.journalTimeline), findsNothing);
              await t.tap(find.text(ShellLabels.segmentRecord));
              await t.pump();
              expect(dummyOf(AppRoutes.journalTimeline), findsOneWidget);
            },
          ),
          (
            name: 'auto',
            flags: kFlagsLiveAuto,
            advisory: false,
            steps: (WidgetTester t) async {
              expect(dummyOf(AppRoutes.journalTimeline), findsOneWidget);
              expect(dummyOf(AppRoutes.adviceInbox), findsNothing);
              expect(find.text(ShellLabels.segmentAdvice), findsNothing);
            },
          ),
        ];

    for (final c in cases) {
      testWidgets('TS-04 ${c.name}', (WidgetTester tester) async {
        final List<String> log = <String>[];
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(c.flags),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, log),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('s01-tabs')),
            matching: find.text(ShellLabels.tabJournal),
          ),
        );
        await tester.pump();
        expect(
          find.byKey(const Key('s01-segment')),
          c.advisory ? findsOneWidget : findsNothing,
        );
        await c.steps(tester);
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }
  });

  // ── TS-05 띠·접두 4조합 + 증권사 모의 ───────────────────────────────────
  group('TS-05 band prefix combos', () {
    final List<({String name, FeatureFlags flags, List<String> want})> cases =
        <({String name, FeatureFlags flags, List<String> want})>[
          (name: 'live_auto', flags: kFlagsLiveAuto, want: const <String>[]),
          (
            name: 'sim_auto',
            flags: kFlagsSimAuto,
            want: const <String>[ShellLabels.simPrefix],
          ),
          (
            name: 'sim_broker_auto',
            flags: kFlagsBrokerAuto,
            want: const <String>[ShellLabels.simPrefix],
          ),
          (
            name: 'live_advisory',
            flags: kFlagsLiveAdvisory,
            want: const <String>[ShellLabels.advisoryPrefix],
          ),
          (
            name: 'sim_advisory',
            flags: kFlagsSimAdvisory,
            want: const <String>[
              ShellLabels.simPrefix,
              ShellLabels.advisoryPrefix,
            ],
          ),
        ];

    for (final c in cases) {
      testWidgets('TS-05 ${c.name}', (WidgetTester tester) async {
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(c.flags),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
          ),
        );
        expect(
          find.byKey(const Key('s01-band')),
          c.want.isEmpty ? findsNothing : findsOneWidget,
        );
        expect(shownTexts(tester, find.byKey(const Key('s01-band'))), c.want);
        expect(
          tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
          <String>[
            ...c.want,
            ShellLabels.tabHome,
          ].join(ShellLabels.prefixSeparator),
        );
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }
  });

  // ── TS-06 플래그 갈래 ──────────────────────────────────────────────────────
  group('TS-06 flags branches', () {
    final List<
      ({
        String name,
        FakeShellConfigRepository Function() configFactory,
        bool skeleton,
        bool error,
        bool shell,
        Future<void> Function(WidgetTester, FakeShellConfigRepository) flow,
      })
    >
    cases =
        <
          ({
            String name,
            FakeShellConfigRepository Function() configFactory,
            bool skeleton,
            bool error,
            bool shell,
            Future<void> Function(WidgetTester, FakeShellConfigRepository) flow,
          })
        >[
          (
            name: 'loading',
            configFactory: () {
              final StreamController<FeatureFlags> ctrl =
                  StreamController<FeatureFlags>();
              addTearDown(() {
                unawaited(ctrl.close());
              });
              return FakeShellConfigRepository(
                flags: (int call) => ctrl.stream,
              );
            },
            skeleton: true,
            error: false,
            shell: false,
            flow: (WidgetTester t, FakeShellConfigRepository cfg) async {
              expect(t.getTopLeft(find.byType(ShellRoot)).dy, 0.0);
            },
          ),
          (
            name: 'fail',
            configFactory: () => FakeShellConfigRepository(
              flags: (int call) => call == 0
                  ? Stream<FeatureFlags>.error(StateError('fail'))
                  : Stream<FeatureFlags>.value(kFlagsLiveAuto),
            ),
            skeleton: false,
            error: true,
            shell: false,
            flow: (WidgetTester t, FakeShellConfigRepository cfg) async {
              expect(t.getTopLeft(find.byType(ShellRoot)).dy, 0.0);
              await t.tap(find.text(ShellLabels.retry));
              await t.pump();
              await t.pump();
              expect(find.byKey(const Key('s01-tabs')), findsOneWidget);
              expect(cfg.calls, 2);
            },
          ),
          (
            name: 'normal',
            configFactory: () => flagsOf(kFlagsLiveAuto),
            skeleton: false,
            error: false,
            shell: true,
            flow: (WidgetTester t, FakeShellConfigRepository cfg) async {
              expect(t.getTopLeft(find.byType(ShellRoot)).dy, 0.0);
            },
          ),
          (
            name: 'value_then_fail',
            configFactory: () => FakeShellConfigRepository(
              flags: (int call) => valueThenFail(kFlagsSimAuto),
            ),
            skeleton: false,
            error: false,
            shell: true,
            flow: (WidgetTester t, FakeShellConfigRepository cfg) async {
              expect(find.text(ShellLabels.simPrefix), findsOneWidget);
              expect(find.byType(CircularProgressIndicator), findsNothing);
              expect(find.byType(LinearProgressIndicator), findsNothing);
            },
          ),
        ];

    for (final c in cases) {
      testWidgets('TS-06 ${c.name}', (WidgetTester tester) async {
        final FakeShellConfigRepository config = c.configFactory();
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: config,
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
          ),
        );

        expect(
          find.byKey(const Key('s01-loading')),
          c.skeleton ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('s01-fail')),
          c.error ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('s01-tabs')),
          c.shell ? findsOneWidget : findsNothing,
        );

        await c.flow(tester, config);
      });
    }
  });

  // ── TS-07 S-02 웹 사이드바 ────────────────────────────────────────────────
  testWidgets('TS-07 web sidebar S-02', (WidgetTester tester) async {
    final List<String> log = <String>[];
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.web,
        config: flagsOf(kFlagsSimAdvisory),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, log),
      ),
      size: const Size(1280, 800),
    );
    expect(shownTexts(tester, find.byKey(const Key('s02-sidebar'))), <String>[
      ShellLabels.viewOnly,
      ShellLabels.simPrefix,
      ShellLabels.advisoryPrefix,
      ShellLabels.sideHome,
      ShellLabels.sideJournal,
      ShellLabels.sideHoldings,
      ShellLabels.sideReports,
      ShellLabels.sideHandbook,
    ]);
    expect(find.byKey(const ValueKey<String>('s02-item-5')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('s02-view-only'))), <String>[
      ShellLabels.viewOnly,
    ]);
    expect(
      shownTexts(tester, find.byKey(const Key('s02-mode-chips'))),
      <String>[ShellLabels.simPrefix, ShellLabels.advisoryPrefix],
    );
    expect(find.byKey(const Key('s02-kill-slot')), findsOneWidget);
    expect(find.byKey(const Key('s01-tabs')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);

    // 사이드바 탭 1 => webAbsent
    await tester.tap(find.byKey(const ValueKey<String>('s02-item-1')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.webAbsent,
    );

    // 사이드바 탭 3 => reportArchive
    await tester.tap(find.byKey(const ValueKey<String>('s02-item-3')));
    await tester.pumpAndSettle();
    expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);

    // 사이드바 탭 4 => handbook-slot
    await tester.tap(find.byKey(const ValueKey<String>('s02-item-4')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('s02-handbook-slot')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── TS-08 큰 글꼴 ──────────────────────────────────────────────────────────
  group('TS-08 large font', () {
    final ListResult<AlertItem> alerts12 = listFixture(
      FixturePaths.alerts12,
      AlertItem.fromJson,
    );

    final List<
      ({String name, ShellPlatform platform, FeatureFlags flags, Size size})
    >
    cases =
        <
          ({String name, ShellPlatform platform, FeatureFlags flags, Size size})
        >[
          (
            name: 'phone',
            platform: ShellPlatform.androidOperator,
            flags: kFlagsSimAdvisory,
            size: const Size(390, 844),
          ),
          (
            name: 'web',
            platform: ShellPlatform.web,
            flags: kFlagsSimAdvisory,
            size: const Size(1280, 800),
          ),
        ];

    for (final c in cases) {
      testWidgets('TS-08 large font ${c.name}', (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(
          () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
        );
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: c.platform,
            config: flagsOf(c.flags),
            alerts: alertsOf(alerts12.rows),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
          ),
          size: c.size,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('s01-title')), findsOneWidget);
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }
  });

  // ── TS-09 화면 Text 전부 ──────────────────────────────────────────────────
  testWidgets('TS-09 all texts shown', (WidgetTester tester) async {
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.androidOperator,
        config: flagsOf(kFlagsSimAdvisory),
        alerts: alertsOf(
          listFixture(FixturePaths.alerts12, AlertItem.fromJson).rows,
        ),
        bodies: const ShellRouteBodies(<String, ShellBodyBuilder>{}),
      ),
    );
    final Set<String> allowed = <String>{
      ShellLabels.tabHome,
      ShellLabels.tabJournal,
      ShellLabels.tabHoldings,
      ShellLabels.tabPlan,
      ShellLabels.tabMore,
      ShellLabels.simPrefix,
      ShellLabels.advisoryPrefix,
      shellTitle(kFlagsSimAdvisory, ShellLabels.tabHome),
    };
    final List<String?> shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data)
        .toList();
    expect(shown, isNotEmpty);
    for (final String? data in shown) {
      expect(data, isIn(allowed));
    }
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── R14 test-only (C4r13a-3) ─────────────────────────────────────────────
  // TS-01 iosViewer = 폰 셸 배치(탭 5 · 사이드바 0 · X02)
  testWidgets('TS-01 ios viewer phone shell tabs 5', (
    WidgetTester tester,
  ) async {
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.iosViewer,
        config: flagsOf(kFlagsLiveAuto),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, <String>[]),
      ),
    );
    expect(find.byKey(const Key('s01-tabs')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('s02-sidebar')), findsNothing);
    expect(find.byKey(const Key('s02-view-only')), findsNothing);
    expect(find.byKey(const Key('s02-kill-slot')), findsNothing);
    final List<String> labels = <String>[
      ShellLabels.tabHome,
      ShellLabels.tabJournal,
      ShellLabels.tabHoldings,
      ShellLabels.tabPlan,
      ShellLabels.tabMore,
    ];
    expect(
      tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .map((NavigationDestination d) => d.label)
          .toList(),
      labels,
    );
    for (final String label in labels) {
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('s01-tabs')),
          matching: find.text(label),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
        label,
      );
    }
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // TS-07 사이드바 탭 뒤 ListTile.selected = 누른 칸 하나(X10)
  testWidgets('TS-07 web sidebar selected follows tap', (
    WidgetTester tester,
  ) async {
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.web,
        config: flagsOf(kFlagsLiveAuto),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, <String>[]),
      ),
      size: const Size(1280, 800),
    );
    List<bool> selectedOf() => <bool>[
      for (int i = 0; i < 5; i++)
        tester
            .widget<ListTile>(find.byKey(ValueKey<String>('s02-item-$i')))
            .selected,
    ];
    expect(selectedOf(), <bool>[true, false, false, false, false]);

    await tester.tap(find.byKey(const ValueKey<String>('s02-item-3')));
    await tester.pumpAndSettle();
    expect(selectedOf(), <bool>[false, false, false, true, false]);

    await tester.tap(find.byKey(const ValueKey<String>('s02-item-4')));
    await tester.pumpAndSettle();
    expect(selectedOf(), <bool>[false, false, false, false, true]);

    await tester.tap(find.byKey(const ValueKey<String>('s02-item-0')));
    await tester.pumpAndSettle();
    expect(selectedOf(), <bool>[true, false, false, false, false]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
