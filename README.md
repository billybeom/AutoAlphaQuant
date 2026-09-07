# AutoAlphaQuant

감정을 배제한 규칙 기반 자동투자 앱. **엔진은 Dart, 호스트는 Android 폰 1대**이고, iOS·웹은 읽기 전용 뷰어 + 킬스위치 「발동만」입니다.

- 원격: <https://github.com/billybeom/AutoAlphaQuant> (private · 기본 브랜치 `main`)
- 로컬: `C:/Work/Bob/AutoAlphaQuant`
- 이 저장소는 **앱 코드만** 둡니다. 전략·백테스트·결정 기록은 아래 §1의 다른 저장소에 있습니다.

> 🔴 **지금 상태**: 뼈대(스캐폴드)만 있습니다. 기능 코드는 한 줄도 없고, 이 PC에는 Flutter·Dart·melos가 **설치돼 있지 않아** 아직 한 번도 빌드해 보지 않았습니다. 설치와 첫 검증은 [`docs/SETUP.md`](docs/SETUP.md).

---

## §1. 저장소 3종 — 무엇을 어디에 두는가

역할이 다르므로 저장소를 나눴습니다. **어디에 커밋해야 하는지 헷갈리면 이 표를 봅니다.**

| # | 저장소 | 무엇이 들어가나 | 상태 |
|---|---|---|---|
| ① | **AlphaQuant** — <https://github.com/billybeom/AlphaQuant> (로컬 `C:/Work/클로드-백그라운드-작업/투자`) | **설계와 결정의 정본**. 전략 명세(`06_시스템설계/00_SPEC.md`)·백테스트·파일럿·앱 설계 문서(`11_앱설계/`)·청사진 스냅샷(`10_리뷰/`) | 운영 중 |
| ② | **AutoAlphaQuant** — 이 저장소 | **앱 코드만**. Flutter 모노레포(엔진·계약·화면). 설계 문서는 여기 두지 않고 ①을 가리킵니다 | 스캐폴드 |
| ③ | **아카이브 데이터** (이름·주소 미정, 아직 없음) | 실행 결과의 장기 보관 — 매매 기록·결정 로그·워치독 이력. 저장 3계층의 마지막 층(SQLite 정본 → Supabase 공유 → **GitHub private 아카이브**) | 🔴 미생성 (M4 착수 시) |

> 🔴 **③에 대해 지어내지 말 것**: 이름도 주소도 아직 정해지지 않았습니다. M4(동기화) 착수 시 발주자가 정합니다.

---

## §2. 구조

```
AutoAlphaQuant/
├─ melos.yaml                 워크스페이스·스크립트(analyze·test·format·build:gen·check:boundaries·golden:verify·test:contracts)
├─ pubspec.yaml               루트(도구 의존만 — 앱 코드 없음)
├─ analysis_options.yaml      전 패키지 공통 분석 규칙 (각 패키지·앱이 include 한 줄로 참조)
├─ CODEOWNERS                 소유 경계를 «파일 경로»로 못 박음
├─ tool/check_boundaries.sh   경계 규칙 기계 검사(C-3·C-5)
├─ .github/workflows/ci.yml   경계·골든·분석·테스트 게이트
├─ docs/SETUP.md              🔴 빌드 전제 — SDK 설치와 첫 검증 순서
├─ docs/DECISIONS.md          확정된 결정(D1 + 청사진 결정 1~9)과 그 근거 위치
├─ docs/TARGETS.md            타깃×패키지 의존 매트릭스 — «여기 없는 것은 컴파일되지 않는다»
│
├─ packages/
│  ├─ domain_contracts/       M2 — DTO·사유 문구 매핑·픽스처            [Claude]
│  ├─ core_engine/            M1·M3 — 신호·목표비중·한도·시뮬레이션      [Claude]
│  ├─ broker_gateway/         M1 — KIS 토큰·유량·멱등 주문               [Claude]
│  ├─ trading_runtime/        M1·X2 — FGS·정확 알람·잡 스케줄·재개       [Claude]
│  ├─ data_sync/              M4·X1·X4·X5 — Supabase·GitHub·키 금고      [Claude]
│  ├─ ui_safety/              M5·X1·X2 게이트·X5 정정 마법사             [Claude]
│  ├─ ui_journal/             M6 — 매매일지·보유현황                     [화면 담당 AI]
│  ├─ ui_analytics/           M7 — 성과·리밸런싱·플래너                  [화면 담당 AI]
│  ├─ ui_shell/               M8·X3 — 셸·운영 홈·알림·온보딩             [화면 담당 AI]
│  └─ ui_settings/            M9 — 설정·키·기기·연결                     [화면 담당 AI]
└─ apps/
   ├─ app_operator_android/   operator — 전 기능 + 엔진 + 키
   ├─ app_viewer_ios/         viewer + 저널 작성
   └─ app_viewer_web/         viewer(웹·데스크탑) ⚠️ Q-D 미결 — 지금은 스텁
```

### 경계 규칙 — 문서로 부탁하지 않고 빌드로 막습니다

| 규칙 | 무엇을 막나 | 어떻게 막나 |
|---|---|---|
| ① 계산·판정·**사유 문구**는 엔진 단일 소스 | 화면이 재계산해 엔진과 다른 숫자를 띄우는 사고 | `ui_*` pubspec에 `core_engine`·`decimal` 부재 → import가 컴파일 실패 · `tool/check_boundaries.sh` · 뷰모델 골든 |
| ② DB 쓰기 주체는 엔진 하나 | 앱이 DB에 직접 써서 멱등성·일일 대사가 무너지는 것 | `ui_*`에 DB·Supabase 의존 금지, 쓰기는 계약이 노출한 명령 API로만 |
| ③ 안전 화면은 「불편이 사양」 | 킬스위치 48h 대기·체크리스트가 「UX 개선」으로 침식되는 것 | M5·X1·X5 화면은 `ui_safety`(Claude 소유) + CODEOWNERS |

