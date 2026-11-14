# TARGETS — 타깃 × 패키지 의존 매트릭스

> **무엇**: `apps/` 3개 타깃이 각각 어떤 패키지를 싣는가. **여기 없는 것은 그 타깃에 컴파일되지 않습니다.**
> **왜 표로 두나**: 경계 규칙 ③(안전 화면·주문 코드의 빌드 제외)은 코드 리뷰가 아니라 **의존 목록**으로 강제됩니다(`11_앱설계/00_README_개발착수패키지.md` §5). 그 목록의 정본이 이 표입니다.
> **정본 우선순위**: 각 앱의 `pubspec.yaml`(실물) > 이 표 > 설명 문서. 표와 pubspec이 어긋나면 **pubspec이 이깁니다** — 같은 커밋에서 이 표를 고치십시오.

---

## 1. 매트릭스

기호: **●** 직접 의존(`pubspec.yaml`에 명시) · **○** 전이 의존(다른 패키지를 통해 들어옴) · **—** 없음(= 빌드 제외) · **⚠️** 조건부(아래 §3)

| 패키지 | 소유 | `app_operator_android` | `app_viewer_ios` | `app_viewer_web` ⚠️Q-D |
|---|---|:--:|:--:|:--:|
| `domain_contracts` | Claude (M2) | ● 🆕 E11p2(조립 · 시험이 계약 타입을 직접 쓴다 — 전에는 ○) | ○ | — |
| `core_engine` | Claude (M1·M3) | ● 🆕 E11p(플랫폼 어댑터가 core 포트를 구현 — 전에는 ○) | **—** | **—** |
| `broker_gateway` | Claude (M1) | ○ | **—** | **—** |
| `trading_runtime` | Claude (M1·X2) | ● | **—** | **—** |
| `data_sync` | Claude (M4·X1·X4·X5) | ● 읽기+쓰기 | **—** 🆕 operator 전용(설계 13 §8 R53 · 지도 D1) | — |
| 🆕 `read_model_client` | Claude (M4-7·M4-8) | — | ● **읽기 전용**(읽기 모델 · 버전 게이트 · 뒤에 명령 INSERT 4종) | — |
| `ui_journal` | 다른 AI (M6) | ● | ⚠️ **`J-3` 사전 저널 폼 제외**(T-3) · 🆕 v1.2 `J-3R` 읽기 뷰(`JournalReadView`)는 **포함** · 🆕 v1.7 `J-4` blind 리뷰(`JournalBlindReview` · **배럴 쪽** — 명령 주입 `journalBlindReviewCommandApiProvider` 는 `blind_review.dart` 안 · 뷰어 허용 4종의 `BLIND_REVIEW_SCORE` · 01 §16)는 **포함** · 🆕 v1.8 보유현황 `H6-1`~`H6-3`(`HoldingsOverview`·`HoldingDetail`·`HoldingsAllocation` · **배럴 쪽** · 01 §17)은 **포함**(본문 = Android·iOS · 뷰어 = 종목 손익 토글·시스템 밖 섹션 부재 — K15·K14 ⓑ · 엔진 데이터) | — |
| `ui_analytics` | 다른 AI (M7) | ● | ⚠️ **`S7-4` 입금 플래너 제외**(T-4 · 🆕 v1.4) · 🆕 `S7-6c` 초안 = 주입 null(T-4 · v1.6) | — |
| `ui_shell` | 다른 AI (M8·X3) | ● | ● | — |
| `ui_settings` | 다른 AI (M9) | ● 전체 | ⚠️ 키 입력 화면 제외 | — |
| `ui_safety` | **Claude (M5·X1·X2·X5)** | ● 전체 | ⚠️ **킬스위치 «발동»만** | — |

