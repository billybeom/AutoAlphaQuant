# 발송 패킷 R14b-Bob-W01 — 재제출 (1회차 반려 · 2026-10-31)

> ▶ **보낼 수 있음(「푸시해」 뒤)**(2026-10-31 · C4 R14b 1회차 반려 기록 · 이 파일이 GitHub `main` 의 `send/` 에 있고 PR #88 «Conversation» 에 C4 반려 댓글(«C4 병합 검사 1회차 판정 — 🔴 반려(재제출) · R14b-Bob-W01 · head `d122061`»)이 보이면 보낸다 · 댓글은 「푸시해」 때 Claude 가 게시(번호 = 게시 뒤 기록) · Bob **새 대화** · 같은 브랜치 `ui/m8-w01-watchdog` · 같은 PR #88 · 그 밖의 선행 없음 · 🔵 `main` 계약 `'1.15.0'` 전제(엔진 세션이 계약을 먼저 올리면 Bob 이 0단계에서 멈춘다 — 통합 담당이 기대를 다시 본다) · `send/README.md` 배지 규칙).
> 만든 날 2026-10-31 · 1회차(PR #88 · 브랜치 `ui/m8-w01-watchdog` · 커밋 `d122061` · 밑동 `36d69e2` · 커밋 4 · CI run 41158945324 3/3)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-31 · 모두 권고): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #88 · 커밋 1개 · 바꿀 자리 3(상자 1~3) · 보고 글 ①~⑤ 전체판 = 저장 파일 · Bob 새 대화 · 자급 패킷 · 저장 파일 UTF-8·줄바꿈 보존 명령 안내 포함) ② 테스트 수 +8/+178 = 기록만(C4H-11 · 경우·단언 빠짐 0) · «까닭:» 줄 누락 = ① 표기(C4H-2) ③ 카드 구멍 C4H-7~9(X3 오래됨+휴장 · X7 배너 차례 · X10 값 쥔 채 다시 읽기) = R14 test-only PR 몫(C4r14b-4 · R14b 병합 뒤 · 통합 담당 — 이 재제출에 넣지 않는다) ④ 이월 부록 C4r14b-1·2·3·5(설계 12 §3 «R14b C4 이월 부록»). 판정 근거 = C4 보고 §0(설계 저장소 `10_리뷰/2026-10-31_R14b_C4_보고.md`) — 1회차 카드 strict 나눔(카드 «보고 규칙» 146~148행). [가] ② 테스트 **C4H-1**(경미 · 실효 0) W01-05 흐름 칸 nullable + else 없는 if(`watchdog_board_test.dart` 245·257·271·283·366~368행 · 카드 232·111·112·180행 · 선례 R3 C3-1 · R13a C4s-3 · R13b C4h-3 · R12d C12d-1). [나] 표기 C4H-2~4 = 아래 «■ 보고 글 견본» 이 고쳤다(«까닭:» 줄 · ④ «+|» 3줄 · ① 줄 나눔·글자 깨짐).
> 고치는 것 = **파일 하나**(`packages/ui_shell/test/watchdog_board_test.dart` — 아래 상자 1~3 · +5/−7 · 테스트 수 변화 0) **+ 보고 글 ①~⑤ 전체판을 저장 파일로**(견본 = 아래 «■ 보고 글 견본» · 자리표시자 4개만 명령 출력으로 · 견본은 이 파일의 `main` 판에서 기계로 꺼내 PowerShell 로 채운다 — 손으로 옮겨 쓰지 않는다). lib·PNG·질문 파일·다른 테스트 0 · PR 본문·라벨 0.
> 🔴 **PNG 열람 0** — 이 재제출은 PNG 를 바꾸지도 다시 찍지도 열지도 않는다(`--update-goldens` 0 · `golden:approved` 불필요 · 골든 표 6행 = 1회차 Bob 칸 그대로 = C4 갈래 G 확인 칸).
> 🔴 **Git Bash 는 경로로 부른다**(이 PC 의 PowerShell 에서 `bash` 는 WSL) — 이 패킷의 bash 줄은 전부 `& "C:\Program Files\Git\bin\bash.exe" -c "…"` 다. 🔵 «■ 보고 글 만들기» 의 꺼내기 줄은 한글 경로(`-재제출.md`)를 쓴다 — R5a 재제출이 같은 꼴(`git show 'origin/main:…-재제출.md'`)로 돌았다 · 조립 때 통합 담당이 PowerShell 5.1 에서 두 꺼내기 줄을 기록 가지 판으로 실제로 돌려 해시를 확인했다(아래 «조립 확인»).
> 🔴 **저장 파일은 UTF-8(BOM 없이) · 줄바꿈 그대로**(발주자 결정 ① · C4H-4 · C4r14b-5) — 1회차 ① 은 «바뀐 파일:» 12줄과 «커밋 목록:» 4줄이 각각 한 줄로 이어 붙었고 커밋 제목이 깨졌다(UTF-8 을 CP949 로 읽은 꼴 · 내용은 사실). 까닭(C4 가 글자 꼴로 짚은 것): ⓐ Windows PowerShell 5.1 은 git·flutter 출력을 콘솔 인코딩(한국어 Windows = CP949)으로 읽는다 → UTF-8 한글이 깨진다 — 먼저 `[Console]::OutputEncoding = [Text.Encoding]::UTF8` ⓑ 여러 줄 출력은 배열이라 문자열 안에 `"$x"` 로 넣으면 줄바꿈이 빈칸으로 바뀌어 한 줄이 된다 — `-join "`n"` 으로 잇는다 ⓒ 저장은 `[IO.File]::WriteAllText("$env:TEMP\R14b-Bob-W01_submit.md", $out + "`n", (New-Object Text.UTF8Encoding($false)))` 한 꼴(BOM 0 · 줄바꿈·글자 그대로) — 저장 파일을 `Set-Content`(5.1 기본 = ANSI·CP949 — 한글 깨짐) · `Out-File`·`>`(5.1 = BOM 이 붙거나 UTF-16) · 화면 복사로 쓰지 않는다. 테스트 출력 사본(`$env:TEMP\r14b_t1~3.txt` · `r14b_pre2.txt`)만 `Out-File -Encoding utf8` 로 떠서 `Get-Content -Encoding UTF8` 로 다시 읽는다(본문 그대로).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 카드 `send/R14b-Bob-W01.md` 머리 표기(3행 한 줄 안 · «🔴 1회차 반려 — 재제출 = 이 파일» · **줄 수 불변** — 아래 «■ 정적 묶음» 이 그 파일 294~325행을 꺼낸다 · 원 카드는 `send/` 에 그대로 둔다(`_완료/` 로 옮기지 않음 — Bob 브랜치의 같은 경로 판과 함께 읽게 · 다시 보내지 않음)) · `inbox/W01_questions.md` 머리 메모(6행 한 줄 안 · 줄 수 불변 · PR #88 의 diff(10행 뒤 3줄 더하기)와 겹치지 않는다 — 사전검사·정적 묶음은 세 점 diff 라 ④ «+|» 3줄 그대로) · `send/README.md` · `rounds.md` · 팩 README 와 **같은 푸시**로 `main` 에 올린다. 올린 뒤 이 파일의 줄 수를 바꾸지 않는다(«■ 보고 글 만들기» 의 꺼내기 줄이 이 파일 `main` 판 201~404행을 쓴다 · 머리 표기는 같은 줄 안에서만 고친다). 🔴 같은 푸시에서 golden README · `packages/ui_shell/README.md` · 01~05 사본 · 코드·PNG 는 건드리지 않는다.
> C4 수정안 시험(2026-10-31 · 분리 worktree `C:/Work/AAQ-claude-r14bj` @ `d122061` · 임시 커밋 `c0ed14d`(어느 가지에도 없음 · 트리 `ddff095`) · 끝에 삭제): 상자 1~3 과 같은 글자(`judge/fix.diff` · blob `0c36d8d`)를 넣고 `flutter test` 파일별 «00:00 +8» · «00:00 +6» · 전체 «00:10 +178: All tests passed!» · `flutter analyze --fatal-infos` No issues found! · `dart format` 0 changed · check_boundaries 실패 0 · 정적 32줄 출력 118줄(EXIT:1 18 · EXIT:0 14 · 1회차 Bob 출력과 줄 단위 같음 · 출력 파일 blob `9fa5908`) · 사전검사 ① 🔴 0 · 🟡 0(T1 0건) · 재제출 글 견본을 채운 판(`judge/submission_fixed.md` · blob `e37e6f6`)의 사전검사 ② 🔴 0 · 🟡 0. 🔵 조립 확인(2026-10-31 · Claude · 기록 가지 `rec/r14`): 이 파일에서 상자 1~3 을 다시 읽어 `d122061` 판(blob `063a00f`)에 적용 = blob `0c36d8d`(C4 수정안과 바이트 같음 · 상자 1·2 = 각 2곳 · 상자 3 = 한 곳) · 견본 201~404행 = `judge/submission_tpl.md` blob `2563ff8`(204줄) · PowerShell 5.1 에서 «■ 보고 글 만들기» 의 꺼내기·채우기·`WriteAllText` 줄을 기록 가지 판으로 실제로 돌림 = 견본 blob `2563ff8` · 채운 판 204줄 · 첫 줄 «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» · 남은 자리표시자 0 · BOM 0 · «■ 정적 묶음» 의 Git Bash 꺼내기 줄(원 카드 `send/R14b-Bob-W01.md` 294~325행 · 머리 표기 뒤) = `e253ad8`.

## 0. 한 줄 목적

PR #88 의 테스트 파일 하나를 상자 1~3 글자대로 고쳐 커밋 1개로 올리고, 보고 글 ①~⑤ **전체판**(견본 · 바뀌는 자리 = 자리표시자 4개뿐)을 사전검사 ② 를 거쳐 **저장 파일**로 내기 — **lib·PNG·질문 파일·다른 테스트는 한 글자도 바꾸지 않고, PNG 는 한 장도 열지 않고, 지난 4개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m8-w01-watchdog` · 같은 PR #88 · 🔴 **새 대화**.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 카드 머리 표기(«🔴 1회차 반려» · 원 카드는 `send/` 에 그대로)를 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(안전장치). PR #88 의 C4 반려 댓글은 「푸시해」 때 Claude 가 함께 올립니다 — 댓글이 보인 뒤 보냅니다.
2. Bob 은 **새 대화** 로 시작합니다(1회차 대화를 이어 쓰지 않습니다 · 필요한 글자는 이 패킷에 다 있습니다). 🔴 보내기 전에 Bob 의 이전 VS Code·터미널 창을 닫습니다(남은 `flutter_tester.exe` 가 다음 테스트를 붙잡지 않게).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R14b-Bob-W01-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md>. 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 이 아니라 이 파일이 없고, Bob 폴더는 PR 브랜치라 **1회차 카드 `R14b-Bob-W01.md` 만** 있습니다(그것을 보내면 안 됩니다). `main` 의 `send/` 에도 1회차 카드 `R14b-Bob-W01.md` 가 남아 있습니다(머리 «🔴 1회차 반려» · 다시 보내지 않음) — 보내는 것은 이 파일입니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ````text 다음 줄(«R14b-Bob-W01 재제출 요청»)부터 닫는 ```` 직전 줄까지 · 바깥 울타리는 **백틱 네 개**(안의 견본이 백틱 세 개를 쓴다) · 울타리와 구분선은 넣지 않습니다.
5. 받는 법 = 1회차와 같음 — Bob 은 보고 글을 `$env:TEMP\R14b-Bob-W01_submit.md` 에 저장하고 채팅에는 두 줄만 냅니다. 채팅 두 줄 = «R14b-Bob-W01 재제출 글 저장했음: <경로>» · 사전검사 ② 끝 줄. 받은 뒤 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다.

## 3. 붙여넣을 본문

---

````text
R14b-Bob-W01 재제출 요청 — 1회차(PR #88 · d122061) 판정: 반려(재제출). 같은 브랜치 ui/m8-w01-watchdog · 같은 PR #88 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 파일 하나(packages/ui_shell/test/watchdog_board_test.dart — 아래 상자 1~3 글자 그대로 · 5줄 더하기 · 7줄 빼기)와
  보고 글 ①~⑤ 전체판(아래 «■ 보고 글 견본» 을 기계로 꺼내 자리표시자 4개만 채워 저장 파일로 — 채팅에 붙이지 않는다)뿐입니다.
🔴 그 파일 밖 0 · PNG 0(다시 찍지도 열지도 않는다) · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.
🔵 1회차 카드(docs/ai-context/send/R14b-Bob-W01.md · 이 브랜치의 판 = main 판에서 머리 한 줄만 다름)는 바탕으로 함께 읽어도 됩니다 — 이번에 필요한 규칙은 이 글에 다 옮겼고, 바꿀 자리는 아래 상자 1~3 뿐입니다.
🔴 이 글과 1회차 카드가 다르면 이 글이 이깁니다(1회차 카드의 0단계·새 브랜치·커밋 (1)~(4)·■ 제출 절차는 따르지 않는다). 그 밖의 카드·문서·프롬프트는 읽지 않습니다.
🔴 명령은 Windows PowerShell 5.1 에서 한 줄씩 · bash 줄은 & "C:\Program Files\Git\bin\bash.exe" -c "…" 꼴 그대로(그냥 bash 라고 치면 WSL 이 돈다).

■ 0단계 — 대상 확인 (저장소 뿌리 C:\Work\Bob\AutoAlphaQuant 에서 · 아무것도 읽기 전에)
이 글은 R14b 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m8-n01-alerts 등)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #88 · 브랜치 ui/m8-w01-watchdog(커밋 d122061)에 아래 상자 1~3 커밋 하나를 «더하는» 일입니다. 상자는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지).
🔴 1회차 카드의 «(4) 뒤 커밋 0(예외 = (5) 하나)» 는 이번에 이 글이 덮습니다 — 재제출 커밋 (5) 1개(제목 = 아래 «커밋 제목» 상자)를 맨 위에 더하는 것이 이번 일입니다.
   지난 4개 커밋(d122061 · f573459 · 21a3034 · 3edc9fc — 순서·제목 그대로)은 고치지 않습니다(고치려 하면 반려).
  [Console]::OutputEncoding = [Text.Encoding]::UTF8   ← 🔴 먼저 한 번(한국어 출력·파일이 깨지지 않게 — 1회차 ① 커밋 제목이 깨진 까닭)
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m8-w01-watchdog 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m8-w01-watchdog
     ← 🔴 git checkout main 금지
  git rev-parse --short HEAD    ← d122061 이면 정상 · 다르면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune
  git rev-parse --short origin/ui/m8-w01-watchdog   ← d122061 · 다르면 멈추고 출력을 채팅으로
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
        ← docs/ai-context/send/R14b-Bob-W01-재제출.md 줄이 있으면 정상(1회차 카드 docs/ai-context/send/R14b-Bob-W01.md 줄도 함께 있다 — 머리 «🔴 1회차 반려» · 상관없음).
          그 밖의 줄(README.md · _완료)도 상관없습니다. 재제출 줄이 없으면 멈추고 채팅으로 — 기록 푸시보다 이 글이 먼저 왔습니다.
  git grep -c "contractVersion = '1.15.0'" origin/main -- packages/domain_contracts/lib/src/contract_version.dart
     ← «origin/main:packages/domain_contracts/lib/src/contract_version.dart:1» 이면 정상 · 출력이 없으면 멈추고 채팅으로
  Test-Path "C:\Program Files\Git\bin\bash.exe"   ← True · False 면 멈추고 채팅으로
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.
docs/ai-context/prompt_M8.md 는 열지 않습니다 · 1회차 카드는 읽기만(고치지 않는다 · 위 🔵 줄).

■ 규칙 요약 (이번에 필요한 것만 — 바탕 = 1회차 카드 규칙 10 · 테스트 최소 목록 W01-05 · ■ 제출 · 다르면 이 글이 이긴다)
· 이번에 고치는 곳 = packages/ui_shell/test/watchdog_board_test.dart 의 W01-05 다섯 줄 자리(상자 1~3)뿐입니다.
· 🔴 고치면 반려: 그 밖의 전부 — lib/**(watchdog_board.dart · ui_shell.dart · labels.dart · shell_providers.dart 포함) · test/shell_fakes.dart · test/golden/** · PNG 전부 ·
  docs/ai-context/inbox/W01_questions.md · pubspec.yaml · analysis_options.yaml · domain_contracts/** · apps/** · 다른 ui_* · docs/** 의 다른 파일.
  🔴 그 밖의 파일이 하나라도 M(또는 ??)이면 git checkout -- <그 파일>(?? 는 지운다) 하고 멈춘 뒤 채팅으로(build/ 는 .gitignore 대상).
· 이번에 걸린 1회차 카드 글자: 232행 «경우 = for · 흐름 = 클로저 칸» · 111행 «🔴 collection-if 0 · else 없는 if 0» · 112행 «🔴 반려 꼴: bool 칸 + if 로 경우 흐름 가르기» · 180행 «조건부 단언».
  → 흐름이 없는 경우도 칸을 비우지(null) 않고 빈 클로저 (WidgetTester t) async {} 를 넣고, 본문은 if 없이 await c.flow(tester); 한 줄로 부릅니다.
· 그대로인 수(상자는 바꾸지 않는다): ⓡ = W17 7 · ⓗ = W18 2 · // pre = W30 18 · testWidgets·test 줄 = W03 8 · 골든 1 · 테스트 수 +8 · +6 · 전체 +178 · 테스트에 한국어 리터럴 0 · if 를 새로 쓰지 않는다.
· 카드 구멍 C4H-7~9(X3 오래됨+휴장 · X7 배너 차례 · X10 값 쥔 채 다시 읽기)는 이번에 고치지 않습니다 — R14 test-only PR(통합 담당 · R14b 병합 뒤) 몫. 경우·단언을 더하지 않는다.
· 도구: melos.bat run test 는 돌리지 않는다 · 패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · 명령 출력은 파일로 떠서 쓴다(화면에서 손으로 옮겨 적지 않는다).
· 보고 규칙(1회차 카드 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장 = 반려 · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문·라벨을 고치지 않는다 · 보고에는 코드·파일·출력에 실제로 있는 것만 적는다.

■ 잘된 것 — 그대로 유지하십시오
lib watchdog_board.dart 는 카드 «화면»·«주입»·«상태 표»·«호출 표»·Key 8이름·_checkLook 글자 그대로였습니다 · 배럴 +1/0 · shell_fakes 끝 절 +63/0 · 라벨·주입·셸 파일 변경 0.
테스트는 W01-05 의 흐름 칸 말고 모두 맞았습니다 — 최소 목록의 경우 19개·단언 전부 · ⓡ 7 · ⓗ 2 · // pre 18 · if/else 짝 3 · 가짜 = call 삼항 · 픽스처 = main() 머리 final.
골든 6장 = 드라이런과 바이트 같음 · dy 696·580·592(light = dark) · 잘림 0 · flutter test 164 → +178 · analyze 0 · format 0 · domain_contracts +408 ~30 · 경계 실패 0 · 예고 변이 41/41 · 탐침 4/4 KILLED.
보고에서 맞은 곳 — 거짓 주장 0 · 정적 32줄 출력 118줄 · ② 10항·괄호 · ③ 서술 2줄 · 골든 표 6행 · ⑤ «없음».

■ 왜 반려인가 — 카드 / 실제 (C4 가 코드와 수정안 시험으로 직접 확인 · strict 나눔 ② · 재량 없이 반려)
① C4H-1 W01-05 흐름 칸이 nullable 이고 else 없는 if 로 흐름을 가른다 (테스트 결함 · 경미 · 실효 0)
   카드:  232행 «흐름 = 클로저 칸» · 111행 «else 없는 if 0» · 112행 «반려 꼴: bool 칸 + if 로 경우 흐름 가르기» · 180행 «조건부 단언».
   실제:  245·257행 Future<void> Function(WidgetTester t)? flow, · 271·283행 flow: null, · 366~368행 if (c.flow != null) { await c.flow!(tester); }
          — 흐름 몸통에는 단언이 있어서 칸이 null 이면 그 단언을 조용히 건너뛴다(지금 null 인 loading·fail 은 카드에서도 흐름이 없어 실효 0).
          사전검사 T1 은 if 안에 expect 가 직접 없어 이 자리를 못 잡았다(도구 구멍 — 따로 기록했다 · 그래도 카드 글자 위반이다).
   고침:  상자 1~3.
함께 고칠 것 — 표기 C4H-2~4 는 아래 «■ 보고 글 견본» 이 이미 고친 글자다(끝 줄 위 «까닭:» 한 줄(C4H-2) · ④ «+|» 3줄(C4H-3) · ① «바뀐 파일:» 12줄·«커밋 목록:» 줄 나눔과 글자(C4H-4)).
  🔵 테스트 수(+8 · +178)는 바꾸지 않습니다 — 경우 for 를 testWidgets 안에 둔 것은 반려 사유가 아닙니다(경우·단언이 다 있다). 카드 계획(+19 · +189)과 다른 까닭은 «까닭:» 줄이 말합니다.
«재량 없이 반려» = 통합 담당이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것 (저장소 뿌리에서)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시)
  cd packages/ui_shell
  flutter test   ← 시작 기준: 끝 줄 «+178: All tests passed!»(1회차 그대로 · 앞 시각은 달라도 된다). 다르면 아무것도 고치지 말고 멈춘 뒤 끝 20줄을 채팅으로.
  (packages/ui_shell 에 머문다 — 아래 상자 경로와 «고친 뒤 확인» 은 이 폴더 기준)

■ 고칠 것 — 상자 1~3 (1회차 반려 · C4 2026-10-31) — 상자 글자 그대로 · 손으로 다시 짜지 않는다
   🔴 «이 글자를» 상자와 파일이 한 글자라도 다르면(들여쓰기 포함) 고쳐 쓰지 말고 멈춘 뒤 채팅으로 — 파일이 d122061 이 아니다.
   🔴 탭 문자 0 · 줄 끝 빈칸 0 · 상자 밖은 한 글자도 바꾸지 않는다(빈 줄 포함) · 상자 머리·끝 줄(┌── · └──)은 파일에 넣지 않는다.

상자 1 (C4H-1 · 경우 칸의 타입 — 「모두 바꾸기」 · 이 글자는 파일에 정확히 2곳(245·257행) · 바꾼 뒤 0곳)
      ┌── 이 글자를(줄 일부 · 물음표 하나를 빼는 것)
Function(WidgetTester t)? flow,
      └──
      ┌── 이 글자로
Function(WidgetTester t) flow,
      └──

상자 2 (C4H-1 · 흐름 없는 두 경우 — 「모두 바꾸기」 · 이 글자는 파일에 정확히 2곳(271·283행 · loading · fail) · 바꾼 뒤 0곳)
      ┌── 이 글자를(줄 일부)
flow: null,
      └──
      ┌── 이 글자로
flow: (WidgetTester t) async {},
      └──

상자 3 (C4H-1 · 본문 — 3줄 → 1줄 · 366~368행 · 파일에 한 곳 · 줄 머리 빈칸 6 · 8 · 6 → 6)
      ┌── 이 줄을(3줄)
      if (c.flow != null) {
        await c.flow!(tester);
      }
      └──
      ┌── 이 줄로(1줄)
      await c.flow(tester);
      └──

고친 뒤 확인(packages/ui_shell 에서 · 커밋하기 전 · 고치지 않고 보기만):
  git diff --stat                                   ← 마지막 줄 « 1 file changed, 5 insertions(+), 7 deletions(-)»(파일 줄 하나 · 다르면 상자와 다시 대조)
  git hash-object test/watchdog_board_test.dart     ← 0c36d8d231966b7a112711bdba8ac05816e8059f(C4 수정안 파일의 git 해시 · 다르면 상자와 다시 대조 — BOM · 줄 끝 빈칸 · 빈 줄 하나에도 바뀐다)
  git grep -c -F "c.flow != null" -- test/watchdog_board_test.dart                 ← 출력 없음(d122061 에서는 «…:1»)
  git grep -c -F "flow: null," -- test/watchdog_board_test.dart                    ← 출력 없음(d122061 에서는 «…:2»)
  git grep -c -F "flow: (WidgetTester t) async {}," -- test/watchdog_board_test.dart  ← «test/watchdog_board_test.dart:2»
  git grep -c -F "await c.flow(tester);" -- test/watchdog_board_test.dart          ← «test/watchdog_board_test.dart:1»
  dart format --output=none --set-exit-if-changed lib test                         ← «Formatted … (0 changed) in …» 꼴
  flutter analyze --fatal-infos                                                    ← «No issues found!»
  flutter test test/watchdog_board_test.dart | Out-File -Encoding utf8 $env:TEMP\r14b_t1.txt
  flutter test test/golden/w01_golden_test.dart | Out-File -Encoding utf8 $env:TEMP\r14b_t2.txt
  flutter test | Out-File -Encoding utf8 $env:TEMP\r14b_t3.txt
     ← 🔴 골든은 --update-goldens 없이 · 세 파일은 아래 «■ 보고 글 만들기» 가 다시 읽는다(지우지 않는다)
  1..3 | ForEach-Object { Get-Content -Encoding UTF8 "$env:TEMP\r14b_t$_.txt" | Select-Object -Last 1 }
     ← 세 줄 «… +8: All tests passed!» · «… +6: All tests passed!» · «… +178: All tests passed!»(앞 시각은 달라도 된다 · 1회차와 같은 수)
  (수가 다르거나 실패가 있으면 커밋하지 말고 멈춘 뒤 그 파일 끝 20줄을 채팅으로 — 상자를 다른 꼴로 고쳐 수를 맞추지 않는다)

■ 커밋 · 사전검사 ① · 푸시 (위 확인이 기대와 같은 뒤 · 저장소 뿌리에서)
  cd ../..
  git status --short   ← 🔴 정확히 한 줄 « M packages/ui_shell/test/watchdog_board_test.dart» · 다른 줄이 있으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
  git add packages/ui_shell/test/watchdog_board_test.dart   ← 🔴 이 한 파일만 · git add . 금지
  git commit -m "[M8] R14b (5) C4 반려 수정 — W01-05 흐름 클로저"   ← 아래 «커밋 제목» 상자 글자 그대로
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M8] R14b (5) C4 반려 수정 — W01-05 흐름 클로저
      └── 커밋 제목 복사 끝(이 줄 앞까지)
  git show --stat --format=%s HEAD   ← 첫 줄 = 위 제목 · 파일 줄 «packages/ui_shell/test/watchdog_board_test.dart | 12 +++++-------» 하나 · 끝 줄 « 1 file changed, 5 insertions(+), 7 deletions(-)»
  git rev-parse "HEAD^{tree}"        ← ddff0958ea1776d2f7a4f3da159856e5a84c17f7(= C4 수정안 트리 · 다르면 푸시하지 말고 멈춘 뒤 채팅으로)
  git log --oneline origin/main..HEAD   ← 5줄 · 맨 위 = 방금 커밋 · 그 아래 4줄 = d122061 … 3edc9fc(그대로 · 다르면 멈춤)
   🔴 지난 커밋을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.
  dart tool/precheck.dart --base origin/main --collection-if 0
     ← 끝 줄 «── 결과: 🔴 0 · 🟡 0 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)»(C4 시험 · T1 0건) · 🔴 가 하나라도 나오면 푸시하지 않고 고치지도 않는다 — 출력 전부를 채팅으로.
  git status --short   ← 🔴 비어 있어야 푸시한다
  git push origin ui/m8-w01-watchdog   ← 같은 브랜치 → PR #88 자동 반영 · 새 PR·라벨·강제 푸시·rebase·main 병합 금지
  git rev-parse --short origin/ui/m8-w01-watchdog   ← 방금 커밋(git rev-parse --short HEAD 와 같은 해시)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다.

■ 정적 묶음 — 1회차 카드 294~325행 32줄(main 의 send/R14b-Bob-W01.md · 머리 한 줄 표기만 바뀌어 줄 번호 그대로)을 파일로 꺼내 Git Bash 로 돌린다 · 🔴 터미널에 붙여 넣어 돌리지 않는다
  (푸시한 그 커밋 위 · git status 가 빈 채 · packages/ui_shell 에서)
  cd packages/ui_shell
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R14b-Bob-W01.md' | sed -n '294,325p' > ../../build/r14b_static.sh"
  git hash-object ../../build/r14b_static.sh   ← e253ad80851787a4017272e0eb96e9ec040a25dc(1회차와 같은 32줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r14b_static.sh > ../../build/r14b_static_out.txt"
  Select-String -Path ..\..\build\r14b_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r14b_static_out.txt).Count   ← 118(EXIT 줄 32 포함)
  git hash-object ../../build/r14b_static_out.txt       ← 9fa590831b1646f1421a98881acc1b05c662a56c(= C4 가 같은 트리에서 돌린 출력 = 아래 견본의 «정적 묶음 출력» 블록 118줄 · 1회차와 같음 ·
                                                          같으면 견본 블록을 그대로 쓴다 · 다르면 제출하지 말고 출력 파일 전부를 채팅으로 — 블록을 손으로 고치지 않는다)
  cd ../..

■ 보고 글 만들기 — 견본(아래 «■ 보고 글 견본» · 이 글의 main 판 201~404행)을 기계로 꺼내 자리표시자 4개만 채운다 · 손으로 옮겨 쓰지 않는다 · 저장소 뿌리에서
  [Console]::OutputEncoding = [Text.Encoding]::UTF8
  $tpl = (git show 'origin/main:docs/ai-context/send/R14b-Bob-W01-재제출.md' | Select-Object -Skip 200 -First 204) -join "`n"
     ← 🔴 -join "`n" 그대로(빼면 줄이 한 줄로 이어 붙는다 — 1회차 ① 이 그 꼴이었다)
  $h5 = git rev-parse --short HEAD
  $t1 = Get-Content -Encoding UTF8 $env:TEMP\r14b_t1.txt | Select-Object -Last 1
  $t2 = Get-Content -Encoding UTF8 $env:TEMP\r14b_t2.txt | Select-Object -Last 1
  $t3 = Get-Content -Encoding UTF8 $env:TEMP\r14b_t3.txt | Select-Object -Last 1
  $out = $tpl.Replace('<H5>', $h5).Replace('<WB_END>', $t1).Replace('<GOLD_END>', $t2).Replace('<ALL_END>', $t3)
  [IO.File]::WriteAllText("$env:TEMP\R14b-Bob-W01_submit.md", $out + "`n", (New-Object Text.UTF8Encoding($false)))
     ← 🔴 이 꼴 그대로(BOM 0 · 줄바꿈·글자 그대로) · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다(머리 «저장 파일» 줄 — 1회차 ① 이 이어 붙고 깨진 까닭)
  (Get-Content -Encoding UTF8 $env:TEMP\R14b-Bob-W01_submit.md).Count   ← 204
  Select-String -Path $env:TEMP\R14b-Bob-W01_submit.md -Pattern '<H5>|<WB_END>|<GOLD_END>|<ALL_END>'   ← 출력 없음(남은 자리표시자 0)
  Get-Content -Encoding UTF8 $env:TEMP\R14b-Bob-W01_submit.md -TotalCount 1   ← «## ① 구현한 화면 ID · 바뀐 파일 · 커밋»
  git -c core.quotePath=false diff --name-status origin/main...HEAD   ← 12줄 = 견본 «바뀐 파일:» 블록 12줄과 같은 글자(다르면 멈추고 채팅으로)
  사전검사 ②:
  dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R14b-Bob-W01_submit.md --golden-prefix w01 --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r14b_pre2.txt; Get-Content -Encoding UTF8 $env:TEMP\r14b_pre2.txt | Select-Object -Last 1
     ← «── 결과: 🔴 0 · 🟡 0 — …»(C4 시험) · 🔴 가 있으면 내지 말고 출력 전부를 채팅으로 · 🟡 가 나오면 PNG 를 열지 말고 출력 전부를 채팅으로(골든 표는 1회차 칸 그대로 — C4 가 확인했다)
  채팅 답 = 두 줄뿐: «R14b-Bob-W01 재제출 글 저장했음: <경로>» · 사전검사 ② 끝 줄.

■ 보고 글 견본 (다음 줄부터 · 204줄 · 자리표시자 = <H5> · <WB_END> · <GOLD_END> · <ALL_END>)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
화면 ID: W-01 — 워치독 상태(WatchdogBoard())

바뀐 파일:
```
M	docs/ai-context/inbox/W01_questions.md
A	packages/ui_shell/lib/src/watchdog_board.dart
M	packages/ui_shell/lib/ui_shell.dart
A	packages/ui_shell/test/golden/goldens/w01_delayed_dark.png
A	packages/ui_shell/test/golden/goldens/w01_delayed_light.png
A	packages/ui_shell/test/golden/goldens/w01_holiday_dark.png
A	packages/ui_shell/test/golden/goldens/w01_holiday_light.png
A	packages/ui_shell/test/golden/goldens/w01_paused_dark.png
A	packages/ui_shell/test/golden/goldens/w01_paused_light.png
A	packages/ui_shell/test/golden/w01_golden_test.dart
M	packages/ui_shell/test/shell_fakes.dart
A	packages/ui_shell/test/watchdog_board_test.dart
```

커밋 목록:
```
<H5> [M8] R14b (5) C4 반려 수정 — W01-05 흐름 클로저
d122061 [M8] R14b (4) format · 질문
f573459 [M8] R14b (3) 골든 w01_* 6장
21a3034 [M8] R14b (2) W-01 테스트
3edc9fc [M8] R14b (1) W-01 워치독 상태
```

## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 W13 — 허용 밖 import 0줄 · pubspec 무변경(W25))
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] (산술 = 신선도 한 식 · null 여부 · UiLevel switch 뿐 · 거르기·정렬·세기·Duration 0(W07) · 금지 수치 W15 0건 · 소수·% 리터럴 W16 0건)
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] (DateTime.now 0(W07) · 마지막 확인 = lastPingText 그대로 · 유예 = graceText 그대로 · 마지막 수신 = lastReceivedText 그대로)
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] (이 카드 범위 밖(5탭·홈·F-01) · 손익 0)
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] (이 카드 범위 밖(알림 = R14a))
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] (이 카드 범위 밖(DND UI = M9))
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] (슬러그·ping URL·키 = 계약에 0(v1.15 · C-49 ⑪) · lib 낱말 0(W09 · 주석 포함) · checkId 그리기·Key·비교 0(W07 · W19 · W01-07))
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] (이 카드 범위 밖(시크릿 입력 = M9))
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] (이 카드 범위 밖(온보딩 = R15))
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] (/pause·/resume 버튼 0(W07) · 삽입 자리 직접 구현 0)

10항 줄 수:
```
10
```

정적 묶음 출력:
```
## W01 new test files hangul 0 (comment lines only)
EXIT:1
## W02 test names ASCII
EXIT:1
## W03 testWidgets and test lines
test/golden/w01_golden_test.dart:1
test/watchdog_board_test.dart:8
EXIT:0
## W04 link literals in lib 0
EXIT:1
## S05 opener lines (each must be inside a tap callback)
lib/src/watchdog_board.dart:111:              ref.read(shellLinkOpenerProvider).open(route);
EXIT:0
## W06 subscription lines (1)
lib/src/watchdog_board.dart:20:      (Ref ref) => ref.watch(shellOpsStatusRepositoryProvider).watchWatchdog(),
EXIT:0
## W07 forbidden words in watchdog board 0
EXIT:1
## W08 UiLevel switch arms (5)
lib/src/watchdog_board.dart:141:  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
lib/src/watchdog_board.dart:142:  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
lib/src/watchdog_board.dart:143:  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
lib/src/watchdog_board.dart:144:  UiLevel.act => (Icons.error_outline, cs.secondary),
lib/src/watchdog_board.dart:145:  UiLevel.blocked => (Icons.block, cs.error),
EXIT:0
## W09 secret words in lib 0
EXIT:1
## W10 shell labels (35 exact)
lib/l10n/labels.dart:35
EXIT:0
## W11 barrel exports (9 exact)
lib/ui_shell.dart:13:export 'l10n/labels.dart';
lib/ui_shell.dart:14:export 'src/alerts/alert_center.dart';
lib/ui_shell.dart:15:export 'src/alerts/alert_detail.dart';
lib/ui_shell.dart:16:export 'src/ops_home.dart';
lib/ui_shell.dart:17:export 'src/ops_rhythm.dart';
lib/ui_shell.dart:18:export 'src/routing/shell_router.dart';
lib/ui_shell.dart:19:export 'src/shell_providers.dart';
lib/ui_shell.dart:20:export 'src/shell_scaffold.dart';
lib/ui_shell.dart:21:export 'src/watchdog_board.dart';
EXIT:0
## W12 shell providers (15 exact)
lib/src/shell_providers.dart:37:final Provider<ShellPlatform> shellPlatformProvider = Provider<ShellPlatform>(
lib/src/shell_providers.dart:42:final Provider<ShellRouteBodies> shellRouteBodiesProvider =
lib/src/shell_providers.dart:49:final Provider<ConfigRepository> shellConfigRepositoryProvider =
lib/src/shell_providers.dart:56:final Provider<AlertRepository> shellAlertRepositoryProvider =
lib/src/shell_providers.dart:63:final Provider<OpsSummaryRepository> shellOpsSummaryRepositoryProvider =
lib/src/shell_providers.dart:70:final Provider<Clock> shellClockProvider = Provider<Clock>(
lib/src/shell_providers.dart:77:final Provider<GlobalKey<NavigatorState>> shellNavigatorKeyProvider =
lib/src/shell_providers.dart:82:final StateProvider<int> shellTabIndexProvider = StateProvider<int>(
lib/src/shell_providers.dart:88:final StreamProvider<FeatureFlags> shellFlagsProvider =
lib/src/shell_providers.dart:113:final Provider<SafetyRepository> shellSafetyRepositoryProvider =
lib/src/shell_providers.dart:120:final Provider<AdviceRepository> shellAdviceRepositoryProvider =
lib/src/shell_providers.dart:127:final Provider<HoldingsRepository> shellHoldingsRepositoryProvider =
lib/src/shell_providers.dart:134:final Provider<OpsStatusRepository> shellOpsStatusRepositoryProvider =
lib/src/shell_providers.dart:141:final Provider<LedgerTrustRepository> shellLedgerTrustRepositoryProvider =
lib/src/shell_providers.dart:150:final Provider<CommandApi?> shellAlertCommandApiProvider =
EXIT:0
## W13 imports outside the three packages 0
EXIT:1
## W14 hangul literals in lib except labels 0
EXIT:1
## W15 figures 0 (prompt 68-74)
EXIT:1
## W16 decimal and percent literals 0
EXIT:1
## W17 R lines (retry findsNothing)
test/watchdog_board_test.dart:7
EXIT:0
## W18 H lines (hasLength)
test/watchdog_board_test.dart:2
EXIT:0
## W19 w01 key names
lib/src/watchdog_board.dart:35:w01-fail
lib/src/watchdog_board.dart:43:w01-loading
lib/src/watchdog_board.dart:59:w01-asof
lib/src/watchdog_board.dart:63:w01-received
lib/src/watchdog_board.dart:71:w01-empty
lib/src/watchdog_board.dart:75:w01-holiday
lib/src/watchdog_board.dart:81:w01-limit
lib/src/watchdog_board.dart:107:w01-row
EXIT:0
## W20 banned vocabulary 0
EXIT:1
## W21 Colors files 0
EXIT:1
## W22 rich text and trimming 0
EXIT:1
## W23 autoDispose 0
EXIT:1
## W24 Scaffold AppBar Navigator in watchdog board 0
EXIT:1
## W25 shared files add-only and frozen files (numstat)
1	0	packages/ui_shell/lib/ui_shell.dart
63	0	packages/ui_shell/test/shell_fakes.dart
EXIT:0
## W26 implements in new tests 0
EXIT:1
## W27 copyWith in tests 0
EXIT:1
## W28 collection-if in tests 0
EXIT:1
## W29 golden files
A	packages/ui_shell/test/golden/goldens/w01_delayed_dark.png
A	packages/ui_shell/test/golden/goldens/w01_delayed_light.png
A	packages/ui_shell/test/golden/goldens/w01_holiday_dark.png
A	packages/ui_shell/test/golden/goldens/w01_holiday_light.png
A	packages/ui_shell/test/golden/goldens/w01_paused_dark.png
A	packages/ui_shell/test/golden/goldens/w01_paused_light.png
EXIT:0
## W30 precondition marks (pre)
test/watchdog_board_test.dart:18
EXIT:0
## W31 bare takeException 0
EXIT:1
## W32 golden PNG total (40 exact)
40
EXIT:0
```

S05 결과:
lib/src/watchdog_board.dart:111 — 탭 콜백 안

ⓡ = W17 출력:
test/watchdog_board_test.dart:7
ⓗ = W18 출력:
test/watchdog_board_test.dart:2

테스트 파일별:
<WB_END>
<GOLD_END>

## ③ 스크린샷 서술 · 골든 표
«정상» = ListView → Key('w01-asof') → ShellStaleBanner(있을 때) → Key('w01-received')(있을 때) → ValueKey<String>('w01-row-$i') → Key('w01-empty')(있을 때) → Key('w01-holiday')(있을 때) → Key('w01-limit')(있을 때)
«빈» = «정상» 의 행 자리에 Key('w01-empty') · «로딩» = ShellSkeleton(Key('w01-loading')) · «에러» = ShellErrorView(Key('w01-fail')) · «오래됨» = ListView → Key('w01-asof') → ShellStaleBanner → Key('w01-received')(있을 때) → ValueKey<String>('w01-row-$i')

| 이름 | 입력 픽스처 | 크기 | 위치 전제 dy | 배치·잘림 |
|---|---|---|---|---|
| w01_delayed light | watchdog_delayed.json | 390×844 | 696.0 | 글자 25줄 — 잘림 없음 |
| w01_delayed dark | watchdog_delayed.json | 390×844 | 696.0 | 글자 25줄 — 잘림 없음 |
| w01_holiday light | watchdog_holiday.json | 390×844 | 580.0 | 글자 20줄 — 잘림 없음 |
| w01_holiday dark | watchdog_holiday.json | 390×844 | 580.0 | 글자 20줄 — 잘림 없음 |
| w01_paused light | watchdog_paused.json | 390×844 | 592.0 | 글자 21줄 — 잘림 없음 |
| w01_paused dark | watchdog_paused.json | 390×844 | 592.0 | 글자 21줄 — 잘림 없음 |

## ④ 질문 목록
```
+| A1 | R14b-Bob-W01 | 추측 | 측정: w01_delayed dy 실측값 (light=696.0, dark=696.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A2 | R14b-Bob-W01 | 추측 | 측정: w01_holiday dy 실측값 (light=580.0, dark=580.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A3 | R14b-Bob-W01 | 추측 | 측정: w01_paused dy 실측값 (light=592.0, dark=592.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
```

## ⑤ 추측한 것 목록
없음

까닭: watchdog_board_test 는 경우 for 를 testWidgets 안에 둠 — testWidgets 8 = 테스트 8(경우 19 · 단언 전부) · 파일별 +8 · +6 → 164 + 14 = 178(카드 계획 164 + 25 와 다름)
flutter test: 시작 기준 164 → 끝 <ALL_END>
■ 보고 글 견본 끝(이 줄 앞까지)
(채팅 답 = 위 두 줄뿐 · 보고 글 전문은 저장 파일에만)
````

---

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R14b-Bob-W01 재제출: PR #88 에 푸시됨 — 병합 검사해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R14b-Bob-W01_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계에서 멈췄다면 `R14b-Bob-W01 재제출 0단계에서 멈춤 — 확인해줘` + 출력.
