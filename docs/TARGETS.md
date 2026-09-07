# TARGETS — 타깃 × 패키지 의존 매트릭스

> **무엇**: `apps/` 3개 타깃이 각각 어떤 패키지를 싣는가. **여기 없는 것은 그 타깃에 컴파일되지 않습니다.**
> **왜 표로 두나**: 경계 규칙 ③(안전 화면·주문 코드의 빌드 제외)은 코드 리뷰가 아니라 **의존 목록**으로 강제됩니다(`11_앱설계/00_README_개발착수패키지.md` §5). 그 목록의 정본이 이 표입니다.
> **정본 우선순위**: 각 앱의 `pubspec.yaml`(실물) > 이 표 > 설명 문서. 표와 pubspec이 어긋나면 **pubspec이 이깁니다** — 같은 커밋에서 이 표를 고치십시오.

---

## 1. 매트릭스

기호: **●** 직접 의존(`pubspec.yaml`에 명시) · **○** 전이 의존(다른 패키지를 통해 들어옴) · **—** 없음(= 빌드 제외) · **⚠️** 조건부(아래 §3)

| 패키지 | 소유 | `app_operator_android` | `app_viewer_ios` | `app_viewer_web` ⚠️Q-D |
|---|---|:--:|:--:|:--:|
| `domain_contracts` | Claude (M2) | ○ | ○ | — |
| `core_engine` | Claude (M1·M3) | ○ | **—** | **—** |
| `broker_gateway` | Claude (M1) | ○ | **—** | **—** |
| `trading_runtime` | Claude (M1·X2) | ● | **—** | **—** |
| `data_sync` | Claude (M4·X1·X4·X5) | ● 읽기+쓰기 | ● **읽기 전용** | — |
| `ui_journal` | 다른 AI (M6) | ● | ● | — |
| `ui_analytics` | 다른 AI (M7) | ● | ● | — |
| `ui_shell` | 다른 AI (M8·X3) | ● | ● | — |
| `ui_settings` | 다른 AI (M9) | ● 전체 | ⚠️ 키 입력 화면 제외 | — |
| `ui_safety` | **Claude (M5·X1·X2·X5)** | ● 전체 | ⚠️ **킬스위치 «발동»만** | — |

- `app_viewer_web` 열이 전부 «—»인 것은 **스텁이기 때문**입니다. 발주자 결정 **Q-D**(v1에서 웹·데스크탑을 뺄 것인가, 00_README §8-2)가 「포함」으로 나면 **`app_viewer_ios` 열과 같은 집합**이 됩니다.
- `core_engine`·`broker_gateway`가 operator에서 «○»인 것은 `trading_runtime`을 통해 들어오기 때문입니다. **viewer에는 그 통로 자체가 없습니다.**
- `domain_contracts`가 «○»인 것은 앱 조립 코드가 아직 계약 타입을 직접 참조하지 않아서입니다. 리포지토리 주입을 시작하면 각 앱 pubspec에 직접 의존으로 올라갑니다(`depend_on_referenced_packages` 린트).

## 2. 이 표가 막는 사고

| 막는 것 | 어떻게 |
|---|---|
| 뷰어에서 주문이 나감 | `broker_gateway`가 viewer 의존 그래프에 없음 → import가 **컴파일 실패**. 리스(operator 1대 강제)가 무의미해지는 것을 막습니다 |
| 두 곳에서 계산해 두 숫자가 생김 | `core_engine`이 viewer에 없음. 그리고 `ui_*` 전체가 `core_engine`·`decimal`을 의존하지 못함(01 §1-1 · C-3) |
| 킬스위치가 뷰어에서 «쉽게 해제»됨 | 해제 경로는 operator 전용. 뷰어는 «발동»만 — 끄기는 쉽게, 켜기는 어렵게(결정 6) |
| 브로커 키가 뷰어 기기에 남음 | 키 입력·금고 경로가 viewer 타깃에 없음. 웹은 브라우저에 안전한 저장소가 없어 더 강한 제외 대상입니다 |

## 3. ⚠️ 아직 «규칙»이고 «빌드»가 아닌 것 — 2건

이 두 줄은 **패키지 의존 수준에서는 막히지 않습니다.** 숨기지 않고 여기 적어 둡니다.

