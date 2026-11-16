// E16f2 — X5 정본 정정 역분개 쓰기 · 부호 있는 합계 · 포지션 다시 세기(설계 13 §8 R128 K1~K11).
//
// 🔵 잡는 것(진짜 길 — 의도 → 제출 → 체결 동기 `_position` 이 쓴 원장 위에서):
//    ① 무효 = REVERSAL 1행(원 행 값 그대로 · 오늘 귀속) → 주문 합 · 포지션 다시 셈 · `orderFills` 부호 있는 합
//    ② 정정 = REVERSAL + RESTATEMENT(새 값 · USER_ENTERED) · 정정의 정정 = 대체 · 체인 상한
//    ③ `ledger_repair` + 상세 · diff RESOLVED · RECON_MISMATCH 플래그 그대로 · 지난 스탬프 대조 통과
//    ④ 거부 = 쓰기 0(신뢰 시각 · 결정 · 원인 · diff · delta · 체결 · 열린 주문 · 되돌려진 대상 · 바뀌는 것 없음 ·
//       재생 앞 어긋남 · 재생 뒤 음수) · 다른 정정 중 = Busy ⑤ 매도 무효 = 포지션 되살림 · 행 다시 넣기
//    ⑥ 모의 장부 보기 = REVERSAL 음수.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 2, 0, 10); // KST 11-02 09:10
const TradeDate _exec = TradeDate('2026-11-02');
// 신뢰 시각 = KST 11-04 08:00(오늘 = 11-04 · 거래일 11-02 는 지난날).
final DateTime _now = DateTime.utc(2026, 11, 3, 23);
const String _o1 = '2026-11-02:0000000001';
const String _o2 = '2026-11-02:0000000002';
const String _delta =
    '{"symbol":"133690","ledger":5,"broker":3,"candidates":["MISRECORDED_FILL"]}';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final LimitConfig _limits = LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: Decimal.parse('20000000'),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
);

final LimitState _ok = LimitState(
  totalEquity: Decimal.parse('100000000'),
  ordersToday: null,
  riskExposureAfter: 0.5,
  leverageAfter: 0.9,
  positionsAfter: 5,
  satellitePositionsAfter: null,
  satelliteSectorCountAfter: null,
  satelliteAllocation: null,
  satelliteExposure: null,
  satelliteDeployedBefore: null,
  dailyPnlPct: 0,
  fxRateUsdKrw: null,
  strategyRegistered: null,
  tradingBlocked: null,
  journalMissing: null,
  tierBUnjudged: null,
);

OrderIntentDraft _draft({
  String symbol = '133690',
  OrderSide side = OrderSide.buy,
  String logical = 'B-SMA-2026-10-30',
}) => OrderIntentDraft(
  executionDate: _exec,
  account: 'pension',
  strategyId: P0sStrategyIds.sleeveB,
  symbol: symbol,
  side: side,
  quantity: 5,
  orderType: OrderTypes.limit,
  limitPrice: Decimal.parse('174180'),
  sizingPrice: Decimal.parse('174180'),
  logicalDecisionId: logical,
  decisionId: DecisionIds.forExecution(logical, _exec),
  instrument: InstrumentKind.etf,
);

