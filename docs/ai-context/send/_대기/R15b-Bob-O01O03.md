# 발송 패킷 R15b-Bob-O01O03 — O-01 단계 목록 · O-02 단계 상세 · O-03 검증 드라이런 결과 (계약 v1.16 전제 · R15 4장 중 2번째 · M8)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-02 조립 · 앱 `rec/r15`) · 선행 = ① R15a 병합(squash `__R15A_SQ__` · PR `__R15A_PR__` · 시작 기준 N = R15a 병합본 실측) ② 🔴 **계약 v1.16 보강 R15b 몫(G8~G14 — 아래 «■ 계약 v1.16 이름표» · ⬜ 발주자 결정 · ▶ 금지)** ③ 🔴 **`SecretField` 삽입 자리 꼴 결정**(M4·M9 소유 위젯 · 실물 0 — 권고 = 슬롯 빌더 주입 · ⬜ 발주자 확인 ⑦) ④ ⬜ 누적 드라이런(R15a 드라이런 끝 위) ⑤ ⬜ 발주자 확인 ①~⑫ ⑥ ⬜ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R15a 브랜치(`ui/m8-o00-mode-pick`)는 건드리지 않는다.
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(🔀 4분할 — R15a 카드 머리 «재분할 판정») + §3-0 + §3 공통 조문 + 이월 부록 «R15» 대상(R15a 카드 «6» 과 같은 표 · O-01~O-03 자리) · 화면 몫 원본 = `04_…` §9 머리 · §9-2(`O-01` · 3등급 · 진행률 · 만료 시계 · 해외주식 0 · 갈래별 준비물 참고표 · 그림 18) · §9-3(`O-02` · 시크릿 6원칙 = `SecretField` 몫) · §9-4(`O-03` · 3상 · 원문 코드 · 그림 19) · §9-8(게이트 3상 · 그림 23) · `01_…` §2-10 `OnboardingStep`·`StepState`·`StepRequirement` · §2-1 `GateState`·`GateBadge` · §4-1 · §4-3 `SettingsActions`·`ActionResult` · `05_…` §4-1(`SecretField` 6원칙 — 읽기만) · 판독 메모 §5-1 G8~G14 · §5-2.
> 사전 조건 — ⬜ **R15a 병합**(PR `__R15A_PR__` squash `__R15A_SQ__` · `ui_shell` = lib 14파일 · 라벨 37 · 배럴 export 11줄 · 셸 주입 17줄 · PNG 48 — 병합본 실측으로 채움) · ⬜ 계약 v1.16 R15b 몫(R15a 와 같은 보강 PR 이면 그 PR · 따로면 v1.16.x — 아래 이름표) · ✅ 프롬프트 v2. 시작 기준 = R15a 병합본의 `flutter test`(packages/ui_shell) = **⟦실측: R15a 병합본 — 드라이런 기대 237⟧** · 이 카드 끝 기대 = 시작 기준 N + **44**(뷰 34 = `onboarding_step_list_test` 13 + `onboarding_step_detail_test` 21 · 골든 10 = `o01_*` 4 + `o02_*` 2 + `o03_*` 4) · 끝 = ⟦실측: 드라이런 «+281» 기대⟧.
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **22**(`onboarding_step_list_test` 8 · `onboarding_step_detail_test` 11 · 골든 3) · lib ⟦실측: 드라이런 — 추정 +390~510⟧ · 새 PNG **10** · 원천·쓰기 **3**(`watchStepList` · `watchStep` · `run(verify.id)`) → 임계 안 · 재분할 없음(R15 를 4장으로 나눈 까닭 = R15a 카드 머리).
> 카드 기본값(⬜ 아래 «발주자 확인» ①~⑫ 가 확정): ⓐ 위젯 = `OnboardingStepList({super.key})`(`lib/src/onboarding/onboarding_step_list.dart` · `ConsumerWidget`) · `OnboardingStepDetail({super.key, required this.stepId})`(`lib/src/onboarding/onboarding_step_detail.dart` · `ConsumerStatefulWidget` — 검증 조각 `_busy`·`_failed`·`_result`) · `O-03` = `O-02` 안의 결과 조각(별도 라우트 0 — ⑥) ⓑ **셸 파일·R15a 파일은 고치지 않는다** — 연결 = 조립 앱 레지스트리(`AppRoutes.onboardingStep` · v1.16 `O-01` 라우트) ⓒ 원천 = 🆕 `watchStepList()` → `OnboardingStepsVm`(갈래 인자 0 — 엔진이 `onboarding_choice` 로 고른다 · ①) · 🆕 `watchStep(stepId)` → `OnboardingStepDetailVm` · 쓰기 = `SettingsActions.run(verify.id, args: verify.args)`(VM 이 준 동작 그대로 · 화면이 id·키를 짓지 않는다 · ⑤) — 주입 = R15a `shellOnboardingActionsProvider`(뷰어 null = 검증 버튼 부재) ⓓ O-01 = 진행률 글자(`progressText`) → 단계 행(받은 차례 · 상태 아이콘 = `StepState` 5값 전수 · 등급 글자 `requirementLabel` · 경고 배지 `warningLabel?` · 만료 `verifiedUntilText?` · 실패 문장 `failureText?` + 원문 코드 `failureReasonCode?` · 게이트 `gate?`(`GateState` 4값 전수 — `unknown` = 진행 차단 모양 · `notApplicable` 과 다른 모양)) → 빈 문장(`emptyLabel?`) → «다음» = `finishLink`(O-04 · 있을 때) · 행 탭 = `detailLink`(O-02 · null = 탭 없음) ⓔ O-02 = 제목·이유·어디서·얼마나·어떻게·만료(엔진 글자) → 🔒 시크릿 자리(`secretSlotId` 가 있을 때 · 슬롯 빌더 주입 · 자체 `TextField` 0) → 검증 버튼(`verify.label` · 주입·`verify` 있을 때) → O-03 결과 조각(`UiLevel` 5값 아이콘 · `headline` · `reasonCode` 원문 · `retryable` 이면 «다시 시도») · 모르는 id = `missingLabel` 한 줄 ⓕ 🔴 판정 0 — «검증 성공 같으니 다음 활성» 0 · 권장 미통과 = 경고 배지만(차단 = 엔진 `gate`) · 비율·남은 시간·만료 계산 0 · 해외주식 행 0(목록에 없으면 없다) ⓖ 새 lib 파일 2 · 공용 3(배럴 +2 · `shell_providers.dart` 끝 절 슬롯 빌더 1 · `test/shell_fakes.dart` 끝 절 — **끝 절 더하기만** · 라벨 0 · «정확히 N» = 마지막 카드) · Key 접두 `o01-`·`o02-`·`o03-` · 골든 5이름 10장(`o01_fresh` · `o01_advisory` · `o02_step` · `o03_ok` · `o03_fail_code`).
> 🔴 **카드 덮개 필수 문장(04 §9 머리 · §9-2~§9-4 · §9-8 · prompt_M8 145~152)** — «게이트 판정은 전부 엔진 — 화면은 판정 결과와 문구를 그린다(«검증 성공 같으니 다음» 0 · 권장 미통과 = 경고 배지만 · `unknown` = 진행 차단 · `notApplicable` 과 같은 모양 0 · «일단 진행» 0)» · «목록은 받은 차례 그대로 — 갈래를 화면이 모른다(목록 두 벌 0 · `OperatingMode` 0) · 진행률 = `progressText` 그대로(비율 계산 0) · 만료 = `verifiedUntilText` 늘 보임(UTC `verifiedUntil` 포맷 0)» · «시크릿 = `SecretField` 삽입 자리뿐 — 자체 `TextField`·붙여넣기 버튼·마스킹·임시 저장·확인 필드 0» · «검증 = VM 이 준 동작 `run(id, args)` 그대로 1회 · 결과 = 3상(성공/실패/재시도)만 · 실패 문구 = `headline` + 원문 코드(요약·의역 0) · 재시도 가능 = `retryable` 데이터» · «셸 파일·R13·R14·R15a 파일·테스트·PNG 는 고치지 않는다».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 01 §2-1 `GateState.unknown`(진행 차단) · 01 §2-10 `estimatedText` · X7 §5-3(준비물 갈래 — 엔진 몫) · K35.
> ⬜ **발주자 확인 12건(권고 = 카드 기본값)** — ① O-01 원천 = 🆕 추가형 `watchStepList()` → `OnboardingStepsVm{progressText, rows, emptyLabel?, finishLink?}`(갈래 인자 0 — 04 §9-2 «화면은 갈래를 알지 못한다» · 기존 `watchSteps(OnboardingTrack)` 는 v1.16 이 두거나 지운다) ② `OnboardingStep` 표시 칸 = 🆕 `requirementLabel`(등급 글자 — «권장» 낱말도 엔진 글자 · R15a 의 «권장 0» 은 `O-00b` 몫) · `warningLabel?`(권장 미통과 배지 — 엔진 판정) · `verifiedUntilText?` · `failureText?` · `gate?`(`GateBadge`) · `detailLink?`(O-02) — `verifiedUntil`·`estimated`·`requirement`·`whereDeepLink` = 화면 미참조 ③ 단계 게이트 = `GateBadge.state` 4값 전수 switch(아이콘·색 — `unknown` = 차단 모양 · `notApplicable` = 다른 모양) · 글자 = `gate.label` · «일단 진행» 0 ④ O-02 원천 = 🆕 `watchStep(stepId)` → `OnboardingStepDetailVm{step?, missingLabel?, whereText?, howText?, verify?, secretSlotId?}`(목록을 거르면 «판정» — 단건 창구) · 모르는 id = `missingLabel` 값(에러 아님) ⑤ 검증 동작 = 🆕 `OnboardingVerifyAction{id, args, label}`(엔진이 단계 ↔ `SettingsActionId` + 화이트리스트 args 를 완성 — 화면이 키를 짓지 않는다 · null = 버튼 부재) ⑥ O-03 = O-02 안 결과 조각(`run` 반환 `ActionResult` 하나 · `level` 아이콘 · `headline` · `reasonCode` 원문 · `retryable` → «다시 시도») · 별도 라우트·`watch(actionRunId)` 0(링크 조립 0) ⑦ 🔴 `SecretField` 삽입 자리 = 🆕 슬롯 빌더 주입 `shellOnboardingSlotBuilderProvider`(`Widget Function(String slotId)?` · 조립 앱 = M4·M9 `SecretField` · 뷰어·미주입 = null = 자리 부재 · R15c 의 서약문·생체·셀프테스트·체크섬 자리도 같은 주입) · 대안 = `ShellPlaceholder` 고정 높이 자리(소유 위젯이 오면 골든 재촬영 `golden:approved`) ⑧ `whereDeepLink` 뜻 = v1.16 이 정리(권고: 내부 단계 링크 = `detailLink` · «어디서 받나» = `whereText` 글자 · 외부 URL 열기 = 플랫폼 몫 · `AppLinkSchemes` 밖) ⑨ 표본 정리 = v1.16 새 `m8/onboarding_steps_*` 에 `o_00`(운영 모드 행 — O-01 에서 O-00b 로 되돌아가는 길 · 04 §9-1 «O-01 안의 한 단계 기각»)·`o_04`(가상 초기금 — O-04 6단계 몫) 행 0 · 해외주식 행 0 ⑩ 정적 라벨 0(«다음» = R15a `onboardingNext` · «다시 시도» = `retry` · 실패 = R15a `onboardingNotAccepted` 재사용) ⑪ 골든 5이름 10장(`o01_fresh` · `o01_advisory` · `o02_step` · `o03_ok` · `o03_fail_code` — 04 에 이름 없음 · 카드가 지음) ⑫ 이월 반영(«6» — C4r14a-5 = O-03 검증 조각).
> 🚫 **플랫폼 몫 = 화면 밖** — Android Keystore · 클립보드 60초 클리어 · `FLAG_SECURE`(시크릿 라우트 진입/이탈 · 05 §4-2) · 생체인증 열람 · 외부 URL 열기(KIS 개발자센터 · GitHub · healthchecks — `url_launcher` 0) · Android 권한 요청(`o_05` 알림 · `o_06` 배터리 최적화 · 정확 알람 · FGS 5분 실측) = 조립 앱·엔진(06 M4 · X3) · 이 카드 = 엔진이 준 결과·글자만.
> 드라이런: ⬜ ⟦실측: 누적 드라이런 2번째 — 가지 `dry/r15-2` = R15a 드라이런 끝 + R15a 병합 기록 흉내 + v1.16 R15b 몫 흉내 → 권장 4커밋 · 시작 · 끝 · 정적 · 사전검사 · dy · lib 줄 · 변이⟧.
> 프롬프트 = `docs/ai-context/prompt_M8.md`(v2 판 183줄 · 2행·119행 범위 · 128행 PR 제목 형식 → 이 카드가 덮는다). 🔴 Bob **새 대화** 전제 — R15a 대화를 기억하지 못합니다.
> R4·R13·R5·R14·R15a 교훈 반영: R15a 카드 머리 «교훈 반영» 줄과 같다(PNG 열람 = 이름마다 light 1장(5장) · 경우 for 는 testWidgets 밖 · 흐름 칸 non-null · 경우 이름 = name 칸 · 쓰기 조각 두 방향 · 부재 = 데이터는 operator · 전제는 if 밖·`// pre` · 커밋마다 `git show --stat HEAD` · 저장 파일 BOM 0 · ① = 파일로 받은 출력 · 정적 = 파일로 Git Bash · 머리 ASCII · G1 🟡 조문 · ③ 구분 줄 · ④ «+» · 단언 없는 `takeException` 0 · 파일별 시각 머리 · 이어진 글자 행 = 한 덩어리 · «자리 바꿈» 견본 · 입력 칸 = 파일 이름만).

