// 드로다운 서킷브레이커 — `06_시스템설계/04_안전장치.md` §2 · 03 §4-4 · 05 GV-31(AC-S16) · GV-18.
//
// 참조 구현 = `08_파일럿/파일럿4/impl/qtrade/risk/breaker.py`(04 §2 의사코드 전사 · GV-31 생성기)
//           + `09_백테스트/백테스트6/engine/backtest.py` `_update_breaker`(v2.29 STOPPED 재개 자격).
//
// 🔴 악화는 즉시, 완화는 ① 유지 기간(recover_hold_bars) 경과 ② 해제 조건을 **둘 다** 만족할 때
//    **한 단계씩**만. 트리거 경계는 전부 `<=`.
// 🔴 STOPPED 는 자동 해제하지 않는다. v2.29 «재개 자격»은 이벤트(신호)일 뿐 레벨을 바꾸지 않는다.
//    실재개는 사람의 결정(03_운영 §6-4b · `decision_id` — M5-3)이 [releaseStoppedToHalted] 를
//    부를 때만이며, 내려가는 곳은 NORMAL 이 아니라 HALTED 다.
// 🔴 참조 엔진의 `stopped_release_enabled`(자격 = 재개, 백테스트·스트레스 전용 근사)는 **여기 두지
//    않는다** — 자동 재개 스위치가 앱 코드에 존재하지 않게 하기 위해서다. 그 근사가 필요한 재현
//    하네스는 자격 이벤트를 받은 봉에 [releaseStoppedToHalted] 를 직접 부른다.
// 회계(05 GV-31 · GV-4 와 같은 규약): bars_since_change 는 매 봉 처음 +1 한 값으로 판정하고,
//    레벨이 바뀐 봉에서 0 으로 리셋한다 — [stepBreaker] 가 이것을 고정한다.

/// 브레이커 레벨 — 선언 순서가 심각도 순서다. `code` 는 저장·골든 표기다.
enum BreakerLevel {
  /// 정상.
  normal('NORMAL'),

  /// 경보 — v2.30 새틀라이트 신규 진입·증액 중단(v2.31: 대상 없음).
  alert('ALERT'),

  /// 축소 — 새틀라이트 × 0.5(v2.31: 대상 없음).
  reduced('REDUCED'),

  /// 정지 — 새틀라이트 0% · 슬리브 A 신규 매수 정지.
  halted('HALTED'),

  /// 전 시스템 정지 — 자동 해제 없음.
  stopped('STOPPED');

  const BreakerLevel(this.code);

  /// 저장·골든 표기.
  final String code;

  /// [code] 에서 되돌린다. 모르는 값이면 [ArgumentError].
  static BreakerLevel fromCode(String code) => BreakerLevel.values.firstWhere(
    (BreakerLevel l) => l.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'BreakerLevel 이 아니다'),
  );
}

/// 브레이커 설정(02 §4 `circuit_breaker`·`breaker` 키 — 값은 config 에서 온다).
class BreakerConfig {
  /// 설정을 만든다. 사다리가 어긋나면 [ArgumentError].
  BreakerConfig({
    required this.alertDd,
    required this.reduceDd,
    required this.haltDd,
    required this.stopDd,
    required this.alertReleaseDd,
    required this.reduceReleaseDd,
    required this.haltReleaseDd,
    required this.recoverHoldBars,
    required this.haltReleaseBullStreak,
    required this.stopReleaseDd,
    required this.stopReleaseBullStreak,
  }) {
    if (!(stopDd < haltDd &&
        haltDd < reduceDd &&
        reduceDd < alertDd &&
        alertDd < 0)) {
      throw ArgumentError(
        '트리거 사다리는 stop < halt < reduce < alert < 0 이어야 한다: '
        '$stopDd / $haltDd / $reduceDd / $alertDd',
      );
    }
    if (!(alertReleaseDd > alertDd &&
        reduceReleaseDd > reduceDd &&
        haltReleaseDd > haltDd &&
        stopReleaseDd > stopDd)) {
      throw ArgumentError('해제 낙폭은 각자의 트리거보다 얕아야 한다');
    }
    if (recoverHoldBars < 0 ||
        haltReleaseBullStreak < 0 ||
        stopReleaseBullStreak < 0) {
      throw ArgumentError('유지 봉 수·BULL 연속일은 0 이상이어야 한다');
    }
  }

  /// ALERT 트리거(`<=`).
  final double alertDd;

  /// REDUCED 트리거(`<=`).
  final double reduceDd;

