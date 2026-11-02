# 발송 패킷 R15c-Bob-O04 — O-04 마무리 6단계 (계약 v1.16 전제 · R15 4장 중 3번째 · M8)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-02 조립 · 2026-11-03 드라이런·지적 반영 · 앱 `rec/r15`) · 선행 = ① R15b 병합(squash `__R15B_SQ__` · PR `__R15B_PR__` · 시작 기준 N = R15b 병합본 실측) ② 🔴 **계약 v1.16 보강 R15c 몫(G15~G17 — 아래 «■ 계약 v1.16 이름표» · 🆕 단계 칸 `link` · 완료 체크 `checks` · ⬜ 발주자 결정 · ▶ 금지)** ③ 🔴 **01 §8 미결 120·§8-32 결정**(시작 상태 선언 = L-3 재사용 경로 · `SelfReportForm` 서명 · C-46 ⑱ `SelfReportPurpose` 예외 · 🆕 두 갈래 다 선언이 선행 — 자동 매매 = 금액 1칸(가상 초기금) · 투자 안내 = L-3 폼 · 금액 1칸 위젯 소유 M8 vs M5 — «R15 창이 연다» · ⬜ 발주자 결정) ④ 🔴 **🔒 자리 꼴**(M5 서약문 3문장 · M5 생체 서명 · M9 골든벡터 셀프테스트 버튼 · 복구 카드 체크섬 입력 — 실물 0 · 권고 = R15b 슬롯 빌더 · 🆕 체크섬 입력 = 04 §9-5 소유 «당신» 과 갈림 · ⬜ 발주자 확인 ③) ⑤ ✅ 누적 드라이런 3번째(아래 «드라이런» 줄 · 🔴 지적 반영으로 «3» 글자가 바뀌었다 — v1.16 실물 위 재드라이런이 수를 다시 잰다) ⑥ ⬜ 발주자 확인 ①~⑪ ⑦ ⬜ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R15a·R15b 브랜치는 건드리지 않는다. 🔵 R15d 를 후순위로 미루면(R15a 확인 ①) 이 카드가 «정확히 N» 을 소유한다(아래 «정적 묶음» Q13~Q15 · Q33 을 «정확히» 로 고친다).
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(🔀 4분할) + §3-0 + §3 공통 조문 + 이월 부록 «R15» 대상(R15a «6» 과 같은 표 · O-04 자리) · 화면 몫 원본 = `04_…` §9-5(`O-04` · 6단계 표 · 단계 6 «committed_at 같은 트랜잭션» · 기대치 한 줄 · 금 상한 config · 복구 카드 · 운영 램프 L1 · 종착 갈래 · 시작 상태 선언(두 갈래) · 완료 체크(X3) = 체크리스트 · 판정 서버 · 체험 완료 기준 = 이 화면 밖 · 그림 20·26) · §9-8 · §3-3(완료 직후 = `simInternal` · 모드 선택 컨트롤 0) · §11-8·9·12 · `01_…` §8-23 ✅ · §8 미결 120·32 · §9-1 · 06 `M5-8`(서약문) · 판독 메모 §5-1 G15~G17 · §5-2.
> 사전 조건 — ⬜ **R15b 병합**(PR `__R15B_PR__` squash `__R15B_SQ__` · `ui_shell` = lib 16파일 · 라벨 37 · 배럴 13 · 주입 18 · PNG 58 — 병합본 실측으로 채움) · ⬜ 계약 v1.16 R15c 몫 · ⬜ 미결 120·32 결정. 시작 기준 = **⟦실측: R15b 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 286(R15b 지적 반영판 실측 · 첫 판 281)⟧** · 끝 기대 = N + **29**(뷰 25 = `onboarding_finish_test` · 골든 4 = `o04_*` · 🆕 첫 판 27 → 지적 반영 +2 = O04-08 두 경우(`auto_ready` · `auto_declared`)) · 끝 = ⟦실측: 앞 카드 병합 기록 때 채움 — 드라이런 기대 «+315»(첫 판 실측 281 → «+308»)⟧.
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **14**(`onboarding_finish_test` 13 · 골든 1 — 드라이런 실측) · lib **+251**(드라이런 첫 판 · `onboarding_finish.dart` 250 · `ui_shell.dart` +1 · 🆕 단계 링크·완료 체크 줄로 조금 는다) · 새 PNG **4** · 원천·쓰기 **2**(`watchFinish` · `run(action.id)`) → 임계 안.
> 카드 기본값(⬜ 발주자 확인 ①~⑪): ⓐ 위젯 = `OnboardingFinish({super.key})`(`lib/src/onboarding/onboarding_finish.dart` · `ConsumerStatefulWidget` — `_busy`·`_failed`·`_result`) ⓑ 셸·R15a·R15b 파일 무변경 ⓒ 원천 = 🆕 `watchFinish()` → `OnboardingFinishVm` · 쓰기 = VM 이 준 단계 동작 `run(action.id, args: action.args)`(⑥ DRY_RUN 시작 — `committed_at` 같은 트랜잭션 = 엔진 · 화면 관여 0) · 주입 = R15a `shellOnboardingActionsProvider` · 🔒 자리 = R15b `shellOnboardingSlotBuilderProvider`(새 주입 0) ⓓ 6단계 = 받은 차례 그대로(순서 고정 · 건너뛰기 0 · «n/6» 0) · 단계마다 제목 + 상태 아이콘(`StepState`) + 게이트(`GateBadge?`) + 엔진 글자 줄(`lines`) + 기대치 한 줄(`expectationLine?` — ① · 없으면 줄 0) + 🔒 자리(`slotId?` — 열린 단계만 · 닫힌 단계 = null) + 🆕 단계 링크(`link?` — ⑥ 시작 상태 선언 · 선언 뒤 null) + 동작 버튼(`action?` — 앞 단계 미통과·선언 전 = 엔진이 null = 버튼 부재) ⓔ 🆕 시작 상태 선언 = ⑥ 단계 칸 링크(두 갈래 — 자동 매매 = 가상 초기금 1칸 · 투자 안내 = L-3 재사용 · 조립 앱 라우트 — `ui_shell` 은 `ui_journal` import 0) · 선언 전 ⑥ 동작 = 엔진이 null ⓕ 완료 = `doneLabel?`(모의투자 진입 문장 · 엔진) + 🆕 완료 체크 줄(`checks` — X3 배관 점검 · 줄마다 상태 아이콘 + 엔진 글자 · 판정 = 서버 · 세기·비율 0) · 모드 선택 컨트롤 0 · 실전 시작 버튼 0 ⓖ 🔴 숫자·문구 리터럴 0(금 상한 8% · 10.2·9.7·10.4 · 배분 20/42 · L1) · 복구 카드 = 글자 줄 + 체크섬 🔒 자리 — PDF·공유·인쇄·복사·스크린샷 버튼 0 · anon key 0(엔진 몫) ⓗ 새 lib 파일 1 · 공용 2(배럴 +1 · `test/shell_fakes.dart` 끝 절) · 라벨·주입 0 · Key 접두 `o04-` · 골든 2이름 4장(`o04_auto` · `o04_advisory` — 🆕 입력 = 준비 끝 표본).
> 🔴 **카드 덮개 필수 문장(04 §9-5 · §9-8 · §3-3 · §11-8·9·12 · prompt_M8 145~150·158~162)** — «6단계는 순서 고정 — 건너뛰기·«나중에»·«n/6» 게이지 0 · 단계 열림은 엔진(자리·링크·동작 null = 부재)» · «서약문·생체 서명·셀프테스트 버튼·체크섬 입력 = 🔒 자리만(프리필 0 · 예시 문장 0 · 자체 입력 0)» · «수치·문구는 엔진 글자 — 금 상한·배분·config_hash·기대치·운영 램프·종착 조합 리터럴 0 · 기대치 값이 없으면 그 줄 0 · `PerformanceSeries`·`PerfDisclosure` 참조 0» · «DRY_RUN 시작 = VM 동작 1회(`committed_at` 같은 트랜잭션 = 엔진) · 모드 선택·실전 시작 0 · 두 갈래 다 시작 상태 선언(⑥ 단계 링크) 없이 시작 0(엔진이 동작을 주지 않는다)» · «완료 체크 = 서버 판정 글자·상태 그대로(세기·비율 0) · 체험 완료 기준 8항목 = 이 화면 0» · «복구 카드 PDF·공유·스크린샷 0» · «셸·R15a·R15b 파일·테스트·PNG 무변경».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 01 §8-23 ✅(`committed_at` = 6단계 같은 트랜잭션) · §9-1(완료 직후 `simInternal`) · 00 §7 용어(OpsRamp ≠ EntryRamp) · 청사진 §9-1b ⑧(복구 카드 = 손글씨 전사 + 체크섬 · PDF 반대).
> ⬜ **발주자 확인 11건(권고 = 카드 기본값 · 🆕 2026-11-03 지적으로 ①③⑤⑧⑨⑩ 를 고쳤다)** — ① 원천 = 🆕 `watchFinish()` → `OnboardingFinishVm{headline, stages(6), doneLabel?, checks}` · 단계 = 🆕 `OnboardingFinishStage{title, state, gate?, lines, expectationLine?, slotId?, link?, action?}`(04 §9-5 의 ⚠️ `expectationLine?` M2-8 = 이 칸 · 🆕 `link` = ⑥ 시작 상태 선언 — 조립 판의 VM 칸 `openingDeclare` 를 단계 칸으로 옮겼다: 04 §9-5 «이 단계 진입 전에 선언» 자리를 화면이 순번으로 고르지 않게 · 명세 지적) · 🆕 완료 체크 = `checks: List<OnboardingFinishCheck{label, state: StepState}>`(04 §9-5 «완료 체크(X3) — 체크리스트로 보이되 판정은 전부 서버» · 그림 20 `CHK` · 그림 26 · DRY_RUN 시작 전 = 빈 목록 · 명세 지적 — 조립 판은 X3 5항목을 «이 화면에 그리지 않는다» 로 잘못 읽었다) · 지금 표본 `m8/onboarding_finish`(단계 7행 + 묶이지 않은 `finish_headline`)는 쓰지 않는다 ② 단계 열림 = 엔진(앞 단계 미통과 → `slotId`·`link`·`action` null · `gate` 로 이유) — 화면이 `state` 로 다음 단계를 열지 않는다(🆕 정적 Q37 «state 비교 0» — 드라이런 M04a) ③ 🔒 자리 = R15b 슬롯 빌더(`slotId` 4종 — ② 서약문 M5 · ③ 생체 M5 · ④ 셀프테스트 버튼 M9 · ⑤ 체크섬 입력) · 체크섬 입력 소유 = ⟦v1.16⟧(권고 = M9 입력 위젯 자리 — M8 `TextField` 0 · 🔴 명세 지적: 04 §9-5 표 5행은 소유 «당신»(M8 — «손글씨 전사 화면 + 체크섬 확인 입력»)이라 권고와 갈린다 → 권고를 고르면 04 §9-5 소유 칸 정정 + 06 M9 작업 항목(체크섬 입력 위젯)이 선행 · 대안(04 를 따르는 쪽) = M8 이 `TextField` 1칸(값 = `action.args` 로만 · 저장·검증 = 엔진 · 비밀 아님 · 그래도 `FLAG_SECURE` 라우트 안)) ④ DRY_RUN 동작 id = ⟦v1.16 G17⟧(권고 = 새 `SettingsActionId.onboardingDryRunStart` — `runtimeEngineStart` 와 뜻이 다르다(첫 `committed_at` · 되돌림 묶음) · 결과 표본 2 = [0] 접수(reasonCode null) · [1] 되돌림 실패(reasonCode = 사전 등재 원문 코드 · retryable false)) ⑤ 🔴 시작 상태 선언 = ⑥ 단계 `link{label, link}`(🆕 `OnboardingLinkAction` — R15d 분기 버튼도 같은 타입) → 두 갈래 다 선행(🆕 04 §9-5 — 자동 매매 = «금액 1칸(가상 초기금, 기본값 없음)» · 투자 안내 = L-3 `SelfReportForm` 재사용 · 둘 다 `SelfReportPurpose.simOpening` · 명세 지적 — 조립 판은 자동 매매 갈래에 선언 길이 없었다) · 01 §8 미결 120: 서명 확장 `yyyyMm`·`accountAlias` nullable 또는 `purpose` 인자 · C-46 ⑱ `simOpening` 예외 · 라우트 = v1.16 · 금액 1칸 위젯 소유 = ⟦미결 32 — 권고 M5⟧ · 이 카드 = 링크 하나 ⑥ 기대치 한 줄 = `expectationLine?`(① 단계만 · null = 줄 0 · 숫자 리터럴 0) ⑦ 운영 램프 L1 · 종착 조합(`simInternal × autoTrade|advisory × execute`) = ⑥ 단계 `lines` 엔진 글자(«운영 램프» 접두가 붙은 문자열 · «n/6» 0) ⑧ 완료 = `doneLabel?` 한 줄 + 🆕 완료 체크 줄(`checks` · 상태 아이콘 = `_stepLook` · 글자 = `label`) · 모드 선택·실전 시작·체험 완료 기준 8항목 = 이 화면 0(M5·M9 — 04 §9-5 «두 게이트는 다른 것») ⑨ 복구 카드 = ⑤ 단계 `lines`(프로젝트 ref · 계정 이메일 · repo 주소 · 복구 코드 — 엔진 글자) + 체크섬 🔒 자리 · 🆕 `FLAG_SECURE` = `O-04` 라우트 전체(복구 코드가 본문 글자 줄이다 · 진입/이탈 = 플랫폼 몫 · 명세 지적) · PDF·공유·인쇄·복사·스크린샷 0 ⑩ 골든 2이름 4장(`o04_auto` · `o04_advisory` — 04 에 이름 없음 · 카드가 지음 · 🆕 입력 = 준비 끝 표본(`m8/onboarding_finish_auto_declared` · `m8/onboarding_finish_advisory`) — 조립 판 입력(6단계 자리 전부 열림)은 844 를 넘어 맨 아래 Key 를 `o04-stage-4` 로 올리면 두 PNG 가 바이트까지 같아졌다(드라이런 blocker) · 대안 = 이름 하나(2장) 또는 흐름으로 끝까지 끌기) ⑪ 이월 반영(«6»).
> 🚫 **플랫폼 몫 = 화면 밖** — 생체인증(③ — M5 위젯 안) · `FLAG_SECURE`(🆕 `O-04` 라우트 전체) · Keystore · 첫 실행 판정 해제(완료 뒤 셸 진입 = 조립 앱) · 이 카드 = 자리·링크·엔진 글자만.
> 드라이런: ✅ 누적 드라이런 3번째(2026-11-03 · 첫 판 가지 `dry/r15-3` = R15b 드라이런 끝 `66ffe93` → R15b 병합 기록 흉내 `ce088ec` → v1.16 R15c 몫 흉내 `aa2dd46`(조립 판 이름표 — VM 칸 `openingDeclare` · 픽스처 6 · `onboardingDryRunStart`) → 권장 4커밋 `18b5c16`·`9b3411f`·`639c860`·`20e6a60` · 🆕 지적 반영 확인 가지 `dry/r15-3b` = + `3d0dd3f`(골든 입력 = 준비 끝 표본 2 · 맨 아래 Key `o04-action-5` 752.0 · VM 칸 선언 `o04-declare` 772.0 · 두 PNG 다름)) · 첫 판 시작 «+281» → 끝 «+308»(`onboarding_finish_test` +23 · `o04_golden` +4) · 정적 34줄(요지로 지은 판 — 출력 144줄 · EXIT:1 18 · EXIT:0 16 · Q18 은 레이아웃 정수를 잡아 판정 줄 구실을 못 했다) · 사전검사 ① 🔴 0 · 🟡 0 · ② `o04_` 🟡 4(G1 — 첫 판 입력) · lib +251 · ⓡ 12 · ⓗ 1 · (전제) 14 · 막힌 곳 3(골든 844 초과 → 두 PNG 같음 · 정적 요지판 · `StepState` 이름 충돌) · 변이 44꼴(예고 29 · 참고 13 · 테스트 쪽 2) = KILLED 43 · SURVIVED 1(M04a «이 단계가 verified 면 버튼 막기» — 표본에서 동작이 있는 ⑥ 이 늘 NOT_STARTED 라 동치) → 🆕 정적 Q37(state 비교 0)이 잡는다(반영 가지에서 grep 확인 — 원본 EXIT:1 · 변이 EXIT:0) · 🔵 지적 반영(단계 링크 · 완료 체크 · 표본 8)은 v1.16 이름표가 바뀌는 몫이라 v1.16 실물 위 재드라이런이 확인한다.
> 프롬프트 = `prompt_M8.md`(v2 판 183줄 · 🔴 160행 «온보딩 5단계» = 낡은 글자 → 6단계(«이긴다» ⑮)). 🔴 Bob **새 대화** 전제.
> 교훈 반영: R15a 카드 머리 «교훈 반영» 줄과 같다(PNG 열람 2장) · ⟦펼침: send/ 승격 때 R15a 머리 «교훈 반영» 줄 글자 그대로 — 감사 지적⟧.

