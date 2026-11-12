// E14b — 재개 갭 · 보수 모드 사다리 · 브레이커 «완화 금지»(설계 13 §8 R72 J1 · J2 · J10).
//
// 🔵 잡는 것: ① 갭 = 사이 세션 수(오늘 · 기준 제외 · 주말 · 휴장 제외) · 기준 없음 = null · 기준 > 오늘 = 오류 ·
//    범위 밖 = 오류 · 날짜 꼴 ② 사다리 생성 검사 · 변경 불가 · 경계(2 · 3 · 5 · 6 · 10 · 11) · 백업 갭 7 ·
//    null = 축 빠짐 · 음수 = 오류 · 다른 사다리 ③ 갭일 = 봉 0 → 유지 봉 · STOPPED 자격 불산입 · 재개일 악화 = 즉시 ·
//    한 봉으로 완화 0
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

// 2026-11 평일 = 세션 · 11-11(수) = 휴장(합성).
ExchangeCalendar _nov() => ExchangeCalendar(
  market: Market.kr,
  sessions: <TradeDate>[
    for (final int d in <int>[
      2,
      3,
      4,
      5,
      6,
      9,
      10,
      12,
      13,
      16,
      17,
      18,
      19,
      20,
      23,
      24,
      25,
      26,
      27,
      30,
    ])
      TradeDate('2026-11-${d.toString().padLeft(2, '0')}'),
  ],
  coverageStart: const TradeDate('2026-11-01'),
  coverageEnd: const TradeDate('2026-11-30'),
);

int? _gap(String? last, String today) => resumeGapSessions(
  calendar: _nov(),
  lastSuccessSession: last == null ? null : TradeDate(last),
  today: TradeDate(today),
);

ResumeMode _mode(int gap, {int? backup, ResumeLadder? ladder}) => resumeModeOf(
  gapSessions: gap,
  backupGapDays: backup,
  ladder: ladder ?? ResumeLadder.defaults,
);

BreakerDay _d(double dd, {bool bull = true}) =>
    BreakerDay(drawdown: dd, directionScore: null, bull: bull);

