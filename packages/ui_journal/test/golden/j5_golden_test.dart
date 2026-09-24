// test/golden/j5_golden_test.dart — J-5 UNKNOWN 해소 보드 골든 (R2 신규 · 3종 × light/dark = 6장)
//
// 🔴 픽스처를 고치지 않는다. 링크 오프너·CommandApi 는 주입하지 않는다.
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/j5_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository(this._vm);
  final UnknownBoardVm _vm;

  @override
  Stream<UnknownBoardVm> watchUnknownBoard() =>
      Stream<UnknownBoardVm>.value(_vm);
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

// ── Helper ─────────────────────────────────────────────────────────────────────

Future<void> _pumpBoard(
  WidgetTester tester,
  UnknownBoardVm vm,
  Brightness b,
) async {
  await pumpForGolden(
    tester,
    const JournalUnknownBoard(),
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
    // ── 13. j5_two_open ───────────────────────────────────────────────────────
    testWidgets('j5_two_open ${b.name}', (WidgetTester tester) async {
      final UnknownBoardVm vm = singleFixture(
        FixturePaths.m6UnknownBoard2,
        UnknownBoardVm.fromJson,
      );
      await _pumpBoard(tester, vm, b);
      // Precondition: nextBatchNoticeText is within viewport
      expect(vm.nextBatchNoticeText, isNotNull);
      expect(
        tester.getBottomLeft(find.text(vm.nextBatchNoticeText!)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j5_two_open', b);
    });

    // ── 14. j5_long_open (emphasized only slice) ──────────────────────────────
    testWidgets('j5_long_open ${b.name}', (WidgetTester tester) async {
      final UnknownBoardVm full = singleFixture(
        FixturePaths.m6UnknownBoard2,
        UnknownBoardVm.fromJson,
      );
      final UnknownBoardVm slice = full.copyWith(
        items: full.items
            .where((UnknownResolutionItem i) => i.emphasized)
            .toList(growable: false),
      );
      expect(slice.items.length, 1);
      await _pumpBoard(tester, slice, b);
      // Precondition: nextBatchNoticeText visible (or absent — check emptyLabel too)
      // j5_long_open has no nextBatchNoticeText since we copied from original vm
      // which has nextBatchNoticeText, but slice doesn't change asOf/nextBatchNoticeText
      // (copyWith keeps it). Check bottom widget.
      // Verify the card is within viewport
      expect(
        tester
            .getBottomLeft(find.byKey(const ValueKey<String>('j5-card-0')))
            .dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j5_long_open', b);
    });

    // ── 15. j5_empty ─────────────────────────────────────────────────────────
    testWidgets('j5_empty ${b.name}', (WidgetTester tester) async {
      final UnknownBoardVm vm = singleFixture(
        FixturePaths.m6UnknownBoardEmpty,
        UnknownBoardVm.fromJson,
      );
      await _pumpBoard(tester, vm, b);
      expect(vm.emptyLabel, isNotNull);
      // Precondition: emptyLabel visible
      expect(
        tester.getBottomLeft(find.text(vm.emptyLabel!)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j5_empty', b);
    });
  }
}