| # | 항목 | 지금 상태 | 기계화하려면 |
|---|---|---|---|
| **T-1** | viewer의 `ui_safety` — 발동만, 해제 화면 제외 | 패키지 **전체**를 의존. "해제 화면을 라우팅에 넣지 않는다"는 규칙 | 🔴 **M5 요청**: 해제 화면을 전이 참조하지 않는 **발동 전용 진입점 라이브러리**(예: `package:ui_safety/kill_switch_trigger.dart`)를 내놓으면 viewer가 그것만 import해 진짜 빌드 제외가 됩니다 |
| **T-2** | viewer의 `ui_settings` — 키 입력 화면 제외 | 패키지 전체를 의존. 라우팅에서 제외하는 규칙 | 🔴 **M9 계약 요청**: 키 입력 위젯을 별도 라이브러리로 분리하거나, 최소한 «operator 전용 라우트» 목록을 계약에 명시. 서버 측 방어는 RLS가 이미 담당(01 §6-4) |

> T-1·T-2가 해소되기 전까지 이 두 항목은 **병합 검사(07 §9 ④)의 사람 판단 대상**입니다.

## 4. 검사 방법 (지금도 돕니다 — SDK 불필요)

```bash
# ① 의존 경계 — viewer 타깃에 엔진·브로커가 «선언»으로 섞였는가 (0건이어야 정상)
#    🔴 «선언 줄»만 봅니다(들여쓰기 + 이름 + 콜론). viewer pubspec의 머리 주석은
#       "이 세 패키지가 없는 것이 사양"이라고 **일부러** 이름을 적고 있어서,
#       주석까지 세는 정규식으로 보면 깨끗한 저장소에서도 매번 2건이 잡힙니다 —
#       고칠 수 없는 조건으로 점검을 실패시키지 않기 위해 이 형태로 씁니다.
rg -n '^\s+(core_engine|broker_gateway|trading_runtime)\s*:' apps/app_viewer_ios/pubspec.yaml apps/app_viewer_web/pubspec.yaml

# ② import 그래프 — 선언에는 없는데 코드가 부르는가 (0건이어야 정상)
rg -n "package:(core_engine|broker_gateway|trading_runtime|decimal)" apps/app_viewer_*/lib

# ③ ui_* 자체의 경계(C-3) — 저장소 루트 스크립트
melos run check:boundaries
```

## 5. 네이티브 폴더 현황

| 타깃 | 네이티브 폴더 | 생성 방법 |
|---|---|---|
| `app_operator_android` | `android/` **없음** | `flutter create --platforms=android …` — 각 앱 README §「네이티브 폴더」 |
| `app_viewer_ios` | `ios/` **없음** | `flutter create --platforms=ios …` (macOS + Xcode 필요) |
| `app_viewer_web` | `web/` **없음** | ⚠️ Q-D 확정 후에만 |

> ✅ **`--org`(applicationId·번들 ID 접두) = `com.billybeom.autoalphaquant`** — 발주자 확정(2026-09-06), 3개 타깃 공통 접두. 타깃별 최종 ID는 `접두.<project-name>`이며 서로 달라야 합니다(iOS 번들 ID는 밑줄 불가 → project-name 표기는 상세 설계에서 확정). 이제 SDK 설치 후 `flutter create --platforms`를 실행할 수 있습니다(임시 폴더에 생성해 플랫폼 폴더만 복사).
> ⚠️ `flutter create`는 기존 `pubspec.yaml`·`README.md`·`lib/main.dart`를 덮어쓸 수 있습니다. 임시 폴더에 만들어 플랫폼 폴더만 복사해 오십시오.

## 6. 이 표를 고쳐야 하는 때

- 앱 pubspec에 의존을 **추가·삭제**했을 때 → 같은 커밋에서 §1 표를 고칩니다.
- Q-D가 확정됐을 때 → `app_viewer_web` 열 전체.
- T-1·T-2가 기계화됐을 때 → §3에서 지우고 §1의 ⚠️를 ●/—로 바꿉니다.
- 새 타깃이 생겼을 때 → 열 추가. **열이 늘어나는 것은 결정 사항**입니다(임의 추가 금지).
