// 🆕 E11q-b2a — X2 재개 화면 VM 두 장(설계 13 §8 R186 · 01 §31 K64 · §34 K156 · 미결 203 · 표본 `x2/resume_gate_*` ·
// `x2/resume_report_screen_*`).
//
// 🔴 리포트 = 가장 최근 **끝난** 회차를 그대로(ds `SqliteResumeRepository.latest()` · 다시 판정 0 · 손익 0) + 시각 · 단계 글자.
// 🔴 게이트 = 가장 최근 회차(열린 회차 포함)의 항목 중 «재판정 값으로 집행 예정» 이 아닌 것 — 회차가 남긴 차례 · 사유 글자
//    그대로(`resume_item.reevaluated_line` = 엔진 `resumeReevaluatedLine`) · 화면이 D+n · 모드 · 멈춤 사유를 계산하지 않는다.
// 🔴 계절 3택 = 사람 결정 대기 행에만 · 고르는 창구가 있을 때만([canChoose]) · 잠김이면 0(C-56 — 보기만).
// 🔵 엔진 글자(미결 203) = 계약 표본이 제안한 문장(«(합성)» 표지 뗌 · 발주자 위임 — 권고대로).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        LinkAction,
        PlannedWorkRejectCodes,
        ResumeGateRow,
        ResumeGateVm,
        ResumeItemReasonCodes,
        ResumeMode,
        ResumePhase,
        ResumeReport,
        ResumeReportVm,
        SafetyActionCall,
        SafetyActionId,
        SafetyActionResult,
        SeasonalChoiceResultCodes,
        SeasonalEntryChoice,
        TradeDate,
        UiLevel,
        VerdictCodes;

import '../ops/ledger_views.dart' show kstDateText;
import 'resume_text.dart' show resumeModeLabel;

/// 재개 화면 기준 오래됨(읽기 모델 — 홈과 같은 축).
const Duration kResumeScreenStaleAfter = Duration(hours: 26);

/// X2 화면 글자(표본 제안 문장 · 엔진 사전 밖 몫).
abstract final class ResumeScreenTexts {
  /// 리포트 회차 0.
  static const String reportEmpty =
      '아직 재개한 적이 없습니다 — 엔진이 거래일을 건너뛰고 다시 켜지면 여기에 결과가 남습니다';

  /// 게이트 — 회차 0.
  static const String gateNoRun = '아직 재개한 적이 없습니다 — 막힌 계획이 없습니다';

  /// 게이트 — 회차 0 의 모드 줄.
  static const String gateNoRunMode = '재개 회차 없음';

  /// 게이트 — 끝난 회차 · 막힌 계획 0.
  static const String gateClear = '재개 점검을 마쳤습니다 — 막힌 계획이 없습니다';

  /// 게이트 — 열린 회차(진행 중 · 크래시 뒤 이어갈 회차).
  static const String gateInProgress = '재개 점검이 진행 중입니다 — 끝나면 결과가 여기에 남습니다';

  /// 리포트 링크.
  static const String reportLink = '재개 리포트 보기';

  /// 계절 3택 버튼(계약 표본 글자 · 엔진 `SeasonalWindowChoice` 차례).
  static String seasonalChoice(SeasonalEntryChoice c) => switch (c) {
    SeasonalEntryChoice.skip => '건너뛰기',
    SeasonalEntryChoice.reduced => '축소 진입',
    SeasonalEntryChoice.asIs => '그대로 진입',
  };

  /// 단계 글자(`ResumePhase` 짝 — 06 X2 R0~R8).
  static String phase(ResumePhase p) => switch (p) {
    ResumePhase.r0 => '회차 열림',
    ResumePhase.r1 => '정지 사유 확인',
    ResumePhase.r2 => '공백 · 모드 결정',
    ResumePhase.r3 => '대사 확인',
    ResumePhase.r4 => '결과 모름 주문 해소',
    ResumePhase.r5 => '자료 공백 기록',
    ResumePhase.r6 => '재판정',
    ResumePhase.r7 => '집행 위임',
    ResumePhase.r8 => '재개 마침',
  };
}

