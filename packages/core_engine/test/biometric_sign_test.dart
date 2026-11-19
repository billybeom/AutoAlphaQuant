// E11p4j — O-04 ③ 생체 서명(설계 13 §8 R159).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

Pledge _p(int v, List<String> lines) =>
    Pledge(version: v, lines: lines, writtenAtUtc: DateTime.utc(2026, 11, 19));

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

void main() {
  test('🔴 채널 값 → 결과 · 모르는 값 = FormatException(조용히 «할 수 없음»으로 바꾸지 않는다)', () {
    expect(biometricOutcomeOfWire('OK'), BiometricOutcome.ok);
    expect(biometricOutcomeOfWire('CANCELED'), BiometricOutcome.canceled);
    expect(biometricOutcomeOfWire('UNAVAILABLE'), BiometricOutcome.unavailable);
    for (final Object? bad in <Object?>[null, '', 'ok', 'FAILED', 1]) {
      expect(
        () => biometricOutcomeOfWire(bad),
        throwsFormatException,
        reason: '$bad',
      );
    }
  });

  test('🔴 결과 문장 = 엔진 글자(할 수 없음 = 공용 BIOMETRIC_UNAVAILABLE 글자)', () {
    expect(
      biometricSignResultText(BiometricOutcome.ok),
      BiometricSignTexts.signed,
    );
    expect(
      biometricSignResultText(BiometricOutcome.canceled),
      BiometricSignTexts.canceled,
    );
    expect(
      biometricSignResultText(BiometricOutcome.unavailable),
      '생체 확인을 할 수 없어 진행하지 않았습니다.',
    );
    expect(kBiometricSignKind, 'ONBOARDING_BIOMETRIC_SIGN');
  });

  test('🔴 서명 지문 = SHA-256 · 판 · 문장 · 기기가 하나라도 다르면 다르다', () {
    final String d = biometricSignDigest(
      pledge: _p(1, <String>['가', '나', '다']),
      deviceId: _dev,
    );
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(d), isTrue, reason: d);
    expect(
      biometricSignDigest(
        pledge: _p(1, <String>['가', '나', '다']),
        deviceId: _dev,
      ),
      d,
    );
    for (final String other in <String>[
      biometricSignDigest(
        pledge: _p(2, <String>['가', '나', '다']),
        deviceId: _dev,
      ),
      biometricSignDigest(
        pledge: _p(1, <String>['가', '나', '라']),
        deviceId: _dev,
      ),
      biometricSignDigest(
        pledge: _p(1, <String>['가', '나', '다']),
        deviceId: 'other-device',
      ),
    ]) {
      expect(other, isNot(d));
    }
  });
}
