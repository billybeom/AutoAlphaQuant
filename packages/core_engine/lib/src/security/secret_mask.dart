// 마스킹 · 지문 · 본문 가림(설계 13 §8 R44 E3 · E4 · 06 M4-4 «앞4·뒤4» · 04_안전장치 SAF-905 · SAF-906).
//
// 🔴 짧은 값은 전부 가린다 — 12자 미만에서 앞 4 · 뒤 4 를 보이면 거의 다 보인다.
// 🔴 계좌는 뒤 4 만(`****5678` · SAF-906).

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 가림 표시.
const String kRedacted = '<가림>';

/// 키 · 토큰 마스킹 — 12자 이상 = «앞 4 … 뒤 4» · 그 미만 = 전부 가림.
String maskSecret(String value) {
  if (value.length < 12) return '••••';
  return '${value.substring(0, 4)}…${value.substring(value.length - 4)}';
}

/// 계좌번호 마스킹 — 상품코드(`-` 뒤)를 떼고 숫자만 세어 뒤 4 를 남긴다(`12345678-01` → `****5678`) ·
/// 숫자 4개 이하 = 전부 가림.
String maskAccount(String account) {
  final String main = account
      .split('-')
      .first
      .replaceAll(RegExp(r'[^0-9]'), '');
  if (main.length <= 4) return '****';
  return '****${main.substring(main.length - 4)}';
}

/// 값의 지문 — sha256(UTF-8) 16진 앞 8(«어느 키인가»를 값 없이 · 토큰 보관 키 · R44 E4).
String secretFingerprint(String value) =>
    sha256.convert(utf8.encode(value)).toString().substring(0, 8);

/// 가림 대상으로 치는 최소 길이 — 그보다 짧은 값(상품코드 `01` 등)은 본문을 깨므로 무시한다.
const int kMinRedactLength = 8;

/// [text] 안의 [values] 를 전부 [kRedacted] 로 바꾼다(긴 값 먼저 — 짧은 값이 긴 값의 일부를 먼저 지우지 않게).
String redactSecrets(String text, Iterable<String> values) {
  final List<String> vs =
      values.where((String v) => v.length >= kMinRedactLength).toSet().toList()
        ..sort((String a, String b) => b.length.compareTo(a.length));
  String out = text;
  for (final String v in vs) {
    out = out.replaceAll(v, kRedacted);
  }
  return out;
}
