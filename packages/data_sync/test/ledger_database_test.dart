// E9-0 — 로컬 정본 SQLite 연결(`package:sqlite3` 실측 · 설계 13 §8 R19 E9-12).
//
// 🔵 잡는 것: PRAGMA 5개가 연결마다 걸리는가(특히 파일에 저장되지 않는 `foreign_keys`) ·
//    되읽기가 다르면 연결을 거부하는가 · 파일 DB 가 WAL 로 쓰이는가 · CHECK 가 실제로 막는가.
// 🔵 스키마 v1 왕복(02 기본 + 배치 A·B·C·F)은 E9 (c1) 의 시험이다.

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('aaq_ledger_'));
  tearDown(() => dir.deleteSync(recursive: true));
  String file(String name) => '${dir.path}${Platform.pathSeparator}$name';

  test('동봉된 SQLite 판을 읽는다', () {
    expect(sqliteLibraryVersion, matches(RegExp(r'^3\.\d+\.\d+$')));
    printOnFailure('SQLite $sqliteLibraryVersion');
  });

  test('새 파일 — PRAGMA 5개가 02 §1 값으로 되읽힌다', () {
    final Database db = openLedgerDatabase(file('ledger.sqlite'));
    addTearDown(db.close);
    Object? read(String name) => db.select('PRAGMA $name').first.values.first;
    expect(read('journal_mode'), 'wal');
    expect(read('synchronous'), 1);
    expect(read('foreign_keys'), 1);
    expect(read('busy_timeout'), 5000);
    expect(read('cache_size'), -64000);
  });

  test('foreign_keys 는 연결마다 — 다시 열어도 FK 위반을 거부한다', () {
    final String path = file('ledger.sqlite');
    Database db = openLedgerDatabase(path);
    // 닫기는 두 번 불러도 된다 — 단언이 중간에 실패해도 임시 폴더를 지울 수 있게.
    addTearDown(db.close);
    db.execute('CREATE TABLE parent (id TEXT NOT NULL PRIMARY KEY)');
    db.execute(
      'CREATE TABLE child (id TEXT NOT NULL PRIMARY KEY, parent_id TEXT NOT NULL, '
      'FOREIGN KEY (parent_id) REFERENCES parent(id))',
    );
    expect(
      () => db.execute("INSERT INTO child VALUES ('c1', 'none')"),
      throwsA(isA<SqliteException>()),
    );
    db.close();
    db = openLedgerDatabase(path);
    addTearDown(db.close);
    expect(
      () => db.execute("INSERT INTO child VALUES ('c2', 'none')"),
      throwsA(isA<SqliteException>()),
    );
    db.execute("INSERT INTO parent VALUES ('p1')");
    db.execute("INSERT INTO child VALUES ('c3', 'p1')");
    expect(db.select('SELECT parent_id FROM child').single['parent_id'], 'p1');
  });

  test('CHECK 가 막고 통과한 행은 그대로 되읽힌다', () {
    final Database db = openLedgerDatabase(file('ledger.sqlite'));
    addTearDown(db.close);
    db.execute(
      "CREATE TABLE t (id INTEGER NOT NULL PRIMARY KEY, mode TEXT NOT NULL CHECK (mode = 'LIVE'))",
    );
    db.execute("INSERT INTO t VALUES (1, 'LIVE')");
    for (final String bad in <String>['SIM_INTERNAL', 'SIM']) {
      expect(
        () => db.execute("INSERT INTO t VALUES (2, '$bad')"),
        throwsA(isA<SqliteException>()),
      );
    }
    expect(db.select('SELECT id, mode FROM t').map((Row r) => r.values), [
      [1, 'LIVE'],
    ]);
  });

  test('파일 DB 는 WAL 로 쓴다 — 쓰기 뒤 -wal 파일이 생긴다', () {
    final String path = file('ledger.sqlite');
    final Database db = openLedgerDatabase(path);
    addTearDown(db.close);
    db.execute('CREATE TABLE t (x INTEGER)');
    db.execute('INSERT INTO t VALUES (1)');
    expect(File('$path-wal').existsSync(), isTrue);
  });

  test(':memory: 는 WAL 이 안 되어 거부한다 — 되읽기가 다르면 연결을 닫는다', () {
    expect(
      () => openLedgerDatabase(':memory:'),
      throwsA(
        isA<StateError>().having(
          (StateError e) => e.message,
          'message',
          contains('PRAGMA journal_mode = memory'),
        ),
      ),
    );
  });
}
