// C-63 E16i 계약 창 — X1 기기 이전 · X5 정정의 엔진 글자 사전 — 01 §38
// (🆕 계약 v1.30 · 발주자 위임 2026-11-14 — 권고대로 · K209~K222).
//
// 정의: 「엔진(E16b~E16t3a)이 «계약 등재 = E16i 전 문자열»로 쓰는 거부 · 막음 · 단계 · 상태 글자 103 을 사전 25무리에
//        1:1 로 싣는다 − 공용 `TRUSTED_TIME_UNKNOWN`(K45) − `BackupResultCodes` 한 벌(K132) · 🔴 타입 이름 ≠ 엔진 ·
//        같은 글자 다른 축 = C-5 문서 중복 · 표시 hold `MIGRATION_IN_PROGRESS`」.
//   ① 엔진 글자 표 ② 도메인 등재 ③ 이름 ≠ 엔진 ④ 공용 빠짐 ⑤ 복원 한 벌 ⑥ 차례
//   ⑦ 겹침 여덟 ⑧ 경계 · 기동 거부 전집 ⑨ hold ⑩ 글자 꼴.
//
// 🔴 엔진 쪽 실시간 대조는 엔진 시험(core_engine · data_sync `test/migration/e16i_contract_parity_test.dart`)이 한다 —
//    계약 패키지는 엔진을 import 하지 못한다. 여기 표는 그 시점 글자의 고정(엔진 파일:줄 = `origin/main` `a36a6048`).

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// ① 엔진 글자 표 — 도메인 → (계약 values · 엔진 정본). 🔴 공용 · 한 벌 몫은 이미 뺀 글자.
const Map<String, List<String>> _engineTable = <String, List<String>>{
  // core migration/migration_plan.dart:112-127 MigrationStartCodes 5 − TRUSTED_TIME_UNKNOWN
  'x1_start_result': <String>[
    'X1_LIVE_ONLY',
    'X1_ADVISORY_PENDING',
    'D03_NOT_CONFIRMED',
    'EMERGENCY_NOT_DECLARED',
  ],
  // core migration_plan.dart:348-363 PlanBlockCodes 5
  'x1_step_block': <String>[
    'OPEN_ORDERS_REMAIN',
    'UNKNOWN_ORDERS_REMAIN',
    'RECON_NOT_ZERO',
    'BACKUP_MISSING',
    'BACKUP_CHAIN_MISMATCH',
  ],
  // ds migration/migration_journal_store.dart:22-31 MigrationStoreCodes 3
  'x1_journal_result': <String>[
    'X1_RUN_EXISTS',
    'X1_STEP_OUT_OF_ORDER',
    'X1_PAST_NO_RETURN',
  ],
  // ds migration/migration_lease_gate.dart:13-19 MigrationBootCodes 2
  'x1_boot_refusal': <String>['X1_DEMOTED', 'X1_JOURNAL_BROKEN'],
  // core migration/backup_manifest.dart:139 · 157 RestoreReason 2 + ds migration/ledger_restore.dart:23 LedgerRestoreCodes 1
  'x1_restore_result': <String>[
    'RESTORE_SHA_MISMATCH',
    'RESTORE_MANIFEST_MISMATCH',
    'X1_LIVE_EXISTS',
  ],
  // core migration/fencing.dart:44-53 FencingCodes 3 − TRUSTED_TIME_UNKNOWN
  'x1_fencing_result': <String>['FENCING_NOT_STARTED', 'FENCING_WAIT'],
  // core migration/reissue_checklist.dart:43-61 ReissueCodes 6 − TRUSTED_TIME_UNKNOWN
  'x1_reissue_result': <String>[
    'KEY_REUSED',
    'REISSUE_NOT_APPLICABLE',
    'REISSUE_DUPLICATE',
    'REISSUE_FINGERPRINT_REQUIRED',
    'REISSUE_FINGERPRINT_UNEXPECTED',
  ],
  // core reissue_checklist.dart:11-29 ReissueItem.wire 6(차례 = 06 X1-3)
  'x1_reissue_item': <String>[
    'KIS_APP_KEY',
    'MESSENGER_TOKEN',
    'WATCHDOG_PING_KEY',
    'GITHUB_PAT',
    'SUPABASE_SESSION',
    'GOOGLE_ACCESS',
  ],
  // ds migration/recovery_journal_store.dart:21-27 RecoveryCodes 2
  'x1_recovery_result': <String>['X1_NOT_RESTORED', 'X1_EPOCH_NOT_ADVANCED'],
  // core migration/gap_rebuild.dart:393-399 RecoverySealCodes 2
  'x1_order_seal': <String>['X1_RECOVERY_IN_PROGRESS', 'X1_RECOVERY_FULL'],
  // core migration/migration_gate.dart:62-86 MigrationGateCodes 8
  'x1_gate_reason': <String>[
    'X1_GOLDEN_NOT_RUN',
    'X1_GOLDEN_FAILED',
    'X1_RECON_NOT_ZERO',
    'X1_UNKNOWN_ORDERS_REMAIN',
    'X1_OPEN_ORDERS_REMAIN',
    'X1_OBSERVING',
    'X1_CHECKLIST_PENDING',
    'X1_BIOMETRIC_PENDING',
  ],
  // ds migration/maintenance_window_store.dart:19-25 WindowStoreCodes 2 − TRUSTED_TIME_UNKNOWN
  'maintenance_window_result': <String>['MW_ALREADY_OPEN'],
  // core gap_rebuild.dart:40 kX1RecoveredReason
  'x1_intent_reason': <String>['X1_RECOVERED'],
  // core migration_plan.dart:68-95 PlanStep.wire 9(차례 = 선언)
  'x1_plan_step': <String>[
    'FREEZE',
    'ORDERS_CLEARED',
    'RECON_ZERO',
    'BACKUP_CHECKSUM',
    'DEMOTED',
    'KEYS_DELETED',
    'RETIRED',
    'SERVICE_STOPPED',
    'TICKET_ISSUED',
  ],
  // core migration_plan.dart:45-54 MigrationStepState.wire 3
  'x1_step_state': <String>['ENTERED', 'DONE', 'FAILED'],
  // core migration_plan.dart:17-23 MigrationKind.wire 2
  'x1_kind': <String>['PLAN', 'EMERGENCY'],
  // core migration_plan.dart:31-37 MigrationRole.wire 2
  'x1_role': <String>['OLD_DEVICE', 'NEW_DEVICE'],
  // core migration/recovery_steps.dart:7-22 RecoveryStep.wire 5(차례 = 선언)
  'x1_recovery_step': <String>[
    'RESTORED',
    'GAP_REBUILT',
    'GOLDEN_SELF_TEST',
    'CHECKLIST_CONFIRMED',
    'BIOMETRIC_CONFIRMED',
  ],
  // core migration_gate.dart:42-54 MigrationGateState.wire 4
  'x1_gate_state': <String>[
    'BLOCKED',
    'OBSERVING',
    'AWAITING_APPROVAL',
    'PASSED',
  ],
  // core gap_rebuild.dart:275-284 GapViolationKind.wire 3
  'x1_gap_violation': <String>[
    'GAP_HOLDING_MISMATCH',
    'GAP_OVERSOLD',
    'GAP_UNMAPPED_STRATEGY',
  ],
  // core migration/maintenance_window.dart:15-27 WindowEvent.wire 4
  'maintenance_window_event': <String>[
    'OPENED',
    'OVERDUE',
    'CLOSED',
    'RESUME_FAILED',
  ],
  // core repair/repair_plan.dart:49-79 RepairCodes 10
  'repair_result': <String>[
    'REPAIR_DELTA_CHANGED',
    'REPAIR_TARGET_NOT_IMMUTABLE',
    'REPAIR_ORIGIN_NOT_ALLOWED',
    'REPAIR_DECISION_REQUIRED',
    'REPAIR_NO_CHANGE',
    'REPAIR_DIFF_NOT_OPEN',
    'REPAIR_FILL_NOT_BROKER',
    'REPAIR_ORDER_OPEN',
    'REPAIR_POSITION_DRIFT',
    'REPAIR_POSITION_NEGATIVE',
  ],
  // core repair/baseline_plan.dart:23-29 BaselineCodes 2
  'baseline_result': <String>[
    'BASELINE_NOT_X5',
    'BASELINE_FIRST_BAD_DATE_UNKNOWN',
  ],
  // core ops/ledger_boundary.dart:17-41 BoundaryReason.wire 8
  'ledger_boundary_reason': <String>[
    'DB_OPEN_FAILED',
    'SQLITE_INTEGRITY',
    'STAMP_CHAIN_BROKEN',
    'RESTORE_ROLLBACK',
    'ARCHIVE_DIVERGED',
    'CONTENT_MISMATCH',
    'FORMAT_VERSION',
    'CLEAN',
  ],
  // core ops/derived_sync.dart:210-231 DerivedRelation.wire 7
  'derived_relation': <String>[
    'IN_SYNC',
    'EMPTY',
    'BEHIND',
    'REBASED',
    'AHEAD',
    'DIVERGED',
    'EPOCH_AHEAD',
  ],
};

