# 발송 패킷 R15d-Bob-R01V01 — R-01 기존 계정에서 다시 시작 · V-01 조회 전용 QR 페어링 (계약 v1.16 전제 · R15 4장 중 4번째 · M8 · «정확히 N» 소유)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-02 조립 · 2026-11-03 드라이런·지적 반영 · 앱 `rec/r15`) · 선행 = ① R15c 병합(squash `__R15C_SQ__` · PR `__R15C_PR__` · 시작 기준 N = R15c 병합본 실측) ② ✅ **계약 v1.16 보강 병합(R15d 몫 G18·G19 — 아래 «■ 계약 v1.16 이름표» = v1.16 실제 글자 · `ledgerLines` nullable · 로그인 전 표본 · ✅ PR #96 squash `dd9e162` · 2026-11-03 · CI 3/3 · 가지 `m2/v116-r15` `aaefdbc` → rebase head `fc97ff4` · R15a 와 같은 PR · ✅ 발주자 결정 2026-11-03)** ③ ✅ **V-01 클레임 창구 = 결정 ③**(뷰어(iOS) 빌드에는 `SettingsActions` 가 주입되지 않는다 — 화면 카드 + 뷰어 주입 읽기 창구 `PairingRepository.watchPairing()`(`repositories/pairing_repository.dart`) · 스캔·클레임·토큰 저장 = 플랫폼 몫(조립 앱 · 06 M4-11) · 01 §8 미결 13 창구 ✅ · 뷰어 원천 구현 = 미결 156) ④ ✅ **X1 계획·비상 경로 라우트 = 결정 ③**(R-01 분기 목적지 · 🔒 X1 마법사 = Claude 소유 · 두 라우트 `aaq://x1/migration/plan`(`AppRoutes.x1MigrationPlan`) · `aaq://x1/migration/emergency`(`AppRoutes.x1MigrationEmergency`) · `AppRoutes.all` 등록 · 🔴 이 카드는 상수를 쓰지 않는다 — 링크는 데이터) ⑤ ✅ 누적 드라이런 4번째 + ✅ 재드라이런 4(2026-11-03 · v1.16 실물 위 · 가지 `dry/r15v2-4` `cf56c86` · 지적 반영 확인 `dry/r15v2-4b` `5f4043a` · 아래 «드라이런» 줄 · 앞 카드 병합본에 기대는 값만 꺾쇠 자리) ⑥ ✅ 발주자 확인 ①~⑪ 확정 ⑦ ⬜ 「푸시해」. ✅ **순서대로(결정 ①)** — 후순위 0(v1.16 이 V-01 창구·X1 두 라우트를 실었다) · «정확히 N» = 이 카드 · 🔴 Bob 의 R15a~R15c 브랜치는 건드리지 않는다.
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(🔀 4분할) + §3-0 + §3 공통 조문 + 이월 부록 «R15» 대상(R15a «6» 과 같은 표) · 화면 몫 원본 = `04_…` §9-6(`R-01` · 1) 복구 카드 로그인 2) 기기 원장 요약 3) 분기 — 차례 · «3)에서 역할 끝» · 초기화 선택지 0 · 갭 7일 = 뷰모델 · 그림 21) · §9-7(`V-01` · QR → 클레임 → 결과 · 수동 입력 0 · 실패 = 코드+문구 · 그림 22) · §9-8(게이트 3상 — 리스·기기 원장 = 있음/없음/모름 · 모름 = 진행 차단) · §2-5(R-01 = Android · V-01 = iOS) · `01_…` §8 미결 13 · §4-3 · 05 §3 `S06`(발급·폐기 = M9 — 읽기만) · 판독 메모 §5-1 G18·G19.
> 사전 조건 — ⬜ **R15c 병합**(`ui_shell` = lib 17파일 · 라벨 37 · 배럴 14 · 주입 18 · PNG 62 — 병합본 실측으로 채움) · ⬜ 계약 v1.16 병합(R15d 몫 포함) · ✅ V-01 클레임 창구 · X1 라우트(결정 ③). 시작 기준 = **⟦실측: R15c 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 315(R15b·R15c 지적 반영 계획 · 첫 판 308 · 재드라이런 4 «00:23 +315»)⟧** · 끝 기대 = N + **40**(뷰 32 = `onboarding_restart_test` 20 + `viewer_pairing_test` 12 · 골든 8 = `r01_*` 4 + `v01_*` 4 · 🆕 첫 판 38 → 지적 반영 +2 = R01-02 gap7(block) · R01-06 logged_out_no_builder 계열) · 끝 = ⟦실측: 앞 카드 병합 기록 때 채움 — 드라이런 기대 «+355»(첫 판 308 → «+346» · 재드라이런 4 «00:20 +355»)⟧.
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **18**(`onboarding_restart_test` 9 · `viewer_pairing_test` 7 · 골든 2 — 드라이런 실측) · lib **+249**(드라이런 첫 판 · `onboarding_restart.dart` 123 · `viewer_pairing.dart` 115 · `shell_providers.dart` +9 · `ui_shell.dart` +2) · 새 PNG **8** · 원천 **2**(`watchRestart` · `watchPairing`) → 임계 안 · 🔴 이 카드가 «정확히 N» 을 **소유**한다(R15 마지막 — 라벨 37 · 배럴 16 · 주입 19 · PNG 70 · 드라이런 T13~T15 · T37 확인).
> 카드 기본값(✅ 발주자 확인 ①~⑪ 확정): ⓐ 위젯 = `OnboardingRestart({super.key})`(`lib/src/onboarding/onboarding_restart.dart` · `ConsumerWidget` · Android) · `ViewerPairing({super.key})`(`lib/src/onboarding/viewer_pairing.dart` · `ConsumerWidget` · iOS 뷰어) ⓑ 셸·R15a~R15c 파일 무변경(셸 가드 무변경 — 04 §2-5 의 «iOS = V-01 만» 은 조립 앱 레지스트리가 지킨다 · 미결 127) ⓒ R-01 원천 = 🆕 `watchRestart()` → `RestartVm` · 쓰기 0 — ① 로그인 = 🔒 슬롯(매직링크/OTP · 플랫폼 · R15b 슬롯 빌더) · ② 기기 원장 요약 = 엔진 글자 줄(🆕 로그인 전 = null = 부재) · 리스 게이트(`GateBadge` 3상 — 모름 = 진행 차단 모양) · ③ 분기 = 엔진이 고른 `LinkAction` 목록(기존 · 계획 QR `aaq://x1/migration/plan` · 비상 `…/emergency` · 갭 7일 «신규 온보딩 + 잔고 승계» `aaq://onboarding/mode`) → 링크로 넘기고 역할 끝 · 승계 고지(킬스위치·차단 플래그 = 활성 승계 · 엔진 글자) ⓓ V-01 원천 = 🆕 `PairingRepository.watchPairing()` → `PairingVm`(뷰어 주입 🆕 `shellPairingRepositoryProvider`) · 스캔·클레임 = 🔒 슬롯(카메라 · 플랫폼) · 결과 = `level` 아이콘 + `headline` + `reasonCode`(원문) + `nextLink?`(링크) · 수동 입력 0 ⓔ 🔴 «초기화»·«새로 시작» 류 선택지 0(엔진이 갭 7일 갈래를 줄 때만 그 글자) · 갭 일수로 분기 0 · «일단 진행» 0 ⓕ 새 lib 파일 2 · 공용 3(배럴 +2 · `shell_providers.dart` 끝 절 주입 1 · `test/shell_fakes.dart` 끝 절) · 라벨 0 · Key 접두 `r01-`·`v01-` · 골든 4이름 8장(`r01_lost_phone` · `r01_gap7` · `v01_ok` · `v01_fail`).
> 🔴 **카드 덮개 필수 문장(04 §9-6 · §9-7 · §9-8 · prompt_M8 145~152)** — «R-01 = 로그인 자리 → 기기 원장 요약 → 엔진이 준 분기 링크(차례 · 로그인 전엔 원장·분기 0 — 데이터가 null·빈 목록) — 3)에서 역할 끝(X1 마법사·검증·DRY_RUN·LIVE = 🔒 Claude · 라우트로 넘기기만)» · «분기 = 데이터(갭 일수로 화면이 고르지 않는다) · 초기화 선택지 0 · 킬스위치·차단 플래그 = 활성 승계(엔진 글자)» · «리스·기기 원장 게이트 3상 — 모름 = 진행 차단 모양 · 해당 없음과 다른 모양 · «일단 진행» 0» · «V-01 = 스캔 자리 → 결과(코드 + 문구 원문) — URL·키 수동 입력·소유자 로그인 폼 0 · 발급·폐기 = M9» · «셸·R15a~R15c 파일·테스트·PNG 무변경».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 결정 9e(조회 전용 폰 = QR 페어링 · role=viewer 클레임 토큰) · 01 §2-1 `GateState.unknown` · X1 계획/비상 경로(🔒 Claude).
> ✅ **확정(2026-11-03 · 발주자 · ① 4분할 + v1.16 선행 + 플랫폼 몫 화면 밖 · ② whereText 글자만 · 체크섬 = M9 슬롯(04 정정) · ③ 미결 120·32 · V-01 PairingRepository · X1 라우트 등록 · ④ 나머지 권고대로)** — 발주자 확인 11건(아래 권고 = 확정 글자 · 🆕 2026-11-03 지적으로 ①②④⑥⑦ 고침 · ⑪ 신설 · «대안» = 기각 기록) — ① R-01 원천 = 🆕 `watchRestart()` → `RestartVm{headline, loginSlotId?, ledgerLines?, leaseGate?, branches, inheritNotice?}`(04 §9-6 1)~3) · 🆕 `ledgerLines` nullable = 로그인 전 null — 1)→2)→3) 이 차례라 로그인 전엔 원장을 읽을 수 없다 · 표본 `m8/restart_vm_logged_out` · 명세 지적) · 표본 `m8/restart_lost_phone`(단계 6행 + 묶이지 않은 `lease_notice`)은 쓰지 않는다 · 코어 `onboarding_reconnect` 단계 목록은 R15b `OnboardingStepList` 가 갈래 무관으로 그린다 ② 분기 = `LinkAction` 목록(기존 · R15c ⑥ 단계 link 와 같은 타입) — 목적지 = ✅ v1.16 두 라우트(표본 `aaq://x1/migration/plan` · `aaq://x1/migration/emergency`) · 갭 7일 «신규 온보딩 + 잔고 승계» = 엔진이 고른 한 갈래(표본 `aaq://onboarding/mode`) · ✅ v1.16 반영: 표본 링크 = `AppRoutes.all` 등록 목적지(C-33 ①) ③ `DeviceAccessVm`(M9 `S06` · 로그인 뒤)은 R-01 이 쓰지 않는다(원천 = `RestartVm.ledgerLines`) ④ 리스 게이트 = `GateBadge?` 4값 전수(모름 = 차단 모양 · 엔진이 그때 `branches` 를 비운다) · 🆕 표본 3상 = lostPhone pass · gap7 block · unknown unknown(감사 지적 — 조립 판 표본은 둘뿐 · ✅ v1.16 표본 그대로) ⑤ ① 로그인 = 🔒 슬롯(`loginSlotId` · 매직링크/OTP = 플랫폼 — `supabase_flutter` 금지 · 조립 앱 · 로그인 끝 = null) ⑥ V-01 원천 = 🆕 `PairingRepository.watchPairing()` → `PairingVm{headline, scannerSlotId?, result?}` · `PairingResult{level, headline, reasonCode?, nextLink?}` · 주입 🆕 `shellPairingRepositoryProvider`(뷰어 빌드 = 구현 · 폰 빌드 = 구현 또는 미사용) · 스캔·클레임·토큰 저장 = 플랫폼(조립 앱 · 06 M4-11 · 01 §8 미결 13 창구 ✅) — ✅ 결정 ③ 화면 카드(대안 «V-01 전부 조립 앱» = 기각) ⑦ 폐기된 토큰 = 엔진이 `result.level`·`reasonCode` 로(«즉시 차단» — 화면 판정 0 · ✅ v1.16 반영: 폐기 토큰 사유 코드 `PAIRING_TOKEN_REVOKED`(OnboardingResultCodes · C-5) · 드라이런 지적) ⑧ 정적 라벨 0(분기·결과·다음 글자 = 엔진) ⑨ 골든 4이름 8장(04 에 이름 없음 · 카드가 지음) ⑩ «정확히 N» 소유 = 이 카드(라벨 37 · 배럴 16 · 주입 19 · PNG 70 · golden README 장수) — ✅ 결정 ① 순서대로(미루지 않는다) ⑪ 🆕 «다음» = `result.nextLink` 데이터만(드라이런 참고 RF6b «ok 일 때만 다음» = 표본 동치 — ok 만 nextLink 를 가진다) · 대안 «v1.16 표본에 level watch/info + nextLink 하나 더» = 미채택(v1.16 V-01 표본 3벌 그대로 · RF6b = 참고).
> 🚫 **플랫폼 몫 = 화면 밖** — Auth 매직링크/OTP 로그인(R-01 ①) · QR 카메라 스캔·토큰 클레임·저장(V-01 · 06 M4-11) · X1 마법사(🔒 Claude) · 기기 epoch·TTL 대기(엔진) · iOS/Android 진입 가드(조립 앱).
> 드라이런: ✅ 누적 드라이런 4번째(2026-11-03 · 가지 `dry/r15-4` = R15c 드라이런 끝 `20e6a60` → R15c 병합 기록 흉내 `7b123a5` → v1.16 R15d 몫 흉내 `3d5d426`(RestartVm · PairingVm · PairingResult · `pairing_repository.dart` · `watchRestart` · `UnimplementedPairingRepository` · 표본 6 · 링크 = 기존 라우트 · 코드 = C-5 등재 코드) → 권장 4커밋 `dec604f`·`e595180`·`0aab3c4`·`21bdbfb`) · 시작 «+308» → 끝 «+346»(`onboarding_restart_test` +18 · `viewer_pairing_test` +12 · `r01_golden` +4 · `v01_golden` +4) · 정적 34줄(요지로 지은 판 · T08·T12·T28 없음 — 출력 155줄 · EXIT:1 19 · EXIT:0 15 · T13 37 · T14 16 · T15 19 · T37 70 «정확히» 확인) · 사전검사 ① 🔴 0 · 🟡 0 · ② `r01_` 🟡 4 · `v01_` 🟡 4(전부 G1 — 버튼을 «상자» 로 읽음) · 골든 dy 4(light = dark · 844 안) · lib +249 · ⓡ restart 8 · pairing 5 · ⓗ 1 · 0 · (전제) 9 · 7 · 막힌 곳 3(정적 요지판 · ⓡ 계획 6 ↔ 목록 8 · G1 🟡 기대 빈칸) · 변이 51꼴(예고 31 · 참고 18 · 테스트 쪽 2) = KILLED 50 · SURVIVED 1(참고 RF6b — 표본 동치 · ⑪) · 🔵 흉내 = 조립 판 이름표 글자(`OnboardingLinkAction{label, link}` · `PairingResult.next` · `ledgerLines` required · 표본 글자도 v1.16 실물과 다르다 — gap7 = 승계 고지 있음 · 실물 = 설계서 §5-4) · 🆕 ✅ **재드라이런 4**(2026-11-03 · base `dry/r15v2-4-base` `039ee51` = R15c 재드라이런 끝 `8c62a3b` + R15c 병합 기록 흉내 · 가지 `dry/r15v2-4` = `4f09acd`·`ab900c5`·`da2e44a`·`cf56c86` · (5) 없음) — 지적 반영(로그인 전 표본 · gap7 block · 버튼 수 단언 · V01-07 ⓡ)을 v1.16 실물로 확인 · 0단계 기대 21줄 그대로 · 315 → «+355»(+20 · +12 · +4 · +4) · 정적 34줄(`bafe5b9` 판 141~174 · hash `fbbcea7`) 출력 155줄(EXIT:1 19 · EXIT:0 15 · T13 37 · T14 16 · T15 19 · T37 70 «정확히» 확인) · lib +249 · ⓡ 8·6 · ⓗ 1·0 · (전제) 9·7 · 사전검사 ① 🔴 0 · 🟡 0 · ② `r01_` 🟡 4 · `v01_` 🟡 4 · 골든 dy = 340.0 · 304.0 · 136.0 · 184.0(light = dark · 잘림 0) · 변이 = 예고 40 전부 KILLED(M03b·M03c «갭 7일 갈래 더하기» = 골든 r01_gap7 만 → 🆕 R01-09 버튼 수 단언으로 뷰 테스트 KILLED · `dry/r15v2-4b` `5f4043a`) · 참고 23 KILLED 20 · SURVIVED 3(RF6b·RF6c·RF6d = 표본 동치) · 테스트 쪽 TF1 = T1 🔴 · TF2b = T3 🔴 · TF4 = T2 🔴 · TF5 = T35 · TF2 늘 참 find.byType · TF3 nullable 흐름 칸 + if = 사전검사 🔴 0 → «5» C4 사람 grep · 카드↔수 어긋남 = 골든 dy(lostPhone 404.0 흉내 → 340.0) · (전제) 나눔 글자 0 → 테스트 줄마다 적음.
> 프롬프트 = `prompt_M8.md`(v2 판 183줄). 🔴 Bob **새 대화** 전제. 교훈 반영 = R15a 머리 줄과 같다(PNG 열람 4장 · ⟦펼침: send/ 승격 때 R15a 머리 «교훈 반영» 줄 글자 그대로⟧).

