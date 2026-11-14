// 전환 세션(`handover_session`) — 종류 · 닫힘 코드 · TTL · id · 열기 사전 판정 · 냉각 알림 · 문구
// (01 :2967 · 02 §2 `handover_session` · SPEC v2.44 · 앱 05 :585 · 설계 13 §8 R93 AE1 f2 · R96 AF1~AF12).
//
// 🔴 판정만 한다 — 쓰기는 data_sync `SqliteHandoverSessionStore`(실전 파일 · AF1).
// 🔴 세션 = 생체 확인 1회의 기록 = 냉각 24h 의 시작 · 연장 0(`expires_at` = 해시 모집단 · AF4).
// 🔴 유효 = 안 닫힘 ∧ 만료 전(01 :2967) — 파일 안에 한 번에 하나(AF3).
// 🔵 코드 = 엔진 문자열(계약 등재 = 1.20.0 후보) · 세션 무효 = 계약 글자 `HANDOVER_SESSION_INVALID`.

import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, GateState, HandoverPath, SettingsResultCodes;

import '../ops/ledger_views.dart' show kstMinuteText;
import 'sim_to_auto.dart'
    show
        SimToAutoCodes,
        SimToAutoReport,
        SimToAutoStep,
        SimToAutoStepResult,
        kHandoverCommitWindow,
        kHandoverCooling;

/// 세션 수명 = 냉각 24h + 확정 기한 24h(AF4 · 연장 0).
const Duration kHandoverSessionTtl = Duration(hours: 48);

/// 냉각 알림을 내는 곳(`alert_event.source` · AF11).
const String kHandoverCoolingCheck = 'handover-cooling';

/// `handover_session.kind`.
enum HandoverSessionKind {
  /// 안내 개시 게이트(M5-10 · 경로 없음).
  gate('GATE_M5_10'),

  /// 집행 주체 전환 위저드(M5-11 · 경로 있음).
  wizard('WIZARD_M5_11');

  const HandoverSessionKind(this.wire);

  /// 저장 글자.
  final String wire;

  /// 저장 글자 → 값(모르는 글자 = [FormatException]).
  static HandoverSessionKind fromWire(String w) => values.firstWhere(
    (HandoverSessionKind k) => k.wire == w,
    orElse: () => throw FormatException('handover_session.kind', w),
  );
}

/// `handover_session.close_code`.
enum HandoverCloseCode {
  /// 커밋으로 닫힘(f3).
  committed('COMMITTED'),

  /// 사람이 취소.
  cancelled('CANCELLED'),

  /// 확정 기한 지남.
  expired('EXPIRED'),

  /// 커밋 실패로 되돌림(f3).
  rolledBack('ROLLED_BACK');

  const HandoverCloseCode(this.wire);

  /// 저장 글자.
  final String wire;

  /// 저장 글자 → 값(모르는 글자 = [FormatException]).
  static HandoverCloseCode fromWire(String w) => values.firstWhere(
    (HandoverCloseCode c) => c.wire == w,
    orElse: () => throw FormatException('handover_session.close_code', w),
  );
}

/// 전환 세션 거부 · 결과 코드(R96).
abstract final class HandoverSessionCodes {
  /// 생체 확인 없음(계약 값 그대로).
  static const String biometricUnavailable =
      SettingsResultCodes.biometricUnavailable;

  /// 이미 열린 세션이 있다(AF3).
  static const String sessionOpen = 'HANDOVER_SESSION_OPEN';

  /// 없거나 닫힌 세션(계약 글자 · AF6).
  static const String sessionInvalid = 'HANDOVER_SESSION_INVALID';

  /// 저장 실패 — 전부 되돌렸다(AF5).
  static const String rolledBack = 'HANDOVER_SESSION_ROLLED_BACK';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 세션 id — `HS-{한국 YYYYMMDD-HHmmss}`(AF5).
String handoverSessionIdOf(DateTime nowUtc) {
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return 'HS-${k.year.toString().padLeft(4, '0')}${_two(k.month)}${_two(k.day)}'
      '-${_two(k.hour)}${_two(k.minute)}${_two(k.second)}';
}

/// 세션 한 행.
class HandoverSessionRecord {
  /// 행을 만든다.
  const HandoverSessionRecord({
    required this.sessionId,
    required this.kind,
    required this.path,
    required this.deviceId,
    required this.leaseEpoch,
    required this.openedAtUtc,
    required this.expiresAtUtc,
    required this.closedAtUtc,
    required this.closeCode,
  });

  /// 세션 id.
  final String sessionId;

  /// 종류.
  final HandoverSessionKind kind;

  /// 경로(게이트 = null).
  final HandoverPath? path;

  /// 연 기기.
  final String deviceId;

  /// 연 때의 리스 세대.
  final int leaseEpoch;

