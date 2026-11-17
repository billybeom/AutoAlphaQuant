// X1-4 새 폰 복원 적용 — 검증된 스냅숏을 live 원장 자리에 놓는다(설계 13 §8 R145 Y2~Y7 · SPEC v2.45 04 §3-1 ③⑧).
//
// 🔴 live 원장(본 파일 · `-wal` · `-shm` · `-journal` 하나라도)이 이미 있으면 거부 `X1_LIVE_EXISTS` — 덮어쓰지 않는다
//    (새 폰 = 빈 설치 · 옛 원장을 지우는 길 0).
// 🔴 차례 = 거부 검사 → 스냅숏 바이트 한 번 읽기 → 복원 검증 4중(E16g2 · 같은 바이트) → 같은 바이트를 `.partial` 에 써서
//    다시 읽은 sha = 매니페스트 → rename(원자) · 실패 = `.partial` 지움 · 원장 0.
// 🟡 열기 · 복구 저널 시작(`SqliteRecoveryJournal.start`) · 갭 재구성 = 부르는 쪽(마법사 · E16j) — 여기는 파일만 놓는다.

import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart'
    show ArchiveCheckpoint, RestoreReason, RestoreVerdict;
import 'package:crypto/crypto.dart' as crypto;
import 'package:domain_contracts/domain_contracts.dart' show LedgerFile;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'ledger_snapshot.dart' show LedgerSnapshot, verifySnapshotBytes;

/// 복원 적용 거부 코드(계약 등재 = E16i 노트).
abstract final class LedgerRestoreCodes {
  /// live 원장이 이미 있다(덮어쓰지 않는다).
  static const String liveExists = 'X1_LIVE_EXISTS';
}

/// 복원 적용 결과 — 통과 = [livePath] · 거부 = [rejectCode](검증 거부면 [verdict] 도).
typedef LedgerRestoreResult = ({
  String? rejectCode,
  RestoreVerdict? verdict,
  String? livePath,
});

const List<String> _sidecars = <String>['', '-wal', '-shm', '-journal'];

/// 🔴 복원 적용 — [ledgerDir] = 원장 폴더(live 파일 이름 = 계약 `LedgerFile.live`) · [archive] = 아카이브 체크포인트 ·
/// [scratch] = 검증 사본 자리 · [sqliteIntegrity] = 시험 주입.
LedgerRestoreResult restoreLiveLedger(
  LedgerSnapshot snapshot, {
  required String ledgerDir,
  required ArchiveCheckpoint? archive,
  required Directory scratch,
  List<String> Function(Database db)? sqliteIntegrity,
}) {
  final String live = '$ledgerDir/${LedgerFile.live.fileName}';
  for (final String s in _sidecars) {
    if (File('$live$s').existsSync()) {
      return (
        rejectCode: LedgerRestoreCodes.liveExists,
        verdict: null,
        livePath: null,
      );
    }
  }
  final Uint8List bytes;
  try {
    bytes = snapshot.file.readAsBytesSync();
  } on FileSystemException {
    const RestoreVerdict v = RestoreVerdict.failed(RestoreReason.unreadable);
    return (rejectCode: v.code, verdict: v, livePath: null);
  }
  final RestoreVerdict v = verifySnapshotBytes(
    bytes,
    snapshot.manifest,
    archive: archive,
    scratch: scratch,
    sqliteIntegrity: sqliteIntegrity,
  );
  if (!v.ok) return (rejectCode: v.code, verdict: v, livePath: null);
  final File partial = File('$live.partial');
  bool placed = false;
  try {
    partial.writeAsBytesSync(bytes, flush: true);
    final String written = crypto.sha256
        .convert(partial.readAsBytesSync())
        .toString();
    if (written != snapshot.manifest.sha256) {
      const RestoreVerdict bad = RestoreVerdict.failed(
        RestoreReason.shaMismatch,
      );
      return (rejectCode: bad.code, verdict: bad, livePath: null);
    }
    partial.renameSync(live);
    placed = true;
    return (rejectCode: null, verdict: v, livePath: live);
  } finally {
    if (!placed && partial.existsSync()) partial.deleteSync();
  }
}
