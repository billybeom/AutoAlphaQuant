import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/ui_journal.dart';

// 🔵 계약 v1.1(M2 추종 수정) — 받침대를 상속한다. M2 가 창구를 더해도 이 가짜는 깨지지 않는다.
class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository(this.result);

  final ListResult<TradeJournalEntry> result;

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
  }) => Stream<ListResult<TradeJournalEntry>>.value(result);

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
  _FakeSafetyRepository(this.state);

  final SafetyState state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime nowUtc() => _now;
}

void main() {
  testWidgets('J-1 keeps the as-of label and row labels from the contract', (
    WidgetTester tester,
  ) async {
    final DateRange range = DateRange(
      from: TradeDate('2026-08-01'),
      to: TradeDate('2026-08-31'),
      label: 'fixture range',
    );
    final AsOf asOf = AsOf(
      observedAt: DateTime.utc(2026, 8, 31),
      tradeDate: TradeDate('2026-08-31'),
      source: AsOfSource.localSqlite,
      staleAfter: const Duration(days: 1),
      label: 'fixture as-of',
    );
    final ListResult<TradeJournalEntry> result = ListResult<TradeJournalEntry>(
      rows: <TradeJournalEntry>[],
      asOf: asOf,
      emptyKind: EmptyKind.noData,
      emptyLabel: 'fixture empty',
      hasMore: false,
    );
    final SafetyState safety = SafetyState(
      breakerLevel: BreakerLevel.normal,
      breakerLabel: 'fixture breaker',
      drawdown: 0,
      activeFlags: <BlockFlag>[],
      killSwitch: KillSwitchView(active: false, stateLabel: 'fixture state'),
      stoppedReleaseEligible: false,
      releaseProgress: <GaugeProgress>[],
      alertBlockSatEntry: false,
      rampLevel: RampLevel.l0,
      mode: RunMode.live,
      asOf: asOf,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          journalTimelineRepositoryProvider.overrideWithValue(
            _FakeJournalRepository(result),
          ),
          journalSafetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safety),
          ),
          journalTimelineQueryProvider.overrideWithValue(
            JournalTimelineQuery(range: range),
          ),
          journalClockProvider.overrideWithValue(
            _FixedClock(DateTime.utc(2026, 8, 31, 10)),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: JournalTimeline())),
      ),
    );
    await tester.pump();

    expect(find.text('fixture as-of'), findsOneWidget);
    expect(find.text('fixture empty'), findsOneWidget);
  });
}