## 0. 한 줄 목적

`OnboardingStepList()` 가 `watchStepList()` 의 `OnboardingStepsVm`(진행률 글자 · 엔진이 갈래로 고른 단계 목록 · O-04 링크)을 받은 차례·글자 그대로 그리고(상태 = `StepState` 아이콘 · 등급·경고·만료·실패 = 엔진 글자 · 게이트 = `GateState` 4값 · 판정 0), `OnboardingStepDetail(stepId:)` 가 `watchStep` 의 단계 상세를 그린 뒤 시크릿은 주입된 슬롯 빌더에만 맡기고(자체 입력 0), 검증 버튼 한 번에 VM 이 준 동작 `run(id, args)` 를 한 번만 불러 결과를 3상·원문 코드 그대로 보이는 `O-01`·`O-02`·`O-03` 을 계약 v1.16 그대로 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-o01-steps`**(base = 최신 `origin/main` · `--no-track` · 분할 뒤 새 이름 · ⬜ 발주자 확인 R15a ①) · PR 제목 = «[M8] O-01~O-03 단계 목록·상세·검증».

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 `_대기/`(R15a 병합 기록이 `send/` 로 옮기고 자리표시자·실측 표식을 채운다).
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
  git grep -c "contractVersion = '1.16" -- packages/domain_contracts/lib/src/contract_version.dart                         ← ⟦실측: v1.16(또는 v1.16.x) 병합본 «…:1»⟧
  git grep -c "Stream<OnboardingStepsVm> watchStepList();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart  ← «…:1»(v1.16)
  git grep -c "Stream<OnboardingStepDetailVm> watchStep(String stepId);" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart  ← «…:1»(v1.16)
  git grep -c "abstract class OnboardingStepsVm" -- packages/domain_contracts/lib/src/dto/safety.dart                          ← ⟦v1.16 파일 자리⟧ «…:1»
  git grep -c "abstract class OnboardingStepDetailVm" -- packages/domain_contracts/lib/src/dto/safety.dart                     ← ⟦v1.16⟧ «…:1»
  git grep -c "abstract class OnboardingVerifyAction" -- packages/domain_contracts/lib/src/dto/safety.dart                     ← ⟦v1.16⟧ «…:1»
  git grep -c "required String requirementLabel," -- packages/domain_contracts/lib/src/dto/safety.dart                         ← ⟦v1.16⟧ «…:1»
  git grep -c "String? verifiedUntilText," -- packages/domain_contracts/lib/src/dto/safety.dart                                 ← ⟦v1.16⟧ «…:1»
  git grep -c "String? failureText," -- packages/domain_contracts/lib/src/dto/safety.dart                                       ← ⟦v1.16⟧ «…:1»
  git grep -c "GateBadge? gate," -- packages/domain_contracts/lib/src/dto/safety.dart                                           ← ⟦v1.16⟧ «…:1»
  git grep -c "static const String m8OnboardingStepsFresh =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← «…:1»(v1.16)
  git grep -c "static const String m8OnboardingVerifyResults =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart ← «…:1»(v1.16)
  git grep -c "final Provider<SettingsActions?> shellOnboardingActionsProvider" -- packages/ui_shell/lib/src/shell_providers.dart  ← «…:1»(R15a 병합)
  git grep -c "static const String onboardingNotAccepted" -- packages/ui_shell/lib/l10n/labels.dart                              ← «…:1»(R15a 병합)
  git grep -c "class FakeShellOnboardingRepository" -- packages/ui_shell/test/shell_fakes.dart                                  ← «…:1»(R15a 병합 — 이 카드는 끝 절에 새 가짜를 더한다 · 고치지 않는다)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                          ← «…prompt_M8.md:1»
  ls docs/ai-context/send/R15b-Bob-O01O03.md                                ← 보여야 올바른 기준
  ls docs/ai-context/inbox/O01O03_questions.md                              ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_fresh.json      ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_advisory.json   ← 보여야 함(v1.16)
  ls packages/domain_contracts/fixtures/m8/onboarding_steps_finish_ready.json  ← 보여야 함(v1.16)
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
  flutter test   ← 시작 기준: R15a 병합본 전부 통과 · 기대 ⟦실측: «+237: All tests passed!»(R15a 병합본 · 드라이런 기대 237)⟧(끝 줄의 수를 «시작 기준 N» 으로 · 다르면 PR 본문에 까닭 한 줄 · 실패가 있으면 멈추고 끝 20줄을 채팅으로)
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 계약 v1.16 이름표 — R15b 몫(🔴 코드가 정본 — 다르면 멈추고 질문 파일에 · ⟦v1.16⟧ = 보강 PR 글자로 병합 기록 때 고침)
  OnboardingStep(기존 + 🆕 칸)  …기존 칸 · 🆕 required String requirementLabel(등급 글자 — 엔진) · String? warningLabel(권장 미통과 배지 — 엔진 판정 · null = 부재) · String? verifiedUntilText(만료 글자 — 엔진 · null = 만료 없음) ·
                     String? failureText(실패 문장 — 엔진 · failureReasonCode 와 함께) · GateBadge? gate(단계 잠금 — 엔진 판정 · null = 게이트 없음) · String? detailLink(O-02 링크 — 엔진이 완성 · null = 행 탭 없음)
                     — 🔴 화면 미참조: stepId · track · order · estimated(Duration) · requirement(열거 — 글자 = requirementLabel) · verifiedUntil(UTC) · whereDeepLink(⟦v1.16 뜻 정리⟧)
  🆕 OnboardingStepsVm({required String progressText, required List<OnboardingStep> rows, String? emptyLabel, String? finishLink})
                     — progressText = «7/12 완료» 류(엔진) · rows = 엔진이 onboarding_choice 로 고른 갈래 목록(받은 차례) · emptyLabel = rows 0 일 때만 · finishLink = O-04 링크(필수 통과 뒤에만 — 엔진 판정 · null = «다음» 부재)
  🆕 OnboardingStepDetailVm({OnboardingStep? step, String? missingLabel, String? whereText, String? howText, OnboardingVerifyAction? verify, String? secretSlotId})
                     — step non-null XOR missingLabel non-null · whereText = «어디서 받나»(엔진 글자 · 외부 열기 0) · howText = «어떻게 검증하나»(엔진) · verify = 검증 동작(null = 버튼 부재) · secretSlotId = 시크릿 자리 이름(null = 자리 없음)
  🆕 OnboardingVerifyAction({required SettingsActionId id, required Map<String, String> args, required String label})
                     — id·args = 엔진이 화이트리스트 안에서 완성(🔴 화면이 키·값을 짓지 않는다 · 그대로 넘긴다) · label = 버튼 글자(엔진)
  repositories/onboarding_repository.dart  Stream<OnboardingStepsVm> watchStepList(); · Stream<OnboardingStepDetailVm> watchStep(String stepId);(추가형 · 스트림 에러 = 읽기 실패 · 모르는 id = missingLabel 값)
  testing.dart  UnimplementedOnboardingRepository(v1.16 — 새 두 메서드 포함) · UnimplementedSettingsActions(기존)
  FixturePaths  m8OnboardingStepsFresh · m8OnboardingStepsAdvisory · m8OnboardingStepsFinishReady · m8OnboardingStepDetailKisMock · m8OnboardingStepDetailNoVerify · m8OnboardingStepDetailMissing · m8OnboardingVerifyResults(아래 «픽스처»)
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
 4 이동 = AppLinkOpener.open(link) 하나(탭 콜백 안) — 링크 = 행 탭 step.detailLink · «다음» finishLink 둘뿐 · 🔴 'aaq://'·'https://' 리터럴 0 · AppRoutes 0 · 링크 조립 0 · 외부 URL 열기 0(whereText = 글자) ·
   공개 위젯 생성자 = OnboardingStepList({super.key}) · OnboardingStepDetail({super.key, required this.stepId}) 둘 · 🔴 stepId 는 watchStep 인자로만(글자·Key·비교 0).
 5 산술·판정 0 — 허용 = ⓐ null 여부(링크 · 글자 칸 · gate · verify · secretSlotId · 슬롯 빌더 · 주입 · _result) ⓑ StepState 5값 · GateState 4값 · UiLevel 5값 전수 switch(아이콘·색) ⓒ 검증 버튼 가능 = 주입 non-null ∧ verify non-null ∧ !_busy(한 식) ·
   ⓓ 검증 조각 상태(_busy · _failed · _result) · result.retryable(«다시 시도» 있음 여부 — 엔진 판정을 읽기만) ⓔ 순번(indexed). 그 밖에 거르기·세기·정렬·자르기 0 · rows.length 글자 0 · DateTime.now 0 · Duration·DateTime 포맷 0 ·
   requirement·state 로 차단·활성 판정 0(🔴 «권장인데 미통과면 배지» 를 화면이 만들지 않는다 — warningLabel) · OperatingMode·FeatureFlags·RunMode 0.
 6 switch 는 열거값 전수(default 0): StepState 5값(_stepLook) · GateState 4값(_gateLook) · UiLevel 5값(_resultLook) — 셋뿐 · 🔴 _gateLook 의 unknown 과 notApplicable 은 다른 아이콘·색(04 §9-8).
 7 공통 조각 = ShellSkeleton · ShellErrorView 재사용 · asOf 머리·오래됨 배너 0(R15a ⑤ 와 같다 — VM 에 asOf 없음) · 새 공용 조각 0 · 스피너 금지 · 시계 미사용.
 8 본문이다 — Scaffold·AppBar·SafeArea·Navigator 0 · 부모 높이 안 ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 · 간격·크기 = 정수·N.0.
 9 프로바이더 — 새 주입 1(슬롯 빌더 · throw 기본값) · 데이터 2(StreamProvider 1 · StreamProvider.family 1 — stepId · 파일 안 private · autoDispose 0) · 탭 핸들러 안 ref.read · 데이터·주입 null 여부는 build 에서 ref.watch.
10 테스트 = R15a 카드 규칙 10 과 같다(받침대 extends · implements 0 · 호출마다 새 Stream/Future · 공장 = call 삼항 · 픽스처 = main() 머리 final · 전제 = testWidgets 본문 첫머리 · if 밖 · `// pre` · 경우 for 는 testWidgets 밖 ·
   흐름 칸 non-null 클로저 · 경우 이름 = name 칸 · 자기 주입값 확인 금지 · 늘 참 금지 · ⓡ + 양성 기준점 · copyWith 0 · 링크 = RecordingLinkOpener · 목록 == 목록 · 갈리는 단언 = if/else 양쪽 또는 want ? findsOneWidget : findsNothing ·
   «부재 = 데이터» = operator 주입 · ASCII 이름·리터럴 · null-aware 원소 · collection-if 0 · else 없는 if 0 · 반려 꼴 목록 그대로 · 제네릭 위젯 술어 = descendant of byKey 꼴만 · 스켈레톤 1 = byKey findsOneWidget · 묶음 글자 = shownTexts) ·
   🔴 시크릿 자리 테스트 = 가짜 슬롯 빌더(slotId 를 받아 Key('fake-slot-<slotId>') 단 SizedBox 를 낸다 · 받은 slotId 를 기록)로만 — TextField 를 찾지 않는다 ·
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄(🔴 O-03 «다시 시도» 가 보이는 경우는 그 테스트의 ⓡ 를 쓰지 않는다 — 아래 목록이 정한다) · ⓗ = 목록 단언 루프 앞의 hasLength 한 줄 ·
      정적 P20·P21 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(onboarding_step_list_test ⓡ 7 · ⓗ 1 · onboarding_step_detail_test ⓡ 8 · ⓗ 0).
   «없는 쪽» 견본 · «화면 Text 전부» 견본 = R15a 카드 규칙 10 과 같은 글자 꼴(경우 칸 = 기대 글자 String? · if/else 양쪽 · 양성 기준점 · allowed = stepListAllowed(c.v) / stepDetailAllowed(c.v, r) · ⓡ 는 테스트 끝 한 줄).
