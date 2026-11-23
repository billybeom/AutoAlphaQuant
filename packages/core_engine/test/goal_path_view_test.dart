// 🆕 E11q-q5d(R238) — M7 `S7-9` 목표 경로 엔진 VM: 표본 `m7_goal_path_*` 기하 · 글자 재현 · 계획선(개시 평가 + 월 납입 설정 ·
// 정직 기대 복리) · 판정 경계(앞섬 · 유지 · 이탈 · 유보) · 결측 · 월간 리포트 목표 줄 · 「목표 경로 보기」 링크.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, dynamic> _row(String name) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/m7/$name.json')
                      .readAsStringSync(),
                ) as Map<String, Object?>)['rows']!
                as List<Object?>)
            .single!
        as Map<String, dynamic>;

GoalPathVm _fx(String name) => GoalPathVm.fromJson(_row(name));

/// 시험 달력 — 평일 = 세션.
bool _weekday(String ymd) {
  final DateTime d = DateTime.parse(ymd);
  return d.weekday != DateTime.saturday && d.weekday != DateTime.sunday;
}

final DateTime _now = DateTime.utc(2026, 8, 3, 3); // 한국 08-03 12:00
final ContributionConfig _cfg = p0sContributionConfig();

/// 개시 04-01(수) 1,000만 · 달마다 마지막 평일 스냅숏(04-30 · 05-29 · 06-30 · 07-31) — [jul] = 7월 말 평가액.
List<EquityPoint> _series({
  double jul = 10700000,
  bool june = true,
  bool july = true,
  String opening = '2026-04-01',
}) => <EquityPoint>[
  EquityPoint(opening, 10000000),
  const EquityPoint('2026-04-30', 10050000),
  const EquityPoint('2026-05-29', 10150000, flow: 100000),
  if (june) const EquityPoint('2026-06-30', 10300000, flow: 100000),
  if (july) EquityPoint('2026-07-31', jul, flow: 100000),
  const EquityPoint('2026-08-03', 99999999), // 그 달 뒤 = 버린다
];

GoalPathOutcome _of({
  String yyyyMm = '2026-07',
  String monthEnd = '2026-07-31',
  List<EquityPoint>? equity,
  List<ContributionParamRow> rows = const <ContributionParamRow>[],
}) => goalPathOf(
  yyyyMm: yyyyMm,
  monthEnd: TradeDate(monthEnd),
  equity: equity ?? _series(),
  isSession: _weekday,
  contributionRows: rows,
  contributionConfig: _cfg,
  nowUtc: _now,
);

double _g(String from, String to) => math
    .pow(
      1 + kGoalPathHonestAnnualRate,
      DateTime.parse(to).difference(DateTime.parse(from)).inDays / 365,
    )
    .toDouble();

ContributionParamRow _rowOf(int id, int amount, String changed, String from) =>
    ContributionParamRow(
      rowId: id,
      amount: Decimal.fromInt(amount),
      changedAtUtc: DateTime.parse('${changed}T01:00:00Z'),
      effectiveFrom: from,
      actionRunId: 'run-$id',
    );

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

MonthlyReport _report(
  GoalVerdict? goal, {
  LedgerTrustBadge trust = _ok,
  bool Function(String)? hasBody,
}) => monthlyReportOf(
  yyyyMm: '2026-08',
  monthEnd: const TradeDate('2026-08-31'),
  generatedAtUtc: DateTime.utc(2026, 9, 1, 3),
  configHash: 'cfg_t',
  trust: trust,
  disclosureViewCount: 2,
  hasBody: hasBody,
  goal: goal,
);

bool _all(String _) => true;

