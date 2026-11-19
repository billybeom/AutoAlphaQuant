// 🆕 E11q-b1b — M5-2 킬스위치 재개 게이트 VM · 문항 제출 읽기 · 결과(설계 13 §8 · 01 §30 K36 · K38 · §34 K153 · 미결 184 · 203 ·
// 표본 `m5/kill_resume_gate_*` · `m5/safety_action_results`(KILL_SWITCH_RESUME)).
//
// 🔴 상태 · 시각 = 엔진(`killSwitchViewOf` · `resumeReadinessOf`) · 순차 수락 = 엔진 `ResumeChecklist.accept` · 화면은 받은 글자 · 차례 그대로.
// 🔴 재생 = 발동 뒤 기록(카드 ④ (가))의 같은 번호 원문(`decision_journal` KILL_SWITCH_CHECKLIST) · 6번 = 기록 확인 줄 · 7번 = 없음 ·
//    확인 전 · 꺼짐 = 전부 없음.
// 🔴 받을 문항(nextItemNo) = 준비됨 ∧ 4번 미충족 아님 ∧ 잠김 아님일 때만 · 냉각 게이지 = 확인 뒤만(경과 ÷ 48h · 남은 시간 = 올림).
// 🔵 표본에 없는 문장(문항별 빈칸 · 꺼짐 · 저널 번호 · 이미 마침)은 표본 문장과 같은 꼴로 짓는다(미결 203 b1b 몫 · 발주자 위임 — 권고대로).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        GaugeCodes,
        GaugeProgress,
        KillResumeChoice,
        KillResumeCondition,
        KillResumeGateVm,
        KillResumeItemRow,
        KillResumeItemSubmission,
        KillResumeScenario,
        KillSwitchView,
        SafetyActionId,
        SafetyActionResult,
        TradeDate,
        UiLevel;

import '../ops/ledger_views.dart' show kstDateText;
import 'kill_checklist.dart'
    show
        KillReasonKind,
        KillScope,
        ResumeChecklist,
        ResumeConditionStatus,
        ResumeItemAnswer,
        ScenarioStatus;
import 'kill_switch.dart'
    show
        KillSwitchConfig,
        KillSwitchRecord,
        ResumeReadiness,
        ResumeReadinessKind,
        kP0sKillSwitchConfig,
        killSwitchViewOf,
        resumeReadinessOf;
import 'kill_switch_screen.dart' show kKillSwitchStaleAfter;

/// 발동 뒤 기록 원문(재생 원천 — `decision_journal.signal_value`).
class KillActivationReplay {
  /// 만든다.
  const KillActivationReplay({
    required this.ruleAction,
    required this.reasonKind,
    this.emotion,
    this.intensity,
    this.sleepHours,
    this.scenario,
    required this.resumeCondition,
    required this.scope,
  });

  /// 1 · 규칙이 지시한 행동.
  final String ruleAction;

  /// 2 · 규칙 / 감정.
  final KillReasonKind reasonKind;

  /// 2 · 감정 · 강도 · 수면(감정일 때만).
  final String? emotion;
  final int? intensity;
  final double? sleepHours;

  /// 3 · 시나리오(null = 해당 없음).
  final String? scenario;

  /// 4 · 재개 조건.
  final String resumeCondition;

  /// 5 · 끄는 범위.
  final KillScope scope;
}

/// M5-2 글자(표본 그대로).
abstract final class KillResumeGateTexts {
  /// 재개판 7문항(SPEC 04 §3-6 ③ «재개판» · 01 §30 K38).
  static const List<String> items = <String>[
    '그때 적은 «규칙이 지시한 행동»을 다시 읽었다 — 지금 규칙은 무엇을 지시하는가',
    '그때의 감정 · 수면 기록을 다시 읽었다 — 지금 상태(감정 · 강도 · 수면)는',
    '그때 짚은 시나리오가 지금 어떻게 됐는가',
    '그때 적은 재개 조건이 지금 충족됐는가',
    '발동 동안 생긴 일(미체결 취소 결과 · 체결 · 남은 UNKNOWN)을 확인했다',
    '확인 시각부터 48h 가 지났음을 확인했다',
    '재개 저널을 썼다 — 사전 필드 3 · decision_id',
  ];

  /// 냉각 게이지.
  static const String cooldownLabel = '냉각 기간';
  static const String cooldownDone = '냉각 완료';
  static const String cooldownUnknown = '신뢰 시각 확인 중';
  static String cooldownLeft(int hours) => '남은 $hours시간';

