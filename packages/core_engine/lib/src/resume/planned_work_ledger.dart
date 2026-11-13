// `planned_work` 평시 정리 포트(06 X2-3 · 설계 13 §8 R74 M4 · M5).
//
// 🔴 여기에 두는 까닭 — 부르는 쪽(`KrOrderJobs.runClose`)은 trading_runtime, 구현(SQLite)은 data_sync 다
//    (잡 실행 기록 · 하트비트 포트와 같은 수).
// 🔴 정리 = PLANNED 행마다 기한 지남 → EXPIRED · 끝남 → DONE(평시에도 전이를 남긴다 — «만료를 지나 DONE 으로 갔는가»의
//    사후 증명은 평시 기록이 있어야 한다).

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

/// 평시 정리 포트 — 구현 = data_sync `SqlitePlannedWorkStore` · 시험 = `FakePlannedWorkLedger`.
abstract interface class PlannedWorkLedger {
  /// [today] 의 정리 — 옮긴 행 수.
  Future<int> settle(TradeDate today);
}
