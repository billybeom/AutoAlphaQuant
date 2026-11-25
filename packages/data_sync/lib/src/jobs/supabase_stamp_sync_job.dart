// 🆕 미결 244 ⓑ — X5 `canonSupabase` 스탬프 실행기(설계 13 §8 R271 O5 · O6 · O7 · 01 §8 미결 244 · R112 D4 · R130 · R131 ·
// 계약 v1.40 §49 K356 `ledger_stamp` = 덮음 · `operator_epoch` = 인자 epoch). GitHub 짝 = `DailyArchiveJob`(R130 · R131).
//
// 🔵 차례 — ① 리스 없음(기기 id 없음 · epoch 0) = 아무것도 안 함 ② 정본 무결성 깃발(`LEDGER_INTEGRITY` 열림) = 건너뜀(깨진 체인을 내보내지
//    않는다 · 아카이브 «무결성 불일치 = 건너뜀» 짝) ③ 지금 상태(`sync_state` SUPABASE) FORK = 건너뜀(끈적 · 사람만 해제) · SEALED = 건너뜀(리스
//    봉인) — 둘 다 망 0 ④ 대조 읽기 = 원격 `ledger_stamp` 그 모드 마지막 한 행(실패 = 다음에 다시 · FORK 로 읽지 않는다) ⑤ 관계
//    (`derivedRelationOf` · epoch 먼저) → FORK = 기록 + P0 `DERIVED_FORK`(바뀐 때만) ⑥ REBASED = 관측 diff ⑦ 조치 = `derivedSyncActionOf`
//    (리스 = 할 일이 있을 때만 묻는다 · 하루 상한 = 운영 설정 · 오늘 횟수 = `LEDGER_STAMPS` 정정 행) ⑧ 재생성 = fromDate ~ 마지막 스탬프를
//    날 오름차순 `op_push`(덮음 = 같은 날 다시 씀 · 부분 성공 = 앞쪽만 → 다음 판정이 BEHIND · REBASED 로 이어 간다) ⑨ REBASED 를 다 보냄 =
//    정정 행(`DERIVED_RESYNC` · `LEDGER_STAMPS`) + diff 해소.
// 🔴 정본 epoch = 이 기기가 쥔 SUPABASE 리스 epoch — 원격 행 `operator_epoch` = 쓴 기기의 리스 epoch(서버가 덮음) · 더 크면 EPOCH_AHEAD(새 폰 ·
//    복원 롤백) = FORK.
// 🔴 EMPTY · BEHIND = 일상 이어 쓰기(정정 행 0 — GitHub 와 같다) · 삭제 0(op_push).
// 🔴 `sync_state` 쓰기 = FORK 때만(R130 L4 · R229 «리스 성공이 FORK 를 지우지 않는다») · `last_ok_at` = 리스 몫이라 손대지 않는다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, FlagIds, OpsPushTables, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../local/derived_sync_store.dart';
import '../supabase/supabase_ledger_stamp_read.dart';
import '../supabase/supabase_ops_push.dart';
import 'ops_push_send.dart';

/// 원격 사본 스탬프 대조의 알림 출처(`alert_event.source`).
const String kSupabaseStampCheck = 'derived_supabase';

/// 스탬프를 보내지 않은 까닭.
enum SupabaseStampSkip {
  /// 정본 무결성 깃발이 열려 있다.
  integrity('무결성'),

  /// 원격 사본 FORK(끈적).
  fork('FORK'),

  /// 리스 봉인.
  sealed('봉인'),

  /// 원격을 읽지 못했다(다음에 다시).
  read('읽기 실패');

  const SupabaseStampSkip(this.label);

  /// 보고 글자.
  final String label;
}

/// 한 번의 보고서(🔴 체인 · 행 값 0).
class SupabaseStampReport {
  /// 만든다.
  const SupabaseStampReport({
    this.noLease = false,
    this.skipped,
    this.readFailure,
    this.relation,
    this.forkRaised = false,
    this.hold,
    this.push,
    this.pushedDays = const <String>[],
    this.resync,
  });

  /// 리스가 없어 하지 않았다.
  final bool noLease;

  /// 보내지 않은 까닭.
  final SupabaseStampSkip? skipped;

  /// 읽기 실패 종류([SupabaseStampSkip.read] 일 때).
  final LedgerStampReadFailure? readFailure;

  /// 원격 사본 ↔ 정본 관계(판정 전 = null).
  final DerivedRelation? relation;

  /// 이번에 FORK 로 바뀌었나(P0 `DERIVED_FORK` 한 번).
  final bool forkRaised;

  /// 재생성을 미룬 까닭(리스 · 하루 상한).
  final DerivedHoldReason? hold;

  /// `ledger_stamp` push 결과(보냈을 때만).
  final OpsTablePush? push;

  /// 이번에 보낸 날(push 가 OK 일 때만).
  final List<String> pushedDays;

  /// 이번 재생성 정정 행(REBASED 를 다 보냈을 때만).
  final LedgerRepairPlanRow? resync;

  /// 낼 알림 코드.
  Set<String> get alerts => <String>{if (forkRaised) kDerivedForkAlertCode};

  /// 사람이 볼 push 실패(경보 = 미결 243 ⓒ 자리 · K344 결).
  List<OpsTablePush> get failed => <OpsTablePush>[
    if (push case final OpsTablePush p when p.outcome == OpsPushOutcome.failed)
      p,
  ];