  /// 4번 미충족 뒤 막힘(SPEC 원문).
  static const String conditionUnmet = '미충족이면 재개하지 않는다';

  /// 선택지(SPEC 원문).
  static const String resolved = '해소됨';
  static const String ongoing = '진행 중';
  static const String notApplicable = '해당 없었음';
  static const String met = '충족';
  static const String unmet = '미충족';

  /// 5 · 6번 답(확인 문항).
  static const String acknowledged = '확인했다';

  static String _hours(double h) =>
      h == h.roundToDouble() ? '${h.toInt()}' : '$h';

  /// 재생 글자.
  static String? replay(
    int itemNo,
    KillActivationReplay r,
    String? confirmed,
  ) => switch (itemNo) {
    1 => '그때 적은 행동: ${r.ruleAction.trim()}',
    2 =>
      r.reasonKind == KillReasonKind.emotion
          ? '그때: ${(r.emotion ?? '').trim()} · 강도 ${r.intensity} · 수면 ${_hours(r.sleepHours ?? 0)}시간'
          : '그때: 규칙이라고 적었다',
    3 => '그때 짚은 시나리오: ${r.scenario?.trim() ?? '해당 없음'}',
    4 => '그때 적은 재개 조건: ${r.resumeCondition.trim()}',
    5 =>
      '그때 고른 범위: ${r.scope == KillScope.liquidateAll ? '전량 청산' : '신규 진입 차단만'}',
    6 => confirmed,
    _ => null,
  };

  /// 받은 답 글자.
  static String? answered(ResumeItemAnswer a) => switch (a.itemNo) {
    1 => '지금 규칙: ${(a.text ?? '').trim()}',
    2 =>
      '지금: ${(a.emotion ?? '').trim()} · 강도 ${a.intensity} · 수면 ${_hours(a.sleepHours ?? 0)}시간',
    3 => switch (a.scenario) {
      ScenarioStatus.resolved => resolved,
      ScenarioStatus.ongoing => ongoing,
      ScenarioStatus.notApplicable => notApplicable,
      null => null,
    },
    4 => switch (a.condition) {
      ResumeConditionStatus.met => met,
      ResumeConditionStatus.unmet => unmet,
      null => null,
    },
    5 || 6 => acknowledged,
    _ => null,
  };

  /// 결과 — 완료.
  static const String done =
      '재개 체크리스트 7번까지 마쳤습니다 — 킬스위치를 풀었습니다. 다음 회차부터 규칙대로 움직입니다.';

  /// 결과 — 한 문항 받음.
  static String accepted(int n) => '$n번 답을 받았습니다 — ${n + 1}번으로 넘어갑니다.';

  /// 결과 — 문항별 빈칸.
  static String missing(int n) => switch (n) {
    1 => '1번 칸이 비었습니다 — 지금 규칙이 무엇을 지시하는지 적으십시오.',
    2 => '2번 칸이 비었습니다 — 감정 · 강도 · 수면을 모두 적으십시오.',
    3 => '3번을 고르십시오 — 해소됨 · 진행 중 · 해당 없었음 중 하나입니다.',
    4 => '4번을 고르십시오 — 충족 · 미충족 중 하나입니다.',
    5 => '5번을 확인하십시오 — 발동 동안 생긴 일을 확인한 뒤 누르십시오.',
    6 => '6번을 확인하십시오 — 48시간이 지났는지 확인한 뒤 누르십시오.',
    _ => '7번 칸이 비었습니다 — 재개 저널의 사전 필드 3개를 모두 적으십시오.',
  };
}

String _mdHm(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(k.month)}-${two(k.day)} ${two(k.hour)}:${two(k.minute)}';
}

List<KillResumeChoice> _choices(int itemNo) => switch (itemNo) {
  3 => const <KillResumeChoice>[
    KillResumeChoice(
      label: KillResumeGateTexts.resolved,
      scenario: KillResumeScenario.resolved,
    ),
    KillResumeChoice(
      label: KillResumeGateTexts.ongoing,
      scenario: KillResumeScenario.ongoing,
    ),
    KillResumeChoice(
      label: KillResumeGateTexts.notApplicable,
      scenario: KillResumeScenario.notApplicable,
    ),
  ],
  4 => const <KillResumeChoice>[
    KillResumeChoice(
      label: KillResumeGateTexts.met,
      condition: KillResumeCondition.met,
    ),
    KillResumeChoice(
      label: KillResumeGateTexts.unmet,
      condition: KillResumeCondition.unmet,
    ),
  ],
  _ => const <KillResumeChoice>[],
};

