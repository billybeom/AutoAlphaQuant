// test/golden/a1_golden_test.dart — A-1 AdviceInbox golden (7 names x light/dark = 14 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/a1_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../advice_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 3800);

class _Flow {
  const _Flow({
    required this.name,
    required this.inbox,
    required this.summary,
    required this.safety,
    required this.steps,
  });

  final String name;
  final ListResult<AdviceItem> inbox;
  final AdviceInboxSummary summary;
  final SafetyState safety;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final SafetyState normal = safetyFixtureRow(0);
  final SafetyState safetyBlocked = singleFixture<SafetyState>(
    FixturePaths.m6SafetyAdviceBlocked,
    SafetyState.fromJson,
  );
  final ListResult<AdviceItem> open4 = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary s12 = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6Advice12,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> advEmpty = listFixture<AdviceItem>(
    FixturePaths.m6AdviceEmpty,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sEmpty = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceEmpty,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> blocked = listFixture<AdviceItem>(
    FixturePaths.m6AdviceBlocked,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sBlocked = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceBlocked,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> confirm = listFixture<AdviceItem>(
    FixturePaths.m6AdviceExpiredConfirm,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sConfirm = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceExpiredConfirm,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> viewer = listFixture<AdviceItem>(
    FixturePaths.m6AdviceViewer4,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sViewer = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceViewer4,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> noAction = listFixture<AdviceItem>(
    FixturePaths.m6AdviceNoAction,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sNoAction = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceNoAction,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final ListResult<AdviceItem> cooling = listFixture<AdviceItem>(
    FixturePaths.m6AdviceHandoverCooling,
    AdviceItem.fromJson,
  );
  final AdviceInboxSummary sCooling = extraFixture<AdviceInboxSummary>(
    FixturePaths.m6AdviceHandoverCooling,
    'summary',
    AdviceInboxSummary.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'a1_open4',
      inbox: open4,
      summary: s12,
      safety: normal,
      steps: (_) async {},
    ),
    _Flow(
      name: 'a1_empty',
      inbox: advEmpty,
      summary: sEmpty,
      safety: normal,
      steps: (_) async {},
    ),
    _Flow(
      name: 'a1_blocked',
      inbox: blocked,
      summary: sBlocked,
      safety: safetyBlocked,
      steps: (_) async {},
    ),
    _Flow(
      name: 'a1_expired_confirm',
      inbox: confirm,
      summary: sConfirm,
      safety: normal,
      steps: (_) async {},
    ),
    _Flow(
      name: 'a1_viewer',
      inbox: viewer,
      summary: sViewer,
      safety: normal,
      steps: (_) async {},
    ),
    _Flow(
      name: 'a1_no_action',
      inbox: noAction,
      summary: sNoAction,
      safety: normal,
      steps: (_) async {},
    ),
    _Flow(
      name: 'a1_handover_cooling',
      inbox: cooling,
      summary: sCooling,
      safety: normal,
      steps: (_) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const AdviceInbox(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: adviceInboxOverrides(
              repo: FakeAdviceRepository(
                inbox: (int call) =>
                    Stream<ListResult<AdviceItem>>.value(flow.inbox),
                summary: (int call) =>
                    Stream<AdviceInboxSummary>.value(flow.summary),
              ),
              safety: flow.safety,
            ),
            child: app,
          ),
        );
        await tester.pump();

        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(const Key('a1-history-link'))).dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('a1-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
