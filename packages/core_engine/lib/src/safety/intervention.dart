// 수동 개입 5단계 상태기계(M5-6 · 06 · 02 §2 `intervention_step` v2.40 · 설계 13 §8 R65).
//
// 단계 = 1 규칙 대비 표시 → 2 카드 → 3 저널 사전 작성 → 4 냉각 → 5 실행 — 🔴 차례대로 한 번씩.
// 🔴 «아무것도 안 하기» · 중단 = 어느 단계에서든 요건 0 으로 세션을 닫는다(나아가기보다 쉽다).
// 🔴 발주자 결정(2026-11-05 · 마찰 규칙): 살아 있는 세션은 한 번에 하나 · 실행 창 = 냉각 끝 + 24h
//    (지나면 만료 — 실행 거부 · 닫기만 된다 · 만료 세션은 새 세션을 막지 않는다).
// 🔴 시각 = 신뢰 시각 · 모르면 어떤 단계도 쓰지 않는다(지도 D23).

/// 4단계 냉각(02 §4 `operations.intervention.cooling_hours: 24` · 지도 D6).
const Duration kInterventionCooling = Duration(hours: 24);

/// 실행 창 — 냉각 끝부터(발주자 결정 2026-11-05 · R65).
const Duration kInterventionExecuteWindow = Duration(hours: 24);

/// 단계 수.
const int kInterventionStages = 5;

/// 3단계(저널 사전 작성) · 4단계(냉각) · 5단계(실행).
const int kJournalStage = 3, kCoolingStage = 4, kExecuteStage = 5;

/// 단계 결과(02 §2 CHECK).
enum InterventionOutcome {
  /// 다음 단계로.
  passed('PASSED'),

  /// «아무것도 안 하기».
  doNothing('DO_NOTHING'),

  /// 중단.
  abandoned('ABANDONED');

  const InterventionOutcome(this.wire);

  /// 저장 값.
  final String wire;

  /// 저장 값에서 — 모르는 값 = 형식 오류(지어내지 않는다).
  static InterventionOutcome fromWire(String wire) {
    for (final InterventionOutcome o in values) {
      if (o.wire == wire) return o;
    }
    throw FormatException('모르는 개입 결과', wire);
  }
}

/// 개입 거부 코드(R65).
abstract final class InterventionCodes {
  /// 이미 닫힌 세션.
  static const String closed = 'INTERVENTION_CLOSED';

  /// 냉각 중.
  static const String cooling = 'INTERVENTION_COOLING';

  /// 실행 창이 지났다.
  static const String expired = 'INTERVENTION_EXPIRED';

  /// 저널 미연결.
  static const String journalMissing = 'INTERVENTION_JOURNAL_MISSING';

  /// 차례가 아닌 단계(건너뛰기 · 되풀이).
  static const String outOfOrder = 'INTERVENTION_STAGE_OUT_OF_ORDER';

  /// 다른 세션이 살아 있다.
  static const String sessionOpen = 'INTERVENTION_SESSION_OPEN';

  /// 신뢰 시각 모름(E11j 코드 재사용).
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';
}

/// `intervention_step` 한 행.
class InterventionStep {
  /// 행을 만든다.
  const InterventionStep({
    required this.stage,
    required this.occurredAtUtc,
    required this.outcome,
    this.decisionId,
  });

  /// 단계(1~5).
  final int stage;

  /// 신뢰 시각.
  final DateTime occurredAtUtc;

  /// 결과.
  final InterventionOutcome outcome;

  /// 결정 id(3 · 5단계 통과 = 필수).
  final String? decisionId;
}

/// 세션 상태(저장 행에서 다시 만든다 — 따로 저장하지 않는다).
class InterventionState {
  const InterventionState._({
    required this.sessionId,
    required this.steps,
    required this.closedOutcome,
    required this.coolingEndsAtUtc,
    required this.journalId,
  });

  /// 세션 id.
  final String sessionId;

  /// 단계 행(차례대로).
  final List<InterventionStep> steps;

  /// 닫은 결과(null = 열림) — 5단계 통과면 `passed`.
  final InterventionOutcome? closedOutcome;

  /// 냉각 끝(3단계 통과 시각 + 냉각) — 3단계 전 = null.
  final DateTime? coolingEndsAtUtc;

  /// 3단계 저널 id.
  final String? journalId;

  /// 닫혔나.
  bool get closed => closedOutcome != null;

  /// 다음 단계(닫힘 = null).
  int? get nextStage => closed ? null : steps.length + 1;

  /// 실행 창 끝(냉각 끝 + 24h).
  DateTime? get executeWindowEndsAtUtc =>
      coolingEndsAtUtc?.add(kInterventionExecuteWindow);

  /// 만료됐나 — 열림 ∧ 실행 창 끝 ≤ 지금.
  bool expiredAt(DateTime nowUtc) {
    final DateTime? end = executeWindowEndsAtUtc;
    return !closed && end != null && !nowUtc.isBefore(end);
  }

