// 01 §1-2 · docs/toolchain_notes.md §3-3 — JSON 컨버터 4종의 재수출 창구.
//
// 🔴 **선언은 `money.dart` 에 있다**(인벤토리 §1 표: money.dart 가 `DecimalStringConverter`·
//    `DurationSecondsConverter` 를 담는다). toolchain_notes §3-1 의 템플릿이 부르는 경로가
//    `../primitives/converters.dart` 라 두 문서의 경로가 갈리므로, 어느 쪽으로 import 해도
//    같은 4종이 오도록 여기서 다시 내보낸다.
// 🔴 이 파일에 새 컨버터를 **선언하지 않는다** — 선언이 두 곳이 되면 규약의 소유자가 둘이 된다.
export 'money.dart'
    show
        DecimalStringConverter,
        DurationSecondsConverter,
        RatioConverter,
        TradeDateConverter;
