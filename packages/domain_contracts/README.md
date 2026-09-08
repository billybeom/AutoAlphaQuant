# domain_contracts — M2 도메인 계약

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M2** domain-contracts(계약·읽기 모델)
> **정본**: ~~`11_앱설계/01_M2_도메인계약_초안.md` — 이 패키지가 확정되면~~ ✅ **확정됐다(2026-09-08 · G3).** 이제 **코드가 정본이고 `01_M2_도메인계약_초안.md` 가 설명**이다(00_README §9-1) — 문서와 코드가 어긋나면 **코드가 이기고 문서를 고친다.** 🔴 문서 파일명은 참조가 많아 «초안»으로 유지한다(00_README §0-1 G3 행의 명시적 예외).

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

## 지금 상태 — ✅ 확정 v1.0 (2026-09-08 · G3·G4)

~~`lib/src/`의 각 폴더는 자리만 있고 비어 있다.~~ 계약 코드가 **실물로 들어왔다.** `lib/src/contract_version.dart`의 `contractVersion`은 이제 **`'1.0.0'`** 이고, 77개 픽스처 봉투의 `meta.contract_version`이 같은 값이다.

| 갈래 | 실물 |
|---|---|
| 손으로 쓴 Dart | **78파일**(`lib/`) + 생성물 49(`*.freezed.dart`·`*.g.dart` — `.gitignore` 대상, `melos.bat run build:gen`으로 만든다) |
| 픽스처 JSON | **77건** — `fixtures/` 12(코어) · `m6/` 17 · `m7/` 29 · `m8/` 18 · `m9/` 1 |
| DDL | **6배치** `ddl/batch_a`~`batch_f` + `batch_z_archive_layout.md` |
| 계약 테스트 | `test/` 36파일(`test/contracts/` 34) — **204케이스 = 170 통과 · 34 skip · 0 실패** |

> 🔴 **34 skip 은 «미구현»이 아니라 «아직 검사할 대상이 없다»** — 대부분 `ui_*` 화면 패키지·엔진 런타임·골든 파일이 **선행**해야 성립하는 검사다. 각 skip 은 `test/contracts/` 안에서 **사유 문장을 달고** 남아 있고, 같은 사유가 `11_앱설계/01_M2_도메인계약_초안.md` §7 의 «C-n 구현 상태» 열에 전건 기록돼 있다. 🔴 skip 을 지우거나 통과로 바꾸지 말 것 — 화면 PR 이 그 자리를 채운다.

### M2-8 확정 이름 목록은 어디에 있나

🔴 **`docs/m2-8_naming.md`**(저장소 루트 기준). 01 문서가 ⚠️(이름 미확정)로 남겼던 타입·필드·열거값 **전량**을 확정한 표다 — **104행 · 확정 이름 101건**(A 열거형 17 · B JSON/DDL 표기 5 · C 기존 DTO 신설 필드 12 · D 값 객체·안전 10 · E M6 미정의 9 · F M7 뷰모델 16 · G M8·M9 13 · H 명령·리포지토리 10 · I config 키 6 · J 발주자 몫 6).

- ✅ = 확정·구현. 이 이름을 그대로 쓴다.
- ⏸ = **이름만 확정**이고 기능은 발주자 결정·실측·다른 창 대기 — 🔴 **이름은 써도 되지만 그 이름이 걸린 기능을 구현하지 않는다**(규칙 4조). 대표: `LedgerEventKind`·`LedgerEventRecord`(결정 ㊲ 대기) · `SplitExecutionLeg`(엔진 M1-9b 창) · 기존 명령 5종의 `CommandContext`(배치 D 창) · X4 캘린더 계열 전부. 🔴 이들은 **코드가 아니라 주석으로만** 자리를 고정해 뒀다(`lib/domain_contracts.dart` 머리 · `lib/src/enums/ledger.dart` · `lib/src/commands/payloads.dart`).
- 🔴 **§K 4건은 이 표가 닫지 못한 것**이다 — `CommandState.noOperator`의 DDL 자리 · `AsOf.staleReasonCode` 값 목록 · 자동 매매 알림 10종의 개별 코드 이름 · M2-8 창을 닫는 시점. **구현 중 부딪히면 멈추고 보고한다 — 이름을 지어내지 않는다.**

같이 읽을 것: `docs/contracts_inventory.md`(영역별 이름·파일 경로 규약) · `docs/toolchain_notes.md`(SDK·build_runner·`decimal` 표기 함정).

## 실행법

~~**⚠️ 이 PC에는 Flutter·Dart·melos가 없다**(2026-09-06).~~ ✅ **설치돼 있고 전부 돈다**(2026-09-08 실측 — Flutter 3.47.2 / Dart 3.13.2 / melos 6.3.3).

🔴 명령은 **저장소 루트**에서 돌린다. 개별 패키지에서 `flutter pub get`을 직접 부르지 않는다(경로 의존 연결이 melos 몫이다). 🔴 이 PC의 `melos`는 **`.bat`만** 있으므로 Git Bash에서 이렇게 부른다:

```bash
export PATH="/c/src/flutter/bin:/c/Users/BeomLee/AppData/Local/Pub/Cache/bin:$PATH"
cd "C:/Work/Bob/AutoAlphaQuant"

melos.bat run bootstrap        # clone 직후 1회 — 경로 의존 연결
melos.bat run build:gen        # *.freezed.dart · *.g.dart 생성 (커밋하지 않는다)
melos.bat run analyze          # dart analyze --fatal-infos · 경고 0이 병합 조건
melos.bat run format           # 어긋난 파일이 있으면 실패(고치려면 format:fix)
melos.bat run test:contracts   # 경계 + 라벨 + 골든 — 07 §9 병합 검사의 스냅샷 명령
melos.bat run test             # 순수 Dart + Flutter 테스트 전부
```

**2026-09-08 실측 결과** — `analyze` 13패키지 경고 0 · `format` 189파일 변경 0 · `test:contracts` SUCCESS · `test` SUCCESS(`domain_contracts` 170 통과 · 34 skip · 0 실패).

이 패키지만 빠르게 보고 싶으면 `cd packages/domain_contracts && dart test` 도 된다(순수 Dart라 Flutter 없이 돈다).
