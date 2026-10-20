// 01 §4-1 — 보유현황(M6) 읽기 창구.
// 🆕 v1.8(01 §17 · R4 선행) — `H6-1`~`H6-3` 화면 창구 3(`watchHoldingsOverview` · `watchHoldingDetail` ·
//    `watchAllocation`) · 받침대 `UnimplementedHoldingsRepository`(`lib/testing.dart`).

import '../dto/holdings.dart';
import '../dto/rebalance.dart';
import '../primitives/list_result.dart';

/// 보유 종목 목록.
abstract interface class HoldingsRepository {
  /// 🔴 `includePnl` 은 **기본 false**다(결정 8) — 화면이 값을 받아 놓고 접기만 하면
  ///    결정 8이 렌더 구현 디테일에 의존하게 된다.
  /// 🔴 X7 D7 — `external_holding`(= `scope == external`)의 표시 UNION 은
  ///    **이 리포지토리 한 곳에서만** 만든다(C-23). 파생 계산 경로는 `positions` 만 읽는다.
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false});

  // ── 🆕 계약 v1.8(R4 선행 M2 보강 · 01 §17) ───────────────────────────────
  // 🔵 [watchHoldings] 는 남는다(시그니처 무변경) — `H6-*` 화면은 부르지 않는다(C-44 ⑬).

  /// 🆕 v1.8 — `H6-1` 한 화면(카드·종목 행·시스템 밖 섹션). 🔴 `includePnl` 기본 false(결정 8) —
  /// 펼침 조작 1회 = `true` 재구독 · 화면 이탈 = 상태 소멸(저장 0). 뷰어 구현은 `true` 여도 `pnl` 을 싣지 않는다(K15).
  /// 🔴 X7 D7 — 시스템 밖 자산의 표시 UNION 은 여기서 만든다(`external`) · 파생 경로는 `positions` 만.
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false});

  /// 🆕 v1.8 — `H6-2` 보유 1건. [holdingId] = `HoldingRow.holdingId`(셸이 라우트에서 꺼내 생성자로 준다).
  /// 모르는 id = 스트림 에러(봉투 없는 VM 의 **잠정** 규칙 — §8 미결 50 ③). `includePnl` 규칙은 위와 같다.
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  });

  /// 🆕 v1.8 — `H6-3` 배분 행 전부(회계 기준). 홈 블록 4(R13)도 이 창구의 `sleeveWeight`·`*PctText` 만 쓴다.
  Stream<SleeveAllocationVm> watchAllocation();
}
