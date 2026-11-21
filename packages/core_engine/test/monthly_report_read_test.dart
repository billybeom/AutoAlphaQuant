// 🆕 E11q-q5e(R231 · 미결 209 ⓔ-2 · ⓔ-5) — 월간 리포트 읽기 경로의 엔진 몫:
// 신뢰 배지(그 달 마감 시점 브로커 대사) · 무결성 가림(표본 `m7_monthly_masked_integrity` 꼴) · 대사 어긋남 D2 표지
// (표본 `_masked_recon`) · 「자세히」(값이 있는 칸 · 본문이 있는 화면만 — 표본 `_2026_08` · `_gap`) · 읽을 때 짓기 판정.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _end = TradeDate('2026-08-31');
final DateTime _gen = DateTime.utc(2026, 9, 1, 3); // 한국 09-01 12:00

Map<String, Object?> _row(String name) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/m7/$name.json')
                      .readAsStringSync(),
                ) as Map<String, Object?>)['rows']!
                as List<Object?>)
            .single!
        as Map<String, Object?>;

Map<String, Object?> _fxItem(Map<String, Object?> row, String code) =>
    (row['items']! as List<Object?>).singleWhere(
          (Object? x) => (x! as Map<String, Object?>)['code'] == code,
        )!
        as Map<String, Object?>;

ReportItem _item(MonthlyReport r, String code) =>
    r.items.singleWhere((ReportItem i) => i.code == code);

bool _all(String _) => true;
bool _none(String _) => false;

/// 한국 [ymd] [hh]:[mm] → UTC.
DateTime _kst(String ymd, int hh, [int mm = 0]) => DateTime.parse(
  '${ymd}T${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:00+09:00',
).toUtc();

LedgerTrustBadge _trustOf(
  List<(DateTime, ReconAction)> checks, {
  bool Function(String)? hasBody,
}) => monthlyLedgerTrustOf(checks: checks, monthEnd: _end, hasBody: hasBody);

SleeveWeight _w(SleeveId s, double w) => SleeveWeight(
  sleeve: s,
  weight: w,
  targetWeight: w,
  bandLow: 0,
  bandHigh: 1,
  label: '${s.wire} 줄',
  basis: AllocationBasis.accounting,
);

final List<SleeveWeight> _alloc = <SleeveWeight>[
  _w(SleeveId.a, 0.2),
  _w(SleeveId.b, 0.42),
  _w(SleeveId.c, 0.32),
];

const LedgerTrustBadge _ok = LedgerTrustBadge(
  grade: LedgerTrustGrade.reconciled,
  level: UiLevel.ok,
  label: MonthlyTrustTexts.reconciledLabel,
  consequenceLine: MonthlyTrustTexts.reconciledLine,
);

const LedgerTrustBadge _drift = LedgerTrustBadge(
  grade: LedgerTrustGrade.drifting,
  level: UiLevel.watch,
  label: MonthlyTrustTexts.driftingLabel,
  consequenceLine: MonthlyTrustTexts.driftingLine,
);

const List<String> _aug = <String>[
  '2026-08-03',
  '2026-08-04',
  '2026-08-05',
  '2026-08-31',
];

MonthlyReport _report({
  LedgerTrustBadge trust = _ok,
  bool Function(String)? hasBody,
  List<SleeveWeight>? allocation,
  P0sExposureTally? tally,
  MonthlyEquityFacts? equity,
  MonthlyExecutionFacts? execution,
}) => monthlyReportOf(
  yyyyMm: '2026-08',
  monthEnd: _end,
  generatedAtUtc: _gen,
  configHash: 'cfg_t',
  trust: trust,
  disclosureViewCount: 2,
  allocation: allocation,
  exposureTally: tally,
  equity: equity,
  execution: execution,
  hasBody: hasBody,
);

final MonthlyEquityFacts _flat = MonthlyEquityFacts(
  series: <EquityPoint>[
    const EquityPoint('2026-07-31', 100),
    for (final String s in _aug) EquityPoint(s, 101),
  ],
  monthSessions: _aug,
);

