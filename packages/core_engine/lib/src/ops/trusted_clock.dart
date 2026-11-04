// 신뢰 시각 포트(M1-13 · 설계 13 §8 R54 J1) — 실물(Supabase 서버 `now()` · 시계 차 판정 D13) = E11k.
//
// 🔴 «모름»(null)은 «지금»이 아니다 — 신뢰 시각이 필요한 쓰기(운영 파라미터의 적용 시점 등)는 모르면 거부한다.

/// 신뢰 시각.
abstract interface class TrustedClock {
  /// 신뢰할 수 있는 지금(UTC) — 모르면 null.
  DateTime? trustedNowUtc();
}
