// 영역 A 재수출 창구 — 원시타입(`lib/src/primitives/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다. 영역 구현자는 자기 폴더의 파일만 만들고
//    여기에 줄을 더하지 않는다(인벤토리 §0).
// 🔴 `primitives/converters.dart` 는 `money.dart` 의 컨버터 4종을 재수출하는
//    창구일 뿐이라 여기서 다시 내보내지 않는다 — 같은 선언이 두 경로로
//    배럴에 오르면 «어느 쪽이 정본인가»가 다시 흐려진다(인벤토리 §1).
//
// 근거: 01 §1-2(금액) · §1-3(시각·날짜·신선도) · §2-1(봉투·구간).

export 'primitives/as_of.dart';
export 'primitives/date_range.dart';
export 'primitives/list_result.dart';
export 'primitives/money.dart';
