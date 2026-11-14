// simToAuto(M5-11 SIM_TO_AUTO) 순수 판정 — 7단계 · 냉각 24h · 확정 기한 · 커밋 창 막기 · 화면 계획 조립
// (앱 05 :510 · :564-585 · 08 :916-945 · 01 §10 G-43 · SPEC v2.44 04 §3-1 ① · 설계 13 §8 R93 AE1~AE7).
//
// 🔴 판정만 한다 — 세션 쓰기(f2) · 2단 커밋(f3) · 리스 · 감시(f4)는 따로.
// 🔴 종착 = live × autoTrade × dryRun(#9) · 자동 전환 0 · 냉각은 건너뛸 수 없다(05 :585).
// 🔴 커밋 창 막기(AE5) — 다음 정기 집행 세션 전에 관찰 N거래일을 채울 수 없으면 확정하지 않는다
//    (dryRun 회차가 그 달 계획을 소모한다 · R89 ⑤ · AC8).
// 🔵 코드 · 단계 id · 문구 = 엔진 문자열(계약 등재 = 1.20.0 창 후보).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        GateState,
        HandoverPath,
        HandoverPlan,
        HandoverStep,
        OperatingMode,
        RunMode,
        TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import '../calendar/next_rebalance.dart' show nextRegularExecutionSession;
import '../ops/ledger_views.dart' show kstDateText, kstMinuteText;
import '../sim/sim_opening.dart' show kP0sSeedStrategies;
import '../sim/sim_trial.dart' show SimTrialReport;
import 'live_observation.dart' show LiveObservationConfig;

/// 냉각 — 생체 확인(세션 열림) 뒤 기다리는 시간(05 :585 · 건너뛰기 0).
const Duration kHandoverCooling = Duration(hours: 24);

/// 확정 기한 — 냉각이 끝난 뒤 확정할 수 있는 시간(개입 선례 · ⬜ 발주자 수치 확인 · R93 AE4).
const Duration kHandoverCommitWindow = Duration(hours: 24);

/// 전환 계획의 신선도(01 §2-11 B13 — 낡으면 커밋 직전에 되돌린다).
const Duration kHandoverPlanStaleAfter = Duration(minutes: 5);

/// 모의 기록 처리(5단계).
enum SimLedgerFate {
  /// 앱 밖 보관본으로 남긴다.
  keep('KEEP'),

  /// 지운다.
  discard('DISCARD');

  const SimLedgerFate(this.wire);

  /// 저장 글자.
  final String wire;
}

/// simToAuto 7단계(05 :510 차례).
enum SimToAutoStep {
  /// 1 모의 체험 확인.
  trial('SIM_TO_AUTO_S1', '모의 체험 확인', '체험 5항목을 채웠는지 엔진이 확인합니다'),

  /// 2 골든 벡터 자가검사.
  goldenVector('SIM_TO_AUTO_S2', '계산 자가검사', '실전과 같은 계산인지 골든 벡터로 다시 확인합니다'),

  /// 3 실전 키 등록 · 조회 검증.
  liveKeys('SIM_TO_AUTO_S3', '실전 키 확인', '실전 키를 등록하고 조회만으로 확인합니다 — 주문은 내지 않습니다'),

  /// 4 계좌 연결.
  accounts('SIM_TO_AUTO_S4', '계좌 연결', '전략 넷이 모두 실전 계좌에 연결됐는지 확인합니다'),

  /// 5 모의 기록 보관 · 지움.
  simLedger(
    'SIM_TO_AUTO_S5',
    '모의 기록 처리',
    '모의 기록을 보관할지 지울지 고릅니다 — 실전 원장에는 남지 않습니다',
  ),

  /// 6 생체 확인.
  biometric('SIM_TO_AUTO_S6', '생체 확인', '생체 확인 1회로 전환을 시작합니다'),

  /// 7 냉각 24시간.
  cooling('SIM_TO_AUTO_S7', '24시간 냉각', '생체 확인 뒤 24시간을 기다립니다 — 건너뛸 수 없습니다');

  const SimToAutoStep(this.stepId, this.title, this.whyLine);

