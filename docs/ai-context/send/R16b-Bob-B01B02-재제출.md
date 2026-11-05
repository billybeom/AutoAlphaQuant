# 발송 패킷 R16b-Bob-B01B02 — 재제출 (1회차 반려 · 2026-11-05)

> ▶ **보낼 수 있음(「푸시해」 뒤)**(2026-11-05 · C4 R16b 1회차 반려 기록 · 이 파일이 GitHub `main` 의 `send/` 에 있고 PR #132 «Conversation» 에 C4 반려 댓글(«C4 병합 검사 1회차 판정 — 🔴 반려(재제출) · R16b-Bob-B01B02 · head `90c2e9b`»)이 보이면 보낸다 · 댓글은 「푸시해」 때 Claude 가 게시(번호 = 게시 뒤 기록) · Bob **새 대화** · 같은 브랜치 `ui/m8-b01-handbook` · 같은 PR #132 · 그 밖의 선행 없음 · 🔵 `main` 계약 `'1.17.0'` 전제(엔진 세션이 계약을 먼저 올리면 Bob 이 0단계에서 멈춘다 — 통합 담당이 기대를 다시 본다) · `send/README.md` 배지 규칙).
> 만든 날 2026-11-05 · 1회차(PR #132 · 브랜치 `ui/m8-b01-handbook` · 커밋 `90c2e9b` · 밑동 `11b151a` · 커밋 6 · 통합 담당 대행 PR)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-11-05 · 모두 권고): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #132 · 커밋 1개(테스트 파일 한 줄 · B02-02 전제 `expect(sleeveB.blocks[1].live, isNotNull); // pre`) · 보고 글 ①~⑤ 전체판 = 저장 파일 · `[IO.File]::WriteAllText` UTF-8 BOM 없이 · 🔴 1회차 ④ 블록이 CP949 로 깨졌으므로 `git diff` 출력을 붙일 때도 UTF-8 로 읽어 붙이는 꼴(`[Console]::OutputEncoding = [Text.Encoding]::UTF8` 먼저 · 그 줄 없이 `git … | Out-String` 으로 받아 붙이지 않는다 · 질문 파일 줄은 `Get-Content -Encoding UTF8` 로 읽는다)을 글자로 · 저장 뒤 «깨진 글자 0» 자기 확인 한 줄 · Bob 새 대화 · 자급 패킷) ② 커밋 (5) · (6) = 그대로((5) `e372b2c` 제목 ≠ 내용 = ① 표기 C4O-3 · 2회차 병합 때 PR 본문 «C4 정정» 한 줄 · 커밋 수 6 · (6) `90c2e9b` 골든 뒤 lib 수정 = 기록만(C4O-4) — 지난 커밋 고치지 않음) ③ 카드 구멍 C4O-7(골든만 잡힌 예고 변이 P09d · P11) · C4O-9(B02-07 null 주입 글자) = R16 test-only 묶음(C4r16b-3 · C4r16a-2 와 한 PR · R16c 병합 뒤 · 통합 담당 — 이 재제출에 넣지 않는다) · 이월 부록 C4r16b-1~6 = 설계 12 §3 «R16b C4 이월 부록»(-1 · -4 · -5 카드 문구 = R16c 승격 때 · -2 infra(사전검사 T34 · T20 · T21 대조 + 깨진 글자 🔴) · -3 🧪 · -6 C4 워크플로) ④ 재제출 = Bob 새 대화. 판정 근거 = C4 보고 §0(설계 저장소 `10_리뷰/2026-11-05_R16b_C4_보고.md`) — 1회차 카드 strict 나눔. [가] ② 테스트 결함 **C4O-1**(B02-02 전제 «live isNotNull // pre» 누락 · 실효 0 · 선례 R4b C4b-2 · R3 C3-4 · R13a C4s-9). [나] 표기 C4O-2(저장 파일 ④ CP949 깨짐) = 아래 «■ 보고 글 견본» 이 고쳤다(UTF-8 다섯 줄 · 저장 = `WriteAllText`) · C4O-3(커밋 (5) 제목) = 2회차 병합 때 C4 정정.
> 고치는 것 = **파일 하나**(`packages/ui_shell/test/handbook_page_view_test.dart` — 아래 상자 1 · B02-02 `testWidgets(` 머리 바로 아래 한 줄 더하기 · 1줄 더하기 · 0줄 빼기 · 테스트 수 변화 0) **+ 보고 글 ①~⑤ 전체판을 저장 파일로**(견본 = 아래 «■ 보고 글 견본» · 자리표시자 6개만 명령 출력으로 · 견본은 이 파일의 `main` 판에서 기계로 꺼내 PowerShell 로 채운다 — 손으로 옮겨 쓰지 않는다). lib · PNG · 질문 파일 · 다른 문서 0 · PR 본문 · 라벨 0.
> 🔴 **PNG 열람 0** — 이 재제출은 PNG 를 바꾸지도 다시 찍지도 열지도 않는다(`--update-goldens` 0 · `golden:approved` 불필요 · 골든 표 «배치·잘림» 칸 · dy 칸 = 1회차 Bob 칸 그대로 = C4 갈래 G · 기계 갈래가 이름마다 `--plain-name` 으로 다시 잰 값 744 · 388 · 248 · 116 과 같음). lib 를 고치지 않으므로 dy 도 다시 재지 않는다.
> 🔴 **Git Bash 는 경로로 부른다**(이 PC 의 PowerShell 에서 `bash` 는 WSL) — 이 패킷의 bash 줄은 전부 `& "C:\Program Files\Git\bin\bash.exe" …` 꼴이다.
> 🔴 **저장 파일은 UTF-8(BOM 없이) · 줄바꿈 그대로**(C4r14b-5 · 1회차 ④ 가 깨진 자리 = C4O-2) — `[Console]::OutputEncoding = [Text.Encoding]::UTF8` 먼저 · 여러 줄은 `-join "`n"` · 저장은 `[IO.File]::WriteAllText(…, (New-Object Text.UTF8Encoding($false)))` 한 꼴. 🔴 `git diff` · `git show` 출력을 붙이거나 비교할 때도 UTF-8 로 읽는다(발주자 결정 ① · 1회차 ④ 다섯 줄 = UTF-8 바이트를 CP949 로 읽은 꼴) — 그 창에서 `[Console]::OutputEncoding` 을 UTF-8 로 먼저 두고, 그 줄 없이 `git … | Out-String` 으로 받아 붙이지 않는다 · 질문 파일 줄이 필요하면 `Get-Content -Encoding UTF8` 로 읽는다 · 저장 뒤 «깨진 글자 0» 자기 확인(한자 · U+FFFD 0 줄)을 한다.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 카드 `send/R16b-Bob-B01B02.md` 머리 표기(3행 한 줄 안 · «🔴 1회차 반려 — 재제출 = 이 파일» · **줄 수 불변** — 아래 «■ 정적 묶음» 이 그 파일 225~261행을 꺼낸다 · 원 카드는 `send/` 에 그대로) · `send/README.md` · `rounds.md` · 팩 README 와 **같은 푸시**로 `main` 에 올린다. `inbox/B01B02_questions.md` 는 `main` 에서 고치지 않는다(이 브랜치가 더하는 파일 · 겹침 0). 올린 뒤 이 파일의 줄 수를 바꾸지 않는다(«■ 보고 글 만들기» 의 꺼내기 줄이 이 파일 `main` 판 195~476행을 쓴다 · 머리 표기는 같은 줄 안에서만 고친다). 🔴 같은 푸시에서 golden README · `packages/ui_shell/README.md` · 01~05 사본 · 코드·PNG · `_대기/R16c-Bob-H03.md` 는 건드리지 않는다.
> C4 수정안 시험(2026-11-05 · 분리 worktree `C:/Work/AAQ-claude-r16bj` @ `90c2e9b` · melos bootstrap 14 · build_runner 82 outputs · 임시 커밋 `0a40c19`(어느 가지에도 없음 · 트리 `3656fcd`) · 끝에 삭제): 상자 1 과 같은 글자(`judge/fix.diff` · 테스트 파일 blob `681d540`)를 넣고 `dart format` 0 changed · `flutter analyze --fatal-infos` «No issues found!» · `flutter test` 파일별 «00:01 +14» · «00:01 +20» · «00:00 +2» · «00:01 +6» · 전체 «00:33 +456: All tests passed!» · name-status 20 · 커밋 7 · 정적 37줄(해시 `c60027d`) 출력 175줄(EXIT:1 21 · EXIT:0 16 · 1회차와 다른 줄 = T34 `test/handbook_page_view_test.dart:3` → `:4` 하나 · 출력 blob `751b25c`) · 사전검사 ① 🔴 0 · 🟡 0(`--base 11b151a` · `--base origin/main` 둘 다) · 재제출 글 견본을 채운 판(`judge/submission_fixed.md` · 282줄 · blob `1eef23c`)의 사전검사 ② `b01_` 🔴 0 · 🟡 1 · `b02_` 🔴 0 · 🟡 1(= 원 카드 기대 · `--base origin/main` 도 같음) · C4 사람 grep 셋 0 · 0 · 0. 탐침: 표본 `blocks[1].live` 를 null 로 바꾸면 1회차 판 B02-02 = «+2: All tests passed!»(공허) · 고친 판 = 두 경우 «Expected: not null» 실패. 🔵 조립 확인(2026-11-05 · Claude · 기록 가지 `rec/r16`): 이 파일에서 상자 1 을 다시 읽어 `90c2e9b` 판(blob `3591d0b`)의 161행(기준 줄 · 파일에 한 번) 아래에 적용 = blob `681d540`(C4 수정안과 바이트 같음 · 새 162행 한 줄) · 견본 195~476행 = `judge/submission_tpl.md` blob `ccbd7ad`(282줄) · PowerShell 5.1 에서 «■ 보고 글 만들기» 의 꺼내기(`-Skip 194 -First 282`)·채우기·`WriteAllText` 줄을 기록 가지 판(index)으로 실제로 돌림 = 견본 blob `ccbd7ad` · C4 시험 값으로 채운 판 = `judge/submission_fixed.md` blob `1eef23c`(바이트 같음) · 282줄 · 첫 줄 «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» · 남은 자리표시자 0 · BOM 0 · «| 추측 | 측정:» 5 · 🆕 깨진 글자 줄 0(같은 줄로 1회차 저장 파일 = 5) · «■ 정적 묶음» 의 Git Bash 꺼내기 줄(원 카드 `send/R16b-Bob-B01B02.md` 225~261행 · 머리 표기 뒤 · 줄 수 478 불변) = `c60027d`.

## 0. 한 줄 목적

PR #132 의 테스트 파일 `packages/ui_shell/test/handbook_page_view_test.dart` 에 상자 1 의 한 줄(B02-02 전제)을 더해 커밋 1개로 올리고, 보고 글 ①~⑤ **전체판**(견본 · 바뀌는 자리 = 자리표시자 6개뿐)을 사전검사 ② 를 거쳐 **저장 파일**로 내기 — **lib · PNG · 질문 파일 · 다른 문서는 한 글자도 바꾸지 않고, PNG 는 한 장도 열지 않고, 지난 6개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m8-b01-handbook` · 같은 PR #132 · 🔴 **새 대화**.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 카드 머리 표기(«🔴 1회차 반려» · 원 카드는 `send/` 에 그대로)를 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(안전장치). PR #132 의 C4 반려 댓글은 「푸시해」 때 Claude 가 함께 올립니다 — 댓글이 보인 뒤 보냅니다.
2. Bob 은 **새 대화** 로 시작합니다(1회차 대화를 이어 쓰지 않습니다 · 필요한 글자는 이 패킷에 다 있습니다). 🔴 보내기 전에 Bob 의 이전 VS Code · 터미널 창을 닫습니다(남은 `flutter_tester.exe` 가 다음 테스트를 붙잡지 않게 · 작업 관리자에서 직접 끝내지 않습니다 — 다른 세션 것도 있습니다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R16b-Bob-B01B02-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md>. 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 이 아니라 이 파일이 없고, Bob 폴더는 PR 브랜치라 **1회차 카드 `R16b-Bob-B01B02.md` 만** 있습니다(그것을 보내면 안 됩니다). `main` 의 `send/` 에도 1회차 카드가 남아 있습니다(머리 «🔴 1회차 반려» · 다시 보내지 않음) — 보내는 것은 이 파일입니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ````text 다음 줄(«R16b-Bob-B01B02 재제출 요청»)부터 닫는 ```` 직전 줄까지 · 바깥 울타리는 **백틱 네 개**(안의 견본이 백틱 세 개를 쓴다) · 울타리와 구분선은 넣지 않습니다.
5. 받는 법 = 1회차와 같음 — Bob 은 보고 글을 `$env:TEMP\R16b-Bob-B01B02_submit.md` 에 저장하고 채팅에는 두 줄만 냅니다. 받은 뒤 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다.

## 3. 붙여넣을 본문

---

````text
R16b-Bob-B01B02 재제출 요청 — 1회차(PR #132 · 90c2e9b) 판정: 반려(재제출). 같은 브랜치 ui/m8-b01-handbook · 같은 PR #132 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 파일 하나(packages/ui_shell/test/handbook_page_view_test.dart — 아래 상자 1 · B02-02 testWidgets 머리 바로 아래 한 줄 더하기)와
  보고 글 ①~⑤ 전체판(아래 «■ 보고 글 견본» 을 기계로 꺼내 자리표시자 6개만 채워 저장 파일로 — 채팅에 붙이지 않는다)뿐입니다.
🔴 그 파일 밖 0 · 그 파일의 다른 줄 0 · lib · PNG · 질문 파일 0(PNG 를 다시 찍지도 열지도 않는다) · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.
🔵 1회차 카드(docs/ai-context/send/R16b-Bob-B01B02.md · 이 브랜치의 판 = main 판에서 머리 한 줄만 다름)는 바탕으로 함께 읽어도 됩니다 — 이번에 필요한 규칙은 이 글에 다 옮겼고, 바꿀 자리는 아래 상자 1 뿐입니다.
🔴 이 글과 1회차 카드가 다르면 이 글이 이깁니다(1회차 카드의 0단계·새 브랜치·커밋 (1)~(4)·■ 제출 절차는 따르지 않는다). 그 밖의 카드·문서·프롬프트는 읽지 않습니다.
🔴 명령은 Windows PowerShell 5.1 에서 한 줄씩 · bash 줄은 & "C:\Program Files\Git\bin\bash.exe" … 꼴 그대로(그냥 bash 라고 치면 WSL 이 돈다).

■ 0단계 — 대상 확인 (저장소 뿌리 C:\Work\Bob\AutoAlphaQuant 에서 · 아무것도 읽기 전에)
이 글은 R16b 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m8-d01-incident 등)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #132 · 브랜치 ui/m8-b01-handbook(커밋 90c2e9b)에 아래 상자 1 커밋 하나를 «더하는» 일입니다. 상자는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지).
🔴 1회차 카드의 «마지막 커밋 = format·질문 커밋(또는 (5))» 는 이번에 이 글이 덮습니다 — 재제출 커밋 (7) 1개(제목 = 아래 «커밋 제목» 상자)를 맨 위에 더하는 것이 이번 일입니다.
   지난 6개 커밋(90c2e9b · e372b2c · 434a625 · 5027a65 · dcc6968 · 2b3dbf7 — 순서·제목 그대로)은 고치지 않습니다(고치려 하면 반려).
  [Console]::OutputEncoding = [Text.Encoding]::UTF8   ← 🔴 먼저 한 번(한국어 출력·파일이 깨지지 않게 · 1회차 ④ 가 깨진 자리)
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m8-b01-handbook 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m8-b01-handbook
     ← 🔴 git checkout main 금지
  git rev-parse --short HEAD    ← 90c2e9b 이면 정상 · 다르면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune
  git rev-parse --short origin/ui/m8-b01-handbook   ← 90c2e9b · 다르면 멈추고 출력을 채팅으로
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
        ← docs/ai-context/send/R16b-Bob-B01B02-재제출.md 줄이 있으면 정상(1회차 카드 docs/ai-context/send/R16b-Bob-B01B02.md 줄도 함께 있다 — 머리 «🔴 1회차 반려» · 상관없음).
          그 밖의 줄(README.md · _완료 · _대기)도 상관없습니다. 재제출 줄이 없으면 멈추고 채팅으로 — 기록 푸시보다 이 글이 먼저 왔습니다.
  git grep -c "contractVersion = '1.17.0'" origin/main -- packages/domain_contracts/lib/src/contract_version.dart
     ← «origin/main:packages/domain_contracts/lib/src/contract_version.dart:1» 이면 정상 · 출력이 없으면 멈추고 채팅으로
  Test-Path "C:\Program Files\Git\bin\bash.exe"   ← True · False 면 멈추고 채팅으로
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.
docs/ai-context/prompt_M8.md 는 열지 않습니다 · 1회차 카드는 읽기만(고치지 않는다 · 위 🔵 줄).

■ 규칙 요약 (이번에 필요한 것만 — 바탕 = 1회차 카드 «규칙 요약» 10 · «■ 테스트 최소 목록» · ■ 제출 · 다르면 이 글이 이긴다)
· 이번에 고치는 곳 = packages/ui_shell/test/handbook_page_view_test.dart 의 B02-02 testWidgets 본문 첫머리 한 줄(상자 1)뿐입니다.
· 🔴 고치면 반려: 그 밖의 전부 — packages/ui_shell/lib/** · 그 테스트 파일의 다른 줄 · 다른 테스트 · PNG · pubspec · packages/domain_contracts/** · apps/** · docs/** 전부(질문 파일 포함).
  🔴 그 밖의 파일이 하나라도 M(또는 ??)이면 git checkout -- <그 파일>(?? 는 지운다) 하고 멈춘 뒤 채팅으로(build/ 는 .gitignore 대상).
· 이번에 걸린 1회차 카드 글자: 테스트 최소 목록 198행 «B02-02 … 두 경우 — live = blocks[1] · no_live = blocks[0] · 전제 live isNotNull // pre» · 196행 «(전제) 4» ·
  규칙 10(107행) «전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다(C4r4b-1) — 자리 = testWidgets 본문 첫머리 · 전제 문장마다 끝에 // pre» · 정적 줄의 뜻 265행 «T34 = 두 줄(3 · 4)».
  → 1회차 B02-02 는 전제 없이 if (live != null) {…} else {…} 로 경우를 갈랐습니다. 표본의 blocks[1] 라이브 값이 없어지면 'live' 경우가 소리 없이 else 로 빠져 통과합니다(C4 탐침으로 확인).
· 그대로인 것(바꾸지 않는다): lib 2파일 · 셸 두 자리 · 공용 3파일 · 다른 테스트 단언 · PNG 8장 · 질문 파일 A1~A5 · 테스트 수(+14 · +20 · +2 · +6 · 전체 +456 — 전제 줄은 테스트를 늘리지 않는다).
· 카드 구멍 C4O-7(골든만 잡힌 예고 변이 P09d · P11)은 이번에 고치지 않습니다 — R16 test-only 묶음(통합 담당) 몫. 테스트를 더하지 않는다.
· 도구: melos.bat run test · melos.bat run test:contracts 는 돌리지 않는다(lib·domain_contracts 무변경 · 1회차 (6) 뒤 몫은 C4 가 다시 돌려 SUCCESS) · 패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · 명령 출력은 파일로 떠서 쓴다(화면에서 손으로 옮겨 적지 않는다).
· 보고 규칙(1회차 카드 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장 = 반려 · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문·라벨을 고치지 않는다 · 보고에는 코드·파일·출력에 실제로 있는 것만 적는다.

■ 잘된 것 — 그대로 유지하십시오
lib 2파일은 카드 «화면» · Key 14 · 받은 글자만 · 항목 수 리터럴 0 · 접기·setState 0 · configHash 0 · handbook:// 조립 0 · 뒤처짐 고지 = 엔진 글자 · asOf 로 고지 숨김 0 · 오래됨 판정 = shellClockProvider 한 곳 · 주입 null 이면 watch 전에 자리표시자 그대로였습니다.
셸 두 자리 = 허용 줄만(shell_router 8/2 · shell_scaffold 5/1 · 기존 s0*·d0* PNG 무변경) · 공용 3파일 더하기만 · 테스트 최소 목록의 다른 항목 단언 전부 · 반려 꼴 0 · C4 사람 grep 셋 0.
골든 8장 390×844 · 배치·잘림 칸 = PNG · dy 744 · 388 · 248 · 116(C4 가 이름마다 다시 잼 · 세 곳 같음) · A5 «측정:» 전·후 행 · flutter test 414 → +456 · analyze 0 · format 0 · domain_contracts +438 ~30 · 경계 실패 0 · 정적 175줄 · 예고 변이 KILLED(정적·표본 동치 3 = 카드 예고대로).
보고에서 맞은 곳 — 섹션 머리 · ① · ② 10항·괄호 · 정적 블록 · S05 · ⓡⓗ · «테스트 파일별:» 접두 0 · ③ 서술 4줄(«» 포함) · 골든 표 · ⑤ · 끝 줄.

■ 왜 반려인가 — 카드 / 실제 (C4 가 분리 worktree 에서 직접 확인 · strict 나눔 ② · 재량 없이 반려)
① C4O-1 B02-02 전제 줄 빠짐 (테스트 결함 · 실효 0)
   카드:  198행 «전제 live isNotNull // pre» · 196행 «(전제) 4» · 107행 «전제는 if 밖 · testWidgets 본문 첫머리 · 끝에 // pre» · 265행 «T34 = 두 줄(3 · 4)».
   실제:  handbook_page_view_test.dart 의 // pre 는 3줄(B02-05 둘 · B02-10 하나) · B02-02 는 전제 없이 if (live != null) {…} else { expect(row, findsNothing); } ·
          1회차 정적 T34 = test/handbook_page_view_test.dart:3(카드 기대 4) — 출력은 사실이었지만 카드 기대와 다른 수를 그대로 붙였다.
   탐침:  표본 handbook_page_sleeve_b.json 의 blocks[1].live 를 null 로 바꾸면 1회차 판 B02-02 두 경우가 모두 통과한다(«+2» · 'live' 경우 공허) · 전제를 넣은 판은 두 경우 모두 실패한다.
   고침:  상자 1(한 줄) — 재드라이런 판과 같은 글자 · 보고 글 견본(정적 T34 줄 · 커밋 줄은 이미 고친 글자다).
함께 고칠 것 — 표기 C4O-2(저장 파일 ④ 한글 깨짐 — 커밋된 질문 파일은 정상)는 아래 «■ 보고 글 견본» 이 이미 고친 글자다(④ = git diff 출력 UTF-8 다섯 줄) · 저장은 WriteAllText 한 꼴.
«재량 없이 반려» = 통합 담당이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것 (저장소 뿌리에서)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시)
  cd packages/ui_shell
  flutter test   ← 시작 기준: 끝 줄 «+456: All tests passed!»(1회차 그대로 · 앞 시각은 달라도 된다). 다르면 아무것도 고치지 말고 멈춘 뒤 끝 20줄을 채팅으로.
  cd ../..

■ 고칠 것 — 상자 1 (1회차 반려 · C4 2026-11-05) — 상자 글자 그대로 · 손으로 다시 짜지 않는다
   파일 = packages/ui_shell/test/handbook_page_view_test.dart(저장소 뿌리 기준) · UTF-8(BOM 없이) · 줄 끝 LF 그대로 · 탭 문자 0 · 줄 끝 빈칸 0.
   🔴 줄을 하나 «더한다» — 기존 줄은 한 글자도 바꾸지 않는다(기준 줄 · 그 아래 «final HandbookLiveValue? live = …» 줄 포함) · 상자 머리·끝 줄(┌── · └──)은 파일에 넣지 않는다.
   🔴 넣는 줄의 blocks[1] 은 숫자 1 그대로다(c.block 이 아니다 — 경우와 상관없이 표본의 'live' 블록에 라이브 값이 있는지를 본다 · 재드라이런 판 글자).
  상자 1 — 161행(B02-02 testWidgets 머리 · 파일에 한 번만 있다) 바로 아래
      ┌── 이 줄 바로 아래에(1줄 · 161행 · 앞 빈칸 4칸 · 바꾸지 않는다)
    testWidgets('B02-02 live value ${c.name}', (WidgetTester tester) async {
      └──
      ┌── 이 줄 하나를 넣는다(1줄 · 새 162행 · 앞 빈칸 6칸)
      expect(sleeveB.blocks[1].live, isNotNull); // pre
      └──

고친 뒤 확인(저장소 뿌리에서 · 커밋하기 전 · 고치지 않고 보기만):
  git status --short   ← 🔴 정확히 한 줄 « M packages/ui_shell/test/handbook_page_view_test.dart» · 다른 줄이 있으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
  git diff --stat      ← 마지막 줄 « 1 file changed, 1 insertion(+)»(빼기 0 · 다르면 상자와 다시 대조)
  git hash-object packages/ui_shell/test/handbook_page_view_test.dart   ← 681d540ad5646b5fbfeb8a6e024f43d0121542a2(C4 수정안 파일의 git 해시 · 다르면 상자와 다시 대조 — BOM · 빈칸 수 · 줄 끝 빈칸에 바뀐다(CRLF 는 git 이 LF 로 바꿔 넣어 해시가 같다))
  git grep -c -F "// pre" -- packages/ui_shell/test/handbook_page_view_test.dart   ← «packages/ui_shell/test/handbook_page_view_test.dart:4»
  cd packages/ui_shell
  dart format --output=none --set-exit-if-changed lib test   ← «(0 changed)» · 바뀐 파일이 1 이상이면 멈추고 출력을 채팅으로(format:fix 로 고치지 않는다)
  flutter analyze --fatal-infos   ← «No issues found!» · 아니면 멈추고 출력을 채팅으로
  cd ../..

■ 커밋 · 사전검사 ① · 푸시 (위 확인이 기대와 같은 뒤 · 저장소 뿌리에서)
  git add packages/ui_shell/test/handbook_page_view_test.dart   ← 🔴 이 한 파일만 · git add . 금지
  git commit -m "[M8] R16b (7) C4 반려 수정 — B02-02 전제"   ← 아래 «커밋 제목» 상자 글자 그대로
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M8] R16b (7) C4 반려 수정 — B02-02 전제
      └── 커밋 제목 복사 끝(이 줄 앞까지)
  git show --stat --format=%s HEAD   ← 첫 줄 = 위 제목 · 파일 줄 «packages/ui_shell/test/handbook_page_view_test.dart | 1 +» 하나 · 끝 줄 « 1 file changed, 1 insertion(+)»
  git rev-parse "HEAD^{tree}"        ← 3656fcd6dfcc5023b48bd4e99f7faa60ac514f7b(= C4 수정안 트리 · 다르면 푸시하지 말고 멈춘 뒤 채팅으로)
  git log --oneline origin/main..HEAD   ← 🔵 origin/main 이 엔진 커밋으로 앞섰어도 7줄 · 맨 위 = 방금 커밋 · 그 아래 6줄 = 90c2e9b … 2b3dbf7(그대로 · 다르면 멈춤)
   🔴 지난 커밋을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.
  dart tool/precheck.dart --base origin/main --collection-if 0
     ← 끝 줄 «── 결과: 🔴 0 · 🟡 0 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)»(C4 시험) · 🔴 가 하나라도 나오면 푸시하지 않고 고치지도 않는다 — 출력 전부를 채팅으로.
  git status --short   ← 🔴 비어 있어야 푸시한다
  git push origin ui/m8-b01-handbook   ← 같은 브랜치 → PR #132 자동 반영 · 새 PR·라벨·강제 푸시·rebase·main 병합 금지
  git rev-parse --short origin/ui/m8-b01-handbook   ← 방금 커밋(git rev-parse --short HEAD 와 같은 해시)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다.

■ 테스트 다시 돌리기 (푸시한 그 커밋 위 · packages/ui_shell 에서 · 결과는 1회차와 같은 수 · 아래 «보고 글 만들기» 가 이 파일들을 읽는다 — 지우지 않는다)
  cd packages/ui_shell
  flutter test test/handbook_contents_test.dart | Out-File -Encoding utf8 $env:TEMP\r16b_t1.txt
  flutter test test/handbook_page_view_test.dart | Out-File -Encoding utf8 $env:TEMP\r16b_t2.txt
  flutter test test/golden/b01_golden_test.dart | Out-File -Encoding utf8 $env:TEMP\r16b_t3.txt
  flutter test test/golden/b02_golden_test.dart | Out-File -Encoding utf8 $env:TEMP\r16b_t4.txt
  flutter test | Out-File -Encoding utf8 $env:TEMP\r16b_t5.txt
     ← 🔴 골든은 --update-goldens 없이
  1..5 | ForEach-Object { Get-Content -Encoding UTF8 "$env:TEMP\r16b_t$_.txt" | Select-Object -Last 1 }
     ← 다섯 줄 «… +14: All tests passed!» · «… +20» · «… +2» · «… +6» · «… +456: All tests passed!»(앞 시각은 달라도 된다 · 1회차와 같은 수)
  (수가 다르거나 실패가 있으면 멈춘 뒤 그 파일 끝 20줄을 채팅으로)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건은 이 카드와 무관 — 그대로 둔다(실패가 있으면 멈추고 출력을 채팅으로)

■ 정적 묶음 — 1회차 카드 225~261행 37줄(main 의 send/R16b-Bob-B01B02.md · 머리 한 줄 표기만 바뀌어 줄 번호 그대로)을 파일로 꺼내 Git Bash 로 돌린다 · 🔴 터미널에 붙여 넣어 돌리지 않는다
  (git status 가 빈 채 · packages/ui_shell 에서)
  cd packages/ui_shell
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R16b-Bob-B01B02.md' | sed -n '225,261p' > ../../build/r16b_static.sh"
  git hash-object ../../build/r16b_static.sh   ← c60027d157f89cfe7fa11de9794cfeeeb16fab4d(1회차와 같은 37줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r16b_static.sh > ../../build/r16b_static_out.txt"
  Select-String -Path ..\..\build\r16b_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r16b_static_out.txt).Count   ← 175(EXIT 줄 37 포함)
  Select-String -Path ..\..\build\r16b_static_out.txt -Pattern '^test/handbook_page_view_test.dart:4$'   ← T34 자리 한 줄(1회차는 :3 이었다)
  git hash-object ../../build/r16b_static_out.txt       ← 751b25cee21dfd26b4c4cad5933b883eb888d1df(= C4 가 같은 트리에서 돌린 출력 = 아래 견본의 «정적 묶음 출력» 블록 175줄 · 1회차와 다른 줄 = T34 한 줄 ·
                                                          같으면 견본 블록을 그대로 쓴다 · 다르면 제출하지 말고 출력 파일 전부를 채팅으로 — 블록을 손으로 고치지 않는다)
  cd ../..

■ 보고 글 만들기 — 견본(아래 «■ 보고 글 견본» · 이 글의 main 판 195~476행)을 기계로 꺼내 자리표시자 6개만 채운다 · 손으로 옮겨 쓰지 않는다 · 저장소 뿌리에서
  [Console]::OutputEncoding = [Text.Encoding]::UTF8
     ← 🔴 이 창에서 다시 한 번(0단계 창과 같아도) — git show · git diff 출력을 UTF-8 로 읽게 한다(1회차 ④ 가 CP949 로 깨진 자리 · C4O-2). git diff 출력을 붙일 때도 이 줄 뒤에만 · Out-String 으로 받아 붙이지 않는다 · 질문 파일 줄은 Get-Content -Encoding UTF8 로 읽는다 · 견본 ④ 는 이미 UTF-8 글자다 — 손대지 않는다
  $tpl = (git show 'origin/main:docs/ai-context/send/R16b-Bob-B01B02-재제출.md' | Select-Object -Skip 194 -First 282) -join "`n"
     ← 🔴 -join "`n" 그대로(빼면 줄이 한 줄로 이어 붙는다)
  $h7 = git rev-parse --short HEAD
  $t = 1..5 | ForEach-Object { Get-Content -Encoding UTF8 "$env:TEMP\r16b_t$_.txt" | Select-Object -Last 1 }
  $out = $tpl.Replace('<H7>', $h7).Replace('<T_HC>', $t[0]).Replace('<T_HP>', $t[1]).Replace('<T_G1>', $t[2]).Replace('<T_G2>', $t[3]).Replace('<ALL_END>', $t[4])
  [IO.File]::WriteAllText("$env:TEMP\R16b-Bob-B01B02_submit.md", $out + "`n", (New-Object Text.UTF8Encoding($false)))
     ← 🔴 이 꼴 그대로(BOM 0 · 줄바꿈·글자 그대로) · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다(1회차 ④ 한글이 깨진 자리)
  (Get-Content -Encoding UTF8 $env:TEMP\R16b-Bob-B01B02_submit.md).Count   ← 282
  Select-String -Path $env:TEMP\R16b-Bob-B01B02_submit.md -Pattern '<H7>|<T_HC>|<T_HP>|<T_G1>|<T_G2>|<ALL_END>'   ← 출력 없음(남은 자리표시자 0)
  Get-Content -Encoding UTF8 $env:TEMP\R16b-Bob-B01B02_submit.md -TotalCount 1   ← «## ① 구현한 화면 ID · 바뀐 파일 · 커밋»
  (Get-Content -Encoding UTF8 $env:TEMP\R16b-Bob-B01B02_submit.md | Select-String -SimpleMatch '| 추측 | 측정:' | Measure-Object).Count   ← 5(④ 다섯 줄 한글이 깨지지 않았다 · 0 이면 저장 꼴이 틀림 — 멈추고 채팅으로)
  (Get-Content -Encoding UTF8 $env:TEMP\R16b-Bob-B01B02_submit.md | Select-String -Pattern '[\uFFFD\u4E00-\u9FFF]' | Measure-Object).Count   ← 0(🔴 깨진 글자 0 자기 확인 — 견본에는 한자도 U+FFFD(«?» 꼴 대체 문자)도 한 글자도 없다 · 1 이상이면 저장 꼴이 틀림(C4 시험: 채운 견본 = 0 · 1회차 저장 파일 = 5 = ④ 다섯 줄) · 내지 말고 채팅으로)
  git -c core.quotePath=false diff --name-status origin/main...HEAD   ← 20줄 = 견본 «바뀐 파일:» 블록 20줄과 같은 글자(1회차와 같음 · 다르면 멈추고 채팅으로)
  git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/B01B02_questions.md | Select-String -Pattern '^\+\|'
     ← 다섯 줄 = 견본 «④ 질문 목록» 블록 다섯 줄과 같은 글자(1회차 커밋 그대로 · 다르면 멈추고 채팅으로)
  🔴 자기 대조 — dy 는 1회차에 이름마다 --plain-name 으로 잰 값이고 lib·PNG 를 고치지 않았으므로 그대로다 · 저장 파일 ③ 골든 표 8행 dy 칸 · ④ A1~A4 · 커밋된 질문 파일(git show HEAD:docs/ai-context/inbox/B01B02_questions.md 의 A1~A4 행)
     세 곳이 744.0 · 744.0 · 388.0 · 388.0 · 248.0 · 248.0 · 116.0 · 116.0(차례 = b01_index light · dark · b02_page · b02_outdated · b02_missing)과 같은지 눈으로 대조 — 하나라도 다르면 내지 말고 채팅으로
  사전검사 ② — 두 번(저장소 뿌리):
  dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R16b-Bob-B01B02_submit.md --golden-prefix b01_ --goldens 2 | Out-File -Encoding utf8 $env:TEMP\r16b_pre2_b01.txt; Get-Content -Encoding UTF8 $env:TEMP\r16b_pre2_b01.txt | Select-Object -Last 1
  dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R16b-Bob-B01B02_submit.md --golden-prefix b02_ --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r16b_pre2_b02.txt; Get-Content -Encoding UTF8 $env:TEMP\r16b_pre2_b02.txt | Select-Object -Last 1
     ← 두 끝 줄 «── 결과: 🔴 0 · 🟡 1 — …» · «── 결과: 🔴 0 · 🟡 1 — …»(C4 시험 = 1회차와 같은 🟡 · PNG 를 열지 않는다 · 칸을 고치지 않는다) ·
       🔴 가 있거나 🟡 수가 이와 다르면 내지 말고 두 출력 전부를 채팅으로.
  채팅 답 = 두 줄뿐: «R16b-Bob-B01B02 재제출 글 저장했음: <(Resolve-Path $env:TEMP\R16b-Bob-B01B02_submit.md).Path 출력>» · 사전검사 ② 끝 줄 둘(« / » 로 이은 한 줄).

■ 보고 글 견본 (다음 줄부터 · 282줄 · 자리표시자 = <H7> · <T_HC> · <T_HP> · <T_G1> · <T_G2> · <ALL_END>)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
화면 ID: B-01 — 전략 핸드북 목차(HandbookContents()) · B-02 — 핸드북 페이지(HandbookPageView(anchor:)) · 주입 shellHandbookRepositoryProvider

바뀐 파일:
```
M	docs/ai-context/inbox/B01B02_questions.md
A	packages/ui_shell/lib/src/handbook/handbook_contents.dart
A	packages/ui_shell/lib/src/handbook/handbook_page_view.dart
M	packages/ui_shell/lib/src/routing/shell_router.dart
M	packages/ui_shell/lib/src/shell_providers.dart
M	packages/ui_shell/lib/src/shell_scaffold.dart
M	packages/ui_shell/lib/ui_shell.dart
A	packages/ui_shell/test/golden/b01_golden_test.dart
A	packages/ui_shell/test/golden/b02_golden_test.dart
A	packages/ui_shell/test/golden/goldens/b01_index_dark.png
A	packages/ui_shell/test/golden/goldens/b01_index_light.png
A	packages/ui_shell/test/golden/goldens/b02_missing_dark.png
A	packages/ui_shell/test/golden/goldens/b02_missing_light.png
A	packages/ui_shell/test/golden/goldens/b02_outdated_dark.png
A	packages/ui_shell/test/golden/goldens/b02_outdated_light.png
A	packages/ui_shell/test/golden/goldens/b02_page_dark.png
A	packages/ui_shell/test/golden/goldens/b02_page_light.png
A	packages/ui_shell/test/handbook_contents_test.dart
A	packages/ui_shell/test/handbook_page_view_test.dart
M	packages/ui_shell/test/shell_fakes.dart
```
커밋 목록:
```
<H7> [M8] R16b (7) C4 반려 수정 — B02-02 전제
90c2e9b [M8] R16b (6) B-01 목차 탭 콜백 정리
e372b2c [M8] R16b (5) 핸드북 여백 조정 · 골든 재생성 · dy 갱신
434a625 [M8] R16b (4) format · 질문
5027a65 [M8] R16b (3) 골든 b01_* 2장 · b02_* 6장
dcc6968 [M8] R16b (2) B-01·B-02 테스트
2b3dbf7 [M8] R16b (1) B-01·B-02 화면 · 셸 핸드북 자리
```

## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 T16 — 허용 밖 import 0줄 · T36 입력·인쇄·공유 패키지 0 · pubspec 무변경(T29))
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] (산술 = null 여부 · 열거 switch 둘(T09) · 오래됨 판정 식 한 줄(B-02 · W-01 꼴) · 항목·블록 수 계산 0 · configHash 비교 0(T11) · 수치 리터럴 0(T18·T19))
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] (DateTime.now 0(T11) · 오래됨 판정 = shellClockProvider 한 곳(T10 · B02-10))
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] (이 카드 범위 밖(5탭·홈·F-01) · 손익 0)
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] (이 카드 범위 밖(알림 = R14) · 뒤처짐 고지 = 받은 글자만(B01-05 · B02-04))
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] (이 카드 범위 밖(DND UI = M9))
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] (이 카드 범위 밖(워치독 = R14b))
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] (시크릿 입력 0 · 입력 위젯 0(T36) · 로컬 상태 0(T11 setState 0))
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] (이 카드 범위 밖(온보딩 = R15))
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] (킬스위치·게이트 자리 0 · 링크 = 받은 링크만(B01-03 · B02-03) · 앱 잠금 = 이 카드 범위 밖(M5))

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
test/golden/b01_golden_test.dart:1
test/golden/b02_golden_test.dart:1
test/handbook_contents_test.dart:9
test/handbook_page_view_test.dart:11
EXIT:0
## T04 link literals in lib 0
EXIT:1
## S05 opener lines (each must be inside a tap callback)
lib/src/handbook/handbook_contents.dart:102:        ref.read(shellLinkOpenerProvider).open(link);
lib/src/handbook/handbook_page_view.dart:108:            ref.read(shellLinkOpenerProvider).open(link);
EXIT:0
## T06 source lines (2)
lib/src/handbook/handbook_contents.dart:18:      (Ref ref) => ref.watch(shellHandbookRepositoryProvider)!.watchIndex(),
lib/src/handbook/handbook_page_view.dart:19:          ref.watch(shellHandbookRepositoryProvider)!.watchPage(anchor),
EXIT:0
## T07 commands and other repositories 0
EXIT:1
## T08 handbook slots in shell (2)
lib/src/routing/shell_router.dart:216:        child: HandbookPageView(
lib/src/shell_scaffold.dart:344:                  child: HandbookContents(),
EXIT:0
## T09 HandbookEntryState UiLevel arms (3 5)
lib/src/handbook/handbook_contents.dart:106:      HandbookEntryState.ready => (Icons.menu_book_outlined, cs.primary),
lib/src/handbook/handbook_contents.dart:107:      HandbookEntryState.preparing => (
lib/src/handbook/handbook_contents.dart:111:      HandbookEntryState.archived => (Icons.inventory_2_outlined, cs.outline),
lib/src/handbook/handbook_page_view.dart:137:  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
lib/src/handbook/handbook_page_view.dart:138:  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
lib/src/handbook/handbook_page_view.dart:139:  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
lib/src/handbook/handbook_page_view.dart:140:  UiLevel.act => (Icons.pending_actions_outlined, cs.secondary),
lib/src/handbook/handbook_page_view.dart:141:  UiLevel.blocked => (Icons.block, cs.error),
EXIT:0
## T10 clock lines (1)
lib/src/handbook/handbook_page_view.dart:53:    final Clock clock = ref.watch(shellClockProvider);
EXIT:0
## T11 forbidden words in new files 0
EXIT:1
## T12 asOf gating the outdated notice 0
EXIT:1
## T13 shell labels (37)
lib/l10n/labels.dart:37
EXIT:0
## T14 barrel exports
lib/ui_shell.dart:13:export 'l10n/labels.dart';
lib/ui_shell.dart:14:export 'src/alerts/alert_center.dart';
lib/ui_shell.dart:15:export 'src/alerts/alert_detail.dart';
lib/ui_shell.dart:16:export 'src/handbook/handbook_contents.dart';
lib/ui_shell.dart:17:export 'src/handbook/handbook_page_view.dart';
lib/ui_shell.dart:18:export 'src/incident/emergency_stop_card.dart';
lib/ui_shell.dart:19:export 'src/incident/incident_banner.dart';
lib/ui_shell.dart:20:export 'src/incident/runbook_detail.dart';
lib/ui_shell.dart:21:export 'src/incident/runbook_list.dart';
lib/ui_shell.dart:22:export 'src/onboarding/onboarding_finish.dart';
lib/ui_shell.dart:23:export 'src/onboarding/onboarding_mode_pick.dart';
lib/ui_shell.dart:24:export 'src/onboarding/onboarding_restart.dart';
lib/ui_shell.dart:25:export 'src/onboarding/onboarding_start.dart';
lib/ui_shell.dart:26:export 'src/onboarding/onboarding_step_detail.dart';
lib/ui_shell.dart:27:export 'src/onboarding/onboarding_step_list.dart';
lib/ui_shell.dart:28:export 'src/onboarding/viewer_pairing.dart';
lib/ui_shell.dart:29:export 'src/ops_home.dart';
lib/ui_shell.dart:30:export 'src/ops_rhythm.dart';
lib/ui_shell.dart:31:export 'src/routing/shell_router.dart';
lib/ui_shell.dart:32:export 'src/shell_providers.dart';
lib/ui_shell.dart:33:export 'src/shell_scaffold.dart';
lib/ui_shell.dart:34:export 'src/watchdog_board.dart';
EXIT:0
## T15 shell providers
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
lib/src/shell_providers.dart:159:final Provider<OnboardingRepository> shellOnboardingRepositoryProvider =
lib/src/shell_providers.dart:166:final Provider<SettingsActions?> shellOnboardingActionsProvider =
lib/src/shell_providers.dart:177:final Provider<ShellSlotBuilder?> shellOnboardingSlotBuilderProvider =
lib/src/shell_providers.dart:186:final Provider<PairingRepository> shellPairingRepositoryProvider =
lib/src/shell_providers.dart:195:final Provider<IncidentRepository?> shellIncidentRepositoryProvider =
lib/src/shell_providers.dart:198:final Provider<RunbookRepository> shellRunbookRepositoryProvider =
lib/src/shell_providers.dart:205:final Provider<ShellSlotBuilder?> shellOpsSlotBuilderProvider =
lib/src/shell_providers.dart:210:final Provider<HandbookRepository?> shellHandbookRepositoryProvider =
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
test/handbook_contents_test.dart:8
test/handbook_page_view_test.dart:10
EXIT:0
## T21 H lines (hasLength)
test/handbook_contents_test.dart:2
test/handbook_page_view_test.dart:1
EXIT:0
## T22 b01 b02 key names
lib/src/handbook/handbook_contents.dart:35:b01-fail
lib/src/handbook/handbook_contents.dart:44:b01-loading
lib/src/handbook/handbook_contents.dart:55:b01-outdated
lib/src/handbook/handbook_contents.dart:68:b01-entry
lib/src/handbook/handbook_contents.dart:71:b01-state
lib/src/handbook/handbook_contents.dart:81:b01-entry
lib/src/handbook/handbook_contents.dart:85:b01-state
lib/src/handbook/handbook_page_view.dart:40:b02-fail
lib/src/handbook/handbook_page_view.dart:50:b02-loading
lib/src/handbook/handbook_page_view.dart:66:b02-asof
lib/src/handbook/handbook_page_view.dart:68:b02-stale
lib/src/handbook/handbook_page_view.dart:71:b02-outdated
lib/src/handbook/handbook_page_view.dart:83:b02-title
lib/src/handbook/handbook_page_view.dart:89:b02-missing
lib/src/handbook/handbook_page_view.dart:104:b02-block
lib/src/handbook/handbook_page_view.dart:117:b02-live
EXIT:0
## T23 banned vocabulary in code 0
EXIT:1
## T24 Colors files 0
EXIT:1
## T25 rich text and trimming 0
EXIT:1
## T26 autoDispose 0
EXIT:1
## T27 Scaffold AppBar Navigator in handbook 0
EXIT:1
## T28 (unused)
EXIT:1
## T29 shared files add-only and frozen files (numstat)
8	2	packages/ui_shell/lib/src/routing/shell_router.dart
5	0	packages/ui_shell/lib/src/shell_providers.dart
5	1	packages/ui_shell/lib/src/shell_scaffold.dart
2	0	packages/ui_shell/lib/ui_shell.dart
97	0	packages/ui_shell/test/shell_fakes.dart
EXIT:0
## T30 implements in new tests 0
EXIT:1
## T31 copyWith in tests 0
EXIT:1
## T32 collection-if in tests 0
EXIT:1
## T33 golden files
A	packages/ui_shell/test/golden/goldens/b01_index_dark.png
A	packages/ui_shell/test/golden/goldens/b01_index_light.png
A	packages/ui_shell/test/golden/goldens/b02_missing_dark.png
A	packages/ui_shell/test/golden/goldens/b02_missing_light.png
A	packages/ui_shell/test/golden/goldens/b02_outdated_dark.png
A	packages/ui_shell/test/golden/goldens/b02_outdated_light.png
A	packages/ui_shell/test/golden/goldens/b02_page_dark.png
A	packages/ui_shell/test/golden/goldens/b02_page_light.png
EXIT:0
## T34 precondition marks (pre)
test/handbook_contents_test.dart:3
test/handbook_page_view_test.dart:4
EXIT:0
## T35 bare takeException 0
EXIT:1
## T36 input print share widgets in handbook 0
EXIT:1
## T37 golden PNG b01 b02 (8)
8
EXIT:0
```

S05 결과:
lib/src/handbook/handbook_contents.dart:102 — 탭 콜백 안
lib/src/handbook/handbook_page_view.dart:108 — 탭 콜백 안

ⓡ = T20 출력:
test/handbook_contents_test.dart:8
test/handbook_page_view_test.dart:10
ⓗ = T21 출력:
test/handbook_contents_test.dart:2
test/handbook_page_view_test.dart:1

테스트 파일별:
<T_HC>
<T_HP>
<T_G1>
<T_G2>

명령 결과(재제출 커밋 (7) 위): check_boundaries 실패 0(ui_journal 🟡 1건은 main 에 원래 있는 것) · packages/ui_shell 에서 dart format --output=none --set-exit-if-changed lib test 0 changed · flutter analyze --fatal-infos «No issues found!» · flutter test 끝 줄 = 아래 · (7) 은 test/handbook_page_view_test.dart 에 한 줄만 더했다(lib·domain_contracts·PNG 무변경 — melos run test:contracts 는 재제출 패킷 지시대로 다시 돌리지 않았다)

## ③ 스크린샷 서술 · 골든 표
«B-01 목차» = ListView → Key('b01-outdated')(있을 때) → ValueKey<String>('b01-entry-$i')(안에 ValueKey<String>('b01-state-$i')) → ValueKey<String>('b01-entry-$i-$j')(있을 때 · 안에 ValueKey<String>('b01-state-$i-$j'))
«B-02 페이지» = ListView → ShellAsOfHeader(Key('b02-asof'))(있을 때) → ShellStaleBanner(Key('b02-stale'))(있을 때) → Key('b02-outdated')(있을 때) → Key('b02-title') → Key('b02-missing')(있을 때) → ValueKey<String>('b02-block-$i')(있을 때 · 안에 ValueKey<String>('b02-live-$i')(있을 때))
«셸 핸드북 자리» = ShellRouteBody → Key('s01-handbook-slot') → HandbookPageView(anchor:) · _WebBody IndexedStack → Key('s02-handbook-slot') → HandbookContents()
«로딩·에러» = ShellSkeleton(Key('b01-loading') · Key('b02-loading')) · ShellErrorView(Key('b01-fail') · Key('b02-fail'))

| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |
|---|---|---|---|---|---|
| b01_index light | handbook_index.json | 없음 | 390×844 | 744.0 | 아이콘 · 글자 1줄 ×3 → 아이콘 · 글자 2줄 → 아이콘 · 글자 1줄 → 아이콘 · 글자 2줄 → 아이콘 · 글자 1줄 ×3 → 아이콘 · 글자 2줄 ×3 — 잘림 없음 |
| b01_index dark | handbook_index.json | 없음 | 390×844 | 744.0 | 아이콘 · 글자 1줄 ×3 → 아이콘 · 글자 2줄 → 아이콘 · 글자 1줄 → 아이콘 · 글자 2줄 → 아이콘 · 글자 1줄 ×3 → 아이콘 · 글자 2줄 ×3 — 잘림 없음 |
| b02_page light | handbook_page_sleeve_b.json | 없음 | 390×844 | 388.0 | 글자 1줄 → 글자 1줄 → 글자 2줄 → 아이콘 · 글자 3줄 → 글자 2줄 → 글자 2줄 → 글자 2줄 — 잘림 없음 |
| b02_page dark | handbook_page_sleeve_b.json | 없음 | 390×844 | 388.0 | 글자 1줄 → 글자 1줄 → 글자 2줄 → 아이콘 · 글자 3줄 → 글자 2줄 → 글자 2줄 → 글자 2줄 — 잘림 없음 |
| b02_outdated light | handbook_page_outdated.json | 없음 | 390×844 | 248.0 | 아이콘 · 글자 3줄 → 글자 1줄 → 글자 2줄 → 글자 2줄 — 잘림 없음 |
| b02_outdated dark | handbook_page_outdated.json | 없음 | 390×844 | 248.0 | 아이콘 · 글자 3줄 → 글자 1줄 → 글자 2줄 → 글자 2줄 — 잘림 없음 |
| b02_missing light | handbook_page_missing.json | 없음 | 390×844 | 116.0 | 글자 1줄 → 글자 2줄 — 잘림 없음 |
| b02_missing dark | handbook_page_missing.json | 없음 | 390×844 | 116.0 | 글자 1줄 → 글자 2줄 — 잘림 없음 |

## ④ 질문 목록
```
+| A1 | R16b-Bob-B01B02 | 추측 | 측정: b01_index dy 실측값 (light=744.0, dark=744.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A2 | R16b-Bob-B01B02 | 추측 | 측정: b02_page dy 실측값 (light=388.0, dark=388.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A3 | R16b-Bob-B01B02 | 추측 | 측정: b02_outdated dy 실측값 (light=248.0, dark=248.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A4 | R16b-Bob-B01B02 | 추측 | 측정: b02_missing dy 실측값 (light=116.0, dark=116.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A5 | R16b-Bob-B01B02 | 추측 | 측정: 제목·모르는 앵커 문장 여백 조정 전 후 dy (b02_page 396.0 에서 388.0 · b02_outdated 256.0 에서 248.0 · b02_missing 108.0 에서 116.0 · b01_index 744.0 변화 없음) | 여백 재량(12 §3 ⓓ) | 조정 후 값이 카드 기대 dy 와 같음 | ⬜ 미답 | |
```

## ⑤ 추측한 것 목록
없음

flutter test: 시작 기준 414 → 끝 <ALL_END>
■ 보고 글 견본 끝(이 줄 앞까지)
(채팅 답 = 위 두 줄뿐 · 보고 글 전문은 저장 파일에만)
````

---

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R16b-Bob-B01B02 재제출: PR #132 에 푸시됨 — 병합 검사해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R16b-Bob-B01B02_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계 · 상자 1 확인에서 멈췄다면 `R16b-Bob-B01B02 재제출 <단계>에서 멈춤 — 확인해줘` + 출력.

## 5. C4 2회차 대조 기대(통합 담당 몫 · Bob 에게 보내지 않음)

- 새 커밋 1 · 파일 1(`packages/ui_shell/test/handbook_page_view_test.dart` +1/−0 · B02-02 `testWidgets(` 머리 바로 아래) · blob `681d540ad5646b5fbfeb8a6e024f43d0121542a2` · `HEAD^{tree}` `3656fcd6dfcc5023b48bd4e99f7faa60ac514f7b` · 지난 6커밋 해시 그대로.
- 저장 파일 ↔ 견본: 다른 곳 = 자리표시자 6 자리뿐(커밋 해시 · 시각 칸) · UTF-8 · BOM 0 · LF · 282줄 · ④ 한글 정상(«추측» 5).
- 정적 출력 blob `751b25c`(T34 `3 · 4`) · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0 · 🟡 1 · 1 · `flutter test` +14 · +20 · +2 · +6 · 전체 +456 · C4 사람 grep 셋 0.
- C4 2회차 기계 갈래: dy 를 `lessThan(0)` 임시 + `--plain-name` 으로 이름마다 다시 잰다(C4r16a-4 · 기대 744 · 388 · 248 · 116) · 탐침(표본 `blocks[1].live` → null → B02-02 두 경우 실패)으로 전제가 서는지 본다.
- 병합 때 PR 본문(재제출 글) ① 커밋 목록 아래 «C4 정정» 한 줄 = 커밋 (5) `e372b2c` 제목에 없는 `_entryTile` 추출 · 최상위 여백 16/16 → (6) `90c2e9b` 가 되돌림(C4O-3 · squash 영향 0).
- 병합 기록 = C4 보고 §7-M(원 카드 + 이 패킷을 함께 `_완료/` · R16c 승격 · golden README «R16» R16b 병합본 실측 줄).