## 0. 한 줄 목적

`OnboardingRestart()` 가 `watchRestart()` 의 `RestartVm`(로그인 자리 · 기기 원장 요약 · 리스 게이트 3상 · 엔진이 고른 분기 링크 · 승계 고지 — 받은 차례·null 여부 그대로)을 그리고 분기 탭은 링크로만 넘기며(초기화 0 · 갭 일수 판정 0), `ViewerPairing()` 이 `watchPairing()` 의 스캔 자리와 결과(코드 + 문구 원문 · 다음 링크)만 그리는(수동 입력 0) `R-01`·`V-01` 을 계약 v1.16 그대로 짓고, R15 공용 파일의 «정확히 N» 을 닫기.

## 1. 어디에 보내나

**IBM Bob** — 새 브랜치 **`ui/m8-r01-restart`**(base = 최신 `origin/main` · `--no-track`) · PR 제목 = «[M8] R-01·V-01 다시 시작·조회 전용 페어링».

## 2. 보내기 전에 발주자가 할 것 🔴

1. `send/` 바로 아래 · 머리 첫 줄 ▶ 일 때만(지금 `_대기/`). 2. Bob **새 대화**. 3. GitHub `main` — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R15d-Bob-R01V01.md>. 4. «3» 본문 전부. 5. 🔴 `_완료/R15a~R15c*` 를 붙여넣지 않습니다. 6. 받는 법 = R15a 와 같다(`$env:TEMP\R15d-Bob-R01V01_submit.md` · BOM 0 · 채팅 두 줄). 7. `flutter_tester` 를 직접 끝내지 마세요.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R15d-Bob-R01V01 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R15d-Bob-R01V01 — 범위: R-01 기존 계정에서 다시 시작(OnboardingRestart() — 머리 · 로그인 🔒 자리 · 기기 원장 요약 줄 · 리스 게이트 · 분기 링크 · 승계 고지) ·
  V-01 조회 전용 QR 페어링(ViewerPairing() — 머리 · 스캔 🔒 자리 · 결과(아이콘 · 문구 · 원문 코드 · 다음 링크)) + 새 주입 1 + 배럴 export 2줄 + 가짜 끝 절 · 🔴 «정확히 N» 소유(R15 마지막).
