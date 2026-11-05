// STOPPED 결정 A/B/C 판정(SPEC v2.40 04 §2 «결정 B 집행 · 전제» · 03_운영 §6-4b ①~⑥ · 설계 13 §8 R61 T2 · T5).
//
// 🔴 허용되는 결정은 셋뿐이다 — «기존 규칙으로 그대로 재개»는 없다(03_운영 §6-4b ④).
// 🔴 20거래일 전에는 어떤 결정도 받지 않는다(②) · 한 에피소드에 결정 하나(④ «셋 중 하나만»).
// 🔴 B(재가동)만 v2.29 재개 자격이 필요하다 — A(전량 방어 이전) · C(청산)는 재가동이 아니라 엔진이 STOPPED 를 유지한다.

import '../ops/equity_snapshot.dart' show BreakerReplay, p0sBreakerConfig;
import '../risk/breaker.dart';

/// 결정 셋(03_운영 §6-4b ④).
enum StoppedDecisionKind {
  /// A — 전량 방어 슬리브 이전(재가동 안 함 · 엔진 STOPPED 유지).
  a('A'),

  /// B — CANDIDATE 부터 재램프(재가동 · STOPPED → HALTED).
  b('B'),

  /// C — 청산 · 프로젝트 종료(엔진 STOPPED 유지).
  c('C');

  const StoppedDecisionKind(this.code);

  /// 기록 표기.
  final String code;
}

/// 거부 코드(R61 T2 · 차례 = 이 선언 차례).
abstract final class StoppedDecisionCodes {
  /// 지금 STOPPED 가 아니다.
  static const String notActive = 'STOPPED_NOT_ACTIVE';

  /// 20거래일이 아직이다.
  static const String wait20d = 'STOPPED_WAIT_20D';

  /// 이 에피소드에 결정이 이미 있다.
  static const String alreadyMade = 'DECISION_ALREADY_MADE';

  /// SEV1 postmortem 이 비었다.
  static const String postmortemMissing = 'POSTMORTEM_MISSING';

  /// 가족 합의 선언이 없다.
  static const String familyAgreementMissing = 'FAMILY_AGREEMENT_MISSING';

  /// 저널(`decision_id` · 사전 필드 3)이 비었다.
  static const String journalRequired = 'JOURNAL_REQUIRED';

  /// B 인데 재개 자격이 없다.
  static const String notEligible = 'STOPPED_NOT_ELIGIBLE';
}

/// 사람이 낸 결정.
class StoppedDecisionAnswers {
  /// 결정을 만든다.
  const StoppedDecisionAnswers({
    required this.kind,
    required this.decisionId,
    required this.rationaleBefore,
    required this.expectedOutcome,
    required this.ruleCited,
    required this.familyAgreement,
  });

  /// 결정.
  final StoppedDecisionKind kind;

  /// 저널 id(`decision_journal.journal_id`).
  final String decisionId;

  /// 사전 필드 3.
  final String rationaleBefore, expectedOutcome, ruleCited;

  /// 🔴 가족 합의서 당사자가 참석했다는 사람 선언(③ · 엔진은 확인할 길이 없어 선언만 받는다).
  final bool familyAgreement;
}

/// 판정.
class StoppedDecisionVerdict {
  /// 통과.
  const StoppedDecisionVerdict.allowed(StoppedDecisionKind this.kind)
    : code = null;

  /// 거부.
  const StoppedDecisionVerdict.rejected(String this.code) : kind = null;

  /// 통과한 결정(거부 = null).
  final StoppedDecisionKind? kind;

  /// 거부 코드(통과 = null).
  final String? code;

  /// 통과했나.
  bool get allowed => code == null;

  /// 🔴 재개 행(STOPPED → HALTED)을 쓰는가 — 통과한 B 만.
  bool get releases => kind == StoppedDecisionKind.b;
}

bool _blank(String s) => s.trim().isEmpty;

/// STOPPED 결정 판정(R61 T2) — [replay] = 저장된 역사를 지금 다시 재생한 결과.
StoppedDecisionVerdict judgeStoppedDecision(
  StoppedDecisionAnswers a, {
  required BreakerReplay replay,
  required bool decisionAlreadyMade,
  required bool postmortemRecorded,
  BreakerConfig? config,
}) {
  final BreakerConfig cfg = config ?? p0sBreakerConfig();
  if (replay.state.level != BreakerLevel.stopped) {
    return const StoppedDecisionVerdict.rejected(
      StoppedDecisionCodes.notActive,
    );
  }
  if (replay.heldBars < cfg.recoverHoldBars) {
    return const StoppedDecisionVerdict.rejected(StoppedDecisionCodes.wait20d);
  }
  if (decisionAlreadyMade) {
    return const StoppedDecisionVerdict.rejected(
      StoppedDecisionCodes.alreadyMade,
    );
  }
  if (!postmortemRecorded) {
    return const StoppedDecisionVerdict.rejected(
      StoppedDecisionCodes.postmortemMissing,
    );
  }
  if (!a.familyAgreement) {
    return const StoppedDecisionVerdict.rejected(
      StoppedDecisionCodes.familyAgreementMissing,
    );
  }
  if (_blank(a.decisionId) ||
      _blank(a.rationaleBefore) ||
      _blank(a.expectedOutcome) ||
      _blank(a.ruleCited)) {
    return const StoppedDecisionVerdict.rejected(
      StoppedDecisionCodes.journalRequired,
    );
  }
  if (a.kind == StoppedDecisionKind.b && !replay.stoppedReleaseEligible) {
    return const StoppedDecisionVerdict.rejected(
      StoppedDecisionCodes.notEligible,
    );
  }
  return StoppedDecisionVerdict.allowed(a.kind);
}
