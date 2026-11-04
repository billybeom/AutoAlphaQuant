// 기기 로컬 암호화 저장소 — 입력 초안 + 명령 내구 큐 ⓐ(설계 13 §8 R46 G1~G10 · 06 M4-9 · 01 §12-1 · §10-8 · §4-2).
//
// 🔴 정본 원장(`ledger*.sqlite`) **밖** 별도 파일이다 — 계열(`RunModeIsSim.isSim`)마다 파일 하나(`device_local_sim.sqlite` ·
//    `device_local_live.sqlite`). 원장은 단일 쓰기 주체이고 M4-5 DB 백업 · X1 사본 이동 대상이라 여기에 섞지 않는다(의무 ①).
// 🔴 값은 전부 `SealedBox` 로 봉한다(aad = 판 · 계열 · 이름공간 · 키) — 평문 칸은 이름공간 · 키 · 계열 · 연결 명령 id · 순번뿐.
//    실물 봉함(Keystore 로 감싼 DEK + AES-GCM) = `app_operator_android` 어댑터(E11p). 여기는 순수 Dart 다(06 M4-9 ④).
// 🔴 초안 · 큐 · 종단 기록의 읽기 · 쓰기는 **한 사슬**(부른 순서)로 돈다 — `clear` 는 앞의 모든 `save` 뒤(의무 ⑤).
// 🔴 동기로 던지지 않는다 — 모든 실패는 반환 `Future` 의 에러다(의무 ⑩). 에러 · 보고에 본문 값 · 키 · 경로를 싣지 않는다(의무 ③).
// 🔴 이 저장소는 기기 밖으로 나가지 않는다(Supabase · GitHub · DB 백업 · OS 백업 · 로그 — 의무 ③ · §12-1-5).

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart' show SealedBox;
import 'package:sqlite3/sqlite3.dart';

/// 저장소 실패 종류.
enum DeviceStoreErrorKind {
  /// 파일을 열 수 없다.
  openFailed,

  /// 읽기 실패.
  readFailed,

  /// 쓰기 · 봉함 실패.
  writeFailed,

  /// 닫힌 뒤 불렀다.
  closed,
}

/// 저장소 실패 — 🔴 SQLite 메시지 · 경로 · 본문 값 없음(종류만).
class DeviceStoreError implements Exception {
  /// 실패를 만든다.
  const DeviceStoreError(this.kind);

  /// 종류.
  final DeviceStoreErrorKind kind;

  @override
  String toString() => 'DeviceStoreError(${kind.name})';
}

/// 해독 실패 종류(의무 ⑥ — 값 없는 내부 보고).
enum DeviceStoreFaultKind {
  /// 봉함을 열 수 없다(키 소실 · 변조 · aad 다름).
  sealOpenFailed,

  /// JSON · 모양 해독 실패(앱 업데이트로 모양이 달라진 경우 포함).
  decodeFailed,

  /// 행의 계열 태그가 파일 계열과 다르다.
  familyMismatch,

  /// 풀린 값의 키가 찾은 키와 다르다.
  keyMismatch,
}

/// 해독 실패 보고 — 🔴 종류 · 이름공간만(키 · 값 0).
class DeviceStoreFault {
  /// 보고를 만든다.
  const DeviceStoreFault(this.kind, this.namespace);

  /// 종류.
  final DeviceStoreFaultKind kind;

  /// 이름공간(`draft` · `cmdq` · `cmdt`).
  final String namespace;

  @override
  bool operator ==(Object other) =>
      other is DeviceStoreFault &&
      other.kind == kind &&
      other.namespace == namespace;

  @override
  int get hashCode => Object.hash(kind, namespace);

  @override
  String toString() => 'DeviceStoreFault(${kind.name} · $namespace)';
}

/// 이름공간(R46 G2).
abstract final class DeviceNamespace {
  /// 입력 초안.
  static const String draft = 'draft';

  /// 큐 ⓐ — 종단 전 명령.
  static const String queue = 'cmdq';

  /// 종단 기록 · 로컬 거부 접수증.
  static const String terminal = 'cmdt';
}

/// 계열 이름.
String familyName({required bool isSim}) => isSim ? 'sim' : 'live';

/// 계열 파일 이름 — 🔴 `ledger` 로 시작하지 않는다(의무 ①).
String deviceLocalFileName({required bool isSim}) =>
    'device_local_${familyName(isSim: isSim)}.sqlite';

/// aad — 판 · 계열 · 이름공간 · 키를 묶는다(다른 자리의 봉함을 옮겨 붙이면 열리지 않는다).
String deviceLocalAad(String family, String namespace, String key) =>
    'aaq.device.v1|$family|$namespace|$key';

