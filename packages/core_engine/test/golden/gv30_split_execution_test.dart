// GV-30 계절성 분할 집행(AC-B23 · e1~e4) — 03 §5-3-1 v2.10 · v2.38 · 06 M1-9b.
//
// 정답지(vectors/SOURCES.md): 05 §GV-30 코드 블록 원문. `filled` 가 없는 케이스는 계획대로 전량 체결된다고 본다
// (블록 검산 «잔량 66 → 33» 이 그 가정이다). e4 의 `filled` 는 1·2일차 체결 수량이다.
// 🔴 e4 해석(v2.38 · 설계 13 §8 R33 D8): 중간 날 = 계획 잔량 기준 ceil · 마지막 날 = 목표 − 누적 체결.
// 🔴 한 정본(E11o-b · 설계 13 §8 R163) — 판정은 엔진 lib `Gv30SplitExecution` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv30SplitExecution());
}
