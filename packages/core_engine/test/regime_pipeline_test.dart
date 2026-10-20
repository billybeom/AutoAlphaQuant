// 국면 파이프라인 규약 중 26년 재현(test/replay)이 직접 보지 않는 것 — 작은 손계산 · 입력 거부 · 03 데이터 부족 규약.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final DirectionHysteresis _dir = DirectionHysteresis(
  up: 60,
  down: 40,
  confirmBars: 3,
  minHoldBars: 10,
);
final TrendHysteresis _trend = TrendHysteresis(
  trendIn: 35,
  trendOut: 45,
  confirmBars: 3,
);

void main() {
  group('pitPercentile', () {
    test('표본이 minPeriods 에 닿기 전은 null · 결측 날은 null(표본에도 안 넣는다)', () {
      final List<double?> r = pitPercentile(
        <double?>[3, 1, null, 2, 5],
        minPeriods: 3,
        lowerQuantile: 0,
        upperQuantile: 1,
      );
      expect(r[0], isNull);
      expect(r[1], isNull);
      expect(r[2], isNull);
      // 표본 {1,2,3} 에서 2 의 순위 2 → 2/3 × 100.
      expect(r[3], closeTo(200 / 3, 1e-12));
      // 표본 {1,2,3,5} 에서 5 → 4/4 × 100.
      expect(r[4], 100.0);
    });
    test('동률은 평균 순위', () {
      final List<double?> r = pitPercentile(
        <double?>[1, 1, 1, 1],
        minPeriods: 1,
        lowerQuantile: 0,
        upperQuantile: 1,
      );
      // 4개 모두 같으면 평균 순위 2.5 → 2.5/4.
      expect(r[3], 62.5);
    });
    test('윈저화 — 그 시점의 분위수로 한 번만 자른다(PIT · 과거 값을 오늘 경계로 다시 자르지 않음)', () {
      // minPeriods 2 · 분위수 0.5(중앙값). t0 = 10 은 경계가 없어 안 잘린 채 남는다.
      // t1 = 1 → 원표본 {1,10} 중앙값 5.5 로 올려 잘림 → 잘린 표본 {5.5, 10} 에서 순위 1 → 50.
      // t2 = 1 → 원표본 {1,1,10} 중앙값 1 → 그대로 1 → 잘린 표본 {1, 5.5, 10} 에서 순위 1 → 100/3.
      // (오늘 경계로 전부 다시 자르면 10 도 1 이 되어 동률 평균 순위가 나온다 — 다른 답.)
      final List<double?> r = pitPercentile(
        <double?>[10, 1, 1],
        minPeriods: 2,
        lowerQuantile: 0.5,
        upperQuantile: 0.5,
      );
      expect(r[0], isNull);
      expect(r[1], 50.0);
      expect(r[2], closeTo(100 / 3, 1e-12));
    });
    test('입력 거부', () {
      expect(
        () => pitPercentile(<double?>[1], minPeriods: 0),
        throwsArgumentError,
      );
      expect(
        () =>
            pitPercentile(<double?>[1], lowerQuantile: 0.6, upperQuantile: 0.4),
        throwsArgumentError,
      );
      expect(
        () => pitPercentile(<double?>[1], lowerQuantile: -0.1),
        throwsArgumentError,
      );
      expect(
        () => pitPercentile(<double?>[1], upperQuantile: 1.1),
        throwsArgumentError,
      );
    });
  });

  group('rollingPercentile', () {
    test('창이 다 차야 값 · 창 안 결측이면 null', () {
      final List<double?> r = rollingPercentile(<double?>[
        3,
        1,
        2,
        null,
        4,
        5,
        6,
      ], 3);
      expect(r.sublist(0, 2), <double?>[null, null]);
      expect(r[2], closeTo(200 / 3, 1e-12)); // {3,1,2} 에서 2 → 2/3
      expect(r[3], isNull);
      expect(r[4], isNull); // 창 {2, null, 4}
      expect(r[5], isNull); // 창 {null, 4, 5}
      expect(r[6], 100.0); // {4,5,6} 에서 6
    });
    test('창 0 거부', () {
      expect(() => rollingPercentile(<double?>[1], 0), throwsArgumentError);
    });
  });

  group('원지표', () {
    test('12-1 모멘텀 = 21봉 전 / 252봉 전 − 1 · 워밍업 252봉', () {
      final List<double?> c = <double?>[
        for (int i = 0; i < 260; i++) 100.0 + i,
      ];
      final List<double?> m = momentum12Minus1(c);
      expect(m[251], isNull);
      expect(m[252], closeTo((100.0 + 231) / 100.0 - 1, 1e-15));
    });
    test('분산일 — 0.2% 이상 하락 + 거래량 증가 · 5% 회복하면 빼고 · 길이 다르면 거부', () {
      final List<double?> c = <double?>[100, 99.7, 99.0, 104.0];
      final List<double?> v = <double?>[10, 11, 9, 12];
      final List<double> d = distributionDays(c, v);
      expect(d[1], 1.0); // −0.3% · 거래량 ↑
      expect(d[2], 1.0); // −0.7% 지만 거래량 ↓ → 분산일 아님
      // 그 뒤 최고 104/99.7 − 1 = 4.31% < 5% — 회복 못 해 남는다.
      expect(d[3], 1.0);
    });
    test('분산일 — 회복 5% 이상이면 센 데서 빠진다', () {
      final List<double?> c = <double?>[100, 99.7, 105.0];
      final List<double?> v = <double?>[10, 11, 9];
      expect(distributionDays(c, v)[2], 0.0); // 105/99.7 − 1 = 5.3%
      expect(() => distributionDays(c, <double?>[1]), throwsArgumentError);
    });
    test('골든크로스 · 200일선 기울기 — 같으면 거짓(strict >)', () {
      final Map<String, List<double?>> t = trendIndicators(
        List<double?>.filled(230, 100.0),
      );
      expect(t['golden_cross']![198], isNull); // SMA200 워밍업
      expect(t['golden_cross']![199], 0.0); // SMA50 = SMA200
      expect(t['ma200_slope']![219], isNull); // 21봉 전 SMA200 없음
      expect(t['ma200_slope']![220], 0.0); // 같은 값
    });
    test('정규화 — 이진은 ×100 · INVERSE 는 100 − pct · 설정 없는 지표는 거부', () {
      final Map<String, List<double?>> n = normalizeIndicators(
        <String, List<double?>>{
          'golden_cross': <double?>[1.0, 0.0, null],
          'vix_level': <double?>[1, 2, 3],
        },
        minPeriods: 1,
      );
      expect(n['golden_cross'], <double?>[100.0, 0.0, null]);
      expect(
        n['vix_level']![2],
        closeTo(0.0, 1e-12),
      ); // 최고값 → pct 100 → INVERSE 0
      expect(
        () => normalizeIndicators(<String, List<double?>>{
          'nope': <double?>[1],
        }),
        throwsArgumentError,
      );
    });
  });

  group('FSM — 03 데이터 부족 규약(R9)', () {
    test('부족한 봉: UNKNOWN 저장 · 익스포저 0 · 나이·추세성 유지 → 다음 봉은 UNKNOWN 에서', () {
      final List<double?> d = <double?>[50, 50, 50, null, 50, 50, 50];
      final List<double?> t = <double?>[50, 50, 50, 50, 50, 50, 50];
      final List<RegimeDay> r = runRegimeFsm(
        d,
        t,
        directionConfig: _dir,
        trendConfig: _trend,
      );
      expect(r[2].directionState, DirectionState.neutral);
      expect(r[2].trendState, TrendState.high);
      expect(r[3].status, RegimeStatus.insufficientData);
      expect(r[3].directionState, DirectionState.unknown);
      expect(r[3].exposure, 0.0);
      expect(r[3].barsInState, r[2].barsInState);
      expect(r[3].trendState, TrendState.high);
      // 창에 결측이 섞인 동안(4·5번 봉)은 UNKNOWN 유지, 6번 봉에 창이 다시 차면 mid → NEUTRAL(나이 ≥ 10 이 아니어도
      // 직전이 BULL 이 아니므로 최소 유지가 걸린다 → 아직 UNKNOWN).
      expect(r[4].directionState, DirectionState.unknown);
      expect(r[6].directionState, DirectionState.unknown);
    });
    test('추세성만 결측이어도 부족', () {
      final List<RegimeDay> r = runRegimeFsm(
        <double?>[50],
        <double?>[null],
        directionConfig: _dir,
        trendConfig: _trend,
      );
      expect(r.single.status, RegimeStatus.insufficientData);
    });
    test('길이 다르면 거부', () {
      expect(
        () => runRegimeFsm(
          <double?>[1, 2],
          <double?>[1],
          directionConfig: _dir,
          trendConfig: _trend,
        ),
        throwsArgumentError,
      );
    });
  });

  group('살아 있는 값 평균', () {
    test('최소 개수 미달이면 null', () {
      final List<double?> r = meanOfAvailable(<List<double?>>[
        <double?>[1, null, null],
        <double?>[3, 5, null],
      ], minValid: 2);
      expect(r, <double?>[2.0, null, null]);
    });
  });
}