  /// 연 시각(= 생체 확인 · 냉각 시작).
  final DateTime openedAtUtc;

  /// 만료 시각(연장 0).
  final DateTime expiresAtUtc;

  /// 닫힌 시각(열림 = null).
  final DateTime? closedAtUtc;

  /// 닫힘 코드(열림 = null).
  final HandoverCloseCode? closeCode;

  /// 닫혔나.
  bool get closed => closedAtUtc != null;

  /// [nowUtc] 에 유효한가 — 안 닫힘 ∧ 만료 전(01 :2967).
  bool liveAt(DateTime nowUtc) => !closed && nowUtc.isBefore(expiresAtUtc);
}

/// 열기 사전 판정(AF2) — 통과 = null · 아니면 거부 코드.
///
/// 차례 = 생체 → 신뢰 시각 → 전제 · 안전 → S1~S5 전부 통과 → 이미 세션(S6 통과).
/// [report] = 저장이 신뢰 시각으로 다시 낸 판정(세션 시각 = 없음).
String? simToAutoOpenReject({
  required bool biometricConfirmed,
  required DateTime? trustedNowUtc,
  required SimToAutoReport report,
}) {
  if (!biometricConfirmed) return HandoverSessionCodes.biometricUnavailable;
  if (trustedNowUtc == null) return SimToAutoCodes.trustedTimeUnavailable;
  if (!report.applicable) return report.code ?? SimToAutoCodes.notSimAuto;
  if (report.code == SimToAutoCodes.safetyBlock) {
    return SimToAutoCodes.safetyBlock;
  }
  for (final SimToAutoStepResult r in report.steps) {
    if (r.step.index >= SimToAutoStep.biometric.index) break;
    if (r.state != GateState.pass) return r.blockedReasonCode ?? r.step.stepId;
  }
  if (report.of(SimToAutoStep.biometric).state == GateState.pass) {
    return HandoverSessionCodes.sessionOpen;
  }
  return null;
}

/// 냉각 알림 코드(AF11) — simToAuto 세션 안 닫힘 ∧ 신뢰 시각 ∈ [열림, 열림 + 냉각) → 계약 `HANDOVER_COOLING_ACTIVE`.
///
/// 신뢰 시각 없음 = 빈 집합(조르지 않는다 · 하루 1건은 알림 묶음 키가 맡는다).
Set<String> handoverCoolingAlertCodes(
  HandoverSessionRecord? s, {
  required DateTime? trustedNowUtc,
}) {
  final DateTime? now = trustedNowUtc;
  if (s == null || now == null || s.closed) return const <String>{};
  if (s.path != HandoverPath.simToAuto) return const <String>{};
  if (now.isBefore(s.openedAtUtc)) return const <String>{};
  if (!now.isBefore(s.openedAtUtc.add(kHandoverCooling))) {
    return const <String>{};
  }
  return const <String>{AlertCodes.handoverCoolingActive};
}

/// 취소 문구(AF6).
const String kHandoverCancelledHeadline = '전환을 취소했습니다 — 지금 모드 그대로입니다.';

/// 열기 · 거부 문구(엔진 문자열 · 화면은 그대로 그린다).
String handoverSessionHeadline(String? code, {DateTime? openedAtUtc}) {
  if (code == null) {
    final DateTime? o = openedAtUtc;
    if (o == null) return '전환 세션을 열었습니다.';
    final DateTime coolEnd = o.add(kHandoverCooling);
    final DateTime deadline = coolEnd.add(kHandoverCommitWindow);
    return '생체 확인 완료 — 24시간 냉각 뒤 ${kstMinuteText(coolEnd)}부터 '
        '${kstMinuteText(deadline)} 전까지 확정할 수 있습니다.';
  }
  return switch (code) {
    HandoverSessionCodes.biometricUnavailable => '생체 확인이 없어 전환을 시작하지 않았습니다.',
    SimToAutoCodes.trustedTimeUnavailable => '시각을 확인할 수 없어 전환을 시작하지 않았습니다.',
    HandoverSessionCodes.sessionOpen =>
      '이미 열린 전환 세션이 있습니다 — 그 세션을 마치거나 취소한 뒤 다시 시작해 주세요.',
    HandoverSessionCodes.sessionInvalid => '열려 있는 전환 세션이 아닙니다.',
    HandoverSessionCodes.rolledBack => '저장에 실패해 아무것도 바꾸지 않았습니다.',
    SimToAutoCodes.notSimAuto => '모의투자 자동 매매 중일 때만 실전으로 옮길 수 있습니다.',
    SimToAutoCodes.safetyBlock => '킬스위치나 주문 차단이 켜져 있어 전환을 시작하지 않았습니다.',
    _ => '앞 단계(1~5)를 모두 마친 뒤 생체 확인을 할 수 있습니다.',
  };
}
