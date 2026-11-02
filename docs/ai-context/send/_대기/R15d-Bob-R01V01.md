# 발송 패킷 R15d-Bob-R01V01 — R-01 기존 계정에서 다시 시작 · V-01 조회 전용 QR 페어링 (계약 v1.16 전제 · R15 4장 중 4번째 · M8 · «정확히 N» 소유)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-02 조립 · 앱 `rec/r15`) · 선행 = ① R15c 병합(squash `__R15C_SQ__` · PR `__R15C_PR__` · 시작 기준 N = R15c 병합본 실측) ② 🔴 **계약 v1.16 보강 R15d 몫(G18·G19 — 아래 «■ 계약 v1.16 이름표» · ⬜ 발주자 결정 · ▶ 금지)** ③ 🔴 **V-01 클레임 창구 결정**(뷰어(iOS) 빌드에는 `SettingsActions` 가 주입되지 않는다 — 권고 = 뷰어 주입 읽기 창구 `PairingRepository` + 스캔·클레임 = 플랫폼 몫 · 01 §8 미결 13 `role` 클레임 발급 위치와 한 창 · ⬜ 발주자 결정) ④ 🔴 **X1 계획·비상 경로 라우트**(R-01 분기 목적지 · 🔒 X1 마법사 = Claude 소유 · 지금 `AppRoutes.x1Migration` 하나 — 갈래 인자 0) ⑤ ⬜ 누적 드라이런 ⑥ ⬜ 발주자 확인 ①~⑩ ⑦ ⬜ 「푸시해」. 🔵 **후순위 가능**(R15a 발주자 확인 ① — X1·M9 창과 묶어 미루면 이 카드는 `_대기/` 에 남고 «정확히 N» 은 R15c 가 소유) · 🔴 Bob 의 R15a~R15c 브랜치는 건드리지 않는다.
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(🔀 4분할) + §3-0 + §3 공통 조문 + 이월 부록 «R15» 대상(R15a «6» 과 같은 표) · 화면 몫 원본 = `04_…` §9-6(`R-01` · 1) 복구 카드 로그인 2) 기기 원장 요약 3) 분기 · «3)에서 역할 끝» · 초기화 선택지 0 · 갭 7일 = 뷰모델 · 그림 21) · §9-7(`V-01` · QR → 클레임 → 결과 · 수동 입력 0 · 실패 = 코드+문구 · 그림 22) · §9-8(게이트 3상 — 리스·기기 원장 = 있음/없음/모름 · 모름 = 진행 차단) · §2-5(R-01 = Android · V-01 = iOS) · `01_…` §8 미결 13 · §4-3 · 05 §3 `S06`(발급·폐기 = M9 — 읽기만) · 판독 메모 §5-1 G18·G19.
> 사전 조건 — ⬜ **R15c 병합**(`ui_shell` = lib 17파일 · 라벨 37 · 배럴 14 · 주입 18 · PNG 62 — 병합본 실측으로 채움) · ⬜ 계약 v1.16 R15d 몫 · ⬜ V-01 클레임 창구 · X1 라우트 결정. 시작 기준 = **⟦실측: R15c 병합본 — 드라이런 기대 308⟧** · 끝 기대 = N + **38**(뷰 30 = `onboarding_restart_test` 18 + `viewer_pairing_test` 12 · 골든 8 = `r01_*` 4 + `v01_*` 4) · 끝 = ⟦실측: «+346» 기대⟧.
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **18**(`onboarding_restart_test` 9 · `viewer_pairing_test` 7 · 골든 2) · lib ⟦실측: 추정 +210~280⟧ · 새 PNG **8** · 원천 **2**(`watchRestart` · `watchPairing`) → 임계 안 · 🔴 이 카드가 «정확히 N» 을 **소유**한다(R15 마지막 — 라벨 37 · 배럴 16 · 주입 19 · PNG 70).
> 카드 기본값(⬜ 발주자 확인 ①~⑩): ⓐ 위젯 = `OnboardingRestart({super.key})`(`lib/src/onboarding/onboarding_restart.dart` · `ConsumerWidget` · Android) · `ViewerPairing({super.key})`(`lib/src/onboarding/viewer_pairing.dart` · `ConsumerWidget` · iOS 뷰어) ⓑ 셸·R15a~R15c 파일 무변경(셸 가드 무변경 — 04 §2-5 의 «iOS = V-01 만» 은 조립 앱 레지스트리가 지킨다 · 미결 127) ⓒ R-01 원천 = 🆕 `watchRestart()` → `RestartVm` · 쓰기 0 — ① 로그인 = 🔒 슬롯(매직링크/OTP · 플랫폼 · R15b 슬롯 빌더) · ② 기기 원장 요약 = 엔진 글자 줄 · 리스 게이트(`GateBadge` 3상 — 모름 = 진행 차단 모양) · ③ 분기 = 엔진이 고른 `OnboardingLinkAction` 목록(계획 QR · 비상 · 갭 7일 «신규 온보딩 + 잔고 승계») → 링크로 넘기고 역할 끝 · 승계 고지(킬스위치·차단 플래그 = 활성 승계 · 엔진 글자) ⓓ V-01 원천 = 🆕 `PairingRepository.watchPairing()` → `PairingVm`(뷰어 주입 🆕 `shellPairingRepositoryProvider`) · 스캔·클레임 = 🔒 슬롯(카메라 · 플랫폼) · 결과 = `level` 아이콘 + `headline` + `reasonCode`(원문) + `next?`(링크) · 수동 입력 0 ⓔ 🔴 «초기화»·«새로 시작» 류 선택지 0(엔진이 갭 7일 갈래를 줄 때만 그 글자) · 갭 일수로 분기 0 · «일단 진행» 0 ⓕ 새 lib 파일 2 · 공용 3(배럴 +2 · `shell_providers.dart` 끝 절 주입 1 · `test/shell_fakes.dart` 끝 절) · 라벨 0 · Key 접두 `r01-`·`v01-` · 골든 4이름 8장(`r01_lost_phone` · `r01_gap7` · `v01_ok` · `v01_fail`).
> 🔴 **카드 덮개 필수 문장(04 §9-6 · §9-7 · §9-8 · prompt_M8 145~152)** — «R-01 = 로그인 자리 → 기기 원장 요약 → 엔진이 준 분기 링크 — 3)에서 역할 끝(X1 마법사·검증·DRY_RUN·LIVE = 🔒 Claude · 라우트로 넘기기만)» · «분기 = 데이터(갭 일수로 화면이 고르지 않는다) · 초기화 선택지 0 · 킬스위치·차단 플래그 = 활성 승계(엔진 글자)» · «리스·기기 원장 게이트 3상 — 모름 = 진행 차단 모양 · 해당 없음과 다른 모양 · «일단 진행» 0» · «V-01 = 스캔 자리 → 결과(코드 + 문구 원문) — URL·키 수동 입력·소유자 로그인 폼 0 · 발급·폐기 = M9» · «셸·R15a~R15c 파일·테스트·PNG 무변경».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 결정 9e(조회 전용 폰 = QR 페어링 · role=viewer 클레임 토큰) · 01 §2-1 `GateState.unknown` · X1 계획/비상 경로(🔒 Claude).
> ⬜ **발주자 확인 10건(권고 = 카드 기본값)** — ① R-01 원천 = 🆕 `watchRestart()` → `RestartVm{headline, loginSlotId?, ledgerLines, leaseGate?, branches, inheritNotice?}`(04 §9-6 1)~3)) · 표본 `m8/restart_lost_phone`(단계 6행 + 묶이지 않은 `lease_notice`)은 쓰지 않는다 · 코어 `onboarding_reconnect` 단계 목록은 R15b `OnboardingStepList` 가 갈래 무관으로 그린다(재접속 갈래도 같은 화면 — 엔진이 목록을 고른다) ② 분기 = 🆕 `OnboardingLinkAction` 목록(R15c 와 같은 타입) — 목적지 라우트 = ⟦v1.16 — X1 계획·비상 두 라우트 또는 `x1Migration` 에 갈래 인자⟧ · 갭 7일 «신규 온보딩 + 잔고 승계» = 엔진이 고른 한 갈래 ③ `DeviceAccessVm`(M9 `S06` · 로그인 뒤)은 R-01 이 쓰지 않는다(로그인 전 화면 · 원천 = `RestartVm.ledgerLines`) ④ 리스 게이트 = `GateBadge?` 4값 전수(모름 = 차단 모양 · 엔진이 그때 `branches` 를 비운다) ⑤ ① 로그인 = 🔒 슬롯(`loginSlotId` · 매직링크/OTP = 플랫폼 — `supabase_flutter` 금지 · 조립 앱) ⑥ V-01 원천 = 🆕 `PairingRepository.watchPairing()` → `PairingVm{headline, scannerSlotId?, result?}` · `PairingResult{level, headline, reasonCode?, next?}` · 주입 🆕 `shellPairingRepositoryProvider`(뷰어 빌드 = 구현 · 폰 빌드 = 구현 또는 미사용) · 스캔·클레임·토큰 저장 = 플랫폼(조립 앱 · 01 §8 미결 13) — 대안 = V-01 전부 조립 앱(화면 카드 0 · F-01 선례) ⑦ 폐기된 토큰 = 엔진이 `result.level`·`reasonCode` 로(«즉시 차단» — 화면 판정 0) ⑧ 정적 라벨 0(분기·결과·다음 글자 = 엔진) ⑨ 골든 4이름 8장(04 에 이름 없음 · 카드가 지음) ⑩ «정확히 N» 소유 = 이 카드(라벨 37 · 배럴 16 · 주입 19 · PNG 70 · golden README 장수) — 이 카드를 미루면 R15c 로 옮긴다.
> 🚫 **플랫폼 몫 = 화면 밖** — Auth 매직링크/OTP 로그인(R-01 ①) · QR 카메라 스캔·토큰 클레임·저장(V-01) · X1 마법사(🔒 Claude) · 기기 epoch·TTL 대기(엔진) · iOS/Android 진입 가드(조립 앱).
> 드라이런: ⬜ ⟦실측: 누적 드라이런 4번째 — 가지 `dry/r15-4`⟧.
> 프롬프트 = `prompt_M8.md`(v2 판 183줄). 🔴 Bob **새 대화** 전제. 교훈 반영 = R15a 머리 줄과 같다(PNG 열람 4장).

