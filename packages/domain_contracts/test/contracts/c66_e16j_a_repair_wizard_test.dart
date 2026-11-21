// C-66 E16j-a 계약 창 — X5 정정 마법사 — 01 §41
// (🆕 계약 v1.32 · 발주자 위임 2026-11-14 — 권고대로 · K247~K263).
//
// 정의: 「허브(`x5RepairWizard`) · 대상(`x5RepairTarget/:targetId`)이 같은 `RepairWizardVm` 을 쓴다 · 마찰 1~5 = 개입 세션 행 5 ·
//        아무것도 안 하기 = `run(repairAccept{diff_id})` · 정정 · 새 기준점 · 3단계 저널 = 제출 DTO 3 · 🔴 잠김 · 끝 · 경계 X1 = 동작 0 ·
//        숫자 칸 0 · 타입 이름 ≠ 엔진」.
//   ① 라우트 ② 허브 꼴 ③ 마찰 행 ④ diff 근거 ⑤ 동작 id · args ⑥ 정정 ↔ 새 기준점 배타 ⑦ 동작 0 조건 ⑧ 원인 코드
//   ⑨ reasonCode ⑩ 결과 표본 ⑪ 이름 ≠ 엔진 · 사전 ⑫ 제출 DTO 왕복 · 받침대 ⑬ 포트 경계(ui_safety 만).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List).cast<Map<String, Object?>>();

const List<String> _vms = <String>[
  FixturePaths.x5RepairHubTargets,
  FixturePaths.x5RepairHubEmpty,
  FixturePaths.x5RepairDiffDefault,
  FixturePaths.x5RepairDiffStage3,
  FixturePaths.x5RepairDiffReady,
  FixturePaths.x5RepairIntegrityReady,
  FixturePaths.x5RepairBoundaryX1,
];

RepairWizardVm _vm(String path) => RepairWizardVm.fromJson(_rows(path).single);

/// 결과 `reasonCode` 합집합(K259 · 🆕 v1.35 K291 += 정정 원문 파싱 거부).
final Set<String> _resultCodes = <String>{
  ...RepairResultCodes.values,
  ...RepairInputResultCodes.values,
  ...BaselineResultCodes.values,
  ...BaselineApplyResultCodes.values,
  AdviceRejectCodes.amendTargetNotActive,
  AdviceRejectCodes.amendSymbolOrSideChange,
  AdviceRejectCodes.amendLimitExceeded,
  ...InterventionResultCodes.values,
  ...SafetyCommonResultCodes.values,
  SettingsResultCodes.biometricUnavailable,
};

/// VM `reasonCode` 모집단.
final Set<String> _vmCodes = <String>{
  ...LedgerBoundaryReasonCodes.values,
  ...RepairResultCodes.values,
  ...BaselineResultCodes.values,
  ...BaselineApplyResultCodes.values,
};

bool _noActions(RepairWizardVm v) =>
    v.doNothingAction == null &&
    v.correction == null &&
    v.baselineLabel == null &&
    v.stages.every((RepairStageRow r) => r.actions.isEmpty && !r.journalForm);

