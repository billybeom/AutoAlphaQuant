// 01 §4-1 — 리밸런싱(M7) 읽기 창구.

import '../dto/rebalance.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 리밸런싱 회차 목록 · 회차 1건 · 다음 회차 예상.
abstract interface class RebalanceRepository {
  /// `S7-6a` 회차 타임라인.
  /// 🆕 v1.5(01 §15-3 ★ⓒ) — 반환을 봉투(`ListResult`)로 바꿨다: 빈 상태 문장(«아직 리밸런싱 회차가
  ///    없습니다» 류)을 봉투 `emptyLabel` 이 준다 — 화면이 빈 상태 문구를 쓰지 않는다(계약 3조 ③).
  /// 🔴 `rows` 는 엔진이 정렬해서 준다 · 화면이 거르거나 다시 세지 않는다.
  Stream<ListResult<RebalanceEvent>> watchEvents(DateRange r);

  /// 🆕 v1.5(01 §15-3 ★ⓐ) — `S7-6b` 회차 1건. `S7-6b`(`RebalanceEventScreen`)는 파라미터 라우트
  /// `rebalanceEvent` 의 `:rebalanceEventId`(셸 → 생성자 인자 → 키)로 **이 창구 하나만** 구독한다.
  /// 🔴 [watchEvents] 행을 id 로 고르면 반려(거르기도 판정이다).
  /// 모르는·지난 id = 스트림 에러(**잠정** — `JournalRepository.watchDecisionDetail` 과 같은 묶음 ·
  /// §8 미결 50 ③ 확정 때 함께 고친다).
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId);

  /// 🆕 G-41 — 다음 회차 예상(`S7-6c` · `H-02` D-7 예고 행).
  /// 🔴 `dDayText`·`expectedDateText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지 않는다.
  /// 🔴 **nullable 이 아니다**(N-4) — 「예정 없음」도 **값으로** 오며 그 상태의 유일한
  ///    문구가 `emptyLabel` 이다. null 을 허용하면 화면이 「예정된 회차 없음」을 스스로
  ///    쓰게 되어 계약 3조 ③(빈 상태 문구도 엔진 생성)이 깨진다.
  Stream<NextRebalanceVm> watchNext();
}
