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

  for (final (String name, BackupVm v, Matcher buttons)
      in <(String, BackupVm, Matcher)>[
        ('normal', normal, findsOneWidget),
        ('age_warn', ageWarn, findsOneWidget),
        ('empty', empty, findsOneWidget),
        ('sim', sim, findsNothing),
      ]) {
    testWidgets('M9S09-02 data variant button $name', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(v),
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
        backupLastTexts(v),
      );

      final ColorScheme cs = colorsOf(tester);
      final Icon lv = tester.widget<Icon>(find.byKey(const Key('m9s09-level')));
      expect(lv.icon, wantLevel(cs, v.level).$1);
      expect(lv.color, wantLevel(cs, v.level).$2);

      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-notice'))),
        <String?>[?v.noticeText],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-points'))),
        backupPointsTexts(v),
      );
      expect(
        find.byWidgetPredicate(isBackupPointRow),
        findsNWidgets(v.points.length),
      );
      for (final (int i, RestorePointRow p) in v.points.indexed) {
        expect(
          shownTexts(tester, find.byKey(Key('m9s09-point-$i'))),
          backupPointTexts(p),
        );
      }
      expect(shownTexts(tester, find.byKey(const Key('m9s09-run'))), <String?>[
        ?v.runAction?.label,
      ]);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        buttons,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-migration'))),
        <String?>[?v.migrationLink?.label],
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-03: backup now runs action, result shows headline + reasonCode ──────

  for (final (String name, ActionResult r) in <(String, ActionResult)>[
    ('accepted', results[0]),
    ('bio', results[1]),
    ('live_only', results[2]),
    ('no_stamp', results[3]),
    ('exists', results[4]),
    ('unreadable', results[5]),
    ('schema_skew', results[6]),
    ('sqlite', results[7]),
    ('chain_invalid', results[8]),
    ('rollback', results[9]),
  ]) {
    testWidgets('M9S09-03 backup run result $name', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(normal),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      expect(r.handoffRoute, isNull); // pre

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
        <String?>[r.headline, ?r.reasonCode],
      );
      expect(runOf(tester).enabled, isTrue);

      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s09-result-level')),
      );
      expect(ic.icon, wantLevel(cs, r.level).$1);
      expect(ic.color, wantLevel(cs, r.level).$2);

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
    final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
      backup: (int call) => one(normal),
    );
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Completer<ActionResult>().future,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();

    expect(normal.migrationLink, isNotNull); // pre

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

  for (final (
        String name,
        Future<ActionResult> Function(int call) factory,
        List<String?> firstNa,
        List<String?> firstRes,
        List<String?> secondNa,
        List<String?> secondRes,
      )
      in <
        (
          String,
          Future<ActionResult> Function(int call),
          List<String?>,
          List<String?>,
          List<String?>,
          List<String?>,
        )
      >[
        (
          'fail_then_ok',
          (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          <String?>[SettingsLabels.notAccepted],
          <String?>[],
          <String?>[],
          <String?>[results[0].headline, ?results[0].reasonCode],
        ),
        (
          'ok_then_fail',
          (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          <String?>[],
          <String?>[results[0].headline, ?results[0].reasonCode],
          <String?>[SettingsLabels.notAccepted],
          <String?>[],
        ),
      ]) {
    testWidgets('M9S09-05 fail success direction $name', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(normal),
      );
      final FakeSettingsActions actions = FakeSettingsActions(result: factory);

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
        firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-result'))),
        firstRes,
      );
      await tester.tap(find.byKey(const Key('m9s09-run')));
      await tester.pump();
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-not-accepted'))),
        secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-result'))),
        secondRes,
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
    final StreamController<BackupVm> feed = StreamController<BackupVm>();
    addTearDown(feed.close);
    final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
      backup: (int call) => feed.stream,
    );
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Future<ActionResult>.value(results[1]),
    );

    expect(locked.lockedLabel, isNotNull); // pre
    expect(locked.runAction, isNull); // pre

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

  for (final (
        String name,
        BackupVm v,
        List<String?> lockedTexts,
        Matcher buttons,
        Matcher link,
        List<Key> chain,
      )
      in <(String, BackupVm, List<String?>, Matcher, Matcher, List<Key>)>[
        (
          'locked',
          locked,
          <String?>[?locked.lockedLabel],
          findsNothing,
          findsNothing,
          <Key>[
            const Key('m9s09-locked'),
            const Key('m9s09-last'),
            const Key('m9s09-notice'),
            const Key('m9s09-points'),
            const Key('m9s09-asof'),
          ],
        ),
        (
          'normal',
          normal,
          <String?>[],
          findsOneWidget,
          findsOneWidget,
          <Key>[
            const Key('m9s09-last'),
            const Key('m9s09-run'),
            const Key('m9s09-notice'),
            const Key('m9s09-points'),
            const Key('m9s09-migration'),
            const Key('m9s09-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S09-07 locked vs normal $name', (WidgetTester tester) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(v),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(results[0]),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      expect(locked.runAction, isNull); // pre

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
        lockedTexts,
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        buttons,
      );
      expect(find.byKey(const Key('m9s09-migration')), link);
      for (int i = 1; i < chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
        );
      }
      expect(actions.ids, <SettingsActionId>[]);
      expect(opener.opened, <String>[]);

      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-points'))),
        backupPointsTexts(v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-last'))),
        backupLastTexts(v),
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-08: viewer (actions null) shows data, link; no button ───────────────

  for (final (String name, BackupVm v) in <(String, BackupVm)>[
    ('normal', normal),
    ('age_warn', ageWarn),
    ('locked', locked),
  ]) {
    testWidgets('M9S09-08 viewer no button data shown $name', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(v),
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
        backupLastTexts(v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-points'))),
        backupPointsTexts(v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-migration'))),
        <String?>[?v.migrationLink?.label],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-locked'))),
        <String?>[?v.lockedLabel],
      );
      expect(find.byKey(const Key('m9s09-last')), findsOneWidget);
      expect(repo.backupCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-09: link opens deepLink once, run stays zero ───────────────────────

  for (final (String name, BackupVm v) in <(String, BackupVm)>[
    ('normal', normal),
    ('empty', empty),
  ]) {
    testWidgets('M9S09-09 link opens deeplink run zero $name', (
      WidgetTester tester,
    ) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(v),
      );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(results[0]),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      expect(v.migrationLink, isNotNull); // pre

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

      expect(opener.opened, <String>[?v.migrationLink?.deepLink]);
      expect(actions.ids, <SettingsActionId>[]);
      expect(find.byKey(const Key('m9s09-result')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-10: asOf line and stale banner ─────────────────────────────────────

  for (final (
        String name,
        BackupVm v,
        Clock clock,
        List<String?> staleTexts,
        List<Key> chain,
      )
      in <(String, BackupVm, Clock, List<String?>, List<Key>)>[
        (
          'fresh',
          normal,
          FixedClock(kGoldenNowUtc),
          <String?>[],
          <Key>[const Key('m9s09-last'), const Key('m9s09-asof')],
        ),
        (
          'stale',
          stale,
          FixedClock(
            stale.asOf.observedAt
                .add(stale.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          <String?>[SettingsLabels.staleBannerTitle, ?stale.asOf.staleLabel],
          <Key>[
            const Key('m9s09-stale'),
            const Key('m9s09-last'),
            const Key('m9s09-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S09-10 asof stale $name', (WidgetTester tester) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(v),
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: clock,
        ),
      );

      expect(find.byKey(const Key('m9s09-asof')), findsOneWidget);
      expect(shownTexts(tester, find.byKey(const Key('m9s09-asof'))), <String?>[
        v.asOf.label,
      ]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s09-stale'))),
        staleTexts,
      );
      for (int i = 1; i < chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S09-11: loading and error states ───────────────────────────────────────

  for (final (
        String name,
        Stream<BackupVm> Function(int call) streamFactory,
        Matcher loading,
        Matcher fail,
        Matcher retry,
      )
      in <
        (String, Stream<BackupVm> Function(int call), Matcher, Matcher, Matcher)
      >[
        (
          'loading',
          (int call) =>
              Stream<BackupVm>.multi((MultiStreamController<BackupVm> m) {}),
          findsOneWidget,
          findsNothing,
          findsNothing,
        ),
        (
          'fail',
          (int call) => Stream<BackupVm>.error(StateError('fail')),
          findsNothing,
          findsOneWidget,
          findsOneWidget,
        ),
      ]) {
    testWidgets('M9S09-11 stream state $name', (WidgetTester tester) async {
      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: streamFactory,
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

      expect(find.byKey(const Key('m9s09-loading')), loading);
      expect(find.byKey(const Key('m9s09-fail')), fail);
      expect(find.text(SettingsLabels.retry), retry);
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

  for (final (
        String name,
        BackupVm v,
        SettingsActions? Function() actionsFactory,
        Set<String> allowed,
      )
      in <(String, BackupVm, SettingsActions? Function(), Set<String>)>[
        (
          'normal_operator',
          normal,
          okActions,
          <String>{...backupAllowed(normal), ...backupControlTexts(normal)},
        ),
        (
          'age_warn_operator',
          ageWarn,
          okActions,
          <String>{...backupAllowed(ageWarn), ...backupControlTexts(ageWarn)},
        ),
        (
          'sim_operator',
          sim,
          okActions,
          <String>{...backupAllowed(sim), ...backupControlTexts(sim)},
        ),
        (
          'locked_operator',
          locked,
          okActions,
          <String>{...backupAllowed(locked), ...backupControlTexts(locked)},
        ),
        ('normal_viewer', normal, noActions, backupAllowed(normal)),
        ('empty_viewer', empty, noActions, backupAllowed(empty)),
      ]) {
    testWidgets('M9S09-13 all texts allowed large font $name', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final FakeSettingsBackupRepository repo = FakeSettingsBackupRepository(
        backup: (int call) => one(v),
      );

      await pumpBackup(
        tester,
        overrides: backupOverrides(
          repo: repo,
          actions: actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byType(EditableText), findsNothing);
      final Set<String> allowedSet = allowed;
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowedSet));
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
