// test/settings_fakes.dart — ui_settings 테스트 공용 가짜·도우미
//
// 🔴 한국어 리터럴 0 · if 0 · collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

// ── R6a — M9 S01 fakes ──

class FakeSettingsRepository extends UnimplementedSettingsRepository {
  FakeSettingsRepository({required this.home});

  final Stream<SettingsHomeVm> Function(int call) home;
  int homeCalls = 0;

  @override
  Stream<SettingsHomeVm> watchHome() {
    final int call = homeCalls;
    homeCalls = homeCalls + 1;
    return home(call);
  }
}

List<Override> settingsHomeOverrides({
  required FakeSettingsRepository repo,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  settingsRepositoryProvider.overrideWithValue(repo),
  settingsLinkOpenerProvider.overrideWithValue(opener),
  settingsClockProvider.overrideWithValue(clock),
];

Future<void> pumpSettingsHome(
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
      child: const MaterialApp(home: Scaffold(body: SettingsHome())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String?> shownTexts(WidgetTester tester, Finder of) => tester
    .widgetList<Text>(find.descendant(of: of, matching: find.byType(Text)))
    .map((Text t) => t.data)
    .toList();

Stream<T> one<T>(T v) => Stream<T>.value(v);

List<String> settingsCardTexts(SettingsCard k) => <String>[
  k.title,
  ?k.statusLabel,
  ?k.attentionText,
];

Set<String> settingsHomeAllowed(SettingsHomeVm v) => <String>{
  v.statusChip.label,
  ?v.statusChip.promotionLabel,
  ?v.annualReviewLink?.label,
  for (final SettingsGroup g in v.groups) g.label,
  for (final SettingsGroup g in v.groups)
    for (final SettingsCard k in g.cards) ...settingsCardTexts(k),
  v.asOf.label,
  ?v.asOf.staleLabel,
};

// ── R6b — M9 S07 fakes ──

class FakeSettingsOpsStatusRepository extends UnimplementedOpsStatusRepository {
  FakeSettingsOpsStatusRepository({required this.connections});

  final Stream<ConnectionsVm> Function(int call) connections;
  int connectionsCalls = 0;

  @override
  Stream<ConnectionsVm> watchConnections() {
    final int call = connectionsCalls;
    connectionsCalls = connectionsCalls + 1;
    return connections(call);
  }
}

class FakeSettingsActions extends UnimplementedSettingsActions {
  FakeSettingsActions({required this.result});

  final Future<ActionResult> Function(int call) result;
  final List<SettingsActionId> ids = <SettingsActionId>[];
  final List<Map<String, String>> argsSeen = <Map<String, String>>[];
  int watchCalls = 0;

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

  @override
  Stream<ActionResult> watch(String actionRunId) {
    watchCalls = watchCalls + 1;
    return const Stream<ActionResult>.empty();
  }
}

List<Override> connectionsOverrides({
  required FakeSettingsOpsStatusRepository repo,
  required SettingsActions? actions,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  settingsOpsStatusRepositoryProvider.overrideWithValue(repo),
  settingsActionsProvider.overrideWithValue(actions),
  settingsLinkOpenerProvider.overrideWithValue(opener),
  settingsClockProvider.overrideWithValue(clock),
];

Future<void> pumpConnections(
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
      child: const MaterialApp(home: Scaffold(body: Connections())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String?> connectionRowTexts(ConnectionRow k) => <String?>[
  k.label,
  k.statusLabel,
  k.lastOkText,
  ?k.detailLine,
];

Set<String> connectionsAllowed(ConnectionsVm v) => <String>{
  ?v.lockedLabel,
  for (final ConnectionRow k in v.rows)
    ...connectionRowTexts(k).whereType<String>(),
  for (final ConnectionRow k in v.rows) ?k.channelPicker?.label,
  for (final ConnectionRow k in v.rows)
    for (final NotifyChannelOption o
        in k.channelPicker?.options ?? const <NotifyChannelOption>[])
      o.label,
  for (final ConnectionRow k in v.rows) ?k.channelPicker?.capabilityNotice,
  for (final ConnectionRow k in v.rows) ?k.channelPicker?.tokenBadgeText,
  for (final ConnectionRow k in v.rows) ?k.channelPicker?.watchdogChannelLine,
  v.asOf.label,
  ?v.asOf.staleLabel,
};

Set<String> connectionsControlTexts(ConnectionsVm v) => <String>{
  for (final ConnectionRow k in v.rows)
    for (final SettingsActionCall call in k.actions) call.label,
  for (final ConnectionRow k in v.rows)
    for (final NotifyChannelOption o
        in k.channelPicker?.options ?? const <NotifyChannelOption>[])
      ?o.selectAction?.label,
};

// ── R6c1 — M9 S05 fakes ──

class FakeSettingsOperationsRepository extends UnimplementedSettingsRepository {
  FakeSettingsOperationsRepository({required this.operations});

  final Stream<OperationsVm> Function(int call) operations;
  int operationsCalls = 0;

  @override
  Stream<OperationsVm> watchOperations() {
    final int call = operationsCalls;
    operationsCalls = operationsCalls + 1;
    return operations(call);
  }
}

List<Override> operationsOverrides({
  required FakeSettingsOperationsRepository repo,
  required SettingsActions? actions,
  required RecordingLinkOpener opener,
  required Clock clock,
}) => <Override>[
  settingsRepositoryProvider.overrideWithValue(repo),
  settingsActionsProvider.overrideWithValue(actions),
  settingsLinkOpenerProvider.overrideWithValue(opener),
  settingsClockProvider.overrideWithValue(clock),
];

Future<void> pumpOperations(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(390, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: Operations())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

List<String?> chipTexts(EngineStatusChip c) => <String?>[
  c.label,
  ?c.promotionLabel,
];

List<String?> modeViewerTexts(RunModeCard m) => <String?>[
  m.label,
  ?m.holdLabel,
  ?m.observation?.progressText,
  ?m.observation?.stateLabel,
  ?m.switchNoticeText,
];

List<String?> modeOperatorTexts(RunModeCard m) => <String?>[
  m.label,
  ?m.holdLabel,
  ?m.observation?.progressText,
  ?m.observation?.stateLabel,
  ?m.promotionAction?.label,
  ?m.switchNoticeText,
  for (final SettingsActionCall c in m.switchActions) c.label,
];

List<String?> opModeViewerTexts(OperatingModeView v) => <String?>[
  v.label,
  v.explainLine,
  for (final OperatingModeOption o in v.options) ...<String?>[
    o.title,
    o.body,
    o.prepLine,
    o.honestyLine,
  ],
  v.trust.label,
  v.trust.consequenceLine,
  ?v.trust.upgradeHint,
  for (final GateBadge g in v.switchGates) g.label,
];

List<String?> opModeOperatorTexts(OperatingModeView v) => <String?>[
  ...opModeViewerTexts(v),
  for (final SettingsActionCall c in v.switchActions) c.label,
];

List<String?> trialTexts(SimTrialCard? t) => <String?>[
  ?t?.headline,
  ?t?.summaryText,
  for (final SimTrialCheck k
      in t?.checks ?? const <SimTrialCheck>[]) ...<String?>[
    k.label,
    k.stateLabel,
    k.detailText,
  ],
];

Set<String> operationsAllowed(OperationsVm v) => <String>{
  v.statusChip.label,
  ?v.statusChip.promotionLabel,
  v.mode.label,
  ?v.mode.holdLabel,
  ?v.mode.observation?.progressText,
  ?v.mode.observation?.stateLabel,
  ?v.mode.switchNoticeText,
  v.operatingMode.label,
  v.operatingMode.explainLine,
  for (final OperatingModeOption o in v.operatingMode.options) ...<String>[
    o.title,
    o.body,
    o.prepLine,
    o.honestyLine,
  ],
  v.operatingMode.trust.label,
  v.operatingMode.trust.consequenceLine,
  ?v.operatingMode.trust.upgradeHint,
  for (final GateBadge g in v.operatingMode.switchGates) g.label,
  ?v.trial?.headline,
  ?v.trial?.summaryText,
  for (final SimTrialCheck k
      in v.trial?.checks ?? const <SimTrialCheck>[]) ...<String>[
    k.label,
    k.stateLabel,
    k.detailText,
  ],
  v.ramp.levelLabel,
  ?v.ramp.dstNoticeText,
  ?v.ramp.emptyLabel,
  for (final RampCondition c in v.ramp.conditions) ...<String>[
    c.label,
    c.progressText,
  ],
  for (final JobRow j in v.jobs) ...<String>[
    j.label,
    j.stateLabel,
    j.scheduleText,
    j.lastRunText,
    ?j.detailLine,
  ],
  v.control.stateLabel,
  ?v.control.stopPromptText,
  ?v.updateGate?.stateLabel,
  ?v.updateGate?.bodyText,
  ?v.lastRequestNotice,
  ?v.lockedLabel,
  v.asOf.label,
  ?v.asOf.staleLabel,
};

Set<String> operationsControlTexts(OperationsVm v) => <String>{
  for (final SettingsActionCall c in v.mode.switchActions) c.label,
  ?v.mode.promotionAction?.label,
  for (final SettingsActionCall c in v.operatingMode.switchActions) c.label,
  ?v.control.startAction?.label,
  for (final SettingsActionCall c in v.control.stopActions) c.label,
};

// ── R6c2 — M9 S05 board fakes ──

List<String?> rampTexts(RampBoard r) => <String?>[
  r.levelLabel,
  ?r.dstNoticeText,
  ?r.emptyLabel,
  for (final RampCondition k in r.conditions) ...<String?>[
    k.label,
    k.progressText,
  ],
];

List<String?> jobTexts(JobRow j) => <String?>[
  j.label,
  j.stateLabel,
  j.scheduleText,
  j.lastRunText,
  ?j.detailLine,
];

List<String?> controlViewerTexts(EngineControl c) => <String?>[
  c.stateLabel,
  ?c.stopPromptText,
];

List<String?> controlOperatorTexts(EngineControl c) => <String?>[
  c.stateLabel,
  ?c.startAction?.label,
  ?c.stopPromptText,
  for (final SettingsActionCall s in c.stopActions) s.label,
];

List<String?> updateTexts(UpdateGateCard? u) => <String?>[
  ?u?.stateLabel,
  ?u?.bodyText,
];
