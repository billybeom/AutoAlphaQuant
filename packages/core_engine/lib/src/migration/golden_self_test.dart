// X1-5 골든 자가검사 포트(설계 13 §8 R138 Q3 · 지도 e16-map D19 · 06 X1-5 «G-GV 전량» — 실행기 = E11o 기기 골든).
//
// 🔴 판정 재료만 — 통과 · 실패 두 값 · 돌릴 수 없으면 던진다(게이트에는 «아직»으로 남는다 · 지어내지 않는다).

/// 골든 자가검사.
abstract interface class GoldenSelfTest {
  /// 한 번 돈다 — 전량 통과 = true · 하나라도 실패 = false · 돌릴 수 없으면 던진다.
  Future<bool> run();
}
