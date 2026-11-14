// 설정 등재 · 승인 읽기(E11p3b-1 · 설계 13 §8 R90 · 02 §2 `config_versions` · 04 §1 SAF-405).
//
// 🔴 등재 = 승인이 아니다 — `approved` 는 0 으로 들어가고, 1 로 바꾸는 길은 규칙 변경 승인 하나뿐이다
//    (`SqliteRuleChangeStore` · 냉각 · 제3자 · 승인 목록 = 하나 · R66).
// 🔴 같은 지문 = 같은 내용 — 이미 있는 지문에 다른 내용이 오면 StateError(덮어쓰지 않는다 · 지문 충돌 또는 판 섞임).
// 🔵 내용 = 정규 JSON(`canonicalConfigJson`) — DDL 주석은 «YAML 원문»이라 적었다(SPEC 정합 메모 · R90).

import 'package:core_engine/core_engine.dart'
    show canonicalConfigJson, configFingerprint;
import 'package:domain_contracts/domain_contracts.dart' show Clock;
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
