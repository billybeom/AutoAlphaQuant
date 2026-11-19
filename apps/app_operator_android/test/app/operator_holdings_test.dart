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
    show HoldingsTexts, P0sHumanInputs, P0sOpsConfig, P0sStrategyIds;
import 'package:data_sync/data_sync.dart'
    show
        HoldingsSourceUnavailable,
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

  test('🔴 원장 → 엔진 VM · 계좌 글자 = 사람 결정 표 · 지금 레지스트리 = 상세 · 배분 링크 0', () async {
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
    expect(vm.cards[1].rows.single.detailDeepLink, isNull);
    expect(vm.allocationLink, isNull);
    expect(vm.cards[2].rowsEmptyText, HoldingsTexts.rowsEmpty);
    expect(vm.asOf.label, startsWith('잔고 기준 2026-08-28 종가'));
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.holdingsOverview),
      true,
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
