# 발송 패킷 R15a-Bob-O00O00b — O-00 첫 실행 3갈래 · O-00b 운영 방식 선택 (계약 v1.16 전제 · R15 4장 중 1번째 · M8)

> ⬜ **조립됨 · ✅ 누적 드라이런·지적 반영 · ✅ v1.16 반영 재조립**(2026-11-03 · 앱 `rec/r15`) · 🔴 **선행 1 = 계약 v1.16 보강 병합(R15 선행 M2 — 가지 `m2/v116-r15` `aaefdbc` · 로컬 · PR 전 · `contractVersion` `'1.16.0'` · squash `__R15V116_SQ__` · R15a 몫 G1~G7 · ✅ 발주자 결정 2026-11-03 · 아래 «■ 계약 v1.16 이름표» = v1.16 실제 글자 · ▶ 금지)** · ✅ 누적 재드라이런 2(2026-11-03 · v1.16 실물 `aaefdbc` + 기록 `bafe5b9` 병합 base `0bdfd67` · 가지 `dry/r15v2-1` `57f3005` · 꺾쇠 «실측» 자리 채움 — 아래 «드라이런» 줄) · ✅ 발주자 확인 ①~⑬ 확정 · ⬜ 「푸시해」 — 남은 둘(선행 1 · 「푸시해」)이 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다(보내기 전 순서 = «2» 1번). 🔴 Bob 의 R14 브랜치(`ui/m8-n01-alerts` · `ui/m8-w01-watchdog` · 병합됨)는 건드리지 않는다.
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(381행 · 🔀 4분할 권고 — 아래 «재분할 판정») + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · PR 본문은 통합 담당 · 커밋 = 제목만 맞추기 · 골든 높이 = 재량 + 기록 · 재제출 = 전체판 + 상자) + 이월 부록 «R15» 대상(«R14b C4 이월 부록» C4r14b-1·2·5 · «R14a» C4r14a-4·5·6 · «R5d» C4r5d-5 · «R5c» C4r5c-5 · «R5e» C4r5e-3~7 계승 — 아래 «6») · 화면 몫 원본 = `04_…` §9 머리(게이트 판정 = Claude) · §9-1(`O-00` · 그림 17) · §9-1b(`O-00b` · 표 · 수용 (a)~(e) · 그림 28) · §2-5(플랫폼) · §11-11 · `01_…` §2-11 `OperatingModeView`·`OperatingModeOption` · §4-1 `OnboardingRepository` · §4-3 `SettingsActions` · §6-3 `onboarding_choice` · §8-23 ✅(`committed_at` = O-04 6단계 같은 트랜잭션) · 판독 메모(통합 담당 스크래치 `r15/read_memo.md` · 2026-11-02 · 앱 `origin/main` `267e867` · 설계 `2f8703c`).
> 사전 조건 — ✅ R14 병합(R14a PR #87 `185e9c7` · R14b PR #88 `afe3e1d` · R14 test-only PR #89 `14d6374` · `ui_shell` = lib 12파일 · 라벨 35 · 배럴 export 9줄 · 셸 주입 15줄 · PNG 40 · 테스트 소스 `testWidgets(`/`test(` 줄 84) · ⬜ **선행 1 계약 v1.16**(R15 선행 M2 보강 PR — G1~G7 R15a 몫 + G8~G19 뒤 카드 몫 · 아래 이름표 · 가지 `m2/v116-r15` `aaefdbc`(`domain_contracts` «+424 ~30» · `ui_shell` 193 무변경 — M2 실측) · 병합 squash = `__R15V116_SQ__`) · ✅ 프롬프트 v2(`34bf60a`). 시작 기준 = 계약 v1.16 병합본의 `flutter test`(packages/ui_shell) = **193**(재드라이런 2 실측 «00:17 +193: All tests passed!» — v1.16 실물 `aaefdbc` + 기록 `bafe5b9` 병합 base 위 · M2 가지 실측도 193 · v1.16 은 `ui_shell` 테스트·가짜를 바꾸지 않았다 · 새 라우트 64 는 TR 루프가 testWidgets 안이라 수 불변 · v1.16 병합 기록 때 병합본에서 다시 잰다) · 이 카드 끝 기대 = 시작 기준 N + **44**(뷰 36 = `onboarding_start_test` 13 + `onboarding_mode_pick_test` 23 · 골든 8 = `o00_*` 2 + `o00b_*` 6) · 끝 = 드라이런 «+237»(파일별 `onboarding_start_test` +13 · `onboarding_mode_pick_test` +23 · `o00_golden` +2 · `o00b_golden` +6 · 🆕 지적 반영판 `dry/r15-1b` 도 같은 수 — 단언만 더했다 · ✅ 재드라이런 2(v1.16 실물) «00:20 +237» 같은 수). 🔵 0단계 `ls docs/ai-context/send/R15a-Bob-O00O00b.md` 가 보이면 조립 기록 커밋(golden README «🆕 R15» 절 포함)이 base 에 있다 — 정적 O29 의 golden README 줄 0 은 이 전제 위에서만 맞는다(드라이런 지적 · 기록 커밋이 base 에 없으면 O29 에 golden README 줄이 하나 더 나온다).
> 🔀 **재분할 판정(12 §3 공통 임계 = 새 `testWidgets(`·`test(` 줄 > 33 · lib > +900 · 새 PNG > 16 · K35 새 원천·쓰기 창구 ≤ 5)** — R15 한 장(O-00 · O-00b · O-01~O-04 · R-01 · V-01 · 🆕 누적 드라이런 실측 합) = 줄 **77**(20 + 25 + 14 + 18 — R15b = 지적 반영판) · lib **+1,299**(+389 + +410 + +251 + +249) · PNG **30** · 원천·쓰기 **10** → **네 축 전부 초과** → **4분할 ✅ 확정**(발주자 결정 ① 2026-11-03): 이 카드 = `O-00`·`O-00b`(카드 계획 = 줄 **20**(`onboarding_start_test` 6 · `onboarding_mode_pick_test` 12 · 골든 2) · lib **+389**(드라이런 · `onboarding_start.dart` 133 · `onboarding_mode_pick.dart` 234 · `labels.dart` +4 · `shell_providers.dart` +16 · `ui_shell.dart` +2) · 새 PNG **8** · 원천·쓰기 **3**(`watchStart` · `watchModeChoice` · `run(onboardingOperatingModeSelect)`)) → `send/_대기/R15b-Bob-O01O03.md`(O-01·O-02·O-03 · 줄 25(드라이런 지적 반영판) · PNG 10 · 원천 3) → `send/_대기/R15c-Bob-O04.md`(O-04 · 줄 14 · PNG 4 · 원천 2) → `send/_대기/R15d-Bob-R01V01.md`(R-01·V-01 · 줄 18 · PNG 8 · 원천 2 · «정확히 N» 소유 · ✅ 결정 ① 순서대로 — 후순위 0). 까닭 = ⓐ 임계 네 축 ⓑ 카드마다 선행 소유자가 다르다(R15a = M2 만 · R15b = M2 + M4·M9 `SecretField` 자리 · R15c = M5·M9·01 §8 미결 120 · R15d = X1·M9·플랫폼) — 먼저 풀리는 장부터 보낸다 ⓒ strict 반려 1회의 되돌림 폭 ⓓ Bob 이미지 20장 한도(이 카드 PNG 열람 4장).
> 카드 기본값(카드 권한 — ✅ 아래 «발주자 확인» ①~⑬ 확정 = 권고 = 카드 기본값): ⓐ 위젯 = `OnboardingStart({super.key})`(`lib/src/onboarding/onboarding_start.dart` · `ConsumerWidget` · 조회 갈래 = 같은 파일 안 별도 클래스 `_ViewerTrackCard`) · `OnboardingModePick({super.key})`(`lib/src/onboarding/onboarding_mode_pick.dart` · `ConsumerStatefulWidget` — `_busy`·`_failed`·`_result` 셋) ⓑ **셸 파일은 고치지 않는다** — 온보딩의 셸 연결 = 조립 앱 레지스트리 칸(v1.16 `AppRoutes.onboardingStart` · `onboardingModePick` 칸 · 06 M4-11 · 이 카드 밖) · 셸 가드 표 무변경(01 §8 미결 127 그대로 · `shell_router_test.dart` 전수 표 무수정) · 첫 실행 판정(온보딩 vs 셸) = 조립 앱 몫(06 M4-11 · 01 §8 미결 158) ⓒ 원천 = 🆕 `watchStart()` → `OnboardingStartVm` · 🆕 `watchModeChoice()` → `OnboardingModeChoiceVm` · 쓰기 = `SettingsActions.run(onboardingOperatingModeSelect, args: {operating_mode: <OperatingMode.wire>})` 1종(새 주입 `shellOnboardingActionsProvider` · `SettingsActions?` · 뷰어 = null = 카드 탭 부재) · `OperatingModeView`·`watchSteps` = 부르지 않는다 ⓓ O-00 = 머리(`headline`) → 계정 축 갈래 2(`tracks` · 받은 차례) → 조회 갈래(`viewerTrack` · null = 부재 · 분리 위젯) · 갈래 탭 = `deepLink`(null = 탭 없음) · 소요 시간 = `estimatedText` ⓔ O-00b = 머리 → 카드 2장(`options` 받은 차례 · 가로 나란히 같은 폭·같은 높이) → 잠금 문장(`lockedLabel` · 있을 때) → 결과 줄(실패 정적 글자 또는 `headline` + `reasonCode`) → 하단 고정 고지(`recordGapNotice`) → 정직 고지(`honestyText`) → «다음»(`nextDeepLink` · 있을 때) ⓕ 🔴 기본값 없음 — 진입 때 체크 0 · 포커스 0 · «다음» 0 · 고른 표시 = 데이터 `selected`(체크 아이콘 + 테두리 색) · 낙관 갱신 0 · 로컬 기억 0 ⓖ 결과 줄 = 받은 `ActionResult` 의 `headline` + `reasonCode`(있을 때 · 원문) 한 덩어리 · `level`·`retryable`·`handoffRoute`·`actionRunId` 미참조 · 예외 = 정적 «접수되지 않았습니다» · 기다리는 동안 카드 탭 null(두 번 누름 0) · 확인 다이얼로그 0 ⓗ 온보딩 화면 asOf 머리·오래됨 배너 = 0(VM 에 asOf 없음 — ⑤) · `shellClockProvider` 미사용 ⓘ 새 lib 파일 2 · 공용 4(`labels.dart` R15a 절 2개 · `shell_providers.dart` 끝 절 주입 2 · 배럴 +2 · `test/shell_fakes.dart` 끝 절 — 전부 **끝 절 더하기만** · «정확히 N»(라벨·배럴·주입·PNG 총수) = 마지막 카드(R15d · ✅ 결정 ① 순서대로)) · Key 접두 `o00-`·`o00b-`(순번만) · 테스트 `test/onboarding_start_test.dart` · `test/onboarding_mode_pick_test.dart` · 골든 4이름 8장(`test/golden/o00_golden_test.dart` 1이름 · `o00b_golden_test.dart` 3이름 · 크기 = `kGoldenPhoneSize`(390 × 844 · dy 308.0 · 584.0 · 652.0 · 648.0 — 재드라이런 2 실측 · light = dark)) ⓙ copyWith 0 · implements 가짜 0(v1.16 받침대 `UnimplementedOnboardingRepository` · 기존 `UnimplementedSettingsActions` extends) ⓚ 픽스처 = v1.16 의 `m8/onboarding_start` · `_start_no_viewer` · `_mode_unselected` · `_mode_auto` · `_mode_advisory` · `_mode_locked` · `_mode_select_results` — 12 §3 원 행의 `m8/onboarding_mode_pick`(`OperatingModeView` · M9 S05 몫)은 **쓰지 않는다**.
> 🔴 **카드 덮개 필수 문장(04 §9 머리 · §9-1 · §9-1b · §11-11 · prompt_M8 145~152·163~164)** — «순서 = `O-00` → `O-00b` → `O-01` — `O-00` 은 계정 축 3갈래(처음 · 다시 · 조회 전용)만이고 운영 방식은 `O-00` 의 4번째 갈래도 `O-01` 안의 한 단계도 아니다(갈래 이동 = 엔진이 준 링크)» · «`O-00b` 는 기본값이 없다 — 미리 고른 카드·포커스·«다음» 활성 0 · «권장»·«추천» 배지 · 한쪽 시각 우대(크기·색·순서 강조) · 사회적 증거 · 겁주기 · 수익률 차이 암시 0 · 두 카드 = 받은 차례·같은 크기·같은 모양» · «문구는 전부 엔진(카드 4칸 · 하단 고정 고지 · 정직 고지 · 결과 문장) — 기대치 숫자 리터럴 0 · 화면이 두 카드를 비교해 결론 문장 0» · «선택 = `SettingsActions.run(onboardingOperatingModeSelect)` 1회 — 고른 표시·«다음»·잠금은 데이터(`selected` · `nextDeepLink` · `lockedLabel`) · 로컬 기억·낙관 갱신 0 · 결과 문장 = `headline` + `reasonCode` 원문(요약·의역 0)» · «셸 파일·R13·R14 파일·테스트·PNG 는 고치지 않는다». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — 새 K 0 · 관련 = X7 요구 12(O-00b 기본값 없음) · 결정 9e(조회 전용 폰 = QR 페어링) · 청사진 §9-1b ⑦(첫 화면 viewer 노출 — 권고 선반영 · 되돌릴 수 있게) · K35(새 원천·쓰기 ≤ 5) · 01 §8-23 ✅(`committed_at` = O-04 6단계 같은 트랜잭션 — 이 카드 = 그 뒤 잠금 문장만 그린다).
> ✅ **확정(2026-11-03 · 발주자 · ① 4분할 + v1.16 선행 + 플랫폼 몫 화면 밖 · ② whereText 글자만 · 체크섬 = M9 슬롯(04 정정) · ③ 미결 120·32 · V-01 PairingRepository · X1 라우트 등록 · ④ 나머지 권고대로)** — 발주자 확인 13건(아래 권고 = 확정 글자 · «대안» = 기각 기록) — ① **분할 · 선행 · 후순위 · 플랫폼 몫을 한 문항으로**: R15 = 4장(이 카드 `O-00`·`O-00b` → `R15b-Bob-O01O03` → `R15c-Bob-O04` → `R15d-Bob-R01V01`) · 선행 = 계약 v1.16 «R15 선행» M2 보강(카드별 몫 = 12 §3 «R15 선행 M2 v1.16 이름표» G1~G19 · 이 카드 = G1~G7) · `R15d` = 순서대로(✅ 후순위 0 — v1.16 이 V-01 창구 `PairingRepository`·X1 두 라우트를 실었다 · 01 §8 미결 13 창구 ✅) · 플랫폼 몫(Android Keystore · 클립보드 60초 클리어 · `FLAG_SECURE` · 생체인증 · QR 카메라 · Auth 매직링크/OTP · Android 권한 요청 · 외부 URL 열기 · 첫 실행 판정) = 화면 밖(조립 앱·엔진 · 06 M4-11 · F-01 이관 선례) · 대안 = 3분할(R15c+R15d — 선행 결정 둘이 묶여 ▶ 가 늦다 · 비권고) · 비권고 = 한 장(임계 네 축 초과) ② 계약 v1.16 이름표(아래 블록 · R15a 몫) = ✅ v1.16 실제 글자(설계서 §4 · M2 가지 `aaefdbc` — 권고 이름표에서 바뀐 것 = 파일 `dto/onboarding.dart` · `OnboardingTrackCard.deepLink` · `OnboardingModeChoiceVm.nextDeepLink`) ③ `O-00b` 원천 = 🆕 `OnboardingModeChoiceVm`(`selected: OperatingMode?` — null = 아직 안 고름) · `OperatingModeView`(`current` required · M9 `S05` 몫)는 `O-00b` 가 읽지 않는다(표본 `m8/onboarding_mode_pick` 의 `current: ADVISORY` + «아직 고르지 않았습니다» = 함정) · 카드 = 기존 `OperatingModeOption` 재사용(01 §2-11 «같은 타입» 유지) · `trust`·`switchGates` = `O-00b` 에 0 · 대안 = `OperatingModeView.current` nullable(S05·표본 연쇄 · 비권고) ④ `O-00` 원천 = 🆕 `OnboardingStartVm{headline, tracks(계정 축 2), viewerTrack?}` · 조회 갈래 = 분리 위젯 · null = 부재(청사진 §9-1b ⑦ 되돌림 = 엔진 한 칸) · 소요 시간 = `estimatedText` · 갈래 탭 = `deepLink`(데이터) ⑤ 온보딩 화면 asOf 머리·오래됨 배너 = 0(`O-00`·`O-00b` VM 에 asOf 없음 — 위저드 · 원천 폰 로컬 · 04 §9 그림에 없음) · 🆕 04 §2-3 공통 6상태 중 이 두 화면이 그리는 것 = 로딩·에러 둘뿐(빈 3갈래 `EmptyKind`·오래됨·차단·부분 동기 = 0 — VM 에 asOf·flags·`EmptyKind` 칸이 없다 · 01 §8 미결 148 과 같은 창 · 명세 지적) · 대안 = asOf·`EmptyKind` 를 VM 에 넣고 머리·빈 갈래 그리기(04 §2-3 «모든 조회 화면» 을 넓게 읽기) ⑥ 선택 쓰기 = `run(onboardingOperatingModeSelect, args {operating_mode: <OperatingMode.wire>})` 1회(args 화이트리스트 = v1.16 G3) · 결과 = `headline` + `reasonCode`(있을 때) 원문 한 덩어리 · `level`·`retryable`·`handoffRoute`·`actionRunId` 미참조 · 예외 = 정적 «접수되지 않았습니다» · 고른 표시 = 데이터 `selected` ⑦ «다음» = `nextDeepLink`(엔진이 고른 뒤에만 준다 · null = 부재) — 화면이 «`selected != null` 이면 다음» 판정 0 ⑧ 잠금(`committed_at` 뒤) = `lockedLabel`(엔진 문장 · non-null = 카드 탭 부재 · 이후 변경 = 🔒 `M5-11` · 이 카드에 그 경로 0) ⑨ 주입 2 = `shellOnboardingRepositoryProvider` · `shellOnboardingActionsProvider`(`SettingsActions?` · 뷰어 null = 카드 탭 부재) · 셸 가드 무변경(미결 127) · 첫 실행 판정 = 조립 앱 ⑩ 정적 라벨 2 = `onboardingNext`(«다음») · `onboardingNotAccepted`(«접수되지 않았습니다») — 대안 = R14a `alertsAckNotAccepted` 재사용(라벨 1) ⑪ 두 카드 배치 = 받은 차례 · 가로 나란히 같은 폭·같은 높이(`IntrinsicHeight` + `Row(stretch)` + `Expanded`) · 고른 뒤 표시 = 체크 아이콘 + 테두리 색(사람이 고른 뒤의 상태 — 시각 우대 아님) · 대안 = 세로 쌓기 · 🆕 드라이런 정보: 체크 아이콘(24)이 제목 글자 줄(20)보다 커서 고른 카드의 제목 행이 4px 높아진다 — 두 카드 높이는 `IntrinsicHeight` 로 같게 남고 «다음» dy 만 고른 쪽 따라 다르다(`o00b_auto` 652.0 · `o00b_advisory` 648.0 — 재드라이런 2 · 흉내 572.0 · 568.0) · 대안 = 체크 자리를 늘 같은 크기 빈 칸으로(고른 쪽 따라 배치 불변) · 🆕 «하단 고정 고지»(04 §9-1b) = 카드·잠금·결과 줄 바로 아래 늘 그리는 자리(스크롤 목록 안 · 화면 아래 고정 아님 — `o00b_unselected` 골든 첫 화면 안 · O0B-01 사슬 dy 가 지킨다 · 감사·명세 지적) · 대안 = `Column[Expanded(ListView), 고지]` 로 화면 아래 고정(200% 글꼴에서도 늘 보임) · 🆕 고른 상태 = 체크 아이콘 + 테두리 색(글자 0 — 04 §2-3 «색·아이콘·글자 함께» 의 글자는 탭 뒤 결과 줄 · 재진입 때는 없다 · 명세 지적) · 대안 = `Semantics(selected: picked)` 한 겹 ⑫ 골든 4이름 8장 = `o00_start`(🆕 카드가 지은 이름 — 04 는 `O-00` 골든 이름을 주지 않는다) · `o00b_unselected` · `o00b_auto` · `o00b_advisory`(04 §9-1b (e) 글자) · `kGoldenPhoneSize` ⑬ 이월 반영(아래 «6»).
> 🔵 **판독 빈틈 → v1.16 권고 → ✅ v1.16 반영(판독 메모 §5-1 · 12 §3 «R15 선행 M2 v1.16 이름표» 확정 줄 · 01 §25)**: G1 `O-00b` 읽는 창구 0 · `current` required 충돌 → `watchModeChoice` · `OnboardingModeChoiceVm.selected?` · G2 하단 고정 고지·정직 고지 칸 0 → `recordGapNotice` · `honestyText` · G3 `onboardingOperatingModeSelect` args 화이트리스트 0 → `{operating_mode ∈ {AUTO_TRADE, ADVISORY}}` + 결과 표본 2 · G4 고른 상태 표본 0 → `m8/onboarding_mode_auto`·`_advisory`·`_locked`·`_unselected` · G5 `O-00` 갈래 VM 0 → `OnboardingStartVm` · G6 온보딩 전용 라우트 0 → v1.16 라우트 6(`onboardingStart` · `onboardingModePick` · `onboardingSteps` · `onboardingFinish` · `onboardingRestart` · `onboardingPairing` — `all` 에서 `onboardingStep` 앞 · 🔴 `aaq://onboarding/:stepId` 와 첫 일치 충돌 0 — `shell_router_test` TR-01 `expect(matched, AppRoutes.all)` 이 잡는다) · G7 받침대 `UnimplementedOnboardingRepository` 0 · 🆕 드라이런 지적(v1.16 PR 체크 — 흉내가 걸린 곳) → ✅ v1.16 반영: C-33 ② `_linkKeys` += `next_deep_link` · `finish_deep_link`(`deep_link` 은 기존 키 · 표본 링크 = `aaq://onboarding/mode`·`steps`·`restart`·`pairing` = v1.16 라우트 · TR-01 첫 일치) · C-8 `_knownUncovered` − `ActionResult` · C-5 거부 표본 `reason_code` = `ONBOARDING_CHOICE_COMMITTED`(🆕 `OnboardingResultCodes` 등재) · 결과 표본 `[0].level` OK ≠ `[1].level` BLOCKED · `dart format` 0 changed. 🟡 화면 스캔 빈틈(01 §8 미결 91·144 — `ui_shell` 은 C-46/C-47·경계 [5b][5c] 밖) → 이 카드 정적 묶음이 메운다(«권장»·«추천» · 기대치 숫자 · `TextField` · 포커스 · `OperatingModeView`).
> 🚫 **플랫폼 몫 = 화면 밖(조립 앱·엔진 · 06 M4-11 · F-01 이관 선례 · ✅ 결정 ①)** — 이 카드에 걸리는 것 = 첫 실행 판정(온보딩 vs 셸 진입 · `FeatureFlags` 에 «온보딩 끝» 칸 0 — 조립 앱) · 뷰어(iOS·웹) 에서 `O-*` 막기(04 §2-5 — 셸 가드 무변경 권고 · 조립 앱이 본문을 주지 않으면 `s01-placeholder`). 뒤 카드 몫 = Keystore·클립보드·`FLAG_SECURE`·생체·QR 카메라·매직링크/OTP·Android 권한·외부 URL(R15b~R15d 머리).
> 드라이런: ✅ 누적 드라이런 1번째(2026-11-02~03 · worktree `C:/Work/AAQ-claude-r15dry` · 첫 판 가지 `dry/r15-1` = `origin/main` `267e867` → 기록 커밋 `1455320` ff → v1.16 흉내 `981fed4`(이름표 G1~G7 그대로 · `domain_contracts` 만 · 픽스처 187 → 194 · 봉투 1.16.0 · 등록부·C-8·C-33 보정) → 권장 4커밋 `7d72587`·`792bdef`·`0292ec7`·`5c46f58` · 🆕 지적 반영판 가지 `dry/r15-1b` = + `dd03123`(테스트 단언만 — O0B-04 고른 뒤 다른 카드 탭 · O0B-05·06·08 자리 dy · O0B-06 실패 글자 · O00-02 `InkWell.onTap`)) · 시작 «+193» → 끝 «+237»(파일별 +13 · +23 · +2 · +6 · 반영판 같은 수) · `domain_contracts` «+408 ~30»(흉내) · 정적 37줄 = 출력 151줄(EXIT:1 20 · EXIT:0 17) · 사전검사 ① 🔴 0 · 🟡 0 · ② `o00_` 🔴 0 · 🟡 0 · `o00b_` 🔴 0 · 🟡 6(G1 — ■ 제출 N3 기대) · 골든 dy 4(light = dark) · lib +389 · PNG 열람 4장 · 변이 74꼴(예고 59 · 참고 15) = 첫 판 KILLED 69 · SURVIVED 5 → 🆕 반영판에서 M08(결과 줄을 고지 아래로) · R06(실패 글자 의역) · R08(고른 뒤 카드 탭 막기) + 🆕 M39b(deepLink null 빈 콜백) KILLED(O0B-05·06 · O0B-06 · O0B-04 · O00-02) · R01(늘 참 단언 `find.byType(Icon)` + `findsWidgets`) = 사전검사 T3 구멍(infra · C4 사람 grep — «5») · R02(else 없는 if) = 사전검사 T1 🔴 · 🔵 흉내 = 권고 이름표 글자(키 `link`·`next_link` · 문장·링크 값도 v1.16 실물과 다르다 — 7벌 전부 · 실물 = 설계서 §5-1) → 글자 길이에 기대는 값(골든 dy · ③ 견본 2행)은 꺾쇠 «실측» 자리로 돌렸다 · 테스트 수·정적 출력 수·lib 줄은 코드 몫이라 기대 그대로 · 🆕 ✅ **재드라이런 2**(2026-11-03 · v1.16 실물 `aaefdbc` + 기록 `bafe5b9` 병합 base `dry/r15v2-base` `0bdfd67`(충돌 0) · 가지 `dry/r15v2-1` = `6e58182`·`da7a0cb`·`e74a95f`·`57f3005` · (5) 없음) — 0단계 기대 27줄 그대로 · 시작 «+193» → 끝 «+237»(파일별 +13 · +23 · +2 · +6) · `domain_contracts` «+424 ~30» · 정적 37줄 꺼내기 해시 `c85e925` 일치 · 출력 151줄(EXIT:1 20 · EXIT:0 17 · 앞 판과 줄 번호까지 같다) · lib +389 · 사전검사 ① 🔴 0 · 🟡 0 · ② `o00_` 🔴 0 · 🟡 0 · `o00b_` 🔴 0 · 🟡 6(기대 그대로) · 카드↔코드 어긋남 0(이름 둘 `deepLink`·`nextDeepLink` 만) · 바뀐 실측 = 골든 dy `o00b` 셋 +80(584.0 · 652.0 · 648.0 — v1.16 정직 고지가 흉내보다 길다) · 고지 글자 6 → 10줄 · PNG 8장 바이트 · 변이 82꼴(예고 62 전부 KILLED · 참고 20 = KILLED 16(테스트 15 + R14 정적 O28) · 테스트·사전검사 통과 3 = R01 늘 참(«5» C4 사람 grep) · R02 else 없는 if(사전검사 T1 🔴 — 임시 커밋 위) · 🆕 R16 nullable 흐름 칸 + if(기계 그물 0 → «5» C4 사람 grep 2)).
> 프롬프트 = `docs/ai-context/prompt_M8.md`(**v2 판 183줄** · 2행 `{{범위}}` = `S-01` · 119행 «이번 과제 범위: S-01» · 128행 PR 제목 = 형식만 → 이 카드가 덮는다(«이긴다» ①⑭) · 재조립 0 · 🔵 낡은 줄 = 160행 «온보딩 5단계» → 지금 6단계(R15c 몫 · «이긴다» ⑰)). 🔴 Bob **새 대화** 전제 — R14 대화를 기억하지 못합니다. 0단계·규칙 요약·본받지 않는 것·스케치·테스트 목록은 본문에 담았습니다.
> R4·R13·R5·R14 교훈 반영: PNG 열람 = 이름마다 light 1장(4장 — 이미지 20장 한도) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 같을 때만) · 구독마다 «로딩·에러 × 갈래»(C4r3-1) · 갈래마다 배너·짝(C4r5e-3 · 이 카드 = 배너 0 · 상태 갈래 짝) · 🆕 경우 for 는 testWidgets **밖**(C4r14b-1) · 🆕 흐름 칸 non-null 클로저(nullable 흐름 칸 + `if (c.flow != null)` = 반려 꼴 · C4r14b-2) · 🆕 경우 이름 = 레코드 `name` 칸(C4r14a-4) · 🆕 쓰기 조각 «실패 → 재시도 → 성공» 두 방향(C4r14a-5) · 🆕 «부재 = 데이터» 테스트 = operator 주입(C4r14a-6) · 전제는 if 밖·`// pre`(C4r4b-1·2) · 커밋마다 `git add <파일>` + `git show --stat HEAD`(C4r5a-3) · 제네릭 위젯 술어 = `tester.widget<T>(find.byKey(…))` · `find.descendant(of: find.byKey(…), matching: find.byType(T))` 만(`find.byType(Card)` 단독 = 늘 참 금지 · C4r5a-4) · 저장 파일로 받기 · 채팅 두 줄(C4r5a-1) · 🆕 저장 파일 = UTF-8 BOM 없이 `[IO.File]::WriteAllText` · ① 붙이기 = 파일로 받은 출력 그대로(C4r14b-5) · 정적 묶음 = 파일로 꺼내 Git Bash 전체 경로 · EXIT 0/1 밖이면 다시(C4r5a-2 · C4L-4) · 정적 머리 ASCII · `Get-Content -Encoding UTF8` · `[Console]::OutputEncoding`(C4r5e-5) · 골든 칸 셈 단위 «이어진 글자 행 = 한 덩어리»(C4r14a-3) · 파일별 기대 글자에 시각 머리(C4r14a-2) · G1 🟡 조문(C4r5d-1) · ③ 표 구분 줄 · ④ «+»(C4r5d-8) · 단언 없는 `takeException` 0(C4r5d-6) · «자리 바꿈» 견본 = 글자 그대로 · 입력 칸 = 파일 이름만(C4r5e-7).

