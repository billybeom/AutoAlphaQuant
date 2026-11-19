// GV-32 리스크 한도 + 동시 발동 우선순위(AC-S17 · 안전 게이트) · GV-39 P2 검사 순서 trace(AC-B27)
// · GV-17 입력 누락 fail-closed(AC-S14) — 04 §1 · §1-5.
//
// 정답지(vectors/SOURCES.md): 파일럿4 `saf_vectors.json` 통째 · 파일럿5 `gv39_vectors.json` 통째 ·
// 05 §GV-17 블록 원문. 🔴 GV-32 의 비교는 `violated` 를 정렬한 뒤(05 §GV-32) — 엔진이 이미 정렬해 준다.
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv32Limits` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv32Limits());
}
