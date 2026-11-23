// 🆕 E11q-q5b — M7 `S7-2` 성과 탐색 시리즈 VM(설계 13 §8 R223 · 01 §2-4 · C-36 · 표본 `m7/m7_perf_*`).
//
// 🔴 원천 = 계층 B · 월간 리포트와 같은 TWR 지수(`twrIndex` — 입출금은 수익이 아니다 · 개시 이전 = 성과 밖) · 지금 원장 한 파일
//    (원장 = 모드 경계 — 체험 중 = 모의 원장의 결과 · 모의/실전 섞어 보기(`SIM_EXCLUDED`)는 실전 뒤 몫).
// 🔴 점 = 주기마다 그 기간의 마지막 스냅숏(일별 = 한국 세션마다 · 월별 · 연도별 = 그 달 · 그해의 마지막 스냅숏 · 없으면 마지막 세션 ·
//    값 0 · `EQUITY_SNAPSHOT_MISSING`) · 기본 구간(인자 없음) = 일별 = 이번 달(첫 스냅숏 앞은 빼고) · 월별 · 연도별 = 처음부터.
//    오늘 = 스냅숏이 있을 때만(장 마감 전 «산출 불가» 를 지어내지 않는다).
// 🔴 값 = 누적 = 첫 점이 덮는 기간의 시작 대비(일별 = 첫 점 = 0 · 월별 · 연도별 = 첫 스냅숏) · 기간별 = 앞 점 대비(앞 점이 비면
//    그 앞 마지막 스냅숏부터 — 결측을 건너 잇는다) · 0.01%p 로 반올림(표시 정본 = `valueText`).
// 🔴 기하 = 표본에서 거꾸로 맞춘 규칙: 가로 = i ÷ (n−1)(1점 = 0.5) · 세로 = 0 을 품는 눈금 범위(간격 = 1 · 2 · 5 × 10^k 중
//    네 칸 이하가 되는 가장 작은 것) · 띠 = 덮는 점의 앞뒤 반 칸(0~1 로 자름) · 띠 시작 = 그 점이 덮는 기간의 첫날(앞 점 다음 세션 ·
//    첫 점 = 일별 그날 · 월별 · 연도별 = 첫 스냅숏 날).
// 🔴 빈 시리즈(점 0 · 문장 카드 1장 · C-36 ⑤) = 원장 무결성 점검 중(가림) · 금액가중(🆕 산출 방식 미정 — 지어내지 않는다) ·
//    스냅숏 0 · 구간 전체 결측. 벤치마크 = 지수 시세 원천 0 → null · 세후 = 연 1회(`S7-7`) → null.

import 'dart:math' as math;

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        PerfAxisTick,
        PerfDisclosure,
        PerfGranularity,
        PerfMetric,
        PerfPoint,
        PerfSegment,
        PerformanceSeries,
        SegmentKind,
        TradeDate;

import 'ledger_views.dart' show kstDateText;
import 'tier_b.dart' show EquityPoint, twrIndex;

/// 성과 기준 유효 시간(표본 93600초 = 26시간).
const Duration kPerfSeriesStaleAfter = Duration(hours: 26);

/// 결측 사유 — 스냅숏 없음(인벤토리 §6-14).
const String kPerfGapSnapshotMissing = 'EQUITY_SNAPSHOT_MISSING';

/// 시리즈 글자(표본 그대로 · 🆕 = 표본 밖 상태).
abstract final class PerfSeriesTexts {
  /// 인터스티셜.
  static const String interstitial = '수익률은 결과이지 목표가 아닙니다. 열람 기록이 남습니다.';

  /// 정직 기대 줄.
  static const String honestExpectation = '정직 기대는 백테스트 점추정보다 낮습니다.';

  /// 낙폭 경고 줄.
  static const String drawdownCaveat = '최대낙폭은 관측 하한이며 앞으로의 상한이 아닙니다.';

  /// 무결성 가림.
  static const String integrityMasked = '원장 무결성 점검 중에는 수익률을 보여 주지 않습니다.';

  /// 🆕 금액가중 — 산출 방식 미정.
  static const String mwrUnavailable = '금액가중 수익률은 아직 산출하지 않습니다. 시간가중으로 보십시오.';