String _two(int n) => n.toString().padLeft(2, '0');

DateTime _kst(DateTime utc) => utc.toUtc().add(const Duration(hours: 9));

/// 회차 시각 «MM-DD HH:mm ~ HH:mm»(같은 날) · «MM-DD HH:mm ~ MM-DD HH:mm»(날이 다르면) · 한국 시각.
String resumePeriodText(DateTime startedUtc, DateTime finishedUtc) {
  final DateTime a = _kst(startedUtc);
  final DateTime b = _kst(finishedUtc);
  final String head =
      '${_two(a.month)}-${_two(a.day)} ${_two(a.hour)}:${_two(a.minute)}';
  final bool sameDay = a.year == b.year && a.month == b.month && a.day == b.day;
  final String tail = sameDay
      ? '${_two(b.hour)}:${_two(b.minute)}'
      : '${_two(b.month)}-${_two(b.day)} ${_two(b.hour)}:${_two(b.minute)}';
  return '$head ~ $tail';
}

/// 기준 «재개 기준 YYYY-MM-DD HH:mm»(관측 = 지금).
AsOf resumeScreenAsOf(DateTime nowUtc) {
  final String day = kstDateText(nowUtc);
  final DateTime k = _kst(nowUtc);
  return AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kResumeScreenStaleAfter,
    label: '재개 기준 $day ${_two(k.hour)}:${_two(k.minute)}',
  );
}

/// X2 리포트 한 화면 — [report] = 가장 최근 끝난 회차(없으면 null).
ResumeReportVm resumeReportVmOf({
  required ResumeReport? report,
  required DateTime nowUtc,
}) => ResumeReportVm(
  report: report,
  periodText: report == null
      ? null
      : resumePeriodText(
          report.startedAt,
          report.finishedAt ?? report.startedAt,
        ),
  phaseLabel: report == null ? null : ResumeScreenTexts.phase(report.phase),
  emptyLabel: report == null ? ResumeScreenTexts.reportEmpty : null,
  asOf: resumeScreenAsOf(nowUtc),
);

/// 게이트가 읽는 회차(가장 최근 · 열린 회차 포함).
class ResumeGateRun {
  /// 회차를 만든다.
  const ResumeGateRun({
    required this.gapTradingDays,
    required this.mode,
    required this.finished,
    required this.headline,
    required this.items,
  });

  /// 공백(거래일).
  final int gapTradingDays;

  /// 모드.
  final ResumeMode mode;

  /// 끝났나.
  final bool finished;

  /// 엔진 머리말(끝난 회차 · 열린 회차 = null).
  final String? headline;

  /// 항목(회차 차례 그대로).
  final List<ResumeGateItem> items;
}

/// 게이트가 읽는 항목 1(`resume_item` 그대로).
class ResumeGateItem {
  /// 항목을 만든다.
  const ResumeGateItem({
    required this.workId,
    required this.oneLine,
    required this.reasonCode,
    required this.reasonLine,
    required this.verdictCode,
  });

  /// 계획 id(화면 미참조).
  final String workId;

  /// 엔진 한 줄.
  final String oneLine;

  /// 사유 코드(`ResumeItemReasonCodes`).
  final String reasonCode;

  /// 사유 글자(엔진 `resumeReevaluatedLine` — 회차가 남긴 그대로).
  final String reasonLine;

  /// 재판정 결과(`VerdictCodes`).
  final String verdictCode;
}

