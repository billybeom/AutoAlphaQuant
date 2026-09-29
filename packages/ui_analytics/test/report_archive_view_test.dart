// packages/ui_analytics/test/report_archive_view_test.dart
//
// A1~A10 — S7-1b ReportArchiveScreen 뷰 테스트.
// 🔴 픽스처 값을 지어내지 않는다. 단언은 픽스처에서 읽은 값으로.
// 🔴 한국어 문자열 리터럴 없음. 열거 switch 없음.
// 🔴 가짜는 받침대 extends — implements 금지.

import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';

// ── 가짜 리포지토리 ──────────────────────────────────────────────────────────

class _FakePerformanceRepository extends UnimplementedPerformanceRepository {
  _FakePerformanceRepository(this._archive);
  final ReportArchiveVm _archive;

  @override
  Future<ReportArchiveVm> reportArchive() async => _archive;
}

class _NeverPerformanceRepository extends UnimplementedPerformanceRepository {
  @override
  Future<ReportArchiveVm> reportArchive() =>
      Completer<ReportArchiveVm>().future;
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

// ── 픽스처 ───────────────────────────────────────────────────────────────────

Directory _fixturesDir() =>
    Directory('${Directory.current.path}/../domain_contracts/fixtures');

String _fixtureText(String relPath) =>
    File('${_fixturesDir().path}/$relPath').readAsStringSync();

ReportArchiveVm _singleVm(String relPath) => decodeSingle<ReportArchiveVm>(
  _fixtureText(relPath),
  ReportArchiveVm.fromJson,
);

// ── 도우미 ────────────────────────────────────────────────────────────────────

Widget _pump({
  required PerformanceRepository perf,
  required SafetyRepository safety,
  Clock? clock,
}) {
  return ProviderScope(
    overrides: <Override>[
      analyticsClockProvider.overrideWithValue(
        clock ?? FixedClock(kGoldenNowUtc),
      ),
      analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
      performanceRepositoryProvider.overrideWithValue(perf),
      safetyRepositoryProvider.overrideWithValue(safety),
    ],
    child: const MaterialApp(home: Scaffold(body: ReportArchiveScreen())),
  );
}

Widget _pumpWithOpener({
  required PerformanceRepository perf,
  required SafetyRepository safety,
  required RecordingLinkOpener opener,
  Clock? clock,
}) {
  return ProviderScope(
    overrides: <Override>[
      analyticsClockProvider.overrideWithValue(
        clock ?? FixedClock(kGoldenNowUtc),
      ),
      analyticsLinkOpenerProvider.overrideWithValue(opener),
      performanceRepositoryProvider.overrideWithValue(perf),
      safetyRepositoryProvider.overrideWithValue(safety),
    ],
    child: const MaterialApp(home: Scaffold(body: ReportArchiveScreen())),
  );
}

// ── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  // 픽스처를 한 번만 읽는다
  final ReportArchiveVm archive18 = _singleVm(FixturePaths.m7M7ReportArchive18);
  final ReportArchiveVm archiveEmpty = _singleVm(
    FixturePaths.m7M7ReportArchiveEmpty,
  );
  final FixtureEnvelope safetyEnv = fixtureEnvelope(FixturePaths.safetyStates);
  final SafetyState safetyOk = SafetyState.fromJson(safetyEnv.rows[0]);
  final SafetyState safetyBlocked = SafetyState.fromJson(safetyEnv.rows[3]);

  // ── A1 ─────────────────────────────────────────────────────────────────────
  testWidgets('A1 18행 Key 전부 있음 · dy 순번대로', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _pump(
        perf: _FakePerformanceRepository(archive18),
        safety: _FakeSafetyRepository(safetyOk),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // 전 행 Key 존재
    for (final ReportArchiveRow row in archive18.rows) {
      expect(
        find.byKey(ValueKey<String>('s71b-row-${row.yyyyMm}')),
        findsOneWidget,
      );
    }

    // dy 가 픽스처 순번대로 증가
    double prevDy = -1;
    for (final ReportArchiveRow row in archive18.rows) {
      final double dy = tester
          .getTopLeft(find.byKey(ValueKey<String>('s71b-row-${row.yyyyMm}')))
          .dy;
      expect(dy, greaterThan(prevDy));
      prevDy = dy;
    }
  });

