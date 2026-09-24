// test/golden/j2_golden_test.dart — J-2 거래 상세 골든 (R2 신규 · 8종 × light/dark = 16장)
//
// 🔴 픽스처를 고치지 않는다. 링크 오프너·CommandApi 는 주입하지 않는다.
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/j2_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

// ── Tall phone size for J-2 (content may be long) ────────────────────────────

const Size _kTallPhone = Size(390, 1600);

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository(this._vm);
  final DecisionDetailVm _vm;

  @override
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId) =>
      Stream<DecisionDetailVm>.value(_vm);
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

// ── Helper ─────────────────────────────────────────────────────────────────────

Future<void> _pumpDetail(
  WidgetTester tester,
  DecisionDetailVm vm,
  Brightness b,
) async {
  await pumpForGolden(
    tester,
    const JournalDecisionDetail(decisionId: 'golden-id'),
    brightness: b,
    logicalSize: _kTallPhone,
    wrapApp: (Widget app) => ProviderScope(
      overrides: <Override>[
        journalTimelineRepositoryProvider.overrideWithValue(
          _FakeJournalRepository(vm),
        ),
        journalSafetyRepositoryProvider.overrideWithValue(
          _FakeSafetyRepository(safetyFixtureRow(0)),
        ),
        journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
        journalLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
      ],
      child: app,
    ),
  );
}

// ── Goldens ────────────────────────────────────────────────────────────────────

void main() {
  for (final Brightness b in Brightness.values) {
    // ── 1. j2_full ────────────────────────────────────────────────────────────
    testWidgets('j2_full ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailFull,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      // Precondition: journalStateLabel visible (screen end is within viewport)
      expect(
        tester.getBottomLeft(find.text(vm.journalStateLabel)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j2_full', b);
    });

    // ── 2. j2_full_snapshot_open ──────────────────────────────────────────────
    testWidgets('j2_full_snapshot_open ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailFull,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      // Tap snapshot header to expand
      await tester.tap(find.text(JournalLabels.decisionSnapshot));
      await tester.pumpAndSettle();
      await expectGolden('j2_full_snapshot_open', b);
    });

    // ── 3. j2_partial ─────────────────────────────────────────────────────────
    testWidgets('j2_partial ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailPartial,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      expect(
        tester.getBottomLeft(find.text(vm.journalStateLabel)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j2_partial', b);
    });

    // ── 4. j2_unknown ─────────────────────────────────────────────────────────
    testWidgets('j2_unknown ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailUnknown,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      expect(
        tester.getBottomLeft(find.text(vm.journalStateLabel)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j2_unknown', b);
    });

    // ── 5. j2_rejected_saf309 ─────────────────────────────────────────────────
    testWidgets('j2_rejected_saf309 ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailRejectedSaf309,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      expect(
        tester.getBottomLeft(find.text(vm.journalStateLabel)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j2_rejected_saf309', b);
    });

    // ── 6. j2_rejected_saf309_trace_open ─────────────────────────────────────
    testWidgets('j2_rejected_saf309_trace_open ${b.name}',
        (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailRejectedSaf309,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      // Tap reject trace header to expand
      await tester.tap(find.text(JournalLabels.rejectTrace));
      await tester.pumpAndSettle();
      await expectGolden('j2_rejected_saf309_trace_open', b);
    });

    // ── 7. j2_reevaluated_child ───────────────────────────────────────────────
    testWidgets('j2_reevaluated_child ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailReevaluatedChild,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      expect(
        tester.getBottomLeft(find.text(vm.journalStateLabel)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j2_reevaluated_child', b);
    });

    // ── 8. j2_amended ────────────────────────────────────────────────────────
    testWidgets('j2_amended ${b.name}', (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailAmended,
        DecisionDetailVm.fromJson,
      );
      await _pumpDetail(tester, vm, b);
      expect(
        tester.getBottomLeft(find.text(vm.journalStateLabel)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j2_amended', b);
    });
  }
}
