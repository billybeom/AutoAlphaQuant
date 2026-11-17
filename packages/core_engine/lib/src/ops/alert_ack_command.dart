// E11p3d-4a — 알림 수신 확인(ack) 명령 봉투(설계 13 §8 R147 · 01 §24 K12 · 앱 04 §5-4 ① · 엔진 R68 H4).
//
// 🔴 수신 확인 = «읽었다» — `SafetyState` 효력 0 · 사다리 정지만(04 §5-4 ① · 무마찰 — 생체 · 확인 다이얼로그 0).
//    체크리스트 이행 선언(`killChecklistConfirm`)과 한 버튼으로 묶지 않는다(그건 M5 화면).
// 🔴 맥락(`CommandContext`)을 채우는 것은 화면이 아니라 `CommandApi` 구현이다(G-19) — 여기는 그 구현이 쓰는 순수 봉투.
// 🔴 `payload_digest` = 와이어(`AlertAck`) JSON 의 SHA-256 16진(원문 재저장 금지 — 실입금 등록 선례).
// 🔵 TTL = 30분(실입금 등록 명령 선례) — 폰 안에서 바로 실행되므로 TTL 을 쓰기 전에 끝난다.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AlertAck, CommandContext, CommandKind, CommandReceipt, CommandState;

/// 확인 명령 TTL.
const Duration kAlertAckTtl = Duration(minutes: 30);

String _hex(Random r, int bytes) => <String>[
  for (int i = 0; i < bytes; i++)
    r.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();

/// 새 명령 id(UUID v4 꼴 · 소문자).
String newCommandId(Random r) {
  final List<int> b = <int>[for (int i = 0; i < 16; i++) r.nextInt(256)];
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final String h = b.map((int x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

/// 수신 확인 명령 한 건.
class AlertAckCommand {
  /// 명령을 만든다(직접 — 시험 · 재구성).
  const AlertAckCommand({
    required this.commandId,
    required this.nonce,
    required this.requestedAt,
    required this.expiresAt,
    required this.wire,
  });

  /// 지금 낸다 — [random] = 명령 id · nonce 원천(운영 = `Random.secure()`).
  factory AlertAckCommand.issue({
    required String alertId,
    required CommandContext context,
    required DateTime nowUtc,
    required Random random,
  }) {
    final DateTime at = nowUtc.toUtc();
    return AlertAckCommand(
      commandId: newCommandId(random),
      nonce: _hex(random, 16),
      requestedAt: at,
      expiresAt: at.add(kAlertAckTtl),
      wire: AlertAck(alertId: alertId, context: context),
    );
  }

  /// 명령 id.
  final String commandId;

  /// 1회용 값.
  final String nonce;

  /// 낸 시각(UTC).
  final DateTime requestedAt;

  /// TTL 끝(UTC).
  final DateTime expiresAt;

  /// 와이어(알림 id + 발행 맥락).
  final AlertAck wire;

  /// `command_inbox.payload_digest` — 와이어 JSON 의 SHA-256 16진.
  String get payloadDigest =>
      sha256.convert(utf8.encode(jsonEncode(wire.toJson()))).toString();

  /// 엔진 처리 결과 → 접수증 — [stateLabel] = 엔진이 `command_inbox` 에 남긴 글자 그대로.
  CommandReceipt receipt({
    required bool executed,
    required String stateLabel,
    String? rejectReasonCode,
  }) {
    if (!executed && rejectReasonCode == null) {
      throw ArgumentError('거부에는 사유 코드가 있어야 한다');
    }
    return CommandReceipt(
      commandId: commandId,
      kind: CommandKind.alertAck,
      state: executed ? CommandState.executed : CommandState.rejected,
      stateLabel: stateLabel,
      requestedAt: requestedAt,
      expiresAt: expiresAt,
      nonce: nonce,
      issuedByDeviceId: wire.context.deviceId,
      rejectReasonCode: executed ? null : rejectReasonCode,
    );
  }
}
