// 🆕 계약 v1.30(01 §38 · E16i 계약 창 · K220) — data_sync X1 글자 = 계약 사전.
//
// 🔴 두 배럴을 한 파일에서 import 한다 — 계약 이름이 엔진 이름과 같으면 여기서 `ambiguous_import` 로 컴파일이 깨진다(K80 · K212).
// 🔴 엔진 lib 0줄 — 엔진 지역 선언 → 계약 참조 이관 = 엔진 숙제(01 §8 미결 212).

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _ttu = 'TRUSTED_TIME_UNKNOWN';

void main() {
  group('E16i 계약 대조 — data_sync 상수 무리 = 계약 사전', () {
    test('MigrationStoreCodes 3 = X1JournalResultCodes', () {
      expect(<String>{
        MigrationStoreCodes.runExists,
        MigrationStoreCodes.stepOutOfOrder,
        MigrationStoreCodes.pastNoReturn,
      }, X1JournalResultCodes.values);
    });

    test('MigrationBootCodes 2 = X1BootRefusalCodes', () {
      expect(<String>{
        MigrationBootCodes.demoted,
        MigrationBootCodes.journalBroken,
      }, X1BootRefusalCodes.values);
    });

    test('RecoveryCodes 2 = X1RecoveryResultCodes', () {
      expect(<String>{
        RecoveryCodes.notRestored,
        RecoveryCodes.epochNotAdvanced,
      }, X1RecoveryResultCodes.values);
    });

    test('WindowStoreCodes 2 = MaintenanceWindowResultCodes ∪ 공용', () {
      expect(
        <String>{
          WindowStoreCodes.alreadyOpen,
          WindowStoreCodes.trustedTimeUnknown,
        },
        <String>{...MaintenanceWindowResultCodes.values, _ttu},
      );
    });

    test('LedgerRestoreCodes 1 ⊂ X1RestoreResultCodes', () {
      expect(LedgerRestoreCodes.liveExists, X1RestoreResultCodes.liveExists);
      expect(
        X1RestoreResultCodes.values,
        contains(LedgerRestoreCodes.liveExists),
      );
    });
  });
}