/// ② 계약 클래스(도메인 → values).
final Map<String, Set<String>> _contract = <String, Set<String>>{
  'x1_start_result': X1StartResultCodes.values,
  'x1_step_block': X1StepBlockCodes.values,
  'x1_journal_result': X1JournalResultCodes.values,
  'x1_boot_refusal': X1BootRefusalCodes.values,
  'x1_restore_result': X1RestoreResultCodes.values,
  'x1_fencing_result': X1FencingResultCodes.values,
  'x1_reissue_result': X1ReissueResultCodes.values,
  'x1_reissue_item': X1ReissueItemCodes.values,
  'x1_recovery_result': X1RecoveryResultCodes.values,
  'x1_order_seal': X1OrderSealCodes.values,
  'x1_gate_reason': X1GateReasonCodes.values,
  'maintenance_window_result': MaintenanceWindowResultCodes.values,
  'x1_intent_reason': X1IntentReasonCodes.values,
  'x1_plan_step': X1StepCodes.values,
  'x1_step_state': X1StepStateCodes.values,
  'x1_kind': X1KindCodes.values,
  'x1_role': X1RoleCodes.values,
  'x1_recovery_step': X1RecoveryStepCodes.values,
  'x1_gate_state': X1GateStateCodes.values,
  'x1_gap_violation': X1GapViolationCodes.values,
  'maintenance_window_event': MaintenanceWindowEventCodes.values,
  'repair_result': RepairResultCodes.values,
  'baseline_result': BaselineResultCodes.values,
  'ledger_boundary_reason': LedgerBoundaryReasonCodes.values,
  'derived_relation': DerivedRelationCodes.values,
};

