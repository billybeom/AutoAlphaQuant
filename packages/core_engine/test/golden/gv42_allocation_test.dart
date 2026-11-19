// GV-42 자본 배분 설정 검증(AC-B30) — 02 §5-7 규칙 4b·6b · §4-2 6b 단서(v2.31 새틀 0 허용).
//
// 정답지 = 파일럿5 `vectors/gv42.json`(05 §GV-42 가 지목 · vectors/SOURCES.md).
// 🔴 거부 사유는 정답지가 문구의 앞 40자(`reason_contains`)를 준다 — 앞부분 일치로 본다.
// 🔵 기대값은 생성기가 소수 10자리로 반올림했다(`gv42_gen_vectors.py` `round(v, 10)`) — 허용오차 1e-9.
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv42Allocation` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv42Allocation());
}