void main() {
  late Directory dir;
  late Database db;
  late SqliteOrderLedger ledger;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteLedgerRepairStore store;
  late FakeOrderBroker broker;
  late Map<String, DailyFillRow> dayRows;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_fc_');
    clock = _Clock(_t0);
    trusted = _Trusted(_now);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    db.execute(
      'INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
      <Object?>[P0sStrategyIds.sleeveB, 'LIVE', '2026-10-01', 1.0],
    );
    ledger = SqliteOrderLedger(
      db,
      mode: RunMode.live,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
    );
    store = SqliteLedgerRepairStore(db, trusted: trusted);
    broker = FakeOrderBroker();
    dayRows = <String, DailyFillRow>{};
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  ExecutionContext ctx() => ExecutionContext(
    ledger: ledger,
    lease: FakeLeaseGate(),
    broker: broker,
    limitConfig: _limits,
    execPolicy: ExecPolicy.execute,
    operatingMode: OperatingMode.autoTrade,
    configHash: 'cfg-test',
  );

  Future<void> submit(OrderIntentDraft d) => executeIntent(d, _ok, ctx());

  /// 브로커 일별 체결 행(누적)을 바꾸고 체결 동기를 한 번 돌린다.
  Future<void> fill(
    String odno, {
    required int cum,
    required String amount,
    OrderSide side = OrderSide.buy,
    String symbol = '133690',
    int minute = 0,
  }) async {
    dayRows[odno] = DailyFillRow(
      orderDate: _exec,
      odno: odno,
      isCancelRow: false,
      symbol: symbol,
      side: side,
      orderQty: 5,
      cumFilledQty: cum,
      cumFilledAmount: Decimal.parse(amount),
      remainingQty: 5 - cum,
    );
    broker.fills[_exec.yyyyMmDd] = dayRows.values.toList();
    await runFillSync(
      ledger: ledger,
      brokers: <String, OrderBroker>{'pension': broker},
      tradeDate: _exec,
      nowUtc: DateTime.utc(2026, 11, 2, 1, minute),
      dayEnd: false,
      costs: const FillCostRates(commissionRate: 0.001, sellTaxRate: 0.002),
    );
  }

  /// 매수 5주 = 3주 @174180 + 2주 @175000(FILLED · 평단 174508).
  Future<void> boughtFive() async {
    await submit(_draft());
    await fill('0000000001', cum: 3, amount: '522540');
    await fill('0000000001', cum: 5, amount: '872540', minute: 5);
  }

  void openDiff(String id) => db.execute(
    'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, '
    "origin_code, status, detected_at, applicable) VALUES (?, 'CANON_BROKER', 'QUANTITY', "
    "'2026-11-03', ?, '수량 어긋남', 'BLOCKING', NULL, 'OPEN', '2026-11-03T08:00:00.000Z', 1)",
    <Object?>[id, _delta],
  );

  FillCorrectionResult correct(
    String fillId, {
    FillRestatement? to,
    String repairId = 'rp-1',
    String diffId = 'd-1',
    Iterable<String>? fresh,
    String? decision = 'DEC-1',
    String origin = OriginCodes.misrecordedFill,
    int chainLimit = 3,
  }) => store.correctFill(
    repairId: repairId,
    diffId: diffId,
    freshDiffIds: fresh ?? <String>[diffId],
    fillId: fillId,
    decisionId: decision,
    originCode: origin,
    chainLimit: chainLimit,
    restatement: to,
  );

  Map<String, Object?> one(String sql, [List<Object?> args = const []]) {
    final Row r = db.select(sql, args).single;
    return <String, Object?>{for (final String k in r.keys) k: r[k]};
  }

  Map<String, Object?> exec(String id) =>
      one('SELECT * FROM executions WHERE execution_id = ?', <Object?>[id]);

  (int, double?) order(String no) {
    final Map<String, Object?> r = one(
      'SELECT filled_qty, avg_fill_price FROM broker_orders WHERE broker_order_no = ?',
      <Object?>[no],
    );
    return (r['filled_qty']! as int, (r['avg_fill_price'] as num?)?.toDouble());
  }

  List<Map<String, Object?>> positions() => <Map<String, Object?>>[
    for (final Row r in db.select(
      'SELECT symbol, quantity, avg_price, entry_date, entry_decision_id FROM positions ORDER BY symbol',
    ))
      <String, Object?>{for (final String k in r.keys) k: r[k]},
  ];

  String dump() => <String>[
    for (final String t in <String>[
      'executions',
      'broker_orders',
      'positions',
      'order_intents',
      'ledger_repair',
      'ledger_repair_detail',
      'ledger_diff',
      'trading_block',
    ])
      jsonEncode(<Object?>[
        for (final Row r in db.select('SELECT * FROM $t ORDER BY 1'))
          <String, Object?>{for (final String k in r.keys) k: r[k]},
      ]),
  ].join('\n');

  bool fixVisible() => db
      .select("SELECT 1 FROM trading_block WHERE flag_id = 'LEDGER_FIX'")
      .isNotEmpty;

  test('정정 원인 MISRECORDED_FILL = 정본 정정 · 브로커 쌍 목록 안', () {
    expect(
      repairOriginCodesFor(
        RepairDirection.canonCorrect,
        LedgerPair.canonBroker,
      ),
      contains(OriginCodes.misrecordedFill),
    );
  });

  test('🔴 무효 — REVERSAL 1행(원 값 · 오늘 귀속) · 주문 합 · 포지션 다시 셈 · 정정 행 + 상세 · diff RESOLVED · 플래그 그대로', () async {
    await boughtFive();
    expect(positions().single['quantity'], 5);
    expect(positions().single['avg_price'], 174508.0);
    // 지난날 스탬프 · RECON_MISMATCH(사람이 푼다).
    clock.at = _now;
    LedgerHashStamper(db, clock: clock).stampThrough('2026-11-03');
    final String head =
        db
                .select(
                  "SELECT chain_hash FROM ledger_daily_hash WHERE authored_date = '2026-11-03'",
                )
                .single['chain_hash']
            as String;
    db.execute(
      "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('RECON_MISMATCH', '2026-11-03T08:00:00.000Z', 'x')",
    );
    openDiff('d-1');

    final FillCorrectionResult r = correct('$_o1#5');
    expect((r.applied, r.rejectCode), (true, null));
    expect(r.fillIds, <String>['$_o1#5|REV']);
    final Map<String, Object?> orig = exec('$_o1#5');
    final Map<String, Object?> rev = exec('$_o1#5|REV');
    for (final String k in <String>[
      'broker_order_no',
      'executed_at',
      'quantity',
      'price',
      'commission',
      'tax',
      'fill_origin',
      'cost_source',
    ]) {
      expect(rev[k], orig[k], reason: k);
    }
    expect(
      (
        rev['fill_kind'],
        rev['reverses_fill_id'],
        rev['restates_fill_id'],
        rev['authored_at'],
      ),
      ('REVERSAL', '$_o1#5', null, _now.toIso8601String()),
    );
    expect(order(_o1), (3, 174180.0));
    expect(positions(), <Map<String, Object?>>[
      <String, Object?>{
        'symbol': '133690',
        'quantity': 3,
        'avg_price': 174180.0,
        'entry_date': '2026-11-02',
        'entry_decision_id': 'B-SMA-2026-10-30@2026-11-02',
      },
    ]);
    expect(
      (await ledger.orderFills(_exec)).map((LedgerOrderFill f) => f.filledQty),
      <int>[3],
    );
    expect(one('SELECT * FROM ledger_repair'), <String, Object?>{
      'repair_id': 'rp-1',
      'diff_id': 'd-1',
      'direction': 'CANON_CORRECT',
      'origin_code': 'MISRECORDED_FILL',
      'decision_id': 'DEC-1',
      'evidence_hash': evidenceHashOf(_delta),
      'supersedes': null,
      'applied_at': _now.toIso8601String(),
    });
    expect(one('SELECT * FROM ledger_repair_detail'), <String, Object?>{
      'repair_id': 'rp-1',
      'recomputed_from': '2026-11-02',
      'chain_hash': head,
      'target_json':
          '{"kind":"QUANTITY","symbol":"133690","before":5,"after":3,'
          '"fill_id":"$_o1#5","restated_id":null}',
      'evidence_json': _delta,
    });
    expect(
      r.row!.targetJson,
      one('SELECT target_json FROM ledger_repair_detail')['target_json'],
    );
    expect(
      one("SELECT status, origin_code FROM ledger_diff WHERE diff_id = 'd-1'"),
      <String, Object?>{
        'status': 'RESOLVED',
        'origin_code': 'MISRECORDED_FILL',
      },
    );
    expect(
      db.select(
        "SELECT 1 FROM trading_block WHERE flag_id = 'RECON_MISMATCH' AND cleared_at IS NULL",
      ),
      hasLength(1),
    );
    expect(fixVisible(), isFalse);
    // 🔴 지난 스탬프는 그대로 대조 통과(새 행은 오늘 귀속).
    final LedgerIntegrityReport ir = LedgerIntegrityCheck(
      db,
      clock: clock,
    ).run();
    expect((ir.verdict.ok, ir.flagRaised), (true, false));
    // 정정 이력 문장.
    final StoredLedgerRepair s = storedLedgerRepairs(db).single;
    expect(
      (repairLabelOf(s), repairTargetTextOf(s)),
      ('잘못 기록된 체결을 바로잡아 수량 정정 · 2026-11-02부터 재계산', '133690 수량 5 → 3주'),
    );
  });

  test(
    '🔴 정정 — REVERSAL + RESTATEMENT(새 값 · USER_ENTERED) · 다시 적은 행은 원 자리에서 재생',
    () async {
      await boughtFive();
      openDiff('d-1');
      final FillCorrectionResult r = correct(
        '$_o1#3',
        to: FillRestatement(quantity: 4, price: 174000, commission: 10, tax: 0),
      );
      expect(r.fillIds, <String>['$_o1#3|REV', '$_o1#3|RST']);
      final Map<String, Object?> rst = exec('$_o1#3|RST');
      expect(
        (
          rst['quantity'],
          rst['price'],
          rst['commission'],
          rst['tax'],
          rst['cost_source'],
          rst['fill_kind'],
          rst['restates_fill_id'],
          rst['reverses_fill_id'],
          rst['executed_at'],
          rst['broker_order_no'],
          rst['fill_origin'],
          rst['authored_at'],
        ),
        (
          4,
          174000.0,
          10.0,
          0.0,
          'USER_ENTERED',
          'RESTATEMENT',
          '$_o1#3',
          null,
          exec('$_o1#3')['executed_at'],
          _o1,
          'BROKER',
          _now.toIso8601String(),
        ),
      );
      // 스탬프가 없으면 체인 = 체인 시작값.
      expect(r.row!.chainHash, kChainGenesis);
      final (int q, double? avg) = order(_o1);
      expect(q, 6);
      expect(avg, closeTo(1046000 / 6, 1e-6));
      final Map<String, Object?> p = positions().single;
      expect(p['quantity'], 6);
      expect(p['avg_price'] as double, closeTo(1046000 / 6, 1e-6));
      expect(jsonDecode(r.row!.targetJson!), <String, Object?>{
        'kind': 'QUANTITY',
        'symbol': '133690',
        'before': 5,
        'after': 6,
        'fill_id': '$_o1#3',
        'restated_id': '$_o1#3|RST',
      });
      expect(
        (await ledger.orderFills(_exec))
            .map((LedgerOrderFill f) => f.filledQty),
        <int>[6],
      );
    },
  );

  test('🔴 정정의 정정 = 앞 정정을 대체 · 체인 상한 · 무효도 대체', () async {
    await boughtFive();
    openDiff('d-1');
    correct(
      '$_o1#3',
      to: FillRestatement(quantity: 4, price: 174000, commission: 10, tax: 0),
    );
    openDiff('d-2');
    final String before = dump();
    final FillCorrectionResult over = correct(
      '$_o1#3|RST',
      repairId: 'rp-2',
      diffId: 'd-2',
      chainLimit: 1,
      to: FillRestatement(quantity: 3, price: 174180, commission: 5, tax: 0),
    );
    expect(over.rejectCode, AdviceRejectCodes.amendLimitExceeded);
    expect(dump(), before);
    final FillCorrectionResult r2 = correct(
      '$_o1#3|RST',
      repairId: 'rp-2',
      diffId: 'd-2',
      chainLimit: 2,
      to: FillRestatement(quantity: 3, price: 174180, commission: 5, tax: 0),
    );
    expect(r2.fillIds, <String>['$_o1#3|RST|REV', '$_o1#3|RST|RST']);
    expect(r2.row!.supersedes, 'rp-1');
    expect(positions().single['quantity'], 5);
    expect(positions().single['avg_price'], 174508.0);
    openDiff('d-3');
    final FillCorrectionResult r3 = correct(
      '$_o1#3|RST|RST',
      repairId: 'rp-3',
      diffId: 'd-3',
    );
    expect(r3.fillIds, <String>['$_o1#3|RST|RST|REV']);
    expect(r3.row!.supersedes, 'rp-2');
    expect(order(_o1), (2, 175000.0));
    expect(positions().single['quantity'], 2);
    expect(
      db
          .select(
            'SELECT repair_id, supersedes FROM ledger_repair ORDER BY repair_id',
          )
          .map((Row x) => (x['repair_id'], x['supersedes'])),
      <(Object?, Object?)>[('rp-1', null), ('rp-2', 'rp-1'), ('rp-3', 'rp-2')],
    );
    expect(
      repairLabelOf(
        storedLedgerRepairs(db)
            .firstWhere((StoredLedgerRepair s) => s.repairId == 'rp-2'),
      ),
      startsWith('잘못 기록된 체결을 바로잡아 앞선 정정을 다시 정정'),
    );
  });

  test('🔴 앞 정정을 못 찾으면 되돌림(지어내지 않는다)', () async {
    await boughtFive();
    openDiff('d-1');
    correct(
      '$_o1#3',
      to: FillRestatement(quantity: 4, price: 174000, commission: 10, tax: 0),
    );
    db.execute('DELETE FROM ledger_repair_detail');
    db.execute('DELETE FROM ledger_repair');
    openDiff('d-2');
    final String before = dump();
    expect(
      () => correct('$_o1#3|RST', repairId: 'rp-2', diffId: 'd-2'),
      throwsStateError,
    );
    expect(dump(), before);
    expect(fixVisible(), isFalse);
  });

  group('매도 무효 · 포지션 행', () {
    test('매도 무효 = 수량 되살림(평단 · 진입 그대로)', () async {
      await boughtFive();
      await submit(_draft(side: OrderSide.sell, logical: 'B-OUT-2026-10-30'));
      await fill(
        '0000000002',
        cum: 2,
        amount: '360000',
        side: OrderSide.sell,
        minute: 9,
      );
      dayRows['0000000002'] = DailyFillRow(
        orderDate: _exec,
        odno: '0000000002',
        isCancelRow: false,
        symbol: '133690',
        side: OrderSide.sell,
        orderQty: 5,
        cumFilledQty: 2,
        cumFilledAmount: Decimal.parse('360000'),
        remainingQty: 0,
      );
      broker.fills[_exec.yyyyMmDd] = dayRows.values.toList();
      await runFillSync(
        ledger: ledger,
        brokers: <String, OrderBroker>{'pension': broker},
        tradeDate: _exec,
        nowUtc: DateTime.utc(2026, 11, 2, 7),
        dayEnd: true,
        costs: const FillCostRates(commissionRate: 0.001, sellTaxRate: 0.002),
      );
      expect(
        db
            .select('SELECT status FROM order_intents ORDER BY created_at')
            .map((Row x) => x['status']),
        isNot(contains(anyOf('SUBMITTED', 'PARTIAL'))),
      );
      expect(positions().single['quantity'], 3);
      openDiff('d-1');
      final FillCorrectionResult r = correct('$_o2#2');
      expect(r.applied, isTrue);
      expect(positions().single, <String, Object?>{
        'symbol': '133690',
        'quantity': 5,
        'avg_price': 174508.0,
        'entry_date': '2026-11-02',
        'entry_decision_id': 'B-SMA-2026-10-30@2026-11-02',
      });
      expect(order(_o2), (0, null));
      // 🔴 모의 장부 보기 — 매도 REVERSAL 은 세금도 음수(매도세 > 0).
      final List<SimExecution> xs = await SqliteSimLedgerView(
        db,
        account: 'pension',
        strategies: <String>{P0sStrategyIds.sleeveB},
        clock: clock,
      ).executions();
      final Map<String, Object?> s = exec('$_o2#2');
      expect((s['tax']! as num).toDouble(), greaterThan(0));
      expect(
        (xs.last.side, xs.last.quantity, xs.last.commission, xs.last.tax),
        (
          OrderSide.sell,
          -2,
          -(s['commission']! as num).toDouble(),
          -(s['tax']! as num).toDouble(),
        ),
      );
    });

    test('진입 매수 무효 = 다음 매수가 진입(행 갱신 · 평단 · 결정)', () async {
      await submit(_draft());
      await fill('0000000001', cum: 5, amount: '870900');
      await submit(_draft(logical: 'B-SMA-2026-10-31'));
      await fill('0000000002', cum: 5, amount: '875000', minute: 9);
      expect(positions().single['quantity'], 10);
      openDiff('d-1');
      expect(correct('$_o1#5').applied, isTrue);
      expect(positions().single, <String, Object?>{
        'symbol': '133690',
        'quantity': 5,
        'avg_price': 175000.0,
        'entry_date': '2026-11-02',
        'entry_decision_id': 'B-SMA-2026-10-31@2026-11-02',
      });
    });

    test('거래일 = 오늘이면 다시 센 첫 날 없음', () async {
      await boughtFive();
      openDiff('d-1');
      trusted.at = DateTime.utc(2026, 11, 2, 6); // KST 11-02 15:00
      final FillCorrectionResult r = correct('$_o1#5');
      expect((r.applied, r.row!.recomputedFrom), (true, null));
    });

    test('전량 매도 뒤 매도 무효 = 행을 다시 넣는다(진입 = 매수)', () async {
      await boughtFive();
      await submit(_draft(side: OrderSide.sell, logical: 'B-OUT-2026-10-30'));
      await fill(
        '0000000002',
        cum: 5,
        amount: '900000',
        side: OrderSide.sell,
        minute: 9,
      );
      expect(positions(), isEmpty);
      openDiff('d-1');
      expect(correct('$_o2#5').applied, isTrue);
      expect(positions().single, <String, Object?>{
        'symbol': '133690',
        'quantity': 5,
        'avg_price': 174508.0,
        'entry_date': '2026-11-02',
        'entry_decision_id': 'B-SMA-2026-10-30@2026-11-02',
      });
    });

    test('하나뿐인 매수 무효 = 행을 지운다 · 주문 합 0 · 평단 null', () async {
      await submit(_draft());
      await fill('0000000001', cum: 5, amount: '870900');
      openDiff('d-1');
      expect(correct('$_o1#5').applied, isTrue);
      expect(positions(), isEmpty);
      expect(order(_o1), (0, null));
      expect(
        (await ledger.orderFills(_exec))
            .map((LedgerOrderFill f) => f.filledQty),
        <int>[0],
      );
    });

    test('🔴 재생 뒤 중간 음수(뒤 매도가 기댄 매수 무효) = 거부 · 쓰기 0', () async {
      await submit(_draft());
      await fill('0000000001', cum: 5, amount: '870900');
      await submit(_draft(side: OrderSide.sell, logical: 'B-OUT-2026-10-30'));
      await fill(
        '0000000002',
        cum: 5,
        amount: '900000',
        side: OrderSide.sell,
        minute: 9,
      );
      openDiff('d-1');
      final String before = dump();
      expect(correct('$_o1#5').rejectCode, RepairCodes.positionNegative);
      expect(dump(), before);
    });
  });

  group('🔴 거부 = 쓰기 0', () {
    late String before;
    setUp(() async {
      await boughtFive();
      openDiff('d-1');
      before = dump();
    });

    void rejects(FillCorrectionResult Function() call, String code) {
      final FillCorrectionResult r = call();
      expect((r.applied, r.rejectCode, r.row), (false, code, null));
      expect(r.fillIds, isEmpty);
      expect(dump(), before);
      expect(fixVisible(), isFalse);
    }

    test('신뢰 시각 모름', () {
      trusted.at = null;
      rejects(() => correct('$_o1#5'), BaselineStoreCodes.trustedTimeUnknown);
    });
    test('결정 없음 · 빈 결정', () {
      rejects(
        () => correct('$_o1#5', decision: null),
        RepairCodes.decisionRequired,
      );
      rejects(
        () => correct('$_o1#5', decision: '  '),
        RepairCodes.decisionRequired,
      );
    });
    test('원인 밖(파생 계열 · 모르는 코드)', () {
      rejects(
        () => correct('$_o1#5', origin: OriginCodes.derived.first),
        RepairCodes.originNotAllowed,
      );
      rejects(
        () => correct('$_o1#5', origin: 'NOPE'),
        RepairCodes.originNotAllowed,
      );
    });
    test('diff 가 OPEN CANON_BROKER 가 아니다(없음 · ACCEPTED · 다른 쌍)', () {
      rejects(() => correct('$_o1#5', diffId: 'd-x'), RepairCodes.diffNotOpen);
      db.execute("UPDATE ledger_diff SET status = 'ACCEPTED'");
      before = dump();
      rejects(() => correct('$_o1#5'), RepairCodes.diffNotOpen);
      db.execute(
        "UPDATE ledger_diff SET status = 'OPEN', pair = 'CANON_GITHUB'",
      );
      before = dump();
      rejects(() => correct('$_o1#5'), RepairCodes.diffNotOpen);
    });
    test('🔴 delta 가 바뀌었다(다시 대사에 없음)', () {
      rejects(
        () => correct('$_o1#5', fresh: <String>['d-other']),
        RepairCodes.deltaChanged,
      );
    });
    test('브로커 체결이 아니거나 없다', () {
      rejects(() => correct('nope'), RepairCodes.fillNotBroker);
    });
    test('🔴 주문이 아직 열려 있다(PARTIAL)', () async {
      await submit(_draft(symbol: '411060'));
      await fill(
        '0000000002',
        cum: 3,
        amount: '30000',
        symbol: '411060',
        minute: 9,
      );
      before = dump();
      rejects(() => correct('$_o2#3'), RepairCodes.orderOpen);
    });
    test('대상이 REVERSAL 행 · 이미 되돌려짐', () {
      expect(correct('$_o1#5').applied, isTrue);
      openDiff('d-2');
      before = dump();
      rejects(
        () => correct('$_o1#5|REV', repairId: 'rp-2', diffId: 'd-2'),
        AdviceRejectCodes.amendTargetNotActive,
      );
      rejects(
        () => correct('$_o1#5', repairId: 'rp-2', diffId: 'd-2'),
        AdviceRejectCodes.amendTargetNotActive,
      );
    });
    test('바뀌는 것 없음', () {
      rejects(
        () => correct(
          '$_o1#5',
          to: FillRestatement(
            quantity: 2,
            price: 175000,
            commission: 1,
            tax: 0,
          ),
        ),
        RepairCodes.noChange,
      );
    });
    test('🔴 재생 앞 = 저장 포지션과 다르다(수량 · 평단)', () {
      db.execute('UPDATE positions SET quantity = 4');
      before = dump();
      rejects(() => correct('$_o1#5'), RepairCodes.positionDrift);
      db.execute('UPDATE positions SET quantity = 5, avg_price = 174509');
      before = dump();
      rejects(() => correct('$_o1#5'), RepairCodes.positionDrift);
      db.execute('DELETE FROM positions');
      before = dump();
      rejects(() => correct('$_o1#5'), RepairCodes.positionDrift);
    });
    test('평단 끝자리 어긋남(허용 안)은 통과', () {
      db.execute('UPDATE positions SET avg_price = ?', <Object?>[
        174508 * (1 + kReplayAvgTolerance / 10),
      ]);
      expect(correct('$_o1#5').applied, isTrue);
    });
    test('다른 정정 중 = Busy · 체인 상한 0 = ArgumentError(되돌림)', () {
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_FIX', '2026-11-03T08:00:00.000Z', 'x')",
      );
      expect(() => correct('$_o1#5'), throwsA(isA<LedgerFixBusy>()));
      db.execute("DELETE FROM trading_block WHERE flag_id = 'LEDGER_FIX'");
      expect(
        () => correct(
          '$_o1#5',
          chainLimit: 0,
          to: FillRestatement(
            quantity: 1,
            price: 175000,
            commission: 1,
            tax: 0,
          ),
        ),
        throwsArgumentError,
      );
      expect(dump(), before);
      expect(fixVisible(), isFalse);
    });
  });

  test('새 값 꼴 — 수량 · 가격 0 이하 · 비용 음수 = ArgumentError · 정정 행 id', () {
    expect(
      () => FillRestatement(quantity: 0, price: 1, commission: 0, tax: 0),
      throwsArgumentError,
    );
    expect(
      () => FillRestatement(quantity: 1, price: 0, commission: 0, tax: 0),
      throwsArgumentError,
    );
    expect(
      () => FillRestatement(quantity: 1, price: 1, commission: -1, tax: 0),
      throwsArgumentError,
    );
    expect(
      () => FillRestatement(quantity: 1, price: 1, commission: 0, tax: -1),
      throwsArgumentError,
    );
    expect(correctionFillIdOf('x#5', FillKind.reversal), 'x#5|REV');
    expect(correctionFillIdOf('x#5', FillKind.restatement), 'x#5|RST');
    expect(
      () => correctionFillIdOf('x', FillKind.original),
      throwsArgumentError,
    );
  });

  test('🔴 모의 장부 보기 = REVERSAL 행은 수량 · 수수료 · 세금 음수(현금이 되돌아간다)', () async {
    await boughtFive();
    openDiff('d-1');
    correct('$_o1#5');
    final List<SimExecution> xs = await SqliteSimLedgerView(
      db,
      account: 'pension',
      strategies: <String>{P0sStrategyIds.sleeveB},
      clock: clock,
    ).executions();
    final Map<String, Object?> o = exec('$_o1#5');
    expect(
      xs.map(
        (SimExecution e) => (e.side, e.quantity, e.price, e.commission, e.tax),
      ),
      <(OrderSide, int, double, double, double)>[
        (
          OrderSide.buy,
          3,
          174180,
          (exec('$_o1#3')['commission']! as num).toDouble(),
          0,
        ),
        (
          OrderSide.buy,
          2,
          175000,
          (o['commission']! as num).toDouble(),
          (o['tax']! as num).toDouble(),
        ),
        (
          OrderSide.buy,
          -2,
          175000,
          -(o['commission']! as num).toDouble(),
          -(o['tax']! as num).toDouble(),
        ),
      ],
    );
  });
}