## 0. 한 줄 목적

`OnboardingFinish()` 가 `watchFinish()` 의 `OnboardingFinishVm` — 엔진이 차례·열림을 정한 6단계(P0S 확인 · 서약문 · 생체 · 셀프테스트 · 복구 카드 · DRY_RUN) — 를 받은 차례·글자 그대로 그리고(숫자·문구 리터럴 0 · 기대치는 값이 있을 때만 한 줄), 🔒 자리는 주입 슬롯에만 맡기며, 엔진이 준 단계 동작만 `run(id, args)` 한 번으로 부르고, 시작 상태 선언은 ⑥ 단계 링크로만 넘기며, 완료 뒤 서버가 판정한 완료 체크 줄을 그대로 보이는 `O-04` 를 계약 v1.16 그대로 짓기(건너뛰기·모드 선택·실전 시작 0).

## 1. 어디에 보내나

**IBM Bob** — 새 브랜치 **`ui/m8-o04-finish`**(base = 최신 `origin/main` · `--no-track`) · PR 제목 = «[M8] O-04 온보딩 마무리».

## 2. 보내기 전에 발주자가 할 것 🔴

1. 이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다(지금 `_대기/`). 2. Bob **새 대화**. 3. GitHub `main` 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R15c-Bob-O04.md>. 4. «3» 본문 전부. 5. 🔴 `_완료/R15a*`·`R15b*` · `_대기/R15d-Bob-R01V01.md` 를 붙여넣지 않습니다. 6. 받는 법 = R15a 와 같다(`$env:TEMP\R15c-Bob-O04_submit.md` · BOM 0 · 채팅 두 줄). 7. `flutter_tester` 를 직접 끝내지 마세요.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R15c-Bob-O04 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R15c-Bob-O04 — 범위: O-04 온보딩 마무리(OnboardingFinish() — 머리 · 6단계(제목 · 상태 · 게이트 · 엔진 글자 줄 · 기대치 한 줄 · 🔒 자리 · 단계 링크 · 단계 동작) · 결과 줄 · 완료 문장 · 완료 체크 줄) + 배럴 export 1줄 + 가짜 끝 절.
🔴 6단계 = 받은 차례 · 순서 고정 · 건너뛰기·«나중에»·«n/6» 0 · 단계 열림 = 엔진(slotId · link · action null = 부재 · state 로 열지 않는다).
🔴 서약문·생체·셀프테스트 버튼·체크섬 입력 = 🔒 자리(슬롯 빌더)만 — 프리필·예시 문장·자체 입력 0.
🔴 수치·문구 = 엔진 글자 — 금 상한·배분·config_hash·기대치·운영 램프·종착 조합 리터럴 0 · 기대치 값 없으면 줄 0 · PerformanceSeries·PerfDisclosure 0.
🔴 DRY_RUN = VM 동작 run(id, args) 1회(committed_at 같은 트랜잭션 = 엔진) · 모드 선택·실전 시작 0 · 시작 상태 선언 = ⑥ 단계 링크(두 갈래) — 선언 전 DRY_RUN 동작은 엔진이 주지 않는다.
🔴 완료 체크 = 서버 판정(상태 아이콘 + 엔진 글자) 그대로 — 세기·비율·«n/5» 0 · 체험 완료 기준 목록 0.
🔴 복구 카드 = 글자 줄 + 체크섬 자리 — PDF·공유·인쇄·복사·스크린샷 버튼 0.
🔴 셸·R15a·R15b 파일(onboarding_start · onboarding_mode_pick · onboarding_step_list · onboarding_step_detail · shell_providers 기존 줄)·테스트·PNG 무변경.
하지 않는 것: O-00~O-03(병합됨) · R-01·V-01(R15d) · L-3 폼·금액 1칸(ui_journal·M5 — import 0 · 링크만) · 체험 완료 기준 목록 · 실전 전환(M9 → M5) · FLAG_SECURE · 생체 · 새 주입 · 새 라벨 · domain_contracts·pubspec 수정.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 16항).