  /// 살아 있나 — 열림 ∧ 만료 아님.
  bool liveAt(DateTime nowUtc) => !closed && !expiredAt(nowUtc);
}

/// 저장 행에서 세션 상태 — 행 없음 = null · 🔴 차례가 끊긴 행 = 오류(원장이 깨졌다).
InterventionState? interventionStateOf(
  String sessionId,
  Iterable<InterventionStep> rows,
) {
  final List<InterventionStep> steps = rows.toList()
    ..sort((InterventionStep a, InterventionStep b) => a.stage - b.stage);
  if (steps.isEmpty) return null;
  InterventionOutcome? closedOutcome;
  for (int i = 0; i < steps.length; i++) {
    if (steps[i].stage != i + 1 || closedOutcome != null) {
      throw StateError('개입 세션 $sessionId 의 단계 행이 차례대로가 아니다');
    }
    final InterventionStep s = steps[i];
    if (s.outcome != InterventionOutcome.passed) {
      closedOutcome = s.outcome;
    } else if (s.stage == kExecuteStage) {
      closedOutcome = InterventionOutcome.passed;
    }
  }
  final InterventionStep? journal = steps.length >= kJournalStage
      ? steps[kJournalStage - 1]
      : null;
  final bool journalPassed =
      journal != null && journal.outcome == InterventionOutcome.passed;
  return InterventionState._(
    sessionId: sessionId,
    steps: List<InterventionStep>.unmodifiable(steps),
    closedOutcome: closedOutcome,
    coolingEndsAtUtc: journalPassed
        ? journal.occurredAtUtc.add(kInterventionCooling)
        : null,
    journalId: journalPassed ? journal.decisionId : null,
  );
}

/// 3단계 저널의 사실(R65 X3).
class InterventionJournalFacts {
  /// 사실을 만든다.
  const InterventionJournalFacts({
    required this.isDeviation,
    required this.rationaleBefore,
    required this.expectedOutcome,
    required this.ruleCited,
    required this.note,
    required this.alreadyUsed,
  });

  /// `decision_journal.is_deviation` = 1.
  final bool isDeviation;

  /// 사전 3필드 · 메모.
  final String? rationaleBefore, expectedOutcome, ruleCited, note;

  /// 다른 세션이 이미 이 저널로 3단계를 통과했나.
  final bool alreadyUsed;
}

bool _filled(String? v) => v != null && v.trim().isNotEmpty;

/// 🔴 3단계 저널 연결 — 이탈 저널 ∧ 사전 3필드 ∧ 저널 하나 = 세션 하나 · 예산 소진 = + 메모(정식 4필드 · G-24 ①).
bool interventionJournalLinked(
  InterventionJournalFacts? j, {
  required bool budgetExhausted,
}) =>
    j != null &&
    j.isDeviation &&
    _filled(j.rationaleBefore) &&
    _filled(j.expectedOutcome) &&
    _filled(j.ruleCited) &&
    (!budgetExhausted || _filled(j.note)) &&
    !j.alreadyUsed;

/// 한 단계 쓰기 판정(R65 X1~X6) — 통과 = null.
///
/// `session` = 이 세션의 상태(행 없음 = null) · `otherLiveSession` = 다른 세션이 살아 있나 ·
/// `journalLinked` = 3단계 통과일 때만 본다.
String? interventionRejectCode({
  required InterventionState? session,
  required bool otherLiveSession,
  required int stage,
  required InterventionOutcome outcome,
  required DateTime? nowUtc,
  required bool journalLinked,
  required String? decisionId,
}) {
  if (nowUtc == null) return InterventionCodes.trustedTimeUnknown;
  if (session != null && session.closed) return InterventionCodes.closed;
  if (stage != (session?.nextStage ?? 1)) return InterventionCodes.outOfOrder;
  if (stage == 1 && otherLiveSession) return InterventionCodes.sessionOpen;
  // 🔴 «아무것도 안 하기» · 중단 = 요건 0.
  if (outcome != InterventionOutcome.passed) return null;
  if (session != null && session.expiredAt(nowUtc)) {
    return InterventionCodes.expired;
  }
  switch (stage) {
    case kJournalStage:
      return journalLinked ? null : InterventionCodes.journalMissing;
    case kCoolingStage:
      return nowUtc.isBefore(session!.coolingEndsAtUtc!)
          ? InterventionCodes.cooling
          : null;
    case kExecuteStage:
      return decisionId != null && decisionId == session!.journalId
          ? null
          : InterventionCodes.journalMissing;
  }
  return null;
}

/// X7 입력 ⓐⓑ(E18)의 문지기 — 4단계 통과 ∧ 5단계 전 ∧ 만료 전 ∧ 신뢰 시각 앎.
bool interventionExecutable(InterventionState? s, DateTime? nowUtc) =>
    s != null &&
    nowUtc != null &&
    s.nextStage == kExecuteStage &&
    !s.expiredAt(nowUtc);
