// E11q-b1b — M5-2 재개 게이트 조립(설계 13 §8 R179) — 실 SQLite(sim 원장) · 발동 → 기록 → 48h → 7문항 → 해제.
//
// 🔴 준비 판정 = 엔진 차례(꺼짐 · 확인 전 · 시각 모름 · 대기) · 순차 = 엔진 `accept` · 1번 제출 = 초안 비움 ·
//    4번 미충족 = 막힘 → 다시 열면 1번부터 · 7번 = 엔진 `resume()`(해제 · 재개 저널) · 게이트 읽기 = 같은 초안.

import 'dart:async';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_kill_switch.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show KillResumeGateTexts, TrustedClock;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);

  DateTime? at;

  @override
  DateTime? trustedNowUtc() => at;
}

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

const KillChecklistSubmission _record = KillChecklistSubmission(
  ruleAction: '규칙대로 신규 진입을 멈춘다',
  reasonKind: KillActivationReason.emotion,
  emotion: '불안',
  intensity: '7',
  sleepHours: '4',
  scenarioId: 'W3',
  resumeCondition: '체결 오류 0',
  scope: KillActivationScope.newEntriesOnly,
  openOrdersQueried: true,
  openOrdersCancelled: true,
  remainingCountZero: true,
  note: '한 줄',
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 23, 10, 2));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(null);
  });
  tearDown(() => files.close());

  OperatorRuntime rt() {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
      trusted: trusted,
    );
    r.view.value = OperatorView(
      db: files.sim,
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_test',
      ),
    );
    return r;
  }

  test('🆕 R179 발동 → 기록 → 대기(TOO_SOON) → 순차 7문항(차례 · 빈칸 · 1번 = 처음부터) → 해제 · 게이트 = 같은 초안', () async {
    final OperatorRuntime r = rt();
    final OperatorKillResumeDraft draft = OperatorKillResumeDraft();
    addTearDown(draft.dispose);
    final OperatorSafetyActions acts = OperatorSafetyActions(r, draft: draft);
    final OperatorKillSwitchGateRepository repo =
        OperatorKillSwitchGateRepository(
          r,
          hasBody: kOperatorRouteBodies.byPattern.containsKey,
          draft: draft,
          tick: const Duration(hours: 1),
        );
    Future<SafetyActionResult> put(KillResumeItemSubmission s) =>
        acts.runKillResumeItem(s);
    // 꺼짐.
    expect(
      (await put(const KillResumeItemSubmission(itemNo: 1, text: 'x')))
          .reasonCode,
      'KILL_SWITCH_NOT_ACTIVE',
    );
    final OperatorCommandApi api = OperatorCommandApi(r);
    await api.activateKillSwitch();
    expect(
      (await put(const KillResumeItemSubmission(itemNo: 1, text: 'x')))
          .reasonCode,
      'RESUME_CHECKLIST_NOT_CONFIRMED',
    );
    trusted.at = clock.nowUtc().add(const Duration(minutes: 18));
    expect(
      (await api.confirmKillChecklist(_record)).state,
      CommandState.executed,
    );
    trusted.at = null;
    expect(
      (await put(const KillResumeItemSubmission(itemNo: 1, text: 'x')))
          .reasonCode,
      'RESUME_TRUSTED_TIME_UNKNOWN',
    );
    trusted.at = clock.nowUtc().add(const Duration(hours: 10));
    final SafetyActionResult soon = await put(
      const KillResumeItemSubmission(itemNo: 1, text: 'x'),
    );
    expect(soon.reasonCode, 'RESUME_TOO_SOON');
    expect(soon.headline, '아직 기다리는 중입니다 — 해제 가능 예정 12-25 10:20.');
    trusted.at = clock.nowUtc().add(const Duration(hours: 49));

    final List<KillResumeGateVm> got = <KillResumeGateVm>[];
    final StreamSubscription<KillResumeGateVm> sub = repo
        .watchResumeGate()
        .listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.nextItemNo, 1);
    expect(got.last.items[0].replayText, '그때 적은 행동: 규칙대로 신규 진입을 멈춘다');
    expect(got.last.items[1].replayText, '그때: 불안 · 강도 7 · 수면 4시간');

    expect(
      (await put(const KillResumeItemSubmission(itemNo: 2, emotion: 'a')))
          .reasonCode,
      'RESUME_ITEM_OUT_OF_ORDER',
    );
    expect(
      (await put(const KillResumeItemSubmission(itemNo: 1, text: '지금도 멈춤')))
          .headline,
      KillResumeGateTexts.accepted(1),
    );
    await until(() => got.last.nextItemNo == 2);
    expect(got.last.items[0].answeredText, '지금 규칙: 지금도 멈춤');
    final SafetyActionResult miss = await put(
      const KillResumeItemSubmission(itemNo: 2, emotion: '담담', intensity: '많이'),
    );
    expect(miss.reasonCode, 'RESUME_ITEM_MISSING');
    expect(miss.headline, KillResumeGateTexts.missing(2));
    // 1번 다시 = 처음부터(받힌다 — 차례 어김이 아니다).
    expect(
      (await put(const KillResumeItemSubmission(itemNo: 1, text: '다시')))
          .reasonCode,
      isNull,
    );
    expect(draft.value.accepted.length, 1);
    expect(draft.value.accepted.single.text, '다시');
    for (final KillResumeItemSubmission s in const <KillResumeItemSubmission>[
      KillResumeItemSubmission(
        itemNo: 2,
        emotion: '담담',
        intensity: '2',
        sleepHours: '7',
      ),
      KillResumeItemSubmission(
        itemNo: 3,
        scenario: KillResumeScenario.resolved,
      ),
      KillResumeItemSubmission(itemNo: 4, condition: KillResumeCondition.met),
      KillResumeItemSubmission(itemNo: 5, acknowledged: true),
      KillResumeItemSubmission(itemNo: 6, acknowledged: true),
    ]) {
      expect((await put(s)).reasonCode, isNull, reason: '${s.itemNo}');
    }
    await until(() => got.last.nextItemNo == 7);
    final SafetyActionResult done = await put(
      const KillResumeItemSubmission(
        itemNo: 7,
        rationaleBefore: '근거',
        expectedOutcome: '결과',
        ruleCited: 'W3',
      ),
    );
    expect(done.reasonCode, isNull);
    expect(done.level, UiLevel.ok);
    expect(done.headline, KillResumeGateTexts.done);
    expect(draft.value.accepted, isEmpty);
    await until(() => got.last.readinessLabel == '킬스위치 꺼짐');
    expect(got.last.nextItemNo, isNull);
    expect(await acts.watch(done.actionRunId).first, done);
  });

  test('🆕 R179 4번 미충족 = 막힘(받을 문항 0) → 다시 열면 1번부터', () async {
    final OperatorRuntime r = rt();
    final OperatorKillResumeDraft draft = OperatorKillResumeDraft();
    addTearDown(draft.dispose);
    final OperatorSafetyActions acts = OperatorSafetyActions(r, draft: draft);
    OperatorKillSwitchGateRepository repo() => OperatorKillSwitchGateRepository(
      r,
      hasBody: kOperatorRouteBodies.byPattern.containsKey,
      draft: draft,
    );
    final OperatorCommandApi api = OperatorCommandApi(r);
    await api.activateKillSwitch();
    trusted.at = clock.nowUtc().add(const Duration(minutes: 18));
    await api.confirmKillChecklist(_record);
    trusted.at = clock.nowUtc().add(const Duration(hours: 49));
    for (final KillResumeItemSubmission s in const <KillResumeItemSubmission>[
      KillResumeItemSubmission(itemNo: 1, text: 'a'),
      KillResumeItemSubmission(
        itemNo: 2,
        emotion: 'b',
        intensity: '1',
        sleepHours: '8',
      ),
      KillResumeItemSubmission(itemNo: 3, scenario: KillResumeScenario.ongoing),
    ]) {
      await acts.runKillResumeItem(s);
    }
    final SafetyActionResult unmet = await acts.runKillResumeItem(
      const KillResumeItemSubmission(
        itemNo: 4,
        condition: KillResumeCondition.unmet,
      ),
    );
    expect(unmet.reasonCode, 'RESUME_CONDITION_UNMET');
    expect(draft.value.conditionUnmet, isTrue);
    final KillResumeGateVm reopened = await repo().watchResumeGate().first;
    expect(reopened.nextItemNo, 1, reason: '다시 열면 1번부터');
    expect(reopened.blockedText, isNull);
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5ReleaseGate),
      true,
    );
  });
}
