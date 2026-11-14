// test/connections_test.dart
//
// M9 S07 -- Connections widget tests (29 tests).
//
// ASCII only. No Korean literals. if 0. collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

// ── Level look helper (lib copy) ───────────────────────────────────────────────

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

// ── Fixtures ──────────────────────────────────────────────────────────────────

final ConnectionsVm conn = singleFixture(
  FixturePaths.m9Connections,
  ConnectionsVm.fromJson,
);
final ConnectionsVm tele = singleFixture(
  FixturePaths.m9ConnectionsTelegram,
  ConnectionsVm.fromJson,
);
final ConnectionsVm locked = singleFixture(
  FixturePaths.m9ConnectionsLocked,
  ConnectionsVm.fromJson,
);
final List<ActionResult> results = listFixture(
  FixturePaths.m9SettingsActionResults,
  ActionResult.fromJson,
).rows;

FakeSettingsActions okActions() => FakeSettingsActions(
  result: (int call) => Future<ActionResult>.value(results[0]),
);

void main() {
  final NotifyChannelCard kakao = conn.rows[2].channelPicker!;
  final NotifyChannelCard telegram = tele.rows[2].channelPicker!;
  final NotifyChannelCard lockedPicker = locked.rows[2].channelPicker!;

  final List<String?> kakaoOperator = <String?>[
    kakao.label,
    ?kakao.options[0].selectAction?.label,
    kakao.options[1].label,
    kakao.capabilityNotice,
    ?kakao.tokenBadgeText,
    kakao.watchdogChannelLine,
  ];
  final List<String?> kakaoViewer = <String?>[
    kakao.label,
    kakao.options[1].label,
    kakao.capabilityNotice,
    ?kakao.tokenBadgeText,
    kakao.watchdogChannelLine,
  ];
  final List<String?> lockedView = <String?>[
    lockedPicker.label,
    lockedPicker.options[1].label,
    lockedPicker.capabilityNotice,
    ?lockedPicker.tokenBadgeText,
    lockedPicker.watchdogChannelLine,
  ];
  final List<String?> telegramOperator = <String?>[
    telegram.label,
    telegram.options[0].label,
    ?telegram.options[1].selectAction?.label,
    telegram.capabilityNotice,
    ?telegram.tokenBadgeText,
    telegram.watchdogChannelLine,
  ];

  // ── M9S07-01 row/button/picker order and text ─────────────────────────────

  testWidgets('M9S07-01 row button picker order text', (
    WidgetTester tester,
  ) async {
    expect(conn.rows, hasLength(5)); // ⓗ

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: FakeSettingsOpsStatusRepository(
          connections: (int call) => one(conn),
        ),
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    for (final (int r, ConnectionRow row) in conn.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s07-row-$r'))),
        connectionRowTexts(row),
      );
      for (final (int a, SettingsActionCall call) in row.actions.indexed) {
        expect(
          shownTexts(
            tester,
            find.byKey(ValueKey<String>('m9s07-action-$r-$a')),
          ),
          <String>[call.label],
        );
      }
    }

    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('m9s07-picker-2'))),
      kakaoOperator,
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s07-asof'))), <String>[
      conn.asOf.label,
    ]);

    final List<Key> chain = <Key>[
      const ValueKey<String>('m9s07-row-0'),
      const ValueKey<String>('m9s07-action-0-0'),
      const ValueKey<String>('m9s07-row-1'),
      const ValueKey<String>('m9s07-action-1-0'),
      const ValueKey<String>('m9s07-row-2'),
      const ValueKey<String>('m9s07-action-2-0'),
      const ValueKey<String>('m9s07-picker-2'),
      const ValueKey<String>('m9s07-row-3'),
      const ValueKey<String>('m9s07-row-4'),
      const Key('m9s07-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }

    expect(find.byKey(const ValueKey<String>('m9s07-row-5')), findsNothing);
    expect(find.byKey(const Key('m9s07-stale')), findsNothing);
    expect(find.byKey(const Key('m9s07-locked')), findsNothing);
    expect(find.byKey(const Key('m9s07-result')), findsNothing);
    expect(find.byKey(const Key('m9s07-not-accepted')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-02 row count = received count (telegram) ────────────────────────

  testWidgets('M9S07-02 row count telegram', (WidgetTester tester) async {
    expect(tele.rows, hasLength(4)); // ⓗ

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: FakeSettingsOpsStatusRepository(
          connections: (int call) => one(tele),
        ),
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    for (final (int r, ConnectionRow row) in tele.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s07-row-$r'))),
        connectionRowTexts(row),
      );
    }
    expect(find.byKey(const ValueKey<String>('m9s07-row-4')), findsNothing);
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('m9s07-picker-2'))),
      telegramOperator,
    );
    expect(find.byKey(const ValueKey<String>('m9s07-token-2')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('m9s07-picker-2')),
      findsOneWidget,
    );
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-03 row level icons and colors ───────────────────────────────────

  testWidgets('M9S07-03 row level icon color', (WidgetTester tester) async {
    expect(conn.rows, hasLength(5)); // ⓗ
    expect(
      conn.rows.map((ConnectionRow k) => k.level).toSet().length,
      greaterThan(1),
    ); // pre

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: FakeSettingsOpsStatusRepository(
          connections: (int call) => one(conn),
        ),
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    final ColorScheme cs = Theme.of(tester.element(find.byType(Connections)))
        .colorScheme;

    for (final (int r, ConnectionRow row) in conn.rows.indexed) {
      final Icon icon = tester.widget<Icon>(
        find.byKey(ValueKey<String>('m9s07-level-$r')),
      );
      final (IconData wantIcon, Color wantColor) = wantLevel(cs, row.level);
      expect(icon.icon, wantIcon);
      expect(icon.color, wantColor);
    }
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-04 row tap = route as-is ───────────────────────────────────────

  testWidgets('M9S07-04 row tap route', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeSettingsActions actions = okActions();

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: FakeSettingsOpsStatusRepository(
          connections: (int call) => one(conn),
        ),
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    final List<String> wantRoutes = <String>[
      for (final ConnectionRow k in conn.rows) ?k.route,
    ];
    expect(wantRoutes, hasLength(2)); // ⓗ

    for (final (int r, ConnectionRow row) in conn.rows.indexed) {
      await tester.tap(find.byKey(ValueKey<String>('m9s07-row-$r')));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('m9s07-row-$r')),
          matching: find.byIcon(Icons.chevron_right),
        ),
        row.route == null ? findsNothing : findsOneWidget,
      );
    }

    expect(opener.opened, wantRoutes);
    expect(actions.ids, <SettingsActionId>[]);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-05 action buttons = row.actions as-is ───────────────────────────

  testWidgets('M9S07-05 action buttons row actions', (
    WidgetTester tester,
  ) async {
    expect(conn.rows[0].actions, hasLength(2)); // ⓗ
    expect(conn.rows[2].actions, hasLength(1)); // ⓗ
    expect(conn.rows[3].actions, isEmpty); // pre

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: FakeSettingsOpsStatusRepository(
          connections: (int call) => one(conn),
        ),
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    for (final (int r, ConnectionRow row) in conn.rows.indexed) {
      for (final (int a, SettingsActionCall call) in row.actions.indexed) {
        expect(
          shownTexts(
            tester,
            find.byKey(ValueKey<String>('m9s07-action-$r-$a')),
          ),
          <String>[call.label],
        );
      }
    }

    expect(
      find.byKey(const ValueKey<String>('m9s07-action-0-2')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('m9s07-action-2-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('m9s07-action-3-0')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('m9s07-action-4-0')),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(6),
    );
    expect(
      find.byKey(const ValueKey<String>('m9s07-action-0-0')),
      findsOneWidget,
    );
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-06 tap button = run once with received id/args ──────────────────

  testWidgets('M9S07-06 run once id args', (WidgetTester tester) async {
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Future<ActionResult>.value(results[0]),
    );
    final FakeSettingsOpsStatusRepository repo =
        FakeSettingsOpsStatusRepository(connections: (int call) => one(conn));
    final RecordingLinkOpener opener = RecordingLinkOpener();

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    final List<SettingsActionId> wantIds = <SettingsActionId>[
      conn.rows[0].actions[0].id,
      conn.rows[0].actions[1].id,
      conn.rows[1].actions[0].id,
      conn.rows[1].actions[1].id,
      conn.rows[2].actions[0].id,
      kakao.options[0].selectAction!.id,
    ];
    final List<Map<String, String>> wantArgs = <Map<String, String>>[
      conn.rows[0].actions[0].args,
      conn.rows[0].actions[1].args,
      conn.rows[1].actions[0].args,
      conn.rows[1].actions[1].args,
      conn.rows[2].actions[0].args,
      kakao.options[0].selectAction!.args,
    ];
    expect(wantIds, hasLength(6)); // ⓗ

    final List<Key> tapKeys = <Key>[
      const ValueKey<String>('m9s07-action-0-0'),
      const ValueKey<String>('m9s07-action-0-1'),
      const ValueKey<String>('m9s07-action-1-0'),
      const ValueKey<String>('m9s07-action-1-1'),
      const ValueKey<String>('m9s07-action-2-0'),
      const ValueKey<String>('m9s07-select-2-0'),
    ];

    for (final Key k in tapKeys) {
      await tester.tap(find.byKey(k));
      await tester.pump();
      await tester.pump();
    }

    expect(actions.ids, wantIds);
    expect(actions.argsSeen, wantArgs);
    expect(actions.watchCalls, 0);
    expect(repo.connectionsCalls, 1);
    expect(opener.opened, <String>[]);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-07 result = headline + reasonCode + level icon (5 cases) ────────

  final ({String name, ActionResult r, Key tap}) case07ok = (
    name: 'ok',
    r: results[0],
    tap: const ValueKey<String>('m9s07-action-0-0'),
  );
  final ({String name, ActionResult r, Key tap}) case07fail = (
    name: 'fail',
    r: results[1],
    tap: const ValueKey<String>('m9s07-action-1-0'),
  );
  final ({String name, ActionResult r, Key tap}) case07dup = (
    name: 'dup',
    r: results[2],
    tap: const ValueKey<String>('m9s07-action-0-1'),
  );
  final ({String name, ActionResult r, Key tap}) case07channel = (
    name: 'channel',
    r: results[3],
    tap: const ValueKey<String>('m9s07-select-2-0'),
  );
  final ({String name, ActionResult r, Key tap}) case07bio = (
    name: 'bio',
    r: results[4],
    tap: const ValueKey<String>('m9s07-action-1-1'),
  );

  for (final c in <({String name, ActionResult r, Key tap})>[
    case07ok,
    case07fail,
    case07dup,
    case07channel,
    case07bio,
  ]) {
    testWidgets('M9S07-07 result headline reasonCode level ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.retryable, isFalse); // pre

      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(conn),
          ),
          actions: FakeSettingsActions(
            result: (int call) => Future<ActionResult>.value(c.r),
          ),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.tap));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );

      final ColorScheme cs = Theme.of(tester.element(find.byType(Connections)))
          .colorScheme;
      final Icon resultIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s07-result-level')),
      );
      final (IconData wantIcon, Color wantColor) = wantLevel(cs, c.r.level);
      expect(resultIcon.icon, wantIcon);
      expect(resultIcon.color, wantColor);

      expect(find.byKey(const Key('m9s07-not-accepted')), findsNothing);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNWidgets(6),
      );

      expect(
        tester.getTopLeft(find.byKey(const Key('m9s07-result'))).dy,
        lessThan(
          tester
              .getTopLeft(find.byKey(const ValueKey<String>('m9s07-row-0')))
              .dy,
        ),
      );
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S07-08 fail<->ok two directions ─────────────────────────────────────

  final ({
    String name,
    Future<ActionResult> Function(int call) factory,
    List<String?> firstNa,
    List<String?> firstRes,
    List<String?> secondNa,
    List<String?> secondRes,
  })
  case08failThenOk = (
    name: 'fail_then_ok',
    factory: (int call) => call == 0
        ? Future<ActionResult>.error(StateError('fail'))
        : Future<ActionResult>.value(results[0]),
    firstNa: <String?>[SettingsLabels.notAccepted],
    firstRes: <String?>[],
    secondNa: <String?>[],
    secondRes: <String?>[results[0].headline],
  );

  final ({
    String name,
    Future<ActionResult> Function(int call) factory,
    List<String?> firstNa,
    List<String?> firstRes,
    List<String?> secondNa,
    List<String?> secondRes,
  })
  case08okThenFail = (
    name: 'ok_then_fail',
    factory: (int call) => call == 0
        ? Future<ActionResult>.value(results[0])
        : Future<ActionResult>.error(StateError('fail')),
    firstNa: <String?>[],
    firstRes: <String?>[results[0].headline],
    secondNa: <String?>[SettingsLabels.notAccepted],
    secondRes: <String?>[],
  );

  for (final c
      in <
        ({
          String name,
          Future<ActionResult> Function(int call) factory,
          List<String?> firstNa,
          List<String?> firstRes,
          List<String?> secondNa,
          List<String?> secondRes,
        })
      >[case08failThenOk, case08okThenFail]) {
    testWidgets('M9S07-08 fail ok two directions ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: c.factory,
      );

      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(conn),
          ),
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('m9s07-action-0-0')));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-result'))),
        c.firstRes,
      );

      await tester.tap(find.byKey(const ValueKey<String>('m9s07-action-0-0')));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-result'))),
        c.secondRes,
      );

      expect(actions.ids, <SettingsActionId>[
        conn.rows[0].actions[0].id,
        conn.rows[0].actions[0].id,
      ]);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S07-09 no double tap while busy ─────────────────────────────────────

  final ({String name, Key tap, List<SettingsActionId> want}) case09action = (
    name: 'action',
    tap: const ValueKey<String>('m9s07-action-0-0'),
    want: <SettingsActionId>[conn.rows[0].actions[0].id],
  );

  final ({String name, Key tap, List<SettingsActionId> want}) case09select = (
    name: 'select',
    tap: const ValueKey<String>('m9s07-select-2-0'),
    want: <SettingsActionId>[?kakao.options[0].selectAction?.id],
  );

  for (final c in <({String name, Key tap, List<SettingsActionId> want})>[
    case09action,
    case09select,
  ]) {
    testWidgets('M9S07-09 no double tap while busy ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Completer<ActionResult>().future,
      );

      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(conn),
          ),
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.tap));
      await tester.pump();
      await tester.tap(find.byKey(c.tap));
      await tester.pump();

      expect(actions.ids, c.want);
      expect(
        tester
            .widgetList<ButtonStyleButton>(
              find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
            )
            .map((ButtonStyleButton b) => b.enabled)
            .toSet(),
        <bool>{false},
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(const Key('m9s07-result')), findsNothing);
      expect(find.byKey(const Key('m9s07-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S07-10 channel picker selection = engine ────────────────────────────

  final ({
    String name,
    ConnectionsVm v,
    List<String?> pickerTexts,
    Key selectedKey,
    List<String?> selectedTexts,
    Key selectKey,
    List<String?> selectTexts,
    Key otherOptionKey,
    Matcher token,
    List<SettingsActionId> wantIds,
    List<Map<String, String>> wantArgs,
  })
  case10kakao = (
    name: 'kakao',
    v: conn,
    pickerTexts: kakaoOperator,
    selectedKey: const ValueKey<String>('m9s07-option-2-1'),
    selectedTexts: <String>[kakao.options[1].label],
    selectKey: const ValueKey<String>('m9s07-select-2-0'),
    selectTexts: <String?>[?kakao.options[0].selectAction?.label],
    otherOptionKey: const ValueKey<String>('m9s07-option-2-0'),
    token: findsOneWidget,
    wantIds: <SettingsActionId>[?kakao.options[0].selectAction?.id],
    wantArgs: <Map<String, String>>[?kakao.options[0].selectAction?.args],
  );

  final ({
    String name,
    ConnectionsVm v,
    List<String?> pickerTexts,
    Key selectedKey,
    List<String?> selectedTexts,
    Key selectKey,
    List<String?> selectTexts,
    Key otherOptionKey,
    Matcher token,
    List<SettingsActionId> wantIds,
    List<Map<String, String>> wantArgs,
  })
  case10telegram = (
    name: 'telegram',
    v: tele,
    pickerTexts: telegramOperator,
    selectedKey: const ValueKey<String>('m9s07-option-2-0'),
    selectedTexts: <String>[telegram.options[0].label],
    selectKey: const ValueKey<String>('m9s07-select-2-1'),
    selectTexts: <String?>[?telegram.options[1].selectAction?.label],
    otherOptionKey: const ValueKey<String>('m9s07-option-2-1'),
    token: findsNothing,
    wantIds: <SettingsActionId>[?telegram.options[1].selectAction?.id],
    wantArgs: <Map<String, String>>[?telegram.options[1].selectAction?.args],
  );

  for (final c
      in <
        ({
          String name,
          ConnectionsVm v,
          List<String?> pickerTexts,
          Key selectedKey,
          List<String?> selectedTexts,
          Key selectKey,
          List<String?> selectTexts,
          Key otherOptionKey,
          Matcher token,
          List<SettingsActionId> wantIds,
          List<Map<String, String>> wantArgs,
        })
      >[case10kakao, case10telegram]) {
    testWidgets('M9S07-10 channel picker selection ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(results[3]),
      );

      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(c.v),
          ),
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        shownTexts(
          tester,
          find.byKey(const ValueKey<String>('m9s07-picker-2')),
        ),
        c.pickerTexts,
      );
      expect(shownTexts(tester, find.byKey(c.selectedKey)), c.selectedTexts);
      expect(shownTexts(tester, find.byKey(c.selectKey)), c.selectTexts);
      expect(find.byKey(c.otherOptionKey), findsNothing);
      expect(find.byKey(const ValueKey<String>('m9s07-token-2')), c.token);

      await tester.tap(find.byKey(c.selectKey));
      await tester.pump();
      await tester.pump();

      expect(shownTexts(tester, find.byKey(c.selectedKey)), c.selectedTexts);
      expect(find.byKey(c.selectKey), findsOneWidget);
      expect(actions.ids, c.wantIds);
      expect(actions.argsSeen, c.wantArgs);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S07-11 viewer = actions null = no buttons ───────────────────────────

  testWidgets('M9S07-11 viewer no buttons data as-is', (
    WidgetTester tester,
  ) async {
    expect(conn.lockedLabel, isNull); // pre

    final FakeSettingsOpsStatusRepository repo =
        FakeSettingsOpsStatusRepository(connections: (int call) => one(conn));

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: repo,
        actions: null,
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    for (final (int r, ConnectionRow row) in conn.rows.indexed) {
      expect(find.byKey(ValueKey<String>('m9s07-action-$r-0')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s07-row-$r'))),
        connectionRowTexts(row),
      );
    }
    expect(
      find.byKey(const ValueKey<String>('m9s07-select-2-0')),
      findsNothing,
    );
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('m9s07-picker-2'))),
      kakaoViewer,
    );
    expect(
      find.byKey(const ValueKey<String>('m9s07-option-2-1')),
      findsOneWidget,
    );
    expect(repo.connectionsCalls, 1);

    final RecordingLinkOpener opener2 = RecordingLinkOpener();
    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: FakeSettingsOpsStatusRepository(
          connections: (int call) => one(conn),
        ),
        actions: null,
        opener: opener2,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('m9s07-row-3')));
    await tester.pump();
    expect(opener2.opened, <String>[?conn.rows[3].route]);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-12 locked = lockedLabel one line + received as-is (2 cases) ─────

  final ({
    String name,
    ConnectionsVm v,
    List<String?> lockedTexts,
    Matcher buttons,
    List<Key> chain,
    List<String?> pickerTexts,
  })
  case12locked = (
    name: 'locked',
    v: locked,
    lockedTexts: <String?>[?locked.lockedLabel],
    buttons: findsNothing,
    chain: <Key>[
      const Key('m9s07-locked'),
      const ValueKey<String>('m9s07-row-0'),
      const Key('m9s07-asof'),
    ],
    pickerTexts: lockedView,
  );

  final ({
    String name,
    ConnectionsVm v,
    List<String?> lockedTexts,
    Matcher buttons,
    List<Key> chain,
    List<String?> pickerTexts,
  })
  case12normal = (
    name: 'normal',
    v: conn,
    lockedTexts: <String?>[],
    buttons: findsNWidgets(6),
    chain: <Key>[
      const ValueKey<String>('m9s07-row-0'),
      const Key('m9s07-asof'),
    ],
    pickerTexts: kakaoOperator,
  );

  for (final c
      in <
        ({
          String name,
          ConnectionsVm v,
          List<String?> lockedTexts,
          Matcher buttons,
          List<Key> chain,
          List<String?> pickerTexts,
        })
      >[case12locked, case12normal]) {
    testWidgets('M9S07-12 locked lockedLabel line ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(locked.lockedLabel, isNotNull); // pre

      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(c.v),
          ),
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('m9s07-option-2-1')),
        findsOneWidget,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-locked'))),
        c.lockedTexts,
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(
        shownTexts(
          tester,
          find.byKey(const ValueKey<String>('m9s07-picker-2')),
        ),
        c.pickerTexts,
      );
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S07-13 asOf line and stale banner two cases ─────────────────────────

  final ({
    String name,
    Clock clock,
    Matcher staleMatcher,
    List<String?> staleTexts,
    List<Key> chain,
  })
  case13fresh = (
    name: 'fresh',
    clock: FixedClock(kGoldenNowUtc),
    staleMatcher: findsNothing,
    staleTexts: <String?>[],
    chain: <Key>[
      const ValueKey<String>('m9s07-row-0'),
      const Key('m9s07-asof'),
    ],
  );

  final ({
    String name,
    Clock clock,
    Matcher staleMatcher,
    List<String?> staleTexts,
    List<Key> chain,
  })
  case13stale = (
    name: 'stale',
    clock: FixedClock(
      conn.asOf.observedAt
          .add(conn.asOf.staleAfter)
          .add(const Duration(seconds: 1)),
    ),
    staleMatcher: findsOneWidget,
    staleTexts: <String?>[
      SettingsLabels.staleBannerTitle,
      ?conn.asOf.staleLabel,
    ],
    chain: <Key>[
      const Key('m9s07-stale'),
      const ValueKey<String>('m9s07-row-0'),
      const Key('m9s07-asof'),
    ],
  );

  for (final c
      in <
        ({
          String name,
          Clock clock,
          Matcher staleMatcher,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[case13fresh, case13stale]) {
    testWidgets('M9S07-13 asof stale ${c.name}', (WidgetTester tester) async {
      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(conn),
          ),
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s07-stale')), c.staleMatcher);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s07-stale'))),
        c.staleTexts,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S07-14 state branches two cases ─────────────────────────────────────

  final ({
    String name,
    Stream<ConnectionsVm> Function(int) repoFn,
    Matcher loadMatcher,
    Matcher failMatcher,
    Matcher rowMatcher,
    Matcher retryMatcher,
    SettingsActions? acts,
  })
  case14loading = (
    name: 'loading',
    repoFn: (int call) => Stream<ConnectionsVm>.multi(
      (MultiStreamController<ConnectionsVm> c) {},
    ),
    loadMatcher: findsOneWidget,
    failMatcher: findsNothing,
    rowMatcher: findsNothing,
    retryMatcher: findsNothing,
    acts: null,
  );

  final ({
    String name,
    Stream<ConnectionsVm> Function(int) repoFn,
    Matcher loadMatcher,
    Matcher failMatcher,
    Matcher rowMatcher,
    Matcher retryMatcher,
    SettingsActions? acts,
  })
  case14fail = (
    name: 'fail',
    repoFn: (int call) => Stream<ConnectionsVm>.error(StateError('fail')),
    loadMatcher: findsNothing,
    failMatcher: findsOneWidget,
    rowMatcher: findsNothing,
    retryMatcher: findsOneWidget,
    acts: okActions(),
  );

  for (final c
      in <
        ({
          String name,
          Stream<ConnectionsVm> Function(int) repoFn,
          Matcher loadMatcher,
          Matcher failMatcher,
          Matcher rowMatcher,
          Matcher retryMatcher,
          SettingsActions? acts,
        })
      >[case14loading, case14fail]) {
    testWidgets('M9S07-14 state branch ${c.name}', (WidgetTester tester) async {
      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(connections: c.repoFn),
          actions: c.acts,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s07-loading')), c.loadMatcher);
      expect(find.byKey(const Key('m9s07-fail')), c.failMatcher);
      expect(find.byKey(const ValueKey<String>('m9s07-row-0')), c.rowMatcher);
      expect(find.text(SettingsLabels.retry), c.retryMatcher);
    });
  }

  // ── M9S07-15 retry ─────────────────────────────────────────────────────────

  testWidgets('M9S07-15 retry invalidate', (WidgetTester tester) async {
    final FakeSettingsOpsStatusRepository repo =
        FakeSettingsOpsStatusRepository(
          connections: (int call) => call == 0
              ? Stream<ConnectionsVm>.error(StateError('fail'))
              : one(conn),
        );

    await pumpConnections(
      tester,
      overrides: connectionsOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s07-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s07-row-0')), findsOneWidget);
    expect(repo.connectionsCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S07-16 all screen texts large font four cases ───────────────────────

  final ({String name, ConnectionsVm v, SettingsActions? acts, Matcher buttons})
  case16connOp = (
    name: 'conn_operator',
    v: conn,
    acts: okActions(),
    buttons: findsNWidgets(6),
  );
  final ({String name, ConnectionsVm v, SettingsActions? acts, Matcher buttons})
  case16teleOp = (
    name: 'tele_operator',
    v: tele,
    acts: okActions(),
    buttons: findsNWidgets(6),
  );
  final ({String name, ConnectionsVm v, SettingsActions? acts, Matcher buttons})
  case16lockedOp = (
    name: 'locked_operator',
    v: locked,
    acts: okActions(),
    buttons: findsNothing,
  );
  final ({String name, ConnectionsVm v, SettingsActions? acts, Matcher buttons})
  case16connViewer = (
    name: 'conn_viewer',
    v: conn,
    acts: null,
    buttons: findsNothing,
  );

  for (final c
      in <
        ({String name, ConnectionsVm v, SettingsActions? acts, Matcher buttons})
      >[case16connOp, case16teleOp, case16lockedOp, case16connViewer]) {
    testWidgets('M9S07-16 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpConnections(
        tester,
        overrides: connectionsOverrides(
          repo: FakeSettingsOpsStatusRepository(
            connections: (int call) => one(c.v),
          ),
          actions: c.acts,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final Set<String> allowed = c.acts != null
          ? <String>{
              ...connectionsAllowed(c.v),
              ...connectionsControlTexts(c.v),
            }
          : connectionsAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(find.byType(IconButton), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }
}
