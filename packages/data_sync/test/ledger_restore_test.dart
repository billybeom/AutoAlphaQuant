// E16t3a — X1-4 새 폰 복원 적용(설계 13 §8 R145 Y2~Y7).
//
// 🔵 잡는 것: ① 검증된 스냅숏 = live 자리에 같은 바이트 · `.partial` 0 · 사본 0 · 열면 원장 그대로 · 복구 저널 시작 가능
//    ② live 본 파일 · `-wal` · `-shm` · `-journal` 하나라도 있으면 `X1_LIVE_EXISTS`(덮어쓰기 0)
//    ③ 검증 거부(아카이브 없음 · 바이트 바뀜) · 스냅숏 파일 없음 = 그 코드 · 원장 0.
import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/ledger_golden.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);

List<String> _ls(Directory d) => <String>[
  for (final FileSystemEntity e in d.listSync()) e.uri.pathSegments.last,
]..sort();

void main() {
  late Directory dir;
  late Directory oldDir;
  late Directory newDir;
  late Directory scratch;
  late Database old;
  late LedgerArchiveWriter writer;
  late LedgerSnapshot snap;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rst_');
    oldDir = Directory('${dir.path}/old')..createSync();
    newDir = Directory('${dir.path}/new')..createSync();
    scratch = Directory('${dir.path}/scratch')..createSync();
    final Directory backups = Directory('${dir.path}/backups')..createSync();
    final Directory root = Directory('${dir.path}/repo')..createSync();
    final _Clock clock = _Clock(_t0);
    old = openLocalLedger(oldDir.path, RunMode.live, clock: () => _t0);
    loadLedgerGolden(old);
    LedgerHashStamper(old, clock: clock).stampThrough('2026-11-04');
    writer = LedgerArchiveWriter(
      old,
      root: root.path,
      mode: RunMode.live,
      clock: clock,
      writerDeviceId: 'dev-old',
      operatorEpoch: 0,
    );
    writer.archiveStamped();
    snap = SqliteLedgerSnapshotter(old, deviceId: 'dev-old', operatorEpoch: 0)
        .take(
          backups,
          'mig-1',
          archive: writer.readCheckpoint(),
          scratch: scratch,
        )
        .snapshot!;
  });
  tearDown(() {
    old.close();
    dir.deleteSync(recursive: true);
  });

  LedgerRestoreResult restore({
    ArchiveCheckpoint? archive,
    bool noArchive = false,
  }) => restoreLiveLedger(
    snap,
    ledgerDir: newDir.path,
    archive: noArchive ? null : (archive ?? writer.readCheckpoint()),
    scratch: scratch,
  );

  final String live = LedgerFile.live.fileName;

  test('🔴 검증된 스냅숏 = live 자리에 같은 바이트 · 찌꺼기 0 · 열면 원장 그대로 · 복구 저널 시작', () {
    final LedgerRestoreResult r = restore();
    expect(r.rejectCode, isNull);
    expect(r.verdict!.ok, isTrue);
    expect(r.livePath, '${newDir.path}/$live');
    expect(_ls(newDir), <String>[live]);
    expect(_ls(scratch), isEmpty);
    expect(File(r.livePath!).readAsBytesSync(), snap.file.readAsBytesSync());
    final Database db = openLocalLedger(
      newDir.path,
      RunMode.live,
      clock: () => _t0,
    );
    addTearDown(db.close);
    for (final String t in <String>['ledger_daily_hash', 'decision_log']) {
      expect(
        db.select('SELECT COUNT(*) AS n FROM $t').single['n'],
        old.select('SELECT COUNT(*) AS n FROM $t').single['n'],
        reason: t,
      );
    }
    expect(
      SqliteRecoveryJournal(db, deviceId: 'dev-new', trusted: _Trusted(_t0))
          .start(
            kind: MigrationKind.plan,
            operatingMode: OperatingMode.autoTrade,
            decisionId: 'd-03',
            operatorEpoch: 1,
            manifest: snap.manifest,
          )
          .rejectCode,
      isNull,
    );
  });

  test(
    '🔴 live 본 파일 · -wal · -shm · -journal 하나라도 = X1_LIVE_EXISTS · 덮어쓰기 0',
    () {
      for (final String s in <String>['', '-wal', '-shm', '-journal']) {
        final File f = File('${newDir.path}/$live$s')..writeAsStringSync('옛 것');
        final LedgerRestoreResult r = restore();
        expect(r.rejectCode, 'X1_LIVE_EXISTS', reason: s);
        expect(r.verdict, isNull);
        expect(r.livePath, isNull);
        expect(f.readAsStringSync(), '옛 것');
        expect(_ls(newDir), <String>['$live$s']);
        f.deleteSync();
      }
    },
  );

  test('검증 거부(아카이브 없음 = RESTORE_ROLLBACK) = 원장 0 · .partial 0', () {
    final LedgerRestoreResult r = restore(noArchive: true);
    expect(r.rejectCode, 'RESTORE_ROLLBACK');
    expect(r.verdict!.archiveRelation, DerivedRelation.empty);
    expect(r.livePath, isNull);
    expect(_ls(newDir), isEmpty);
  });

  test('스냅숏 바이트 바뀜 = RESTORE_SHA_MISMATCH · 파일 없음 = RESTORE_UNREADABLE', () {
    final Uint8List b = snap.file.readAsBytesSync();
    b[b.length - 1] ^= 0x01;
    snap.file.writeAsBytesSync(b);
    expect(restore().rejectCode, 'RESTORE_SHA_MISMATCH');
    snap.file.deleteSync();
    final LedgerRestoreResult r = restore();
    expect(r.rejectCode, 'RESTORE_UNREADABLE');
    expect(r.verdict!.reason, RestoreReason.unreadable);
    expect(_ls(newDir), isEmpty);
  });
}
