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
| `lib/src/version_gate.dart` | 🆕 E11i — **스키마 버전 게이트**(M4-8 · D17): `readModelGate(원격 스탬프)` → `ok` · `degraded` · `incompatible`. 행을 못 읽음 · `schema_version` 다름 · `hash_format_version` 다름 · `contract_version` major 다름 = **incompatible** · 원격 minor 가 더 큼 = degraded · 그 밖 = ok. 기준 = 이 빌드에 컴파일된 계약 상수. |

## 아직 없는 것

- Supabase 클라이언트 · 읽기 모델 행 읽기(E11l2 뒤) · 뷰어 `CommandApi` 4종 INSERT(E11m).
- 게이트 결과를 셸 배너에 잇기(조립) — 🟡 게이트 상태 열거형 · 배너 문자열의 계약 자리는 계약 창 몫.