void main() {
  group('기하 — 표본 값으로 표본 목록 재현(m7_goal_path_on · _off · _realworld)', () {
    List<GoalPathFact> factsOf(GoalPathVm v) => <GoalPathFact>[
      for (int i = 0; i < v.planned.length; i++)
        GoalPathFact(
          date: v.planned[i].date.yyyyMmDd,
          dateText: v.planned[i].dateText,
          planned: v.planned[i].value!,
          actual: v.actual[i].value,
        ),
    ];

    for (final String name in <String>['m7_goal_path_on', 'm7_goal_path_off']) {
      test('🔴 $name — 계획선 · 실제선 · 눈금 · 띠 = 표본 DTO 그대로', () {
        final GoalPathVm fx = _fx(name);
        final GoalPathChart c = goalPathChartOf(
          factsOf(fx),
          isSession: _weekday,
        );
        expect(c.planned, fx.planned);
        expect(c.actual, fx.actual);
        expect(c.yTicks, fx.yTicks);
        expect(c.segments, fx.segments);
      });
    }

    test(
      '🔴 _realworld — 결측 점 · 띠 기하 = 표본(사유 · 띠 글자 = 스냅숏 결측 — 재개 갭 원천 전)',
      () {
        final GoalPathVm fx = _fx('m7_goal_path_realworld');
        final GoalPathChart c = goalPathChartOf(
          factsOf(fx),
          isSession: _weekday,
        );
        expect(c.planned, fx.planned);
        expect(c.actual, <PerfPoint>[
          for (final PerfPoint p in fx.actual)
            p.gapReasonCode == null
                ? p
                : p.copyWith(gapReasonCode: kPerfGapSnapshotMissing),
        ]);
        expect(c.yTicks, fx.yTicks);
        expect(c.segments, <PerfSegment>[
          for (final PerfSegment s in fx.segments)
            s.copyWith(label: PerfSeriesTexts.missing),
        ]);
      },
    );

    test('날짜 순 아님 · 점 0 = 실패', () {
      expect(
        () => goalPathChartOf(const <GoalPathFact>[], isSession: _weekday),
        throwsArgumentError,
      );
      expect(
        () => goalPathChartOf(const <GoalPathFact>[
          GoalPathFact(
            date: '2026-05-01',
            dateText: 'a',
            planned: 1,
            actual: 1,
          ),
          GoalPathFact(
            date: '2026-05-01',
            dateText: 'b',
            planned: 1,
            actual: 1,
          ),
        ], isSession: _weekday),
        throwsArgumentError,
      );
    });
  });

  group('글자 — 표본 그대로', () {
    test('🔴 판정 · 근거 · 이탈 · 범례 · 가정 카드 · 정직 기대 · 고지 · 불가 카드', () {
      final GoalPathVm on = _fx('m7_goal_path_on');
      final GoalPathVm off = _fx('m7_goal_path_off');
      final GoalPathVm hold = _fx('m7_goal_path_hold');
      expect(GoalPathTexts.onTrack, on.judgementText);
      expect(GoalPathTexts.basisWithin(8), on.basisText);
      expect(GoalPathTexts.offTrack, off.judgementText);
      expect(GoalPathTexts.basisBelow(8), off.basisText);
      expect(GoalPathTexts.deviation, off.deviationText);
      expect(GoalPathTexts.withheld, hold.judgementText);
      expect(GoalPathTexts.chartUnavailable, hold.chartUnavailableLabel);
      expect(GoalPathTexts.holdPeriod('2026-08'), hold.periodLabel);
      expect(GoalPathTexts.asOfLabel('2026-08-31'), hold.asOf.label);
      expect(GoalPathTexts.plannedLabel, on.plannedLabel);
      expect(GoalPathTexts.actualLabel, on.actualLabel);
      expect(GoalPathTexts.backtestBasis, on.backtestBasisText);
      expect(GoalPathTexts.startingCapital, on.startingCapitalAssumptionText);
      expect(GoalPathTexts.honest, on.honestExpectationText);
      expect(GoalPathTexts.honestWorst, on.honestExpectationWorstText);
      expect(GoalPathTexts.disclaimer, on.disclaimerText);
      expect(GoalPathTexts.monthText('2024-12-31'), on.planned.first.dateText);
      expect(
        '${GoalPathTexts.monthText('2024-12')} ~ ${GoalPathTexts.monthText('2026-08')}',
        on.periodLabel,
      );
    });

    test('🔴 정직 기대 수 = 온보딩 · 배분 카드 정직 기대 줄과 같은 수(두 벌로 갈리지 않는다)', () {
      expect(
        kP0sHonestExpectationLine,
        contains('${GoalPathTexts.pct1(kGoalPathHonestAnnualRate)}% 안팎'),
      );
      expect(
        kP0sHonestExpectationLine,
        contains('최악 ${GoalPathTexts.pct1(kGoalPathHonestWorstAnnualRate)}%'),
      );
    });

    test('월간 리포트 목표 줄 — 앞섬 · 유보 = 표본 m7_monthly_2026_08 · _gap 글자', () {
      expect(
        GoalPathTexts.reportAhead,
        _row('m7_monthly_2026_08')['goal_line'],
      );
      expect(
        MonthlyReportTexts.goalWithheld,
        _row('m7_monthly_gap')['goal_line'],
      );
    });
  });

  group('계획선 — 개시 평가 + 월 납입 설정 · 정직 기대 복리', () {
    test('🔴 점 = 개시 점 + 다음 달부터 달마다 마지막 스냅숏 · 첫 점 계획 = 실제 = 개시 평가', () {
      final GoalPathVm v = _of().vm;
      expect(
        <String>[for (final PerfPoint p in v.actual) p.date.yyyyMmDd],
        <String>['2026-04-01', '2026-05-29', '2026-06-30', '2026-07-31'],
      );
      expect(
        <String>[for (final PerfPoint p in v.actual) p.dateText],
        <String>['2026년 4월', '2026년 5월', '2026년 6월', '2026년 7월'],
      );
      expect(v.planned.first.value, 10000000);
      expect(v.actual.first.value, 10000000);
      expect(v.actual.last.value, 10700000); // 08-03 점은 버렸다
      expect(v.periodLabel, '2026년 4월 ~ 2026년 7월');
      for (int i = 0; i < v.actual.length; i++) {
        expect(v.planned[i].date, v.actual[i].date);
        expect(v.planned[i].xNormalized, v.actual[i].xNormalized);
        expect(v.planned[i].dateText, v.actual[i].dateText);
        expect(v.planned[i].yNormalized, isNotNull);
        expect(v.planned[i].valueText, isNot(contains('%')));
        expect(v.actual[i].valueText, isNot(contains('%')));
      }
      expect(v.yTicks.length, lessThanOrEqualTo(5));
      expect(v.yTicks.first.normalized, 0);
      expect(v.yTicks.last.normalized, 1);
      expect(v.segments, isEmpty);
      expect(v.chartUnavailableLabel, isNull);
    });

    test('🔴 납입 = 개시 다음 달부터 그달 첫 세션 · 기록 없음 = 기본 10만원 · 복리(일수 ÷ 365)', () {
      final GoalPathVm v = _of().vm;
      final double want =
          10000000 * _g('2026-04-01', '2026-07-31') +
          100000 * _g('2026-05-01', '2026-07-31') +
          100000 * _g('2026-06-01', '2026-07-31') +
          100000 * _g('2026-07-01', '2026-07-31');
      expect(v.planned.last.value, want.roundToDouble());
      expect(v.planned.last.valueText, '1,063만원'); // 손셈 ≈ 10,632,092
      final double may =
          10000000 * _g('2026-04-01', '2026-05-29') +
          100000 * _g('2026-05-01', '2026-05-29');
      expect(v.planned[1].value, may.roundToDouble());
    });

    test('🔴 설정 기록 = 그날 현재값(적용 개시일 ≤ 그날) · 0원 = 납입 없음', () {
      final GoalPathVm base = _of().vm;
      final GoalPathVm up = _of(
        rows: <ContributionParamRow>[
          _rowOf(1, 200000, '2026-05-20', '2026-06-01'),
        ],
      ).vm;
      expect(
        up.planned.last.value! - base.planned.last.value!,
        closeTo(
          100000 *
              (_g('2026-06-01', '2026-07-31') + _g('2026-07-01', '2026-07-31')),
          2,
        ),
      );
      final GoalPathVm zero = _of(
        rows: <ContributionParamRow>[_rowOf(1, 0, '2026-04-20', '2026-05-01')],
      ).vm;
      expect(
        zero.planned.last.value,
        (10000000 * _g('2026-04-01', '2026-07-31')).roundToDouble(),
      );
    });

    test('개시가 달 중간이어도 납입은 다음 달 첫 세션부터(개시 달 = 개시 점 하나)', () {
      final GoalPathVm v = _of(equity: _series(opening: '2026-04-15')).vm;
      expect(v.actual.first.date.yyyyMmDd, '2026-04-15');
      expect(v.actual.first.dateText, '2026년 4월');
      final double want =
          10000000 * _g('2026-04-15', '2026-07-31') +
          100000 * _g('2026-05-01', '2026-07-31') +
          100000 * _g('2026-06-01', '2026-07-31') +
          100000 * _g('2026-07-01', '2026-07-31');
      expect(v.planned.last.value, want.roundToDouble());
    });
  });

  group('판정 — 그 달 한 점', () {
    test('🔴 앞섬(평가 ≥ 계획) = VM «유지» · 근거 «안에» · 이탈 문장 없음', () {
      final GoalPathOutcome o = _of(equity: _series(jul: 10700000));
      expect(o.verdict, GoalVerdict.ahead);
      expect(o.vm.judgementText, GoalPathTexts.onTrack);
      expect(o.vm.basisText, GoalPathTexts.basisWithin(7));
      expect(o.vm.deviationText, isNull);
    });

    test('🔴 유지(계획 아래 · 1년 치 기대 성장 안) · 이탈(그 아래) · 경계', () {
      final double p = _of().vm.planned.last.value!;
      GoalPathOutcome at(double a) => _of(equity: _series(jul: a));
      expect(at(p).verdict, GoalVerdict.ahead);
      expect(at(p - 1).verdict, GoalVerdict.onTrack);
      final double floor = p / (1 + kGoalPathHonestAnnualRate);
      expect(at(floor.ceilToDouble()).verdict, GoalVerdict.onTrack);
      final GoalPathOutcome off = at(floor.floorToDouble() - 1);
      expect(off.verdict, GoalVerdict.offTrack);
      expect(off.vm.judgementText, GoalPathTexts.offTrack);
      expect(off.vm.basisText, GoalPathTexts.basisBelow(7));
      expect(off.vm.deviationText, GoalPathTexts.deviation);
      expect(at(10000000).verdict, GoalVerdict.onTrack);
      expect(at(9500000).verdict, GoalVerdict.offTrack);
    });

    test('🔴 판정 유보 = 개시 달부터 3개월 미만 · 스냅숏 0 — 표본 _hold 꼴(네 목록 0 · 불가 카드)', () {
      final GoalPathVm fx = _fx('m7_goal_path_hold');
      for (final GoalPathOutcome o in <GoalPathOutcome>[
        _of(yyyyMm: '2026-06', monthEnd: '2026-06-30'),
        _of(yyyyMm: '2026-04', monthEnd: '2026-04-30'),
        _of(equity: const <EquityPoint>[]),
      ]) {
        expect(o.verdict, GoalVerdict.withheld);
        expect(o.vm.judgementText, fx.judgementText);
        expect(o.vm.basisText, GoalPathTexts.basisShort);
        expect(o.vm.deviationText, isNull);
        expect(o.vm.planned, isEmpty);
        expect(o.vm.actual, isEmpty);
        expect(o.vm.yTicks, isEmpty);
        expect(o.vm.segments, isEmpty);
        expect(o.vm.chartUnavailableLabel, fx.chartUnavailableLabel);
        expect(o.vm.backtestBasisText, fx.backtestBasisText);
        expect(o.vm.disclaimerText, fx.disclaimerText);
      }
      expect(
        _of(yyyyMm: '2026-06', monthEnd: '2026-06-30').vm.periodLabel,
        '2026년 6월 기준',
      );
    });

    test('🔴 그 달 마감 평가 0 = 유보(근거 = 그 달 기록 없음)', () {
      final GoalPathOutcome o = _of(equity: _series(july: false));
      expect(o.verdict, GoalVerdict.withheld);
      expect(o.vm.basisText, GoalPathTexts.basisNoMonthEnd(7));
      expect(o.vm.planned, isEmpty);
    });
  });

  group('결측 — 선을 끊는다', () {
    test(
      '🔴 가운데 달 스냅숏 0 = 결측 점(산출 불가 · 사유) · 띠 = 앞 점 다음 세션 ~ 그 점 · 앞뒤 반 칸',
      () {
        final GoalPathVm v = _of(equity: _series(june: false)).vm;
        final PerfPoint jun = v.actual[2];
        expect(jun.date.yyyyMmDd, '2026-06-30');
        expect(jun.value, isNull);
        expect(jun.yNormalized, isNull);
        expect(jun.valueText, PerfSeriesTexts.notComputable);
        expect(jun.gapReasonCode, kPerfGapSnapshotMissing);
        expect(v.planned[2].value, isNotNull);
        expect(v.segments, <PerfSegment>[
          const PerfSegment(
            from: TradeDate('2026-06-01'),
            to: TradeDate('2026-06-30'),
            kind: SegmentKind.unavailable,
            label: PerfSeriesTexts.missing,
            startNormalized: 0.5,
            endNormalized: 0.8333,
          ),
        ]);
      },
    );
  });

  group('머리 · 기준', () {
    test('기준 = 그 달 마지막 세션 · 관측 = 읽은 시각 · 26시간', () {
      final GoalPathVm v = _of().vm;
      expect(v.yyyyMm, '2026-07');
      expect(v.asOf.tradeDate, const TradeDate('2026-07-31'));
      expect(v.asOf.observedAt, _now);
      expect(v.asOf.staleAfter, kGoalPathStaleAfter);
      expect(v.asOf.source, AsOfSource.localSqlite);
      expect(v.asOf.label, '목표 경로 기준 2026-07-31');
    });

    test('달 꼴 · 기준일이 그 달이 아니면 실패', () {
      expect(() => _of(yyyyMm: '2026-7'), throwsArgumentError);
      expect(() => _of(monthEnd: '2026-08-31'), throwsArgumentError);
    });
  });

  group('월간 리포트 목표 줄 · 「목표 경로 보기」', () {
    test('🔴 판정마다 줄 · 표본 m7_monthly_2026_08(앞섬) · _gap(유보) 줄 + 링크 그대로', () {
      final Map<String, dynamic> aug = _row('m7_monthly_2026_08');
      final MonthlyReport a = _report(GoalVerdict.ahead, hasBody: _all);
      expect(a.goalLine, aug['goal_line']);
      expect(a.goalDeepLink, aug['goal_deep_link']);
      final Map<String, dynamic> gap = _row('m7_monthly_gap');
      final MonthlyReport w = _report(GoalVerdict.withheld, hasBody: _all);
      expect(w.goalLine, gap['goal_line']);
      expect(w.goalDeepLink, gap['goal_deep_link']);
      expect(_report(GoalVerdict.onTrack).goalLine, GoalPathTexts.onTrack);
      expect(_report(GoalVerdict.offTrack).goalLine, GoalPathTexts.offTrack);
    });

    test(
      '🔴 링크 = 판정 있음 · 본문 있음 · 대사 어긋남 아님(표본 _masked_recon = 줄은 있고 버튼 부재)',
      () {
        expect(_report(null, hasBody: _all).goalDeepLink, isNull);
        expect(
          _report(null, hasBody: _all).goalLine,
          MonthlyReportTexts.goalWithheld,
        );
        expect(_report(GoalVerdict.ahead).goalDeepLink, isNull);
        expect(
          _report(
            GoalVerdict.ahead,
            hasBody: (String r) => r != AppRoutes.reportGoalPath,
          ).goalDeepLink,
          isNull,
        );
        final MonthlyReport d = _report(
          GoalVerdict.ahead,
          trust: _drift,
          hasBody: _all,
        );
        expect(d.goalLine, _row('m7_monthly_masked_recon')['goal_line']);
        expect(d.goalDeepLink, isNull);
        expect(
          _report(
            GoalVerdict.ahead,
            hasBody: (String r) => r == AppRoutes.reportGoalPath,
          ).goalDeepLink,
          'aaq://report/goal/2026-08',
        );
      },
    );
  });
}
