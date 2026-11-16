// X1-2 백업 스냅숏 · 매니페스트 · 복원 검증 4중(설계 13 §8 R135 P3~P6 · SPEC v2.45 04 §3-1 ⑧ · 앱 06 X1-2).
//
// 🔴 스냅숏 = `VACUUM INTO`(트랜잭션 밖만) · live 원장만 · 스탬프 0 = 거부 · 이름 = 부르는 쪽 ·
//    매니페스트가 이미 있으면 덮지 않는다(`SNAPSHOT_EXISTS`) · 매니페스트 없는 스냅숏 · `.partial` = 찌꺼기 → 지우고 다시.
// 🔴 매니페스트 = 만든 자리에서 복원 검증을 **다** 통과한 스냅숏에만(DEMOTED 는 되돌릴 수 없다) · 값은 스냅숏 사본에서 읽는다.
// 🔴 검증 = 바이트를 한 번 읽어 sha256 → **같은 바이트**를 scratch 사본에 써서 읽기 전용으로 연다(원본은 열지 않는다) ·
//    끝나면 사본(`-journal` · `-wal` · `-shm` 포함)을 지운다 · 읽다가 무엇이든 던지면 = 읽을 수 없음(fail-closed).
// 🔴 사본에 `LedgerIntegrityCheck.run` 을 쓰지 않는다(`reconciliation_log` · 플래그를 쓴다) — 체인 = `ledgerChainVerdictOf`.
// 🟡 올리기 = ⬜ `backup_upload: false`(로컬만) · 티켓 · 새 폰 적용 = E16h · E16t.

import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:domain_contracts/domain_contracts.dart'
    show LedgerFile, schemaVersion;
import 'package:sqlite3/sqlite3.dart';

import '../local/derived_sync_store.dart' show canonChainOf, storedDayStampsOf;
import '../local/ledger_integrity_check.dart'
    show ledgerChainVerdictOf, sqliteIntegrityLines;

final RegExp _name = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,95}$');

String _checkName(String name) {
  if (!_name.hasMatch(name)) {
    throw ArgumentError.value(name, 'name', '스냅숏 이름 꼴(영숫자 · _ · -)');
  }
  return name;
}

/// [dir] 의 [name] 스냅숏 파일.
File snapshotFileOf(Directory dir, String name) =>
    File('${dir.path}/${_checkName(name)}.sqlite');

/// [dir] 의 [name] 매니페스트 파일.
File manifestFileOf(Directory dir, String name) =>
    File('${dir.path}/${_checkName(name)}.manifest.json');

/// 스냅숏 한 벌.
class LedgerSnapshot {
  /// 만든다.
  const LedgerSnapshot({
    required this.file,
    required this.manifestFile,
    required this.manifest,
  });

  /// 스냅숏 파일.
  final File file;

  /// 매니페스트 파일.
  final File manifestFile;

  /// 매니페스트.
  final BackupManifest manifest;
}

/// 스냅숏 만들기 결과 — 통과 = [snapshot] · 거부 = [rejectCode](복원 판정 거부면 [verdict] 도).
typedef SnapshotTakeResult = ({
  LedgerSnapshot? snapshot,
  String? rejectCode,
  RestoreVerdict? verdict,
});

// 사본 탐침(읽기 전용 연결) — 판정이 묻는 차례대로만 읽는다.
class _SqliteSnapshotProbe implements SnapshotProbe {
  _SqliteSnapshotProbe(this._db, this._archive, this._pragma);

  final Database _db;
  final ArchiveCheckpoint? _archive;
  final List<String> Function(Database db) _pragma;

  @override
  bool get live =>
      _db.select('PRAGMA application_id').first.values.first ==
      LedgerFile.live.applicationId;

  @override
  int get schemaVersion {
    final bool has = _db
        .select(
          "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'schema_version'",
        )
        .isNotEmpty;
    if (!has) return 0;
    return (_db
                .select('SELECT max(version) AS v FROM schema_version')
                .first['v']
            as int?) ??
        0;
  }

  @override
  List<String> get sqliteIntegrity => _pragma(_db);

  @override
  LedgerIntegrityVerdict get chain => ledgerChainVerdictOf(_db);

