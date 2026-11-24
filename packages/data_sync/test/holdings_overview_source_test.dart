// 🆕 E11q1 — M6 H6-1 보유 현황 원천(설계 13 §8 R171): 원장 원문 → 엔진 VM.
//
// 🔴 셈은 엔진 — 여기는 모으기만 한다: 보유 ⋈ 진입 결정(같은 전략 · 종목의 첫 매수 의도) · 계좌마다 가상 현금 합 ·
//    기준일 = 보유 종목 마지막 원가 종가 중 가장 이른 날 · 그날까지의 원가 종가 · 트랜치 = 수정 종가 · 차단 가림 · 모의 밖 = 원천 없음.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        HoldingPositionFact,
        HoldingsOverviewFacts,
        HoldingsTexts,
        Market,
        MonthEndInputError,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        WhatIfConfig,
        bTrancheSignalsOf,
        frozenExchangeCalendar,
        holdingsOverviewVmOf,
        monthlyLastCloses,
        nextRegularRebalance;
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/ops_config_seed.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 8, 31, 9); // 18:00 KST

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'isa',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'isa',
};

const Map<String, String> _labels = <String, String>{
  'isa': 'ISA',
  'pension': '연금저축',
  'general': '일반 위탁',
};

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

final P0sOpsConfig _cfg = P0sOpsConfig.of(
  P0sHumanInputs(aSymbol: '229200', accountByStrategy: _accounts),
);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  int seq = 0;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11q1_');
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
    seq = 0;
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteHoldingsOverviewSource src({RunMode mode = RunMode.simInternal}) =>
      SqliteHoldingsOverviewSource(
        db,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
        runMode: mode,
        accountLabels: _labels,
        hasBody: (String _) => false,
      );

  void open() {
    final String hash = SqliteConfigVersionStore(
      db,
      clock: clock,
    ).register(_cfg.content());
    final SqliteOnboardingStore s = SqliteOnboardingStore(db, clock: clock);
    expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
    expect(
      s
          .declareSimOpening(
            SelfReportBalance(
              asOfTradeDate: const TradeDate('2026-08-03'),
              purpose: SelfReportPurpose.simOpening,
              sessionStartedAt: _t0,
              lines: const <SelfReportLine>[],
              cashKrw: Decimal.parse('10000000'),
              accountAlias: 'general',
              declaredComplete: true,
              context: _ctx,
            ),
            accountByStrategy: _accounts,
            configHash: hash,
          )
          .ok,
      true,
    );
  }

  void intent(
    String strategy,
    String symbol,
    String decision, {
    String side = 'BUY',
    String? id,
  }) {
    seq++;
    db.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES (?, ?, ?, '2026-08-03', 'KR', ?, ?, ?, ?, ?, 'LIMIT', 1, 1, 'FILLED', ?, ?, ?)",
      <Object?>[
        id ?? 'i$seq-$symbol',
        'k$seq',
        _t0.toIso8601String(),
        _accounts[strategy],
        strategy,
        decision,
        symbol,
        side,
        'cfg-$seq',
        _t0.toIso8601String(),
        RunMode.simInternal.wire,
      ],
    );
  }

  void position(
    String strategy,
    String symbol,
    int qty,
    double avg, {
    String? decision,
  }) => db.execute(
    'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at, '
    "entry_decision_id) VALUES ('KR', ?, ?, ?, ?, '2026-08-03', ?, ?)",
    <Object?>[symbol, strategy, qty, avg, _t0.toIso8601String(), decision],
  );

  void bar(String symbol, String day, double close, {double? unadj}) =>
      db.execute(
        'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
        "VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 0)",
        <Object?>[day, symbol, close, close, close, close, unadj ?? close],
      );

  double cashSum() =>
      (db
                  .select('SELECT COALESCE(SUM(amount), 0) AS s FROM cash_flow')
                  .first['s']!
              as num)
          .toDouble();

  test('보유 0 = 빈 VM(설정 · 현금을 묻지 않는다 · 다음 판정일)', () {
    final HoldingsOverviewVm vm = src(mode: RunMode.live).overview();
    expect(vm.cards, isEmpty);
    final TradeDate next = nextRegularRebalance(
      frozenExchangeCalendar(Market.kr),
      const TradeDate('2026-08-31'),
    )!.judgment;
    expect(vm.emptyLabel, HoldingsTexts.empty(next));
  });

  group('보유 있음', () {
    setUp(() {
      open();
      // 진입 결정 — 같은 결정의 다른 종목 · 매도 의도는 고르지 않는다.
      intent(P0sStrategyIds.sleeveA, '229200', 'D-A', id: 'i0-229200');
      intent(P0sStrategyIds.sleeveB, '411060', 'D-B', id: 'i0-411060');
      intent(P0sStrategyIds.sleeveB, '133690', 'D-B', side: 'SELL', id: 'i0-x');
      intent(P0sStrategyIds.sleeveB, '133690', 'D-B', id: 'i1-133690');
      intent(P0sStrategyIds.sleeveC, '0085P0', 'D-C', id: 'i2-0085P0');
      position(P0sStrategyIds.sleeveA, '229200', 100, 9800, decision: 'D-A');
      position(P0sStrategyIds.sleeveB, '133690', 200, 20000, decision: 'D-B');
      position(P0sStrategyIds.sleeveC, '0085P0', 50, 10000, decision: 'D-C');
      // B 13달 수정 종가(오름) — 원가 종가는 다르다(평가 = 원가 · 트랜치 = 수정).
      for (int i = 0; i < 12; i++) {
        final int y = i < 5 ? 2025 : 2026;
        final int m = i < 5 ? 8 + i : i - 4;
        final String d = '$y-${m.toString().padLeft(2, '0')}-27';
        bar('133690', d, 10000.0 + i * 100);
        bar('411060', d, 20000.0 + i * 100);
      }
      bar('133690', '2026-08-28', 19000, unadj: 21000);
      // 기준일 뒤 봉(수정 종가 급락) — 트랜치 판정에 들어가면 신호가 꺼진다.
      bar('133690', '2026-08-31', 5000, unadj: 21500);
      bar('411060', '2026-08-28', 21500, unadj: 20000);
      bar('229200', '2026-08-28', 9900, unadj: 10000);
      bar('229200', '2026-08-31', 9990, unadj: 10100);
      bar('0085P0', '2026-08-28', 10000);
    });

    test('🔴 엔진 VM = 손으로 모은 사실의 VM(기준일 = 가장 이른 마지막 봉 · 원가 종가 · 현금 합)', () {
      final HoldingsOverviewVm vm = src().overview();
      List<(String, double)> b(String s) => <(String, double)>[
        for (final Row r in db.select(
          'SELECT trade_date, close FROM daily_prices WHERE symbol = ? '
          "AND trade_date <= '2026-08-28' ORDER BY trade_date",
          <Object?>[s],
        ))
          (r['trade_date'] as String, (r['close'] as num).toDouble()),
      ];
      DecisionRef ref(String d, String i, String h) =>
          DecisionRef(decisionId: d, intentId: i, configHash: h);
      final HoldingsOverviewVm want = holdingsOverviewVmOf(
        HoldingsOverviewFacts(
          positions: <HoldingPositionFact>[
            HoldingPositionFact(
              strategyId: P0sStrategyIds.sleeveA,
              symbol: '229200',
              quantity: 100,
              avgPrice: Decimal.parse('9800'),
              entryDate: const TradeDate('2026-08-03'),
              entryDecision: ref('D-A', 'i0-229200', 'cfg-1'),
            ),
            HoldingPositionFact(
              strategyId: P0sStrategyIds.sleeveB,
              symbol: '133690',
              quantity: 200,
              avgPrice: Decimal.parse('20000'),
              entryDate: const TradeDate('2026-08-03'),
              entryDecision: ref('D-B', 'i1-133690', 'cfg-4'),
            ),
            HoldingPositionFact(
              strategyId: P0sStrategyIds.sleeveC,
              symbol: '0085P0',
              quantity: 50,
              avgPrice: Decimal.parse('10000'),
              entryDate: const TradeDate('2026-08-03'),
              entryDecision: ref('D-C', 'i2-0085P0', 'cfg-5'),
            ),
          ],
          closes: <String, Decimal>{
            '229200': Decimal.parse('10000'),
            '133690': Decimal.parse('21000'),
            '0085P0': Decimal.parse('10000'),
            '411060': Decimal.parse('20000'),
          },
          closeDate: const TradeDate('2026-08-28'),
          cashKrw: Decimal.parse('${cashSum()}'),
          potCash: Decimal.zero,
          config: WhatIfConfig.defaults,
          accountAliasOf: (String s) => _labels[_accounts[s]]!,
          bTranches: bTrancheSignalsOf(<String, List<double>>{
            '133690': monthlyLastCloses(b('133690'), '2026-08'),
            '411060': monthlyLastCloses(b('411060'), '2026-08'),
          }, WhatIfConfig.defaults),
          nextTrancheDate: nextRegularRebalance(
            frozenExchangeCalendar(Market.kr),
            const TradeDate('2026-08-31'),
          )!.judgment,
          integrityHidden: false,
          reconSuspect: false,
          hasBody: (String _) => false,
          nowUtc: _t0,
        ),
      );
      expect(vm, want);
      expect(cashSum(), greaterThan(0), reason: '모의 개시 현금이 실렸다');
      expect(vm.asOf.label, startsWith('잔고 기준 2026-08-28 종가'));
      final HoldingRow b0 = vm.cards[1].rows.single;
      expect(b0.entryDecision.intentId, 'i1-133690');
      expect(b0.accountAlias, '연금저축');
      expect(vm.cards[0].rows.single.accountAlias, 'ISA');
      expect(
        vm.cards[1].allocation.trancheStateText,
        'B 트랜치 3/3 — SMA 신호 3개 점등',
        reason: '기준일(08-28)까지의 수정 종가 — 뒤 봉(08-31 급락)은 넣지 않는다',
      );
    });

    test('🔴 차단 가림 — 서 있는 LEDGER_INTEGRITY = 숨김 · 풀린 RECON_MISMATCH = 그대로', () {
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason, cleared_at) VALUES '
        "('LEDGER_INTEGRITY', '2026-08-31T00:00:00Z', 't', NULL), "
        "('RECON_MISMATCH', '2026-08-30T00:00:00Z', 't', '2026-08-30T01:00:00Z')",
      );
      final HoldingsOverviewVm vm = src().overview();
      expect(vm.cards[1].allocation.deployedText, HoldingsTexts.hidden);
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-08-31T01:00:00Z' WHERE flag_id = 'LEDGER_INTEGRITY'",
      );
      db.execute(
        "UPDATE trading_block SET cleared_at = NULL WHERE flag_id = 'RECON_MISMATCH'",
      );
      expect(src().overview().cards[1].rows.single.quantityText, '200주?');
    });

    test('🆕 E11q-q6 — L-3 실사 세션(그 폰)이 열린 동안 = LEDGER_INTEGRITY 와 같은 «숨김» · 닫히면 원래 글자', () {
      bool open = true;
      final SqliteHoldingsOverviewSource masked = SqliteHoldingsOverviewSource(
        db,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
        runMode: RunMode.simInternal,
        accountLabels: _labels,
        hasBody: (String _) => false,
        selfReportSessionOpen: () => open,
      );
      expect(
        masked.overview().cards[1].allocation.deployedText,
        HoldingsTexts.hidden,
      );
      expect(
        masked.overview().cards[1].rows.single.quantityText,
        HoldingsTexts.hidden,
      );
      open = false;
      expect(masked.overview().cards[1].rows.single.quantityText, '200주');
      expect(
        src().overview().cards[1].rows.single.quantityText,
        '200주',
        reason: '판정 함수 없음 = 가림 0',
      );
    });

    test('🔴 진입 결정을 못 찾으면 실패(행을 지어내지 않는다)', () {
      position(P0sStrategyIds.pot, '133690', 1, 20000, decision: 'D-NONE');
      expect(() => src().overview(), throwsStateError);
    });

    test('🔴 모의 밖 = 원천 없음(실계좌 현금 = 트랙 C) · 🆕 R265 모의 파일을 실전 모드로 읽으면 = 실전 개시 없음(모의 판을 빌리지 않는다)', () {
      expect(
        () => src(mode: RunMode.live).overview(),
        throwsA(
          isA<OpsConfigUnavailable>().having(
            (OpsConfigUnavailable u) => u.code,
            'code',
            OpsConfigCodes.noOpening,
          ),
        ),
      );
      // 실전 원장(실전 개시 판) = 설정은 읽고 현금 원천이 없다 — 배분 시험(보유 0)이 실제 실전 파일로 본다.
      expect(
        () => src(mode: RunMode.simBroker).overview(),
        throwsA(isA<HoldingsSourceUnavailable>()),
      );
    });

    test('🆕 R172 상세 = 같은 보유 행 · 원 체결 수(REVERSAL · 다른 종목 제외) → «준비 중» 문장', () {
      final HoldingRow b = src().overview().cards[1].rows.single;
      expect(src().detail(b.holdingId).holding, b);
      expect(
        src().detail(b.holdingId).recentEmptyLabel,
        HoldingsTexts.recentEmpty,
      );
      void fill(String no, String intentId, {String kind = 'ORIGINAL'}) {
        db.execute(
          'INSERT OR IGNORE INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
          "VALUES (?, ?, '2026-08-03T00:00:00Z', 'FILLED')",
          <Object?>[no, intentId],
        );
        db.execute(
          'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, fill_kind) '
          "VALUES (?, ?, '2026-08-03T06:00:00Z', 1, 1, ?)",
          <Object?>['$no#$kind', no, kind],
        );
      }

      fill('2026-08-03:SIM1', 'i1-133690');
      fill('2026-08-03:SIM2', 'i1-133690');
      fill('2026-08-03:SIM2', 'i1-133690', kind: 'REVERSAL');
      fill('2026-08-03:SIM3', 'i2-0085P0');
      expect(
        src().detail(b.holdingId).recentEmptyLabel,
        HoldingsTexts.recentPending(2),
      );
      expect(() => src().detail('h_P0S_B_999999'), throwsStateError);
    });

    test('🆕 R172 배분 = 다섯 행 · 원화 현금 = 개시 현금 합 · 카드 = A · B · C 행 그대로', () {
      final SleeveAllocationVm a = src().allocation();
      expect(a.rows, hasLength(5));
      expect(a.rows.last.parkingText, endsWith('만원'));
      final HoldingsOverviewVm vm = src().overview();
      expect(
        vm.cards.map((HoldingsSleeveCard c) => c.allocation).toList(),
        <SleeveAllocationRow>[a.rows[0], a.rows[2], a.rows[3]],
      );
      expect(
        src().overview(includePnl: true).cards[1].rows.single.pnl,
        isNotNull,
      );
    });

    test('🔴 봉 없는 보유 = 엔진 «종가 없음» 실패', () {
      intent(P0sStrategyIds.sleeveB, '214980', 'D-P');
      position(P0sStrategyIds.sleeveB, '214980', 1, 100000, decision: 'D-P');
      expect(() => src().overview(), throwsA(isA<MonthEndInputError>()));
    });
  });

  test('🔴 보유가 있는데 개시 설정이 없으면 실패(계좌를 지어내지 않는다)', () {
    intent(P0sStrategyIds.sleeveA, '229200', 'D-A');
    position(P0sStrategyIds.sleeveA, '229200', 1, 1, decision: 'D-A');
    bar('229200', '2026-08-28', 10000);
    expect(() => src().overview(), throwsA(isA<OpsConfigUnavailable>()));
  });

  group('🆕 R172 배분 — 보유 0', () {
    test('개시 전(설정 · 현금 0) = 빈 상태', () {
      final SleeveAllocationVm a = src().allocation();
      expect(a.rows, isEmpty);
      expect(a.emptyLabel, HoldingsTexts.allocationEmpty);
    });

    test('개시 뒤 보유 0 = 원화 현금 대기 100% · 모의 밖 = 원천 없음', () {
      open();
      final SleeveAllocationVm a = src().allocation();
      expect(a.rows.last.bandNoteText, '원화 현금 대기 100.0% — 유휴가 아닙니다');
      expect(src().overview().cards, isEmpty, reason: 'H6-1 = 빈 보유 그대로');
      // 🆕 R265 — 실전 원장(실전 개시 판) = 설정은 읽지만 실계좌 현금 원천 없음(트랙 C).
      final Database live = openLocalLedger(
        dir.path,
        RunMode.live,
        clock: () => _t0,
      );
      addTearDown(live.close);
      seedOpening(live, RunMode.live, clock: clock);
      expect(
        () => SqliteHoldingsOverviewSource(
          live,
          clock: clock,
          kr: frozenExchangeCalendar(Market.kr),
          runMode: RunMode.live,
          accountLabels: _labels,
          hasBody: (String _) => false,
        ).allocation(),
        throwsA(isA<HoldingsSourceUnavailable>()),
      );
    });

    test('🆕 리뷰 3차 E-1(미결 231 ⓒ · R265 · K206) — 개시 결정 없음만 빈 상태 · 판 바뀜 · 미등재 · 꼴 오류 = 그 사유를 던진다', () {
      open();
      Matcher code(String c) => throwsA(
        isA<OpsConfigUnavailable>().having(
          (OpsConfigUnavailable u) => u.code,
          'code',
          c,
        ),
      );
      final String good =
          db.select('SELECT content FROM config_versions').single['content']!
              as String;
      // 앱 업데이트로 SPEC 판이 바뀜(모의 개시 ~ 첫 체결 사이) = DRIFT — «배분 현황이 없습니다»로 가리지 않는다.
      db.execute(
        "UPDATE config_versions SET content = replace(content, '\"spec\":\"', '\"spec\":\"old-')",
      );
      expect(() => src().allocation(), code(OpsConfigCodes.drift));
      // 꼴 오류.
      db.execute("UPDATE config_versions SET content = 'x'");
      expect(() => src().allocation(), code(OpsConfigCodes.contentInvalid));
      // 미등재.
      db.execute('DELETE FROM config_versions');
      expect(() => src().allocation(), code(OpsConfigCodes.notRegistered));
      // H6-1(보유 0) = 설정을 묻지 않는다 — 그대로 빈 보유.
      expect(src().overview().cards, isEmpty);
      // 되돌리면 다시 읽는다.
      db.execute(
        'INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES (?, ?, ?, 0)',
        <Object?>[_cfg.configHash, _t0.toIso8601String(), good],
      );
      expect(src().allocation().rows, isNotEmpty);
    });
  });
}
