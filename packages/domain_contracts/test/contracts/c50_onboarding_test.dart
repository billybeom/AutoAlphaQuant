// C-50 온보딩 VM·동작·결과·페어링 — 01 §25(🆕 계약 v1.16 · R15 선행 · 발주자 결정 2026-11-03 ①~④).
//
// 정의: 「온보딩 7화면은 엔진이 완성한 한 화면 VM 으로 온다(asOf 칸 0 · 모르는 id 도 값) — 갈래·기본값·«다음»·
//        열림·분기·시작 동작은 전부 엔진이 정해서 싣고, 동작은 화이트리스트 안의 id·args 로 완성돼 오며,
//        결과는 접수/거부(원문 코드)·재시도를 데이터로 갈라 싣고, 🔒 자리는 슬롯 이름만 싣는다」.
//   ① 허용 키 ② O-00 갈래 ③ O-00b 기본값 없음 ④ 낱말 ⑤ 선택 결과 ⑥ 단계 행(전 픽스처) ⑦ O-01 목록
//   ⑧ O-02 상세 ⑨ 동작 화이트리스트(전 픽스처) ⑩ 검증 결과 ⑪ O-04 6단계 ⑫ O-04 결과 ⑬ R-01 ⑭ V-01
//   ⑮ 슬롯 이름(전 픽스처) ⑯ 받침대.
//
// 🔴 픽스처 불변식만 본다 — `ui_shell` 화면 스캔은 R15 카드 정적 묶음 몫(01 §8 미결 144).
// 🔴 한국어 글자 단언 0 — 상수 리터럴 = 표본 id·키 이름·코드·라우트 상수뿐(④ 의 «권장»·«추천» 두 낱말만 예외).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

const List<String> _starts = <String>[
  FixturePaths.m8OnboardingStart,
  FixturePaths.m8OnboardingStartNoViewer,
];

const List<String> _modes = <String>[
  FixturePaths.m8OnboardingModeUnselected,
  FixturePaths.m8OnboardingModeAuto,
  FixturePaths.m8OnboardingModeAdvisory,
  FixturePaths.m8OnboardingModeLocked,
];

const List<String> _steps = <String>[
  FixturePaths.m8OnboardingStepsFresh,
  FixturePaths.m8OnboardingStepsAdvisory,
  FixturePaths.m8OnboardingStepsFinishReady,
  FixturePaths.m8OnboardingStepsFinishReadyWarn,
  FixturePaths.m8OnboardingStepsAllVerifiedLocked,
  FixturePaths.m8OnboardingStepsEmpty,
];

const List<String> _details = <String>[
  FixturePaths.m8OnboardingStepDetailKisMock,
  FixturePaths.m8OnboardingStepDetailNoVerify,
  FixturePaths.m8OnboardingStepDetailMissing,
];

const List<String> _finishes = <String>[
  FixturePaths.m8OnboardingFinishAuto,
  FixturePaths.m8OnboardingFinishAutoReady,
  FixturePaths.m8OnboardingFinishAutoDeclared,
  FixturePaths.m8OnboardingFinishAdvisory,
  FixturePaths.m8OnboardingFinishAdvisoryDeclared,
  FixturePaths.m8OnboardingFinishNoExpectation,
  FixturePaths.m8OnboardingFinishDone,
];

const List<String> _restarts = <String>[
  FixturePaths.m8RestartVmLostPhone,
  FixturePaths.m8RestartVmLoggedOut,
  FixturePaths.m8RestartVmGap7,
  FixturePaths.m8RestartVmUnknown,
];

const List<String> _pairings = <String>[
  FixturePaths.m8PairingWaiting,
  FixturePaths.m8PairingOk,
  FixturePaths.m8PairingFail,
];

const List<String> _results = <String>[
  FixturePaths.m8OnboardingModeSelectResults,
  FixturePaths.m8OnboardingVerifyResults,
  FixturePaths.m8OnboardingFinishResults,
];

/// v1.16 신설 32(⑥ 의 «신설 표본 한정» 단언 · ④ 의 R15a 7).
const List<String> _newFixtures = <String>[
  ..._starts,
  ..._modes,
  ..._steps,
  ..._details,
  ..._finishes,
  ..._restarts,
  ..._pairings,
  ..._results,
];

const List<String> _r15a = <String>[
  ..._starts,
  ..._modes,
  FixturePaths.m8OnboardingModeSelectResults,
];

