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
