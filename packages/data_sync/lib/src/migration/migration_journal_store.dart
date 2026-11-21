// X1-2 이전 저널 저장(옛 폰 · 설계 13 §8 R132 N3~N6 · N10 · SPEC v2.45 04 §3-1 ①② · 앱 06 X1-2).
//
// 🔴 append-only · 단계마다 ENTERED → DONE | FAILED(키 = 이전 · 단계 · 상태 · INSERT OR IGNORE = 재개 멱등).
// 🔴 차례 · 막는 사실 · 되돌릴 수 없는 점 = core 순수 함수(`planNextOf` · `planStepBlockCode` · `mayFail`) 그대로.
// 🔴 DEMOTED 끝 = 같은 트랜잭션에 리스 봉인 · 중단 = 같은 트랜잭션에 이 이전이 연 창 닫기.
// 🔴 기기 필터 — 「마지막 이전」 = 이 기기 · OLD_DEVICE 만(복원한 스냅샷에 실려 온 옛 폰 행을 새 폰이 읽지 않게).
// 🔴 live 파일만(`application_id`) · 행 시각 = 신뢰 시각.
// 🟡 새 폰 이전 행 = E16h · 스냅샷 · 매니페스트 = E16g2.

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show LedgerFile, OperatingMode, RunMode, X1JournalResultCodes;
import 'package:sqlite3/sqlite3.dart';

import '../local/lease_store.dart' show SqliteLeaseGate;
import '../market/market_store.dart' show inLedgerTransaction;
import 'maintenance_window_store.dart' show closeOpenWindowsOfRun;

/// 이전 저널 거부 코드(core 코드 밖 · 글자 = 계약 `X1JournalResultCodes` 참조 · 미결 212).
abstract final class MigrationStoreCodes {
  /// 이 기기에 중단되지 않은 이전이 있다.
  static const String runExists = X1JournalResultCodes.runExists;

  /// 단계 차례가 아니다.
  static const String stepOutOfOrder = X1JournalResultCodes.stepOutOfOrder;

  /// DEMOTED 뒤 = 실패를 적을 수 없다.
  static const String pastNoReturn = X1JournalResultCodes.pastNoReturn;
}

/// 옛 폰 이전 저널(live 원장).
class SqliteMigrationJournal {
  /// 만든다 — [lease] = 같은 원장의 리스(DEMOTED 봉인).
  SqliteMigrationJournal(
    this._db, {
    required this.deviceId,
    required this._trusted,
    required this._lease,
  }) : isLive =
           _db.select('PRAGMA application_id').first.values.first ==
           LedgerFile.live.applicationId;

  final Database _db;
  final TrustedClock _trusted;
  final SqliteLeaseGate _lease;

  /// 이 기기.
  final String deviceId;

  /// live 원장인가(`application_id`).
  final bool isLive;

  /// [runId] 의 저널 행.
  List<MigrationStepRow> rowsOf(String runId) => <MigrationStepRow>[
    for (final Row r in _db.select(
      'SELECT run_id, step, state, at FROM migration_step WHERE run_id = ? ORDER BY at, rowid',
      <Object?>[runId],
    ))
      MigrationStepRow(
        runId: r['run_id'] as String,
        step: r['step'] as String,
        state: r['state'] as String,
        atUtc: DateTime.parse(r['at'] as String).toUtc(),
      ),
  ];

  /// [runId] 의 진행 — 저널이 깨졌으면 [StateError] · 모르는 글자 = [FormatException].
  PlanProgress progressOf(String runId) => planProgressOf(runId, rowsOf(runId));

  /// 이 기기 · OLD_DEVICE 의 마지막 이전 id(시작 시각 · rowid 차례 · 없으면 null).
  String? latestRunId() {
    final ResultSet r = _db.select(
      "SELECT run_id FROM migration_run WHERE device_id = ? AND role = 'OLD_DEVICE' "
      'ORDER BY started_at DESC, rowid DESC LIMIT 1',
      <Object?>[deviceId],
    );
    return r.isEmpty ? null : r.single['run_id'] as String;
  }

  /// 🔴 마지막 이전의 진행(없으면 null) — 리스 래퍼 · 기동 거부가 읽는다.
  PlanProgress? latestProgress() {
    final String? id = latestRunId();
    return id == null ? null : progressOf(id);
  }

