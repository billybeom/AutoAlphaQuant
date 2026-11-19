// GV-31 드로다운 서킷브레이커(AC-S16 · 안전 게이트) · s_h5_1(v2.29 STOPPED 재개 자격) · GV-18 슬리브별 승수.
//
// 정답지(vectors/SOURCES.md):
//   gv31_breaker_vectors.json      — 파일럿4 원본 통째(단발 23 + 시퀀스 6 · v1.13 재생성 · dd_stop −0.35)
//   gv31_s_h5_1_J1_stopped.json    — 백테스트6 `runs/J1_stopped/J1_stopped.json` 통째(vectorB_deterministic)
//   gv18_exposure_multiplier.json  — 05 §GV-18 블록 원문
// 🔴 s_h5_1 의 입력 시퀀스는 정답 파일에 없다 — 05 §GV-31 계열 s_h5_1 «입력 시퀀스» 문단과
//    `exp/J1_stopped_vector.py` vectorB 블록대로 여기서 만든다(numpy linspace 의 계산 순서까지).
// 🔴 한 정본(E11o-c1 · 설계 13 §8 R164) — 판정은 엔진 lib `Gv31Breaker` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv31Breaker());
}
