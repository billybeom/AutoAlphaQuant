// E11p3d-2b — `H-01` 운영 홈 오늘 요약 · `H-02` 운영 리듬(설계 13 §8 R133 · 발주자 «H-01 맡아» 2026-11-16).
//
// 🔴 전부 엔진 완성 문자열 — 화면은 세지도 · 날짜를 빼지도 않는다(01 §4-1 · 04 §4-4).
// 🔴 정의가 없는 칸은 지어내지 않는다 — 신호 일치 · 규칙 준수 연속 · 투자 안내 기록 = «판정 보류»(원천 · 정의 생기면 바꾼다).
// 🔵 재량 예산 = SPEC FR-709(롤링 12개월 4회) 엔진 문장 그대로(R64 W7) — 표본 «이번 달 2회»는 따르지 않는다.
// 🔵 D-day = 달력일(K23) · 같은 날 = «D-day».
// 🔵 리듬 행 = 원천 있는 둘(월간 정기 리밸런싱 · 월 납입)만 — 월간 리포트 · 분기 실사 · 연간 리뷰 = 원천 없음(행 부재).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        EmptyKind,
        LinkAction,
        ListResult,
        OperatingMode,
        OpsDailySummary,
        OpsRhythmRow,
        TradeDate;

import '../calendar/exchange_calendar.dart';
import '../calendar/next_rebalance.dart';
import '../safety/discretion.dart' show DiscretionBudget, discretionBudgetText;
import 'contribution_setting.dart' show nextContributionDay;
import 'ledger_views.dart' show kReconStaleAfter, kstDateText;

/// 홈 · 리듬 신선도 — 마지막 엔진 활동(잡 기록)에서 26시간(대조 기준과 같은 값 · 표본 93600초).
const Duration kOpsHomeStaleAfter = kReconStaleAfter;

/// 리듬 행 코드(표본 사전과 같은 글자).
abstract final class OpsRhythmCodes {
  /// 월간 정기 리밸런싱.
  static const String monthlyRebalance = 'MONTHLY_REBALANCE';

  /// 월 납입.
  static const String monthlyContribution = 'MONTHLY_CONTRIBUTION';
}

/// «판정 보류» 문장(정의 · 원천이 생기면 바꾼다).
abstract final class OpsHomePendingText {
  /// 자동 매매 — 신호 일치(섀도 · 신호 원천 없음).
  static const String signalMatch = '신호 일치 판정 보류';

  /// 투자 안내 — 안내 대비 기록(X7 기록 원천 없음).
  static const String adviceRecord = '안내 기록 판정 보류';

  /// 투자 안내 — 오늘 기록 수(X7 수기 기록 원천 없음).
  static const String todayRecords = '오늘 기록 판정 보류';

  /// 규칙 준수 연속(끊김 사건 정의 없음).
  static const String streak = '규칙 준수 판정 보류';
}

/// 달력 범위 밖이라 다음 회차를 모를 때(지어내지 않는다).
const String kOpsHomeNoRebalanceText = '예정된 회차가 아직 없습니다';

/// 리듬이 빈 날의 글자.
const String kOpsRhythmEmptyLabel = '예정된 운영 일정이 없습니다';

/// 홈 오늘 요약의 사실(앱이 원장에서 모은다).
class OpsHomeFacts {
  /// 만든다.
  const OpsHomeFacts({
    required this.operatingMode,
    required this.ordersToday,
    required this.failedJobsToday,
    required this.discretion,
    required this.lastActivityUtc,
    this.resumeLine,
  });

  /// 운영 방식(자동 매매 / 투자 안내 — 문장 갈래).
  final OperatingMode operatingMode;

  /// 오늘(KST) 7단계를 지난 주문 의도 수(SAF-401 `orders_today` 와 같은 셈).
  final int ordersToday;

  /// 오늘(KST) 세션의 실패한 잡 회차 수(이 모드 접두 · FAILED 만).
  final int failedJobsToday;

  /// 재량 예산(신뢰 시각 모름 = null).
  final DiscretionBudget? discretion;

  /// 마지막 잡 기록 시각(없음 = null → 지금).
  final DateTime? lastActivityUtc;

  /// X2 한 줄(실행 기록 없음 = null).
  final LinkAction? resumeLine;
}

/// 달력일 D-day(K23) — [fromDay] → [toDay](둘 다 `YYYY-MM-DD`) · 같은 날 = «D-day».
String opsDDayText(String fromDay, String toDay) {
  final int n = DateTime.parse('${toDay}T00:00:00Z')
      .difference(DateTime.parse('${fromDay}T00:00:00Z'))
      .inDays;
  if (n < 0) throw ArgumentError('지난 날($toDay < $fromDay)');
  return n == 0 ? 'D-day' : 'D-$n';
}

