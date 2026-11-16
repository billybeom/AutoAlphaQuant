// 01 §4-1 — 🆕 계약 v1.21(01 §30 · K6) — 서약 읽기 창구(M5-8 · `O-04` ② 슬롯 위젯 · 재생처).
//
// 🔴 J-3 의 `JournalDraftFormSpec.pledgeLines` 는 그대로(엔진이 같은 원문을 싣는다 — 원문은 한 번만).
// 🔴 상태를 바꾸는 경로 0(C-7) — 쓰기 = `SafetyActions.runPledge`.

import '../dto/safety_gate.dart';

/// 서약 지금 판.
abstract interface class PledgeRepository {
  Stream<PledgeVm> watchPledge();
}
