// 🆕 미결 243 ⓓ — 닫힌 원장 쓰기 거부 접수증(설계 13 §8 R276 · 계약 v1.39 K347 · 13 R261 H5 · 리뷰 3차 H1-2).
//
// 🔴 뜻 = 화면 상태가 가리키는 원장이 닫혔다(simToAuto 커밋으로 CLOSE 된 모의 원장 · 커밋 ~ 깨어남 끝 몇 초 틈) → 쓰기 0 ·
//    모든 명령 종류 = rejected `LEDGER_CLOSED` · 다시 누르면 깨어남 뒤 새 원장에 적힌다.
// 🔴 `runMode` 불일치 거부(파일 경계)와 다른 축 — 같은 모드라도 원장 행이 CLOSE 면 이 글자.
// 🔴 판정 = 부르는 쪽(원장 `mode_transition` CLOSE 행 · data_sync `SqliteModeStore.closed`) · 이 파일 = 접수증 글자 · 꼴만(순수).
// 🆕 미결 249(설계 13 §8 R279 · K347 둘째 축) — 원장에 쓰는 안전 · 설정 동작 결과(`SafetyActionResult` · `ActionResult`) = `LEDGER_CLOSED` ·
//    `retryable` true · 등급 = 지켜보기(잠시 뒤 다시 · 바뀐 것 없음) · 글자 = 엔진 한 벌.

import 'dart:math';

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        CommandKind,
        CommandReceipt,
        CommandState,
        LedgerWriteGateCodes,
        SafetyActionId,
        SafetyActionResult,
        SettingsActionId,
        UiLevel;

import '../ops/alert_ack_command.dart' show newCommandId;

/// 닫힌 원장 거부 접수증 TTL(명령 선례 30분 — 폰 안에서 바로 끝난다).
const Duration kLedgerClosedReceiptTtl = Duration(minutes: 30);

/// 닫힌 원장 글자(엔진).
abstract final class LedgerWriteGateTexts {
  /// 접수증 글자(«거부됨 — » 꼴 · 할 일 = 잠시 뒤 다시 · 🔴 수치 · 계좌 0).
  static const String closed =
      '거부됨 — 실전 전환으로 이 원장이 닫혔습니다. 잠시 뒤 다시 누르면 새 원장에 적힙니다';

  /// 🆕 R279 — 동작 결과 글자(결과 headline 꼴 · 접수증과 같은 뜻 · 🔴 수치 · 계좌 0).
  static const String closedAction =
      '실전 전환으로 이 원장이 닫혀 적지 않았습니다. 잠시 뒤 다시 누르면 새 원장에 적힙니다.';
}

/// 🆕 R279(미결 249) — 닫힌 원장 안전 동작 결과(쓰기 0 · `retryable` true · 동작 id = 부른 동작 그대로).
SafetyActionResult ledgerClosedSafetyResultOf({
  required String actionRunId,
  required SafetyActionId id,
}) => SafetyActionResult(
  actionRunId: actionRunId,
  id: id,
  level: UiLevel.watch,
  headline: LedgerWriteGateTexts.closedAction,
  reasonCode: LedgerWriteGateCodes.ledgerClosed,
  retryable: true,
);

/// 🆕 R279(미결 249) — 닫힌 원장 설정 동작 결과(쓰기 0 · `retryable` true · 동작 id = 부른 동작 그대로).
ActionResult ledgerClosedActionResultOf({
  required String actionRunId,
  required SettingsActionId id,
}) => ActionResult(
  actionRunId: actionRunId,
  id: id,
  level: UiLevel.watch,
  headline: LedgerWriteGateTexts.closedAction,
  reasonCode: LedgerWriteGateCodes.ledgerClosed,
  retryable: true,
);

/// 🔴 닫힌 원장 거부 접수증 — 명령 id · nonce = [random] · 시각 = [requestedAtUtc](기기 시계 · 판정에 쓰지 않는다) · 원장 쓰기 0.
CommandReceipt ledgerClosedReceiptOf({
  required CommandKind kind,
  required DateTime requestedAtUtc,
  required String deviceId,
  required Random random,
}) {
  final DateTime at = requestedAtUtc.toUtc();
  return CommandReceipt(
    commandId: newCommandId(random),
    kind: kind,
    state: CommandState.rejected,
    stateLabel: LedgerWriteGateTexts.closed,
    requestedAt: at,
    expiresAt: at.add(kLedgerClosedReceiptTtl),
    nonce: <String>[
      for (int i = 0; i < 16; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join(),
    issuedByDeviceId: deviceId,
    rejectReasonCode: LedgerWriteGateCodes.ledgerClosed,
  );
}
