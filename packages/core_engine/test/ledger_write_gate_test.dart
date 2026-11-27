// 🆕 미결 243 ⓓ — 닫힌 원장 쓰기 거부 접수증(설계 13 §8 R276 · 계약 v1.39 K347).

import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

void main() {
  test('🔴 모든 명령 종류 = rejected LEDGER_CLOSED · 글자 = 엔진 · TTL 30분 · 새 명령 id · nonce', () {
    final DateTime at = DateTime.utc(2027, 1, 12, 3, 0);
    final Set<String> ids = <String>{};
    final Random random = Random(11);
    for (final CommandKind k in CommandKind.values) {
      final CommandReceipt r = ledgerClosedReceiptOf(
        kind: k,
        requestedAtUtc: at.toLocal(),
        deviceId: 'dev-1',
        random: random,
      );
      expect(r.kind, k);
      expect(r.state, CommandState.rejected);
      expect(r.rejectReasonCode, LedgerWriteGateCodes.ledgerClosed);
      expect(r.rejectReasonCode, 'LEDGER_CLOSED');
      expect(r.stateLabel, LedgerWriteGateTexts.closed);
      expect(r.requestedAt, at);
      expect(r.requestedAt.isUtc, isTrue);
      expect(r.expiresAt, at.add(const Duration(minutes: 30)));
      expect(r.issuedByDeviceId, 'dev-1');
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(r.commandId),
        isTrue,
        reason: r.commandId,
      );
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(r.nonce), isTrue);
      ids.add(r.commandId);
      // 거부 = 코드 필수(계약 상태 기계).
      expect(CommandStateMachine.requiresRejectReasonCode(r.state), isTrue);
    }
    expect(ids, hasLength(CommandKind.values.length));
    expect(kLedgerClosedReceiptTtl, const Duration(minutes: 30));
  });

  test('글자 = «거부됨 — » 꼴 · 할 일(다시 누르기) · 수치 · 코드 0', () {
    expect(LedgerWriteGateTexts.closed, startsWith('거부됨 — '));
    expect(LedgerWriteGateTexts.closed, contains('다시 누르면'));
    expect(LedgerWriteGateTexts.closed, isNot(contains(RegExp(r'\d|LEDGER_'))));
  });
}
