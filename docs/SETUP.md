# SETUP — Windows에서 이 저장소를 처음 돌리기까지

> **읽는 사람**: 이 PC(Windows 11)에서 AutoAlphaQuant를 빌드하려는 사람. Flutter를 처음 깔아 봅니다.
> **왜 필요한가**: 스캐폴드를 만든 시점(2026-09-06)에 이 PC에는 **Flutter·Dart·melos가 없었습니다.** 그래서 저장소의 파일들은 「문법은 맞게 썼지만 한 번도 실행해 보지 않은」 상태입니다. 아래 순서대로 하면 그 상태에서 벗어납니다.
> **걸리는 시간**: 다운로드 포함 40분~1시간(§1이 대부분).

---

## §0. 전체 그림 — 무엇을 왜 하는가

```
[1] Flutter SDK 설치      →  dart·flutter 명령이 생긴다
[2] melos 설치            →  패키지 10여 개를 한 번에 다루는 도구
[3] melos bootstrap       →  패키지들이 서로를 찾을 수 있게 연결
[4] 첫 검증 5가지         →  «파일은 있다»에서 «실제로 돈다»로  ← G2 완료 지점
[5] GitHub 설정(선택)     →  브랜치 보호·CODEOWNERS 효력
```

지금은 패키지가 **빈 껍데기**라 [4]에서 통과하는 것은 「경계 규칙·형식」까지입니다. 기능 테스트는 계약(G3)과 픽스처(G4)가 들어온 뒤에 생깁니다.

---

## §1. Flutter SDK 설치

Flutter를 설치하면 **Dart도 함께** 들어옵니다. Dart를 따로 깔지 마십시오(두 개가 되면 어느 쪽이 쓰이는지 헷갈립니다).

