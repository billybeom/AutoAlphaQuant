// E11q1 — M6 H6-1 보유 현황 조립(설계 13 §8 R171 · 나눔 계획 R169 q1) — 실 SQLite(sim 원장).
//
// 🔴 화면 상태의 원장 → data_sync 원천 → 엔진 VM · 원장이 바뀌면 다시 낸다 · 계좌 글자 = 사람 결정 표 ·
//    링크 = 셸이 실제로 쓰는 레지스트리에 본문이 있는 화면만(H6-2 · H6-3 미등록 = 링크 0) · 모의 밖 = 원천 없음.

import 'dart:async';

import 'package:app_operator_android/app/operator_ops_summary.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        HoldingsTexts,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        p0sKrPlanSymbols;
import 'package:data_sync/data_sync.dart'
    show
        HoldingsSourceUnavailable,
        OpsConfigUnavailable,
        P0sHumanDecision,
        SqliteConfigVersionStore,
        SqliteOnboardingStore;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

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

OperatorView _viewOf(Database db, {RunMode mode = RunMode.simInternal}) =>
    OperatorView(
      db: db,
      flags: FeatureFlags(
        satelliteEnabled: false,
        webViewerEnabled: false,
        calendarEnabled: false,
        runMode: mode,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg_test',
      ),
    );

