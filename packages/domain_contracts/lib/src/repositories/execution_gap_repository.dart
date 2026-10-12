// 01 §4-1 · §10 — 🆕 X7 이행 갭 리포트 읽기 창구.
// 🆕 v1.6(01 §15-4) — `monthly({String? yyyyMm})` → `ExecutionGapResult`(리포트 | 빈·해당없음 문장).

import '../dto/ledger_trust.dart';

/// 월간 이행 갭(`S7-10`) · 롤링 이행 갭.
/// 🔴 `modeAdviceLine` 은 엔진이 **3갈래로 갈라 생성**한다(B21) — 화면이 조립하지 않는다.
abstract interface class ExecutionGapRepository {
  /// 🆕 v1.6 — [yyyyMm](`yyyy-MM`) == null = **엔진 기본 달**(06 X7-4 — 권고: 월간 리포트가 발행된
  /// 가장 최근 달). 기간은 `report.periodLabel` 이 말한다. 「계획」 탭 ⑤ = null · `S7-1` ⑧ = 그 달
  /// (`AppRoutes.ledgerExecutionGapMonth` → 셸 → `ExecutionGapScreen(yyyyMm:)` → 이 인자).
  Future<ExecutionGapResult> monthly({String? yyyyMm});

  /// 🔴 R12 화면 미사용 — 롤링 창 정의 = 06 X7-4(정의 전).
  Stream<ExecutionGapReport> watchRolling();
}
