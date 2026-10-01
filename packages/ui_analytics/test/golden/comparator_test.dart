// comparator_test.dart — «유의 픽셀» 비교기의 자체 검증 (C-2 하네스 · M2 소유 · 3판)
//
// 하네스가 «무엇을 무시하고 무엇을 잡는가»를 코드로 고정한다. 이것들이 깨지면 골든 게이트의
// 뜻이 바뀐 것이다 — 임계를 바꾸기 전에 이 파일을 먼저 읽는다.
//   무시: ① 같은 그림 ② 1px 이동(가로·대각) ③ 작은 회색 차(AA) ④ 가는 획의 농도 차
//         («진한 1칸» vs «흐린 2칸» — 어두운 배경의 밝은 글자에서 플랫폼마다 다르다)
//   잡음: ⑤ 속이 찬 칩 누락 ⑥ **가는 테두리뿐인 칩 누락**(2판이 놓치던 것) ⑦ 2px 이동
//   판정(🆕 2026-10-01 · 보조 기준 0.5% → 1.0%): 폰 크기(390×844) 캔버스에서 실제 상수와 실제
//         판정 함수(acceptsSignificantDiff)로 — ⑧ 흩어진 0.6~0.9% 소음 통과(PR #19 의 0.592% 재현
//         포함) ⑨ 경계 바로 아래 통과 · 바로 위 실패 ⑩ 아이콘 1개 누락 실패(소음과 겹쳐도)
//
// 🔴 dart:ui 이미지 디코드를 쓰지 않는다 — 바이트 버퍼를 직접 만든다(빠르고 결정적).

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../flutter_test_config.dart'
    show kGoldenMaxWindowDensity, kGoldenSignificantDiffTolerance;
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

    test('small icon-sized outline missing: tiny total, dense window', () {
      // 18px lock icon in the real J-1 screen: total 0.06% but window density 27%.
      final Uint8List a = _canvas(); // candidate: icon missing
      final Uint8List b = _canvas();
      _outline(b, 50, 30, 16, 16);
      final SignificantDiffStats s = analyzeSignificantDiffs(
        a,
        b,
        width: _w,
        height: _h,
      );
      expect(s.total / (_w * _h), lessThan(0.05), reason: 'small overall');
      expect(
        s.maxWindowDensity,
        greaterThan(0.12),
        reason: 'but clustered -> the window rule must catch it',
      );
    });

    test('scattered platform-like noise: low window density', () {
      // isolated 3x3 specks every 20px: spread thin, never clustered.
      final Uint8List a = _canvas();
      final Uint8List b = _canvas();
      for (int y = 6; y < _h - 6; y += 20) {
        for (int x = 6; x < _w - 6; x += 20) {
          _rect(b, x, y, 3, 3);
        }
      }
      final SignificantDiffStats s = analyzeSignificantDiffs(
        a,
        b,
        width: _w,
        height: _h,
      );
      expect(s.total, greaterThan(0));
      expect(s.maxWindowDensity, lessThan(0.12));
    });

    test('2px shift is NOT absorbed by radius 1', () {
      final Uint8List a = _canvas();
      _rect(a, 10, 10, 60, 32);
      final Uint8List b = _canvas();
      _rect(b, 12, 10, 60, 32);
      expect(_count(a, b), greaterThan(0));
    });
  });

  // Phone-size verdicts with the real thresholds. Each isolated 2x2 speck on the
  // light background yields exactly 12 significant pixels after the 3x3 blur, and
  // specks 26px apart never share a 24x24 window enough to look clustered — so a
  // speck count sets the overall ratio exactly (390x844 = 329,160 px).
  group('verdict at phone size (secondary 1.0%, window 12%)', () {
    test('one speck = 12 significant px, scattered grid stays thin', () {
      final _Phone p = _Phone()..scatter(1);
      expect(p.stats().total, 12);
      final _Phone q = _Phone()..scatter(_specksFor(0.009));
      expect(q.stats().maxWindowDensity, lessThan(0.05));
    });

    test(
      'PR #19 linux noise replayed (0.592%): rejected at 0.5%, accepted now',
      () {
        // s74_pension_limit_hit_light on CI: 1,950 px = 0.592%, window 5.2%.
        final _Phone p = _Phone()..scatter(163); // 1,956 px = 0.594%
        final SignificantDiffStats s = p.stats();
        expect(s.total / _Phone.area, closeTo(0.00592, 0.0001));
        expect(
          p.accepts(s, tolerance: 0.005),
          isFalse,
          reason: 'old secondary',
        );
        expect(p.accepts(s), isTrue, reason: 'new secondary');
      },
    );

    for (final double target in <double>[0.006, 0.0075, 0.009]) {
      test(
        'scattered noise ${(target * 100).toStringAsFixed(2)}% -> accepted',
        () {
          final _Phone p = _Phone()..scatter(_specksFor(target));
          final SignificantDiffStats s = p.stats();
          expect(s.total / _Phone.area, closeTo(target, 0.0001));
          expect(p.accepts(s), isTrue);
        },
      );
    }

    test('scattered noise just below the secondary limit -> accepted', () {
      final _Phone p = _Phone()..scatter(274); // 3,288 px = 0.9989%
      final SignificantDiffStats s = p.stats();
      expect(
        s.total / _Phone.area,
        lessThanOrEqualTo(kGoldenSignificantDiffTolerance),
      );
      expect(p.accepts(s), isTrue);
    });

    test('scattered noise just above the secondary limit -> rejected', () {
      final _Phone p = _Phone()..scatter(275); // 3,300 px = 1.0026%
      final SignificantDiffStats s = p.stats();
      expect(
        s.total / _Phone.area,
        greaterThan(kGoldenSignificantDiffTolerance),
      );
      expect(
        s.maxWindowDensity,
        lessThan(kGoldenMaxWindowDensity),
        reason: 'thin: only the secondary rule can catch it',
      );
      expect(p.accepts(s), isFalse);
    });

    test(
      'one 18px icon missing on a clean screen -> rejected by the window',
      () {
        final _Phone p = _Phone()..dropIcon();
        final SignificantDiffStats s = p.stats();
        expect(s.total / _Phone.area, lessThan(0.001), reason: 'tiny overall');
        expect(s.maxWindowDensity, greaterThan(kGoldenMaxWindowDensity));
        expect(p.accepts(s), isFalse);
      },
    );

    test(
      'one 18px icon missing under 0.9% scattered noise -> still rejected',
      () {
        final _Phone p = _Phone()
          ..scatter(_specksFor(0.009))
          ..dropIcon();
        final SignificantDiffStats s = p.stats();
        expect(
          s.total / _Phone.area,
          lessThanOrEqualTo(kGoldenSignificantDiffTolerance),
        );
        expect(s.maxWindowDensity, greaterThan(kGoldenMaxWindowDensity));
        expect(p.accepts(s), isFalse);
      },
    );
  });
}

