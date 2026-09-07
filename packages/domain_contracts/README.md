# domain_contracts — M2 도메인 계약

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M2** domain-contracts(계약·읽기 모델)
> **정본**: `11_앱설계/01_M2_도메인계약_초안.md` — 이 패키지가 확정되면 **코드가 정본이고 문서가 설명**이 된다(00_README §9-1)

## 무엇을 담나

화면 담당 AI가 의존하는 **유일한 인터페이스**다. 이 패키지 밖의 타입을 화면이 아는 순간 분업 경계가 사라진다.

| 갈래 | 자리 | 정본 |
|---|---|---|
| 값 객체(`Money`·`Ratio`·`TradeDate`·`AsOf`·`Clock`) | `lib/src/primitives/` | 01 §1-2·§1-3 |
| 뷰모델 DTO(`TradeJournalEntry`·`HoldingRow` …) | `lib/src/dto/` | 01 §2 |
| 열거형(`SleeveId`·`JournalStatus`·`AlertLevel` …) | `lib/src/enums/` | 01 §2-1 |
| 읽기 리포지토리 인터페이스 | `lib/src/repositories/` | 01 §4-1 |
| 명령 API 인터페이스·페이로드 | `lib/src/commands/` | 01 §4-2·§4-3 |
| 코드→문구 매핑 목록 | `lib/src/labels/` | 01 §3 |
| 모의 픽스처 JSON | `fixtures/` | 01 §5 |

## 의존 — 허용 (01 §1-1)

`decimal` · `freezed_annotation` · `json_annotation` · `meta`. **순수 Dart이며 Flutter를 의존하지 않는다.**

## 의존 — 🔴 금지

Flutter SDK · `core_engine` · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · 그 밖의 모든 플랫폼 패키지.

> 계약이 Flutter를 의존하면 순수 Dart인 `core_engine`이 계약을 못 읽고, 엔진과 화면이 서로 다른 타입을 쓰게 된다.

## 이 패키지가 지는 규칙 3개

1. **부작용 없음**(01 §1-4) — 모든 DTO는 `@freezed` 불변이고 **계산 getter가 없다**. `pnlPct`를 `(price / avg - 1)`로 만드는 getter는 경계 규칙 ① 위반이다. `save_`·`write_`·`submit_`·`send_` 함수는 존재하지 않는다.
2. **열거값에는 짝이 되는 `*Label` 문자열 필드가 붙는다**(01 §1-5) — `status` ↔ `statusLabel`. 짝이 없으면 화면이 문구를 분기로 고르게 되고 그것이 «사유 문구 생성»이다.
3. **enum 직렬화는 `@JsonValue`로 못 박는다**(01 §1-1 아래 규약) — Dart는 camelCase, JSON·DDL은 SCREAMING_SNAKE_CASE. 신규 열거값은 **DDL `CHECK` → `@JsonValue` → 픽스처** 순서로 같은 커밋에 넣는다.

## 지금 상태 — 🟡 스캐폴드

`lib/src/`의 각 폴더는 **자리만 있고 비어 있다**. 계약 코드는 G3에서 들어온다. `lib/src/contract_version.dart`의 `'0.0.0-draft'`가 그 표식이다.

**⚠️ 이 PC에는 Flutter·Dart·melos가 없다**(2026-09-06). `dart pub get`·`build_runner`·테스트는 SDK 설치 후 처음 돈다 — 지금은 «파일은 있으나 도는지는 미확인» 상태다.
