// 체결 재생 · 포지션 쓰기 공용(설계 13 §8 R137 N10 — X5 정정 `ledger_repair_store` 에서 꺼냄 · 동작 0 변경).
//
// 🔴 체결 = 브로커 주문이 있는 체결만(수동 = 브로커 주문 없음 = 빠진다) · 차례 = 입력(rowid).
// 🔴 쓰기 = 0 = 지움 · 남음 = 수량 · 평단 · 진입 갱신(ATR 등 그대로) · 새로 생김 = 넣음 — 부르는 쪽 트랜잭션 안.

import 'package:core_engine/core_engine.dart'
    show LedgerFillRow, ReplayedPosition;
import 'package:domain_contracts/domain_contracts.dart'
    show FillKind, OrderSide;
import 'package:sqlite3/sqlite3.dart';

/// 브로커 체결 행의 열(`e` = executions · `i` = order_intents) — [ledgerFillRowOf] 가 읽는다.
const String kLedgerFillColumnsSql =
    'e.execution_id, e.fill_kind, e.reverses_fill_id, e.restates_fill_id, e.quantity, '
    'e.price, e.broker_order_no, i.side, i.trade_date, i.decision_id';

/// [kLedgerFillColumnsSql] 한 행 → 재생 입력(🆕 E3d-3 — 월간 306 단계도 같이 쓴다).
LedgerFillRow ledgerFillRowOf(Row r) => LedgerFillRow(
  executionId: r['execution_id'] as String,
  kind: FillKind.values.firstWhere((FillKind k) => k.wire == r['fill_kind']),
  side: OrderSide.values.firstWhere((OrderSide s) => s.wire == r['side']),
  quantity: r['quantity'] as int,
  price: (r['price'] as num).toDouble(),
  brokerOrderNo: r['broker_order_no'] as String,
  tradeDate: r['trade_date'] as String,
  decisionId: r['decision_id'] as String,
  reversesFillId: r['reverses_fill_id'] as String?,
  restatesFillId: r['restates_fill_id'] as String?,
);

/// (시장 · 종목 · 전략)의 브로커 체결 — 입력 차례(rowid).
List<LedgerFillRow> ledgerFillRowsOf(
  Database db,
  String market,
  String symbol,
  String strategy,
) => <LedgerFillRow>[
  for (final Row r in db.select(
    'SELECT $kLedgerFillColumnsSql FROM executions e '
    'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
    'JOIN order_intents i ON i.intent_id = b.intent_id '
    'WHERE i.market = ? AND i.symbol = ? AND i.strategy_id = ? ORDER BY e.rowid',
    <Object?>[market, symbol, strategy],
  ))
    ledgerFillRowOf(r),
];

/// 🔴 다시 센 포지션을 쓴다 — 0 = 지움 · 남음 = 수량 · 평단 · 진입 갱신(ATR 등 그대로) · 새로 생김 = 넣음.
void writeReplayedPosition(
  Database db,
  List<Object?> key, {
  required bool exists,
  required ReplayedPosition p,
  required String iso,
}) {
  if (p.quantity == 0) {
    if (exists) {
      db.execute(
        'DELETE FROM positions WHERE market = ? AND symbol = ? AND strategy_id = ?',
        key,
      );
    }
    return;
  }
  if (exists) {
    db.execute(
      'UPDATE positions SET quantity = ?, avg_price = ?, entry_date = ?, entry_decision_id = ?, '
      'updated_at = ? WHERE market = ? AND symbol = ? AND strategy_id = ?',
      <Object?>[
        p.quantity,
        p.avgPrice,
        p.entryDate,
        p.entryDecisionId,
        iso,
        ...key,
      ],
    );
    return;
  }
  db.execute(
    'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, '
    'updated_at, entry_decision_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      ...key,
      p.quantity,
      p.avgPrice,
      p.entryDate,
      iso,
      p.entryDecisionId,
    ],
  );
}
