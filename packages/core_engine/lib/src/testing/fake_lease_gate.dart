// 리스 포트 가짜(🆕 E14a · 설계 13 §8 R71 L8) — 판정을 바꿔 끼우고 부른 횟수를 센다 · 던지기 주입.
//
// 🔴 테스트 전용 — 앱 코드(lib/)는 import 하지 않는다(배럴 `core_engine/testing.dart`).

import '../ops/lease_gate.dart';

/// 리스 가짜.
class FakeLeaseGate implements LeaseGate {
  /// 가짜를 만든다(기본 = 유효).
  FakeLeaseGate([this.verdict = LeaseVerdict.valid]);

  /// 다음 판정.
  LeaseVerdict verdict;

  /// 다음 부름에 던질 것(null = 안 던짐).
  Exception? throwing;

  /// 부른 횟수.
  int calls = 0;

  /// [check] 를 부를 때마다 판정을 바꾼다(앞에서부터 하나씩 · 다 쓰면 [verdict]).
  final List<LeaseVerdict> script = <LeaseVerdict>[];

  @override
  Future<LeaseVerdict> check() async {
    calls++;
    final Exception? t = throwing;
    if (t != null) throw t;
    return script.isEmpty ? verdict : script.removeAt(0);
  }
}
