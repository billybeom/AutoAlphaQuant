# 발송 패킷 R6a-Bob-M9S01 — 재제출 (1회차 반려 · 2026-11-13)

> ▶ **보낼 수 있음(「푸시해」 뒤)**(2026-11-13 · C4 R6a 1회차 반려 기록 · 이 파일이 GitHub `main` 의 `send/` 에 있고 PR #146 «Conversation» 에 C4 반려 댓글 `6856195390`(«C4 병합 검사 판정 — 🔴 reject(1회차 반려 → 재제출) · R6a-Bob-M9S01 · head `7c5ac34`»)이 보이면 보낸다 · 댓글은 「푸시해」 때 Claude 가 게시(번호 = 게시 뒤 기록) · Bob **새 대화** · 같은 브랜치 `ui/m9-s01-settings-home` · 같은 PR #146 · 그 밖의 선행 없음 · 🔵 `main` 계약 `'1.18.0'` 전제(엔진 세션이 계약을 먼저 올리면 Bob 이 0단계에서 멈춘다 — 통합 담당이 기대를 다시 본다) · `send/README.md` 배지 규칙 · 아래 «■ 보고 글 만들기» 의 `-Skip 208 -First 232` = 이 판의 견본 209~440행(조립판에서 다시 잼))
> 만든 날 2026-11-13 · 1회차(PR #146 · 브랜치 `ui/m9-s01-settings-home` · 커밋 `7c5ac34` · 밑동 `cfa1227` · 커밋 7 · 통합 담당 대행 PR)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-11-13) = (A) 반려 → 재제출 · 커밋 꼴 C4Q-4 = 기록만 · 재제출 = 상자 1 하나만 · 이월 후보 C4r6a-1~9 = 전부 부록(재제출 꼴 = 같은 브랜치·같은 PR #146 · 커밋 1개(테스트 파일 11줄 더하기 · M9S01-04 칩 아이콘 단언) · 보고 글 ①~⑤ 전체판 = 저장 파일 · `[IO.File]::WriteAllText` UTF-8 BOM 없이 · Bob 새 대화 · 자급 패킷).
> 고치는 것 = **파일 하나**(`packages/ui_settings/test/settings_home_test.dart` — 아래 상자 1 · M9S01-04 본문 칩 글자 단언 바로 아래 11줄 더하기 · 0줄 빼기 · 테스트 수 변화 0) **+ 보고 글 ①~⑤ 전체판을 저장 파일로**(견본 = 아래 «■ 보고 글 견본» · 자리표시자 4개만 명령 출력으로 · 견본은 이 파일의 `main` 판에서 기계로 꺼내 PowerShell 로 채운다 — 손으로 옮겨 쓰지 않는다). lib · PNG · 질문 파일 · 다른 문서 0 · PR 본문 · 라벨 0.
> 🔴 **PNG 열람 0** — 이 재제출은 PNG 를 바꾸지도 다시 찍지도 열지도 않는다(`--update-goldens` 0 · `golden:approved` 불필요 · 골든 표 «배치·잘림» 칸 · dy 칸 = 1회차 Bob 칸 그대로 = C4 갈래 G · 기계 갈래 · 정직 갈래가 이름마다 `--plain-name` 으로 다시 잰 값 1048 · 964 · 516 과 같음). lib 를 고치지 않으므로 dy 도 다시 재지 않는다.
> 🔴 **Git Bash 는 경로로 부른다**(이 PC 의 PowerShell 에서 `bash` 는 WSL) — 이 패킷의 bash 줄은 전부 `& "C:\Program Files\Git\bin\bash.exe" …` 꼴이다.
> 🔴 **저장 파일은 UTF-8(BOM 없이) · 줄 끝 LF**(C4r14b-5) — `[Console]::OutputEncoding = [Text.Encoding]::UTF8` 먼저 · 여러 줄은 `-join "`n"` · 저장은 `[IO.File]::WriteAllText(…, (New-Object Text.UTF8Encoding($false)))` 한 꼴. 1회차 저장 파일은 ④ 세 줄 끝에 CR 이 붙었고(C4Q-3 · 저장소의 질문 파일은 LF 로 정상) 코드 울타리가 백틱 6개였다(C4Q-2) — 견본은 이미 고친 글자(LF · 백틱 3개)다.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 카드 `send/R6a-Bob-M9S01.md` 머리 표기(3행 한 줄 안 · «🔴 1회차 반려 — 재제출 = 이 파일» · **줄 수 불변 505** — 아래 «■ 정적 묶음» 이 그 파일 235~271행을 꺼낸다 · 원 카드는 `send/` 에 그대로) · `send/README.md` · `rounds.md` · 팩 README 와 **같은 푸시**로 `main` 에 올린다. `inbox/M9S01_questions.md` 는 `main` 에서 고치지 않는다(이 브랜치가 A1~A3 을 더하는 파일 · 겹침 0). 올린 뒤 이 파일의 줄 수를 바꾸지 않는다(«■ 보고 글 만들기» 가 이 파일의 줄 번호로 견본을 꺼낸다).
> C4 수정안 시험(2026-11-13 · 분리 worktree `C:/Work/AAQ-claude-r6aj` @ `7c5ac34` · melos bootstrap 14 SUCCESS · build_runner 82 outputs · 임시 커밋 `88e6d61`(어느 가지에도 없음 · 트리 `2a5b3d3`) · 끝에 삭제): 상자 1 과 같은 글자(`judge/fix.diff` · 테스트 파일 blob `60380fc`)를 넣고 `dart format` 0 changed · `flutter analyze --fatal-infos` «No issues found!» · `flutter test` 파일별 «00:01 +16» · «00:01 +6» · 전체 «00:01 +23: All tests passed!» · name-status 17 · 커밋 8 · 정적 37줄(해시 `be87988`) 출력 132줄 · EXIT:1 20 · EXIT:0 17 = 1회차 Bob 블록과 같음(다른 줄 0 — C4 저장소는 T08 `index` 줄 해시 약어가 8자인 환경 차뿐) · 사전검사 ① 🔴 0 · 🟡 0 · ②(채운 견본) 🔴 0 · 🟡 1(G1 = 카드 기대) · C4 사람 grep 셋 0 · check_boundaries 실패 0 · 예고 변이 «칩 아이콘 고정»(WATCH 로 · 아이콘만 · 색만 · 둘 다) = 1회차 판 SURVIVED(+23 통과) → 고친 판 KILLED(«M9S01-04 annual review promotion no_review» 실패 · +22 −1).

## 0. 한 줄 목적

PR #146 의 테스트 파일 `packages/ui_settings/test/settings_home_test.dart` 에 상자 1 의 11줄(M9S01-04 칩 아이콘·색 단언)을 더해 커밋 1개로 올리고, 보고 글 ①~⑤ **전체판**(견본 · 바뀌는 자리 = 자리표시자 4개뿐)을 사전검사 ② 를 거쳐 **저장 파일**로 내기 — **lib · PNG · 질문 파일 · 다른 문서는 한 글자도 바꾸지 않고, PNG 는 한 장도 열지 않고, 지난 7개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m9-s01-settings-home` · 같은 PR #146 · 🔴 **새 대화**.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 카드 머리 표기(«🔴 1회차 반려» · 원 카드는 `send/` 에 그대로)를 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(안전장치). PR #146 의 C4 반려 댓글은 「푸시해」 때 Claude 가 함께 올립니다 — 댓글이 보인 뒤 보냅니다.
2. Bob 은 **새 대화** 로 시작합니다(1회차 대화를 이어 쓰지 않습니다 · 필요한 글자는 이 패킷에 다 있습니다). 🔴 보내기 전에 Bob 의 이전 VS Code · 터미널 창을 닫습니다(남은 `flutter_tester.exe` 가 다음 테스트를 붙잡지 않게 · 작업 관리자에서 직접 끝내지 않습니다 — 다른 세션 것도 있습니다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R6a-Bob-M9S01-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md>. 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 이 아니라 이 파일이 없고, Bob 폴더는 PR 브랜치라 **1회차 카드 `R6a-Bob-M9S01.md` 만** 있습니다(그것을 보내면 안 됩니다). `main` 의 `send/` 에도 1회차 카드가 남아 있습니다(머리 «🔴 1회차 반려» · 다시 보내지 않음) — 보내는 것은 이 파일입니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ````text 다음 줄(«R6a-Bob-M9S01 재제출 요청»)부터 닫는 ```` 직전 줄까지 · 바깥 울타리는 **백틱 네 개**(안의 견본이 백틱 세 개를 쓴다) · 울타리와 구분선은 넣지 않습니다.
5. 받는 법 = 1회차와 같음 — Bob 은 보고 글을 `$env:TEMP\R6a-Bob-M9S01_submit.md` 에 저장하고 채팅에는 두 줄만 냅니다. 받은 뒤 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다.

## 3. 붙여넣을 본문

---

````text
R6a-Bob-M9S01 재제출 요청 — 1회차(PR #146 · 7c5ac34) 판정: 반려(재제출). 같은 브랜치 ui/m9-s01-settings-home · 같은 PR #146 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 파일 하나(packages/ui_settings/test/settings_home_test.dart — 아래 상자 1 · M9S01-04 본문에 11줄 더하기)와
  보고 글 ①~⑤ 전체판(아래 «■ 보고 글 견본» 을 기계로 꺼내 자리표시자 4개만 채워 저장 파일로 — 채팅에 붙이지 않는다)뿐입니다.
🔴 그 파일 밖 0 · 그 파일의 다른 줄 0 · lib · PNG · 질문 파일 0(PNG 를 다시 찍지도 열지도 않는다) · amend·rebase·cherry-pick·reset·squash·강제 푸시 0 — 하나라도 어기면 반려입니다.
🔵 1회차 카드(docs/ai-context/send/R6a-Bob-M9S01.md · 이 브랜치의 판 = main 판에서 머리 한 줄만 다름)는 바탕으로 함께 읽어도 됩니다 — 이번에 필요한 규칙은 이 글에 다 옮겼고, 바꿀 자리는 아래 상자 1 뿐입니다.
🔴 이 글과 1회차 카드가 다르면 이 글이 이깁니다(1회차 카드의 0단계·새 브랜치·커밋 (1)~(4)·■ 제출 절차는 따르지 않는다). 그 밖의 카드·문서·프롬프트는 읽지 않습니다.
🔴 명령은 Windows PowerShell 5.1 에서 한 줄씩 · bash 줄은 & "C:\Program Files\Git\bin\bash.exe" … 꼴 그대로(그냥 bash 라고 치면 WSL 이 돈다).

■ 0단계 — 대상 확인 (저장소 뿌리 C:\Work\Bob\AutoAlphaQuant 에서 · 아무것도 읽기 전에)
이 글은 R6a 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
이번 대상 = PR #146 · 브랜치 ui/m9-s01-settings-home(커밋 7c5ac34)에 아래 상자 1 커밋 하나를 «더하는» 일입니다. 상자는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지 · main 은 엔진 커밋으로 앞섰지만 ui_settings 와 겹치지 않는다 — C4 확인).
🔴 지난 7개 커밋(7c5ac34 · 51bd84e · 967fd10 · 3b5191e · 407e50f · e755fa8 · f56beb0 — 순서·제목 그대로)은 고치지 않습니다(고치려 하면 반려). 커밋 꼴은 1회차 기록으로 남았고 이번에 손대지 않습니다.
  [Console]::OutputEncoding = [Text.Encoding]::UTF8   ← 🔴 먼저 한 번(한국어 출력·파일이 깨지지 않게)
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m9-s01-settings-home 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m9-s01-settings-home
     ← 🔴 git checkout main 금지
  git rev-parse --short HEAD    ← 7c5ac34 이면 정상 · 다르면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune
  git rev-parse --short origin/ui/m9-s01-settings-home   ← 7c5ac34 · 다르면 멈추고 출력을 채팅으로
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
        ← docs/ai-context/send/R6a-Bob-M9S01-재제출.md 줄이 있으면 정상(1회차 카드 docs/ai-context/send/R6a-Bob-M9S01.md 줄도 함께 있다 — 머리 «🔴 1회차 반려» · 상관없음).
          그 밖의 줄(README.md · _완료 · _대기)도 상관없습니다. 재제출 줄이 없으면 멈추고 채팅으로 — 기록 푸시보다 이 글이 먼저 왔습니다.
  git grep -c "contractVersion = '1.18.0'" origin/main -- packages/domain_contracts/lib/src/contract_version.dart
     ← «origin/main:packages/domain_contracts/lib/src/contract_version.dart:1» 이면 정상 · 출력이 없으면 멈추고 채팅으로
  Test-Path "C:\Program Files\Git\bin\bash.exe"   ← True · False 면 멈추고 채팅으로
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.
docs/ai-context/prompt_M9.md 는 열지 않습니다 · 1회차 카드는 읽기만(고치지 않는다 · 위 🔵 줄).

■ 규칙 요약 (이번에 필요한 것만 — 바탕 = 1회차 카드 «규칙 요약» · «■ 테스트 최소 목록» · ■ 제출 · 다르면 이 글이 이긴다)
· 이번에 고치는 곳 = packages/ui_settings/test/settings_home_test.dart 의 M9S01-04 testWidgets 본문 11줄(상자 1)뿐입니다.
· 🔴 고치면 반려: 그 밖의 전부 — packages/ui_settings/lib/** · 그 테스트 파일의 다른 줄 · 다른 테스트 · settings_fakes · PNG · pubspec · packages/ui_shell/** · packages/domain_contracts/** · apps/** · docs/** 전부(질문 파일 포함).
  🔴 그 밖의 파일이 하나라도 M(또는 ??)이면 git checkout -- <그 파일>(?? 는 지운다) 하고 멈춘 뒤 채팅으로(build/ 는 .gitignore 대상).
· 이번에 걸린 1회차 카드 글자: 테스트 최소 목록 M9S01-04(210~211행) «no_review = m9s01-review findsNothing · 양성 기준점 m9s01-chip · 칩 글자 [label] · 칩 Icon(m9s01-chip-level) == wantLevel(cs, ok) · opened == [] · ⓡ» ·
  🔴 예고 변이(221행) «칩 아이콘 고정» · «6» 이월 표(489행) «C4r15c-2 상태 아이콘 icon·color | M9S01-02 · M9S01-04».
  → 1회차 M9S01-04 는 칩 글자(shownTexts)만 보고 칩 아이콘·색을 보지 않았습니다. 칩 아이콘은 M9S01-02(home 표본 · 칩 = WATCH) 한 곳에서만 봅니다.
    그래서 칩 아이콘·색을 WATCH 로 고정한 화면(no_review 표본의 칩 = OK 인데 WATCH 로 그려짐)이 테스트 23개를 모두 통과했습니다(골든 6장 포함 · C4 가 직접 확인).
· 그대로인 것(바꾸지 않는다): lib 3파일 · 공용 2파일 끝 더하기 · settings_fakes · 비교기 2 · 골든 테스트 · PNG 6장 · 질문 파일 A1~A3 · 다른 테스트 단언 · 테스트 수(+16 · +6 · 전체 +23 — 단언 줄은 테스트를 늘리지 않는다) · 정적 출력 132줄(1회차와 같다).
· 1회차 C4 가 «기록만» 으로 둔 것(// pre 네 곳의 자리 · 사슬 dy 의 lessThanOrEqualTo · M9S01-08 fresh 양성 기준점 · 픽스처 최상위 final · 리뷰 행·묶음 머리 Row 정렬 · 커밋 꼴)은 이번에 고치지 않습니다 — 손대면 반려입니다.
· 도구: melos.bat run test · melos.bat run test:contracts 는 돌리지 않는다(lib·domain_contracts 무변경 · 1회차 몫은 C4 가 다시 돌려 SUCCESS) · 패키지 테스트는 packages/ui_settings 에서 flutter test 직접 · 명령 출력은 파일로 떠서 쓴다(화면에서 손으로 옮겨 적지 않는다).
· 보고 규칙(1회차 카드 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장 = 반려 · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문·라벨을 고치지 않는다 · 보고에는 코드·파일·출력에 실제로 있는 것만 적는다.

■ 잘된 것 — 그대로 유지하십시오
lib 3파일은 카드 «화면» 나무 · Key 12 · 받은 글자만 · 정렬·거르기·세기 0 · code·달·뷰어 판정 0 · tier 로 자물쇠 아이콘만 · 오래됨 판정 = 시계 주입 한 곳 · 쓰기 0 · S05 2줄 = 탭 콜백 안이었습니다.
공용 = labels +2/0 · 배럴 +2/0 · settings_fakes 81/0 · 비교기 복사본 = ui_shell 판과 머리 1행만 다름 · ui_settings 밖 변경 = 질문 파일 하나 · 반려 꼴 0 · C4 사람 grep 셋 0.
테스트 최소 목록의 다른 항목 단언 전부 · ⓡ 10 · ⓗ 7 · // pre 7(최소 목록 «전제» 7개와 하나씩 같음) · 51bd84e 의 경우 칸(staleTexts · retryMatcher) = if 를 감춘 것이 아니라 단언을 늘린 정당한 고침.
골든 6장(390×1120 · 390×844) · 배치·잘림 칸 = PNG · dy 1048 · 964 · 516(C4 가 이름마다 다시 잼 · 세 곳 같음) · flutter test 1 → +23 · analyze 0 · format 0 · domain_contracts +451 ~30 · 경계 실패 0 · 정적 132줄.
보고에서 맞은 곳 — 섹션 머리 · ① · ② 10항·괄호(카드 상자와 바이트 같음) · 정적 블록 · S05 · ⓡⓗ · «테스트 파일별:» 접두 0 · ③ 서술 3줄(«» 포함) · 골든 표 6행 · ④ 행 글자 · ⑤ · 끝 줄 · 거짓 주장 0.

■ 왜 반려인가 — 카드 / 실제 (C4 가 분리 worktree 에서 직접 확인 · strict 나눔 ② · ③ · 재량 없이 반려)
① C4Q-1 M9S01-04 칩 아이콘·색 단언 빠짐 (테스트 결함 · 예고 변이 통과)
   카드:  최소 목록 M9S01-04 «no_review … 칩 Icon(m9s01-chip-level) == wantLevel(cs, ok)» · 예고 변이 «칩 아이콘 고정» · «6» 표 C4r15c-2 «M9S01-02 · M9S01-04».
   실제:  settings_home_test.dart 에서 m9s01-chip-level 은 M9S01-02(home · 칩 WATCH) 한 곳뿐 · M9S01-04 는 칩 글자만 본다.
   변이:  lib/src/settings_home.dart 의 칩 Icon 두 자리 settingsLevelLook(cs, vm.statusChip.level) → settingsLevelLook(cs, UiLevel.watch)(아이콘만 · 색만 · 둘 다) = 1회차 판 «+23: All tests passed!»(골든 6장도 통과) ·
          상자 1 을 넣은 판 = «M9S01-04 annual review promotion no_review» 실패(+22 −1).
   고침:  상자 1(11줄) — 드라이런 판과 같은 꼴(두 경우 모두 c.v.statusChip.level 로 · if 0) · 보고 글 견본(커밋 줄 · 끝 줄 자리표시자)은 이미 고친 글자다.
함께 고칠 것 — 표기 C4Q-2(코드 울타리 백틱 6개 → 3개) · C4Q-3(④ 세 줄 끝 CR → LF)은 아래 «■ 보고 글 견본» 이 이미 고친 글자다 · 저장은 WriteAllText 한 꼴.
«재량 없이 반려» = 통합 담당이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것 (저장소 뿌리에서)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시)
  cd packages/ui_settings
  flutter test   ← 시작 기준: 끝 줄 «+23: All tests passed!»(1회차 그대로 · 앞 시각은 달라도 된다). 다르면 아무것도 고치지 말고 멈춘 뒤 끝 20줄을 채팅으로.
  cd ../..

■ 고칠 것 — 상자 1 (1회차 반려 · C4 2026-11-13) — 상자 글자 그대로 · 손으로 다시 짜지 않는다
   파일 = packages/ui_settings/test/settings_home_test.dart(저장소 뿌리 기준) · UTF-8(BOM 없이) · 줄 끝 LF 그대로 · 탭 문자 0 · 줄 끝 빈칸 0.
   🔴 줄을 «더한다» — 기존 줄은 한 글자도 바꾸지 않는다(기준 네 줄 · 그 아래 «await c.flow(tester);» 줄 포함) · 상자 머리·끝 줄(┌── · └──)은 파일에 넣지 않는다.
   🔴 넣는 줄의 기대값은 c.v.statusChip.level 이다(경우 칸의 표본 — home = WATCH · no_review = OK · 숫자·상수로 쓰지 않는다 · if 0 · 드라이런 판 글자).
  상자 1 — M9S01-04 본문(265행 testWidgets('M9S01-04 annual review promotion ${c.name}' 아래)의 칩 글자 단언 바로 아래 · 291행 «await c.flow(tester);» 바로 위
      ┌── 이 네 줄 바로 아래에(287~290행 · 앞 빈칸 6칸 · 8칸 · 8칸 · 6칸 · 바꾸지 않는다 · 파일에서 «c.chipTexts,» 는 이 한 곳뿐)
      expect(
        shownTexts(tester, find.byKey(const Key('m9s01-chip'))),
        c.chipTexts,
      );
      └──
      ┌── 이 열한 줄을 넣는다(새 291~301행 · 앞 빈칸 = 줄마다 상자 글자 그대로 6칸 또는 8칸 · 10칸(.colorScheme 줄))
      final ColorScheme cs = Theme.of(tester.element(find.byType(SettingsHome)))
          .colorScheme;
      final Icon chipIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s01-chip-level')),
      );
      final (IconData wantIcon, Color wantColor) = wantLevel(
        cs,
        c.v.statusChip.level,
      );
      expect(chipIcon.icon, wantIcon);
      expect(chipIcon.color, wantColor);
      └──
      ┌── 그 아래 줄(새 302행 · 그대로)
      await c.flow(tester);
      └──

고친 뒤 확인(저장소 뿌리에서 · 커밋하기 전 · 고치지 않고 보기만):
  git status --short   ← 🔴 정확히 한 줄 « M packages/ui_settings/test/settings_home_test.dart» · 다른 줄이 있으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
  git diff --stat      ← 마지막 줄 « 1 file changed, 11 insertions(+)»(빼기 0 · 다르면 상자와 다시 대조)
  git hash-object packages/ui_settings/test/settings_home_test.dart   ← 60380fc0eba0d66b4c9f681e5cec0e96cbdb49f2(C4 수정안 파일의 git 해시 · 다르면 상자와 다시 대조 — BOM · 빈칸 수 · 줄 끝 빈칸에 바뀐다(CRLF 는 git 이 LF 로 바꿔 넣어 해시가 같다))
  git grep -c -F "m9s01-chip-level" -- packages/ui_settings/test/settings_home_test.dart   ← «packages/ui_settings/test/settings_home_test.dart:2»(M9S01-02 하나 · M9S01-04 하나)
  git grep -c -F "// pre" -- packages/ui_settings/test/settings_home_test.dart   ← «packages/ui_settings/test/settings_home_test.dart:7»(1회차 그대로)
  cd packages/ui_settings
  dart format --output=none --set-exit-if-changed lib test   ← «(0 changed)» · 바뀐 파일이 1 이상이면 멈추고 출력을 채팅으로(format:fix 로 고치지 않는다 — 상자 글자가 format 판이다)
  flutter analyze --fatal-infos   ← «No issues found!» · 아니면 멈추고 출력을 채팅으로
  cd ../..

■ 커밋 · 사전검사 ① · 푸시 (위 확인이 기대와 같은 뒤 · 저장소 뿌리에서)
  git add packages/ui_settings/test/settings_home_test.dart   ← 🔴 이 한 파일만 · git add . 금지
  git commit -m "[M9] R6a (6) C4 반려 수정 — M9S01-04 칩 아이콘 단언"   ← 아래 «커밋 제목» 상자 글자 그대로
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M9] R6a (6) C4 반려 수정 — M9S01-04 칩 아이콘 단언
      └── 커밋 제목 복사 끝(이 줄 앞까지)
  git show --stat --format=%s HEAD   ← 첫 줄 = 위 제목 · 파일 줄 «packages/ui_settings/test/settings_home_test.dart | 11 +++++++++++» 하나 · 끝 줄 « 1 file changed, 11 insertions(+)»
  git rev-parse "HEAD^{tree}"        ← 2a5b3d36a3f3d78c96fe0064be00a7264734753a(= C4 수정안 트리 · 다르면 푸시하지 말고 멈춘 뒤 채팅으로)
  git log --oneline origin/main..HEAD   ← 🔵 origin/main 이 엔진 커밋으로 앞섰어도 8줄 · 맨 위 = 방금 커밋 · 그 아래 7줄 = 7c5ac34 … f56beb0(그대로 · 다르면 멈춤)
   🔴 지난 커밋을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.
  dart tool/precheck.dart --base origin/main --collection-if 0
     ← 끝 줄 «── 결과: 🔴 0 · 🟡 0 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)»(C4 시험) · 🔴 가 하나라도 나오면 푸시하지 않고 고치지도 않는다 — 출력 전부를 채팅으로.
  git status --short   ← 🔴 비어 있어야 푸시한다
  git push origin ui/m9-s01-settings-home   ← 같은 브랜치 → PR #146 자동 반영 · 새 PR·라벨·강제 푸시·rebase·main 병합 금지
  git rev-parse --short origin/ui/m9-s01-settings-home   ← 방금 커밋(git rev-parse --short HEAD 와 같은 해시)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다.

■ 테스트 다시 돌리기 (푸시한 그 커밋 위 · packages/ui_settings 에서 · 결과는 1회차와 같은 수 · 아래 «보고 글 만들기» 가 이 파일들을 읽는다 — 지우지 않는다)
  cd packages/ui_settings
  flutter test test/settings_home_test.dart | Out-File -Encoding utf8 $env:TEMP\r6a_t1.txt
  flutter test test/golden/m9s01_golden_test.dart | Out-File -Encoding utf8 $env:TEMP\r6a_t2.txt
  flutter test | Out-File -Encoding utf8 $env:TEMP\r6a_t3.txt
     ← 🔴 골든은 --update-goldens 없이
  1..3 | ForEach-Object { Get-Content -Encoding UTF8 "$env:TEMP\r6a_t$_.txt" | Select-Object -Last 1 }
     ← 세 줄 «… +16: All tests passed!» · «… +6: All tests passed!» · «… +23: All tests passed!»(앞 시각은 달라도 된다 · 1회차와 같은 수)
  (수가 다르거나 실패가 있으면 멈춘 뒤 그 파일 끝 20줄을 채팅으로)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건은 이 카드와 무관 — 그대로 둔다(실패가 있으면 멈추고 출력을 채팅으로)

■ 정적 묶음 — 1회차 카드 235~271행 37줄(main 의 send/R6a-Bob-M9S01.md · 머리 한 줄 표기만 바뀌어 줄 번호 그대로)을 파일로 꺼내 Git Bash 로 돌린다 · 🔴 터미널에 붙여 넣어 돌리지 않는다
  (git status 가 빈 채 · packages/ui_settings 에서)
  cd packages/ui_settings
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R6a-Bob-M9S01.md' | sed -n '235,271p' > ../../build/r6a_static.sh"
  git hash-object ../../build/r6a_static.sh   ← be8798835dfd4407547c5e638e30c43b222a0e7f(1회차와 같은 37줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r6a_static.sh > ../../build/r6a_static_out.txt"
  Select-String -Path ..\..\build\r6a_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r6a_static_out.txt).Count   ← 132(EXIT 줄 37 포함)
  git hash-object ../../build/r6a_static_out.txt       ← d9b7fb3586c3c46132f816fdd3afe588428ebcb3(= 1회차 보고 ② 의 «정적 묶음 출력» 블록 132줄과 같은 바이트 = 아래 견본 블록 ·
                                                          상자 1 은 정적 출력을 한 줄도 바꾸지 않는다(C4 시험) · 같으면 견본 블록을 그대로 쓴다 · 다르면 제출하지 말고 출력 파일 전부를 채팅으로 — 블록을 손으로 고치지 않는다)
  cd ../..

■ 보고 글 만들기 — 견본(아래 «■ 보고 글 견본» · 이 글의 main 판 209~440행)을 기계로 꺼내 자리표시자 4개만 채운다 · 손으로 옮겨 쓰지 않는다 · 저장소 뿌리에서
  [Console]::OutputEncoding = [Text.Encoding]::UTF8
     ← 🔴 이 창에서 다시 한 번(0단계 창과 같아도) — git show · git diff 출력을 UTF-8 로 읽게 한다 · Out-String 으로 받아 붙이지 않는다 · 질문 파일 줄은 Get-Content -Encoding UTF8 로 읽는다 · 견본 ④ 는 이미 LF 글자다 — 손대지 않는다
  $tpl = (git show 'origin/main:docs/ai-context/send/R6a-Bob-M9S01-재제출.md' | Select-Object -Skip 208 -First 232) -join "`n"
     ← 🔴 -join "`n" 그대로(빼면 줄이 한 줄로 이어 붙는다)
  $h8 = git rev-parse --short HEAD
  $t = 1..3 | ForEach-Object { Get-Content -Encoding UTF8 "$env:TEMP\r6a_t$_.txt" | Select-Object -Last 1 }
  $out = $tpl.Replace('<H8>', $h8).Replace('<T_H>', $t[0]).Replace('<T_G>', $t[1]).Replace('<ALL_END>', $t[2])
  [IO.File]::WriteAllText("$env:TEMP\R6a-Bob-M9S01_submit.md", $out + "`n", (New-Object Text.UTF8Encoding($false)))
     ← 🔴 이 꼴 그대로(BOM 0 · CR 0 · 글자 그대로) · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다(1회차 ④ 세 줄 끝에 CR 이 붙은 자리)
  (Get-Content -Encoding UTF8 $env:TEMP\R6a-Bob-M9S01_submit.md).Count   ← 232
  Select-String -Path $env:TEMP\R6a-Bob-M9S01_submit.md -Pattern '<H8>|<T_H>|<T_G>|<ALL_END>'   ← 출력 없음(남은 자리표시자 0)
  Get-Content -Encoding UTF8 $env:TEMP\R6a-Bob-M9S01_submit.md -TotalCount 1   ← «## ① 구현한 화면 ID · 바뀐 파일 · 커밋»
  ([IO.File]::ReadAllText("$env:TEMP\R6a-Bob-M9S01_submit.md").Split([char]13).Count - 1)   ← 0(🔴 CR 0 자기 확인 · 1 이상이면 저장 꼴이 틀림 — 내지 말고 채팅으로)
  (Get-Content -Encoding UTF8 $env:TEMP\R6a-Bob-M9S01_submit.md | Select-String -Pattern '[\uFFFD\u4E00-\u9FFF]' | Measure-Object).Count   ← 0(🔴 깨진 글자 0 자기 확인 — 견본에는 한자도 U+FFFD 도 없다 · 1 이상이면 내지 말고 채팅으로)
  (Get-Content -Encoding UTF8 $env:TEMP\R6a-Bob-M9S01_submit.md | Select-String -SimpleMatch '| 추측 | 측정:' | Measure-Object).Count   ← 3(④ 세 줄)
  git -c core.quotePath=false diff --name-status origin/main...HEAD   ← 17줄 = 견본 «바뀐 파일:» 블록 17줄과 같은 글자(1회차와 같음 · 다르면 멈추고 채팅으로)
  git log --oneline origin/main..HEAD   ← 8줄 = 견본 «커밋 목록:» 블록(맨 위 줄은 채운 해시) 8줄과 같은 글자(다르면 멈추고 채팅으로)
  git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/M9S01_questions.md | Select-String -Pattern '^\+\|'
     ← 세 줄 = 견본 «④ 질문 목록» 블록 세 줄과 같은 글자(1회차 커밋 그대로 · 다르면 멈추고 채팅으로)
  🔴 자기 대조 — dy 는 1회차에 이름마다 --plain-name 으로 잰 값이고 lib·PNG 를 고치지 않았으므로 그대로다 · 저장 파일 ③ 골든 표 6행 dy 칸 · ④ A1~A3 · 커밋된 질문 파일(git show HEAD:docs/ai-context/inbox/M9S01_questions.md 의 A1~A3 행)
     세 곳이 1048.0 · 1048.0 · 964.0 · 964.0 · 516.0 · 516.0(차례 = m9s01_home light · dark · m9s01_no_review · m9s01_viewer)과 같은지 눈으로 대조 — 하나라도 다르면 내지 말고 채팅으로
  사전검사 ②(저장소 뿌리):
  dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R6a-Bob-M9S01_submit.md --golden-prefix m9s01_ --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r6a_pre2.txt; Get-Content -Encoding UTF8 $env:TEMP\r6a_pre2.txt | Select-Object -Last 1
     ← 끝 줄 «── 결과: 🔴 0 · 🟡 1 — …»(C4 시험 = 1회차와 같은 🟡 G1 · PNG 를 열지 않는다 · 칸을 고치지 않는다) · 🔴 가 있거나 🟡 수가 이와 다르면 내지 말고 출력 전부를 채팅으로.
  채팅 답 = 두 줄뿐: «R6a-Bob-M9S01 재제출 글 저장했음: <(Resolve-Path $env:TEMP\R6a-Bob-M9S01_submit.md).Path 출력>» · 사전검사 ② 끝 줄.

■ 보고 글 견본 (다음 줄부터 · 232줄 · 자리표시자 = <H8> · <T_H> · <T_G> · <ALL_END>)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋

화면 ID: M9 S01 — 설정 홈(SettingsHome())

바뀐 파일:
```
M	docs/ai-context/inbox/M9S01_questions.md
M	packages/ui_settings/lib/l10n/labels.dart
A	packages/ui_settings/lib/src/common/settings_common.dart
A	packages/ui_settings/lib/src/settings_home.dart
A	packages/ui_settings/lib/src/settings_providers.dart
M	packages/ui_settings/lib/ui_settings.dart
A	packages/ui_settings/test/flutter_test_config.dart
A	packages/ui_settings/test/golden/goldens/m9s01_home_dark.png
A	packages/ui_settings/test/golden/goldens/m9s01_home_light.png
A	packages/ui_settings/test/golden/goldens/m9s01_no_review_dark.png
A	packages/ui_settings/test/golden/goldens/m9s01_no_review_light.png
A	packages/ui_settings/test/golden/goldens/m9s01_viewer_dark.png
A	packages/ui_settings/test/golden/goldens/m9s01_viewer_light.png
A	packages/ui_settings/test/golden/m9s01_golden_test.dart
A	packages/ui_settings/test/golden/shift_tolerant_compare.dart
A	packages/ui_settings/test/settings_fakes.dart
A	packages/ui_settings/test/settings_home_test.dart
```

커밋 목록:
```
<H8> [M9] R6a (6) C4 반려 수정 — M9S01-04 칩 아이콘 단언
7c5ac341 [M9] R6a (5) format:fix settings_home_test.dart
51bd84e4 [M9] R6a (5) 사전검사 T1 — M9S01-08 staleTexts 칸 · M9S01-09 retryMatcher 칸
967fd100 [M9] R6a (5) 주석 금지 낱말 — S05 settingsLinkOpenerProvider · T12 throw UnimplementedError(
3b5191e1 [M9] R6a (4) format · 질문
407e50f3 [M9] R6a (3) 비교기 · 골든 m9s01_* 6장
e755fa8b [M9] R6a (2) S01 테스트
f56beb09 [M9] R6a (1) S01 설정 홈 화면 · 공용 조각 · 주입 · 라벨
```

## ② 자체 점검 12항 · 정적 묶음 · 명령 출력

 1. `ui_settings`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 T16 — 허용 밖 import 0줄 · T36 입력·인쇄·공유·생체 패키지 0 · pubspec 무변경(T29))
 2. 화면 코드에 산술이 없는가 — 합계·잔여일·비율·TTL·D-day 전부 뷰모델 값인가 [x] (산술 = null 여부 · UiLevel switch 하나(T09) · SettingTier switch 하나(T10) · 오래됨 판정 식 한 줄(W-01 꼴) · 묶음·카드·주의 수 세기 0(T11) · 수치 리터럴 0(T18·T19))
 3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (정적 라벨은 `labels.dart` 한 곳인가) [x] (한국어 리터럴 0(T17) · 정적 라벨 = labels.dart 2개(T13) · 칩·묶음·카드·주의·asOf 글자 = 받은 문자열 그대로(M9S01-11))
 4. 평가손익·수익률·평가액이 없는가 (S04 백테스트 카드만 예외이고 그것도 뷰모델 문자열인가) [x] (손익 낱말 0(T23) · 칩·카드 글자 = 엔진 문자열 그대로(M9S01-11))
 5. 시크릿·계좌 전체번호가 재표시·복사·로그되지 않고 `FLAG_SECURE`가 켜지고 나갈 때 꺼지는가 [x] (이 카드 범위 밖(시크릿 화면 = S02 · R7) · 입력 위젯 0(T36))
 6. `SecretField`를 삽입만 했는가 / 자체 입력 위젯·임시 저장·확인 필드를 만들지 않았는가 [x] (이 카드 범위 밖(SecretField = S02 · R7) · 자체 입력 위젯 0(T36))
 7. «적용»류가 `SettingsActions.run` 1회 + `handoffRoute` 이동으로 끝나는가 (게이트 UI 자체 구현 없음) [x] (이 카드 범위 밖(S01 = 쓰기 0 · SettingsActions 0 — T07) · 탭 = 받은 링크 열기뿐(S05))
 8. S04가 자동 정규화하지 않는가 / SAT 슬라이더가 숨겨지는가 / 금 상한이 config 키에서 오는가 [x] (이 카드 범위 밖(S04 = R8))
 9. 뷰어 빌드에 폰 전용 라우트가 없는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] (폰 전용 행 = 엔진이 뷰어 VM 에서 뺌(M9S01-07 · 화면 판정 0) · 라우트 본문 = 조립 앱 레지스트리(이 카드 범위 밖) · 앱 잠금·킬스위치 = 이 카드 범위 밖(M5))
10. DND UI가 P0를 끌 수 있게 보이지 않는가 / 미확정 상수(골든벡터 총계 등)를 화면에 적지 않았는가 [x] (DND UI = 이 카드 범위 밖(S11) · 미확정 상수 0(T18 · 칩 글자 = 엔진 문자열))

10항 줄 수:
```
10
```

정적 묶음 출력:
```
## T01 new test files hangul 0 (comment lines only)
EXIT:1
## T02 test names ASCII
EXIT:1
## T03 testWidgets and test lines
test/golden/m9s01_golden_test.dart:1
test/settings_home_test.dart:11
EXIT:0
## T04 link literals in lib 0
EXIT:1
## S05 opener lines (each must be inside a tap callback)
lib/src/settings_home.dart:90:                  .read(settingsLinkOpenerProvider)
lib/src/settings_home.dart:129:                      ref.read(settingsLinkOpenerProvider).open(card.route!);
EXIT:0
## T06 source lines (1)
lib/src/settings_home.dart:20:      (Ref ref) => ref.watch(settingsRepositoryProvider).watchHome(),
EXIT:0
## T07 commands and other sources 0
EXIT:1
## T08 comparator copies (1 line diff + 0)
diff --git a/../ui_shell/test/flutter_test_config.dart b/test/flutter_test_config.dart
index 8d63aa7..88e2198 100644
--- a/../ui_shell/test/flutter_test_config.dart
+++ b/test/flutter_test_config.dart
@@ -1,4 +1,4 @@
-// flutter_test_config.dart — ui_shell 위젯 테스트 공통 설정 (C-2 위젯 골든 하네스 · M2 소유)
+// flutter_test_config.dart — ui_settings 위젯 테스트 공통 설정 (C-2 위젯 골든 하네스 · M2 소유)
 //
 // 무엇을 하나: `flutter test` 가 이 패키지의 모든 테스트 파일 앞에서 이 파일의
 //   `testExecutable` 을 먼저 부른다(Flutter 규약 — test/ 아래 같은 이름 파일 자동 탐지).
EXIT:0
## T09 UiLevel arms (5)
lib/src/common/settings_common.dart:17:  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
lib/src/common/settings_common.dart:18:  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
lib/src/common/settings_common.dart:19:  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
lib/src/common/settings_common.dart:20:  UiLevel.act => (Icons.error_outline, cs.secondary),
lib/src/common/settings_common.dart:21:  UiLevel.blocked => (Icons.block, cs.error),
EXIT:0
## T10 SettingTier arms (3)
lib/src/settings_home.dart:142:  SettingTier.general => null,
lib/src/settings_home.dart:143:  SettingTier.operational => Icons.lock_outline,
lib/src/settings_home.dart:144:  SettingTier.rule => Icons.lock_outline,
EXIT:0
## T11 forbidden words in new lib files 0
EXIT:1
## T12 providers default throw (3)
lib/src/settings_providers.dart:12:      (Ref ref) => throw UnimplementedError(
lib/src/settings_providers.dart:19:      throw UnimplementedError('settingsClockProvider must be overridden'),
lib/src/settings_providers.dart:24:      (Ref ref) => throw UnimplementedError(
EXIT:0
## T13 settings labels
lib/l10n/labels.dart:2
EXIT:0
## T14 barrel exports
lib/ui_settings.dart:13:export 'l10n/labels.dart';
lib/ui_settings.dart:14:export 'src/settings_home.dart';
lib/ui_settings.dart:15:export 'src/settings_providers.dart';
EXIT:0
## T15 settings providers
lib/src/settings_providers.dart:10:final Provider<SettingsRepository> settingsRepositoryProvider =
lib/src/settings_providers.dart:17:final Provider<Clock> settingsClockProvider = Provider<Clock>(
lib/src/settings_providers.dart:22:final Provider<AppLinkOpener> settingsLinkOpenerProvider =
EXIT:0
## T16 imports outside the three packages 0
EXIT:1
## T17 hangul literals in lib except labels 0
EXIT:1
## T18 figures 0
EXIT:1
## T19 decimal and percent literals 0
EXIT:1
## T20 R lines (retry findsNothing)
test/settings_home_test.dart:10
EXIT:0
## T21 H lines (hasLength)
test/settings_home_test.dart:7
EXIT:0
## T22 m9s01 key names
lib/src/settings_home.dart:35:m9s01-fail
lib/src/settings_home.dart:45:m9s01-loading
lib/src/settings_home.dart:58:m9s01-stale
lib/src/settings_home.dart:60:m9s01-chip
lib/src/settings_home.dart:67:m9s01-chip-level
lib/src/settings_home.dart:87:m9s01-review
lib/src/settings_home.dart:106:m9s01-group
lib/src/settings_home.dart:114:m9s01-lock
lib/src/settings_home.dart:121:m9s01-card
lib/src/settings_home.dart:133:m9s01-asof
lib/src/settings_home.dart:178:m9s01-level
lib/src/settings_home.dart:194:m9s01-attention
EXIT:0
## T23 banned vocabulary in code 0
EXIT:1
## T24 Colors files 0
EXIT:1
## T25 rich text and trimming 0
EXIT:1
## T26 autoDispose 0
EXIT:1
## T27 Scaffold AppBar Navigator in new files 0
EXIT:1
## T28 common pieces exported 0
EXIT:1
## T29 shared files add-only and frozen files (numstat)
2	0	packages/ui_settings/lib/l10n/labels.dart
2	0	packages/ui_settings/lib/ui_settings.dart
81	0	packages/ui_settings/test/settings_fakes.dart
EXIT:0
## T30 implements in new tests 0
EXIT:1
## T31 copyWith in tests 0
EXIT:1
## T32 collection-if in tests 0
EXIT:1
## T33 golden files
A	packages/ui_settings/test/golden/goldens/m9s01_home_dark.png
A	packages/ui_settings/test/golden/goldens/m9s01_home_light.png
A	packages/ui_settings/test/golden/goldens/m9s01_no_review_dark.png
A	packages/ui_settings/test/golden/goldens/m9s01_no_review_light.png
A	packages/ui_settings/test/golden/goldens/m9s01_viewer_dark.png
A	packages/ui_settings/test/golden/goldens/m9s01_viewer_light.png
EXIT:0
## T34 precondition marks (pre)
test/settings_home_test.dart:7
EXIT:0
## T35 bare takeException 0
EXIT:1
## T36 input print share biometric widgets in new files 0
EXIT:1
## T37 golden PNG m9s01 (6)
6
EXIT:0
```

S05 결과:
lib/src/settings_home.dart:90 — 탭 콜백 안
lib/src/settings_home.dart:129 — 탭 콜백 안

ⓡ = T20 출력:
test/settings_home_test.dart:10
ⓗ = T21 출력:
test/settings_home_test.dart:7

테스트 파일별:
<T_H>
<T_G>

## ③ 스크린샷 서술 · 골든 표

«M9 S01 정상» = ListView → SettingsStaleBanner(Key('m9s01-stale'))(있을 때) → Key('m9s01-chip')(안에 Key('m9s01-chip-level')) → Key('m9s01-review')(있을 때) → ValueKey<String>('m9s01-group-$g')(안에 ValueKey<String>('m9s01-lock-$g') — 있을 때) → ValueKey<String>('m9s01-card-$g-$c')(안에 ValueKey<String>('m9s01-level-$g-$c') · ValueKey<String>('m9s01-attention-$g-$c') — 있을 때) → SettingsAsOfLine(Key('m9s01-asof'))
«M9 S01 뷰어» = ListView → SettingsStaleBanner(Key('m9s01-stale'))(있을 때) → Key('m9s01-chip')(안에 Key('m9s01-chip-level')) → Key('m9s01-review')(있을 때) → ValueKey<String>('m9s01-group-$g')(안에 ValueKey<String>('m9s01-lock-$g') — 있을 때) → ValueKey<String>('m9s01-card-$g-$c')(안에 ValueKey<String>('m9s01-level-$g-$c') · ValueKey<String>('m9s01-attention-$g-$c') — 있을 때) → SettingsAsOfLine(Key('m9s01-asof'))
«M9 S01 로딩·에러» = SettingsSkeleton(Key('m9s01-loading')) · SettingsErrorView(Key('m9s01-fail'))

| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |
|---|---|---|---|---|---|
| m9s01_home light | settings_home.json | 없음 | 390×1120 | 1048.0 | 아이콘 · 글자 3줄 → 글자 1줄 · 아이콘 → 글자 1줄 → 아이콘 · 글자 3줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 3줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 — 잘림 없음 |
| m9s01_home dark | settings_home.json | 없음 | 390×1120 | 1048.0 | 아이콘 · 글자 3줄 → 글자 1줄 · 아이콘 → 글자 1줄 → 아이콘 · 글자 3줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 3줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 — 잘림 없음 |
| m9s01_no_review light | settings_home_no_review.json | 없음 | 390×1120 | 964.0 | 아이콘 · 글자 1줄 → 글자 1줄 → 아이콘 · 글자 3줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 3줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 — 잘림 없음 |
| m9s01_no_review dark | settings_home_no_review.json | 없음 | 390×1120 | 964.0 | 아이콘 · 글자 1줄 → 글자 1줄 → 아이콘 · 글자 3줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 3줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 — 잘림 없음 |
| m9s01_viewer light | settings_home_viewer.json | 없음 | 390×844 | 516.0 | 아이콘 · 글자 3줄 → 글자 1줄 · 아이콘 → 글자 1줄 → 아이콘 · 글자 3줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 — 잘림 없음 |
| m9s01_viewer dark | settings_home_viewer.json | 없음 | 390×844 | 516.0 | 아이콘 · 글자 3줄 → 글자 1줄 · 아이콘 → 글자 1줄 → 아이콘 · 글자 3줄 · 아이콘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 둘 → 글자 1줄 · 아이콘 → 아이콘 · 글자 2줄 · 아이콘 → 글자 1줄 — 잘림 없음 |

## ④ 질문 목록

```
+| A1 | R6a-Bob-M9S01 | 추측 | 측정: m9s01_home dy 실측값 (light=1048.0, dark=1048.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
+| A2 | R6a-Bob-M9S01 | 추측 | 측정: m9s01_no_review dy 실측값 (light=964.0, dark=964.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
+| A3 | R6a-Bob-M9S01 | 추측 | 측정: m9s01_viewer dy 실측값 (light=516.0, dark=516.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
```

## ⑤ 추측한 것 목록

없음

flutter test: 시작 기준 1 → 끝 <ALL_END>
■ 보고 글 견본 끝(이 줄 앞까지)
(채팅 답 = 위 두 줄뿐 · 보고 글 전문은 저장 파일에만)
````

---

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R6a-Bob-M9S01 재제출: PR #146 에 푸시됨 — 병합 검사해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R6a-Bob-M9S01_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계 · 상자 1 확인에서 멈췄다면 `R6a-Bob-M9S01 재제출 <단계>에서 멈춤 — 확인해줘` + 출력.

## 5. C4 2회차 대조 기대(통합 담당 몫 · Bob 에게 보내지 않음)

- 새 커밋 1 · 파일 1(`packages/ui_settings/test/settings_home_test.dart` +11/−0 · M9S01-04 칩 글자 단언 바로 아래) · blob `60380fc0eba0d66b4c9f681e5cec0e96cbdb49f2` · `HEAD^{tree}` `2a5b3d36a3f3d78c96fe0064be00a7264734753a` · 지난 7커밋 해시 그대로.
- 저장 파일 ↔ 견본: 다른 곳 = 자리표시자 4 자리뿐(커밋 해시 · 시각 칸) · UTF-8 · BOM 0 · CR 0 · 232줄 · 울타리 백틱 3개 10줄.
- 정적 출력 blob `d9b7fb3`(1회차와 같음) · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0 · 🟡 1 · `flutter test` +16 · +6 · 전체 +23 · C4 사람 grep 셋 0.
- C4 2회차 변이 갈래: 칩 아이콘 고정(WATCH · 아이콘만 · 색만 · 둘 다) = M9S01-04 no_review 가 잡는지 · 그 밖 예고 변이는 1회차 KILLED 그대로인지(lib 무변경) · dy 를 `lessThan(0)` 임시 + `--plain-name` 으로 이름마다 다시 잰다(기대 1048 · 964 · 516).
- 병합 때 PR 본문(재제출 글) ① 커밋 목록 아래 «C4 정정» 줄 = **0**(발주자 결정 2026-11-13 ② 커밋 꼴 C4Q-4 = 기록만 · 커밋 (4) `3b5191e` 의 analyze 몫(settings_fakes 쓰이지 않는 import 2줄 삭제 · 지역 record 5곳 final) · (5) 셋 = 카드 «(5) 하나로» 밖 · squash 영향 0 = C4 보고 기록만 · 이월 C4r6a-7).
- 병합 기록 = C4 보고 §7-M(원 카드 + 이 패킷을 함께 `_완료/` · `ui_settings/README` 낡은 줄 · golden README «🆕 R6» 절 R6a 병합본 실측 · 질문 A1~A3 ✅ · R6b 조립을 연다).
