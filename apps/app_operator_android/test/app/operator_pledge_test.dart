// E11p4h — 서약 operator 판(설계 13 §8 R157) — 실 SQLite(sim 원장) · 엔진 `SqlitePledgeStore` · 결과 = 엔진 문장.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_onboarding.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show PledgeCodes, PledgeResultTexts, TrustedClock, pledgeSubmissionDigest;
import 'package:data_sync/data_sync.dart' show SqliteOnboardingStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);

  DateTime? at;

  @override
  DateTime? trustedNowUtc() => at;
}

const List<String> _three = <String>[
  ' 정한 날에만 산다 ',
  '하락에도 규칙을 지킨다',
  '멈춘 뒤엔 점검부터',
];

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 19, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(DateTime.utc(2026, 11, 19, 0, 30));
  });
  tearDown(() => files.close());

  OperatorRuntime rt({bool withTrusted = true}) => OperatorRuntime(
    files: files,
    clock: clock,
    trusted: withTrusted ? trusted : null,
  );

  OperatorSafetyActions actions({bool withTrusted = true}) =>
      OperatorSafetyActions(rt(withTrusted: withTrusted), random: Random(5));

  PledgeSubmission write(List<String> s) =>
      PledgeSubmission(id: SafetyActionId.pledgeWrite, sentences: s);

  int pledges() =>
      files.sim.select('SELECT COUNT(*) AS n FROM pledge').first['n'] as int;

  test(
    '🔴 첫 판 = 엔진 실행 · 결과 = 엔진 문장 · 판 1 · 저널 id = 명령 id · 지문 = 제출 · watch 같은 값',
    () async {
      final OperatorSafetyActions a = actions();
      final PledgeSubmission sub = write(_three);
      final SafetyActionResult r = await a.runPledge(sub);
      expect(r.id, SafetyActionId.pledgeWrite);
      expect(r.level, UiLevel.ok);
      expect(r.headline, PledgeResultTexts.written);
      expect(r.reasonCode, isNull);
      final row = files.sim.select('SELECT * FROM pledge').single;
      expect(row['version'], 1);
      expect(row['sentence_1'], '정한 날에만 산다');
      expect(row['sentence_3'], '멈춘 뒤엔 점검부터');
      expect(row['decision_id'], r.actionRunId);
      final cmd = files.sim.select(
        'SELECT kind, decision_id, payload_digest, state FROM command_inbox WHERE command_id = ?',
        <Object?>[r.actionRunId],
      ).single;
      expect(cmd['kind'], 'PLEDGE_WRITE');
      expect(cmd['decision_id'], r.actionRunId);
      expect(cmd['payload_digest'], pledgeSubmissionDigest(sub));
      expect(cmd['state'], 'EXECUTED');
      expect(await a.watch(r.actionRunId).toList(), <SafetyActionResult>[r]);
      await expectLater(a.watch('모름'), emitsError(isA<StateError>()));
    },
  );

  test('🔴 신뢰 시각 모름(E11k 전 기본) = 저장 안 함 · «서버 시각» 문장 · 막힘', () async {
    final SafetyActionResult r = await actions(withTrusted: false)
        .runPledge(write(_three));
    expect(r.reasonCode, PledgeCodes.trustedTimeUnknown);
    expect(r.level, UiLevel.blocked);
    expect(r.headline, PledgeResultTexts.trustedTimeUnknown);
    expect(pledges(), 0);
  });

  test('🔴 빈칸 = 엔진 거부(세 문장) · 두 번째 첫 판 = 이미 있음 · 원문은 한 번만', () async {
    final OperatorSafetyActions a = actions();
    final SafetyActionResult blank = await a.runPledge(
      write(<String>['가', ' ', '다']),
    );
    expect(blank.reasonCode, PledgeResultCodes.sentencesMissing);
    expect(blank.headline, PledgeResultTexts.sentencesMissing);
    expect(pledges(), 0);
    final SafetyActionResult two = await a.runPledge(write(<String>['나']));
    expect(two.reasonCode, PledgeResultCodes.sentencesMissing);
    expect((await a.runPledge(write(_three))).reasonCode, isNull);
    final SafetyActionResult again = await a.runPledge(write(_three));
    expect(again.reasonCode, PledgeResultCodes.alreadyWritten);
    expect(again.headline, PledgeResultTexts.alreadyWritten);
    expect(pledges(), 1);
  });

  test('🔴 편집 = 엔진 판정 그대로(11월 = 창 밖 · 12월 + 저널 없음 = 저널 없음) · 판 그대로', () async {
    final OperatorSafetyActions a = actions();
    await a.runPledge(write(_three));
    const List<String> next = <String>['가', '나', '다'];
    final SafetyActionResult nov = await a.runPledge(
      const PledgeSubmission(id: SafetyActionId.pledgeEdit, sentences: next),
    );
    expect(nov.reasonCode, PledgeResultCodes.outOfWindow);
    expect(nov.level, UiLevel.watch);
    trusted.at = DateTime.utc(2026, 12, 2);
    final SafetyActionResult dec = await a.runPledge(
      const PledgeSubmission(id: SafetyActionId.pledgeEdit, sentences: next),
    );
    expect(dec.reasonCode, PledgeResultCodes.journalMissing);
    expect(dec.headline, PledgeResultTexts.journalMissing);
    expect(pledges(), 1);
  });

  test('🔴 서약 아닌 동작 id = ArgumentError · 서약 밖 안전 동작 = 구현 전(오류)', () async {
    final OperatorSafetyActions a = actions();
    await expectLater(
      a.runPledge(
        const PledgeSubmission(
          id: SafetyActionId.killSwitchResume,
          sentences: _three,
        ),
      ),
      throwsArgumentError,
    );
    await expectLater(
      a.run(SafetyActionId.ruleChangeCancel),
      throwsA(isA<UnsupportedError>()),
    );
    // 🆕 R179 — 재개 문항 = 구현(`operator_kill_resume_test`).
    expect(pledges(), 0);
  });

  test(
    '🔴 읽기 = 처음 0줄 → 저장하면 세 줄(같은 원장 · 바뀔 때 다시 낸다) · 12월 신뢰 시각 = 편집 가능',
    () async {
      final List<PledgeVm> got = <PledgeVm>[];
      final StreamSubscription<PledgeVm> sub = OperatorPledgeRepository(rt())
          .watchPledge()
          .listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got.last.lines, isEmpty);
      expect(got.last.editable, isFalse);
      await actions().runPledge(write(_three));
      await until(() => got.last.lines.isNotEmpty);
      expect(got.last.lines, <String>[
        '정한 날에만 산다',
        '하락에도 규칙을 지킨다',
        '멈춘 뒤엔 점검부터',
      ]);
      expect(got.last.editable, isFalse);
      expect(got.last.asOf.label, '서약 기준 2026-11-19 09:30');
      trusted.at = DateTime.utc(2026, 12, 2);
      final PledgeVm dec = await OperatorPledgeRepository(rt())
          .watchPledge()
          .first;
      expect(dec.editable, isTrue);
      final PledgeVm unknown = await OperatorPledgeRepository(
        rt(withTrusted: false),
      ).watchPledge().first;
      expect(unknown.editable, isFalse);
      expect(unknown.lines, hasLength(3));
    },
  );
  test('🔴 O-04 ② — 서약 저장 = 마무리 ② 확인됨 · 슬롯 닫힘(같은 원장 · 실제 시간)', () async {
    expect(
      SqliteOnboardingStore(
        files.sim,
        clock: clock,
      ).selectOperatingMode(OperatingMode.autoTrade).ok,
      isTrue,
    );
    final List<OnboardingFinishVm> got = <OnboardingFinishVm>[];
    final StreamSubscription<OnboardingFinishVm> sub =
        OperatorOnboardingRepository(rt()).watchFinish().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.stages[1].slotId, OnboardingSlotIds.pledgeWrite);
    expect(got.last.stages[1].state, isNot(StepState.verified));
    await actions().runPledge(write(_three));
    await until(() => got.last.stages[1].state == StepState.verified);
    expect(got.last.stages[1].slotId, isNull);
  });
}
