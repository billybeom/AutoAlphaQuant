// C-67 E16j-b 계약 창 — X1 기기 이전 화면 — 01 §42
// (🆕 계약 v1.33 · 발주자 위임 2026-11-14 — 권고대로 · K264~K281).
//
// 정의: 「옛 폰 = `X1PlanWizardVm`(D-03 → 9단계 → 티켓) · 새 폰 = `X1RecoveryVm`(받기 · 비상 공용 · 5단계 · 게이트) · 동작 = 엔진 완성
//        `run` 6 · 시크릿 = 슬롯 · 잠김 · 끝 ⇒ 동작 · 슬롯 0 · 숫자 칸 0 · 타입 이름 ≠ 엔진」.
//   ① 라우트 무변경 ② 옛 폰 행 ③ 새 폰 행 ④ D-03 ⇔ 시작 ⑤ 옛 폰 동작표 ⑥ 새 폰 동작표 ⑦ 재발급 행 ⑧ 슬롯
//   ⑨ 코드 칸 ⑩ 잠김 · 끝 ⑪ RECOVERY_FULL 링크 ⑫ 결과 표본 ⑬ 포트 경계 ⑭ 이름 ≠ 엔진 · 사전 · 와이어.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

List<Map<String, Object?>> _rows(String path) =>
    ((jsonDecode(readFixture(path)) as Map<String, Object?>)['rows']! as List)
        .cast<Map<String, Object?>>();

const List<String> _plans = <String>[
  FixturePaths.x1PlanWizardBlocked,
  FixturePaths.x1PlanWizardD03,
  FixturePaths.x1PlanWizardDemoted,
  FixturePaths.x1PlanWizardLiveOnly,
  FixturePaths.x1PlanWizardLocked,
  FixturePaths.x1PlanWizardTicket,
];

const List<String> _recoveries = <String>[
  FixturePaths.x1RecoveryEmergencyFencing,
  FixturePaths.x1RecoveryEmergencyStart,
  FixturePaths.x1RecoveryFull,
  FixturePaths.x1RecoveryGapViolation,
  FixturePaths.x1RecoveryGateBiometric,
  FixturePaths.x1RecoveryGateObserving,
  FixturePaths.x1RecoveryPlanScan,
  FixturePaths.x1RecoveryRestoreRejected,
];

X1PlanWizardVm _plan(String p) => X1PlanWizardVm.fromJson(_rows(p).single);
X1RecoveryVm _rec(String p) => X1RecoveryVm.fromJson(_rows(p).single);

const String _ttu = 'TRUSTED_TIME_UNKNOWN';

/// 옛 폰 VM `reasonCode` 모집단(K268).
final Set<String> _planCodes = <String>{
  ...X1StartResultCodes.values,
  ...X1StepBlockCodes.values,
  ...X1JournalResultCodes.values,
  ...X1BootRefusalCodes.values,
  ...SafetyCommonResultCodes.values,
};

/// 새 폰 VM `reasonCode` 모집단(K271).
final Set<String> _recCodes = <String>{
  ...X1RecoveryResultCodes.values,
  ...X1RestoreResultCodes.values,
  ...BackupResultCodes.values,
  ...X1OrderSealCodes.values,
  ...X1FencingResultCodes.values,
  ...X1ReissueResultCodes.values,
  ...X1StartResultCodes.values,
  ...X1GateReasonCodes.values,
  ...SafetyCommonResultCodes.values,
};

/// 결과 `reasonCode` 합집합(K273 · `safety_actions.dart` 머리).
final Set<String> _resultCodes = <String>{
  ..._planCodes,
  ..._recCodes,
  SettingsResultCodes.biometricUnavailable,
};

final Set<String> _rowBlockCodes = <String>{
  ...X1StepBlockCodes.values,
  ...X1GapViolationCodes.values,
  ...X1GateReasonCodes.values,
};

bool _planNoActions(X1PlanWizardVm v) =>
    v.startAction == null &&
    v.rows.every((X1StepRow r) => r.actions.isEmpty) &&
    v.ticket?.ticketSlotId == null;

bool _recNoActions(X1RecoveryVm v) =>
    v.startAction == null &&
    v.recoveryCodeSlotId == null &&
    v.scanSlotId == null &&
    v.steps.every((X1StepRow r) => r.actions.isEmpty) &&
    v.reissue.every(
      (X1ReissueRow r) => r.recordAction == null && r.reissueSlotId == null,
    );

