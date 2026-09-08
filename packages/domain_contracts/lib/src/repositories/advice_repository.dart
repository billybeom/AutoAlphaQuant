// 01 §4-1 · §10 — 🆕 X7 투자 안내 읽기 창구.
//
// 🔴 전부 읽기 전용이며 쓰기는 §4-2 명령 API 경유다.

import '../dto/advice.dart';
import '../dto/journal.dart';
import '../enums/advice.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 안내함 · 요약 · 상세 · 이력 · 수기 기록 폼 사양.
abstract interface class AdviceRepository {
  /// `A-1` 안내함.
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  });

  /// 홈·알림 앵커.
  /// 🔴 `openCount` 의 정의는 엔진이 갖는다(G-08) — 화면이 재구현하지 않는다.
  Stream<AdviceInboxSummary> watchSummary();

  /// `A-2` 상세.
  Future<AdviceItem?> findById(String adviceId);

  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range});

  /// `A-3` 수기 기록 폼 사양.
  /// 🔴 A16 — **Future 가 아니라 Stream 이다.** 계약 3조 ②(모든 스트림은 `AsOf` 를 싣는다)를
  ///    Future 한 방으로 우회하면, 임시공휴일 해제·슬리브 종목 교체 뒤에도 화면이 **오래된
  ///    판정으로** 사람의 실제 거래일을 막는다. 신선도 초과면 `A-3` 는 폼을 열지 않고
  ///    엔진 문구를 보인다 — 🔴 «오래된 규칙으로 막는 것»보다 «막지 못한다고 말하는 것»이 안전하다.
  Stream<ManualFillFormSpec> watchManualFillFormSpec();

  /// 🆕 G-23 — 이 **안내**에 연결된 체결 목록(`A-2` 「기록된 체결」 블록).
  /// 🔴 `JournalRepository.fillChain(entryId)` 와 **다른 것이다** — `fillChain` 은 «한 체결의
  ///    정정 체인», 이것은 «한 안내의 체결들»이다. 02 §3-7 의 `fillChain(adviceId)` 인용은
  ///    오기이며 정본 우선순위상 01 이 이긴다.
  /// 🔴 정정된 행도 전부 온다 — 화면이 `fillKind` 로 접어 묶는다.
  /// 🔴 지연 이행(`LATE_FILL`)으로 참조만 걸린 체결도 포함한다.
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId);
}
