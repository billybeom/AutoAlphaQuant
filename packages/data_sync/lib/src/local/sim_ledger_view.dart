// 가상 체결 브로커가 읽는 원장(sim 파일 · 계좌 하나 · 설계 13 §8 R83 Y3 · Y5 · SPEC v2.44 04 §3-1 v2.44 ③).
//
// 🔴 시뮬레이터는 따로 저장하지 않는다 — 받은 주문 = 엔진이 쓴 `broker_orders` ⋈ `order_intents`(주문번호 `{주문일}:SIM…`).
// 🔴 현금 = 이 계좌 `cash_flow` 합 · 체결 · 판정 전 매수 · 잔고 = 이 계좌 전략들의 `positions`.
// 🔴 봉 없음 = `data_gap` 1행(`GAP-SIMBAR-{날짜}-{종목}` · 복구 불가 · 같은 날 · 종목 = 한 번).

import 'package:core_engine/core_engine.dart'
    show SimExecution, SimLedgerView, SimOrder, kSimOdnoPrefix;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, OrderSide, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'fill_sign_sql.dart' show signedFillSql;

/// 봉 공백 자료 이름.
const String kSimBarGapDataset = 'sim_fill_bar';

/// 봉 공백 사유.
const String kSimBarMissing = 'SIM_BAR_MISSING';

/// sim 원장 읽기(계좌 하나).
class SqliteSimLedgerView implements SimLedgerView {
  /// 읽기를 만든다 — [strategies] = 이 계좌에 묶인 전략(초안 설정의 전략 → 계좌).
  SqliteSimLedgerView(
    this._db, {
    required this.account,
    required this.strategies,
    required this._clock,
  });

  final Database _db;
  final Clock _clock;

  /// 계좌 별칭.
  final String account;

  /// 이 계좌의 전략.
  final Set<String> strategies;

  static const String _orderCols =
      'SELECT b.broker_order_no, i.symbol, i.side, i.quantity, i.order_type, i.limit_price '
      'FROM broker_orders b JOIN order_intents i ON i.intent_id = b.intent_id ';

  static SimOrder _order(Row r) {
    final String no = r['broker_order_no'] as String;
    final int cut = no.indexOf(':');
    return SimOrder(
      orderDate: TradeDate(no.substring(0, cut)),
      odno: no.substring(cut + 1),
      symbol: r['symbol'] as String,
      side: OrderSide.values.firstWhere((OrderSide s) => s.wire == r['side']),
      quantity: r['quantity'] as int,
      orderType: r['order_type'] as String,
      limitPrice: (r['limit_price'] as num?)?.toDouble(),
    );
  }

  @override
  Future<List<SimOrder>> ordersOf(TradeDate orderDate) async => <SimOrder>[
    for (final Row r in _db.select(
      '${_orderCols}WHERE i.account = ? AND b.broker_order_no LIKE ? ORDER BY b.broker_order_no',
      <Object?>[account, '${orderDate.yyyyMmDd}:$kSimOdnoPrefix%'],
    ))
      _order(r),
  ];

  @override
  Future<SimOrder?> orderNo(String brokerOrderNo) async {
    final ResultSet rs = _db.select(
      '${_orderCols}WHERE i.account = ? AND b.broker_order_no = ?',
      <Object?>[account, brokerOrderNo],
    );
    return rs.isEmpty ? null : _order(rs.first);
  }

  @override
  Future<int> maxSimSeq(TradeDate orderDate) async {
    final String prefix = '${orderDate.yyyyMmDd}:$kSimOdnoPrefix';
    int max = 0;
    for (final Row r in _db.select(
      'SELECT broker_order_no FROM broker_orders WHERE broker_order_no LIKE ?',
      <Object?>['$prefix%'],
    )) {
      final int? n = int.tryParse(
        (r['broker_order_no'] as String).substring(prefix.length),
      );
      if (n != null && n > max) max = n;
    }
    return max;
  }

  @override
  Future<double> cashFlowSum() async =>
      (_db.select(
                'SELECT COALESCE(SUM(amount), 0) AS s FROM cash_flow WHERE account_alias = ?',
                <Object?>[account],
              ).first['s']!
              as num)
          .toDouble();

  @override
  Future<List<SimExecution>> executions() async => <SimExecution>[
    for (final Row r in _db.select(
      // 🆕 E16f2 — REVERSAL = 수량 · 수수료 · 세금 음수(현금 셈이 정확히 되돌아간다 · R128 K2).
      'SELECT i.side, ${signedFillSql('e', 'quantity')} AS quantity, e.price, '
      '${signedFillSql('e', 'commission')} AS commission, '
      '${signedFillSql('e', 'tax')} AS tax FROM executions e '
      'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
      'JOIN order_intents i ON i.intent_id = b.intent_id '
      'WHERE i.account = ? ORDER BY e.execution_id',
      <Object?>[account],
    ))
      SimExecution(
        side: OrderSide.values.firstWhere((OrderSide s) => s.wire == r['side']),
        quantity: r['quantity'] as int,
        price: (r['price'] as num).toDouble(),
        commission: (r['commission'] as num).toDouble(),
        tax: (r['tax'] as num).toDouble(),
      ),
  ];

  @override
  Future<List<SimOrder>> openBuys() async => <SimOrder>[
    for (final Row r in _db.select(
      "${_orderCols}WHERE i.account = ? AND i.side = 'BUY' AND i.status IN ('SUBMITTED', 'PARTIAL') "
      'AND b.broker_order_no LIKE ? ORDER BY b.broker_order_no',
      <Object?>[account, '%:$kSimOdnoPrefix%'],
    ))
      _order(r),
  ];

  @override
  Future<Map<String, int>> holdings() async {
    if (strategies.isEmpty) return <String, int>{};
    final List<String> ids = strategies.toList()..sort();
    return <String, int>{
      for (final Row r in _db.select(
        "SELECT symbol, SUM(quantity) AS q FROM positions WHERE market = 'KR' AND strategy_id IN "
        '(${List<String>.filled(ids.length, '?').join(', ')}) GROUP BY symbol HAVING q > 0 ORDER BY symbol',
        ids,
      ))
        r['symbol'] as String: r['q'] as int,
    };
  }

  @override
  Future<void> recordBarGap(TradeDate date, String symbol) async => _db.execute(
    'INSERT OR IGNORE INTO data_gap (gap_id, dataset, from_date, to_date, recoverable, reason_code, detected_at) '
    'VALUES (?, ?, ?, ?, 0, ?, ?)',
    <Object?>[
      'GAP-SIMBAR-${date.yyyyMmDd}-$symbol',
      kSimBarGapDataset,
      date.yyyyMmDd,
      date.yyyyMmDd,
      kSimBarMissing,
      _clock.nowUtc().toUtc().toIso8601String(),
    ],
  );
}
