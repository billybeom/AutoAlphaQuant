// E11q-s71b — M7 `S7-1b` 월간 리포트 보관함 VM 짓기(설계 13 §8 R253 · 앱 03 §4 ⓐ~ⓙ · 01 §13-8 · 미결 209 ⓔ-4 의 보관함 몫).
//
// 🔴 행 = `S7-1` 이 지금 지을 수 있는 달과 같은 판정([monthlyReportReadinessOf] — 닫힌 달 · 개시 달부터) · 최신 달부터 ·
//    수치 칸 0(03 §4 ⓗ). 저장(스냅숏 · G-97)이 없으므로 «생성됨» = 읽을 때 지을 수 있는 닫힌 달이다 — 아직 닫히지 않은 달은 싣지
//    않는다(지난 리포트 목록 · 미생성 문장 = ⓔ-4 그대로).
// 🔴 링크 = 지금 원장의 달 ∧ 자동 매매(S7-1 원천이 짓는 갈래) ∧ 본문 등록(`reportMonthly`) — 투자 안내 = 링크 0 + 사유
//    (S7-1 = 원천 없음 · X7 사다리 전) · 실전 전환 뒤 옛 모의 파일의 달 = 링크 0 + 표본 사유(S7-1 은 지금 원장만 읽는다).
// 🔴 머리글 = 같은 (연도 · 모드) 묶음의 첫 행에만(엔진 · 화면은 앞 행과 비교하지 않는다 — 03 §4 ⓒ).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        OperatingMode,
        ReportArchiveRow,
        ReportArchiveVm,
        RunMode,
        TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import 'ledger_views.dart' show kstDateText;
import 'monthly_report.dart'
    show MonthlyReportReadiness, monthlyReportReadinessOf;

/// 보관함 신선도(표본 `stale_after_seconds` 93600 = 26시간).
const Duration kReportArchiveStaleAfter = Duration(hours: 26);

/// 보관함 글자(표본 `m7/m7_report_archive_*` · 엔진 정본).
abstract final class ReportArchiveTexts {
  /// 실전 칩.
  static const String live = '실전';

  /// 모의 칩.
  static const String sim = '모의투자';

  /// 실전 전환 뒤 옛 모의 달(표본 그대로).
  static const String simClosed = '모의 기간의 리포트는 앱에서 열 수 없습니다.';

  /// 🆕 투자 안내 — S7-1 원천 전(X7 신뢰 등급 사다리 · 이행 갭 조각 전).
  static const String advisory = '투자 안내 방식의 월간 리포트는 아직 만들지 않습니다.';

  /// 빈 보관함(표본 `m7_report_archive_empty` 그대로).
  static const String empty = '아직 발행된 리포트가 없습니다 · 첫 리포트는 월 마감 뒤에 만들어집니다';

  /// 달 이름(«2026년 8월»).
  static String month(String yyyyMm) =>
      '${int.parse(yyyyMm.substring(0, 4))}년 ${int.parse(yyyyMm.substring(5, 7))}월';

  /// 머리글(«2026년» · «2025년 · 모의투자»).
  static String section(String yyyyMm, {required bool sim}) {
    final String y = '${int.parse(yyyyMm.substring(0, 4))}년';
    return sim ? '$y · 모의투자' : y;
  }
}

bool _noBody(String _) => false;

/// 보관함 사실(조립 앱이 모은다).
class ReportArchiveFacts {
  /// 사실을 만든다.
  const ReportArchiveFacts({
    required this.runMode,
    required this.operatingMode,
    required this.openingDate,
    required this.nowUtc,
    this.pastSimOpeningDate,
    this.hasBody = _noBody,
  });

  /// 지금 원장의 실행 모드(화면 상태).
  final RunMode runMode;

  /// 지금 운영 방식(화면 상태).
  final OperatingMode operatingMode;

  /// 지금 원장의 개시 날(`openingCashTradeDate` · null = 개시 0 → 행 0).
  final String? openingDate;

  /// 🔴 실전일 때만 — 옛 모의 파일의 개시 날(null = 모의 달 0).
  final String? pastSimOpeningDate;

