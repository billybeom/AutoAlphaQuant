// 🆕 E11q-q5d — M7 `S7-9` 목표 경로 VM(설계 13 §8 R238 · 06 M1-23 · 01 §14-9~§14-11 · C-39 · 표본 `m7/m7_goal_path_*`).
//
// 🔴 계획선(M1-23 ⓐ) = 월 납입 시나리오 — 개시 평가(첫 마감 스냅숏 = 실제선 첫 점과 같은 값) + 달마다 월 납입 설정값(그달 첫 KR
//    세션 · `operating_param_log` 이력의 그날 현재값 · 기록 없음 = 기본값)을 정직 기대 연 [kGoalPathHonestAnnualRate] 로
//    복리(일수 ÷ 365)한 금액. 목표 금액 입력(01 §8 미결 80)은 쓰지 않는다 — 계획선은 «금액 경로»이고 끝값을 정하지 않는다.
// 🔴 실제선 = 계층 B · 월간 리포트와 같은 마감 평가 시리즈(`EquityPoint` · 개시 이후) — 점 = 개시 점 + 개시 다음 달부터 그 달까지
//    달마다 그 달의 마지막 스냅숏(없으면 결측 · `EQUITY_SNAPSHOT_MISSING` · 선을 끊는다 — 보간 금지 · S7-2 와 같은 규칙).
// 🔴 판정(M1-23 ⓑ) = 그 달 점 하나: 평가액 ≥ 계획 = 앞섬(VM 글자 = «유지» · 월간 리포트 줄 = «앞서 있습니다») ·
//    평가액 < 계획 ÷ (1 + 정직 기대) = 이탈(1년 치 정직 기대 성장만큼 뒤처짐) · 그 사이 = 유지.
//    판정 유보(M1-23 ⓒ) = 개시 달부터 [kGoalPathMinMonths]개월 미만 · 스냅숏 0 · 그 달 마감 평가 0 → 표본 `_hold` 꼴
//    (차트 · 네 목록 0 · 불가 카드 · C-39 ③).
// 🔴 기하 = 표본에서 거꾸로 맞춘 규칙(S7-2 와 같다): 가로 = i ÷ (n−1) · 세로 = 값 범위를 덮는 만원 눈금(간격 1 · 2 · 5 × 10^k 중
//    네 칸 이하가 되는 가장 작은 것 · 0 을 품지 않는다 — 표본 2,000만~2,600만) · 결측 띠 = 덮는 점의 앞뒤 반 칸 · 띠 시작 =
//    앞 점 다음 세션. 글자 = 만원(`%` 0 · 달성률 0 — C-39 ⑥).
// 🔴 가정 카드 · 정직 기대 = 엔진 상수 문장(표본 글자 그대로 · 숫자 = 온보딩 · 배분 카드의 정직 기대 줄과 같은 수 — 시험이 대조).
//    월 납입 금액을 문장에 끼우지 않는다(03 §17-17 · C-32).
// 🔴 무결성 점검 중 = 읽기 경로가 실패로 막는다(R226 드로다운 선례 — 가림 표본 없음 · 월간 리포트 링크도 부재).

import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        GoalPathVm,
        PerfAxisTick,
        PerfPoint,
        PerfSegment,
        SegmentKind,
        TradeDate;

import 'contribution_setting.dart'
    show ContributionConfig, ContributionParamRow, splitContributionRows;
import 'holdings_overview.dart' show holdingsManwonText;
import 'perf_series_view.dart' show PerfSeriesTexts, kPerfGapSnapshotMissing;
import 'tier_b.dart' show EquityPoint;

/// 목표 경로 기준 유효 시간(표본 93600초 = 26시간).
const Duration kGoalPathStaleAfter = Duration(hours: 26);

/// 정직 기대(전 계좌 세후 · 연) — 온보딩 · 배분 카드 정직 기대 줄(`kP0sHonestExpectationLine`)과 같은 수(시험이 대조).
const double kGoalPathHonestAnnualRate = 0.102;

/// 최악 가정(전 계좌 세후 · 연) — 같은 줄의 «최악» 수.
const double kGoalPathHonestWorstAnnualRate = 0.097;

/// 판정 유보 최소 관측 — 개시 달에서 그 달까지 달 수(한 분기 · 표본 점 간격).
const int kGoalPathMinMonths = 3;

/// 목표 경로 판정 갈래(월간 리포트 목표 줄 · 링크가 같은 판정을 쓴다).
enum GoalVerdict {
  /// 평가액 ≥ 계획.
  ahead,

  /// 계획 아래 · 허용 범위 안.
  onTrack,