  /// 🆕 스냅숏 0(운용 첫 마감 전).
  static const String noSnapshot = '아직 마감 평가액 기록이 없어 수익률을 낼 수 없습니다.';

  /// 구간 전체 결측(표본 `m7_perf_unavailable_gap` — 일별 «7거래일»).
  static String allMissing(int n, PerfGranularity g) =>
      '$n${_unit(g)} 동안 기록이 비어 이 기간의 수익률을 낼 수 없습니다.';

  /// 표본 없음.
  static const String sampleNone = '관측 표본이 없습니다. 이 기간은 산출할 수 없습니다.';

  /// 일별 표본 크기.
  static String sampleDaily(int n) =>
      '관측 표본은 $n거래일입니다. 이 길이로는 아무것도 판정할 수 없습니다.';

  /// 월별 표본 크기.
  static String sampleMonthly(int n) =>
      '관측 표본은 $n개월입니다. 이 길이로는 규칙의 우열을 가릴 수 없습니다.';

  /// 연도별 표본 크기 — [lastMonth] = 마지막 해가 끝나지 않았으면 그 달.
  static String sampleYearly(int n, int? lastMonth) => lastMonth == null
      ? '관측 표본은 $n개 연도입니다.'
      : '관측 표본은 $n개 연도입니다(마지막 해는 $lastMonth월까지).';

  /// 본선 이름.
  static String seriesLabel(PerfMetric m, PerfGranularity g, bool cumulative) =>
      '내 계좌 · ${m == PerfMetric.twr ? '시간가중' : '금액가중'} · '
      '${cumulative ? '누적' : _per(g)}';

  /// 측정 띠.
  static const String measured = '측정 구간';

  /// 결측 띠.
  static const String missing = '결측 — 스냅샷 없음';

  /// 결측 점.
  static const String notComputable = '산출 불가';

  /// 기준(마감 스냅숏 날).
  static String asOfLabel(String day) => '성과 기준 $day 종가';

  /// 🆕 기준(스냅숏 0).
  static String asOfLabelNone(String day) => '성과 기준 $day';

  static String _unit(PerfGranularity g) => switch (g) {
    PerfGranularity.daily => '거래일',
    PerfGranularity.monthly => '개월',
    PerfGranularity.yearly => '개 연도',
    PerfGranularity.weekly => '주',
  };

  static String _per(PerfGranularity g) => switch (g) {
    PerfGranularity.daily => '일별',
    PerfGranularity.monthly => '월별',
    PerfGranularity.yearly => '연도별',
    PerfGranularity.weekly => '주별',
  };
}

/// 점 하나(기하 전).
class _Pt {
  _Pt(this.date, this.text, this.snap);
  final String date;
  final String text;

  /// 이 점을 대표하는 스냅숏 날(없으면 결측).
  final String? snap;
}

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

double _r4(double x) => (x * 10000).round() / 10000;

int _floorDiv(int a, int b) => (a / b).floor();
int _ceilDiv(int a, int b) => (a / b).ceil();

/// 0.01%p 단위 → «1.42%» · «−1.10%».
String _pct(int u) =>
    '${u < 0 ? '−' : ''}${(u.abs() / 100).toStringAsFixed(2)}%';

/// 눈금 글자 — 간격 1%p 이상 = 정수 · 0.1%p 이상 = 한 자리 · 그 밖 = 두 자리.
String _tick(int u, int step) {
  final int dec = step >= 100 ? 0 : (step >= 10 ? 1 : 2);
  return '${u < 0 ? '−' : ''}${(u.abs() / 100).toStringAsFixed(dec)}%';
}

