// C-53 운용 관리·S05 동작·E15i 등재형 — 01 §28(🆕 계약 v1.19 · R6c 선행 + 엔진 E15i 굳은 몫 ·
// 발주자 위임 2026-11-14 — 권고대로 · K1~K26).
//
// 정의: 「M9 `S05` 운용 관리는 엔진이 완성한 VM 으로 온다 — 두 축(모드 · 운영 방식)은 각각 · 버튼 = 엔진이 완성한
//        `SettingsActionCall`(args 화이트리스트 · `target` 키 0) · 고지 짝 · 엔진 시작 xor 중지 · 잠김 = `lockedLabel` +
//        엔진이 동작 칸 5 를 비움 · 승격 버튼 ⇔ 관찰 승격 가능 · 체험·잡·램프 색 = `level`(짝 = 엔진 의무) ·
//        결과 = 버튼 근거 0 — 그리고 E15i 등재형 사전이 엔진 글자와 같다」.
//   ① 허용 키 ② 넘김 ③ 글자 ④ 동작 호출 ⑤ 고지 짝 ⑥ 엔진 제어 ⑦ 잠김 ⑧ 관찰·승격 ⑨ 체험 ⑩ 잡 ⑪ 램프
//   ⑫ 동작 결과 ⑬ E15i 등재형 ⑭ hold 칸 ⑮ 받침대.
//
// 🔴 픽스처 불변식만 본다 — `ui_settings` S05 화면 스캔은 R6c 카드 정적 묶음 몫.
// 🔴 한국어 글자 단언 0 — 상수 리터럴 = 표본 id·키 이름·코드·라우트 상수·`FixturePaths` · 예외 = ③ 금지 낱말 목록 ·
//    ⑬ 엔진 글자 집합(엔진 실물 대조 — `core_engine` 을 import 하지 않는다: 계약 패키지는 엔진에 의존하지 않는다).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// `OperationsVm` 표본 7벌.
const List<String> _vms = <String>[
  FixturePaths.m9OperationsSimAuto,
  FixturePaths.m9OperationsSimComplete,
  FixturePaths.m9OperationsLiveObserve,
  FixturePaths.m9OperationsLivePromotable,
  FixturePaths.m9OperationsLiveHoldKeys,
  FixturePaths.m9OperationsAdvisory,
  FixturePaths.m9OperationsLocked,
];

/// 신설 8벌(VM 7 + 결과 1).
const List<String> _all = <String>[
  ..._vms,
  FixturePaths.m9OperationsActionResults,
];

/// ③ 손익 낱말(C-52 ⑬ 과 같은 목록).
const List<String> _pnlWords = <String>['수익률', '평가액', '손익'];

/// ③ 금액 글자 꼴.
final RegExp _money = RegExp(r'[0-9][0-9,]*원');

/// ④ S05 동작 id 5.
const Set<SettingsActionId> _s05Ids = <SettingsActionId>{
  SettingsActionId.runtimeModeSwitchRequest,
  SettingsActionId.runtimeOperatingModeSwitchRequest,
  SettingsActionId.runtimeEngineStart,
  SettingsActionId.runtimeEngineStop,
  SettingsActionId.runtimeLivePromotion,
};

/// ⑨ 엔진 체험 5항목 차례(`core_engine` `SimTrialItem` 차례 = 04 §9-5).
const List<String> _engineTrialOrder = <String>[
  'SIM_TRIAL_TWO_TRADING_WEEKS',
  'SIM_TRIAL_MONTH_END_REBALANCE',
  'SIM_TRIAL_RECONCILIATION',
  'SIM_TRIAL_RESUME',
  'SIM_TRIAL_KILL_SWITCH',
];

/// ⑨ 체험 상태 → 색(K9 · 엔진 의무).
const Map<String, UiLevel> _trialLevel = <String, UiLevel>{
  'PASSED': UiLevel.ok,
  'AUTO_PASSED': UiLevel.ok,
  'OPEN': UiLevel.watch,
  'OPEN_WARN': UiLevel.info,
};

