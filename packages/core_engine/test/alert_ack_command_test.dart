// E11p3d-4a — 알림 수신 확인(ack) 명령 봉투(설계 13 §8 R147).

import 'dart:convert';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 0,
  deviceId: '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
);

final DateTime _now = DateTime.utc(2026, 12, 1, 0, 5);

AlertAckCommand _issue({int seed = 7, String alertId = 'al_1'}) =>
    AlertAckCommand.issue(
      alertId: alertId,
      context: _ctx,
      nowUtc: _now,
      random: Random(seed),
    );

final RegExp _uuid4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  test('🔴 낸다 = 명령 id(UUID v4) · nonce(16바이트 16진) · 낸 시각 · TTL 30분 · 와이어 = 알림 id + 맥락', () {
    final AlertAckCommand c = _issue();
    expect(_uuid4.hasMatch(c.commandId), isTrue, reason: c.commandId);
    expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(c.nonce), isTrue);
    expect(c.requestedAt, _now);
    expect(c.expiresAt, _now.add(const Duration(minutes: 30)));
    expect(kAlertAckTtl, const Duration(minutes: 30));
    expect(c.wire, const AlertAck(alertId: 'al_1', context: _ctx));
    // 다른 난수 = 다른 id · nonce.
    final AlertAckCommand d = _issue(seed: 8);
    expect(d.commandId, isNot(c.commandId));
    expect(d.nonce, isNot(c.nonce));
    // 지역 시각을 받아도 UTC 로 남긴다.
    expect(
      AlertAckCommand.issue(
        alertId: 'al_1',
        context: _ctx,
        nowUtc: _now.toLocal(),
        random: Random(1),
      ).requestedAt.isUtc,
      isTrue,
    );
  });

  test('명령 id — 판 · 변형 자리가 늘 UUID v4(난수 1000개)', () {
    final Random r = Random(42);
    for (int i = 0; i < 1000; i++) {
      final String id = newCommandId(r);
      expect(_uuid4.hasMatch(id), isTrue, reason: id);
    }
  });

  test('🔴 payload_digest = 와이어 JSON 의 SHA-256 16진 · 알림 id · 맥락이 바뀌면 달라진다', () {
    final AlertAckCommand c = _issue();
    expect(
      c.payloadDigest,
      sha256.convert(utf8.encode(jsonEncode(c.wire.toJson()))).toString(),
    );
    expect(c.payloadDigest, hasLength(64));
    expect(_issue(alertId: 'al_2').payloadDigest, isNot(c.payloadDigest));
    // 맥락(세대 · 기기)이 바뀌어도 달라진다.
    expect(
      AlertAckCommand.issue(
        alertId: 'al_1',
        context: _ctx.copyWith(leaseEpoch: 1),
        nowUtc: _now,
        random: Random(7),
      ).payloadDigest,
      isNot(c.payloadDigest),
    );
    // 같은 알림 · 같은 맥락 = 같은 지문(명령 id · nonce 는 지문 밖).
    expect(_issue(seed: 99).payloadDigest, c.payloadDigest);
  });

  test('🔴 접수증 — 실행 = executed(사유 없음) · 거부 = rejected + 사유 · 글자 = 엔진 그대로 · 발행 기기 = 맥락의 기기', () {
    final AlertAckCommand c = _issue();
    final CommandReceipt ok = c.receipt(executed: true, stateLabel: '실행됨');
    expect(ok.commandId, c.commandId);
    expect(ok.kind, CommandKind.alertAck);
    expect(ok.state, CommandState.executed);
    expect(ok.stateLabel, '실행됨');
    expect(ok.requestedAt, c.requestedAt);
    expect(ok.expiresAt, c.expiresAt);
    expect(ok.nonce, c.nonce);
    expect(ok.issuedByDeviceId, _ctx.deviceId);
    expect(ok.rejectReasonCode, isNull);
    // 실행인데 사유가 와도 싣지 않는다.
    expect(
      c
          .receipt(executed: true, stateLabel: '실행됨', rejectReasonCode: 'X')
          .rejectReasonCode,
      isNull,
    );
    final CommandReceipt no = c.receipt(
      executed: false,
      stateLabel: '거부됨 — INPUT_INVALID',
      rejectReasonCode: 'INPUT_INVALID',
    );
    expect(no.state, CommandState.rejected);
    expect(no.rejectReasonCode, 'INPUT_INVALID');
    expect(
      () => c.receipt(executed: false, stateLabel: '거부됨'),
      throwsArgumentError,
    );
  });
}