  @override
  StoredDayStamp? get head {
    final List<StoredDayStamp> s = storedDayStampsOf(_db);
    return s.isEmpty ? null : s.last;
  }

  @override
  DerivedRelation archiveRelation(int operatorEpoch) => derivedRelationOf(
    canonChainOf(_db, operatorEpoch: operatorEpoch),
    _archive == null ? null : DerivedStamp.fromCheckpoint(_archive),
  );
}

void _deleteIfExists(String path) {
  final File f = File(path);
  if (f.existsSync()) f.deleteSync();
}

// [bytes] 를 [scratch] 사본에 써서 읽기 전용으로 열고 [use] 를 부른다(못 열면 null) — 끝나면 사본을 지운다.
T _withCopy<T>(
  Uint8List bytes,
  Directory scratch,
  String digest,
  T Function(Database? db) use,
) {
  final String path =
      '${scratch.path}/.verify-${digest.substring(0, 16)}.sqlite';
  final List<String> trash = <String>[
    path,
    '$path-journal',
    '$path-wal',
    '$path-shm',
  ];
  Database? db;
  try {
    trash.forEach(_deleteIfExists);
    File(path).writeAsBytesSync(bytes, flush: true);
    db = sqlite3.open(path, mode: OpenMode.readOnly);
  } on Object {
    db = null;
  }
  try {
    return use(db);
  } finally {
    db?.close();
    trash.forEach(_deleteIfExists);
  }
}

// 사본 판정 — 읽다가 던지면 = 읽을 수 없음.
RestoreVerdict _verdictOn(
  Database? db,
  BackupManifest manifest,
  String digest,
  ArchiveCheckpoint? archive,
  List<String> Function(Database db) pragma,
) {
  try {
    return restoreVerdictOf(
      manifest: manifest,
      sha256: digest,
      probe: db == null ? null : _SqliteSnapshotProbe(db, archive, pragma),
      appSchemaVersion: schemaVersion,
    );
  } on Object {
    return const RestoreVerdict.failed(RestoreReason.unreadable);
  }
}

/// 🔴 복원 검증 4중(바이트) — sha ∧ `integrity_check` ∧ 체인 ∧ 아카이브 체크포인트(IN_SYNC) · 앞에 파일 꼴 · 매니페스트 머리.
///
/// [archive] = 아카이브 체크포인트(없음 = EMPTY = 거부) · [scratch] = 사본 자리(있어야 한다 · 없으면 읽을 수 없음).
RestoreVerdict verifySnapshotBytes(
  Uint8List bytes,
  BackupManifest manifest, {
  required ArchiveCheckpoint? archive,
  required Directory scratch,
  List<String> Function(Database db)? sqliteIntegrity,
}) {
  final String digest = crypto.sha256.convert(bytes).toString();
  return _withCopy(
    bytes,
    scratch,
    digest,
    (Database? db) => _verdictOn(
      db,
      manifest,
      digest,
      archive,
      sqliteIntegrity ?? sqliteIntegrityLines,
    ),
  );
}

/// 복원 검증(스냅숏 한 벌) — 스냅숏 파일을 못 읽으면 = 읽을 수 없음.
RestoreVerdict verifyLedgerSnapshot(
  LedgerSnapshot snapshot, {
  required ArchiveCheckpoint? archive,
  required Directory scratch,
  List<String> Function(Database db)? sqliteIntegrity,
}) {
  final Uint8List bytes;
  try {
    bytes = snapshot.file.readAsBytesSync();
  } on FileSystemException {
    return const RestoreVerdict.failed(RestoreReason.unreadable);
  }
  return verifySnapshotBytes(
    bytes,
    snapshot.manifest,
    archive: archive,
    scratch: scratch,
    sqliteIntegrity: sqliteIntegrity,
  );
}

/// [dir] 의 [name] 스냅숏(매니페스트 없음 = null · 매니페스트가 틀리면 [FormatException]).
LedgerSnapshot? readLedgerSnapshot(Directory dir, String name) {
  final File man = manifestFileOf(dir, name);
  if (!man.existsSync()) return null;
  return LedgerSnapshot(
    file: snapshotFileOf(dir, name),
    manifestFile: man,
    manifest: BackupManifest.parse(man.readAsStringSync()),
  );
}

