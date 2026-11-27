// 🆕 미결 243 ⓒ · ⓓ(설계 13 §8 R276 · 계약 v1.39 K347 · K348 · 리뷰 3차 B-03 · H1-2) — 명령 창구 조립 · 실 SQLite(sim 원장).
//
// ⓒ 킬스위치 기록 확인 ≠ 엔진 미체결(`KILL_ACK_MISMATCH` · `p0`) → `KILL_SWITCH_ACK_MISMATCH` P0 한 건(낸 곳 = 킬스위치 · 같은 날 = 한 건) ·
//    접수증 = 거부 그대로 · 깨어남 한 번. 그 밖 거부 = 경보 0 · 깨어남 0.
// ⓓ 쓸 원장이 닫힘(CLOSE · 전환 커밋 ~ 깨어남 끝 틈) = 모든 명령 거부 접수증 `LEDGER_CLOSED` · 쓰기 0 · 깨어남 0.

import 'dart:io' show Directory;
import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_self_report.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show KillCommandTexts, LedgerWriteGateTexts, P0sStrategyIds, TrustedClock;
import 'package:data_sync/data_sync.dart' show SqliteModeStore;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);

  DateTime? at;

  @override
  DateTime? trustedNowUtc() => at;
}

const KillChecklistSubmission _ok = KillChecklistSubmission(
  ruleAction: '규칙대로 신규 진입을 멈춘다',
  reasonKind: KillActivationReason.rule,
  scenarioId: 'W3',
  resumeCondition: '체결 오류 0',
  scope: KillActivationScope.newEntriesOnly,
  openOrdersQueried: true,
  openOrdersCancelled: true,
  remainingCountZero: true,
  note: '한 줄',
);

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
  late _Trusted trusted;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 23, 10, 2));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(null);
  });
  tearDown(() => files.close());

  OperatorRuntime rt({Database? db}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: 'dev-1',
      trusted: trusted,
    );
    r.view.value = OperatorView(db: db ?? files.sim, flags: _simFlags);
    return r;
  }

  int n(Database db, String sql) =>
      db.select('SELECT COUNT(*) AS n FROM $sql').first['n'] as int;

  /// 엔진이 볼 미체결 1건(제출됨 · 잔량 > 0 · 오늘 한국 날).
  void openOrder(Database db) {
    db.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES ('I-1', 'k-I-1', '2026-12-23T01:00:00.000Z', '2026-12-23', 'KR', 'pension', "
      "?, 'D-1', '133690', 'BUY', 'LIMIT', 10, 20000, 'SUBMITTED', 'cfg', '2026-12-23T01:00:00.000Z', "
      "'SIM_INTERNAL')",
      <Object?>[P0sStrategyIds.sleeveB],
    );
    db.execute(
      'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, remaining_qty) '
      "VALUES ('2026-12-23:1', 'I-1', '2026-12-23T01:00:01.000Z', 'SUBMITTED', 10)",
    );
  }

  List<Map<String, Object?>> alerts(Database db) => <Map<String, Object?>>[
    for (final r in db.select(
      'SELECT code, level, source FROM alert_event ORDER BY raised_at',
    ))
      <String, Object?>{...r},
  ];

  group('ⓒ KILL_SWITCH_ACK_MISMATCH P0', () {
    test('🔴 확인 3 ≠ 엔진 미체결 = 접수증 거부(KILL_ACK_MISMATCH) + P0 경보 한 건(낸 곳 = 킬스위치) · 같은 날 다시 = 새 행 0 · '
        '깨어남 = 경보 낸 때마다 · 사다리 있음', () async {
      final OperatorRuntime r = rt();
      int wakes = 0;
      r.attachWake(() async => wakes++);
      final OperatorCommandApi api = OperatorCommandApi(r, random: Random(5));
      openOrder(files.sim);
      expect((await api.activateKillSwitch()).state, CommandState.executed);
      await Future<void>.delayed(Duration.zero);
      wakes = 0;
      trusted.at = clock.nowUtc().add(const Duration(minutes: 5));
      final CommandReceipt mismatch = await api.confirmKillChecklist(_ok);
      expect(
        (mismatch.state, mismatch.rejectReasonCode, mismatch.stateLabel),
        (
          CommandState.rejected,
          'KILL_ACK_MISMATCH',
          KillCommandTexts.rejected('KILL_ACK_MISMATCH'),
        ),
      );
      expect(alerts(files.sim), <Map<String, Object?>>[
        <String, Object?>{
          'code': AlertCodes.killSwitchAckMismatch,
          'level': 'P0',
          'source': 'kill_switch',
        },
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(wakes, 1, reason: '새 P0 = FGS 열린 P0 줄이 바뀌는 전이');
      // 같은 한국 날 다시 = 경보 새 행 0(묶음 키) · 접수증은 또 거부.
      expect(
        (await api.confirmKillChecklist(_ok)).rejectReasonCode,
        'KILL_ACK_MISMATCH',
      );
      expect(alerts(files.sim), hasLength(1));
      expect(
        n(files.sim, "alert_event WHERE code = 'KILL_SWITCH_ACK_MISMATCH'"),
        1,
      );
    });

    test('🔴 그 밖 거부(확인 미완 · 신뢰 시각 모름 · 빈 칸) = 경보 0 · 깨어남 0', () async {
      final OperatorRuntime r = rt();
      int wakes = 0;
      r.attachWake(() async => wakes++);
      final OperatorCommandApi api = OperatorCommandApi(r, random: Random(5));
      openOrder(files.sim);
      await api.activateKillSwitch();
      await Future<void>.delayed(Duration.zero);
      wakes = 0;
      // 신뢰 시각 모름(판정 전 거부).
      expect(
        (await api.confirmKillChecklist(_ok)).rejectReasonCode,
        'TRUSTED_TIME_UNKNOWN',
      );
      trusted.at = clock.nowUtc().add(const Duration(minutes: 5));
      expect(
        (await api.confirmKillChecklist(
          _ok.copyWith(remainingCountZero: false),
        )).rejectReasonCode,
        'KILL_ACK_INCOMPLETE',
      );
      expect(
        (await api.confirmKillChecklist(_ok.copyWith(reasonKind: null)))
            .rejectReasonCode,
        'KILL_CHECKLIST_ITEM_MISSING',
      );
      await Future<void>.delayed(Duration.zero);
      expect(alerts(files.sim), isEmpty);
      expect(wakes, 0);
    });
  });

  group('ⓓ LEDGER_CLOSED', () {
    void close() {
      writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
      SqliteModeStore(
        files.sim,
        LedgerFile.sim,
        clock: clock,
      ).close(decisionId: 'D-LIVE');
    }

    int changes(Database db) =>
        db.select('SELECT total_changes() AS n').first['n'] as int;

    void closedReceipt(CommandReceipt r, CommandKind kind) {
      expect(
        (r.kind, r.state, r.rejectReasonCode, r.stateLabel),
        (
          kind,
          CommandState.rejected,
          LedgerWriteGateCodes.ledgerClosed,
          LedgerWriteGateTexts.closed,
        ),
      );
      expect(r.issuedByDeviceId, 'dev-1');
    }

    test('🔴 화면 상태 원장이 닫힘 = 모든 명령 거부 접수증 LEDGER_CLOSED · 쓰기 0 · 깨어남 0 · watchCommand 같은 값', () async {
      close();
      trusted.at = clock.nowUtc();
      final OperatorRuntime r = rt();
      int wakes = 0;
      r.attachWake(() async => wakes++);
      final OperatorCommandApi api = OperatorCommandApi(
        r,
        random: Random(9),
        selfReport: OperatorSelfReport(r, hasBody: (String _) => true),
      );
      final int before = changes(files.sim);
      final List<(CommandKind, Future<CommandReceipt> Function())> calls =
          <(CommandKind, Future<CommandReceipt> Function())>[
            (CommandKind.alertAck, () => api.acknowledgeAlert('A-1')),
            (CommandKind.killSwitchActivate, api.activateKillSwitch),
            (
              CommandKind.killChecklistConfirm,
              () => api.confirmKillChecklist(_ok),
            ),
            (
              CommandKind.journalDraft,
              () => api.submitJournalDraft(
                const JournalDraft(
                  decisionId: 'JIV-1',
                  rationaleBefore: '근거',
                  expectedOutcome: '기대',
                  ruleCited: 'R',
                ),
              ),
            ),
            (
              CommandKind.blindReviewScore,
              () => api.submitBlindReviewScore(
                const BlindReviewScore(
                  decisionId: 'D28',
                  answers: <String, int>{'Q1': 1},
                ),
              ),
            ),
            (
              CommandKind.disclosureView,
              () => api.recordDisclosureView(
                DisclosureViewEvent(
                  surfaceCode: DisclosureSurfaceCodes.performanceExplore,
                  viewedAt: clock.nowUtc(),
                ),
              ),
            ),
            (
              CommandKind.depositRegister,
              () =>
                  api.registerDeposit(const DepositRegistration(planId: 'P-1')),
            ),
            (
              CommandKind.selfReportBalance,
              () => api.submitSelfReportBalance(
                const SelfReportSubmission(
                  purpose: SelfReportPurpose.simOpening,
                  input: SelfReportInput(cashKrwText: '1,000,000'),
                  declaredComplete: true,
                ),
              ),
            ),
            (
              CommandKind.selfReportBalance,
              () => api.submitSelfReportBalance(
                const SelfReportSubmission(
                  purpose: SelfReportPurpose.periodicAudit,
                  yyyyMm: '2026-11',
                  input: SelfReportInput(
                    cashKrwText: '1,000,000',
                    accountAlias: '연금저축',
                  ),
                  declaredComplete: true,
                ),
              ),
            ),
          ];
      final Set<String> ids = <String>{};
      for (final (CommandKind kind, Future<CommandReceipt> Function() call)
          in calls) {
        final CommandReceipt got = await call();
        closedReceipt(got, kind);
        expect(await api.watchCommand(got.commandId).first, got);
        ids.add(got.commandId);
      }
      expect(ids, hasLength(calls.length));
      expect(changes(files.sim), before, reason: '닫힌 원장 = 쓰기 0');
      expect(n(files.sim, 'command_inbox'), 0);
      expect(n(files.sim, 'kill_switch_state'), 0);
      await Future<void>.delayed(Duration.zero);
      expect(wakes, 0, reason: '거부 = 전이 아님');
    });

    test(
      '🔴 실전 화면이어도 모의 개시(모의 파일에 씀) = 모의 파일이 닫혔으면 거부 · 실전 원장 명령 = 그대로 간다',
      () async {
        close();
        final Database live = writeLiveMode(Directory(files.directory), clock);
        addTearDown(live.close);
        final OperatorRuntime r = rt(db: live);
        final OperatorCommandApi api = OperatorCommandApi(r, random: Random(9));
        closedReceipt(
          await api.submitSelfReportBalance(
            const SelfReportSubmission(
              purpose: SelfReportPurpose.simOpening,
              input: SelfReportInput(cashKrwText: '1,000,000'),
              declaredComplete: true,
            ),
          ),
          CommandKind.selfReportBalance,
        );
        final CommandReceipt on = await api.activateKillSwitch();
        expect(on.state, CommandState.executed, reason: '실전 원장 = 열림');
        expect(n(live, 'kill_switch_state'), 1);
        expect(n(files.sim, 'kill_switch_state'), 0);
      },
    );
  });
}
