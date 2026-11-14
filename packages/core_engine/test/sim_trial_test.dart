// 🆕 E15d2 — 체험 5항목 판정 · 요약 카운터(설계 13 §8 R87 AB2~AB9 · 앱 04 M8 §9-5).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

/// 12-21(월) 15:30 커밋 — 09:10 뒤라 그날 kr_order 없음.
final DateTime _anchor = _k('2026-12-21', 15, 30);

/// 12-22 ~ 01-07 = 10세션(12-25 · 12-31 · 01-01 휴장).
const List<String> _ten = <String>[
  '2026-12-22',
  '2026-12-23',
  '2026-12-24',
  '2026-12-28',
  '2026-12-29',
  '2026-12-30',
  '2027-01-04',
  '2027-01-05',
  '2027-01-06',
  '2027-01-07',
];

SimTrialFacts _facts({
  DateTime? asOf,
  DateTime? anchor,
  bool noAnchor = false,
  RunMode? runMode = RunMode.simInternal,
  Iterable<String> ok = const <String>[],
  List<SimTrialRebalance> rebalances = const <SimTrialRebalance>[],
  List<SimTrialRecon> recons = const <SimTrialRecon>[],
  int openDiffs = 0,
  List<SimTrialResumeRun> resumes = const <SimTrialResumeRun>[],
  List<SimTrialKillEvent> kills = const <SimTrialKillEvent>[],
  List<DateTime> alerts = const <DateTime>[],
  List<DateTime> interventions = const <DateTime>[],
}) => SimTrialFacts(
  asOfUtc: asOf ?? _k('2027-01-07', 18),
  anchorUtc: noAnchor ? null : (anchor ?? _anchor),
  runMode: runMode,
  batchOkDays: ok.toSet(),
  rebalances: rebalances,
  recons: recons,
  openLedgerDiffs: openDiffs,
  resumeRuns: resumes,
  killEvents: kills,
  alertRaisedUtc: alerts,
  interventionStartedUtc: interventions,
);

SimTrialItemResult _item(SimTrialFacts f, SimTrialItem i) =>
    judgeSimTrial(f, kr: _kr).of(i);

final SimTrialRebalance _plan = SimTrialRebalance(
  kSimTrialMonthlyKind,
  _k('2027-01-04', 8),
);
final SimTrialResumeRun _resume = SimTrialResumeRun(
  _k('2026-12-24', 7),
  finished: true,
  gapTradingDays: 1,
);
final List<SimTrialKillEvent> _kill = <SimTrialKillEvent>[
  SimTrialKillEvent('ACTIVATED', _k('2026-12-24', 10)),
  SimTrialKillEvent('CHECKLIST_CONFIRMED', _k('2026-12-24', 10, 5)),
  SimTrialKillEvent('RESUMED', _k('2026-12-28', 11)),
];

