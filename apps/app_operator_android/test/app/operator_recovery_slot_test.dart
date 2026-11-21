// E11k-e3 — O-04 ⑤ 슬롯 `RECOVERY_CHECKSUM` 조립(설계 13 §8 R229 · 06 M4-11 ①).
//
// 🔵 잡는 것: ① 첫 클레임 흐름이 있으면 체크섬 칸(실행 묶음의 캡처 막기 · 흐름의 확인 · 다시 시도) ② 없으면 자리 부재(크기 0).

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart'
    show operatorSlotBuilder;
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/safety/recovery_checksum_field.dart';
import 'package:core_engine/core_engine.dart' show FirstClaimOutcome;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show SupabaseAuth, SupabaseFirstClaim, SupabaseLeaseRpc;
import 'package:domain_contracts/domain_contracts.dart' show OnboardingSlotIds;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  setUp(() {
    clock = FakeClock(kst(2026, 12, 8, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  test(
    '🔴 흐름 있음 = 체크섬 칸(실행 묶음의 캡처 막기 · 흐름 확인 = 카드 없음) · 흐름 없음 = 자리 부재',
    () async {
      final http.Client net = MockClient(
        (http.Request q) async => http.Response('', 500),
      );
      final MemorySecretVault vault = MemorySecretVault(<String, String>{});
      final SupabaseFirstClaim claim = SupabaseFirstClaim(
        SupabaseLeaseRpc(net, vault, SupabaseAuth(net, vault, clock: clock)),
        files.sim,
        deviceId: '0f1e2d3c-4b5a-4978-8a6b-5c4d3e2f1a0b',
        clock: clock,
      );
      final OperatorRuntime rt = OperatorRuntime(
        files: files,
        clock: clock,
        firstClaim: claim,
      );
      final Widget w = operatorSlotBuilder(rt)(
        OnboardingSlotIds.recoveryChecksum,
      );
      expect(w, isA<RecoveryChecksumField>());
      final RecoveryChecksumField f = w as RecoveryChecksumField;
      expect(identical(f.secure, rt.secure), true);
      expect(f.pending(), isFalse);
      expect(await f.confirm('ABCD'), FirstClaimOutcome.noCard);
      expect(await f.retry(), FirstClaimOutcome.noCard);
      final Widget none = operatorSlotBuilder(
        OperatorRuntime(files: files, clock: clock),
      )(OnboardingSlotIds.recoveryChecksum);
      expect(none.key, const Key('m4-slot-absent'));
    },
  );
}
