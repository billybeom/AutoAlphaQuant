// test/golden/h01_golden_test.dart — H-01 운영 홈 골든 (8 names x light/dark = 16 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/h01_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1300);

class _Flow {
  const _Flow({
    required this.name,
    required this.today,
    required this.safety,
    required this.advice,
    required this.alloc,
    required this.diag,
    required this.trust,
    required this.bottomKey,
    this.steps = _noSteps,
  });

  final String name;
  final OpsDailySummary today;
  final SafetyState safety;
  final AdviceInboxSummary advice;
  final SleeveAllocationVm alloc;
  final DiagnosticsVm diag;
  final LedgerTrustBadge trust;
  final Key bottomKey;
  final Future<void> Function(WidgetTester tester) steps;

  static Future<void> _noSteps(WidgetTester _) async {}
}

void main() {
  final OpsDailySummary normal = singleFixture(
    FixturePaths.m8OpsHomeNormal,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary blockedT = singleFixture(
    FixturePaths.m8OpsHomeBlocked,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary resume = singleFixture(
    FixturePaths.m8OpsHomeResumeGap7,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary adviceT = singleFixture(
    FixturePaths.m8OpsHomeAdviceOpen,
    OpsDailySummary.fromJson,
  );
  final OpsDailySummary zeroT = singleFixture(
    FixturePaths.m8OpsHomeAdviceZero,
    OpsDailySummary.fromJson,
  );
  final AdviceInboxSummary zero = extraFixture(
    FixturePaths.m8OpsHomeAdviceZero,
    'advice_summary',
    AdviceInboxSummary.fromJson,
  );
  final AdviceInboxSummary none = zero.copyWith(hasSuppressedNotice: false);
  final AdviceInboxSummary open = extraFixture(
    FixturePaths.m8OpsHomeAdviceOpen,
    'advice_summary',
    AdviceInboxSummary.fromJson,
  );
  final AdviceInboxSummary suppressed = extraFixture(
    FixturePaths.m6AdviceNoAction,
    'summary',
    AdviceInboxSummary.fromJson,
  );
  final SafetyState safe0 = safetyFixtureRow(0);
  final SafetyState safe1 = safetyFixtureRow(1);
  final SafetyState safe3 = safetyFixtureRow(3);
  final SleeveAllocationVm alloc = singleFixture(
    FixturePaths.m6AllocationInBand,
    SleeveAllocationVm.fromJson,
  );
  final DiagnosticsVm diff = singleFixture(
    FixturePaths.m8ReconBoardDiff,
    DiagnosticsVm.fromJson,
  );
  final DiagnosticsVm ok = singleFixture(
    FixturePaths.m8ReconBoardOk,
    DiagnosticsVm.fromJson,
  );
  final LedgerTrustBadge trustDue = singleFixture(
    FixturePaths.m7LedgerTrustSelfAuditDue,
    LedgerTrustBadge.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'h01_normal',
      today: normal,
      safety: safe0,
      advice: none,
      alloc: alloc,
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_blocked',
      today: blockedT,
      safety: safe3,
      advice: none,
      alloc: alloc,
      diag: diff,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_resume_gap7',
      today: resume,
      safety: safe0,
      advice: none,
      alloc: alloc,
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_recon_diff',
      today: normal,
      safety: safe0,
      advice: none,
      alloc: alloc,
      diag: diff,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_advice_open',
      today: adviceT,
      safety: safe0,
      advice: open,
      alloc: alloc,
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_advice_zero',
      today: zeroT,
      safety: safe0,
      advice: none,
      alloc: alloc,
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_advice_suppressed',
      today: zeroT,
      safety: safe0,
      advice: suppressed,
      alloc: alloc,
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_self_audit_due',
      today: normal,
      safety: safe1,
      advice: none,
      alloc: alloc,
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-audit'),
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const OpsHome(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: homeOverrides(
              safety: FakeShellSafetyRepository(
                state: (int call) => one(flow.safety),
              ),
              today: FakeShellOpsTodayRepository(
                today: (int call) => one(flow.today),
              ),
              advice: FakeShellAdviceRepository(
                summary: (int call) => one(flow.advice),
              ),
              alloc: FakeShellHoldingsRepository(
                allocation: (int call) => one(flow.alloc),
              ),
              diag: FakeShellOpsStatusRepository(
                diagnostics: (int call) => one(flow.diag),
              ),
              trust: FakeShellLedgerTrustRepository(
                grade: (int call) => one(flow.trust),
              ),
              opener: RecordingLinkOpener(),
              clock: FixedClock(kGoldenNowUtc),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        // 위치 전제 둘
        expect(
          tester.getBottomLeft(find.byKey(flow.bottomKey)).dy,
          lessThan(_kTallPhone.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('h01-asof'))).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
