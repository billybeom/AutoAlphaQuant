// 재개 항목 판정 · child 전제 · 집행 방향 · 모드별 자동 허용 · `RESUME_INCOMPLETE` 해제 · 계절 선택
// (06 X2-1 · X2-3 · X2-5 · X2-6 · 04 §3-1 v2.42 ②③ · 08M 그림 10-1~10-3 · 청사진 X2 보강 (a)(e) ·
// 설계 13 §8 R70 D1 · D2 · D9 · R72 J4~J7).
//
// 🔴 재판정에 전략 판단이 없다 — 계획기 · 계절 판정을 재개일 as-of 로 다시 돌린 결과(할 일 있음 · 없음)만
//    받는다(돌리는 일 = 실행기 E14d).
// 🔴 재개는 주문을 내지 않는다(«집행 위임») — `EXECUTED_AS_REEVALUATED` = child 를 다음 `kr_order` 회차에 넘김.
// 🔴 child 전제 = 대사 불일치 0 ∧ UNKNOWN 0 ∧ RESERVED · SUBMITTING 잔류 0(보강 (a) — 새 decision_id 가
//    멱등키를 바꾸므로 이 전제 없이는 이중 주문 방어선을 우회한다).
// 🔴 관찰 회차(RECOVERY_DRY)에는 재판정 행을 남기지 않는다 — 항목은 BLOCKED 로 다음 회차를 기다린다.

import 'package:domain_contracts/domain_contracts.dart'
    show
        PlannedWorkKindCodes,
        PlannedWorkState,
        ResumeMode,
        TradeDate,
        VerdictCodes;

import 'planned_work_machine.dart'
    show kPlannedWorkTerminal, plannedWorkPastDue;

/// 집행 방향 — 선언 차례 = 우선순위(차단 해소 → 방어 → 정기 리밸런싱 → 신규 진입 · X2-5).
enum ResumeDirection {
  /// 차단 해소.
  unblock,

  /// 방어 방향(청산 · 축소).
  defensive,

  /// 정기 리밸런싱.
  rebalance,

  /// 신규 진입.
  entry,
}

/// `planned_work.kind` P0S 판(R70 D6 · 문자열 — 계약 등재 = E14i).
abstract final class ResumeWorkKinds {
  /// 월말 계획.
  static const String monthlyPlan = 'MONTHLY_PLAN';

  /// 계절 판정 · 분할 날(계약 기존 값).
  static const String seasonalWindow = PlannedWorkKindCodes.seasonalWindow;

  /// 이월 의도.
  static const String carryOver = 'CARRY_OVER';
}

/// 항목 판정 사유 · 플래그 유지 사유(R72 J4 · J6 · J7 — 문구 = `resume_text.dart`).
abstract final class ResumeReasonCodes {
  /// 기한을 넘겼다.
  static const String duePassed = 'DUE_PASSED';

  /// 안내 모드 재개 조건 결정 대기(미결 19).
  static const String advisoryPending = 'ADVISORY_PENDING';

  /// RECOVERY_FULL — 매매 없는 안전 정지.
  static const String safetyStop = 'SAFETY_STOP';

  /// RECOVERY_DRY — 관찰 회차.
  static const String observing = 'OBSERVING';

  /// 대사 불일치가 남았다.
  static const String reconMismatch = 'RECON_MISMATCH_REMAINS';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'UNKNOWN_ORDERS_REMAIN';

  /// RESERVED · SUBMITTING 잔류.
  static const String residualOrders = 'RESIDUAL_ORDERS_REMAIN';

  /// 계절 A 진입 — 사람 결정 대기.
  static const String humanDecision = 'HUMAN_DECISION';

  /// 보수 모드 — 다음 정기 회차.
  static const String conservativeDefer = 'CONSERVATIVE_DEFER';

  /// 재판정 결과 할 일 없음.
  static const String reevaluatedEmpty = 'REEVALUATED_EMPTY';

