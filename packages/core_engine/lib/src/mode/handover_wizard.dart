// 🆕 E11q-c1 — M5-11 simToAuto 위저드 VM · S1 체험 카드 · 동작 결과 글자(설계 13 §8 R191 · 01 §35 K167~K176 ·
// 미결 207 ⓓ · 표본 `m5/handover_wizard_*` · `m5/handover_sim_to_auto_action_results`).
//
// 🔴 판정 = `judgeSimToAuto` 그대로 · 단계 줄 = `simToAutoPlan` 그대로 — 이 파일은 감싸기만 한다(분류 · 수치 0).
// 🔴 단계별 허용 동작(K169 · C-60 ③) — S5 = 모의 기록 고르기 2(세션 전 · 아직 안 고름 · S1~S4 통과) ·
//    S6 = 세션 시작 1(세션 없음 또는 기한 지남 · S1~S5 통과) · S7 = 취소(세션 열림 · 기한 안) + 확정(`readyToCommit` 일 때만) ·
//    S2 = 0(실행은 S10 진단 화면 — 링크로 보낸다) · 그 밖 = 0 · 세션 id = 엔진이 `handover_session_id` args 에 넣는다.
// 🔴 쓰기 창구 없음 · 잠김 · 확정됨 = 동작 0(C-60 ②) · 신뢰 시각 모름 = 자리는 그대로 두고 결과 원문으로 거부(K176).
// 🔴 색 = 행 `level`(K172) — PASS = OK(체험 ② 경고 후 진행 = WATCH) · BLOCK = BLOCKED(냉각 = WATCH) ·
//    UNKNOWN «아직» = INFO(시각 모름 = WATCH).
// 🔴 시각 글자 = 엔진(카운트다운 0 · 시각이 지나면 조립이 새 VM · K170).
// 🔵 버튼 · 링크 · 시각 · 확정 · 고름 결과 글자 = 계약 표본이 제안한 문장(«(합성)» 표지 뗌 · c0 R188 결 · 발주자 위임 — 권고대로).

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        AppRoutes,
        GateState,
        HandoverPath,
        HandoverPlan,
        HandoverStep,
        HandoverWizardStepRow,
        HandoverWizardVm,
        LinkAction,
        SettingsActionCall,
        SettingsActionId,
        SimTrialCard,
        SimTrialCheck,
        UiLevel;

import '../ops/ledger_views.dart' show kstMinuteText;
import '../sim/sim_trial.dart'
    show SimTrialItemResult, SimTrialItemState, SimTrialReport;
import 'handover_session.dart' show HandoverSessionCodes;
import 'sim_to_auto.dart'
    show
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoReport,
        SimToAutoStep,
        SimToAutoStepResult,
        simToAutoPlan;
import 'sim_to_auto_commit.dart' show SimToAutoCommitCodes;
import 'sim_to_auto_switch.dart' show kSimToAutoCommitUnknown;

/// M5-11 위저드 글자(표본 제안 문장 · 엔진 사전 밖 몫).
abstract final class HandoverWizardTexts {
  /// S5 — 앱 밖 보관본.
  static const String fateKeep = '앱 밖 보관본으로 남기기';

  /// S5 — 지움.
  static const String fateDiscard = '모의 기록 지우기';

  /// S6 — 시작.
  static const String start = '생체 확인하고 전환 시작';

  /// S6 — 기한이 지난 뒤 다시.
  static const String restart = '처음부터 다시 시작';

  /// S7 — 취소.
  static const String cancel = '전환 취소';

  /// S7 — 확정.
  static const String commit = '확정하기';

  /// S2 → 진단(S10).
  static const String linkGolden = '자가검사 보기';

  /// S3 → 키(S02).
  static const String linkLiveKeys = '실전 키 등록';

  /// S4 → 계좌(S03).
  static const String linkAccounts = '계좌 연결 보기';

  /// 냉각 끝 · 확정 기한.
  static String coolingEnds(DateTime utc) => '냉각 끝 ${kstMinuteText(utc)}';
  static String deadline(DateTime utc) => '확정 기한 ${kstMinuteText(utc)}';

  /// 고지 — 승인된 설정 없음(미결 205 ⓓ · SAF-405 — 실전 기동 = 승인 config 필수).
  static const String configNotApproved =
      '승인된 설정이 없으면 확정할 수 없습니다 — 규칙 변경 게이트에서 첫 승인을 먼저 요청하십시오';

  /// 확정 뒤(K175).
  static const String committedHeadline = '실전 관찰로 옮겼습니다';
  static const String done = '확정됨 — 실전 관찰 중(주문 0) · 승격은 운영 화면에서 합니다';

