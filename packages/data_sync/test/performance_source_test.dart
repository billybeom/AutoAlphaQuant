// E11q-q5b — M7 S7-2 시리즈 · S7-2G 게이트 · 열람 기록 원장 원천(설계 13 §8 R223) · 🆕 E11q-q5c S7-3 드로다운(R226) ·
// 🆕 E11q-q5c2 S7-3b 슬리브 기여(R228) — 실 SQLite(모의 원장).
//
// 🔴 시리즈 = 계층 B 와 같은 점(입출금 = 수익 아님) → 엔진 · 무결성 = `LEDGER_INTEGRITY` 깃발 · 열람 기록 = `command_inbox` 한 행 ·
//    집계 = 접수 시각의 한국 달 · 무결성 점검 중 = 보류 행(집계에 든다).

import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

bool _weekday(String ymd) =>
    DateTime.parse('${ymd}T00:00:00Z').weekday <= DateTime.friday;

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('r221_');
    clock = _Clock(DateTime.utc(2026, 8, 5, 9)); // 한국 08-05 18:00
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => clock.at);
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqlitePerformanceSource src() => SqlitePerformanceSource(db, clock: clock);

  void snap(String day, double equity) => db.execute(
    'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, ?, ?, 0, ?, 0, 'SIM_INTERNAL')",
    <Object?>[day, equity, equity, equity],
  );

  void deposit(String day, double amount) => db.execute(
    'INSERT INTO cash_flow(flow_id, trade_date, kind, amount, currency, note) '
    "VALUES (?, ?, 'DEPOSIT', ?, 'KRW', 'it')",
    <Object?>['f-$day', day, amount],
  );

  void integrity() => db.execute(
    "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-08-05T00:00:00.000Z', 'x')",
  );

  DisclosureViewCommand cmd(int seed) => DisclosureViewCommand.issue(
    event: DisclosureViewEvent(
      surfaceCode: DisclosureSurfaceCodes.performanceExplore,
      viewedAt: clock.at,
    ),
    deviceId: 'dev',
    nowUtc: clock.at,
    random: Random(seed),
  );

  CommandReceipt view(int seed) => src().record(
    cmd(seed),
    runMode: RunMode.simInternal,
    operatingMode: OperatingMode.autoTrade,
    leaseEpoch: 3,
  );

  PerformanceSeries daily() => src().series(
    metric: PerfMetric.twr,
    granularity: PerfGranularity.daily,
    cumulative: true,
    isSession: _weekday,
  );

  group('시리즈', () {
    test('원장 스냅숏 → 엔진과 같은 값 · 입금 = 수익 아님 · 열람 수 = 같은 원장', () {
      snap('2026-08-03', 100);
      snap('2026-08-04', 150);
      deposit('2026-08-04', 50);
      snap('2026-08-05', 153);
      view(1);
      final PerformanceSeries s = daily();
      expect(s.points.map((PerfPoint p) => p.valueText).toList(), <String>[
        '0.00%',
        '0.00%',
        '2.00%',
      ]);
      expect(
        s,
        performanceSeriesOf(
          metric: PerfMetric.twr,
          granularity: PerfGranularity.daily,
          cumulative: true,
          equity: tierBSeries(db, '2026-08-05'),
          isSession: _weekday,
          nowUtc: clock.at,
          viewCountThisMonth: 1,
          integrityHidden: false,
        ),
      );
      expect(s.disclosure.viewCountThisMonth, 1);
    });

    test('스냅숏 0 = 문장 카드 · 무결성 점검 중 = 가림', () {
      expect(daily().unavailableLabel, PerfSeriesTexts.noSnapshot);
      snap('2026-08-03', 100);
      snap('2026-08-04', 101);
      expect(daily().points, hasLength(2));
      integrity();
      final PerformanceSeries masked = daily();
      expect(masked.points, isEmpty);
      expect(masked.unavailableLabel, PerfSeriesTexts.integrityMasked);
    });
  });

  group('🆕 드로다운(R226)', () {
    test('같은 원장 점 → 엔진과 같은 값 · 스냅숏 0 / 무결성 = 실패', () {
      bool kr(String d) => _weekday(d);
      expect(() => src().drawdownContext(isSession: kr), throwsStateError);
      snap('2026-08-03', 100);
      snap('2026-08-04', 95);
      snap('2026-08-05', 97);
      final DrawdownContextVm v = src().drawdownContext(isSession: kr);
      expect(v.maxDdText, '최대 낙폭 −5.0%');
      expect(v.currentDdText, '현재 낙폭 −3.0%');
      expect(
        v,
        drawdownContextVmOf(
          equity: tierBSeries(db, '2026-08-05'),
          isSession: kr,
          nowUtc: clock.at,
          integrityHidden: false,
        ),
      );
      integrity();
      expect(() => src().drawdownContext(isSession: kr), throwsStateError);
    });
  });

  group('🆕 기여(R228)', () {
    const DateRange aug = DateRange(
      from: TradeDate('2026-08-01'),
      to: TradeDate('2026-08-31'),
    );
    int seq = 0;

    void bar(String symbol, String day, double unadj) => db.execute(
      'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
      "VALUES (?, 'KR', ?, 1, 1, 1, 1, ?, 0)",
      <Object?>[day, symbol, unadj],
    );

    void position(String strategy, String symbol, int qty) => db.execute(
      'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
      "VALUES ('KR', ?, ?, ?, 1, '2026-08-03', '2026-08-03T00:00:00Z')",
      <Object?>[symbol, strategy, qty],
    );

    /// 주문 의도 + 브로커 주문 + 체결 한 벌(집행일 = [day]).
    void fill(
      String strategy,
      String symbol,
      String day,
      int qty,
      double price, {
      String side = 'BUY',
      double commission = 0,
    }) {
      seq++;
      db.execute(
        'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
        'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
        "updated_at, mode) VALUES (?, ?, '2026-08-01T00:00:00Z', ?, 'KR', 'acc', ?, ?, ?, ?, 'LIMIT', ?, ?, "
        "'FILLED', 'cfg', '2026-08-01T00:00:00Z', ?)",
        <Object?>[
          'i$seq',
          'k$seq',
          day,
          strategy,
          'd$seq@$day',
          symbol,
          side,
          qty,
          price,
          RunMode.simInternal.wire,
        ],
      );
      db.execute(
        'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
        "VALUES (?, ?, '2026-08-01T00:00:00Z', 'FILLED')",
        <Object?>['$day:SIM$seq', 'i$seq'],
      );
      db.execute(
        'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, '
        "fill_origin) VALUES (?, ?, ?, ?, ?, ?, 'SIMULATED')",
        <Object?>[
          '$day:SIM$seq#$qty',
          '$day:SIM$seq',
          '${day}T06:00:00Z',
          qty,
          price,
          commission,
        ],
      );
    }

    void ledger() {
      clock.at = DateTime.utc(2026, 8, 31, 9);
      snap('2026-07-31', 10000000);
      // 8월 3일 A 100주 · B 200주 매수(수수료) · 8월 31일 마감.
      fill('P0S_A', 'AAA', '2026-08-03', 100, 10000, commission: 150);
      fill('P0S_B', 'BBB', '2026-08-03', 200, 20000, commission: 600);
      position('P0S_A', 'AAA', 100);
      position('P0S_B', 'BBB', 200);
      bar('AAA', '2026-08-31', 10420);
      bar('BBB', '2026-08-31', 19800);
      snap('2026-08-31', 10000000 - 1000150 - 4000600 + 1042000 + 3960000);
    }

    test('원장(스냅숏 · 보유 · 체결 · 원가 종가) → 엔진과 같은 값 · 수수료 = 손익', () {
      expect(() => src().contribution(range: aug), throwsStateError);
      ledger();
      final ContributionVm v = src().contribution(range: aug);
      // A = (1,042,000 − 1,000,150) ÷ 1,000만 = +0.42%p · B = (3,960,000 − 4,000,600) ÷ 1,000만 = −0.41%p.
      expect(
        <String>[for (final ContributionRow r in v.rows) r.contributionText],
        <String>['+0.42%p', '−0.41%p', '0.00%p'],
      );
      expect(v.periodLabel, '2026년 8월');
      expect(v.asOf.label, '기여 분해 기준 2026-08-31');
      expect(
        v,
        contributionVmOf(
          range: aug,
          equity: tierBSeries(db, '2026-08-31'),
          holdingsNow: const <LedgerHolding>[
            LedgerHolding('P0S_A', 'AAA', 100),
            LedgerHolding('P0S_B', 'BBB', 200),
          ],
          fills: const <ContributionFill>[
            ContributionFill(
              strategyId: 'P0S_A',
              symbol: 'AAA',
              tradeDate: '2026-08-03',
              side: OrderSide.buy,
              kind: FillKind.original,
              quantity: 100,
              price: 10000,
              commission: 150,
            ),
            ContributionFill(
              strategyId: 'P0S_B',
              symbol: 'BBB',
              tradeDate: '2026-08-03',
              side: OrderSide.buy,
              kind: FillKind.original,
              quantity: 200,
              price: 20000,
              commission: 600,
            ),
          ],
          closes: const <String, Map<String, double>>{
            'AAA': <String, double>{'2026-08-31': 10420},
            'BBB': <String, double>{'2026-08-31': 19800},
          },
          nowUtc: clock.at,
          integrityHidden: false,
        ),
      );
      integrity();
      expect(() => src().contribution(range: aug), throwsStateError);
    });

    test('종가 결측 = 그 슬리브 «산출 불가»(표본 partial 꼴) · 원가 종가 없음 = 결측', () {
      ledger();
      db.execute(
        "UPDATE daily_prices SET close_unadj = NULL WHERE symbol = 'BBB' AND trade_date = '2026-08-31'",
      );
      final ContributionVm v = src().contribution(range: aug);
      expect(v.rows[0].contributionText, '+0.42%p');
      expect(v.rows[1].contributionText, '산출 불가');
      expect(v.rows[1].unavailableLabel, '8월 31일 가격 결측 — 이 슬리브는 산출할 수 없습니다');
      expect(v.methodNoteText, ContributionTexts.methodPartial);
    });

    test('🔴 귀속 규칙 전 원장 사건 = 전 행 — 분배금(현금 흐름) · 기업행위(원장 사건) · 수기 체결', () {
      ledger();
      Set<String?> why() => <String?>{
        for (final ContributionRow r in src().contribution(range: aug).rows)
          r.unavailableLabel,
      };
      expect(why(), <String?>{null});
      db.execute(
        "INSERT INTO cash_flow(flow_id, trade_date, kind, amount, currency) VALUES ('dv', '2026-08-20', 'DISTRIBUTION', 100, 'KRW')",
      );
      expect(why(), <String?>{'8월 20일 분배금 기록(슬리브 귀속 전) — 이 슬리브는 산출할 수 없습니다'});
      db.execute("DELETE FROM cash_flow WHERE flow_id = 'dv'");
      db.execute(
        'INSERT INTO ledger_event (event_id, kind, entry_kind, effective_date, account_alias, symbol, '
        'action_type, ratio_from, ratio_to, decision_id, command_id, authored_by_device_id, authored_at) '
        "VALUES ('ca', 'CORPORATE_ACTION', 'ORIGINAL', '2026-09-03', 'acc', 'AAA', 'SPLIT', 1, 2, 'd', 'c', 'dev', "
        "'2026-09-03T00:00:00Z')",
      );
      expect(why(), <String?>{'9월 3일 기업행위 기록(슬리브 귀속 전) — 이 슬리브는 산출할 수 없습니다'});
      db.execute("DELETE FROM ledger_event WHERE event_id = 'ca'");
      db.execute(
        'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, fill_origin) '
        "VALUES ('m1', NULL, '2026-08-24T05:00:00Z', 1, 100, 'MANUAL')",
      );
      expect(why(), <String?>{'8월 24일 수기 체결 기록(슬리브 귀속 전) — 이 슬리브는 산출할 수 없습니다'});
    });
  });

  group('게이트 · 열람 기록', () {
    test('0회 = 열림 · 마찰 0 → 기록 2건 = «2번» · 기록 고지 · 행 = 종류 · 상태 · 맥락 · 지문', () {
      expect(
        src().gate(),
        disclosureGateVmOf(
          viewCountThisMonth: 0,
          integrityHidden: false,
          nowUtc: clock.at,
        ),
      );
      final CommandReceipt a = view(1);
      final CommandReceipt b = view(2);
      expect(a.state, CommandState.executed);
      expect(a.stateLabel, DisclosureGateTexts.recorded);
      expect(a.commandId, isNot(b.commandId));
      final DisclosureGateVm g = src().gate();
      expect(g.viewCountText, '이번 달 2번 열어 보셨습니다');
      expect(g.frictionLine, DisclosureGateTexts.friction);
      final Row r = db.select(
        'SELECT * FROM command_inbox WHERE command_id = ?',
        <Object?>[a.commandId],
      ).single;
      expect(r['kind'], 'DISCLOSURE_VIEW');
      expect(r['state'], 'EXECUTED');
      expect(r['state_label'], DisclosureGateTexts.recorded);
      expect(r['run_mode'], 'SIM_INTERNAL');
      expect(r['operating_mode'], 'AUTO_TRADE');
      expect(r['lease_epoch'], 3);
      expect(r['payload_digest'], cmd(1).payloadDigest);
    });

    test('집계 = 접수 시각의 한국 달 — 달이 바뀌면 0부터 · 다른 종류 명령은 세지 않는다', () {
      view(1);
      db.execute(
        'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, payload_digest) '
        "VALUES ('x', 'ALERT_ACK', ?, 'EXECUTED', '실행됨', 'd')",
        <Object?>[clock.at.toIso8601String()],
      );
      expect(src().disclosureViews('2026-08'), 1);
      clock.at = DateTime.utc(2026, 8, 31, 15); // 한국 09-01 00:00
      view(2);
      expect(src().disclosureViews('2026-08'), 1);
      expect(src().disclosureViews('2026-09'), 1);
      expect(src().gate().viewCountText, '이번 달 1번 열어 보셨습니다');
    });

    test('무결성 점검 중 = 게이트 닫힘 · 기록 = 보류 행(집계에 든다)', () {
      integrity();
      final DisclosureGateVm g = src().gate();
      expect(g.gateOpen, isFalse);
      expect(g.headline, DisclosureGateTexts.closedHeadline);
      final CommandReceipt h = view(1);
      expect(h.state, CommandState.heldForIntegrity);
      expect(h.stateLabel, DisclosureGateTexts.held);
      expect(
        db.select('SELECT state FROM command_inbox').single['state'],
        'HELD_FOR_INTEGRITY',
      );
      expect(src().disclosureViews('2026-08'), 1);
    });

    test('감시 표 = 시리즈 · 게이트 원천 다섯', () {
      expect(SqlitePerformanceSource.watchedTables, <String>{
        'equity_snapshot',
        'cash_flow',
        'decision_log',
        'command_inbox',
        'trading_block',
      });
    });
  });
}
