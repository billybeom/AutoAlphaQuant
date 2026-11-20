// E11p4a — 온보딩 단계 목록 · 상세 VM 짓기(설계 13 §8 R122) · 표본 = domain_contracts v1.16 픽스처.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, Object?> _row(String name) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/m8/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (env['rows']! as List<Object?>).first! as Map<String, Object?>;
}

OnboardingStepsVm _steps(String name) => OnboardingStepsVm.fromJson(_row(name));

/// 픽스처 행 → 사실(게이트 UNKNOWN = 원천 없음).
Map<String, OnboardingStepFact> _factsOf(OnboardingStepsVm vm) =>
    <String, OnboardingStepFact>{
      for (final OnboardingStep s in vm.rows)
        s.stepId: s.gate?.state == GateState.unknown
            ? const OnboardingStepFact.unknown()
            : OnboardingStepFact(
                state: s.state,
                verifiedUntil: s.verifiedUntil,
                failureReasonCode: s.failureReasonCode,
              ),
    };

final DateTime _now = DateTime.utc(2026, 11, 15, 1);

void main() {
  test(
    '🔴 자동 매매 = 표본 `_steps_fresh` 그대로(글자 · 차례 · 필수도 · 경고 · 기한 · 실패 · 게이트 · 링크)',
    () {
      final OnboardingStepsVm want = _steps('onboarding_steps_fresh');
      final OnboardingStepsVm got = onboardingStepsVmOf(
        mode: OperatingMode.autoTrade,
        facts: _factsOf(want),
        nowUtc: _now,
      );
      // 🔵 o_02 의 «열렸습니다» 게이트는 표본의 예시다 — 기기 원장(o_01)의 원천이 없어 앞 단계 조건을 두지 않는다(R122 O4).
      final OnboardingStepsVm adj = want.copyWith(
        rows: <OnboardingStep>[
          for (final OnboardingStep s in want.rows)
            s.stepId == 'o_02' ? s.copyWith(gate: null) : s,
        ],
      );
      expect(got.rows.length, adj.rows.length);
      for (int i = 0; i < got.rows.length; i++) {
        expect(got.rows[i], adj.rows[i], reason: adj.rows[i].stepId);
      }
      expect(got, adj);
    },
  );

  test('🔴 투자 안내 = 표본 `_steps_advisory`(o_12 넷째 · 권장 · o_06 · o_13 없음 · 제목 · 이유 바뀜)', () {
    final OnboardingStepsVm want = _steps('onboarding_steps_advisory');
    final OnboardingStepsVm got = onboardingStepsVmOf(
      mode: OperatingMode.advisory,
      facts: _factsOf(want),
      nowUtc: _now,
    );
    // 🔵 표본은 o_03 게이트를 비워 두었다 — 앞 단계(모의 앱키)가 끝나기 전 = 막힘(R122 O4 · `_steps_fresh` 와 같은 규칙).
    final List<OnboardingStep> adj = <OnboardingStep>[
      for (final OnboardingStep s in want.rows)
        s.stepId == 'o_03'
            ? s.copyWith(
                gate: const GateBadge(
                  code: 'STEP_ORDER',
                  label: '앞 단계(모의 앱키)가 끝나야 열립니다',
                  state: GateState.block,
                ),
              )
            : s,
    ];
    expect(got.rows, adj);
    expect(got.progressText, want.progressText);
    expect(got.finishDeepLink, isNull);
  });

  test('🔴 고르기 전 = 표본 `_steps_empty`(행 0 · 빈 문장)', () {
    expect(
      onboardingStepsVmOf(mode: null, facts: const {}, nowUtc: _now),
      _steps('onboarding_steps_empty'),
    );
  });

  group('🔴 마무리 링크(K17)', () {
    Map<String, OnboardingStepFact> all(StepState s) =>
        <String, OnboardingStepFact>{
          for (final String id in onboardingStepIds)
            id: OnboardingStepFact(state: s),
        };

    test('필수 전부 VERIFIED ∧ 게이트 열림 = 링크 · 권장 남음 = 그래도 링크(경고만)', () {
      final Map<String, OnboardingStepFact> f = all(StepState.verified)
        ..['o_05'] = const OnboardingStepFact(state: StepState.notStarted);
      final OnboardingStepsVm vm = onboardingStepsVmOf(
        mode: OperatingMode.autoTrade,
        facts: f,
        nowUtc: _now,
      );
      expect(vm.finishDeepLink, AppRoutes.onboardingFinish);
      expect(
        vm.rows
            .singleWhere((OnboardingStep s) => s.stepId == 'o_05')
            .warningLabel,
        kOnboardingRecommendedWarning,
      );
      expect(vm.progressText, '11/12 완료');
      // 권장이라도 VERIFIED = 경고 없음.
      expect(
        vm.rows
            .singleWhere((OnboardingStep s) => s.stepId == 'o_06')
            .warningLabel,
        isNull,
      );
    });

    test('권장 단계는 원천이 없어도 게이트를 달지 않는다(투자 안내 o_11 = 권장)', () {
      final OnboardingStepsVm vm = onboardingStepsVmOf(
        mode: OperatingMode.advisory,
        facts: const <String, OnboardingStepFact>{},
        nowUtc: _now,
      );
      final OnboardingStep o11 = vm.rows.singleWhere(
        (OnboardingStep s) => s.stepId == 'o_11',
      );
      expect(o11.requirement, StepRequirement.recommended);
      expect(o11.gate, isNull);
      // 같은 단계가 자동 매매(필수)면 원천 없음 = UNKNOWN.
      expect(
        onboardingStepsVmOf(
              mode: OperatingMode.autoTrade,
              facts: const <String, OnboardingStepFact>{},
              nowUtc: _now,
            ).rows
            .singleWhere((OnboardingStep s) => s.stepId == 'o_11')
            .gate
            ?.state,
        GateState.unknown,
      );
    });

    test('필수 하나 원천 없음 = 게이트 UNKNOWN · 링크 없음 · 권장 · 선택 원천 없음 = 게이트 없음', () {
      final Map<String, OnboardingStepFact> f = all(StepState.verified)
        ..['o_07'] = const OnboardingStepFact.unknown()
        ..['o_05'] = const OnboardingStepFact.unknown()
        ..['o_13'] = const OnboardingStepFact.unknown();
      final OnboardingStepsVm vm = onboardingStepsVmOf(
        mode: OperatingMode.autoTrade,
        facts: f,
        nowUtc: _now,
      );
      OnboardingStep row(String id) =>
          vm.rows.singleWhere((OnboardingStep s) => s.stepId == id);
      expect(row('o_07').gate?.state, GateState.unknown);
      expect(row('o_07').state, StepState.notStarted);
      expect(row('o_05').gate, isNull);
      expect(row('o_13').gate, isNull);
      expect(vm.finishDeepLink, isNull);
    });

    test('필수 하나 진행 중(게이트 없음) = 링크 없음 — 게이트가 아니라 필수 완료가 막는다', () {
      final Map<String, OnboardingStepFact> f = all(StepState.verified)
        ..['o_09'] = const OnboardingStepFact(state: StepState.inProgress);
      final OnboardingStepsVm vm = onboardingStepsVmOf(
        mode: OperatingMode.autoTrade,
        facts: f,
        nowUtc: _now,
      );
      expect(
        vm.rows.singleWhere((OnboardingStep s) => s.stepId == 'o_09').gate,
        isNull,
      );
      expect(vm.finishDeepLink, isNull);
    });

    test('필수 하나 VERIFIED 아님 = 링크 없음 · 앞 단계 막힘은 원천 없음보다 먼저', () {
      final Map<String, OnboardingStepFact> f = all(StepState.verified)
        ..['o_02'] = const OnboardingStepFact(state: StepState.failed)
        ..['o_03'] = const OnboardingStepFact.unknown();
      final OnboardingStepsVm vm = onboardingStepsVmOf(
        mode: OperatingMode.autoTrade,
        facts: f,
        nowUtc: _now,
      );
      final OnboardingStep o3 = vm.rows.singleWhere(
        (OnboardingStep s) => s.stepId == 'o_03',
      );
      expect(o3.gate?.code, 'STEP_ORDER');
      expect(o3.gate?.state, GateState.block);
      expect(vm.finishDeepLink, isNull);
    });
  });

  test('🔴 기한 글자 = KST 날짜 · 지났거나 EXPIRED = «에 만료됨» · 남음 = «까지»', () {
    OnboardingStep o1(OnboardingStepFact f) => onboardingStepsVmOf(
      mode: OperatingMode.autoTrade,
      facts: <String, OnboardingStepFact>{'o_01': f},
      nowUtc: _now,
    ).rows.first;
    // 2026-11-29T15:00Z = KST 11-30 00:00.
    expect(
      o1(
        OnboardingStepFact(
          state: StepState.verified,
          verifiedUntil: DateTime.utc(2026, 11, 29, 15),
        ),
      ).verifiedUntilText,
      '2026-11-30까지',
    );
    expect(
      o1(
        OnboardingStepFact(
          state: StepState.verified,
          verifiedUntil: DateTime.utc(2026, 11, 14),
        ),
      ).verifiedUntilText,
      '2026-11-14에 만료됨',
    );
    expect(
      o1(
        OnboardingStepFact(
          state: StepState.expired,
          verifiedUntil: DateTime.utc(2026, 12, 1),
        ),
      ).verifiedUntilText,
      '2026-12-01에 만료됨',
    );
    expect(
      o1(const OnboardingStepFact(state: StepState.verified)).verifiedUntilText,
      isNull,
    );
  });

  test('🔴 실패 = 문장 필수 — 사전에 없는 코드 · 코드 없는 FAILED = 되돌림 문장', () {
    OnboardingStep o5(OnboardingStepFact f) => onboardingStepsVmOf(
      mode: OperatingMode.autoTrade,
      facts: <String, OnboardingStepFact>{'o_05': f},
      nowUtc: _now,
    ).rows.singleWhere((OnboardingStep s) => s.stepId == 'o_05');
    expect(
      o5(
        const OnboardingStepFact(
          state: StepState.failed,
          failureReasonCode: 'SOMETHING_NEW',
        ),
      ).failureText,
      kOnboardingFailureFallback,
    );
    expect(
      o5(const OnboardingStepFact(state: StepState.failed)).failureText,
      kOnboardingFailureFallback,
    );
    expect(
      o5(const OnboardingStepFact(state: StepState.verified)).failureText,
      isNull,
    );
  });

  group('🔴 단계 상세(K18)', () {
    final Map<String, OnboardingStepFact> facts = _factsOf(
      _steps('onboarding_steps_fresh'),
    );
    OnboardingStepDetailVm detail(String id) => onboardingStepDetailVmOf(
      stepId: id,
      mode: OperatingMode.autoTrade,
      facts: facts,
      nowUtc: _now,
    );

    test(
      'o_02 = 표본 `_step_detail_kis_mock` 의 글자 · 검증 동작 · 슬롯 · 단계 = 목록과 같은 객체',
      () {
        final OnboardingStepDetailVm want = OnboardingStepDetailVm.fromJson(
          _row('onboarding_step_detail_kis_mock'),
        );
        final OnboardingStepDetailVm got = detail('o_02');
        expect(got.whereText, want.whereText);
        expect(got.howText, want.howText);
        expect(got.verify, want.verify);
        expect(got.secretSlotId, want.secretSlotId);
        expect(got.missingLabel, isNull);
        expect(
          got.step,
          onboardingStepsVmOf(
            mode: OperatingMode.autoTrade,
            facts: facts,
            nowUtc: _now,
          ).rows.singleWhere((OnboardingStep s) => s.stepId == 'o_02'),
        );
      },
    );

    test('🆕 E11k-c(R206) o_07 진행 중 = 표본 `_step_detail_supabase` 의 글자 · 연결 확인 동작 · 슬롯 · 진행 중 확인 글자', () {
      final OnboardingStepDetailVm want = OnboardingStepDetailVm.fromJson(
        _row('onboarding_step_detail_supabase'),
      );
      final OnboardingStepDetailVm got = onboardingStepDetailVmOf(
        stepId: 'o_07',
        mode: OperatingMode.autoTrade,
        facts: <String, OnboardingStepFact>{
          ...facts,
          'o_07': const OnboardingStepFact(state: StepState.inProgress),
        },
        nowUtc: _now,
      );
      expect(got.whereText, want.whereText);
      expect(got.howText, want.howText);
      expect(got.verify, want.verify);
      expect(got.secretSlotId, want.secretSlotId);
      expect(got.secretSlotId, OnboardingSlotIds.supabaseConnect);
      expect(got.step!.state, StepState.inProgress);
      expect(got.step!.verificationLabel, want.step!.verificationLabel);
      expect(got.step!.title, want.step!.title);
      expect(got.step!.whyLine, want.step!.whyLine);
    });

    test(
      '🆕 R206 o_07 확인 글자 = 진행 중만 · 시작 전 = 없음 · 그 밖 상태 = 카탈로그 기본(아직 없음)',
      () {
        String? label(StepState? st) =>
            onboardingStepsVmOf(
                  mode: OperatingMode.autoTrade,
                  facts: <String, OnboardingStepFact>{
                    'o_07': st == null
                        ? const OnboardingStepFact.unknown()
                        : OnboardingStepFact(state: st),
                  },
                  nowUtc: _now,
                ).rows
                .singleWhere((OnboardingStep s) => s.stepId == 'o_07')
                .verificationLabel;
        expect(label(StepState.inProgress), '서버 시각 확인됨 — 로그인과 SQL 단계가 남았습니다');
        expect(label(StepState.notStarted), isNull);
        expect(label(null), isNull);
        expect(label(StepState.verified), isNull);
        expect(label(StepState.failed), isNull);
        // 다른 단계의 진행 중 = 그 단계의 기본 확인 글자 그대로(o_02).
        expect(
          onboardingStepsVmOf(
                mode: OperatingMode.autoTrade,
                facts: const <String, OnboardingStepFact>{
                  'o_02': OnboardingStepFact(state: StepState.inProgress),
                },
                nowUtc: _now,
              ).rows
              .singleWhere((OnboardingStep s) => s.stepId == 'o_02')
              .verificationLabel,
          '토큰 발급 + 모의 잔고 조회 1회',
        );
      },
    );

    test('o_06 = 표본 `_step_detail_no_verify`(글자 · 동작 0 · 슬롯 0)', () {
      final OnboardingStepDetailVm want = OnboardingStepDetailVm.fromJson(
        _row('onboarding_step_detail_no_verify'),
      );
      final OnboardingStepDetailVm got = detail('o_06');
      expect(
        (got.whereText, got.howText, got.verify, got.secretSlotId),
        (want.whereText, want.howText, null, null),
      );
    });

    test(
      '모르는 id · 상세 없는 단계(o_13) · 그 방식에 없는 단계 = 표본 `_step_detail_missing`',
      () {
        final OnboardingStepDetailVm missing = OnboardingStepDetailVm.fromJson(
          _row('onboarding_step_detail_missing'),
        );
        expect(detail('o_99'), missing);
        expect(detail('o_13'), missing);
        expect(
          onboardingStepDetailVmOf(
            stepId: 'o_06',
            mode: OperatingMode.advisory,
            facts: facts,
            nowUtc: _now,
          ),
          missing,
        );
        expect(
          onboardingStepDetailVmOf(
            stepId: 'o_02',
            mode: null,
            facts: facts,
            nowUtc: _now,
          ),
          missing,
        );
      },
    );

    test('막힌 단계 = 검증 동작 · 슬롯 없음(앞 단계가 먼저)', () {
      final OnboardingStepDetailVm d = detail('o_03');
      expect(d.step?.gate?.state, GateState.block);
      expect(d.verify, isNull);
      expect(d.secretSlotId, isNull);
    });
  });

  test('🔴 카탈로그 = id 꼴 · 겹침 0 · o_00 · o_04 없음 · 차례 1..n · 상세 링크 = 그 id', () {
    final RegExp shape = RegExp(r'^[orv]_[0-9]{2}[a-z]?$');
    expect(onboardingStepIds.toSet().length, onboardingStepIds.length);
    for (final String id in onboardingStepIds) {
      expect(shape.hasMatch(id), true, reason: id);
    }
    expect(onboardingStepIds, isNot(contains('o_00')));
    expect(onboardingStepIds, isNot(contains('o_04')));
    for (final OperatingMode m in OperatingMode.values) {
      final OnboardingStepsVm vm = onboardingStepsVmOf(
        mode: m,
        facts: const {},
        nowUtc: _now,
      );
      expect(
        vm.rows.map((OnboardingStep s) => s.order),
        List<int>.generate(vm.rows.length, (int i) => i + 1),
      );
      for (final OnboardingStep s in vm.rows) {
        if (s.detailDeepLink != null) {
          expect(s.detailDeepLink, 'aaq://onboarding/${s.stepId}');
        }
        expect(<String>{'필수', '권장', '선택'}, contains(s.requirementLabel));
        expect(s.title.contains('해외'), false);
      }
    }
  });
}
