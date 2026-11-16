// 일일 아카이브 잡 본체 — 스탬프 → 아카이브 → 백업 나이(설계 13 §8 R52 A5 · A6 · 06 M4-5 · 04 M8 `BACKUP_STALE`).
//
// 🔴 잡 등록(잡 표 · 하트비트 · SPEC 잡 표 창) = E11n(원격 커밋)과 함께 — 원격 없이 매일 돌면 26h 뒤부터 매일 P1.
// 🔴 달력일 잡(휴장 무관) · 어제(한국)까지 스탬프 · 실패 = 던짐(스탬프 · 아카이브는 각자 원자).
// 🔴 백업 나이 = 매매를 막지 않는다(보고 표식만).
// 🆕 E13c1 — 스탬프 **뒤** · 아카이브 **앞** 정본 자가 무결성 검사(R58 C5) · 불일치면 아카이브 건너뜀 · 🔴 `LEDGER_INTEGRITY` 는 검사가 세운다.
// 🆕 E16f3a — 무결성 일치 뒤 아카이브 ↔ 정본 관계(R130 L7): FORK(지금 FORK 이거나 관계가 FORK) = 건너뜀 + 기록 ·
//    FORK 로 바뀐 때만 P0 `DERIVED_FORK` · REBASED = 건너뜀(던지지 않음) + 관측 diff · 봉인 = 건너뜀 · 그 밖 = 아카이브.
//    🔴 FORK 판정은 리스 무관(SPEC v2.45 ⑤) · 리스 · 하루 상한 = 재생성(E16f3b)부터.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../local/derived_sync_store.dart';
import '../local/ledger_archive_writer.dart';
import '../local/ledger_hash_stamper.dart';
import '../local/ledger_integrity_check.dart';
import 'daily_jobs.dart' show DailyJobReport;

/// 🆕 E16f3a — 아카이브를 건너뛴 까닭.
enum ArchiveSkip {
  /// 정본 자가 무결성 불일치.
  integrity('무결성'),

  /// 파생 FORK(끈적).
  fork('FORK'),

  /// 새 기준점 전 기록 — 재생성 대기(E16f3b).
  rebased('REBASED 대기'),

  /// 봉인.
  sealed('봉인');

  const ArchiveSkip(this.label);

  /// 보고 글자.
  final String label;
}

/// 일일 아카이브 보고.
class DailyArchiveReport implements DailyJobReport {
  /// 보고를 만든다.
  const DailyArchiveReport({
    required this.stamped,
    required this.archived,
    required this.backup,
    required this.integrity,
    this.skipped,
    this.relation,
    this.forkRaised = false,
  });

  /// 이번에 스탬프한 날.
  final List<String> stamped;

  /// 이번에 아카이브한 날.
  final List<String> archived;

  /// 백업 나이(스탬프 0 = null).
  final BackupAge? backup;

  /// 🆕 E13c1 — 정본 자가 무결성 검사.
  final LedgerIntegrityReport integrity;

  /// 🆕 E16f3a — 아카이브를 건너뛴 까닭(아카이브함 = null).
  final ArchiveSkip? skipped;

  /// 🆕 E16f3a — 아카이브 ↔ 정본 관계(무결성 불일치 = null).
  final DerivedRelation? relation;

  /// 🆕 E16f3a — 이번에 FORK 로 바뀌었나(P0 `DERIVED_FORK` 한 번).
  final bool forkRaised;

  @override
  Set<String> get alerts => <String>{
    if (backup?.stale ?? false) AlertCodes.backupStale,
    ...integrity.alerts,
    if (forkRaised) kDerivedForkAlertCode,
  };

  @override
  String toString() =>
      'DailyArchiveReport(스탬프 ${stamped.length} · 무결성 ${integrity.verdict.ok ? '일치' : integrity.verdict.reason!.code} · 아카이브 ${skipped == null ? archived.length : '건너뜀 ${skipped!.label}'} · 백업 ${backup?.age.inHours ?? '-'}h)';
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
    List<String> Function(Database db)? sqliteIntegrity,
  }) : _operatorEpoch = operatorEpoch,
       _derived = SqliteDerivedSyncStore(_db),
       _writer = LedgerArchiveWriter(
         _db,
         root: root,
         mode: mode,
         clock: _clock,
         writerDeviceId: writerDeviceId,
         operatorEpoch: operatorEpoch,
       ),
       _integrity = LedgerIntegrityCheck(
         _db,
         clock: _clock,
         sqliteIntegrity: sqliteIntegrity,
       );

  final Database _db;
  final Clock _clock;
  final int _operatorEpoch;
  final SqliteDerivedSyncStore _derived;
  final LedgerArchiveWriter _writer;
  final LedgerIntegrityCheck _integrity;

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

  /// ① 어제(한국)까지 스탬프 ② 정본 자가 무결성 ③ 아카이브 ↔ 정본 관계(② 일치일 때만) ④ 아카이브(FORK · 봉인 · REBASED
  /// 아님) ⑤ 백업 나이.
  DailyArchiveReport run() {
    final List<LedgerDayStamp> stamped = LedgerHashStamper(
      _db,
      clock: _clock,
    ).stampThrough(_kstYesterday(_clock.nowUtc()));
    final LedgerIntegrityReport integrity = _integrity.run();
    List<String> archived = const <String>[];
    ArchiveSkip? skipped;
    DerivedRelation? relation;
    bool forkRaised = false;
    if (!integrity.verdict.ok) {
      skipped = ArchiveSkip.integrity;
    } else {
      final DerivedView view = _derived.archiveView(
        _writer,
        operatorEpoch: _operatorEpoch,
      );
      relation = view.relation;
      final DerivedSyncStatus current = _derived.statusOf(DerivedTarget.github);
      if (current == DerivedSyncStatus.fork || view.relation.forks) {
        skipped = ArchiveSkip.fork;
        forkRaised = _derived.recordFork(
          DerivedTarget.github,
          view,
          _clock.nowUtc(),
        );
      } else if (current == DerivedSyncStatus.sealed) {
        skipped = ArchiveSkip.sealed;
      } else if (view.relation == DerivedRelation.rebased) {
        skipped = ArchiveSkip.rebased;
        _derived.recordRebased(DerivedTarget.github, view, _clock.nowUtc());
      } else {
        archived = _writer.archiveStamped().days;
      }
    }
    return DailyArchiveReport(
      stamped: <String>[for (final LedgerDayStamp s in stamped) s.authoredDate],
      archived: archived,
      backup: backupAge(),
      integrity: integrity,
      skipped: skipped,
      relation: relation,
      forkRaised: forkRaised,
    );
  }
}
