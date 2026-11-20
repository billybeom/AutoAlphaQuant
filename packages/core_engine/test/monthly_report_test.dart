// 🆕 미결 209 — 월간 리포트 빌더 첫 판 · A1 · A2 · C1 · C2(설계 13 §8 R199 · R205 · 앱 01 §36 K192 · K193 · 03 §3).
//
// 🔴 13칸 = 표본 `m7/m7_monthly_2026_08` 의 code · order · section · title 그대로(C-25) · 원천 없는 칸 = «산출 불가» ·
//    `D2_ALLOCATION` = 월말 회계 비중 세 줄 + SAF-307 · 원화 유동성 월 집계 메모(문턱 = 집계가 쓴 문턱).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _end = TradeDate('2026-08-31');
final DateTime _gen = DateTime.utc(2026, 8, 31, 23); // KST 09-01 08:00(월 잡)

const LedgerTrustBadge _trust = LedgerTrustBadge(
  grade: LedgerTrustGrade.reconciled,
  level: UiLevel.ok,
  label: '대사 완료',
  consequenceLine: '브로커 원장과 수량·현금이 맞습니다.',
  lastVerifiedOn: TradeDate('2026-08-31'),
);

SleeveWeight _w(SleeveId s, double w, {AllocationBasis? basis}) => SleeveWeight(
  sleeve: s,
  weight: w,
  targetWeight: w,
  bandLow: 0,
  bandHigh: 1,
  label: '${s.wire} 줄',
  basis: basis ?? AllocationBasis.accounting,
);

final List<SleeveWeight> _alloc = <SleeveWeight>[
  _w(SleeveId.a, 0.2),
  _w(SleeveId.b, 0.4204),
  _w(SleeveId.c, 0.3196),
];

P0sExposureTally _tally({
  String month = '2026-08',
  int days = 21,
  int usd = 18,
  int krw = 0,
  List<(String, String)> none = const <(String, String)>[
    ('2026-08-14', '평가 행 없음'),
  ],
  P0sWarnConfig? config,
}) => P0sExposureTally(
  month: month,
  tradingDays: days,
  usdOverDays: usd,
  krwLowDays: krw,
  unmeasured: none,
  config: config ?? p0sWarnConfig(),
);

MonthlyReport _report({
  String yyyyMm = '2026-08',
  TradeDate monthEnd = _end,
  DateTime? generatedAtUtc,
  int views = 2,
  List<SleeveWeight>? allocation,
  P0sExposureTally? tally,
  bool noTally = false,
  String? footnote,
  MonthlyEquityFacts? equity,
}) => monthlyReportOf(
  yyyyMm: yyyyMm,
  monthEnd: monthEnd,
  generatedAtUtc: generatedAtUtc ?? _gen,
  configHash: 'cfg_t',
  trust: _trust,
  disclosureViewCount: views,
  allocation: allocation,
  exposureTally: noTally ? null : (tally ?? _tally()),
  backdateFootnote: footnote,
  equity: equity,
);

/// 비중 가드가 낸 [ArgumentError](이름 `weights` — 범위 밖 색인 [RangeError] 와 가른다).
final Matcher _weightsGuard = throwsA(
  isA<ArgumentError>().having((ArgumentError e) => e.name, 'name', 'weights'),
);

ReportItem _d2(MonthlyReport r) =>
    r.items.singleWhere((ReportItem i) => i.code == 'D2_ALLOCATION');

