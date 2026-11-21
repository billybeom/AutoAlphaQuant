// 🆕 E16j-b — X1 기기 이전 화면(01 §42) — 읽기 모델 = 계약 픽스처(`x1/*`).
//
// 🔴 화면은 받은 글자 · 차례 그대로 · 코드 칸 = 그리지 않음 · 동작 = VM · 행이 준 것만(쓰기 주입 null = 버튼 0) · 결과 = 엔진 글자 ·
//    제출 실패 = 정적 문장 · 확인 대화 0 · D-03 건너뛰기 0 · 슬롯 = 빌더(없으면 자리 부재).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

Map<String, dynamic> _row(String name) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/x1/$name.json')
                      .readAsStringSync(),
                ) as Map<String, dynamic>)['rows']
                as List<dynamic>)
            .first
        as Map<String, dynamic>;

class _Repo implements MigrationRepository {
  final StreamController<X1PlanWizardVm> plan =
      StreamController<X1PlanWizardVm>();
  final StreamController<X1RecoveryVm> receive =
      StreamController<X1RecoveryVm>();
  final StreamController<X1RecoveryVm> emergency =
      StreamController<X1RecoveryVm>();

  @override
  Stream<X1PlanWizardVm> watchPlanWizard() => plan.stream;

  @override
  Stream<X1RecoveryVm> watchPlanRecovery() => receive.stream;

  @override
  Stream<X1RecoveryVm> watchEmergencyRecovery() => emergency.stream;

  /// 🔴 기다리지 않는다 — 듣는 쪽이 없던 흐름의 close() 는 끝나지 않는다.
  void close() {
    unawaited(plan.close());
    unawaited(receive.close());
    unawaited(emergency.close());
  }
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.fail = false});

  final bool fail;
  final List<(SafetyActionId, Map<String, String>)> calls =
      <(SafetyActionId, Map<String, String>)>[];

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    calls.add((id, args));
    if (fail) throw StateError('제출 실패');
    return SafetyActionResult(
      actionRunId: 'run-1',
      id: id,
      level: UiLevel.blocked,
      headline: '엔진 결과 글자',
      reasonCode: 'OPEN_ORDERS_REMAIN',
      retryable: true,
    );
  }
}

Future<(_Repo, _Links)> _pump(
  WidgetTester t,
  Widget screen, {
  SafetyActions? actions,
  SafetyX1SlotBuilder? slot,
}) async {
  t.view.physicalSize = const Size(800, 3200);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  final _Links links = _Links();
  await t.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyMigrationRepositoryProvider.overrideWithValue(repo),
        safetyLinkOpenerProvider.overrideWithValue(links),
        safetyActionsProvider.overrideWithValue(actions),
        safetyX1SlotBuilderProvider.overrideWithValue(slot),
      ],
      child: MaterialApp(home: Scaffold(body: screen)),
    ),
  );
  return (repo, links);
}

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump();
}

Widget _slot(String id) => SizedBox(key: Key('slot:$id'), height: 10);

