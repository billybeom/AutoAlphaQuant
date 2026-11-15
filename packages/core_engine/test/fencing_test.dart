// E16c — X1-3 비상 펜싱 1 대기 게이트(설계 13 §8 R119 C2 · C3 · SPEC v2.45 04 §3-1 ③).
//
// 🔵 잡는 것: ① 대기 = max(리스 TTL + 마진, 잔존 · 모르면 24h) ② REVOKED 모름 · 신뢰 시각 모름 = 대기
//    ③ 끝 1초 전 = 대기 · 끝 = 통과 ④ 설정 꼴(마진 음수 · 잔존 0 이하).
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final DateTime _revoked = DateTime.utc(2026, 12, 1, 0, 30);

void main() {
  test('🔴 잔존 모름 = 24h 가정 — 리스 TTL + 마진보다 길면 잔존이 이긴다', () {
    final FencingConfig c = FencingConfig(margin: const Duration(minutes: 10));
    expect(c.wait, kBrokerTokenResidualAssumed);
    expect(kBrokerTokenResidualAssumed, const Duration(hours: 24));
    expect(fencingWaitEndOf(_revoked, c), DateTime.utc(2026, 12, 2, 0, 30));
  });

  test('🔴 잔존이 짧으면 리스 TTL + 마진이 이긴다', () {
    final FencingConfig c = FencingConfig(
      margin: const Duration(minutes: 10),
      brokerTokenResidual: const Duration(minutes: 20),
    );
    expect(c.wait, kLeaseTtl + const Duration(minutes: 10));
    final FencingConfig d = FencingConfig(
      margin: const Duration(minutes: 10),
      brokerTokenResidual: const Duration(hours: 2),
    );
    expect(d.wait, const Duration(hours: 2));
  });

  test('설정 꼴 — 마진 음수 · 잔존 0 = ArgumentError · 마진 0 = 됨', () {
    expect(
      () => FencingConfig(margin: const Duration(minutes: -1)),
      throwsArgumentError,
    );
    expect(
      () => FencingConfig(
        margin: Duration.zero,
        brokerTokenResidual: Duration.zero,
      ),
      throwsArgumentError,
    );
    expect(
      FencingConfig(
        margin: Duration.zero,
        brokerTokenResidual: const Duration(minutes: 1),
      ).wait,
      kLeaseTtl,
    );
  });

  group('대기 판정', () {
    final FencingConfig c = FencingConfig(
      margin: const Duration(minutes: 10),
      brokerTokenResidual: const Duration(hours: 1),
    );
    final DateTime end = _revoked.add(const Duration(hours: 1));

    FencingVerdict at(DateTime? now, {DateTime? revoked}) =>
        fencingVerdictOf(revokedAtUtc: revoked, trustedNowUtc: now, config: c);

    test('🔴 REVOKED 모름 = 대기(시작 전)', () {
      final FencingVerdict v = at(DateTime.utc(2027));
      expect(
        (v.passed, v.code, v.endsAtUtc),
        (false, FencingCodes.notStarted, null),
      );
    });

    test('🔴 신뢰 시각 모름 = 대기(통과 아님)', () {
      final FencingVerdict v = at(null, revoked: _revoked);
      expect(
        (v.passed, v.code, v.endsAtUtc),
        (false, FencingCodes.trustedTimeUnknown, end),
      );
    });

    test('🔴 끝 1초 전 = 대기 · 끝 = 통과 · 뒤 = 통과', () {
      final FencingVerdict w = at(
        end.subtract(const Duration(seconds: 1)),
        revoked: _revoked,
      );
      expect((w.passed, w.code), (false, FencingCodes.waiting));
      final FencingVerdict p = at(end, revoked: _revoked);
      expect((p.passed, p.code, p.endsAtUtc), (true, null, end));
      expect(
        at(end.add(const Duration(days: 1)), revoked: _revoked).passed,
        isTrue,
      );
    });
  });
}
