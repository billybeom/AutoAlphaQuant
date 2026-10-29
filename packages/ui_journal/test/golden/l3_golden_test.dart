// l3_golden_test.dart - L-3 SelfReportForm golden tests.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/journal_draft.dart';

import '../self_report_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1300);

class _Flow {
  const _Flow({
    required this.name,
    required this.session,
    required this.bottom,
    required this.steps,
  });

  final String name;
  final SelfReportSession session;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final SelfReportSession session1 = singleFixture<SelfReportSession>(
    FixturePaths.m6SelfReport1,
    SelfReportSession.fromJson,
  );
  final SelfReportSession diffResult = singleFixture<SelfReportSession>(
    FixturePaths.m6SelfReportDiffResult,
    SelfReportSession.fromJson,
  );
  final ListResult<DraftRecord> drafts = listFixture<DraftRecord>(
    FixturePaths.m6DraftRecordsX7,
    DraftRecord.fromJson,
  );
  final String alias = drafts.rows[2].selfReport?.accountAlias ?? '';

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'l3_session',
      session: session1,
      bottom: const Key('l3-submit'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'l3_diff_result',
      session: diffResult,
      bottom: const Key('l3-next-account'),
      steps: (WidgetTester t) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final FakeSelfReportRepository repo = FakeSelfReportRepository(
          session: (_) => Stream<SelfReportSession>.value(flow.session),
        );
        final FakeSelfReportActions actions = FakeSelfReportActions();
        final UnimplementedCommandApi cmd = UnimplementedCommandApi();
        final RecordingDraftStore store = RecordingDraftStore();

        await pumpForGolden(
          tester,
          SelfReportForm(
            yyyyMm: '2026-08',
            accountAlias: alias,
          ),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: selfReportOverrides(
              repo: repo,
              actions: actions,
              cmd: cmd,
              store: store,
              safety: safetyFixtureRow(0),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(_kTallPhone.height),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('l3-asof'))).dy,
          0.0,
        );
        await expectGolden(flow.name, b);
      });
    }
  }
}