void main() {
  group('C-66 E16j-a X5 정정 마법사 (01 §41)', () {
    test(
      'C-66 ① 라우트 — x5RepairTarget 5조각 · 85 · 허브와 첫 일치 겹침 0 · 대상 링크 = 등록',
      () {
        expect(AppRoutes.x5RepairTarget, 'aaq://x5/repair-wizard/:targetId');
        expect(AppRoutes.all, contains(AppRoutes.x5RepairTarget));
        expect(AppRoutes.all, hasLength(85));
        expect(
          AppRoutes.isRegistered('aaq://x5/repair-wizard/ld_0001'),
          isTrue,
        );
        expect(AppRoutes.isRegistered(AppRoutes.x5RepairWizard), isTrue);
      },
    );

    test('C-66 ② 허브 — targetLinks 비지 않음 ⇔ 허브(그때 diff · stages · origins · 동작 0) · 링크 = x5RepairTarget', () {
      for (final String path in _vms) {
        final RepairWizardVm v = _vm(path);
        if (v.targetLinks.isNotEmpty) {
          expect(v.diff, isNull, reason: path);
          expect(v.stages, isEmpty, reason: path);
          expect(v.origins, isEmpty, reason: path);
          expect(_noActions(v), isTrue, reason: path);
          for (final LinkAction l in v.targetLinks) {
            expect(
              l.deepLink,
              startsWith('aaq://x5/repair-wizard/'),
              reason: path,
            );
            expect(AppRoutes.isRegistered(l.deepLink), isTrue, reason: path);
          }
        }
      }
      expect(_vm(FixturePaths.x5RepairHubTargets).targetLinks, hasLength(2));
    });

    test('C-66 ③ 마찰 행 — 길이 ∈ {0, 5} · 3단계만 journalForm · 행 동작 id ⊆ {interventionStep}', () {
      for (final String path in _vms) {
        final RepairWizardVm v = _vm(path);
        expect(<int>{0, 5}, contains(v.stages.length), reason: path);
        for (int i = 0; i < v.stages.length; i++) {
          final RepairStageRow r = v.stages[i];
          if (r.journalForm) expect(i, 2, reason: '$path 3단계만 저널 폼');
          for (final SafetyActionCall c in r.actions) {
            expect(c.id, SafetyActionId.interventionStep, reason: path);
            expect(
              c.args.keys.toSet(),
              containsAll(<String>['session_id', 'stage', 'outcome']),
              reason: path,
            );
          }
        }
      }
      expect(
        _vm(FixturePaths.x5RepairDiffStage3).stages[2].journalForm,
        isTrue,
      );
    });

    test('C-66 ④ diff 근거 — L-1 행 재사용 · 그 안 actionLink = null', () {
      for (final String path in _vms) {
        final LedgerDiffRow? d = _vm(path).diff;
        if (d != null) expect(d.actionLink, isNull, reason: path);
      }
    });

    test(
      'C-66 ⑤ 동작 — doNothingAction = repairAccept{diff_id} · 무결성 갈래 = 0',
      () {
        for (final String path in _vms) {
          final RepairWizardVm v = _vm(path);
          final SafetyActionCall? a = v.doNothingAction;
          if (a != null) {
            expect(a.id, SafetyActionId.repairAccept, reason: path);
            expect(a.args.keys.toSet(), <String>{'diff_id'}, reason: path);
            expect(v.diff, isNotNull, reason: '$path 아무것도 안 하기 = diff 갈래만');
          }
        }
        expect(
          _vm(FixturePaths.x5RepairIntegrityReady).doNothingAction,
          isNull,
        );
        expect(_vm(FixturePaths.x5RepairDiffDefault).doNothingDefault, isTrue);
      },
    );

    test('C-66 ⑥ 정정 폼 ↔ 새 기준점 동시 0 · 정정 후보 비지 않음 · 갈래 맞음', () {
      for (final String path in _vms) {
        final RepairWizardVm v = _vm(path);
        expect(
          v.correction != null && v.baselineLabel != null,
          isFalse,
          reason: path,
        );
        final RepairCorrectionForm? f = v.correction;
        if (f != null) {
          expect(f.fills, isNotEmpty, reason: path);
          expect(v.diff, isNotNull, reason: path);
        }
        if (v.baselineLabel != null) expect(v.diff, isNull, reason: path);
      }
    });

    test('C-66 ⑦ 잠김 · 끝 · 경계 X1 ⇒ 동작 0 · 경계 X1 링크 = x1MigrationEmergency', () {
      for (final String path in _vms) {
        final RepairWizardVm v = _vm(path);
        if (v.lockedLabel != null ||
            v.doneLabel != null ||
            v.x1GuideLink != null) {
          expect(_noActions(v), isTrue, reason: path);
        }
      }
      expect(
        _vm(FixturePaths.x5RepairBoundaryX1).x1GuideLink?.deepLink,
        AppRoutes.x1MigrationEmergency,
      );
    });

    test('C-66 ⑧ 원인 — originCode ⊆ OriginCodes · 새 기준점 원인 ⊆ 3종', () {
      for (final String path in _vms) {
        for (final RepairOriginChoice o in _vm(path).origins) {
          expect(OriginCodes.values, contains(o.originCode), reason: path);
        }
      }
      expect(
        _vm(FixturePaths.x5RepairIntegrityReady).origins
            .map((RepairOriginChoice o) => o.originCode),
        everyElement(isIn(<String>{'CHAIN_BROKEN', 'SCHEMA_SKEW', 'DB_ERROR'})),
      );
    });

    test('C-66 ⑨ VM reasonCode ⊆ 경계 ∪ 정정 ∪ 새 기준점 사전', () {
      for (final String path in _vms) {
        final String? c = _vm(path).reasonCode;
        if (c != null) expect(_vmCodes, contains(c), reason: path);
      }
    });

    test('C-66 ⑩ 결과 표본 — id ⊆ 새 동작 4 · reasonCode ⊆ 합집합 · 왕복', () {
      final Set<SafetyActionId> ids = <SafetyActionId>{
        SafetyActionId.repairAccept,
        SafetyActionId.repairCorrect,
        SafetyActionId.repairBaseline,
        SafetyActionId.interventionJournal,
      };
      final List<Map<String, Object?>> rows = _rows(
        FixturePaths.x5RepairActionResults,
      );
      expect(rows, isNotEmpty);
      final Set<SafetyActionId> seen = <SafetyActionId>{};
      for (final Map<String, Object?> r in rows) {
        final SafetyActionResult a = SafetyActionResult.fromJson(r);
        expect(a.toJson(), r);
        expect(ids, contains(a.id));
        seen.add(a.id);
        if (a.reasonCode != null) {
          expect(_resultCodes, contains(a.reasonCode), reason: a.actionRunId);
        }
      }
      expect(seen, ids);
    });

    test('C-66 ⑪ 이름 ≠ 엔진 · 새 사전 등재 · 와이어 4', () {
      final String lib = <String>[
        for (final File f in dartSourcesIn(libDir)) f.readAsStringSync(),
      ].join('\n');
      for (final String engine in <String>[
        'RepairChoice',
        'RepairCodes',
        'BaselineCodes',
        'BaselineStoreCodes',
        'BaselineResult',
        'FillRestatement',
        'InterventionStep',
        'InterventionOutcome',
      ]) {
        expect(
          RegExp('(?:class|enum)\\s+$engine\\b').hasMatch(lib),
          isFalse,
          reason: '$engine — 계약 이름이 엔진 이름과 같다(K80)',
        );
      }
      expect(BaselineApplyResultCodes.values, <String>{
        'BASELINE_FLAG_NOT_SET',
      });
      expect(
        ContractCodes.byDomain['baseline_apply_result'],
        BaselineApplyResultCodes.values,
      );
      expect(
        <String>[
          SafetyActionId.repairAccept.wire,
          SafetyActionId.repairCorrect.wire,
          SafetyActionId.repairBaseline.wire,
          SafetyActionId.interventionJournal.wire,
        ],
        <String>[
          'REPAIR_ACCEPT',
          'REPAIR_CORRECT',
          'REPAIR_BASELINE',
          'INTERVENTION_JOURNAL',
        ],
      );
    });

    test('C-66 ⑫ 제출 DTO 3 왕복 · 원문 칸 = 문자열 · 받침대 = 에러', () async {
      const RepairCorrectSubmission c = RepairCorrectSubmission(
        targetId: 'ld_0001',
        fillRef: 'ex_0001',
        originCode: 'MISRECORDED_FILL',
        voidFill: false,
        quantityText: '9',
      );
      expect(RepairCorrectSubmission.fromJson(c.toJson()), c);
      const RepairBaselineSubmission b = RepairBaselineSubmission(
        targetId: 'li_0001',
        originCode: 'CHAIN_BROKEN',
      );
      expect(RepairBaselineSubmission.fromJson(b.toJson()), b);
      const InterventionJournalSubmission j = InterventionJournalSubmission(
        rationaleBefore: 'a',
        expectedOutcome: 'b',
        ruleCited: 'c',
      );
      expect(InterventionJournalSubmission.fromJson(j.toJson()), j);
      expect(
        c.toJson().keys,
        containsAll(<String>[
          'quantity_text',
          'price_text',
          'commission_text',
          'tax_text',
        ]),
      );
      final UnimplementedSafetyActions stub = UnimplementedSafetyActions();
      await expectLater(stub.runRepairCorrect(c), throwsUnimplementedError);
      await expectLater(stub.runRepairBaseline(b), throwsUnimplementedError);
      await expectLater(
        stub.runInterventionJournal(j),
        throwsUnimplementedError,
      );
      expect(
        () => UnimplementedRepairWizardRepository().watchRepair(),
        throwsUnimplementedError,
      );
    });

    test('C-66 ⑬ 포트 경계 — ui_*(ui_safety 제외) 소스에 X5 마법사 VM · 창구 · 제출 이름 0', () {
      const List<String> symbols = <String>[
        'RepairWizardVm',
        'RepairWizardRepository',
        'RepairCorrectSubmission',
        'RepairBaselineSubmission',
        'InterventionJournalSubmission',
        'runRepairCorrect',
        'runRepairBaseline',
        'runInterventionJournal',
      ];
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        if (name == 'ui_safety') {
          continue;
        }
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) {
          continue;
        }
        for (final File f in dartSourcesIn(lib)) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final String symbol in symbols) {
            if (RegExp('\\b$symbol\\b').hasMatch(code)) {
              offenders.add('${shortPath(f)}: $symbol');
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: '🔴 X5 정정 마법사 = ui_safety 만(01 §41 K249 · C-55 ⑯ 꼴)',
      );
    });
  });
}
