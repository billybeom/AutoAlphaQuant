// 국면 집계·히스테리시스의 규약 중 골든(GV-1·GV-4)이 직접 다루지 않는 것 — 03 §1-1 · §1-7 · §1-8.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final DirectionHysteresis _cfg = DirectionHysteresis(
  up: 60,
  down: 40,
  confirmBars: 3,
  minHoldBars: 10,
);

void main() {
  group('카테고리 점수 — 가중 평균(03 §1-1 v2.13)', () {
    test('살아 있는 지표의 weight 만 분모에 들어간다', () {
      // (80×1 + 40×0.5) / (1 + 0.5) = 100 / 1.5
      expect(
        categoryScore(
          const CategoryInput(
            definedCount: 3,
            available: <IndicatorScore>[
              IndicatorScore(80),
              IndicatorScore(40, weight: 0.5),
            ],
          ),
          minValidRatio: 0.5,
        ),
        closeTo(100 / 1.5, 1e-12),
      );
    });

    test('살아 있는 지표가 ceil(비율 × 정의 수) 보다 적으면 제외(null)', () {
      expect(
        categoryScore(
          const CategoryInput(
            definedCount: 4,
            available: <IndicatorScore>[IndicatorScore(90)],
          ),
          minValidRatio: 0.5,
        ),
        isNull,
      );
    });

    test('넘기지 않은(꺼진) 카테고리는 점수에도 제외 목록에도 없다', () {
      final DirectionScore r = aggregateDirection(
        <RegimeCategory, CategoryInput>{
          RegimeCategory.trend: const CategoryInput(
            definedCount: 1,
            available: <IndicatorScore>[IndicatorScore(70)],
          ),
          RegimeCategory.breadth: const CategoryInput(
            definedCount: 2,
            available: <IndicatorScore>[],
          ),
        },
        minValidRatio: 0.5,
      );
      expect(r.categories.keys, <RegimeCategory>[RegimeCategory.trend]);
      expect(r.excluded, <RegimeCategory>[RegimeCategory.breadth]);
      expect(r.direction, 70);
    });

    test('비율이 0~1 밖이면 거부', () {
      const CategoryInput input = CategoryInput(
        definedCount: 1,
        available: <IndicatorScore>[IndicatorScore(50)],
      );
      expect(
        () => categoryScore(input, minValidRatio: 1.5),
        throwsArgumentError,
      );
      expect(
        () => categoryScore(input, minValidRatio: double.nan),
        throwsArgumentError,
      );
    });
  });

  group('직전 상태가 UNKNOWN 인 봉(05 §GV-3c 📌 의 «다음 날» 경로)', () {
    test('하방 3봉이면 즉시 BEAR', () {
      final ({DirectionState state, int barsInState}) r = applyHysteresis(
        <double?>[30, 30, 30],
        DirectionState.unknown,
        0,
        _cfg,
      );
      expect(r.state, DirectionState.bear);
      expect(r.barsInState, 0);
    });

    test('상방 3봉이어도 최소 유지 전이면 UNKNOWN 그대로 — 익스포저 0 이 이어진다', () {
      final ({DirectionState state, int barsInState}) r = applyHysteresis(
        <double?>[70, 70, 70],
        DirectionState.unknown,
        3,
        _cfg,
      );
      expect(r.state, DirectionState.unknown);
      expect(r.barsInState, 4);
    });
  });

  group('경계값 — above·below 는 strict (03 §1-7 ④)', () {
    // GV-4g 는 직전 BULL 이라 mid 가 먼저 받는다. 직전 NEUTRAL 이면 mid 는 전환이 없으므로
    // above·below 를 inclusive 로 쓴 구현만 여기서 전환해 버린다.
    test('정확히 60.0 이 3봉이어도 NEUTRAL → BULL 이 아니다', () {
      final ({DirectionState state, int barsInState}) r = applyHysteresis(
        <double?>[60, 60, 60],
        DirectionState.neutral,
        99,
        _cfg,
      );
      expect(r.state, DirectionState.neutral);
      expect(r.barsInState, 100);
    });

    test('정확히 40.0 이 3봉이어도 NEUTRAL → BEAR 가 아니다', () {
      final ({DirectionState state, int barsInState}) r = applyHysteresis(
        <double?>[40, 40, 40],
        DirectionState.neutral,
        99,
        _cfg,
      );
      expect(r.state, DirectionState.neutral);
      expect(r.barsInState, 100);
    });
  });

  group('설정 거부', () {
    test('down >= up 이면 거부', () {
      expect(
        () => DirectionHysteresis(
          up: 40,
          down: 40,
          confirmBars: 3,
          minHoldBars: 10,
        ),
        throwsArgumentError,
      );
    });

    test('확인 봉 0 은 거부', () {
      expect(
        () => DirectionHysteresis(
          up: 60,
          down: 40,
          confirmBars: 0,
          minHoldBars: 10,
        ),
        throwsArgumentError,
      );
      expect(
        () => TrendHysteresis(trendIn: 35, trendOut: 45, confirmBars: 0),
        throwsArgumentError,
      );
    });

    test('trendIn >= trendOut 이면 거부', () {
      expect(
        () => TrendHysteresis(trendIn: 45, trendOut: 35, confirmBars: 3),
        throwsArgumentError,
      );
    });
  });
}
