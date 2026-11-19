// E11q3 — M9 S13 월 납입 · M7 S7-4 납입 플래너 조립(설계 13 §8 R174) — 실 SQLite(sim 원장).
//
// 🔴 S13 = 엔진 투영 · 바꾸기 = 이 기기 id 가 있을 때만 · 쓰기 판정 · 문장 = 엔진(신뢰 시각 모름 = `TRUSTED_TIME_UNKNOWN`).
// 🔴 S7-4 = 미리보기 · 계획 찾기 = 엔진 What-if(리밸런싱과 같은 원장 어댑터) · 등록 = 신뢰 시각 관문(모름 = 쓰기 0 · 거부 접수증 ·
//    앎 = 엔진 기록기 한 트랜잭션).

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_ops_summary.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:core_engine/core_engine.dart'
    show
        DepositIssueTexts,
        MonthlyContributionTexts,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        TrustedClock,
        p0sKrPlanSymbols;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        ContributionSettingSource,
        SqliteConfigVersionStore,
        SqliteOnboardingStore;
import 'package:decimal/decimal.dart';
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

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'isa',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'isa',
};

final P0sHumanInputs _inputs = P0sHumanInputs(
  aSymbol: '229200',
  accountByStrategy: _accounts,
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 20, 18, 0));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(null);
  });
  tearDown(() => files.close());

  Database db() => files.sim;

  OperatorRuntime rt({String? device = 'dev-1'}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: device,
      trusted: trusted,
    );
    r.view.value = OperatorView(
      db: db(),
      flags: const FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_test',
      ),
    );
    return r;
  }

  void open() {
    final String hash = SqliteConfigVersionStore(
      db(),
      clock: clock,
    ).register(P0sOpsConfig.of(_inputs).content());
    final SqliteOnboardingStore s = SqliteOnboardingStore(db(), clock: clock);
    expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
    expect(
      s
          .declareSimOpening(
            SelfReportBalance(
              asOfTradeDate: const TradeDate('2026-11-02'),
              purpose: SelfReportPurpose.simOpening,
              sessionStartedAt: clock.nowUtc(),
              lines: const <SelfReportLine>[],
              cashKrw: Decimal.parse('10000000'),
              accountAlias: 'general',
              declaredComplete: true,
              context: const CommandContext(
                runMode: RunMode.simInternal,
                operatingMode: OperatingMode.autoTrade,
                leaseEpoch: 0,
                deviceId: 'dev-1',
              ),
            ),
            accountByStrategy: _accounts,
            configHash: hash,
          )
          .ok,
      true,
    );
    for (final String s in p0sKrPlanSymbols()) {
      db().execute(
        'INSERT OR IGNORE INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, '
        "volume) VALUES ('2026-11-20', 'KR', ?, 10000, 10000, 10000, 10000, 10000, 0)",
        <Object?>[s],
      );
    }
  }

  OperatorSettingsActions actions(OperatorRuntime r) => OperatorSettingsActions(
    secrets: SecretHandoff(),
    vault: MemorySecretVault(),
    clientOf: (_) => throw UnimplementedError('키 검증 안 씀'),
    clock: clock,
    contribution: () {
      final OperatorView? v = r.view.value;
      final String? id = r.deviceId;
      if (v == null || id == null) return null;
      return ContributionSettingSource(
        v.db,
        trusted: r.trusted,
        clock: clock,
        kr: r.calendars.kr,
        deviceId: id,
      );
    },
  );

  int cashRows() =>
      db().select('SELECT COUNT(*) AS n FROM cash_flow').first['n']! as int;

  int paramRows() =>
      db().select('SELECT COUNT(*) AS n FROM operating_param_log').first['n']!
          as int;

  test('🆕 R174 S13 = 엔진 투영(셸 설정과 같은 값) · 바꾸기 = 기기 id 가 있을 때만', () async {
    final OperatorRuntime r = rt();
    final MonthlyContributionVm vm = await OperatorSettingsRepository(r)
        .watchContribution()
        .first;
    final ContributionSetting s = await OperatorConfigRepository(
      r.view,
      clock: clock,
      kr: r.calendars.kr,
    ).watchContributionSetting().first;
    expect(vm.amountText, s.amountText);
    expect(vm.amountInputText, s.amountInputText);
    expect(vm.appliesFromText, s.appliesFromText);
    expect(vm.lastChangedText, s.lastChangedText);
    expect(vm.asOf, s.asOf);
    expect(vm.changeLabel, MonthlyContributionTexts.change);
    expect(vm.editable, isTrue);
    final MonthlyContributionVm none = await OperatorSettingsRepository(
      rt(device: null),
    ).watchContribution().first;
    expect(none.changeLabel, isNull);
    expect(none.editable, isFalse);
    expect(
      kOperatorRouteBodies.byPattern.containsKey(
        AppRoutes.settingsContribution,
      ),
      true,
    );
  });

  test('🆕 R174 S13 바꾸기 = 엔진 판정 — 신뢰 시각 모름 = 쓰기 0 · 서버 시각 문장 · 입력 거부 · 신뢰 시각 앎 = 접수(기록 1)', () async {
    final OperatorRuntime r = rt();
    final OperatorSettingsActions a = actions(r);
    Future<ActionResult> put(String s) =>
        a.runContributionUpdate(ContributionUpdateSubmission(amountInput: s));
    final ActionResult blocked = await put('200000');
    expect(blocked.reasonCode, 'TRUSTED_TIME_UNKNOWN');
    expect(blocked.level, UiLevel.blocked);
    expect(blocked.headline, startsWith('서버 시각을 확인하지 못해'));
    expect(paramRows(), 0, reason: '기기 시계로 대신 쓰지 않는다');
    trusted.at = clock.nowUtc();
    final ActionResult blank = await put('  ');
    expect(blank.reasonCode, 'CONTRIBUTION_INPUT_BLANK');
    expect(blank.level, UiLevel.act);
    final ActionResult ok = await put('200000');
    expect(ok.reasonCode, isNull);
    expect(ok.level, UiLevel.ok);
    expect(ok.headline, MonthlyContributionTexts.accepted);
    expect(ok.id, SettingsActionId.settingsContributionUpdate);
    expect(paramRows(), 1);
    await expectLater(
      actions(rt(device: null)).runContributionUpdate(
        const ContributionUpdateSubmission(amountInput: '1'),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('🆕 R174 S7-4 미리보기 · 계획 찾기 = 엔진 What-if(원장 어댑터) · 등록 = 신뢰 시각 관문(모름 = 쓰기 0 · 앎 = 기록)', () async {
    open();
    final OperatorRuntime r = rt();
    final OperatorWhatIfApi w = OperatorWhatIfApi(
      r,
      hasBody: kOperatorRouteBodies.byPattern.containsKey,
    );
    final DepositPreviewResult p = await w.simulateDeposit(
      amountInput: '300000',
    );
    final DepositPlan plan = p.plan!;
    expect((await w.findPlan(plan.planId))!.planId, plan.planId);
    expect(await w.findPlan('nope'), isNull);
    final OperatorCommandApi c = OperatorCommandApi(r);
    final int before = cashRows();
    final CommandReceipt no = await c.registerDeposit(
      DepositRegistration(planId: plan.planId),
    );
    expect(no.state, CommandState.rejected);
    expect(no.rejectReasonCode, DepositIssueTexts.trustedTimeUnknownCode);
    expect(no.stateLabel, contains(DepositIssueTexts.trustedTimeUnknown));
    expect(no.kind, CommandKind.depositRegister);
    expect(cashRows(), before, reason: '신뢰 시각을 모르면 쓰기 0');
    expect(await c.watchCommand(no.commandId).first, no);
    trusted.at = clock.nowUtc();
    final CommandReceipt yes = await c.registerDeposit(
      DepositRegistration(planId: plan.planId),
    );
    expect(yes.state, CommandState.executed, reason: yes.stateLabel);
    expect(cashRows(), greaterThan(before));
    expect(
      yes.expiresAt.difference(yes.requestedAt),
      const Duration(minutes: 30),
    );
    await expectLater(
      OperatorCommandApi(rt(device: null))
          .registerDeposit(DepositRegistration(planId: plan.planId)),
      throwsA(isA<StateError>()),
    );
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.planDeposit),
      true,
    );
  });
}
