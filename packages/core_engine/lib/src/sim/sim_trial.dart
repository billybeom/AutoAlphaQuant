// 모의 체험 5항목 판정 · 요약 카운터(SPEC v2.44 02 §2-7 ⓐ · 앱 04 M8 §9-5 · 05 S05 · 앱 06 X6-5 ⓑ ·
// 설계 13 §8 R87 AB1~AB11).
//
// 🔴 판정 · 건수는 전부 여기(엔진) — 화면은 상태와 문구만 보인다(비율 · 잔여를 세지 않는다 · 앱 04 M8 §9-5).
// 🔴 ② 월말 정기 리밸런싱만 소프트 문(미경험 = 경고 후 진행 허용) · 나머지 넷은 단단한 문.
// 🔴 시작점 = 모의 파일 첫 RUN_MODE 커밋(O-04 ⑥) — 그 앞의 기록은 체험이 아니다.
// 🔴 카운터에 손익 0.
// 🔵 코드 · 문구 = 엔진 문자열(계약 `SimTrialCard` = 1.19.0 창 · E15i — `safety/alert_text.dart` 선례).

import 'dart:math' as math;

import 'package:domain_contracts/domain_contracts.dart' show RunMode, TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import '../calendar/next_rebalance.dart' show nextRegularRebalance;
import '../ops/ledger_views.dart' show kstDateText;

/// ① 연속 정상 배치 세션 수(2거래주 · R87 AB3 — 설정 키 = 다음 SPEC 창).
const int kSimTrialRequiredSessions = 10;

/// ① 이 판정하는 배치 잡(`job_run` 체크 이름의 잡 부분).
const String kSimTrialBatchJob = 'kr_order';

/// ② 가 보는 리밸런싱 종류.
const String kSimTrialMonthlyKind = 'MONTHLY_REGULAR';

/// 체험 5항목(앱 04 M8 §9-5 차례).
enum SimTrialItem {
  /// ① 연속 2거래주 정상 배치.
  twoTradingWeeks('SIM_TRIAL_TWO_TRADING_WEEKS', '연속 2거래주 정상 배치'),

  /// ② 월말 정기 리밸런싱 1회(🔴 소프트 — 미경험 = 경고 후 진행 허용).
  monthEndRebalance('SIM_TRIAL_MONTH_END_REBALANCE', '월말 정기 리밸런싱 1회'),

  /// ③ 대사 0오차(simBroker 만 · simInternal = 자동 통과).
  reconciliation('SIM_TRIAL_RECONCILIATION', '대사 0오차'),

  /// ④ X2 재개 1회 시연.
  resume('SIM_TRIAL_RESUME', 'X2 재개 1회 시연'),

  /// ⑤ 킬스위치 발동 · 재개 1회 연습.
  killSwitch('SIM_TRIAL_KILL_SWITCH', '킬스위치 발동·재개 1회 연습');

  const SimTrialItem(this.code, this.label);

  /// 엔진 코드.
  final String code;

  /// 항목 이름(엔진 문구).
  final String label;

  /// 소프트 문인가(미경험이어도 완료를 막지 않는다).
  bool get soft => this == SimTrialItem.monthEndRebalance;
}

/// 항목 상태(R87 AB8).
enum SimTrialItemState {
  /// 채웠다.
  passed('PASSED'),

  /// 해당 없음 — 자동 통과(③ simInternal).
  autoPassed('AUTO_PASSED'),

  /// 아직(단단한 문).
  open('OPEN'),

  /// 아직 — 경고 후 진행 허용(② 소프트).
  openWarn('OPEN_WARN');

  const SimTrialItemState(this.wire);

  /// 저장 · 전달 글자.
  final String wire;

  /// 채웠나(자동 통과 포함).
  bool get satisfied =>
      this == SimTrialItemState.passed || this == SimTrialItemState.autoPassed;
}

/// 리밸런싱 기록 1건(`rebalance_event`).
class SimTrialRebalance {
  /// 기록을 만든다.
  const SimTrialRebalance(this.kind, this.createdAtUtc);

  /// 종류(`MONTHLY_REGULAR` 등).
  final String kind;

  /// 만든 시각(🔴 거래일이 아니라 이 시각으로 시작점과 비교 — R87 AB4).
  final DateTime createdAtUtc;
}

/// 대사 1회(`reconciliation_log` 의 `rc-` · 해제 행 제외).
class SimTrialRecon {
  /// 기록을 만든다.
  const SimTrialRecon(this.runAtUtc, {required this.matched});

  /// 돈 시각.
  final DateTime runAtUtc;

