// test/golden/x1_golden_test.dart — X1 기기 이전 골든(E16j-b · 01 §42 · 표본 `x1/*`).
//
// 🔴 최초 베이스라인만 이 파일 하나로 찍는다:
//      flutter test --update-goldens test/golden/x1_golden_test.dart
// 🔴 렌더 입력 = 계약 픽스처(`x1/plan_wizard_*` · `x1/recovery_*`) — 값을 고치지 않는다.
// 🔴 프레임이 지키는 것: ① D-03 카드 아래 시작 버튼 하나(건너뛰기 0) ② 단계 = VM 차례 그대로 · 막힘 행 = 그만두기만
//    ③ 시각 · 관찰 = 엔진 글자(카운트다운 0) ④ 확인 대화 0 ⑤ 코드 글자 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1900);

class _Repo implements MigrationRepository {
  const _Repo({this.plan, this.recovery});

  final X1PlanWizardVm? plan;
  final X1RecoveryVm? recovery;

  @override
  Stream<X1PlanWizardVm> watchPlanWizard() =>
      plan == null ? const Stream<X1PlanWizardVm>.empty() : Stream.value(plan!);

  @override
  Stream<X1RecoveryVm> watchPlanRecovery() => recovery == null
      ? const Stream<X1RecoveryVm>.empty()
      : Stream.value(recovery!);

  @override
  Stream<X1RecoveryVm> watchEmergencyRecovery() => watchPlanRecovery();
}

class _Links implements AppLinkOpener {
  @override
  void open(String link) {}
}

Widget _scope(Widget child, _Repo repo) => ProviderScope(
  overrides: <Override>[
    safetyMigrationRepositoryProvider.overrideWithValue(repo),
    safetyLinkOpenerProvider.overrideWithValue(_Links()),
    safetyActionsProvider.overrideWithValue(UnimplementedSafetyActions()),
  ],
  child: child,
);

const Map<String, String> _plans = <String, String>{
  'x1p_d03': 'plan_wizard_d03',
  'x1p_blocked': 'plan_wizard_blocked',
  'x1p_demoted': 'plan_wizard_demoted',
  'x1p_ticket': 'plan_wizard_ticket',
  'x1p_live_only': 'plan_wizard_live_only',
};

const Map<String, String> _recoveries = <String, String>{
  'x1r_plan_scan': 'recovery_plan_scan',
  'x1r_fencing': 'recovery_emergency_fencing',
  'x1r_gap_violation': 'recovery_gap_violation',
  'x1r_gate_biometric': 'recovery_gate_biometric',
  'x1r_full': 'recovery_full',
};

void main() {
  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, String> e in _plans.entries) {
      testWidgets('X1 옛 폰 ${e.value} · ${brightnessSuffix(b)}', (
        WidgetTester t,
      ) async {
        await pumpForGolden(
          t,
          _scope(
            const X1PlanWizardScreen(),
            _Repo(
              plan: singleFixture(
                'x1/${e.value}.json',
                X1PlanWizardVm.fromJson,
              ),
            ),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden(e.key, b);
      });
    }
    for (final MapEntry<String, String> e in _recoveries.entries) {
      testWidgets('X1 새 폰 ${e.value} · ${brightnessSuffix(b)}', (
        WidgetTester t,
      ) async {
        await pumpForGolden(
          t,
          _scope(
            const X1RecoveryScreen(route: X1RecoveryRoute.plan),
            _Repo(
              recovery: singleFixture(
                'x1/${e.value}.json',
                X1RecoveryVm.fromJson,
              ),
            ),
          ),
          brightness: b,
          logicalSize: _kTallPhone,
        );
        await t.pump();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
        await expectGolden(e.key, b);
      });
    }
  }
}