11 골든 = 새 PNG o01_* 4장 · o02_* 2장 · o03_* 4장 · --update-goldens 는 o01·o02·o03 골든 파일만 · 기존 PNG(48장) 재생성 0 · golden:approved 안 붙임 · 🔴 높이(844)는 늘리지 않는다.
12 도구 = R15a 와 같다(format:fix → format·analyze·test·test:contracts SUCCESS · melos run test 백그라운드·파이프 0 · 패키지 폴더 flutter test 직접).
13 C-4 이름 함정 — R15a 와 같다.
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 주석도 센다 — 두 새 lib 파일 주석에 이 낱말을 쓰지 않는다: stepId · verifiedUntil · requirement · estimated · whereDeepLink · OperatingMode · TextField · TextFormField · Clipboard · obscure · FLAG_SECURE · keystore · url_launcher ·
   DateTime.now · Duration · AppRoutes · FeatureFlags · runMode · Colors · RichText · autoDispose · Scaffold · Navigator · actionRunId · handoffRoute · skip · 해외 · 건너뛰 · 추천 · 권유 · 자문 · 시그널.
🔴 보고 규칙(strict 나눔) · PNG 열람(이름마다 light 1장 = 5장) · 배치·잘림 칸 · 셈 단위 · PR 본문 = 통합 담당 · S05 결과 줄 · 자체 점검 ② · ③ = R15a 카드 «보고 규칙» 과 같은 글자(이 카드의 수 = 5장 · S05 기대 2줄).

