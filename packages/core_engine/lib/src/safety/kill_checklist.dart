// 킬스위치 체크리스트 두 벌 · 재개판 순차 상태기계 · `tryResume`(SPEC v2.40 04 §3-6 ③ · 03운 카드 ④ · ④-R · 설계 13 §8 R56 K3 · K4 · K5).
//
// 🔴 (가) 발동 뒤 기록 = 카드 ④ 7 + 확인 3 — 차단은 이미 걸려 있다(이 기록은 발동을 늦추지 않는다) · 마친 시각 = 48h 기준.
// 🔴 (나) 재개판 7문항 = 순차(앞 항목 통과 전 다음 거부 · 일괄 0) · 4번 «미충족» = 재개하지 않는다.
// 🔴 해제 값을 만드는 공개 함수는 [tryResume] 하나다(정적 검사 SC-2 판 — 시험이 이름을 센다).

import 'kill_switch.dart';

String _trim(String? s) => (s ?? '').trim();

/// 카드 ④ 2번 — 끄는 것이 규칙인가 감정인가.
enum KillReasonKind {
  /// 규칙.
  rule,

  /// 감정.
  emotion,
}

/// 카드 ④ 5번 — 끄는 범위(기본 = 신규 진입 차단).
enum KillScope {
  /// 신규 진입 차단만.
  newEntriesOnly,

  /// 전량 청산(🔴 앱은 자동으로 팔지 않는다 — 기록만 · 2단계 확인은 사람).
  liquidateAll,
}

/// (가) 발동 뒤 기록 — 카드 ④ 7(6번 = 엔진이 채운다).
class KillActivationAnswers {
  /// 답을 만든다.
  const KillActivationAnswers({
    required this.ruleAction,
    required this.reasonKind,
    this.emotion,
    this.intensity,
    this.sleepHours,
    this.scenarioId,
    this.scenarioNone = false,
    required this.resumeCondition,
    required this.scope,
    required this.journalDecisionId,
  });

  /// 1 · 규칙이 지시한 행동.
  final String ruleAction;

  /// 2 · 규칙인가 감정인가.
  final KillReasonKind reasonKind;

  /// 2 · 감정(감정이면 필수).
  final String? emotion;

  /// 2 · 강도 0~10(감정이면 필수).
  final int? intensity;

  /// 2 · 수면 시간 0~24(감정이면 필수).
  final double? sleepHours;

  /// 3 · W번호 · 트리거 ID.
  final String? scenarioId;

  /// 3 · «해당 없음»을 골랐다.
  final bool scenarioNone;

  /// 4 · 재개 조건.
  final String resumeCondition;

  /// 5 · 끄는 범위.
  final KillScope scope;

  /// 7 · 저널 `decision_id`.
  final String journalDecisionId;
}

/// (가) 확인 3(계약 `KillChecklistAck` 와 같은 칸).
class KillAckAnswers {
  /// 답을 만든다.
  const KillAckAnswers({
    required this.openOrdersQueried,
    required this.openOrdersCancelled,
    required this.remainingCountZero,
    required this.note,
  });

  /// 미체결 주문을 조회했다.
  final bool openOrdersQueried;

  /// 전량 취소했다.
  final bool openOrdersCancelled;

  /// 잔여 0 을 확인했다.
  final bool remainingCountZero;

  /// 1줄.
  final String note;
}

/// 체크리스트 판정 결과.
class KillChecklistVerdict {
  const KillChecklistVerdict._(this.code, {this.itemNo, this.p0 = false});

  /// 통과.
  static const KillChecklistVerdict ok = KillChecklistVerdict._(null);

  /// 거부 코드(통과면 null).
  final String? code;

  /// 막힌 항목 번호(1~7 · 확인 = null).
  final int? itemNo;

  /// 🔴 P0 를 다시 올린다(확인 3 이 엔진 미체결 수와 어긋남).
  final bool p0;

  /// 통과했나.
  bool get passed => code == null;
}

/// (가) 발동 뒤 기록 판정(K3) — [engineOpenOrders] = 엔진이 본 남은 미체결 수.
KillChecklistVerdict activationChecklistVerdict(
  KillActivationAnswers a,
  KillAckAnswers ack, {
  required int engineOpenOrders,
}) {
  KillChecklistVerdict item(int n) =>
      KillChecklistVerdict._('KILL_CHECKLIST_ITEM_MISSING', itemNo: n);
  if (_trim(a.ruleAction).isEmpty) return item(1);
  if (a.reasonKind == KillReasonKind.emotion) {
    final int? i = a.intensity;
    final double? h = a.sleepHours;
    if (_trim(a.emotion).isEmpty ||
        i == null ||
        i < 0 ||
        i > 10 ||
        h == null ||
        h < 0 ||
        h > 24) {
      return item(2);
    }
  }
  if (!a.scenarioNone && _trim(a.scenarioId).isEmpty) return item(3);
  if (_trim(a.resumeCondition).isEmpty) return item(4);
  if (_trim(a.journalDecisionId).isEmpty) return item(7);
  if (!ack.openOrdersQueried ||
      !ack.openOrdersCancelled ||
      !ack.remainingCountZero ||
      _trim(ack.note).isEmpty) {
    return const KillChecklistVerdict._('KILL_ACK_INCOMPLETE');
  }
  if (engineOpenOrders > 0) {
    return const KillChecklistVerdict._('KILL_ACK_MISMATCH', p0: true);
  }
  return KillChecklistVerdict.ok;
}

/// 재개판 3번.
enum ScenarioStatus {
  /// 해소됨.
  resolved,

  /// 진행 중.
  ongoing,

  /// 해당 없었음.
  notApplicable,
}

/// 재개판 4번.
enum ResumeConditionStatus {
  /// 충족.
  met,

