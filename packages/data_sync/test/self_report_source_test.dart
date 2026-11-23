// E11q-q6 — `L-3` 정기 실사 원장 원천(01 §21-4 · 02 §3-10) — 실 SQLite(live 원장).
//
// 🔴 기준일 원장 수량 = 그 계좌 전략의 지금 포지션 − 기준일 뒤 브로커 체결 · 기록 = 한 트랜잭션(실사 · 줄 · 차이 · 접수) ·
//    같은 기준일 · 계좌 두 번째 = 쓰기 0 · 무결성 점검 중 = 보관 행 하나 · 원장 해시가 실사 표를 그대로 묶는다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 9, 2, 3);

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

const CommandContext _ctx = CommandContext(
  runMode: RunMode.live,
  operatingMode: OperatingMode.advisory,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

SelfReportBalance _wire({
  String alias = '연금저축',
  String asOf = '2026-08-31',
  Map<String, int> lines = const <String, int>{'133690': 242, '069500': 10},
}) => SelfReportBalance(
  asOfTradeDate: TradeDate(asOf),
  purpose: SelfReportPurpose.periodicAudit,
  sessionStartedAt: DateTime.utc(2026, 9, 2, 2),
  lines: <SelfReportLine>[
    for (final MapEntry<String, int> e in lines.entries)
      SelfReportLine(symbol: e.key, symbolLabel: e.key, quantity: e.value),
  ],
  cashKrw: Decimal.fromInt(1250000),
  accountAlias: alias,
  declaredComplete: true,
  context: _ctx,
);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  int seq = 0;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11q_q6_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    clock = _Clock(_t0);
    seq = 0;
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteSelfReportSource src() => SqliteSelfReportSource(db, clock: clock);

  void position(String strategy, String symbol, int qty) => db.execute(
    'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
    "VALUES ('KR', ?, ?, ?, 1000, '2026-08-03', '2026-08-03T00:00:00Z')",
    <Object?>[symbol, strategy, qty],
  );

  /// 브로커 체결 1건(의도 · 주문 · 체결 — 매수 + · 매도 −).
  void fill(String day, String strategy, String symbol, int qty) {
    seq++;
    final String id = 't$seq';
    final String no = '$day:t$seq';
    db.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode) VALUES (?, ?, '2026-01-01T00:00:00Z', ?, 'KR', 'main', ?, ?, ?, ?, 'LIMIT', ?, 1, "
      "'FILLED', 'cfg', '2026-01-01T00:00:00Z', 'LIVE')",
      <Object?>[
        id,
        'tk$seq',
        day,
        strategy,
        'td$seq@$day',
        symbol,
        qty < 0 ? 'SELL' : 'BUY',
        qty.abs(),
      ],
    );
    db.execute(
      'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
      "VALUES (?, ?, '2026-01-01T00:00:00Z', 'FILLED')",
      <Object?>[no, id],
    );
    db.execute(
      'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price) '
      "VALUES (?, ?, '2026-01-01T01:00:00Z', ?, 1)",
      <Object?>['$no#x', no, qty.abs()],
    );
  }

  int count(String sql, [List<Object?> args = const <Object?>[]]) =>
      db.select(sql, args).first.columnAt(0) as int;

  void recordDefault({
    String alias = '연금저축',
    List<SelfReportDiffRow> diffs = const <SelfReportDiffRow>[],
    String commandId = 'cmd-1',
    Map<String, int>? lines,
  }) => src().record(
    wire: lines == null
        ? _wire(alias: alias)
        : _wire(alias: alias, lines: lines),
    commandId: commandId,
    deviceId: 'dev-1',
    reportedAtUtc: _t0,
    diffs: diffs,
    stateLabel: SelfReportTexts.executed,
    runMode: RunMode.live,
    operatingMode: OperatingMode.advisory,
    leaseEpoch: 0,
  );

  test(
    '🔴 기준일 원장 수량 = 그 계좌 전략의 지금 포지션 − 기준일 뒤 체결(다른 계좌 · 0 · 기준일 당일 체결 = 그대로)',
    () {
      position(P0sStrategyIds.sleeveB, '133690', 250);
      position(P0sStrategyIds.pot, '069500', 10);
      position(P0sStrategyIds.sleeveA, '069500', 7);
      position(P0sStrategyIds.sleeveB, '411060', 0);
      fill(
        '2026-08-31',
        P0sStrategyIds.sleeveB,
        '133690',
        40,
      ); // 기준일 당일 = 기준일 보유에 든다
      fill('2026-09-01', P0sStrategyIds.sleeveB, '133690', 8);
      fill('2026-09-02', P0sStrategyIds.sleeveB, '133690', -3);
      fill('2026-09-01', P0sStrategyIds.sleeveA, '069500', 7); // 다른 계좌
      fill('2026-09-01', P0sStrategyIds.pot, '411060', 2); // 기준일 뒤에 처음 산 종목
      final List<String> mine = <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.pot,
      ];
      expect(
        src().ledgerQuantities(const TradeDate('2026-08-31'), mine),
        <String, int>{'133690': 245, '069500': 10, '411060': -2},
      );
      expect(
        src().ledgerQuantities(const TradeDate('2026-09-02'), mine),
        <String, int>{'133690': 250, '069500': 10},
      );
      expect(src().heldSleeves(mine), <String, SleeveId>{
        '133690': SleeveId.b,
        '069500': SleeveId.pot,
      });
      expect(
        src().ledgerQuantities(const TradeDate('2026-08-31'), const <String>[]),
        isEmpty,
      );
    },
  );

  test('🔴 기록 = 한 트랜잭션(실사 1 · 줄 n · 차이 · 접수 EXECUTED) → 이 달 실사 계좌 · 마지막 기준일 · 차이 읽기', () {
    expect(src().auditedAccounts(const TradeDate('2026-08-31')), isEmpty);
    expect(src().lastVerifiedOn('연금저축'), isNull);
    final List<SelfReportDiffRow> diffs = selfReportDiffRowsOf(
      asOf: const TradeDate('2026-08-31'),
      alias: '연금저축',
      diffs: const <SelfReportQuantityDiff>[
        SelfReportQuantityDiff(symbol: '133690', ledger: 245, reported: 242),
      ],
    );
    recordDefault(diffs: diffs);
    expect(count('SELECT COUNT(*) FROM self_report_balance'), 1);
    expect(
      db.select('SELECT * FROM self_report_balance').single.values,
      <Object?>[
        'sr_cmd-1',
        '2026-08-31',
        '연금저축',
        '2026-09-02T02:00:00.000Z',
        1250000.0,
        1,
        'dev-1',
        'cmd-1',
        '2026-09-02T03:00:00.000Z',
      ],
    );
    expect(
      <(String, int)>[
        for (final Row r in db.select(
          'SELECT symbol, quantity FROM self_report_line ORDER BY symbol',
        ))
          (r['symbol'] as String, r['quantity'] as int),
      ],
      <(String, int)>[('069500', 10), ('133690', 242)],
    );
    final Row inbox = db.select('SELECT * FROM command_inbox').single;
    expect(inbox['kind'], 'SELF_REPORT_BALANCE');
    expect(inbox['state'], 'EXECUTED');
    expect(inbox['state_label'], SelfReportTexts.executed);
    expect(inbox['run_mode'], 'LIVE');
    expect(inbox['operating_mode'], 'ADVISORY');
    expect(inbox['payload_digest'], selfReportPayloadDigestOf(_wire()));
    expect(src().auditedAccounts(const TradeDate('2026-08-31')), <String>{
      '연금저축',
    });
    expect(src().lastVerifiedOn('연금저축'), const TradeDate('2026-08-31'));
    final List<StoredLedgerDiff> got = src().diffsOf(
      const TradeDate('2026-08-31'),
      '연금저축',
    );
    expect(got.single.diffId, diffs.single.diffId);
    expect(got.single.pair, LedgerPair.canonSelfReport);
    expect(got.single.axis, LedgerAxis.quantity);
    expect(got.single.severity, DiffSeverity.observational);
    expect(got.single.status, DiffStatus.open);
    expect(got.single.deltaLabel, '133690 수량 −3주 (원장 245 / 자가 보고 242)');
    expect(got.single.detectedAtUtc, _t0);
    expect(src().diffsOf(const TradeDate('2026-08-31'), '일반'), isEmpty);
    expect(src().diffsOf(const TradeDate('2026-07-31'), '연금저축'), isEmpty);
    // L-1 이 같은 행을 읽는다(같은 원장 · 같은 사전).
    expect(
      storedLedgerDiffs(db).map((StoredLedgerDiff d) => d.diffId),
      <String>[diffs.single.diffId],
    );
  });

  test('🔴 같은 기준일 · 계좌 두 번째 = StateError · 쓰기 0(되돌림) · 다른 계좌 = 받는다', () {
    recordDefault();
    final List<SelfReportDiffRow> diffs = selfReportDiffRowsOf(
      asOf: const TradeDate('2026-08-31'),
      alias: '연금저축',
      diffs: const <SelfReportQuantityDiff>[
        SelfReportQuantityDiff(symbol: '069500', ledger: 1, reported: 10),
      ],
    );
    expect(
      () => recordDefault(diffs: diffs, commandId: 'cmd-2'),
      throwsStateError,
    );
    expect(count('SELECT COUNT(*) FROM self_report_balance'), 1);
    expect(count('SELECT COUNT(*) FROM self_report_line'), 2);
    expect(count('SELECT COUNT(*) FROM ledger_diff'), 0);
    expect(count('SELECT COUNT(*) FROM command_inbox'), 1);
    recordDefault(alias: '일반', commandId: 'cmd-3');
    expect(src().auditedAccounts(const TradeDate('2026-08-31')), <String>{
      '연금저축',
      '일반',
    });
  });

  test('🔴 차이 쓰기가 실패하면 실사 · 줄 · 접수도 없다(한 트랜잭션)', () {
    final SelfReportDiffRow d = selfReportDiffRowsOf(
      asOf: const TradeDate('2026-08-31'),
      alias: '연금저축',
      diffs: const <SelfReportQuantityDiff>[
        SelfReportQuantityDiff(symbol: '133690', ledger: 245, reported: 242),
      ],
    ).single;
    expect(
      () => recordDefault(diffs: <SelfReportDiffRow>[d, d]),
      throwsA(isA<SqliteException>()),
    );
    for (final String t in <String>[
      'self_report_balance',
      'self_report_line',
      'ledger_diff',
      'command_inbox',
    ]) {
      expect(count('SELECT COUNT(*) FROM $t'), 0, reason: t);
    }
  });

  test('🔴 무결성 점검 중 = 보관 행 하나(원장 쓰기 0) · 판정 = 서 있는 LEDGER_INTEGRITY', () {
    expect(src().integrityBroken(), isFalse);
    db.execute(
      "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-09-01T00:00:00Z', 'x')",
    );
    expect(src().integrityBroken(), isTrue);
    src().hold(
      wire: _wire(),
      commandId: 'cmd-h',
      stateLabel: SelfReportTexts.held,
      runMode: RunMode.live,
      operatingMode: OperatingMode.advisory,
      leaseEpoch: 4,
    );
    final Row inbox = db.select('SELECT * FROM command_inbox').single;
    expect(inbox['state'], 'HELD_FOR_INTEGRITY');
    expect(inbox['state_label'], SelfReportTexts.held);
    expect(inbox['lease_epoch'], 4);
    expect(count('SELECT COUNT(*) FROM self_report_balance'), 0);
    db.execute(
      "UPDATE trading_block SET cleared_at = '2026-09-01T01:00:00Z' WHERE flag_id = 'LEDGER_INTEGRITY'",
    );
    expect(src().integrityBroken(), isFalse);
  });

  test('원장 해시가 실사 표를 묶는다(보고 날 스탬프에 실사 · 줄 행이 센다)', () {
    recordDefault();
    clock.now = DateTime.utc(2026, 9, 4, 3);
    final LedgerDayStamp day = LedgerHashStamper(db, clock: clock)
        .stampThrough('2026-09-02')
        .singleWhere((LedgerDayStamp s) => s.authoredDate == '2026-09-02');
    final Map<String, dynamic> counts =
        jsonDecode(day.rowCounts) as Map<String, dynamic>;
    expect(counts['self_report_balance'], 1);
    expect(counts['self_report_line'], 2);
  });
}