- `ui_*`는 **`domain_contracts` + Flutter + Riverpod만** 의존합니다.
- 정적 UI 라벨(「닫기」·「기간」)은 각 `ui_*`의 **`lib/l10n/labels.dart` 한 파일**에만 둡니다. 상태를 설명하는 문장은 전부 엔진이 만듭니다.
- 근거 조문: `11_앱설계/01_M2_도메인계약_초안.md` §1-1·§1-5·§7, `00_README_개발착수패키지.md` §5.

---

## §3. 착수 게이트 G1~G4 — 지금 어디까지 왔나

「다른 AI에게 첫 화면 과제를 줄 수 있는가」의 조건 4개입니다(`11_앱설계/00_README` §0-1).

| # | 무엇 | 상태 | 확인 방법 |
|---|---|---|---|
| **G1** | 저장소 위치 결정 | ✅ **확정 2026-09-06 (D1)** — 신규 전용 저장소 `AutoAlphaQuant` | `docs/DECISIONS.md` D1 |
| **G2** | 저장소 실물 (melos 뼈대 + 빈 패키지 + CI) | 🟡 **파일은 생성됨 / 동작은 미검증** | 이 트리가 보이면 파일은 있는 것. **`melos bootstrap`이 실제로 도는지는 SDK 설치 후** 확인 — `docs/SETUP.md` §4 |
| **G3** | M2 계약 확정 | ⬜ 예정 | ①의 `11_앱설계/01_M2_도메인계약_초안.md`에서 `_초안`이 빠지고 「상태: 확정 v1.0」 줄이 생김 |
| **G4** | 픽스처 실물 (연습 데이터 JSON 10개) | ⬜ 예정 | `packages/domain_contracts/fixtures/`에 JSON 10개가 실제로 있음 |

> 🔴 **G3·G4 전에 화면 과제를 주지 않습니다.** 계약이 없으면 그 AI는 테이블을 상상해서 쿼리하고 사유 문구를 지어냅니다. 지어낸 값은 코드와 스크린샷에 남아 되돌리기 어렵습니다.
> 🟡 **G2가 「파일은 있으나 도는지는 미확인」인 이유**: 스캐폴드를 만든 PC에 Flutter SDK가 없어 `melos bootstrap`·`flutter analyze`를 한 번도 돌리지 못했습니다. 버전 제약은 범위로 두고 `⚠️` 주석을 달아 뒀으니, SDK 설치 후 첫 부트스트랩에서 좁히십시오.

---

## §4. 설계 정본은 여기가 아닙니다

이 저장소에는 **결정의 사본**만 둡니다(`docs/DECISIONS.md`). 충돌하면 아래가 이깁니다.

| 순위 | 정본 | 위치 (AlphaQuant 저장소 기준) |
|---|---|---|
| 1 | **앱 청사진 v1.14** — 모듈 M1~M9·횡단 X1~X5·결정 1~9 | `10_리뷰/2026-09-01_앱청사진_v1.14_스냅샷.html` |
| 2 | **개발 착수 패키지 8부** — 계약·화면 명세·작업 목록·배포 프롬프트 | `11_앱설계/00_README_개발착수패키지.md` 외 7부 |
| 3 | **전략·엔진 규칙** — FR/NFR·절대 규칙·슬리브 배분 | `06_시스템설계/00_SPEC.md` (**v2.31 P0S**) |

- 전략 정본 요약: 슬리브 **A 20% / B 42% / 잔여 C**, 새틀라이트는 **0%·비활성 보존**. 1차 자동화는 **국내상장 ETF만**.
- 화면 담당 AI에게는 청사진 HTML도, 엔진 명세도 주지 않습니다 — 컨텍스트 낭비이자 재계산 유혹입니다(주는 문서는 정확히 4부, `11_앱설계/00_README` §1).

---

## §5. 자주 쓰는 명령

먼저 [`docs/SETUP.md`](docs/SETUP.md)로 SDK를 설치해야 합니다.

```bash
melos bootstrap              # 의존 해결 + 패키지 링크 (clone 직후 1회)
melos run build:gen          # freezed·json_serializable 생성 코드 (생성물은 커밋하지 않음)
melos run analyze            # 정적 분석 — 경고 0이 병합 조건
melos run test               # 전 패키지 테스트
melos run check:boundaries   # 경계 규칙 검사 (SDK 없이도 돎)
melos run golden:verify      # 골든 스냅샷 비교
```

> 🔴 **골든 스냅샷이 깨졌다고 다시 찍지 마십시오.** 표시 계약이 바뀌었다는 신호입니다. 의도적으로 바꿨다면 PR에 라벨 `golden:approved`를 붙이고 무엇이 왜 바뀌었는지 본문에 적습니다(CI가 그 라벨 없이는 통과시키지 않습니다).
> 🔴 **어떤 AI에게도 실제 API 키·계좌번호·비밀번호를 주지 않습니다.** 연습 데이터(픽스처)로만 개발하고, 실키는 완성된 설정 화면에서 발주자가 직접 입력합니다.

---

## §6. 라이선스·공개 범위

private 저장소이며 공개 배포 계획이 없습니다. 사용자 1인·리밸런싱 월 1회급 규모입니다 — **확장성보다 「틀렸을 때 조용히 틀리지 않는 것」이 우선**입니다.