## 0. 한 줄 목적

`OnboardingRestart()` 가 `watchRestart()` 의 `RestartVm`(로그인 자리 · 기기 원장 요약 · 리스 게이트 3상 · 엔진이 고른 분기 링크 · 승계 고지)을 받은 차례·글자 그대로 그리고 분기 탭은 링크로만 넘기며(초기화 0 · 갭 일수 판정 0), `ViewerPairing()` 이 `watchPairing()` 의 스캔 자리와 결과(코드 + 문구 원문 · 다음 링크)만 그리는(수동 입력 0) `R-01`·`V-01` 을 계약 v1.16 그대로 짓고, R15 공용 파일의 «정확히 N» 을 닫기.

## 1. 어디에 보내나

**IBM Bob** — 새 브랜치 **`ui/m8-r01-restart`**(base = 최신 `origin/main` · `--no-track`) · PR 제목 = «[M8] R-01·V-01 다시 시작·조회 전용 페어링».

## 2. 보내기 전에 발주자가 할 것 🔴

1. `send/` 바로 아래 · 머리 첫 줄 ▶ 일 때만(지금 `_대기/`). 2. Bob **새 대화**. 3. GitHub `main` — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R15d-Bob-R01V01.md>. 4. «3» 본문 전부. 5. 🔴 `_완료/R15a~R15c*` 를 붙여넣지 않습니다. 6. 받는 법 = R15a 와 같다(`$env:TEMP\R15d-Bob-R01V01_submit.md` · BOM 0 · 채팅 두 줄). 7. `flutter_tester` 를 직접 끝내지 마세요.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R15d-Bob-R01V01 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R15d-Bob-R01V01 — 범위: R-01 기존 계정에서 다시 시작(OnboardingRestart() — 머리 · 로그인 🔒 자리 · 기기 원장 요약 줄 · 리스 게이트 · 분기 링크 · 승계 고지) ·
  V-01 조회 전용 QR 페어링(ViewerPairing() — 머리 · 스캔 🔒 자리 · 결과(아이콘 · 문구 · 원문 코드 · 다음 링크)) + 새 주입 1 + 배럴 export 2줄 + 가짜 끝 절 · 🔴 «정확히 N» 소유(R15 마지막).
