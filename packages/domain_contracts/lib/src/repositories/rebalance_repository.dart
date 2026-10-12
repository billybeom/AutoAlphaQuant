// 01 §4-1 — 리밸런싱(M7) 읽기 창구.

import '../dto/rebalance.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 리밸런싱 회차 목록 · 회차 1건 · 다음 회차 예상.
abstract interface class RebalanceRepository {
  /// `S7-6a` 회차 타임라인 — 봉투(`ListResult`) · 빈 상태 문장 = 봉투 `emptyLabel`(v1.5).
  /// 🆕 v1.6(01 §15-4 · 발주자 결정 ① · §8 미결 88 의 «범위 고르기» 몫 · K26) — [range] == null =
  ///    **전체 기간**(첫 회차부터 · 기간으로 자르지 않는다). 이름 인자 꼴은 v1.3 `series(range:)` 선례지만
  ///    뜻은 다르다 — `series` 의 null 은 «엔진이 고른 구간»이라 `periodLabel` 이 말하고, 여기의 null 은
  ///    **고르지 않음**이라 말할 기간이 없다(그래서 봉투에 기간 글자를 두지 않는다 · 비평 #10).
  ///    어느 모드(LIVE·SIM)의 행이 오는지는 §8 미결 89. 🔴 R12 화면은 **인자 없이** 부른다 — 화면이
  ///    `DateRange` 를 만들지 않는다. `ListResult.hasMore` 는 전체 기간·`limit` 없음이라 늘 false — 화면 미사용.
  /// 🔴 `rows` 는 엔진이 **시간 역순**으로 정렬해서 준다(03 §11-a) · 화면은 재정렬·거르기·세기 0.
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range});

  /// 🆕 v1.5(01 §15-3 ★ⓐ) — `S7-6b` 회차 1건. `S7-6b`(`RebalanceEventScreen`)는 파라미터 라우트
  /// `rebalanceEvent` 의 `:rebalanceEventId`(셸 → 생성자 인자 → 키)로 **이 창구 하나만** 구독한다.
  /// 🔴 [watchEvents] 행을 id 로 고르면 반려(거르기도 판정이다).
  /// 모르는·지난 id = 스트림 에러(**잠정** — `JournalRepository.watchDecisionDetail` 과 같은 묶음 ·
  /// §8 미결 50 ③ 확정 때 함께 고친다).
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId);

  /// 🆕 G-41 — 다음 회차 예상(`S7-6c` · `H-02` D-7 예고 행).
  /// 무변경 — 단 v1.6 에서 [NextRebalanceVm] 의 두 글자가 nullable 이 되고 `asOf` 가 생겼다.
  /// 🔴 `dDayText`·`expectedDateText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지 않는다.
  /// 🔴 **nullable 이 아니다**(N-4) — 「예정 없음」도 **값으로** 오며 그 상태의 유일한
  ///    문구가 `emptyLabel` 이다. null 을 허용하면 화면이 「예정된 회차 없음」을 스스로
  ///    쓰게 되어 계약 3조 ③(빈 상태 문구도 엔진 생성)이 깨진다.
  Stream<NextRebalanceVm> watchNext();
}
