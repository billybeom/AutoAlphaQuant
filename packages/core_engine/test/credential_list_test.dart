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

  group('🆕 R196 · K208 — 실전 세트 카드(실전 · ISA · 표본 차례)', () {
    CredentialCardVm cardOf(String name, String kind) {
      final Map<String, Object?> env = jsonDecode(
        File('../domain_contracts/fixtures/m9/$name.json').readAsStringSync(),
      ) as Map<String, Object?>;
      return CredentialListVm.fromJson(
        (env['rows']! as List<Object?>).first! as Map<String, Object?>,
      ).cards.singleWhere((CredentialCardVm c) => c.kind == kind);
    }

    // 표본 «08-31 08:40»(KST) = 2026-08-30 23:40Z.
    final DateTime at40 = DateTime.utc(2026, 8, 30, 23, 40);
    CredentialHealthRecord rec(String kind, String h) =>
        CredentialHealthRecord(kind: kind, health: h, lastVerifiedAtUtc: at40);
    CredentialListVm list(
      RunMode m,
      List<LiveCredentialFacts> live, {
      OperatingMode? op,
    }) => credentialListVmOf(
      runMode: m,
      paper: const PaperCredentialFacts(stored: false),
      nowUtc: _now,
      live: live,
      operatingMode: op,
    );
    LiveCredentialFacts ok(String kind) => LiveCredentialFacts(
      kind: kind,
      stored: true,
      record: rec(kind, CredentialHealthCodes.ok),
    );

    test('실전 모드 통과 = 표본 `credentials` 실전 카드(만료 = 원천 0 · 비교 밖) · 차례 = 실전 → ISA → 모의', () {
      final CredentialListVm vm = list(RunMode.live, <LiveCredentialFacts>[
        ok(CredentialKindCodes.kisLive),
        ok(CredentialKindCodes.kisIsa),
      ]);
      expect(
        vm.cards.first,
        cardOf(
          'credentials',
          CredentialKindCodes.kisLive,
        ).copyWith(expiresText: null),
      );
      expect(
        <String>[for (final CredentialCardVm c in vm.cards) c.kind],
        <String>[
          CredentialKindCodes.kisLive,
          CredentialKindCodes.kisIsa,
          CredentialKindCodes.kisPaper,
        ],
      );
      expect(vm.cards[1].kindLabel, 'ISA 중개형');
      expect(vm.cards[1].alias, 'kis_isa');
      expect(vm.modeNotice, isNull);
    });

    test(
      '🔴 SIM 통과 = 표본 `credentials_sim_sealed` 실전 카드(봉인 · 동작 0) · 머리 줄 = 표본 글자',
      () {
        final CredentialListVm vm = list(
          RunMode.simInternal,
          <LiveCredentialFacts>[ok(CredentialKindCodes.kisLive)],
        );
        expect(
          vm.cards.first,
          cardOf(
            'credentials_sim_sealed',
            CredentialKindCodes.kisLive,
          ).copyWith(expiresText: null),
        );
        final Map<String, Object?> env = jsonDecode(
          File('../domain_contracts/fixtures/m9/credentials_sim_sealed.json')
              .readAsStringSync(),
        ) as Map<String, Object?>;
        expect(
          vm.modeNotice,
          ((env['rows']! as List<Object?>).first!
              as Map<String, Object?>)['mode_notice'],
        );
      },
    );

    test(
      '안내 모드 미등록 = 표본 `credentials_advisory` 실전 카드(선택 · 한 줄 · 칸 + «검증 후 저장»)',
      () {
        final CredentialListVm vm = list(
          RunMode.live,
          const <LiveCredentialFacts>[
            LiveCredentialFacts(
              kind: CredentialKindCodes.kisLive,
              stored: false,
            ),
          ],
          op: OperatingMode.advisory,
        );
        expect(
          vm.cards.first,
          cardOf('credentials_advisory', CredentialKindCodes.kisLive),
        );
      },
    );

    test(
      '🔴 K208 — SIM 미등록 · 실패 = 봉인 그대로 + 칸 + «검증 후 저장»(조회만) · 기록 없음 = «다시 검증»',
      () {
        final CredentialListVm vm = list(
          RunMode.simInternal,
          <LiveCredentialFacts>[
            const LiveCredentialFacts(
              kind: CredentialKindCodes.kisLive,
              stored: false,
            ),
            LiveCredentialFacts(
              kind: CredentialKindCodes.kisIsa,
              stored: true,
              record: rec(
                CredentialKindCodes.kisIsa,
                CredentialHealthCodes.invalid,
              ),
            ),
          ],
        );
        final CredentialCardVm live = vm.cards[0];
        expect(
          (
            live.healthCode,
            live.level,
            live.sealLabel,
            live.requirementLabel,
            live.credentialSlotId,
          ),
          (
            'NOT_REGISTERED',
            UiLevel.info,
            LiveCredentialTexts.seal,
            LiveCredentialTexts.requiredOnSwitch,
            SettingsSlotIds.secretKisLive,
          ),
        );
        expect(
          (
            live.verifyAction?.id,
            live.verifyAction?.label,
            live.lastVerifiedText,
          ),
          (SettingsActionId.credentialVerify, '검증 후 저장', null),
        );
        expect(live.verifyAction?.args, <String, String>{
          'kind': CredentialKindCodes.kisLive,
        });
        final CredentialCardVm isa = vm.cards[1];
        expect(
          (
            isa.healthCode,
            isa.level,
            isa.credentialSlotId,
            isa.verifyAction?.label,
            isa.lastVerifiedText,
          ),
          (
            'INVALID',
            UiLevel.watch,
            SettingsSlotIds.secretKisIsa,
            '검증 후 저장',
            '마지막 검증 08-31 08:40 · 거절(CREDENTIAL_REJECTED)',
          ),
        );
        final CredentialCardVm unk = list(
          RunMode.simInternal,
          const <LiveCredentialFacts>[
            LiveCredentialFacts(
              kind: CredentialKindCodes.kisLive,
              stored: true,
            ),
          ],
        ).cards.first;
        expect(
          (
            unk.healthCode,
            unk.level,
            unk.credentialSlotId,
            unk.verifyAction?.label,
          ),
          ('UNKNOWN', UiLevel.info, null, '다시 검증'),
        );
      },
    );

    test('실전 모드 — 기록 없음 = WATCH «다시 검증» · 미등록 = ACT(필수) · 실패 = ACT · 통과 기록이 있어도 금고에 키가 없으면 미등록', () {
      String look(LiveCredentialFacts f) {
        final CredentialCardVm c = list(RunMode.live, <LiveCredentialFacts>[
          f,
        ]).cards.first;
        return '${c.healthCode}/${c.level.wire}/${c.credentialSlotId}/${c.verifyAction?.label}/${c.sealLabel}';
      }

      expect(
        look(
          const LiveCredentialFacts(
            kind: CredentialKindCodes.kisLive,
            stored: true,
          ),
        ),
        'UNKNOWN/WATCH/null/다시 검증/null',
      );
      expect(
        look(
          const LiveCredentialFacts(
            kind: CredentialKindCodes.kisLive,
            stored: false,
          ),
        ),
        'NOT_REGISTERED/ACT/SECRET_KIS_LIVE/검증 후 저장/null',
      );
      expect(
        look(
          LiveCredentialFacts(
            kind: CredentialKindCodes.kisLive,
            stored: false,
            record: rec(CredentialKindCodes.kisLive, CredentialHealthCodes.ok),
          ),
        ),
        'NOT_REGISTERED/ACT/SECRET_KIS_LIVE/검증 후 저장/null',
      );
      expect(
        look(
          LiveCredentialFacts(
            kind: CredentialKindCodes.kisLive,
            stored: true,
            record: rec(
              CredentialKindCodes.kisLive,
              CredentialHealthCodes.invalid,
            ),
          ),
        ),
        'INVALID/ACT/SECRET_KIS_LIVE/검증 후 저장/null',
      );
    });
  });
}
