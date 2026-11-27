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
    SelfReportCashCheck cashCheck = SelfReportCashCheck.noTolerance,
    double? cashToleranceKrw,
  }) => src().record(
    wire: lines == null
        ? _wire(alias: alias)
        : _wire(alias: alias, lines: lines),
    commandId: commandId,
    deviceId: 'dev-1',
    reportedAtUtc: _t0,
    diffs: diffs,
    cashCheck: cashCheck,
    cashToleranceKrw: cashToleranceKrw,
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
        'NO_TOLERANCE',
        null,
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

  group('🆕 R278 현금 축 원천(01 §8 미결 227 · §46 K323 ①)', () {
    const TradeDate asOf = TradeDate('2026-08-31');
    int n = 0;

    void flow(String day, double amount, String? alias, {String cur = 'KRW'}) {
      n++;
      db.execute(
        'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, account_alias) '
        "VALUES (?, ?, ?, ?, 'DEPOSIT', ?)",
        <Object?>['cf$n', day, amount, cur, alias],
      );
    }

    /// 브로커 체결 1건(그 계좌 · 시장 · 가격 · 비용) → 체결 id.
    String cashFill(
      String day,
      String account,
      String side,
      int qty,
      double price, {
      double commission = 0,
      double tax = 0,
      String market = 'KR',
    }) {
      n++;
      final String id = 'c$n';
      final String no = '$day:c$n';
      db.execute(
        'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
        'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
        "updated_at, mode) VALUES (?, ?, '2026-01-01T00:00:00Z', ?, ?, ?, 'P0S_B', ?, '133690', ?, 'LIMIT', ?, 1, "
        "'FILLED', 'cfg', '2026-01-01T00:00:00Z', 'LIVE')",
        <Object?>[id, 'ck$n', day, market, account, 'cd$n@$day', side, qty],
      );
      db.execute(
        'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
        "VALUES (?, ?, '2026-01-01T00:00:00Z', 'FILLED')",
        <Object?>[no, id],
      );
      db.execute(
        'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax) '
        "VALUES (?, ?, '2026-01-01T01:00:00Z', ?, ?, ?, ?)",
        <Object?>['$no#x', no, qty, price, commission, tax],
      );
      return '$no#x';
    }

    void reverse(String fillId) => db.execute(
      'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax, '
      'fill_kind, reverses_fill_id) SELECT ?, broker_order_no, executed_at, quantity, price, commission, tax, '
      "'REVERSAL', execution_id FROM executions WHERE execution_id = ?",
      <Object?>['$fillId~r', fillId],
    );

    void manual(String id, String executedAtUtc, {String? reverses}) =>
        db.execute(
          'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, fill_origin, '
          "fill_kind, reverses_fill_id) VALUES (?, NULL, ?, 1, 100, 'MANUAL', ?, ?)",
          <Object?>[
            id,
            executedAtUtc,
            reverses == null ? 'ORIGINAL' : 'REVERSAL',
            reverses,
          ],
        );

    test('🔴 그 계좌 원화 현금 흐름(≤ 기준일) + 그 계좌 KR 브로커 체결 대금(집행일 ≤ 기준일 · 되돌림 음수) = 원장 현금 · 다른 계좌 · 뒤 · 외화 · 미국 = 빠짐', () {
      flow('2026-08-01', 1000000, '연금저축');
      flow('2026-08-31', -50000, '연금저축'); // 기준일 당일 = 든다
      flow('2026-09-01', 999, '연금저축'); // 기준일 뒤
      flow('2026-08-01', 7777, '일반'); // 다른 계좌
      flow('2026-08-02', 100, '연금저축', cur: 'USD'); // 원화 아님
      final String buy = cashFill(
        '2026-08-20',
        '연금저축',
        'BUY',
        10,
        1000,
        commission: 15,
      );
      cashFill('2026-08-31', '연금저축', 'SELL', 4, 1500, commission: 10, tax: 12);
      reverse(buy); // 매수 되돌림 = +10,015
      cashFill('2026-09-01', '연금저축', 'BUY', 1, 5000); // 기준일 뒤
      cashFill('2026-08-20', '일반', 'BUY', 3, 100); // 다른 계좌
      cashFill('2026-08-20', '연금저축', 'BUY', 2, 100, market: 'US');
      final SelfReportCashFacts f = src().cashFactsOf(asOf, '연금저축');
      expect(f.unattributed, isFalse);
      expect(f.cashFlowSum, 950000);
      expect(f.executions, hasLength(3));
      expect(selfReportLedgerCashOf(f), Decimal.fromInt(955978));
      // 기준일 전날까지 = 첫 입금뿐(08-20 체결 · 08-31 출금 · 매도 빠짐).
      expect(
        selfReportLedgerCashOf(
          src().cashFactsOf(const TradeDate('2026-08-19'), '연금저축'),
        ),
        Decimal.fromInt(1000000),
      );
      expect(
        selfReportLedgerCashOf(src().cashFactsOf(asOf, '일반')),
        Decimal.fromInt(7777 - 300),
      );
      expect(
        selfReportLedgerCashOf(src().cashFactsOf(asOf, '없는계좌')),
        Decimal.zero,
      );
    });

    test(
      '🔴 모름 = 기준일까지 별칭 빈 현금 행 · 계좌 빈 의도의 체결 · 살아 있는 수기 체결(뒤 · 되돌린 쌍 = 모름 아님)',
      () {
        bool unknown() => src().cashFactsOf(asOf, '연금저축').unattributed;
        flow('2026-08-01', 1000000, '연금저축');
        expect(unknown(), isFalse);
        flow('2026-09-05', 5, null); // 기준일 뒤 = 상관없다
        expect(unknown(), isFalse);
        flow('2026-07-01', 5, null); // v1.11 전 행
        expect(unknown(), isTrue);
        expect(selfReportLedgerCashOf(src().cashFactsOf(asOf, '연금저축')), isNull);
        db.execute('DELETE FROM cash_flow WHERE account_alias IS NULL');
        flow('2026-07-01', 5, ' ');
        expect(unknown(), isTrue, reason: '빈 별칭(공백)도 모름');
        db.execute("DELETE FROM cash_flow WHERE TRIM(account_alias) = ''");
        cashFill('2026-09-01', '', 'BUY', 1, 100);
        expect(unknown(), isFalse, reason: '계좌 빈 의도라도 기준일 뒤면 상관없다');
        cashFill('2026-08-31', '', 'BUY', 1, 100);
        expect(unknown(), isTrue);
        db.execute(
          'DELETE FROM executions WHERE broker_order_no IN (SELECT b.broker_order_no FROM broker_orders b '
          "JOIN order_intents i ON i.intent_id = b.intent_id WHERE i.account = '')",
        );
        expect(unknown(), isFalse);
        // 한국 날짜 09-01 00:30 = 기준일 뒤.
        manual('m-late', '2026-08-31T15:30:00.000Z');
        expect(unknown(), isFalse);
        manual('m-1', '2026-08-30T01:00:00.000Z');
        expect(unknown(), isTrue, reason: '수기 체결 행에는 계좌 칸이 없다');
        manual('m-1r', '2026-08-30T02:00:00.000Z', reverses: 'm-1');
        expect(unknown(), isFalse, reason: '되돌린 쌍 = 사라진 사실');
      },
    );

    test(
      '🔴 표식(SELF_AUDIT_PATTERN_UNVERIFIED) = 서 있을 때만 · 감시 표 += cash_flow',
      () {
        expect(src().patternUnverifiedStanding(), isFalse);
        db.execute(
          "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('SELF_AUDIT_PATTERN_UNVERIFIED', "
          "'2026-09-01T00:00:00Z', 'x')",
        );
        expect(src().patternUnverifiedStanding(), isTrue);
        expect(src().integrityBroken(), isFalse);
        db.execute(
          "UPDATE trading_block SET cleared_at = '2026-09-01T01:00:00Z' "
          "WHERE flag_id = 'SELF_AUDIT_PATTERN_UNVERIFIED'",
        );
        expect(src().patternUnverifiedStanding(), isFalse);
        expect(SqliteSelfReportSource.watchedTables, contains('cash_flow'));
      },
    );

    test('🔴 기록 = 현금 행(CASH 축 · 관측 · 열림) 같이 · 0오차 = 실사가 있고 차이 행 0(현금 행은 대조해 넘은 때만)', () {
      final List<SelfReportDiffRow> cash = selfReportCashDiffRowsOf(
        asOf: asOf,
        alias: '연금저축',
        verdict: selfReportCashVerdictOf(
          toleranceKrw: Decimal.zero,
          ledgerKrw: Decimal.fromInt(1250500),
          reportedKrw: Decimal.fromInt(1250000),
        ),
      );
      expect(src().zeroErrorAudit(asOf, '연금저축'), isFalse, reason: '실사 없음');
      recordDefault(
        diffs: cash,
        cashCheck: SelfReportCashCheck.compared,
        cashToleranceKrw: 0,
      );
      final StoredLedgerDiff got = src().diffsOf(asOf, '연금저축').single;
      expect(got.axis, LedgerAxis.cash);
      expect(got.pair, LedgerPair.canonSelfReport);
      expect(got.severity, DiffSeverity.observational);
      expect(got.status, DiffStatus.open);
      expect(
        got.deltaLabel,
        '원화 현금이 기록과 다릅니다 (원장 1,250,500원 / 자가 보고 1,250,000원)',
      );
      expect(src().zeroErrorAudit(asOf, '연금저축'), isFalse);
      recordDefault(alias: '일반', commandId: 'cmd-2');
      expect(src().zeroErrorAudit(asOf, '일반'), isTrue, reason: '미대조 = 세지 않음');
      expect(
        src().zeroErrorAudit(const TradeDate('2026-07-31'), '일반'),
        isFalse,
      );
    });
  });

  group('🆕 R281 실사 현금 판정 원장 기록(01 §8 미결 256 · 계약 v1.42 §51)', () {
    const TradeDate asOf = TradeDate('2026-08-31');

    void raw(String id, String alias, String check, double? tol) => db.execute(
      'INSERT INTO self_report_balance (report_id, as_of_trade_date, account_alias, session_started_at, cash_krw, '
      'declared_complete, device_id, command_id, reported_at, cash_check, cash_tolerance_krw) '
      "VALUES (?, '2026-08-31', ?, '2026-09-02T02:00:00Z', 0, 1, 'dev-1', ?, '2026-09-02T03:00:00Z', ?, ?)",
      <Object?>[id, alias, 'c-$id', check, tol],
    );

    test('🔴 기록한 판정 = 그대로 읽는다(대조함 + 허용 오차 · 허용 오차 없음 · 원장 모름) · 실사 없음 = StateError', () {
      expect(() => src().cashCheckOf(asOf, '연금저축'), throwsStateError);
      recordDefault(
        cashCheck: SelfReportCashCheck.compared,
        cashToleranceKrw: 1000,
      );
      recordDefault(alias: '일반', commandId: 'cmd-2');
      recordDefault(
        alias: 'ISA',
        commandId: 'cmd-3',
        cashCheck: SelfReportCashCheck.ledgerUnknown,
      );
      expect(src().cashCheckOf(asOf, '연금저축'), SelfReportCashCheck.compared);
      expect(src().cashCheckOf(asOf, '일반'), SelfReportCashCheck.noTolerance);
      expect(src().cashCheckOf(asOf, 'ISA'), SelfReportCashCheck.ledgerUnknown);
      expect(
        <Object?>[
          for (final Row r in db.select(
            'SELECT account_alias, cash_tolerance_krw FROM self_report_balance ORDER BY account_alias',
          ))
            (r['account_alias'], r['cash_tolerance_krw']),
        ],
        <Object?>[('ISA', null), ('연금저축', 1000.0), ('일반', null)],
      );
      expect(
        () => src().cashCheckOf(const TradeDate('2026-07-31'), '연금저축'),
        throwsStateError,
      );
    });

    test('🔴 DDL 이 판정 꼴을 지킨다 — 3값 밖 · 대조함인데 허용 오차 없음 · 대조 안 함인데 허용 오차 · 음수 · 판정 없음 = 거부', () {
      expect(
        () => raw('a', 'x1', 'MAYBE', null),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => raw('b', 'x2', 'COMPARED', null),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => raw('c', 'x3', 'NO_TOLERANCE', 0),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => raw('d', 'x4', 'COMPARED', -1),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => db.execute(
          'INSERT INTO self_report_balance (report_id, as_of_trade_date, account_alias, session_started_at, cash_krw, '
          'declared_complete, device_id, command_id, reported_at) '
          "VALUES ('e', '2026-08-31', 'x5', '2026-09-02T02:00:00Z', 0, 1, 'dev-1', 'c-e', '2026-09-02T03:00:00Z')",
        ),
        throwsA(isA<SqliteException>()),
      );
      expect(count('SELECT COUNT(*) FROM self_report_balance'), 0);
      raw('f', 'x6', 'COMPARED', 0);
      raw('g', 'x7', 'LEDGER_UNKNOWN', null);
      expect(count('SELECT COUNT(*) FROM self_report_balance'), 2);
    });

    test('🔴 판정 칸은 원장 해시 투영 밖(엔진 판정) — 같은 실사 · 다른 판정 = 같은 정규 행', () {
      final LedgerHashTable t = kLedgerHashPopulationV1.singleWhere(
        (LedgerHashTable t) => t.table == 'self_report_balance',
      );
      expect(t.excluded, <String>['cash_check', 'cash_tolerance_krw']);
      expect(t.columns, isNot(contains('cash_check')));
      raw('h', 'x8', 'COMPARED', 5);
      raw('i', 'x9', 'NO_TOLERANCE', null);
      String canon(String id) {
        final Row r = db.select(
          'SELECT * FROM self_report_balance WHERE report_id = ?',
          <Object?>[id],
        ).single;
        return canonicalRow(<String, Object?>{
          for (final String c in t.columns)
            c: c == 'report_id' || c == 'account_alias' || c == 'command_id'
                ? 'same'
                : r[c],
        }, t.columns);
      }

      expect(canon('h'), canon('i'));
    });
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