/// 🔴 `S7-2` 시리즈 — [equity] = 개시 뒤 마감 스냅숏(날짜 순 · 흐름 포함) · [isSession] = 한국 세션 ·
/// [viewCountThisMonth] = 이번 달 열람 기록 수 · [integrityHidden] = 원장 무결성 점검 중 · 주별 = 미정(미결 54) 실패.
PerformanceSeries performanceSeriesOf({
  required PerfMetric metric,
  required PerfGranularity granularity,
  required bool cumulative,
  required List<EquityPoint> equity,
  required bool Function(String ymd) isSession,
  required DateTime nowUtc,
  required int viewCountThisMonth,
  required bool integrityHidden,
}) {
  if (granularity == PerfGranularity.weekly) {
    throw UnsupportedError('주별 시리즈: 주 경계 미정(미결 54)');
  }
  if (viewCountThisMonth < 0) {
    throw ArgumentError.value(viewCountThisMonth, 'viewCountThisMonth', '음수');
  }
  final String today = kstDateText(nowUtc);
  final List<EquityPoint> eq = <EquityPoint>[
    for (final EquityPoint p in equity)
      if (p.date.compareTo(today) <= 0) p,
  ];
  final String label = PerfSeriesTexts.seriesLabel(
    metric,
    granularity,
    cumulative,
  );

  PerfDisclosure disclosure(String sample) => PerfDisclosure(
    sampleSizeLine: sample,
    interstitialText: PerfSeriesTexts.interstitial,
    viewCountThisMonth: viewCountThisMonth,
    honestExpectationLine: PerfSeriesTexts.honestExpectation,
    drawdownCaveatLine: PerfSeriesTexts.drawdownCaveat,
  );

  AsOf asOf(String day, String text) => AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kPerfSeriesStaleAfter,
    label: text,
  );

  PerformanceSeries empty({
    required String period,
    required String sample,
    required String why,
    required AsOf at,
  }) => PerformanceSeries(
    metric: metric,
    granularity: granularity,
    cumulative: cumulative,
    segments: const <PerfSegment>[],
    points: const <PerfPoint>[],
    disclosure: disclosure(sample),
    asOf: at,
    seriesLabel: label,
    periodLabel: period,
    unavailableLabel: why,
  );

  if (eq.isEmpty) {
    return empty(
      period: _emptyPeriod(granularity, today),
      sample: PerfSeriesTexts.sampleNone,
      why: integrityHidden
          ? PerfSeriesTexts.integrityMasked
          : (metric == PerfMetric.mwr
                ? PerfSeriesTexts.mwrUnavailable
                : PerfSeriesTexts.noSnapshot),
      at: asOf(today, PerfSeriesTexts.asOfLabelNone(today)),
    );
  }

  final Map<String, int> at = <String, int>{
    for (int k = 0; k < eq.length; k++) eq[k].date: k,
  };
  final List<double> index = twrIndex(eq);
  final String first = eq.first.date;
  final String last = eq.last.date;

  // 끝 = 오늘(스냅숏이 있을 때) · 아니면 오늘 앞 마지막 세션(첫 스냅숏 앞으로는 가지 않는다).
  String end = today;
  while (end.compareTo(first) > 0 &&
      (!isSession(end) || (end == today && !at.containsKey(end)))) {
    end = _shift(end, -1);
  }
  if (end.compareTo(last) < 0) end = last;

  final List<_Pt> pts = switch (granularity) {
    PerfGranularity.daily => _daily(first, end, isSession, at),
    PerfGranularity.monthly => _monthly(first, end, isSession, eq),
    _ => _yearly(first, end, isSession, eq),
  };
  final int n = pts.length;
  final int? lastMonth =
      granularity == PerfGranularity.yearly && pts.last.text.contains('(')
      ? int.parse(pts.last.date.substring(5, 7))
      : null;
  final String sample = switch (granularity) {
    PerfGranularity.daily => PerfSeriesTexts.sampleDaily(n),
    PerfGranularity.monthly => PerfSeriesTexts.sampleMonthly(n),
    _ => PerfSeriesTexts.sampleYearly(n, lastMonth),
  };
  final String period = granularity == PerfGranularity.daily
      ? '${pts.first.date} ~ ${pts.last.date}'
      : (n == 1 ? pts.first.text : '${pts.first.text} ~ ${pts.last.text}');
  final AsOf seriesAsOf = asOf(last, PerfSeriesTexts.asOfLabel(last));

  // 값(0.01%p) — 첫 점 = 0 · 누적 = 첫 점 대비 · 기간별 = 앞 점(비면 그 앞 마지막 스냅숏) 대비.
  double? idxAtOrBefore(String d) {
    double? v;
    for (int k = 0; k < eq.length && eq[k].date.compareTo(d) <= 0; k++) {
      v = index[k];
    }
    return v;
  }

  // 기준 = 첫 점이 덮는 기간의 시작 — 일별 = 첫 점 그날(값 0) · 월별 · 연도별 = 첫 스냅숏(표본 `yearly` 첫 해 0.74%).
  final List<int?> units = <int?>[];
  final double? base = granularity != PerfGranularity.daily
      ? index[0]
      : (pts.first.snap != null
            ? index[at[pts.first.snap]!]
            : idxAtOrBefore(pts.first.date));
  for (int i = 0; i < n; i++) {
    final String? s = pts[i].snap;
    if (s == null) {
      units.add(null);
      continue;
    }
    final double here = index[at[s]!];
    final double? from = cumulative || i == 0
        ? base
        : idxAtOrBefore(pts[i - 1].date);
    units.add(
      from == null || from == 0 ? null : ((here / from - 1) * 10000).round(),
    );
  }

  if (integrityHidden) {
    return empty(
      period: period,
      sample: sample,
      why: PerfSeriesTexts.integrityMasked,
      at: seriesAsOf,
    );
  }
  if (metric == PerfMetric.mwr) {
    return empty(
      period: period,
      sample: sample,
      why: PerfSeriesTexts.mwrUnavailable,
      at: seriesAsOf,
    );
  }
  final List<int> known = <int>[for (final int? u in units) ?u];
  if (known.isEmpty) {
    return empty(
      period: period,
      sample: PerfSeriesTexts.sampleNone,
      why: PerfSeriesTexts.allMissing(n, granularity),
      at: seriesAsOf,
    );
  }

  // 세로 눈금.
  final int minU = math.min(0, known.reduce(math.min));
  final int maxU = math.max(0, known.reduce(math.max));
  int lo = 0, hi = 100, step = 100;
  if (minU != maxU) {
    for (int k = 0; ; k++) {
      final int s = <int>[1, 2, 5][k % 3] * math.pow(10, k ~/ 3).toInt();
      final int l = _floorDiv(minU, s) * s;
      final int h = _ceilDiv(maxU, s) * s;
      if ((h - l) ~/ s <= 4) {
        lo = l;
        hi = h;
        step = s;
        break;
      }
    }
  }
  double y(int u) => _r4((u - lo) / (hi - lo));
  final List<PerfAxisTick> ticks = <PerfAxisTick>[
    for (int t = lo; t <= hi; t += step)
      PerfAxisTick(normalized: y(t), label: _tick(t, step), isBaseline: t == 0),
  ];

  double xRaw(int i) => n == 1 ? 0.5 : i / (n - 1);
  final double half = n == 1 ? 0.5 : 0.5 / (n - 1);
  final List<PerfPoint> points = <PerfPoint>[
    for (int i = 0; i < n; i++)
      PerfPoint(
        date: TradeDate(pts[i].date),
        xNormalized: _r4(xRaw(i)),
        dateText: pts[i].text,
        valueText: units[i] == null
            ? PerfSeriesTexts.notComputable
            : _pct(units[i]!),
        yNormalized: units[i] == null ? null : y(units[i]!),
        value: units[i] == null ? null : units[i]! / 10000,
        gapReasonCode: units[i] == null ? kPerfGapSnapshotMissing : null,
      ),
  ];

  String periodStart(int i) {
    if (i == 0) {
      return granularity == PerfGranularity.daily ? pts[0].date : first;
    }
    String d = _shift(pts[i - 1].date, 1);
    while (!isSession(d) && d.compareTo(pts[i].date) < 0) {
      d = _shift(d, 1);
    }
    return d;
  }

  final List<PerfSegment> segments = <PerfSegment>[];
  int runStart = 0;
  for (int i = 1; i <= n; i++) {
    if (i < n && (units[i] == null) == (units[runStart] == null)) continue;
    final bool ok = units[runStart] != null;
    segments.add(
      PerfSegment(
        from: TradeDate(periodStart(runStart)),
        to: TradeDate(pts[i - 1].date),
        kind: ok ? SegmentKind.measured : SegmentKind.unavailable,
        label: ok ? PerfSeriesTexts.measured : PerfSeriesTexts.missing,
        startNormalized: math.max(0, _r4(xRaw(runStart) - half)),
        endNormalized: math.min(1, _r4(xRaw(i - 1) + half)),
      ),
    );
    runStart = i;
  }

  return PerformanceSeries(
    metric: metric,
    granularity: granularity,
    cumulative: cumulative,
    segments: segments,
    points: points,
    disclosure: disclosure(sample),
    asOf: seriesAsOf,
    seriesLabel: label,
    periodLabel: period,
    yTicks: ticks,
  );
}