■ 0단계 — 대상 확인
이 카드는 R15a·R15b(병합됨)가 아닙니다. 지금 코드에는 packages/ui_shell/lib/src/onboarding/onboarding_finish.dart 가 없습니다.
  git branch --show-current · git status --short(빈) · git fetch origin --prune · git checkout --no-track -b ui/m8-o04-finish origin/main   ← 🔴 git checkout main 금지
  git grep -c "contractVersion = '1.16" -- packages/domain_contracts/lib/src/contract_version.dart   ← ⟦실측: v1.16(또는 v1.16.x) 병합본 «…:1» — 🆕 감사 지적(R15a·R15b 꼴)⟧
  git grep -c "Stream<OnboardingFinishVm> watchFinish();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart   ← «…:1»(v1.16)
  git grep -c "Stream<OnboardingFinishVm> watchFinish()" -- packages/domain_contracts/lib/testing.dart   ← «…:1»(v1.16 받침대 UnimplementedOnboardingRepository · 🆕 감사 지적)
  git grep -c "abstract class OnboardingFinishVm" -- packages/domain_contracts/lib/src/dto/safety.dart                         ← ⟦v1.16 파일⟧ «…:1»
  git grep -c "abstract class OnboardingFinishStage" -- packages/domain_contracts/lib/src/dto/safety.dart                      ← ⟦v1.16⟧ «…:1»
  git grep -c "abstract class OnboardingFinishCheck" -- packages/domain_contracts/lib/src/dto/safety.dart                      ← ⟦v1.16 · 🆕 완료 체크⟧ «…:1»
  git grep -c "abstract class OnboardingLinkAction" -- packages/domain_contracts/lib/src/dto/safety.dart                       ← ⟦v1.16⟧ «…:1»
  git grep -c "String? expectationLine," -- packages/domain_contracts/lib/src/dto/safety.dart                                 ← ⟦v1.16⟧ «…:1»
  git grep -c "OnboardingLinkAction? link," -- packages/domain_contracts/lib/src/dto/safety.dart                              ← ⟦v1.16 · 🆕 단계 링크⟧ «…:1»
  git grep -c "static const String m8OnboardingFinishAuto =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart  ← «…:1»(v1.16)
  git grep -c "static const String m8OnboardingFinishResults =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart  ← «…:1»(v1.16)
  git grep -c "final Provider<ShellSlotBuilder?> shellOnboardingSlotBuilderProvider" -- packages/ui_shell/lib/src/shell_providers.dart  ← «…:1»(R15b 병합)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                          ← «…:1»
  ls docs/ai-context/send/R15c-Bob-O04.md · ls docs/ai-context/inbox/O04_questions.md · ls packages/domain_contracts/fixtures/m8/onboarding_finish_auto.json · _auto_ready.json · _auto_declared.json · _advisory.json · _advisory_declared.json · _no_expectation.json · _done.json · _results.json   ← 전부 보여야 함(한 줄에 하나 · ⟦v1.16 표본 이름⟧)
  반대(없어야 함): ls packages/ui_shell/lib/src/onboarding/onboarding_finish.dart · git grep -c OnboardingFinish -- packages/ui_shell/lib
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 ⟦실측: 앞 카드 병합 기록 때 채움 — R15b 병합본 «+286: All tests passed!»(드라이런 기대)⟧ → cd ../..

