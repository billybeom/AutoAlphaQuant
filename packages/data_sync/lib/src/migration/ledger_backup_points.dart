// M9 S09 백업 화면 사실 — 스냅숏 매니페스트 목록 · 원장 판정 · «지금 백업»(E11q-c2 · 설계 13 §8 R201 · 01 §33 K112 · K133 · 미결 199 ⓑⓒⓓ).
//
// 🔴 목록 = [dir] 의 매니페스트 중 이름이 백업 꼴(core `backupSnapshotTimeOf`)이고 정규 표기이며 스냅숏 파일이 있는 것만 —
//    못 읽는 매니페스트 · 파일 없는 지점 = 복원할 수 없으니 보이지 않는다 · 🔴 보관 개수 · 지우기 = 발주자 수치(⬜ — 여기서 지우지 않는다).
// 🔴 원장 판정 = `take` 와 같은 함수 · 같은 차례(application_id → `ledger_daily_hash` → `canonChainOf` ↔ 체크포인트
//    `derivedRelationOf` = `IN_SYNC`) — 화면이 버튼을 보이면 `take` 도 그 자리까지는 받아 준다.
// 🔴 «지금 백업» = X1 스냅숏 `take`(이름 = 만든 시각 · 기기 안만) · 🟡 바깥 올리기 = `backup_upload` D9(발주자 · 미정) — 여기 없다.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show LedgerFile;
import 'package:sqlite3/sqlite3.dart';

import '../local/derived_sync_store.dart' show canonChainOf;
import 'ledger_snapshot.dart';

const String _manifestSuffix = '.manifest.json';

/// 🔴 [dir] 의 백업 지점(차례 무관 · 엔진이 새것부터 놓는다) — 폴더 없음 = 빈 목록.
List<BackupPointFacts> ledgerBackupPointsOf(Directory dir) {
  if (!dir.existsSync()) return const <BackupPointFacts>[];
  final List<BackupPointFacts> out = <BackupPointFacts>[];
  for (final FileSystemEntity e in dir.listSync(followLinks: false)) {
    if (e is! File) continue;
    final String base = e.path.split(RegExp(r'[/\\]')).last;
    if (!base.endsWith(_manifestSuffix)) continue;
    final String name = base.substring(0, base.length - _manifestSuffix.length);
    final DateTime? at = backupSnapshotTimeOf(name);
    if (at == null) continue;
    final LedgerSnapshot? s;
    try {
      s = readLedgerSnapshot(dir, name);
    } on FormatException {
      continue;
    } on FileSystemException {
      continue;
    }
    if (s == null || !s.file.existsSync()) continue;
    out.add(
      BackupPointFacts(code: name, createdAtUtc: at, manifest: s.manifest),
    );
  }
  return out;
}

/// 🔴 S09 사실 — [db] = 화면 원장 · [dir] = 백업 폴더 · [archive] = 지금 아카이브 체크포인트(없음 = null → `IN_SYNC` 아님) ·
/// [operatorEpoch] = 이 기기 epoch(`take` 와 같은 값) · 나머지 = 조립(창구 · 레지스트리 · 잠김 · 시각) 그대로.
BackupScreenFacts backupScreenFactsOf(
  Database db, {
  required Directory dir,
  required ArchiveCheckpoint? archive,
  required int operatorEpoch,
  required bool canRun,
  required bool migrationLinkable,
  required DateTime nowUtc,
  String? lockedLabel,
}) {
  final bool live =
      db.select('PRAGMA application_id').first.values.first ==
      LedgerFile.live.applicationId;
  final bool stamped =
      live && db.select('SELECT 1 FROM ledger_daily_hash LIMIT 1').isNotEmpty;
  final bool inSync =
      stamped &&
      derivedRelationOf(
            canonChainOf(db, operatorEpoch: operatorEpoch),
            archive == null ? null : DerivedStamp.fromCheckpoint(archive),
          ) ==
          DerivedRelation.inSync;
  return BackupScreenFacts(
    liveLedger: live,
    stamped: stamped,
    archiveInSync: inSync,
    archive: archive,
    points: live ? ledgerBackupPointsOf(dir) : const <BackupPointFacts>[],
    canRun: canRun,
    migrationLinkable: migrationLinkable,
    nowUtc: nowUtc,
    lockedLabel: lockedLabel,
  );
}

/// 🔴 «지금 백업» — 이름 = [nowUtc](분) · [dir] · [scratch] 는 없으면 만든다 · 거부 코드 = `take` 그대로.
SnapshotTakeResult takeLedgerBackup(
  Database db, {
  required Directory dir,
  required Directory scratch,
  required ArchiveCheckpoint? archive,
  required String deviceId,
  required int operatorEpoch,
  required DateTime nowUtc,
}) {
  dir.createSync(recursive: true);
  scratch.createSync(recursive: true);
  return SqliteLedgerSnapshotter(
    db,
    deviceId: deviceId,
    operatorEpoch: operatorEpoch,
  ).take(dir, backupSnapshotNameOf(nowUtc), archive: archive, scratch: scratch);
}