String _emptyPeriod(PerfGranularity g, String today) => switch (g) {
  PerfGranularity.daily => '$today ~ $today',
  PerfGranularity.monthly =>
    '${int.parse(today.substring(0, 4))}년 ${int.parse(today.substring(5, 7))}월',
  _ => '${int.parse(today.substring(0, 4))}년',
};

/// 일별 — 이번 달(끝 날의 달) 세션 · 첫 스냅숏 앞은 뺀다.
List<_Pt> _daily(
  String first,
  String end,
  bool Function(String) isSession,
  Map<String, int> at,
) {
  final String monthStart = '${end.substring(0, 7)}-01';
  final String start = first.compareTo(monthStart) > 0 ? first : monthStart;
  return <_Pt>[
    for (String d = start; d.compareTo(end) <= 0; d = _shift(d, 1))
      if (isSession(d) || at.containsKey(d))
        _Pt(d, d, at.containsKey(d) ? d : null),
  ];
}

/// 그 기간([from]~[to])의 마지막 스냅숏 · 없으면 마지막 세션.
_Pt _periodPoint(
  String from,
  String to,
  String text,
  bool Function(String) isSession,
  List<EquityPoint> eq,
) {
  String? snap;
  for (final EquityPoint p in eq) {
    if (p.date.compareTo(from) >= 0 && p.date.compareTo(to) <= 0) snap = p.date;
  }
  if (snap != null) return _Pt(snap, text, snap);
  String d = to;
  while (d.compareTo(from) > 0 && !isSession(d)) {
    d = _shift(d, -1);
  }
  return _Pt(d, text, null);
}