/// ⑩ 잡 상태 → 허용 색(K12 · 엔진 의무).
const Map<String, Set<UiLevel>> _jobLevels = <String, Set<UiLevel>>{
  'SUCCESS': <UiLevel>{UiLevel.ok},
  'LATE': <UiLevel>{UiLevel.watch},
  'HOLIDAY': <UiLevel>{UiLevel.info},
  'NONE': <UiLevel>{UiLevel.info},
  'FAILED': <UiLevel>{UiLevel.act, UiLevel.blocked},
};

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? list) =>
    (list! as List<Object?>).cast<Map<String, Object?>>();

List<Map<String, Object?>> _rows(String path) => _maps(_env(path)['rows']);

/// VM 1행 봉투의 VM.
Map<String, Object?> _vm(String path) {
  final List<Map<String, Object?>> rows = _rows(path);
  expect(rows, hasLength(1), reason: '$path — VM 1행 봉투가 아니다');
  return rows.single;
}

Map<String, Object?>? _map(Object? v) => v as Map<String, Object?>?;

Set<String> _keys(Map<String, Object?> m) => m.keys.toSet();

OperationsVm _ops(String path) => OperationsVm.fromJson(_vm(path));

/// 문자열 값 전부.
List<String> _strings(Object? node) {
  final List<String> out = <String>[];
  void visit(Object? n) {
    if (n is String) {
      out.add(n);
    } else if (n is Map) {
      n.values.forEach(visit);
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// 키 전부(깊이 우선).
Set<String> _allKeys(Object? node) {
  final Set<String> out = <String>{};
  void visit(Object? n) {
    if (n is Map) {
      for (final MapEntry<Object?, Object?> e in n.entries) {
        out.add(e.key! as String);
        visit(e.value);
      }
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

void _expectSameKeys(
  Map<String, Object?> raw,
  Map<String, Object?> json,
  String where,
) {
  expect(_keys(raw), _keys(json), reason: '$where — 직속 키 ≠ toJson 키');
}

/// 동작 호출 1개 — id · args 키 · 라벨.
void _expectCall(
  SettingsActionCall a,
  SettingsActionId id,
  Set<String> argKeys,
  String where,
) {
  expect(a.id, id, reason: where);
  expect(a.args.keys.toSet(), argKeys, reason: '$where — args 화이트리스트');
  expect(a.label, isNotEmpty, reason: '$where — 버튼 글자');
}

void main() {
  group('C-53 운용 관리·S05 동작·E15i 등재형 (01 §28 · 계약 v1.19)', () {
    test('C-53 ① 허용 키 — 새·개정 DTO 의 직속 키 = toJson · 삭제·금지·walker 키 0', () {
      for (final String path in _vms) {
        final Map<String, Object?> raw = _vm(path);
        final OperationsVm vm = OperationsVm.fromJson(raw);
        _expectSameKeys(raw, vm.toJson(), '$path OperationsVm');
        _expectSameKeys(
          _map(raw['mode'])!,
          vm.mode.toJson(),
          '$path RunModeCard',
        );
        _expectSameKeys(
          _map(raw['operating_mode'])!,
          vm.operatingMode.toJson(),
          '$path OperatingModeView',
        );
        _expectSameKeys(
          _map(raw['ramp'])!,
          vm.ramp.toJson(),
          '$path RampBoard',
        );
        final List<Map<String, Object?>> conds = _maps(
          _map(raw['ramp'])!['conditions'],
        );
        for (int i = 0; i < conds.length; i++) {
          _expectSameKeys(
            conds[i],
            vm.ramp.conditions[i].toJson(),
            '$path RampCondition[$i]',
          );
        }
        final List<Map<String, Object?>> jobs = _maps(raw['jobs']);
        for (int i = 0; i < jobs.length; i++) {
          _expectSameKeys(jobs[i], vm.jobs[i].toJson(), '$path JobRow[$i]');
        }
        _expectSameKeys(
          _map(raw['control'])!,
          vm.control.toJson(),
          '$path EngineControl',
        );
        if (vm.trial != null) {
          final Map<String, Object?> t = _map(raw['trial'])!;
          _expectSameKeys(t, vm.trial!.toJson(), '$path SimTrialCard');
          final List<Map<String, Object?>> checks = _maps(t['checks']);
          for (int i = 0; i < checks.length; i++) {
            _expectSameKeys(
              checks[i],
              vm.trial!.checks[i].toJson(),
              '$path SimTrialCheck[$i]',
            );
          }
        }
        if (vm.updateGate != null) {
          _expectSameKeys(
            _map(raw['update_gate'])!,
            vm.updateGate!.toJson(),
            '$path UpdateGateCard',
          );
        }
        final Set<String> keys = _allKeys(raw);
        for (final String bad in <String>[
          'scope',
          'contribution',
          'handover_plan',
          'actions',
          'action',
          'select_action',
          'target',
        ]) {
          expect(keys, isNot(contains(bad)), reason: '$path — 키 $bad');
        }
        expect(
          keys.where((String k) => k.contains('force')),
          isEmpty,
          reason: '$path — 강행 칸 0(K17)',
        );
      }
    });

    test('C-53 ② 넘김 — 전환 요청 결과만 · 등록 라우트 · M5 목적지 2', () {
      final List<ActionResult> results = <ActionResult>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m9OperationsActionResults,
        ))
          ActionResult.fromJson(r),
      ];
      for (final ActionResult r in results) {
        final bool isSwitch =
            r.id == SettingsActionId.runtimeModeSwitchRequest ||
            r.id == SettingsActionId.runtimeOperatingModeSwitchRequest;
        expect(r.handoffRoute != null, isSwitch, reason: r.actionRunId);
        if (r.handoffRoute != null) {
          expect(
            <String>{AppRoutes.m5HandoverWizard, AppRoutes.m5HandoverGate},
            contains(r.handoffRoute),
            reason: r.actionRunId,
          );
          expect(AppRoutes.isRegistered(r.handoffRoute!), isTrue);
        }
      }
    });

    test('C-53 ③ 글자 — DRY_RUN·손익 낱말·금액 0 · hold 모드 카드 «모의» 0', () {
      final List<String> bad = <String>[
        for (final String path in _all)
          for (final String s in _strings(_env(path)['rows']))
            if (s.contains('DRY_RUN') ||
                _pnlWords.any(s.contains) ||
                _money.hasMatch(s))
              '$path: $s',
      ];
      expect(bad, isEmpty);
      final RunModeCard hold = _ops(FixturePaths.m9OperationsLiveHoldKeys).mode;
      expect(hold.holdLabel, isNotNull);
      for (final String s in <String>[hold.label, hold.holdLabel!]) {
        expect(s.contains('모의'), isFalse, reason: 'hold 를 모의로 그린다: $s');
      }
    });

    test('C-53 ④ 동작 호출 — 자리마다 id·args 화이트리스트 · 값 사전 · 같은 값 전환 0', () {
      final Set<String> runModes = RunMode.values
          .map((RunMode m) => m.wire)
          .toSet();
      final Set<String> opModes = OperatingMode.values
          .map((OperatingMode m) => m.wire)
          .toSet();
      int switches = 0;
      int opSwitches = 0;
      int starts = 0;
      int stops = 0;
      int promotions = 0;
      for (final String path in _vms) {
        final OperationsVm vm = _ops(path);
        for (final SettingsActionCall a in vm.mode.switchActions) {
          _expectCall(a, SettingsActionId.runtimeModeSwitchRequest, <String>{
            'run_mode',
          }, '$path mode.switch');
          expect(runModes, contains(a.args['run_mode']), reason: path);
          switches++;
        }
        for (final SettingsActionCall a in vm.operatingMode.switchActions) {
          _expectCall(
            a,
            SettingsActionId.runtimeOperatingModeSwitchRequest,
            <String>{'operating_mode'},
            '$path operating_mode.switch',
          );
          expect(opModes, contains(a.args['operating_mode']), reason: path);
          expect(
            a.args['operating_mode'],
            isNot(vm.operatingMode.current.wire),
            reason: '$path — 같은 값 전환',
          );
          opSwitches++;
        }
        if (vm.control.startAction != null) {
          _expectCall(
            vm.control.startAction!,
            SettingsActionId.runtimeEngineStart,
            <String>{},
            '$path start',
          );
          starts++;
        }
        final List<String> reasons = <String>[];
        for (final SettingsActionCall a in vm.control.stopActions) {
          _expectCall(a, SettingsActionId.runtimeEngineStop, <String>{
            'reason_code',
          }, '$path stop');
          expect(
            EngineStopReasonCodes.values,
            contains(a.args['reason_code']),
            reason: path,
          );
          reasons.add(a.args['reason_code']!);
          stops++;
        }
        expect(reasons.toSet(), hasLength(reasons.length), reason: path);
        if (vm.mode.promotionAction != null) {
          _expectCall(
            vm.mode.promotionAction!,
            SettingsActionId.runtimeLivePromotion,
            <String>{},
            '$path promotion',
          );
          promotions++;
        }
      }
      // 자리마다 표본이 있다(«입력 없이 통과» 방지).
      expect(switches, greaterThan(0));
      expect(opSwitches, greaterThan(0));
      expect(starts, greaterThan(0));
      expect(stops, greaterThan(0));
      expect(promotions, greaterThan(0));
    });

    test('C-53 ⑤ 고지 짝 — switchNoticeText ⇔ switchActions 비지 않음', () {
      for (final String path in _vms) {
        final RunModeCard m = _ops(path).mode;
        expect(
          m.switchNoticeText != null,
          m.switchActions.isNotEmpty,
          reason: path,
        );
      }
    });

    test('C-53 ⑥ 엔진 제어 — 잠김 밖 시작 xor 중지 · 중지 ⇔ 머리말 · 사유 전수', () {
      for (final String path in _vms) {
        final OperationsVm vm = _ops(path);
        final EngineControl c = vm.control;
        expect(
          c.stopActions.isNotEmpty,
          c.stopPromptText != null,
          reason: path,
        );
        if (vm.lockedLabel == null) {
          expect(
            (c.startAction != null) != c.stopActions.isNotEmpty,
            isTrue,
            reason: '$path — 시작 xor 중지',
          );
        }
      }
      final EngineControl run = _ops(FixturePaths.m9OperationsSimAuto).control;
      expect(
        run.stopActions
            .map((SettingsActionCall a) => a.args['reason_code'])
            .toSet(),
        EngineStopReasonCodes.values,
      );
      final EngineControl stopped = _ops(FixturePaths.m9OperationsLiveHoldKeys)
          .control;
      expect(stopped.startAction, isNotNull);
      expect(stopped.stopActions, isEmpty);
    });

    test('C-53 ⑦ 잠김 — 동작 칸 5 비움 · 그 밖 = live_promotable · 다른 표본 null', () {
      final OperationsVm locked = _ops(FixturePaths.m9OperationsLocked);
      expect(locked.lockedLabel, isNotNull);
      expect(locked.mode.switchActions, isEmpty);
      expect(locked.mode.promotionAction, isNull);
      expect(locked.operatingMode.switchActions, isEmpty);
      expect(locked.control.startAction, isNull);
      expect(locked.control.stopActions, isEmpty);
      expect(locked.control.stopPromptText, isNull);

      Map<String, Object?> stripped(String path) {
        final Map<String, Object?> vm =
            jsonDecode(jsonEncode(_vm(path))) as Map<String, Object?>;
        final Map<String, Object?> mode = _map(vm['mode'])!;
        final Map<String, Object?> op = _map(vm['operating_mode'])!;
        final Map<String, Object?> control = _map(vm['control'])!;
        mode
          ..remove('switch_actions')
          ..remove('promotion_action');
        op.remove('switch_actions');
        control
          ..remove('start_action')
          ..remove('stop_actions')
          ..remove('stop_prompt_text');
        vm.remove('locked_label');
        return vm;
      }

      expect(
        jsonEncode(stripped(FixturePaths.m9OperationsLocked)),
        jsonEncode(stripped(FixturePaths.m9OperationsLivePromotable)),
      );
      for (final String path in _vms) {
        if (path == FixturePaths.m9OperationsLocked) continue;
        expect(_ops(path).lockedLabel, isNull, reason: path);
      }
    });

    test('C-53 ⑧ 관찰·승격 — 관찰 ⇔ 칩 승격 줄 · 승격 버튼 ⇒ 승격 가능', () {
      for (final String path in _vms) {
        final OperationsVm vm = _ops(path);
        expect(
          vm.mode.observation != null,
          vm.statusChip.promotionLabel != null,
          reason: path,
        );
        if (vm.mode.promotionAction != null) {
          expect(vm.mode.observation?.promotionAvailable, isTrue, reason: path);
        }
      }
      final OperationsVm observe = _ops(FixturePaths.m9OperationsLiveObserve);
      expect(observe.mode.observation!.promotionAvailable, isFalse);
      expect(observe.mode.promotionAction, isNull);
      final OperationsVm promo = _ops(FixturePaths.m9OperationsLivePromotable);
      expect(promo.mode.observation!.promotionAvailable, isTrue);
      expect(promo.mode.promotionAction, isNotNull);
    });

    test('C-53 ⑨ 체험 — SIM 두 벌만 · 엔진 차례 · 사전 · 짝 · 실패색 0 · 전수', () {
      for (final String path in _vms) {
        final SimTrialCard? t = _ops(path).trial;
        final bool sim =
            path == FixturePaths.m9OperationsSimAuto ||
            path == FixturePaths.m9OperationsSimComplete;
        expect(t != null, sim, reason: path);
        if (t == null) continue;
        expect(t.checks, isNotEmpty, reason: path);
        final List<String> codes = t.checks
            .map((SimTrialCheck c) => c.itemCode)
            .toList();
        expect(codes.toSet(), hasLength(codes.length), reason: path);
        expect(codes, _engineTrialOrder, reason: '$path — 엔진 차례');
        for (final SimTrialCheck c in t.checks) {
          expect(SimTrialItemCodes.values, contains(c.itemCode));
          expect(SimTrialItemStateCodes.values, contains(c.itemState));
          expect(
            c.level,
            _trialLevel[c.itemState],
            reason: '$path ${c.itemCode}',
          );
          expect(
            <UiLevel>{UiLevel.act, UiLevel.blocked},
            isNot(contains(c.level)),
            reason: '$path ${c.itemCode} — 체험 미충족은 실패가 아니다',
          );
        }
      }
      expect(
        _ops(FixturePaths.m9OperationsSimAuto).trial!.checks
            .map((SimTrialCheck c) => c.itemState)
            .toSet(),
        SimTrialItemStateCodes.values,
      );
      expect(
        _ops(FixturePaths.m9OperationsSimComplete).trial!.checks.every(
          (SimTrialCheck c) => c.itemState == SimTrialItemStateCodes.passed,
        ),
        isTrue,
      );
    });

    test('C-53 ⑩ 잡 — 상태 5값 · 짝 · 행 ≥ 1 · sim_auto 전수 + FAILED 두 색', () {
      for (final String path in _vms) {
        final List<JobRow> jobs = _ops(path).jobs;
        expect(jobs, isNotEmpty, reason: path);
        for (final JobRow j in jobs) {
          expect(_jobLevels.keys, contains(j.statusCode), reason: path);
          expect(
            _jobLevels[j.statusCode],
            contains(j.level),
            reason: '$path ${j.statusCode}',
          );
        }
      }
      final List<JobRow> sa = _ops(FixturePaths.m9OperationsSimAuto).jobs;
      expect(
        sa.map((JobRow j) => j.statusCode).toSet(),
        _jobLevels.keys.toSet(),
      );
      expect(
        sa
            .where((JobRow j) => j.statusCode == 'FAILED')
            .map((JobRow j) => j.level)
            .toSet(),
        <UiLevel>{UiLevel.act, UiLevel.blocked},
      );
    });

    test('C-53 ⑪ 램프 — 빈 ⇔ 까닭 · 조건 색 · DST ⇒ 정지색 0 · L0 0', () {
      for (final String path in _vms) {
        final RampBoard r = _ops(path).ramp;
        expect(r.conditions.isEmpty, r.emptyLabel != null, reason: path);
        for (final RampCondition c in r.conditions) {
          expect(
            <UiLevel>{UiLevel.ok, UiLevel.info, UiLevel.watch},
            contains(c.level),
            reason: path,
          );
        }
        if (r.dstNoticeText != null) {
          expect(
            <UiLevel>{UiLevel.act, UiLevel.blocked},
            isNot(contains(r.level)),
            reason: '$path — DST 표식을 정지로 그린다',
          );
        }
        expect(r.levelLabel.contains('L0'), isFalse, reason: path);
      }
      expect(
        _ops(FixturePaths.m9OperationsLiveHoldKeys).ramp.dstNoticeText,
        isNotNull,
      );
      for (final String path in <String>[
        FixturePaths.m9OperationsSimAuto,
        FixturePaths.m9OperationsSimComplete,
      ]) {
        expect(_ops(path).ramp.conditions, isEmpty, reason: path);
      }
      expect(
        _ops(FixturePaths.m9OperationsLiveObserve).ramp.conditions,
        isNotEmpty,
      );
    });

    test('C-53 ⑫ 동작 결과 — 13행 · 레벨 5값 · 사전 · 새 코드 전수 · 재시도 0 · id 5 전수', () {
      final List<ActionResult> results = <ActionResult>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m9OperationsActionResults,
        ))
          ActionResult.fromJson(r),
      ];
      expect(results, hasLength(13));
      expect(
        results.map((ActionResult r) => r.level).toSet(),
        UiLevel.values.toSet(),
      );
      final Set<String?> allowed = <String?>{
        ...SettingsResultCodes.values,
        ...ModeStartupCodes.values,
        ...LiveObservationBlockCodes.values,
        ...LivePromotionResultCodes.values,
        AdviceRejectCodes.modeCombinationDenied,
        null,
      };
      final Set<String?> codes = results
          .map((ActionResult r) => r.reasonCode)
          .toSet();
      expect(allowed.containsAll(codes), isTrue, reason: '$codes');
      expect(
        codes.containsAll(<String>{
          SettingsResultCodes.engineAlreadyRunning,
          SettingsResultCodes.engineAlreadyStopped,
          ...ModeStartupCodes.values,
          LiveObservationBlockCodes.notEnoughDays,
          LivePromotionResultCodes.notObserving,
        }),
        isTrue,
        reason: '새 코드 전수',
      );
      for (final ActionResult r in results) {
        expect(r.retryable, isFalse, reason: r.actionRunId);
      }
      expect(results.map((ActionResult r) => r.id).toSet(), _s05Ids);
    });

    test('C-53 ⑬ E15i 등재형 — 엔진 글자 그대로 · 한 벌 · byDomain 7', () {
      expect(SimTrialItemCodes.values, _engineTrialOrder.toSet());
      expect(SimTrialItemStateCodes.values, <String>{
        'PASSED',
        'AUTO_PASSED',
        'OPEN',
        'OPEN_WARN',
      });
      expect(LiveObservationBlockCodes.values, <String>{
        'LIVE_OBSERVATION_KILL_SWITCH',
        'LIVE_OBSERVATION_TRADING_BLOCK',
        'LIVE_OBSERVATION_UNKNOWN_ORDERS',
        'LIVE_OBSERVATION_NOT_ENOUGH_DAYS',
      });
      expect(ModeStartupCodes.values, <String>{
        'SAF-405',
        'CREDENTIAL_ENV_MISMATCH',
      });
      expect(
        ModeStartupCodes.values,
        isNot(contains(AdviceRejectCodes.modeCombinationDenied)),
      );
      expect(SimOpeningResultCodes.values, <String>{
        'SIM_OPENING_NOT_POSITIVE',
        'SIM_OPENING_NOT_WHOLE_WON',
        'SIM_OPENING_ACCOUNT_UNMAPPED',
        'SIM_OPENING_LINES_NOT_ALLOWED',
        'SIM_OPENING_WRONG_PURPOSE',
        'SIM_OPENING_ALREADY_DECLARED',
        'SIM_OPENING_NOT_DECLARED',
        'ONBOARDING_CHOICE_MISSING',
        'SIM_OPENING_ADVISORY_NOT_READY',
        'TIER_B_CARD_MISSING',
      });
      // 🔵 v1.39(01 §48 K346) — +1 `LIVE_PROMOTION_CONFIG_UNAVAILABLE`(전량 고정 = C-72 ⑦).
      expect(
        LivePromotionResultCodes.values,
        containsAll(<String>{
          'HANDOVER_SESSION_INVALID',
          'LIVE_PROMOTION_NOT_OBSERVING',
          'LIVE_PROMOTION_NOT_AUTO_TRADE',
          'LIVE_PROMOTION_CLOCK_BEHIND',
          'LIVE_PROMOTION_ROLLED_BACK',
        }),
      );
      expect(
        LivePromotionResultCodes.values,
        isNot(contains(SettingsResultCodes.biometricUnavailable)),
      );
      expect(DecisionReasonCodes.livePromotion, 'LIVE_EXECUTE_PROMOTION');
      expect(
        DecisionReasonCodes.values,
        contains(DecisionReasonCodes.livePromotion),
      );
      expect(EngineStopReasonCodes.values, <String>{
        'PLANNED_MAINTENANCE',
        'TROUBLESHOOTING',
      });
      expect(
        ContractCodes.byDomain.keys,
        containsAll(<String>[
          'engine_stop_reason',
          'sim_trial_item',
          'sim_trial_state',
          'live_observation_block',
          'live_promotion_result',
          'mode_startup',
          'sim_opening_result',
        ]),
      );
    });

    test('C-53 ⑭ hold 칸 — 기본 [] · toJson 에 실린다 · 왕복 · 값 ⊆ SafetyHoldCodes', () {
      final List<SafetyState> states = <SafetyState>[
        for (final Map<String, Object?> r in _rows(FixturePaths.safetyStates))
          SafetyState.fromJson(r),
      ];
      expect(states, isNotEmpty);
      for (final SafetyState s in states) {
        expect(s.holds, isEmpty);
        expect(s.toJson().containsKey('holds'), isTrue);
      }
      final SafetyState held = states.first.copyWith(
        holds: <String>[SafetyHoldCodes.liveAwaitingKeys],
      );
      final SafetyState back = SafetyState.fromJson(
        jsonDecode(jsonEncode(held.toJson())) as Map<String, dynamic>,
      );
      expect(back, held);
      expect(SafetyHoldCodes.values.containsAll(back.holds), isTrue);
    });

    test(
      'C-53 ⑮ 받침대 — UnimplementedSettingsRepository.watchOperations 는 동기로 던진다',
      () {
        expect(
          () => UnimplementedSettingsRepository().watchOperations(),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });
}
