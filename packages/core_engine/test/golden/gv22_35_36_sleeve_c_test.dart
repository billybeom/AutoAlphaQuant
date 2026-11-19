// GV-22 슬리브 C 통화 분리·금 상한(AC-B15) · GV-35 분모 = 달러 잔액 · GV-36 조달 상대 = 잉여 큰 순 · B 제외
// (AC-B26 일부) — 03 §2-9-1·2 · §5-2 v2.19·v2.21.
//
// 정답지 = 05 v1.22 §GV-22 블록 원문 + 파일럿5 `gv35_38.json`(vectors/SOURCES.md).
// 🔴 GV-35 는 생성기(`gen_v220_vectors.py` gv35_sleeve_c_targets)가 비중 0.40/0.35/0.25 · 금 상한 0.08 을
//    **기본 인자로 숨겨** 계산했다(JSON 입력에 없다). 발주자 결정(2026-10-20 · 설계 13 §8 R14 ①)대로
//    그 값을 아래에 드러내 적고 «식»만 본다 — P0S 비중(0 / 0.65 / 0.35)의 값은 GV-P0S(E6)가 잰다.
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv22SleeveC` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv22SleeveC());
}
