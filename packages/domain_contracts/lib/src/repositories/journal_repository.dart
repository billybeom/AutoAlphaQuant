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

  // ── 🆕 계약 v1.1(2026-09-17 · M2 보강) ────────────────────────────────────

  /// `J-1` 필터의 상태·출처·종목 선택지(§8 미결 37).
  /// 🔵 기간 = `ConfigRepository.watchRangePresets()` · 슬리브 = `watchSleeves()`.
  /// 🔴 화면이 열거값을 순회해 선택지를 만들거나 `rows` 에서 종목을 모으지 않는다.
  Stream<JournalFilterCatalog> watchFilterCatalog();

  /// `J-1` 상단 배지(「확인 중 2건」 등 — §8 미결 38). 🔴 비면 배지 줄이 없다.
  /// 🔴 화면이 `watchTimeline` 의 `rows` 를 세어 건수를 만들지 않는다.
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  });

  /// `J-2` 거래 상세 한 화면의 전부 — 체인 6단계·스냅샷·임계 대조·거부 추적·체결 행·이동 버튼.
  /// 🔵 `chainOf`·`findByDecisionId`·`fillChain` 은 남는다(다른 화면의 참조 링크용) — `J-2` 는
  ///    이 메서드 **하나만** 구독한다(화면이 세 결과를 조립하면 그것이 조인이다).
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId);

  /// `J-3` 사전 저널 폼 스펙(서약문·문맥 칩·규칙 인용 선택지).
  /// 🔴 제출은 `CommandApi.submitJournalDraft` — 여기는 읽기뿐이다.
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId);

  /// `J-5` UNKNOWN 해소 보드. 🔴 이 화면에서 `CommandApi` 호출은 0건이다(02 §3-5 수용 a).
  Stream<UnknownBoardVm> watchUnknownBoard();

  // ── 🆕 계약 v1.2(R2b 선행 M2 보강 · 01 §12-2) ─────────────────────────────

  /// 🆕 v1.2 — 결정 1건의 **사전 저널 본문**(`J-3` 읽기 뷰 `J-3R` · `J-3` executed 뒤 · iOS 의
  /// `journalDraft` 대체 · `J-2 journalLink`(작성됨)의 목적지).
  /// 결정은 있는데 저널이 아직 없으면 `body == null` 인 값을 흘린다(«미작성»도 값이다).
  /// 결정 자체가 없으면 스트림 에러 — `watchDecisionDetail` 의 **잠정** 규칙(01 §8 미결 50 ③ · ⬜ 확인
  /// 대기)과 같게 둔다. 50 ③ 이 확정되면 두 메서드를 함께 고친다(화면은 어느 쪽이든 공통 에러 상태).
  /// 🔴 화면은 `findByDecisionId`·`chainOf` 로 조립하지 않는다 — 이 스트림 하나만 구독한다.
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId);
}
