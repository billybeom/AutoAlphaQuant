# 발송 패킷 R11b-Bob-S79 — 재제출 (1회차 반려 · 2026-10-01)

> 만든 날 2026-10-01 · 1회차(PR #21 · 브랜치 `ui/m7-s79-goal-path` · 커밋 `a816264`)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다(발주자 결정 2026-10-01 = «(A) 반려 → 재제출» · C4b-12(배너 «스크롤 밖» 단언)는 다음 카드로 · R12 의 `S7-8` 은 나중에). 규칙·범위(S7-9 목표 경로 + 부록)는 1회차 카드(`send/_완료/R11b-Bob-S79.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 F1~F6** 만 담았습니다.
> 같은 브랜치 `ui/m7-s79-goal-path` · 같은 PR #21 에 **새 커밋 1개를 맨 위에** 더하면 됩니다(새 PR 을 만들지 않습니다 · 지난 커밋 고쳐 쓰기·rebase·amend·cherry-pick 금지). 기대 = **lib 0**(`lib/**` 변경 0) · **PNG 0**(새로 찍지 않는다) · **test 1파일**(`test/goal_path_view_test.dart` — T79-02 본문만 · testWidgets 수 불변 → `flutter test` 304 그대로) · **질문 파일 변경 0**(A1~A4·머리말 그대로) · PR 본문 5섹션 새 판(② S05 6줄 · ③ «빈» 한 줄 · ④ 4행 · 까닭 두 줄 = C4 가 준 글자(단 까닭 1줄째의 카드 인용은 원 패킷 311·574행 글자로 고침 — C4 보고 §6-2 ⓓ 와 다르고 이 패킷이 기준) · 나머지 = 1회차 글자 · 단 ⓡ·ⓗ 는 S29·S30 출력 줄 그대로(새 모양 · 1회차 카드의 «한 줄» 을 덮음) · ① 커밋 목록 8줄(맨 위 = 재제출 커밋) · flutter test 시작 기준 304).
> 판정 근거 = C4 보고 §0(설계 저장소 `10_리뷰/2026-10-01_R11b_C4_보고.md`) — 1회차 카드 🔴 «보고와 코드·파일·PNG 가 1건이라도 다르면 재량 없이 반려»(발주자 결정 5) · 규칙 11 «금지하는 if = else 없는 if». [가] 5건: **C4b-5** T79-02 «없는 쪽» 단언이 else 없는 if 둘 + 빈 if 블록 하나 · 카드가 이름으로 든 `s79-segment-caption-0` 0 단언이 어느 경우에도 실행되지 않음(테스트 코드) · **C4b-4** ③ «빈(판정 유보)» 나열에 `s79-deviation`(있을 때) 누락 · **C4b-2** ④ 요지 ≠ 질문 파일 «질문·추측» 칸 글자 · **C4b-3** S05 6줄에 앞머리 `packages/ui_analytics/` + 백틱(카드 정규식 불일치) · **C4b-1** 커밋 순서((5b) `a816264` 가 부록 (6) `1b12631` 뒤 · (5) `b3f3d43` 제목 ≠ 내용) — rebase·amend 금지 조항 때문에 **기록으로만 닫는다**(이 패킷은 고치게 하지 않는다 · C4 보고 §6-3). [나] C4b-6 dy·S27 «차이가 나면 까닭» 줄 없음 — 함께 고친다. lib·PNG 결함 0 · 예고 변이 27/27 잡힘 · `flutter test` 304 통과 · CI 3/3 은 합격. 고칠 것의 모양 = C4 보고 §6-1(T79-02 · C4 시험 304/304 · S29 13 · S30 8 불변 · diff 원본 = C4 작업 폴더 `c4b/logs/s_fix_T7902.diff`) · §6-2 ⓐ~ⓓ(PR 본문 글자).
> 🔵 **규칙 변경(발주자 결정 2026-10-01 · 이 재제출의 C4 판정부터 적용 · 1회차 판정에는 소급하지 않는다)** — «보고 **표기만**의 결함(경로 앞머리·백틱·요지 줄임·까닭 누락 등)은 C4 가 PR 본문을 정정하고 병합 · **코드·테스트 결함과 거짓 주장**은 반려». 본문 «■ 규칙 요약» 에 한 줄로 알린다(그래도 출력 그대로가 원칙 · 복사 상자는 그대로 붙인다).
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기(`refs/pull/21/merge`)를 돌린다(R11a 재제출 패킷이 `ci.yml` 의 `pull_request` · `actions/checkout@v4` `ref` 없음으로 확인한 구조 · 이번에 다시 보지는 않았다). 그래서 기록 커밋이 `main` 에 들어가도 Bob 브랜치에 병합할 까닭이 없다.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R11b-Bob-S79.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R11b 행 · `rounds.md` R11b 행과 **같은 푸시**로 `main` 에 올린다(C4 보고 §8-0 · R11a 재제출 선례 · 0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/S7-9_questions.md` · `inbox/S7-1_questions.md` 는 건드리지 않는다(머리말 «다음 번호» 도 — A1~A4 답 · S7-1 A13 은 PR #21 병합 때 통합 담당이 C4 보고 §7 대로 고친다).
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R11b-Bob-S79.md` 는 `send/` 에 없음). 다른 선행(infra PR 등)은 없다. PR #21 의 `golden:approved` 라벨은 그대로 둔다(1회차 C4 가 허용 목록 `s71_*` 6장 확인 뒤 붙임 · 재제출은 PNG 0 이라 다시 볼 것이 없다).
> 시험 적용(2026-10-01 · 검사 폴더 `C:\Work\AAQ-claude-review` · 로컬 가지 `dry/r11b-resub` = `a816264` 위에 이 패킷 본문만 보고 F1 을 적용 · 커밋 `274ef5d` · 끝난 뒤 `a816264` 분리 HEAD 로 되돌림 · git status 빈 · 가지는 남겨 둠): `flutter test test/goal_path_view_test.dart` **34 통과** · ui_analytics `flutter test` **304 통과 · 0 실패**(시작 기준 a816264 도 304) · `melos.bat run format:fix` = 1 changed(ⓓ else 단언만 여러 줄로 접힘 — F1 끝 예고대로 · 같은 커밋) → 커밋 뒤 `melos.bat run format` **0 changed** · `melos.bat run analyze`(`--fatal-infos`) SUCCESS · 13 패키지 «No issues found» · 정적 37줄 = `a816264` 에서 같은 37줄을 돌린 출력과 **글자 차이 0**(warning 줄 포함 · S05 `:68` / `:92 :109 :179 :285 :329` · S27 `6 0 · 7 0 · 17 2 · 1 0 · 143 0` · **S29 13·3 · S30 8·1**) · `git diff --name-status a816264 HEAD` = test 1줄 · `origin/main...HEAD` 26줄(1회차와 같음) · `origin/main..HEAD` 8줄(맨 위 재제출) · 결과 파일 = C4 `s_fix_T7902.diff` 적용본과 blob 같음(`275ec20`) · F3 대조(코드 81~82 · 86 · 165 · 171행)·F4 대조(질문 파일 10~13행) 모두 상자 글자와 맞음 · 변이 4개(LM1 caption-0 · LM2 이탈 · LM3 차단 아이콘 · LM4 오래됨 배너): 새 T79-02 가 4/4 잡음 · 옛 T79-02 는 LM1 만 놓침(else 없는 if 둘은 «없는 쪽» 경우에 실제로 돌아 LM2·LM3 를 잡았다 · LM1 은 파일 전체로는 1회차에도 T79-13 on·off · T79-10 이 잡음) → 이번 수정의 효과 = **규칙 11 위반 정리 · T79-02 안 caption-0 단언 실행 보장**(파일 단위의 새 구멍 막기는 아니다 — 판정·기록에 그렇게 적는다) · 안 돌린 것 = `melos.bat run test` · `test:contracts`(중첩 melos 멈춤 규칙 · domain_contracts 변경 0 · CI 몫 — 카드의 «SUCCESS» 기대는 시험으로 확인한 값이 아니다) · 0단계 `ls-tree` 는 시험 때 main(`f4972d9`)에 재제출 패킷이 없어 멈춤(의도된 안전장치 — 기록 푸시 뒤 풀림) · 원격 조작 0 · 셸 = Git Bash 만(PowerShell 미실행). 기대값 = 시험 적용 실측 · 다르면 PR 본문에 까닭. 참고 = C4 보고 §6-1 의 diff 시험(복제본 `qmerge` = `f4972d9` + `a816264` · 임시 가지): `dart format` 0 changed · `flutter analyze --fatal-infos` No issues · `flutter test`(ui_analytics) 304/304 · S29 13 · S30 8 불변 · diff +40/−36.

## 0. 한 줄 목적

PR #21 의 T79-02 를 카드 규칙 11(«없는 쪽은 if/else 양쪽 · else 없는 if 금지»)대로 고치고, PR 본문 ②③④ 와 까닭 두 줄을 C4 가 준 글자로 바꿔 다시 내기 — **lib·PNG·질문 파일은 한 글자도 바꾸지 않고, 지난 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s79-goal-path` · 같은 PR #21.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작하기를 권합니다. 1회차 대화를 이어 쓰면 1회차 카드의 «(6) 부록이 마지막 · (6) 뒤에 커밋을 더하지 않는다» 와 이 카드의 «맨 위에 커밋 1개» 가 섞일 수 있습니다(본문은 Bob 이 1회차를 기억하지 못한다는 전제로 썼습니다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R11b-Bob-S79-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R11b-Bob-S79-재제출.md` · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R11b-Bob-S79.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부**(첫 줄 «R11b-Bob-S79 재제출 요청» ~ «(+ flutter test 한 줄)» 끝) · 고치지 않습니다. 새 대화라 규칙 요약 · 고칠 곳의 모양 · 자체 점검 12항 복사 상자 · 정적 37줄 묶음 · PR 본문 복사 상자(① 머리 · S05 6줄 · ③ · ④ · ⑤ · 까닭 두 줄)가 본문에 들어 있습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R11b 패킷은 **이것 하나**(`R11b-Bob-S79-재제출.md`)입니다. 원 패킷 `R11b-Bob-S79.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R11a-Bob-S74-재제출.md` · `_완료/R10c-Bob-S72-재제출.md` · `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드입니다(보내지 않음).

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R11b-Bob-S79 재제출 요청 — 1회차(PR #21 · a816264) 판정: 반려(재제출). 같은 브랜치 ui/m7-s79-goal-path · 같은 PR #21 에 커밋 1개를 맨 위에 더하십시오(새 PR 금지).
이번에 고치는 곳은 테스트 파일 하나(packages/ui_analytics/test/goal_path_view_test.dart 의 T79-02 본문)와 PR 본문뿐입니다. 🔴 lib 0 · PNG 0 · 질문 파일 0 — 하나라도 바뀌면 반려입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R11b 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #21 · 브랜치 ui/m7-s79-goal-path(커밋 a816264)에 아래 F1 커밋 하나를 «더하는» 일입니다. F1 은 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돌기 때문에, main 에 들어간 기록 커밋은 병합하지 않아도 CI 에 들어갑니다.
🔴 1회차 카드의 «(6) 부록이 마지막 커밋 · (6) 뒤에 다른 커밋을 더하지 않는다» 는 이번에 이 카드가 덮습니다 — 재제출 커밋 1개를 맨 위에 더하는 것이 이번 일입니다.
   지난 7개 커밋(순서·제목 포함)은 그대로 둡니다 — rebase·amend·cherry-pick·reset·강제 푸시 금지(커밋 순서 결함 C4b-1 은 통합 담당이 기록으로 닫았습니다 · 고치려 하면 반려).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git branch --show-current     ← ui/m7-s79-goal-path 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m7-s79-goal-path
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git log --oneline -1          ← a816264 로 시작하면 정상(제목 «[M7] R11b (5b) 질문 파일 …» 의 한글은 셸에 따라 깨져 보일 수 있다) · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git rev-parse --short origin/ui/m7-s79-goal-path   ← a816264 로 시작 · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R11b-Bob-S79-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R11b-Bob-S79.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R11b-Bob-S79-» 로 시작하는 줄이 있으면 정상.
        «R11b-Bob-S79-재제출» 줄이 없거나 꼬리 없는 «R11b-Bob-S79.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 카드가 먼저 왔습니다.
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
🔴 이 카드와 1회차 카드(R11b-Bob-S79.md)의 글이 다르면 이 카드가 이깁니다 — 예: 커밋은 재제출 커밋 1개만 맨 위에 · 질문 파일을 고치지 않는다 · 골든을 다시 찍지도 dy 를 다시 재지도 않는다 ·
   PR 본문 ①~⑤ 의 글자는 이 카드 «■ 제출» 대로 · ① 커밋 목록의 맨 위는 재제출 커밋 · main 을 병합하지 않는다.

■ 규칙 요약 (1회차 카드 = 이 브랜치의 docs/ai-context/send/R11b-Bob-S79.md(main 에서는 send/_완료/ 로 옮겨졌다 — 글자는 같다)의 규칙 1~17 · 보고 규칙 · 화면 · Key 표 · 테스트 최소 목록 · 정적 묶음 · 골든 · 질문 파일 절이 유효 — 단 이 카드와 다른 곳은 이 카드가 이긴다 · 여기엔 핵심만)
· 이번에 고치는 곳 = 아래 한 곳뿐입니다.
    packages/ui_analytics/test/goal_path_view_test.dart   (F1 — T79-02 본문 · 새 testWidgets/test 를 더하지 않는다 · 다른 테스트는 한 글자도 안 바꾼다)
· 🔴 고치면 반려: 위 한 파일 밖의 전부 — packages/ui_analytics/lib/**(goal_path_screen.dart · src/goal_path/** · monthly_report_screen.dart · labels.dart · analytics_providers.dart · ui_analytics.dart 포함 · 🔴 lib 0) ·
  test/golden/goldens/*.png 전부(s79_* 8장 · s71_* 포함 · 🔴 PNG 0 · --update-goldens 를 돌리지 않는다) · test/golden/s79_golden_test.dart · test/goal_path_fakes.dart ·
  test/monthly_report_view_test.dart(TA-1~TA-3 포함) · 그 밖의 기존 테스트 전부 · test/golden/ 의 하네스·reference/**·README · test/flutter_test_config.dart ·
  domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml · docs/ai-context/inbox/S7-9_questions.md · S7-1_questions.md(아래 «질문 파일»).
  🔴 PNG 나 lib 가 하나라도 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 테스트 규칙(1회차 카드 규칙 11 — 이번에 걸린 곳만 글자 그대로):
   전제는 expect(조용한 return·if 건너뛰기 금지) ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) ·
   if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 ·
   금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기) · T79-02 의 사슬 목록을 만드는 collection-if(«있는 것만 넣는다»)는 «없는 쪽은 따로 단언»과 짝일 때만 허용.
   ⓡ = expect(find.text(AnalyticsLabels.retryButton), findsNothing); 줄 · ⓗ = expect(<목록>, hasLength(n)); 전제 줄 — 정적 S29·S30 이 파일마다 정확히 13·3 / 8·1 이어야 한다(이번 F1 은 ⓡ·ⓗ 줄을 더하지도 빼지도 않는다).
  (그 밖 — 테스트 이름 그대로 · 테스트에 한국어 리터럴 금지 · 주석에도 한국어를 새로 쓰지 않는다(정적 S01) · 새 띄우기 도우미·새 가짜 금지.)
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인.
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 카드가 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.
🔵 규칙 변경 알림(발주자 결정 2026-10-01 · 이번 재제출의 판정부터): 보고 «표기만»의 결함(경로 앞머리·백틱·요지 줄임·까닭 누락 등)은 통합 담당(C4)이 PR 본문을 정정하고 병합합니다 · 코드·테스트 결함과 거짓 주장(코드·파일·출력에 없는 것을 있다고 쓰기)은 그대로 반려입니다 — 그래도 출력 그대로 · 복사 상자 그대로가 원칙입니다.

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다 — 배치 1~13 · 판정 유보 때 7b~7f 부재 · Key 표 밖 s79- Key 0 · 배너·StaleBanner 스크롤 밖 · 정적 라벨 4 · goalPathProvider(autoDispose) · 배럴 export 자리 · 부록 허용 diff 셋 · 본보기 2파일 차이 0.
새 PNG s79_* 8장(390×900 · 넘침·잘림 0)과 다시 찍은 s71_* 6장은 맞고 그 밖의 PNG 는 그대로였습니다. 골든 dy 8개 = C4 재실측 8/8 일치(784 · 824 · 532 · 804 · light=dark).
카드가 예고한 변이 20항목(27건)은 전부 테스트가 잡았습니다. flutter test 304 통과 · CI 3/3 초록.
보고에서 맞은 곳 — ① name-status 26줄 · 커밋 목록 7줄(실제와 글자 같음) · ② 12항 원문 15줄(글자 차이 0 · 괄호 12개 모두 사실) · 정적 37줄 출력(C4 재실행과 차이 0) · S29 13·3 · S30 8·1 · ③ «로딩»·«정상»·«차단»·«부록» · 골든 표 8행 · ⑤ «없음».

■ 왜 반려인가 — 카드 / 코드 · 보고 글 / 실제 (C4 검사 갈래 둘 이상이 따로 확인 · C4b-5 는 통합 담당이 코드·카드를 직접 열어 확인)
① T79-02 «없는 쪽» 단언 (C4b-5 · 테스트 코드)
   카드:  T79-02 «없는 쪽은 따로 단언한다(if/else 양쪽 — staleBannerTitle 0 · find.byIcon(Icons.block) 0 · s79-deviation 0 · s79-segment-caption-0 0). 세 경우가 양쪽을 한 번 이상씩 지난다.» + 규칙 11 «금지하는 if = else 없는 if».
   실제:  goal_path_view_test.dart 110~129행 — if (isStale) { // stale shows banner } else {…} 는 if 쪽이 주석뿐인 빈 블록 · if (activeFlags.isEmpty) {…}(115~117) · if (vm.deviationText == null) {…}(118~120) 은 else 없는 if ·
          s79-segment-caption-0 0 단언이 없다 — 122~129행 루프(121행은 그 주석)는 measured 구간에서만 단언하는데 on·off 는 구간 0 · realworld 는 측정 아닌 구간 1 이라 한 번도 돌지 않는다.
② ③ «빈(판정 유보)» 나열 (C4b-4)
   카드:  «goal_path_screen.dart 를 위에서 아래로 읽으며 나오는 순서 그대로 · 조건으로 붙는 것(… s79-deviation …)은 «(있을 때)»» · 판정 유보 = 1~7a → s79-unavailable → 8~13.
   실제:  코드는 if (vm.deviationText != null)(81~82행)가 chartUnavailableLabel 갈래(86행)보다 앞이고 그와 무관하다 — 판정 유보에서도 그 자리를 지난다. «빈» 줄에 Key('s79-deviation')(있을 때)가 빠졌다(«정상» 줄에는 있다).
③ ④ 질문 표 요지 (C4b-2)
   카드:  «새 행 번호·요지 — 질문 파일에 쓴 글자와 같게».
   실제:  질문 파일 «측정: s79_on_track dy 실측값 (light=784.0, dark=784.0 < 900)» ↔ ④ «s79_on_track dy 실측 (784.0 < 900)» — «측정:»·«값»·light/dark 가 빠졌다(4행 모두).
④ S05 결과 줄 (C4b-3)
   카드:  «정확히 «<파일>:<줄> — 탭 콜백 안» 만 · 정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ 와 완전히 같아야 · <파일> = git grep 출력의 경로 그대로».
   실제:  6줄 모두 앞머리 packages/ui_analytics/ 를 붙이고(git grep 출력은 lib/…) 줄 전체를 백틱으로 감쌌다. 줄 번호와 «탭 콜백 안» 사실은 6/6 맞다.
⑤ 커밋 순서 (C4b-1 — 고치지 않는다 · 기록으로 닫음)
   (5b) a816264 가 부록 (6) 1b12631 위에 있고, (5) b3f3d43 제목의 «+ 질문 파일» 은 그 커밋에 없다. 카드가 rebase·amend 를 금했으므로 통합 담당이 기록으로 닫았다 — 이 재제출에서 손대지 않는다.
함께 고칠 것: C4b-6 — 골든 dy·S27 이 1회차 카드의 드라이런 수와 다른데 카드 «차이가 나면 PR 본문에 까닭» 줄이 없었다(값은 사실 · 아래 F5 의 두 줄).
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.4 생성물은 git 에 없습니다(브랜치를 바꿨거나 새로 받았으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: 304 통과 · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·푸시 -u 는 하지 않습니다):
   · docs/ai-context/send/R11b-Bob-S79.md(1회차 카드 — 이 브랜치에 있다) — «■ 규칙 요약» 11 · «■ 화면» · «■ Key 표» · «■ 테스트 최소 목록» T79-02·T79-13 · «■ 정적 묶음» · «■ 제출» ②
   · docs/ai-context/prompt_M7.md 155~169행(자체 점검 12항 원문 — 아래 «■ 제출» ② 상자와 같은 글자)
   · packages/ui_analytics/lib/src/screens/goal_path_screen.dart 55~180행(F3 의 «빈» 줄을 대조하려면 꼭 — 고치지는 않는다)
   · docs/ai-context/inbox/S7-9_questions.md(F4 의 ④ 를 대조하려면 꼭 — 고치지는 않는다)

■ 고칠 것 — F1~F6 (1회차 반려 · C4 2026-10-01) — 같은 브랜치 ui/m7-s79-goal-path 에 커밋 1개를 더해 푸시합니다(rebase·amend·강제 푸시 금지).
   (F1 = 테스트(반려 사유) · F2~F5 = PR 본문(«■ 제출» 의 복사 상자) · F6 = 커밋)

F1 (T79-02 · goal_path_view_test.dart 72~131행 · C4b-5) «없는 쪽» 단언을 if/else 짝으로 바꿉니다. 행 번호는 a816264 의 것입니다.
   고칠 범위 = 72행 final List<BlockFlag> activeFlags = safety.activeFlags; 다음 줄부터 131행 ⓡ 줄 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 앞까지.
   그 밖(경우 목록 49~55행 · 띄우기 57~70행 · 72행 · 131행 ⓡ 줄 · 테스트 이름)은 한 글자도 안 바꿉니다.
   ① 사슬 목록을 빈 목록 final List<Finder> chain = <Finder>[]; 로 시작하고, 위 → 아래 차례대로 채웁니다. 조건이 붙는 네 자리는 collection-if 로 넣지 않고 if/else 문으로 씁니다 —
      있는 쪽 = 사슬에 넣기(chain.add / 캡션만 chain.addAll) · 없는 쪽(else) = 그 자리의 findsNothing 단언 하나:
        ⓐ 오래됨     조건 isStale                     있는 쪽 chain.add(find.text(AnalyticsLabels.staleBannerTitle))   / else expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing)
        ⓑ 차단       조건 activeFlags.isNotEmpty      있는 쪽 chain.add(find.text(activeFlags.first.label))          / else expect(find.byIcon(Icons.block), findsNothing)
        ⓒ 이탈       조건 vm.deviationText != null    있는 쪽 chain.add(find.byKey(const Key('s79-deviation')))       / else expect(find.byKey(const Key('s79-deviation')), findsNothing)
        ⓓ 띠 캡션    조건 captions.isNotEmpty         있는 쪽 chain.addAll(captions)                                / else expect(find.byKey(const ValueKey<String>('s79-segment-caption-0')), findsNothing)
      captions = 지금 87~89행의 for · if 를 그대로 옮긴 목록입니다 — final List<Finder> captions = <Finder>[ for (…) if (vm.segments[i].kind != SegmentKind.measured) find.byKey(ValueKey<String>('s79-segment-caption-$i')), ];
        (이 collection-if 는 계약이 정한 부재 규칙이고 바로 아래 ⓓ if/else 의 없는 쪽 단언과 짝이라 규칙 11 이 허용합니다.)
      조건 없는 Key 들은 그 사이에 chain.addAll(<Finder>[ … ]); 로 넣습니다. 전체 차례(지금 사슬과 같다):
        ⓐ → ⓑ → s79-asof → s79-judgement → s79-basis → ⓒ → s79-period → s79-chart → s79-x-first → s79-legend-actual → s79-legend-planned → ⓓ →
        s79-values-toggle → s79-assumption-header → s79-backtest-basis → s79-starting-capital → s79-honest → s79-honest-worst → s79-disclaimer
   ② 82행 if (vm.chartUnavailableLabel == null) ...<Finder>[ … ] 묶음을 없앱니다 — T79-02 의 세 경우(on · off · realworld)는 모두 차트가 있어 이 갈래는 늘 참이고 else 가 없습니다(판정 유보는 T79-04 몫).
      그 안의 Key(s79-chart · s79-x-first · s79-legend-actual · s79-legend-planned · 캡션 · s79-values-toggle)는 위 ① 의 차례 그대로 사슬에 남습니다.
   ③ 사슬 단언 뒤의 «없는 쪽» 블록(110~129행)을 통째로 지웁니다 — 빈 if 블록(// stale shows banner) · else 없는 if 둘 · measured 구간 루프와 그 주석(121행).
      그 단언들은 ① 의 else 로 옮겨졌습니다(measured 구간의 캡션 부재는 T79-13 이 이미 봅니다 · T79-13 은 고치지 않는다).
   ④ 사슬 단언 루프 두 개(100~102행 findsOneWidget · 103~108행 dy lessThan)와 131행 ⓡ 줄은 한 글자도 안 바꿉니다.
   🔴 hasLength( 를 쓰지 않습니다(captions 길이를 전제로 세지 않는다 — 쓰면 S30 이 8 에서 달라진다) · retryButton 줄을 더하거나 빼지 않습니다(S29 13) · 한국어 리터럴·한국어 주석 0 · 새 도우미 0 · 다른 테스트 0.
   🔴 세 경우가 네 갈래의 양쪽을 한 번 이상씩 지나는지 고친 뒤 눈으로 봅니다(픽스처가 정한다 — 이 표와 다르면 멈추고 채팅으로):
        ⓐ 오래됨 = off 참 / on·realworld 거짓 · ⓑ 플래그 = off(행 4)·realworld(행 3) 있음 / on(행 0) 없음 · ⓒ 이탈 = off 있음 / on·realworld 없음 · ⓓ 캡션 = realworld 있음 / on·off 없음.
        볼 곳(읽기만 · 테스트에 print 를 넣거나 실행해 보지 않는다): ⓐ = T79-02 경우 목록(49~55행)의 셋째 값 ·
        ⓑ = packages/domain_contracts/fixtures/safety_states.json 의 rows 0 · 3 · 4 의 active_flags(빈 목록이면 없음) ·
        ⓒ ⓓ = packages/domain_contracts/fixtures/m7/m7_goal_path_{on,off,realworld}.json 의 rows[0] — deviation_text(키가 없으면 없음) · segments[].kind(MEASURED 가 아닌 것이 있으면 캡션 있음).
   (ⓓ 의 else 단언은 한 줄이 80자를 넘어 format:fix 가 여러 줄로 접습니다 — 접힌 모양 그대로 둡니다 · F6 대로 같은 커밋.)

F2 (PR 본문 ② S05 결과 6줄 · C4b-3) «■ 제출» ② 의 «S05 복사 상자» 글자 그대로 — 앞머리 packages/ui_analytics/ 없이 · 백틱 없이 · 줄 끝 빈칸 없이(정규식 안$ 가 깨진다).
   lib 를 안 바꾸므로 정적 묶음의 S05a 는 lib/src/screens/goal_path_screen.dart:68 한 줄 · S05b 는 lib/src/screens/monthly_report_screen.dart:92 · :109 · :179 · :285 · :329 다섯 줄이 1회차와 같이 나와야 합니다 — 다르면 lib 가 바뀐 것이니 멈춘 뒤 채팅으로.

F3 (PR 본문 ③ «빈(판정 유보)» 한 줄 · C4b-4) «■ 제출» ③ 의 복사 상자 글자 그대로 — «빈» 줄에 Key('s79-deviation')(있을 때)가 Key('s79-basis') 와 Key('s79-period') 사이에 들어갑니다.
   🔴 goal_path_screen.dart 를 열어 대조합니다: 81~82행 if (vm.deviationText != null) Text(… key: const Key('s79-deviation')) 가 86행 if (vm.chartUnavailableLabel == null) 보다 앞이고, 판정 유보 카드(Key('s79-unavailable') · 171행)는 그 갈래의 else 쪽(165행)입니다.
   맞지 않는 곳이 하나라도 있으면 고쳐 쓰지 말고 멈춘 뒤 채팅으로. ③ 의 다른 줄(로딩 · 정상 · 차단 · 부록 · 골든 표 8행)은 1회차 글자 그대로입니다(C4 가 코드·PNG 와 대조해 맞음 · lib·PNG 불변).

F4 (PR 본문 ④ 질문 표 · C4b-2) «■ 제출» ④ 의 복사 상자 글자 그대로 — 요지 칸 = 질문 파일 «질문·추측» 칸 글자 그대로(«측정:» · «실측값» · light=…, dark=… 포함).
   🔴 대조(저장소 뿌리에서): git grep -n "측정:" -- docs/ai-context/inbox/S7-9_questions.md   ← 4줄의 «질문·추측» 칸 글자가 상자의 요지 칸과 한 글자도 다르지 않아야 합니다(다르면 멈추고 채팅으로 — 질문 파일을 고치지 않는다).
   (셸에서 한글이 깨져 보이면 편집기로 docs/ai-context/inbox/S7-9_questions.md 10~13행을 열어 대조합니다 — 읽기만 · 고치지 않는다.)

F5 (PR 본문 끝 까닭 두 줄 · C4b-6) «■ 제출» 의 «까닭 복사 상자» 두 줄을 끝 줄 «flutter test: …» 바로 위에 글자 그대로 붙입니다.
   🔴 까닭 줄은 그 두 줄뿐 · 글자 그대로 — 테스트별 수·줄 번호를 손으로 세어 더하지 않습니다. 수가 필요해 보이면 이 카드가 준 명령(정적 묶음)의 출력 그대로만 쓰고, 그래도 모자라면 멈춘 뒤 채팅으로(손으로 센 수 = 보고 ≠ 사실 위험).

F6 (커밋 · C4b-1 은 손대지 않음) 커밋은 하나 — 맨 위에:
   git commit -m "[M7] R11b 재제출 (1) T79-02 if/else 짝"
   (format:fix 가 바꾼 줄도 이 커밋 안에 — 커밋 전에 melos.bat run format:fix 를 돌려 함께 add 한다 · 커밋 뒤의 melos.bat run format 은 0 changed 여야 한다 · 아니면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
   🔴 지난 커밋(664ca20 · 9c4b828 · d4adf97 · b34b045 · b3f3d43 · 1b12631 · a816264)을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지 · 커밋 순서·제목 결함(C4b-1)은 기록으로 닫혔습니다.

■ 고치지 않는 것 (1회차가 맞았거나 이 카드 밖 — 손대면 반려)
 · lib/** 전부 · PNG 전부(s79_* 8장 · s71_* 포함 — --update-goldens 금지) · s79_golden_test.dart · goal_path_fakes.dart · monthly_report_view_test.dart · labels.dart
 · 골든 dy — lib·골든 테스트·PNG 가 그대로라 다시 재지 않습니다(질문 파일 A1~A4 = 1회차 실측 · C4 재실측 8/8 일치 · s79_golden_test.dart 를 열어 lessThan(0) 으로 바꾸는 일도 하지 않는다)
 · 질문 파일 docs/ai-context/inbox/S7-9_questions.md · S7-1_questions.md — A1~A4 행·머리말(«다음 번호» 포함)·S7-1 A13 행을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 C4 재실측과 대조해 닫는다)
 · T79-02 의 경우 목록·띄우기·사슬 단언 루프 두 개·ⓡ 줄 · 나머지 테스트(T79-01 · 03~15 · 08a · 08b · TA-1~TA-3) — 이번에 걸린 곳이 아니다
 · ⓡ·ⓗ 줄 — 더하지도 빼지도 않는다 · 테스트 이름 · 테스트 수(304 그대로)
 · 지난 7개 커밋 · C4b-12(배너 «스크롤 밖» 단언)는 다음 카드 몫 — 이번에 넣지 않는다(넣으면 범위 밖 변경)

■ 질문 파일
· 이번 F1~F6 은 전부 이 패킷이 정했고 lib·PNG 가 그대로라 잴 것도 없으므로, 질문 파일은 바뀌지 않는 것이 정상입니다(새 행 0).
· 🔴 새 행이 필요해 보이면(측정·추측·질문 어느 것이든) 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 — 이번 커밋은 테스트 파일 하나만 add 하고, 아래 «git diff --name-status a816264 HEAD» 는 테스트 한 줄이어야 합니다(질문 파일 줄이 나오면 멈춤).

■ 제출
  (F1 을 고친 뒤)
  cd packages/ui_analytics
  flutter test test/goal_path_view_test.dart   ← 먼저 이 파일만 · 34 통과(실패하면 고친 곳을 다시 본다 · lib 를 고치지 않는다)
  flutter test   ← 옵션 없이 전부 통과 · 수 = 304(1회차와 같다 — 채팅에 끝 줄을 그대로 적습니다)
  cd ../..
  melos.bat run format:fix
  git status --short   ← M 은 packages/ui_analytics/test/goal_path_view_test.dart 하나뿐이어야 합니다(PNG·lib·질문 파일의 M = 금지 → git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  git add packages/ui_analytics/test/goal_path_view_test.dart
  git commit -m "[M7] R11b 재제출 (1) T79-02 if/else 짝"   ← F1 + format:fix 가 바꾼 줄(F6)
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git diff --name-status a816264 HEAD
     ← 재제출 커밋의 변경만 봅니다. 🔴 정확히 이 한 줄이어야 합니다:
        M	packages/ui_analytics/test/goal_path_view_test.dart
        다른 줄이 한 줄이라도 나오면(lib · PNG · 질문 파일 · goal_path_fakes · s79_golden_test · monthly_report_* …) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git log --oneline -2   ← 맨 위 = 재제출 커밋 · 그 아래 = a816264(지난 커밋은 그대로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #21 자동 반영 · 새 PR·라벨·강제 푸시·rebase·main 병합 금지)
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(1회차와 같은 26줄이 정상 — main 이 앞으로 갔어도 점 세 개 diff 는 갈라진 곳(f4972d9)부터 센다 · goal_path_view_test.dart 는 1회차에 이미 A)
  git log --oneline origin/main..HEAD   ← 아래 ① 에 그대로 붙일 출력(8줄 — 맨 위 = 재제출 커밋 · 그 아래 7줄 = 1회차 그대로)
  cd packages/ui_analytics → 아래 «정적 묶음» 37줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력
     🔴 푸시한 그 커밋 위에서 · git status 가 빈 채로 새로 돌린다 · 1회차 출력을 쓰지 않는다.
■ 정적 묶음 — packages/ui_analytics 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다(1회차 카드의 37줄과 같은 글자)
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 37줄을 돌려 글자로 대조한다 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 · «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/goal_path_view_test.dart test/goal_path_fakes.dart test/golden/s79_golden_test.dart; echo "EXIT:$?"
echo "## S01b appendix test hangul lines unchanged (HEAD = origin/main)"; git grep -cP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/monthly_report_view_test.dart; git grep -cP "'[^'\n]*[\x{AC00}-\x{D7A3}]" origin/main -- test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/goal_path_view_test.dart test/golden/s79_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/goal_path_view_test.dart test/golden/s79_golden_test.dart; echo "EXIT:$?"
echo "## S02c appendix test names ASCII"; git grep -nP "testWidgets\('TA-[^']*[^\x00-\x7F]" -- test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S02d appendix tests 3"; git grep -c "testWidgets('TA-" -- test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S03 replaceFirst replaceAll 0"; git grep -nE "replaceFirst|replaceAll" -- lib/src/screens/goal_path_screen.dart lib/src/screens/monthly_report_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes (old reportArchive line only)"; git grep -n "AppRoutes\." -- lib/src/screens/goal_path_screen.dart lib/src/screens/monthly_report_screen.dart; echo "EXIT:$?"
echo "## S05a opener lines goal path (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/goal_path_screen.dart; echo "EXIT:$?"
echo "## S05b opener lines monthly report (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/monthly_report_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 DateRange ConfigRepository 0"; git grep -nE "DateRange|[Cc]onfigRepository" -- lib/src/screens/goal_path_screen.dart lib/src/goal_path; echo "EXIT:$?"
echo "## S15 autoDispose 4"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "goal_path/|chart/|explore/|planner|perf_chart|analytics_skeleton|analytics_error_view" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports 8"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint" -- lib; echo "EXIT:$?"
echo "## S25 value refs 0 (goal path files)"; git grep -nP "\.value\b(?!OrNull)(?!\s*\()|PerfPoint\s*\([^)]*\bvalue\b" -- lib/src/screens/goal_path_screen.dart lib/src/goal_path; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea 0 (goal path files)"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/screens/goal_path_screen.dart lib/src/goal_path; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/src/screens/monthly_report_screen.dart lib/ui_analytics.dart test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S28 goal link key 1"; git grep -n "s71-goal-link" -- lib; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/goal_path_view_test.dart test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/goal_path_view_test.dart test/monthly_report_view_test.dart; echo "EXIT:$?"
  (기대 출력 — lib·PNG·다른 테스트 불변이라 37줄의 출력은 1회차 출력과 같다(EXIT 표기·warning 줄 말고):
   S05a = lib/src/screens/goal_path_screen.dart:68 한 줄 · S05b = monthly_report_screen.dart :92 · :109 · :179 · :285 · :329 다섯 줄 ·
   S27 = 6 0 · 7 0 · 17 2 · 1 0 · 143 0(goal_path_view_test.dart 는 S27 이 보지 않는다) · S29 = test/goal_path_view_test.dart:13 · test/monthly_report_view_test.dart:3 · S30 = test/goal_path_view_test.dart:8 · test/monthly_report_view_test.dart:1 —
   C4 시험 적용 실측과 같음 · 🔴 S29·S30 이 이와 다르면 제출하지 말고 F1 을 다시 본다(정확히 13·3 / 8·1 — 1회차 카드 규칙 11 · 까닭 한 줄로 갈음 불가) · 그 밖의 줄이 1회차와 다르면 멈춘 뒤 채팅으로)
  채팅으로 — PR 본문 5섹션을 처음부터 새로(지난 본문을 고쳐 쓰지 않습니다). PR #21 본문은 통합 담당이 이 새 판으로 통째로 바꿉니다:
   ① 아래 «① 머리 복사 상자» 두 줄 그대로 +
      «바뀐 파일:» + 위 git diff --name-status origin/main...HEAD 출력 그대로(코드 블록 하나 · 손으로 쓰지 않음 · A/M · PNG 포함 · 26줄이 정상) +
      «커밋 목록:» + 위 git log --oneline origin/main..HEAD 출력 그대로(코드 블록 하나 · 8줄 · 맨 위 = 재제출 커밋 — 1회차 카드의 «부록 (6) 이 맨 위» 는 이 카드가 덮는다)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: S7-9 — 목표 금액 경로 · 부록 S7-1 — 목표 경로 버튼·값 열 정렬
본보기 2파일(정적 묶음 S18b = 차이 0): `lib/src/goal_path/goal_path_chart.dart` · `lib/src/goal_path/goal_path_chart_painter.dart`
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 15줄 그대로인지 셉니다 — 11번·12번은 각각 3줄·2줄(들여쓰기 4칸 줄 포함)이고, 한 줄로 잇지 않습니다(줄을 이으면 = 보고 불일치).
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음 결과의 수 — 1회차와 같은 글자):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «S7-9 화면 파일 산술 0 · 차트 산술은 옮긴 본보기의 정규값 × 크기뿐(정적 S18b 차이 0)»
        3번 = «정적 묶음 S20 — 0건»
        4번 · 5번 · 6번 · 8번 = «이 카드 범위 밖»
        7번 = «앞절 T79-09 expectGoalPathMatches(realworld 실제선 끊김) / 뒷절 값 표 결측 행 = 엔진 valueText 그대로(T79-07) · 배지 0»
        9번 = «as-of 는 목표 경로 화면에 1줄(s79-asof) · 오래됨 배너 = StaleBanner(T79-11)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 기존 PNG M = 허용 목록 s71_* 만(부록 재생성) · domain_contracts 변경 0»
        11번 = «정적 묶음 S21 결과 <N>건 · 보강 S22 결과 <N>건 · S23 결과 <N>건»
        12번 = «앞 두 절 이 카드 범위 밖(S7-9 에는 세후 사다리가 없다) / 뒷절 가정 카드 두 줄 = s79-backtest-basis · s79-starting-capital(T79-02)»
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
      이어서 «정적 묶음 출력:» + 37줄 출력 전부를 코드 블록 하나로 그대로 +
      «S05a 결과:» 다음 줄에 아래 상자의 첫 줄 · «S05b 결과:» 다음 줄부터 아래 상자의 나머지 5줄 — 글자 그대로(백틱·앞머리·괄호·설명·줄 끝 빈칸 없이 · 각 줄이 정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ 와 완전히 같다):
      ┌── S05 복사 시작(다음 줄부터 · 6줄)
lib/src/screens/goal_path_screen.dart:68 — 탭 콜백 안
lib/src/screens/monthly_report_screen.dart:92 — 탭 콜백 안
lib/src/screens/monthly_report_screen.dart:109 — 탭 콜백 안
lib/src/screens/monthly_report_screen.dart:179 — 탭 콜백 안
lib/src/screens/monthly_report_screen.dart:285 — 탭 콜백 안
lib/src/screens/monthly_report_screen.dart:329 — 탭 콜백 안
      └── S05 복사 끝(이 줄 앞까지)
         (위 6줄은 F2 대로 정적 묶음 S05a·S05b 출력의 경로·줄 번호와 같아야 합니다 — 다르면 멈춘 뒤 채팅으로.)
      + ⓡ·ⓗ = 아래 모양으로(1회차 카드 «■ 제출» ② 의 «ⓡ = S29 출력 · ⓗ = S30 출력» 한 줄은 이 카드가 덮는다 — 출력 줄을 고치지 않고 그대로 옮기기 위해서) — 숫자 줄은 정적 묶음 S29·S30 출력 줄을 그대로 복사(test/ 를 떼거나 / 로 잇지 않는다 · 손으로 쓰지 않는다):
         ⓡ = S29 출력:
         <S29 출력 첫 줄 그대로>
         <S29 출력 둘째 줄 그대로>
         ⓗ = S30 출력:
         <S30 출력 첫 줄 그대로>
         <S30 출력 둘째 줄 그대로>
   ③ 스크린샷 서술 — 아래 복사 상자 글자 그대로(로딩 · 정상 · 빈(판정 유보) · 차단 · 부록 5줄 + 골든 표 8행 · 줄 사이 빈 줄 포함).
      🔴 F3 대조를 마친 뒤 붙입니다. «빈» 줄만 1회차와 다르고(Key('s79-deviation')(있을 때) 추가) 나머지는 1회차 글자 그대로입니다 — 낱말을 바꾸거나 요약어(«순서대로»·«정상 배치»·«모두»·«상단»)를 더하지 않습니다.
      ┌── ③ 복사 시작(다음 줄부터)
**로딩**: `AnalyticsSkeleton`(배너 없음)

**정상**: `ValueKey<String>('s79-${vm.yyyyMm}')` → `StaleBanner`(있을 때) → `SafetyBlockBanner`(있을 때) → `Expanded(ListView)` → `Key('s79-asof')` → `Key('s79-judgement')` → `Key('s79-basis')` → `Key('s79-deviation')`(있을 때) → `Key('s79-period')` → `Key('s79-chart')` → `Key('s79-x-first')` → `Key('s79-x-last')` → `Key('s79-legend-actual')` → `Key('s79-legend-planned')` → `ValueKey<String>('s79-segment-caption-$i')`(있을 때) → `Key('s79-values-toggle')` → `Key('s79-values-table')`(있을 때) → `Key('s79-assumption-header')` → `Key('s79-backtest-basis')` → `Key('s79-starting-capital')` → `Key('s79-honest')` → `Key('s79-honest-worst')` → `Key('s79-disclaimer')`

**빈(판정 유보)**: `ValueKey<String>('s79-${vm.yyyyMm}')` → `StaleBanner`(있을 때) → `SafetyBlockBanner`(있을 때) → `Expanded(ListView)` → `Key('s79-asof')` → `Key('s79-judgement')` → `Key('s79-basis')` → `Key('s79-deviation')`(있을 때) → `Key('s79-period')` → `Key('s79-unavailable')` → `Key('s79-assumption-header')` → `Key('s79-backtest-basis')` → `Key('s79-starting-capital')` → `Key('s79-honest')` → `Key('s79-honest-worst')` → `Key('s79-disclaimer')`

**차단**: `SafetyBlockBanner` 위치 = `StaleBanner` 아래 · `Expanded(ListView)` 바깥 위(값이 온 뒤의 `Column` 둘째 자식)

**부록**: S7-1 `_buildFooter`: `goalLine Text` → `Key('s71-goal-link')`(goalDeepLink 있을 때) → `Divider` → `disclosureViewCountText`

**골든 표 8행**:

| 이름 | 입력 픽스처 | 크기 | dy (light/dark) | 배치·잘림 |
|---|---|---|---|---|
| s79_on_track_light | m7/m7_goal_path_on.json | 390×900 | 784.0 | s79-asof → s79-judgement → s79-basis → s79-period → s79-chart(실제선·계획선 모두 그려짐) → x 양끝 글자 → 범례 2줄 → s79-values-toggle → 가정 카드 → s79-honest → s79-honest-worst → s79-disclaimer · 잘림 없음 |
| s79_on_track_dark | m7/m7_goal_path_on.json | 390×900 | 784.0 | light와 동일 구조 · dark 테마 · 잘림 없음 |
| s79_off_track_light | m7/m7_goal_path_off.json | 390×900 | 824.0 | s79-deviation 줄 추가로 on_track보다 높음 · 실제선 계획선 아래 이탈 형태 · 잘림 없음 |
| s79_off_track_dark | m7/m7_goal_path_off.json | 390×900 | 824.0 | light와 동일 구조 · dark 테마 · 잘림 없음 |
| s79_hold_light | m7/m7_goal_path_hold.json | 390×900 | 532.0 | 차트 없음 · s79-unavailable 카드 보임 · 가정 카드 → 정직 기대 → 고지 · 잘림 없음 |
| s79_hold_dark | m7/m7_goal_path_hold.json | 390×900 | 532.0 | light와 동일 구조 · dark 테마 · 잘림 없음 |
| s79_realworld_light | m7/m7_goal_path_realworld.json | 390×900 | 804.0 | 빗금 띠(unavailable 구간) 보임 · 띠 캡션 1줄 · 실제선 중간 끊김(결측 구간) · 잘림 없음 |
| s79_realworld_dark | m7/m7_goal_path_realworld.json | 390×900 | 804.0 | light와 동일 구조 · dark 테마 · 잘림 없음 |
      └── ③ 복사 끝(이 줄 앞까지)
   ④ 질문 표 — 아래 복사 상자 글자 그대로(F4 대조를 마친 뒤 · S7-9 와 S7-1 을 나눠서):
      ┌── ④ 복사 시작(다음 줄부터)
S7-9 새 행:

| 번호 | 요지 |
|---|---|
| A1 | 측정: s79_on_track dy 실측값 (light=784.0, dark=784.0 < 900) |
| A2 | 측정: s79_off_track dy 실측값 (light=824.0, dark=824.0 < 900) |
| A3 | 측정: s79_hold dy 실측값 (light=532.0, dark=532.0 < 900) |
| A4 | 측정: s79_realworld dy 실측값 (light=804.0, dark=804.0 < 900) |

S7-1 새 행: 없음
      └── ④ 복사 끝(이 줄 앞까지)
   ⑤ 추측한 것 = «없음» 한 줄 — S7-9 A1~A4 는 «종류» 칸이 «추측» 이지만 «질문·추측» 칸이 «측정:» 으로 시작하는 측정 행이라 ⑤ 에 넣지 않는다 · S7-1 새 행 0(1회차 ⑤ «없음» 과 같다 · 질문 파일과 ⑤ 가 다르면 반려).
   까닭 두 줄 — ⑤ 다음 · 끝 줄 «flutter test: …» 바로 위에 아래 상자 글자 그대로(F5):
      ┌── 까닭 복사 시작(다음 줄부터 · 2줄)
까닭(골든 dy): s79-disclaimer 아래 끝 784·824·532·804 가 드라이런 803·847·562·827 보다 19~30 작다 — goal_path_screen.dart 의 SizedBox 간격(4·8)과 판정 줄 글자 크기·굵기가 다르다(카드 «간격(SizedBox 높이)·글자 굵기·Card 모서리는 재량» · «재량인 것(여백·글자 크기·모서리)»).
까닭(S27): monthly_report_view_test.dart 143/0 — 드라이런 146/0 은 TA-2 Divider 보강 전 수이고 TA 짜임에 따라 더한 줄 수가 다르다(기준인 둘째 수 = 0).
      └── 까닭 복사 끝(이 줄 앞까지)
   (+ flutter test 한 줄 — «flutter test: 시작 기준 304 → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>»(예 «… +304: All tests passed!» 처럼 출력 끝 줄을 고치지 않고 · 기대 = 304 · 수를 따로 계산해 덧붙이지 않는다))
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s79-goal-path` 에 추가 커밋 **1개**: `[M7] R11b 재제출 (1) T79-02 if/else 짝`(format:fix 가 바꾼 줄 포함). main 병합 커밋 **없음** · 지난 7개 커밋 **그대로**(`git log --oneline origin/main..HEAD` = 8줄 · 맨 위 = 재제출 커밋 · 아래 7줄 = 1회차 글자).
- `test/` 수정 1 — `goal_path_view_test.dart` T79-02 본문만: 조건 넷(오래됨 · 플래그 · 이탈 · 띠 캡션)이 모두 if/else 짝(있으면 사슬에 · 없으면 findsNothing — 캡션의 없는 쪽 = `s79-segment-caption-0` 0) · `chartUnavailableLabel` collection-if 묶음 없음 · 사슬 뒤의 빈 if 블록·else 없는 if·measured 루프 없음 · 사슬 단언 루프 두 개·ⓡ 줄 그대로. C4 보고 §6-1 과 같은 뜻(글자는 Bob 이 쓴다 — 줄 모양·순서가 조금 달라도 위 뜻이면 된다).
- `lib/` 변경 0 · PNG 변경 0 · 질문 파일 변경 0 — `git diff --name-status a816264 HEAD` = `M	packages/ui_analytics/test/goal_path_view_test.dart` 한 줄.
- `ui_analytics` `flutter test` **304**(1회차와 같음 · 뷰 파일 34 · 시험 적용 실측과 같음) · 정적 37줄 출력 = 1회차와 같은 글자(EXIT·warning 말고 · S29 13·3 · S30 8·1 · S05 = `:68` · `:92`·`:109`·`:179`·`:285`·`:329` · 시험 적용 실측과 같음 — `a816264` 출력과 글자 차이 0).
- 채팅: PR 본문 5섹션 새 판 — ① 머리 2줄 + name-status 26줄 + 커밋 목록 8줄 · ② 복사 상자 12항 15줄 + 괄호(1회차 글자) + 정적 37줄 출력 + S05 6줄(복사 상자 · 백틱·앞머리 없음) + ⓡ·ⓗ(S29·S30 출력 줄 그대로) · ③ 복사 상자(«빈» 에 `s79-deviation`(있을 때)) · ④ 복사 상자(요지 = 질문 파일 글자) · ⑤ «없음» · 까닭 두 줄 · flutter test 끝 줄.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R11b-Bob-S79 재제출: PR #21 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다(Claude 가 PR #21 본문을 이 새 판으로 통째로 바꿉니다). 0단계·«먼저 할 것»에서 멈췄다면 `R11b-Bob-S79 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR #21 «Files changed» — `a816264` 뒤 커밋만 보면 된다): ① `packages/ui_analytics/lib/` 의 변경 ② PNG 변경(`s79_*`·`s71_*` 포함 — 이번에는 한 장도 바뀌면 안 된다) ③ `goal_path_fakes.dart`·`s79_golden_test.dart`·`monthly_report_view_test.dart`·`labels.dart`·`pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README·질문 파일 변경 ④ `Merge … origin/main` 커밋 · 지난 7개 커밋의 해시가 바뀜(강제 푸시·rebase 흔적) ⑤ T79-02 에 아직 `// stale shows banner` 빈 블록 · else 없는 `if (activeFlags.isEmpty)`·`if (vm.deviationText == null)` · `s79-segment-caption-0` 0 단언 없음 ⑥ PR 본문 S05 줄에 백틱·`packages/ui_analytics/` · ③ «빈» 에 `s79-deviation` 없음 · ④ 요지에 «측정:» 없음 — 하나라도 있으면 반려 신호(⑥ 은 바뀐 규칙에 따라 «표기만» 이면 C4 정정 대상).
- CI: 이 PR 은 1회차부터 `golden:approved` 라벨이 붙어 있고(허용 목록 `s71_*` 6장) 재제출은 PNG 0 이라 «골든 스냅샷» 은 그대로 **APPROVED · 초록**이 정상입니다(라벨은 그대로 둔다 · 떼지 않는다). «분석 · 테스트(melos)» 는 Bob 의 푸시(새 `pull_request` synchronize)로 새 `main`(기록 커밋 포함) 위의 병합 미리보기를 다시 돌린다 — 기록 커밋은 문서뿐이라 수는 1회차 CI 와 같은 것이 기대.
- C4 가 2회차에서 볼 것: lib diff 0 · PNG diff 0 · `git diff --name-status a816264 HEAD` 한 줄 · 지난 7개 커밋 해시 불변 · T79-02 의 네 갈래가 세 경우에서 양쪽을 한 번 이상씩 지나는지(F1 표) · else 없는 if·빈 if 블록 0(합격 모양 = 카드 F1 ① 이 정한 «있는 쪽 = chain.add/addAll(뒤의 사슬 루프가 findsOneWidget 으로 단언) · 없는 쪽 = else findsNothing» — if 블록 안에 expect 가 직접 없다는 것만으로 규칙 11 위반으로 보지 않는다) · `hasLength(` 수 불변(S30 8) · 예고 변이 27건 재실행(1회차 27/27 — 반려 판정 대상은 1회차 카드의 예고 변이뿐 · 1회차 통과 8건(C4 보고 §5 · 카드 공백·계약상 동치·정적이 잡음)은 참고) · ② 12항(15줄) 글자 diff · 정적 37줄 글자 대조 · S05 6줄 정규식 · ③ «빈» = 코드 81~86·165~171행 · ④ = 질문 파일 글자 · 까닭 두 줄 = 이 패킷 글자 · 골든 dy 8개(1회차와 같아야 함 — lib·PNG 불변이라 재실측은 선택) · 질문 파일 불변. 판정에는 **바뀐 규칙**(표기만 = C4 정정 · 코드·테스트·거짓 = 반려)을 쓴다.
- 병합 뒤 할 일(Claude · C4 보고 §7·§8-1): §7-1 질문 A1~A4 답 칸을 «1회차 PR #21 `a816264` 측정값 — 재제출 `<RESUB>` 은 lib·골든 테스트·PNG 0 이라 같다(C4 1·2회차 재실측 일치 · light=dark).» 모양으로(R11a 선례) · 머리말 «다음 번호 = Q1·A5» · §7-2 S7-1 A13 닫기 · §8-1 의 «Bob `a816264`» → «Bob `<RESUB>`(1회차 `a816264` + 재제출 커밋 1)» · 패킷 이동은 재제출 패킷 `send/R11b-Bob-S79-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · 팩 판은 그다음 접미 · 2회차 보고 보존본 `10_리뷰/2026-10-01_R11b_C4_2회차_보고.md`(같은 날이면).
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R11b 패킷은 이 파일 하나입니다. 원 패킷 `R11b-Bob-S79.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 합니다). `_완료/R11a-Bob-S74-재제출.md` · `_완료/R10c-Bob-S72-재제출.md` · `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드입니다.
- 범위 밖(발주자 결정 2026-10-01): C4b-12(배너 «스크롤 밖» 단언 · X11)는 다음 카드(R12 테스트 공통 줄) · C4b-13·C4b-14 도 다음 카드 · R12 의 `S7-8`(M5 컴포넌트 임베드 대상)은 나중에 정한다 — 이 재제출에 넣지 않는다.
