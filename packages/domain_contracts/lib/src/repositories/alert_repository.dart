// 01 §4-1 — 알림함(M8) 읽기 창구.
//
// 🔴 `AlertLevel` 의 **표시 계층 사적 재분류는 금지**다(결정 7c) — `min` 은 거르기이지
//    등급을 다시 매기는 자리가 아니다.

import '../dto/safety.dart';
import '../enums/safety.dart';

/// 알림 창구(M8).
abstract interface class AlertRepository {
  /// `S-01` P0 점(🔵 v1.15 무변경). 받은 차례 = 엔진 순서(등급 순 P0 → P1 → P2 · 같은 등급 안 = 엔진 · K13).
  Stream<List<AlertItem>> watchInbox({AlertLevel? min});

  /// 🆕 v1.15(01 §24 · K2 · K10) — `N-01` 알림 센터. [p0Only] = «P0만 보기»(창구 인자 · 바꾸면 재구독) —
  /// true 면 `sections` 빈 목록 · `pinned` 그대로. 🔴 화면은 받은 VM 을 거르거나 다시 묶지 않는다.
  Stream<AlertCenterVm> watchCenter({required bool p0Only});

  /// 🆕 v1.15(K2 · 발주자 결정 ②(a)) — `N-02` 알림 상세. 모르는·지난 [alertId] = `item` null + `missingLabel`
  /// (값 · 에러 아님) · 스트림 에러 = 읽기 실패.
  Stream<AlertDetailVm> watchAlert(String alertId);
}
