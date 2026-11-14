// 한도 입력의 원장 사실 — 전일 평가 · 입출금(E11p3b-2 · 설계 13 §8 R91 · core `LimitLedgerFactsSource` 구현).
//
// 🔴 원 단위 REAL 칸을 그대로 넘긴다 — 금액 계산(Decimal)은 core `LimitInputsCollector` 몫
//    (data_sync 허용 의존 = sqlite3 · 01 §1-1).
// 🔴 전일 평가 = 그날 **앞** 마지막 `equity_snapshot.total_equity`(그날 행은 20:30 평가라 주문 시각엔 없다 · 있어도 쓰지 않는다).
// 🔴 입출금 = `cash_flow.amount`(입금 +) — 그날 앞 합 · 그날 합. 금액 칸이 숫자가 아니면 StateError(지어내지 않는다).

import 'package:core_engine/core_engine.dart'
    show LimitLedgerFacts, LimitLedgerFactsSource;
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;
import 'package:sqlite3/sqlite3.dart';

/// 원장 사실 원천.
class SqliteLimitLedgerFacts implements LimitLedgerFactsSource {
  /// 만든다.
  SqliteLimitLedgerFacts(this._db);

  final Database _db;

  @override
  LimitLedgerFacts factsFor(TradeDate day) {
    final String d = day.yyyyMmDd;
    final Object? snap = _db.select(
      'SELECT total_equity FROM equity_snapshot WHERE trade_date < ? '
      'ORDER BY trade_date DESC LIMIT 1',
      <Object?>[d],
    ).firstOrNull?['total_equity'];
    return LimitLedgerFacts(
      previousSnapshotEquity: snap == null ? null : _real(snap),
      flowsBefore: _sum('SELECT amount FROM cash_flow WHERE trade_date < ?', d),
      flowsToday: _sum('SELECT amount FROM cash_flow WHERE trade_date = ?', d),
    );
  }

  double _sum(String sql, String day) {
    double s = 0;
    for (final Row r in _db.select(sql, <Object?>[day])) {
      s += _real(r['amount']);
    }
    return s;
  }

  static double _real(Object? v) => switch (v) {
    final int i => i.toDouble(),
    final double x => x,
    _ => throw StateError('금액 칸 꼴이 아니다: $v'),
  };
}
