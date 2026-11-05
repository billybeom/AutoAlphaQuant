// 🆕 계약 v1.17(01 §26 · K13) — M8 `B-01` 목차 항목 상태.
import 'package:freezed_annotation/freezed_annotation.dart';

/// `B-01` 목차 항목 상태 — 🔴 화면은 **아이콘·색 선택에만** 쓴다(글자 = `HandbookEntry.stateLabel`).
/// [preparing] = 원고 대기(04 §8 ⑥⑦⑧ · 06 §3-11 HB-1~HB-3 — 본문을 대신 쓰지 않는다) ·
/// [archived] = 보관됨(새틀라이트 — «왜 없앴나» 한 단락 · 목차에서 접힘 = 엔진이 상태 글자로 보낸다 · 화면 접기 판정 0).
enum HandbookEntryState {
  @JsonValue('READY')
  ready('READY'),
  @JsonValue('PREPARING')
  preparing('PREPARING'),
  @JsonValue('ARCHIVED')
  archived('ARCHIVED');

  const HandbookEntryState(this.wire);

  /// JSON 표기.
  final String wire;
}
