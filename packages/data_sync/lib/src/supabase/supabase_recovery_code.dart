// 복구 코드 해시 꼴(E11k-e2 · 설계 13 §8 R221 · 06 M4-3 «복구 코드는 최초 클레임과 같은 트랜잭션 · 해시만» ·
// 계약 `LeaseRpcParams.recoveryCodeHash` · `newRecoveryCodeHash`).
//
// 🔴 꼴 = `sha256:<소금 16진 32>:<요약 16진 64>` · 요약 = sha256(UTF-8(`<소금 16진>:<정규화 코드>`)) ·
//    정규화 = 영숫자만 남기고 대문자(종이 카드에서 옮겨 적은 띄어쓰기 · 하이픈 · 대소문자를 지운다).
// 🔴 서버 대조 = `sql/supabase_lease_rpc.sql` `lease_revoke`(같은 식 · Postgres 내장 `sha256()` — 확장 0) · 대조 시험 = Postgres 가
//    계산한 고정 벡터(`test/supabase_bootstrap_test.dart`).
// 🔴 빠른 해시로 충분한 까닭 = 복구 코드는 기기가 뽑는 무작위 ≥ 100비트(사람이 고른 낱말이 아니다) — 발급 · 소금 뽑기 · 종이 카드 =
//    E11k-e3(O-04 ⑤). 이 파일은 꼴만 고정한다.
// 🔴 코드 · 해시는 어떤 문자열(오류 · 기록)에도 싣지 않는다 — 꼴 아님 = null.
// 🆕 E11k-e3(R229 F2 · F3) — 발급 = `Random.secure()` 무작위 20자 × 32글자(5비트) = 100비트 · 4자 묶음 5 · 글자 = 손글씨로 헷갈리는
//    0 · 1 · I · O 를 뺀 숫자 · 대문자(정규화 = 그대로 · 서버 식 무변경) · 소금 = 16바이트 소문자 16진 32 · 대조 = 같은 소금으로 다시
//    해시해 상수 시간 비교(평문 비교 0).

import 'dart:convert';
import 'dart:math' show Random;

import 'package:crypto/crypto.dart' show sha256;

final RegExp _nonAlnum = RegExp('[^0-9A-Za-z]');
final RegExp _salt = RegExp(r'^[0-9a-f]{32}$');

/// 서버가 받는 해시 꼴(`sql/supabase_lease_rpc.sql` 의 정규식과 같은 글자 — 시험이 대조한다).
final RegExp kRecoveryCodeHashShape = RegExp(
  r'^sha256:[0-9a-f]{32}:[0-9a-f]{64}$',
);

/// 정규화 — 영숫자만 · 대문자.
String normalizeRecoveryCode(String code) =>
    code.replaceAll(_nonAlnum, '').toUpperCase();

/// 복구 코드 해시 — [saltHex] = 소문자 16진 32자(16바이트) · 꼴 아님(소금 · 정규화 뒤 빈 코드) = null.
String? recoveryCodeHash(String code, {required String saltHex}) {
  if (!_salt.hasMatch(saltHex)) return null;
  final String norm = normalizeRecoveryCode(code);
  if (norm.isEmpty) return null;
  final String digest = sha256
      .convert(utf8.encode('$saltHex:$norm'))
      .toString();
  return 'sha256:$saltHex:$digest';
}

/// 🆕 R229 — 복구 코드 글자 32(숫자 2~9 · 대문자 I · O 뺌 — 손글씨로 0 · 1 · I · O 를 헷갈리지 않게 · 정규화 뒤 그대로).
const String kRecoveryCodeAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

/// 🆕 R229 — 복구 코드 글자 수(20 × 5비트 = 100비트).
const int kRecoveryCodeLength = 20;

/// 🆕 R229 — 묶음 크기(4자씩 하이픈).
const int kRecoveryCodeGroup = 4;

/// 🆕 R229 — 복구 코드 하나(`XXXX-XXXX-XXXX-XXXX-XXXX`) — [random] = `Random.secure()`(시험 = 고정 씨앗).
String newRecoveryCode(Random random) {
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < kRecoveryCodeLength; i++) {
    if (i > 0 && i % kRecoveryCodeGroup == 0) b.write('-');
    b.write(
      kRecoveryCodeAlphabet[random.nextInt(kRecoveryCodeAlphabet.length)],
    );
  }
  return b.toString();
}

/// 🆕 R229 — 소금 16바이트 → 소문자 16진 32.
String newRecoverySaltHex(Random random) {
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < 16; i++) {
    b.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return b.toString();
}

/// 🆕 R229 — 발급한 복구 카드(🔴 [code] = 평문 — 이 객체에만 · 메모리 · `toString` 에 0).
class IssuedRecoveryCode {
  const IssuedRecoveryCode._(this.code, this.hash);

  /// 평문(종이 카드에 옮겨 적을 글자).
  final String code;

  /// 서버에 보낼 해시(`sha256:<소금>:<요약>`).
  final String hash;

  @override
  String toString() => 'IssuedRecoveryCode(…)';
}

/// 🆕 R229 — 새 복구 코드 · 소금 · 해시.
IssuedRecoveryCode issueRecoveryCode(Random random) {
  final String code = newRecoveryCode(random);
  return IssuedRecoveryCode._(
    code,
    recoveryCodeHash(code, saltHex: newRecoverySaltHex(random))!,
  );
}

/// 🆕 R229 — [typed] 가 [hash] 의 코드인가(같은 소금으로 다시 해시 · 상수 시간 비교) · 꼴 아님 = false.
bool recoveryCodeMatches(String typed, String hash) {
  if (!kRecoveryCodeHashShape.hasMatch(hash)) return false;
  final String salt = hash.substring(7, 39);
  final String? again = recoveryCodeHash(typed, saltHex: salt);
  if (again == null || again.length != hash.length) return false;
  int diff = 0;
  for (int i = 0; i < hash.length; i++) {
    diff |= again.codeUnitAt(i) ^ hash.codeUnitAt(i);
  }
  return diff == 0;
}