■ 계약 v1.16 이름표 — R15c 몫(🔴 코드가 정본 · ⟦v1.16⟧ = 보강 PR 글자로 병합 기록 때 고침)
  🆕 OnboardingFinishVm({required String headline, required List<OnboardingFinishStage> stages, String? doneLabel, required List<OnboardingFinishCheck> checks})
       — stages = 6(엔진 차례 · 순서 고정) · doneLabel = DRY_RUN 시작 뒤 문장(모의투자 진입 · null = 아직) · checks = 완료 체크(X3 배관 점검 — 전 키 1회 호출 · 워치독 첫 핑 · 체크 active · GitHub 첫 커밋 · FGS 생존 · 판정 = 서버 · DRY_RUN 시작 전 = 빈 목록)
  🆕 OnboardingFinishStage({required String title, required StepState state, GateBadge? gate, required List<String> lines, String? expectationLine, String? slotId, OnboardingLinkAction? link, OnboardingVerifyAction? action})
       — lines = 엔진 글자 줄(① 배분·금 상한(config)·config_hash · ④ 셀프테스트 «통과 n/전체 n» · ⑤ 복구 카드 4칸 · ⑥ 운영 램프 L1·종착 조합) · expectationLine = ① 정직한 기대치 한 줄(값 없으면 null) ·
         slotId = 🔒 자리 이름(② 서약문 · ③ 생체 · ④ 셀프테스트 버튼 · ⑤ 체크섬 입력 — 열린 단계만 · 닫힌·끝난 단계 = null) · link = ⑥ 시작 상태 선언(두 갈래 · 선언 뒤 = null) · action = 단계 동작(⑥ DRY_RUN 시작 등 · 앞 단계 미통과·선언 전 = null — 엔진 판정)
  🆕 OnboardingFinishCheck({required String label, required StepState state}) — 완료 체크 한 줄(글자 + 상태 · 판정 = 서버)
  🆕 OnboardingLinkAction({required String label, required String link}) — 글자 + 링크(엔진이 완성)
  OnboardingVerifyAction(R15b) · ActionResult(기존) · SettingsActionId ⟦v1.16 G17 — DRY_RUN 시작 id⟧(🔴 이 카드는 id 를 이름으로 쓰지 않는다 — action.id 그대로)
  FixturePaths  m8OnboardingFinishAuto · …AutoReady · …AutoDeclared · …Advisory · …AdvisoryDeclared · …NoExpectation · …Done · …Results(아래 «픽스처»)
  🔵 v1.16 PR 체크(드라이런 지적): 결과 표본 reason_code = C-5 등재 코드 · 링크 표본 = AppRoutes 등록 목적지(C-33 — 선언 = L-3 재사용 라우트 · 가상 초기금 라우트) · `dart format` 0 changed.
  🔴 쓰지 않는 것: m8/onboarding_finish(단계 7행 + finish_headline) · OnboardingStep · watchStepList · PerformanceSeries · PerfDisclosure · FeatureFlags · RunMode · OperatingMode.

