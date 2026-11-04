// 🆕 계약 v1.17(01 §26 · K12) — M8 `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드 읽기 창구.
// 🔴 원고 = M2 번들(03_실행 §10-5 · 04_안전장치 §5-5) — 뷰어도 같은 번들을 읽는다(폰이 죽어도 열린다 · 발주자 결정 ③).

import '../dto/incident.dart';

/// `D-02`·`D-03` 문서 창구(읽기 전용 · 쓰기 0).
abstract interface class RunbookRepository {
  /// `D-02` 목록.
  Stream<RunbookIndexVm> watchRunbookIndex();

  /// `D-02` 상세 — 모르는 id = `RunbookVm.missingLabel`(스트림 에러 아님).
  Stream<RunbookVm> watchRunbook(String runbookId);

  /// `D-03` 카드.
  Stream<EmergencyCardVm> watchEmergencyCard();
}
