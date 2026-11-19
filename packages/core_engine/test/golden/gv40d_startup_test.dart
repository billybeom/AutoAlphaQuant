// GV-40d 기동 통제(SAF-405 · AC-S18 의 d 몫 · 설계 13 §8 R66 Y6 · Y9).
//
// 정답지(vectors/SOURCES.md): gv40_saf_warn.json — 파일럿5 원본 통째 · 이 판은 `GV-40d` 3건을 본다(e 는 E13f1).
// 🔵 정답지는 live 기동의 판정이다(04 §1 «미승인 config로 live 실행») — 모의 모드는 discretion 밖이라 rule_change_test 가 본다.
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv40dStartup` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv40dStartup());
}
