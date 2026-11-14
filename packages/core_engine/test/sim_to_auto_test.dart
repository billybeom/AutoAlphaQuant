// 🆕 E15f1 — simToAuto 순수 판정(7단계 · 냉각 · 확정 기한 · 커밋 창 막기 · 화면 계획 · 설계 13 §8 R93 AE2~AE7).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
).subtract(const Duration(hours: 9));

const SimTrialReport _done = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: false,
  counters: SimTrialCounters.zero,
  headline: '체험 5항목을 모두 채웠습니다.',
);
const SimTrialReport _warn = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: true,
  counters: SimTrialCounters.zero,
  headline: '체험 항목을 채웠습니다 — 월말 리밸런싱은 아직이라 경고 후 진행합니다.',
);
const SimTrialReport _open = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: false,
  needsWarning: true,
  counters: SimTrialCounters.zero,
  headline: '모의 체험 진행 중 — 남은 항목 1개',
);

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

/// 생체 = 01-12 10:00 → 냉각 끝 01-13 10:00 → 기한 01-14 10:00.
final DateTime _opened = _k('2027-01-12', 10);

SimToAutoFacts _facts({
  DateTime? now,
  bool noNow = false,
  RunMode? sim = RunMode.simInternal,
  bool closed = false,
  OperatingMode? op = OperatingMode.autoTrade,
  SimTrialReport trial = _done,
  bool? golden = true,
  bool? keys = true,
  Map<String, String> accounts = _accounts,
  SimLedgerFate? fate = SimLedgerFate.keep,
  DateTime? opened,
  bool noSession = false,
  bool kill = false,
  List<String> flags = const <String>[],
}) => SimToAutoFacts(
  trustedNowUtc: noNow ? null : (now ?? _k('2027-01-13', 11)),
  simRunMode: sim,
  simClosed: closed,
  operatingMode: op,
  trial: trial,
  goldenVectorPassed: golden,
  liveKeysVerified: keys,
  accountByStrategy: accounts,
  fate: fate,
  sessionOpenedAtUtc: noSession ? null : (opened ?? _opened),
  killSwitchActive: kill,
  blockingFlags: flags,
);

SimToAutoReport _judge(SimToAutoFacts f, [LiveObservationConfig? c]) =>
    judgeSimToAuto(f, kr: _kr, observation: c ?? _two);