  /// 재판정 값으로 다음 주문 회차에 위임.
  static const String reevaluated = 'REEVALUATED';

  /// 사람이 건너뜀.
  static const String humanSkip = 'HUMAN_SKIP';

  /// 사람이 축소 진입을 고름.
  static const String humanReduced = 'HUMAN_REDUCED';

  /// 사람이 그대로를 고름.
  static const String humanAsIs = 'HUMAN_AS_IS';
}

/// 계절 선택 거부 코드(R72 J6).
abstract final class SeasonalChoiceCodes {
  /// `decision_id` 없음.
  static const String decisionMissing = 'SEASONAL_DECISION_MISSING';

  /// 계절 A 진입 항목이 아님.
  static const String notSeasonalEntry = 'SEASONAL_NOT_ENTRY';

  /// 사람 결정을 기다리는 상태가 아님(종단 등).
  static const String notPending = 'SEASONAL_NOT_PENDING';

  /// 기한을 넘겼다(1월 판정 날 자동 만료).
  static const String pastDue = 'SEASONAL_PAST_DUE';
}

/// child 전제 — R3 · R4 결과(보강 (a)).
class ResumePreconditions {
  /// 전제를 만든다 — 음수 = [ArgumentError].
  ResumePreconditions({
    required this.reconMismatches,
    required this.unknownOrders,
    required this.residualOrders,
  }) {
    if (reconMismatches < 0 || unknownOrders < 0 || residualOrders < 0) {
      throw ArgumentError('전제 건수는 음수일 수 없다');
    }
  }

  /// 대사 불일치 건수.
  final int reconMismatches;

  /// UNKNOWN 주문 건수.
  final int unknownOrders;

  /// RESERVED · SUBMITTING 잔류 건수.
  final int residualOrders;

  /// 첫 실패 사유 — null = 성립.
  String? get failureCode {
    if (reconMismatches > 0) return ResumeReasonCodes.reconMismatch;
    if (unknownOrders > 0) return ResumeReasonCodes.unknownOrders;
    if (residualOrders > 0) return ResumeReasonCodes.residualOrders;
    return null;
  }
}

/// 재개가 다루는 `planned_work` 1행.
class ResumeWorkItem {
  /// 항목을 만든다.
  const ResumeWorkItem({
    required this.workId,
    required this.kind,
    required this.oneLine,
    required this.state,
    required this.plannedOn,
    required this.dueBy,
    required this.direction,
    required this.sell,
  });

  /// `planned_work.work_id`.
  final String workId;

  /// `planned_work.kind`.
  final String kind;

  /// 엔진 한 줄(`planned_work.one_line`).
  final String oneLine;

  /// 지금 상태.
  final PlannedWorkState state;

  /// 계획한 날.
  final TradeDate plannedOn;

  /// 낼 수 있는 마지막 세션(포함).
  final TradeDate dueBy;

  /// 집행 방향.
  final ResumeDirection direction;

  /// 매도인가(같은 방향 안에서 매도 먼저).
  final bool sell;

  /// 계절 A 진입인가 — 사람 결정 대상(D2).
  bool get seasonalEntry =>
      kind == ResumeWorkKinds.seasonalWindow &&
      direction == ResumeDirection.entry;
}

/// 항목 판정 결과.
class ResumeItemJudgement {
  /// 결과를 만든다.
  const ResumeItemJudgement({
    required this.nextState,
    required this.verdictCode,
    required this.reasonCode,
  });

  /// 다음 상태(지금과 같으면 전이 기록 0).
  final PlannedWorkState nextState;

  /// `VerdictCodes` 5종 가운데 하나.
  final String verdictCode;

  /// [ResumeReasonCodes].
  final String reasonCode;

  /// child 를 만드나(= 다음 주문 회차 위임).
  bool get delegates => verdictCode == VerdictCodes.executedAsReevaluated;
}

