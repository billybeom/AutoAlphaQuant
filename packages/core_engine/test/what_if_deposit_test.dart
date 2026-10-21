// E7a2-2 — 입금 미리보기 계산(06 M3-1 · 01 §14-3~§14-5 · 설계 13 §8 R18 D-1 · D-7 · D-8 · D-15).
//
// 🔵 시나리오 행렬의 출력 전부에 E7a0 판정 함수(C-38 ①~⑧ · ③ 은 목록 전체)를 건다 — 픽스처와 같은 판정.
// 🔵 금액은 손으로 셀 수 있는 값으로 맞댄다(목표 = 비중 × (평가 합 + 입금) · 부족분 큰 순 · B 먼저 · 원 미만 버림).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

const Set<String> _pension = <String>{'연금저축'};
const Set<String> _all = <String>{'연금저축', '일반'};

WhatIfState _state({
  String a = '2000000',
  String b = '4000000',
  String c = '4000000',
  String used = '0',
  String? parkingPrice = '10450',
  Set<String> unknown = const <String>{},
  List<BlockFlag> flags = const <BlockFlag>[],
}) => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: flags,
  recovery: false,
  accounts: const WhatIfAccounts(pensionAlias: '연금저축', generalAlias: '일반'),
  pensionUsedThisYear: _d(used),
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  sleeveValues: <SleeveId, Decimal>{
    SleeveId.a: _d(a),
    SleeveId.b: _d(b),
    SleeveId.c: _d(c),
  },
  prices: <String, Decimal>{
    if (parkingPrice != null) '214980': _d(parkingPrice),
  },
  unknownSymbols: unknown,
);

BlockFlag _flag(String id) => BlockFlag.fromJson(<String, Object?>{
  'flag_id': id,
  'label': '$id 플래그',
  'set_at': '2026-08-28T01:00:00Z',
  'clear_route': 'WIZARD_ONLY',
  'clear_instruction': '해소 안내',
});

final DateTime _now = DateTime.utc(2026, 8, 31, 21, 5);

DepositPreviewResult _run(WhatIfState s, String input) =>
    simulateDepositPreview(
      s,
      input,
      WhatIfConfig.defaults,
      planId: 'pl_20260901_01',
      computedAt: _now,
    );

Map<SleeveId, Decimal> _shares(DepositPlan p) => <SleeveId, Decimal>{
  for (final SleeveAllocation a in p.allocations) a.sleeve: a.amount,
};