void main() {
  group('옛 폰', () {
    testWidgets(
      '🔴 시작 전 = D-03 한 장 + 시작 버튼(건너뛰기 0) · 누르면 `{}` 그대로 · 결과 = 엔진 글자',
      (WidgetTester t) async {
        final _Actions a = _Actions();
        final (_Repo repo, _) = await _pump(
          t,
          const X1PlanWizardScreen(),
          actions: a,
          slot: _slot,
        );
        expect(find.byKey(const Key('x1p-loading')), findsOneWidget);
        final X1PlanWizardVm vm = X1PlanWizardVm.fromJson(
          _row('plan_wizard_d03'),
        );
        repo.plan.add(vm);
        await _settle(t);
        expect(find.text(vm.headline), findsOneWidget);
        expect(find.text(vm.d03Card!.title), findsOneWidget);
        for (final RunbookStep s in vm.d03Card!.steps) {
          expect(find.text(s.text), findsOneWidget);
        }
        expect(find.text(vm.d03Card!.contactLine), findsOneWidget);
        expect(
          find.byKey(const Key('slot:EMERGENCY_CARD_PRINT')),
          findsOneWidget,
        );
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(OutlinedButton), findsNothing);
        await t.tap(find.byKey(const Key('x1p-start')));
        await _settle(t);
        expect(a.calls.single.$1, SafetyActionId.x1PlanStart);
        expect(a.calls.single.$2, isEmpty);
        expect(find.text('엔진 결과 글자 (OPEN_ORDERS_REMAIN)'), findsOneWidget);
        expect(find.byType(Dialog), findsNothing);
      },
    );

    testWidgets('🔴 막힘 = 행 9 차례 · 줄 · 그만두기만 · 코드 글자 0 · 행 동작 args 그대로', (
      WidgetTester t,
    ) async {
      final _Actions a = _Actions();
      final (_Repo repo, _) = await _pump(
        t,
        const X1PlanWizardScreen(),
        actions: a,
      );
      final X1PlanWizardVm vm = X1PlanWizardVm.fromJson(
        _row('plan_wizard_blocked'),
      );
      repo.plan.add(vm);
      await _settle(t);
      final List<String> keys = <String>[
        for (final Element e in find.byType(Card).evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ];
      expect(keys, <String>[
        for (final X1StepRow r in vm.rows) 'x1p-row-${r.code}',
      ]);
      expect(find.text(vm.windowText!), findsOneWidget);
      expect(find.text(vm.rows[1].lines.single), findsOneWidget);
      expect(find.text('OPEN_ORDERS_REMAIN'), findsNothing);
      expect(find.byType(OutlinedButton), findsOneWidget);
      await t.tap(
        find.byKey(const Key('x1p-row-ORDERS_CLEARED-act-X1_PLAN_ABORT')),
      );
      await _settle(t);
      expect(a.calls.single.$1, SafetyActionId.x1PlanAbort);
      expect(a.calls.single.$2, vm.rows[1].actions.single.args);
      expect(
        find.byKey(const Key('x1p-row-ORDERS_CLEARED-result')),
        findsOneWidget,
      );
    });

    testWidgets('잠김 = 잠김 글자 · 버튼 0 · 쓰기 주입 없음 = 버튼 0', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(
        t,
        const X1PlanWizardScreen(),
        actions: _Actions(),
      );
      final X1PlanWizardVm vm = X1PlanWizardVm.fromJson(
        _row('plan_wizard_locked'),
      );
      repo.plan.add(vm);
      await _settle(t);
      expect(find.text(vm.lockedLabel!), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);

      final (_Repo r2, _) = await _pump(t, const X1PlanWizardScreen());
      r2.plan.add(X1PlanWizardVm.fromJson(_row('plan_wizard_d03')));
      await _settle(t);
      expect(find.byType(FilledButton), findsNothing);
      // 행에 동작이 있어도 쓰기 주입이 없으면 버튼 0(뷰어 · 시험 조립).
      final (_Repo r3, _) = await _pump(t, const X1PlanWizardScreen());
      r3.plan.add(X1PlanWizardVm.fromJson(_row('plan_wizard_blocked')));
      await _settle(t);
      expect(find.byKey(const Key('x1p-row-ORDERS_CLEARED')), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('제출 자체 실패 = 정적 문장(접수증 아님)', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(
        t,
        const X1PlanWizardScreen(),
        actions: _Actions(fail: true),
      );
      repo.plan.add(X1PlanWizardVm.fromJson(_row('plan_wizard_d03')));
      await _settle(t);
      await t.tap(find.byKey(const Key('x1p-start')));
      await _settle(t);
      expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    });

    testWidgets('티켓 = QR 슬롯 · 만료 절대 시각 · 줄 / 슬롯 빌더 없음 = 자리 부재', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(
        t,
        const X1PlanWizardScreen(),
        slot: _slot,
      );
      final X1PlanWizardVm vm = X1PlanWizardVm.fromJson(
        _row('plan_wizard_ticket'),
      );
      repo.plan.add(vm);
      await _settle(t);
      expect(
        find.byKey(const Key('slot:X1_TICKET_QR_DISPLAY')),
        findsOneWidget,
      );
      expect(find.text(vm.ticket!.expiresText!), findsOneWidget);
      final (_Repo r2, _) = await _pump(t, const X1PlanWizardScreen());
      r2.plan.add(vm);
      await _settle(t);
      expect(find.byKey(const Key('slot:X1_TICKET_QR_DISPLAY')), findsNothing);
    });

    testWidgets('읽기 오류 = 읽기 실패 문장', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(t, const X1PlanWizardScreen());
      repo.plan.addError(StateError('x'));
      await _settle(t);
      expect(find.text(SafetyLabels.x1ReadFailed), findsOneWidget);
    });
  });

  group('새 폰', () {
    testWidgets('🔴 비상 펜싱 = 끝 시각 글자 · 재발급 6행 차례 · 값 슬롯 · 기록 버튼 = 행 동작', (
      WidgetTester t,
    ) async {
      final _Actions a = _Actions();
      final (_Repo repo, _) = await _pump(
        t,
        const X1RecoveryScreen(route: X1RecoveryRoute.emergency),
        actions: a,
        slot: _slot,
      );
      final X1RecoveryVm vm = X1RecoveryVm.fromJson(
        _row('recovery_emergency_fencing'),
      );
      repo.emergency.add(vm);
      await _settle(t);
      expect(find.text(vm.fencing!.endsAtText!), findsOneWidget);
      final List<String> keys = <String>[
        for (final Element e in find.byType(Card).evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ].where((String k) => k.startsWith('x1r-reissue-')).toList();
      expect(keys, <String>[
        for (final X1ReissueRow r in vm.reissue) 'x1r-reissue-${r.code}',
      ]);
      expect(
        find.byKey(const Key('slot:SECRET_X1_REISSUE')),
        findsNWidgets(
          vm.reissue.where((X1ReissueRow r) => r.reissueSlotId != null).length,
        ),
      );
      await t.tap(find.byKey(const Key('x1r-reissue-GITHUB_PAT-act')));
      await _settle(t);
      expect(a.calls.single.$1, SafetyActionId.x1ReissueRecord);
      expect(a.calls.single.$2['item'], 'GITHUB_PAT');
    });

    testWidgets('받기 = 스캔 슬롯 · 비상 시작 = 복구 코드 슬롯 + 시작 버튼', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(
        t,
        const X1RecoveryScreen(route: X1RecoveryRoute.plan),
        actions: _Actions(),
        slot: _slot,
      );
      repo.receive.add(X1RecoveryVm.fromJson(_row('recovery_plan_scan')));
      await _settle(t);
      expect(find.byKey(const Key('slot:X1_TICKET_QR_SCAN')), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      final (_Repo r2, _) = await _pump(
        t,
        const X1RecoveryScreen(route: X1RecoveryRoute.emergency),
        actions: _Actions(),
        slot: _slot,
      );
      final X1RecoveryVm e = X1RecoveryVm.fromJson(
        _row('recovery_emergency_start'),
      );
      r2.emergency.add(e);
      await _settle(t);
      expect(
        find.byKey(const Key('slot:SECRET_X1_RECOVERY_CODE')),
        findsOneWidget,
      );
      expect(find.text(e.startAction!.label), findsOneWidget);
      expect(find.text(e.noticeText!), findsOneWidget);
    });

    testWidgets('🔴 게이트 생체 = 단계 5행 차례 · 게이트 글자 · 생체 단계 동작', (
      WidgetTester t,
    ) async {
      final _Actions a = _Actions();
      final (_Repo repo, _) = await _pump(
        t,
        const X1RecoveryScreen(route: X1RecoveryRoute.plan),
        actions: a,
      );
      final X1RecoveryVm vm = X1RecoveryVm.fromJson(
        _row('recovery_gate_biometric'),
      );
      repo.receive.add(vm);
      await _settle(t);
      final List<String> rows = <String>[
        for (final Element e in find.byType(Card).evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ].where((String k) => k.startsWith('x1r-row-')).toList();
      expect(rows, <String>[
        for (final X1StepRow r in vm.steps) 'x1r-row-${r.code}',
      ]);
      expect(find.text(vm.gate!.observeText!), findsOneWidget);
      expect(find.text(vm.gate!.actionLine!), findsOneWidget);
      for (final String l in vm.gate!.checklistLines) {
        expect(find.text(l), findsOneWidget);
      }
      expect(find.text('X1_BIOMETRIC_PENDING'), findsNothing);
      await t.tap(
        find.byKey(
          const Key('x1r-row-BIOMETRIC_CONFIRMED-act-X1_RECOVERY_STEP'),
        ),
      );
      await _settle(t);
      expect(a.calls.single.$2['step'], 'BIOMETRIC_CONFIRMED');
    });

    testWidgets('🔴 RECOVERY_FULL = 링크 하나(엔진 완성) · 버튼 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _Links links) = await _pump(
        t,
        const X1RecoveryScreen(route: X1RecoveryRoute.emergency),
        actions: _Actions(),
      );
      final X1RecoveryVm vm = X1RecoveryVm.fromJson(_row('recovery_full'));
      repo.emergency.add(vm);
      await _settle(t);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      await t.tap(find.byKey(const Key('x1r-restart')));
      await _settle(t);
      expect(links.opened, <String>[vm.restartLink!.deepLink]);
    });
  });
}
