// E16g2 — X1-2 백업 스냅숏 · 매니페스트 · 복원 검증 4중 · 이전 단계 사실(설계 13 §8 R135 P1~P9).
//
// 🔵 잡는 것: ① 스냅숏 = `VACUUM INTO` · 매니페스트 7키 = 사본 머리 · 파일 sha 독립 계산 · 찌꺼기 없음 · 원본 바이트 불변
//    ② 거부 차례(트랜잭션 · live · 스탬프 · 이미 있음) · 🔴 만든 자리 검증 실패 = 매니페스트 없음(아카이브 EMPTY · BEHIND ·
//    PRAGMA · 체인 · scratch 없음) · 찌꺼기 지우고 다시 ③ 복원 검증 — sha · 열 수 없음 · live · schema · 매니페스트 머리 ·
//    아카이브 AHEAD · EPOCH_AHEAD ④ 체인 판정 분리(기록 0) ⑤ 단계 사실(미체결 4상태 · UNKNOWN · 대사 · 체인 · 백업).
import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart' show sha256;
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

// 2026-11-04T21:30Z = 한국 11-05 06:30 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);

List<String> _ls(Directory d) => <String>[
  for (final FileSystemEntity e in d.listSync()) e.uri.pathSegments.last,
]..sort();

void main() {
  late Directory dir;
  late Directory root;
  late Directory backups;
  late Directory scratch;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_snap_');
    root = Directory('${dir.path}/repo')..createSync();
    backups = Directory('${dir.path}/backups')..createSync();
    scratch = Directory('${dir.path}/scratch')..createSync();
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  LedgerArchiveWriter writer({int epoch = 0}) => LedgerArchiveWriter(
    db,
    root: root.path,
    mode: RunMode.live,
    clock: clock,
    writerDeviceId: 'dev-old',
    operatorEpoch: epoch,
  );

  SqliteLedgerSnapshotter snapper({
    int epoch = 0,
    List<String> Function(Database db)? pragma,
  }) => SqliteLedgerSnapshotter(
    db,
    deviceId: 'dev-old',
    operatorEpoch: epoch,
    sqliteIntegrity: pragma,
  );

  /// 골든 · [through] 까지 스탬프 · 아카이브.
  void archived({String through = '2026-11-04'}) {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough(through);
    writer().archiveStamped();
  }

  String lastChain() =>
      db
              .select(
                'SELECT chain_hash FROM ledger_daily_hash ORDER BY authored_date DESC LIMIT 1',
              )
              .single['chain_hash']
          as String;

  SnapshotTakeResult take({
    String name = 'mig-20261105-1',
    ArchiveCheckpoint? archive,
    bool noArchive = false,
    Directory? scratchDir,
    SqliteLedgerSnapshotter? s,
  }) => (s ?? snapper()).take(
    backups,
    name,
    archive: noArchive ? null : (archive ?? writer().readCheckpoint()),
    scratch: scratchDir ?? scratch,
  );

  group('SqliteLedgerSnapshotter.take — 만들기', () {
    test('🔴 스냅숏 + 매니페스트 7키 = 사본 머리 · sha 독립 계산 · 찌꺼기 0 · 검증 통과', () {
      archived();
      final SnapshotTakeResult r = take(s: snapper(epoch: 0));
      expect(r.rejectCode, isNull);
      expect(r.verdict!.ok, isTrue);
      final LedgerSnapshot s = r.snapshot!;
      expect(_ls(backups), <String>[
        'mig-20261105-1.manifest.json',
        'mig-20261105-1.sqlite',
      ]);
      expect(_ls(scratch), isEmpty);
      final Uint8List bytes = s.file.readAsBytesSync();
      final BackupManifest m = s.manifest;
      expect(m.sha256, sha256.convert(bytes).toString());
      expect(m.chainHash, lastChain());
      expect(m.authoredDate, '2026-11-04');
      expect(m.schemaVersion, 1);
      expect(m.hashFormatVersion, 1);
      expect(m.operatorEpoch, 0);
      expect(m.writerDeviceId, 'dev-old');
      expect(s.manifestFile.readAsStringSync(), m.toCanonicalJson());
      // 스냅숏 = live 원장 그대로(행 수).
      final Database snap = sqlite3.open(s.file.path, mode: OpenMode.readOnly);
      addTearDown(snap.close);
      for (final String t in <String>[
        'decision_log',
        'ledger_daily_hash',
        'order_intents',
      ]) {
        expect(
          snap.select('SELECT COUNT(*) AS n FROM $t').single['n'],
          db.select('SELECT COUNT(*) AS n FROM $t').single['n'],
          reason: t,
        );
      }
      // 되읽기 · 복원 검증 · 원본 바이트 불변(원본을 열지 않는다).
      final LedgerSnapshot back = readLedgerSnapshot(
        backups,
        'mig-20261105-1',
      )!;
      expect(back.manifest.toCanonicalJson(), m.toCanonicalJson());
      expect(back.file.path, s.file.path);
      final RestoreVerdict v = verifyLedgerSnapshot(
        back,
        archive: writer().readCheckpoint(),
        scratch: scratch,
      );
      expect(v.ok, isTrue);
      expect(s.file.readAsBytesSync(), bytes);
      expect(_ls(scratch), isEmpty);
      expect(readLedgerSnapshot(backups, 'other'), isNull);
    });

    test('epoch · 기기 = 넘긴 값(아카이브 epoch 와 같아야 IN_SYNC)', () {
      archived();
      final SnapshotTakeResult r = take(s: snapper(epoch: 2));
      // 아카이브 epoch(0) < 매니페스트 epoch(2) = IN_SYNC — EPOCH_AHEAD 는 «아카이브 > 매니페스트» 만.
      expect(r.snapshot!.manifest.operatorEpoch, 2);
      expect(r.verdict!.ok, isTrue);
    });

    test('트랜잭션 안 = StateError · 파일 0', () {
      archived();
      db.execute('BEGIN');
      expect(take, throwsStateError);
      db.execute('ROLLBACK');
      expect(_ls(backups), isEmpty);
    });

    test('live 아님 = X1_LIVE_ONLY(스탬프 검사보다 먼저 · 파일 0)', () {
      final Database sim = openLocalLedger(
        (Directory('${dir.path}/simdir')..createSync()).path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sim.close);
      final SnapshotTakeResult r = SqliteLedgerSnapshotter(
        sim,
        deviceId: 'dev-old',
        operatorEpoch: 0,
      ).take(backups, 'mig-x', archive: null, scratch: scratch);
      expect(r.rejectCode, 'X1_LIVE_ONLY');
      expect(r.snapshot, isNull);
      expect(r.verdict, isNull);
      expect(_ls(backups), isEmpty);
    });

    test('스탬프 0 = SNAPSHOT_NO_STAMP · 파일 0', () {
      final SnapshotTakeResult r = take(noArchive: true);
      expect(r.rejectCode, 'SNAPSHOT_NO_STAMP');
      expect(r.verdict, isNull);
      expect(_ls(backups), isEmpty);
      expect(_ls(scratch), isEmpty);
    });

    test('매니페스트가 이미 있으면 SNAPSHOT_EXISTS · 덮지 않는다', () {
      archived();
      final LedgerSnapshot first = take().snapshot!;
      final Uint8List bytes = first.file.readAsBytesSync();
      final String man = first.manifestFile.readAsStringSync();
      final SnapshotTakeResult r = take();
      expect(r.rejectCode, 'SNAPSHOT_EXISTS');
      expect(r.snapshot, isNull);
      expect(first.file.readAsBytesSync(), bytes);
      expect(first.manifestFile.readAsStringSync(), man);
    });

    test('찌꺼기(매니페스트 없는 스냅숏 · .partial) = 지우고 다시', () {
      archived();
      File('${backups.path}/mig-20261105-1.sqlite').writeAsStringSync('옛 찌꺼기');
      File('${backups.path}/mig-20261105-1.sqlite.partial')
          .writeAsStringSync('반쯤');
      File('${backups.path}/mig-20261105-1.manifest.json.partial')
          .writeAsStringSync('반쯤');
      final SnapshotTakeResult r = take();
      expect(r.rejectCode, isNull);
      expect(_ls(backups), <String>[
        'mig-20261105-1.manifest.json',
        'mig-20261105-1.sqlite',
      ]);
      expect(
        r.snapshot!.manifest.sha256,
        sha256.convert(r.snapshot!.file.readAsBytesSync()).toString(),
      );
    });

    test('🔴 아카이브 없음(EMPTY) = RESTORE_ROLLBACK · 매니페스트 0 · 찌꺼기 0', () {
      archived();
      final SnapshotTakeResult r = take(noArchive: true);
      expect(r.rejectCode, 'RESTORE_ROLLBACK');
      expect(r.verdict!.archiveRelation, DerivedRelation.empty);
      expect(r.snapshot, isNull);
      expect(_ls(backups), isEmpty);
      expect(_ls(scratch), isEmpty);
    });

    test('🔴 아카이브 뒤처짐(BEHIND) = RESTORE_ROLLBACK — 아카이브를 따라잡힌 뒤에 백업', () {
      archived(through: '2026-11-03');
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
      final SnapshotTakeResult r = take();
      expect(r.rejectCode, 'RESTORE_ROLLBACK');
      expect(r.verdict!.archiveRelation, DerivedRelation.behind);
      expect(_ls(backups), isEmpty);
      writer().archiveStamped();
      expect(take().verdict!.ok, isTrue);
    });

    test('PRAGMA ≠ ok = RESTORE_SQLITE_INTEGRITY · 사본에 물었다', () {
      archived();
      final List<String> seen = <String>[];
      final SnapshotTakeResult r = take(
        s: snapper(
          pragma: (Database d) {
            seen.add(
              d.select('PRAGMA application_id').first.values.first.toString(),
            );
            return <String>['row 7 missing'];
          },
        ),
      );
      expect(r.rejectCode, 'RESTORE_SQLITE_INTEGRITY');
      expect(seen, <String>['${LedgerFile.live.applicationId}']);
      expect(_ls(backups), isEmpty);
    });

    test('체인 깨짐 = RESTORE_CHAIN_INVALID · 사유 · 첫 날 실림 · 원장에 기록 0', () {
      archived();
      db.execute(
        "UPDATE decision_log SET created_at = '2026-11-04T05:00:00Z' WHERE decision_id = 'D-1'",
      );
      final int recon =
          db.select('SELECT COUNT(*) AS n FROM reconciliation_log').single['n']
              as int;
      final SnapshotTakeResult r = take();
      expect(r.rejectCode, 'RESTORE_CHAIN_INVALID');
      expect(r.verdict!.chain!.ok, isFalse);
      expect(r.verdict!.toDetail()['first_bad_date'], isNotNull);
      expect(
        db.select('SELECT COUNT(*) AS n FROM reconciliation_log').single['n'],
        recon,
      );
      expect(
        db.select(
          "SELECT 1 FROM trading_block WHERE flag_id = 'LEDGER_INTEGRITY'",
        ),
        isEmpty,
      );
      expect(_ls(backups), isEmpty);
    });

    test('scratch 없음 = RESTORE_UNREADABLE · .partial 지움', () {
      archived();
      final SnapshotTakeResult r = take(
        scratchDir: Directory('${dir.path}/없는곳'),
      );
      expect(r.rejectCode, 'RESTORE_UNREADABLE');
      expect(_ls(backups), isEmpty);
    });

    test('이름 꼴 = ArgumentError', () {
      archived();
      for (final String bad in <String>['', '../x', 'a.b', '-x', 'a/b', '한']) {
        expect(() => take(name: bad), throwsArgumentError, reason: bad);
      }
      expect(() => snapshotFileOf(backups, 'a b'), throwsArgumentError);
      expect(() => manifestFileOf(backups, '.x'), throwsArgumentError);
      expect(
        snapshotFileOf(backups, 'A_1-b').path,
        '${backups.path}/A_1-b.sqlite',
      );
      expect(
        manifestFileOf(backups, 'A_1-b').path,
        '${backups.path}/A_1-b.manifest.json',
      );
    });
  });

  group('verifyLedgerSnapshot · verifySnapshotBytes — 복원 쪽', () {
    late LedgerSnapshot snap;
    late Uint8List bytes;
    setUp(() {
      archived();
      snap = take().snapshot!;
      bytes = snap.file.readAsBytesSync();
    });

    RestoreVerdict verify(
      Uint8List b,
      BackupManifest m, {
      ArchiveCheckpoint? archive,
      bool noArchive = false,
      Directory? scratchDir,
    }) => verifySnapshotBytes(
      b,
      m,
      archive: noArchive ? null : (archive ?? writer().readCheckpoint()),
      scratch: scratchDir ?? scratch,
    );

    BackupManifest withSha(
      BackupManifest m,
      String sha, {
      String? chain,
      String? date,
      int? epoch,
    }) => BackupManifest(
      sha256: sha,
      chainHash: chain ?? m.chainHash,
      authoredDate: date ?? m.authoredDate,
      schemaVersion: m.schemaVersion,
      hashFormatVersion: m.hashFormatVersion,
      operatorEpoch: epoch ?? m.operatorEpoch,
      writerDeviceId: m.writerDeviceId,
    );

    test('통과 · 사본 지움', () {
      expect(verify(bytes, snap.manifest).ok, isTrue);
      expect(_ls(scratch), isEmpty);
    });

    test('바이트 한 개 바뀜 = RESTORE_SHA_MISMATCH', () {
      final Uint8List b = Uint8List.fromList(bytes);
      b[b.length - 1] ^= 0x01;
      expect(verify(b, snap.manifest).code, 'RESTORE_SHA_MISMATCH');
      expect(_ls(scratch), isEmpty);
    });

    test('파일 없음 · scratch 없음 · 쓰레기 바이트 = RESTORE_UNREADABLE', () {
      snap.file.deleteSync();
      expect(
        verifyLedgerSnapshot(
          snap,
          archive: writer().readCheckpoint(),
          scratch: scratch,
        ).code,
        'RESTORE_UNREADABLE',
      );
      expect(
        verify(
          bytes,
          snap.manifest,
          scratchDir: Directory('${dir.path}/없음'),
        ).code,
        'RESTORE_UNREADABLE',
      );
      final Uint8List junk = Uint8List.fromList(List<int>.filled(4096, 7));
      final BackupManifest m = withSha(
        snap.manifest,
        sha256.convert(junk).toString(),
      );
      expect(verify(junk, m).code, 'RESTORE_UNREADABLE');
      expect(_ls(scratch), isEmpty);
    });

    test('모의 파일 = X1_LIVE_ONLY', () {
      final Database sim = openLocalLedger(
        scratch.path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      final String out = '${dir.path}/sim.sqlite';
      sim.execute('VACUUM INTO ?', <Object?>[out]);
      sim.close();
      for (final String f in _ls(scratch)) {
        File('${scratch.path}/$f').deleteSync();
      }
      final Uint8List b = File(out).readAsBytesSync();
      expect(
        verify(b, withSha(snap.manifest, sha256.convert(b).toString())).code,
        'X1_LIVE_ONLY',
      );
    });

    test('schema 판 다름 = RESTORE_SCHEMA_SKEW', () {
      final String path = '${dir.path}/skew.sqlite';
      File(path).writeAsBytesSync(bytes);
      final Database d = sqlite3.open(path);
      d.execute(
        "INSERT INTO schema_version (version, applied_at, description) VALUES (2, 'x', '미래 판')",
      );
      d.close();
      final Uint8List b = File(path).readAsBytesSync();
      expect(
        verify(b, withSha(snap.manifest, sha256.convert(b).toString())).code,
        'RESTORE_SCHEMA_SKEW',
      );
    });

    test('schema_version 표 없음 · 행 없음 = RESTORE_SCHEMA_SKEW(0 으로 본다)', () {
      for (final String sql in <String>[
        'DROP TABLE schema_version',
        'DELETE FROM schema_version',
      ]) {
        final String path = '${dir.path}/noschema.sqlite';
        File(path).writeAsBytesSync(bytes);
        final Database d = sqlite3.open(path);
        d.execute(sql);
        d.close();
        final Uint8List b = File(path).readAsBytesSync();
        File(path).deleteSync();
        expect(
          verify(b, withSha(snap.manifest, sha256.convert(b).toString())).code,
          'RESTORE_SCHEMA_SKEW',
          reason: sql,
        );
      }
    });

    test('정본 epoch = 매니페스트 epoch — 매니페스트(2) > 아카이브(1) = 통과', () {
      final ArchiveCheckpoint cp = writer().readCheckpoint()!;
      final ArchiveCheckpoint older = ArchiveCheckpoint(
        schemaVersion: cp.schemaVersion,
        hashFormatVersion: cp.hashFormatVersion,
        authoredDate: cp.authoredDate,
        chainHash: cp.chainHash,
        operatorEpoch: 1,
        writerDeviceId: cp.writerDeviceId,
        committedAt: cp.committedAt,
      );
      expect(
        verify(
          bytes,
          withSha(snap.manifest, snap.manifest.sha256, epoch: 2),
          archive: older,
        ).ok,
        isTrue,
      );
    });

    test('PRAGMA 주입 = 복원 쪽도 사본에 묻는다', () {
      final List<String> seen = <String>[];
      final RestoreVerdict v = verifyLedgerSnapshot(
        snap,
        archive: writer().readCheckpoint(),
        scratch: scratch,
        sqliteIntegrity: (Database d) {
          seen.add(
            d.select('PRAGMA application_id').first.values.first.toString(),
          );
          return <String>['page 3 corrupt'];
        },
      );
      expect(v.code, 'RESTORE_SQLITE_INTEGRITY');
      expect(seen, <String>['${LedgerFile.live.applicationId}']);
    });

    test('매니페스트 ↔ 머리 다름 = RESTORE_MANIFEST_MISMATCH(체인 · 날)', () {
      expect(
        verify(
          bytes,
          withSha(snap.manifest, snap.manifest.sha256, chain: 'e' * 64),
        ).code,
        'RESTORE_MANIFEST_MISMATCH',
      );
      expect(
        verify(
          bytes,
          withSha(snap.manifest, snap.manifest.sha256, date: '2026-11-03'),
        ).code,
        'RESTORE_MANIFEST_MISMATCH',
      );
    });

    test('🔴 아카이브가 앞섬(옛 백업 복원 = 되돌림) = RESTORE_ROLLBACK · AHEAD', () {
      clock.at = DateTime.utc(2026, 11, 5, 21, 30);
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-05');
      writer().archiveStamped();
      final RestoreVerdict v = verify(bytes, snap.manifest);
      expect(v.code, 'RESTORE_ROLLBACK');
      expect(v.archiveRelation, DerivedRelation.ahead);
    });

    test(
      '아카이브 epoch 가 앞섬 = RESTORE_ROLLBACK · EPOCH_AHEAD · 아카이브 없음 = EMPTY',
      () {
        final ArchiveCheckpoint cp = writer().readCheckpoint()!;
        final ArchiveCheckpoint newer = ArchiveCheckpoint(
          schemaVersion: cp.schemaVersion,
          hashFormatVersion: cp.hashFormatVersion,
          authoredDate: cp.authoredDate,
          chainHash: cp.chainHash,
          operatorEpoch: cp.operatorEpoch + 1,
          writerDeviceId: 'dev-new',
          committedAt: cp.committedAt,
        );
        final RestoreVerdict v = verify(bytes, snap.manifest, archive: newer);
        expect(v.code, 'RESTORE_ROLLBACK');
        expect(v.archiveRelation, DerivedRelation.epochAhead);
        expect(
          verify(bytes, snap.manifest, noArchive: true).archiveRelation,
          DerivedRelation.empty,
        );
      },
    );
  });

  group('ledgerChainVerdictOf — 체인만 · 기록 0', () {
    test('스탬프 0 = 통과 · 스탬프 = 통과 · 고친 행 = DAY_HASH_MISMATCH', () {
      final LedgerIntegrityVerdict empty = ledgerChainVerdictOf(db);
      expect(empty.ok, isTrue);
      expect(empty.daysChecked, 0);
      archived();
      expect(ledgerChainVerdictOf(db).ok, isTrue);
      db.execute(
        "UPDATE decision_log SET created_at = '2026-11-04T05:00:00Z' WHERE decision_id = 'D-1'",
      );
      final LedgerIntegrityVerdict bad = ledgerChainVerdictOf(db);
      expect(bad.reason, LedgerIntegrityReason.dayHashMismatch);
      expect(
        db.select('SELECT COUNT(*) AS n FROM reconciliation_log').single['n'],
        0,
      );
    });
  });

  group('migrationPlanFactsOf — 단계 사실', () {
    void intent(String id, String status) => db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
      "'2026-11-04', 'KR', 'pension', 'P0S_B', 'B@2026-11-04', '133690', 'BUY', 'LIMIT', 1, ?, 'c', 'x', 'LIVE')",
      <Object?>[id, 'k-$id', status],
    );

    test('빈 원장 = 0 · 체인 없음 · 백업 없음 = BACKUP_MISSING', () {
      final PlanStepFacts f = migrationPlanFactsOf(db);
      expect(f.openOrders, 0);
      expect(f.unknownOrders, 0);
      expect(f.reconMismatches, 0);
      expect(f.currentChainHash, isNull);
      expect(f.backupChainHash, isNull);
      expect(
        planStepBlockCode(PlanStep.backupChecksum, f),
        PlanBlockCodes.backupMissing,
      );
    });

    test('미체결 = RESERVED · SUBMITTING · SUBMITTED · PARTIAL · UNKNOWN 따로', () {
      const List<String> all = <String>[
        'RESERVED',
        'SUBMITTING',
        'SUBMITTED',
        'PARTIAL',
        'FILLED',
        'CANCELLED',
        'REJECTED',
        'SKIPPED',
        'EXPIRED',
        'UNKNOWN',
      ];
      for (int i = 0; i < all.length; i++) {
        intent('i-$i', all[i]);
      }
      intent('i-u2', 'UNKNOWN');
      final PlanStepFacts f = migrationPlanFactsOf(db);
      expect(f.openOrders, 4);
      expect(f.unknownOrders, 2);
      expect(
        planStepBlockCode(PlanStep.ordersCleared, f),
        PlanBlockCodes.openOrders,
      );
    });

    test('대사 = RECON_MISMATCH 활성만 · 풀린 행 = 0', () {
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.reconMismatch, '2026-11-04T01:00:00Z', 'r'],
      );
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.ledgerIntegrity, '2026-11-04T01:00:00Z', 'r'],
      );
      expect(migrationPlanFactsOf(db).reconMismatches, 1);
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-11-04T02:00:00Z' WHERE flag_id = ?",
        <Object?>[FlagIds.reconMismatch],
      );
      expect(migrationPlanFactsOf(db).reconMismatches, 0);
    });

    test('🔴 지금 체인 = 마지막 스탬프 · 백업 체인 = 검증된 매니페스트 → BACKUP_CHECKSUM 통과 · 다음 날 스탬프 = 어긋남', () {
      archived();
      final LedgerSnapshot s = take().snapshot!;
      final PlanStepFacts f = migrationPlanFactsOf(db, backup: s.manifest);
      expect(f.currentChainHash, lastChain());
      expect(f.backupChainHash, s.manifest.chainHash);
      expect(planStepBlockCode(PlanStep.backupChecksum, f), isNull);
      clock.at = DateTime.utc(2026, 11, 5, 21, 30);
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-05');
      expect(
        planStepBlockCode(
          PlanStep.backupChecksum,
          migrationPlanFactsOf(db, backup: s.manifest),
        ),
        PlanBlockCodes.backupChainMismatch,
      );
    });
  });
}
