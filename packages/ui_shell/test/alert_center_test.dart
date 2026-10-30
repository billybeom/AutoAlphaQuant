// test/alert_center_test.dart - N01-01 ~ N01-12 (N-01 alert center).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

void main() {
  final AlertCenterVm p0ack = singleFixture(
    FixturePaths.m8AlertCenterP0Ack,
    AlertCenterVm.fromJson,
  );
  final AlertCenterVm digest = singleFixture(
    FixturePaths.m8AlertCenterDigest,
    AlertCenterVm.fromJson,
  );
  final AlertCenterVm empty = singleFixture(
    FixturePaths.m8AlertCenterEmpty,
    AlertCenterVm.fromJson,
  );
  final AlertCenterVm p0only = singleFixture(
    FixturePaths.m8AlertCenterP0Only,
    AlertCenterVm.fromJson,
  );
  final AlertCenterVm reordered = singleFixture(
    FixturePaths.m8AlertCenterP0AckReordered,
    AlertCenterVm.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture(
    FixturePaths.m8AlertAckReceipts3,
    CommandReceipt.fromJson,
  );

  final Clock fresh = FixedClock(kGoldenNowUtc);
  final Clock old = FixedClock(kGoldenNowUtc.add(const Duration(days: 2)));

  Stream<T> valueThenFail<T>(T v) async* {
    yield v;
    throw StateError('fail');
  }

  FakeShellAlertCenterRepository centerOf(
    Stream<AlertCenterVm> Function(int call) center,
  ) => FakeShellAlertCenterRepository(
    center: center,
    detail: (int call) => Stream<AlertDetailVm>.error(StateError('unused')),
  );

  // -- N01-01 render order, row texts, received order -----------------------
  testWidgets('N01-01 render order row texts received order', (
    WidgetTester tester,
  ) async {
    expect(p0ack.sections.single.digestLabel, isNull); // pre
    expect(p0ack.emptyLabel, isNull); // pre
    final FakeShellAlertCenterRepository alerts = centerOf(
      (int call) => one(p0ack),
    );
    await pumpAlertCenter(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: null,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
    );
    expect(alerts.p0Onlys, equals(<bool>[false]));
    final Finder aof = find.byKey(const Key('n01-asof'));
    final Finder p0f = find.byKey(const Key('n01-p0-only'));
    final Finder pin0 = find.byKey(const ValueKey<String>('n01-pin-0'));
    final Finder pin1 = find.byKey(const ValueKey<String>('n01-pin-1'));
    final Finder pin2 = find.byKey(const ValueKey<String>('n01-pin-2'));
    final Finder sec0 = find.byKey(const ValueKey<String>('n01-sec-0'));
    final Finder row00 = find.byKey(const ValueKey<String>('n01-row-0-0'));
    final Finder row01 = find.byKey(const ValueKey<String>('n01-row-0-1'));
    expect(tester.getTopLeft(aof).dy, lessThan(tester.getTopLeft(p0f).dy));
    expect(tester.getTopLeft(p0f).dy, lessThan(tester.getTopLeft(pin0).dy));
    expect(tester.getTopLeft(pin0).dy, lessThan(tester.getTopLeft(pin1).dy));
    expect(tester.getTopLeft(pin1).dy, lessThan(tester.getTopLeft(pin2).dy));
    expect(tester.getTopLeft(pin2).dy, lessThan(tester.getTopLeft(sec0).dy));
    expect(tester.getTopLeft(sec0).dy, lessThan(tester.getTopLeft(row00).dy));
    expect(tester.getTopLeft(row00).dy, lessThan(tester.getTopLeft(row01).dy));
    expect(shownTexts(tester, aof), equals(<String?>[p0ack.asOf.label]));
    expect(p0ack.pinned, hasLength(3)); // ⓗ
    for (int i = 0; i < p0ack.pinned.length; i++) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('n01-pin-$i'))),
        equals(alertTileTexts(p0ack.pinned[i])),
      );
    }
    expect(find.byKey(const ValueKey<String>('n01-pin-3')), findsNothing);
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('n01-sec-0'))),
      equals(<String?>[p0ack.sections.single.headerText]),
    );
    expect(p0ack.sections.single.rows, hasLength(2)); // ⓗ
    final List<AlertItem> rows = p0ack.sections.single.rows;
    for (int i = 0; i < rows.length; i++) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('n01-row-0-$i'))),
        equals(alertTileTexts(rows[i])),
      );
    }
    expect(find.byKey(const ValueKey<String>('n01-row-0-2')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n01-digest-0')), findsNothing);
    expect(find.byKey(const Key('n01-empty')), findsNothing);
    expect(find.text(ShellLabels.staleBannerTitle), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N01-02 level appearance full AlertLevel switch -----------------------

  IconData wantIcon(AlertLevel l) => switch (l) {
    AlertLevel.p0 => Icons.error_outline,
    AlertLevel.p1 => Icons.warning_amber_outlined,
    AlertLevel.p2 => Icons.info_outline,
  };

  Color wantColor(ColorScheme cs, AlertLevel l) => switch (l) {
    AlertLevel.p0 => cs.error,
    AlertLevel.p1 => cs.tertiary,
    AlertLevel.p2 => cs.onSurfaceVariant,
  };

  final List<
    ({
      String name,
      AlertCenterVm vm,
      Future<void> Function(WidgetTester t) steps,
      List<(String, AlertItem)> rows,
    })
  >
  n01_02cases =
      <
        ({
          String name,
          AlertCenterVm vm,
          Future<void> Function(WidgetTester t) steps,
          List<(String, AlertItem)> rows,
        })
      >[
        (
          name: 'p0ack',
          vm: p0ack,
          steps: (WidgetTester t) async {},
          rows: <(String, AlertItem)>[
            ('n01-pin-0', p0ack.pinned[0]),
            ('n01-pin-1', p0ack.pinned[1]),
            ('n01-pin-2', p0ack.pinned[2]),
            ('n01-row-0-0', p0ack.sections.single.rows[0]),
            ('n01-row-0-1', p0ack.sections.single.rows[1]),
          ],
        ),
        (
          name: 'digest_open',
          vm: digest,
          steps: (WidgetTester t) async {
            await t.tap(find.byKey(const ValueKey<String>('n01-digest-1')));
            await t.pump();
          },
          rows: <(String, AlertItem)>[
            ('n01-row-0-0', digest.sections[0].rows[0]),
            ('n01-drow-1-0', digest.sections[1].digestRows[0]),
            ('n01-drow-1-1', digest.sections[1].digestRows[1]),
            ('n01-drow-1-2', digest.sections[1].digestRows[2]),
          ],
        ),
      ];

  for (final c in n01_02cases) {
    testWidgets('N01-02 level appearance switch ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(p0ack.pinned.first.level, AlertLevel.p0); // pre
      expect(p0ack.sections.single.rows.first.level, AlertLevel.p1); // pre
      expect(digest.sections[1].digestRows.first.level, AlertLevel.p2); // pre
      final FakeShellAlertCenterRepository alerts = centerOf(
        (int call) => one(c.vm),
      );
      await pumpAlertCenter(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: null,
          opener: RecordingLinkOpener(),
          clock: fresh,
        ),
      );
      await c.steps(tester);
      final ColorScheme cs = Theme.of(tester.element(find.byType(AlertCenter)))
          .colorScheme;
      for (final (String k, AlertItem item) in c.rows) {
        final Icon icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(ValueKey<String>(k)),
            matching: find.byType(Icon),
          ),
        );
        expect(icon.icon, wantIcon(item.level));
        expect(icon.color, wantColor(cs, item.level));
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- N01-03 P0-only filter resubscribes with argument ---------------------
  testWidgets('N01-03 P0-only filter resubscribe argument', (
    WidgetTester tester,
  ) async {
    expect(p0only.sections, isEmpty); // pre
    expect(digest.pinned, isEmpty); // pre
    final FakeShellAlertCenterRepository alerts =
        FakeShellAlertCenterRepository(
          center: (int call) => call == 1 ? one(p0only) : one(digest),
          detail: (int call) =>
              Stream<AlertDetailVm>.error(StateError('unused')),
        );
    await pumpAlertCenter(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: null,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
    );
    expect(find.byKey(const ValueKey<String>('n01-sec-0')), findsOneWidget);
    expect(
      tester.widget<FilterChip>(find.byKey(const Key('n01-p0-only'))).selected,
      isFalse,
    );
    await tester.tap(find.byKey(const Key('n01-p0-only')));
    await tester.pump();
    await tester.pump();
    expect(alerts.p0Onlys, equals(<bool>[false, true]));
    expect(
      tester.widget<FilterChip>(find.byKey(const Key('n01-p0-only'))).selected,
      isTrue,
    );
    expect(p0only.pinned, hasLength(3)); // ⓗ
    for (int i = 0; i < p0only.pinned.length; i++) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('n01-pin-$i'))),
        equals(alertTileTexts(p0only.pinned[i])),
      );
    }
    expect(find.byKey(const ValueKey<String>('n01-sec-0')), findsNothing);
    await tester.tap(find.byKey(const Key('n01-p0-only')));
    await tester.pump();
    await tester.pump();
    expect(alerts.p0Onlys, equals(<bool>[false, true]));
    expect(find.byKey(const ValueKey<String>('n01-sec-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('n01-pin-0')), findsNothing);
    expect(
      tester.widget<FilterChip>(find.byKey(const Key('n01-p0-only'))).selected,
      isFalse,
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N01-04 collapsed digest expand toggle --------------------------------
  testWidgets('N01-04 collapsed digest expand toggle', (
    WidgetTester tester,
  ) async {
    final AlertSection d = digest.sections[1];
    expect(d.digestLabel, isNotNull); // pre
    expect(d.rows, isEmpty); // pre
    expect(digest.sections.first.digestLabel, isNull); // pre
    final FakeShellAlertCenterRepository alerts = centerOf(
      (int call) => one(digest),
    );
    await pumpAlertCenter(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: null,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
    );
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('n01-digest-1'))),
      equals(<String?>[d.digestLabel]),
    );
    expect(find.byKey(const ValueKey<String>('n01-drow-1-0')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n01-digest-0')), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('n01-digest-1')));
    await tester.pump();
    expect(d.digestRows, hasLength(3)); // ⓗ
    for (int i = 0; i < d.digestRows.length; i++) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('n01-drow-1-$i'))),
        equals(alertTileTexts(d.digestRows[i])),
      );
    }
    expect(find.byKey(const ValueKey<String>('n01-drow-1-3')), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('n01-digest-1')));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('n01-drow-1-0')), findsNothing);
    expect(alerts.p0Onlys, equals(<bool>[false]));
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N01-05 empty inbox text from data ------------------------------------

  final List<({AlertCenterVm vm, String? want})> n01_05cases =
      <({AlertCenterVm vm, String? want})>[
        (vm: empty, want: empty.emptyLabel),
        (vm: p0ack, want: null),
      ];

  for (final c in n01_05cases) {
    testWidgets(
      'N01-05 empty inbox text from data ${c.want != null ? 'empty' : 'nonempty'}',
      (WidgetTester tester) async {
        expect(empty.emptyLabel, isNotNull); // pre
        expect(empty.pinned, isEmpty); // pre
        expect(empty.sections, isEmpty); // pre
        expect(p0ack.emptyLabel, isNull); // pre
        final FakeShellAlertCenterRepository alerts = centerOf(
          (int call) => one(c.vm),
        );
        await pumpAlertCenter(
          tester,
          overrides: alertOverrides(
            alerts: alerts,
            api: null,
            opener: RecordingLinkOpener(),
            clock: fresh,
          ),
        );
        final String? want = c.want;
        if (want != null) {
          expect(
            tester.widget<Text>(find.byKey(const Key('n01-empty'))).data,
            want,
          );
          expect(find.byKey(const ValueKey<String>('n01-pin-0')), findsNothing);
        } else {
          expect(find.byKey(const Key('n01-empty')), findsNothing);
          expect(
            find.byKey(const ValueKey<String>('n01-pin-0')),
            findsOneWidget,
          );
        }
        expect(find.byKey(const Key('n01-asof')), findsOneWidget);
        expect(find.byKey(const Key('n01-p0-only')), findsOneWidget);
        expect(find.text(ShellLabels.retry), findsNothing);
      },
    );
  }

  // -- N01-06 ack button data and injection ---------------------------------

  final List<({String name, CommandApi? api, List<bool> buttons})> n01_06cases =
      <({String name, CommandApi? api, List<bool> buttons})>[
        (
          name: 'operator',
          api: FakeShellAlertCommandApi(
            receipt: (int call) =>
                Future<CommandReceipt>.value(receipts.rows[0]),
          ),
          buttons: <bool>[true, false, false],
        ),
        (name: 'viewer', api: null, buttons: <bool>[false, false, false]),
      ];

  for (final c in n01_06cases) {
    testWidgets('N01-06 ack button data and injection ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(p0ack.pinned[0].ack?.acked, isFalse); // pre
      expect(p0ack.pinned[1].ack?.acked, isTrue); // pre
      expect(p0ack.pinned[2].ack, isNull); // pre
      final FakeShellAlertCenterRepository alerts = centerOf(
        (int call) => one(p0ack),
      );
      await pumpAlertCenter(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: c.api,
          opener: RecordingLinkOpener(),
          clock: fresh,
        ),
      );
      for (int i = 0; i < 3; i++) {
        final String? s = p0ack.pinned[i].ack?.stateLabel;
        if (s != null) {
          expect(
            tester
                .widget<Text>(find.byKey(ValueKey<String>('n01-pin-$i-state')))
                .data,
            s,
          );
        } else {
          expect(
            find.byKey(ValueKey<String>('n01-pin-$i-state')),
            findsNothing,
          );
        }
        expect(
          find.byKey(ValueKey<String>('n01-pin-$i-ack')),
          c.buttons[i] ? findsOneWidget : findsNothing,
        );
      }
      expect(
        find.byKey(const ValueKey<String>('n01-pin-0-receipt')),
        findsNothing,
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- N01-07 ack tap command once, receipt, busy ---------------------------

  final List<
    ({
      String name,
      Future<CommandReceipt> Function(int call) receiptFn,
      String? want,
      bool failText,
      bool busy,
    })
  >
  n01_07cases =
      <
        ({
          String name,
          Future<CommandReceipt> Function(int call) receiptFn,
          String? want,
          bool failText,
          bool busy,
        })
      >[
        (
          name: 'accepted',
          receiptFn: (int call) =>
              Future<CommandReceipt>.value(receipts.rows[0]),
          want: receipts.rows[0].stateLabel,
          failText: false,
          busy: false,
        ),
        (
          name: 'rejected',
          receiptFn: (int call) =>
              Future<CommandReceipt>.value(receipts.rows[2]),
          want: receipts.rows[2].stateLabel,
          failText: false,
          busy: false,
        ),
        (
          name: 'failed',
          receiptFn: (int call) =>
              Future<CommandReceipt>.error(StateError('fail')),
          want: null,
          failText: true,
          busy: false,
        ),
        (
          name: 'pending',
          receiptFn: (int call) => Completer<CommandReceipt>().future,
          want: null,
          failText: false,
          busy: true,
        ),
      ];

  for (final c in n01_07cases) {
    testWidgets('N01-07 ack tap command once receipt busy ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(receipts.rows[0].kind, CommandKind.alertAck); // pre
      expect(receipts.rows[2].state, CommandState.rejected); // pre
      final FakeShellAlertCommandApi api = FakeShellAlertCommandApi(
        receipt: c.receiptFn,
      );
      final FakeShellAlertCenterRepository alerts = centerOf(
        (int call) => one(p0ack),
      );
      await pumpAlertCenter(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: api,
          opener: RecordingLinkOpener(),
          clock: fresh,
        ),
      );
      await tester.tap(find.byKey(const ValueKey<String>('n01-pin-0-ack')));
      await tester.pump();
      await tester.pump();
      expect(api.acks, equals(<String>[p0ack.pinned[0].alertId]));
      final String? want = c.want;
      if (want != null) {
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey<String>('n01-pin-0-receipt')),
              )
              .data,
          want,
        );
      } else {
        expect(
          find.byKey(const ValueKey<String>('n01-pin-0-receipt')),
          findsNothing,
        );
      }
      expect(
        find.byKey(const ValueKey<String>('n01-pin-0-ack-fail')),
        c.failText ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('n01-pin-0-ack')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey<String>('n01-pin-0-ack')),
            )
            .onPressed,
        c.busy ? isNull : isNotNull,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey<String>('n01-pin-0-state')))
            .data,
        p0ack.pinned[0].ack!.stateLabel,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(alerts.p0Onlys, equals(<bool>[false]));
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- N01-08 row tap detailDeepLink ----------------------------------------

  final List<
    ({String name, AlertCenterVm vm, String keyStr, List<String> want})
  >
  n01_08cases =
      <({String name, AlertCenterVm vm, String keyStr, List<String> want})>[
        (
          name: 'linked',
          vm: p0ack,
          keyStr: 'n01-pin-0',
          want: <String>[p0ack.pinned[0].detailDeepLink!],
        ),
        (name: 'unlinked', vm: digest, keyStr: 'n01-row-0-0', want: <String>[]),
      ];

  for (final c in n01_08cases) {
    testWidgets('N01-08 row tap detailDeepLink ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(p0ack.pinned[0].detailDeepLink, isNotNull); // pre
      expect(digest.sections.first.rows.first.detailDeepLink, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeShellAlertCenterRepository alerts = centerOf(
        (int call) => one(c.vm),
      );
      await pumpAlertCenter(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: null,
          opener: opener,
          clock: fresh,
        ),
      );
      await tester.tap(find.byKey(ValueKey<String>(c.keyStr)));
      await tester.pump();
      expect(opener.opened, equals(c.want));
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- N01-09 state branches ------------------------------------------------

  final List<
    ({
      String name,
      Stream<AlertCenterVm> Function(int call) centerFn,
      Clock clock,
      List<Key> present,
      List<Key> absent,
      bool banner,
      Future<void> Function(WidgetTester t) steps,
    })
  >
  n01_09cases =
      <
        ({
          String name,
          Stream<AlertCenterVm> Function(int call) centerFn,
          Clock clock,
          List<Key> present,
          List<Key> absent,
          bool banner,
          Future<void> Function(WidgetTester t) steps,
        })
      >[
        (
          name: 'loading',
          centerFn: (int call) => Stream<AlertCenterVm>.multi(
            (MultiStreamController<AlertCenterVm> c) {},
          ),
          clock: fresh,
          present: <Key>[const Key('n01-loading')],
          absent: <Key>[const Key('n01-asof'), const Key('n01-fail')],
          banner: false,
          steps: (WidgetTester t) async {},
        ),
        (
          name: 'fail',
          centerFn: (int call) =>
              Stream<AlertCenterVm>.error(StateError('fail')),
          clock: fresh,
          present: <Key>[const Key('n01-fail')],
          absent: <Key>[const Key('n01-asof'), const Key('n01-loading')],
          banner: false,
          steps: (WidgetTester t) async {},
        ),
        (
          name: 'value_then_fail',
          centerFn: (int call) => valueThenFail(p0ack),
          clock: fresh,
          present: <Key>[const Key('n01-fail')],
          absent: <Key>[const Key('n01-asof')],
          banner: false,
          steps: (WidgetTester t) async {
            expect(find.text(p0ack.asOf.label), findsOneWidget);
          },
        ),
        (
          name: 'stale',
          centerFn: (int call) => one(p0ack),
          clock: old,
          present: <Key>[
            const Key('n01-asof'),
            const ValueKey<String>('n01-pin-0'),
          ],
          absent: <Key>[const Key('n01-fail')],
          banner: true,
          steps: (WidgetTester t) async {
            expect(
              t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
              lessThan(t.getTopLeft(find.byKey(const Key('n01-p0-only'))).dy),
            );
          },
        ),
        (
          name: 'stale_empty',
          centerFn: (int call) => one(empty),
          clock: old,
          present: <Key>[const Key('n01-asof'), const Key('n01-empty')],
          absent: <Key>[const Key('n01-fail')],
          banner: true,
          steps: (WidgetTester t) async {
            expect(
              t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
              lessThan(t.getTopLeft(find.byKey(const Key('n01-empty'))).dy),
            );
          },
        ),
      ];

  for (final c in n01_09cases) {
    testWidgets('N01-09 state branches ${c.name}', (WidgetTester tester) async {
      final FakeShellAlertCenterRepository alerts = centerOf(c.centerFn);
      await pumpAlertCenter(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: null,
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );
      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(
        find.text(ShellLabels.staleBannerTitle),
        c.banner ? findsOneWidget : findsNothing,
      );
      await c.steps(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  }

  // -- N01-10 retry ---------------------------------------------------------
  testWidgets('N01-10 retry', (WidgetTester tester) async {
    final FakeShellAlertCenterRepository alerts = centerOf(
      (int call) => call == 0
          ? Stream<AlertCenterVm>.error(StateError('fail'))
          : one(p0ack),
    );
    await pumpAlertCenter(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: null,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('n01-fail')), findsNothing);
    expect(find.byKey(const Key('n01-asof')), findsOneWidget);
    expect(alerts.p0Onlys, equals(<bool>[false, false]));
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N01-11 all texts large font ------------------------------------------

  final List<
    ({
      AlertCenterVm vm,
      Future<void> Function(WidgetTester t) steps,
      Set<String?> allowed,
    })
  >
  n01_11cases =
      <
        ({
          AlertCenterVm vm,
          Future<void> Function(WidgetTester t) steps,
          Set<String?> allowed,
        })
      >[
        (
          vm: p0ack,
          steps: (WidgetTester t) async {},
          allowed: alertCenterAllowed(p0ack),
        ),
        (
          vm: digest,
          steps: (WidgetTester t) async {
            await t.tap(find.byKey(const ValueKey<String>('n01-digest-1')));
            await t.pump();
          },
          allowed: alertCenterAllowed(digest),
        ),
      ];

  for (final c in n01_11cases) {
    testWidgets(
      'N01-11 all texts large font ${c.vm == p0ack ? 'p0ack' : 'digest_open'}',
      (WidgetTester tester) async {
        final FakeShellAlertCenterRepository alerts = centerOf(
          (int call) => one(c.vm),
        );
        await pumpAlertCenter(
          tester,
          overrides: alertOverrides(
            alerts: alerts,
            api: null,
            opener: RecordingLinkOpener(),
            clock: fresh,
          ),
        );
        await c.steps(tester);
        final List<String?> shown = tester
            .widgetList<Text>(find.byType(Text))
            .map((Text t) => t.data)
            .toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(c.allowed));
        }
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(
          () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(ShellLabels.retry), findsNothing);
      },
    );
  }

  // -- N01-12 reissue resets ack block state --------------------------------
  testWidgets('N01-12 reissue resets ack block state', (
    WidgetTester tester,
  ) async {
    expect(reordered.pinned[0].alertId, p0ack.pinned[1].alertId); // pre
    expect(reordered.pinned[1].alertId, p0ack.pinned[0].alertId); // pre

    final Completer<void> gate = Completer<void>();

    Stream<AlertCenterVm> makeStream(int call) async* {
      yield p0ack;
      await gate.future;
      yield reordered;
    }

    final FakeShellAlertCommandApi api = FakeShellAlertCommandApi(
      receipt: (int call) => Future<CommandReceipt>.value(receipts.rows[0]),
    );
    final FakeShellAlertCenterRepository alerts = centerOf(makeStream);
    await pumpAlertCenter(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: api,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('n01-pin-0-ack')));
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('n01-pin-0-receipt')))
          .data,
      receipts.rows[0].stateLabel,
    );
    gate.complete();
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('n01-pin-0-state')))
          .data,
      reordered.pinned[0].ack!.stateLabel,
    );
    expect(
      find.byKey(const ValueKey<String>('n01-pin-0-receipt')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('n01-pin-1-receipt')),
      findsNothing,
    );
    expect(api.acks, equals(<String>[p0ack.pinned[0].alertId]));
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
