// E7a3-2 — 리밸런싱 미리보기 단위 시험(01 §15-4 · 설계 13 §8 R18 D-8 · D-9 · D-10 · D-11).
// 26년 재현 대조는 `replay/replay_rebalance_preview_test.dart` 몫 — 여기는 손으로 지은 상태로 경계를 본다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

/// 2026-08-03 ~ 2026-09-30 의 평일(휴장 없음).
ExchangeCalendar _kr() {
  final List<TradeDate> sessions = <TradeDate>[];
  for (
    DateTime t = DateTime.utc(2026, 8, 3);
    !t.isAfter(DateTime.utc(2026, 9, 30));
    t = t.add(const Duration(days: 1))
  ) {
    if (t.weekday <= 5) {
      sessions.add(TradeDate(t.toIso8601String().substring(0, 10)));
    }
  }
  return ExchangeCalendar(
    market: Market.kr,
    sessions: sessions,
    coverageStart: const TradeDate('2026-08-01'),
    coverageEnd: const TradeDate('2026-09-30'),
  );
}

BlockFlag _flag(String id, {String? link}) =>
    BlockFlag.fromJson(<String, Object?>{
      'flag_id': id,
      'label': '$id 플래그',
      'set_at': '2026-08-28T01:00:00Z',
      'clear_route': 'WIZARD_ONLY',
      'clear_instruction': '해소 안내',
      'clear_deep_link': link,
    });

/// 월말 계획기 입력 — 기본: 총자산 1억 · B 파킹 4,200만(자산 0) · 월봉 12개 오름(B·POT 비율 1) ·
/// C 는 목표대로(원화 530만 · 채권 2,470만 = 65% · 금 800만 = 총자산 8% 상한) — C 주문 0.
MonthEndState _me({
  int month = 12,
  String bPark = '42000000',
  String krw = '5300000',
  String bond = '24700000',
  String? gold = '8000000',
  bool rising = true,
  String parkC = '0',
}) => MonthEndState(
  totalEquity: _d('100000000'),
  bAssets: <String, Decimal?>{'133690': Decimal.zero, '411060': Decimal.zero},
  bParking: _d(bPark),
  bParkingReclassified: _d(parkC),
  krwCash: _d(krw),
  reservedKrw: Decimal.zero,
  cBond: _d(bond),
  cGold: gold == null ? null : _d(gold),
  potCash: Decimal.zero,
  potAssets: const <String, Decimal?>{'133690': null, '411060': null},
  pensionUsedThisYear: Decimal.zero,
  monthIndex: month,
  regimeState: DirectionState.neutral,
  monthlyCloses: <String, List<double>>{
    for (final String t in <String>['133690', '411060'])
      t: <double>[for (int k = 1; k <= 12; k++) rising ? 100.0 + k : 100.0],
  },
  hasNextKrSession: true,
  hasNextUsSession: true,
);

WhatIfState _s({
  MonthEndState? me,
  List<BlockFlag> flags = const <BlockFlag>[],
  bool recovery = false,
  bool calendar = true,
  Set<String> unknown = const <String>{},
  Map<String, Decimal>? prices,
}) => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: flags,
  recovery: recovery,
  accounts: const WhatIfAccounts(pensionAlias: '연금저축', generalAlias: '일반'),
  pensionUsedThisYear: Decimal.zero,
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  sleeveValues: const <SleeveId, Decimal>{},
  prices:
      prices ??
      <String, Decimal>{
        '133690': _d('16380'),
        '411060': _d('8940'),
        '0085P0': _d('10250'),
      },
  unknownSymbols: unknown,
  monthEnd: me ?? _me(),
  krCalendar: calendar ? _kr() : null,
);

RebalancePreviewResult _run(WhatIfState s, {TradeDate? planned}) =>
    previewRebalancePlan(
      s,
      WhatIfConfig.defaults,
      planned: plannedRebalanceDate(s, planned),
      planId: 'pv_re_20260901_01',
    );

