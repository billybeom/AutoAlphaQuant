// E11p3d-5d — M9 S02 키 목록 VM(모의 세트 카드 · 설계 13 §8 R129) · 표본 = domain_contracts v1.20 픽스처.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

CredentialCardVm _paperOf(String name) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/m9/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final CredentialListVm vm = CredentialListVm.fromJson(
    (env['rows']! as List<Object?>).first! as Map<String, Object?>,
  );
  return vm.cards.singleWhere(
    (CredentialCardVm c) => c.kind == CredentialKindCodes.kisPaper,
  );
}

// 표본 «08-31 08:42»(KST) = 2026-08-30 23:42Z.
final DateTime _at = DateTime.utc(2026, 8, 30, 23, 42);
final DateTime _now = DateTime.utc(2026, 8, 31);

CredentialCardVm _card(RunMode m, PaperCredentialFacts f) =>
    credentialListVmOf(runMode: m, paper: f, nowUtc: _now).cards.single;

void main() {
  test(
    '🔴 저장 · 통과(모의 모드) = 표본 `credentials_advisory` 의 모의 카드(만료 줄 = 원천 0 · 비교 밖)',
    () {
      expect(
        _card(
          RunMode.simInternal,
          PaperCredentialFacts(
            stored: true,
            lastState: StepState.verified,
            lastAtUtc: _at,
          ),
        ),
        _paperOf('credentials_advisory').copyWith(expiresText: null),
      );
    },
  );

  test('🔴 거절(실전 모드 = 선택) = 표본 `credentials` 의 모의 카드(칸 + «검증 후 저장»)', () {
    for (final bool stored in <bool>[true, false]) {
      expect(
        _card(
          RunMode.live,
          PaperCredentialFacts(
            stored: stored,
            lastState: StepState.failed,
            lastAtUtc: _at,
            lastFailureCode: 'CREDENTIAL_REJECTED',
          ),
        ),
        _paperOf('credentials').copyWith(expiresText: null),
        reason: 'stored=$stored',
      );
    }
  });

  test('🔴 미등록 = 칸 + «검증 후 저장» · 모의 모드 필수 = 할 일(ACT) · 실전 모드 선택 = 안내(INFO) · 마지막 검증 줄 없음', () {
    final CredentialCardVm sim = _card(
      RunMode.simInternal,
      const PaperCredentialFacts(stored: false),
    );
    expect(
      (sim.healthCode, sim.healthLabel, sim.level),
      ('NOT_REGISTERED', '미등록', UiLevel.act),
    );
    expect(sim.credentialSlotId, OnboardingSlotIds.secretKisMock);
    expect(sim.verifyAction?.label, '검증 후 저장');
    expect(sim.lastVerifiedText, isNull);
    expect(sim.requirementLabel, '필수');
    final CredentialCardVm live = _card(
      RunMode.live,
      const PaperCredentialFacts(stored: false),
    );
    expect((live.level, live.requirementLabel), (UiLevel.info, '선택'));
  });

  test('🔴 통과 기록이 있어도 금고에 키가 없으면 = 미등록(칸 + «검증 후 저장» · 금고가 정본)', () {
    final CredentialCardVm c = _card(
      RunMode.simInternal,
      PaperCredentialFacts(
        stored: false,
        lastState: StepState.verified,
        lastAtUtc: _at,
      ),
    );
    expect(c.healthCode, 'NOT_REGISTERED');
    expect(c.credentialSlotId, OnboardingSlotIds.secretKisMock);
    expect(c.verifyAction?.label, '검증 후 저장');
  });

  test('🔴 저장됐지만 검증 기록 없음 = 확인 필요(WATCH) · 칸 없음 · «다시 검증»(금고 키)', () {
    final CredentialCardVm c = _card(
      RunMode.simInternal,
      const PaperCredentialFacts(stored: true),
    );
    expect(
      (c.healthCode, c.healthLabel, c.level),
      ('UNKNOWN', '검증 기록 없음', UiLevel.watch),
    );
    expect(c.credentialSlotId, isNull);
    expect(c.verifyAction?.label, '다시 검증');
    expect(c.lastVerifiedText, isNull);
  });

  test('🔴 목록 = 모의 카드 하나(엔진에 있는 세트만) · 키 조각 · 회전 · 런북 · 잠김 · 모드 머리 = 없음 · 기준 글자 = KST', () {
    final CredentialListVm vm = credentialListVmOf(
      runMode: RunMode.simInternal,
      paper: const PaperCredentialFacts(stored: false),
      nowUtc: DateTime.utc(2026, 8, 31, 0, 0),
    );
    expect(vm.cards, hasLength(1));
    expect(vm.cards.single.rotateLink, isNull);
    expect(vm.cards.single.sealLabel, isNull);
    expect(vm.cards.single.expiresText, isNull);
    expect(
      (vm.modeNotice, vm.leakRunbookLink, vm.lockedLabel),
      (null, null, null),
    );
    expect(vm.asOf.label, '키 기준 2026-08-31 09:00');
    expect(vm.asOf.staleAfter, kCredentialListStaleAfter);
    expect(vm.asOf.source, AsOfSource.localSqlite);
  });
}