  /// 허용 범위 아래(이탈).
  offTrack,

  /// 판정 유보(관측 부족).
  withheld,
}

/// 목표 경로 글자(표본 그대로 · 🆕 = 표본 밖 상태).
abstract final class GoalPathTexts {
  /// 판정 — 유지(표본 `_on` · `_realworld`).
  static const String onTrack = '목표 경로를 따라가고 있습니다(유지).';

  /// 판정 — 이탈(표본 `_off`).
  static const String offTrack = '목표 경로보다 뒤처져 있습니다(이탈).';

  /// 판정 — 유보(표본 `_hold`).
  static const String withheld = '관측이 짧아 목표 경로 판정을 보류합니다(판정 유보).';

  /// 근거 — 허용 범위 안(표본 `_on`).
  static String basisWithin(int month) =>
      '$month월 말 평가액이 계획 경로의 허용 범위 안에 있습니다.';

  /// 근거 — 허용 범위 아래(표본 `_off`).
  static String basisBelow(int month) =>
      '$month월 말 평가액이 계획 경로의 허용 범위 아래에 있습니다.';

  /// 🆕 근거 — 관측 부족(표본 `_hold` 의 «재개 점검 뒤» = 재개 원천 전이라 뺐다).
  static const String basisShort = '판정에 필요한 관측이 아직 쌓이지 않았습니다.';

  /// 🆕 근거 — 그 달 마감 평가 0.
  static String basisNoMonthEnd(int month) =>
      '$month월 마감 평가액 기록이 없어 판정에 쓸 관측이 모자랍니다.';

  /// 이탈 문장(표본 `_off`).
  static const String deviation = '계획선보다 뒤처져 있습니다. 규칙을 바꿀 근거는 아닙니다.';

  /// 범례 — 계획선.
  static const String plannedLabel = '계획 경로';

  /// 범례 — 실제선.
  static const String actualLabel = '실제 평가액';

  /// 불가 카드(표본 `_hold`).
  static const String chartUnavailable =
      '관측이 모자라 경로를 그리지 않습니다. 관측이 쌓이면 다시 그립니다.';

  /// 가정 카드 1줄(표본 `_on`).
  static const String backtestBasis = '계획 경로는 백테스트 기준 실행을 정직 기대 수익률로 낮춰 그렸습니다.';

  /// 가정 카드 2줄(표본 `_on` · 금액 없음 — 03 §17-17).
  static const String startingCapital = '당신의 현재 원금과 월 납입 설정에서 출발한 경로입니다.';

  /// 정직 기대 인용(01 §14-10 예외 조문 · 표본 글자).
  static String get honest =>
      '정직 기대는 전 계좌 세후 연 ${pct1(kGoalPathHonestAnnualRate)}% 안팎입니다.';

  /// 최악 가정 인용.
  static String get honestWorst =>
      '세금을 가장 불리하게 가정하면 연 ${pct1(kGoalPathHonestWorstAnnualRate)}% 안팎입니다.';

  /// 고지(표본).
  static const String disclaimer = '이 경로는 약속이 아니며 수익을 보증하지 않습니다.';

  /// 월간 리포트 목표 줄 — 앞섬(표본 `m7_monthly_2026_08`).
  static const String reportAhead = '목표 경로 대비 앞서 있습니다. 앞으로의 약속은 아닙니다.';

  /// 기준 줄.
  static String asOfLabel(String day) => '목표 경로 기준 $day';

  /// 달 글자 «2026년 8월».
  static String monthText(String ymdOrYm) =>
      '${int.parse(ymdOrYm.substring(0, 4))}년 ${int.parse(ymdOrYm.substring(5, 7))}월';

  /// 판정 유보 기간 줄(표본 `_hold` «2026년 8월 기준»).
  static String holdPeriod(String yyyyMm) => '${monthText(yyyyMm)} 기준';

  /// 비율 → 소수 한 자리(«10.2»).
  static String pct1(double r) => (r * 100).toStringAsFixed(1);
}

/// 점 하나(기하 전) — [actual] null = 결측.
class GoalPathFact {
  /// 만든다.
  const GoalPathFact({
    required this.date,
    required this.dateText,
    required this.planned,
    required this.actual,
  });

  /// 점 날(`YYYY-MM-DD`).
  final String date;

  /// 점 글자.
  final String dateText;

  /// 계획 금액(원).
  final double planned;

  /// 실제 평가액(원 · null = 결측).
  final double? actual;
}

/// 차트 네 목록(C-39 ①②④⑤).
class GoalPathChart {
  /// 만든다.
  const GoalPathChart({
    required this.planned,
    required this.actual,
    required this.yTicks,
    required this.segments,
  });

