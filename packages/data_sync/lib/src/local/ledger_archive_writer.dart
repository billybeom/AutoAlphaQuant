// JSONL 아카이브 로컬 쓰기 · `checkpoint.json`(설계 13 §8 R52 A1~A4 · 01 §6-7 · 06 M4-5).
//
// 🔴 대상 = 스탬프된 날 중 체크포인트 뒤 · 쓰기 전에 전부 대조한다(재계산 day_hash = 스탬프 · 체크포인트 체인 = 스탬프 ·
//    이미 있는 파일 = 같은 바이트) — 하나라도 어긋나면 아무것도 쓰지 않고 [LedgerArchiveError].
// 🔴 쓰는 순서 = 날 파일 전부 → 체크포인트 마지막(임시 파일 → 이름 바꾸기) · 중간에 끊기면 다시 돌릴 때 이어 쓴다.
// 🔴 원격 커밋 · `sync_state` 쓰기 = E11n.
// 🆕 E16f3b — 새 기준점 뒤 REBASED 재생성(`regenerateFrom` · 설계 13 §8 R131 M1): fromDate ~ 마지막 스탬프 날을 전부 대조한 뒤
//    다른 바이트 = 덮어씀 · 🔴 그 날 행이 없는 표의 옛 파일 = 지움(남으면 파일로 다시 센 day_hash 가 틀린다) · 체크포인트 마지막.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, RunMode, RunModeIsSim, hashFormatVersion, schemaVersion;
import 'package:sqlite3/sqlite3.dart';

import 'ledger_hash_stamper.dart' show ledgerLinesByDay;

/// 아카이브 실패 — 🔴 사유 = 날 · 표 · 경로만(금액 0). 아무것도 쓰지 않았다.
class LedgerArchiveError implements Exception {
  /// 실패를 만든다.
  const LedgerArchiveError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'LedgerArchiveError($reason)';
}

/// 아카이브 보고.
class LedgerArchiveReport {
  /// 보고를 만든다.
  const LedgerArchiveReport({
    required this.days,
    required this.filesWritten,
    required this.checkpoint,
    this.filesDeleted = const <String>[],
  });

  /// 이번에 아카이브한 날.
  final List<String> days;

  /// 이번에 새로 쓴 파일(루트 기준 경로 · 같은 바이트로 이미 있던 것 제외).
  final List<String> filesWritten;

  /// 지금 체크포인트(없으면 null).
  final ArchiveCheckpoint? checkpoint;

  /// 🆕 E16f3b — 이번에 지운 파일(재생성 · 행이 없어진 표 · 루트 기준 경로).
  final List<String> filesDeleted;
}

/// JSONL 아카이브 로컬 쓰기(R52).
class LedgerArchiveWriter {
  /// 쓰기를 만든다 — [root] = 원격 저장소 작업 트리와 같은 꼴의 폴더(조립 앱이 준다).
  LedgerArchiveWriter(
    this._db, {
    required this._root,
    required RunMode mode,
    required this._clock,
    required this._writerDeviceId,
    required this._operatorEpoch,
  }) : _prefix = archivePrefix(sim: mode.isSim);

  final Database _db;
  final String _root;
  final String _prefix;
  final Clock _clock;
  final String _writerDeviceId;
  final int _operatorEpoch;

  File _file(String rel) => File('$_root/$rel');

  /// 지금 체크포인트(없으면 null · 못 읽음 = [LedgerArchiveError]).
  ArchiveCheckpoint? readCheckpoint() {
    final File f = _file(archiveCheckpointPath(_prefix));
    if (!f.existsSync()) return null;
    try {
      return ArchiveCheckpoint.parse(f.readAsStringSync());
    } on LedgerHashError catch (e) {
      throw LedgerArchiveError('체크포인트: ${e.reason}');
    }
  }

  void _writeAtomic(String rel, String content) {
    final File f = _file(rel);
    f.parent.createSync(recursive: true);
    final File tmp = File('${f.path}.tmp');
    tmp.writeAsStringSync(content, flush: true);
    tmp.renameSync(f.path);
  }

  /// 스탬프된 날 중 체크포인트 뒤를 아카이브한다.
  LedgerArchiveReport archiveStamped() {
    final ArchiveCheckpoint? cp = readCheckpoint();
    if (cp != null) {
      final ResultSet at = _db.select(
        'SELECT chain_hash FROM ledger_daily_hash WHERE authored_date = ?',
        <Object?>[cp.authoredDate],
      );
      if (at.isEmpty || at.first['chain_hash'] != cp.chainHash) {
        throw LedgerArchiveError('체크포인트가 체인과 다르다: ${cp.authoredDate}');
      }
    }
    final List<Row> stamps = _db.select(
      'SELECT authored_date, day_hash, chain_hash, hash_format_version FROM ledger_daily_hash '
      'WHERE authored_date > ? ORDER BY authored_date',
      <Object?>[cp?.authoredDate ?? ''],
    ).toList();
    if (stamps.isEmpty) {
      return LedgerArchiveReport(
        days: const <String>[],
        filesWritten: const <String>[],
        checkpoint: cp,
      );
    }
    final Map<String, Map<String, List<String>>> byDay = ledgerLinesByDay(_db);
    // 1) 대조 — 하나라도 어긋나면 아무것도 쓰지 않는다.
    final List<(String, String)> toWrite = <(String, String)>[];
    for (final Row s in stamps) {
      final String d = s['authored_date'] as String;
      if (s['hash_format_version'] != hashFormatVersion) {
        throw LedgerArchiveError('$d: 형식 판 다름');
      }
      final Map<String, List<String>> lines =
          byDay[d] ?? const <String, List<String>>{};
      if (dayHashOf(lines) != s['day_hash']) {
        throw LedgerArchiveError('$d: 원장이 스탬프와 다르다');
      }
      for (final MapEntry<String, List<String>> e in lines.entries) {
        final String rel = archiveTablePath(_prefix, d, e.key);
        final String content = archiveFileContent(e.value);
        final File f = _file(rel);
        if (f.existsSync()) {
          if (!_sameBytes(f.readAsBytesSync(), utf8.encode(content))) {
            throw LedgerArchiveError('이미 있는 파일과 다르다: $rel');
          }
          continue;
        }
        toWrite.add((rel, content));
      }
    }
    // 2) 날 파일 → 3) 체크포인트 마지막.
    for (final (String rel, String content) in toWrite) {
      _writeAtomic(rel, content);
    }
    final Row last = stamps.last;
    final ArchiveCheckpoint next = ArchiveCheckpoint(
      schemaVersion: schemaVersion,
      hashFormatVersion: hashFormatVersion,
      authoredDate: last['authored_date'] as String,
      chainHash: last['chain_hash'] as String,
      operatorEpoch: _operatorEpoch,
      writerDeviceId: _writerDeviceId,
      committedAt: _clock.nowUtc().toUtc().toIso8601String(),
    );
    _writeAtomic(archiveCheckpointPath(_prefix), next.toCanonicalJson());
    return LedgerArchiveReport(
      days: <String>[for (final Row s in stamps) s['authored_date'] as String],
      filesWritten: <String>[for (final (String rel, _) in toWrite) rel],
      checkpoint: next,
    );
  }

