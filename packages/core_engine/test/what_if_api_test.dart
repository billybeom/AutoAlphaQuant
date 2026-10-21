// E7a2-3 — 엔진 `WhatIfApi`(06 M3-1 · M3-2 · 01 §14-5 · §14-7 · §14-8 · 설계 13 §8 R18 D-3 · D-13).
//
// 🔵 부작용 0 = 상태는 읽기만 · 쓰는 곳은 계획 스냅샷 저장소 하나 · 차단·거부는 아무것도 쓰지 않는다.
// 🔵 planId = `pl_<한국 날짜>_<순번 두 자리>` · 호출마다 새 값 · 만료와 등록 불가는 `findPlan` 이 지금 시각·상태로 다시 판정.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

BlockFlag _flag(String id) => BlockFlag.fromJson(<String, Object?>{
  'flag_id': id,
  'label': '$id 플래그',
  'set_at': '2026-08-28T01:00:00Z',
  'clear_route': 'WIZARD_ONLY',
  'clear_instruction': '해소 안내',
});

WhatIfState _state({List<BlockFlag> flags = const <BlockFlag>[]}) =>
    WhatIfState(
      asOfTradeDate: const TradeDate('2026-08-31'),
      configHash: 'cfg_test',
      activeFlags: flags,
      recovery: false,
      accounts: const WhatIfAccounts(pensionAlias: '연금저축', generalAlias: '일반'),
      pensionUsedThisYear: Decimal.zero,
      observedAt: DateTime.utc(2026, 8, 31, 9),
      source: AsOfSource.localSqlite,
      sleeveValues: <SleeveId, Decimal>{
        SleeveId.a: _d('2000000'),
        SleeveId.b: _d('4000000'),
        SleeveId.c: _d('4000000'),
      },
      prices: <String, Decimal>{'214980': _d('10450')},
    );

/// 읽기만 하는 상태 공급자 — 읽은 횟수를 센다 · 상태를 갈아 끼울 수 있다 · 실패를 낼 수 있다.
class _Source implements WhatIfStateSource {
  _Source(this.state);
  WhatIfState state;
  Error? fail;
  int loads = 0;

  @override
  Future<WhatIfState> load() async {
    loads++;
    if (fail != null) throw fail!;
    return state;
  }
}

/// 쓰기를 세는 저장소.
class _Store extends InMemoryPlanSnapshotStore {
  int saves = 0;
  int sequences = 0;

  @override
  Future<void> save(DepositPlan plan) {
    saves++;
    return super.save(plan);
  }

  @override
  Future<int> nextSequence(String kstDay) {
    sequences++;
    return super.nextSequence(kstDay);
  }
}

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;

  @override
  DateTime nowUtc() => now;
}

