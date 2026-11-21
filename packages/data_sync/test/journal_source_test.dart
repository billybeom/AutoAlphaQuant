// 🆕 E11q-q4a — M6 매매일지 «읽기» 원천: 원장 원문(의도 · 브로커 주문 · 체결 · 결정 · 저널 · 회차 · 계획 대상 · 차단) →
// 엔진 VM.
//
// 🔴 셈은 엔진 — 여기는 모으기만 한다: 원장 실수 → 글자 · 회차 묶음 = 계획 스냅샷 대상(재개 child 포함) · 계절 POT 청산 ·
//    가림 = 서 있는 차단 · 원장 한 파일 = 그 파일의 행 전부 · S7-6b 의도 묶음 = 같은 셈.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show JournalEventFact, Market, P0sStrategyIds, frozenExchangeCalendar;
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

final DateTime _t0 = DateTime.utc(2026, 8, 31, 9); // 18:00 KST

const DateRange _all = DateRange(
  from: TradeDate('2026-01-02'),
  to: TradeDate('2026-08-31'),
);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  int seq = 0;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('q4a_');
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
    seq = 0;
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteJournalSource src({bool Function(String)? hasBody}) =>
      SqliteJournalSource(
        db,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
        runMode: RunMode.simInternal,
        accountLabels: const <String, String>{'pension': '연금저축'},
        hasBody: hasBody ?? (String _) => true,
      );

  void intent(
    String id,
    String decision, {
    String strategy = P0sStrategyIds.sleeveB,
    String symbol = '133690',
    String trade = '2026-08-03',
    String status = 'FILLED',
    int qty = 10,
    double? limit = 20000,
    String created = '2026-08-03T00:10:00.000Z',
    String? error,
  }) {
    seq++;
    db.execute(
      'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
      'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
      "updated_at, mode, error_message) VALUES (?, ?, ?, ?, 'KR', 'pension', ?, ?, ?, 'BUY', 'LIMIT', ?, ?, ?, "
      "'cfg', ?, 'SIM_INTERNAL', ?)",
      <Object?>[
        id,
        'k$seq',
        created,
        trade,
        strategy,
        decision,
        symbol,
        qty,
        limit,
        status,
        created,
        error,
      ],
    );
  }

  void order(
    String no,
    String intentId, {
    String at = '2026-08-03T00:20:00.000Z',
  }) => db.execute(
    'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status) '
    "VALUES (?, ?, ?, 'SUBMITTED')",
    <Object?>[no, intentId, at],
  );

  void fill(
    String id,
    String order,
    int qty,
    double price, {
    double commission = 0,
    String at = '2026-08-03T01:00:00.000Z',
  }) => db.execute(
    'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, commission, tax, '
    "authored_at, fill_origin, cost_source) VALUES (?, ?, ?, ?, ?, ?, 0, ?, 'SIMULATED', 'ESTIMATED')",
    <Object?>[id, order, at, qty, price, commission, at],
  );

  void decision(
    String id, {
    String? journal,
    String code = 'MONTHLY_REGULAR',
  }) => db.execute(
    'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
    "reason_code, config_hash, journal_id) VALUES (?, '2026-07-31T09:00:00.000Z', '2026-07-31', "
    "'SIM_INTERNAL', 'REBALANCE', 'P0S', '월말 정기 리밸런싱 — 대상 2건', ?, 'cfg', ?)",
    <Object?>[id, code, journal],
  );

  void plan(String planId, List<String> logical) => db.execute(
    'INSERT INTO plan_snapshot (plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, '
    "config_hash) VALUES (?, 'REBALANCE', '2026-07-31T09:00:00.000Z', '2026-07-31', '2026-08-31', '{}', ?, 'cfg')",
    <Object?>[
      planId,
      jsonEncode(<String, Object?>{
        'targets': <Object?>[
          for (final String l in logical)
            <String, Object?>{'logical_decision_id': l},
        ],
      }),
    ],
  );

  void event(
    String id,
    String day,
    String kind,
    String decisionId, {
    Map<String, Object?> trigger = const <String, Object?>{},
  }) => db.execute(
    'INSERT INTO rebalance_event (event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
    "weights_before, weights_after, config_hash, created_at) VALUES (?, ?, 'SIM_INTERNAL', ?, ?, ?, '[]', '[]', "
    "'cfg', '2026-07-31T09:00:00.000Z')",
    <Object?>[id, day, kind, decisionId, jsonEncode(trigger)],
  );

  void seedMonthly() {
    decision('MONTH-END-2026-07-31');
    plan('REBAL-2026-07-31', <String>[
      'B-SMA-2026-07-31',
      'C-REBAL-2026-07-31',
    ]);
    plan('REBAL-2026-07-31#RESUME-2026-08-05', <String>[
      'B-SMA-2026-07-31#R2026-08-05',
    ]);
    event(
      'REB-MONTHLY-2026-07-31',
      '2026-07-31',
      'MONTHLY_REGULAR',
      'MONTH-END-2026-07-31',
    );
    intent('iB', 'B-SMA-2026-07-31@2026-08-03', qty: 10);
    order('2026-08-03:0001', 'iB');
    fill('2026-08-03:0001#4', '2026-08-03:0001', 4, 20000.0, commission: 2.6);
    fill(
      '2026-08-03:0001#10',
      '2026-08-03:0001',
      6,
      20100.0,
      commission: 3.0,
      at: '2026-08-03T02:00:00.000Z',
    );
    intent(
      'iC',
      'C-REBAL-2026-07-31@2026-08-03',
      strategy: P0sStrategyIds.sleeveC,
      symbol: '0085P0',
      status: 'REJECTED',
      error: 'KILL_SWITCH',
      created: '2026-08-03T00:11:00.000Z',
    );
    intent(
      'iR',
      'B-SMA-2026-07-31#R2026-08-05@2026-08-05',
      trade: '2026-08-05',
      status: 'UNKNOWN',
      created: '2026-08-05T00:10:00.000Z',
    );
    order('2026-08-05:0002', 'iR', at: '2026-08-05T00:20:00.000Z');
    intent(
      'iX',
      'DEP-p1@2026-08-04',
      trade: '2026-08-04',
      created: '2026-08-04T00:10:00.000Z',
      limit: null,
      status: 'SUBMITTED',
    );
  }

  test('원장 원문 → 일지 행(시간 역순 · 체결 합 · 실수 → 글자 · 회차 묶음 = 계획 대상 · 재개 child)', () {
    seedMonthly();
    final ListResult<TradeJournalEntry> r = src().timeline(range: _all);
    expect(
      <String>[for (final TradeJournalEntry e in r.rows) e.entryId],
      <String>['iR', 'iX', 'iC', 'iB'],
    );
    final TradeJournalEntry b = r.rows.last;
    expect(
      (b.quantityText, b.priceText, b.commissionText, b.statusLabel),
      ('10주', '20,060원', '6원', '체결'),
    );
    expect(
      (b.fillOrigin, b.originLabel, b.costSourceLabel),
      (FillOrigin.simulated, '모의 체결', '추정치'),
    );
    expect(
      (b.mode, b.accountAlias, b.symbolLabel),
      (RunMode.simInternal, '연금저축', '133690 TIGER 미국나스닥100'),
    );
    expect(b.decision.executionId, '2026-08-03:0001#10');
    expect(b.reasons.single.label, '월간 정기 리밸런싱');
    expect(
      <String?>[for (final TradeJournalEntry e in r.rows) e.rebalanceEventId],
      <String?>[
        'REB-MONTHLY-2026-07-31',
        null,
        'REB-MONTHLY-2026-07-31',
        'REB-MONTHLY-2026-07-31',
      ],
    );
    expect(r.rows[1].statusLabel, '접수 — 체결 대기');
    expect(r.rows[1].priceText, '시장가');
    expect(r.rows[2].reasons.single.code, 'KILL_SWITCH');
    // 🔴 원장 한 파일 = 그 파일의 행 전부 — 모드로 거르지 않는다.
    expect(
      r.rows.every((TradeJournalEntry e) => e.mode == RunMode.simInternal),
      true,
    );
  });

  test('S7-6b 묶음 = 같은 셈(회차 → 의도 id · 원장 순) · 리밸런싱 원천의 회차 VM 에 실린다', () {
    seedMonthly();
    expect(src().intentIdsByEvent(), <String, List<String>>{
      'REB-MONTHLY-2026-07-31': <String>['iB', 'iC', 'iR'],
    });
    final RebalanceEvent ev = SqliteRebalanceSource(
      db,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
      us: frozenExchangeCalendar(Market.us),
      holdings: SqliteHoldingsOverviewSource(
        db,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
        runMode: RunMode.simInternal,
        accountLabels: const <String, String>{},
        hasBody: (String _) => true,
      ),
      activeFlags: () => const <BlockFlag>[],
      hasBody: (String _) => true,
    ).events().rows.single;
    expect(ev.orderIntentIds, <String>['iB', 'iC', 'iR']);
    expect(
      ev.journalTimelineLink,
      const LinkAction(
        label: '이 회차의 주문 3건',
        deepLink: 'aaq://journal/rebalance/REB-MONTHLY-2026-07-31',
      ),
    );
    expect(
      SqliteRebalanceSource.watchedTables.containsAll(<String>[
        'order_intents',
        'plan_snapshot',
      ]),
      true,
    );
  });

  test('J-2 = 결정의 체결 전부(시간 순 · 체결 1 = 행 1) · 범위 · J-3R · 기간 프리셋 · 배지', () {
    seedMonthly();
    db.execute(
      'INSERT INTO decision_journal (journal_id, trade_date, strategy_id, signal_value, action_taken, '
      "is_deviation, rationale_before, expected_outcome, rule_cited, note, created_at) VALUES ('J1', "
      "'2026-08-03', 'P0S', '{}', '{}', 1, '근거', '기대', '재량 예산', NULL, '2026-08-03T00:05:00.000Z')",
    );
    decision('B-SMA-2026-07-31', journal: 'J1');
    final DecisionDetailVm d = src().decisionDetail(
      'B-SMA-2026-07-31@2026-08-03',
    );
    expect(
      <(String, String)>[
        for (final TradeJournalEntry e in d.fills) (e.entryId, e.quantityText),
      ],
      <(String, String)>[
        ('2026-08-03:0001#4', '4주'),
        ('2026-08-03:0001#10', '6주'),
      ],
    );
    expect(d.steps[2].detailLines, <String>['주문번호 0001']);
    expect(d.steps[3].detailLines, <String>['2회에 걸쳐 10주 체결']);
    expect(
      d.journalLink!.deepLink,
      'aaq://journal/read/B-SMA-2026-07-31@2026-08-03',
    );
    final DecisionJournalVm j = src().decisionJournal(
      'B-SMA-2026-07-31@2026-08-03',
    );
    expect(
      (j.journalStateLabel, j.body!.writtenAtText, j.body!.note),
      ('저널 작성됨', '2026-08-03 09:05 작성', null),
    );
    expect(() => src().decisionDetail('none'), throwsA(isA<StateError>()));
    final JournalRebalanceScope s = src().rebalanceScope(
      'REB-MONTHLY-2026-07-31',
    )!;
    expect(
      (s.label, s.range.from, s.range.to),
      (
        '2026-07-31 월간 정기 회차',
        const TradeDate('2026-08-03'),
        const TradeDate('2026-08-05'),
      ),
    );
    expect(src().rebalanceScope('none'), isNull);
    final List<DateRange> p = src().rangePresets();
    expect(
      (p.last.presetCode, p.last.from),
      ('ALL', const TradeDate('2026-08-03')),
    );
    expect(src().badges().single.label, '확인 중 1건');
    // 🆕 q4b — J-5 미해소 보드 = 같은 사실(UNKNOWN 의도 iR · 발생 = 첫 브로커 주문 전송 · 오래됨 = 강조).
    final UnknownBoardVm board = src().unknownBoard();
    expect(board.items.single.entry.entryId, 'iR');
    expect(board.items.single.elapsedText, startsWith('발생 08-05 09:20 · '));
    expect(board.items.single.emphasized, true);
    expect(
      src().filterCatalog().originOptions.single.origin,
      FillOrigin.simulated,
    );
    expect(src().sleeves().length, 4);
  });

  test('계절 회차 = 판정 결정 + POT 청산(판정이 청산을 말할 때만)', () {
    event(
      'SEAS-2026-10-30',
      '2026-10-30',
      'SEASONAL',
      'SEAS-A-IN-2026-10-30',
      trigger: <String, Object?>{'anchor': '2026-10-30', 'liquidate_pot': true},
    );
    intent(
      'iA',
      'SEAS-A-IN-2026-10-30@2026-11-02',
      strategy: P0sStrategyIds.sleeveA,
      symbol: '229200',
      trade: '2026-11-02',
    );
    intent(
      'iP',
      'POT-LIQ-2026-10-30@2026-11-02',
      strategy: P0sStrategyIds.pot,
      symbol: '214980',
      trade: '2026-11-02',
    );
    expect(src().intentIdsByEvent(), <String, List<String>>{
      'SEAS-2026-10-30': <String>['iA', 'iP'],
    });
    final List<JournalEventFact> ev = journalEventFactsOf(db);
    expect(ev.single.logicalIds, <String>{
      'SEAS-A-IN-2026-10-30',
      'POT-LIQ-2026-10-30',
    });
  });

  test('가림 = 서 있는 차단(LEDGER_INTEGRITY «숨김» · 풀리면 원래 글자)', () {
    seedMonthly();
    db.execute(
      "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('LEDGER_INTEGRITY', '2026-08-31T00:00:00.000Z', 'x')",
    );
    TradeJournalEntry b() => src().timeline(range: _all).rows.last;
    expect((b().quantityText, b().priceText), ('숨김', '숨김'));
    db.execute(
      "UPDATE trading_block SET cleared_at = '2026-08-31T01:00:00.000Z' WHERE flag_id = 'LEDGER_INTEGRITY'",
    );
    expect((b().quantityText, b().priceText), ('10주', '20,060원'));
  });

  test(
    '🆕 E11q-q6 — L-3 실사 세션(그 폰)이 열린 동안 = «숨김» · 닫히면 원래 글자 · 판정 함수 없음 = 가림 0',
    () {
      seedMonthly();
      bool open = true;
      final SqliteJournalSource masked = SqliteJournalSource(
        db,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
        runMode: RunMode.simInternal,
        accountLabels: const <String, String>{'pension': '연금저축'},
        hasBody: (String _) => true,
        selfReportSessionOpen: () => open,
      );
      TradeJournalEntry b() => masked.timeline(range: _all).rows.last;
      expect((b().quantityText, b().priceText), ('숨김', '숨김'));
      open = false;
      expect((b().quantityText, b().priceText), ('10주', '20,060원'));
      open = true;
      expect(
        (
          src().timeline(range: _all).rows.last.quantityText,
          src().timeline(range: _all).rows.last.priceText,
        ),
        ('10주', '20,060원'),
      );
    },
  );

  test('빈 원장 = 엔진 빈 문장 · 프리셋 전체 = 끝 날', () {
    final ListResult<TradeJournalEntry> r = src().timeline(range: _all);
    expect(r.rows, isEmpty);
    expect(r.emptyLabel, startsWith('아직 기록된 거래가 없습니다'));
    expect(src().rangePresets().last.from, const TradeDate('2026-08-31'));
    expect(src().badges(), isEmpty);
    expect(src().unknownBoard().emptyLabel, '미해소 건이 없습니다');
  });
}
