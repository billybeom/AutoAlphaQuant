// 국면 상태 — `06_시스템설계/03_알고리즘.md` §1-7(방향 히스테리시스) · §1-8(추세성 축).
//
// 🔴 두 값 모두 **히스테리시스를 거친 상태**다. 원시 점수(0~100)를 임계값과 직접
//    비교해 만든 값을 여기에 넣으면 dead-band·확인 기간이 사라진다(03 §1-8 주석).
//    상태 전이 자체(M1-2 · GV-4)는 E2 에서 들어온다.

/// 방향 상태(03 §1-7). `code` 는 DB·로그·골든에 적히는 값이다.
enum DirectionState {
  /// 상승.
  bull('BULL'),

  /// 중립.
  neutral('NEUTRAL'),

  /// 하락.
  bear('BEAR'),

  /// 판정 불가(데이터 부족 등) — 🔴 fail-closed 로 다룬다(03 §1-8 · GV-3c).
  unknown('UNKNOWN');

  const DirectionState(this.code);

  /// 저장·골든 표기.
  final String code;

  /// [code] 에서 되돌린다. 모르는 값이면 [ArgumentError] — 🔴 `unknown` 으로
  /// 조용히 바꾸지 않는다(오타가 «판정 불가»로 숨는다).
  static DirectionState fromCode(String code) =>
      DirectionState.values.firstWhere(
        (DirectionState s) => s.code == code,
        orElse: () =>
            throw ArgumentError.value(code, 'code', 'DirectionState 가 아니다'),
      );
}

/// 추세성 상태(03 §1-8 `apply_trend_hysteresis` 의 결과). 초기값은 `low`(fail-closed).
enum TrendState {
  /// 고추세.
  high('HIGH'),

  /// 저추세.
  low('LOW');

  const TrendState(this.code);

  /// 저장·골든 표기.
  final String code;

  /// [code] 에서 되돌린다. 모르는 값이면 [ArgumentError].
  static TrendState fromCode(String code) => TrendState.values.firstWhere(
    (TrendState s) => s.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'TrendState 가 아니다'),
  );
}