■ 규칙 요약 (정본 = 이 카드 · R15a 카드 규칙과 다른 줄만 새로 적고, 같은 줄은 «= R15a 규칙 n» — 그 글자는 docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3» · ⟦펼침: send/ 승격 때 «= R15a» 자리를 R14b 처럼 전부 펼친다 — 감사 지적⟧)
 1 고치는 곳 = packages/ui_shell + inbox/O04_questions.md 만. 새 파일 = lib/src/onboarding/onboarding_finish.dart · test/onboarding_finish_test.dart · test/golden/o04_golden_test.dart · 새 PNG 4.
   공용 2파일 끝 절 더하기만: lib/ui_shell.dart = export 'src/onboarding/onboarding_finish.dart'; 한 줄(자리 = export 'src/alerts/alert_detail.dart'; 바로 뒤 · 정렬 차례 — onboarding_finish < onboarding_mode_pick) · test/shell_fakes.dart 끝 R15c 절.
   고치면 반려: 그 밖 ui_shell 파일 전부(labels.dart · shell_providers.dart 포함) · domain_contracts/** · apps/** · 다른 ui_*.
 2 ⟦펼침: R15a 규칙 2⟧ = R15a 규칙 2(값 = headline · title · lines · expectationLine · gate.label · link.label · action.label · doneLabel · checks[i].label · 결과 headline · reasonCode 원문 · 리터럴 0).
 3 읽지 않는 필드: OnboardingFinishStage 의 slotId(🔴 빌더 인자로만 · 글자 0) · link.link(🔴 open 인자로만) · action 의 id·args(🔴 run 인자로만) · GateBadge.code · blockedReasonCode · ActionResult 의 actionRunId · id · handoffRoute · retryable(⑥ 은 재시도 0 — 다시 누르기 = 같은 동작이 엔진이 줄 때만).
 4 이동 = AppLinkOpener.open(stage.link.link) 하나(단계 링크 탭 콜백 안) · 'aaq://' 리터럴 0 · AppRoutes 0 · 🔴 ui_journal import 0(L-3 = 링크).
 5 산술·판정 0 — 허용 = ⓐ null 여부 ⓑ StepState 5값 · GateState 4값 전수 switch(R15b _stepLook·_gateLook 과 같은 글자 — 공용 모양 함수는 만들지 않는다 · 01 §8 미결 145) ⓒ 단계 동작 버튼 = 주입 non-null ∧ action non-null ∧ !_busy ⓓ 조각 상태 셋 ⓔ 순번.
   🔴 «앞 단계 verified 면 다음 열기»·«이 단계 verified 면 버튼 숨기기»·«n/6»·«i+1 단계» 표기 0 · state 를 == / != 로 비교 0(정적 Q37) · lines 를 고르거나 합치기 0 · expectationLine 대신 다른 줄 0 · checks 세기·비율·«n/5» 0.
 6 switch = StepState 5 · GateState 4(둘뿐 · default 0 · 완료 체크 아이콘도 _stepLook). 7 ⟦펼침: R15a 규칙 7⟧ = R15a 규칙 7. 8 ⟦펼침: R15a 규칙 8⟧ = R15a 규칙 8. 9 새 주입 0 · 데이터 1(_finishProvider) · 주입 = shellOnboardingActionsProvider · shellOnboardingSlotBuilderProvider · shellLinkOpenerProvider.
10 ⟦펼침: R15a 규칙 10 전문⟧ = R15a 규칙 10(경우 for 밖 · 흐름 칸 non-null · name 칸 · 쓰기 조각 두 방향 · 부재 = 데이터는 operator · ⓡ·ⓗ = Q20·Q21 — onboarding_finish_test ⓡ 12 · ⓗ 1 · 🔴 정확히(드라이런 첫 판 실측 · 지적 반영도 testWidgets 줄 그대로) · (전제) = ⟦실측: 재드라이런 — 첫 판 14 · 아래 최소 목록의 경우별 수 합⟧) · 🔒 자리 테스트 = R15b FakeShellSlotRecorder(고치지 않는다 · 새 가짜 0).
11 골든 = 새 PNG o04_* 4장 · 높이 844 고정(🆕 입력 = 준비 끝 표본 — 드라이런 dy 752.0 · 772.0) · 기존 PNG 58장 재생성 0. 12~14 ⟦펼침: R15a 규칙 12~14⟧ = R15a 규칙 12~14.
15 주석 금지 낱말(정적이 센다 · 🔵 R15a 규칙 15 목록과 이 목록을 합친 것이 아니라 이 목록 하나가 정본 — 감사 지적): slotId 를 글자로 · OperatingMode · RunMode · FeatureFlags · PerformanceSeries · PerfDisclosure · DateTime.now · Duration · AppRoutes · ui_journal · SelfReport · TextField · Clipboard · share · print · pdf · screenshot · skip · 건너뛰 · 나중에 · 추천 · 권유 · 자문 · 시그널 · 해외.
🔴 보고 규칙 ⟦펼침: R15a «보고 규칙» 전문⟧ = R15a «보고 규칙»(PNG 열람 2장 · S05 기대 1줄 · 🆕 사전검사 G1 🟡 기대 = ⟦실측: 재드라이런 — 첫 판 o04_ 4(G1 · 표 «글자 24줄» ↔ PNG «글자 22줄» — 아이콘 든 제목 행과 게이트 행을 G1 이 합쳐 읽는다)⟧ · 그대로 · 다시 열지 않음).

■ 프롬프트보다 이 카드가 이긴다 — 16항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 범위 → O-04 ② 113~118행 → 이 카드 = O-04 · O-00~O-03 = R15a·R15b(병합됨) · R-01·V-01 = R15d ③ 12~13행 의존 → 추가 0 ④ 15~19행 링크 = 데이터 → 그대로(stage.link.link)
 ⑤ 20~23행 → 그대로(시계·신선도 0) ⑥ 24~31행 + 04 §2-1 금지 5 → 그대로(복구 카드 내보내기·공유·인쇄 0) ⑦ 32~35행 → 이 카드 라벨 0 ⑧ 36~38행 → 그대로 ⑨ 41~47행 안전 화면 → 그대로(🔒 M5·M9 자리 · 실전 전환 0)
 ⑩ 48~57행 모드 → 그대로(완료 직후 모드 = 엔진 기본값 · 모드 선택 컨트롤 0 · 04 §3-3) ⑪ 68~77행 수치·램프 → 그대로(리터럴 0 · «운영 램프» 접두 엔진 글자 · «n/6» 0)
 ⑫ 106~111행 → inbox/O04_questions.md ⑬ 127~128행 → ui/m8-o04-finish · «[M8] O-04 온보딩 마무리» ⑭ 145~150행 → 그대로(금 상한 8% 리터럴 0 · 복구 카드 PDF·공유·스크린샷 0 · 건너뛰기 0)
 ⑮ 158~162행 → 🔴 «온보딩 1단계의 기대치» = O-04 1단계(P0S 확인)의 expectationLine · «온보딩 5단계의 램프 L1» = 낡은 글자 — 지금 6단계(서약문 신설로 밀림 · 04 §9-5 머리) · 04 §11-9 의 «O-04 5단계» 도 같은 낡음 ⑯ 172~182행 자체 점검 → ■ 제출 ② 상자 + 괄호

■ 먼저 읽을 것 — ① prompt_M8.md ② 04 §9-5(표 · 완료 체크(X3) 불릿 · 그림 20·26) · §9-8 · §3-3 · §11-8·9·12 ③ 01 §8-23 · §8 미결 120·32 · ⟦v1.16 절⟧ ④ domain_contracts — v1.16 dto · repositories/onboarding_repository.dart · testing.dart
 ⑤ ui_shell — lib/src/onboarding/onboarding_step_detail.dart(🔵 R15b 동작·슬롯 꼴 · 읽기만) · test/onboarding_step_detail_test.dart · test/shell_fakes.dart ⑥ ⟦펼침: 승격 때 이 줄을 지운다⟧ docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3»(«= R15a» 글자의 정본) ⑦ inbox/O04_questions.md 머리말

■ 본받지 않는 것
 · 지금 표본 m8/onboarding_finish(단계 7행 · finish_headline) · «체험 완료 기준 8항목» 목록을 이 화면에 그리기(04 §9-5 — 게이트는 M5 · 🆕 «완료 체크(X3) 5항목» 은 이 화면이 그린다 — checks · 둘은 다른 것) · 완료 체크 «n/5»·비율 · 실전 시작·모드 고르기 버튼
 · 서약문 예시 문장·자리 안 Text · 생체 아이콘 버튼을 화면이 직접 · 셀프테스트 «실행» 버튼을 화면이 직접(M9) · 체크섬 TextField(⟦발주자 확인 ③⟧ 전) · 복구 카드 복사·공유·PDF
 · 앞 단계 state 로 다음 단계 버튼 활성 · 이 단계 state 로 버튼 숨기기 · 단계 번호를 화면이 짓기(«1/6» · «단계 n») · 배분 «20% / 42%»·«8%»·«L1» 리터럴 · expectationLine null 인데 다른 글자
 · L-3 폼·금액 1칸을 ui_journal 에서 import·복제 · SelfReportPurpose 를 화면이 고르기 · 선언 링크를 단계 밖(맨 아래)에 · link 없이 선언 버튼

■ 주입 구조 — lib/src/onboarding/onboarding_finish.dart = OnboardingFinish(공개 · ConsumerStatefulWidget) · _finishProvider(StreamProvider<OnboardingFinishVm> · watchFinish()) · _StageBlock(StatelessWidget) · _stepLook · _gateLook(R15b 와 같은 글자) · 배럴 한 줄 ·
  🆕 import 차례 = 'dart:async' → domain_contracts → `import 'package:flutter/material.dart' hide StepState;`(🔴 domain_contracts StepState ↔ flutter Stepper StepState 이름 충돌 — 없으면 analyze ambiguous_import · R15b 드라이런 지적 이월) → flutter_riverpod → ../../l10n/labels.dart → ../common/shell_common.dart → ../routing/shell_router.dart → ../shell_providers.dart · StepState 를 쓰는 테스트도 같은 hide.

■ 호출 표 — 부르는 것: watchFinish() 한 번(재시도 = 한 번 더) · run(stage.action.id, args: stage.action.args)(버튼마다 한 번 · 기다리는 동안 0) · 슬롯 빌더(stage.slotId) · shellLinkOpenerProvider(단계 링크 탭 콜백 안). 부르지 않는 것: watchStepList · watchStep · SettingsActions.watch · 다른 id.

■ 상태 표 — finish  hasError → ShellErrorView(key: const Key('o04-fail'), onRetry: invalidate) · 값 전 → ShellSkeleton(key: const Key('o04-loading')) · 값 → «화면»

■ 화면 (위 → 아래)
 머리    Padding(key: const Key('o04-headline'), …, Text(vm.headline))
 단계    for (final (int i, OnboardingFinishStage st) in vm.stages.indexed) _StageBlock(index: i, stage: st, …) — Padding(key: ValueKey<String>('o04-stage-$i'), Column(start)[
           Row[ Icon(_stepLook) · Expanded(Text(st.title)) ] · (gate) Row(key: ValueKey<String>('o04-gate-$i'))[ Icon(_gateLook) · Flexible(Text(gate.label)) ] · for (line in st.lines) Text(line) ·
           (exp) Text(exp, key 없음 — 단계 Padding 안) · (slotId && builder) Padding(key: ValueKey<String>('o04-slot-$i'), builder(slotId)) ·
           🆕 (link) FilledButton.tonal(key: ValueKey<String>('o04-link-$i'), onPressed: () { ref.read(shellLinkOpenerProvider).open(link.link); }, child: Text(link.label)) ·
           (action && actions && !_busy) FilledButton(key: ValueKey<String>('o04-action-$i'), child: Text(action.label)) ])
 결과    (_failed) Padding(key: const Key('o04-not-accepted'), Text(ShellLabels.onboardingNotAccepted)) · (r) Padding(key: const Key('o04-result'), Column[ Text(r.headline) · (code) Text(code) ])
 완료    (done != null) Padding(key: const Key('o04-done'), Text(done))
 🆕 체크  for (final (int i, OnboardingFinishCheck c) in vm.checks.indexed) Padding(key: ValueKey<String>('o04-check-$i'), Row[ Icon(_stepLook(cs, c.state)) · SizedBox(width: 8) · Expanded(Text(c.label)) ])   (빈 목록 = 아무것도 그리지 않음)
 🔴 단계 블록 사이 «n/6»·진행 막대 0 · 완료 체크 «n/5» 0 · 맨 아래 «실전 시작» 0

■ 픽스처 — ⟦v1.16 표본 이름·글자⟧ · 🆕 2026-11-03 지적 반영(명세 S2·S8 · 드라이런 blocker):
  auto(진행 중 대표 — ① VERIFIED · expectationLine non-null · ② NOT_STARTED · slotId non-null(서약문) · ③~⑤ NOT_STARTED · slotId null(닫힘) · gate 로 이유(block · unknown · notApplicable 각 1) · ⑥ action·link null · checks 빈)
  autoReady(①~⑤ VERIFIED · slotId 전부 null · ⑥ action null · link non-null(가상 초기금 선언)) · autoDeclared(autoReady 의 선언 뒤 — ⑥ action non-null · link null · 🔵 골든 o04_auto)
  advisory(①~⑤ VERIFIED · ⑥ action null · link non-null(L-3 선언) · 🔵 골든 o04_advisory) · declared(advisory 의 선언 뒤 — ⑥ action non-null · link null)
  noExp(auto 와 같고 ① expectationLine null) · done(doneLabel non-null · action·link 전부 null · ⑥ VERIFIED · checks 5(X3 · 상태 섞음 — verified 와 inProgress 이상)) · results(listFixture · [0] 접수 reasonCode null · [1] 되돌림 실패 reasonCode = 등재 원문 코드 · retryable false).

■ Key 표 (o04- 12이름) — o04-loading · o04-fail · o04-headline · o04-stage-$i · o04-gate-$i · o04-slot-$i · o04-link-$i · o04-action-$i · o04-not-accepted · o04-result · o04-done · o04-check-$i

■ 할 일 — (1) lib + 배럴 «[M8] R15c (1) O-04 마무리 화면» (2) fakes 끝 절 + 테스트 «[M8] R15c (2) O-04 테스트» (3) 골든 4장 «[M8] R15c (3) 골든 o04_* 4장» (4) format · 질문(A1~A2 dy) «[M8] R15c (4) format · 질문» · (4) 뒤 (5) 하나만.

■ 정적 라벨 — 0개(«접수되지 않았습니다» = R15a onboardingNotAccepted 재사용).

■ 테스트 최소 목록 — test/onboarding_finish_test.dart(줄 13 · 테스트 25 · ⓡ 12 · ⓗ 1 — 🔴 정확히 · (전제) = ⟦실측: 재드라이런⟧)
 🆕 공통(드라이런 글자 · 이 이름 그대로):
   test/shell_fakes.dart 끝 절 «// ── R15c — O-04 fakes ──»: class FakeShellFinishRepository extends UnimplementedOnboardingRepository { FakeShellFinishRepository({required this.finish}); final Stream<OnboardingFinishVm> Function(int call) finish; int finishCalls = 0; @override watchFinish() → final int call = finishCalls; finishCalls = finishCalls + 1; return finish(call); } ·
     List<Override> finishOverrides({required FakeShellFinishRepository repo, required SettingsActions? actions, required ShellSlotBuilder? slots, required RecordingLinkOpener opener})(4줄) · Future<void> pumpFinish(WidgetTester tester, {required List<Override> overrides})(Size(390, 2400) · R15a pump 꼴) ·
     List<String> stageTexts(OnboardingFinishStage s) => <String>[s.title, ?s.gate?.label, ...s.lines, ?s.expectationLine, ?s.link?.label, ?s.action?.label] · Set<String> finishAllowed(OnboardingFinishVm v, ActionResult? r)(= headline · stages 마다 stageTexts · ?doneLabel · checks 마다 label · ?r?.headline · ?r?.reasonCode · ShellLabels.onboardingNotAccepted)
   테스트 파일 머리 도우미(main() 밖): valueThenFail(R15a 꼴) · wantStep(cs, StepState) · wantGate(cs, GateState)(R15b 글자 사본) · firstIconIn(tester, key)(R15b 글자) · main() 머리 final: auto · autoReady · autoDeclared · advisory · declared · noExp · done · results.
 O04-01 6단계 차례·제목·글자 줄(auto) — ⓗ expect(auto.stages, hasLength(6)) → i 마다 shownTexts(o04-stage-$i) == stageTexts(auto.stages[i]) · 사슬 dy o04-headline → o04-stage-0 → … → o04-stage-5 · o04-check-0 findsNothing(checks 빈) · ⓡ.
 O04-02 기대치 한 줄 = 데이터 — 두 경우(with_line · auto · no_line · noExp) · 전제 둘(auto ① 있음 · noExp ① 없음 // pre) · «없는 쪽» 견본 · ⓡ.
 O04-03 🔒 자리 = 슬롯 빌더 — 두 경우(builder · no_builder · 둘 다 auto) · 전제 둘(expect(auto.stages[1].slotId, isNotNull); // pre · expect(auto.stages[2].slotId, isNull); // pre) → builder: slots.slotIds == auto.stages 의 non-null slotId 차례 · 🆕 i 마다 o04-slot-$i = auto.stages[i].slotId != null ? findsOneWidget : findsNothing(닫힌 단계 = 자리 0 — 명세 S8) ·
        no_builder: i 마다 o04-slot-$i findsNothing · 두 경우 find.byType(TextField) findsNothing · ⓡ.
 O04-04 게이트 3상(unknown ≠ notApplicable · auto) — 전제 둘(unknown 단계 있음 · notApplicable 단계 있음 // pre) → gate non-null 단계마다 o04-gate-$i 첫 Icon icon·color == wantGate(state) · unknown 과 notApplicable 아이콘이 다르다 한 줄 · ⓡ.
 O04-05 단계 동작 = run(action.id, action.args) 1회(autoDeclared ⑥) — 전제 하나(expect(autoDeclared.stages[5].action, isNotNull); // pre) → 🆕 i 마다 o04-action-$i = autoDeclared.stages[i].action != null ? findsOneWidget : findsNothing(드라이런 M04b 류) ·
        공장 = (int call) => Completer<ActionResult>().future → tap(o04-action-5) → pump → expect(actions.ids, <SettingsActionId>[?autoDeclared.stages[5].action?.id]) · expect(actions.argsSeen, <Map<String, String>>[?autoDeclared.stages[5].action?.args]) · 🆕 o04-action-5 findsNothing(기다리는 동안 — 드라이런 M14) · CircularProgressIndicator findsNothing · ⓡ.
 O04-06 결과 줄 — 두 경우(accepted · results[0] · failed_code · results[1]) · 전제 둘(expect(results[0].reasonCode, isNull); // pre · expect(results[1].reasonCode, isNotNull); // pre) → tap → pump 두 번 → shownTexts(o04-result) == <String?>[c.r.headline, ?c.r.reasonCode] · o04-not-accepted findsNothing · ⓡ.
 O04-07 실패 ↔ 성공 두 방향(C4r14a-5 · R15a O0B-06 꼴 · 성공 = results[0] · 실패 = Future.error) · ⓡ.
 O04-08 시작 상태 선언 = ⑥ 단계 링크(두 갈래) — 🆕 네 경우 ㉠ (auto_ready · link 있음 · action 없음) · (advisory · link 있음 · action 없음) · (auto_declared · link 없음 · action 있음) · (declared · link 없음 · action 있음)마다 —
        전제 넷(autoReady·advisory ⑥ link non-null · autoDeclared·declared ⑥ link null // pre) → final OnboardingLinkAction? link = c.v.stages[5].link; if (link != null) { o04-action-5 findsNothing · tap(o04-link-5) → pump → expect(opener.opened, <String>[link.link]); } else { o04-link-5 findsNothing · o04-action-5 findsOneWidget } · ⓡ.
 O04-09 주입 null(뷰어) = 동작 버튼 부재 · operator 대조(autoDeclared) — 두 경우(viewer · operator) → expect(o04-action-5, c.want ? findsOneWidget : findsNothing) · ⓡ.
 O04-10 완료 문장 · 🆕 완료 체크 = 서버 판정(done) — 전제 둘(expect(done.doneLabel, isNotNull); // pre · expect(done.checks, isNotEmpty); // pre) → shownTexts(o04-done) == [done.doneLabel] · i 마다 shownTexts(o04-check-$i) == [done.checks[i].label] · o04-check-$i 첫 Icon icon·color == wantStep(cs, done.checks[i].state) ·
        i 마다(단계 6) o04-action-$i findsNothing · o04-link-$i findsNothing · ⓡ.
 O04-11 상태 갈래 세 경우 · O04-12 재시도 · ⓡ · O04-13 화면 Text 전부 · 큰 글꼴 세 경우(auto · advisory · done — 8%·10.2·20/42·«n/5» 리터럴은 allowed 밖) · ⓡ.
🔴 예고 변이(갈래마다): 단계 뒤집기 · 단계 하나 빼기 · «n/6» 글자 더하기 · 앞 단계 state 로 버튼 열기 · action null 에도 버튼 · expectationLine 빼기 · null 에도 빈 줄 · lines 하나 빼기 · 슬롯 대신 TextField · 빌더 null 인데 상자 · 🆕 닫힌 단계(slotId null)에도 상자 ·
   run 0·두 번 · args 고치기 · 기다리는 동안 두 번 · 결과 headline·code 빼기 · 한 칸 초기화 빼기 · 🆕 단계 링크 탭 0 · 단계 링크를 단계 밖 맨 아래로 · link 있어도 ⑥ 버튼 · 🆕 완료 체크 줄 빼기 · 체크 상태 아이콘 고정 · 체크 줄에 «n/5» 더하기 ·
   주입 null 에도 버튼 · done 빼기 · 모드 선택 버튼 더하기 · 에러를 스켈레톤 · 재시도 invalidate 0 ·
   🔵 참고 — 정적이 잡음: «이 단계가 verified 면 버튼 막기»(드라이런 M04a — 표본상 동치 · Q37 state 비교 0) · 드라이런 변이 표 = 첫 판 44꼴 KILLED 43 · SURVIVED 1(M04a → Q37) — 🆕 단계 링크·완료 체크 변이는 재드라이런이 넣는다.

■ 정적 묶음 — 35줄(머리 «## Q01» ~ «## Q37» · Q12·Q28 비움 — 🆕 드라이런이 요지로 지은 34줄 + Q37 · Q18·Q29 고침) · ⟦펼침: R15a 실행 꼴 6줄 — r15c_static.sh · r15c_static_out.txt · sed -n '<범위>p' · hash-object · Select-String EXIT · Count⟧ · 꺼내기 줄 범위·해시·출력 줄 수 = ⟦실측: send/ 승격 때 잰다 — 드라이런 첫 판(요지판 34줄) = 144줄 · EXIT:1 18 · EXIT:0 16 · 고친 35줄을 첫 판 코드에 돌리면 138줄(EXIT:1 20 · EXIT:0 15 — Q18 0 · Q37 0 · Q29 두 줄)⟧:
echo "## Q01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/onboarding_finish_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## Q02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/onboarding_finish_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## Q03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/onboarding_finish_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## Q04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://|'https?://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q06 source lines (1)"; git grep -nE "watchFinish\(" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q07 action ids in finish file 0"; git grep -nE "SettingsActionId\." -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q08 run calls (1)"; git grep -nE "\.run\(" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q09 StepState GateState arms (5 4)"; git grep -nE "StepState\.(notStarted|inProgress|verified|failed|expired)|GateState\.(pass|block|notApplicable|unknown)" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q10 slot builder lines"; git grep -n "shellOnboardingSlotBuilderProvider" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q11 forbidden words in finish file 0"; git grep -nE "OperatingMode|RunMode|FeatureFlags|PerformanceSeries|PerfDisclosure|ui_journal|SelfReport|DateTime\.now|Duration\(|AppRoutes|toString\(|\.length|\.where\(|\.sort|\.take\(|\.every\(|\.any\(|share|[Pp]df|print\(|Clipboard|TextField|[Ss]kip|actionRunId|handoffRoute|retryable|\.slotId\b.*Text" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q13 shell labels (37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## Q14 barrel exports"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## Q15 shell providers"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## Q16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## Q17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## Q18 figures 0"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])|'[^'\n]*\b(20|42|8)\b" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## Q20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/onboarding_finish_test.dart; echo "EXIT:$?"
echo "## Q21 H lines (hasLength)"; git grep -c "hasLength(" -- test/onboarding_finish_test.dart; echo "EXIT:$?"
echo "## Q22 o04 key names"; git grep -noP "o04-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q23 banned vocabulary in code 0"; git grep -nE "추천|권유|자문|시그널|대부분|건너뛰|나중에|해외" -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
echo "## Q24 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## Q25 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox|LinearProgressIndicator" -- lib; echo "EXIT:$?"
echo "## Q26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## Q27 Scaffold AppBar Navigator in onboarding 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/onboarding; echo "EXIT:$?"
echo "## Q29 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/src/shell_providers.dart lib/l10n/labels.dart lib/src/onboarding/onboarding_start.dart lib/src/onboarding/onboarding_mode_pick.dart lib/src/onboarding/onboarding_step_list.dart lib/src/onboarding/onboarding_step_detail.dart lib/src/shell_scaffold.dart lib/src/routing lib/src/common lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts lib/src/watchdog_board.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/watchdog_board_test.dart test/onboarding_start_test.dart test/onboarding_mode_pick_test.dart test/onboarding_step_list_test.dart test/onboarding_step_detail_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart test/golden/w01_golden_test.dart test/golden/o00_golden_test.dart test/golden/o00b_golden_test.dart test/golden/o01_golden_test.dart test/golden/o02_golden_test.dart test/golden/o03_golden_test.dart; echo "EXIT:$?"
echo "## Q30 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/onboarding_finish_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## Q31 copyWith in tests 0"; git grep -n "copyWith(" -- test/onboarding_finish_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## Q32 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/onboarding_finish_test.dart test/golden/o04_golden_test.dart; echo "EXIT:$?"
echo "## Q33 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## Q34 precondition marks (pre)"; git grep -c "// pre$" -- test/onboarding_finish_test.dart; echo "EXIT:$?"
echo "## Q35 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/onboarding_finish_test.dart; echo "EXIT:$?"
echo "## Q36 input and export widgets in onboarding 0"; git grep -niE "textfield|textformfield|editabletext|clipboard|share|pdf|printing|screenshot|flag_secure|url_launcher|launchUrl" -- lib/src/onboarding; echo "EXIT:$?"
echo "## Q37 state comparisons in finish file 0"; git grep -nE "\.state\s*(==|!=)|(==|!=)\s*StepState\." -- lib/src/onboarding/onboarding_finish.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — Q01·Q02 = 출력 없음 · Q03 = 2줄(«test/golden/o04_golden_test.dart:1» · «test/onboarding_finish_test.dart:13») · Q04 = 0 · S05 = 1줄(단계 링크 탭 콜백 안) · Q06 = 1 · Q07 = 0 · Q08 = 1 · Q09 = 9줄(StepState 5 · GateState 4) · Q10 = 1줄 ·
   Q11 = 0 · Q13 = «lib/l10n/labels.dart:37» · Q14 = 14줄(onboarding_finish 가 alert_detail 뒤 · mode_pick 앞) · Q15 = 18줄(끝 shellOnboardingSlotBuilderProvider)(🔵 R15d 를 미루면 이 셋 = «정확히») · Q16·Q17·Q19 = 0 · Q18 = 0(🆕 문자열 안 20·42·8 만 — 낱말 경계만 쓰면 레이아웃 정수 8·16·20 과 주석을 잡는다 · 드라이런·감사 지적) ·
   Q20 = «test/onboarding_finish_test.dart:12» · Q21 = «…:1»(🔴 정확히) · Q22 = 이름 12(fail · loading · headline · stage · gate · slot · link · action · not-accepted · result · done · check) · Q23~Q27 = 0 ·
   Q29 = 두 줄(lib/ui_shell.dart · test/shell_fakes.dart — 둘째 수 0 · 그 밖 0 · 🆕 목록 = R15a O29 + R15a·R15b 파일 — 드라이런·감사 지적) · Q30~Q32 = 0 · Q33 = 4줄 «A» · Q34 = ⟦실측: 재드라이런⟧(🔴 정확히) · Q35 = 0 · Q36 = 0 · Q37 = 0(🆕 드라이런 M04a))

■ 골든 — ⟦펼침: R15a 골든 절 글자⟧ o04 — test/golden/o04_golden_test.dart · 위젯 = OnboardingFinish() · 이름 o04_auto(🆕 autoDeclared · 맨 아래 Key = ValueKey<String>('o04-action-5') — 드라이런 752.0 · light = dark) · o04_advisory(🆕 advisory · 맨 아래 Key = ValueKey<String>('o04-link-5') — ⟦실측: 재드라이런 — 흉내는 VM 칸 선언(맨 아래 Key('o04-declare'))으로 772.0⟧) · 머리 Key('o04-headline') dy 0.0 · 슬롯 = FakeShellSlotRecorder · 명령 = testWidgets 안에서 새로(공장 · C4r5d-5) ·
  🔴 높이 844 는 늘리지 않는다 · 🆕 조립 판 입력(6단계 자리·동작 전부 열림)은 976 까지 내려가 맨 아래 Key 를 화면 안 단계로 올리면 두 PNG 가 바이트까지 같아졌다(드라이런 blocker) — 그래서 입력 = 준비 끝 표본(①~⑤ 자리 닫힘) · 넘으면 멈추고 dy 를 질문 파일에 · 나머지 = R15a 골든 절 글자.

■ 질문 파일 — O04_questions.md(이미 있다) · A1·A2 = o04_auto · o04_advisory dy «측정:» 행(R15a 상자 꼴 · 카드ID = R15c-Bob-O04) · 접두 «O-04:».

■ 제출 — ⟦펼침: R15a ■ 제출 전문 — 섹션 머리 · ①~⑤ 상자 · N1 · N3 · 저장 명령⟧ R15a «■ 제출» 과 같은 꼴(파일별 끝 줄 시각 머리 · 저장 파일 BOM 0 · ① = 파일로 받은 출력 · 채팅 두 줄 · N1 · N3)
  flutter test test/onboarding_finish_test.dart ← «00:0n +25: All tests passed!» · test/golden/o04_golden_test.dart ← «+4» · flutter test ← N + 29 — ⟦실측: 앞 카드 병합 기록 때 채움 — 드라이런 기대 286 → «+315»⟧
  name-status 기대: A lib/src/onboarding/onboarding_finish.dart · M lib/ui_shell.dart · A PNG 4 · A test/golden/o04_golden_test.dart · A test/onboarding_finish_test.dart · M test/shell_fakes.dart · M inbox/O04_questions.md · 그 밖 = 금지 · 권장대로면 바뀐 파일 10줄 · 커밋 4줄(드라이런 실측)
  사전검사 ② 한 번: --golden-prefix o04_ --goldens 4 · PR 제목: [M8] O-04 온보딩 마무리 · 채팅 = «R15c-Bob-O04 제출 글 저장했음: <경로>» · 사전검사 ② 끝 줄.
   ① 머리 복사 상자 글자: «화면 ID: O-04 — 온보딩 마무리 6단계(OnboardingFinish())»
   ② 붙일 괄호(요지 · ⟦펼침: R15a ② 꼴 10줄 괄호 글자⟧): 1 Q16·Q29 · 2 «산술 = null 여부 · 열거 switch 둘 · 표시 상태뿐 · «n/6»·«n/5» 0(Q11) · state 비교 0(Q37) · 수치 리터럴 0(Q18·Q19)» · 3 «DateTime.now 0» · 4~7 범위 밖 · 8 «🔒 자리 = 슬롯 빌더(O04-03) · 입력 위젯 0(Q36)» ·
     9 «건너뛰기 0(Q23 · 순서 = 받은 차례 O04-01) · 결과 원문(O04-06)» · 10 «서약문·생체·셀프테스트·체크섬 = 자리만(O04-03) · 실전 시작·모드 선택 0»
   ③ 견본 = ⟦실측: 재드라이런 — 셈 단위 견본 1행(o04_auto light) · 첫 판 견본 «글자 1줄 → 글자 8줄 → 글자 2줄 → 글자 3줄 → 글자 3줄 → 글자 6줄 → 글자 1줄 — 잘림: 맨 아래 덩어리 첫 줄이 화면 아래 끝에서 잘림» 은 옛 입력⟧
   (+ flutter test 한 줄 — 시작·끝 상자(기대 M = N + 29))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-o04-finish` · 커밋 권장 4 · lib 새 1 · 배럴 +1 · test 새 2 + fakes 끝 절 · PNG 4 · `O04_questions.md` A1·A2 · `flutter test` = N + 29(⟦실측: 앞 카드 병합 기록 때 채움⟧) · 정적 Q20 = 12 · Q21 = 1 · Q34 = ⟦실측⟧(정확히) · Q37 = 0.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15c-Bob-O04 결과: 브랜치 ui/m8-o04-finish 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 저장 파일 글 전부.

## 5. 주의

- **5분 눈 검사**: 단계 순서 · «n/6»·«n/5» · 앞 단계로 버튼 열기 · state 비교 · 슬롯 대신 입력 위젯 · 수치 리터럴(8% · 20/42 · 10.2) · 공유·PDF · 모드 선택·실전 시작 · ui_journal import · 선언 링크가 단계 밖.
- 🔵 L-3 재사용(미결 120)이 v1.16 에서 «링크» 가 아닌 다른 꼴로 정해지면(예 ui_shell 이 폼 위젯을 받는 주입) 이 카드 «화면» 의 단계 링크 줄과 테스트 O04-08 을 고친다.
- ⬜ 남은 표식 = 꺾쇠 U+27E6 자리(셈 = `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R15c-Bob-O04.md`) — ⓐ «앞 카드 병합 기록 때 채움» 실측 ⓑ v1.16 이름표 ⓒ 🆕 «펼침» 표식(«= R15a» 자리 · 정적 실행 꼴 · ② 괄호 — 감사 지적) ⓓ 재드라이런 실측(전제 수 · 🟡 · 견본 · o04_advisory dy) + 자리표시자 `__R15B_SQ__` · `__R15B_PR__` — 🔴 보내기 전 0 · ✅ 드라이런 첫 판 실측(줄 · lib · ⓡⓗ · dy · 변이 표)은 «드라이런 기대» 로 채웠다(2026-11-03).
- 범위 고지: 04 §9-5 «체험 완료 기준» = M5 게이트(이 화면 0 · 🆕 «완료 체크(X3)» 는 이 화면이 그린다 — checks) · 01 §8 미결 120·32(이 카드가 닫지 않는다 — v1.16 창이 연다) · 145(공용 모양 함수 — 셋째·넷째 벌 · 셸 손질 카드).

## 6. R15 이월 반영 — R15a «6» 과 같은 표(O-04 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r14b-1 · -2 · C4r14a-4 | 규칙 10 = R15a 규칙 10(⟦펼침⟧) | — |
| C4r14b-5 | ■ 제출 = R15a 꼴(⟦펼침⟧) | — |
| C4r14a-5 쓰기 조각 두 방향 | O04-07 · 예고 변이 «한 칸 초기화 빼기» | — |
| C4r14a-6 부재 = 데이터 = operator | O04-09 · O04-08(operator) · O04-03 닫힌 단계 | — |
| C4r5d-5 골든 명령 칸 = 공장 | ■ 골든 «명령 = testWidgets 안에서 새로» | 탭을 찍는 골든 0 |
| C4r5c-5 · C4r5e-3~7 (계승) | R15a «6» 과 같은 자리 | 배너 = 해당 없음 |
| R15b 드라이런 이월(`StepState` 이름 충돌) | ■ 주입 구조 import 차례 `hide StepState` | — |
