// E11q-s05 — M9 S05 운용 관리 VM 짓기(설계 13 §8 R252 · 01 §28) — 표본 `m9/operations_*` 글자 대조 · 버튼 = 창구가 있을 때만.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

Map<String, Object?> _doc(String f) => jsonDecode(
  File('../domain_contracts/fixtures/m9/$f.json').readAsStringSync(),
) as Map<String, Object?>;

OperationsVm _fixture(String name) => OperationsVm.fromJson(
  (_doc('operations_$name')['rows']! as List<Object?>).single!
      as Map<String, Object?>,
);

ActionResult _result(String runId) => ActionResult.fromJson(
  (_doc('operations_action_results')['rows']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .singleWhere((Map<String, Object?> r) => r['action_run_id'] == runId),
);

final DateTime _now = DateTime.utc(2026, 11, 24, 0, 0); // 09:00 KST

const LedgerTrustBadge _trust = LedgerTrustBadge(
  grade: LedgerTrustGrade.reconciled,
  level: UiLevel.ok,
  label: '브로커 대사 일치',
  consequenceLine: '차이 0건입니다.',
);

const List<JobRow> _jobs = <JobRow>[
  JobRow(
    label: '대사 배치',
    scheduleText: '평일 07:00 · 유예 2시간',
    lastRunText: '오늘 07:02 끝남',
    statusCode: 'SUCCESS',
    stateLabel: '성공',
    level: UiLevel.ok,
  ),
];

SimTrialReport _trial() => judgeSimTrial(
  SimTrialFacts(
    asOfUtc: _now,
    anchorUtc: _now.subtract(const Duration(days: 3)),
    runMode: RunMode.simInternal,
    batchOkDays: const <String>{},
    rebalances: const <SimTrialRebalance>[],
    recons: const <SimTrialRecon>[],
    openLedgerDiffs: 0,
    resumeRuns: const <SimTrialResumeRun>[],
    killEvents: const <SimTrialKillEvent>[],
    alertRaisedUtc: const <DateTime>[],
    interventionStartedUtc: const <DateTime>[],
  ),
  kr: frozenExchangeCalendar(Market.kr),
);

LiveObservationReport _observe({required bool promotable}) =>
    LiveObservationReport(
      observing: true,
      observedTradingDays: promotable ? 2 : 1,
      promotionAvailable: promotable,
      block: promotable ? null : LiveObservationBlock.notEnoughDays,
      vm: LiveDryRunObservationVm(
        observedTradingDays: promotable ? 2 : 1,
        requiredTradingDays: 2,
        progressText: '무결 거래일 ${promotable ? 2 : 1}/2',
        promotionAvailable: promotable,
        stateLabel: '실전 관찰 중',
      ),
      promotionLabel: promotable
          ? '승격 가능 — 무결 거래일을 채웠습니다(2/2)'
          : '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)',
    );

OperationsFacts _facts({
  RunMode run = RunMode.simInternal,
  OperatingMode op = OperatingMode.autoTrade,
  Set<String> holds = const <String>{},
  List<String> rejected = const <String>[],
  LiveObservationReport? observation,
  SimTrialReport? trial,
  int? ramp,
  int? preDst,
  String? next = '오늘 18:30 국내 시세 수집',
  bool canSwitch = false,
  bool canPromote = false,
}) => OperationsFacts(
  runMode: run,
  operatingMode: op,
  holds: holds,
  rejected: rejected,
  observation: observation,
  trial: trial,
  rampLevel: ramp,
  preDstRampLevel: preDst,
  jobs: _jobs,
  nextJobText: next,
  trust: _trust,
  canRequestSwitch: canSwitch,
  canPromote: canPromote,
  nowUtc: _now,
);

void main() {
  group('S05 운용 관리 VM(R252)', () {
    test(
      '🔴 모의 — 칩 = S01 생산 · 모드 카드 · 전환 요청 = 창구가 있을 때만(표본 글자) · 체험 카드 · 램프 빈 까닭',
      () {
        final OperationsVm sim = _fixture('sim_auto');
        final OperationsVm vm = operationsVmOf(
          _facts(trial: _trial(), canSwitch: true),
        );
        expect(
          vm.statusChip,
          settingsStatusChipOf(RunMode.simInternal, OperatingMode.autoTrade),
        );
        expect(vm.statusChip, sim.statusChip);
        expect(
          (vm.mode.label, vm.mode.level, vm.mode.holdLabel),
          (sim.mode.label, sim.mode.level, null),
        );
        expect(vm.mode.switchNoticeText, sim.mode.switchNoticeText);
        expect(vm.mode.switchActions, sim.mode.switchActions);
        expect(vm.mode.promotionAction, isNull);
        expect(vm.ramp, sim.ramp);
        expect(vm.trial, isNotNull);
        expect(vm.trial!.checks, hasLength(5));
        expect(vm.jobs, _jobs);
        expect(
          (vm.updateGate, vm.lastRequestNotice, vm.lockedLabel),
          (null, null, null),
        );
        expect(vm.asOf.label, '운용 기준 2026-11-24 09:00');
        // 창구 없음 = 버튼 · 고지 부재(지어내지 않는다).
        final OperationsVm bare = operationsVmOf(_facts(trial: _trial()));
        expect(bare.mode.switchActions, isEmpty);
        expect(bare.mode.switchNoticeText, isNull);
      },
    );

    test('🔴 브로커 모의 = KIS 모의투자 서버 글자(표본 sim_complete)', () {
      final OperationsVm vm = operationsVmOf(_facts(run: RunMode.simBroker));
      expect(vm.mode.label, _fixture('sim_complete').mode.label);
    });

    test(
      '🔴 운영 방식 카드 = O-00b 와 같은 카드 · 전환 버튼 0 · 위저드 게이트 = 해당 없음 · 배지 = 받은 것',
      () {
        final OperatingModeView v = operationsVmOf(_facts()).operatingMode;
        final OperatingModeView f = _fixture('sim_auto').operatingMode;
        expect(
          (v.current, v.label, v.explainLine),
          (f.current, f.label, f.explainLine),
        );
        expect(v.options, f.options);
        expect(v.switchGates, f.switchGates);
        expect(v.switchActions, isEmpty);
        expect(v.trust, _trust);
        final OperatingModeView adv = operationsVmOf(
          _facts(run: RunMode.live, op: OperatingMode.advisory),
        ).operatingMode;
        final OperatingModeView fa = _fixture('advisory').operatingMode;
        expect((adv.label, adv.explainLine), (fa.label, fa.explainLine));
        expect(adv.switchActions, isEmpty);
      },
    );

    test('🔴 실전 관찰 — 칩 승격 줄 = 관찰 판정 · 모드 = 관찰 중 WATCH · 승격 버튼 = 가능 ∧ 창구(표본 live_promotable)', () {
      final OperationsVm promotable = _fixture('live_promotable');
      final OperationsVm vm = operationsVmOf(
        _facts(
          run: RunMode.live,
          observation: _observe(promotable: true),
          canPromote: true,
        ),
      );
      expect(
        vm.statusChip.promotionLabel,
        promotable.statusChip.promotionLabel,
      );
      expect(
        (vm.mode.label, vm.mode.level),
        (promotable.mode.label, promotable.mode.level),
      );
      expect(vm.mode.promotionAction, promotable.mode.promotionAction);
      expect(vm.mode.observation?.progressText, '무결 거래일 2/2');
      expect(
        vm.operatingMode.explainLine,
        _fixture('live_observe').operatingMode.explainLine,
      );
      expect(vm.trial, isNull);
      expect(vm.mode.switchActions, isEmpty);
      // 실전 = 체험 카드 0(체험 판정을 받아도 · 엔진 의무 «SIM 계열만») · 전환 요청 0(창구가 있어도).
      final OperationsVm liveTrial = operationsVmOf(
        _facts(
          run: RunMode.live,
          trial: _trial(),
          observation: LiveObservationReport.notObserving,
          canSwitch: true,
        ),
      );
      expect(liveTrial.trial, isNull);
      expect(liveTrial.mode.switchActions, isEmpty);
      expect(liveTrial.mode.switchNoticeText, isNull);
      // 창구 없음 · 아직 불가 = 버튼 부재.
      expect(
        operationsVmOf(
          _facts(run: RunMode.live, observation: _observe(promotable: true)),
        ).mode.promotionAction,
        isNull,
      );
      final OperationsVm notYet = operationsVmOf(
        _facts(
          run: RunMode.live,
          observation: _observe(promotable: false),
          canPromote: true,
        ),
      );
      expect(notYet.mode.promotionAction, isNull);
      expect(
        notYet.statusChip.promotionLabel,
        _fixture('live_observe').statusChip.promotionLabel,
      );
    });

    test(
      '🔴 관찰 아님(실전 집행) = 승격 줄 · 관찰 칸 0 · 자동 주문 OK · 모의는 관찰 판정을 받아도 칩 줄 0',
      () {
        final OperationsVm vm = operationsVmOf(
          _facts(
            run: RunMode.live,
            observation: LiveObservationReport.notObserving,
            canPromote: true,
          ),
        );
        expect(
          (vm.mode.label, vm.mode.level, vm.mode.observation),
          ('실전 · 자동 주문', UiLevel.ok, null),
        );
        expect(vm.statusChip.promotionLabel, isNull);
        expect(
          operationsVmOf(
            _facts(observation: _observe(promotable: true), canPromote: true),
          ).statusChip.promotionLabel,
          isNull,
        );
      },
    );

    test('🔴 hold = 짝 문장(표본 live_hold_keys) · 모드 WATCH · 엔진 줄 = 배치 멈춤 · 모르는 코드 = ArgumentError', () {
      final OperationsVm f = _fixture('live_hold_keys');
      final OperationsVm vm = operationsVmOf(
        _facts(
          run: RunMode.live,
          holds: const <String>{SafetyHoldCodes.liveAwaitingKeys},
          observation: LiveObservationReport.notObserving,
        ),
      );
      expect(
        (vm.mode.label, vm.mode.level, vm.mode.holdLabel),
        (f.mode.label, f.mode.level, f.mode.holdLabel),
      );
      expect(
        (vm.control.stateLabel, vm.control.level),
        (OperationsTexts.heldBatches, UiLevel.watch),
      );
      expect(
        () => operationsVmOf(_facts(holds: const <String>{'NOPE'})),
        throwsArgumentError,
      );
    });

    test('🔴 엔진 줄 = 다음 잡(표본 꼴) · 기동 거부 = 막힘 + 코드 · 시작 · 중지 버튼 0(미결 173)', () {
      final EngineControl ok = operationsVmOf(_facts()).control;
      expect(
        (ok.stateLabel, ok.level),
        ('돌고 있음 — 다음 잡: 오늘 18:30 국내 시세 수집', UiLevel.ok),
      );
      expect((ok.startAction, ok.stopPromptText), (null, null));
      expect(ok.stopActions, isEmpty);
      expect(operationsVmOf(_facts(next: null)).control.stateLabel, '돌고 있음');
      final EngineControl no = operationsVmOf(
        _facts(rejected: const <String>['SAF-405', 'CREDENTIAL_ENV_MISMATCH']),
      ).control;
      expect(
        (no.stateLabel, no.level, no.startAction),
        (
          '멈춤 — 기동 판정이 시작을 거부했습니다(SAF-405 · CREDENTIAL_ENV_MISMATCH)',
          UiLevel.blocked,
          null,
        ),
      );
    });

    test('🔴 램프 — 실전 = 03 §9-2 비중 · DST 하향 = 표본 글자 · 조건 = 빈 + 까닭(미결 172) · 범위 밖 = RangeError', () {
      final RampBoard dst = operationsRampOf(
        runMode: RunMode.live,
        level: 2,
        preDstLevel: 3,
      );
      final RampBoard f = _fixture('live_hold_keys').ramp;
      expect(
        (dst.levelLabel, dst.level, dst.dstNoticeText),
        (f.levelLabel, f.level, f.dstNoticeText),
      );
      expect(dst.conditions, isEmpty);
      expect(dst.emptyLabel, OperationsTexts.rampLiveEmpty);
      expect(
        operationsRampOf(runMode: RunMode.live).levelLabel,
        _fixture('live_observe').ramp.levelLabel,
      );
      expect(
        operationsRampOf(runMode: RunMode.live, level: 5).levelLabel,
        'L5 · 100% · 최고 단계',
      );
      expect(
        operationsRampOf(runMode: RunMode.live, level: 3, preDstLevel: 3),
        const RampBoard(
          levelLabel: 'L3 · 40%',
          level: UiLevel.info,
          emptyLabel: OperationsTexts.rampLiveEmpty,
        ),
      );
      expect(
        () => operationsRampOf(runMode: RunMode.live, level: 6),
        throwsRangeError,
      );
      expect(kOpsRampPercent.keys, <int>[1, 2, 3, 4, 5]);
    });

    test('🔴 결과 — 실전 전환 요청 = 위저드로 넘김(표본 ar_s05_01) · 승격 결과 레벨 · 글자(표본 ar_s05_10~13)', () {
      final ActionResult sw = runModeSwitchRequestedResultOf(
        actionRunId: 'ar_s05_01',
      );
      expect(sw, _result('ar_s05_01'));
      final ActionResult notEnough = _result('ar_s05_10');
      expect(
        livePromotionActionResultOf(
          actionRunId: 'ar_s05_10',
          code: notEnough.reasonCode,
          headline: notEnough.headline,
        ),
        notEnough,
      );
      for (final String id in <String>['ar_s05_11', 'ar_s05_12', 'ar_s05_13']) {
        final ActionResult want = _result(id);
        expect(
          livePromotionActionResultOf(
            actionRunId: id,
            code: want.reasonCode,
            headline: livePromotionHeadline(want.reasonCode),
          ),
          want,
          reason: id,
        );
      }
      // 레벨 전수 — 막는 코드는 OK 가 아니다 · 되돌림만 다시 시도.
      for (final String c in livePromotionResultCodes) {
        expect(livePromotionResultLevel(c), isNot(UiLevel.ok), reason: c);
        expect(
          livePromotionActionResultOf(
            actionRunId: 'x',
            code: c,
            headline: livePromotionHeadline(c),
          ).retryable,
          c == LivePromotionCodes.rolledBack,
          reason: c,
        );
      }
      expect(livePromotionResultLevel(kLeaseInvalidCode), UiLevel.blocked);
    });

    test('🔴 «DRY_RUN» · 손익 글자 0', () {
      final String all = jsonEncode(<Object?>[
        operationsVmOf(_facts(trial: _trial(), canSwitch: true)).toJson(),
        operationsVmOf(
          _facts(
            run: RunMode.live,
            observation: _observe(promotable: true),
            canPromote: true,
            ramp: 2,
            preDst: 3,
          ),
        ).toJson(),
      ]);
      for (final String banned in <String>['DRY_RUN', 'dry-run', '수익', '손익']) {
        expect(all.contains(banned), isFalse, reason: banned);
      }
    });
  });
}
