// 🆕 계약 v1.32(01 §41 · E16j-a 계약 창 · K257 · K263) — data_sync 새 기준점 저장 거부 글자 = 계약 사전.
//
// 🔴 두 배럴을 한 파일에서 import 한다 — 계약 이름(`BaselineApplyResultCodes` · `RepairWizardVm` · 제출 DTO 3)이
//    엔진 이름(`BaselineStoreCodes` · `BaselineResult` · …)과 같으면 여기서 `ambiguous_import` 로 컴파일이 깨진다(K80).
// 🔴 엔진 lib 0줄 — 엔진 지역 선언 → 계약 참조 이관 · VM 생산자 = 엔진 숙제(01 §8 미결 217).

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('E16j-a 계약 대조 — data_sync 새 기준점 저장 거부 = 계약 사전', () {
    test('BaselineStoreCodes 2 = BaselineApplyResultCodes ∪ 공용 신뢰 시각', () {
      expect(
        <String>{
          BaselineStoreCodes.trustedTimeUnknown,
          BaselineStoreCodes.flagNotSet,
        },
        <String>{
          ...BaselineApplyResultCodes.values,
          SafetyCommonResultCodes.trustedTimeUnknown,
        },
      );
      expect(
        BaselineStoreCodes.flagNotSet,
        BaselineApplyResultCodes.flagNotSet,
      );
    });

    test('새 계약 타입이 두 배럴에서 함께 보인다(이름 겹침 0)', () {
      expect(RepairWizardVm, isNotNull);
      expect(RepairCorrectSubmission, isNotNull);
      expect(RepairBaselineSubmission, isNotNull);
      expect(InterventionJournalSubmission, isNotNull);
      expect(BaselineResult, isNotNull);
    });
  });
}
