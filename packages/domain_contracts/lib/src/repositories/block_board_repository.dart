// 01 §4-1 — 🆕 계약 v1.25(01 §34 · K154) — `M5-5` 차단 보드 읽기 창구(`ui_safety` 만 · 상태를 바꾸는 경로 0 — C-7).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용) · `BreakerLadderRepository`(사다리 단독) 무변경 — 보드는 둘을 감싼 한 스트림이다(v1.24 K113 결).

import '../dto/safety_gate.dart';

/// 차단 보드 한 화면.
abstract interface class BlockBoardRepository {
  Stream<BlockBoardVm> watchBoard();
}
