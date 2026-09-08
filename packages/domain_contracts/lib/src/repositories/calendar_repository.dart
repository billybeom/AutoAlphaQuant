// 01 §4-1 — X4 구글 캘린더 동기 상태 읽기 창구.
//
// ⏸ J-5 — X4 계열 전체는 **이름·타입을 등재하되 구현하지 않는다**(OAuth 동의화면
//    «테스트» 상태 7일 만료 스모크가 미결 · §8-5). 인터페이스 선언까지가 이 회차의 몫이다.

import '../dto/calendar.dart';

/// 캘린더 동기 상태 1건.
abstract interface class CalendarRepository {
  Future<CalendarSyncStatus> status();
}
