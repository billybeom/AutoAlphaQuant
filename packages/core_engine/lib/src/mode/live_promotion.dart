// M1-22 승격 커밋 — 사전 판정 차례 · 코드 · 결정 id · 문구(02 §2-6 EXEC_POLICY «승격(관찰 뒤 생체 1회)» ·
// 01 §10-2 G-43 · SPEC v2.44 04 §3-1 ① · 설계 13 §8 R91 AD1~AD5).
//
// 🔴 자동 승격 0 — 사람의 생체 1회(호출자 증명)가 있어야 하고, 같은 트랜잭션 안에서 관찰을 다시 판정한다.
// 🔴 판정 차례 = 생체 → 세션 → 관찰 중 → 자동 매매 → 시각 → 재판정(AD4).
// 🔴 문구에 «DRY_RUN» 글자 0(G-63) · 코드 = 엔진 문자열(계약 등재 = 1.19.0 창 후보).

import 'package:domain_contracts/domain_contracts.dart'
    show ExecPolicy, OperatingMode, RunMode, SettingsResultCodes;

import 'live_observation.dart' show LiveObservationBlock, LiveObservationReport;

/// 승격 거부 · 결과 코드(R91).
abstract final class LivePromotionCodes {
  /// 생체 확인 없음(계약 값 그대로).
  static const String biometricUnavailable =
      SettingsResultCodes.biometricUnavailable;

  /// 준 세션이 없거나 닫혔거나 만료.
  static const String sessionInvalid = 'HANDOVER_SESSION_INVALID';

  /// 현재 행이 실전 관찰(live × dryRun)이 아니다.
  static const String notObserving = 'LIVE_PROMOTION_NOT_OBSERVING';

  /// 운영 방식이 자동 매매가 아니다(모름 포함).
  static const String notAutoTrade = 'LIVE_PROMOTION_NOT_AUTO_TRADE';

  /// 지금이 현재 행 커밋 시각보다 늦지 않다(새 행이 «현재»가 못 된다).
  static const String clockBehind = 'LIVE_PROMOTION_CLOCK_BEHIND';

  /// 저장 실패 — 전부 되돌렸다.
  static const String rolledBack = 'LIVE_PROMOTION_ROLLED_BACK';
}

/// 승격 결정의 `decision_log.reason_code`.
const String kLivePromotionReasonCode = 'LIVE_EXECUTE_PROMOTION';

/// 승격 결정의 `decision_log.reason`(엔진 문구).
const String kLivePromotionReason = '실전 집행 승격 — 관찰 뒤 생체 1회';

String _two(int n) => n.toString().padLeft(2, '0');

/// 승격 결정 id — `PROMOTE-{한국 YYYYMMDD-HHmmss}`.
String livePromotionDecisionId(DateTime nowUtc) {
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return 'PROMOTE-${k.year.toString().padLeft(4, '0')}${_two(k.month)}${_two(k.day)}'
      '-${_two(k.hour)}${_two(k.minute)}${_two(k.second)}';
}

/// 사전 판정(AD4) — 통과 = null · 아니면 거부 코드.
///
/// [sessionValid] = 세션을 주지 않았으면 null · 줬으면 그 행이 열림 ∧ 만료 전인가.
/// [report] = 같은 트랜잭션 안에서 다시 판정한 관찰 결과.
String? livePromotionReject({
  required bool biometricConfirmed,
  required bool? sessionValid,
  required RunMode? runMode,
  required ExecPolicy? execPolicy,
  required OperatingMode? operatingMode,
  required DateTime? currentSinceUtc,
  required DateTime nowUtc,
  required LiveObservationReport report,
}) {
  if (!biometricConfirmed) return LivePromotionCodes.biometricUnavailable;
  if (sessionValid == false) return LivePromotionCodes.sessionInvalid;
  if (runMode != RunMode.live ||
      execPolicy != ExecPolicy.dryRun ||
      currentSinceUtc == null) {
    return LivePromotionCodes.notObserving;
  }
  if (operatingMode != OperatingMode.autoTrade) {
    return LivePromotionCodes.notAutoTrade;
  }
  if (!nowUtc.isAfter(currentSinceUtc)) return LivePromotionCodes.clockBehind;
  if (!report.promotionAvailable) {
    return report.block?.code ?? LivePromotionCodes.notObserving;
  }
  return null;
}

/// 엔진 머리말 — [code] = null 이면 성공 · 관찰 막힘이면 칩 문구([LiveObservationReport.promotionLabel]).
String livePromotionHeadline(String? code, {LiveObservationReport? report}) {
  if (code == null) return '실전 집행으로 올렸습니다 — 다음 회차부터 실제 주문을 냅니다.';
  for (final LiveObservationBlock b in LiveObservationBlock.values) {
    if (b.code == code) {
      return report?.promotionLabel ?? '승격 불가 — 관찰 조건을 아직 채우지 못했습니다';
    }
  }
  return switch (code) {
    LivePromotionCodes.biometricUnavailable => '생체 확인이 없어 올리지 않았습니다.',
    LivePromotionCodes.sessionInvalid => '확인 세션이 열려 있지 않거나 만료돼 올리지 않았습니다.',
    LivePromotionCodes.notObserving => '실전 관찰 중이 아니라 올릴 것이 없습니다.',
    LivePromotionCodes.notAutoTrade => '자동 매매가 아니라 올리지 않았습니다.',
    LivePromotionCodes.clockBehind => '기기 시각이 관찰 시작보다 앞서 올리지 않았습니다.',
    _ => '실전 집행으로 올리지 못했습니다 — 바뀐 것은 없습니다. 다시 시도해 주세요.',
  };
}
