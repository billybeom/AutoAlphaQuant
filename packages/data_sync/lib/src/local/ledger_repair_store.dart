// X5-3 정정 쓰기 — 새 기준점(재스탬프) · 아무것도 안 하기(설계 13 §8 R126 J1~J7 · SPEC v2.45 04 §3-1 ④ · 지도 D2).
//
// 🔴 새 기준점 = `withLedgerFix` 한 트랜잭션: 안에서 다시 판정 → 경계 X5 만 → 첫 어긋난 날 이후 스탬프를 지금 원장으로
//    다시 씀 → 다시 대조가 통과해야 → `ledger_repair` + 상세 → `LEDGER_INTEGRITY` 해제. 어디서든 실패 = 전부 되돌림.
// 🔴 본문 안에서 스탬퍼 · 무결성 검사 · 알림 `emit` 을 부르지 않는다(겹친 트랜잭션) — 셈은 core 순수 함수로.
// 🔴 아무것도 안 하기 = 그 diff 하나 OPEN → ACCEPTED(플래그는 그대로).
// 🟡 정본 정정 역분개 쓰기 = E16f2 · 파생 FORK 기록 · 아카이브 재생성 = E16f3.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show FlagIds, hashFormatVersion;
import 'package:sqlite3/sqlite3.dart';

import 'ledger_fix.dart' show withLedgerFix;
import 'ledger_hash_stamper.dart' show ledgerLinesByDay;

/// 새 기준점 거부 코드(core `BaselineCodes` 밖의 저장 쪽 사유).
abstract final class BaselineStoreCodes {
  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';

  /// `LEDGER_INTEGRITY` 가 서 있지 않다.
  static const String flagNotSet = 'BASELINE_FLAG_NOT_SET';
}

/// 새 기준점 결과.
class BaselineResult {
  const BaselineResult._({this.row, this.rejectCode});

  /// 쓴 정정 행(거부 = null).
  final LedgerRepairPlanRow? row;

  /// 거부 코드(쓰기 0 · 성공 = null).
  final String? rejectCode;

  /// 성공했나.
  bool get applied => row != null;
}

/// `ledger_repair` 쓰기 저장소(operator 원장).
class SqliteLedgerRepairStore {
  /// 만든다.
  SqliteLedgerRepairStore(this._db, {required this._trusted});

  final Database _db;
  final TrustedClock _trusted;

  bool _integrityFlagActive() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  List<StoredDayStamp> _stamps() => <StoredDayStamp>[
    for (final Row r in _db.select(
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

  LedgerIntegrityVerdict _verdict() {
    final List<String> pragma = <String>[
      for (final Row r in _db.select('PRAGMA integrity_check'))
        r.values.first.toString(),
    ];
    if (pragma.length != 1 || pragma.single != 'ok') {
      return const LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.sqliteIntegrity,
        daysChecked: 0,
      );
    }
    final List<StoredDayStamp> stamps = _stamps();
    if (stamps.isEmpty) {
      return const LedgerIntegrityVerdict.ok(
        daysChecked: 0,
        checkedThrough: null,
      );
    }
    try {
      return verifyLedgerChain(stamps, ledgerLinesByDay(_db));
    } on LedgerHashError {
      return const LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.attribution,
        daysChecked: 0,
      );
    }
  }

  /// 🔴 새 기준점 선언 — 거부면 쓰기 0 · 다른 정정 중 = `LedgerFixBusy` · 다시 쓴 뒤 대조 실패 = [StateError](되돌림).
  ///
  /// [archiveRelation] = 아카이브 체크포인트 ↔ 정본 관계(모름 = null · 호출자가 판정).
  BaselineResult applyBaseline({
    required String repairId,
    required String? decisionId,
    required String originCode,
    required String clearedBy,
    DerivedRelation? archiveRelation,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      return const BaselineResult._(
        rejectCode: BaselineStoreCodes.trustedTimeUnknown,
      );
    }
    if (!_integrityFlagActive()) {
      return const BaselineResult._(rejectCode: BaselineStoreCodes.flagNotSet);
    }
    final DateTime at = now.toUtc();
    return withLedgerFix(
      _db,
      reason: 'X5 새 기준점 $repairId',
      atUtc: at,
      body: () {
        final LedgerIntegrityVerdict verdict = _verdict();
        final LedgerBoundaryVerdict boundary = ledgerBoundaryOf(
          dbOpened: true,
          integrity: verdict,
          archiveRelation: archiveRelation,
        );
        final String? reject = baselineRejectCode(
          boundary,
          decisionId: decisionId,
          originCode: originCode,
        );
        if (reject != null) return BaselineResult._(rejectCode: reject);
        final List<StoredDayStamp> before = _stamps();
        final LedgerRepairPlanRow plan = baselinePlanOf(
          boundary,
          repairId: repairId,
          decisionId: decisionId,
          originCode: originCode,
          reasonWire: verdict.reason!.code,
          stamps: before,
          appliedAtUtc: at,
        );
        final String head = _restampFrom(plan.recomputedFrom!, before, at);
        final LedgerIntegrityVerdict after = verifyLedgerChain(
          _stamps(),
          ledgerLinesByDay(_db),
        );
        if (!after.ok) {
          throw StateError('다시 쓴 스탬프가 대조를 통과하지 못한다: ${after.reason!.code}');
        }
        final String iso = at.toIso8601String();
        _db.execute(
          'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
          'evidence_hash, supersedes, applied_at) VALUES (?, ?, ?, ?, ?, ?, NULL, ?)',
          <Object?>[
            plan.repairId,
            plan.diffId,
            plan.direction.wire,
            plan.originCode,
            plan.decisionId,
            plan.evidenceHash,
            iso,
          ],
        );
        _db.execute(
          'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
          'VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            plan.repairId,
            plan.recomputedFrom,
            head,
            '{"kind":"LEDGER_INTEGRITY"}',
            plan.evidenceJson,
          ],
        );
        _db.execute(
          'UPDATE trading_block SET cleared_at = ?, cleared_by = ?, decision_id = ?, origin_code = ? '
          'WHERE flag_id = ? AND cleared_at IS NULL',
          <Object?>[
            iso,
            clearedBy,
            plan.decisionId,
            plan.originCode,
            FlagIds.ledgerIntegrity,
          ],
        );
        if (_db.updatedRows != 1) {
          throw StateError('LEDGER_INTEGRITY 해제가 1행이 아니다: ${_db.updatedRows}');
        }
        return BaselineResult._(
          row: LedgerRepairPlanRow(
            repairId: plan.repairId,
            diffId: plan.diffId,
            direction: plan.direction,
            originCode: plan.originCode,
            evidenceHash: plan.evidenceHash,
            appliedAtUtc: at,
            decisionId: plan.decisionId,
            recomputedFrom: plan.recomputedFrom,
            chainHash: head,
            targetJson: '{"kind":"LEDGER_INTEGRITY"}',
            evidenceJson: plan.evidenceJson,
          ),
        );
      },
    );
  }

