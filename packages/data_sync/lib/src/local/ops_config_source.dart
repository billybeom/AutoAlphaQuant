// 지금 운영 설정 원천(E11p3c-2 · 설계 13 §8 R99 · R90 B2 · 02 §2 `config_versions` · X6-5 ⓑ 모의 개시).
//
// 🔴 사람 값(A 종목 · 전략 → 계좌 넷)은 코드에 없다(R90 B2) — 사람이 온보딩에서 넣은 값이 **등재된 설정 판**
//    (`config_versions.content`)에 실려 있다. 이 원장 파일의 «지금 설정» = 모의 개시 결정(`decision_log` ·
//    `SIM_OPENING_BALANCE`)이 붙인 `config_hash` 의 판이다 — 가상 초기금을 그 계좌 대응으로 나눴으니 같은 판으로 돈다.
// 🔴 판을 다시 지어 지문을 맞춰 본다 — 앱이 바뀌어 SPEC 값(한도 · 비용 · 기본판)이 달라졌으면 같은 사람 값이어도 지문이
//    달라진다. 그때는 «설정 판이 바뀌었다»로 멈춘다(조용히 다른 설정으로 돌지 않는다 · 다시 등재 = 설정 화면).
// 🔴 사유 = 코드 + 지문 · 필드 이름뿐(계좌번호 · 금액 0 — 별칭 · 종목 코드는 비밀이 아니다).
// 🔵 live 파일 · 규칙 변경으로 승인된 새 판(SAF-405)은 계약 창 · E11p3c-4 몫 — 여기는 모의 개시 판 하나.

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show P0sHumanInputs, P0sOpsConfig, kP0sConfigSpecVersion;
import 'package:domain_contracts/domain_contracts.dart'
    show DecisionReasonCodes;
import 'package:sqlite3/sqlite3.dart';

/// 지금 설정을 못 얻은 까닭.
abstract final class OpsConfigCodes {
  /// 모의 개시 결정이 없다(온보딩 전 · 투자 안내 모드).
  static const String noOpening = 'OPS_CONFIG_NO_OPENING';

  /// 개시 결정이 가리키는 판이 `config_versions` 에 없다.
  static const String notRegistered = 'OPS_CONFIG_NOT_REGISTERED';

  /// 판 내용이 P0S 설정 꼴이 아니다(사람 값 칸 · 꼴).
  static const String contentInvalid = 'OPS_CONFIG_CONTENT_INVALID';

  /// 판의 SPEC 판이 지금 코드와 다르거나, 다시 지은 지문이 다르다.
  static const String drift = 'OPS_CONFIG_DRIFT';
}

/// 지금 설정 읽기 결과.
sealed class OpsConfigRead {
  const OpsConfigRead();
}

/// 지금 설정.
final class OpsConfigReady extends OpsConfigRead {
  /// 만든다.
  const OpsConfigReady(this.config, this.configHash);

  /// 설정(사람 값 포함).
  final P0sOpsConfig config;

  /// 판 지문(= `config.configHash`).
  final String configHash;
}

/// 지금 설정을 못 얻었다 — 🔴 실물 잡은 이 회차를 실패로 남긴다.
final class OpsConfigUnavailable extends OpsConfigRead implements Exception {
  /// 만든다.
  const OpsConfigUnavailable(this.code, this.detail);

  /// [OpsConfigCodes] 값.
  final String code;

  /// 사유(지문 · 칸 이름).
  final String detail;

  @override
  String toString() => 'OpsConfigUnavailable($code · $detail)';
}

/// 🔴 [db](sim 원장)의 지금 설정 — 모의 개시가 붙인 판을 읽고 다시 지어 지문을 맞춘다.
OpsConfigRead currentP0sOpsConfig(Database db) {
  final Row? opening = db.select(
    "SELECT config_hash FROM decision_log WHERE kind = 'MANUAL' AND reason_code = ? "
    'ORDER BY created_at LIMIT 1',
    <Object?>[DecisionReasonCodes.simOpeningBalance],
  ).firstOrNull;
  final String? hash = opening?['config_hash'] as String?;
  if (opening == null || hash == null || hash.isEmpty) {
    return const OpsConfigUnavailable(OpsConfigCodes.noOpening, '모의 개시 결정 없음');
  }
  final Row? row = db.select(
    'SELECT content FROM config_versions WHERE config_hash = ?',
    <Object?>[hash],
  ).firstOrNull;
  if (row == null) {
    return OpsConfigUnavailable(OpsConfigCodes.notRegistered, hash);
  }
  final Object? content;
  try {
    content = jsonDecode(row['content'] as String);
  } on FormatException {
    return OpsConfigUnavailable(
      OpsConfigCodes.contentInvalid,
      '$hash: JSON 아님',
    );
  }
  if (content is! Map<String, Object?>) {
    return OpsConfigUnavailable(OpsConfigCodes.contentInvalid, '$hash: 객체 아님');
  }
  if (content['spec'] != kP0sConfigSpecVersion) {
    return OpsConfigUnavailable(
      OpsConfigCodes.drift,
      '$hash: spec ${content['spec']} ≠ $kP0sConfigSpecVersion',
    );
  }
  final Object? a = content['sleeve_a_symbol'];
  final Object? accounts = content['accounts'];
  if (a is! String || accounts is! Map<String, Object?>) {
    return OpsConfigUnavailable(
      OpsConfigCodes.contentInvalid,
      '$hash: sleeve_a_symbol · accounts',
    );
  }
  final Map<String, String> byStrategy = <String, String>{};
  for (final MapEntry<String, Object?> e in accounts.entries) {
    final Object? v = e.value;
    if (v is! String) {
      return OpsConfigUnavailable(
        OpsConfigCodes.contentInvalid,
        '$hash: accounts.${e.key}',
      );
    }
    byStrategy[e.key] = v;
  }
  final P0sOpsConfig config;
  try {
    config = P0sOpsConfig.of(
      P0sHumanInputs(aSymbol: a, accountByStrategy: byStrategy),
    );
  } on ArgumentError catch (e) {
    return OpsConfigUnavailable(
      OpsConfigCodes.contentInvalid,
      '$hash: ${e.name ?? '사람 값'}',
    );
  }
  if (config.configHash != hash) {
    return OpsConfigUnavailable(
      OpsConfigCodes.drift,
      '$hash ≠ 다시 지은 ${config.configHash}',
    );
  }
  return OpsConfigReady(config, hash);
}
