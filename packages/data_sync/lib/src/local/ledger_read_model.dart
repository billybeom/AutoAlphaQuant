// X5 읽기 쪽 operator 판 — `LedgerRepository` · 5칸 대조 보드(앱 계약 01 §2-9 · §4-1 · §23 · 설계 13 §8 R59 S0~S9).
//
// 🔴 글자 · 순서 · 색 = core `ledger_views.dart` · 여기는 SQL 로 재료만 모은다.
// 🔴 갱신 = 같은 연결의 `db.updates` → 다시 읽어 바뀐 때만 내보낸다(구독 즉시 1회 · R59 S8).
// 🔴 `watchExternalHoldings` = 생산자(E18) 전이라 빈 봉투 — 행이 생기면 스트림 오류(R59 S9).
// 🆕 E16f1(설계 13 §8 R126 J6) — `watchRepairs` 실물 = `ledger_repair` ⋈ 상세 → core `ledgerRepairRowsOf`(상세 없는 행 = 스트림 오류).

import 'dart:async';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';

/// [read] 를 구독 즉시 1회 · [tables] 가 바뀔 때마다 다시 읽어 바뀐 값만 내보낸다(R59 S8).
Stream<T> watchLedgerQuery<T>(
  Database db,
  Set<String> tables,
  T Function() read,
) {
  late final StreamController<T> out;
  StreamSubscription<SqliteUpdate>? sub;
  bool has = false;
  bool pending = false;
  T? last;
  void emit() {
    pending = false;
    if (out.isClosed) return; // 해지 뒤에 남은 타이머.
    try {
      final T v = read();
      if (has && v == last) return;
      has = true;
      last = v;
      out.add(v);
    } on Object catch (e, st) {
      out.addError(e, st);
    }
  }

  out = StreamController<T>(
    onListen: () {
      emit();
      sub = db.updates.listen((SqliteUpdate u) {
        if (!tables.contains(u.tableName) || pending) return;
        pending = true;
        // 🔴 갱신 알림은 행마다 마이크로태스크로 온다 — 다음 이벤트 루프 차례로 미뤄 한 트랜잭션을 한 번으로 묶는다.
        Timer.run(emit);
      });
    },
    onCancel: () async {
      await sub?.cancel();
      await out.close();
    },
  );
  return out.stream;
}

/// 브로커 대사 행(`rc-` · 해제 행 제외)의 마지막 시각 · 행동.
(DateTime?, String?) _lastBrokerRecon(Database db) {
  final ResultSet rs = db.select(
    "SELECT run_at, action_taken FROM reconciliation_log WHERE recon_id LIKE 'rc-%' "
    "AND recon_id NOT LIKE 'rc-clear-%' ORDER BY run_at DESC, recon_id DESC LIMIT 1",
  );
  if (rs.isEmpty) return (null, null);
  return (
    DateTime.parse(rs.first['run_at'] as String).toUtc(),
    rs.first['action_taken'] as String?,
  );
}

/// 🆕 E11p3b-3(R93) — 마지막 브로커 대사 시각(FGS «마지막 대사 HH:MM» · 위와 같은 규칙).
DateTime? lastBrokerReconUtc(Database db) => _lastBrokerRecon(db).$1;

/// 대조 차이 저장 행 전부(+ 브로커 쌍의 닫힌 시각 · R59 S2).
List<StoredLedgerDiff> storedLedgerDiffs(Database db) {
  final List<DateTime> clears = <DateTime>[
    for (final Row r in db.select(
      "SELECT run_at FROM reconciliation_log WHERE recon_id LIKE 'rc-clear-%'",
    ))
      DateTime.parse(r['run_at'] as String).toUtc(),
  ]..sort();
  return <StoredLedgerDiff>[
    for (final Row r in db.select('SELECT * FROM ledger_diff'))
      () {
        DateTime? closed;
        if (r['status'] != DiffStatus.open.wire &&
            r['pair'] == LedgerPair.canonBroker.wire) {
          final DateTime detected = DateTime.parse(r['detected_at'] as String)
              .toUtc();
          for (final DateTime c in clears) {
            if (!c.isBefore(detected)) {
              closed = c;
              break;
            }
          }
        }
        return StoredLedgerDiff.fromColumns(<String, Object?>{
          for (final String k in r.keys) k: r[k],
        }, closedAtUtc: closed);
      }(),
  ];
}

/// 🆕 E16f1 — 저장된 정정 행(`ledger_repair` ⋈ 상세 · R126 J6) — 🔴 상세 없는 행 = [StateError](지어내지 않는다).
List<StoredLedgerRepair> storedLedgerRepairs(Database db) =>
    <StoredLedgerRepair>[
      for (final Row r in db.select(
        'SELECT r.repair_id, r.diff_id, r.direction, r.origin_code, r.decision_id, r.evidence_hash, '
        'r.supersedes, r.applied_at, d.recomputed_from, d.chain_hash, d.target_json '
        'FROM ledger_repair r LEFT JOIN ledger_repair_detail d ON d.repair_id = r.repair_id '
        'ORDER BY r.applied_at, r.repair_id',
      ))
        StoredLedgerRepair(
          repairId: r['repair_id'] as String,
          diffId: r['diff_id'] as String,
          direction: r['direction'] as String,
          originCode: r['origin_code'] as String,
          evidenceHash: r['evidence_hash'] as String,
          appliedAtUtc: DateTime.parse(r['applied_at'] as String).toUtc(),
          chainHash:
              r['chain_hash'] as String? ??
              (throw StateError('정정 상세가 없다: ${r['repair_id']}')),
          targetJson:
              r['target_json'] as String? ??
              (throw StateError('정정 대상이 없다: ${r['repair_id']}')),
          decisionId: r['decision_id'] as String?,
          supersedes: r['supersedes'] as String?,
          recomputedFrom: r['recomputed_from'] as String?,
        ),
    ];

