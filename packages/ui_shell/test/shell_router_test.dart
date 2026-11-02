// test/shell_router_test.dart — TR-01 ~ TR-12
//
// 라우터·가드 동작 테스트 — ⓡ 0 줄(화면 재시도 갈래 없음) · ⓗ 1줄(TR-03).
// 테스트 이름: ASCII only.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

void main() {
  // ── TR-01 전량 자기 일치 ────────────────────────────────────────────────────
  test('TR-01 all routes match themselves', () {
    final List<String> matched = <String>[];
    expect(AppRoutes.all, isNotEmpty);
    for (final String p in AppRoutes.all) {
      final String link = dummyLink(p);
      expect(AppRoutes.isRegistered(link), isTrue);
      final ShellRouteMatch? m = matchShellRoute(link);
      expect(m?.pattern, p);
      expect(m?.params, dummyParams(p));
      matched.add(m!.pattern);
    }
    expect(matched, AppRoutes.all);
  });

  // ── TR-02 음성 ─────────────────────────────────────────────────────────────
  test('TR-02 negative cases', () {
    const List<String> negatives = <String>[
      'aaq://nope/x',
      'aaq://holdings/detail/',
      'aaq://holdings/detail/h1?x=1',
      'aaq://holdings/detail/h1#x',
      'handbook://sleeve-b',
    ];
    for (final String link in negatives) {
      expect(matchShellRoute(link), isNull);
      expect(AppRoutes.isRegistered(link), isFalse);
    }
  });

  // ── TR-03 한글 별칭 링크(W11) ──────────────────────────────────────────────
  test('TR-03 korean alias link W11', () {
    final ListResult<OpsRhythmRow> rows = listFixture(
      FixturePaths.m8OpsRhythmRows,
      OpsRhythmRow.fromJson,
    );
    expect(rows.rows, hasLength(5)); // ⓗ
    for (final OpsRhythmRow r in rows.rows) {
      expect(r.route, isNotNull); // pre
      expect(AppRoutes.isRegistered(r.route!), isTrue);
      expect(matchShellRoute(r.route!)?.pattern, isNotNull);
    }
    final OpsRhythmRow audit = rows.rows[3];
    expect(audit.code, 'QUARTERLY_SELF_AUDIT'); // pre
    final List<String> segs = audit.route!.split('/');
    expect(segs.last.runes.any((int c) => c > 0x7F), isTrue); // pre
    final ShellRouteMatch? m = matchShellRoute(audit.route!);
    expect(m?.pattern, AppRoutes.ledgerSelfReport);
    expect(m?.params, <String, String>{
      'yyyyMm': segs[segs.length - 2],
      'accountAlias': segs.last,
    });
  });

  // ── TR-04 가드 표 ──────────────────────────────────────────────────────────
  test('TR-04 guard table', () {
    const List<String> iosPhoneOnly = <String>[
      AppRoutes.adviceFill,
      AppRoutes.adviceSkip,
      AppRoutes.ledgerSelfReport,
      AppRoutes.ledgerRepairs,
      AppRoutes.planDeposit,
    ];
    const List<String> webPhoneOnly = <String>[
      AppRoutes.ledgerRepairs,
      AppRoutes.planDeposit,
    ];
    const List<String> webAbsent = <String>[
      AppRoutes.journalTimeline,
      AppRoutes.journalDecision,
      AppRoutes.journalDraft,
      AppRoutes.journalRead,
      AppRoutes.journalRebalance,
      AppRoutes.journalBlindReview,
      AppRoutes.journalUnknownBoard,
      AppRoutes.holdingsOverview,
      AppRoutes.holdingsDetail,
      AppRoutes.holdingsAllocation,
      AppRoutes.adviceInbox,
      AppRoutes.adviceDetail,
      AppRoutes.adviceFill,
      AppRoutes.adviceSkip,
      AppRoutes.adviceHistory,
      AppRoutes.ledgerSelfReport,
      AppRoutes.ledgerDiffs,
    ];
    const List<String> advisoryWrite = <String>[
      AppRoutes.adviceFill,
      AppRoutes.adviceSkip,
      AppRoutes.ledgerSelfReport,
    ];

    for (final String p in AppRoutes.all) {
      for (final OperatingMode? mode in <OperatingMode?>[
        OperatingMode.autoTrade,
        OperatingMode.advisory,
        null,
      ]) {
        // androidOperator
        final ShellGuard android = shellGuardFor(
          p,
          ShellPlatform.androidOperator,
          mode,
        );
        final ShellGuard wantAndroid = advisoryWrite.contains(p)
            ? (mode == OperatingMode.advisory
                  ? ShellGuard.open
                  : ShellGuard.advisoryOnly)
            : ShellGuard.open;
        expect(android, wantAndroid);

        // iosViewer
        final ShellGuard ios = shellGuardFor(p, ShellPlatform.iosViewer, mode);
        final ShellGuard wantIos = p == AppRoutes.journalDraft
            ? ShellGuard.draftReadOnly
            : iosPhoneOnly.contains(p)
            ? ShellGuard.phoneOnly
            : ShellGuard.open;
        expect(ios, wantIos);

        // web
        final ShellGuard web = shellGuardFor(p, ShellPlatform.web, mode);
        final ShellGuard wantWeb = webPhoneOnly.contains(p)
            ? ShellGuard.phoneOnly
            : webAbsent.contains(p)
            ? ShellGuard.webAbsent
            : ShellGuard.open;
        expect(web, wantWeb);
      }
    }
  });

  // ── TR-05 Android 모드 가드 ────────────────────────────────────────────────
  const List<String> advisoryWritePatterns = <String>[
    AppRoutes.adviceFill,
    AppRoutes.adviceSkip,
    AppRoutes.ledgerSelfReport,
  ];

  group('TR-05 android advisory guard', () {
    const List<({String name, FeatureFlags flags, bool wantGuard})> cases =
        <({String name, FeatureFlags flags, bool wantGuard})>[
          (name: 'auto', flags: kFlagsLiveAuto, wantGuard: true),
          (name: 'advisory', flags: kFlagsLiveAdvisory, wantGuard: false),
        ];

    for (final c in cases) {
      testWidgets('TR-05 ${c.name}', (WidgetTester tester) async {
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
        for (final String p in advisoryWritePatterns) {
          await openLink(tester, dummyLink(p));
          expect(
            find.text(ShellLabels.advisoryOnly),
            c.wantGuard ? findsOneWidget : findsNothing,
          );
          expect(dummyOf(p), c.wantGuard ? findsNothing : findsOneWidget);
          expect(
            tester
                .widgetList<DummyBody>(
                  find.ancestor(
                    of: dummyOf(p),
                    matching: find.byType(DummyBody),
                  ),
                )
                .map((DummyBody d) => d.params)
                .toList(),
            c.wantGuard
                ? <Map<String, String>>[]
                : <Map<String, String>>[dummyParams(p)],
          );
          await openLink(tester, AppNavActions.back);
        }
      });
    }
  });

  // ── TR-06 iOS 가드 ─────────────────────────────────────────────────────────
  const List<String> iosPhoneOnlyPatterns = <String>[
    AppRoutes.adviceFill,
    AppRoutes.adviceSkip,
    AppRoutes.ledgerSelfReport,
    AppRoutes.ledgerRepairs,
    AppRoutes.planDeposit,
  ];

  testWidgets('TR-06 ios guard', (WidgetTester tester) async {
    final List<String> log = <String>[];
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.iosViewer,
        config: flagsOf(kFlagsLiveAdvisory),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, log),
      ),
    );

    // journalDraft => draftReadOnly
    await openLink(tester, dummyLink(AppRoutes.journalDraft));
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.journalDraftPhoneOnly,
    );
    expect(dummyOf(AppRoutes.journalRead), findsOneWidget);
    expect(
      tester
          .widget<DummyBody>(
            find.ancestor(
              of: dummyOf(AppRoutes.journalRead),
              matching: find.byType(DummyBody),
            ),
          )
          .params,
      dummyParams(AppRoutes.journalDraft),
    );
    expect(dummyOf(AppRoutes.journalDraft), findsNothing);
    await openLink(tester, AppNavActions.back);

    // iosPhoneOnly 다섯
    for (final String p in iosPhoneOnlyPatterns) {
      await openLink(tester, dummyLink(p));
      expect(
        tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
        ShellLabels.phoneOnly,
      );
      expect(dummyOf(p), findsNothing);
      await openLink(tester, AppNavActions.back);
    }

    // journalRead open => open
    await openLink(tester, dummyLink(AppRoutes.journalRead));
    expect(dummyOf(AppRoutes.journalRead), findsOneWidget);
    expect(find.byKey(const Key('s01-guard')), findsNothing);
  });

  // ── TR-07 웹 가드 ──────────────────────────────────────────────────────────
  testWidgets('TR-07 web guard S-02', (WidgetTester tester) async {
    final List<String> log = <String>[];
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.web,
        config: flagsOf(kFlagsLiveAuto),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, log),
      ),
      size: const Size(1280, 800),
    );
    // 조회 전용 = 실전·자동에서도
    expect(shownTexts(tester, find.byKey(const Key('s02-view-only'))), <String>[
      ShellLabels.viewOnly,
    ]);

    // webAbsent
    await openLink(tester, dummyLink(AppRoutes.adviceInbox));
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.webAbsent,
    );
    expect(find.byType(DummyBody), findsNothing);
    await openLink(tester, AppNavActions.back);

    await openLink(tester, dummyLink(AppRoutes.journalTimeline));
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.webAbsent,
    );
    expect(find.byType(DummyBody), findsNothing);
    await openLink(tester, AppNavActions.back);

    // phoneOnly
    await openLink(tester, dummyLink(AppRoutes.ledgerRepairs));
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.phoneOnly,
    );
    await openLink(tester, AppNavActions.back);

    await openLink(tester, dummyLink(AppRoutes.planDeposit));
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.phoneOnly,
    );
    await openLink(tester, AppNavActions.back);

    // open
    await openLink(tester, dummyLink(AppRoutes.reportArchive));
    expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);
    expect(find.byKey(const Key('s01-guard')), findsNothing);

    // 링크 화면 위에서도 s02-view-only · s02-kill-slot
    expect(find.byKey(const Key('s02-view-only')), findsOneWidget);
    expect(find.byKey(const Key('s02-kill-slot')), findsOneWidget);

    // 사이드바 탭 => 쌓인 화면 닫힘
    await tester.tap(find.byKey(const ValueKey<String>('s02-item-0')));
    await tester.pumpAndSettle();
    expect(dummyOf(AppRoutes.reportArchive), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
      ShellLabels.sideHome,
    );
  });

  // ── TR-08 back 동작 링크 ───────────────────────────────────────────────────
  group('TR-08 back action link', () {
    final List<({String name, Future<void> Function(WidgetTester t) steps})>
    cases = <({String name, Future<void> Function(WidgetTester t) steps})>[
      (
        name: 'pushed',
        steps: (WidgetTester t) async {
          await openLink(t, dummyLink(AppRoutes.holdingsDetail));
          expect(dummyOf(AppRoutes.holdingsDetail), findsOneWidget);
          await openLink(t, AppNavActions.back);
          expect(dummyOf(AppRoutes.holdingsDetail), findsNothing);
          expect(
            t.widget<Text>(find.byKey(const Key('s01-title'))).data,
            ShellLabels.tabHome,
          );
        },
      ),
      (
        name: 'root',
        steps: (WidgetTester t) async {
          // 탭 3으로 이동 후 back => 홈(탭 0)
          await t.tap(
            find.descendant(
              of: find.byKey(const Key('s01-tabs')),
              matching: find.text(ShellLabels.tabPlan),
            ),
          );
          await t.pump();
          await openLink(t, AppNavActions.back);
          expect(
            t.widget<Text>(find.byKey(const Key('s01-title'))).data,
            ShellLabels.tabHome,
          );
          expect(
            t
                .widget<NavigationBar>(find.byKey(const Key('s01-tabs')))
                .selectedIndex,
            0,
          );
        },
      ),
    ];

    for (final c in cases) {
      testWidgets('TR-08 ${c.name}', (WidgetTester tester) async {
        final List<String> log = <String>[];
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(kFlagsLiveAuto),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, log),
          ),
        );

        await c.steps(tester);
      });
    }
  });

  // ── TR-09 미등록 · 핸드북 · 본문 없음 ─────────────────────────────────────
  group('TR-09 unknown handbook no-body', () {
    final List<
      ({
        String name,
        List<String> Function(List<String> log) bodiesFactory,
        String link,
        bool unknown,
        bool handbook,
        bool placeholder,
      })
    >
    cases =
        <
          ({
            String name,
            List<String> Function(List<String> log) bodiesFactory,
            String link,
            bool unknown,
            bool handbook,
            bool placeholder,
          })
        >[
          (
            name: 'unknown',
            bodiesFactory: (List<String> log) => AppRoutes.all,
            link: 'aaq://nope/x',
            unknown: true,
            handbook: false,
            placeholder: false,
          ),
          (
            name: 'handbook',
            bodiesFactory: (List<String> log) => AppRoutes.all,
            link: 'handbook://sleeve-b',
            unknown: false,
            handbook: true,
            placeholder: false,
          ),
          (
            name: 'no_body',
            bodiesFactory: (List<String> log) => const <String>[],
            link: AppRoutes.reportArchive,
            unknown: false,
            handbook: false,
            placeholder: true,
          ),
          // opener 경유 음성 링크 — 물음표 뒤를 자르지 않는다(C4r13a-3 · X05)
          (
            name: 'query_link',
            bodiesFactory: (List<String> log) => AppRoutes.all,
            link: 'aaq://holdings/detail/h1?x=1',
            unknown: true,
            handbook: false,
            placeholder: false,
          ),
        ];

    for (final c in cases) {
      testWidgets('TR-09 ${c.name}', (WidgetTester tester) async {
        final List<String> log = <String>[];
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(kFlagsLiveAuto),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(c.bodiesFactory(log), log),
          ),
        );
        await openLink(tester, c.link);
        expect(
          find.byKey(const Key('s01-unknown-link')),
          c.unknown ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('s01-handbook-slot')),
          c.handbook ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('s01-placeholder')),
          c.placeholder ? findsOneWidget : findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('s01-placeholder')),
            matching: find.byType(Text),
            matchRoot: true,
          ),
          findsNothing,
        );
        expect(find.byType(DummyBody), findsNothing);
      });
    }
  });

  // ── TR-10 performanceExplore = 늘 새 화면 ─────────────────────────────────
  testWidgets('TR-10 performanceExplore always new page', (
    WidgetTester tester,
  ) async {
    final List<String> log = <String>[];
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.androidOperator,
        config: flagsOf(kFlagsLiveAuto),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(<String>[AppRoutes.performanceExplore], log),
      ),
    );
    await openLink(tester, AppRoutes.performanceExplore);
    await openLink(tester, AppNavActions.back);
    await openLink(tester, AppRoutes.performanceExplore);
    expect(log, <String>[
      AppRoutes.performanceExplore,
      AppRoutes.performanceExplore,
    ]);
  });

  // ── TR-11 전 라우트 모의투자·안내 접두 ────────────────────────────────────
  const List<({String name, ShellPlatform platform, Size size})> platformCases =
      <({String name, ShellPlatform platform, Size size})>[
        (
          name: 'android',
          platform: ShellPlatform.androidOperator,
          size: Size(390, 844),
        ),
        (name: 'ios', platform: ShellPlatform.iosViewer, size: Size(390, 844)),
        (name: 'web', platform: ShellPlatform.web, size: Size(1280, 800)),
      ];

  for (final pc in platformCases) {
    testWidgets('TR-11 all routes band ${pc.name}', (
      WidgetTester tester,
    ) async {
      final List<String> log = <String>[];
      await pumpShell(
        tester,
        overrides: shellOverrides(
          platform: pc.platform,
          config: flagsOf(kFlagsSimAdvisory),
          alerts: alertsOf(const <AlertItem>[]),
          bodies: dummyBodies(AppRoutes.all, log),
        ),
        size: pc.size,
      );
      for (final String p in AppRoutes.all) {
        await openLink(tester, dummyLink(p));
        expect(shownTexts(tester, find.byKey(const Key('s01-band'))), <String>[
          ShellLabels.simPrefix,
          ShellLabels.advisoryPrefix,
        ]);
        expect(
          tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
          shellTitle(kFlagsSimAdvisory, null),
        );
        await openLink(tester, AppNavActions.back);
      }
    });
  }

  // ── TR-12 실전 = 접두 0 ────────────────────────────────────────────────────
  testWidgets('TR-12 live auto no prefix', (WidgetTester tester) async {
    final List<String> log = <String>[];
    await pumpShell(
      tester,
      overrides: shellOverrides(
        platform: ShellPlatform.androidOperator,
        config: flagsOf(kFlagsLiveAuto),
        alerts: alertsOf(const <AlertItem>[]),
        bodies: dummyBodies(AppRoutes.all, log),
      ),
    );
    await openLink(tester, dummyLink(AppRoutes.reportArchive));
    expect(find.byKey(const Key('s01-band')), findsNothing);
    expect(find.byKey(const Key('s01-title')), findsNothing);
    expect(find.text(ShellLabels.simPrefix), findsNothing);
    expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);
  });
}
