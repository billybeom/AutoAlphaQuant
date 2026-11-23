// 01 §4-1 — 🆕 계약 v1.37(01 §46 · K318 · 01 §8 미결 224) — `M5-13` 원장 실사 해소 게이트 읽기 창구(`ui_safety` 만 · 상태를 바꾸는 경로 0 — C-7).
//
// 🔴 기존 `LedgerTrustRepository`(배지 · `L-3` 세션) · `LedgerRepository`(`L-1`) · `BlockBoardRepository`(`M5-5`) 무변경 —
//    해소 게이트는 플래그 · 두 카운터 · 열린 자가 보고 차이 · 보관 명령을 한 스트림으로 감싼다(v1.25 K154 결).
// 🔴 쓰기 = `SafetyActions.run(heldCommandsConfirm, {review_id})`(엔진 완성 `SelfAuditResolveVm.confirmHeld`) 하나 · 플래그 해제 동작 0.

import '../dto/self_audit.dart';

/// `M5-13` 한 화면.
abstract interface class SelfAuditResolveRepository {
  Stream<SelfAuditResolveVm> watchResolve();
}