/// ③ 계약 이름 25.
const List<String> _contractNames = <String>[
  'X1StartResultCodes',
  'X1StepBlockCodes',
  'X1JournalResultCodes',
  'X1BootRefusalCodes',
  'X1RestoreResultCodes',
  'X1FencingResultCodes',
  'X1ReissueResultCodes',
  'X1ReissueItemCodes',
  'X1RecoveryResultCodes',
  'X1OrderSealCodes',
  'X1GateReasonCodes',
  'MaintenanceWindowResultCodes',
  'X1IntentReasonCodes',
  'X1StepCodes',
  'X1StepStateCodes',
  'X1KindCodes',
  'X1RoleCodes',
  'X1RecoveryStepCodes',
  'X1GateStateCodes',
  'X1GapViolationCodes',
  'MaintenanceWindowEventCodes',
  'RepairResultCodes',
  'BaselineResultCodes',
  'LedgerBoundaryReasonCodes',
  'DerivedRelationCodes',
];

/// ③ 엔진 이름 26(core 21 · data_sync 5) — 계약 이름과 같으면 엔진 시험이 `ambiguous_import`(K80).
const List<String> _engineNames = <String>[
  'MigrationStartCodes',
  'PlanBlockCodes',
  'SnapshotCodes',
  'RestoreReason',
  'FencingCodes',
  'ReissueCodes',
  'ReissueItem',
  'RecoverySealCodes',
  'MigrationGateCodes',
  'PlanStep',
  'MigrationStepState',
  'MigrationKind',
  'MigrationRole',
  'RecoveryStep',
  'MigrationGateState',
  'GapViolationKind',
  'WindowEvent',
  'RepairCodes',
  'BaselineCodes',
  'BoundaryReason',
  'DerivedRelation',
  'MigrationStoreCodes',
  'MigrationBootCodes',
  'RecoveryCodes',
  'WindowStoreCodes',
  'LedgerRestoreCodes',
];

/// ⑦ 같은 글자 다른 축 여덟 — 글자 → 짝 도메인(K213 ⓒ).
const Map<String, Set<String>> _overlaps = <String, Set<String>>{
  'X1_LIVE_ONLY': <String>{'backup_result', 'x1_start_result'},
  'UNKNOWN_ORDERS_REMAIN': <String>{'resume_reason', 'x1_step_block'},
  'FAILED': <String>{'kill_cancel_outcome', 'x1_step_state'},
  'BLOCKED': <String>{'verdict_code', 'x1_gate_state'},
  'OBSERVING': <String>{'resume_reason', 'x1_gate_state'},
  'PASSED': <String>{'sim_trial_state', 'x1_gate_state'},
  'SQLITE_INTEGRITY': <String>{
    'ledger_integrity_result',
    'ledger_boundary_reason',
  },
  'FORMAT_VERSION': <String>{
    'ledger_integrity_result',
    'ledger_boundary_reason',
  },
  // 이미 문서 중복(v1.24) — 세 번째 축만 늘어난다.
  'RESTORE_ROLLBACK': <String>{
    'origin_code',
    'backup_result',
    'ledger_boundary_reason',
  },
};

