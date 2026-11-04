// 🆕 계약 v1.17(01 §26 · K16) — M8 `B-01`·`B-02` 전략 핸드북 읽기 창구.
// 🔴 앵커 = `handbook://` 뒤 글자 전부(셸 라우터 한 곳이 뗀다) · 별칭 해석·모르는 앵커 판정 = 엔진.
// 🔴 셸 주입은 nullable 기본 null(셸 핸드북 자리표시자 그대로) — 조립 앱 override 의무(06 M4-12).

import '../dto/handbook.dart';

/// `B-01` 목차 · `B-02` 페이지.
abstract interface class HandbookRepository {
  Stream<HandbookIndex> watchIndex();

  /// 모르는 앵커 = `HandbookPage.missingLabel`(스트림 에러 아님).
  Stream<HandbookPage> watchPage(String anchor);
}
