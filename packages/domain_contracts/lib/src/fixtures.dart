// 영역 F 재수출 창구 — 픽스처 경로·봉투 로더(`lib/src/fixtures/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 픽스처는 **합성 데이터**다(C-14 · 실키 0건). `scanForSecrets` 가 그
//    검사의 술어이며 화면 코드가 픽스처를 실행 경로에서 읽지 않는다.
// 🔵 배럴에 올리는 이유: 화면·테스트가 `lib/src/` 를 직접 import 하는 것이
//    인벤토리 §0 의 금지 사항이기 때문이다(영역 F 인계 사항).
//
// 근거: 01 §5 · 인벤토리 §8.

export 'fixtures/fixture_loader.dart';
export 'fixtures/fixture_paths.dart';
