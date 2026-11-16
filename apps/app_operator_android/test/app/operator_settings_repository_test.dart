// E11p3d-5d 설정 읽기 모델 operator 판 — M9 S02 키 목록(설계 13 §8 R129) — 메모리 금고 · 실 SQLite(sim) · 실제 시간(갱신 훅).

import 'dart:async';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisEnvironment, KisKeySet, storeKisCredentials;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart' show SqliteOnboardingProgressStore;
import 'package:domain_contracts/domain_contracts.dart'
    show
        CredentialCardVm,
        CredentialListVm,
        OnboardingResultCodes,
        OnboardingSlotIds,
        OperatingMode,
        StepState,
        UiLevel;
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late MemorySecretVault vault;
  late OperatorRuntime rt;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
    vault = MemorySecretVault();
    rt = OperatorRuntime(files: files, clock: clock, vault: vault);
  });
  tearDown(() => files.close());

  Future<void> until(bool Function() ok) async {
    final Stopwatch w = Stopwatch()..start();
    while (!ok() && w.elapsed < const Duration(seconds: 5)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  SqliteOnboardingProgressStore progress() =>
      SqliteOnboardingProgressStore(files.sim, clock: clock);

  CredentialCardVm card(CredentialListVm v) => v.cards.single;

  test('🔴 금고 비었음 · 기록 없음 = 미등록(모의 = 필수 · 할 일) · 칸 + «검증 후 저장»', () async {
    final CredentialCardVm c = card(
      await OperatorSettingsRepository(rt).credentials(),
    );
    expect(
      (c.healthCode, c.level, c.requirementLabel),
      ('NOT_REGISTERED', UiLevel.act, '필수'),
    );
    expect(c.credentialSlotId, OnboardingSlotIds.secretKisMock);
    expect(c.verifyAction?.label, '검증 후 저장');
  });

  test('🔴 금고 저장 + o_02 통과 = 정상 · 칸 없음 · «다시 검증» · 마지막 검증 줄(KST)', () async {
    await storeKisCredentials(
      vault,
      KisKeySet.paper,
      KisCredentials(
        environment: KisEnvironment.mock,
        appKey: 'PSTESTAPPKEY0000000000001',
        appSecret: 'TESTSECRETVALUEabcdefghijklmnop9876',
        accountNo: '12345678',
      ),
    );
    progress().record('o_02', StepState.verified);
    final CredentialCardVm c = card(
      await OperatorSettingsRepository(rt).credentials(),
    );
    expect((c.healthCode, c.healthLabel, c.level), ('OK', '정상', UiLevel.ok));
    expect(c.credentialSlotId, isNull);
    expect(c.verifyAction?.label, '다시 검증');
    expect(c.lastVerifiedText, '마지막 검증 12-01 09:00 · 통과');
  });

  test('🔴 거절 기록 → 다시 낸다(진척 표 · 실제 갱신 훅) · 금고 없는 조립 = 저장 안 됨으로 본다', () async {
    final List<CredentialListVm> got = <CredentialListVm>[];
    final StreamSubscription<CredentialListVm> sub = OperatorSettingsRepository(
      rt,
    ).watchCredentials().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(card(got.last).healthCode, 'NOT_REGISTERED');
    progress().record(
      'o_02',
      StepState.failed,
      failureReasonCode: OnboardingResultCodes.credentialRejected,
    );
    await until(() => card(got.last).healthCode == 'INVALID');
    expect(
      card(got.last).lastVerifiedText,
      '마지막 검증 12-01 09:00 · 거절(CREDENTIAL_REJECTED)',
    );
    final CredentialCardVm noVault = card(
      await OperatorSettingsRepository(
        OperatorRuntime(files: files, clock: clock),
      ).credentials(),
    );
    expect(noVault.healthCode, 'INVALID');
  });

  test('🔴 실행 모드 = 화면 상태(없음 = 모의) · 화면 상태가 바뀌면 다시 낸다', () async {
    expect(
      card(await OperatorSettingsRepository(rt).credentials()).requirementLabel,
      '필수',
    );
    final List<CredentialListVm> got = <CredentialListVm>[];
    final StreamSubscription<CredentialListVm> sub = OperatorSettingsRepository(
      rt,
    ).watchCredentials().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    final int n = got.length;
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    clock.now = clock.now.add(const Duration(minutes: 1));
    rt.view.value = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    );
    await until(() => got.length > n);
    expect(got.length, greaterThan(n));
  });

  test('🔴 나머지 창구 = 원천 없음(오류)', () async {
    final OperatorSettingsRepository r = OperatorSettingsRepository(rt);
    await expectLater(r.watchHome(), emitsError(isA<UnsupportedError>()));
    await expectLater(r.watchOperations(), emitsError(isA<UnsupportedError>()));
    await expectLater(
      r.watchAccountMapping(),
      emitsError(isA<UnsupportedError>()),
    );
  });
}
