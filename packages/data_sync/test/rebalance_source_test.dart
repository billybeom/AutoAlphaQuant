// 🆕 E11q2 — 리밸런싱 회차 읽기 · What-if 상태 원천(설계 13 §8 R173): 원장 원문 → 엔진.
//
// 🔴 회차 = `rebalance_event` 그대로(월말 · 계절 A) · 월말 집행일 = 다음 KR 세션 · 기준 = 마지막 KR 봉 날.
// 🔴 미리보기 상태 = 보유 현황과 같은 장부 + 월말 잡과 같은 입력(회차 번호 · 연금 누계 · 차단 · 체결 확인 중) ·
//    개시 전 = 계산하지 않는다(실패).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        EngineWhatIfApi,
        InMemoryPlanSnapshotStore,
        Market,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        RebalanceGateTexts,
        WhatIfState,
        frozenExchangeCalendar,
        p0sKrPlanSymbols;
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
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

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'isa',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'isa',
};

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

final P0sOpsConfig _cfg = P0sOpsConfig.of(
  P0sHumanInputs(aSymbol: '229200', accountByStrategy: _accounts),
);

String _w(double a, double b, double c, double pot) => jsonEncode(<Object?>[
  <String, Object?>{'sleeve': 'A', 'weight': a},
  <String, Object?>{'sleeve': 'B', 'weight': b},
  <String, Object?>{'sleeve': 'C', 'weight': c},
  <String, Object?>{'sleeve': 'POT', 'weight': pot},
]);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late List<BlockFlag> flags;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11q2_');
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
    flags = <BlockFlag>[];
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteRebalanceSource src({bool Function(String)? hasBody}) =>
      SqliteRebalanceSource(
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
          hasBody: (String _) => false,
        ),
        activeFlags: () => flags,
        hasBody: hasBody ?? (String r) => r == AppRoutes.rebalanceEvent,
      );

  void event(
    String id,
    String day,
    String kind,
    Map<String, Object?> trigger, {
    String before = '[]',
    String after = '[]',
    String created = '2026-08-01T00:00:00Z',
  }) => db.execute(
    'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
    'weights_before, weights_after, config_hash, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      id,
      day,
      RunMode.simInternal.wire,
      kind,
      'D-$id',
      jsonEncode(trigger),
      before,
      after,
      'cfg_t',
      created,
    ],
  );

  void bar(String symbol, String day, double close) => db.execute(
    'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
    "VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 0)",
    <Object?>[day, symbol, close, close, close, close, close],
  );

  void open() {
    final String hash = SqliteConfigVersionStore(
      db,
      clock: clock,
    ).register(_cfg.content());
    final SqliteOnboardingStore s = SqliteOnboardingStore(db, clock: clock);
    expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
    expect(
      s
          .declareSimOpening(
            SelfReportBalance(
              asOfTradeDate: const TradeDate('2026-08-03'),
              purpose: SelfReportPurpose.simOpening,
              sessionStartedAt: _t0,
              lines: const <SelfReportLine>[],
              cashKrw: Decimal.parse('10000000'),
              accountAlias: 'general',
              declaredComplete: true,
              context: _ctx,
            ),
            accountByStrategy: _accounts,
            configHash: hash,
          )
          .ok,
      true,
    );
  }

  test('회차 0 = 빈 문장 · 기준 = 마지막 KR 봉 날', () {
    bar('229200', '2026-08-28', 10000);
    final ListResult<RebalanceEvent> r = src().events();
    expect(r.rows, isEmpty);
    expect(r.emptyLabel, '아직 리밸런싱 회차가 없습니다');
    expect(r.asOf.label, '자료 기준 2026-08-28');
  });

  test(
    '월말 · 계절 A 행 그대로 — 시간 역순 · 월말 집행일 = 다음 KR 세션 · 상세 = 목록과 같은 행 · 모르는 id = 실패',
    () {
      event(
        'REB-MONTHLY-2026-07-31',
        '2026-07-31',
        'MONTHLY_REGULAR',
        <String, Object?>{'targets': 3, 'sleeve_b_held': false},
        before: _w(0.18, 0.46, 0.32, 0.04),
        after: _w(0.18, 0.42, 0.36, 0.04),
        created: '2026-08-02T23:00:00Z',
      );
      event('REB-SEAS-2026-06-30', '2026-06-30', 'SEASONAL', <String, Object?>{
        'outcome': 'nothing',
      });
      final SqliteRebalanceSource s = src();
      final ListResult<RebalanceEvent> r = s.events();
      expect(r.rows.map((RebalanceEvent e) => e.eventId), <String>[
        'REB-MONTHLY-2026-07-31',
        'REB-SEAS-2026-06-30',
      ]);
      final RebalanceEvent m = r.rows.first;
      expect(m.modeLabel, '모의');
      expect(m.sectionLabel, '모의투자 회차');
      expect(
        m.trigger.summary,
        '월간 정기 판정(2026-07-31 종가)으로 2026-08-03 모의투자 회차를 계획했습니다 — 주문 대상 3건.',
      );
      expect(m.before[0].label, startsWith('A 22.0% '));
      expect(m.after[1].label, startsWith('B 42.0% '));
      expect(m.detailDeepLink, 'aaq://rebalance/event/REB-MONTHLY-2026-07-31');
      expect(r.rows[1].before, isEmpty);
      expect(r.rows[1].trigger.summary, '계절 A 할 일 없음 — 주문 없음.');
      expect(s.event('REB-SEAS-2026-06-30'), r.rows[1]);
      expect(() => s.event('nope'), throwsStateError);
      expect(
        src(hasBody: (String _) => false).events().rows.first.detailDeepLink,
        isNull,
      );
    },
  );

  test('미리보기 상태 — 개시 전 = 실패(0원 장부로 초안을 내지 않는다)', () {
    expect(() => src().whatIfState(), throwsA(isA<OpsConfigUnavailable>()));
  });

  group('개시 뒤', () {
    setUp(() {
      open();
      db.execute(
        'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at, '
        "entry_decision_id) VALUES ('KR', '229200', ?, 100, 9800, '2026-08-03', ?, NULL)",
        <Object?>[P0sStrategyIds.sleeveA, _t0.toIso8601String()],
      );
      for (final String s in p0sKrPlanSymbols()) {
        bar(s, '2026-08-28', 10000);
      }
      if (!p0sKrPlanSymbols().contains('229200')) {
        bar('229200', '2026-08-28', 10000);
      }
      db.execute(
        'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, '
        "config_hash) VALUES ('REBAL-2026-07-31', 'REBALANCE', ?, '2026-07-31', '2026-09-01', '{}', ?, 'cfg_t')",
        <Object?>[
          _t0.toIso8601String(),
          jsonEncode(<String, Object?>{'month_index': 4}),
        ],
      );
      db.execute(
        'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, account, '
        'strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, status, config_hash, '
        "updated_at, mode) VALUES ('iu', 'ku', ?, '2026-08-28', 'KR', 'pension', ?, 'D-U', '133690', 'BUY', "
        "'LIMIT', 1, 1, 'UNKNOWN', 'cfg_t', ?, ?)",
        <Object?>[
          _t0.toIso8601String(),
          P0sStrategyIds.sleeveB,
          _t0.toIso8601String(),
          RunMode.simInternal.wire,
        ],
      );
    });

    test(
      '보유 현황과 같은 장부 · 회차 번호 = 마지막 계획 + 1 · 계좌 · 차단(주입) · 체결 확인 중 종목',
      () async {
        flags = <BlockFlag>[
          BlockFlag.fromJson(<String, Object?>{
            'flag_id': FlagIds.ledgerFix,
            'label': '정정',
            'set_at': '2026-08-28T01:00:00Z',
            'clear_route': 'WIZARD_ONLY',
            'clear_instruction': '해소 안내',
            'clear_deep_link': null,
          }),
        ];
        final WhatIfState s = await SqliteWhatIfStateSource(src()).load();
        expect(s.asOfTradeDate, const TradeDate('2026-08-28'));
        expect(s.monthEnd!.monthIndex, 5);
        expect(s.monthEnd!.krwCash, Decimal.parse('10000000'));
        expect(s.monthEnd!.totalEquity, Decimal.parse('11000000'));
        expect(s.accounts.pensionAlias, 'pension');
        expect(s.accounts.generalAlias, 'general');
        expect(s.configHash, _cfg.configHash);
        expect(s.activeFlags, flags);
        expect(s.recovery, isFalse);
        expect(s.unknownSymbols, <String>{'133690'});
        expect(s.prices['229200'], Decimal.parse('10000'));
      },
    );

    test('🔴 미리보기 = 이 원천으로 엔진 창구가 계산(다음 정기 회차 · 경고 = 정정 플래그)', () async {
      flags = <BlockFlag>[
        BlockFlag.fromJson(<String, Object?>{
          'flag_id': FlagIds.ledgerFix,
          'label': '정정',
          'set_at': '2026-08-28T01:00:00Z',
          'clear_route': 'WIZARD_ONLY',
          'clear_instruction': '해소 안내',
          'clear_deep_link': null,
        }),
      ];
      final RebalancePreviewResult r = await EngineWhatIfApi(
        source: SqliteWhatIfStateSource(src()),
        store: InMemoryPlanSnapshotStore(),
        clock: clock,
      ).previewRebalance();
      expect(r.blockedText, isNull);
      expect(r.preview!.plannedDate, const TradeDate('2026-09-01'));
      expect(r.preview!.asOf.label, '초안 기준 2026-08-28 종가');
      expect(r.preview!.planId, 'pv_re_20260901_01');
      expect(
        r.preview!.warningLines,
        contains(RebalanceGateTexts.warnLedgerFix),
      );
    });
  });
}