/// ⑧ 경계 사유 가운데 X1 길 다섯(data_sync `migration/x1_startup.dart:39-41` → 기동 거부).
const Set<String> _boundaryX1 = <String>{
  'DB_OPEN_FAILED',
  'SQLITE_INTEGRITY',
  'STAMP_CHAIN_BROKEN',
  'RESTORE_ROLLBACK',
  'ARCHIVE_DIVERGED',
};

void main() {
  group('C-63 E16i X1 · X5 엔진 글자 사전 (01 §38)', () {
    test('C-63 ① 엔진 글자 표 — 25무리 103 = 계약 values', () {
      expect(_engineTable.keys.toSet(), _contract.keys.toSet());
      expect(_engineTable, hasLength(25));
      for (final MapEntry<String, List<String>> e in _engineTable.entries) {
        expect(
          _contract[e.key],
          e.value.toSet(),
          reason: '${e.key} — 엔진 글자와 다르다(엔진 파일:줄 = 표 주석)',
        );
        expect(e.value.toSet(), hasLength(e.value.length), reason: e.key);
      }
      final int total = _engineTable.values.fold<int>(
        0,
        (int n, List<String> v) => n + v.length,
      );
      expect(total, 103);
    });

    test('C-63 ② 도메인 25 등재 · 값 = 그 클래스 values', () {
      for (final MapEntry<String, Set<String>> e in _contract.entries) {
        expect(ContractCodes.hasDomain(e.key), isTrue, reason: e.key);
        expect(ContractCodes.byDomain[e.key], same(e.value), reason: e.key);
      }
    });

    test(
      'C-63 ③ 타입 이름 ≠ 엔진 — 계약 lib 에 엔진 이름 선언 0 · 저장소 다른 lib 에 계약 이름 선언 0',
      () {
        expect(
          _contractNames.toSet().intersection(_engineNames.toSet()),
          isEmpty,
        );
        final RegExp decl = RegExp(
          r'^\s*(?:abstract\s+)?(?:final\s+)?(?:class|enum)\s+(\w+)',
          multiLine: true,
        );
        final Set<String> contractDecls = <String>{
          for (final File f in dartSourcesIn(libDir))
            for (final RegExpMatch m in decl.allMatches(f.readAsStringSync()))
              m.group(1)!,
        };
        expect(contractDecls.intersection(_engineNames.toSet()), isEmpty);
        expect(contractDecls, containsAll(_contractNames));

        final List<String> clashes = <String>[];
        final List<Directory> others = <Directory>[
          for (final FileSystemEntity e in Directory(
            '${repoRoot.path}/packages',
          ).listSync())
            if (e is Directory && !e.path.endsWith('domain_contracts'))
              Directory('${e.path}/lib'),
          for (final FileSystemEntity e in Directory(
            '${repoRoot.path}/apps',
          ).listSync())
            if (e is Directory) Directory('${e.path}/lib'),
        ];
        for (final Directory d in others) {
          if (!d.existsSync()) continue;
          for (final File f in dartSourcesIn(d)) {
            for (final RegExpMatch m in decl.allMatches(f.readAsStringSync())) {
              if (_contractNames.contains(m.group(1))) {
                clashes.add('${shortPath(f)}: ${m.group(1)}');
              }
            }
          }
        }
        expect(clashes, isEmpty, reason: '계약 이름이 다른 패키지 선언과 겹친다');
      },
    );

    test('C-63 ④ 공용 TRUSTED_TIME_UNKNOWN = 한 벌(네 사전에 0)', () {
      for (final Set<String> v in <Set<String>>[
        X1StartResultCodes.values,
        X1FencingResultCodes.values,
        X1ReissueResultCodes.values,
        MaintenanceWindowResultCodes.values,
      ]) {
        expect(v, isNot(contains('TRUSTED_TIME_UNKNOWN')));
      }
      expect(
        SafetyCommonResultCodes.trustedTimeUnknown,
        'TRUSTED_TIME_UNKNOWN',
      );
      expect(ContractCodes.domainsOf('TRUSTED_TIME_UNKNOWN'), <String>{
        'safety_common_result',
      });
    });

    test('C-63 ⑤ 복원 판정 = BackupResultCodes 와 한 벌(서로소 · 합 = 엔진 전집)', () {
      expect(
        X1RestoreResultCodes.values.intersection(BackupResultCodes.values),
        isEmpty,
      );
      const Set<String> engineRestore = <String>{
        // core backup_manifest.dart:139-160 RestoreReason 7 + X1_LIVE_ONLY + ds X1_LIVE_EXISTS
        'RESTORE_SHA_MISMATCH',
        'RESTORE_UNREADABLE',
        'RESTORE_SCHEMA_SKEW',
        'RESTORE_SQLITE_INTEGRITY',
        'RESTORE_CHAIN_INVALID',
        'RESTORE_MANIFEST_MISMATCH',
        'RESTORE_ROLLBACK',
        'X1_LIVE_ONLY',
        'X1_LIVE_EXISTS',
      };
      expect(
        X1RestoreResultCodes.values.union(BackupResultCodes.values),
        containsAll(engineRestore),
      );
    });

    test('C-63 ⑥ 차례 — ordered = 엔진 선언 차례 · ordered 집합 = values', () {
      expect(X1StepCodes.ordered, _engineTable['x1_plan_step']);
      expect(X1RecoveryStepCodes.ordered, _engineTable['x1_recovery_step']);
      expect(X1ReissueItemCodes.ordered, _engineTable['x1_reissue_item']);
      expect(X1StepCodes.ordered.toSet(), X1StepCodes.values);
      expect(X1RecoveryStepCodes.ordered.toSet(), X1RecoveryStepCodes.values);
      expect(X1ReissueItemCodes.ordered.toSet(), X1ReissueItemCodes.values);
      // 🔴 되돌릴 수 없는 점 = 다섯째(DEMOTED) — 앞 넷만 실패를 적는다(R117 B4).
      expect(X1StepCodes.ordered.indexOf(X1StepCodes.demoted), 4);
    });

    test('C-63 ⑦ 같은 글자 다른 축 — 새 글자 가운데 다른 도메인에도 있는 것 = 정확히 표 그대로', () {
      final Set<String> newCodes = <String>{
        for (final Set<String> v in _contract.values) ...v,
      };
      final Map<String, Set<String>> found = <String, Set<String>>{
        for (final String c in newCodes)
          if (ContractCodes.domainsOf(c).length > 1)
            c: ContractCodes.domainsOf(c),
      };
      expect(found, _overlaps);
    });

    test('C-63 ⑧ 경계 X1 길 다섯 ⊂ 경계 사유 · CLEAN 포함 · 기동 거부 전집 = 서로소 합', () {
      expect(LedgerBoundaryReasonCodes.values, containsAll(_boundaryX1));
      expect(LedgerBoundaryReasonCodes.values, contains('CLEAN'));
      expect(X1BootRefusalCodes.values.intersection(_boundaryX1), isEmpty);
      expect(
        X1BootRefusalCodes.values.union(_boundaryX1),
        hasLength(X1BootRefusalCodes.values.length + _boundaryX1.length),
      );
    });

    test('C-63 ⑨ hold — SafetyHoldCodes 2 · MIGRATION_IN_PROGRESS', () {
      expect(SafetyHoldCodes.migrationInProgress, 'MIGRATION_IN_PROGRESS');
      expect(SafetyHoldCodes.values, <String>{
        'LIVE_AWAITING_KEYS',
        'MIGRATION_IN_PROGRESS',
      });
      expect(ContractCodes.byDomain['safety_hold'], SafetyHoldCodes.values);
    });

    test('C-63 ⑩ 글자 꼴 — 새 두 파일 상수 = 대문자 · 숫자 · _ 만(문구 · 수치 0)', () {
      final RegExp constRe = RegExp(r"static const String \w+ = '([^']*)';");
      final RegExp wire = RegExp(r'^[A-Z][A-Z0-9_]*$');
      int n = 0;
      for (final String name in <String>[
        'migration_codes.dart',
        'repair_codes.dart',
      ]) {
        final String src = stripComments(
          File('${libDir.path}/src/labels/$name').readAsStringSync(),
        );
        for (final RegExpMatch m in constRe.allMatches(src)) {
          n++;
          expect(m.group(1), matches(wire), reason: '$name ${m.group(0)}');
        }
      }
      // 🆕 v1.32(01 §41 · K259) — repair_codes.dart 에 `BaselineApplyResultCodes` 1 이 더해졌다(103 → 104 · C-66 ⑪).
      // 🆕 v1.33(01 §42 · K274) — migration_codes.dart 에 `X1SlotIds` 4 가 더해졌다(104 → 108 · C-67 ⑭).
      expect(n, 108);
    });
  });
}