  /// 단계 id(엔진 문자열).
  final String stepId;

  /// 제목.
  final String title;

  /// 왜 하는가(한 줄).
  final String whyLine;
}

/// simToAuto 거부 · 막힘 코드(R93).
abstract final class SimToAutoCodes {
  /// 모의 자동 매매가 아니다(모의 파일 현재 행 · 닫힘 · 운영 방식).
  static const String notSimAuto = 'SIM_TO_AUTO_NOT_SIM_AUTO';

  /// 킬스위치 · 주문 차단 플래그.
  static const String safetyBlock = 'SIM_TO_AUTO_SAFETY_BLOCK';

  /// 체험 미완.
  static const String trialIncomplete = 'SIM_TO_AUTO_TRIAL_INCOMPLETE';

  /// 골든 벡터 실패.
  static const String goldenVectorFailed = 'SIM_TO_AUTO_GOLDEN_VECTOR_FAILED';

  /// 실전 키 검증 실패.
  static const String liveKeysFailed = 'SIM_TO_AUTO_LIVE_KEYS_FAILED';

  /// 계좌 없는 전략.
  static const String accountUnmapped = 'SIM_TO_AUTO_ACCOUNT_UNMAPPED';

  /// 냉각 중.
  static const String cooling = 'SIM_TO_AUTO_COOLING';

  /// 확정 기한 지남(세션 만료).
  static const String sessionExpired = 'SIM_TO_AUTO_SESSION_EXPIRED';

  /// 신뢰 시각 없음.
  static const String trustedTimeUnavailable =
      'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE';

  /// 커밋 창 막힘(다음 정기 집행 전 관찰을 채울 수 없다).
  static const String commitWindow = 'SIM_TO_AUTO_COMMIT_WINDOW';
}

/// 판정 입력.
class SimToAutoFacts {
  /// 입력을 만든다.
  const SimToAutoFacts({
    required this.trustedNowUtc,
    required this.simRunMode,
    required this.simClosed,
    required this.operatingMode,
    required this.trial,
    required this.goldenVectorPassed,
    required this.liveKeysVerified,
    required this.accountByStrategy,
    required this.fate,
    required this.sessionOpenedAtUtc,
    required this.killSwitchActive,
    required this.blockingFlags,
  });

  /// 신뢰 시각(없으면 null — 냉각 · 기한 · 커밋 창을 판정하지 않는다).
  final DateTime? trustedNowUtc;

  /// 모의 파일 현재 행의 모드.
  final RunMode? simRunMode;

  /// 모의 파일이 닫혔나(CLOSE 행).
  final bool simClosed;

  /// 운영 방식.
  final OperatingMode? operatingMode;

  /// 체험 판정(E15d2).
  final SimTrialReport trial;

  /// 골든 벡터 자가검사(null = 아직).
  final bool? goldenVectorPassed;

  /// 실전 키 조회 검증(null = 아직).
  final bool? liveKeysVerified;

  /// 전략 → 실전 계좌 별칭.
  final Map<String, String> accountByStrategy;

  /// 모의 기록 처리(null = 아직).
  final SimLedgerFate? fate;

  /// 전환 세션이 열린 시각(= 생체 확인 · 냉각 시작 · null = 아직).
  final DateTime? sessionOpenedAtUtc;

  /// 킬스위치가 켜져 있나.
  final bool killSwitchActive;

  /// 주문 차단 플래그(`DST_WEEK` 제외).
  final List<String> blockingFlags;
}

/// 단계 1줄.
class SimToAutoStepResult {
  /// 줄을 만든다.
  const SimToAutoStepResult(
    this.step,
    this.state,
    this.label, [
    this.blockedReasonCode,
  ]);

  /// 단계.
  final SimToAutoStep step;

  /// 상태.
  final GateState state;

  /// 엔진 문구.
  final String label;

  /// 막힌 사유 코드(막힘일 때만).
  final String? blockedReasonCode;
}

/// 커밋 창(AE5).
class SimToAutoCommitWindow {
  /// 결과를 만든다.
  const SimToAutoCommitWindow({
    required this.allowed,
    required this.roundSession,
    required this.sessionsBeforeRound,
    required this.label,
  });