/// Specks needed for [ratio] of the phone area (12 px each, rounded).
int _specksFor(double ratio) => (ratio * _Phone.area / 12).round();

/// A 390x844 candidate (blank) and golden pair; noise and the icon go in the golden.
class _Phone {
  static const int w = 390;
  static const int h = 844;
  static const int area = w * h;

  final Uint8List candidate = _fill();
  final Uint8List golden = _fill();

  static Uint8List _fill() {
    final Uint8List px = Uint8List(w * h * 4);
    for (int i = 0; i < px.length; i += 4) {
      px[i] = 250;
      px[i + 1] = 250;
      px[i + 2] = 250;
      px[i + 3] = 255;
    }
    return px;
  }

  void _box(int x0, int y0, int bw, int bh) {
    for (int y = y0; y < y0 + bh; y++) {
      for (int x = x0; x < x0 + bw; x++) {
        final int i = (y * w + x) * 4;
        golden[i] = 20;
        golden[i + 1] = 20;
        golden[i + 2] = 20;
      }
    }
  }

  /// [n] isolated 2x2 specks, 26px apart, row by row (15 per row).
  void scatter(int n) {
    int placed = 0;
    for (int y = 4; y < h - 4 && placed < n; y += 26) {
      for (int x = 4; x < w - 4 && placed < n; x += 26) {
        _box(x, y, 2, 2);
        placed++;
      }
    }
    if (placed < n) {
      throw StateError('not enough room for $n specks');
    }
  }

  /// An 18px outlined icon (1px border) in a speck-free gap of the grid.
  void dropIcon() {
    const int x0 = 186;
    const int y0 = 790;
    _box(x0, y0, 18, 1);
    _box(x0, y0 + 17, 18, 1);
    _box(x0, y0, 1, 18);
    _box(x0 + 17, y0, 1, 18);
  }

  SignificantDiffStats stats() =>
      analyzeSignificantDiffs(candidate, golden, width: w, height: h);

  bool accepts(
    SignificantDiffStats s, {
    double tolerance = kGoldenSignificantDiffTolerance,
  }) => acceptsSignificantDiff(
    s,
    width: w,
    height: h,
    tolerance: tolerance,
    maxWindowDensity: kGoldenMaxWindowDensity,
  );
}