String _monthEnd(int y, int m) =>
    _ymd(DateTime.utc(y, m + 1, 1).subtract(const Duration(days: 1)));

List<_Pt> _monthly(
  String first,
  String end,
  bool Function(String) isSession,
  List<EquityPoint> eq,
) {
  final List<_Pt> out = <_Pt>[];
  int y = int.parse(first.substring(0, 4));
  int m = int.parse(first.substring(5, 7));
  final int ey = int.parse(end.substring(0, 4));
  final int em = int.parse(end.substring(5, 7));
  while (y < ey || (y == ey && m <= em)) {
    final String from =
        '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-01';
    final String me = _monthEnd(y, m);
    final String to = me.compareTo(end) < 0 ? me : end;
    out.add(_periodPoint(from, to, '$y년 $m월', isSession, eq));
    if (++m > 12) {
      m = 1;
      y++;
    }
  }
  return out;
}

List<_Pt> _yearly(
  String first,
  String end,
  bool Function(String) isSession,
  List<EquityPoint> eq,
) {
  final int fy = int.parse(first.substring(0, 4));
  final int ey = int.parse(end.substring(0, 4));
  String lastSessionOf(int y) {
    String d = '${y.toString().padLeft(4, '0')}-12-31';
    for (int k = 0; k < 366 && !isSession(d); k++) {
      d = _shift(d, -1);
    }
    return d;
  }

  return <_Pt>[
    for (int y = fy; y <= ey; y++)
      () {
        final String to = y < ey ? '$y-12-31' : end;
        final bool done = y < ey || end.compareTo(lastSessionOf(y)) >= 0;
        final _Pt p = _periodPoint('$y-01-01', to, '$y년', isSession, eq);
        return done
            ? p
            : _Pt(
                p.date,
                '$y년(${int.parse(p.date.substring(5, 7))}월까지)',
                p.snap,
              );
      }(),
  ];
}
