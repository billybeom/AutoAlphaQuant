// 서킷브레이커 규약 중 골든(GV-31·s_h5_1·GV-18)이 직접 다루지 않는 것 — 04 §2.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

BreakerConfig _config({double stopDd = -0.35, double haltDd = -0.25}) =>
    BreakerConfig(
      alertDd: -0.15,
      reduceDd: -0.20,
      haltDd: haltDd,
      stopDd: stopDd,
      alertReleaseDd: -0.13,
      reduceReleaseDd: -0.12,
      haltReleaseDd: -0.15,
      recoverHoldBars: 20,
      haltReleaseBullStreak: 3,
      stopReleaseDd: -0.25,
      stopReleaseBullStreak: 5,
    );

void main() {
  test('사다리가 어긋난 설정은 거부한다(stop 이 halt 보다 얕음)', () {
    expect(() => _config(stopDd: -0.20, haltDd: -0.25), throwsArgumentError);
  });

  test('STOPPED 가 아닌 상태를 «재개»하면 거부한다', () {
    expect(
      () => releaseStoppedToHalted(
        const BreakerState(level: BreakerLevel.halted, barsSinceChange: 5),
      ),
      throwsStateError,
    );
  });

  test('자격은 이벤트일 뿐 — 조건이 계속 충족돼도 레벨은 STOPPED · 이벤트는 에피소드당 1회', () {
    final BreakerConfig config = _config();
    BreakerState state = const BreakerState(
      level: BreakerLevel.stopped,
      barsSinceChange: 30,
    );
    int events = 0;
    for (int d = 0; d < 10; d++) {
      final BreakerStep step = stepBreaker(
        state,
        drawdown: -0.10,
        directionScore: 80,
        bullStreak: 9,
        config: config,
      );
      if (step.releaseEligible) events++;
      state = step.state;
      expect(state.level, BreakerLevel.stopped);
    }
    expect(events, 1);
  });

  test('자격은 STOPPED 유지 20봉부터 — 낙폭·BULL 조건이 먼저 차도 그 전에는 없다', () {
    final BreakerConfig config = _config();
    BreakerState state = const BreakerState(
      level: BreakerLevel.stopped,
      barsSinceChange: 0,
    );
    final List<int> eligibleAt = <int>[];
    for (int d = 0; d < 25; d++) {
      final BreakerStep step = stepBreaker(
        state,
        drawdown: -0.10,
        directionScore: 80,
        bullStreak: 9,
        config: config,
      );
      if (step.releaseEligible) eligibleAt.add(step.state.barsSinceChange);
      state = step.state;
    }
    expect(eligibleAt, <int>[20]);
  });

  test('새 STOPPED 에피소드는 자격 이벤트를 다시 무장한다', () {
    final BreakerConfig config = _config();
    // 1차 에피소드: 자격 이벤트 → 사람이 재개(HALTED) → 다시 −36% 로 STOPPED → 20봉 뒤 다시 자격.
    BreakerState state = const BreakerState(
      level: BreakerLevel.stopped,
      barsSinceChange: 30,
    );
    BreakerStep step = stepBreaker(
      state,
      drawdown: -0.10,
      directionScore: 80,
      bullStreak: 9,
      config: config,
    );
    expect(step.releaseEligible, isTrue);
    state = releaseStoppedToHalted(step.state);
    state = stepBreaker(
      state,
      drawdown: -0.36,
      directionScore: 80,
      bullStreak: 0,
      config: config,
    ).state;
    expect(state.level, BreakerLevel.stopped);
    int events = 0;
    for (int d = 0; d < 25; d++) {
      step = stepBreaker(
        state,
        drawdown: -0.10,
        directionScore: 80,
        bullStreak: 9,
        config: config,
      );
      if (step.releaseEligible) events++;
      state = step.state;
    }
    expect(events, 1);
  });

  test('REDUCED 해제는 방향 스코어 NaN 도 결측으로 본다(fail-closed)', () {
    expect(
      evaluateBreaker(
        drawdown: -0.05,
        previous: BreakerLevel.reduced,
        barsSinceChange: 40,
        directionScore: double.nan,
        bullStreak: 9,
        config: _config(),
      ),
      BreakerLevel.reduced,
    );
  });
}