## 0. 한 줄 목적

`OnboardingStart()` 가 `watchStart()` 의 `OnboardingStartVm`(머리 · 계정 축 2갈래 · 분리된 조회 갈래)을 받은 차례·글자 그대로 그리고 갈래 탭은 엔진 링크로만 열며, `OnboardingModePick()` 이 `watchModeChoice()` 의 `OnboardingModeChoiceVm` 카드 2장을 **기본값 없이**(체크·포커스·«다음» 0) 같은 크기·같은 모양으로 그리고, 카드 탭 한 번에 `SettingsActions.run(onboardingOperatingModeSelect)` 를 한 번만 불러 결과 문장을 원문 그대로 보이며, 고른 표시·«다음»·잠금은 데이터로만 바꾸는 `O-00`·`O-00b` 를 계약 v1.16 그대로 짓기(셸 파일 무수정).

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-o00-mode-pick`**(base = 최신 `origin/main` · `--no-track` · 이름 = 분할 뒤 새 이름 — 12 §3 R15 원 행의 `ui/m8-o00-onboarding` · «[M8] O-00~O-04 온보딩» 은 한 장 판 글자 · ✅ 결정 ①) · PR 제목 = «[M8] O-00·O-00b 첫 실행·운영 방식 선택».

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 ⬜(선행 계약 v1.16 병합 · 「푸시해」가 남음 · v1.16 병합 기록이 자리표시자를 채운다 · ✅ 재드라이런 2 가 «실측» 표식을 채웠다). 🔴 **보내기 전 순서**(재드라이런 2 지적): ① v1.16 PR(가지 `m2/v116-r15` 를 그때의 `origin/main` 위로 rebase · 재검사) 병합 → ② `rec/r15` 병합 기록(이 카드·golden README «🆕 R15» 가 `main` 에 오른다) → ③ 머리 ▶ — 0단계 `ls docs/ai-context/send/R15a-Bob-O00O00b.md` · 정적 꺼내기 `git show 'origin/main:…'` · O29 · 사전검사 `--base origin/main` 은 ①② 가 `main` 에 오른 뒤에만 맞는다(재드라이런은 `origin/main` 자리를 base `0bdfd67` 로 바꿔 돌렸다) · 0단계 계약 버전 줄은 병합 뒤 다시 잰다(2026-11-03 `origin/main` `22446ed` = `'1.15.0'` · `m2/v116-r15`·`rec/r15` 둘 다 merge-tree 충돌 0 · E10 병합분은 `domain_contracts`·`ui_shell`·`docs/ai-context` 를 건드리지 않았다).
2. Bob 에 R14 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R15a-Bob-O00O00b.md> (🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다 · `send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R15a-Bob-O00O00b — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 바깥 울타리 = 백틱 네 개 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R14*-Bob-*.md` · 다음 장 `_대기/R15b-Bob-O01O03.md`·`R15c-Bob-O04.md`·`R15d-Bob-R01V01.md` 를 붙여넣지 않습니다.
6. 🔴 **받는 법(C4r5a-1 · R14 와 같은 꼴)** — Bob 은 보고 글 전문을 채팅에 내지 않고 `$env:TEMP\R15a-Bob-O00O00b_submit.md`(🆕 UTF-8 **BOM 없이** — C4r14b-5)에 저장한 뒤 사전검사 ② 를 두 번(`o00_` · `o00b_`) 돌리고, 채팅에는 두 줄(«…저장했음: <경로>» · 사전검사 ② 끝 줄 둘을 « / » 로 이은 한 줄)만 냅니다. 받은 뒤에는 아래 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다.
7. 🔵 Bob 의 이전 창은 닫은 뒤 새 대화를 엽니다 — 그 창이 띄운 `flutter_tester` 는 창과 함께 끝납니다. 작업 관리자 등에서 `flutter_tester` 를 직접 끝내지 마세요(다른 세션 것도 있습니다 · C4r5a-9 ⑥).

## 3. 붙여넣을 본문 — ````text 다음 줄(«R15a-Bob-O00O00b — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R15a-Bob-O00O00b — 범위: O-00 첫 실행 3갈래(OnboardingStart() — 머리 · 계정 축 갈래 2(처음 · 다시) · 조회 갈래 1(분리 위젯 · 없으면 부재) · 갈래 탭 = 링크) ·
  O-00b 운영 방식 선택(OnboardingModePick() — 머리 · 카드 2장(기본값 없음 · 같은 크기·모양) · 잠금 문장 · 결과 줄 · 하단 고정 고지 · 정직 고지 · «다음» = 링크) + 새 주입 2 + 정적 라벨 2 + 배럴 export 2줄 + 가짜 끝 절.
🔴 순서 = O-00 → O-00b → O-01 — O-00 은 계정 축 3갈래만(운영 방식 = O-00 의 4번째 갈래 아님 · O-01 안의 한 단계 아님) · 갈래 이동 = 엔진이 준 링크(deepLink · nextDeepLink)뿐.
🔴 O-00b 기본값 없음 — 진입 때 체크 0 · 포커스 0 · «다음» 0 · «권장»·«추천» 배지 0 · 한쪽 시각 우대(크기·색·순서) 0 · 사회적 증거·겁주기·수익률 차이 암시 0 · 두 카드 = 받은 차례·같은 크기·같은 모양.
🔴 문구 전부 엔진 — 카드 4칸 · 하단 고정 고지 · 정직 고지 · 결과 문장 · 잠금 문장 · 기대치 숫자 리터럴 0 · 화면이 두 카드를 비교해 결론 문장 0.
🔴 선택 = SettingsActions.run(onboardingOperatingModeSelect) 1회 — 고른 표시·«다음»·잠금 = 데이터(selected · nextDeepLink · lockedLabel) · 낙관 갱신 0 · 로컬 기억 0 · 결과 = headline + reasonCode 원문(요약·의역 0) · 뷰어(주입 null) = 카드 탭 부재.
🔴 셸 파일(shell_scaffold · shell_router · shell_common · shell_providers 의 기존 줄 · ops_* · alerts · watchdog_board)·R13·R14 테스트·PNG 는 고치지 않는다 — 셸 연결은 레지스트리 칸(조립 앱 몫 · 이 카드 밖).
하지 않는 것: O-01~O-03 단계 목록·상세·검증(R15b) · O-04 마무리(R15c) · R-01 재시작·V-01 페어링(R15d) · OperatingModeView(current · trust · switchGates — M9 S05 몫) · watchSteps ·
  asOf 머리·오래됨 배너(이 카드 VM 에 asOf 없음) · 첫 실행 판정(조립 앱) · 셸 가드 · 조립 앱 배선 · domain_contracts·pubspec 수정 · 다른 ui_* 수정 · 내보내기·공유·인쇄(04 §2-1 금지 5).
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 19항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R14a·R14b(병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-s01-shell · ui/m8-h01-home · ui/m8-n01-alerts · ui/m8-w01-watchdog)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_shell/lib/src/onboarding/ 이 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m8-w01-watchdog(R14b) 일 것입니다 — 다른 ui/m6-*·ui/m8-* 여도 멈추지 않음
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m8-o00-mode-pick origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git grep -c "contractVersion = '1.16.0'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»(계약 v1.16 · M2 가지 `aaefdbc` 실측 = 1.16.0 · 🔵 엔진 레인이 먼저 올렸으면 통합 담당이 이 줄을 다시 잰 뒤 보낸다)
  git grep -c "Stream<OnboardingStartVm> watchStart();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart    ← «…onboarding_repository.dart:1»(v1.16)
  git grep -c "Stream<OnboardingModeChoiceVm> watchModeChoice();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart  ← «…onboarding_repository.dart:1»(v1.16)
  git grep -c "abstract class OnboardingStartVm" -- packages/domain_contracts/lib/src/dto/onboarding.dart                     ← «…onboarding.dart:1»(v1.16 · 온보딩 VM 파일)
  git grep -c "abstract class OnboardingTrackCard" -- packages/domain_contracts/lib/src/dto/onboarding.dart                   ← «…onboarding.dart:1»(v1.16)
  git grep -c "abstract class OnboardingModeChoiceVm" -- packages/domain_contracts/lib/src/dto/onboarding.dart                ← «…onboarding.dart:1»(v1.16)
  git grep -c "OperatingMode? selected," -- packages/domain_contracts/lib/src/dto/onboarding.dart                             ← «…onboarding.dart:1»(v1.16 · 기본값 없음 = null)
  git grep -c "String? lockedLabel," -- packages/domain_contracts/lib/src/dto/onboarding.dart                                 ← «…onboarding.dart:1»(v1.16)
  git grep -c "onboardingOperatingModeSelect" -- packages/domain_contracts/lib/src/commands/settings_actions.dart              ← «…settings_actions.dart:2»(v1.16 args 화이트리스트 · 결과 읽기 주석)
  git grep -c "class UnimplementedOnboardingRepository" -- packages/domain_contracts/lib/testing.dart                         ← «…testing.dart:1»(v1.16)
  git grep -c "class UnimplementedSettingsActions" -- packages/domain_contracts/lib/testing.dart                              ← «…testing.dart:1»(v1.12 · 기존)
  git grep -c "static const String m8OnboardingStart =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart       ← «…fixture_paths.dart:1»(v1.16)
  git grep -c "static const String m8OnboardingModeSelectResults =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart  ← «…fixture_paths.dart:1»(v1.16)
  git grep -c "final Provider<AppLinkOpener> shellLinkOpenerProvider" -- packages/ui_shell/lib/src/routing/shell_router.dart  ← «…shell_router.dart:1»(R13a)
  git grep -c "class ShellErrorView" -- packages/ui_shell/lib/src/common/shell_common.dart                                   ← «…shell_common.dart:1»(R13a)
  git grep -c "List<String?> shownTexts" -- packages/ui_shell/test/shell_fakes.dart                                          ← «…shell_fakes.dart:1»(R13a 도우미)
  git grep -c "static const String alertsAckNotAccepted" -- packages/ui_shell/lib/l10n/labels.dart                            ← «…labels.dart:1»(R14a 절의 마지막 상수 — 이 뒤에 R15a 절)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                       ← «…prompt_M8.md:1»(아래 줄 번호가 이 판 기준 · 없으면 멈춤)
  ls docs/ai-context/send/R15a-Bob-O00O00b.md                               ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/O00O00b_questions.md                             ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m8/onboarding_start.json            ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_start_no_viewer.json  ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_mode_unselected.json  ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_mode_auto.json        ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_mode_advisory.json    ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_mode_locked.json      ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_mode_select_results.json  ← 보여야 함(v1.16 · ActionResult 2행)
     (🔴 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 계약 v1.16 보다 카드가 먼저 왔습니다 · && 가 안 되는 셸이면 한 줄씩)
  아래 네 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 들어간 것 — 멈추고 알림):
  ls packages/ui_shell/lib/src/onboarding                                   ← 없어야 함
  ls packages/ui_shell/test/onboarding_start_test.dart                      ← 없어야 함
  git grep -c OnboardingModePick -- packages/ui_shell/lib                   ← 출력 없음이어야 함
  git grep -n " implements " -- packages/ui_shell/test/shell_fakes.dart     ← 출력 없음이어야 함(R14 가 extends 로 바꿨다)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · 브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_shell
  flutter test   ← 시작 기준: v1.16 병합본 전부 통과 · 0 실패 · 기대 «+193: All tests passed!»(재드라이런 2 실측 — v1.16 실물 위 · 병합 기록 때 병합본에서 다시 잰다)(앞 시각은 달라도 된다)(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · 다르면 멈추지 말고 PR 본문에 까닭 한 줄 —
                   그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 계약 v1.16 이름표 — 이 카드가 쓰는 새 이름(0단계가 확인한 것 · 🔴 코드가 정본 — 아래와 다르면 멈추고 질문 파일에 · ✅ v1.16 실제 글자 = 설계서 §4 · 01 §25)
  dto/onboarding.dart  OnboardingStartVm({required String headline, required List<OnboardingTrackCard> tracks, OnboardingTrackCard? viewerTrack})
                       — headline = 첫 화면 머리(엔진) · tracks = 계정 축 갈래(fresh · reconnect — 엔진 차례) · viewerTrack = 조회 전용 갈래(null = 첫 화면에 내지 않음 — 되돌림 자리)
                     OnboardingTrackCard({required OnboardingTrack track, required String title, required String estimatedText, String? deepLink})
                       — track = 엔진 표지(🔴 화면 미참조) · estimatedText = «약 60~90분» 류(엔진) · deepLink = 다음 화면(엔진이 완성 · 표본 `aaq://onboarding/mode`·`restart`·`pairing` · null = 탭 없음)
                     OnboardingModeChoiceVm({required String headline, required List<OperatingModeOption> options, OperatingMode? selected, required String recordGapNotice, required String honestyText, String? nextDeepLink, String? lockedLabel})
                       — options = 카드 2장(엔진 차례 · 기존 OperatingModeOption{mode, title, body, prepLine, honestyLine}) · selected = 고른 값(🔴 null = 아직 안 고름 · 기본값 없음) ·
                         recordGapNotice = 하단 고정 고지 · honestyText = 정직 고지 한 문단(기대치 숫자는 이 문장 안에만) · nextDeepLink = O-01 링크(`aaq://onboarding/steps` · 고른 뒤에만 · null = «다음» 부재) ·
                         lockedLabel = committed_at 뒤 읽기 전용 문장(non-null = 카드 탭 부재)
  repositories/onboarding_repository.dart  Stream<OnboardingStartVm> watchStart(); · Stream<OnboardingModeChoiceVm> watchModeChoice();(추가형 · 스트림 에러 = 읽기 실패) · watchSteps 그대로(R15b 몫 · 이 카드 미호출)
  commands/settings_actions.dart  args 화이트리스트 onboardingOperatingModeSelect = {operating_mode ∈ {AUTO_TRADE, ADVISORY}}(값 = OperatingMode.wire · O-04 완료 뒤 = 거부 결과 `ONBOARDING_CHOICE_COMMITTED`(OnboardingResultCodes.choiceCommitted) · 같은 값 재선택 = 접수 · 저장 = 엔진이 onboarding_choice 에 · 결과 읽기 = headline + reasonCode 원문 — retryable 은 O-03 몫 · 이 카드 표본 전부 false)
  testing.dart  UnimplementedOnboardingRepository(받침대 · 동기 throw) · UnimplementedSettingsActions(기존 · run = Future 에러 · watch = 에러 스트림)
  FixturePaths  m8OnboardingStart · m8OnboardingStartNoViewer · m8OnboardingModeUnselected · m8OnboardingModeAuto · m8OnboardingModeAdvisory · m8OnboardingModeLocked · m8OnboardingModeSelectResults(아래 «픽스처» 표)
  AppRoutes  온보딩 라우트 6(onboardingStart `…/start` · onboardingModePick `…/mode` · onboardingSteps `…/steps` · onboardingFinish `…/finish` · onboardingRestart `…/restart` · onboardingPairing `…/pairing` — 앞머리 `aaq://onboarding` · all 64 에서 onboardingStep 앞 · 🔴 이 카드는 상수를 쓰지 않는다 — 링크는 데이터) · 셸 가드 무변경
  🔴 쓰지 않는 것: OperatingModeView(current · label · explainLine · trust · switchGates — M9 S05 몫) · FixturePaths.m8OnboardingModePick · watchSteps · OnboardingStep.

