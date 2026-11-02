// test/alert_detail_test.dart - N02-01 ~ N02-06 (N-02 alert detail).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

void main() {
  final AlertDetailVm fullV = singleFixture(
    FixturePaths.m8AlertDetailFull,
    AlertDetailVm.fromJson,
  );
  final AlertDetailVm bareV = singleFixture(
    FixturePaths.m8AlertDetailNoLink,
    AlertDetailVm.fromJson,
  );
  final AlertDetailVm missingV = singleFixture(
    FixturePaths.m8AlertDetailMissing,
    AlertDetailVm.fromJson,
  );
  final ListResult<CommandReceipt> receipts = listFixture(
    FixturePaths.m8AlertAckReceipts3,
    CommandReceipt.fromJson,
  );
  final AlertItem full = fullV.item!;
  final AlertItem bare = bareV.item!;
  const String goneId = 'al_gone_01';
  final Clock fresh = FixedClock(kGoldenNowUtc);
  final Clock old = FixedClock(kGoldenNowUtc.add(const Duration(days: 2)));

  Stream<T> valueThenFail<T>(T v) async* {
    yield v;
    throw StateError('fail');
  }

  FakeShellAlertCenterRepository detailOf(
    Stream<AlertDetailVm> Function(int call) detail,
  ) => FakeShellAlertCenterRepository(
    center: (int call) => Stream<AlertCenterVm>.error(StateError('unused')),
    detail: detail,
  );

  FakeShellAlertCommandApi operatorApi() => FakeShellAlertCommandApi(
    receipt: (int call) => Future<CommandReceipt>.value(receipts.rows[1]),
  );

  // -- N02-01 fixed block order, two paragraphs, header --------------------
  testWidgets('N02-01 block order two paragraphs header', (
    WidgetTester tester,
  ) async {
    expect(full.raisedAtText, isNotNull); // pre
    expect(full.deepLink, isNotNull); // pre
    expect(full.ack, isNotNull); // pre
    expect(fullV.missingLabel, isNull); // pre

    final FakeShellAlertCenterRepository alerts = detailOf(
      (int call) => one(fullV),
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAlertDetail(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: operatorApi(),
        opener: opener,
        clock: fresh,
      ),
      alertId: full.alertId,
    );
    expect(alerts.alertIds, equals(<String>[full.alertId]));
    final Finder aof = find.byKey(const Key('n02-asof'));
    final Finder title = find.byKey(const Key('n02-title'));
    final Finder time = find.byKey(const Key('n02-time'));
    final Finder body = find.byKey(const Key('n02-body'));
    final Finder action = find.byKey(const Key('n02-action'));
    final Finder link = find.byKey(const Key('n02-link'));
    final Finder state = find.byKey(const ValueKey<String>('n02-state'));
    expect(tester.getTopLeft(aof).dy, lessThan(tester.getTopLeft(title).dy));
    expect(tester.getTopLeft(title).dy, lessThan(tester.getTopLeft(time).dy));
    expect(tester.getTopLeft(time).dy, lessThan(tester.getTopLeft(body).dy));
    expect(tester.getTopLeft(body).dy, lessThan(tester.getTopLeft(action).dy));
    expect(tester.getTopLeft(action).dy, lessThan(tester.getTopLeft(link).dy));
    expect(tester.getTopLeft(link).dy, lessThan(tester.getTopLeft(state).dy));
    expect(shownTexts(tester, aof), equals(<String?>[fullV.asOf.label]));
    expect(shownTexts(tester, title), equals(<String?>[full.title]));
    expect(shownTexts(tester, time), equals(<String?>[full.raisedAtText!]));
    expect(shownTexts(tester, body), equals(<String?>[full.bodyText]));
    expect(shownTexts(tester, action), equals(<String?>[full.actionLine]));
    expect(
      shownTexts(tester, link),
      equals(<String?>[ShellLabels.alertsEvidence]),
    );
    expect(find.byKey(const Key('n02-missing')), findsNothing);
    expect(find.text(ShellLabels.staleBannerTitle), findsNothing);
    await tester.tap(find.byKey(const Key('n02-link')));
    await tester.pump();
    expect(opener.opened, equals(<String>[full.deepLink!]));
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N02-02 absent fields null means absent --------------------------------
  testWidgets('N02-02 absent fields null means absent', (
    WidgetTester tester,
  ) async {
    expect(bare.raisedAtText, isNull); // pre
    expect(bare.deepLink, isNull); // pre
    expect(bare.ack, isNull); // pre

    final FakeShellAlertCenterRepository alerts = detailOf(
      (int call) => one(bareV),
    );
    await pumpAlertDetail(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: null,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
      alertId: bare.alertId,
    );
    expect(find.byKey(const Key('n02-time')), findsNothing);
    expect(find.byKey(const Key('n02-link')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n02-state')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n02-ack')), findsNothing);
    expect(find.byKey(const Key('n02-missing')), findsNothing);
    expect(find.byKey(const Key('n02-asof')), findsOneWidget);
    expect(find.byKey(const Key('n02-title')), findsOneWidget);
    expect(find.byKey(const Key('n02-body')), findsOneWidget);
    expect(find.byKey(const Key('n02-action')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N02-03 ack shared block and injection --------------------------------

  final List<
    ({
      String name,
      FakeShellAlertCommandApi? Function() apiFn,
      Future<void> Function(WidgetTester t, FakeShellAlertCommandApi? api)
      steps,
    })
  >
  n02_03cases =
      <
        ({
          String name,
          FakeShellAlertCommandApi? Function() apiFn,
          Future<void> Function(WidgetTester t, FakeShellAlertCommandApi? api)
          steps,
        })
      >[
        (
          name: 'operator',
          apiFn: operatorApi,
          steps: (WidgetTester t, FakeShellAlertCommandApi? api) async {
            await t.tap(find.byKey(const ValueKey<String>('n02-ack')));
            await t.pump();
            await t.pump();
            expect(api!.acks, equals(<String>[full.alertId]));
            expect(
              t
                  .widget<Text>(
                    find.byKey(const ValueKey<String>('n02-receipt')),
                  )
                  .data,
              receipts.rows[1].stateLabel,
            );
          },
        ),
        (
          name: 'viewer',
          apiFn: () => null,
          steps: (WidgetTester t, FakeShellAlertCommandApi? api) async {
            expect(find.byKey(const ValueKey<String>('n02-ack')), findsNothing);
            expect(
              find.byKey(const ValueKey<String>('n02-state')),
              findsOneWidget,
            );
          },
        ),
      ];

  for (final c in n02_03cases) {
    testWidgets('N02-03 ack shared block and injection ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(full.ack?.acked, isFalse); // pre
      final FakeShellAlertCommandApi? api = c.apiFn();
      final FakeShellAlertCenterRepository alerts = detailOf(
        (int call) => one(fullV),
      );
      await pumpAlertDetail(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: api,
          opener: RecordingLinkOpener(),
          clock: fresh,
        ),
        alertId: full.alertId,
      );
      await c.steps(tester, api);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- N02-04 state branches ------------------------------------------------

  final List<
    ({
      String name,
      Stream<AlertDetailVm> Function(int call) detailFn,
      Clock clock,
      String id,
      List<Key> present,
      List<Key> absent,
      bool banner,
      Future<void> Function(WidgetTester t) steps,
    })
  >
  n02_04cases =
      <
        ({
          String name,
          Stream<AlertDetailVm> Function(int call) detailFn,
          Clock clock,
          String id,
          List<Key> present,
          List<Key> absent,
          bool banner,
          Future<void> Function(WidgetTester t) steps,
        })
      >[
        (
          name: 'loading',
          detailFn: (int call) => Stream<AlertDetailVm>.multi(
            (MultiStreamController<AlertDetailVm> c) {},
          ),
          clock: fresh,
          id: full.alertId,
          present: <Key>[const Key('n02-loading')],
          absent: <Key>[const Key('n02-asof'), const Key('n02-fail')],
          banner: false,
          steps: (WidgetTester t) async {},
        ),
        (
          name: 'fail',
          detailFn: (int call) =>
              Stream<AlertDetailVm>.error(StateError('fail')),
          clock: fresh,
          id: full.alertId,
          present: <Key>[const Key('n02-fail')],
          absent: <Key>[const Key('n02-asof'), const Key('n02-loading')],
          banner: false,
          steps: (WidgetTester t) async {},
        ),
        (
          name: 'value_then_fail',
          detailFn: (int call) => valueThenFail(fullV),
          clock: fresh,
          id: full.alertId,
          present: <Key>[const Key('n02-fail')],
          absent: <Key>[const Key('n02-asof')],
          banner: false,
          steps: (WidgetTester t) async {
            expect(find.text(fullV.asOf.label), findsOneWidget);
          },
        ),
        (
          name: 'stale',
          detailFn: (int call) => one(fullV),
          clock: old,
          id: full.alertId,
          present: <Key>[const Key('n02-asof'), const Key('n02-title')],
          absent: <Key>[const Key('n02-fail'), const Key('n02-missing')],
          banner: true,
          steps: (WidgetTester t) async {
            expect(
              t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
              lessThan(t.getTopLeft(find.byKey(const Key('n02-title'))).dy),
            );
          },
        ),
        (
          name: 'stale_missing',
          detailFn: (int call) => one(missingV),
          clock: old,
          id: goneId,
          present: <Key>[const Key('n02-asof'), const Key('n02-missing')],
          absent: <Key>[
            const Key('n02-fail'),
            const Key('n02-title'),
            const Key('n02-loading'),
          ],
          banner: true,
          steps: (WidgetTester t) async {
            expect(
              t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
              lessThan(t.getTopLeft(find.byKey(const Key('n02-missing'))).dy),
            );
            expect(
              t.widget<Text>(find.byKey(const Key('n02-missing'))).data,
              missingV.missingLabel,
            );
          },
        ),
      ];

  for (final c in n02_04cases) {
    testWidgets('N02-04 state branches ${c.name}', (WidgetTester tester) async {
      expect(missingV.item, isNull); // pre
      expect(missingV.missingLabel, isNotNull); // pre
      final FakeShellAlertCenterRepository alerts = detailOf(c.detailFn);
      await pumpAlertDetail(
        tester,
        overrides: alertOverrides(
          alerts: alerts,
          api: null,
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
        alertId: c.id,
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

  // -- N02-05 retry ---------------------------------------------------------
  testWidgets('N02-05 retry', (WidgetTester tester) async {
    final FakeShellAlertCenterRepository alerts = detailOf(
      (int call) => call == 0
          ? Stream<AlertDetailVm>.error(StateError('fail'))
          : one(fullV),
    );
    await pumpAlertDetail(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: null,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
      alertId: full.alertId,
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('n02-fail')), findsNothing);
    expect(find.byKey(const Key('n02-asof')), findsOneWidget);
    expect(find.byKey(const Key('n02-title')), findsOneWidget);
    expect(alerts.alertIds, equals(<String>[full.alertId, full.alertId]));
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- N02-06 all texts large font ------------------------------------------

  final List<({AlertDetailVm v, String id})> n02_06cases =
      <({AlertDetailVm v, String id})>[
        (v: fullV, id: full.alertId),
        (v: bareV, id: bare.alertId),
        (v: missingV, id: goneId),
      ];

  for (final c in n02_06cases) {
    testWidgets(
      'N02-06 all texts large font ${c.v == fullV
          ? 'full'
          : c.v == bareV
          ? 'bare'
          : 'missing'}',
      (WidgetTester tester) async {
        final FakeShellAlertCenterRepository alerts = detailOf(
          (int call) => one(c.v),
        );
        await pumpAlertDetail(
          tester,
          overrides: alertOverrides(
            alerts: alerts,
            api: operatorApi(),
            opener: RecordingLinkOpener(),
            clock: fresh,
          ),
          alertId: c.id,
        );
        final Set<String?> allowed = alertDetailAllowed(c.v);
        final List<String?> shown = tester
            .widgetList<Text>(find.byType(Text))
            .map((Text t) => t.data)
            .toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(allowed));
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

  // -- N02-02 absent fields with operator injection (C4r14a-1 b) ------------
  // 주입 = operator 라서 n02-ack findsNothing 이 «ack null -> 버튼 부재» 를 시험한다.
  testWidgets('N02-02 absent fields null means absent operator', (
    WidgetTester tester,
  ) async {
    expect(bare.raisedAtText, isNull); // pre
    expect(bare.deepLink, isNull); // pre
    expect(bare.ack, isNull); // pre

    final FakeShellAlertCommandApi api = operatorApi();
    final FakeShellAlertCenterRepository alerts = detailOf(
      (int call) => one(bareV),
    );
    await pumpAlertDetail(
      tester,
      overrides: alertOverrides(
        alerts: alerts,
        api: api,
        opener: RecordingLinkOpener(),
        clock: fresh,
      ),
      alertId: bare.alertId,
    );
    expect(alerts.alertIds, equals(<String>[bare.alertId]));
    expect(find.byKey(const Key('n02-time')), findsNothing);
    expect(find.byKey(const Key('n02-link')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n02-state')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n02-ack')), findsNothing);
    expect(find.byKey(const ValueKey<String>('n02-receipt')), findsNothing);
    expect(find.byKey(const Key('n02-missing')), findsNothing);
    expect(find.byKey(const Key('n02-asof')), findsOneWidget);
    expect(find.byKey(const Key('n02-title')), findsOneWidget);
    expect(find.byKey(const Key('n02-body')), findsOneWidget);
    expect(find.byKey(const Key('n02-action')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
