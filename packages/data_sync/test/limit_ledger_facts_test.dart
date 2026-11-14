// E11p3b-2 — 한도 입력의 원장 사실(설계 13 §8 R91).

import 'dart:io';

import 'package:core_engine/core_engine.dart' show LimitLedgerFacts;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late Database db;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('limf_');
    db = openLocalLedger(
      dir.path,
      RunMode.simInternal,
      clock: () => DateTime.utc(2026, 11, 14),
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void snap(String day, double equity) => db.execute(
    'INSERT INTO equity_snapshot (trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, ?, 0, 0, ?, 0, 'SIM_INTERNAL')",
    <Object?>[day, equity, equity],
  );

  void flow(String id, String day, double amount) => db.execute(
    'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, recorded_at, account_alias) '
    "VALUES (?, ?, ?, 'KRW', 'DEPOSIT', 'x', 'acct')",
    <Object?>[id, day, amount],
  );

  test('빈 원장 = 평가 없음 · 입출금 0', () {
    final LimitLedgerFacts f = SqliteLimitLedgerFacts(db)
        .factsFor(const TradeDate('2026-11-16'));
    expect(f.previousSnapshotEquity, isNull);
    expect(f.flowsBefore, 0);
    expect(f.flowsToday, 0);
  });

  test('🔴 전일 평가 = 그날 **앞** 마지막 행(그날 행은 쓰지 않는다)', () {
    snap('2026-11-12', 100);
    snap('2026-11-13', 110);
    snap('2026-11-16', 999);
    expect(
      SqliteLimitLedgerFacts(db)
          .factsFor(const TradeDate('2026-11-16'))
          .previousSnapshotEquity,
      110,
    );
  });

  test('🔴 입출금 = 그날 앞 합 · 그날 합(입금 + · 출금 −)', () {
    flow('f1', '2026-11-02', 1000000);
    flow('f2', '2026-11-13', 50000);
    flow('f3', '2026-11-16', 100000);
    flow('f4', '2026-11-16', -30000);
    flow('f5', '2026-11-17', 7);
    final LimitLedgerFacts f = SqliteLimitLedgerFacts(db)
        .factsFor(const TradeDate('2026-11-16'));
    expect(f.flowsBefore, 1050000);
    expect(f.flowsToday, 70000);
  });
}
