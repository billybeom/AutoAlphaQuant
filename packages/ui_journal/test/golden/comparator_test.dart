// comparator_test.dart — «유의 픽셀» 비교기의 자체 검증 (C-2 하네스 · M2 소유)
//
// 하네스가 «무엇을 무시하고 무엇을 잡는가»를 코드로 고정한다. 이 셋이 깨지면 골든 게이트의
// 뜻이 바뀐 것이다 — 임계를 바꾸기 전에 이 파일을 먼저 읽는다.
//   ① 같은 그림 → 0
//   ② 사각형이 1px 옆으로 이동 → 0 (플랫폼 글자 위치 차이의 모형)
//   ③ 사각형(칩 크기)이 사라짐 → 그 넓이만큼 유의 픽셀 (누락 탐지의 모형)
//   ④ 배경만 살짝 다른 회색(AA 모형) → 0
//
// 🔴 dart:ui 이미지 디코드를 쓰지 않는다 — 바이트 버퍼를 직접 만든다(빠르고 결정적).

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'shift_tolerant_compare.dart';

const int _w = 120;
const int _h = 80;

Uint8List _canvas({int bg = 250}) {
  final Uint8List px = Uint8List(_w * _h * 4);
  for (int i = 0; i < px.length; i += 4) {
    px[i] = bg;
    px[i + 1] = bg;
    px[i + 2] = bg;
    px[i + 3] = 255;
  }
  return px;
}

void _rect(Uint8List px, int x0, int y0, int w, int h, {int gray = 20}) {
  for (int y = y0; y < y0 + h; y++) {
    for (int x = x0; x < x0 + w; x++) {
      final int i = (y * _w + x) * 4;
      px[i] = gray;
      px[i + 1] = gray;
      px[i + 2] = gray;
      px[i + 3] = 255;
    }
  }
}

int _count(Uint8List a, Uint8List b) => countSignificantDiffs(
  a,
  b,
  width: _w,
  height: _h,
  radius: 1,
  channelDelta: 48,
);

void main() {
  group('shift-tolerant golden compare', () {
    test('identical images -> 0 significant pixels', () {
      final Uint8List a = _canvas();
      _rect(a, 10, 10, 60, 32);
      final Uint8List b = _canvas();
      _rect(b, 10, 10, 60, 32);
      expect(_count(a, b), 0);
    });

    test('1px horizontal shift of a glyph-like box -> 0', () {
      final Uint8List a = _canvas();
      _rect(a, 10, 10, 60, 32);
      final Uint8List b = _canvas();
      _rect(b, 11, 10, 60, 32);
      expect(_count(a, b), 0);
      expect(_count(b, a), 0);
    });

    test('1px diagonal shift -> 0', () {
      final Uint8List a = _canvas();
      _rect(a, 10, 10, 60, 32);
      final Uint8List b = _canvas();
      _rect(b, 11, 11, 60, 32);
      expect(_count(a, b), 0);
    });

    test('missing chip-sized box -> roughly its area is significant', () {
      final Uint8List a = _canvas(); // candidate: chip missing
      final Uint8List b = _canvas();
      _rect(b, 10, 10, 60, 32); // golden: chip present
      final int n = _count(a, b);
      // 60×32 = 1,920. The 1px rim can match neighbours, so allow the interior
      // (58×30 = 1,740) as the floor.
      expect(n, greaterThanOrEqualTo(58 * 30));
      expect(n, lessThanOrEqualTo(60 * 32));
      // and the reverse direction (extra chip) is also detected
      expect(_count(b, a), greaterThanOrEqualTo(58 * 30));
    });

    test('anti-aliasing-like small gray delta -> 0', () {
      final Uint8List a = _canvas(bg: 250);
      final Uint8List b = _canvas(bg: 236); // delta 14 <= 48
      expect(_count(a, b), 0);
    });

    test(
      '2px shift is NOT absorbed by radius 1 (guards the tolerance meaning)',
      () {
        final Uint8List a = _canvas();
        _rect(a, 10, 10, 60, 32);
        final Uint8List b = _canvas();
        _rect(b, 12, 10, 60, 32);
        expect(_count(a, b), greaterThan(0));
      },
    );
  });
}
