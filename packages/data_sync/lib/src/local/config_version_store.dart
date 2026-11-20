// 설정 등재 · 승인 읽기(E11p3b-1 · 설계 13 §8 R90 · 02 §2 `config_versions` · 04 §1 SAF-405).
//
// 🔴 등재 = 승인이 아니다 — `approved` 는 0 으로 들어가고, 1 로 바꾸는 길은 규칙 변경 승인 하나뿐이다
//    (`SqliteRuleChangeStore` · 냉각 · 제3자 · 승인 목록 = 하나 · R66).
// 🔴 같은 지문 = 같은 내용 — 이미 있는 지문에 다른 내용이 오면 StateError(덮어쓰지 않는다 · 지문 충돌 또는 판 섞임).
// 🔵 내용 = 정규 JSON(`canonicalConfigJson`) — DDL 주석은 «YAML 원문»이라 적었다(SPEC 정합 메모 · R90).
// 🆕 R192(미결 205 ⓔ · 13 R102 S8 닫음) — 기동 판정 입력 `startupConfigApprovalOf`(operator `BootInputs.approvedOf` 실물).

import 'package:core_engine/core_engine.dart'
    show canonicalConfigJson, configFingerprint;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, DecisionReasonCodes, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// 설정 판 저장.
class SqliteConfigVersionStore {
  /// 만든다.
  SqliteConfigVersionStore(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 🔴 [content] 를 등재한다(승인 0) — 지문을 돌려준다 · 이미 같은 내용이면 그대로.
  String register(Object? content) {
    final String json = canonicalConfigJson(content);
    final String hash = configFingerprint(content);
    return inLedgerTransaction(_db, () {
      final Row? have = _db.select(
        'SELECT content FROM config_versions WHERE config_hash = ?',
        <Object?>[hash],
      ).firstOrNull;
      if (have != null) {
        if (have['content'] != json) {
          throw StateError('config_versions: 지문 $hash 에 다른 내용이 이미 있다');
        }
        return hash;
      }
      _db.execute(
        'INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES (?, ?, ?, 0)',
        <Object?>[hash, _clock.nowUtc().toUtc().toIso8601String(), json],
      );
      return hash;
    });
  }

  /// SAF-405 승인 값(행 없음 = null) — 기동 판정(`modeStartupGate.approved`)의 입력.
  int? approvalOf(String configHash) =>
      _db.select(
            'SELECT approved FROM config_versions WHERE config_hash = ?',
            <Object?>[configHash],
          ).firstOrNull?['approved']
          as int?;
}

/// 🆕 R192(미결 205 ⓔ) — SAF-405 기동 입력: 이 원장의 «지금 돌 설정»(개시 결정이 붙인 판)의 `approved`
/// (개시 없음 · 판 없음 = null → live 기동 거부 · 경고 강등 0).
///
/// 🔴 live = 실전 개시 결정(`OPENING_BALANCE` — simToAuto 커밋이 승인 config 를 옮겨 붙인 판) · 그 밖 = 모의 개시
/// (`SIM_OPENING_BALANCE` — 모의는 SAF-405 무관). 실전에서 규칙 변경이 새 판을 승인하면 개시 판은 0 이 되어 기동이
/// 멈춘다(자동 적용 0 — 새 판으로 도는 길 = M9 «적용» · 그 전엔 미승인 설정으로 돌지 않는다).
int? startupConfigApprovalOf(Database db, RunMode mode) {
  final Row? opening = db.select(
    "SELECT config_hash FROM decision_log WHERE kind = 'MANUAL' AND reason_code = ? "
    'ORDER BY created_at LIMIT 1',
    <Object?>[
      mode == RunMode.live
          ? DecisionReasonCodes.openingBalance
          : DecisionReasonCodes.simOpeningBalance,
    ],
  ).firstOrNull;
  final String? hash = opening?['config_hash'] as String?;
  if (hash == null || hash.isEmpty) return null;
  return db.select(
        'SELECT approved FROM config_versions WHERE config_hash = ?',
        <Object?>[hash],
      ).firstOrNull?['approved']
      as int?;
}
