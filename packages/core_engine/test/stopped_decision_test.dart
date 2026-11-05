// E13d2 — STOPPED 결정 A/B/C 판정 순수(설계 13 §8 R61 T2 · T5) · 저장 역사 재생 도우미(T1).
//
// 🔵 잡는 것: ① 거부 차례 = 지금 STOPPED → 20거래일(19 막힘 · 20 통과) → 이미 결정 → postmortem → 가족 합의 → 저널 4칸 →
//    B 만 자격 ② A · C = 자격 불요 · 재개 행 없음 · B 통과 = 재개 행 ③ 설정의 유지 봉 ④ 저장 역사 재생 = 같은 재생 · 재개 날 반영
//    ⑤ SEV1 id = 진입 날.
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

BreakerDay _d(double dd, {bool bull = false}) =>
    BreakerDay(drawdown: dd, directionScore: bull ? 60 : 40, bull: bull);

BreakerReplay _replay(List<BreakerDay> days) =>
    replayBreaker(days, p0sBreakerConfig());

StoppedDecisionAnswers _a(
  StoppedDecisionKind k, {
  bool family = true,
  String id = 'J-SD-1',
  String why = '20거래일 대기 뒤 원인 정리',
  String expect = '페이퍼부터 다시',
  String rule = '03_운영 §6-4b',
}) => StoppedDecisionAnswers(
  kind: k,
  decisionId: id,
  rationaleBefore: why,
  expectedOutcome: expect,
  ruleCited: rule,
  familyAgreement: family,
);