1. <https://docs.flutter.dev/get-started/install/windows> 에서 Windows용 안정 채널(stable) zip을 내려받습니다.
2. **경로에 공백·한글이 없는 곳**에 풉니다. 권장: `C:\src\flutter`
   - 🔴 `C:\Program Files\` 아래는 피하십시오(공백과 권한 문제로 pub이 자주 실패합니다).
3. 환경 변수 `Path`에 `C:\src\flutter\bin`을 추가합니다.
   - 시작 → 「시스템 환경 변수 편집」 → 환경 변수 → 사용자 변수 `Path` → 새로 만들기.
4. **새 터미널을 열고** 확인합니다.

```powershell
flutter --version
dart --version
```

5. 진단을 돌립니다.

```powershell
flutter doctor
```

- ✅ 이 저장소에 필요한 것: **Flutter SDK**와 **Android toolchain**(폰에 올릴 것이므로).
- ⬜ 지금은 없어도 되는 것: Visual Studio(Windows 데스크탑 빌드), Chrome(웹). `app_viewer_web`은 아직 스텁이고 웹 채택 자체가 미결(Q-D)입니다.
- Android Studio를 설치하면 Android SDK·라이선스 동의가 한 번에 끝납니다. 라이선스는 `flutter doctor --android-licenses`.

> ⚠️ **SDK 버전을 확인해 적어 두십시오.** 저장소의 `environment`는 루트·`packages/` 10개·`apps/` 3개가 전부 **`sdk: ^3.5.0` / `flutter: ">=3.24.0"`** 한 값으로 통일돼 있습니다(= Dart 3.5 이상). 하한만 정한 **잠정값**이니 실제 설치 버전을 보고 좁힐지 판단합니다(§4-6).
> 🔴 **깐 Flutter가 Dart 3.5 미만이면** `melos bootstrap`이 「SDK 제약 불만족」으로 실패합니다. 그때 고칠 자리는 13개 pubspec 전부이며 **한 커밋에서 같은 값으로** 고칩니다 — 한 곳만 낮추면 «앱은 되는데 의존이 안 되는» 상태가 됩니다.

---

## §2. melos 설치

패키지가 10여 개라 하나씩 `flutter pub get`을 부르면 서로의 경로 연결이 어긋납니다. melos가 그것을 한 번에 합니다.

```powershell
dart pub global activate melos
melos --version
```

- `melos: command not found`가 나오면 `%LOCALAPPDATA%\Pub\Cache\bin`을 `Path`에 추가하고 터미널을 다시 엽니다.
- ⚠️ **버전을 확인하십시오.** melos 6.x는 Dart의 pub workspace 방식을 권장하고, 3~5.x는 `melos.yaml`의 `packages:` 글롭 방식을 씁니다. 지금 저장소는 **글롭 방식**으로 쓰여 있습니다. 6.x를 깔았다면 §4-6을 읽고 한쪽으로 정리하십시오 — **두 방식을 섞으면 bootstrap이 조용히 다른 pubspec을 읽습니다.**

---

## §3. 저장소 가져오기

```powershell
git clone https://github.com/billybeom/AutoAlphaQuant.git C:\Work\Bob\AutoAlphaQuant
cd C:\Work\Bob\AutoAlphaQuant
```

이미 로컬에 있다면 이 단계는 건너뜁니다.

---

## §4. 첫 검증 — 이 순서대로

**순서가 중요합니다.** 앞이 실패한 채로 뒤를 돌면 원인이 섞입니다. 하나씩, 실패하면 거기서 멈추고 원인을 적으십시오.

### 4-1. 부트스트랩

```powershell
melos bootstrap
```

- 기대: 패키지 목록이 나열되고 각각 `pub get` 성공.
- ⚠️ 패키지가 아직 없으면 `No packages found`가 **정상**입니다(G3 이전).
- ❌ 버전 충돌이 나면 대개 `pubspec.yaml`의 `^` 제약 때문입니다. 스캐폴드의 버전은 전부 **잠정값**이니 실제 해결 가능한 버전으로 좁히고, 무엇을 왜 바꿨는지 커밋 메시지에 남기십시오.

### 4-2. 경계 규칙 (SDK 없이도 도는 검사)

```powershell
bash tool/check_boundaries.sh
```

- Git Bash가 필요합니다(Git for Windows에 포함).
- 기대: `✅ 경계 규칙 통과`.
- 이 검사는 「`ui_*`가 엔진·DB를 의존하는가」를 봅니다. **실패하면 그것은 취향 문제가 아니라 분업 경계가 뚫린 것입니다.**

### 4-3. 코드 생성

```powershell
melos run build:gen
```

- `*.freezed.dart`·`*.g.dart`는 **커밋하지 않습니다**(`.gitignore`). clone 직후와 CI에서 한 번 만들어야 합니다.
- 이것을 건너뛰면 다음 단계에서 「타입을 찾을 수 없다」가 잔뜩 납니다 — 코드가 틀린 게 아니라 생성물이 없는 것입니다.

### 4-4. 형식·분석

```powershell
melos run format
melos run analyze
```

- `analyze`는 `--fatal-infos`라 **정보 수준 지적도 실패**입니다. 이것이 병합 조건입니다.

### 4-5. 테스트

```powershell
melos run test
melos run golden:verify
```

- 지금은 테스트가 거의 없습니다. 계약(G3) 이후 C-1~C-16이 여기 붙습니다.
- 🔴 골든이 깨지면 **다시 찍지 마십시오.** 표시 계약이 바뀌었다는 신호입니다.

### 4-6. 여기까지 됐으면 — 잠정값 좁히기 (G2 완료)

첫 부트스트랩이 성공한 그 커밋에서, 실제 확인된 버전으로 `⚠️` 주석을 정리합니다.

| 파일 | 무엇을 | 어떻게 |
|---|---|---|
| `pubspec.yaml` **13개 전부**(루트 · `packages/*` · `apps/*`) | `environment.sdk`(현재 `^3.5.0`) · `environment.flutter`(현재 `">=3.24.0"`) | `dart --version`·`flutter --version` 결과에 맞춰 확정. 🔴 **13개를 같은 값으로, 한 커밋에서** — 한 곳만 다르면 해석이 조용히 갈립니다 |
| `pubspec.yaml` | `melos` 버전 | `melos --version` 결과로 고정 |
| `melos.yaml` | 글롭 방식 ↔ pub workspace 방식 | melos 6.x + Dart 3.6↑ 이면 workspace로 통일(한쪽만) |
| `analysis_options.yaml` | 켜지지 않는 lint 이름 | 분석기가 「알 수 없는 규칙」이라고 하면 그 줄만 제거 |

그리고 `README.md` §3의 G2 줄을 🟡에서 ✅로 바꿉니다 — **실제로 돌려 본 사람만** 바꿉니다.

---

## §5. GitHub 설정 (선택 — 화면 담당 AI에게 과제를 주기 전에)

`CODEOWNERS`와 CI는 저장소 설정이 받쳐 줘야 효력이 생깁니다.

1. **Settings → Branches → Add rule** (`main`)
   - Require a pull request before merging
   - Require status checks to pass — `경계 규칙 (C-3 · C-5)` · `골든 스냅샷 (C-1 · C-2 무결성)` · `분석 · 테스트 (melos)`
   - Require review from Code Owners (⚠️ 1인 저장소에서는 자기 PR을 자기가 승인할 수 없습니다 — 이 항목만 끄고 나머지를 켜는 것이 현실적입니다)
2. **Settings → Labels**에 `golden:approved`를 만듭니다. 골든 스냅샷을 의도적으로 바꿀 때 쓰는 유일한 통로입니다.
3. Actions가 켜져 있는지 확인합니다(private 저장소는 기본 켜짐).

---

## §6. 자주 막히는 곳

| 증상 | 원인 | 조치 |
|---|---|---|
| `melos: command not found` | pub 전역 bin이 Path에 없음 | `%LOCALAPPDATA%\Pub\Cache\bin` 추가 후 터미널 재시작 |
| `flutter pub get` 권한 오류 | SDK가 `Program Files` 아래 | `C:\src\flutter`로 옮김 |
| 「타입을 찾을 수 없다」가 대량 | 생성 코드 없음 | `melos run build:gen` |
| `bash: command not found` | Git Bash 미설치 | Git for Windows 설치, 또는 CI 결과로 대체 |
| 한글 리터럴 검사가 0건만 보고 | 셸 로케일이 UTF-8이 아님 | 스크립트가 「건너뛴다」고 경고합니다. `LANG=C.UTF-8 bash tool/check_boundaries.sh` |
| 첫 `flutter build apk`가 매우 느림 | Gradle 최초 다운로드 | 정상. 두 번째부터 빨라집니다 |

---

## §7. 이 문서를 고쳐야 하는 때

- SDK·melos 버전을 확정했을 때(§4-6)
- Android 서명 키(`key.properties`·`*.jks`)를 만들었을 때 — 🔴 **파일은 저장소에 넣지 말고**, 「어디에 두었는지」만 여기 적습니다(`.gitignore`가 이미 막고 있습니다)
- 첫 실기기 배포 절차가 생겼을 때

---

## §6. 실측 기록 — 2026-09-07 첫 bootstrap (G2 ✅)

| 항목 | 실측값 |
|---|---|
| Flutter | **3.47.2 stable** (`C:\src\flutter`, Dart **3.13.2**, DevTools 2.60.0) — 사용자 PATH에 `C:\src\flutter\bin` 추가 |
| melos | 전역 8.6.0 설치했으나 **저장소 안에서는 루트 pubspec의 `melos: ^6.0.0` → 6.3.3이 자동 사용**됨(고전 `packages:` 글롭 방식 그대로 동작). pub workspace 전환은 불필요 — 전환은 melos 7+로 올릴 때 한 커밋에서 |
| bootstrap | 성공. 단 `apps/app_operator_android`·`apps/app_viewer_web` 두 타깃은 package_config가 만들어지지 않아 각 폴더에서 `flutter pub get` 1회 추가 실행으로 해결(재현되면 §4 절차에 이 줄을 넣을 것) |
| 검사 5가지 | `melos run analyze` ✅(13 패키지 No issues) · `format` ✅(29 파일) · `check:boundaries` ✅ · `test` ✅(ui_* 자리표시 테스트 5) · `test:contracts` ✅ |
| Flutter 도구가 손댄 파일 | Flutter 패키지 8곳의 `analysis_options.yaml`에 `analyzer: exclude: [build/**]`가 자동 추가됨(«Upgrading analysis_options.yaml») — 유지 |
| 산출물 | melos가 만든 `pubspec_overrides.yaml` 11개 → `.gitignore`에 추가. `pubspec.lock`은 기존 규칙대로 미커밋 |
| Git Bash에서 실행할 때 | `melos`는 `melos.bat`뿐이라 PATH에 `%LOCALAPPDATA%\Pub\Cache\bin`을 넣고 `melos.bat run …`으로 부른다(중첩 스크립트 `test`·`analyze`가 내부에서 `melos`를 다시 부르므로 PATH가 없으면 «'melos'은(는) 내부 또는 외부 명령…»으로 실패). PowerShell에서는 `melos run …` 그대로 |
| PowerShell 주의 | `flutter --version 2>&1`처럼 stderr 리디렉션을 붙이면 «Building flutter tool...» 한 줄이 NativeCommandError로 잡혀 exit 1이 난다 — 리디렉션 없이 실행 |
| 남은 것(발주자) | Android toolchain(Android Studio + `flutter doctor --android-licenses`) — 폰에 올릴 때 필요. 계약·픽스처 테스트는 순수 Dart라 지금 상태로 검증 가능 |