  /// 계획선.
  final List<PerfPoint> planned;

  /// 실제선.
  final List<PerfPoint> actual;

  /// 세로 눈금(≤ 5).
  final List<PerfAxisTick> yTicks;

  /// 결측 띠.
  final List<PerfSegment> segments;
}

/// 목표 경로 결과 — 화면 VM + 판정 갈래(월간 리포트 줄 · 링크).
class GoalPathOutcome {
  /// 만든다.
  const GoalPathOutcome(this.vm, this.verdict);

  /// 화면 VM.
  final GoalPathVm vm;

  /// 판정.
  final GoalVerdict verdict;
}

final RegExp _yyyyMm = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
final RegExp _ymdRe = RegExp(r'^\d{4}-\d\d-\d\d$');

DateTime _day(String ymd) => DateTime.utc(
  int.parse(ymd.substring(0, 4)),
  int.parse(ymd.substring(5, 7)),
  int.parse(ymd.substring(8, 10)),
);

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _shift(String ymd, int days) =>
    _ymd(_day(ymd).add(Duration(days: days)));

int _days(String a, String b) => _day(b).difference(_day(a)).inDays;

double _r4(double x) => (x * 10000).round() / 10000;

int _monthIndex(String ym) =>
    int.parse(ym.substring(0, 4)) * 12 + int.parse(ym.substring(5, 7)) - 1;

String _ymOf(int index) =>
    '${(index ~/ 12).toString().padLeft(4, '0')}-${(index % 12 + 1).toString().padLeft(2, '0')}';

String _calendarMonthEnd(String ym) => _ymd(
  DateTime.utc(
    int.parse(ym.substring(0, 4)),
    int.parse(ym.substring(5, 7)) + 1,
    1,
  ).subtract(const Duration(days: 1)),
);

String _won(double v) => holdingsManwonText(Decimal.fromInt(v.round()));

/// 🔴 차트 네 목록 — [points] = 날짜 순(첫 점 = 개시) · 계획 결측 0 · 실제 null = 결측 · [isSession] = 띠 시작 세션.
/// 규칙 = 표본 `m7_goal_path_on` · `_off` · `_realworld` 에서 거꾸로 맞춘 것(머리 주석).
GoalPathChart goalPathChartOf(
  List<GoalPathFact> points, {
  required bool Function(String ymd) isSession,
}) {
  final int n = points.length;
  if (n == 0) throw ArgumentError.value(points, 'points', '점 0');
  for (int i = 0; i < n; i++) {
    if (!_ymdRe.hasMatch(points[i].date) ||
        (i > 0 && points[i].date.compareTo(points[i - 1].date) <= 0)) {
      throw ArgumentError.value(points[i].date, 'points', '날짜 순이 아니다');
    }
  }
  final List<double> planned = <double>[
    for (final GoalPathFact p in points) p.planned.roundToDouble(),
  ];
  final List<double?> actual = <double?>[
    for (final GoalPathFact p in points) p.actual?.roundToDouble(),
  ];
  final List<double> all = <double>[
    ...planned,
    for (final double? a in actual) ?a,
  ];
  final double minV = all.reduce(math.min);
  final double maxV = all.reduce(math.max);

  // 세로 눈금(만원) — 간격 1 · 2 · 5 × 10^k 중 네 칸 이하가 되는 가장 작은 것.
  int lo = (minV / 10000).floor();
  int hi = lo + 1;
  int step = 1;
  if (minV != maxV) {
    for (int k = 0; ; k++) {
      final int s = <int>[1, 2, 5][k % 3] * math.pow(10, k ~/ 3).toInt();
      final int l = (minV / (s * 10000)).floor() * s;
      final int h = (maxV / (s * 10000)).ceil() * s;
      if ((h - l) ~/ s <= 4) {
        lo = l;
        hi = h;
        step = s;
        break;
      }
    }
  }
  double y(double v) => _r4((v - lo * 10000) / ((hi - lo) * 10000));
  final List<PerfAxisTick> ticks = <PerfAxisTick>[
    for (int t = lo; t <= hi; t += step)
      PerfAxisTick(
        normalized: y(t * 10000.0),
        label: holdingsManwonText(Decimal.fromInt(t * 10000)),
      ),
  ];

  double xRaw(int i) => n == 1 ? 0.5 : i / (n - 1);
  final double half = n == 1 ? 0.5 : 0.5 / (n - 1);
  PerfPoint point(int i, double? v) => PerfPoint(
    date: TradeDate(points[i].date),
    xNormalized: _r4(xRaw(i)),
    dateText: points[i].dateText,
    valueText: v == null ? PerfSeriesTexts.notComputable : _won(v),
    yNormalized: v == null ? null : y(v),
    value: v,
    gapReasonCode: v == null ? kPerfGapSnapshotMissing : null,
  );

  String periodStart(int i) {
    if (i == 0) return points[0].date;
    String d = _shift(points[i - 1].date, 1);
    while (!isSession(d) && d.compareTo(points[i].date) < 0) {
      d = _shift(d, 1);
    }
    return d;
  }

  // 결측 띠 — 결측 점이 이어진 묶음마다 하나(측정 띠는 두지 않는다 — 표본).
  final List<PerfSegment> segments = <PerfSegment>[];
  for (int i = 0; i < n; i++) {
    if (actual[i] != null || (i > 0 && actual[i - 1] == null)) continue;
    int j = i;
    while (j + 1 < n && actual[j + 1] == null) {
      j++;
    }
    segments.add(
      PerfSegment(
        from: TradeDate(periodStart(i)),
        to: TradeDate(points[j].date),
        kind: SegmentKind.unavailable,
        label: PerfSeriesTexts.missing,
        startNormalized: math.max(0, _r4(xRaw(i) - half)),
        endNormalized: math.min(1, _r4(xRaw(j) + half)),
      ),
    );
  }

  return GoalPathChart(
    planned: <PerfPoint>[for (int i = 0; i < n; i++) point(i, planned[i])],
    actual: <PerfPoint>[for (int i = 0; i < n; i++) point(i, actual[i])],
    yTicks: ticks,
    segments: segments,
  );
}

