// X1-5 LIVE 재개 게이트 원천(설계 13 §8 R138 Q5~Q9 · SPEC v2.45 04 §3-1 ③ · 앱 06 X1-5 · core `migrationGateOf`).
//
// 🔴 판정 = 복구 없음 `X1_NOT_RESTORED` · 갭 재구성 전 `X1_RECOVERY_IN_PROGRESS` · 그 뒤 = core `migrationGateOf`.
// 🔴 골든 = GOLDEN_SELF_TEST DONE = 통과 · FAILED 만 = 실패 · 없음 = 아직 · 포트가 던지면 쓰기 0(아직 그대로).
// 🔴 관찰 = 갭 재구성 끝부터 연속 무결일(core `cleanTradingDayStreakOf` · M1-22 원천 행 재사용 · 다른 키).
// 🔴 승인 2단계 = 한 트랜잭션 안에서 다시 판정해 그 단계가 다음 차례일 때만 적는다(decision_id 필수 · 이미 = 쓰기 0).
// 🔴 실패 기본값 = 매매 없는 안전 정지 — 이 저장소에 롤백 · 옛 폰 재승격 · 자동 통과 API 0.

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

import '../local/live_observation_facts.dart' show SqliteLiveObservationFacts;
import '../market/market_store.dart' show inLedgerTransaction;
import 'migration_facts.dart' show migrationPlanFactsOf;
import 'recovery_journal_store.dart'
    show RecoveryCodes, RecoveryRun, latestRecoveryOf;

/// 게이트 한 판 — 복구 전 · 재구성 전 = [holdCode] · 그 뒤 = [gate].
typedef RecoveryGateView = ({MigrationGateVerdict? gate, String? holdCode});

/// 새 폰 LIVE 재개 게이트(복원한 live 원장).
class SqliteRecoveryGate {
  /// 만든다 — [clock] = 관찰 «오늘»(M1-22 와 같은 원천) · [trusted] = 기록 시각.
  SqliteRecoveryGate(
    this._db, {
    required this.deviceId,
    required this._trusted,
    required this._clock,
    required this._kr,
  });

  final Database _db;
  final TrustedClock _trusted;
  final Clock _clock;
  final ExchangeCalendar _kr;

  /// 이 기기(새 폰).
  final String deviceId;

  Set<String> _states(String runId, RecoveryStep step) => <String>{
    for (final Row r in _db.select(
      'SELECT state FROM migration_step WHERE run_id = ? AND step = ?',
      <Object?>[runId, step.wire],
    ))
      r['state'] as String,
  };

  bool _done(String runId, RecoveryStep step) =>
      _states(runId, step).contains('DONE');

  String? _holdOf(RecoveryRun? r) => r == null
      ? RecoveryCodes.notRestored
      : !r.gapRebuilt
      ? RecoverySealCodes.inProgress
      : null;

  /// 🔴 게이트 사실(복구 · 갭 재구성 뒤만 · 그 전 = null).
  MigrationGateFacts? factsOf() {
    final RecoveryRun? r = latestRecoveryOf(_db, deviceId);
    if (_holdOf(r) != null) return null;
    final Set<String> golden = _states(r!.runId, RecoveryStep.goldenSelfTest);
    final PlanStepFacts plan = migrationPlanFactsOf(_db);
    final LiveObservationFacts seen = SqliteLiveObservationFacts(
      _db,
      clock: _clock,
    ).read();
    return MigrationGateFacts(
      goldenPassed: golden.contains('DONE')
          ? true
          : golden.contains('FAILED')
          ? false
          : null,
      reconMismatches: plan.reconMismatches,
      unknownOrders: plan.unknownOrders,
      openOrders: plan.openOrders,
      observedTradingDays: cleanTradingDayStreakOf(
        runs: seen.runs,
        recons: seen.recons,
        sinceUtc: r.gapRebuiltAtUtc!,
        asOfUtc: seen.asOfUtc,
        kr: _kr,
      ),
      checklistConfirmed: _done(r.runId, RecoveryStep.checklistConfirmed),
      biometricConfirmed: _done(r.runId, RecoveryStep.biometricConfirmed),
    );
  }

