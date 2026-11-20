// C-56 E13 나머지·사다리·재개 게이트·simToAuto·fill-origin — 01 §31(🆕 계약 v1.22 · 엔진 예고 2/2 · 발주자 위임 2026-11-14 —
// 권고대로 · K48~K71).
//
// 🆕 v1.26(01 §35 · K181) — `run` 화이트리스트 4 → 3(`reconClear` 뺌 → `runReconClear` · 단언 = C-60 ⑮) · 아래 정의는 v1.22 그대로.
// 정의: 「M5 나머지 동작은 `SafetyActions` 의 제출 메서드 4(사람 글·수) + `run` 화이트리스트 4(엔진 완성)로만 가고 결과 코드는
//        엔진 글자 1:1 사전(공용 한 벌 · RECON 해제 = 코드 0) · 사다리 = 엔진 문장 5행 · X2 재개 게이트 = 엔진 문장 + 행마다
//        계절 3택(잠김 = 버튼 0) · 재개 리포트 = 엔진 DRY/FULL/NORMAL 판정 꼴 · simToAuto 계획 = 엔진 7단계 · 위저드 동작 3 =
//        `SettingsActionId`(5단계 = 세션 전) · fill-origin = 계약 글자(태그 줄 = 엔진 재생성 PR — 두 상태 허용)」.
//   ① 허용 키 ② E13 결과 ③ 위저드 결과 ④ simToAuto 계획 ⑤ 사다리 ⑥ 재개 게이트 ⑦ 재개 리포트 ⑧ 사전 ⑨ 열거·동작 id
//   ⑩ 제출 DTO 왕복 ⑪ 포트 경계 ⑫ 받침대 ⑬ 글자 ⑭ 모드 표지 ⑮ fill-origin ⑯ resume_mode ⑰ 추가형 사전 ⑱ J-1 모의 행.
//
// 🔴 픽스처 불변식 + 경계 스캔만 본다 — `ui_safety` M5-3~M5-11·X2 화면은 카드(E13k~m · E14j · E15j) 몫.
// 🔴 한국어 글자 단언 = 엔진 글자 표만(출처 주석 파일:줄 · origin/main 4f85259) — ④ 단계 제목 7 · ⑤ 사다리 라벨 5·문장 5×3 ·
//    ⑥ 재개 사유 줄 · ⑦ verdict 라벨 5·머리 꼬리 · ⑨ 엔진 명령 kind 6 · ⑭ 모드 표지 4 · ⑬ 금지 낱말 목록.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 사다리 2벌.
const List<String> _ladders = <String>[
  FixturePaths.m5BreakerLadderNormal,
  FixturePaths.m5BreakerLadderStopped,
];

/// simToAuto 계획 4벌.
const List<String> _plans = <String>[
  FixturePaths.m5HandoverSimToAutoReady,
  FixturePaths.m5HandoverSimToAutoS3Blocked,
  FixturePaths.m5HandoverSimToAutoCooling,
  FixturePaths.m5HandoverSimToAutoFatePending,
];

/// 재개 게이트 4벌.
const List<String> _gates = <String>[
  FixturePaths.x2ResumeGateSeasonalPending,
  FixturePaths.x2ResumeGateConservativeDefer,
  FixturePaths.x2ResumeGateReevaluationFailed,
  FixturePaths.x2ResumeGateLocked,
];

/// 재개 리포트(F8 + 신설 2).
const List<String> _reports = <String>[
  FixturePaths.resumeReport1,
  FixturePaths.x2ResumeReportRecoveryFull,
  FixturePaths.x2ResumeReportNormal,
];

/// v1.22 신설 15벌.
const List<String> _new = <String>[
  ..._ladders,
  FixturePaths.m5SafetyActionResultsE13,
  ..._plans,
  FixturePaths.m5HandoverSimToAutoActionResults,
  FixturePaths.x2ResumeGateSeasonalPending,
  FixturePaths.x2ResumeGateConservativeDefer,
  FixturePaths.x2ResumeGateReevaluationFailed,
  FixturePaths.x2ResumeGateLocked,
  FixturePaths.x2ResumeReportRecoveryFull,
  FixturePaths.x2ResumeReportNormal,
  FixturePaths.m6JournalSimBrokerReject,
];

// ── 엔진 글자 표(core · origin/main 4f85259) ───────────────────────────────

/// ④ simToAuto 7단계 제목(core `mode/sim_to_auto.dart:53-77` `SimToAutoStep.title`).
const List<String> _stepTitles = <String>[
  '모의 체험 확인',
  '계산 자가검사',
  '실전 키 확인',
  '계좌 연결',
  '모의 기록 처리',
  '생체 확인',
  '24시간 냉각',
];

/// ④ 경로 글자(core `mode/sim_to_auto.dart` `simToAutoPlan` `pathLabel`).
const String _pathLabel = '모의투자 → 실전 자동 매매(관찰부터)';

/// ⑤ 사다리 라벨(core `safety/safety_text.dart:179` `breakerLabelOf` · `BreakerLevel` 차례).
const List<String> _ladderLabels = <String>['정상', '경보', '축소 운용', '중지', '정지'];

/// ⑤ 사다리 문장 5×3(트리거 · 해제 · 조치) — 엔진 출력 그대로 옮겨 적음(새 수치 0 · 구현 감사 2026-11-17 변이 MA):
/// core `safety/breaker_ladder.dart:45` `breakerLadderOf(config: p0sBreakerConfig(), satelliteActive: false)` ·
/// 설정 = core `ops/equity_snapshot.dart:19` `p0sBreakerConfig` · `risk/breaker.dart:119` 방향 점수(origin/main 4f85259).
/// 엔진 설정이 바뀌면 이 표 · 표본 2 · 생성기 `LADDER_TEXT` 를 같은 PR 에서 함께 고친다(엔진 대조 시험 = 01 §31-8 ⑥).
const List<(String, String, String)> _ladderTexts = <(String, String, String)>[
  ('dd > -15%', '—', '정상 운용'),
  ('dd ≤ -15%', 'dd > -13% · 20거래일 유지', '알림 · 새틀라이트 신규 진입 · 증액 중단(지금은 대상 없음)'),
  ('dd ≤ -20%', 'dd ≥ -12% · 방향 점수 50 이상 · 20거래일 유지', '새틀라이트 × 0.5(지금은 대상 없음)'),
  (
    'dd ≤ -25%',
    'dd ≥ -15% · BULL 3일 연속 · 20거래일 유지',
    '새틀라이트 0%(지금은 대상 없음) · 슬리브 A 신규 매수 정지',
  ),
  (
    'dd ≤ -35%',
    '자동 해제 없음 — 20거래일 · SEV1 postmortem · 가족 합의 · 결정 A/B/C',
    '신규 주문 전면 중단 · 보유 유지 · 자동 청산 없음',
  ),
];

