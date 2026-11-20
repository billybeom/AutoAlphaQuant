// 🆕 simToAuto 커밋이 모의 파일에서 실전 파일로 옮기는 행 — 승인 config · 그 승인 기록 · 서약
// (설계 13 §8 R189 · 01 §8 미결 205 ⓒ · 208 · 01 §35 K177 · 02 §2 `config_versions` · `rule_change_*` · `pledge`).
//
// 🔴 읽기 = 모의 파일(커밋 트랜잭션 앞 · 읽기만) · 쓰기 = 실전 파일 커밋 트랜잭션 안(`SqliteSimToAutoCommitStore.commit`).
//    두 파일을 한 트랜잭션에 묶지 않는다(01 :3388) — 모의 파일은 고치지 않는다(마감 · 지움 = f3b · S5 고름).
// 🔴 승인 config = `config_versions.approved == 1` 하나 ∧ 그것을 승인한 규칙 변경 기록(마지막 APPROVED 결정의 «후» hash 와
//    같다). 승인 기록이 없거나 어긋나면 «승인 아님»(null) → 커밋 거부 `SIM_TO_AUTO_CONFIG_NOT_APPROVED`
//    (승인의 길 = 규칙 변경 승인뿐 · SAF-405 · 냉각 30일 수치 무변경).
// 🔴 옮기는 것 = 설정 판 1(approved 1 그대로) · 그 승인 요청 · 결정 · 요청 저널 · 서약 전 판 · 서약 편집 저널(208).
//    큐(미결정 요청) · 승인 안 된 판 · 취소 · 명령 행(`command_inbox` — 파일마다 멱등) · 서약 재생 = 옮기지 않는다.
// 🔵 열 = 모의 파일 행 그대로(같은 스키마 — `openLocalLedger`) · 표 = 아래 고정 목록뿐.

import 'package:core_engine/core_engine.dart' show kNoApprovedConfig;
import 'package:domain_contracts/domain_contracts.dart' show LedgerFile;
import 'package:sqlite3/sqlite3.dart';

/// 옮기는 행 하나(표 · 열 이름 → 값).
class SimToAutoCarriedRow {
  /// 행을 만든다.
  const SimToAutoCarriedRow(this.table, this.values);

  /// 표(아래 [SimToAutoCarry.tables] 가운데 하나).
  final String table;

  /// 열 → 값(모의 파일 행 그대로).
  final Map<String, Object?> values;
}

/// 🆕 R189 — simToAuto 커밋이 실전 파일로 옮길 것.
class SimToAutoCarry {
  /// 만든다(시험 · [readSimToAutoCarry]).
  const SimToAutoCarry({required this.approvedConfigHash, required this.rows});

  /// 옮길 것 없음(승인 config 없음 → 커밋 거부).
  static const SimToAutoCarry none = SimToAutoCarry(
    approvedConfigHash: null,
    rows: <SimToAutoCarriedRow>[],
  );

  /// 🔴 넣는 차례(참조 먼저) — 저널 → 규칙 변경 요청 → 결정 → 설정 판 → 서약.
  static const List<String> tables = <String>[
    'decision_journal',
    'rule_change_request',
    'rule_change_decision',
    'config_versions',
    'pledge',
  ];

  /// 승인 기록과 맞는 승인 config(없음 = null).
  final String? approvedConfigHash;

  /// 옮길 행([tables] 차례).
  final List<SimToAutoCarriedRow> rows;

  /// 표 하나의 행.
  List<SimToAutoCarriedRow> of(String table) => <SimToAutoCarriedRow>[
    for (final SimToAutoCarriedRow r in rows)
      if (r.table == table) r,
  ];
}

Map<String, Object?> _values(Row r) => <String, Object?>{
  for (final String c in r.keys) c: r[c],
};

