// 재개 문장 — 모드 이름 · `modeLabel` · `headline` · verdict 라벨 · 계획 · 재판정 한 줄 · 홈 «X2 한 줄»
// (06 X2-6 · 01 §2-7 `ResumeReport` · 04M8 §4-2 · 청사진 X2 «화면» · 설계 13 §8 R72 J8).
//
// 🔴 손익 숫자 0(결정 8) · «램프» 낱말 0(M2-3 · X2-6 검사) · 화면은 조립하지 않는다(완성 문장).
// 🔴 재개는 주문을 내지 않는다 — «실행»이라 쓰지 않고 «집행 예정» · «다음 주문 회차»라 쓴다.

import 'package:domain_contracts/domain_contracts.dart'
    show ResumeCounts, ResumeItem, ResumeMode, TradeDate, VerdictCodes;

import 'resume_judge.dart'
    show ResumeItemJudgement, ResumeReasonCodes, ResumeWorkItem;

/// 모드 이름(사용자 말).
String resumeModeName(ResumeMode mode) => switch (mode) {
  ResumeMode.normal => '평상',
  ResumeMode.conservative => '보수',
  ResumeMode.recoveryDry => '복구 관찰',
  ResumeMode.recoveryFull => '안전 정지',
};

/// `ResumeReport.modeLabel` — «{n}거래일 미실행 — {이름}».
String resumeModeLabel({required int gapSessions, required ResumeMode mode}) =>
    '$gapSessions거래일 미실행 — ${resumeModeName(mode)}';

/// verdict 라벨 5 — 모르는 코드 = [ArgumentError].
String resumeVerdictLabel(String verdictCode) => switch (verdictCode) {
  VerdictCodes.executedAsReevaluated => '재판정 값으로 집행 예정',
  VerdictCodes.expired => '만료',
  VerdictCodes.superseded => '대체됨',
  VerdictCodes.blocked => '차단',
  VerdictCodes.unrecoverable => '복구 불가',
  _ => throw ArgumentError.value(verdictCode, 'verdictCode', '모르는 재판정 코드'),
};

/// 계획 한 줄 — «{M}월 {D}일 계획됨».
String resumePlannedLine(TradeDate plannedOn) => '${_monthDay(plannedOn)} 계획됨';

/// 재판정 한 줄 — 사유별. 모르는 사유 = [ArgumentError].
String resumeReevaluatedLine({
  required String reasonCode,
  required TradeDate dueBy,
  required TradeDate today,
}) => switch (reasonCode) {
  ResumeReasonCodes.duePassed => '유효기한(${_monthDay(dueBy)})이 지났습니다',
  ResumeReasonCodes.advisoryPending => '안내 모드 재개 조건 결정을 기다립니다',
  ResumeReasonCodes.safetyStop => '안전 정지 — 기기와 원장 검증이 먼저입니다',
  ResumeReasonCodes.observing => '관찰 회차라 다음 회차에 재판정합니다',
  ResumeReasonCodes.reconMismatch => '대사 불일치가 남아 있어 미뤄 둡니다',
  ResumeReasonCodes.unknownOrders => '결과를 모르는 주문이 남아 있어 미뤄 둡니다',
  ResumeReasonCodes.residualOrders => '처리 중인 주문이 남아 있어 미뤄 둡니다',
  ResumeReasonCodes.humanDecision => '계절 진입은 직접 결정해야 합니다',
  ResumeReasonCodes.conservativeDefer => '보수 모드라 다음 정기 회차로 넘겼습니다',
  ResumeReasonCodes.reevaluatedEmpty => '${_monthDay(today)} 재판정 결과 할 일이 없습니다',
  ResumeReasonCodes.reevaluated =>
    '${_monthDay(today)} 재판정 값으로 다음 주문 회차에 넘겼습니다',
  ResumeReasonCodes.humanSkip => '직접 건너뛰었습니다',
  ResumeReasonCodes.humanReduced => '직접 축소 진입을 골랐습니다',
  ResumeReasonCodes.humanAsIs => '직접 그대로 진입을 골랐습니다',
  ResumeReasonCodes.reevaluationFailed => '재판정에 필요한 자료가 없어 미뤄 둡니다',
  _ => throw ArgumentError.value(reasonCode, 'reasonCode', '모르는 재개 사유'),
};

