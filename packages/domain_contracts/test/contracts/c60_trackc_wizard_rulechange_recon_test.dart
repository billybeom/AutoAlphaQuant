// C-60 트랙 C 선행 — M5-11 simToAuto 위저드 VM · M5-9 SAF-405 첫 승인 최소판 · M5-5 RECON 해제 · 사전 저널 꼴 — 01 §35
// (🆕 계약 v1.26 · 트랙 C 선행 · 발주자 위임 2026-11-14 — 권고대로 · K166~K186).
//
// 정의: 「M5-11 은 `HandoverWizardVm`(엔진 7단계 감싸기 · 단계별 허용 동작 = 기존 `SettingsActionId` · 세션 id = 엔진이 args 에 ·
//        잠김·확정 = 동작 0)을 `HandoverRepository.watchWizard()` 로(`handoverStatus` = 같은 본문), M5-9 첫 승인은
//        `RuleChangeGateVm`(후보 = 엔진 · 자기 신고 0 · 큐 취소 = `run(ruleChangeCancel{request_id})`)을
//        `RuleChangeGateRepository.watchGate()` 로 읽고 요청 = `runRuleChangeRequest(제출 DTO)` · RECON 해제 = 보드 RECON 행의
//        폼(원인 코드 ⊆ 쓰기 화이트리스트) + `runReconClear(제출 DTO)` — `run(reconClear)` 는 화이트리스트 밖 ·
//        사람 글 3필드(사전 저널) = 제출 DTO · 저널 id = 구현」.
//   ① 표본 20 왕복·키 ② 위저드 단계 차례 ③ 단계별 허용 동작 ④ 위저드 링크 ⑤ 잠김·확정 = 동작 0 ⑥ 위저드 코드·색 짝
//   ⑦ 게이트 잠김·취소 ⑧ 게이트 표본 ⑨ RECON 폼 ⑩ 결과 사전 ⑪ 제출 DTO 키 ⑫ wire·사전 ⑬ 금액 키·글자 0
//   ⑭ 확정 성공 표본 0 ⑮ `run` 화이트리스트 ⑯ 받침대·창구 ⑰ 포트 경계.
//
// 🔴 픽스처 불변식 + 포트 경계 스캔만 본다 — 위저드·게이트·RECON 화면(생체 · 폼 · 결과 원문)은 `ui_safety` 카드(E11q-c0 · c1 · c4) 몫.
// 🔴 봉투 `meta.mode` = `LIVE`(전 표본 선례 · v1.22 simToAuto 표본도 LIVE — 모의/실전 갈래는 VM 글자가 말한다).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 위저드 12벌.
const List<String> _wizards = <String>[
  FixturePaths.m5HandoverWizardTrialIncomplete,
  FixturePaths.m5HandoverWizardS3Blocked,
  FixturePaths.m5HandoverWizardFatePending,
  FixturePaths.m5HandoverWizardStartReady,
  FixturePaths.m5HandoverWizardCooling,
  FixturePaths.m5HandoverWizardCommitReady,
  FixturePaths.m5HandoverWizardWindowBlocked,
  FixturePaths.m5HandoverWizardExpired,
  FixturePaths.m5HandoverWizardTimeUnknown,
  FixturePaths.m5HandoverWizardNotApplicable,
  FixturePaths.m5HandoverWizardCommitted,
  FixturePaths.m5HandoverWizardLocked,
];

/// 규칙 변경 게이트 5벌.
const List<String> _gates = <String>[
  FixturePaths.m5RuleChangeGateFirstCandidate,
  FixturePaths.m5RuleChangeGateCooling,
  FixturePaths.m5RuleChangeGateApprovable,
  FixturePaths.m5RuleChangeGateEmpty,
  FixturePaths.m5RuleChangeGateLocked,
];

/// 차단 보드 전부(v1.25 4 + v1.26 RECON 1).
const List<String> _boards = <String>[
  FixturePaths.m5BlockBoardClear,
  FixturePaths.m5BlockBoardKillActive,
  FixturePaths.m5BlockBoardReconMismatch,
  FixturePaths.m5BlockBoardResumeIncomplete,
  FixturePaths.m5BlockBoardStopped,
];