void main() {
  late _Source source;
  late _Store store;
  late _Clock clock;
  late EngineWhatIfApi api;

  setUp(() {
    source = _Source(_state());
    store = _Store();
    clock = _Clock(DateTime.utc(2026, 8, 31, 21, 5)); // 한국 2026-09-01 06:05
    api = EngineWhatIfApi(source: source, store: store, clock: clock);
  });

  group('planId · 스냅샷(D-13)', () {
    test('한국 날짜 + 그날 순번 두 자리 · 호출마다 새 값 · 날이 바뀌면 01 부터', () async {
      final DepositPlan p1 = (await api.simulateDeposit(amountInput: '100,000'))
          .plan!;
      final DepositPlan p2 = (await api.simulateDeposit(amountInput: '100,000'))
          .plan!;
      expect(p1.planId, 'pl_20260901_01');
      expect(p2.planId, 'pl_20260901_02');
      clock.now = DateTime.utc(2026, 9, 1, 15); // 한국 09-02 00:00
      expect(
        (await api.simulateDeposit(amountInput: '100000')).plan!.planId,
        'pl_20260902_01',
      );
      expect(kstDay(DateTime.utc(2026, 8, 31, 14, 59)), '20260831');
      expect(kstDay(DateTime.utc(2026, 8, 31, 15)), '20260901');
      expect(
        depositPlanId(DateTime.utc(2026, 8, 31, 21), 123),
        'pl_20260901_123',
      );
      expect(() => depositPlanId(DateTime.utc(2026), 0), throwsArgumentError);
    });

    test('계산 시각 = 신뢰 시각 · 만료 = +24h · 저장본 = 돌려준 계획', () async {
      final DepositPlan p = (await api.simulateDeposit(amountInput: '100000'))
          .plan!;
      expect(p.computedAt, clock.now);
      expect(p.expiresAt, clock.now.add(const Duration(hours: 24)));
      expect(await store.find(p.planId), p);
    });
  });

  group('부작용 0(06 M3-1 ⓔ)', () {
    test('계획이 생길 때만 저장 1회 · 차단·거부는 아무것도 쓰지 않고 순번도 먹지 않는다', () async {
      await api.simulateDeposit(amountInput: '100000');
      expect((store.saves, store.sequences), (1, 1));
      await api.simulateDeposit(amountInput: '10만');
      source.state = _state(flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity)]);
      await api.simulateDeposit(amountInput: '100000');
      expect((store.saves, store.sequences), (1, 1));
      source.state = _state();
      expect(
        (await api.simulateDeposit(amountInput: '100000')).plan!.planId,
        'pl_20260901_02',
      );
    });

    test('창구 출력 전부가 C-38 ①~⑧ 를 통과한다', () async {
      final List<DepositPreviewResult> rs = <DepositPreviewResult>[
        await api.simulateDeposit(amountInput: '100000'),
        await api.simulateDeposit(amountInput: ''),
      ];
      source.state = _state(
        flags: <BlockFlag>[_flag(FlagIds.resumeIncomplete)],
      );
      rs.add(await api.simulateDeposit(amountInput: '100000'));
      final List<String> bad = <String>[
        for (final (int i, DepositPreviewResult r) in rs.indexed) ...<String>[
          ...depositPreviewResultViolations('r$i', r),
          if (r.plan case final DepositPlan p)
            ...depositPlanViolations(
              'r$i',
              p,
              pensionAliases: const <String>{'연금저축'},
              allAliases: const <String>{'연금저축', '일반'},
            ),
        ],
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('상태를 못 읽으면 Future 에러(인프라) — 저장하지 않는다', () async {
      source.fail = StateError('원장 읽기 실패');
      await expectLater(
        api.simulateDeposit(amountInput: '100000'),
        throwsStateError,
      );
      expect(store.saves, 0);
    });
  });

  group('findPlan — 지금 시각·상태로 등록 불가 다시 판정(D-3)', () {
    test('없는 planId = null · 만료 전 = 등록 가능 · 만료 시각 정각부터 만료 문장', () async {
      expect(await api.findPlan('pl_20260901_99'), isNull);
      final DepositPlan p = (await api.simulateDeposit(amountInput: '100000'))
          .plan!;
      expect((await api.findPlan(p.planId))!.registerBlockedText, isNull);
      clock.now = p.expiresAt.subtract(const Duration(seconds: 1));
      expect((await api.findPlan(p.planId))!.registerBlockedText, isNull);
      clock.now = p.expiresAt;
      expect(
        (await api.findPlan(p.planId))!.registerBlockedText,
        DepositGateTexts.registerExpired,
      );
    });

    test(
      '계산 뒤 잔고 대조가 걸리면 RECON 이 만료보다 먼저 · 해소되면 다시 등록 가능 · 그 밖 칸은 저장본 그대로',
      () async {
        final DepositPlan p = (await api.simulateDeposit(amountInput: '100000'))
            .plan!;
        source.state = _state(flags: <BlockFlag>[_flag(FlagIds.reconMismatch)]);
        clock.now = p.expiresAt.add(const Duration(hours: 1));
        final DepositPlan f = (await api.findPlan(p.planId))!;
        expect(f.registerBlockedText, DepositGateTexts.registerRecon);
        expect(f.copyWith(registerBlockedText: null), p);
        source.state = _state();
        clock.now = p.computedAt;
        expect((await api.findPlan(p.planId))!.registerBlockedText, isNull);
        expect(depositPlanTextViolations('f', f), isEmpty);
      },
    );

    test('계산 때 등록 불가였어도 해소되면 findPlan 은 등록 가능으로 준다', () async {
      source.state = _state(flags: <BlockFlag>[_flag(FlagIds.ledgerFix)]);
      final DepositPlan p = (await api.simulateDeposit(amountInput: '100000'))
          .plan!;
      expect(p.registerBlockedText, DepositGateTexts.registerLedgerFix);
      source.state = _state();
      expect((await api.findPlan(p.planId))!.registerBlockedText, isNull);
    });
  });

  group('estimateCosts · 동결 창구', () {
    test('estimateCosts = 저장본 비용 · 없는 planId = 에러', () async {
      final DepositPlan p = (await api.simulateDeposit(amountInput: '100000'))
          .plan!;
      expect(await api.estimateCosts(p.planId), p.costs);
      await expectLater(api.estimateCosts('pl_none'), throwsStateError);
    });

    test(
      'simulateWithdrawal(인출 규칙 결정 뒤) · previewRebalance(E7a3) 는 아직 에러',
      () async {
        await expectLater(
          api.simulateWithdrawal(amount: Decimal.one),
          throwsUnimplementedError,
        );
        await expectLater(api.previewRebalance(), throwsUnimplementedError);
      },
    );
  });
}