  /// HALTED 트리거(`<=`).
  final double haltDd;

  /// STOPPED 트리거 = 목표 MDD(`<=`).
  final double stopDd;

  /// ALERT → NORMAL 해제 낙폭(strict `>`).
  final double alertReleaseDd;

  /// REDUCED → ALERT 해제 낙폭(`>=`) — 방향 스코어 ≥ 50 도 필요.
  final double reduceReleaseDd;

  /// HALTED → REDUCED 해제 낙폭(`>=`) — BULL 연속일도 필요.
  final double haltReleaseDd;

  /// 레벨이 바뀐 뒤 어떤 완화도 막는 유지 봉 수(STOPPED 재개 자격에도 같은 값).
  final int recoverHoldBars;

  /// HALTED 해제에 필요한 BULL 연속일.
  final int haltReleaseBullStreak;

  /// STOPPED 재개 «자격» 낙폭(`>=`, v2.29).
  final double stopReleaseDd;

  /// STOPPED 재개 «자격» BULL 연속일(v2.29).
  final int stopReleaseBullStreak;
}

/// REDUCED 해제에 필요한 방향 점수(04 §2 «direction_score ≥ 50» · 🆕 E13e2 — 사다리 문장이 같은 값을 쓴다).
const double kReduceReleaseDirectionScore = 50.0;

/// 낙폭만으로 정해지는 레벨 — 심각한 쪽부터 · 경계 `<=`.
BreakerLevel levelFromDrawdown(double drawdown, BreakerConfig config) {
  if (drawdown <= config.stopDd) return BreakerLevel.stopped;
  if (drawdown <= config.haltDd) return BreakerLevel.halted;
  if (drawdown <= config.reduceDd) return BreakerLevel.reduced;
  if (drawdown <= config.alertDd) return BreakerLevel.alert;
  return BreakerLevel.normal;
}

/// 04 §2 `evaluate_breaker` — 한 봉의 다음 레벨.
///
/// [barsSinceChange] 는 이번 봉에서 이미 +1 한 값이다. [directionScore] 가 null 이면 REDUCED 해제는
/// 막힌다(fail-closed · GV-31 s12). [bullStreak] 는 `bars_in_state` 가 아니라 실제 BULL 연속일이다.
BreakerLevel evaluateBreaker({
  required double drawdown,
  required BreakerLevel previous,
  required int barsSinceChange,
  required double? directionScore,
  required int bullStreak,
  required BreakerConfig config,
}) {
  if (previous == BreakerLevel.stopped) return BreakerLevel.stopped;

  final BreakerLevel worse = levelFromDrawdown(drawdown, config);
  if (worse.index > previous.index) return worse; // 악화는 즉시

  if (barsSinceChange < config.recoverHoldBars) return previous;

  switch (previous) {
    case BreakerLevel.halted:
      // 🔴 한 단계씩 — 조건이 넘쳐도 REDUCED 까지만(GV-31 s17).
      return drawdown >= config.haltReleaseDd &&
              bullStreak >= config.haltReleaseBullStreak
          ? BreakerLevel.reduced
          : previous;
    case BreakerLevel.reduced:
      return drawdown >= config.reduceReleaseDd &&
              directionScore != null &&
              !directionScore.isNaN &&
              directionScore >= kReduceReleaseDirectionScore
          ? BreakerLevel.alert
          : previous;
    case BreakerLevel.alert:
      return drawdown > config.alertReleaseDd ? BreakerLevel.normal : previous;
    case BreakerLevel.normal:
    case BreakerLevel.stopped:
      return previous;
  }
}

/// v2.29 STOPPED 재개 «자격» — 유지 ≥ recover_hold_bars ∧ 낙폭 ≥ stop_release_dd ∧ BULL 연속 ≥
/// stop_release_bull_streak. 🔴 자격일 뿐 레벨·주문에 효력이 없다.
bool isStoppedReleaseEligible({
  required int heldBars,
  required double drawdown,
  required int bullStreak,
  required BreakerConfig config,
}) =>
    heldBars >= config.recoverHoldBars &&
    drawdown >= config.stopReleaseDd &&
    bullStreak >= config.stopReleaseBullStreak;

/// 봉과 봉 사이에 넘기는 브레이커 상태.
class BreakerState {
  /// 상태를 만든다.
  const BreakerState({
    required this.level,
    required this.barsSinceChange,
    this.releaseEligibilitySent = false,
  });

  /// 현재 레벨.
  final BreakerLevel level;