/// 항목 판정 한 걸음.
sealed class ResumeItemStep {
  const ResumeItemStep();
}

/// 종단 — 재개가 건드리지 않는다.
final class ResumeItemUntouched extends ResumeItemStep {
  /// 만든다.
  const ResumeItemUntouched();
}

/// 판정 끝(재판정 불필요).
final class ResumeItemDecided extends ResumeItemStep {
  /// 만든다.
  const ResumeItemDecided(this.judgement);

  /// 결과.
  final ResumeItemJudgement judgement;
}

/// 재판정이 필요하다 — 실행기가 계획기 · 판정을 재개일 as-of 로 돌린 뒤 [reevaluatedJudgement].
final class ResumeItemNeedsReevaluation extends ResumeItemStep {
  /// 만든다.
  const ResumeItemNeedsReevaluation();
}

/// 모드별 자동 허용(그림 10-3) — NORMAL 전부 · CONSERVATIVE 차단 해소 · 방어 · RECOVERY_DRY · FULL 없음.
bool resumeAutoAllows(ResumeMode mode, ResumeDirection direction) =>
    switch (mode) {
      ResumeMode.normal => true,
      ResumeMode.conservative =>
        direction == ResumeDirection.unblock ||
            direction == ResumeDirection.defensive,
      ResumeMode.recoveryDry || ResumeMode.recoveryFull => false,
    };

/// 매매를 멈춰 둘 사유 — null = 없음(차례 = 안내 → 안전 정지 → 관찰 → 전제).
String? resumeHaltReason({
  required ResumeMode mode,
  required bool advisory,
  required ResumePreconditions preconditions,
}) {
  if (advisory) return ResumeReasonCodes.advisoryPending;
  if (mode == ResumeMode.recoveryFull) return ResumeReasonCodes.safetyStop;
  if (mode == ResumeMode.recoveryDry) return ResumeReasonCodes.observing;
  return preconditions.failureCode;
}

/// `RESUME_INCOMPLETE` 를 푸나(v2.42 ② · R72 J7) — 멈출 사유가 없을 때만.
bool resumeReleasesFlag({
  required ResumeMode mode,
  required bool advisory,
  required ResumePreconditions preconditions,
}) =>
    resumeHaltReason(
      mode: mode,
      advisory: advisory,
      preconditions: preconditions,
    ) ==
    null;

/// 항목 판정(R72 J4 ①~⑦ — ⑧ 은 [reevaluatedJudgement]).
ResumeItemStep judgeResumeItem({
  required ResumeWorkItem item,
  required TradeDate today,
  required ResumeMode mode,
  required bool advisory,
  required ResumePreconditions preconditions,
}) {
  if (kPlannedWorkTerminal.contains(item.state)) {
    return const ResumeItemUntouched();
  }
  if (plannedWorkPastDue(dueBy: item.dueBy, today: today)) {
    return const ResumeItemDecided(
      ResumeItemJudgement(
        nextState: PlannedWorkState.expired,
        verdictCode: VerdictCodes.expired,
        reasonCode: ResumeReasonCodes.duePassed,
      ),
    );
  }
  final String? halt = resumeHaltReason(
    mode: mode,
    advisory: advisory,
    preconditions: preconditions,
  );
  if (halt != null) return ResumeItemDecided(_blocked(halt));
  if (item.seasonalEntry) {
    return ResumeItemDecided(_blocked(ResumeReasonCodes.humanDecision));
  }
  if (!resumeAutoAllows(mode, item.direction)) {
    return const ResumeItemDecided(
      ResumeItemJudgement(
        nextState: PlannedWorkState.superseded,
        verdictCode: VerdictCodes.superseded,
        reasonCode: ResumeReasonCodes.conservativeDefer,
      ),
    );
  }
  return const ResumeItemNeedsReevaluation();
}

