// test/watchdog_board_test.dart — W01-01 ~ W01-08
//
// W-01 워치독 상태 테스트 — ⓡ 7줄(W01-01·02·03·04·06·07·08) · ⓗ 2줄(W01-01·02).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

(IconData, Color) _wantIcon(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

void main() {
  final WatchdogBoardVm delayed = singleFixture(
    FixturePaths.m8WatchdogDelayed,
    WatchdogBoardVm.fromJson,
  );
  final WatchdogBoardVm holiday = singleFixture(
    FixturePaths.m8WatchdogHoliday,
    WatchdogBoardVm.fromJson,
  );
  final WatchdogBoardVm paused = singleFixture(
    FixturePaths.m8WatchdogPaused,
    WatchdogBoardVm.fromJson,
  );
  final WatchdogBoardVm emptyV = singleFixture(
    FixturePaths.m8WatchdogEmpty,
    WatchdogBoardVm.fromJson,
  );

  // ── W01-01 행 글자·받은 차례·머리·하단 ───────────────────────────────────
  testWidgets('W01-01 rows text order header footer', (
    WidgetTester tester,
  ) async {
    expect(delayed.emptyLabel, isNull); // pre
    expect(delayed.lastReceivedText, isNotNull); // pre
    expect(delayed.holidayNotice, isNull); // pre
    expect(delayed.limitNotice, isNotNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeShellWatchdogRepository ops = FakeShellWatchdogRepository(
      watchdog: (int call) => Stream<WatchdogBoardVm>.value(delayed),
    );
    await pumpWatchdogBoard(
      tester,
      overrides: watchdogOverrides(
        ops: ops,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(ops.calls, 1);

    // 사슬 dy
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('w01-asof')),
      find.byKey(const Key('w01-received')),
      find.byKey(const ValueKey<String>('w01-row-0')),
      find.byKey(const ValueKey<String>('w01-row-1')),
      find.byKey(const ValueKey<String>('w01-row-2')),
      find.byKey(const ValueKey<String>('w01-row-3')),
      find.byKey(const ValueKey<String>('w01-row-4')),
      find.byKey(const ValueKey<String>('w01-row-5')),
      find.byKey(const Key('w01-limit')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }

    expect(shownTexts(tester, find.byKey(const Key('w01-asof'))), <String>[
      delayed.asOf.label,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('w01-received'))), <String>[
      delayed.lastReceivedText!,
    ]);
    expect(delayed.rows, hasLength(6)); // ⓗ
    for (final (int i, WatchdogCheck c) in delayed.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('w01-row-$i'))),
        watchdogRowTexts(c),
      );
    }
    expect(find.byKey(const ValueKey<String>('w01-row-6')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('w01-limit'))), <String>[
      delayed.limitNotice!,
    ]);
    expect(find.byKey(const Key('w01-holiday')), findsNothing);
    expect(find.byKey(const Key('w01-empty')), findsNothing);
    expect(find.text(ShellLabels.staleBannerTitle), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── W01-02 상태 모양 = level 전수 ─────────────────────────────────────────
  testWidgets('W01-02 state icon level exhaustive', (
    WidgetTester tester,
  ) async {
    expect(
      delayed.rows.any((WatchdogCheck r) => r.level == UiLevel.watch),
      isTrue,
    ); // pre
    expect(
      delayed.rows.any((WatchdogCheck r) => r.level == UiLevel.blocked),
      isTrue,
    ); // pre
    expect(
      paused.rows.any((WatchdogCheck r) => r.level == UiLevel.info),
      isTrue,
    ); // pre

    final List<({String name, WatchdogBoardVm v, int n})> cases =
        <({String name, WatchdogBoardVm v, int n})>[
          (name: 'delayed', v: delayed, n: 6),
          (name: 'holiday', v: holiday, n: 5),
          (name: 'paused', v: paused, n: 5),
        ];

    for (final c in cases) {
      await pumpWatchdogBoard(
        tester,
        overrides: watchdogOverrides(
          ops: FakeShellWatchdogRepository(
            watchdog: (int call) => Stream<WatchdogBoardVm>.value(c.v),
          ),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      expect(c.v.rows, hasLength(c.n)); // ⓗ
      final ColorScheme cs = Theme.of(
        tester.element(find.byType(WatchdogBoard)),
      ).colorScheme;
      for (int i = 0; i < c.v.rows.length; i++) {
        final WatchdogCheck row = c.v.rows[i];
        final Icon icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(ValueKey<String>('w01-row-$i')),
            matching: find.byType(Icon),
          ),
        );
        final (IconData wantIco, Color wantCol) = _wantIcon(cs, row.level);
        expect(icon.icon, wantIco);
        expect(icon.color, wantCol);
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    }
  });

  // ── W01-03 행 탭 = route ──────────────────────────────────────────────────
  testWidgets('W01-03 row tap route', (WidgetTester tester) async {
    expect(delayed.rows[1].route, isNotNull); // pre
    expect(delayed.rows[0].route, isNull); // pre

    final List<({String name, int k, List<String> want})> cases =
        <({String name, int k, List<String> want})>[
          (name: 'linked', k: 1, want: <String>[delayed.rows[1].route!]),
          (name: 'unlinked', k: 0, want: <String>[]),
        ];

    for (final c in cases) {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpWatchdogBoard(
        tester,
        overrides: watchdogOverrides(
          ops: FakeShellWatchdogRepository(
            watchdog: (int call) => Stream<WatchdogBoardVm>.value(delayed),
          ),
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      await tester.tap(find.byKey(ValueKey<String>('w01-row-${c.k}')));
      await tester.pump();
      expect(opener.opened, c.want);
      expect(find.text(ShellLabels.retry), findsNothing);
    }
  });

  // ── W01-04 빈 = 데이터 ────────────────────────────────────────────────────
  testWidgets('W01-04 empty label data driven', (WidgetTester tester) async {
    expect(emptyV.rows, isEmpty); // pre
    expect(emptyV.emptyLabel, isNotNull); // pre
    expect(delayed.emptyLabel, isNull); // pre

    final List<({String name, WatchdogBoardVm v, String? want})> cases =
        <({String name, WatchdogBoardVm v, String? want})>[
          (name: 'empty', v: emptyV, want: emptyV.emptyLabel),
          (name: 'delayed', v: delayed, want: null),
        ];

    for (final c in cases) {
      await pumpWatchdogBoard(
        tester,
        overrides: watchdogOverrides(
          ops: FakeShellWatchdogRepository(
            watchdog: (int call) => Stream<WatchdogBoardVm>.value(c.v),
          ),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      final String? want = c.want;
      if (want != null) {
        expect(
          tester.widget<Text>(find.byKey(const Key('w01-empty'))).data,
          want,
        );
        expect(find.byKey(const ValueKey<String>('w01-row-0')), findsNothing);
      } else {
        expect(find.byKey(const Key('w01-empty')), findsNothing);
        expect(find.byKey(const ValueKey<String>('w01-row-0')), findsOneWidget);
      }
      expect(find.byKey(const Key('w01-asof')), findsOneWidget);
      expect(find.text(ShellLabels.retry), findsNothing);
    }
  });

  // ── W01-05 갈래 × 상태 ────────────────────────────────────────────────────
  testWidgets('W01-05 state branches', (WidgetTester tester) async {
    final List<
      ({
        String name,
        FakeShellWatchdogRepository Function() opsFactory,
        Clock clock,
        List<Key> present,
        List<Key> absent,
        bool banner,
        Future<void> Function(WidgetTester t)? flow,
      })
    >
    cases =
        <
          ({
            String name,
            FakeShellWatchdogRepository Function() opsFactory,
            Clock clock,
            List<Key> present,
            List<Key> absent,
            bool banner,
            Future<void> Function(WidgetTester t)? flow,
          })
        >[
          (
            name: 'loading',
            opsFactory: () => FakeShellWatchdogRepository(
              watchdog: (int call) => Stream<WatchdogBoardVm>.multi(
                (MultiStreamController<WatchdogBoardVm> c) {},
              ),
            ),
            clock: FixedClock(kGoldenNowUtc),
            present: <Key>[const Key('w01-loading')],
            absent: <Key>[const Key('w01-asof'), const Key('w01-fail')],
            banner: false,
            flow: null,
          ),
          (
            name: 'fail',
            opsFactory: () => FakeShellWatchdogRepository(
              watchdog: (int call) =>
                  Stream<WatchdogBoardVm>.error(StateError('fail')),
            ),
            clock: FixedClock(kGoldenNowUtc),
            present: <Key>[const Key('w01-fail')],
            absent: <Key>[const Key('w01-asof'), const Key('w01-loading')],
            banner: false,
            flow: null,
          ),
          (
            name: 'value_then_fail',
            opsFactory: () => FakeShellWatchdogRepository(
              watchdog: (int call) => valueThenFail(delayed),
            ),
            clock: FixedClock(kGoldenNowUtc),
            present: <Key>[const Key('w01-fail')],
            absent: <Key>[const Key('w01-asof')],
            banner: false,
            flow: (WidgetTester t) async {
              expect(find.text(delayed.asOf.label), findsOneWidget);
            },
          ),
          (
            name: 'stale',
            opsFactory: () => FakeShellWatchdogRepository(
              watchdog: (int call) => Stream<WatchdogBoardVm>.value(delayed),
            ),
            clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
            present: <Key>[
              const Key('w01-asof'),
              const Key('w01-received'),
              const ValueKey<String>('w01-row-0'),
              const Key('w01-limit'),
            ],
            absent: <Key>[const Key('w01-fail')],
            banner: true,
            flow: (WidgetTester t) async {
              expect(
                t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
                lessThan(
                  t
                      .getTopLeft(
                        find.byKey(const ValueKey<String>('w01-row-0')),
                      )
                      .dy,
                ),
              );
            },
          ),
          (
            name: 'stale_empty',
            opsFactory: () => FakeShellWatchdogRepository(
              watchdog: (int call) => Stream<WatchdogBoardVm>.value(emptyV),
            ),
            clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
            present: <Key>[
              const Key('w01-asof'),
              const Key('w01-empty'),
              const Key('w01-limit'),
            ],
            absent: <Key>[const Key('w01-fail')],
            banner: true,
            flow: (WidgetTester t) async {
              expect(
                t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy,
                lessThan(t.getTopLeft(find.byKey(const Key('w01-empty'))).dy),
              );
            },
          ),
        ];

    for (final c in cases) {
      await pumpWatchdogBoard(
        tester,
        overrides: watchdogOverrides(
          ops: c.opsFactory(),
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
      if (c.flow != null) {
        await c.flow!(tester);
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
  });

  // ── W01-06 재시도 ─────────────────────────────────────────────────────────
  testWidgets('W01-06 retry', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeShellWatchdogRepository ops = FakeShellWatchdogRepository(
      watchdog: (int call) => call == 0
          ? Stream<WatchdogBoardVm>.error(StateError('fail'))
          : one(delayed),
    );
    await pumpWatchdogBoard(
      tester,
      overrides: watchdogOverrides(
        ops: ops,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('w01-fail')), findsNothing);
    expect(find.byKey(const Key('w01-asof')), findsOneWidget);
    expect(ops.calls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── W01-07 화면 Text 전부 · 큰 글꼴 ──────────────────────────────────────
  testWidgets('W01-07 all texts large font', (WidgetTester tester) async {
    final List<({String name, WatchdogBoardVm v})> cases =
        <({String name, WatchdogBoardVm v})>[
          (name: 'delayed', v: delayed),
          (name: 'holiday', v: holiday),
          (name: 'paused', v: paused),
        ];

    for (final c in cases) {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      await pumpWatchdogBoard(
        tester,
        overrides: watchdogOverrides(
          ops: FakeShellWatchdogRepository(
            watchdog: (int call) => Stream<WatchdogBoardVm>.value(c.v),
          ),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      final Set<String> allowed = watchdogAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    }
  });

  // ── W01-08 머리 수신 · 하단 휴장·한계 고지 = 데이터 ───────────────────────
  testWidgets('W01-08 received holiday limit data driven', (
    WidgetTester tester,
  ) async {
    expect(holiday.lastReceivedText, isNotNull); // pre
    expect(emptyV.lastReceivedText, isNull); // pre
    expect(holiday.holidayNotice, isNotNull); // pre
    expect(emptyV.holidayNotice, isNull); // pre
    expect(holiday.limitNotice, isNotNull); // pre
    expect(emptyV.limitNotice, isNotNull); // pre

    final List<({String name, WatchdogBoardVm v, List<Key> chain})> cases =
        <({String name, WatchdogBoardVm v, List<Key> chain})>[
          (
            name: 'holiday',
            v: holiday,
            chain: <Key>[
              const Key('w01-asof'),
              const Key('w01-received'),
              const ValueKey<String>('w01-row-4'),
              const Key('w01-holiday'),
              const Key('w01-limit'),
            ],
          ),
          (
            name: 'empty',
            v: emptyV,
            chain: <Key>[
              const Key('w01-asof'),
              const Key('w01-empty'),
              const Key('w01-limit'),
            ],
          ),
        ];

    for (final c in cases) {
      await pumpWatchdogBoard(
        tester,
        overrides: watchdogOverrides(
          ops: FakeShellWatchdogRepository(
            watchdog: (int call) => Stream<WatchdogBoardVm>.value(c.v),
          ),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      // 사슬 dy
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }

      // received
      final String? received = c.v.lastReceivedText;
      if (received != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('w01-received'))),
          <String>[received],
        );
      } else {
        expect(find.byKey(const Key('w01-received')), findsNothing);
        expect(find.byKey(const Key('w01-asof')), findsOneWidget);
      }

      // holiday
      final String? hol = c.v.holidayNotice;
      if (hol != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('w01-holiday'))),
          <String>[hol],
        );
      } else {
        expect(find.byKey(const Key('w01-holiday')), findsNothing);
        expect(find.byKey(const Key('w01-limit')), findsOneWidget);
      }

      expect(shownTexts(tester, find.byKey(const Key('w01-limit'))), <String>[
        c.v.limitNotice!,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    }
  });
}