🔴 R-01 = 1) 로그인 → 2) 원장 → 3) 분기 차례 · 3)에서 역할 끝 — 분기 = 엔진이 준 링크 목록 · 갭 일수로 화면이 고르지 않는다 · 초기화·새로 시작 선택지 0 · X1 마법사·검증·DRY_RUN = 이 카드 밖(라우트로 넘기기만).
🔴 리스·기기 원장 게이트 3상 — 모름 = 진행 차단 모양 · 해당 없음과 다른 모양 · «일단 진행» 0 · 킬스위치·차단 플래그 = 활성 승계(엔진 글자).
🔴 V-01 = 스캔 자리 + 결과 원문 — URL·키 수동 입력·소유자 로그인 폼 0 · 폐기·실패 판정 = 엔진(level · reasonCode) · 발급·폐기 버튼 0(M9).
🔴 셸·R15a~R15c 파일·테스트·PNG 무변경 · 로그인·스캔·클레임·토큰 저장 = 플랫폼(슬롯).
하지 않는 것: O-00~O-04(병합됨) · X1 마법사(🔒) · S06 기기 관리(M9) · DeviceAccessVm · 매직링크/OTP · 카메라 · supabase_flutter · 새 라벨 · domain_contracts·pubspec 수정 · 다른 ui_*.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 15항).