/// 리포트 항목 1행(계획 vs 재판정 vs 사유).
ResumeItem resumeItemOf({
  required ResumeWorkItem item,
  required ResumeItemJudgement judgement,
  required TradeDate today,
}) => ResumeItem(
  workId: item.workId,
  oneLine: item.oneLine,
  plannedLine: resumePlannedLine(item.plannedOn),
  reevaluatedLine: resumeReevaluatedLine(
    reasonCode: judgement.reasonCode,
    dueBy: item.dueBy,
    today: today,
  ),
  verdictCode: judgement.verdictCode,
  verdictLabel: resumeVerdictLabel(judgement.verdictCode),
);

/// 집계 — verdict 마다 · 복구 불가 = UNRECOVERABLE 항목 + 복구 불가 데이터 공백(`data_gap` recoverable 0).
ResumeCounts resumeCountsOf({
  required Iterable<String> verdictCodes,
  required int unrecoverableGaps,
}) {
  if (unrecoverableGaps < 0) {
    throw ArgumentError.value(unrecoverableGaps, 'unrecoverableGaps', '음수');
  }
  final Map<String, int> n = <String, int>{
    for (final String v in VerdictCodes.values) v: 0,
  };
  for (final String v in verdictCodes) {
    if (!n.containsKey(v)) {
      throw ArgumentError.value(v, 'verdictCodes', '모르는 재판정 코드');
    }
    n[v] = n[v]! + 1;
  }
  return ResumeCounts(
    executed: n[VerdictCodes.executedAsReevaluated]!,
    expired: n[VerdictCodes.expired]!,
    superseded: n[VerdictCodes.superseded]!,
    blocked: n[VerdictCodes.blocked]!,
    unrecoverable: n[VerdictCodes.unrecoverable]! + unrecoverableGaps,
  );
}

/// `ResumeReport.headline` — 집계 한 줄 + 모드 꼬리 한 문장.
///
/// [haltReason] = 매매를 멈춰 둔 사유(`resumeHaltReason`) · null = 해제.
String resumeHeadline({
  required int gapSessions,
  required ResumeCounts counts,
  required String? haltReason,
}) =>
    '$gapSessions거래일 미실행: 재판정 ${counts.executed} / 만료 ${counts.expired} / '
    '대체 ${counts.superseded} / 차단 ${counts.blocked} / 복구 불가 ${counts.unrecoverable}. '
    '${_tail(haltReason, counts)}';

String _tail(String? haltReason, ResumeCounts counts) => switch (haltReason) {
  null => counts.executed > 0 ? '주문은 다음 주문 회차가 냅니다.' : '새로 낼 주문은 없습니다.',
  ResumeReasonCodes.observing => '관찰 회차라 발주하지 않습니다.',
  ResumeReasonCodes.safetyStop => '안전 정지 — 매매하지 않습니다.',
  ResumeReasonCodes.advisoryPending => '안내 모드 재개 조건 결정을 기다립니다.',
  ResumeReasonCodes.reconMismatch => '대사 불일치가 풀릴 때까지 매매를 멈춰 둡니다.',
  ResumeReasonCodes.unknownOrders => '결과를 모르는 주문이 풀릴 때까지 매매를 멈춰 둡니다.',
  ResumeReasonCodes.residualOrders => '처리 중인 주문이 풀릴 때까지 매매를 멈춰 둡니다.',
  ResumeReasonCodes.reevaluationFailed => '재판정을 마치지 못해 매매를 멈춰 둡니다.',
  _ => throw ArgumentError.value(haltReason, 'haltReason', '모르는 정지 사유'),
};

/// 홈 «X2 한 줄»(04M8 §4-2) — «마지막 성공 거래일 D+n · 대기 작업 없음 / n건». 기준 없음 = null(블록 부재).
String? resumeLineText({required int? gapSessions, required int pendingWork}) {
  if (pendingWork < 0) {
    throw ArgumentError.value(pendingWork, 'pendingWork', '음수');
  }
  if (gapSessions == null) return null;
  if (gapSessions < 0) {
    throw ArgumentError.value(gapSessions, 'gapSessions', '음수');
  }
  final String work = pendingWork == 0 ? '없음' : '$pendingWork건';
  return '마지막 성공 거래일 D+$gapSessions · 대기 작업 $work';
}

String _monthDay(TradeDate d) {
  final List<String> p = d.yyyyMmDd.split('-');
  if (p.length != 3) {
    throw ArgumentError.value(d.yyyyMmDd, 'date', 'YYYY-MM-DD 가 아니다');
  }
  return '${int.parse(p[1])}월 ${int.parse(p[2])}일';
}
