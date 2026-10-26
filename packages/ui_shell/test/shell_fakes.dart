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

class FakeShellAlertRepository implements AlertRepository {
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

FakeShellConfigRepository flagsOf(FeatureFlags f) =>
    FakeShellConfigRepository(
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
    ShellRouteBodies(
      <String, ShellBodyBuilder>{
        for (final String p in patterns)
          p: (Map<String, String> params) =>
              DummyBody(tag: p, params: params, log: log),
      },
    );

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
  shellOpsSummaryRepositoryProvider
      .overrideWithValue(UnimplementedOpsSummaryRepository()),
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
      child: const MaterialApp(
        builder: _bandBuilder,
        home: ShellRoot(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Widget _bandBuilder(BuildContext context, Widget? child) =>
    ShellBandOverlay(child: child ?? const SizedBox.shrink());

AppLinkOpener shellOpener(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(ShellRoot)),
    ).read(shellLinkOpenerProvider);

Future<void> openLink(WidgetTester tester, String link) async {
  shellOpener(tester).open(link);
  await tester.pumpAndSettle();
}

List<String?> shownTexts(WidgetTester tester, Finder of) =>
    tester
        .widgetList<Text>(find.descendant(of: of, matching: find.byType(Text)))
        .map((Text t) => t.data)
        .toList();