const Set<String> _startKeys = <String>{'headline', 'tracks', 'viewer_track'};
const Set<String> _trackKeys = <String>{
  'track',
  'title',
  'estimated_text',
  'deep_link',
};
const Set<String> _modeKeys = <String>{
  'headline',
  'options',
  'selected',
  'record_gap_notice',
  'honesty_text',
  'next_deep_link',
  'locked_label',
};
const Set<String> _stepsKeys = <String>{
  'progress_text',
  'rows',
  'empty_label',
  'finish_deep_link',
};
const Set<String> _detailKeys = <String>{
  'step',
  'missing_label',
  'where_text',
  'how_text',
  'verify',
  'secret_slot_id',
};
const Set<String> _actionKeys = <String>{'id', 'args', 'label'};
const Set<String> _finishKeys = <String>{
  'headline',
  'stages',
  'done_label',
  'checks',
};
const Set<String> _stageKeys = <String>{
  'title',
  'state',
  'gate',
  'lines',
  'expectation_line',
  'slot_id',
  'link',
  'action',
};
const Set<String> _checkKeys = <String>{'label', 'state'};
const Set<String> _restartKeys = <String>{
  'headline',
  'login_slot_id',
  'ledger_lines',
  'lease_gate',
  'branches',
  'inherit_notice',
};
const Set<String> _pairingKeys = <String>{
  'headline',
  'scanner_slot_id',
  'result',
};
const Set<String> _pairingResultKeys = <String>{
  'level',
  'headline',
  'reason_code',
  'next_link',
};

/// `OnboardingStep` 기존 13 + 🆕 v1.16 6.
const Set<String> _stepKeys = <String>{
  'step_id',
  'track',
  'order',
  'title',
  'why_line',
  'where_deep_link',
  'estimated_seconds',
  'estimated_text',
  'requirement',
  'state',
  'verification_label',
  'verified_until',
  'failure_reason_code',
  'requirement_label',
  'warning_label',
  'verified_until_text',
  'failure_text',
  'gate',
  'detail_deep_link',
};

/// K28 — 엔진 의무 `stepId` 꼴 · 고정 조각 6 과 겹치지 않는다.
final RegExp _stepIdShape = RegExp(r'^[orv]_[0-9]{2}[a-z]?$');
const Set<String> _fixedSegments = <String>{
  'start',
  'mode',
  'steps',
  'finish',
  'restart',
  'pairing',
};

/// K13 · K19 · K24 — 온보딩 동작 args 화이트리스트(`settings_actions.dart` 머리).
const Map<String, Set<String>> _argsWhitelist = <String, Set<String>>{
  'CREDENTIAL_VERIFY': <String>{'kind'},
  'CONNECTION_TEST': <String>{'target'},
  // 🆕 v1.31(01 §40 · K239) — o_07 ③ 로그인(값 = 슬롯 ↔ 구현 사이만).
  'SUPABASE_SIGN_IN': <String>{},
  'ACCOUNT_VERIFY_MAPPING': <String>{},
  'ONBOARDING_DRY_RUN_START': <String>{},
};

/// K23 — O-04 ②~⑤ 자리 이름(차례 고정).
const List<String> _stageSlots = <String>[
  OnboardingSlotIds.pledgeWrite,
  OnboardingSlotIds.biometricSign,
  OnboardingSlotIds.selftestRun,
  OnboardingSlotIds.recoveryChecksum,
];

final RegExp _recommendWord = RegExp('권장|추천');

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