/// M5-2 한 화면 — [replay] = 발동 뒤 기록 원문(확인 전 · 없으면 null) · [checklist] = 지금 초안(구현이 든다) ·
/// [lockedLabel] = 운영 등급 생체 축소(지금 조립 = null).
KillResumeGateVm killResumeGateVmOf({
  required KillSwitchRecord record,
  required DateTime? trustedNowUtc,
  required DateTime nowUtc,
  required KillActivationReplay? replay,
  required ResumeChecklist checklist,
  String? lockedLabel,
  KillSwitchConfig cfg = kP0sKillSwitchConfig,
}) {
  final String day = kstDateText(nowUtc);
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  final AsOf asOf = AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kKillSwitchStaleAfter,
    label:
        '안전 기준 $day ${k.hour.toString().padLeft(2, '0')}:${k.minute.toString().padLeft(2, '0')}',
  );
  final KillSwitchView view = killSwitchViewOf(record, trustedNowUtc, cfg: cfg);
  final ResumeReadiness ready = resumeReadinessOf(
    record,
    trustedNowUtc,
    cfg: cfg,
  );
  final bool confirmed =
      ready.kind != ResumeReadinessKind.inactive &&
      ready.kind != ResumeReadinessKind.checklistNotConfirmed;
  final Map<int, ResumeItemAnswer> answered = <int, ResumeItemAnswer>{
    if (confirmed)
      for (final ResumeItemAnswer a in checklist.accepted) a.itemNo: a,
  };
  final bool unmet = confirmed && checklist.conditionUnmet;
  final List<KillResumeItemRow> items = <KillResumeItemRow>[
    for (int i = 0; i < KillResumeGateTexts.items.length; i++)
      KillResumeItemRow(
        itemNo: i + 1,
        label: KillResumeGateTexts.items[i],
        replayText: confirmed && replay != null
            ? KillResumeGateTexts.replay(
                i + 1,
                replay,
                view.checklistStateLabel,
              )
            : null,
        answeredText: answered[i + 1] == null
            ? null
            : KillResumeGateTexts.answered(answered[i + 1]!),
        level: answered[i + 1] == null
            ? UiLevel.info
            : (i + 1 == 4 &&
                      answered[4]!.condition == ResumeConditionStatus.unmet
                  ? UiLevel.blocked
                  : UiLevel.ok),
        choices: _choices(i + 1),
      ),
  ];
  final GaugeProgress? cooldown = switch (ready.kind) {
    ResumeReadinessKind.inactive ||
    ResumeReadinessKind.checklistNotConfirmed => null,
    ResumeReadinessKind.trustedTimeUnknown => const GaugeProgress(
      code: GaugeCodes.cooldown,
      label: KillResumeGateTexts.cooldownLabel,
      normalized: 0,
      valueText: KillResumeGateTexts.cooldownUnknown,
    ),
    ResumeReadinessKind.waiting => GaugeProgress(
      code: GaugeCodes.cooldown,
      label: KillResumeGateTexts.cooldownLabel,
      normalized: 1 - ready.remaining!.inMinutes / cfg.resumeMinWait.inMinutes,
      valueText: KillResumeGateTexts.cooldownLeft(
        (ready.remaining!.inMinutes / 60).ceil(),
      ),
    ),
    ResumeReadinessKind.ready => const GaugeProgress(
      code: GaugeCodes.cooldown,
      label: KillResumeGateTexts.cooldownLabel,
      normalized: 1,
      valueText: KillResumeGateTexts.cooldownDone,
    ),
  };
  final bool open =
      ready.kind == ResumeReadinessKind.ready && !unmet && lockedLabel == null;
  return KillResumeGateVm(
    readinessLabel: view.stateLabel,
    level: switch (ready.kind) {
      ResumeReadinessKind.inactive => UiLevel.ok,
      ResumeReadinessKind.checklistNotConfirmed => UiLevel.act,
      ResumeReadinessKind.trustedTimeUnknown => UiLevel.blocked,
      ResumeReadinessKind.waiting => UiLevel.watch,
      ResumeReadinessKind.ready => unmet ? UiLevel.blocked : UiLevel.info,
    },
    etaText: view.releaseEtaText,
    cooldown: cooldown,
    items: items,
    nextItemNo: open ? checklist.next : null,
    blockedText: switch (ready.kind) {
      ResumeReadinessKind.checklistNotConfirmed => view.checklistStateLabel,
      ResumeReadinessKind.ready =>
        unmet ? KillResumeGateTexts.conditionUnmet : null,
      _ => null,
    },
    lockedLabel: lockedLabel,
    asOf: asOf,
  );
}