/// v1.26 신설 20벌.
const List<String> _new = <String>[
  ..._wizards,
  ..._gates,
  FixturePaths.m5RuleChangeRequestResults,
  FixturePaths.m5BlockBoardReconMismatch,
  FixturePaths.m5ReconClearResults,
];

/// ① §4 JSON 키(선언 차례).
const List<String> _wizardKeys = <String>[
  'headline',
  'level',
  'reason_code',
  'path_label',
  'rows',
  'trial',
  'cooling_text',
  'deadline_text',
  'window_text',
  'notice_text',
  'done_label',
  'locked_label',
  'as_of',
];
const List<String> _wizardRowKeys = <String>[
  'step',
  'level',
  'link',
  'actions',
];
const List<String> _gateKeys = <String>[
  'headline',
  'level',
  'window_text',
  'candidates',
  'rows',
  'empty_label',
  'locked_label',
  'as_of',
];
const List<String> _candidateKeys = <String>[
  'candidate_id',
  'label',
  'category_label',
  'hash_text',
  'request_label',
  'notice_text',
];
const List<String> _queueKeys = <String>[
  'request_id',
  'category_label',
  'hash_text',
  'requested_text',
  'cooling_text',
  'state_label',
  'level',
  'approve_label',
  'cancel',
];
const List<String> _formKeys = <String>['choices', 'notice_text'];
const List<String> _choiceKeys = <String>['origin_code', 'label'];

/// ③ K169 단계별 허용 동작(그 밖 단계 = 0).
const Map<String, Set<SettingsActionId>> _allowed =
    <String, Set<SettingsActionId>>{
      SimToAutoStepIds.goldenVector: <SettingsActionId>{
        SettingsActionId.selftestGoldenRun,
      },
      SimToAutoStepIds.simLedger: <SettingsActionId>{
        SettingsActionId.handoverSimLedgerFate,
      },
      SimToAutoStepIds.biometric: <SettingsActionId>{
        SettingsActionId.handoverSessionStart,
      },
      SimToAutoStepIds.cooling: <SettingsActionId>{
        SettingsActionId.handoverSessionCancel,
        SettingsActionId.handoverCommit,
      },
    };

/// ③ args 키(`settings_actions.dart` 화이트리스트 그대로).
const Map<SettingsActionId, List<String>> _argKeys =
    <SettingsActionId, List<String>>{
      SettingsActionId.selftestGoldenRun: <String>[],
      SettingsActionId.handoverSimLedgerFate: <String>['fate'],
      SettingsActionId.handoverSessionStart: <String>['path'],
      SettingsActionId.handoverSessionCancel: <String>['handover_session_id'],
      SettingsActionId.handoverCommit: <String>['handover_session_id'],
    };

/// ④ 단계 → 링크 목적지(엔진이 줄 때만).
const Map<String, String> _links = <String, String>{
  SimToAutoStepIds.goldenVector: AppRoutes.settingsDiagnostics,
  SimToAutoStepIds.liveKeys: AppRoutes.settingsCredentials,
  SimToAutoStepIds.accounts: AppRoutes.settingsAccounts,
};

const String _bio = 'BIOMETRIC_UNAVAILABLE';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? v) =>
    (v! as List).cast<Map<String, Object?>>().toList(growable: false);

List<Map<String, Object?>> _rows(String path) => _maps(_env(path)['rows']);

Map<String, Object?> _vm(String path) => _rows(path).single;

HandoverWizardVm _wizard(String path) => HandoverWizardVm.fromJson(_vm(path));

RuleChangeGateVm _gate(String path) => RuleChangeGateVm.fromJson(_vm(path));

Iterable<String> _strings(Object? v) sync* {
  if (v is Map) {
    for (final MapEntry<Object?, Object?> e in v.entries) {
      if (e.key == 'meta' || e.key == 'deep_link') continue;
      yield* _strings(e.value);
    }
  } else if (v is List) {
    for (final Object? x in v) {
      yield* _strings(x);
    }
  } else if (v is String) {
    yield v;
  }
}

Iterable<String> _jsonKeys(Object? v) sync* {
  if (v is Map) {
    for (final MapEntry<Object?, Object?> e in v.entries) {
      yield e.key! as String;
      yield* _jsonKeys(e.value);
    }
  } else if (v is List) {
    for (final Object? x in v) {
      yield* _jsonKeys(x);
    }
  }
}

