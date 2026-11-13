// `planned_work` 평시 정리 포트 가짜(🆕 E14c2 · 설계 13 §8 R74 M5) — 부른 날을 담는다 · 던지기 주입.
//
// 🔴 테스트 전용 — 앱 코드(lib/)는 import 하지 않는다(배럴 `core_engine/testing.dart`).

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import '../resume/planned_work_ledger.dart';

/// 평시 정리 가짜.
class FakePlannedWorkLedger implements PlannedWorkLedger {
  /// 부른 날(차례대로).
  final List<TradeDate> calls = <TradeDate>[];

  /// 돌려줄 옮긴 행 수.
  int settled = 0;

  /// 다음 부름에 던질 것(null = 안 던짐).
  Exception? throwing;

  @override
  Future<int> settle(TradeDate today) async {
    calls.add(today);
    final Exception? t = throwing;
    if (t != null) throw t;
    return settled;
  }
}
