# 발송 패킷 R12d-Bob-S710 — 재제출 (1회차 반려 · 2026-10-15)

> ⬜ **「푸시해」 뒤 보냄** — 이 파일이 GitHub `main` 의 `send/` 에 있으면 이 조건은 풀린 것(이 패킷과 원 패킷의 `send/_완료/` 이동이 `main` 에 올라간 뒤 · 다른 선행 없음 — PR #29 반려 댓글 게시됨(2026-10-15 · issuecomment-6181856097) · 아래 «보내는 조건» · `send/README.md` 배지 규칙).
> 만든 날 2026-10-15 · 1회차(PR #29 · 브랜치 `ui/m7-s710-gap` · 커밋 `20edbbd` · 밑동 `a789447` · 커밋 5 · CI 3/3 run 38656481547)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-15): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #29 · Bob 이 R1·R2 를 **test 1파일 커밋 1개**로 · lib 0 · PNG 0 · 지난 5커밋 그대로 · amend·rebase·force 금지) ② **재제출 범위 = R1·R2 + 보고 글 ①~⑤ 전체판**(12 §3 재제출 조문(2026-10-14 개정) «전체판 + 바뀔 자리만 상자» — **이 재제출이 그 조문의 첫 적용**) ③ C12d-3(골든 표 «글자 N줄» 셈 단위)은 ① 표기로 기록(반려 사유 아님 — 아래 보고 글 조각 14 상자로 고친다) ④ 다음 카드 보강 C4d-1·C4d-5 는 설계 12 §3 «R12d C4 이월 부록» 에 적었다(이 패킷 몫 아님). 규칙·범위(S7-10 안내 이행 리포트)는 1회차 카드(`send/_완료/R12d-Bob-S710.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 R1·R2 + 보고 글 ①~⑤ 전체판(바뀔 자리만 상자 · 바뀌지 않는 자리도 1회차 글자 그대로 복사 상자)** 을 담았습니다.
> 고치는 것 = **테스트 파일 하나**(`packages/ui_analytics/test/execution_gap_view_test.dart` — 아래 R1·R2 의 «이 줄을 → 이 줄로» 그대로 · +31/−34) **+ 채팅 글 ①~⑤ 전체판** — `lib/**` 0 · PNG 0 · 골든 테스트·가짜·질문 파일 `inbox/S7-10_questions.md` 0(A1~A6 행·머리말 그대로 · 답은 병합 때 통합 담당) · PR 본문·라벨 0(통합 담당이 PR 본문을 이 글로 통째로 바꾼다). 같은 브랜치 `ui/m7-s710-gap` · 같은 PR #29(새 PR·새 브랜치 금지) · 커밋은 맨 위에 1개 · amend·rebase·cherry-pick·reset·강제 푸시 금지.
> 판정 근거 = C4 보고 §0 · §4(설계 저장소 `10_리뷰/2026-10-15_R12d_C4_보고.md`) — 1회차 카드 보고 규칙 strict 나눔 ② «코드·테스트 결함(예 규칙 11 «else 없는 if») = 반려(재량 없음)»(카드 210행). [가] 2건(둘 다 T710-15): **C12d-1** Text 루프가 **else 없는 if** 안에서만 단언(`20edbbd` 723행 · 카드 147~148·178·274·417·496·210행 · 실효 = 빈 글자·`Text.rich` 글자를 뷰 54 가 못 봄 — 골든만 잡음 · else 없는 if 세 번째(R11b C4b-5 · R12b C12b-1)) · **C12d-2** 허용 글자 집합이 collection-if 3(695·703·708행 · 카드 153·499행 «null-aware 원소 — if 0» · 실효 0). [나] 2건(C12d-3 골든 표 «글자 N줄» 의 N = Text 위젯 수·문장 수·플래그 수 ≠ PNG 에 보이는 행 수 · C12d-4 masked «차단 배너 상자» = PNG 는 폭 전체 배경 → 둘 다 조각 14 상자) · 거짓 주장 0 · 예고 변이 29항목 31꼴 전부 뷰가 잡음. 합격(그대로): lib · 새 PNG 12 · 질문 파일 · `flutter test` 448 → 514 · 정적 37줄 출력 · C-42 ① 11줄 · N1·N3 · CI 3/3.
> 🔴 **재제출 조문(12 §3 · 2026-10-14 개정) = 전체판 + 바뀔 자리만 상자** — Bob 은 보고 글 ①~⑤ 를 **처음부터 끝까지 다시** 낸다. 다만 글자는 이 패킷 «■ 보고 글» 의 조각 1~18 뿐이다 — [상자] 조각은 복사 상자 글자 그대로(바뀌지 않는 자리 = 1회차 Bob 글자 그대로 옮긴 상자 · 바뀌는 자리 = C4 가 준 상자), [출력] 조각은 다시 돌린 명령 출력을 파일로 떠서 그대로. 상자·출력 밖의 글은 0(머리말·요약·까닭 줄·설명 금지).
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기를 돌린다(R11a·R11b·R12b·R12c 재제출 선례). Bob 의 푸시가 CI 를 다시 돌린다(PNG 변경 0 이라 «골든 스냅샷» 은 라벨 없이 초록이 정상).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R12d-Bob-S710.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R12d 행·재제출 행 · `rounds.md` R12d 행·재제출 행과 **같은 푸시**로 `main` 에 올린다(0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/S7-10_questions.md` · golden README · `packages/ui_analytics/README.md` · 01~05 사본은 건드리지 않는다(병합 때).
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R12d-Bob-S710.md` 는 `send/` 에 없음). 확인 = `git cat-file -t origin/main:docs/ai-context/send/R12d-Bob-S710-재제출.md`(= `blob`) · PR #29 «Conversation» 에 C4 반려 댓글(«C4 병합 검사 판정 — 🔴 반려(재제출) · R12d-Bob-S710 1회차»)이 있다(게시됨) · 그 밖의 선행(infra PR 등)은 없다.
> C4 수정안 시험(2026-10-15 · 통합 담당 worktree `C:/Work/AAQ-claude-c4dj` @ `20edbbd` · 끝에 삭제): 아래 R1·R2 와 같은 글자(+31/−34)를 넣고 `dart format --output=none --set-exit-if-changed .` «74 files (0 changed)» · `flutter analyze --fatal-infos` No issues found! · 뷰 `00:02 +54: All tests passed!` · 골든 `00:01 +12: All tests passed!` · `flutter test`(ui_analytics 전체) `00:22 +514: All tests passed!` · S31 15 · S32 8 · S02c 18 · 그 위에서 1회차 판이 놓친 꼴(빈 글자 Text · `Text.rich` 정적 글자)이 T710-15 로 잡힘. 안 돌린 것 = `melos.bat run test`(중첩 melos · CI 몫). 조립 확인(2026-10-15): 아래 R1·R2 상자를 `20edbbd` 판에 상자대로 적용한 결과 = C4 수정안 파일과 바이트 같음 · 조각 14 상자에 1회차 카드 N3 의 셋째·넷째·다섯째 정규식 = 12 · 12 · 0.

## 0. 한 줄 목적

PR #29 의 테스트 파일 하나를 R1·R2 글자대로 고쳐 커밋 1개로 올리고, 보고 글 ①~⑤ 를 **전체판**(바뀔 자리만 새 상자 · 나머지는 1회차 글자 상자)으로 다시 내기 — **lib·PNG·골든 테스트·가짜·질문 파일은 한 글자도 바꾸지 않고, 지난 5개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s710-gap` · 같은 PR #29.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). PR #29 의 C4 반려 댓글은 이미 올라가 있습니다.
2. Bob 은 **1회차와 같은 대화여도 됩니다**(Bob 폴더가 지금 `ui/m7-s710-gap` `20edbbd` 입니다 · 1회차 카드의 «(5) 뒤에 다른 커밋을 더하지 않는다» 는 이 카드가 덮습니다 — 아래 본문 0단계). 새 대화로 시작해도 됩니다 — 본문은 Bob 이 1회차를 기억하지 못한다는 전제로 썼고, 1회차 글자는 이 패킷의 복사 상자에 다 들어 있어 1회차 글을 따로 붙여 줄 필요가 없습니다.
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12d-Bob-S710-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R12d-Bob-S710-재제출.md` · 가지 `rec/r12-cards` · 2026-10-15 Claude 확인 · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R12d-Bob-S710.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ```text 다음 줄(«R12d-Bob-S710 재제출 요청»)부터 닫는 ``` 직전 줄까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12d 패킷은 **이것 하나**(`R12d-Bob-S710-재제출.md`)입니다. 원 패킷 `R12d-Bob-S710.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R12c-Bob-S77-재제출.md` · `_완료/R12b-Bob-S76c-재제출.md` · `_완료/R12a-Bob-S76ab-재제출.md` · `_완료/R12a-Bob-S76ab-재제출2.md` · `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` 는 끝난 카드입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12d-Bob-S710 재제출 요청»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12d-Bob-S710 재제출 요청 — 1회차(PR #29 · 20edbbd) 판정: 반려(재제출). 같은 브랜치 ui/m7-s710-gap · 같은 PR #29 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 테스트 파일 하나(packages/ui_analytics/test/execution_gap_view_test.dart — 아래 R1·R2 글자 그대로)와 채팅 보고 글 ①~⑤ 전체판(아래 «■ 보고 글» 의 조각 1~18 그대로)뿐입니다.
🔴 lib 0 · PNG 0 · 골든 테스트·가짜·질문 파일 0 · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12d 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner · ui/m7-s79-goal-path · ui/m7-s76ab-rebalance · ui/m7-s76c-preview · ui/m7-s77-annual)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #29 · 브랜치 ui/m7-s710-gap(커밋 20edbbd)에 아래 R1·R2 커밋 하나를 «더하는» 일입니다. R1·R2 는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돌기 때문에, main 에 들어간 기록 커밋은 병합하지 않아도 CI 에 들어갑니다.
🔴 1회차 카드의 «(5) 뒤에 다른 커밋을 더하지 않는다(… amend·rebase 금지)» 는 이번에 이 카드가 덮습니다 — 재제출 커밋 1개를 맨 위에 더하는 것이 이번 일입니다.
   지난 5개 커밋(20edbbd · a0ebd73 · fc62344 · 6e663ba · d01d0b8 — 순서·제목 포함)은 그대로 둡니다(고치려 하면 반려).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m7-s710-gap 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m7-s710-gap
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git rev-parse --short HEAD    ← 20edbbd 이면 정상 · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m7-s710-gap   ← 20edbbd · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R12d-Bob-S710-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R12d-Bob-S710.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R12d-Bob-S710-» 로 시작하는 줄이 있으면 정상.
        «R12d-Bob-S710-재제출» 줄이 없거나 꼬리 없는 «R12d-Bob-S710.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 카드가 먼저 왔습니다.
  ls docs/ai-context/send/R12d-Bob-S710.md   ← 보여야 함(이 브랜치에는 1회차 카드가 있다 — 아래 «규칙 요약» 이 가리키는 파일 · 읽기만)
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
🔴 이 카드와 1회차 카드(R12d-Bob-S710.md)의 글이 다르면 이 카드가 이깁니다 — 예: 커밋은 재제출 커밋 1개만 맨 위에 · 질문 파일을 고치지 않는다 · 골든을 다시 찍지도 dy 를 다시 재지도 않는다 ·
   채팅 글은 이 카드 «■ 보고 글» 의 조각 1~18 그대로(전체판) · 테스트 수 기대 = 뷰 +54 · 골든 +12 · 전체 +514(1회차와 같은 수) · main 을 병합하지 않는다.
   PR #29 반려 댓글의 «보고 글 = ①~⑤ 전체판(바뀌는 자리 = 상자 글자 그대로 · 골든 표 12행 포함)» 과 이 카드의 조각 1~18 은 같은 범위다 — 글자·차례는 이 카드 «■ 보고 글» 상자가 정한다.

■ 규칙 요약 (1회차 카드 = 이 브랜치의 docs/ai-context/send/R12d-Bob-S710.md(main 에서는 send/_완료/ 로 옮겨졌다 — 글자는 같다)의 규칙 11(147~178행) · 보고 규칙(208~222행) · 테스트 최소 목록(416~520행 · 예고 변이 514~520행 포함) · 정적 묶음(521~579행) · 골든(581~605행) · ■ 제출(621~750행)이 유효 —
   단 이 카드와 다른 곳은 이 카드가 이긴다 · 여기엔 핵심만)
· 이번에 고치는 곳 = 아래 한 파일뿐입니다.
    packages/ui_analytics/test/execution_gap_view_test.dart   (R1·R2 — T710-15 본문만 · 새 testWidgets 줄을 더하지 않는다 · 경우 목록도 그대로)
· 🔴 고치면 반려: 위 한 파일 밖의 전부 — packages/ui_analytics/lib/**(execution_gap_screen.dart · labels.dart · analytics_providers.dart · ui_analytics.dart 포함 · 🔴 lib 0) ·
  test/golden/goldens/*.png 전부(s710_* 12장 포함 · 🔴 PNG 0 · --update-goldens 를 돌리지 않는다) · test/golden/s710_golden_test.dart · test/execution_gap_fakes.dart ·
  그 밖의 기존 테스트 전부 · test/golden/ 의 하네스·README · test/flutter_test_config.dart · domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml ·
  docs/ai-context/**(질문 파일 inbox/S7-10_questions.md 포함).
  🔴 PNG 나 lib 가 하나라도 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 테스트 규칙(1회차 카드 규칙 11 — 이번에 걸린 곳만 글자 그대로):
   «전제는 expect(조용한 return·if 건너뛰기 금지)»(148행) · «🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기 · 빈 if 블록)와 firstWhere 다»(178행).
   «목록·집합을 «있으면 넣는다»로 만들 때(… 예 T710-15 의 허용 글자 집합)는 null-aware 원소(?report?.modeAdviceLine · ...?report?.countLines)로 만든다 — else 없는 if 0(SDK ^3.13)»(153행).
   T710-15(496~501행) «화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있다 … 🔴 집합은 null-aware 원소(?x · ...?xs)로 만든다 — if 0 · 규칙 11».
   ⓡ = expect(find.text(AnalyticsLabels.retryButton), findsNothing); 줄 · ⓗ = hasLength( 줄 · 정적 S31·S32 가 정확히 15 · 8 이어야 한다(R1·R2 는 ⓡ·ⓗ 줄을 더하지도 빼지도 않는다 —
   🔴 R1 의 «비어 있지 않음» 전제는 hasLength 가 아니라 isNotEmpty 다 · 카드 176~177행 «T710-15 의 Text 루프 … 에는 hasLength( 를 쓰지 않는다» 그대로).
  (그 밖 — 테스트 이름 그대로 · 테스트에 한국어 리터럴 금지 · 주석에도 한국어를 새로 쓰지 않는다(정적 S01) · 새 띄우기 도우미·새 가짜 금지 · if 를 새로 쓰지 않는다.)
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인.
· 보고 규칙(1회차 카드 208~211행 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당(C4)이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음) · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 섹션 머리 ①~⑤ 는 «■ 보고 글» 상자 글자 그대로).
  🔴 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 «모든 확인 완료 …» 같은 섹션 밖 글이나 --- 를 두지 않는다(1회차 카드 663행 N1 그대로).
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 카드가 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.
   🔴 git log · git diff · flutter test · dart test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
      <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다 — 새 화면 1(«화면» 배치 · 배너 둘은 스크롤 밖 · 로딩·에러에 배너 없음 · 게이지 트리 · 칩 색 4갈래 전수 switch · Card 기본 고도 · 주석 0) ·
  공용 3파일 더하기만(S27 3 0 / 16 0 / 1 0) · providers R12d 절 = 카드 글자 그대로 · 배럴 정렬 자리 1줄 · 라벨 1 · Key 7 = Key 표 · lib/src/execution_gap/ 없음 · 읽지 않는 필드 0.
테스트는 T710-15 밖이 모두 맞았습니다 — 뷰 18 testWidgets(경우 54) · 골든 1 testWidgets(12) · ⓡ 15 · ⓗ 8 자리 · T710-15 밖의 if 15개는 모두 else 짝 · C4b-12·13·14 반영 · T710-16 13 · T710-17 9 · 한국어 리터럴 0 · ASCII 이름.
flutter test 448 → 514 · analyze --fatal-infos No issues · format 0 changed · C-42 ① 11줄(«S7-10(R12d) 1파일» · 합 5파일 · 61줄) · 새 PNG 12장(390×844) · 기존 96장 그대로 · dy 12값 = C4 재실측 · CI 3/3.
보고에서 맞은 곳 — 거짓 주장 0 · 정적 37줄 출력이 C4 재실행과 글자가 같았습니다(warning: 줄만 차이 = 대조 밖) · ① 20줄·5커밋 · ② 12항 15줄·괄호·세는 줄 · S05 2줄 · ⓡⓗ · C-42 11줄 · ③ 4줄 · ④ 6행 · ⑤ «없음» · 🆕 N1(첫 줄)·N3(자기 확인) 지켜짐.
카드가 예고한 변이 29항목(31꼴)은 모두 뷰 테스트가 잡았습니다.

■ 왜 반려인가 — 카드 / 실제 (C4 검사 갈래가 따로 냈고 통합 담당이 코드·재현·수정안 시험으로 직접 다시 확인)
① T710-15 Text 루프가 else 없는 if 안에서만 단언 (C12d-1 · 테스트 결함 · strict 나눔 ②)
   카드:  규칙 11(147~148행) «전제는 expect(조용한 return·if 건너뛰기 금지)» · 178행 «🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기 · 빈 if 블록)» ·
          본받지 않는 것(274행) «if (x != null) { expect… }» 조건부 단언 · 최소 목록 머리(417행) «else 없는 if = 반려(R12b 1회차 C12b-1 · R11b C4b-5 — 같은 꼴 두 번)» ·
          T710-15(496행) «화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있다» · 보고 규칙(210행) «② 코드·테스트 결함(예 규칙 11 «else 없는 if») = 반려(재량 없음)».
   실제:  execution_gap_view_test.dart(20edbbd) 721~740행이 for (final Text text in tester.widgetList<Text>(find.byType(Text))) { final String? data = text.data; if (data != null && data.isNotEmpty) { expect ×3 } } 이다 —
          723행 if 에 else 가 없다. 화면에 Text 가 하나라도 있다는 양성 기준점(expect(…, isNotEmpty))도 없다.
   놓친 것: data 가 null 인 Text(Text.rich 로 그린 글자)와 data 가 '' 인 Text 는 세 단언(허용 집합 · 금액 정규식 · 금지어 정규식)을 모두 조용히 건너뛴다.
          그래서 화면이 지은 정적 글자를 Text.rich 로 그리거나 Key 없는 빈 Text 를 더해도 뷰 54 가 모두 통과한다(골든만 잡는다 · 통합 담당 재현). 화면이 Text 를 하나도 그리지 않아도 이 테스트는 통과한다.
          else 없는 if 는 R11b(C4b-5) · R12b(C12b-1)에 이어 세 번째다(카드가 417행에 그 선례를 적어 두었다).
② T710-15 허용 글자 집합이 collection-if 3개 (C12d-2 · 테스트 결함 · strict 나눔 ②)
   카드:  규칙 11(153행) «목록·집합을 «있으면 넣는다»로 만들 때(… 예 T710-15 의 허용 글자 집합)는 null-aware 원소(?report?.modeAdviceLine · ...?report?.countLines)로 만든다 — else 없는 if 0(SDK ^3.13)» ·
          T710-15(499행) «🔴 집합은 null-aware 원소(?x · ...?xs)로 만든다 — if 0 · 규칙 11» · 210행.
   실제:  693~712행 집합이 695행 if (report != null) ...<String>[ … ] else ...<String>[result.emptyLabel!](709행까지) · 703행 if (report.modeAdviceLine != null) report.modeAdviceLine! ·
          708행 if (report.trust.upgradeHint != null) report.trust.upgradeHint! 로 지어졌다(703·708 은 else 없음).
          실효 손실은 0 이다(집합 원소는 카드 드라이런과 같다). 그래도 카드가 «if 0» 을 글자로 못박은 자리이고, 같은 테스트의 이웃 줄이라 한 커밋에 함께 고친다.
함께 고칠 것: 표기 C12d-3·C12d-4(③ 골든 표 «배치·잘림» 칸 — «글자 N줄» 의 N 을 Text 위젯 수·문장 수·플래그 수로 셌다 ↔ PNG 에 보이는 행 수(줄바꿈된 행도 센다) · masked_recon 맨 위 «차단 배너 상자» ↔ PNG 는 모서리 없는 화면 폭 전체 배경 · «안내 문장» = PNG 에서 읽을 수 없는 뜻 낱말)
  = 아래 «■ 보고 글» 조각 14 상자(통합 담당이 PNG 를 열어 맞춘 12행). 반려 사유는 아니다(덩어리 순서·개수·잘림 없음은 PNG 와 같았다).
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 생성물은 git 에 없습니다(브랜치를 바꿨거나 새로 받았으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류 · 생성물은 git 이 무시하므로 git status 는 빈 채).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test test/execution_gap_view_test.dart   ← 시작 기준: 끝 줄 «+54: All tests passed!»(1회차 그대로)
  flutter test   ← 시작 기준: 끝 줄 «+514: All tests passed!» · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·푸시 -u 는 하지 않습니다):
   · docs/ai-context/send/R12d-Bob-S710.md(1회차 카드 — 이 브랜치에 있다) — 147~178행 규칙 11 · 208~222행 보고 규칙 · 496~501행 T710-15 · 512~513행 ⓡⓗ 기대 · 521~579행 정적 묶음 · 621~750행 ■ 제출
   · packages/ui_analytics/test/execution_gap_view_test.dart 의 아래 R1·R2 자리(20edbbd 행 번호 · 고치기 전에 «이 줄을» 상자와 한 글자씩 대조)

■ 고칠 것 — R1·R2 (1회차 반려 · C4 2026-10-15) — 파일 하나 · 아래 상자의 «이 줄을 → 이 줄로» 그대로 · 손으로 다시 짜지 않는다
   🔴 행 번호는 20edbbd 의 것이다. 아래 차례(파일 **아래쪽부터** 위로 — ⑴ R1 → ⑵ R2)로 고치면 앞의 수정이 뒤 자리의 행 번호를 밀지 않는다.
   🔴 «이 줄을» 상자와 파일의 그 행이 한 글자라도 다르면(들여쓰기 포함) 고쳐 쓰지 말고 멈춘 뒤 채팅으로 — 파일이 20edbbd 가 아니다.
   🔴 상자 안의 들여쓰기(빈칸 수)를 그대로 옮긴다 · 탭 문자 0 · 상자 밖의 줄은 한 글자도 바꾸지 않는다(빈 줄 포함 — 720행 빈 줄 · 740행 «      }» · 694행 result.asOf.label, · 710~711행 두 정적 라벨 · 713행 빈 줄 · 714~719행 정규식 두 개는 그대로 둔다) · lib 0 · PNG 0.

⑴ R1 (C12d-1 · T710-15 Text 루프 · 721~739행) — 화면의 Text data 를 목록으로 먼저 받고, 비어 있지 않음을 단언한 뒤, 모든 data(null · '' 포함)를 if 없이 단언한다
      ┌── 이 줄을(721~739행 · 19줄)
      for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
        final String? data = text.data;
        if (data != null && data.isNotEmpty) {
          expect(
            allowed.contains(data),
            isTrue,
            reason: 'Text must be in allowed set',
          );
          expect(
            moneyRegex.hasMatch(data),
            isFalse,
            reason: 'Text must not match money regex',
          );
          expect(
            forbiddenRegex.hasMatch(data),
            isFalse,
            reason: 'Text must not match forbidden regex',
          );
        }
      └──
      ┌── 이 줄로(17줄)
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed), reason: 'Text must be in allowed set');
        expect(
          data,
          isNot(matches(moneyRegex)),
          reason: 'Text must not match money regex',
        );
        expect(
          data,
          isNot(matches(forbiddenRegex)),
          reason: 'Text must not match forbidden regex',
        );
      └──
   (740행 «      }» 는 글자 그대로 둔다 — 이제 새 for 를 닫는다 · null·'' 도 isIn(allowed) 에서 실패한다 · matches 는 글자가 아닌 값에 거짓이라 isNot(matches(…)) 는 null 에도 안전하다 ·
    expect(shown, isNotEmpty) 는 양성 기준점이다 · hasLength( 를 쓰지 않아 S32 는 8 그대로 · if 0 · 줄 나눔은 dart format 결과 그대로다.)

⑵ R2 (C12d-2 · T710-15 허용 글자 집합 · 695~709행) — collection-if 3개를 null-aware 원소로
      ┌── 이 줄을(695~709행 · 15줄)
        if (report != null) ...<String>[
          report.periodLabel,
          report.complianceRateLabel,
          ...report.countLines,
          report.medianDelayLabel,
          report.priceGapLabel,
          ...report.correctionLines,
          report.amendChainMaxLabel,
          if (report.modeAdviceLine != null) report.modeAdviceLine!,
          for (final ReasonChip c in report.skipReasonBuckets) c.label,
          for (final ReasonChip c in report.selectiveExecutionChips) c.label,
          report.trust.label,
          report.trust.consequenceLine,
          if (report.trust.upgradeHint != null) report.trust.upgradeHint!,
        ] else ...<String>[result.emptyLabel!],
      └──
      ┌── 이 줄로(14줄)
        ?report?.periodLabel,
        ?report?.complianceRateLabel,
        ...?report?.countLines,
        ?report?.medianDelayLabel,
        ?report?.priceGapLabel,
        ...?report?.correctionLines,
        ?report?.amendChainMaxLabel,
        ?report?.modeAdviceLine,
        ...?report?.skipReasonBuckets.map((ReasonChip c) => c.label),
        ...?report?.selectiveExecutionChips.map((ReasonChip c) => c.label),
        ?report?.trust.label,
        ?report?.trust.consequenceLine,
        ?report?.trust.upgradeHint,
        ?result.emptyLabel,
      └──
   (694행 result.asOf.label, 과 710~711행 두 정적 라벨(AnalyticsLabels.executionGapSkipReasonsHeader · AnalyticsLabels.actionViewButton)은 그대로 둔다 ·
    ?x 는 x 가 null 이면 넣지 않고 ...?xs 는 xs 가 null 이면 펼치지 않는다 — report 가 null 이면 리포트 원소 0 · emptyLabel 이 null 이면 빈 문장 원소 0 · 집합 원소는 원판·드라이런과 같다.)

고친 뒤 확인(packages/ui_analytics 에서 · 커밋하기 전 · 고치지 않고 보기만):
  git diff --stat                     ← 마지막 줄이 « 1 file changed, 31 insertions(+), 34 deletions(-)»(위에 파일 줄 하나가 더 있는 것이 정상 · 다르면 상자와 다시 대조 · 커밋하지 않는다)
  dart format --output=none --set-exit-if-changed test/execution_gap_view_test.dart   ← «Formatted 1 file (0 changed)» 꼴 · 바뀐 줄이 있으면 상자와 다르게 옮긴 것 — 다시 대조
  git grep -c 'hasLength(' -- test/execution_gap_view_test.dart                                   ← «test/execution_gap_view_test.dart:8»(20edbbd 와 같은 수 · ⓗ)
  git grep -c 'retryButton), findsNothing' -- test/execution_gap_view_test.dart                   ← «test/execution_gap_view_test.dart:15»(20edbbd 와 같은 수 · ⓡ)
  git grep -c -F "expect(data, isIn(allowed), reason: 'Text must be in allowed set');" -- test/execution_gap_view_test.dart   ← «test/execution_gap_view_test.dart:1»(R1 · 20edbbd 에서는 출력 없음)
  git grep -c -F '?report?.modeAdviceLine,' -- test/execution_gap_view_test.dart                  ← «test/execution_gap_view_test.dart:1»(R2 · 20edbbd 에서는 출력 없음)
  git grep -c -E '^ +if \(.*[^{]$' -- test/execution_gap_view_test.dart                          ← 출력 없음(collection-if 0 · 20edbbd 에서는 :3)
  git grep -c -E 'if \(data != null' -- test/execution_gap_view_test.dart                         ← 출력 없음(else 없는 if 의 조건 0 · 20edbbd 에서는 :1)
  (위 여덟 줄 다 자기 점검이다 · 따옴표 그대로(Git Bash·PowerShell 둘 다 그대로 돈다) · 다르면 커밋하지 말고 멈춘 뒤 출력을 채팅으로 · 이 출력은 채팅 글에 붙이지 않는다)

커밋 — 하나 · 맨 위에(R1·R2 전부 · format:fix 가 바꾼 줄이 있으면 그것도 같은 커밋 — 기대는 0 줄):
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M7] R12d (6) 재제출 — T710-15 Text 전부 단언 · 허용 집합 null-aware
      └── 커밋 제목 복사 끝(이 줄 앞까지)
   🔴 지난 커밋(20edbbd · a0ebd73 · fc62344 · 6e663ba · d01d0b8)을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.

■ 고치지 않는 것 (1회차가 맞았거나 이 카드 밖 — 손대면 반려)
 · lib/** 전부 · PNG 전부(s710_* 12장 포함 — --update-goldens 금지) · s710_golden_test.dart · execution_gap_fakes.dart · labels.dart · 그 밖의 테스트 파일
 · 골든 dy — lib·골든 테스트·PNG 가 그대로라 다시 재지 않습니다(질문 파일 A1~A6 = 1회차 실측 = C4 재실측 · s710_golden_test.dart 를 열어 lessThan(0) 으로 바꾸는 일도 하지 않는다)
 · 질문 파일 docs/ai-context/inbox/S7-10_questions.md — A1~A6 행·머리말(«다음 번호» 포함)을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 닫는다)
 · R1·R2 상자 밖의 테스트 본문 전부(T710-01~14 · 16~18 · T710-15 의 경우 목록·띄우기·두 정규식·ⓡ 줄)
 · ⓡ·ⓗ 줄 — 더하지도 빼지도 않는다(S31 15 · S32 8) · 테스트 이름 · 경우 목록
 · 지난 5개 커밋 · 보강 후보(C4 보고 §7 C4d-1~6 — 다음 카드 몫)는 이번에 넣지 않는다(넣으면 범위 밖 변경)

■ 질문 파일
· 이번 R1·R2 는 전부 이 패킷이 정했고 lib·PNG 가 그대로라 잴 것도 없으므로, 질문 파일은 바뀌지 않는 것이 정상입니다(새 행 0).
· 🔴 새 행이 필요해 보이면(측정·추측·질문 어느 것이든) 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 — 이번 커밋은 테스트 파일 하나만 add 하고, 아래 «git diff --name-status 20edbbd HEAD» 는 테스트 한 줄이어야 합니다.

(읽는 법 — 아래 «■ 정적 묶음» 절은 1회차 카드 521~579행 글자 그대로다. 이 재제출에서는 «PR 본문 ②» = 채팅 글 조각 8 · ««■ 제출» 의 flutter test 세 줄» = 이 카드의 «■ 테스트 수 묶음» ·
  S27 의 origin/main...HEAD 는 점 세 개라 기록 커밋이 main 에 더해져도 1회차와 같은 밑동(a789447)에서 잰다 ·
  대조에서 빼는 것 = 빈 줄 · EXIT 표기 · warning:·error: 줄 · PowerShell 장식 줄 · 줄 머리 경과 시각 · 한국어가 깨져 보이면 [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 돌린다.)
■ 정적 묶음 — packages/ui_analytics 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 37줄을 돌려 글자로 대조한다 — 다르면 거짓 주장 = 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로(줄 수가 많아도 · «길어서 줄였습니다» 같은 주의 문장으로 갈음하지 않는다 · R12a C12a-2).
  🔴 **테스트 이름·패키지 이름 한 낱말이라도 다르면 반려 — 대조에서 빼는 것은 빈 줄·EXIT 표기·warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐**(R12a 2회차 C12a2-1 — 다시 돌린 출력을 채팅 글로 옮기다 테스트 제목의 패키지 이름 한 낱말이 바뀌어 반려).
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(«■ 제출» 의 flutter test 세 줄 · C-42 dart test · Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 → <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 2>&1 로 모으면 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힐 수 있다 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/execution_gap_view_test.dart test/execution_gap_fakes.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/execution_gap_view_test.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/execution_gap_view_test.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S02c testWidgets lines"; git grep -c "testWidgets(" -- test/execution_gap_view_test.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (S7-10 file)"; git grep -nP "(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes 0 (S7-10 file)"; git grep -n "AppRoutes" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 number formatting 0"; git grep -nE "toStringAsFixed|toStringAsPrecision|NumberFormat" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 S7-10 forbidden windows and types 0"; git grep -nE "watchGrade|watchRolling|LedgerTrustRepository|Decimal|Money|KrwAmount|operatingMode|OperatingMode|RunMode|runMode|FeatureFlags" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S15 autoDispose 9"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "execution_gap/|annual_review/|rebalance/|goal_path/|chart/|explore/|widgets/|planner|perf_chart" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports 13"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint" -- lib; echo "EXIT:$?"
echo "## S25 raw fields 0 (S7-10 file)"; git grep -nP "(?<!Labels)\.(issued|filled|partial|skipped|lapsed|revoked|lateFilled|backdatedCount|selfReportCorrectionCount|range|grade|level|lastVerifiedOn|actionDeepLink|detailDeepLink|emptyKind|code|kind|mode|wire|hasMore)\b" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea SnackBar 0 (S7-10 file)"; git grep -nE "Scaffold|AppBar|SafeArea|SnackBar" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 decimal and percent literals 0 (S7-10 file)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S29 elevation 0 (S7-10 file)"; git grep -n "elevation" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S30 sort filter words 0 (S7-10 file)"; git grep -nP "(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|\breverse:\s*true" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S31 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/execution_gap_view_test.dart; echo "EXIT:$?"
echo "## S32 H lines (hasLength)"; git grep -c "hasLength(" -- test/execution_gap_view_test.dart; echo "EXIT:$?"
echo "## S33 s710 keys (7 names)"; git grep -noP "s710-[a-z]+" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름·문자열 리터럴은 ASCII 만(«—»·«→» 도 금지 · S02b 는 접힌 줄의 reason: 글자도 잡는다 — 규칙 11) · S02c = «test/execution_gap_view_test.dart:18» · «test/golden/s710_golden_test.dart:1»(드라이런 확인) ·
   S03 = 엔진 글자 가공 0 · S04 = 출력 없음(이 카드가 쓰는 AppRoutes 0 · import 도 show 없이라 이름이 안 찍힌다) ·
   S05 = 탭 콜백 안 2줄(SafetyBlockBanner onOpenLink · TrustBadgeView onOpenLink · 줄 번호는 짓는 모양마다 다르다 — 드라이런은 66 · 111) — build 본문에서 읽는 줄 0 ·
   S06~S12 = lib 전체 0(R12a~c 포함 — 앞 카드 병합본에서 이미 0) · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0(누적 드라이런 확인) ·
   S14 = S7-10 파일에 롤링·등급 창구·금액 타입·운영 모드 0 · S15 = 대소문자 구분 · 9줄(기존 4 + R12a 2 + R12b 1 + R12c 1 + executionGapProvider 1 · 마지막 줄 = executionGapProvider 의 «executionGapProvider = FutureProvider.autoDispose» · 줄 번호는 병합본마다 다를 수 있다 — 9줄이 기준) · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = export 13줄(execution_gap_screen 은 drawdown_context_screen 과 goal_path_screen 사이) ·
   S17·S18·S18b = 차트 본보기와 lib 차트 차이 0(이 카드는 차트를 건드리지 않는다) · S19~S23 = 12항의 1·3·11항 근거(S22·S23 = 11항 보강 — 계약 테스트 C-38 ⑫ 와 같은 정규식) ·
   S24 = 폐기·금지 이름 0 · S25 = C-42 ②③ 의 S7-10 원값 점 접근 0(+ actionDeepLink·detailDeepLink — 화면 파일은 링크 필드를 읽지 않는다) ·
   S26 = 공개 위젯은 본문만(ScaffoldMessenger 도 «Scaffold» 로 걸린다) ·
   S27 = 공용 파일의 «더하기만» — 세 파일 모두 둘째 수(삭제)가 0 · 첫째 수 = labels 3(빈 줄 · 절 주석 · 라벨 1) · providers 16(위 «주입 구조» 의 절 그대로 · 빈 줄 포함) · 배럴 1(드라이런 확인 — 다르면 절 모양이 카드와 다른 것) ·
   S28 = C-42 ⑥(소수부 ≠ 0 소수 · % 문자열) 0 · S29 = Card() 기본 고도 · S30 = C-42 ⑨ 정렬·거르기 0 ·
   S31·S32 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 정확히 같아야 한다(15 · 8 · 다르면 반려 — 규칙 11) ·
   S33 = s710-root · s710-gauge · s710-count · s710-correction · s710-advice · s710-empty · s710-asof 7줄(각 1번 · Key 표 밖의 s710- 0 · 줄 번호와 줄 순서는 private 메서드 배치에 따라 다르다 — 이름 7개가 각 1번이면 된다))
  (🆕 이번 기대 — lib·PNG·다른 테스트 불변이고 R1·R2 는 한국어·비 ASCII 이름·testWidgets·ⓡ·ⓗ 줄을 더하지 않으므로, 37줄의 출력은 1회차 출력과 같다(EXIT 표기·warning 줄·PowerShell 장식 줄 말고):
   S02c = test/execution_gap_view_test.dart:18 · test/golden/s710_golden_test.dart:1 · S05 = lib/src/screens/execution_gap_screen.dart:53 · :66 두 줄 · S13 옛 4파일 · S15 9줄(마지막 :166) · S16b 13줄 ·
   S27 = 3 0 · 16 0 · 1 0 · S31 = test/execution_gap_view_test.dart:15 · S32 = test/execution_gap_view_test.dart:8 · S33 7줄(46 · 72 · 92 · 100 · 145 · 154 · 160) · 나머지 출력 없음(S17·S18·S18b 는 요약 줄 없음) — C4 1회차 재실행과 같음 ·
   🔴 S31·S32 가 15·8 과 다르면 제출하지 말고 R1·R2 를 다시 본다 · 그 밖의 줄이 1회차와 다르면 멈춘 뒤 채팅으로)
  이어서 packages/domain_contracts 에서(정적 묶음과 별도 · 1회차 카드 ■ 제출 627~632행과 같은 명령):
    cd ../domain_contracts
    dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded
       ← 출력에서 «C-42 ① 대상» 으로 시작하는 줄과 그 바로 아래 들여쓴(공백 4칸) 경로 줄 전부 + «C-42 ① 역할 대상 합» 줄 = 11줄(진행 표시 줄 «00:00 +0: …» 은 빼고 · 줄을 고르지 않는다 · 파일로 떠서) ·
         끝 줄 «All tests passed!» 확인 · 기대 = 1회차와 같은 11줄(«C-42 ① 대상 S7-10(R12d) 1파일 — …» · 그 아래 «    lib/src/screens/execution_gap_screen.dart» · 마지막 «C-42 ① 역할 대상 합 5파일 · providers R12 절 61줄») · 다르면 멈춘 뒤 채팅으로
    cd ../ui_analytics

■ 테스트 수 묶음 — packages/ui_analytics 에서 세 줄(조각 12 와 조각 18 의 끝 줄은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다 · 파일로 떠서 붙인다)
  flutter test test/execution_gap_view_test.dart   ← 끝 줄 «+54: All tests passed!» 기대(1회차와 같음 — R1·R2 는 testWidgets·경우 수를 바꾸지 않는다 · C4 시험 «+54»)
  flutter test test/golden/s710_golden_test.dart   ← «+12: All tests passed!» 기대(1회차와 같음)
  flutter test                                     ← 끝 줄 «+514: All tests passed!» 기대(1회차와 같음 — C4 시험 «+514»)
  PowerShell 에서 파일로 뜨는 꼴(예 — 이름은 아무것이나 · 저장소 밖):
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    flutter test test/execution_gap_view_test.dart | Out-File -Encoding utf8 $env:TEMP\r12d_t_view.txt
    Get-Content -Encoding UTF8 $env:TEMP\r12d_t_view.txt | Select-Object -Last 1   ← 이 줄을 그대로 복사(golden · 전체도 같은 꼴로 r12d_t_golden.txt · r12d_t_all.txt)
  (수가 +54 · +12 · +514 와 다르면 제출하지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로 — 상자의 수를 맞추려 고쳐 쓰지 않는다.)

■ 제출
  (R1·R2 를 고치고 «고친 뒤 확인» 이 기대와 같은 뒤)
  cd packages/ui_analytics
  flutter test test/execution_gap_view_test.dart   ← 먼저 이 파일만 · «+54: All tests passed!»(실패하면 고친 곳을 상자와 다시 대조 · lib 를 고치지 않는다)
  flutter test   ← 옵션 없이 전부 통과 · «+514: All tests passed!»
  cd ../..
  melos.bat run format:fix
  git status --short   ← M 은 packages/ui_analytics/test/execution_gap_view_test.dart 하나뿐이어야 합니다(PNG·lib·질문 파일의 M = 금지 → git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  git add packages/ui_analytics/test/execution_gap_view_test.dart
  git commit -m "[M7] R12d (6) 재제출 — T710-15 Text 전부 단언 · 허용 집합 null-aware"   ← 위 «커밋 제목» 상자 글자 그대로
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git diff --name-status 20edbbd HEAD
     ← 재제출 커밋의 변경만 봅니다. 🔴 정확히 이 한 줄이어야 합니다:
        M	packages/ui_analytics/test/execution_gap_view_test.dart
        다른 줄이 한 줄이라도 나오면(lib · PNG · 질문 파일 · execution_gap_fakes · s710_golden_test …) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git log --oneline -2   ← 맨 위 = 재제출 커밋 · 그 아래 = 20edbbd(지난 커밋은 그대로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #29 자동 반영 · 새 PR·라벨·강제 푸시(--force · --force-with-lease)·rebase·main 병합 금지)
  아래 출력은 푸시한 그 커밋 위에서 · git status 가 빈 채로 · 1회차 출력을 쓰지 않는다 · 전부 파일로 떠서:
   git diff --name-status origin/main...HEAD   ← 조각 2(기대 = 1회차와 같은 20줄 · 테스트 파일은 1회차부터 A 라 줄이 늘지 않는다 · 다르면 멈춘 뒤 채팅으로)
   git log --oneline origin/main..HEAD         ← 조각 4(6줄 · 맨 위 = 재제출 커밋 · 그 아래 5줄 = 1회차 그대로 «20edbbd [M7] R12d (5) format · 질문» … «d01d0b8 [M7] R12d (1) 정적 라벨» · 다르면 멈춤)
   cd packages/ui_analytics → 위 «정적 묶음» 37줄 → 조각 8 → C-42 줄(cd ../domain_contracts → dart test … → cd ../ui_analytics) → 조각 10 → 위 «테스트 수 묶음» 3줄 → 조각 12 · 조각 18 → cd ../..
   git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/S7-10_questions.md   ← 저장소 뿌리에서 · «+|» 로 시작하는 줄이 조각 16 상자 6줄과 글자 같아야 한다(질문 파일 불변 — 다르면 멈춘 뒤 채팅으로 · 이 출력은 붙이지 않는다 · 조각 16 은 상자 글자로 낸다)
  git status --short   ← 🔴 다시 비어 있어야 합니다(명령이 파일을 바꾸었으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다(golden:approved 포함).

■ 보고 글 — ①~⑤ 전체판 (12 §3 재제출 조문 2026-10-14 개정 «전체판 + 바뀔 자리만 상자» · 이 재제출이 첫 적용)
  🔴 채팅 글 = 아래 조각 1~18 을 이 차례로 이은 것뿐입니다. 조각은 두 갈래입니다:
     [상자] = 복사 상자 글자 그대로(한 글자도 바꾸지 않는다 — 바뀌지 않는 자리는 1회차 Bob 글자를 그대로 옮긴 상자 · 바뀌는 자리는 C4 가 준 상자) ·
     [출력] = 위 «■ 제출» 에서 다시 돌린 명령 출력을 파일로 떠서 그대로(줄을 고르거나 줄이거나 고쳐 쓰지 않는다).
  🔴 상자와 출력 밖에는 아무 글도 짓지 않습니다 — 머리말(«모든 확인 완료 …» · «재제출 글입니다» · «이제 제출 글을 작성합니다») · 구분선 --- · 요약 · 설명 · 까닭 줄 · 끝인사 0.
     기대와 다른 출력이 나오면 글로 설명하지 말고 제출을 멈춘 뒤 채팅으로 출력을 보입니다(위 «■ 제출» 의 멈춤 줄).
  🔴 첫 줄 = 조각 1 의 첫 줄 «## ① 구현한 화면 ID · 바뀐 파일 · 커밋»(1회차 카드 N1) · 조각 사이에는 빈 줄 하나를 둔다(빈 줄은 대조에서 뺀다) · 상자 머리·끝 줄(┌── · └──)은 붙이지 않는다.
  🔴 «코드 블록 하나로» = 위아래에 백틱 세 개 줄을 두른다(1회차 글과 같은 꼴) · «코드 블록 없이» = 줄만 그대로.
     꼴 표시가 없는 조각(1·3·5·7·11·15·17·18) = 코드 블록 없이(1회차 글과 같은 꼴).
  조각 1 [상자 · 바뀌지 않는 자리 · ① 머리]
      ┌── 조각 1 복사 시작(다음 줄부터 · 4줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
화면 ID: S7-10 — 안내 이행 리포트(ExecutionGapScreen({String? yyyyMm}))
R12 «정확히 N» 소유: 배럴 export 13(T710-16) · autoDispose 9(T710-17)
바뀐 파일:
      └── 조각 1 복사 끝(이 줄 앞까지)
  조각 2 [출력 · 바뀌는 자리] git diff --name-status origin/main...HEAD 출력 그대로 — 코드 블록 하나로(기대 20줄 = 1회차와 같음)
  조각 3 [상자]
      ┌── 조각 3 복사 시작(다음 줄부터 · 1줄)
커밋 목록:
      └── 조각 3 복사 끝(이 줄 앞까지)
  조각 4 [출력 · 바뀌는 자리] git log --oneline origin/main..HEAD 출력 6줄 그대로 — 코드 블록 하나로(맨 위 = 재제출 커밋)
  조각 5 [상자 · 바뀌지 않는 자리 · ② 머리 + 자체 점검 12항 15줄(1회차 괄호까지)]
      ┌── 조각 5 복사 시작(다음 줄부터 · 17줄)
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
 1. `ui_analytics`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 S19 — 허용 밖 import 0줄)
 2. 화면 코드에 산술이 없는가 — 행동 갭·워터폴 잔여·밴드 이탈·페널티 금액을 내가 계산하지 않았는가 [x] (S7-10 화면 파일 산술 0 · 게이지 폭 = complianceRateNormalized 정규값 clamp 하나(T710-07) · 건수·교정 = 엔진 줄 글자(T710-05·06))
 3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (리밸런싱 트리거 배지·«미달» 경고문 포함) [x] (정적 묶음 S20 — 0건)
 4. S7-2에 인터스티셜·격리 위치·열람 기록 3종이 모두 있는가 [x] (이 카드 범위 밖)
 5. M8 홈·알림에 넘기는 요약과 D-7/D-1 알림 본문에 손익·금액이 없는가 [x] (이 카드 범위 밖)
 6. 플래너가 M3 결과만 그리는가 / «미리보기입니다» 고지가 상시인가 / 주문 실행 버튼이 없는가 [x] (이 카드 범위 밖)
 7. 결측 구간을 보간하지 않고 공백으로 두는가 / «산출 불가»에 근사 배지를 붙이지 않았는가 [x] (앞절 이 카드 범위 밖(S7-10 에 시계열 없음) / 뒷절 가림 = 엔진 «?» 글자 그대로 · 게이지 부재(T710-07 masked_recon) · 배지 0)
 8. 표본 크기 고지·벤치마크 구성 문구가 뷰모델 문자열 그대로인가 [x] (이 카드 범위 밖)
 9. as-of 기준일이 모든 성과 화면 상단에 상시 표기되고, 유예 초과 시 «오래된 데이터» 배너가 뜨는가 [x] (as-of 는 이행 리포트 화면에 1줄(s710-asof · T710-04) · 오래됨 배너 = StaleBanner(T710-12))
10. S7-8의 게이트·개입 UI를 자체 구현하지 않았는가 / 픽스처·골든 스냅샷을 손대지 않았는가 [x] (앞절 이 카드 범위 밖 / 뒷절 기존 PNG M 0 · 새 PNG = s710_* 12장 · domain_contracts 변경 0)
11. `ui_analytics` 소스에 세후·기대수익률·낙폭 수치가 리터럴로 없는가 —
    정규식 `\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b` 로 `lib/` 만 검사(pubspec·버전 문자열·
    `fixtures/`·테스트는 대상 제외 — 픽스처는 M2 소유) [x] (정적 묶음 S21 결과 0건 · 보강 S22 결과 0건 · S23 결과 0건)
12. 세후 카드에 계좌 배치 갈래가 정확히 하나만 펼쳐져 있는가 / 층을 화면에서 합치거나 빼지 않았는가 /
    목표 경로 가정 카드가 «백테스트 기준 실행»과 «현재 원금·납입» 두 줄로 갈라져 있는가 [x] (이 카드 범위 밖(S7-10 에 세후 카드·목표 경로 가정 카드 없음))
12항 줄 수:
      └── 조각 5 복사 끝(이 줄 앞까지 — 12항 15줄은 1회차 글자 그대로 · 다시 세지 않는다)
  조각 6 [상자 · 바뀌지 않는 자리 · 세는 줄] — 코드 블록 하나로
      ┌── 조각 6 복사 시작(다음 줄부터 · 1줄)
15
      └── 조각 6 복사 끝(이 줄 앞까지)
  조각 7 [상자]
      ┌── 조각 7 복사 시작(다음 줄부터 · 1줄)
정적 묶음 출력:
      └── 조각 7 복사 끝(이 줄 앞까지)
  조각 8 [출력 · 바뀌는 자리] 위 «정적 묶음» 37줄의 출력 전부 — 코드 블록 하나로(줄이지 않는다 · 빈 줄도 지우지 않는다 · warning: 줄이 나오면 지우지 않고 그대로)
  조각 9 [상자 · 바뀌지 않는 자리 · S05 결과 · ⓡⓗ · C-42 이름표] — 코드 블록 없이
      🔴 S05 두 줄은 조각 8 의 S05 출력(경로·줄 번호)과, ⓡ·ⓗ 둘째·넷째 줄은 조각 8 의 S31·S32 출력 줄과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 멈춘 뒤 채팅으로(lib 가 바뀌었거나 R1·R2 가 상자와 다르다).
      ┌── 조각 9 복사 시작(다음 줄부터 · 8줄)
S05 결과:
lib/src/screens/execution_gap_screen.dart:53 — 탭 콜백 안
lib/src/screens/execution_gap_screen.dart:66 — 탭 콜백 안
ⓡ = S31 출력:
test/execution_gap_view_test.dart:15
ⓗ = S32 출력:
test/execution_gap_view_test.dart:8
C-42 ① 출력:
      └── 조각 9 복사 끝(이 줄 앞까지)
  조각 10 [출력 · 바뀌는 자리] 위 dart test 의 «C-42 ①» 줄과 그 아래 들여쓴 경로 줄 전부 그대로 11줄 — 코드 블록 없이(들여쓰기 그대로 · S7-10 줄만 고르지 않는다)
  조각 11 [상자]
      ┌── 조각 11 복사 시작(다음 줄부터 · 1줄)
테스트 파일별:
      └── 조각 11 복사 끝(이 줄 앞까지)
  조각 12 [출력 · 바뀌는 자리] 위 «테스트 수 묶음» 의 execution_gap_view_test · s710_golden_test 끝 줄 그대로 2줄(이 순서) — 코드 블록 없이
  조각 13 [상자 · 바뀌지 않는 자리 · ③ 머리 + 스크린샷 서술 4줄(로딩·정상·빈·차단)] — 코드 블록 없이
      ┌── 조각 13 복사 시작(다음 줄부터 · 5줄)
## ③ 스크린샷 서술 · 골든 표
로딩 = AnalyticsSkeleton(배너 없음)
정상 = Key('s710-root') → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → Expanded(ListView) → periodLabel Text → TrustBadgeView → Key('s710-gauge')(있을 때) → complianceRateLabel Text → ValueKey<String>('s710-count-$i') → medianDelayLabel Text → priceGapLabel Text → ValueKey<String>('s710-correction-$i')(있을 때) → amendChainMaxLabel Text → executionGapSkipReasonsHeader Text(있을 때) → Chip(skipReasonBuckets · 있을 때) → Chip(selectiveExecutionChips · 있을 때) → Key('s710-advice')(있을 때) → Key('s710-asof')
빈 = Key('s710-root') → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → Expanded(ListView) → Card → Key('s710-empty') → Key('s710-asof')
차단 = StaleBanner 아래 · Expanded(ListView) 바깥 위(값이 온 뒤의 Column 둘째 자식)
      └── 조각 13 복사 끝(이 줄 앞까지)
  조각 14 [상자 · 바뀌는 자리 · ③ 골든 표 머리 2줄 + 12행 — C12d-3·C12d-4] — 코드 블록 없이(마크다운 표 그대로)
      🔴 붙이기 전에 PNG 12장(test/golden/goldens/s710_*.png)을 다시 연다 — 골든 글꼴은 글자를 네모로 그린다 · 줄 수·차례·상자·가로 막대·칩 개수·버튼 글자 네모의 있고 없음·잘림만 본다 ·
         «글자 n줄» 의 n = PNG 에 보이는 글자 행 수(줄바꿈된 행도 한 행으로 센다 · Text 위젯 수나 문장 수가 아니다) · «상자» = 테두리·모서리가 보이는 덩어리 · 화면 폭 전체 배경 = «배경 덩어리».
         «칩 n개» 의 n = 한 무리의 칩 개수(한 무리가 두 행으로 줄바꿈돼도 하나로 센다 · 예 mixed «칩 3개» = 2개 + 1개 두 행) · «상자» 속 글자 행은 세지 않는다(상자 하나뿐인 빈·해당 없음 화면만 «상자 안 글자 n줄»).
         이 상자와 PNG 가 다르면(행 수·덩어리 차례·잘림) 제출하지 말고 멈춘 뒤 채팅으로 — 상자를 고쳐 쓰지 않는다.
         (PNG 는 이번 재제출에서 바뀌지 않는다 — 골든 테스트·lib 0 · dy 그대로 · 앞 다섯 칸은 1회차 글자 그대로 · 배치·잘림 칸만 바뀐다.)
      ┌── 조각 14 복사 시작(다음 줄부터 · 14줄)
| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |
|---|---|---|---|---|---|
| `s710_cant` (dark) | m7/execution_gap_cant.json | 0 | 390×844 | 573 | 글자 1줄 → 상자 → 가로 막대 → 글자 8줄 → 교정 글자 2줄 → 글자 1줄 → 머리글 1줄 → 칩 2개 → 제안 글자 2줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_cant` (light) | m7/execution_gap_cant.json | 0 | 390×844 | 573 | 글자 1줄 → 상자 → 가로 막대 → 글자 8줄 → 교정 글자 2줄 → 글자 1줄 → 머리글 1줄 → 칩 2개 → 제안 글자 2줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_wont` (dark) | m7/execution_gap_wont.json | 0 | 390×844 | 591 | 글자 1줄 → 상자 → 가로 막대 → 글자 7줄 → 글자 1줄 → 머리글 1줄 → 칩 2개 → 칩 1개 → 제안 글자 4줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_wont` (light) | m7/execution_gap_wont.json | 0 | 390×844 | 591 | 글자 1줄 → 상자 → 가로 막대 → 글자 7줄 → 글자 1줄 → 머리글 1줄 → 칩 2개 → 칩 1개 → 제안 글자 4줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_mixed` (dark) | m7/execution_gap_mixed.json | 0 | 390×844 | 649 | 글자 1줄 → 상자(버튼 글자 포함) → 가로 막대 → 글자 8줄 → 교정 글자 2줄 → 글자 1줄 → 머리글 1줄 → 칩 3개 → 칩 1개 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_mixed` (light) | m7/execution_gap_mixed.json | 0 | 390×844 | 649 | 글자 1줄 → 상자(버튼 글자 포함) → 가로 막대 → 글자 8줄 → 교정 글자 2줄 → 글자 1줄 → 머리글 1줄 → 칩 3개 → 칩 1개 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_empty` (dark) | m7/execution_gap_empty.json | 0 | 390×844 | 112 | 상자 안 글자 1줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_empty` (light) | m7/execution_gap_empty.json | 0 | 390×844 | 112 | 상자 안 글자 1줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_not_applicable` (dark) | m7/execution_gap_not_applicable.json | 0 | 390×844 | 152 | 상자 안 글자 3줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_not_applicable` (light) | m7/execution_gap_not_applicable.json | 0 | 390×844 | 152 | 상자 안 글자 3줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_masked_recon` (dark) | m7/execution_gap_masked_recon.json | 3 | 390×844 | 544 | 맨 위 화면 폭 배경 덩어리(글자 5줄) → 글자 1줄 → 상자(버튼 글자 포함) → 글자 7줄 → 교정 글자 2줄 → 글자 1줄 → 기준일 글자 1줄 — 잘림 없음 |
| `s710_masked_recon` (light) | m7/execution_gap_masked_recon.json | 3 | 390×844 | 544 | 맨 위 화면 폭 배경 덩어리(글자 5줄) → 글자 1줄 → 상자(버튼 글자 포함) → 글자 7줄 → 교정 글자 2줄 → 글자 1줄 → 기준일 글자 1줄 — 잘림 없음 |
      └── 조각 14 복사 끝(이 줄 앞까지)
  조각 15 [상자]
      ┌── 조각 15 복사 시작(다음 줄부터 · 1줄)
## ④ 질문 목록
      └── 조각 15 복사 끝(이 줄 앞까지)
  조각 16 [상자 · 바뀌지 않는 자리 · ④ 질문 목록 6줄] — 코드 블록 하나로(위 «■ 제출» 의 질문 파일 diff 의 «+|» 줄과 글자 같아야 한다)
      ┌── 조각 16 복사 시작(다음 줄부터 · 6줄)
+| A1 | R12d-Bob-S710 | 추측 | 측정: s710_cant dy 실측값 (light=573, dark=573 < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A2 | R12d-Bob-S710 | 추측 | 측정: s710_wont dy 실측값 (light=591, dark=591 < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A3 | R12d-Bob-S710 | 추측 | 측정: s710_mixed dy 실측값 (light=649, dark=649 < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A4 | R12d-Bob-S710 | 추측 | 측정: s710_empty dy 실측값 (light=112, dark=112 < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A5 | R12d-Bob-S710 | 추측 | 측정: s710_not_applicable dy 실측값 (light=152, dark=152 < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A6 | R12d-Bob-S710 | 추측 | 측정: s710_masked_recon dy 실측값 (light=544, dark=544 < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 조각 16 복사 끝(이 줄 앞까지)
  조각 17 [상자 · 바뀌지 않는 자리 · ⑤]
      ┌── 조각 17 복사 시작(다음 줄부터 · 2줄)
## ⑤ 추측한 것 목록
없음
      └── 조각 17 복사 끝(이 줄 앞까지)
  조각 18 [틀 · 바뀌는 자리 · 끝 줄] — <…> 자리에만 위 «테스트 수 묶음» 의 flutter test(전체) 끝 줄 그대로(시각·«+수»·«All tests passed!» 까지 · «끝 514» 처럼 수만 쓰지 않는다 · «시작 기준 448» 은 1회차 글자 그대로)
      ┌── 조각 18 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 448 → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>
      └── 조각 18 복사 끝(이 줄 앞까지)

■ 내기 전 자기 확인 — 1회차 카드 664~671행(N3) 글자 그대로 · 파일 이름만 $env:TEMP\r12d_resubmit.md
  (이번 글은 상자와 출력뿐이라 다섯 줄은 기대(0줄 · 첫 줄 · 12 · 12 · 0줄)대로 나와야 한다 — 다르면 상자를 고쳐 쓰지 말고 상자를 다시 옮긴다 · 그래도 다르면 멈춘 뒤 채팅으로)
      🆕 내기 전 자기 확인(발주자 결정 2026-10-14 ② N3) — ①~⑤ 와 flutter test 한 줄까지 다 쓴 제출 글 전체를 저장소 밖 파일에 저장(예 PowerShell 에서 notepad $env:TEMP\r12d_resubmit.md 로 열어 붙여 넣고 저장 · 이 파일은 커밋하지 않는다)한 뒤 PowerShell 에서 다섯 줄:
     Select-String -Path $env:TEMP\r12d_resubmit.md -Encoding UTF8 -Pattern '파란|파랑|푸른|보라|빨간|빨강|붉은|주황|초록|녹색|노란|노랑|회색|분홍|남색|갈색|하늘색|(?<![A-Za-z])(primary|secondary|tertiary|error|surface)'   ← 출력 0줄이어야 함(예외 = 명령 출력 코드 블록 안의 줄 — 아래)
     Get-Content $env:TEMP\r12d_resubmit.md -Encoding UTF8 -TotalCount 1   ← «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» 한 줄이어야 함
     (Select-String -Path $env:TEMP\r12d_resubmit.md -Encoding UTF8 -Pattern '^\| *`?s710_').Count   ← 12(③ 골든 표 행 — 표는 «| 이름 | … | 배치·잘림 |» 꼴 마크다운 표 · 한 행 한 줄)
     (Select-String -Path $env:TEMP\r12d_resubmit.md -Encoding UTF8 -Pattern '^\| *`?s710_.*— 잘림[^|]*\| *$').Count   ← 12(배치·잘림 칸 끝 «— 잘림 없음 / — 잘림: …» · 바로 위 수와 같아야 함)
     Select-String -Path $env:TEMP\r12d_resubmit.md -Encoding UTF8 -Pattern '^\| *`?s710_.*\|[^|]*[A-Za-z][^|]*\| *$'   ← 출력 0줄이어야 함(배치·잘림 칸의 영문 낱말 = 코드 이름 0 — Card · Row · Primary 등)
        첫째 명령에 줄이 나오면 — 사람이 쓴 칸(③ 서술·골든 표 등)이면 그 낱말을 PNG 에 보이는 말(예 «버튼 글자»)로 바꾼 뒤 다섯 줄을 다시 돌린다 · 명령 출력을 붙인 코드 블록 안의 줄이면 출력은 고치지 않는다(그대로 낸다).
        둘째 명령이 다른 줄을 보이면 첫 줄 위의 글을 지우고 다시 돌린다 · 셋째·넷째 수가 12 가 아니거나 서로 다르면, 또는 다섯째 명령에 줄이 나오면 그 골든 표 행의 배치·잘림 칸을 위 견본 꼴로 고친 뒤 다시 돌린다 · 첫째 명령은 대소문자를 가리지 않는다(Primary·Error 도 잡는다 · 앞에 영문 글자가 붙은 AnalyticsErrorView 같은 이름은 잡지 않는다) · 다섯 명령의 출력은 채팅에 붙이지 않는다(확인용 · PowerShell 5.1 에서 확인한 글자 · 정적 묶음 실제 출력에서 헛경보 0).
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s710-gap` 에 추가 커밋 **1개**: `[M7] R12d (6) 재제출 — T710-15 Text 전부 단언 · 허용 집합 null-aware`. main 병합 커밋 **없음** · 지난 5개 커밋 **그대로**(`git log --oneline origin/main..HEAD` = 6줄 · 맨 위 = 재제출 커밋 · 아래 5줄 = 1회차 글자).
- `test/` 수정 1 — `execution_gap_view_test.dart` 의 R1·R2 자리만(+31/−34 · C4 시험 diff `j_fix.diff` 와 같은 글자 — 통합 담당이 `git diff 20edbbd HEAD` 를 그 diff 와, 트리의 파일을 C4 수정안 파일과 대조한다).
- `lib/` 변경 0 · PNG 변경 0 · 골든 테스트·가짜·질문 파일 변경 0 — `git diff --name-status 20edbbd HEAD` = `M	packages/ui_analytics/test/execution_gap_view_test.dart` 한 줄.
- `ui_analytics` `flutter test` **514**(뷰 54 · 골든 12 — 1회차와 같은 수) · 정적 37줄 출력 = 1회차와 같은 글자(EXIT·warning·장식 줄 말고 · S31 15 · S32 8 · S05 `:53` · `:66`) · C-42 ① 11줄 = 1회차와 같음.
- 채팅: 보고 글 ①~⑤ **전체판** = 조각 1~18(상자 13 · 출력 5) — 첫 줄 `## ① 구현한 화면 ID · 바뀐 파일 · 커밋` · 섹션 머리 5줄(1회차와 같은 글자) · 조각 2 name-status 20줄 · 조각 4 git log 6줄 · 조각 8 정적 37줄 출력 전부 · 조각 10 C-42 ① 11줄 · 조각 12 테스트 파일별 2줄 · 조각 14 골든 표 12행(C4 상자) · 조각 18 끝 줄 · 그 밖은 1회차 글자 상자 그대로 · 상자·출력 밖 글 0.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12d-Bob-S710 재제출: PR #29 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 채팅 글(①~⑤ 전체판 — 첫 줄 `## ①` 부터 끝 줄 `flutter test: …` 까지)을 붙여넣습니다(Claude 가 PR #29 본문을 이 글로 통째로 바꿉니다). 0단계·«먼저 할 것»·«고친 뒤 확인»·«■ 제출» 에서 멈췄다면 `R12d-Bob-S710 재제출 0단계에서 멈춤 — 확인해줘`(멈춘 자리 이름으로) + Bob 이 보여 준 출력. Bob 이 상자 밖 글(머리말·요약·까닭 줄)을 더해 냈다면 그대로 붙여넣되 «상자 밖 글 있음» 이라고 함께 알립니다(통합 담당이 strict 나눔으로 가른다).

## 5. 주의

- **5분 눈 검사**(PR #29 «Commits» · «Files changed» — `20edbbd` 뒤 커밋만 보면 된다): ① 커밋 수가 6 이 아님 · 지난 5개 해시가 바뀜(강제 푸시·rebase 흔적) · `Merge … origin/main` 커밋 ② `packages/ui_analytics/lib/` 의 변경 ③ PNG 변경(`s710_*` 포함 — 이번에는 한 장도 바뀌면 안 된다) ④ `execution_gap_fakes.dart`·`s710_golden_test.dart`·`labels.dart`·`pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README·질문 파일 변경 ⑤ T710-15 에 아직 `if (data != null && data.isNotEmpty)` 가 남음 · `expect(shown, isNotEmpty);` 한 줄이 없음 · 허용 집합에 `if (report` 가 남음 ⑥ 채팅 글 조각 14 가 상자와 다름 · 첫 줄 위의 섹션 밖 글 · 상자 밖 글 — 하나라도 있으면 반려 신호(⑥ 은 strict 나눔 ① 표기만이면 C4 정정 대상).
- CI: PNG 변경 0 이라 «골든 스냅샷» 은 라벨 없이 초록이 정상(PR #29 라벨 0 그대로 · 붙이지 않는다). «분석 · 테스트(melos)» 는 Bob 의 푸시(새 `pull_request` synchronize)로 새 `main`(기록 커밋 포함) 위의 병합 미리보기를 다시 돌린다 — 기록 커밋은 문서뿐이라 수는 C4 시험과 같은 것이 기대.
- C4 가 2회차에서 볼 것: 기계 = `20edbbd..HEAD` test 1파일 M · hunk 가 R1·R2 자리뿐(`j_fix.diff` 와 글자 대조 · 트리의 파일 = C4 수정안 `execution_gap_view_test.fixed.dart` 바이트 대조) · 지난 5개 해시 불변 · 전체 +514 · analyze · format · C-42 · CI / 변이 = 예고 31꼴(실행 36꼴 — 갈래 추가 포함) + 참고 P01b·R01·R12(이제 T710-15 가 잡아야 함 — 실패 테스트 이름이 T710-15 인지 확인) · R05·R06(카드 구멍 — 기록만) 재실행 / 정직 = 전체판의 [상자] 조각은 이 패킷 상자 글자와(조각 1·3·5·6·7·9·11·13·15·16·17 = 1회차 Bob 글자 · 조각 14 = C4 상자 · 조각 18 = 틀) · [출력] 조각(2·4·8·10·12 · 18 의 끝 자리)은 재실행 출력과 글자 대조(테스트 끝 줄의 줄 머리 경과 시각(mm:ss)은 대조에서 뺀다) · 상자·출력 밖 글 0 · N1·N3 다시 · 질문 파일 불변. 판정 기준 = 1회차 카드 strict 나눔(카드 208~211행 · ① 표기만 = C4 정정 · ② 코드·테스트·거짓 = 반려 · ③ 예고 변이 = 반려).
- 병합 뒤 할 일(Claude · C4 보고 §5·§6-1): 질문 파일 A1~A6 답 칸(«PR #29 `20edbbd` 측정값 = C4 재실측 …» · 재제출은 골든 테스트·lib·PNG 0 이라 같다) · 머리말 «다음 번호 = Q1·A7» · golden README 1행(108장)·R12d 병합본 실측 줄 · `packages/ui_analytics/README.md` 테스트 수 514 · 패킷 이동은 이 재제출 패킷 `send/R12d-Bob-S710-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · 🔴 `send/` 에 다음 카드 없음 = R12 네 장 완료(보낼 패킷 0장이 정상 · 다음 카드는 설계 12 §6 큐 — 기본 R3-Bob-J4 · 선행 01 §8 미결 46 은 병합 기록 때 다룬다) · 팩 판은 그다음 접미 · 2회차 보고 보존본 `10_리뷰/<날짜>_R12d_C4_2회차_보고.md`.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12d 패킷은 이 파일 하나입니다. 원 패킷 `R12d-Bob-S710.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 한다). `_완료/R12c-Bob-S77-재제출.md` · `_완료/R12b-Bob-S76c-재제출.md` · `_완료/R12a-Bob-S76ab-재제출.md` · `_완료/R12a-Bob-S76ab-재제출2.md` · `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` 는 끝난 카드입니다.
- 범위 밖(발주자 결정 2026-10-15 ④): C4 보고 §7 의 보강 후보 C4d-1(«화면의 Text 전부» 단언 코드 글자 견본 + 정적 묶음에 if 짝 세는 줄) · C4d-5(골든 표 «글자 줄 n» = PNG 에 보이는 행 수(줄바꿈 포함) · «상자» = 테두리·모서리 보이는 덩어리 · 폭 전체 배경 = «배경 덩어리»)는 R12 다음 카드부터 넣는다 — R12d 가 R12 마지막이라 지금은 설계 12 §3 «R12d C4 이월 부록» 에 적었다 · C4d-2~4·6 은 그 장면이 있는 카드 후보(발주자 미결정). 이 재제출에는 넣지 않는다(이 재제출은 위 R1·R2 와 «커밋» 상자 1개 그대로 · 조각 14 상자는 C12d-3·4 정정이지 카드 조문 개정이 아니다).
