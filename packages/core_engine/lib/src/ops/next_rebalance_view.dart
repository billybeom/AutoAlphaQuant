// 🆕 E11q1b — 다음 리밸런싱 회차 VM(설계 13 §8 R172 · 01 §4-1 m2-8 F-5 · 표본 `m7/m7_next_rebalance_countdown` · `_none`).
//
// 🔴 날짜 = 홈 · 운영 리듬과 같은 원천(`nextRegularExecutionSession` — 월말 판정 뒤 첫 KR 세션 · 09:10 주문 전이면 오늘) ·
//    D-day = 홈과 같은 셈(`opsDDayText`) — 화면이 날짜를 빼지 않는다.
// 🔴 미리보기 링크 = 조립 앱에 본문이 등록됐을 때만(S01 원칙 · 없는 화면으로 보내지 않는다).
// 🔴 달력 밖(다음 회차를 모름) = «예정 없음» 문장만(표본 `_none`).

import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, AsOf, AsOfSource, NextRebalanceVm, RebalanceKind, TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;
import '../calendar/next_rebalance.dart' show nextRegularExecutionSession;
import 'ledger_views.dart' show kstDateText;
import 'ops_home.dart' show kOpsHomeStaleAfter, opsDDayText;

/// 다음 리밸런싱 글자(표본 그대로).
abstract final class NextRebalanceTexts {
  /// 예정 없음.
  static const String none = '예정된 리밸런싱 회차가 아직 없습니다.';

  /// 월간 정기.
  static const String monthlyRegular = '월간 정기';

  /// 고지.
  static const String notice = '예정일은 거래일 달력으로 정해집니다.';

  /// «2026년 9월 1일».
  static String date(String yyyyMmDd) {
    final List<String> p = yyyyMmDd.split('-');
    return '${int.parse(p[0])}년 ${int.parse(p[1])}월 ${int.parse(p[2])}일';
  }
}

/// 다음 리밸런싱 회차 VM — [hasBody] = 조립 앱에 이 라우트의 본문이 있나.
NextRebalanceVm nextRebalanceVmOf({
  required ExchangeCalendar kr,
  required DateTime nowUtc,
  required bool Function(String route) hasBody,
}) {
  final String today = kstDateText(nowUtc);
  final AsOf asOf = AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(today),
    source: AsOfSource.localSqlite,
    staleAfter: kOpsHomeStaleAfter,
    label: '리밸런싱 예정 기준 $today',
  );
  final String? exec = nextRegularExecutionSession(kr, nowUtc);
  if (exec == null) {
    return NextRebalanceVm(emptyLabel: NextRebalanceTexts.none, asOf: asOf);
  }
  return NextRebalanceVm(
    expectedDateText: NextRebalanceTexts.date(exec),
    dDayText: opsDDayText(today, exec),
    expectedKind: RebalanceKind.monthlyRegular,
    kindLabel: NextRebalanceTexts.monthlyRegular,
    previewRoute: hasBody(AppRoutes.rebalancePreview)
        ? AppRoutes.rebalancePreview
        : null,
    noticeText: NextRebalanceTexts.notice,
    asOf: asOf,
  );
}
