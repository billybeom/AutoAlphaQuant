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