/// 옛 폰 백업 스냅숏(live 원장).
class SqliteLedgerSnapshotter {
  /// 만든다 — [sqliteIntegrity] = 시험 주입(기본 = `PRAGMA integrity_check`).
  SqliteLedgerSnapshotter(
    this._db, {
    required this.deviceId,
    required this.operatorEpoch,
    List<String> Function(Database db)? sqliteIntegrity,
  }) : _pragma = sqliteIntegrity ?? sqliteIntegrityLines;

  final Database _db;
  final List<String> Function(Database db) _pragma;

  /// 이 기기(매니페스트 `writer_device_id`).
  final String deviceId;

  /// 이 기기 epoch(매니페스트 `operator_epoch` · 아카이브 관계의 epoch).
  final int operatorEpoch;

  /// 🔴 스냅숏을 만든다 — 차례: live → 스탬프 → 매니페스트 있음 → `VACUUM INTO` → 사본 복원 검증 → 파일 · 매니페스트.
  ///
  /// [dir] · [scratch] 는 있어야 한다 · 트랜잭션 안이면 [StateError] · [archive] = 지금 아카이브 체크포인트.
  SnapshotTakeResult take(
    Directory dir,
    String name, {
    required ArchiveCheckpoint? archive,
    required Directory scratch,
  }) {
    if (!_db.autocommit) {
      throw StateError('스냅숏은 트랜잭션 밖에서만(VACUUM INTO)');
    }
    final File snap = snapshotFileOf(dir, name);
    final File man = manifestFileOf(dir, name);
    if (_db.select('PRAGMA application_id').first.values.first !=
        LedgerFile.live.applicationId) {
      return (
        snapshot: null,
        rejectCode: MigrationStartCodes.liveOnly,
        verdict: null,
      );
    }
    if (_db.select('SELECT 1 FROM ledger_daily_hash LIMIT 1').isEmpty) {
      return (snapshot: null, rejectCode: SnapshotCodes.noStamp, verdict: null);
    }
    if (man.existsSync()) {
      return (snapshot: null, rejectCode: SnapshotCodes.exists, verdict: null);
    }
    final String partial = '${snap.path}.partial';
    final String manPartial = '${man.path}.partial';
    for (final String p in <String>[partial, snap.path, manPartial]) {
      _deleteIfExists(p);
    }
    bool kept = false;
    try {
      _db.execute('VACUUM INTO ?', <Object?>[partial]);
      final Uint8List bytes = File(partial).readAsBytesSync();
      final String digest = crypto.sha256.convert(bytes).toString();
      final (
        BackupManifest? m,
        RestoreVerdict v,
      ) = _withCopy(bytes, scratch, digest, (Database? db) {
        final BackupManifest? m;
        try {
          m = db == null ? null : _manifestOf(db, digest);
        } on Object {
          return (null, const RestoreVerdict.failed(RestoreReason.unreadable));
        }
        if (m == null) {
          return (null, const RestoreVerdict.failed(RestoreReason.unreadable));
        }
        return (m, _verdictOn(db, m, digest, archive, _pragma));
      });
      if (m == null || !v.ok) {
        return (snapshot: null, rejectCode: v.code, verdict: v);
      }
      File(partial).renameSync(snap.path);
      kept = true;
      File(manPartial).writeAsStringSync(m.toCanonicalJson(), flush: true);
      File(manPartial).renameSync(man.path);
      return (
        snapshot: LedgerSnapshot(file: snap, manifestFile: man, manifest: m),
        rejectCode: null,
        verdict: v,
      );
    } finally {
      if (!kept) _deleteIfExists(partial);
    }
  }

  // 사본 머리로 매니페스트(스탬프 없음 = null).
  BackupManifest? _manifestOf(Database db, String digest) {
    final _SqliteSnapshotProbe p = _SqliteSnapshotProbe(db, null, _pragma);
    final StoredDayStamp? head = p.head;
    if (head == null) return null;
    return BackupManifest(
      sha256: digest,
      chainHash: head.chainHash,
      authoredDate: head.authoredDate,
      schemaVersion: p.schemaVersion,
      hashFormatVersion: head.hashFormatVersion,
      operatorEpoch: operatorEpoch,
      writerDeviceId: deviceId,
    );
  }
}