void main() {
  final BreakerReplay normal = _replay(<BreakerDay>[_d(-0.10)]);
  BreakerReplay held(int n) =>
      _replay(<BreakerDay>[_d(-0.36), for (int i = 0; i < n; i++) _d(-0.30)]);
  final BreakerReplay eligible = _replay(<BreakerDay>[
    _d(-0.36),
    for (int i = 0; i < 19; i++) _d(-0.30),
    for (int i = 0; i < 5; i++) _d(-0.20, bull: true),
  ]);

  String? code(
    StoppedDecisionAnswers a,
    BreakerReplay r, {
    bool made = false,
    bool pm = true,
    BreakerConfig? cfg,
  }) => judgeStoppedDecision(
    a,
    replay: r,
    decisionAlreadyMade: made,
    postmortemRecorded: pm,
    config: cfg,
  ).code;

  test(
    '거부 차례 — 지금 STOPPED → 20거래일 → 이미 결정 → postmortem → 가족 합의 → 저널 → B 만 자격',
    () {
      final StoppedDecisionAnswers b = _a(StoppedDecisionKind.b);
      expect(code(b, normal), 'STOPPED_NOT_ACTIVE');
      expect(code(b, normal, made: true, pm: false), 'STOPPED_NOT_ACTIVE');
      expect(held(19).heldBars, 19);
      expect(code(b, held(19), made: true), 'STOPPED_WAIT_20D');
      expect(code(b, held(20), made: true, pm: false), 'DECISION_ALREADY_MADE');
      expect(
        code(_a(StoppedDecisionKind.b, family: false), held(20), pm: false),
        'POSTMORTEM_MISSING',
      );
      expect(
        code(_a(StoppedDecisionKind.b, family: false, id: ''), held(20)),
        'FAMILY_AGREEMENT_MISSING',
      );
      for (final StoppedDecisionAnswers blank in <StoppedDecisionAnswers>[
        _a(StoppedDecisionKind.b, id: '  '),
        _a(StoppedDecisionKind.b, why: ''),
        _a(StoppedDecisionKind.b, expect: ' '),
        _a(StoppedDecisionKind.b, rule: ''),
      ]) {
        expect(code(blank, held(20)), 'JOURNAL_REQUIRED');
      }
      expect(code(b, held(20)), 'STOPPED_NOT_ELIGIBLE');
      expect(code(b, eligible), isNull);
    },
  );

  test('🔴 A · C = 자격 없이도 통과 · 재개 행 없음 · B 통과만 재개 행', () {
    for (final StoppedDecisionKind k in <StoppedDecisionKind>[
      StoppedDecisionKind.a,
      StoppedDecisionKind.c,
    ]) {
      final StoppedDecisionVerdict v = judgeStoppedDecision(
        _a(k),
        replay: held(20),
        decisionAlreadyMade: false,
        postmortemRecorded: true,
      );
      expect((v.allowed, v.kind, v.releases, v.code), (true, k, false, null));
      expect(code(_a(k), held(19)), 'STOPPED_WAIT_20D');
    }
    final StoppedDecisionVerdict b = judgeStoppedDecision(
      _a(StoppedDecisionKind.b),
      replay: eligible,
      decisionAlreadyMade: false,
      postmortemRecorded: true,
    );
    expect(
      (b.allowed, b.kind, b.releases),
      (true, StoppedDecisionKind.b, true),
    );
    final StoppedDecisionVerdict no = judgeStoppedDecision(
      _a(StoppedDecisionKind.b),
      replay: normal,
      decisionAlreadyMade: false,
      postmortemRecorded: true,
    );
    expect((no.allowed, no.kind, no.releases), (false, null, false));
    expect(
      StoppedDecisionKind.values.map((StoppedDecisionKind k) => k.code),
      <String>['A', 'B', 'C'],
    );
  });

  test('유지 봉 = 설정 값', () {
    final BreakerConfig base = p0sBreakerConfig();
    final BreakerConfig short = BreakerConfig(
      alertDd: base.alertDd,
      reduceDd: base.reduceDd,
      haltDd: base.haltDd,
      stopDd: base.stopDd,
      alertReleaseDd: base.alertReleaseDd,
      reduceReleaseDd: base.reduceReleaseDd,
      haltReleaseDd: base.haltReleaseDd,
      recoverHoldBars: 5,
      haltReleaseBullStreak: base.haltReleaseBullStreak,
      stopReleaseDd: base.stopReleaseDd,
      stopReleaseBullStreak: base.stopReleaseBullStreak,
    );
    expect(code(_a(StoppedDecisionKind.a), held(5), cfg: short), isNull);
    expect(
      code(_a(StoppedDecisionKind.a), held(4), cfg: short),
      'STOPPED_WAIT_20D',
    );
  });

  test('저장 역사 재생 = 같은 재생 · 재개 날 반영 · SEV1 id = 진입 날', () {
    final List<EquitySnapshotRow> rows = <EquitySnapshotRow>[
      for (int i = 0; i < 25; i++)
        EquitySnapshotRow(
          tradeDate: '2026-09-${(i + 1).toString().padLeft(2, '0')}',
          totalEquity: 64,
          cashKrw: 64,
          positionsValue: 0,
          highWaterMark: 100,
          drawdown: i == 0 ? -0.36 : (i < 20 ? -0.30 : -0.20),
          breakerLevel: BreakerLevel.normal, // 저장 칸은 재생이 보지 않는다
        ),
    ];
    (double?, bool) regime(String d) =>
        d.compareTo('2026-09-21') >= 0 ? (60, true) : (40, false);
    final BreakerReplay r = replayStoredBreaker(rows, regime);
    expect(
      (r.state.level, r.heldBars, r.stoppedReleaseEligible),
      (BreakerLevel.stopped, 24, true),
    );
    final BreakerReplay released = replayStoredBreaker(
      rows,
      regime,
      releaseDates: const <String>['2026-09-25'],
    );
    expect((released.state.level, released.heldBars), (BreakerLevel.halted, 0));
    expect(
      replayStoredBreaker(
        rows,
        regime,
        releaseDates: const <String>['2026-09-26'],
      ).state.level,
      BreakerLevel.stopped,
    );
    expect(
      replayStoredBreaker(const <EquitySnapshotRow>[], regime).state.level,
      BreakerLevel.normal,
    );
    expect(
      stoppedIncidentIdOf('2026-09-01'),
      'SEV1-BREAKER_STOPPED-2026-09-01',
    );
  });
}
