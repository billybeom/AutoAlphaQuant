// 🆕 E16j-b — X1 기기 이전 화면 VM · 결과 글자(01 §42 K267~K273 · 미결 218 ⓐ · 표본 `x1/*`).
//
// 🔵 잡는 것: ① 옛 폰 차례(기기 id → 모의 → 안내 → 깨짐 → 시작 전 D-03 ⇔ 시작 동작 → 9행) ② 행 = `X1StepCodes.ordered` 차례 ·
//    행 동작 `step` = 행 코드 · 그만두기 = DEMOTED 앞만 ③ 🔴 열린 단계 = 1~3 · 4단계 행 = 막힘 문장 + 그만두기만(진행 동작 0)
//    ④ 미체결 막힘 = 줄 · 코드 · 그만두기만 ⑤ 잠김 = 동작 0 ⑥ 새 폰 = 복구 없음 막힘 문장 · 슬롯 · 시작 0 · RECOVERY_FULL = 링크
//    · 단계 5행 차례 · 게이트 카드 ⑦ 결과 글자 = 표본 문장(«(합성)» 뺀 것) ⑧ 숫자 칸 · 카운트다운 0(관찰 = n/m 글자).
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

final DateTime _now = DateTime.utc(2026, 11, 21, 3); // 한국 12:00
const String _run = 'mig-20261121-1';

