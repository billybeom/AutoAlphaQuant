// E7b2 · E7b3 — 실입금 등록 한 트랜잭션 기록기(설계 13 §8 R22 D5·D6·D7·D8·D9·D10·D11·D13 · 01 §20-3 · 06 M3-2·M3-4).
//
// 🔵 잡는 것(실 SQLite 파일): ① 기록 = decision_log 1 + 계좌별 cash_flow + 바인딩 + command_inbox 1 — 그 밖의 표 0
//    (주문 행 0 · D2 잔여 = 원화 대기) ② 두 번째 등록 거부 · 같은 명령 재전달 = 같은 결과 · 새 행 0 ③ 만료 거부는
//    requested_at 으로(엔진 시각이 늦어도 만료 전 등록은 기록) ④ RECON·LEDGER_FIX 거부 = 감사 1행만 · 무결성 = 쓰기 0
//    ⑤ planId 만으로 금액·기준일 · 휴장 → 다음 거래일 ⑥ 중간 실패 = 행 0 ⑦ 모드·파일 경계 ⑧ 실엔진 접수증에 C-38 ⑨
//    ⑨ 🆕 E7b3 — 한도 재검사(먼저 등록한 계획이 한도를 쓰면 다음 계획은 거부 · 06 M3-4 «소진 인식») · 해 넘김(처리 시점
//    KST 연도 · 연말 휴장에 넣은 돈은 그해 납입) · 계획 ↔ 결정 ↔ 현금 행 조인 앵커와 «계획 대비 실제».

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

BlockFlag _flag(String id) => BlockFlag.fromJson(<String, Object?>{
  'flag_id': id,
  'label': '$id 플래그',
  'set_at': '2026-08-28T01:00:00Z',
  'clear_route': 'WIZARD_ONLY',
  'clear_instruction': '해소 안내',
});

final ExchangeCalendar _kr = ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    for (final String d in <String>[
      '2026-08-31',
      '2026-09-01',
      '2026-09-02',
      '2026-09-03',
      '2026-09-04',
      '2026-09-07',
      '2026-09-08',
    ])
      TradeDate(d),
  ],
  coverageStart: const TradeDate('2026-08-31'),
  coverageEnd: const TradeDate('2026-09-08'),
);

/// 연말 — 2026-12-31(목)·2027-01-01(금) 휴장 · 01-02·03 주말.
final ExchangeCalendar _yearEnd = ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    for (final String d in <String>[
      '2026-12-28',
      '2026-12-29',
      '2026-12-30',
      '2027-01-04',
      '2027-01-05',
    ])
      TradeDate(d),
  ],
  coverageStart: const TradeDate('2026-12-28'),
  coverageEnd: const TradeDate('2027-01-05'),
);

WhatIfState _state({
  List<String> flags = const <String>[],
  Decimal? used,
  ExchangeCalendar? calendar,
}) => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: flags.map(_flag).toList(),
  recovery: false,
  accounts: const WhatIfAccounts(pensionAlias: '연금저축', generalAlias: '일반'),
  pensionUsedThisYear: used ?? _d('4200000'),
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  sleeveValues: <SleeveId, Decimal>{
    SleeveId.a: _d('4000000'),
    SleeveId.b: _d('8400000'),
    SleeveId.c: _d('7600000'),
  },
  prices: <String, Decimal>{'214980': _d('104235')},
  krCalendar: calendar ?? _kr,
);

/// 시스템 밖 연금 납입 신고값(연도별).
class _Declared implements PensionDeclarationSource {
  _Declared(this.byYear);
  final Map<int, Decimal> byYear;
  @override
  Future<Decimal> declaredOutside(int year) async =>
      byYear[year] ?? Decimal.zero;
}

class _Source implements WhatIfStateSource {
  _Source(this.s);
  WhatIfState s;
  @override
  Future<WhatIfState> load() async => s;
}

