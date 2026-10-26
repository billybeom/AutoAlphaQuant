// E8b2 — 판정·조립(설계 13 §8 R23 D4 · D5 · D6 · D13 · R24 B2·B3).
//
// 🔵 잡는 것: ① KR 결측(행 없음 · 종가 ≤ 0 · 거래량 < 0 · |변동| ≥ 60%) → 그날 계획 중단 · 전 종목 공백 = 캘린더 의심
//    ② 월말 판정 시점 — 미국 그날 세션 종가가 들어온 뒤에만(휴장이면 바로) ③ 신선도 상한 — 일간 세션 · 주간·월간
//    달력일 · «아직 없음»은 낡음이 아니다 ④ D5 — 국면 UNKNOWN 월말은 B 트랜치 보류(보조가 켜졌을 때만 · null 은 그대로)
//    · 미리보기에 경고 줄.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

/// 2026-08-31(월) ~ 09-08(화) — 09-05·06 주말.
ExchangeCalendar _cal(Market m) => ExchangeCalendar(
  market: m,
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

Map<String, KrBar> _bars(Map<String, double> closes) => <String, KrBar>{
  for (final MapEntry<String, double> e in closes.entries)
    e.key: KrBar(close: e.value, volume: 1000),
};

MonthEndState _me(DirectionState? regime) => MonthEndState(
  totalEquity: _d('100000000'),
  bAssets: <String, Decimal?>{'133690': Decimal.zero, '411060': Decimal.zero},
  bParking: _d('42000000'),
  bParkingReclassified: Decimal.zero,
  krwCash: _d('5300000'),
  reservedKrw: Decimal.zero,
  cBond: _d('24700000'),
  cGold: _d('8000000'),
  potCash: Decimal.zero,
  potAssets: const <String, Decimal?>{'133690': null, '411060': null},
  pensionUsedThisYear: Decimal.zero,
  monthIndex: 12,
  regimeState: regime,
  monthlyCloses: <String, List<double>>{
    for (final String t in <String>['133690', '411060'])
      t: <double>[for (int k = 1; k <= 12; k++) 100.0 + k],
  },
  hasNextKrSession: true,
  hasNextUsSession: true,
);

int _bOrders(MonthEndPlan p) => p.actions
    .where((MonthEndAction a) => a.kind == MonthEndActionKind.sleeveBOrder)
    .length;

void main() {
  group('D4 KR 결측 — 하나라도 결측이면 그날 계획을 만들지 않는다', () {
    final ExchangeCalendar kr = _cal(Market.kr);
    const TradeDate day = TradeDate('2026-09-07');
    final Map<String, Map<String, KrBar>> ok = <String, Map<String, KrBar>>{
      '133690': _bars(<String, double>{'2026-09-04': 100, '2026-09-07': 101}),
      '411060': _bars(<String, double>{'2026-09-04': 50, '2026-09-07': 50.5}),
    };

    test('정상 — 진행 · 앞 세션은 주말을 건너뛴 09-04', () {
      final KrDayVerdict v = judgeKrPlanDay(
        day,
        <String>['133690', '411060'],
        ok,
        kr,
      );
      expect(v.proceed, isTrue);
      expect(v.calendarSuspect, isFalse);
    });

    test('행 없음 · 종가 0 · 거래량 음수 · 60% 변동 — 각각 결측', () {
      List<String> causes(Map<String, Map<String, KrBar>> b) => judgeKrPlanDay(
        day,
        <String>['133690', '411060'],
        b,
        kr,
      ).issues.map((DataIssue i) => '${i.key}:${i.cause.wire}').toList();
      expect(
        causes(<String, Map<String, KrBar>>{
          '133690': _bars(<String, double>{'2026-09-04': 100}),
          '411060': ok['411060']!,
        }),
        <String>['133690:MISSING_ROW'],
      );
      expect(
        causes(<String, Map<String, KrBar>>{
          '133690': _bars(<String, double>{'2026-09-04': 100, '2026-09-07': 0}),
          '411060': ok['411060']!,
        }),
        <String>['133690:NON_POSITIVE_PRICE'],
      );
      expect(
        causes(<String, Map<String, KrBar>>{
          '133690': <String, KrBar>{
            '2026-09-04': const KrBar(close: 100, volume: 10),
            '2026-09-07': const KrBar(close: 101, volume: -1),
          },
          '411060': ok['411060']!,
        }),
        <String>['133690:NEGATIVE_VOLUME'],
      );
      expect(
        causes(<String, Map<String, KrBar>>{
          '133690': _bars(<String, double>{
            '2026-09-04': 100,
            '2026-09-07': 160,
          }),
          '411060': ok['411060']!,
        }),
        <String>['133690:PRICE_JUMP'],
      );
      // 59.9% 는 결측이 아니다(상한 미만).
      expect(
        causes(<String, Map<String, KrBar>>{
          '133690': _bars(<String, double>{
            '2026-09-04': 100,
            '2026-09-07': 159.9,
          }),
          '411060': ok['411060']!,
        }),
        isEmpty,
      );
      // 정확히 60% 하락(100 → 40 · double 로 |0.4 − 1| == 0.6)은 결측이다(FR-112 «< 60%» 만 정상).
      expect(
        causes(<String, Map<String, KrBar>>{
          '133690': _bars(<String, double>{
            '2026-09-04': 100,
            '2026-09-07': 40,
          }),
          '411060': ok['411060']!,
        }),
        <String>['133690:PRICE_JUMP'],
      );
    });

    test('전 종목이 함께 비면 «캘린더 의심» — 그래도 중단 · 판정일이 세션이 아니면 StateError', () {
      final KrDayVerdict v = judgeKrPlanDay(
        day,
        <String>['133690', '411060'],
        <String, Map<String, KrBar>>{},
        kr,
      );
      expect(v.proceed, isFalse);
      expect(v.calendarSuspect, isTrue);
      expect(v.issues.last.cause, DataGapCause.calendarSuspect);
      expect(
        () => judgeKrPlanDay(
          const TradeDate('2026-09-05'),
          <String>['133690'],
          ok,
          kr,
        ),
        throwsStateError,
      );
    });
  });

  test('D13 월말 판정 시점 — 미국 그날 세션 종가가 들어온 뒤에만 · 미국 휴장이면 바로', () {
    final ExchangeCalendar us = _cal(Market.us);
    expect(monthEndRegimeReady('2026-08-31', '2026-08-28', us), isFalse);
    expect(monthEndRegimeReady('2026-08-31', '2026-08-31', us), isTrue);
    expect(
      monthEndRegimeReady('2026-09-05', '2026-09-04', us),
      isTrue,
      reason: '미국 휴장일 — 그 앞 값이 최종',
    );
  });

  group('D6 신선도 상한', () {
    final List<String> cal = <String>[
      for (int d = 1; d <= 30; d++) '2026-09-${d.toString().padLeft(2, '0')}',
    ];
    DatedSeries dated(List<String> ds, [double v = 1]) =>
        DatedSeries(ds, <double>[for (final String _ in ds) v]);
    final DatedSeries none = DatedSeries(const <String>[], const <double>[]);
    RegimeSources src({
      DatedSeries? vix,
      DatedSeries? nfci,
      DatedSeries? sahm,
    }) => RegimeSources(
      usDates: cal,
      usClose: <double?>[for (final String _ in cal) 100],
      usHigh: <double?>[for (final String _ in cal) 101],
      usLow: <double?>[for (final String _ in cal) 99],
      usVolume: <double?>[for (final String _ in cal) 1],
      spyAdjClose: dated(cal),
      rspAdjClose: dated(cal),
      vix: vix ?? dated(cal),
      vix3m: dated(cal),
      ofrFsi: dated(cal),
      nfci: nfci ?? dated(cal),
      cfnaiMa3: dated(cal),
      t10y3m: dated(cal),
      sahm: sahm ?? dated(cal),
    );

    test('일간 = 세션 수(5 까지 괜찮다) · 관측 전은 «아직 없음»', () {
      final Map<String, List<String>> st = regimeStaleDays(
        src(vix: dated(<String>['2026-09-03'])),
      );
      // 09-03 관측 → 5세션 뒤 09-08 까지 괜찮고 09-09 부터 낡음. vix_term 도 VIX 로 만든다.
      expect(st['vix_level']!.first, '2026-09-09');
      expect(st['vix_level']!, hasLength(22));
      expect(st['vix_level']!, isNot(contains('2026-09-01')));
      expect(regimeStaleDays(src(vix: none))['vix_level'], isEmpty);
    });

    test('주간 21일 · 월간(발표 지연 뒤) 45일 — 달력일', () {
      final Map<String, List<String>> st = regimeStaleDays(
        src(
          nfci: dated(<String>['2026-08-01']),
          sahm: dated(<String>['2026-07-01']),
        ),
      );
      // nfci: 08-01 + 지연 7 = 08-08 → +21 = 08-29 까지 → 09-01 부터(달력 첫날) 낡음.
      expect(st['nfci']!.first, '2026-09-01');
      // sahm: 07-01 + 지연 40 = 08-10 → +45 = 09-24 까지 → 09-25 부터.
      expect(st['sahm']!.first, '2026-09-25');
      expect(
        const RegimeFreshnessCaps().dailySessions,
        5,
        reason: 'R23 D6 기본값',
      );
    });

    test('상한을 건 원지표 — 낡은 날만 null', () {
      final RegimeSources s = src(vix: dated(<String>['2026-09-03'], 20));
      final Map<String, List<double?>> raw = regimeRawIndicators(s);
      final Map<String, List<double?>> capped = applyFreshnessCaps(s, raw);
      expect(raw['vix_level']![10], isNotNull);
      expect(capped['vix_level']![10], isNull, reason: '09-11 은 낡은 날');
      expect(capped['vix_level']![5], raw['vix_level']![5]);
    });

    test('미국 달력 지연 — 마지막 데이터 뒤 as-of 까지의 미국 세션 수', () {
      final List<String> xnys = <String>[
        '2026-09-01',
        '2026-09-02',
        '2026-09-03',
        '2026-09-04',
        '2026-09-08',
      ];
      expect(usCalendarLagSessions('2026-09-02', '2026-09-08', xnys), 3);
      expect(usCalendarLagSessions('2026-09-08', '2026-09-08', xnys), 0);
    });
  });

  group('D5 국면 UNKNOWN 월말 — B 트랜치 보류', () {
    final MonthEndConfig base = p0sMonthEndConfig();
    test('UNKNOWN 이면 B 주문 0 · 보류 표시 · 다른 슬리브는 그대로', () {
      final MonthEndPlan bull = planMonthEnd(_me(DirectionState.bull), base);
      final MonthEndPlan unknown = planMonthEnd(
        _me(DirectionState.unknown),
        base,
      );
      expect(_bOrders(bull), greaterThan(0), reason: '입력 확인 — 평소엔 B 주문이 있다');
      expect(bull.sleeveBHeld, isFalse);
      expect(_bOrders(unknown), 0);
      expect(unknown.sleeveBHeld, isTrue);
      expect(
        unknown.actions
            .where(
              (MonthEndAction a) => a.kind != MonthEndActionKind.sleeveBOrder,
            )
            .length,
        bull.actions
            .where(
              (MonthEndAction a) => a.kind != MonthEndActionKind.sleeveBOrder,
            )
            .length,
      );
    });

    test('null(보조를 쓰지 않음)은 보류하지 않는다 · 보조가 꺼진 설정도 보류하지 않는다', () {
      final MonthEndPlan none = planMonthEnd(_me(null), base);
      expect(none.sleeveBHeld, isFalse);
      expect(_bOrders(none), greaterThan(0));
      final MonthEndConfig off = MonthEndConfig(
        allocB: base.allocB,
        coreBand: base.coreBand,
        rampMonths: base.rampMonths,
        bAssets: base.bAssets,
        lookbackMonths: base.lookbackMonths,
        assist: SleeveBAssist(floor: 1 / 3, cutState: null, cut: 2 / 3),
        cBondSymbol: base.cBondSymbol,
        cGoldSymbol: base.cGoldSymbol,
        cBondWeight: base.cBondWeight,
        cGoldWeight: base.cGoldWeight,
        maxGoldPctOfTotal: base.maxGoldPctOfTotal,
        cRelativeBand: base.cRelativeBand,
        bOrderThreshold: base.bOrderThreshold,
        cOrderThreshold: base.cOrderThreshold,
        potOrderThreshold: base.potOrderThreshold,
        topupMinFraction: base.topupMinFraction,
        krwUsableFraction: base.krwUsableFraction,
        pensionAnnualLimit: base.pensionAnnualLimit,
        pensionFunding: base.pensionFunding,
        bSellCostRate: base.bSellCostRate,
        cSellCostRate: base.cSellCostRate,
        potCostRate: base.potCostRate,
      );
      final MonthEndPlan unknownOff = planMonthEnd(
        _me(DirectionState.unknown),
        off,
      );
      expect(unknownOff.sleeveBHeld, isFalse);
      expect(_bOrders(unknownOff), greaterThan(0));
    });
  });
}