■ 프롬프트보다 이 카드가 이긴다 — 17항 (prompt_M8.md 183줄 판 v2)
 ① 2행 {{범위}} = S-01 · 119행 → 이 카드의 범위 = O-01 · O-02 · O-03
 ② 113~118행 역할·범위 → 이 카드 = O-01~O-03 · O-00·O-00b = R15a(병합됨) · O-04 = R15c · R-01·V-01 = R15d · 그 밖 = R13·R14·R16
 ③ 12~13행 의존 셋 → 추가 0 · pubspec 무변경
 ④ 15~19행 링크는 데이터 → 그대로 유효(행 탭 = detailLink · «다음» = finishLink · null = 부재 · 외부 URL 0)
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
 ③ 01 §2-10 OnboardingStep·StepState·StepRequirement · §2-1 GateState·GateBadge · §4-1 · §4-3 ActionResult · ⟦v1.16 절⟧ ④ 05 §4-1(SecretField — 이 카드는 자리만)
 ⑤ packages/domain_contracts/lib/ — dto/safety.dart(OnboardingStep · v1.16 새 DTO) · dto/common.dart(GateBadge) · enums/onboarding.dart · enums/ui.dart(GateState · UiLevel) · commands/settings_actions.dart · testing.dart
 ⑥ packages/ui_shell — lib/src/onboarding/onboarding_mode_pick.dart(🔵 R15a 쓰기 조각 꼴 · 읽기만) · lib/src/watchdog_board.dart(_checkLook 꼴) · test/onboarding_mode_pick_test.dart · test/shell_fakes.dart · golden README «🆕 R15»
 ⑦ fixtures/README.md(m8 행 · v1.16) ⑧ inbox/README.md · O01O03_questions.md 머리말
 ⑨ docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3» 의 규칙 10 · «보고 규칙» · «■ 골든» · «■ 제출»(🔴 이 카드가 «R15a 와 같다» 로 부른 글자의 정본 — 읽기만 · 그 카드의 수·이름·파일은 쓰지 않는다)

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
  import 차례 = R15a 와 같다(onboarding_step_detail 만 'dart:async').
