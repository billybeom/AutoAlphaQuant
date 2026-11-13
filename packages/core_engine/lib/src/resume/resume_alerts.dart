// 재개 묶음 알림(04 §5-3 v2.42 · 06 X2-6 · 08M 그림 10-1 · 청사진 X2 «규칙» · 설계 13 §8 R70 D7 · R72 J9).
//
// 🔴 회차 끝 = 해제면 `RESUME_COMPLETED`(P1) · 유지면 `RESUME_TRADING_HALTED`(P0) — 둘은 배타(경보 피로) ·
//    복구 불가 갭이 있으면 `RESUME_DATA_GAP`(P2)을 더한다. 낸 곳 = `RESUME`(묶음 키 = 한국 날 → 하루 ≤ 1).
// 🔴 재개 회차 동안 하위 단계 알림은 접는다 — P0 안전 3코드만 개별 유지(P0 사고를 묶음 안에 숨기지 않는다).
//    접힌 건은 재개 리포트에 남는다(`AlertSink` 는 코드만 받는다).
// 🔴 세 코드는 등재 대기 제안(계약 = E14i).

import 'package:domain_contracts/domain_contracts.dart' show AlertCodes;

/// 재개 완료 요약(P1).
const String kResumeCompletedAlertCode = 'RESUME_COMPLETED';

/// 재개 뒤 매매 정지 상태(P0).
const String kResumeTradingHaltedAlertCode = 'RESUME_TRADING_HALTED';

/// 복구 불가 갭(P2).
const String kResumeDataGapAlertCode = 'RESUME_DATA_GAP';

/// 묶음 알림의 낸 곳(`AlertSink.emit` 의 check).
const String kResumeAlertSource = 'RESUME';

/// 재개 회차 동안에도 접지 않는 P0 안전 3코드.
const Set<String> kResumeUnfoldedAlertCodes = <String>{
  AlertCodes.reconMismatch,
  AlertCodes.orderOutcomeUnknown,
  AlertCodes.brokerAuthFailed,
};

/// 재개 회차 동안 이 하위 알림을 접나.
bool resumeFoldsAlert(String code) => !kResumeUnfoldedAlertCodes.contains(code);

/// 회차 끝 묶음 — [flagReleased] = `RESUME_INCOMPLETE` 를 풀었나 · [unrecoverableGaps] = 복구 불가 공백 수.
Set<String> resumeBundleAlerts({
  required bool flagReleased,
  required int unrecoverableGaps,
}) {
  if (unrecoverableGaps < 0) {
    throw ArgumentError.value(unrecoverableGaps, 'unrecoverableGaps', '음수');
  }
  return <String>{
    if (flagReleased)
      kResumeCompletedAlertCode
    else
      kResumeTradingHaltedAlertCode,
    if (unrecoverableGaps > 0) kResumeDataGapAlertCode,
  };
}