■ 0단계 — 대상 확인
이 카드는 R15a~R15c(병합됨)가 아닙니다. 지금 코드에는 lib/src/onboarding/onboarding_restart.dart · viewer_pairing.dart 가 없습니다.
  git branch --show-current · git status --short(빈) · git fetch origin --prune · git checkout --no-track -b ui/m8-r01-restart origin/main
  git grep -c "contractVersion = '1.16.0'" -- packages/domain_contracts/lib/src/contract_version.dart   ← «…contract_version.dart:1»(계약 v1.16 · PR #96 dd9e162 병합본 실측 «:1» 2026-11-03 · 🔵 엔진 레인이 그 뒤 올렸으면 앞 카드 병합 기록 때 다시 잰다 · 감사 지적 — R15a·R15b 꼴)
  git grep -c "Stream<RestartVm> watchRestart();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart   ← «…:1»(v1.16)
  git grep -c "Stream<RestartVm> watchRestart()" -- packages/domain_contracts/lib/testing.dart   ← «…:1»(v1.16 받침대 UnimplementedOnboardingRepository · 🆕 감사 지적)
  git grep -c "Stream<PairingVm> watchPairing();" -- packages/domain_contracts/lib/src/repositories   ← «…repositories/pairing_repository.dart:1»(v1.16)
  git grep -c "abstract class RestartVm" -- packages/domain_contracts/lib · git grep -c "abstract class PairingVm" -- packages/domain_contracts/lib · git grep -c "abstract class PairingResult" -- packages/domain_contracts/lib   ← 각 «…lib/src/dto/onboarding.dart:1»(v1.16)
  git grep -c "List<String>? ledgerLines," -- packages/domain_contracts/lib   ← «…lib/src/dto/onboarding.dart:1»(v1.16 · 🆕 로그인 전 null)
  git grep -c "class UnimplementedPairingRepository" -- packages/domain_contracts/lib/testing.dart   ← «…:1»(v1.16)
  git grep -c "static const String m8RestartVmLostPhone =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← «…:1»(v1.16)
  git grep -c "class OnboardingFinish" -- packages/ui_shell/lib/src/onboarding/onboarding_finish.dart   ← «…:1»(R15c 병합)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md
  ls docs/ai-context/send/R15d-Bob-R01V01.md · ls docs/ai-context/inbox/R01V01_questions.md · ls packages/domain_contracts/fixtures/m8/restart_vm_lost_phone.json · restart_vm_logged_out.json · restart_vm_gap7.json · restart_vm_unknown.json · pairing_waiting.json · pairing_ok.json · pairing_fail.json   ← 전부 보여야 함(한 줄에 하나)
  반대(없어야 함): ls packages/ui_shell/lib/src/onboarding/onboarding_restart.dart · git grep -c ViewerPairing -- packages/ui_shell/lib
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 ⟦실측: 앞 카드 병합 기록 때 채움 — R15c 병합본 «+315: All tests passed!»(드라이런 기대 · 재드라이런 4 315)⟧ → cd ../..

■ 계약 v1.16 이름표 — R15d 몫(🔴 코드가 정본 · ✅ v1.16 실제 글자 = 설계서 §4 · 01 §25 · 파일 = dto/onboarding.dart · repositories/pairing_repository.dart)
  🆕 RestartVm({required String headline, String? loginSlotId, List<String>? ledgerLines, GateBadge? leaseGate, required List<LinkAction> branches, String? inheritNotice})
       — loginSlotId = ① 복구 카드 로그인 자리(플랫폼 · null = 이미 로그인) · ledgerLines = ② 구 폰 라벨·마지막 접속·리스 잔여(엔진 글자 · 🆕 null = 로그인 전 — 원장을 아직 못 읽음) · leaseGate = 리스·기기 원장 3상 · branches = ③ 엔진이 고른 분기(모름·로그인 전이면 0) · inheritNotice = 킬스위치·차단 플래그 승계 고지
  🆕 PairingVm({required String headline, String? scannerSlotId, PairingResult? result}) · 🆕 PairingResult({required UiLevel level, required String headline, String? reasonCode, LinkAction? nextLink})
  🆕 PairingRepository { Stream<PairingVm> watchPairing(); }(뷰어 주입 · 클레임 = 플랫폼이 하고 결과를 이 스트림에 싣는다 · v1.16 · 01 §8 미결 13 창구 ✅ · 156) · OnboardingRepository += Stream<RestartVm> watchRestart();
  LinkAction{label, deepLink} · GateBadge · UiLevel(기존 · dto/common.dart · enums/ui.dart) · testing.dart = UnimplementedPairingRepository(🆕) · UnimplementedOnboardingRepository(watchRestart 포함)
  FixturePaths  m8RestartVmLostPhone(loginSlotId null · ledgerLines 3 · branches 2 — 계획 QR `aaq://x1/migration/plan` · 비상 `…/emergency` · leaseGate pass · inheritNotice non-null) · 🆕 m8RestartVmLoggedOut(loginSlotId `RECOVERY_LOGIN` · ledgerLines null · leaseGate null · branches 0 · inheritNotice null) ·
                m8RestartVmGap7(branches 1 — 신규 온보딩 + 잔고 승계 `aaq://onboarding/mode` · 🆕 leaseGate block · inheritNotice non-null) · m8RestartVmUnknown(leaseGate unknown · branches 0 · inheritNotice null) ·
                m8PairingWaiting(result null · scannerSlotId `VIEWER_QR_SCAN`) · m8PairingOk(scannerSlotId null · result level ok · nextLink non-null `aaq://holdings/overview`) · m8PairingFail(scannerSlotId non-null · result level blocked · reasonCode `PAIRING_TOKEN_REVOKED`(폐기 토큰) · nextLink null)
  ✅ v1.16 반영(드라이런 지적): X1 계획·비상 두 라우트 `AppRoutes.all`(64 · 분기 표본 링크 C-33 ① 통과) · 폐기 토큰 사유 코드 `PAIRING_TOKEN_REVOKED` 등재(C-5) · `pairing_repository.dart` export(repositories.dart 배럴) · `dart format` 0 changed.
  🔴 쓰지 않는 것: m8/restart_lost_phone(단계 6행 + lease_notice) · onboarding_reconnect · DeviceAccessVm · SettingsActions · AppRoutes.x1Migration·x1MigrationPlan·x1MigrationEmergency(링크 = 데이터).

■ 규칙 요약 (정본 = 이 카드 · «= R15a 규칙 n» 의 글자는 docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3» · ⟦펼침: send/ 승격 때 «= R15a» 자리를 R14b 처럼 전부 펼친다 — 감사 지적⟧)
 1 고치는 곳 = packages/ui_shell + inbox/R01V01_questions.md 만. 새 파일 = lib/src/onboarding/onboarding_restart.dart · viewer_pairing.dart · test/onboarding_restart_test.dart · test/viewer_pairing_test.dart · test/golden/r01_golden_test.dart · v01_golden_test.dart · 새 PNG 8.
   공용 3파일 끝 절 더하기만: lib/src/shell_providers.dart 끝 R15d 절(🆕 final Provider<PairingRepository> shellPairingRepositoryProvider · throw 기본값) · lib/ui_shell.dart export 두 줄(정렬 차례 — src/onboarding/onboarding_restart.dart 는 onboarding_mode_pick 뒤 · src/onboarding/viewer_pairing.dart 는 onboarding_step_list 뒤 · src/ops_home.dart 앞) · test/shell_fakes.dart 끝 R15d 절.
   고치면 반려: 그 밖 ui_shell 파일 전부 · domain_contracts/** · apps/** · 다른 ui_*.
 2 ⟦펼침: R15a 규칙 2⟧ = R15a 규칙 2(값 = headline · ledgerLines · leaseGate.label · branches[i].label · inheritNotice · result.headline · reasonCode 원문 · nextLink.label · 리터럴 0).
 3 읽지 않는 필드: LinkAction.deepLink(🔴 open 인자로만) · loginSlotId·scannerSlotId(빌더 인자로만) · GateBadge.code · blockedReasonCode.
 4 이동 = AppLinkOpener.open(link) — 링크 = branches[i].deepLink · result.nextLink.deepLink 둘뿐 · 'aaq://' 리터럴 0 · AppRoutes 0(x1Migration·x1MigrationPlan·x1MigrationEmergency 포함).
 5 산술·판정 0 — 허용 = null 여부 · GateState 4값 · UiLevel 5값 전수 switch · 순번 · 🔴 branches 를 고르거나·세거나·«0 이면 문장» 0(빈 = 아무것도 그리지 않음 — 이유는 leaseGate 가 말한다) · 🆕 «로그인 자리가 있으면 원장·분기 숨기기» 0(데이터가 null·빈 목록으로 온다) · 갭 일수·시각 계산 0.
 6 switch = GateState 4(_gateLook — R15b 글자) · UiLevel 5(_resultLook — R15b 글자) · 둘뿐. 7·8 ⟦펼침: R15a 규칙 7·8⟧ = R15a 규칙 7·8. 9 새 주입 1 · 데이터 2(_restartProvider · _pairingProvider) · 탭 안 ref.read.
10 ⟦펼침: R15a 규칙 10 전문⟧ = R15a 규칙 10(⓪ 경우 for 밖 · 흐름 칸 non-null · name 칸 · 부재 = 데이터 · ⓡ·ⓗ = T20·T21 — restart_test ⓡ 8 · ⓗ 1 · pairing_test ⓡ 6 · ⓗ 0 · 🔴 정확히(🆕 감사·드라이런 지적 — 조립 판 «ⓡ 6» 은 목록 표시 8 과 어긋났다 · V01-07 에 ⓡ 를 더했다) · (전제) = 9 · 7(재드라이런 4 실측 · 🔴 정확히 · 나눔 = 아래 최소 목록 테스트 줄마다 — 첫 판도 합은 9 · 7 이나 나눔이 달랐다)) · 🔒 자리 = R15b FakeShellSlotRecorder(새 가짜 0).
11 골든 = 새 PNG r01_* 4 · v01_* 4 · 높이 844 고정 · 기존 PNG 62장 재생성 0. 12~14 ⟦펼침: R15a 규칙 12~14⟧ = R15a 규칙 12~14.
15 주석 금지 낱말: x1Migration · AppRoutes · DeviceAccessVm · SettingsActions · supabase · camera · token · password · TextField · 초기화 · 새로 시작 · 일단 · DateTime.now · Duration · 추천 · 권유 · 자문 · 시그널 · 해외.
🔴 보고 규칙 ⟦펼침: R15a «보고 규칙» 전문⟧ = R15a «보고 규칙»(PNG 열람 4장 · S05 기대 2줄 · 🆕 사전검사 G1 은 FilledButton.tonal·FilledButton 을 «상자(안 글자 n줄)» 로 읽고 이어진 글자 덩어리를 합친다 — 표 칸은 이 카드 단위(«버튼 글자») 그대로 · 드라이런 기대 🟡 = r01_ 4 · v01_ 4 = 8(r01_lost_phone·r01_gap7·v01_ok light·dark = G1 이 버튼을 상자로 읽음 · 🆕 v01_fail light·dark = G1 이 원문 코드 줄을 글자로 세지 않는다(표 «글자 4줄» ↔ PNG «글자 2줄» · 재드라이런 4) — 둘 다 그대로 · 다시 열지 않음 · C4r5b-4 꼴)).

■ 프롬프트보다 이 카드가 이긴다 — 15항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 범위 → R-01 · V-01 ② 113~118행 → 이 카드 = R-01 · V-01 · O-00~O-04 = R15a~R15c(병합됨) ③ 12~13행 → 추가 0 ④ 15~19행 링크 = 데이터 → 그대로(분기 · 다음) ⑤ 20~23행 → 그대로(갭 일수·리스 잔여 = 엔진 글자)
 ⑥ 24~31행 → 그대로 ⑦ 32~35행 → 라벨 0 ⑧ 36~38행 → 그대로(빈 분기 = 그리지 않음) ⑨ 41~47행 → 그대로(🔒 X1 마법사 · 킬스위치 = 승계 고지 글자만) ⑩ 48~57행 → 그대로
 ⑪ 106~111행 → inbox/R01V01_questions.md ⑫ 127~128행 → ui/m8-r01-restart · «[M8] R-01·V-01 다시 시작·조회 전용 페어링» ⑬ 145~150행 → 그대로(로그인·스캔 = 자리 · 수동 입력 0) ⑭ 151~152행 → 그대로(결과 = headline + reasonCode 원문) ⑮ 172~182행 → ■ 제출 ② 상자 + 괄호

■ 먼저 읽을 것 — ① prompt_M8.md ② 04 §9-6 · §9-7 · §9-8 · §2-5 ③ 01 §8 미결 13·156 · §25(계약 v1.16) ④ domain_contracts — dto/onboarding.dart · dto/common.dart(LinkAction · GateBadge) · repositories/pairing_repository.dart · testing.dart ⑤ ui_shell — lib/src/onboarding/onboarding_step_list.dart(_gateLook) · onboarding_step_detail.dart(_resultLook · 슬롯) · onboarding_finish.dart(링크 동작) — 읽기만 ⑥ ⟦펼침: 승격 때 이 줄을 지운다⟧ _완료/R15a «3» ⑦ inbox/R01V01_questions.md 머리말

■ 본받지 않는 것
 · m8/restart_lost_phone 의 단계 행·lease_notice 를 R-01 에 그리기 · DeviceAccessVm 쓰기 · 갭 7일을 화면이 세어 «신규 온보딩» 버튼 · «초기화하고 새로 시작» · leaseGate unknown 인데 분기 버튼 · «일단 진행» · 로그인 전 원장 자리를 빈 상자로 · 분기 옆 «건너뛰기» TextButton
 · URL·키·코드 수동 입력 칸 · 소유자 로그인 폼 · 스캔 버튼을 화면이 직접(카메라) · 폐기 토큰을 화면이 판정 · «ok 일 때만 다음» · 발급·폐기 버튼 · x1Migration 상수로 이동

■ 주입 구조 — onboarding_restart.dart = OnboardingRestart(공개 · ConsumerWidget) · _restartProvider · _gateLook / viewer_pairing.dart = ViewerPairing(공개 · ConsumerWidget) · _pairingProvider · _resultLook · 🆕 shell_providers.dart 끝 R15d 절 = shellPairingRepositoryProvider · 배럴 두 줄 ·
  import 차례 = R15a 와 같다(StepState 를 쓰지 않아 hide 0) · 🆕 테스트 import = 'dart:async'(MultiStreamController) → domain_contracts.dart → 'package:domain_contracts/testing.dart'(RecordingLinkOpener) → material → flutter_riverpod → flutter_test → ui_shell.dart → golden/golden_support.dart → shell_fakes.dart(드라이런 지적 — 두 줄이 없어 첫 실행이 컴파일 실패).

■ 호출 표 — R-01: watchRestart() 한 번(재시도 = 한 번 더) · 슬롯 빌더(loginSlotId) · shellLinkOpenerProvider(분기 탭 안) · 부르지 않는 것: SettingsActions · watchStepList · watchPairing. V-01: watchPairing() 한 번 · 슬롯 빌더(scannerSlotId) · shellLinkOpenerProvider(«다음» 탭 안) · 부르지 않는 것: OnboardingRepository · SettingsActions.

■ 상태 표 — restart: hasError → ShellErrorView(key: const Key('r01-fail'), …) · 값 전 → ShellSkeleton(key: const Key('r01-loading')) · pairing: Key('v01-fail') · Key('v01-loading').

■ 화면 1 — R-01: 머리 Padding(key: const Key('r01-headline')) → (loginSlotId && builder) Padding(key: const Key('r01-login'), builder(id)) → 🆕 (ledger != null) Padding(key: const Key('r01-ledger'), Column[ for line Text(line) ])(final List<String>? ledger = vm.ledgerLines;) → (gate) Row(key: const Key('r01-gate'))[ Icon(_gateLook) · Flexible(Text(gate.label)) ] →
   for (i, b) in branches.indexed FilledButton.tonal(key: ValueKey<String>('r01-branch-$i'), onPressed: () { open(b.deepLink); }, child: Text(b.label)) → (inherit) Padding(key: const Key('r01-inherit'), Text(inherit))
 ■ 화면 2 — V-01: 머리 Padding(key: const Key('v01-headline')) → (scannerSlotId && builder) Padding(key: const Key('v01-scanner'), builder(id)) → (result) Padding(key: const Key('v01-result'), Column[ Row[ Icon(_resultLook, key: const Key('v01-level')) · Expanded(Text(r.headline)) ] · (code) Text(code) ]) →
   (next) FilledButton(key: const Key('v01-next'), onPressed: () { open(next.deepLink); }, child: Text(next.label))(final LinkAction? next = r.nextLink;)

■ Key 표 (r01- 8 · v01- 7 = 15 — 🆕 감사·드라이런 지적으로 머리 수 고침) — r01-loading · r01-fail · r01-headline · r01-login · r01-ledger · r01-gate · r01-branch-$i · r01-inherit · v01-loading · v01-fail · v01-headline · v01-scanner · v01-result · v01-level · v01-next

■ 할 일 — (1) lib 두 파일 + shell_providers R15d 절 + 배럴 «[M8] R15d (1) R-01·V-01 화면» (2) fakes 끝 절 + 두 테스트 «[M8] R15d (2) R-01·V-01 테스트»
 (3) 골든 8장 «[M8] R15d (3) 골든 r01_* 4장 · v01_* 4장» (4) format · 질문(A1~A4 dy) «[M8] R15d (4) format · 질문».

■ 정적 라벨 — 0개(🔴 labels.dart 무변경 · 총수 «정확히» 37 = 정적 T13).

■ 테스트 최소 목록 (드라이런 첫 판 실측 + 지적 반영 · ✅ 수 = 재드라이런 4 가 «정확히» 로 확정 · 2026-11-03)
 🆕 공통(드라이런 글자 · 이 이름 그대로): test/shell_fakes.dart 끝 절 «// ── R15d — R-01·V-01 fakes ──» = class FakeShellRestartRepository extends UnimplementedOnboardingRepository(restart 공장 · restartCalls) · class FakeShellPairingRepository extends UnimplementedPairingRepository(pairing 공장 · pairingCalls) ·
   List<Override> restartOverrides({repo, slots, opener}) · List<Override> pairingOverrides({repo, slots, opener}) · Future<void> pumpRestart / pumpPairing(WidgetTester tester, {required List<Override> overrides})(R15a pump 꼴) ·
   Set<String> restartAllowed(RestartVm v)(= headline · ...?ledgerLines · ?leaseGate?.label · branches 마다 label · ?inheritNotice) · Set<String> pairingAllowed(PairingVm v)(= headline · ?result?.headline · ?result?.reasonCode · ?result?.nextLink?.label) ·
   테스트 파일 머리(main() 밖 · 🆕 파일마다 — 재드라이런 4 지적): onboarding_restart_test = valueThenFail · wantGate(cs, GateState)(R15b 글자 사본) · firstIconIn(tester, key) / viewer_pairing_test = valueThenFail · wantResult(cs, UiLevel)(R15b 글자 사본).
 R-01 — test/onboarding_restart_test.dart(줄 9 · 테스트 20 · 🆕 (전제) 9 = R01-01 1 · 02 3 · 04 1 · 05 2 · 06 2 — 🔴 정확히 · 재드라이런 4)
 R01-01 블록 차례·글자(lostPhone · 로그인 끝) — 전제 하나(expect(lostPhone.loginSlotId, isNull); // pre) → 사슬 dy headline → ledger → gate → branch-0 → branch-1 → inherit · r01-login findsNothing · ⓗ expect(lostPhone.branches, hasLength(2)) → 분기 글자 == label ·
        🆕 expect(find.byWidgetPredicate((Widget w) => w is ButtonStyleButton), findsNWidgets(lostPhone.branches.length))(분기 밖 버튼 0 — «건너뛰기» TextButton 을 뷰 테스트가 잡는다 · 드라이런 RF7a) · ⓡ.
 R01-02 리스 게이트 3상 — 🆕 세 경우(pass · lostPhone · block · gap7 · unknown · unknown) · 전제 셋(expect(lostPhone.leaseGate?.state, GateState.pass); // pre · gap7 = GateState.block · unknown = GateState.unknown — 같은 꼴 // pre) → r01-gate 첫 Icon icon·color == wantGate(state) · 🔴 unknown 은 차단 색 · notApplicable 과 다른 아이콘(wantGate 표) · ⓡ.
 R01-03 분기 탭 = deepLink(데이터) — 세 경우(plan · emergency · gap7) → opener.opened == [link] · ⓡ.
 R01-04 모름 = 분기 0(unknown · 전제 하나(expect(unknown.branches, isEmpty); // pre) · r01-branch-0 findsNothing · 🆕 ButtonStyleButton findsNothing · 양성 기준점 r01-gate) · ⓡ.
 R01-05 승계 고지 = 데이터 — 두 경우(present · lostPhone · absent · unknown — v1.16 gap7 은 승계 고지가 있다 · unknown = inheritNotice null) · 전제 둘(expect(lostPhone.inheritNotice, isNotNull); // pre · expect(unknown.inheritNotice, isNull); // pre) · «없는 쪽» 견본(🆕 absent 양성 기준점 = Key('r01-gate') findsOneWidget — unknown 은 분기가 없어 r01-branch-0 을 쓸 수 없다 · 재드라이런 4 지적) · ⓡ.
 R01-06 로그인 자리 = 슬롯 빌더 · 🆕 차례 = 데이터 — 세 경우 ㉠ (logged_out · loggedOut · 빌더 있음 → r01-login findsOneWidget · slots.slotIds == [loggedOut.loginSlotId!] · r01-ledger findsNothing · r01-branch-0 findsNothing) ·
        (logged_out_no_builder · loggedOut · 빌더 null → r01-login findsNothing · 양성 기준점 r01-headline) · (logged_in · lostPhone · 빌더 있음 → r01-login findsNothing · slots.slotIds == [] · r01-ledger findsOneWidget)마다 — 전제 둘(loggedOut.loginSlotId non-null · loggedOut.ledgerLines null // pre) · TextField findsNothing · ⓡ(명세 지적 — 로그인 전 원장·분기 0).
 R01-07 상태 갈래 세 경우 · R01-08 재시도 · ⓡ · R01-09 화면 Text 전부 · 큰 글꼴 세 경우(lostPhone · gap7 · unknown) · 🆕 Text 대조 뒤 expect(find.byWidgetPredicate((Widget w) => w is ButtonStyleButton), findsNWidgets(c.v.branches.length)) 한 줄(세 경우 — 화면이 버튼을 더하면 뷰 테스트가 잡는다 · 재드라이런 4 M03b(엔진 글자 재사용)·M03c(원장 글자 보고 판정)는 골든 r01_gap7 만 잡았다 → `dry/r15v2-4b` `5f4043a` 에서 R01-09 gap7 KILLED · 테스트 수·ⓡ·(전제) 그대로) · ⓡ.
 V-01 — test/viewer_pairing_test.dart(줄 7 · 테스트 12 · 🆕 (전제) 7 = V01-01 2 · 02 2 · 03 2 · 04 1 — 🔴 정확히 · 재드라이런 4)
 V01-01 기다림 = 스캔 자리만(waiting · 전제 둘(expect(waiting.result, isNull); // pre · expect(waiting.scannerSlotId, isNotNull); // pre) · v01-result findsNothing · v01-next findsNothing) · ⓡ.
 V01-02 성공 = 문구 + 다음 링크(ok · 전제 둘(expect(ok.result?.nextLink, isNotNull); // pre · expect(ok.result?.reasonCode, isNull); // pre) → 🆕 Key('v01-level') 아이콘·색 == wantResult(cs, ok.result!.level) → tap v01-next → opener == [ok.result!.nextLink!.deepLink]) · ⓡ.
 V01-03 실패 = 문구 + 원문 코드 · 다음 0(fail · 전제 둘(expect(fail.result?.reasonCode, isNotNull); // pre · expect(fail.result?.nextLink, isNull); // pre) · shownTexts(v01-result) == [headline, reasonCode] · 🆕 Key('v01-level') 아이콘·색 == wantResult(cs, fail.result!.level) — 드라이런이 넣어 «level 아이콘 고정» M15a·M15b 를 잡았다) · ⓡ.
 V01-04 스캔 자리 = 슬롯 빌더 — 두 경우(빌더 있음 · null → v01-scanner findsNothing) · 전제 하나(expect(waiting.scannerSlotId, isNotNull); // pre) · TextField findsNothing · ⓡ.
 V01-05 상태 갈래 세 경우 · V01-06 재시도 · ⓡ · V01-07 화면 Text 전부 · 큰 글꼴 세 경우 · 🆕 ⓡ(감사 지적 — R15a O0B-12 꼴).
🔴 예고 변이: 분기 뒤집기 · 분기 하나 빼기 · 갭 7일 갈래를 화면이 더하기(정적 글자 · 🆕 엔진 글자 재사용 · 원장 글자 보고 판정 — R01-09 버튼 수) · unknown 에도 분기 · unknown 을 notApplicable 모양 · 초기화 버튼 더하기 · 분기 탭 0 · 다른 링크 · 승계 고지 빼기 · ledger 줄 하나 빼기 · 로그인 자리 대신 TextField ·
   🆕 로그인 전에도 원장 자리(ledgerLines null 무시 — 빈 Padding) · 분기 옆 건너뛰기 TextButton(엔진 글자 재사용) ·
   결과 headline·code 빼기 · 실패에도 다음 · 성공에 다음 0 · 결과 level 아이콘 고정(아이콘 · 색) · 스캔 자리 대신 입력 칸 · 에러를 스켈레톤 · 재시도 invalidate 0 · 정적 글자 더하기 ·
   🔵 참고 — 표본 동치: «ok 일 때만 다음»(드라이런 RF6b · ⑪) · 🆕 «로그인 자리가 있으면 원장 숨김»(재드라이런 4 RF6c — 표본 loggedOut 은 ledgerLines null) · «unknown 이면 분기 숨김»(RF6d — 표본 unknown 은 branches 빈 목록) · 드라이런 변이 표 = 첫 판 51꼴 KILLED 50 · SURVIVED 1(RF6b) · 🆕 RF7a(건너뛰기 TextButton)는 첫 판에 골든만 잡았다 → R01-01 버튼 수 단언 · 🆕 재드라이런 4(v1.16 실물) = 예고 40 전부 KILLED(M03b·M03c 는 골든만 → R01-09 버튼 수 단언으로 뷰 테스트 KILLED) · 참고 23 KILLED 20 · SURVIVED 3(RF6b·RF6c·RF6d = 표본 동치) · 테스트 쪽 8꼴(TF1 T1 🔴 · TF2b T3 🔴 · TF4 T2 🔴 + T32 · TF5 T35 · TF2·TF3 = «5» C4 사람 grep · TF6·TF7 = R01-01·R01-04 버튼 단언이 꼭 필요함).

■ 정적 묶음 — 34줄(머리 «## T01» ~ «## T37» · 🔵 T08·T12·T28 은 일부러 비운다 — 드라이런이 요지로 지은 판 · T23 «해외» 더함) · ⟦펼침: R15a 실행 꼴 6줄 — r15d_static.sh · r15d_static_out.txt · sed -n '<범위>p' · hash-object · Select-String EXIT · Count⟧ · 꺼내기 줄 범위·해시 = ⟦실측: send/ 승격(펼침) 뒤 다시 잰다 — 재드라이런 4 = `bafe5b9` 판 141~174행(34줄) · hash `fbbcea7439ceb13e963bfbcad873cd34bcfc1d1d`⟧ · 출력 줄 수 = 155줄(EXIT:1 19 · EXIT:0 15 — 재드라이런 4 실측 · v1.16 실물 위 · 첫 판·고친 34줄도 155줄):
echo "## T01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://|'https?://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T06 source lines (2)"; git grep -nE "watchRestart\(|watchPairing\(" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T07 settings actions 0"; git grep -nE "SettingsActions" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T09 GateState UiLevel arms (4 5)"; git grep -nE "GateState\.(pass|block|notApplicable|unknown)|UiLevel\.(ok|info|watch|act|blocked)" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T10 slot builder lines (2)"; git grep -n "shellOnboardingSlotBuilderProvider" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T11 forbidden words in new files 0"; git grep -nE "x1Migration|AppRoutes|DeviceAccessVm|SettingsActions|DateTime\.now|Duration\(|\.length|\.where\(|\.sort|\.take\(|\.isEmpty|\.isNotEmpty|TextField|supabase|camera|[Tt]oken|password|print\(" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T13 shell labels (37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## T14 barrel exports (16)"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## T15 shell providers (19)"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## T16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## T17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T18 figures 0"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05|2\.75|22\.5)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## T19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## T20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart; echo "EXIT:$?"
echo "## T21 H lines (hasLength)"; git grep -c "hasLength(" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart; echo "EXIT:$?"
echo "## T22 r01 v01 key names"; git grep -noP "(r01|v01)-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/onboarding/onboarding_restart.dart lib/src/onboarding/viewer_pairing.dart; echo "EXIT:$?"
echo "## T23 banned vocabulary in code 0"; git grep -nE "권장|추천|권유|자문|시그널|대부분|건너뛰|초기화|새로 시작|일단|해외" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T24 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## T25 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## T26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## T27 Scaffold AppBar Navigator in onboarding 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/onboarding; echo "EXIT:$?"
echo "## T29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/src/shell_providers.dart lib/l10n/labels.dart lib/src/onboarding/onboarding_start.dart lib/src/onboarding/onboarding_mode_pick.dart lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart lib/src/onboarding/onboarding_finish.dart lib/src/shell_scaffold.dart lib/src/routing lib/src/common lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/watchdog_board_test.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/onboarding_finish_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart test/golden/w01_golden_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## T30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T31 copyWith in tests 0"; git grep -n "copyWith(" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/onboarding_restart_test.dart test/viewer_pairing_test.dart test/golden/r01_golden_test.dart test/golden/v01_golden_test.dart; echo "EXIT:$?"
echo "## T33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## T34 precondition marks (pre)"; git grep -c "// pre$" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart; echo "EXIT:$?"
echo "## T35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/onboarding_restart_test.dart test/viewer_pairing_test.dart; echo "EXIT:$?"
echo "## T36 input widgets in onboarding 0"; git grep -niE "textfield|textformfield|editabletext|secretfield|keystore|flag_secure|biometric|mobile_scanner|image_picker|url_launcher|launchUrl" -- lib/src/onboarding; echo "EXIT:$?"
echo "## T37 golden PNG total (70)"; git ls-files -- "test/golden/goldens/*.png" | wc -l; echo "EXIT:$?"
  (줄의 뜻과 기대 — T01·T02 = 0 · T03 = 4줄(r01_golden 1 · v01_golden 1 · restart_test 9 · pairing_test 7) · T04 = 0 · S05 = 2줄(분기 · 다음 — 줄마다 탭 콜백 안) · T06 = 2 · T07 = 0 · T09 = 9줄(GateState 4 · UiLevel 5) · T10 = 2줄 · T11 = 0 ·
   🔴 T13 «lib/l10n/labels.dart:37»(정확히) · T14 16줄(정확히 — l10n/labels.dart · alerts 2 · onboarding 7(finish · mode_pick · restart · start · step_detail · step_list · viewer_pairing) · ops_home · ops_rhythm · routing/shell_router · shell_providers · shell_scaffold · watchdog_board 차례) ·
   T15 19줄(정확히 — R14 15 + R15a 2 + R15b 1 + R15d 1) · T16~T19 = 0 · T20 = «test/onboarding_restart_test.dart:8» · «test/viewer_pairing_test.dart:6» · T21 = «test/onboarding_restart_test.dart:1»(🔴 정확히) · T22 Key 이름 15 · T23 금지 어휘 0 · T24~T27 = 0 ·
   T29 = 세 줄(shell_providers · ui_shell · shell_fakes — 둘째 수 0 · 🆕 목록 = R15a O29 + R15a~R15c 파일 — 감사 지적) · T30~T32 = 0 · T33 PNG 8줄 «A» · 🔴 T37 PNG 총수 «70»(정확히 — R14 40 + R15a 8 + R15b 10 + R15c 4 + 이 카드 8) · T34 (pre) = «test/onboarding_restart_test.dart:9» · «test/viewer_pairing_test.dart:7»(재드라이런 4 · 정확히) · T35 = 0 · T36 = 0)

■ 골든 — ⟦펼침: R15a 골든 절 글자⟧ r01 — test/golden/r01_golden_test.dart · 위젯 = OnboardingRestart() · r01_lost_phone(lostPhone · 맨 아래 Key('r01-inherit') — 드라이런 기대 340.0(재드라이런 4 · v1.16 lostPhone = 로그인 끝(loginSlotId null) · 흉내 404.0 은 로그인 자리 64px 포함)) · r01_gap7(gap7 · 맨 아래 Key('r01-inherit') — v1.16 gap7 = 승계 고지 있음 · dy 드라이런 기대 304.0(재드라이런 4 · 흉내(고지 없음) 맨 아래 ValueKey('r01-branch-0') 276.0)) · 머리 Key('r01-headline') dy 0.0 · 슬롯 = FakeShellSlotRecorder
  v01 — test/golden/v01_golden_test.dart · 위젯 = ViewerPairing() · v01_ok(ok · 맨 아래 Key('v01-next') — 드라이런 136.0) · v01_fail(fail · 맨 아래 Key('v01-result') — 드라이런 184.0) · 머리 Key('v01-headline') dy 0.0 · light = dark · 여백 조정 0 · 나머지 = R15a 골든 절 글자.

■ 질문 파일 — R01V01_questions.md(이미 있다) · A1~A4 = r01_lost_phone · r01_gap7 · v01_ok · v01_fail dy «측정:» 행 · 접두 «R-01:» · «V-01:».

■ 제출 — ⟦펼침: R15a ■ 제출 전문 — 섹션 머리 · ①~⑤ 상자 · N1 · N3 · 저장 명령⟧ R15a «■ 제출» 과 같은 꼴
  flutter test test/onboarding_restart_test.dart ← «00:0n +20» · test/viewer_pairing_test.dart ← «+12» · r01_golden ← «+4» · v01_golden ← «+4» · flutter test ← N + 40 — ⟦실측: 앞 카드 병합 기록 때 채움 — 드라이런 기대 315 → «+355»(재드라이런 4 «00:20 +355»)⟧
  name-status 기대: A lib/src/onboarding/onboarding_restart.dart · A lib/src/onboarding/viewer_pairing.dart · M lib/src/shell_providers.dart · M lib/ui_shell.dart · A PNG 8 · A 골든 테스트 2 · A 테스트 2 · M test/shell_fakes.dart · M inbox/R01V01_questions.md · 그 밖 = 금지 · 권장대로면 바뀐 파일 18줄 · 커밋 4줄(드라이런 실측)
  사전검사 ② 두 번: --golden-prefix r01_ --goldens 4 · v01_ --goldens 4(드라이런 기대 🟡 4 · 4 — 보고 규칙) · PR 제목: [M8] R-01·V-01 다시 시작·조회 전용 페어링 · 채팅 = 두 줄.
   ① 머리 복사 상자 글자: «화면 ID: R-01 — 기존 계정에서 다시 시작(OnboardingRestart()) · V-01 — 조회 전용 QR 페어링(ViewerPairing()) · 주입 shellPairingRepositoryProvider»
   ③ 셈 단위 견본(재드라이런 4 · v1.16 실물 PNG · 이 카드 단위 · 견본과 같은 이름의 행은 꼬리까지 그대로): «| r01_lost_phone light | restart_vm_lost_phone.json | 슬롯 빌더 | 390×844 | 340.0 | 글자 1줄 → 글자 3줄 → 글자 1줄 → 버튼 글자 → 버튼 글자 → 글자 2줄 — 잘림 없음 |» · «| v01_fail light | pairing_fail.json | 슬롯 빌더 | 390×844 | 184.0 | 글자 1줄 → 글자 3줄 — 잘림 없음 |»(🆕 로그인 끝 lostPhone 표본 = 줄 수 그대로 · dy 만 404.0 흉내 → 340.0)
   (+ flutter test 한 줄 — 시작·끝 상자(기대 M = N + 40))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-r01-restart` · 커밋 권장 4 · lib 새 2 · 주입 +1 · 배럴 +2 · test 새 4 + fakes 끝 절 · PNG 8 · `R01V01_questions.md` A1~A4 · `flutter test` = N + 40(⟦실측: 앞 카드 병합 기록 때 채움⟧) · 🔴 «정확히 N» = 라벨 37 · 배럴 16 · 주입 19 · PNG 70.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15d-Bob-R01V01 결과: 브랜치 ui/m8-r01-restart 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

## 5. 주의

- **5분 눈 검사**: 초기화·새로 시작 버튼 · 갭 일수 판정 · unknown 에도 분기 · 로그인 전 원장 자리 · 분기 밖 버튼 · 수동 입력 칸 · 카메라·토큰 코드 · `x1Migration` 상수 · 셸 파일 `M`.
- 🔵 R15 마지막 카드 — 병합 기록이 R15 완료(🏁)를 적는다 · 다음 = 12 §6 큐(R16) · R15 test-only PR(C4 이월 몫이 생기면).
- 🔵 C4 사람 grep(🆕 재드라이런 4 테스트 쪽 TF2 «늘 참 find.byType(Text) + findsWidgets» · TF3 «nullable 흐름 칸 + if(r01 골든)» = 테스트·사전검사 🔴 0 · R15a «5» 꼴): `git grep -nE "find\.byType\([^)]*\)\s*,\s*(findsWidgets|findsAtLeast)" -- packages/ui_shell/test/onboarding_restart_test.dart packages/ui_shell/test/viewer_pairing_test.dart` · `git grep -nE "Function\(WidgetTester [A-Za-z_]*\)\?" -- packages/ui_shell/test/` · 둘 다 출력 0 이어야 · 테스트 쪽 변이 판정 = 임시 커밋 위(infra 후속 = 12 §3 부록 C4r14b-3 — precheck T3 byType+findsWidgets · T1 nullable 흐름 칸 + if).
- ⬜ 남은 표식 = 꺾쇠 U+27E6 자리(셈 = `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R15d-Bob-R01V01.md`) — ⓐ «앞 카드 병합 기록 때 채움» 실측 ⓑ ✅ v1.16 이름표 표식 0(2026-11-03 재조립) ⓒ 🆕 «펼침» 표식(감사 지적) ⓓ ✅ 재드라이런 4 실측(전제 수·나눔 · 견본 · dy · 🟡 까닭 · 정적 출력 줄 수 — 2026-11-03 채움) + 자리표시자 `__R15C_SQ__` · `__R15C_PR__` — 🔴 보내기 전 0 · ✅ 드라이런 첫 판 실측(줄 · lib · ⓡⓗ · dy · 변이 표 · 🟡 기대)은 «드라이런 기대» 로 채웠다(2026-11-03).
- 범위 고지: 01 §8 미결 13(창구 ✅ · `role` 클레임 발급 위치 = M4-2·M4-3) · 127(뷰어 가드) · 156(V-01 뷰어 원천 구현) · 158(첫 실행 판정) — 이 카드가 닫지 않는다 · ✅ X1 두 라우트 = v1.16(결정 ③).

## 6. R15 이월 반영 — R15a «6» 과 같은 표(R-01·V-01 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r14b-1 · -2 · C4r14a-4 | 규칙 10 = R15a 규칙 10(⟦펼침⟧) | — |
| C4r14b-5 | ■ 제출 = R15a 꼴(⟦펼침⟧) | — |
| C4r14a-5 쓰기 조각 | — | 해당 없음(이 카드 쓰기 0) |
| C4r14a-6 부재 = 데이터 | R01-04 · R01-05 · R01-06 logged_in · V01-01 | 주입 null 갈래 = 슬롯 빌더 null 두 경우(R01-06 · V01-04) |
| C4r5d-5 골든 명령 칸 | — | 해당 없음(명령 0) |
| C4r5c-5 · C4r5e-3~7 (계승) | R15a «6» 과 같은 자리 | 배너 = 해당 없음 |
| C4r5b-4 G1 🟡 «덩어리로 셀 수 없음» 꼴 | 보고 규칙 «드라이런 기대 🟡 8» | infra(G1 버튼 낱말) = 12 §3 부록 |
