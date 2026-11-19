// GV-8 이중 상한 사이징 — 05 §GV-8(8a~8f) · 03 §3-4 · 06 M1-1 검증 게이트.
//
// 정답지 둘:
//   gv08_sizing.json        — 파일럿1 원본(8a~8d · 8e 예외 4)
//   gv08_machine_block.json — 05 §GV-8 «기계 채점 블록»(notional_value · exact_fields 포함)
// 🔵 v2.31 P0S 에서 GV-8 은 채점 외(새틀라이트 비활성)지만 Decimal 규약의 게이트다.
// 🔴 한 정본(E11o-b · 설계 13 §8 R163) — 판정은 엔진 lib `Gv8Sizing` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv8Sizing());
}
