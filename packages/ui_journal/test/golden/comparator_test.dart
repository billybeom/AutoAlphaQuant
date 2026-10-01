// comparator_test.dart — «유의 픽셀» 비교기의 자체 검증 (C-2 하네스 · M2 소유 · 3판)
//
// 하네스가 «무엇을 무시하고 무엇을 잡는가»를 코드로 고정한다. 이것들이 깨지면 골든 게이트의
// 뜻이 바뀐 것이다 — 임계를 바꾸기 전에 이 파일을 먼저 읽는다.
//   무시: ① 같은 그림 ② 1px 이동(가로·대각) ③ 작은 회색 차(AA) ④ 가는 획의 농도 차
//         («진한 1칸» vs «흐린 2칸» — 어두운 배경의 밝은 글자에서 플랫폼마다 다르다)
//   잡음: ⑤ 속이 찬 칩 누락 ⑥ **가는 테두리뿐인 칩 누락**(2판이 놓치던 것) ⑦ 2px 이동
//   판정(🆕 2026-10-01 · 보조 기준 0.5% → 1.0%): 폰 크기(390×844) 캔버스에서 실제 상수와 실제
//         판정 함수(acceptsSignificantDiff)로 — ⑧ 흩어진 0.6~0.9% 소음 통과(PR #19 의 0.592% 재현
//         포함) ⑨ 경계 바로 아래 통과 · 바로 위 실패 ⑩ 아이콘 1개 누락 실패(소음 격자 안에 겹쳐도)
//   P2(🆕 2026-10-01 · 적대 검토 infra_review — 전체 0.5% 를 넘으면 창 7% 이하만 통과):
//         ⑪ «1px 선 → 3px» 흉내(전체 0.608% · 창 8.7%) 실패 — P2 가 없으면 통과하던 것
//         ⑫ PR #19 소음 그대로(1,950px · 창 30/576) 통과 ⑬ 엄격 경계(0.486% 통과 · 0.501% 실패)
//         ⑭ 얇음 경계(창 6.25% 통과 · 7.64% 실패) ⑮ 창 12% 를 양쪽에서(뭉친 소음 30/576 ·
//         66/576 통과 · 78/576 실패) ⑯ 비교기 연결 — testExecutable 이 상수를 넘겼는지, 그리고
//         실제 PNG 두 장으로 `ShiftTolerantGoldenFileComparator.compare` 를 직접 부른다
//
// 🔴 판정 시험은 dart:ui 이미지 디코드를 쓰지 않는다 — 바이트 버퍼를 직접 만든다(빠르고 결정적).
//    ⑯ 연결 시험만 PNG 를 인코드·디코드한다(비교기의 실제 경로를 지나게).

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../flutter_test_config.dart'
    show
        ShiftTolerantGoldenFileComparator,
        kGoldenChannelDelta,
        kGoldenMaxWindowDensity,
        kGoldenShiftRadius,
        kGoldenSignificantDiffTolerance,
        kGoldenStrictDiffTolerance,
        kGoldenThinWindowDensity;
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

    test('one 18px icon missing on top of 0.9% scattered noise -> still rejected', () {
      // The icon sits inside the speck grid (a speck falls in its interior), so
      // its densest window holds icon AND noise pixels together.
      final _Phone p = _Phone()
        ..scatter(_specksFor(0.009))
        ..dropIcon(x0: 24, y0: 24);
      final SignificantDiffStats s = p.stats();
      final SignificantDiffStats iconOnly = (_Phone()..dropIcon(x0: 24, y0: 24))
          .stats();
      expect(
        s.maxWindowCount,
        greaterThan(iconOnly.maxWindowCount),
        reason: 'noise really shares the icon window',
      );
      expect(
        s.total / _Phone.area,
        lessThanOrEqualTo(kGoldenSignificantDiffTolerance),
      );
      expect(s.maxWindowDensity, greaterThan(kGoldenMaxWindowDensity));
      expect(p.accepts(s), isFalse);
    });
  });

  // P2: above the strict 0.5% the diff must be thin (window <= 7%). A thin and
  // wide regression (every 1px line drawn 3px) sits at ~0.6% total like the
  // noise, but its densest window is 8.9% against the noise's 5.2%.
  group('P2: above 0.5% total only thin diffs pass (window <= 7%)', () {
    test('line thickening 1px -> 3px replayed (0.608%, window 8.7%) -> '
        'rejected; accepted without P2', () {
      // infra_review: S7-2 with every border/grid line 3px = 0.607%, 51/576.
      final _Phone p = _Phone()..thicken(40, length: 18); // 40 x 50 px
      final SignificantDiffStats s = p.stats();
      expect(s.total, 2000);
      expect(s.maxWindowCount, 50);
      final double ratio = s.total / _Phone.area;
      expect(ratio, greaterThan(kGoldenStrictDiffTolerance));
      expect(ratio, lessThanOrEqualTo(kGoldenSignificantDiffTolerance));
      expect(s.maxWindowDensity, greaterThan(kGoldenThinWindowDensity));
      expect(s.maxWindowDensity, lessThanOrEqualTo(kGoldenMaxWindowDensity));
      expect(
        p.accepts(s, strictTolerance: kGoldenSignificantDiffTolerance),
        isTrue,
        reason: 'without P2 (secondary 1.0% + window 12%) it slips through',
      );
      expect(p.accepts(s), isFalse, reason: 'P2 catches it');
    });

    test('PR #19 linux noise exactly (1,950 px, window 30/576) -> accepted', () {
      // s74_pension_limit_hit_light on CI: 1,950 px = 0.592%, maxWindow 30/576.
      final _Phone p = _Phone()
        ..scatter(160) // 1,920 px, window 12
        ..cluster(2, pair: true, x0: 96, y0: 600); // 30 px in one window
      final SignificantDiffStats s = p.stats();
      expect(s.total, 1950);
      expect(s.maxWindowCount, 30);
      expect(s.total / _Phone.area, greaterThan(kGoldenStrictDiffTolerance));
      expect(p.accepts(s), isTrue);
    });

    test('strict boundary: the same thin lines at 0.486% accepted, '
        '0.501% rejected', () {
      final _Phone below = _Phone()..thicken(32, length: 18); // 1,600 px
      final _Phone above = _Phone()..thicken(33, length: 18); // 1,650 px
      final SignificantDiffStats sb = below.stats();
      final SignificantDiffStats sa = above.stats();
      expect(sb.total / _Phone.area, lessThan(kGoldenStrictDiffTolerance));
      expect(sa.total / _Phone.area, greaterThan(kGoldenStrictDiffTolerance));
      expect(sa.total / _Phone.area, lessThan(0.00502));
      expect(sb.maxWindowDensity, greaterThan(kGoldenThinWindowDensity));
      expect(sa.maxWindowDensity, sb.maxWindowDensity);
      expect(below.accepts(sb), isTrue);
      expect(above.accepts(sa), isFalse);
    });

    test('thin boundary at ~0.6% total: window 36/576 (6.25%) accepted, '
        '44/576 (7.64%) rejected', () {
      final _Phone thin = _Phone()
        ..scatter(160)
        ..cluster(3, x0: 96, y0: 600); // 1,956 px, window 36
      final _Phone thick = _Phone()..thicken(45, length: 16); // 45 x 44 px
      final SignificantDiffStats st = thin.stats();
      final SignificantDiffStats sk = thick.stats();
      expect(st.maxWindowCount, 36);
      expect(sk.maxWindowCount, 44);
      expect(st.total / _Phone.area, greaterThan(kGoldenStrictDiffTolerance));
      expect(sk.total / _Phone.area, greaterThan(kGoldenStrictDiffTolerance));
      expect(thin.accepts(st), isTrue);
      expect(thick.accepts(sk), isFalse);
    });

    test('thin boundary pinned closer: window 42/576 (7.29%) above 0.5% '
        'rejected', () {
      final _Phone p = _Phone()
        ..scatter(160)
        ..cluster(3, pair: true, x0: 96, y0: 600); // window 42
      final SignificantDiffStats s = p.stats();
      expect(s.maxWindowCount, 42);
      expect(s.total / _Phone.area, greaterThan(kGoldenStrictDiffTolerance));
      expect(s.maxWindowDensity, lessThan(0.075));
      expect(p.accepts(s), isFalse);
    });
  });

  // The main window rule pinned from both sides by one cluster on a clean
  // screen (tiny total, so only the window decides).
  group('window 12% from both sides', () {
    for (final (int specks, int count, bool ok) in <(int, int, bool)>[
      (2, 30, true), // clustered noise like PR #19: 5.2%
      (5, 66, true), // just below: 11.5%
      (6, 78, false), // like the progress bar +5px in infra_review: 13.5%
    ]) {
      test('cluster $count/576 -> ${ok ? 'accepted' : 'rejected'}', () {
        final _Phone p = _Phone()..cluster(specks, pair: true, x0: 96, y0: 600);
        final SignificantDiffStats s = p.stats();
        expect(s.maxWindowCount, count);
        expect(s.total, count, reason: 'one cluster, nothing else');
        expect(s.total / _Phone.area, lessThan(kGoldenStrictDiffTolerance));
        expect(p.accepts(s), ok);
      });
    }

    test('cluster 72/576 (12.5%) -> rejected', () {
      final _Phone p = _Phone()..cluster(6, x0: 96, y0: 600);
      final SignificantDiffStats s = p.stats();
      expect(s.maxWindowCount, 72);
      expect(s.total, 72, reason: 'one cluster, nothing else');
      expect(s.maxWindowDensity, lessThan(0.13));
      expect(p.accepts(s), isFalse);
    });
  });

  // The wiring: testExecutable -> constants -> comparator -> compare() ->
  // acceptsSignificantDiff. Real PNG bytes go through the decode path.
  group('comparator wiring (real PNGs through compare())', () {
    test('testExecutable installs the comparator with the real constants', () {
      final GoldenFileComparator installed = goldenFileComparator;
      expect(installed, isA<ShiftTolerantGoldenFileComparator>());
      final ShiftTolerantGoldenFileComparator c =
          installed as ShiftTolerantGoldenFileComparator;
      expect(c.tolerance, kGoldenSignificantDiffTolerance);
      expect(c.maxWindowDensity, kGoldenMaxWindowDensity);
      expect(c.strictTolerance, kGoldenStrictDiffTolerance);
      expect(c.thinWindowDensity, kGoldenThinWindowDensity);
      expect(c.channelDelta, kGoldenChannelDelta);
      expect(c.radius, kGoldenShiftRadius);
    });

    late Directory dir;
    late ShiftTolerantGoldenFileComparator comparator;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aaq_golden_wiring_');
      final ShiftTolerantGoldenFileComparator installed =
          goldenFileComparator as ShiftTolerantGoldenFileComparator;
      // Same thresholds as the installed comparator, but rooted in a temp dir so
      // the golden file and any failures/ output stay out of the package.
      comparator = ShiftTolerantGoldenFileComparator(
        Uri.file('${dir.path}${Platform.pathSeparator}wiring_test.dart'),
        tolerance: installed.tolerance,
        maxWindowDensity: installed.maxWindowDensity,
        strictTolerance: installed.strictTolerance,
        thinWindowDensity: installed.thinWindowDensity,
        channelDelta: installed.channelDelta,
        radius: installed.radius,
      );
    });
    tearDown(() => dir.deleteSync(recursive: true));

    Future<void> writeGolden(Uint8List png) =>
        File('${dir.path}${Platform.pathSeparator}g.png').writeAsBytes(png);

    test('1px shifted box: bytes differ, 0 significant px -> true', () async {
      final _Small golden = _Small()..box(21, 20, 40, 30);
      final _Small candidate = _Small()..box(20, 20, 40, 30);
      final Uint8List g = await golden.png();
      final Uint8List c = await candidate.png();
      expect(listEquals(g, c), isFalse, reason: 'must reach the decode path');
      await writeGolden(g);
      expect(await comparator.compare(c, Uri.parse('g.png')), isTrue);
    });

    test('4 specks in one window (0.52%, 8.3%) -> rejected by P2', () async {
      final _Small golden = _Small();
      for (int k = 0; k < 4; k++) {
        golden.box(38 + (k % 2) * 8, 38 + (k ~/ 2) * 8, 2, 2);
      }
      final _Small candidate = _Small();
      final SignificantDiffStats s = analyzeSignificantDiffs(
        candidate.px,
        golden.px,
        width: _Small.side,
        height: _Small.side,
      );
      expect(s.total, 48);
      expect(s.maxWindowCount, 48);
      expect(
        acceptsSignificantDiff(
          s,
          width: _Small.side,
          height: _Small.side,
          tolerance: kGoldenSignificantDiffTolerance,
          maxWindowDensity: kGoldenMaxWindowDensity,
          strictTolerance: kGoldenSignificantDiffTolerance,
          thinWindowDensity: kGoldenThinWindowDensity,
        ),
        isTrue,
        reason: 'without P2 this pair would pass',
      );
      await writeGolden(await golden.png());
      final Uint8List c = await candidate.png();
      await expectLater(
        comparator.compare(c, Uri.parse('g.png')),
        throwsA(
          isA<FlutterError>().having(
            (FlutterError e) => e.message,
            'message',
            contains('-> rejected'),
          ),
        ),
      );
    });
  });
}