/// `OnboardingStep` 객체 — `step_id` + `track` + `requirement`(🔴 `HandoverStep`·미확정 주문 단계는 `track` 이 없다).
List<Map<String, Object?>> _stepObjects(Object? node) {
  final List<Map<String, Object?>> out = <Map<String, Object?>>[];
  void visit(Object? n) {
    if (n is Map<String, Object?>) {
      if (n.containsKey('step_id') &&
          n.containsKey('track') &&
          n.containsKey('requirement')) {
        out.add(n);
      }
      n.values.forEach(visit);
    } else if (n is List<Object?>) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// UTC 시각 [iso] 의 KST 날짜(`yyyy-MM-dd` · 숫자만).
String _kstDate(String iso) {
  final DateTime k = DateTime.parse(iso).toUtc().add(const Duration(hours: 9));
  String two(int v) => v.toString().padLeft(2, '0');
  return '${k.year}-${two(k.month)}-${two(k.day)}';
}

/// 링크가 라우트 패턴 [pattern] 과 일치하는가(`AppRoutes.isRegistered` 와 같은 규칙 — 한 패턴만).
bool _matches(String pattern, String link) {
  final List<String> p = pattern.split('/');
  final List<String> l = link.split('/');
  if (p.length != l.length) {
    return false;
  }
  for (int i = 0; i < p.length; i++) {
    if (p[i].startsWith(':')) {
      if (l[i].isEmpty || l[i].contains('?') || l[i].contains('#')) {
        return false;
      }
    } else if (p[i] != l[i]) {
      return false;
    }
  }
  return true;
}

void main() {
  group('C-50 온보딩 VM·동작·결과·페어링 (01 §25 · 계약 v1.16)', () {
    test('C-50 ① 허용 키 — 픽스처 키와 toJson() 키 · VM 에 as_of 0', () {
      for (final String path in _starts) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _startKeys, reason: path);
        expect(
          OnboardingStartVm.fromJson(vm).toJson().keys.toSet(),
          _startKeys,
        );
        final List<Map<String, Object?>> cards = <Map<String, Object?>>[
          ..._maps(vm['tracks']),
          if (vm['viewer_track'] != null) _map(vm['viewer_track'])!,
        ];
        for (final Map<String, Object?> c in cards) {
          expect(c.keys.toSet(), _trackKeys, reason: path);
          expect(
            OnboardingTrackCard.fromJson(c).toJson().keys.toSet(),
            _trackKeys,
          );
        }
      }
      for (final String path in _modes) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _modeKeys, reason: path);
        expect(
          OnboardingModeChoiceVm.fromJson(vm).toJson().keys.toSet(),
          _modeKeys,
        );
      }
      for (final String path in _steps) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _stepsKeys, reason: path);
        expect(
          OnboardingStepsVm.fromJson(vm).toJson().keys.toSet(),
          _stepsKeys,
        );
      }
      for (final String path in _details) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _detailKeys, reason: path);
        expect(
          OnboardingStepDetailVm.fromJson(vm).toJson().keys.toSet(),
          _detailKeys,
        );
        final Map<String, Object?>? verify = _map(vm['verify']);
        if (verify != null) {
          expect(verify.keys.toSet(), _actionKeys, reason: path);
          expect(
            OnboardingAction.fromJson(verify).toJson().keys.toSet(),
            _actionKeys,
          );
        }
      }
      for (final String path in _finishes) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _finishKeys, reason: path);
        expect(
          OnboardingFinishVm.fromJson(vm).toJson().keys.toSet(),
          _finishKeys,
        );
        for (final Map<String, Object?> s in _maps(vm['stages'])) {
          expect(s.keys.toSet(), _stageKeys, reason: path);
          expect(
            OnboardingFinishStage.fromJson(s).toJson().keys.toSet(),
            _stageKeys,
          );
          final Map<String, Object?>? action = _map(s['action']);
          if (action != null) {
            expect(action.keys.toSet(), _actionKeys, reason: path);
          }
        }
        for (final Map<String, Object?> c in _maps(vm['checks'])) {
          expect(c.keys.toSet(), _checkKeys, reason: path);
          expect(
            OnboardingFinishCheck.fromJson(c).toJson().keys.toSet(),
            _checkKeys,
          );
        }
      }
      for (final String path in _restarts) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _restartKeys, reason: path);
        expect(RestartVm.fromJson(vm).toJson().keys.toSet(), _restartKeys);
      }
      for (final String path in _pairings) {
        final Map<String, Object?> vm = _vm(path);
        expect(vm.keys.toSet(), _pairingKeys, reason: path);
        expect(PairingVm.fromJson(vm).toJson().keys.toSet(), _pairingKeys);
        final Map<String, Object?>? result = _map(vm['result']);
        if (result != null) {
          expect(result.keys.toSet(), _pairingResultKeys, reason: path);
          expect(
            PairingResult.fromJson(result).toJson().keys.toSet(),
            _pairingResultKeys,
          );
        }
      }
      int steps = 0;
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> s in _stepObjects(_env(path))) {
          steps++;
          expect(
            _stepKeys.containsAll(s.keys),
            isTrue,
            reason: '$path ${s['step_id']} — 단계 객체에 계약 밖 키가 있다',
          );
          expect(OnboardingStep.fromJson(s).toJson().keys.toSet(), _stepKeys);
        }
      }
      expect(steps, greaterThanOrEqualTo(45 + 34));
      // K10 — VM 에 asOf 칸이 없다(봉투 `as_of` 만).
      for (final String path in <String>[
        ..._starts,
        ..._modes,
        ..._steps,
        ..._details,
        ..._finishes,
        ..._restarts,
        ..._pairings,
      ]) {
        expect(_vm(path).containsKey('as_of'), isFalse, reason: path);
      }
    });

    test('C-50 ② O-00 갈래 — 계정 축 2 · 조회 갈래 한 칸 · 링크 대응', () {
      const Map<String, String> linkOf = <String, String>{
        'FRESH': AppRoutes.onboardingModePick,
        'RECONNECT': AppRoutes.onboardingRestart,
        'VIEWER_PAIRING': AppRoutes.onboardingPairing,
      };
      int noViewer = 0;
      int nullLinks = 0;
      for (final String path in _starts) {
        final OnboardingStartVm vm = OnboardingStartVm.fromJson(_vm(path));
        expect(
          vm.tracks.map((OnboardingTrackCard c) => c.track).toList(),
          <OnboardingTrack>[OnboardingTrack.fresh, OnboardingTrack.reconnect],
          reason: '$path — 계정 축 갈래는 처음·다시 둘(운영 방식은 갈래가 아니다)',
        );
        if (vm.viewerTrack == null) {
          noViewer++;
        } else {
          expect(vm.viewerTrack!.track, OnboardingTrack.viewerPairing);
        }
        for (final OnboardingTrackCard c in <OnboardingTrackCard>[
          ...vm.tracks,
          ?vm.viewerTrack,
        ]) {
          if (c.deepLink == null) {
            nullLinks++;
          } else {
            expect(c.deepLink, linkOf[c.track.wire], reason: '$path $c');
          }
        }
      }
      expect(noViewer, 1);
      expect(nullLinks, greaterThanOrEqualTo(1));
    });

    test('C-50 ③ O-00b 기본값 없음 — 고른 뒤에만 «다음» · 잠금 = 읽기 전용', () {
      final List<Map<String, Object?>> pickOptions = _maps(
        _vm(FixturePaths.m8OnboardingModePick)['options'],
      );
      final Map<OperatingMode, int> picked = <OperatingMode, int>{};
      for (final String path in _modes) {
        final Map<String, Object?> raw = _vm(path);
        expect(raw['options'], pickOptions, reason: '$path — 같은 엔진 산출');
        final OnboardingModeChoiceVm vm = OnboardingModeChoiceVm.fromJson(raw);
        expect(
          vm.options.map((OperatingModeOption o) => o.mode).toList(),
          <OperatingMode>[OperatingMode.autoTrade, OperatingMode.advisory],
          reason: path,
        );
        if (vm.lockedLabel != null) {
          expect(vm.selected, isNotNull, reason: path);
          expect(vm.nextDeepLink, isNull, reason: path);
        } else if (vm.selected != null) {
          expect(vm.nextDeepLink, AppRoutes.onboardingSteps, reason: path);
          picked[vm.selected!] = (picked[vm.selected!] ?? 0) + 1;
        } else {
          expect(vm.nextDeepLink, isNull, reason: path);
        }
      }
      final OnboardingModeChoiceVm unselected = OnboardingModeChoiceVm.fromJson(
        _vm(FixturePaths.m8OnboardingModeUnselected),
      );
      expect(unselected.selected, isNull);
      expect(unselected.nextDeepLink, isNull);
      expect(unselected.lockedLabel, isNull);
      expect(picked, <OperatingMode, int>{
        OperatingMode.autoTrade: 1,
        OperatingMode.advisory: 1,
      });
    });

    test('C-50 ④ 낱말 — O-00·O-00b 표본과 mode_pick 에 «권장»·«추천» 0 · 고지 2칸', () {
      final List<String> bad = <String>[];
      for (final String path in <String>[
        ..._r15a,
        FixturePaths.m8OnboardingModePick,
      ]) {
        final Map<String, Object?> env = _env(path)..remove('meta');
        walkJson(env, (String jsonPath, String key, Object? value) {
          if (value is String && _recommendWord.hasMatch(value)) {
            bad.add('$path $jsonPath');
          }
        });
      }
      expect(bad, isEmpty, reason: '권장 배지·헛경보 낱말이 돌아왔다(04 §9-1b 수용 (c))');
      for (final String path in _modes) {
        final OnboardingModeChoiceVm vm = OnboardingModeChoiceVm.fromJson(
          _vm(path),
        );
        expect(vm.recordGapNotice.trim(), isNotEmpty, reason: path);
        expect(vm.honestyText.trim(), isNotEmpty, reason: path);
      }
    });

    test('C-50 ⑤ 선택 결과 — 접수 · 거부(committed) 갈래가 데이터로 갈린다', () {
      final List<ActionResult> rows = _rows(
        FixturePaths.m8OnboardingModeSelectResults,
      ).map(ActionResult.fromJson).toList();
      expect(rows, hasLength(2));
      for (final ActionResult r in rows) {
        expect(r.id, SettingsActionId.onboardingOperatingModeSelect);
        expect(r.handoffRoute, isNull);
        expect(r.retryable, isFalse);
      }
      expect(rows[0].level, UiLevel.ok);
      expect(rows[0].reasonCode, isNull);
      expect(rows[1].level, UiLevel.blocked);
      expect(rows[1].reasonCode, OnboardingResultCodes.choiceCommitted);
      expect(rows[1].level, isNot(rows[0].level));
    });

    test('C-50 ⑥ 단계 행 — 등급 글자 사전 1벌 · 만료 글자 · 행 링크 · stepId 꼴 (전 픽스처)', () {
      final Map<String, String> labelOf = <String, String>{};
      final List<String> bad = <String>[];
      final Set<String> newPaths = _newFixtures.toSet();
      int newSteps = 0;
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> s in _stepObjects(_env(path))) {
          final String id = s['step_id']! as String;
          final String where = '$path $id';
          final String? label = s['requirement_label'] as String?;
          if (label == null || label.trim().isEmpty) {
            bad.add('$where — requirement_label 비었다');
          } else {
            final String req = s['requirement']! as String;
            final String seen = labelOf.putIfAbsent(req, () => label);
            if (seen != label) {
              bad.add('$where — 같은 등급 다른 글자');
            }
          }
          final Object? until = s['verified_until'];
          final Object? untilText = s['verified_until_text'];
          if (until != null && untilText == null) {
            bad.add('$where — verified_until 만 있고 글자가 없다');
          } else if (until is String &&
              untilText is String &&
              !untilText.startsWith(_kstDate(until))) {
            // 날짜 숫자만 대조한다 — 꼬리 낱말(«까지»·«에 만료됨»)은 엔진 몫.
            bad.add('$where — verified_until_text 날짜 ≠ verified_until(KST)');
          }
          final Object? detail = s['detail_deep_link'];
          if (detail != null && detail != 'aaq://onboarding/$id') {
            bad.add('$where — detail_deep_link ≠ 자기 단계');
          }
          if (!_stepIdShape.hasMatch(id) || _fixedSegments.contains(id)) {
            bad.add('$where — stepId 꼴');
          }
          if (!newPaths.contains(path)) {
            continue;
          }
          newSteps++;
          final OnboardingStep step = OnboardingStep.fromJson(s);
          if (step.failureReasonCode != null && step.failureText == null) {
            bad.add('$where — 원문 코드만 있고 실패 문장이 없다');
          }
          if (step.state == StepState.failed && step.failureText == null) {
            bad.add('$where — FAILED 인데 실패 문장이 없다');
          }
          final bool warn =
              step.requirement == StepRequirement.recommended &&
              step.state != StepState.verified;
          if (warn != (step.warningLabel != null)) {
            bad.add('$where — 경고 배지 ⇔ 권장 ∧ 미검증');
          }
          if (step.whereDeepLink != null) {
            bad.add('$where — 신설 표본 where_deep_link 는 null');
          }
          if (step.gate?.blockedReasonCode != null) {
            bad.add('$where — 게이트 blocked_reason_code 는 null');
          }
        }
      }
      expect(bad, isEmpty);
      expect(labelOf.keys.toSet(), <String>{
        'REQUIRED',
        'RECOMMENDED',
        'OPTIONAL',
      });
      expect(newSteps, greaterThanOrEqualTo(30));
    });

    test('C-50 ⑦ O-01 목록 — 빈 ⇔ 행 0 · «다음» = 필수 통과 ∧ 막는 게이트 0 · 차례', () {
      for (final String path in _steps) {
        final OnboardingStepsVm vm = OnboardingStepsVm.fromJson(_vm(path));
        expect(vm.emptyLabel != null, vm.rows.isEmpty, reason: path);
        expect(
          vm.rows.map((OnboardingStep s) => s.order).toList(),
          List<int>.generate(vm.rows.length, (int i) => i + 1),
          reason: '$path — 엔진 차례 그대로',
        );
        for (final OnboardingStep s in vm.rows) {
          expect(s.stepId, isNot(anyOf('o_00', 'o_04')), reason: path);
          expect(s.title.contains('해외'), isFalse, reason: path);
          expect(s.whyLine.contains('해외'), isFalse, reason: path);
        }
        if (vm.finishDeepLink != null) {
          expect(vm.finishDeepLink, AppRoutes.onboardingFinish, reason: path);
          for (final OnboardingStep s in vm.rows) {
            if (s.requirement == StepRequirement.required_) {
              expect(s.state, StepState.verified, reason: '$path ${s.stepId}');
            }
            expect(
              s.gate == null ||
                  s.gate!.state == GateState.pass ||
                  s.gate!.state == GateState.notApplicable,
              isTrue,
              reason: '$path ${s.stepId} — 막는 게이트가 있는데 «다음»',
            );
          }
        }
      }
      final OnboardingStepsVm fresh = OnboardingStepsVm.fromJson(
        _vm(FixturePaths.m8OnboardingStepsFresh),
      );
      expect(
        fresh.rows.map((OnboardingStep s) => s.state).toSet(),
        StepState.values.toSet(),
      );
      expect(
        fresh.rows
            .where((OnboardingStep s) => s.gate != null)
            .map((OnboardingStep s) => s.gate!.state)
            .toSet(),
        GateState.values.toSet(),
      );
      expect(
        fresh.rows.where((OnboardingStep s) => s.detailDeepLink == null),
        isNotEmpty,
      );
      expect(
        fresh.rows.where((OnboardingStep s) => s.warningLabel != null),
        isNotEmpty,
      );
      expect(fresh.finishDeepLink, isNull);
      final OnboardingStepsVm locked = OnboardingStepsVm.fromJson(
        _vm(FixturePaths.m8OnboardingStepsAllVerifiedLocked),
      );
      expect(
        locked.rows.every((OnboardingStep s) => s.state == StepState.verified),
        isTrue,
      );
      expect(locked.finishDeepLink, isNull);
      expect(
        locked.rows.where(
          (OnboardingStep s) => s.gate?.state == GateState.unknown,
        ),
        isNotEmpty,
      );
      final OnboardingStepsVm warn = OnboardingStepsVm.fromJson(
        _vm(FixturePaths.m8OnboardingStepsFinishReadyWarn),
      );
      expect(warn.finishDeepLink, isNotNull);
      expect(
        warn.rows.where((OnboardingStep s) => s.warningLabel != null),
        isNotEmpty,
      );
    });

    test('C-50 ⑧ O-02 상세 — step XOR missing · 목록과 같은 객체 · 동작·자리 부재 갈래', () {
      final Map<String, Map<String, Object?>> freshById =
          <String, Map<String, Object?>>{
            for (final Map<String, Object?> s in _maps(
              _vm(FixturePaths.m8OnboardingStepsFresh)['rows'],
            ))
              s['step_id']! as String: s,
          };
      for (final String path in _details) {
        final Map<String, Object?> raw = _vm(path);
        final OnboardingStepDetailVm vm = OnboardingStepDetailVm.fromJson(raw);
        expect(vm.step == null, vm.missingLabel != null, reason: path);
        if (vm.step == null) {
          expect(vm.whereText, isNull, reason: path);
          expect(vm.howText, isNull, reason: path);
          expect(vm.verify, isNull, reason: path);
          expect(vm.secretSlotId, isNull, reason: path);
        } else {
          final Map<String, Object?> step = _map(raw['step'])!;
          expect(step, freshById[step['step_id']], reason: '$path — 두 원천');
        }
      }
      final OnboardingStepDetailVm kis = OnboardingStepDetailVm.fromJson(
        _vm(FixturePaths.m8OnboardingStepDetailKisMock),
      );
      expect(kis.verify, isNotNull);
      expect(kis.secretSlotId, isNotNull);
      final OnboardingStepDetailVm noVerify = OnboardingStepDetailVm.fromJson(
        _vm(FixturePaths.m8OnboardingStepDetailNoVerify),
      );
      expect(noVerify.verify, isNull);
      expect(noVerify.secretSlotId, isNull);
    });

    test('C-50 ⑨ 동작 화이트리스트 — id·args 는 엔진이 완성한다 (전 픽스처)', () {
      final List<String> bad = <String>[];
      int verifies = 0;
      int actions = 0;
      for (final String path in FixturePaths.all) {
        walkJson(_env(path), (String jsonPath, String key, Object? value) {
          if ((key != 'verify' && key != 'action') ||
              value is! Map<String, Object?>) {
            return;
          }
          final OnboardingAction a = OnboardingAction.fromJson(value);
          final Set<String>? allowed = _argsWhitelist[a.id.wire];
          if (allowed == null) {
            bad.add('$path $jsonPath — 화이트리스트 밖 id ${a.id.wire}');
            return;
          }
          if (!allowed.containsAll(a.args.keys)) {
            bad.add('$path $jsonPath — args 키 ${a.args.keys}');
          }
          if (a.label.trim().isEmpty) {
            bad.add('$path $jsonPath — 버튼 글자 비었다');
          }
          if (key == 'verify') {
            verifies++;
            if (a.id == SettingsActionId.onboardingDryRunStart) {
              bad.add('$path $jsonPath — 검증 자리에 DRY_RUN');
            }
          } else {
            actions++;
            if (a.id != SettingsActionId.onboardingDryRunStart) {
              bad.add('$path $jsonPath — 마무리 동작은 DRY_RUN 하나');
            }
          }
        });
      }
      expect(bad, isEmpty);
      expect(verifies, greaterThanOrEqualTo(1));
      expect(actions, greaterThanOrEqualTo(2));
    });

    test('C-50 ⑩ 검증 결과 — 성공 · 원문 코드 재시도 · 앱 코드 거절', () {
      final List<ActionResult> rows = _rows(
        FixturePaths.m8OnboardingVerifyResults,
      ).map(ActionResult.fromJson).toList();
      expect(rows, hasLength(3));
      for (final ActionResult r in rows) {
        expect(r.id, SettingsActionId.credentialVerify);
        expect(r.handoffRoute, isNull);
      }
      expect(rows[0].level, UiLevel.ok);
      expect(rows[0].reasonCode, isNull);
      expect(rows[0].retryable, isFalse);
      expect(rows[1].level, UiLevel.blocked);
      expect(BrokerRawCodes.values, contains(rows[1].reasonCode));
      expect(rows[1].retryable, isTrue);
      expect(rows[2].level, UiLevel.blocked);
      expect(OnboardingResultCodes.values, contains(rows[2].reasonCode));
      expect(rows[2].retryable, isFalse);
    });

    test('C-50 ⑪ O-04 6단계 — 칸은 단계 객체가 싣는다 · 건너뛰기·선언 우회 0', () {
      for (final String path in _finishes) {
        final OnboardingFinishVm vm = OnboardingFinishVm.fromJson(_vm(path));
        final List<OnboardingFinishStage> st = vm.stages;
        expect(st, hasLength(6), reason: path);
        for (int i = 0; i < st.length; i++) {
          if (i != 0) {
            expect(st[i].expectationLine, isNull, reason: '$path [$i]');
          }
          if (st[i].slotId != null) {
            expect(i, inInclusiveRange(1, 4), reason: '$path [$i]');
            expect(st[i].slotId, _stageSlots[i - 1], reason: '$path [$i]');
            // 칸은 열린 단계에만 — 마친(VERIFIED) 단계 · 닫힌(게이트 PASS 밖) 단계 = null.
            expect(
              st[i].state,
              isNot(StepState.verified),
              reason: '$path [$i] — 마친 단계에 칸',
            );
            expect(
              st[i].gate == null || st[i].gate!.state == GateState.pass,
              isTrue,
              reason: '$path [$i] — 닫힌 단계에 칸',
            );
          }
          if (i != 5) {
            expect(st[i].link, isNull, reason: '$path [$i]');
            expect(st[i].action, isNull, reason: '$path [$i]');
          }
        }
        final OnboardingFinishStage six = st[5];
        if (six.link != null) {
          expect(six.action, isNull, reason: '$path — 선언 전 = 시작 못함');
          final String pattern = path.contains('advisory')
              ? AppRoutes.ledgerSimOpening
              : AppRoutes.m5SimOpeningCash;
          expect(
            _matches(pattern, six.link!.deepLink),
            isTrue,
            reason: '$path ${six.link!.deepLink}',
          );
        }
        if (six.action != null) {
          expect(six.link, isNull, reason: path);
          expect(six.action!.id, SettingsActionId.onboardingDryRunStart);
          for (int i = 0; i < 5; i++) {
            expect(st[i].state, StepState.verified, reason: '$path [$i]');
          }
        }
        expect(vm.doneLabel != null, vm.checks.isNotEmpty, reason: path);
        if (vm.doneLabel != null) {
          for (final OnboardingFinishStage s in st) {
            expect(s.state, StepState.verified, reason: path);
            expect(s.link, isNull, reason: path);
            expect(s.action, isNull, reason: path);
            expect(s.slotId, isNull, reason: path);
          }
        }
      }
      final OnboardingFinishVm noExp = OnboardingFinishVm.fromJson(
        _vm(FixturePaths.m8OnboardingFinishNoExpectation),
      );
      expect(noExp.stages[0].expectationLine, isNull);
      final OnboardingFinishVm auto = OnboardingFinishVm.fromJson(
        _vm(FixturePaths.m8OnboardingFinishAuto),
      );
      final Set<GateState> closed = <GateState>{};
      for (final OnboardingFinishStage s in auto.stages) {
        if (s.slotId == null && s.state != StepState.verified) {
          expect(s.gate, isNotNull, reason: '${s.title} — 닫힌 단계는 게이트로 이유');
          closed.add(s.gate!.state);
        }
      }
      expect(closed, <GateState>{
        GateState.block,
        GateState.unknown,
        GateState.notApplicable,
      });
      int links = 0;
      int actions = 0;
      for (final String path in _finishes) {
        final OnboardingFinishStage six = OnboardingFinishVm.fromJson(_vm(path))
            .stages[5];
        if (six.link != null) {
          links++;
        }
        if (six.action != null) {
          actions++;
        }
      }
      expect(links, 2);
      expect(actions, 2);
    });

    test('C-50 ⑫ O-04 결과 — 접수 · 되돌림', () {
      final List<ActionResult> rows = _rows(
        FixturePaths.m8OnboardingFinishResults,
      ).map(ActionResult.fromJson).toList();
      expect(rows, hasLength(2));
      for (final ActionResult r in rows) {
        expect(r.id, SettingsActionId.onboardingDryRunStart);
        expect(r.handoffRoute, isNull);
        expect(r.retryable, isFalse);
      }
      expect(rows[0].level, UiLevel.ok);
      expect(rows[0].reasonCode, isNull);
      expect(rows[1].level, UiLevel.blocked);
      expect(rows[1].reasonCode, OnboardingResultCodes.dryRunStartRolledBack);
    });

    test('C-50 ⑬ R-01 — 로그인 → 원장 → 분기 차례 · 모름 = 분기 0 · 승계 고지', () {
      const Set<String> allowed = <String>{
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
        AppRoutes.onboardingModePick,
      };
      final Set<GateState> leases = <GateState>{};
      for (final String path in _restarts) {
        final RestartVm vm = RestartVm.fromJson(_vm(path));
        if (vm.loginSlotId != null) {
          expect(vm.ledgerLines, isNull, reason: path);
          expect(vm.leaseGate, isNull, reason: path);
          expect(vm.branches, isEmpty, reason: path);
          expect(vm.inheritNotice, isNull, reason: path);
        }
        if (vm.leaseGate != null) {
          leases.add(vm.leaseGate!.state);
          if (vm.leaseGate!.state == GateState.unknown) {
            expect(vm.branches, isEmpty, reason: '$path — 모름 = 진행 차단');
          }
        }
        if (vm.branches.isNotEmpty) {
          expect(vm.inheritNotice, isNotNull, reason: path);
        }
        for (final LinkAction b in vm.branches) {
          expect(allowed, contains(b.deepLink), reason: path);
        }
      }
      expect(leases, <GateState>{
        GateState.pass,
        GateState.block,
        GateState.unknown,
      });
      final RestartVm lost = RestartVm.fromJson(
        _vm(FixturePaths.m8RestartVmLostPhone),
      );
      expect(lost.branches.map((LinkAction b) => b.deepLink).toList(), <String>[
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
      ]);
      final RestartVm gap7 = RestartVm.fromJson(
        _vm(FixturePaths.m8RestartVmGap7),
      );
      // 🆕 v1.39(01 §48 K349 ⑤) — 옛 폰 회수(비상 이전) 뒤에만 첫 클레임이 선다 → 분기 = 비상 이전 먼저(13 R267 L1 · L3).
      expect(gap7.branches.map((LinkAction b) => b.deepLink).toList(), <String>[
        AppRoutes.x1MigrationEmergency,
      ]);
      expect(gap7.leaseGate!.state, GateState.block);
    });

    test('C-50 ⑭ V-01 — 대기 = 스캐너 자리 · 성공 ⇔ 다음 링크 · 실패 = 원문 코드', () {
      final Map<String, int> kinds = <String, int>{};
      for (final String path in _pairings) {
        final PairingVm vm = PairingVm.fromJson(_vm(path));
        final PairingResult? r = vm.result;
        if (r == null) {
          expect(vm.scannerSlotId, isNotNull, reason: path);
          kinds['waiting'] = (kinds['waiting'] ?? 0) + 1;
          continue;
        }
        expect(r.level == UiLevel.ok, r.nextLink != null, reason: path);
        if (r.level == UiLevel.ok) {
          expect(vm.scannerSlotId, isNull, reason: path);
          expect(r.reasonCode, isNull, reason: path);
          kinds['ok'] = (kinds['ok'] ?? 0) + 1;
        } else {
          expect(OnboardingResultCodes.values, contains(r.reasonCode));
          kinds['fail'] = (kinds['fail'] ?? 0) + 1;
        }
      }
      expect(kinds, <String, int>{'waiting': 1, 'ok': 1, 'fail': 1});
      final PairingVm fail = PairingVm.fromJson(
        _vm(FixturePaths.m8PairingFail),
      );
      expect(
        fail.result!.reasonCode,
        OnboardingResultCodes.pairingTokenRevoked,
      );
    });

    test('C-50 ⑮ 슬롯 이름 — 자리에 맞는 이름 (전 픽스처)', () {
      final List<String> bad = <String>[];
      final Map<String, int> seen = <String, int>{};
      for (final String path in FixturePaths.all) {
        walkJson(_env(path), (String jsonPath, String key, Object? value) {
          if (value is! String) {
            return;
          }
          final bool ok;
          switch (key) {
            case 'secret_slot_id':
              ok = value.startsWith('SECRET_');
            case 'login_slot_id':
              ok = value == OnboardingSlotIds.recoveryLogin;
            case 'scanner_slot_id':
              ok = value == OnboardingSlotIds.viewerQrScan;
            case 'slot_id':
              ok = _stageSlots.contains(value);
            default:
              return;
          }
          seen[key] = (seen[key] ?? 0) + 1;
          if (!ok || !OnboardingSlotIds.values.contains(value)) {
            bad.add('$path $jsonPath = $value');
          }
        });
      }
      expect(bad, isEmpty);
      expect(seen.keys.toSet(), <String>{
        'secret_slot_id',
        'login_slot_id',
        'scanner_slot_id',
        'slot_id',
      });
    });

    test('C-50 ⑯ 받침대 — 값을 지어내지 않는다(동기 throw)', () {
      final UnimplementedOnboardingRepository onboarding =
          UnimplementedOnboardingRepository();
      final Matcher throwsUnimpl = throwsA(isA<UnimplementedError>());
      expect(() => onboarding.watchSteps(OnboardingTrack.fresh), throwsUnimpl);
      expect(onboarding.watchStart, throwsUnimpl);
      expect(onboarding.watchModeChoice, throwsUnimpl);
      expect(onboarding.watchStepList, throwsUnimpl);
      expect(() => onboarding.watchStep('o_02'), throwsUnimpl);
      expect(onboarding.watchFinish, throwsUnimpl);
      expect(onboarding.watchRestart, throwsUnimpl);
      expect(UnimplementedPairingRepository().watchPairing, throwsUnimpl);
    });
  });
}