void main() {
  group('갭', () {
    test('사이 세션 수 — 오늘 · 기준 제외 · 주말 · 휴장 제외', () {
      expect(_gap('2026-11-05', '2026-11-06'), 0);
      expect(_gap('2026-11-05', '2026-11-05'), 0);
      expect(_gap('2026-11-06', '2026-11-09'), 0); // 주말
      expect(_gap('2026-11-06', '2026-11-10'), 1); // 11-09
      expect(_gap('2026-11-10', '2026-11-13'), 1); // 11-12 · 11-11 휴장
      expect(_gap('2026-11-02', '2026-11-20'), 12);
      expect(_gap('2026-11-05', '2026-11-07'), 1); // 오늘 = 토요일 · 11-06
      expect(_gap('2026-11-02', '2026-11-30'), 18);
    });

    test('기준 없음 = null', () {
      expect(_gap(null, '2026-11-20'), isNull);
    });

    test('🔴 기준 > 오늘 = 오류 · 범위 밖 = 오류 · 날짜 꼴', () {
      expect(() => _gap('2026-11-06', '2026-11-05'), throwsArgumentError);
      expect(() => _gap('2026-10-29', '2026-11-03'), throwsStateError);
      expect(() => _gap('2026-11-27', '2026-12-02'), throwsStateError);
      expect(() => _gap('2026-11-x5', '2026-11-06'), throwsArgumentError);
      expect(() => _gap('2026-11-05', '2026-11-31'), throwsArgumentError);
    });
  });

  group('사다리', () {
    test('기본 = 02 §4 권고값 · 변경 불가', () {
      expect(ResumeLadder.defaults.gapLadderTradingDays, <int>[2, 5, 10]);
      expect(ResumeLadder.defaults.backupGapDays, 7);
      expect(
        () => ResumeLadder.defaults.gapLadderTradingDays[0] = 9,
        throwsUnsupportedError,
      );
      final List<int> src = <int>[1, 2, 3];
      final ResumeLadder l = ResumeLadder(
        gapLadderTradingDays: src,
        backupGapDays: 2,
      );
      src[0] = 0;
      expect(l.gapLadderTradingDays, <int>[1, 2, 3]);
    });

    test('생성 검사 — 세 칸 · 0 이상 오름차순 · 백업 ≥ 1', () {
      ResumeLadder mk(List<int> g, [int b = 7]) =>
          ResumeLadder(gapLadderTradingDays: g, backupGapDays: b);
      expect(() => mk(<int>[2, 5]), throwsArgumentError);
      expect(() => mk(<int>[2, 5, 10, 20]), throwsArgumentError);
      expect(() => mk(<int>[-1, 5, 10]), throwsArgumentError);
      expect(() => mk(<int>[3, 2, 10]), throwsArgumentError);
      expect(() => mk(<int>[2, 2, 10]), throwsArgumentError);
      expect(() => mk(<int>[2, 5, 5]), throwsArgumentError);
      expect(() => mk(<int>[2, 5, 10], 0), throwsArgumentError);
      expect(mk(<int>[0, 1, 2], 1).gapLadderTradingDays, <int>[0, 1, 2]);
    });

    test(
      '경계 — 0~2 NORMAL · 3~5 CONSERVATIVE · 6~10 RECOVERY_DRY · 11~ FULL',
      () {
        expect(_mode(0), ResumeMode.normal);
        expect(_mode(2), ResumeMode.normal);
        expect(_mode(3), ResumeMode.conservative);
        expect(_mode(5), ResumeMode.conservative);
        expect(_mode(6), ResumeMode.recoveryDry);
        expect(_mode(10), ResumeMode.recoveryDry);
        expect(_mode(11), ResumeMode.recoveryFull);
        expect(_mode(400), ResumeMode.recoveryFull);
      },
    );

    test('🔴 백업 갭 7일 이상 = FULL · null = 축 빠짐 · 음수 = 오류', () {
      expect(_mode(0, backup: 6), ResumeMode.normal);
      expect(_mode(4, backup: 6), ResumeMode.conservative);
      expect(_mode(0, backup: 7), ResumeMode.recoveryFull);
      expect(_mode(0, backup: 30), ResumeMode.recoveryFull);
      expect(_mode(0), ResumeMode.normal);
      expect(() => _mode(-1), throwsArgumentError);
      expect(() => _mode(0, backup: -1), throwsArgumentError);
    });

    test('다른 사다리 = 그 값으로(상수로 흩어 쓰지 않는다)', () {
      final ResumeLadder l = ResumeLadder(
        gapLadderTradingDays: const <int>[0, 1, 2],
        backupGapDays: 3,
      );
      expect(_mode(0, ladder: l), ResumeMode.normal);
      expect(_mode(1, ladder: l), ResumeMode.conservative);
      expect(_mode(2, ladder: l), ResumeMode.recoveryDry);
      expect(_mode(3, ladder: l), ResumeMode.recoveryFull);
      expect(_mode(0, backup: 2, ladder: l), ResumeMode.normal);
      expect(_mode(0, backup: 3, ladder: l), ResumeMode.recoveryFull);
    });
  });

  group('🔴 브레이커 완화 금지(J10 — 갭일 = 봉 0)', () {
    final BreakerConfig cfg = p0sBreakerConfig();

    test('HALTED — 갭일이 유지 봉에 들어가지 않는다(채웠다면 풀렸을 것)', () {
      final List<BreakerDay> pre = <BreakerDay>[
        _d(-0.26),
        for (int i = 0; i < 14; i++) _d(-0.10),
      ];
      final BreakerReplay resumed = replayBreaker(<BreakerDay>[
        ...pre,
        _d(-0.05),
      ], cfg);
      expect(resumed.state.level, BreakerLevel.halted);
      expect(resumed.heldBars, 15);
      // 반사실 — 갭 7세션을 봉으로 채웠다면 20봉을 넘겨 REDUCED 로 풀렸다.
      final BreakerReplay filled = replayBreaker(<BreakerDay>[
        ...pre,
        for (int i = 0; i < 7; i++) _d(-0.05),
        _d(-0.05),
      ], cfg);
      expect(filled.state.level, BreakerLevel.reduced);
    });

    test('STOPPED — 재개 자격 유지 봉에 갭일 불산입', () {
      final List<BreakerDay> pre = <BreakerDay>[
        _d(-0.36),
        for (int i = 0; i < 18; i++) _d(-0.20),
      ];
      final BreakerReplay resumed = replayBreaker(<BreakerDay>[
        ...pre,
        _d(-0.20),
      ], cfg);
      expect(resumed.state.level, BreakerLevel.stopped);
      expect(resumed.heldBars, 19);
      expect(resumed.stoppedReleaseEligible, isFalse);
      final BreakerReplay filled = replayBreaker(<BreakerDay>[
        ...pre,
        for (int i = 0; i < 5; i++) _d(-0.20),
        _d(-0.20),
      ], cfg);
      expect(filled.stoppedReleaseEligible, isTrue);
    });

    test('재개일 실측이 더 나쁘면 즉시 그쪽(보수적인 쪽)', () {
      final BreakerReplay r = replayBreaker(<BreakerDay>[
        _d(-0.26),
        _d(-0.20),
        _d(-0.20),
        _d(-0.36),
      ], cfg);
      expect(r.state.level, BreakerLevel.stopped);
      expect(r.stoppedEnteredToday, isTrue);
    });

    test('재개일 한 봉이 얕아도 ALERT 를 풀지 않는다(유지 20봉 전)', () {
      final BreakerReplay r = replayBreaker(<BreakerDay>[
        _d(-0.16),
        _d(-0.14),
        _d(-0.01),
      ], cfg);
      expect(r.state.level, BreakerLevel.alert);
      expect(r.heldBars, 2);
    });
  });
}
