// 영역 D 재수출 창구 — 명령 API·명령 인자·설정 액션(`lib/src/commands/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 화면이 상태를 바꾸는 경로는 여기 있는 것이 전부다. 리포지토리에는
//    쓰기 메서드가 없다(01 §4-1·§4-2).
// 🆕 v1.2 — 셋째 쓰기 창구 = 기기 로컬 초안 `DraftStore`(01 §12-1 · 원장·명령 쓰기가 아니다).
//
// 근거: 01 §4-2·§4-3 · 인벤토리 §5-4.

export 'commands/command_api.dart';
export 'commands/command_context.dart';
export 'commands/command_receipt.dart';
export 'commands/command_state_machine.dart';
export 'commands/draft_store.dart';
export 'commands/drafts.dart';
export 'commands/payloads.dart';
export 'commands/payloads_x7.dart';
export 'commands/settings_actions.dart';
