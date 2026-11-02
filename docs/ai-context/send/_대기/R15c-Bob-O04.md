# 발송 패킷 R15c-Bob-O04 — O-04 마무리 6단계 (계약 v1.16 전제 · R15 4장 중 3번째 · M8)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-11-02 조립 · 앱 `rec/r15`) · 선행 = ① R15b 병합(squash `__R15B_SQ__` · PR `__R15B_PR__` · 시작 기준 N = R15b 병합본 실측) ② 🔴 **계약 v1.16 보강 R15c 몫(G15~G17 — 아래 «■ 계약 v1.16 이름표» · ⬜ 발주자 결정 · ▶ 금지)** ③ 🔴 **01 §8 미결 120·§8-32 결정**(모의 안내 시작 상태 선언 = L-3 재사용 경로 · `SelfReportForm` 서명 · C-46 ⑱ `SelfReportPurpose` 예외 · 금액 1칸 위젯 소유 M8 vs M5 — «R15 창이 연다» · ⬜ 발주자 결정) ④ 🔴 **🔒 자리 꼴**(M5 서약문 3문장 · M5 생체 서명 · M9 골든벡터 셀프테스트 버튼 · 복구 카드 체크섬 입력 — 실물 0 · 권고 = R15b 슬롯 빌더 · ⬜ 발주자 확인 ③) ⑤ ⬜ 누적 드라이런 ⑥ ⬜ 발주자 확인 ①~⑪ ⑦ ⬜ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R15a·R15b 브랜치는 건드리지 않는다. 🔵 R15d 를 후순위로 미루면(R15a 확인 ①) 이 카드가 «정확히 N» 을 소유한다(아래 «정적 묶음» Q13~Q15 · Q33 을 «정확히» 로 고친다).
> 만든 날 2026-11-02 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R15-Bob-M8c` 행(🔀 4분할) + §3-0 + §3 공통 조문 + 이월 부록 «R15» 대상(R15a «6» 과 같은 표 · O-04 자리) · 화면 몫 원본 = `04_…` §9-5(`O-04` · 6단계 표 · 단계 6 «committed_at 같은 트랜잭션» · 기대치 한 줄 · 금 상한 config · 복구 카드 · 운영 램프 L1 · 종착 갈래 · 체험 완료 기준 = 이 화면 밖 · 그림 20·26) · §9-8 · §3-3(완료 직후 = `simInternal` · 모드 선택 컨트롤 0) · §11-8·9·12 · `01_…` §8-23 ✅ · §8 미결 120·32 · §9-1 · 06 `M5-8`(서약문) · 판독 메모 §5-1 G15~G17 · §5-2.
> 사전 조건 — ⬜ **R15b 병합**(PR `__R15B_PR__` squash `__R15B_SQ__` · `ui_shell` = lib 16파일 · 라벨 37 · 배럴 13 · 주입 18 · PNG 58 — 병합본 실측으로 채움) · ⬜ 계약 v1.16 R15c 몫 · ⬜ 미결 120·32 결정. 시작 기준 = **⟦실측: R15b 병합본 — 드라이런 기대 281⟧** · 끝 기대 = N + **27**(뷰 23 = `onboarding_finish_test` · 골든 4 = `o04_*`) · 끝 = ⟦실측: 드라이런 «+308» 기대⟧.
> 🔀 **재분할 판정** — 새 `testWidgets(`·`test(` 줄 **14**(`onboarding_finish_test` 13 · 골든 1) · lib ⟦실측: 추정 +280~350⟧ · 새 PNG **4** · 원천·쓰기 **2**(`watchFinish` · `run(action.id)`) → 임계 안.
> 카드 기본값(⬜ 발주자 확인 ①~⑪): ⓐ 위젯 = `OnboardingFinish({super.key})`(`lib/src/onboarding/onboarding_finish.dart` · `ConsumerStatefulWidget` — `_busy`·`_failed`·`_result`) ⓑ 셸·R15a·R15b 파일 무변경 ⓒ 원천 = 🆕 `watchFinish()` → `OnboardingFinishVm` · 쓰기 = VM 이 준 단계 동작 `run(action.id, args: action.args)`(⑥ DRY_RUN 시작 — `committed_at` 같은 트랜잭션 = 엔진 · 화면 관여 0) · 주입 = R15a `shellOnboardingActionsProvider` · 🔒 자리 = R15b `shellOnboardingSlotBuilderProvider`(새 주입 0) ⓓ 6단계 = 받은 차례 그대로(순서 고정 · 건너뛰기 0 · «n/6» 0) · 단계마다 제목 + 상태 아이콘(`StepState`) + 게이트(`GateBadge?`) + 엔진 글자 줄(`lines`) + 기대치 한 줄(`expectationLine?` — ① · 없으면 줄 0) + 🔒 자리(`slotId?` — ②③④⑤) + 동작 버튼(`action?` — 앞 단계 미통과면 엔진이 null = 버튼 부재) ⓔ 투자 안내 갈래 = 시작 상태 선언 링크(`openingDeclare?` · L-3 재사용 · 조립 앱 라우트 — `ui_shell` 은 `ui_journal` import 0) · 선언 전 ⑥ 동작 = 엔진이 null ⓕ 완료 = `doneLabel?`(모의투자 진입 문장 · 엔진) · 모드 선택 컨트롤 0 · 실전 시작 버튼 0 ⓖ 🔴 숫자·문구 리터럴 0(금 상한 8% · 10.2·9.7·10.4 · 배분 20/42 · L1) · 복구 카드 = 글자 줄 + 체크섬 🔒 자리 — PDF·공유·인쇄·복사·스크린샷 버튼 0 · anon key 0(엔진 몫) ⓗ 새 lib 파일 1 · 공용 2(배럴 +1 · `test/shell_fakes.dart` 끝 절) · 라벨·주입 0 · Key 접두 `o04-` · 골든 2이름 4장(`o04_auto` · `o04_advisory`).
> 🔴 **카드 덮개 필수 문장(04 §9-5 · §9-8 · §3-3 · §11-8·9·12 · prompt_M8 145~150·158~162)** — «6단계는 순서 고정 — 건너뛰기·«나중에»·«n/6» 게이지 0 · 단계 열림은 엔진(동작 null = 버튼 부재)» · «서약문·생체 서명·셀프테스트 버튼·체크섬 입력 = 🔒 자리만(프리필 0 · 예시 문장 0 · 자체 입력 0)» · «수치·문구는 엔진 글자 — 금 상한·배분·config_hash·기대치·운영 램프·종착 조합 리터럴 0 · 기대치 값이 없으면 그 줄 0 · `PerformanceSeries`·`PerfDisclosure` 참조 0» · «DRY_RUN 시작 = VM 동작 1회(`committed_at` 같은 트랜잭션 = 엔진) · 모드 선택·실전 시작 0 · 투자 안내는 시작 상태 선언(L-3 재사용 링크) 없이 시작 0(엔진이 동작을 주지 않는다)» · «복구 카드 PDF·공유·스크린샷 0» · «셸·R15a·R15b 파일·테스트·PNG 무변경».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 01 §8-23 ✅(`committed_at` = 6단계 같은 트랜잭션) · §9-1(완료 직후 `simInternal`) · 00 §7 용어(OpsRamp ≠ EntryRamp) · 청사진 §9-1b ⑧(복구 카드 = 손글씨 전사 + 체크섬 · PDF 반대).
> ⬜ **발주자 확인 11건(권고 = 카드 기본값)** — ① 원천 = 🆕 `watchFinish()` → `OnboardingFinishVm{headline, stages(6), openingDeclare?, doneLabel?}` · 단계 = 🆕 `OnboardingFinishStage{title, state, gate?, lines, expectationLine?, slotId?, action?}`(04 §9-5 의 ⚠️ `expectationLine?` M2-8 = 이 칸) · 지금 표본 `m8/onboarding_finish`(단계 7행 + 묶이지 않은 `finish_headline`)는 쓰지 않는다 ② 단계 열림 = 엔진(앞 단계 미통과 → `action` null · `gate` 로 이유) — 화면이 `state` 로 다음 단계를 열지 않는다 ③ 🔒 자리 = R15b 슬롯 빌더(`slotId` 4종 — ② 서약문 M5 · ③ 생체 M5 · ④ 셀프테스트 버튼 M9 · ⑤ 체크섬 입력) · 체크섬 입력 소유 = ⟦v1.16⟧(권고 = M9 입력 위젯 자리 — M8 `TextField` 0 · 대안 = M8 이 `TextField` 1칸을 만들고 값은 `action.args` 로만(비밀 아님) — 비권고: 복구 코드 체크섬도 `FLAG_SECURE` 라우트 안) ④ DRY_RUN 동작 id = ⟦v1.16 G17⟧(권고 = 새 `SettingsActionId.onboardingDryRunStart` — `runtimeEngineStart` 와 뜻이 다르다(첫 `committed_at` · 되돌림 묶음) · 결과 표본 2 = 접수 · 실패(둘 다 되돌림 원문 코드)) ⑤ 🔴 모의 안내 시작 상태 선언 = `openingDeclare{label, link}`(🆕 `OnboardingLinkAction` — R15d 분기 버튼도 같은 타입) → L-3 `SelfReportForm` 재사용 라우트(01 §8 미결 120: 서명 확장 `yyyyMm`·`accountAlias` nullable 또는 `purpose` 인자 · C-46 ⑱ `simOpening` 예외 · 라우트 = v1.16) · 금액 1칸(가상 초기금 — autoTrade 갈래) 위젯 소유 = ⟦미결 32 — 권고 M5⟧ · 이 카드 = 링크 하나 ⑥ 기대치 한 줄 = `expectationLine?`(① 단계만 · null = 줄 0 · 숫자 리터럴 0) ⑦ 운영 램프 L1 · 종착 조합(`simInternal × autoTrade|advisory × execute`) = ⑥ 단계 `lines` 엔진 글자(«운영 램프» 접두가 붙은 문자열 · «n/6» 0) ⑧ 완료 = `doneLabel?` 한 줄 · 모드 선택·실전 시작·체험 완료 기준 목록 = 이 화면 0(M5·M9) ⑨ 복구 카드 = ⑤ 단계 `lines`(프로젝트 ref · 계정 이메일 · repo 주소 · 복구 코드 — 엔진 글자) + 체크섬 🔒 자리 · `FLAG_SECURE`(라우트 진입/이탈) = 플랫폼 몫 · PDF·공유·인쇄·복사·스크린샷 0 ⑩ 골든 2이름 4장(`o04_auto` · `o04_advisory` — 04 에 이름 없음 · 카드가 지음 · 높이 844 를 넘으면 멈추고 dy) ⑪ 이월 반영(«6»).
> 🚫 **플랫폼 몫 = 화면 밖** — 생체인증(③ — M5 위젯 안) · `FLAG_SECURE`(복구 카드 라우트) · Keystore · 첫 실행 판정 해제(완료 뒤 셸 진입 = 조립 앱) · 이 카드 = 자리·링크·엔진 글자만.
> 드라이런: ⬜ ⟦실측: 누적 드라이런 3번째 — 가지 `dry/r15-3` = R15b 드라이런 끝 + R15b 병합 기록 흉내 + v1.16 R15c 몫 흉내⟧.
> 프롬프트 = `prompt_M8.md`(v2 판 183줄 · 🔴 160행 «온보딩 5단계» = 낡은 글자 → 6단계(«이긴다» ⑰)). 🔴 Bob **새 대화** 전제.
> 교훈 반영: R15a 카드 머리 «교훈 반영» 줄과 같다(PNG 열람 2장).

## 0. 한 줄 목적

`OnboardingFinish()` 가 `watchFinish()` 의 `OnboardingFinishVm` — 엔진이 차례·열림을 정한 6단계(P0S 확인 · 서약문 · 생체 · 셀프테스트 · 복구 카드 · DRY_RUN) — 를 받은 차례·글자 그대로 그리고(숫자·문구 리터럴 0 · 기대치는 값이 있을 때만 한 줄), 🔒 자리는 주입 슬롯에만 맡기며, 엔진이 준 단계 동작만 `run(id, args)` 한 번으로 부르고, 투자 안내 갈래의 시작 상태 선언은 링크로만 넘기는 `O-04` 를 계약 v1.16 그대로 짓기(건너뛰기·모드 선택·실전 시작 0).

## 1. 어디에 보내나

**IBM Bob** — 새 브랜치 **`ui/m8-o04-finish`**(base = 최신 `origin/main` · `--no-track`) · PR 제목 = «[M8] O-04 온보딩 마무리».

## 2. 보내기 전에 발주자가 할 것 🔴

1. 이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다(지금 `_대기/`). 2. Bob **새 대화**. 3. GitHub `main` 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R15c-Bob-O04.md>. 4. «3» 본문 전부. 5. 🔴 `_완료/R15a*`·`R15b*` · `_대기/R15d-Bob-R01V01.md` 를 붙여넣지 않습니다. 6. 받는 법 = R15a 와 같다(`$env:TEMP\R15c-Bob-O04_submit.md` · BOM 0 · 채팅 두 줄). 7. `flutter_tester` 를 직접 끝내지 마세요.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R15c-Bob-O04 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R15c-Bob-O04 — 범위: O-04 온보딩 마무리(OnboardingFinish() — 머리 · 6단계(제목 · 상태 · 게이트 · 엔진 글자 줄 · 기대치 한 줄 · 🔒 자리 · 단계 동작) · 결과 줄 · 시작 상태 선언 링크 · 완료 문장) + 배럴 export 1줄 + 가짜 끝 절.
🔴 6단계 = 받은 차례 · 순서 고정 · 건너뛰기·«나중에»·«n/6» 0 · 단계 열림 = 엔진(action null = 버튼 부재 · state 로 열지 않는다).
🔴 서약문·생체·셀프테스트 버튼·체크섬 입력 = 🔒 자리(슬롯 빌더)만 — 프리필·예시 문장·자체 입력 0.
🔴 수치·문구 = 엔진 글자 — 금 상한·배분·config_hash·기대치·운영 램프·종착 조합 리터럴 0 · 기대치 값 없으면 줄 0 · PerformanceSeries·PerfDisclosure 0.
🔴 DRY_RUN = VM 동작 run(id, args) 1회(committed_at 같은 트랜잭션 = 엔진) · 모드 선택·실전 시작 0 · 투자 안내 = 시작 상태 선언 링크(L-3 재사용) — 선언 전 DRY_RUN 동작은 엔진이 주지 않는다.
🔴 복구 카드 = 글자 줄 + 체크섬 자리 — PDF·공유·인쇄·복사·스크린샷 버튼 0.
🔴 셸·R15a·R15b 파일(onboarding_start · onboarding_mode_pick · onboarding_step_list · onboarding_step_detail · shell_providers 기존 줄)·테스트·PNG 무변경.
하지 않는 것: O-00~O-03(병합됨) · R-01·V-01(R15d) · L-3 폼(ui_journal — import 0 · 링크만) · 체험 완료 기준 목록 · 실전 전환(M9 → M5) · FLAG_SECURE · 생체 · 새 주입 · 새 라벨 · domain_contracts·pubspec 수정.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 16항).

■ 0단계 — 대상 확인
이 카드는 R15a·R15b(병합됨)가 아닙니다. 지금 코드에는 packages/ui_shell/lib/src/onboarding/onboarding_finish.dart 가 없습니다.
  git branch --show-current · git status --short(빈) · git fetch origin --prune · git checkout --no-track -b ui/m8-o04-finish origin/main   ← 🔴 git checkout main 금지
  git grep -c "Stream<OnboardingFinishVm> watchFinish();" -- packages/domain_contracts/lib/src/repositories/onboarding_repository.dart   ← «…:1»(v1.16)
  git grep -c "abstract class OnboardingFinishVm" -- packages/domain_contracts/lib/src/dto/safety.dart                         ← ⟦v1.16 파일⟧ «…:1»
  git grep -c "abstract class OnboardingFinishStage" -- packages/domain_contracts/lib/src/dto/safety.dart                      ← ⟦v1.16⟧ «…:1»
  git grep -c "abstract class OnboardingLinkAction" -- packages/domain_contracts/lib/src/dto/safety.dart                       ← ⟦v1.16⟧ «…:1»
  git grep -c "String? expectationLine," -- packages/domain_contracts/lib/src/dto/safety.dart                                 ← ⟦v1.16⟧ «…:1»
  git grep -c "static const String m8OnboardingFinishAuto =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart  ← «…:1»(v1.16)
  git grep -c "static const String m8OnboardingFinishResults =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart  ← «…:1»(v1.16)
  git grep -c "final Provider<ShellSlotBuilder?> shellOnboardingSlotBuilderProvider" -- packages/ui_shell/lib/src/shell_providers.dart  ← «…:1»(R15b 병합)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                          ← «…:1»
  ls docs/ai-context/send/R15c-Bob-O04.md · ls docs/ai-context/inbox/O04_questions.md · ls packages/domain_contracts/fixtures/m8/onboarding_finish_auto.json · _advisory.json · _advisory_declared.json · _no_expectation.json · _done.json · _results.json   ← 전부 보여야 함(한 줄에 하나)
  반대(없어야 함): ls packages/ui_shell/lib/src/onboarding/onboarding_finish.dart · git grep -c OnboardingFinish -- packages/ui_shell/lib
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 ⟦실측: R15b 병합본 «+281: All tests passed!»⟧ → cd ../..

■ 계약 v1.16 이름표 — R15c 몫(🔴 코드가 정본 · ⟦v1.16⟧ = 보강 PR 글자로 병합 기록 때 고침)
  🆕 OnboardingFinishVm({required String headline, required List<OnboardingFinishStage> stages, OnboardingLinkAction? openingDeclare, String? doneLabel})
       — stages = 6(엔진 차례 · 순서 고정) · openingDeclare = 투자 안내 갈래 시작 상태 선언(L-3 재사용 링크 · 선언 뒤·자동 매매 = null) · doneLabel = DRY_RUN 시작 뒤 문장(모의투자 진입 · null = 아직)
  🆕 OnboardingFinishStage({required String title, required StepState state, GateBadge? gate, required List<String> lines, String? expectationLine, String? slotId, OnboardingVerifyAction? action})
       — lines = 엔진 글자 줄(① 배분·금 상한(config)·config_hash · ④ 셀프테스트 «통과 n/전체 n» · ⑤ 복구 카드 4칸 · ⑥ 운영 램프 L1·종착 조합) · expectationLine = ① 정직한 기대치 한 줄(값 없으면 null) ·
         slotId = 🔒 자리 이름(② 서약문 · ③ 생체 · ④ 셀프테스트 버튼 · ⑤ 체크섬 입력) · action = 단계 동작(⑥ DRY_RUN 시작 등 · 앞 단계 미통과·선언 전 = null — 엔진 판정)
  🆕 OnboardingLinkAction({required String label, required String link}) — 글자 + 링크(엔진이 완성)
  OnboardingVerifyAction(R15b) · ActionResult(기존) · SettingsActionId ⟦v1.16 G17 — DRY_RUN 시작 id⟧(🔴 이 카드는 id 를 이름으로 쓰지 않는다 — action.id 그대로)
  FixturePaths  m8OnboardingFinishAuto · …Advisory · …AdvisoryDeclared · …NoExpectation · …Done · …Results(ActionResult 2 — 접수 · 실패(둘 다 되돌림 원문 코드))
  🔴 쓰지 않는 것: m8/onboarding_finish(단계 7행 + finish_headline) · OnboardingStep · watchStepList · PerformanceSeries · PerfDisclosure · FeatureFlags · RunMode · OperatingMode.

■ 규칙 요약 (정본 = 이 카드 · R15a 카드 규칙과 다른 줄만 새로 적고, 같은 줄은 «= R15a 규칙 n» — 그 글자는 docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3»)
 1 고치는 곳 = packages/ui_shell + inbox/O04_questions.md 만. 새 파일 = lib/src/onboarding/onboarding_finish.dart · test/onboarding_finish_test.dart · test/golden/o04_golden_test.dart · 새 PNG 4.
   공용 2파일 끝 절 더하기만: lib/ui_shell.dart = export 'src/onboarding/onboarding_finish.dart'; 한 줄(자리 = export 'src/alerts/alert_detail.dart'; 바로 뒤 · 정렬 차례 — onboarding_finish < onboarding_mode_pick) · test/shell_fakes.dart 끝 R15c 절.
   고치면 반려: 그 밖 ui_shell 파일 전부(labels.dart · shell_providers.dart 포함) · domain_contracts/** · apps/** · 다른 ui_*.
 2 = R15a 규칙 2(값 = headline · title · lines · expectationLine · gate.label · action.label · openingDeclare.label · doneLabel · 결과 headline · reasonCode 원문 · 리터럴 0).
 3 읽지 않는 필드: OnboardingFinishStage 의 slotId(🔴 빌더 인자로만 · 글자 0) · action 의 id·args(🔴 run 인자로만) · GateBadge.code · ActionResult 의 actionRunId · id · handoffRoute · retryable(⑥ 은 재시도 0 — 다시 누르기 = 같은 동작이 엔진이 줄 때만).
 4 이동 = AppLinkOpener.open(openingDeclare.link) 하나(탭 콜백 안) · 'aaq://' 리터럴 0 · AppRoutes 0 · 🔴 ui_journal import 0(L-3 = 링크).
 5 산술·판정 0 — 허용 = ⓐ null 여부 ⓑ StepState 5값 · GateState 4값 전수 switch(R15b _stepLook·_gateLook 과 같은 글자 — 공용 모양 함수는 만들지 않는다 · 01 §8 미결 145) ⓒ 단계 동작 버튼 = 주입 non-null ∧ action non-null ∧ !_busy ⓓ 조각 상태 셋 ⓔ 순번.
   🔴 «앞 단계 verified 면 다음 열기»·«n/6»·«i+1 단계» 표기 0 · lines 를 고르거나 합치기 0 · expectationLine 대신 다른 줄 0.
 6 switch = StepState 5 · GateState 4(둘뿐 · default 0). 7 = R15a 규칙 7. 8 = R15a 규칙 8. 9 새 주입 0 · 데이터 1(_finishProvider) · 주입 = shellOnboardingActionsProvider · shellOnboardingSlotBuilderProvider · shellLinkOpenerProvider.
10 = R15a 규칙 10(경우 for 밖 · 흐름 칸 non-null · name 칸 · 쓰기 조각 두 방향 · 부재 = 데이터는 operator · ⓡ·ⓗ = Q20·Q21 — onboarding_finish_test ⓡ ⟦실측: 계획 10⟧ · ⓗ 1 · 🔴 정확히) · 🔒 자리 테스트 = R15b FakeShellSlotRecorder(고치지 않는다 · 새 가짜 0).
11 골든 = 새 PNG o04_* 4장 · 높이 844 고정(넘으면 멈추고 dy · 6단계라 길다 — 드라이런 dy 로 확인) · 기존 PNG 58장 재생성 0. 12~14 = R15a 규칙 12~14.
15 주석 금지 낱말(정적이 센다): slotId 를 글자로 · OperatingMode · RunMode · FeatureFlags · PerformanceSeries · PerfDisclosure · DateTime.now · Duration · AppRoutes · ui_journal · SelfReport · TextField · Clipboard · share · print · pdf · screenshot · skip · 건너뛰 · 나중에 · 추천 · 권유 · 자문 · 시그널.
🔴 보고 규칙 = R15a «보고 규칙»(PNG 열람 2장 · S05 기대 1줄).

■ 프롬프트보다 이 카드가 이긴다 — 16항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 범위 → O-04 ② 113~118행 → 이 카드 = O-04 · O-00~O-03 = R15a·R15b(병합됨) · R-01·V-01 = R15d ③ 12~13행 의존 → 추가 0 ④ 15~19행 링크 = 데이터 → 그대로(openingDeclare.link)
 ⑤ 20~23행 → 그대로(시계·신선도 0) ⑥ 24~31행 + 04 §2-1 금지 5 → 그대로(복구 카드 내보내기·공유·인쇄 0) ⑦ 32~35행 → 이 카드 라벨 0 ⑧ 36~38행 → 그대로 ⑨ 41~47행 안전 화면 → 그대로(🔒 M5·M9 자리 · 실전 전환 0)
 ⑩ 48~57행 모드 → 그대로(완료 직후 모드 = 엔진 기본값 · 모드 선택 컨트롤 0 · 04 §3-3) ⑪ 68~77행 수치·램프 → 그대로(리터럴 0 · «운영 램프» 접두 엔진 글자 · «n/6» 0)
 ⑫ 106~111행 → inbox/O04_questions.md ⑬ 127~128행 → ui/m8-o04-finish · «[M8] O-04 온보딩 마무리» ⑭ 145~150행 → 그대로(금 상한 8% 리터럴 0 · 복구 카드 PDF·공유·스크린샷 0 · 건너뛰기 0)
 ⑮ 158~162행 → 🔴 «온보딩 1단계의 기대치» = O-04 1단계(P0S 확인)의 expectationLine · «온보딩 5단계의 램프 L1» = 낡은 글자 — 지금 6단계(서약문 신설로 밀림 · 04 §9-5 머리) · 04 §11-9 의 «O-04 5단계» 도 같은 낡음 ⑯ 172~182행 자체 점검 → ■ 제출 ② 상자 + 괄호

■ 먼저 읽을 것 — ① prompt_M8.md ② 04 §9-5(표 · 그림 20·26) · §9-8 · §3-3 · §11-8·9·12 ③ 01 §8-23 · §8 미결 120·32 · ⟦v1.16 절⟧ ④ domain_contracts — v1.16 dto · repositories/onboarding_repository.dart · testing.dart
 ⑤ ui_shell — lib/src/onboarding/onboarding_step_detail.dart(🔵 R15b 동작·슬롯 꼴 · 읽기만) · test/onboarding_step_detail_test.dart · test/shell_fakes.dart ⑥ docs/ai-context/send/_완료/R15a-Bob-O00O00b.md «3»(«= R15a» 글자의 정본) ⑦ inbox/O04_questions.md 머리말

■ 본받지 않는 것
 · 지금 표본 m8/onboarding_finish(단계 7행 · finish_headline) · «완료 체크(X3) 5항목»·«체험 완료 기준 8항목» 목록을 이 화면에 그리기(04 §9-5 — 게이트는 M5) · 실전 시작·모드 고르기 버튼
 · 서약문 예시 문장·자리 안 Text · 생체 아이콘 버튼을 화면이 직접 · 셀프테스트 «실행» 버튼을 화면이 직접(M9) · 체크섬 TextField(⟦발주자 확인 ③⟧ 전) · 복구 카드 복사·공유·PDF
 · 앞 단계 state 로 다음 단계 버튼 활성 · 단계 번호를 화면이 짓기(«1/6» · «단계 n») · 배분 «20% / 42%»·«8%»·«L1» 리터럴 · expectationLine null 인데 다른 글자
 · L-3 폼을 ui_journal 에서 import·복제 · SelfReportPurpose 를 화면이 고르기 · openingDeclare 없이 선언 버튼

■ 주입 구조 — lib/src/onboarding/onboarding_finish.dart = OnboardingFinish(공개 · ConsumerStatefulWidget) · _finishProvider(StreamProvider<OnboardingFinishVm> · watchFinish()) · _StageBlock(StatelessWidget) · _stepLook · _gateLook(R15b 와 같은 글자) · 배럴 한 줄.

■ 호출 표 — 부르는 것: watchFinish() 한 번(재시도 = 한 번 더) · run(stage.action.id, args: stage.action.args)(버튼마다 한 번 · 기다리는 동안 0) · 슬롯 빌더(stage.slotId) · shellLinkOpenerProvider(선언 탭 콜백 안). 부르지 않는 것: watchStepList · watchStep · SettingsActions.watch · 다른 id.

■ 상태 표 — finish  hasError → ShellErrorView(key: const Key('o04-fail'), onRetry: invalidate) · 값 전 → ShellSkeleton(key: const Key('o04-loading')) · 값 → «화면»

■ 화면 (위 → 아래)
 머리    Padding(key: const Key('o04-headline'), …, Text(vm.headline))
 단계    for (final (int i, OnboardingFinishStage st) in vm.stages.indexed) _StageBlock(index: i, stage: st, …) — Padding(key: ValueKey<String>('o04-stage-$i'), Column(start)[
           Row[ Icon(_stepLook) · Expanded(Text(st.title)) ] · (gate) Row(key: ValueKey<String>('o04-gate-$i'))[ Icon(_gateLook) · Flexible(Text(gate.label)) ] · for (line in st.lines) Text(line) ·
           (exp) Text(exp, key 없음 — 단계 Padding 안) · (slotId && builder) Padding(key: ValueKey<String>('o04-slot-$i'), builder(slotId)) · (action && actions && !_busy) FilledButton(key: ValueKey<String>('o04-action-$i'), child: Text(action.label)) ])
 결과    (_failed) Padding(key: const Key('o04-not-accepted'), Text(ShellLabels.onboardingNotAccepted)) · (r) Padding(key: const Key('o04-result'), Column[ Text(r.headline) · (code) Text(code) ])
 선언    (declare != null) Padding(key: const Key('o04-declare'), FilledButton.tonal(onPressed: () { ref.read(shellLinkOpenerProvider).open(declare.link); }, child: Text(declare.label)))
 완료    (done != null) Padding(key: const Key('o04-done'), Text(done))
 🔴 단계 블록 사이 «n/6»·진행 막대 0 · 맨 아래 «실전 시작» 0

■ 픽스처 — auto(stages 6 · ① expectationLine non-null · ②③④⑤ slotId non-null · ⑥ action non-null · openingDeclare null · doneLabel null) · advisory(⑥ action null · openingDeclare non-null) · declared(⑥ action non-null · openingDeclare null) ·
  noExp(① expectationLine null) · done(doneLabel non-null · action 전부 null) · results(listFixture · [0] 접수 · [1] 실패 원문 코드) · 🔴 gate 표본 = 적어도 한 단계 unknown(⟦v1.16⟧).

■ Key 표 (o04- 11이름) — o04-loading · o04-fail · o04-headline · o04-stage-$i · o04-gate-$i · o04-slot-$i · o04-action-$i · o04-not-accepted · o04-result · o04-declare · o04-done

■ 할 일 — (1) lib + 배럴 «[M8] R15c (1) O-04 마무리 화면» (2) fakes 끝 절 + 테스트 «[M8] R15c (2) O-04 테스트» (3) 골든 4장 «[M8] R15c (3) 골든 o04_* 4장» (4) format · 질문(A1~A2 dy) «[M8] R15c (4) format · 질문» · (4) 뒤 (5) 하나만.

■ 정적 라벨 — 0개(«접수되지 않았습니다» = R15a onboardingNotAccepted 재사용).

■ 테스트 최소 목록 — test/onboarding_finish_test.dart(줄 13 · 테스트 23 — 계획 · ⓡ·ⓗ·(전제) 수는 드라이런이 «정확히» 로 확정)
 O04-01 6단계 차례·제목·글자 줄(auto) — ⓗ expect(auto.stages, hasLength(6)) → i 마다 단계 글자 == [title, ?gate.label, ...lines, ?expectationLine, ?action.label] 꼴 · 사슬 dy · ⓡ.
 O04-02 기대치 한 줄 = 데이터 — 두 경우(auto 있음 · noExp 없음) · «없는 쪽» 견본 · ⓡ.
 O04-03 🔒 자리 = 슬롯 빌더 — 두 경우(빌더 있음 → slots.slotIds == stages 의 non-null slotId 차례 · 빌더 null → o04-slot-* 0) · TextField findsNothing · ⓡ.
 O04-04 게이트 3상(unknown ≠ notApplicable) · ⓡ.
 O04-05 단계 동작 = run(action.id, action.args) 1회(auto ⑥) · ⓡ.
 O04-06 결과 줄 — 두 경우(접수 · 실패 원문 코드) · ⓡ.
 O04-07 실패 ↔ 성공 두 방향(C4r14a-5) · ⓡ.
 O04-08 투자 안내 선언 — 두 경우(advisory: o04-declare 있음 · ⑥ o04-action 없음 → tap → opener.opened == [link] · declared: o04-declare 없음 · ⑥ 있음) · ⓡ.
 O04-09 주입 null(뷰어) = 동작 버튼 부재 · operator 대조 — 두 경우 · ⓡ.
 O04-10 완료 문장(done) · 동작 버튼 0 · ⓡ.
 O04-11 상태 갈래 세 경우 · O04-12 재시도 · ⓡ · O04-13 화면 Text 전부 · 큰 글꼴 세 경우(auto · advisory · done — 8%·10.2·20/42 리터럴은 allowed 밖) · ⓡ.
🔴 예고 변이(갈래마다): 단계 뒤집기 · 단계 하나 빼기 · «n/6» 글자 더하기 · 앞 단계 state 로 버튼 열기 · action null 에도 버튼 · expectationLine 빼기 · null 에도 빈 줄 · lines 하나 빼기 · 슬롯 대신 TextField · 빌더 null 인데 상자 ·
   run 0·두 번 · args 고치기 · 기다리는 동안 두 번 · 결과 headline·code 빼기 · 한 칸 초기화 빼기 · 선언 링크 탭 0 · 선언 있어도 ⑥ 버튼 · 주입 null 에도 버튼 · done 빼기 · 모드 선택 버튼 더하기 · 에러를 스켈레톤 · 재시도 invalidate 0 · ⟦실측: 드라이런 변이 표⟧.

■ 정적 묶음 — R15a 꼴 37줄 안팎(머리 «## Q01» ~ · 파일로 Git Bash · 꺼내기 범위·해시 = ⟦실측⟧) — 판정 줄(뜻과 기대 · ⬜ 드라이런 실측 전):
  Q01·Q02 새 테스트 한글·이름 ASCII = 0 · Q03 testWidgets 줄 = 2줄(o04_golden 1 · finish_test 13) · Q04 링크 리터럴 0 · S05 opener = 1줄(선언 콜백) · Q06 watchFinish( = 1 · Q07 SettingsActionId. = 0 · Q08 .run( = 1 ·
  Q09 StepState 5 · GateState 4 = 9줄 · Q10 슬롯 빌더 = 1줄 · Q11 금지 낱말 0(OperatingMode|RunMode|FeatureFlags|PerformanceSeries|PerfDisclosure|ui_journal|SelfReport|DateTime\.now|Duration\(|AppRoutes|toString\(|\.length|\.where\(|\.sort|\.take\(|share|[Pp]df|print\(|Clipboard|TextField|[Ss]kip|actionRunId|handoffRoute|retryable|\.slotId\b.*Text) ·
  Q13 라벨 37 · Q14 배럴 14 · Q15 주입 18(🔵 R15d 를 미루면 이 셋 = «정확히») · Q16~Q19 import·한글·수치(+ 20|42|8% 류 — `'[^'\n]*%`·`\b(20|42|8)\b` 리터럴 0)·소수 0 · Q20·Q21 ⓡ·ⓗ(🔴 정확히) · Q22 Key 이름 11 · Q23 금지 어휘 0(+ 나중에 · 건너뛰) · Q24~Q27 Colors·RichText·autoDispose·Scaffold 0 ·
  Q29 numstat(ui_shell.dart · shell_fakes.dart 두 줄 · 둘째 수 0 · 그 밖 0) · Q30~Q32 implements·copyWith·collection-if 0 · Q33 PNG = 4줄 «A» · Q34 (pre) ⟦실측⟧ · Q35 bare takeException 0 · Q36 입력·내보내기 위젯 0(textfield|clipboard|share|pdf|printing|screenshot|flag_secure).

■ 골든 — o04 — test/golden/o04_golden_test.dart · 위젯 = OnboardingFinish() · 이름 o04_auto(auto · 맨 아래 Key = ValueKey('o04-action-5')) · o04_advisory(advisory · 맨 아래 Key('o04-declare')) · 머리 Key('o04-headline') dy 0.0 · 슬롯 = FakeShellSlotRecorder · 명령 = testWidgets 안에서 새로(공장 · C4r5d-5) ·
  🔴 6단계가 844 를 넘으면 높이를 늘리지 말고 멈춘 뒤 dy 를 질문 파일에(⟦실측: 드라이런 dy — 넘으면 카드가 맨 아래 Key 를 화면 안 마지막 단계로 고친다⟧) · 나머지 = R15a 골든 절 글자.

■ 질문 파일 — O04_questions.md(이미 있다) · A1·A2 = o04_auto · o04_advisory dy «측정:» 행(R15a 상자 꼴 · 카드ID = R15c-Bob-O04) · 접두 «O-04:».

■ 제출 — R15a «■ 제출» 과 같은 꼴(파일별 끝 줄 시각 머리 · 저장 파일 BOM 0 · ① = 파일로 받은 출력 · 채팅 두 줄 · N1 · N3)
  flutter test test/onboarding_finish_test.dart ← «00:0n +23: All tests passed!» · test/golden/o04_golden_test.dart ← «+4» · flutter test ← N + 27 — ⟦실측: 281 → «+308»⟧
  name-status 기대: A lib/src/onboarding/onboarding_finish.dart · M lib/ui_shell.dart · A PNG 4 · A test/golden/o04_golden_test.dart · A test/onboarding_finish_test.dart · M test/shell_fakes.dart · M inbox/O04_questions.md · 그 밖 = 금지
  사전검사 ② 한 번: --golden-prefix o04_ --goldens 4 · PR 제목: [M8] O-04 온보딩 마무리 · 채팅 = «R15c-Bob-O04 제출 글 저장했음: <경로>» · 사전검사 ② 끝 줄.
   ① 머리 복사 상자 글자: «화면 ID: O-04 — 온보딩 마무리 6단계(OnboardingFinish())»
   ② 붙일 괄호(요지): 1 Q16·Q29 · 2 «산술 = null 여부 · 열거 switch 둘 · 표시 상태뿐 · «n/6» 0(Q11) · 수치 리터럴 0(Q18·Q19)» · 3 «DateTime.now 0» · 4~7 범위 밖 · 8 «🔒 자리 = 슬롯 빌더(O04-03) · 입력 위젯 0(Q36)» ·
     9 «건너뛰기 0(Q23 · 순서 = 받은 차례 O04-01) · 결과 원문(O04-06)» · 10 «서약문·생체·셀프테스트·체크섬 = 자리만(O04-03) · 실전 시작·모드 선택 0»
   (+ flutter test 한 줄 — 시작·끝 상자(기대 M = N + 27))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-o04-finish` · 커밋 권장 4 · lib 새 1 · 배럴 +1 · test 새 2 + fakes 끝 절 · PNG 4 · `O04_questions.md` A1·A2 · `flutter test` = N + 27(⟦실측⟧) · 정적 Q20·Q21·Q34 정확히.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R15c-Bob-O04 결과: 브랜치 ui/m8-o04-finish 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 저장 파일 글 전부.

## 5. 주의

- **5분 눈 검사**: 단계 순서 · «n/6» · 앞 단계로 버튼 열기 · 슬롯 대신 입력 위젯 · 수치 리터럴(8% · 20/42 · 10.2) · 공유·PDF · 모드 선택·실전 시작 · ui_journal import.
- 🔵 L-3 재사용(미결 120)이 v1.16 에서 «링크» 가 아닌 다른 꼴로 정해지면(예 ui_shell 이 폼 위젯을 받는 주입) 이 카드 «화면» 의 선언 줄과 테스트 O04-08 을 고친다.
- ⬜ 남은 표식 = 실측 표식 + 자리표시자 `__R15B_SQ__` · `__R15B_PR__` — R15b 병합 기록 · v1.16 · 드라이런 때 채운다 · 🔴 보내기 전 0.
- 범위 고지: 04 §9-5 «완료 체크(X3) 5항목» · «체험 완료 기준» = M5 게이트(이 화면 0) · 01 §8 미결 120·32(이 카드가 닫지 않는다 — v1.16 창이 연다) · 145(공용 모양 함수 — 셋째·넷째 벌 · 셸 손질 카드).

## 6. R15 이월 반영 — R15a «6» 과 같은 표(O-04 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r14b-1 · -2 · C4r14a-4 | 규칙 10 = R15a 규칙 10 | — |
| C4r14b-5 | ■ 제출 = R15a 꼴 | — |
| C4r14a-5 쓰기 조각 두 방향 | O04-07 · 예고 변이 «한 칸 초기화 빼기» | — |
| C4r14a-6 부재 = 데이터 = operator | O04-09 · O04-08(operator) | — |
| C4r5d-5 골든 명령 칸 = 공장 | ■ 골든 «명령 = testWidgets 안에서 새로» | 탭을 찍는 골든 0 |
| C4r5c-5 · C4r5e-3~7 (계승) | R15a «6» 과 같은 자리 | 배너 = 해당 없음 |
