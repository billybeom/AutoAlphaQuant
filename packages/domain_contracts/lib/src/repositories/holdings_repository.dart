// 01 §4-1 — 보유현황(M6) 읽기 창구.

import '../dto/holdings.dart';
import '../primitives/list_result.dart';

/// 보유 종목 목록.
abstract interface class HoldingsRepository {
  /// 🔴 `includePnl` 은 **기본 false**다(결정 8) — 화면이 값을 받아 놓고 접기만 하면
  ///    결정 8이 렌더 구현 디테일에 의존하게 된다.
  /// 🔴 X7 D7 — `external_holding`(= `scope == external`)의 표시 UNION 은
  ///    **이 리포지토리 한 곳에서만** 만든다(C-23). 파생 계산 경로는 `positions` 만 읽는다.
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false});
}
