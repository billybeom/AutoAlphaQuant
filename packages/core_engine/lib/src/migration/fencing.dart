// X1-3 비상 펜싱 1(클라우드) 대기 게이트(순수 · 설계 13 §8 R119 C2 · C3 · SPEC v2.45 04 §3-1 ③ · 08 그림 9-2).
//
// 🔴 대기 끝 = REVOKED 신뢰 시각 + max(리스 TTL + 마진, 브로커 토큰 잔존 · 모르면 24h).
//    옛 폰이 리스 갱신에 실패해 스스로 봉인하는 것이 «시간상» 보장된 뒤에만 다음으로 간다.
// 🔴 건너뛰는 인자 · 경로 0 · REVOKED 모름 · 신뢰 시각 모름 = 대기(통과 아님).

import 'package:domain_contracts/domain_contracts.dart'
    show SafetyCommonResultCodes, X1FencingResultCodes;

import '../ops/lease_gate.dart' show kLeaseTtl;

/// 브로커 토큰 잔존을 모를 때의 가정(SPEC 04 §3-1 v2.45 ③ — KIS 접근토큰 유효 24h · 실험 1 뒤 값으로 바꾼다).
const Duration kBrokerTokenResidualAssumed = Duration(hours: 24);

/// 펜싱 대기 설정(값 = 02 §4 `operations.migration` — 잠정 · ⬜ 발주자 확정).
class FencingConfig {
  /// 만든다 — 마진 음수 · 잔존 0 이하 = [ArgumentError].
  FencingConfig({required this.margin, this.brokerTokenResidual}) {
    if (margin.isNegative) {
      throw ArgumentError.value(margin, 'margin', '음수');
    }
    if (brokerTokenResidual != null && brokerTokenResidual! <= Duration.zero) {
      throw ArgumentError.value(brokerTokenResidual, 'brokerTokenResidual');
    }
  }

  /// 리스 TTL 위 마진(`fencing_margin_minutes`).
  final Duration margin;

  /// 브로커 토큰 잔존(`broker_token_residual_hours` · null = [kBrokerTokenResidualAssumed]).
  final Duration? brokerTokenResidual;

  /// 실제로 기다리는 길이.
  Duration get wait {
    final Duration lease = kLeaseTtl + margin;
    final Duration residual =
        brokerTokenResidual ?? kBrokerTokenResidualAssumed;
    return lease > residual ? lease : residual;
  }
}

/// 대기 끝 시각.
DateTime fencingWaitEndOf(DateTime revokedAtUtc, FencingConfig c) =>
    revokedAtUtc.toUtc().add(c.wait);

/// 펜싱 대기 사유 코드(글자 = 계약 `X1FencingResultCodes` ∪ 공용 `SafetyCommonResultCodes` 참조 · 미결 212).
abstract final class FencingCodes {
  /// REVOKED 가 아직 없다(대기 시작 전).
  static const String notStarted = X1FencingResultCodes.notStarted;

  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown =
      SafetyCommonResultCodes.trustedTimeUnknown;

  /// 대기 중.
  static const String waiting = X1FencingResultCodes.waiting;
}

/// 펜싱 대기 판정.
class FencingVerdict {
  const FencingVerdict._({required this.passed, this.code, this.endsAtUtc});

  /// 통과했나.
  final bool passed;

  /// 대기 사유(통과 = null).
  final String? code;

  /// 대기 끝 시각(REVOKED 모름 = null).
  final DateTime? endsAtUtc;
}

/// 🔴 펜싱 대기 판정 — 끝 시각 이상일 때만 통과 · 그 밖은 전부 대기.
FencingVerdict fencingVerdictOf({
  required DateTime? revokedAtUtc,
  required DateTime? trustedNowUtc,
  required FencingConfig config,
}) {
  if (revokedAtUtc == null) {
    return const FencingVerdict._(passed: false, code: FencingCodes.notStarted);
  }
  final DateTime end = fencingWaitEndOf(revokedAtUtc, config);
  if (trustedNowUtc == null) {
    return FencingVerdict._(
      passed: false,
      code: FencingCodes.trustedTimeUnknown,
      endsAtUtc: end,
    );
  }
  if (trustedNowUtc.toUtc().isBefore(end)) {
    return FencingVerdict._(
      passed: false,
      code: FencingCodes.waiting,
      endsAtUtc: end,
    );
  }
  return FencingVerdict._(passed: true, endsAtUtc: end);
}