/// 행 하나(평문 칸 + 봉함).
class SealedRow {
  /// 행을 만든다.
  const SealedRow({
    required this.key,
    required this.family,
    required this.body,
    required this.seq,
    this.linkedCommandId,
  });

  /// 키.
  final String key;

  /// 계열 태그.
  final String family;

  /// 봉함.
  final Uint8List body;

  /// 순번(적재 순).
  final int seq;

  /// 연결 명령 id(초안).
  final String? linkedCommandId;
}

/// 계열 파일 하나(SQLite) — 동기 · 이 파일 밖에서는 [DeviceLocal] 사슬 안에서만 부른다.
class DeviceFamilyFile {
  DeviceFamilyFile._(this.family, this._db);

  /// [directory] 에서 [isSim] 계열 파일을 연다(없으면 만든다).
  static DeviceFamilyFile open(String directory, {required bool isSim}) {
    final String name = deviceLocalFileName(isSim: isSim);
    if (name.toLowerCase().startsWith('ledger')) {
      throw const DeviceStoreError(DeviceStoreErrorKind.openFailed);
    }
    try {
      Directory(directory).createSync(recursive: true);
      final Database db = sqlite3.open(
        '$directory${Platform.pathSeparator}$name',
      );
      db.execute('PRAGMA journal_mode = WAL');
      db.execute('PRAGMA synchronous = FULL');
      db.execute('''
CREATE TABLE IF NOT EXISTS sealed_item(
  ns TEXT NOT NULL,
  item_key TEXT NOT NULL,
  family TEXT NOT NULL,
  linked_command_id TEXT,
  seq INTEGER NOT NULL,
  body BLOB NOT NULL,
  PRIMARY KEY (ns, item_key)
)''');
      db.execute(
        'CREATE INDEX IF NOT EXISTS sealed_item_link ON sealed_item(ns, linked_command_id)',
      );
      return DeviceFamilyFile._(familyName(isSim: isSim), db);
    } on DeviceStoreError {
      rethrow;
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.openFailed);
    }
  }

  /// 계열 이름.
  final String family;
  final Database _db;
  bool _closed = false;

  void _live() {
    if (_closed) throw const DeviceStoreError(DeviceStoreErrorKind.closed);
  }

  SealedRow _row(Row r) => SealedRow(
    key: r['item_key'] as String,
    family: r['family'] as String,
    body: Uint8List.fromList(r['body'] as List<int>),
    seq: r['seq'] as int,
    linkedCommandId: r['linked_command_id'] as String?,
  );

  int _nextSeq() =>
      _db
              .select('SELECT COALESCE(MAX(seq), 0) + 1 AS n FROM sealed_item')
              .first['n']
          as int;

  /// 한 행(없으면 null).
  SealedRow? get(String ns, String key) {
    _live();
    try {
      final ResultSet rs = _db.select(
        'SELECT * FROM sealed_item WHERE ns = ? AND item_key = ?',
        <Object?>[ns, key],
      );
      return rs.isEmpty ? null : _row(rs.first);
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.readFailed);
    }
  }

  /// 이름공간의 행 전부(적재 순).
  List<SealedRow> all(String ns) {
    _live();
    try {
      return <SealedRow>[
        for (final Row r in _db.select(
          'SELECT * FROM sealed_item WHERE ns = ? ORDER BY seq',
          <Object?>[ns],
        ))
          _row(r),
      ];
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.readFailed);
    }
  }

  /// 연결 명령 id 가 [commandId] 인 행의 키.
  List<String> keysLinkedTo(String ns, String commandId) {
    _live();
    try {
      return <String>[
        for (final Row r in _db.select(
          'SELECT item_key FROM sealed_item WHERE ns = ? AND linked_command_id = ? ORDER BY seq',
          <Object?>[ns, commandId],
        ))
          r['item_key'] as String,
      ];
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.readFailed);
    }
  }

  /// 같은 키 통째 교체(트랜잭션 1회 = 확정).
  void put(String ns, String key, Uint8List body, {String? linkedCommandId}) {
    _live();
    try {
      _db.execute('BEGIN IMMEDIATE');
      try {
        final int seq = _nextSeq();
        _db.execute(
          'INSERT OR REPLACE INTO sealed_item(ns, item_key, family, linked_command_id, seq, body) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[ns, key, family, linkedCommandId, seq, body],
        );
        _db.execute('COMMIT');
      } on Object {
        _db.execute('ROLLBACK');
        rethrow;
      }
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.writeFailed);
    }
  }

  /// 행을 지운다(없어도 성공).
  void delete(String ns, String key) {
    _live();
    try {
      _db.execute(
        'DELETE FROM sealed_item WHERE ns = ? AND item_key = ?',
        <Object?>[ns, key],
      );
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.writeFailed);
    }
  }

  /// [from] 의 행을 [to] 로 옮긴다(한 트랜잭션 · 연결 id 는 [to] 에서 비운다).
  void move(String from, String to, String key, Uint8List body) {
    _live();
    try {
      _db.execute('BEGIN IMMEDIATE');
      try {
        final int seq = _nextSeq();
        _db.execute(
          'DELETE FROM sealed_item WHERE ns = ? AND item_key = ?',
          <Object?>[from, key],
        );
        _db.execute(
          'INSERT OR REPLACE INTO sealed_item(ns, item_key, family, linked_command_id, seq, body) '
          'VALUES (?, ?, ?, NULL, ?, ?)',
          <Object?>[to, key, family, seq, body],
        );
        _db.execute('COMMIT');
      } on Object {
        _db.execute('ROLLBACK');
        rethrow;
      }
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.writeFailed);
    }
  }

  /// 이름공간을 통째로 지운다.
  void deleteNamespace(String ns) {
    _live();
    try {
      _db.execute('DELETE FROM sealed_item WHERE ns = ?', <Object?>[ns]);
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.writeFailed);
    }
  }

  /// 닫는다.
  void close() {
    if (_closed) return;
    _closed = true;
    _db.close();
  }
}