  /// 지금 확정해도 되나.
  final bool allowed;

  /// 다음 정기 집행 세션(달력 밖 = null).
  final String? roundSession;

  /// 집행 전 관찰 가능 세션 수.
  final int sessionsBeforeRound;

  /// 엔진 문구.
  final String label;
}

/// 판정 결과.
class SimToAutoReport {
  /// 결과를 만든다.
  const SimToAutoReport({
    required this.applicable,
    required this.code,
    required this.steps,
    required this.needsTrialWarning,
    required this.coolingEndsAtUtc,
    required this.commitDeadlineUtc,
    required this.window,
    required this.readyToCommit,
    required this.headline,
  });

  /// 전제를 채웠나(모의 자동 매매 중).
  final bool applicable;

  /// 확정을 막는 첫 사유(확정 가능 = null).
  final String? code;

  /// 7단계(전제 밖 = 빈 목록).
  final List<SimToAutoStepResult> steps;

  /// 체험 ② 미경험 — 경고 후 진행.
  final bool needsTrialWarning;

  /// 냉각 끝 시각(세션 없음 = null).
  final DateTime? coolingEndsAtUtc;

  /// 확정 기한(세션 없음 = null).
  final DateTime? commitDeadlineUtc;

  /// 커밋 창(신뢰 시각 없음 = null).
  final SimToAutoCommitWindow? window;

  /// 지금 확정할 수 있나.
  final bool readyToCommit;

  /// 엔진 머리말.
  final String headline;

  /// 단계 [s] 의 줄.
  SimToAutoStepResult of(SimToAutoStep s) =>
      steps.firstWhere((SimToAutoStepResult r) => r.step == s);
}

bool _beforeKrOrder(DateTime atUtc, String day) {
  final DateTime k = atUtc.toUtc().add(const Duration(hours: 9));
  return kstDateText(atUtc) == day &&
      (k.hour < 9 || (k.hour == 9 && k.minute < 10));
}

/// 커밋 창 막기(AE5) — [commitAtUtc] 에 확정하면 다음 정기 집행 전에 관찰 [config] 일수를 채울 수 있나.
SimToAutoCommitWindow simToAutoCommitWindow({
  required DateTime commitAtUtc,
  required ExchangeCalendar kr,
  required LiveObservationConfig config,
}) {
  final String today = kstDateText(commitAtUtc);
  final TradeDate t = TradeDate(today);
  final String? round = nextRegularExecutionSession(kr, commitAtUtc);
  final int n = config.requiredTradingDays;
  if (round == null) {
    return const SimToAutoCommitWindow(
      allowed: false,
      roundSession: null,
      sessionsBeforeRound: 0,
      label: '달력 범위 밖이라 확정하지 않습니다',
    );
  }
  int count = 0;
  String day = kr.isSession(t) ? today : kr.nextSession(t).yyyyMmDd;
  while (day.compareTo(round) < 0) {
    if (day != today || _beforeKrOrder(commitAtUtc, day)) count++;
    day = kr.nextSession(TradeDate(day)).yyyyMmDd;
  }
  final bool ok = count >= n;
  return SimToAutoCommitWindow(
    allowed: ok,
    roundSession: round,
    sessionsBeforeRound: count,
    label: ok
        ? '정기 리밸런싱 $round 전 관찰 가능 $count거래일'
        : '정기 리밸런싱 $round 전에 관찰 $n거래일을 채울 수 없습니다 — $round 09:10 뒤에 확정할 수 있습니다',
  );
}

SimToAutoStepResult _port(
  SimToAutoStep s,
  bool? v, {
  required String passLabel,
  required String failLabel,
  required String failCode,
}) => switch (v) {
  true => SimToAutoStepResult(s, GateState.pass, passLabel),
  false => SimToAutoStepResult(s, GateState.block, failLabel, failCode),
  null => SimToAutoStepResult(s, GateState.unknown, '아직 확인 전'),
};