· 🆕 주입 1 = lib/src/shell_providers.dart 끝 R15b 절:
    // ── R15b — O-01~O-03 injection providers ─────────────────────────────────
    typedef ShellSlotBuilder = Widget Function(String slotId);
    final Provider<ShellSlotBuilder?> shellOnboardingSlotBuilderProvider = Provider<ShellSlotBuilder?>((Ref ref) => throw UnimplementedError('shellOnboardingSlotBuilderProvider must be overridden'));
    (🔵 조립 앱 = slotId 별로 M4·M9 SecretField(·R15c 의 M5·M9 자리)를 낸다 · 뷰어·미주입 빌드 = overrideWithValue(null) = 자리 부재 · ⟦발주자 확인 ⑦ — 대안 = ShellPlaceholder 고정 높이⟧ · 🔵 typedef 는 줄머리 «final» 이 아니라 정적 P15 셈 밖)
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
         ← final String? link = step.detailLink; final String? warn = step.warningLabel; final String? vlabel = step.verificationLabel; final String? until = step.verifiedUntilText; final String? fail = step.failureText; final String? code = step.failureReasonCode; final GateBadge? gate = step.gate;
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
 _run(SettingsActions a, OnboardingVerifyAction v) = R15a _pick 꼴(세 칸 같이 · run(v.id, args: v.args) · 실패 = _failed true · _result null)
 🔴 단계 실패 문장(failureText)·원문 코드는 O-01 행 몫 · O-02 는 머리에 만료만 · 결과 = 이번 run 의 ActionResult 하나

■ 픽스처 (FixturePaths.… · singleFixture — VM 1행 봉투 · 결과 = listFixture · 🔴 전제 expect 로 다시 확인)
 fresh        m8OnboardingStepsFresh — rows ⟦v1.16 · 권고 12⟧(StepState 5값 전부 · 권장 미통과 행 warningLabel non-null · 만료 행 verifiedUntilText non-null · 실패 행 failureText·failureReasonCode non-null · gate 4값 표본 각 1행(unknown 포함) · detailLink null 1행) · finishLink null · emptyLabel null · o_00·o_04·해외주식 행 0
 advisory     m8OnboardingStepsAdvisory — 투자 안내 갈래 rows(대사 전용 키 recommended 등 — 04 §9-2 참고표) · finishLink null
 ready        m8OnboardingStepsFinishReady — rows 전부 verified · finishLink non-null
 kisMock      m8OnboardingStepDetailKisMock — step non-null · whereText·howText non-null · verify non-null(label · id · args) · secretSlotId non-null
 noVerify     m8OnboardingStepDetailNoVerify — step non-null · verify null · secretSlotId null
 missingV     m8OnboardingStepDetailMissing — step null · missingLabel non-null
 results      listFixture(m8OnboardingVerifyResults, ActionResult.fromJson).rows — [0] 성공(level ok · reasonCode null · retryable false) · [1] 실패(level blocked · reasonCode «EGW00133» · retryable true) · [2] 실패(reasonCode non-null · retryable false)

