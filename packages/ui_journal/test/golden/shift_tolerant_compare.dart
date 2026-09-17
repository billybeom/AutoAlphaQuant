// shift_tolerant_compare.dart — 위젯 골든 비교의 «유의 픽셀» 계산 (C-2 하네스 · M2 소유)
//
// 왜 있나(01 §7 골든 규칙 · test/golden/README.md):
//   Windows 에서 찍은 PNG 를 리눅스 CI 가 비교하면 글자 상자 가장자리가 **1픽셀** 어긋나고
//   그림자·둥근 모서리의 안티에일리어싱이 미세하게 다르다. 2026-09-17 실측: J-1 골든 8장 중
//   6장이 0.74~1.44%(2,430~4,736px) 어긋났고, light/dark 가 같은 수치였다(= 테마가 아니라
//   글자 위치 차이). 단순 픽셀 비율 허용치를 1.5% 로 올리면 **칩 하나 누락(약 0.6%)** 을
//   잡지 못한다 — 검사의 목적(사유 칩·배지 누락 탐지)이 죽는다.
//
// 그래서 «달라진 픽셀»이 아니라 «유의 픽셀»을 센다:
//   후보 이미지의 픽셀 p 가 골든의 같은 자리와 다르더라도, 골든의 p 주변 (2r+1)×(2r+1)
//   이웃 안에 색이 비슷한(채널 차 ≤ channelDelta) 픽셀이 있으면 **이동·AA 차이**로 보고
//   무시한다. 이웃 어디에도 비슷한 색이 없으면 **구조가 다른 것**(칩·행·배지가 생기거나
//   사라진 것)이라 유의 픽셀로 센다.
//   · 글자 상자가 1px 이동 → 이웃에 같은 색이 있다 → 0
//   · 칩(약 60×32) 하나가 사라짐 → 그 자리 전부 배경인데 골든 이웃은 글자/칩 색 → 수백~수천 px
//
// 🔴 순수 함수다 — dart:ui 이미지 디코드는 flutter_test_config.dart 가 하고 여기는 바이트만 본다.
// 🔴 한국어 문자열 리터럴을 두지 않는다(실패 메시지는 ASCII).

import 'dart:typed_data';

/// 두 RGBA 버퍼(길이 = width*height*4)를 비교해 «유의 픽셀» 수를 돌려준다.
///
/// [radius] 이웃 반경(px). 1 이면 3×3. [channelDelta] 같은 색으로 볼 채널 차의 상한(0~255).
int countSignificantDiffs(
  Uint8List candidate,
  Uint8List golden, {
  required int width,
  required int height,
  int radius = 1,
  int channelDelta = 48,
}) {
  final int expected = width * height * 4;
  if (candidate.length != expected || golden.length != expected) {
    throw ArgumentError(
      'buffer length mismatch: candidate=${candidate.length} '
      'golden=${golden.length} expected=$expected',
    );
  }
  int significant = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int i = (y * width + x) * 4;
      if (_close(candidate, i, golden, i, channelDelta)) {
        continue;
      }
      bool matched = false;
      for (int dy = -radius; dy <= radius && !matched; dy++) {
        final int ny = y + dy;
        if (ny < 0 || ny >= height) {
          continue;
        }
        for (int dx = -radius; dx <= radius; dx++) {
          final int nx = x + dx;
          if (nx < 0 || nx >= width) {
            continue;
          }
          if (_close(
            candidate,
            i,
            golden,
            (ny * width + nx) * 4,
            channelDelta,
          )) {
            matched = true;
            break;
          }
        }
      }
      if (!matched) {
        significant++;
      }
    }
  }
  return significant;
}

bool _close(Uint8List a, int ai, Uint8List b, int bi, int delta) {
  for (int c = 0; c < 4; c++) {
    if ((a[ai + c] - b[bi + c]).abs() > delta) {
      return false;
    }
  }
  return true;
}
