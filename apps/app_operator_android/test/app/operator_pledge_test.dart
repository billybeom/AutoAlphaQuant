// E11p4h — 서약 operator 판(설계 13 §8 R157) — 실 SQLite(sim 원장) · 엔진 `SqlitePledgeStore` · 결과 = 엔진 문장.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_onboarding.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show PledgeCodes, PledgeResultTexts, TrustedClock, pledgeSubmissionDigest;
import 'package:data_sync/data_sync.dart'
    show SqliteOnboardingStore, SqlitePledgeStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

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
    // 🆕 R188 — `run` 의 규칙 변경 취소 = 구현(`operator_rule_change_test`) · 그 밖 id = 구현 전 · 🆕 R189 RECON = 화이트리스트 밖.
    // 🆕 E16j-a(R227) — 개입 단계 = 구현(`operator_repair_test` · args 없음 = ArgumentError) · 그 밖 id = 구현 전.
    await expectLater(
      a.run(SafetyActionId.interventionStep),
      throwsArgumentError,
    );
    await expectLater(
      a.run(SafetyActionId.stoppedDecision),
      throwsA(isA<UnsupportedError>()),
    );
    await expectLater(a.run(SafetyActionId.reconClear), throwsArgumentError);
    // 🆕 R180 — 재개 문항 = 구현(`operator_kill_resume_test`).
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
  test('🆕 리뷰 3차 H1-6(미결 231 ⓓ · R265) — 서약 원장 = 화면 원장: 실전 전환 뒤 읽기 · 12월 창 편집 = 실전 파일(J-3 저널 · 판) · 모의 파일 0', () async {
    final OperatorRuntime r = rt();
    final OperatorSafetyActions a = OperatorSafetyActions(r, random: Random(5));
    final List<PledgeVm> got = <PledgeVm>[];
    final StreamSubscription<PledgeVm> sub = OperatorPledgeRepository(r)
        .watchPledge()
        .listen(got.add);
    addTearDown(sub.cancel);
    // 화면 상태 없음(온보딩 ③) = 모의 파일.
    expect((await a.runPledge(write(_three))).reasonCode, isNull);
    expect(pledges(), 1);
    await until(() => got.isNotEmpty && got.last.lines.length == 3);
    // 실전 전환 — 커밋이 서약 판을 실전 파일로 옮겼다(같은 판 · 여기서는 실전 파일에 같은 첫 판) → 화면 = 실전 원장.
    final Database live = files.openLive();
    expect(
      SqlitePledgeStore(live, clock: clock, trusted: trusted)
          .writeFirst(
            commandId: 'carried',
            payloadDigest: 'dg',
            sentences: const <String>['실전 하나', '실전 둘', '실전 셋'],
            decisionId: 'ON-1',
          )
          .executed,
      isTrue,
    );
    r.view.value = OperatorView(
      db: live,
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.live,
        operatingMode: OperatingMode.autoTrade,
        configHash: '',
      ),
    );
    await until(() => got.last.lines.first == '실전 하나');
    // 12월 창 · J-3 저널 = 실전 파일에만.
    trusted.at = DateTime.utc(2026, 12, 2);
    live.execute(
      'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, is_deviation, '
      "rationale_before, expected_outcome, rule_cited, kind, note, created_at) VALUES ('J-LIVE', '2026-12-02', 'P0S', "
      "'{}', '{}', 0, '근거', '기대', '03 §6-4', NULL, NULL, '2026-12-02T00:00:00.000Z')",
    );
    final SafetyActionResult dec = await a.runPledge(
      const PledgeSubmission(
        id: SafetyActionId.pledgeEdit,
        sentences: <String>['가', '나', '다'],
        decisionId: 'J-LIVE',
      ),
    );
    expect(dec.reasonCode, isNull, reason: dec.headline);
    expect(live.select('SELECT MAX(version) AS v FROM pledge').first['v'], 2);
    expect(pledges(), 1, reason: '모의 파일 서약 그대로');
    await until(() => got.last.lines.first == '가');
  });

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
