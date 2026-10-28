// advice_fakes.dart — A-1 오늘의 매매 안내 · 지난 안내 위젯 테스트·골든 공용 가짜와 도우미.
//
// 🔴 가짜는 전부 testing.dart 받침대를 extends 한다 — 화면이 부르면 안 되는 창구는
//    받침대가 던져서 테스트가 실패한다. 한국어 리터럴 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

/// A-1 읽기 창구 가짜 — 받은 인자를 호출마다 기록한다.
class FakeAdviceRepository extends UnimplementedAdviceRepository {
  FakeAdviceRepository({required this.inbox, required this.summary});

  final Stream<ListResult<AdviceItem>> Function(int call) inbox;
  final Stream<AdviceInboxSummary> Function(int call) summary;

  /// watchInbox 의 (status, limit) — 호출마다.
  final List<(AdviceStatus?, int)> inboxArgs = <(AdviceStatus?, int)>[];
  int summaryCalls = 0;

  @override
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  }) {
    final int call = inboxArgs.length;
    inboxArgs.add((status, limit));
    return inbox(call);
  }

  @override
  Stream<AdviceInboxSummary> watchSummary() {
    final int call = summaryCalls;
    summaryCalls = summaryCalls + 1;
    return summary(call);
  }
}

/// 명령 가짜 — 받은 adviceId 를 호출마다 기록한다.
class FakeAdviceCommandApi extends UnimplementedCommandApi {
  FakeAdviceCommandApi({required this.defer});

  final Future<CommandReceipt> Function(int call) defer;

  final List<String> deferred = <String>[];

  @override
  Future<CommandReceipt> deferAdviceConfirm(String adviceId) {
    final int call = deferred.length;
    deferred.add(adviceId);
    return defer(call);
  }
}

/// A-1 주입 5개.
List<Override> adviceInboxOverrides({
  required FakeAdviceRepository repo,
  CommandApi? cmd,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalAdviceRepositoryProvider.overrideWithValue(repo),
  journalAdviceCommandApiProvider.overrideWithValue(
    cmd ?? UnimplementedCommandApi(),
  ),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

/// 390×4000 · DPR 1.0 으로 A-1 을 띄운다(끝에 pump 1번).
Future<void> pumpAdviceInbox(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: AdviceInbox())),
    ),
  );
  await tester.pump();
}

/// 행 슬라이스 — 입력 준비(화면 판정 아님). 봉투 값은 그대로 두고 hasMore 만 닫는다.
ListResult<AdviceItem> adviceSlice(
  ListResult<AdviceItem> source,
  List<int> pick,
) => source.copyWith(
  rows: <AdviceItem>[for (final int i in pick) source.rows[i]],
  hasMore: false,
);

/// 값 하나를 낸 뒤 에러로 끝나는 스트림.
Stream<T> adviceValueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

/// 신선도 초과 시계(+2일).
Clock adviceStaleClock() =>
    FixedClock(kGoldenNowUtc.add(const Duration(days: 2)));

/// scope 아래 Text 의 data(위 → 아래) — Key 가 Text 자신에 달린 자리도 센다.
List<String?> adviceShownTexts(WidgetTester tester, Finder scope) => tester
    .widgetList<Text>(
      find.descendant(of: scope, matching: find.byType(Text), matchRoot: true),
    )
    .map((Text t) => t.data)
    .toList();

/// 카드 안 Text 순서 — AdviceCard 의 build 순서 그대로.
List<String> adviceCardTexts(AdviceItem v) {
  final String? s = v.suppressedLabel;
  final List<String> actionTexts = <String>[
    for (final AdviceAction a in v.actions) ...<String>[
      a.label,
      ?a.disabledReasonLabel,
    ],
  ];
  return s != null
      ? <String>[
          s,
          v.validityLabel,
          for (final ReasonChip c in v.reasons) c.label,
          ...actionTexts,
        ]
      : <String>[
          ?v.expiredConfirmLabel,
          ?v.symbolLabel,
          ?v.sideLabel,
          ?v.phoneOnlyLabel,
          v.sizingLabel,
          ?v.priceBand?.label,
          v.validityLabel,
          v.progressLabel,
          v.statusLabel,
          ?v.holdReasonLabel,
          for (final ReasonChip c in v.reasons) c.label,
          ...actionTexts,
        ];
}

/// A-1 행 안 Text 순서 — 카드 + 「내일 다시」.
List<String> adviceRowTexts(AdviceItem v) => <String>[
  ...adviceCardTexts(v),
  ?(v.deferAvailable ? JournalLabels.adviceDeferConfirm : null),
];

/// 요약 묶음 안 Text 순서.
List<String> adviceSummaryTexts(AdviceInboxSummary s) => <String>[
  s.headline,
  ?s.dueSoonLabel,
  ?s.staleLabel,
  ?s.handoverCoolingLabel,
  ?s.cashNotice?.label,
  s.trust.label,
  s.trust.consequenceLine,
  ?s.trust.upgradeHint,
];

/// A-1 화면에 나올 수 있는 Text 글자 전부.
Set<String> adviceInboxAllowed(
  ListResult<AdviceItem> v,
  AdviceInboxSummary s,
) => <String>{
  v.asOf.label,
  ?v.emptyLabel,
  ...adviceSummaryTexts(s),
  for (final AdviceItem r in v.rows) ...adviceRowTexts(r),
  ?s.overdueUnrecordedLink?.label,
  ?s.manualEntryNoticeText,
  ?s.manualEntryLink?.label,
  JournalLabels.adviceHistoryLink,
};

/// 지난 안내 읽기 창구 가짜 — 받은 range 를 호출마다 기록한다.
class FakeAdviceHistoryRepository extends UnimplementedAdviceRepository {
  FakeAdviceHistoryRepository({required this.history});

  final Stream<ListResult<AdviceItem>> Function(int call) history;

  /// watchHistory 의 range — 호출마다.
  final List<DateRange> ranges = <DateRange>[];

  @override
  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range}) {
    final int call = ranges.length;
    ranges.add(range);
    return history(call);
  }
}

/// 범위 프리셋 가짜 — 호출 수를 센다.
class FakeAdviceRangeConfig extends UnimplementedConfigRepository {
  FakeAdviceRangeConfig({required this.presets});

  final Stream<List<DateRange>> Function(int call) presets;

  int calls = 0;

  @override
  Stream<List<DateRange>> watchRangePresets() {
    final int call = calls;
    calls = calls + 1;
    return presets(call);
  }
}

/// 지난 안내 주입 5개.
List<Override> adviceHistoryOverrides({
  required FakeAdviceHistoryRepository repo,
  required FakeAdviceRangeConfig config,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalAdviceRepositoryProvider.overrideWithValue(repo),
  journalConfigRepositoryProvider.overrideWithValue(config),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

/// 390×4000 · DPR 1.0 으로 지난 안내를 띄운다(프리셋 → 지난 안내 순서라 pump 두 번).
Future<void> pumpAdviceHistory(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: AdviceHistory())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

/// 지난 안내 화면에 나올 수 있는 Text 글자 전부.
Set<String> adviceHistoryAllowed(ListResult<AdviceItem> v, DateRange range) =>
    <String>{
      v.asOf.label,
      ?range.label,
      ?v.emptyLabel,
      for (final AdviceItem r in v.rows) ...adviceCardTexts(r),
    };
