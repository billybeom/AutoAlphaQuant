// E7b1 — 계획 스냅샷 입력 원값 `PlanInputs`(inputs JSON v1 · 설계 13 §8 R22 D2).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
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
    SleeveId.c: _d('9000000'),
    SleeveId.a: _d('4000000'),
    SleeveId.b: _d('8400000'),
  },
  prices: <String, Decimal>{'411060': _d('31250.5'), '214980': _d('104235')},
);

void main() {
  test('JSON v1 — 판 번호 · 키 정렬 · Decimal 문자열 · 환율 null', () {
    final Map<String, Object?> j = PlanInputs.of(_state()).toJson();
    expect(j['v'], 1);
    expect(j['config_hash'], 'cfg_test');
    expect(j['as_of'], <String, Object?>{
      'trade_date': '2026-08-31',
      'observed_at': '2026-08-31T09:00:00.000Z',
      'source': 'LOCAL_SQLITE',
    });
    expect((j['prices']! as Map).keys, <String>['214980', '411060']);
    expect((j['prices']! as Map)['411060'], '31250.5');
    expect((j['sleeve_values']! as Map).keys, <String>['A', 'B', 'C']);
    expect(j['pension_used_this_year'], '4200000');
    expect(j['accounts'], <String, Object?>{
      'pension': '연금저축',
      'general': '일반',
    });
    expect(j.containsKey('fx'), isTrue);
    expect(j['fx'], isNull);
  });

  test('왕복 — fromJson(toJson(x)).toJson() == toJson(x)', () {
    final PlanInputs a = PlanInputs.of(_state());
    final PlanInputs b = PlanInputs.fromJson(a.toJson());
    expect(b.toJson(), a.toJson());
    expect(b.sleeveValues[SleeveId.b], _d('8400000'));
    expect(b.observedAt.isUtc, isTrue);
  });

  test('모르는 판은 읽지 않는다', () {
    final Map<String, Object?> j = PlanInputs.of(_state()).toJson()..['v'] = 2;
    expect(() => PlanInputs.fromJson(j), throwsA(isA<FormatException>()));
  });

  test('simulateDeposit 은 계획과 그 계산 입력 원값을 함께 저장한다', () async {
    final InMemoryPlanSnapshotStore store = InMemoryPlanSnapshotStore();
    final EngineWhatIfApi api = EngineWhatIfApi(
      source: _Fixed(_state()),
      store: store,
      clock: _Clock(DateTime.utc(2026, 8, 31, 21, 5)),
    );
    final DepositPreviewResult r = await api.simulateDeposit(
      amountInput: '1000000',
    );
    final String id = r.plan!.planId;
    expect(store.inputs[id]!.toJson(), PlanInputs.of(_state()).toJson());
  });
}

class _Fixed implements WhatIfStateSource {
  _Fixed(this.s);
  final WhatIfState s;
  @override
  Future<WhatIfState> load() async => s;
}

class _Clock implements Clock {
  _Clock(this.t);
  final DateTime t;
  @override
  DateTime nowUtc() => t;
}