- 🆕 v1.8 — 보유 화면 셋(`H6-*`)은 `ui_journal` 안이라 웹 타깃에는 없다: 셸은 라우트 3(`holdingsOverview`·`holdingsDetail`·`holdingsAllocation`)을 전 플랫폼 등록하되 웹 목적지 = Q-D 전 «부재» 가드(`journalRead` 조문과 같은 꼴 · 04 §1-2 · R13).
- `app_viewer_web` 열이 전부 «—»인 것은 **스텁이기 때문**입니다. 발주자 결정 **Q-D**(v1에서 웹·데스크탑을 뺄 것인가, 00_README §8-2)가 「포함」으로 나면 **`app_viewer_ios` 열과 같은 집합**이 됩니다.
- `broker_gateway`가 operator에서 «○»인 것은 `trading_runtime`을 통해 들어오기 때문입니다(`core_engine` 도 그랬다가 🆕 E11p 에서 «●» — `lib/platform/` 어댑터가 `SecretVault`·`SealedBox` 포트를 직접 구현한다 · 빌드 내용은 같다). **viewer에는 그 통로 자체가 없습니다.**
  - 🆕 2026-11-04 정정(설계 13 §8 R53) — 이 문장은 **그동안 거짓이었다**: viewer 가 의존하던 `data_sync` 가 `core_engine` 을 의존해 전이로 들어왔다(지도 X1). viewer 는 이제 `read_model_client`(의존 = `domain_contracts` 만)로만 읽고, `tool/check_boundaries.sh` [8] 이 viewer 의 **전이 의존 그래프**에 `core_engine` · `broker_gateway` · `trading_runtime` · `data_sync` · `sqlite3` 가 없는지 본다.
- `domain_contracts`가 «○»인 것은 앱 조립 코드가 아직 계약 타입을 직접 참조하지 않아서입니다. 리포지토리 주입을 시작하면 각 앱 pubspec에 직접 의존으로 올라갑니다(`depend_on_referenced_packages` 린트). 🆕 operator 는 E11p2 에서 올라갔다(●).
- 🆕 E11p3a — operator 조립(`lib/engine/`)이 원장 연결(`sqlite3` `Database`)과 healthchecks 어댑터의 `http.Client` 를 직접 다룬다 → 외부 패키지 `sqlite3` · `http` 를 직접 의존으로 올렸다(`data_sync` 와 같은 범위 · 빌드 내용은 같다 — 전에도 `data_sync` 를 거쳐 들어와 있었다). viewer 의 전이 그래프에 `sqlite3` 가 없다는 [8] 검사는 그대로다.

## 2. 이 표가 막는 사고

| 막는 것 | 어떻게 |
|---|---|
| 뷰어에서 주문이 나감 | `broker_gateway`가 viewer 의존 그래프에 없음 → import가 **컴파일 실패**. 리스(operator 1대 강제)가 무의미해지는 것을 막습니다 |
| 두 곳에서 계산해 두 숫자가 생김 | `core_engine`이 viewer에 없음. 그리고 `ui_*` 전체가 `core_engine`·`decimal`을 의존하지 못함(01 §1-1 · C-3) |
| 킬스위치가 뷰어에서 «쉽게 해제»됨 | 해제 경로는 operator 전용. 뷰어는 «발동»만 — 끄기는 쉽게, 켜기는 어렵게(결정 6) |
| 브로커 키가 뷰어 기기에 남음 | 키 입력·금고 경로가 viewer 타깃에 없음. 웹은 브라우저에 안전한 저장소가 없어 더 강한 제외 대상입니다 |

## 3. ⚠️ 아직 «규칙»이고 «빌드»가 아닌 것 — 4건

이 네 줄은 **패키지 의존 수준에서는 막히지 않습니다.** 숨기지 않고 여기 적어 둡니다.