void main() {
  group('다음 정기 회차(D-9 — 월말 판정 다음 세션 · watchNext 와 같은 함수)', () {
    test('월중 · 월말 당일 · 주말 → 판정 08-31 · 회차 09-01 · 달력 끝을 넘으면 null', () {
      final ExchangeCalendar kr = _kr();
      for (final String asOf in <String>[
        '2026-08-14',
        '2026-08-31',
        '2026-08-29',
      ]) {
        final NextRebalance n = nextRegularRebalance(kr, TradeDate(asOf))!;
        expect(n.judgment, const TradeDate('2026-08-31'), reason: asOf);
        expect(n.planned, const TradeDate('2026-09-01'), reason: asOf);
      }
      expect(
        nextRegularRebalance(kr, const TradeDate('2026-09-15')),
        isNull,
        reason: '9월 말 다음 세션이 범위 밖',
      );
      expect(
        nextRegularRebalance(kr, const TradeDate('2026-12-01')),
        isNull,
        reason: '범위 밖',
      );
    });
  });

  group('관문(H64 · D-10)', () {
    test('달력 없음 = 예정 없음 · 무결성 = 복구 위저드 버튼 · 복구 모드 — 정확히 한 갈래', () {
      final List<RebalancePreviewResult> rs = <RebalancePreviewResult>[
        _run(_s(calendar: false)),
        _run(
          _s(
            flags: <BlockFlag>[
              _flag(FlagIds.ledgerIntegrity, link: 'aaq://x5/repair-wizard'),
            ],
          ),
        ),
        _run(_s(recovery: true)),
      ];
      expect(rs.map((RebalancePreviewResult r) => r.blockedText), <String>[
        RebalanceGateTexts.noPlannedDate,
        RebalanceGateTexts.integrity,
        RebalanceGateTexts.recovery,
      ]);
      expect(rs[1].blockedAction!.deepLink, 'aaq://x5/repair-wizard');
      for (final RebalancePreviewResult r in rs) {
        expect(rebalancePreviewResultViolations('r', r), isEmpty);
      }
    });

    test('RECON · LEDGER_FIX 는 초안을 내고 경고 줄', () {
      final RebalancePreview p = _run(
        _s(
          flags: <BlockFlag>[
            _flag(FlagIds.reconMismatch),
            _flag(FlagIds.ledgerFix),
          ],
        ),
      ).preview!;
      expect(
        p.warningLines,
        containsAll(<String>[
          RebalanceGateTexts.warnRecon,
          RebalanceGateTexts.warnLedgerFix,
        ]),
      );
    });

    test('계산할 수 없는 상태 — 월말 계획기 입력 없음 · 초안 종목 가격 없음 = StateError', () {
      final WhatIfState noInput = WhatIfState(
        asOfTradeDate: const TradeDate('2026-08-31'),
        configHash: 'cfg',
        activeFlags: const <BlockFlag>[],
        recovery: false,
        accounts: const WhatIfAccounts(
          pensionAlias: '연금저축',
          generalAlias: '일반',
        ),
        pensionUsedThisYear: Decimal.zero,
        observedAt: DateTime.utc(2026, 8, 31),
        source: AsOfSource.localSqlite,
        sleeveValues: const <SleeveId, Decimal>{},
        prices: const <String, Decimal>{},
        krCalendar: _kr(),
      );
      expect(() => _run(noInput), throwsStateError);
      expect(
        () => _run(_s(prices: const <String, Decimal>{})),
        throwsStateError,
      );
    });
  });

  group('초안 · 글자', () {
    test('B 신호 — 월봉 오름(비율 1) · 파킹 4,200만 → 133690 매수 2,051주 · 411060 매수 939주 · 다음 회차 09-01', () {
      final RebalancePreview p = _run(_s()).preview!;
      expect(p.plannedDate, const TradeDate('2026-09-01'));
      expect(p.plannedDateText, '2026년 9월 1일 회차');
      expect(p.asOf.label, '초안 기준 2026-08-31 종가');
      final List<(String, OrderSide, int)> drafts = <(String, OrderSide, int)>[
        for (final OrderDraft o in p.orderDrafts)
          (o.symbol, o.side, o.quantity),
      ];
      // 4,200만 × 0.8 = 3,360만 ÷ 16,380 = 2,051.28 · 4,200만 × 0.2 = 840만 ÷ 8,940 = 939.6
      expect(drafts, <(String, OrderSide, int)>[
        ('133690', OrderSide.buy, 2051),
        ('411060', OrderSide.buy, 939),
      ]);
      expect(
        p.orderDrafts.first.reasons.single.code,
        RebalanceReasonCodes.sleeveBSignal,
      );
      expect(p.orderDrafts.first.accountAlias, '연금저축');
      expect(p.orderDrafts.first.limitPriceText, '16,380원');
      expect(p.costs.totalText, startsWith('약 '));
      expect(p.previewNotice, RebalancePreviewTexts.previewNotice);
      expect(
        rebalancePreviewViolations(
          'p',
          p,
          asOf: p.asOf,
          pensionAliases: const <String>{'연금저축'},
          allAliases: const <String>{'연금저축', '일반'},
        ),
        isEmpty,
      );
    });

    test('평탄 월봉(기본 비율 0) — P0S 하한 1/3 이 걸려 B 목표 = B 의 1/3 · 133690 683주 · 411060 313주(코어 밴드 안)', () {
      final RebalancePreview p = _run(_s(me: _me(rising: false))).preview!;
      // 4,200만 × 0.8 ÷ 3 = 1,120만 ÷ 16,380 = 683.8 · 4,200만 × 0.2 ÷ 3 = 280만 ÷ 8,940 = 313.2
      expect(
        <(String, int)>[
          for (final OrderDraft o in p.orderDrafts)
            if (o.sleeve == SleeveId.b) (o.symbol, o.quantity),
        ],
        <(String, int)>[('133690', 683), ('411060', 313)],
      );
    });

    test('빈 초안 — 목표대로면 빈 초안 문장 · 비용 없음 · 가격 움직임 경고', () {
      // B: 자산 0 · 파킹 0 · 비율 0(월봉 없음) → 목표 0 · C: 채권 = 65% · 금 0(가격 없음) …
      final MonthEndState me = MonthEndState(
        totalEquity: _d('100000000'),
        bAssets: const <String, Decimal?>{'133690': null, '411060': null},
        bParking: _d('42000000'),
        bParkingReclassified: Decimal.zero,
        krwCash: _d('13300000'),
        reservedKrw: Decimal.zero,
        cBond: _d('24700000'),
        cGold: null,
        potCash: Decimal.zero,
        potAssets: const <String, Decimal?>{'133690': null, '411060': null},
        pensionUsedThisYear: Decimal.zero,
        monthIndex: 12,
        regimeState: DirectionState.neutral,
        monthlyCloses: const <String, List<double>>{},
        hasNextKrSession: true,
        hasNextUsSession: true,
      );
      final RebalancePreview p = _run(_s(me: me)).preview!;
      expect(p.orderDrafts, isEmpty);
      expect(p.ordersEmptyText, RebalancePreviewTexts.ordersEmpty);
      expect(p.costs.totalText, RebalancePreviewTexts.costNone);
      expect(p.warningLines, contains(RebalancePreviewTexts.warnEmpty));
      expect(p.fundingSteps, isNull);
    });

    test('램프 납입이 있으면 «연금저축으로 … 납입이 함께 필요합니다» 줄', () {
      final RebalancePreview p = _run(
        _s(
          me: _me(month: 1, bPark: '0', krw: '20000000'),
        ),
      ).preview!;
      expect(
        p.warningLines.where(
          (String l) => l.contains('연금저축으로 700만원 납입이 함께 필요합니다'),
        ),
        hasLength(1),
      );
    });

    test(
      '원화 조달(램프 납입 재원)은 매도 초안 + fundingSteps(순서 1 · 대금 > 0 · 근거 03 §5-5b)',
      () {
        final RebalancePreview p = _run(
          _s(
            me: _me(month: 1, bPark: '0', krw: '0', gold: '20000000'),
            prices: <String, Decimal>{
              '133690': _d('16380'),
              '411060': _d('8940'),
              '0085P0': _d('10250'),
            },
          ),
        ).preview!;
        final List<FundingStep> f = p.fundingSteps!;
        expect(f.first.order, 1);
        expect(f.first.expectedProceeds > Decimal.zero, isTrue);
        expect(f.first.ruleCited, '03 §5-5b');
        expect(
          p.orderDrafts.where(
            (OrderDraft o) =>
                o.reasons.single.code == LedgerEventCodes.pensionFunding,
          ),
          isNotEmpty,
        );
      },
    );

    test('체결 확인 중인 종목의 초안에 pendingNoteText', () {
      final RebalancePreview p = _run(_s(unknown: <String>{'133690'})).preview!;
      expect(
        p.orderDrafts
            .firstWhere((OrderDraft o) => o.symbol == '133690')
            .pendingNoteText,
        RebalancePreviewTexts.pending,
      );
      expect(
        p.orderDrafts
            .firstWhere((OrderDraft o) => o.symbol == '411060')
            .pendingNoteText,
        isNull,
      );
    });

    test('전후 비중 — 회계 기준 A·B·C 세 줄 · 밴드는 B 에만(상단 초과 · 여유 문장)', () {
      final RebalancePreview over = _run(
        _s(
          me: _me(bPark: '47800000', krw: '0', bond: '24200000'),
        ),
      ).preview!;
      final SleeveWeight b = over.before.firstWhere(
        (SleeveWeight w) => w.sleeve == SleeveId.b,
      );
      expect(b.label, 'B 47.8% (목표 42.0%, 편차 +5.8%p, 밴드 상단 2.8%p 초과)');
      final SleeveWeight a = over.before.firstWhere(
        (SleeveWeight w) => w.sleeve == SleeveId.a,
      );
      expect(a.label, 'A 20.0% (목표 20.0%, 편차 0.0%p)');
      expect(over.before.map((SleeveWeight w) => w.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.b,
        SleeveId.c,
      ]);
      final RebalancePreview inBand = _run(_s()).preview!;
      expect(
        inBand.before
            .firstWhere((SleeveWeight w) => w.sleeve == SleeveId.b)
            .label,
        'B 42.0% (목표 42.0%, 편차 0.0%p, 밴드 여유 3.0%p)',
      );
      expect(
        inBand.before
            .firstWhere((SleeveWeight w) => w.sleeve == SleeveId.c)
            .label,
        'C 38.0% (목표 38.0%, 편차 0.0%p)',
      );
    });
  });

  group('경계 — 0주 · 재분류 파킹 · 이동 뒤 비중', () {
    test('금액이 1주 값보다 작으면 초안에서 뺀다(0주 초안 없음)', () {
      final RebalancePreview p = _run(
        _s(
          prices: <String, Decimal>{
            '133690': _d('40000000'),
            '411060': _d('8940'),
            '0085P0': _d('10250'),
          },
        ),
      ).preview!;
      expect(p.orderDrafts.map((OrderDraft o) => o.symbol), <String>['411060']);
      expect(p.orderDrafts.every((OrderDraft o) => o.quantity > 0), isTrue);
    });

    test('재분류 파킹은 C 로 센다(같은 연금 계좌지만 회계 기준 C)', () {
      // B 파킹 4,200만 · 재분류 파킹 500만 · C 원화 30만 · 채권 2,470만 · 금 800만 → C = 3,800만.
      final RebalancePreview p = _run(
        _s(
          me: _me(krw: '300000', parkC: '5000000'),
        ),
      ).preview!;
      expect(
        p.before.firstWhere((SleeveWeight w) => w.sleeve == SleeveId.c).label,
        startsWith('C 38.0% '),
      );
      expect(
        p.before.firstWhere((SleeveWeight w) => w.sleeve == SleeveId.a).label,
        startsWith('A 20.0% '),
      );
    });

    test('이동 뒤 비중(after)은 당일 이체를 반영한다 — 램프 납입 700만이면 B 0% → 7%', () {
      final RebalancePreview p = _run(
        _s(
          me: _me(month: 1, bPark: '0', krw: '20000000'),
        ),
      ).preview!;
      double w(List<SleeveWeight> ws) =>
          ws.firstWhere((SleeveWeight x) => x.sleeve == SleeveId.b).weight;
      expect(w(p.before), 0.0);
      expect(w(p.after), closeTo(0.07, 1e-12));
    });
  });

  group('EngineWhatIfApi.previewRebalance', () {
    test(
      '회차별 순번 planId(pv_re_20260901_01 · 02) · 결과 캐시 0 · plannedDate 를 주면 그날',
      () async {
        final InMemoryPlanSnapshotStore store = InMemoryPlanSnapshotStore();
        final EngineWhatIfApi api = EngineWhatIfApi(
          source: _FixedSource(_s()),
          store: store,
          clock: _Clock(),
        );
        expect(
          (await api.previewRebalance()).preview!.planId,
          'pv_re_20260901_01',
        );
        expect(
          (await api.previewRebalance()).preview!.planId,
          'pv_re_20260901_02',
        );
        final RebalancePreview later = (await api.previewRebalance(
          plannedDate: const TradeDate('2026-09-02'),
        )).preview!;
        expect(later.plannedDate, const TradeDate('2026-09-02'));
        expect(later.planId, 'pv_re_20260902_01');
        expect(
          await store.find('pv_re_20260901_01'),
          isNull,
          reason: '결과를 저장하지 않는다',
        );
      },
    );
  });
}

class _FixedSource implements WhatIfStateSource {
  _FixedSource(this.s);
  final WhatIfState s;
  @override
  Future<WhatIfState> load() async => s;
}

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 31, 21);
}
