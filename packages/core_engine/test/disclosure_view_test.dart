// E11q-q5b — M7 S7-2G 열람 게이트 VM · 열람 기록 명령 봉투(설계 13 §8 R223 · 03 §5 S7-2G · 01 §13-5~§13-7).
//
// 🔴 표본 `m7_disclosure_gate` · `_first` · `_frequent` · `_closed` 와 DTO 째로 같다 · 접수증 글자 = 표본 `receipts_4` ·
//    «자주 볼수록» 문턱 = 5회(발주자 위임 — 권고대로).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m7';

List<Map<String, Object?>> _rows(String file) => <Map<String, Object?>>[
  for (final Object? r
      in (jsonDecode(File('$_fx/$file').readAsStringSync())
              as Map<String, Object?>)['rows']!
          as List<Object?>)
    r! as Map<String, Object?>,
];

DisclosureGateVm _gate(String file) =>
    DisclosureGateVm.fromJson(_rows(file).first);

final DateTime _now = DateTime.utc(2026, 8, 31, 9);

DisclosureGateVm _vm(int n, {bool integrity = false}) => disclosureGateVmOf(
  viewCountThisMonth: n,
  integrityHidden: integrity,
  nowUtc: _now,
);

void main() {
  group('게이트 = 표본 그대로', () {
    test('열림 · 2회 · 기록 고지(m7_disclosure_gate)', () {
      expect(_vm(2), _gate('m7_disclosure_gate.json'));
    });

    test('열림 · 0회 · 마찰 줄 없음(_first)', () {
      expect(_vm(0), _gate('m7_disclosure_gate_first.json'));
    });

    test('열림 · 5회 · 잦은 열람(_frequent)', () {
      expect(_vm(5), _gate('m7_disclosure_gate_frequent.json'));
    });

    test('닫힘 · 원장 무결성 점검 — 머리 = 까닭 · 마찰 · 링크 없음(_closed)', () {
      expect(_vm(2, integrity: true), _gate('m7_disclosure_gate_closed.json'));
      expect(_vm(7, integrity: true).frictionLine, isNull);
    });
  });

  test('🆕 «자주 볼수록» 문턱 = 5회 — 4회 = 기록 고지 · 링크 = 열림과 같이(C-37 ①)', () {
    expect(kDisclosureFrequentViews, 5);
    expect(_vm(4).frictionLine, DisclosureGateTexts.friction);
    expect(_vm(5).frictionLine, DisclosureGateTexts.frictionFrequent);
    expect(_vm(30).frictionLine, DisclosureGateTexts.frictionFrequent);
    for (final (int n, bool integrity) in <(int, bool)>[
      (0, false),
      (3, false),
      (3, true),
    ]) {
      final DisclosureGateVm v = _vm(n, integrity: integrity);
      expect(v.gateOpen, v.route != null);
    }
  });

  test('횟수 글자 — 0 = 아직 · n = 월간 리포트와 같은 글자 · 음수 = 인자 오류', () {
    expect(disclosureViewCountText(0), DisclosureGateTexts.noViewsYet);
    expect(disclosureViewCountText(3), MonthlyReportTexts.disclosureViews(3));
    expect(() => disclosureViewCountText(-1), throwsArgumentError);
  });

  test('집계 달 = 접수 시각의 한국 달(UTC 말일 15시 = 다음 달)', () {
    expect(disclosureMonthOf(DateTime.utc(2026, 8, 31, 14, 59)), '2026-08');
    expect(disclosureMonthOf(DateTime.utc(2026, 8, 31, 15)), '2026-09');
  });

  group('명령 봉투', () {
    final DisclosureViewEvent event = DisclosureViewEvent(
      surfaceCode: DisclosureSurfaceCodes.performanceExplore,
      viewedAt: _now,
    );

    test('접수증 — 기록됨 · 보류됨 = 표본 글자 · 종류 · TTL 30분 · 기기', () {
      final DisclosureViewCommand c = DisclosureViewCommand.issue(
        event: event,
        deviceId: 'dev_operator_01',
        nowUtc: _now,
        random: Random(3),
      );
      final List<Map<String, Object?>> rows = _rows(
        'm7_disclosure_view_receipts_4.json',
      );
      String label(String state) =>
          rows.firstWhere(
                (Map<String, Object?> r) => r['state'] == state,
              )['state_label']!
              as String;
      final CommandReceipt ok = c.receipt(held: false);
      expect(ok.kind, CommandKind.disclosureView);
      expect(ok.state, CommandState.executed);
      expect(ok.stateLabel, label('EXECUTED'));
      expect(ok.expiresAt.difference(ok.requestedAt), kDisclosureViewTtl);
      expect(ok.issuedByDeviceId, 'dev_operator_01');
      expect(ok.rejectReasonCode, isNull);
      final CommandReceipt held = c.receipt(held: true);
      expect(held.state, CommandState.heldForIntegrity);
      expect(held.stateLabel, label('HELD_FOR_INTEGRITY'));
    });

    test('지문 = 와이어 JSON 의 SHA-256(원문 재저장 금지) · 낼 때마다 새 id', () {
      final Random r = Random(5);
      final DisclosureViewCommand a = DisclosureViewCommand.issue(
        event: event,
        deviceId: 'd',
        nowUtc: _now,
        random: r,
      );
      final DisclosureViewCommand b = DisclosureViewCommand.issue(
        event: event,
        deviceId: 'd',
        nowUtc: _now,
        random: r,
      );
      expect(
        a.payloadDigest,
        sha256.convert(utf8.encode(jsonEncode(event.toJson()))).toString(),
      );
      expect(a.commandId, isNot(b.commandId));
      expect(a.nonce, isNot(b.nonce));
    });

    test('모르는 화면 코드 = 인자 오류(계약 사전 밖)', () {
      expect(
        () => DisclosureViewCommand.issue(
          event: DisclosureViewEvent(surfaceCode: 'NOPE', viewedAt: _now),
          deviceId: 'd',
          nowUtc: _now,
          random: Random(1),
        ),
        throwsArgumentError,
      );
    });
  });
}
