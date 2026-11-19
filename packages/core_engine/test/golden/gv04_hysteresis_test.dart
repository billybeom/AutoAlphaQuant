// GV-4 히스테리시스 — 방향(4 · 4b · 4c · 4d · 4e · 4g) · 추세성(4f · 4f-b · 4f-n)
// (05 §GV-4 계열 · AC-B04 서브케이스 13) · 03 §1-7 · §1-8.
//
// 정답지: 05 v1.22 본문 JSON 블록 9개 원문(vectors/SOURCES.md).
// 🔴 파일럿1 `GV-4_hysteresis.json` 은 쓰지 않는다 — 4b~4g·4f-b·4f-n 이 없다.
// 🔴 함수는 봉 하나를 처리한다 — 시리즈를 한 봉씩 늘려 가며 봉 수만큼 부른다(03 §1-7 호출 규약).
// 🔴 한 정본(E11o-a · 설계 13 §8 R162) — 판정은 엔진 lib `Gv4Hysteresis` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv4Hysteresis());
}
