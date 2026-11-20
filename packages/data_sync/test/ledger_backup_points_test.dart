// E11q-c2 — M9 S09 백업 지점 목록 · 화면 사실 · «지금 백업»(설계 13 §8 R201 · 미결 199 ⓑⓒⓓ).
//
// 🔵 잡는 것: ① «지금 백업» = X1 `take` · 이름 = 만든 시각(분) · 같은 분 = SNAPSHOT_EXISTS · 폴더 없으면 만든다
//    ② 목록 = 백업 꼴 이름 ∧ 정규 매니페스트 ∧ 파일 있음만(다른 이름 · 깨진 매니페스트 · 파일 없음 = 지점 아님) · 지우지 않는다
//    ③ 화면 사실 = `take` 와 같은 판정(모의 · 스탬프 0 · 아카이브 EMPTY · BEHIND · IN_SYNC) — 사실이 «받는다»면 `take` 도 받는다
//    ④ 엔진 VM 끝까지(버튼 · 지점 행 · 상태 줄).

import 'dart:io';

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

// 2026-11-04T21:30Z = 한국 11-05 06:30 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);

List<String> _ls(Directory d) => d.existsSync()
    ? (<String>[
        for (final FileSystemEntity e in d.listSync()) e.uri.pathSegments.last,
      ]..sort())
    : const <String>[];

