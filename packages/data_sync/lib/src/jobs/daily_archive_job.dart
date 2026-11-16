// 일일 아카이브 잡 본체 — 스탬프 → 아카이브 → 백업 나이(설계 13 §8 R52 A5 · A6 · 06 M4-5 · 04 M8 `BACKUP_STALE`).
//
// 🔴 잡 등록(잡 표 · 하트비트 · SPEC 잡 표 창) = E11n(원격 커밋)과 함께 — 원격 없이 매일 돌면 26h 뒤부터 매일 P1.
// 🔴 달력일 잡(휴장 무관) · 어제(한국)까지 스탬프 · 실패 = 던짐(스탬프 · 아카이브는 각자 원자).
// 🔴 백업 나이 = 매매를 막지 않는다(보고 표식만).
// 🆕 E13c1 — 스탬프 **뒤** · 아카이브 **앞** 정본 자가 무결성 검사(R58 C5) · 불일치면 아카이브 건너뜀 · 🔴 `LEDGER_INTEGRITY` 는 검사가 세운다.
// 🆕 E16f3a — 무결성 일치 뒤 아카이브 ↔ 정본 관계(R130 L7): FORK(지금 FORK 이거나 관계가 FORK) = 건너뜀 + 기록 ·
//    FORK 로 바뀐 때만 P0 `DERIVED_FORK` · REBASED = 건너뜀(던지지 않음) + 관측 diff · 봉인 = 건너뜀 · 그 밖 = 아카이브.
//    🔴 FORK 판정은 리스 무관(SPEC v2.45 ⑤) · 리스 · 하루 상한 = 재생성(E16f3b)부터.
// 🆕 E16f3b — REBASED = `derivedSyncActionOf`(리스 유효 ∧ 하루 상한 안) → 재생성(파일 → 체크포인트) → 정정 행 · diff 해소
//    (R131 M2 · M5) · 미룸 = 건너뜀 + 까닭 · 🔴 EMPTY · BEHIND 로컬 이어 쓰기는 리스를 보지 않는다(원격 커밋 = E11n).

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
    this.hold,
    this.resync,
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

  /// 🆕 E16f3b — REBASED 재생성을 미룬 까닭(리스 · 하루 상한).
  final DerivedHoldReason? hold;

  /// 🆕 E16f3b — 이번 재생성 정정 행(다시 썼을 때만).
  final LedgerRepairPlanRow? resync;

  @override
  Set<String> get alerts => <String>{
    if (backup?.stale ?? false) AlertCodes.backupStale,
    ...integrity.alerts,
    if (forkRaised) kDerivedForkAlertCode,
  };

  @override
  String toString() =>
      'DailyArchiveReport(스탬프 ${stamped.length} · 무결성 ${integrity.verdict.ok ? '일치' : integrity.verdict.reason!.code} · 아카이브 ${skipped == null ? '${resync == null ? '' : '다시 씀 '}${archived.length}' : '건너뜀 ${skipped!.label}${hold == null ? '' : ' ${hold!.wire}'}'} · 백업 ${backup?.age.inHours ?? '-'}h)';
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
    required int derivedResyncDailyCap,
    List<String> Function(Database db)? sqliteIntegrity,
  }) : _operatorEpoch = operatorEpoch,
       _resyncCap = derivedResyncDailyCap < 1
           ? throw ArgumentError.value(
               derivedResyncDailyCap,
               'derivedResyncDailyCap',
               '1 이상',
             )
           : derivedResyncDailyCap,
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
  final int _resyncCap;
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

  /// ① 어제(한국)까지 스탬프 ② 정본 자가 무결성 ③ 아카이브 ↔ 정본 관계(② 일치일 때만) ④ 아카이브(FORK · 봉인 아님 ·
  /// REBASED = 리스 ∧ 상한 안이면 재생성) ⑤ 백업 나이.
  ///
  /// [lease] = 지금 리스 판정(조립 앱이 넘긴다 · 기본 UNKNOWN = 재생성하지 않음).
  DailyArchiveReport run({LeaseVerdict lease = LeaseVerdict.unknown}) {
    final List<LedgerDayStamp> stamped = LedgerHashStamper(
      _db,
      clock: _clock,
    ).stampThrough(_kstYesterday(_clock.nowUtc()));
    final LedgerIntegrityReport integrity = _integrity.run();
    List<String> archived = const <String>[];
    ArchiveSkip? skipped;
    DerivedRelation? relation;
    bool forkRaised = false;
    DerivedHoldReason? hold;
    LedgerRepairPlanRow? resync;
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
        final DateTime now = _clock.nowUtc();
        _derived.recordRebased(DerivedTarget.github, view, now);
        final DerivedSyncAction action = derivedSyncActionOf(
          relation: view.relation,
          current: current,
          lease: lease,
          resyncsToday: _derived.archiveResyncsOn(kstDateText(now)),
          dailyCap: _resyncCap,
          canon: view.canon,
          derived: view.derived,
        );
        switch (action) {
          case DerivedResync(:final String fromDate):
            // 🔴 파일 → 체크포인트 → DB(R131 M5).
            final LedgerArchiveReport rep = _writer.regenerateFrom(fromDate);
            archived = rep.days;
            resync = _derived.recordArchiveResync(
              DerivedTarget.github,
              view,
              fromDate: fromDate,
              days: rep.days.length,
              chainHash: rep.checkpoint!.chainHash,
              atUtc: now,
            );
          case DerivedHold(:final DerivedHoldReason reason):
            skipped = ArchiveSkip.rebased;
            hold = reason;
          case DerivedNoop() || DerivedForkStop():
            throw StateError('REBASED 조치가 아니다: $action');
        }
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
      hold: hold,
      resync: resync,
    );
  }
}
