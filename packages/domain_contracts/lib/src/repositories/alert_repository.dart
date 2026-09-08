// 01 §4-1 — 알림함(M8) 읽기 창구.
//
// 🔴 `AlertLevel` 의 **표시 계층 사적 재분류는 금지**다(결정 7c) — `min` 은 거르기이지
//    등급을 다시 매기는 자리가 아니다.

import '../dto/safety.dart';
import '../enums/safety.dart';

/// 알림 목록.
abstract interface class AlertRepository {
  Stream<List<AlertItem>> watchInbox({AlertLevel? min});
}