■ Key 표 (o01- 8이름 · o02- 7이름 · o03- 5이름 — 정본 · 표 밖 Key 0 · 순번만 · 🔴 stepId 0)
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
  계획 = step_list_test 줄 8(테스트 13) · step_detail_test 줄 11(테스트 21) · 골든 3 · 합 22.
  🆕 test/shell_fakes.dart 끝 절(«// ── R15b — O-01~O-03 fakes ──»): FakeShellStepRepository extends UnimplementedOnboardingRepository(steps · detail 공장 · stepIds 기록 · listCalls) · FakeShellSlotRecorder(slotIds 기록 · build(slotId) → SizedBox(key: ValueKey<String>('fake-slot-$slotId'), height: 48)) ·
    stepOverrides(…) · pumpStepList · pumpStepDetail · stepRowTexts(OnboardingStep s) => <String>[s.title, s.whyLine, s.estimatedText, s.requirementLabel, ?s.warningLabel, ?s.verificationLabel, ?s.verifiedUntilText, ?s.failureText, ?s.failureReasonCode, ?s.gate?.label] ·
    stepListAllowed(OnboardingStepsVm v) · stepDetailAllowed(OnboardingStepDetailVm v, ActionResult? r)(+ ShellLabels.onboardingNext · onboardingNotAccepted · retry 중 그 화면에 나올 수 있는 것 · 🔴 stepId·링크·code(GateBadge) 0) · FakeShellOnboardingActions = R15a 가짜 재사용(고치지 않는다).
O-01 — test/onboarding_step_list_test.dart
 O01-01 진행률·행 글자·받은 차례(04 §9-2) — fresh: 전제 둘: expect(fresh.finishLink, isNull); // pre · expect(fresh.emptyLabel, isNull); // pre → repo.listCalls == 1 · shownTexts(o01-progress) == [fresh.progressText] ·
        ⓗ expect(fresh.rows, hasLength(⟦v1.16 표본 행 수⟧)) → i 마다 shownTexts(o01-row-$i) == stepRowTexts(fresh.rows[i]) · 사슬 dy o01-progress → o01-row-0 → … · o01-finish findsNothing · o01-empty findsNothing · ⓡ.
 O01-02 상태 아이콘 = StepState 5값 전수 — fresh: 전제 하나: expect(fresh.rows.map((OnboardingStep r) => r.state).toSet(), StepState.values.toSet()); // pre → i 마다 tester.widget<Icon>(descendant of o01-row-$i, first Icon) icon·color == wantStep(row.state)(테스트 파일 private switch · 기대 원천 = «화면 1» _stepLook) · ⓡ.
 O01-03 게이트 3상 — fresh: 전제 하나: expect(fresh.rows.where((OnboardingStep r) => r.gate?.state == GateState.unknown), isNotEmpty); // pre → gate non-null 인 행 i 마다 o01-gate-$i 의 Icon icon·color == wantGate(state) · 🔴 unknown 행과 notApplicable 행의 아이콘이 다르다 한 줄 · gate null 행 = o01-gate-$i findsNothing · ⓡ.
 O01-04 행 탭 = detailLink — 두 경우 ㉠ (linked · 첫 detailLink non-null 행 · [link]) · (unlinked · detailLink null 행 · [])마다 — 전제 둘(두 행이 표본에 있다 // pre) → tap(o01-row-$k) → expect(opener.opened, c.want) · ⓡ.
 O01-05 «다음» = finishLink(데이터 · 판정 0) — 두 경우 ㉠ (ready · want [ready.finishLink!]) · (fresh · null)마다 — 전제 둘: expect(ready.finishLink, isNotNull); // pre · expect(fresh.finishLink, isNull); // pre → «없는 쪽» 견본(o01-finish · 양성 기준점 o01-row-0) · 있으면 tap → opener.opened == want · ⓡ.
 O01-06 상태 갈래 — 세 경우(loading · fail · value_then_fail)마다 Key 목록 · CircularProgressIndicator findsNothing.
 O01-07 재시도 — call 0 error → retry → value → o01-fail findsNothing · o01-progress findsOneWidget · repo.listCalls == 2 · ⓡ.
 O01-08 화면 Text 전부 · 큰 글꼴(해외주식·o_00 글자 0 = allowed 밖) — 두 경우(fresh · advisory) → allowed = stepListAllowed(c.v) → textScaleFactorTestValue 2.0 → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = 7줄(O01-01 · 02 · 03 · 04 · 05 · 07 · 08) · ⓗ = 1(O01-01) · (전제) = ⟦실측: 계획 8 — 01 2 · 02 1 · 03 1 · 04 2 · 05 2⟧.
O-02 · O-03 — test/onboarding_step_detail_test.dart(주입 = 따로 적지 않으면 operator · 슬롯 = FakeShellSlotRecorder)
 O02-01 상세 글자·차례 — kisMock: 전제 셋(step · whereText · howText non-null // pre) → repo.stepIds == ['<stepId 인자>'](🔵 인자 = 테스트가 넘긴 글자 · 표본 step.stepId 를 그대로 넘긴다) · 사슬 dy o02-head → o02-where → o02-how → o02-secret → o03-run · 글자 = shownTexts · ⓡ.
 O02-02 모르는 id = missingLabel 값(에러 아님) — missingV: 전제 둘 → o02-missing 글자 == [missingLabel] · o02-head · o03-run · o02-fail findsNothing · ⓡ.
 O02-03 시크릿 자리 = 슬롯 빌더(SecretField 삽입만) — 세 경우 ㉠ (slot · kisMock · 빌더 있음 · fake-slot-<id> findsOneWidget · slots.slotIds == [kisMock.secretSlotId!]) · (no_builder · kisMock · 빌더 null · o02-secret findsNothing) · (no_slot · noVerify · 빌더 있음 · o02-secret findsNothing · slotIds == [])마다 ·
        🔴 find.byType(TextField) findsNothing 한 줄(세 경우 모두) · ⓡ.
 O02-04 상태 갈래 — 세 경우(loading · fail · value_then_fail) · O02-05 재시도(구독 · stepIds 두 번 같은 인자) · ⓡ.
 O03-01 검증 버튼 = run(verify.id, verify.args) 1회 — kisMock → tap(o03-run) → pump → expect(actions.ids, [kisMock.verify!.id]) · expect(actions.argsSeen, [kisMock.verify!.args]) · ⓡ.
 O03-02 결과 3상 · 원문 코드 — 세 경우 ㉠ (ok · results[0]) · (fail_retry · results[1]) · (fail_final · results[2])마다 — 전제 셋(reasonCode·retryable 표본 // pre) → tap(o03-run) → pump 두 번 → shownTexts(o03-result) 앞부분 == [r.headline, ?r.reasonCode](«다시 시도» 글자는 따로) · o03-level Icon == wantResult(r.level) · o03-not-accepted findsNothing(🔵 fail_retry 경우는 ⓡ 대신 o03-retry 단언 — retry 글자가 보인다).
 O03-03 «다시 시도» = retryable 데이터 — 두 경우 ㉠ (retryable · results[1] · o03-retry findsOneWidget → tap → actions.ids 두 번) · (final · results[2] · o03-retry findsNothing · actions.ids 한 번)마다.
 O03-04 실패 ↔ 성공 두 방향(C4r14a-5) — R15a O0B-06 꼴(o03-not-accepted ↔ o03-result) · ⓡ.
 O03-05 주입 null(뷰어) = 검증 버튼 부재 · operator 대조(C4r14a-6) — 두 경우(viewer · operator) → o03-run viewer findsNothing / operator findsOneWidget(want ? findsOneWidget : findsNothing 한 꼴) · ⓡ.
 O03-06 화면 Text 전부 · 큰 글꼴 — 두 경우(kisMock · noVerify) → allowed = stepDetailAllowed(c.v, null) → textScaleFactorTestValue 2.0 → takeException isNull · ⓡ.
 ⓡ 기대 = 8줄(O02-01 · 02 · 03 · 05 · O03-01 · 04 · 05 · 06 — 계획) · ⓗ = 0 · (전제) = ⟦실측: 계획 O02-01 3 · O02-02 2 · O03-02 3⟧ — 드라이런이 확정하고 이 줄을 «정확히» 로 고친다.

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(갈래마다 짝):
   (목록) 행 뒤집기 · 행 하나 빼기 · verified 행 거르기 · 해외주식 행 더하기(정적 글자) · progressText 대신 rows 수로 «n/m»(정적·O01-01) · emptyLabel 빼기.
   (판정) warningLabel 대신 requirement·state 로 배지(표본상 동치면 🔵 참고 — 정적 P11 이 requirement 를 잡는다) · gate unknown 을 notApplicable 모양으로 · gate unknown 을 pass 모양으로 · state 아이콘 하나로 고정 · failed 를 verified 색으로 · finishLink 대신 «전부 verified 면 다음».
   (글자) verifiedUntilText 빼기 · verifiedUntil 포맷(정적 P11) · failureText 빼기 · failureReasonCode 빼기 · failureText 대신 정적 글자 · gate.label 빼기 · whereText·howText 빼기.
   (시크릿) 슬롯 빌더 대신 TextField(O02-03 · 정적 P36) · 빌더 null 인데 빈 상자 · slotId 대신 고정 글자 · 시크릿 자리를 검증 버튼 아래로.
   (검증) run 0 · run 두 번 · verify.args 에 키 더하기 · 다른 id · 기다리는 동안 두 번 · 결과 headline 빼기 · reasonCode 빼기 · level 아이콘 고정 · retryable 무시(늘 «다시 시도» · 늘 없음) · 실패 글자 빼기 · 한 칸 초기화 빼기(두 방향) · 주입 null 에도 버튼.
   (링크) 행 탭 0 · detailLink null 에도 탭 · «다음» 탭 0.
   (상태 — 갈래마다 · 두 화면) 에러를 스켈레톤 · 재시도 invalidate 0 · 모르는 id 를 에러 화면으로 · 정적 글자 더하기.
   🔵 참고 — 타입이 막음: «verify 없이 화면이 SettingsActionId 고르기»(검증 id 는 VM 칸 — 화면이 고르면 정적 P07 «SettingsActionId.» 0 이 잡는다) · ⟦실측: 드라이런 변이 표⟧.

■ 정적 묶음 — R15a 꼴 37줄 안팎(머리 «## P01» ~ · 파일로 꺼내 Git Bash · 꺼내기 줄 범위·해시 = ⟦실측: 이 카드가 send/ 로 옮겨질 때 잰다⟧) — 줄과 기대(⬜ 드라이런 실측 전 — 카드 계획):
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
echo "## P11 forbidden words in step files 0"; git grep -nE "stepId\b.*(Key|Text)|verifiedUntil\b|\.requirement\b|\.estimated\b|whereDeepLink|\.track\b|watchSteps\(|OperatingMode|FeatureFlags|runMode|DateTime\.now|DateFormat|Duration\(|toString\(|\.where\(|\.length|\.sort|\.take\(|split\(|RegExp|actionRunId|handoffRoute|AppRoutes|AppLinkSchemes|kIsWeb|Platform\.|dart:io|showDialog|SnackBar|print\(|[Ss]kip" -- lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart; echo "EXIT:$?"
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
echo "## P29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/src/shell_providers.dart lib/l10n/labels.dart lib/src/onboarding/onboarding_start.dart lib/src/onboarding/onboarding_mode_pick.dart lib/src/shell_scaffold.dart lib/src/routing lib/src/common lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml README.md test/golden/golden_support.dart test/golden/README.md test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart; echo "EXIT:$?"
echo "## P30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P31 copyWith in tests 0"; git grep -n "copyWith(" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## P33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## P34 precondition marks (pre)"; git grep -c "// pre$" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart; echo "EXIT:$?"
echo "## P35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart; echo "EXIT:$?"
echo "## P36 secret input widgets in onboarding 0"; git grep -niE "textfield|textformfield|editabletext|obscure|clipboard|keystore|flag_secure|url_launcher|launchUrl" -- lib/src/onboarding; echo "EXIT:$?"
  (줄의 뜻과 기대 — P01·P02 = 출력 없음 · P03 = 5줄(o01_golden 1 · o02_golden 1 · o03_golden 1 · step_detail_test 11 · step_list_test 8) · P04 = 0 · S05 = 2줄(행 탭 · «다음») · P06 = 2줄 · P07 = 0(🔴 검증 id = VM 칸) · P08 = 1줄 ·
   P09 = 14줄(_stepLook 5 · _gateLook 4 · _resultLook 5) · P10 = 1줄(onboarding_step_detail.dart build) · P11 = 0 · P13 = «lib/l10n/labels.dart:37»(R15a 병합본 · 이 카드 0 · 기대 — «정확히» = 마지막 카드) ·
   P14 = 13줄(… src/onboarding/onboarding_mode_pick.dart · onboarding_start.dart · 🆕 onboarding_step_detail.dart · onboarding_step_list.dart · …) · P15 = 18줄(R15a 17 + 슬롯 빌더 1) · P16~P19 = 0 · P20·P21 = ⟦실측⟧(🔴 정확히) · P22 = 이름 = 위 «Key 표» ·
   P23~P27 = 0 · P29 = 세 줄(lib/src/shell_providers.dart · lib/ui_shell.dart · test/shell_fakes.dart — 둘째 수 0) · P30~P32 = 0 · P33 = 10줄 전부 «A» · P34 = ⟦실측⟧(🔴 정확히) · P35 = 0 · P36 = 0)
  (🔵 P12·P28 은 이 카드에 없다(번호 비움 — R15a 의 «선택 비교»·«포커스» 줄 몫 없음) · 이 카드가 send/ 로 옮겨질 때 줄 번호를 이어 매기고 «아래 n줄» 을 실측으로 고친다)

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · golden README «🆕 R15» 절 표 그대로)
  o01 — test/golden/o01_golden_test.dart · 위젯 = OnboardingStepList() · 이름 o01_fresh(fresh · 맨 아래 Key = 마지막 o01-row) · o01_advisory(advisory · 마지막 o01-row) · 머리 Key('o01-progress') dy 0.0 · 🔴 행이 많아 844 를 넘으면 높이를 늘리지 말고 멈춘 뒤 dy 를 질문 파일에(⟦실측: 드라이런 dy⟧ · 넘으면 맨 아래 Key = 화면 안 마지막 행으로 카드가 고친다)
  o02 — test/golden/o02_golden_test.dart · 위젯 = OnboardingStepDetail(stepId: kisMock.step!.stepId) · 이름 o02_step(kisMock · 슬롯 = FakeShellSlotRecorder · 맨 아래 Key('o03-run')) · 머리 Key('o02-head') dy 0.0
  o03 — test/golden/o03_golden_test.dart · 위젯 = 같은 상세 · 흐름 = tap(o03-run) → pump 두 번(🔴 명령 칸 = 공장 SettingsActions Function() 을 testWidgets 안에서 부른다 — 가짜 공유 금지 · C4r5d-5) ·
    이름 o03_ok(results[0] · 맨 아래 Key('o03-result')) · o03_fail_code(results[1] · 맨 아래 Key('o03-retry')) · 머리 Key('o02-head') dy 0.0
  모양·주입·위치 전제 둘·명령 = R15a 골든 절과 같은 글자(_Flow · 흐름 칸 non-null · pumpForGolden · wrapApp ProviderScope · getBottomLeft dy < 844 · getTopLeft 머리 dy 0.0 · --update-goldens 는 파일 지정).

■ 질문 파일 (🔴 새 파일을 만들지 않는다 — 이미 있다)
· O01O03_questions.md — «다음 번호»(Q1·A1)부터 · 행 앞에 «O-01:» · «O-02:» · «O-03:» 접두(골든 «측정:» 행 예외) · 꼭 적을 것: 골든 dy 5행(A1~A5 = o01_fresh · o01_advisory · o02_step · o03_ok · o03_fail_code — R15a 상자 꼴 · 카드ID = R15b-Bob-O01O03).
· 적지 않을 것(카드가 정함): 위젯·Key·파일 이름 · 라벨 0 · 읽지 않는 필드 · 아이콘·색 표 · 슬롯 빌더 꼴 · 골든 이름·입력 · 재량(여백).

■ 제출 — R15a «■ 제출» 과 같은 꼴(파일별 끝 줄 = 시각 머리까지 · 저장 파일 BOM 0 · ① = 파일로 받은 출력 · 채팅 두 줄 · N1 · N3 · 섹션 머리 5줄 · 자체 점검 상자 · 10항 줄 수 · ⓡⓗ 상자 · ③ 견본 · ④ «+» · ⑤ · 시작·끝 상자)
  cd packages/ui_shell
  flutter test test/onboarding_step_list_test.dart     ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +13: All tests passed!»)
  flutter test test/onboarding_step_detail_test.dart   ← 끝 줄 그대로 — 줄 머리 시각까지(기대 «00:0n +21: All tests passed!»)
  flutter test test/golden/o01_golden_test.dart        ← 기대 «00:0n +4: All tests passed!» · o02 ← «+2» · o03 ← «+4»
  flutter test   ← 기대 = 시작 기준 N + 44 — ⟦실측: 237 → «00:nn +281: All tests passed!»⟧
  cd ../.. → check_boundaries(Git Bash 전체 경로) → melos format·analyze·test·test:contracts(domain_contracts ⟦실측⟧) → git status 빈 → name-status 기대(A lib/src/onboarding/onboarding_step_detail.dart · A onboarding_step_list.dart · M lib/src/shell_providers.dart · M lib/ui_shell.dart ·
     A PNG 10 · A test/golden/o01·o02·o03_golden_test.dart · A test/onboarding_step_detail_test.dart · A test/onboarding_step_list_test.dart · M test/shell_fakes.dart · M docs/ai-context/inbox/O01O03_questions.md · 그 밖 = 금지)
  사전검사 ① → git push -u origin ui/m8-o01-steps → ① 출력 파일로 받기($env:TEMP\r15b_ns.txt · r15b_log.txt) → 정적 묶음 → 저장 파일 $env:TEMP\R15b-Bob-O01O03_submit.md(BOM 0)
  사전검사 ② 세 번: --golden-prefix o01_ --goldens 4 · o02_ --goldens 2 · o03_ --goldens 4(출력 파일 r15b_pre2_o01.txt · _o02 · _o03 · 끝 줄 셋을 « / » 로 이은 한 줄 = 채팅 둘째 줄)
  PR 제목: [M8] O-01~O-03 단계 목록·상세·검증 · 🔴 채팅 답 = 두 줄뿐: «R15b-Bob-O01O03 제출 글 저장했음: <경로>» · 사전검사 ② 끝 줄 셋.
   ① 머리 복사 상자 글자: «화면 ID: O-01 — 단계 목록(OnboardingStepList()) · O-02 — 단계 상세(OnboardingStepDetail(stepId:)) · O-03 — 검증 결과(O-02 안 결과 조각) · 주입 shellOnboardingSlotBuilderProvider»
   ② 붙일 괄호: 1번 «정적 묶음 P16 — 허용 밖 import 0줄 · pubspec 무변경(P29)» · 2번 «산술 = null 여부 · 열거 switch 셋(P09) · 표시 상태뿐 · 거르기·정렬·세기 0(P11) · 진행률 = progressText 그대로 · 금지 수치 P18 0건» ·
     3번 «DateTime.now 0(P11) · 만료 = verifiedUntilText 그대로 · verifiedUntil 포맷 0(P11)» · 4번 «이 카드 범위 밖(5탭·홈·F-01) · 손익 0» · 5번 «이 카드 범위 밖(알림 = R14)» · 6번 «이 카드 범위 밖(DND UI = M9)» · 7번 «이 카드 범위 밖(워치독 = R14b)» ·
     8번 «시크릿 = 슬롯 빌더 삽입만(O02-03 · P10) · TextField·클립보드·마스킹 0(P36)» · 9번 «건너뛰기·해외주식 0(P11 · P23 · O01-08) · 실패 문구 = failureText + 원문 코드 · 결과 = headline + reasonCode 원문(O03-02)» · 10번 «삽입 자리 직접 구현 0(SecretField = 슬롯 · P36) · 킬스위치 진입 = 셸 몫(무수정 P29)»
   ③ 견본 = «목록 정상» · «목록 빈» · «목록 로딩·에러» · «상세 정상» · «상세 모르는 id» · «상세 결과(성공·실패)» · «상세 로딩·에러» 7줄(R15a ③ 꼴 · Key 이름 나열 · ⟦실측: 드라이런이 글자를 짓는다⟧) + 골든 표 10행(입력 = 파일 이름만 · 셈 단위 견본 = ⟦실측⟧).
   (+ flutter test 한 줄 — 시작·끝 상자 글자 틀 그대로(기대 M = N + 44))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-o01-steps` 푸시 1건 · 커밋 권장 4개 · (4) 뒤 = (5) 하나만.
- `lib/` 새 파일 **2**(`src/onboarding/onboarding_step_list.dart` · `onboarding_step_detail.dart`) · 수정 2(`shell_providers.dart` 끝 절 1 · `ui_shell.dart` export 2 · 더하기만) · 라벨·셸·R13·R14·R15a 파일 변경 0.
- `test/` 새 파일 5(두 테스트 · 골든 세 파일) + 수정 1(`shell_fakes.dart` 끝 절) + 새 PNG 10 · 재생성 0.
- 질문 파일 `O01O03_questions.md`(A1~A5 «측정:»).
- `flutter test` = 시작 기준 N(R15a 병합본 · 기대 237) + 44 · 정적 P13 = 37 · P14 = 13 · P15 = 18 · P09 = 14 · P33 = 10 A · P20·P21·P34 = ⟦실측⟧(🔴 정확히).
- 재분할 임계: 줄 22 · lib ⟦실측⟧ · PNG 10 · 원천 3 → 재분할 없음.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15b-Bob-O01O03 결과: 브랜치 ui/m8-o01-steps 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R15b-Bob-O01O03_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계에서 멈췄다면 `R15b-Bob-O01O03 0단계에서 멈춤 — 확인해줘` + 출력.

## 5. 주의

- **5분 눈 검사**: ① 셸·R15a 파일·`labels.dart`·기존 테스트·PNG 가 `M` ② 새 lib 파일에 `TextField`·`Clipboard`·`obscure`·`verifiedUntil`·`.requirement`·`.estimated`·`whereDeepLink`·`stepId` 를 Key/글자로·`SettingsActionId.`·`'aaq://`·`AppRoutes` ③ 권장 미통과 배지를 화면이 짓기 ④ gate unknown = notApplicable 모양 ⑤ «다음» 을 finishLink 없이 ⑥ 결과를 level 로 숨김 · retryable 무시 ⑦ 슬롯 빌더 null 인데 자리.
- 🔵 `golden:approved` 불필요(새 PNG 만). 🔵 R15c 의 서약문·생체·셀프테스트·체크섬 자리도 이 카드의 슬롯 빌더를 쓴다(⑦ 확정 시).
- ⬜ 남은 표식 = 실측 표식(꺾쇠 U+27E6 으로 여는 자리 · 셈 = `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R15b-Bob-O01O03.md`) + 자리표시자 `__R15A_SQ__` · `__R15A_PR__` — R15a 병합 기록 · v1.16 병합 기록 · 드라이런 때 채운다 · 🔴 보내기 전 표식 0 · 자리표시자 0.
- 범위 고지: 01 §8 미결 91·144(셸 스캔 제외 — 이 카드 정적 묶음이 메운다) · 137·143(늘 push — O-01 ↔ O-02 가 쌓인다) · 🆕 v1.16 미결 후보 = `whereDeepLink` 뜻(⑧) · 외부 URL 열기 경로(플랫폼) · 슬롯 빌더 꼴(⑦) · 갈래 목록 원천(`onboarding_choice` → 엔진) — 이 카드가 닫지 않는다.

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
| 공통 교훈(R5·R13·R14) | 머리 «교훈 반영» 줄 | — |