void main() {
  group('C-60 트랙 C 선행 — 위저드 · 첫 승인 · RECON 해제 · 사전 저널 꼴 (01 §35 · 계약 v1.26)', () {
    test('C-60 ① 표본 20 — 1행 VM 봉투 18 · 결과 목록 2 · 키 == toJson(선언 차례) · 봉투 LIVE · 개정 보드 행 = recon_clear 칸', () {
      expect(_new, hasLength(20));
      expect(_new.toSet(), hasLength(20));
      for (final String path in _new) {
        final Map<String, Object?> meta =
            _env(path)['meta']! as Map<String, Object?>;
        expect(meta['mode'], 'LIVE', reason: path);
        expect(meta['contract_version'], contractVersion, reason: path);
      }
      for (final String path in _wizards) {
        final Map<String, Object?> raw = _vm(path);
        expect(raw.keys.toList(), _wizardKeys, reason: path);
        final HandoverWizardVm vm = HandoverWizardVm.fromJson(raw);
        expect(vm.toJson().keys.toList(), _wizardKeys, reason: path);
        expect(HandoverWizardVm.fromJson(vm.toJson()), vm, reason: path);
        for (final Map<String, Object?> r in _maps(raw['rows'])) {
          expect(r.keys.toList(), _wizardRowKeys, reason: path);
          expect(
            HandoverWizardStepRow.fromJson(r).toJson().keys.toList(),
            _wizardRowKeys,
            reason: path,
          );
        }
      }
      for (final String path in _gates) {
        final Map<String, Object?> raw = _vm(path);
        expect(raw.keys.toList(), _gateKeys, reason: path);
        final RuleChangeGateVm vm = RuleChangeGateVm.fromJson(raw);
        expect(vm.toJson().keys.toList(), _gateKeys, reason: path);
        expect(RuleChangeGateVm.fromJson(vm.toJson()), vm, reason: path);
        for (final Map<String, Object?> c in _maps(raw['candidates'])) {
          expect(c.keys.toList(), _candidateKeys, reason: path);
          expect(
            RuleChangeCandidateRow.fromJson(c).toJson().keys.toList(),
            _candidateKeys,
          );
        }
        for (final Map<String, Object?> q in _maps(raw['rows'])) {
          expect(q.keys.toList(), _queueKeys, reason: path);
          expect(
            RuleChangeQueueRow.fromJson(q).toJson().keys.toList(),
            _queueKeys,
          );
        }
      }
      for (final String path in _boards) {
        final BlockBoardVm vm = BlockBoardVm.fromJson(_vm(path));
        expect(BlockBoardVm.fromJson(vm.toJson()), vm, reason: path);
        for (final Map<String, Object?> r in _maps(_vm(path)['rows'])) {
          expect(r.keys.last, 'recon_clear', reason: '$path — 행 끝 칸');
        }
      }
      for (final String path in <String>[
        FixturePaths.m5RuleChangeRequestResults,
        FixturePaths.m5ReconClearResults,
      ]) {
        for (final Map<String, Object?> r in _rows(path)) {
          final SafetyActionResult res = SafetyActionResult.fromJson(r);
          expect(r.keys.toList(), res.toJson().keys.toList(), reason: path);
        }
      }
    });

    test('C-60 ② 위저드 단계 — 행 0 또는 7 · 7 이면 엔진 차례 · 0 ⇔ 전제 밖 표본', () {
      for (final String path in _wizards) {
        final HandoverWizardVm vm = _wizard(path);
        expect(<int>[0, 7], contains(vm.rows.length), reason: path);
        expect(
          vm.rows.isEmpty,
          path == FixturePaths.m5HandoverWizardNotApplicable,
          reason: '$path — 행 0 ⇔ 전제 밖',
        );
        if (vm.rows.isNotEmpty) {
          expect(
            vm.rows.map((HandoverWizardStepRow r) => r.step.stepId).toList(),
            SimToAutoStepIds.ordered,
            reason: path,
          );
          expect(
            vm.rows.map((HandoverWizardStepRow r) => r.step.order).toList(),
            <int>[1, 2, 3, 4, 5, 6, 7],
            reason: path,
          );
        }
      }
    });

    test('C-60 ③ 단계별 허용 동작(K169) — 표 밖 0 · args 키 = 화이트리스트 · 세션 id = 엔진 · 확정 ⇒ S7 PASS ∧ 막힘 0', () {
      int calls = 0;
      for (final String path in _wizards) {
        final HandoverWizardVm vm = _wizard(path);
        for (final HandoverWizardStepRow r in vm.rows) {
          final Set<SettingsActionId> allowed =
              _allowed[r.step.stepId] ?? <SettingsActionId>{};
          for (final SettingsActionCall a in r.actions) {
            calls++;
            expect(
              allowed,
              contains(a.id),
              reason: '$path ${r.step.stepId} — ${a.id} 는 이 단계 동작이 아니다',
            );
            expect(
              a.args.keys.toList(),
              _argKeys[a.id],
              reason: '$path ${a.id} — args 키',
            );
            if (a.id == SettingsActionId.handoverSimLedgerFate) {
              expect(<String>['KEEP', 'DISCARD'], contains(a.args['fate']));
            }
            if (a.id == SettingsActionId.handoverSessionStart) {
              expect(a.args['path'], 'SIM_TO_AUTO', reason: path);
            }
            if (a.args.containsKey('handover_session_id')) {
              expect(a.args['handover_session_id'], isNotEmpty, reason: path);
            }
            if (a.id == SettingsActionId.handoverCommit) {
              expect(
                r.step.state,
                GateState.pass,
                reason: '$path — 확정 = S7 통과만',
              );
              expect(
                vm.reasonCode,
                isNull,
                reason: '$path — 확정 = 막힘 0(readyToCommit)만',
              );
            }
            expect(a.label, isNotEmpty);
          }
        }
      }
      expect(
        calls,
        greaterThanOrEqualTo(9),
        reason: '표본이 동작을 거의 안 싣는다(표본 = 9)',
      );
      final HandoverWizardVm ready = _wizard(
        FixturePaths.m5HandoverWizardCommitReady,
      );
      expect(
        ready.rows.last.actions.map((SettingsActionCall a) => a.id).toSet(),
        <SettingsActionId>{
          SettingsActionId.handoverCommit,
          SettingsActionId.handoverSessionCancel,
        },
      );
      final HandoverWizardVm fate = _wizard(
        FixturePaths.m5HandoverWizardFatePending,
      );
      for (final SettingsActionCall a in fate.rows[4].actions) {
        expect(
          a.args.containsKey('handover_session_id'),
          isFalse,
          reason: '5단계 = 세션 전(v1.22 K56)',
        );
      }
    });

    test('C-60 ④ 위저드 링크 — S2·S3·S4 행만 · 목적지 = 진단·키·계좌', () {
      int links = 0;
      for (final String path in _wizards) {
        for (final HandoverWizardStepRow r in _wizard(path).rows) {
          final LinkAction? link = r.link;
          if (link == null) continue;
          links++;
          expect(
            _links[r.step.stepId],
            link.deepLink,
            reason: '$path ${r.step.stepId} — 링크 목적지',
          );
          expect(AppRoutes.isRegistered(link.deepLink), isTrue);
        }
      }
      expect(links, greaterThanOrEqualTo(3));
    });

    test('C-60 ⑤ 잠김·확정 — lockedLabel 또는 doneLabel ⇒ 모든 행 동작 0', () {
      for (final String path in _wizards) {
        final HandoverWizardVm vm = _wizard(path);
        if (vm.lockedLabel == null && vm.doneLabel == null) continue;
        for (final HandoverWizardStepRow r in vm.rows) {
          expect(r.actions, isEmpty, reason: '$path ${r.step.stepId}');
        }
      }
      expect(
        _wizard(FixturePaths.m5HandoverWizardLocked).lockedLabel,
        isNotNull,
      );
      expect(
        _wizard(FixturePaths.m5HandoverWizardCommitted).doneLabel,
        isNotNull,
      );
      expect(
        _wizard(FixturePaths.m5HandoverWizardCommitted).rows,
        hasLength(7),
      );
    });

    test('C-60 ⑥ 위저드 코드·색 — reasonCode ∈ 엔진 사전 ∪ 단계 id · 막힘 코드 ∈ 사전 · 행 level ↔ 상태 짝(K172)', () {
      final Set<String> codes = <String>{
        ...SimToAutoResultCodes.values,
        ...SimToAutoStepIds.values,
      };
      for (final String path in _wizards) {
        final HandoverWizardVm vm = _wizard(path);
        if (vm.reasonCode != null) {
          expect(codes, contains(vm.reasonCode), reason: path);
        }
        for (final HandoverWizardStepRow r in vm.rows) {
          final String? b = r.step.blockedReasonCode;
          if (b != null) {
            expect(SimToAutoResultCodes.values, contains(b), reason: path);
          }
          final Set<UiLevel> pair = switch (r.step.state) {
            GateState.pass => <UiLevel>{UiLevel.ok},
            GateState.block => <UiLevel>{UiLevel.blocked, UiLevel.watch},
            GateState.unknown => <UiLevel>{UiLevel.info, UiLevel.watch},
            // 위저드 7단계에는 오지 않는다(엔진 `simToAutoPlan` = PASS·BLOCK·UNKNOWN 셋).
            GateState.notApplicable => <UiLevel>{},
          };
          expect(pair, contains(r.level), reason: '$path ${r.step.stepId}');
        }
      }
      expect(
        _wizard(FixturePaths.m5HandoverWizardCommitReady).reasonCode,
        isNull,
      );
      expect(
        _wizard(FixturePaths.m5HandoverWizardWindowBlocked).reasonCode,
        SimToAutoResultCodes.windowBlocked,
      );
      expect(
        _wizard(FixturePaths.m5HandoverWizardFatePending).reasonCode,
        SimToAutoStepIds.simLedger,
        reason: '엔진 code = 첫 미통과 단계 id(막힘 코드가 없을 때)',
      );
      expect(
        _wizard(FixturePaths.m5HandoverWizardTrialIncomplete).trial,
        isNotNull,
      );
    });

    test('C-60 ⑦ 게이트 잠김·취소 — 잠김 ⇒ 후보 0 ∧ 취소·승인 0 · 취소 = run(ruleChangeCancel{request_id = 행 값})', () {
      for (final String path in _gates) {
        final RuleChangeGateVm vm = _gate(path);
        if (vm.lockedLabel != null) {
          expect(vm.candidates, isEmpty, reason: path);
          for (final RuleChangeQueueRow r in vm.rows) {
            expect(r.cancel, isNull, reason: path);
            expect(r.approveLabel, isNull, reason: path);
          }
        }
        for (final RuleChangeQueueRow r in vm.rows) {
          final SafetyActionCall? c = r.cancel;
          if (c == null) continue;
          expect(c.id, SafetyActionId.ruleChangeCancel, reason: path);
          expect(c.args.keys.toList(), <String>['request_id'], reason: path);
          expect(c.args['request_id'], r.requestId, reason: path);
        }
        for (final RuleChangeCandidateRow c in vm.candidates) {
          expect(c.candidateId, isNotEmpty);
          expect(c.requestLabel, isNotEmpty);
        }
      }
      expect(_gate(FixturePaths.m5RuleChangeGateLocked).lockedLabel, isNotNull);
    });

    test('C-60 ⑧ 게이트 표본 — 첫 후보 = 후보 1 ∧ 큐 0 · 냉각 = 승인 0 · 승인 가능 = 승인 글자 · 빈 = 둘 다 0 + 빈 문장', () {
      final RuleChangeGateVm first = _gate(
        FixturePaths.m5RuleChangeGateFirstCandidate,
      );
      expect(first.candidates, hasLength(1));
      expect(first.rows, isEmpty);
      expect(
        _gate(FixturePaths.m5RuleChangeGateCooling).rows.single.approveLabel,
        isNull,
      );
      expect(
        _gate(FixturePaths.m5RuleChangeGateApprovable).rows.single.approveLabel,
        isNotNull,
      );
      final RuleChangeGateVm empty = _gate(FixturePaths.m5RuleChangeGateEmpty);
      expect(empty.candidates, isEmpty);
      expect(empty.rows, isEmpty);
      expect(empty.emptyLabel, isNotNull);
      for (final String path in _gates) {
        final RuleChangeGateVm vm = _gate(path);
        if (vm.emptyLabel != null) {
          expect(
            vm.candidates.isEmpty && vm.rows.isEmpty,
            isTrue,
            reason: path,
          );
        }
      }
    });

    test('C-60 ⑨ RECON 폼 — reconClear ⇔ RECON_MISMATCH 행 · 선택지 비지 않음 · 원인 코드 ⊆ 쓰기 화이트리스트 · 겹침 0', () {
      int forms = 0;
      for (final String path in _boards) {
        for (final BlockBoardRow r in BlockBoardVm.fromJson(_vm(path)).rows) {
          final ReconClearForm? f = r.reconClear;
          expect(
            f != null,
            r.rowId == FlagIds.reconMismatch,
            reason: '$path ${r.rowId} — 해제 폼은 RECON 행만',
          );
          if (f == null) continue;
          forms++;
          expect(f.choices, isNotEmpty, reason: path);
          final List<String> codes = f.choices
              .map((ReconOriginChoice c) => c.originCode)
              .toList();
          expect(codes.toSet(), hasLength(codes.length), reason: path);
          for (final ReconOriginChoice c in f.choices) {
            expect(OriginCodes.writable, contains(c.originCode), reason: path);
            expect(c.label, isNotEmpty);
          }
          for (final Map<String, Object?> c in _maps(
            (_maps(_vm(path)['rows']).firstWhere(
                  (Map<String, Object?> m) =>
                      m['row_id'] == FlagIds.reconMismatch,
                )['recon_clear']!
                as Map<String, Object?>)['choices'],
          )) {
            expect(c.keys.toList(), _choiceKeys);
          }
        }
      }
      expect(forms, 1);
      final Map<String, Object?> recon = _maps(
        _vm(FixturePaths.m5BlockBoardReconMismatch)['rows'],
      ).first;
      expect(
        (recon['recon_clear']! as Map<String, Object?>).keys.toList(),
        _formKeys,
      );
    });

    test('C-60 ⑩ 결과 사전 — 요청 = RULE_CHANGE_REQUEST · 해제 = RECON_CLEAR · 코드 ∈ 허용 · 성공 1 = OK · 넘김 0 · 재시도 0', () {
      final Map<String, (SafetyActionId, Set<String>)> want =
          <String, (SafetyActionId, Set<String>)>{
            FixturePaths.m5RuleChangeRequestResults: (
              SafetyActionId.ruleChangeRequest,
              <String>{
                ...RuleChangeResultCodes.values,
                SafetyCommonResultCodes.trustedTimeUnknown,
                SafetyCommonResultCodes.journalIdTaken,
                _bio,
              },
            ),
            FixturePaths.m5ReconClearResults: (
              SafetyActionId.reconClear,
              <String>{
                ...ReconClearResultCodes.values,
                SafetyCommonResultCodes.journalIdTaken,
                _bio,
              },
            ),
          };
      for (final MapEntry<String, (SafetyActionId, Set<String>)> e
          in want.entries) {
        int ok = 0;
        final Set<String> seen = <String>{};
        for (final Map<String, Object?> raw in _rows(e.key)) {
          final SafetyActionResult r = SafetyActionResult.fromJson(raw);
          expect(r.id, e.value.$1, reason: e.key);
          expect(r.handoffRoute, isNull, reason: e.key);
          expect(r.retryable, isFalse, reason: e.key);
          expect(r.headline, isNotEmpty);
          final String? code = r.reasonCode;
          if (code == null) {
            ok++;
            expect(r.level, UiLevel.ok, reason: '${e.key} — 성공 = OK');
          } else {
            expect(e.value.$2, contains(code), reason: '${e.key} — $code');
            expect(seen.add(code), isTrue, reason: '${e.key} — $code 두 번');
          }
        }
        expect(ok, 1, reason: e.key);
      }
      expect(
        _rows(FixturePaths.m5ReconClearResults)
            .map((Map<String, Object?> r) => r['reason_code'])
            .whereType<String>()
            .toSet(),
        containsAll(ReconClearResultCodes.values),
      );
    });

    test(
      'C-60 ⑪ 제출 DTO — JSON 키 고정(규칙 변경 요청 6 · RECON 해제 4) · 왕복 · 저널 id 칸 0',
      () {
        const RuleChangeRequestSubmission req = RuleChangeRequestSubmission(
          candidateId: 'c',
          reason: 'r',
          rollbackMethod: 'b',
          rationaleBefore: 'a',
          expectedOutcome: 'e',
          ruleCited: 'u',
        );
        const ReconClearSubmission rc = ReconClearSubmission(
          originCode: OriginCodes.fillLag,
          rationaleBefore: 'a',
          expectedOutcome: 'e',
          ruleCited: 'u',
        );
        expect(req.toJson().keys.toList(), <String>[
          'candidate_id',
          'reason',
          'rollback_method',
          'rationale_before',
          'expected_outcome',
          'rule_cited',
        ]);
        expect(rc.toJson().keys.toList(), <String>[
          'origin_code',
          'rationale_before',
          'expected_outcome',
          'rule_cited',
        ]);
        expect(RuleChangeRequestSubmission.fromJson(req.toJson()), req);
        expect(ReconClearSubmission.fromJson(rc.toJson()), rc);
        for (final Map<String, Object?> j in <Map<String, Object?>>[
          req.toJson(),
          rc.toJson(),
        ]) {
          for (final String k in <String>[
            'decision_id',
            'cleared_by',
            'change_type',
            'hash_before',
            'hash_after',
          ]) {
            expect(
              j.containsKey(k),
              isFalse,
              reason: '$k = 엔진·구현 몫(K178 · K180 · K181)',
            );
          }
        }
      },
    );

    test('C-60 ⑫ wire·사전 — RULE_CHANGE_REQUEST · RECON 3 · byDomain 등재 · 다른 사전과 겹침 0', () {
      expect(SafetyActionId.ruleChangeRequest.wire, 'RULE_CHANGE_REQUEST');
      expect(
        SafetyActionId.values.indexOf(SafetyActionId.ruleChangeRequest) + 1,
        SafetyActionId.values.indexOf(SafetyActionId.ruleChangeCancel),
        reason: '자리 = ruleChangeCancel 앞',
      );
      expect(ReconClearResultCodes.values, <String>{
        'RECON_NOT_BLOCKED',
        'RECON_ORIGIN_NOT_ALLOWED',
        'RECON_JOURNAL_MISSING',
      });
      expect(
        ContractCodes.byDomain['recon_clear_result'],
        ReconClearResultCodes.values,
      );
      for (final MapEntry<String, Set<String>> e
          in ContractCodes.byDomain.entries) {
        if (e.key == 'recon_clear_result') continue;
        expect(
          e.value.intersection(ReconClearResultCodes.values),
          isEmpty,
          reason: '${e.key} 와 겹친다',
        );
      }
    });

    test('C-60 ⑬ 금액 키·글자 0 — 새 표본 20 에 손익·금액·계좌 키 0 · DRY_RUN·손익 낱말·금액 글자·8자리 숫자 0', () {
      const Set<String> badKeys = <String>{
        'amount',
        'cash',
        'pnl',
        'krw',
        'won',
        'balance',
        'account_no',
      };
      final RegExp bad = RegExp(
        r'DRY_RUN|평가손익|수익률|평가액|손익|세후|카운트다운|해제 버튼|[0-9]{8,}|[0-9][0-9,]*원|[0-9]만',
      );
      for (final String path in _new) {
        final Map<String, Object?> env = _env(path);
        final Set<String> keys = _jsonKeys(env['rows']).toSet();
        expect(keys.intersection(badKeys), isEmpty, reason: path);
        for (final String s in _strings(env)) {
          expect(bad.hasMatch(s), isFalse, reason: '$path — «$s»');
        }
      }
    });

    test(
      'C-60 ⑭ 확정 성공 결과 표본 0 — 위저드 결과 표본에 HANDOVER_COMMIT 성공 행 0(K175 · 금액 문장)',
      () {
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m5HandoverSimToAutoActionResults,
        )) {
          final ActionResult a = ActionResult.fromJson(r);
          if (a.id == SettingsActionId.handoverCommit) {
            expect(a.reasonCode, isNotNull, reason: '확정 성공 문장 = 금액 → 표본 0');
          }
          expect(a.handoffRoute, isNull);
        }
      },
    );

    test('C-60 ⑮ run 화이트리스트 — 머리 표 = interventionStep·ruleChangeCancel·seasonalWindowChoice(reconClear 0) · '
        '표본 SafetyActionCall 에 RECON_CLEAR·RULE_CHANGE_REQUEST 0', () {
      final String src = File('${libDir.path}/src/commands/safety_actions.dart')
          .readAsStringSync();
      final Set<String> active = RegExp(
        r'^///\s+· `(\w+)`\s+= `\{',
        multiLine: true,
      ).allMatches(src).map((RegExpMatch m) => m.group(1)!).toSet();
      expect(active, <String>{
        'interventionStep',
        'ruleChangeCancel',
        'seasonalWindowChoice',
        // 🆕 v1.32(01 §41 · K254) — X5 아무것도 안 하기(v1.33 에 표 꼴로 맞춤).
        'repairAccept',
        // 🆕 v1.33(01 §42 · K273) — X1 기기 이전 6(전부 엔진 완성 · 시크릿 = 슬롯).
        'x1PlanStart',
        'x1PlanStep',
        'x1PlanAbort',
        'x1EmergencyStart',
        'x1ReissueRecord',
        'x1RecoveryStep',
      });
      for (final String path in FixturePaths.all) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (value is! Map) return;
          final Map<Object?, Object?> m = value;
          if (m.length == 3 &&
              m.containsKey('id') &&
              m.containsKey('args') &&
              m.containsKey('label')) {
            expect(
              <Object?>['RECON_CLEAR', 'RULE_CHANGE_REQUEST'],
              isNot(contains(m['id'])),
              reason: '$path $jsonPath — 제출 DTO 경로 동작은 엔진 완성 호출로 싣지 않는다',
            );
          }
        });
      }
    });

    test('C-60 ⑯ 받침대·창구 — 창구 2 = 동기 throw · SafetyActions 새 메서드 2 = Future 에러 · 반환 타입', () async {
      expect(
        () => UnimplementedHandoverRepository().watchWizard(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedRuleChangeGateRepository().watchGate(),
        throwsA(isA<UnimplementedError>()),
      );
      final Stream<HandoverWizardVm> Function() w =
          UnimplementedHandoverRepository().watchWizard;
      final Stream<RuleChangeGateVm> Function() g =
          UnimplementedRuleChangeGateRepository().watchGate;
      expect(<Object>[w, g], hasLength(2));
      final SafetyActions actions = UnimplementedSafetyActions();
      await expectLater(
        actions.runRuleChangeRequest(
          const RuleChangeRequestSubmission(
            candidateId: 'c',
            reason: 'r',
            rollbackMethod: 'b',
            rationaleBefore: 'a',
            expectedOutcome: 'e',
            ruleCited: 'u',
          ),
        ),
        throwsA(isA<UnimplementedError>()),
      );
      await expectLater(
        actions.runReconClear(
          const ReconClearSubmission(
            originCode: OriginCodes.fillLag,
            rationaleBefore: 'a',
            expectedOutcome: 'e',
            ruleCited: 'u',
          ),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('C-60 ⑰ 포트 경계 — ui_*(ui_safety 제외)에 새 이름 0', () {
      final List<RegExp> names = <RegExp>[
        RegExp(r'\bHandoverWizardVm\b'),
        RegExp(r'\bHandoverWizardStepRow\b'),
        RegExp(r'\bHandoverRepository\b'),
        RegExp(r'\bRuleChangeGateVm\b'),
        RegExp(r'\bRuleChangeGateRepository\b'),
        RegExp(r'\bRuleChangeRequestSubmission\b'),
        RegExp(r'\bReconClearForm\b'),
        RegExp(r'\bReconClearSubmission\b'),
        RegExp(r'\bReconClearResultCodes\b'),
        RegExp(r'\bwatchWizard\s*\('),
        RegExp(r'\brunRuleChangeRequest\s*\('),
        RegExp(r'\brunReconClear\s*\('),
      ];
      final List<String> offenders = <String>[];
      int scanned = 0;
      for (final String name in uiPackageNames) {
        if (name == 'ui_safety') continue;
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) continue;
        for (final File f in dartSourcesIn(lib)) {
          scanned++;
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExp rx in names) {
            if (rx.hasMatch(code)) {
              offenders.add('${shortPath(f)}: ${rx.pattern}');
            }
          }
        }
      }
      expect(scanned, greaterThan(0), reason: 'ui_*/lib 를 못 읽었다');
      expect(
        offenders,
        isEmpty,
        reason: '🔴 M5 위저드·게이트·RECON 화면은 ui_safety 만 그린다(00_README §4 · K185)',
      );
    });
  });
}
