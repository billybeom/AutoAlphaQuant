// 기기 시계(E11p3a · 설계 e11p-map Q2).
//
// 🔴 신뢰 시각(리스 TTL · 킬스위치 48h · 냉각)은 이것이 아니다 — Supabase 서버 시각(E11k · `TrustedClock`).
//    여기는 잡 규약 · 기록 · 회차 판정에 쓰는 기기 시각뿐이다.

import 'package:domain_contracts/domain_contracts.dart' show Clock;

/// 기기 시계 — UTC.
class SystemClock implements Clock {
  /// 만든다.
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
