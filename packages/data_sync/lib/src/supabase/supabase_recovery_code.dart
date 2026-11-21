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

import 'dart:convert';

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
