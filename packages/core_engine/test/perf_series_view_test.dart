// E11q-q5b — M7 S7-2 성과 탐색 시리즈 VM(설계 13 §8 R223 · C-36 · 표본 `m7/m7_perf_*`).
//
// 🔴 표본 `daily_gap` · `yearly` · `masked_integrity` = 원장 값을 맞춰 넣으면 DTO 째로 같다 · `monthly_period` = 점 · 눈금 · 띠 기하가
//    같다(결측 사유 · 띠 글자 · 벤치마크 = 표본 밖 원천) · `unavailable_gap` = 문장 규칙이 같다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m7';

Map<String, Object?> _row(String file) =>
    ((jsonDecode(File('$_fx/$file').readAsStringSync())
                    as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

PerformanceSeries _fixture(String file) =>
    PerformanceSeries.fromJson(_row(file));

/// 표본 기준 시각(as_of observed_at · 한국 2026-08-31 18:00).
final DateTime _now = DateTime.utc(2026, 8, 31, 9);

/// 시험 달력 — 월~금.
bool _weekday(String ymd) {
  final DateTime d = DateTime.utc(
    int.parse(ymd.substring(0, 4)),
    int.parse(ymd.substring(5, 7)),
    int.parse(ymd.substring(8, 10)),
  );
  return d.weekday <= DateTime.friday;
}

/// 표본 점 값(누적) → 스냅숏(첫 점 = 1 · 흐름 0 · 결측 점 = 스냅숏 없음).
List<EquityPoint> _fromCumulative(PerformanceSeries s) => <EquityPoint>[
  for (final PerfPoint p in s.points)
    if (p.value != null) EquityPoint(p.date.yyyyMmDd, 1 + p.value!),
];

PerformanceSeries _series({
  required List<EquityPoint> equity,
  PerfGranularity g = PerfGranularity.daily,
  bool cumulative = true,
  PerfMetric metric = PerfMetric.twr,
  DateTime? now,
  int views = 2,
  bool integrity = false,
}) => performanceSeriesOf(
  metric: metric,
  granularity: g,
  cumulative: cumulative,
  equity: equity,
  isSession: _weekday,
  nowUtc: now ?? _now,
  viewCountThisMonth: views,
  integrityHidden: integrity,
);

/// 표본 `monthly_period`(기간별) 값 → 월말 스냅숏(결측 달 = 없음 · 결측 뒤 달 = 결측 전 마지막 스냅숏 대비).
List<EquityPoint> _fromPeriodic(PerformanceSeries s) {
  final List<EquityPoint> out = <EquityPoint>[];
  double e = 1;
  for (final PerfPoint p in s.points) {
    if (p.value == null) continue;
    e = out.isEmpty ? 1 : e * (1 + p.value!);
    out.add(EquityPoint(p.date.yyyyMmDd, e));
  }
  return out;
}

void main() {
  group('표본 DTO 째로', () {
    test('일별 누적 · 결측 2일(daily_gap) — 점 · 눈금 · 띠(반 칸) · 글자 · 기준', () {
      final PerformanceSeries want = _fixture('m7_perf_daily_gap.json');
      expect(_series(equity: _fromCumulative(want)), want);
    });

    test('연도별 누적(yearly) — 첫 해 = 첫 스냅숏 대비 · 마지막 해 «(8월까지)» · 띠 시작 = 첫 스냅숏', () {
      final PerformanceSeries want = _fixture('m7_perf_yearly.json');
      final List<EquityPoint> eq = <EquityPoint>[
        const EquityPoint('2024-09-30', 1),
        ..._fromCumulative(want),
      ];
      expect(_series(equity: eq, g: PerfGranularity.yearly), want);
    });

    test('무결성 점검 중(masked_integrity) — 점 0 · 문장 카드 · 표본 줄은 그대로', () {
      final List<EquityPoint> eq = _fromPeriodic(
        _fixture('m7_perf_monthly_period.json'),
      );
      expect(
        _series(equity: eq, g: PerfGranularity.monthly, integrity: true),
        _fixture('m7_perf_masked_integrity.json'),
      );
    });
  });

  group('월별 기간별(monthly_period) — 값 · 눈금 · 띠 기하', () {
    final PerformanceSeries want = _fixture('m7_perf_monthly_period.json');
    final PerformanceSeries got = _series(
      equity: _fromPeriodic(want),
      g: PerfGranularity.monthly,
      cumulative: false,
    );

    test('점 24 — 날짜 · 가로 · 글자 · 값 · 세로(결측 사유 = 스냅숏 없음)', () {
      expect(got.points.length, want.points.length);
      for (int i = 0; i < want.points.length; i++) {
        final PerfPoint w = want.points[i];
        expect(
          got.points[i],
          w.copyWith(
            gapReasonCode: w.value == null ? kPerfGapSnapshotMissing : null,
          ),
          reason: w.dateText,
        );
      }
    });

    test('눈금 −2%~2%(1%p) · 0 = 기준선 · 이름 · 기간 · 표본 줄', () {
      expect(got.yTicks, want.yTicks);
      expect(got.seriesLabel, want.seriesLabel);
      expect(got.periodLabel, want.periodLabel);
      expect(got.disclosure, want.disclosure);
    });

    test('띠 — 측정 · 결측 · 측정 · 가로 범위 = 표본 · 결측 띠 = 스냅숏 없음(재개 갭 원천 = 표본 밖)', () {
      expect(
        got.segments
            .map(
              (PerfSegment s) =>
                  (s.kind, s.startNormalized, s.endNormalized, s.to),
            )
            .toList(),
        want.segments
            .map(
              (PerfSegment s) =>
                  (s.kind, s.startNormalized, s.endNormalized, s.to),
            )
            .toList(),
      );
      expect(got.segments.first.from, want.segments.first.from);
      expect(got.segments[1].label, PerfSeriesTexts.missing);
      expect(
        got.segments[1].from,
        TradeDate('2025-03-03'),
        reason: '앞 점 다음 세션(표본 03-01 = 달력날 · sim_split 표본은 세션)',
      );
      expect(got.benchmark, isNull, reason: '지수 시세 원천 0');
    });
  });

  group('문장 카드(점 0)', () {
    test('구간 전체 결측 = «n거래일 동안» · 표본 없음 줄(unavailable_gap 문장 규칙)', () {
      expect(
        PerfSeriesTexts.allMissing(7, PerfGranularity.daily),
        _fixture('m7_perf_unavailable_gap.json').unavailableLabel,
      );
      final PerformanceSeries s = _series(
        equity: const <EquityPoint>[EquityPoint('2026-07-31', 1)],
        now: DateTime.utc(
          2026,
          8,
          12,
          1,
        ), // 한국 08-12 10:00 — 오늘 = 스냅숏 전 · 끝 = 08-11
      );
      expect(s.points, isEmpty);
      expect(s.segments, isEmpty);
      expect(s.yTicks, isEmpty);
      expect(
        s.unavailableLabel,
        PerfSeriesTexts.allMissing(7, PerfGranularity.daily),
      );
      expect(s.periodLabel, '2026-08-03 ~ 2026-08-11');
      expect(s.disclosure.sampleSizeLine, PerfSeriesTexts.sampleNone);
      expect(
        s.disclosure.sampleSizeLine,
        _fixture('m7_perf_unavailable_gap.json').disclosure.sampleSizeLine,
      );
    });

    test('스냅숏 0 = 문장 카드 · 기준 = 오늘', () {
      final PerformanceSeries s = _series(equity: const <EquityPoint>[]);
      expect(s.points, isEmpty);
      expect(s.unavailableLabel, PerfSeriesTexts.noSnapshot);
      expect(s.asOf.label, '성과 기준 2026-08-31');
      expect(s.disclosure.sampleSizeLine, PerfSeriesTexts.sampleNone);
    });

    test('🆕 금액가중 = 문장 카드(산출 방식 미정 · 지어내지 않는다) · 무결성이 먼저', () {
      final List<EquityPoint> eq = _fromCumulative(
        _fixture('m7_perf_daily_gap.json'),
      );
      final PerformanceSeries m = _series(equity: eq, metric: PerfMetric.mwr);
      expect(m.points, isEmpty);
      expect(m.unavailableLabel, PerfSeriesTexts.mwrUnavailable);
      expect(m.seriesLabel, '내 계좌 · 금액가중 · 누적');
      expect(
        _series(
          equity: eq,
          metric: PerfMetric.mwr,
          integrity: true,
        ).unavailableLabel,
        PerfSeriesTexts.integrityMasked,
      );
    });

    test('주별 = 미정(미결 54) 실패 · 열람 수 음수 = 인자 오류', () {
      expect(
        () => _series(equity: const <EquityPoint>[], g: PerfGranularity.weekly),
        throwsUnsupportedError,
      );
      expect(
        () => _series(equity: const <EquityPoint>[], views: -1),
        throwsArgumentError,
      );
    });
  });

  group('규칙', () {
    test('입출금은 수익이 아니다(TWR) — 입금 날 평가액이 늘어도 수익 0', () {
      final PerformanceSeries s = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-08-03', 100),
          EquityPoint('2026-08-04', 150, flow: 50),
          EquityPoint('2026-08-05', 153),
        ],
        now: DateTime.utc(2026, 8, 5, 9),
      );
      expect(s.points.map((PerfPoint p) => p.valueText).toList(), <String>[
        '0.00%',
        '0.00%',
        '2.00%',
      ]);
    });

    test('기간별 = 앞 점 대비 · 결측 뒤 = 결측 앞 마지막 스냅숏 대비 · 음수 = «−»', () {
      final PerformanceSeries s = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-08-03', 100),
          EquityPoint('2026-08-04', 101),
          EquityPoint('2026-08-06', 99.99),
        ],
        cumulative: false,
        now: DateTime.utc(2026, 8, 6, 9),
      );
      expect(s.points.map((PerfPoint p) => p.valueText).toList(), <String>[
        '0.00%',
        '1.00%',
        PerfSeriesTexts.notComputable,
        '−1.00%',
      ]);
      expect(s.seriesLabel, '내 계좌 · 시간가중 · 일별');
    });

    test('오늘 = 스냅숏이 있을 때만(장 마감 전 «산출 불가» 를 지어내지 않는다) · 주말 = 점 아님', () {
      final PerformanceSeries before = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-08-03', 100),
          EquityPoint('2026-08-04', 101),
        ],
        now: DateTime.utc(2026, 8, 5, 1), // 한국 08-05 10:00 · 스냅숏 전
      );
      expect(before.points.last.date, TradeDate('2026-08-04'));
      final PerformanceSeries weekend = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-08-06', 100),
          EquityPoint('2026-08-07', 101),
        ],
        now: DateTime.utc(2026, 8, 9, 9), // 일요일
      );
      expect(
        weekend.points.map((PerfPoint p) => p.date.yyyyMmDd).toList(),
        <String>['2026-08-06', '2026-08-07'],
      );
    });

    test('일별 기본 구간 = 이번 달(첫 스냅숏 앞은 뺀다) · 누적 기준 = 첫 점', () {
      final PerformanceSeries s = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-07-30', 100),
          EquityPoint('2026-07-31', 110),
          EquityPoint('2026-08-03', 121),
        ],
        now: DateTime.utc(2026, 8, 3, 9),
      );
      expect(s.points.length, 1);
      expect(s.points.single.valueText, '0.00%');
      expect(s.points.single.xNormalized, 0.5, reason: '1점 = 0.5');
      expect(s.yTicks.map((PerfAxisTick t) => t.label).toList(), <String>[
        '0%',
        '1%',
      ], reason: '값이 모두 0 = 0~1%');
      expect(s.segments.single.startNormalized, 0.0);
      expect(s.segments.single.endNormalized, 1.0);
    });

    test('🆕 R260 F-2 🔴 일별 첫 세션 결측 = 누적 기준 = 첫 관측 점 그날(값 0) — 앞 달 마지막 스냅숏이 아니다 · 첫 점 있음 = 그대로', () {
      List<String?> texts(List<EquityPoint> eq) => <String?>[
        for (final PerfPoint p in _series(
          equity: eq,
          now: DateTime.utc(2026, 8, 5, 9),
        ).points)
          p.valueText,
      ];
      // 08-03(월) 결측 · 08-04 = 105 · 08-05 = 110(앞 달 끝 07-31 = 100).
      expect(
        texts(const <EquityPoint>[
          EquityPoint('2026-07-31', 100),
          EquityPoint('2026-08-04', 105),
          EquityPoint('2026-08-05', 110),
        ]),
        <String?>['산출 불가', '0.00%', '4.76%'],
      );
      // 첫 세션 있음 = 그날이 기준(옛 규칙 그대로).
      expect(
        texts(const <EquityPoint>[
          EquityPoint('2026-07-31', 100),
          EquityPoint('2026-08-03', 100),
          EquityPoint('2026-08-04', 105),
          EquityPoint('2026-08-05', 110),
        ]),
        <String?>['0.00%', '5.00%', '10.00%'],
      );
    });

    test('월별 누적 기준 = 첫 스냅숏(첫 달 중간 개시) · 진행 중 달 = 마지막 스냅숏 날', () {
      final PerformanceSeries s = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-06-15', 100),
          EquityPoint('2026-06-30', 102),
          EquityPoint('2026-07-31', 104.04),
          EquityPoint('2026-08-12', 105.0804),
        ],
        g: PerfGranularity.monthly,
        now: DateTime.utc(2026, 8, 13, 1),
      );
      expect(
        s.points.map((PerfPoint p) => (p.date.yyyyMmDd, p.valueText)).toList(),
        <(String, String)>[
          ('2026-06-30', '2.00%'),
          ('2026-07-31', '4.04%'),
          ('2026-08-12', '5.08%'),
        ],
      );
      expect(s.segments.single.from, TradeDate('2026-06-15'));
      expect(s.periodLabel, '2026년 6월 ~ 2026년 8월');
      expect(s.disclosure.sampleSizeLine, PerfSeriesTexts.sampleMonthly(3));
    });

    test('눈금 간격 = 1 · 2 · 5 계열 중 네 칸 이하 최소(sim_split 0~8% · 2%p)', () {
      final PerformanceSeries s = _series(
        equity: const <EquityPoint>[
          EquityPoint('2026-08-03', 1),
          EquityPoint('2026-08-04', 1.0686),
        ],
        now: DateTime.utc(2026, 8, 4, 9),
      );
      expect(s.yTicks, _fixture('m7_perf_monthly_sim_split.json').yTicks);
      expect(s.points.last.yNormalized, 0.8575);
    });

    test('세로 · 가로 · 띠는 0~1 · 띠는 겹치지 않고 차례대로(C-36 ④b)', () {
      final PerformanceSeries s = _series(
        equity: _fromCumulative(_fixture('m7_perf_daily_gap.json')),
      );
      double prevEnd = 0;
      for (final PerfSegment g in s.segments) {
        expect(g.startNormalized, greaterThanOrEqualTo(prevEnd - 1e-9));
        expect(g.endNormalized, lessThanOrEqualTo(1));
        prevEnd = g.endNormalized;
      }
      for (final PerfPoint p in s.points) {
        expect(p.xNormalized, inInclusiveRange(0, 1));
        if (p.yNormalized != null) {
          expect(p.yNormalized, inInclusiveRange(0, 1));
        }
        expect(p.value == null, p.yNormalized == null, reason: 'C-10 ⑤');
      }
    });
  });
}