void main() {
  group('13칸 고정(C-25)', () {
    test(
      '🔴 칸 = 표본 m7_monthly_2026_08 의 code · order · section · title 그대로',
      () {
        final Map<String, Object?> d = jsonDecode(
          File('../domain_contracts/fixtures/m7/m7_monthly_2026_08.json')
              .readAsStringSync(),
        ) as Map<String, Object?>;
        final List<Object?> items =
            ((d['rows']! as List<Object?>).single!
                    as Map<String, Object?>)['items']!
                as List<Object?>;
        expect(items, hasLength(13));
        expect(MonthlyReportSlot.values, hasLength(13));
        for (int i = 0; i < 13; i++) {
          final Map<String, Object?> f = items[i]! as Map<String, Object?>;
          final MonthlyReportSlot s = MonthlyReportSlot.values[i];
          expect(s.code, f['code']);
          expect(s.order, f['order']);
          expect(s.sectionCode, f['section_code']);
          expect(s.title, f['title']);
        }
      },
    );

    test('🔴 리포트 = 13칸 · 순서 1~13 · D2 밖 = «산출 불가» · 메모 · 링크 0', () {
      final MonthlyReport r = _report(allocation: _alloc);
      expect(r.items, hasLength(13));
      expect(
        <String>[for (final ReportItem i in r.items) i.code],
        <String>[
          for (final MonthlyReportSlot s in MonthlyReportSlot.values) s.code,
        ],
      );
      for (int i = 0; i < 13; i++) {
        final ReportItem it = r.items[i];
        expect(it.order, i + 1);
        expect(it.sectionCode, MonthlyReportSlot.values[i].sectionCode);
        expect(it.title, MonthlyReportSlot.values[i].title);
        expect(it.detailDeepLink, isNull);
        if (it.code == 'D2_ALLOCATION') continue;
        expect(it.valueText, MonthlyReportTexts.notComputed);
        expect(it.noteText, isNull);
      }
      expect(() => r.items.add(r.items.first), throwsUnsupportedError);
    });

    test('결측(비중 · 집계 없음)이어도 13칸 그대로', () {
      final MonthlyReport r = _report(noTally: true);
      expect(r.items, hasLength(13));
      expect(_d2(r).valueText, MonthlyReportTexts.notComputed);
      expect(_d2(r).noteText, isNull);
      expect(
        _report(allocation: const <SleeveWeight>[], noTally: true).items,
        hasLength(13),
      );
      expect(
        _d2(_report(allocation: const <SleeveWeight>[], noTally: true))
            .valueText,
        MonthlyReportTexts.notComputed,
      );
    });
  });

  group('D2_ALLOCATION', () {
    test('🔴 값 = «회계 기준 A · B · C»(소수 한 자리) · 메모 = 월 집계 한 줄', () {
      final ReportItem d2 = _d2(_report(allocation: _alloc));
      expect(d2.order, 7);
      expect(d2.sectionCode, 'D');
      expect(d2.title, '슬리브 배분 현황');
      expect(d2.valueText, '회계 기준 A 20.0% · B 42.0% · C 32.0%');
      expect(
        d2.noteText,
        '21거래일 중 달러 노출 50% 넘은 날 18일 · 원화 유동성 1% 밑 0일 · 계측 없음 1일',
      );
    });

    test('비중 없음 = 값 «산출 불가» · 메모는 집계대로(서로 다른 원천)', () {
      final ReportItem d2 = _d2(_report());
      expect(d2.valueText, MonthlyReportTexts.notComputed);
      expect(d2.noteText, startsWith('21거래일 중 '));
    });

    test('집계 없음 = 메모 부재(null) · 값은 비중대로', () {
      final ReportItem d2 = _d2(_report(allocation: _alloc, noTally: true));
      expect(d2.valueText, '회계 기준 A 20.0% · B 42.0% · C 32.0%');
      expect(d2.noteText, isNull);
    });

    test('🔴 계측 없음 = 0 이어도 적는다 · 세 수 = 집계 칸 그대로', () {
      expect(
        monthlyExposureNoteOf(
          _tally(days: 22, usd: 3, krw: 2, none: const <(String, String)>[]),
        ),
        '22거래일 중 달러 노출 50% 넘은 날 3일 · 원화 유동성 1% 밑 2일 · 계측 없음 0일',
      );
    });

    test('🔴 문턱 글자 = 집계가 쓴 문턱(지어내지 않는다)', () {
      expect(
        monthlyExposureNoteOf(
          _tally(
            config: const P0sWarnConfig(
              minDefensivePct: 0.10,
              goldTotalMonitorPct: 0.20,
              usdBaselinePct: 0.6,
              krwLiquidityFloorPct: 0.025,
            ),
          ),
        ),
        '21거래일 중 달러 노출 60% 넘은 날 18일 · 원화 유동성 2.5% 밑 0일 · 계측 없음 1일',
      );
    });

    test('🔴 월 집계 함수 → 메모(집계가 setup 문턱을 싣는다)', () {
      P0sWarnInputs day(int qty, String cash) => P0sWarnInputs(
        holdings: <LedgerHolding>[LedgerHolding('P0S_B', '133690', qty)],
        closes: <String, Decimal>{'133690': Decimal.fromInt(100)},
        cashKrw: Decimal.parse(cash),
      );
      const P0sWarnConfig c = P0sWarnConfig(
        minDefensivePct: 0.10,
        goldTotalMonitorPct: 0.20,
        usdBaselinePct: 0.7,
        krwLiquidityFloorPct: 0.05,
      );
      final P0sExposureTally t = p0sMonthlyExposureTally(
        month: '2026-08',
        days: <P0sTallyDay>[
          (
            date: '2026-08-03',
            inputs: day(8, '200'),
            reason: null,
          ), // 0.80 > 0.7
          (date: '2026-08-04', inputs: day(6, '400'), reason: null), // 0.60
          (
            date: '2026-08-05',
            inputs: day(99, '400'),
            reason: null,
          ), // 원화 400/10300 < 0.05
          (date: '2026-08-06', inputs: null, reason: '평가 행 없음'),
        ],
        setup: P0sWarnSetup(config: c),
      );
      expect(identical(t.config, c), isTrue);
      expect(
        _d2(_report(tally: t)).noteText,
        '4거래일 중 달러 노출 70% 넘은 날 2일 · 원화 유동성 5% 밑 1일 · 계측 없음 1일',
      );
      final P0sExposureTally dflt = p0sMonthlyExposureTally(
        month: '2026-08',
        days: const <P0sTallyDay>[],
        setup: P0sWarnSetup(),
      );
      expect(dflt.config.usdBaselinePct, 0.50);
      expect(dflt.config.krwLiquidityFloorPct, 0.01);
    });

    test('비중 가드 — A · B · C 순 · 세 줄 · 회계 기준(이 가드의 오류 · 범위 밖 색인 아님)', () {
      expect(
        () => monthlyAllocationValueOf(_alloc.sublist(0, 2)),
        _weightsGuard,
      );
      expect(
        () => monthlyAllocationValueOf(<SleeveWeight>[
          _alloc[1],
          _alloc[0],
          _alloc[2],
        ]),
        _weightsGuard,
      );
      expect(
        () => monthlyAllocationValueOf(<SleeveWeight>[
          _alloc[0],
          _alloc[1],
          _w(SleeveId.pot, 0.32),
        ]),
        _weightsGuard,
      );
      expect(
        () => monthlyAllocationValueOf(<SleeveWeight>[
          _alloc[0],
          _w(SleeveId.b, 0.42, basis: AllocationBasis.engineColumn),
          _alloc[2],
        ]),
        _weightsGuard,
      );
      expect(
        () => _report(
          allocation: <SleeveWeight>[..._alloc, _w(SleeveId.pot, 0.04)],
        ),
        _weightsGuard,
      );
    });

    test('거래일 0 집계 = 실패(지어내지 않는다)', () {
      expect(
        () => monthlyExposureNoteOf(
          _tally(days: 0, usd: 0, none: const <(String, String)>[]),
        ),
        throwsArgumentError,
      );
    });
  });

  group('머리 · 꼬리', () {
    test('🔴 목표 = 판정 보류 · 버튼 · 세후 · 미생성 고지 0 · 표본 글자', () {
      final MonthlyReport r = _report(allocation: _alloc, footnote: '전월 정정 1건');
      expect(r.yyyyMm, '2026-08');
      expect(r.goalLine, '목표 경로 대비 판정을 보류합니다.');
      expect(r.goalDeepLink, isNull);
      expect(r.afterTax, isNull);
      expect(r.pendingNoticeText, isNull);
      expect(r.disclosureViewCountText, '이번 달 2번 열어 보셨습니다');
      expect(r.trust, _trust);
      expect(r.configHash, 'cfg_t');
      expect(r.backdateFootnote, '전월 정정 1건');
      expect(_report(views: 0).disclosureViewCountText, '이번 달 0번 열어 보셨습니다');
      expect(_report(noTally: true).backdateFootnote, isNull);
      // 03 §3 «산출 불가» 꼴 — 원천 없는 칸의 한 문장(R199).
      expect(MonthlyReportTexts.notComputed, '산출 불가 — 아직 계산하지 않는 항목입니다');
    });

    test('🔴 생성 = 한국 날 · asOf = 생성 시각 · 월말 세션 · 26시간 · «리포트 기준»', () {
      final MonthlyReport r = _report();
      expect(r.generatedAtText, '2026-09-01 생성'); // UTC 08-31 23:00 = KST 09-01
      expect(r.asOf.observedAt, _gen);
      expect(r.asOf.tradeDate, _end);
      expect(r.asOf.source, AsOfSource.localSqlite);
      expect(r.asOf.staleAfter, const Duration(seconds: 93600));
      expect(r.asOf.label, '리포트 기준 2026-08-31');
      expect(
        _report(generatedAtUtc: DateTime.utc(2026, 8, 31, 12)).generatedAtText,
        '2026-08-31 생성',
      ); // 월말 세션 당일 밤(KST 21:00) = 마감 뒤
    });

    test('JSON 왕복 = 같은 값(계약 DTO)', () {
      final MonthlyReport r = _report(allocation: _alloc);
      expect(
        MonthlyReport.fromJson(
          jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
        ),
        r,
      );
    });
  });

  group('입력 가드', () {
    test('달 · 월말 · 생성 · 열람 · 집계 달', () {
      expect(() => _report(yyyyMm: '2026-8'), throwsArgumentError);
      expect(() => _report(yyyyMm: '2026-13'), throwsArgumentError);
      expect(
        () => _report(
          yyyyMm: '2026-13',
          monthEnd: const TradeDate('2026-13-31'),
          generatedAtUtc: DateTime.utc(2027),
          noTally: true,
        ),
        throwsArgumentError,
      ); // 월말 가드를 지나도 달 꼴에서 막는다
      expect(
        () => _report(monthEnd: const TradeDate('2026-09-01')),
        throwsArgumentError,
      );
      expect(
        () => _report(monthEnd: const TradeDate('2026-08-3')),
        throwsArgumentError,
      );
      expect(
        () => _report(generatedAtUtc: DateTime.utc(2026, 8, 30, 14, 59)),
        throwsArgumentError,
      ); // KST 08-30 23:59 < 월말
      expect(
        _report(generatedAtUtc: DateTime.utc(2026, 8, 30, 15)).generatedAtText,
        '2026-08-31 생성',
      ); // KST 08-31 00:00 = 경계 통과
      expect(() => _report(views: -1), throwsArgumentError);
      expect(
        () => _report(tally: _tally(month: '2026-07')),
        throwsArgumentError,
      );
    });
  });

  // ── 🆕 R205 — A1 · A2 · C1 · C2(계층 B 와 같은 TWR 시리즈 + 그 달 KR 세션) ──
  group('A1 · A2 · C1 · C2(R205)', () {
    ReportItem item(MonthlyReport r, String code) =>
        r.items.singleWhere((ReportItem i) => i.code == code);

    MonthlyReport withEquity(List<EquityPoint> series, List<String> sessions) =>
        _report(
          noTally: true,
          equity: MonthlyEquityFacts(series: series, monthSessions: sessions),
        );

    const List<String> aug = <String>[
      '2026-08-03',
      '2026-08-04',
      '2026-08-05',
      '2026-08-19',
      '2026-08-20',
      '2026-08-21',
      '2026-08-24',
      '2026-08-31',
    ];

    test('🔴 그 달 결측 = 표본 m7_monthly_gap 의 A1 · A2 · C1 · C2 글자 그대로', () {
      final Map<String, Object?> d = jsonDecode(
        File('../domain_contracts/fixtures/m7/m7_monthly_gap.json')
            .readAsStringSync(),
      ) as Map<String, Object?>;
      final List<Object?> fx =
          ((d['rows']! as List<Object?>).single!
                  as Map<String, Object?>)['items']!
              as List<Object?>;
      final MonthlyReport r = withEquity(<EquityPoint>[
        const EquityPoint('2026-07-31', 100),
        for (final String s in aug)
          if (s != '2026-08-20' && s != '2026-08-21') EquityPoint(s, 101),
      ], aug);
      for (final String code in <String>[
        'A1_PERIOD_RETURN',
        'A2_CUMULATIVE_RETURN',
        'C1_MAX_DRAWDOWN',
        'C2_TIME_UNDER_WATER',
      ]) {
        final Map<String, Object?> f =
            fx.singleWhere((Object? x) => (x! as Map)['code'] == code)!
                as Map<String, Object?>;
        expect(item(r, code).valueText, f['value_text'], reason: code);
        expect(item(r, code).noteText, f['note_text'], reason: code);
        expect(item(r, code).detailDeepLink, isNull, reason: code);
      }
    });

    test('결측 날 메모 = 세션 목록에서 이어진 묶음(주말 건너 이어짐) · 개수', () {
      final MonthlyReport r = withEquity(<EquityPoint>[
        const EquityPoint('2026-07-31', 100),
        const EquityPoint('2026-08-04', 100),
        const EquityPoint('2026-08-05', 100),
        const EquityPoint('2026-08-19', 100),
        const EquityPoint('2026-08-20', 100),
      ], aug); // 결측 = 3 · 21 · 24 · 31
      expect(item(r, 'A1_PERIOD_RETURN').valueText, '산출 불가 — 4거래일이 결측입니다');
      expect(item(r, 'A1_PERIOD_RETURN').noteText, '8월 3일 · 21~31일 스냅샷이 없습니다.');
    });

    test('🔴 개시 날 앞 세션 = 결측 아님 · 개시가 이 달이면 A1 = 첫 점부터', () {
      final MonthlyReport r = withEquity(<EquityPoint>[
        const EquityPoint('2026-08-24', 100),
        const EquityPoint('2026-08-31', 101),
      ], aug);
      expect(item(r, 'A1_PERIOD_RETURN').valueText, '+1.00%');
      expect(item(r, 'A1_PERIOD_RETURN').noteText, isNull);
      expect(item(r, 'A2_CUMULATIVE_RETURN').valueText, '+1.00%');
    });

    test('🔴 TWR — 입금은 수익이 아니다 · 낙폭 · 회복(같은 높이 허용) · 물속 기간', () {
      // 지수: 1 · 1.1 · 0.99 · 1.045 · 1.1(입금 50 · 회복) · 1.155
      final MonthlyReport r = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-06-30', 100),
          const EquityPoint('2026-07-01', 110),
          const EquityPoint('2026-07-31', 99),
          const EquityPoint('2026-08-03', 104.5),
          const EquityPoint('2026-08-14', 160, flow: 50),
          const EquityPoint('2026-08-31', 168),
        ],
        const <String>['2026-08-03', '2026-08-14', '2026-08-31'],
      );
      expect(item(r, 'A1_PERIOD_RETURN').valueText, '+16.67%'); // 1.155 ÷ 0.99
      expect(item(r, 'A2_CUMULATIVE_RETURN').valueText, '+15.50%');
      expect(item(r, 'C1_MAX_DRAWDOWN').valueText, '−10.0%'); // 0.99 ÷ 1.1
      expect(
        item(r, 'C2_TIME_UNDER_WATER').valueText,
        '최장 1개월',
      ); // 07-01 → 08-14 = 44일
      for (final String c in <String>[
        'A1_PERIOD_RETURN',
        'A2_CUMULATIVE_RETURN',
        'C1_MAX_DRAWDOWN',
        'C2_TIME_UNDER_WATER',
      ]) {
        expect(item(r, c).noteText, isNull, reason: c);
        expect(item(r, c).detailDeepLink, isNull, reason: c);
      }
      expect(item(r, 'B1_BENCHMARK').valueText, MonthlyReportTexts.notComputed);
      expect(r.items, hasLength(13));
    });

    test('물속 진행 중 = 월말까지 · 가장 긴 것 · 음수 수익률 «−»', () {
      final MonthlyReport r = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-05-29', 100),
          const EquityPoint('2026-05-30', 90),
          const EquityPoint('2026-05-31', 100), // 짧은 물속(2일) 뒤 회복
          const EquityPoint('2026-06-01', 120),
          const EquityPoint('2026-08-31', 90), // 06-01 → 08-31 = 91일 진행 중
        ],
        const <String>['2026-08-31'],
      );
      expect(
        item(r, 'A1_PERIOD_RETURN').valueText,
        '−25.00%',
      ); // 앞 달 마지막 점 06-01
      expect(item(r, 'A2_CUMULATIVE_RETURN').valueText, '−10.00%');
      expect(item(r, 'C1_MAX_DRAWDOWN').valueText, '−25.0%');
      expect(item(r, 'C2_TIME_UNDER_WATER').valueText, '최장 2개월');
    });

    test('물속 0 · 1달 미만 · 0 수익 글자', () {
      final MonthlyReport up = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-08-03', 100),
          const EquityPoint('2026-08-31', 100),
        ],
        const <String>['2026-08-03', '2026-08-31'],
      );
      expect(item(up, 'A1_PERIOD_RETURN').valueText, '0.00%');
      expect(item(up, 'C1_MAX_DRAWDOWN').valueText, '0.0%');
      expect(item(up, 'C2_TIME_UNDER_WATER').valueText, '전고점 아래 구간 없음');
      final MonthlyReport tiny = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-08-03', 100),
          const EquityPoint('2026-08-04', 99.999),
          const EquityPoint('2026-08-31', 99.999),
        ],
        const <String>['2026-08-03', '2026-08-04', '2026-08-31'],
      );
      expect(
        item(tiny, 'A1_PERIOD_RETURN').valueText,
        '0.00%',
      ); // −0.001% → 반올림 0
      expect(item(tiny, 'C1_MAX_DRAWDOWN').valueText, '0.0%');
      expect(item(tiny, 'C2_TIME_UNDER_WATER').valueText, '최장 1개월 미만');
      expect(MonthlyReportTexts.longestUnderWater(30), '최장 1개월 미만');
      expect(MonthlyReportTexts.longestUnderWater(31), '최장 1개월');
      expect(MonthlyReportTexts.longestUnderWater(61), '최장 2개월');
      expect(MonthlyReportTexts.longestUnderWater(60), '최장 1개월');
    });

    test('🔴 물속 기간 = 회복된 것까지 통틀어 가장 긴 것 · 회복 뒤 오르는 구간은 물속 아님', () {
      final MonthlyReport longFirst = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-06-01', 100),
          const EquityPoint('2026-06-02', 90),
          const EquityPoint('2026-08-03', 100), // 63일 뒤 회복
          const EquityPoint('2026-08-04', 90),
          const EquityPoint('2026-08-05', 100), // 1일 뒤 회복
          const EquityPoint('2026-08-31', 101),
        ],
        const <String>['2026-08-03', '2026-08-04', '2026-08-05', '2026-08-31'],
      );
      expect(item(longFirst, 'C2_TIME_UNDER_WATER').valueText, '최장 2개월');
      final MonthlyReport riseAfter = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-06-01', 100),
          const EquityPoint('2026-06-02', 99),
          const EquityPoint('2026-06-03', 100), // 2일 뒤 회복
          const EquityPoint('2026-08-31', 110), // 89일 오름 = 물속 아님
        ],
        const <String>['2026-08-31'],
      );
      expect(item(riseAfter, 'C2_TIME_UNDER_WATER').valueText, '최장 1개월 미만');
      expect(item(riseAfter, 'C1_MAX_DRAWDOWN').valueText, '−1.0%');
      // 부동소수 오차가 아래로 나는 회복(110 → 91 → 110 = 지수 1.0999999999999999) = 같은 높이(허용 1e-9 · 계층 B)
      final MonthlyReport noisy = withEquity(
        <EquityPoint>[
          const EquityPoint('2026-06-01', 100),
          const EquityPoint('2026-06-02', 110),
          const EquityPoint('2026-06-03', 91),
          const EquityPoint('2026-06-04', 110), // 2일 뒤 회복
          const EquityPoint('2026-08-31', 111),
        ],
        const <String>['2026-08-31'],
      );
      expect(item(noisy, 'C2_TIME_UNDER_WATER').valueText, '최장 1개월 미만');
    });

    test('결측 1일도 산출 불가', () {
      final MonthlyReport r = withEquity(<EquityPoint>[
        const EquityPoint('2026-07-31', 100),
        for (final String s in aug)
          if (s != '2026-08-05') EquityPoint(s, 100),
      ], aug);
      expect(item(r, 'A1_PERIOD_RETURN').valueText, '산출 불가 — 1거래일이 결측입니다');
      expect(item(r, 'A1_PERIOD_RETURN').noteText, '8월 5일 스냅샷이 없습니다.');
      expect(
        item(r, 'C2_TIME_UNDER_WATER').valueText,
        MonthlyReportTexts.gapInHistory,
      );
    });

    test('equity 없음 = 네 칸 «산출 불가»', () {
      final MonthlyReport r = _report(noTally: true);
      for (final String c in <String>[
        'A1_PERIOD_RETURN',
        'A2_CUMULATIVE_RETURN',
        'C1_MAX_DRAWDOWN',
        'C2_TIME_UNDER_WATER',
      ]) {
        expect(item(r, c).valueText, MonthlyReportTexts.notComputed);
        expect(item(r, c).noteText, isNull);
      }
    });

    test('가드 — 시리즈 · 세션', () {
      final Matcher g = throwsA(
        isA<ArgumentError>().having(
          (ArgumentError e) => e.name,
          'name',
          'equity',
        ),
      );
      const List<String> s = <String>['2026-08-31'];
      expect(() => withEquity(const <EquityPoint>[], s), g);
      expect(
        () => withEquity(const <EquityPoint>[
          EquityPoint('2026-08-31', 1),
          EquityPoint('2026-08-30', 1),
        ], s),
        g,
      );
      expect(
        () => withEquity(const <EquityPoint>[
          EquityPoint('2026-08-30', 1),
          EquityPoint('2026-08-30', 1),
        ], s),
        g,
      );
      expect(
        () => withEquity(const <EquityPoint>[
          EquityPoint('2026-08-31', 1),
          EquityPoint('2026-09-01', 1),
        ], s),
        g,
      );
      const List<EquityPoint> one = <EquityPoint>[EquityPoint('2026-08-31', 1)];
      expect(() => withEquity(one, const <String>[]), g);
      expect(() => withEquity(one, const <String>['2026-08-28']), g);
      expect(
        () => withEquity(one, const <String>['2026-07-31', '2026-08-31']),
        g,
      );
      expect(
        () => withEquity(one, const <String>['2026-08-3', '2026-08-31']),
        g,
      );
      expect(
        () => withEquity(one, const <String>[
          '2026-08-28',
          '2026-08-28',
          '2026-08-31',
        ]),
        g,
      );
      expect(
        () => withEquity(one, const <String>[
          '2026-08-29',
          '2026-08-28',
          '2026-08-31',
        ]),
        g,
      );
    });
  });
}