| # | 항목 | 지금 상태 | 기계화하려면 |
|---|---|---|---|
| **T-1** | viewer의 `ui_safety` — 발동만, 해제 화면 제외 | 패키지 **전체**를 의존. "해제 화면을 라우팅에 넣지 않는다"는 규칙 | 🔴 **M5 요청**: 해제 화면을 전이 참조하지 않는 **발동 전용 진입점 라이브러리**(예: `package:ui_safety/kill_switch_trigger.dart`)를 내놓으면 viewer가 그것만 import해 진짜 빌드 제외가 됩니다 |
| **T-2** | viewer의 `ui_settings` — 키 입력 화면 제외 | 패키지 전체를 의존. 라우팅에서 제외하는 규칙 | 🔴 **M9 계약 요청**: 키 입력 위젯을 별도 라이브러리로 분리하거나, 최소한 «operator 전용 라우트» 목록을 계약에 명시. 서버 측 방어는 RLS가 이미 담당(01 §6-4) |
| **T-3** 🆕 | viewer(iOS)의 `ui_journal` — `J-3` 사전 저널 폼 제외(결정 9b «폰 전용») | 패키지 전체를 의존. ✅ 모양은 정했다(2026-09-23 · R2 준비): `J-3` 은 **배럴 밖** 라이브러리 `package:ui_journal/journal_draft.dart` 에 두고(`CommandApi` 주입 `journalCommandApiProvider` 도 그 안 · 🆕 v1.2 초안 포트 주입 `journalDraftStoreProvider` 도 그 안 — C-35 ⑥ 이 기계 검사) **operator 앱만 import** 한다 — iOS 는 배럴 `package:ui_journal/ui_journal.dart` 만 쓴다(T-1 이 `ui_safety` 에 요구한 모양과 같다). 웹은 `ui_journal` 자체가 없다 · 🆕 **계약 v1.12(01 §21 · K10 ⓐ · ⬜ 로컬 커밋 — PR 대기)** — X7 폼 3(`A-3` `ManualFillForm` · `A-4` `AdviceSkipForm` · `L-3` `SelfReportForm`)도 **같은 `journal_draft.dart`** 에 더한다(경로·C-35 ⑥ 무변경 · 주입 `journalCommandApiProvider`·`journalDraftStoreProvider` 재사용 · 🆕 `journalSettingsActionsProvider` 는 `self_report_form.dart` 안) · 만료 확인 카드 「내일 다시」의 명령 주입 `journalAdviceCommandApiProvider` 는 **배럴 쪽** `advice_inbox.dart`(선례 `journalBlindReviewCommandApiProvider` · 뷰어 = `deferAvailable` false 라 읽히지 않는다) · iOS 셸 = `adviceFill`·`adviceSkip`·`ledgerSelfReport`·`ledgerRepairs` «폰에서만» 부재 안내 | 🔴 조립 앱 배선 때 `tool/check_boundaries.sh` 에 [6] «`apps/app_viewer_ios/lib` 에 `package:ui_journal/journal_draft.dart` import 0건» 을 더한다(M2/infra) |
| **T-4** 🆕 | viewer의 `ui_analytics` — `S7-4` 입금 플래너 제외(계약 v1.4 · 01 §14-1 · `DEPOSIT_REGISTER` = operator 전용 · 뷰어 미리보기는 v1 제외 · 01 §8 미결 73) | 패키지 전체를 의존. 모양은 T-3 과 같다: `S7-4` 는 **배럴 밖** 라이브러리 `package:ui_analytics/planner.dart`(+ `lib/src/planner/**` · 주입 프로바이더 `plannerWhatIfApiProvider`·`plannerConfigRepositoryProvider`·`plannerCommandApiProvider` 도 그 안 — R11a 가 만든다)에 두고 **operator 앱만 import** 한다. viewer 셸은 `AppRoutes.planDeposit` 을 등록하되 목적지 = «폰에서만 쓸 수 있습니다» 부재 안내(셸 몫 · R13 · 미결 62 · 선례 = J-3 `journalDraft` 의 iOS 셸 가드). 🆕 **v1.6(01 §15-4 · K2 권고 선반영)** — `S7-6c` 초안 = **주입 null(뷰어)**: `S7-6c` 는 배럴 안 화면이라 viewer 에도 실리지만 «지금 기준 초안» 버튼·영역은 `analyticsWhatIfApiProvider = Provider<WhatIfApi?>`(배럴 쪽 `analytics_providers.dart` · R12b 가 만든다 · 기본값 throw)가 null 이면 부재다 — operator 셸 = 실구현(플래너와 같은 인스턴스) · viewer 셸 = `(_) => null`(viewer 에는 `core_engine` 이 없어 주입할 `WhatIfApi` 가 없다 · 뷰어 초안을 되살리는 길 = 엔진 발행 읽기 모델 · 미결 73) | ✅ **이미 기계 검사가 돈다**(v1.4): `tool/check_boundaries.sh` **[7]**(`apps/app_viewer_*/lib` 에 `package:ui_analytics/planner.dart` import 0건) + 계약 테스트 **C-35 ⑥ 확장**(`ui_analytics/lib` 안에서 planner 밖 파일이 planner 를 import·export 0 · viewer 앱 import 0). 빌드 제외(별도 패키지 분리)는 아니므로 이 표에 남긴다. 🆕 v1.6 `S7-6c` 쪽은 화면이 고르는 조건 = «주입 null 여부» 하나(`kIsWeb`·`Platform`·planner import 0 — C-42 ⑤ · C-35 ⑥) · viewer 셸의 null override 는 R13 배선 몫(빠뜨리면 기본값 throw = 에러 화면 — 조용한 실패는 아니다) |

