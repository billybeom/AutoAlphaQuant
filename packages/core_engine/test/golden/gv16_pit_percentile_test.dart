// GV-16 `pit_percentile` 룩어헤드 · 워밍업(안전 게이트 AC-S11 · 05 §GV-16) — 03 §1-6 · NR-9.
//
// 정답지 = 05 v1.23 §GV-16 코드 블록 원문(vectors/SOURCES.md).
// 🔴 한 정본(E11o-c2 · 설계 13 §8 R165) — 판정은 엔진 lib `Gv16PitPercentile` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv16PitPercentile());
}