/// 사유 → 행 수준 — 매매를 멈춰 두는 사유 = BLOCKED · 사람이 고를 것 = ACT · 관찰 회차 = WATCH · 나머지(지난 일) = INFO ·
/// 모르는 코드 = INFO(게이트를 깨지 않는다 — 사유 사전 전부가 짝이 있음은 시험이 지킨다).
UiLevel resumeGateRowLevel(String reasonCode) => switch (reasonCode) {
  ResumeItemReasonCodes.safetyStop ||
  ResumeItemReasonCodes.reconMismatch ||
  ResumeItemReasonCodes.unknownOrders ||
  ResumeItemReasonCodes.residualOrders ||
  ResumeItemReasonCodes.reevaluationFailed => UiLevel.blocked,
  ResumeItemReasonCodes.humanDecision ||
  ResumeItemReasonCodes.advisoryPending => UiLevel.act,
  ResumeItemReasonCodes.observing => UiLevel.watch,
  _ => UiLevel.info,
};

/// X2 재개 게이트 한 화면 — [run] = 가장 최근 회차(없으면 null) · [incomplete] = `RESUME_INCOMPLETE` 활성 ·
/// [canChoose] = 계절 선택을 낼 창구가 있나 · [hasBody] = 조립 앱 레지스트리에 본문이 있나 · [lockedLabel] = 운영 등급 생체 축소.
ResumeGateVm resumeGateVmOf({
  required ResumeGateRun? run,
  required bool incomplete,
  required bool canChoose,
  required bool Function(String route) hasBody,
  required DateTime nowUtc,
  String? lockedLabel,
}) {
  final LinkAction? report = hasBody(AppRoutes.x2ResumeReport)
      ? const LinkAction(
          label: ResumeScreenTexts.reportLink,
          deepLink: AppRoutes.x2ResumeReport,
        )
      : null;
  if (run == null) {
    return ResumeGateVm(
      headline: ResumeScreenTexts.gateNoRun,
      modeLabel: ResumeScreenTexts.gateNoRunMode,
      level: incomplete ? UiLevel.blocked : UiLevel.ok,
      rows: const <ResumeGateRow>[],
      reportLink: report,
      lockedLabel: lockedLabel,
      asOf: resumeScreenAsOf(nowUtc),
    );
  }
  final bool choose = canChoose && lockedLabel == null;
  final List<ResumeGateRow> rows = <ResumeGateRow>[
    for (final ResumeGateItem i in run.items)
      if (i.verdictCode != VerdictCodes.executedAsReevaluated)
        ResumeGateRow(
          workId: i.workId,
          oneLine: i.oneLine,
          reasonCode: i.reasonCode,
          reasonLabel: i.reasonLine,
          level: resumeGateRowLevel(i.reasonCode),
          actions: <SafetyActionCall>[
            if (choose && i.reasonCode == ResumeItemReasonCodes.humanDecision)
              for (final SeasonalEntryChoice c in SeasonalEntryChoice.values)
                SafetyActionCall(
                  id: SafetyActionId.seasonalWindowChoice,
                  args: <String, String>{'work_id': i.workId, 'choice': c.wire},
                  label: ResumeScreenTexts.seasonalChoice(c),
                ),
          ],
        ),
  ];
  final UiLevel level = incomplete
      ? UiLevel.blocked
      : rows.any(
          (ResumeGateRow r) =>
              r.level == UiLevel.act ||
              r.level == UiLevel.watch ||
              r.level == UiLevel.blocked,
        )
      ? UiLevel.watch
      : rows.isNotEmpty
      ? UiLevel.info
      : UiLevel.ok;
  return ResumeGateVm(
    headline: !run.finished
        ? ResumeScreenTexts.gateInProgress
        : rows.isEmpty
        ? ResumeScreenTexts.gateClear
        : run.headline ?? ResumeScreenTexts.gateInProgress,
    modeLabel: resumeModeLabel(gapSessions: run.gapTradingDays, mode: run.mode),
    level: level,
    rows: rows,
    reportLink: report,
    lockedLabel: lockedLabel,
    asOf: resumeScreenAsOf(nowUtc),
  );
}

