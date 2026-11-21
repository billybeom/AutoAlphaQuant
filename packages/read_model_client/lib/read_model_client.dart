/// AutoAlphaQuant 뷰어 전용 읽기 패키지(설계 13 §8 R53 · 지도 D1).
///
/// 🔴 엔진 · 주문 · 원장 코드가 없다 — viewer 앱은 이 패키지로만 읽기 모델에 닿는다(01 §1-1).
library;

// 🆕 E11q-s04a — S04 배분 `rm_config_view` 7열 → 계약 VM(01 §8 미결 210 의 함수 몫 · 못 읽으면 던진다 — K206).
export 'src/allocation_columns.dart' show allocationEditorVmFromColumns;

// 🆕 E11i — 스키마 버전 게이트(M4-8 · D17).
export 'src/version_gate.dart'
    show
        ContractVersion,
        ReadModelGate,
        ReadModelVersionStamp,
        compiledVersionStamp,
        readModelGate,
        readModelGateOfRow;
