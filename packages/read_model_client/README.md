# read_model_client — 뷰어 전용 읽기 패키지

> 설계 13 §8 **R53**(E11i) · 지도 **D1**(발주자 결정 2026-11-04 — 뷰어 전용 읽기 패키지 신설) · 01 §1-1 의존 표 · 04 M8 §2-4 스키마 버전 게이트.

## 왜 따로 있나

viewer 앱(`apps/app_viewer_ios`)이 `data_sync` 를 의존하면 `data_sync` → `core_engine` 으로 **엔진 · 원장 코드가 viewer 빌드에 들어간다**(지도 X1). viewer 에는 «주문 · 원장 쓰기를 부를 통로 자체가 없어야» 한다 — 그래서 viewer 는 이 패키지로만 읽기 모델에 닿고, `data_sync` 는 **operator 전용**이 된다.

## 의존 규칙(🔴 기계 검사)

| 허용 | 🔴 금지 |
|---|---|
| `domain_contracts` · (뒤에) Supabase 순수 Dart 클라이언트(지도 D2) | `core_engine` · `broker_gateway` · `trading_runtime` · `data_sync` · `sqlite3` · `decimal`(화면 쪽과 같은 까닭 — 금액 산술 금지) · `flutter` |

- `tool/check_boundaries.sh` **[9]** 이 이 패키지의 `pubspec` 직접 의존과 `lib/` import 를 본다.
- **[8]** 이 viewer 앱의 **전이 의존 그래프**(`path:` 를 재귀로 따라감)에 `core_engine` · `broker_gateway` · `trading_runtime` · `data_sync` · `sqlite3` 가 없는지 본다.

## 지금 있는 것

| 파일 | 내용 |
|---|---|
| `lib/src/version_gate.dart` | 🆕 E11i — **스키마 버전 게이트**(M4-8 · D17): `readModelGate(원격 스탬프)` → `ok` · `degraded` · `incompatible`. 행을 못 읽음 · `schema_version` 다름 · `hash_format_version` 다름 · `contract_version` major 다름 = **incompatible** · 원격 minor 가 더 큼 = degraded · 그 밖 = ok. 기준 = 이 빌드에 컴파일된 계약 상수. 🆕 E11-viewer-223 `readModelGateAfter` — 창구가 행을 못 읽음(`FormatException`) = incompatible(미결 223 ⓔ). |
| `lib/src/allocation_columns.dart` | E11q-s04a — S04 배분 7열 → `AllocationEditorVm`(v1.28 · 무변경 — 아래 `ReadModelReaders.allocationEditor` 와 같은 VM). |
| `lib/src/read_model_rows.dart` | 🆕 E11-viewer-223 — **22표 행 → 계약 DTO**(01 §8 미결 223 ⓐ · 계약 v1.36 §45): 결속 읽개 25(`ReadModelReaders`) = 계약 상수 `ReadModelTables` 하나로 접두 떼기 · 펼친 키 다시 묶기 · 제외 키 = 뷰어 판 값 → `X.fromJson` 한 번. 🔴 못 읽으면 `FormatException`(열 없음 · 형 틀림 · 모르는 와이어 값 · null 칸이 DTO 기본 값으로 메워짐). 시리즈 + 점(`date` 오름차순) · DTO 밖 목록 열(`sleeve_catalog` · `rhythm`). |
| `lib/src/list_envelope.dart` | 🆕 E11-viewer-223 — **목록 봉투 · `ListResult`**(미결 223 ⓑ · K310): `rm_list_envelope` 행 → 봉투 · `listResultOf`(limit+1 → `hasMore` · 받은 차례 그대로 · 봉투 없음 = 던짐 · 필터 빈 문장 = 봉투 글자 또는 null). |
| `lib/src/read_model_source.dart` | 🆕 E11-viewer-223 — **원천 창구 뼈대**: `ReadModelSource`(select · watch) · `ReadModelQuery`(표 하나 · 같음 · 차례 · 개수 — 표 상수 밖 열 = ArgumentError) · `ReadModelRowMissing`. 네트워크 0. |
| `lib/src/viewer_repositories.dart` | 🆕 E11-viewer-223 — **뷰어 계약 창구 뼈대** `ViewerReadModels`(저장소 14 · 원천 하나 · 화면 모드 하나): 모드별 1행 · 키 한 행 · jsonb 목록 · 시리즈 점 · `is_default` 행(미결 223 ⓓ) · 봉투 = 선다 · 행 표 목록(차례 · 소속 열 없음 = 계약 창 대기) · 조립 VM · 폰 전용(원천 열 0 = 223 ⓒ) · 사용자 지정 구간 = `UnsupportedError`. 게이트 `watchGate()`(행 없음 · 원천 오류 = incompatible). |

## 아직 없는 것

- `ReadModelSource` 실물(Supabase 순수 Dart 클라이언트 · RLS select · Realtime — E11l2 뒤 뷰어 앱 착수 카드) · 뷰어 `CommandApi` 4종 INSERT(E11m).
- 행 표 목록 창구(일지 · 보유 · 회차 · 안내 수신함 · 이력 · 차이 · blind 대기 · 알림 · 체인) — 엔진 차례 · 소속을 실을 열이 계약에 없다(🔴 계약 창 대기 · 01 §8 미결 223 꼬리).
- 조립 VM 원천(미결 223 ⓒ) · 필터 빈 문장 열 · 기간 프리셋 목록 열 — 계약 판.
- 게이트 결과를 셸 배너에 잇기(조립) — 🟡 게이트 상태 열거형 · 배너 문자열의 계약 자리는 계약 창 몫.
