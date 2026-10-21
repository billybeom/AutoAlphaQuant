// E7b1 — 계획 스냅샷 SQLite 판(설계 13 §8 R22 D1~D3 · 06 M3-1 ⓔ · M3-2).
//
// 🔵 잡는 것: ① 실 SQLite 왕복(되살린 계획 == 저장한 계획 · 입력 원값 JSON v1) ② 앱을 다시 켜도 `findPlan` 이
//    같은 계획을 주고 등록 불가 문장을 지금 시각으로 다시 판정한다 ③ 재시작 뒤 순번이 이어지고 PK 가 충돌하지 않는다
//    ④ «부작용 0» — 미리보기 한 번에 바뀌는 표는 `plan_snapshot` 하나(+1행)뿐 ⑤ 모의 파일의 계획은 실계좌 파일에 없다.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

WhatIfState _state() => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: const <BlockFlag>[],
  recovery: false,
  accounts: const WhatIfAccounts(pensionAlias: '연금저축', generalAlias: '일반'),
  pensionUsedThisYear: _d('4200000'),
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  sleeveValues: <SleeveId, Decimal>{
    SleeveId.a: _d('4000000'),
    SleeveId.b: _d('8400000'),
    SleeveId.c: _d('9000000'),
  },
  prices: <String, Decimal>{'214980': _d('104235')},
);

class _Fixed implements WhatIfStateSource {
  _Fixed(this.s);
  final WhatIfState s;
  @override
  Future<WhatIfState> load() async => s;
}

class _Clock implements Clock {
  _Clock(this.t);
  DateTime t;
  @override
  DateTime nowUtc() => t;
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('aaq_plan_'));
  tearDown(() => dir.deleteSync(recursive: true));

  final DateTime t0 = DateTime.utc(2026, 8, 31, 21, 5); // KST 09-01 06:05

  Database open(RunMode mode) {
    final Database db = openLocalLedger(dir.path, mode, clock: () => t0);
    addTearDown(db.close);
    return db;
  }

  EngineWhatIfApi api(Database db, _Clock clock) => EngineWhatIfApi(
    source: _Fixed(_state()),
    store: SqlitePlanSnapshotStore(db),
    clock: clock,
  );

  Map<String, int> counts(Database db) => <String, int>{
    for (final Row t in db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    ))
      t['name'] as String:
          db.select('SELECT count(*) AS n FROM "${t['name']}"').first['n']
              as int,
  };

  test('왕복 — 되살린 계획 == 저장한 계획 · 입력 원값 JSON v1 · 행 칸', () async {
    final Database db = open(RunMode.live);
    final DepositPlan plan = (await api(
      db,
      _Clock(t0),
    ).simulateDeposit(amountInput: '1000000')).plan!;
    expect(plan.planId, 'pl_20260901_01');
    final SqlitePlanSnapshotStore store = SqlitePlanSnapshotStore(db);
    expect(await store.find(plan.planId), plan);
    expect(
      (await store.findInputs(plan.planId))!.toJson(),
      PlanInputs.of(_state()).toJson(),
    );
    final Row r = db.select('SELECT * FROM plan_snapshot').single;
    expect(r['kind'], 'DEPOSIT');
    expect(r['as_of_trade_date'], '2026-08-31');
    expect(r['config_hash'], 'cfg_test');
    expect(r['computed_at'], '2026-08-31T21:05:00.000Z');
    expect(r['expires_at'], '2026-09-01T21:05:00.000Z');
    expect(r['consumed_by_decision_id'], isNull, reason: '바인딩은 등록 처리(E7b2) 몫');
    expect(await store.find('pl_20260901_99'), isNull);
  });

  test('다시 켜도 findPlan 이 같은 계획을 주고 만료를 지금 시각으로 판정한다', () async {
    final Database first = open(RunMode.live);
    final DepositPlan plan = (await api(
      first,
      _Clock(t0),
    ).simulateDeposit(amountInput: '1000000')).plan!;
    first.close();

    final Database again = open(RunMode.live);
    final _Clock clock = _Clock(t0.add(const Duration(hours: 1)));
    final DepositPlan? live = await api(again, clock).findPlan(plan.planId);
    expect(live, isNotNull);
    expect(live!.copyWith(registerBlockedText: null), plan);
    expect(live.registerBlockedText, isNull, reason: '만료 전 · 차단 없음');

    clock.t = plan.expiresAt;
    expect(
      (await api(again, clock).findPlan(plan.planId))!.registerBlockedText,
      DepositGateTexts.registerExpired,
    );
  });

  test('순번 — 재시작 뒤 이어지고 충돌하지 않는다 · 날이 바뀌면 01 · re_ 키는 저장 무관', () async {
    final Database first = open(RunMode.live);
    final _Clock clock = _Clock(t0);
    final EngineWhatIfApi a = api(first, clock);
    expect(
      (await a.simulateDeposit(amountInput: '1000000')).plan!.planId,
      'pl_20260901_01',
    );
    expect(
      (await a.simulateDeposit(amountInput: '2000000')).plan!.planId,
      'pl_20260901_02',
    );
    first.close();

    final Database again = open(RunMode.live);
    final EngineWhatIfApi b = api(again, clock);
    expect(
      (await b.simulateDeposit(amountInput: '3000000')).plan!.planId,
      'pl_20260901_03',
    );
    clock.t = t0.add(const Duration(days: 1));
    expect(
      (await b.simulateDeposit(amountInput: '1000000')).plan!.planId,
      'pl_20260902_01',
    );
    expect(again.select('SELECT * FROM plan_snapshot'), hasLength(4));
    final SqlitePlanSnapshotStore s = SqlitePlanSnapshotStore(again);
    expect(await s.nextSequence('re_20260901'), 1);
    // 저장 전에 두 번 받아도 겹치지 않는다(이 연결이 나눠 준 순번을 기억한다).
    expect(await s.nextSequence('20260902'), 2);
    expect(await s.nextSequence('20260902'), 3);
  });

  test('부작용 0 — 미리보기 한 번에 바뀌는 표는 plan_snapshot(+1) 하나 · 거부된 입력은 0', () async {
    final Database db = open(RunMode.live);
    final EngineWhatIfApi a = api(db, _Clock(t0));
    final Map<String, int> before = counts(db);
    await a.simulateDeposit(amountInput: '1000000');
    final Map<String, int> after = counts(db);
    for (final String t in before.keys) {
      expect(after[t], before[t]! + (t == 'plan_snapshot' ? 1 : 0), reason: t);
    }
    final DepositPreviewResult bad = await a.simulateDeposit(amountInput: '0');
    expect(bad.plan, isNull);
    expect(counts(db), after);
  });

  test('파일이 경계 — 모의 파일에서 만든 계획은 실계좌 파일에 없다', () async {
    final Database sim = open(RunMode.simInternal);
    final DepositPlan plan = (await api(
      sim,
      _Clock(t0),
    ).simulateDeposit(amountInput: '1000000')).plan!;
    final Database live = open(RunMode.live);
    expect(await SqlitePlanSnapshotStore(live).find(plan.planId), isNull);
    expect(await api(live, _Clock(t0)).findPlan(plan.planId), isNull);
    expect(await SqlitePlanSnapshotStore(sim).find(plan.planId), plan);
  });
}
