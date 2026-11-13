// `planned_work` 상태기계(06 X2-3 · 08M 그림 10-2 · 청사진 X2 원칙 3 ① · 01 §2-7 · 설계 13 §8 R72 J3).
//
// 🔴 기한(`due_by`)을 넘긴 계획은 코드 경로상 DONE 으로 갈 수 없다 — 갈 곳은 EXPIRED 하나뿐이다.
// 🔴 종단(REEVALUATED · SUPERSEDED · EXPIRED · DONE)은 어떤 경로로도 되살아나지 않는다.
// 🔴 `due_by` = 그 계획을 낼 수 있는 **마지막 세션(포함)** — 등록 값은 E14c.
// 🔴 재판정 child 는 새 행(PLANNED)이다 — 원행은 REEVALUATED 에서 멈춘다.

import 'package:domain_contracts/domain_contracts.dart'
    show PlannedWorkState, TradeDate;

/// 종단 상태.
const Set<PlannedWorkState> kPlannedWorkTerminal = <PlannedWorkState>{
  PlannedWorkState.reevaluated,
  PlannedWorkState.superseded,
  PlannedWorkState.expired,
  PlannedWorkState.done,
};

/// 전이 거부 코드(R72 J3 · 계약 등재 = E14i).
abstract final class PlannedWorkCodes {
  /// 같은 상태로 — 전이가 아니다(전이 기록 0).
  static const String unchanged = 'PLANNED_WORK_UNCHANGED';

  /// 종단에서 나가려 함.
  static const String terminal = 'PLANNED_WORK_TERMINAL';

  /// 기한을 넘겼는데 EXPIRED 가 아닌 곳으로.
  static const String pastDue = 'PLANNED_WORK_PAST_DUE';

  /// 기한 전인데 EXPIRED 로.
  static const String notDue = 'PLANNED_WORK_NOT_DUE';

  /// 표에 없는 전이(PLANNED 로 되돌리기 · BLOCKED → DONE).
  static const String illegal = 'PLANNED_WORK_ILLEGAL';

  /// 🆕 E14c2 — 그런 행이 없다(R74 M3).
  static const String unknown = 'PLANNED_WORK_UNKNOWN';
}

/// 기한을 넘겼나 — 오늘 > `due_by`(같은 날은 아직 유효).
bool plannedWorkPastDue({required TradeDate dueBy, required TradeDate today}) =>
    today.yyyyMmDd.compareTo(dueBy.yyyyMmDd) > 0;

/// 전이 거부 코드 — null = 허용.
///
/// PLANNED → REEVALUATED · SUPERSEDED · EXPIRED · BLOCKED · DONE / BLOCKED → REEVALUATED · SUPERSEDED · EXPIRED.
/// 기한을 넘겼으면 EXPIRED 만 · 기한 전이면 EXPIRED 불가 · DONE = PLANNED 에서만.
String? plannedWorkTransitionRejectCode({
  required PlannedWorkState from,
  required PlannedWorkState to,
  required TradeDate dueBy,
  required TradeDate today,
}) {
  if (from == to) return PlannedWorkCodes.unchanged;
  if (kPlannedWorkTerminal.contains(from)) return PlannedWorkCodes.terminal;
  if (to == PlannedWorkState.planned) return PlannedWorkCodes.illegal;
  final bool past = plannedWorkPastDue(dueBy: dueBy, today: today);
  if (past) {
    return to == PlannedWorkState.expired ? null : PlannedWorkCodes.pastDue;
  }
  if (to == PlannedWorkState.expired) return PlannedWorkCodes.notDue;
  if (to == PlannedWorkState.done && from != PlannedWorkState.planned) {
    return PlannedWorkCodes.illegal;
  }
  return null;
}
