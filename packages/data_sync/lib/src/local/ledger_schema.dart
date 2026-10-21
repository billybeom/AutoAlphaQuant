// 로컬 원장 스키마 v1 — 두 파일을 열고 한 트랜잭션으로 만든다(설계 13 §8 R19 E9-2·E9-10 · R20 Q0·Q1 · E9c).
//
// 🔴 v1 = 02 기본 + 배치 A·B·C·F **한 판**(`schemaVersion` = 1). 새 파일이면 전 문장 + `application_id` +
//    `schema_version` 행을 **한 트랜잭션**으로 적용한다 — 파일마다 COMMIT 하면 F 에서 실패할 때 A~C 만 반영된
//    부분 상태가 남는다(01 §6-0). 배치 파일의 `PRAGMA foreign_keys`·`BEGIN`·`COMMIT` 은 그래서 거른다.
// 🔴 이미 있는 파일은 다시 적용하지 않는다(ALTER ADD COLUMN 은 멱등이 아니다). 대신 **파일 식별**
//    (`PRAGMA application_id`)과 번호를 대조하고, 어긋나면 열지 않는다:
//    다른 계열의 파일 · 번호 없는 표 · 더 새 판(앱 되돌림) · 식별 없는 v1 — 전부 [StateError].
// 🔴 두 파일을 한 연결에 묶지 않는다(`ATTACH` 0 — 한 트랜잭션이 두 파일에 걸치지 않는다 · 01 §9-2).

import 'package:domain_contracts/domain_contracts.dart'
    show LedgerFile, RunMode, ledgerDdlFor, schemaVersion;
import 'package:sqlite3/sqlite3.dart';

import 'ledger_database.dart';
import 'schema_v1_sql.dart';

/// 배치 파일에서 거르는 제어문(줄 전체가 이것일 때만).
const Set<String> _controlLines = <String>{
  'PRAGMA foreign_keys = OFF;',
  'PRAGMA foreign_keys = ON;',
  'BEGIN TRANSACTION;',
  'COMMIT;',
};

/// [sql] 에서 제어문 줄을 지운다. 지운 뒤에도 주석 밖에 `PRAGMA`·`BEGIN`·`COMMIT` 이 남으면 [FormatException] —
/// 꼴이 다른 제어문이 한 트랜잭션을 조용히 쪼개지 않게.
String stripControlStatements(String sql) {
  final List<String> kept = <String>[
    for (final String line in sql.split('\n'))
      if (!_controlLines.contains(line.trim())) line,
  ];
  final String out = kept.join('\n');
  final String code = kept
      .map((String l) => l.replaceAll(RegExp('--.*'), ''))
      .join('\n');
  final RegExpMatch? left = RegExp(
    r'\b(PRAGMA|BEGIN|COMMIT|ROLLBACK|ATTACH)\b',
    caseSensitive: false,
  ).firstMatch(code);
  if (left != null) {
    throw FormatException(
      '스키마 문장에 제어문 «${left.group(0)}» 이 남았다',
      code,
      left.start,
    );
  }
  return out;
}

/// [file] 판 v1 스크립트 — 02 기본 1개 + 배치 4개(적용 순서 · SIM 판은 `ledgerDdlFor`).
List<String> ledgerSchemaV1Scripts(LedgerFile file) => <String>[
  stripControlStatements(kBase02Sql),
  for (final (String _, String sql) in kLocalBatchSql)
    stripControlStatements(ledgerDdlFor(file, sql)),
];

/// [db] 를 [file] 의 v1 로 맞춘다. 새 파일이면 만들고, 이미 v1 이면 식별만 대조한다.
///
/// [scripts] 는 시험용(원자성 실패 주입) — 생략하면 [ledgerSchemaV1Scripts].
void ensureLedgerSchema(
  Database db,
  LedgerFile file, {
  DateTime Function()? clock,
  List<String>? scripts,
}) {
  final int appId =
      db.select('PRAGMA application_id').first.values.first! as int;
  final int tables =
      db
              .select(
                "SELECT count(*) AS n FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
              )
              .first['n']
          as int;
  if (tables == 0 && appId == 0) {
    _install(
      db,
      file,
      clock ?? DateTime.now,
      scripts ?? ledgerSchemaV1Scripts(file),
    );
    return;
  }
  if (appId != file.applicationId) {
    throw StateError(
      appId == 0
          ? '원장 파일에 식별(application_id)이 없다 — 열지 않는다: ${file.fileName}'
          : '다른 계열의 원장 파일이다(application_id $appId ≠ ${file.applicationId}) — 열지 않는다: ${file.fileName}',
    );
  }
  final bool hasVersionTable = db
      .select(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'schema_version'",
      )
      .isNotEmpty;
  final int? version = hasVersionTable
      ? db.select('SELECT max(version) AS v FROM schema_version').first['v']
            as int?
      : null;
  if (version == null) {
    throw StateError('원장 파일에 schema_version 행이 없다 — 열지 않는다: ${file.fileName}');
  }
  if (version > schemaVersion) {
    throw StateError(
      '원장 파일이 더 새 판이다(schema_version $version > $schemaVersion) — 앱을 되돌린 채 열지 않는다',
    );
  }
  if (version < schemaVersion) {
    throw StateError(
      'schema_version $version → $schemaVersion 마이그레이션이 없다(v1 이 첫 판이다)',
    );
  }
}

void _install(
  Database db,
  LedgerFile file,
  DateTime Function() clock,
  List<String> scripts,
) {
  db.execute('BEGIN IMMEDIATE');
  try {
    for (final String sql in scripts) {
      db.execute(sql);
    }
    db.execute('PRAGMA application_id = ${file.applicationId}');
    db.execute(
      'INSERT INTO schema_version (version, applied_at, description) VALUES (?, ?, ?)',
      <Object>[
        schemaVersion,
        clock().toUtc().toIso8601String(),
        'v1 — 02 기본 + 배치 A·B·C·F 한 판(${file.fileName})',
      ],
    );
    db.execute('COMMIT');
  } catch (_) {
    if (!db.autocommit) db.execute('ROLLBACK');
    rethrow;
  }
}

/// [directory] 안에서 [mode] 가 쓰는 원장 파일(`LedgerFile.of`)을 열고 v1 을 보장한다.
///
/// 🔴 실패하면 연결을 닫고 다시 던진다 — 잘못된 파일을 연 채로 돌려주지 않는다.
Database openLocalLedger(
  String directory,
  RunMode mode, {
  DateTime Function()? clock,
}) {
  final LedgerFile file = LedgerFile.of(mode);
  // `/` 는 Windows 에서도 SQLite 가 받는다.
  final Database db = openLedgerDatabase('$directory/${file.fileName}');
  try {
    ensureLedgerSchema(db, file, clock: clock);
    return db;
  } catch (_) {
    db.close();
    rethrow;
  }
}
