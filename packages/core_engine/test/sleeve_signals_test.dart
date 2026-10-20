// 슬리브 신호 규약 중 정답지가 직접 보지 않는 것 — 03 v2.27 P0S 하한·BEAR 차감 · §5-3-2 입력 범위.
//
// 🔴 P0S 의 하한·차감 값은 05 GV-P0S(26년 경로)만 잰다 — 여기 기대값은 03 v2.27 블록이 적어 둔 것
//    («BEAR 에서 1 → 1/3 · 2/3 → 0 · 1/3 → 0», «하한 먼저 · 차감 나중», «워밍업이면 하한도 없음»)이다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

const List<int> _lookbacks = <int>[8, 10, 12];
// 05 GV-20 의 head — 마지막 값으로 0/⅓/⅔/1 을 고른다(b4 85 · b3 95 · b2 99 · b1 105).
const List<double> _head = <double>[
  120, 118, 116, 110, 100, 90, 85, 88, 92, 96, 100, //
];
List<double> _with(double last) => <double>[..._head, last];

final SleeveBAssist _p0s = SleeveBAssist(
  floor: 1.0 / 3,
  cutState: DirectionState.bear,
  cut: 2.0 / 3,
);

double _p0(double last, DirectionState state, {SleeveBAssist? assist}) =>
    sleeveBTargetRatioP0(
      _with(last),
      lookbackMonths: _lookbacks,
      assist: assist ?? _p0s,
      regimeState: state,
    );

void main() {
  group('P0S 하한 1/3 → BEAR 차감 2/3(03 v2.27)', () {
    test('BEAR 아님 — 0 은 하한 1/3 으로, 나머지는 그대로', () {
      for (final DirectionState s in <DirectionState>[
        DirectionState.bull,
        DirectionState.neutral,
        DirectionState.unknown,
      ]) {
        expect(_p0(85, s), 1.0 / 3, reason: '$s');
        expect(_p0(95, s), 1.0 / 3, reason: '$s');
        expect(_p0(99, s), 2.0 / 3, reason: '$s');
        expect(_p0(105, s), 1.0, reason: '$s');
      }
    });
    test('BEAR — 1 → 1/3 · 2/3 → 0 · 1/3 → 0 · 0 → 0(차감은 승수가 아니다)', () {
      expect(_p0(105, DirectionState.bear), closeTo(1.0 / 3, 1e-15));
      expect(_p0(99, DirectionState.bear), 0.0);
      expect(_p0(95, DirectionState.bear), 0.0);
      expect(_p0(85, DirectionState.bear), 0.0);
    });
    test('BEAR 1 → 1/3 은 파이썬과 같은 이진 값(1.0 − 2/3 = 0.33333333333333337)', () {
      expect(_p0(105, DirectionState.bear), 0.33333333333333337);
    });
    test('워밍업이면 하한도 차감도 없이 0.0', () {
      expect(
        sleeveBTargetRatioP0(
          _head,
          lookbackMonths: _lookbacks,
          assist: _p0s,
          regimeState: DirectionState.bull,
        ),
        0.0,
      );
    });
    test('하한 0 · 차감 상태 없음 = 명세 기본 비율 그대로', () {
      final SleeveBAssist off = SleeveBAssist(floor: 0.0, cut: 2.0 / 3);
      expect(_p0(85, DirectionState.bear, assist: off), 0.0);
      expect(_p0(99, DirectionState.bear, assist: off), 2.0 / 3);
    });
    test('차감 상태를 설정에서 읽는다(NEUTRAL 로 바꾸면 NEUTRAL 에서 깎는다)', () {
      final SleeveBAssist neutralCut = SleeveBAssist(
        floor: 1.0 / 3,
        cutState: DirectionState.neutral,
        cut: 1.0 / 3,
      );
      expect(_p0(99, DirectionState.neutral, assist: neutralCut), 1.0 / 3);
      expect(_p0(99, DirectionState.bear, assist: neutralCut), 2.0 / 3);
    });
    test('설정 거부 — 하한·차감은 0~1', () {
      expect(() => SleeveBAssist(floor: -0.1, cut: 0.5), throwsArgumentError);
      expect(() => SleeveBAssist(floor: 1.1, cut: 0.5), throwsArgumentError);
      expect(() => SleeveBAssist(floor: 0.3, cut: -0.1), throwsArgumentError);
      expect(() => SleeveBAssist(floor: 0.3, cut: 1.5), throwsArgumentError);
      expect(
        () => SleeveBAssist(floor: double.nan, cut: 0.5),
        throwsArgumentError,
      );
    });
  });

  group('3-트랜치 기본', () {
    test('판정월 종가와 SMA 가 같으면 보유하지 않는다(> 엄격)', () {
      // 12개 모두 100 이면 모든 SMA = 100 = 종가 → 0.
      expect(
        sleeveBTargetWeight(
          List<double>.filled(12, 100),
          lookbackMonths: _lookbacks,
        ),
        0.0,
      );
    });
    test('룩백 순서·개수를 설정에서 읽는다', () {
      // 룩백 [8] 하나뿐이면 b3(95 > sma8 93.25) 는 1.0.
      expect(sleeveBTargetWeight(_with(95), lookbackMonths: <int>[8]), 1.0);
      // [12, 8] 이면 2개 중 1개 → 0.5.
      expect(sleeveBTargetWeight(_with(95), lookbackMonths: <int>[12, 8]), 0.5);
    });
    test('워밍업 경계 — 가장 긴 룩백과 같은 길이면 판정한다', () {
      expect(sleeveBTargetWeight(_with(105), lookbackMonths: _lookbacks), 1.0);
      expect(
        sleeveBTargetWeight(<double>[
          ..._head.skip(1),
          105,
        ], lookbackMonths: _lookbacks),
        0.0,
      );
    });
    test('빈 룩백 · 0 이하 룩백은 거부', () {
      expect(
        () => sleeveBTargetWeight(_with(95), lookbackMonths: <int>[]),
        throwsArgumentError,
      );
      expect(
        () => sleeveBTargetWeight(_with(95), lookbackMonths: <int>[0, 8]),
        throwsArgumentError,
      );
    });
  });

  group('계절 청산 비율 — 입력 범위', () {
    test('NaN 점수는 결측과 같이 전량', () {
      expect(
        seasonalExitFraction(double.nan, partialEnabled: true, minScore: 40),
        1.0,
      );
    });
    test('100 초과 점수는 거부(매도 비율이 음수가 된다)', () {
      expect(
        () => seasonalExitFraction(100.5, partialEnabled: true, minScore: 40),
        throwsArgumentError,
      );
    });
    test('꺼져 있으면 범위 밖 점수도 묻지 않고 전량(P0S 경로는 던지지 않는다)', () {
      expect(
        seasonalExitFraction(100.5, partialEnabled: false, minScore: 40),
        1.0,
      );
    });
    test('min_score 를 설정에서 읽는다', () {
      expect(seasonalExitFraction(45, partialEnabled: true, minScore: 50), 1.0);
      expect(
        seasonalExitFraction(45, partialEnabled: true, minScore: 40),
        closeTo(0.55, 1e-15),
      );
    });
  });
}