void main() {
  test('체험 전 = 시작 0 · 항목 미완 · ② 만 경고 · 카운터 0', () {
    final SimTrialReport r = judgeSimTrial(
      _facts(noAnchor: true, ok: _ten),
      kr: _kr,
    );
    expect(r.started, isFalse);
    expect(r.complete, isFalse);
    expect(r.needsWarning, isTrue);
    expect(r.counters.text, '체험 0일 · 배치 0회 · 리밸런싱 0회 · 경보 0건 · 개입 0회');
    expect(r.headline, '모의 체험을 아직 시작하지 않았습니다.');
    expect(
      <SimTrialItemState>[for (final SimTrialItemResult i in r.items) i.state],
      <SimTrialItemState>[
        SimTrialItemState.open,
        SimTrialItemState.openWarn,
        SimTrialItemState.open,
        SimTrialItemState.open,
        SimTrialItemState.open,
      ],
    );
  });

  group('① 연속 2거래주(AB3)', () {
    test('연속 10세션 = 통과', () {
      final SimTrialItemResult i = _item(
        _facts(ok: _ten),
        SimTrialItem.twoTradingWeeks,
      );
      expect(i.state, SimTrialItemState.passed);
      expect(i.detail, '연속 정상 배치 10세션 채움');
    });

    test('9세션 · 오늘 행 아직 없음 = 끊지 않고 9/10', () {
      final SimTrialItemResult i = _item(
        _facts(ok: _ten.take(9), asOf: _k('2027-01-07', 8)),
        SimTrialItem.twoTradingWeeks,
      );
      expect(i.state, SimTrialItemState.open);
      expect(i.detail, '연속 정상 배치 9/10세션');
    });

    test('가운데 한 세션 빠짐 = 연속이 다시 센다', () {
      final SimTrialItemResult i = _item(
        _facts(ok: _ten.where((String d) => d != '2026-12-28')),
        SimTrialItem.twoTradingWeeks,
      );
      expect(i.state, SimTrialItemState.open);
      expect(i.detail, '연속 정상 배치 6/10세션');
    });

    test('한 번 채우면 뒤에 빠져도 유지', () {
      final SimTrialItemResult i = _item(
        _facts(ok: _ten, asOf: _k('2027-01-11', 18)),
        SimTrialItem.twoTradingWeeks,
      );
      expect(i.state, SimTrialItemState.passed);
    });

    test('시작 날 행이 있으면 셈 · 시작 앞 날은 세지 않음', () {
      final List<String> fromOpen = <String>['2026-12-21', ..._ten.take(9)];
      expect(
        _item(
          _facts(
            ok: fromOpen,
            anchor: _k('2026-12-21', 9),
            asOf: _k('2027-01-06', 18),
          ),
          SimTrialItem.twoTradingWeeks,
        ).state,
        SimTrialItemState.passed,
      );
      final SimTrialReport r = judgeSimTrial(
        _facts(
          ok: <String>['2026-12-18', ..._ten.take(9)],
          asOf: _k('2027-01-06', 18),
        ),
        kr: _kr,
      );
      expect(r.of(SimTrialItem.twoTradingWeeks).state, SimTrialItemState.open);
      expect(r.counters.batches, 9);
    });

    test('필요 세션 수 = 인자(1 미만 = ArgumentError)', () {
      expect(
        judgeSimTrial(
          _facts(ok: _ten.take(3), asOf: _k('2026-12-24', 18)),
          kr: _kr,
          requiredSessions: 3,
        ).of(SimTrialItem.twoTradingWeeks).state,
        SimTrialItemState.passed,
      );
      expect(
        () => judgeSimTrial(_facts(), kr: _kr, requiredSessions: 0),
        throwsArgumentError,
      );
    });
  });

  group('② 월말 정기 리밸런싱(AB4 · 소프트)', () {
    test('시작 뒤 계획 · 집행 세션 kr_order 정상 = 통과', () {
      final SimTrialItemResult i = _item(
        _facts(ok: _ten, rebalances: <SimTrialRebalance>[_plan]),
        SimTrialItem.monthEndRebalance,
      );
      expect(i.state, SimTrialItemState.passed);
      expect(i.detail, '월말 계획 집행 확인');
    });

    test('집행 세션 kr_order 없음 · 다른 종류 · 시작 앞 계획 = 경고', () {
      for (final SimTrialFacts f in <SimTrialFacts>[
        _facts(
          ok: _ten.where((String d) => d != '2027-01-04'),
          rebalances: <SimTrialRebalance>[_plan],
        ),
        _facts(
          ok: _ten,
          rebalances: <SimTrialRebalance>[
            SimTrialRebalance('SEASONAL', _k('2027-01-04', 8)),
          ],
        ),
        _facts(
          ok: _ten,
          anchor: _k('2027-01-04', 9),
          rebalances: <SimTrialRebalance>[_plan],
        ),
      ]) {
        expect(
          _item(f, SimTrialItem.monthEndRebalance).state,
          SimTrialItemState.openWarn,
        );
      }
    });

    test('🔴 월말 날 커밋 — 계획 trade_date 는 시작 앞이어도 created_at 이 뒤면 통과', () {
      expect(
        _item(
          _facts(
            ok: _ten,
            anchor: _k('2026-12-30', 16),
            rebalances: <SimTrialRebalance>[_plan],
          ),
          SimTrialItem.monthEndRebalance,
        ).state,
        SimTrialItemState.passed,
      );
    });

    test('비세션 날 만든 계획 = 다음 세션이 집행', () {
      expect(
        _item(
          _facts(
            ok: _ten,
            rebalances: <SimTrialRebalance>[
              SimTrialRebalance(kSimTrialMonthlyKind, _k('2027-01-01', 8)),
            ],
          ),
          SimTrialItem.monthEndRebalance,
        ).state,
        SimTrialItemState.passed,
      );
    });

    test('미경험 문구 = 다음 정기 리밸런싱 날', () {
      expect(
        _item(
          _facts(asOf: _k('2026-12-22', 18)),
          SimTrialItem.monthEndRebalance,
        ).detail,
        '아직 없음 — 다음 정기 리밸런싱 2027-01-04 08:00 · 건너뛰면 경고 후 진행',
      );
    });
  });

  group('③ 대사 0오차(AB5)', () {
    test('simInternal = 자동 통과', () {
      final SimTrialItemResult i = _item(_facts(), SimTrialItem.reconciliation);
      expect(i.state, SimTrialItemState.autoPassed);
      expect(i.state.satisfied, isTrue);
    });

    test('simBroker — 기록 없음 · 불일치 · 열린 차이 = 미완', () {
      SimTrialItemResult b(List<SimTrialRecon> rs, {int diffs = 0}) => _item(
        _facts(runMode: RunMode.simBroker, recons: rs, openDiffs: diffs),
        SimTrialItem.reconciliation,
      );
      expect(b(const <SimTrialRecon>[]).detail, '대사 기록 없음');
      final SimTrialItemResult bad = b(<SimTrialRecon>[
        SimTrialRecon(_k('2026-12-22', 16), matched: true),
        SimTrialRecon(_k('2026-12-23', 16), matched: false),
      ]);
      expect(bad.state, SimTrialItemState.open);
      expect(bad.detail, '불일치 1건');
      final SimTrialItemResult open = b(<SimTrialRecon>[
        SimTrialRecon(_k('2026-12-22', 16), matched: true),
      ], diffs: 1);
      expect(open.state, SimTrialItemState.open);
      expect(open.detail, '열린 차이 1건');
    });

    test('simBroker — 시작 앞 불일치는 보지 않음 · 뒤 전부 맞음 = 통과', () {
      final SimTrialItemResult i = _item(
        _facts(
          runMode: RunMode.simBroker,
          recons: <SimTrialRecon>[
            SimTrialRecon(_k('2026-12-18', 16), matched: false),
            SimTrialRecon(_k('2026-12-22', 16), matched: true),
            SimTrialRecon(_k('2026-12-23', 16), matched: true),
          ],
        ),
        SimTrialItem.reconciliation,
      );
      expect(i.state, SimTrialItemState.passed);
      expect(i.detail, '대사 2회 · 불일치 0');
    });

    test('모드 없음 = 미완', () {
      expect(
        _item(_facts(runMode: null), SimTrialItem.reconciliation).state,
        SimTrialItemState.open,
      );
    });
  });

  group('④ X2 재개(AB6)', () {
    test('끝난 · 갭 ≥ 1 · 시작 뒤 = 통과', () {
      final SimTrialItemResult i = _item(
        _facts(resumes: <SimTrialResumeRun>[_resume]),
        SimTrialItem.resume,
      );
      expect(i.state, SimTrialItemState.passed);
      expect(i.detail, '재개 1회 끝남');
    });

    test('갭 0 · 안 끝남 · 시작 앞 = 미완', () {
      for (final SimTrialResumeRun r in <SimTrialResumeRun>[
        SimTrialResumeRun(
          _k('2026-12-24', 7),
          finished: true,
          gapTradingDays: 0,
        ),
        SimTrialResumeRun(
          _k('2026-12-24', 7),
          finished: false,
          gapTradingDays: 2,
        ),
        SimTrialResumeRun(
          _k('2026-12-21', 7),
          finished: true,
          gapTradingDays: 1,
        ),
      ]) {
        final SimTrialItemResult i = _item(
          _facts(resumes: <SimTrialResumeRun>[r]),
          SimTrialItem.resume,
        );
        expect(i.state, SimTrialItemState.open);
        expect(i.detail, '아직 없음');
      }
    });
  });

  group('⑤ 킬스위치(AB7)', () {
    test('발동 다음 재개 = 통과(입력 차례 무관)', () {
      final SimTrialItemResult i = _item(
        _facts(kills: _kill.reversed.toList()),
        SimTrialItem.killSwitch,
      );
      expect(i.state, SimTrialItemState.passed);
      expect(i.detail, '발동 · 재개 연습 끝남');
    });

    test('발동만 · 재개가 앞 · 시작 앞 쌍 = 미완', () {
      expect(
        _item(
          _facts(kills: <SimTrialKillEvent>[_kill.first]),
          SimTrialItem.killSwitch,
        ).detail,
        '발동됨 — 재개 대기',
      );
      final SimTrialItemResult early = _item(
        _facts(
          kills: <SimTrialKillEvent>[
            SimTrialKillEvent('RESUMED', _k('2026-12-22', 10)),
            SimTrialKillEvent('ACTIVATED', _k('2026-12-23', 10)),
          ],
        ),
        SimTrialItem.killSwitch,
      );
      expect(early.state, SimTrialItemState.open);
      expect(early.detail, '발동됨 — 재개 대기');
      final SimTrialItemResult before = _item(
        _facts(
          kills: <SimTrialKillEvent>[
            SimTrialKillEvent('ACTIVATED', _k('2026-12-18', 10)),
            SimTrialKillEvent('RESUMED', _k('2026-12-21', 10)),
          ],
        ),
        SimTrialItem.killSwitch,
      );
      expect(before.state, SimTrialItemState.open);
      expect(before.detail, '아직 없음');
    });
  });

  group('완료 · 경고(AB8)', () {
    test('5항목 = 완료 · 경고 없음', () {
      final SimTrialReport r = judgeSimTrial(
        _facts(
          ok: _ten,
          rebalances: <SimTrialRebalance>[_plan],
          resumes: <SimTrialResumeRun>[_resume],
          kills: _kill,
        ),
        kr: _kr,
      );
      expect(r.started, isTrue);
      expect(r.complete, isTrue);
      expect(r.needsWarning, isFalse);
      expect(r.headline, '체험 5항목을 모두 채웠습니다.');
    });

    test('② 만 빠짐 = 완료 + 경고', () {
      final SimTrialReport r = judgeSimTrial(
        _facts(ok: _ten, resumes: <SimTrialResumeRun>[_resume], kills: _kill),
        kr: _kr,
      );
      expect(r.complete, isTrue);
      expect(r.needsWarning, isTrue);
      expect(r.headline, '체험 항목을 채웠습니다 — 월말 리밸런싱은 아직이라 경고 후 진행합니다.');
    });

    test('단단한 문 하나 빠짐 = 미완 · 남은 수', () {
      final SimTrialReport r = judgeSimTrial(
        _facts(ok: _ten, rebalances: <SimTrialRebalance>[_plan], kills: _kill),
        kr: _kr,
      );
      expect(r.complete, isFalse);
      expect(r.headline, '모의 체험 진행 중 — 남은 항목 1개');
    });
  });

  test('요약 카운터(AB9) — 시작 앞 기록 제외 · 시작 시각 같은 기록 포함 · 손익 0', () {
    final SimTrialReport r = judgeSimTrial(
      _facts(
        ok: <String>['2026-12-18', ..._ten],
        rebalances: <SimTrialRebalance>[
          SimTrialRebalance(kSimTrialMonthlyKind, _k('2026-12-01', 8)),
          _plan,
          SimTrialRebalance('SEASONAL', _k('2027-01-05', 8)),
        ],
        alerts: <DateTime>[
          _k('2026-12-20', 9),
          _anchor,
          _k('2026-12-22', 9),
          _k('2026-12-23', 9),
          _k('2027-01-05', 9),
        ],
        interventions: <DateTime>[_k('2026-12-19', 9), _k('2026-12-29', 9)],
      ),
      kr: _kr,
    );
    expect(r.counters.trialDays, 18);
    expect(r.counters.batches, 10);
    expect(r.counters.rebalances, 2);
    expect(r.counters.alerts, 4);
    expect(r.counters.interventions, 1);
    expect(r.counters.text, '체험 18일 · 배치 10회 · 리밸런싱 2회 · 경보 4건 · 개입 1회');
  });
}