🔴 R-01 = 3)에서 역할 끝 — 분기 = 엔진이 준 링크 목록 · 갭 일수로 화면이 고르지 않는다 · 초기화·새로 시작 선택지 0 · X1 마법사·검증·DRY_RUN = 이 카드 밖(라우트로 넘기기만).
🔴 리스·기기 원장 게이트 3상 — 모름 = 진행 차단 모양 · 해당 없음과 다른 모양 · «일단 진행» 0 · 킬스위치·차단 플래그 = 활성 승계(엔진 글자).
🔴 V-01 = 스캔 자리 + 결과 원문 — URL·키 수동 입력·소유자 로그인 폼 0 · 폐기·실패 판정 = 엔진(level · reasonCode) · 발급·폐기 버튼 0(M9).
🔴 셸·R15a~R15c 파일·테스트·PNG 무변경 · 로그인·스캔·클레임·토큰 저장 = 플랫폼(슬롯).
하지 않는 것: O-00~O-04(병합됨) · X1 마법사(🔒) · S06 기기 관리(M9) · DeviceAccessVm · 매직링크/OTP · 카메라 · supabase_flutter · 새 라벨 · domain_contracts·pubspec 수정 · 다른 ui_*.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 15항).

■ 0단계 — 대상 확인
이 카드는 R15a~R15c(병합됨)가 아닙니다. 지금 코드에는 lib/src/onboarding/onboarding_restart.dart · viewer_pairing.dart 가 없습니다.
  git branch --show-current · git status --short(빈) · git fetch origin --prune · git checkout --no-track -b ui/m8-r01-restart origin/main
  git grep -c "Stream<RestartVm> watchRestart();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart   ← «…:1»(v1.16)
  git grep -c "Stream<PairingVm> watchPairing();" -- packages/domain_contracts/lib/src/repositories   ← ⟦v1.16 파일 자리⟧ «…:1»
  git grep -c "abstract class RestartVm" -- packages/domain_contracts/lib · git grep -c "abstract class PairingVm" -- packages/domain_contracts/lib · git grep -c "abstract class PairingResult" -- packages/domain_contracts/lib   ← ⟦v1.16⟧ 각 «…:1»
  git grep -c "class UnimplementedPairingRepository" -- packages/domain_contracts/lib/testing.dart   ← «…:1»(v1.16)
  git grep -c "static const String m8RestartVmLostPhone =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← «…:1»(v1.16)
  git grep -c "class OnboardingFinish" -- packages/ui_shell/lib/src/onboarding/onboarding_finish.dart   ← «…:1»(R15c 병합)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md
  ls docs/ai-context/send/R15d-Bob-R01V01.md · ls docs/ai-context/inbox/R01V01_questions.md · ls packages/domain_contracts/fixtures/m8/restart_vm_lost_phone.json · restart_vm_gap7.json · restart_vm_unknown.json · pairing_waiting.json · pairing_ok.json · pairing_fail.json   ← 전부 보여야 함
  반대(없어야 함): ls packages/ui_shell/lib/src/onboarding/onboarding_restart.dart · git grep -c ViewerPairing -- packages/ui_shell/lib
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 ⟦실측: R15c 병합본 «+308: All tests passed!»⟧ → cd ../..