/// 제출 원문 → 엔진 답 — 강도 · 수면 숫자 아님 = 빈칸(엔진 `RESUME_ITEM_MISSING`) · 7번 저널 id = [journalDecisionId](구현이 짓는다).
ResumeItemAnswer killResumeItemAnswerOf(
  KillResumeItemSubmission s, {
  String? journalDecisionId,
}) => ResumeItemAnswer(
  s.itemNo,
  text: s.text,
  emotion: s.emotion,
  intensity: int.tryParse((s.intensity ?? '').trim()),
  sleepHours: double.tryParse((s.sleepHours ?? '').trim()),
  scenario: switch (s.scenario) {
    KillResumeScenario.resolved => ScenarioStatus.resolved,
    KillResumeScenario.ongoing => ScenarioStatus.ongoing,
    KillResumeScenario.notApplicable => ScenarioStatus.notApplicable,
    null => null,
  },
  condition: switch (s.condition) {
    KillResumeCondition.met => ResumeConditionStatus.met,
    KillResumeCondition.unmet => ResumeConditionStatus.unmet,
    null => null,
  },
  acknowledged: s.acknowledged,
  decisionId: s.itemNo == 7 ? journalDecisionId : null,
  rationaleBefore: s.rationaleBefore,
  expectedOutcome: s.expectedOutcome,
  ruleCited: s.ruleCited,
);

/// 재개 동작 결과 — [code] null ∧ [done] = 해제 · [code] null = [acceptedItemNo] 받음 · 아니면 거부(글자 = 표본 · 같은 꼴).
SafetyActionResult killResumeResultOf({
  required String actionRunId,
  String? code,
  bool done = false,
  int? acceptedItemNo,
  int? submittedItemNo,
  int? nextItemNo,
  DateTime? etaUtc,
}) {
  final (UiLevel level, String headline) = switch (code) {
    null when done => (UiLevel.ok, KillResumeGateTexts.done),
    null => (UiLevel.info, KillResumeGateTexts.accepted(acceptedItemNo!)),
    'RESUME_TOO_SOON' => (
      UiLevel.watch,
      '아직 기다리는 중입니다 — 해제 가능 예정 ${etaUtc == null ? '' : _mdHm(etaUtc)}.',
    ),
    'RESUME_ITEM_MISSING' => (
      UiLevel.act,
      KillResumeGateTexts.missing(submittedItemNo ?? 1),
    ),
    'RESUME_ITEM_OUT_OF_ORDER' => (
      UiLevel.act,
      '앞 문항을 먼저 마치십시오 — 지금 차례는 $nextItemNo번입니다.',
    ),
    'RESUME_CONDITION_UNMET' => (
      UiLevel.blocked,
      '재개 조건이 충족되지 않았습니다 — 재개하지 않습니다.',
    ),
    'RESUME_TRUSTED_TIME_UNKNOWN' => (
      UiLevel.blocked,
      '서버 시각을 확인하지 못해 재개를 막았습니다.',
    ),
    'RESUME_CHECKLIST_NOT_CONFIRMED' => (UiLevel.act, '발동 뒤 체크리스트를 먼저 마치십시오.'),
    'KILL_SWITCH_NOT_ACTIVE' => (UiLevel.info, '킬스위치가 꺼져 있습니다 — 재개할 것이 없습니다.'),
    'JOURNAL_ID_TAKEN' => (UiLevel.act, '저널 번호가 이미 쓰였습니다 — 7번을 다시 제출하십시오.'),
    'RESUME_CHECKLIST_DONE' => (UiLevel.info, '재개 체크리스트를 이미 마쳤습니다.'),
    final String other => throw ArgumentError.value(
      other,
      'code',
      '모르는 재개 거부 코드',
    ),
  };
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: SafetyActionId.killSwitchResume,
    level: level,
    headline: headline,
    reasonCode: code,
    retryable: false,
  );
}
