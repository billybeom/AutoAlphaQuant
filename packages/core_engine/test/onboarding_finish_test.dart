// E11p4c — 온보딩 마무리(O-04) 6단계 VM(설계 13 §8 R127) · 표본 = domain_contracts v1.16 픽스처.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

List<Object?> _rows(String name) =>
    (jsonDecode(
          File('../domain_contracts/fixtures/m8/$name.json').readAsStringSync(),
        ) as Map<String, Object?>)['rows']!
        as List<Object?>;

OnboardingFinishVm _fx(String name) =>
    OnboardingFinishVm.fromJson(_rows(name).first! as Map<String, Object?>);

const String _hash = 'cfg_fake_0000000000000000';

/// 복구 카드 줄(⑤ — 원천 0 · 비교 밖)을 비운다.
OnboardingFinishVm _noCardLines(OnboardingFinishVm v) => v.copyWith(
  stages: <OnboardingFinishStage>[
    for (int i = 0; i < v.stages.length; i++)
      i == 4 ? v.stages[i].copyWith(lines: const <String>[]) : v.stages[i],
  ],
);

OnboardingFinishFacts _ready({
  OperatingMode mode = OperatingMode.autoTrade,
  bool declared = false,
  bool committed = false,
}) => OnboardingFinishFacts(
  mode: mode,
  committed: committed,
  pledged: true,
  openingDeclared: declared,
  configHash: _hash,
  biometricSigned: true,
  selftest: (12, 12),
  recoveryCardDone: true,
  advisoryOpeningAlias: '연금저축',
);

