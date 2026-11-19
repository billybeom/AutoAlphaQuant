// GV-13 «발주 횟수» 부분(AC-S13 · 05 §GV-13 v1~v4) — 형식 부분은 `gv09_idempotency_test.dart`(E4).
//
// 정답지(vectors/SOURCES.md): 05 §GV-13 코드 블록 원문(`gv13_decision_id.json`). «mock — submit_order 호출 횟수를
// 센다» = 포트 수준 FakeBroker(설계 13 §8 R35 V9 · V10). 🔵 v2.38: 주문 의도의 decision_id 는 `{논리 id}@{집행일}` —
// 정답지의 `decision_id` 는 논리 id 이고, 같은 날 집행이라 접미도 같다.
// 🔴 한 정본(E11o-b · 설계 13 §8 R163) — 판정은 엔진 lib `Gv13SubmitCount` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv13SubmitCount());
}