  /// 확정 뒤 단계 글자(모의 기록은 실전 파일에 없다 — 단계별 원문 대신).
  static const String stepDone = '마침';
  static String biometricAt(DateTime utc) => '생체 확인 ${kstMinuteText(utc)}';
  static String committedAt(DateTime utc) => '확정 ${kstMinuteText(utc)}';

  /// S5 고름 결과.
  static const String fateKept = '모의 기록을 앱 밖 보관본으로 남기기로 했습니다.';
  static const String fateDiscarded = '모의 기록을 실전 전환 뒤 지우기로 했습니다.';
  static const String fateSimClosed = '모의 파일이 이미 닫혀 고른 것을 적지 않았습니다.';
  static const String fateNotSimAuto = '모의투자 자동 매매 중일 때만 실전으로 옮길 수 있습니다.';

  /// 체험 항목 상태 글자.
  static String trialState(SimTrialItemState s) => switch (s) {
    SimTrialItemState.passed => '통과',
    SimTrialItemState.autoPassed => '자동 통과',
    SimTrialItemState.open => '아직',
    SimTrialItemState.openWarn => '아직 — 경고 후 진행',
  };
}

/// 체험 항목 짝(계약 C-53 ⑨) — 채움 = OK · 아직 = WATCH · 아직(소프트) = INFO.
UiLevel simTrialStateLevel(SimTrialItemState s) => switch (s) {
  SimTrialItemState.passed || SimTrialItemState.autoPassed => UiLevel.ok,
  SimTrialItemState.open => UiLevel.watch,
  SimTrialItemState.openWarn => UiLevel.info,
};

/// S1 상세(04 :1222 «같은 그릇» · K171 · 미결 177 의 위저드 몫) — 머리 · 카운터 · 5항목 = 엔진 판정 그대로.
SimTrialCard simTrialCardOf(SimTrialReport r) => SimTrialCard(
  headline: r.headline,
  summaryText: r.counters.text,
  checks: <SimTrialCheck>[
    for (final SimTrialItemResult i in r.items)
      SimTrialCheck(
        itemCode: i.item.code,
        label: i.item.label,
        detailText: i.detail,
        itemState: i.state.wire,
        stateLabel: HandoverWizardTexts.trialState(i.state),
        level: simTrialStateLevel(i.state),
      ),
  ],
);

/// 확정 뒤 원천(실전 파일의 COMMITTED 세션 · 없으면 시각 null).
class HandoverCommitted {
  /// 만든다.
  const HandoverCommitted({this.openedAtUtc, this.committedAtUtc});

  /// 생체 확인(세션 열림) 시각.
  final DateTime? openedAtUtc;

  /// 확정(세션 닫힘) 시각.
  final DateTime? committedAtUtc;
}

UiLevel _stepLevel(SimToAutoStepResult s, {required bool trialWarn}) =>
    switch (s.state) {
      GateState.pass =>
        s.step == SimToAutoStep.trial && trialWarn ? UiLevel.watch : UiLevel.ok,
      GateState.block =>
        s.blockedReasonCode == SimToAutoCodes.cooling
            ? UiLevel.watch
            : UiLevel.blocked,
      GateState.unknown || GateState.notApplicable =>
        s.blockedReasonCode == SimToAutoCodes.trustedTimeUnavailable
            ? UiLevel.watch
            : UiLevel.info,
    };

/// 머리 색(계약 `HandoverWizardVm.level` 짝) — 확정 가능 = OK · 냉각 · 시각 모름 = WATCH · «아직» = INFO · 막힘 = BLOCKED.
UiLevel handoverWizardLevelOf(SimToAutoReport r) {
  final String? code = r.code;
  if (!r.applicable) return UiLevel.info;
  if (code == null) return UiLevel.ok;
  if (code == SimToAutoCodes.cooling ||
      code == SimToAutoCodes.trustedTimeUnavailable) {
    return UiLevel.watch;
  }
  for (final SimToAutoStep s in SimToAutoStep.values) {
    if (s.stepId == code) return UiLevel.info;
  }
  return UiLevel.blocked;
}

LinkAction? _link(SimToAutoStepResult s) {
  if (s.state == GateState.pass) return null;
  return switch (s.step) {
    SimToAutoStep.goldenVector => const LinkAction(
      label: HandoverWizardTexts.linkGolden,
      deepLink: AppRoutes.settingsDiagnostics,
    ),
    SimToAutoStep.liveKeys => const LinkAction(
      label: HandoverWizardTexts.linkLiveKeys,
      deepLink: AppRoutes.settingsCredentials,
    ),
    SimToAutoStep.accounts => const LinkAction(
      label: HandoverWizardTexts.linkAccounts,
      deepLink: AppRoutes.settingsAccounts,
    ),
    _ => null,
  };
}

