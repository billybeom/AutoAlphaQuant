// 사람 값 원천(E11p4e · 설계 13 §8 R154 · R153 발주자 결정 · 체크리스트 P0-① · P0-②).
//
// 🔴 값 = 자산 `assets/config/p0s_human.json`(발주자 결정 그대로 — 슬리브 A 종목 · 전략 → 계좌 별칭 넷 · 별칭 표시 글자) ·
//    lib 리터럴 0(R90 B2 «기본값 없는 필수 입력») · 별칭 · 종목 = 비밀 아님(계좌 번호 · 키 0).
// 🔴 이 자산은 «정한 값»이지 «지금 설정»이 아니다 — 지금 설정 = 원장의 개시 결정(모의 · 🆕 R265 실전)이 가리키는 등재 판
//    (`currentP0sOpsConfig` · R99 P1) ·
//    모의 개시가 이 값으로 판을 등재한다(그 동작 = M5-14 화면 뒤).
// 🔴 꼴 틀림 = [FormatException](포장 결함은 크게 — 조용히 넘어가지 않는다) · 판 번호가 다르면 읽지 않는다.
// 🔴 이 패키지는 순수 Dart — 자산 읽기(AssetBundle)는 조립 앱 · 여기는 글자 → 값만.

import 'dart:convert' show jsonDecode;

import 'package:core_engine/core_engine.dart' show P0sHumanInputs;

/// 이 패키지 안 자산 경로(시험 · 도구가 파일로 읽는다).
const String kP0sHumanAssetPath = 'assets/config/p0s_human.json';

/// 조립 앱 자산 키(Flutter 의 패키지 자산 규약).
const String kP0sHumanAssetKey = 'packages/data_sync/$kP0sHumanAssetPath';

/// 읽는 판 번호.
const int kP0sHumanVersion = 1;

/// 발주자가 정한 사람 값 + 별칭 표시 글자.
class P0sHumanDecision {
  /// 만든다.
  const P0sHumanDecision({
    required this.inputs,
    required this.accountLabels,
    required this.decisionRef,
  });

  /// 사람 값(A 종목 · 전략 → 계좌 별칭 넷 — 검증된 값).
  final P0sHumanInputs inputs;

  /// 별칭 → 화면 글자(«isa» → «ISA»).
  final Map<String, String> accountLabels;

  /// 결정 근거 한 줄(설계 문서 행).
  final String decisionRef;

  /// 별칭의 화면 글자(없으면 별칭 그대로).
  String labelOf(String alias) => accountLabels[alias] ?? alias;
}

Map<String, String> _strings(Object? raw, String what) {
  if (raw is! Map) throw FormatException('사람 값: $what 가 객체가 아니다');
  final Map<String, String> out = <String, String>{};
  for (final MapEntry<Object?, Object?> e in raw.entries) {
    final Object? k = e.key;
    final Object? v = e.value;
    if (k is! String || v is! String || v.isEmpty) {
      throw FormatException('사람 값: $what.$k 가 비었거나 글자가 아니다');
    }
    out[k] = v;
  }
  return out;
}

/// 🔴 자산 글자 → 사람 값(JSON 아님 · 판 번호 다름 · 칸 없음 · 별칭 표시 글자 빠짐 · 사람 값 규칙 위반 = [FormatException]).
P0sHumanDecision p0sHumanDecisionFromText(String text) {
  final Object? j = jsonDecode(text);
  if (j is! Map) throw const FormatException('사람 값: 객체가 아니다');
  if (j['version'] != kP0sHumanVersion) {
    throw FormatException('사람 값: 판 ${j['version']} — $kP0sHumanVersion 만 읽는다');
  }
  final Object? a = j['sleeve_a_symbol'];
  if (a is! String) throw const FormatException('사람 값: sleeve_a_symbol');
  final Object? ref = j['decision'];
  if (ref is! String || ref.trim().isEmpty) {
    throw const FormatException('사람 값: decision(결정 근거) 없음');
  }
  final Map<String, String> accounts = _strings(j['accounts'], 'accounts');
  final Map<String, String> labels = _strings(
    j['account_labels'],
    'account_labels',
  );
  for (final String alias in accounts.values) {
    if (!labels.containsKey(alias)) {
      throw FormatException('사람 값: 별칭 $alias 의 표시 글자 없음');
    }
  }
  final P0sHumanInputs inputs;
  try {
    inputs = P0sHumanInputs(aSymbol: a, accountByStrategy: accounts);
  } on ArgumentError catch (e) {
    throw FormatException('사람 값: ${e.message}');
  }
  return P0sHumanDecision(
    inputs: inputs,
    accountLabels: Map<String, String>.unmodifiable(labels),
    decisionRef: ref,
  );
}