  /// 🔴 이전 시작 — 거부 = core 차례(live → 안내 모드 → 결정 → 신뢰 시각) → 중단되지 않은 이전 있음 · 통과 = 이전 id.
  ({String? runId, String? rejectCode}) start({
    required MigrationKind kind,
    required OperatingMode operatingMode,
    required String? decisionId,
    required int operatorEpoch,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    final String? reject = migrationStartRejectCode(
      kind: kind,
      runMode: isLive ? RunMode.live : RunMode.simInternal,
      operatingMode: operatingMode,
      decisionId: decisionId,
      trustedNowUtc: now,
    );
    if (reject != null) return (runId: null, rejectCode: reject);
    return inLedgerTransaction(_db, () {
      final PlanProgress? last = latestProgress();
      if (last != null && last.failed == null) {
        return (runId: null, rejectCode: MigrationStoreCodes.runExists);
      }
      final int seq =
          (_db.select(
                'SELECT COUNT(*) AS n FROM migration_run WHERE run_id LIKE ?',
                <Object?>['mig-${kstDateText(now!)}-%'],
              ).single['n']
              as int) +
          1;
      final String id = migrationRunIdOf(now, seq);
      _db.execute(
        'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          kind.wire,
          MigrationRole.oldDevice.wire,
          deviceId,
          operatorEpoch,
          decisionId,
          now.toIso8601String(),
        ],
      );
      return (runId: id, rejectCode: null);
    });
  }

  void _insertStep(
    String runId,
    PlanStep step,
    MigrationStepState state,
    DateTime at,
    Map<String, Object?>? detail,
  ) => _db.execute(
    'INSERT OR IGNORE INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, ?, ?, ?, ?)',
    <Object?>[
      runId,
      step.wire,
      state.wire,
      detail == null ? null : jsonEncode(detail),
      at.toIso8601String(),
    ],
  );

  void _requireMine(String runId) {
    final ResultSet r = _db.select(
      "SELECT 1 FROM migration_run WHERE run_id = ? AND device_id = ? AND role = 'OLD_DEVICE'",
      <Object?>[runId, deviceId],
    );
    if (r.isEmpty) throw ArgumentError.value(runId, 'runId', '이 기기의 이전이 아니다');
  }

  /// 🔴 단계에 들어간다 — 그 단계가 다음 차례일 때만(이미 들어감 = 쓰기 0 · 통과) · 통과 = null.
  String? enter(String runId, PlanStep step, {Map<String, Object?>? detail}) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) return MigrationStartCodes.trustedTimeUnknown;
    return inLedgerTransaction(_db, () {
      _requireMine(runId);
      return switch (planNextOf(progressOf(runId))) {
        PlanEnter(step: final PlanStep s) when s == step => () {
          _insertStep(runId, step, MigrationStepState.entered, now, detail);
          return null;
        }(),
        PlanResume(step: final PlanStep s) when s == step => null,
        _ => MigrationStoreCodes.stepOutOfOrder,
      };
    });
  }

  /// 🔴 단계를 끝낸다 — 진행 중인 그 단계만 · [facts] 가 막으면 그 코드 · 🔴 DEMOTED = 같은 트랜잭션에 리스 봉인.
  String? done(
    String runId,
    PlanStep step,
    PlanStepFacts facts, {
    Map<String, Object?>? detail,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) return MigrationStartCodes.trustedTimeUnknown;
    return inLedgerTransaction(_db, () {
      _requireMine(runId);
      if (progressOf(runId).inFlight != step) {
        return MigrationStoreCodes.stepOutOfOrder;
      }
      final String? block = planStepBlockCode(step, facts);
      if (block != null) return block;
      _insertStep(runId, step, MigrationStepState.done, now, detail);
      if (step == PlanStep.demoted) _lease.seal();
      return null;
    });
  }

  /// 🔴 단계 실패(= 이 이전 중단) — DEMOTED 앞 ∧ 진행 중일 때만 · 같은 트랜잭션에 이 이전이 연 열린 창을 닫는다.
  String? fail(String runId, PlanStep step, {required String reasonCode}) {
    if (!step.mayFail) return MigrationStoreCodes.pastNoReturn;
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) return MigrationStartCodes.trustedTimeUnknown;
    return inLedgerTransaction(_db, () {
      _requireMine(runId);
      if (progressOf(runId).inFlight != step) {
        return MigrationStoreCodes.stepOutOfOrder;
      }
      _insertStep(
        runId,
        step,
        MigrationStepState.failed,
        now,
        <String, Object?>{'reason': reasonCode},
      );
      closeOpenWindowsOfRun(_db, runId, now);
      return null;
    });
  }
}
