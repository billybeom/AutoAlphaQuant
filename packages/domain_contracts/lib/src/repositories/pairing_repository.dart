// 01 §4-1 — 🆕 계약 v1.16(01 §25 · K4 · K27 · 발주자 결정 2026-11-03 ③) — `V-01` 조회 전용 QR 페어링 읽기 창구.
//
// 🔴 **뷰어(iOS) 빌드에 주입된다** — 뷰어에는 `SettingsActions` 가 주입되지 않는다(settings_actions.dart 머리).
// 🔴 스캔·토큰 클레임·저장 = **플랫폼**(조립 앱 · 카메라 플러그인 = C-3 밖 · 01 §8 미결 13 과 한 창) —
//    플랫폼이 클레임한 결과를 이 스트림에 싣는다. 화면은 스캐너 자리를 비우고 결과를 그대로 그린다
//    (쓰기 0 · URL·키 수동 입력 0 · 04 §9-7).

import '../dto/onboarding.dart';

/// `V-01` 페어링 상태 읽기 창구.
abstract interface class PairingRepository {
  /// 스캔 전(`result` null) → 결과(`OK` · 실패 + 원문 코드). 폐기된 토큰 = 엔진·플랫폼이 즉시 차단해 실패로 싣는다.
  Stream<PairingVm> watchPairing();
}
