// test/shell_fakes.dart
//
// 셸 테스트 공용 가짜·도우미.
//
// 🔴 한국어 리터럴 0 · if 0 · collection-if 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';

// ── FeatureFlags const 5 벌 ────────────────────────────────────────────────────

const FeatureFlags kFlagsLiveAuto = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.live,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg_fake_0000000000000000',
);

const FeatureFlags kFlagsSimAuto = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg_fake_0000000000000000',
);

const FeatureFlags kFlagsLiveAdvisory = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.live,
  operatingMode: OperatingMode.advisory,
  configHash: 'cfg_fake_0000000000000000',
);

const FeatureFlags kFlagsSimAdvisory = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.advisory,
  configHash: 'cfg_fake_0000000000000000',
);

const FeatureFlags kFlagsBrokerAuto = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simBroker,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg_fake_0000000000000000',
);

// ── Fakes ──────────────────────────────────────────────────────────────────────

class FakeShellConfigRepository extends UnimplementedConfigRepository {
  FakeShellConfigRepository({required this.flags});

  final Stream<FeatureFlags> Function(int call) flags;
  int calls = 0;

  @override
  Stream<FeatureFlags> watchFlags() {
    final int call = calls;
    calls = calls + 1;
    return flags(call);
  }
}

class FakeShellAlertRepository extends UnimplementedAlertRepository {
  FakeShellAlertRepository({required this.inbox});

  final Stream<List<AlertItem>> Function(int call) inbox;
  final List<AlertLevel?> mins = <AlertLevel?>[];

  @override
  Stream<List<AlertItem>> watchInbox({AlertLevel? min}) {
    final int call = mins.length;
    mins.add(min);
    return inbox(call);
  }
}

class FakeShellOpsSummaryRepository extends UnimplementedOpsSummaryRepository {
  FakeShellOpsSummaryRepository({required this.rhythm});

  final Stream<ListResult<OpsRhythmRow>> Function(int call) rhythm;
  int rhythmCalls = 0;

  @override
  Stream<ListResult<OpsRhythmRow>> watchRhythm() {
    final int call = rhythmCalls;
    rhythmCalls = rhythmCalls + 1;
    return rhythm(call);
  }
}

// ── Factory helpers ────────────────────────────────────────────────────────────

FakeShellConfigRepository flagsOf(FeatureFlags f) => FakeShellConfigRepository(
  flags: (int call) => Stream<FeatureFlags>.value(f),
);

FakeShellAlertRepository alertsOf(List<AlertItem> items) =>
    FakeShellAlertRepository(
      inbox: (int call) => Stream<List<AlertItem>>.value(items),
    );

// ── DummyBody ──────────────────────────────────────────────────────────────────

class DummyBody extends StatefulWidget {
  const DummyBody({
    super.key,
    required this.tag,
    required this.params,
    required this.log,
  });

  final String tag;
  final Map<String, String> params;
  final List<String> log;

  @override
  State<DummyBody> createState() => _DummyBodyState();
}

