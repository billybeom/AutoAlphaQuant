// GV-9 멱등키(05 §GV-9 · AC-B09) · GV-13 decision_id 형식 부분(05 §GV-13 · AC-S13) — 04 §3-2.
//
// 정답지 = 05 v1.22 본문 블록 원문(vectors/SOURCES.md).
// 🔵 GV-13 의 «submit_order 호출 횟수 · order_intents 행 수 · reserve_intent 결과»는 주문 의도 예약과
//    모의 브로커가 있어야 재는 값이라 주문 경로(E10)에서 시험한다. 여기서는 decision_id 문자열과
//    서로 다른 id·멱등키 개수만 본다.
// 🔴 한 정본(E11o-b · 설계 13 §8 R163) — 판정은 엔진 lib `Gv9Idempotency` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv9Idempotency());
}
