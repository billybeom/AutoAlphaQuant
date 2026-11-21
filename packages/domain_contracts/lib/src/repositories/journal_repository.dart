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
  ///    🆕 v1.5(01 §15-3) — 운반 = `AppRoutes.journalRebalance` → 셸 → `JournalTimeline(rebalanceEventId:)`
  ///    → 이 인자. 씨앗 기간은 [watchRebalanceScope] 의 `range` 다.
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
  /// 🆕 v1.35(01 §44 · K296 · K300) — 인자 = **저널 id**(`AppRoutes.journalDraft` 의 `:decisionId` 그대로) · 모르는 키 = `Future` 에러 ·
  /// 서약 줄 = 재량 예산을 쓰는 목적에만(그 밖 0줄) · 인용 규칙 선택지 코드 ∈ `JournalRuleCitedCodes`.
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
  /// 🆕 v1.35(01 §44 · K296) — 인자 = 결정 id(J-2 «작성됨» 링크 `journalRead`) **또는** 저널 id(`J-3` executed 뒤 끼워 넣기 ·
  /// 안전 저널) 둘 다 받는다 — 해석(저널 id 먼저 · 없으면 결정 id → `decision_log.journal_id`) = 엔진 · 저널 id 로 열리면
  /// `decisionLink` = 그 저널이 붙은 결정이 있을 때만(없으면 null — 기존 «null = 부재») · 둘 다 아니면 스트림 에러(위 규칙 그대로).
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId);

  // ── 🆕 계약 v1.5(R12 선행 M2 보강 · 01 §15-3 · §8 미결 49) ─────────────────────

  /// 🆕 v1.5 — `J-1` 회차 조건의 범위 설명(회차 칩 글자 + 씨앗 기간). 키 = 셸이 라우트 파라미터에서
  /// 꺼내 `JournalTimeline(rebalanceEventId:)` 로 준 값.
  /// null = 엔진이 그 회차를 모른다 → 칩 **부재**. 🔴 엔진 규칙: null 이면 같은 id 의
  /// [watchTimeline] 은 0행이고 «없음»의 문장은 그 봉투의 `emptyLabel` 이 말한다
  /// (봉투 있는 목록 = 빈 상태 · 봉투 없는 VM(`J-2`)의 «스트림 에러» 잠정 규칙(§8 미결 50 ③)과 다른 축).
  /// 🔴 `RebalanceEvent.journalTimelineLink` 가 non-null 인 회차에 대해서는 null 을 주지 않는다.
  /// 🔴 화면이 `RebalanceRepository` 를 구독해 글자를 조립하지 않는다(그것이 조인이다).
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId);

  // ── 🆕 계약 v1.7(J-4 선행 M2 보강 · 01 §16 · §8 미결 46) ───────────────────────

  /// 🆕 v1.7 — `J-4` 채점 **대기** 카드 목록. 봉투(`ListResult`) · 빈 상태 문장 = 봉투 `emptyLabel`.
  /// 🔴 `rows` 의 [BlindReviewCard.result] 는 **늘 null** 이다(대기 = 채점 전).
  /// 🔴 엔진이 정렬해서 준다(오래된 결정부터 — K4) — 화면은 재정렬·거르기·세기 0, `rows[0]` 을 고정 카드로 쓴다.
  /// 🔴 엔진 의무: 채점이 집행돼 그 결정의 카드에 `result` 가 실리는 **같은 갱신에서** 그 결정은 이 목록에서 빠진다.
  /// 🔴 행 수 = 같은 [mode] 의 `watchTimelineBadges` «리뷰 대기 n건»의 n — 화면이 세지 않는다(배지 문구가 말한다).
  /// 🔴 큐가 비면 같은 [mode] 의 배지 목록에 `BLIND_REVIEW_PENDING` 행이 **없다**(«0건» 배지 금지 — 정상 = 무소식).
  /// 대상·진입 시점 = 엔진 규칙(K3 · 06). `hasMore` 는 늘 false(목록 전체 · `limit` 없음) — 화면 미사용.
  /// `J-4` 화면은 **인자 없이** 부른다(SIM 결정의 리뷰 = §8 미결 99).
  /// 🔵 K24 확정(2026-10-20) — v1.7 = LIVE 만: 모의투자(DRY_RUN) 기간에는 LIVE 결정이 없어 큐가 비고 봉투의
  /// `emptyLabel` 만 보인다(화면 무변경으로 뒤에 넓힐 수 있다 — X6 창).
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  });

  /// 🆕 v1.7 — `J-4` 카드 1건(고정 카드). 채점 전 = `result == null` · 채점 집행 뒤 = **같은 스트림에**
  /// `result` 가 실린 값이 온다(02 그림 M6-13 «재조회» — 화면이 다시 부르거나 기다리지 않는다).
  /// 모르는·리뷰 대상이 아닌 id = 스트림 에러(봉투 없는 VM 의 **잠정** 규칙 — §8 미결 50 ③ · `watchDecisionJournal` 과 같다).
  /// 🔴 화면은 `watchDecisionDetail`·`watchDecisionJournal`·`watchTimeline` 으로 카드를 조립하지 않는다.
  Stream<BlindReviewCard> watchBlindReviewCard(String decisionId);
}
