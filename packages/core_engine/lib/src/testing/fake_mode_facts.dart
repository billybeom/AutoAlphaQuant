// 모드 판정 입력 가짜(🆕 E15a · 설계 13 §8 R81 V5) — 입력을 바꿔 끼우고 부른 횟수를 센다 · 던지기 주입.
//
// 🔴 테스트 전용 — 앱 코드(lib/)는 import 하지 않는다(배럴 `core_engine/testing.dart`).

import '../mode/mode_guard.dart';

/// 모드 판정 입력 가짜.
class FakeModeFacts implements ModeFactsSource {
  /// 가짜를 만든다(기본 = 세션 없음 · 실키 검증됨).
  FakeModeFacts({
    this.handoverSessionValid = false,
    this.liveKeysVerified = true,
  });

  /// 유효한 세션 토큰이 있나.
  bool handoverSessionValid;

  /// 실키가 검증됐나.
  bool liveKeysVerified;

  /// 다음 부름에 던질 것(null = 안 던짐).
  Exception? throwing;

  /// 부른 횟수.
  int calls = 0;

  @override
  Future<ModeFacts> facts() async {
    calls++;
    final Exception? t = throwing;
    if (t != null) throw t;
    return ModeFacts(
      handoverSessionValid: handoverSessionValid,
      liveKeysVerified: liveKeysVerified,
    );
  }
}