/// Specks needed for [ratio] of the phone area (12 px each, rounded).
int _specksFor(double ratio) => (ratio * _Phone.area / 12).round();

/// A 390x844 candidate (blank) and golden pair; noise and the icon go in the golden
/// (thickened lines go in both — 1px in the candidate, 3px in the golden).
class _Phone {
  static const int w = 390;
  static const int h = 844;
  static const int area = w * h;

  final Uint8List candidate = _fill();
  final Uint8List golden = _fill();

  static Uint8List _fill() => _fillSized(w, h);

  static Uint8List _fillSized(int width, int height) {
    final Uint8List px = Uint8List(width * height * 4);
    for (int i = 0; i < px.length; i += 4) {
      px[i] = 250;
      px[i + 1] = 250;
      px[i + 2] = 250;
      px[i + 3] = 255;
    }
    return px;
  }

  void _box(int x0, int y0, int bw, int bh, {Uint8List? into}) {
    final Uint8List px = into ?? golden;
    for (int y = y0; y < y0 + bh; y++) {
      for (int x = x0; x < x0 + bw; x++) {
        final int i = (y * w + x) * 4;
        px[i] = 20;
        px[i + 1] = 20;
        px[i + 2] = 20;
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

  /// An 18px outlined icon (1px border). The default spot is a speck-free gap
  /// of the grid.
  void dropIcon({int x0 = 186, int y0 = 790}) {
    _box(x0, y0, 18, 1);
    _box(x0, y0 + 17, 18, 1);
    _box(x0, y0, 1, 18);
    _box(x0 + 17, y0, 1, 18);
  }

  /// [n] short lines drawn 1px tall in the candidate and 3px tall in the golden
  /// (a stroke width 1 -> 3 regression), [length] px long, 24px apart along a
  /// row and 26px between rows. Each line yields 3 * length - 4 significant px
  /// and one line fills the densest window.
  void thicken(int n, {required int length}) {
    int placed = 0;
    for (int y = 8; y < h - 4 && placed < n; y += 26) {
      for (int x = 4; x + length < w - 4 && placed < n; x += 24) {
        _box(x, y, length, 1, into: candidate);
        _box(x, y - 1, length, 3);
        placed++;
      }
    }
    if (placed < n) {
      throw StateError('not enough room for $n lines');
    }
  }

  /// [specks] 2x2 specks 8px apart (3 per row), plus an optional 1x2 pair in the
  /// next slot, all inside the 24x24 window at ([x0], [y0]) — x0 and y0 are
  /// multiples of the 12px stride. A speck is 12 significant px, a pair 6.
  void cluster(
    int specks, {
    bool pair = false,
    required int x0,
    required int y0,
  }) {
    int k = 0;
    for (; k < specks; k++) {
      _box(x0 + 2 + (k % 3) * 8, y0 + 2 + (k ~/ 3) * 8, 2, 2);
    }
    if (pair) {
      _box(x0 + 2 + (k % 3) * 8, y0 + 2 + (k ~/ 3) * 8, 2, 1);
    }
  }

  SignificantDiffStats stats() =>
      analyzeSignificantDiffs(candidate, golden, width: w, height: h);

  bool accepts(
    SignificantDiffStats s, {
    double tolerance = kGoldenSignificantDiffTolerance,
    double strictTolerance = kGoldenStrictDiffTolerance,
  }) => acceptsSignificantDiff(
    s,
    width: w,
    height: h,
    tolerance: tolerance,
    maxWindowDensity: kGoldenMaxWindowDensity,
    strictTolerance: strictTolerance,
    thinWindowDensity: kGoldenThinWindowDensity,
  );
}

/// A 96x96 light image that turns into real PNG bytes for the wiring test.
class _Small {
  static const int side = 96;

  final Uint8List px = _Phone._fillSized(side, side);

  void box(int x0, int y0, int bw, int bh) {
    for (int y = y0; y < y0 + bh; y++) {
      for (int x = x0; x < x0 + bw; x++) {
        final int i = (y * side + x) * 4;
        px[i] = 20;
        px[i + 1] = 20;
        px[i + 2] = 20;
      }
    }
  }

  Future<Uint8List> png() async {
    final Completer<ui.Image> done = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      px,
      side,
      side,
      ui.PixelFormat.rgba8888,
      done.complete,
    );
    final ui.Image image = await done.future;
    try {
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (data == null) {
        throw StateError('png encode returned null');
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }
}
