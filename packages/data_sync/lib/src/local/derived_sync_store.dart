// X5-4 파생 FORK 기록 · 아카이브 관계(설계 13 §8 R130 L2~L10 · SPEC v2.45 04 §3-1 ⑤ · §5-3 v2.45).
//
// 🔴 정본 체인 = `ledger_daily_hash` 스탬프 + 새 기준점(`ledger_repair` ⋈ 상세 `LEDGER_INTEGRITY` 의 다시 센 첫 날).
// 🔴 `sync_state` 쓰기 = FORK 일 때만 — SEALED 는 덮지 않는다(봉인이 풀린다) · OK 행을 만들지 않는다(보드 «연결됨») ·
//    `last_ok_at` 은 손대지 않는다(원격 성공의 뜻 · 백업 나이).
// 🔴 FORK 로 **바뀐 때만** true(끈적 — 다시 알리지 않는다) · 체인 diff = INSERT OR IGNORE(관측 · 같은 내용 = 같은 id).
// 🔴 기록 = 저장소 한 트랜잭션(정본 정정이 아니라 `withLedgerFix` 밖).
// 🆕 E16f3b — 아카이브 재생성 기록(R131 M3 · M4): REBASED diff RESOLVED + `DERIVED_RESYNC` `ARCHIVE_DAYS` 정정 행 + 상세 ·
//    id = 대상 · 첫 날 · 체인의 해시(다시 돌려도 한 행) · 오늘 횟수 = 한국 날 그 행 수(하루 상한).

import 'dart:convert' show jsonEncode, utf8;

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:domain_contracts/domain_contracts.dart'
    show DiffStatus, OriginCodes;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'ledger_archive_writer.dart' show LedgerArchiveWriter;

/// `ledger_daily_hash` 스탬프(날 차례).
List<StoredDayStamp> storedDayStampsOf(Database db) => <StoredDayStamp>[
  for (final Row r in db.select(
    'SELECT authored_date, day_hash, chain_hash, hash_format_version '
    'FROM ledger_daily_hash ORDER BY authored_date',
  ))
    StoredDayStamp(
      authoredDate: r['authored_date'] as String,
      dayHash: r['day_hash'] as String,
      chainHash: r['chain_hash'] as String,
      hashFormatVersion: r['hash_format_version'] as int,
    ),
];

/// 🔴 정본 체인 — 스탬프 + 새 기준점 · [operatorEpoch] = 이 기기 epoch(아카이브 쓰기와 같은 값 · 다르면 EPOCH_AHEAD).
///
/// 새 기준점 행에 다시 센 첫 날 · 결정이 없으면 [StateError](지어내지 않는다).
CanonChain canonChainOf(Database db, {required int operatorEpoch}) =>
    CanonChain(
      stamps: storedDayStampsOf(db),
      operatorEpoch: operatorEpoch,
      baselines: <ChainBaseline>[
        for (final Row r in db.select(
          'SELECT r.repair_id, d.recomputed_from, r.decision_id FROM ledger_repair r '
          'JOIN ledger_repair_detail d ON d.repair_id = r.repair_id '
          "WHERE r.direction = 'CANON_CORRECT' "
          "AND json_extract(d.target_json, '\$.kind') = 'LEDGER_INTEGRITY' "
          'ORDER BY d.recomputed_from, r.repair_id',
        ))
          ChainBaseline(
            fromDate:
                r['recomputed_from'] as String? ??
                (throw StateError('새 기준점에 다시 센 첫 날이 없다: ${r['repair_id']}')),
            decisionId:
                r['decision_id'] as String? ??
                (throw StateError('새 기준점에 결정이 없다: ${r['repair_id']}')),
          ),
      ],
    );

/// 🆕 E16f3b — 재생성 정정 행 id(대상 · 첫 날 · 체인 · 다시 돌려도 같은 id · R131 M3).
String archiveResyncRepairIdOf(
  DerivedTarget target,
  String fromDate,
  String chainHash,
) =>
    'rs-${sha256.convert(utf8.encode('${target.syncTarget}|$fromDate|$chainHash')).toString().substring(0, 24)}';

