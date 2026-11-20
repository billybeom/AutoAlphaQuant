// E11q-b2b — X2 계절 3택 operator 판(설계 13 §8 R194 · 01 §31 K54) — 실 SQLite(sim 원장) · 엔진 `SqliteSeasonalChoice` ·
// 결과 = 엔진 글자.
//
// 🔴 행의 동작 그대로(`seasonalWindowChoice{work_id, choice}`) · 결정 id = `SEA-<명령 id>` · 같은 작업 두 번 = 이미 결정 ·
//    인자 없음 = ArgumentError(지어내지 않는다).

import 'dart:math';

import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show P0sStrategyIds, ResumeWorkKinds, SeasonalChoiceCodes;
import 'package:data_sync/data_sync.dart'
    show inLedgerTransaction, registerPlannedWork;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  late LedgerFiles files;
  setUp(() {
    clock = FakeClock(kst(2026, 11, 13, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
    files.sim.execute(
      'INSERT INTO decision_log(decision_id, created_at, trade_date, mode, kind, strategy_id, reason, reason_code, '
      "config_hash) VALUES ('SEAS-IN', '2026-10-28T00:00:00.000Z', '2026-10-28', 'SIM_INTERNAL', 'ENTRY', ?, 'r', "
      "'SEASONAL_ENTRY', 'cfg')",
      <Object?>[P0sStrategyIds.sleeveA],
    );
    files.sim.execute(
      'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
      "weights_before, weights_after, config_hash, created_at) VALUES ('EV-SEAS-IN', '2026-10-28', 'SIM_INTERNAL', "
      "'SEASONAL', 'SEAS-IN', '{\"side\":\"BUY\",\"target_shares\":10,\"a_symbol\":\"A1\"}', '[]', '[]', 'c', 'x')",
    );
    inLedgerTransaction(
      files.sim,
      () => registerPlannedWork(
        files.sim,
        kind: ResumeWorkKinds.seasonalWindow,
        decisionId: 'SEAS-IN',
        dueBy: const TradeDate('2026-11-27'),
        oneLine: '계절',
        payloadJson: '{}',
        createdAtUtc: '2026-10-28T00:00:00.000Z',
      ),
    );
  });
  tearDown(() => files.close());

  OperatorSafetyActions actions() {
    final OperatorRuntime rt = OperatorRuntime(files: files, clock: clock);
    rt.view.value = OperatorView(
      db: files.sim,
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: '',
      ),
    );
    return OperatorSafetyActions(rt, random: Random(3));
  }

  test(
    '🔴 축소 진입 = 엔진 적용(계획 = 재판정 · 결정 행 SEA-명령 id · HUMAN_REDUCED) · 두 번 = 이미 결정',
    () async {
      final OperatorSafetyActions a = actions();
      final SafetyActionResult r = await a.run(
        SafetyActionId.seasonalWindowChoice,
        args: const <String, String>{
          'work_id': 'PW-SEAS-IN',
          'choice': 'REDUCED',
        },
      );
      expect(
        (r.id, r.level, r.reasonCode, r.headline),
        (
          SafetyActionId.seasonalWindowChoice,
          UiLevel.ok,
          null,
          '고른 대로 기록했습니다 — 다음 주문 회차가 이어 갑니다.',
        ),
      );
      expect(
        files.sim
            .select(
              "SELECT state FROM planned_work WHERE work_id = 'PW-SEAS-IN'",
            )
            .single['state'],
        'REEVALUATED',
      );
      expect(
        files.sim.select(
          'SELECT reason_code FROM decision_log WHERE decision_id = ?',
          <Object?>['SEA-${r.actionRunId}'],
        ).single['reason_code'],
        'HUMAN_REDUCED',
      );
      expect(await a.watch(r.actionRunId).toList(), <SafetyActionResult>[r]);
      final SafetyActionResult again = await a.run(
        SafetyActionId.seasonalWindowChoice,
        args: const <String, String>{'work_id': 'PW-SEAS-IN', 'choice': 'SKIP'},
      );
      expect(
        (again.reasonCode, again.headline),
        (SeasonalChoiceCodes.notPending, '이미 결정된 작업입니다.'),
      );
    },
  );

  test('🔴 인자 없음 · 모르는 선택 = ArgumentError', () async {
    final OperatorSafetyActions a = actions();
    await expectLater(
      a.run(SafetyActionId.seasonalWindowChoice),
      throwsArgumentError,
    );
    await expectLater(
      a.run(
        SafetyActionId.seasonalWindowChoice,
        args: const <String, String>{'work_id': 'PW-SEAS-IN', 'choice': 'ALL'},
      ),
      throwsArgumentError,
    );
  });
}
