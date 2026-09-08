// 01 §4-1 — 매매일지(M6) 읽기 창구.
//
// 🔴 여기에는 인터페이스만 있다. 구현체는 둘뿐이고 둘 다 같은 DTO를 돌려준다
//    (`LocalSqliteReader` = 폰 정본 SQLite / `SupabaseReadModel` = viewer RLS + Realtime).

import '../dto/journal.dart';
import '../enums/journal.dart';
import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 매매일지 타임라인·결정 체인·정정 체인.
abstract interface class JournalRepository {
  /// 🔴 `rows` 는 **엔진이 시간 역순으로 정렬해서** 준다 — 화면이 정렬 키를 만들지 않는다.
  /// 🔴 페이징은 커서가 아니라 `limit` 증가 재구독 하나뿐이다(1인 사용자·연 ~934건).
  ///    무한 스크롤 = 바닥 도달 시 `limit += 100` 으로 재구독하고 `hasMore == false` 면 멈춘다.
  /// 🆕 G-39 `origin` — 「수기 기록만」·「브로커 체결만」 필터(02 §3-1 X7).
  ///    🔴 화면이 `rows` 를 받아 거르지 않는다 — **거르기도 판정이다**.
  /// 🆕 G-40 `rebalanceEventId` — `S7-6b` 「이 회차의 주문 N건」 딥링크의 **유일한 경로**.
  ///    🔴 화면이 `RebalanceEvent.orderIntentIds` 를 순회해 거르는 구현은 반려.
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  });

  Future<TradeJournalEntry?> findByDecisionId(String decisionId);

  /// 의도 → 주문 → 체결.
  Future<List<TradeJournalEntry>> chainOf(String decisionId);

  /// 🆕 X7 — 한 체결의 **정정 체인**(ORIGINAL → REVERSAL → RESTATEMENT).
  /// 🔴 `AdviceRepository.fillsOfAdvice(adviceId)` 와 **다른 것이다**(G-23) — 이쪽은
  ///    «한 체결의 정정 체인», 저쪽은 «한 안내의 체결들»이다.
  Future<List<TradeJournalEntry>> fillChain(String entryId);
}