/// 아카이브 ↔ 정본 관계 한 판.
typedef DerivedView = ({
  CanonChain canon,
  DerivedStamp? derived,
  DerivedRelation relation,
});

/// 파생 동기 상태 · FORK 기록 저장소(operator 원장).
class SqliteDerivedSyncStore {
  /// 만든다.
  SqliteDerivedSyncStore(this._db);

  final Database _db;

  /// 지금 상태(행 없음 = OK).
  DerivedSyncStatus statusOf(DerivedTarget target) {
    final ResultSet r = _db.select(
      'SELECT status FROM sync_state WHERE target = ?',
      <Object?>[target.syncTarget],
    );
    return r.isEmpty
        ? DerivedSyncStatus.ok
        : DerivedSyncStatus.parse(r.single['status'] as String);
  }

  /// 아카이브(GITHUB 로컬 체크포인트) ↔ 정본 관계 — 🔵 E16j 가 `applyBaseline` 의 아카이브 관계로도 쓴다.
  ///
  /// 체크포인트를 못 읽으면 `LedgerArchiveError`(그대로 던진다).
  DerivedView archiveView(
    LedgerArchiveWriter writer, {
    required int operatorEpoch,
  }) {
    final CanonChain canon = canonChainOf(_db, operatorEpoch: operatorEpoch);
    final ArchiveCheckpoint? cp = writer.readCheckpoint();
    final DerivedStamp? derived = cp == null
        ? null
        : DerivedStamp.fromCheckpoint(cp);
    return (
      canon: canon,
      derived: derived,
      relation: derivedRelationOf(canon, derived),
    );
  }

  /// 🔴 FORK 기록 — 한 트랜잭션: `sync_state` FORK(SEALED · 이미 FORK = 그대로) + 체인 diff(관측 · INSERT OR IGNORE).
  ///
  /// 이번에 FORK 로 바뀌었으면 true · 관계가 FORK 도 아니고 지금 FORK 도 아니면 [ArgumentError].
  bool recordFork(
    DerivedTarget target,
    DerivedView view,
    DateTime atUtc,
  ) => inLedgerTransaction(_db, () {
    if (!view.relation.forks && statusOf(target) != DerivedSyncStatus.fork) {
      throw ArgumentError.value(view.relation.wire, 'relation', 'FORK 가 아니다');
    }
    final String at = atUtc.toUtc().toIso8601String();
    _db.execute(
      'INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) '
      'VALUES (?, NULL, ?, ?, ?) '
      'ON CONFLICT(target) DO UPDATE SET status = excluded.status, updated_at = excluded.updated_at '
      'WHERE sync_state.status NOT IN (?, ?)',
      <Object?>[
        target.syncTarget,
        DerivedSyncStatus.fork.wire,
        view.canon.operatorEpoch,
        at,
        DerivedSyncStatus.fork.wire,
        DerivedSyncStatus.sealed.wire,
      ],
    );
    final bool changed = _db.updatedRows == 1;
    _insertDiff(target, view, at);
    return changed;
  });

  /// REBASED 관측 diff(재생성 전 · E16f3b 가 해소한다) — 넣었으면 true · REBASED 아님 = [ArgumentError].
  bool recordRebased(DerivedTarget target, DerivedView view, DateTime atUtc) {
    if (view.relation != DerivedRelation.rebased) {
      throw ArgumentError.value(
        view.relation.wire,
        'relation',
        'REBASED 가 아니다',
      );
    }
    return inLedgerTransaction(
      _db,
      () => _insertDiff(target, view, atUtc.toUtc().toIso8601String()),
    );
  }

