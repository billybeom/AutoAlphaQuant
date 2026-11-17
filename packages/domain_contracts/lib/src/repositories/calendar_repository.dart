// 01 §4-1 — X4 구글 캘린더 동기 상태 읽기 창구.
//
// ⏸ J-5 — X4 계열 전체는 **이름·타입을 등재하되 구현하지 않는다**(OAuth 동의화면
//    «테스트» 상태 7일 만료 스모크가 미결 · §8-5). 인터페이스 선언까지가 이 회차의 몫이다.
// ⏸ v1.24(01 §33 · K107) — `S08` 은 1.24.0 에서 뺐다(X4 = 13 E17 «실험 3 · 실전 뒤» · 카드 ⏸ `R9d-Bob-M9S08`) — 이 창구·`CalendarSyncStatus` 는
//    지우지 않는다(J-5 그대로 · 계약 창 = E17 판독 뒤 · 01 §8 미결 196).

import '../dto/calendar.dart';

/// 캘린더 동기 상태 1건.
abstract interface class CalendarRepository {
  Future<CalendarSyncStatus> status();
}
