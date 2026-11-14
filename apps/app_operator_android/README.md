# app_operator_android — operator 타깃

> **한 줄**: 엔진을 돌리고 **실제 주문을 내는 단 하나의 타깃**입니다. Android 폰 1대에만 설치합니다.
> **정본**: 청사진 §7 결정 1·2·6 · `11_앱설계/00_README_개발착수패키지.md` §4·§5 · `01_M2_도메인계약_초안.md` §1-1.

---

## 1. 역할

| 항목 | 내용 |
|---|---|
| 타깃 역할 | operator — 전 기능(엔진 실행·주문·브로커 키·안전 화면 전부) |
| 플랫폼 | Android 폰 **1대**. 태블릿·에뮬레이터는 개발용으로만 |
| 동시 가동 대수 | **1대**(`operator_lease` 단일 행이 강제 — 00_README §7 「리스」). 두 대에 설치하면 늦게 갱신한 쪽이 스스로 봉인됩니다 |
| 실행 모드 | 골든벡터 전량 통과 전까지 **DRY_RUN 이탈 금지**(결정 2) |

## 2. 이 타깃만 갖는 것 — 왜 viewer와 나누는가

`trading_runtime`(→ 전이로 `core_engine`·`broker_gateway`)과 `data_sync` **쓰기 경로**는 이 앱의 `pubspec.yaml`에만 있습니다.
경계 규칙 ③은 문서로 부탁하지 않고 **빌드로 막습니다**(00_README §5): viewer 타깃의 의존 목록에 브로커·주문 패키지가 없으므로, viewer에서 주문 코드를 부르려 해도 **import 자체가 컴파일 실패**입니다. 코드 리뷰로 대체할 수 없는 이유가 이것입니다.

| 패키지 | operator | viewer | 이유 |
|---|---|---|---|
| `trading_runtime` · (전이) `core_engine` · `broker_gateway` | ✅ | ❌ | 주문·브로커 키·엔진 판정 |
| `ui_settings` | ✅ 전체 | ⚠️ 읽기 화면만 | 키 입력 위젯은 operator 전용 |
| `ui_safety` | ✅ 전체 | ⚠️ **킬스위치 발동 진입점만** | 해제(48h·체크리스트 7항)는 operator에서만 |
| `data_sync` | ✅ 읽기+쓰기 | ⚠️ 읽기 전용 | 명령 큐 append는 viewer도 가능하나 원장 쓰기는 엔진 하나(경계 규칙 ②) |

> 타깃×패키지 전체 매트릭스는 [`docs/TARGETS.md`](../../docs/TARGETS.md).

## 3. Android 플랫폼 제약 — 착수 전에 알아 둘 것

🆕 **E11p2(2026-11-14)** — FGS · 정확 알람 · 부팅 · 알림 채널은 이 앱의 Kotlin 얇은 어댑터(`android/…/operator/ops/`)가 맡습니다(설계 13 · e11p-map P6~P12 · D20). 계산(잡 표 · 다음 회차 · 놓친 발화 · 알림 문구)은 `trading_runtime` 순수 몫 그대로이고, Kotlin 은 판정 · 문구 0 입니다.

| 자리 | 값 |
|---|---|
| FGS | `EngineService` · 타입 **`specialUse`**(dataSync 는 Android 15 에서 24h 중 6h 한도 + 부팅 시작 금지) · 🔴 FlutterEngine 을 **소유**(`EngineHost` — 화면은 그 엔진에 붙는다 · Dart isolate 1 = 원장 단일 쓰기) |
| 정확 알람 | `USE_EXACT_ALARM`(33+) + `SCHEDULE_EXACT_ALARM ≤32` · Dart 가 잡마다 `nextOccurrence` 1개를 통째로 넘김 · `setExactAndAllowWhileIdle` |
| 부팅 | `BOOT_COMPLETED` · `MY_PACKAGE_REPLACED` · `TIME_SET` · `TIMEZONE_CHANGED` → FGS → Dart 재무장 |
| 알림 채널 | `ops_status`(LOW · 무음) · `ops_p0`(HIGH · 방해금지 관통 요청 — 실제 값은 자가진단) · 본문 = 엔진 `FgsNotice` 그대로 |
| 실측 | Kotlin 이 깨어날 때마다 `files/aaq_wake_log.jsonl` 에 먼저 적는다 · `tool/measure_survival.sh`(FGS 5분 · 정확 알람 · Doze 흉내) · debug 빌드 전용 `ProbeReceiver` |

🆕 **E11p3a(2026-11-14)** — 엔진 조립 뼈대(`lib/engine/` · 설계 e11p-map §3 Q0~Q10). 깨어날 때마다:

| 차례 | 하는 일 | 판정 주인 |
|---|---|---|
| ① 원장 | 처음 깨어날 때 한 번 — `noBackupFilesDir/engine/`(Kotlin `paths`) 에 sim 파일을 열고 live 파일은 **있을 때만** 연다 | 조립 |
| ② 기동 판정 | 모드 해석 → 온보딩 미완 = 잡 0 → 반쯤 끝난 커밋 복구 → 운영 방식 → 기동 판정(거부 = 잡 0) — **깨어날 때마다 다시** | data_sync `bootModeOf` · `repairHalfCommit` · core `modeStartupGate` |
| ③ 회차 판정 | 지금 − 14일 ~ 지금 · 이미 돈 회차 = `job_run` 의 SUCCESS · LATE · HOLIDAY(기준점 저장 0) · runNow 만 예정 차례대로 | trading_runtime `wakeDecisions` |
| ④ 실행 | 잡 표 9칸 · `runJob` 감싸기(체크 이름 2축 · 시장 달력 · 🔴 세션일 · 마감 = 회차 값) | trading_runtime `runJob` |