  /// 🆕 E16f3b — 한국 날 [kstDay] 의 아카이브 재생성 횟수(`DERIVED_RESYNC` × `ARCHIVE_DAYS` · 하루 상한 · R131 M2).
  int archiveResyncsOn(String kstDay) =>
      _db.select(
            'SELECT COUNT(*) AS n FROM ledger_repair r '
            'JOIN ledger_repair_detail d ON d.repair_id = r.repair_id '
            "WHERE r.direction = 'DERIVED_RESYNC' "
            "AND json_extract(d.target_json, '\$.kind') = 'ARCHIVE_DAYS' "
            "AND date(r.applied_at, '+9 hours') = ?",
            <Object?>[kstDay],
          ).single['n']
          as int;

  /// 🔴 아카이브 재생성 기록(R131 M3 · M4) — 한 트랜잭션: REBASED diff(없으면 넣고) RESOLVED + `DERIVED_RESYNC` 정정 행 + 상세.
  ///
  /// 같은 첫 날 · 체인 = 같은 id(INSERT OR IGNORE · 다시 돌려도 한 행) · REBASED 아님 = [ArgumentError].
  LedgerRepairPlanRow recordArchiveResync(
    DerivedTarget target,
    DerivedView view, {
    required String fromDate,
    required int days,
    required String chainHash,
    required DateTime atUtc,
  }) {
    if (view.relation != DerivedRelation.rebased) {
      throw ArgumentError.value(
        view.relation.wire,
        'relation',
        'REBASED 가 아니다',
      );
    }
    if (days < 0) throw ArgumentError.value(days, 'days', '0 이상');
    final DerivedChainDiff d = derivedChainDiffOf(
      target,
      view.relation,
      view.canon,
      view.derived,
    )!;
    final DateTime at = atUtc.toUtc();
    final LedgerRepairPlanRow row = LedgerRepairPlanRow(
      repairId: archiveResyncRepairIdOf(target, fromDate, chainHash),
      diffId: d.diffId,
      direction: RepairDirection.derivedResync,
      originCode: OriginCodes.chainBroken,
      evidenceHash: evidenceHashOf(d.deltaJson),
      appliedAtUtc: at,
      recomputedFrom: fromDate,
      chainHash: chainHash,
      targetJson: jsonEncode(<String, Object?>{
        'kind': 'ARCHIVE_DAYS',
        'count': days,
      }),
      evidenceJson: d.deltaJson,
    );
    return inLedgerTransaction(_db, () {
      final String iso = at.toIso8601String();
      _insertDiff(target, view, iso);
      _db.execute(
        'UPDATE ledger_diff SET status = ?, origin_code = ? WHERE diff_id = ? AND status = ?',
        <Object?>[
          DiffStatus.resolved.wire,
          row.originCode,
          row.diffId,
          DiffStatus.open.wire,
        ],
      );
      _db.execute(
        'INSERT OR IGNORE INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
        'evidence_hash, supersedes, applied_at) VALUES (?, ?, ?, ?, NULL, ?, NULL, ?)',
        <Object?>[
          row.repairId,
          row.diffId,
          row.direction.wire,
          row.originCode,
          row.evidenceHash,
          iso,
        ],
      );
      _db.execute(
        'INSERT OR IGNORE INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, '
        'evidence_json) VALUES (?, ?, ?, ?, ?)',
        <Object?>[
          row.repairId,
          row.recomputedFrom,
          row.chainHash,
          row.targetJson,
          row.evidenceJson,
        ],
      );
      return row;
    });
  }

  bool _insertDiff(DerivedTarget target, DerivedView view, String at) {
    final DerivedChainDiff? d = derivedChainDiffOf(
      target,
      view.relation,
      view.canon,
      view.derived,
    );
    if (d == null) return false;
    _db.execute(
      'INSERT OR IGNORE INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, '
      'severity, origin_code, status, detected_at, applicable) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, 1)',
      <Object?>[
        d.diffId,
        d.pair.wire,
        d.axis.wire,
        d.authoredDate,
        d.deltaJson,
        d.label,
        d.severity.wire,
        DiffStatus.open.wire,
        at,
      ],
    );
    return _db.updatedRows == 1;
  }
}
