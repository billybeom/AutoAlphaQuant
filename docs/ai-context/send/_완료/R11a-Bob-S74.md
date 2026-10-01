# 발송 패킷 R11a-Bob-S74 — S7-4 투자금 플래너 위저드(폰 전용) (계약 v1.4 · R11 2장 중 1번째)

> ▶ **보낼 수 있습니다**(2026-09-30) — 계약 v1.4 병합(M2 PR #18 · squash `b288a00` · CI 3/3)과 이 카드의 기록 커밋(`c3fa414`)이 GitHub `main` 에 있습니다. **R11 2장 중 1번째** · 한 번에 카드 1장 · 순서 R11a → R11b(R11c 는 보류).
> 만든 날 2026-09-30 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R11a 행 · §6 3a · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-09-30_R11선행_계약v1.4_설계서.md` §2 Δ6·Δ7·Δ8 + §3 «4. 화면 몫»·«5. 증명 계획» + §5 패킷 규칙 · 조문 = `01_…` §14(14-1~14-8 · 14-19) · §12-3 · `03_…` §9 의 «🆕 계약 v1.4 — `S7-4` R11 범위» 블록(ⓐ~ⓗ) · golden README «🆕 R11(계약 v1.4)» 절.
> 사전 조건 — ✅ 계약 v1.4 병합(M2 PR #18 · squash `b288a00` — 새 DTO `DepositPreviewResult`·`PensionLimitVm` · `WhatIfApi.simulateDeposit({required String amountInput})` · 받침대 `UnimplementedWhatIfApi` · 픽스처 122 · G13 완화) · ✅ R10 3장 병합(R10a PR #15 `02e8e06` · R10b PR #16 `510a8d1` · R10c PR #17 `1cada8a`). 병합 확인은 본문 0단계의 확인 줄로(해시 없이 내용으로 확인한다).
> 발주자 결정(2026-09-30 · 01 §14 머리) — ① 카드 나눔(R11a → R11b · R11c 보류) ② 플래너·실입금 등록 **폰 전용**(`package:ui_analytics/planner.dart` · 배럴 밖) ③ 차단 = **진입 허용 + 엔진 `blockedText` 문장**(D21) ④ 스텝 ④ 비교·시나리오 저장 연기 + 03 §9 수용 (a)(b)(d)(e) 정정 ⑤ **strict 보고 규칙 적용** · 선택 S-4 = 싣지 않음. «반대로 인출하면?» 버튼·`planWithdrawal` 은 v1.5(R11c).
> 카드 확정값(카드 권한): 정적 라벨 15개(본문 «정적 라벨» — 글자 고정) · 위젯·Key·파일·프로바이더 이름(본문 «주입 구조»·«Key 표») · 골든 7이름 14장 · 테스트 번호 T74-01~T74-26(T74-19 없음) · 정적 묶음 29줄.
> 🔴 **보내는 조건(Claude 확인)** — v1.4 PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-4_questions.md` 가 `main` 에 있음(빈 머리말 — 기록 커밋 `c3fa414` 에서 만든다). 0단계의 `ls` 줄이 그 증명이다.
> 드라이런: ✅ 2026-09-30 누적 드라이런(검사 폴더 `C:/Work/AAQ-claude-review` · 계약 v1.4 로컬 tip `3f3c923` + 기록 커밋 모사 위 · 이 카드 본문만 보고 지음 · 끝 `a8d8c7f` · 뒤이어 R11b 를 같은 폴더에 쌓음) — 기존 `flutter test` **196** → 새 **39**(뷰 25 + 골든 14) = **235** 통과 · 0 실패 · 골든 높이 844/844/1100/844/1100/1300/844 · dy 379~1175(light=dark) · S05 2줄 · S22 1줄 · S26 29 · S27 20(ⓗ 전제 9 + 호출 수 단언 11) · S19 43줄 · lib +751 · 예고 변이 24종 중 23 KILLED(«첫 값 뒤 스트림이 입력 덮기» 생존 → T74-02 ⓒ 로 보강) · bash / PowerShell 5.1 출력 같음(EXIT 표기·warning 줄 제외). 드라이런 결함 13건 + 콜드 리드 17건을 이 판에 반영했다(enum 값 이름 `input` · pumpPlanner 새로 띄우기 · 스텝별 목록 Key · T74-09 · 배분 행 Wrap · 접수 실패 줄 지우기 · 테스트 단계 배분 · S27 뜻 · S17·S18 판정 …). 반영 뒤 재드라이런은 하지 않았다 — 바뀐 곳(배분 행 · 목록 Key · T74-02 ⓒ · T74-09 · T74-18 ⓑ)은 Bob 의 PR 이 첫 실측이다. 🔴 재분할 임계(설계 Δ7): **새 `testWidgets(`/`test(` 줄(골든 파일은 «골든» 절의 모양 — 밝기 루프 하나 안에 이름마다 1줄 = 7) > 33 · lib > +900 · 새 PNG > 16** → 드라이런 32(뷰 25 + 골든 7 · 실행 수 39) · +751 · 14 = **모두 임계 안(나누지 않는다)**.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 치환값은 R11 두 장을 함께 적은 것이다 · 이 카드의 범위·PR 제목은 이 패킷이 정한다 · 행 번호는 기록 커밋 뒤 파일(170행) 기준) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R10 의 대화를 기억하지 못합니다 — 이미 `main` 에 있는 것은 «이미 있다 · 고치지 않는다 · 이렇게 쓴다»로, 0단계·규칙 요약·본받지 않는 것·코드 틀은 본문에 담았습니다. Bob 이 다시 써야 하는 목록(12항 원문 · 정적 묶음 · Key 표 · 라벨 글자)은 전부 붙여넣는 본문 안에 있다(다른 파일을 가리키기만 하지 않는다).
> R10 교훈 반영(C4 보고 R10a · R10b 1·2회차 · R10c 1·2회차): ② 12항 복사 상자 · 정적 묶음 출력 그대로 · ① name-status 출력 그대로 · ③ 위젯·Key 이름 나열(요약어 금지) · [—] 금지 · teardown `unawaited(close)` · «화면에서 센다» · 배치 사슬 테스트(R10c 1회차 반려 = 배치 순서) · 🆕 R10c 이월(발주자 2026-09-30) = **S05 줄 괄호 금지** + **보강 줄 개수 grep -c 대조**(ⓡ·ⓗ 따로).

## 0. 한 줄 목적

