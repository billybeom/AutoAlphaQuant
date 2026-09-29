# 발송 패킷 R10b-Bob-S72G — 재제출 (1회차 반려 · 2026-09-29)

> 만든 날 2026-09-29 · 1회차(PR #16 · 브랜치 `ui/m7-s72g-gate` · 커밋 `8a3c413`)의 C4 병합 검사 결과가 **반려(재제출)**여서 만든 패킷입니다(발주자 승인 2026-09-29 · 테스트 보강 F7~F12 도 함께 넣음). 규칙·범위(S7-2G 열람 게이트 + 수익률 탐색 화면 합성 · 탐색 본문은 껍데기)는 1회차 카드(`send/_완료/R10b-Bob-S72G.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 F1~F12 + 질문 파일 행 처리**만 담았습니다.
> 같은 브랜치 `ui/m7-s72g-gate` · 같은 PR #16 에 커밋을 더하면 됩니다(새 PR 을 만들지 않습니다). 기대 = **lib 0 · PNG 0** — 코드와 그림은 고칠 것이 없습니다. 반려 사유는 보고 글 5묶음(①~⑤) + 테스트 1건(⑥ G14 조건부 단언)입니다.
> 판정 근거 = C4 보고 §0(카드 🔴 «보고와 코드·파일·PNG 가 다르면 1건이라도 재량 없이 반려»를 처음 적용한 카드 · R10a 는 이 문장이 카드에 없어 통합 수정으로 병합했다) · 고칠 것 = C4 보고 §6 F1~F12(F2 만 실측값을 뺐다 — Bob 이 재고 C4 가 대조) · 질문 행 = C4 보고 §7.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `R10b-Bob-S72G.md` 의 `send/_완료/` 이동과 **같은 푸시**로 `main` 에 올린다(Bob 은 «먼저 할 것»의 병합 한 번으로 둘 다 받는다). 0단계의 `ls-tree` 확인 줄이 그 증명이다. `R10c-Bob-S72.md` 머리의 ⏸ 는 그대로 둔다(이 재제출이 병합된 뒤 ▶).
> 🔴 **같은 푸시에 함께 넣을 것(Claude)** — `send/README.md` 의 ▶ 줄과 R10b 행을 이 재제출(같은 브랜치 · 같은 PR #16 · 원 패킷 `_완료/`)로 고친다(기록 스크립트). R2b 병합 기록(`R2b-Bob-J3.md` → `_완료/`)은 **R2b 세션 몫이라 이 푸시에 넣지 않는다**(발주자 메모 2026-09-29) — 그래서 `send/` 에 `R2b-Bob-J3.md` 가 남아 보일 수 있고, §2-5·§5 는 그것을 «끝난 카드 · 보내지 않음» 예외로 적었다(0단계 판정에는 영향 없음 — 다른 줄은 무시).

## 0. 한 줄 목적

PR #16 의 보고(자체 점검 12항 · 골든 dy · 파일 목록 · 추측 · 정적 줄)를 코드·파일·PNG 와 같게 고치고, 테스트·가짜가 카드 규칙(조건부 단언 금지 · 호출마다 새 Stream)과 빠진 상태를 실제로 증명하게 하기 — lib 와 PNG 는 한 줄도 바꾸지 않는다.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s72g-gate` · 같은 PR #16.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다. 🔴 1회차를 보낸 대화를 이어 쓰지 않습니다(Bob 은 1회차를 기억하지 못한다는 전제로 본문을 썼습니다).
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R10b-Bob-S72G-재제출.md`** 에서 엽니다(Bob 폴더는 PR 브랜치라 병합 전에는 이 파일이 없습니다 · 그 폴더가 아직 최신 `main` 을 받지 않았으면 GitHub 의 `main` 에서 · 보낼지는 GitHub `main` 에 있는지로 판단).
4. 붙여넣을 것은 아래 «3» 의 본문 **전부**(첫 줄 «R10b-Bob-S72G 재제출 요청» ~ «■ 제출» 끝) · 고치지 않습니다. 새 대화라 규칙 요약과 자체 점검 12항 원문이 본문에 들어 있습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 지금 보낼 패킷은 **이것 하나**입니다(`R2b-Bob-J3.md` 가 보여도 그것은 끝난 카드 — 병합 PR #13 · 보내지 않음). 원 패킷 `R10b-Bob-S72G.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). `R10c-Bob-S72.md` 는 머리가 ⏸ — 이 재제출이 병합된 뒤의 카드입니다. 이름이 비슷한 `_완료/R2-Bob-J2J3-재제출.md`·`_완료/R1b-Bob-J1-재제출.md` 등 «-재제출» 카드는 끝난 카드입니다(09-22 비슷한 이름의 옛 카드로 Bob 이 8시간 멈춘 사고).

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R10b-Bob-S72G 재제출 요청 — 1회차(PR #16 · 8a3c413) 판정: 반려(재제출). 같은 브랜치·같은 PR 에 커밋을 더하십시오(새 PR 금지).
이번 반려는 코드가 아니라 보고 때문입니다(+ 테스트 1건). lib/ 와 PNG 는 한 줄도 바꾸지 않습니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R10a(ui/m7-s71b-archive · 병합됨)도 R10c(아직 보내지 않음)도 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
ui/m6-* · ui/m7-s71b-archive 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #16 · 브랜치 ui/m7-s72g-gate(커밋 8a3c413)에 아래 F1~F12 커밋을 «더하는» 일입니다.
F1~F12 는 아직 브랜치에 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← ui/m7-s72g-gate
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  (다른 브랜치였다면 status 가 빈 것을 본 뒤) git checkout ui/m7-s72g-gate
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git log --oneline -1          ← 8a3c413 [M7] R10b (4) format·질문 파일 · 다르면 멈추고 출력을 채팅으로
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R10b-Bob-S72G-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R10b-Bob-S72G.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 · R10c-Bob-S72.md 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R10b-Bob-S72G-» 로 시작하는 줄이 있으면 정상.
        «R10b-Bob-S72G-재제출» 줄이 없거나 꼬리 없는 «R10b-Bob-S72G.md» 가 보이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다.
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (1회차 카드 docs/ai-context/send/_완료/R10b-Bob-S72G.md 의 규칙 1~14 · 보고 규칙 · 주입 구조 · 테스트 최소 목록 · 정적 · 골든 · 질문 파일 절이 그대로 유효 — 여기엔 핵심만)
· 이번에 고치는 곳 = packages/ui_analytics/test 의 세 파일(performance_explore_gate_test.dart · explore_fakes.dart · golden/s72g_golden_test.dart)
  + docs/ai-context/inbox/S7-2G_questions.md 만.
· 🔴 고치면 반려: packages/ui_analytics/lib/** 전부(이 PR 이 만든 새 lib 파일 3개 · labels · analytics_providers · 배럴 포함) ·
  test/golden/goldens/*.png 전부(이 PR 의 s72g_* 8장 포함 · 기존 22장 s71_·s73_·s73b_·s71b_) ·
  domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml · test/flutter_test_config.dart ·
  test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·reference/**·s71_golden_test·s73_golden_test·s71b_golden_test·README ·
  기존 테스트 5파일(contribution_view·drawdown_context_view·monthly_report_view·report_archive_view + 자리표시 ui_analytics_test).
· 새 테스트가 lib 를 고쳐야만 통과하면 lib 를 고치지 말고 멈추고 채팅으로(C4 가 8a3c413 위에서 같은 뜻의 시험 테스트 10개를 돌려 모두 통과함을 확인했습니다).
· 테스트(규칙 10): testing.dart 받침대 extends(implements 금지) · 받은 인자 전부 기록 · 호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) ·
  동작은 UI 를 실제로 눌러서 · 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 ·
  정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 · DTO·CommandReceipt 를 지어 넣지 않는다(픽스처 행에서) ·
  테스트 이름 = 번호 + ASCII(«—»·«→» 도 금지) · 테스트에 한국어 리터럴 금지 · «<» 를 «<=» 로 · «N개» 를 greaterThanOrEqualTo 로 바꾸지 않는다 ·
  StreamController 는 만든 줄 바로 뒤 addTearDown(() { unawaited(controller.close()); }) · add·addError 직후는 await tester.pump(Duration.zero) ·
  픽스처는 golden_support.dart 의 singleFixture/listFixture/fixtureEnvelope 로만 · 보고된 에러는 tester.takeException() 으로 단언.
· 골든: --update-goldens 금지(이번엔 다시 찍을 PNG 가 없다) · golden:approved 라벨 안 붙임.
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
  package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)).
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10a 교훈) — 🔴 이 카드부터 «보고와 코드·파일·PNG 가 다르면 1건이라도 재량 없이 반려»입니다.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모).
   자체 점검 ② 는 prompt_M7.md 154~168행 12항을 글자 그대로 복사한 뒤 [x] 와 괄호 근거만 붙입니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 · 항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다 —
   R10a 는 12항을 전부 자기 말로 바꿔 1·2·3·11항의 원문 검사가 빠졌습니다).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(PR 본문 ① 한 줄 · 골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.
   → 이번 재제출은 이 규칙을 1회차가 어긴 곳을 고치는 일입니다. 같은 결함이 한 번 더 나오면 다시 반려입니다.

■ 잘된 것 — 그대로 유지하십시오
lib 가 카드 문장 그대로입니다(주입 구조 — analyticsCommandApiProvider · disclosureGateProvider · typedef PerfSeriesQuery · performanceSeriesProvider · 정적 라벨 3 ·
배럴 export 자리(monthly_report 다음 · report_archive 앞) · 게이트 배치·상태 표 · 명령 호출 틀(_continue) · 탐색 본문 껍데기 — 위반 0).
기계 검사 전부 초록 — dart format 0 changed · analyze 13/13 · ui_analytics flutter test 138 통과·0 실패 · 골든 8장 일치 · domain_contracts 230 통과·30 skip·0 실패 ·
경계·라벨 검사 · CI 3/3.
새 PNG 8장은 픽스처·배치와 맞고(넘침·잘림·겹침 0 · 두 버튼 같은 폭) 기존 22장 M 0 · 카드가 예고한 변이는 넣어 보니 전부 테스트가 잡았습니다.
정적 줄의 실측도 전부 통과했습니다(오프너 2줄은 탭 콜백 안 · providers autoDispose 3 · 새 lib 의 import·산술·한국어 리터럴·정규식 0 — 원문 1·2·3·11항을 코드는 통과합니다. 보고만 틀렸습니다).

■ 왜 반려인가 — 보고 글 / 실제 (①~⑤ 는 C4 검사 갈래 둘 이상이 따로 확인 · ⑥ 은 카드 반려 조건)
① PR ② 자체 점검
   보고 글: 머리 «(prompt_M7.md 154~168행 원문)» · 1항 «pubspec.yaml 의존이 추가되지 않았다.» 등 12항
   실제:    원문과 같은 글자 0/12. 원문 1항은 «`ui_analytics`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가» 입니다.
            12항 전부 지은 문장입니다(R10a 와 같은 결함) · 괄호 틀도 엉뚱한 문장에 붙었습니다(«탐색 본문 R10c» 괄호가 원문 7·8 «결측 보간»·«표본 고지» 가 아닌 곳에).
② PR ③ 골든 표 · 질문 파일 A1
   보고 글: 골든 표 8행이 모두 같은 한 값(< 844) · A1 «s72g_* 4종 × light/dark 공통 — … (뷰포트 390×2400 …)»
   실제:    위치 전제 dy 는 골든 이름마다 다릅니다(390×844). 한 이름을 390×2400(G 테스트 뷰포트)에서 잰 값을 8행과 A1 에 복사했습니다.
            C4 가 테스트 탐침 4번 + PNG 픽셀 1번, 따로 다섯 번 재서 모두 같은 네 값을 얻었습니다(값은 적지 않습니다 — 직접 재서 적고 C4 가 대조합니다).
③ PR ① 파일 목록
   보고 글: «새 파일 5개» · «수정 파일: test/golden/s72g_golden_test.dart» · «프로바이더 4개 추가»
   실제:    새 파일 = 코드·테스트 6 + PNG 8 = 14 · s72g_golden_test.dart 는 A(새 파일) · PNG 8장이 목록에 없음 · 프로바이더 3 + typedef 1.
④ PR ⑤ 추측한 것
   보고 글: «추측한 것: 없음»
   실제:    질문 파일에 종류 «추측» 행 A2·A3 이 있습니다(A1 은 «측정:» 이라 예외). 게다가 A2(DisclosureGateView 생성자 모양 = 카드 «재량인 것») ·
            A3(series 에러 lastAsOfLabel = null = 카드 규칙 7 «늘 null»)은 카드가 «적지 않을 것»으로 정한 행입니다.
⑤ PR ② 정적 줄
   보고 글: «정적 grep 결과»
   실제:    카드 «정적» 목록의 'aaq:// 0 줄과 «테스트 이름 ASCII» 결과 줄이 없습니다(실측은 둘 다 통과 — 빠진 것이 문제 · 카드 «빠진 항목 = 보고 불일치 = 반려»).
⑥ G14 · G11 (테스트 — 카드 반려 조건)
   코드:    G14 가 루프 안 if (!FlagIds.markerOnly.contains(flag.flagId)) { expect… } 로 단언을 거르고 else 가 없습니다 · G11 은 차단 2건 중 firstWhere 로 1건만 «0» 을 봅니다.
   카드:    규칙 10 «전제는 expect(조용한 return·if 건너뛰기 금지)» · «if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려».
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 보고를 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다
(카드 «재량인 것» 은 다른 뜻 — Bob 이 스스로 정해도 되는 설계 부분입니다).
R10a 와 판정이 다른 까닭: R10a 카드에는 «보고가 다르면 1건이라도 반려» 문장이 없어 통합 담당이 고쳐 병합했습니다. 이 카드에는 🔴 로 있었고,
② 복사는 R10a 를 이름까지 들어 금지했습니다 — 그래서 재량 없이 반려합니다. 코드·테스트가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  git fetch origin && git merge --no-edit origin/main
     ← 이 패킷과 원 패킷의 _완료/ 이동을 받습니다. 병합 커밋이 하나 생기는 것은 정상입니다(&& 가 안 되는 셸이면 두 줄로).
        충돌이 나면 아무것도 고치지 말고 멈춘 뒤 git status 출력을 채팅으로.
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.3 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: 138 통과 · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·골든 찍기는 하지 않습니다):
   · docs/ai-context/send/_완료/R10b-Bob-S72G.md — «■ 규칙 요약» 10 · «■ 테스트 최소 목록» · «(정적 …)» 목록 · «■ 골든» · «■ 질문 파일» · «■ 제출» ②
   · docs/ai-context/prompt_M7.md 154~168행(자체 점검 12항 원문 — 아래 «■ 제출» ② 상자와 같은 글자)

■ 고칠 것 — F1~F12 (1회차 반려 · C4 2026-09-29) — 같은 브랜치 ui/m7-s72g-gate 에 커밋을 더해 푸시합니다(rebase·강제 푸시 금지). lib/ 와 PNG 는 한 줄도 바꾸지 않습니다.
   🔴 이번 반려는 코드가 아니라 보고 때문입니다. 규칙은 그대로 «보고와 코드·파일·PNG 가 다르면 1건이라도 재량 없이 반려» 입니다.
   (F1~F6 = 반려 사유 · F7~F12 = 테스트 보강 — 발주자 결정으로 이번에 함께 넣습니다.)

F1 (PR ② 자체 점검) 아래 상자의 12항(15줄 — 11·12항은 여러 줄)을 한 글자도 바꾸지 않고 붙인 뒤, 각 항목 끝에 « [x] (근거)» 만 붙입니다.
   지난 제출은 12항 전부를 자기 말로 바꿨습니다(예 «1. pubspec.yaml 의존이 추가되지 않았다.» — 원문 1항은 import 검사).
   🔴 상자 밖의 말로 된 항목이 하나라도 있으면 반려입니다.
   항목을 더하거나 빼거나 합치지 않습니다(11·12항의 줄을 한 줄로 합치지도 않습니다) · 범위 밖도 [x] + 괄호.
   ┌ (prompt_M7.md 154~168행 원문)
    1. `ui_analytics`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가
    2. 화면 코드에 산술이 없는가 — 행동 갭·워터폴 잔여·밴드 이탈·페널티 금액을 내가 계산하지 않았는가
    3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (리밸런싱 트리거 배지·«미달» 경고문 포함)
    4. S7-2에 인터스티셜·격리 위치·열람 기록 3종이 모두 있는가
    5. M8 홈·알림에 넘기는 요약과 D-7/D-1 알림 본문에 손익·금액이 없는가
    6. 플래너가 M3 결과만 그리는가 / «미리보기입니다» 고지가 상시인가 / 주문 실행 버튼이 없는가
    7. 결측 구간을 보간하지 않고 공백으로 두는가 / «산출 불가»에 근사 배지를 붙이지 않았는가
    8. 표본 크기 고지·벤치마크 구성 문구가 뷰모델 문자열 그대로인가
    9. as-of 기준일이 모든 성과 화면 상단에 상시 표기되고, 유예 초과 시 «오래된 데이터» 배너가 뜨는가
   10. S7-8의 게이트·개입 UI를 자체 구현하지 않았는가 / 픽스처·골든 스냅샷을 손대지 않았는가
   11. `ui_analytics` 소스에 세후·기대수익률·낙폭 수치가 리터럴로 없는가 —
       정규식 `\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b` 로 `lib/` 만 검사(pubspec·버전 문자열·
       `fixtures/`·테스트는 대상 제외 — 픽스처는 M2 소유)
   12. 세후 카드에 계좌 배치 갈래가 정확히 하나만 펼쳐져 있는가 / 층을 화면에서 합치거나 빼지 않았는가 /
       목표 경로 가정 카드가 «백테스트 기준 실행»과 «현재 원금·납입» 두 줄로 갈라져 있는가
   └
   붙일 괄호: 1 = git grep -nE "^import 'package:" -- lib 결과에서 domain_contracts·flutter·flutter_riverpod 밖 0줄(dart:async·상대 경로는 적어 둠) ·
     2 = 새 lib 파일에 + - * / 산술 0 · 3 = git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart" 결과 0줄 ·
     4 = «인터스티셜·열람 기록 = 이 PR · 격리 위치(라우트·진입점) = 셸 몫» · 5·6·12 = «이 카드 범위 밖» · 7·8 = «이 카드 범위 밖 — 탐색 본문 R10c» ·
     9 = «as-of 는 게이트 카드 안 1줄 · 오래됨 배너 = StaleBanner · 탐색 본문의 as-of = R10c» ·
     10 = «앞절 이 카드 범위 밖 / 뒷절 git status 의 기존 PNG M 0 · domain_contracts 변경 0» · 11 = «위 정규식 -- lib 결과 N건».
   (위 상자는 보기 좋게 들여 쓴 것입니다 — PR ② 에 붙일 때는 «■ 제출» ② 의 복사용 상자(원문 파일과 같은 들여쓰기)를 씁니다.)

F2 (PR ③ 골든 표 · 질문 파일 A1) 위치 전제의 dy 는 골든 이름마다 다릅니다(390×844 — C4 가 이름마다 재 두었고, 재제출 때 대조합니다).
   지난 제출은 한 이름의 값을 390×2400(G 테스트 크기)에서 재고 8행과 A1 에 복사했습니다. 이번엔 8장을 이름마다 직접 재서 적습니다:
     test/golden/s72g_golden_test.dart 의 위치 전제 네 곳
       expect(tester.getBottomLeft(find.byKey(const Key('s72g-back'))).dy, lessThan(kGoldenPhoneSize.height));
     의 lessThan(kGoldenPhoneSize.height) 를 잠시 lessThan(0) 으로 바꾸고 → packages/ui_analytics 에서 flutter test test/golden/s72g_golden_test.dart
       (--update-goldens 없이 · 한 이름만 보려면 --plain-name "s72g_first light" 처럼 — 테스트 이름 = '<골든 이름> light' / '<골든 이름> dark')
     → 테스트 이름마다 실패 문구의 «Actual: <숫자>» 를 적는다(8개 · 출력에서 Actual 줄은 그 테스트 이름의 [E] 줄보다 위에 나옵니다 — 헷갈리면 --plain-name 으로 한 이름씩)
     → 네 곳을 되돌린다(git diff -- test/golden/s72g_golden_test.dart 로 되돌린 것을 확인).
   🔴 이 lessThan(0) 임시 수정은 커밋하지 않습니다.
     (위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않습니다. F10 으로 이 파일을 고친 뒤에 재도 됩니다 — 네 곳 모두 되돌린 뒤 커밋.)
   ③ 표의 «위치 전제» 칸 8행을 이름·밝기마다 그 값으로 고칩니다. 질문 파일 A1 행은 상태 «⬜ 미답» · 답 칸 비움 그대로 두고 «질문·추측» 칸만 아래 완성 문장으로 바꿉니다
     (<값> 자리에만 잰 숫자를 넣고, 다른 글자는 그대로):
       light 와 dark 가 같으면 →
         측정: s72g-back 아래 끝 dy(390×844 · light=dark) — first <값> · frequent <값> · closed <값> · not_accepted <값> (모두 < 844)
       하나라도 다르면 →
         측정: s72g-back 아래 끝 dy(390×844) — first light <값> / dark <값> · frequent light <값> / dark <값> · closed light <값> / dark <값> · not_accepted light <값> / dark <값> (모두 < 844)
   ④ 표의 A1 요지도 같은 글로 맞춥니다.

F3 (PR ①) 파일 목록은 손으로 쓰지 않고 git diff --name-status origin/main...HEAD 출력을 그대로 붙입니다(A = 새 · M = 수정 · PNG 포함).
   analytics_providers.dart 설명은 «프로바이더 3개 + typedef 1개».

F4 (질문 파일 A2·A3 · PR ④⑤) A2(DisclosureGateView 를 ConsumerWidget 으로)와 A3(series 에러 lastAsOfLabel = null) 두 행을 지웁니다.
   A2 = 카드 «재량인 것(내부 위젯 DisclosureGateView 등의 생성자 모양)» · A3 = 카드 규칙 7 «늘 null» — 둘 다 카드가 이미 정해 «적지 않을 것» 입니다.
   🔴 행을 쓰기 전에 그 내용을 카드에서 찾습니다(찾는 말 = 위젯·필드 이름). «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않습니다.
   ④ 표에는 A1 한 행만 · ⑤ «추측한 것» = 질문 파일의 새 A 행 중 «측정:» 이 아닌 행의 번호 전부(이번엔 «없음») — 질문 파일과 ⑤ 가 다르면 반려.

F5 (PR ② «정적» 줄) 카드 «정적» 목록의 항목마다 명령 1줄 + 결과 1줄. 지난 제출에서 빠진 두 줄을 더합니다:
     git grep -n "'aaq://" -- lib → EXIT:1(0건)
     테스트 이름 ASCII — git grep -nP "testWidgets\('[^']*[^\x00-\x7F]" -- test/performance_explore_gate_test.dart test/golden/s72g_golden_test.dart → EXIT:1(0건)
     테스트 이름 ASCII(줄로 내려간 이름) — git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/performance_explore_gate_test.dart test/golden/s72g_golden_test.dart → EXIT:1(0건)
       (format:fix 는 긴 이름(G5b·G10b·G11c)을 testWidgets( 다음 줄로 내립니다 — 윗줄은 그 이름을 보지 못하므로 두 줄 다 적습니다 · 두 줄은 packages/ui_analytics 에서)
   Navigator·DateTime.now·kIsWeb·Platform. 처럼 한 명령에 묶은 줄은 그대로 두어도 됩니다(항목 이름이 줄에 다 보이면 됨).

F6 (G14 · G11 — 카드 반려 조건 «if 건너뛰기 금지 · else 쪽 없으면 반려») 목록을 도는 단언은 대상 목록을 먼저 만들고, 그 수를 전제로 expect 한 뒤, for 로 전부 단언합니다.
   루프 안 if 로 거르지 않고, firstWhere 로 하나만 고르지 않습니다.
   아래 두 줄(blocking 목록 + 전제 expect)은 G11 · G11c(F9) · G14 각 testWidgets 안 첫머리에 둡니다(main() 맨 위에 두면 expect 가 테스트 밖에 놓입니다).
     final List<BlockFlag> blocking = safetyRow3.activeFlags.where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId)).toList();
     expect(blocking, hasLength(2));   // 전제 — 행 3 = RECON_MISMATCH · JOURNAL_MISSING
     G14: for (final BlockFlag flag in blocking) { 글자 1 · 그 dy < s72g-card dy }
     G11: 로딩·에러 두 단계 모두 for (final BlockFlag flag in blocking) { expect(find.text(flag.label), findsNothing); }
   G14 에 한 줄 더: expect(tester.getTopLeft(find.text(AnalyticsLabels.staleBannerTitle)).dy, lessThan(tester.getTopLeft(find.text(blocking.first.label)).dy));  // Stale 가 Safety 위

F7 (test/explore_fakes.dart — 카드 규칙 10 «호출마다 새 Future/Stream» · 카드 «watchCommand 기본 답 = 돌려준 그 접수증») 이름·기존 매개변수는 그대로 두고 F7 몫은 두 곳만 고칩니다
   (같은 파일에 F10 이 공개 함수 하나를 더하고 pumpExplore 안쪽 목록을 그 함수로 바꿉니다 — pumpExplore 의 이름·매개변수는 그대로).
   ① FakePerformanceRepository 에 선택 매개변수 Stream<DisclosureGateVm> Function()? gateStreamFactory 를 더합니다.
      watchDisclosureGate() = 호출 수 +1 → gateStreamFactory 가 있으면 gateStreamFactory() · 없으면 지금처럼 gateStream(없으면 StateError).
      G10 은 가짜 하나(gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen))로 두 번 띄웁니다(카드 «같은 가짜로 다시 띄운다») · 끝에 watchDisclosureGateCalls 2.
      골든의 .asBroadcastStream() 은 gateStreamFactory 로 바꿔도 되고 그대로 두어도 됩니다(PNG 는 바뀌지 않아야 합니다 — 바뀌면 멈추고 채팅으로).
   ② FakeCommandApi.recordDisclosureView 가 recordFn 을 쓸 때도 돌려준 접수증을 기억합니다:
        if (_recordFn != null) { return _recordFn(event).then((CommandReceipt r) { _lastReceipt = r; return r; }); }
      G6 넷은 watchFn 없이 recordFn 만 줍니다(기본 답이 그 행을 내는지를 G6 이 증명한다).

F8 (G3) series 호출 «수» 말고 네 인자도 봅니다 — G3 끝에:
     expect(repo.seriesCalls, <({PerfMetric metric, PerfGranularity granularity, bool cumulative, DateRange? range})>[
       (metric: PerfMetric.twr, granularity: PerfGranularity.monthly, cumulative: true, range: null),
     ]);

F9 (G11 더하기 · 새 G11c) 「그래도 보기」가 없는 상태는 닫힘뿐 아니라 로딩·에러도 「돌아가기」 하나가 줄 전체 폭입니다.
   G11 로딩 단계: expect(tester.widget<AnalyticsSkeleton>(find.byType(AnalyticsSkeleton)).blocks, 2);
                  expect(tester.getSize(find.byKey(const Key('s72g-back'))).width, tester.getSize(find.byType(AnalyticsSkeleton)).width);
   G11 에러 단계: expect(tester.getSize(find.byKey(const Key('s72g-back'))).width, tester.getSize(find.byType(AnalyticsErrorView)).width);
     (AnalyticsErrorView = package:ui_analytics/src/widgets/analytics_error_view.dart import)
   G11c 'G11c error after a value: no banners, last asOf label, retry resubscribes' —
     final StreamController<DisclosureGateVm> c = StreamController<DisclosureGateVm>.broadcast(); addTearDown(() { unawaited(c.close()); });
     가짜 = FakePerformanceRepository(gateStreamFactory: () => c.stream) · 안전 행 3 · 시계 +3일 ·
     c.add(gateOpen) → pump(Duration.zero) → pump() → staleBannerTitle 1(기준점) →
     c.addError(Exception('gate-error')) → pump(Duration.zero) → pump() →
     retryButton 1 · 글자 gateOpen.asOf.label 1 · staleBannerTitle 0 · blocking 각 label 0 · watchDisclosureGateCalls 1 →
     retryButton 탭 → pump() → watchDisclosureGateCalls 2.

F10 (새 G10b — 카드 🔴 «통과 사실은 이 State 에만 · 전역 프로바이더 금지» 를 한 컨테이너에서 증명)
     'G10b same ProviderContainer: leaving and coming back shows the gate again' —
     게이트 테스트 파일에 import 'package:flutter_riverpod/flutter_riverpod.dart'; 한 줄을 더합니다(ProviderContainer · UncontrolledProviderScope — 지금은 없음).
     뷰포트는 pumpExplore 와 같게: tester.view.physicalSize = const Size(390, 2400); tester.view.devicePixelRatio = 1.0; + addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
     ProviderContainer(overrides: pumpExplore 와 같은 5개 · 게이트 가짜 = gateStreamFactory) + addTearDown(container.dispose) ·
     Widget app(bool show) => UncontrolledProviderScope(container: container, child: MaterialApp(home: Scaffold(body: show ? const PerformanceExploreScreen() : const SizedBox())));
     pumpWidget(app(true)) → pump() → 「그래도 보기」 탭 → pump() → pump() → s72-record-line 1 → pumpWidget(app(false)) → pumpWidget(app(true)) → pump() → s72g-card 1 · s72-record-line 0.
       (첫 pumpWidget 바로 뒤의 pump() 를 빼면 게이트가 아직 로딩이라 s72g-continue 를 찾지 못해 실패합니다 — pumpExplore 가 끝에 pump() 를 하는 까닭과 같음)
     (띄우기 도우미를 한 벌로 두기 위해, 오버라이드 5개 목록은 explore_fakes.dart 의 공개 함수 하나로 만들어 pumpExplore · G10b · 골든이 함께 씁니다 —
      이름 예 exploreOverrides({required repo, required commandApi, safetyState, clock, opener}) · 골든 4묶음의 목록 반복도 이것으로 바꿉니다 ·
      골든 파일에서 쓰이지 않게 된 import 'package:domain_contracts/testing.dart'; 와 safety 변수는 지웁니다 — 남기면 analyze --fatal-infos 가 unused_import 로 실패합니다.)

F11 (새 G5b — 카드 «직전 1줄은 제출 시작 때 사라짐») 'G5b not-accepted line clears as soon as the next submit starts' —
     명령 가짜: 1회차 Future.error · 2회차 Completer.future(끝내지 않음) →
     탭 → pump() → pump() → takeException 비null · s72g-record-not-accepted 1 → 다시 탭 → pump() 한 번 → s72g-record-not-accepted 0 · s72g-card 1 ·
     끝에 pumpWidget(const SizedBox()) → completer.complete(receipts[0]) → pump() → expect(tester.takeException(), isNull) (G4 끝과 같은 순서).

F12 (G5 — 첫 탭이 실패한 뒤 · expect(repo.seriesCalls, isEmpty); 다음, 두 번째 탭 앞에 · 접수 실패 화면의 글자·자리 — 지금은 골든만 봅니다)
     🔴 G5 의 맨 끝(두 번째 탭이 성공한 뒤)은 이미 탐색 본문이라 아래 9줄이 실패합니다 — 자리는 반드시 첫 실패 뒤입니다.
     expect(find.text(gateOpen.asOf.label), findsOneWidget);
     expect(find.text(gateOpen.route!), findsNothing);
     expect(find.text(AnalyticsLabels.recordNotAccepted), findsOneWidget);
     final Finder line = find.byKey(const Key('s72g-record-not-accepted'));
     expect(find.descendant(of: find.byType(SnackBar), matching: line), findsNothing);
     expect(tester.getBottomLeft(find.byKey(const Key('s72g-card'))).dy, lessThan(tester.getTopLeft(line).dy));
     expect(tester.getTopLeft(line).dy, lessThan(tester.getTopLeft(find.byKey(const Key('s72g-back'))).dy));
     expect(tester.getTopLeft(find.byKey(const Key('s72g-back'))).dx, lessThan(tester.getTopLeft(find.byKey(const Key('s72g-continue'))).dx));
     expect(tester.getSize(find.byKey(const Key('s72g-back'))), tester.getSize(find.byKey(const Key('s72g-continue'))));
   그리고 정상 상태 testWidgets(G2·G3·G6·G8·G9·G10·G12·G14)마다 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 한 줄(카드 규칙 10).

■ 질문의 답 — 브랜치의 docs/ai-context/inbox/S7-2G_questions.md
   (머리말은 고치지 않습니다 · 칸 안에 세로 막대 문자를 넣지 않습니다 — 표가 깨집니다)
  A1  «질문·추측» 칸만 F2 대로 바꿉니다 · 상태 «⬜ 미답» · 답 칸 비움 그대로(번호·카드ID·종류 «추측»·막힌 곳·제안 칸은 그대로).
      답은 병합 때 통합 담당이 C4 재실측과 대조해 적고 ✅ 로 닫습니다(golden README 에 실측 줄을 더하는 것도 통합 담당 몫).
      🔴 test/golden/README 를 고치면 반려입니다.
  A2  행 전체를 지웁니다(F4) — 카드가 정한 것(«재량인 것 — 내부 위젯 DisclosureGateView 등의 생성자 모양»).
  A3  행 전체를 지웁니다(F4) — 카드가 정한 것(규칙 7 «탐색 시리즈 에러는 첫 요청이라 앞 값이 없으니 늘 null» · 껍데기 build 줄 lastAsOfLabel: null).
      (A2·A3 이 남아 있으면 F4 불이행 = 다시 반려 사유입니다.)
  새 행 — 이번 F1~F12 는 전부 이 패킷이 정했으므로 새 행이 없는 것이 정상입니다. 문서에 없어 꼭 정해야 한 것이 생기면 그때만 더하고,
      번호는 A4 부터(지운 A2·A3 번호는 다시 쓰지 않습니다 — 1회차 보고와 C4 보고가 그 번호로 가리킵니다) · 상태 «⬜ 미답» · 답 칸 비움.

■ 제출
  melos.bat run format:fix
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과 · 수 = 138 + 새 testWidgets 3(G5b · G10b · G11c) = 141(더 나누었으면 그 수 — 채팅에 실제 수를 적습니다)
     🔴 --update-goldens 는 쓰지 않습니다 — s72g 골든은 다시 찍지 않습니다(lib 0 이면 그림이 그대로입니다).
        골든 비교가 실패하면(F7·F10 으로 골든 테스트를 고친 뒤) PNG 를 다시 찍지 말고, 고친 테스트를 되돌려 원인을 찾고 — 그래도 안 되면 멈추고 채팅으로.
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git status --short
     ← 🔴 *.png 의 M = 금지(s72g_* 8장 포함 — git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로).
        🔴 packages/ui_analytics/lib/ 의 M = 금지(git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로).
        M 이 정상인 곳 = test/performance_explore_gate_test.dart · test/explore_fakes.dart · test/golden/s72g_golden_test.dart · docs/ai-context/inbox/S7-2G_questions.md 뿐
  git add packages/ui_analytics docs/ai-context/inbox
  git commit -m "[M7] R10b 재제출 — F1~F12"   ← F 단위로 나눠 커밋해도 됩니다
  git diff --stat 8a3c413 HEAD -- packages/ui_analytics/lib packages/ui_analytics/test/golden/goldens
     ← 🔴 출력 없음이어야 합니다(lib 0 · PNG 0). 한 줄이라도 나오면 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #16 자동 반영 · 새 PR·라벨·강제 푸시·rebase 금지)
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력
  채팅으로 — PR 본문 5섹션을 처음부터 새로(지난 본문을 고쳐 쓰지 않습니다). PR 본문 수정은 통합 담당이 합니다:
   ① 화면 ID(S7-2G) + 탐색 화면 합성(PerformanceExploreScreen · 탐색 본문은 껍데기 — 본문 전부는 R10c) 한 줄 +
      바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(F3 — 손으로 쓰지 않음 · A/M · PNG 포함) · analytics_providers.dart = «프로바이더 3개 + typedef 1개»
   ② 자체 점검 12항 — 아래 복사용 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 F1 «붙일 괄호» 대로 채웁니다.
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않습니다(두 번 틀린 곳입니다 — R10a · R10b 1회차). 이어서 «정적» 줄(F5 — 카드 «정적» 목록 항목마다 명령 1줄 + 결과 1줄).
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
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M7.md 154~168행과 같습니다)
   ③ 스크린샷 서술(열림·닫힘·접수 실패 — PNG 에 실제로 있는 것만 · PNG 가 없는 로딩·차단은 «PNG 없음 — G11·G14 가 봄» 한 줄씩)
      + 골든 표 8행(이름·입력 픽스처·크기·위치 전제 dy · PNG 를 열어 배치·잘림만 · 못 본 것은 «미열람»).
      🔴 dy 는 이름·밝기마다 F2 로 직접 잰 값 — 한 값을 여러 행에 복사하지 않습니다.
   ④ 질문 표 — A1 한 행(F2 로 바꾼 요지) + 새 행이 있으면 번호·요지
   ⑤ 추측한 것 — 질문 파일의 새 A 행 중 «측정:» 이 아닌 행의 번호 전부(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
   (+ flutter test 실제 통과 수 한 줄)
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s72g-gate` 에 추가 커밋: `main` 병합 커밋 1 + 수정 커밋(F1~F12 — 하나 또는 여럿).
- `test/` 수정 3 — `performance_explore_gate_test.dart`(F6 G14·G11 · F8 G3 · F9 G11·새 G11c · F10 새 G10b + `flutter_riverpod` import · F11 새 G5b · F12 G5 첫 실패 뒤·정상 상태 retry 0) · `explore_fakes.dart`(F7 `gateStreamFactory`·recordFn 접수증 기억 · F10 `exploreOverrides` 같은 공개 함수) · `golden/s72g_golden_test.dart`(F10 오버라이드 목록 + 쓰이지 않게 된 `domain_contracts/testing.dart` import·`safety` 변수 삭제 · F7 선택 — PNG 는 그대로).
- ② 정적 줄에 테스트 이름 ASCII 2줄(같은 줄 · 줄로 내려간 이름 — F5) · 둘 다 EXIT:1.
- `docs/ai-context/inbox/S7-2G_questions.md` — A1 «질문·추측» 칸(F2 · 이름마다 잰 dy) · A2·A3 삭제(F4) · 머리말 불변 · 새 행 없음이 정상.
- `lib/` 0 · PNG 0 — `git diff 8a3c413..<새 head> -- packages/ui_analytics/lib '*.png'` 가 비어 있어야 함.
- `ui_analytics` flutter test 141(더 나누었으면 그 수) · 채팅: PR 본문 5섹션(① `git diff --name-status` 그대로 · ② 원문 12항 + [x] + 괄호 + 정적 줄 · ③ 골든 표 dy 이름마다 · ④ A1 · ⑤ «없음»).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R10b-Bob-S72G 재제출: PR #16 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. 0단계·«먼저 할 것»에서 멈췄다면 `R10b-Bob-S72G 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR #16 «Files changed» — 8a3c413 뒤 커밋만 보면 된다): ① `packages/ui_analytics/lib/` 에 새 변경 ② `*.png` 가 바뀜(`s72g_*` 포함) ③ `pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README 변경 ④ 질문 파일에 A2·A3 이 남음 ⑤ ② 자체 점검 1항이 «`ui_analytics`가 `domain_contracts`…import하지 않는가» 가 아님(원문과 글자가 다름) ⑥ ③ 골든 표 8행 dy 가 모두 같은 값 ⑦ G14 루프 안 `if` · G11 `firstWhere` 가 남음 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 PNG 변경이 없으므로 **초록이 정상**입니다(빨간색 = PNG 를 건드린 것 = 반려 신호). `golden:approved` 는 필요 없고 붙이지 않습니다.
- PR 에 `Merge remote-tracking branch 'origin/main'` 커밋이 보이는 것은 정상입니다(squash 병합이라 결과에 남지 않음 · 변경 경로는 여전히 `packages/ui_analytics/**` + `docs/ai-context/inbox/` 만이어야 함).
- C4 가 재제출에서 다시 볼 것: ② 12항(15줄) 글자 diff(원문과 차이 0) · ③ 8행 dy 재실측 대조 · ① = `git diff --name-status` · 질문 파일 A1 한 행 · 정적 줄 목록 · 변이 51개 재실행(예상 생존만 남는지) · lib·PNG diff 0.
- Card margin 4px(카드 테두리보다 전폭 「돌아가기」가 양옆 4px 넓음)는 재량이라 이번엔 건드리지 않습니다 — 고치면 PNG 8장을 다시 찍어야 합니다(반려 사유 아님 · R10c 뒤 시각 다듬기 후보).
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 지금 보낼 것 = 이 파일 하나(`R2b-Bob-J3.md` 가 보여도 끝난 카드 — 병합 PR #13 · 보내지 않음). 원 패킷 `R10b-Bob-S72G.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 합니다). `R10c-Bob-S72.md` 는 이 재제출 병합 뒤 · C4 가 이월 항목(`explore_fakes.dart` 실제 이름 등)을 병합본 실물로 맞춘 뒤 ▶ 로 바뀝니다.