  /// 🔴 REBASED 재생성 — [fromDate] ~ 마지막 스탬프 날을 지금 원장으로 다시 쓴다(R131 M1).
  ///
  /// 체크포인트가 없거나 [fromDate] 가 체크포인트 날보다 뒤 · 스탬프가 없거나 형식 판 · 원장 ≠ 스탬프 = [LedgerArchiveError]
  /// (아무것도 안 씀). 다른 바이트 = 덮어씀 · 그 날 행이 없는 표의 옛 파일 = 지움 · 체크포인트 마지막 · [fromDate] 앞 날은 그대로.
  LedgerArchiveReport regenerateFrom(String fromDate) {
    final ArchiveCheckpoint? cp = readCheckpoint();
    if (cp == null) throw const LedgerArchiveError('체크포인트가 없다 — 다시 쓸 것이 없다');
    if (fromDate.compareTo(cp.authoredDate) > 0) {
      throw LedgerArchiveError('$fromDate: 체크포인트 날(${cp.authoredDate})보다 뒤');
    }
    final List<Row> stamps = _db.select(
      'SELECT authored_date, day_hash, chain_hash, hash_format_version FROM ledger_daily_hash '
      'WHERE authored_date >= ? ORDER BY authored_date',
      <Object?>[fromDate],
    ).toList();
    if (stamps.isEmpty) throw LedgerArchiveError('$fromDate: 다시 쓸 스탬프가 없다');
    final Map<String, Map<String, List<String>>> byDay = ledgerLinesByDay(_db);
    // 1) 대조 — 하나라도 어긋나면 아무것도 쓰지 않는다.
    final List<(String, String)> toWrite = <(String, String)>[];
    final List<String> toDelete = <String>[];
    for (final Row s in stamps) {
      final String d = s['authored_date'] as String;
      if (s['hash_format_version'] != hashFormatVersion) {
        throw LedgerArchiveError('$d: 형식 판 다름');
      }
      final Map<String, List<String>> lines =
          byDay[d] ?? const <String, List<String>>{};
      if (dayHashOf(lines) != s['day_hash']) {
        throw LedgerArchiveError('$d: 원장이 스탬프와 다르다');
      }
      for (final MapEntry<String, List<String>> e in lines.entries) {
        final String rel = archiveTablePath(_prefix, d, e.key);
        final String content = archiveFileContent(e.value);
        final File f = _file(rel);
        if (f.existsSync() &&
            _sameBytes(f.readAsBytesSync(), utf8.encode(content))) {
          continue;
        }
        toWrite.add((rel, content));
      }
      final Directory dir = Directory('$_root/${archiveDayDir(_prefix, d)}');
      if (dir.existsSync()) {
        for (final FileSystemEntity e in dir.listSync()) {
          final String name = e.uri.pathSegments.last;
          if (e is! File || !name.endsWith('.jsonl')) continue;
          final String table = name.substring(0, name.length - '.jsonl'.length);
          if (!lines.containsKey(table)) {
            toDelete.add(archiveTablePath(_prefix, d, table));
          }
        }
      }
    }
    toDelete.sort();
    // 2) 날 파일 → 옛 파일 지우기 → 3) 체크포인트 마지막.
    for (final (String rel, String content) in toWrite) {
      _writeAtomic(rel, content);
    }
    for (final String rel in toDelete) {
      _file(rel).deleteSync();
    }
    final Row last = stamps.last;
    final ArchiveCheckpoint next = ArchiveCheckpoint(
      schemaVersion: schemaVersion,
      hashFormatVersion: hashFormatVersion,
      authoredDate: last['authored_date'] as String,
      chainHash: last['chain_hash'] as String,
      operatorEpoch: _operatorEpoch,
      writerDeviceId: _writerDeviceId,
      committedAt: _clock.nowUtc().toUtc().toIso8601String(),
    );
    _writeAtomic(archiveCheckpointPath(_prefix), next.toCanonicalJson());
    return LedgerArchiveReport(
      days: <String>[for (final Row s in stamps) s['authored_date'] as String],
      filesWritten: <String>[for (final (String rel, _) in toWrite) rel],
      checkpoint: next,
      filesDeleted: toDelete,
    );
  }
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int k = 0; k < a.length; k++) {
    if (a[k] != b[k]) return false;
  }
  return true;
}
