import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

// Minimal in-test repository implementations that stream fixture values.
// These do NOT compute or modify any values.

// 🔵 계약 v1.1(M2 추종 수정) — 받침대를 상속한다. M2 가 창구를 더해도 이 가짜는 깨지지 않는다.
class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository(this._result);

  final ListResult<TradeJournalEntry> _result;

  @override
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  }) => Stream<ListResult<TradeJournalEntry>>.value(_result);

  @override
  Future<TradeJournalEntry?> findByDecisionId(String decisionId) async => null;

  @override
  Future<List<TradeJournalEntry>> chainOf(String decisionId) async =>
      <TradeJournalEntry>[];

  @override
  Future<List<TradeJournalEntry>> fillChain(String entryId) async =>
      <TradeJournalEntry>[];
}

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository(this._state);

  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  final ListResult<TradeJournalEntry> all = journalFixture(
    FixturePaths.journal30,
  );
  final ListResult<TradeJournalEntry> empty = journalFixture(
    FixturePaths.m6JournalEmpty,
  );
  final ListResult<TradeJournalEntry> prevented = journalSlice(
    all,
    (TradeJournalEntry e) => e.status == JournalStatus.prevented,
  );
  final SafetyState normal = safetyFixtureRow(0);
  final SafetyState blocked = safetyFixtureRow(3);
  final DateRange range = DateRange(
    from: TradeDate('2026-08-01'),
    to: TradeDate('2026-08-31'),
    presetCode: 'FIXTURE',
  );

  // name -> (journal result, safety state)
  final Map<String, (ListResult<TradeJournalEntry>, SafetyState)> cases =
      <String, (ListResult<TradeJournalEntry>, SafetyState)>{
        'j1_normal': (all, normal),
        'j1_blocked': (all, blocked),
        'j1_empty': (empty, normal),
        'j1_prevented': (prevented, normal),
      };

  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, (ListResult<TradeJournalEntry>, SafetyState)> c
        in cases.entries) {
      testWidgets('${c.key} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: <Override>[
              journalTimelineRepositoryProvider.overrideWithValue(
                _FakeJournalRepository(c.value.$1),
              ),
              journalSafetyRepositoryProvider.overrideWithValue(
                _FakeSafetyRepository(c.value.$2),
              ),
              journalTimelineQueryProvider.overrideWithValue(
                JournalTimelineQuery(range: range),
              ),
              journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            ],
            child: const JournalTimeline(),
          ),
          brightness: b,
        );
        await expectGolden(c.key, b);
      });
    }
  }
}
