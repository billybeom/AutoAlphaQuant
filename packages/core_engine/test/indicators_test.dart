// 지표의 결측·인자 규약 — 03 §0-3·§1-5 본문 중 골든(GV-2)이 다루지 않는 것.
//
// 기대값은 참조 구현 `09_백테스트/백테스트6/engine/indicators.py` 의 코드를 손으로 따라가 정했다
// (NaN = null). ⚠️ 이 PC 의 Python 에는 pandas 가 없어 참조 엔진을 직접 돌리지 못했다 —
// 골든(GV-2)은 참조 구현이 낸 값이라 그쪽이 실측 대조다.

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/src/signals/indicators.dart'
    show directionalMovement;
import 'package:test/test.dart';

void main() {
  group('SMA', () {
    test('인덱스 n−1 부터 값', () {
      expect(sma(<double?>[1, 2, 3, 4], 2), <double?>[null, 1.5, 2.5, 3.5]);
    });

    test('창에 결측이 있으면 결측 — 앞으로 채우지 않는다', () {
      expect(sma(<double?>[1, null, 3, 4], 2), <double?>[
        null,
        null,
        null,
        3.5,
      ]);
    });
  });

  group('rma(Wilder) 결측 규약 (03 §0-3)', () {
    test('선행 결측은 건너뛰고 첫 유효값부터 n개 SMA 로 시작한다', () {
      expect(rma(<double?>[null, null, 1, 2, 3, 4], 2), <double?>[
        null,
        null,
        null,
        1.5,
        2.25,
        3.125,
      ]);
    });

    test('중간 결측이 오면 그 뒤는 전부 결측', () {
      expect(rma(<double?>[1, 2, null, 4, 5], 2), <double?>[
        null,
        1.5,
        null,
        null,
        null,
      ]);
    });

    test('시드 창에 결측이 섞이면 전부 결측', () {
      expect(rma(<double?>[1, null, 3, 4, 5], 3), <double?>[
        null,
        null,
        null,
        null,
        null,
      ]);
    });

    test('값이 n개보다 적으면 전부 결측', () {
      expect(rma(<double?>[1, 2], 3), <double?>[null, null]);
    });
  });

  group('TR 결측 규약', () {
    test('전날 종가가 빠지면 그다음 날 TR 이 결측 — 첫 봉은 H−L', () {
      expect(
        trueRange(<double?>[110, 112, 115], <double?>[100, 104, 107], <double?>[
          105,
          null,
          110,
        ]),
        <double?>[10, 8, null],
      );
    });
  });

  group('±DM (03 §1-5)', () {
    test('두 폭이 같으면 둘 다 0 — «크고» 는 엄격 비교다', () {
      // i=1: 고가 +2 · 저가 −2(동률) → 0/0 · i=2: +DM 1 · i=3: −DM 2
      final ({List<double> plus, List<double> minus}) dm = directionalMovement(
        <double?>[10, 12, 13, 13],
        <double?>[9, 7, 8, 6],
      );
      expect(dm.plus, <double>[0, 0, 1, 0]);
      expect(dm.minus, <double>[0, 0, 0, 2]);
    });

    test('차분이 결측이면 0 — 결측이 아니라 0 이다(참조 구현 np.where)', () {
      final ({List<double> plus, List<double> minus}) dm = directionalMovement(
        <double?>[10, null, 12],
        <double?>[9, 8, 7],
      );
      expect(dm.plus, <double>[0, 0, 0]);
      expect(dm.minus, <double>[0, 0, 0]);
    });
  });

  test('ADX — warmup 보다 훨씬 짧은 시리즈도 오류 없이 전부 결측', () {
    final List<double?> x = <double?>[for (int i = 0; i < 100; i++) 100.0 + i];
    expect(
      adx(x, x, x, period: 14, warmup: 150),
      List<double?>.filled(100, null),
    );
  });

  group('인자 거부', () {
    final List<double?> x = <double?>[1, 2, 3];

    test('period 0 은 거부', () {
      expect(() => sma(x, 0), throwsArgumentError);
      expect(() => rma(x, 0), throwsArgumentError);
      expect(() => atr(x, x, x, 0), throwsArgumentError);
    });

    test('CHOP 는 n = 1 을 거부한다(log10(1) = 0)', () {
      expect(() => chop(x, x, x, 1), throwsArgumentError);
    });

    test('ADX warmup 0 은 거부', () {
      expect(() => adx(x, x, x, period: 14, warmup: 0), throwsArgumentError);
    });

    test('high·low·close 길이가 다르면 거부', () {
      expect(() => trueRange(x, <double?>[1, 2], x), throwsArgumentError);
      expect(() => chop(x, x, <double?>[1], 2), throwsArgumentError);
    });
  });
}
