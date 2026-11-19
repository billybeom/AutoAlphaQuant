// GV-20 슬리브 B 3-트랜치 SMA(AC-B13) · GV-23 계절성 부분 청산(AC-B16) · GV-38 4월 청산 기본값 = 전량
// (AC-B26 일부) — 03 §2-7-2·3 · §5-3-2.
//
// 정답지 = 05 v1.22 본문 블록 원문(GV-20 · GV-23) + 파일럿5 `gv35_38.json`(GV-38 — vectors/SOURCES.md).
// 🔵 GV-23 은 enabled 경로라 P0S 에서 돌지 않지만, GV-38-4 가 «enabled 경로는 GV-23 그대로»를 같은
//    함수로 묻기 때문에 함께 시험한다. GV-35~37 은 다음 PR(슬리브 C · 코어 밴드)에서 읽는다.
// 🔵 GV-23 의 매도 금액은 «비율 × 슬리브 금액» 검산이다 — 종목별 배분(§5-3-2 v2.9)은 주문 산출의 몫.
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv20SleeveSignals` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv20SleeveSignals());
}