void main() {
  test('🔴 시작 전(자동) = 표본 `_auto` — ⑤ 만 원천 없음 = UNKNOWN(표본의 «이미 있음» N/A 는 계정 사실 · 원천 0)', () {
    final OnboardingFinishVm got = onboardingFinishVmOf(
      const OnboardingFinishFacts(
        mode: OperatingMode.autoTrade,
        committed: false,
        pledged: false,
        openingDeclared: false,
        configHash: _hash,
      ),
    );
    final OnboardingFinishVm want = _fx('onboarding_finish_auto');
    for (final int i in <int>[0, 1, 2, 3, 5]) {
      expect(got.stages[i], want.stages[i], reason: '단계 ${i + 1}');
    }
    expect(got.stages[4].gate?.state, GateState.unknown);
    expect(got.stages[4].gate?.code, 'RECOVERY_CARD');
    expect(got.stages[4].slotId, isNull);
    expect(got.headline, want.headline);
    expect(got.doneLabel, isNull);
    expect(got.checks, isEmpty);
  });

  test('🔴 ①~⑤ 끝 · 선언 전 = 표본 `_auto_ready`(⑥ 링크 = 가상 초기금) · 선언 뒤 = `_auto_declared`(⑥ 동작)', () {
    expect(
      _noCardLines(onboardingFinishVmOf(_ready())),
      _noCardLines(_fx('onboarding_finish_auto_ready')),
    );
    expect(
      _noCardLines(onboardingFinishVmOf(_ready(declared: true))),
      _noCardLines(_fx('onboarding_finish_auto_declared')),
    );
  });

  test('🔴 투자 안내 = 표본 `_advisory`(⑥ 링크 = 시작 선언 · 계좌) · `_advisory_declared` · 계좌 모름 = 게이트', () {
    expect(
      _noCardLines(onboardingFinishVmOf(_ready(mode: OperatingMode.advisory))),
      _noCardLines(_fx('onboarding_finish_advisory')),
    );
    expect(
      _noCardLines(
        onboardingFinishVmOf(
          _ready(mode: OperatingMode.advisory, declared: true),
        ),
      ),
      _noCardLines(_fx('onboarding_finish_advisory_declared')),
    );
    final OnboardingFinishVm noAlias = onboardingFinishVmOf(
      const OnboardingFinishFacts(
        mode: OperatingMode.advisory,
        committed: false,
        pledged: true,
        openingDeclared: false,
        biometricSigned: true,
        selftest: (1, 1),
        recoveryCardDone: true,
      ),
    );
    expect(noAlias.stages[5].link, isNull);
    expect(noAlias.stages[5].action, isNull);
    expect(noAlias.stages[5].gate?.state, GateState.unknown);
  });

  test('🔴 끝(committed) = 전 단계 VERIFIED · 링크 · 동작 · 슬롯 0 · 끝 문장 · 점검 다섯(표본 글자 · 상태 = 원천 전 시작 전)', () {
    final OnboardingFinishVm got = onboardingFinishVmOf(
      const OnboardingFinishFacts(
        mode: OperatingMode.autoTrade,
        committed: true,
        pledged: false,
        openingDeclared: true,
      ),
    );
    final OnboardingFinishVm want = _fx('onboarding_finish_done');
    expect(got.doneLabel, want.doneLabel);
    expect(
      got.checks.map((OnboardingFinishCheck c) => c.label),
      want.checks.map((OnboardingFinishCheck c) => c.label),
    );
    for (final OnboardingFinishStage s in got.stages) {
      expect(s.state, StepState.verified);
      expect((s.link, s.action, s.slotId, s.gate), (null, null, null, null));
    }
    expect(got.stages[5].lines, want.stages[5].lines);
  });

  group('🔴 K23 규칙', () {
    test('슬롯 = ②~⑤ 그 단계가 열려 있을 때만 · ② 끝 = ③ 슬롯(생체 사실 있음) · 원천 없음 = 슬롯 없음', () {
      OnboardingFinishVm vm({bool? bio, (int, int)? st, bool? card}) =>
          onboardingFinishVmOf(
            OnboardingFinishFacts(
              mode: OperatingMode.autoTrade,
              committed: false,
              pledged: true,
              openingDeclared: false,
              biometricSigned: bio,
              selftest: st,
              recoveryCardDone: card,
            ),
          );
      expect(vm().stages[1].slotId, isNull);
      expect(vm().stages[2].slotId, isNull);
      expect(vm().stages[2].gate?.state, GateState.unknown);
      expect(vm(bio: false).stages[2].slotId, OnboardingSlotIds.biometricSign);
      expect(vm(bio: false).stages[2].gate, isNull);
      // ③ 끝 · ④ 원천 있음 · 미통과 = 슬롯 셀프테스트.
      expect(
        vm(bio: true, st: (3, 12)).stages[3].slotId,
        OnboardingSlotIds.selftestRun,
      );
      expect(vm(bio: true, st: (3, 12)).stages[3].lines, <String>[
        '통과 3/전체 12',
      ]);
      // ④ 앞(③) 미완 = 막힘.
      expect(vm(bio: false, st: (3, 12)).stages[3].gate?.code, 'STAGE_ORDER');
      // ⑤ 원천 있음 · ④ 끝 = 슬롯 체크섬.
      expect(
        vm(bio: true, st: (12, 12), card: false).stages[4].slotId,
        OnboardingSlotIds.recoveryChecksum,
      );
      expect(
        vm(bio: true, st: (3, 12), card: false).stages[4].gate?.code,
        'STAGE_ORDER',
      );
      for (final OnboardingFinishStage s in <OnboardingFinishStage>[
        vm().stages[0],
        vm().stages[5],
      ]) {
        expect(s.slotId, isNull);
      }
    });

    test('기대치 줄 = ①만 · 링크 · 동작 = ⑥만 · 링크 ⇒ 동작 없음 · ①~⑤ 하나라도 미완 = ⑥ 막힘', () {
      final OnboardingFinishVm a = onboardingFinishVmOf(_ready());
      for (int i = 1; i < 6; i++) {
        expect(a.stages[i].expectationLine, isNull);
      }
      for (int i = 0; i < 5; i++) {
        expect((a.stages[i].link, a.stages[i].action), (null, null));
      }
      expect(a.stages[5].link, isNotNull);
      expect(a.stages[5].action, isNull);
      final OnboardingFinishVm notReady = onboardingFinishVmOf(
        const OnboardingFinishFacts(
          mode: OperatingMode.autoTrade,
          committed: false,
          pledged: true,
          openingDeclared: true,
          biometricSigned: true,
          selftest: (11, 12),
          recoveryCardDone: true,
        ),
      );
      expect(notReady.stages[5].action, isNull);
      expect(notReady.stages[5].gate?.code, 'STAGE_ORDER');
      expect(notReady.stages[3].state, StepState.notStarted);
    });

    test('⑤ 하나만 미완(선언 뒤여도) = ⑥ 막힘 · 동작 없음 · ③ 슬롯 = ② 끝 뒤에만', () {
      for (final bool? card in <bool?>[false, null]) {
        final OnboardingFinishVm v = onboardingFinishVmOf(
          OnboardingFinishFacts(
            mode: OperatingMode.autoTrade,
            committed: false,
            pledged: true,
            openingDeclared: true,
            biometricSigned: true,
            selftest: (12, 12),
            recoveryCardDone: card,
          ),
        );
        expect(v.stages[5].action, isNull, reason: '$card');
        expect(v.stages[5].gate?.code, 'STAGE_ORDER', reason: '$card');
      }
      final OnboardingFinishVm noPledge = onboardingFinishVmOf(
        const OnboardingFinishFacts(
          mode: OperatingMode.autoTrade,
          committed: false,
          pledged: false,
          openingDeclared: false,
          biometricSigned: false,
        ),
      );
      expect(noPledge.stages[2].slotId, isNull);
      expect(noPledge.stages[2].gate?.code, 'STAGE_ORDER');
    });

    test('설정 해시 = 있을 때만 줄 · 단계 = 6 차례 고정', () {
      final OnboardingFinishVm v = onboardingFinishVmOf(
        const OnboardingFinishFacts(
          mode: OperatingMode.autoTrade,
          committed: false,
          pledged: false,
          openingDeclared: false,
        ),
      );
      expect(v.stages, hasLength(6));
      expect(v.stages[0].lines, hasLength(2));
      expect(v.stages.map((OnboardingFinishStage s) => s.title), <String>[
        'P0S 프로파일 확인',
        '본인 서약문 3문장',
        '생체 서명',
        '골든벡터 셀프테스트',
        '복구 카드 발급',
        '모의 운영(DRY_RUN) 시작',
      ]);
    });
  });

  test('🔴 모의 운영 시작 결과 문장 = 표본 `_finish_results`', () {
    final List<ActionResult> r = <ActionResult>[
      for (final Object? x in _rows('onboarding_finish_results'))
        ActionResult.fromJson(x! as Map<String, Object?>),
    ];
    expect(r[0].headline, kOnboardingDryRunStartedText);
    expect(r[1].headline, kOnboardingDryRunRolledBackText);
    expect(r[1].reasonCode, OnboardingResultCodes.dryRunStartRolledBack);
  });

  group('🆕 R229 ⑤ 복구 카드(E11k-e3)', () {
    const String code = 'ABCD-EFGH-JKMN-PQRS-TUVW';
    OnboardingFinishFacts facts({
      bool? card = false,
      bool pending = false,
      List<String> lines = const <String>[],
      (int, int)? st = (12, 12),
      List<String> Function()? issue,
      bool committed = false,
    }) => OnboardingFinishFacts(
      mode: OperatingMode.autoTrade,
      committed: committed,
      pledged: true,
      openingDeclared: false,
      configHash: _hash,
      biometricSigned: true,
      selftest: st,
      recoveryCardDone: card,
      recoveryCardPending: pending,
      recoveryCardLines: lines,
      recoveryCardIssue: issue,
    );

    test('🔴 열림 = 그때 카드 줄을 부른다(발급) · 슬롯 · 시작 전 · 코드 = 그 줄에만', () {
      int calls = 0;
      List<String> issue() {
        calls++;
        return recoveryCardIssueLines(code);
      }

      final OnboardingFinishStage s5 = onboardingFinishVmOf(facts(issue: issue))
          .stages[4];
      expect(calls, 1);
      expect(s5.state, StepState.notStarted);
      expect(s5.slotId, OnboardingSlotIds.recoveryChecksum);
      expect(s5.gate, isNull);
      expect(s5.lines, recoveryCardIssueLines(code));
      expect(s5.lines.where((String l) => l.contains(code)), hasLength(1));
    });

    test('🔴 닫힘(④ 미완 · 원천 없음) = 카드 줄을 부르지 않는다(발급 0) · 줄 0 · 슬롯 0', () {
      int calls = 0;
      List<String> issue() {
        calls++;
        return recoveryCardIssueLines(code);
      }

      final OnboardingFinishStage order = onboardingFinishVmOf(
        facts(st: (3, 12), issue: issue),
      ).stages[4];
      expect(order.gate?.code, 'STAGE_ORDER');
      expect(order.lines, isEmpty);
      expect(order.slotId, isNull);
      final OnboardingFinishStage none = onboardingFinishVmOf(
        facts(card: null, issue: issue, lines: <String>['x']),
      ).stages[4];
      expect(none.gate?.state, GateState.unknown);
      expect(none.lines, isEmpty);
      expect(calls, 0);
    });

    test('🔴 대기(종이 확인 · 등록 남음) = 진행 중 · 슬롯 그대로 · 대기 줄 · 카드 줄 0', () {
      int calls = 0;
      final OnboardingFinishStage s5 = onboardingFinishVmOf(
        facts(
          pending: true,
          lines: <String>[RecoveryCardTexts.pendingLine],
          issue: () {
            calls++;
            return recoveryCardIssueLines(code);
          },
        ),
      ).stages[4];
      expect(s5.state, StepState.inProgress);
      expect(s5.slotId, OnboardingSlotIds.recoveryChecksum);
      expect(s5.lines, <String>[RecoveryCardTexts.pendingLine]);
      expect(calls, 0);
    });

    test('🔴 끝 = 확인됨 · 슬롯 0 · 코드 없는 줄 · ⑥ 열림', () {
      final OnboardingFinishVm vm = onboardingFinishVmOf(
        facts(
          card: true,
          lines: <String>[RecoveryCardTexts.doneLine],
          issue: () => throw StateError('끝난 단계에서 발급'),
        ),
      );
      final OnboardingFinishStage s5 = vm.stages[4];
      expect(s5.state, StepState.verified);
      expect(s5.slotId, isNull);
      expect(s5.lines, <String>[RecoveryCardTexts.doneLine]);
      expect(vm.stages[5].link, isNotNull);
    });

    test('글자 — 결과 8 전부 문장 · 카드 줄(새로 냄 = 머리 줄) · 종류 이름', () {
      for (final FirstClaimOutcome o in FirstClaimOutcome.values) {
        expect(firstClaimResultText(o), isNotEmpty, reason: o.name);
      }
      expect(
        firstClaimResultText(FirstClaimOutcome.claimed),
        RecoveryCardTexts.claimed,
      );
      expect(
        recoveryCardIssueLines(code, reissued: true).first,
        RecoveryCardTexts.reissuedLine,
      );
      expect(recoveryCardIssueLines(code).first, '복구 코드: $code');
      expect(kRecoveryCardKind, 'ONBOARDING_RECOVERY_CARD');
      expect(kRecoveryCardKind, isNot(kBiometricSignKind));
      for (final String t in <String>[
        RecoveryCardTexts.doneLine,
        RecoveryCardTexts.existingLine,
        RecoveryCardTexts.pendingLine,
      ]) {
        expect(t, isNot(contains(code)));
      }
    });
  });
}