  /// 맞았나.
  final bool matched;
}

/// 재개 회차 1건(`resume_run`).
class SimTrialResumeRun {
  /// 기록을 만든다.
  const SimTrialResumeRun(
    this.startedAtUtc, {
    required this.finished,
    required this.gapTradingDays,
  });

  /// 시작 시각.
  final DateTime startedAtUtc;

  /// 끝났나(`finished_at` 있음).
  final bool finished;

  /// 갭(거래일).
  final int gapTradingDays;
}

/// 킬스위치 사건 1건(`kill_switch_event`).
class SimTrialKillEvent {
  /// 기록을 만든다.
  const SimTrialKillEvent(this.kind, this.occurredAtUtc);

  /// 종류(`ACTIVATED` · `CHECKLIST_CONFIRMED` · `CANCEL_REPORT` · `RESUMED`).
  final String kind;

  /// 시각.
  final DateTime occurredAtUtc;
}

/// 판정 입력 — 모의 파일의 원 기록(시작점 거르기 · 판정은 [judgeSimTrial]).
class SimTrialFacts {
  /// 입력을 만든다.
  const SimTrialFacts({
    required this.asOfUtc,
    required this.anchorUtc,
    required this.runMode,
    required this.batchOkDays,
    required this.rebalances,
    required this.recons,
    required this.openLedgerDiffs,
    required this.resumeRuns,
    required this.killEvents,
    required this.alertRaisedUtc,
    required this.interventionStartedUtc,
  });

  /// 읽은 시각.
  final DateTime asOfUtc;

  /// 체험 시작점(첫 RUN_MODE 커밋 · 없으면 null = 체험 전).
  final DateTime? anchorUtc;

  /// 지금 모드(최신 비-CLOSE 행 · 없으면 null).
  final RunMode? runMode;

  /// `kr_order` 가 SUCCESS · LATE 인 세션일(`YYYY-MM-DD`).
  final Set<String> batchOkDays;

  /// 리밸런싱 기록 전부.
  final List<SimTrialRebalance> rebalances;

  /// 대사 기록 전부(`rc-` · 해제 제외).
  final List<SimTrialRecon> recons;

  /// 열린(`OPEN`) 원장 차이 수(지금).
  final int openLedgerDiffs;

  /// 재개 회차 전부.
  final List<SimTrialResumeRun> resumeRuns;

  /// 킬스위치 사건 전부.
  final List<SimTrialKillEvent> killEvents;

  /// 알림 발생 시각 전부.
  final List<DateTime> alertRaisedUtc;

  /// 개입 세션 시작(1단계) 시각 전부.
  final List<DateTime> interventionStartedUtc;
}

/// 판정 입력 포트(R87 AB1 · `ModeFactsSource` 선례 · 🔴 예외 = 판정 없음).
abstract interface class SimTrialFactsSource {
  /// 지금의 입력.
  Future<SimTrialFacts> facts();
}

/// 항목 1줄.
class SimTrialItemResult {
  /// 줄을 만든다.
  const SimTrialItemResult(this.item, this.state, this.detail);

  /// 항목.
  final SimTrialItem item;

  /// 상태.
  final SimTrialItemState state;

  /// 엔진 문구(진척 · 사유 — 화면은 세지 않는다).
  final String detail;
}

/// 요약 카운터(R87 AB9 · 🔴 손익 0).
class SimTrialCounters {
  /// 카운터를 만든다.
  const SimTrialCounters({
    required this.trialDays,
    required this.batches,
    required this.rebalances,
    required this.alerts,
    required this.interventions,
  });

  /// 0 카운터(체험 전).
  static const SimTrialCounters zero = SimTrialCounters(
    trialDays: 0,
    batches: 0,
    rebalances: 0,
    alerts: 0,
    interventions: 0,
  );

  /// 체험 N일(시작 한국 날 = 1일째 · 달력 날).
  final int trialDays;

  /// 배치 n회(`kr_order` 정상 세션 수).
  final int batches;

  /// 리밸런싱 r회(전 종류).
  final int rebalances;

  /// 경보 k건(전 등급).
  final int alerts;

  /// 개입 m회(개입 세션 수).
  final int interventions;

  /// 엔진 문구.
  String get text =>
      '체험 $trialDays일 · 배치 $batches회 · 리밸런싱 $rebalances회 · 경보 $alerts건 · 개입 $interventions회';
}

/// 판정 결과.
class SimTrialReport {
  /// 결과를 만든다.
  const SimTrialReport({
    required this.started,
    required this.items,
    required this.complete,
    required this.needsWarning,
    required this.counters,
    required this.headline,
  });

