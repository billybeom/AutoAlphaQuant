// a3_golden_test.dart - A-3 ManualFillForm golden tests.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/journal_draft.dart';

import '../advice_skip_fakes.dart';
import '../holdings_overview_fakes.dart';
import '../manual_fill_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1700);

class _Flow {
  const _Flow({
    required this.name,
    required this.item,
    required this.spec,
    required this.seed,
    required this.cmd,
    required this.bottom,
    required this.steps,
  });

  final String name;
  final AdviceItem item;
  final ManualFillFormSpec spec;
  final List<DraftRecord> seed;
  final CommandApi cmd;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final ListResult<AdviceItem> advices = listFixture<AdviceItem>(
    FixturePaths.m6Advice12,
    AdviceItem.fromJson,
  );
  final AdviceItem ad0001 = advices.rows[3];
  final AdviceItem ad0002 = advices.rows[4];
  final AdviceItem partial = singleFixture<AdviceItem>(
    FixturePaths.m6AdviceDetailPartial,
    AdviceItem.fromJson,
  );
  final ManualFillFormSpec spec = singleFixture<ManualFillFormSpec>(
    FixturePaths.m6FillFormSpec,
    ManualFillFormSpec.fromJson,
  );
  final ManualFillFormSpec staleSpec = singleFixture<ManualFillFormSpec>(
    FixturePaths.m6FillFormSpecStale,
    ManualFillFormSpec.fromJson,
  );
  final CommandReceipt rejectedPrice = singleFixture<CommandReceipt>(
    FixturePaths.m6FillRejectedPrice,
    CommandReceipt.fromJson,
  );
  final ListResult<DraftRecord> drafts = listFixture<DraftRecord>(
    FixturePaths.m6DraftRecordsX7,
    DraftRecord.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'a3_empty',
      item: ad0001,
      spec: spec,
      seed: const <DraftRecord>[],
      cmd: UnimplementedCommandApi(),
      bottom: const Key('a3-submit'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'a3_advice_linked',
      item: partial,
      spec: spec,
      seed: const <DraftRecord>[],
      cmd: UnimplementedCommandApi(),
      bottom: const Key('a3-submit'),
      steps: (WidgetTester t) async {
        await t.ensureVisible(find.byKey(const Key('a3-prefill')));
        await t.tap(find.byKey(const Key('a3-prefill')));
      },
    ),
    _Flow(
      name: 'a3_rejected_price',
      item: ad0002,
      spec: spec,
      seed: <DraftRecord>[drafts.rows[0]],
      cmd: FakeManualFillCommandApi(
        record: (int call) => Future<CommandReceipt>.value(rejectedPrice),
        watch: (int call) => Stream<CommandReceipt>.value(rejectedPrice),
      ),
      bottom: const Key('a3-submit'),
      steps: (WidgetTester t) async {
        await t.ensureVisible(find.byKey(const Key('a3-submit')));
        await t.tap(find.byKey(const Key('a3-submit')));
      },
    ),
    _Flow(
      name: 'a3_form_spec_stale',
      item: ad0001,
      spec: staleSpec,
      seed: const <DraftRecord>[],
      cmd: UnimplementedCommandApi(),
      bottom: const Key('a3-asof'),
      steps: (WidgetTester t) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final RecordingLinkOpener opener = RecordingLinkOpener();
        final FakeAdviceFormRepository repo = FakeAdviceFormRepository(
          item: (int call) => Future<AdviceItem?>.value(flow.item),
          spec: (int call) => Stream<ManualFillFormSpec>.value(flow.spec),
        );
        await pumpForGolden(
          tester,
          ManualFillForm(adviceId: flow.item.adviceId),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: manualFillOverrides(
              repo: repo,
              cmd: flow.cmd,
              store: RecordingDraftStore(seed: flow.seed),
              opener: opener,
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
        expect(tester.getTopLeft(find.byKey(const Key('a3-asof'))).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
