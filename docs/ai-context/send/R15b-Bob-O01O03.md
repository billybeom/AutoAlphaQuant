# 발송 패킷 R15b-Bob-O01O03 — O-01 단계 목록 · O-02 단계 상세 · O-03 검증 드라이런 결과 (계약 v1.16 전제 · R15 4장 중 2번째 · M8)

> ▶ **보낼 수 있음(「푸시해」 뒤)**(2026-11-04 · R15a 병합 기록 · 이 파일이 GitHub `main` 의 `send/` 에 있으면 보낸다 · Bob **새 대화** · 브랜치 `ui/m8-o01-steps`) · ✅ **선행 ① = R15a 병합**(PR #99 squash `940082c` · 2026-11-04 · 1회차 `8c89b14` merge-with-fixes(PR 본문 «C4 정정» 1곳 · 코드 정정 0) · CI 3/3 · `ui_shell` 193 → 237 · 병합본 시작 기준 N = 237 실측 · `domain_contracts` +424 ~30) · ✅ 0단계 확인 줄 = 병합본 `940082c` 에서 실행(기대 그대로 — 아래 «드라이런» 줄 «병합본 가벼운 확인») · ✅ «펼침» 표식 = R15a 글자(`_완료/R15a-Bob-O00O00b.md` «3» 규칙 10·12·13 · «보고 규칙» · «■ 골든» · «■ 제출» · 정적 실행 꼴)를 이 카드의 수·이름·파일로 펼쳤다(⑨ 줄 지움) · 🆕 R15a C4 이월 C4r15a-1 반영(■ 제출 ③ 머리 = 견본 차례·줄 수 · «» 까지 견본 글자 그대로 · «6» 표) · 남은 표식 0 · 자리표시자 0 — ~~⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**~~(2026-11-02 조립 · 앱 `rec/r15`) · 선행 = ① ✅ R15a 병합(squash `940082c` · PR #99 · 시작 기준 N = R15a 병합본 실측 237) ② ✅ **계약 v1.16 보강 병합(R15b 몫 G8~G14 — 아래 «■ 계약 v1.16 이름표» = v1.16 실제 글자 · ✅ PR #96 squash `dd9e162` · 2026-11-03 · CI 3/3 · 가지 `m2/v116-r15` `aaefdbc` → rebase head `fc97ff4` · R15a 와 같은 PR · ✅ 발주자 결정 2026-11-03)** ③ ✅ **`SecretField` 삽입 자리 꼴 = 슬롯 빌더 주입**(M4·M9 소유 위젯 · 실물 0 · 슬롯 이름 = `OnboardingSlotIds` 값 · 발주자 확인 ⑦ 권고대로) ④ ✅ 누적 드라이런 2번째(아래 «드라이런» 줄 · 지적 반영판 `dry/r15-2b` · 흉내 위) + ✅ 재드라이런 2(2026-11-03 · v1.16 실물 위 · 가지 `dry/r15v2-2` `ac711ac` · 아래 «드라이런» 줄 · 앞 카드 병합본에 기대는 값만 꺾쇠 자리) ⑤ ✅ 발주자 확인 ①~⑫ 확정 ⑥ ⬜ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R15a 브랜치(`ui/m8-o00-mode-pick`)는 건드리지 않는다.
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(🔀 4분할 — R15a 카드 머리 «재분할 판정») + §3-0 + §3 공통 조문 + 이월 부록 «R15» 대상(R15a 카드 «6» 과 같은 표 · O-01~O-03 자리) · 화면 몫 원본 = `04_…` §9 머리 · §9-2(`O-01` · 3등급 · 진행률 · 만료 시계 · 해외주식 0 · 갈래별 준비물 참고표 · 그림 18) · §9-3(`O-02` · 시크릿 6원칙 = `SecretField` 몫) · §9-4(`O-03` · 3상 · 원문 코드 · 그림 19) · §9-8(게이트 3상 · 그림 23) · `01_…` §2-10 `OnboardingStep`·`StepState`·`StepRequirement` · §2-1 `GateState`·`GateBadge` · §4-1 · §4-3 `SettingsActions`·`ActionResult` · `05_…` §4-1(`SecretField` 6원칙 — 읽기만) · 판독 메모 §5-1 G8~G14 · §5-2.
> 사전 조건 — ✅ **R15a 병합**(PR #99 squash `940082c` · 2026-11-04 · `ui_shell` = lib 14파일 · 라벨 37 · 배럴 export 11줄 · 셸 주입 17줄 · PNG 48 — 병합본 `940082c` 실측 그대로) · ✅ 계약 v1.16 병합(R15b 몫 포함 — R15a 와 같은 보강 PR #96 squash `dd9e162` · 2026-11-03 · 아래 이름표) · ✅ 프롬프트 v2. 시작 기준 = R15a 병합본의 `flutter test`(packages/ui_shell) = **237**(✅ R15a 병합본 실측 2026-11-04 · `940082c` · «00:23 +237: All tests passed!» · 드라이런 기대 237(재드라이런 2 «00:14 +237») 와 같음) · 이 카드 끝 기대 = 시작 기준 N + **49**(뷰 39 = `onboarding_step_list_test` 16 + `onboarding_step_detail_test` 23 · 골든 10 = `o01_*` 4 + `o02_*` 2 + `o03_*` 4 · 🆕 첫 판 44 → 지적 반영 +5 = O01-05 `locked`·`ready_warn` · O01-09 · O02-06 · O03-07) · 끝 = **+286**(✅ 병합본 가벼운 확인 2026-11-04 · `940082c` 위 `dry/r15v2-2` R15b 커밋 4 cherry-pick «00:17 +286: All tests passed!» · 드라이런 기대 «+286»(반영판 `dry/r15-2b` 실측 · 첫 판 «+281» · 재드라이런 2(v1.16 실물) «00:24 +286») 와 같음).
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **25**(`onboarding_step_list_test` 9 · `onboarding_step_detail_test` 13 · 골든 3 — 드라이런 지적 반영판) · lib **+410**(드라이런 · `onboarding_step_list.dart` 178 · `onboarding_step_detail.dart` 219 · `shell_providers.dart` +11 · `ui_shell.dart` +2) · 새 PNG **10** · 원천·쓰기 **3**(`watchStepList` · `watchStep` · `run(verify.id)`) → 임계 안 · 재분할 없음(R15 를 4장으로 나눈 까닭 = R15a 카드 머리).
> 카드 기본값(✅ 아래 «발주자 확인» ①~⑫ 확정): ⓐ 위젯 = `OnboardingStepList({super.key})`(`lib/src/onboarding/onboarding_step_list.dart` · `ConsumerWidget`) · `OnboardingStepDetail({super.key, required this.stepId})`(`lib/src/onboarding/onboarding_step_detail.dart` · `ConsumerStatefulWidget` — 검증 조각 `_busy`·`_failed`·`_result`) · `O-03` = `O-02` 안의 결과 조각(별도 라우트 0 — ⑥) ⓑ **셸 파일·R15a 파일은 고치지 않는다** — 연결 = 조립 앱 레지스트리(`AppRoutes.onboardingSteps` `aaq://onboarding/steps` · `AppRoutes.onboardingStep` `aaq://onboarding/:stepId` · 06 M4-11) ⓒ 원천 = 🆕 `watchStepList()` → `OnboardingStepsVm`(갈래 인자 0 — 엔진이 `onboarding_choice` 로 고른다 · ①) · 🆕 `watchStep(stepId)` → `OnboardingStepDetailVm` · 쓰기 = `SettingsActions.run(verify.id, args: verify.args)`(VM 이 준 동작 그대로 · 화면이 id·키를 짓지 않는다 · ⑤) — 주입 = R15a `shellOnboardingActionsProvider`(뷰어 null = 검증 버튼 부재) ⓓ O-01 = 진행률 글자(`progressText`) → 단계 행(받은 차례 · 상태 아이콘 = `StepState` 5값 전수 · 등급 글자 `requirementLabel` · 경고 배지 `warningLabel?` · 만료 `verifiedUntilText?` · 실패 문장 `failureText?` + 원문 코드 `failureReasonCode?` · 게이트 `gate?`(`GateState` 4값 전수 — `unknown` = 진행 차단 모양 · `notApplicable` 과 다른 모양)) → 빈 문장(`emptyLabel?`) → «다음» = `finishDeepLink`(O-04 · 있을 때) · 행 탭 = `detailDeepLink`(O-02 · null = 탭 없음) ⓔ O-02 = 제목·이유·어디서·얼마나·어떻게·만료(엔진 글자) → 🔒 시크릿 자리(`secretSlotId` 가 있을 때 · 슬롯 빌더 주입 · 자체 `TextField` 0) → 검증 버튼(`verify.label` · 주입·`verify` 있을 때) → O-03 결과 조각(`UiLevel` 5값 아이콘 · `headline` · `reasonCode` 원문 · `retryable` 이면 «다시 시도») · 모르는 id = `missingLabel` 한 줄 ⓕ 🔴 판정 0 — «검증 성공 같으니 다음 활성» 0 · 권장 미통과 = 경고 배지만(차단 = 엔진 `gate`) · 비율·남은 시간·만료 계산 0 · 해외주식 행 0(목록에 없으면 없다) ⓖ 새 lib 파일 2 · 공용 3(배럴 +2 · `shell_providers.dart` 끝 절 슬롯 빌더 1 · `test/shell_fakes.dart` 끝 절 — **끝 절 더하기만** · 라벨 0 · «정확히 N» = 마지막 카드) · Key 접두 `o01-`·`o02-`·`o03-` · 골든 5이름 10장(`o01_fresh` · `o01_advisory` · `o02_step` · `o03_ok` · `o03_fail_code`).
> 🔴 **카드 덮개 필수 문장(04 §9 머리 · §9-2~§9-4 · §9-8 · prompt_M8 145~152)** — «게이트 판정은 전부 엔진 — 화면은 판정 결과와 문구를 그린다(«검증 성공 같으니 다음» 0 · 권장 미통과 = 경고 배지만 · `unknown` = 진행 차단 · `notApplicable` 과 같은 모양 0 · «일단 진행» 0)» · «목록은 받은 차례 그대로 — 갈래를 화면이 모른다(목록 두 벌 0 · `OperatingMode` 0) · 진행률 = `progressText` 그대로(비율 계산 0) · 만료 = `verifiedUntilText` 늘 보임(UTC `verifiedUntil` 포맷 0)» · «시크릿 = `SecretField` 삽입 자리뿐 — 자체 `TextField`·붙여넣기 버튼·마스킹·임시 저장·확인 필드 0» · «검증 = VM 이 준 동작 `run(id, args)` 그대로 1회 · 결과 = 3상(성공/실패/재시도)만 · 실패 문구 = `headline` + 원문 코드(요약·의역 0) · 재시도 가능 = `retryable` 데이터» · «셸 파일·R13·R14·R15a 파일·테스트·PNG 는 고치지 않는다».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 01 §2-1 `GateState.unknown`(진행 차단) · 01 §2-10 `estimatedText` · X7 §5-3(준비물 갈래 — 엔진 몫) · K35.
> ✅ **확정(2026-11-03 · 발주자 · ① 4분할 + v1.16 선행 + 플랫폼 몫 화면 밖 · ② whereText 글자만 · 체크섬 = M9 슬롯(04 정정) · ③ 미결 120·32 · V-01 PairingRepository · X1 라우트 등록 · ④ 나머지 권고대로)** — 발주자 확인 12건(아래 권고 = 확정 글자 · 🆕 2026-11-03 드라이런·감사·명세 지적으로 ②③⑥⑧⑨ 에 더한 갈림 = 전부 권고 쪽 · «대안» = 기각 기록) — ① O-01 원천 = 🆕 추가형 `watchStepList()` → `OnboardingStepsVm{progressText, rows, emptyLabel?, finishDeepLink?}`(갈래 인자 0 — 04 §9-2 «화면은 갈래를 알지 못한다» · 기존 `watchSteps(OnboardingTrack)` = v1.16 이 그대로 둔다 — 이 카드 미호출 · 존폐 = 01 §8 미결 149) ② `OnboardingStep` 표시 칸 = 🆕 `requirementLabel`(등급 글자 — «권장» 낱말도 엔진 글자 · R15a 의 «권장 0» 은 `O-00b` 몫) · `warningLabel?`(권장 미통과 배지 — 엔진 판정) · `verifiedUntilText?` · `failureText?` · `gate?`(`GateBadge`) · `detailDeepLink?`(O-02) — `verifiedUntil`·`estimated`·`requirement`·`whereDeepLink` = 화면 미참조 · 🆕 상태 글자 = `verificationLabel`·`failureText` 가 있을 때만(notStarted·inProgress 는 아이콘·색만 — 04 §2-3 «색·아이콘·글자 함께» 와 갈림 · 명세 지적) · 대안 = v1.16 `stateLabel`(엔진 글자) ③ 단계 게이트 = `GateBadge.state` 4값 전수 switch(아이콘·색 — `unknown` = 차단 모양 · `notApplicable` = 다른 모양) · 글자 = `gate.label` · «일단 진행» 0 · 🆕 `GateBadge.blockedReasonCode` = 화면 미참조 그대로(01 C-44 ⑮ 가 같은 칸을 «원값·키» 로 금지한 선례 · 04 §9-8 그림 23 «blockedReasonCode 문구» = 그 코드의 문구 = `gate.label` · 원문 코드 = 행 `failureReasonCode`·검증 `reasonCode` 몫 — 명세 지적 기각 까닭) · 대안 = block 행에 코드 한 줄 더하기(C-44 와 갈린다) ④ O-02 원천 = 🆕 `watchStep(stepId)` → `OnboardingStepDetailVm{step?, missingLabel?, whereText?, howText?, verify?, secretSlotId?}`(목록을 거르면 «판정» — 단건 창구) · 모르는 id = `missingLabel` 값(에러 아님) ⑤ 검증 동작 = 🆕 `OnboardingAction{id, args, label}`(엔진이 단계 ↔ `SettingsActionId` + 화이트리스트 args 를 완성 — 화면이 키를 짓지 않는다 · null = 버튼 부재) ⑥ O-03 = O-02 안 결과 조각(`run` 반환 `ActionResult` 하나 · `level` 아이콘 · `headline` · `reasonCode` 원문 · `retryable` → «다시 시도») · 별도 라우트·`watch(actionRunId)` 0(링크 조립 0) · 🆕 04 §9-4 «3상» 읽기 = 성공(`level` ok) · 실패(그 밖 `level` · 또는 예외 = 정적 «접수되지 않았습니다») · 재시도(`retryable`) — 아이콘은 `UiLevel` 5값 전수(규칙 6 · 상태를 새로 만들지 않는다 · 표본 = ok·blocked 만 · 명세 지적) ⑦ 🔴 `SecretField` 삽입 자리 = 🆕 슬롯 빌더 주입 `shellOnboardingSlotBuilderProvider`(`Widget Function(String slotId)?` · 조립 앱 = M4·M9 `SecretField` · 뷰어·미주입 = null = 자리 부재 · R15c 의 서약문·생체·셀프테스트·체크섬 자리도 같은 주입) · 대안 = `ShellPlaceholder` 고정 높이 자리(소유 위젯이 오면 골든 재촬영 `golden:approved`) ⑧ ✅ `whereDeepLink` 뜻 = v1.16 정리(결정 ② — 내부 단계 링크 = `detailDeepLink` · «어디서 받나» = `OnboardingStepDetailVm.whereText` 글자만 · 외부 URL 열기(KIS 개발자센터 · GitHub · healthchecks) = 플랫폼 몫(조립 앱 · 06 M4-11 · `AppLinkSchemes` 밖) · `whereDeepLink` = 화면 미참조(옛 뜻 = 자기 단계 링크 · 신설 표본 null · 01 §8 미결 150) · 04 §9-3 «어디서 받나(외부 딥링크)» 는 «글자 + 플랫폼 몫» 으로 정정됨(설계 2b304cf)) ⑨ 표본 정리 = v1.16 새 `m8/onboarding_steps_*` 에 `o_00`(운영 모드 행 — O-01 에서 O-00b 로 되돌아가는 길 · 04 §9-1 «O-01 안의 한 단계 기각»)·`o_04`(가상 초기금 — O-04 6단계 몫) 행 0 · 해외주식 행 0 · 🆕 표본 셋 더(드라이런 지적 — 예고 변이를 잡는 표본): `m8/onboarding_steps_empty`(rows 0 · `emptyLabel` · «emptyLabel 빼기») · `m8/onboarding_steps_all_verified_locked`(전부 verified · `finishDeepLink` null · 게이트 unknown 행 — «전부 verified 면 첫 행 링크로 다음» 류) · `m8/onboarding_steps_finish_ready_warn`(권장 미통과 행 + `finishDeepLink` — «finishDeepLink 대신 전부 verified 면 다음») ⑩ 정적 라벨 0(«다음» = R15a `onboardingNext` · «다시 시도» = `retry` · 실패 = R15a `onboardingNotAccepted` 재사용) ⑪ 골든 5이름 10장(`o01_fresh` · `o01_advisory` · `o02_step` · `o03_ok` · `o03_fail_code` — 04 에 이름 없음 · 카드가 지음) ⑫ 이월 반영(«6» — C4r14a-5 = O-03 검증 조각).
> 🚫 **플랫폼 몫 = 화면 밖** — Android Keystore · 클립보드 60초 클리어 · `FLAG_SECURE`(시크릿 라우트 진입/이탈 · 05 §4-2) · 생체인증 열람 · 외부 URL 열기(KIS 개발자센터 · GitHub · healthchecks — `url_launcher` 0) · Android 권한 요청(`o_05` 알림 · `o_06` 배터리 최적화 · 정확 알람 · FGS 5분 실측) = 조립 앱·엔진(06 M4-4 · M4-11 · X3 · ✅ 결정 ①) · 이 카드 = 엔진이 준 결과·글자만.
> 드라이런: 🆕 ✅ **병합본 가벼운 확인**(2026-11-04 · R15a 병합본 `940082c` · worktree `C:/Work/AAQ-claude-r15bchk` · 끝에 삭제 · 🔵 전면 재드라이런 하지 않음 — R15a 는 코드 정정 없이 병합(통합 수정 = PR 본문 «C4 정정» 1곳뿐) · Bob 판 R15a lib 의 드라이런 대비 차이 = 주석·지역 변수 선언 차례뿐 · 공용 4파일 = 드라이런과 바이트 같음 · 이 카드는 R15a 파일을 고치지 않는다) — ⓐ 0단계 확인 31줄(grep 16 · ls 12 · 반대 3)을 병합본에서 실제로 실행 = 기대 그대로(grep «:1» 16 · ls 11 있음 + `send/R15b-Bob-O01O03.md` = 이 기록 커밋이 넣음 · 반대 3 없음/출력 없음) · 사전 조건 실측 = lib `.dart` 14 · 라벨 37(P13 꼴) · `^export` 11 · `^final …> shell` 17 · PNG 48 · `flutter test` «00:23 +237» · `domain_contracts` «00:11 +424 ~30» · ⓑ `dry/r15v2-2` 의 R15b 커밋 4(`4c60979` · `8bf7e2a` · `506fb83` · `ac711ac`)를 병합본 위에 cherry-pick = 충돌 0 · 바뀐 파일 21 = 카드 name-status 기대 · R15b 파일 20 = `dry/r15v2-2` blob 그대로(다른 것 = 질문 파일 머리말뿐 — 밑동 차) → `flutter test` 파일별 «00:01 +16» · «00:01 +23» · «00:00 +4» · «00:00 +2» · «00:00 +4» · 전부 «00:17 +286» · `domain_contracts` +424 ~30 · `o01~o03_*` 10장 = `dry/r15v2-2` blob 그대로(10/10 · --update-goldens 0) · ui_shell PNG 58 · 정적 34줄(이 판 꺼내기 범위 · 해시 `8929219`) Git Bash 파일 실행 = 카드 기대(아래 «■ 정적 묶음») · 사전검사 ① 🔴 0 · 🟡 0 → 카드 기대 글자(시작 237 · 끝 +286 · 파일별 · +424 ~30 · 정적 162 · 19 · 15 · PNG 58) 고칠 곳 0 · ✅ 누적 드라이런 2번째(2026-11-02~03 · 첫 판 가지 `dry/r15-2` = R15a 드라이런 끝 `5c46f58` → R15a 병합 기록 흉내 `77ad6dc` → v1.16 R15b 몫 흉내 `90edc68`(G8~G14 · 칸 +6 · 새 DTO 3 · 표본 7 · 기존 OnboardingStep 표본 5개 `requirement_label` · C-33 링크 키 2 · reason_code = C-5 등재 코드) → 권장 4커밋 `31a341e`·`bac114e`·`91dc333`·`66ffe93` · 🆕 지적 반영판 가지 `dry/r15-2b` = + 표본 흉내 `031af01`·`260fdd6`(empty · all_verified_locked · finish_ready_warn) + 테스트 `85475d5`·`260fdd6`) · 첫 판 시작 «+237» → 끝 «+281»(파일별 +13 · +21 · +4 · +2 · +4) → 반영판 끝 «+286»(+16 · +23) · 정적 34줄(첫 판 = 출력 162줄 · EXIT:1 19 · EXIT:0 15 — 판정 줄 전부 기대대로) · 사전검사 ① 🔴 0 · 🟡 0 · ② `o01_` 🟡 0 · `o02_` 🟡 2 · `o03_` 🟡 4(전부 G1) · 골든 dy 5(light = dark) · lib +410 · PNG 열람 5장 · 막힌 곳 2 = `StepState` 이름 충돌(`hide StepState`) · `o01_fresh` 맨 아래 Key(→ `o01-row-4`) · 변이 62꼴 = 예고 SURVIVED 4(L6 emptyLabel 빼기 · J6a «전부 verified 면 다음» · T1b O-02 머리 만료 빼기 · V5 기다리는 동안 두 번) → 🆕 반영판에서 4꼴 + J6c(fallback 링크) KILLED(O01-09 · O01-05 `ready_warn`·`locked` · O02-06 · O03-07) · 정적이 잡음 = J1a(P11 `.requirement`) · 참고 RF7(P04) · RF9(P06) · RF5b = 이름 충돌로 컴파일 무효 · 🔵 흉내 = 권고 이름표 글자(`detailDeepLink`·`finishDeepLink`·`OnboardingAction` · 표본 글자·행 수도 v1.16 실물과 다르다 — 10벌 전부 · 실물 = 설계서 §5-2 · 예 `advisory` 10행 · 상세 `noVerify` = 만료 글자 없는 단계) → 골든 dy · ③ 견본 · 🟡 기대는 v1.16 실물 위 재드라이런이 다시 잰다 · 🆕 ✅ **재드라이런 2**(2026-11-03 · base `dry/r15v2-2-base` `e32c481` = R15a 재드라이런 끝 `57f3005` + R15a 병합 기록 흉내 · 가지 `dry/r15v2-2` = `4c60979`·`8bf7e2a`·`506fb83`·`ac711ac` · (5) 없음) — 0단계 기대 28줄 그대로 · 237 → «+286»(파일별 +16 · +23 · +4 · +2 · +4) · 정적 34줄(`bafe5b9` 판 302~335 · hash `8929219`) 출력 162줄(EXIT:1 19 · EXIT:0 15 · 판정 줄 전부 기대대로) · lib +410 · 사전검사 ① 🔴 0 · 🟡 0 · ② `o01_` 🟡 2 · `o02_` 🟡 2 · `o03_` 🟡 4 · 카드↔코드 어긋남 4 → 이 판에서 고침(`o01_fresh` 맨 아래 Key `o01-row-4` = 아래 끝 844.0 → `o01-row-3` 700.0 · ③ 견본 2행 = 흉내 값 · `o01_` 🟡 기대 0 → 2 · 끝 상자 «N + 44» → 49) · 골든 dy = 700.0 · 744.0 · 356.0 · 404.0 · 472.0(light = dark · 잘림 0) · 변이 = 예고 52꼴 KILLED 50 · SURVIVED 2(J1a = 정적 P11·P09 · T1b = 🔵 참고 — 상세 표본에 만료 글자 0) · 참고 13꼴 KILLED 10 + 정적 3(RF5b · RF7 · RF9) · 테스트 쪽 RF1 = T3 🔴 · RF2 = T1 🔴 · RF1b 늘 참 find.byType · RF13 nullable 흐름 칸 + if = 사전검사 🔴 0 → «5» C4 사람 grep.
> 프롬프트 = `docs/ai-context/prompt_M8.md`(v2 판 183줄 · 2행·119행 범위 · 128행 PR 제목 형식 → 이 카드가 덮는다). 🔴 Bob **새 대화** 전제 — R15a 대화를 기억하지 못합니다.
> R4·R13·R5·R14·R15a 교훈 반영: R15a 카드 머리 «교훈 반영» 줄과 같다(PNG 열람 = 이름마다 light 1장(5장) · 경우 for 는 testWidgets 밖 · 흐름 칸 non-null · 경우 이름 = name 칸 · 쓰기 조각 두 방향 · 부재 = 데이터는 operator · 전제는 if 밖·`// pre` · 커밋마다 `git show --stat HEAD` · 저장 파일 BOM 0 · ① = 파일로 받은 출력 · 정적 = 파일로 Git Bash · 머리 ASCII · G1 🟡 조문 · ③ 구분 줄 · ④ «+» · 단언 없는 `takeException` 0 · 파일별 시각 머리 · 이어진 글자 행 = 한 덩어리 · «자리 바꿈» 견본 · 입력 칸 = 파일 이름만).

## 0. 한 줄 목적

`OnboardingStepList()` 가 `watchStepList()` 의 `OnboardingStepsVm`(진행률 글자 · 엔진이 갈래로 고른 단계 목록 · O-04 링크)을 받은 차례·글자 그대로 그리고(상태 = `StepState` 아이콘 · 등급·경고·만료·실패 = 엔진 글자 · 게이트 = `GateState` 4값 · 판정 0), `OnboardingStepDetail(stepId:)` 가 `watchStep` 의 단계 상세를 그린 뒤 시크릿은 주입된 슬롯 빌더에만 맡기고(자체 입력 0), 검증 버튼 한 번에 VM 이 준 동작 `run(id, args)` 를 한 번만 불러 결과를 3상·원문 코드 그대로 보이는 `O-01`·`O-02`·`O-03` 을 계약 v1.16 그대로 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-o01-steps`**(base = 최신 `origin/main` · `--no-track` · 분할 뒤 새 이름 · ✅ 결정 ①) · PR 제목 = «[M8] O-01~O-03 단계 목록·상세·검증».

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — ✅ 2026-11-04 R15a 병합 기록(PR #99 `940082c` · 병합본 시작 기준 N = 237)이 `send/` 로 옮기고 표식·펼침을 채웠습니다(「푸시해」 뒤 `main` 에 올라가면 보냅니다).
2. Bob 에 R15a 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다.
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R15b-Bob-O01O03.md>(`send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R15b-Bob-O01O03 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R15a-Bob-O00O00b*.md` · 다음 장 `_대기/R15c-Bob-O04.md` 를 붙여넣지 않습니다.
6. 🔴 **받는 법** — R15a 와 같다(`$env:TEMP\R15b-Bob-O01O03_submit.md` · BOM 0 · 채팅 두 줄 · 그 파일을 열어 통째로 붙여 넣기).
7. 🔵 이전 창의 `flutter_tester` 를 직접 끝내지 마세요(다른 세션 것도 있습니다).

## 3. 붙여넣을 본문 — ````text 다음 줄(«R15b-Bob-O01O03 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R15b-Bob-O01O03 — 범위: O-01 단계 목록(OnboardingStepList() — 진행률 · 단계 행(상태 아이콘 · 등급 · 경고 · 만료 · 실패 문장+원문 코드 · 게이트) · 빈 문장 · «다음» = O-04 링크 · 행 탭 = 상세 링크) ·
  O-02 단계 상세 + O-03 검증 결과(OnboardingStepDetail(stepId:) — 상세 글자 · 🔒 시크릿 자리(슬롯 빌더) · 검증 버튼 · 결과 조각(3상 · 원문 코드 · 재시도)) + 새 주입 1(슬롯 빌더) + 배럴 export 2줄 + 가짜 끝 절.
🔴 게이트 판정은 전부 엔진 — «검증 성공 같으니 다음» 0 · 권장 미통과 = 경고 배지만 · gate unknown = 진행 차단 모양 · notApplicable 과 같은 모양 0 · «일단 진행» 0.
🔴 목록 = 받은 차례 그대로 · 갈래를 모른다(목록 두 벌 0 · OperatingMode 0) · 진행률 = progressText 그대로 · 만료 = verifiedUntilText 늘 보임 · 비율·남은 시간 계산 0 · 해외주식 행 0.
🔴 시크릿 = 주입 슬롯 빌더(SecretField 자리)뿐 — TextField·붙여넣기 버튼·마스킹·임시 저장·확인 필드 0 · 주입 null = 자리 부재.
🔴 검증 = VM 이 준 run(verify.id, args: verify.args) 1회 · 결과 3상만 · 실패 문구 = headline + reasonCode 원문(요약·의역 0) · 재시도 = retryable 데이터 · 뷰어(주입 null) = 버튼 부재.
🔴 셸 파일·R13·R14·R15a 파일(onboarding_start · onboarding_mode_pick)·테스트·PNG 는 고치지 않는다.
하지 않는 것: O-00·O-00b(R15a · 병합됨) · O-04 마무리(R15c) · R-01·V-01(R15d) · 외부 URL 열기 · 권한 요청 · Keystore · FLAG_SECURE · 실키(KIS_LIVE·ISA — M5 위저드) · 조립 앱 배선 · domain_contracts·pubspec 수정 · 다른 ui_* 수정 · 새 정적 라벨.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 17항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R15a(ui/m8-o00-mode-pick — 병합됨)가 아닙니다. 앞 카드의 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_shell/lib/src/onboarding/onboarding_step_list.dart 가 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m8-o00-mode-pick 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m8-o01-steps origin/main      ← 🔴 git checkout main 금지
  git grep -c "contractVersion = '1.16.0'" -- packages/domain_contracts/lib/src/contract_version.dart                       ← «…contract_version.dart:1»(계약 v1.16 · R15a 병합본 940082c 실측 «:1» · 2026-11-04)
  git grep -c "Stream<OnboardingStepsVm> watchStepList();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart  ← «…:1»(v1.16)
  git grep -c "Stream<OnboardingStepDetailVm> watchStep(String stepId);" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart  ← «…:1»(v1.16)
  git grep -c "abstract class OnboardingStepsVm" -- packages/domain_contracts/lib/src/dto/onboarding.dart                      ← «…onboarding.dart:1»(v1.16 · 온보딩 VM 파일)
  git grep -c "abstract class OnboardingStepDetailVm" -- packages/domain_contracts/lib/src/dto/onboarding.dart                 ← «…onboarding.dart:1»(v1.16)
  git grep -c "abstract class OnboardingAction" -- packages/domain_contracts/lib/src/dto/onboarding.dart                       ← «…onboarding.dart:1»(v1.16 · 검증·DRY_RUN 공용 동작)
  git grep -c "required String requirementLabel," -- packages/domain_contracts/lib/src/dto/safety.dart                         ← «…safety.dart:1»(v1.16 · OnboardingStep 표시 칸)
  git grep -c "String? verifiedUntilText," -- packages/domain_contracts/lib/src/dto/safety.dart                                 ← «…safety.dart:1»(v1.16)
  git grep -c "String? failureText," -- packages/domain_contracts/lib/src/dto/safety.dart                                       ← «…safety.dart:1»(v1.16)
  git grep -c "GateBadge? gate," -- packages/domain_contracts/lib/src/dto/safety.dart                                           ← «…safety.dart:1»(v1.16 · 🔵 lib 전체로 넓히면 2 — onboarding.dart 의 OnboardingFinishStage 에도 있다)
  git grep -c "static const String m8OnboardingStepsFresh =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← «…:1»(v1.16)
  git grep -c "static const String m8OnboardingVerifyResults =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart ← «…:1»(v1.16)
  git grep -c "final Provider<SettingsActions?> shellOnboardingActionsProvider" -- packages/ui_shell/lib/src/shell_providers.dart  ← «…:1»(R15a 병합)
  git grep -c "static const String onboardingNotAccepted" -- packages/ui_shell/lib/l10n/labels.dart                              ← «…:1»(R15a 병합)
  git grep -c "class FakeShellOnboardingRepository" -- packages/ui_shell/test/shell_fakes.dart                                  ← «…:1»(R15a 병합 — 이 카드는 끝 절에 새 가짜를 더한다 · 고치지 않는다)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                          ← «…prompt_M8.md:1»
  ls docs/ai-context/send/R15b-Bob-O01O03.md                                ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/O01O03_questions.md                              ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_fresh.json      ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_advisory.json   ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_finish_ready.json  ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_finish_ready_warn.json  ← 보여야 함(v1.16 · 🆕 드라이런 지적)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_all_verified_locked.json  ← 보여야 함(v1.16 · 🆕)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_empty.json      ← 보여야 함(v1.16 · 🆕)
  ls packages/domain_contracts/fixtures/m8/onboarding_step_detail_kis_mock.json  ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_step_detail_no_verify.json  ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_step_detail_missing.json  ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_verify_results.json   ← 보여야 함(v1.16 · ActionResult 3행)
     (🔴 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로)
  아래 세 줄만 반대다 — 🔴 «없음»·출력 없음이 정상:
  ls packages/ui_shell/lib/src/onboarding/onboarding_step_list.dart         ← 없어야 함
  ls packages/ui_shell/test/onboarding_step_list_test.dart                  ← 없어야 함
  git grep -c OnboardingStepDetail -- packages/ui_shell/lib                 ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_shell
  flutter test   ← 시작 기준: R15a 병합본 전부 통과 · 기대 «+237: All tests passed!»(R15a 병합본 940082c 실측 «00:23 +237» · 줄 머리 시각은 실행마다 다름 · 드라이런 기대 237 와 같음)(끝 줄의 수를 «시작 기준 N» 으로 · 다르면 PR 본문에 까닭 한 줄 · 실패가 있으면 멈추고 끝 20줄을 채팅으로)
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 계약 v1.16 이름표 — R15b 몫(🔴 코드가 정본 — 다르면 멈추고 질문 파일에 · ✅ v1.16 실제 글자 = 설계서 §4 · 01 §25)
  OnboardingStep(dto/safety.dart · 기존 + 🆕 칸)  …기존 칸 · 🆕 required String requirementLabel(등급 글자 — 엔진) · String? warningLabel(권장 미통과 배지 — 엔진 판정 · null = 부재) · String? verifiedUntilText(만료 글자 — 엔진 · null = 만료 없음) ·
                     String? failureText(실패 문장 — 엔진 · failureReasonCode 와 함께) · GateBadge? gate(단계 잠금 — 엔진 판정 · null = 게이트 없음) · String? detailDeepLink(O-02 링크 `aaq://onboarding/<stepId>` — 엔진이 완성 · null = 행 탭 없음)
                     — 🔴 화면 미참조: stepId · track · order · estimated(Duration) · requirement(열거 — 글자 = requirementLabel) · verifiedUntil(UTC) · whereDeepLink(v1.16 = 화면 미참조 · 옛 뜻 = 자기 단계 링크 · 신설 표본 null · 01 §8 미결 150)
                     — ✅ v1.16 반영(드라이런·명세 지적): requirementLabel 이 required 라 기존 OnboardingStep 표본 5개(onboarding_fresh · onboarding_reconnect · m8/onboarding_finish · m8/onboarding_fresh_advisory · m8/restart_lost_phone)에 requirement_label(+ verified_until_text) 보강 · C-33 `_linkKeys` += finish_deep_link(detail_deep_link 은 기존 deep_link 꼴 키) · C-50 ⑥ «verifiedUntil non-null ⇒ verifiedUntilText non-null · 글자 머리 = verifiedUntil 의 KST 날짜»(표본 계약 테스트 — 꼬리 «까지»·«에 만료됨» = 엔진 몫 · 화면은 글자만 읽는다)
  🆕 OnboardingStepsVm({required String progressText, required List<OnboardingStep> rows, String? emptyLabel, String? finishDeepLink})(dto/onboarding.dart)
                     — progressText = «7/12 완료» 류(엔진) · rows = 엔진이 onboarding_choice 로 고른 갈래 목록(받은 차례) · emptyLabel = rows 0 일 때만 · finishDeepLink = O-04 링크(`aaq://onboarding/finish` · 필수 통과 뒤에만 — 엔진 판정 · null = «다음» 부재)
  🆕 OnboardingStepDetailVm({OnboardingStep? step, String? missingLabel, String? whereText, String? howText, OnboardingAction? verify, String? secretSlotId})(dto/onboarding.dart)
                     — step non-null XOR missingLabel non-null · whereText = «어디서 받나»(엔진 글자 · 외부 열기 0) · howText = «어떻게 검증하나»(엔진) · verify = 검증 동작(null = 버튼 부재) · secretSlotId = 시크릿 자리 이름(OnboardingSlotIds 값 · 표본 `SECRET_KIS_MOCK` · 🔴 화면은 이름을 글자로 쓰지 않는다 — 빌더에 그대로 · null = 자리 없음)
  🆕 OnboardingAction({required SettingsActionId id, required Map<String, String> args, required String label})(dto/onboarding.dart · 검증·DRY_RUN 공용)
                     — id·args = 엔진이 화이트리스트 안에서 완성(표본 = credentialVerify `{kind: KIS_MOCK}` · 🔴 화면이 키·값을 짓지 않는다 · 그대로 넘긴다) · label = 버튼 글자(엔진) · 결과 읽기 = headline + reasonCode 원문 + retryable(O-03 만 · settings_actions.dart 주석)
  repositories/onboarding_repository.dart  Stream<OnboardingStepsVm> watchStepList(); · Stream<OnboardingStepDetailVm> watchStep(String stepId);(추가형 · 스트림 에러 = 읽기 실패 · 모르는 id = missingLabel 값)
  testing.dart  UnimplementedOnboardingRepository(v1.16 — 새 두 메서드 포함) · UnimplementedSettingsActions(기존)
  FixturePaths  m8OnboardingStepsFresh · m8OnboardingStepsAdvisory · m8OnboardingStepsFinishReady · 🆕 m8OnboardingStepsFinishReadyWarn · m8OnboardingStepsAllVerifiedLocked · m8OnboardingStepsEmpty · m8OnboardingStepDetailKisMock · m8OnboardingStepDetailNoVerify · m8OnboardingStepDetailMissing · m8OnboardingVerifyResults(아래 «픽스처»)
  🔴 쓰지 않는 것: watchSteps(OnboardingTrack) · 코어 onboarding_fresh·onboarding_reconnect · m8/onboarding_fresh_advisory(형제 키 operating_mode·credential_use — 화면이 읽을 DTO 0) · OperatingMode · SettingsActions.watch.

■ 규칙 요약 (전문 = prompt_M8.md · 우선순위 = 코드 > 이 카드 > 01 §2-10·§2-1·§4-1·§4-3 > 04 §9-2~§9-4·§9-8 > prompt_M8 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_shell + docs/ai-context/inbox/O01O03_questions.md 만. 새 파일 = lib/src/onboarding/onboarding_step_list.dart · onboarding_step_detail.dart · test/onboarding_step_list_test.dart · test/onboarding_step_detail_test.dart ·
   test/golden/o01_golden_test.dart · o02_golden_test.dart · o03_golden_test.dart · 새 PNG 10.
   공용 3파일은 **끝 절 더하기만**: lib/src/shell_providers.dart = 파일 끝에 R15b 절(주입 1) · lib/ui_shell.dart = export 두 줄(자리 = 정렬 차례 — export 'src/onboarding/onboarding_step_detail.dart'; export 'src/onboarding/onboarding_step_list.dart'; 는 export 'src/onboarding/onboarding_start.dart'; 바로 뒤) ·
     test/shell_fakes.dart = 파일 끝에 R15b 절.
   고치면 반려: 그 밖의 ui_shell 파일 전부(lib/l10n/labels.dart · onboarding_start.dart · onboarding_mode_pick.dart · 셸·홈·리듬·알림·워치독 lib · 앞 카드 테스트·골든 테스트 · 비교기 · golden_support.dart · golden README · 기존 PNG · pubspec · analysis_options · README) · domain_contracts/** · apps/** · 다른 ui_*.
 2 화면은 받은 글자와 null 여부만 본다 — 값 = progressText · title · whyLine · estimatedText · requirementLabel · warningLabel · verificationLabel · verifiedUntilText · failureText · failureReasonCode · gate.label · emptyLabel · missingLabel · whereText · howText · verify.label ·
   결과 headline · reasonCode 원문 그대로 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 0(라벨도 새로 0) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱).
 3 읽지 않는 필드(카드가 정함): OnboardingStep 의 stepId(🔴 Key·비교 0 — 순번만) · track · order · estimated · requirement · verifiedUntil · whereDeepLink · GateBadge 의 code · blockedReasonCode · ActionResult 의 actionRunId · id · handoffRoute(🔴 결과 = level 아이콘 · headline · reasonCode · retryable 넷).
 4 이동 = AppLinkOpener.open(link) 하나(탭 콜백 안) — 링크 = 행 탭 step.detailDeepLink · «다음» finishDeepLink 둘뿐 · 🔴 'aaq://'·'https://' 리터럴 0 · AppRoutes 0 · 링크 조립 0 · 외부 URL 열기 0(whereText = 글자) ·
   공개 위젯 생성자 = OnboardingStepList({super.key}) · OnboardingStepDetail({super.key, required this.stepId}) 둘 · 🔴 stepId 는 watchStep 인자로만(글자·Key·비교 0).
 5 산술·판정 0 — 허용 = ⓐ null 여부(링크 · 글자 칸 · gate · verify · secretSlotId · 슬롯 빌더 · 주입 · _result) ⓑ StepState 5값 · GateState 4값 · UiLevel 5값 전수 switch(아이콘·색) ⓒ 검증 버튼 가능 = 주입 non-null ∧ verify non-null ∧ !_busy(한 식) ·
   ⓓ 검증 조각 상태(_busy · _failed · _result) · result.retryable(«다시 시도» 있음 여부 — 엔진 판정을 읽기만) ⓔ 순번(indexed). 그 밖에 거르기·세기·정렬·자르기 0 · rows.length 글자 0 · DateTime.now 0 · Duration·DateTime 포맷 0 ·
   requirement·state 로 차단·활성 판정 0(🔴 «권장인데 미통과면 배지» 를 화면이 만들지 않는다 — warningLabel) · OperatingMode·FeatureFlags·RunMode 0.
 6 switch 는 열거값 전수(default 0): StepState 5값(_stepLook) · GateState 4값(_gateLook) · UiLevel 5값(_resultLook) — 셋뿐 · 🔴 _gateLook 의 unknown 과 notApplicable 은 다른 아이콘·색(04 §9-8).
 7 공통 조각 = ShellSkeleton · ShellErrorView 재사용 · asOf 머리·오래됨 배너 0(R15a ⑤ 와 같다 — VM 에 asOf 없음) · 새 공용 조각 0 · 스피너 금지 · 시계 미사용.
 8 본문이다 — Scaffold·AppBar·SafeArea·Navigator 0 · 부모 높이 안 ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 · 간격·크기 = 정수·N.0.
 9 프로바이더 — 새 주입 1(슬롯 빌더 · throw 기본값) · 데이터 2(StreamProvider 1 · StreamProvider.family 1 — stepId · 파일 안 private · autoDispose 0) · 탭 핸들러 안 ref.read · 데이터·주입 null 여부는 build 에서 ref.watch.
10 테스트 = 받침대 extends(UnimplementedOnboardingRepository · UnimplementedSettingsActions) · 🔴 implements 가짜 0(정적 P30) · 받은 인자 전부 기록 · 호출마다 새 Stream/Future · 가짜 공장 = 받은 call 로 삼항(C4r4b-7) · 따로 세는 변수 = 호출 수 칸뿐 ·
   공장 안 early-return if 0 · 픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지 · C4r4b-6) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다(C4r4b-1) — 자리 = testWidgets 본문 첫머리
     (main() 바로 아래의 expect 는 테스트 밖이라 파일 적재가 OutsideTestException 으로 실패한다) · 전제 문장마다 끝에 `// pre`(ASCII · 정적 P34 가 센다 = 최소 목록의 «(전제)» 수) · 동작은 UI 를 실제로 눌러서 ·
   🔴 경우 for 는 testWidgets 밖(C4r14b-1): for (final _Case c in cases) { testWidgets('<번호> <요지> ${c.name}', (WidgetTester tester) async { … }); } · 경우 칸 name 은 테스트 이름에 쓴다(안 쓰는 칸 0 · 테스트 수 = 경우 수) ·
     경우 이름 = 레코드 name 칸 글자(비교식·삼항으로 짓지 않는다 · C4r14a-4) · 흐름 = 클로저 칸 non-null — 흐름이 없는 경우도 (WidgetTester t) async {} 를 넣고 본문은 if 없이 await c.flow(tester); 한 줄(C4r14b-2) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(ShellLabels.retry), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(전부 픽스처 · copyWith 0 — 정적 P31) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 가짜의 호출 기록은 목록 == 목록 · 픽스처마다 갈리는 단언은 if/else 양쪽에 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴 ·
   🔴 «부재 = 데이터» 테스트(시크릿 자리 없음 · «다음» 없음 · 검증 버튼 부재 대조)는 주입을 operator 로 못박는다(뷰어로 띄우면 버튼 부재 단언이 공허 · C4r14a-6) ·
   테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII · «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2) ·
   🔴 반려 꼴: bool 칸 + if 로 경우 흐름 가르기 · nullable 흐름 칸(Function(…)? flow) + if (c.flow != null) · c.name == / flow.name == 비교 · opened[0] 만 보기 · expect(a || b, isTrue) · 괄호 단언(«X 0(Y 0)» — 단언마다 따로) ·
     단언 없는 tester.takeException();(쓰면 expect(tester.takeException(), isNull) 꼴 · 정적 P35) ·
   제네릭 위젯 술어 = tester.widget<Icon>(find.descendant(of: find.byKey(…), matching: find.byType(Icon)).first) 꼴(firstIconIn 도우미)만 — 아이콘 단언 = icon · color 두 줄(🔴 find.byType(Icon)·find.byType(Padding) 류를 단독으로 세면 늘 참 · C4r5a-4) ·
   스켈레톤 1 = expect(find.byKey(const Key('o01-loading')), findsOneWidget) 꼴(O-02 = Key('o02-loading')) · Key 를 단 묶음(Padding·InkWell·Row)의 글자 = shownTexts(tester, find.byKey(…)) == 기대 목록(R13a 도우미 · 트리 순서) ·
   🔴 Key 가 Text 자체에 붙은 자리는 shownTexts 가 [] 를 낸다(find.descendant 는 뿌리를 세지 않는다) → 이 카드는 Key 를 Text 에 달지 않는다(전부 Padding·InkWell·Row·FilledButton·TextButton·Icon · 아래 «Key 표»).
   🔴 시크릿 자리 테스트 = 가짜 슬롯 빌더(slotId 를 받아 Key('fake-slot-<slotId>') 단 SizedBox 를 낸다 · 받은 slotId 를 기록)로만 — TextField 를 찾지 않는다 ·
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄(🔴 O-03 «다시 시도» 가 보이는 경우는 그 테스트의 ⓡ 를 쓰지 않는다 — 아래 목록이 정한다) · ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 한 줄(n = 정수 리터럴 — 이 카드 = 12) · 🔴 전제에 hasLength 0 ·
      정적 P20·P21 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(onboarding_step_list_test ⓡ 8 · ⓗ 1 · onboarding_step_detail_test ⓡ 10 · ⓗ 0 — 드라이런 지적 반영판 실측).
   «없는 쪽» 견본 · «화면 Text 전부» 견본 = 아래 글자 꼴(이 카드에 다 담았다 — 앞 카드를 찾지 않는다 · 드라이런 O01-05 글자):
        final String? want = c.want;     // 경우 칸 = 기대 글자 String?(ready = ready.finishDeepLink · fresh = null)
        if (want != null) {
          await tester.tap(find.byKey(const Key('o01-finish')));
          await tester.pump();
          expect(opener.opened, <String>[want]);
        } else {
          expect(find.byKey(const Key('o01-finish')), findsNothing);
          expect(find.byKey(const ValueKey<String>('o01-row-0')), findsOneWidget);   // 양성 기준점
        }
        🔴 반려 꼴: if (want != null) { expect(…); }(else 없음) · if (x != null) { expect(x, isNotNull); … }(if 안의 전제 = 늘 참)
        «화면 Text 전부»(R13a T02-07 꼴 · allowed = stepListAllowed(c.v) / stepDetailAllowed(c.v, null) · 🔴 견본 뒤 ⓡ 는 테스트 끝 한 줄만 — 견본 안에 ⓡ 를 두지 않는다):
        final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(allowed));
        }
11 골든 = 새 PNG o01_* 4장 · o02_* 2장 · o03_* 4장 · --update-goldens 는 o01·o02·o03 골든 파일만 · 기존 PNG(48장) 재생성 0 · golden:approved 안 붙임 · 🔴 높이(844)는 늘리지 않는다.
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(5분 넘게 출력이 없으면 끊고 패키지별 flutter test) ·
   패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · close_sinks · prefer_final_locals.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 화면에는 산술이 없다).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 주석도 센다 — 두 새 lib 파일 주석에 이 낱말을 쓰지 않는다: stepId · verifiedUntil · requirement · estimated · whereDeepLink · OperatingMode · TextField · TextFormField · Clipboard · obscure · FLAG_SECURE · keystore · url_launcher ·
   DateTime.now · Duration · AppRoutes · FeatureFlags · runMode · Colors · RichText · autoDispose · Scaffold · Navigator · actionRunId · handoffRoute · skip · 해외 · 건너뛰 · 추천 · 권유 · 자문 · 시그널.
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려** · 카드 구멍 = 반려 근거 아님.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다).
   PNG 는 이름마다 light 한 장만 연다(5장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지) · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 n줄» = PNG 의 글자 **행** 수(이어진 글자 행은 한 덩어리 «글자 n줄» — «글자 1줄 → 글자 1줄» 로 쪼개지 않는다 · C4r14a-3) · «상자» = 테두리·모서리가 보이는 덩어리 · «나란한 상자 2» = 가로로 붙은 두 상자 · «버튼 글자» = 채운 버튼 하나 ·
     «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다 · 🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다).
     🆕 사전검사 G1 은 «버튼 글자» 를 «상자» 로 읽고 이어진 «글자 n줄» 덩어리를 합쳐 센다 — 표 칸은 이 카드 단위 그대로 · 드라이런 기대 🟡 = o01_ 2 · o02_ 2 · o03_ 4(그대로 · 다시 열지 않음) · 🆕 o01_ 2 = o01_fresh light·dark(재드라이런 2 — 게이트 아이콘(16) 줄이 바로 윗줄과 4px 떨어져 G1 이 두 줄을 하나로 센다 · 표 «글자 35줄» ↔ PNG «글자 34줄» · PNG 를 다시 열어도 표가 맞다 — 칸을 고치지 않는다 · 헛경보).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 제출 글은 저장 파일로) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · 출력 줄 수만큼 · 이 카드 기대 2줄) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M8.md 173~182행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지 · 🆕 상태 이름을 감싼 «» 까지 견본 글자 그대로 — C4r15a-1) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외).

■ 프롬프트보다 이 카드가 이긴다 — 17항 (prompt_M8.md 183줄 판 v2)
 ① 2행 {{범위}} = S-01 · 119행 → 이 카드의 범위 = O-01 · O-02 · O-03
 ② 113~118행 역할·범위 → 이 카드 = O-01~O-03 · O-00·O-00b = R15a(병합됨) · O-04 = R15c · R-01·V-01 = R15d · 그 밖 = R13·R14·R16
 ③ 12~13행 의존 셋 → 추가 0 · pubspec 무변경
 ④ 15~19행 링크는 데이터 → 그대로 유효(행 탭 = detailDeepLink · «다음» = finishDeepLink · null = 부재 · 외부 URL 0)
 ⑤ 20~23행 DateTime.now 금지 · UTC DateTime 표시 금지 → 그대로 유효(만료 = verifiedUntilText · verifiedUntil 포맷 0 · 신선도 판정 0 — asOf 없음)
 ⑥ 24~31행 산술·집계·거르기·재정렬 → 그대로 유효(진행률 = progressText · 목록 = 받은 차례)
 ⑦ 32~35행 한국어 리터럴 = labels.dart → 이 카드 라벨 0(«다음»·«다시 시도»·실패 = 기존 상수)
 ⑧ 36~38행 «아무 일 없음 문장 금지» → 그대로 유효(빈 문장 = emptyLabel 데이터)
 ⑨ 41~47행 안전 화면 금지 → 그대로 유효(🔒 시크릿 입력 위젯 = SecretField 소유 M4·M9 · 실키 = M5 위저드 · 이 카드 = 자리만)
 ⑩ 48~57행 모드 접두·띠 = 셸 → 그대로 유효(갈래·모드를 읽지 않는다)
 ⑪ 87~105행 «■ 제출» → 그대로 유효 · 글자·명령 = 아래
 ⑫ 106~111행 질문 파일 → inbox/O01O03_questions.md
 ⑬ 127~128행 브랜치·PR 제목 형식 → ui/m8-o01-steps · «[M8] O-01~O-03 단계 목록·상세·검증»
 ⑭ 145~150행 온보딩 조문 → 그대로 유효 — 판정·검증 = SettingsActions.run 결과 · 주입 null = 버튼 렌더 0 · SecretField 삽입만(이 카드 = 슬롯 빌더) · 건너뛰기 0 · 해외주식 0 · 금 상한·복구 카드 = R15c
 ⑮ 151~152행 실패 문구 의역 금지 → 그대로 유효(failureText + failureReasonCode · 결과 headline + reasonCode — 예 EGW00133 원문 그대로)
 ⑯ 158~164행 O-04 기대치·램프 · O-00b → 이 카드 범위 밖(R15c · R15a)
 ⑰ 172~182행 자체 점검 10항 → «■ 제출» ② 복사 상자 + 괄호(섹션 머리 «12항» 그대로)

■ 먼저 읽을 것 (🔴 02·03 명세는 읽지 않음 · 05 는 §4-1 SecretField 6원칙만 — 읽기만)
 ① prompt_M8.md 전문 ② 04 §9 머리 · §9-2(O-01 · 3등급 · 진행률 · 만료 · 해외주식 · 그림 18) · §9-3(O-02 · 6원칙) · §9-4(O-03 · 그림 19) · §9-8(게이트 3상 · 그림 23) · §2-5
 ③ 01 §2-10 OnboardingStep·StepState·StepRequirement · §2-1 GateState·GateBadge · §4-1 · §4-3 ActionResult · §25(계약 v1.16) ④ 05 §4-1(SecretField — 이 카드는 자리만)
 ⑤ packages/domain_contracts/lib/ — dto/safety.dart(OnboardingStep) · dto/onboarding.dart(v1.16 새 DTO) · dto/common.dart(GateBadge) · labels/onboarding_codes.dart(OnboardingResultCodes · BrokerRawCodes · OnboardingSlotIds — 읽기만) · enums/onboarding.dart · enums/ui.dart(GateState · UiLevel) · commands/settings_actions.dart · testing.dart
 ⑥ packages/ui_shell — lib/src/onboarding/onboarding_mode_pick.dart(🔵 R15a 쓰기 조각 꼴 · 읽기만) · lib/src/watchdog_board.dart(_checkLook 꼴) · test/onboarding_mode_pick_test.dart · test/shell_fakes.dart · golden README «🆕 R15»
 ⑦ fixtures/README.md(m8 행 · v1.16) ⑧ inbox/README.md · O01O03_questions.md 머리말

■ 본받지 않는 것
 · 코어 onboarding_fresh 의 o_00(«운영 모드 고르기» 행)·o_04 행을 기대하는 것 — 이 카드 표본(m8/onboarding_steps_*)에는 없다(R15a 순서 · O-04 몫) · watchSteps(OnboardingTrack) 를 부르는 것(화면이 갈래를 고르게 된다)
 · requirement == recommended && state != verified 로 경고 배지를 짓는 것 · gate 없이 state 로 행 잠그기 · unknown 을 notApplicable 과 같은 회색으로 · «일단 진행» 버튼 · 비율 막대(진행률 = 글자)
 · verifiedUntil 을 DateFormat·toString 으로 · estimated(Duration) 를 «n분» 으로 · failureReasonCode 만 단독으로(문장 없이)·failureText 를 요약 · 결과 headline 앞에 «실패:» 류 정적 글자
 · TextField·TextFormField·Clipboard·obscureText 로 시크릿 칸 · 붙여넣기·보기 버튼 · 시크릿 값을 State·로그에 · «한 번 더 입력» · 슬롯 빌더 null 인데 빈 상자 그리기
 · 검증 버튼을 verify 없이 그리기 · verify.args 를 고치거나 키를 더하기 · run 뒤 watch(actionRunId) 구독 · 결과를 level 로 숨기기 · retryable 없이 «다시 시도» · stepId 를 Key·글자로
 · 셸·R15a 파일 고치기 · implements 가짜 · 한국어 테스트 이름 · 조건부 단언 · lib nullable 에 !

■ 주입 구조
· 🆕 lib 파일 2개:
  lib/src/onboarding/onboarding_step_list.dart — OnboardingStepList(공개 · ConsumerWidget) · _stepsProvider · _StepRow(ConsumerWidget) · _stepLook · _gateLook
  lib/src/onboarding/onboarding_step_detail.dart — OnboardingStepDetail(공개 · ConsumerStatefulWidget · stepId) · _stepDetailProvider(family) · _VerifyResult(StatelessWidget) · _resultLook
  import 차례 = R15a 와 같다(onboarding_step_detail 만 'dart:async') · 🔴 flutter 줄 = `import 'package:flutter/material.dart' hide StepState;`(두 lib 파일 + StepState 를 쓰는 테스트 — domain_contracts `StepState` 와 flutter Stepper `StepState` 이름 충돌 · 없으면 analyze ambiguous_import 6건 · 드라이런 지적 · 골든 파일은 StepState 를 안 쓰면 붙이지 않는다).
· 🆕 주입 1 = lib/src/shell_providers.dart 끝 R15b 절:
    // ── R15b — O-01~O-03 injection providers ─────────────────────────────────
    typedef ShellSlotBuilder = Widget Function(String slotId);
    final Provider<ShellSlotBuilder?> shellOnboardingSlotBuilderProvider = Provider<ShellSlotBuilder?>((Ref ref) => throw UnimplementedError('shellOnboardingSlotBuilderProvider must be overridden'));
    (🔵 조립 앱 = slotId 별로 M4·M9 SecretField(·R15c 의 M5·M9 자리)를 낸다 · 뷰어·미주입 빌드 = overrideWithValue(null) = 자리 부재 · ✅ 발주자 확인 ⑦ 권고대로(슬롯 빌더) · 🔵 typedef 는 줄머리 «final» 이 아니라 정적 P15 셈 밖)
· 데이터 2 = final StreamProvider<OnboardingStepsVm> _stepsProvider = StreamProvider<OnboardingStepsVm>((Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchStepList()); ·
           final _stepDetailProvider = StreamProvider.family<OnboardingStepDetailVm, String>((Ref ref, String stepId) => ref.watch(shellOnboardingRepositoryProvider).watchStep(stepId));(타입 = StreamProviderFamily<OnboardingStepDetailVm, String> · R14a _alertDetailProvider 꼴)
· 🆕 배럴 두 줄(export 'src/onboarding/onboarding_start.dart'; 뒤 · 정렬 차례).

■ 호출 표
 OnboardingStepList — 부르는 것: watchStepList() 한 번(재시도 = 한 번 더) · shellLinkOpenerProvider(행 탭 · «다음» 콜백 안). 부르지 않는 것: watchSteps · watchStep · SettingsActions · 슬롯 빌더.
 OnboardingStepDetail — 부르는 것: watchStep(widget.stepId) 한 번(재시도 = 한 번 더) · run(verify.id, args: verify.args)(버튼마다 한 번 · «다시 시도» 도 같은 동작 한 번 · 기다리는 동안 0) · 슬롯 빌더(secretSlotId 를 그대로 · build 에서).
   부르지 않는 것: SettingsActions.watch · watchStepList · 다른 SettingsActionId · shellLinkOpenerProvider(이 화면 링크 0).

■ 상태 표 (구독마다)
 steps   hasError → ShellErrorView(key: const Key('o01-fail'), onRetry: () => ref.invalidate(_stepsProvider)) · 값 전 → ShellSkeleton(key: const Key('o01-loading')) · 값 → «화면 1»
 detail  hasError → ShellErrorView(key: const Key('o02-fail'), onRetry: () => ref.invalidate(_stepDetailProvider(widget.stepId))) · 값 전 → ShellSkeleton(key: const Key('o02-loading')) · 값 → «화면 2»(모르는 id = missingLabel 한 줄 — 에러 화면 아님)

■ 화면 1 — O-01 (위 → 아래)
 진행    Padding(key: const Key('o01-progress'), EdgeInsets.fromLTRB(16, 16, 16, 8), Text(vm.progressText))                               · 늘
 행      for (final (int i, OnboardingStep s) in vm.rows.indexed) _StepRow(index: i, step: s)                                       · 받은 차례
         _StepRow = InkWell(key: ValueKey<String>('o01-row-$index'), onTap: link == null ? null : () { ref.read(shellLinkOpenerProvider).open(link); }, Padding(EdgeInsets.symmetric(horizontal: 16, vertical: 12), Row(crossAxisAlignment: start)[
           Icon(look.$1, color: look.$2, size: 20) · SizedBox(width: 8) · Expanded(Column(crossAxisAlignment: start)[ Text(step.title) · Text(step.whyLine) · Text(step.estimatedText) · Text(step.requirementLabel) ·
           (warn) Text(warn) · (vlabel) Text(vlabel) · (until) Text(until) · (fail) Text(fail) · (code) Text(code) · (gate) _GateMark(gate) ]) ]))
         ← final String? link = step.detailDeepLink; final String? warn = step.warningLabel; final String? vlabel = step.verificationLabel; final String? until = step.verifiedUntilText; final String? fail = step.failureText; final String? code = step.failureReasonCode; final GateBadge? gate = step.gate;
         _GateMark = Row(key: ValueKey<String>('o01-gate-$index'))[ Icon(g.$1, color: g.$2, size: 16) · SizedBox(width: 4) · Flexible(Text(gate.label)) ] ← final (IconData, Color) g = _gateLook(cs, gate.state);
 빈      (empty != null) Padding(key: const Key('o01-empty'), EdgeInsets.all(16), Text(empty))
 다음    (finish != null) Padding(EdgeInsets.fromLTRB(16, 16, 16, 16), FilledButton(key: const Key('o01-finish'), onPressed: () { ref.read(shellLinkOpenerProvider).open(finish); }, child: const Text(ShellLabels.onboardingNext)))
 _stepLook(cs, StepState s) = switch(s) { notStarted → (Icons.radio_button_unchecked, cs.onSurfaceVariant) · inProgress → (Icons.timelapse, cs.tertiary) · verified → (Icons.check_circle_outline, cs.primary) · failed → (Icons.error_outline, cs.error) · expired → (Icons.update, cs.secondary) }
 _gateLook(cs, GateState g) = switch(g) { pass → (Icons.lock_open, cs.primary) · block → (Icons.lock_outline, cs.error) · notApplicable → (Icons.remove_circle_outline, cs.onSurfaceVariant) · unknown → (Icons.help_outline, cs.error) }(🔴 unknown ≠ notApplicable · unknown = 차단 색)

■ 화면 2 — O-02 · O-03 (위 → 아래 · 모르는 id 면 머리 아래 missingLabel 한 줄뿐)
 모름    (missing != null) Padding(key: const Key('o02-missing'), EdgeInsets.all(16), Text(missing))  ← final String? missing = vm.missingLabel;
 머리    (s != null) Padding(key: const Key('o02-head'), EdgeInsets.fromLTRB(16, 16, 16, 8), Column(start)[ Text(s.title) · Text(s.whyLine) · Text(s.estimatedText) · (until) Text(until) ])  ← final OnboardingStep? s = vm.step;
 어디서  (where != null) Padding(key: const Key('o02-where'), …, Text(where)) · 어떻게 (how != null) Padding(key: const Key('o02-how'), …, Text(how))
 시크릿  (slotId != null && builder != null) Padding(key: const Key('o02-secret'), EdgeInsets.fromLTRB(16, 8, 16, 8), builder(slotId))  ← final ShellSlotBuilder? builder = ref.watch(shellOnboardingSlotBuilderProvider); final String? slotId = vm.secretSlotId;
 검증    (verify != null && actions != null) Padding(EdgeInsets.fromLTRB(16, 8, 16, 0), FilledButton(key: const Key('o03-run'), onPressed: _busy ? null : () { unawaited(_run(actions, verify)); }, child: Text(verify.label)))
 결과    (_failed) Padding(key: const Key('o03-not-accepted'), …, Text(ShellLabels.onboardingNotAccepted)) · (r != null) _VerifyResult(result: r, onRetry: (r.retryable && verify != null && actions != null && !_busy) ? () { unawaited(_run(actions, verify)); } : null)
         _VerifyResult = Padding(key: const Key('o03-result'), …, Column(start)[ Row[ Icon(look.$1, color: look.$2, key: const Key('o03-level')) · Expanded(Text(result.headline)) ] · (code) Text(code) · (onRetry != null) TextButton(key: const Key('o03-retry'), onPressed: onRetry, child: const Text(ShellLabels.retry)) ])
         _resultLook(cs, UiLevel l) = H-01 `_cellLook` 글자 그대로(ok · info · watch · act · blocked)
 _run(SettingsActions a, OnboardingAction v) = R15a _pick 꼴(세 칸 같이 · run(v.id, args: v.args) · 실패 = _failed true · _result null)
 🔴 단계 실패 문장(failureText)·원문 코드는 O-01 행 몫 · O-02 는 머리에 만료만 · 결과 = 이번 run 의 ActionResult 하나

■ 픽스처 (FixturePaths.… · singleFixture — VM 1행 봉투 · 결과 = listFixture · 🔴 전제 expect 로 다시 확인)
 fresh        m8OnboardingStepsFresh — rows 12(F1~F12 = 설계서 §5-2 · StepState 5값 전부 · 권장 미통과 행 warningLabel non-null 2 · 만료 행 verifiedUntilText non-null 2(«2026-11-30까지» · «2026-08-30에 만료됨») · 실패 행 failureText·failureReasonCode non-null 2(PERMISSION_DENIED · TOKEN_EXPIRED) · gate 4값 표본 각 1행(PASS [1] · BLOCK [2] · UNKNOWN [5] · NOT_APPLICABLE [10]) · detailDeepLink null 1행([11])) · progressText «1/12 완료» · finishDeepLink null · emptyLabel null · o_00·o_04·해외주식 행 0
 advisory     m8OnboardingStepsAdvisory — 투자 안내 갈래 rows 10(대사 전용 키·Android 권한 = 권장 등 — 04 §9-2 참고표 · gate 0) · finishDeepLink null
 ready        m8OnboardingStepsFinishReady — rows 3 전부 verified · finishDeepLink `aaq://onboarding/finish`
 🆕 readyWarn   m8OnboardingStepsFinishReadyWarn — rows 4 · 권장 미통과 행(NOT_STARTED · warningLabel) 하나([3]) + finishDeepLink non-null(필수 통과 = 엔진이 마무리를 연다 · 드라이런 J6a)
 🆕 locked      m8OnboardingStepsAllVerifiedLocked — rows 3 전부 verified · finishDeepLink null · 게이트 unknown 행 하나([0] 기기 원장 · 엔진이 막는다 · 드라이런 J6c)
 🆕 empty       m8OnboardingStepsEmpty — rows 0 · emptyLabel non-null · finishDeepLink null(드라이런 L6)
 kisMock      m8OnboardingStepDetailKisMock — step non-null(F2 o_02 IN_PROGRESS · verifiedUntilText null) · whereText·howText non-null · verify non-null(label «검증 실행» · id credentialVerify · args {kind: KIS_MOCK}) · secretSlotId `SECRET_KIS_MOCK`
 noVerify     m8OnboardingStepDetailNoVerify — step non-null(F5 o_06 NOT_STARTED · verifiedUntilText null) · whereText·howText non-null · verify null · secretSlotId null
 missingV     m8OnboardingStepDetailMissing — step null · missingLabel non-null
 results      listFixture(m8OnboardingVerifyResults, ActionResult.fromJson).rows — [0] 성공(level ok · reasonCode null · retryable false) · [1] 실패(level blocked · reasonCode `EGW00133`(BrokerRawCodes.kisTokenRateLimited — 사전 등재 원문 코드 · C-5) · retryable true) · [2] 실패(level blocked · reasonCode `CREDENTIAL_REJECTED`(OnboardingResultCodes) · retryable false)

■ Key 표 (o01- 7이름 · o02- 7이름 · o03- 5이름 — 정본 · 표 밖 Key 0 · 순번만 · 🔴 stepId 0)
   o01-loading · o01-fail · o01-progress · o01-row-$i · o01-gate-$i · o01-empty · o01-finish · (o01 행 안 글자는 Key 0) ·
   o02-loading · o02-fail · o02-missing · o02-head · o02-where · o02-how · o02-secret · o03-run · o03-not-accepted · o03-result · o03-level · o03-retry

■ 할 일 — R15a 와 같은 꼴(커밋마다 git add <파일> + git show --stat HEAD · amend 0)
 (1) lib 두 파일 + shell_providers R15b 절 + 배럴 두 줄. 커밋 «[M8] R15b (1) O-01~O-03 화면»
 (2) test/shell_fakes.dart 끝 절 + 두 테스트 파일 · git add 뒤 정적 미리. 커밋 «[M8] R15b (2) O-01~O-03 테스트»
 (3) 골든 10장(o01 2이름 · o02 1이름 · o03 2이름). 커밋 «[M8] R15b (3) 골든 o01_* 4장 · o02_* 2장 · o03_* 4장»
 (4) format:fix · analyze · 질문 파일(A1~A5 dy). 커밋 «[M8] R15b (4) format · 질문» · (4) 뒤 = (5) 하나만.

■ 정적 라벨 — 0개(🔴 labels.dart 무변경 · 총수 = 정적 P13 이 센다 = R15a 병합본 37)

■ 테스트 최소 목록 (ⓡ·ⓗ = P20·P21 · (전제) = P34)
공통: 띄우기 = pumpStepList(tester, overrides:) · pumpStepDetail(tester, overrides:, stepId:)(R15a pump 꼴) · overrides = stepOverrides(repo:, actions:, slots:, opener:)(4줄 · slots = ShellSlotBuilder?) · 경우 for = testWidgets 밖 · 흐름 = 클로저 칸 ·
  계획 = step_list_test 줄 9(테스트 16) · step_detail_test 줄 13(테스트 23) · 골든 3 · 합 25(드라이런 지적 반영판 실측).
  🆕 테스트 파일 머리 도우미(main() 밖 · 드라이런 글자): valueThenFail(R15a 꼴) · listRepo(steps) / detailRepo(detail)(안 쓰는 쪽 공장 = Stream.error(StateError('unused'))) · wantStep(cs, StepState) · wantGate(cs, GateState) · wantResult(cs, UiLevel)(= «화면 1·2» 의 _stepLook · _gateLook · _resultLook 글자 사본) ·
    firstIconIn(tester, key) => tester.widget<Icon>(find.descendant(of: find.byKey(key), matching: find.byType(Icon)).first) · main() 머리 final: fresh · advisory · ready · readyWarn · locked · empty · kisMock · noVerify · missingV · results · askedId = kisMock.step!.stepId · linkedAt · unlinkedAt.
  🆕 test/shell_fakes.dart 끝 절(«// ── R15b — O-01~O-03 fakes ──»): FakeShellStepRepository extends UnimplementedOnboardingRepository(steps · detail 공장 · stepIds 기록 · listCalls) · FakeShellSlotRecorder(slotIds 기록 · build(slotId) → SizedBox(key: ValueKey<String>('fake-slot-$slotId'), height: 48)) ·
    stepOverrides(…) · pumpStepList · pumpStepDetail · stepRowTexts(OnboardingStep s) => <String>[s.title, s.whyLine, s.estimatedText, s.requirementLabel, ?s.warningLabel, ?s.verificationLabel, ?s.verifiedUntilText, ?s.failureText, ?s.failureReasonCode, ?s.gate?.label] ·
    stepListAllowed(OnboardingStepsVm v) · stepDetailAllowed(OnboardingStepDetailVm v, ActionResult? r)(+ ShellLabels.onboardingNext · onboardingNotAccepted · retry 중 그 화면에 나올 수 있는 것 · 🔴 stepId·링크·code(GateBadge) 0) · FakeShellOnboardingActions = R15a 가짜 재사용(고치지 않는다).
O-01 — test/onboarding_step_list_test.dart
 O01-01 진행률·행 글자·받은 차례(04 §9-2) — fresh: 전제 둘: expect(fresh.finishDeepLink, isNull); // pre · expect(fresh.emptyLabel, isNull); // pre → repo.listCalls == 1 · shownTexts(o01-progress) == [fresh.progressText] ·
        ⓗ expect(fresh.rows, hasLength(12)) → i 마다 shownTexts(o01-row-$i) == stepRowTexts(fresh.rows[i]) · 사슬 dy o01-progress → o01-row-0 → … · o01-finish findsNothing · o01-empty findsNothing · ⓡ.
 O01-02 상태 아이콘 = StepState 5값 전수 — fresh: 전제 하나: expect(fresh.rows.map((OnboardingStep r) => r.state).toSet(), StepState.values.toSet()); // pre → i 마다 tester.widget<Icon>(descendant of o01-row-$i, first Icon) icon·color == wantStep(row.state)(테스트 파일 private switch · 기대 원천 = «화면 1» _stepLook) · ⓡ.
 O01-03 게이트 3상 — fresh: 전제 하나: expect(fresh.rows.where((OnboardingStep r) => r.gate?.state == GateState.unknown), isNotEmpty); // pre → gate non-null 인 행 i 마다 o01-gate-$i 의 Icon icon·color == wantGate(state) · 🔴 unknown 행과 notApplicable 행의 아이콘이 다르다 한 줄 · gate null 행 = o01-gate-$i findsNothing · ⓡ.
 O01-04 행 탭 = detailDeepLink — 두 경우 ㉠ (linked · k = linkedAt · [fresh.rows[linkedAt].detailDeepLink!]) · (unlinked · k = unlinkedAt · [])마다(main() 머리 final int linkedAt = fresh.rows.indexWhere((OnboardingStep r) => r.detailDeepLink != null); · unlinkedAt = 같은 꼴 == null) — 전제 둘: expect(linkedAt, greaterThanOrEqualTo(0)); // pre · expect(unlinkedAt, greaterThanOrEqualTo(0)); // pre → tap(o01-row-$k) → expect(opener.opened, c.want) · ⓡ.
 O01-05 «다음» = finishDeepLink(데이터 · 판정 0) — 네 경우 ㉠ (ready · want ready.finishDeepLink) · (fresh · null) · 🆕 (locked · null) · (ready_warn · want readyWarn.finishDeepLink)마다(경우 칸 want = String?) — 전제 여섯: expect(ready.finishDeepLink, isNotNull); // pre · expect(fresh.finishDeepLink, isNull); // pre · expect(locked.finishDeepLink, isNull); // pre ·
        expect(locked.rows.every((OnboardingStep r) => r.state == StepState.verified), isTrue); // pre · expect(readyWarn.finishDeepLink, isNotNull); // pre · expect(readyWarn.rows.any((OnboardingStep r) => r.state != StepState.verified), isTrue); // pre →
        final String? want = c.want; if (want != null) { tap(o01-finish) → pump → expect(opener.opened, <String>[want]); } else { o01-finish findsNothing · 양성 기준점 o01-row-0 findsOneWidget } · ⓡ(🔴 locked = «전부 verified 면 다음» 류 · ready_warn = «finishDeepLink 대신 전부 verified» — 드라이런 J6a·J6c).
 O01-06 상태 갈래 — 세 경우(loading · fail · value_then_fail)마다 Key 목록 · CircularProgressIndicator findsNothing.
 O01-07 재시도 — call 0 error → retry → value → o01-fail findsNothing · o01-progress findsOneWidget · repo.listCalls == 2 · ⓡ.
 O01-08 화면 Text 전부 · 큰 글꼴(해외주식·o_00 글자 0 = allowed 밖) — 두 경우(fresh · advisory) → allowed = stepListAllowed(c.v) → textScaleFactorTestValue 2.0 → expect(tester.takeException(), isNull) · ⓡ.
 🆕 O01-09 빈 문장 = emptyLabel 데이터 — empty: 전제 둘: expect(empty.rows, isEmpty); // pre · expect(empty.emptyLabel, isNotNull); // pre → shownTexts(o01-empty) == [empty.emptyLabel] · o01-row-0 findsNothing · o01-progress findsOneWidget · ⓡ(드라이런 L6).
 ⓡ 기대 = 8줄(O01-01 · 02 · 03 · 04 · 05 · 07 · 08 · 09) · ⓗ = 1(O01-01) · (전제) = 14(01 2 · 02 1 · 03 1 · 04 2 · 05 6 · 09 2 — 드라이런 지적 반영판 실측 · 🔴 정확히).
O-02 · O-03 — test/onboarding_step_detail_test.dart(주입 = 따로 적지 않으면 operator · 슬롯 = FakeShellSlotRecorder)
 O02-01 상세 글자·차례 — kisMock: 전제 셋(step · whereText · howText non-null // pre) → repo.stepIds == <String>[askedId](main() 머리 final String askedId = kisMock.step!.stepId; — 위젯 인자로 그대로 넘긴다) · 사슬 dy o02-head → o02-where → o02-how → o02-secret → o03-run · 글자 = shownTexts · ⓡ.
 O02-02 모르는 id = missingLabel 값(에러 아님) — missingV: 전제 둘 → o02-missing 글자 == [missingLabel] · o02-head · o03-run · o02-fail findsNothing · ⓡ.
 O02-03 시크릿 자리 = 슬롯 빌더(SecretField 삽입만) — 세 경우 ㉠ (slot · kisMock · 빌더 있음 · fake-slot-<id> findsOneWidget · slots.slotIds == [kisMock.secretSlotId!]) · (no_builder · kisMock · 빌더 null · o02-secret findsNothing) · (no_slot · noVerify · 빌더 있음 · o02-secret findsNothing · slotIds == [])마다 ·
        🔴 find.byType(TextField) findsNothing 한 줄(세 경우 모두) · ⓡ.
 O02-04 상태 갈래 — 세 경우(loading · fail · value_then_fail) · O02-05 재시도(구독 · stepIds 두 번 같은 인자) · ⓡ.
 🆕 O02-06 머리 만료 글자 = 데이터(없는 쪽) — noVerify: 전제 둘: expect(noVerify.step, isNotNull); // pre · expect(noVerify.step!.verifiedUntilText, isNull); // pre → shownTexts(o02-head) == <String?>[s.title, s.whyLine, s.estimatedText](만료 줄 0 — 폴백 글자·verifiedUntil 포맷을 잡는다) · ⓡ(🔵 v1.16 상세 표본 셋에 만료 글자가 있는 단계가 없다 — kisMock = F2 · noVerify = F5 · 설계서 §5-2 → 드라이런 T1b «머리 만료 빼기» 는 이 카드에서 🔵 참고(표본 부재) · 만료 있는 상세 표본이 M2 에 더해지면 있는 쪽 경우를 더한다).
 O03-01 검증 버튼 = run(verify.id, verify.args) 1회 — kisMock → tap(o03-run) → pump → expect(actions.ids, [kisMock.verify!.id]) · expect(actions.argsSeen, [kisMock.verify!.args]) · ⓡ.
 O03-02 결과 3상 · 원문 코드 — 세 경우 ㉠ (ok · results[0]) · (fail_retry · results[1]) · (fail_final · results[2])마다 — 전제 셋(reasonCode·retryable 표본 // pre) → tap(o03-run) → pump 두 번 → expect(shownTexts(o03-result), <String?>[c.r.headline, ?c.r.reasonCode, ...c.tail])(🆕 경우 칸 tail = 기대 꼬리 글자 목록 — ok·fail_final <String>[] · fail_retry <String>[ShellLabels.retry] · 드라이런 글자) · expect(find.byKey(const Key('o03-retry')), c.r.retryable ? findsOneWidget : findsNothing) · o03-level Icon == wantResult(r.level) · o03-not-accepted findsNothing(🔵 fail_retry 경우는 ⓡ 대신 o03-retry 단언 — retry 글자가 보인다).
 O03-03 «다시 시도» = retryable 데이터 — 두 경우 ㉠ (retryable · results[1] · o03-retry findsOneWidget → tap → actions.ids 두 번) · (final · results[2] · o03-retry findsNothing · actions.ids 한 번)마다.
 O03-04 실패 ↔ 성공 두 방향(C4r14a-5) — R15a O0B-06 꼴(o03-not-accepted ↔ o03-result · 🆕 성공 = results[0](retryable false — «다시 시도» 0 이라 ⓡ 가 선다) · 실패 = Future<ActionResult>.error(StateError('fail'))) · ⓡ.
 O03-05 주입 null(뷰어) = 검증 버튼 부재 · operator 대조(C4r14a-6) — 두 경우(viewer · operator) → o03-run viewer findsNothing / operator findsOneWidget(want ? findsOneWidget : findsNothing 한 꼴) · ⓡ.
 O03-06 화면 Text 전부 · 큰 글꼴 — 두 경우(kisMock · noVerify) → allowed = stepDetailAllowed(c.v, null) → textScaleFactorTestValue 2.0 → takeException isNull · ⓡ.
 🆕 O03-07 기다리는 동안 두 번 누름 0 — 공장 = (int call) => Completer<ActionResult>().future(끝나지 않음) · kisMock → tap(o03-run) → pump → tap(o03-run) → pump → expect(actions.ids, <SettingsActionId>[?kisMock.verify?.id]) · CircularProgressIndicator findsNothing · ⓡ(드라이런 V5).
 ⓡ 기대 = 10줄(O02-01 · 02 · 03 · 05 · 06 · O03-01 · 04 · 05 · 06 · 07) · ⓗ = 0 · (전제) = 10(O02-01 3 · O02-02 2 · O02-06 2 · O03-02 3) — 드라이런 지적 반영판 실측 · 🔴 정확히.

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(갈래마다 짝):
   (목록) 행 뒤집기 · 행 하나 빼기 · verified 행 거르기 · 해외주식 행 더하기(정적 글자) · progressText 대신 rows 수로 «n/m»(정적·O01-01) · emptyLabel 빼기(O01-09).
   (판정) warningLabel 대신 requirement·state 로 배지(표본상 동치면 🔵 참고 — 정적 P11 이 requirement 를 잡는다) · gate unknown 을 notApplicable 모양으로 · gate unknown 을 pass 모양으로 · state 아이콘 하나로 고정 · failed 를 verified 색으로 · finishDeepLink 대신 «전부 verified 면 다음»(O01-05 ready_warn) · 🆕 fallback 링크(finishDeepLink 없고 전부 verified 면 첫 행 링크 — O01-05 locked).
   (글자) verifiedUntilText 빼기(O-01 행 — O01-01 · 🔵 O-02 머리 = 참고 · v1.16 상세 표본에 만료 글자 0 — O02-06 은 없는 쪽만) · verifiedUntil 포맷(정적 P11) · failureText 빼기 · failureReasonCode 빼기 · failureText 대신 정적 글자 · gate.label 빼기 · whereText·howText 빼기.
   (시크릿) 슬롯 빌더 대신 TextField(O02-03 · 정적 P36) · 빌더 null 인데 빈 상자 · slotId 대신 고정 글자 · 시크릿 자리를 검증 버튼 아래로.
   (검증) run 0 · run 두 번 · verify.args 에 키 더하기 · 다른 id · 기다리는 동안 두 번(O03-07) · 결과 headline 빼기 · reasonCode 빼기 · level 아이콘 고정 · retryable 무시(늘 «다시 시도» · 늘 없음) · 실패 글자 빼기 · 한 칸 초기화 빼기(두 방향) · 주입 null 에도 버튼.
   (링크) 행 탭 0 · detailDeepLink null 에도 탭 · «다음» 탭 0.
   (상태 — 갈래마다 · 두 화면) 에러를 스켈레톤 · 재시도 invalidate 0 · 모르는 id 를 에러 화면으로 · 정적 글자 더하기.
   🔵 참고 — 타입이 막음: «verify 없이 화면이 SettingsActionId 고르기»(검증 id 는 VM 칸 — 화면이 고르면 정적 P07 «SettingsActionId.» 0 이 잡는다) · 드라이런 변이 표 = 첫 판 62꼴(예고 51 · 참고 9 · 사전검사 2) — 예고 KILLED 47 · SURVIVED 4(L6 · J6a · T1b · V5) · 정적이 잡음 1(J1a = P11) → 반영판 `dry/r15-2b` 에서 4꼴 + 🆕 J6c KILLED · 참고 KILLED 8 · 정적 2(RF7 = P04 · RF9 = P06) · 무효 1(RF5b = 이름 충돌 컴파일 실패 — 🆕 재드라이런 2 = detail lib 의 `hide StepState` 로 컴파일되어 테스트 통과 · 정적 P11 «.state !=» · P09 한 줄 더로 잡힌다(표본에 verified 상세 0)) · 사전검사 RF1(늘 참) = T3 🔴 · RF2(else 없는 if) = T1 🔴 · 🔵 v1.16 실물 위에서 T1b 는 다시 참고(O02-06 — 표본 부재) · 🆕 재드라이런 2(v1.16 실물 · `dry/r15v2-2`) = 예고 52꼴 KILLED 50 · SURVIVED 2(J1a = 정적 P11·P09 · T1b = 🔵 참고) · 참고 13꼴 KILLED 10(🆕 RF11 권장 배지를 화면이 짓기 · RF12 state 순 정렬 · RF14 block 게이트 숨김 · RF15 실패 행 원문 코드 숨김) + 정적 3(RF5b = P11·P09 · RF7 = P04 · RF9 = P06) · 테스트 쪽 RF1 = T3 🔴 · RF2 = T1 🔴 · RF1b(늘 참 find.byType + findsWidgets) · RF13(nullable 흐름 칸 + if) = 사전검사 🔴 0 → «5» C4 사람 grep(테스트 쪽 변이 판정 = 임시 커밋 위).

■ 정적 묶음 — 아래 34줄(머리 «## P01» ~ «## P36» · P12·P28 비움 — 드라이런 실측)을 파일로 꺼내 Git Bash 로 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다(대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 머리 ASCII · «EXIT:1» = 출력 없음 · 출력 줄 수(EXIT 줄 포함) = 162줄(드라이런 — 기록 커밋이 base 에 있을 때) — 붙이기 전에 세어 같은지 본다)
  🔴 터미널에 붙여 넣어 돌리지 않는다(대화형 bash 는 ! 든 줄을 건너뛸 수 있다 · bash 라고만 치면 이 PC 에서는 WSL)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 손으로 옮겨 쓰지 않는다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R15b-Bob-O01O03.md' | sed -n '344,377p' > ../../build/r15b_static.sh"
  git hash-object ../../build/r15b_static.sh   ← 892921963a3c9f3bb2cffc92674cab6e6d3770d3(= 아래 34줄 · 재드라이런 2 · ✅ send/ 승격(펼침) 뒤 꺼내기 범위 다시 잼 2026-11-04 · 해시 그대로 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r15b_static.sh > ../../build/r15b_static_out.txt"
  Select-String -Path ..\..\build\r15b_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음이어야 한다(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r15b_static_out.txt).Count   ← 162(드라이런 · EXIT 줄 34 포함) · (Select-String -Path ..\..\build\r15b_static_out.txt -Pattern '^EXIT:1$').Count ← 19 · -Pattern '^EXIT:0$' ← 15
  ② 에 붙일 출력 = Get-Content -Encoding UTF8 ..\..\build\r15b_static_out.txt 전부(build/ 는 .gitignore 대상 — git status 는 빈 채 · 커밋 0 · 할 일의 «미리 돌리기» 도 이 꼴)
echo "## P01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://|'https?://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P06 source lines (2)"; git grep -nE "watchStepList\(|watchStep\(" -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P07 action ids in step files 0"; git grep -nE "SettingsActionId\." -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P08 run calls (1)"; git grep -nE "\.run\(" -- lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P09 StepState GateState UiLevel arms (5 4 5)"; git grep -nE "StepState\.(notStarted|inProgress|verified|failed|expired)|GateState\.(pass|block|notApplicable|unknown)|UiLevel\.(ok|info|watch|act|blocked)" -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P10 slot builder lines"; git grep -n "shellOnboardingSlotBuilderProvider" -- lib/src/onboarding; echo "EXIT:$?"
echo "## P11 forbidden words in step files 0"; git grep -nE "stepId\b.*(Key|Text)|verifiedUntil\b|\.requirement\b|\.estimated\b|whereDeepLink|\.track\b|watchSteps\(|OperatingMode|FeatureFlags|runMode|DateTime\.now|DateFormat|Duration\(|toString\(|\.where\(|\.length|\.sort|\.take\(|split\(|RegExp|actionRunId|handoffRoute|AppRoutes|AppLinkSchemes|kIsWeb|Platform\.|dart:io|showDialog|SnackBar|print\(|[Ss]kip|\.every\(|\.any\(|\.state\s*(==|!=)|(==|!=)\s*StepState\." -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P13 shell labels (37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## P14 barrel exports"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## P15 shell providers"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## P16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## P17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## P18 figures 0"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## P19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## P20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart; echo "EXIT:$?"
echo "## P21 H lines (hasLength)"; git grep -c "hasLength(" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart; echo "EXIT:$?"
echo "## P22 o01 o02 o03 key names"; git grep -noP "o0[123]-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P23 banned vocabulary in code 0"; git grep -nE "추천|권유|자문|시그널|대부분|건너뛰|해외" -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
echo "## P24 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## P25 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox|LinearProgressIndicator" -- lib; echo "EXIT:$?"
echo "## P26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## P27 Scaffold AppBar Navigator in onboarding 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/onboarding; echo "EXIT:$?"
echo "## P29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/src/shell_providers.dart lib/l10n/labels.dart lib/src/onboarding/onboarding_start.dart lib/src/onboarding/onboarding_mode_pick.dart lib/src/shell_scaffold.dart lib/src/routing lib/src/common lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/watchdog_board_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart test/golden/w01_golden_test.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## P30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P31 copyWith in tests 0"; git grep -n "copyWith(" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## P34 precondition marks (pre)"; git grep -c "// pre$" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart; echo "EXIT:$?"
echo "## P35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart; echo "EXIT:$?"
echo "## P36 secret input widgets in onboarding 0"; git grep -niE "textfield|textformfield|editabletext|obscure|clipboard|keystore|flag_secure|url_launcher|launchUrl" -- lib/src/onboarding; echo "EXIT:$?"
  (줄의 뜻과 기대 — 드라이런 지적 반영판 · 출력 줄 수 = 162줄(EXIT:1 19 · EXIT:0 15 — 재드라이런 2 실측 · v1.16 실물 위 · 드라이런 반영판·첫 판도 162 · 승격(펼침)으로 바뀌지 않는다) · P01·P02 = 출력 없음 · P03 = 5줄(o01_golden 1 · o02_golden 1 · o03_golden 1 · step_detail_test 13 · step_list_test 9) · P04 = 0 · S05 = 2줄(행 탭 · «다음») · P06 = 2줄 · P07 = 0(🔴 검증 id = VM 칸) · P08 = 1줄 ·
   P09 = 14줄(_stepLook 5 · _gateLook 4 · _resultLook 5) · P10 = 1줄(onboarding_step_detail.dart build) · P11 = 0(🆕 `.every(`·`.any(`·state 비교 — «전부 verified 면 다음» 류를 정적으로도 · 드라이런 J6a) · P13 = «lib/l10n/labels.dart:37»(R15a 병합본 · 이 카드 0 · 기대 — «정확히» = 마지막 카드) ·
   P14 = 13줄(… src/onboarding/onboarding_mode_pick.dart · onboarding_start.dart · 🆕 onboarding_step_detail.dart · onboarding_step_list.dart · …) · P15 = 18줄(R15a 17 + 슬롯 빌더 1) · P16~P19 = 0 · P20 = «test/onboarding_step_detail_test.dart:10» · «test/onboarding_step_list_test.dart:8» · P21 = «test/onboarding_step_list_test.dart:1»(🔴 정확히) · P22 = 이름 19(o01 7 · o02 7 · o03 5 = 위 «Key 표») ·
   P23~P27 = 0 · P29 = 세 줄(lib/src/shell_providers.dart · lib/ui_shell.dart · test/shell_fakes.dart — 둘째 수 0 · 🆕 목록 = R15a O29 목록 + R15a 파일 — 감사 지적) · P30~P32 = 0 · P33 = 10줄 전부 «A» · P34 = «test/onboarding_step_detail_test.dart:10» · «test/onboarding_step_list_test.dart:14»(🔴 정확히) · P35 = 0 · P36 = 0)
  (🔵 P12·P28 은 이 카드에 없다(번호 비움 — R15a 의 «선택 비교»·«포커스» 줄 몫 없음 · 판정 줄 머리 번호는 매기지 않고 그대로 둔다 — 머리 글자가 바뀌면 해시·드라이런 기대가 바뀐다) · ✅ send/ 승격(2026-11-04) = 꺼내기 줄 범위 344~377 실측 · «아래 34줄» 그대로 · 🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · P11 · P23 · P36 은 주석 줄도 센다(규칙 15))

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · golden README «🆕 R15» 절 표 그대로)
  o01 — test/golden/o01_golden_test.dart · 크기 = kGoldenPhoneSize(390 × 844 · light = dark) · 저장소 = FakeShellStepRepository(steps: (int call) => one(flow.fixture), detail: (int call) => Stream<OnboardingStepDetailVm>.error(StateError('unused')))(🔴 testWidgets 안에서 새로 · _Flow 칸에 인스턴스 0) · 명령 = UnimplementedSettingsActions() · 슬롯 = null · 위젯 = OnboardingStepList() · 이름 o01_fresh(fresh · 맨 아래 Key = ValueKey<String>('o01-row-3') — 🆕 재드라이런 2(v1.16 실물 12행 표본): row-4 의 아래 끝이 844.0 에 딱 닿아 위치 전제(< 844)가 실패한다 · row-5 부터는 ListView 가 만들지 않는다 · row-3 = 드라이런 기대 700.0) · o01_advisory(advisory · 맨 아래 Key = ValueKey<String>('o01-row-4') — v1.16 advisory 10행 · row-4 = 드라이런 기대 744.0 · row-5 는 848 에서 끝나 화면 밖) · 머리 Key('o01-progress') dy 0.0 · 🔴 높이는 늘리지 않는다 · 두 이름 배치·잘림 칸 = «— 잘림 없음»(재드라이런 2)
  o02 — test/golden/o02_golden_test.dart · 위젯 = OnboardingStepDetail(stepId: kisMock.step!.stepId) · 이름 o02_step(kisMock · 슬롯 = FakeShellSlotRecorder · 맨 아래 Key('o03-run') — 드라이런 기대 356.0) · 머리 Key('o02-head') dy 0.0
  o03 — test/golden/o03_golden_test.dart · 위젯 = 같은 상세 · 흐름 = tap(o03-run) → pump 두 번(🔴 명령 칸 = 공장 SettingsActions Function() 을 testWidgets 안에서 부른다 — 가짜 공유 금지 · C4r5d-5) ·
    이름 o03_ok(results[0] · 맨 아래 Key('o03-result') — 드라이런 기대 404.0) · o03_fail_code(results[1] · 맨 아래 Key('o03-retry') — 드라이런 기대 472.0) · 머리 Key('o02-head') dy 0.0 · 여백 조정 0 · light = dark
  표(이름 · 입력 · 흐름 · 맨 아래 Key · 머리 Key — 드라이런 글자):
    이름              입력       흐름                         맨 아래 Key                       머리 Key
    o01_fresh         fresh      없음                         ValueKey<String>('o01-row-3')     Key('o01-progress')
    o01_advisory      advisory   없음                         ValueKey<String>('o01-row-4')     Key('o01-progress')
    o02_step          kisMock    없음                         Key('o03-run')                    Key('o02-head')
    o03_ok            kisMock    tap(o03-run) → pump 두 번    Key('o03-result')                 Key('o02-head')
    o03_fail_code     kisMock    tap(o03-run) → pump 두 번    Key('o03-retry')                  Key('o02-head')
  모양 = w01_golden_test.dart · o00_golden_test.dart 와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록(private class _Flow · 흐름 칸 = Future<void> Function(WidgetTester t) — non-null · o03 = 입력 칸 대신 명령 공장 칸 SettingsActions Function()) × Brightness.values · 흐름 = 흐름 없는 이름은 (WidgetTester t) async {}(C4r14a-4 — `_` 매개변수 꼴도 같은 뜻으로 본다 · 글자는 이 꼴) · o03 = tap → pump 두 번 한 함수(두 이름 공용) ·
  테스트 이름 '${flow.name} ${brightnessSuffix(b)}' · 주입 = pumpForGolden(tester, <위젯>, brightness: b, logicalSize: kGoldenPhoneSize, wrapApp: (Widget app) => ProviderScope(overrides: stepOverrides(repo: …, actions: …, slots: …, opener: RecordingLinkOpener()), child: app)) →
    await tester.pump(); → await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden(flow.name, b).
  위치 전제 둘 = 이 코드 글자 꼴(흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(kGoldenPhoneSize.height));
    expect(tester.getTopLeft(find.byKey(const Key('o01-progress'))).dy, 0.0);      ← o02·o03 파일은 Key('o02-head')
  명령(packages/ui_shell): flutter test --update-goldens test/golden/o01_golden_test.dart → flutter test --update-goldens test/golden/o02_golden_test.dart → flutter test --update-goldens test/golden/o03_golden_test.dart → flutter test(옵션 없이 · (3) 커밋 전 git status 에 새 PNG 10 · 새 골든 테스트 3(o01_golden_test.dart · o02_golden_test.dart · o03_golden_test.dart)만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     골든 높이 = 카드 확정값 + 여백 재량 — 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (🔴 새 파일을 만들지 않는다 — 이미 있다)
· O01O03_questions.md — «다음 번호»(Q1·A1)부터 · 행 앞에 «O-01:» · «O-02:» · «O-03:» 접두(골든 «측정:» 행 예외) · 꼭 적을 것: 골든 dy 5행(A1~A5 = o01_fresh · o01_advisory · o02_step · o03_ok · o03_fail_code — R15a 상자 꼴 · 카드ID = R15b-Bob-O01O03).
· 적지 않을 것(카드가 정함): 위젯·Key·파일 이름 · 라벨 0 · 읽지 않는 필드 · 아이콘·색 표 · 슬롯 빌더 꼴 · 골든 이름·입력 · 재량(여백).

■ 제출
  (할 일 (1)~(4) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(또는 (5)))
  cd packages/ui_shell
  flutter test test/onboarding_step_list_test.dart     ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +16: All tests passed!» · 시각은 실행마다 다름 · C4r14a-2 · 드라이런 반영판 · ✅ 병합본 가벼운 확인 «00:01 +16»)
  flutter test test/onboarding_step_detail_test.dart   ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +23: All tests passed!»)
  flutter test test/golden/o01_golden_test.dart        ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +4: All tests passed!»)
  flutter test test/golden/o02_golden_test.dart        ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +2: All tests passed!»)
  flutter test test/golden/o03_golden_test.dart        ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +4: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과 — 끝 줄 그대로 — 줄 머리 시각까지(기대 = 시작 기준 N + 49 — 237 → «00:nn +286: All tests passed!»(✅ R15a 병합본 가벼운 확인 «00:17 +286» 2026-11-04 · 재드라이런 2 «00:24 +286») · R15a 병합본 N 이 다르면 N + 49)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← Git Bash 전체 경로(C4r5a-2) · 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건은 이 카드와 무관 — 그대로 둔다
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+424 ~30: All tests passed!»(✅ R15a 병합본 940082c 실측 2026-11-04 · v1.16 병합본 dd9e162 · M2 가지·재드라이런 2 와 같음 · 이 카드 몫 0) · 🔴 melos.bat run test 가 5분 넘게 출력이 없으면 Ctrl+C 로 끊고 packages/ui_shell 에서 flutter test(위 줄) + melos.bat run test:contracts 만 — 끊은 사실을 ② 끝에 한 줄로(드라이런 = 패키지별 실행) · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_shell/): A lib/src/onboarding/onboarding_step_detail.dart · A lib/src/onboarding/onboarding_step_list.dart · M lib/src/shell_providers.dart · M lib/ui_shell.dart ·
        A test/golden/goldens/o01_*.png 4장 · A test/golden/goldens/o02_step_*.png 2장 · A test/golden/goldens/o03_*.png 4장 · A test/golden/o01_golden_test.dart · A test/golden/o02_golden_test.dart · A test/golden/o03_golden_test.dart · A test/onboarding_step_detail_test.dart · A test/onboarding_step_list_test.dart · M test/shell_fakes.dart ·
        M docs/ai-context/inbox/O01O03_questions.md · 그 밖의 줄(특히 M lib/l10n/labels.dart · M lib/src/onboarding/onboarding_start.dart · M lib/src/onboarding/onboarding_mode_pick.dart · M lib/src/shell_scaffold.dart · M PNG · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번(C4r5e-5)
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M8] R15b (5) 사전검사 지적 수정» · amend 금지 · format:fix 먼저 · analyze·format 실패를 고칠 때도 이 (5) 하나) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m8-o01-steps
  ① 에 붙일 출력 — 🆕 파일로 받아 그 글자를 그대로(C4r14b-5 · 화면 복사·문자열 안 "$x" 배열 0):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     git -c core.quotePath=false diff --name-status origin/main...HEAD | Out-File -Encoding utf8 $env:TEMP\r15b_ns.txt
     git log --oneline origin/main..HEAD | Out-File -Encoding utf8 $env:TEMP\r15b_log.txt
     (Get-Content -Encoding UTF8 $env:TEMP\r15b_ns.txt).Count · (Get-Content -Encoding UTF8 $env:TEMP\r15b_log.txt).Count   ← 줄 수 = git 출력 줄 수(한 줄로 이어 붙었으면 다시 · 권장대로면 바뀐 파일 21줄 · 커밋 4줄 — 드라이런 실측 · ✅ 병합본 가벼운 확인 21줄)
  cd packages/ui_shell → 위 «정적 묶음» 의 실행 꼴(파일로 꺼내 Git Bash · EXIT 확인) → cd ../..   ← ② 에 그대로 붙일 출력(r15b_static_out.txt 전부)
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M8] O-01~O-03 단계 목록·상세·검증
  🔴 제출 글 = 아래 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님) + 끝 flutter test 한 줄 — 채팅에 내지 않고 저장 파일 $env:TEMP\R15b-Bob-O01O03_submit.md 로(C4r5a-1) ·
     🆕 저장 = UTF-8 **BOM 없이** · 줄바꿈 그대로(C4r14b-5) — 편집기 도구로 쓰면 «UTF-8(BOM 없음)» · PowerShell 로 쓰면 이 꼴만: [IO.File]::WriteAllText("$env:TEMP\R15b-Bob-O01O03_submit.md", $text + "`n", (New-Object Text.UTF8Encoding($false)))
       ($text = 줄을 -join "`n" 으로 이은 글 · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다) ·
     🔴 채팅 답 = 두 줄뿐: «R15b-Bob-O01O03 제출 글 저장했음: <(Resolve-Path $env:TEMP\R15b-Bob-O01O03_submit.md).Path 출력>» · 사전검사 ② 끝 줄 셋(o01_ · o02_ · o03_ — « / » 로 이은 한 줄) · 대화 요약(Previous conversation summary)을 내지 않는다.
  PR 본문 5섹션을 저장 파일로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로 — 아래 자체 점검 상자는 10줄이지만 머리 글자는 사전검사가 정한다 · 🔴 «10항» 으로 고치면 🔴 R1):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 저장 파일 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② 세 번 — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일($env:TEMP\R15b-Bob-O01O03_submit.md · BOM 없이 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R15b-Bob-O01O03_submit.md --golden-prefix o01_ --goldens 4 | Out-File -Encoding utf8 $env:TEMP\r15b_pre2_o01.txt; Get-Content -Encoding UTF8 $env:TEMP\r15b_pre2_o01.txt | Select-Object -Last 1
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R15b-Bob-O01O03_submit.md --golden-prefix o02_ --goldens 2 | Out-File -Encoding utf8 $env:TEMP\r15b_pre2_o02.txt; Get-Content -Encoding UTF8 $env:TEMP\r15b_pre2_o02.txt | Select-Object -Last 1
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R15b-Bob-O01O03_submit.md --golden-prefix o03_ --goldens 4 | Out-File -Encoding utf8 $env:TEMP\r15b_pre2_o03.txt; Get-Content -Encoding UTF8 $env:TEMP\r15b_pre2_o03.txt | Select-Object -Last 1
        ← 🔴 세 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다) · 출력은 채팅에 붙이지 않는다 · 🔵 접두 o01_ · o02_ · o03_ 는 서로 겹치지 않는다(정규식 머리 일치 — 이름마다 한 번씩 · 세 번 돌리는 까닭) ·
          🔵 🟡 [G1] 은 멈춤이 아니다(드라이런 기대 🟡 = 8행 — o01_: o01_fresh light·dark 2 · o02_: o02_step light·dark 2 · o03_: o03_ok·o03_fail_code light·dark 4(G1 이 «버튼 글자» 를 «상자» 로 읽고 이어진 «글자 n줄» 덩어리를 합쳐 센다 · o01_fresh = 게이트 아이콘 줄이 윗줄과 4px — 위 «보고 규칙» · 표는 이 카드 단위) → 🔴 이 8행은 그대로 낸다 · PNG 를 다시 열지 않는다 · 칸을 고치지 않는다) · 🟡 [G1] 이 그 밖의 행에서 **상자 수·덩어리 차례**를 다르게 읽으면 그 이름의 light PNG 를 다시 열어 표를 맞춘다(안 줄 수만 다른 🟡 · «덩어리로 셀 수 없어 대조하지 않았다» 🟡 는 그대로 · C4r5b-4) ·
          🔴 🟡 수가 카드 기대보다 많으면 늘어난 🟡 행의 light PNG 를 다시 열어 표를 맞춘다 — 다시 열지 않고 그대로 내면 ② 반려(C4r5d-1).
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + $env:TEMP\r15b_ns.txt 글자 그대로(코드 블록 하나) + «커밋 목록:» + $env:TEMP\r15b_log.txt 글자 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: O-01 — 단계 목록(OnboardingStepList()) · O-02 — 단계 상세(OnboardingStepDetail(stepId:)) · O-03 — 검증 결과(O-02 안 결과 조각) · 주입 shellOnboardingSlotBuilderProvider
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항(머리는 «12항») — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다 ·
     꼴 = «N. <prompt 글자> [x] ( )» — [x] 는 글자 뒤 · 이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «정적 묶음 P16 — 허용 밖 import 0줄 · pubspec 무변경(P29)»
        2번 = «산술 = null 여부 · 열거 switch 셋(P09) · 표시 상태뿐 · 거르기·정렬·세기 0(P11) · 진행률 = progressText 그대로 · 금지 수치 P18 0건»
        3번 = «DateTime.now 0(P11) · 만료 = verifiedUntilText 그대로 · verifiedUntil 포맷 0(P11)»
        4번 = «이 카드 범위 밖(5탭·홈·F-01) · 손익 0»
        5번 = «이 카드 범위 밖(알림 = R14)»
        6번 = «이 카드 범위 밖(DND UI = M9)»
        7번 = «이 카드 범위 밖(워치독 = R14b)»
        8번 = «시크릿 = 슬롯 빌더 삽입만(O02-03 · P10) · TextField·클립보드·마스킹 0(P36)»
        9번 = «건너뛰기·해외주식 0(P11 · P23 · O01-08) · 실패 문구 = failureText + 원문 코드 · 결과 = headline + reasonCode 원문(O03-02)»
        10번 = «삽입 자리 직접 구현 0(SecretField = 슬롯 · P36) · 킬스위치 진입 = 셸 몫(무수정 P29)»
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
      10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r15b_box2.txt)에 저장 → (Get-Content -Encoding UTF8 $env:TEMP\r15b_box2.txt).Count → 출력 한 줄을 아래 «10항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 10):
      ┌── 10항 줄 수 복사 시작(다음 줄부터 · 4줄)
10항 줄 수:
```
<출력 한 줄>
```
      └── 10항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 34줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄들(S05 출력 줄마다 한 줄 · 같은 차례 · 기대 2줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(P20·P21 출력 줄 그대로 복사) + «테스트 파일별:» + 위 flutter test 다섯 파일 끝 줄 그대로(onboarding_step_list · onboarding_step_detail · o01_golden · o02_golden · o03_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = P20 출력:
<P20 출력 줄 그대로>
ⓗ = P21 출력:
<P21 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — 목록 정상·빈·로딩·에러 3줄 + 상세 정상·모르는 id·결과·로딩·에러 4줄(= 아래 견본 7줄 · 머리와 견본이 같은 차례·줄 수 — 🆕 C4r15a-1) + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면 1·2» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로(🆕 상태 이름을 감싼 «» · «=» 앞뒤 띄어쓰기 · «·» 까지 한 글자도 바꾸지 않는다 · 줄을 나누거나 합치지 않는다 — C4r15a-1 · «자리 바꿈» 줄은 이 글자 그대로 — 펼치지 않는다 · C4r5e-7):
         «목록 정상» = ListView → Key('o01-progress') → ValueKey<String>('o01-row-$i')(안에 ValueKey<String>('o01-gate-$i') 있을 때) → Key('o01-finish')(있을 때)
         «목록 빈» = ListView → Key('o01-progress') → Key('o01-empty')
         «목록 로딩·에러» = ShellSkeleton(Key('o01-loading')) · ShellErrorView(Key('o01-fail'))
         «상세 정상» = ListView → Key('o02-head') → Key('o02-where')(있을 때) → Key('o02-how')(있을 때) → Key('o02-secret')(있을 때) → Key('o03-run')(있을 때)
         «상세 모르는 id» = ListView → Key('o02-missing')
         «상세 결과(성공·실패)» = «상세 정상» 끝에 Key('o03-result')(안에 Key('o03-level') · Key('o03-retry') 있을 때) 또는 Key('o03-not-accepted')
         «상세 로딩·에러» = ShellSkeleton(Key('o02-loading')) · ShellErrorView(Key('o02-fail'))
      골든 표 10행(한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |» + 바로 다음 줄 구분 줄 «|---|---|---|---|---|---|»(없으면 표로 그려지지 않는다 · C4r5d-8) · 이름 칸 = «o01_fresh light» 꼴 ·
        입력 = 파일 이름만(경로 앞머리 없이 · C4r5e-7 — onboarding_steps_fresh.json · onboarding_steps_advisory.json · onboarding_step_detail_kis_mock.json(o02 · o03 셋 다)) · 주입 = 다섯 이름 모두 «operator» · 크기 = 390×844 ·
        dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(5장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 나란한 상자 2 · 버튼 글자 · 아이콘> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(10행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다) ·
        셈 단위 견본 2행(재드라이런 2 · v1.16 실물 PNG · 꼴만 본뜬다 · 🔴 견본과 같은 이름의 행은 꼬리까지 견본 글자 그대로 — PNG 가 견본과 다르게 보이면 칸을 바꾸지 말고 질문 파일에 · C4r5d-1):
         «| o01_fresh light | onboarding_steps_fresh.json | operator | 390×844 | 700.0 | 글자 1줄 → 글자 6줄 → 글자 7줄 → 글자 6줄 → 글자 9줄 → 글자 6줄 — 잘림 없음 |»
         «| o03_fail_code light | onboarding_step_detail_kis_mock.json | operator | 390×844 | 472.0 | 글자 4줄 → 글자 3줄 → 글자 2줄 → 버튼 글자 → 글자 3줄 → 글자 1줄 — 잘림 없음 |».
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/O01O03_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 줄머리 «+» 까지 출력 그대로 — 지우지 않는다 · C4r5d-8 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = O01O03_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 49 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-o01-steps` 푸시 1건 · 커밋 권장 4개 · (4) 뒤 = (5) 하나만.
- `lib/` 새 파일 **2**(`src/onboarding/onboarding_step_list.dart` · `onboarding_step_detail.dart`) · 수정 2(`shell_providers.dart` 끝 절 1 · `ui_shell.dart` export 2 · 더하기만) · 라벨·셸·R13·R14·R15a 파일 변경 0.
- `test/` 새 파일 5(두 테스트 · 골든 세 파일) + 수정 1(`shell_fakes.dart` 끝 절) + 새 PNG 10 · 재생성 0.
- 질문 파일 `O01O03_questions.md`(A1~A5 «측정:»).
- `flutter test` = 시작 기준 N(R15a 병합본 · 기대 237) + 49 · 정적 P13 = 37 · P14 = 13 · P15 = 18 · P09 = 14 · P33 = 10 A · P20 = 10 · 8 · P21 = 1 · P34 = 10 · 14(🔴 정확히 · 드라이런 반영판).
- 재분할 임계: 줄 25 · lib +410(드라이런) · PNG 10 · 원천 3 → 재분할 없음.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15b-Bob-O01O03 결과: 브랜치 ui/m8-o01-steps 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R15b-Bob-O01O03_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계에서 멈췄다면 `R15b-Bob-O01O03 0단계에서 멈춤 — 확인해줘` + 출력.

## 5. 주의

- **5분 눈 검사**: ① 셸·R15a 파일·`labels.dart`·기존 테스트·PNG 가 `M` ② 새 lib 파일에 `TextField`·`Clipboard`·`obscure`·`verifiedUntil`·`.requirement`·`.estimated`·`whereDeepLink`·`stepId` 를 Key/글자로·`SettingsActionId.`·`'aaq://`·`AppRoutes` ③ 권장 미통과 배지를 화면이 짓기 ④ gate unknown = notApplicable 모양 ⑤ «다음» 을 finishDeepLink 없이 ⑥ 결과를 level 로 숨김 · retryable 무시 ⑦ 슬롯 빌더 null 인데 자리.
- 🔵 `golden:approved` 불필요(새 PNG 만). 🔵 R15c 의 서약문·생체·셀프테스트·체크섬 자리도 이 카드의 슬롯 빌더를 쓴다(⑦ 확정 시).
- 🔵 C4 사람 grep(🆕 재드라이런 2 참고 변이 RF1b «늘 참 단언 find.byType(Icon) + findsWidgets» · RF13 «nullable 흐름 칸 + if(o03 골든)» = 테스트·사전검사 🔴 0 — 테스트 쪽 변이의 사전검사 판정은 임시 커밋 위 · R15a «5» 꼴): `git grep -nE "find\.byType\([^)]*\)\s*,\s*(findsWidgets|findsAtLeast)" -- packages/ui_shell/test/onboarding_step_list_test.dart packages/ui_shell/test/onboarding_step_detail_test.dart` · `git grep -nE "Function\(WidgetTester [A-Za-z_]*\)\?" -- packages/ui_shell/test/` · 둘 다 출력 0 이어야(infra 창 = C4r14b-3 T3 · T1).
- ✅ 남은 표식 0 · 자리표시자 0(2026-11-04 R15a 병합 기록 · 셈 = `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R15b-Bob-O01O03.md` = 0 · 🔵 이 안내 줄에는 그 글자를 쓰지 않았다) — ⓐ «앞 카드 병합 기록 때 채움» 실측 = 병합본 `940082c` 에서 다시 잼(시작 N 237 · 끝 +286 · `domain_contracts` +424 ~30 · 꺼내기 범위 344~377 · 해시 `8929219` 그대로 — 전부 드라이런 기대와 같음) · ⓑ ✅ v1.16 이름표 표식 0(2026-11-03 재조립) · ⓒ «펼침» 표식 = R15a 글자(`_완료/R15a-Bob-O00O00b.md` «3» 규칙 10·12·13 · «보고 규칙» · «■ 골든» · «■ 제출» · 정적 실행 꼴)를 이 카드의 수·이름·파일로 펼쳤다(⑨ 줄 지움 · 🆕 C4r15a-1 반영) + 자리표시자 `#99` · `940082c` 채움 · ✅ 드라이런 실측(파일별 · 줄 · ⓡⓗ(전제) · dy · 견본 · 변이 표 · 🟡 기대)은 «드라이런 기대» 로 채웠다(2026-11-03) · 🔵 이 파일의 앞쪽 줄 수가 바뀌면 꺼내기 범위를 다시 잰다(해시는 34줄 글자만 본다).
- 범위 고지: 01 §8 미결 91·144(셸 스캔 제외 — 이 카드 정적 묶음이 메운다) · 137·143(늘 push — O-01 ↔ O-02 가 쌓인다) · 🆕 v1.16 01 §8 미결 = 150(`whereDeepLink` 옛 뜻) · 151(검증 args 값 사전) · 152(슬롯 이름 확장 · 빌더 구현) · 155(온보딩 VM 산출 — 갈래 목록 원천 `onboarding_choice` → 엔진) · 157(브로커 원문 코드 범위) · 외부 URL 열기 = 06 M4-11 — 이 카드가 닫지 않는다.

## 6. R15 이월 반영 — R15a 카드 «6» 과 같은 표(O-01~O-03 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r14b-1 · C4r14a-4 경우 for 밖 · name 칸 | 규칙 10(R15a 와 같은 글자) · 최소 목록 공통 | — |
| C4r14b-2 흐름 칸 non-null | 규칙 10 · 골든 «흐름 칸 non-null» | — |
| C4r14b-5 ① 파일로 받기 · 저장 BOM 0 | ■ 제출(R15a 꼴 · r15b_ns.txt · r15b_log.txt · WriteAllText) | — |
| C4r14a-5 쓰기 조각 두 방향 · 한 칸 초기화 빼기 | O-03 검증 조각(_busy·_failed·_result) · O03-04 두 방향 · 예고 변이 (검증) «한 칸 초기화 빼기(두 방향)» | — |
| C4r14a-6 부재 = 데이터 = operator | O03-05(viewer · operator 두 경우) · O02-03 no_slot(operator 주입) | — |
| C4r5d-5 골든 명령 칸 = 공장 | ■ 골든 o03 «명령 칸 = 공장 SettingsActions Function() 을 testWidgets 안에서» | — |
| C4r5c-5 (a) · C4r5e-3~7 (계승) | R15a «6» 과 같은 자리(흐름 클로저 · 갈래마다 · 판정 줄 위주 · 머리 ASCII · 타입이 막음 참고 · 자리 바꿈 견본 · 입력 = 파일 이름만) | 배너 = 해당 없음(asOf 0) |
| 🆕 C4r15a-1 ③ 머리 = 견본 차례·줄 수 · «» 까지 견본 글자 그대로(R15a C4I-1·C4I-2) | ■ 제출 ③ 머리 «목록 정상·빈·로딩·에러 3줄 + 상세 정상·모르는 id·결과·로딩·에러 4줄(= 아래 견본 7줄 · 머리와 견본이 같은 차례·줄 수)» · 견본 머리 «상태 이름을 감싼 «» · «=» 앞뒤 띄어쓰기 · «·» 까지 한 글자도 바꾸지 않는다 · 줄을 나누거나 합치지 않는다» · «보고 규칙» ③ ««» 까지 견본 글자 그대로»(2026-11-04 승격 때 · 바뀐 줄 = 위 세 자리 · 견본 7줄·골든 견본 2행 글자 = 무변경 · 드라이런 기대값(+286 · 🟡 8) 무변경) | R15c·R15d 승격 때 같은 꼴 · 이후 카드 조립 체크리스트(12 §3 «R15a C4 이월 부록») |
| C4r15a-2 드라이런 변이 앵커 analyze 선확인 | — | 조립 체크리스트(R15c·R15d 드라이런 변이 표 · 12 §3 «R15a C4 이월 부록») |
| C4r15a-3 · C4r15a-4 사전검사 T3·T1 표본 · inbox README «측정» 종류 | — («5» C4 사람 grep 두 줄 그대로) | 🛠 다음 infra 창(C4r14b-3 · C4r5e-8 과 한 줄) |
| 공통 교훈(R5·R13·R14) | 머리 «교훈 반영» 줄 | — |