Future<void> until(bool Function() ok) async {
  for (int i = 0; i < 300 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(ok(), isTrue);
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 8, 31, 18, 0));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  Database db() => files.sim;

  OperatorRuntime rt({bool labels = true, RunMode mode = RunMode.simInternal}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      humanDecision: labels
          ? P0sHumanDecision(
              inputs: _inputs,
              accountLabels: const <String, String>{
                'isa': 'ISA',
                'pension': '연금저축',
                'general': '일반 위탁',
              },
              decisionRef: 'test',
            )
          : null,
    );
    r.view.value = _viewOf(db(), mode: mode);
    return r;
  }

  OperatorHoldingsRepository repo(
    OperatorRuntime r, {
    Duration tick = const Duration(milliseconds: 20),
  }) => OperatorHoldingsRepository(
    r,
    hasBody: kOperatorRouteBodies.byPattern.containsKey,
    tick: tick,
  );

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
              asOfTradeDate: const TradeDate('2026-08-03'),
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
  }

  void hold(String strategy, String symbol, int qty, String decision) {
    db().execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES (?, ?, '2026-08-03T00:00:00Z', '2026-08-03', 'KR', ?, ?, ?, ?, 'BUY', "
      "'LIMIT', 1, 1, 'FILLED', 'cfg_test', '2026-08-03T00:00:00Z', ?)",
      <Object?>[
        'i-$symbol',
        'k-$symbol',
        _accounts[strategy],
        strategy,
        decision,
        symbol,
        RunMode.simInternal.wire,
      ],
    );
    db().execute(
      'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at, '
      "entry_decision_id) VALUES ('KR', ?, ?, ?, 10000, '2026-08-03', '2026-08-03T00:00:00Z', ?)",
      <Object?>[symbol, strategy, qty, decision],
    );
    db().execute(
      'INSERT OR IGNORE INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
      "VALUES ('2026-08-28', 'KR', ?, 10000, 10000, 10000, 10000, 10000, 0)",
      <Object?>[symbol],
    );
  }

  test('보유 0 = 빈 VM(설정 · 현금을 묻지 않는다)', () async {
    final HoldingsOverviewVm vm = await repo(rt())
        .watchHoldingsOverview()
        .first;
    expect(vm.cards, isEmpty);
    expect(vm.emptyLabel, startsWith('보유 종목이 없습니다'));
  });

  test(
    '🔴 원장 → 엔진 VM · 계좌 글자 = 사람 결정 표 · 🆕 R172 레지스트리 = 상세 · 배분 링크가 선다',
    () async {
      open();
      hold(P0sStrategyIds.sleeveA, '229200', 100, 'D-A');
      hold(P0sStrategyIds.sleeveB, '133690', 200, 'D-B');
      final HoldingsOverviewVm vm = await repo(rt())
          .watchHoldingsOverview()
          .first;
      expect(vm.cards.map((HoldingsSleeveCard c) => c.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.b,
        SleeveId.c,
      ]);
      expect(vm.cards[0].rows.single.accountAlias, 'ISA');
      expect(vm.cards[1].rows.single.accountAlias, '연금저축');
      expect(vm.cards[1].rows.single.entryDecision.intentId, 'i-133690');
      expect(
        vm.cards[1].rows.single.detailDeepLink,
        'aaq://holdings/detail/h_P0S_B_133690',
      );
      expect(vm.allocationLink?.deepLink, AppRoutes.holdingsAllocation);
      expect(vm.pnlToggleLabel, HoldingsTexts.pnlToggle);
      expect(vm.cards[2].rowsEmptyText, HoldingsTexts.rowsEmpty);
      expect(vm.asOf.label, startsWith('잔고 기준 2026-08-28 종가'));
      expect(
        kOperatorRouteBodies.byPattern.containsKey(AppRoutes.holdingsOverview),
        true,
      );
      final HoldingsOverviewVm pnl = await repo(rt())
          .watchHoldingsOverview(includePnl: true)
          .first;
      expect(pnl.cards[1].rows.single.pnl, isNotNull, reason: '펼침 = 종목 손익');
    },
  );

  test('🆕 R172 상세 = 같은 보유 행 · 매수 결정 링크 · 없는 보유 = 오류', () async {
    open();
    hold(P0sStrategyIds.sleeveB, '133690', 200, 'D-B');
    final OperatorHoldingsRepository r = repo(rt());
    final HoldingRow row =
        (await r.watchHoldingsOverview().first).cards[1].rows.single;
    final HoldingDetailVm d = await r.watchHoldingDetail(row.holdingId).first;
    expect(d.holding, row);
    expect(d.entryDecisionLink.deepLink, 'aaq://journal/decision/D-B');
    expect(d.recentEmptyLabel, HoldingsTexts.recentEmpty);
    expect(
      (await r.watchHoldingDetail(row.holdingId, includePnl: true).first)
          .holding
          .pnl,
      isNotNull,
    );
    await expectLater(
      r.watchHoldingDetail('h_P0S_B_999999'),
      emitsError(isA<StateError>()),
    );
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.holdingsDetail),
      true,
    );
  });

  test(
    '🆕 R172 배분 = 개시 전 빈 문장 → 개시 뒤 원화 현금 대기 → 보유가 서면 다섯 행(원장 변경으로)',
    () async {
      final OperatorHoldingsRepository r = repo(
        rt(),
        tick: const Duration(hours: 1),
      );
      final SleeveAllocationVm none = await r.watchAllocation().first;
      expect(none.emptyLabel, HoldingsTexts.allocationEmpty);
      open();
      final List<SleeveAllocationVm> got = <SleeveAllocationVm>[];
      final StreamSubscription<SleeveAllocationVm> sub = r
          .watchAllocation()
          .listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got.last.rows.last.bandNoteText, '원화 현금 대기 100.0% — 유휴가 아닙니다');
      hold(P0sStrategyIds.sleeveB, '133690', 200, 'D-B');
      await until(() => got.last.rows[2].deployedText != '0원');
      expect(got.last.rows.map((SleeveAllocationRow x) => x.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.pot,
        SleeveId.b,
        SleeveId.c,
        SleeveId.cash,
      ]);
      expect(
        kOperatorRouteBodies.byPattern.containsKey(
          AppRoutes.holdingsAllocation,
        ),
        true,
      );
    },
  );

  test('🆕 R173 다음 리밸런싱 · 미리보기 등록 = 링크 · 회차 = 원장(빈 → 행이 서면 다시 냄) · 상세 = 같은 행 · 기간 인자 = 원천 없음', () async {
    final OperatorRebalanceRepository r = OperatorRebalanceRepository(
      rt(),
      hasBody: kOperatorRouteBodies.byPattern.containsKey,
      tick: const Duration(hours: 1),
    );
    final NextRebalanceVm n = await r.watchNext().first;
    expect(n.dDayText, 'D-1', reason: '08-31 18:00 KST → 09-01');
    expect(n.expectedDateText, '2026년 9월 1일');
    expect(n.previewRoute, AppRoutes.rebalancePreview);
    final List<ListResult<RebalanceEvent>> got = <ListResult<RebalanceEvent>>[];
    final StreamSubscription<ListResult<RebalanceEvent>> sub = r
        .watchEvents()
        .listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.emptyLabel, '아직 리밸런싱 회차가 없습니다');
    db().execute(
      'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
      "weights_before, weights_after, config_hash, created_at) VALUES ('REB-MONTHLY-2026-07-31', "
      "'2026-07-31', ?, 'MONTHLY_REGULAR', 'MONTH-END-2026-07-31', '{\"targets\":2}', ?, ?, 'cfg_test', "
      "'2026-08-02T23:00:00Z')",
      <Object?>[
        RunMode.simInternal.wire,
        '[{"sleeve":"A","weight":0.2},{"sleeve":"B","weight":0.45},'
            '{"sleeve":"C","weight":0.35},{"sleeve":"POT","weight":0.0}]',
        '[{"sleeve":"A","weight":0.2},{"sleeve":"B","weight":0.42},'
            '{"sleeve":"C","weight":0.38},{"sleeve":"POT","weight":0.0}]',
      ],
    );
    await until(() => got.last.rows.isNotEmpty);
    final RebalanceEvent e = got.last.rows.single;
    expect(e.detailDeepLink, 'aaq://rebalance/event/REB-MONTHLY-2026-07-31');
    expect(e.modeLabel, '모의');
    expect(e.after[1].label, startsWith('B 42.0% '));
    expect(await r.watchEvent(e.eventId).first, e);
    await expectLater(r.watchEvent('nope'), emitsError(isA<StateError>()));
    await expectLater(
      r.watchEvents(
        range: const DateRange(
          from: TradeDate('2026-01-01'),
          to: TradeDate('2026-08-31'),
        ),
      ),
      emitsError(isA<UnsupportedError>()),
    );
    for (final String route in <String>[
      AppRoutes.rebalancePreview,
      AppRoutes.rebalanceHistory,
      AppRoutes.rebalanceEvent,
    ]) {
      expect(kOperatorRouteBodies.byPattern.containsKey(route), true);
    }
  });

  test('🆕 R173 지금 기준 초안 = 원장 상태 → 엔진(개시 전 = 실패 · 개시 뒤 = 초안 · 호출마다 새 id) · 🆕 R174 입금 = 섬 · 인출 = 원천 없음', () async {
    final OperatorWhatIfApi api = OperatorWhatIfApi(
      rt(),
      hasBody: kOperatorRouteBodies.byPattern.containsKey,
    );
    await expectLater(
      api.previewRebalance(),
      throwsA(isA<OpsConfigUnavailable>()),
    );
    open();
    for (final String s in p0sKrPlanSymbols()) {
      db().execute(
        'INSERT OR IGNORE INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, '
        "volume) VALUES ('2026-08-28', 'KR', ?, 10000, 10000, 10000, 10000, 10000, 0)",
        <Object?>[s],
      );
    }
    final RebalancePreviewResult r = await api.previewRebalance();
    expect(r.blockedText, isNull);
    expect(r.preview!.plannedDate, const TradeDate('2026-09-01'));
    expect(r.preview!.planId, 'pv_re_20260901_01');
    expect((await api.previewRebalance()).preview!.planId, 'pv_re_20260901_02');
    expect(
      (await api.simulateDeposit(amountInput: '100000')).plan,
      isNotNull,
      reason: '🆕 R174 입금 미리보기 = 같은 엔진 창구',
    );
    expect(await api.findPlan('x'), isNull);
    await expectLater(
      api.simulateWithdrawal(amount: Decimal.one),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('사람 결정 표가 없으면 계좌 별칭 그대로', () async {
    open();
    hold(P0sStrategyIds.sleeveB, '133690', 1, 'D-B');
    final HoldingsOverviewVm vm = await repo(rt(labels: false))
        .watchHoldingsOverview()
        .first;
    expect(vm.cards[1].rows.single.accountAlias, 'pension');
  });

  test('🔴 원장이 바뀌면 다시 낸다(새 보유 → 행이 선다)', () async {
    open();
    hold(P0sStrategyIds.sleeveB, '133690', 1, 'D-B');
    final List<HoldingsOverviewVm> got = <HoldingsOverviewVm>[];
    // 틱 = 1시간 — 다시 냄은 원장 변경으로만 온다.
    final StreamSubscription<HoldingsOverviewVm> sub = repo(
      rt(),
      tick: const Duration(hours: 1),
    ).watchHoldingsOverview().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.cards[2].rows, isEmpty);
    hold(P0sStrategyIds.sleeveC, '0085P0', 5, 'D-C');
    await until(() => got.last.cards[2].rows.length == 1);
    expect(got.last.cards[2].rows.single.symbol, '0085P0');
  });

  test('🔴 모의 밖 = 원천 없음 · 화면 상태 없음 = 오류(지어내지 않는다)', () async {
    open();
    hold(P0sStrategyIds.sleeveB, '133690', 1, 'D-B');
    await expectLater(
      repo(rt(mode: RunMode.live)).watchHoldingsOverview(),
      emitsError(isA<HoldingsSourceUnavailable>()),
    );
    final OperatorRuntime none = OperatorRuntime(files: files, clock: clock);
    await expectLater(
      repo(none).watchHoldingsOverview(),
      emitsError(isA<StateError>()),
    );
  });
}
