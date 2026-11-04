# app_viewer_ios — viewer 타깃 (iOS)

> **한 줄**: **읽기 전용** 조회 앱입니다. 엔진도 주문도 브로커 키도 이 앱에 없습니다. 예외는 딱 둘 — 저널 작성과 **킬스위치 «발동»**.
> **정본**: 청사진 §7 결정 1·2·6 · `00_README_개발착수패키지.md` §4·§5 · `01_M2_도메인계약_초안.md` §1-3·§2-10·§6-4.

---

## 1. 역할

| 항목 | 내용 |
|---|---|
| 타깃 역할 | viewer — 조회 + 저널 작성 + 킬스위치 발동 |
| 플랫폼 | iOS(아이폰·아이패드). 여러 대 설치 가능 — 리스는 operator 1대만 잡습니다 |
| 할 수 없는 일 | 엔진 실행 · 주문 · 브로커 키 입력·보관 · 킬스위치 **해제** · 원장 직접 쓰기 |
| 데이터 출처 | Supabase 읽기 모델(미러). 로컬 SQLite 정본은 operator 폰에만 있습니다 |

## 2. 빌드 제외 규칙 — 이 타깃에 **컴파일되지 않는 것**

경계 규칙 ③(00_README §5)은 리뷰가 아니라 **의존 목록**으로 강제됩니다. 아래는 `pubspec.yaml`에 없으므로 이 앱에서 import하면 빌드가 깨집니다.

| 제외 대상 | 어디 있나 | 왜 |
|---|---|---|
| 주문·브로커 호출 | `broker_gateway` (전이 경로 없음) | 뷰어에서 주문이 나가면 리스(1대 강제)가 무의미해집니다 |
| 🆕 원장 쓰기 · 키 금고 · 로컬 SQLite | `data_sync`(🆕 operator 전용 · 설계 13 §8 R53) | 읽기는 `read_model_client` 로만 — `data_sync` 를 두면 `core_engine` 까지 전이로 들어왔다(지도 X1). 🔴 `tool/check_boundaries.sh` [8] 이 **전이 의존 그래프**를 본다 |
| 엔진 판정·계산 | `core_engine` | 두 곳에서 계산하면 두 숫자가 생깁니다(경계 규칙 ①) |
| FGS·정확 알람·잡 스케줄 | `trading_runtime` | iOS는 애초에 이런 상시 실행을 허용하지 않습니다(§3) |
| 브로커 키 입력 위젯 | `ui_settings`의 키 화면 | ⚠️ 패키지는 의존하되 **키 입력 화면은 라우팅에 넣지 않습니다** — §4 계약 요청 참조 |
| 킬스위치 **해제** 화면 | `ui_safety`의 해제 마법사 | 해제는 48h 대기 + 체크리스트 7항 + 저널. operator에서만 |

> 🔴 「넣지 않기로 했다」와 「컴파일되지 않는다」는 다릅니다. 지금 완전히 기계적인 것은 위 4줄(패키지 부재 — 직접이든 전이든)이고, 아래 2줄(`ui_settings`·`ui_safety` 내부 화면)은 **§4의 계약 요청이 반영되기 전까지 규칙 수준**입니다. 이 차이를 README에 남겨 둡니다 — 숨기면 나중에 "막혀 있는 줄 알았다"가 됩니다.

## 3. iOS 플랫폼 제약

| 제약 | 내용 | 결과 |
|---|---|---|
| 백그라운드 실행 없음 | iOS는 Android FGS에 해당하는 상시 실행을 주지 않습니다 | **엔진을 iOS에 올릴 수 없습니다**(결정 1의 실질 근거). viewer 역할이 선택이 아니라 제약입니다 |
| 푸시 | P0 알림은 서버 푸시로 받습니다. 앱이 꺼져 있어도 도착해야 합니다 | ⚠️ APNs 인증서·번들 ID는 발주자 계정 작업(§5) |
| 배포 | 개인 배포는 TestFlight 또는 개발자 서명(7일) | ⚠️ 미결 — v1 배포 경로는 결정되지 않았습니다 |
| 시계 | 🔴 기기 시계를 믿지 않습니다. 마찰 카운트다운의 신뢰 시각은 Supabase 서버 시각(01 §1-3) | 화면은 `SafetyState.releaseProgress`를 **그대로 표시**합니다 |

## 4. ⚠️ 계약 요청 2건 (M5·M4 소유 — 이 앱이 임의로 정하지 않음)

1. **`ui_safety` 발동 전용 진입점** — 지금 viewer는 `ui_safety` 패키지 전체를 의존합니다. 발동만 쓰고 해제 화면은 안 쓴다는 것이 «규칙»으로만 있고 «빌드»로는 없습니다. `package:ui_safety/kill_switch_trigger.dart`처럼 **해제 화면을 전이 참조하지 않는 별도 라이브러리**를 M5가 내놓으면, viewer가 그것만 import해 진짜 빌드 제외가 됩니다. → M5에 요청.
2. ~~**`data_sync` 읽기 전용 표면**~~ ✅ **해소(2026-11-04 · 설계 13 §8 R53 · 지도 D1 발주자 결정)** — viewer 전용 읽기 패키지 `packages/read_model_client` 를 새로 두고 viewer `pubspec` 에서 `data_sync` 를 뺐습니다(`data_sync` = operator 전용). 지금 그 패키지에는 스키마 버전 게이트(M4-8)만 있고, Supabase 읽기 · 명령 INSERT 4종은 E11l2 · E11m 에서 들어옵니다. RLS 로 서버에서 한 번 더 막는 것(01 §6-4)은 그대로입니다.

## 5. 네이티브 폴더는 아직 없습니다

`ios/` 폴더를 일부러 만들지 않았습니다(SDK 부재 — 손으로 쓴 Xcode 프로젝트는 버전과 어긋납니다). SDK 설치 후:

```bash
cd apps/app_viewer_ios

# ⚠️ 기존 pubspec.yaml·README.md·lib/main.dart를 덮어쓸 수 있습니다.
#    임시 폴더에 만들어 ios/ 만 복사해 오는 편이 안전합니다.
# ⚠️ macOS + Xcode가 있어야 합니다. Windows에서는 생성만 되고 빌드는 안 됩니다.
flutter create --platforms=ios --project-name=app_viewer_ios --org=com.billybeom.autoalphaquant .
```

- ✅ `--org` = **`com.billybeom.autoalphaquant`** (발주자 확정 2026-09-06, operator 타깃과 같은 접두). 번들 ID는 `com.billybeom.autoalphaquant.<project-name>` — iOS는 밑줄 불가이므로 `--project-name`을 `viewer`처럼 밑줄 없는 이름으로(상세 설계에서 확정). 네이티브 폴더는 임시 폴더에 만들어 플랫폼 폴더만 복사하십시오.
- `android/`·`web/`는 이 타깃에 만들지 않습니다.

## 6. 금지

viewer에도 금지 4항(00_README §6)이 그대로 적용되고, 여기에 **한 줄이 더 붙습니다**: 🔴 **엔진·주문·키 관련 패키지를 `pubspec.yaml`에 추가하지 마십시오.** 그 한 줄이 이 타깃의 안전 근거 전부입니다.
