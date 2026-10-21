// 다음 정기 리밸런싱 회차 — 월 마지막 KR 거래일 종가로 판정하고 다음 세션에 집행한다(03 §5-2 · 설계 13 §8 R18 D-9).
//
// 🔵 `previewRebalance(plannedDate: null)` 와 `watchNext`(M1-24 · `NextRebalanceVm`)가 **같은 판정**을 쓴다
//    (01 §15-4 ④) — 이 함수가 그 한 곳이다. 픽스처: as-of 2026-08-31(월말) → 판정 08-31 · 회차 09-01.
// 🔴 달력 범위 밖이면 null(«예정된 회차가 아직 없습니다» — 모르는 날을 지어내지 않는다).

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import 'exchange_calendar.dart';

/// 다음 정기 회차 — 판정일(월 마지막 세션)과 집행일(그다음 세션).
class NextRebalance {
  const NextRebalance(this.judgment, this.planned);
  final TradeDate judgment, planned;
}

/// [asOf] 이후(그날 포함) 첫 월 마지막 KR 세션과 그다음 세션. 범위 밖이면 null.
NextRebalance? nextRegularRebalance(ExchangeCalendar kr, TradeDate asOf) {
  try {
    // 세션이 아니면 isLastSessionOfMonth 가 false 라 다음 세션으로 넘어간다.
    TradeDate d = asOf;
    while (!kr.isLastSessionOfMonth(d)) {
      d = kr.nextSession(d);
    }
    return NextRebalance(d, kr.nextSession(d));
  } on StateError {
    return null;
  }
}
