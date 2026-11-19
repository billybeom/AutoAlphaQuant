// GV-2 기술 지표 — 05 §GV-2(2a~2f · AC-B02 서브케이스 10) · 03 §0-3·§1-5.
//
// 정답지: 05 v1.22 본문 JSON 블록 7개를 원문 그대로 옮긴 것(vectors/SOURCES.md).
// 🔴 파일럿1 `GV-2_indicators.json` 은 쓰지 않는다 — 2e(BBW)·2f(ADX 값)가 없고 2d 허용오차가
//    05 v1.5 이전 값(1e-6)이다.
// 🔴 한 정본(E11o-a · 설계 13 §8 R162) — 판정은 엔진 lib `Gv2Indicators` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv2Indicators());
}