> T-1~T-4가 해소되기 전까지 이 네 항목은 **병합 검사(07 §9 ④)의 사람 판단 대상**입니다(T-4 는 [7]·C-35 ⑥ 이 먼저 거른다).

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

# ③ ui_* 자체의 경계(C-3) — 저장소 루트 스크립트 · 🆕 v1.4 [7] viewer 앱의 planner import 0(T-4)
melos run check:boundaries
```

## 5. 네이티브 폴더 현황

| 타깃 | 네이티브 폴더 | 생성 방법 |
|---|---|---|
| `app_operator_android` | ✅ `android/` — 🆕 E11p1 에서 생성(PR #152 · Flutter 3.47.4 템플릿 · id `com.billybeom.autoalphaquant.operator`) | 앱 README §4 「네이티브 폴더」 |
| `app_viewer_ios` | `ios/` **없음** | `flutter create --platforms=ios …` (macOS + Xcode 필요) |
| `app_viewer_web` | `web/` **없음** | ⚠️ Q-D 확정 후에만 |

> ✅ **`--org`(applicationId·번들 ID 접두) = `com.billybeom.autoalphaquant`** — 발주자 확정(2026-09-06), 3개 타깃 공통 접두. 타깃별 최종 ID는 `접두.<project-name>`이며 서로 달라야 합니다(iOS 번들 ID는 밑줄 불가 → project-name 표기는 상세 설계에서 확정). 이제 SDK 설치 후 `flutter create --platforms`를 실행할 수 있습니다(임시 폴더에 생성해 플랫폼 폴더만 복사).
> ⚠️ `flutter create`는 기존 `pubspec.yaml`·`README.md`·`lib/main.dart`를 덮어쓸 수 있습니다. 임시 폴더에 만들어 플랫폼 폴더만 복사해 오십시오.

## 6. 이 표를 고쳐야 하는 때

- 앱 pubspec에 의존을 **추가·삭제**했을 때 → 같은 커밋에서 §1 표를 고칩니다.
- Q-D가 확정됐을 때 → `app_viewer_web` 열 전체.
- T-1~T-4가 기계화됐을 때 → §3에서 지우고 §1의 ⚠️를 ●/—로 바꿉니다.
- 새 타깃이 생겼을 때 → 열 추가. **열이 늘어나는 것은 결정 사항**입니다(임의 추가 금지).