void main() {
  test('전제 밖 — 모드 · 닫힘 · 운영 방식 = 단계 0 · 확정 불가', () {
    for (final SimToAutoFacts f in <SimToAutoFacts>[
      _facts(sim: RunMode.live),
      _facts(sim: null),
      _facts(closed: true),
      _facts(op: OperatingMode.advisory),
      _facts(op: null),
    ]) {
      final SimToAutoReport r = _judge(f);
      expect(r.applicable, isFalse);
      expect(r.code, SimToAutoCodes.notSimAuto);
      expect(r.steps, isEmpty);
      expect(r.readyToCommit, isFalse);
      expect(r.headline, '모의투자 자동 매매 중일 때만 실전으로 옮길 수 있습니다.');
    }
    expect(_judge(_facts(sim: RunMode.simBroker)).applicable, isTrue);
  });

  test('7단계 모두 통과 · 냉각 끝 · 창 열림 = 확정 가능', () {
    final SimToAutoReport r = _judge(_facts());
    expect(r.applicable, isTrue);
    expect(r.code, isNull);
    expect(r.readyToCommit, isTrue);
    expect(r.needsTrialWarning, isFalse);
    expect(r.headline, '확정할 수 있습니다 — 확정하면 실전 관찰(주문 0)부터 시작합니다');
    expect(
      <(String, GateState, String)>[
        for (final SimToAutoStepResult s in r.steps)
          (s.step.stepId, s.state, s.label),
      ],
      <(String, GateState, String)>[
        ('SIM_TO_AUTO_S1', GateState.pass, '체험 5항목 완료'),
        ('SIM_TO_AUTO_S2', GateState.pass, '골든 벡터 통과'),
        ('SIM_TO_AUTO_S3', GateState.pass, '실전 키 조회 확인'),
        ('SIM_TO_AUTO_S4', GateState.pass, '전략 4개 모두 계좌 연결'),
        ('SIM_TO_AUTO_S5', GateState.pass, '모의 기록을 앱 밖 보관본으로 남깁니다'),
        ('SIM_TO_AUTO_S6', GateState.pass, '생체 확인 2027-01-12 10:00'),
        ('SIM_TO_AUTO_S7', GateState.pass, '냉각 끝 — 2027-01-14 10:00 전까지 확정하세요'),
      ],
    );
    expect(r.coolingEndsAtUtc, _k('2027-01-13', 10));
    expect(r.commitDeadlineUtc, _k('2027-01-14', 10));
    expect(r.window!.allowed, isTrue);
    expect(r.window!.roundSession, '2027-02-01');
    for (final SimToAutoStepResult s in r.steps) {
      expect(s.label, isNot(contains('DRY_RUN')));
    }
  });

  group('단계(AE3)', () {
    test('S1 ② 미경험 = 통과 + 경고 문구 · 미완 = 막힘(체험 머리말)', () {
      final SimToAutoReport w = _judge(_facts(trial: _warn));
      expect(w.readyToCommit, isTrue);
      expect(w.needsTrialWarning, isTrue);
      expect(
        w.of(SimToAutoStep.trial).label,
        '체험 완료 — 월말 리밸런싱은 아직이라 경고 후 진행합니다',
      );
      final SimToAutoReport o = _judge(_facts(trial: _open));
      expect(o.of(SimToAutoStep.trial).state, GateState.block);
      expect(o.code, SimToAutoCodes.trialIncomplete);
      expect(o.needsTrialWarning, isFalse);
      expect(o.headline, '모의 체험 확인 — 모의 체험 진행 중 — 남은 항목 1개');
    });

    test('S2 · S3 포트 — 거짓 = 막힘 코드 · 아직 = unknown(코드 = 단계 id)', () {
      expect(
        _judge(_facts(golden: false)).code,
        SimToAutoCodes.goldenVectorFailed,
      );
      final SimToAutoReport g = _judge(_facts(golden: null));
      expect(g.of(SimToAutoStep.goldenVector).state, GateState.unknown);
      expect(g.code, 'SIM_TO_AUTO_S2');
      expect(_judge(_facts(keys: false)).code, SimToAutoCodes.liveKeysFailed);
      expect(_judge(_facts(keys: null)).code, 'SIM_TO_AUTO_S3');
    });

    test('S4 계좌 — 빠진 전략 · 빈 별칭 = 막힘', () {
      final SimToAutoReport r = _judge(
        _facts(
          accounts: <String, String>{
            P0sStrategyIds.sleeveA: 'general',
            P0sStrategyIds.sleeveB: ' ',
            P0sStrategyIds.pot: 'general',
          },
        ),
      );
      expect(r.code, SimToAutoCodes.accountUnmapped);
      expect(r.of(SimToAutoStep.accounts).label, '계좌가 없는 전략: P0S_B · P0S_C');
    });

    test('S5 · S6 · 첫 미완 단계가 코드', () {
      expect(
        _judge(_facts(fate: SimLedgerFate.discard))
            .of(SimToAutoStep.simLedger)
            .label,
        '모의 기록을 지웁니다',
      );
      expect(_judge(_facts(fate: null)).code, 'SIM_TO_AUTO_S5');
      final SimToAutoReport s = _judge(_facts(noSession: true));
      expect(s.code, 'SIM_TO_AUTO_S6');
      expect(s.of(SimToAutoStep.cooling).label, '생체 확인 뒤 시작합니다');
      expect(s.coolingEndsAtUtc, isNull);
      expect(s.commitDeadlineUtc, isNull);
    });
  });

  group('S7 냉각 · 확정 기한(AE4)', () {
    test('냉각 끝 1분 전 = 막힘 · 끝 시각 = 통과 · 기한 = 만료', () {
      final SimToAutoReport c = _judge(_facts(now: _k('2027-01-13', 9, 59)));
      expect(c.code, SimToAutoCodes.cooling);
      expect(
        c.of(SimToAutoStep.cooling).label,
        '냉각 중 — 2027-01-13 10:00 이후 확정할 수 있습니다',
      );
      expect(_judge(_facts(now: _k('2027-01-13', 10))).readyToCommit, isTrue);
      final SimToAutoReport x = _judge(_facts(now: _k('2027-01-14', 10)));
      expect(x.code, SimToAutoCodes.sessionExpired);
      expect(x.of(SimToAutoStep.cooling).state, GateState.block);
      expect(
        _judge(_facts(now: _k('2027-01-14', 9, 59))).readyToCommit,
        isTrue,
      );
    });

    test('신뢰 시각 없음 = unknown · 창 없음 · 확정 불가', () {
      final SimToAutoReport r = _judge(_facts(noNow: true));
      expect(r.of(SimToAutoStep.cooling).state, GateState.unknown);
      expect(r.code, SimToAutoCodes.trustedTimeUnavailable);
      expect(r.window, isNull);
      expect(r.readyToCommit, isFalse);
    });

    test('세션 없음 · 시각 없음 = 시각 사유(단계 다 통과해도)', () {
      final SimToAutoReport r = _judge(_facts(noNow: true, noSession: true));
      expect(r.code, 'SIM_TO_AUTO_S6');
    });
  });

  test('킬스위치 · 차단 플래그 = 안전 막힘(단계보다 먼저)', () {
    for (final SimToAutoFacts f in <SimToAutoFacts>[
      _facts(kill: true, golden: false),
      _facts(flags: <String>['RECON_MISMATCH']),
    ]) {
      final SimToAutoReport r = _judge(f);
      expect(r.code, SimToAutoCodes.safetyBlock);
      expect(r.readyToCommit, isFalse);
      expect(r.headline, '킬스위치 · 주문 차단 플래그가 있어 확정하지 않습니다');
    }
  });

  group('커밋 창 막기(AE5 · 갈래 A 02-01 집행 · N = 2)', () {
    SimToAutoCommitWindow w(DateTime at, [int n = 2]) => simToAutoCommitWindow(
      commitAtUtc: at,
      kr: _kr,
      config: LiveObservationConfig(requiredTradingDays: n),
    );

    test('01-28 09:10 전 = 01-28 · 01-29 = 열림 · 09:10 뒤 = 01-29 하나 = 막힘', () {
      final SimToAutoCommitWindow a = w(_k('2027-01-28', 9, 9));
      expect(a.allowed, isTrue);
      expect(a.sessionsBeforeRound, 2);
      expect(a.label, '정기 리밸런싱 2027-02-01 전 관찰 가능 2거래일');
      final SimToAutoCommitWindow b = w(_k('2027-01-28', 9, 10));
      expect(b.allowed, isFalse);
      expect(b.sessionsBeforeRound, 1);
      expect(
        b.label,
        '정기 리밸런싱 2027-02-01 전에 관찰 2거래일을 채울 수 없습니다 — 2027-02-01 09:10 뒤에 확정할 수 있습니다',
      );
      expect(w(_k('2027-01-28', 10), 1).allowed, isTrue);
    });

    test('주말 · 집행일 09:10 전 = 막힘 · 집행일 09:10 뒤 = 다음 달 집행', () {
      final SimToAutoCommitWindow sat = w(_k('2027-01-30', 12));
      expect(sat.allowed, isFalse);
      expect(sat.roundSession, '2027-02-01');
      expect(sat.sessionsBeforeRound, 0);
      final SimToAutoCommitWindow am = w(_k('2027-02-01', 8));
      expect(am.allowed, isFalse);
      expect(am.roundSession, '2027-02-01');
      final SimToAutoCommitWindow pm = w(_k('2027-02-01', 10));
      expect(pm.allowed, isTrue);
      expect(pm.roundSession, '2027-03-02');
      // 경계 — 집행일 09:09 = 그 집행 · 09:10 = 다음 달.
      expect(w(_k('2027-02-01', 9, 9)).roundSession, '2027-02-01');
      expect(w(_k('2027-02-01', 9, 10)).roundSession, '2027-03-02');
    });

    test('월말 판정일(01-29) = 다음 집행 02-01 · 달력 밖 = 막힘', () {
      expect(w(_k('2027-01-29', 8)).roundSession, '2027-02-01');
      final SimToAutoCommitWindow end = w(_k('2027-12-30', 8));
      expect(end.allowed, isFalse);
      expect(end.roundSession, isNull);
      expect(end.label, '달력 범위 밖이라 확정하지 않습니다');
    });

    test('판정에 합쳐짐 — 단계 다 통과해도 창이 막으면 확정 불가 · 머리말 = 창 문구', () {
      final SimToAutoReport r = _judge(
        _facts(opened: _k('2027-01-27', 9), now: _k('2027-01-28', 10)),
      );
      expect(r.of(SimToAutoStep.cooling).state, GateState.pass);
      expect(r.code, SimToAutoCodes.commitWindow);
      expect(r.readyToCommit, isFalse);
      expect(r.headline, r.window!.label);
    });
  });

  test('화면 계획(AE7) — HandoverPlan 7단계 · 편입 0 · asOf', () {
    final SimToAutoReport r = _judge(_facts(golden: false));
    final DateTime at = _k('2027-01-13', 11);
    final HandoverPlan p = simToAutoPlan(r, observedAtUtc: at);
    expect(p.path, HandoverPath.simToAuto);
    expect(p.pathLabel, '모의투자 → 실전 자동 매매(관찰부터)');
    expect(p.adoptionPreview, isEmpty);
    expect(p.steps.map((HandoverStep s) => s.order), <int>[
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ]);
    final HandoverStep s2 = p.steps[1];
    expect(
      <Object?>[
        s2.stepId,
        s2.title,
        s2.whyLine,
        s2.state,
        s2.stateLabel,
        s2.blockedReasonCode,
      ],
      <Object?>[
        'SIM_TO_AUTO_S2',
        '계산 자가검사',
        '실전과 같은 계산인지 골든 벡터로 다시 확인합니다',
        GateState.block,
        '골든 벡터가 맞지 않습니다 — 실전으로 옮기지 않습니다',
        SimToAutoCodes.goldenVectorFailed,
      ],
    );
    expect(p.asOf.observedAt, at);
    expect(p.asOf.tradeDate, const TradeDate('2027-01-13'));
    expect(p.asOf.source, AsOfSource.localSqlite);
    expect(p.asOf.staleAfter, kHandoverPlanStaleAfter);
    expect(p.asOf.label, '전환 판정 2027-01-13 11:00');
    expect(
      simToAutoPlan(_judge(_facts(closed: true)), observedAtUtc: at).steps,
      isEmpty,
    );
  });
}
