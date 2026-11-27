/// AutoAlphaQuant 뷰어 전용 읽기 패키지(설계 13 §8 R53 · 지도 D1).
///
/// 🔴 엔진 · 주문 · 원장 코드가 없다 — viewer 앱은 이 패키지로만 읽기 모델에 닿는다(01 §1-1).
library;

// 🆕 E11q-s04a — S04 배분 `rm_config_view` 7열 → 계약 VM(01 §8 미결 210 의 함수 몫 · 못 읽으면 던진다 — K206).
export 'src/allocation_columns.dart' show allocationEditorVmFromColumns;

// 🆕 E11-viewer-223 — 목록 봉투(`rm_list_envelope`) · `ListResult` 조립(01 §8 미결 223 ⓑ · K310).
export 'src/list_envelope.dart'
    show ReadModelListEnvelope, listEnvelopeOfRow, listResultOf;
// 🆕 E11-viewer-223 — 읽기 모델 22표 행 → 계약 DTO(01 §8 미결 223 ⓐ · 계약 v1.36 §45).
export 'src/read_model_rows.dart'
    show
        ReadModelReader,
        ReadModelReaders,
        ReadModelRow,
        decodeReadModelJson,
        opsRhythmOfRow,
        performanceSeriesOfRows,
        readModelBindingColumns,
        readModelBindingJson,
        sleeveCatalogOfRow;
// 🆕 E11-viewer-223 — 읽기 모델 원천 창구 뼈대(네트워크 0 · 구현 = 뷰어 앱 착수 카드).
export 'src/read_model_source.dart'
    show ReadModelOrder, ReadModelQuery, ReadModelRowMissing, ReadModelSource;
// 🆕 R277(E11m-b · 설계 13 §8 R277) — 뷰어 `CommandApi`(뷰어 4종 INSERT · `command_status` 읽기 · 큐 없음).
export 'src/supabase/viewer_command_api.dart'
    show ViewerCommandApi, ViewerCommandFailure, ViewerCommandFailureKind;
// 🆕 R277 — 뷰어 PostgREST 얇은 호출기(`http` · 공개 키 + 접근 토큰 · 401/403 = 토큰 새로 한 번).
export 'src/supabase/viewer_rest.dart'
    show ViewerRest, ViewerRestFailure, ViewerRestResult;
// 🆕 R277 — 뷰어 세션 포트(구현 = E11m-c 페어링 · 01 §8 미결 247).
export 'src/supabase/viewer_session.dart' show ViewerEndpoint, ViewerSession;
// 🆕 E11i — 스키마 버전 게이트(M4-8 · D17).
export 'src/version_gate.dart'
    show
        ContractVersion,
        ReadModelGate,
        ReadModelVersionStamp,
        compiledVersionStamp,
        readModelGate,
        readModelGateAfter,
        readModelGateOfRow;
// 🆕 E11-viewer-223 — 뷰어 계약 창구 뼈대(22표 → 계약 저장소 · 서지 않는 창구 = UnsupportedError).
export 'src/viewer_repositories.dart' show ViewerReadModels;
