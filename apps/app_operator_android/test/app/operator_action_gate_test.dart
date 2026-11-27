// 🆕 미결 249(설계 13 §8 R279 · 계약 v1.39 K347 둘째 축 · 13 R261 H5) — 닫힌 원장의 안전 · 설정 동작 결과 `LEDGER_CLOSED` ·
// 실 SQLite(모의 원장을 CLOSE).
//
// 🔴 화면 원장(또는 그 동작이 쓰는 모의 파일)이 닫혔으면 = 결과 `LEDGER_CLOSED` · `retryable` true · 지켜보기 · 쓰기 0 · 깨어남 0 ·
//    `watch` 같은 값. 뺀 것(X1 · 구현 없는 동작) = 그대로. 열린 원장 = 그대로 간다.

import 'dart:io' show Directory;
import 'dart:math';

import 'package:app_operator_android/app/operator_golden.dart';
import 'package:app_operator_android/app/operator_handover.dart';
import 'package:app_operator_android/app/operator_ledger_gate.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisRestClient;
import 'package:core_engine/core_engine.dart'
    show LedgerWriteGateTexts, TrustedClock;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart' show SqliteModeStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  const _Trusted(this.at);

  final DateTime at;

  @override
  DateTime? trustedNowUtc() => at;
}

const FeatureFlags _simFlags = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg_test',
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2027, 1, 12, 10, 0));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  void closeSim() {
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    SqliteModeStore(
      files.sim,
      LedgerFile.sim,
      clock: clock,
    ).close(decisionId: 'D-LIVE');
  }

  OperatorRuntime rt({Database? db}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
      trusted: _Trusted(clock.nowUtc()),
    );
    r.view.value = OperatorView(db: db ?? files.sim, flags: _simFlags);
    return r;
  }

  int changes(Database db) =>
      db.select('SELECT total_changes() AS n').first['n'] as int;

  OperatorSettingsActions settings(OperatorRuntime r) =>
      OperatorSettingsActions(
        secrets: SecretHandoff(),
        vault: MemorySecretVault(),
        clientOf: (KisCredentials c) => KisRestClient(
          MockClient((_) async => http.Response('', 500)),
          c,
          environment: c.environment,
        ),
        clock: clock,
        sim: files.sim,
        ledger: () => r.view.value?.db,
        golden: OperatorGolden(
          (String _) async => throw StateError('골든 자산을 읽으면 안 된다(막힘 앞)'),
          clock: clock,
          appBuild: () async => '0.1.0+1',
          isolate: false,
        ),
        handover: OperatorHandover(r),
      );

  test('🔴 판정 한 곳 — 열린 모의 · 실전 = 아님 · 닫힌 모의 = 닫힘', () {
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    expect(operatorLedgerClosed(files.sim, clock: clock), isFalse);
    final Database live = writeLiveMode(Directory(files.directory), clock);
    addTearDown(live.close);
    expect(operatorLedgerClosed(live, clock: clock), isFalse);
    SqliteModeStore(
      files.sim,
      LedgerFile.sim,
      clock: clock,
    ).close(decisionId: 'D-LIVE');
    expect(operatorLedgerClosed(files.sim, clock: clock), isTrue);
    expect(operatorLedgerClosed(live, clock: clock), isFalse);
  });

  test('🔴 안전 동작 — 화면 원장에 쓰는 14 자리(🆕 R282 postmortem) = LEDGER_CLOSED(지켜보기 · 다시 해 볼 만함 · 동작 id 그대로) · 쓰기 0 · 깨어남 0 · watch 같은 값', () async {
    closeSim();
    final OperatorRuntime r = rt();
    int wakes = 0;
    r.attachWake(() async => wakes++);
    final OperatorSafetyActions a = OperatorSafetyActions(r, random: Random(3));
    final int before = changes(files.sim);
    final List<(SafetyActionId, Future<SafetyActionResult> Function())>
    calls = <(SafetyActionId, Future<SafetyActionResult> Function())>[
      (
        SafetyActionId.pledgeWrite,
        () => a.runPledge(
          const PledgeSubmission(
            id: SafetyActionId.pledgeWrite,
            sentences: <String>['가', '나', '다'],
          ),
        ),
      ),
      (
        SafetyActionId.pledgeEdit,
        () => a.runPledge(
          const PledgeSubmission(
            id: SafetyActionId.pledgeEdit,
            sentences: <String>['가', '나', '다'],
          ),
        ),
      ),
      (
        SafetyActionId.seasonalWindowChoice,
        () => a.run(
          SafetyActionId.seasonalWindowChoice,
          args: const <String, String>{'work_id': 'W-1', 'choice': 'ENTER'},
        ),
      ),
      (
        SafetyActionId.interventionStep,
        () => a.run(SafetyActionId.interventionStep),
      ),
      (SafetyActionId.repairAccept, () => a.run(SafetyActionId.repairAccept)),
      (
        SafetyActionId.ruleChangeCancel,
        () => a.run(
          SafetyActionId.ruleChangeCancel,
          args: const <String, String>{'request_id': 'RC-1'},
        ),
      ),
      (
        SafetyActionId.killSwitchResume,
        () => a.runKillResumeItem(const KillResumeItemSubmission(itemNo: 1)),
      ),
      (
        SafetyActionId.repairCorrect,
        () => a.runRepairCorrect(
          const RepairCorrectSubmission(
            targetId: 'T-1',
            fillRef: 'F-1',
            originCode: 'O',
            voidFill: false,
          ),
        ),
      ),
      (
        SafetyActionId.repairBaseline,
        () => a.runRepairBaseline(
          const RepairBaselineSubmission(targetId: 'T-1', originCode: 'O'),
        ),
      ),
      (
        SafetyActionId.interventionJournal,
        () => a.runInterventionJournal(
          const InterventionJournalSubmission(
            rationaleBefore: '근거',
            expectedOutcome: '기대',
            ruleCited: 'R',
          ),
        ),
      ),
      (
        SafetyActionId.ruleChangeApprove,
        () => a.runRuleChangeApproval(
          const RuleChangeApprovalSubmission(requestId: 'RC-1', approver: '나'),
        ),
      ),
      (
        SafetyActionId.ruleChangeRequest,
        () => a.runRuleChangeRequest(
          const RuleChangeRequestSubmission(
            candidateId: 'C-1',
            reason: '까닭',
            rollbackMethod: '되돌림',
            rationaleBefore: '근거',
            expectedOutcome: '기대',
            ruleCited: 'R',
          ),
        ),
      ),
      (
        SafetyActionId.postmortemRecord,
        () => a.runPostmortem(
          const PostmortemSubmission(incidentId: 'SEV2-X', text: '글'),
        ),
      ),
      (
        SafetyActionId.reconClear,
        () => a.runReconClear(
          const ReconClearSubmission(
            originCode: 'O',
            rationaleBefore: '근거',
            expectedOutcome: '기대',
            ruleCited: 'R',
          ),
        ),
      ),
    ];
    final Set<String> runs = <String>{};
    for (final (SafetyActionId id, Future<SafetyActionResult> Function() call)
        in calls) {
      final SafetyActionResult got = await call();
      expect(
        (got.id, got.reasonCode, got.retryable, got.level, got.headline),
        (
          id,
          LedgerWriteGateCodes.ledgerClosed,
          true,
          UiLevel.watch,
          LedgerWriteGateTexts.closedAction,
        ),
        reason: id.wire,
      );
      expect(await a.watch(got.actionRunId).first, got);
      runs.add(got.actionRunId);
    }
    expect(runs, hasLength(calls.length));
    expect(changes(files.sim), before, reason: '닫힌 원장 = 쓰기 0');
    await Future<void>.delayed(Duration.zero);
    expect(wakes, 0);
  });

  test('🔴 안전 동작 뺀 것 — X1 = 자체 실전 전용 판정 · 구현 없는 동작 = 그대로 오류 · RECON 해제 run = ArgumentError', () async {
    closeSim();
    final OperatorSafetyActions a = OperatorSafetyActions(
      rt(),
      random: Random(3),
    );
    expect(
      (await a.run(SafetyActionId.x1PlanStart)).reasonCode,
      isNot(LedgerWriteGateCodes.ledgerClosed),
    );
    await expectLater(
      a.run(SafetyActionId.stoppedDecision),
      throwsUnsupportedError,
    );
    await expectLater(a.run(SafetyActionId.reconClear), throwsArgumentError);
  });

  test('🔴 설정 동작 — 원장에 쓰는 6 자리(무결성 · 골든 · 월 납입 · 운영 방식 고름 · 모의 개시 · 모의 파일 처리) = LEDGER_CLOSED · 쓰기 0 · watch 같은 값', () async {
    closeSim();
    final OperatorRuntime r = rt();
    int wakes = 0;
    r.attachWake(() async => wakes++);
    final OperatorSettingsActions s = settings(r);
    final int before = changes(files.sim);
    final List<(SettingsActionId, Future<ActionResult> Function())> calls =
        <(SettingsActionId, Future<ActionResult> Function())>[
          (
            SettingsActionId.selftestIntegrityRun,
            () => s.run(SettingsActionId.selftestIntegrityRun),
          ),
          (
            SettingsActionId.selftestGoldenRun,
            () => s.run(SettingsActionId.selftestGoldenRun),
          ),
          (
            SettingsActionId.settingsContributionUpdate,
            () => s.runContributionUpdate(
              const ContributionUpdateSubmission(amountInput: '1000000'),
            ),
          ),
          (
            SettingsActionId.onboardingOperatingModeSelect,
            () => s.run(
              SettingsActionId.onboardingOperatingModeSelect,
              args: <String, String>{
                'operating_mode': OperatingMode.autoTrade.wire,
              },
            ),
          ),
          (
            SettingsActionId.onboardingDryRunStart,
            () => s.run(SettingsActionId.onboardingDryRunStart),
          ),
          (
            SettingsActionId.handoverSimLedgerFate,
            () => s.run(
              SettingsActionId.handoverSimLedgerFate,
              args: const <String, String>{'fate': 'KEEP'},
            ),
          ),
        ];
    final Set<String> runs = <String>{};
    for (final (SettingsActionId id, Future<ActionResult> Function() call)
        in calls) {
      final ActionResult got = await call();
      expect(
        (got.id, got.reasonCode, got.retryable, got.level, got.headline),
        (
          id,
          LedgerWriteGateCodes.ledgerClosed,
          true,
          UiLevel.watch,
          LedgerWriteGateTexts.closedAction,
        ),
        reason: id.wire,
      );
      expect(await s.watch(got.actionRunId).first, got);
      runs.add(got.actionRunId);
    }
    expect(runs, hasLength(calls.length));
    expect(changes(files.sim), before, reason: '닫힌 원장 = 쓰기 0');
    await Future<void>.delayed(Duration.zero);
    expect(wakes, 0);
  });

  test('🔴 실전 화면 = 화면 원장 동작은 그대로 간다 · 모의 파일에 쓰는 동작(모의 개시)만 닫힘', () async {
    closeSim();
    final Database live = writeLiveMode(Directory(files.directory), clock);
    addTearDown(live.close);
    final OperatorRuntime r = rt(db: live);
    final OperatorSettingsActions s = settings(r);
    final ActionResult integrity = await s.run(
      SettingsActionId.selftestIntegrityRun,
    );
    expect(integrity.reasonCode, isNot(LedgerWriteGateCodes.ledgerClosed));
    expect(
      (await s.run(SettingsActionId.onboardingDryRunStart)).reasonCode,
      LedgerWriteGateCodes.ledgerClosed,
    );
    final SafetyActionResult rule =
        await OperatorSafetyActions(r, random: Random(3)).run(
          SafetyActionId.ruleChangeCancel,
          args: const <String, String>{'request_id': 'RC-1'},
        );
    expect(rule.reasonCode, isNot(LedgerWriteGateCodes.ledgerClosed));
  });
}