  @override
  String toString() {
    if (noLease) return 'SupabaseStampReport(리스 없음)';
    final String rel = relation?.wire ?? '-';
    if (skipped != null) {
      return 'SupabaseStampReport(건너뜀 ${skipped!.label}'
          '${readFailure == null ? '' : ' ${readFailure!.name}'} · $rel)';
    }
    if (hold != null) return 'SupabaseStampReport($rel · 미룸 ${hold!.wire})';
    return 'SupabaseStampReport($rel · 보냄 ${pushedDays.length}'
        '${push == null || push!.outcome == OpsPushOutcome.ok ? '' : ' · ${push!.outcome.name} ${push!.reason}'}'
        '${resync == null ? '' : ' · 다시 씀'})';
  }
}

/// 🆕 X5 원격 사본(Supabase) 스탬프 실행기.
class SupabaseStampSyncJob {
  /// 만든다 — [derivedResyncDailyCap] = 하루 재생성 상한(운영 설정 `migration.derived_resync_daily_cap` · 기본값 없음 · 1 미만 =
  /// [ArgumentError]).
  SupabaseStampSyncJob(
    this._db, {
    required this.clock,
    required this.reader,
    required this.pusher,
    required int derivedResyncDailyCap,
    this.chunk = kOpsPushChunk,
  }) : dailyCap = derivedResyncDailyCap < 1
           ? throw ArgumentError.value(
               derivedResyncDailyCap,
               'derivedResyncDailyCap',
               '1 이상',
             )
           : derivedResyncDailyCap,
       _derived = SqliteDerivedSyncStore(_db);

  final Database _db;
  final SqliteDerivedSyncStore _derived;

  /// 기기 시계(기록 시각 · 한국 날).
  final Clock clock;

  /// 대조 읽기 포트.
  final LedgerStampReader reader;

  /// push 포트.
  final OpsPusher pusher;

  /// 하루 재생성 상한.
  final int dailyCap;

  /// 한 번에 보내는 행 수 상한.
  final int chunk;

  bool _integrityBlocked() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// 한 번 돈다 — 이 기기 [deviceId] · 쥔 SUPABASE 리스 [epoch] · 행 mode = [mode] · [lease] = 리스 판정(할 일이 있을 때만 부른다).
  Future<SupabaseStampReport> run({
    required String? deviceId,
    required int epoch,
    required RunMode mode,
    required Future<LeaseVerdict> Function() lease,
  }) async {
    if (deviceId == null || deviceId.isEmpty || epoch <= 0) {
      return const SupabaseStampReport(noLease: true);
    }
    if (_integrityBlocked()) {
      return const SupabaseStampReport(skipped: SupabaseStampSkip.integrity);
    }
    final DerivedSyncStatus current = _derived.statusOf(DerivedTarget.supabase);
    if (current == DerivedSyncStatus.fork) {
      return const SupabaseStampReport(skipped: SupabaseStampSkip.fork);
    }
    if (current == DerivedSyncStatus.sealed) {
      return const SupabaseStampReport(skipped: SupabaseStampSkip.sealed);
    }
    final LedgerStampRead read = await reader.lastStamp(mode);
    if (read.failure != null) {
      return SupabaseStampReport(
        skipped: SupabaseStampSkip.read,
        readFailure: read.failure,
      );
    }
    final DerivedView view = _derived.supabaseView(
      read.stamp,
      operatorEpoch: epoch,
    );
    final DerivedRelation relation = view.relation;
    if (relation.forks) {
      return SupabaseStampReport(
        skipped: SupabaseStampSkip.fork,
        relation: relation,
        forkRaised: _derived.recordFork(
          DerivedTarget.supabase,
          view,
          clock.nowUtc(),
        ),
      );
    }
    if (relation == DerivedRelation.inSync) {
      return SupabaseStampReport(relation: relation);
    }
    final DateTime now = clock.nowUtc();
    if (relation == DerivedRelation.rebased) {
      _derived.recordRebased(DerivedTarget.supabase, view, now);
    }
    final DerivedSyncAction action = derivedSyncActionOf(
      relation: relation,
      current: current,
      lease: await lease(),
      resyncsToday: _derived.resyncsOn(
        DerivedTarget.supabase,
        kstDateText(now),
      ),
      dailyCap: dailyCap,
      canon: view.canon,
      derived: view.derived,
    );
    switch (action) {
      case DerivedHold(:final DerivedHoldReason reason):
        return SupabaseStampReport(relation: relation, hold: reason);
      case DerivedNoop() || DerivedForkStop():
        throw StateError('원격 사본 조치가 아니다: $action');
      case DerivedResync(:final String fromDate):
        final List<StoredDayStamp> days = <StoredDayStamp>[
          for (final StoredDayStamp s in view.canon.stamps)
            if (s.authoredDate.compareTo(fromDate) >= 0) s,
        ];
        final OpsTablePush push = await sendOpsRows(
          pusher,
          deviceId: deviceId,
          epoch: epoch,
          table: OpsPushTables.ledgerStamp,
          rows: <Map<String, Object?>>[
            for (final StoredDayStamp s in days)
              <String, Object?>{
                'mode': mode.wire,
                'authored_date': s.authoredDate,
                'chain_hash': s.chainHash,
              },
          ],
          chunk: chunk,
        );
        if (push.outcome != OpsPushOutcome.ok) {
          return SupabaseStampReport(relation: relation, push: push);
        }
        return SupabaseStampReport(
          relation: relation,
          push: push,
          pushedDays: <String>[
            for (final StoredDayStamp s in days) s.authoredDate,
          ],
          resync: relation == DerivedRelation.rebased
              ? _derived.recordResync(
                  DerivedTarget.supabase,
                  view,
                  fromDate: fromDate,
                  days: days.length,
                  chainHash: view.canon.stamps.last.chainHash,
                  atUtc: now,
                )
              : null,
        );
    }
  }
}
