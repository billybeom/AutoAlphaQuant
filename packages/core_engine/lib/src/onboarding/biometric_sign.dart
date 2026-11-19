// O-04 ③ 생체 서명(설계 13 §8 R159 · 04 §9-5 ③ · 06 M4-11 ① · 05 §63 · 01 §8 미결 169).
//
// 🔴 뜻 = 이 폰의 생체 인증으로 ② 서약 지금 판에 서명한다 — 뒤의 안전 동작(재개 게이트 · 승격 · 운영 등급)이 쓰는
//    생체가 이 폰에 등록돼 작동하는지 온보딩에서 처음 확인하는 자리.
// 🔴 서명 대상 지문 = SHA-256(종류 · 서약 판 · 세 문장 · 기기 id) — 서약을 고치면(새 판) 지문이 달라진다.
// 🔴 기기 암호(PIN · 패턴) 대체 0(05 §63 «비밀번호 대체 경로를 만들지 않는다») · 실패 3회 · 미등록 · 잠금 = 할 수 없음.
// 🔴 글자 = 엔진(대화상자 · 버튼 · 결과) — 플랫폼(Kotlin)은 문장을 짓지 않는다.

import 'dart:convert' show jsonEncode, utf8;

import 'package:crypto/crypto.dart' show sha256;

import '../safety/pledge.dart' show Pledge;

/// `command_inbox.kind` — ③ 생체 서명 기록(스키마 무변경 · 서약 쓰기 `PLEDGE_WRITE` 선례).
const String kBiometricSignKind = 'ONBOARDING_BIOMETRIC_SIGN';

/// 플랫폼 생체 확인 결과.
enum BiometricOutcome {
  /// 확인됐다.
  ok('OK'),

  /// 사람이 취소했다(다시 누를 수 있다).
  canceled('CANCELED'),

  /// 할 수 없다(미등록 · 하드웨어 없음 · 잠금 · 화면 없음 · 너무 옛 Android).
  unavailable('UNAVAILABLE');

  const BiometricOutcome(this.wire);

  /// 채널 글자.
  final String wire;
}

/// 🔴 채널 값 → 결과(모르는 값 = [FormatException] — 조용히 «할 수 없음»으로 바꾸지 않는다).
BiometricOutcome biometricOutcomeOfWire(Object? v) {
  for (final BiometricOutcome o in BiometricOutcome.values) {
    if (o.wire == v) return o;
  }
  throw FormatException('생체 결과 꼴이 아니다', v);
}

/// ③ 생체 서명 글자(엔진).
abstract final class BiometricSignTexts {
  /// 대화상자 제목.
  static const String promptTitle = '서약에 생체로 서명';

  /// 대화상자 설명.
  static const String promptSubtitle = '방금 쓴 서약 세 문장을 이 폰의 생체 인증으로 확인합니다.';

  /// 대화상자 취소 버튼.
  static const String promptCancel = '취소';

  /// 칸 버튼.
  static const String button = '생체로 서명';

  /// 서명했다.
  static const String signed = '생체 서명을 마쳤습니다.';

  /// 취소했다.
  static const String canceled = '생체 확인을 취소했습니다 — 다시 누르면 됩니다.';

  /// 할 수 없다(`BIOMETRIC_UNAVAILABLE` 공용 글자와 같다).
  static const String unavailable = '생체 확인을 할 수 없어 진행하지 않았습니다.';

  /// 서약이 아직 없다(② 가 먼저다).
  static const String noPledge = '서약을 먼저 저장해 주세요.';
}

/// 결과 → 문장(엔진).
String biometricSignResultText(BiometricOutcome o) => switch (o) {
  BiometricOutcome.ok => BiometricSignTexts.signed,
  BiometricOutcome.canceled => BiometricSignTexts.canceled,
  BiometricOutcome.unavailable => BiometricSignTexts.unavailable,
};

/// 🔴 서명 대상 지문 — 종류 · 서약 판 · 세 문장 · 기기 id.
String biometricSignDigest({
  required Pledge pledge,
  required String deviceId,
}) => sha256
    .convert(
      utf8.encode(
        jsonEncode(<String, Object>{
          'kind': kBiometricSignKind,
          'pledge_version': pledge.version,
          'lines': pledge.lines,
          'device_id': deviceId,
        }),
      ),
    )
    .toString();