/// ⑥ 재개 사유 줄 — 시점 무관 12(core `resume/resume_text.dart:45-66` `resumeReevaluatedLine`).
const Map<String, String> _fixedReasonLines = <String, String>{
  'ADVISORY_PENDING': '안내 모드 재개 조건 결정을 기다립니다',
  'SAFETY_STOP': '안전 정지 — 기기와 원장 검증이 먼저입니다',
  'OBSERVING': '관찰 회차라 다음 회차에 재판정합니다',
  'RECON_MISMATCH_REMAINS': '대사 불일치가 남아 있어 미뤄 둡니다',
  'UNKNOWN_ORDERS_REMAIN': '결과를 모르는 주문이 남아 있어 미뤄 둡니다',
  'RESIDUAL_ORDERS_REMAIN': '처리 중인 주문이 남아 있어 미뤄 둡니다',
  'HUMAN_DECISION': '계절 진입은 직접 결정해야 합니다',
  'CONSERVATIVE_DEFER': '보수 모드라 다음 정기 회차로 넘겼습니다',
  'HUMAN_SKIP': '직접 건너뛰었습니다',
  'HUMAN_REDUCED': '직접 축소 진입을 골랐습니다',
  'HUMAN_AS_IS': '직접 그대로 진입을 골랐습니다',
  'REEVALUATION_FAILED': '재판정에 필요한 자료가 없어 미뤄 둡니다',
};

/// ⑥ 재개 사유 줄 — 시점 의존 3(날짜 = «{M}월 {D}일» · 같은 파일 `_monthDay`).
final Map<String, RegExp> _datedReasonLines = <String, RegExp>{
  'DUE_PASSED': RegExp(r'^유효기한\([0-9]{1,2}월 [0-9]{1,2}일\)이 지났습니다$'),
  'REEVALUATED': RegExp(r'^[0-9]{1,2}월 [0-9]{1,2}일 재판정 값으로 다음 주문 회차에 넘겼습니다$'),
  'REEVALUATED_EMPTY': RegExp(r'^[0-9]{1,2}월 [0-9]{1,2}일 재판정 결과 할 일이 없습니다$'),
};

/// ⑦ verdict 라벨(core `resume/resume_text.dart:30-37` `resumeVerdictLabel`).
const Map<String, String> _verdictLabels = <String, String>{
  'EXECUTED_AS_REEVALUATED': '재판정 값으로 집행 예정',
  'EXPIRED': '만료',
  'SUPERSEDED': '대체됨',
  'BLOCKED': '차단',
  'UNRECOVERABLE': '복구 불가',
};

/// ⑦ 리포트 머리 꼬리(core `resume/resume_text.dart:126-137` `_tail` · 모드 → 멈춤 사유).
const Map<String, String> _reportTails = <String, String>{
  'RECOVERY_DRY': '관찰 회차라 발주하지 않습니다.',
  'RECOVERY_FULL': '안전 정지 — 매매하지 않습니다.',
};

/// ⑦ 멈춤 사유 없음 꼬리(같은 함수 `null` 갈래).
const String _tailExecuted = '주문은 다음 주문 회차가 냅니다.';
const String _tailNothing = '새로 낼 주문은 없습니다.';

/// ⑨ 엔진 ds 명령 kind 6(`local/stopped_decision_store.dart:19` · `incident_store.dart:13` · `intervention_store.dart:16` ·
/// `discretion_store.dart:15` · `rule_change_store.dart:17-18`) + 계약이 짓는 2(K54 · K55).
const Map<SafetyActionId, String> _newSafetyWires = <SafetyActionId, String>{
  SafetyActionId.stoppedDecision: 'STOPPED_DECISION',
  SafetyActionId.postmortemRecord: 'INCIDENT_POSTMORTEM',
  SafetyActionId.reconClear: 'RECON_CLEAR',
  SafetyActionId.interventionStep: 'INTERVENTION_STEP',
  SafetyActionId.discretionAdjust: 'DISCRETION_ADJUST',
  SafetyActionId.ruleChangeCancel: 'RULE_CHANGE_CANCEL',
  SafetyActionId.ruleChangeApprove: 'RULE_CHANGE_APPROVE',
  SafetyActionId.seasonalWindowChoice: 'SEASONAL_WINDOW_CHOICE',
};

/// ⑭ 모드 표지(core `ops/mode_marker.dart:11 · 14 · 17-20` · ui_shell `lib/l10n/labels.dart:31-32`).
const List<String> _modeMarkers = <String>['모의투자', '투자 안내', '[모의]', '[안내]'];

/// ⑪ `ui_safety` 밖 화면이 이름을 들이면 안 되는 v1.22 포트·VM·창구·동작.
const List<String> _portSymbols = <String>[
  'BreakerLadderVm',
  'BreakerLadderRepository',
  'ResumeGateVm',
  'ResumeGateRepository',
  'StoppedDecisionSubmission',
  'PostmortemSubmission',
  'RuleChangeApprovalSubmission',
  'DiscretionAdjustSubmission',
  'KillChecklistSubmission',
  'runStoppedDecision',
  'runPostmortem',
  'runRuleChangeApproval',
  'runDiscretionAdjust',
  'handoverSessionStart',
  'handoverSessionCancel',
  'handoverSimLedgerFate',
];

/// ⑬ 금지 낱말.
const List<String> _forbiddenWords = <String>[
  'DRY_RUN',
  '수익률',
  '손익',
  '추천',
  '권유',
  '자문',
  '시그널',
  '매매 중단',
  '카운트다운',
  '해제 버튼',
];

/// ⑬ J-1 모의 거부 행의 가격 칸(J-1 행 꼴 · K66 — 이 세 키만 «…원» 허용).
const Set<String> _j1MoneyKeys = <String>{
  'price_text',
  'commission_text',
  'tax_text',
};

final RegExp _money = RegExp(r'[0-9][0-9,]*원');
final RegExp _longDigits = RegExp(r'[0-9]{8,}');

const Set<String> _allLevels = <String>{
  'OK',
  'INFO',
  'WATCH',
  'ACT',
  'BLOCKED',
};

const String _bio = 'BIOMETRIC_UNAVAILABLE';
const String _ttu = 'TRUSTED_TIME_UNKNOWN';

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

Set<String> _keys(Map<String, Object?> m) => m.keys.toSet();

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

/// (키, 문자열 값) 전부.
List<(String, String)> _keyedStrings(Object? node) {
  final List<(String, String)> out = <(String, String)>[];
  void visit(String key, Object? n) {
    if (n is String) {
      out.add((key, n));
    } else if (n is Map) {
      for (final MapEntry<Object?, Object?> e in n.entries) {
        visit(e.key! as String, e.value);
      }
    } else if (n is List) {
      for (final Object? x in n) {
        visit(key, x);
      }
    }
  }

  visit(r'$', node);
  return out;
}

/// camelCase 값 이름 → 기계적 SCREAMING_SNAKE(K10).
String _screamingSnake(String camel) => camel
    .replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (Match m) => '${m[1]}_${m[2]}',
    )
    .toUpperCase();

/// 재개 리포트 머리(core `resume/resume_text.dart:116` `resumeHeadline` 틀).
String _headline(int gap, ResumeCounts c, String tail) =>
    '$gap거래일 미실행: 재판정 ${c.executed} / 만료 ${c.expired} / '
    '대체 ${c.superseded} / 차단 ${c.blocked} / 복구 불가 ${c.unrecoverable}. $tail';

