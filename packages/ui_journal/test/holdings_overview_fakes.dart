// holdings_overview_fakes.dart — H6-1 위젯 테스트·골든 공용 가짜와 도우미.
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

/// H6-1 읽기 창구 가짜 — 한 화면 창구만 연다. 받은 includePnl 을 호출마다 기록한다.
class FakeHoldingsRepository extends UnimplementedHoldingsRepository {
  FakeHoldingsRepository({required this.overview});

  final Stream<HoldingsOverviewVm> Function(bool includePnl, int call) overview;

  /// watchHoldingsOverview 의 includePnl — 호출마다.
  final List<bool> calls = <bool>[];

  @override
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false}) {
    final int call = calls.length;
    calls.add(includePnl);
    return overview(includePnl, call);
  }
}

/// 접힘 구독에는 [closed] · 펼침 구독에는 [open] 을 낸다(호출마다 새 스트림).
FakeHoldingsRepository fakeHoldingsOverview(
  HoldingsOverviewVm closed,
  HoldingsOverviewVm open,
) => FakeHoldingsRepository(
  overview: (bool includePnl, int call) =>
      Stream<HoldingsOverviewVm>.value(includePnl ? open : closed),
);

/// 안전 상태 가짜 — 호출마다 새 스트림.
class FakeHoldingsSafetyRepository extends UnimplementedSafetyRepository {
  FakeHoldingsSafetyRepository(this.state);

  final SafetyState state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

/// H6-1 주입 4개.
List<Override> holdingsOverviewOverrides({
  required FakeHoldingsRepository repo,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalHoldingsRepositoryProvider.overrideWithValue(repo),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

/// 390×4000 · DPR 1.0 으로 H6-1 을 띄운다(끝에 pump 1번).
Future<void> pumpHoldingsOverview(
  WidgetTester tester, {
  required List<Override> overrides,
  Key? screenKey,
}) async {
  tester.view.physicalSize = const Size(390, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: HoldingsOverview(key: screenKey)),
      ),
    ),
  );
  await tester.pump();
}

/// 카드 [c] 의 머리를 눌러 펼침·접힘을 바꾼다.
Future<void> openHoldingsCard(WidgetTester tester, int c) async {
  final Finder head = find.byKey(ValueKey<String>('h61-card-toggle-$c'));
  await tester.scrollUntilVisible(head.hitTestable(), 300);
  await tester.tap(head);
  await tester.pump();
}

/// 시스템 밖 섹션 머리를 눌러 펼침·접힘을 바꾼다.
Future<void> openHoldingsExternal(WidgetTester tester) async {
  final Finder head = find.byKey(const Key('h61-ext-toggle'));
  await tester.scrollUntilVisible(head.hitTestable(), 300);
  await tester.tap(head);
  await tester.pump();
}

/// 손익 토글을 누른다(재구독 값이 도착하도록 pump 두 번).
Future<void> tapHoldingsPnlToggle(WidgetTester tester) async {
  final Finder toggle = find.byKey(const Key('h61-pnl-toggle'));
  await tester.scrollUntilVisible(toggle.hitTestable(), 300);
  await tester.tap(toggle);
  await tester.pump();
  await tester.pump();
}

/// 행 안 Text 순서(위 → 아래) — build 의 행 순서 그대로.
List<String> holdingsRowTexts(HoldingRow row) => <String>[
  row.symbolLabel,
  row.quantityText,
  ?row.pendingText,
  ?row.subBookLabel,
  JournalLabels.holdingsAvgPrice,
  row.avgPriceText,
  JournalLabels.holdingsEntryDate,
  row.entryDate.yyyyMmDd,
  row.weightText,
  for (final ReasonChip c in row.entryReasons) c.label,
  for (final TrancheStep s in row.smaTranches) s.label,
  for (final GateBadge g in row.gates) g.label,
  ?row.pnl?.pnlText,
  ?row.pnl?.pnlPctText,
  ?row.pnl?.disclosureNote,
];

/// 카드 머리 안 Text 순서.
List<String> holdingsCardHeadTexts(HoldingsSleeveCard card) => <String>[
  card.titleText,
  ?card.allocation.sleeveWeight?.label,
  ?card.allocation.bandNoteText,
  ?card.allocation.bandStateLabel,
];

/// 시스템 밖 행 안 Text 순서.
List<String> holdingsExternalRowTexts(ExternalHoldingRow x) => <String>[
  x.symbolLabel,
  x.quantityText,
  JournalLabels.holdingsRegisteredOn,
  x.registeredOn.yyyyMmDd,
];

/// 그 Key 아래 Text 글자(위 → 아래).
List<String?> holdingsShownTexts(WidgetTester tester, Key key) => tester
    .widgetList<Text>(
      find.descendant(of: find.byKey(key), matching: find.byType(Text)),
    )
    .map((Text t) => t.data)
    .toList();

/// scope 아래 글자가 label 인 Chip 의 아이콘.
IconData? holdingsChipIcon(WidgetTester tester, Finder scope, String label) =>
    tester
        .widget<Icon>(
          find.descendant(
            of: find.ancestor(
              of: find.descendant(of: scope, matching: find.text(label)),
              matching: find.byType(Chip),
            ),
            matching: find.byType(Icon),
          ),
        )
        .icon;

/// 화면에 나올 수 있는 Text 글자 전부.
Set<String> holdingsOverviewAllowed(HoldingsOverviewVm v) => <String>{
  v.asOf.label,
  ?v.pnlToggleLabel,
  ?v.allocationLink?.label,
  for (final HoldingsSleeveCard c in v.cards) ...<String>[
    ...holdingsCardHeadTexts(c),
    ?c.rowsEmptyText,
    for (final HoldingRow r in c.rows) ...holdingsRowTexts(r),
  ],
  ?v.external?.titleText,
  ?v.external?.noticeText,
  ?v.external?.bannerText,
  for (final ExternalHoldingRow x in v.external?.rows ?? <ExternalHoldingRow>[])
    ...holdingsExternalRowTexts(x),
};