/// 🔴 M5-11 한 화면(207 ⓓ) — [report] = 지금 판정(`judgeSimToAuto`) · [trial] = 그 판정의 체험 입력 ·
/// [fate] = S5 고름(아직 = null) · [sessionId] = 안 닫힌 simToAuto 세션(만료 포함 · 없음 = null — 화면은 읽지 않는다) ·
/// [configApproved] = 지금 설정이 SAF-405 승인을 받았나(아니면 고지 한 줄) · [canAct] = 위저드 쓰기 창구가 있나 ·
/// [lockedLabel] = 운영 등급 생체 축소(미결 169) · [committed] = 실전 파일에 확정 행이 있다(non-null ⇒ 확정 뒤 본문) ·
/// [observedAtUtc] = 판정 시각(기기 시계 — 신선도 5분).
HandoverWizardVm handoverWizardVmOf({
  required SimToAutoReport report,
  required SimTrialReport trial,
  required SimLedgerFate? fate,
  required String? sessionId,
  required bool configApproved,
  required bool canAct,
  required DateTime observedAtUtc,
  String? lockedLabel,
  HandoverCommitted? committed,
}) {
  final HandoverPlan plan = simToAutoPlan(report, observedAtUtc: observedAtUtc);
  if (committed != null) return _committedVm(plan, committed, lockedLabel);
  if (!report.applicable) {
    return HandoverWizardVm(
      headline: report.headline,
      level: UiLevel.info,
      reasonCode: report.code,
      pathLabel: plan.pathLabel,
      lockedLabel: lockedLabel,
      asOf: plan.asOf,
    );
  }
  final bool act = canAct && lockedLabel == null;
  final SimToAutoStepResult s7 = report.of(SimToAutoStep.cooling);
  final bool expired = s7.blockedReasonCode == SimToAutoCodes.sessionExpired;
  final bool sessionLive = sessionId != null && !expired;
  final bool trialWarn = report.needsTrialWarning;

  bool passedBefore(SimToAutoStep s) {
    for (final SimToAutoStepResult r in report.steps) {
      if (r.step.index >= s.index) return true;
      if (r.state != GateState.pass) return false;
    }
    return true;
  }

  List<SettingsActionCall> actionsOf(SimToAutoStepResult s) {
    if (!act) return const <SettingsActionCall>[];
    switch (s.step) {
      case SimToAutoStep.simLedger:
        if (fate != null ||
            sessionId != null ||
            !passedBefore(SimToAutoStep.simLedger)) {
          return const <SettingsActionCall>[];
        }
        return <SettingsActionCall>[
          SettingsActionCall(
            id: SettingsActionId.handoverSimLedgerFate,
            args: <String, String>{'fate': SimLedgerFate.keep.wire},
            label: HandoverWizardTexts.fateKeep,
          ),
          SettingsActionCall(
            id: SettingsActionId.handoverSimLedgerFate,
            args: <String, String>{'fate': SimLedgerFate.discard.wire},
            label: HandoverWizardTexts.fateDiscard,
          ),
        ];
      case SimToAutoStep.biometric:
        if (sessionLive || !passedBefore(SimToAutoStep.biometric)) {
          return const <SettingsActionCall>[];
        }
        return <SettingsActionCall>[
          SettingsActionCall(
            id: SettingsActionId.handoverSessionStart,
            args: <String, String>{'path': HandoverPath.simToAuto.wire},
            label: expired
                ? HandoverWizardTexts.restart
                : HandoverWizardTexts.start,
          ),
        ];
      case SimToAutoStep.cooling:
        final String? id = sessionId;
        if (id == null || expired) return const <SettingsActionCall>[];
        final Map<String, String> args = <String, String>{
          'handover_session_id': id,
        };
        return <SettingsActionCall>[
          if (report.readyToCommit && s.state == GateState.pass)
            SettingsActionCall(
              id: SettingsActionId.handoverCommit,
              args: args,
              label: HandoverWizardTexts.commit,
            ),
          SettingsActionCall(
            id: SettingsActionId.handoverSessionCancel,
            args: args,
            label: HandoverWizardTexts.cancel,
          ),
        ];
      case SimToAutoStep.trial ||
          SimToAutoStep.goldenVector ||
          SimToAutoStep.liveKeys ||
          SimToAutoStep.accounts:
        return const <SettingsActionCall>[];
    }
  }

  final DateTime? coolEnd = report.coolingEndsAtUtc;
  final DateTime? deadline = report.commitDeadlineUtc;
  final bool showTimes = sessionLive && coolEnd != null && deadline != null;
  return HandoverWizardVm(
    headline: report.headline,
    level: handoverWizardLevelOf(report),
    reasonCode: report.code,
    pathLabel: plan.pathLabel,
    rows: <HandoverWizardStepRow>[
      for (int i = 0; i < report.steps.length; i++)
        HandoverWizardStepRow(
          step: plan.steps[i],
          level: _stepLevel(report.steps[i], trialWarn: trialWarn),
          link: _link(report.steps[i]),
          actions: actionsOf(report.steps[i]),
        ),
    ],
    trial: report.of(SimToAutoStep.trial).state != GateState.pass || trialWarn
        ? simTrialCardOf(trial)
        : null,
    coolingText: showTimes ? HandoverWizardTexts.coolingEnds(coolEnd) : null,
    deadlineText: showTimes ? HandoverWizardTexts.deadline(deadline) : null,
    windowText: s7.state == GateState.pass ? report.window?.label : null,
    noticeText: configApproved ? null : HandoverWizardTexts.configNotApproved,
    lockedLabel: lockedLabel,
    asOf: plan.asOf,
  );
}