  /// 체험을 시작했나.
  final bool started;

  /// 5항목(차례 = [SimTrialItem]).
  final List<SimTrialItemResult> items;

  /// 완료(단단한 넷 = 채움 — ② 는 보지 않는다).
  final bool complete;

  /// ② 미경험 — 진행하려면 경고를 보인다.
  final bool needsWarning;

  /// 요약 카운터.
  final SimTrialCounters counters;

  /// 엔진 머리말.
  final String headline;

  /// 항목 [item] 의 줄.
  SimTrialItemResult of(SimTrialItem item) =>
      items.firstWhere((SimTrialItemResult r) => r.item == item);
}

String _firstSessionOnOrAfter(ExchangeCalendar kr, String day) {
  final TradeDate d = TradeDate(day);
  return kr.isSession(d) ? day : kr.nextSession(d).yyyyMmDd;
}

int _kstDayIndex(String day) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
).difference(DateTime.utc(1970)).inDays;

bool _onOrAfter(DateTime t, DateTime anchor) => !t.isBefore(anchor);

/// 체험 5항목 판정 · 요약 카운터(R87 AB2~AB9).
SimTrialReport judgeSimTrial(
  SimTrialFacts f, {
  required ExchangeCalendar kr,
  int requiredSessions = kSimTrialRequiredSessions,
}) {
  if (requiredSessions < 1) {
    throw ArgumentError.value(requiredSessions, 'requiredSessions', '1 이상');
  }
  final DateTime? anchor = f.anchorUtc;
  if (anchor == null) {
    return SimTrialReport(
      started: false,
      items: <SimTrialItemResult>[
        for (final SimTrialItem i in SimTrialItem.values)
          SimTrialItemResult(
            i,
            i.soft ? SimTrialItemState.openWarn : SimTrialItemState.open,
            '체험 전',
          ),
      ],
      complete: false,
      needsWarning: true,
      counters: SimTrialCounters.zero,
      headline: '모의 체험을 아직 시작하지 않았습니다.',
    );
  }
  final String startDay = kstDateText(anchor);
  final String today = kstDateText(f.asOfUtc);

  // ① 연속 정상 배치 — 오늘 행이 아직 없으면 끊지 않는다 · 한 번 채우면 유지(AB3).
  int run = 0;
  int best = 0;
  int batches = 0;
  for (
    String day = _firstSessionOnOrAfter(kr, startDay);
    day.compareTo(today) <= 0;
    day = kr.nextSession(TradeDate(day)).yyyyMmDd
  ) {
    if (f.batchOkDays.contains(day)) {
      run++;
      batches++;
      best = math.max(best, run);
    } else if (day != today) {
      run = 0;
    }
  }
  final bool weeksOk = best >= requiredSessions;
  final SimTrialItemResult weeks = SimTrialItemResult(
    SimTrialItem.twoTradingWeeks,
    weeksOk ? SimTrialItemState.passed : SimTrialItemState.open,
    weeksOk
        ? '연속 정상 배치 $requiredSessions세션 채움'
        : '연속 정상 배치 ${math.min(run, requiredSessions)}/$requiredSessions세션',
  );

  // ② 월말 정기 리밸런싱 — created_at 비교 · 집행 세션의 kr_order 정상(AB4).
  bool monthOk = false;
  for (final SimTrialRebalance r in f.rebalances) {
    if (r.kind != kSimTrialMonthlyKind || !_onOrAfter(r.createdAtUtc, anchor)) {
      continue;
    }
    final String exec = _firstSessionOnOrAfter(kr, kstDateText(r.createdAtUtc));
    if (f.batchOkDays.contains(exec)) {
      monthOk = true;
      break;
    }
  }
  final String nextPlan =
      nextRegularRebalance(kr, TradeDate(today))?.planned.yyyyMmDd ?? '';
  final SimTrialItemResult month = SimTrialItemResult(
    SimTrialItem.monthEndRebalance,
    monthOk ? SimTrialItemState.passed : SimTrialItemState.openWarn,
    monthOk
        ? '월말 계획 집행 확인'
        : nextPlan.isEmpty
        ? '아직 없음 — 건너뛰면 경고 후 진행'
        : '아직 없음 — 다음 정기 리밸런싱 $nextPlan 08:00 · 건너뛰면 경고 후 진행',
  );

  // ③ 대사 0오차 — simInternal = 자동 통과 · simBroker = 대사 ≥ 1 ∧ 전부 맞음 ∧ 열린 차이 0(AB5).
  final SimTrialItemResult recon;
  if (f.runMode == RunMode.simInternal) {
    recon = const SimTrialItemResult(
      SimTrialItem.reconciliation,
      SimTrialItemState.autoPassed,
      '내부 가상 체결 — 브로커 대사 없음(자동 통과)',
    );
  } else if (f.runMode == RunMode.simBroker) {
    final List<SimTrialRecon> rs = <SimTrialRecon>[
      for (final SimTrialRecon r in f.recons)
        if (_onOrAfter(r.runAtUtc, anchor)) r,
    ];
    final int bad = rs.where((SimTrialRecon r) => !r.matched).length;
    final bool ok = rs.isNotEmpty && bad == 0 && f.openLedgerDiffs == 0;
    recon = SimTrialItemResult(
      SimTrialItem.reconciliation,
      ok ? SimTrialItemState.passed : SimTrialItemState.open,
      ok
          ? '대사 ${rs.length}회 · 불일치 0'
          : rs.isEmpty
          ? '대사 기록 없음'
          : bad > 0
          ? '불일치 $bad건'
          : '열린 차이 ${f.openLedgerDiffs}건',
    );
  } else {
    recon = const SimTrialItemResult(
      SimTrialItem.reconciliation,
      SimTrialItemState.open,
      '모의 모드가 아니다',
    );
  }

  // ④ X2 재개 — 끝난 회차 · 시작점 뒤 · 갭 ≥ 1(AB6).
  final int resumes = f.resumeRuns
      .where(
        (SimTrialResumeRun r) =>
            r.finished &&
            r.gapTradingDays >= 1 &&
            _onOrAfter(r.startedAtUtc, anchor),
      )
      .length;
  final SimTrialItemResult resume = SimTrialItemResult(
    SimTrialItem.resume,
    resumes > 0 ? SimTrialItemState.passed : SimTrialItemState.open,
    resumes > 0 ? '재개 $resumes회 끝남' : '아직 없음',
  );

  // ⑤ 킬스위치 — 시작점 뒤 ACTIVATED 다음 RESUMED(AB7).
  final List<SimTrialKillEvent> ks =
      <SimTrialKillEvent>[
        for (final SimTrialKillEvent e in f.killEvents)
          if (_onOrAfter(e.occurredAtUtc, anchor)) e,
      ]..sort(
        (SimTrialKillEvent a, SimTrialKillEvent b) =>
            a.occurredAtUtc.compareTo(b.occurredAtUtc),
      );
  bool activated = false;
  bool practised = false;
  for (final SimTrialKillEvent e in ks) {
    if (e.kind == 'ACTIVATED') activated = true;
    if (e.kind == 'RESUMED' && activated) {
      practised = true;
      break;
    }
  }
  final SimTrialItemResult kill = SimTrialItemResult(
    SimTrialItem.killSwitch,
    practised ? SimTrialItemState.passed : SimTrialItemState.open,
    practised
        ? '발동 · 재개 연습 끝남'
        : activated
        ? '발동됨 — 재개 대기'
        : '아직 없음',
  );

  final List<SimTrialItemResult> items = <SimTrialItemResult>[
    weeks,
    month,
    recon,
    resume,
    kill,
  ];
  final List<SimTrialItemResult> hardOpen = <SimTrialItemResult>[
    for (final SimTrialItemResult r in items)
      if (!r.item.soft && !r.state.satisfied) r,
  ];
  final bool complete = hardOpen.isEmpty;
  final bool warn = !month.state.satisfied;

  final SimTrialCounters counters = SimTrialCounters(
    trialDays: _kstDayIndex(today) - _kstDayIndex(startDay) + 1,
    batches: batches,
    rebalances: f.rebalances
        .where((SimTrialRebalance r) => _onOrAfter(r.createdAtUtc, anchor))
        .length,
    alerts: f.alertRaisedUtc
        .where((DateTime t) => _onOrAfter(t, anchor))
        .length,
    interventions: f.interventionStartedUtc
        .where((DateTime t) => _onOrAfter(t, anchor))
        .length,
  );

  return SimTrialReport(
    started: true,
    items: List<SimTrialItemResult>.unmodifiable(items),
    complete: complete,
    needsWarning: warn,
    counters: counters,
    headline: !complete
        ? '모의 체험 진행 중 — 남은 항목 ${hardOpen.length}개'
        : warn
        ? '체험 항목을 채웠습니다 — 월말 리밸런싱은 아직이라 경고 후 진행합니다.'
        : '체험 5항목을 모두 채웠습니다.',
  );
}