  /// [from] ~ 원래 마지막 스탬프 날(달력일 연속)을 지금 원장으로 다시 쓴다(앞 체인부터) — 다시 쓴 마지막 체인.
  ///
  /// 첫 스탬프 앞날의 행(`ROWS_BEFORE_FIRST_STAMP`)이면 [from] 이 첫 스탬프보다 앞이라 그 날부터 새로 스탬프한다.
  String _restampFrom(String from, List<StoredDayStamp> before, DateTime at) {
    if (before.isEmpty) throw StateError('스탬프가 없다');
    final String last = before.last.authoredDate;
    if (from.compareTo(last) > 0) {
      throw StateError('다시 쓸 스탬프가 없다: $from 이후');
    }
    final List<StoredDayStamp> head = before
        .where((StoredDayStamp s) => s.authoredDate.compareTo(from) < 0)
        .toList();
    final Map<String, Map<String, List<String>>> byDay = ledgerLinesByDay(_db);
    _db.execute(
      'DELETE FROM ledger_daily_hash WHERE authored_date >= ?',
      <Object?>[from],
    );
    String prev = head.isEmpty ? kChainGenesis : head.last.chainHash;
    final String iso = at.toIso8601String();
    for (String d = from; d.compareTo(last) <= 0; d = _nextDay(d)) {
      final Map<String, List<String>> lines =
          byDay[d] ?? const <String, List<String>>{};
      final String day = dayHashOf(lines);
      final String chain = chainHashOf(prev, day);
      _db.execute(
        'INSERT INTO ledger_daily_hash(authored_date, day_hash, chain_hash, hash_format_version, '
        'row_counts, created_at) VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>[d, day, chain, hashFormatVersion, rowCountsJson(lines), iso],
      );
      prev = chain;
    }
    return prev;
  }

  static String _nextDay(String ymd) {
    final DateTime d = DateTime.parse('${ymd}T00:00:00Z')
        .add(const Duration(days: 1));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 🔴 아무것도 안 하기 — 그 diff 하나 OPEN → ACCEPTED(OPEN 아님 = false · 플래그 그대로).
  bool acceptDiff(String diffId) {
    _db.execute(
      "UPDATE ledger_diff SET status = 'ACCEPTED' WHERE diff_id = ? AND status = 'OPEN'",
      <Object?>[diffId],
    );
    return _db.updatedRows == 1;
  }
}