final MonthlyEquityFacts _gap = MonthlyEquityFacts(
  series: <EquityPoint>[
    const EquityPoint('2026-07-31', 100),
    for (final String s in _aug)
      if (s != '2026-08-04') EquityPoint(s, 101),
  ],
  monthSessions: _aug,
);

const MonthlyExecutionFacts _exec = MonthlyExecutionFacts(
  decisionKinds: <String>['ENTRY', 'EXIT'],
  deviationJournals: 0,
);

void main() {
  group('신뢰 배지 — 그 달 마감 시점 브로커 대사(ⓔ-2)', () {
    test('🔴 대사 0 = 확인 불가 · WATCH · 링크 0 · 마지막 확인 날 없음', () {
      final LedgerTrustBadge b = _trustOf(
        const <(DateTime, ReconAction)>[],
        hasBody: _all,
      );
      expect(b.grade, LedgerTrustGrade.unverifiable);
      expect(b.level, UiLevel.watch);
      expect(b.label, '확인 불가'); // 표본 ledger_trust_4 라벨
      expect(b.consequenceLine, MonthlyTrustTexts.noReconLine);
      expect(b.lastVerifiedOn, isNull);
      expect(b.actionDeepLink, isNull);
      expect(b.upgradeHint, isNull);
    });

    test('🔴 마지막 대사 MATCHED · TRANSIENT = 대사 완료 · 확인 날 = 그 대사의 한국 날', () {
      for (final ReconAction a in <ReconAction>[
        ReconAction.matched,
        ReconAction.transient,
      ]) {
        final LedgerTrustBadge b = _trustOf(<(DateTime, ReconAction)>[
          (_kst('2026-08-31', 7, 5), ReconAction.blocked),
          (_kst('2026-08-31', 9, 15), a),
        ], hasBody: _all);
        expect(b.grade, LedgerTrustGrade.reconciled, reason: a.code);
        expect(b.level, UiLevel.ok);
        expect(b.lastVerifiedOn, _end);
        expect(b.actionDeepLink, isNull);
      }
    });

    test('🔴 대사 완료 = 표본 m7_monthly_2026_08 의 등급 · 단계 · 라벨 · 확인 날 — 결과 줄만 «수량»(현금 축 = 관측만)', () {
      final Map<String, Object?> fx =
          _row('m7_monthly_2026_08')['trust']! as Map<String, Object?>;
      final LedgerTrustBadge b = _trustOf(<(DateTime, ReconAction)>[
        (_kst('2026-08-31', 7, 5), ReconAction.matched),
      ]);
      expect(b.grade.wire, fx['grade']);
      expect(b.level.wire, fx['level']);
      expect(b.label, fx['label']);
      expect(b.lastVerifiedOn?.yyyyMmDd, fx['last_verified_on']);
      expect(fx['consequence_line'], '브로커 원장과 수량·현금이 맞습니다.');
      expect(b.consequenceLine, '브로커 원장과 수량이 맞습니다. 현금은 아직 대조하지 않습니다.');
    });

    test(
      '🔴 마지막 대사 BLOCKED = 표본 m7_monthly_masked_recon 배지 그대로(차단 보드 = 본문 있을 때)',
      () {
        final LedgerTrustBadge fx = LedgerTrustBadge.fromJson(
          _row('m7_monthly_masked_recon')['trust']! as Map<String, dynamic>,
        );
        final List<(DateTime, ReconAction)> blockedOnly =
            <(DateTime, ReconAction)>[
              (_kst('2026-08-31', 7, 5), ReconAction.blocked),
            ];
        expect(_trustOf(blockedOnly, hasBody: _all), fx);
        expect(_trustOf(blockedOnly, hasBody: _none).actionDeepLink, isNull);
        expect(_trustOf(blockedOnly).actionDeepLink, isNull);
        // 앞서 맞은 날은 확인 날로 남는다.
        final LedgerTrustBadge after = _trustOf(<(DateTime, ReconAction)>[
          (_kst('2026-08-27', 7, 5), ReconAction.matched),
          (_kst('2026-08-31', 7, 5), ReconAction.blocked),
        ], hasBody: _all);
        expect(after.grade, LedgerTrustGrade.drifting);
        expect(after.lastVerifiedOn, const TradeDate('2026-08-27'));
      },
    );

    test('🔴 마지막 대사 UNAVAILABLE = 확인 불가(대조 못 한 계좌) · 확인 날 = 앞서 맞은 날', () {
      final LedgerTrustBadge b = _trustOf(<(DateTime, ReconAction)>[
        (_kst('2026-08-28', 7, 5), ReconAction.transient),
        (_kst('2026-08-31', 7, 5), ReconAction.unavailable),
      ], hasBody: _all);
      expect(b.grade, LedgerTrustGrade.unverifiable);
      expect(b.level, UiLevel.watch);
      expect(b.consequenceLine, MonthlyTrustTexts.reconUnavailableLine);
      expect(b.lastVerifiedOn, const TradeDate('2026-08-28'));
      expect(b.actionDeepLink, isNull);
    });

    test('🔴 마감 시점 = 실행 시각의 한국 날 ≤ 월말 세션(뒤 대사 = 보지 않는다 · 다시 지어도 같다)', () {
      final List<(DateTime, ReconAction)> base = <(DateTime, ReconAction)>[
        (_kst('2026-08-31', 23, 59), ReconAction.matched), // UTC 08-31 14:59
      ];
      final LedgerTrustBadge a = _trustOf(base);
      final LedgerTrustBadge b = _trustOf(<(DateTime, ReconAction)>[
        ...base,
        (_kst('2026-09-01', 0, 0), ReconAction.blocked), // UTC 08-31 15:00
        (_kst('2026-09-01', 7, 5), ReconAction.unavailable),
      ]);
      expect(a.grade, LedgerTrustGrade.reconciled);
      expect(b, a);
    });

    test('시각 순이 아니면 실패 · 월말 꼴 가드', () {
      expect(
        () => _trustOf(<(DateTime, ReconAction)>[
          (_kst('2026-08-31', 7, 5), ReconAction.matched),
          (_kst('2026-08-30', 7, 5), ReconAction.matched),
        ]),
        throwsArgumentError,
      );
      expect(
        () => monthlyLedgerTrustOf(
          checks: const <(DateTime, ReconAction)>[],
          monthEnd: const TradeDate('2026-8-31'),
        ),
        throwsArgumentError,
      );
    });
  });

  group('무결성 가림(표본 m7_monthly_masked_integrity)', () {
    MonthlyReport masked({bool Function(String)? hasBody, int views = 2}) =>
        monthlyReportIntegrityMaskedOf(
          yyyyMm: '2026-08',
          monthEnd: _end,
          generatedAtUtc: _gen,
          configHash: 'cfg_fake_0000000000000000',
          disclosureViewCount: views,
          hasBody: hasBody,
        );

    test('🔴 13칸 · 목표 줄 · 열람 수 · 배지(X5 링크) = 표본 그대로', () {
      final Map<String, Object?> row = _row('m7_monthly_masked_integrity');
      final MonthlyReport fx = MonthlyReport.fromJson(
        row as Map<String, dynamic>,
      );
      final MonthlyReport r = masked(hasBody: _all);
      expect(r.items, fx.items);
      expect(r.goalLine, fx.goalLine);
      expect(r.disclosureViewCountText, fx.disclosureViewCountText);
      expect(r.trust, fx.trust);
      expect(r.configHash, fx.configHash);
      expect(r.asOf.label, fx.asOf.label);
      expect(r.asOf.tradeDate, fx.asOf.tradeDate);
      expect(r.generatedAtText, fx.generatedAtText);
      expect(r.goalDeepLink, isNull);
      expect(r.afterTax, isNull);
      expect(r.backdateFootnote, isNull);
      expect(r.pendingNoticeText, isNull);
    });

    test('X5 링크 = 본문이 있을 때만 · 머리 검사 = 마감 전 · 음수 열람 실패', () {
      expect(masked().trust.actionDeepLink, isNull);
      expect(masked(hasBody: _none).trust.actionDeepLink, isNull);
      expect(
        () => monthlyReportIntegrityMaskedOf(
          yyyyMm: '2026-08',
          monthEnd: _end,
          generatedAtUtc: DateTime.utc(2026, 8, 30, 3),
          configHash: '',
          disclosureViewCount: 0,
        ),
        throwsArgumentError,
      );
      expect(() => masked(views: -1), throwsArgumentError);
      expect(
        () => monthlyReportIntegrityMaskedOf(
          yyyyMm: '2026-09',
          monthEnd: _end,
          generatedAtUtc: _gen,
          configHash: '',
          disclosureViewCount: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('「자세히」 — 값이 있는 칸 · 본문이 있는 화면만', () {
    test('🔴 C1 · C2 · D3 링크 = 표본 m7_monthly_2026_08 그대로 · 나머지 칸 = 링크 0', () {
      final Map<String, Object?> fx = _row('m7_monthly_2026_08');
      final MonthlyReport r = _report(
        hasBody: _all,
        equity: _flat,
        execution: _exec,
        allocation: _alloc,
      );
      for (final MonthlyReportSlot s in MonthlyReportSlot.values) {
        expect(
          _item(r, s.code).detailDeepLink,
          _fxItem(fx, s.code)['detail_deep_link'],
          reason: s.code,
        );
      }
      expect(
        _item(r, 'D3_EXECUTION').detailDeepLink,
        'aaq://ledger/execution-gap/2026-08',
      );
    });

    test('🔴 결측 달 = C1 · C2 링크 0 · D3 링크 남음(표본 m7_monthly_gap 꼴)', () {
      final Map<String, Object?> fx = _row('m7_monthly_gap');
      final MonthlyReport r = _report(
        hasBody: _all,
        equity: _gap,
        execution: _exec,
      );
      for (final String code in <String>[
        'C1_MAX_DRAWDOWN',
        'C2_TIME_UNDER_WATER',
        'D3_EXECUTION',
      ]) {
        expect(
          _item(r, code).detailDeepLink,
          _fxItem(fx, code)['detail_deep_link'],
          reason: code,
        );
      }
      expect(_item(r, 'C1_MAX_DRAWDOWN').valueText, startsWith('산출 불가'));
    });

    test('🔴 원천 없는 칸(«산출 불가») · 본문 없는 화면 · hasBody 없음 = 링크 0', () {
      final MonthlyReport none = _report(hasBody: _all);
      for (final ReportItem i in none.items) {
        expect(i.detailDeepLink, isNull, reason: i.code);
      }
      for (final bool Function(String)? h in <bool Function(String)?>[
        null,
        _none,
      ]) {
        final MonthlyReport r = _report(
          hasBody: h,
          equity: _flat,
          execution: _exec,
        );
        for (final ReportItem i in r.items) {
          expect(i.detailDeepLink, isNull, reason: i.code);
        }
      }
      // 드로다운만 등록 = D3 링크 0 · 이행 갭만 = C 링크 0.
      final MonthlyReport dd = _report(
        hasBody: (String r) => r == AppRoutes.performanceDrawdown,
        equity: _flat,
        execution: _exec,
      );
      expect(
        _item(dd, 'C1_MAX_DRAWDOWN').detailDeepLink,
        AppRoutes.performanceDrawdown,
      );
      expect(_item(dd, 'D3_EXECUTION').detailDeepLink, isNull);
      final MonthlyReport gap = _report(
        hasBody: (String r) => r == AppRoutes.ledgerExecutionGapMonth,
        equity: _flat,
        execution: _exec,
      );
      expect(_item(gap, 'C2_TIME_UNDER_WATER').detailDeepLink, isNull);
      expect(
        _item(gap, 'D3_EXECUTION').detailDeepLink,
        'aaq://ledger/execution-gap/2026-08',
      );
      expect(gap.goalDeepLink, isNull);
    });
  });

  group('대사 어긋남 D2 표지(표본 m7_monthly_masked_recon)', () {
    test('🔴 배지 DRIFTING = 퍼센트마다 «?» · 메모 = 표본 글자(노출 집계가 있으면 뒤에 잇는다)', () {
      final Map<String, Object?> fx = _fxItem(
        _row('m7_monthly_masked_recon'),
        'D2_ALLOCATION',
      );
      final ReportItem d2 = _item(
        _report(trust: _drift, allocation: _alloc),
        'D2_ALLOCATION',
      );
      expect(d2.valueText, '회계 기준 A 20.0%? · B 42.0%? · C 32.0%?');
      expect(
        fx['value_text'] as String,
        startsWith(d2.valueText),
      ); // 표본 뒤 «엔진 열» 병기 = R199 밖
      expect(d2.noteText, fx['note_text']);
      final P0sExposureTally t = P0sExposureTally(
        month: '2026-08',
        tradingDays: 21,
        usdOverDays: 18,
        krwLowDays: 0,
        unmeasured: const <(String, String)>[],
        config: p0sWarnConfig(),
      );
      final ReportItem withTally = _item(
        _report(trust: _drift, allocation: _alloc, tally: t),
        'D2_ALLOCATION',
      );
      expect(
        withTally.noteText,
        '${MonthlyReportTexts.allocationUnsettled} ${monthlyExposureNoteOf(t)}',
      );
    });

    test('대사 완료 · 확인 불가 = 표지 0 · 비중 없음 = «산출 불가» 그대로(표지 0)', () {
      for (final LedgerTrustBadge b in <LedgerTrustBadge>[
        _ok,
        _trustOf(const <(DateTime, ReconAction)>[]),
      ]) {
        final ReportItem d2 = _item(
          _report(trust: b, allocation: _alloc),
          'D2_ALLOCATION',
        );
        expect(d2.valueText, '회계 기준 A 20.0% · B 42.0% · C 32.0%');
        expect(d2.noteText, isNull);
      }
      final ReportItem none = _item(_report(trust: _drift), 'D2_ALLOCATION');
      expect(none.valueText, MonthlyReportTexts.notComputed);
      expect(none.noteText, isNull);
    });
  });

  group('읽을 때 짓기 판정', () {
    MonthlyReportReadiness at(
      String? opening,
      DateTime now, {
      String m = '2026-08',
    }) => monthlyReportReadinessOf(
      yyyyMm: m,
      monthEnd: m == '2026-08' ? _end : const TradeDate('2026-07-31'),
      openingDate: opening,
      nowUtc: now,
    );

    test('🔴 닫힘 = 한국 오늘 > 월말 세션 · 월말 날 · 그 앞 = 미생성', () {
      expect(
        at('2026-07-01', _kst('2026-09-01', 0)),
        MonthlyReportReadiness.closed,
      );
      expect(
        at('2026-07-01', _kst('2026-08-31', 23, 59)),
        MonthlyReportReadiness.pending,
      );
      expect(
        at('2026-07-01', _kst('2026-08-12', 9)),
        MonthlyReportReadiness.pending,
      );
    });

    test('🔴 개시 0 · 개시 전 달 = 개시 전(미래 달도 개시 0 이면) · 개시 달 = 짓는다', () {
      expect(
        at(null, _kst('2026-09-01', 9)),
        MonthlyReportReadiness.beforeOpening,
      );
      expect(
        at(null, _kst('2026-08-01', 9)),
        MonthlyReportReadiness.beforeOpening,
      );
      expect(
        at('2026-09-01', _kst('2026-11-21', 9)),
        MonthlyReportReadiness.beforeOpening,
      );
      expect(
        at('2026-08-31', _kst('2026-11-21', 9)),
        MonthlyReportReadiness.closed,
      );
      expect(
        at('2026-08-31', _kst('2026-11-21', 9), m: '2026-07'),
        MonthlyReportReadiness.beforeOpening,
      );
    });

    test('꼴 가드 — 달 · 월말 · 개시 날', () {
      expect(() => at('2026-07-01', _gen, m: '2026-8'), throwsArgumentError);
      expect(
        () => monthlyReportReadinessOf(
          yyyyMm: '2026-09',
          monthEnd: _end,
          openingDate: '2026-07-01',
          nowUtc: _gen,
        ),
        throwsArgumentError,
      );
      expect(() => at('2026-7-01', _gen), throwsArgumentError);
    });
  });
}