■ 계약 v1.16 이름표 — R15d 몫(🔴 코드가 정본 · ⟦v1.16⟧ = 보강 PR 글자로 고침)
  🆕 RestartVm({required String headline, String? loginSlotId, required List<String> ledgerLines, GateBadge? leaseGate, required List<OnboardingLinkAction> branches, String? inheritNotice})
       — loginSlotId = ① 복구 카드 로그인 자리(플랫폼 · null = 이미 로그인) · ledgerLines = ② 구 폰 라벨·마지막 접속·리스 잔여(엔진 글자) · leaseGate = 리스·기기 원장 3상 · branches = ③ 엔진이 고른 분기(모름이면 0) · inheritNotice = 킬스위치·차단 플래그 승계 고지
  🆕 PairingVm({required String headline, String? scannerSlotId, PairingResult? result}) · 🆕 PairingResult({required UiLevel level, required String headline, String? reasonCode, OnboardingLinkAction? next})
  🆕 PairingRepository { Stream<PairingVm> watchPairing(); }(뷰어 주입 · 클레임 = 플랫폼이 하고 결과를 이 스트림에 싣는다 · ⟦v1.16 · 01 §8 미결 13⟧) · OnboardingRepository += Stream<RestartVm> watchRestart();
  OnboardingLinkAction(R15c) · GateBadge · UiLevel(기존) · testing.dart = UnimplementedPairingRepository(🆕) · UnimplementedOnboardingRepository(watchRestart 포함)
  FixturePaths  m8RestartVmLostPhone(branches 2 — 계획 QR · 비상 · leaseGate pass · inheritNotice non-null) · m8RestartVmGap7(branches 1 — 신규 온보딩 + 잔고 승계) · m8RestartVmUnknown(leaseGate unknown · branches 0) ·
                m8PairingWaiting(result null · scannerSlotId non-null) · m8PairingOk(result level ok · next non-null) · m8PairingFail(result level blocked · reasonCode non-null(폐기 토큰) · next null)
  🔴 쓰지 않는 것: m8/restart_lost_phone(단계 6행 + lease_notice) · onboarding_reconnect · DeviceAccessVm · SettingsActions · AppRoutes.x1Migration(링크 = 데이터).