HandoverWizardVm _committedVm(
  HandoverPlan plan,
  HandoverCommitted c,
  String? lockedLabel,
) {
  String labelOf(SimToAutoStep s) {
    final DateTime? opened = c.openedAtUtc;
    final DateTime? at = c.committedAtUtc;
    if (s == SimToAutoStep.biometric && opened != null) {
      return HandoverWizardTexts.biometricAt(opened);
    }
    if (s == SimToAutoStep.cooling && at != null) {
      return HandoverWizardTexts.committedAt(at);
    }
    return HandoverWizardTexts.stepDone;
  }

  return HandoverWizardVm(
    headline: HandoverWizardTexts.committedHeadline,
    level: UiLevel.ok,
    pathLabel: plan.pathLabel,
    rows: <HandoverWizardStepRow>[
      for (final SimToAutoStep s in SimToAutoStep.values)
        HandoverWizardStepRow(
          step: HandoverStep(
            stepId: s.stepId,
            order: s.index + 1,
            title: s.title,
            whyLine: s.whyLine,
            state: GateState.pass,
            stateLabel: labelOf(s),
          ),
          level: UiLevel.ok,
        ),
    ],
    doneLabel: HandoverWizardTexts.done,
    lockedLabel: lockedLabel,
    asOf: plan.asOf,
  );
}

/// 위저드 동작 결과 짝 — 접수 = OK · 냉각 · 창 · 시각 모름 · 결과 모름 = WATCH · 이미 · 닫힘 = INFO ·
/// 사람이 할 일(앞 단계 · 다시 조회) = ACT · 그 밖 = BLOCKED(표본 `m5/handover_sim_to_auto_action_results`).
UiLevel handoverResultLevel(String? code) {
  if (code == null) return UiLevel.ok;
  for (final SimToAutoStep s in SimToAutoStep.values) {
    if (s.stepId == code) return UiLevel.act;
  }
  return switch (code) {
    SimToAutoCodes.trustedTimeUnavailable ||
    SimToAutoCodes.cooling ||
    SimToAutoCodes.commitWindow ||
    kSimToAutoCommitUnknown => UiLevel.watch,
    SimToAutoCommitCodes.simClosed ||
    HandoverSessionCodes.sessionOpen ||
    HandoverSessionCodes.sessionInvalid => UiLevel.info,
    SimToAutoCodes.trialIncomplete ||
    SimToAutoCodes.goldenVectorFailed ||
    SimToAutoCodes.liveKeysFailed ||
    SimToAutoCodes.accountUnmapped ||
    SimToAutoCommitCodes.snapshotStale => UiLevel.act,
    _ => UiLevel.blocked,
  };
}

/// 위저드 동작 1회 결과(`handoffRoute` = 확정 성공만 `settingsOperations` · K175 · 다시 시도 = 늘 false).
ActionResult handoverActionResultOf({
  required SettingsActionId id,
  required String actionRunId,
  required String? code,
  required String headline,
}) => ActionResult(
  actionRunId: actionRunId,
  id: id,
  level: handoverResultLevel(code),
  headline: headline,
  reasonCode: code,
  handoffRoute: id == SettingsActionId.handoverCommit && code == null
      ? AppRoutes.settingsOperations
      : null,
  retryable: false,
);

/// S5 고름 결과 글자 — 성공 = 고른 쪽 · `SIM_LEDGER_FATE_SIM_CLOSED` · `SIM_TO_AUTO_NOT_SIM_AUTO`.
String simLedgerFateResultText(SimLedgerFate fate, String? code) =>
    switch (code) {
      null =>
        fate == SimLedgerFate.keep
            ? HandoverWizardTexts.fateKept
            : HandoverWizardTexts.fateDiscarded,
      SimToAutoCommitCodes.simClosed => HandoverWizardTexts.fateSimClosed,
      _ => HandoverWizardTexts.fateNotSimAuto,
    };