/// 기기 로컬 저장소 — 계열 파일 둘 · 한 사슬 · 봉함 · 보고(R46 G1~G6).
class DeviceLocal {
  DeviceLocal._(this._sim, this._live, this._box, this._isSim, this._onFault);

  /// [directory] 에서 연다 — [isSim] 은 부를 때마다 묻는다(현재 계열) · [onFault] = 해독 실패 보고(값 0).
  static DeviceLocal open({
    required String directory,
    required SealedBox box,
    required bool Function() isSim,
    void Function(DeviceStoreFault fault)? onFault,
  }) {
    final DeviceFamilyFile sim = DeviceFamilyFile.open(directory, isSim: true);
    final DeviceFamilyFile live;
    try {
      live = DeviceFamilyFile.open(directory, isSim: false);
    } on Object {
      sim.close();
      rethrow;
    }
    return DeviceLocal._(sim, live, box, isSim, onFault);
  }

  final DeviceFamilyFile _sim;
  final DeviceFamilyFile _live;
  final SealedBox _box;
  final bool Function() _isSim;
  final void Function(DeviceStoreFault fault)? _onFault;
  Future<void> _tail = Future<void>.value();

  /// 지금 계열의 파일.
  DeviceFamilyFile get current => _isSim() ? _sim : _live;

  /// SIM 계열 파일.
  DeviceFamilyFile get simFile => _sim;

  /// 한 사슬에 올린다 — 🔴 동기로 던지지 않는다(앞 작업의 실패는 뒤 작업을 막지 않는다).
  Future<T> run<T>(FutureOr<T> Function() op) {
    final Future<T> result = _tail.then((_) => op());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// 봉한다.
  Future<Uint8List> seal(
    DeviceFamilyFile f,
    String ns,
    String key,
    Object json,
  ) async {
    try {
      return await _box.seal(
        Uint8List.fromList(utf8.encode(jsonEncode(json))),
        aad: deviceLocalAad(f.family, ns, key),
      );
    } on Object {
      throw const DeviceStoreError(DeviceStoreErrorKind.writeFailed);
    }
  }

  /// 행을 풀어 JSON 지도로(실패 = null + 보고).
  Future<Map<String, Object?>?> unseal(
    DeviceFamilyFile f,
    String ns,
    SealedRow row,
  ) async {
    if (row.family != f.family) {
      report(DeviceStoreFault(DeviceStoreFaultKind.familyMismatch, ns));
      return null;
    }
    Uint8List? plain;
    try {
      plain = await _box.open(
        row.body,
        aad: deviceLocalAad(f.family, ns, row.key),
      );
    } on Object {
      plain = null;
    }
    if (plain == null) {
      report(DeviceStoreFault(DeviceStoreFaultKind.sealOpenFailed, ns));
      return null;
    }
    try {
      final Object? v = jsonDecode(utf8.decode(plain));
      if (v is Map<String, Object?>) return v;
    } on FormatException {
      // 아래에서 보고.
    }
    report(DeviceStoreFault(DeviceStoreFaultKind.decodeFailed, ns));
    return null;
  }

  /// 해독 실패 보고(값 0) — 보고기가 던져도 삼킨다(보고가 저장소를 막지 않게).
  void report(DeviceStoreFault fault) {
    try {
      _onFault?.call(fault);
    } on Object {
      // 보고 실패는 무시.
    }
  }

  /// 닫는다(밀린 작업 뒤).
  Future<void> close() => run<void>(() {
    _sim.close();
    _live.close();
  });
}