/// `LedgerRepository` operator 판(R59 S0).
class SqliteLedgerRepository implements LedgerRepository {
  /// 저장소를 만든다.
  SqliteLedgerRepository(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  AsOf _asOf(String prefix) => reconAsOf(
    lastReconUtc: _lastBrokerRecon(_db).$1,
    nowUtc: _clock.nowUtc(),
    prefix: prefix,
  );

  /// `L-1` 지금 값(R59 S1).
  ListResult<LedgerDiffRow> recentDiffs() => recentLedgerDiffsOf(
    storedLedgerDiffs(_db),
    nowUtc: _clock.nowUtc(),
    asOf: _asOf('대조 기준'),
  );

  @override
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs() => watchLedgerQuery(
    _db,
    const <String>{'ledger_diff', 'reconciliation_log'},
    recentDiffs,
  );

  ListResult<T> _emptyOrUnsupported<T>(
    String table,
    String prefix,
    String label,
    String owner,
  ) {
    final bool any = _db.select('SELECT 1 FROM $table LIMIT 1').isNotEmpty;
    if (any) {
      throw UnsupportedError('$table 표시 = $owner(생산자와 같은 판)');
    }
    return emptyLedgerList<T>(_asOf(prefix), label);
  }

  /// 🆕 E16f1 — 정정 이력 지금 값(R126 J6 · 상한 [limit]).
  ListResult<LedgerRepairRow> repairs({int limit = 50}) {
    final List<LedgerRepairRow> rows = ledgerRepairRowsOf(
      storedLedgerRepairs(_db),
    );
    return ListResult<LedgerRepairRow>(
      rows: rows.take(limit).toList(),
      asOf: _asOf('정정 이력 기준'),
      emptyKind: EmptyKind.noData,
      emptyLabel: rows.isEmpty ? '정정 이력이 없습니다' : null,
      hasMore: rows.length > limit,
    );
  }

  @override
  Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50}) =>
      watchLedgerQuery(_db, const <String>{
        'ledger_repair',
        'ledger_repair_detail',
        'reconciliation_log',
      }, () => repairs(limit: limit));

  @override
  Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings() =>
      watchLedgerQuery(
        _db,
        const <String>{'external_holding', 'reconciliation_log'},
        () => _emptyOrUnsupported<ExternalHoldingRow>(
          'external_holding',
          '대조 기준',
          '시스템 밖 자산이 없습니다',
          'E18',
        ),
      );
}

/// 파생 쌍 ↔ `sync_state.target`.
const Map<LedgerPair, String> kDerivedSyncTargets = <LedgerPair, String>{
  LedgerPair.canonSupabase: 'SUPABASE',
  LedgerPair.canonGithub: 'GITHUB',
  LedgerPair.canonCalendar: 'CALENDAR',
};

/// 5칸 대조 보드 원천(`OpsRepository.watchDiagnostics` 의 operator 판 · R59 S5~S7).
class LedgerDiagnosticsSource {
  /// 원천을 만든다 — [operatingMode] = 지금 운영 모드(조립 앱이 안다).
  LedgerDiagnosticsSource(
    this._db, {
    required this._clock,
    required this._operatingMode,
  });

  final Database _db;
  final Clock _clock;
  final OperatingMode Function() _operatingMode;

  /// 지금 값.
  DiagnosticsVm diagnostics() {
    final (DateTime? lastAt, String? lastAction) = _lastBrokerRecon(_db);
    final Set<LedgerAxis> blockingAxes = <LedgerAxis>{};
    bool observational = false;
    final Map<LedgerPair, List<List<String>>> open =
        <LedgerPair, List<List<String>>>{};
    for (final StoredLedgerDiff d in storedLedgerDiffs(_db)) {
      if (d.status != DiffStatus.open || !d.applicable) continue;
      if (d.pair == LedgerPair.canonBroker) {
        if (d.severity == DiffSeverity.blocking) {
          blockingAxes.add(d.axis);
        } else {
          observational = true;
        }
      } else {
        (open[d.pair] ??= <List<String>>[]).add(candidatesOfDelta(d.delta));
      }
    }
    final Set<String> connected = <String>{
      for (final Row r in _db.select('SELECT target FROM sync_state'))
        r['target'] as String,
    };
    return diagnosticsOf(
      mode: _operatingMode(),
      broker: BrokerReconSummary(
        reconRan: lastAt != null,
        lastActionCode: lastAction,
        openBlockingAxes: blockingAxes,
        openObservational: observational,
      ),
      derived: <LedgerPair, DerivedPairSummary>{
        for (final MapEntry<LedgerPair, String> e
            in kDerivedSyncTargets.entries)
          e.key: DerivedPairSummary(
            connected: connected.contains(e.value),
            openCandidates: open[e.key] ?? const <List<String>>[],
          ),
      },
      asOf: reconAsOf(lastReconUtc: lastAt, nowUtc: _clock.nowUtc()),
    );
  }

  /// 구독 — 대조 · 대사 · 연결 상태가 바뀔 때마다.
  Stream<DiagnosticsVm> watchDiagnostics() => watchLedgerQuery(
    _db,
    const <String>{'ledger_diff', 'reconciliation_log', 'sync_state'},
    diagnostics,
  );
}
