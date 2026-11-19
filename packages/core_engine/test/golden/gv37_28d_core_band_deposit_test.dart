// GV-37 코어 밴드 전액 자동 + 연금 한도 다리(AC-B26 일부) · GV-28d 납입 배분(AC-B21 일부) —
// 03 §5-2 v2.20·v2.21 · §5-5b DEPOSIT v2.23.
//
// 정답지 = 파일럿5 `gv35_38.json`(GV-37 · E5b 에서 들어옴) + 파일럿5 `gv28d_vectors.json`(vectors/SOURCES.md).
// 🔴 GV-37 은 생성기(`gen_v220_vectors.py` gv37_core_band)가 B 목표 0.287(3차 배분) · band 0.03 ·
//    원화 1e18 · 한도 ∞ 를 **기본 인자로 숨겨** 계산했다. 발주자 결정(2026-10-20 · 설계 13 §8 R14 ①)대로
//    그 값을 아래에 드러내 적고 «식»만 본다 — P0S 의 B 0.42 경로는 GV-P0S(E6)가 잰다.
// 🔵 GV-37 의 기대 금액 = 재분류 + 납입 합계(생성기는 둘을 더해 하나로 낸다).
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv37CoreBandDeposit` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv37CoreBandDeposit());
}
