// 일일 아카이브 잡 본체 — 스탬프 → 아카이브 → 백업 나이(설계 13 §8 R52 A5 · A6 · 06 M4-5 · 04 M8 `BACKUP_STALE`).
//
// 🔴 잡 등록(잡 표 · 하트비트 · SPEC 잡 표 창) = E11n(원격 커밋)과 함께 — 원격 없이 매일 돌면 26h 뒤부터 매일 P1.
// 🔴 달력일 잡(휴장 무관) · 어제(한국)까지 스탬프 · 실패 = 던짐(스탬프 · 아카이브는 각자 원자).
// 🔴 백업 나이 = 매매를 막지 않는다(보고 표식만).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../local/ledger_archive_writer.dart';
import '../local/ledger_hash_stamper.dart';
import 'daily_jobs.dart' show DailyJobReport;

/// 일일 아카이브 보고.
class DailyArchiveReport implements DailyJobReport {
  /// 보고를 만든다.
  const DailyArchiveReport({
    required this.stamped,
    required this.archived,
    required this.backup,
  });

  /// 이번에 스탬프한 날.
  final List<String> stamped;

  /// 이번에 아카이브한 날.
  final List<String> archived;

  /// 백업 나이(스탬프 0 = null).
  final BackupAge? backup;

  @override
  Set<String> get alerts => backup?.stale ?? false
      ? const <String>{AlertCodes.backupStale}
      : const <String>{};

  @override
  String toString() =>
      'DailyArchiveReport(스탬프 ${stamped.length} · 아카이브 ${archived.length} · 백업 ${backup?.age.inHours ?? '-'}h)';
}

String _kstYesterday(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  final DateTime y = DateTime.utc(k.year, k.month, k.day - 1);
  return y.toIso8601String().substring(0, 10);
}

/// 일일 아카이브 잡 본체(R52 A6).
class DailyArchiveJob {
  /// 잡을 만든다.
  DailyArchiveJob(
    this._db, {
    required this._clock,
    required String root,
    required RunMode mode,
    required String writerDeviceId,
    required int operatorEpoch,
  }) : _writer = LedgerArchiveWriter(
         _db,
         root: root,
         mode: mode,
         clock: _clock,
         writerDeviceId: writerDeviceId,
         operatorEpoch: operatorEpoch,
       );

  final Database _db;
  final Clock _clock;
  final LedgerArchiveWriter _writer;

  /// 백업 나이 — `sync_state`(`GITHUB`) `last_ok_at` · 없으면 첫 스탬프 `created_at`.
  BackupAge? backupAge() {
    final ResultSet ok = _db.select(
      "SELECT last_ok_at FROM sync_state WHERE target = 'GITHUB'",
    );
    final Object? lastOk = ok.isEmpty ? null : ok.first['last_ok_at'];
    final ResultSet first = _db.select(
      'SELECT created_at FROM ledger_daily_hash ORDER BY authored_date LIMIT 1',
    );
    return backupAgeOf(
      nowUtc: _clock.nowUtc(),
      lastRemoteOkAtUtc: lastOk is String ? DateTime.parse(lastOk) : null,
      firstStampAtUtc: first.isEmpty
          ? null
          : DateTime.parse(first.first['created_at'] as String),
    );
  }

  /// ① 어제(한국)까지 스탬프 ② 아카이브 ③ 백업 나이.
  DailyArchiveReport run() {
    final List<LedgerDayStamp> stamped = LedgerHashStamper(
      _db,
      clock: _clock,
    ).stampThrough(_kstYesterday(_clock.nowUtc()));
    final LedgerArchiveReport archived = _writer.archiveStamped();
    return DailyArchiveReport(
      stamped: <String>[for (final LedgerDayStamp s in stamped) s.authoredDate],
      archived: archived.days,
      backup: backupAge(),
    );
  }
}