  /// 지금(기기 시계 — 읽기 · S7-1 과 같은 시계).
  final DateTime nowUtc;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _next(String yyyyMm) {
  final int y = int.parse(yyyyMm.substring(0, 4));
  final int m = int.parse(yyyyMm.substring(5, 7));
  return m == 12 ? '${y + 1}-01' : '$y-${_two(m + 1)}';
}

/// [yyyyMm] 의 마지막 KR 세션 — 달력이 덮지 않거나 세션이 없으면 null(그 달은 싣지 않는다 · 지어내지 않는다).
TradeDate? _monthEnd(ExchangeCalendar kr, String yyyyMm) {
  final int y = int.parse(yyyyMm.substring(0, 4));
  final int m = int.parse(yyyyMm.substring(5, 7));
  for (int d = DateTime.utc(y, m + 1, 0).day; d >= 1; d--) {
    final TradeDate day = TradeDate('$yyyyMm-${_two(d)}');
    try {
      if (kr.isSession(day)) return day;
    } on StateError {
      return null;
    }
  }
  return null;
}

/// 🔴 [openingDate] 달부터 지금 달까지 `S7-1` 이 지금 지을 수 있는 달(닫힌 달) — 최신 달부터 · [before] 달 앞까지만.
List<String> reportArchiveMonthsOf({
  required ExchangeCalendar kr,
  required String? openingDate,
  required DateTime nowUtc,
  String? before,
}) {
  final String? o = openingDate;
  if (o == null) return const <String>[];
  final String last = kstDateText(nowUtc).substring(0, 7);
  final List<String> out = <String>[];
  for (String m = o.substring(0, 7); m.compareTo(last) <= 0; m = _next(m)) {
    if (before != null && m.compareTo(before) >= 0) break;
    final TradeDate? end = _monthEnd(kr, m);
    if (end == null) continue;
    if (monthlyReportReadinessOf(
          yyyyMm: m,
          monthEnd: end,
          openingDate: o,
          nowUtc: nowUtc,
        ) ==
        MonthlyReportReadiness.closed) {
      out.add(m);
    }
  }
  return out.reversed.toList();
}

/// 🔴 `S7-1b` 보관함.
ReportArchiveVm reportArchiveVmOf(
  ReportArchiveFacts f, {
  required ExchangeCalendar kr,
}) {
  final DateTime now = f.nowUtc.toUtc();
  final bool currentSim = f.runMode != RunMode.live;
  final bool auto = f.operatingMode == OperatingMode.autoTrade;
  final bool body = f.hasBody(AppRoutes.reportMonthly);
  final List<String> current = reportArchiveMonthsOf(
    kr: kr,
    openingDate: f.openingDate,
    nowUtc: now,
  );
  // 옛 모의 달 = 지금(실전) 원장의 첫 달 앞까지(같은 달 두 행 0 — 화면 Key = 달).
  final String? o = f.openingDate;
  final List<String> pastSim = currentSim
      ? const <String>[]
      : reportArchiveMonthsOf(
          kr: kr,
          openingDate: f.pastSimOpeningDate,
          nowUtc: now,
          before: o == null
              ? kstDateText(now).substring(0, 7)
              : o.substring(0, 7),
        );
  final List<(String, bool, ReportArchiveRow)> rows =
      <(String, bool, ReportArchiveRow)>[
        for (final String m in current)
          (
            m,
            currentSim,
            ReportArchiveRow(
              yyyyMm: m,
              label: ReportArchiveTexts.month(m),
              generated: auto,
              modeLabel: currentSim
                  ? ReportArchiveTexts.sim
                  : ReportArchiveTexts.live,
              reasonLabel: auto ? null : ReportArchiveTexts.advisory,
              route: auto && body
                  ? AppRoutes.reportMonthly.replaceFirst(':yyyyMm', m)
                  : null,
            ),
          ),
        for (final String m in pastSim)
          (
            m,
            true,
            ReportArchiveRow(
              yyyyMm: m,
              label: ReportArchiveTexts.month(m),
              generated: true,
              modeLabel: ReportArchiveTexts.sim,
              reasonLabel: ReportArchiveTexts.simClosed,
            ),
          ),
      ];
  final Set<String> seen = <String>{};
  final List<ReportArchiveRow> out = <ReportArchiveRow>[
    for (final (String m, bool sim, ReportArchiveRow r) in rows)
      seen.add('${m.substring(0, 4)}/$sim')
          ? r.copyWith(sectionLabel: ReportArchiveTexts.section(m, sim: sim))
          : r,
  ];
  final String today = kstDateText(now);
  return ReportArchiveVm(
    rows: out,
    emptyLabel: out.isEmpty ? ReportArchiveTexts.empty : null,
    asOf: AsOf(
      observedAt: now,
      tradeDate: TradeDate(today),
      source: AsOfSource.localSqlite,
      staleAfter: kReportArchiveStaleAfter,
      label: '아카이브 기준 $today',
    ),
  );
}
