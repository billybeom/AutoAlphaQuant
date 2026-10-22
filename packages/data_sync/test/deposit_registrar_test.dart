// E7b2 — 실입금 등록 한 트랜잭션 기록기(설계 13 §8 R22 D5·D6·D9·D10·D11 · 01 §20-3 · 06 M3-2·M3-4).
//
// 🔵 잡는 것(실 SQLite 파일): ① 기록 = decision_log 1 + 계좌별 cash_flow + 바인딩 + command_inbox 1 — 그 밖의 표 0
//    (주문 행 0 · D2 잔여 = 원화 대기) ② 두 번째 등록 거부 · 같은 명령 재전달 = 같은 결과 · 새 행 0 ③ 만료 거부는
//    requested_at 으로(엔진 시각이 늦어도 만료 전 등록은 기록) ④ RECON·LEDGER_FIX 거부 = 감사 1행만 · 무결성 = 쓰기 0
//    ⑤ planId 만으로 금액·기준일 · 휴장 → 다음 거래일 ⑥ 중간 실패 = 행 0 ⑦ 모드·파일 경계 ⑧ 실엔진 접수증에 C-38 ⑨.

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

WhatIfState _state({List<String> flags = const <String>[]}) => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: flags.map(_flag).toList(),
  recovery: false,
  accounts: const WhatIfAccounts(pensionAlias: '연금저축', generalAlias: '일반'),
  pensionUsedThisYear: _d('4200000'),
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  sleeveValues: <SleeveId, Decimal>{
    SleeveId.a: _d('4000000'),
    SleeveId.b: _d('8400000'),
    SleeveId.c: _d('7600000'),
  },
  prices: <String, Decimal>{'214980': _d('104235')},
  krCalendar: _kr,
);

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

  Future<DepositPlan> plan(Database db, {DateTime? at}) async =>
      (await EngineWhatIfApi(
        source: _Source(_state()),
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
  }) => SqliteDepositRegistrar(
    db,
    mode: mode,
    state: _Source(_state(flags: flags)),
    clock: _Clock(now ?? DateTime.utc(2026, 9, 1, 1, 0, 5)),
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
}