이번에 넣을 돈이 «어디로 얼마나 가는가»를 엔진 미리보기 그대로 보여 주고, 그 계획으로 실입금을 **한 번** 등록하게 하는 폰 전용 플래너 — 계약 v1.4 그대로 스텝 ①~③ 과 등록 흐름을 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s74-planner`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **계약 v1.4 가 `main` 에 병합되고, 이 파일 머리 첫 줄이 ▶ 로 바뀐 뒤에 보냅니다** — 첫 줄이 ⏸ 이면 아직입니다(Claude 가 v1.4 병합과 기록 푸시를 마치면 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R10 을 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R11a-Bob-S74.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R11a-Bob-S74.md` · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 옛 브랜치에 있어 이 파일이 안 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부**(«R11a-Bob-S74 — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래의 R11 패킷은 **이것 하나**입니다. 끝난 카드 `_완료/R10a-Bob-S71b.md`·`_완료/R10b-Bob-S72G.md`(+재제출)·`_완료/R10c-Bob-S72.md`(+재제출)·`_완료/R2b-Bob-J3.md`, M7 의 옛 카드 `_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md` 를 붙여넣지 않습니다. R11b(`R11b-Bob-S79.md`)는 이 카드의 병합 기록 커밋에서 Claude 가 `send/` 에 올립니다 — 그 전에는 `send/` 에 없습니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R11a-Bob-S74 — 범위: S7-4 투자금 플래너 위저드(폰 전용 · package:ui_analytics/planner.dart · 배럴 밖) — 공개 위젯 DepositPlannerScreen 하나 ·
  스텝 ① 금액(설정 문장 · 입력칸 · 미리보기 계산 · 입력 거부 · 차단 · 계산 에러 · 대기) · 스텝 ② 배분·계좌(워터폴 글자 행 · 잔여 · 한도 카드) ·
  스텝 ③ 결과(주문 초안 · 비용 · 조달 · 등록 1회 · 등록 불가 · 접수 상태 · 접수 실패 · 다시 계산). R11 2장 중 1번째.
하지 않는 것: S7-9 목표 경로·S7-1 진입 버튼·A13 값 열 정렬(R11b 몫) · S7-5 인출 안내·«반대로 인출하면?» 버튼·AppRoutes.planWithdrawal(R11c · v1.5) ·
  스텝 ④ «즉시 vs 다음 리밸런싱 대기» 비교 · 시나리오 저장·목록 · 등록 뒤 M5 핸드오프 · 워터폴 막대·배분비·슬리피지 · 비용 내역(수수료·세금 따로) ·
  사유 칩 탭(핸드북 연결) · 뷰어(iOS·웹) 미리보기 · 웹 2열·반응형 · SIM 골든 · 초기 진입(EntryRamp) 카드 · 셸 몫(라우트 등록·라우터 가드·진입점 · M8) ·
  기존 화면·위젯·프로바이더·배럴 수정.
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 19항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R10c(ui/m7-s72-explore · 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/planner.dart · lib/src/planner/ · AnalyticsLabels.plannerIntroLine 이 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s72-explore 일 것입니다(다른 이름이어도 아래 status 가 비면 계속)
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s74-planner origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.4.0'" -- packages/domain_contracts/lib/src/contract_version.dart     ← «…contract_version.dart:1»(계약 v1.4 병합)
  git grep -c "simulateDeposit({required String amountInput})" -- packages/domain_contracts/lib/src/repositories/what_if_api.dart   ← «…what_if_api.dart:1»
  ls docs/ai-context/send/R11a-Bob-S74.md                                                               ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls docs/ai-context/inbox/S7-4_questions.md                                                            ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m7/m7_deposit_plan_blocked.json                                 ← 보여야 함
  ls packages/domain_contracts/fixtures/m7/m7_deposit_register_receipts_4.json                          ← 보여야 함
  ls packages/domain_contracts/fixtures/m9/contribution_setting_default.json                            ← 보여야 함
  ls packages/ui_analytics/lib/src/widgets/analytics_error_view.dart                                    ← 보여야 함(R10a)
  ls packages/ui_analytics/lib/src/chart/perf_chart_geometry.dart                                       ← 보여야 함(R10c 가 병합된 것)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 세 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R11a 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/planner.dart                                                             ← 없어야 함
  ls packages/ui_analytics/lib/src/planner                                                              ← 없어야 함
  git grep -c plannerIntroLine -- packages/ui_analytics/lib                                             ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.4 새 타입(DepositPreviewResult · PensionLimitVm …)과 새 필드의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: 196 통과 · 0 실패(병합본 · 드라이런 실측 = M2 로컬 196 · 수가 다르면 PR 본문에 까닭 한 줄). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §14(14-1~14-8) · §12-3 > 03 §9 의 R11 범위 블록 > 03 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox 만.
   새 파일 = lib/planner.dart · lib/src/planner/**(파일은 아래 «주입 구조») · test/planner_fakes.dart · test/deposit_planner_view_test.dart · test/golden/s74_golden_test.dart · test/golden/goldens/s74_*.png 14장.
   고치는 기존 파일 = lib/l10n/labels.dart 하나 — **끝에 더하기만**(R10c 절 뒤에 🆕 R11a 절 · 기존 줄 diff 0 · R11b 가 그 뒤에 자기 절을 더한다).
   고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml(decimal 추가 = C-3 실패) · analysis_options.yaml · test/flutter_test_config.dart ·
   test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·goal_path_probe_test·reference/**·README·기존 골든 테스트 5파일(s71·s71b·s72·s72g·s73) ·
   goldens/ 의 기존 PNG 42장(s71_* 10 · s73_*·s73b_* 8 · s71b_* 4 · s72g_* 8 · s72_* 12) ·
   lib 의 기존 파일 전부(labels.dart 끝 더하기 제외) — lib/ui_analytics.dart(배럴) · src/providers/analytics_providers.dart · src/screens/**(explore/ 포함) · src/chart/** · src/widgets/** ·
   기존 테스트 전부 — contribution_view · drawdown_context_view · monthly_report_view · performance_explore_gate(G13 포함) · performance_explore_view · perf_chart_geometry · report_archive_view · ui_analytics_test · explore_fakes.
   🔴 기존 PNG 42장은 하나라도 M 이면 되돌리고 멈춤 · 예외 없음.
   test/explore_fakes.dart(R10b·R10c)는 **import 만** 한다(test/planner_fakes.dart 안에서 import 'explore_fakes.dart' show FakeSafetyRepository; — 같은 test/ 폴더라 '../' 없음 · 한 줄도 바꾸지 않는다).
 2 03 §9 본문의 구 초안(「데이터」·「컴포넌트·흐름」의 4스텝·AccountRouting·초안 PensionLimitVm{usedText, remainText, deadlineDDayText}·「시나리오 저장」·「플랫폼」 웹 2열·
   그림 M7-15·M7-16)은 03 §9 의 R11 범위 블록(머리글 «🆕 계약 v1.4 — `S7-4` R11 범위»)과 01 §14 에 집니다. 설계서에 보이는 expiredText 는 없다(registerBlockedText 하나로 합쳤다) — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read). 이 카드의 링크는 둘뿐이다:
   ⓐ BlockFlag.clearDeepLink — SafetyBlockBanner(activeFlags:, onOpenLink: (link) => ref.read(analyticsLinkOpenerProvider).open(link)) 가 부른다
   ⓑ DepositPreviewResult.blockedAction.deepLink — 차단 카드의 버튼.
   🔴 AppRoutes 상수를 쓰지 않는다(0개) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 사유 칩은 누를 수 없다(ReasonChip.detailDeepLink 를 읽지 않는다 · D20) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯 생성자에는 key 뿐(const DepositPlannerScreen({super.key})).
 4 값 = DTO 의 *Text·*Label·label·stateLabel·previewNotice 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) ·
   원값(Decimal·int·DateTime·TradeDate)·.wire 표시 금지 · 폴백 문구·자리표시자(«0원»·«해당 없음»·«-») 금지 — null 이면 **부재**, non-null 이면 그대로 ·
   색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
 5 읽지 않는 필드(카드가 정함 — 질문 아님):
   ⓐ 01 §14-4 «읽지 않는 필드»(C-38 ⑩ 이 CI 에서 본다): DepositPlan.computedAt · expiresAt · asOfTradeDate · depositAmount · pensionLimitConsumed · residualKrwCash /
      OrderDraft.side · quantity · limitPrice / CostEstimate.commission · tax · total / FundingStep.quantity · expectedProceeds · sourceSleeve · ruleCited /
      SleeveAllocation.amount / ContributionSetting.amount / ReasonChip.detailDeepLink
   ⓑ 이 카드가 더 정함: DepositPlan.configHash / SleeveAllocation.sleeve / OrderDraft.symbol · sleeve / CostEstimate.source / FundingStep.order · symbol · symbolLabel
      (조달 행은 받은 목록 순서대로 label 만 — order 로 정렬하지 않는다 · 01 §14-4 표·03 §9 ⓓ 의 «order 순»은 엔진이 order 순으로 보낸다는 뜻이다 — 화면은 받은 순서 그대로 · 질문 아님) / ReasonChip.code / ContributionSetting.lastChangedText(설정 문장은 4줄뿐 — 03 §9 ⓒ) /
      SafetyState 는 activeFlags 하나 / AsOf 는 label(StaleBanner 에는 asOf 를 그대로 넘긴다) /
      CommandReceipt 는 stateLabel(그린다)과 commandId(watchCommand 인자) 둘만 / DepositPlan.planId 는 DepositRegistration(planId:) 인자로만(그리지 않는다).
   🔴 C-38 ⑩ 정규식은 `(?<!Labels)\.(expiresAt|computedAt|asOfTradeDate|depositAmount|residualKrwCash|pensionLimitConsumed|quantity|limitPrice|side|commission|tax|total|expectedProceeds|sourceSleeve|ruleCited|amount|detailDeepLink)\b`
      이다 — 플래너 파일(lib/planner.dart · lib/src/planner/**)에서는 **어떤 객체에도** .side · .total · .amount · .tax · .quantity 를 쓰지 않는다(지역 변수·다른 타입도 걸린다).
      패턴 분해(DepositPlan(:depositAmount) · OrderDraft(quantity: final q))도 걸린다. amountText · amountInputText · quantityText · sideLabel · totalText · depositAmountText ·
      limitPriceText · residualKrwCashText 는 걸리지 않는다(\b).
      또 DepositPreviewResult · DepositPlan · OrderDraft · DepositRegistration · simulateDeposit · registerDeposit 라는 말은 플래너 파일 **밖**의 ui_analytics/lib 에 쓰지 않는다(C-38 ⑩ 가드).
 6 화면 산술 0 — 합계 검산·차액·비율·잔여·한도·D-day·세액을 계산하지 않는다(합이 안 맞아도 그대로 그리고 질문 파일에) · 목록을 거르지도 세지도 정렬하지도 묶지도 않는다.
   🔴 입력칸 글자는 **고치지 않는다** — controller 의 글자를 그대로 simulateDeposit(amountInput:) 에 넘긴다.
      replaceAll · replaceFirst · .trim( · int.parse · num.parse · double.parse · tryParse · inputFormatters 0(정적 묶음 S03) · 빈칸이어도 버튼은 눌린다(판정은 엔진 — inputRejectedText).
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드의 switch 는 둘뿐: private enum _PlannerStep { input, allocation, result } 과 ChipTone(사유 칩 색).
   🔴 값 이름에 amount 를 쓰지 않는다 — _PlannerStep.amount 는 C-38 ⑩ 정규식에 걸려 test:contracts 가 빨갛다(드라이런 실측 · 규칙 5).
   🔴 CommandState 로 갈래·문구를 고르지 않는다(lib 에 CommandState 0건) · rejectReasonCode 를 읽지 않는다 · flagId 로 입력칸·계산 버튼을 끄지 않는다(D21 — 막는 것은 엔진 blockedText) ·
      operatingMode · RunMode 로 분기하지 않는다 · 세 결과 갈래는 «plan · inputRejectedText · blockedText 중 무엇이 non-null 인가» 하나로만 가른다(문장을 해석하지 않는다).
 8 시계 = analyticsClockProvider(DateTime.now() 금지) — 이 카드에서 시계를 읽는 곳은 StaleBanner 안뿐이다(화면 코드는 시계를 읽지 않는다 · expiresAt 을 시계와 비교하지 않는다).
   공통 상태 = 스켈레톤(AnalyticsSkeleton · 스피너 금지) · 에러 = AnalyticsErrorView(재시도 = 아래 «화면» 대로 · lastAsOfLabel 은 넘기지 않는다) ·
   오래됨 = StaleBanner(asOf: plan.asOf)(스텝 ②③ 만 · 스텝 ① 에는 없다 — 설정은 시세가 아니다) · 차단 = SafetyBlockBanner(배너만 · 값을 가리지 않는다) + 엔진 blockedText 문장 카드.
   배너는 안전 상태에서 오므로 설정·계산이 로딩·에러여도 그 자리에 있다.
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible(또는 Wrap) · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지 ·
   390px overflow 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(정적 글자는 아래 15개뿐).
10 프로바이더: 새 것은 lib/src/planner/planner_providers.dart 의 4개뿐(아래 «주입 구조» 글자 그대로) · 배너·링크·시계는 새로 만들지 않는다 —
   lib/src/providers/analytics_providers.dart 의 safetyStateStreamProvider · analyticsLinkOpenerProvider · analyticsClockProvider(StaleBanner 가 안에서 읽는다)를 import 해 쓴다(방향 planner → 배럴 쪽만 · C-35 ⑥).
   🔴 analytics_providers.dart · 배럴은 한 줄도 바꾸지 않는다 · 계산 결과(DepositPreviewResult · DepositPlan)는 **State 에** 둔다(프로바이더 금지 · 들어올 때마다 처음부터).
   오프너·WhatIfApi·CommandApi 는 탭 콜백 안에서 ref.read — build 에서 read 금지. 예외 하나 — 설정 첫 값으로 입력칸을 채우는 ref.listenManual(initState · 아래 코드 틀).
11 테스트 = testing.dart 받침대 extends(UnimplementedWhatIfApi · UnimplementedConfigRepository · UnimplementedCommandApi · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO·CommandReceipt 를 지어 넣지 않는다(픽스처 행에서 — 예외는 셋: T74-02 ⓒ 의 setting.copyWith(amountInputText: …) · T74-08 의 plan.copyWith(pensionLimit: null) · T74-11 의 ReasonChip 의 copyWith(tone: …)
   (그 칩을 넣으려고 draft·plan·preview 를 copyWith 로 잇는 사슬은 허용 — 바뀌는 값은 tone 하나) — 줄 하나만 바꾸고 값을 지어내지 않는다 · 03 §9 ⓓ·ⓗ) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 등록 인자 기대값은 테스트가 listFixture/singleFixture 로 **따로** 디코드한 plan.planId 에서(화면 State 에서 읽지 않는다) ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'T74-06 rejected and blocked stay on step one').
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다 ·
   스켈레톤 1 = expect(find.byKey(const Key('s74-…-loading')), findsOneWidget) + 그 위젯이 AnalyticsSkeleton 인지(tester.widget<AnalyticsSkeleton>(…)) — 스피너 부재로 대신하지 않는다 ·
   if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 ⓡ = 정상 상태 테스트의 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 줄 — **한 줄에 하나** · 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄로 남게 둔다
      (들여쓰기가 깊으면 format 이 접어 grep 이 못 센다 — 루프 안이면 루프 첫머리에) · 줄 수는 정적 묶음 S26 의 grep -c 출력이 증거다.
   🆕 ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(<숫자>)) 전제 줄 — hasLength 전제를 루프 안의 if·firstWhere 로 대신하지 않는다
      (항목별 null 갈래의 if/else 양쪽 단언은 허용 · 의무 — T74-07·T74-11) · 호출 수 단언(simulateCalls · registrations · watchedIds)도 hasLength 로 쓴다 ·
      정적 묶음 S27 은 hasLength( 가 든 줄 **전부**(ⓗ 전제 + 호출 수 단언)를 센다 — 그 grep -c 출력이 증거다.
   🆕 한 testWidgets 안에서 다시 띄울 때(«마다» · «새로 띄워» · «두 장면»)는 늘 pumpPlanner 를 다시 부른다 — pumpPlanner 가 먼저 빈 위젯을 띄워 앞 장면의 State·프로바이더를 버린다(탭으로 되돌아가 재사용하지 않는다).
12 골든 = 이 카드의 새 PNG 14장만 · --update-goldens 는 새 테스트 파일 하나(test/golden/s74_golden_test.dart)를 지정(폴더 지정 금지) · golden:approved 는 안 붙임 · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이).
13 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…) — future.then(…) 도 unawaited 로 감싼다) · close_sinks 린트.
14 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다
   (이 카드에 그런 식별자가 많다 — _amountController · residualKrwCashText · limitPriceText · plannerAmountFieldLabel …). 글자 잇기는 보간 '${a}${b}' · 레이아웃 상수 산술도 그 이름 옆에서 하지 않는다.
15 C-38 ⑫ — ui_analytics/lib 전체(labels.dart·**주석 포함**)에 세율·기대 수치(16.5 · 9.7 · 10.2 · 10.63 · 10.85 · 10.91 · 10.96 · 11.13 · 12.5x · 12.60)와
   월 납입 금액(100000 · 100_000 · 100,000 · 10만 · 9만 · 9.7만 · 2,000만 · 1,800만 · 1억 · …만원)을 쓰지 않는다(정적 묶음 S24·S25). 주석에 픽스처 값을 옮겨 적지 않는다.
16 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
17 정적 묶음은 git grep 이라 **주석도 센다**(C-38 은 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 플래너 파일(lib/planner.dart · lib/src/planner/**)의 주석에 이 낱말을 쓰지 않는다:
   AppRoutes · CommandState · Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · GestureDetector · Colors · estimateCosts · findPlan · previewRebalance · simulateWithdrawal ·
   replaceAll · replaceFirst · .trim( · int.parse · tryParse · inputFormatters · ActionChip · detailDeepLink · rejectReasonCode · expiresAt · computedAt · autoDispose · analyticsLinkOpenerProvider.
   analytics_providers.dart 는 show 없이 import 한다 — S05 에는 배너 onOpenLink 1줄과 차단 버튼 1줄만 나와야 한다.
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20 은 주석 줄도 센다(작은따옴표 뒤 같은 줄에 한글이 있으면 1건 · 기대 0건 ·
      예 «// 's74-intro' 정적 안내 1줄» 이 1건이다 → ② 3번 괄호 «정적 묶음 S20 — 0건» 이 출력과 달라져 반려).
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10a~R10c 교훈 · 발주자 결정 5) — 🔴 «보고와 코드·파일·PNG 가 1건이라도 다르면 재량 없이 반려» 입니다(R10b 부터 적용).
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모).
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M7.md 155~169행 12항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 ·
   항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다).
   🆕 정적 묶음 S05 결과 줄마다 사람이 적는 줄은 **정확히** «<파일>:<줄> — 탭 콜백 안» 만 — 정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ 와 완전히 같아야 합니다.
      괄호·위젯 이름·매개변수 이름·설명을 붙이지 않습니다(R10c 2회차 strict 반려 사유 = «…:103 — 탭 콜백 안 (SafetyBlockBanner onTap)» — 코드에 onTap 이 없었다).
   🆕 ⓡ·ⓗ 줄 수는 정적 묶음 S26·S27 의 grep -c 출력이 증거입니다 — 손으로 센 수를 따로 적지 않습니다(PR 본문에 적은 수가 grep -c 출력과 다르면 보고 불일치 = 반려 ·
      카드의 드라이런 실측과 다른 것은 반려 사유가 아니다 — 테스트 짜임에 따라 줄 수가 달라진다 · PR 본문에 까닭 한 줄 · 하한 = 테스트 목록의 ⓡ·ⓗ 표식마다 소스 1줄 이상).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.
   ③ 은 코드의 위젯·Key 이름을 위 → 아래 순서 그대로 «→» 로 잇습니다 — «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어는 코드와 PNG 를 다시 열어 맞을 때만(R10c 1회차 반려 사유).

■ 프롬프트보다 이 카드가 이긴다 — 19항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 11~12행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변 · decimal 을 넣으면 C-3 실패 · 입력은 String 그대로 넘긴다)
 ② 13~14행 «다른 화면으로는 라우트 상수로 딥링크만» → 이 카드의 이동은 DTO 링크 둘(규칙 3 ⓐⓑ)을 AppLinkOpener.open 에 그대로 · AppRoutes 상수 0
 ③ 15~17행 DateTime.now() 금지 → 그대로 + 시계를 읽는 곳은 StaleBanner 안뿐(화면이 expiresAt 을 시계와 비교하지 않는다 · 만료는 registerBlockedText)
 ④ 19~22행 «허용되는 산술은 레이아웃뿐 · 입력은 0.0~1.0 정규값» → 이 카드에는 정규값도 차트도 없다 — 화면 산술 0(레이아웃 상수뿐)
 ⑤ 39~42행 «딥링크 목적지 목록 · 없으면 자리표시자» → 목적지는 DTO 문자열 그대로(목록과 대조하지 않는다 · aaq://x2/resume-report 도 픽스처 값으로만) · 자리표시자 금지(없으면 부재 · 질문 파일)
 ⑥ 47·68행 «띠 높이를 비워 두기» → 예약 안 함(01 §9)
 ⑦ 52~55행 금액 리터럴 금지 → 그대로 유효 · «같은 값을 네 자리가 그린다»는 v1.4 에서 셋(S7-9 는 ConfigRepository 를 읽지 않는다) · «CI 에 걸린다»의 실제 강제 = C-38 ⑫(CI) + 정적 묶음 S24·S25
 ⑧ 89행 «자체 점검 10항» → 155~169행 12항(이 카드 밖 4·5·7·8·12 와 10 앞절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑨ 89~90행 스크린샷 4장 → 서술 + 골든 표(«제출» ③) ⑩ 88~89행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅)
 ⑪ 98~100행 TODO(question-3)·«M2 미정의» → 자리표시자 금지 · 질문 파일로 · 이 화면의 타입은 코드에 확정(v1.4)
 ⑫ 103~107행 역할 문단 «폰 레이아웃 먼저 … 반응형으로 넓히기» → 범위 = 이 카드의 S7-4 · 폰 세로 하나 · 넓히지 않는다(폰 전용 · 결정 2)
 ⑬ 110~115행 «읽을 문서 5개» → 아래 «먼저 읽을 것» ⑭ 117행 브랜치 형식 → ui/m7-s74-planner
 ⑮ 132~134행 플래너 — «계산을 전부 M3 미리보기 호출로» = 그대로 · «상단 «미리보기입니다» 고지 상시» → **결과가 그려진 단계(스텝 ②③)에서 상시**(스텝 ① 은 정적 안내 1줄 · 결정 4 · 수용 (b) 정정) ·
    «즉시 vs 다음 리밸런싱 대기 비교» → 없음(연기 · 01 §8 미결 66) · «등록은 명령 API 1회 호출 + 게이트 화면 핸드오프» → registerDeposit 1회만 · 핸드오프 없음(미결 68)
 ⑯ 119~126·135~144행(S7-2 결정 8 · 기간 프리셋 · S7-8 · 세후 사다리 · 목표 경로 가정 카드) → 이 카드 범위 밖(S7-9 = R11b) · 142~144행의 «월 9만원»·«100,000원» 은 서술일 뿐 — 코드·주석·labels 에 쓰지 않는다(규칙 15)
 ⑰ 151행 «인출 가능 금액 비율» → R11c(보류) · «주(週)» 는 이 카드와 무관 · 152~153행 «모의 체험 리포트» 는 그대로 유효(만들지 않는다)
 ⑱ 154행 «명세 §12와 1:1» → 무시 · 12항 = «■ 제출» ② 의 복사 상자
 ⑲ 108행 «이번 과제 범위»와 117행 PR 제목 치환값은 R11 두 장(R11a·R11b)을 함께 적은 것이다 — 이 카드의 범위·PR 제목은 이 카드 머리(«범위»)와 «■ 제출» 이 정한다
 (23~24행 «건수 집계도 재계산» · 94~95행 «기존 스냅샷을 다시 찍는 것은 위조»는 그대로 유효 — 이 카드에는 예외가 없다.)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문 ② 01 §14-1~§14-8(특히 14-3 세 갈래·D21 · 14-4 null 규칙 표·«읽지 않는 필드» · 14-5 · 14-7 잠금 · 14-8 호출 표) + §12-3(접수 실패 1줄)
 ③ 03 §9 의 R11 범위 블록 — 머리글 «🆕 계약 v1.4 — `S7-4` R11 범위»(ⓐ~ⓗ + 골든 표 · 찾는 말 = «`S7-4` R11 범위(»(같은 말의 §14 블록은 S7-9 몫 — 읽지 않는다) · 「모의」 줄 바로 아래 · 그림 M7-15 앞 — 위쪽 본문과 그림은 «구 초안»이라 블록이 이긴다)
 ④ packages/domain_contracts/lib/ — src/dto/plan.dart(DepositPreviewResult · DepositPlan · PensionLimitVm · OrderDraft · SleeveAllocation · CostEstimate · FundingStep) ·
    src/dto/settings.dart(ContributionSetting) · src/dto/common.dart(ReasonChip · LinkAction) · src/enums/ui.dart(ChipTone) ·
    src/repositories/what_if_api.dart · src/repositories/config_repository.dart(watchContributionSetting) · src/commands/command_api.dart(registerDeposit · watchCommand) ·
    src/commands/payloads.dart(DepositRegistration) · src/commands/command_receipt.dart ·
    testing.dart(UnimplementedWhatIfApi — 전부 Future 에러 · UnimplementedConfigRepository · UnimplementedCommandApi · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R11(계약 v1.4)» 절(골든 표) + «규칙»·«하네스» 절 + «🆕 R10» 절의 «2. 높이와 위치 전제»(찍기 전 단언 모양)
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 ·
    lib/src/widgets/safety_block_banner.dart · stale_banner.dart · analytics_skeleton.dart · analytics_error_view.dart ·
    lib/src/screens/explore/performance_explore_body.dart(배너·오프너·watchCommand 구독의 모양만 본다 — 고치지 않는다) ·
    test/explore_fakes.dart(FakeSafetyRepository · 가짜 모양 — import 만) · test/golden/golden_support.dart · test/golden/s72g_golden_test.dart(골든 파일 모양) ·
    test/performance_explore_gate_test.dart 의 G13(배럴이 planner 를 export 하지 않는지 본다 — 고치지 않는다)
 ⑦ packages/domain_contracts/fixtures/README.md 의 v1.4 절 + 이 카드가 쓰는 픽스처 9건 + 안전 상태(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · S7-4_questions.md 의 머리말

■ 본받지 않는 것 (ui_analytics·ui_journal 의 기존 코드·문서에 남아 있는 다른 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → AnalyticsSkeleton · AnalyticsErrorView(R10a · 이미 main)
 · ui_journal 의 사유 칩 ActionChip(누르면 핸드북) → 플래너 칩은 Chip · 탭 0 · detailDeepLink 미참조(D20 · 01 §14-4)
 · performanceSeriesProvider 처럼 결과를 family 프로바이더에 두는 모양 → 플래너의 계산 결과는 State(버튼을 눌렀을 때만 부른다)
 · 03 §9 구 초안(4스텝 · AccountRouting · usedText/remainText/deadlineDDayText · 시나리오 목록 · 웹 2열 · M5 핸드오프) · 설계서의 expiredText · «반대로 인출하면?»
 · 테스트의 class … implements …Repository · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · 띄우기 도우미 pumpPlanner 한 벌
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s74-…)
 · 주석에 Key·글자를 작은따옴표로 인용하는 모양(// 's74-…') → 백틱(규칙 17 · 정적 S20 이 주석도 센다)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변 · import 만): analyticsClockProvider · analyticsLinkOpenerProvider · safetyRepositoryProvider · safetyStateStreamProvider(전부 lib/src/providers/analytics_providers.dart) ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsSkeleton({super.key, this.blocks = 4}) · AnalyticsErrorView({super.key, required this.onRetry, this.lastAsOfLabel}) ·
  AnalyticsLabels.retryButton · staleBannerTitle.
  (플래너 파일은 상대 import 로 필요한 파일만 가져온다 — '../providers/analytics_providers.dart'(show 없이 · 규칙 17) · '../widgets/…' · '../../l10n/labels.dart'. 배럴 package:ui_analytics/ui_analytics.dart 를 lib 안에서 import 하지 않는다.)
· 🆕 lib/planner.dart — export 는 이 두 줄뿐(T74-22 가 집합을 본다 · 머리 주석은 재량):
    export 'src/planner/deposit_planner_screen.dart';
    export 'src/planner/planner_providers.dart';
· 🆕 lib/src/planner/planner_providers.dart — 이 4개뿐(이름·타입 글자 그대로 · 🔴 주석에 autoDispose 라는 말을 쓰지 않는다 — 정적 S22 가 센다):
    final Provider<WhatIfApi> plannerWhatIfApiProvider = Provider<WhatIfApi>((ref) {
      throw UnimplementedError('plannerWhatIfApiProvider must be overridden');
    });
    final Provider<ConfigRepository> plannerConfigRepositoryProvider = Provider<ConfigRepository>((ref) {
      throw UnimplementedError('plannerConfigRepositoryProvider must be overridden');
    });
    final Provider<CommandApi> plannerCommandApiProvider = Provider<CommandApi>((ref) {
      throw UnimplementedError('plannerCommandApiProvider must be overridden');
    });
    final AutoDisposeStreamProvider<ContributionSetting> plannerContributionSettingProvider =
        StreamProvider.autoDispose<ContributionSetting>((ref) {
          return ref.watch(plannerConfigRepositoryProvider).watchContributionSetting();
        });
· 🆕 lib/src/planner/deposit_planner_screen.dart — const DepositPlannerScreen({super.key}) · ConsumerStatefulWidget · 공개 위젯은 이것 하나.
  내부 위젯·도우미는 lib/src/planner/ 안의 비공개(밑줄) 이름 · 파일을 더 나눠도 된다(lib/src/planner/ 아래만 · export 하지 않는다 · 재량).
· 배럴 lib/ui_analytics.dart · analytics_providers.dart 는 고치지 않는다(G13 이 배럴에 src/planner export 0 을 본다 · C-35 ⑥ 이 배럴 쪽의 planner import 를 막는다).
  테스트는 package:ui_analytics/planner.dart(화면·프로바이더) + package:ui_analytics/ui_analytics.dart(라벨·공용 프로바이더) + package:ui_analytics/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · safety_block_banner.dart · stale_banner.dart 를 import
  (배럴이 export 하지 않는다 — find.byType(StaleBanner) · find.byType(SafetyBlockBanner) 에 필요 · 드라이런 실측).

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / listFixture / fixtureEnvelope · 행 타입 = DepositPreviewResult 래퍼)
 설정      m9ContributionSettingDefault(pensionLimitNoteText 있음) · m9ContributionSettingNoLimitNote(없음) — singleFixture(…, ContributionSetting.fromJson)
 결과      m7M7DepositPlanDefault(plan · 배분 3 · 잔여 있음 · 한도 카드(제안·조달 안내 없음) · 초안 4 · 경고 0 · 조달 null · 등록 가능) ·
           m7M7DepositPlanLimit(plan · 배분 2 · 초안 0 + ordersEmptyText · 한도 카드(제안·조달 안내 있음) · 경고 1) ·
           m7M7DepositPlanExpired(plan · registerBlockedText(만료) · 기준일이 오래돼 kGoldenNowUtc 에서 StaleBanner 가 보인다) ·
           m7M7DepositPlanFunding(plan · 조달 1단 · 잔여 없음 · 초안 한 줄에 지정가 없음·미확정 줄 · registerBlockedText(RECON)) ·
           m7M7DepositPlanInputRejected(inputRejectedText 만) — 여기까지 singleFixture(…, DepositPreviewResult.fromJson)
           m7M7DepositPlanBlocked(🔴 2행 — listFixture(…).rows[0] = blockedText 만(버튼 없음) · rows[1] = blockedText + blockedAction(재개 리포트))
 접수증    m7M7DepositRegisterReceipts4 — listFixture(…, CommandReceipt.fromJson).rows · 행 순서가 뜻(0 REQUESTED · 1 EXECUTED · 2 EXPIRED · 3 HELD_FOR_INTEGRITY · 같은 commandId)
 안전      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상 · 3 차단 2건(RECON_MISMATCH · JOURNAL_MISSING) · 4 LEDGER_INTEGRITY
 🔴 코어 전용 deposit_plan_1 · deposit_plan_funding_1(행 = DepositPlan)은 화면에 쓰지 않는다. 픽스처끼리 이어 붙인 시나리오를 만들지 않는다. 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 — S7-4 DepositPlannerScreen (03 §9 R11 블록 ⓒⓓ · 01 §14-3·14-5·14-7·14-8)
 State(이름은 재량 · 뜻은 고정):
   _PlannerStep _step(첫 값 input) · TextEditingController _amountController · bool _seeded · bool _touched ·
   Future<DepositPreviewResult>? _pending(기다리는 계산 — 마지막 요청) · String _lastInput(직전 글자) ·
   DepositPlan? _plan · String? _rejectedText · String? _blockedText · LinkAction? _blockedAction · bool _calcFailed ·
   bool _submitting · bool _notAccepted · CommandReceipt? _receipt · StreamSubscription<CommandReceipt>? _subscription.
   dispose 에서 _subscription?.cancel() · _amountController.dispose().
 입력칸 첫 값(initState — 이 모양으로 · 🔴 «첫 값만» · «아직 건드리지 않았을 때만»):
   ref.listenManual<AsyncValue<ContributionSetting>>(plannerContributionSettingProvider, (previous, next) {
     final ContributionSetting? setting = next.valueOrNull;
     if (setting == null || _seeded || _touched) return;
     _seeded = true;
     _amountController.text = setting.amountInputText;
   }, fireImmediately: true);
   TextField 의 onChanged: (_) => _touched = true(사용자 편집만 · 프로그램이 넣은 글자는 onChanged 를 부르지 않는다).
   🔴 setting.amount 로 만들지 않는다 · 이후 스트림 값은 입력칸을 덮지 않는다(설정 문장만 새 값으로 다시 그린다).
 계산(«미리보기 계산» 탭 = _calculate(_amountController.text) · 에러 뷰 재시도·«다시 계산» = _calculate(_lastInput)) — 이 모양으로:
   final Future<DepositPreviewResult> future = ref.read(plannerWhatIfApiProvider).simulateDeposit(amountInput: input);
   setState(() { _pending = future; _lastInput = input; _rejectedText = null; _blockedText = null; _blockedAction = null; _calcFailed = false; _notAccepted = false; });
       ← _notAccepted 도 지운다: 새 계산이 시작되면 옛 계획의 접수 실패 줄이 새 계획 위에 남지 않는다(드라이런 Q3 · T74-18 ⓑ)
   unawaited(future.then((DepositPreviewResult result) {
     if (!mounted || !identical(future, _pending)) return;            ← 🔴 마지막 요청의 결과만(늦게 온 이전 결과는 버린다)
     final DepositPlan? plan = result.plan;
     setState(() {
       _pending = null;
       if (plan != null) { _plan = plan; 스텝 ① 에서 눌렀으면 allocation · 스텝 ③ 의 «다시 계산»이면 result 그대로 }
       else { _plan = null; _step = input; _rejectedText = result.inputRejectedText; _blockedText = result.blockedText; _blockedAction = result.blockedAction; }
     });
   }, onError: (Object error, StackTrace stack) {
     if (!mounted || !identical(future, _pending)) return;
     setState(() { _pending = null; _plan = null; _step = input; _calcFailed = true; });
   }));
   🔴 계산 Future 에러는 FlutterError.reportError 하지 않는다(에러 뷰가 말한다 · 에러 내용으로 분기하지 않는다 · T74-05 가 takeException == null 을 본다).
   🔴 plan 이 아니면 옛 plan 을 버리고 스텝 ① 로 돌아가 그 자리(입력칸 아래 1줄 · 차단 카드 · 에러 뷰)에 그린다 — 입력칸 글자는 그대로(01 §14-8).
 등록(«이 계획으로 입금 등록» 탭 = unawaited(_register(plan)) · plan = 지금 그려진 _plan) — 이 모양으로:
   setState(() { _submitting = true; _notAccepted = false; });
   final CommandApi api = ref.read(plannerCommandApiProvider);
   try {
     final CommandReceipt receipt = await api.registerDeposit(DepositRegistration(planId: plan.planId));
     if (!mounted) return;
     setState(() { _submitting = false; _receipt = receipt; });
     _subscription = api.watchCommand(receipt.commandId).listen(
       (CommandReceipt next) { if (mounted) setState(() => _receipt = next); },
       onError: (Object error, StackTrace stack) {
         FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'ui_analytics'));   ← 마지막 글자 유지
       });
   } catch (error, stack) {
     FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'ui_analytics'));
     if (!mounted) return;
     setState(() { _submitting = false; _notAccepted = true; });   ← 01 §12-3 접수 실패 1줄 · 버튼 재활성
   }
   🔴 StreamProvider 로 감싸지 않는다(에러가 삼켜진다) · 낙관 갱신 금지 · 접수증이 오면 잠금(아래 스텝 ③) · 종결 접수증(EXPIRED·HELD_FOR_INTEGRITY)이어도 잠금 유지 ·
    다시 하려면 화면을 나갔다 들어온다(이 카드에는 되돌리는 버튼이 없다).
 build: switch (_step) 전수 · 배너 = ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ?? const <BlockFlag>[] ·
   배너 위젯은 한 곳(비공개 도우미 하나)에서 만든다 — if (activeFlags.isNotEmpty) SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (link) => ref.read(analyticsLinkOpenerProvider).open(link)).

 스텝 ① — 배치(위 → 아래)
   1 SafetyBlockBanner(있을 때)                                                    ← 스크롤 밖 · Column 첫째
   ── 이하 Expanded(ListView(key: Key('s74-list-input'), padding 16)[ … ]) ──
   2 Text(AnalyticsLabels.plannerStepAmountTitle)                                  Key s74-step-title
   3 Text(AnalyticsLabels.plannerIntroLine)                                        Key s74-intro
   4 Text(AnalyticsLabels.plannerCurrentSettingHeader)                             Key s74-setting-header
   5 설정 자리 = ref.watch(plannerContributionSettingProvider) 의 갈래:
       로딩(첫 값 전) = AnalyticsSkeleton(key: Key('s74-setting-loading'), blocks: 2)
       에러 = AnalyticsErrorView(key: Key('s74-setting-error'), onRetry: () => ref.invalidate(plannerContributionSettingProvider))
       값 = Text(setting.amountText) Key s74-setting-amount · Text(setting.equivalentNoteText) Key s74-setting-equivalent · Text(setting.appliesFromText) Key s74-setting-applies ·
            (pensionLimitNoteText != null) Text(그 글자) Key s74-setting-limit-note · Text(setting.asOf.label) Key s74-setting-asof
       🔴 설정이 로딩·에러여도 6·8 은 그대로 있다(판정 금지 — 빈칸으로 눌러도 엔진이 inputRejectedText 로 답한다).
   6 TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AnalyticsLabels.plannerAmountFieldLabel), onChanged: …)   Key s74-amount-field
       🔴 enabled·readOnly·inputFormatters·maxLength 를 주지 않는다.
   7 (_rejectedText != null) Text(_rejectedText, 색 = colorScheme.error)                Key s74-input-rejected     ← 입력칸 바로 아래 1줄
   8 FilledButton(onPressed: () => _calculate(_amountController.text), child: Text(AnalyticsLabels.plannerCalculateButton))   Key s74-calculate
       🔴 기다리는 동안에도 눌린다(onPressed 를 null 로 만들지 않는다 — 다시 누르면 새 요청 · 마지막 요청만 반영 · T74-20).
   9 결과 자리(아래 하나만 · 없으면 부재):
       기다림(_pending != null) = AnalyticsSkeleton(key: Key('s74-result-loading'), blocks: 3)
       에러(_calcFailed) = AnalyticsErrorView(key: Key('s74-result-error'), onRetry: () => _calculate(_lastInput))
       차단(_blockedText != null) = Card(key: Key('s74-blocked-card'), child: Padding(12, Column[ Text(_blockedText) ,
            (_blockedAction != null) OutlinedButton(key: Key('s74-blocked-action'), onPressed: () => ref.read(analyticsLinkOpenerProvider).open(action.deepLink), child: Text(action.label)) ]))
   🔴 스텝 ① 에는 «다음»·«이전»·previewNotice·StaleBanner 가 없다. 앞으로 가는 길은 «미리보기 계산» 하나다.

 스텝 ② ③ — 공통 머리(위 → 아래 · 스크롤 밖 · 01 §14-5 · 03 §9 ⓓ)
   1 Padding(16, Text(plan.previewNotice))                                         Key s74-preview-notice    ← Column 맨 위 · Expanded 밖(스크롤해도 고정)
   2 StaleBanner(asOf: plan.asOf)                                                  ← 유예 초과일 때만 보인다(위젯이 스스로 판정)
   3 SafetyBlockBanner(있을 때)
   ── 이하 Expanded(ListView(key: ② Key('s74-list-allocation') / ③ Key('s74-list-result'), padding 16)[ … ]) ──
   🔴 스텝마다 목록 Key 가 달라야 한다 — 같거나 없으면 «다음» 뒤 스텝 ③ 이 스텝 ② 의 스크롤 위치를 물려받아 중간부터 열린다(드라이런 실측 · T74-09 가 본다).
   4 Text(스텝 제목 — ② plannerStepAllocationTitle / ③ plannerStepResultTitle)     Key s74-step-title
   5 Text(plan.asOf.label)                                                         Key s74-asof
   6 warningLines — 받은 순서대로 한 줄씩 Text(line)                                  Key s74-warning-<순번>(0 부터)
 스텝 ② 본문(6 다음)
   7 Text(plan.depositAmountText)                                                  Key s74-deposit-amount
   8 배분 행 — allocations 받은 순서대로 한 행씩 Column(key: Key('s74-allocation-<순번>'))[
        Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8)[ Text(a.label) , Text(a.amountText) ] ,   ← 한 줄에 들어가면 라벨 왼쪽 · 금액 오른쪽 끝 · 안 들어가면 금액이 다음 줄(잘림 0)
          (🔧 Row[ Expanded(라벨) , Flexible(금액) ] 은 폭을 반씩 나눠 라벨이 두 줄로 접히고 금액이 행 가운데에 붙었다 — 드라이런 PNG 실측)
        (a.accountAlias != null) Text(그 글자)       Key s74-allocation-<순번>-account ,
        (a.routingReasonText != null) Text(그 글자)  Key s74-allocation-<순번>-reason ]
   9 (plan.residualKrwCashText != null) Text(그 글자)                             Key s74-residual
  10 (plan.pensionLimit != null) Card(key: Key('s74-pension-limit'))[ Text(AnalyticsLabels.plannerPensionLimitTitle) , Text(annualLimitText) , Text(taxCreditText) , Text(deadlineText) ,
        (suggestionText != null) Text  Key s74-pension-suggestion , (fundingNoteText != null) Text  Key s74-pension-funding-note ]
  11 FilledButton «다음»(전체 폭 · onPressed = setState(() => _step = result))          Key s74-next
  12 TextButton «이전»(전체 폭 · onPressed = setState(() => _step = input))            Key s74-back
 스텝 ③ 본문(6 다음)
   7 Text(plan.orderDraftsTitle)                                                   Key s74-orders-title
   8 (plan.ordersEmptyText != null) Text(그 글자)                                  Key s74-orders-empty
     아니면 초안 행 — orderDrafts 받은 순서대로 Column(key: Key('s74-order-<순번>'))[ Text(d.symbolLabel) , Text(d.accountAlias) ,
        Wrap(spacing: 8)[ Text(d.sideLabel) , Text(d.quantityText) , (d.limitPriceText != null) Text  Key s74-order-<순번>-limit ] ,
        (d.pendingNoteText != null) Text  Key s74-order-<순번>-pending ,
        Wrap(spacing: 6, runSpacing: 4)[ 사유 칩마다 Chip(label: Text(chip.label), backgroundColor: 톤 색) ] ]
     🔴 고르는 것은 ordersEmptyText 하나다(orderDrafts.isEmpty 로 고르지 않는다).
     🔴 사유 칩 = Chip(탭 0 · onPressed·onSelected·onDeleted 없음) · ActionChip·InputChip·InkWell·GestureDetector 금지 · 톤 색 = 비공개 switch(전수 · ui_journal 을 import 하지 않는다):
        ChipTone.caution → colorScheme.errorContainer · ChipTone.blocked → colorScheme.error · ChipTone.neutral → colorScheme.surfaceContainerHighest · ChipTone.prevented → colorScheme.surfaceContainerHighest
   9 Card(key: Key('s74-costs'))[ Text(AnalyticsLabels.plannerCostsHeader) , Text(costs.totalText) , Text(costs.sourceLabel) , Text(costs.basisNote) ]   ← 초안이 없어도 그린다(엔진이 그때의 글자를 준다)
  10 조달 — fundingSteps 가 null 이거나 빈 목록이면 절째 부재 · 아니면 Column(key: Key('s74-funding'))[ Text(AnalyticsLabels.plannerFundingHeader) , 받은 순서대로 Text(step.label) Key s74-funding-<순번> ]
  11 등록 자리 — (plan.registerBlockedText != null) Text(그 글자)                  Key s74-register-blocked    ← 등록 버튼 부재
       아니면(_receipt == null 일 때만) [ (_notAccepted) Text(AnalyticsLabels.plannerRegisterNotAccepted, 색 = colorScheme.error)   Key s74-register-not-accepted ← 등록 버튼 바로 위(01 §12-3) ,
                                          FilledButton(onPressed: _submitting ? null : () => unawaited(_register(plan)), child: Text(AnalyticsLabels.plannerRegisterButton))   Key s74-register ]
  12 (_receipt != null) Text(_receipt.stateLabel)                                  Key s74-receipt
  13 (_receipt == null) OutlinedButton «다시 계산»(전체 폭 · onPressed = _submitting ? null : () => _calculate(_lastInput))   Key s74-recalculate
  14 (_receipt == null) TextButton «이전»(전체 폭 · onPressed = _submitting ? null : () => setState(() => _step = allocation))    Key s74-back
   🔴 접수증이 오면 잠금 = 11 의 등록 버튼·접수 실패 줄 · 13 · 14 부재(12 만 남는다 · 01 §14-7 · 03 ⓓ 🔧) · 스텝 ③ 에는 입력칸이 없다.
   🔴 «다시 계산»을 기다리는 동안 = 공통 머리 1~3(옛 plan) 그대로 + 스크롤 본문은 [ 4 스텝 제목 , 5 s74-asof , 6 warningLines(옛 plan) , AnalyticsSkeleton(key: Key('s74-result-loading'), blocks: 3) ] 뿐(7~14 없음).
      결과가 plan 이면 새 plan 으로 스텝 ③ · 아니면 스텝 ① 로(위 «계산»).
 Key 표(01 §14-19 — 전부 Key('…') · 순번은 0 부터 · 테스트는 이 글자로 찾는다):
   🔴 버튼 Key 는 버튼 위젯(FilledButton · OutlinedButton · TextButton) 자체에 단다 — «전체 폭»은 바깥 SizedBox(width: double.infinity) 로(Key 를 SizedBox 에 달면 T74-16 의 tester.widget<OutlinedButton>(…) 이 타입 오류) ·
      글자 Key(s74-register-not-accepted · s74-input-rejected …)는 Text 자체에(T74-18 이 style.color 를 읽는다) · 목록 Key 는 ListView 자체에.
   공통   s74-step-title · s74-preview-notice · s74-asof · s74-warning-<i> · s74-list-input · s74-list-allocation · s74-list-result
   스텝 ① s74-intro · s74-setting-header · s74-setting-loading · s74-setting-error · s74-setting-amount · s74-setting-equivalent · s74-setting-applies · s74-setting-limit-note · s74-setting-asof ·
          s74-amount-field · s74-input-rejected · s74-calculate · s74-result-loading · s74-result-error · s74-blocked-card · s74-blocked-action
   스텝 ② s74-deposit-amount · s74-allocation-<i> · s74-allocation-<i>-account · s74-allocation-<i>-reason · s74-residual · s74-pension-limit · s74-pension-suggestion · s74-pension-funding-note · s74-next · s74-back
   스텝 ③ s74-orders-title · s74-orders-empty · s74-order-<i> · s74-order-<i>-limit · s74-order-<i>-pending · s74-costs · s74-funding · s74-funding-<i> ·
          s74-register-blocked · s74-register-not-accepted · s74-register · s74-receipt · s74-recalculate · s74-back
   (s74-result-loading 은 스텝 ① 의 결과 자리와 스텝 ③ 의 «다시 계산» 기다림에 같은 Key 를 쓴다 · s74-back 은 스텝 ②③ 에 같은 Key)

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R11a (1) 정적 라벨») · 테스트는 그 단계 커밋에 함께
 (1) 정적 라벨 15개(labels.dart 끝 · 기존 화면·위젯·테스트 무변경 — 시작할 때의 flutter test 가 그대로 통과).
 (2) 자리·주입 — lib/planner.dart(export 2) · lib/src/planner/planner_providers.dart(4개) · 화면 뼈대(스텝 ① 머리까지) · test/planner_fakes.dart · T74-22.
 (3) 스텝 ① 전부(설정 자리 · 입력칸 첫 값 · 계산 · 입력 거부 · 차단 카드·버튼 · 계산 에러 · 기다림 · 늦은 결과) + T74-01~T74-03 · T74-05 · T74-06 · T74-21(스텝 ① 사슬) · T74-25.
     (스텝 ②③ 자리는 switch 전수를 위해 뼈대만 둔다 — 스텝 ② 화면을 요구하는 T74-04 · T74-20 · T74-23 은 (4) 로.)
 (4) 스텝 ②③ 과 등록 흐름 + T74-04 · T74-07~T74-18 · T74-20 · T74-21(스텝 ②③ 사슬) · T74-23 · T74-24 · T74-26.
 각 단계 커밋 전에 flutter test 가 통과해야 한다(그 단계까지 넣은 테스트 전부).
 (5) 골든 14장 — test/golden/s74_golden_test.dart.
 (6) format:fix · 질문 파일 · 정적 묶음(아래 «정적 묶음»).

■ 정적 라벨 — AnalyticsLabels 끝에(R10c 절 뒤) 절 주석(// ── 🆕 R11a — S7-4 ──)과 함께 15개(이름·글자 고정 · 글자에 숫자·금액 없음):
   plannerIntroLine = '입력한 금액으로 미리보기를 계산합니다' · plannerCurrentSettingHeader = '현재 설정' · plannerAmountFieldLabel = '이번에 넣을 금액(원)' ·
   plannerCalculateButton = '미리보기 계산' · plannerNextButton = '다음' · plannerBackButton = '이전' ·
   plannerStepAmountTitle = '금액' · plannerStepAllocationTitle = '배분·계좌' · plannerStepResultTitle = '결과' ·
   plannerPensionLimitTitle = '연금 납입 한도' · plannerCostsHeader = '예상 비용' · plannerFundingHeader = '연금 납입 조달 순서' ·
   plannerRecalculateButton = '다시 계산' · plannerRegisterButton = '이 계획으로 입금 등록' · plannerRegisterNotAccepted = '등록 요청이 접수되지 않았습니다. 계획은 그대로 있습니다.'
   (plannerWithdrawalLinkButton 은 없다 — v1.5. 기존 상수는 고치지 않는다. R11b 가 이 절 뒤에 자기 절을 더한다.)
   🔴 만들지 않는 글자(엔진 몫): «미리보기입니다…» · 금액·계좌·주문·비용·한도·조달·경고·만료·등록 불가·입력 거부·차단 문장 · «주문 초안»(orderDraftsTitle) · 접수 상태 글자 ·
      «현금 부족» · «한도 초과» · «0원» · «해당 없음» · 금액·월 납입 운영값.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · 파일 = test/deposit_planner_view_test.dart · T74-22 만 파일 읽기 test)
공통: 띄우기 도우미 = test/planner_fakes.dart 의 pumpPlanner 한 벌(아래) · 뷰포트 기본 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 ·
  호출마다 새 Future/Stream · 시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 보고된 에러는 tester.takeException() 으로 단언 ·
  픽스처는 golden_support.dart 의 singleFixture/listFixture/fixtureEnvelope 로만 읽는다 · 탭 뒤에는 pump() 두 번(또는 pumpAndSettle — Completer 로 멈춘 동안에도 된다).
  StreamController 는 만든 줄 바로 뒤 addTearDown(() { unawaited(controller.close()); })(🔴 addTearDown(controller.close) 로 쓰지 않는다 — 구독자 0 이면 close() 가 끝나지 않아
  teardown 이 타임아웃까지 매달린다 · R2b C4) · add·addError 직후는 await tester.pump(Duration.zero).
  test/planner_fakes.dart(🆕 · 이 카드 소유 · 이름·매개변수 고정 · 부르는 이름 = 아래 글자):
    FakeWhatIfApi({answerFn}) extends UnimplementedWhatIfApi
        simulateDeposit(amountInput:) = simulateCalls(List<String>)에 글자 그대로 더하고 → answerFn(amountInput)(Future<DepositPreviewResult> Function(String)) · 없으면 m7M7DepositPlanDefault 행을 Future.value
        simulateWithdrawal · previewRebalance · estimateCosts · findPlan = otherCalls(List<String>)에 메서드 이름을 더한 뒤 super 를 그대로 돌려준다(받침대의 Future 에러)
        (override 매개변수의 타입은 생략 — decimal 을 import 하지 않는다)
    FakeConfigRepository({settingStreamFactory}) extends UnimplementedConfigRepository
        watchContributionSetting() = watchContributionSettingCalls(int) +1 → settingStreamFactory()(Stream<ContributionSetting> Function()) · 없으면 m9ContributionSettingDefault 행의 Stream.value
    FakePlannerCommandApi({registerFn, watchFn}) extends UnimplementedCommandApi
        registerDeposit = registrations(List<DepositRegistration>)에 더하고 → registerFn(registration) · 없으면 m7M7DepositRegisterReceipts4 행 0 을 Future.value
        watchCommand = watchedIds(List<String>)에 더하고 → watchFn(commandId) · 없으면 registerDeposit 이 돌려준 그 접수증의 Stream.value(호출마다 새로)
    plannerOverrides({required whatIf, config, commandApi, safetyState, clock, opener}) → 오버라이드 6개(🔴 전부 overrideWithValue — overrideWith(함수) 금지)
        analyticsClockProvider · analyticsLinkOpenerProvider · safetyRepositoryProvider(FakeSafetyRepository — explore_fakes 에서 import) · plannerWhatIfApiProvider · plannerConfigRepositoryProvider · plannerCommandApiProvider
        기본값: config = FakeConfigRepository() · commandApi = FakePlannerCommandApi() · 안전 = safetyStates 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 오프너 = 새 RecordingLinkOpener
    pumpPlanner(tester, {required whatIf, config, commandApi, safetyState, clock, opener, Size viewSize = const Size(390, 2400)})
        ← 🔴 첫 줄 = await tester.pumpWidget(const SizedBox.shrink())(앞 장면을 걷어 낸다 — 같은 모양을 다시 pumpWidget 하면 Flutter 가 State 를 그대로 두어 _step · _seeded · _touched · 입력 글자가 남는다) →
           viewSize · DPR 1.0 · teardown 2 · ProviderScope(overrides: plannerOverrides(…)) → MaterialApp(home: Scaffold(body: DepositPlannerScreen())) · 끝에 pump() 두 번
    tapAndSettle(tester, String key) — tap(find.byKey(Key(key))) → pump() → pump() (계산 · 다음 · 이전 · 등록 · 다시 계산 공용)
    🔴 골든은 pumpPlanner 를 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: plannerOverrides(…), child: const DepositPlannerScreen()), brightness: b, logicalSize: …)
 T74-01 진입 — 기본 설정·기본 결과로 띄운다 → whatIf.simulateCalls 0 · whatIf.otherCalls 0 · config.watchContributionSettingCalls == 1 ·
        plannerStepAmountTitle · plannerIntroLine · plannerCurrentSettingHeader 글자 각 1 · amountText · equivalentNoteText · appliesFromText · setting.asOf.label 글자 각 1 ·
        lastChangedText 글자 0 · s74-preview-notice 0 · StaleBanner 0(find.byType) · ⓡ ·
        설정 두 벌(m9ContributionSettingDefault · m9ContributionSettingNoLimitNote)마다 pensionLimitNoteText 가 있으면 s74-setting-limit-note 1 + 그 글자 1, 없으면 s74-setting-limit-note 0(양쪽 다 단언).
 T74-02 입력칸 첫 값 — testWidgets 하나 · 세 장면(장면마다 pumpPlanner · StreamController 로 설정을 준다):
        ⓐ 첫 값 add → tester.widget<TextField>(s74-amount-field).controller!.text == amountInputText → enterText(s74-amount-field, '${amountInputText}0') →
           둘째 값(m9ContributionSettingNoLimitNote 행) add → 글자는 그대로 '${amountInputText}0' · s74-setting-limit-note 0(둘째 값이 그려졌다는 증거)
        ⓑ 첫 값 전에 enterText(같은 글자) → 첫 값 add → 글자는 그대로(첫 값이 덮지 않는다) · s74-setting-amount 1.
        ⓒ 편집 없이 첫 값 add → 글자 == amountInputText → 둘째 값 = m9ContributionSettingNoLimitNote 행.copyWith(amountInputText: '${amountInputText}0')(규칙 11 예외) add →
           글자는 그대로 amountInputText(둘째 값이 덮지 않는다) · s74-setting-limit-note 0(둘째 값이 그려졌다는 증거)
           (까닭: 설정 픽스처 두 벌의 amountInputText 가 같아 ⓐⓑ 만으로는 «첫 값 뒤 스트림이 입력 덮기» 변이가 살아남는다 — 드라이런 실측).
 T74-03 계산 인자 — enterText(' ${amountInputText} ')(앞뒤 빈칸) → 계산 → simulateCalls == <String>[그 글자 그대로](자르지 않았다) · ⓡ
 T74-04 기다림 — answerFn = Completer → 계산 → s74-result-loading 1(AnalyticsSkeleton · blocks == 3) · plannerStepAmountTitle 1 · s74-amount-field 1 · s74-calculate 1 · s74-preview-notice 0 · ⓡ →
        Completer 를 기본 결과로 완료 → plannerStepAllocationTitle 1 · s74-result-loading 0.
 T74-05 계산 에러 — answerFn = Future.error(StateError('x')) → s74-result-error 1 · 그 안의 retryButton 1 · tester.takeException() == null(보고하지 않는다) ·
        입력칸 글자 그대로 → 재시도 탭 → simulateCalls hasLength(2) · 두 글자가 같다.
 T74-06 입력 거부·차단 — ⓐ m7M7DepositPlanInputRejected → s74-input-rejected 글자 == inputRejectedText · plannerStepAmountTitle 1 · s74-blocked-card 0 · 입력칸 글자 그대로 ·
        dy: s74-amount-field < s74-input-rejected < s74-calculate(입력칸 바로 아래 · lessThan) · ⓡ
        ⓑ m7M7DepositPlanBlocked 두 행(ⓗ hasLength(2))마다 새로 띄워 → s74-blocked-card 1 · blockedText 글자 1 · s74-input-rejected 0 · dy s74-calculate < s74-blocked-card ·
           blockedAction 이 있으면(행 1) s74-blocked-action 1 · action.label 글자 1 · 탭 → opener.opened == <String>[row.blockedAction!.deepLink] ,
           없으면(행 0) s74-blocked-action 0 · opener.opened 비어 있음(양쪽 다 단언) · ⓡ
 T74-07 스텝 ② 배분 — m7M7DepositPlanDefault · m7M7DepositPlanFunding 마다(계산 한 번):
        s74-deposit-amount 글자 == depositAmountText · ⓗ allocations hasLength(<그 픽스처의 수>) 뒤 for i: s74-allocation-i 안에 label · amountText 글자 각 1 ·
        accountAlias 있으면 s74-allocation-i-account 1 + 글자, 없으면 0 · routingReasonText 있으면 s74-allocation-i-reason 1 + 글자, 없으면 0(양쪽 다) · s74-allocation-<길이> 0 ·
        residualKrwCashText 있으면(default) s74-residual 글자 1, 없으면(funding) s74-residual 0(양쪽 다) · ⓡ
 T74-08 한도 카드 — m7M7DepositPlanDefault · m7M7DepositPlanLimit · m7M7DepositPlanFunding + default 의 plan.copyWith(pensionLimit: null)(규칙 11 예외 — 결과를 preview.copyWith(plan: …) 로 준다):
        pensionLimit 이 있으면 s74-pension-limit 1 · plannerPensionLimitTitle 1 · annualLimitText · taxCreditText · deadlineText 글자 각 1 ·
          suggestionText 있으면 s74-pension-suggestion 1 + 글자, 없으면 0 · fundingNoteText 있으면 s74-pension-funding-note 1 + 글자, 없으면 0(양쪽 다) ,
        없으면 s74-pension-limit 0 · plannerPensionLimitTitle 0(양쪽 다) · ⓡ
 T74-09 고지 고정 — viewSize: Size(390, 600) · 기본 결과 · 스텝 ② 와 ③ 을 각각 새로 띄워서(pumpPlanner) 잰다:
        스텝 ③ 은 스텝 ② 에서 tester.ensureVisible(find.byKey(const Key('s74-next'), skipOffstage: false)) → pumpAndSettle → «다음» →
          전제 expect(tester.state<ScrollableState>(find.descendant(of: find.byKey(const Key('s74-list-result')), matching: find.byType(Scrollable))).position.pixels, 0.0)(맨 위부터 열린다 · 목록 Key) ·
        각 스텝에서: s74-preview-notice 글자 == previewNotice ·
        find.ancestor(of: s74-preview-notice, matching: find.byType(Scrollable)) findsNothing · find.ancestor(of: s74-asof, matching: find.byType(Scrollable)) findsOneWidget(양성 기준점) ·
        고지 dy 와 s74-asof dy(find.byKey(const Key('s74-asof'), skipOffstage: false) 로 잰다 — 끈 뒤 보이는 영역 밖일 수 있다)를 적어 두고
        tester.drag(find.byKey(const Key('s74-list-<그 스텝>')), const Offset(0, -40)) → pumpAndSettle → 고지 dy 는 같고 s74-asof dy 는 lessThan(끌기 전 값) · ⓡ
        (드라이런 실측: 스텝 ② 기본 결과의 최대 스크롤 175 — −400 이면 끝까지 밀려 s74-asof 가 화면 밖으로 나가 기본 finder 가 0개를 찾는다)
 T74-10 경고 줄 — m7M7DepositPlanLimit → 스텝 ② 와 ③ 에서 ⓗ warningLines hasLength(1) 뒤 s74-warning-0 글자 == warningLines[0] · s74-warning-1 0 ·
        m7M7DepositPlanDefault → s74-warning-0 0(양쪽 다) · ⓡ
 T74-11 스텝 ③ 초안·칩 — m7M7DepositPlanDefault · m7M7DepositPlanFunding 마다: s74-orders-title 글자 == orderDraftsTitle · s74-orders-empty 0 ·
        ⓗ orderDrafts hasLength(<수>) 뒤 for i: s74-order-i 안에 symbolLabel · accountAlias · sideLabel · quantityText 글자 각 1 ·
        limitPriceText 있으면 s74-order-i-limit 1 + 글자, 없으면 0 · pendingNoteText 있으면 s74-order-i-pending 1 + 글자, 없으면 0(양쪽 다) ·
        ⓗ reasons hasLength(<수>) 뒤 s74-order-i 안의 Chip 수(find.descendant … find.byType(Chip)) · 칩 label 글자 · s74-order-<길이> 0 ·
        find.byType(ActionChip) 0 · 첫 칩을 눌러도 opener.opened 비어 있음 · 🔴 ruleCited·code 글자 0 · ⓡ
        + 톤 4갈래(03 §9 ⓓ — 픽스처는 NEUTRAL 뿐): ChipTone.values 마다 첫 초안의 첫 칩만 copyWith(tone: t)(규칙 11 예외 ·
          preview.copyWith(plan: plan.copyWith(orderDrafts: [첫 초안.copyWith(reasons: [첫 칩.copyWith(tone: t), …나머지 칩]), …나머지 초안])) 사슬 허용) 한 결과로 새로 띄워 스텝 ③ →
          tester.widget<Chip>(s74-order-0 안의 Chip).backgroundColor == 위 «화면» 의 톤 표(colorScheme 은 Theme.of(tester.element(…)) 에서).
 T74-12 초안 없음 — m7M7DepositPlanLimit → 스텝 ③: s74-orders-empty 글자 == ordersEmptyText · s74-order-0 0 · s74-orders-title 1 · s74-costs 1(totalText 글자 1) · ⓡ
 T74-13 조달 — m7M7DepositPlanFunding → s74-funding 1 · plannerFundingHeader 1 · ⓗ fundingSteps hasLength(1) 뒤 s74-funding-0 글자 == label · s74-funding-1 0 · ruleCited 글자 0 ·
        m7M7DepositPlanDefault(null) → s74-funding 0 · plannerFundingHeader 0(양쪽 다) · ⓡ
 T74-14 만료 — m7M7DepositPlanExpired → 스텝 ③: s74-register 0 · s74-register-blocked 글자 == registerBlockedText · s74-recalculate 1 ·
        둘째 답을 Completer 로 → «다시 계산» → s74-result-loading 1 · s74-register-blocked 0 · s74-recalculate 0 · s74-preview-notice 1 →
        Completer 를 같은 픽스처로 완료 → plannerStepResultTitle 1 · simulateCalls hasLength(2) · [1] == [0](직전 글자) · ⓡ
 T74-15 등록 자리 — m7M7DepositPlanDefault · m7M7DepositPlanExpired · m7M7DepositPlanFunding 마다 스텝 ③: registerBlockedText 가 있으면 s74-register-blocked 글자 1 · s74-register 0,
        없으면 s74-register 1 · s74-register-blocked 0(양쪽 다) · funding 은 s74-funding 1 도 함께 · ⓡ
 T74-16 등록 1회 — m7M7DepositPlanDefault · registerFn = Completer → s74-register 탭 → 기다리는 동안 tester.widget<FilledButton>(s74-register).onPressed == null ·
        s74-recalculate·s74-back 의 onPressed == null · 한 번 더 탭 → registrations hasLength(1) → Completer 를 접수증 행 0 으로 완료 →
        registrations.single.planId == singleFixture(FixturePaths.m7M7DepositPlanDefault, DepositPreviewResult.fromJson).plan!.planId(따로 디코드) · ⓡ
 T74-17 접수 뒤 잠금 — watchFn = StreamController → 등록 → s74-receipt 글자 == 접수증 행 0 의 stateLabel · watchedIds == <String>[행 0 의 commandId] ·
        s74-register 0 · s74-recalculate 0 · s74-back 0 · 행 1 add → 행 1 의 stateLabel · 행 2(EXPIRED) add → 행 2 의 stateLabel · 여전히 s74-register 0 · s74-back 0 ·
        addError → tester.takeException() != null · 글자는 행 2 그대로 · ⓡ
 T74-18 접수 실패 — registerFn 첫 호출 = Future.error(StateError('x')) · 둘째 = Completer → 탭 → takeException() != null · s74-register-not-accepted 글자 == AnalyticsLabels.plannerRegisterNotAccepted ·
        그 Text 의 style.color == colorScheme.error · dy s74-register-not-accepted < s74-register · s74-register 의 onPressed != null(재활성) · s74-receipt 0 →
        다시 탭 → 기다리는 동안 s74-register-not-accepted 0(다음 제출 시작에 지운다) · registrations hasLength(2) · ⓡ
        ⓑ(같은 testWidgets · 새로 띄워) registerFn = Future.error(StateError('x')) → 탭 → takeException() != null · s74-register-not-accepted 1 →
           «다시 계산»(기본 결과) → s74-register-not-accepted 0 · s74-register 1(새 계산이 옛 실패 줄을 지운다 · 드라이런 Q3)
 (T74-19 는 없는 번호다 — «반대로 인출하면?» 은 v1.5 · R11c.)
 T74-20 늦은 결과 — testWidgets 하나 · 두 장면(answerFn 이 호출 순서대로 Completer A · B 를 돌려준다 · 둘째 글자 = '${amountInputText}0' 로 바꿔 둔다):
        ⓐ 계산(A) → 글자 바꿔 계산(B) → B 를 기본 결과로 완료 → plannerStepAllocationTitle 1 → A 를 입력 거부로 완료 → 여전히 plannerStepAllocationTitle 1 · s74-input-rejected 0
        ⓑ 계산(A) → 계산(B) → A 를 기본 결과로 완료 → plannerStepAmountTitle 1 · s74-result-loading 1(A 는 버렸다) → B 를 입력 거부로 완료 → s74-input-rejected 1 ·
        두 장면 다 simulateCalls hasLength(2) · ⓡ
 T74-21 배치 사슬 — 위쪽 변 dy(tester.getTopLeft(…).dy)의 lessThan 사슬 · 조건부 요소는 if/else 양쪽 · testWidgets 하나에 세 스텝:
        ① 기본 설정 · 안전 행 0: s74-step-title < s74-intro < s74-setting-header < s74-setting-amount < s74-setting-equivalent < s74-setting-applies < s74-setting-limit-note < s74-setting-asof < s74-amount-field < s74-calculate
        ② m7M7DepositPlanDefault · m7M7DepositPlanLimit · m7M7DepositPlanFunding 마다: s74-preview-notice < s74-step-title < s74-asof < (warningLines 가 있으면 s74-warning-0 · 없으면 그 Key 0) <
           s74-deposit-amount < s74-allocation-0 < (residual 있으면 s74-residual · 없으면 0) < (pensionLimit 있으면 s74-pension-limit · 없으면 0) < s74-next < s74-back
        ③ m7M7DepositPlanDefault · m7M7DepositPlanLimit · m7M7DepositPlanExpired · m7M7DepositPlanFunding 마다: s74-preview-notice < (오래됨이면 staleBannerTitle 글자 · 아니면 그 글자 0) < s74-asof <
           (s74-warning-0 | 0) < (s74-order-0 | s74-orders-empty — ordersEmptyText 로 고른다) < s74-costs < (s74-funding | 0) < (s74-register | s74-register-blocked) < s74-recalculate < s74-back
           (오래됨 = 전제 계산 plan.asOf.observedAt.add(plan.asOf.staleAfter).isBefore(kGoldenNowUtc) — 시계 비교는 테스트에서만 · 네 벌 중 오래됨이 정확히 1벌임을 expect 로 먼저 둔다)
        🔴 «<» 는 lessThan 그대로 · ⓡ
 T74-22 자리 — (test · 파일 읽기) lib/planner.dart 의 export 경로 집합 == {'src/planner/deposit_planner_screen.dart', 'src/planner/planner_providers.dart'}(정확히 2 · 🔵 R11c 가 +1 할 때 그 카드가 이 단언을 이름으로 고친다) ·
        lib/ui_analytics.dart · lib/src/screens/** · lib/src/widgets/** · lib/src/providers/** 의 글자에 'planner' 0.
 T74-23 안전 배너 — safetyStates 행 3 · 행 4 마다(ⓗ activeFlags hasLength(2) / hasLength(1)): 각 플래그 label 글자 1 · dy SafetyBlockBanner < s74-step-title ·
        tester.widget<TextField>(s74-amount-field).enabled != false · tester.widget<FilledButton>(s74-calculate).onPressed != null(판정은 엔진 · D21) ·
        배너 안 chevron(find.descendant(of: find.byType(SafetyBlockBanner), matching: find.byIcon(Icons.chevron_right)))을 i 번째마다 눌러 opener.opened.last == flags[i].clearDeepLink!(전제 isNotNull) ·
        행 0 → find.byType(SafetyBlockBanner) 0(양쪽 다) · 결과 단계에서도: 행 3 · 기본 결과 → 스텝 ② 에서 dy s74-preview-notice < SafetyBlockBanner < s74-step-title · ⓡ
 T74-24 오래됨 — m7M7DepositPlanDefault: 시계 kGoldenNowUtc → 스텝 ②·③ 에서 staleBannerTitle 0 / 시계 kGoldenNowUtc.add(const Duration(days: 3)) → 스텝 ②·③ 에서 1(양쪽 다) ·
        같은 +3일 시계의 스텝 ① → staleBannerTitle 0(스텝 ① 에는 StaleBanner 가 없다) · ⓡ
 T74-25 설정 스트림 상태 — ⓐ 값을 주지 않는 StreamController → s74-setting-loading 1(AnalyticsSkeleton) · s74-setting-amount 0 · s74-amount-field 1(글자 빈칸) · s74-calculate onPressed != null · ⓡ
        ⓑ settingStreamFactory 첫 호출 = Stream.error(StateError('x')) · 둘째 = 기본 설정 → s74-setting-error 1 · 그 안의 retryButton 1 · s74-amount-field 1 · s74-calculate 1 →
           재시도 탭 → watchContributionSettingCalls == 2 · s74-setting-amount 1 · 입력칸 글자 == amountInputText(아직 건드리지 않았으므로 첫 값이 채운다).
 T74-26 되돌아가기 — ⓐ «다시 계산» 의 결과(answerFn 둘째 답)가 입력 거부 · 차단 행 0 · Future 에러 인 세 벌마다 새로 띄워 → plannerStepAmountTitle 1 · s74-preview-notice 0 ·
           입력칸 글자 == 처음 글자 · 각각 s74-input-rejected 1 / s74-blocked-card 1 / s74-result-error 1(에러 벌은 재시도 → simulateCalls hasLength(3) · 셋 다 같은 글자)
        ⓑ 기본 결과 → 스텝 ③ → «이전» → plannerStepAllocationTitle 1 · s74-next 1 → «이전» → plannerStepAmountTitle 1 · 입력칸 글자 그대로 · s74-preview-notice 0 → 계산 → simulateCalls hasLength(2) · ⓡ
 ⓡ·ⓗ 줄 수(정적 묶음 S26·S27): 드라이런 실측 S26 = 29 · S27 = 20(ⓗ 전제 9 + 호출 수 단언 11) — 드라이런 실측 · 차이가 나면 PR 본문에 까닭(반려 사유는 «PR 본문의 수 ≠ grep -c 출력» 과 «표식마다 1줄 이상» 미달뿐).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 진입 때 simulateDeposit 호출 · 입력 글자 trim · 첫 값 뒤 스트림이 입력 덮기 · 건드린 뒤 첫 값이 덮기 ·
   늦은 결과 반영 · 계산 에러를 스텝 ② 로 · 입력 거부를 차단 카드로 · blockedAction 무시 · flagId 로 계산 버튼 끄기 · allocations 역순 · residual 상시 표시 · 한도 카드 제안 줄 상시 ·
   ordersEmptyText 무시하고 빈 표 · 조달 빈 절 그리기 · previewNotice 를 스크롤 안에 · StaleBanner 빼기 · 사유 칩을 ActionChip 으로 · 톤 색 바꾸기 · 등록 연타 2회 ·
   등록 대기 중 «다시 계산» 눌림 · 접수 뒤 «다시 계산»·«이전» 남기기 · 접수 실패 줄 누락 · 접수 실패 줄을 버튼 아래로 · «다시 계산» 결과가 거부인데 스텝 ③ 유지 · 스텝 ③ 배치 순서 바꾸기 · 스텝별 목록 Key 빼기(스텝 ③ 이 스크롤된 채 열림) · 새 계산 뒤 접수 실패 줄 남기기.

■ 정적 묶음 — packages/ui_analytics 에서 아래 29줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 29줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 2>&1 로 모으면 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힌다 · 드라이런 실측 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 사람이 적는 줄은 **정확히** «<파일>:<줄> — 탭 콜백 안» 만(정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ · 괄호·설명·위젯 이름 금지 · R10c 2회차 반려 사유).
     S05 출력 줄 수 = 2(드라이런 실측 · 배너 onOpenLink 1 + 차단 버튼 1 — 배너를 한 곳에서 만들 때 · dart format 이 ref / .read(…) / .open 으로 줄을 나누면 .read 줄이 찍힌다 — 그 줄도 «탭 콜백 안» ·
     차이가 나면 PR 본문에 까닭 · import 줄·주석 줄이 찍히면 규칙 17 위반).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/deposit_planner_view_test.dart test/planner_fakes.dart test/golden/s74_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/deposit_planner_view_test.dart test/golden/s74_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/deposit_planner_view_test.dart test/golden/s74_golden_test.dart; echo "EXIT:$?"
echo "## S03 input normalization 0"; git grep -nE "replaceAll|replaceFirst|\.trim\(|int\.parse|num\.parse|double\.parse|tryParse|inputFormatters" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S04 AppRoutes 0"; git grep -n "AppRoutes" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/planner; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 other WhatIfApi calls 0"; git grep -nE "estimateCosts|findPlan|previewRebalance|simulateWithdrawal" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S15 autoDispose 3"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 planner outside planner 0"; git grep -n "planner" -- lib/ui_analytics.dart lib/src/screens lib/src/widgets lib/src/providers lib/src/chart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S19 item1 package imports"; git grep -nE "^import 'package:" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 planner autoDispose 1"; git grep -n "autoDispose" -- lib/src/planner; echo "EXIT:$?"
echo "## S23 chip link state 0"; git grep -nE "ActionChip|detailDeepLink|rejectReasonCode|expiresAt|computedAt" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S24 rate literals 0"; git grep -nP '(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])' -- lib; echo "EXIT:$?"
echo "## S25 amount literals 0"; git grep -nP '(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}' -- lib; echo "EXIT:$?"
echo "## S26 retry-nothing lines"; git grep -c "retryButton), findsNothing" -- test/deposit_planner_view_test.dart; echo "EXIT:$?"
echo "## S27 hasLength lines (premise + call counts)"; git grep -c "hasLength(" -- test/deposit_planner_view_test.dart; echo "EXIT:$?"
echo "## S28 planner exports 2"; git grep -n "^export" -- lib/planner.dart; echo "EXIT:$?"
  (줄의 뜻 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) · S03 = 입력 글자를 고치지 않는다 · S04 = AppRoutes 0 ·
   S05 = build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0 ·
   S14 = 호출 표(01 §14-8) · S15 = 기존 3줄 그대로(대소문자 구분 · 플래너 프로바이더는 lib/src/planner 라 여기 안 잡힌다 · 이 카드는 이 파일을 고치지 않는다) ·
   S16 = 배럴 쪽에서 planner 0(C-35 ⑥ · G13) · S17·S18 = R10 차트 파일 무변경 · S19~S21 = 12항의 1·3·11항 근거(② 괄호가 이 출력을 가리킨다) ·
   S22 = plannerContributionSettingProvider 한 줄(🔴 주석에 autoDispose 라는 말을 쓰지 않는다 — 주석도 센다) · S23 = 칩 탭 0 · 거부 코드·시계 비교 0 ·
   S24·S25 = C-38 ⑫ 와 같은 뜻(labels.dart·주석 포함 · 만 = \x{B9CC} · 원 = \x{C6D0} · 억 = \x{C5B5}) · S26 = ⓡ 줄 수 · S27 = hasLength( 가 든 줄 전부(ⓗ 전제 + 호출 수 단언)(둘 다 숫자 한 줄 «파일:N» · PR 본문의 수와 글자로 대조) ·
   S28 = export 2줄)
  (기대 출력 — 드라이런 실측 · 차이가 나면 PR 본문에 까닭: S01 = 출력 없음(주석 줄이 걸리면 그 줄만) · S05 = 2줄 · S13 = 4줄 · S15 = 3줄 · S17·S18 = «changed» 요약 줄 없음 ·
   S19 = 43줄(전부 domain_contracts·flutter·flutter_riverpod · 그중 플래너 파일 5줄) · S22 = 1줄(lib/src/planner/planner_providers.dart:<줄>) ·
   S26 = test/deposit_planner_view_test.dart:29 · S27 = test/deposit_planner_view_test.dart:20 · S28 = 2줄 · 나머지 = 출력 없음)

■ 골든 — 7이름 × light/dark = 14장(전부 신규 · 03 §9 ⓗ 표 · golden README «🆕 R11» 절)
  이름 · 입력 · 가는 길 · 안전 행 · 맨 아래 위젯(위치 전제 Key) · 크기(390 × 높이 — 드라이런 실측 · 테스트 파일 안 상수 · 차이가 나면 PR 본문에 까닭):
    s74_step1_default      설정 m9ContributionSettingDefault · 결과 없음(띄우기만)                 행 0 · s74-calculate · 390×844
    s74_step2_normal       결과 m7M7DepositPlanDefault · «미리보기 계산»                           행 0 · s74-back · 390×844
    s74_step3_normal       결과 m7M7DepositPlanDefault · «미리보기 계산» → «다음»                  행 0 · s74-back · 390×1100
    s74_pension_limit_hit  결과 m7M7DepositPlanLimit · «미리보기 계산»(스텝 ② · 한도 카드 + 제안 + 조달 안내)   행 0 · s74-back · 390×844
    s74_expired            결과 m7M7DepositPlanExpired · 계산 → «다음»(스텝 ③ · registerBlockedText · StaleBanner 가 보인다)   행 0 · s74-back · 390×1100
    s74_funding            결과 m7M7DepositPlanFunding · 계산 → «다음»(스텝 ③ · 조달 절 · 등록 불가)   행 3(RECON_MISMATCH·JOURNAL_MISSING 배너) · s74-back · 390×1300
    s74_blocked            결과 m7M7DepositPlanBlocked 행 0 · «미리보기 계산»(스텝 ① · 배너 + 차단 카드 · 버튼 없음)   행 4(LEDGER_INTEGRITY 배너) · s74-blocked-card · 390×844
  드라이런 실측 dy(light=dark · 참고값 — Bob 은 자기 PNG 에서 이름·밝기마다 잰다): step1_default 379 · step2_normal 759 · step3_normal 964 · pension_limit_hit 814 · expired 992 · funding 1175 · blocked 532
  (배분 행을 Wrap 으로 바꾼 뒤라 step2_normal · pension_limit_hit 는 더 작아질 수 있다).
  설정은 전부 m9ContributionSettingDefault · 시계 = FixedClock(kGoldenNowUtc) · 가짜 answerFn 은 인자와 무관하게 그 골든의 픽스처를 돌려준다.
  (blocked 행 1(재개 리포트 버튼)은 안전 상태에 짝이 없어 골든이 아니라 T74-06 이 덮는다 · pensionLimit null 갈래는 T74-08 이 덮는다.)
  찍는 모양: pumpForGolden(tester, ProviderScope(overrides: plannerOverrides(…), child: const DepositPlannerScreen()), brightness: b, logicalSize: Size(390, <그 이름의 높이 상수>)) →
    탭(tapAndSettle) → 🔴 찍기 전 await tester.pumpAndSettle()(버튼 물결이 남지 않게) → 위치 전제 expect(tester.getBottomLeft(find.byKey(const Key('<맨 아래 Key>'))).dy, lessThan(<높이>)) → expectGolden('<이름>', b).
  높이는 테스트 파일 안 상수 · 🔴 kGoldenPhoneSize 를 고치지 않는다 · 입력칸에 포커스를 주지 않는다(커서 깜빡임).
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s74_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 14장만 ??
  🔴 기존 골든 테스트 5파일(s71·s71b·s72·s72g·s73)을 --update-goldens 에 넣지 않는다.
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s74_golden_test.dart 의 위치 전제 lessThan(<높이>) 를 **전부** 잠시 lessThan(0) 으로 바꾸고(도우미 하나에 모았으면 그 한 곳 · 테스트마다 썼으면 7곳 모두 — 드라이런은 도우미 한 곳)
    → flutter test test/golden/s74_golden_test.dart(--update-goldens 없이)
    → 테스트 이름마다 실패 문구의 «Actual: <숫자>» 를 적는다(14개가 모두 실패해야 한다 — 덜 나오면 안 바꾼 곳이 남았다 · 헷갈리면 --plain-name 으로 한 이름씩)
    → 전부 되돌린다(git diff -- test/golden/s74_golden_test.dart 가 빈 것을 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).
  골든 테스트 이름 = '<골든 이름> ${brightnessSuffix(b)}'(예 's74_step1_default light') · 파일은 '../planner_fakes.dart' 와 'golden_support.dart' 를 import.
  파일 모양 = for (final Brightness b in Brightness.values) { 이름마다 testWidgets 1 — 7개 }(루프 하나 · s72g 처럼 · 재분할 임계는 이 모양의 testWidgets( 줄 수로 센다 = 7).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다)
· S7-4_questions.md — 머리말의 «다음 번호»에서 이어 붙인다.
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 권고와 다르게 지은 이름 · 15개 밖에 새로 더한 정적 라벨 · 골든 위치 전제의 실제 dy(종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리에 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 ·
  C4 가 재실측해 ✅ 로 닫는다 · 형식 예: | A1 | R11a-Bob-S74 | 추측 | 측정: s74_step1_default dy 실측값 (light=<값>, dark=<값> < <높이>) | 골든 위치 전제 실측 | <높이> 미만 확인 | ⬜ 미답 | |) ·
  픽스처 합이 안 맞아 보이는 곳(고치지 않고 그대로 그린 뒤) · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 15개와 글자 · 읽지 않는 필드 목록(규칙 5) · 배치 순서 · 계산 에러를 보고하지 않는 것 ·
  접수 실패 줄의 자리 · 설정 로딩·에러 자리 · 골든 이름·높이 · 톤 색 표 · 재량인 것(여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드·Key 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  melos.bat run format:fix
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · test:contracts 가 C-38 ⑩⑪⑫ · C-35 ⑥ · C-4 · C-12 를 이 브랜치 파일에 건다)
  git status --short
     ← test/golden/goldens/ 에서: 기존 PNG 42장(s71_*·s73_*·s73b_*·s71b_*·s72g_*·s72_*)의 M = 금지(git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로) · 새 PNG 는 s74_* 14장뿐 ·
        lib 에서 M 은 lib/l10n/labels.dart 하나뿐(끝에 더한 줄만) · lib/ui_analytics.dart · src/providers/** · src/screens/** · src/widgets/** · src/chart/** 의 M = 금지 ·
        test/ 에서 기존 파일(explore_fakes.dart · 기존 테스트 · test/golden/ 하네스·reference/**·README·기존 골든 테스트)의 M = 금지
  git add packages/ui_analytics docs/ai-context/inbox
  git commit -m "[M7] R11a (6) format·질문 파일"   ← 늘 한다(질문 파일의 «측정:» 7행 + format 수정을 함께 — 이 커밋이 없으면 제출이 아니다)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push -u origin ui/m7-s74-planner
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력
  cd packages/ui_analytics → 위 «정적 묶음» 29줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M7] S7-4 투자금 플래너 위저드(폰 전용)
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(S7-4 — DepositPlannerScreen · package:ui_analytics/planner.dart) 한 줄 +
      바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(손으로 쓰지 않음 · A/M · PNG 포함)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · N 만 채운다):
        1번 = «정적 묶음 S19 — domain_contracts·flutter·flutter_riverpod 밖 0줄»
        2번 = «워터폴 잔여 = residualKrwCashText 그대로(T74-07) · 금액 원값 미참조(C-38 ⑩ · 정적 묶음 S24·S25 0건)»
        3번 = «정적 묶음 S20 — 0건»
        4·5·7·8·12번 = «이 카드 범위 밖»
        6번 = «plan 은 simulateDeposit 결과만(T74-03) / previewNotice 스텝 ②③ 스크롤 밖 고정(T74-09) / 주문 실행 버튼 0 — registerDeposit 1회(T74-16)»
        9번 = «스텝 ②③ s74-asof + StaleBanner(asOf: plan.asOf)(T74-21·T74-24) · 스텝 ① setting.asOf.label(s74-setting-asof)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 git status 의 기존 PNG M 0 · domain_contracts 변경 0»(10번은 «앞절 … / 뒷절 …» 로 괄호 하나)
        11번 = «정적 묶음 S21 결과 N건»
      ┌── 복사 시작(다음 줄부터)
 1. `ui_analytics`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 산술이 없는가 — 행동 갭·워터폴 잔여·밴드 이탈·페널티 금액을 내가 계산하지 않았는가 [x] ( )
 3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (리밸런싱 트리거 배지·«미달» 경고문 포함) [x] ( )
 4. S7-2에 인터스티셜·격리 위치·열람 기록 3종이 모두 있는가 [x] ( )
 5. M8 홈·알림에 넘기는 요약과 D-7/D-1 알림 본문에 손익·금액이 없는가 [x] ( )
 6. 플래너가 M3 결과만 그리는가 / «미리보기입니다» 고지가 상시인가 / 주문 실행 버튼이 없는가 [x] ( )
 7. 결측 구간을 보간하지 않고 공백으로 두는가 / «산출 불가»에 근사 배지를 붙이지 않았는가 [x] ( )
 8. 표본 크기 고지·벤치마크 구성 문구가 뷰모델 문자열 그대로인가 [x] ( )
 9. as-of 기준일이 모든 성과 화면 상단에 상시 표기되고, 유예 초과 시 «오래된 데이터» 배너가 뜨는가 [x] ( )
10. S7-8의 게이트·개입 UI를 자체 구현하지 않았는가 / 픽스처·골든 스냅샷을 손대지 않았는가 [x] ( )
11. `ui_analytics` 소스에 세후·기대수익률·낙폭 수치가 리터럴로 없는가 —
    정규식 `\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b` 로 `lib/` 만 검사(pubspec·버전 문자열·
    `fixtures/`·테스트는 대상 제외 — 픽스처는 M2 소유) [x] ( )
12. 세후 카드에 계좌 배치 갈래가 정확히 하나만 펼쳐져 있는가 / 층을 화면에서 합치거나 빼지 않았는가 /
    목표 경로 가정 카드가 «백테스트 기준 실행»과 «현재 원금·납입» 두 줄로 갈라져 있는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M7.md 155~169행과 같습니다)
      이어서 «정적 묶음» 출력 전부를 코드 블록 하나로 그대로 + S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄
      (괄호·설명 금지 · 줄을 빼거나 줄이면 = 보고 불일치 = 반려) + «ⓡ = S26 출력 · ⓗ = S27 출력» 한 줄(숫자는 출력 그대로).
   ③ 스크린샷 서술 — 로딩·정상·빈(초안 없음)·차단 최소 4줄 + 골든 표 14행(이름 · 입력 픽스처 · 크기 · 위치 전제 dy · 배치·잘림)
      🔴 서술은 코드의 위젯·Key 이름을 위 → 아래 순서 그대로 «→» 로 잇는다(예 SafetyBlockBanner → s74-step-title → … → s74-calculate) ·
         조건으로 붙는 것(SafetyBlockBanner · StaleBanner · s74-warning-<i> · s74-residual · s74-pension-limit · s74-order-<i>-limit · s74-funding · s74-register-blocked …)은 «(있을 때)» 를 붙인다 ·
         그 순서가 위 «화면» 배치와 다르면 제출하지 말고 멈춘 뒤 채팅으로.
         «로딩» = s74-setting-loading · s74-result-loading 이 있는 자리를 코드 그대로 · «차단» = SafetyBlockBanner 의 자리(스텝 ① = Column 첫째 · Expanded(ListView) 바깥 위 /
         스텝 ②③ = s74-preview-notice · StaleBanner 다음 · Expanded(ListView) 바깥 위) + s74-blocked-card · «빈» = s74-orders-empty 의 자리.
      입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m7/m7_deposit_plan_default.json · m9/contribution_setting_default.json · safety_states.json 행 3 — 상수 이름과 섞지 않는다) ·
      dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값 · 배치·잘림 = PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 못 본 것은 «미열람»).
   ④ 질문 표(새 행 번호·요지 — 질문 파일에 쓴 글자와 같게) ⑤ 추측한 것 = 질문 파일의 새 A 행 중 «측정:» 이 아닌 행의 번호 전부(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
   (+ flutter test 실제 통과 수 한 줄)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s74-planner` 푸시 1건 · 커밋 6개(본문 (1)~(5) + (6) format·질문 파일 — 질문 파일의 «측정:» 7행 때문에 (6) 은 늘 있다).
- `lib/` 새 파일 — `planner.dart`(export 2) · `src/planner/planner_providers.dart`(4개) · `src/planner/deposit_planner_screen.dart`(+ 재량으로 나눈 `src/planner/` 아래 비공개 파일) · 수정 1(`l10n/labels.dart` — 끝에 🆕 R11a 절 15개). 배럴 `ui_analytics.dart` · `providers/analytics_providers.dart` · `screens/**` · `widgets/**` · `chart/**` 는 바뀌지 않는 것이 정상.
- `test/` 새 파일 3(`planner_fakes.dart` · `deposit_planner_view_test.dart` · `golden/s74_golden_test.dart`) + 새 PNG 14장. `explore_fakes.dart`·기존 테스트·하네스·`reference/**`·golden README·기존 PNG 42장은 불변.
- 질문 파일 1개(`S7-4_questions.md` — «측정:» 행 7개(이름마다 1행 · light·dark 두 값 = dy 14개) + 있으면 질문·추측 행) · 채팅: PR 본문 5섹션(① name-status 출력 그대로 · ② 복사 상자 12항 + «정적 묶음» 29줄 출력 전부 + S05 줄 «<파일>:<줄> — 탭 콜백 안» · ③ 위젯·Key 이름 나열 + 골든 표 14행 — dy 는 이름·밝기마다).
- `flutter test` = 병합본 기존 196 + 새 39(뷰 25 + 골든 14) = 235(드라이런 실측 · 최소 목록의 번호가 기준 · 차이가 나면 PR 본문에 까닭) · 정적 S26 = 29 · S27 = 20(드라이런 실측 · 반려 사유는 PR 본문의 수 ≠ grep -c 출력).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R11a-Bob-S74 결과: 브랜치 ui/m7-s74-planner 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R11a-Bob-S74 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R11a-Bob-S74 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG 42장(`s71_*`·`s73_*`·`s73b_*`·`s71b_*`·`s72g_*`·`s72_*`)이 `M`, 또는 `lib/` 에서 `labels.dart` 밖의 기존 파일(배럴 `ui_analytics.dart` · `analytics_providers.dart` · 화면·위젯·차트)이 `M` ② `pubspec.yaml` 변경(`decimal` = C-3) ③ `test/golden/` 하네스·`reference/**`·README·`explore_fakes.dart`·기존 테스트가 `M` ④ 플래너 파일의 `AppRoutes`·`aaq://`·`Navigator`·`DateTime.now`·`ActionChip`·`CommandState`·`expiresAt` ⑤ 입력 글자를 고치는 코드(`trim`·`replaceAll`·`tryParse`·`inputFormatters`)나 금액 원값(`.amount`·`.total`)을 읽는 코드 ⑥ ② 의 S05 줄에 괄호·설명이 붙음 ⑦ 플래너 파일 주석의 작은따옴표 인용·규칙 17 낱말(정적 S20·S03~S14·S23 이 주석도 센다) — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **추가만** 하므로 초록이 정상입니다(빨간색이면 기존 PNG 를 건드린 것).
- 계약 테스트 C-38 ⑩⑪(플래너 파일의 «읽지 않는 필드»·금지 창구)과 C-35 ⑥(배럴 쪽의 planner 도달)은 플래너 파일이 없을 때 공허 통과였다 — 이 브랜치에서 처음 실제 파일을 본다. 병합 검사 때 Claude 가 그 위에서 돌린다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 🔴 **파일 이름 주의** — `send/` 바로 아래의 R11 패킷은 이것 하나입니다(`R11b-Bob-S79.md` 는 이 카드의 병합 기록 커밋에서 `send/` 에 올라간다 — 그 전에는 없다). `_완료/` 의 R10a·R10b(+재제출)·R10c(+재제출)·R2b-Bob-J3 와 M7 옛 카드(`R1b-Gem-S71.md`·`R2-Gem-S73.md`)를 붙여넣지 않습니다.
- 드라이런 실측(2026-09-30 · `C:/Work/AAQ-claude-review` `a8d8c7f`): 새 테스트 39(testWidgets 줄 32 = 뷰 25 + 골든 7) · 총 235 · 골든 높이 844/844/1100/844/1100/1300/844 · dy 379~1175 · S05 2 · S22 1 · S26 29 · S27 20 · S19 43 · lib +751 · 예고 변이 24종 중 23 KILLED(생존 1 → T74-02 ⓒ) · bash/PowerShell 5.1 출력 같음(EXIT 표기·warning 줄 제외 · PowerShell 에서 S17·S18 은 EXIT:False 로 찍힐 수 있다). 재분할 임계(새 testWidgets 줄 > 33 · lib > +900 · 새 PNG > 16) 모두 안 — 나누지 않는다(설계 Δ7). 반영 뒤 재드라이런 없음(바뀐 곳은 머리 «드라이런» 줄).
- 범위 고지: 스텝 ④ 비교(01 §8 미결 66) · 시나리오 저장(67) · M5 핸드오프(68) · 워터폴 막대·배분비·슬리피지(69) · 비용 내역(70) · advisory 표본(71) · 계좌 매핑 목적지(72) · 뷰어 미리보기(73) · 사유 칩 핸드북 연결(81) · «반대로 인출하면?»(v1.5 · R11c)은 이 카드에 없습니다. `m7_deposit_plan_limit` 은 1,800만 합산 납입한도 **형태 표본**입니다(실전 조건 한도 구속 0/25년 · 01 §14-6).
- 🔵 설계서 §3 4-4 의 `plannerRegisterNotAccepted` 후보 글자(«… 다시 시도해 주세요.»)는 01 §12-3 문구 5원칙 ②(«관측한 로컬 사실만»)에 맞춰 «… 계획은 그대로 있습니다.» 로 확정했다(카드 권한 · 01 §12-3 «이름·문구 = 카드가 정한다»). 접수 실패 줄의 자리도 01 §12-3(«제출 버튼 바로 위»)이 03 §9 ⓓ 의 나열 순서보다 앞선다.
- 그 밖의 알릴 것은 `_완료/R10c-Bob-S72.md` «5» 를 참고합니다.
