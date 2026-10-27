# 발송 패킷 R13a-Bob-S01H02 — 재제출 (1회차 반려 · 2026-10-26)

> ⬜ **「푸시해」 뒤 보냄** — 이 파일이 GitHub `main` 의 `send/` 에 있으면 이 조건은 풀린 것(이 패킷과 원 패킷의 `send/_완료/` 이동이 `main` 에 올라간 뒤 · 다른 선행 없음 — PR #71 반려 댓글 게시됨(2026-10-26 · issuecomment-6418982474) · 아래 «보내는 조건» · `send/README.md` 배지 규칙).
> 만든 날 2026-10-27 · 1회차(PR #71 · 브랜치 `ui/m8-s01-shell` · 커밋 `1195787` · 밑동 `b341aa8` · 커밋 9 · CI run 40329562992 = 경계 규칙·골든 스냅샷·분석·테스트(melos) 3/3 pass)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-26): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #71 · Bob 이 상자 1~17 을 **lib 1 + test 4 파일 커밋 1개**로 · PNG 0 · 질문 파일 0 · 지난 9커밋 그대로 · amend·rebase·force 금지) ② **카드 구멍 보강을 함께 넣는다**(C4s-17 · 상자 17 = T02-05 `not_loaded_stale` 경우 1개 · 기대 끝 줄 +65 → **+66**) ③ 프롬프트 v2 를 이 반려 기록보다 먼저 푸시(✅ 앱 `34bf60a` — 이 재제출은 프롬프트를 다시 읽지 않으므로 `main` 의 `prompt_M8.md` 가 v2(183줄) 판이어도 무관하다).
> 고치는 것 = **`packages/ui_shell/` 의 파일 다섯**(`lib/src/shell_scaffold.dart` · `test/golden/s01_golden_test.dart` · `test/ops_rhythm_test.dart` · `test/shell_router_test.dart` · `test/shell_scaffold_test.dart` — 아래 상자 1~17 = «이 줄을 → 이 줄로» · 합 +167/−92) **+ 채팅 글 ①~⑤ 전체판** — PNG 0 · 그 밖의 lib·테스트·가짜(`test/shell_fakes.dart`)·`test/golden/h02_golden_test.dart`·비교기 2파일·질문 파일 `inbox/S01H02_questions.md` 0(A1~A4 행·머리말 그대로 · 답은 병합 때 통합 담당) · PR 본문·라벨 0(통합 담당이 PR 본문을 이 글로 통째로 바꾼다). 같은 브랜치 · 같은 PR #71(새 PR·새 브랜치 금지) · 커밋은 맨 위에 1개.
> 판정 근거 = C4 보고 §0(설계 저장소 `10_리뷰/2026-10-26_R13a_C4_보고.md`) — 1회차 카드 strict 나눔(카드 169행 · ② 코드·테스트 결함과 거짓 주장 = 반려 · ③ 예고 변이 통과 = 반려). [가] ③ **C4s-1** TS-07 에 «s01-tabs 0(NavigationBar 0)» 의 `find.byType(NavigationBar)` 단언이 없어 예고 변이 «웹에 NavigationBar»(갈래 X `S23`)가 65/65 통과 · ② lib **C4s-2** 웹 사이드바 모드 칩에 띠 칩 Key `s01-band-chip-$i`(카드 Key 표 399·404행 · 웹에서 같은 Key 2개) · ② 테스트 **C4s-3~10**(TR-08·TS-04 흐름 = bool 칸 + if/else · TS-04 advisory ⓡ 없음 · T02-01 사슬 dy 가 row-0 에서 멈춤·`>=` · T02-05 재시도 want 누락 · 경우 이름 비교(TS-08 · s01 골든) · TR-07 journalTimeline 뒤 DummyBody 0 누락 · TR-03 `// pre` 자리 · 값 안 내는 StreamController teardown 없음 — 실효는 작거나 0 이지만 카드가 글자로 정한 자리). [나] 표기 C4s-11~15 = 아래 «■ 보고 글» 조각으로 고친다 · C4s-16(커밋 (7)~(9) 가 (5) 뒤 · (8) 제목 ≠ 내용)은 고치지 않는다(병합 때 C4 정정). 카드 구멍 C4s-17(T02-05 에 «빈 + 오래됨» 경우 없음 · 반려 사유 아님) = 발주자 결정 ② 로 상자 17. 거짓 주장 0 · 골든 8장 = 카드 드라이런 8장과 바이트 같음 · 합친 트리(main `fc25f77` + `1195787`) 깨짐 0.
> 🔴 **재제출 조문(12 §3) = 전체판 + 바뀔 자리만 상자** — Bob 은 보고 글 ①~⑤ 를 처음부터 끝까지 다시 낸다. 글자는 이 패킷 «■ 보고 글» 의 조각 1~22 뿐이다 — [상자] = 복사 상자 글자 그대로(바뀌지 않는 자리 = 1회차 Bob 글자를 기계로 옮긴 상자 · 바뀌는 자리 = C4 가 준 상자) · [출력] = 다시 돌린 명령 출력을 그대로 · [틀] = <…> 자리에만 출력. 상자·출력 밖의 글 0.
> 🔴 **PNG 열람 0**(Bob 사정 — 한 대화 이미지 20장 한도 · 대화 길이 한도) — 이 재제출은 PNG 를 바꾸지 않는다(상자 1 은 골든이 없는 웹 사이드바 · 상자 2~4 는 위치 전제의 머리 Finder 를 칸으로 옮길 뿐 · C4 가 `--update-goldens` 없이 s01 4 · h02 4 통과 확인). 골든 표 8행은 C4 상자(조각 18)로 주고, 사전검사 ② 의 🟡 1 + 1(G1 — 괄호가 든 칸)도 PNG 를 열지 않고 그대로 둔다. 본문도 짧은 상자·명령·기대 출력으로만 썼다.
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기를 돌린다. Bob 의 푸시가 CI 를 다시 돌린다. 이 카드는 새 PNG 만이라 `golden:approved` 는 필요 없다(기존 PNG M 0 · `ui_shell` 첫 골든).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R13a-Bob-S01H02.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R13a 행·재제출 행 · `rounds.md` R13a 행·재제출 행과 **같은 푸시**로 `main` 에 올린다(0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/S01H02_questions.md` · golden README · `packages/ui_shell/README.md` · `send/_대기/R13b-Bob-H01.md` · 01~05 사본은 건드리지 않는다(병합 때).
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R13a-Bob-S01H02.md` 는 `send/` 에 없음). 확인 = `git cat-file -t origin/main:docs/ai-context/send/R13a-Bob-S01H02-재제출.md`(= `blob`) · PR #71 «Conversation» 에 C4 반려 댓글(«C4 판정 — R13a-Bob-S01H02 1회차(`1195787`): 반려 → 재제출»)이 있다(게시됨 · issuecomment-6418982474) · 그 밖의 선행(infra PR 등)은 없다.
> C4 수정안 시험(2026-10-26 · 통합 담당 분리 worktree `C:/Work/AAQ-claude-r13aj` @ `1195787` · 임시 커밋 `c167937`(어느 가지에도 없음) · 끝에 삭제): 상자 1~16 과 같은 글자(`judge/fix.diff` · +153/−92)를 넣고 `flutter test` 파일별 «+18» · «+24» · «+14» · «+4» · «+4» · 전체 «00:08 +65: All tests passed!» · `flutter analyze --fatal-infos` No issues found! · `dart format` 0 changed · PNG 불변(`--update-goldens` 없이 통과) · 변이 재실행 = 카드 유효 75 중 KILLED 74(**S23 KILLED** — TS-07 · 남은 1 = `H15b` 카드 구멍) · 약해진 꼴 0 · 사전검사 ① 🔴 0 · 🟡 0 · 합친 트리(`fc25f77` 위) ui_shell +65 · analyze 0. 상자 17(`judge/fix_extra.diff` · +14/−0)을 더한 판 = ops_rhythm «+15» · 전체 «00:13 +66: All tests passed!» · analyze 0 · **`H15b` KILLED**(T02-05 not_loaded_stale). 안 돌린 것 = `melos.bat run test`(중첩 melos · CI 몫).
> 조립 확인(2026-10-27 · Claude): 아래 상자 1~17 을 이 파일에서 다시 읽어 `1195787` 판에 상자대로(파일마다 아래쪽부터) 적용한 결과 = C4 수정안(`judge/fix.diff` + `judge/fix_extra.diff`) 5파일과 **바이트 같음**(파이썬 · blob `c3921f8` · `8c7774a` · `1b059e8` · `b52fecc` · `9b39969`) · «이 줄을» 묶음 17개는 각 파일에 한 곳뿐(`1195787` 판에서도 · 앞 상자를 고친 판에서도) · 그 판을 임시 커밋(어느 가지에도 없음 · 확인 뒤 worktree 삭제)으로 올려 잰 것 = `git diff --stat` « 5 files changed, 167 insertions(+), 92 deletions(-)» · `dart format` «Formatted 5 files (0 changed)» · 정적 34줄 출력 = C4 수정안 출력과 같음(197줄 · warning 4줄 뺌 · 1회차와 다른 곳 = S07 · S22 · S29 줄 번호뿐) · 사전검사 ① 🔴 0 · 🟡 0 · 아래 조각 1~22 를 기대 출력으로 이어 붙인 판의 사전검사 ② = s01_ 🔴 0 · 🟡 1 · h02_ 🔴 0 · 🟡 1(둘 다 [G1] «배치·잘림 칸을 덩어리로 셀 수 없어 PNG 와 대조하지 않았다» — 괄호 안 «·» 나열·«빈 자리» 가 든 칸 · 멈춤 아님 · C4 미리보기 `judge/resubmit_preview.md` 와 같은 수 — 그 미리보기는 상자 17 이전 판이라 🟡 수만 같고 글자 기준으로는 쓰지 않는다 · «5. 주의»).

## 0. 한 줄 목적

PR #71 의 `packages/ui_shell` 파일 다섯을 상자 1~17 글자대로 고쳐 커밋 1개로 올리고, 보고 글 ①~⑤ 를 **전체판**(바뀔 자리만 새 상자 · 나머지는 1회차 글자 상자)으로 다시 내기 — **PNG·가짜·`h02_golden_test.dart`·질문 파일은 한 글자도 바꾸지 않고, PNG 는 한 장도 열지 않고, 지난 9개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m8-s01-shell` · 같은 PR #71 · 🔴 **새 대화**.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). PR #71 의 C4 반려 댓글은 이미 올라가 있습니다(issuecomment-6418982474).
2. Bob 은 **새 대화(new task)** 로 시작합니다 — 1회차 대화는 이어 쓰지 않습니다(이미지 20장·대화 길이 한도 · 멈춘 대화는 강제 중지). 본문은 Bob 이 1회차를 기억하지 못한다는 전제로 썼고, 1회차 글자는 이 패킷의 복사 상자에 다 들어 있어 1회차 글이나 원 카드·프롬프트를 따로 붙여 줄 필요가 없습니다. Bob 폴더는 지금 `ui/m8-s01-shell` `1195787` 입니다(2026-10-27 Claude 확인 — `git worktree list` · 0단계가 다시 본다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R13a-Bob-S01H02-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r13rec\docs\ai-context\send\R13a-Bob-S01H02-재제출.md` · 가지 `rec/r13` · 2026-10-27 Claude 작성 · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R13a-Bob-S01H02.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ```text 다음 줄(«R13a-Bob-S01H02 재제출 요청»)부터 닫는 ``` 직전 줄까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R13a 패킷은 **이것 하나**(`R13a-Bob-S01H02-재제출.md`)입니다. 원 패킷 `R13a-Bob-S01H02.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). `send/_대기/R13b-Bob-H01.md` 는 R13a 병합 뒤 카드이고, 이름이 비슷한 `_완료/R4b-Bob-H62H63-재제출.md` · `_완료/R3-Bob-J4-재제출.md` 는 끝난 카드입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R13a-Bob-S01H02 재제출 요청»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R13a-Bob-S01H02 재제출 요청 — 1회차(PR #71 · 1195787) 판정: 반려(재제출). 같은 브랜치 ui/m8-s01-shell · 같은 PR #71 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 packages/ui_shell 의 파일 다섯(lib/src/shell_scaffold.dart 1 · test 4 — 아래 상자 1~17 글자 그대로 · 합 167줄 더하기 · 92줄 빼기)과
  채팅 보고 글 ①~⑤ 전체판(아래 «■ 보고 글» 의 조각 1~22 그대로)뿐입니다.
🔴 PNG 0 · 위 다섯 파일 밖 0(질문 파일 포함) · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.
🔴 PNG 를 한 장도 열지 않습니다(이미지 0장) — 이 재제출은 PNG 를 바꾸지 않고, 골든 표는 통합 담당이 맞춘 상자로 줍니다. --update-goldens 도 돌리지 않습니다.
🔴 다른 카드·문서·프롬프트를 읽지 않습니다 — 1회차 카드의 규칙 중 이번에 필요한 것은 이 글에 다 옮겼습니다(main 의 docs/ai-context/prompt_M8.md 가 새 판(183줄)으로 바뀌었어도 이 재제출과 무관 — 열지 않는다).
   이 글과 1회차 카드가 다르면 이 글이 이깁니다.

■ 0단계 — 대상 확인 (새 대화이므로 아무것도 읽기 전에 이것부터)
이 글은 R13a 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m6-* · ui/m7-*)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #71 · 브랜치 ui/m8-s01-shell(커밋 1195787)에 아래 상자 1~17 커밋 하나를 «더하는» 일입니다. 상자 1~17 은 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돕니다.
🔴 1회차 카드의 «마지막 커밋 = format · 질문 파일» · «(5) 뒤 커밋 0(예외 = 사전검사 ① 🔴 수정 커밋 (6))» 은 이번에 이 글이 덮습니다 — 재제출 커밋 (10) 1개(제목 = 아래 «커밋 제목» 상자)를 맨 위에 더하는 것이 이번 일입니다.
   지난 9개 커밋(1195787 · fcb54fc · 064ad8b · 4042db3 · 1144f4d · 52686c7 · 296ec26 · 89ee073 · 83f34a4 — 순서·제목 포함 · (7)~(9) 가 (5) 뒤에 들어간 것 · (8) 제목이 내용과 다른 것도 그대로 — 통합 담당이 병합 때 PR 본문에 적는다)은 그대로 둡니다(고치려 하면 반려).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m8-s01-shell 이 아니면(status 가 빈 것을 본 뒤) git checkout ui/m8-s01-shell
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git rev-parse --short HEAD    ← 1195787 이면 정상 · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m8-s01-shell   ← 1195787 · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R13a-Bob-S01H02-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R13a-Bob-S01H02.md 줄이 없으면 = 이 글이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _대기 · _완료 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R13a-Bob-S01H02-» 로 시작하는 줄이 있으면 정상.
        «R13a-Bob-S01H02-재제출» 줄이 없거나 꼬리 없는 «R13a-Bob-S01H02.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 이 글이 먼저 왔습니다.
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
이 브랜치에 있는 docs/ai-context/send/R13a-Bob-S01H02.md(1회차 카드 — main 에서는 send/_완료/R13a-Bob-S01H02.md 로 옮겨졌다 · 머리 첫 줄의 반려 표기 말고는 글자가 같다)와
  docs/ai-context/prompt_M8.md 는 열지 않습니다(대화 길이 한도 — 규칙을 다시 읽을 필요는 없고, 이번에 필요한 글자는 이 글에 다 있다).

■ 규칙 요약 (이번에 필요한 것만 — 바탕 = 1회차 카드 규칙 요약(92~175행 · 이번에 걸린 곳 = 규칙 10 의 123·125·132·133행 · 테스트 공통 427행 · Key 표 399~404행) · ■ 제출(638~739행) · 다르면 이 글이 이긴다)
· 이번에 고치는 곳 = 아래 다섯 파일뿐입니다(packages/ui_shell/ 안).
    lib/src/shell_scaffold.dart          (상자 1 — 웹 사이드바 모드 칩의 Key 빼기)
    test/golden/s01_golden_test.dart     (상자 2·3·4 — 위치 전제 머리 = _Flow 의 top 칸)
    test/ops_rhythm_test.dart            (상자 5·6·7·17 — T02-01 사슬 dy · T02-05 loading teardown · T02-05 재시도 단언 · T02-05 not_loaded_stale 경우)
    test/shell_router_test.dart          (상자 8·9·10 — TR-03 // pre 자리 · TR-07 DummyBody 0 · TR-08 흐름 클로저)
    test/shell_scaffold_test.dart        (상자 11~16 — TS-04 흐름 클로저 + 공통 ⓡ · TS-06 loading teardown · TS-07 NavigationBar 0 · TS-08 platform 칸)
· 🔴 고치면 반려: 위 다섯 파일 밖의 전부 — lib/ 의 다른 파일 · test/golden/goldens/*.png 전부(🔴 PNG 0 · --update-goldens 를 돌리지 않는다 · PNG 를 열지 않는다) ·
  test/shell_fakes.dart · test/golden/h02_golden_test.dart · test/flutter_test_config.dart · test/golden/shift_tolerant_compare.dart · test/golden/golden_support.dart · test/golden/README.md · test/ui_shell_test.dart ·
  domain_contracts/** · apps/** · 다른 ui_* · pubspec.yaml · analysis_options.yaml · docs/ai-context/**(질문 파일 inbox/S01H02_questions.md 포함).
  🔴 PNG 나 그 밖의 파일이 하나라도 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 테스트 규칙(1회차 카드 — 이번에 걸린 곳만 글자 그대로):
   427행 «… 경우의 흐름 = 클로저 칸(bool 칸 + if 금지 · C4r3-4) …»
   123행 «… 경우 칸에 픽스처·스트림 공장·시계를 직접 · caseName 이름 비교 if 사슬 0 — C4r4b-6»
   125행 «… 전제 문장마다 끝에 주석 `// pre`(ASCII · 문장이 여러 줄이면 마지막 줄 끝) — 정적 S32 가 파일마다 센다 …»
   132행 «… «<» 를 «<=» 로 · «N개» 를 greaterThanOrEqualTo 로 바꾸지 않는다» · 133행 «늦게 구독되거나 값을 끝까지 내지 않는 StreamController 의 teardown = addTearDown(() { unawaited(ctrl.close()); }).»
   ⓡ = expect(find.text(ShellLabels.retry), findsNothing); 줄 · ⓗ = hasLength( 줄 · 전제 = 끝이 // pre 인 줄 — 정적 S20·S21·S32 가 정확히 7·8 · 1·1 · 6·3·4 이어야 한다
     (상자 1~17 은 이 셋의 수를 바꾸지 않는다 — 상자 12 는 ⓡ 줄을 else 안에서 경우 공통 자리로 옮길 뿐 · 상자 8 은 // pre 표식을 옮길 뿐 · 상자 7 의 재시도 단언은 want 꼴이라 S20 셈 밖) ·
   testWidgets·test 줄 수도 그대로(S02c 1 · 1 · 8 · 12 · 9) · 테스트 이름 그대로(새 경우 = 상자 17 의 not_loaded_stale 하나 — 테스트 이름 «T02-05 not_loaded_stale» 은 기존 for 가 만든다) ·
   테스트에 한국어 리터럴 0 · if 를 새로 쓰지 않는다 · 새 가짜·새 도우미 파일 0.
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
  🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 · 패키지 테스트는 packages/ui_shell 에서 flutter test 직접.
· 보고 규칙(1회차 카드 169행 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당(C4)이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음) · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 섹션 머리 ①~⑤ 는 «■ 보고 글» 상자 글자 그대로).
  🔴 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 «모든 확인 완료 …» 같은 섹션 밖 글이나 --- 를 두지 않는다(1회차 카드 672행 N1).
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 글이 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.
   🔴 git log · git diff · flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
      <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채).
   🔴 $env:TEMP 에 쓸 수 없으면 저장소 뿌리의 build\<이름>.txt 에 쓴다(루트 .gitignore 의 build/ 대상 — git status 는 빈 채 · 커밋하지 않는다 · 이 글의 $env:TEMP\… 자리를 모두 build\… 로 읽는다).

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다(아래 C4s-2 한 곳 밖) — 새 파일 5 · 주입 구조 · 가드 표(const Set 넷) · matchShellRoute · ShellLinkOpener · ShellRoot 갈래 · 웹 사이드바가 Navigator 바깥 · 띠(stretch · isSim 톤) ·
  H-02(watchRhythm 하나 · 신선도 한 식 · 열 둘 · 빈 갈래) · 라벨 25 · 배럴 export 4줄.
테스트는 C4s-1~10 의 자리 말고 모두 맞았습니다 — 뷰 56 · 골든 8 · else 없는 if 0 · collection-if 0 · ⓡ 8·7·0 · ⓗ 0·1·1 · // pre 4·6·3 · 가짜 = 받침대 extends + 예외 1 · 공장 = call 삼항 · FeatureFlags const 5 · 비교기 2파일.
골든 8장(390×844)이 카드 저자의 드라이런 8장과 바이트까지 같습니다 — 배치 결함 0 · 잘림 0 · dy 844 · 844 · 292 · 76(light = dark · 머리 0.0) · flutter test 1 → 65 · analyze 0 · format 0 · domain_contracts 386/30/0 · 경계 실패 0 · CI 3/3.
보고에서 맞은 곳 — 거짓 주장 0 · name-status 24줄 · 커밋 9 · 10항 10줄·괄호 · 10항 줄 수 · 정적 34줄 출력(C4 재실행과 바이트 같음) · S05 · ⓡⓗ 수 · 테스트 파일별 수 · dy 16값 · 질문 파일 A1~A4 꼴.

■ 왜 반려인가 — 카드 / 실제 (C4 가 코드·변이·수정안 시험으로 직접 확인)
① C4s-1 TS-07 에 «NavigationBar 0» 단언이 없다 (예고 변이 통과 · strict 나눔 ③)
   카드:  522행 TS-07 «s02-kill-slot 1 · s01-tabs 0(NavigationBar 0)» · 556행 예고 변이 «웹에 NavigationBar» · 549행 «하나라도 테스트가 그대로 통과하면 반려».
   실제:  shell_scaffold_test.dart 505~506행 = s02-kill-slot 1 · s01-tabs 0 뿐 — find.byType(NavigationBar) 단언 0(파일 전체). Key 없는 NavigationBar 를 웹 본문에 붙인 변이가 65/65 통과했다.
   고침:  상자 14 — 한 줄(C4 시험: 같은 변이를 TS-07 이 잡음).
② C4s-2 웹 사이드바 모드 칩에 띠 칩 Key (lib 결함 · strict 나눔 ②)
   카드:  399행 «정본 = 이 표 · 🔴 표 밖 Key 0» · 401행 s01-band-chip-$i = 띠 칩 · 404행 «그 밖의 Text · 칩 · 아이콘 · 사이드바 칩 안 글자에는 Key 를 달지 않는다».
   실제:  shell_scaffold.dart 273~277행 — s02-mode-chips 안 칩에 ValueKey<String>('s01-band-chip-$i'). 웹(모의·안내)에서 이 Key 가 2개(띠 + 사이드바)가 된다.
   고침:  상자 1 — for (final String m in modes) Chip(label: Text(m)), 한 줄(dart format 결과).
③ C4s-3~10 테스트가 카드 글자와 다르다 (테스트 결함 · strict 나눔 ② · 실효는 작거나 0)
   C4s-3  TR-08·TS-04 흐름 = bool 칸 + if/else(427·484·509행 «클로저 칸 · bool 칸 + if 금지») → 상자 10·11·12(흐름 = 클로저 칸 · 본문 = await c.steps(tester);)
   C4s-4  TS-04 의 ⓡ 이 auto(else) 안에만 있어 advisory 경우는 재시도 부재를 보지 않는다(510·526행) → 상자 12(경우 공통 ⓡ 한 줄 · S20 8 그대로)
   C4s-5  T02-01 사슬 dy 가 row-0 에서 멈추고 greaterThanOrEqualTo(531·132행) → 상자 5(asof → head → row-0 … row-4 · lessThan)
   C4s-6  T02-05 재시도 want 단언 누락(541행) → 상자 7
   C4s-7  경우 자료를 이름 비교로 고름 — TS-08 c.name == 'web' · s01 골든 flow.name == 's01_tabs_p0'(123·620행) → 상자 2·3·4(_Flow 의 top 칸) · 15·16(경우의 platform 칸)
   C4s-8  TR-07 journalTimeline 뒤 DummyBody 0 누락(480행) → 상자 9
   C4s-9  TR-03 // pre 가 route · isRegistered · match 에 있고 audit.code · runes 에는 없다(466~467행 «전제 셋 = route · audit.code · 한글 runes») → 상자 8(표식만 옮김 · S32 3 그대로)
   C4s-10 값을 내지 않는 StreamController 를 닫지 않는다(TS-06 · T02-05 loading · 133행) → 상자 6·13
카드 구멍(반려 사유 아님) — C4s-17 T02-05 다섯 경우에 «빈 + 오래됨» 이 없어 예고 변이 «오래됨 배너 빼기(빈 갈래)» 가 통과했다(카드 드라이런도 같음 · Bob 화면 코드는 맞다) →
  발주자 결정으로 상자 17(경우 1개 · ops_rhythm +14 → +15 · 전체 +65 → +66).
함께 고칠 것 — 표기 C4s-11~15 = 아래 «■ 보고 글» 조각(② 꼬리 = 조각 12·13·15·22 · ③ 서술 7줄 = 조각 16 · 골든 표 6열 = 조각 18 · ④ diff 4줄 = 조각 20 · ⑤ «없음» = 조각 21).
  C4s-16(커밋 (7)~(9) · (8) 제목)은 고치지 않는다(통합 담당이 병합 때 PR 본문에 적는다). 질문 파일은 고치지 않는다.
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 생성물은 git 에 없습니다(새 대화·브랜치를 바꿨으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류 · 생성물은 git 이 무시하므로 git status 는 빈 채).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_shell
  flutter test   ← 시작 기준: 끝 줄 «+65: All tests passed!» · 0 실패(1회차 그대로 · 앞 시각은 달라도 된다). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  (cd ../.. 하지 않고 packages/ui_shell 에 머문다 — 아래 상자의 경로·«고친 뒤 확인» 은 이 폴더 기준이다)

■ 고칠 것 — 상자 1~17 (1회차 반려 · C4 2026-10-26 · 상자 17 = 카드 구멍 보강 · 발주자 결정) — 상자 글자 그대로 · 손으로 다시 짜지 않는다
   🔴 행 번호는 1195787 의 것이다. 한 파일에 상자가 여럿이면 **행 번호가 큰 상자부터**(파일 아래쪽부터 위로) 고친다 — 그러면 앞의 수정이 뒤 자리의 행 번호를 밀지 않는다.
      차례: lib/src/shell_scaffold.dart = 상자 1 · test/golden/s01_golden_test.dart = 상자 4 → 3 → 2 · test/ops_rhythm_test.dart = 상자 7 → 17 → 6 → 5 ·
            test/shell_router_test.dart = 상자 10 → 9 → 8 · test/shell_scaffold_test.dart = 상자 16 → 15 → 14 → 13 → 12 → 11
   🔴 «이 줄을» 상자와 파일의 그 행들이 한 글자라도 다르면(들여쓰기 포함) 고쳐 쓰지 말고 멈춘 뒤 채팅으로 — 파일이 1195787 이 아니다. «이 줄을» 묶음 17개는 각 파일에 한 곳뿐이다.
   🔴 상자 안의 들여쓰기(빈칸 수)를 그대로 옮긴다 · 탭 문자 0 · 줄 끝 빈칸 0 · 상자 밖의 줄은 한 글자도 바꾸지 않는다(빈 줄 포함) · 상자 머리·끝 줄(┌── · └──)은 파일에 넣지 않는다 ·
      상자 안 줄 머리의 빈칸은 파일의 들여쓰기 그대로다(상자 머리 ┌── 의 들여쓰기와 무관 — 떼어 내지 않는다) · 상자 첫 줄·끝 줄이 빈 줄이면 그 빈 줄도 상자 글자다(상자 머리에 적었다) · PNG 0.

상자 1 (C4s-2 · lib/src/shell_scaffold.dart — 웹 사이드바 모드 칩 · 11줄 → 7줄)
   (바뀐 뜻: 사이드바 모드 칩 = for (final String m in modes) Chip(label: Text(m)), 한 줄 — Key 0(s01-band-chip-$i 는 띠 칩에만))
      ┌── 이 줄을(lib/src/shell_scaffold.dart 270~280행 · 11줄 · 이 11줄 묶음은 파일에 한 곳뿐)
                      key: const Key('s02-mode-chips'),
                      spacing: 8,
                      children: <Widget>[
                        for (final (int i, String m) in modes.indexed)
                          Chip(
                            key: ValueKey<String>('s01-band-chip-$i'),
                            label: Text(m),
                          ),
                      ],
                    ),
                  ),
      └──
      ┌── 이 줄로(7줄)
                      key: const Key('s02-mode-chips'),
                      spacing: 8,
                      children: <Widget>[
                        for (final String m in modes) Chip(label: Text(m)),
                      ],
                    ),
                  ),
      └──

상자 2 (C4s-7 · test/golden/s01_golden_test.dart — s01 골든 _Flow 의 칸 · 12줄 → 14줄)
   (바뀐 뜻: _Flow 에 top 칸(Finder) 하나를 더한다(생성자 required · 필드))
      ┌── 이 줄을(test/golden/s01_golden_test.dart 17~28행 · 12줄 · 이 12줄 묶음은 파일에 한 곳뿐 · 끝 줄 = 빈 줄)
    required this.name,
    required this.flags,
    required this.alerts,
    required this.steps,
  });

  final String name;
  final FeatureFlags flags;
  final List<AlertItem> alerts;
  final Future<void> Function(WidgetTester tester) steps;
}

      └──
      ┌── 이 줄로(14줄 · 끝 줄 = 빈 줄)
    required this.name,
    required this.flags,
    required this.alerts,
    required this.top,
    required this.steps,
  });

  final String name;
  final FeatureFlags flags;
  final List<AlertItem> alerts;
  final Finder top;
  final Future<void> Function(WidgetTester tester) steps;
}

      └──

상자 3 (C4s-7 · test/golden/s01_golden_test.dart — s01 골든 흐름 목록 · 12줄 → 14줄)
   (바뀐 뜻: s01_tabs_p0 = find.byKey(const Key('s01-band')) · s01_tabs_clean = find.byType(AppBar) 를 경우 칸에 직접 넣는다)
      ┌── 이 줄을(test/golden/s01_golden_test.dart 41~52행 · 12줄 · 이 12줄 묶음은 파일에 한 곳뿐)
      name: 's01_tabs_p0',
      flags: kFlagsSimAdvisory,
      alerts: alerts12.rows,
      steps: (_) async {},
    ),
    _Flow(
      name: 's01_tabs_clean',
      flags: kFlagsLiveAuto,
      alerts: digest.rows,
      steps: (_) async {},
    ),
  ];
      └──
      ┌── 이 줄로(14줄)
      name: 's01_tabs_p0',
      flags: kFlagsSimAdvisory,
      alerts: alerts12.rows,
      top: find.byKey(const Key('s01-band')),
      steps: (_) async {},
    ),
    _Flow(
      name: 's01_tabs_clean',
      flags: kFlagsLiveAuto,
      alerts: digest.rows,
      top: find.byType(AppBar),
      steps: (_) async {},
    ),
  ];
      └──

상자 4 (C4s-7 · test/golden/s01_golden_test.dart — s01 골든 위치 전제 · 10줄 → 7줄)
   (바뀐 뜻: 이름 비교 삼항 세 줄 → expect(tester.getTopLeft(flow.top).dy, 0.0); 한 줄(1회차 카드 620행 글자))
      ┌── 이 줄을(test/golden/s01_golden_test.dart 80~89행 · 10줄 · 이 10줄 묶음은 파일에 한 곳뿐)
          tester.getBottomLeft(find.byKey(const Key('s01-tabs'))).dy,
          kGoldenPhoneSize.height,
        );
        final Finder topFinder = flow.name == 's01_tabs_p0'
            ? find.byKey(const Key('s01-band'))
            : find.byType(AppBar);
        expect(tester.getTopLeft(topFinder).dy, 0.0);

        await expectGolden(flow.name, b);
      });
      └──
      ┌── 이 줄로(7줄)
          tester.getBottomLeft(find.byKey(const Key('s01-tabs'))).dy,
          kGoldenPhoneSize.height,
        );
        expect(tester.getTopLeft(flow.top).dy, 0.0);

        await expectGolden(flow.name, b);
      });
      └──

상자 5 (C4s-5 · test/ops_rhythm_test.dart — T02-01 사슬 dy · 17줄 → 18줄)
   (바뀐 뜻: h02-asof → h02-head → h02-row-0 … h02-row-4 를 차례로 getTopLeft · lessThan(행 수는 rows.rows.indexed 로 · 리터럴 5 0 · >= 0))
      ┌── 이 줄을(test/ops_rhythm_test.dart 79~95행 · 17줄 · 이 17줄 묶음은 파일에 한 곳뿐)
    expect(find.byKey(const ValueKey<String>('h02-row-5')), findsNothing);

    // 사슬 dy
    final double dyAsof = tester
        .getBottomLeft(find.byKey(const Key('h02-asof')))
        .dy;
    final double dyHead = tester
        .getTopLeft(find.byKey(const Key('h02-head')))
        .dy;
    final double dyRow0 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('h02-row-0')))
        .dy;
    expect(dyHead, greaterThanOrEqualTo(dyAsof));
    expect(dyRow0, greaterThanOrEqualTo(dyHead));

    // 승인·확인 버튼 0
    expect(find.byType(FilledButton), findsNothing);
      └──
      ┌── 이 줄로(18줄)
    expect(find.byKey(const ValueKey<String>('h02-row-5')), findsNothing);

    // 사슬 dy
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('h02-asof')),
      find.byKey(const Key('h02-head')),
      for (final (int i, OpsRhythmRow _) in rows.rows.indexed)
        find.byKey(ValueKey<String>('h02-row-$i')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }

    // 승인·확인 버튼 0
    expect(find.byType(FilledButton), findsNothing);
      └──

상자 6 (C4s-10 · test/ops_rhythm_test.dart — T02-05 loading 공장 · 10줄 → 16줄)
   (바뀐 뜻: 값을 내지 않는 컨트롤러 = 지역 ctrl + addTearDown(() { unawaited(ctrl.close()); }))
      ┌── 이 줄을(test/ops_rhythm_test.dart 220~229행 · 10줄 · 이 10줄 묶음은 파일에 한 곳뿐)
        >[
          (
            name: 'loading',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  StreamController<ListResult<OpsRhythmRow>>().stream,
            ),
            clock: FixedClock(kGoldenNowUtc),
            skeleton: true,
            error: false,
      └──
      ┌── 이 줄로(16줄)
        >[
          (
            name: 'loading',
            opsFactory: () {
              final StreamController<ListResult<OpsRhythmRow>> ctrl =
                  StreamController<ListResult<OpsRhythmRow>>();
              addTearDown(() {
                unawaited(ctrl.close());
              });
              return FakeShellOpsSummaryRepository(
                rhythm: (int call) => ctrl.stream,
              );
            },
            clock: FixedClock(kGoldenNowUtc),
            skeleton: true,
            error: false,
      └──

상자 7 (C4s-6 · test/ops_rhythm_test.dart — T02-05 재시도 단언 · 6줄 → 10줄)
   (바뀐 뜻: expect(find.text(ShellLabels.retry), c.error ? findsOneWidget : findsNothing); 을 행0 단언 뒤에(want 꼴 · 정적 S20 셈 밖))
      ┌── 이 줄을(test/ops_rhythm_test.dart 322~327행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
          find.byKey(const ValueKey<String>('h02-row-0')),
          c.row0 ? findsOneWidget : findsNothing,
        );
        // 빈 문장 (전제는 if 밖)
        expect(empty.emptyLabel, isNotNull); // pre
        final String? wantEmpty = c.wantEmpty;
      └──
      ┌── 이 줄로(10줄)
          find.byKey(const ValueKey<String>('h02-row-0')),
          c.row0 ? findsOneWidget : findsNothing,
        );
        expect(
          find.text(ShellLabels.retry),
          c.error ? findsOneWidget : findsNothing,
        );
        // 빈 문장 (전제는 if 밖)
        expect(empty.emptyLabel, isNotNull); // pre
        final String? wantEmpty = c.wantEmpty;
      └──

상자 8 (C4s-9 · test/shell_router_test.dart — TR-03 전제 표식 · 13줄 → 13줄)
   (바뀐 뜻: // pre = r.route · audit.code · 한글 runes 세 줄(isRegistered · match 두 줄의 표식은 뗀다 · S32 3 그대로))
      ┌── 이 줄을(test/shell_router_test.dart 51~63행 · 13줄 · 이 13줄 묶음은 파일에 한 곳뿐)
    expect(rows.rows, hasLength(5)); // ⓗ
    for (final OpsRhythmRow r in rows.rows) {
      expect(r.route, isNotNull); // pre
      expect(AppRoutes.isRegistered(r.route!), isTrue); // pre
      expect(matchShellRoute(r.route!)?.pattern, isNotNull); // pre
    }
    final OpsRhythmRow audit = rows.rows[3];
    expect(audit.code, 'QUARTERLY_SELF_AUDIT');
    final List<String> segs = audit.route!.split('/');
    expect(segs.last.runes.any((int c) => c > 0x7F), isTrue);
    final ShellRouteMatch? m = matchShellRoute(audit.route!);
    expect(m?.pattern, AppRoutes.ledgerSelfReport);
    expect(m?.params, <String, String>{
      └──
      ┌── 이 줄로(13줄)
    expect(rows.rows, hasLength(5)); // ⓗ
    for (final OpsRhythmRow r in rows.rows) {
      expect(r.route, isNotNull); // pre
      expect(AppRoutes.isRegistered(r.route!), isTrue);
      expect(matchShellRoute(r.route!)?.pattern, isNotNull);
    }
    final OpsRhythmRow audit = rows.rows[3];
    expect(audit.code, 'QUARTERLY_SELF_AUDIT'); // pre
    final List<String> segs = audit.route!.split('/');
    expect(segs.last.runes.any((int c) => c > 0x7F), isTrue); // pre
    final ShellRouteMatch? m = matchShellRoute(audit.route!);
    expect(m?.pattern, AppRoutes.ledgerSelfReport);
    expect(m?.params, <String, String>{
      └──

상자 9 (C4s-8 · test/shell_router_test.dart — TR-07 journalTimeline · 6줄 → 7줄)
   (바뀐 뜻: journalTimeline 가드 글자 단언 뒤 expect(find.byType(DummyBody), findsNothing); 한 줄)
      ┌── 이 줄을(test/shell_router_test.dart 288~293행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.webAbsent,
    );
    await openLink(tester, AppNavActions.back);

    // phoneOnly
      └──
      ┌── 이 줄로(7줄)
      tester.widget<Text>(find.byKey(const Key('s01-guard'))).data,
      ShellLabels.webAbsent,
    );
    expect(find.byType(DummyBody), findsNothing);
    await openLink(tester, AppNavActions.back);

    // phoneOnly
      └──

상자 10 (C4s-3 · test/shell_router_test.dart — TR-08 경우와 본문 · 55줄 → 61줄)
   (바뀐 뜻: 경우 = (name, steps) 클로저 칸 · 본문 = await c.steps(tester); (bool 칸 + if/else 0))
      ┌── 이 줄을(test/shell_router_test.dart 326~380행 · 55줄 · 이 55줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  // ── TR-08 back 동작 링크 ───────────────────────────────────────────────────
  group('TR-08 back action link', () {
    const List<({String name, bool pushed})> cases =
        <({String name, bool pushed})>[
          (name: 'pushed', pushed: true),
          (name: 'root', pushed: false),
        ];

    for (final c in cases) {
      testWidgets('TR-08 ${c.name}', (WidgetTester tester) async {
        final List<String> log = <String>[];
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(kFlagsLiveAuto),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, log),
          ),
        );

        if (c.pushed) {
          await openLink(tester, dummyLink(AppRoutes.holdingsDetail));
          expect(dummyOf(AppRoutes.holdingsDetail), findsOneWidget);
          await openLink(tester, AppNavActions.back);
          expect(dummyOf(AppRoutes.holdingsDetail), findsNothing);
          expect(
            tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
            ShellLabels.tabHome,
          );
        } else {
          // 탭 3으로 이동 후 back => 홈(탭 0)
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('s01-tabs')),
              matching: find.text(ShellLabels.tabPlan),
            ),
          );
          await tester.pump();
          await openLink(tester, AppNavActions.back);
          expect(
            tester.widget<Text>(find.byKey(const Key('s01-title'))).data,
            ShellLabels.tabHome,
          );
          expect(
            tester
                .widget<NavigationBar>(find.byKey(const Key('s01-tabs')))
                .selectedIndex,
            0,
          );
        }
      });
    }
  });
      └──
      ┌── 이 줄로(61줄 · 첫 줄 = 빈 줄)

  // ── TR-08 back 동작 링크 ───────────────────────────────────────────────────
  group('TR-08 back action link', () {
    final List<({String name, Future<void> Function(WidgetTester t) steps})>
    cases = <({String name, Future<void> Function(WidgetTester t) steps})>[
      (
        name: 'pushed',
        steps: (WidgetTester t) async {
          await openLink(t, dummyLink(AppRoutes.holdingsDetail));
          expect(dummyOf(AppRoutes.holdingsDetail), findsOneWidget);
          await openLink(t, AppNavActions.back);
          expect(dummyOf(AppRoutes.holdingsDetail), findsNothing);
          expect(
            t.widget<Text>(find.byKey(const Key('s01-title'))).data,
            ShellLabels.tabHome,
          );
        },
      ),
      (
        name: 'root',
        steps: (WidgetTester t) async {
          // 탭 3으로 이동 후 back => 홈(탭 0)
          await t.tap(
            find.descendant(
              of: find.byKey(const Key('s01-tabs')),
              matching: find.text(ShellLabels.tabPlan),
            ),
          );
          await t.pump();
          await openLink(t, AppNavActions.back);
          expect(
            t.widget<Text>(find.byKey(const Key('s01-title'))).data,
            ShellLabels.tabHome,
          );
          expect(
            t
                .widget<NavigationBar>(find.byKey(const Key('s01-tabs')))
                .selectedIndex,
            0,
          );
        },
      ),
    ];

    for (final c in cases) {
      testWidgets('TR-08 ${c.name}', (WidgetTester tester) async {
        final List<String> log = <String>[];
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: ShellPlatform.androidOperator,
            config: flagsOf(kFlagsLiveAuto),
            alerts: alertsOf(const <AlertItem>[]),
            bodies: dummyBodies(AppRoutes.all, log),
          ),
        );

        await c.steps(tester);
      });
    }
  });
      └──

상자 11 (C4s-3 · test/shell_scaffold_test.dart — TS-04 경우 목록 · 10줄 → 53줄)
   (바뀐 뜻: 경우 = (name, flags, advisory, steps) — 갈래 흐름을 steps 클로저 칸에)
      ┌── 이 줄을(test/shell_scaffold_test.dart 249~258행 · 10줄 · 이 10줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  // ── TS-04 일지 세그먼트 ────────────────────────────────────────────────────
  group('TS-04 journal segment', () {
    final List<({String name, FeatureFlags flags, bool advisory})> cases =
        <({String name, FeatureFlags flags, bool advisory})>[
          (name: 'advisory', flags: kFlagsLiveAdvisory, advisory: true),
          (name: 'auto', flags: kFlagsLiveAuto, advisory: false),
        ];

    for (final c in cases) {
      └──
      ┌── 이 줄로(53줄 · 첫 줄 = 빈 줄)

  // ── TS-04 일지 세그먼트 ────────────────────────────────────────────────────
  group('TS-04 journal segment', () {
    final List<
      ({
        String name,
        FeatureFlags flags,
        bool advisory,
        Future<void> Function(WidgetTester t) steps,
      })
    >
    cases =
        <
          ({
            String name,
            FeatureFlags flags,
            bool advisory,
            Future<void> Function(WidgetTester t) steps,
          })
        >[
          (
            name: 'advisory',
            flags: kFlagsLiveAdvisory,
            advisory: true,
            steps: (WidgetTester t) async {
              expect(
                t
                    .widget<SegmentedButton<int>>(
                      find.byKey(const Key('s01-segment')),
                    )
                    .selected,
                <int>{0},
              );
              expect(dummyOf(AppRoutes.adviceInbox), findsOneWidget);
              expect(dummyOf(AppRoutes.journalTimeline), findsNothing);
              await t.tap(find.text(ShellLabels.segmentRecord));
              await t.pump();
              expect(dummyOf(AppRoutes.journalTimeline), findsOneWidget);
            },
          ),
          (
            name: 'auto',
            flags: kFlagsLiveAuto,
            advisory: false,
            steps: (WidgetTester t) async {
              expect(dummyOf(AppRoutes.journalTimeline), findsOneWidget);
              expect(dummyOf(AppRoutes.adviceInbox), findsNothing);
              expect(find.text(ShellLabels.segmentAdvice), findsNothing);
            },
          ),
        ];

    for (final c in cases) {
      └──

상자 12 (C4s-3 · C4s-4 · test/shell_scaffold_test.dart — TS-04 본문 · 26줄 → 8줄)
   (바뀐 뜻: if/else → await c.steps(tester); + 경우 공통 ⓡ 한 줄(advisory 경우도 재시도 부재를 본다 · S20 8 그대로))
      ┌── 이 줄을(test/shell_scaffold_test.dart 278~303행 · 26줄 · 이 26줄 묶음은 파일에 한 곳뿐)
          find.byKey(const Key('s01-segment')),
          c.advisory ? findsOneWidget : findsNothing,
        );
        if (c.advisory) {
          expect(
            tester
                .widget<SegmentedButton<int>>(
                  find.byKey(const Key('s01-segment')),
                )
                .selected,
            <int>{0},
          );
          expect(dummyOf(AppRoutes.adviceInbox), findsOneWidget);
          expect(dummyOf(AppRoutes.journalTimeline), findsNothing);
          await tester.tap(find.text(ShellLabels.segmentRecord));
          await tester.pump();
          expect(dummyOf(AppRoutes.journalTimeline), findsOneWidget);
        } else {
          expect(dummyOf(AppRoutes.journalTimeline), findsOneWidget);
          expect(dummyOf(AppRoutes.adviceInbox), findsNothing);
          expect(find.text(ShellLabels.segmentAdvice), findsNothing);
          expect(find.text(ShellLabels.retry), findsNothing);
        }
      });
    }
  });
      └──
      ┌── 이 줄로(8줄)
          find.byKey(const Key('s01-segment')),
          c.advisory ? findsOneWidget : findsNothing,
        );
        await c.steps(tester);
        expect(find.text(ShellLabels.retry), findsNothing);
      });
    }
  });
      └──

상자 13 (C4s-10 · test/shell_scaffold_test.dart — TS-06 loading 공장 · 9줄 → 16줄)
   (바뀐 뜻: 값을 내지 않는 컨트롤러 = 지역 ctrl + addTearDown(() { unawaited(ctrl.close()); }))
      ┌── 이 줄을(test/shell_scaffold_test.dart 385~393행 · 9줄 · 이 9줄 묶음은 파일에 한 곳뿐)
        >[
          (
            name: 'loading',
            configFactory: () => FakeShellConfigRepository(
              flags: (int call) => StreamController<FeatureFlags>().stream,
            ),
            skeleton: true,
            error: false,
            shell: false,
      └──
      ┌── 이 줄로(16줄)
        >[
          (
            name: 'loading',
            configFactory: () {
              final StreamController<FeatureFlags> ctrl =
                  StreamController<FeatureFlags>();
              addTearDown(() {
                unawaited(ctrl.close());
              });
              return FakeShellConfigRepository(
                flags: (int call) => ctrl.stream,
              );
            },
            skeleton: true,
            error: false,
            shell: false,
      └──

상자 14 (C4s-1 · test/shell_scaffold_test.dart — TS-07 NavigationBar 0 · 6줄 → 7줄)
   (바뀐 뜻: expect(find.byType(NavigationBar), findsNothing); 한 줄(1회차 카드 522행 «(NavigationBar 0)»))
      ┌── 이 줄을(test/shell_scaffold_test.dart 504~509행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
    );
    expect(find.byKey(const Key('s02-kill-slot')), findsOneWidget);
    expect(find.byKey(const Key('s01-tabs')), findsNothing);

    // 사이드바 탭 1 => webAbsent
    await tester.tap(find.byKey(const ValueKey<String>('s02-item-1')));
      └──
      ┌── 이 줄로(7줄)
    );
    expect(find.byKey(const Key('s02-kill-slot')), findsOneWidget);
    expect(find.byKey(const Key('s01-tabs')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);

    // 사이드바 탭 1 => webAbsent
    await tester.tap(find.byKey(const ValueKey<String>('s02-item-1')));
      └──

상자 15 (C4s-7 · test/shell_scaffold_test.dart — TS-08 경우 목록 · 10줄 → 25줄)
   (바뀐 뜻: 경우 = (name, platform, flags, size) — 플랫폼을 경우 칸에 직접)
      ┌── 이 줄을(test/shell_scaffold_test.dart 532~541행 · 10줄 · 이 10줄 묶음은 파일에 한 곳뿐)
      AlertItem.fromJson,
    );

    final List<({String name, FeatureFlags flags, Size size})> cases =
        <({String name, FeatureFlags flags, Size size})>[
          (name: 'phone', flags: kFlagsSimAdvisory, size: const Size(390, 844)),
          (name: 'web', flags: kFlagsSimAdvisory, size: const Size(1280, 800)),
        ];

    for (final c in cases) {
      └──
      ┌── 이 줄로(25줄)
      AlertItem.fromJson,
    );

    final List<
      ({String name, ShellPlatform platform, FeatureFlags flags, Size size})
    >
    cases =
        <
          ({String name, ShellPlatform platform, FeatureFlags flags, Size size})
        >[
          (
            name: 'phone',
            platform: ShellPlatform.androidOperator,
            flags: kFlagsSimAdvisory,
            size: const Size(390, 844),
          ),
          (
            name: 'web',
            platform: ShellPlatform.web,
            flags: kFlagsSimAdvisory,
            size: const Size(1280, 800),
          ),
        ];

    for (final c in cases) {
      └──

상자 16 (C4s-7 · test/shell_scaffold_test.dart — TS-08 띄우기 · 9줄 → 7줄)
   (바뀐 뜻: platform: c.platform, (이름 비교 삼항 0))
      ┌── 이 줄을(test/shell_scaffold_test.dart 547~555행 · 9줄 · 이 9줄 묶음은 파일에 한 곳뿐)
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: c.name == 'web'
                ? ShellPlatform.web
                : ShellPlatform.androidOperator,
            config: flagsOf(c.flags),
            alerts: alertsOf(alerts12.rows),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
      └──
      ┌── 이 줄로(7줄)
        await pumpShell(
          tester,
          overrides: shellOverrides(
            platform: c.platform,
            config: flagsOf(c.flags),
            alerts: alertsOf(alerts12.rows),
            bodies: dummyBodies(AppRoutes.all, <String>[]),
      └──

상자 17 (C4s-17 · 카드 구멍 보강(발주자 결정 ②) · test/ops_rhythm_test.dart — T02-05 경우 목록 끝 · 6줄 → 20줄)
   (바뀐 뜻: 경우 not_loaded_stale 하나 — 빈 표본(empty) + 시계 +2일 → 머리 1 · 오래됨 배너 1 · 행0 0 · 빈 문장 = empty.emptyLabel(ops_rhythm +14 → +15))
      ┌── 이 줄을(test/ops_rhythm_test.dart 290~295행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
            row0: false,
            wantEmpty: empty.emptyLabel,
          ),
        ];

    for (final c in cases) {
      └──
      ┌── 이 줄로(20줄)
            row0: false,
            wantEmpty: empty.emptyLabel,
          ),
          (
            name: 'not_loaded_stale',
            opsFactory: () => FakeShellOpsSummaryRepository(
              rhythm: (int call) =>
                  Stream<ListResult<OpsRhythmRow>>.value(empty),
            ),
            clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
            skeleton: false,
            error: false,
            header: true,
            stale: true,
            row0: false,
            wantEmpty: empty.emptyLabel,
          ),
        ];

    for (final c in cases) {
      └──

고친 뒤 확인(packages/ui_shell 에서 · 커밋하기 전 · 고치지 않고 보기만):
  git diff --stat                     ← 마지막 줄이 « 5 files changed, 167 insertions(+), 92 deletions(-)»(위에 파일 줄 다섯이 더 있는 것이 정상 · 다르면 상자와 다시 대조 · 커밋하지 않는다)
  dart format --output=none --set-exit-if-changed lib/src/shell_scaffold.dart test/golden/s01_golden_test.dart test/ops_rhythm_test.dart test/shell_router_test.dart test/shell_scaffold_test.dart
                                      ← «Formatted 5 files (0 changed)» 꼴 · 바뀐 줄이 있으면 상자와 다르게 옮긴 것 — 다시 대조
  git hash-object lib/src/shell_scaffold.dart          ← c3921f8b1d81e8bc23e0ccf9bb56d1466676511b
  git hash-object test/golden/s01_golden_test.dart     ← 8c7774a54feea891458fadc43b15d22c9571c6f4
  git hash-object test/ops_rhythm_test.dart            ← 1b059e8c99be8020391a120bbebb34a576e63d97
  git hash-object test/shell_router_test.dart          ← b52fecca2118dc74826a3a1cd85554c7795a9386
  git hash-object test/shell_scaffold_test.dart        ← 9b39969b8b39c0b91718ab1b6cdaebd0c2036497
     (다섯 줄 = C4 수정안 파일의 git 해시 · 다르면 그 파일만 상자와 다시 대조 — BOM · 줄 끝 빈칸 · 빈 줄 하나 차이에도 해시가 바뀐다)
  git grep -c -F "find.byType(NavigationBar), findsNothing" -- test/shell_scaffold_test.dart   ← «test/shell_scaffold_test.dart:1»(C4s-1 · 1195787 에서는 출력 없음)
  git grep -c -F "s01-band-chip" -- lib/src/shell_scaffold.dart                                ← «lib/src/shell_scaffold.dart:1»(C4s-2 · 1195787 에서는 «…:2»)
  git grep -c -F -e "if (c." -e "c.name ==" -e "flow.name ==" -- test                          ← 출력 없음(C4s-3·C4s-7 · 1195787 에서는 세 줄 «…s01_golden_test.dart:1» · «…shell_router_test.dart:1» · «…shell_scaffold_test.dart:2»)
  git grep -c -F "unawaited(ctrl.close())" -- test/ops_rhythm_test.dart test/shell_scaffold_test.dart   ← «test/ops_rhythm_test.dart:1» · «test/shell_scaffold_test.dart:1»(C4s-10 · 1195787 에서는 출력 없음)
  git grep -c -F "not_loaded_stale" -- test/ops_rhythm_test.dart                               ← «test/ops_rhythm_test.dart:1»(C4s-17 · 1195787 에서는 출력 없음)
  git grep -c "retry), findsNothing" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart   ← «test/ops_rhythm_test.dart:7» · «test/shell_scaffold_test.dart:8»(ⓡ · 1195787 과 같은 수)
  git grep -c "// pre$" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart               ← «test/ops_rhythm_test.dart:6» · «test/shell_router_test.dart:3» · «test/shell_scaffold_test.dart:4»(전제 · 1195787 과 같은 수)
  (위 줄 다 자기 점검이다 · 따옴표 그대로(Git Bash·PowerShell 둘 다 그대로 돈다) · 다르면 커밋하지 말고 멈춘 뒤 출력을 채팅으로 · 이 출력은 채팅 글에 붙이지 않는다)

커밋 — 하나 · 맨 위에(상자 1~17 전부 · format:fix 가 바꾼 줄이 있으면 그것도 같은 커밋 — 기대는 0 줄):
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M8] R13a (10) C4 반려 수정 — TS-07 NavigationBar 0 · 사이드바 칩 Key · 테스트 흐름·전제 · 빈+오래됨 경우
      └── 커밋 제목 복사 끝(이 줄 앞까지)
   🔴 지난 커밋(1195787 · fcb54fc · 064ad8b · 4042db3 · 1144f4d · 52686c7 · 296ec26 · 89ee073 · 83f34a4)을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.

■ 고치지 않는 것 (1회차가 맞았거나 이 글 밖 — 손대면 반려)
 · 상자 1~17 밖의 lib·테스트 본문 전부 · PNG 전부(s01_* 4 · h02_* 4 — --update-goldens 금지 · 열지도 않는다) · shell_fakes.dart · h02_golden_test.dart · 비교기 2파일 · 그 밖의 테스트 파일
 · 골든 dy — 상자 1 은 골든이 없는 웹 사이드바만 · 상자 2~4 는 위치 전제의 머리 Finder 를 칸으로 옮길 뿐이라 PNG·dy 가 그대로다 — 다시 재지 않는다
   (질문 파일 A1~A4 = 1회차 실측 = C4 재실측 · 위치 전제를 lessThan(0) 으로 바꾸는 일도 하지 않는다)
 · 질문 파일 docs/ai-context/inbox/S01H02_questions.md — A1~A4 행·머리말(«다음 번호» 포함)을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 닫는다)
 · ⓡ·ⓗ·// pre 줄의 수(S20 7·8 · S21 1·1 · S32 6·3·4) · 테스트 이름 · 경우 목록(상자 17 의 not_loaded_stale 하나 말고)
 · 지난 9개 커밋(제목 포함 — C4s-16 은 통합 담당 몫) · 다음 카드 보강 후보(C4 보고 §8 — 다음 카드 몫)는 이번에 넣지 않는다(넣으면 범위 밖 변경)

■ 질문 파일
· 이번 상자 1~17 은 전부 이 글이 정했고 PNG 가 그대로라 잴 것도 없으므로, 질문 파일은 바뀌지 않는 것이 정상입니다(새 행 0).
· 🔴 새 행이 필요해 보이면(측정·추측·질문 어느 것이든) 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 — 이번 커밋은 위 다섯 파일만 add 하고, 아래 «git diff --name-status 1195787 HEAD» 는 다섯 줄이어야 합니다.

(읽는 법 — 아래 «■ 정적 묶음» 절은 1회차 카드 563~609행 글자 그대로다. 이 재제출에서는 «PR 본문 ②» = 채팅 글 조각 11 · «블록 뒤 S05 결과 줄» = 조각 12 상자 · «flutter test 출력» = 이 글의 «■ 테스트 수 묶음» ·
  S26 의 origin/main...HEAD 는 점 세 개라 기록 커밋·엔진 커밋이 main 에 더해져도 1회차와 같은 밑동(b341aa8)에서 잰다 ·
  대조에서 빼는 것 = 빈 줄 · EXIT 표기 · warning:·error: 줄 · PowerShell 장식 줄 · 줄 머리 경과 시각 · 한국어가 깨져 보이면 [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 돌린다.)
■ 정적 묶음 — packages/ui_shell 에서 아래 34줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (R4b 카드와 같은 대조 규칙 — 줄을 고르거나 줄이거나 설명으로 바꾸지 않는다 · 대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 ·
   flutter test·dart test 출력은 파일로 떠서 붙인다 · «EXIT:1»/«EXIT:False» = 출력 없음 · 블록 뒤 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»)
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/golden/s01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/golden/s01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/golden/s01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## S02c testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/golden/s01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## S03 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S04 forbidden words in lib src and l10n 0"; git grep -nP "DateTime\.now|kIsWeb|(?<![A-Za-z])Platform\.|dart:io|go_router|performanceExplore|HoldingPnl|PerformanceSeries|afterTax|cagrPct|endMult|SafetyRepository|watchState|watchToday|upcoming|killSwitch|NumberFormat|toStringAsFixed|ShellVm|ShellChip" -- lib/src lib/l10n; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/ops_rhythm.dart lib/src/shell_scaffold.dart; echo "EXIT:$?"
echo "## S06 subscription lines (3)"; git grep -nE "watchFlags\(|watchInbox\(|watchRhythm\(" -- lib; echo "EXIT:$?"
echo "## S07 isSim lines"; git grep -n "isSim" -- lib; echo "EXIT:$?"
echo "## S08 OperatingMode switch arms"; git grep -n "OperatingMode\." -- lib; echo "EXIT:$?"
echo "## S09 RunMode values 0"; git grep -nE "RunMode\.(simInternal|simBroker|live)" -- lib; echo "EXIT:$?"
echo "## S10 ShellPlatform and ShellGuard arms"; git grep -nE "ShellPlatform\.|ShellGuard\." -- lib; echo "EXIT:$?"
echo "## S11 AlertLevel lines (1)"; git grep -n "AlertLevel\." -- lib; echo "EXIT:$?"
echo "## S12 comparator copies (1 line diff + 0)"; git diff --no-index -- ../ui_journal/test/flutter_test_config.dart test/flutter_test_config.dart; git diff --no-index --exit-code -- ../ui_journal/test/golden/shift_tolerant_compare.dart test/golden/shift_tolerant_compare.dart; echo "EXIT:$?"
echo "## S13 barrel exports"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## S14 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## S15 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S16 figures 0 (prompt 48-54)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S17 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## S18 shell labels"; git grep -nE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## S19 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## S20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart; echo "EXIT:$?"
echo "## S21 H lines (hasLength)"; git grep -c "hasLength(" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart; echo "EXIT:$?"
echo "## S22 s01 s02 h02 key names"; git grep -noP "(s01|s02|h02)-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib; echo "EXIT:$?"
echo "## S23 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S24 rich text widgets 0"; git grep -nE "RichText|SelectableText|Text\.rich" -- lib; echo "EXIT:$?"
echo "## S25 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## S26 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_shell.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md; echo "EXIT:$?"
echo "## S27 trimming 0"; git grep -nE "maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## S28 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart; echo "EXIT:$?"
echo "## S29 copyWith in new tests (one statement)"; git grep -n "copyWith(" -- test/shell_fakes.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/golden/s01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## S30 implements in new tests (1)"; git grep -n " implements " -- test/shell_fakes.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/golden/s01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## S31 FeatureFlags constants in fakes (5)"; git grep -c "FeatureFlags(" -- test/shell_fakes.dart; echo "EXIT:$?"
echo "## S32 precondition marks (pre)"; git grep -c "// pre$" -- test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(드라이런 실측) — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = ASCII · S02c = 5줄(git grep 경로 순 h02_golden 1 · s01_golden 1 · ops_rhythm 8 · shell_router 12 · shell_scaffold 9) · S03·S04 = 0 ·
   S05 = 탭 콜백 안 1줄(ops_rhythm 의 행 onTap — scaffold 0) · S06 = 3줄(ops_rhythm watchRhythm · shell_providers watchFlags · shell_scaffold watchInbox) · S07 = 2줄(shell_providers 의 shellModeLabels · shell_scaffold 의 띠 색) ·
   S08 = 6줄(shell_router _advisoryGate 2 · shell_providers shellModeLabels 2 · shell_scaffold _JournalTab 2) · S09 = 0 · S10 = 21줄(shell_router 18 = shellGuardFor 의 ShellPlatform 3 갈래 머리 + ShellGuard 반환값 7 + _advisoryGate 3 + ShellRouteBody switch 5 ·
   shell_scaffold 3 = ShellRoot 의 ShellPlatform 3) · S11 = 1줄 · S12 = 10줄(«diff --git a/../ui_journal/test/flutter_test_config.dart b/test/flutter_test_config.dart» · «index …» · «--- a/…» · «+++ b/…» · «@@ -1,4 +1,4 @@» ·
   «-// … ui_journal …» · «+// … ui_shell …» · 문맥 3줄) 뒤 둘째 파일 출력 없음(🔵 «warning: in the working copy … LF will be replaced by CRLF» 줄은 대조 밖) · S13 = 5줄(l10n/labels.dart · src/ops_rhythm.dart · src/routing/shell_router.dart ·
   src/shell_providers.dart · src/shell_scaffold.dart 순) · S14~S17 = 0 · S18 = 25줄 · S19 = 0 · S20 = 2줄 «test/ops_rhythm_test.dart:7» · «test/shell_scaffold_test.dart:8» ·
   S21 = 2줄 «test/ops_rhythm_test.dart:1» · «test/shell_router_test.dart:1»(🔴 정확히 — 다르면 반려) · S22 = 이름 30개(위 «Key 표» — 같은 이름이 갈래마다 두 번 나와도 된다 · 표 밖 0) ·
   S23~S25 = 0 · S26 = 두 줄(labels.dart 27/0 · ui_shell.dart 4/0) · 그 밖 파일 줄 없음 · S27·S28 = 0 · S29 = 2줄(ops_rhythm_test 의 T02-03 한 문장 — dart format 이 두 줄로 나눈다 · copyWith 문장은 그 하나뿐) ·
   S30 = 1줄(test/shell_fakes.dart 의 FakeShellAlertRepository) · S31 = «test/shell_fakes.dart:5» · S32 = 3줄 «test/ops_rhythm_test.dart:6» · «test/shell_router_test.dart:3» · «test/shell_scaffold_test.dart:4»(= 최소 목록의 (전제) 수 · 🔴 정확히))
  (🔵 S20·S21 처럼 git grep -c 가 0 인 파일은 줄로 나오지 않는다(shell_router_test 의 ⓡ 0 · shell_scaffold_test 의 ⓗ 0) — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다)
  (🆕 이번 기대 — 위 600~608행의 «기대(드라이런 실측)» 보다 이 줄이 이긴다: 34줄의 출력 = C4 수정안 시험 재실행과 같은 197줄(warning: 줄 넷 빼고 · EXIT 줄 34 포함) ·
   1회차 출력과 다른 곳은 줄 번호 셋뿐이다 — S07 «lib/src/shell_scaffold.dart:367:» → «…:363:» · S22 «lib/src/shell_scaffold.dart:275:s01-band-chip» 줄이 빠지고 그 뒤 shell_scaffold 일곱 줄의 번호가 4씩 준다
   (283→279 s02-item · 295→291 s02-kill-slot · 321→317 s01-title · 331→327 s02-handbook-slot · 340→336 s01-home-slot · 375→371 s01-band · 386→382 s01-band-chip) ·
   S29 «test/ops_rhythm_test.dart:132:»·«…:133:» → «…:133:»·«…:134:» · 나머지는 1회차와 글자 같다(S06 4줄 · S26 labels «41 0» 도 1회차 그대로가 맞다 — 고치지 않는다) ·
   🔴 S20·S21·S32 가 7·8 · 1·1 · 6·3·4 와 다르면 제출하지 말고 상자를 다시 본다 · 그 밖의 줄이 이와 다르면 멈춘 뒤 채팅으로)

■ 테스트 수 묶음 — packages/ui_shell 에서 여섯 줄(조각 15 와 조각 22 의 끝 줄은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다 · 파일로 떠서 붙인다)
  flutter test test/shell_router_test.dart          ← 끝 줄 «+18: All tests passed!» 기대(1회차와 같음)
  flutter test test/shell_scaffold_test.dart        ← «+24: All tests passed!» 기대(1회차와 같음 — 상자 11~16 은 testWidgets·경우 수를 바꾸지 않는다)
  flutter test test/ops_rhythm_test.dart            ← «+15: All tests passed!» 기대(1회차 +14 → +15 — 상자 17 의 T02-05 not_loaded_stale 1)
  flutter test test/golden/s01_golden_test.dart     ← «+4: All tests passed!» 기대(1회차와 같음 · --update-goldens 없이)
  flutter test test/golden/h02_golden_test.dart     ← «+4: All tests passed!» 기대(1회차와 같음 · --update-goldens 없이)
  flutter test                                      ← 끝 줄 «+66: All tests passed!» 기대(1회차 +65 → +66 — C4 시험 «+66»)
  PowerShell 에서 파일로 뜨는 꼴(예 — 이름은 아무것이나 · 저장소 밖):
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    flutter test test/shell_router_test.dart | Out-File -Encoding utf8 $env:TEMP\r13a_t_router.txt
    Get-Content -Encoding UTF8 $env:TEMP\r13a_t_router.txt | Select-Object -Last 1   ← 이 줄을 그대로 복사(나머지 다섯도 같은 꼴로 r13a_t_scaffold.txt · r13a_t_ops.txt · r13a_t_s01.txt · r13a_t_h02.txt · r13a_t_all.txt)
  (수가 +18 · +24 · +15 · +4 · +4 · +66 과 다르면 제출하지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로 — 상자의 수를 맞추려 고쳐 쓰지 않는다 · 골든이 실패하면 PNG 를 다시 찍지 않고 멈춘다.)

■ 제출
  (상자 1~17 을 고치고 «고친 뒤 확인» 이 기대와 같은 뒤 · packages/ui_shell 에서)
  flutter test   ← 옵션 없이 전부 통과 · «+66: All tests passed!»(실패하면 실패한 테스트 파일의 상자와 다시 대조 · PNG 를 고치지 않는다)
  cd ../..
  melos.bat run format:fix
  git status --short   ← M 은 아래 다섯 줄뿐이어야 합니다(PNG·질문 파일·그 밖의 파일의 M = 금지 → git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로):
        M packages/ui_shell/lib/src/shell_scaffold.dart · M packages/ui_shell/test/golden/s01_golden_test.dart · M packages/ui_shell/test/ops_rhythm_test.dart ·
        M packages/ui_shell/test/shell_router_test.dart · M packages/ui_shell/test/shell_scaffold_test.dart
  git add packages/ui_shell/lib/src/shell_scaffold.dart packages/ui_shell/test/golden/s01_golden_test.dart packages/ui_shell/test/ops_rhythm_test.dart packages/ui_shell/test/shell_router_test.dart packages/ui_shell/test/shell_scaffold_test.dart
  git commit -m "[M8] R13a (10) C4 반려 수정 — TS-07 NavigationBar 0 · 사이드바 칩 Key · 테스트 흐름·전제 · 빈+오래됨 경우"   ← 위 «커밋 제목» 상자 글자 그대로
  bash tool/check_boundaries.sh   ← 실패 0 · ui_shell 의 🟡 [C-5] 0 · 🔵 main 에 원래 있는 ui_journal 1건(«packages/ui_journal/lib/src/timeline.dart:109»)은 이 재제출과 무관 — 그대로 둔다
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed(🔴 백그라운드·파이프 금지)
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git diff --stat HEAD~1   ← 마지막 줄 « 5 files changed, 167 insertions(+), 92 deletions(-)»
  git diff --name-status 1195787 HEAD
     ← 재제출 커밋의 변경만 봅니다. 🔴 정확히 이 다섯 줄이어야 합니다:
        M	packages/ui_shell/lib/src/shell_scaffold.dart
        M	packages/ui_shell/test/golden/s01_golden_test.dart
        M	packages/ui_shell/test/ops_rhythm_test.dart
        M	packages/ui_shell/test/shell_router_test.dart
        M	packages/ui_shell/test/shell_scaffold_test.dart
        다른 줄이 한 줄이라도 나오면(PNG · 질문 파일 · shell_fakes …) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git log --oneline -2   ← 맨 위 = 재제출 커밋 · 그 아래 = 1195787 [M8] R13a (9) S25 autoDispose in comment removed(지난 커밋은 그대로)
  사전검사 ① 코드만(저장소 뿌리에서 · 1회차 카드 658행과 같은 명령 · 출력은 채팅에 붙이지 않는다 — C4 가 같은 줄을 다시 돌린다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 첫 줄 «── 사전검사 · head <재제출 커밋> · 공통 조상 b341aa8» · 끝 줄 «── 결과: 🔴 0 · 🟡 0 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)»(C4 시험).
        🔴 가 하나라도 나오면 푸시하지 않고 고치지도 않는다 — 출력 전부를 채팅으로(이 글의 상자대로면 0 이다 · 다른 꼴로 감추는 고침 = 반려).
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push origin ui/m8-s01-shell   (같은 브랜치 → PR #71 자동 반영 · 새 PR·라벨·강제 푸시(--force · --force-with-lease)·rebase·main 병합 금지)
  아래 출력은 푸시한 그 커밋 위에서 · git status 가 빈 채로 · 1회차 출력을 쓰지 않는다 · 전부 파일로 떠서:
   git diff --name-status origin/main...HEAD   ← 조각 3(기대 = 1회차와 같은 24줄 · 고친 다섯 파일은 1회차부터 A 라 줄이 늘지 않는다 · 첫 줄 «M	docs/ai-context/inbox/S01H02_questions.md» · 끝 줄 «A	packages/ui_shell/test/shell_scaffold_test.dart» · 다르면 멈춘 뒤 채팅으로)
   git log --oneline origin/main..HEAD         ← 조각 5(10줄 · 맨 위 = 재제출 커밋 · 그 아래 9줄 = 1회차 그대로 «1195787 [M8] R13a (9) S25 autoDispose in comment removed» … «83f34a4 [M8] R13a (1) 정적 라벨 · 공용 조각 · 주입» · 다르면 멈춤)
   cd packages/ui_shell → 위 «정적 묶음» 34줄 → 조각 11 → 위 «테스트 수 묶음» 여섯 줄 → 조각 15 · 조각 22 → cd ../..
   git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/S01H02_questions.md   ← 저장소 뿌리에서 · «+|» 로 시작하는 줄이 조각 20 상자 4줄과 글자 같아야 한다(질문 파일 불변 — 다르면 멈춘 뒤 채팅으로 · 이 출력은 붙이지 않는다 · 조각 20 은 상자 글자로 낸다)
  git status --short   ← 🔴 다시 비어 있어야 합니다(명령이 파일을 바꾸었으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다.

■ 보고 글 — ①~⑤ 전체판 (12 §3 재제출 조문 «전체판 + 바뀔 자리만 상자»)
  🔴 채팅 글 = 아래 조각 1~22 를 이 차례로 이은 것뿐입니다. 조각은 세 갈래입니다:
     [상자] = 복사 상자 글자 그대로(한 글자도 바꾸지 않는다 — 바뀌지 않는 자리는 1회차 Bob 글자를 그대로 옮긴 상자 · 바뀌는 자리는 C4 가 준 상자) ·
     [출력] = 위 «■ 제출» 에서 다시 돌린 명령 출력을 파일로 떠서 그대로(줄을 고르거나 줄이거나 고쳐 쓰지 않는다) · [틀] = 상자 글자 그대로 두고 <…> 자리에만 출력.
  🔴 상자와 출력 밖에는 아무 글도 짓지 않습니다 — 머리말(«모든 확인 완료 …» · «재제출 글입니다» · «이제 제출 글을 작성합니다») · 구분선 --- · 요약 · 설명 · 까닭 줄 · 끝인사 0.
     기대와 다른 출력이 나오면 글로 설명하지 말고 제출을 멈춘 뒤 채팅으로 출력을 보입니다(위 «■ 제출» 의 멈춤 줄).
  🔴 첫 줄 = 조각 1 의 첫 줄 «## ① 구현한 화면 ID · 바뀐 파일 · 커밋»(1회차 카드 672행 N1) · 조각 사이에는 빈 줄 하나를 둔다(빈 줄은 대조에서 뺀다) · 상자 머리·끝 줄(┌── · └──)은 붙이지 않는다.
  🔴 «코드 블록 하나로» = 위아래에 백틱 세 개 줄을 두른다(1회차 글과 같은 꼴) · «코드 블록 없이» = 줄만 그대로 · 조각마다 둘 중 하나를 적어 두었다.
  🔴 PNG 는 열지 않는다 — 골든 표(조각 18)는 통합 담당이 맞춘 글자다(배치·잘림 칸 = C4 · 앞 다섯 칸 = 카드 6열 꼴(이름·입력 픽스처·플래그·크기·위치 전제 dy) — 1회차 PNG·dy 그대로).
  조각 1 [상자 · 바뀌지 않는 자리 · ① 섹션 머리 + 화면 ID 3줄] — 코드 블록 없이
      ┌── 조각 1 복사 시작(다음 줄부터 · 4줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
화면 ID: S-01 — 폰 5탭 셸(ShellRoot · ShellBandOverlay)
화면 ID: S-02 — 웹 사이드바 셸(ShellRoot 레이아웃 분기)
화면 ID: H-02 — 운영 리듬 표(OpsRhythm())
      └── 조각 1 복사 끝(이 줄 앞까지)
  조각 2 [상자] — 코드 블록 없이
      ┌── 조각 2 복사 시작(다음 줄부터 · 1줄)
바뀐 파일:
      └── 조각 2 복사 끝(이 줄 앞까지)
  조각 3 [출력] 위 «■ 제출» 의 git diff --name-status origin/main...HEAD 출력 그대로 — 코드 블록 하나로
      (기대 24줄 = 1회차와 같음 · 첫 줄 «M	docs/ai-context/inbox/S01H02_questions.md» · 끝 줄 «A	packages/ui_shell/test/shell_scaffold_test.dart»)
  조각 4 [상자] — 코드 블록 없이
      ┌── 조각 4 복사 시작(다음 줄부터 · 1줄)
커밋 목록:
      └── 조각 4 복사 끝(이 줄 앞까지)
  조각 5 [출력 · 바뀌는 자리] 위 «■ 제출» 의 git log --oneline origin/main..HEAD 출력 10줄 그대로 — 코드 블록 하나로
      (맨 위 = 재제출 커밋 «<해시> [M8] R13a (10) C4 반려 수정 — TS-07 NavigationBar 0 · 사이드바 칩 Key · 테스트 흐름·전제 · 빈+오래됨 경우» · 그 아래 9줄 = 1회차 그대로 «1195787 [M8] R13a (9) S25 autoDispose in comment removed» … «83f34a4 [M8] R13a (1) 정적 라벨 · 공용 조각 · 주입»)
  조각 6 [상자 · 바뀌지 않는 자리 · ② 섹션 머리] — 코드 블록 없이
      ┌── 조각 6 복사 시작(다음 줄부터 · 1줄)
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
      └── 조각 6 복사 끝(이 줄 앞까지)
  조각 7 [상자 · 바뀌지 않는 자리 · 자체 점검 10항 10줄(1회차 괄호까지 · 다시 채우지 않는다)] — 코드 블록 없이
      ┌── 조각 7 복사 시작(다음 줄부터 · 10줄)
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 S14 — 허용 밖 import 0줄 · pubspec·analysis_options 무변경(S26))
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] (산술 = 신선도 한 식(H-02) + P0 미확인 존재 1식(S11 1줄) + 라우터 일치·가드 표뿐 · 건수·D-day·편차 0 · 금지 수치 S16 0건 · 소수·% 리터럴 S17 0건)
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] (DateTime.now 0(S04) · 시계 = shellClockProvider 주입 · 오래됨 = T02-05)
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] (탭 5 = 홈·일지·보유·계획·더보기(TS-01) · 수익률 진입점 0(S04 performanceExplore 0줄) · 홈 숫자 = 이 카드 범위 밖(R13b))
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] (이 카드 범위 밖(알림 센터 = R14) · 탭 배지 = P0 미확인 점 하나(TS-02))
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] (이 카드 범위 밖(DND = R14))
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] (이 카드 범위 밖(W-01 = R15~R16))
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] (이 카드 범위 밖(시크릿 입력 0))
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] (이 카드 범위 밖(온보딩 = R15))
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] (킬스위치 = 웹 사이드바 빈 자리 s02-kill-slot(TS-07 · 링크 화면 위에서도 TR-07) · 폰 진입 = 전역 배너(이 카드 범위 밖 · M5) · M5 화면 0 · 앱 잠금 = 이 카드 범위 밖)
      └── 조각 7 복사 끝(이 줄 앞까지)
  조각 8 [상자] — 코드 블록 없이
      ┌── 조각 8 복사 시작(다음 줄부터 · 1줄)
10항 줄 수:
      └── 조각 8 복사 끝(이 줄 앞까지)
  조각 9 [상자 · 바뀌지 않는 자리 · 10항 줄 수 출력 한 줄(조각 7 이 1회차 글자 그대로라 1회차 출력 그대로 — 다시 세지 않는다)] — 코드 블록 하나로
      ┌── 조각 9 복사 시작(다음 줄부터 · 1줄)
10
      └── 조각 9 복사 끝(이 줄 앞까지)
  조각 10 [상자] — 코드 블록 없이
      ┌── 조각 10 복사 시작(다음 줄부터 · 1줄)
정적 묶음 출력:
      └── 조각 10 복사 끝(이 줄 앞까지)
  조각 11 [출력] 위 «정적 묶음» 34줄의 출력 전부 — 코드 블록 하나로
      (줄이지 않는다 · 빈 줄도 지우지 않는다 · warning: 줄이 나오면 지우지 않고 그대로 · 기대 = 위 «🆕 이번 기대»(197줄 · 1회차와 다른 곳 = S07 · S22 · S29 줄 번호뿐))
  조각 12 [상자 · 바뀌는 자리 · C4s-11 · S05 결과(1회차 «S05 결과 줄:» + 코드 블록 → 카드 715행 꼴)] — 코드 블록 없이
      🔴 둘째 줄은 조각 11 의 S05 출력(경로·줄 번호)과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 멈춘 뒤 채팅으로(lib 가 상자 1 밖에서 바뀌었다).
      ┌── 조각 12 복사 시작(다음 줄부터 · 2줄)
S05 결과:
lib/src/ops_rhythm.dart:111 — 탭 콜백 안
      └── 조각 12 복사 끝(이 줄 앞까지)
  조각 13 [상자 · 바뀌는 자리 · C4s-11 · ⓡⓗ(카드 717~722행 꼴)] — 코드 블록 없이
      🔴 둘째·셋째 줄은 조각 11 의 S20 출력 줄, 다섯째·여섯째 줄은 S21 출력 줄과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 멈춘 뒤 채팅으로(상자가 다르게 옮겨졌다).
      ┌── 조각 13 복사 시작(다음 줄부터 · 6줄)
ⓡ = S20 출력:
test/ops_rhythm_test.dart:7
test/shell_scaffold_test.dart:8
ⓗ = S21 출력:
test/ops_rhythm_test.dart:1
test/shell_router_test.dart:1
      └── 조각 13 복사 끝(이 줄 앞까지)
  조각 14 [상자 · 바뀌는 자리 · C4s-11] — 코드 블록 없이
      ┌── 조각 14 복사 시작(다음 줄부터 · 1줄)
테스트 파일별:
      └── 조각 14 복사 끝(이 줄 앞까지)
  조각 15 [출력 · 바뀌는 자리 · C4s-11] 위 «테스트 수 묶음» 의 다섯 파일 끝 줄 그대로 5줄(shell_router_test · shell_scaffold_test · ops_rhythm_test · s01_golden_test · h02_golden_test 순) — 코드 블록 없이
      (기대 «+18» · «+24» · «+15» · «+4» · «+4» — 줄 머리 경과 시각은 출력 그대로)
  조각 16 [상자 · 바뀌는 자리 · C4s-12 · ③ 섹션 머리 + 스크린샷 서술 7줄(카드 723~730행 꼴 · 코드 차례 그대로 — C4 가 코드로 맞춘 글자)] — 코드 블록 없이
      ┌── 조각 16 복사 시작(다음 줄부터 · 8줄)
## ③ 스크린샷 서술 · 골든 표
S-01 «로딩» = ShellSkeleton(Key('s01-loading'))
S-01 «정상» = ShellBandOverlay → Key('s01-band')(있을 때) → ValueKey<String>('s01-band-chip-$i')(있을 때) → ShellRoot → Navigator → Scaffold → Key('s01-title') → IndexedStack → Key('s01-home-slot') → Key('s01-tabs') → Key('s01-p0-dot')(있을 때)
S-01 «에러» = ShellErrorView(Key('s01-fail'))
S-02 «정상» = ShellBandOverlay → Key('s01-band')(있을 때) → ShellRoot → Key('s02-sidebar') → Key('s02-view-only') → Key('s02-mode-chips')(있을 때) → ValueKey<String>('s02-item-$i') → Key('s02-kill-slot') → Navigator → Scaffold → Key('s01-title') → IndexedStack
H-02 «로딩» = ShellSkeleton(Key('h02-loading'))
H-02 «정상» = ListView → Key('h02-asof') → ShellStaleBanner(있을 때) → Key('h02-head') → ValueKey<String>('h02-row-$i') → ValueKey<String>('h02-title-$i') → ValueKey<String>('h02-when-$i') → ValueKey<String>('h02-dday-$i')(있을 때)
H-02 «빈» = ListView → Key('h02-asof') → ShellStaleBanner(있을 때) → Key('h02-empty')(있을 때)
      └── 조각 16 복사 끝(이 줄 앞까지)
  조각 17 [상자] — 코드 블록 없이
      ┌── 조각 17 복사 시작(다음 줄부터 · 1줄)
골든 표:
      └── 조각 17 복사 끝(이 줄 앞까지)
  조각 18 [상자 · 바뀌는 자리 · C4s-13 · ③ 골든 표 머리 2줄 + 8행(카드 6열 · 배치·잘림 칸 = C4 · 앞 다섯 칸 = 1회차 PNG·dy 그대로)] — 코드 블록 없이
      ┌── 조각 18 복사 시작(다음 줄부터 · 10줄)
| 이름 | 입력 픽스처 | 플래그 | 크기 | 위치 전제 dy | 배치·잘림 |
|---|---|---|---|---|---|
| s01_tabs_p0 light | alerts_12.json | 모의·안내 | 390×844 | 844.0 | 배경 덩어리(칩 2개 · 한 줄) → 글자 1줄 → 빈 자리 → 배경 덩어리(아이콘 5개 · 글자 1줄 · 첫 아이콘 둥근 상자 · 점 1개) — 잘림 없음 |
| s01_tabs_p0 dark | alerts_12.json | 모의·안내 | 390×844 | 844.0 | 배경 덩어리(칩 2개 · 한 줄) → 글자 1줄 → 빈 자리 → 배경 덩어리(아이콘 5개 · 글자 1줄 · 첫 아이콘 둥근 상자 · 점 1개) — 잘림 없음 |
| s01_tabs_clean light | m8/alerts_digest.json | 실전·자동 | 390×844 | 844.0 | 글자 1줄 → 빈 자리 → 배경 덩어리(아이콘 5개 · 글자 1줄 · 첫 아이콘 둥근 상자) — 잘림 없음 |
| s01_tabs_clean dark | m8/alerts_digest.json | 실전·자동 | 390×844 | 844.0 | 글자 1줄 → 빈 자리 → 배경 덩어리(아이콘 5개 · 글자 1줄 · 첫 아이콘 둥근 상자) — 잘림 없음 |
| h02_rows light | m8/ops_rhythm_rows.json | 없음 | 390×844 | 292.0 | 글자 1줄 → 글자 1줄(두 칸) → 글자 5줄(줄마다 두 칸) → 빈 자리 — 잘림 없음 |
| h02_rows dark | m8/ops_rhythm_rows.json | 없음 | 390×844 | 292.0 | 글자 1줄 → 글자 1줄(두 칸) → 글자 5줄(줄마다 두 칸) → 빈 자리 — 잘림 없음 |
| h02_not_loaded light | m8/ops_rhythm_empty.json | 없음 | 390×844 | 76.0 | 글자 1줄 → 글자 1줄 → 빈 자리 — 잘림 없음 |
| h02_not_loaded dark | m8/ops_rhythm_empty.json | 없음 | 390×844 | 76.0 | 글자 1줄 → 글자 1줄 → 빈 자리 — 잘림 없음 |
      └── 조각 18 복사 끝(이 줄 앞까지)
  조각 19 [상자] — 코드 블록 없이
      ┌── 조각 19 복사 시작(다음 줄부터 · 1줄)
## ④ 질문 목록
      └── 조각 19 복사 끝(이 줄 앞까지)
  조각 20 [상자 · 바뀌는 자리 · C4s-14 · ④ = 질문 파일 diff 의 «+|» 줄 4줄(위 «■ 제출» 의 질문 파일 diff 와 글자 같아야 한다)] — 코드 블록 하나로
      ┌── 조각 20 복사 시작(다음 줄부터 · 4줄)
+| A1 | R13a-Bob-S01H02 | 추측 | 측정: s01_tabs_p0 dy 실측값 (light=844, dark=844) = 844 | 골든 위치 전제 실측 | 844 확인 | ⬜ 미답 | |
+| A2 | R13a-Bob-S01H02 | 추측 | 측정: s01_tabs_clean dy 실측값 (light=844, dark=844) = 844 | 골든 위치 전제 실측 | 844 확인 | ⬜ 미답 | |
+| A3 | R13a-Bob-S01H02 | 추측 | 측정: h02_rows dy 실측값 (light=292, dark=292) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
+| A4 | R13a-Bob-S01H02 | 추측 | 측정: h02_not_loaded dy 실측값 (light=76, dark=76) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 조각 20 복사 끝(이 줄 앞까지)
  조각 21 [상자 · 바뀌는 자리 · C4s-15 · ⑤(새 A 행이 전부 «측정:» 이라 «없음»)] — 코드 블록 없이
      ┌── 조각 21 복사 시작(다음 줄부터 · 2줄)
## ⑤ 추측한 것 목록
없음
      └── 조각 21 복사 끝(이 줄 앞까지)
  조각 22 [틀 · 바뀌는 자리 · C4s-11 · 끝 줄] — 코드 블록 없이
      <…> 자리에만 위 «테스트 수 묶음» 의 flutter test(전체) 끝 줄 그대로(시각·«+수»·«All tests passed!» 까지 · «끝 66» 처럼 수만 쓰지 않는다 · «시작 기준 1» 은 1회차 글자 그대로)
      ┌── 조각 22 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 1 → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 조각 22 복사 끝(이 줄 앞까지)
■ 내기 전 자기 확인 — 사전검사 ② (1회차 카드 673~676행 글자 그대로 · 이번 기대는 그 아래 «🆕 이번 기대» 가 이긴다)
  제출 글 전체 = 조각 1~22 를 이은 글(①~⑤ + flutter test 한 줄) · $env:TEMP 에 쓸 수 없으면 저장소 뿌리의 build\R13a-Bob-S01H02_submit.md(커밋하지 않는다) — 아래 네 줄은 1회차 카드 673~676행 글자 그대로:
      🔴 N3 — 내기 전 사전검사 ② — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R13a-Bob-S01H02_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서 **두 줄**(접두마다 한 번 · 골든 표는 한 표):
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R13a-Bob-S01H02_submit.md --golden-prefix s01_ --goldens 4
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R13a-Bob-S01H02_submit.md --golden-prefix h02_ --goldens 4
        ← 🔴 두 줄 모두 0 이어야 채팅에 낸다 · 출력은 채팅에 붙이지 않는다 · 🔵 접두 하나는 그 접두 행만 센다(다른 접두 행은 그 줄의 검사 밖 — 표는 8행 한 표) · 🔵 🟡 [G1] 은 멈춤이 아니다(드라이런 = s01_ 🟡 1(괄호가 든 칸은 셀 수 없음) · h02_ 🟡 0) — 표는 이 카드의 셈 단위대로.
  🆕 이번 기대(위 676행의 «드라이런 = s01_ 🟡 1 · h02_ 🟡 0» 은 1회차 판의 셈 · 이번은 C4 상자라 아래가 맞다):
     두 줄 모두 끝 줄 «── 결과: 🔴 0 · 🟡 1 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)» 이어야 채팅에 낸다(출력은 채팅에 붙이지 않는다).
     🟡 1 = 줄마다 [G1] 하나 · 자리 = 그 접두의 골든 표 4행(s01_ = s01_tabs_p0 · s01_tabs_clean 의 light·dark · h02_ = h02_rows · h02_not_loaded 의 light·dark) — 기계가 «(칩 2개 · 한 줄)» 같은 괄호 안 «·» 나열과
        «(두 칸)» · «빈 자리» 가 든 칸을 덩어리로 세지 못해 «배치·잘림 칸을 덩어리로 셀 수 없어 PNG 와 대조하지 않았다» 고 적는다(멈춤 아님).
     🔴 끝 줄의 «🟡 는 PNG·글을 다시 보고 판단» 은 이 두 줄에서는 따르지 않는다 — PNG 0장 · 조각 18 은 통합 담당이 맞춘 상자다 · 🟡 를 없애려고 상자를 고쳐 쓰지 않는다.
     🔴 가 나오거나 🟡 의 수가 이와 다르면 상자를 다시 옮긴다(조각을 빠뜨렸거나 글자가 바뀐 것) · 그래도 다르면 멈춘 뒤 채팅으로.
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m8-s01-shell` 에 추가 커밋 **1개**: `[M8] R13a (10) C4 반려 수정 — TS-07 NavigationBar 0 · 사이드바 칩 Key · 테스트 흐름·전제 · 빈+오래됨 경우`. main 병합 커밋 **없음** · 지난 9개 커밋 **그대로**(`git log --oneline origin/main..HEAD` = 10줄 · 맨 위 = 재제출 커밋 · 아래 9줄 = 1회차 글자).
- `packages/ui_shell/` 수정 5(lib 1 · test 4) — 상자 1~17 자리뿐(합 +167/−92 · C4 시험 diff `judge/fix.diff` + `judge/fix_extra.diff` 와 같은 글자 — 통합 담당이 `git diff 1195787 HEAD` 를 그 두 diff 와, 트리의 파일을 C4 수정안 파일(blob `c3921f8` · `8c7774a` · `1b059e8` · `b52fecc` · `9b39969`)과 대조한다).
- PNG 변경 0 · 가짜·`h02_golden_test.dart`·비교기·질문 파일 변경 0 — `git diff --name-status 1195787 HEAD` = 다섯 줄.
- `ui_shell` `flutter test` **66**(파일별 +18 · +24 · +15 · +4 · +4 — ops_rhythm 만 1회차 +14 → +15 · 카드 739행 «M = N + 64 · 다르면 «까닭:»» 는 이번에 적용하지 않는다 — 66 = 65 + 상자 17(발주자 결정 ②) · 까닭 줄 없음이 정답) · 정적 34줄 출력 = C4 수정안 출력과 같은 글자(1회차와 다른 곳 = S07 · S22 · S29 줄 번호 · S20 7·8 · S21 1·1 · S32 6·3·4 · S05 `:111`) · 사전검사 ① 🔴 0 · 🟡 0.
- 채팅: 보고 글 ①~⑤ **전체판** = 조각 1~22(상자 17 · 출력 4 · 틀 1) — 첫 줄 `## ① 구현한 화면 ID · 바뀐 파일 · 커밋` · 섹션 머리 5줄(1회차와 같은 글자) · 조각 3 name-status 24줄 · 조각 5 git log 10줄 · 조각 11 정적 34줄 출력 전부 · 조각 12·13 S05·ⓡⓗ 상자 · 조각 15 테스트 파일별 5줄 · 조각 16 ③ 서술 7줄 · 조각 18 골든 표 8행(C4 상자) · 조각 20 ④ 4줄 · 조각 21 ⑤ «없음» · 조각 22 끝 줄 · 그 밖은 1회차 글자 상자 그대로 · 상자·출력 밖 글 0 · 사전검사 ② 🔴 0 · 🟡 1 + 1(G1).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R13a-Bob-S01H02 재제출: PR #71 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 채팅 글(①~⑤ 전체판 — 첫 줄 `## ①` 부터 끝 줄 `flutter test: …` 까지)을 붙여넣습니다(Claude 가 PR #71 본문을 이 글로 통째로 바꿉니다). 0단계·«먼저 할 것»·«고친 뒤 확인»·«■ 제출» 에서 멈췄다면 `R13a-Bob-S01H02 재제출 0단계에서 멈춤 — 확인해줘`(멈춘 자리 이름으로) + Bob 이 보여 준 출력. Bob 이 상자 밖 글(머리말·요약·까닭 줄)을 더해 냈다면 그대로 붙여넣되 «상자 밖 글 있음» 이라고 함께 알립니다(통합 담당이 strict 나눔으로 가른다). Bob 이 PNG 를 열었거나 다시 찍었다면 그 사실도 함께 알립니다.

## 5. 주의

- **5분 눈 검사**(PR #71 «Commits» · «Files changed» — `1195787` 뒤 커밋만 보면 된다): ① 커밋 수가 10 이 아님 · 지난 9개 해시가 바뀜(강제 푸시·rebase 흔적) · `Merge … origin/main` 커밋 ② 고친 다섯 파일 밖의 변경(`lib/` 의 다른 파일 · `shell_fakes.dart` · `h02_golden_test.dart` · 비교기 · 질문 파일 · `pubspec.yaml` · `domain_contracts/**`) ③ PNG 변경(이번에는 한 장도 바뀌면 안 된다 — `s01_*` · `h02_*`) ④ `shell_scaffold.dart` 에 `s01-band-chip` 이 두 곳 · `shell_scaffold_test.dart` 에 `find.byType(NavigationBar), findsNothing` 이 없음 · 테스트에 `if (c.` · `c.name ==` · `flow.name ==` 가 남음 · `ops_rhythm_test.dart` 에 `not_loaded_stale` 이 없음 ⑤ 채팅 글 조각 18 이 상자와 다름 · 첫 줄 위의 섹션 밖 글 · 상자 밖 글 — 하나라도 있으면 반려 신호(⑤ 는 strict 나눔 ① 표기만이면 C4 정정 대상).
- CI: 3/3 기대 — 이 카드는 새 PNG 만이라 `golden:approved` 는 붙이지 않는다. «분석 · 테스트(melos)» 는 Bob 의 푸시(새 `pull_request` synchronize)로 새 `main`(엔진 PR #70 · 프롬프트 v2 `34bf60a` · 기록 커밋 포함) 위의 병합 미리보기를 다시 돌린다 — 그 커밋들은 `ui_shell` 밖이라 수는 C4 시험과 같은 것이 기대(`domain_contracts` 는 그 시점 main 의 수).
- C4 가 2회차에서 볼 것(C4 보고 §0 · §5-A): 기계 = `1195787..HEAD` 5파일 M · hunk 가 상자 1~17 자리뿐(`judge/fix.diff` + `judge/fix_extra.diff` 와 글자 대조 · 트리의 파일 = C4 수정안 blob 5개) · 지난 9개 해시 불변 · 전체 +66 · analyze · format · 사전검사 ①② · CI / 변이 = 예고 76꼴 + 참고 10 + 탐침 4 재실행(S23 · H15b 가 이제 잡혀야 함 · J01 · J03b KILLED · 약해진 꼴 0) / 정직 = 전체판의 [상자] 조각은 이 패킷 상자 글자와(바뀌지 않는 자리 = 1회차 Bob 글자 · 조각 12·13·16·18·20·21 = C4 상자 · 조각 22 = 틀) · [출력] 조각(3·5·11·15 · 22 의 끝 자리)은 재실행 출력과 글자 대조(테스트 끝 줄의 줄 머리 경과 시각(mm:ss)은 대조에서 뺀다) · 상자·출력 밖 글 0 · N1·N3 다시 · 질문 파일 불변. 판정 기준 = 1회차 카드 strict 나눔(카드 169행 · ① 표기만 = C4 정정 · ② 코드·테스트·거짓 = 반려 · ③ 예고 변이 = 반려).
  - 🔴 **C4s-2 는 테스트로 잡히지 않는다**(2026-10-27 드라이런 — «사이드바 칩에 `s01-band-chip-$i` Key 되살리기» 변이 = +66 통과 · 다른 하위 트리의 같은 ValueKey 는 오류가 아님) — 2회차 기계 검사에 `git grep -c "s01-band-chip" HEAD -- packages/ui_shell/lib/src/shell_scaffold.dart` = `1` 과 `shell_scaffold.dart` blob `c3921f8` 대조를 반드시 넣는다(정적 S22 줄 번호도).
  - 대조 기준 = **blob 5개**(`c3921f8` · `8c7774a` · `1b059e8` · `b52fecc` · `9b39969`) — scratchpad `judge/fixed/` 폴더는 기준으로 쓰지 않는다(그 폴더의 `ops_rhythm_test.dart` 는 원래 상자 1~16 판 `81e69b3` 이었고 2026-10-27 상자 17 을 넣어 `1b059e8` 로 바꿨다) · `judge/fix_extra.diff` 는 일반 `diff -u` 꼴이라 저장소 뿌리에서 `git apply --directory=packages judge/fix_extra.diff` 로 적용한다(`fix.diff` 는 그냥 `git apply`) · 정직성 대조의 바이트 기준 = 이 패킷 조각 1~22 + 재실행 출력(드라이런 조립판 scratchpad `dry_resubmit.md` 327줄도 같다) — `judge/resubmit_preview.md` 는 **상자 17 이전 판**(커밋 제목 · ops «+14» · 끝 줄 «+65» 가 다름)이라 🟡 수 확인에만 쓴다.
  - 카드 739행 «기대 M = N + 64 · 다르면 그 위 한 줄에 «까닭:»» 는 이번에 적용하지 않는다 — 66 = 65 + 상자 17(발주자 결정 ②) · 본문이 까닭 줄을 금하므로(«상자·출력 밖 글 0») 까닭 줄 없음이 정답이고, 없다고 ① 표기 결함으로 적지 않는다.
- 병합 뒤 할 일(Claude · C4 보고 §6 · §7-M): 질문 파일 A1~A4 답 칸(앞 6칸 = Bob 글자 그대로) · 머리말 «다음 번호 = Q1·A5» · golden README «🆕 R13» 절 ✅·R13a 병합본 실측 줄(8장) · `packages/ui_shell/README.md` 지금 상태 · PR 본문 «C4 정정» 한 곳(C4s-16 커밋 (7)~(9)·(8) 제목 · 커밋은 고치지 않음) · 1회차 본문 댓글 보존 · 패킷 이동은 이 재제출 패킷 `send/R13a-Bob-S01H02-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · `send/_대기/R13b-Bob-H01.md` 자리표시자(`__R13A_SQ__` · ⟦실측⟧ — 시작 기준 = 병합본 `flutter test` 끝 수(기대 66) · 🔴 H13 셈 = C4s-30) — R13b 는 선행 2 M2 보강 병합 전까지 `_대기` · 팩 판은 그다음 접미 · 2회차 보고 보존본 `10_리뷰/<날짜>_R13a_C4_2회차_보고.md`.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R13a 패킷은 이 파일 하나입니다. 원 패킷 `R13a-Bob-S01H02.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 한다).
- 범위 밖: C4 보고 §8 의 보강 후보 C4r13a-1(«빈 + 오래됨» 경우 — 이 재제출 상자 17 이 R13a 몫을 막는다 · 카드 조립 체크리스트 한 줄은 다음 카드) · C4r13a-2~9 는 설계 12 §3 «R13a C4 이월 부록» 에 적었다 — 다음 카드 조립 때 · 이 재제출에는 넣지 않는다(이 재제출은 위 상자 1~17 과 «커밋» 상자 1개 그대로 · 조각 12·13·16·18·20·21 상자는 C4s-11~15 표기 정정이지 카드 조문 개정이 아니다).
