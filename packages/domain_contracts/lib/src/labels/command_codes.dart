// 🆕 계약 v1.41(01 §50 · K368 · 01 §10-8 «소비 규칙» · 13 §8 R272 Y5) — 명령 소비(맥락) 공통 거부 사전.
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다(labels.dart 머리) — 문구는 엔진이 ack `state_label` 에 함께 싣는다.

/// 명령 맥락 거부(도메인 `command_context_reject`) — 축 = `CommandReceipt.rejectReasonCode` · `command_ack.reject_reason_code`(모든 명령 종류).
/// 🔴 01 §10-8 소비 규칙 — «발행 시점 맥락으로 판정 · 소비 시점 런타임과 다르면 거부하지 않고 `staleContext` · 단 `runMode` 불일치는
///    **예외 없이 거부**(파일 경계는 협상 대상이 아니다)». 이 사전 = 그 «거부» 한 갈래의 글자다(`operatingMode` · `leaseEpoch` 불일치 =
///    `staleContext` 갈래 · 거부 코드 아님).
/// 🔴 `AdviceRejectCodes.operatingModeMismatch`(`OPERATING_MODE_MISMATCH` · X7 안내 갈래 · 다른 축)와 다른 글자 ·
///    `LedgerWriteGateCodes.ledgerClosed`(같은 모드라도 원장 행이 CLOSE)와 다른 축.
abstract final class CommandContextRejectCodes {
  /// 명령의 발행 시점 `run_mode` ≠ 소비 시점 실행 모드(모의 명령이 실전 원장에 · 실전 명령이 모의 원장에 닿지 않는다) — 집행 0 · ack `REJECTED`.
  static const String runModeMismatch = 'RUN_MODE_MISMATCH';

  static const Set<String> values = <String>{runModeMismatch};
}
