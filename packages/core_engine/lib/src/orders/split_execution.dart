// 계절 분할 집행 — `06_시스템설계/03_알고리즘.md` §5-3-1 v2.10 · v2.38 블록 · 05 GV-30(AC-B23) · 06 M1-9b.
//
// 🔴 집행일 = 그 달 마지막 KR 거래일(anchor)을 **포함해** 거꾸로 N 세션(오름차순). anchor 다음으로 넘기면
//    시즌 경계를 넘는다(05 GV-30) — 그래서 anchor 가 월 마지막 세션이 아니거나 N 세션이 달을 넘으면 거절한다.
// 🔴 v2.38(설계 13 §8 R33 D8 — 정답지 그대로): 중간 날 = `ceil(계획 잔량 ÷ 남은 일수)` · 계획 잔량 = 목표 − 앞날
//    **계획** 합(미체결분은 더하지 않는다) · 마지막 날 = 목표 − **누적 체결**(이월분이 여기서 모인다) · 시장가(D7).
//    GV-30 e4: 10 → 4(체결 2) → 3(체결 0) → 10 − 2 = 8.
// 🔴 0주 날은 주문을 내지 않는다(e3 — SAF-104). 그날의 판정은 호출자가 [SplitDay.quantity] 로 본다.
// 🔵 놓친 날(D27 — 15:00 까지 못 냄) · 일 마감 실효 · 이월 기록은 E10e 몫이다. 이 파일은 값만 낸다(부작용 0).

import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/exchange_calendar.dart';

/// anchor(그 달 마지막 KR 세션)를 포함해 거꾸로 [days] 세션 — 오름차순.
///
/// anchor 가 월 마지막 세션이 아니면 [ArgumentError] · 집행일이 anchor 의 달을 벗어나면 [StateError]
/// (시즌 경계 — 05 GV-30) · 달력 범위 밖이면 달력의 [StateError].
List<TradeDate> seasonalExecutionDays(
  ExchangeCalendar kr,
  TradeDate anchor,
  int days,
) {
  if (days < 1) throw ArgumentError.value(days, 'days', '1 이상이어야 한다');
  if (!kr.isLastSessionOfMonth(anchor)) {
    throw ArgumentError.value(anchor, 'anchor', '그 달 마지막 세션이 아니다');
  }
  final List<TradeDate> out = <TradeDate>[
    for (int back = days - 1; back >= 1; back--)
      kr.nthSessionBefore(anchor, back),
    anchor,
  ];
  final String month = anchor.yyyyMmDd.substring(0, 7);
  if (out.first.yyyyMmDd.substring(0, 7) != month) {
    throw StateError('분할 집행일이 $month 를 벗어난다: ${out.first}');
  }
  return out;
}

/// 분할 집행의 하루 몫.
class SplitDay {
  /// 하루 몫을 만든다.
  const SplitDay(this.quantity, {required this.marketOrder});

  /// 그날 낼 수량(0 이면 내지 않는다 — SAF-104).
  final int quantity;

  /// 마지막 날 = 시장가(03 §5-3-1 v2.38 · R33 D7) · 그 밖 = 지정가.
  final bool marketOrder;
}

/// [dayIndex](0부터)번째 집행일의 몫 — 03 §5-3-1 v2.38 표.
///
/// [plannedBefore] = 앞날에 **계획한** 수량 합 · [filledBefore] = 앞날에 **체결된** 수량 합.
/// 값이 앞뒤가 안 맞으면(음수 · 체결 > 계획 · 계획 > 목표) [ArgumentError].
SplitDay splitDay({
  required int target,
  required int days,
  required int dayIndex,
  required int plannedBefore,
  required int filledBefore,
}) {
  if (target < 0) throw ArgumentError.value(target, 'target', '음수다');
  if (days < 1) throw ArgumentError.value(days, 'days', '1 이상이어야 한다');
  if (dayIndex < 0 || dayIndex >= days) {
    throw ArgumentError.value(dayIndex, 'dayIndex', '0 ~ ${days - 1} 밖이다');
  }
  if (plannedBefore < 0 || plannedBefore > target) {
    throw ArgumentError.value(
      plannedBefore,
      'plannedBefore',
      '0 ~ $target 밖이다',
    );
  }
  if (filledBefore < 0 || filledBefore > plannedBefore) {
    throw ArgumentError.value(
      filledBefore,
      'filledBefore',
      '0 ~ $plannedBefore(앞날 계획 합) 밖이다',
    );
  }
  if (dayIndex == 0 && plannedBefore != 0) {
    throw ArgumentError.value(plannedBefore, 'plannedBefore', '첫날인데 0 이 아니다');
  }
  if (dayIndex == days - 1) {
    // 🔴 마지막 날은 전량 강제 — 목표 − 누적 체결(이월분이 여기서 모인다).
    return SplitDay(target - filledBefore, marketOrder: true);
  }
  final int remaining = target - plannedBefore;
  final int daysLeft = days - dayIndex;
  // 🔴 ceil — floor 면 e2 가 [2,2,3] 으로 틀린다(05 GV-30).
  return SplitDay((remaining + daysLeft - 1) ~/ daysLeft, marketOrder: false);
}
