// 🆕 계약 v1.17(01 §26 · K9) — M8 `D-01` 장애 배너 읽기 창구.
// 🔴 폰(로컬 엔진)·뷰어(rm_* + `phoneDown` 파생 — 06 숙제)가 **같은 DTO** 를 준다(01 §4-1 계약 3조 ①).
// 🔴 셸 주입은 nullable 기본 null(배너 부재) — 조립 앱은 반드시 override 하고 조립 테스트 1줄로 비-null 을 단언한다(06 M4-12).

import '../dto/incident.dart';

/// `D-01` 장애 배너 — 최대 1건(엔진이 고름).
abstract interface class IncidentRepository {
  /// 늘 값을 낸다 — 배너 없음 = `IncidentBannerVm(banner: null)`.
  Stream<IncidentBannerVm> watchIncident();
}
