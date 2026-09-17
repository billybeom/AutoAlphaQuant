// shift_tolerant_compare.dart — 위젯 골든 비교의 «유의 픽셀» 계산 (C-2 하네스 · M2 소유 · 3판)
//
// 왜 있나(01 §7 골든 규칙 · test/golden/README.md):
//   Windows 에서 찍은 PNG 를 리눅스 CI 가 비교하면 글자 상자 가장자리가 **1픽셀** 어긋나고
//   가는 획의 안티에일리어싱 농도가 다르다(특히 **어두운 배경의 밝은 글자** — 플랫폼별 글자
//   감마 보정이 달라 1px 획이 한쪽은 «진한 1칸», 다른 쪽은 «흐린 2칸»으로 찍힌다).
//   실측(2026-09-17): J-1 8장 원시 차 0.4~1.4% · S7-1 6장 원시 차 3.8~4.2%.
//   단순 픽셀 비율 허용치를 올리면 **칩 하나 누락(약 0.6%)** 을 잡지 못한다.
//
// 그래서 «달라진 픽셀»이 아니라 «유의 픽셀»을 센다 — 3단계:
//   ① 두 이미지를 **3×3 상자 흐림**으로 흐린다 — «진한 1칸»과 «흐린 2칸»이 같은 값대로 모인다.
//   ② 자리 p 에서 **양방향**으로 본다: 후보[p] 와 비슷한 색(채널 차 ≤ channelDelta)이 골든의
//      p 주변 (2r+1)² 이웃에 있는가, **그리고** 골든[p] 와 비슷한 색이 후보의 이웃에 있는가.
//   ③ 어느 한쪽이라도 없으면 그 자리는 **구조가 다른 것**이라 유의 픽셀로 센다.
//   · 글자·테두리가 1px 이동 → 양쪽 다 이웃에서 찾는다 → 0
//   · 칩(속이 찬 것이든 **가는 테두리뿐인 것이든**)이 사라짐 → 골든의 획·테두리가 후보의
//     이웃 어디에도 없다 → 유의 픽셀
//   🔴 2판(한 방향만 검사)은 «가는 테두리뿐인 칩»의 누락을 못 잡았다 — 후보의 배경 픽셀은
//      골든의 이웃에서 언제나 배경을 찾기 때문이다. 대칭 검사가 그 구멍을 막는다.
//
// 🔴 순수 함수다 — dart:ui 이미지 디코드는 flutter_test_config.dart 가 하고 여기는 바이트만 본다.
// 🔴 한국어 문자열 리터럴을 두지 않는다(실패 메시지는 ASCII).

import 'dart:typed_data';

/// 두 RGBA 버퍼(길이 = width*height*4)를 비교해 «유의 픽셀» 수를 돌려준다.
///
/// [radius] 이웃 반경(px). 1 이면 3×3. [channelDelta] 같은 색으로 볼 채널 차의 상한(0~255).
/// [blur] 가 true 면 비교 전에 두 버퍼를 3×3 상자 흐림으로 흐린다(기본).
int countSignificantDiffs(
  Uint8List candidate,
  Uint8List golden, {
  required int width,
  required int height,
  int radius = 1,
  int channelDelta = 48,
  bool blur = true,
}) => analyzeSignificantDiffs(
  candidate,
  golden,
  width: width,
  height: height,
  radius: radius,
  channelDelta: channelDelta,
  blur: blur,
).total;

/// 유의 픽셀의 «양»과 «뭉침».
///
/// 플랫폼 소음은 화면 전체의 글자 가장자리에 **얇게 흩어지고**, 칩·행·배지의 누락은
/// **한 곳에 뭉친다**. 전체 비율 하나로는 둘을 가르기 어려워(소음 0.18% vs 테두리 칩 0.16%)
/// 가장 빽빽한 창(window) 하나의 유의 픽셀 수를 함께 본다.
class SignificantDiffStats {
  const SignificantDiffStats({
    required this.total,
    required this.maxWindowCount,
    required this.windowSize,
  });

  /// 화면 전체의 유의 픽셀 수.
  final int total;

  /// [windowSize]×[windowSize] 창(보폭 = 절반) 가운데 가장 많은 유의 픽셀 수.
  final int maxWindowCount;

  /// 창 한 변(px).
  final int windowSize;

  /// 가장 빽빽한 창의 밀도(0.0~1.0).
  double get maxWindowDensity => maxWindowCount / (windowSize * windowSize);
}

