// 01 §4-1 — 리밸런싱(M7) 읽기 창구.

import '../dto/rebalance.dart';
import '../primitives/date_range.dart';

/// 리밸런싱 회차 목록 · 다음 회차 예상.
abstract interface class RebalanceRepository {
  Stream<List<RebalanceEvent>> watchEvents(DateRange r);

  /// 🆕 G-41 — 다음 회차 예상(`S7-6c` · `H-02` D-7 예고 행).
  /// 🔴 `dDayText`·`expectedDateText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지 않는다.
  /// 🔴 **nullable 이 아니다**(N-4) — 「예정 없음」도 **값으로** 오며 그 상태의 유일한
  ///    문구가 `emptyLabel` 이다. null 을 허용하면 화면이 「예정된 회차 없음」을 스스로
  ///    쓰게 되어 계약 3조 ③(빈 상태 문구도 엔진 생성)이 깨진다.
  Stream<NextRebalanceVm> watchNext();
}