void main() {
  late Directory dir;
  late Directory root;
  late Directory backups;
  late Directory scratch;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_bk_');
    root = Directory('${dir.path}/repo')..createSync();
    backups = Directory('${dir.path}/backup');
    scratch = Directory('${dir.path}/backup_scratch');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  LedgerArchiveWriter writer() => LedgerArchiveWriter(
    db,
    root: root.path,
    mode: RunMode.live,
    clock: clock,
    writerDeviceId: 'dev-c2',
    operatorEpoch: 0,
  );

  void archived({String through = '2026-11-04'}) {
    loadLedgerGolden(db);
    LedgerHashStamper(db, clock: clock).stampThrough(through);
    writer().archiveStamped();
  }

  SnapshotTakeResult take({DateTime? at, ArchiveCheckpoint? archive}) =>
      takeLedgerBackup(
        db,
        dir: backups,
        scratch: scratch,
        archive: archive ?? writer().readCheckpoint(),
        deviceId: 'dev-c2',
        operatorEpoch: 0,
        nowUtc: at ?? _t0,
      );

  BackupScreenFacts facts({Database? on, ArchiveCheckpoint? archive}) =>
      backupScreenFactsOf(
        on ?? db,
        dir: backups,
        archive: archive,
        operatorEpoch: 0,
        canRun: true,
        migrationLinkable: true,
        nowUtc: _t0,
      );

  group('takeLedgerBackup — X1 take · 이름 = 만든 시각', () {
    test('🔴 폴더를 만들고 스냅숏 + 매니페스트 · 이름 = bk_ 분 · 같은 분 = SNAPSHOT_EXISTS · 다음 분 = 새 지점', () {
      archived();
      expect(backups.existsSync(), isFalse);
      final SnapshotTakeResult r = take();
      expect(r.rejectCode, isNull);
      expect(_ls(backups), <String>[
        'bk_20261104T2130Z.manifest.json',
        'bk_20261104T2130Z.sqlite',
      ]);
      expect(_ls(scratch), isEmpty);
      expect(
        take(at: _t0.add(const Duration(seconds: 40))).rejectCode,
        SnapshotCodes.exists,
      );
      expect(take(at: _t0.add(const Duration(minutes: 1))).rejectCode, isNull);
      expect(ledgerBackupPointsOf(backups), hasLength(2));
    });

    test('🔴 아카이브 없음 = RESTORE_ROLLBACK(K133) · 모의 = X1_LIVE_ONLY · 스탬프 0 = SNAPSHOT_NO_STAMP · 지점 0', () {
      expect(take().rejectCode, SnapshotCodes.noStamp);
      archived();
      expect(
        takeLedgerBackup(
          db,
          dir: backups,
          scratch: scratch,
          archive: null,
          deviceId: 'dev-c2',
          operatorEpoch: 0,
          nowUtc: _t0,
        ).rejectCode,
        RestoreReason.rollback.wire,
      );
      final Database sim = openLocalLedger(
        (Directory('${dir.path}/simdir')..createSync()).path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sim.close);
      expect(
        takeLedgerBackup(
          sim,
          dir: backups,
          scratch: scratch,
          archive: null,
          deviceId: 'dev-c2',
          operatorEpoch: 0,
          nowUtc: _t0,
        ).rejectCode,
        MigrationStartCodes.liveOnly,
      );
      expect(ledgerBackupPointsOf(backups), isEmpty);
    });
  });

  group('ledgerBackupPointsOf — 목록', () {
    test('🔴 폴더 없음 = 빈 목록', () {
      expect(ledgerBackupPointsOf(backups), isEmpty);
    });

    test('🔴 백업 꼴 이름 ∧ 정규 매니페스트 ∧ 파일 있음만 · 시각 = 이름 · 지우지 않는다', () {
      archived();
      take();
      final String man = File('${backups.path}/bk_20261104T2130Z.manifest.json')
          .readAsStringSync();
      // X1 이전 스냅숏 이름(백업 꼴 아님) · 깨진 매니페스트 · 파일 없는 지점 · 달력에 없는 날.
      File('${backups.path}/mig-20261105-1.manifest.json')
          .writeAsStringSync(man);
      File('${backups.path}/mig-20261105-1.sqlite').writeAsStringSync('x');
      File('${backups.path}/bk_20261103T0100Z.manifest.json')
          .writeAsStringSync('{"broken":true}\n');
      File('${backups.path}/bk_20261103T0100Z.sqlite').writeAsStringSync('x');
      File('${backups.path}/bk_20261102T0100Z.manifest.json')
          .writeAsStringSync(man);
      File('${backups.path}/bk_20260230T0100Z.manifest.json')
          .writeAsStringSync(man);
      File('${backups.path}/bk_20260230T0100Z.sqlite').writeAsStringSync('x');
      final List<String> before = _ls(backups);
      final List<BackupPointFacts> pts = ledgerBackupPointsOf(backups);
      expect(pts.map((BackupPointFacts p) => p.code), <String>[
        'bk_20261104T2130Z',
      ]);
      expect(pts.single.createdAtUtc, _t0);
      expect(pts.single.manifest.authoredDate, '2026-11-04');
      expect(_ls(backups), before, reason: '지우지 않는다');
    });
  });

  group('backupScreenFactsOf — take 와 같은 판정', () {
    test('🔴 모의 원장 = live 아님 · 스탬프 · IN_SYNC 거짓 · 지점 0', () {
      final Database sim = openLocalLedger(
        (Directory('${dir.path}/simdir')..createSync()).path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sim.close);
      final BackupScreenFacts f = facts(on: sim);
      expect(f.liveLedger, isFalse);
      expect(f.stamped, isFalse);
      expect(f.archiveInSync, isFalse);
      expect(f.points, isEmpty);
    });

    test('🔴 스탬프 0 → 스탬프 · 아카이브 없음(EMPTY) → 뒤처짐(BEHIND) → IN_SYNC — 사실이 받으면 take 도 받는다', () {
      expect(facts().stamped, isFalse);
      expect(facts().archiveInSync, isFalse);

      loadLedgerGolden(db);
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-03');
      expect(facts().stamped, isTrue);
      expect(facts().archiveInSync, isFalse, reason: 'EMPTY');

      writer().archiveStamped();
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
      final ArchiveCheckpoint behind = writer().readCheckpoint()!;
      expect(facts(archive: behind).archiveInSync, isFalse, reason: 'BEHIND');
      expect(take(archive: behind).rejectCode, RestoreReason.rollback.wire);

      writer().archiveStamped();
      final ArchiveCheckpoint now = writer().readCheckpoint()!;
      expect(facts(archive: now).archiveInSync, isTrue);
      expect(take(archive: now).rejectCode, isNull);
    });

    test('🔴 엔진 VM 끝까지 — 버튼 · 지점 1 · 상태 줄 = 체크포인트 같음 · 아카이브가 움직이면 상태 줄 부재', () {
      archived(through: '2026-11-03');
      final ArchiveCheckpoint cp = writer().readCheckpoint()!;
      take(archive: cp);
      BackupVm vm = backupVmOf(facts(archive: cp));
      expect(vm.runAction?.id, SettingsActionId.backupRunNow);
      expect(vm.points, hasLength(1));
      expect(vm.points.single.label, '11-05 06:30 만듦 · 11-03 장부까지');
      expect(vm.points.single.chainHashText, cp.chainHash.substring(0, 8));
      expect(vm.points.single.stateLabel, BackupScreenTexts.pointVerified);
      expect(vm.lastBackupText, '마지막 백업 11-05 06:30');
      expect(vm.level, UiLevel.ok);

      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
      writer().archiveStamped();
      vm = backupVmOf(facts(archive: writer().readCheckpoint()));
      expect(vm.points.single.stateLabel, isNull);
      expect(vm.runAction, isNotNull);
    });
  });
}
