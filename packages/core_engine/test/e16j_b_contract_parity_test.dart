// 🆕 계약 v1.33(01 §42 · E16j-b 계약 창 · K281) — core 엔진 X1 단계 · 재발급 열거 = 계약 행 차례.
//
// 🔴 두 배럴을 한 파일에서 import 한다 — 계약 새 이름(`X1PlanWizardVm` · `X1RecoveryVm` · `X1StepRow` · 카드 5 · `MigrationRepository` ·
//    `X1SlotIds`)이 엔진 이름(`PlanStep` · `RecoveryStep` · `ReissueItem` · `TransferTicket` · …)과 같으면 여기서 `ambiguous_import` 로 깨진다(K80).
// 🔴 엔진 lib 0줄 — VM 생산 · 단계 진행기 = 엔진 숙제(01 §8 미결 218). 행 수 {0,9} · {0,5} · {0,6}(C-67 ②③⑦)의 근거를 여기서 묶는다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('E16j-b 계약 대조 — core X1 열거 차례 = 계약 ordered', () {
    test('PlanStep 9 = X1StepCodes.ordered(옛 폰 행 차례)', () {
      expect(
        PlanStep.values.map((PlanStep s) => s.wire).toList(),
        X1StepCodes.ordered,
      );
    });

    test('RecoveryStep 5 = X1RecoveryStepCodes.ordered(새 폰 행 차례)', () {
      expect(
        RecoveryStep.values.map((RecoveryStep s) => s.wire).toList(),
        X1RecoveryStepCodes.ordered,
      );
    });

    test('ReissueItem 6 = X1ReissueItemCodes.ordered(재발급 행 차례)', () {
      expect(
        ReissueItem.values.map((ReissueItem i) => i.wire).toList(),
        X1ReissueItemCodes.ordered,
      );
    });

    test('새 계약 타입이 두 배럴에서 함께 보인다(이름 겹침 0)', () {
      expect(X1PlanWizardVm, isNotNull);
      expect(X1RecoveryVm, isNotNull);
      expect(X1StepRow, isNotNull);
      expect(MigrationRepository, isNotNull);
      expect(X1SlotIds.values, hasLength(4));
      expect(TransferTicket, isNotNull);
    });
  });
}