  /// 레벨이 바뀐 뒤 지난 봉 수.
  final int barsSinceChange;

  /// 이번 STOPPED 에피소드에 재개 자격 이벤트를 이미 냈는가(에피소드당 1회).
  final bool releaseEligibilitySent;
}

/// [stepBreaker] 결과.
class BreakerStep {
  /// 결과를 만든다.
  const BreakerStep({required this.state, required this.releaseEligible});

  /// 다음 봉으로 넘길 상태.
  final BreakerState state;

  /// 이 봉에서 `STOPPED_RELEASE_ELIGIBLE` 이벤트를 낸다(에피소드당 1회 · P1 알림 대상).
  final bool releaseEligible;
}

/// 한 봉 — 회계(+1 후 판정 · 바뀐 봉에서 0)와 재개 자격 이벤트(에피소드당 1회)를 고정한다.
BreakerStep stepBreaker(
  BreakerState state, {
  required double drawdown,
  required double? directionScore,
  required int bullStreak,
  required BreakerConfig config,
}) {
  final int bars = state.barsSinceChange + 1;
  final BreakerLevel next = evaluateBreaker(
    drawdown: drawdown,
    previous: state.level,
    barsSinceChange: bars,
    directionScore: directionScore,
    bullStreak: bullStreak,
    config: config,
  );
  if (next != state.level) {
    // 새 STOPPED 에피소드는 자격 이벤트를 다시 무장한다.
    return BreakerStep(
      state: BreakerState(level: next, barsSinceChange: 0),
      releaseEligible: false,
    );
  }
  final bool eligible =
      next == BreakerLevel.stopped &&
      !state.releaseEligibilitySent &&
      isStoppedReleaseEligible(
        heldBars: bars,
        drawdown: drawdown,
        bullStreak: bullStreak,
        config: config,
      );
  return BreakerStep(
    state: BreakerState(
      level: next,
      barsSinceChange: bars,
      releaseEligibilitySent: state.releaseEligibilitySent || eligible,
    ),
    releaseEligible: eligible,
  );
}

/// STOPPED → HALTED 실재개. 🔴 부르는 자리는 M5-3 재개 경로(`decision_id` 등록 뒤)와 백테스트 재현
/// 하네스뿐이다 — 엔진의 정기 배치가 부르지 않는다. 이후는 기존 계단 해제 규약을 탄다.
BreakerState releaseStoppedToHalted(BreakerState state) {
  if (state.level != BreakerLevel.stopped) {
    throw StateError('STOPPED 가 아닌데 재개할 수 없다: ${state.level.code}');
  }
  return const BreakerState(level: BreakerLevel.halted, barsSinceChange: 0);
}

/// 슬리브별 익스포저 승수(03 §4-4 · 05 GV-18) — 🔴 스칼라가 아니라 슬리브마다 다르다.
class SleeveMultipliers {
  /// 승수를 만든다.
  const SleeveMultipliers({
    required this.sleeveA,
    required this.sleeveB,
    required this.satellite,
    required this.sleeveC,
  });

  /// 슬리브 A(신규 매수 승수 — HALTED 에서 0).
  final double sleeveA;

  /// 슬리브 B.
  final double sleeveB;

  /// 새틀라이트(v2.31: 0% 라 대상 없음 · 규칙 보존).
  final double satellite;

  /// 슬리브 C.
  final double sleeveC;
}

/// 레벨 → 슬리브별 승수. 🔴 HALTED 의 슬리브 A = 0.0 이 핵심이다(GV-18) · ALERT 는 알림만이라 전부 1.0.
SleeveMultipliers exposureMultiplier(BreakerLevel level) => switch (level) {
  BreakerLevel.normal || BreakerLevel.alert => const SleeveMultipliers(
    sleeveA: 1.0,
    sleeveB: 1.0,
    satellite: 1.0,
    sleeveC: 1.0,
  ),
  BreakerLevel.reduced => const SleeveMultipliers(
    sleeveA: 1.0,
    sleeveB: 1.0,
    satellite: 0.5,
    sleeveC: 1.0,
  ),
  BreakerLevel.halted => const SleeveMultipliers(
    sleeveA: 0.0,
    sleeveB: 1.0,
    satellite: 0.0,
    sleeveC: 1.0,
  ),
  BreakerLevel.stopped => const SleeveMultipliers(
    sleeveA: 0.0,
    sleeveB: 0.0,
    satellite: 0.0,
    sleeveC: 0.0,
  ),
};
