// E11p4b — 온보딩 첫 화면 · 운영 방식 선택 VM(설계 13 §8 R125) · 표본 = domain_contracts v1.16 픽스처.

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

Map<String, Object?> _row(String name) =>
    _rows(name).first! as Map<String, Object?>;

void main() {
  test('🔴 첫 화면 = 표본(재시작 · 조회 전용 둘 다 = `onboarding_start` · 둘 다 아님 = `_start_no_viewer`)', () {
    expect(
      onboardingStartVmOf(reconnectReady: true, viewerTrack: true),
      OnboardingStartVm.fromJson(_row('onboarding_start')),
    );
    expect(
      onboardingStartVmOf(reconnectReady: false, viewerTrack: false),
      OnboardingStartVm.fromJson(_row('onboarding_start_no_viewer')),
    );
  });

  test('🔴 운영 방식 = 표본(고르기 전 · 자동 · 안내 · 확정 잠김)', () {
    expect(
      onboardingModeChoiceVmOf(selected: null, committed: false),
      OnboardingModeChoiceVm.fromJson(_row('onboarding_mode_unselected')),
    );
    expect(
      onboardingModeChoiceVmOf(
        selected: OperatingMode.autoTrade,
        committed: false,
      ),
      OnboardingModeChoiceVm.fromJson(_row('onboarding_mode_auto')),
    );
    expect(
      onboardingModeChoiceVmOf(
        selected: OperatingMode.advisory,
        committed: false,
      ),
      OnboardingModeChoiceVm.fromJson(_row('onboarding_mode_advisory')),
    );
    expect(
      onboardingModeChoiceVmOf(
        selected: OperatingMode.advisory,
        committed: true,
      ),
      OnboardingModeChoiceVm.fromJson(_row('onboarding_mode_locked')),
    );
    expect(
      () => onboardingModeChoiceVmOf(selected: null, committed: true),
      throwsArgumentError,
    );
  });

  test('🔴 선택 결과 문장 = 표본 `_mode_select_results`', () {
    final List<ActionResult> r = <ActionResult>[
      for (final Object? x in _rows('onboarding_mode_select_results'))
        ActionResult.fromJson(x! as Map<String, Object?>),
    ];
    expect(r[0].headline, kOnboardingModeSelectedText);
    expect(r[1].headline, kOnboardingModeCommittedText);
    expect(r[1].reasonCode, OnboardingResultCodes.choiceCommitted);
  });
}
