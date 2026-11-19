// E11q-b1b — M5-2 재개 게이트 VM · 문항 읽기 · 결과(설계 13 §8 R179).
//
// 🔴 표본 `m5/kill_resume_gate_*` 8 꼴과 문항 행 · 수준 · 게이지 · 받을 문항 · 막힘이 같다(관측 시각 제외) ·
//    결과 = 표본 `safety_action_results` KILL_SWITCH_RESUME 행 글자 그대로(생체 제외).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

KillResumeGateVm _fx(String f) => KillResumeGateVm.fromJson(
  ((jsonDecode(File('../domain_contracts/fixtures/m5/$f').readAsStringSync())
                  as Map<String, Object?>)['rows']!
              as List<Object?>)
          .first!
      as Map<String, Object?>,
);

// 표본 시각: 기록 확인 11-16 14:00 KST · 해제 가능 예정 11-18 14:00 · 대기 = 남은 17시간.
final DateTime _activated = DateTime.utc(2026, 11, 16, 4, 40);
final DateTime _confirmed = DateTime.utc(2026, 11, 16, 5);
final DateTime _waitingNow = DateTime.utc(2026, 11, 17, 12);
final DateTime _readyNow = DateTime.utc(2026, 11, 18, 6);

const KillActivationReplay _replay = KillActivationReplay(
  ruleAction: '신규 진입을 멈추고 규칙 W3 를 다시 읽는다',
  reasonKind: KillReasonKind.emotion,
  emotion: '불안',
  intensity: 7,
  sleepHours: 4,
  scenario: 'W3',
  resumeCondition: '급락 뉴스가 정리되고 체결 오류가 0 이다',
  scope: KillScope.newEntriesOnly,
);

ResumeChecklist _accept(List<ResumeItemAnswer> answers) {
  ResumeChecklist c = ResumeChecklist.empty;
  for (final ResumeItemAnswer a in answers) {
    final (ResumeChecklist? n, String? code) = c.accept(a);
    expect(code, isNull, reason: 'item ${a.itemNo}');
    c = n!;
  }
  return c;
}

const List<ResumeItemAnswer> _three = <ResumeItemAnswer>[
  ResumeItemAnswer(1, text: '신규 진입 차단 유지 · 월말 계획대로'),
  ResumeItemAnswer(2, emotion: '담담', intensity: 2, sleepHours: 7),
  ResumeItemAnswer(3, scenario: ScenarioStatus.resolved),
];

KillResumeGateVm _vm({
  KillSwitchRecord record = const KillSwitchRecord(),
  DateTime? trusted,
  ResumeChecklist checklist = ResumeChecklist.empty,
  String? locked,
}) => killResumeGateVmOf(
  record: record,
  trustedNowUtc: trusted,
  nowUtc: _readyNow,
  replay: record.checklistConfirmedAtUtc == null ? null : _replay,
  checklist: checklist,
  lockedLabel: locked,
);

void _same(KillResumeGateVm got, KillResumeGateVm fx) {
  expect(got.readinessLabel, fx.readinessLabel);
  expect(got.level, fx.level);
  expect(got.etaText, fx.etaText);
  expect(got.nextItemNo, fx.nextItemNo);
  expect(got.blockedText, fx.blockedText);
  expect(got.lockedLabel, fx.lockedLabel);
  expect(got.items, fx.items);
  if (fx.cooldown == null) {
    expect(got.cooldown, isNull);
  } else {
    expect(got.cooldown!.code, fx.cooldown!.code);
    expect(got.cooldown!.label, fx.cooldown!.label);
    expect(got.cooldown!.valueText, fx.cooldown!.valueText);
    expect(got.cooldown!.normalized, closeTo(fx.cooldown!.normalized, 1e-9));
  }
}

