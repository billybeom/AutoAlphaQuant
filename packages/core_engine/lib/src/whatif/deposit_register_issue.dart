// 🆕 E11q3 — 실입금 등록 명령 발행(폰 · operator 전용 · 설계 13 §8 R174 · 01 §14-2 · R22 D9).
//
// 🔴 만료 판정의 시각 = 명령의 서버 시각(`requested_at` · R22 D9) — 폰 안에서는 **신뢰 시각**이 그 자리다.
//    신뢰 시각을 모르면 등록하지 않는다: 원장 · 바인딩 · 감사 쓰기 0 · 거부 접수증 `TRUSTED_TIME_UNKNOWN`(모의 개시 원문 검사의
//    «큐 적재 없이 거부» 선례 · 월 납입 쓰기 R54 · 서약 R157 과 같은 원칙). 기기 시계로 대신하지 않는다.
// 🔴 TTL = 30분(실입금 등록 명령 선례 · 알림 확인 · 모의 개시와 같은 값).

import 'dart:math';

import 'package:domain_contracts/domain_contracts.dart' show CommandReceipt;

import '../ops/alert_ack_command.dart' show newCommandId;
import 'deposit_register.dart'
    show DepositRegisterCommand, DepositRegisterRejected, depositReceipt;

/// 실입금 등록 명령 TTL.
const Duration kDepositRegisterTtl = Duration(minutes: 30);

/// 발행 글자.
abstract final class DepositIssueTexts {
  /// 신뢰 시각 없음 — 거부 코드(월 납입 · 서약과 같은 코드).
  static const String trustedTimeUnknownCode = 'TRUSTED_TIME_UNKNOWN';

  /// 신뢰 시각 없음 — 까닭 문장(«거부됨 — » 뒤 · 월 납입 표본 문장의 꼴).
  static const String trustedTimeUnknown =
      '서버 시각을 확인하지 못해 지금은 실입금을 등록할 수 없습니다. 연결을 확인한 뒤 다시 시도해 주세요.';
}

/// 명령을 낸다 — [requestedAtUtc] = 신뢰 시각(만료 판정의 시각) · [random] = 명령 id · nonce 원천.
DepositRegisterCommand issueDepositRegister({
  required String planId,
  required DateTime requestedAtUtc,
  required String deviceId,
  required Random random,
}) {
  final DateTime at = requestedAtUtc.toUtc();
  return DepositRegisterCommand(
    commandId: newCommandId(random),
    planId: planId,
    requestedAt: at,
    expiresAt: at.add(kDepositRegisterTtl),
    nonce: <String>[
      for (int i = 0; i < 16; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join(),
    issuedByDeviceId: deviceId,
  );
}

/// 신뢰 시각을 몰라 등록하지 않은 접수증 — [command] = 기기 시계로 만든 봉투(접수증 시각 · 판정에 쓰지 않는다).
CommandReceipt depositTrustedTimeUnknownReceipt(
  DepositRegisterCommand command,
) => depositReceipt(
  command,
  const DepositRegisterRejected(
    DepositIssueTexts.trustedTimeUnknownCode,
    DepositIssueTexts.trustedTimeUnknown,
  ),
);