/// 홈 · 리듬 기준 — 관측 = 마지막 엔진 활동(없으면 지금) · 26시간.
AsOf opsHomeAsOf({
  required DateTime? lastActivityUtc,
  required DateTime nowUtc,
  required String prefix,
}) {
  final DateTime at = (lastActivityUtc ?? nowUtc).toUtc();
  final String day = kstDateText(at);
  return AsOf(
    observedAt: at,
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kOpsHomeStaleAfter,
    label: '$prefix $day',
  );
}

/// 리듬 행(원천 있는 것만 · 날짜 순 · 같은 날 = 리밸런싱 먼저).
List<OpsRhythmRow> opsRhythmRowsOf({
  required ExchangeCalendar kr,
  required DateTime nowUtc,
}) {
  final String today = kstDateText(nowUtc);
  final List<(String, int, OpsRhythmRow)> rows =
      <(String, int, OpsRhythmRow)>[];
  final String? rebalance = nextRegularExecutionSession(kr, nowUtc);
  if (rebalance != null) {
    rows.add((
      rebalance,
      0,
      OpsRhythmRow(
        code: OpsRhythmCodes.monthlyRebalance,
        title: '월간 정기 리밸런싱',
        whenText: '매월 첫 거래일',
        dDayText: opsDDayText(today, rebalance),
        route: AppRoutes.rebalancePreview,
      ),
    ));
  }
  String? contribution;
  try {
    contribution = nextContributionDay(kr, today);
  } on StateError {
    contribution = null;
  }
  if (contribution != null) {
    rows.add((
      contribution,
      1,
      OpsRhythmRow(
        code: OpsRhythmCodes.monthlyContribution,
        title: '월 납입',
        whenText: '매월 첫 거래일',
        dDayText: opsDDayText(today, contribution),
        route: AppRoutes.planDeposit,
      ),
    ));
  }
  rows.sort((a, b) {
    final int c = a.$1.compareTo(b.$1);
    return c != 0 ? c : a.$2.compareTo(b.$2);
  });
  return <OpsRhythmRow>[for (final (_, _, OpsRhythmRow r) in rows) r];
}

/// `H-02` 운영 리듬 표.
ListResult<OpsRhythmRow> opsRhythmOf({
  required ExchangeCalendar kr,
  required DateTime nowUtc,
  required DateTime? lastActivityUtc,
}) {
  final List<OpsRhythmRow> rows = opsRhythmRowsOf(kr: kr, nowUtc: nowUtc);
  return ListResult<OpsRhythmRow>(
    rows: rows,
    asOf: opsHomeAsOf(
      lastActivityUtc: lastActivityUtc,
      nowUtc: nowUtc,
      prefix: '운영 리듬 기준',
    ),
    emptyKind: EmptyKind.noData,
    emptyLabel: rows.isEmpty ? kOpsRhythmEmptyLabel : null,
    hasMore: false,
  );
}

/// `H-01` 오늘 요약 — `upcoming` = 리듬 표 앞 ≤3(C-47 ⑤ · 같은 함수 · 같은 시각).
OpsDailySummary opsDailySummaryOf(
  OpsHomeFacts f, {
  required ExchangeCalendar kr,
  required DateTime nowUtc,
}) {
  final List<OpsRhythmRow> rhythm = opsRhythmRowsOf(kr: kr, nowUtc: nowUtc);
  final OpsRhythmRow? rebalance = rhythm
      .where((OpsRhythmRow r) => r.code == OpsRhythmCodes.monthlyRebalance)
      .firstOrNull;
  final bool auto = switch (f.operatingMode) {
    OperatingMode.autoTrade => true,
    OperatingMode.advisory => false,
  };
  return OpsDailySummary(
    asOf: opsHomeAsOf(
      lastActivityUtc: f.lastActivityUtc,
      nowUtc: nowUtc,
      prefix: '운영 홈 기준',
    ),
    todayOrdersText: auto
        ? '오늘 주문 ${f.ordersToday}건'
        : OpsHomePendingText.todayRecords,
    todayErrorsText: '오늘 오류 ${f.failedJobsToday}건',
    signalMatchText: auto
        ? OpsHomePendingText.signalMatch
        : OpsHomePendingText.adviceRecord,
    streakText: OpsHomePendingText.streak,
    discretionBudgetText: discretionBudgetText(f.discretion),
    nextRebalanceDDayText: rebalance?.dDayText ?? kOpsHomeNoRebalanceText,
    upcoming: rhythm.take(3).toList(),
    resumeLine: f.resumeLine,
  );
}
