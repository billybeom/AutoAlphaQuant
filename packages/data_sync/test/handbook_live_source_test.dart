// 🆕 E11q-d1b — M8 핸드북 «현재 상태»(금 상한) 원천(설계 13 §8 R236) — 실 SQLite 원장.
//
// 🔴 가장 최근 평가 행의 날 · 그날 보유(지금 보유 − 그 뒤 체결) · 그날 종가 · 그 행 현금 → SAF-308 셈(일간 잡과 같은 규칙) ·
//    원천 없음(평가 행 · 설정 · 종가) = 빈 맵(블록 부재 — 지어내지 않는다) · 경고만(주문 무차단 — 문장).

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 23, 0, 30); // 한국 11-23 09:30

void main() {
  late Directory dir;
  late Database db;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('r236_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  final P0sExposureMap map = p0sExposureMap();
  final String gold = map.goldSymbols.single;
  const String bond = '0085P0';

  void snap(String day, double cash) => db.execute(
    'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
    "VALUES (?, ?, ?, 0, ?, 0, 'LIVE')",
    <Object?>[day, cash, cash, cash],
  );

  void position(String strategy, String symbol, int qty) => db.execute(
    'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
    "VALUES ('KR', ?, ?, ?, 1, '2026-11-02', ?)",
    <Object?>[symbol, strategy, qty, _t0.toIso8601String()],
  );

  void bar(String symbol, String day, double close) => db.execute(
    'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
    "VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 0)",
    <Object?>[day, symbol, close, close, close, close, close],
  );

  void buyFill(String id, String day, String symbol, int qty) {
    db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      'decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES '
      "(?, ?, 'x', ?, 'KR', 'general', 'P0S_C', ?, ?, 'BUY', 'LIMIT', ?, 'FILLED', 'c', 'x', 'LIVE')",
      <Object?>['i$id', 'k$id', day, 'D-$id', symbol, qty],
    );
    db.execute(
      'INSERT INTO broker_orders(broker_order_no, intent_id, submitted_at, status) '
      "VALUES (?, ?, 'x', 'FILLED')",
      <Object?>['b$id', 'i$id'],
    );
    db.execute(
      'INSERT INTO executions(execution_id, broker_order_no, executed_at, quantity, price, commission, tax) '
      "VALUES (?, ?, '2026-11-23T01:00:00Z', ?, 15000, 0, 0)",
      <Object?>['e$id', 'b$id', qty],
    );
  }

  Map<String, HandbookLiveReading> live({P0sWarnSetup? setup}) =>
      ledgerHandbookLiveOf(db, mode: RunMode.live, setup: setup, nowUtc: _t0);

  /// 11-20 종가 기준: 현금 250,000 · 금 10 × 15,000 · 채권 40 × 15,000 = 총 1,000,000 → 금 15%.
  void seed({double goldClose = 15000}) {
    snap('2026-11-20', 250000);
    position('P0S_C', gold, 10);
    position('P0S_C', bond, 40);
    bar(gold, '2026-11-20', goldClose);
    bar(bond, '2026-11-20', 15000);
  }

  test('🔴 원천 없음 = 빈 맵(평가 행 없음 · 설정 못 읽음) — 블록 부재', () {
    expect(live(setup: P0sWarnSetup()), isEmpty);
    seed();
    expect(live(), isEmpty);
  });

  test('🔴 감시선 안쪽 = OK 문장 · 기준 = 마지막 평가 행의 날(종가)', () {
    seed();
    snap('2026-11-19', 250000); // 앞 날 행은 고르지 않는다
    final HandbookLiveReading r = live(
      setup: P0sWarnSetup(),
    )[HandbookLiveKeys.goldCap]!;
    expect(
      r.value,
      const HandbookLiveValue(
        label: '금 비중 15% — 감시선 20% 안쪽입니다.',
        level: UiLevel.ok,
      ),
    );
    expect(r.asOf.tradeDate, const TradeDate('2026-11-20'));
    expect(r.asOf.label, '현재 상태 기준 2026-11-20 종가');
    expect(r.asOf.observedAt, _t0);
  });

  test('🔴 감시선 넘음 = WATCH · 경고만(주문은 막지 않는다는 문장) · 일간 판정과 같은 경계', () {
    seed(goldClose: 30000); // 금 300,000 ÷ 1,150,000
    final HandbookLiveReading r = live(
      setup: P0sWarnSetup(),
    )[HandbookLiveKeys.goldCap]!;
    expect(
      r.value,
      const HandbookLiveValue(
        label: '금 비중 26.1% — 감시선 20%를 넘었습니다. 알림만 하고 주문은 막지 않습니다.',
        level: UiLevel.watch,
      ),
    );
  });

  test('🔴 그날 보유 = 지금 보유 − 그 뒤 집행일 체결(일간 잡 · 월 집계와 같은 길)', () {
    seed();
    // 11-23 에 금 10 을 더 샀다 — 지금 원장 보유 20 · 11-20 보유는 10.
    buyFill('1', '2026-11-23', gold, 10);
    db.execute(
      "UPDATE positions SET quantity = 20 WHERE symbol = ? AND strategy_id = 'P0S_C'",
      <Object?>[gold],
    );
    expect(
      live(setup: P0sWarnSetup())[HandbookLiveKeys.goldCap]!.value.label,
      '금 비중 15% — 감시선 20% 안쪽입니다.',
    );
  });

  test('🔴 셈할 수 없으면(보유 종목의 그날 종가 없음) = 빈 맵(지어내지 않는다)', () {
    snap('2026-11-20', 250000);
    position('P0S_C', gold, 10);
    bar(gold, '2026-11-19', 15000); // 다른 날 종가뿐
    expect(live(setup: P0sWarnSetup()), isEmpty);
  });

  test('보는 표 = 평가 · 보유 · 종가 · 체결 재생 표', () {
    expect(
      kHandbookLiveWatchedTables,
      containsAll(<String>[
        'equity_snapshot',
        'positions',
        'daily_prices',
        'executions',
        'broker_orders',
        'order_intents',
      ]),
    );
  });
}
