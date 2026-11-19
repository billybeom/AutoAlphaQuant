// test/backup_test.dart
//
// M9 S09 — BackupRestore widget tests (37 tests).
//
// 🔴 ASCII only · no Korean literals · if 0 · collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

// ── Level look helpers (lib copy) ───────────────────────────────────────────────

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

ColorScheme colorsOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(BackupRestore))).colorScheme;

ButtonStyleButton runOf(WidgetTester tester) =>
    tester.widget<ButtonStyleButton>(find.byKey(const Key('m9s09-run')));

void main() {
  final BackupVm normal = singleFixture(
    FixturePaths.m9Backup,
    BackupVm.fromJson,
  );
  final BackupVm ageWarn = singleFixture(
    FixturePaths.m9BackupAgeWarn,
    BackupVm.fromJson,
  );
  final BackupVm empty = singleFixture(
    FixturePaths.m9BackupEmpty,
    BackupVm.fromJson,
  );
  final BackupVm sim = singleFixture(
    FixturePaths.m9BackupSim,
    BackupVm.fromJson,
  );
  final BackupVm locked = singleFixture(
    FixturePaths.m9BackupLocked,
    BackupVm.fromJson,
  );
  final BackupVm stale = singleFixture(
    FixturePaths.m9BackupStale,
    BackupVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9BackupActionResults,
    ActionResult.fromJson,
  ).rows;

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );
  SettingsActions? noActions() => null;

  // ── M9S09-01: block order and texts (normal · operator) ─────────────────────

  testWidgets('M9S09-01 block order texts normal operator', (
    WidgetTester tester,
  ) async {
    final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
      backup: (int call) => one(normal),
    );
    await pumpBackup(
      tester,
      overrides: backupOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(
      shownTexts(tester, find.byKey(const Key('m9s09-last'))),
      backupLastTexts(normal),
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s09-run'))), <String?>[
      ?normal.runAction?.label,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('m9s09-notice'))), <String?>[
      ?normal.noticeText,
    ]);
    expect(
      shownTexts(tester, find.byKey(const Key('m9s09-points'))),
      backupPointsTexts(normal),
    );
    expect(
      find.byWidgetPredicate(isBackupPointRow),
      findsNWidgets(normal.points.length),
    );
    for (final (int i, RestorePointRow p) in normal.points.indexed) {
      expect(
        shownTexts(tester, find.byKey(Key('m9s09-point-$i'))),
        backupPointTexts(p),
      );
    }
    expect(
      shownTexts(tester, find.byKey(const Key('m9s09-migration'))),
      <String?>[?normal.migrationLink?.label],
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s09-asof'))), <String?>[
      normal.asOf.label,
    ]);

    expect(
      tester.getTopLeft(find.byKey(const Key('m9s09-last'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-run'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('m9s09-run'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-notice'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('m9s09-notice'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-points'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('m9s09-points'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-migration'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('m9s09-migration'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-asof'))).dy),
    );

    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(1),
    );
    expect(find.byKey(const Key('m9s09-stale')), findsNothing);
    expect(find.byKey(const Key('m9s09-locked')), findsNothing);
    expect(find.byKey(const Key('m9s09-result')), findsNothing);
    expect(find.byKey(const Key('m9s09-not-accepted')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S09-02: data variants and button presence ──────────────────────────────

  for (final c in <({String name, BackupVm v, Matcher buttons})>[
    (name: 'normal', v: normal, buttons: findsOneWidget),
    (name: 'age_warn', v: ageWarn, buttons: findsOneWidget),
    (name: 'empty', v: empty, buttons: findsOneWidget),
    (name: 'sim', v: sim, buttons: findsNothing),
  ]) {
    testWidgets('M9S09-02 data variant button ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(c.v),
      );
      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s09-last')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-last'))),
        backupLastTexts(c.v),
      );

      final ColorScheme cs = colorsOf(tester);
      final Icon lv = tester.widget<Icon>(find.byKey(const Key('m9s09-level')));
      expect(lv.icon, wantLevel(cs, c.v.level).$1);
      expect(lv.color, wantLevel(cs, c.v.level).$2);

      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-notice'))),
        <String?>[?c.v.noticeText],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-points'))),
        backupPointsTexts(c.v),
      );
      expect(
        find.byWidgetPredicate(isBackupPointRow),
        findsNWidgets(c.v.points.length),
      );
      for (final (int i, RestorePointRow p) in c.v.points.indexed) {
        expect(
          shownTexts(tester, find.byKey(Key('m9s09-point-$i'))),
          backupPointTexts(p),
        );
      }
      expect(shownTexts(tester, find.byKey(const Key('m9s09-run'))), <String?>[
        ?c.v.runAction?.label,
      ]);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-migration'))),
        <String?>[?c.v.migrationLink?.label],
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-03: backup now runs action, result shows headline + reasonCode ──────

  for (final c in <({String name, ActionResult r})>[
    (name: 'accepted', r: results[0]),
    (name: 'bio', r: results[1]),
    (name: 'live_only', r: results[2]),
    (name: 'no_stamp', r: results[3]),
    (name: 'exists', r: results[4]),
    (name: 'unreadable', r: results[5]),
    (name: 'schema_skew', r: results[6]),
    (name: 'sqlite', r: results[7]),
    (name: 'chain_invalid', r: results[8]),
    (name: 'rollback', r: results[9]),
  ]) {
    testWidgets('M9S09-03 backup run result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(normal),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(actions.ids, <SettingsActionId>[]);
      await tester.tap(find.byKey(const Key('m9s09-run')));
      await tester.pump();
      await tester.pump();
      expect(actions.ids, backupRunIds(normal));
      expect(actions.argsSeen, backupRunArgs(normal));
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      expect(runOf(tester).enabled, isTrue);
      expect(find.byKey(const Key('m9s09-migration')), findsOneWidget);

      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s09-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);

      expect(
        tester.getTopLeft(find.byKey(const Key('m9s09-run'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-result'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s09-result'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s09-notice'))).dy),
      );

      expect(actions.watchCalls, 0);
      expect(repo.backupCalls, 1);
      expect(opener.opened, <String>[]);
      expect(find.byKey(const Key('m9s09-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-04: busy blocks second tap, link still opens ───────────────────────

  testWidgets('M9S09-04 busy blocks second tap link opens', (
    WidgetTester tester,
  ) async {
    expect(normal.migrationLink, isNotNull); // pre

    final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
      backup: (int call) => one(normal),
    );
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Completer<ActionResult>().future,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();

    await pumpBackup(
      tester,
      overrides: backupOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s09-run')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m9s09-run')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m9s09-migration')));
    await tester.pump();
    expect(actions.ids, backupRunIds(normal));
    expect(opener.opened, <String>[?normal.migrationLink?.deepLink]);

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
    expect(find.byKey(const Key('m9s09-result')), findsNothing);
    expect(find.byKey(const Key('m9s09-not-accepted')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S09-05: failure <-> success two directions ──────────────────────────────

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
      >[
        (
          name: 'fail_then_ok',
          factory: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[0].headline, ?results[0].reasonCode],
        ),
        (
          name: 'ok_then_fail',
          factory: (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          firstNa: <String?>[],
          firstRes: <String?>[results[0].headline, ?results[0].reasonCode],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
      ]) {
    testWidgets('M9S09-05 fail success direction ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(normal),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: c.factory,
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s09-run')));
      await tester.pump();
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-result'))),
        c.firstRes,
      );
      await tester.tap(find.byKey(const Key('m9s09-run')));
      await tester.pump();
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-result'))),
        c.secondRes,
      );
      expect(actions.ids, <SettingsActionId>[
        ...backupRunIds(normal),
        ...backupRunIds(normal),
      ]);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-06: result stays after VM turns locked ──────────────────────────────

  testWidgets('M9S09-06 result stays vm turns locked', (
    WidgetTester tester,
  ) async {
    expect(locked.lockedLabel, isNotNull); // pre
    expect(locked.runAction, isNull); // pre

    final StreamController<BackupVm> feed = StreamController<BackupVm>();
    addTearDown(feed.close);
    final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
      backup: (int call) => feed.stream,
    );
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Future<ActionResult>.value(results[1]),
    );

    feed.add(normal);
    await pumpBackup(
      tester,
      overrides: backupOverrides(
        repo: repo,
        actions: actions,
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s09-run')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('m9s09-locked')), findsNothing);
    feed.add(locked);
    await tester.pump();
    await tester.pump();

    expect(shownTexts(tester, find.byKey(const Key('m9s09-locked'))), <String?>[
      ?locked.lockedLabel,
    ]);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    expect(find.byKey(const Key('m9s09-migration')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('m9s09-result'))), <String?>[
      results[1].headline,
      ?results[1].reasonCode,
    ]);

    final List<Key> chain = <Key>[
      const Key('m9s09-locked'),
      const Key('m9s09-last'),
      const Key('m9s09-result'),
      const Key('m9s09-notice'),
      const Key('m9s09-points'),
      const Key('m9s09-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }

    expect(actions.ids, backupRunIds(normal));
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S09-07: locked shows label, no button/link; normal shows both ───────────

  for (final c
      in <
        ({
          String name,
          BackupVm v,
          List<String?> lockedTexts,
          Matcher buttons,
          Matcher link,
          List<Key> chain,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          buttons: findsNothing,
          link: findsNothing,
          chain: <Key>[
            const Key('m9s09-locked'),
            const Key('m9s09-last'),
            const Key('m9s09-notice'),
            const Key('m9s09-points'),
            const Key('m9s09-asof'),
          ],
        ),
        (
          name: 'normal',
          v: normal,
          lockedTexts: <String?>[],
          buttons: findsOneWidget,
          link: findsOneWidget,
          chain: <Key>[
            const Key('m9s09-last'),
            const Key('m9s09-run'),
            const Key('m9s09-notice'),
            const Key('m9s09-points'),
            const Key('m9s09-migration'),
            const Key('m9s09-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S09-07 locked vs normal ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(locked.runAction, isNull); // pre

      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(c.v),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(results[0]),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s09-last')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-locked'))),
        c.lockedTexts,
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(find.byKey(const Key('m9s09-migration')), c.link);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(actions.ids, <SettingsActionId>[]);
      expect(opener.opened, <String>[]);

      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-points'))),
        backupPointsTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-last'))),
        backupLastTexts(c.v),
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-08: viewer (actions null) shows data, link; no button ───────────────

  for (final c in <({String name, BackupVm v})>[
    (name: 'normal', v: normal),
    (name: 'age_warn', v: ageWarn),
    (name: 'locked', v: locked),
  ]) {
    testWidgets('M9S09-08 viewer no button data shown ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(c.v),
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
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
      expect(find.byKey(const Key('m9s09-run')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-last'))),
        backupLastTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-points'))),
        backupPointsTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-migration'))),
        <String?>[?c.v.migrationLink?.label],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(find.byKey(const Key('m9s09-last')), findsOneWidget);
      expect(repo.backupCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-09: link opens deepLink once, run stays zero ───────────────────────

  for (final c in <({String name, BackupVm v})>[
    (name: 'normal', v: normal),
    (name: 'empty', v: empty),
  ]) {
    testWidgets('M9S09-09 link opens deeplink run zero ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.v.migrationLink, isNotNull); // pre

      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(c.v),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(results[0]),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s09-migration')));
      await tester.pump();

      expect(opener.opened, <String>[?c.v.migrationLink?.deepLink]);
      expect(actions.ids, <SettingsActionId>[]);
      expect(find.byKey(const Key('m9s09-result')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-10: asOf line and stale banner ─────────────────────────────────────

  for (final c
      in <
        ({
          String name,
          BackupVm v,
          Clock clock,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[
        (
          name: 'fresh',
          v: normal,
          clock: FixedClock(kGoldenNowUtc),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s09-last'), const Key('m9s09-asof')],
        ),
        (
          name: 'stale',
          v: stale,
          clock: FixedClock(
            stale.asOf.observedAt
                .add(stale.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?stale.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s09-stale'),
            const Key('m9s09-last'),
            const Key('m9s09-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S09-10 asof stale ${c.name}', (WidgetTester tester) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(c.v),
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s09-asof')), findsOneWidget);
      expect(shownTexts(tester, find.byKey(const Key('m9s09-asof'))), <String?>[
        c.v.asOf.label,
      ]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-stale'))),
        c.staleTexts,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-11: loading and error states ───────────────────────────────────────

  for (final c
      in <
        ({
          String name,
          Stream<BackupVm> Function(int call) streamFactory,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          streamFactory: (int call) =>
              Stream<BackupVm>.multi((MultiStreamController<BackupVm> m) {}),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          streamFactory: (int call) =>
              Stream<BackupVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S09-11 stream state ${c.name}', (WidgetTester tester) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: c.streamFactory,
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s09-loading')), c.loading);
      expect(find.byKey(const Key('m9s09-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const Key('m9s09-last')), findsNothing);
      expect(find.byKey(const Key('m9s09-run')), findsNothing);
    });
  }

  // ── M9S09-12: retry invalidates provider ─────────────────────────────────────

  testWidgets('M9S09-12 retry invalidates provider', (
    WidgetTester tester,
  ) async {
    final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
      backup: (int call) =>
          call == 0 ? Stream<BackupVm>.error(StateError('fail')) : one(normal),
    );

    await pumpBackup(
      tester,
      overrides: backupOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('m9s09-fail')), findsNothing);
    expect(find.byKey(const Key('m9s09-last')), findsOneWidget);
    expect(repo.backupCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S09-13: all texts within allowed set, large font ───────────────────────

  for (final c
      in <
        ({
          String name,
          BackupVm v,
          SettingsActions? Function() actionsFactory,
          Set<String> allowed,
        })
      >[
        (
          name: 'normal_operator',
          v: normal,
          actionsFactory: okActions,
          allowed: <String>{
            ...backupAllowed(normal),
            ...backupControlTexts(normal),
          },
        ),
        (
          name: 'age_warn_operator',
          v: ageWarn,
          actionsFactory: okActions,
          allowed: <String>{
            ...backupAllowed(ageWarn),
            ...backupControlTexts(ageWarn),
          },
        ),
        (
          name: 'sim_operator',
          v: sim,
          actionsFactory: okActions,
          allowed: <String>{...backupAllowed(sim), ...backupControlTexts(sim)},
        ),
        (
          name: 'locked_operator',
          v: locked,
          actionsFactory: okActions,
          allowed: <String>{
            ...backupAllowed(locked),
            ...backupControlTexts(locked),
          },
        ),
        (
          name: 'normal_viewer',
          v: normal,
          actionsFactory: noActions,
          allowed: backupAllowed(normal),
        ),
        (
          name: 'empty_viewer',
          v: empty,
          actionsFactory: noActions,
          allowed: backupAllowed(empty),
        ),
      ]) {
    testWidgets('M9S09-13 all texts allowed large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(c.v),
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: c.actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byType(EditableText), findsNothing);
      final Set<String> allowed = c.allowed;
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(
        find.byWidgetPredicate((Widget w) => w is IconButton),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }
}