■ 규칙 요약 (전문 = prompt_M8.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §2-11·§4-1·§4-3 > 04 §9-1·§9-1b 본문·그림 17·28 > prompt_M8.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_shell + docs/ai-context/inbox/O00O00b_questions.md 만. 새 파일 = lib/src/onboarding/onboarding_start.dart · onboarding_mode_pick.dart · test/onboarding_start_test.dart · test/onboarding_mode_pick_test.dart ·
   test/golden/o00_golden_test.dart · test/golden/o00b_golden_test.dart · 새 PNG 8.
   공용 4파일은 **끝 절 더하기만**(기존 줄 한 글자도 바꾸지 않는다 · 정적 O29 의 삭제 수 0): lib/l10n/labels.dart = ShellLabels 안 R14a 절의 마지막 상수(alertsAckNotAccepted) 뒤 · 닫는 } 앞에 R15a 절 ·
     lib/src/shell_providers.dart = 파일 끝에 R15a 절(주입 2) · lib/ui_shell.dart = export 두 줄(자리 = 정렬 차례 — export 'src/onboarding/onboarding_mode_pick.dart'; export 'src/onboarding/onboarding_start.dart'; 는 export 'src/alerts/alert_detail.dart'; 바로 뒤) ·
     test/shell_fakes.dart = 파일 끝에 R15a 절.
   고치면 반려: 그 밖의 ui_shell 파일 전부(lib/src/shell_scaffold.dart · routing/shell_router.dart · common/shell_common.dart · ops_rhythm.dart · ops_home.dart · alerts/* · watchdog_board.dart · R13·R14 테스트 · 비교기 2파일 · golden_support.dart ·
     golden README · test/ui_shell_test.dart · goldens/ 의 기존 PNG · pubspec.yaml · analysis_options.yaml · README.md) · domain_contracts/** · apps/** · 다른 ui_*.
 2 화면은 받은 글자와 null 여부만 본다 — 값 = DTO 의 headline · title · estimatedText · body · prepLine · honestyLine · recordGapNotice · honestyText · lockedLabel · 결과 headline · reasonCode 원문 그대로 ·
   원값 표시 금지(mode.wire 는 args 값 한 곳에만 · 글자로 그리지 않는다) · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = labels.dart 의 ShellLabels 에만(테스트에도 금지) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱만).
 3 읽지 않는 필드(카드가 정함 — 질문 아님): OnboardingTrackCard 의 track(🔴 갈래를 화면이 모른다 — 분기 0) · ActionResult 의 actionRunId · id · level · handoffRoute · retryable(🔴 결과 줄 = headline + reasonCode 뿐 · 성공/실패를 화면이 판정 0) ·
   OperatingModeView 전부(이 카드는 그 타입을 import 해도 쓰지 않는다 — 쓰면 반려).
 4 이동 = AppLinkOpener.open(link) 하나(ref.read(shellLinkOpenerProvider) · 탭 콜백 안) — 링크 = 갈래 탭 tracks[i].deepLink · 조회 갈래 탭 viewerTrack.deepLink · «다음» nextDeepLink 셋뿐 · 🔴 lib 에 'aaq://' 리터럴 0 · AppRoutes 0 · 링크 조립·파라미터·비교 0 ·
   카드 탭 = 쓰기(run)이지 이동이 아니다(탭 뒤 open 0) · 공개 위젯 생성자 = OnboardingStart({super.key}) · OnboardingModePick({super.key}) 둘.
 5 산술·판정 0 — 허용되는 것은 다섯뿐이다: ⓐ null 여부(deepLink · viewerTrack · nextDeepLink · lockedLabel · reasonCode · 주입 · _result) ⓑ 고른 표시 비교 하나(카드마다 option.mode == picked · picked = vm.selected 를 한 번 읽은 지역 변수) ·
   ⓒ 카드 탭 가능 = 주입 non-null ∧ lockedLabel == null ∧ !_busy(한 식 · 화면 판정이 아니라 데이터·주입·기다림의 null·bool 여부) ⓓ 쓰기 조각 상태 bool 둘 + 결과 하나(_busy · _failed · _result) ⓔ 순번(indexed). 그 밖에 거르기·세기·정렬·자르기 0 ·
   목록 길이·int 를 글자로 0 · maxLines · TextOverflow · FittedBox · .trim( 0 · DateTime.now 0 · DateFormat·NumberFormat 0 · FeatureFlags·RunMode 0 · OperatingMode 를 switch·if 로 가르기 0(모드별 모양 0 — 두 카드는 같은 코드로 그린다).
 6 switch 0 — 이 카드의 열거값(OnboardingTrack · OperatingMode · UiLevel)은 화면에서 가르지 않는다(갈래·모드·결과 등급 모양 0).
 7 공통 조각 = R13a 의 ShellSkeleton · ShellErrorView 재사용(상대 경로 import · ShellAsOfHeader·ShellStaleBanner 는 쓰지 않는다 — asOf 0) · 새 공용 조각 0 · 상태 갈래 = 아래 «상태 표» 글자 그대로(구독마다) · 스피너 금지 · 시계 미사용.
 8 두 화면은 본문이다 — Scaffold·AppBar·SafeArea·Navigator 0 · 부모 높이 안 ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 · 간격·크기는 정수·N.0 만.
 9 프로바이더 — 이름·타입·파일 = 아래 «주입 구조» 글자 그대로 · autoDispose 0 · 새 주입 2(throw 기본값) · 데이터 2(파일 안 private StreamProvider) · 탭 핸들러 안 ref.read · 데이터와 «주입 null 여부»는 build 에서 ref.watch ·
   🔴 autofocus · FocusNode · requestFocus 0(포커스 = 기본값의 한 꼴 · 정적 O28).
10 테스트 = 받침대 extends(UnimplementedOnboardingRepository · UnimplementedSettingsActions) · 🔴 implements 가짜 0(정적 O30) · 받은 인자 전부 기록 · 호출마다 새 Stream/Future · 가짜 공장 = 받은 call 로 삼항(C4r4b-7) · 따로 세는 변수 = 호출 수 칸뿐 ·
   공장 안 early-return if 0 · 픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지 · C4r4b-6) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다(C4r4b-1) — 자리 = testWidgets 본문 첫머리
     (main() 바로 아래의 expect 는 테스트 밖이라 파일 적재가 OutsideTestException 으로 실패한다) · 전제 문장마다 끝에 `// pre`(ASCII · 정적 O34 가 센다 = 최소 목록의 «(전제)» 수) · 동작은 UI 를 실제로 눌러서 ·
   🔴 경우 for 는 testWidgets 밖(C4r14b-1): for (final _Case c in cases) { testWidgets('<번호> <요지> ${c.name}', (WidgetTester tester) async { … }); } · 경우 칸 name 은 테스트 이름에 쓴다(안 쓰는 칸 0 · 테스트 수 = 경우 수) ·
     경우 이름 = 레코드 name 칸 글자(비교식·삼항으로 짓지 않는다 · C4r14a-4) · 흐름 = 클로저 칸 non-null — 흐름이 없는 경우도 (WidgetTester t) async {} 를 넣고 본문은 if 없이 await c.flow(tester); 한 줄(C4r14b-2) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(ShellLabels.retry), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(전부 픽스처 · copyWith 0 — 정적 O31) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 가짜의 호출 기록은 목록 == 목록 · 픽스처마다 갈리는 단언은 if/else 양쪽에 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴 ·
   🔴 «부재 = 데이터» 테스트(잠금·조회 갈래 없음)는 주입을 operator 로 못박는다(뷰어로 띄우면 탭 부재 단언이 공허 · C4r14a-6) ·
   테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII · «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2) ·
   🔴 반려 꼴: bool 칸 + if 로 경우 흐름 가르기 · nullable 흐름 칸(Function(…)? flow) + if (c.flow != null) · c.name == / flow.name == 비교 · opened[0] 만 보기 · expect(a || b, isTrue) · 괄호 단언(«X 0(Y 0)» — 단언마다 따로) ·
     단언 없는 tester.takeException();(쓰면 expect(tester.takeException(), isNull) 꼴 · 정적 O35) ·
   제네릭 위젯 술어 = tester.widget<Card>(find.byKey(…)) · tester.widget<InkWell>(find.descendant(of: find.byKey(…), matching: find.byType(InkWell))) 꼴만(🔴 find.byType(Card)·find.byType(Icon) 류를 단독으로 세면 늘 참 · C4r5a-4) ·
   스켈레톤 1 = expect(find.byKey(const Key('o00-loading')), findsOneWidget) 꼴 · Key 를 단 묶음(Padding·Card)의 글자 = shownTexts(tester, find.byKey(…)) == 기대 목록(R13a 도우미 · 트리 순서) ·
   🔴 Key 가 Text 자체에 붙은 자리는 shownTexts 가 [] 를 낸다(find.descendant 는 뿌리를 세지 않는다) → 이 카드는 Key 를 Text 에 달지 않는다(전부 Padding·Card·FilledButton · 아래 «Key 표»).
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 한 줄(n = 정수 리터럴 — 이 카드 = 2) · 🔴 전제에 hasLength 0 ·
      정적 O20·O21 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(onboarding_start_test ⓡ 5 · ⓗ 1 · onboarding_mode_pick_test ⓡ 11 · ⓗ 1).
   «없는 쪽» 견본 · «화면 Text 전부» 견본 = 아래 글자 꼴(이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
        final OnboardingTrackCard? viewer = c.v.viewerTrack;     // 경우 칸 = 입력 VM(present = start · absent = noViewer)
        if (viewer != null) {
          expect(shownTexts(tester, find.byKey(const Key('o00-viewer'))), trackCardTexts(viewer));
        } else {
          expect(find.byKey(const Key('o00-viewer')), findsNothing);
          expect(find.byKey(const ValueKey<String>('o00-track-1')), findsOneWidget);   // 양성 기준점
        }
        🔴 반려 꼴: if (viewer != null) { expect(…); }(else 없음) · if (x != null) { expect(x, isNotNull); … }(if 안의 전제 = 늘 참)
        «화면 Text 전부»(R13a T02-07 꼴 · allowed = onboardingStartAllowed(c.v) / modePickAllowed(c.v) · 🔴 견본 뒤 ⓡ 는 테스트 끝 한 줄만 — 견본 안에 ⓡ 를 두지 않는다):
        final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(allowed));
        }
11 골든 = 새 PNG o00_* 2장 · o00b_* 6장 · --update-goldens 는 o00_golden_test.dart · o00b_golden_test.dart 만(파일 지정 · 폴더 지정 금지) · 기존 PNG(40장) 재생성 0 · golden:approved 안 붙임 ·
   🔴 높이(kGoldenPhoneSize 844)는 늘리지 않는다(카드 확정값 · 여백을 줄이면 «측정:» 전·후 행).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(5분 넘게 출력이 없으면 끊고 패키지별 flutter test) ·
   패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · close_sinks · prefer_final_locals.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 화면에는 산술이 없다).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — lib/src/onboarding/ 주석에 이 낱말을 쓰지 않는다: current · OperatingModeView · switchGates · trust · track · autofocus · FocusNode · TextField · SecretField · skip · DateTime.now · AppRoutes · FeatureFlags · runMode ·
   Duration · Colors · RichText · autoDispose · Scaffold · Navigator · level · retryable · actionRunId · handoffRoute · 권장 · 추천 · 권유 · 자문 · 시그널 · 건너뛰.
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려** · 카드 구멍 = 반려 근거 아님.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다).
   PNG 는 이름마다 light 한 장만 연다(4장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지) · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 n줄» = PNG 의 글자 **행** 수(이어진 글자 행은 한 덩어리 «글자 n줄» — «글자 1줄 → 글자 1줄» 로 쪼개지 않는다 · C4r14a-3) · «상자» = 테두리·모서리가 보이는 덩어리 · «나란한 상자 2» = 가로로 붙은 두 상자 · «버튼 글자» = 채운 버튼 하나 ·
     «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다 · 🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다).
     🆕 사전검사 G1 은 표의 «나란한 상자 2» 를 상자 1 · «버튼 글자» 를 글자 1줄로 읽고(앞 글자 덩어리와 합친다) PNG 는 상자 2 · 버튼 = 상자(안 글자 1줄)로 센다 — 표 칸은 이 카드 단위 그대로 · 그 차이로 나는 🟡 = ■ 제출 N3 «드라이런 기대 🟡» 6행(그대로 · 다시 열지 않음 · 드라이런 지적 · 재드라이런 2 같은 6행).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 제출 글은 저장 파일로) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · 출력 줄 수만큼) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M8.md 173~182행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외).

■ 프롬프트보다 이 카드가 이긴다 — 19항 (prompt_M8.md 183줄 판 v2)
 ① 2행 {{범위}} = S-01 · 119행 → 이 카드의 범위 = O-00 · O-00b
 ② 113~118행 역할·범위 → 이 카드 = O-00·O-00b · O-01~O-03 = R15b · O-04 = R15c · R-01·V-01 = R15d · S-01·S-02·H-01·H-02 = R13 · N-01·N-02·W-01 = R14(병합됨) · 그 밖 = R16
 ③ 12~13행 의존 셋 → 추가 0 · pubspec 무변경
 ④ 15~19행 링크는 데이터 → 그대로 유효(갈래 탭 = deepLink · 조회 갈래 = viewerTrack.deepLink · «다음» = nextDeepLink · null = 부재 · 상수 진입 0)
 ⑤ 20~23행 DateTime.now 금지 · 신선도 → DateTime.now 금지 그대로 · 🔵 이 카드 = 신선도 판정 0(VM 에 asOf 없음 · 발주자 확인 ⑤) → 시계 미사용
 ⑥ 24~31행 금지 4항 · 산술·집계·거르기·재정렬 → 그대로 유효(카드·갈래 = 받은 차례 · 고른 표시 = 데이터 비교 하나) + 04 §2-1 금지 5(내보내기·공유·인쇄 0)
 ⑦ 32~35행 한국어 리터럴 = labels.dart → 그대로 유효 + 🆕 «권장»·«추천» 0(04 §9-1b (c) — 라벨·주석에도 · 정적 O23 · O37)
 ⑧ 36~38행 «아무 일 없음 문장 금지» → 그대로 유효(문장 = 엔진 글자뿐)
 ⑨ 41~47행 안전 화면 금지 → 그대로 유효(🔒 M5 위저드·게이트 = 이 카드 밖 · 잠금 뒤 변경 경로 = runtimeOperatingModeSwitchRequest → M5-11 · 이 카드에 그 버튼 0)
 ⑩ 48~57행 모드 접두·띠 = 셸 → 그대로 유효 · 🔴 O-00b 는 «모드를 고르는» 화면이지만 고른 값은 데이터 selected 로만 읽는다(FeatureFlags.operatingMode 0 · 모드별 모양 0)
 ⑪ 68~74행 수치 리터럴 금지 → 그대로 유효(정직 고지 = honestyText 엔진 문장 · 10.2·9.7·8.38·35.05 리터럴 0 · «안내가 자동보다 몇 %p» 0)
 ⑫ 87~105행 «■ 제출» → 그대로 유효 · 글자·명령 = 아래 «■ 제출»(저장 파일 BOM 0 · 채팅 두 줄)
 ⑬ 106~111행 질문 파일 → inbox/O00O00b_questions.md
 ⑭ 127~128행 브랜치·PR 제목 형식 → ui/m8-o00-mode-pick · «[M8] O-00·O-00b 첫 실행·운영 방식 선택»
 ⑮ 145~150행 온보딩 조문 → 그대로 유효 — 판정·저장 = SettingsActions.run 결과 · 주입 null = 렌더 0(이 카드 = 카드 탭 부재) · 건너뛰기 0 · SecretField·해외주식·금 상한·복구 카드 = 이 카드 범위 밖(R15b·R15c)
 ⑯ 151~152행 실패 문구 의역 금지 → 그대로 유효(결과 줄 = headline + reasonCode 원문 · 예외 = 정적 «접수되지 않았습니다»)
 ⑰ 158~162행 «온보딩 1단계의 기대치» · «온보딩 5단계의 램프 L1» → 이 카드 범위 밖(R15c · 🔵 낡은 글자 = 1단계 = O-04 1단계(P0S 확인) · «5단계» = 지금 6단계(04 §9-5 머리 · 서약문 신설로 밀림))
 ⑱ 163~164행 X7 O-00b 기본값 없음 → 그대로 유효 + 이 카드 «화면 2» 가 글자를 정한다(체크·포커스·«다음» 0 · 배지·시각 우대 0)
 ⑲ 172~182행 자체 점검 10항 → «■ 제출» ② 복사 상자 + 괄호(괄호 글자 = ■ 제출 ② «붙일 괄호» 가 정본 · 범위 밖도 [x] · 섹션 머리는 «12항» 그대로 — 사전검사 R1)

■ 먼저 읽을 것 (🔴 02·03·05 명세는 읽지 않음)
 ① prompt_M8.md 전문 ② 04 §9 머리(게이트 판정 = Claude) · §9-1(O-00 · 그림 17) · §9-1b(O-00b · 표 · 수용 (a)~(e) · 그림 28) · §2-5(플랫폼) · §11-11
 ③ 01 §2-11 OperatingModeOption · §4-1 OnboardingRepository · §4-3 SettingsActions · §6-3 onboarding_choice · §25(계약 v1.16 · R15 선행 · 이름표 정본)
 ④ packages/domain_contracts/lib/ — dto/handover.dart(OperatingModeOption) · dto/onboarding.dart(OnboardingStartVm · OnboardingTrackCard · OnboardingModeChoiceVm) · repositories/onboarding_repository.dart · commands/settings_actions.dart(ActionResult · args 화이트리스트) ·
    enums/mode.dart(OperatingMode · wire) · enums/onboarding.dart(OnboardingTrack) · enums/command.dart(SettingsActionId.onboardingOperatingModeSelect) · testing.dart(UnimplementedOnboardingRepository · UnimplementedSettingsActions · RecordingLinkOpener)
 ⑤ packages/ui_shell — lib/src/watchdog_board.dart(🔵 구독 화면 꼴 · 읽기만) · lib/src/alerts/alert_ack.dart(🔵 쓰기 조각 꼴 _busy·_failed · 읽기만) · test/alert_center_test.dart(N01-07 확인 조각 테스트 꼴) · test/shell_fakes.dart ·
    test/golden/w01_golden_test.dart · golden_support.dart · golden README «🆕 R15» 절
 ⑥ fixtures/README.md(m8 행 · v1.16) ⑦ docs/ai-context/inbox/README.md · O00O00b_questions.md 머리말

■ 본받지 않는 것
 · OperatingModeView.current 로 카드를 칠하는 것(표본 m8/onboarding_mode_pick 의 current = ADVISORY 는 «아직 안 고름» — 이 카드는 그 타입을 쓰지 않는다) · trust·switchGates 를 O-00b 에 그리기(M9 S05 몫)
 · ui_journal 의 journalSettingsActionsProvider(non-nullable) 꼴 — 이 카드 주입은 nullable(뷰어 null = 탭 부재) · R5e L-3 의 «화면은 ActionResult 를 읽지 않는다» — 이 카드는 headline·reasonCode 를 읽는다(두 칸만)
 · 한쪽 카드를 크게·색칠·먼저(시각 우대) · 첫 카드에 autofocus · «권장»·«추천»·«대부분»·«나중에 바꾸기 어렵습니다» 류 글자 · 기대치 숫자·«몇 %p» · 화면이 두 카드를 비교해 결론 문장 · 결과 level 로 색·숨김
 · 탭하자마자 체크(낙관 갱신) · 고른 값을 State·저장소에 기억 · «다음» 을 selected 로 판정 · 잠금을 화면이 판정 · 카드 탭 = 이동 · Radio·Checkbox·SegmentedButton·ChoiceChip 으로 고르기(선택 UI = 카드 탭뿐)
 · O-00 에 운영 방식 갈래(4번째)·O-01 목록 안 운영 방식 행 · 갈래 이름·소요 시간 리터럴 · 조회 갈래를 tracks 와 같은 클래스·같은 Key 로 · track 으로 갈래 분기 · 첫 실행 판정 코드
 · 셸 파일(shell_router 가드 표 · shell_scaffold)에 온보딩 진입 더하기 · implements 가짜 · 한국어 테스트 이름 · 조건부 단언 · lib nullable 에 !

■ 주입 구조
· 🆕 lib 파일 2개:
  lib/src/onboarding/onboarding_start.dart — OnboardingStart(공개 · ConsumerWidget) · _startProvider · _TrackCard(ConsumerWidget) · _ViewerTrackCard(ConsumerWidget · 🔴 조회 갈래 전용 클래스 — 되돌림 자리)
  lib/src/onboarding/onboarding_mode_pick.dart — OnboardingModePick(공개 · ConsumerStatefulWidget) · _modeChoiceProvider · _ModeCard(StatelessWidget — index · option · picked · onTap)
  import 차례 = (onboarding_mode_pick 만 'dart:async') → package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart → ../../l10n/labels.dart(안 쓰면 뺀다) → ../common/shell_common.dart → ../routing/shell_router.dart → ../shell_providers.dart
· 🆕 주입 2 = lib/src/shell_providers.dart 끝 R15a 절(아래 글자 그대로 · 기존 줄 0 변경):
    // ── R15a — O-00·O-00b injection providers ──────────────────────────────────
    final Provider<OnboardingRepository> shellOnboardingRepositoryProvider = Provider<OnboardingRepository>((Ref ref) => throw UnimplementedError('shellOnboardingRepositoryProvider must be overridden'));
    final Provider<SettingsActions?> shellOnboardingActionsProvider = Provider<SettingsActions?>((Ref ref) => throw UnimplementedError('shellOnboardingActionsProvider must be overridden'));
    (format 이 R14a 절처럼 여러 줄로 나눈다 · 🔵 operator 빌드 = 조립 앱이 구현체 · 뷰어 빌드 = overrideWithValue(null))
· 데이터 2 = final StreamProvider<OnboardingStartVm> _startProvider = StreamProvider<OnboardingStartVm>((Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchStart()); ·
           final StreamProvider<OnboardingModeChoiceVm> _modeChoiceProvider = StreamProvider<OnboardingModeChoiceVm>((Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchModeChoice());
· 🆕 배럴 lib/ui_shell.dart 에 export 두 줄(자리 = export 'src/alerts/alert_detail.dart'; 바로 뒤 · 정렬 차례 · 삭제 0)
· 조립 앱(이 카드 밖 · 참고만): ShellRouteBodies 의 AppRoutes.onboardingStart · onboardingModePick 칸 = (_) => const OnboardingStart() · (_) => const OnboardingModePick()(06 M4-11).

■ 호출 표
 OnboardingStart — 부르는 것: watchStart() 한 번(재시도 = 한 번 더) · shellLinkOpenerProvider(갈래 탭 콜백 안). 부르지 않는 것: watchModeChoice · watchSteps · SettingsActions · shellClockProvider · AppRoutes.isRegistered.
 OnboardingModePick — 부르는 것: watchModeChoice() 한 번(재시도 = 한 번 더) · run(SettingsActionId.onboardingOperatingModeSelect, args: <String, String>{'operating_mode': option.mode.wire})(카드 탭마다 한 번 · 기다리는 동안 0) · shellLinkOpenerProvider(«다음» 콜백 안).
   부르지 않는 것: SettingsActions.watch · 다른 SettingsActionId · watchStart · watchSteps · OperatingModeView 를 내는 창구 · shellClockProvider.

■ 상태 표 (구독마다 — 꼴 = R14b WatchdogBoard)
 start   hasError → ShellErrorView(key: const Key('o00-fail'), onRetry: () => ref.invalidate(_startProvider)) · 값 전 → ShellSkeleton(key: const Key('o00-loading')) · 값 → 아래 «화면 1»
 choice  hasError → ShellErrorView(key: const Key('o00b-fail'), onRetry: () => ref.invalidate(_modeChoiceProvider)) · 값 전 → ShellSkeleton(key: const Key('o00b-loading')) · 값 → 아래 «화면 2»
 (lastAsOfLabel = 넘기지 않는다 — asOf 0 · 🔵 값 뒤 에러 = 에러 화면(마지막 글자 0) · 쓰기 조각 상태(_busy·_failed·_result)는 구독 갈래와 따로 · 에러 화면으로 바뀌어도 초기화 0)

■ 화면 1 — O-00 (위 → 아래 · 🔴 이 순서)
 머리    Padding(key: const Key('o00-headline'), EdgeInsets.fromLTRB(16, 16, 16, 8), Text(vm.headline))                                          · 늘
 갈래    for (final (int i, OnboardingTrackCard t) in vm.tracks.indexed) _TrackCard(index: i, card: t)                                     · 받은 차례
         _TrackCard = Card(key: ValueKey<String>('o00-track-$index'), margin: EdgeInsets.fromLTRB(16, 0, 16, 12), child: InkWell(onTap: link == null ? null : () { ref.read(shellLinkOpenerProvider).open(link); },
           child: Padding(EdgeInsets.all(16), child: Column(crossAxisAlignment: start)[ Text(card.title) · SizedBox(height: 4) · Text(card.estimatedText) ])))   ← final String? link = card.deepLink;
 조회    (viewer != null) _ViewerTrackCard(card: viewer)                                                                                  ← final OnboardingTrackCard? viewer = vm.viewerTrack;(다른 조건 0)
         _ViewerTrackCard = _TrackCard 와 같은 모양 · Key = Card(key: const Key('o00-viewer')) · 🔴 별도 클래스(청사진 §9-1b ⑦ «한 위젯으로 분리» — 되돌림 = 엔진이 viewerTrack 을 null 로) · 탭 = viewer.deepLink(null = 탭 없음)
 🔴 운영 방식 갈래·4번째 카드·«다음» 버튼 0 · track 미참조

■ 화면 2 — O-00b (위 → 아래 · 🔴 이 순서)
 머리    Padding(key: const Key('o00b-headline'), EdgeInsets.fromLTRB(16, 16, 16, 8), Text(vm.headline))                                         · 늘
 카드    Padding(EdgeInsets.symmetric(horizontal: 12), IntrinsicHeight(Row(crossAxisAlignment: CrossAxisAlignment.stretch, [ for (final (int i, OperatingModeOption o) in vm.options.indexed)
           Expanded(_ModeCard(index: i, option: o, picked: o.mode == picked, onTap: pick == null ? null : () { unawaited(pick(o.mode)); })) ])))
         ← final OperatingMode? picked = vm.selected;(🔴 이 한 줄만 selected 를 읽는다) · final SettingsActions? actions = ref.watch(shellOnboardingActionsProvider); · final String? locked = vm.lockedLabel; ·
           final Future<void> Function(OperatingMode m)? pick = (actions == null || locked != null || _busy) ? null : (OperatingMode m) => _pick(actions, m);(규칙 5 ⓒ 한 식)
         _ModeCard = Card(key: ValueKey<String>('o00b-card-$index'), margin: EdgeInsets.all(4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: picked ? cs.primary : cs.outlineVariant, width: 2)),
           child: InkWell(onTap: onTap, child: Padding(EdgeInsets.all(12), child: Column(crossAxisAlignment: start)[ Row[ Expanded(Text(option.title)) · (picked) Icon(Icons.check_circle, key: ValueKey<String>('o00b-check-$index'), color: cs.primary) ] ·
           SizedBox(height: 8) · Text(option.body) · SizedBox(height: 8) · Text(option.prepLine) · SizedBox(height: 8) · Text(option.honestyLine) ])))
         🔴 두 카드 = 같은 코드·같은 여백·같은 글자 모양(모드로 가르지 않는다) · 다른 점은 picked 의 테두리 색·체크 아이콘 둘뿐 · color·elevation 칸 = 두 카드 같은 값(지정하지 않으면 기본값 그대로)
 잠금    (locked != null) Padding(key: const Key('o00b-locked'), EdgeInsets.fromLTRB(16, 8, 16, 0), Text(locked))
 결과    (_failed) Padding(key: const Key('o00b-not-accepted'), EdgeInsets.fromLTRB(16, 8, 16, 0), Text(ShellLabels.onboardingNotAccepted)) ·
         (r != null) Padding(key: const Key('o00b-result'), EdgeInsets.fromLTRB(16, 8, 16, 0), Column(crossAxisAlignment: start)[ Text(r.headline) · (code != null) Text(code) ])
         ← final ActionResult? r = _result; final String? code = r?.reasonCode;(🔴 level·retryable 미참조 · _failed 와 r 은 함께 서지 않는다 — _pick 이 둘을 같이 바꾼다)
 고지    Padding(key: const Key('o00b-record-gap'), EdgeInsets.fromLTRB(16, 16, 16, 0), Text(vm.recordGapNotice)) · Padding(key: const Key('o00b-honesty'), EdgeInsets.fromLTRB(16, 8, 16, 0), Text(vm.honestyText))      · 늘
 다음    (next != null) Padding(EdgeInsets.fromLTRB(16, 16, 16, 16), FilledButton(key: const Key('o00b-next'), onPressed: () { ref.read(shellLinkOpenerProvider).open(next); }, child: const Text(ShellLabels.onboardingNext)))
         ← final String? next = vm.nextDeepLink;(🔴 다른 조건 0 — «selected 가 있으면» 판정 금지)
 _pick(SettingsActions a, OperatingMode m) async {
   setState(() => _busy = true);
   try { final ActionResult r = await a.run(SettingsActionId.onboardingOperatingModeSelect, args: <String, String>{'operating_mode': m.wire}); if (!mounted) return; setState(() { _busy = false; _failed = false; _result = r; }); }
   catch (_) { if (!mounted) return; setState(() { _busy = false; _failed = true; _result = null; }); } }
   🔴 세 칸을 늘 같이 바꾼다(한 칸 초기화 빼기 = 예고 변이 · C4r14a-5) · 확인 다이얼로그·SnackBar 0 · 탭 뒤 이동 0

■ 픽스처 (FixturePaths.… · singleFixture(…, X.fromJson) — v1.16 넷은 VM 1행 봉투 · 결과 = listFixture · 🔴 전제 expect 로 다시 확인)
 start        singleFixture(m8OnboardingStart, OnboardingStartVm.fromJson) — tracks 2([0] fresh · [1] reconnect · 둘 다 deepLink non-null — `aaq://onboarding/mode` · `…/restart`) · viewerTrack non-null(deepLink `aaq://onboarding/pairing`)
 noViewer     singleFixture(m8OnboardingStartNoViewer, …) — viewerTrack null · tracks 2([1].deepLink null = «탭 없음» 표본)
 unselected   singleFixture(m8OnboardingModeUnselected, OnboardingModeChoiceVm.fromJson) — options 2([0] AUTO_TRADE · [1] ADVISORY) · selected null · nextDeepLink null · lockedLabel null
 auto         singleFixture(m8OnboardingModeAuto, …) — selected AUTO_TRADE · nextDeepLink `aaq://onboarding/steps` · lockedLabel null
 advisory     singleFixture(m8OnboardingModeAdvisory, …) — selected ADVISORY · nextDeepLink `aaq://onboarding/steps` · lockedLabel null
 locked       singleFixture(m8OnboardingModeLocked, …) — selected ADVISORY · nextDeepLink null · lockedLabel non-null
 results      listFixture(m8OnboardingModeSelectResults, ActionResult.fromJson).rows — [0] 접수(level OK · reasonCode null) · [1] 거부(level BLOCKED · reasonCode `ONBOARDING_CHOICE_COMMITTED` · 원문 코드) · retryable 둘 다 false
 🔴 쓰지 않는 것: m8/onboarding_mode_pick(OperatingModeView) · onboarding_fresh·onboarding_reconnect·m8/onboarding_finish·onboarding_fresh_advisory·restart_lost_phone(뒤 카드 몫) · copyWith · 지은 DTO.

■ Key 표 (o00- 5이름 · o00b- 11이름 — 정본 · 표 밖 Key 0 · 순번만)
   o00-loading(ShellSkeleton) · o00-fail(ShellErrorView) · o00-headline(머리 Padding) · o00-track-$i(_TrackCard 의 Card) · o00-viewer(_ViewerTrackCard 의 Card) ·
   o00b-loading · o00b-fail · o00b-headline(Padding) · o00b-card-$i(_ModeCard 의 Card) · o00b-check-$i(체크 Icon) · o00b-locked(Padding) · o00b-not-accepted(Padding) · o00b-result(Padding) · o00b-record-gap(Padding) · o00b-honesty(Padding) · o00b-next(FilledButton)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 내용 · 커밋마다 git add <파일> + git show --stat HEAD · amend·rebase·강제 푸시 금지 · 마지막 = format · 질문)
 (1) lib/l10n/labels.dart R15a 절 · lib/src/shell_providers.dart R15a 절 · lib/src/onboarding/ 두 파일 · 배럴 두 줄. 커밋 «[M8] R15a (1) O-00·O-00b 화면»
 (2) test/shell_fakes.dart 끝 절 + test/onboarding_start_test.dart(O00-01~O00-06) + test/onboarding_mode_pick_test.dart(O0B-01~O0B-12) · 🔴 커밋 전에 git add <그 파일들> 뒤 «정적 묶음» 미리 돌리기(실행 꼴 그대로 ·
     git add 전이면 새 테스트 파일을 git grep 이 못 봐 O01·O02·O03·O20·O21·O30~O32·O34·O35 가 EXIT:1 로 «통과» 처럼 보인다 · 이때 O29 · O33 · 출력 줄 수는 (4) 뒤 기대와 다르다). 커밋 «[M8] R15a (2) O-00·O-00b 테스트»
 (3) 골든 8장 — test/golden/o00_golden_test.dart(1이름 × 2) · test/golden/o00b_golden_test.dart(3이름 × 2). 커밋 «[M8] R15a (3) 골든 o00_* 2장 · o00b_* 6장»
 (4) melos.bat run format:fix · analyze 한 번 · 질문 파일(O00O00b_questions.md — dy 측정 행 A1~A4). 커밋 «[M8] R15a (4) format · 질문» · 🔴 (4) 뒤 커밋 0(예외 = 사전검사 ① 🔴 · analyze · format 수정 (5) 하나 · 제목 = 까닭).

■ 정적 라벨 — 2개(ShellLabels 안 R14a 절 뒤 · 닫는 } 앞 · 이 글자 그대로 · 🔴 «권장»·«추천» 0)
    // ── 🆕 R15a — O-00·O-00b 온보딩 ──────────────────────────────────────────
    static const String onboardingNext = '다음';
    static const String onboardingNotAccepted = '접수되지 않았습니다';
  (갈래 이름·소요 시간·카드 글자·고지·결과·잠금 = 전부 VM · 정적 라벨로 만들지 않는다 · 총수 «정확히» = 마지막 카드)

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ = O20·O21 · (전제) = O34)
공통: 띄우기 = pumpOnboardingStart(tester, overrides:) · pumpOnboardingModePick(tester, overrides:)(Size(390, 2400) · DPR 1.0 · teardown 2 · ProviderScope > MaterialApp > Scaffold(body: <위젯>) · pump 두 번) ·
  overrides = onboardingOverrides(repo:, actions:, opener:)(3줄) · 경우 = for 는 testWidgets 밖 · 흐름 = 클로저 칸 non-null · 계획 = onboarding_start_test testWidgets 줄 6(테스트 13) · onboarding_mode_pick_test 줄 12(테스트 23) · 골든 2 · 합 20.
  🆕 test/shell_fakes.dart 끝 절(한국어 리터럴 0 · if 0 · collection-if 0 · «// ── R15a — O-00·O-00b fakes ──» 머리):
    class FakeShellOnboardingRepository extends UnimplementedOnboardingRepository { FakeShellOnboardingRepository({required this.start, required this.modeChoice});
      final Stream<OnboardingStartVm> Function(int call) start; final Stream<OnboardingModeChoiceVm> Function(int call) modeChoice; int startCalls = 0; int modeCalls = 0;
      @override watchStart() → final int call = startCalls; startCalls = startCalls + 1; return start(call); · @override watchModeChoice() → 같은 꼴(modeCalls) }(🔴 watchSteps 는 넘기지 않는다 — 받침대가 던진다)
    class FakeShellOnboardingActions extends UnimplementedSettingsActions { FakeShellOnboardingActions({required this.result}); final Future<ActionResult> Function(int call) result;
      final List<SettingsActionId> ids = <SettingsActionId>[]; final List<Map<String, String>> argsSeen = <Map<String, String>>[];
      @override run(SettingsActionId id, {Map<String, String> args = const <String, String>{}}) → final int call = ids.length; ids.add(id); argsSeen.add(args); return result(call); }(🔴 watch 는 넘기지 않는다)
    List<Override> onboardingOverrides({required FakeShellOnboardingRepository repo, required SettingsActions? actions, required RecordingLinkOpener opener})
        ← shellOnboardingRepositoryProvider.overrideWithValue(repo) · shellOnboardingActionsProvider.overrideWithValue(actions) · shellLinkOpenerProvider.overrideWithValue(opener) — 3줄
    Future<void> pumpOnboardingStart(WidgetTester tester, {required List<Override> overrides}) · Future<void> pumpOnboardingModePick(WidgetTester tester, {required List<Override> overrides})(R14a pumpAlertCenter 꼴)
    List<String> trackCardTexts(OnboardingTrackCard c) => <String>[c.title, c.estimatedText] · List<String> modeCardTexts(OperatingModeOption o) => <String>[o.title, o.body, o.prepLine, o.honestyLine]
    Set<String> onboardingStartAllowed(OnboardingStartVm v)(= headline · tracks 마다 title·estimatedText · ?viewerTrack?.title · ?viewerTrack?.estimatedText — null-aware 원소 · collection-for 만 · 🔴 deepLink·track 0)
    Set<String> modePickAllowed(OnboardingModeChoiceVm v)(= headline · options 마다 modeCardTexts · recordGapNotice · honestyText · ?lockedLabel · ShellLabels.onboardingNext — 🔴 mode.wire·결과 글자 0)
  `one<T>` · `shownTexts` = 앞 카드 도우미 그대로(shell_fakes.dart) · valueThenFail = 테스트 파일 머리의 비공개 도우미(main() 밖 · watchdog_board_test 꼴 — Stream<T> valueThenFail<T>(T v) async* { yield v; throw StateError('fail'); } · 값 하나 낸 뒤 에러 · 두 테스트 파일에 같은 글자) · 값 안 내는 스트림 = Stream<T>.multi((MultiStreamController<T> c) {})(닫지 않는다) ·
  끝나지 않는 Future = Completer<ActionResult>().future · test 파일 import 차례 = 'dart:async' → 'package:domain_contracts/domain_contracts.dart' → 'package:domain_contracts/testing.dart' → 'package:flutter/material.dart' →
     'package:flutter_test/flutter_test.dart' → 'package:ui_shell/ui_shell.dart' → 'golden/golden_support.dart' → 'shell_fakes.dart'(안 쓰는 것 0 — analyze 가 정본).
O-00 — test/onboarding_start_test.dart
 O00-01 머리·두 갈래·조회 갈래 글자·받은 차례(04 §9-1 · 그림 17) — start: 전제 하나: expect(start.viewerTrack, isNotNull); // pre → repo.startCalls == 1 · 사슬 dy o00-headline → o00-track-0 → o00-track-1 → o00-viewer ·
        shownTexts(o00-headline) == [start.headline] · ⓗ expect(start.tracks, hasLength(2)) → i 마다 shownTexts(o00-track-$i) == trackCardTexts(start.tracks[i]) · o00-track-2 findsNothing · shownTexts(o00-viewer) == trackCardTexts(start.viewerTrack!) ·
        find.byKey(const Key('o00b-next')) findsNothing(🔴 O-00 에 «다음» 0) · ⓡ.
 O00-02 갈래 탭 = deepLink(데이터 · 판정 0) — 네 경우 ㉠ (이름, 입력, 누를 Key, want): (fresh · start · ValueKey<String>('o00-track-0') · <String>[start.tracks[0].deepLink!]) · (reconnect · start · ValueKey<String>('o00-track-1') · <String>[start.tracks[1].deepLink!]) ·
        (viewer · start · Key('o00-viewer') · <String>[start.viewerTrack!.deepLink!]) · (unlinked · noViewer · ValueKey<String>('o00-track-1') · <String>[])마다(🆕 경우 칸 tappable bool — 앞 셋 true · unlinked false) — 전제 넷: expect(start.tracks[0].deepLink, isNotNull); // pre ·
        expect(start.tracks[1].deepLink, isNotNull); // pre · expect(start.viewerTrack!.deepLink, isNotNull); // pre · expect(noViewer.tracks[1].deepLink, isNull); // pre → 🆕 expect(tester.widget<InkWell>(find.descendant(of: find.byKey(c.key), matching: find.byType(InkWell))).onTap, c.tappable ? isNotNull : isNull)(빈 콜백 = 잉크만 남는 «탭 있음» 을 잡는다 · 드라이런 감사) → tap(c.key) → pump → expect(opener.opened, c.want) · ⓡ.
 O00-03 조회 갈래 = 데이터(분리 위젯 · null = 부재 · 되돌림 자리) — 두 경우 ㉠ (present · start) · (absent · noViewer)마다 — 전제 둘: expect(start.viewerTrack, isNotNull); // pre · expect(noViewer.viewerTrack, isNull); // pre →
        규칙 10 «없는 쪽» 견본 그대로(양성 기준점 o00-track-1) · ⓡ.
 O00-04 상태 갈래(갈래마다) — 세 경우 ㉠ (loading · Stream.multi(값 0) · present [o00-loading] · absent [o00-headline, o00-fail]) · (fail · Stream.error · [o00-fail] · [o00-headline, o00-loading]) ·
        (value_then_fail · valueThenFail(start) · [o00-fail] · [o00-headline, o00-loading])마다 Key 목록 findsOneWidget / findsNothing · CircularProgressIndicator findsNothing.
 O00-05 재시도 — 공장 = (int call) => call == 0 ? Stream<OnboardingStartVm>.error(StateError('fail')) : one(start) → tap(find.text(ShellLabels.retry)) → pump 두 번 → o00-fail findsNothing · o00-headline findsOneWidget · repo.startCalls == 2 · ⓡ.
 O00-06 화면 Text 전부 · 큰 글꼴(문구 = 엔진 · 리터럴 0) — 두 경우 ㉠ (start) · (noViewer)마다 규칙 10 «화면 Text 전부» 견본(allowed = onboardingStartAllowed(c.v) — deepLink·track 글자가 allowed 에 없어 그리면 잡힌다) →
        tester.platformDispatcher.textScaleFactorTestValue = 2.0 → pump → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = onboarding_start_test.dart 5줄(O00-01 · 02 · 03 · 05 · 06) · ⓗ 기대 = 1줄(O00-01) — 🔴 정확히 · (전제) = 7(01 1 · 02 4 · 03 2 — 정적 O34).
O-00b — test/onboarding_mode_pick_test.dart (주입 = 따로 적지 않으면 operator = FakeShellOnboardingActions · 공장 기본 = (int call) => Future<ActionResult>.value(results[0]))
 O0B-01 진입 = 어느 카드도 선택 아님(04 §9-1b 수용 (a) · 기본값 없음) — unselected: 전제 셋: expect(unselected.selected, isNull); // pre · expect(unselected.nextDeepLink, isNull); // pre · expect(unselected.lockedLabel, isNull); // pre →
        repo.modeCalls == 1 · 사슬 dy o00b-headline → o00b-card-0 → o00b-record-gap → o00b-honesty · getTopLeft(o00b-card-0).dy == getTopLeft(o00b-card-1).dy(나란히) · shownTexts(o00b-headline) == [unselected.headline] ·
        ⓗ expect(unselected.options, hasLength(2)) → i 마다 shownTexts(o00b-card-$i) == modeCardTexts(unselected.options[i]) · ValueKey<String>('o00b-check-$i') findsNothing · o00b-card-2 findsNothing ·
        shownTexts(o00b-record-gap) == [unselected.recordGapNotice] · shownTexts(o00b-honesty) == [unselected.honestyText] · o00b-next · o00b-locked · o00b-result · o00b-not-accepted 넷 다 findsNothing(단언마다 따로) · ⓡ.
 O0B-02 두 카드 = 같은 크기·같은 모양(시각 우대 0 · 04 §9-1b 금지) — unselected: final Card a = tester.widget<Card>(find.byKey(const ValueKey<String>('o00b-card-0'))); final Card b = …('o00b-card-1') ·
        expect(tester.getSize(find.byKey(…card-0)), tester.getSize(find.byKey(…card-1))) · expect(a.color, b.color) · expect(a.elevation, b.elevation) · expect(a.shape, b.shape) · expect(a.margin, b.margin) ·
        제목 글자 모양 = expect(tester.widget<Text>(find.descendant(of: card-0, matching: find.text(unselected.options[0].title))).style, tester.widget<Text>(find.descendant(of: card-1, matching: find.text(unselected.options[1].title))).style) · ⓡ.
 O0B-03 카드 탭 = run 1회(쓰기 1개 · args 화이트리스트 · 낙관 갱신 0) — 두 경우 ㉠ (auto · i 0) · (advisory · i 1)마다 — unselected → tap(o00b-card-$i) → pump →
        expect(actions.ids, <SettingsActionId>[SettingsActionId.onboardingOperatingModeSelect]) · expect(actions.argsSeen, <Map<String, String>>[<String, String>{'operating_mode': unselected.options[c.i].mode.wire}]) ·
        expect(opener.opened, <String>[])(탭 = 이동 아님) · ValueKey<String>('o00b-check-${c.i}') findsNothing(🔴 데이터가 아직 unselected — 낙관 갱신 0) · ⓡ.
 O0B-04 고른 상태 = 데이터(selected · 체크 · «다음» = nextDeepLink · 🆕 고른 뒤에도 바꿀 수 있다 — 04 §9-1b «O-04 전까지 자유») — 두 경우 ㉠ (이름, 입력, 체크 Key, 없는 체크 Key, other): (auto · auto · ValueKey<String>('o00b-check-0') · ValueKey<String>('o00b-check-1') · 1) ·
        (advisory · advisory · ValueKey<String>('o00b-check-1') · ValueKey<String>('o00b-check-0') · 0)마다 — 전제 넷: expect(auto.options[0].mode, auto.selected); // pre · expect(advisory.options[1].mode, advisory.selected); // pre ·
        expect(auto.nextDeepLink, isNotNull); // pre · expect(advisory.nextDeepLink, isNotNull); // pre → c.on findsOneWidget · c.off findsNothing · getSize(card-0) == getSize(card-1) · expect(actions.ids, <SettingsActionId>[])(데이터만으로 쓰기 0) ·
        tap(o00b-next) → pump → expect(opener.opened, <String>[c.v.nextDeepLink!]) → 🆕 tap(ValueKey<String>('o00b-card-${c.other}')) → pump → expect(actions.ids, <SettingsActionId>[SettingsActionId.onboardingOperatingModeSelect]) · expect(actions.argsSeen, <Map<String, String>>[<String, String>{'operating_mode': c.v.options[c.other].mode.wire}])(🔴 «고른 뒤 탭 막기» = 화면 판정 — 드라이런 R08) · ⓡ.
 O0B-05 결과 줄 = 엔진 글자(headline · reasonCode 원문 · 의역 0) — 두 경우 ㉠ (accepted · results[0]) · (rejected · results[1])마다 — 전제 둘: expect(results[0].reasonCode, isNull); // pre · expect(results[1].reasonCode, isNotNull); // pre →
        공장 = (int call) => Future<ActionResult>.value(c.r) · unselected → tap(o00b-card-0) → pump 두 번 → expect(shownTexts(tester, find.byKey(const Key('o00b-result'))), <String?>[c.r.headline, ?c.r.reasonCode]) · 🆕 자리 dy 두 줄: getTopLeft(o00b-card-0).dy < getTopLeft(o00b-result).dy · getTopLeft(o00b-result).dy < getTopLeft(o00b-record-gap).dy(«결과 줄을 고지 아래로» — 드라이런 M08) · o00b-not-accepted findsNothing · ⓡ.
 O0B-06 실패 ↔ 성공(쓰기 조각 세 칸 · C4r14a-5 두 방향) — 두 경우 ㉠ (fail_then_ok · 공장 (int call) => call == 0 ? Future<ActionResult>.error(StateError('fail')) : Future<ActionResult>.value(results[0]) ·
        첫 탭 뒤 present Key('o00b-not-accepted') · absent Key('o00b-result') · 둘째 탭 뒤 present o00b-result · absent o00b-not-accepted · 🆕 firstTexts <String?>[ShellLabels.onboardingNotAccepted] · secondTexts <String?>[results[0].headline, ?results[0].reasonCode]) · (ok_then_fail · 공장 (int call) => call == 0 ? value(results[0]) : error · 첫 탭 뒤 present o00b-result · absent o00b-not-accepted ·
        둘째 탭 뒤 present o00b-not-accepted · absent o00b-result · 🆕 firstTexts <String?>[results[0].headline, ?results[0].reasonCode] · secondTexts <String?>[ShellLabels.onboardingNotAccepted])마다 — unselected → tap(o00b-card-0) → pump 두 번 → 첫 present findsOneWidget · 첫 absent findsNothing ·
        🆕 expect(shownTexts(tester, find.byKey(c.firstOn)), c.firstTexts) · 자리 dy 두 줄 getTopLeft(o00b-card-0).dy < getTopLeft(c.firstOn).dy < getTopLeft(o00b-record-gap).dy(실패 글자 의역 — 드라이런 R06 · 자리 — M08) → tap(o00b-card-0) → pump 두 번 → 둘째 present findsOneWidget · 둘째 absent findsNothing · 둘째도 같은 꼴(secondTexts · 자리 dy 두 줄) ·
        expect(actions.ids, <SettingsActionId>[SettingsActionId.onboardingOperatingModeSelect, SettingsActionId.onboardingOperatingModeSelect]) · ⓡ.
 O0B-07 기다리는 동안 두 번 누름 0 — 공장 = (int call) => Completer<ActionResult>().future(끝나지 않음) · unselected → tap(o00b-card-0) → pump → tap(o00b-card-0) → tap(o00b-card-1) → pump →
        expect(actions.ids, <SettingsActionId>[SettingsActionId.onboardingOperatingModeSelect]) · CircularProgressIndicator findsNothing · ⓡ.
 O0B-08 잠금 = 데이터(lockedLabel · 탭 0 · «다음» 0 · operator 주입 — C4r14a-6) — 두 경우 ㉠ (locked · locked · want <SettingsActionId>[]) · (open · unselected · want <SettingsActionId>[SettingsActionId.onboardingOperatingModeSelect])마다 —
        전제 셋: expect(locked.lockedLabel, isNotNull); // pre · expect(locked.nextDeepLink, isNull); // pre · expect(unselected.lockedLabel, isNull); // pre →
        final String? lock = c.v.lockedLabel; if (lock != null) { expect(shownTexts(tester, find.byKey(const Key('o00b-locked'))), <String>[lock]); 🆕 자리 dy 두 줄 getTopLeft(o00b-card-0).dy < getTopLeft(o00b-locked).dy < getTopLeft(o00b-record-gap).dy; } else { expect(find.byKey(const Key('o00b-locked')), findsNothing); expect(find.byKey(const ValueKey<String>('o00b-card-0')), findsOneWidget); } ·
        expect(find.byKey(const Key('o00b-next')), findsNothing)(🔴 locked = selected 있음 · nextDeepLink null — «selected 로 다음» 을 잡는다) → tap(o00b-card-0) → pump → expect(actions.ids, c.want) · ⓡ.
 O0B-09 주입 null(뷰어) = 카드 탭 부재 — 두 경우 ㉠ (viewer · 주입 공장 () => null · tappable false) · (operator · () => FakeShellOnboardingActions(…) · true)마다 i 0·1 → final InkWell ink = tester.widget<InkWell>(find.descendant(of: find.byKey(ValueKey<String>('o00b-card-$i')), matching: find.byType(InkWell)));
        expect(ink.onTap, c.tappable ? isNotNull : isNull)(🔴 operator 경우가 있어야 단언이 공허하지 않다 · 가짜는 testWidgets 안에서 공장으로) · ⓡ.
 O0B-10 상태 갈래(갈래마다) — 세 경우 ㉠ (loading · Stream.multi(값 0) · [o00b-loading] · [o00b-headline, o00b-fail]) · (fail · Stream.error · [o00b-fail] · [o00b-headline, o00b-loading]) ·
        (value_then_fail · valueThenFail(unselected) · [o00b-fail] · [o00b-headline, o00b-loading])마다 Key 목록 findsOneWidget / findsNothing · CircularProgressIndicator findsNothing.
 O0B-11 재시도(구독) — 공장 = (int call) => call == 0 ? Stream<OnboardingModeChoiceVm>.error(StateError('fail')) : one(unselected) → tap(find.text(ShellLabels.retry)) → pump 두 번 → o00b-fail findsNothing · o00b-headline findsOneWidget · repo.modeCalls == 2 · ⓡ.
 O0B-12 화면 Text 전부 · 큰 글꼴(04 §9-1b 수용 (b)(d) · 문구 = 엔진) — 네 경우 ㉠ (unselected) · (auto) · (advisory) · (locked)마다 규칙 10 «화면 Text 전부» 견본(allowed = modePickAllowed(c.v) — trust·switchGates·mode.wire 글자가 allowed 에 없어 그리면 잡힌다) →
        tester.platformDispatcher.textScaleFactorTestValue = 2.0 → pump → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = onboarding_mode_pick_test.dart 11줄(O0B-01~09 · 11 · 12) · ⓗ 기대 = 1줄(O0B-01) — 🔴 정확히 · (전제) = 12(01 3 · 04 4 · 05 2 · 08 3 — 정적 O34).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 통과하면 반려 · 갈래마다 짝 · C4r5e-3):
   (순서·목록) 갈래 뒤집기 · 조회 갈래를 맨 위로 · 갈래 하나만(take(1)) · 카드 뒤집기 · 카드 하나만 · 카드를 세로로 쌓기(자리 바꿈 — O0B-01 나란히 dy) · 고지 둘 자리 바꾸기 · 결과 줄을 고지 아래로 · «다음» 을 고지 위로.
   (기본값 — 수용 (a)) selected null 에도 첫 카드 체크 · nextDeepLink null 에도 «다음» · «다음» 을 nextDeepLink 대신 selected != null 로(O0B-08 locked) · 고른 표시를 index 0 고정 · 탭하자마자 체크(낙관 갱신 — O0B-03) ·
     🔵 참고 — 정적이 잡음: «첫 카드 autofocus»(O28) · «카드에 «권장» 글자»(O23 · 라벨 더하기 = O13 · O37) · 🔵 참고 — 타입이 막음(적용 불가): «OperatingModeView.current 로 칠하기» · «trust·switchGates 그리기»(v1.16 VM 에 칸 0).
   (시각 우대) 고르지 않은 카드 줄이기 · 첫 카드만 elevation · 첫 카드만 color · 카드 폭 비대칭(flex 2:1) · 첫 카드 제목 굵게(O0B-02 style) · 첫 카드만 margin.
   (쓰기) 탭 무시(run 0) · run 두 번 · 다른 SettingsActionId · args 키 바꾸기 · args 값 = title · args 값 고정 AUTO_TRADE · 탭 = 이동(opener.open) · 기다리는 동안 두 번 · 기다리는 동안 다른 카드 · 🆕 고른 뒤 카드 탭 막기(화면 판정 — O0B-04).
   (결과) headline 빼기 · reasonCode 빼기 · reasonCode 를 headline 앞에 · headline 대신 정적 글자 · 결과 level 로 줄 숨기기 · 실패 글자 빼기 · 실패 때 결과 남기기(ok_then_fail · 한 칸 초기화 빼기) · 성공 때 실패 글자 남기기(fail_then_ok).
   (링크) 갈래 탭 0 · deepLink null 에도 탭 · 🆕 deepLink null 에도 빈 콜백(잉크만 — O00-02 InkWell) · 조회 갈래 탭 = tracks[0].deepLink · «다음» 탭 0 · «다음» = 다른 링크.
   (잠금·주입) lockedLabel 빼기 · 잠금에도 탭 · 주입 null 에도 탭 · 주입 있어도 탭 0 · 조회 갈래를 tracks 와 같은 Key 로(O00-01 · O00-03).
   (상태 — 갈래마다 · 두 화면) 에러를 스켈레톤으로 · 재시도 invalidate 0 · 화면에 정적 글자 하나 더하기 · 머리 빼기 · 스피너 더하기.
   🔵 판정 = 변이마다 ui_shell 의 flutter test 전부(골든 포함) + 정적 묶음(🔵 참고 «정적이 잡음» 몫) · 🆕 테스트 쪽 변이(늘 참 · else 없는 if · nullable 흐름 칸)의 사전검사 판정 = 임시 커밋 위(사전검사는 HEAD 커밋만 본다 — 작업 트리만 고치면 «🔴 0 · 🟡 1([W0])» 로 거짓 통과 · 재드라이런 2 R02 첫 실행) → 판정 뒤 reset --hard · 드라이런 변이 표 = 첫 판 74꼴(예고 59 · 참고 15) KILLED 69 · SURVIVED 5 → 반영판(`dry/r15-1b` `dd03123`)에서 M08 · R06 · R08 · 🆕 M39b 4꼴 KILLED · 🔵 참고 R01(늘 참 단언) = 사전검사 T3 구멍(infra · C4 사람 grep) · R02(else 없는 if) = 사전검사 T1 🔴 · 그 밖 참고(«권장» 배지 · %p 글자 · 4번째 갈래 · 결과 덧말 · 코드 숨김 · 시크릿 TextField · 링크 조립 · 구독 누수 · rejected 를 실패로) 전부 KILLED · 🆕 재드라이런 2(v1.16 실물) = 82꼴 — 예고 62 전부 KILLED(🆕 M29b 고른 뒤 탭 막기 · M39b · M40b 조회 갈래 탭 0 · 앞 판 SURVIVED M08 = O0B-05·06 자리 dy) · 참고 20 = KILLED 16(🆕 R15 진입 기본 선택 · R17 코드를 Semantics 로만 · R18 «다음» 을 카드 위로 · R14 autofocus = 정적 O28) · R01 = C4 사람 grep · R02 = T1 🔴 · 🆕 R16 nullable 흐름 칸 + if = C4 사람 grep 2(«5»).

■ 정적 묶음 — 아래 37줄을 파일로 꺼내 Git Bash 로 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다(대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 머리 ASCII · «EXIT:1» = 출력 없음 · 출력 줄 수(EXIT 줄 포함) = 151줄(드라이런 — 기록 커밋이 base 에 있을 때) — 붙이기 전에 세어 같은지 본다)
  🔴 터미널에 붙여 넣어 돌리지 않는다(대화형 bash 는 ! 든 줄을 건너뛸 수 있다 · bash 라고만 치면 이 PC 에서는 WSL)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 손으로 옮겨 쓰지 않는다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R15a-Bob-O00O00b.md' | sed -n '401,437p' > ../../build/r15a_static.sh"
  git hash-object ../../build/r15a_static.sh   ← c85e925a87a897a344777ad1683f7d5f56cf489f(= 아래 37줄 · 드라이런·지적 반영 판 실측 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r15a_static.sh > ../../build/r15a_static_out.txt"
  Select-String -Path ..\..\build\r15a_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음이어야 한다(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r15a_static_out.txt).Count   ← 151(드라이런 · EXIT 줄 37 포함) · (Select-String -Path ..\..\build\r15a_static_out.txt -Pattern '^EXIT:1$').Count ← 20 · -Pattern '^EXIT:0$' ← 17
  ② 에 붙일 출력 = Get-Content -Encoding UTF8 ..\..\build\r15a_static_out.txt 전부(build/ 는 .gitignore 대상 — git status 는 빈 채 · 커밋 0 · 할 일의 «미리 돌리기» 도 이 꼴)
echo "## O01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## O02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## O03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## O04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://|'https?://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O06 source lines (2)"; git grep -nE "watchStart\(|watchModeChoice\(" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O07 action ids (1)"; git grep -noE "SettingsActionId\.[A-Za-z]+" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O08 run calls (1)"; git grep -nE "\.run\(" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O09 wire uses (1)"; git grep -nE "\.wire\b" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O10 args key (1)"; git grep -nF "'operating_mode'" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O11 forbidden words in onboarding 0"; git grep -nE "\.current\b|OperatingModeView|switchGates|\.trust\b|\.track\b|watchSteps|OnboardingStep\b|\.level\b|retryable|actionRunId|handoffRoute|DateTime\.now|Duration\(|kIsWeb|Platform\.|dart:io|HoldingPnl|PerformanceSeries|PerfDisclosure|afterTax|FeatureFlags|operatingMode|runMode|AppRoutes|AppLinkSchemes|\.where\(|\.length|\.sort|sorted|\.take\(|toString\(|NumberFormat|DateFormat|split\(|startsWith|substring|RegExp|switch \(|showDialog|SnackBar|Clipboard|print\(|[Ss]kip" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O12 selection read (1)"; git grep -nE "\.selected\b" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O13 R15a labels (2)"; git grep -cE "^\s*static const String onboarding" -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## O14 barrel exports"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## O15 shell providers"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## O16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## O17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## O18 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05|2\.75|22\.5)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## O19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## O20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart; echo "EXIT:$?"
echo "## O21 H lines (hasLength)"; git grep -c "hasLength(" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart; echo "EXIT:$?"
echo "## O22 o00 o00b key names"; git grep -noP "o00b?-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O23 banned vocabulary in code 0 (incl recommend)"; git grep -nE "권장|추천|권유|자문|시그널|대부분|건너뛰|해외" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## O24 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## O25 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## O26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## O27 Scaffold AppBar Navigator in onboarding 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O28 focus and choice widgets in onboarding 0"; git grep -nE "autofocus|FocusNode|requestFocus|FocusScope|Radio|Checkbox|Switch\(|ToggleButtons|SegmentedButton|ChoiceChip|FilterChip|DropdownButton" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/l10n/labels.dart lib/src/shell_providers.dart lib/src/shell_scaffold.dart lib/src/routing/shell_router.dart lib/src/common/shell_common.dart lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/watchdog_board_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## O30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## O31 copyWith in tests 0"; git grep -n "copyWith(" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## O32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## O33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## O34 precondition marks (pre)"; git grep -c "// pre$" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart; echo "EXIT:$?"
echo "## O35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart; echo "EXIT:$?"
echo "## O36 secret and input widgets in onboarding 0"; git grep -niE "textfield|textformfield|editabletext|secretfield|keystore|flag_secure|biometric" -- lib/src/onboarding; echo "EXIT:$?"
echo "## O37 banned vocabulary in labels 0"; git grep -nE "static const String .*(권장|추천|권유|자문|시그널|대부분|건너뛰|해외)" -- lib/l10n/labels.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(✅ 드라이런 실측과 같음) — O01 = 주석 줄 말고 출력 없음 · O02 = 출력 없음 · O03 = 4줄(o00_golden 1 · o00b_golden 1 · onboarding_mode_pick_test 12 · onboarding_start_test 6) · O04 = 0 ·
   S05 = 3줄(onboarding_mode_pick.dart «다음» 콜백 · onboarding_start.dart _TrackCard 탭 · _ViewerTrackCard 탭 — 줄마다 탭 콜백 안) · O06 = 2줄 · O07 = 1줄(«…:SettingsActionId.onboardingOperatingModeSelect») · O08 = 1줄 · O09 = 1줄 · O10 = 1줄 ·
   O11 = 0(🔴 주석 포함 · 「switch (」 도 0 — 열거값을 가르지 않는다) · O12 = 1줄(final OperatingMode? picked = vm.selected; — 🔵 _ModeCard 칸 이름은 picked) · O13 = «lib/l10n/labels.dart:2» ·
   O14 = 11줄(l10n/labels.dart · src/alerts/alert_center.dart · src/alerts/alert_detail.dart · 🆕 src/onboarding/onboarding_mode_pick.dart · 🆕 src/onboarding/onboarding_start.dart · src/ops_home.dart · src/ops_rhythm.dart · src/routing/shell_router.dart ·
   src/shell_providers.dart · src/shell_scaffold.dart · src/watchdog_board.dart 차례 — 기대 · 🔵 «정확히» 판정 = 마지막 카드) · O15 = 17줄(R14 15 + 끝 2 = shellOnboardingRepositoryProvider · shellOnboardingActionsProvider · 기대 — «정확히» = 마지막 카드 · 이 카드 판정 = +2 · 삭제 0(O29)) ·
   O16~O19 = 0 · O20 = «test/onboarding_mode_pick_test.dart:11» · «test/onboarding_start_test.dart:5» · O21 = «test/onboarding_mode_pick_test.dart:1» · «test/onboarding_start_test.dart:1»(🔴 정확히 — 다르면 반려) ·
   O22 = 이름 16 = 위 «Key 표» 의 리터럴 이름(o00-loading · o00-fail · o00-headline · o00-track · o00-viewer · o00b-loading · o00b-fail · o00b-headline · o00b-card · o00b-check · o00b-locked · o00b-not-accepted · o00b-result · o00b-record-gap ·
   o00b-honesty · o00b-next — 순번 꼴은 머리만 · 표 밖 0) · O23~O28 = 0 · O29 = 네 줄(lib/l10n/labels.dart · lib/src/shell_providers.dart · lib/ui_shell.dart · test/shell_fakes.dart — 둘째 수 0 · ui_shell.dart 첫째 수 2 · 첫째 수는 재량 — 삭제 0 만 본다) ·
   그 밖 파일 줄 없음(R13·R14 화면·테스트·골든 테스트 포함 — 고치면 줄이 나온다) · O30 = 0 · O31 = 0 · O32 = 0 · O33 = 8줄 전부 «A»(o00_* 2 · o00b_* 6 만) · O34 = «test/onboarding_mode_pick_test.dart:12» · «test/onboarding_start_test.dart:7»(🔴 정확히) · O35 = 0 · O36 = 0 · O37 = 0(🔵 O23 은 labels.dart 를 뺀다 — 그 파일 머리 주석의 «건너뛰기» 예시 글자 · 라벨 값은 O37 이 본다 · 🆕 O23·O37 에 «해외» — 자체 점검 9번 «해외주식 0» 의 근거 줄 · 명세 지적))
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · O11 · O23 · O28 · O36 은 주석 줄도 센다(규칙 15))

■ 골든 — 4이름 × light/dark = 8장(전부 신규 · 이름 = 04 §9-1b (e) 글자 + O-00 카드 이름 · golden README «🆕 R15» 절 표 그대로)
  o00 — test/golden/o00_golden_test.dart · 크기 = kGoldenPhoneSize(390 × 844 · 맨 아래 dy 308.0 — 재드라이런 2 · light = dark) · 위젯 = OnboardingStart() · 저장소 = FakeShellOnboardingRepository(start: (int call) => one(flow.fixture), modeChoice: …)(🔴 testWidgets 안에서 새로 · _Flow 칸에 인스턴스 0):
    이름              입력         흐름    맨 아래 Key           머리 Key
    o00_start         start        없음    Key('o00-viewer')      Key('o00-headline')
  o00b — test/golden/o00b_golden_test.dart · 크기 = kGoldenPhoneSize(맨 아래 dy o00b_unselected 584.0 · o00b_auto 652.0 · o00b_advisory 648.0 — 재드라이런 2 · v1.16 실물 정직 고지가 흉내보다 길어 +80 · light = dark · 머리 dy 0.0 · 여백 조정 0) · 위젯 = OnboardingModePick() · 명령 = testWidgets 안에서 UnimplementedSettingsActions() 새로(공장 · _Flow 칸 0 · 탭 없음 — C4r5d-5) · 저장소 = 같은 꼴:
    o00b_unselected   unselected   없음    Key('o00b-honesty')    Key('o00b-headline')
    o00b_auto         auto         없음    Key('o00b-next')       Key('o00b-headline')
    o00b_advisory     advisory     없음    Key('o00b-next')       Key('o00b-headline')
  모양 = w01_golden_test.dart 와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록(private class _Flow · 흐름 칸 = Future<void> Function(WidgetTester t) — non-null) × Brightness.values · 흐름 = 전부 (WidgetTester t) async {}(C4r14a-4 — `_` 매개변수 꼴도 같은 뜻으로 본다 · 글자는 이 꼴) ·
  테스트 이름 '${flow.name} ${brightnessSuffix(b)}' · 주입 = pumpForGolden(tester, <위젯>, brightness: b, logicalSize: kGoldenPhoneSize, wrapApp: (Widget app) => ProviderScope(overrides: onboardingOverrides(…), child: app)) →
    await tester.pump(); → await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden(flow.name, b).
  위치 전제 둘 = 이 코드 글자 꼴(흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(kGoldenPhoneSize.height));
    expect(tester.getTopLeft(find.byKey(const Key('o00-headline'))).dy, 0.0);      ← o00b 파일은 Key('o00b-headline')
  명령(packages/ui_shell): flutter test --update-goldens test/golden/o00_golden_test.dart → flutter test --update-goldens test/golden/o00b_golden_test.dart → flutter test(옵션 없이 · (3) 커밋 전 git status 에 새 PNG 8 · 새 골든 테스트 2(o00_golden_test.dart · o00b_golden_test.dart)만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     골든 높이 = 카드 확정값 + 여백 재량 — 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개)
· O00O00b_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지 · 행 앞에 «O-00:» 또는 «O-00b:» 접두(🔵 예외 = 골든 dy «측정:» 행).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A4 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 4줄을 그대로 붙이고 <값> 자리에만 잰 수를 넣는다(높이 = 리터럴):
      ┌── 측정 행 복사 시작(다음 줄부터 · 4줄)
| A1 | R15a-Bob-O00O00b | 추측 | 측정: o00_start dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A2 | R15a-Bob-O00O00b | 추측 | 측정: o00b_unselected dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A3 | R15a-Bob-O00O00b | 추측 | 측정: o00b_auto dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A4 | R15a-Bob-O00O00b | 추측 | 측정: o00b_advisory dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖)
  여백을 줄였으면 A5 부터 «측정:» 전·후 행 · 더 필요해 보인 정적 라벨(🔴 만들지 말고 행으로) · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 2 · 읽지 않는 필드 · 배치 순서 · 카드 모양·체크 아이콘 · 결과 줄 꼴 · 골든 이름·입력 · 재량(여백·모서리).
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(4) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(또는 (5)))
  cd packages/ui_shell
  flutter test test/onboarding_start_test.dart         ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +13: All tests passed!» · 시각은 실행마다 다름 · C4r14a-2)
  flutter test test/onboarding_mode_pick_test.dart     ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +23: All tests passed!»)
  flutter test test/golden/o00_golden_test.dart        ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +2: All tests passed!»)
  flutter test test/golden/o00b_golden_test.dart       ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +6: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과 — 끝 줄 그대로 — 줄 머리 시각까지(기대 = 시작 기준 N + 44 — 193 → «00:nn +237: All tests passed!»(재드라이런 2 «00:20 +237») · v1.16 병합본 N 이 다르면 N + 44)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← Git Bash 전체 경로(C4r5a-2) · 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건은 이 카드와 무관 — 그대로 둔다
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+424 ~30: All tests passed!»(M2 가지 `aaefdbc` 실측 · v1.16 병합본 수로 병합 기록 때 다시 잰다 · 이 카드 몫 0) · 🔴 melos.bat run test 가 5분 넘게 출력이 없으면 Ctrl+C 로 끊고 packages/ui_shell 에서 flutter test(위 줄) + melos.bat run test:contracts 만 — 끊은 사실을 ② 끝에 한 줄로(드라이런 = 패키지별 실행) · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_shell/): M lib/l10n/labels.dart · A lib/src/onboarding/onboarding_mode_pick.dart · A lib/src/onboarding/onboarding_start.dart · M lib/src/shell_providers.dart · M lib/ui_shell.dart ·
        A test/golden/goldens/o00_start_*.png 2장 · A test/golden/goldens/o00b_*.png 6장 · A test/golden/o00_golden_test.dart · A test/golden/o00b_golden_test.dart · A test/onboarding_mode_pick_test.dart · A test/onboarding_start_test.dart · M test/shell_fakes.dart ·
        M docs/ai-context/inbox/O00O00b_questions.md · 그 밖의 줄(특히 M lib/src/shell_scaffold.dart · M lib/src/routing/shell_router.dart · M lib/src/alerts/* · M PNG · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번(C4r5e-5)
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M8] R15a (5) 사전검사 지적 수정» · amend 금지 · format:fix 먼저 · analyze·format 실패를 고칠 때도 이 (5) 하나) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m8-o00-mode-pick
  ① 에 붙일 출력 — 🆕 파일로 받아 그 글자를 그대로(C4r14b-5 · 화면 복사·문자열 안 "$x" 배열 0):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     git -c core.quotePath=false diff --name-status origin/main...HEAD | Out-File -Encoding utf8 $env:TEMP\r15a_ns.txt
     git log --oneline origin/main..HEAD | Out-File -Encoding utf8 $env:TEMP\r15a_log.txt
     (Get-Content -Encoding UTF8 $env:TEMP\r15a_ns.txt).Count · (Get-Content -Encoding UTF8 $env:TEMP\r15a_log.txt).Count   ← 줄 수 = git 출력 줄 수(한 줄로 이어 붙었으면 다시 · 권장대로면 바뀐 파일 19줄 · 커밋 4줄 — 드라이런 실측)
  cd packages/ui_shell → 위 «정적 묶음» 의 실행 꼴(파일로 꺼내 Git Bash · EXIT 확인) → cd ../..   ← ② 에 그대로 붙일 출력(r15a_static_out.txt 전부)
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M8] O-00·O-00b 첫 실행·운영 방식 선택
  🔴 제출 글 = 아래 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님) + 끝 flutter test 한 줄 — 채팅에 내지 않고 저장 파일 $env:TEMP\R15a-Bob-O00O00b_submit.md 로(C4r5a-1) ·
     🆕 저장 = UTF-8 **BOM 없이** · 줄바꿈 그대로(C4r14b-5) — 편집기 도구로 쓰면 «UTF-8(BOM 없음)» · PowerShell 로 쓰면 이 꼴만: [IO.File]::WriteAllText("$env:TEMP\R15a-Bob-O00O00b_submit.md", $text + "`n", (New-Object Text.UTF8Encoding($false)))
       ($text = 줄을 -join "`n" 으로 이은 글 · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다) ·
     🔴 채팅 답 = 두 줄뿐: «R15a-Bob-O00O00b 제출 글 저장했음: <(Resolve-Path $env:TEMP\R15a-Bob-O00O00b_submit.md).Path 출력>» · 사전검사 ② 끝 줄 둘(o00_ · o00b_ — « / » 로 이은 한 줄) · 대화 요약(Previous conversation summary)을 내지 않는다.
  PR 본문 5섹션을 저장 파일로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로 — 아래 자체 점검 상자는 10줄이지만 머리 글자는 사전검사가 정한다 · 🔴 «10항» 으로 고치면 🔴 R1):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 저장 파일 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② 두 번 — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일($env:TEMP\R15a-Bob-O00O00b_submit.md · BOM 없이 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R15a-Bob-O00O00b_submit.md --golden-prefix o00_ --goldens 2 | Out-File -Encoding utf8 $env:TEMP\r15a_pre2_o00.txt; Get-Content -Encoding UTF8 $env:TEMP\r15a_pre2_o00.txt | Select-Object -Last 1
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R15a-Bob-O00O00b_submit.md --golden-prefix o00b_ --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r15a_pre2_o00b.txt; Get-Content -Encoding UTF8 $env:TEMP\r15a_pre2_o00b.txt | Select-Object -Last 1
        ← 🔴 두 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다) · 출력은 채팅에 붙이지 않는다 · 🔵 접두 «o00_» 는 o00b_* 를 세지 않는다(정규식 머리 일치 — 두 번 돌리는 까닭) ·
          🔵 🟡 [G1] 은 멈춤이 아니다(드라이런 기대 🟡 = 6행 — o00_: 0 · o00b_: o00b_unselected·o00b_auto·o00b_advisory light·dark «덩어리 차례 다름»(G1 이 표의 «나란한 상자 2» 를 상자 1 · «버튼 글자» 를 글자 1줄로 읽고 PNG 는 상자 2 · 버튼 = 상자(안 글자 1줄)로 센다 · 표는 이 카드 단위) → 🔴 이 6행은 그대로 낸다 · PNG 를 다시 열지 않는다 · 칸을 고치지 않는다) · 🟡 [G1] 이 그 밖의 행에서 **상자 수·덩어리 차례**를 다르게 읽으면 그 이름의 light PNG 를 다시 열어 표를 맞춘다(안 줄 수만 다른 🟡 · «덩어리로 셀 수 없어 대조하지 않았다» 🟡 는 그대로 · C4r5b-4) ·
          🔴 🟡 수가 카드 기대보다 많으면 늘어난 🟡 행의 light PNG 를 다시 열어 표를 맞춘다 — 다시 열지 않고 그대로 내면 ② 반려(C4r5d-1).
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + $env:TEMP\r15a_ns.txt 글자 그대로(코드 블록 하나) + «커밋 목록:» + $env:TEMP\r15a_log.txt 글자 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: O-00 — 첫 실행 3갈래(OnboardingStart()) · O-00b — 운영 방식 선택(OnboardingModePick()) · 주입 shellOnboardingRepositoryProvider · shellOnboardingActionsProvider
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항(머리는 «12항») — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다 ·
     꼴 = «N. <prompt 글자> [x] ( )» — [x] 는 글자 뒤 · 이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «정적 묶음 O16 — 허용 밖 import 0줄 · pubspec 무변경(O29)»
        2번 = «산술 = null 여부 · 고른 표시 비교 하나(O12) · 탭 가능 한 식 · 표시 상태뿐 · 거르기·정렬·세기·switch 0(O11) · 금지 수치 O18 0건 · 소수·% 리터럴 O19 0건»
        3번 = «DateTime.now 0(O11) · 시계 미사용(asOf 0) · 소요 시간 = estimatedText 그대로»
        4번 = «이 카드 범위 밖(5탭·홈·F-01 = R13·엔진 레인) · 손익 0(O11)»
        5번 = «이 카드 범위 밖(알림 = R14)»
        6번 = «이 카드 범위 밖(DND UI = M9)»
        7번 = «이 카드 범위 밖(워치독 = R14b)»
        8번 = «이 카드 범위 밖(시크릿 입력 = R15b SecretField 자리) · 이 카드 입력 위젯 0(O36 · O28)»
        9번 = «건너뛰기·해외주식 0(O11 · O23) · 결과 문장 = headline + reasonCode 원문(O0B-05) · 실패 = 정적 «접수되지 않았습니다»(O0B-06)»
        10번 = «삽입 자리 직접 구현 0 · 잠금 뒤 변경 경로 0(M5-11 몫 · O0B-08) · 킬스위치 진입 = 셸 몫(무수정 O29)»
      ┌── 복사 시작(다음 줄부터 · 10줄)
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] ( )
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] ( )
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] ( )
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] ( )
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] ( )
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] ( )
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] ( )
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] ( )
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M8.md 173~182행과 같습니다)
      10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r15a_box2.txt)에 저장 → (Get-Content -Encoding UTF8 $env:TEMP\r15a_box2.txt).Count → 출력 한 줄을 아래 «10항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 10):
      ┌── 10항 줄 수 복사 시작(다음 줄부터 · 4줄)
10항 줄 수:
```
<출력 한 줄>
```
      └── 10항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 37줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄들(S05 출력 줄마다 한 줄 · 같은 차례 · 기대 3줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(O20·O21 출력 줄 그대로 복사) + «테스트 파일별:» + 위 flutter test 네 파일 끝 줄 그대로(onboarding_start · onboarding_mode_pick · o00_golden · o00b_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = O20 출력:
<O20 출력 줄 그대로>
ⓗ = O21 출력:
<O21 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — 첫 실행 로딩·정상·조회 없음·에러 4줄 + 운영 방식 로딩·진입·고름·잠금·에러 5줄 + 골든 표 8행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면 1·2» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로(«자리 바꿈» 줄은 이 글자 그대로 — 펼치지 않는다 · C4r5e-7):
         «첫 실행 정상» = ListView → Key('o00-headline') → ValueKey<String>('o00-track-$i') → Key('o00-viewer')(있을 때)
         «첫 실행 조회 없음» = «첫 실행 정상» 에서 Key('o00-viewer') 가 빠진 꼴
         «첫 실행 로딩» = ShellSkeleton(Key('o00-loading')) · «첫 실행 에러» = ShellErrorView(Key('o00-fail'))
         «운영 방식 진입» = ListView → Key('o00b-headline') → Row(ValueKey<String>('o00b-card-0') · ValueKey<String>('o00b-card-1')) → Key('o00b-record-gap') → Key('o00b-honesty')
         «운영 방식 고름» = «운영 방식 진입» 의 카드 하나에 ValueKey<String>('o00b-check-$i') · 끝에 Key('o00b-next') · 탭 뒤 카드 다음 자리에 Key('o00b-result') 또는 Key('o00b-not-accepted')
         «운영 방식 잠금» = «운영 방식 진입» 의 카드 다음 자리에 Key('o00b-locked') · 체크 하나 · Key('o00b-next') 없음
         «운영 방식 로딩» = ShellSkeleton(Key('o00b-loading')) · «운영 방식 에러» = ShellErrorView(Key('o00b-fail'))
      골든 표 8행(한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |» + 바로 다음 줄 구분 줄 «|---|---|---|---|---|---|»(없으면 표로 그려지지 않는다 · C4r5d-8) · 이름 칸 = «o00b_auto light» 꼴 ·
        입력 = 파일 이름만(경로 앞머리 없이 · C4r5e-7 — onboarding_start.json · onboarding_mode_unselected.json · onboarding_mode_auto.json · onboarding_mode_advisory.json) · 주입 = o00 행 «없음» · o00b 행 «operator» · 크기 = 390×844 ·
        dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(4장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 나란한 상자 2 · 버튼 글자 · 아이콘> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(8행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다) ·
        셈 단위 견본 2행(드라이런이 PNG 를 열어 쓴 칸 · 꼴만 본뜬다 · 🔴 견본과 같은 이름의 행은 꼬리까지 견본 글자 그대로 — PNG 가 견본과 다르게 보이면 칸을 바꾸지 말고 질문 파일에 · C4r5d-1):
         «| o00_start light | onboarding_start.json | 없음 | 390×844 | 308.0 | 글자 1줄 → 상자 → 상자 → 상자 — 잘림 없음 |»
         «| o00b_auto light | onboarding_mode_auto.json | operator | 390×844 | 652.0 | 글자 2줄 → 나란한 상자 2 → 글자 10줄 → 버튼 글자 — 잘림 없음 |».
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/O00O00b_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 줄머리 «+» 까지 출력 그대로 — 지우지 않는다 · C4r5d-8 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = O00O00b_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 44 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-o00-mode-pick` 푸시 1건 · 커밋 권장 4개(마지막 = format·질문 · amend·rebase·강제 푸시 0 · 커밋마다 지정 파일 add · (4) 뒤 = 사전검사 ① 🔴 · analyze · format 수정 (5) 하나만 · 제목 = 까닭).
- `lib/` 새 파일 **2**(`src/onboarding/onboarding_start.dart` · `onboarding_mode_pick.dart`) · 수정 3(더하기만 — `labels.dart` R15a 절 2 · `shell_providers.dart` 끝 절 2 · `ui_shell.dart` export 2) · 셸 파일·R13·R14 화면·`apps/`·`domain_contracts`·pubspec 변경 0.
- `test/` 새 파일 4(`onboarding_start_test.dart` · `onboarding_mode_pick_test.dart` · `golden/o00_golden_test.dart` · `golden/o00b_golden_test.dart`) + 수정 1(`shell_fakes.dart` 끝 절) + 새 PNG 8장 · 재생성 0.
- 질문 파일 `O00O00b_questions.md`(새 행 A1~A4 «측정:» 반드시).
- 저장 파일 `$env:TEMP\R15a-Bob-O00O00b_submit.md`(PR 본문 5섹션 + flutter test 한 줄 · BOM 0) + 채팅 두 줄 · 사전검사 ① 한 번 · ② 두 번(`o00_` 2 · `o00b_` 6) 🔴 0.
- `flutter test` = 시작 기준 N(머리 «사전 조건» 의 v1.16 병합본 실측 · 기대 193) + 44(뷰 36 + 골든 8) · 정적 O13 = 2 · O20 = 11 · 5 · O21 = 1 · 1 · O34 = 12 · 7(🔴 정확히) · O14 = 11줄 · O15 = 17줄(기대 — «정확히» = 마지막 카드 · 이 카드 = 더하기만) · O22 = 이름 16 · S05 = 3 · O06 = 2 · O07~O10 = 1 · O33 = 8 A · 출력 151줄(드라이런).
- 재분할 임계: 새 `testWidgets(`·`test(` 줄 20 · lib +389(드라이런) · 새 PNG 8 · 원천·쓰기 3 → 재분할 없음.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15a-Bob-O00O00b 결과: 브랜치 ui/m8-o00-mode-pick 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**를 붙여넣습니다(C4r5a-1 — Bob 채팅 화면의 글을 복사하지 않습니다 · 여는 법: PowerShell 에서 `notepad $env:TEMP\R15a-Bob-O00O00b_submit.md`(또는 Bob 채팅 답 첫 줄의 경로를 메모장으로) → Ctrl+A → Ctrl+C → 붙여넣기 · 첫 줄이 `## ① 구현한 화면 ID · 바뀐 파일 · 커밋` 이고 끝 줄이 `flutter test: 시작 기준 … → 끝 …` 이면 맞게 연 것). 0단계에서 멈췄다면 `R15a-Bob-O00O00b 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① `shell_scaffold.dart`·`shell_router.dart`·`shell_common.dart`·`ops_*`·`alerts/*`·`watchdog_board.dart`·R13·R14 테스트·기존 PNG 가 `M` ② `apps/**`·`packages/domain_contracts/**`·다른 `ui_*` 가 `M` ③ `lib/src/onboarding/` 에 `current`·`OperatingModeView`·`switchGates`·`.track`·`.level`·`retryable`·`autofocus`·`TextField`·`AppRoutes`·`'aaq://`·`switch (`·`DateTime.now`·«권장»·«추천» ④ 진입 때 체크·«다음» · 탭하자마자 체크 · 한쪽 카드만 크게·색 ⑤ 결과 줄에 정적 «완료» 류 글자 · `level` 로 색 ⑥ 잠금에도 탭 · 뷰어에 탭 ⑦ 조회 갈래가 `tracks` 와 같은 Key ⑧ implements 가짜 · copyWith · 한국어 리터럴(테스트).
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 만 · 기존 40장 무변경).
- 🔵 C-46·C-47·경계 [5b][5c] 의 화면 스캔은 `ui_shell` 을 뺀다(01 §8 미결 91·144) — 이 카드는 정적 O11 · O16 · O17 · O23 · O28 · O36 · O37 이 그 구멍을 메운다(통합 담당이 C4 때 같은 줄을 다시 돌린다).
- 🔵 R15 4장 중 1번째 — 이 카드 병합 기록이 `send/_대기/R15b-Bob-O01O03.md` 를 `send/` 로 옮기고(v1.16 은 R15b~R15d 몫까지 한 PR — 이 카드 병합 때 이미 풀려 있다) `__R15A_SQ__`·`__R15A_PR__`·«앞 카드 병합 기록 때 채움» 실측 자리를 채운다 · «정확히 N»(라벨 · 배럴 · 주입 · PNG · README 장수) = 마지막 카드(R15d · ✅ 결정 ① 순서대로).
- ✅ 꺾쇠 U+27E6 «실측» 자리 0(2026-11-03 누적 재드라이런 2 가 채웠다 — 시작 기준 N · 끝 N · 골든 dy · ③ 견본 2행 · 셈 = `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R15a-Bob-O00O00b.md` = 0 · 🔵 이 안내 줄에는 그 글자를 쓰지 않았다) · ⬜ 남은 자리표시자 = `__R15V116_SQ__`(계약 v1.16 squash) — v1.16 병합 기록 때 채운다 · ✅ v1.16 이름표 표식 0(2026-11-03 재조립 — 실제 이름 · 파일 `dto/onboarding.dart` · `deepLink` · `nextDeepLink`) · ✅ 누적 드라이런 실측(정적 출력·EXIT 수 · 꺼내기 줄 범위 401~437·해시 `c85e925` · lib 줄 · 변이 표 · 🟡 기대)은 재드라이런 2 에서도 같다(🔵 이 파일의 앞쪽 줄 수가 바뀌면 범위·해시를 다시 잰다) · v1.16 병합본에 기대는 값(계약 버전 줄 1.16.0 · 시작 기준 193 · `domain_contracts` +424 ~30)은 병합 기록 때 다시 잰다 — 🔴 보내기 전 표식 0 · 자리표시자 0.
- 🔵 C4 사람 grep(사전검사 T3 구멍 — 드라이런 참고 변이 R01 «늘 참 단언» 이 테스트·사전검사 둘 다 통과): `git grep -nE "find\.byType\([^)]*\)\s*,\s*(findsWidgets|findsAtLeast)" -- packages/ui_shell/test/onboarding_start_test.dart packages/ui_shell/test/onboarding_mode_pick_test.dart` · 출력 0 이어야(infra 창 = C4r14b-3 · C4r5e-8 묶음에서 T3 에 더한다).
- 🔵 C4 사람 grep 2(🆕 재드라이런 2 참고 변이 R16 «nullable 흐름 칸 + if» — 골든 `_Flow.steps` 를 `Function(WidgetTester t)?` 로 바꾸고 `if (st != null) { await st(tester); }` = 테스트 44/44 · 사전검사 🔴 0(T1 은 단언이 든 if 만 본다) · 위 grep 통과 — 규칙 10 반려 꼴인데 기계 그물 0): `git grep -nE "Function\(WidgetTester [A-Za-z_]*\)\?" -- packages/ui_shell/test/` · 출력 0 이어야(2026-11-03 R15 네 장 드라이런 가지·`origin/main` 전부 0 · 🔵 테스트 쪽 변이의 사전검사 판정은 임시 커밋 위 — «3» 🔵 판정 · infra 창 = C4r14b-3 T1 «null 검사 + 클로저 호출» 에 R16 표본으로 이어 적음).
- 범위 고지: 01 §8 미결 91·144(셸 스캔 제외) · 125·126(`ShellVm` · 밀어 올린 화면 제목 원천 0 — 온보딩 제목도 «접두만») · 127(뷰어 operator 전용 라우트 가드 — 셸 무변경) · 137·143(ShellLinkOpener 늘 push — O-00 → O-00b → O-01 이 쌓이기만 한다 · 교체·정리 0) · 148(공통 상태 ⑤⑥ 원천 0) 은 이 카드가 닫지 않는다 · 🆕 v1.16 01 §8 미결(이 카드가 닫지 않는다) = 158(첫 실행 판정 — 조립 앱 · 06 M4-11) · 155(온보딩 VM 산출 — 엔진) · 149(`watchSteps` 존폐 — 코어 `onboarding_fresh` 의 `o_00` 행은 R15 표본에 없다).

## 6. R15 이월 반영 — 설계 12 §3 부록 중 대상 «R15»·«다음 화면 카드»·«다음 X7 카드»·«조립 체크리스트» 항목(2026-11-02 · 조립 — ✅ 는 병합된 것만이라 쓰지 않는다)

원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 «R14b C4 이월 부록»(`10_리뷰/2026-10-31_R14b_C4_보고.md`) · «R14a C4 이월 부록» · «R5e·R5d·R5c C4 이월 부록». R15b~R15d 카드 «6» 이 같은 표를 각 자리로 싣는다.

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r14b-1 경우 for 는 testWidgets 밖 · name = 테스트 이름 | 규칙 10 «경우 for 는 testWidgets 밖» 줄(견본 글자) · 최소 목록 공통 «경우 = for 는 testWidgets 밖» · 계획 = 줄 20(뷰 18 + 골든 2) · 테스트 44(뷰 36 + 골든 8 · 경우 수 = 테스트 수) | — |
| C4r14b-2 nullable 흐름 칸 반려 꼴 | 규칙 10 «흐름 = 클로저 칸 non-null … await c.flow(tester); 한 줄» · 반려 꼴 목록 «nullable 흐름 칸 + if (c.flow != null)» · 골든 «흐름 칸 = … non-null» | — |
| C4r14b-5 ① 붙이기 명령 꼴 · 저장 파일 BOM 0 | ■ 제출 «① 에 붙일 출력 — 파일로 받아» 4줄(`Out-File -Encoding utf8` · 줄 수 확인) · 저장 = `[IO.File]::WriteAllText(…, UTF8Encoding($false))` · «2» 6번 «BOM 없이» | infra(사전검사 ② R6 «① 블록 줄 수») = C4r14b-3 그대로 |
| C4r14a-4 경우 이름 = name 칸 · 골든 흐름 글자 | 규칙 10 «경우 이름 = 레코드 name 칸 글자» · 골든 «흐름 = 전부 (WidgetTester t) async {} — `_` 꼴도 같은 뜻 · 글자는 이 꼴» | — |
| C4r14a-5 상태 칸 여럿인 조각 = «실패 → 재시도 → 성공» · «한 칸 초기화 빼기» | O-00b 쓰기 조각(_busy·_failed·_result) · 화면 2 «세 칸을 늘 같이 바꾼다» · 최소 목록 O0B-06 두 방향(fail_then_ok · ok_then_fail) · 예고 변이 (결과) «실패 때 결과 남기기» · «성공 때 실패 글자 남기기» | R15b O-03 검증 실행 조각 = 그 카드 «6» |
| C4r14a-6 «부재 = 데이터» = operator 주입 | 규칙 10 «부재 = 데이터 테스트는 operator» · O0B-08(잠금 — operator) · O0B-09(viewer · operator 두 경우 — 공허 방지) · O00-03(주입 0 화면) | — |
| C4r5d-5 골든 «명령 칸» = 공장 | ■ 골든 o00b «명령 = testWidgets 안에서 UnimplementedSettingsActions() 새로(공장 · _Flow 칸 0 · 탭 없음)» · 최소 목록 O0B-09 «가짜는 testWidgets 안에서 공장으로» | 탭을 찍는 골든 0(고른 상태 = 표본 auto·advisory) — «경우 칸의 명령» 글자 = 해당 없음 |
| C4r5c-5 (a) 흐름 = 클로저 칸 | 공통 «흐름 = 클로저 칸 non-null» · 골든 흐름 = 전부 `(WidgetTester t) async {}` | (b) `_restoreDone` = 해당 없음(초안 0) |
| C4r5e-3 예고 변이 «갈래마다» 짝 (계승) | 예고 변이 머리 «갈래마다 짝» · (상태 — 갈래마다 · 두 화면) 줄 · 최소 목록 O00-04 · O0B-10 세 갈래 | 배너 = 해당 없음(asOf 0 — ⑤) |
| C4r5e-4 정적 줄 수를 format 에 덜 흔들리게 (계승) | ■ 정적 묶음 = 판정 줄 위주(목록 줄 = O14 · O15 · O22 셋) · O07 = «SettingsActionId.» 출현 수(줄 나눔에 덜 흔들린다) | `dispose` 자리 0 — «dispose 범위 안 ref 0» 판정 줄 불필요 |
| C4r5e-5 PowerShell 5.1 인코딩 (계승) | 정적 머리 ASCII(37줄) · ② `Get-Content -Encoding UTF8` · 사전검사 ①·N3 앞 `[Console]::OutputEncoding` | infra 그대로 |
| C4r5e-6 타입이 막는 변이 = 참고 (계승) | 예고 변이 (기본값) «OperatingModeView.current 로 칠하기» · «trust·switchGates 그리기» = «🔵 참고 — 타입이 막음» | — |
| C4r5e-7 «자리 바꿈» 줄 · 입력 = 파일 이름만 (계승) | ■ 제출 ③ 견본 머리 · «첫 실행 조회 없음» · «운영 방식 잠금» 줄 · 골든 표 «입력 = 파일 이름만» | — |
| 공통 교훈(R5·R13·R14) | 머리 «교훈 반영» 줄 · «2» 6·7번 · 규칙 10 반려 꼴 · ■ 정적 묶음 실행 꼴(Git Bash 전체 경로) · ■ 제출 N3 G1 조문(C4r5d-1) · ③ 구분 줄 · ④ «+» · O35 · 파일별 시각 머리(C4r14a-2) · 이어진 글자 행 = 한 덩어리(C4r14a-3) · 커밋마다 `git show --stat` | — |
| C4r14b-3 · C4r5e-8 (infra) | «5» C4 사람 grep 한 줄(T3 구멍) | 다음 infra 창(tool/precheck.dart T1 «null 검사 + 클로저 호출» · R6 · G1 헛경보(«나란한 상자 2»·«버튼 글자» 낱말) · 🆕 T3 «find.byType(…) + findsWidgets/findsAtLeast» 단독 단언 — 드라이런 R01 · 🆕 T1 «nullable 흐름 칸 + if» — 재드라이런 2 R16 · «5» C4 사람 grep 2) — 카드 몫 아님 |
