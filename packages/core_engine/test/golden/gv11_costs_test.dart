// GV-11 거래비용(AC-B11) · GV-11e 구간 경계 · 미국 fail-closed · GV-11d 참여율 절단 · GV-19 비용의 손익
// 반영 · GV-24 보유비용 — 03 §5-6 · §5-7.
//
// 정답지 = 05 v1.22 본문 블록 원문(vectors/SOURCES.md). 설정 = 02 §4 `costs.kr`(엔진 lib `krCostsFromSpec` · `src/golden/golden_fixtures.dart`).
// 🔴 05 GV-11 의 a·b 는 «소형주»라 개별주 세율(ETF 아님)로 계산한다. P0S 의 ETF 매도세 0 은 단위 시험 몫.
// 🔴 GV-19 기대값은 증권거래세 0.18% 시절 값이다(05 검산 «18,000»). 통합 경로는 그 설정으로 정답지와
//    맞추고, 현행 0.20% 로는 매도 비용이 GV-11b 와 같아야 함을 따로 본다(설계 13 §8 R13).
// 🔴 한 정본(E11o-b · 설계 13 §8 R163) — 판정은 엔진 lib `Gv11Costs` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv11Costs());
}
