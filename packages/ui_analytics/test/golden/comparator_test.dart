// comparator_test.dart — «유의 픽셀» 비교기의 자체 검증 (C-2 하네스 · M2 소유 · 3판)
//
// 하네스가 «무엇을 무시하고 무엇을 잡는가»를 코드로 고정한다. 이것들이 깨지면 골든 게이트의
// 뜻이 바뀐 것이다 — 임계를 바꾸기 전에 이 파일을 먼저 읽는다.
//   무시: ① 같은 그림 ② 1px 이동(가로·대각) ③ 작은 회색 차(AA) ④ 가는 획의 농도 차
//         («진한 1칸» vs «흐린 2칸» — 어두운 배경의 밝은 글자에서 플랫폼마다 다르다)
//   잡음: ⑤ 속이 찬 칩 누락 ⑥ **가는 테두리뿐인 칩 누락**(2판이 놓치던 것) ⑦ 2px 이동
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

/// 1px 두께의 빈 상자(테두리만).
void _outline(Uint8List px, int x0, int y0, int w, int h, {int gray = 20}) {
  _rect(px, x0, y0, w, 1, gray: gray);
  _rect(px, x0, y0 + h - 1, w, 1, gray: gray);
  _rect(px, x0, y0, 1, h, gray: gray);
  _rect(px, x0 + w - 1, y0, 1, h, gray: gray);
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
  group('shift-tolerant golden compare (v3: blur + symmetric)', () {
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

    test('1px shift of a thin outlined box -> 0', () {
      final Uint8List a = _canvas();
      _outline(a, 10, 10, 60, 32);
      final Uint8List b = _canvas();
      _outline(b, 11, 10, 60, 32);
      expect(_count(a, b), 0);
    });

    test('anti-aliasing-like small gray delta -> 0', () {
      final Uint8List a = _canvas(bg: 250);
      final Uint8List b = _canvas(bg: 236); // delta 14 <= 48
      expect(_count(a, b), 0);
    });

    test('thin stroke density: one solid column vs two half columns -> 0', () {
      // dark background, light text: platform gamma renders a 1px stroke either as
      // one strong column or as two weak columns.
      final Uint8List a = _canvas(bg: 20);
      _rect(a, 40, 10, 1, 40, gray: 230);
      final Uint8List b = _canvas(bg: 20);
      _rect(b, 40, 10, 1, 40, gray: 125);
      _rect(b, 41, 10, 1, 40, gray: 125);
      expect(_count(a, b), 0);
      expect(_count(b, a), 0);
    });

    test('missing solid chip -> roughly its area, either direction', () {
      final Uint8List a = _canvas(); // candidate: chip missing
      final Uint8List b = _canvas();
      _rect(b, 10, 10, 60, 32); // golden: chip present
      final int n = _count(a, b);
      // 60×32 = 1,920. Blur softens the rim; the interior (58×30) is the floor
      // and the 1px halo (62×34) is the ceiling.
      expect(n, greaterThanOrEqualTo(58 * 30));
      expect(n, lessThanOrEqualTo(62 * 34));
      expect(_count(b, a), n, reason: 'the check is symmetric');
    });

    test('missing OUTLINED chip (1px border only) is detected', () {
      // v2 (one-directional) returned ~0 here: every background pixel of the
      // candidate finds background in the golden neighbourhood.
      final Uint8List a = _canvas(); // candidate: outlined chip missing
      final Uint8List b = _canvas();
      _outline(b, 10, 10, 60, 32);
      final int n = _count(a, b);
      // perimeter = 2*(60+32)-4 = 180 px; blur widens it to ~3px.
      expect(n, greaterThanOrEqualTo(180));
      expect(_count(b, a), n);
    });

    test('2px shift is NOT absorbed by radius 1', () {
      final Uint8List a = _canvas();
      _rect(a, 10, 10, 60, 32);
      final Uint8List b = _canvas();
      _rect(b, 12, 10, 60, 32);
      expect(_count(a, b), greaterThan(0));
    });
  });
}