SignificantDiffStats analyzeSignificantDiffs(
  Uint8List candidate,
  Uint8List golden, {
  required int width,
  required int height,
  int radius = 1,
  int channelDelta = 48,
  bool blur = true,
  int windowSize = 24,
}) {
  final int expected = width * height * 4;
  if (candidate.length != expected || golden.length != expected) {
    throw ArgumentError(
      'buffer length mismatch: candidate=${candidate.length} '
      'golden=${golden.length} expected=$expected',
    );
  }
  final Uint8List a = blur ? boxBlur3x3(candidate, width, height) : candidate;
  final Uint8List b = blur ? boxBlur3x3(golden, width, height) : golden;

  int significant = 0;
  final Uint8List mask = Uint8List(width * height);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int i = (y * width + x) * 4;
      if (_close(a, i, b, i, channelDelta)) {
        continue;
      }
      final bool forward = _hasNeighbour(
        a,
        i,
        b,
        x,
        y,
        width,
        height,
        radius,
        channelDelta,
      );
      final bool backward =
          forward &&
          _hasNeighbour(b, i, a, x, y, width, height, radius, channelDelta);
      if (!(forward && backward)) {
        significant++;
        mask[y * width + x] = 1;
      }
    }
  }

  // 가장 빽빽한 창 — 적분 영상(summed-area table)으로 O(1) 창 합.
  final int stride = windowSize ~/ 2 > 0 ? windowSize ~/ 2 : 1;
  final Int32List sat = Int32List((width + 1) * (height + 1));
  for (int y = 0; y < height; y++) {
    int rowSum = 0;
    for (int x = 0; x < width; x++) {
      rowSum += mask[y * width + x];
      sat[(y + 1) * (width + 1) + (x + 1)] =
          sat[y * (width + 1) + (x + 1)] + rowSum;
    }
  }
  int maxWindow = 0;
  for (int y = 0; y < height; y += stride) {
    final int y1 = y + windowSize < height ? y + windowSize : height;
    for (int x = 0; x < width; x += stride) {
      final int x1 = x + windowSize < width ? x + windowSize : width;
      final int sum =
          sat[y1 * (width + 1) + x1] -
          sat[y * (width + 1) + x1] -
          sat[y1 * (width + 1) + x] +
          sat[y * (width + 1) + x];
      if (sum > maxWindow) {
        maxWindow = sum;
      }
    }
  }
  return SignificantDiffStats(
    total: significant,
    maxWindowCount: maxWindow,
    windowSize: windowSize,
  );
}

/// 3×3 상자 흐림(가장자리는 있는 픽셀만 평균). 알파 포함 4채널.
Uint8List boxBlur3x3(Uint8List src, int width, int height) {
  final Uint8List out = Uint8List(src.length);
  for (int y = 0; y < height; y++) {
    final int y0 = y > 0 ? y - 1 : y;
    final int y1 = y < height - 1 ? y + 1 : y;
    for (int x = 0; x < width; x++) {
      final int x0 = x > 0 ? x - 1 : x;
      final int x1 = x < width - 1 ? x + 1 : x;
      int r = 0;
      int g = 0;
      int bl = 0;
      int al = 0;
      int n = 0;
      for (int yy = y0; yy <= y1; yy++) {
        for (int xx = x0; xx <= x1; xx++) {
          final int j = (yy * width + xx) * 4;
          r += src[j];
          g += src[j + 1];
          bl += src[j + 2];
          al += src[j + 3];
          n++;
        }
      }
      final int i = (y * width + x) * 4;
      out[i] = r ~/ n;
      out[i + 1] = g ~/ n;
      out[i + 2] = bl ~/ n;
      out[i + 3] = al ~/ n;
    }
  }
  return out;
}

/// [from] 의 자리 [fi] 와 비슷한 색이 [to] 의 (x, y) 주변 이웃에 있는가.
bool _hasNeighbour(
  Uint8List from,
  int fi,
  Uint8List to,
  int x,
  int y,
  int width,
  int height,
  int radius,
  int delta,
) {
  for (int dy = -radius; dy <= radius; dy++) {
    final int ny = y + dy;
    if (ny < 0 || ny >= height) {
      continue;
    }
    for (int dx = -radius; dx <= radius; dx++) {
      final int nx = x + dx;
      if (nx < 0 || nx >= width) {
        continue;
      }
      if (_close(from, fi, to, (ny * width + nx) * 4, delta)) {
        return true;
      }
    }
  }
  return false;
}

bool _close(Uint8List a, int ai, Uint8List b, int bi, int delta) {
  for (int c = 0; c < 4; c++) {
    if ((a[ai + c] - b[bi + c]).abs() > delta) {
      return false;
    }
  }
  return true;
}