/// 🔴 `S7-9` 목표 경로 — [yyyyMm] 의 경로(개시 ~ 그 달) · [monthEnd] = 그 달 마지막 KR 세션 ·
/// [equity] = 개시 이후 마감 스냅숏(날짜 순 · 계층 B 와 같은 시리즈 · [monthEnd] 뒤 점은 쓰지 않는다) ·
/// [isSession] = 한국 세션 · [contributionRows] = 월 납입 설정 기록(`operating_param_log`) · [contributionConfig] = 기본값 ·
/// [nowUtc] = 읽은 시각(기준 관측 시각). 달 꼴 · [monthEnd] 가 그 달이 아니면 [ArgumentError].
/// 닫힌 달 · 개시 달부터 · 무결성 = 읽기 경로 몫(월간 리포트와 같은 판정).
GoalPathOutcome goalPathOf({
  required String yyyyMm,
  required TradeDate monthEnd,
  required List<EquityPoint> equity,
  required bool Function(String ymd) isSession,
  required List<ContributionParamRow> contributionRows,
  required ContributionConfig contributionConfig,
  required DateTime nowUtc,
}) {
  if (!_yyyyMm.hasMatch(yyyyMm)) {
    throw ArgumentError.value(yyyyMm, 'yyyyMm', 'YYYY-MM 이 아니다');
  }
  final String end = monthEnd.yyyyMmDd;
  if (!_ymdRe.hasMatch(end) || !end.startsWith('$yyyyMm-')) {
    throw ArgumentError.value(end, 'monthEnd', '$yyyyMm 의 날이 아니다');
  }
  final int month = int.parse(yyyyMm.substring(5, 7));
  final AsOf asOf = AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: monthEnd,
    source: AsOfSource.localSqlite,
    staleAfter: kGoalPathStaleAfter,
    label: GoalPathTexts.asOfLabel(end),
  );

  GoalPathOutcome hold(String basis) => GoalPathOutcome(
    GoalPathVm(
      yyyyMm: yyyyMm,
      judgementText: GoalPathTexts.withheld,
      basisText: basis,
      periodLabel: GoalPathTexts.holdPeriod(yyyyMm),
      plannedLabel: GoalPathTexts.plannedLabel,
      actualLabel: GoalPathTexts.actualLabel,
      planned: const <PerfPoint>[],
      actual: const <PerfPoint>[],
      yTicks: const <PerfAxisTick>[],
      segments: const <PerfSegment>[],
      chartUnavailableLabel: GoalPathTexts.chartUnavailable,
      backtestBasisText: GoalPathTexts.backtestBasis,
      startingCapitalAssumptionText: GoalPathTexts.startingCapital,
      honestExpectationText: GoalPathTexts.honest,
      honestExpectationWorstText: GoalPathTexts.honestWorst,
      disclaimerText: GoalPathTexts.disclaimer,
      asOf: asOf,
    ),
    GoalVerdict.withheld,
  );

  // 그 달 뒤 점 = 쓰지 않는다(점은 달마다 날짜 범위로 고르고 · 첫 스냅숏이 그 달 뒤면 «3개월 미만»으로 유보).
  final List<EquityPoint> eq = equity;
  if (eq.isEmpty) return hold(GoalPathTexts.basisShort);
  final String first = eq.first.date;
  final int open = _monthIndex(first);
  final int target = _monthIndex(yyyyMm);
  if (target - open < kGoalPathMinMonths) return hold(GoalPathTexts.basisShort);

  // 점 — 개시 점 + 다음 달부터 그 달까지 달마다 마지막 스냅숏(없으면 그 달 마지막 세션 · 결측).
  final List<(String, String, double?)> pts = <(String, String, double?)>[
    (first, GoalPathTexts.monthText(first), eq.first.equity),
  ];
  for (int m = open + 1; m <= target; m++) {
    final String ym = _ymOf(m);
    final String from = '$ym-01';
    final String to = m == target ? end : _calendarMonthEnd(ym);
    EquityPoint? snap;
    for (final EquityPoint p in eq) {
      if (p.date.compareTo(from) >= 0 && p.date.compareTo(to) <= 0) snap = p;
    }
    String d = to;
    if (snap != null) {
      d = snap.date;
    } else {
      while (d.compareTo(from) > 0 && !isSession(d)) {
        d = _shift(d, -1);
      }
    }
    pts.add((d, GoalPathTexts.monthText(ym), snap?.equity));
  }
  if (pts.last.$3 == null) return hold(GoalPathTexts.basisNoMonthEnd(month));

  // 계획 납입 — 개시 다음 달부터 그 달까지 그달 첫 KR 세션(개시 뒤) · 금액 = 그날 현재 설정값(없으면 기본값).
  final List<(String, double)> plan = <(String, double)>[];
  for (int m = open + 1; m <= target; m++) {
    final String ym = _ymOf(m);
    final String last = _calendarMonthEnd(ym);
    String d = '$ym-01';
    while (!isSession(d) && d.compareTo(last) < 0) {
      d = _shift(d, 1);
    }
    if (!isSession(d) || d.compareTo(first) <= 0 || d.compareTo(end) > 0) {
      continue;
    }
    final ContributionParamRow? row = splitContributionRows(
      contributionRows,
      d,
    ).$1;
    plan.add((d, (row?.amount ?? contributionConfig.defaultAmount).toDouble()));
  }
  double grow(String from, String to) =>
      math.pow(1 + kGoalPathHonestAnnualRate, _days(from, to) / 365).toDouble();
  double plannedAt(String d) {
    double v = eq.first.equity * grow(first, d);
    for (final (String day, double amount) in plan) {
      if (day.compareTo(d) <= 0) v += amount * grow(day, d);
    }
    return v;
  }

  final List<GoalPathFact> facts = <GoalPathFact>[
    for (final (String d, String text, double? a) in pts)
      GoalPathFact(date: d, dateText: text, planned: plannedAt(d), actual: a),
  ];
  final GoalPathChart chart = goalPathChartOf(facts, isSession: isSession);
  final double a = chart.actual.last.value!;
  final double p = chart.planned.last.value!;
  final GoalVerdict verdict = a >= p
      ? GoalVerdict.ahead
      : (a < p / (1 + kGoalPathHonestAnnualRate)
            ? GoalVerdict.offTrack
            : GoalVerdict.onTrack);
  final bool off = verdict == GoalVerdict.offTrack;
  return GoalPathOutcome(
    GoalPathVm(
      yyyyMm: yyyyMm,
      judgementText: off ? GoalPathTexts.offTrack : GoalPathTexts.onTrack,
      basisText: off
          ? GoalPathTexts.basisBelow(month)
          : GoalPathTexts.basisWithin(month),
      deviationText: off ? GoalPathTexts.deviation : null,
      periodLabel:
          '${GoalPathTexts.monthText(first)} ~ ${GoalPathTexts.monthText(yyyyMm)}',
      plannedLabel: GoalPathTexts.plannedLabel,
      actualLabel: GoalPathTexts.actualLabel,
      planned: chart.planned,
      actual: chart.actual,
      yTicks: chart.yTicks,
      segments: chart.segments,
      backtestBasisText: GoalPathTexts.backtestBasis,
      startingCapitalAssumptionText: GoalPathTexts.startingCapital,
      honestExpectationText: GoalPathTexts.honest,
      honestExpectationWorstText: GoalPathTexts.honestWorst,
      disclaimerText: GoalPathTexts.disclaimer,
      asOf: asOf,
    ),
    verdict,
  );
}