  /// 🔴 게이트 판정 — [config] = 관찰 일수(`operations.migration.observation_trading_days` · 잠정).
  RecoveryGateView view({required MigrationObservationConfig config}) {
    final RecoveryRun? r = latestRecoveryOf(_db, deviceId);
    final String? hold = _holdOf(r);
    if (hold != null) return (gate: null, holdCode: hold);
    return (
      gate: migrationGateOf(factsOf()!, kind: r!.kind, config: config),
      holdCode: null,
    );
  }

  /// 🔴 골든 자가검사 — 복구 · 재구성 뒤만 · 이미 통과 = 포트를 부르지 않는다 · 포트가 던지면 쓰기 0(그대로 던진다).
  ///
  /// 시각 = 돌리기 전 신뢰 시각(모름 = 거부 · 포트를 부르지 않는다).
  Future<({bool? passed, String? rejectCode})> runGoldenSelfTest(
    GoldenSelfTest port,
  ) async {
    final RecoveryRun? r = latestRecoveryOf(_db, deviceId);
    final String? hold = _holdOf(r);
    if (hold != null) return (passed: null, rejectCode: hold);
    if (_done(r!.runId, RecoveryStep.goldenSelfTest)) {
      return (passed: true, rejectCode: null);
    }
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      return (passed: null, rejectCode: MigrationStartCodes.trustedTimeUnknown);
    }
    final bool passed = await port.run();
    _db.execute(
      'INSERT OR IGNORE INTO migration_step (run_id, step, state, detail_json, at) '
      'VALUES (?, ?, ?, NULL, ?)',
      <Object?>[
        r.runId,
        RecoveryStep.goldenSelfTest.wire,
        passed ? 'DONE' : 'FAILED',
        now.toIso8601String(),
      ],
    );
    return (passed: passed, rejectCode: null);
  }

  /// 🔴 승인 1(체크리스트) — 게이트가 `X1_CHECKLIST_PENDING` 일 때만 · 아니면 그 판정 코드 · 이미 = null(쓰기 0).
  String? confirmChecklist({
    required String decisionId,
    required MigrationObservationConfig config,
  }) => _confirm(
    RecoveryStep.checklistConfirmed,
    MigrationGateCodes.checklistPending,
    decisionId,
    config,
  );

  /// 🔴 승인 2(생체 · 결과만 — 생체 자체는 화면) — 게이트가 `X1_BIOMETRIC_PENDING` 일 때만.
  String? confirmBiometric({
    required String decisionId,
    required MigrationObservationConfig config,
  }) => _confirm(
    RecoveryStep.biometricConfirmed,
    MigrationGateCodes.biometricPending,
    decisionId,
    config,
  );

  String? _confirm(
    RecoveryStep step,
    String turnCode,
    String decisionId,
    MigrationObservationConfig config,
  ) {
    if (decisionId.trim().isEmpty) {
      throw ArgumentError.value(decisionId, 'decisionId', '비울 수 없다');
    }
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) return MigrationStartCodes.trustedTimeUnknown;
    return inLedgerTransaction(_db, () {
      final RecoveryGateView v = view(config: config);
      if (v.holdCode != null) return v.holdCode;
      final RecoveryRun r = latestRecoveryOf(_db, deviceId)!;
      if (_done(r.runId, step)) return null;
      final MigrationGateVerdict g = v.gate!;
      if (g.code != turnCode) return g.code ?? g.state.wire;
      _db.execute(
        'INSERT INTO migration_step (run_id, step, state, detail_json, at) '
        "VALUES (?, ?, 'DONE', ?, ?)",
        <Object?>[
          r.runId,
          step.wire,
          jsonEncode(<String, Object?>{'decision_id': decisionId}),
          now.toIso8601String(),
        ],
      );
      return null;
    });
  }
}