/// simToAuto 판정(AE2~AE5).
SimToAutoReport judgeSimToAuto(
  SimToAutoFacts f, {
  required ExchangeCalendar kr,
  required LiveObservationConfig observation,
}) {
  final RunMode? m = f.simRunMode;
  if ((m != RunMode.simInternal && m != RunMode.simBroker) ||
      f.simClosed ||
      f.operatingMode != OperatingMode.autoTrade) {
    return const SimToAutoReport(
      applicable: false,
      code: SimToAutoCodes.notSimAuto,
      steps: <SimToAutoStepResult>[],
      needsTrialWarning: false,
      coolingEndsAtUtc: null,
      commitDeadlineUtc: null,
      window: null,
      readyToCommit: false,
      headline: '모의투자 자동 매매 중일 때만 실전으로 옮길 수 있습니다.',
    );
  }

  final SimTrialReport tr = f.trial;
  final SimToAutoStepResult s1 = tr.complete
      ? SimToAutoStepResult(
          SimToAutoStep.trial,
          GateState.pass,
          tr.needsWarning ? '체험 완료 — 월말 리밸런싱은 아직이라 경고 후 진행합니다' : '체험 5항목 완료',
        )
      : SimToAutoStepResult(
          SimToAutoStep.trial,
          GateState.block,
          tr.headline,
          SimToAutoCodes.trialIncomplete,
        );
  final SimToAutoStepResult s2 = _port(
    SimToAutoStep.goldenVector,
    f.goldenVectorPassed,
    passLabel: '골든 벡터 통과',
    failLabel: '골든 벡터가 맞지 않습니다 — 실전으로 옮기지 않습니다',
    failCode: SimToAutoCodes.goldenVectorFailed,
  );
  final SimToAutoStepResult s3 = _port(
    SimToAutoStep.liveKeys,
    f.liveKeysVerified,
    passLabel: '실전 키 조회 확인',
    failLabel: '실전 키 조회가 실패했습니다',
    failCode: SimToAutoCodes.liveKeysFailed,
  );
  final List<String> unmapped = <String>[
    for (final String s in kP0sSeedStrategies)
      if ((f.accountByStrategy[s] ?? '').trim().isEmpty) s,
  ];
  final SimToAutoStepResult s4 = unmapped.isEmpty
      ? SimToAutoStepResult(
          SimToAutoStep.accounts,
          GateState.pass,
          '전략 ${kP0sSeedStrategies.length}개 모두 계좌 연결',
        )
      : SimToAutoStepResult(
          SimToAutoStep.accounts,
          GateState.block,
          '계좌가 없는 전략: ${unmapped.join(' · ')}',
          SimToAutoCodes.accountUnmapped,
        );
  final SimToAutoStepResult s5 = switch (f.fate) {
    SimLedgerFate.keep => const SimToAutoStepResult(
      SimToAutoStep.simLedger,
      GateState.pass,
      '모의 기록을 앱 밖 보관본으로 남깁니다',
    ),
    SimLedgerFate.discard => const SimToAutoStepResult(
      SimToAutoStep.simLedger,
      GateState.pass,
      '모의 기록을 지웁니다',
    ),
    null => const SimToAutoStepResult(
      SimToAutoStep.simLedger,
      GateState.unknown,
      '고르기 전',
    ),
  };

  final DateTime? opened = f.sessionOpenedAtUtc;
  final DateTime? now = f.trustedNowUtc;
  final SimToAutoStepResult s6 = opened == null
      ? const SimToAutoStepResult(
          SimToAutoStep.biometric,
          GateState.unknown,
          '생체 확인 전',
        )
      : SimToAutoStepResult(
          SimToAutoStep.biometric,
          GateState.pass,
          '생체 확인 ${kstMinuteText(opened)}',
        );
  final DateTime? coolEnd = opened?.add(kHandoverCooling);
  final DateTime? deadline = coolEnd?.add(kHandoverCommitWindow);
  final SimToAutoStepResult s7;
  if (opened == null) {
    s7 = const SimToAutoStepResult(
      SimToAutoStep.cooling,
      GateState.unknown,
      '생체 확인 뒤 시작합니다',
    );
  } else if (now == null) {
    s7 = const SimToAutoStepResult(
      SimToAutoStep.cooling,
      GateState.unknown,
      '시각을 확인할 수 없어 기다립니다',
      SimToAutoCodes.trustedTimeUnavailable,
    );
  } else if (!now.isBefore(deadline!)) {
    s7 = const SimToAutoStepResult(
      SimToAutoStep.cooling,
      GateState.block,
      '확정 기한이 지났습니다 — 처음부터 다시 진행해 주세요',
      SimToAutoCodes.sessionExpired,
    );
  } else if (now.isBefore(coolEnd!)) {
    s7 = SimToAutoStepResult(
      SimToAutoStep.cooling,
      GateState.block,
      '냉각 중 — ${kstMinuteText(coolEnd)} 이후 확정할 수 있습니다',
      SimToAutoCodes.cooling,
    );
  } else {
    s7 = SimToAutoStepResult(
      SimToAutoStep.cooling,
      GateState.pass,
      '냉각 끝 — ${kstMinuteText(deadline)} 전까지 확정하세요',
    );
  }
  final List<SimToAutoStepResult> steps = <SimToAutoStepResult>[
    s1,
    s2,
    s3,
    s4,
    s5,
    s6,
    s7,
  ];
  final SimToAutoCommitWindow? window = now == null
      ? null
      : simToAutoCommitWindow(commitAtUtc: now, kr: kr, config: observation);

  final bool safety = f.killSwitchActive || f.blockingFlags.isNotEmpty;
  SimToAutoStepResult? firstOpen;
  for (final SimToAutoStepResult r in steps) {
    if (r.state != GateState.pass) {
      firstOpen = r;
      break;
    }
  }
  final String? code = safety
      ? SimToAutoCodes.safetyBlock
      : firstOpen != null
      ? (firstOpen.blockedReasonCode ?? firstOpen.step.stepId)
      : window == null
      ? SimToAutoCodes.trustedTimeUnavailable
      : !window.allowed
      ? SimToAutoCodes.commitWindow
      : null;
  final String headline = code == null
      ? '확정할 수 있습니다 — 확정하면 실전 관찰(주문 0)부터 시작합니다'
      : code == SimToAutoCodes.safetyBlock
      ? '킬스위치 · 주문 차단 플래그가 있어 확정하지 않습니다'
      : code == SimToAutoCodes.commitWindow
      ? window!.label
      : firstOpen != null
      ? '${firstOpen.step.title} — ${firstOpen.label}'
      : '시각을 확인할 수 없어 확정하지 않습니다';
  return SimToAutoReport(
    applicable: true,
    code: code,
    steps: List<SimToAutoStepResult>.unmodifiable(steps),
    needsTrialWarning: tr.complete && tr.needsWarning,
    coolingEndsAtUtc: coolEnd,
    commitDeadlineUtc: deadline,
    window: window,
    readyToCommit: code == null,
    headline: headline,
  );
}

/// 화면 계획(`HandoverPlan` · AE7) — [observedAtUtc] = 판정 시각.
HandoverPlan simToAutoPlan(
  SimToAutoReport r, {
  required DateTime observedAtUtc,
}) => HandoverPlan(
  path: HandoverPath.simToAuto,
  pathLabel: '모의투자 → 실전 자동 매매(관찰부터)',
  steps: <HandoverStep>[
    for (final SimToAutoStepResult s in r.steps)
      HandoverStep(
        stepId: s.step.stepId,
        order: s.step.index + 1,
        title: s.step.title,
        whyLine: s.step.whyLine,
        state: s.state,
        stateLabel: s.label,
        blockedReasonCode: s.blockedReasonCode,
      ),
  ],
  adoptionPreview: const [],
  asOf: AsOf(
    observedAt: observedAtUtc.toUtc(),
    tradeDate: TradeDate(kstDateText(observedAtUtc)),
    source: AsOfSource.localSqlite,
    staleAfter: kHandoverPlanStaleAfter,
    label: '전환 판정 ${kstMinuteText(observedAtUtc)}',
  ),
);