void main() {
  group('C-67 E16j-b X1 기기 이전 (01 §42)', () {
    test('C-67 ① 라우트 무변경 — 85 · X1 셋 등록 · 인자 0', () {
      expect(AppRoutes.all, hasLength(85));
      for (final String r in <String>[
        AppRoutes.x1Migration,
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
      ]) {
        expect(AppRoutes.all, contains(r));
        expect(r, isNot(contains('/:')), reason: '$r — X1 라우트 인자 0(K265)');
      }
    });

    test('C-67 ② 옛 폰 행 — 길이 ∈ {0, 9} · 차례 = X1StepCodes.ordered', () {
      for (final String p in _plans) {
        final X1PlanWizardVm v = _plan(p);
        expect(<int>{0, 9}, contains(v.rows.length), reason: p);
        if (v.rows.isNotEmpty) {
          expect(
            v.rows.map((X1StepRow r) => r.code).toList(),
            X1StepCodes.ordered,
            reason: p,
          );
        }
      }
      expect(_plan(FixturePaths.x1PlanWizardBlocked).rows, hasLength(9));
    });

    test('C-67 ③ 새 폰 행 — 길이 ∈ {0, 5} · 차례 = X1RecoveryStepCodes.ordered', () {
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        expect(<int>{0, 5}, contains(v.steps.length), reason: p);
        if (v.steps.isNotEmpty) {
          expect(
            v.steps.map((X1StepRow r) => r.code).toList(),
            X1RecoveryStepCodes.ordered,
            reason: p,
          );
        }
      }
    });

    test('C-67 ④ D-03 ⇔ 시작 동작(잠김 · 거부 제외) · 그때 행 0', () {
      for (final String p in _plans) {
        final X1PlanWizardVm v = _plan(p);
        if (v.lockedLabel != null || v.doneLabel != null) continue;
        expect(v.d03Card != null, v.startAction != null, reason: p);
        if (v.d03Card != null) {
          expect(v.rows, isEmpty, reason: p);
          expect(v.startAction!.id, SafetyActionId.x1PlanStart, reason: p);
          expect(v.startAction!.args, isEmpty, reason: p);
        }
      }
      expect(_plan(FixturePaths.x1PlanWizardD03).d03Card, isNotNull);
    });

    test('C-67 ⑤ 옛 폰 동작표 — 행 = x1PlanStep · x1PlanAbort{run_id, step = 행 코드} · 되돌리기 = DEMOTED 앞만', () {
      final int demoted = X1StepCodes.ordered.indexOf(X1StepCodes.demoted);
      for (final String p in _plans) {
        final X1PlanWizardVm v = _plan(p);
        for (int i = 0; i < v.rows.length; i++) {
          final X1StepRow r = v.rows[i];
          for (final SafetyActionCall c in r.actions) {
            expect(
              <SafetyActionId>{
                SafetyActionId.x1PlanStep,
                SafetyActionId.x1PlanAbort,
              },
              contains(c.id),
              reason: '$p ${r.code}',
            );
            expect(c.args.keys.toSet(), <String>{'run_id', 'step'}, reason: p);
            expect(c.args['step'], r.code, reason: '$p — step 인자 = 행 코드');
            if (c.id == SafetyActionId.x1PlanAbort) {
              expect(i < demoted, isTrue, reason: '$p ${r.code} — 강등 뒤 되돌리기 0');
            }
          }
        }
      }
    });

    test('C-67 ⑥ 새 폰 동작표 — 행 = x1RecoveryStep{run_id, step = 행 코드} · 시작 = x1EmergencyStart{}', () {
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        for (final X1StepRow r in v.steps) {
          for (final SafetyActionCall c in r.actions) {
            expect(c.id, SafetyActionId.x1RecoveryStep, reason: p);
            expect(c.args.keys.toSet(), <String>{'run_id', 'step'}, reason: p);
            expect(c.args['step'], r.code, reason: p);
          }
        }
        final SafetyActionCall? s = v.startAction;
        if (s != null) {
          expect(s.id, SafetyActionId.x1EmergencyStart, reason: p);
          expect(s.args, isEmpty, reason: '$p — 시크릿 = 슬롯 · args 0');
          expect(v.scanSlotId, isNull, reason: '$p — 비상 = 스캔 자리 0');
        }
      }
    });

    test('C-67 ⑦ 재발급 — 길이 ∈ {0, 6} · 차례 = ordered · 기록 = x1ReissueRecord{run_id, item = 행 코드} · 재발급 ⇒ 스캔 0', () {
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        expect(<int>{0, 6}, contains(v.reissue.length), reason: p);
        if (v.reissue.isEmpty) continue;
        expect(
          v.reissue.map((X1ReissueRow r) => r.code).toList(),
          X1ReissueItemCodes.ordered,
          reason: p,
        );
        expect(v.scanSlotId, isNull, reason: p);
        for (final X1ReissueRow r in v.reissue) {
          final SafetyActionCall? c = r.recordAction;
          if (c == null) continue;
          expect(c.id, SafetyActionId.x1ReissueRecord, reason: p);
          expect(c.args.keys.toSet(), <String>{'run_id', 'item'}, reason: p);
          expect(c.args['item'], r.code, reason: p);
        }
      }
      expect(
        _rec(FixturePaths.x1RecoveryEmergencyFencing).reissue,
        hasLength(6),
      );
    });

    test('C-67 ⑧ 슬롯 — 각 칸 = 제 슬롯 하나(표시 · 스캔 · 복구 코드 · 재발급)', () {
      for (final String p in _plans) {
        final String? t = _plan(p).ticket?.ticketSlotId;
        if (t != null) expect(t, X1SlotIds.ticketQrDisplay, reason: p);
      }
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        if (v.scanSlotId != null) {
          expect(v.scanSlotId, X1SlotIds.ticketQrScan, reason: p);
        }
        if (v.recoveryCodeSlotId != null) {
          expect(v.recoveryCodeSlotId, X1SlotIds.recoveryCode, reason: p);
        }
        for (final X1ReissueRow r in v.reissue) {
          if (r.reissueSlotId != null) {
            expect(r.reissueSlotId, X1SlotIds.reissueSecret, reason: p);
          }
        }
      }
    });

    test('C-67 ⑨ 코드 칸 ⊆ 사전 — VM · 행 · 카드', () {
      for (final String p in _plans) {
        final X1PlanWizardVm v = _plan(p);
        if (v.reasonCode != null) {
          expect(_planCodes, contains(v.reasonCode), reason: p);
        }
        for (final X1StepRow r in v.rows) {
          expect(X1StepCodes.values, contains(r.code), reason: p);
          if (r.blockCode != null) {
            expect(_rowBlockCodes, contains(r.blockCode), reason: p);
          }
        }
      }
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        if (v.reasonCode != null) {
          expect(_recCodes, contains(v.reasonCode), reason: p);
        }
        for (final X1StepRow r in v.steps) {
          expect(X1RecoveryStepCodes.values, contains(r.code), reason: p);
          if (r.blockCode != null) {
            expect(_rowBlockCodes, contains(r.blockCode), reason: p);
          }
        }
        final String? f = v.fencing?.code;
        if (f != null) {
          expect(
            <String>{...X1FencingResultCodes.values, _ttu},
            contains(f),
            reason: p,
          );
        }
        final String? rc = v.restore?.code;
        if (rc != null) {
          expect(
            <String>{
              ...X1RestoreResultCodes.values,
              ...BackupResultCodes.values,
            },
            contains(rc),
            reason: p,
          );
        }
        final X1GateCard? g = v.gate;
        if (g != null) {
          expect(X1GateStateCodes.values, contains(g.gateStateCode), reason: p);
          if (g.code != null) {
            expect(X1GateReasonCodes.values, contains(g.code), reason: p);
          }
        }
        for (final X1ReissueRow r in v.reissue) {
          expect(X1ReissueItemCodes.values, contains(r.code), reason: p);
        }
      }
    });

    test('C-67 ⑩ 잠김 · 끝 ⇒ 동작 · 슬롯 0', () {
      for (final String p in _plans) {
        final X1PlanWizardVm v = _plan(p);
        if (v.lockedLabel != null || v.doneLabel != null) {
          expect(_planNoActions(v), isTrue, reason: p);
        }
      }
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        if (v.lockedLabel != null || v.doneLabel != null) {
          expect(_recNoActions(v), isTrue, reason: p);
        }
      }
      expect(_plan(FixturePaths.x1PlanWizardLocked).lockedLabel, isNotNull);
    });

    test('C-67 ⑪ restartLink ⇔ X1_RECOVERY_FULL · 링크 = onboardingRestart · 그때 동작 0', () {
      for (final String p in _recoveries) {
        final X1RecoveryVm v = _rec(p);
        expect(
          v.restartLink != null,
          v.reasonCode == X1OrderSealCodes.full,
          reason: p,
        );
        if (v.restartLink != null) {
          expect(
            v.restartLink!.deepLink,
            AppRoutes.onboardingRestart,
            reason: p,
          );
          expect(_recNoActions(v), isTrue, reason: p);
        }
      }
    });

    test('C-67 ⑫ 결과 표본 — id 6 전부 · 코드 ⊆ 합집합 · 왕복', () {
      final Set<SafetyActionId> six = <SafetyActionId>{
        SafetyActionId.x1PlanStart,
        SafetyActionId.x1PlanStep,
        SafetyActionId.x1PlanAbort,
        SafetyActionId.x1EmergencyStart,
        SafetyActionId.x1ReissueRecord,
        SafetyActionId.x1RecoveryStep,
      };
      final Set<SafetyActionId> seen = <SafetyActionId>{};
      for (final Map<String, Object?> r in _rows(
        FixturePaths.x1X1ActionResults,
      )) {
        final SafetyActionResult a = SafetyActionResult.fromJson(r);
        expect(a.toJson(), r);
        expect(six, contains(a.id));
        seen.add(a.id);
        if (a.reasonCode != null) {
          expect(_resultCodes, contains(a.reasonCode), reason: a.actionRunId);
        }
      }
      expect(seen, six);
    });

    test('C-67 ⑬ 포트 경계 — ui_*(ui_safety 제외) 소스에 X1 VM · 창구 · 슬롯 사전 이름 0 · 받침대 = 에러', () {
      const List<String> symbols = <String>[
        'X1PlanWizardVm',
        'X1RecoveryVm',
        'X1StepRow',
        'X1TicketCard',
        'X1FencingCard',
        'X1ReissueRow',
        'X1RestoreCard',
        'X1GateCard',
        'MigrationRepository',
        'X1SlotIds',
      ];
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        if (name == 'ui_safety') continue;
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) continue;
        for (final File f in dartSourcesIn(lib)) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final String s in symbols) {
            if (RegExp('\\b$s\\b').hasMatch(code)) {
              offenders.add('${shortPath(f)}: $s');
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: '🔴 X1 이전 화면 = ui_safety 만(01 §42 K266)',
      );
      final UnimplementedMigrationRepository stub =
          UnimplementedMigrationRepository();
      expect(stub.watchPlanWizard, throwsUnimplementedError);
      expect(stub.watchPlanRecovery, throwsUnimplementedError);
      expect(stub.watchEmergencyRecovery, throwsUnimplementedError);
    });

    test('C-67 ⑭ 이름 ≠ 엔진 · 슬롯 사전 등재 · 와이어 6', () {
      final String lib = <String>[
        for (final File f in dartSourcesIn(libDir)) f.readAsStringSync(),
      ].join('\n');
      for (final String engine in <String>[
        'PlanStep',
        'RecoveryStep',
        'ReissueItem',
        'ReissueChecklist',
        'TransferTicket',
        'FencingVerdict',
        'RestoreVerdict',
        'MigrationGateVerdict',
        'MigrationStepRow',
        'PlanProgress',
        'RecoveryRun',
      ]) {
        expect(
          RegExp('(?:class|enum)\\s+$engine\\b').hasMatch(lib),
          isFalse,
          reason: '$engine — 계약 이름이 엔진 이름과 같다(K80)',
        );
      }
      expect(X1SlotIds.values, hasLength(4));
      expect(ContractCodes.byDomain['x1_slot'], X1SlotIds.values);
      for (final String s in <String>[
        X1SlotIds.recoveryCode,
        X1SlotIds.reissueSecret,
      ]) {
        expect(s, startsWith('SECRET_'), reason: '시크릿 자리 = SECRET_ 접두(K274)');
      }
      expect(
        <String>[
          SafetyActionId.x1PlanStart.wire,
          SafetyActionId.x1PlanStep.wire,
          SafetyActionId.x1PlanAbort.wire,
          SafetyActionId.x1EmergencyStart.wire,
          SafetyActionId.x1ReissueRecord.wire,
          SafetyActionId.x1RecoveryStep.wire,
        ],
        <String>[
          'X1_PLAN_START',
          'X1_PLAN_STEP',
          'X1_PLAN_ABORT',
          'X1_EMERGENCY_START',
          'X1_REISSUE_RECORD',
          'X1_RECOVERY_STEP',
        ],
      );
    });
  });
}
