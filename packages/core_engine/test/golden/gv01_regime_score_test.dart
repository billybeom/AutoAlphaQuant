// GV-1 방향 스코어 — 카테고리 재정규화(05 §GV-1 · AC-B01 서브케이스 7) · 03 §1-1.
//
// 정답지: 05 v1.22 본문 JSON 블록 5개 원문(vectors/SOURCES.md).
// 🔴 파일럿1 `GV-1_regime_categories.json` 은 쓰지 않는다 — 1c 의 BREADTH 가 v1.5 가
//    «판별력 0» 으로 고친 옛 값(60.0)이고 1e 가 없다.
// 허용오차: 1a~1d 블록에는 값이 없어 03 §0-4 «스코어 1e-4» 를 쓴다(1e 블록과 같은 값).
// 🔴 한 정본(E11o-a · 설계 13 §8 R162) — 판정은 엔진 lib `Gv1RegimeScore` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv1RegimeScore());
}
