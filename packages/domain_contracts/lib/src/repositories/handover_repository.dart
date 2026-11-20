// 01 §4-1 — 🆕 계약 v1.26(01 §35 · K167) — `M5-11` simToAuto 위저드 읽기 창구(폰 전용 · `ui_safety` 만 · 구현 = 조립 앱 — 엔진 VM 생산).
//
// 🔴 `SettingsRepository` 를 넓히지 않는다(05 «7단계 전부 M5 소유» · M9/M5 경계 · v1.25 `BlockBoardRepository` 선례).
// 🔴 `handoverStatus` = 같은 본문 · 같은 스트림(K173).
// 🔴 시각이 지나면(냉각 끝 · 확정 기한 · 커밋 창) 새 VM 을 낸다 — 화면 카운트다운 0.
// 🔴 세션 저장 = 실전 파일(ds `handover_session_store.dart`) — 열기·여는 때는 구현 몫(01 §8 미결 207).
// 🔴 쓰기 = `SettingsActions.run`(행의 `actions` 그대로 · K169).

import '../dto/handover.dart';

/// 위저드 한 화면.
abstract interface class HandoverRepository {
  Stream<HandoverWizardVm> watchWizard();
}