/// ⑮ `executions.fill_origin` CHECK 값 — [file] 판.
Set<String> _fillOriginValues(LedgerFile file, String raw) => <String>{
  for (final CheckConstraint c in parseCheckConstraintsText(
    ledgerDdlFor(file, raw),
    'batch_f_x7_advisory.sql',
  ))
    if (c.table == 'executions' && c.column == 'fill_origin') ...c.values,
};

void main() {
  group('C-56 E13 나머지·사다리·재개 게이트·simToAuto·fill-origin (01 §31 · 계약 v1.22)', () {
    test('C-56 ① 허용 키 — 새 VM·행·결과 키 == toJson · 저널 id·카운트다운·해제 칸 0 · 계절 호출 args 에 decision_id 0', () {
      for (final String path in _ladders) {
        final Map<String, Object?> raw = _vm(path);
        final BreakerLadderVm vm = BreakerLadderVm.fromJson(raw);
        expect(_keys(raw), vm.toJson().keys.toSet(), reason: path);
        for (int i = 0; i < vm.rows.length; i++) {
          expect(
            _keys(_maps(raw['rows'])[i]),
            vm.rows[i].toJson().keys.toSet(),
            reason: '$path rows[$i]',
          );
        }
      }
      for (final String path in _gates) {
        final Map<String, Object?> raw = _vm(path);
        final ResumeGateVm vm = ResumeGateVm.fromJson(raw);
        expect(_keys(raw), vm.toJson().keys.toSet(), reason: path);
        for (int i = 0; i < vm.rows.length; i++) {
          final Map<String, Object?> row = _maps(raw['rows'])[i];
          expect(
            _keys(row),
            vm.rows[i].toJson().keys.toSet(),
            reason: '$path rows[$i]',
          );
          for (final Map<String, Object?> call in _maps(row['actions'])) {
            expect(
              (call['args']! as Map<String, Object?>).containsKey(
                'decision_id',
              ),
              isFalse,
              reason: '$path — 계절 선택 decision_id = 구현이 짓는다(K54)',
            );
          }
        }
      }
      for (final Map<String, Object?> r in _rows(
        FixturePaths.m5SafetyActionResultsE13,
      )) {
        expect(_keys(r), SafetyActionResult.fromJson(r).toJson().keys.toSet());
      }
      for (final Map<String, Object?> r in _rows(
        FixturePaths.m5HandoverSimToAutoActionResults,
      )) {
        expect(_keys(r), ActionResult.fromJson(r).toJson().keys.toSet());
      }
      const Set<String> bad = <String>{
        'decision_id',
        'journal_decision_id',
        'countdown',
        'remaining_seconds',
        'release_action',
        'deactivate',
        'prefill',
        'example',
      };
      for (final String path in <String>[..._ladders, ..._gates, ..._plans]) {
        expect(
          _allKeys(_vm(path)).intersection(bad),
          isEmpty,
          reason: '$path — VM 안 금지 키',
        );
      }
    });

    test('C-56 ② E13 결과 — id 8 전수 · id 마다 허용 코드 · 새 사전마다 ≥1 · 레벨 5값 · 넘김·재시도 0 · RECON 코드 지어내기 0', () {
      final List<SafetyActionResult> rs = <SafetyActionResult>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m5SafetyActionResultsE13,
        ))
          SafetyActionResult.fromJson(r),
      ];
      expect(<SafetyActionId>{
        for (final SafetyActionResult r in rs) r.id,
      }, _newSafetyWires.keys.toSet());
      final Set<String> halt = <String>{
        ResumeItemReasonCodes.advisoryPending,
        ResumeItemReasonCodes.safetyStop,
        ResumeItemReasonCodes.observing,
        ResumeItemReasonCodes.reconMismatch,
        ResumeItemReasonCodes.unknownOrders,
        ResumeItemReasonCodes.residualOrders,
        ResumeItemReasonCodes.reevaluationFailed,
      };
      final Map<SafetyActionId, Set<String>> allowed =
          <SafetyActionId, Set<String>>{
            SafetyActionId.stoppedDecision: <String>{
              ...StoppedDecisionResultCodes.values,
              SafetyCommonResultCodes.journalIdTaken,
              _bio,
            },
            SafetyActionId.postmortemRecord: <String>{
              ...PostmortemResultCodes.values,
              _bio,
            },
            SafetyActionId.reconClear: <String>{_bio},
            SafetyActionId.interventionStep: <String>{
              ...InterventionResultCodes.values,
              _ttu,
              _bio,
            },
            SafetyActionId.discretionAdjust: <String>{
              ...DiscretionResultCodes.values,
              _ttu,
              _bio,
            },
            SafetyActionId.ruleChangeCancel: <String>{
              ...RuleChangeResultCodes.values,
              _ttu,
              _bio,
            },
            SafetyActionId.ruleChangeApprove: <String>{
              ...RuleChangeResultCodes.values,
              _ttu,
              _bio,
            },
            SafetyActionId.seasonalWindowChoice: <String>{
              ...SeasonalChoiceResultCodes.values,
              ...PlannedWorkRejectCodes.values,
              ...halt,
              _bio,
            },
          };
      for (final SafetyActionResult r in rs) {
        final String? code = r.reasonCode;
        if (code != null) {
          expect(
            allowed[r.id]!.contains(code),
            isTrue,
            reason: '${r.actionRunId} ${r.id.wire} — 허용 밖 코드 $code',
          );
        }
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(r.retryable, isFalse, reason: r.actionRunId);
        expect(r.headline, isNotEmpty, reason: r.actionRunId);
      }
      final Set<String> used = <String>{
        for (final SafetyActionResult r in rs)
          if (r.reasonCode != null) r.reasonCode!,
      };
      for (final MapEntry<String, Set<String>> e in <String, Set<String>>{
        'stopped_decision_result': StoppedDecisionResultCodes.values,
        'postmortem_result': PostmortemResultCodes.values,
        'intervention_result': InterventionResultCodes.values,
        'rule_change_result': RuleChangeResultCodes.values,
        'discretion_result': DiscretionResultCodes.values,
        'seasonal_choice_result': SeasonalChoiceResultCodes.values,
        'planned_work_reject': PlannedWorkRejectCodes.values,
        'resume_reason(멈춤)': halt,
      }.entries) {
        expect(used.intersection(e.value), isNotEmpty, reason: '${e.key} 표본 0');
      }
      expect(used, contains(SafetyCommonResultCodes.journalIdTaken));
      expect(used, contains(_bio));
      expect(<String>{
        for (final SafetyActionResult r in rs) r.level.wire,
      }, _allLevels);
    });

    test('C-56 ③ 위저드 결과 — id 4 전수 · id 마다 허용 코드 · 확정 null 행 0 · 금액 문장 0', () {
      final List<ActionResult> rs = <ActionResult>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m5HandoverSimToAutoActionResults,
        ))
          ActionResult.fromJson(r),
      ];
      final Map<SettingsActionId, Set<String>> allowed =
          <SettingsActionId, Set<String>>{
            SettingsActionId.handoverSimLedgerFate: <String>{
              SimToAutoCommitResultCodes.simClosed,
              SimToAutoResultCodes.notSimAuto,
            },
            SettingsActionId.handoverSessionStart: <String>{
              ...SimToAutoResultCodes.values,
              ...SimToAutoStepIds.values,
              ...HandoverSessionResultCodes.values,
              _bio,
            },
            SettingsActionId.handoverSessionCancel: <String>{
              LivePromotionResultCodes.sessionInvalid,
            },
            SettingsActionId.handoverCommit: <String>{
              ...SimToAutoCommitResultCodes.values,
              ...SimToAutoResultCodes.values,
              ...SimToAutoStepIds.values,
              LivePromotionResultCodes.sessionInvalid,
              JournalReasonCodes.leaseInvalid,
            },
          };
      expect(<SettingsActionId>{
        for (final ActionResult r in rs) r.id,
      }, allowed.keys.toSet());
      for (final ActionResult r in rs) {
        final String? code = r.reasonCode;
        if (code != null) {
          expect(
            allowed[r.id]!.contains(code),
            isTrue,
            reason: '${r.actionRunId} ${r.id.wire} — 허용 밖 코드 $code',
          );
        }
        if (r.id == SettingsActionId.handoverCommit) {
          expect(
            code,
            isNotNull,
            reason: '${r.actionRunId} — 확정 성공 = 금액 문장(표본 0)',
          );
        }
        expect(_money.hasMatch(r.headline), isFalse, reason: r.actionRunId);
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(r.retryable, isFalse, reason: r.actionRunId);
      }
      expect(<String>{
        for (final ActionResult r in rs) r.level.wire,
      }, _allLevels);
    });

    test('C-56 ④ simToAuto 계획 — 7단계 · id·차례·제목 == 엔진 · BLOCK ⇒ 판정 코드 · PASS ⇒ null · 미리보기 0', () {
      final List<HandoverPlan> plans = <HandoverPlan>[
        for (final String path in _plans) HandoverPlan.fromJson(_vm(path)),
        HandoverPlan.fromJson(
          _rows(
            FixturePaths.m9HandoverStates,
          ).singleWhere((Map<String, Object?> r) => r['path'] == 'SIM_TO_AUTO'),
        ),
      ];
      for (final HandoverPlan p in plans) {
        final String where = '${p.path.wire} ${p.asOf.label}';
        expect(p.path, HandoverPath.simToAuto, reason: where);
        expect(p.pathLabel, _pathLabel, reason: where);
        expect(p.adoptionPreview, isEmpty, reason: where);
        expect(
          <String>[for (final HandoverStep s in p.steps) s.stepId],
          SimToAutoStepIds.ordered,
          reason: where,
        );
        expect(
          <int>[for (final HandoverStep s in p.steps) s.order],
          <int>[for (int i = 1; i <= 7; i++) i],
          reason: where,
        );
        expect(
          <String>[for (final HandoverStep s in p.steps) s.title],
          _stepTitles,
          reason: where,
        );
        for (final HandoverStep s in p.steps) {
          expect(s.state, isNot(GateState.notApplicable), reason: where);
          switch (s.state) {
            case GateState.block:
              expect(
                SimToAutoResultCodes.values,
                contains(s.blockedReasonCode),
                reason: '$where ${s.stepId}',
              );
            case GateState.pass:
              expect(s.blockedReasonCode, isNull, reason: '$where ${s.stepId}');
            case GateState.unknown:
              expect(
                <String?>[null, SimToAutoResultCodes.trustedTimeUnavailable],
                contains(s.blockedReasonCode),
                reason: '$where ${s.stepId}',
              );
            case GateState.notApplicable:
              fail('$where ${s.stepId} — 경고 갈래 0');
          }
        }
      }
      expect(
        plans.first.steps.every((HandoverStep s) => s.state == GateState.pass),
        isTrue,
        reason: 'ready = 7 PASS',
      );
      final HandoverStep fate = HandoverPlan.fromJson(
        _vm(FixturePaths.m5HandoverSimToAutoFatePending),
      ).steps[4];
      expect(fate.state, GateState.unknown);
      expect(fate.blockedReasonCode, isNull);
    });

    test('C-56 ⑤ 사다리 — 5행 BreakerLevel 차례 · current 하나 · 라벨·문장 == 엔진 · current 빼면 두 표본 같음 · 빈 글자 0', () {
      final Map<String, BreakerLevel> want = <String, BreakerLevel>{
        FixturePaths.m5BreakerLadderNormal: BreakerLevel.normal,
        FixturePaths.m5BreakerLadderStopped: BreakerLevel.stopped,
      };
      for (final String path in _ladders) {
        final BreakerLadderVm vm = BreakerLadderVm.fromJson(_vm(path));
        expect(
          <BreakerLevel>[for (final BreakerLadderRow r in vm.rows) r.level],
          BreakerLevel.values,
          reason: path,
        );
        expect(
          <BreakerLevel>[
            for (final BreakerLadderRow r in vm.rows)
              if (r.current) r.level,
          ],
          <BreakerLevel>[want[path]!],
          reason: path,
        );
        expect(
          <String>[for (final BreakerLadderRow r in vm.rows) r.label],
          _ladderLabels,
          reason: path,
        );
        expect(
          <(String, String, String)>[
            for (final BreakerLadderRow r in vm.rows)
              (r.triggerText, r.releaseText, r.actionText),
          ],
          _ladderTexts,
          reason: '$path — 사다리 문장 ≠ 엔진 breakerLadderOf 출력',
        );
        for (final BreakerLadderRow r in vm.rows) {
          for (final String s in <String>[
            r.label,
            r.triggerText,
            r.releaseText,
            r.actionText,
          ]) {
            expect(s.trim(), isNotEmpty, reason: '$path ${r.level.wire}');
          }
        }
      }
      String body(String path) => jsonEncode(<Object?>[
        for (final Map<String, Object?> r in _maps(_vm(path)['rows']))
          <String, Object?>{...r, 'current': null},
      ]);
      expect(
        body(FixturePaths.m5BreakerLadderNormal),
        body(FixturePaths.m5BreakerLadderStopped),
      );
    });

    test('C-56 ⑥ 재개 게이트 — 사유 ∈ 사전 · 줄 == 엔진 · actions ⇔ 사람 결정 ∧ 잠김 아님 · 호출 = 3택 · 잠김 = 그 밖 같음 · 링크', () {
      for (final String path in _gates) {
        final ResumeGateVm vm = ResumeGateVm.fromJson(_vm(path));
        expect(
          RegExp(r'^[0-9]+거래일 미실행 — .+$').hasMatch(vm.modeLabel),
          isTrue,
          reason: path,
        );
        expect(vm.reportLink?.deepLink, AppRoutes.x2ResumeReport, reason: path);
        for (final ResumeGateRow r in vm.rows) {
          final String where = '$path ${r.workId}';
          expect(
            ResumeItemReasonCodes.values,
            contains(r.reasonCode),
            reason: where,
          );
          final String? fixed = _fixedReasonLines[r.reasonCode];
          if (fixed != null) {
            expect(r.reasonLabel, fixed, reason: where);
          } else {
            expect(
              _datedReasonLines[r.reasonCode]!.hasMatch(r.reasonLabel),
              isTrue,
              reason: where,
            );
          }
          final bool wantCalls =
              r.reasonCode == ResumeItemReasonCodes.humanDecision &&
              vm.lockedLabel == null;
          expect(r.actions.isNotEmpty, wantCalls, reason: where);
          for (final SafetyActionCall c in r.actions) {
            expect(c.id, SafetyActionId.seasonalWindowChoice, reason: where);
            expect(c.args.keys.toSet(), <String>{
              'work_id',
              'choice',
            }, reason: where);
            expect(c.args['work_id'], r.workId, reason: where);
          }
          if (r.actions.isNotEmpty) {
            expect(
              <String?>[
                for (final SafetyActionCall c in r.actions) c.args['choice'],
              ],
              <String>[
                for (final SeasonalEntryChoice v in SeasonalEntryChoice.values)
                  v.wire,
              ],
              reason: where,
            );
          }
        }
      }
      final Map<String, Object?> pending = Map<String, Object?>.of(
        _vm(FixturePaths.x2ResumeGateSeasonalPending),
      );
      final Map<String, Object?> locked = _vm(FixturePaths.x2ResumeGateLocked);
      expect(locked['locked_label'], isA<String>());
      pending['locked_label'] = locked['locked_label'];
      pending['rows'] = <Object?>[
        for (final Map<String, Object?> r in _maps(pending['rows']))
          <String, Object?>{...r, 'actions': <Object?>[]},
      ];
      expect(jsonEncode(pending), jsonEncode(locked));
    });

    test('C-56 ⑦ 재개 리포트 — 모드 3 전수 · DRY ⇒ 재판정 0 · 항목 UNRECOVERABLE 0 · 셈 == 항목 + 공백 · 라벨·머리 == 엔진', () {
      final Set<ResumeMode> modes = <ResumeMode>{};
      for (final String path in _reports) {
        final ResumeReport r = ResumeReport.fromJson(_vm(path));
        modes.add(r.mode);
        final List<String> verdicts = <String>[
          for (final ResumeItem i in r.items) i.verdictCode,
        ];
        expect(
          verdicts,
          isNot(contains(VerdictCodes.unrecoverable)),
          reason: path,
        );
        if (r.mode == ResumeMode.recoveryDry) {
          expect(r.counts.executed, 0, reason: path);
        }
        int n(String v) => verdicts.where((String x) => x == v).length;
        expect(
          r.counts.executed,
          n(VerdictCodes.executedAsReevaluated),
          reason: path,
        );
        expect(r.counts.expired, n(VerdictCodes.expired), reason: path);
        expect(r.counts.superseded, n(VerdictCodes.superseded), reason: path);
        expect(r.counts.blocked, n(VerdictCodes.blocked), reason: path);
        expect(
          r.counts.unrecoverable,
          r.unrecoverableGaps.length,
          reason: path,
        );
        for (final ResumeItem i in r.items) {
          expect(
            i.verdictLabel,
            _verdictLabels[i.verdictCode],
            reason: '$path ${i.workId}',
          );
        }
        for (final DataGapRow g in r.unrecoverableGaps) {
          expect(g.dataset, 'equity_snapshot', reason: path);
          expect(GapReasonCodes.values, contains(g.reasonCode), reason: path);
          expect(g.recoverable, isFalse, reason: path);
        }
        final String tail =
            _reportTails[r.mode.wire] ??
            (r.counts.executed > 0 ? _tailExecuted : _tailNothing);
        expect(
          r.headline,
          _headline(r.gapTradingDays, r.counts, tail),
          reason: path,
        );
        expect(
          r.modeLabel.startsWith('${r.gapTradingDays}거래일 미실행 — '),
          isTrue,
          reason: path,
        );
      }
      expect(modes, <ResumeMode>{
        ResumeMode.recoveryDry,
        ResumeMode.recoveryFull,
        ResumeMode.normal,
      });
    });

    test('C-56 ⑧ 사전 — 새 12 값 == 엔진 표 · byDomain 등재 · 도메인 사이 겹침 = JOURNAL_MISSING 뿐(🆕 v1.30 X1 짝 둘 예외) · 이름 2 · 세션 ∌ INVALID', () {
      final Map<String, Set<String>> engine = <String, Set<String>>{
        // core safety/stopped_decision.dart:28 · incident.dart:61 · intervention.dart:47 · rule_change.dart:56 · discretion.dart:19
        'stopped_decision_result': <String>{
          'STOPPED_NOT_ACTIVE',
          'STOPPED_WAIT_20D',
          'DECISION_ALREADY_MADE',
          'POSTMORTEM_MISSING',
          'FAMILY_AGREEMENT_MISSING',
          'JOURNAL_REQUIRED',
          'STOPPED_NOT_ELIGIBLE',
        },
        'postmortem_result': <String>{
          'INCIDENT_NOT_FOUND',
          'POSTMORTEM_BLANK',
          'POSTMORTEM_ALREADY_RECORDED',
        },
        'intervention_result': <String>{
          'INTERVENTION_CLOSED',
          'INTERVENTION_COOLING',
          'INTERVENTION_EXPIRED',
          'INTERVENTION_JOURNAL_MISSING',
          'INTERVENTION_STAGE_OUT_OF_ORDER',
          'INTERVENTION_SESSION_OPEN',
        },
        'rule_change_result': <String>{
          'RULE_CHANGE_APPROVAL_FIELDS_MISSING',
          'RULE_CHANGE_BASE_STALE',
          'RULE_CHANGE_CONFIG_UNKNOWN',
          'RULE_CHANGE_COOLING',
          'RULE_CHANGE_DD_LOCKED',
          'RULE_CHANGE_DECIDED',
          'RULE_CHANGE_FIELDS_MISSING',
          'RULE_CHANGE_JOURNAL_MISSING',
          'RULE_CHANGE_NOT_FOUND',
          'RULE_CHANGE_OUT_OF_WINDOW',
          'RULE_CHANGE_THIRD_PARTY_MISSING',
        },
        'discretion_result': <String>{
          'COUNT_EXCEEDED',
          'DELTA_EXCEEDED',
          'JOURNAL_MISSING',
        },
        // core resume/resume_judge.dart:51-111 · planned_work_machine.dart:20
        'resume_reason': <String>{
          'DUE_PASSED',
          'ADVISORY_PENDING',
          'SAFETY_STOP',
          'OBSERVING',
          'RECON_MISMATCH_REMAINS',
          'UNKNOWN_ORDERS_REMAIN',
          'RESIDUAL_ORDERS_REMAIN',
          'HUMAN_DECISION',
          'CONSERVATIVE_DEFER',
          'REEVALUATED_EMPTY',
          'REEVALUATED',
          'HUMAN_SKIP',
          'HUMAN_REDUCED',
          'HUMAN_AS_IS',
          'REEVALUATION_FAILED',
        },
        'seasonal_choice_result': <String>{
          'SEASONAL_DECISION_MISSING',
          'SEASONAL_NOT_ENTRY',
          'SEASONAL_NOT_PENDING',
          'SEASONAL_PAST_DUE',
        },
        'planned_work_reject': <String>{
          'PLANNED_WORK_UNCHANGED',
          'PLANNED_WORK_TERMINAL',
          'PLANNED_WORK_PAST_DUE',
          'PLANNED_WORK_NOT_DUE',
          'PLANNED_WORK_ILLEGAL',
          'PLANNED_WORK_UNKNOWN',
        },
        // core mode/sim_to_auto.dart:92-123 · sim_to_auto_commit.dart:49-79 · sim_to_auto_switch.dart:21-25 ·
        // handover_session.dart:75-88 · sim_to_auto.dart:53-77
        'sim_to_auto_result': <String>{
          'SIM_TO_AUTO_NOT_SIM_AUTO',
          'SIM_TO_AUTO_SAFETY_BLOCK',
          'SIM_TO_AUTO_TRIAL_INCOMPLETE',
          'SIM_TO_AUTO_GOLDEN_VECTOR_FAILED',
          'SIM_TO_AUTO_LIVE_KEYS_FAILED',
          'SIM_TO_AUTO_ACCOUNT_UNMAPPED',
          'SIM_TO_AUTO_COOLING',
          'SIM_TO_AUTO_SESSION_EXPIRED',
          'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE',
          'SIM_TO_AUTO_COMMIT_WINDOW',
        },
        'sim_to_auto_commit_result': <String>{
          'SIM_TO_AUTO_ALREADY_COMMITTED',
          'SIM_TO_AUTO_ACCOUNT_PROBE_MISSING',
          'SIM_TO_AUTO_SNAPSHOT_STALE',
          'SIM_TO_AUTO_HOLDINGS_NOT_ZERO',
          'SIM_TO_AUTO_BROKER_ACTIVITY_TODAY',
          'SIM_TO_AUTO_CASH_UNKNOWN',
          'SIM_TO_AUTO_ZERO_CASH',
          'SIM_TO_AUTO_COMMIT_ROLLED_BACK',
          'SIM_TO_AUTO_LEASE_MISMATCH',
          'SIM_LEDGER_FATE_SIM_CLOSED',
          'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED',
          'SIM_TO_AUTO_COMMIT_UNKNOWN',
        },
        'handover_session_result': <String>{
          'HANDOVER_SESSION_OPEN',
          'HANDOVER_SESSION_ROLLED_BACK',
        },
        'sim_to_auto_step': <String>{
          for (int i = 1; i <= 7; i++) 'SIM_TO_AUTO_S$i',
        },
      };
      for (final MapEntry<String, Set<String>> e in engine.entries) {
        expect(ContractCodes.byDomain[e.key], e.value, reason: e.key);
        for (final MapEntry<String, Set<String>> other
            in ContractCodes.byDomain.entries) {
          if (other.key == e.key) continue;
          final Set<String> overlap = e.value.intersection(other.value);
          // 🆕 v1.30(01 §38 · E16i K213 ⓒ) — `resume_reason` 의 OBSERVING · UNKNOWN_ORDERS_REMAIN 이 X1 사전과 같은 글자
          //    다른 축(C-5 문서 중복 · C-63 ⑦ 전수). 그 밖 겹침 0 은 그대로.
          expect(
            overlap.difference(<String>{
              'JOURNAL_MISSING',
              if (e.key == 'resume_reason' &&
                  (other.key == 'x1_gate_state' ||
                      other.key == 'x1_step_block')) ...<String>{
                'OBSERVING',
                'UNKNOWN_ORDERS_REMAIN',
              },
            }),
            isEmpty,
            reason: '${e.key} ↔ ${other.key} — 같은 글자 두 사전',
          );
        }
      }
      // 선언한 상수 == values(상수만 두고 values 에서 빠뜨리면 전역 조회가 다른 사전으로 통과시킨다 — 변이 V20).
      const Map<String, String> classOf = <String, String>{
        'StoppedDecisionResultCodes': 'stopped_decision_result',
        'PostmortemResultCodes': 'postmortem_result',
        'InterventionResultCodes': 'intervention_result',
        'RuleChangeResultCodes': 'rule_change_result',
        'DiscretionResultCodes': 'discretion_result',
        'ResumeItemReasonCodes': 'resume_reason',
        'SeasonalChoiceResultCodes': 'seasonal_choice_result',
        'PlannedWorkRejectCodes': 'planned_work_reject',
        'SimToAutoResultCodes': 'sim_to_auto_result',
        'SimToAutoCommitResultCodes': 'sim_to_auto_commit_result',
        'HandoverSessionResultCodes': 'handover_session_result',
        'SimToAutoStepIds': 'sim_to_auto_step',
      };
      final Map<String, Set<String>> declared = <String, Set<String>>{};
      for (final File f in dartSourcesIn(
        Directory('${libDir.path}/src/labels'),
      )) {
        final String src = stripComments(f.readAsStringSync());
        for (final RegExpMatch m in RegExp(
          r'abstract final class (\w+)\s*\{(.*?)\n\}',
          dotAll: true,
        ).allMatches(src)) {
          if (!classOf.containsKey(m[1])) continue;
          declared[m[1]!] = <String>{
            for (final RegExpMatch c in RegExp(
              r"static const String \w+\s*=\s*'([^']*)';",
            ).allMatches(m[2]!))
              c[1]!,
          };
        }
      }
      for (final MapEntry<String, String> e in classOf.entries) {
        expect(
          declared[e.key],
          ContractCodes.byDomain[e.value],
          reason: '${e.key} — 선언 상수 ≠ values',
        );
      }
      expect(SimToAutoResultCodes.windowBlocked, 'SIM_TO_AUTO_COMMIT_WINDOW');
      expect(
        SimToAutoCommitResultCodes.outcomeUnknown,
        'SIM_TO_AUTO_COMMIT_UNKNOWN',
      );
      expect(SimToAutoCommitResultCodes.values, hasLength(12));
      expect(
        HandoverSessionResultCodes.values,
        isNot(contains(LivePromotionResultCodes.sessionInvalid)),
      );
      expect(SimToAutoStepIds.ordered.toSet(), SimToAutoStepIds.values);
    });

    test('C-56 ⑨ 열거·동작 id — 값 이름 == 엔진 · STOPPED 와이어 A·B·C · 그 밖 기계적 · 새 동작 와이어 == 엔진 kind', () {
      // core safety/stopped_decision.dart:11 · intervention.dart:22 · resume/resume_judge.dart:345 값 이름.
      expect(
        <String>[
          for (final StoppedDecisionChoice v in StoppedDecisionChoice.values)
            v.name,
        ],
        <String>['a', 'b', 'c'],
      );
      expect(
        <String>[
          for (final StoppedDecisionChoice v in StoppedDecisionChoice.values)
            v.wire,
        ],
        <String>['A', 'B', 'C'],
      );
      expect(
        <String>[
          for (final InterventionStepOutcome v
              in InterventionStepOutcome.values)
            v.name,
        ],
        <String>['passed', 'doNothing', 'abandoned'],
      );
      expect(
        <String>[
          for (final SeasonalEntryChoice v in SeasonalEntryChoice.values)
            v.name,
        ],
        <String>['skip', 'reduced', 'asIs'],
      );
      for (final List<Enum> values in <List<Enum>>[
        InterventionStepOutcome.values,
        SeasonalEntryChoice.values,
      ]) {
        for (final Enum v in values) {
          final String wire = switch (v) {
            final InterventionStepOutcome o => o.wire,
            final SeasonalEntryChoice c => c.wire,
            _ => throw StateError('$v'),
          };
          expect(wire, _screamingSnake(v.name), reason: '$v');
        }
      }
      for (final MapEntry<SafetyActionId, String> e
          in _newSafetyWires.entries) {
        expect(e.key.wire, e.value, reason: e.key.name);
      }
      expect(
        SettingsActionId.handoverSessionStart.wire,
        'HANDOVER_SESSION_START',
      );
      expect(
        SettingsActionId.handoverSessionCancel.wire,
        'HANDOVER_SESSION_CANCEL',
      );
      expect(
        SettingsActionId.handoverSimLedgerFate.wire,
        'HANDOVER_SIM_LEDGER_FATE',
      );
    });

    test('C-56 ⑩ 제출 DTO 왕복 — JSON 키 · 숫자 = 원문 · 와이어·저널 id·맥락 칸 0 · 옛 KillChecklistAck 열림', () {
      const StoppedDecisionSubmission stopped = StoppedDecisionSubmission(
        choice: StoppedDecisionChoice.b,
        familyAgreement: true,
        rationaleBefore: 'r',
        expectedOutcome: 'e',
        ruleCited: 'c',
      );
      const PostmortemSubmission pm = PostmortemSubmission(
        incidentId: 'inc_fake_01',
        text: 't',
      );
      const RuleChangeApprovalSubmission approve = RuleChangeApprovalSubmission(
        requestId: 'rc_fake_01',
        goldenChanged: false,
        approver: 'a',
        thirdPartyNotified: true,
      );
      const DiscretionAdjustSubmission disc = DiscretionAdjustSubmission(
        deltaPct: '2.5',
        decisionId: 'dj_fake_01',
      );
      const KillChecklistSubmission kill = KillChecklistSubmission(
        ruleAction: 'r',
        reasonKind: KillActivationReason.emotion,
        emotion: 'e',
        intensity: '7',
        sleepHours: '4.5',
        scenarioNone: true,
        resumeCondition: 'c',
        scope: KillActivationScope.newEntriesOnly,
        openOrdersQueried: true,
        openOrdersCancelled: true,
        remainingCountZero: true,
        note: 'n',
      );
      final Map<Object, List<String>> keys = <Object, List<String>>{
        stopped: <String>[
          'choice',
          'family_agreement',
          'rationale_before',
          'expected_outcome',
          'rule_cited',
        ],
        pm: <String>['incident_id', 'text'],
        approve: <String>[
          'request_id',
          'golden_changed',
          'approver',
          'third_party_notified',
        ],
        disc: <String>['delta_pct', 'decision_id'],
        kill: <String>[
          'rule_action',
          'reason_kind',
          'emotion',
          'intensity',
          'sleep_hours',
          'scenario_id',
          'scenario_none',
          'resume_condition',
          'scope',
          'open_orders_queried',
          'open_orders_cancelled',
          'remaining_count_zero',
          'note',
        ],
      };
      for (final MapEntry<Object, List<String>> e in keys.entries) {
        final Map<String, Object?> json = switch (e.key) {
          final StoppedDecisionSubmission s => s.toJson(),
          final PostmortemSubmission s => s.toJson(),
          final RuleChangeApprovalSubmission s => s.toJson(),
          final DiscretionAdjustSubmission s => s.toJson(),
          final KillChecklistSubmission s => s.toJson(),
          _ => throw StateError('${e.key}'),
        };
        expect(json.keys.toList(), e.value, reason: '${e.key.runtimeType}');
      }
      expect(StoppedDecisionSubmission.fromJson(stopped.toJson()), stopped);
      expect(PostmortemSubmission.fromJson(pm.toJson()), pm);
      expect(RuleChangeApprovalSubmission.fromJson(approve.toJson()), approve);
      expect(DiscretionAdjustSubmission.fromJson(disc.toJson()), disc);
      expect(KillChecklistSubmission.fromJson(kill.toJson()), kill);
      expect(disc.toJson()['delta_pct'], isA<String>());
      expect(kill.toJson()['intensity'], isA<String>());
      expect(kill.toJson()['sleep_hours'], isA<String>());
      for (final String k in <String>[
        'journal_decision_id',
        'safety_event_id',
        'queried_at',
        'context',
      ]) {
        expect(kill.toJson().containsKey(k), isFalse, reason: k);
      }
      expect(stopped.toJson().containsKey('decision_id'), isFalse);
      final KillChecklistAck old = KillChecklistAck.fromJson(<String, Object?>{
        'safety_event_id': 'se_fake_01',
        'open_orders_queried': true,
        'open_orders_cancelled': true,
        'remaining_count_zero': true,
        'queried_at': '2026-11-16T05:00:00Z',
        'note': 'n',
        'context': const CommandContext(
          runMode: RunMode.live,
          operatingMode: OperatingMode.autoTrade,
          leaseEpoch: 1,
          deviceId: 'dev_fake_0001',
        ).toJson(),
      });
      expect(old.activation, isNull);
    });

    test(
      'C-56 ⑪ 포트 경계 — ui_*(ui_safety 제외) 소스에 v1.22 M5·X2 포트·VM·창구·위저드 동작 이름 0',
      () {
        final List<String> offenders = <String>[];
        for (final String name in uiPackageNames) {
          if (name == 'ui_safety') {
            continue;
          }
          final Directory lib = Directory(
            '${repoRoot.path}/packages/$name/lib',
          );
          if (!lib.existsSync()) {
            continue;
          }
          for (final File f in dartSourcesIn(lib)) {
            final String code = stripCommentsAndStrings(f.readAsStringSync());
            for (final String symbol in _portSymbols) {
              if (RegExp('\\b$symbol\\b').hasMatch(code)) {
                offenders.add('${shortPath(f)}: $symbol');
              }
            }
          }
        }
        expect(
          offenders,
          isEmpty,
          reason: '🔴 M5·X2 쓰기·게이트·simToAuto 위저드는 ui_safety 만 부른다(01 §31 · K56) — M9 S05 도 넘기기만 한다.',
        );
      },
    );

    test('C-56 ⑫ 받침대 — 창구 3 = 동기 throw · SafetyActions 새 4 = Future 에러(동기 throw 0) · confirmKillChecklist throw', () async {
      expect(
        () => UnimplementedBreakerLadderRepository().watchLadder(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedResumeGateRepository().watchGate(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedResumeRepository().watchLatest(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedResumeRepository().watchPlannedWork(),
        throwsA(isA<UnimplementedError>()),
      );
      final UnimplementedSafetyActions actions = UnimplementedSafetyActions();
      final List<Future<SafetyActionResult>> futures =
          <Future<SafetyActionResult>>[];
      expect(() {
        futures
          ..add(
            actions.runStoppedDecision(
              const StoppedDecisionSubmission(
                choice: StoppedDecisionChoice.a,
                rationaleBefore: '',
                expectedOutcome: '',
                ruleCited: '',
              ),
            ),
          )
          ..add(
            actions.runPostmortem(
              const PostmortemSubmission(incidentId: 'i', text: ''),
            ),
          )
          ..add(
            actions.runRuleChangeApproval(
              const RuleChangeApprovalSubmission(requestId: 'r', approver: ''),
            ),
          )
          ..add(
            actions.runDiscretionAdjust(
              const DiscretionAdjustSubmission(deltaPct: ''),
            ),
          );
      }, returnsNormally);
      for (final Future<SafetyActionResult> f in futures) {
        await expectLater(f, throwsA(isA<UnimplementedError>()));
      }
      expect(
        () => UnimplementedCommandApi().confirmKillChecklist(
          const KillChecklistSubmission(
            ruleAction: '',
            resumeCondition: '',
            note: '',
          ),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test(
      'C-56 ⑬ 글자 — 신설 15: DRY_RUN·손익 낱말·금액(J-1 가격 칸 3 제외)·금지어·카운트다운·8자리 숫자 0',
      () {
        for (final String path in _new) {
          for (final (String key, String s) in _keyedStrings(_rows(path))) {
            for (final String w in _forbiddenWords) {
              expect(s.contains(w), isFalse, reason: '$path $key — «$w»: $s');
            }
            if (!(path == FixturePaths.m6JournalSimBrokerReject &&
                _j1MoneyKeys.contains(key))) {
              expect(
                _money.hasMatch(s),
                isFalse,
                reason: '$path $key — 금액: $s',
              );
            }
            if (key != 'config_hash') {
              expect(
                _longDigits.hasMatch(s),
                isFalse,
                reason: '$path $key — 8자리 숫자: $s',
              );
            }
          }
        }
      },
    );

    test('C-56 ⑭ 모드 표지 — ModeMarkerText 4 == 엔진·셸 글자', () {
      expect(<String>[
        ModeMarkerText.sim,
        ModeMarkerText.advisory,
        ModeMarkerText.osSimPrefix,
        ModeMarkerText.osAdvisoryPrefix,
      ], _modeMarkers);
    });

    test('C-56 ⑮ fill-origin — 태그·식 == SPEC 02 :731 · values 5 · 합성 줄 왕복 · batch_f 두 상태 허용 · README 행', () {
      const LedgerModeCheck f = LedgerModeCheck.fillOrigin;
      expect(f.tag, 'fill-origin');
      expect(
        f.liveExpr,
        "fill_origin IN ('BROKER','MANUAL','BROKER_RECOVERED')",
      );
      expect(
        f.simExpr,
        "fill_origin IN ('BROKER','MANUAL','SIMULATED','BROKER_RECOVERED')",
      );
      expect(LedgerModeCheck.values, hasLength(5));
      expect(LedgerModeCheck.values.last, same(f));
      final String line = '  CHECK (${f.liveExpr}   -- @sim fill-origin';
      expect(ledgerDdlFor(LedgerFile.live, line), line);
      expect(ledgerDdlFor(LedgerFile.sim, line), contains(f.simExpr));
      final String raw = File('${ddlDir.path}/batch_f_x7_advisory.sql')
          .readAsStringSync();
      final int tags = RegExp(r'--\s*@sim\s+fill-origin\b')
          .allMatches(raw)
          .length;
      final Set<String> all = <String>{
        for (final FillOrigin o in FillOrigin.values) o.wire,
      };
      final Set<String> live = _fillOriginValues(LedgerFile.live, raw);
      final Set<String> sim = _fillOriginValues(LedgerFile.sim, raw);
      switch (tags) {
        case 0: // 태그 전(이 PR) — 두 판 같은 4값.
          expect(live, all);
          expect(sim, all);
        case 1: // 태그 뒤(엔진 재생성 PR) — LIVE 3 · SIM 4.
          expect(live, all.difference(<String>{'SIMULATED'}));
          expect(sim, all);
        default:
          fail('batch_f 의 @sim fill-origin 태그가 $tags 개다(0 또는 1)');
      }
      final String readme = File('${ddlDir.path}/README.md').readAsStringSync();
      expect(
        readme,
        contains('| `fill-origin` | `${f.liveExpr}` | `${f.simExpr}` |'),
      );
    });

    test('C-56 ⑯ resume_mode — batch_d resume_run_mirror.resume_mode = ResumeMode 4 ∧ not null · 같은 표 mode = RunMode 3', () {
      final List<CheckConstraint> checks = parseCheckConstraints(
        File('${ddlDir.path}/batch_d_supabase.sql'),
      );
      Set<String> values(String column) => <String>{
        for (final CheckConstraint c in checks)
          if (c.table == 'resume_run_mirror' && c.column == column) ...c.values,
      };
      expect(values('resume_mode'), <String>{
        for (final ResumeMode m in ResumeMode.values) m.wire,
      });
      expect(values('mode'), <String>{
        for (final RunMode m in RunMode.values) m.wire,
      });
      final String sql = File('${ddlDir.path}/batch_d_supabase.sql')
          .readAsStringSync();
      expect(
        RegExp(
          r'^\s*resume_mode text not null check',
          multiLine: true,
        ).hasMatch(sql),
        isTrue,
      );
    });

    test('C-56 ⑰ 추가형 사전 — kind 5(옛 둘 남음) · 결정 사유 +2(LIVE_OPENING 0) · 봉 공백 · 가상 체결 3', () {
      expect(PlannedWorkKindCodes.values, <String>{
        'SEASONAL_WINDOW',
        'DEFER_COUNT',
        'SPLIT_LEG',
        'MONTHLY_PLAN',
        'CARRY_OVER',
      });
      expect(DecisionReasonCodes.values, hasLength(12));
      expect(
        DecisionReasonCodes.values,
        containsAll(<String>['SIM_LEDGER_KEEP', 'SIM_LEDGER_DISCARD']),
      );
      expect(DecisionReasonCodes.values, isNot(contains('LIVE_OPENING')));
      expect(ContractCodes.isRegistered('LIVE_OPENING'), isFalse);
      expect(GapReasonCodes.values, contains('SIM_BAR_MISSING'));
      expect(
        BrokerRawCodes.values,
        containsAll(<String>[
          'SIM_INVALID_ORDER',
          'SIM_ORDER_NOT_FOUND',
          'SIM_CANCEL_TOO_LATE',
        ]),
      );
    });

    test(
      'C-56 ⑱ J-1 모의 행 — 1행 · SIM_INTERNAL · REJECTED · 칩 ∈ 가상 체결 3 · 봉투 LIVE',
      () {
        final Map<String, Object?> env = _env(
          FixturePaths.m6JournalSimBrokerReject,
        );
        expect((env['meta']! as Map<String, Object?>)['mode'], 'LIVE');
        final List<Map<String, Object?>> rows = _maps(env['rows']);
        expect(rows, hasLength(1));
        final TradeJournalEntry e = TradeJournalEntry.fromJson(rows.single);
        expect(e.mode, RunMode.simInternal);
        expect(e.status, JournalStatus.rejected);
        expect(e.reasons, isNotEmpty);
        for (final ReasonChip c in e.reasons) {
          expect(<String>{
            BrokerRawCodes.simInvalidOrder,
            BrokerRawCodes.simOrderNotFound,
            BrokerRawCodes.simCancelTooLate,
          }, contains(c.code));
        }
      },
    );
  });
}
