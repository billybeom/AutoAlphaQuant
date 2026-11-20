// 🆕 계약 v1.30(01 §38 · E16i 계약 창 · K220) — core 엔진 X1 · X5 글자 = 계약 사전.
//
// 🔴 두 배럴을 한 파일에서 import 한다 — 계약 이름이 엔진 이름과 같으면 여기서 `ambiguous_import` 로 컴파일이 깨진다(K80 · K212).
// 🔴 엔진 lib 0줄 — 엔진 지역 선언 → 계약 참조 이관 = 엔진 숙제(01 §8 미결 212). 그 전까지 이 시험이 글자를 묶는다.
// 공용 `TRUSTED_TIME_UNKNOWN` = 계약 `SafetyCommonResultCodes` 한 벌(K45) · 복원 판정 take 몫 = `BackupResultCodes`(K132).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _ttu = 'TRUSTED_TIME_UNKNOWN';

void main() {
  group('E16i 계약 대조 — core 열거 wire = 계약 사전', () {
    test('PlanStep 9 = X1StepCodes.ordered(차례까지)', () {
      expect(<String>[
        for (final PlanStep s in PlanStep.values) s.wire,
      ], X1StepCodes.ordered);
    });

    test('MigrationStepState · MigrationKind · MigrationRole', () {
      expect(<String>{
        for (final MigrationStepState s in MigrationStepState.values) s.wire,
      }, X1StepStateCodes.values);
      expect(<String>{
        for (final MigrationKind k in MigrationKind.values) k.wire,
      }, X1KindCodes.values);
      expect(<String>{
        for (final MigrationRole r in MigrationRole.values) r.wire,
      }, X1RoleCodes.values);
    });

    test('RecoveryStep 5 = X1RecoveryStepCodes.ordered · ReissueItem 6 = X1ReissueItemCodes.ordered', () {
      expect(<String>[
        for (final RecoveryStep s in RecoveryStep.values) s.wire,
      ], X1RecoveryStepCodes.ordered);
      expect(<String>[
        for (final ReissueItem i in ReissueItem.values) i.wire,
      ], X1ReissueItemCodes.ordered);
    });

    test('MigrationGateState · GapViolationKind · WindowEvent · BoundaryReason · DerivedRelation', () {
      expect(<String>{
        for (final MigrationGateState s in MigrationGateState.values) s.wire,
      }, X1GateStateCodes.values);
      expect(<String>{
        for (final GapViolationKind k in GapViolationKind.values) k.wire,
      }, X1GapViolationCodes.values);
      expect(<String>{
        for (final WindowEvent e in WindowEvent.values) e.wire,
      }, MaintenanceWindowEventCodes.values);
      expect(<String>{
        for (final BoundaryReason r in BoundaryReason.values) r.wire,
      }, LedgerBoundaryReasonCodes.values);
      expect(<String>{
        for (final DerivedRelation r in DerivedRelation.values) r.wire,
      }, DerivedRelationCodes.values);
    });
  });

  group('E16i 계약 대조 — core 상수 무리 = 계약 사전(− 공용 · 한 벌)', () {
    test('MigrationStartCodes 5 = X1StartResultCodes 4 ∪ 공용', () {
      expect(
        <String>{
          MigrationStartCodes.liveOnly,
          MigrationStartCodes.advisoryPending,
          MigrationStartCodes.d03NotConfirmed,
          MigrationStartCodes.emergencyNotDeclared,
          MigrationStartCodes.trustedTimeUnknown,
        },
        <String>{...X1StartResultCodes.values, _ttu},
      );
      expect(SafetyCommonResultCodes.trustedTimeUnknown, _ttu);
    });

    test('PlanBlockCodes 5 = X1StepBlockCodes', () {
      expect(<String>{
        PlanBlockCodes.openOrders,
        PlanBlockCodes.unknownOrders,
        PlanBlockCodes.reconNotZero,
        PlanBlockCodes.backupMissing,
        PlanBlockCodes.backupChainMismatch,
      }, X1StepBlockCodes.values);
    });

    test('FencingCodes 3 · ReissueCodes 6 = 계약 ∪ 공용', () {
      expect(
        <String>{
          FencingCodes.notStarted,
          FencingCodes.trustedTimeUnknown,
          FencingCodes.waiting,
        },
        <String>{...X1FencingResultCodes.values, _ttu},
      );
      expect(
        <String>{
          ReissueCodes.keyReused,
          ReissueCodes.notApplicable,
          ReissueCodes.duplicate,
          ReissueCodes.fingerprintRequired,
          ReissueCodes.fingerprintUnexpected,
          ReissueCodes.trustedTimeUnknown,
        },
        <String>{...X1ReissueResultCodes.values, _ttu},
      );
    });

    test('RecoverySealCodes · MigrationGateCodes · kX1RecoveredReason', () {
      expect(<String>{
        RecoverySealCodes.inProgress,
        RecoverySealCodes.full,
      }, X1OrderSealCodes.values);
      expect(<String>{
        MigrationGateCodes.goldenNotRun,
        MigrationGateCodes.goldenFailed,
        MigrationGateCodes.reconNotZero,
        MigrationGateCodes.unknownOrders,
        MigrationGateCodes.openOrders,
        MigrationGateCodes.observing,
        MigrationGateCodes.checklistPending,
        MigrationGateCodes.biometricPending,
      }, X1GateReasonCodes.values);
      expect(<String>{kX1RecoveredReason}, X1IntentReasonCodes.values);
    });

    test('RestoreReason 7 + SnapshotCodes 2 + X1_LIVE_ONLY = BackupResultCodes ∪ X1RestoreResultCodes − X1_LIVE_EXISTS', () {
      final Set<String> engine = <String>{
        for (final RestoreReason r in RestoreReason.values) r.wire,
        SnapshotCodes.noStamp,
        SnapshotCodes.exists,
        MigrationStartCodes.liveOnly,
      };
      expect(
        engine,
        <String>{
          ...BackupResultCodes.values,
          ...X1RestoreResultCodes.values,
        }.difference(<String>{X1RestoreResultCodes.liveExists}),
      );
      expect(
        BackupResultCodes.values.intersection(X1RestoreResultCodes.values),
        isEmpty,
      );
    });

    test('RepairCodes 10 · BaselineCodes 2', () {
      expect(<String>{
        RepairCodes.deltaChanged,
        RepairCodes.targetNotImmutable,
        RepairCodes.originNotAllowed,
        RepairCodes.decisionRequired,
        RepairCodes.noChange,
        RepairCodes.diffNotOpen,
        RepairCodes.fillNotBroker,
        RepairCodes.orderOpen,
        RepairCodes.positionDrift,
        RepairCodes.positionNegative,
      }, RepairResultCodes.values);
      expect(<String>{
        BaselineCodes.notX5,
        BaselineCodes.firstBadDateUnknown,
      }, BaselineResultCodes.values);
    });
  });
}