class _DummyBodyState extends State<DummyBody> {
  @override
  void initState() {
    super.initState();
    widget.log.add(widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(key: ValueKey<String>('dummy ${widget.tag}'));
  }
}

const String kHomeTag = 'home';

Finder dummyOf(String pattern) =>
    find.byKey(ValueKey<String>('dummy $pattern'));

ShellRouteBodies dummyBodies(List<String> patterns, List<String> log) =>
    ShellRouteBodies(<String, ShellBodyBuilder>{
      for (final String p in patterns)
        p: (Map<String, String> params) =>
            DummyBody(tag: p, params: params, log: log),
    });

String dummyLink(String pattern) => <String>[
  for (final (int i, String s) in pattern.split('/').indexed)
    s.startsWith(':') ? 'p$i' : s,
].join('/');

Map<String, String> dummyParams(String pattern) =>
    Map<String, String>.fromEntries(
      pattern
          .split('/')
          .indexed
          .where(((int, String) e) => e.$2.startsWith(':'))
          .map(
            ((int, String) e) =>
                MapEntry<String, String>(e.$2.substring(1), 'p${e.$1}'),
          ),
    );

// ── Overrides & pump helpers ───────────────────────────────────────────────────

List<Override> shellOverrides({
  required ShellPlatform platform,
  required FakeShellConfigRepository config,
  required FakeShellAlertRepository alerts,
  required ShellRouteBodies bodies,
}) => <Override>[
  shellPlatformProvider.overrideWithValue(platform),
  shellConfigRepositoryProvider.overrideWithValue(config),
  shellAlertRepositoryProvider.overrideWithValue(alerts),
  shellRouteBodiesProvider.overrideWithValue(bodies),
  shellClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
  shellOpsSummaryRepositoryProvider.overrideWithValue(
    UnimplementedOpsSummaryRepository(),
  ),
];

Future<void> pumpShell(
  WidgetTester tester, {
  required List<Override> overrides,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(builder: _bandBuilder, home: ShellRoot()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Widget _bandBuilder(BuildContext context, Widget? child) =>
    ShellBandOverlay(child: child ?? const SizedBox.shrink());

AppLinkOpener shellOpener(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ShellRoot)))
        .read(shellLinkOpenerProvider);

Future<void> openLink(WidgetTester tester, String link) async {
  shellOpener(tester).open(link);
  await tester.pumpAndSettle();
}

List<String?> shownTexts(WidgetTester tester, Finder of) => tester
    .widgetList<Text>(find.descendant(of: of, matching: find.byType(Text)))
    .map((Text t) => t.data)
    .toList();

// ── H-02 helpers ───────────────────────────────────────────────────────────────

List<Override> opsRhythmOverrides({
  required FakeShellOpsSummaryRepository ops,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  shellOpsSummaryRepositoryProvider.overrideWithValue(ops),
  shellLinkOpenerProvider.overrideWithValue(opener),
  shellClockProvider.overrideWithValue(clock),
];

Future<void> pumpOpsRhythm(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OpsRhythm())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String> rhythmRowTexts(OpsRhythmRow r) => <String>[
  r.title,
  r.whenText,
  ?r.dDayText,
];

Set<String> rhythmAllowed(ListResult<OpsRhythmRow> v) => <String>{
  v.asOf.label,
  ?v.emptyLabel,
  ShellLabels.rhythmColumnItem,
  ShellLabels.rhythmColumnNext,
  for (final OpsRhythmRow r in v.rows) ...rhythmRowTexts(r),
};

// ── R13b — H-01 fakes ─────────────────────────────────────────────────────────

class FakeShellSafetyRepository extends UnimplementedSafetyRepository {
  FakeShellSafetyRepository({required this.state});

  final Stream<SafetyState> Function(int call) state;
  int calls = 0;

  @override
  Stream<SafetyState> watchState() {
    final int call = calls;
    calls = calls + 1;
    return state(call);
  }
}

class FakeShellOpsTodayRepository extends UnimplementedOpsSummaryRepository {
  FakeShellOpsTodayRepository({required this.today});

  final Stream<OpsDailySummary> Function(int call) today;
  int calls = 0;

  @override
  Stream<OpsDailySummary> watchToday() {
    final int call = calls;
    calls = calls + 1;
    return today(call);
  }
}

class FakeShellAdviceRepository extends UnimplementedAdviceRepository {
  FakeShellAdviceRepository({required this.summary});

  final Stream<AdviceInboxSummary> Function(int call) summary;
  int calls = 0;

  @override
  Stream<AdviceInboxSummary> watchSummary() {
    final int call = calls;
    calls = calls + 1;
    return summary(call);
  }
}

class FakeShellHoldingsRepository extends UnimplementedHoldingsRepository {
  FakeShellHoldingsRepository({required this.allocation});

  final Stream<SleeveAllocationVm> Function(int call) allocation;
  int calls = 0;

  @override
  Stream<SleeveAllocationVm> watchAllocation() {
    final int call = calls;
    calls = calls + 1;
    return allocation(call);
  }
}

class FakeShellOpsStatusRepository extends UnimplementedOpsStatusRepository {
  FakeShellOpsStatusRepository({required this.diagnostics});

  final Stream<DiagnosticsVm> Function(int call) diagnostics;
  int calls = 0;

  @override
  Stream<DiagnosticsVm> watchDiagnostics() {
    final int call = calls;
    calls = calls + 1;
    return diagnostics(call);
  }
}

class FakeShellLedgerTrustRepository
    extends UnimplementedLedgerTrustRepository {
  FakeShellLedgerTrustRepository({required this.grade});

  final Stream<LedgerTrustBadge> Function(int call) grade;
  int calls = 0;

  @override
  Stream<LedgerTrustBadge> watchGrade() {
    final int call = calls;
    calls = calls + 1;
    return grade(call);
  }
}

Stream<T> one<T>(T v) => Stream<T>.value(v);

List<Override> homeOverrides({
  required FakeShellSafetyRepository safety,
  required FakeShellOpsTodayRepository today,
  required FakeShellAdviceRepository advice,
  required FakeShellHoldingsRepository alloc,
  required FakeShellOpsStatusRepository diag,
  required FakeShellLedgerTrustRepository trust,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  shellSafetyRepositoryProvider.overrideWithValue(safety),
  shellOpsSummaryRepositoryProvider.overrideWithValue(today),
  shellAdviceRepositoryProvider.overrideWithValue(advice),
  shellHoldingsRepositoryProvider.overrideWithValue(alloc),
  shellOpsStatusRepositoryProvider.overrideWithValue(diag),
  shellLedgerTrustRepositoryProvider.overrideWithValue(trust),
  shellLinkOpenerProvider.overrideWithValue(opener),
  shellClockProvider.overrideWithValue(clock),
];

Future<void> pumpOpsHome(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OpsHome())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Set<String> homeAllowed({
  required OpsDailySummary today,
  required SafetyState safety,
  required AdviceInboxSummary? advice,
  required SleeveAllocationVm alloc,
  required DiagnosticsVm diag,
  required LedgerTrustBadge trust,
}) {
  final AdviceInboxSummary? a =
      advice != null && (advice.openCount != 0 || advice.hasSuppressedNotice)
      ? advice
      : null;
  final String? adviceHeadline = a?.headline;
  final String? adviceDueSoon = a != null && !a.hasSuppressedNotice
      ? a.dueSoonLabel
      : null;
  final String? adviceTrustLabel = a != null && !a.hasSuppressedNotice
      ? a.trust.label
      : null;
  final List<SleeveAllocationRow> top = alloc.rows
      .where((SleeveAllocationRow r) => r.parentSleeve == null)
      .toList();
  return <String>{
    today.asOf.label,
    today.todayOrdersText,
    today.todayErrorsText,
    today.signalMatchText,
    today.streakText,
    today.discretionBudgetText,
    today.nextRebalanceDDayText,
    for (final OpsRhythmRow r in today.upcoming) ...<String>[
      r.title,
      r.whenText,
      ?r.dDayText,
    ],
    safety.breakerLabel,
    for (final BlockFlag f in safety.activeFlags.where(
      (BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId),
    ))
      f.label,
    ?adviceHeadline,
    ?adviceDueSoon,
    ?adviceTrustLabel,
    for (final SleeveAllocationRow r in top)
      ...<String?>[
        r.sleeveLabel,
        r.sleeveWeight?.label,
        r.bandStateLabel,
        r.bandNoteText,
        r.deployedPctText,
        r.parkingPctText,
      ].nonNulls,
    ?alloc.noticeText,
    ?alloc.emptyLabel,
    for (final DiagnosticCell c in diag.cells) ...<String>[
      c.label,
      c.stateLabel,
    ],
    diag.headline,
    trust.label,
    trust.consequenceLine,
    ShellLabels.homeReconTitle,
    ShellLabels.homeUpcomingTitle,
    ShellLabels.homeMore,
    ShellLabels.homeSelfAuditAction,
    ShellLabels.homeDeployed,
    ShellLabels.homeParking,
    ShellLabels.staleBannerTitle,
  };
}

// ── R14a — N-01·N-02 fakes ────────────────────────────────────────────────────

class FakeShellAlertCenterRepository extends UnimplementedAlertRepository {
  FakeShellAlertCenterRepository({required this.center, required this.detail});

  final Stream<AlertCenterVm> Function(int call) center;
  final Stream<AlertDetailVm> Function(int call) detail;
  final List<bool> p0Onlys = <bool>[];
  final List<String> alertIds = <String>[];

  @override
  Stream<AlertCenterVm> watchCenter({required bool p0Only}) {
    final int call = p0Onlys.length;
    p0Onlys.add(p0Only);
    return center(call);
  }

  @override
  Stream<AlertDetailVm> watchAlert(String alertId) {
    final int call = alertIds.length;
    alertIds.add(alertId);
    return detail(call);
  }
}

class FakeShellAlertCommandApi extends UnimplementedCommandApi {
  FakeShellAlertCommandApi({required this.receipt});

  final Future<CommandReceipt> Function(int call) receipt;
  final List<String> acks = <String>[];

  @override
  Future<CommandReceipt> acknowledgeAlert(String alertId) {
    final int call = acks.length;
    acks.add(alertId);
    return receipt(call);
  }
}

List<Override> alertOverrides({
  required FakeShellAlertCenterRepository alerts,
  required CommandApi? api,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  shellAlertRepositoryProvider.overrideWithValue(alerts),
  shellAlertCommandApiProvider.overrideWithValue(api),
  shellLinkOpenerProvider.overrideWithValue(opener),
  shellClockProvider.overrideWithValue(clock),
];

Future<void> pumpAlertCenter(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: AlertCenter())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> pumpAlertDetail(
  WidgetTester tester, {
  required List<Override> overrides,
  required String alertId,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: AlertDetail(alertId: alertId)),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String?> alertTileTexts(AlertItem a) => <String?>[
  a.title,
  ?a.groupedText,
  ?a.raisedAtText,
];

Set<String?> alertCenterAllowed(AlertCenterVm v) => <String?>{
  v.asOf.label,
  ?v.asOf.staleLabel,
  for (final AlertItem a in v.pinned) ...<String?>[
    a.title,
    ?a.groupedText,
    ?a.raisedAtText,
    ?a.ack?.stateLabel,
  ],
  for (final AlertSection sec in v.sections) ...<String?>[
    sec.headerText,
    ?sec.digestLabel,
    for (final AlertItem a in sec.rows) ...<String?>[
      a.title,
      ?a.groupedText,
      ?a.raisedAtText,
      ?a.ack?.stateLabel,
    ],
    for (final AlertItem a in sec.digestRows) ...<String?>[
      a.title,
      ?a.groupedText,
      ?a.raisedAtText,
      ?a.ack?.stateLabel,
    ],
  ],
  ?v.emptyLabel,
  ShellLabels.alertsP0Only,
  ShellLabels.alertsAck,
  ShellLabels.staleBannerTitle,
};

Set<String?> alertDetailAllowed(AlertDetailVm v) => <String?>{
  v.asOf.label,
  ?v.asOf.staleLabel,
  ?v.missingLabel,
  ?v.item?.title,
  ?v.item?.raisedAtText,
  ?v.item?.bodyText,
  ?v.item?.actionLine,
  ?v.item?.ack?.stateLabel,
  ShellLabels.alertsEvidence,
  ShellLabels.alertsAck,
  ShellLabels.staleBannerTitle,
};

// ── R14b — W-01 fakes ─────────────────────────────────────────────────────────

class FakeShellWatchdogRepository extends UnimplementedOpsStatusRepository {
  FakeShellWatchdogRepository({required this.watchdog});

  final Stream<WatchdogBoardVm> Function(int call) watchdog;
  int calls = 0;

  @override
  Stream<WatchdogBoardVm> watchWatchdog() {
    final int call = calls;
    calls = calls + 1;
    return watchdog(call);
  }
}

List<Override> watchdogOverrides({
  required FakeShellWatchdogRepository ops,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  shellOpsStatusRepositoryProvider.overrideWithValue(ops),
  shellLinkOpenerProvider.overrideWithValue(opener),
  shellClockProvider.overrideWithValue(clock),
];

Future<void> pumpWatchdogBoard(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: WatchdogBoard())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String> watchdogRowTexts(WatchdogCheck c) => <String>[
  c.label,
  c.stateLabel,
  c.lastPingText,
  ?c.graceText,
];

Set<String> watchdogAllowed(WatchdogBoardVm v) => <String>{
  v.asOf.label,
  ?v.asOf.staleLabel,
  ?v.lastReceivedText,
  for (final WatchdogCheck c in v.rows) ...watchdogRowTexts(c),
  ?v.emptyLabel,
  ?v.holidayNotice,
  ?v.limitNotice,
  ShellLabels.staleBannerTitle,
};

// ── R15a — O-00·O-00b fakes ───────────────────────────────────────────────────

class FakeShellOnboardingRepository extends UnimplementedOnboardingRepository {
  FakeShellOnboardingRepository({
    required this.start,
    required this.modeChoice,
  });

  final Stream<OnboardingStartVm> Function(int call) start;
  final Stream<OnboardingModeChoiceVm> Function(int call) modeChoice;
  int startCalls = 0;
  int modeCalls = 0;

  @override
  Stream<OnboardingStartVm> watchStart() {
    final int call = startCalls;
    startCalls = startCalls + 1;
    return start(call);
  }

  @override
  Stream<OnboardingModeChoiceVm> watchModeChoice() {
    final int call = modeCalls;
    modeCalls = modeCalls + 1;
    return modeChoice(call);
  }
}

class FakeShellOnboardingActions extends UnimplementedSettingsActions {
  FakeShellOnboardingActions({required this.result});

  final Future<ActionResult> Function(int call) result;
  final List<SettingsActionId> ids = <SettingsActionId>[];
  final List<Map<String, String>> argsSeen = <Map<String, String>>[];

  @override
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  }) {
    final int call = ids.length;
    ids.add(id);
    argsSeen.add(args);
    return result(call);
  }
}

List<Override> onboardingOverrides({
  required FakeShellOnboardingRepository repo,
  required SettingsActions? actions,
  required RecordingLinkOpener opener,
}) => <Override>[
  shellOnboardingRepositoryProvider.overrideWithValue(repo),
  shellOnboardingActionsProvider.overrideWithValue(actions),
  shellLinkOpenerProvider.overrideWithValue(opener),
];

Future<void> pumpOnboardingStart(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OnboardingStart())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> pumpOnboardingModePick(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OnboardingModePick())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String> trackCardTexts(OnboardingTrackCard c) => <String>[
  c.title,
  c.estimatedText,
];

List<String> modeCardTexts(OperatingModeOption o) => <String>[
  o.title,
  o.body,
  o.prepLine,
  o.honestyLine,
];

Set<String> onboardingStartAllowed(OnboardingStartVm v) => <String>{
  v.headline,
  for (final OnboardingTrackCard t in v.tracks) ...trackCardTexts(t),
  ?v.viewerTrack?.title,
  ?v.viewerTrack?.estimatedText,
};

Set<String> modePickAllowed(OnboardingModeChoiceVm v) => <String>{
  v.headline,
  for (final OperatingModeOption o in v.options) ...modeCardTexts(o),
  v.recordGapNotice,
  v.honestyText,
  ?v.lockedLabel,
  ShellLabels.onboardingNext,
};

// ── R15b — O-01~O-03 fakes ──

class FakeShellStepRepository extends UnimplementedOnboardingRepository {
  FakeShellStepRepository({required this.steps, required this.detail});

  final Stream<OnboardingStepsVm> Function(int call) steps;
  final Stream<OnboardingStepDetailVm> Function(int call) detail;
  final List<String> stepIds = <String>[];
  int listCalls = 0;

  @override
  Stream<OnboardingStepsVm> watchStepList() {
    final int call = listCalls;
    listCalls = listCalls + 1;
    return steps(call);
  }

  @override
  Stream<OnboardingStepDetailVm> watchStep(String stepId) {
    final int call = stepIds.length;
    stepIds.add(stepId);
    return detail(call);
  }
}

class FakeShellSlotRecorder {
  final List<String> slotIds = <String>[];

  Widget build(String slotId) {
    slotIds.add(slotId);
    return SizedBox(key: ValueKey<String>('fake-slot-$slotId'), height: 48);
  }
}

List<Override> stepOverrides({
  required FakeShellStepRepository repo,
  required SettingsActions? actions,
  required ShellSlotBuilder? slots,
  required RecordingLinkOpener opener,
}) => <Override>[
  shellOnboardingRepositoryProvider.overrideWithValue(repo),
  shellOnboardingActionsProvider.overrideWithValue(actions),
  shellOnboardingSlotBuilderProvider.overrideWithValue(slots),
  shellLinkOpenerProvider.overrideWithValue(opener),
];

Future<void> pumpStepList(
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
      child: const MaterialApp(home: Scaffold(body: OnboardingStepList())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> pumpStepDetail(
  WidgetTester tester, {
  required List<Override> overrides,
  required String stepId,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: OnboardingStepDetail(stepId: stepId)),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String> stepRowTexts(OnboardingStep s) => <String>[
  s.title,
  s.whyLine,
  s.estimatedText,
  s.requirementLabel,
  ?s.warningLabel,
  ?s.verificationLabel,
  ?s.verifiedUntilText,
  ?s.failureText,
  ?s.failureReasonCode,
  ?s.gate?.label,
];

Set<String> stepListAllowed(OnboardingStepsVm v) => <String>{
  v.progressText,
  ?v.emptyLabel,
  for (final OnboardingStep r in v.rows) ...stepRowTexts(r),
  ShellLabels.onboardingNext,
};

Set<String> stepDetailAllowed(OnboardingStepDetailVm v, ActionResult? r) =>
    <String>{
      ?v.missingLabel,
      ?v.step?.title,
      ?v.step?.whyLine,
      ?v.step?.estimatedText,
      ?v.step?.verifiedUntilText,
      ?v.whereText,
      ?v.howText,
      ?v.verify?.label,
      ?r?.headline,
      ?r?.reasonCode,
      ShellLabels.onboardingNotAccepted,
      ShellLabels.retry,
    };

// ── R15c — O-04 fakes ──

class FakeShellFinishRepository extends UnimplementedOnboardingRepository {
  FakeShellFinishRepository({required this.finish});

  final Stream<OnboardingFinishVm> Function(int call) finish;
  int finishCalls = 0;

  @override
  Stream<OnboardingFinishVm> watchFinish() {
    final int call = finishCalls;
    finishCalls = finishCalls + 1;
    return finish(call);
  }
}

List<Override> finishOverrides({
  required FakeShellFinishRepository repo,
  required SettingsActions? actions,
  required ShellSlotBuilder? slots,
  required RecordingLinkOpener opener,
}) => <Override>[
  shellOnboardingRepositoryProvider.overrideWithValue(repo),
  shellOnboardingActionsProvider.overrideWithValue(actions),
  shellOnboardingSlotBuilderProvider.overrideWithValue(slots),
  shellLinkOpenerProvider.overrideWithValue(opener),
];

Future<void> pumpFinish(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OnboardingFinish())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String> stageTexts(OnboardingFinishStage s) => <String>[
  s.title,
  ?s.gate?.label,
  ...s.lines,
  ?s.expectationLine,
  ?s.link?.label,
  ?s.action?.label,
];

Set<String> finishAllowed(OnboardingFinishVm v, ActionResult? r) => <String>{
  v.headline,
  for (final OnboardingFinishStage s in v.stages) ...stageTexts(s),
  ?v.doneLabel,
  for (final OnboardingFinishCheck c in v.checks) c.label,
  ?r?.headline,
  ?r?.reasonCode,
  ShellLabels.onboardingNotAccepted,
};

// ── R15d — R-01·V-01 fakes ──

class FakeShellRestartRepository extends UnimplementedOnboardingRepository {
  FakeShellRestartRepository({required this.restart});

  final Stream<RestartVm> Function(int call) restart;
  int restartCalls = 0;

  @override
  Stream<RestartVm> watchRestart() {
    final int call = restartCalls;
    restartCalls = restartCalls + 1;
    return restart(call);
  }
}

class FakeShellPairingRepository extends UnimplementedPairingRepository {
  FakeShellPairingRepository({required this.pairing});

  final Stream<PairingVm> Function(int call) pairing;
  int pairingCalls = 0;

  @override
  Stream<PairingVm> watchPairing() {
    final int call = pairingCalls;
    pairingCalls = pairingCalls + 1;
    return pairing(call);
  }
}

List<Override> restartOverrides({
  required FakeShellRestartRepository repo,
  required ShellSlotBuilder? slots,
  required RecordingLinkOpener opener,
}) => <Override>[
  shellOnboardingRepositoryProvider.overrideWithValue(repo),
  shellOnboardingSlotBuilderProvider.overrideWithValue(slots),
  shellLinkOpenerProvider.overrideWithValue(opener),
];

List<Override> pairingOverrides({
  required FakeShellPairingRepository repo,
  required ShellSlotBuilder? slots,
  required RecordingLinkOpener opener,
}) => <Override>[
  shellPairingRepositoryProvider.overrideWithValue(repo),
  shellOnboardingSlotBuilderProvider.overrideWithValue(slots),
  shellLinkOpenerProvider.overrideWithValue(opener),
];

Future<void> pumpRestart(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: OnboardingRestart())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> pumpPairing(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: ViewerPairing())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Set<String> restartAllowed(RestartVm v) => <String>{
  v.headline,
  ...?v.ledgerLines,
  ?v.leaseGate?.label,
  for (final LinkAction b in v.branches) b.label,
  ?v.inheritNotice,
};

Set<String> pairingAllowed(PairingVm v) => <String>{
  v.headline,
  ?v.result?.headline,
  ?v.result?.reasonCode,
  ?v.result?.nextLink?.label,
};