  /// 미충족.
  unmet,
}

/// 재개판 한 문항의 답 — 그 번호에 맞는 칸만 채운다.
class ResumeItemAnswer {
  /// 답을 만든다.
  const ResumeItemAnswer(
    this.itemNo, {
    this.text,
    this.emotion,
    this.intensity,
    this.sleepHours,
    this.scenario,
    this.condition,
    this.acknowledged = false,
    this.decisionId,
    this.rationaleBefore,
    this.expectedOutcome,
    this.ruleCited,
  });

  /// 문항 번호(1~7).
  final int itemNo;

  /// 1 · 지금 규칙이 지시하는 것.
  final String? text;

  /// 2 · 감정.
  final String? emotion;

  /// 2 · 강도 0~10.
  final int? intensity;

  /// 2 · 수면 0~24.
  final double? sleepHours;

  /// 3.
  final ScenarioStatus? scenario;

  /// 4.
  final ResumeConditionStatus? condition;

  /// 5 · 6 · 확인했다.
  final bool acknowledged;

  /// 7 · 재개 저널.
  final String? decisionId;

  /// 7 · 사전 필드.
  final String? rationaleBefore, expectedOutcome, ruleCited;
}

/// 재개판 진행(K4) — 불변 값 · [accept] 가 새 값을 돌려준다.
class ResumeChecklist {
  const ResumeChecklist._(this.accepted, this.conditionUnmet);

  /// 빈 체크리스트.
  static const ResumeChecklist empty = ResumeChecklist._(
    <ResumeItemAnswer>[],
    false,
  );

  /// 통과한 답(순서대로).
  final List<ResumeItemAnswer> accepted;

  /// 4번 «미충족» — 🔴 더 진행하지 않는다.
  final bool conditionUnmet;

  /// 다음 문항 번호(다 마쳤으면 8).
  int get next => accepted.length + 1;

  /// 7문항을 다 마쳤나.
  bool get complete => accepted.length == 7;

  /// 7번 답(마쳤으면).
  ResumeItemAnswer? get journal => complete ? accepted.last : null;

  /// 답 하나를 받는다 — (새 상태 · 거부 코드) 중 하나.
  (ResumeChecklist?, String?) accept(ResumeItemAnswer a) {
    if (conditionUnmet) return (null, 'RESUME_CONDITION_UNMET');
    if (complete) return (null, 'RESUME_CHECKLIST_DONE');
    if (a.itemNo != next) return (null, 'RESUME_ITEM_OUT_OF_ORDER');
    final String? problem = _itemProblem(a);
    if (problem != null) return (null, problem);
    final bool unmet =
        a.itemNo == 4 && a.condition == ResumeConditionStatus.unmet;
    return (ResumeChecklist._(<ResumeItemAnswer>[...accepted, a], unmet), null);
  }
}

String? _itemProblem(ResumeItemAnswer a) {
  const String missing = 'RESUME_ITEM_MISSING';
  switch (a.itemNo) {
    case 1:
      return _trim(a.text).isEmpty ? missing : null;
    case 2:
      final int? i = a.intensity;
      final double? h = a.sleepHours;
      return _trim(a.emotion).isEmpty ||
              i == null ||
              i < 0 ||
              i > 10 ||
              h == null ||
              h < 0 ||
              h > 24
          ? missing
          : null;
    case 3:
      return a.scenario == null ? missing : null;
    case 4:
      return a.condition == null ? missing : null;
    case 5:
    case 6:
      return a.acknowledged ? null : missing;
    case 7:
      return _trim(a.decisionId).isEmpty ||
              _trim(a.rationaleBefore).isEmpty ||
              _trim(a.expectedOutcome).isEmpty ||
              _trim(a.ruleCited).isEmpty
          ? missing
          : null;
  }
  return 'RESUME_ITEM_OUT_OF_ORDER';
}

/// 재개 판정 결과.
class ResumeDecision {
  const ResumeDecision._({this.code, this.clearedAtUtc, this.decisionId});

  /// 거부 코드(통과면 null).
  final String? code;

  /// 통과 — 기록할 해제 시각(신뢰 시각).
  final DateTime? clearedAtUtc;

  /// 통과 — 기록할 재개 저널.
  final String? decisionId;

  /// 통과했나.
  bool get allowed => code == null;
}

/// 재개(K5 · 04 §3-6 `try_resume_v240`) — 🔴 해제 값을 만드는 유일한 공개 함수.
ResumeDecision tryResume(
  KillSwitchRecord record,
  DateTime? trustedNowUtc,
  ResumeChecklist checklist, {
  KillSwitchConfig cfg = kP0sKillSwitchConfig,
}) {
  ResumeDecision no(String c) => ResumeDecision._(code: c);
  final ResumeReadiness ready = resumeReadinessOf(
    record,
    trustedNowUtc,
    cfg: cfg,
  );
  switch (ready.kind) {
    case ResumeReadinessKind.inactive:
      return no('KILL_SWITCH_NOT_ACTIVE');
    case ResumeReadinessKind.checklistNotConfirmed:
      return no('RESUME_CHECKLIST_NOT_CONFIRMED');
    case ResumeReadinessKind.trustedTimeUnknown:
      return no('RESUME_TRUSTED_TIME_UNKNOWN');
    case ResumeReadinessKind.waiting:
      return no('RESUME_TOO_SOON');
    case ResumeReadinessKind.ready:
      break;
  }
  if (checklist.conditionUnmet) return no('RESUME_CONDITION_UNMET');
  if (!checklist.complete) return no('RESUME_CHECKLIST_INCOMPLETE');
  return ResumeDecision._(
    clearedAtUtc: trustedNowUtc!.toUtc(),
    decisionId: checklist.journal!.decisionId!.trim(),
  );
}
