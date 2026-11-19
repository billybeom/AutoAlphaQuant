// GV-40e 재량 예산 원장(SAF-409 · AC-S18 의 e 몫 · 설계 13 §8 R64 W8).
//
// 정답지(vectors/SOURCES.md): gv40_saf_warn.json — 파일럿5 원본 통째 · 이 판은 `GV-40e` 9건만 본다.
// 🔵 정답지 `decision_id` 의 «미연결» = null → `journalLinked: false`(저널 사실 판정은 discretion_test 가 본다).
// 🔵 `triggered` · `action` 은 사유가 있느냐로 정해진다(참조 `gv40e_discretion`).
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv40eDiscretion` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv40eDiscretion());
}
