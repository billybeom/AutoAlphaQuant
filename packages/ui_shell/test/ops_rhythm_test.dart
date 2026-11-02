// test/ops_rhythm_test.dart — T02-01 ~ T02-08
//
// H-02 운영 리듬 표 테스트 — ⓡ 7줄(T02-01·02·03·04·06·07·08) · ⓗ 1줄(T02-01).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/src/common/shell_common.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

void main() {
  final ListResult<OpsRhythmRow> rows = listFixture(
    FixturePaths.m8OpsRhythmRows,
    OpsRhythmRow.fromJson,
  );
  final ListResult<OpsRhythmRow> empty = listFixture(
    FixturePaths.m8OpsRhythmEmpty,
    OpsRhythmRow.fromJson,
  );

  // ── T02-01 정상 5행 · 순서 · 열 ───────────────────────────────────────────
  testWidgets('T02-01 normal 5 rows order columns', (
    WidgetTester tester,
  ) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeShellOpsSummaryRepository ops = FakeShellOpsSummaryRepository(
      rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(rows),
    );
    final Clock clock = FixedClock(kGoldenNowUtc);
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(ops: ops, opener: opener, clock: clock),
    );
    expect(ops.rhythmCalls, 1);
    expect(shownTexts(tester, find.byKey(const Key('h02-asof'))), <String>[
      rows.asOf.label,
    ]);
    expect(rows.emptyLabel, isNull); // pre
    expect(find.byKey(const Key('h02-empty')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('h02-head'))), <String>[
      ShellLabels.rhythmColumnItem,
      ShellLabels.rhythmColumnNext,
    ]);
    expect(rows.rows, hasLength(5)); // ⓗ
    for (final (int i, OpsRhythmRow r) in rows.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('h02-row-$i'))),
        rhythmRowTexts(r),
      );
      expect(
        tester.widget<Text>(find.byKey(ValueKey<String>('h02-title-$i'))).data,
        r.title,
      );
      expect(
        tester.widget<Text>(find.byKey(ValueKey<String>('h02-when-$i'))).data,
        r.whenText,
      );
      final String? dDay = r.dDayText;
      if (dDay != null) {
        expect(
          tester.widget<Text>(find.byKey(ValueKey<String>('h02-dday-$i'))).data,
          dDay,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h02-dday-$i')), findsNothing);
      }
    }
    expect(find.byKey(const ValueKey<String>('h02-row-5')), findsNothing);

    // 사슬 dy
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('h02-asof')),
      find.byKey(const Key('h02-head')),
      for (final (int i, OpsRhythmRow _) in rows.rows.indexed)
        find.byKey(ValueKey<String>('h02-row-$i')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }

    // 승인·확인 버튼 0
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── T02-02 행 탭 = route ──────────────────────────────────────────────────
  testWidgets('T02-02 row tap route', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(rows),
        ),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    // 전제 — 루프 밖
    for (final OpsRhythmRow r in rows.rows) {
      expect(r.route, isNotNull); // pre
    }
    for (final (int i, OpsRhythmRow _) in rows.rows.indexed) {
      await tester.tap(find.byKey(ValueKey<String>('h02-title-$i')));
      await tester.pump();
    }
    expect(opener.opened, <String>[
      for (final OpsRhythmRow r in rows.rows) r.route!,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── T02-03 route·dDay null = 반응 없음 · 행은 그린다 ─────────────────────
  testWidgets('T02-03 null route no reaction row still rendered', (
    WidgetTester tester,
  ) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final ListResult<OpsRhythmRow> noRoute = rows.copyWith(
      rows: <OpsRhythmRow>[rows.rows[0].copyWith(route: null, dDayText: null)],
    );
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(noRoute),
        ),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(find.byKey(const ValueKey<String>('h02-row-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('h02-dday-0')), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('h02-title-0')));
    await tester.pump();
    expect(opener.opened, <String>[]);
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey<String>('h02-row-0')))
          .onTap,
      isNull,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('h02-title-0')))
          .data,
      rows.rows[0].title,
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── T02-04 모름(NOT_LOADED) ────────────────────────────────────────────────
  testWidgets('T02-04 not loaded empty kind', (WidgetTester tester) async {
    expect(empty.emptyKind, EmptyKind.notLoaded); // pre
    expect(empty.rows, isEmpty); // pre
    expect(empty.emptyLabel, isNotNull); // pre
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(empty),
        ),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('h02-empty'))).data,
      empty.emptyLabel,
    );
    expect(find.byKey(const Key('h02-head')), findsNothing);
    expect(find.byKey(const ValueKey<String>('h02-row-0')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('h02-asof'))), <String>[
      empty.asOf.label,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── T02-05 갈래 × 상태 ────────────────────────────────────────────────────
  group('T02-05 state branches', () {
    final List<
      ({
        String name,
        FakeShellOpsSummaryRepository Function() opsFactory,
        Clock clock,
        bool skeleton,
        bool error,
        bool header,
        bool stale,
        bool row0,
        String? wantEmpty,
      })
    >
    cases =
        <
          ({
            String name,
            FakeShellOpsSummaryRepository Function() opsFactory,
            Clock clock,
            bool skeleton,
            bool error,
            bool header,
            bool stale,
            bool row0,
            String? wantEmpty,
          })
        >[
          (
            name: 'loading',
            opsFactory: () {
              final StreamController<ListResult<OpsRhythmRow>> ctrl =
                  StreamController<ListResult<OpsRhythmRow>>();
              addTearDown(() {
                unawaited(ctrl.close());
              });
              return FakeShellOpsSummaryRepository(
                rhythm: (int call) => ctrl.stream,
              );
            },
            clock: FixedClock(kGoldenNowUtc),
            skeleton: true,
            error: false,
            header: false,
            stale: false,
            row0: false,
            wantEmpty: null,
          ),
          (
            name: 'fail',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.error(StateError('fail')),
            ),
            clock: FixedClock(kGoldenNowUtc),
            skeleton: false,
            error: true,
            header: false,
            stale: false,
            row0: false,
            wantEmpty: null,
          ),
          (
            name: 'normal',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.value(rows),
            ),
            clock: FixedClock(kGoldenNowUtc),
            skeleton: false,
            error: false,
            header: true,
            stale: false,
            row0: true,
            wantEmpty: null,
          ),
          (
            name: 'normal_stale',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.value(rows),
            ),
            clock: FixedClock(
              DateTime.utc(2026, 9, 3, 10), // kGoldenNowUtc + 3 days
            ),
            skeleton: false,
            error: false,
            header: true,
            stale: true,
            row0: true,
            wantEmpty: null,
          ),
          (
            name: 'not_loaded',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.value(empty),
            ),
            clock: FixedClock(kGoldenNowUtc),
            skeleton: false,
            error: false,
            header: true,
            stale: false,
            row0: false,
            wantEmpty: empty.emptyLabel,
          ),
          (
            name: 'not_loaded_stale',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.value(empty),
            ),
            clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
            skeleton: false,
            error: false,
            header: true,
            stale: true,
            row0: false,
            wantEmpty: empty.emptyLabel,
          ),
        ];

    for (final c in cases) {
      testWidgets('T02-05 ${c.name}', (WidgetTester tester) async {
        await pumpOpsRhythm(
          tester,
          overrides: opsRhythmOverrides(
            ops: c.opsFactory(),
            opener: RecordingLinkOpener(),
            clock: c.clock,
          ),
        );
        expect(
          find.byKey(const Key('h02-loading')),
          c.skeleton ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('h02-fail')),
          c.error ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('h02-asof')),
          c.header ? findsOneWidget : findsNothing,
        );
        expect(
          find.text(ShellLabels.staleBannerTitle),
          c.stale ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const ValueKey<String>('h02-row-0')),
          c.row0 ? findsOneWidget : findsNothing,
        );
        expect(
          find.text(ShellLabels.retry),
          c.error ? findsOneWidget : findsNothing,
        );
        // 빈 문장 (전제는 if 밖)
        expect(empty.emptyLabel, isNotNull); // pre
        final String? wantEmpty = c.wantEmpty;
        if (wantEmpty != null) {
          expect(
            tester.widget<Text>(find.byKey(const Key('h02-empty'))).data,
            wantEmpty,
          );
        } else {
          expect(find.byKey(const Key('h02-empty')), findsNothing);
        }
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
      });
    }
  });

  // ── T02-06 에러와 재시도 ──────────────────────────────────────────────────
  group('T02-06 error and retry', () {
    final List<
      ({
        String name,
        FakeShellOpsSummaryRepository Function() opsFactory,
        String? wantLastAsOf,
      })
    >
    cases =
        <
          ({
            String name,
            FakeShellOpsSummaryRepository Function() opsFactory,
            String? wantLastAsOf,
          })
        >[
          (
            name: 'fail_then_rows',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) => call == 0
                  ? Stream<ListResult<OpsRhythmRow>>.error(StateError('fail'))
                  : Stream<ListResult<OpsRhythmRow>>.value(rows),
            ),
            wantLastAsOf: null,
          ),
          (
            name: 'value_then_fail',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) => call == 0
                  ? valueThenFail(rows)
                  : Stream<ListResult<OpsRhythmRow>>.value(rows),
            ),
            wantLastAsOf: rows.asOf.label,
          ),
        ];

    for (final c in cases) {
      testWidgets('T02-06 ${c.name}', (WidgetTester tester) async {
        final FakeShellOpsSummaryRepository ops = c.opsFactory();
        await pumpOpsRhythm(
          tester,
          overrides: opsRhythmOverrides(
            ops: ops,
            opener: RecordingLinkOpener(),
            clock: FixedClock(kGoldenNowUtc),
          ),
        );
        expect(find.byKey(const Key('h02-fail')), findsOneWidget);
        expect(
          tester
              .widget<ShellErrorView>(find.byKey(const Key('h02-fail')))
              .lastAsOfLabel,
          c.wantLastAsOf,
        );
        await tester.tap(find.text(ShellLabels.retry));
        await tester.pump();
        await tester.pump();
        expect(find.byKey(const Key('h02-fail')), findsNothing);
        expect(find.byKey(const Key('h02-asof')), findsOneWidget);
        expect(ops.rhythmCalls, 2);
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }
  });

  // ── T02-07 화면 Text 전부 ─────────────────────────────────────────────────
  group('T02-07 all texts shown', () {
    final List<({String name, ListResult<OpsRhythmRow> fixture})> cases =
        <({String name, ListResult<OpsRhythmRow> fixture})>[
          (name: 'rows', fixture: rows),
          (name: 'not_loaded', fixture: empty),
        ];

    for (final c in cases) {
      testWidgets('T02-07 ${c.name}', (WidgetTester tester) async {
        await pumpOpsRhythm(
          tester,
          overrides: opsRhythmOverrides(
            ops: FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.value(c.fixture),
            ),
            opener: RecordingLinkOpener(),
            clock: FixedClock(kGoldenNowUtc),
          ),
        );
        final Set<String> allowed = rhythmAllowed(c.fixture);
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
    }
  });

  // ── T02-08 큰 글꼴 ────────────────────────────────────────────────────────
  testWidgets('T02-08 large font', (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(
      () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
    );
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(rows),
        ),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('h02-asof')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // ── R14 test-only (C4r13a-3) ─────────────────────────────────────────────
  // T02-03 route null 만 — dDay 는 그대로 그린다(X07)
  testWidgets('T02-03 null route only keeps dday', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final OpsRhythmRow row = rows.rows[0];
    expect(row.dDayText, isNotNull); // pre
    final ListResult<OpsRhythmRow> noRoute = rows.copyWith(
      rows: <OpsRhythmRow>[row.copyWith(route: null)],
    );
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(noRoute),
        ),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('h02-dday-0')))
          .data,
      row.dDayText,
    );
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey<String>('h02-row-0')))
          .onTap,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey<String>('h02-title-0')));
    await tester.pump();
    expect(opener.opened, <String>[]);
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('h02-row-0'))),
      <String>[row.title, row.whenText, row.dDayText!],
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // T02-03 dDay null 만 — 행 탭은 route 를 연다
  testWidgets('T02-03 null dday only keeps route', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final OpsRhythmRow row = rows.rows[0];
    expect(row.route, isNotNull); // pre
    final ListResult<OpsRhythmRow> noDDay = rows.copyWith(
      rows: <OpsRhythmRow>[row.copyWith(dDayText: null)],
    );
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(noDDay),
        ),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(find.byKey(const ValueKey<String>('h02-dday-0')), findsNothing);
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey<String>('h02-row-0')))
          .onTap,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey<String>('h02-title-0')));
    await tester.pump();
    expect(opener.opened, <String>[row.route!]);
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('h02-row-0'))),
      <String>[row.title, row.whenText],
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // 빈 + emptyLabel null 표본(테스트 안 값) — 빈 갈래 · 머리·행·빈 문장 0(X09)
  testWidgets('T02-04 empty rows with null empty label', (
    WidgetTester tester,
  ) async {
    final ListResult<OpsRhythmRow> blank = empty.copyWith(emptyLabel: null);
    expect(blank.rows, isEmpty); // pre
    expect(blank.emptyLabel, isNull); // pre
    await pumpOpsRhythm(
      tester,
      overrides: opsRhythmOverrides(
        ops: FakeShellOpsSummaryRepository(
          rhythm: (int call) => Stream<ListResult<OpsRhythmRow>>.value(blank),
        ),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(shownTexts(tester, find.byKey(const Key('h02-asof'))), <String>[
      blank.asOf.label,
    ]);
    expect(find.byKey(const Key('h02-head')), findsNothing);
    expect(find.text(ShellLabels.rhythmColumnItem), findsNothing);
    expect(find.text(ShellLabels.rhythmColumnNext), findsNothing);
    expect(find.byKey(const Key('h02-empty')), findsNothing);
    expect(find.byKey(const ValueKey<String>('h02-row-0')), findsNothing);
    expect(find.byKey(const Key('h02-loading')), findsNothing);
    expect(find.byKey(const Key('h02-fail')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