void main() {
  /// 시나리오 행렬 — (이름, 상태, 입력).
  final List<(String, WhatIfState, String)> matrix =
      <(String, WhatIfState, String)>[
        ('기본 — B 부족분이 입금보다 크다', _state(), '100,000'),
        ('한도 소진 — B 제외', _state(used: '18000000'), '100000'),
        ('한도 일부 — B 는 남은 한도까지', _state(used: '17950000'), '100000'),
        (
          '목표대로 — 모든 슬리브가 비중만큼',
          _state(a: '2000000', b: '4200000', c: '3800000'),
          '1,000,000',
        ),
        ('원 미만 버림 — 잔여 1원', _state(a: '1000001', b: '0', c: '0'), '1000003'),
        ('파킹 1주도 못 산다', _state(parkingPrice: '104500'), '100000'),
        ('체결 확인 중', _state(unknown: <String>{'214980'}), '100000'),
        (
          '잔고 대조 중 — 등록 불가',
          _state(flags: <BlockFlag>[_flag(FlagIds.reconMismatch)]),
          '100000',
        ),
        (
          '표 밖 플래그는 영향 없음',
          _state(flags: <BlockFlag>[_flag(FlagIds.journalMissing)]),
          '100000',
        ),
        ('수수료까지 넣어 1주 줄인다', _state(parkingPrice: '10000'), '100000'),
        ('한도 소진 · B 목표 초과', _state(b: '5000000', used: '18000000'), '100000'),
        ('세액공제 구간만 채움', _state(used: '8990000'), '100000'),
        ('세액공제 구간을 정확히 채움', _state(used: '8900000'), '100000'),
        ('시스템 밖 납입으로 한도 초과', _state(used: '18500000'), '100000'),
      ];

  late final Map<String, DepositPlan> plans;
  setUpAll(() {
    plans = <String, DepositPlan>{
      for (final (String n, WhatIfState s, String input) in matrix)
        n: _run(s, input).plan!,
    };
  });

  test('C-38 ①~⑧ — 시나리오 출력 전부가 판정 함수를 통과한다(③ = 목록 전체 · ⑦ = 엔진 계좌 매핑)', () {
    final List<String> bad = <String>[
      for (final (String n, WhatIfState s, String input) in matrix) ...<String>[
        ...depositPreviewResultViolations(n, _run(s, input)),
        ...depositPlanViolations(
          n,
          plans[n]!,
          pensionAliases: _pension,
          allAliases: _all,
        ),
      ],
      ...depositPreviewNoticeViolations(<(String, DepositPlan)>[
        for (final MapEntry<String, DepositPlan> e in plans.entries)
          (e.key, e.value),
      ]),
    ];
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('갈래 표본 — 초안 있음 · 빈 초안 · 잔여 0 · 잔여 있음 · 등록 불가 · 체결 확인 중이 행렬에 다 있다', () {
    final Iterable<DepositPlan> ps = plans.values;
    expect(ps.where((DepositPlan p) => p.orderDrafts.isNotEmpty), isNotEmpty);
    expect(ps.where((DepositPlan p) => p.ordersEmptyText != null), isNotEmpty);
    expect(
      ps.where((DepositPlan p) => p.residualKrwCashText == null),
      isNotEmpty,
    );
    expect(
      ps.where((DepositPlan p) => p.residualKrwCashText != null),
      isNotEmpty,
    );
    expect(
      ps.where((DepositPlan p) => p.registerBlockedText != null),
      isNotEmpty,
    );
    expect(
      ps
          .expand((DepositPlan p) => p.orderDrafts)
          .where((OrderDraft o) => o.pendingNoteText != null),
      isNotEmpty,
    );
  });

  group('D-1 «대기 자리» — 배분은 03 §5-5b · 초안은 B 파킹 매수만', () {
    test(
      '기본 — 목표 = 비중 × 1,010만 · B 부족 24만 2천 > 입금 → B 가 10만 전부 · 파킹 9주 · 수수료 14원',
      () {
        final DepositPlan p = plans['기본 — B 부족분이 입금보다 크다']!;
        expect(_shares(p), <SleeveId, Decimal>{SleeveId.b: _d('100000')});
        expect(p.residualKrwCash, Decimal.zero);
        final OrderDraft o = p.orderDrafts.single;
        expect(o.symbol, '214980');
        expect(o.symbolLabel, '214980 KODEX 단기채권PLUS');
        expect(o.accountAlias, '연금저축');
        expect(o.side, OrderSide.buy);
        expect(
          o.quantity,
          9,
        ); // 9 × 10,450 = 94,050 · 수수료 14 → 94,064 ≤ 100,000
        expect(o.limitPrice, _d('10450'));
        expect(p.costs.commission, _d('14'));
        expect(p.costs.total, _d('14'));
        expect(p.costs.totalText, '약 14원');
        expect(p.pensionLimitConsumed, _d('100000'));
        expect(
          p.pensionLimit!.annualLimitText,
          '올해 연금 합산 납입한도 1,800만원 가운데 10만원을 썼습니다(이번 입금 포함).',
        );
        expect(
          p.pensionLimit!.taxCreditText,
          '세액공제 대상 구간 900만원 가운데 10만원을 채웠습니다.',
        );
        expect(p.pensionLimit!.deadlineText, '올해 납입 마감(12월 31일)까지 122일 남았습니다.');
        expect(p.pensionLimit!.suggestionText, isNull);
        expect(p.fundingSteps, isNull, reason: 'D-15');
        expect(p.warningLines, isEmpty);
      },
    );

    test('한도 소진 — B 제외 · A 부족 2만 · C 는 목표 초과 → 잔여 8만 · 초안 0 · 경고 · 제안', () {
      final DepositPlan p = plans['한도 소진 — B 제외']!;
      expect(_shares(p), <SleeveId, Decimal>{SleeveId.a: _d('20000')});
      expect(p.residualKrwCash, _d('80000'));
      expect(p.residualKrwCashText, '8만원은 원화 현금으로 대기합니다(다음 리밸런싱 재원).');
      expect(p.orderDrafts, isEmpty);
      expect(p.ordersEmptyText, DepositPlanTexts.ordersEmpty);
      expect(p.costs.totalText, DepositPlanTexts.costNone);
      expect(p.warningLines, <String>[DepositPlanTexts.quotaExhausted]);
      expect(
        p.pensionLimit!.annualLimitText,
        '올해 연금 합산 납입한도 1,800만원을 모두 썼습니다.',
      );
      expect(p.pensionLimit!.taxCreditText, '세액공제 대상 구간 900만원도 모두 채웠습니다.');
      expect(
        p.pensionLimit!.suggestionText,
        DepositPlanTexts.suggestionGeneral,
      );
      expect(p.allocations.single.accountAlias, '일반');
    });

    test('한도 일부 — B 는 남은 5만까지 · 나머지 5만 중 A 부족 2만 · 잔여 3만', () {
      final DepositPlan p = plans['한도 일부 — B 는 남은 한도까지']!;
      expect(_shares(p), <SleeveId, Decimal>{
        SleeveId.b: _d('50000'),
        SleeveId.a: _d('20000'),
      });
      expect(p.residualKrwCash, _d('30000'));
      expect(p.pensionLimitConsumed, _d('18000000'));
      expect(
        p.orderDrafts.single.quantity,
        4,
      ); // 4 × 10,450 = 41,800 + 6 ≤ 50,000
      expect(p.warningLines, isEmpty, reason: 'B 를 채웠다 — 소진 경고는 B 가 통째로 빠질 때만');
      // 이번 입금으로 한도를 정확히 다 썼다 — «모두 썼습니다» · 세액공제 구간도.
      expect(
        p.pensionLimit!.annualLimitText,
        '올해 연금 합산 납입한도 1,800만원을 모두 썼습니다.',
      );
      expect(p.pensionLimit!.taxCreditText, '세액공제 대상 구간 900만원도 모두 채웠습니다.');
      expect(p.pensionLimit!.suggestionText, isNull);
    });

    test('목표대로 — 부족분 = 비중 × 입금 · 잔여 0 · 잔여 글자 없음 · 슬리브 순서 A·B·C', () {
      final DepositPlan p = plans['목표대로 — 모든 슬리브가 비중만큼']!;
      expect(p.allocations.map((SleeveAllocation a) => a.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.b,
        SleeveId.c,
      ]);
      expect(_shares(p), <SleeveId, Decimal>{
        SleeveId.a: _d('200000'),
        SleeveId.b: _d('420000'),
        SleeveId.c: _d('380000'),
      });
      expect(p.residualKrwCash, Decimal.zero);
      expect(p.residualKrwCashText, isNull);
      expect(p.orderDrafts.map((OrderDraft o) => o.sleeve).toSet(), <SleeveId>{
        SleeveId.b,
      }, reason: 'A·C 몫은 원화 대기 — 초안은 B 파킹뿐');
      expect(
        p.allocations
            .firstWhere((SleeveAllocation a) => a.sleeve == SleeveId.a)
            .routingReasonText,
        DepositPlanTexts.routingA,
      );
      expect(
        p.allocations
            .firstWhere((SleeveAllocation a) => a.sleeve == SleeveId.c)
            .routingReasonText,
        DepositPlanTexts.routingC,
      );
    });

    test(
      '원 미만 버림 — B 84만 1.68 → 84만 1 · C 16만 1.32 → 16만 1 · 잔여 1원 · 합 = 입금액',
      () {
        final DepositPlan p = plans['원 미만 버림 — 잔여 1원']!;
        expect(_shares(p), <SleeveId, Decimal>{
          SleeveId.b: _d('840001'),
          SleeveId.c: _d('160001'),
        });
        expect(p.residualKrwCash, Decimal.one);
        expect(p.residualKrwCashText, '1원은 원화 현금으로 대기합니다(다음 리밸런싱 재원).');
      },
    );

    test(
      '수수료까지 넣어 1주 줄인다 — 10주 = 10만 + 수수료 15 > 10만 → 9주 · 수수료 13.5 → 13(버림)',
      () {
        final DepositPlan p = plans['수수료까지 넣어 1주 줄인다']!;
        expect(p.orderDrafts.single.quantity, 9);
        expect(p.costs.commission, _d('13'));
      },
    );

    test('한도 소진이어도 B 가 목표 초과면 «채우지 못한다» 경고 · 제안을 내지 않는다', () {
      final DepositPlan p = plans['한도 소진 · B 목표 초과']!;
      expect(_shares(p).containsKey(SleeveId.b), isFalse);
      expect(p.warningLines, isEmpty);
      expect(p.pensionLimit!.suggestionText, isNull);
    });

    test('세액공제 구간만 채움 — 연 한도는 남고 세액공제 900만은 «모두 채웠습니다»', () {
      final DepositPlan p = plans['세액공제 구간만 채움']!;
      expect(p.pensionLimitConsumed, _d('9090000'));
      expect(
        p.pensionLimit!.annualLimitText,
        '올해 연금 합산 납입한도 1,800만원 가운데 909만원을 썼습니다(이번 입금 포함).',
      );
      expect(p.pensionLimit!.taxCreditText, '세액공제 대상 구간 900만원을 모두 채웠습니다.');
    });

    test('경계 — 세액공제 900만을 정확히 채우면 «모두» · 누계가 한도를 넘어도(시스템 밖 납입) 계산은 한다', () {
      final DepositPlan exact = plans['세액공제 구간을 정확히 채움']!;
      expect(exact.pensionLimitConsumed, _d('9000000'));
      expect(exact.pensionLimit!.taxCreditText, '세액공제 대상 구간 900만원을 모두 채웠습니다.');
      final DepositPlan over = plans['시스템 밖 납입으로 한도 초과']!;
      expect(_shares(over).containsKey(SleeveId.b), isFalse);
      expect(over.warningLines, <String>[DepositPlanTexts.quotaExhausted]);
      expect(
        over.pensionLimit!.annualLimitText,
        '올해 연금 합산 납입한도 1,800만원을 모두 썼습니다.',
      );
    });

    test('파킹 1주도 못 사면 초안 0 · B 몫은 연금 계좌에 원화로 남는다', () {
      final DepositPlan p = plans['파킹 1주도 못 산다']!;
      expect(_shares(p)[SleeveId.b], _d('100000'));
      expect(p.orderDrafts, isEmpty);
      expect(p.ordersEmptyText, isNotNull);
      expect(p.costs.total, Decimal.zero);
    });

    test('체결 확인 중 · 잔고 대조 중 · 표 밖 플래그', () {
      expect(
        plans['체결 확인 중']!.orderDrafts.single.pendingNoteText,
        DepositPlanTexts.pending,
      );
      expect(
        plans['기본 — B 부족분이 입금보다 크다']!.orderDrafts.single.pendingNoteText,
        isNull,
      );
      expect(
        plans['잔고 대조 중 — 등록 불가']!.registerBlockedText,
        DepositGateTexts.registerRecon,
      );
      expect(plans['표 밖 플래그는 영향 없음']!, plans['기본 — B 부족분이 입금보다 크다']!);
    });
  });

  group('계획 머리 · 글자 · 왕복', () {
    test('id · 계산 시각 · 만료(+24h) · 기준일 고지 · 고지 문장 · 제목', () {
      final DepositPlan p = plans['기본 — B 부족분이 입금보다 크다']!;
      expect(p.planId, 'pl_20260901_01');
      expect(p.computedAt, _now);
      expect(p.expiresAt, _now.add(const Duration(hours: 24)));
      expect(p.asOfTradeDate, const TradeDate('2026-08-31'));
      expect(p.configHash, 'cfg_test');
      expect(p.asOf.label, '계획 기준 2026-08-31 종가');
      expect(p.asOf.staleAfter, const Duration(seconds: 93600));
      expect(p.asOf.source, AsOfSource.localSqlite);
      expect(p.previewNotice, DepositPlanTexts.previewNotice);
      expect(p.orderDraftsTitle, '주문 초안');
      expect(p.depositAmountText, '10만원');
    });

    test('원값 ↔ 글자 · 사유 칩 · JSON 왕복(C-8) — 행렬 전부', () {
      for (final MapEntry<String, DepositPlan> e in plans.entries) {
        final DepositPlan p = e.value;
        expect(p.depositAmountText, wonText(p.depositAmount), reason: e.key);
        for (final SleeveAllocation a in p.allocations) {
          expect(a.amountText, wonText(a.amount), reason: e.key);
          expect(a.label, isNotEmpty);
        }
        for (final OrderDraft o in p.orderDrafts) {
          expect(o.quantityText, sharesText(o.quantity), reason: e.key);
          expect(o.limitPriceText, commaWonText(o.limitPrice!), reason: e.key);
          expect(o.reasons.single.code, PlannerReasonCodes.depositRouting);
        }
        expect(
          DepositPlan.fromJson(p.toJson()),
          p,
          reason: '${e.key} — JSON 왕복',
        );
      }
    });

    test('부작용 0 — 같은 입력이면 같은 결과 · 상태를 바꾸지 않는다', () {
      final WhatIfState s = _state();
      final Map<SleeveId, Decimal> before = Map<SleeveId, Decimal>.of(
        s.sleeveValues,
      );
      expect(_run(s, '100000'), _run(s, '100000'));
      expect(s.sleeveValues, before);
    });
  });

  group('계산하지 않는 갈래', () {
    test('차단 · 입력 거부는 계획 없이 한 갈래(C-38 ①)', () {
      final DepositPreviewResult blocked = _run(
        _state(flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity)]),
        '100000',
      );
      expect(blocked.plan, isNull);
      expect(blocked.blockedText, DepositGateTexts.integrity);
      final DepositPreviewResult rejected = _run(_state(), '10만');
      expect(rejected.plan, isNull);
      expect(rejected.inputRejectedText, kAmountNotNumberText);
      expect(depositPreviewResultViolations('b', blocked), isEmpty);
      expect(depositPreviewResultViolations('r', rejected), isEmpty);
    });

    test(
      '계산을 못 하는 상태는 StateError(Future 에러 = 인프라) — 파킹 가격 없음 · 슬리브 집합 불일치',
      () {
        expect(
          () => _run(_state(parkingPrice: null), '100000'),
          throwsStateError,
        );
        expect(
          () => _run(_state(parkingPrice: '0'), '100000'),
          throwsStateError,
        );
        final WhatIfState s = _state();
        final WhatIfState missingC = WhatIfState(
          asOfTradeDate: s.asOfTradeDate,
          configHash: s.configHash,
          activeFlags: s.activeFlags,
          recovery: s.recovery,
          accounts: s.accounts,
          pensionUsedThisYear: s.pensionUsedThisYear,
          observedAt: s.observedAt,
          source: s.source,
          sleeveValues: <SleeveId, Decimal>{
            SleeveId.a: _d('1'),
            SleeveId.b: _d('1'),
          },
          prices: s.prices,
        );
        expect(() => _run(missingC, '100000'), throwsStateError);
        // B 몫이 0 이면 파킹 가격이 없어도 계산한다(사지 않으니까).
        expect(
          _run(_state(used: '18000000', parkingPrice: null), '100000').plan,
          isNotNull,
        );
      },
    );

    test('설정 — 목표 비중 합이 1 이 아니면 거부', () {
      expect(
        () => WhatIfConfig(
          planTtl: const Duration(hours: 1),
          pensionAnnualLimit: Decimal.one,
          taxCreditBand: Decimal.one,
          depositMin: Decimal.one,
          depositMax: Decimal.one,
          targetWeights: <SleeveId, Decimal>{
            SleeveId.a: _d('0.5'),
            SleeveId.b: _d('0.4'),
          },
        ),
        throwsArgumentError,
      );
    });
  });
}