void main() {
  final KillSwitchRecord on = KillSwitchRecord(activatedAtUtc: _activated);
  final KillSwitchRecord recorded = KillSwitchRecord(
    activatedAtUtc: _activated,
    checklistConfirmedAtUtc: _confirmed,
  );

  test('표본 8 꼴 — 꺼짐 · 확인 전 · 시각 모름 · 대기 · 준비 · 진행 · 4번 미충족 · 잠김', () {
    _same(_vm(), _fx('kill_resume_gate_off.json'));
    _same(
      _vm(record: on, trusted: _readyNow),
      _fx('kill_resume_gate_not_confirmed.json'),
    );
    _same(_vm(record: recorded), _fx('kill_resume_gate_time_unknown.json'));
    _same(
      _vm(record: recorded, trusted: _waitingNow),
      _fx('kill_resume_gate_waiting.json'),
    );
    _same(
      _vm(record: recorded, trusted: _readyNow),
      _fx('kill_resume_gate_ready.json'),
    );
    _same(
      _vm(record: recorded, trusted: _readyNow, checklist: _accept(_three)),
      _fx('kill_resume_gate_in_progress.json'),
    );
    _same(
      _vm(
        record: recorded,
        trusted: _readyNow,
        checklist: _accept(<ResumeItemAnswer>[
          ..._three,
          const ResumeItemAnswer(4, condition: ResumeConditionStatus.unmet),
        ]),
      ),
      _fx('kill_resume_gate_condition_unmet.json'),
    );
    final KillResumeGateVm fx = _fx('kill_resume_gate_locked.json');
    _same(
      _vm(record: recorded, trusted: _readyNow, locked: fx.lockedLabel),
      fx,
    );
  });

  test('규칙 갈래 2번 재생 · 해당 없음 시나리오 · 전량 청산 범위 · 5 · 6번 답', () {
    final KillResumeGateVm vm = killResumeGateVmOf(
      record: recorded,
      trustedNowUtc: _readyNow,
      nowUtc: _readyNow,
      replay: const KillActivationReplay(
        ruleAction: 'A',
        reasonKind: KillReasonKind.rule,
        resumeCondition: 'B',
        scope: KillScope.liquidateAll,
      ),
      checklist: _accept(<ResumeItemAnswer>[
        ..._three,
        const ResumeItemAnswer(4, condition: ResumeConditionStatus.met),
        const ResumeItemAnswer(5, acknowledged: true),
      ]),
    );
    expect(vm.items[1].replayText, '그때: 규칙이라고 적었다');
    expect(vm.items[2].replayText, '그때 짚은 시나리오: 해당 없음');
    expect(vm.items[4].replayText, '그때 고른 범위: 전량 청산');
    expect(vm.items[3].answeredText, '충족');
    expect(vm.items[3].level, UiLevel.ok);
    expect(vm.items[4].answeredText, '확인했다');
    expect(vm.nextItemNo, 6);
  });

  test('제출 원문 → 엔진 답 — 숫자 아님 = 빈칸 · 7번만 저널 id', () {
    final ResumeItemAnswer a = killResumeItemAnswerOf(
      const KillResumeItemSubmission(
        itemNo: 2,
        emotion: '담담',
        intensity: '2',
        sleepHours: '7.5',
      ),
      journalDecisionId: 'J',
    );
    expect((a.intensity, a.sleepHours, a.decisionId), (2, 7.5, null));
    expect(
      killResumeItemAnswerOf(
        const KillResumeItemSubmission(
          itemNo: 2,
          emotion: 'x',
          intensity: '많이',
        ),
      ).intensity,
      isNull,
    );
    final ResumeItemAnswer seven = killResumeItemAnswerOf(
      const KillResumeItemSubmission(
        itemNo: 7,
        rationaleBefore: 'r',
        expectedOutcome: 'e',
        ruleCited: 'c',
      ),
      journalDecisionId: 'KS-RES-1',
    );
    expect(seven.decisionId, 'KS-RES-1');
    expect(
      killResumeItemAnswerOf(
        const KillResumeItemSubmission(
          itemNo: 3,
          scenario: KillResumeScenario.ongoing,
        ),
      ).scenario,
      ScenarioStatus.ongoing,
    );
    expect(
      killResumeItemAnswerOf(
        const KillResumeItemSubmission(
          itemNo: 4,
          condition: KillResumeCondition.unmet,
        ),
      ).condition,
      ResumeConditionStatus.unmet,
    );
  });

  test(
    '결과 = 표본 safety_action_results(KILL_SWITCH_RESUME · 생체 제외) 글자 · 수준 그대로',
    () {
      final List<Object?> rows =
          (jsonDecode(
                File(
                  '../domain_contracts/fixtures/m5/safety_action_results.json',
                ).readAsStringSync(),
              ) as Map<String, Object?>)['rows']!
              as List<Object?>;
      int n = 0;
      for (final Object? o in rows) {
        final SafetyActionResult fx = SafetyActionResult.fromJson(
          o! as Map<String, Object?>,
        );
        if (fx.id != SafetyActionId.killSwitchResume) continue;
        if (fx.reasonCode == 'BIOMETRIC_UNAVAILABLE') continue;
        final SafetyActionResult got = killResumeResultOf(
          actionRunId: fx.actionRunId,
          code: fx.reasonCode,
          done: fx.level == UiLevel.ok,
          acceptedItemNo: 3,
          submittedItemNo: 2,
          nextItemNo: 4,
          etaUtc: DateTime.utc(2026, 11, 18, 5),
        );
        expect(got.headline, fx.headline, reason: '${fx.reasonCode}');
        expect(got.level, fx.level, reason: '${fx.reasonCode}');
        expect(got.id, SafetyActionId.killSwitchResume);
        n++;
      }
      expect(n, 8);
      expect(
        () => killResumeResultOf(actionRunId: 'x', code: 'NOPE'),
        throwsArgumentError,
      );
      for (int i = 1; i <= 7; i++) {
        expect(
          killResumeResultOf(
            actionRunId: 'x',
            code: 'RESUME_ITEM_MISSING',
            submittedItemNo: i,
          ).headline,
          startsWith('$i번'),
        );
      }
    },
  );
}