Map<String, Object?> _fixtureRow(String name) {
  final Map<String, Object?> j = jsonDecode(
    File('../domain_contracts/fixtures/x1/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (j['rows']! as List<Object?>).first! as Map<String, Object?>;
}

String _plain(Object? s) => (s! as String).replaceFirst('(합성) ', '');

PlanProgress _progress(List<(PlanStep, MigrationStepState)> rows) =>
    planProgressOf(_run, <MigrationStepRow>[
      for (final (PlanStep s, MigrationStepState st) in rows)
        MigrationStepRow(
          runId: _run,
          step: s.wire,
          state: st.wire,
          atUtc: _now,
        ),
    ]);

List<(PlanStep, MigrationStepState)> _doneThrough(PlanStep last) =>
    <(PlanStep, MigrationStepState)>[
      for (final PlanStep s in PlanStep.values.take(
        last.index + 1,
      )) ...<(PlanStep, MigrationStepState)>[
        (s, MigrationStepState.entered),
        (s, MigrationStepState.done),
      ],
    ];

const PlanStepFacts _clean = PlanStepFacts(
  openOrders: 0,
  unknownOrders: 0,
  reconMismatches: 0,
  currentChainHash: 'c',
);

X1PlanWizardFacts _plan({
  RunMode runMode = RunMode.live,
  OperatingMode op = OperatingMode.autoTrade,
  bool device = true,
  bool broken = false,
  PlanProgress? progress,
  PlanStepFacts facts = _clean,
  DateTime? window,
  String? locked,
  X1TicketFacts? ticket,
}) => X1PlanWizardFacts(
  runMode: runMode,
  operatingMode: op,
  deviceKnown: device,
  nowUtc: _now,
  journalBroken: broken,
  runId: progress == null ? null : _run,
  progress: progress,
  stepFacts: facts,
  windowOpenedAtUtc: window,
  lockedLabel: locked,
  ticket: ticket,
);

/// 🔴 C-67 ⑤ — 행 동작의 `step` = 그 행 코드 · `run_id` = 저널.
void _argsMatchRows(List<X1StepRow> rows) {
  for (final X1StepRow r in rows) {
    for (final SafetyActionCall a in r.actions) {
      expect(a.args['step'], r.code, reason: '${r.code} ${a.id}');
      expect(a.args['run_id'], _run);
    }
  }
}

List<SafetyActionCall> _allActions(X1PlanWizardVm vm) => <SafetyActionCall>[
  ?vm.startAction,
  for (final X1StepRow r in vm.rows) ...r.actions,
];

final BackupManifest _manifest = BackupManifest(
  sha256: 'a' * 64,
  chainHash: '3f9a1c07${'0' * 56}',
  authoredDate: '2026-08-31',
  schemaVersion: 7,
  hashFormatVersion: 2,
  operatorEpoch: 4,
  writerDeviceId: 'dev-old',
);

MigrationGateVerdict _gate(MigrationGateFacts f, {int days = 2}) =>
    migrationGateOf(
      f,
      kind: MigrationKind.plan,
      config: MigrationObservationConfig(
        planTradingDays: days,
        emergencyTradingDays: 5,
      ),
    );

MigrationGateFacts _gf({
  bool? golden = true,
  int observed = 0,
  bool checklist = false,
  bool bio = false,
}) => MigrationGateFacts(
  goldenPassed: golden,
  reconMismatches: 0,
  unknownOrders: 0,
  openOrders: 0,
  observedTradingDays: observed,
  checklistConfirmed: checklist,
  biometricConfirmed: bio,
);

void main() {
  group('옛 폰 — 차례 · 시작 전', () {
    test('기기 id 없음 → 모의 → 안내 → 깨짐 = 행 0 · 동작 0 · 코드', () {
      final List<(X1PlanWizardFacts, String?, UiLevel)> cases =
          <(X1PlanWizardFacts, String?, UiLevel)>[
            (
              _plan(device: false, runMode: RunMode.simInternal),
              null,
              UiLevel.blocked,
            ),
            (
              _plan(runMode: RunMode.simInternal),
              X1StartResultCodes.liveOnly,
              UiLevel.info,
            ),
            (
              _plan(op: OperatingMode.advisory),
              X1StartResultCodes.advisoryPending,
              UiLevel.info,
            ),
            (
              _plan(broken: true),
              X1BootRefusalCodes.journalBroken,
              UiLevel.blocked,
            ),
          ];
      for (final (X1PlanWizardFacts f, String? code, UiLevel level) in cases) {
        final X1PlanWizardVm vm = x1PlanWizardVmOf(f);
        expect(vm.reasonCode, code);
        expect(vm.level, level);
        expect(vm.rows, isEmpty);
        expect(vm.d03Card, isNull);
        expect(_allActions(vm), isEmpty);
      }
      expect(
        x1PlanWizardVmOf(_plan(runMode: RunMode.simInternal)).headline,
        _plain(_fixtureRow('plan_wizard_live_only')['headline']),
      );
    });

    test('🔴 시작 전 = D-03 한 장 ⇔ 시작 동작 `{}` · 행 0 · 표본 글자 · 중단된 이전도 같다', () {
      for (final PlanProgress? p in <PlanProgress?>[
        null,
        _progress(<(PlanStep, MigrationStepState)>[
          (PlanStep.freeze, MigrationStepState.entered),
          (PlanStep.freeze, MigrationStepState.failed),
        ]),
      ]) {
        final X1PlanWizardVm vm = x1PlanWizardVmOf(_plan(progress: p));
        final Map<String, Object?> fx = _fixtureRow('plan_wizard_d03');
        expect(vm.headline, _plain(fx['headline']));
        expect(vm.d03Card, kX1D03Card);
        expect(
          vm.d03Card!.toJson(),
          EmergencyCardVm.fromJson(fx['d03_card']! as Map<String, Object?>)
              .toJson(),
        );
        expect(vm.startAction?.id, SafetyActionId.x1PlanStart);
        expect(vm.startAction?.args, isEmpty);
        expect(
          vm.startAction?.label,
          _plain((fx['start_action']! as Map<String, Object?>)['label']),
        );
        expect(vm.rows, isEmpty);
      }
    });

    test('잠김 = 시작 동작 0 · 카드 그대로', () {
      final X1PlanWizardVm vm = x1PlanWizardVmOf(_plan(locked: '잠김'));
      expect(vm.d03Card, isNotNull);
      expect(vm.startAction, isNull);
      expect(vm.lockedLabel, '잠김');
    });
  });

  group('옛 폰 — 단계 9행', () {
    test('🔴 FREEZE 들어감 = 9행 차례 · 지금 = 진행 + 그만두기(step = 행 코드) · 나머지 대기', () {
      final X1PlanWizardVm vm = x1PlanWizardVmOf(
        _plan(
          progress: _progress(<(PlanStep, MigrationStepState)>[
            (PlanStep.freeze, MigrationStepState.entered),
          ]),
        ),
      );
      expect(<String>[
        for (final X1StepRow r in vm.rows) r.code,
      ], X1StepCodes.ordered);
      expect(vm.headline, X1ScreenTexts.inProgress);
      _argsMatchRows(vm.rows);
      final X1StepRow f = vm.rows.first;
      expect(f.stateLabel, X1ScreenTexts.stateTurn);
      expect(
        <SafetyActionId>[for (final SafetyActionCall a in f.actions) a.id],
        <SafetyActionId>[SafetyActionId.x1PlanStep, SafetyActionId.x1PlanAbort],
      );
      for (final SafetyActionCall a in f.actions) {
        expect(a.args, <String, String>{'run_id': _run, 'step': 'FREEZE'});
      }
      for (final X1StepRow r in vm.rows.skip(1)) {
        expect(r.stateLabel, X1ScreenTexts.stateWaiting);
        expect(r.actions, isEmpty);
      }
      expect(vm.rows.first.title, '1 주문 동결');
      expect(vm.rows.last.title, '9 티켓 발급');
    });

    test('🔴 미체결 막힘 = 머리 · 줄 · 코드 = 표본(plan_wizard_blocked) · 동작 = 그만두기만', () {
      final X1PlanWizardVm vm = x1PlanWizardVmOf(
        _plan(
          progress: _progress(_doneThrough(PlanStep.freeze)),
          facts: const PlanStepFacts(
            openOrders: 1,
            unknownOrders: 0,
            reconMismatches: 0,
            currentChainHash: 'c',
          ),
          window: DateTime.utc(2026, 8, 31, 9),
        ),
      );
      final Map<String, Object?> fx = _fixtureRow('plan_wizard_blocked');
      expect(vm.headline, _plain(fx['headline']));
      expect(vm.reasonCode, X1StepBlockCodes.openOrders);
      expect(vm.level, UiLevel.blocked);
      expect(vm.windowText, _plain(fx['window_text']));
      final X1StepRow row = vm.rows[1];
      final Map<String, Object?> fr =
          (fx['rows']! as List<Object?>)[1]! as Map<String, Object?>;
      expect(row.title, _plain(fr['title']));
      expect(row.stateLabel, _plain(fr['state_label']));
      expect(row.lines, <String>[
        _plain((fr['lines']! as List<Object?>).single),
      ]);
      expect(row.blockCode, X1StepBlockCodes.openOrders);
      _argsMatchRows(vm.rows);
      expect(row.actions.single.id, SafetyActionId.x1PlanAbort);
      expect(
        row.actions.single.label,
        _plain(
          ((fr['actions']! as List<Object?>).single!
              as Map<String, Object?>)['label'],
        ),
      );
      expect(
        vm.rows[0].stateLabel,
        _plain(
          ((fx['rows']! as List<Object?>).first!
              as Map<String, Object?>)['state_label'],
        ),
      );
    });

    test('UNKNOWN · 대사 막힘 = 각자 코드 · 줄', () {
      final PlanProgress p = _progress(_doneThrough(PlanStep.freeze));
      final X1PlanWizardVm u = x1PlanWizardVmOf(
        _plan(
          progress: p,
          facts: const PlanStepFacts(
            openOrders: 0,
            unknownOrders: 2,
            reconMismatches: 0,
            currentChainHash: 'c',
          ),
        ),
      );
      expect(u.reasonCode, X1StepBlockCodes.unknownOrders);
      expect(u.rows[1].lines, <String>[X1ScreenTexts.unknownOrdersLine(2)]);
      final X1PlanWizardVm r = x1PlanWizardVmOf(
        _plan(
          progress: _progress(_doneThrough(PlanStep.ordersCleared)),
          facts: const PlanStepFacts(
            openOrders: 0,
            unknownOrders: 0,
            reconMismatches: 1,
            currentChainHash: 'c',
          ),
        ),
      );
      expect(r.reasonCode, X1StepBlockCodes.reconNotZero);
      expect(r.rows[2].blockCode, X1StepBlockCodes.reconNotZero);
    });

    test('🔴 1~3 끝 = 4단계 행 막힘 문장 + 그만두기만(진행 0) · 머리 = 닫힘 · 백업 없음은 막음 아님', () {
      expect(kX1PlanOpenThrough, PlanStep.reconZero);
      expect(x1PlanStepOpen(PlanStep.reconZero), isTrue);
      expect(x1PlanStepOpen(PlanStep.backupChecksum), isFalse);
      final X1PlanWizardVm vm = x1PlanWizardVmOf(
        _plan(progress: _progress(_doneThrough(PlanStep.reconZero))),
      );
      _argsMatchRows(vm.rows);
      expect(vm.headline, X1ScreenTexts.closedHeadline);
      expect(vm.level, UiLevel.blocked);
      expect(vm.reasonCode, isNull);
      final X1StepRow b = vm.rows[3];
      expect(b.code, X1StepCodes.backupChecksum);
      expect(b.stateLabel, X1ScreenTexts.stateBlocked);
      expect(b.lines, <String>[X1ScreenTexts.closedLine]);
      expect(b.blockCode, isNull);
      expect(
        <SafetyActionId>[for (final SafetyActionCall a in b.actions) a.id],
        <SafetyActionId>[SafetyActionId.x1PlanAbort],
      );
      for (final X1StepRow r in vm.rows.take(3)) {
        expect(r.stateLabel, X1ScreenTexts.stateDone);
        expect(r.actions, isEmpty);
      }
    });

    test(
      '🔴 DEMOTED 뒤(다른 길로 넘은 저널) = 되돌리기 0 · DEMOTED 줄 · 유예 경고 · 닫힌 단계 = 동작 0',
      () {
        final X1PlanWizardVm vm = x1PlanWizardVmOf(
          _plan(progress: _progress(_doneThrough(PlanStep.demoted))),
        );
        final Map<String, Object?> fx = _fixtureRow('plan_wizard_demoted');
        expect(vm.headline, _plain(fx['headline']));
        expect(vm.rows[4].lines, <String>[X1ScreenTexts.noReturn]);
        expect(
          vm.rows[4].lines.single,
          _plain(
            (((fx['rows']! as List<Object?>)[4]!
                        as Map<String, Object?>)['lines']!
                    as List<Object?>)
                .single,
          ),
        );
        expect(vm.warningLines, <String>[X1ScreenTexts.graceLine]);
        expect(
          _allActions(
            vm,
          ).where((SafetyActionCall a) => a.id == SafetyActionId.x1PlanAbort),
          isEmpty,
        );
        expect(vm.rows[5].actions, isEmpty, reason: '키 삭제 = 아직 닫힘');
      },
    );

    test('잠김 = 행 동작 0', () {
      final X1PlanWizardVm vm = x1PlanWizardVmOf(
        _plan(progress: _progress(_doneThrough(PlanStep.freeze)), locked: '잠김'),
      );
      expect(_allActions(vm), isEmpty);
    });

    test('끝 = 티켓 카드(만료 절대 시각 · 체인 8자 · 페이로드 0) · 동작 0', () {
      final X1PlanWizardVm vm = x1PlanWizardVmOf(
        _plan(
          progress: _progress(_doneThrough(PlanStep.ticketIssued)),
          ticket: X1TicketFacts(
            expiresAtUtc: DateTime.utc(2026, 8, 31, 9, 45),
            backupAuthoredDate: '08-31 18:00',
            chainHash: '3f9a1c07${'e' * 56}',
          ),
        ),
      );
      final Map<String, Object?> fx = _fixtureRow('plan_wizard_ticket');
      final Map<String, Object?> ft = fx['ticket']! as Map<String, Object?>;
      expect(vm.headline, _plain(fx['headline']));
      expect(vm.ticket?.headline, _plain(ft['headline']));
      expect(vm.ticket?.ticketSlotId, X1SlotIds.ticketQrDisplay);
      expect(vm.ticket?.expiresText, _plain(ft['expires_text']));
      expect(vm.ticket?.lines, <String>[
        _plain((ft['lines']! as List<Object?>).single),
      ]);
      expect(_allActions(vm), isEmpty);
    });
  });

  group('새 폰', () {
    test('🔴 복구 없음 = 갈래별 막힘 문장 · 시작 · 슬롯 · 행 0', () {
      for (final MigrationKind k in MigrationKind.values) {
        final X1RecoveryVm vm = x1RecoveryVmOf(
          X1RecoveryFacts(routeKind: k, nowUtc: _now),
        );
        expect(vm.level, UiLevel.blocked);
        expect(vm.startAction, isNull);
        expect(vm.recoveryCodeSlotId, isNull);
        expect(vm.scanSlotId, isNull);
        expect(vm.reissue, isEmpty);
        expect(vm.steps, isEmpty);
        expect(vm.noticeText, isNotNull);
        expect(
          vm.kindLabel,
          k == MigrationKind.plan
              ? X1ScreenTexts.planKind
              : X1ScreenTexts.emergencyKind,
        );
      }
      expect(
        X1ScreenTexts.planKind,
        _plain(_fixtureRow('recovery_plan_scan')['kind_label']),
      );
      expect(
        X1ScreenTexts.emergencyKind,
        _plain(_fixtureRow('recovery_emergency_start')['kind_label']),
      );
    });

    test('복구 저널 깨짐 = 코드 · 동작 0', () {
      final X1RecoveryVm vm = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          journalBroken: true,
        ),
      );
      expect(vm.reasonCode, X1BootRefusalCodes.journalBroken);
      expect(vm.steps, isEmpty);
    });

    X1RecoveryRunFacts run({
      bool rebuilt = true,
      MigrationKind kind = MigrationKind.plan,
    }) => X1RecoveryRunFacts(
      runId: _run,
      kind: kind,
      manifest: _manifest,
      gapRebuilt: rebuilt,
    );

    test('🔴 RECOVERY_FULL = 표본 머리 · 링크 = onboardingRestart · 행 0 · 복원 카드', () {
      final X1RecoveryVm vm = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(kind: MigrationKind.emergency),
          recoveryFull: true,
        ),
      );
      final Map<String, Object?> fx = _fixtureRow('recovery_full');
      expect(vm.headline, _plain(fx['headline']));
      expect(vm.reasonCode, X1OrderSealCodes.full);
      expect(
        vm.kindLabel,
        X1ScreenTexts.emergencyKind,
        reason: '복구 갈래가 라우트를 이긴다',
      );
      expect(vm.restartLink?.deepLink, AppRoutes.onboardingRestart);
      expect(
        vm.restartLink?.label,
        _plain((fx['restart_link']! as Map<String, Object?>)['label']),
      );
      expect(vm.steps, isEmpty);
      final Map<String, Object?> fr = fx['restore']! as Map<String, Object?>;
      expect(vm.restore?.headline, _plain(fr['headline']));
      expect(vm.restore?.chainHashText, fr['chain_hash_text']);
      expect(
        vm.restore?.lines.single,
        '백업 2026-08-31 · 스키마 판 7 · 해시 판 2 · epoch 4',
      );
    });

    test('갭 재구성 전 = 막힘 행 · 봉인 코드 · 게이트 0 · 동작 0', () {
      final X1RecoveryVm vm = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(rebuilt: false),
          goldenRunnable: true,
        ),
      );
      expect(vm.reasonCode, X1OrderSealCodes.inProgress);
      expect(<String>[
        for (final X1StepRow r in vm.steps) r.code,
      ], X1RecoveryStepCodes.ordered);
      expect(vm.steps[1].stateLabel, X1ScreenTexts.stateBlocked);
      expect(vm.steps[1].lines, <String>[X1ScreenTexts.gapBlockedLine]);
      expect(vm.gate, isNull);
      expect(<SafetyActionCall>[
        for (final X1StepRow r in vm.steps) ...r.actions,
      ], isEmpty);
    });

    test('🔴 골든 아직 = 진행 동작(실행기 있을 때만) · 실패 = 실패 줄 · 코드 · 다시', () {
      X1RecoveryVm vmOf(Set<String> golden, bool runnable, bool? passed) =>
          x1RecoveryVmOf(
            X1RecoveryFacts(
              routeKind: MigrationKind.plan,
              nowUtc: _now,
              run: run(),
              goldenStates: golden,
              gate: _gate(_gf(golden: passed)),
              goldenRunnable: runnable,
            ),
          );
      final X1RecoveryVm notRun = vmOf(const <String>{}, true, null);
      expect(notRun.reasonCode, X1GateReasonCodes.goldenNotRun);
      _argsMatchRows(notRun.steps);
      expect(notRun.steps[2].actions.single.args, <String, String>{
        'run_id': _run,
        'step': 'GOLDEN_SELF_TEST',
      });
      expect(vmOf(const <String>{}, false, null).steps[2].actions, isEmpty);
      expect(vmOf(const <String>{}, false, null).steps[2].lines, <String>[
        X1ScreenTexts.goldenAbsentLine,
      ]);
      final X1RecoveryVm failed = vmOf(const <String>{'FAILED'}, true, false);
      expect(failed.steps[2].stateLabel, X1ScreenTexts.stateFailed);
      expect(failed.steps[2].blockCode, X1GateReasonCodes.goldenFailed);
      expect(failed.steps[2].actions, hasLength(1));
      expect(failed.headline, X1ScreenTexts.goldenFailedHeadline);
    });

    test('🔴 관찰 = 표본(recovery_gate_observing) 글자 · n/m · 확인 목록 차례(동작 0)', () {
      final X1RecoveryVm vm = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(),
          goldenStates: const <String>{'DONE'},
          gate: _gate(_gf(observed: 2), days: 5),
        ),
      );
      final Map<String, Object?> fx = _fixtureRow('recovery_gate_observing');
      final Map<String, Object?> fg = fx['gate']! as Map<String, Object?>;
      expect(vm.headline, _plain(fx['headline']));
      expect(vm.reasonCode, X1GateReasonCodes.observing);
      expect(vm.gate?.stateLabel, _plain(fg['state_label']));
      expect(vm.gate?.observeText, _plain(fg['observe_text']));
      expect(vm.gate?.whyLine, _plain(fg['why_line']));
      expect(vm.gate?.actionLine, isNull);
      expect(vm.gate?.gateStateCode, X1GateStateCodes.observing);
      expect(vm.steps[3].stateLabel, X1ScreenTexts.stateTurn);
      expect(vm.steps[3].actions, isEmpty);
    });

    test('🔴 확인 목록 차례 = 동작 · 생체 차례 = 표본(recovery_gate_biometric) · 생체 동작(띄울 수 있을 때만)', () {
      final X1RecoveryVm cl = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(),
          goldenStates: const <String>{'DONE'},
          gate: _gate(_gf(observed: 2)),
        ),
      );
      expect(cl.reasonCode, X1GateReasonCodes.checklistPending);
      _argsMatchRows(cl.steps);
      expect(cl.steps[3].actions.single.args['step'], 'CHECKLIST_CONFIRMED');
      expect(cl.gate?.checklistLines, X1ScreenTexts.checklistLines);

      X1RecoveryVm bio(bool runnable) => x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(),
          goldenStates: const <String>{'DONE'},
          gate: _gate(_gf(observed: 5, checklist: true), days: 5),
          biometricRunnable: runnable,
        ),
      );
      final X1RecoveryVm vm = bio(true);
      final Map<String, Object?> fx = _fixtureRow('recovery_gate_biometric');
      final Map<String, Object?> fg = fx['gate']! as Map<String, Object?>;
      expect(vm.headline, _plain(fx['headline']));
      expect(vm.gate?.stateLabel, _plain(fg['state_label']));
      expect(vm.gate?.observeText, _plain(fg['observe_text']));
      expect(vm.gate?.whyLine, _plain(fg['why_line']));
      expect(vm.gate?.actionLine, _plain(fg['action_line']));
      expect(vm.gate?.checklistLines, <String>[
        for (final Object? l in fg['checklist_lines']! as List<Object?>)
          _plain(l),
      ]);
      expect(vm.steps[3].stateLabel, X1ScreenTexts.stateDone);
      expect(vm.steps[4].actions.single.args, <String, String>{
        'run_id': _run,
        'step': 'BIOMETRIC_CONFIRMED',
      });
      expect(bio(false).steps[4].actions, isEmpty);
    });

    test('통과 = 5행 끝 · 동작 0 · 잠김 = 동작 0', () {
      final X1RecoveryVm vm = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(),
          goldenStates: const <String>{'DONE'},
          gate: _gate(_gf(observed: 2, checklist: true, bio: true)),
        ),
      );
      expect(vm.headline, X1ScreenTexts.passedHeadline);
      for (final X1StepRow r in vm.steps) {
        expect(r.stateLabel, X1ScreenTexts.stateDone);
        expect(r.actions, isEmpty);
      }
      final X1RecoveryVm locked = x1RecoveryVmOf(
        X1RecoveryFacts(
          routeKind: MigrationKind.plan,
          nowUtc: _now,
          run: run(),
          gate: _gate(_gf(golden: null)),
          goldenRunnable: true,
          lockedLabel: '잠김',
        ),
      );
      expect(<SafetyActionCall>[
        for (final X1StepRow r in locked.steps) ...r.actions,
      ], isEmpty);
    });
  });

  group('결과 글자', () {
    test('🔴 표본(x1_action_results) 머리 = 엔진 글자 · 등급 · 다시 가능', () {
      final Map<String, Object?> j = jsonDecode(
        File('../domain_contracts/fixtures/x1/x1_action_results.json')
            .readAsStringSync(),
      ) as Map<String, Object?>;
      for (final Object? o in j['rows']! as List<Object?>) {
        final SafetyActionResult want = SafetyActionResult.fromJson(
          o! as Map<String, Object?>,
        );
        final SafetyActionResult got = x1ActionResultOf(
          id: want.id,
          actionRunId: want.actionRunId,
          code: want.reasonCode,
        );
        expect(
          got.headline,
          _plain(want.headline),
          reason: '${want.id} ${want.reasonCode}',
        );
        expect(got.level, want.level, reason: '${want.id} ${want.reasonCode}');
        expect(
          got.retryable,
          want.retryable,
          reason: '${want.id} ${want.reasonCode}',
        );
        expect(got.reasonCode, want.reasonCode);
      }
    });

    test('X1 밖 동작 = ArgumentError · 모르는 코드 = 일반 문장', () {
      expect(
        () => x1ActionResultOf(
          id: SafetyActionId.reconClear,
          actionRunId: 'a',
          code: null,
        ),
        throwsArgumentError,
      );
      expect(
        x1ActionResultOf(
          id: SafetyActionId.x1PlanStep,
          actionRunId: 'a',
          code: 'ZZZ',
        ).headline,
        '진행하지 않았습니다',
      );
    });
  });
}
