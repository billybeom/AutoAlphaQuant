// 01 §4-1 · §10 — 🆕 X7 이행 갭 리포트 읽기 창구.

import '../dto/ledger_trust.dart';

/// 월간 이행 갭(`S7-10`) · 롤링 이행 갭.
/// 🔴 `modeAdviceLine` 은 엔진이 **3갈래로 갈라 생성**한다(B21) — 화면이 조립하지 않는다.
abstract interface class ExecutionGapRepository {
  Future<ExecutionGapReport> monthly(String yyyyMm);

  Stream<ExecutionGapReport> watchRolling();
}
