// test/golden/j3r_golden_test.dart — J-3R 사전 저널 읽기 뷰 골든 (2종 × light/dark = 4장)
//
// 🔴 링크 오프너 주입 안 함(카드 규칙 «골든은 링크 오프너만 주입하지 않는다»).
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/j3r_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

// ── Fake repository ────────────────────────────────────────────────────────────

class _FakeJournalRepo extends UnimplementedJournalRepository {
  _FakeJournalRepo({required this.vm});
  final DecisionJournalVm vm;

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) =>
      Stream<DecisionJournalVm>.value(vm);
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

// ── Goldens ────────────────────────────────────────────────────────────────────

void main() {
  for (final Brightness b in Brightness.values) {
    // ── j3r_written ───────────────────────────────────────────────────────────
    // JournalReadView + m6JournalReadWritten
    testWidgets('j3r_written ${b.name}', (WidgetTester tester) async {
      final DecisionJournalVm vm = singleFixture(
        FixturePaths.m6JournalReadWritten,
        DecisionJournalVm.fromJson,
      );
      await pumpForGolden(
        tester,
        JournalReadView(decisionId: vm.decisionId),
        brightness: b,
        logicalSize: _kTallPhone,
        wrapApp: (Widget app) => ProviderScope(
          overrides: <Override>[
            journalTimelineRepositoryProvider.overrideWithValue(
              _FakeJournalRepo(vm: vm),
            ),
            journalSafetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyFixtureRow(0)),
            ),
            journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            // 🔴 링크 오프너 주입 안 함
          ],
          child: app,
        ),
      );
      await tester.pumpAndSettle();

      // 맨 아래 = j3r-link-decision
      expect(
        tester.getBottomLeft(find.byKey(const Key('j3r-link-decision'))).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3r_written', b);
    });

    // ── j3r_not_written ───────────────────────────────────────────────────────
    // JournalReadView + m6JournalReadNotWritten 행 0 (d_20260810_b_27)
    // 🔴 singleFixture 는 2행 파일이라 던진다 → listFixture.rows[0]
    // 행 1 은 전환 표본(d_20260901_a_31) — 행 0 을 쓴다
    testWidgets('j3r_not_written ${b.name}', (WidgetTester tester) async {
      final DecisionJournalVm vm = listFixture(
        FixturePaths.m6JournalReadNotWritten,
        DecisionJournalVm.fromJson,
      ).rows[0];
      await pumpForGolden(
        tester,
        JournalReadView(decisionId: vm.decisionId),
        brightness: b,
        logicalSize: _kTallPhone,
        wrapApp: (Widget app) => ProviderScope(
          overrides: <Override>[
            journalTimelineRepositoryProvider.overrideWithValue(
              _FakeJournalRepo(vm: vm),
            ),
            journalSafetyRepositoryProvider.overrideWithValue(
              _FakeSafetyRepository(safetyFixtureRow(0)),
            ),
            journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            // 🔴 링크 오프너 주입 안 함
          ],
          child: app,
        ),
      );
      await tester.pumpAndSettle();

      // 맨 아래 = j3r-state (body 없음, link 없음)
      expect(
        tester.getBottomLeft(find.byKey(const Key('j3r-state'))).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3r_not_written', b);
    });
  }
}
