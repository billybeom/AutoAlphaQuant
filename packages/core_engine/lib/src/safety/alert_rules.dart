// 알림 등급 · 묶음 키 · P0 ack 승급 사다리 · 확인 판정
// (04 §5-3 등급 표 · 앱 04 §5-4 사다리 · 06 M5-15 · 02 §2 v2.41 `alert_*` · 설계 13 §8 R68 H2~H6).
//
// 🔴 등급은 엔진이 정한다(화면 재분류 금지) · 모르는 코드 = 오류(등급을 지어내지 않는다).
// 🔴 같은 날 같은 낸 곳의 같은 코드 = 알림 1건(04 «배치당 · 체크당 · 일 1건»).
// 🔴 사다리 = P0 ∧ ≠ `ADVICE_EXIT_URGENT` · 15분 → 60분 · 건너뛰기 0 · 확인 = 즉시 정지(효력은 그것뿐).

import 'package:domain_contracts/domain_contracts.dart'
    show AdviceRejectCodes, AlertCodes, AlertLevel;

import '../ops/equity_snapshot.dart'
    show kBreakerStoppedAlertCode, kStoppedReleaseEligibleAlertCode;
import '../ops/ledger_integrity.dart' show kLedgerIntegrityAlertCode;
import '../ops/ledger_views.dart' show kstDateText;

/// 엔진 등급 표(04 §5-3 · 계약 25 + 등재 대기 제안 3 — 등재 = 계약 창 E13i1).
const Map<String, AlertLevel> kAlertLevels = <String, AlertLevel>{
  // P0(04 §5-3).
  AlertCodes.orderOutcomeUnknown: AlertLevel.p0,
  AlertCodes.reconMismatch: AlertLevel.p0,
  AlertCodes.brokerAuthFailed: AlertLevel.p0,
  AlertCodes.maintenanceResumeFailed: AlertLevel.p0,
  AlertCodes.adviceExitUrgent: AlertLevel.p0,
  AlertCodes.adviceRevoked: AlertLevel.p0,
  AlertCodes.adviceSuppressed: AlertLevel.p0,
  // P1(04 §5-3).
  AlertCodes.orderRejected: AlertLevel.p1,
  AlertCodes.rebalanceD1: AlertLevel.p1,
  AlertCodes.watchdogLate: AlertLevel.p1,
  AlertCodes.dataSourceDown: AlertLevel.p1,
  AlertCodes.backupStale: AlertLevel.p1,
  AlertCodes.maintenanceWindowOverdue: AlertLevel.p1,
  AlertCodes.adviceIssued: AlertLevel.p1,
  AlertCodes.adviceDueSoon: AlertLevel.p1,
  AlertCodes.ledgerTrustDowngrade: AlertLevel.p1,
  AlertCodes.manualFillRejected: AlertLevel.p1,
  AlertCodes.handoverCoolingActive: AlertLevel.p1,
  AlertCodes.handoverCommitted: AlertLevel.p1,
  // 계약 v1.17 잠정 P1(04 표 밖 · 엔진 D11).
  AlertCodes.staleOrdersHeld: AlertLevel.p1,
  // P2(04 §5-3).
  AlertCodes.rebalanceD7: AlertLevel.p2,
  AlertCodes.depositReminder: AlertLevel.p2,
  AlertCodes.adviceExpired: AlertLevel.p2,
  AlertCodes.selfAuditDue: AlertLevel.p2,
  AlertCodes.contributionChanged: AlertLevel.p2,
  // 등재 대기 제안 3(R68 H2).
  kBreakerStoppedAlertCode: AlertLevel.p0,
  kLedgerIntegrityAlertCode: AlertLevel.p0,
  kStoppedReleaseEligibleAlertCode: AlertLevel.p1,
};

/// 코드의 등급 — 🔴 모르는 코드 = [ArgumentError](지어내지 않는다 · 잡 규약상 fail 핑).
AlertLevel alertLevelOf(String code) {
  final AlertLevel? l = kAlertLevels[code];
  if (l == null) throw ArgumentError.value(code, 'code', '등급 표에 없는 알림 코드');
  return l;
}

/// 사다리를 거는가 — P0 ∧ 손절 안내가 아님(04 §5-4 · 손절 안내는 T-90분 `ADVICE_DUE_SOON` 한 번).
bool alertHasLadder(String code) =>
    alertLevelOf(code) == AlertLevel.p0 && code != AlertCodes.adviceExitUrgent;

/// 묶음 키(R68 H3) — 한국 날 · 낸 곳 · 코드.
String alertDedupeKey({
  required String code,
  required String source,
  required DateTime raisedAtUtc,
}) => '${kstDateText(raisedAtUtc)}|$source|$code';

/// 알림 id(R68 H3) — 같은 묶음 = 같은 id.
String alertIdOf({
  required String code,
  required String source,
  required DateTime raisedAtUtc,
}) => 'AL-${kstDateText(raisedAtUtc)}-$source-$code';

/// 사다리 단계의 경과 기준(앱 04 §5-4) — 단계 1 = 15분(백업 채널) · 단계 2 = 60분(반복 알람 + 워치독).
const List<Duration> kAckLadder = <Duration>[
  Duration(minutes: 15),
  Duration(minutes: 60),
];

/// 지금 오를 단계(차례대로 · R68 H5) — 🔴 건너뛰기 0: 아직 적지 않은 가장 낮은 단계부터, 경과가 닿은 데까지.
List<int> dueEscalationSteps({
  required DateTime raisedAtUtc,
  required DateTime nowUtc,
  required bool acked,
  required Set<int> done,
}) {
  if (acked) return const <int>[];
  final Duration elapsed = nowUtc.difference(raisedAtUtc);
  final List<int> out = <int>[];
  for (int i = 0; i < kAckLadder.length; i++) {
    final int step = i + 1;
    if (done.contains(step)) continue;
    if (elapsed < kAckLadder[i]) break;
    out.add(step);
  }
  return out;
}

/// 확인 판정(R68 H4) — 사다리가 걸린 알림만 · 아니면 `INPUT_INVALID`(효력 없는 확인이라 다른 코드를 만들지 않는다).
String? alertAckRejectCode({required String? code}) =>
    code != null && alertHasLadder(code)
    ? null
    : AdviceRejectCodes.inputInvalid;

/// 사다리 채널 포트(R68 H6) — 실물(백업 채널 · 반복 알람 · 워치독 경보) = 폰 · 계정 뒤.
abstract interface class AlertEscalationChannel {
  /// [step] 단계를 보낸다 — 실패 = 예외(그 단계는 적지 않는다).
  Future<void> escalate({
    required String alertId,
    required String code,
    required int step,
  });
}

/// 알림 포트(잡 → 저장 · 발송) — 엔진이 정한 코드만 넘긴다(등급 · 묶음 · 발송은 받는 쪽).
///
/// 🆕 E13h1(R68 H1) — trading_runtime `job_contract.dart` 에서 옮겼다(구현 = data_sync `SqliteAlertSink` ·
/// trading_runtime 배럴이 같은 이름으로 다시 내보낸다 — E11c R45 C1 하트비트 포트 선례).
abstract interface class AlertSink {
  /// [check] 잡이 낸 알림 코드.
  Future<void> emit(String check, Set<String> codes);
}