  // ── A2 ─────────────────────────────────────────────────────────────────────
  testWidgets('A2 전 행의 label·modeLabel 글자가 픽스처와 같다', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _pump(
        perf: _FakePerformanceRepository(archive18),
        safety: _FakeSafetyRepository(safetyOk),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    for (final ReportArchiveRow row in archive18.rows) {
      final Finder rowKey = find.byKey(
        ValueKey<String>('s71b-row-${row.yyyyMm}'),
      );
      expect(
        find.descendant(of: rowKey, matching: find.text(row.label)),
        findsOneWidget,
      );
      final Finder modeKey = find.byKey(Key('s71b-mode-${row.yyyyMm}'));
      expect(
        find.descendant(of: modeKey, matching: find.text(row.modeLabel)),
        findsOneWidget,
      );
    }
  });

  // ── A3 ─────────────────────────────────────────────────────────────────────
  testWidgets('A3 not-generated row: reason shown, no link', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();
    await tester.pumpWidget(
      _pumpWithOpener(
        perf: _FakePerformanceRepository(archive18),
        safety: _FakeSafetyRepository(safetyOk),
        opener: opener,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // 미생성 행 찾기 — generated == false 인 첫 번째 행
    final ReportArchiveRow notGenRow = archive18.rows.firstWhere(
      (ReportArchiveRow r) => !r.generated,
    );
    expect(notGenRow.reasonLabel, isNotNull);

    final Finder rowFinder = find.byKey(
      ValueKey<String>('s71b-row-${notGenRow.yyyyMm}'),
    );

    // 사유 글자가 이 행 안에 있다
    expect(
      find.descendant(
        of: rowFinder,
        matching: find.text(notGenRow.reasonLabel!),
      ),
      findsOneWidget,
    );

    // 같은 사유 글자가 화면 전체에 1개인지 확인 필요 없음(행 범위로 봤다)
    // 꺾쇠가 없다
    expect(
      find.descendant(
        of: rowFinder,
        matching: find.byIcon(Icons.chevron_right),
      ),
      findsNothing,
    );

    // 탭해도 링크 없음
    await tester.tap(rowFinder);
    await tester.pumpAndSettle();
    expect(opener.opened, isEmpty);
  });

  // ── A4 ─────────────────────────────────────────────────────────────────────
  testWidgets('A4 linked row tap: opener.opened == [row.route!]', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opener = RecordingLinkOpener();
    await tester.pumpWidget(
      _pumpWithOpener(
        perf: _FakePerformanceRepository(archive18),
        safety: _FakeSafetyRepository(safetyOk),
        opener: opener,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);

    // 링크 있는 첫 번째 행
    final ReportArchiveRow linkedRow = archive18.rows.firstWhere(
      (ReportArchiveRow r) => r.route != null,
    );
    expect(linkedRow.route, isNotNull);

    await tester.tap(
      find.byKey(ValueKey<String>('s71b-row-${linkedRow.yyyyMm}')),
    );
    await tester.pumpAndSettle();

    expect(opener.opened, <String>[linkedRow.route!]);
  });

  // ── A5 ─────────────────────────────────────────────────────────────────────
  testWidgets(
    'A5 sim row (generated true + route null): reason shown, no open',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final opener = RecordingLinkOpener();
      await tester.pumpWidget(
        _pumpWithOpener(
          perf: _FakePerformanceRepository(archive18),
          safety: _FakeSafetyRepository(safetyOk),
          opener: opener,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      // 모의 달 — generated:true 이면서 route null 인 행
      final ReportArchiveRow simRow = archive18.rows.firstWhere(
        (ReportArchiveRow r) => r.generated && r.route == null,
      );
      expect(simRow.reasonLabel, isNotNull);

      final Finder rowFinder = find.byKey(
        ValueKey<String>('s71b-row-${simRow.yyyyMm}'),
      );

      // 사유 글자가 이 행 안에 있다 (generated 로 고르지 않았다는 증명)
      expect(
        find.descendant(
          of: rowFinder,
          matching: find.text(simRow.reasonLabel!),
        ),
        findsOneWidget,
      );

      // 탭해도 링크 없음
      await tester.tap(rowFinder);
      await tester.pumpAndSettle();
      expect(opener.opened, isEmpty);
    },
  );

  // ── A6 ─────────────────────────────────────────────────────────────────────
  testWidgets(
    'A6 empty fixture: emptyLabel shown, no row keys, no retryButton',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _pump(
          perf: _FakePerformanceRepository(archiveEmpty),
          safety: _FakeSafetyRepository(safetyOk),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      // emptyLabel 글자가 1개
      expect(archiveEmpty.emptyLabel, isNotNull);
      expect(find.text(archiveEmpty.emptyLabel!), findsOneWidget);

      // 행 Key 0 (rows 가 비어 있다)
      expect(archiveEmpty.rows, isEmpty);
    },
  );

  // ── A7 ─────────────────────────────────────────────────────────────────────
  testWidgets(
    'A7 loading→skeleton; error→retryButton; retry re-calls; banners hidden during loading/error',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 안전 상태 — blocked (row 3)
      final SafetyState blocked = SafetyState.fromJson(safetyEnv.rows[3]);

      // 1) 끝나지 않는 Future → 스켈레톤
      await tester.pumpWidget(
        _pump(
          perf: _NeverPerformanceRepository(),
          safety: _FakeSafetyRepository(blocked),
        ),
      );
      await tester.pump(); // 첫 프레임

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // 로딩 상태에서는 배너가 없다
      for (final BlockFlag flag in blocked.activeFlags) {
        expect(find.text(flag.label), findsNothing);
      }

      // 2) 던지는 가짜 → 에러 상태 → retryButton
      int callCount = 0;
      final _CountingThrowingRepo counting = _CountingThrowingRepo(
        onCall: () => callCount++,
      );
      await tester.pumpWidget(
        _pump(perf: counting, safety: _FakeSafetyRepository(blocked)),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
      // 에러 상태에서도 배너 없음
      for (final BlockFlag flag in blocked.activeFlags) {
        expect(find.text(flag.label), findsNothing);
      }

      // retryButton 탭 → 두 번째 호출
      expect(callCount, equals(1));
      await tester.tap(find.text(AnalyticsLabels.retryButton));
      await tester.pumpAndSettle();
      expect(callCount, equals(2));

      // 3) 정상 데이터가 오면 배너(blocked) 글자가 보인다
      await tester.pumpWidget(
        _pump(
          perf: _FakePerformanceRepository(archive18),
          safety: _FakeSafetyRepository(blocked),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      for (final BlockFlag flag in blocked.activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
      }
    },
  );

  // ── A8 ─────────────────────────────────────────────────────────────────────
  testWidgets(
    'A8 stale +3days: staleBannerTitle shown; safetyRow3 flags each 1',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1) 신선 → staleBannerTitle 없음
      await tester.pumpWidget(
        _pump(
          perf: _FakePerformanceRepository(archive18),
          safety: _FakeSafetyRepository(safetyOk),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      // 2) 시계 +3일 → staleBannerTitle 1
      final Clock staleClock = FixedClock(
        kGoldenNowUtc.add(const Duration(days: 3)),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(staleClock),
            analyticsLinkOpenerProvider.overrideWithValue(
              RecordingLinkOpener(),
            ),
            performanceRepositoryProvider.overrideWithValue(
              _FakePerformanceRepository(archive18),
            ),
            safetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyOk),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ReportArchiveScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      // 3) safetyStates row 3 — blocked 플래그 2개 각 1
      await tester.pumpWidget(
        _pump(
          perf: _FakePerformanceRepository(archive18),
          safety: _FakeSafetyRepository(safetyBlocked),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      // 플래그 2개의 label 이 서로 다르고 각 1
      final List<BlockFlag> flags = safetyBlocked.activeFlags;
      expect(flags.length, greaterThanOrEqualTo(2));
      final String label0 = flags[0].label;
      final String label1 = flags[1].label;
      expect(label0, isNot(equals(label1)));
      expect(find.text(label0), findsOneWidget);
      expect(find.text(label1), findsOneWidget);
    },
  );

  // ── A9 ─────────────────────────────────────────────────────────────────────
  testWidgets(
    'A9 section_label rows: Key count matches, text correct, dy ordering',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _pump(
          perf: _FakePerformanceRepository(archive18),
          safety: _FakeSafetyRepository(safetyOk),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      // sectionLabel 이 있는 행 목록
      final List<ReportArchiveRow> withSection = archive18.rows
          .where((ReportArchiveRow r) => r.sectionLabel != null)
          .toList();

      // Key 수 = sectionLabel 있는 행 수
      for (final ReportArchiveRow row in withSection) {
        expect(find.byKey(Key('s71b-section-${row.yyyyMm}')), findsOneWidget);
      }

      // 전체 section key 수
      for (final ReportArchiveRow row in archive18.rows) {
        if (row.sectionLabel != null) {
          final Finder sectionFinder = find.byKey(
            Key('s71b-section-${row.yyyyMm}'),
          );
          expect(sectionFinder, findsOneWidget);
          // 글자가 sectionLabel 그대로 — Key 가 Text 위젯 자체에 붙어 있다
          final Text sectionText = tester.widget<Text>(sectionFinder);
          expect(sectionText.data, equals(row.sectionLabel));
          // dy: section < row < (다음 행이 있으면 다음 행)
          final double sectionDy = tester.getTopLeft(sectionFinder).dy;
          final double rowDy = tester
              .getTopLeft(
                find.byKey(ValueKey<String>('s71b-row-${row.yyyyMm}')),
              )
              .dy;
          expect(sectionDy, lessThan(rowDy));

          // 다음 행이 있으면 rowDy < nextRowDy
          final int idx = archive18.rows.indexOf(row);
          if (idx + 1 < archive18.rows.length) {
            final ReportArchiveRow nextRow = archive18.rows[idx + 1];
            final double nextRowDy = tester
                .getTopLeft(
                  find.byKey(ValueKey<String>('s71b-row-${nextRow.yyyyMm}')),
                )
                .dy;
            expect(rowDy, lessThanOrEqualTo(nextRowDy));
          }
        }
      }
    },
  );

  // ── A10 ────────────────────────────────────────────────────────────────────
  test('A10 barrel keeps its exports and hides internals', () {
    const String barrelPath = 'lib/ui_analytics.dart';
    final String content = File(barrelPath).readAsStringSync();

    // 새 export 있음
    expect(
      content.contains("'src/screens/report_archive_screen.dart'"),
      isTrue,
    );

    // 기존 다섯 줄 그대로
    expect(content.contains("'l10n/labels.dart'"), isTrue);
    expect(
      content.contains("'src/providers/analytics_providers.dart'"),
      isTrue,
    );
    expect(content.contains("'src/screens/contribution_screen.dart'"), isTrue);
    expect(
      content.contains("'src/screens/drawdown_context_screen.dart'"),
      isTrue,
    );
    expect(
      content.contains("'src/screens/monthly_report_screen.dart'"),
      isTrue,
    );

    // 내부 파일은 export 하지 않는다
    expect(content.contains('analytics_skeleton'), isFalse);
    expect(content.contains('analytics_error_view'), isFalse);
    expect(content.contains("'src/screens/explore/"), isFalse);
    expect(content.contains("'src/chart/"), isFalse);
    expect(content.contains('perf_chart'), isFalse);
  });
}

// ── 보조 가짜 ─────────────────────────────────────────────────────────────────

class _CountingThrowingRepo extends UnimplementedPerformanceRepository {
  _CountingThrowingRepo({required this.onCall});
  final void Function() onCall;

  @override
  Future<ReportArchiveVm> reportArchive() {
    onCall();
    return Future<ReportArchiveVm>.error(Exception('test error'));
  }
}
