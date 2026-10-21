// 로컬 정본 SQLite 연결 — 02 §1 PRAGMA 5개를 연결마다 걸고 되읽어 확인한다(설계 13 §8 R19 E9-12).
//
// 🔴 드라이버 = `package:sqlite3`(순수 Dart FFI · 빌드 훅이 SQLite 실행 파일을 받아 sha256 으로
//    검증한 뒤 동봉한다). data_sync 를 순수 Dart 로 두어 CI `dart test` 가 실제 SQLite 를 연다.
// 🔴 `foreign_keys` 는 파일에 저장되지 않는다 — 연결을 열 때마다 켜고 켜졌는지 되읽는다.
//    되읽은 값이 하나라도 다르면 연결을 닫고 StateError(fail-closed — FK 가 꺼진 연결로
//    원장을 쓰지 않는다). `:memory:` 는 WAL 이 안 되므로 여기서 거부된다(원장은 파일이다).
// 🔴 스키마(02 기본 + 배치 A·B·C·F = `schema_version` 1)는 아직 없다 — 마이그레이션 러너는
//    E9 (c1) 몫이다(설계 13 §2-2 E9).

import 'package:sqlite3/sqlite3.dart';

/// 02 §1 — 연결마다 거는 PRAGMA(이름 · 거는 값 · 되읽을 때 기대하는 값).
const List<(String, String, Object)> kLedgerPragmas =
    <(String, String, Object)>[
      ('journal_mode', 'WAL', 'wal'),
      ('synchronous', 'NORMAL', 1),
      ('foreign_keys', 'ON', 1),
      ('busy_timeout', '5000', 5000),
      ('cache_size', '-64000', -64000),
    ];

/// 동봉된 SQLite 의 판 — 예 `3.54.0`.
String get sqliteLibraryVersion => sqlite3.version.libVersion;

/// [path] 의 원장 파일을 연다(없으면 만든다). PRAGMA 5개를 걸고 되읽어 모두 맞을 때만 돌려준다.
Database openLedgerDatabase(String path) {
  final Database db = sqlite3.open(path);
  try {
    for (final (String name, String value, Object want) in kLedgerPragmas) {
      db.execute('PRAGMA $name = $value');
      final Object? got = db.select('PRAGMA $name').first.values.first;
      if (got != want) {
        throw StateError('PRAGMA $name = $got (기대 $want) — 원장 연결을 거부한다: $path');
      }
    }
    return db;
  } catch (_) {
    db.close();
    rethrow;
  }
}
