// 🆕 미결 209 — 월간 리포트 빌더 첫 판(설계 13 §8 R199 · 앱 01 §36 K192 · K193 · 03 §3).
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
}