■ 규칙 요약 (정본 = 이 카드 · «= R15a 규칙 n» 의 글자는 docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3»)
 1 고치는 곳 = packages/ui_shell + inbox/R01V01_questions.md 만. 새 파일 = lib/src/onboarding/onboarding_restart.dart · viewer_pairing.dart · test/onboarding_restart_test.dart · test/viewer_pairing_test.dart · test/golden/r01_golden_test.dart · v01_golden_test.dart · 새 PNG 8.
   공용 3파일 끝 절 더하기만: lib/src/shell_providers.dart 끝 R15d 절(🆕 final Provider<PairingRepository> shellPairingRepositoryProvider · throw 기본값) · lib/ui_shell.dart export 두 줄(정렬 차례 — src/onboarding/onboarding_restart.dart 는 onboarding_mode_pick 뒤 · src/onboarding/viewer_pairing.dart 는 onboarding_step_list 뒤 · src/ops_home.dart 앞) · test/shell_fakes.dart 끝 R15d 절.
   고치면 반려: 그 밖 ui_shell 파일 전부 · domain_contracts/** · apps/** · 다른 ui_*.
 2 = R15a 규칙 2(값 = headline · ledgerLines · leaseGate.label · branches[i].label · inheritNotice · result.headline · reasonCode 원문 · next.label · 리터럴 0).
 3 읽지 않는 필드: OnboardingLinkAction.link(🔴 open 인자로만) · loginSlotId·scannerSlotId(빌더 인자로만) · GateBadge.code · blockedReasonCode.
 4 이동 = AppLinkOpener.open(link) — 링크 = branches[i].link · result.next.link 둘뿐 · 'aaq://' 리터럴 0 · AppRoutes 0(x1Migration 포함).
 5 산술·판정 0 — 허용 = null 여부 · GateState 4값 · UiLevel 5값 전수 switch · 순번 · 🔴 branches 를 고르거나·세거나·«0 이면 문장» 0(빈 = 아무것도 그리지 않음 — 이유는 leaseGate 가 말한다) · 갭 일수·시각 계산 0.
 6 switch = GateState 4(_gateLook — R15b 글자) · UiLevel 5(_resultLook — R15b 글자) · 둘뿐. 7·8 = R15a 규칙 7·8. 9 새 주입 1 · 데이터 2(_restartProvider · _pairingProvider) · 탭 안 ref.read.
10 = R15a 규칙 10(⓪ 경우 for 밖 · 흐름 칸 non-null · name 칸 · 부재 = 데이터 · ⓡ·ⓗ = T20·T21 — 계획 restart_test ⓡ 6 · ⓗ 1 · pairing_test ⓡ 5 · ⓗ 0 · 드라이런이 «정확히» 로 확정) · 🔒 자리 = R15b FakeShellSlotRecorder(새 가짜 0).
11 골든 = 새 PNG r01_* 4 · v01_* 4 · 높이 844 고정 · 기존 PNG 62장 재생성 0. 12~14 = R15a 규칙 12~14.
15 주석 금지 낱말: x1Migration · AppRoutes · DeviceAccessVm · SettingsActions · supabase · camera · token · password · TextField · 초기화 · 새로 시작 · 일단 · DateTime.now · Duration · 추천 · 권유 · 자문 · 시그널.
🔴 보고 규칙 = R15a «보고 규칙»(PNG 열람 4장 · S05 기대 2줄).

■ 프롬프트보다 이 카드가 이긴다 — 15항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 범위 → R-01 · V-01 ② 113~118행 → 이 카드 = R-01 · V-01 · O-00~O-04 = R15a~R15c(병합됨) ③ 12~13행 → 추가 0 ④ 15~19행 링크 = 데이터 → 그대로(분기 · 다음) ⑤ 20~23행 → 그대로(갭 일수·리스 잔여 = 엔진 글자)
 ⑥ 24~31행 → 그대로 ⑦ 32~35행 → 라벨 0 ⑧ 36~38행 → 그대로(빈 분기 = 그리지 않음) ⑨ 41~47행 → 그대로(🔒 X1 마법사 · 킬스위치 = 승계 고지 글자만) ⑩ 48~57행 → 그대로
 ⑪ 106~111행 → inbox/R01V01_questions.md ⑫ 127~128행 → ui/m8-r01-restart · «[M8] R-01·V-01 다시 시작·조회 전용 페어링» ⑬ 145~150행 → 그대로(로그인·스캔 = 자리 · 수동 입력 0) ⑭ 151~152행 → 그대로(결과 = headline + reasonCode 원문) ⑮ 172~182행 → ■ 제출 ② 상자 + 괄호

■ 먼저 읽을 것 — ① prompt_M8.md ② 04 §9-6 · §9-7 · §9-8 · §2-5 ③ 01 §8 미결 13 · ⟦v1.16 절⟧ ④ domain_contracts v1.16 dto · repositories · testing.dart ⑤ ui_shell — lib/src/onboarding/onboarding_step_list.dart(_gateLook) · onboarding_step_detail.dart(_resultLook · 슬롯) · onboarding_finish.dart(링크 동작) — 읽기만 ⑥ _완료/R15a «3» ⑦ inbox/R01V01_questions.md 머리말

■ 본받지 않는 것
 · m8/restart_lost_phone 의 단계 행·lease_notice 를 R-01 에 그리기 · DeviceAccessVm 쓰기 · 갭 7일을 화면이 세어 «신규 온보딩» 버튼 · «초기화하고 새로 시작» · leaseGate unknown 인데 분기 버튼 · «일단 진행»
 · URL·키·코드 수동 입력 칸 · 소유자 로그인 폼 · 스캔 버튼을 화면이 직접(카메라) · 폐기 토큰을 화면이 판정 · 발급·폐기 버튼 · x1Migration 상수로 이동

■ 주입 구조 — onboarding_restart.dart = OnboardingRestart(공개 · ConsumerWidget) · _restartProvider · _gateLook / viewer_pairing.dart = ViewerPairing(공개 · ConsumerWidget) · _pairingProvider · _resultLook · 🆕 shell_providers.dart 끝 R15d 절 = shellPairingRepositoryProvider · 배럴 두 줄.

■ 호출 표 — R-01: watchRestart() 한 번(재시도 = 한 번 더) · 슬롯 빌더(loginSlotId) · shellLinkOpenerProvider(분기 탭 안) · 부르지 않는 것: SettingsActions · watchStepList · watchPairing. V-01: watchPairing() 한 번 · 슬롯 빌더(scannerSlotId) · shellLinkOpenerProvider(«다음» 탭 안) · 부르지 않는 것: OnboardingRepository · SettingsActions.

■ 상태 표 — restart: hasError → ShellErrorView(key: const Key('r01-fail'), …) · 값 전 → ShellSkeleton(key: const Key('r01-loading')) · pairing: Key('v01-fail') · Key('v01-loading').

■ 화면 1 — R-01: 머리 Padding(key: const Key('r01-headline')) → (loginSlotId && builder) Padding(key: const Key('r01-login'), builder(id)) → Padding(key: const Key('r01-ledger'), Column[ for line Text(line) ]) → (gate) Row(key: const Key('r01-gate'))[ Icon(_gateLook) · Flexible(Text(gate.label)) ] →
   for (i, b) in branches.indexed FilledButton.tonal(key: ValueKey<String>('r01-branch-$i'), onPressed: () { open(b.link); }, child: Text(b.label)) → (inherit) Padding(key: const Key('r01-inherit'), Text(inherit))
 ■ 화면 2 — V-01: 머리 Padding(key: const Key('v01-headline')) → (scannerSlotId && builder) Padding(key: const Key('v01-scanner'), builder(id)) → (result) Padding(key: const Key('v01-result'), Column[ Row[ Icon(_resultLook, key: const Key('v01-level')) · Expanded(Text(r.headline)) ] · (code) Text(code) ]) →
   (next) FilledButton(key: const Key('v01-next'), onPressed: () { open(next.link); }, child: Text(next.label))

■ Key 표 (r01- 9 · v01- 8) — r01-loading · r01-fail · r01-headline · r01-login · r01-ledger · r01-gate · r01-branch-$i · r01-inherit · v01-loading · v01-fail · v01-headline · v01-scanner · v01-result · v01-level · v01-next

■ 할 일 — (1) lib 두 파일 + shell_providers R15d 절 + 배럴 «[M8] R15d (1) R-01·V-01 화면» (2) fakes 끝 절(FakeShellRestartRepository extends UnimplementedOnboardingRepository · FakeShellPairingRepository extends UnimplementedPairingRepository) + 두 테스트 «[M8] R15d (2) R-01·V-01 테스트»
 (3) 골든 8장 «[M8] R15d (3) 골든 r01_* 4장 · v01_* 4장» (4) format · 질문(A1~A4 dy) «[M8] R15d (4) format · 질문».

■ 정적 라벨 — 0개(🔴 labels.dart 무변경 · 총수 «정확히» 37 = 정적 T13).

■ 테스트 최소 목록 (계획 — 드라이런이 수·(전제)·ⓡ 를 «정확히» 로 확정)
 R-01 — test/onboarding_restart_test.dart(줄 9 · 테스트 18)
 R01-01 블록 차례·글자(lostPhone) — 사슬 dy headline → login → ledger → gate → branch-0 → branch-1 → inherit · ⓗ expect(lostPhone.branches, hasLength(2)) → 분기 글자 == label · ⓡ.
 R01-02 리스 게이트 3상(lostPhone pass · unknown 모름 — 아이콘 다름 · unknown 은 차단 색) · ⓡ.
 R01-03 분기 탭 = link(데이터) — 세 경우(plan · emergency · gap7) → opener.opened == [link] · ⓡ.
 R01-04 모름 = 분기 0(unknown · r01-branch-0 findsNothing · 양성 기준점 r01-gate) · ⓡ.
 R01-05 승계 고지 = 데이터 — 두 경우(lostPhone 있음 · gap7 ⟦표본⟧) · «없는 쪽» 견본 · ⓡ.
 R01-06 로그인 자리 = 슬롯 빌더 — 두 경우(빌더 있음 → slotIds == [loginSlotId] · null → r01-login findsNothing) · TextField findsNothing · ⓡ.
 R01-07 상태 갈래 세 경우 · R01-08 재시도 · ⓡ · R01-09 화면 Text 전부 · 큰 글꼴 세 경우(lostPhone · gap7 · unknown) · ⓡ.
 V-01 — test/viewer_pairing_test.dart(줄 7 · 테스트 12)
 V01-01 기다림 = 스캔 자리만(waiting · v01-result findsNothing · v01-next findsNothing) · ⓡ.
 V01-02 성공 = 문구 + 다음 링크(ok → tap v01-next → opener == [next.link]) · ⓡ.
 V01-03 실패 = 문구 + 원문 코드 · 다음 0(fail · shownTexts(v01-result) == [headline, reasonCode]) · ⓡ.
 V01-04 스캔 자리 = 슬롯 빌더 — 두 경우(빌더 있음 · null → v01-scanner findsNothing) · TextField findsNothing · ⓡ.
 V01-05 상태 갈래 세 경우 · V01-06 재시도 · ⓡ · V01-07 화면 Text 전부 · 큰 글꼴 세 경우.
🔴 예고 변이: 분기 뒤집기 · 분기 하나 빼기 · 갭 7일 갈래를 화면이 더하기(정적 글자) · unknown 에도 분기 · unknown 을 notApplicable 모양 · 초기화 버튼 더하기 · 분기 탭 0 · 다른 링크 · 승계 고지 빼기 · ledger 줄 하나 빼기 · 로그인 자리 대신 TextField ·
   결과 headline·code 빼기 · 실패에도 다음 · 성공에 다음 0 · 결과 level 아이콘 고정 · 스캔 자리 대신 입력 칸 · 에러를 스켈레톤 · 재시도 invalidate 0 · 정적 글자 더하기 · ⟦실측: 드라이런 변이 표⟧.

■ 정적 묶음 — R15a 꼴 37줄 안팎(머리 «## T01» ~ · 꺼내기 범위·해시 = ⟦실측⟧) — 판정 줄(뜻과 기대 · ⬜ 드라이런 전):
  T01·T02 = 0 · T03 = 4줄(r01_golden 1 · v01_golden 1 · restart_test 9 · pairing_test 7) · T04 = 0 · S05 = 2줄(분기 · 다음) · T06 = 2(watchRestart( · watchPairing() · T07 SettingsActions = 0 · T09 GateState 4 · UiLevel 5 = 9줄 · T10 슬롯 빌더 = 2줄 ·
  T11 금지 낱말 0(x1Migration|AppRoutes|DeviceAccessVm|SettingsActions|DateTime\.now|Duration\(|\.length|\.where\(|\.sort|\.take\(|TextField|supabase|camera|[Tt]oken|password|print\() ·
  🔴 T13 라벨 «lib/l10n/labels.dart:37»(정확히) · T14 배럴 16줄(정확히 — l10n/labels.dart · alerts 2 · onboarding 7(finish · mode_pick · restart · start · step_detail · step_list · viewer_pairing) · ops_home · ops_rhythm · routing/shell_router · shell_providers · shell_scaffold · watchdog_board 차례) ·
  T15 주입 19줄(정확히 — R14 15 + R15a 2 + R15b 1 + R15d 1) · T16~T19 = 0 · T20·T21 ⓡ·ⓗ(정확히) · T22 Key 이름 15 · T23 금지 어휘 0(+ 초기화 · 새로 시작 · 일단) · T24~T27 = 0 · T29 numstat(shell_providers · ui_shell · shell_fakes 세 줄 · 둘째 수 0) · T30~T32 = 0 ·
  T33 PNG 8줄 «A» · 🔴 T37 PNG 총수 «70»(정확히 — R14 40 + R15a 8 + R15b 10 + R15c 4 + 이 카드 8) · T34 (pre) 정확히 · T35 = 0 · T36 입력 위젯 0.

■ 골든 — r01 — test/golden/r01_golden_test.dart · 위젯 = OnboardingRestart() · r01_lost_phone(lostPhone · 맨 아래 Key('r01-inherit')) · r01_gap7(gap7 · 맨 아래 ValueKey('r01-branch-0') ⟦표본⟧) · 머리 Key('r01-headline') dy 0.0 · 슬롯 = FakeShellSlotRecorder
  v01 — test/golden/v01_golden_test.dart · 위젯 = ViewerPairing() · v01_ok(ok · 맨 아래 Key('v01-next')) · v01_fail(fail · 맨 아래 Key('v01-result')) · 머리 Key('v01-headline') dy 0.0 · 나머지 = R15a 골든 절 글자.

■ 질문 파일 — R01V01_questions.md(이미 있다) · A1~A4 = r01_lost_phone · r01_gap7 · v01_ok · v01_fail dy «측정:» 행 · 접두 «R-01:» · «V-01:».

■ 제출 — R15a «■ 제출» 과 같은 꼴
  flutter test test/onboarding_restart_test.dart ← «00:0n +18» · test/viewer_pairing_test.dart ← «+12» · r01_golden ← «+4» · v01_golden ← «+4» · flutter test ← N + 38 — ⟦실측: 308 → «+346»⟧
  name-status 기대: A lib/src/onboarding/onboarding_restart.dart · A lib/src/onboarding/viewer_pairing.dart · M lib/src/shell_providers.dart · M lib/ui_shell.dart · A PNG 8 · A 골든 테스트 2 · A 테스트 2 · M test/shell_fakes.dart · M inbox/R01V01_questions.md · 그 밖 = 금지
  사전검사 ② 두 번: --golden-prefix r01_ --goldens 4 · v01_ --goldens 4 · PR 제목: [M8] R-01·V-01 다시 시작·조회 전용 페어링 · 채팅 = 두 줄.
   ① 머리 복사 상자 글자: «화면 ID: R-01 — 기존 계정에서 다시 시작(OnboardingRestart()) · V-01 — 조회 전용 QR 페어링(ViewerPairing()) · 주입 shellPairingRepositoryProvider»
   (+ flutter test 한 줄 — 시작·끝 상자(기대 M = N + 38))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-r01-restart` · 커밋 권장 4 · lib 새 2 · 주입 +1 · 배럴 +2 · test 새 4 + fakes 끝 절 · PNG 8 · `R01V01_questions.md` A1~A4 · `flutter test` = N + 38(⟦실측⟧) · 🔴 «정확히 N» = 라벨 37 · 배럴 16 · 주입 19 · PNG 70.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15d-Bob-R01V01 결과: 브랜치 ui/m8-r01-restart 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

## 5. 주의

- **5분 눈 검사**: 초기화·새로 시작 버튼 · 갭 일수 판정 · unknown 에도 분기 · 수동 입력 칸 · 카메라·토큰 코드 · `x1Migration` 상수 · 셸 파일 `M`.
- 🔵 R15 마지막 카드 — 병합 기록이 R15 완료(🏁)를 적는다 · 다음 = 12 §6 큐(R16) · R15 test-only PR(C4 이월 몫이 생기면).
- ⬜ 남은 표식 = 실측 표식 + 자리표시자 `__R15C_SQ__` · `__R15C_PR__` — 🔴 보내기 전 0.
- 범위 고지: 01 §8 미결 13(role 클레임 발급 위치) · 127(뷰어 가드) · X1 라우트 갈래 — 이 카드가 닫지 않는다(v1.16 창).

## 6. R15 이월 반영 — R15a «6» 과 같은 표(R-01·V-01 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r14b-1 · -2 · C4r14a-4 | 규칙 10 = R15a 규칙 10 | — |
| C4r14b-5 | ■ 제출 = R15a 꼴 | — |
| C4r14a-5 쓰기 조각 | — | 해당 없음(이 카드 쓰기 0) |
| C4r14a-6 부재 = 데이터 | R01-04 · R01-05 · V01-01 | 주입 null 갈래 = 슬롯 빌더 null 두 경우(R01-06 · V01-04) |
| C4r5d-5 골든 명령 칸 | — | 해당 없음(명령 0) |
| C4r5c-5 · C4r5e-3~7 (계승) | R15a «6» 과 같은 자리 | 배너 = 해당 없음 |