/// 🔴 [sim] = 모의 파일(식별이 다르면 [StateError]) — 옮길 행을 읽는다(쓰기 0).
SimToAutoCarry readSimToAutoCarry(Database sim) {
  final Object? appId = sim.select('PRAGMA application_id').first.values.first;
  if (appId != LedgerFile.sim.applicationId) {
    throw StateError('승인 config 옮김: 모의 파일이 아니다($appId)');
  }
  final ResultSet approved = sim.select(
    'SELECT * FROM config_versions WHERE approved = 1',
  );
  if (approved.length > 1) {
    throw StateError('승인된 config 가 ${approved.length}개다(승인 목록 = 하나)');
  }
  final Row? cfg = approved.firstOrNull;
  // 승인 기록 = 마지막 APPROVED 결정(승인은 목록을 «후» hash 하나로 바꾼다 — 마지막 승인 = 지금 승인).
  final Row? decision = sim
      .select(
        "SELECT * FROM rule_change_decision WHERE outcome = 'APPROVED' "
        'ORDER BY decided_at DESC, request_id DESC LIMIT 1',
      )
      .firstOrNull;
  final Row? request = decision == null
      ? null
      : sim.select(
          'SELECT * FROM rule_change_request WHERE request_id = ?',
          <Object?>[decision['request_id']],
        ).firstOrNull;
  final String? hash = cfg?['config_hash'] as String?;
  final bool recorded =
      hash != null &&
      hash != kNoApprovedConfig &&
      request != null &&
      request['config_hash_after'] == hash;
  final List<Row> pledges = sim
      .select('SELECT * FROM pledge ORDER BY version')
      .toList();
  final Set<String> journalIds = <String>{
    if (recorded) request['decision_id']! as String,
    for (final Row p in pledges) p['decision_id']! as String,
  };
  final List<Row> journals = <Row>[
    for (final String id in journalIds.toList()..sort())
      ...sim.select(
        'SELECT * FROM decision_journal WHERE journal_id = ?',
        <Object?>[id],
      ),
  ];
  return SimToAutoCarry(
    approvedConfigHash: recorded ? hash : null,
    rows: <SimToAutoCarriedRow>[
      for (final Row j in journals)
        SimToAutoCarriedRow('decision_journal', _values(j)),
      if (recorded) ...<SimToAutoCarriedRow>[
        SimToAutoCarriedRow('rule_change_request', _values(request)),
        SimToAutoCarriedRow('rule_change_decision', _values(decision!)),
        SimToAutoCarriedRow('config_versions', _values(cfg!)),
      ],
      for (final Row p in pledges) SimToAutoCarriedRow('pledge', _values(p)),
    ],
  );
}

/// 🔴 커밋 트랜잭션 안에서만 — [carry] 의 행을 실전 파일 [live] 에 넣는다(실패 = 던짐 → 커밋 전부 되돌림).
///
/// 설정 판: 같은 지문이 이미 있으면 내용이 같아야 한다(다르면 [StateError]) · 넣은 뒤 승인 목록 = 그 판 하나(R66 ⓐ).
/// 그 밖 표: 그대로 넣는다(같은 id 가 이미 있으면 SQLite 오류 = 되돌림 — 실전 파일엔 커밋 전 이 행들이 없다).
void writeSimToAutoCarryInTransaction(Database live, SimToAutoCarry carry) {
  if (live.autocommit) {
    throw StateError('승인 config 옮김은 바깥 트랜잭션 안에서만');
  }
  final Object? appId = live.select('PRAGMA application_id').first.values.first;
  if (appId != LedgerFile.live.applicationId) {
    throw StateError('승인 config 옮김: 실전 파일이 아니다($appId)');
  }
  for (final String table in SimToAutoCarry.tables) {
    for (final SimToAutoCarriedRow r in carry.of(table)) {
      if (table == 'config_versions') {
        final Row? have = live.select(
          'SELECT content FROM config_versions WHERE config_hash = ?',
          <Object?>[r.values['config_hash']],
        ).firstOrNull;
        if (have != null) {
          if (have['content'] != r.values['content']) {
            throw StateError(
              'config_versions: 지문 ${r.values['config_hash']} 에 다른 내용이 이미 있다',
            );
          }
          continue;
        }
      }
      final List<String> cols = r.values.keys.toList();
      live.execute(
        'INSERT INTO $table (${cols.join(', ')}) '
        'VALUES (${List<String>.filled(cols.length, '?').join(', ')})',
        <Object?>[for (final String c in cols) r.values[c]],
      );
    }
  }
  final String? hash = carry.approvedConfigHash;
  if (hash != null) {
    // 🔴 승인 목록 = 하나(R66 ⓐ) — 옮긴 판만 1.
    live.execute(
      'UPDATE config_versions SET approved = CASE WHEN config_hash = ? THEN 1 ELSE 0 END',
      <Object?>[hash],
    );
  }
}