class _Clock implements Clock {
  _Clock(this.t);
  DateTime t;
  @override
  DateTime nowUtc() => t;
}

final DateTime _t0 = DateTime.utc(
  2026,
  8,
  31,
  21,
  5,
); // KST 09-01 06:05 · 계획 만료 = +24h

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('aaq_reg_'));
  tearDown(() => dir.deleteSync(recursive: true));

  Database open(RunMode mode) {
    final Database db = openLocalLedger(dir.path, mode, clock: () => _t0);
    addTearDown(db.close);
    return db;
  }

  Future<DepositPlan> plan(Database db, {DateTime? at, Decimal? used}) async =>
      (await EngineWhatIfApi(
        source: _Source(_state(used: used)),
        store: SqlitePlanSnapshotStore(db),
        clock: _Clock(at ?? _t0),
      ).simulateDeposit(amountInput: '1000000')).plan!;

  DepositRegisterCommand command(
    String planId, {
    String id = 'cmd_20260901_0051',
    DateTime? at,
  }) {
    final DateTime t = at ?? DateTime.utc(2026, 9, 1, 1); // KST 09-01 10:00
    return DepositRegisterCommand(
      commandId: id,
      planId: planId,
      requestedAt: t,
      expiresAt: t.add(const Duration(minutes: 30)),
      nonce: 'n_7c3e1a9f2b64',
      issuedByDeviceId: 'dev_operator_01',
    );
  }

  SqliteDepositRegistrar registrar(
    Database db, {
    RunMode mode = RunMode.live,
    List<String> flags = const <String>[],
    DateTime? now,
    Map<int, Decimal> declared = const <int, Decimal>{},
    ExchangeCalendar? calendar,
  }) => SqliteDepositRegistrar(
    db,
    mode: mode,
    state: _Source(_state(flags: flags, calendar: calendar)),
    clock: _Clock(now ?? DateTime.utc(2026, 9, 1, 1, 0, 5)),
    declarations: _Declared(declared),
  );

  Map<String, int> counts(Database db) => <String, int>{
    for (final Row t in db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    ))
      t['name'] as String:
          db.select('SELECT count(*) AS n FROM "${t['name']}"').first['n']
              as int,
  };

  Map<String, int> delta(Map<String, int> a, Map<String, int> b) =>
      <String, int>{
        for (final String k in b.keys)
          if (b[k] != a[k]) k: b[k]! - (a[k] ?? 0),
      };

  test('기록 — decision_log 1 · 계좌별 cash_flow · 바인딩 · command_inbox 1 · 그 밖의 표 0', () async {
    final Database db = open(RunMode.live);
    final DepositPlan p = await plan(db);
    final Map<String, int> before = counts(db);
    final CommandReceipt r = await registrar(db).register(command(p.planId));

    expect(r.state, CommandState.executed);
    expect(r.stateLabel, DepositRegisterTexts.executed);
    expect(r.rejectReasonCode, isNull);
    expect(depositReceiptViolations('engine', <CommandReceipt>[r]), isEmpty);
    expect(
      delta(before, counts(db)),
      <String, int>{'decision_log': 1, 'cash_flow': 2, 'command_inbox': 1},
      reason:
          '주문(order_intents)·안내·rebalance_event 는 쓰지 않는다(R22 D11 · D2 = 원화 대기)',
    );

    final Row d = db.select('SELECT * FROM decision_log').single;
    expect(d['decision_id'], 'DEP-${p.planId}');
    expect(d['kind'], 'DEPOSIT');
    expect(d['mode'], 'LIVE');
    expect(d['reason_code'], DecisionReasonCodes.depositRegistered);
    expect(d['strategy_id'], kDepositStrategyId);
    expect(d['config_hash'], p.configHash);
    expect(
      d['trade_date'],
      '2026-09-01',
      reason: '기준일 = 등록 시점(D10) — 스냅샷 as-of(08-31)가 아니다',
    );
    expect(d['created_at'], '2026-09-01T01:00:05.000Z');

    final Decimal bShare = p.allocations
        .where((SleeveAllocation a) => a.sleeve == SleeveId.b)
        .single
        .amount;
    expect(
      db
          .select(
            'SELECT account_alias, amount, trade_date, note FROM cash_flow ORDER BY flow_id',
          )
          .map(
            (Row c) =>
                '${c['account_alias']}|${c['amount']}|${c['trade_date']}|${c['note']}',
          ),
      <String>[
        '일반|${(p.depositAmount - bShare).toDouble()}|2026-09-01|${p.planId}',
        '연금저축|${bShare.toDouble()}|2026-09-01|${p.planId}',
      ],
      reason: '금액은 planId 만으로 스냅샷에서 · 계좌별 행(D6)',
    );
    expect(
      db.select(
        'SELECT consumed_by_decision_id AS c FROM plan_snapshot WHERE plan_id = ?',
        <Object>[p.planId],
      ).single['c'],
      'DEP-${p.planId}',
    );
    final Row inbox = db.select('SELECT * FROM command_inbox').single;
    expect(inbox['state'], 'EXECUTED');
    expect(inbox['decision_id'], 'DEP-${p.planId}');
    expect(inbox['payload_digest'], command(p.planId).payloadDigest);
    expect(inbox['run_mode'], isNull);
    expect(db.select('SELECT * FROM order_intents'), isEmpty);
  });

  test('두 번째 등록은 거부(감사 1행만) · 같은 명령 재전달은 같은 결과 · 새 행 0', () async {
    final Database db = open(RunMode.live);
    final DepositPlan p = await plan(db);
    final SqliteDepositRegistrar reg = registrar(db);
    final CommandReceipt first = await reg.register(command(p.planId));
    final Map<String, int> afterFirst = counts(db);

    final CommandReceipt again = await reg.register(command(p.planId));
    expect(again, first, reason: '수송 재전달 — 감사 기록의 결과를 그대로');
    expect(counts(db), afterFirst);

    final CommandReceipt second = await reg.register(
      command(p.planId, id: 'cmd_20260901_0052'),
    );
    expect(second.state, CommandState.rejected);
    expect(
      second.rejectReasonCode,
      DepositRegisterRejectCodes.planAlreadyRegistered,
    );
    expect(delta(afterFirst, counts(db)), <String, int>{'command_inbox': 1});
    expect(
      depositReceiptViolations('engine', <CommandReceipt>[first, second]),
      isEmpty,
    );
  });

  test(
    '만료 거부는 requested_at 으로 — 엔진이 늦게 받아도 만료 전 등록은 기록한다(D9 · 06 M3-2)',
    () async {
      final Database db = open(RunMode.live);
      final DepositPlan p = await plan(db);
      final DateTime late = p.expiresAt.add(const Duration(hours: 5));

      final CommandReceipt expired = await registrar(
        db,
        now: late,
      ).register(command(p.planId, id: 'cmd_a', at: p.expiresAt));
      expect(expired.rejectReasonCode, DepositRegisterRejectCodes.planExpired);
      expect(expired.stateLabel, contains(DepositGateTexts.registerExpired));
      expect(db.select('SELECT * FROM decision_log'), isEmpty);

      final CommandReceipt ok = await registrar(db, now: late).register(
        command(
          p.planId,
          id: 'cmd_b',
          at: p.expiresAt.subtract(const Duration(minutes: 1)),
        ),
      );
      expect(ok.state, CommandState.executed);
    },
  );

  test('RECON·LEDGER_FIX 는 거부(감사 1행만) · 원장 무결성은 보류(쓰기 0)', () async {
    final Database db = open(RunMode.live);
    final DepositPlan p = await plan(db);
    final Map<String, int> start = counts(db);

    final CommandReceipt held = await registrar(
      db,
      flags: <String>[FlagIds.ledgerIntegrity, FlagIds.reconMismatch],
    ).register(command(p.planId, id: 'cmd_h'));
    expect(held.state, CommandState.heldForIntegrity);
    expect(counts(db), start, reason: '보류는 아무것도 쓰지 않는다 — 수송이 다시 건넨다');

    final CommandReceipt recon = await registrar(
      db,
      flags: <String>[FlagIds.reconMismatch, FlagIds.ledgerFix],
    ).register(command(p.planId, id: 'cmd_r'));
    final CommandReceipt fix = await registrar(
      db,
      flags: <String>[FlagIds.ledgerFix],
    ).register(command(p.planId, id: 'cmd_f'));
    expect(
      <String?>[recon.rejectReasonCode, fix.rejectReasonCode],
      <String>[
        DepositRegisterRejectCodes.reconPending,
        DepositRegisterRejectCodes.ledgerFixPending,
      ],
    );
    expect(delta(start, counts(db)), <String, int>{'command_inbox': 2});
    expect(
      db
          .select('SELECT consumed_by_decision_id AS c FROM plan_snapshot')
          .single['c'],
      isNull,
      reason: '거부는 바인딩하지 않는다 — 대조가 끝나면 같은 계획으로 다시 등록할 수 있다',
    );
    expect(
      depositReceiptViolations('engine', <CommandReceipt>[held, recon, fix]),
      isEmpty,
    );
  });

  test('휴장일에 누른 등록 — 기준일 = 다음 KR 거래일(금요일 밤 계획 → 토요일 등록 → 월요일)', () async {
    final Database db = open(RunMode.live);
    final DepositPlan p = await plan(
      db,
      at: DateTime.utc(2026, 9, 4, 11),
    ); // KST 금 20:00 · 만료 = 토 20:00
    final CommandReceipt r =
        await registrar(db, now: DateTime.utc(2026, 9, 5, 1, 0, 5)).register(
          command(p.planId, at: DateTime.utc(2026, 9, 5, 1)),
        ); // KST 토 10:00
    expect(r.state, CommandState.executed);
    expect(
      db.select('SELECT trade_date FROM decision_log').single['trade_date'],
      '2026-09-07',
    );
    expect(
      db
          .select('SELECT DISTINCT trade_date AS d FROM cash_flow')
          .map((Row c) => c['d']),
      <String>['2026-09-07'],
    );
  });

  test('중간 실패 — 둘째 현금 행에서 PK 충돌이면 결정·현금·바인딩·감사 전부 0', () async {
    final Database db = open(RunMode.live);
    final DepositPlan p = await plan(db);
    db.execute(
      "INSERT INTO cash_flow (flow_id, trade_date, amount, kind) VALUES (?, '2026-08-01', 1, 'DEPOSIT')",
      <Object>['DEP-${p.planId}-GENERAL'],
    );
    final Map<String, int> before = counts(db);
    await expectLater(
      registrar(db).register(command(p.planId)),
      throwsA(isA<SqliteException>()),
    );
    expect(counts(db), before);
    expect(db.autocommit, isTrue, reason: '트랜잭션이 열린 채 남지 않는다');
    expect(
      db
          .select('SELECT consumed_by_decision_id AS c FROM plan_snapshot')
          .single['c'],
      isNull,
    );
  });

  test(
    '파일이 경계 — 모의 계획은 실계좌 파일에서 «없음» · 모의 파일은 SIM 모드로 기록 · 잘못 연 모드는 실패',
    () async {
      final Database sim = open(RunMode.simInternal);
      final DepositPlan p = await plan(sim);
      final Database live = open(RunMode.live);

      final CommandReceipt none = await registrar(live)
          .register(command(p.planId, id: 'cmd_x'));
      expect(none.rejectReasonCode, DepositRegisterRejectCodes.planNotFound);

      final Map<String, int> before = counts(sim);
      await expectLater(
        registrar(sim).register(command(p.planId, id: 'cmd_y')),
        throwsA(isA<SqliteException>()),
        reason: 'LIVE 로 모의 파일에 쓰면 decision_log.mode CHECK 가 막는다',
      );
      expect(counts(sim), before);

      final CommandReceipt ok = await registrar(
        sim,
        mode: RunMode.simInternal,
      ).register(command(p.planId, id: 'cmd_z'));
      expect(ok.state, CommandState.executed);
      expect(
        sim.select('SELECT mode FROM decision_log').single['mode'],
        'SIM_INTERNAL',
      );
    },
  );

  test(
    '한도 재검사 — 같은 누계에서 만든 두 계획 · 먼저 등록한 쪽이 한도를 쓰면 다음은 거부(D13 · 06 M3-4)',
    () async {
      final Database db = open(RunMode.live);
      final Decimal outside = _d('17600000'); // 남은 한도 400,000원
      final DepositPlan first = await plan(db, used: outside);
      final DepositPlan second = await plan(db, used: outside);
      final Decimal bShare = depositPensionShare(first);
      expect(bShare, _d('400000'), reason: '입력 확인 — B 몫이 남은 한도로 잘린다');
      final Map<int, Decimal> declared = <int, Decimal>{2026: outside};

      final CommandReceipt a = await registrar(
        db,
        declared: declared,
      ).register(command(first.planId, id: 'cmd_1'));
      expect(a.state, CommandState.executed);
      final Map<String, int> afterFirst = counts(db);

      final CommandReceipt b = await registrar(
        db,
        declared: declared,
      ).register(command(second.planId, id: 'cmd_2'));
      expect(
        b.rejectReasonCode,
        DepositRegisterRejectCodes.pensionQuotaChanged,
      );
      expect(b.stateLabel, contains(DepositGateTexts.registerPensionQuota));
      expect(delta(afterFirst, counts(db)), <String, int>{'command_inbox': 1});
      expect(
        pensionUsedInYear(
          SqliteDepositLedger(db).cashRows('연금저축'),
          pensionAlias: '연금저축',
          year: 2026,
          declaredOutside: outside,
        ),
        _d('18000000'),
        reason: '누계 = 신고값 + 원장 연금 입금 — 연 한도에 꽉 찼다',
      );
      expect(
        depositReceiptViolations('engine', <CommandReceipt>[a, b]),
        isEmpty,
      );
    },
  );

  test('🆕 R260 F-1 🔴 앱 안 모의 — 그날 마감 평가 뒤 등록 = 기준일 다음 세션 → 계층 B TWR 시리즈 거짓 낙폭 0 · 평가 전 = 그날 · 실전 = 옛 규칙', () async {
    void snap(Database db, String day, double eq) => db.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
      "VALUES (?, ?, ?, 0, ?, 0, 'SIM_INTERNAL')",
      <Object?>[day, eq, eq, eq],
    );
    List<String> days(Database db) => <String>[
      for (final Row c in db.select(
        'SELECT DISTINCT trade_date AS d FROM cash_flow ORDER BY d',
      ))
        c['d'] as String,
    ];
    final DateTime night = DateTime.utc(2026, 9, 1, 12); // KST 09-01 21:00

    final Database sim = open(RunMode.simInternal);
    snap(sim, '2026-08-31', 10000000);
    snap(sim, '2026-09-01', 10000000); // 09-01 20:30 평가(입금 전)
    final DepositPlan p = await plan(sim);
    final CommandReceipt r = await registrar(
      sim,
      mode: RunMode.simInternal,
      now: night.add(const Duration(seconds: 5)),
    ).register(command(p.planId, at: night));
    expect(r.state, CommandState.executed);
    snap(sim, '2026-09-02', 11000000); // 입금이 처음 든 평가
    expect(twrIndex(tierBSeries(sim, '2026-09-02')), <double>[
      1.0,
      1.0,
      1.0,
    ], reason: '고치기 전 = 09-01 −10% · 09-02 +10%(지수 0.9 → 0.99)');
    expect(days(sim), <String>['2026-09-02']);
    expect(
      sim.select('SELECT trade_date FROM decision_log').single['trade_date'],
      '2026-09-02',
    );
  });

  test('🆕 R260 F-1 — 그날 평가 전 등록(모의 · 잡 늦음 · 실패) = 그날', () async {
    void snap(Database db, String day, String mode) => db.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
      'VALUES (?, 1, 1, 0, 1, 0, ?)',
      <Object?>[day, mode],
    );
    final DateTime night = DateTime.utc(2026, 9, 1, 12); // KST 09-01 21:00
    final Database sim = open(RunMode.simInternal);
    snap(sim, '2026-08-31', 'SIM_INTERNAL');
    final DepositPlan p = await plan(sim);
    await registrar(
      sim,
      mode: RunMode.simInternal,
      now: night,
    ).register(command(p.planId, at: night));
    expect(
      sim.select('SELECT trade_date FROM decision_log').single['trade_date'],
      '2026-09-01',
    );
  });

  test(
    '🆕 R260 F-1 — 실전 = 그날 평가가 있어도 등록 날(옛 규칙 · 돈이 평가에 드는 날 = 브로커 입금 날)',
    () async {
      void snap(Database db, String day, String mode) => db.execute(
        'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
        'VALUES (?, 1, 1, 0, 1, 0, ?)',
        <Object?>[day, mode],
      );
      final DateTime night = DateTime.utc(2026, 9, 1, 12); // KST 09-01 21:00
      final Database live = open(RunMode.live);
      snap(live, '2026-09-01', 'LIVE');
      final DepositPlan q = await plan(live);
      await registrar(live, now: night).register(command(q.planId, at: night));
      expect(
        live.select('SELECT trade_date FROM decision_log').single['trade_date'],
        '2026-09-01',
      );
    },
  );

  test(
    '🆕 R260 F-5 🔴 연금 한도 «그해» = 요청 시각(신뢰 시각) KST 연도 — 기기 시계가 해를 넘겨도 그해 한도로 판정',
    () async {
      final Database db = open(RunMode.live);
      final Decimal outside = _d('17600000');
      final DateTime computed = DateTime.utc(
        2026,
        12,
        31,
        11,
      ); // KST 12-31 20:00
      final DepositPlan dec = await plan(db, at: computed, used: outside);
      final DepositPlan late = await plan(db, at: computed, used: outside);
      final Map<int, Decimal> declared = <int, Decimal>{2026: outside};
      final CommandReceipt a =
          await registrar(
            db,
            declared: declared,
            calendar: _yearEnd,
            now: DateTime.utc(2026, 12, 31, 12, 0, 5),
          ).register(
            command(
              dec.planId,
              id: 'cmd_d',
              at: DateTime.utc(2026, 12, 31, 12),
            ),
          );
      expect(a.state, CommandState.executed);
      // 요청 = KST 12-31 22:00(2026 · 한도 꽉 참) · 기기 시계 = KST 01-01 01:00(2027).
      final CommandReceipt b =
          await registrar(
            db,
            declared: declared,
            calendar: _yearEnd,
            now: DateTime.utc(2026, 12, 31, 16),
          ).register(
            command(
              late.planId,
              id: 'cmd_l',
              at: DateTime.utc(2026, 12, 31, 13),
            ),
          );
      expect(b.state, CommandState.rejected);
      expect(
        b.rejectReasonCode,
        DepositRegisterRejectCodes.pensionQuotaChanged,
        reason: '고치기 전 = 기기 시계 연도(2027) 한도로 판정 → 2026 한도 넘겨 기록',
      );
    },
  );

  test('해 넘김 — 12-31(휴장) 밤에 넣은 돈은 그해 납입 · 1월 1일에 넣은 돈은 새해 한도', () async {
    final Database db = open(RunMode.live);
    final Decimal outside = _d('17600000');
    final DateTime computed = DateTime.utc(
      2026,
      12,
      31,
      11,
    ); // KST 12-31 20:00 · 만료 01-01 20:00
    final DepositPlan dec = await plan(db, at: computed, used: outside);
    final DepositPlan jan = await plan(db, at: computed, used: outside);
    final Map<int, Decimal> declared = <int, Decimal>{2026: outside};

    final CommandReceipt a =
        await registrar(
          db,
          declared: declared,
          calendar: _yearEnd,
          now: DateTime.utc(2026, 12, 31, 12, 0, 5),
        ).register(
          command(dec.planId, id: 'cmd_d', at: DateTime.utc(2026, 12, 31, 12)),
        );
    expect(a.state, CommandState.executed);

    // 같은 연금 한도(2026)는 이제 꽉 찼지만, 해가 바뀐 뒤 처리하면 2027 한도에서 센다.
    final CommandReceipt b =
        await registrar(
          db,
          declared: declared,
          calendar: _yearEnd,
          now: DateTime.utc(2027, 1, 1, 1, 0, 5),
        ).register(
          command(jan.planId, id: 'cmd_j', at: DateTime.utc(2027, 1, 1, 1)),
        );
    expect(b.state, CommandState.executed);

    expect(
      db
          .select('SELECT trade_date FROM decision_log ORDER BY decision_id')
          .map((Row r) => r['trade_date']),
      <String>['2027-01-04', '2027-01-04'],
      reason: '기준일은 휴장 보정 — 둘 다 다음 거래일',
    );
    final List<LedgerCashRow> rows = SqliteDepositLedger(db).cashRows('연금저축');
    expect(
      pensionUsedInYear(
        rows,
        pensionAlias: '연금저축',
        year: 2026,
        declaredOutside: outside,
      ),
      _d('18000000'),
      reason: '12-31 처리분은 기준일이 2027 이어도 2026 납입이다',
    );
    expect(
      pensionUsedInYear(
        rows,
        pensionAlias: '연금저축',
        year: 2027,
        declaredOutside: Decimal.zero,
      ),
      depositPensionShare(jan),
    );
  });

  test('앵커 — 계획 ↔ 결정 ↔ 현금 행 조인 = 기록 값 · 계획 대비 실제는 «실제» 공급분과 맞댄다(D8)', () async {
    final Database db = open(RunMode.live);
    final DepositPlan p = await plan(db);
    final DepositPlan other = await plan(db);
    final SqliteDepositLedger ledger = SqliteDepositLedger(db);
    expect(ledger.registeredCash(p.planId), isEmpty, reason: '등록 전');

    await registrar(db).register(command(p.planId));
    final DepositPlanSnapshot snap = SqlitePlanSnapshotStore(db)
        .readSnapshot(p.planId)!;
    final List<DepositCashRow> registered = ledger.registeredCash(p.planId);
    expect(
      registered.map(
        (DepositCashRow r) => '${r.flowId}|${r.accountAlias}|${r.amount}',
      ),
      unorderedEquals(
        depositLedgerEntry(snap, const TradeDate('2026-09-01')).cash.map(
          (DepositCashRow r) => '${r.flowId}|${r.accountAlias}|${r.amount}',
        ),
      ),
    );
    expect(
      ledger.registeredCash(other.planId),
      isEmpty,
      reason: '다른 계획의 행은 섞이지 않는다',
    );
    expect(
      depositPlanVsActual(snap, <String?, Decimal>{
        for (final DepositCashRow r in registered) r.accountAlias: r.amount,
      }),
      isEmpty,
      reason: '기록 = 계획(그래서 «실제»는 브로커 잔고·수기 기록이 공급한다 — E10·E18)',
    );
    final List<DepositAccountGap> gaps = depositPlanVsActual(
      snap,
      <String?, Decimal>{'연금저축': depositPensionShare(p), '일반': Decimal.zero},
    );
    expect(gaps.map((DepositAccountGap g) => g.accountAlias), <String>['일반']);
  });
}