/// 생체 확인 불가(계약 `BIOMETRIC_UNAVAILABLE` · 계절 선택 결과 사전).
const String _kBiometricUnavailable = 'BIOMETRIC_UNAVAILABLE';

/// 🆕 E11q-b2b(R195 · K54) — 계절 3택 결과 글자(표본 `m5/safety_action_results_e13` 제안 문장 · «(합성)» 뗌) — (수준, 문장) ·
/// 거부 = `SeasonalChoiceResultCodes` ∪ `PlannedWorkRejectCodes` ∪ 멈춤 사유 7 ∪ 생체 · 모르는 코드 = 오류(지어내지 않는다).
(UiLevel, String) _seasonalText(String? code) => switch (code) {
  null => (UiLevel.ok, '고른 대로 기록했습니다 — 다음 주문 회차가 이어 갑니다.'),
  SeasonalChoiceResultCodes.pastDue ||
  PlannedWorkRejectCodes.pastDue => (UiLevel.act, '고를 수 있는 기한이 지났습니다.'),
  SeasonalChoiceResultCodes.notPending ||
  PlannedWorkRejectCodes.terminal ||
  PlannedWorkRejectCodes.unchanged => (UiLevel.info, '이미 결정된 작업입니다.'),
  SeasonalChoiceResultCodes.notSeasonalEntry => (
    UiLevel.info,
    '계절 진입 작업이 아닙니다.',
  ),
  SeasonalChoiceResultCodes.decisionMissing => (
    UiLevel.blocked,
    '결정 번호가 없어 기록하지 않았습니다.',
  ),
  PlannedWorkRejectCodes.unknown => (UiLevel.info, '그 작업을 찾지 못했습니다.'),
  PlannedWorkRejectCodes.notDue => (UiLevel.info, '아직 고를 때가 아닙니다.'),
  PlannedWorkRejectCodes.illegal => (
    UiLevel.blocked,
    '이 작업은 지금 그렇게 바꿀 수 없습니다.',
  ),
  ResumeItemReasonCodes.reconMismatch => (
    UiLevel.blocked,
    '대사 불일치가 남아 있어 진입을 고르지 않았습니다.',
  ),
  ResumeItemReasonCodes.unknownOrders => (
    UiLevel.blocked,
    '결과를 모르는 주문이 남아 있어 진입을 고르지 않았습니다.',
  ),
  ResumeItemReasonCodes.residualOrders => (
    UiLevel.blocked,
    '처리 중인 주문이 남아 있어 진입을 고르지 않았습니다.',
  ),
  ResumeItemReasonCodes.safetyStop => (
    UiLevel.blocked,
    '안전 정지 중이라 진입을 고르지 않았습니다.',
  ),
  ResumeItemReasonCodes.reevaluationFailed => (
    UiLevel.blocked,
    '재판정을 마치지 못해 진입을 고르지 않았습니다.',
  ),
  ResumeItemReasonCodes.observing => (UiLevel.watch, '관찰 회차라 진입을 고르지 않았습니다.'),
  ResumeItemReasonCodes.advisoryPending => (
    UiLevel.act,
    '안내 모드 재개 조건 결정을 기다려 진입을 고르지 않았습니다.',
  ),
  _kBiometricUnavailable => (UiLevel.blocked, '생체 확인을 할 수 없어 진행하지 않았습니다.'),
  final String other => throw ArgumentError.value(
    other,
    'code',
    '모르는 계절 선택 결과 코드',
  ),
};

/// 계절 3택 동작 결과 — [code] null = 기록됨 · 글자 = 엔진.
SafetyActionResult seasonalChoiceResultOf({
  required String actionRunId,
  String? code,
}) {
  final (UiLevel level, String headline) = _seasonalText(code);
  return SafetyActionResult(
    actionRunId: actionRunId,
    id: SafetyActionId.seasonalWindowChoice,
    level: level,
    headline: headline,
    reasonCode: code,
    retryable: false,
  );
}