- 🔵 지금은 아홉 칸 **전부 미조립** — 돌면 본체가 곧바로 `UNASSEMBLED <잡>: <부품>` 으로 실패해 `job_run` FAILED + fail 핑이 남는다(조용히 건너뛰지 않는다). 빈 부품(운영 설정 · 시세 · 한도 · 브로커 · FGS 상태 함수)은 **E11p3b**(packages) · 실물 조립은 **E11p3c**.
- 🔵 온보딩 전 기기(폰 실측 D22 포함)는 ② 에서 멈추므로 잡 · 핑 · 기록 0건이다.
- 🔵 live 는 설정 승인 원천(E11p3b) 전까지 SAF-405 로 기동 거부된다(안전한 빈 입력).

아래 표는 처음 적어 둔 제약입니다(그대로 유효).

| 제약 | 내용 | 언제 문제가 되나 |
|---|---|---|
| **Foreground Service** | 엔진 배치가 도즈(Doze)에 먹히지 않게 FGS로 돕니다. Android 14+는 `foregroundServiceType` 선언과 사용자 고지가 필수 | 상시 알림이 뜨는 것은 **사양**입니다. 없애 달라는 요구는 거절이 기본값 |
| **정확 알람** | 배치 시각 정확도를 위해 `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` 계열 권한 | Android 13+에서 사용자 승인이 필요하고, 거부되면 배치가 밀립니다 → 워치독이 감지 |
| **배터리 최적화 예외** | 제조사 커스텀 도즈(삼성 등)에서 잡이 조용히 스킵됨 | 온보딩(X3) 단계에 「배터리 최적화 제외」 확인이 들어갑니다 |
| **백그라운드 네트워크** | 데이터 세이버·절전 모드에서 브로커 호출 차단 가능 | 대사(reconciliation) 실패로 나타납니다 |
| **시계** | 🔴 폰 시계는 신뢰 대상이 아닙니다. 마찰 카운트다운의 신뢰 시각은 **Supabase 서버 시각**(01 §1-3) | 리스 TTL·킬스위치 48h·냉각 30일 |

## 4. 네이티브 폴더 — 🆕 E11p1 에서 생성(2026-11-14)

`android/` 는 Flutter 3.47.4 템플릿(AGP 9.1 · Kotlin 2.4 · Gradle 9.3.1)을 임시 폴더에 만들어 **플랫폼 폴더만** 옮겨 왔습니다(설계 13 · e11p-map P1).

| 항목 | 값 |
|---|---|
| `applicationId` · `namespace` | **`com.billybeom.autoalphaquant.operator`**(`--org` = 발주자 확정 2026-09-06 · 접미 `operator` = P1 — Dart 패키지 이름 `app_operator_android` 는 그대로) |
| Kotlin 자리 | `android/app/src/main/kotlin/com/billybeom/autoalphaquant/operator/` — `MainActivity`(채널 등록만) · `OperatorChannels` · `security/`(AES-GCM 봉투 · Keystore 키 · DEK 봉함 · 금고) |
| Dart 어댑터 | `lib/platform/` — `AndroidSecretVault`(core `SecretVault`) · `AndroidSealedBox`(core `SealedBox`) · 채널 이름 · 오류 코드 |
| 백업 | 🔴 `allowBackup=false` · `fullBackupContent=false` · `dataExtractionRules`(클라우드 · 기기 간 이전 전 도메인 제외) · 비밀 파일 = `noBackupFilesDir`(06 M4-9 ⑤) |
| 시험 | `test/platform/` = 채널 계약 · Kotlin 글자 대조 · 매니페스트(CI) · `integration_test/` = 실 Keystore(에뮬레이터 · 폰 · 로컬만) |

- ✅ FGS · 정확 알람 · 부팅 · 알림 채널 2(§3 표의 권한)는 **E11p2**(PR #153)에서 더했습니다.
- `ios/`·`web/` 폴더는 이 타깃에 **만들지 않습니다**(§2 빌드 제외 규칙).
- 🔴 `local.properties` · `gradlew*` · `gradle-wrapper.jar` 는 저장소에 넣지 않습니다(루트 `.gitignore`) — `flutter build` 가 다시 만듭니다.

## 5. 빌드·실행

```bash
melos bootstrap                 # 저장소 루트에서 1회
melos run analyze               # 경고 0이 병합 조건
cd apps/app_operator_android
flutter build apk --debug       # Kotlin 컴파일 확인(CI 는 Gradle 을 돌리지 않는다)
flutter test                    # 채널 계약 · 글자 대조(CI 와 같은 범위)
flutter test integration_test/keystore_test.dart -d <기기>   # 실 Keystore(에뮬레이터 · 폰)
flutter test integration_test/engine_test.dart -d <기기>     # 🆕 E11p3a 조립(원장 폴더 · 기동 판정)
```

## 6. 금지

1. **화면에서 재계산 금지** — 이 앱은 조립만 합니다. `main.dart`에 수식이 생기면 위반입니다.
2. **사유 문구 생성 금지** — 사용자에게 보이는 상태 문장은 전부 엔진이 만든 문자열입니다.
3. **홈·알림·위젯에 손익 금지**(결정 8).
4. **안전 화면의 "UX 개선" 금지** — 킬스위치 48h 대기·체크리스트 순차 통과는 불편이 사양입니다.
5. **실키 금지** — 개발 중에는 연습 데이터만. 실제 KIS 앱키·계좌번호는 완성된 M9 화면에서 발주자가 직접 입력합니다.