/// 재판정 뒤(R72 J4 ⑧) — 할 일 있음 = child 위임 · 없음 = 대체.
ResumeItemJudgement reevaluatedJudgement({required bool actionNeeded}) =>
    actionNeeded
    ? const ResumeItemJudgement(
        nextState: PlannedWorkState.reevaluated,
        verdictCode: VerdictCodes.executedAsReevaluated,
        reasonCode: ResumeReasonCodes.reevaluated,
      )
    : const ResumeItemJudgement(
        nextState: PlannedWorkState.reevaluated,
        verdictCode: VerdictCodes.superseded,
        reasonCode: ResumeReasonCodes.reevaluatedEmpty,
      );

ResumeItemJudgement _blocked(String reason) => ResumeItemJudgement(
  nextState: PlannedWorkState.blocked,
  verdictCode: VerdictCodes.blocked,
  reasonCode: reason,
);

/// 집행 차례(X2-5) — 방향 → 매도 먼저 → `work_id`.
List<ResumeWorkItem> resumePriorityOrder(Iterable<ResumeWorkItem> items) {
  final List<ResumeWorkItem> out = items.toList();
  out.sort((ResumeWorkItem a, ResumeWorkItem b) {
    final int d = a.direction.index.compareTo(b.direction.index);
    if (d != 0) return d;
    if (a.sell != b.sell) return a.sell ? -1 : 1;
    return a.workId.compareTo(b.workId);
  });
  return out;
}

/// 계절 창 선택 3택(D2 · «아무것도 안 하기» = 고르지 않고 1월 만료).
enum SeasonalWindowChoice {
  /// 건너뛰기.
  skip,

  /// 축소 진입(비율 = E14d · 계약 창).
  reduced,

  /// 그대로.
  asIs,
}

/// 계절 선택 거부 코드 — null = 허용.
///
/// 건너뛰기는 멈출 사유가 있어도 받는다(아무것도 내지 않으므로). 축소 · 그대로는 멈출 사유가 없을 때만 —
/// 있으면 그 사유 코드([ResumeReasonCodes])를 그대로 돌려준다.
String? seasonalChoiceRejectCode({
  required ResumeWorkItem item,
  required SeasonalWindowChoice choice,
  required String decisionId,
  required TradeDate today,
  required ResumeMode mode,
  required bool advisory,
  required ResumePreconditions preconditions,
}) {
  if (decisionId.trim().isEmpty) return SeasonalChoiceCodes.decisionMissing;
  if (!item.seasonalEntry) return SeasonalChoiceCodes.notSeasonalEntry;
  if (kPlannedWorkTerminal.contains(item.state)) {
    return SeasonalChoiceCodes.notPending;
  }
  if (plannedWorkPastDue(dueBy: item.dueBy, today: today)) {
    return SeasonalChoiceCodes.pastDue;
  }
  if (choice == SeasonalWindowChoice.skip) return null;
  return resumeHaltReason(
    mode: mode,
    advisory: advisory,
    preconditions: preconditions,
  );
}

/// 계절 선택의 결과(R72 J6).
ResumeItemJudgement seasonalChoiceJudgement(SeasonalWindowChoice choice) =>
    switch (choice) {
      SeasonalWindowChoice.skip => const ResumeItemJudgement(
        nextState: PlannedWorkState.superseded,
        verdictCode: VerdictCodes.superseded,
        reasonCode: ResumeReasonCodes.humanSkip,
      ),
      SeasonalWindowChoice.reduced => const ResumeItemJudgement(
        nextState: PlannedWorkState.reevaluated,
        verdictCode: VerdictCodes.executedAsReevaluated,
        reasonCode: ResumeReasonCodes.humanReduced,
      ),
      SeasonalWindowChoice.asIs => const ResumeItemJudgement(
        nextState: PlannedWorkState.reevaluated,
        verdictCode: VerdictCodes.executedAsReevaluated,
        reasonCode: ResumeReasonCodes.humanAsIs,
      ),
    };
