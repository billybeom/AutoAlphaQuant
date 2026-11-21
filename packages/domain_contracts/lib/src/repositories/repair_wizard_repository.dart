// 01 §4-1 — 🆕 계약 v1.32(01 §41 · K249 · E16j-a) — X5 정정 마법사 읽기 창구(폰 전용 · `ui_safety` 만 · 구현 = 조립 앱 — 엔진 VM 생산).
//
// 🔴 [targetId] null = 허브(열린 대상 고르기 · `x5RepairWizard`) · 값 = 대상 화면(`x5RepairTarget/:targetId` · `ld-…` diff id 또는 `li-…`
//    무결성 합성 id — 라우트 인자 그대로 · 화면은 해석하지 않는다).
// 🔴 모르는 · 닫힌 대상 = 엔진 문장 VM(스트림 에러가 아니다 · `doneLabel` 또는 `headline`).
// 🔴 쓰기 = `SafetyActions`(행 · VM 의 동작 그대로 · 제출 DTO 3).

import '../dto/repair.dart';

/// X5 정정 마법사 한 화면.
abstract interface class RepairWizardRepository {
  Stream<RepairWizardVm> watchRepair({String? targetId});
}
