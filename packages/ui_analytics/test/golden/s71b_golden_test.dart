// packages/ui_analytics/test/golden/s71b_golden_test.dart
//
// S7-1b 리포트 아카이브 골든 — 4장(s71b_list·s71b_empty × light/dark).
// 🔴 찍기 전에 위치 전제(맨 아래 위젯 dy < 높이) — 잘린 골든이 조용히 통과하지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';
import 'package:ui_analytics/src/screens/report_archive_screen.dart';

import 'golden_support.dart';

// 픽스처를 그대로 돌려주는 최소 가짜 — 받침대 extends.
class _FakePerformanceRepository extends UnimplementedPerformanceRepository {
  _FakePerformanceRepository(this._archive);
  final ReportArchiveVm _archive;

  @override
  Future<ReportArchiveVm> reportArchive() async => _archive;
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  // 픽스처를 한 번만 읽는다
  final ReportArchiveVm archive18 =
      singleFixture(FixturePaths.m7M7ReportArchive18, ReportArchiveVm.fromJson);
  final ReportArchiveVm archiveEmpty =
      singleFixture(FixturePaths.m7M7ReportArchiveEmpty, ReportArchiveVm.fromJson);
  final SafetyState safety =
      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[0]);

  // 골든 크기 상수 (테스트 파일 안에 두고 pumpForGolden logicalSize 에 넘긴다)
  const double _kListHeight = 1700;
  const double _kEmptyHeight = 844;

  // ── s71b_list ──────────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s71b_list ${brightnessSuffix(b)}', (WidgetTester tester) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
            performanceRepositoryProvider
                .overrideWithValue(_FakePerformanceRepository(archive18)),
            safetyRepositoryProvider
                .overrideWithValue(_FakeSafetyRepository(safety)),
          ],
          child: const ReportArchiveScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, _kListHeight),
      );

      // 위치 전제 — 끝 행의 아래 끝이 높이 안에 있다(README §2)
      expect(
        tester
            .getBottomLeft(
              find.byKey(
                ValueKey<String>('s71b-row-${archive18.rows.last.yyyyMm}'),
              ),
            )
            .dy,
        lessThan(_kListHeight),
      );

      await expectGolden('s71b_list', b);
    });
  }

  // ── s71b_empty ─────────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s71b_empty ${brightnessSuffix(b)}', (WidgetTester tester) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
            performanceRepositoryProvider
                .overrideWithValue(_FakePerformanceRepository(archiveEmpty)),
            safetyRepositoryProvider
                .overrideWithValue(_FakeSafetyRepository(safety)),
          ],
          child: const ReportArchiveScreen(),
        ),
        brightness: b,
        logicalSize: const Size(390, _kEmptyHeight),
      );

      // 위치 전제 — 빈 상태 글자의 아래 끝이 높이 안에 있다(README §2)
      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s71b-empty')))
            .dy,
        lessThan(_kEmptyHeight),
      );

      await expectGolden('s71b_empty', b);
    });
  }
}
