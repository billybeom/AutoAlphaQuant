# 발송 패킷 R13b-Bob-H01 — 재제출 (1회차 반려 · 2026-10-27)

> ⬜ **「푸시해」 뒤 보냄** — 이 파일이 GitHub `main` 의 `send/` 에 있으면 이 조건은 풀린 것(이 패킷과 원 패킷의 `send/_완료/` 이동이 `main` 에 올라간 뒤 · 다른 선행 없음 — PR #74 반려 댓글 게시됨(2026-10-27 · issuecomment-6433496842) · 아래 «보내는 조건» · `send/README.md` 배지 규칙).
> 만든 날 2026-10-27 · 1회차(PR #74 · 브랜치 `ui/m8-h01-home` · 커밋 `81d9ace` · 밑동 `4206274` · 커밋 7 · CI run 40440626380 = 경계 규칙·골든 스냅샷·분석·테스트(melos) 3/3 pass)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-27): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #74 · Bob 이 상자 1~47 을 적용하고 PNG 16장을 `flutter test --update-goldens test/golden/h01_golden_test.dart` **1명령**으로 다시 찍어 **커밋 1개**로 · PNG 열람 0 · 지난 7커밋 그대로 · amend·rebase·force 금지 · `h01_*` 는 `main` 에 없는 새 파일이라 PR 기준 A — CI «골든 스냅샷» 이 세 점 diff 로 A 만 보므로 `golden:approved` 불필요 — 2026-10-27 Claude 가 `.github/workflows/ci.yml` 으로 확인) ② **엔진 E8a PR #73 = R13b 병합 뒤**(`main` 계약 `'1.13.0'` · `domain_contracts` «+389 ~30» 그대로 전제 — 0단계가 `origin/main` 계약 줄을 본다).
> 고치는 것 = **파일 여섯**(`packages/ui_shell/lib/src/ops_home.dart` · `lib/src/shell_providers.dart` · `test/shell_fakes.dart` · `test/golden/h01_golden_test.dart` · `test/ops_home_test.dart` · `docs/ai-context/inbox/H01_questions.md` — 아래 상자 1~47 = «이 줄을 → 이 줄로» · 합 +433/−215) **+ `h01_*` PNG 16장 다시 찍기(명령 1줄 · 열지 않음) + 채팅 글 ①~⑤ 전체판** — 그 밖의 lib(`labels.dart` · `ui_shell.dart` · 셸 파일)·테스트·`s01_*`·`h02_*` PNG 0 · PR 본문·라벨 0(통합 담당이 PR 본문을 이 글로 통째로 바꾼다). 같은 브랜치 · 같은 PR #74(새 PR·새 브랜치 금지) · 커밋은 맨 위에 1개.
> 판정 근거 = C4 보고 §0(설계 저장소 `10_리뷰/2026-10-27_R13b_C4_보고.md`) — 1회차 카드 strict 나눔(카드 148행 · ② 코드·테스트 결함과 거짓 주장 = 반려 · ③ 예고 변이 통과 = 반려). [가] ② 테스트 **C4h-1** 골든 높이 1120 → 1300(발주자 확정 ⑫ · 카드 416·435행 · 12 §3 «높이는 늘리지 않는다» · 여백만 줄여도 맨 아래 dy 최대 1104) · **C4h-2** (6) 커밋이 사전검사 T1 을 지우려고 if 를 단언 안으로 감춤(T01-12 `data.isEmpty ||` · 늘 참 else 둘 · 카드 464행 정면) · **C4h-3** 흐름 꼴(탭·링크 단언이 if 안 · bool 칸 + if · `opened[0]`·`[1]` 원소 비교 — R13a C4s-3 재발) · **C4h-4** 이름 비교 15줄(R13a C4s-7 재발) · 경미 **C4h-5~8**(골든 `steps` 칸 삭제 · lib nullable `!` 5 · 주입 절 자리 · `homeAllowed` 에 링크 문자열). [나] 표기 C4h-9~15 = 아래 «■ 보고 글» 조각으로 고친다 · C4h-16(커밋 (6)(7) 이 «(4) 뒤 커밋 0(예외 = (5))» 밖)은 고치지 않는다(병합 때 C4 정정). 카드·도구 구멍 C4h-17~21 = 반려 사유 아님 · 이번에 넣지 않는다(다음 카드). ③ 예고 변이 통과 0(64/64 KILLED) · 거짓 주장 0 · 합친 트리(`main` `4206274` = 밑동) 깨짐 0.
> 🔴 **재제출 조문(12 §3) = 전체판 + 바뀔 자리만 상자** — Bob 은 보고 글 ①~⑤ 를 처음부터 끝까지 다시 낸다. 글자는 이 패킷 «■ 보고 글» 의 조각 1~21 뿐이다 — [상자] = 복사 상자 글자 그대로(바뀌지 않는 자리 = 1회차 Bob 글자를 기계로 옮긴 상자 · 바뀌는 자리 = C4 가 준 상자) · [출력] = 다시 돌린 명령 출력을 그대로 · [틀] = <…> 자리에만 출력. 상자·출력 밖의 글 0.
> 🔴 **PNG 열람 0**(Bob 사정 — 한 대화 이미지 20장 한도 · 대화 길이 한도) — 이 재제출은 PNG 16장을 다시 찍지만 한 장도 열지 않는다. C4 가 같은 상자로 다시 찍은 16장(390×1120 · dy 952.0 · 1020.0 · 1000.0 · 972.0 · 1020.0 · 952.0 · 980.0 · 1104.0 · light = dark)의 띠 모양(높이·x 범위·폭)이 1회차 PNG 16장과 16/16 같다(세로 위치만 당겨짐 · `bands.py` 기계 대조) → 골든 표 16행 = C4 상자(조각 17) · Bob 이 다시 찍은 PNG 는 `git hash-object` 16줄로 C4 판과 대조한다(같으면 dy·크기도 같다 · 다르면 PNG 를 열지 않는 «크기·dy 확인» 두 가지). 사전검사 ② 의 🟡 16(G1)도 PNG 를 열지 않고 그대로 둔다. 본문도 짧은 상자·명령·기대 출력으로만 썼다.
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기를 돌린다. Bob 의 푸시가 CI 를 다시 돌린다. `golden:approved` 는 붙이지 않는다(위 ① — `h01_*` 16장은 PR 기준 A · 기존 PNG(`s01_*` · `h02_*`) M 0).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R13b-Bob-H01.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R13b 행·재제출 행 · `rounds.md` R13b 행·재제출 행과 **같은 푸시**로 `main` 에 올린다(0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/H01_questions.md`(답은 병합 때) · golden README · `packages/ui_shell/README.md` · 01~05 사본은 건드리지 않는다.
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R13b-Bob-H01.md` 는 `send/` 에 없음). 확인 = `git cat-file -t origin/main:docs/ai-context/send/R13b-Bob-H01-재제출.md`(= `blob`) · PR #74 «Conversation» 에 C4 반려 댓글(«C4 판정 — R13b-Bob-H01 1회차(`81d9ace`): 반려 → 재제출»)이 있다(게시됨 · issuecomment-6433496842) · 그 밖의 선행(infra PR 등)은 없다 · 엔진 E8a PR #73 은 이 카드 병합 뒤(발주자 결정 ② — 먼저 병합되면 0단계 계약 줄에서 Bob 이 멈춘다).
> C4 수정안 시험(2026-10-27 · 통합 담당 분리 worktree `C:/Work/AAQ-claude-r13bj` @ `81d9ace` · 임시 커밋 `24d8984`(어느 가지에도 없음) · 끝에 삭제): 상자 1~47 과 같은 글자(`judge/fix.diff` · lib 2 + test 3 + 질문 1 · +433/−215)를 넣고 `flutter test --update-goldens test/golden/h01_golden_test.dart` 로 PNG 16 을 다시 찍은 뒤 `flutter test` 파일별 «+35» · «+16» · 전체 «00:08 +117: All tests passed!» · `flutter analyze --fatal-infos` No issues found! · `dart format` 0 changed · 기존 `s01_*`·`h02_*` PNG 불변 · 변이 재실행 = 카드 예고 64꼴 KILLED 64 · 참고 24꼴 KILLED 19(통과 5 = 1회차와 같은 카드 구멍 C4h-17~19) · 종합 탐침 3꼴 KILLED 3(1회차 판은 통과 1 · 골든만 1 · T01-12 못 봄 1) · 약해진 꼴 0 · 사전검사 ① 🔴 0 · 🟡 0 · 재제출 글 미리보기의 사전검사 ② 🔴 0 · 🟡 16(전부 [G1]) · 엔진 E8a(`origin/m2/contract-v1.14`)와 임시로 합친 시험 = 충돌 0 · ui_shell +117 · `domain_contracts` +392 ~30. 안 돌린 것 = `melos.bat run test`(중첩 melos · CI 몫).
> 조립 확인(2026-10-27 · Claude): 아래 상자 1~47 을 이 파일에서 다시 읽어 `81d9ace` 판에 상자대로(번호 차례 = 파일마다 아래쪽부터) 적용한 결과 = C4 수정안(`judge/fix.diff` · 임시 커밋 `24d8984`) 6파일과 **바이트 같음**(파이썬 · blob `e9bb4df` · `3c831ef` · `35c3fe9` · `2abe8f9` · `807cd1e` · `a49d3f3` · 글자 바꾸기로 번호 차례 적용해도 같음) · 상자 47개 = C4 `judge/resubmit_boxes.md` 47개와 «찾을 글자 → 바꿀 글자» 같은 글자(81d9ace 줄 번호 · 파일 끝 줄바꿈 표지만 뺌 — 상자 17 · 47) · «이 줄을» 묶음 47개는 각 파일에 한 곳뿐(`81d9ace` 판에서도 · 번호 차례로 앞 상자를 고친 판에서도 — 상자 17 → 18 을 뒤집으면 17 이 두 곳이 된다 · 본문 🔴 줄) · 그 판(= `24d8984`)을 임시 worktree(`C:/Work/AAQ-claude-r13bx` · 확인 뒤 삭제 · 프로세스 0)에서 잰 것 = `dart format` «Formatted 5 files (0 changed)» · 정적 31줄 출력 = C4 수정안 출력 `judge/fix_static.txt` 와 같음(179줄) · 자기 점검 grep 12줄 = 기대와 같음(81d9ace 판 값도 실측) · PNG 머리 16장 = 390x1120 · PNG blob 16 = `git ls-tree 24d8984` = scratchpad `judge/png_fix/` · «크기·dy 확인» 의 PowerShell 줄(크기 한 줄 · ReadAllText/WriteAllText 되돌림 = 해시 `2abe8f9` 그대로 · Select-String 16줄) · 질문 파일 «+|» 추출 줄(9줄) 실제로 돌려 봄 · 사전검사 ① 🔴 0 · 🟡 0 · 아래 조각 1~21 을 기대 출력으로 이어 붙인 판의 사전검사 ② = 🔴 0 · 🟡 16(전부 [G1] «골든 표 ↔ PNG 셈» — 멈춤 아님 · C4 미리보기 `judge/resubmit_preview.md` 와 같은 수). 안 돌린 것 = `flutter test`(C4 시험 값 그대로 인용 · 임시 worktree 는 bootstrap 하지 않음).

## 0. 한 줄 목적

PR #74 의 파일 여섯을 상자 1~47 글자대로 고치고, `h01_*` PNG 16장을 명령 한 줄로 다시 찍어 커밋 1개로 올리고, 보고 글 ①~⑤ 를 **전체판**(바뀔 자리만 새 상자 · 나머지는 1회차 글자 상자)으로 다시 내기 — **다른 PNG·라벨·배럴·셸 파일은 한 글자도 바꾸지 않고, PNG 는 한 장도 열지 않고, 지난 7개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m8-h01-home` · 같은 PR #74 · 🔴 **새 대화**.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). PR #74 의 C4 반려 댓글은 이미 올라가 있습니다(issuecomment-6433496842).
2. Bob 은 **새 대화(new task)** 로 시작합니다 — 1회차 대화는 이어 쓰지 않습니다(이미지 20장·대화 길이 한도 · 멈춘 대화는 강제 중지). 본문은 Bob 이 1회차를 기억하지 못한다는 전제로 썼고, 1회차 글자는 이 패킷의 복사 상자에 다 들어 있어 1회차 글이나 원 카드·프롬프트를 따로 붙여 줄 필요가 없습니다. Bob 폴더는 지금 `ui/m8-h01-home` `81d9ace` 입니다(2026-10-27 Claude 확인 — `git worktree list` · 0단계가 다시 본다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R13b-Bob-H01-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r13rec\docs\ai-context\send\R13b-Bob-H01-재제출.md` · 가지 `rec/r13` · 2026-10-27 Claude 작성 · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R13b-Bob-H01.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ```text 다음 줄(«R13b-Bob-H01 재제출 요청»)부터 닫는 ``` 직전 줄까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R13b 패킷은 **이것 하나**(`R13b-Bob-H01-재제출.md`)입니다. 원 패킷 `R13b-Bob-H01.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R13a-Bob-S01H02-재제출.md` · `_완료/R4b-Bob-H62H63-재제출.md` 는 끝난 카드입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R13b-Bob-H01 재제출 요청»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R13b-Bob-H01 재제출 요청 — 1회차(PR #74 · 81d9ace) 판정: 반려(재제출). 같은 브랜치 ui/m8-h01-home · 같은 PR #74 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 파일 여섯(packages/ui_shell 의 lib 2 · test 3 + docs/ai-context/inbox/H01_questions.md — 아래 상자 1~47 글자 그대로 · 합 433줄 더하기 · 215줄 빼기) ·
  h01_* PNG 16장 다시 찍기(명령 한 줄 · 열지 않는다) · 채팅 보고 글 ①~⑤ 전체판(아래 «■ 보고 글» 의 조각 1~21 그대로)뿐입니다.
🔴 위 여섯 파일과 h01_* PNG 16장 밖 0 · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.
🔴 PNG 를 한 장도 열지 않습니다(이미지 0장) — 다시 찍은 PNG 는 git 해시로만 확인하고, 골든 표는 통합 담당이 맞춘 상자로 줍니다.
🔴 다른 카드·문서·프롬프트를 읽지 않습니다 — 1회차 카드의 규칙 중 이번에 필요한 것은 이 글에 다 옮겼습니다. 이 글과 1회차 카드가 다르면 이 글이 이깁니다.

■ 0단계 — 대상 확인 (새 대화이므로 아무것도 읽기 전에 이것부터)
이 글은 R13b 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-s01-shell)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #74 · 브랜치 ui/m8-h01-home(커밋 81d9ace)에 아래 상자 1~47 + PNG 16 커밋 하나를 «더하는» 일입니다. 상자 1~47 은 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돕니다.
🔴 1회차 카드의 «마지막 커밋 = format · 질문 파일» · «(4) 뒤 커밋 0(예외 = 사전검사 수정 커밋 (5))» 은 이번에 이 글이 덮습니다 — 재제출 커밋 (8) 1개(제목 = 아래 «커밋 제목» 상자)를 맨 위에 더하는 것이 이번 일입니다.
   지난 7개 커밋(81d9ace · 4513041 · c1a38ae · 78869ea · a794443 · c347846 · d6dc617 — 순서·제목 포함 · (6)(7) 이 (5) 뒤에 들어간 것도 그대로 — 통합 담당이 병합 때 PR 본문에 적는다)은 그대로 둡니다(고치려 하면 반려).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m8-h01-home 이 아니면(status 가 빈 것을 본 뒤) git checkout ui/m8-h01-home
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git rev-parse --short HEAD    ← 81d9ace 이면 정상 · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m8-h01-home   ← 81d9ace · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R13b-Bob-H01-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R13b-Bob-H01.md 줄이 없으면 = 이 글이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _대기 · _완료 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R13b-Bob-H01-» 로 시작하는 줄이 있으면 정상.
        «R13b-Bob-H01-재제출» 줄이 없거나 꼬리 없는 «R13b-Bob-H01.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 이 글이 먼저 왔습니다.
  git grep -c "contractVersion = '1.13.0'" origin/main -- packages/domain_contracts/lib/src/contract_version.dart
     ← «origin/main:packages/domain_contracts/lib/src/contract_version.dart:1» 이면 정상(main 계약 1.13.0 — 이 재제출의 전제 · 엔진 계약 1.14.0 은 이 카드 병합 뒤) ·
        출력이 없으면 멈추고 채팅으로(main 의 계약이 먼저 바뀌었다 — 통합 담당이 기대 수를 다시 정한다)
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
이 브랜치에 있는 docs/ai-context/send/R13b-Bob-H01.md(1회차 카드 — main 에서는 send/_완료/R13b-Bob-H01.md 로 옮겨졌다 · 머리 첫 줄의 반려 표기 말고는 글자가 같다)와
  docs/ai-context/prompt_M8.md 는 열지 않습니다(대화 길이 한도 — 규칙을 다시 읽을 필요는 없고, 이번에 필요한 글자는 이 글에 다 있다).

■ 규칙 요약 (이번에 필요한 것만 — 바탕 = 1회차 카드 규칙 요약(92~155행) · 테스트 최소 목록(289~370행) · 골든(415~436행) · ■ 제출(447~539행) · 다르면 이 글이 이긴다)
· 이번에 고치는 곳 = 아래 여섯 파일뿐입니다(앞 다섯 = packages/ui_shell/ 안 · 여섯째 = packages/ui_shell 에서 본 경로).
    lib/src/ops_home.dart                          (상자 1~16 — 블록 세로 여백 12 → 4 아홉 곳 · 행 여백 4 → 0 두 곳 · nullable 의 ! 다섯 → 지역 변수)
    lib/src/shell_providers.dart                   (상자 17·18 — R13b 주입 절을 파일 끝으로(그 뒤에 있던 두 절을 앞으로) · 더하기만 그대로)
    test/shell_fakes.dart                          (상자 19 — homeAllowed 의 링크 줄 하나 지우기)
    test/golden/h01_golden_test.dart               (상자 20~31 — 높이 1120 · 흐름 칸 steps 되살리기 · await flow.steps(tester);)
    test/ops_home_test.dart                        (상자 32~46 — T01-02·03·04·08·10·12 의 경우 칸 · 흐름 클로저 · 견본 그대로)
    ../../docs/ai-context/inbox/H01_questions.md   (상자 47 — A1~A9 행 = 새 dy · A9 = 여백 축소 «측정:» 행)
  + PNG 16장 = test/golden/goldens/h01_*.png — 손으로 고치지 않고 아래 «■ PNG 다시 찍기» 명령 한 줄로만 바꾼다(열지 않는다).
· 🔴 고치면 반려: 위 여섯 파일과 h01_* PNG 16장 밖의 전부 — lib/ 의 다른 파일(lib/l10n/labels.dart · lib/ui_shell.dart · shell_scaffold.dart · ops_rhythm.dart · routing/ · common/) ·
  test/golden/goldens/ 의 s01_*·h02_* PNG · test/ 의 다른 파일(s01·h02 골든 테스트 · ops_rhythm·shell_router·shell_scaffold 테스트 · flutter_test_config.dart · golden/golden_support.dart ·
  golden/shift_tolerant_compare.dart · golden/README.md · ui_shell_test.dart) · domain_contracts/** · apps/** · 다른 ui_* · pubspec.yaml · analysis_options.yaml · docs/ai-context/** 의 다른 파일.
  🔴 그 밖의 파일이 하나라도 M(또는 ??)이면 git checkout -- <그 파일>(?? 는 지운다) 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 이번에 걸린 1회차 카드 글자(글자 그대로 · 인용 안의 연속 공백은 하나로 줄임 — 상자가 이것을 맞춘다):
   416행 «… 크기 = 테스트 파일 안 const Size _kTallPhone = Size(390, 1120) …» · 발주자 확정 ⑫ «_kTallPhone = Size(390, 1120)» · 12 §3 공통 조문 «높이는 늘리지 않는다» ·
   435행 «골든 높이 = 재량 + 기록(12 §3 공통 조문) — 화면 여백을 줄여 맞추는 것은 허용 · 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.»
     → 🔴 높이는 1120 그대로다. 상자의 여백 축소(블록 12 → 4 · 행 4 → 0)가 C4 가 잰 길이고, 그 «측정:» 행이 상자 47 의 A9 다.
   464행 «… 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) …» · 122행 «… 늘 참인 단언 금지 …» · 352행 «T01-12 … R13a «화면의 Text 전부» 견본 그대로 →»
   292행 «… 경우의 흐름 = 클로저 칸 …» · 330행 «(🔵 흐름 = 클로저 칸 · bool 칸 + if 0)» · 321행 «… halted 흐름 = tap(h01-blocked) → opener.opened == <String>[AppRoutes.m5BlockBoard] · tap(h01-status) → 두 번째 원소도 m5BlockBoard · ⓡ.»
   133행 «final String? want = c.resumeLabel; // 경우 칸 = 기대 글자 String? …» · 348행 «공장 = (int call) => call == 0 ? Stream<T>.error(StateError('fail')) : one(v) → … 그 가짜 calls == 2 · ⓡ.»
   426행 «… 흐름 = 전부 없음 — (WidgetTester t) async {} …» · 428행 «… → await tester.pump(); → await flow.steps(tester); →» · 310행 «homeAllowed(…)(= 그 입력의 표시 글자 전부 + R13b 라벨 6 + ShellLabels.staleBannerTitle · null-aware 원소)»
   195행 «… lib 의 nullable 에 !(null 검사 뒤 지역 변수로 …)» · 96행 «lib/src/shell_providers.dart = 파일 끝에 R13b 절(주입 5) …» · 409행 «H13 = 14줄(… 끝 5줄 = 위 «주입 구조» 차례 …)»
   ⓡ = expect(find.text(ShellLabels.retry), findsNothing); 줄 · ⓗ = hasLength( 줄 · 전제 = 끝이 // pre 인 줄 — 정적 H18·H19·H31 이 정확히 11 · 3 · 17 이어야 한다(상자 1~47 은 이 셋의 수를 바꾸지 않는다) ·
   testWidgets·test 줄 수도 그대로(H03 = h01_golden_test 1 · ops_home_test 12) · 테스트 이름·경우 이름·경우 수 그대로(+35 · +16) · 테스트에 한국어 리터럴 0 · if 를 새로 쓰지 않는다 · 새 가짜·새 도우미 파일 0.
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
  🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 · 패키지 테스트는 packages/ui_shell 에서 flutter test 직접.
· 보고 규칙(1회차 카드 148행 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당(C4)이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음) · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 섹션 머리 ①~⑤ 는 «■ 보고 글» 상자 글자 그대로).
  🔴 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 «모든 확인 완료 …» 같은 섹션 밖 글이나 --- 를 두지 않는다(1회차 카드 477행 N1).
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 글이 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.
   🔴 git log · git diff · flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
      <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채).
   🔴 $env:TEMP 에 쓸 수 없으면 저장소 뿌리의 build\<이름>.txt 에 쓴다(루트 .gitignore 의 build/ 대상 — git status 는 빈 채 · 커밋하지 않는다 · 이 글의 $env:TEMP\… 자리를 모두 build\… 로 읽는다).

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다(아래 C4h-6 · C4h-7 두 곳과 여백 밖) — 구독 6 · 블록 순서(머리 → 1 → 2 → 3 → 3b → 4 → 5 → 6 → 7 → 8 → 9b) · 상태 표(today 에러 = 홈 전체 · 1·4·6 = 그 자리 재시도 · 3·3b·9b = 부재 · 값 뒤 에러 = 마지막 값) ·
  링크 10자리(전부 탭 콜백 안) · switch 셋 · 규칙 5 식 6줄 · 공용 4파일 더하기만 · Key 21이름 · 라벨 6 · 배럴 export 한 줄.
테스트는 C4h-2~5 · 8 의 자리 말고 모두 맞았습니다 — 가짜 받침대 · 공장 = call 삼항 · ⓡ 11 · ⓗ 3 · // pre 17 · T01-01 «full» · T01-09 9경우 · T01-11 paused → inactive → resumed · 픽스처 = main() 머리 final · copyWith 3.
골든 16장은 배치 결함 0 · 잘림 0 · light = dark 기하 · 칸 아이콘 5 · 9b 는 h01_self_audit_due 만 — 높이만 카드 값(1120)이 아니었습니다 · flutter test 66 → 117 · analyze 0 · format 0 · domain_contracts +389 ~30 · 경계 실패 0 · CI 3/3.
보고에서 맞은 곳 — 거짓 주장 0 · name-status 24줄 · 커밋 7 · 10항 10줄·괄호 · 10항 줄 수 · 정적 31줄 출력(C4 재실행과 바이트 같음) · dy 16값 · 끝 줄.

■ 왜 반려인가 — 카드 / 실제 (C4 가 코드·변이·수정안 시험으로 직접 확인 · 전부 strict 나눔 ② · 재량 없이 반려)
① C4h-1 골든 높이를 1300 으로 늘렸다 (테스트 결함)
   카드:  416행 Size(390, 1120) · 발주자 확정 ⑫ · 435행 «여백을 줄여 맞추는 것은 허용 … 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에» · 12 §3 «높이는 늘리지 않는다».
   실제:  h01_golden_test.dart 16행 Size(390, 1300) · PNG 16장 390×1300 · 질문 A9 «… 1120 이었으나 max dy=1256.0 초과 → 1300 으로 변경». 여백만 줄여도 맨 아래 dy 최대 1104(C4 실측) — 허용된 길이 있었다.
   고침:  상자 1~5 · 7 · 9 · 12 · 14~16(블록 여백 12 → 4 · 행 여백 4 → 0) · 31(1120) · 47(A1~A9) + PNG 다시 찍기.
② C4h-2 (6) 커밋이 사전검사 T1 을 지우려고 if 를 단언 안으로 감췄다 (테스트 결함 · 가장 무거움)
   카드:  464행 «고친다(테스트만 · if 를 다른 꼴로 감추지 않는다)» · 352행 «R13a «화면의 Text 전부» 견본 그대로» · 122행 «늘 참인 단언 금지».
   실제:  T01-12 «expect(data.isEmpty || allowed.contains(data), isTrue …)»(빈 글자 Text 를 보지 않게 됨) · T01-04 · T01-08 에 «else { expect(opener.opened, isEmpty …) }»(아무것도 누르지 않은 갈래 — 늘 참).
   고침:  상자 32(견본 그대로 — expect(data, isIn(allowed), reason: name);) · 36 · 39(덧붙인 else 대신 흐름 클로저 + 경우 공통 expect(opener.opened, opened, …)).
③ C4h-3 흐름이 if 갈래 안에 있다 (테스트 결함 · R13a C4s-3 과 같은 꼴)
   카드:  292행 «경우의 흐름 = 클로저 칸» · 330행 «bool 칸 + if 0» · 321행 «opener.opened == <String>[AppRoutes.m5BlockBoard]».
   실제:  T01-02 · 03 · 04 의 탭·링크 단언이 if (want != null) 안 · T01-08 = bool 칸 wantCard + if · T01-03 = opened[0]·[1] 원소 비교(탭 한 번에 링크를 두 번 여는 꼴을 못 봄 — C4 탐침 통과).
   고침:  상자 36~46(경우 레코드에 steps(클로저) · opened(기대 목록) 칸 · 본문 = «없는 쪽» 견본 → await steps(tester); → expect(opener.opened, opened);).
④ C4h-4 경우 자료를 이름 비교로 고른다 (테스트 결함 · 경미 · R13a C4s-7 과 같은 꼴)
   카드:  133행 견본 «final String? want = c.resumeLabel; // 경우 칸» · 318·320행 «(경우 · 입력 · want = …)» · 348행 «공장 = (int call) => call == 0 ? … : one(v) … 그 가짜 calls == 2».
   실제:  name == · which == 15줄(T01-02 · 03 · 04 · 08 · 10 · 12) — 자료·today 입력·공장·calls 를 이름으로 고름.
   고침:  상자 33~35 · 38 · 40 · 41 · 43 · 44 · 46(경우 칸 = want · today · 공장 넷 · failIndex · 입력 칸).
⑤ 경미 넷 (실효 0 또는 작음 · 카드가 글자로 정한 자리)
   C4h-5 골든 흐름 칸 steps 를 린트 때문에 지움(426~428행) → 상자 20~30(required 칸 + 이름마다 (WidgetTester t) async {} · await flow.steps(tester);)
   C4h-6 lib nullable 의 ! 다섯 곳(195행) → 상자 6 · 7 · 8 · 10 · 11 · 13(지역 변수 dueSoon · notice · empty · band · note)
   C4h-7 주입 절이 파일 끝이 아님(96 · 201 · 409행) → 상자 17 · 18(H13 끝 5줄 = R13b 주입 5줄 · 더하기만 37/0 그대로)
   C4h-8 homeAllowed 에 링크 문자열 ?trust.actionDeepLink(310행 «표시 글자 전부») → 상자 19(그 줄 삭제 · H26 shell_fakes 219 → 218)
카드·도구 구멍(반려 사유 아님) — C4h-17~21(참고 변이 5꼴 · 카드 골든 절 문구 · 사전검사 R4)은 이번에 넣지 않는다(다음 카드 · 다음 도구).
함께 고칠 것 — 표기 C4h-9~15 = 아래 «■ 보고 글» 조각(② 꼬리 = 조각 12·13·14·15·21 · ③ 서술 3줄 = 조각 16 · 골든 표 5열 16행 = 조각 17 · ④ diff «+|» 9줄 = 조각 19 · ⑤ «없음» = 조각 20 ·
  사전검사 ② 를 돌려 🔴 0 을 본 뒤 낸다 = «■ 내기 전 자기 확인»). C4h-16(커밋 (6)(7))은 고치지 않는다(통합 담당이 병합 때 PR 본문에 적는다).
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 생성물은 git 에 없습니다(새 대화·브랜치를 바꿨으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류 · 생성물은 git 이 무시하므로 git status 는 빈 채).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_shell
  flutter test   ← 시작 기준: 끝 줄 «+117: All tests passed!» · 0 실패(1회차 그대로 · 앞 시각은 달라도 된다). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  (cd ../.. 하지 않고 packages/ui_shell 에 머문다 — 아래 상자의 경로·«고친 뒤 확인»·«■ PNG 다시 찍기» 는 이 폴더 기준이다 · 질문 파일만 ../../docs/ai-context/inbox/H01_questions.md)

■ 고칠 것 — 상자 1~47 (1회차 반려 · C4 2026-10-27) — 상자 글자 그대로 · 손으로 다시 짜지 않는다
   🔴 행 번호는 81d9ace 의 것이다. 상자는 **번호 차례(1 → 47)** 로 고친다 — 번호가 파일마다 행 번호가 큰 상자부터(파일 아래쪽부터 위로) 매겨져 있어, 앞의 수정이 뒤 상자의 행 번호를 밀지 않는다.
      파일별 차례: lib/src/ops_home.dart = 상자 1 → 16 · lib/src/shell_providers.dart = 17 → 18 · test/shell_fakes.dart = 19 · test/golden/h01_golden_test.dart = 20 → 31 ·
                   test/ops_home_test.dart = 32 → 46 · ../../docs/ai-context/inbox/H01_questions.md = 47
   🔴 «이 줄을» 상자와 파일의 그 행들이 한 글자라도 다르면(들여쓰기 포함) 고쳐 쓰지 말고 멈춘 뒤 채팅으로 — 파일이 81d9ace 가 아니다. «이 줄을» 묶음 47개는 각 파일에 한 곳뿐이다(번호 차례로 고칠 때).
   🔴 상자 17 → 18 차례는 꼭 지킨다 — 18 을 먼저 하면 18 이 넣은 25줄 때문에 17 의 «이 줄을» 묶음이 파일에 두 곳이 된다(그렇게 보이면 멈춘 뒤 채팅으로).
   🔴 같은 글자 줄이 여러 상자에 나온다(블록 여백 «vertical: 12» 아홉 곳 · 골든 «steps: (WidgetTester t) async {},» 여덟 곳) — 상자마다 «이 줄을» 묶음 전체로 자리를 찾아 그 자리만 고친다(한 줄만 보고 찾지 않는다).
   🔴 상자 안의 들여쓰기(빈칸 수)를 그대로 옮긴다 · 탭 문자 0 · 줄 끝 빈칸 0 · 상자 밖의 줄은 한 글자도 바꾸지 않는다(빈 줄 포함) · 상자 머리·끝 줄(┌── · └──)은 파일에 넣지 않는다 ·
      상자 안 줄 머리의 빈칸은 파일의 들여쓰기 그대로다(상자 머리 ┌── 의 들여쓰기와 무관 — 떼어 내지 않는다) · 상자 첫 줄·끝 줄이 빈 줄이면 그 빈 줄도 상자 글자다(상자 머리에 적었다) ·
      «이 줄로(0줄)» = 그 묶음을 지운다(상자 17 하나 — 파일 끝 25줄 · 지운 뒤 파일의 마지막 줄 = 상자 17 머리에 적은 줄 · 그 줄 뒤 줄바꿈 하나는 그대로) · PNG 는 상자로 고치지 않는다.

상자 1 (C4h-1 · lib/src/ops_home.dart — _UpcomingRow 행 여백 · 3줄 → 3줄)
   (바뀐 뜻: 예정 행 Padding vertical 4 → 0)
      ┌── 이 줄을(lib/src/ops_home.dart 527~529행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
      └──
      ┌── 이 줄로(3줄)
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
      └──

상자 2 (C4h-1 · lib/src/ops_home.dart — 블록 8 h01-upcoming 여백 · 3줄 → 3줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 492~494행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      key: const Key('h01-upcoming'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
      └──
      ┌── 이 줄로(3줄)
      key: const Key('h01-upcoming'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
      └──

상자 3 (C4h-1 · lib/src/ops_home.dart — 블록 7 h01-today 여백 · 3줄 → 3줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 467~469행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
      └──
      ┌── 이 줄로(3줄)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Wrap(
      └──

상자 4 (C4h-1 · lib/src/ops_home.dart — 블록 6 h01-recon 여백 · 7줄 → 7줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 411~417행 · 7줄 · 이 7줄 묶음은 파일에 한 곳뿐)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.ledgerDiffs);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      └──
      ┌── 이 줄로(7줄)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.ledgerDiffs);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      └──

상자 5 (C4h-1 · lib/src/ops_home.dart — 블록 5 h01-process 여백 · 3줄 → 3줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 385~387행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      key: const Key('h01-process'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
      └──
      ┌── 이 줄로(3줄)
      key: const Key('h01-process'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
      └──

상자 6 (C4h-6 · lib/src/ops_home.dart — _AllocRow 의 ! 둘 · 4줄 → 4줄)
   (바뀐 뜻: Text(row.bandStateLabel!) · Text(row.bandNoteText!) → 지역 변수 band · note)
      ┌── 이 줄을(lib/src/ops_home.dart 358~361행 · 4줄 · 이 4줄 묶음은 파일에 한 곳뿐)
          if (w != null) Text(w.label),
          if (row.bandStateLabel != null) Text(row.bandStateLabel!),
          if (row.bandNoteText != null) Text(row.bandNoteText!),
          Row(
      └──
      ┌── 이 줄로(4줄)
          if (w != null) Text(w.label),
          if (band != null) Text(band),
          if (note != null) Text(note),
          Row(
      └──

상자 7 (C4h-6 · C4h-1 · lib/src/ops_home.dart — _AllocRow 지역 변수 · 행 여백 · 5줄 → 7줄)
   (바뀐 뜻: final String? band · note 두 줄 + 행 Padding vertical 4 → 0)
      ┌── 이 줄을(lib/src/ops_home.dart 350~354행 · 5줄 · 이 5줄 묶음은 파일에 한 곳뿐)
    final SleeveWeight? w = row.sleeveWeight;
    return Padding(
      key: ValueKey<String>('h01-sleeve-$index'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
      └──
      ┌── 이 줄로(7줄)
    final SleeveWeight? w = row.sleeveWeight;
    final String? band = row.bandStateLabel;
    final String? note = row.bandNoteText;
    return Padding(
      key: ValueKey<String>('h01-sleeve-$index'),
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
      └──

상자 8 (C4h-6 · lib/src/ops_home.dart — 블록 4 의 ! 둘 · 4줄 → 4줄)
   (바뀐 뜻: Text(vm.noticeText!) · Text(vm.emptyLabel!) → 지역 변수 notice · empty)
      ┌── 이 줄을(lib/src/ops_home.dart 332~335행 · 4줄 · 이 4줄 묶음은 파일에 한 곳뿐)
              _AllocRow(index: i, row: row),
            if (vm.noticeText != null) Text(vm.noticeText!),
            if (vm.emptyLabel != null) Text(vm.emptyLabel!),
          ],
      └──
      ┌── 이 줄로(4줄)
              _AllocRow(index: i, row: row),
            if (notice != null) Text(notice),
            if (empty != null) Text(empty),
          ],
      └──

상자 9 (C4h-1 · lib/src/ops_home.dart — 블록 4 h01-alloc 여백 · 7줄 → 7줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 324~330행 · 7줄 · 이 7줄 묶음은 파일에 한 곳뿐)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.holdingsAllocation);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      └──
      ┌── 이 줄로(7줄)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.holdingsAllocation);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      └──

상자 10 (C4h-6 · lib/src/ops_home.dart — 블록 4 지역 변수 · 2줄 → 4줄)
   (바뀐 뜻: final String? notice · empty 두 줄)
      ┌── 이 줄을(lib/src/ops_home.dart 320~321행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐)
        .toList();
    return InkWell(
      └──
      ┌── 이 줄로(4줄)
        .toList();
    final String? notice = vm.noticeText;
    final String? empty = vm.emptyLabel;
    return InkWell(
      └──

상자 11 (C4h-6 · lib/src/ops_home.dart — 블록 3b 의 ! · 3줄 → 3줄)
   (바뀐 뜻: Text(s.dueSoonLabel!) → 지역 변수 dueSoon)
      ┌── 이 줄을(lib/src/ops_home.dart 298~300행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
            if (!s.hasSuppressedNotice) ...<Widget>[
              if (s.dueSoonLabel != null) Text(s.dueSoonLabel!),
              Text(s.trust.label),
      └──
      ┌── 이 줄로(3줄)
            if (!s.hasSuppressedNotice) ...<Widget>[
              if (dueSoon != null) Text(dueSoon),
              Text(s.trust.label),
      └──

상자 12 (C4h-1 · lib/src/ops_home.dart — 블록 3b h01-advice 여백 · 7줄 → 7줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 290~296행 · 7줄 · 이 7줄 묶음은 파일에 한 곳뿐)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.adviceInbox);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      └──
      ┌── 이 줄로(7줄)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.adviceInbox);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
      └──

상자 13 (C4h-6 · lib/src/ops_home.dart — 블록 3b 지역 변수 · 2줄 → 3줄)
   (바뀐 뜻: final String? dueSoon 한 줄)
      ┌── 이 줄을(lib/src/ops_home.dart 283~284행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐)
    final AdviceInboxSummary s = summary;
    if (s.openCount == 0 && !s.hasSuppressedNotice) {
      └──
      ┌── 이 줄로(3줄)
    final AdviceInboxSummary s = summary;
    final String? dueSoon = s.dueSoonLabel;
    if (s.openCount == 0 && !s.hasSuppressedNotice) {
      └──

상자 14 (C4h-1 · lib/src/ops_home.dart — 블록 3 h01-blocked 여백 · 7줄 → 7줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 261~267행 · 7줄 · 이 7줄 묶음은 파일에 한 곳뿐)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.m5BlockBoard);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[for (final BlockFlag f in blocking) Text(f.label)],
      └──
      ┌── 이 줄로(7줄)
        ref.read(shellLinkOpenerProvider).open(AppRoutes.m5BlockBoard);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[for (final BlockFlag f in blocking) Text(f.label)],
      └──

상자 15 (C4h-1 · lib/src/ops_home.dart — 블록 2 h01-resume 여백 · 3줄 → 3줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 235~237행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(line.label),
      └──
      ┌── 이 줄로(3줄)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(line.label),
      └──

상자 16 (C4h-1 · lib/src/ops_home.dart — 블록 1 h01-status 여백 · 3줄 → 3줄)
   (바뀐 뜻: vertical 12 → 4)
      ┌── 이 줄을(lib/src/ops_home.dart 209~211행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(safety.breakerLabel),
      └──
      ┌── 이 줄로(3줄)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(safety.breakerLabel),
      └──

상자 17 (C4h-7 · lib/src/shell_providers.dart — 파일 끝 두 절 지우기 · 25줄 → 0줄)
   (바뀐 뜻: «Data provider» · «Label helpers» 두 절(앞 빈 줄 포함 25줄)을 여기서 지운다 — 상자 18 이 R13b 절 앞에 같은 글자를 넣는다 · 지운 뒤 파일의 마지막 줄 = R13b 절의 끝 줄 «    );»)
      ┌── 이 줄을(lib/src/shell_providers.dart 122~146행 · 25줄 · 이 25줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄 · 파일 끝 묶음 — 마지막 줄 뒤에 줄이 없다)

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<FeatureFlags> shellFlagsProvider =
    StreamProvider<FeatureFlags>(
      (Ref ref) => ref.watch(shellConfigRepositoryProvider).watchFlags(),
    );

// ── Label helpers ──────────────────────────────────────────────────────────────

/// 접두·띠 칩 — 순서 고정(모의 → 안내).
List<String> shellModeLabels(FeatureFlags flags) {
  final String? run = flags.runMode.isSim ? ShellLabels.simPrefix : null;
  final String? op = switch (flags.operatingMode) {
    OperatingMode.autoTrade => null,
    OperatingMode.advisory => ShellLabels.advisoryPrefix,
  };
  return <String>[?run, ?op];
}

/// 앱바 제목 = 접두들 + 제목(없으면 접두만) — 이음 = ShellLabels.prefixSeparator.
String shellTitle(FeatureFlags? flags, String? title) => <String>[
  ...?(flags == null ? null : shellModeLabels(flags)),
  ?title,
].join(ShellLabels.prefixSeparator);
      └──
      ┌── 이 줄로(0줄 — 위 묶음을 지운다 · 이 머리 바로 아래가 끝 줄이다)
      └──

상자 18 (C4h-7 · lib/src/shell_providers.dart — R13b 절 앞에 두 절 넣기 · 2줄 → 27줄)
   (바뀐 뜻: 상자 17 에서 지운 25줄을 R13b 절 머리 주석 앞에 넣는다 → R13b 절이 파일 끝(H13 끝 5줄 = R13b 주입 5 · 더하기만 37/0 그대로))
      ┌── 이 줄을(lib/src/shell_providers.dart 85~86행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

// ── R13b — H-01 injection providers ──────────────────────────────────────────
      └──
      ┌── 이 줄로(27줄 · 첫 줄 = 빈 줄)

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<FeatureFlags> shellFlagsProvider =
    StreamProvider<FeatureFlags>(
      (Ref ref) => ref.watch(shellConfigRepositoryProvider).watchFlags(),
    );

// ── Label helpers ──────────────────────────────────────────────────────────────

/// 접두·띠 칩 — 순서 고정(모의 → 안내).
List<String> shellModeLabels(FeatureFlags flags) {
  final String? run = flags.runMode.isSim ? ShellLabels.simPrefix : null;
  final String? op = switch (flags.operatingMode) {
    OperatingMode.autoTrade => null,
    OperatingMode.advisory => ShellLabels.advisoryPrefix,
  };
  return <String>[?run, ?op];
}

/// 앱바 제목 = 접두들 + 제목(없으면 접두만) — 이음 = ShellLabels.prefixSeparator.
String shellTitle(FeatureFlags? flags, String? title) => <String>[
  ...?(flags == null ? null : shellModeLabels(flags)),
  ?title,
].join(ShellLabels.prefixSeparator);

// ── R13b — H-01 injection providers ──────────────────────────────────────────
      └──

상자 19 (C4h-8 · test/shell_fakes.dart — homeAllowed 의 링크 줄 · 3줄 → 2줄)
   (바뀐 뜻: ?trust.actionDeepLink, 한 줄을 지운다(표시 글자만 · H26 shell_fakes 219 → 218))
      ┌── 이 줄을(test/shell_fakes.dart 485~487행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
    trust.consequenceLine,
    ?trust.actionDeepLink,
    ShellLabels.homeReconTitle,
      └──
      ┌── 이 줄로(2줄)
    trust.consequenceLine,
    ShellLabels.homeReconTitle,
      └──

상자 20 (C4h-5 · test/golden/h01_golden_test.dart — 골든 본문 흐름 · 2줄 → 3줄)
   (바뀐 뜻: await tester.pump(); 뒤에 await flow.steps(tester); 한 줄(1회차 카드 428행))
      ┌── 이 줄을(test/golden/h01_golden_test.dart 216~217행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐)
        await tester.pump();
        await tester.pumpAndSettle();
      └──
      ┌── 이 줄로(3줄)
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();
      └──

상자 21 (C4h-5 · test/golden/h01_golden_test.dart — h01_self_audit_due 흐름 칸 · 2줄 → 3줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 176~177행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐)
      bottomKey: const Key('h01-audit'),
    ),
      └──
      ┌── 이 줄로(3줄)
      bottomKey: const Key('h01-audit'),
      steps: (WidgetTester t) async {},
    ),
      └──

상자 22 (C4h-5 · test/golden/h01_golden_test.dart — h01_advice_suppressed 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 164~169행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_self_audit_due',
      └──
      ┌── 이 줄로(7줄)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_self_audit_due',
      └──

상자 23 (C4h-5 · test/golden/h01_golden_test.dart — h01_advice_zero 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 154~159행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_advice_suppressed',
      └──
      ┌── 이 줄로(7줄)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_advice_suppressed',
      └──

상자 24 (C4h-5 · test/golden/h01_golden_test.dart — h01_advice_open 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 144~149행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_advice_zero',
      └──
      ┌── 이 줄로(7줄)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_advice_zero',
      └──

상자 25 (C4h-5 · test/golden/h01_golden_test.dart — h01_recon_diff 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 134~139행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: diff,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_advice_open',
      └──
      ┌── 이 줄로(7줄)
      diag: diff,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_advice_open',
      └──

상자 26 (C4h-5 · test/golden/h01_golden_test.dart — h01_resume_gap7 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 124~129행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_recon_diff',
      └──
      ┌── 이 줄로(7줄)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_recon_diff',
      └──

상자 27 (C4h-5 · test/golden/h01_golden_test.dart — h01_blocked 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 114~119행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: diff,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_resume_gap7',
      └──
      ┌── 이 줄로(7줄)
      diag: diff,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_resume_gap7',
      └──

상자 28 (C4h-5 · test/golden/h01_golden_test.dart — h01_normal 흐름 칸 · 6줄 → 7줄)
   (바뀐 뜻: steps: (WidgetTester t) async {}, 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 104~109행 · 6줄 · 이 6줄 묶음은 파일에 한 곳뿐)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
    ),
    _Flow(
      name: 'h01_blocked',
      └──
      ┌── 이 줄로(7줄)
      diag: ok,
      trust: trustDue,
      bottomKey: const Key('h01-more'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h01_blocked',
      └──

상자 29 (C4h-5 · test/golden/h01_golden_test.dart — _Flow 필드 · 2줄 → 3줄)
   (바뀐 뜻: final Future<void> Function(WidgetTester tester) steps; 한 줄)
      ┌── 이 줄을(test/golden/h01_golden_test.dart 37~38행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐)
  final Key bottomKey;
}
      └──
      ┌── 이 줄로(3줄)
  final Key bottomKey;
  final Future<void> Function(WidgetTester tester) steps;
}
      └──

상자 30 (C4h-5 · test/golden/h01_golden_test.dart — _Flow 생성자 · 2줄 → 3줄)
   (바뀐 뜻: required this.steps, 한 줄(required 라 unused_element_parameter 린트가 걸리지 않는다))
      ┌── 이 줄을(test/golden/h01_golden_test.dart 27~28행 · 2줄 · 이 2줄 묶음은 파일에 한 곳뿐)
    required this.bottomKey,
  });
      └──
      ┌── 이 줄로(3줄)
    required this.bottomKey,
    required this.steps,
  });
      └──

상자 31 (C4h-1 · test/golden/h01_golden_test.dart — 골든 크기 · 3줄 → 3줄)
   (바뀐 뜻: const Size _kTallPhone = Size(390, 1300); → Size(390, 1120);(발주자 확정 ⑫))
      ┌── 이 줄을(test/golden/h01_golden_test.dart 15~17행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄 · 끝 줄 = 빈 줄)

const Size _kTallPhone = Size(390, 1300);

      └──
      ┌── 이 줄로(3줄 · 첫 줄 = 빈 줄 · 끝 줄 = 빈 줄)

const Size _kTallPhone = Size(390, 1120);

      └──

상자 32 (C4h-2 · test/ops_home_test.dart — T01-12 본문 · 14줄 → 13줄)
   (바뀐 뜻: R13a «화면의 Text 전부» 견본 그대로 — .map((Text t) => t.data) → expect(data, isIn(allowed), reason: name); → 글꼴 2.0 → pump → takeException(data.isEmpty || 0))
      ┌── 이 줄을(test/ops_home_test.dart 1191~1204행 · 14줄 · 이 14줄 묶음은 파일에 한 곳뿐)
      );
      final List<Text> allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .toList();
      expect(allTexts, isNotEmpty, reason: name);
      for (final Text t in allTexts) {
        final String data = t.data ?? '';
        expect(
          data.isEmpty || allowed.contains(data),
          isTrue,
          reason: '$name unexpected text: $data',
        );
      }
      expect(tester.takeException(), isNull, reason: name);
      └──
      ┌── 이 줄로(13줄)
      );
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty, reason: name);
      for (final String? data in shown) {
        expect(data, isIn(allowed), reason: name);
      }
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: name);
      └──

상자 33 (C4h-4 · test/ops_home_test.dart — T01-12 경우 목록 · 47줄 → 55줄)
   (바뀐 뜻: 경우 레코드에 입력 칸(safety · today · advice)을 직접 — name == 0)
      ┌── 이 줄을(test/ops_home_test.dart 1132~1178행 · 47줄 · 이 47줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  final List<(String, Set<String>)> cases12 = <(String, Set<String>)>[
    (
      'advice_open',
      homeAllowed(
        today: adviceT,
        safety: safe0,
        advice: open,
        alloc: alloc,
        diag: ok,
        trust: trustDue,
      ),
    ),
    (
      'self_audit_due',
      homeAllowed(
        today: normal,
        safety: safe1,
        advice: none,
        alloc: alloc,
        diag: ok,
        trust: trustDue,
      ),
    ),
  ];

  for (final (String name, Set<String> allowed) in cases12) {
    testWidgets('T01-12 all texts large font\n$name', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(
            state: (int call) =>
                name == 'self_audit_due' ? one(safe1) : one(safe0),
          ),
          today: FakeShellOpsTodayRepository(
            today: (int call) =>
                name == 'advice_open' ? one(adviceT) : one(normal),
          ),
          advice: FakeShellAdviceRepository(
            summary: (int call) =>
                name == 'advice_open' ? one(open) : one(none),
          ),
      └──
      ┌── 이 줄로(55줄 · 첫 줄 = 빈 줄)

  final List<
    (String, SafetyState, OpsDailySummary, AdviceInboxSummary, Set<String>)
  >
  cases12 =
      <(String, SafetyState, OpsDailySummary, AdviceInboxSummary, Set<String>)>[
        (
          'advice_open',
          safe0,
          adviceT,
          open,
          homeAllowed(
            today: adviceT,
            safety: safe0,
            advice: open,
            alloc: alloc,
            diag: ok,
            trust: trustDue,
          ),
        ),
        (
          'self_audit_due',
          safe1,
          normal,
          none,
          homeAllowed(
            today: normal,
            safety: safe1,
            advice: none,
            alloc: alloc,
            diag: ok,
            trust: trustDue,
          ),
        ),
      ];

  for (final (
        String name,
        SafetyState safetyF,
        OpsDailySummary todayF,
        AdviceInboxSummary adviceF,
        Set<String> allowed,
      )
      in cases12) {
    testWidgets('T01-12 all texts large font\n$name', (
      WidgetTester tester,
    ) async {
      await pumpOpsHome(
        tester,
        overrides: homeOverrides(
          safety: FakeShellSafetyRepository(state: (int call) => one(safetyF)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(todayF)),
          advice: FakeShellAdviceRepository(
            summary: (int call) => one(adviceF),
          ),
      └──

상자 34 (C4h-4 · test/ops_home_test.dart — T01-10 calls · 10줄 → 9줄)
   (바뀐 뜻: expect(calls[failIndex], 2, …) — 이름 삼항 사슬 0)
      ┌── 이 줄을(test/ops_home_test.dart 1056~1065행 · 10줄 · 이 10줄 묶음은 파일에 한 곳뿐)
      expect(find.byKey(ValueKey<String>(successKey)), findsOneWidget);
      final int calls = which == 'today'
          ? todayRepo.calls
          : which == 'safety'
          ? safetyRepo.calls
          : which == 'alloc'
          ? allocRepo.calls
          : diagRepo.calls;
      expect(calls, 2, reason: '$which calls');
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──
      ┌── 이 줄로(9줄)
      expect(find.byKey(ValueKey<String>(successKey)), findsOneWidget);
      final List<int> calls = <int>[
        safetyRepo.calls,
        todayRepo.calls,
        allocRepo.calls,
        diagRepo.calls,
      ];
      expect(calls[failIndex], 2, reason: '$which calls');
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──

상자 35 (C4h-4 · test/ops_home_test.dart — T01-10 경우 목록 · 40줄 → 100줄)
   (바뀐 뜻: 경우 레코드에 공장 넷과 failIndex 칸 — 공장 = (int call) => call == 0 ? error : one(v) 를 경우 칸에 직접(which == 0))
      ┌── 이 줄을(test/ops_home_test.dart 997~1036행 · 40줄 · 이 40줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  final List<(String, String, String)> cases10 = <(String, String, String)>[
    ('today', 'h01-fail', 'h01-asof'),
    ('safety', 'h01-status-fail', 'h01-status'),
    ('alloc', 'h01-alloc-fail', 'h01-alloc'),
    ('diag', 'h01-recon-fail', 'h01-recon'),
  ];

  for (final (String which, String failKey, String successKey) in cases10) {
    testWidgets('T01-10 retry\n$which', (WidgetTester tester) async {
      final FakeShellSafetyRepository safetyRepo = FakeShellSafetyRepository(
        state: (int call) => which == 'safety'
            ? (call == 0
                  ? Stream<SafetyState>.error(StateError('fail'))
                  : one(safe0))
            : one(safe0),
      );
      final FakeShellOpsTodayRepository todayRepo = FakeShellOpsTodayRepository(
        today: (int call) => which == 'today'
            ? (call == 0
                  ? Stream<OpsDailySummary>.error(StateError('fail'))
                  : one(normal))
            : one(normal),
      );
      final FakeShellHoldingsRepository allocRepo = FakeShellHoldingsRepository(
        allocation: (int call) => which == 'alloc'
            ? (call == 0
                  ? Stream<SleeveAllocationVm>.error(StateError('fail'))
                  : one(alloc))
            : one(alloc),
      );
      final FakeShellOpsStatusRepository diagRepo =
          FakeShellOpsStatusRepository(
            diagnostics: (int call) => which == 'diag'
                ? (call == 0
                      ? Stream<DiagnosticsVm>.error(StateError('fail'))
                      : one(ok))
                : one(ok),
          );
      await pumpOpsHome(
      └──
      ┌── 이 줄로(100줄 · 첫 줄 = 빈 줄)

  final List<
    (
      String,
      Stream<SafetyState> Function(int),
      Stream<OpsDailySummary> Function(int),
      Stream<SleeveAllocationVm> Function(int),
      Stream<DiagnosticsVm> Function(int),
      String,
      String,
      int,
    )
  >
  cases10 =
      <
        (
          String,
          Stream<SafetyState> Function(int),
          Stream<OpsDailySummary> Function(int),
          Stream<SleeveAllocationVm> Function(int),
          Stream<DiagnosticsVm> Function(int),
          String,
          String,
          int,
        )
      >[
        (
          'today',
          (int call) => one(safe0),
          (int call) => call == 0
              ? Stream<OpsDailySummary>.error(StateError('fail'))
              : one(normal),
          (int call) => one(alloc),
          (int call) => one(ok),
          'h01-fail',
          'h01-asof',
          1,
        ),
        (
          'safety',
          (int call) => call == 0
              ? Stream<SafetyState>.error(StateError('fail'))
              : one(safe0),
          (int call) => one(normal),
          (int call) => one(alloc),
          (int call) => one(ok),
          'h01-status-fail',
          'h01-status',
          0,
        ),
        (
          'alloc',
          (int call) => one(safe0),
          (int call) => one(normal),
          (int call) => call == 0
              ? Stream<SleeveAllocationVm>.error(StateError('fail'))
              : one(alloc),
          (int call) => one(ok),
          'h01-alloc-fail',
          'h01-alloc',
          2,
        ),
        (
          'diag',
          (int call) => one(safe0),
          (int call) => one(normal),
          (int call) => one(alloc),
          (int call) => call == 0
              ? Stream<DiagnosticsVm>.error(StateError('fail'))
              : one(ok),
          'h01-recon-fail',
          'h01-recon',
          3,
        ),
      ];

  for (final (
        String which,
        Stream<SafetyState> Function(int) safetyF,
        Stream<OpsDailySummary> Function(int) todayF,
        Stream<SleeveAllocationVm> Function(int) allocF,
        Stream<DiagnosticsVm> Function(int) diagF,
        String failKey,
        String successKey,
        int failIndex,
      )
      in cases10) {
    testWidgets('T01-10 retry\n$which', (WidgetTester tester) async {
      final FakeShellSafetyRepository safetyRepo = FakeShellSafetyRepository(
        state: safetyF,
      );
      final FakeShellOpsTodayRepository todayRepo = FakeShellOpsTodayRepository(
        today: todayF,
      );
      final FakeShellHoldingsRepository allocRepo = FakeShellHoldingsRepository(
        allocation: allocF,
      );
      final FakeShellOpsStatusRepository diagRepo =
          FakeShellOpsStatusRepository(diagnostics: diagF);
      await pumpOpsHome(
      └──

상자 36 (C4h-2 · C4h-3 · test/ops_home_test.dart — T01-08 본문 · 40줄 → 27줄)
   (바뀐 뜻: 흐름 클로저 + 경우 공통 expect(opener.opened, opened) · 카드 색 단언은 카드 있는 경우에서만 — bool 칸 + if 0 · 덧붙인 else 0 · name == 0)
      ┌── 이 줄을(test/ops_home_test.dart 664~703행 · 40줄 · 이 40줄 묶음은 파일에 한 곳뿐)
      );
      expect(
        find.byKey(const Key('h01-audit')),
        wantCard ? findsOneWidget : findsNothing,
        reason: name,
      );
      if (wantCard) {
        final List<String?> texts = shownTexts(
          tester,
          find.byKey(const Key('h01-audit')),
        );
        expect(texts[0], trustF.label, reason: name);
        expect(texts[1], trustF.consequenceLine, reason: name);
        expect(
          find.byKey(const Key('h01-audit-action')),
          wantButton ? findsOneWidget : findsNothing,
          reason: name,
        );
        final ColorScheme cs = Theme.of(tester.element(find.byType(OpsHome)))
            .colorScheme;
        if (name == 'due') {
          await tester.tap(find.byKey(const Key('h01-audit-action')));
          await tester.pump();
          expect(opener.opened, <String>[trustDue.actionDeepLink!]);
          final Card card = tester.widget<Card>(
            find.byKey(const Key('h01-audit')),
          );
          expect(card.color, cs.surfaceContainerHighest, reason: 'info color');
          expect(card.color, isNot(cs.errorContainer), reason: 'not error');
        } else {
          expect(opener.opened, isEmpty, reason: name);
        }
      } else {
        expect(
          find.byKey(const Key('h01-audit-action')),
          findsNothing,
          reason: name,
        );
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──
      ┌── 이 줄로(27줄)
      );
      final Finder card = find.byKey(const Key('h01-audit'));
      if (want != null) {
        expect(shownTexts(tester, card).take(2).toList(), want, reason: name);
        final ColorScheme cs = Theme.of(tester.element(find.byType(OpsHome)))
            .colorScheme;
        expect(
          tester.widget<Card>(card).color,
          cs.surfaceContainerHighest,
          reason: 'info color',
        );
        expect(
          tester.widget<Card>(card).color,
          isNot(cs.errorContainer),
          reason: 'not error',
        );
      } else {
        expect(card, findsNothing, reason: name);
      }
      expect(
        find.byKey(const Key('h01-audit-action')),
        button ? findsOneWidget : findsNothing,
        reason: name,
      );
      await steps(tester);
      expect(opener.opened, opened, reason: name);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──

상자 37 (C4h-3 · test/ops_home_test.dart — T01-08 경우 레코드 칸 · 4줄 → 6줄)
   (바뀐 뜻: bool wantCard → want · steps(클로저) · opened(기대 목록) 칸)
      ┌── 이 줄을(test/ops_home_test.dart 637~640행 · 4줄 · 이 4줄 묶음은 파일에 한 곳뿐)
        LedgerTrustBadge trustF,
        bool wantCard,
        bool wantButton,
      )
      └──
      ┌── 이 줄로(6줄)
        LedgerTrustBadge trustF,
        List<String>? want,
        bool button,
        Future<void> Function(WidgetTester) steps,
        List<String> opened,
      )
      └──

상자 38 (C4h-3 · C4h-4 · test/ops_home_test.dart — T01-08 경우 목록 · 7줄 → 55줄)
   (바뀐 뜻: 세 경우(due · viewer · none)에 want · steps · opened 를 직접)
      ┌── 이 줄을(test/ops_home_test.dart 626~632행 · 7줄 · 이 7줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  final List<(String, SafetyState, LedgerTrustBadge, bool, bool)> cases08 =
      <(String, SafetyState, LedgerTrustBadge, bool, bool)>[
        ('due', safe1, trustDue, true, true),
        ('viewer', safe1, viewer, true, false),
        ('none', safe0, trustDue, false, false),
      ];
      └──
      ┌── 이 줄로(55줄 · 첫 줄 = 빈 줄)

  final List<
    (
      String,
      SafetyState,
      LedgerTrustBadge,
      List<String>?,
      bool,
      Future<void> Function(WidgetTester),
      List<String>,
    )
  >
  cases08 =
      <
        (
          String,
          SafetyState,
          LedgerTrustBadge,
          List<String>?,
          bool,
          Future<void> Function(WidgetTester),
          List<String>,
        )
      >[
        (
          'due',
          safe1,
          trustDue,
          <String>[trustDue.label, trustDue.consequenceLine],
          true,
          (WidgetTester t) async {
            await t.tap(find.byKey(const Key('h01-audit-action')));
            await t.pump();
          },
          <String>[trustDue.actionDeepLink!],
        ),
        (
          'viewer',
          safe1,
          viewer,
          <String>[viewer.label, viewer.consequenceLine],
          false,
          (WidgetTester t) async {},
          <String>[],
        ),
        (
          'none',
          safe0,
          trustDue,
          null,
          false,
          (WidgetTester t) async {},
          <String>[],
        ),
      ];
      └──

상자 39 (C4h-2 · C4h-3 · test/ops_home_test.dart — T01-04 본문 · 12줄 → 7줄)
   (바뀐 뜻: await steps(tester); → expect(opener.opened, opened, …) — if (name == …) 0 · 덧붙인 else 0)
      ┌── 이 줄을(test/ops_home_test.dart 396~407행 · 12줄 · 이 12줄 묶음은 파일에 한 곳뿐)
        );
        if (name == 'open') {
          await tester.tap(find.byKey(const Key('h01-advice')));
          await tester.pump();
          expect(opener.opened, <String>[AppRoutes.adviceInbox]);
        } else {
          expect(opener.opened, isEmpty, reason: name);
        }
      } else {
        expect(find.byKey(const Key('h01-advice')), findsNothing, reason: name);
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──
      ┌── 이 줄로(7줄)
        );
      } else {
        expect(find.byKey(const Key('h01-advice')), findsNothing, reason: name);
      }
      await steps(tester);
      expect(opener.opened, opened, reason: name);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──

상자 40 (C4h-4 · test/ops_home_test.dart — T01-04 today 입력 · 5줄 → 3줄)
   (바뀐 뜻: today 공장 = 경우 칸 값 — 이름 삼항 0)
      ┌── 이 줄을(test/ops_home_test.dart 371~375행 · 5줄 · 이 5줄 묶음은 파일에 한 곳뿐)
          safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
          today: FakeShellOpsTodayRepository(
            today: (int call) => one(name == 'open' ? adviceT : zeroT),
          ),
          advice: FakeShellAdviceRepository(
      └──
      ┌── 이 줄로(3줄)
          safety: FakeShellSafetyRepository(state: (int call) => one(safe0)),
          today: FakeShellOpsTodayRepository(today: (int call) => one(todayF)),
          advice: FakeShellAdviceRepository(
      └──

상자 41 (C4h-3 · C4h-4 · test/ops_home_test.dart — T01-04 경우 목록 · 15줄 → 61줄)
   (바뀐 뜻: 경우 레코드에 today 입력 · steps · opened 칸)
      ┌── 이 줄을(test/ops_home_test.dart 344~358행 · 15줄 · 이 15줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  final List<(String, AdviceInboxSummary, List<String>?)> cases04 =
      <(String, AdviceInboxSummary, List<String>?)>[
        (
          'open',
          open,
          <String>[open.headline, open.dueSoonLabel!, open.trust.label],
        ),
        ('zero_none', none, null),
        ('suppressed', suppressed, <String>[suppressed.headline]),
        ('suppressed_due', sdue, <String>[sdue.headline]),
      ];

  for (final (String name, AdviceInboxSummary adviceF, List<String>? want)
      in cases04) {
      └──
      ┌── 이 줄로(61줄 · 첫 줄 = 빈 줄)

  final List<
    (
      String,
      OpsDailySummary,
      AdviceInboxSummary,
      List<String>?,
      Future<void> Function(WidgetTester),
      List<String>,
    )
  >
  cases04 =
      <
        (
          String,
          OpsDailySummary,
          AdviceInboxSummary,
          List<String>?,
          Future<void> Function(WidgetTester),
          List<String>,
        )
      >[
        (
          'open',
          adviceT,
          open,
          <String>[open.headline, open.dueSoonLabel!, open.trust.label],
          (WidgetTester t) async {
            await t.tap(find.byKey(const Key('h01-advice')));
            await t.pump();
          },
          <String>[AppRoutes.adviceInbox],
        ),
        ('zero_none', zeroT, none, null, (WidgetTester t) async {}, <String>[]),
        (
          'suppressed',
          zeroT,
          suppressed,
          <String>[suppressed.headline],
          (WidgetTester t) async {},
          <String>[],
        ),
        (
          'suppressed_due',
          zeroT,
          sdue,
          <String>[sdue.headline],
          (WidgetTester t) async {},
          <String>[],
        ),
      ];

  for (final (
        String name,
        OpsDailySummary todayF,
        AdviceInboxSummary adviceF,
        List<String>? want,
        Future<void> Function(WidgetTester) steps,
        List<String> opened,
      )
      in cases04) {
      └──

상자 42 (C4h-3 · test/ops_home_test.dart — T01-03 본문 · 11줄 → 7줄)
   (바뀐 뜻: await steps(tester); → expect(opener.opened, opened, …) — opened[0]·[1] 원소 비교 0(탭 한 번에 두 번 여는 꼴도 잡는다))
      ┌── 이 줄을(test/ops_home_test.dart 329~339행 · 11줄 · 이 11줄 묶음은 파일에 한 곳뿐)
        expect(shownTexts(tester, find.byKey(const Key('h01-blocked'))), want);
        await tester.tap(find.byKey(const Key('h01-blocked')));
        await tester.pump();
        expect(opener.opened[0], AppRoutes.m5BlockBoard);
        await tester.tap(find.byKey(const Key('h01-status')));
        await tester.pump();
        expect(opener.opened[1], AppRoutes.m5BlockBoard);
      } else {
        expect(find.byKey(const Key('h01-blocked')), findsNothing);
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──
      ┌── 이 줄로(7줄)
        expect(shownTexts(tester, find.byKey(const Key('h01-blocked'))), want);
      } else {
        expect(find.byKey(const Key('h01-blocked')), findsNothing);
      }
      await steps(tester);
      expect(opener.opened, opened);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──

상자 43 (C4h-4 · test/ops_home_test.dart — T01-03 want · 3줄 → 2줄)
   (바뀐 뜻: want = 경우 칸(name == 0))
      ┌── 이 줄을(test/ops_home_test.dart 306~308행 · 3줄 · 이 3줄 묶음은 파일에 한 곳뿐)
      expect(safe1.activeFlags, isNotEmpty); // pre
      final List<String>? want = name == 'halted' ? wantHalted : null;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      └──
      ┌── 이 줄로(2줄)
      expect(safe1.activeFlags, isNotEmpty); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      └──

상자 44 (C4h-3 · C4h-4 · test/ops_home_test.dart — T01-03 경우 목록 · 9줄 → 45줄)
   (바뀐 뜻: 경우 레코드에 want · steps · opened 칸)
      ┌── 이 줄을(test/ops_home_test.dart 294~302행 · 9줄 · 이 9줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  final List<(String, SafetyState)> cases03 = <(String, SafetyState)>[
    ('halted', safe3),
    ('marker_only', safe1),
    ('none', safe0),
  ];

  for (final (String name, SafetyState safetyF) in cases03) {
    testWidgets('T01-03 block 3 blocking only\n$name', (
      └──
      ┌── 이 줄로(45줄 · 첫 줄 = 빈 줄)

  final List<
    (
      String,
      SafetyState,
      List<String>?,
      Future<void> Function(WidgetTester),
      List<String>,
    )
  >
  cases03 =
      <
        (
          String,
          SafetyState,
          List<String>?,
          Future<void> Function(WidgetTester),
          List<String>,
        )
      >[
        (
          'halted',
          safe3,
          wantHalted,
          (WidgetTester t) async {
            await t.tap(find.byKey(const Key('h01-blocked')));
            await t.pump();
            await t.tap(find.byKey(const Key('h01-status')));
            await t.pump();
          },
          <String>[AppRoutes.m5BlockBoard, AppRoutes.m5BlockBoard],
        ),
        ('marker_only', safe1, null, (WidgetTester t) async {}, <String>[]),
        ('none', safe0, null, (WidgetTester t) async {}, <String>[]),
      ];

  for (final (
        String name,
        SafetyState safetyF,
        List<String>? want,
        Future<void> Function(WidgetTester) steps,
        List<String> opened,
      )
      in cases03) {
    testWidgets('T01-03 block 3 blocking only\n$name', (
      └──

상자 45 (C4h-3 · test/ops_home_test.dart — T01-02 본문 · 8줄 → 7줄)
   (바뀐 뜻: await steps(tester); → expect(opener.opened, opened, …) — 링크 단언이 if 안 0)
      ┌── 이 줄을(test/ops_home_test.dart 277~284행 · 8줄 · 이 8줄 묶음은 파일에 한 곳뿐)
        );
        await tester.tap(find.byKey(const Key('h01-resume')));
        await tester.pump();
        expect(opener.opened, <String>[resume.resumeLine!.deepLink]);
      } else {
        expect(find.byKey(const Key('h01-resume')), findsNothing);
      }
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──
      ┌── 이 줄로(7줄)
        );
      } else {
        expect(find.byKey(const Key('h01-resume')), findsNothing);
      }
      await steps(tester);
      expect(opener.opened, opened);
      expect(find.text(ShellLabels.retry), findsNothing); // ⓡ
      └──

상자 46 (C4h-3 · C4h-4 · test/ops_home_test.dart — T01-02 경우 목록 · 14줄 → 45줄)
   (바뀐 뜻: 경우 레코드에 want · steps · opened 칸 — want = 경우 칸(name == 0))
      ┌── 이 줄을(test/ops_home_test.dart 240~253행 · 14줄 · 이 14줄 묶음은 파일에 한 곳뿐 · 첫 줄 = 빈 줄)

  final List<(String, OpsDailySummary)> cases02 = <(String, OpsDailySummary)>[
    ('resume_gap7', resume),
    ('normal', normal),
  ];

  for (final (String name, OpsDailySummary todayF) in cases02) {
    testWidgets('T01-02 block 2 resume\n$name', (WidgetTester tester) async {
      expect(resume.resumeLine, isNotNull); // pre
      expect(normal.resumeLine, isNull); // pre
      final String? want = name == 'resume_gap7'
          ? resume.resumeLine!.label
          : null;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      └──
      ┌── 이 줄로(45줄 · 첫 줄 = 빈 줄)

  final List<
    (
      String,
      OpsDailySummary,
      String?,
      Future<void> Function(WidgetTester),
      List<String>,
    )
  >
  cases02 =
      <
        (
          String,
          OpsDailySummary,
          String?,
          Future<void> Function(WidgetTester),
          List<String>,
        )
      >[
        (
          'resume_gap7',
          resume,
          resume.resumeLine!.label,
          (WidgetTester t) async {
            await t.tap(find.byKey(const Key('h01-resume')));
            await t.pump();
          },
          <String>[resume.resumeLine!.deepLink],
        ),
        ('normal', normal, null, (WidgetTester t) async {}, <String>[]),
      ];

  for (final (
        String name,
        OpsDailySummary todayF,
        String? want,
        Future<void> Function(WidgetTester) steps,
        List<String> opened,
      )
      in cases02) {
    testWidgets('T01-02 block 2 resume\n$name', (WidgetTester tester) async {
      expect(resume.resumeLine, isNotNull); // pre
      expect(normal.resumeLine, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      └──

상자 47 (C4h-1 · C4h-14 · ../../docs/ai-context/inbox/H01_questions.md — 질문 파일 A1~A9 · 10줄 → 10줄)
   (바뀐 뜻: A1~A8 = 새 dy(< 1120) · A9 = 여백 축소 «측정:» 행(자리 · 정수 전 → 뒤 · 줄이기 전 dy → 줄인 뒤 dy · 12 §3 꼴))
      ┌── 이 줄을(../../docs/ai-context/inbox/H01_questions.md 10~19행 · 10줄 · 이 10줄 묶음은 파일에 한 곳뿐 · 파일 끝 묶음 — 마지막 줄 뒤에 줄이 없다)
|---|---|---|---|---|---|---|---|
| A1 | R13b-Bob-H01 | 추측 | 측정: h01_normal dy 실측값 (light=1096.0, dark=1096.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A2 | R13b-Bob-H01 | 추측 | 측정: h01_blocked dy 실측값 (light=1180.0, dark=1180.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A3 | R13b-Bob-H01 | 추측 | 측정: h01_resume_gap7 dy 실측값 (light=1160.0, dark=1160.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A4 | R13b-Bob-H01 | 추측 | 측정: h01_recon_diff dy 실측값 (light=1116.0, dark=1116.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A5 | R13b-Bob-H01 | 추측 | 측정: h01_advice_open dy 실측값 (light=1180.0, dark=1180.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A6 | R13b-Bob-H01 | 추측 | 측정: h01_advice_zero dy 실측값 (light=1096.0, dark=1096.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A7 | R13b-Bob-H01 | 추측 | 측정: h01_advice_suppressed dy 실측값 (light=1140.0, dark=1140.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A8 | R13b-Bob-H01 | 추측 | 측정: h01_self_audit_due dy 실측값 (light=1256.0, dark=1256.0) < 1300 | 골든 위치 전제 실측 | 1300 미만 확인 | ⬜ 미답 | |
| A9 | R13b-Bob-H01 | 추측 | 측정: 카드 계획 _kTallPhone 높이 1120 이었으나 max dy=1256.0 초과 → 1300 으로 변경 | 골든 높이 재량 변경 | 높이 1300 사용 | ⬜ 미답 | |
      └──
      ┌── 이 줄로(10줄)
|---|---|---|---|---|---|---|---|
| A1 | R13b-Bob-H01 | 추측 | 측정: h01_normal dy 실측값 (light=952.0, dark=952.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A2 | R13b-Bob-H01 | 추측 | 측정: h01_blocked dy 실측값 (light=1020.0, dark=1020.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A3 | R13b-Bob-H01 | 추측 | 측정: h01_resume_gap7 dy 실측값 (light=1000.0, dark=1000.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A4 | R13b-Bob-H01 | 추측 | 측정: h01_recon_diff dy 실측값 (light=972.0, dark=972.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A5 | R13b-Bob-H01 | 추측 | 측정: h01_advice_open dy 실측값 (light=1020.0, dark=1020.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A6 | R13b-Bob-H01 | 추측 | 측정: h01_advice_zero dy 실측값 (light=952.0, dark=952.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A7 | R13b-Bob-H01 | 추측 | 측정: h01_advice_suppressed dy 실측값 (light=980.0, dark=980.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A8 | R13b-Bob-H01 | 추측 | 측정: h01_self_audit_due dy 실측값 (light=1104.0, dark=1104.0) < 1120 | 골든 위치 전제 실측 | 1120 미만 확인 | ⬜ 미답 | |
| A9 | R13b-Bob-H01 | 추측 | 측정: 여백 축소(12 §3 골든 높이 조문 · 높이 1120 그대로) — 자리 = lib/src/ops_home.dart 블록 Padding vertical 12 → 4(9곳) · _AllocRow Padding vertical 4 → 0 · _UpcomingRow Padding vertical 4 → 0 · 줄이기 전 dy(light=dark) h01_normal 1096.0 · h01_blocked 1180.0 · h01_resume_gap7 1160.0 · h01_recon_diff 1116.0 · h01_advice_open 1180.0 · h01_advice_zero 1096.0 · h01_advice_suppressed 1140.0 · h01_self_audit_due 1256.0 → 줄인 뒤 952.0 · 1020.0 · 1000.0 · 972.0 · 1020.0 · 952.0 · 980.0 · 1104.0 | 골든 위치 전제가 1120 을 넘음 | 여백만 줄여 1120 안에 맞춤 | ⬜ 미답 | |
      └──

고친 뒤 확인(packages/ui_shell 에서 · PNG 다시 찍기 전 · 커밋하기 전 · 고치지 않고 보기만):
  git diff --stat                     ← 마지막 줄이 « 6 files changed, 433 insertions(+), 215 deletions(-)»(위에 파일 줄 여섯이 더 있는 것이 정상 · PNG 줄 0 · 다르면 상자와 다시 대조 · 커밋하지 않는다)
  dart format --output=none --set-exit-if-changed lib/src/ops_home.dart lib/src/shell_providers.dart test/shell_fakes.dart test/golden/h01_golden_test.dart test/ops_home_test.dart
                                      ← «Formatted 5 files (0 changed) in …» 꼴 · 바뀐 줄이 있으면 상자와 다르게 옮긴 것 — 다시 대조
  git hash-object lib/src/ops_home.dart                        ← e9bb4df7b15f5b8d43c2c0d933f5de4f5b2ba7de
  git hash-object lib/src/shell_providers.dart                 ← 3c831ef141066a350b4eec0002944212f94a60ac
  git hash-object test/shell_fakes.dart                        ← 35c3fe9679ec60e40e64cb279fec05b83340a3a7
  git hash-object test/golden/h01_golden_test.dart             ← 2abe8f9953edf3927f37deeabc4101326c2a243b
  git hash-object test/ops_home_test.dart                      ← 807cd1ecc100a93f9b652e6b1f4bde3c05fd7aa8
  git hash-object ../../docs/ai-context/inbox/H01_questions.md ← a49d3f3184b22b8d33313c0cf27d890bbdc63d53
     (여섯 줄 = C4 수정안 파일의 git 해시 · 다르면 그 파일만 상자와 다시 대조 — BOM · 줄 끝 빈칸 · 빈 줄 하나 차이에도 해시가 바뀐다)
  git grep -c -F "Size(390, 1120)" -- test/golden/h01_golden_test.dart           ← «test/golden/h01_golden_test.dart:1»(C4h-1 · 81d9ace 에서는 출력 없음 — 1300)
  git grep -c -F "vertical: 12" -- lib/src/ops_home.dart                        ← 출력 없음(C4h-1 · 81d9ace 에서는 «lib/src/ops_home.dart:9»)
  git grep -c -F '!)' -- lib/src/ops_home.dart                                  ← 출력 없음(C4h-6 · 81d9ace 에서는 «lib/src/ops_home.dart:5» · 이 줄만 작은따옴표)
  git grep -c -F "actionDeepLink" -- test/shell_fakes.dart                      ← 출력 없음(C4h-8 · 81d9ace 에서는 «test/shell_fakes.dart:1»)
  git grep -c -F "await flow.steps(tester);" -- test/golden/h01_golden_test.dart ← «test/golden/h01_golden_test.dart:1»(C4h-5 · 81d9ace 에서는 출력 없음)
  git grep -c -E "name ==|which ==" -- test/ops_home_test.dart                  ← 출력 없음(C4h-4 · 81d9ace 에서는 «test/ops_home_test.dart:15»)
  git grep -c -F "data.isEmpty ||" -- test/ops_home_test.dart                   ← 출력 없음(C4h-2 · 81d9ace 에서는 «test/ops_home_test.dart:1»)
  git grep -c -F "opener.opened[" -- test/ops_home_test.dart                    ← 출력 없음(C4h-3 · 81d9ace 에서는 «test/ops_home_test.dart:2»)
  git grep -c -F "await steps(tester);" -- test/ops_home_test.dart              ← «test/ops_home_test.dart:5»(C4h-3 · 81d9ace 에서는 «test/ops_home_test.dart:1»)
  git grep -c "retry), findsNothing" -- test/ops_home_test.dart                 ← «test/ops_home_test.dart:11»(ⓡ · 81d9ace 와 같은 수)
  git grep -c "hasLength(" -- test/ops_home_test.dart                           ← «test/ops_home_test.dart:3»(ⓗ · 81d9ace 와 같은 수)
  git grep -c "// pre$" -- test/ops_home_test.dart                              ← «test/ops_home_test.dart:17»(전제 · 81d9ace 와 같은 수)
  (위 줄 다 자기 점검이다 · 따옴표 그대로(Git Bash·PowerShell 둘 다 그대로 돈다) · 다르면 PNG 를 다시 찍지 말고 커밋하지 말고 멈춘 뒤 출력을 채팅으로 · 이 출력은 채팅 글에 붙이지 않는다)

■ PNG 다시 찍기 — 명령 한 줄 (packages/ui_shell 에서 · 위 «고친 뒤 확인» 이 기대와 같은 뒤 · 🔴 PNG 는 열지 않는다)
  flutter test --update-goldens test/golden/h01_golden_test.dart   ← 끝 줄 «+16: All tests passed!»(🔴 이 파일 하나만 — 다른 골든 파일·폴더를 넣지 않는다 · 이 명령은 한 번만)
  git status --short   ← 🔴 정확히 22줄 · 전부 « M»(경로는 packages/ui_shell 에서 본 꼴):
        여섯 파일 = ../../docs/ai-context/inbox/H01_questions.md · lib/src/ops_home.dart · lib/src/shell_providers.dart · test/golden/h01_golden_test.dart · test/ops_home_test.dart · test/shell_fakes.dart
        + PNG 16 = test/golden/goldens/h01_<이름>_dark.png · h01_<이름>_light.png(<이름> = advice_open · advice_suppressed · advice_zero · blocked · normal · recon_diff · resume_gap7 · self_audit_due)
        ← s01_*·h02_* PNG 의 M · ?? 줄(새 파일 · test/golden/failures/ 등) · 그 밖의 줄 = 금지 → 멈춘 뒤 채팅으로(PNG 를 열지 않는다 · 다시 찍지 않는다)
  다시 찍은 PNG 확인 — 열지 않고 git 해시로(16줄 · 기대 = C4 가 같은 상자로 다시 찍은 16장 · 2026-10-27):
  git hash-object test/golden/goldens/h01_advice_open_dark.png        ← 77ab8fe7947e61c6f76c3049f2c3051132fea397
  git hash-object test/golden/goldens/h01_advice_open_light.png       ← 37c34eda8761f7dfba086cb6309042fd99729cd8
  git hash-object test/golden/goldens/h01_advice_suppressed_dark.png  ← 7c9ca69fa24ca23a93741b9062fba9527d188bff
  git hash-object test/golden/goldens/h01_advice_suppressed_light.png ← 30e1f867af0403c1113173b995fb25c6e8f73b93
  git hash-object test/golden/goldens/h01_advice_zero_dark.png        ← e88470c42d49c1b9c98b7cefe5870937fa14455a
  git hash-object test/golden/goldens/h01_advice_zero_light.png       ← 1ce5d25b0b4ba3ed4b1d14327fb0668a8d21a592
  git hash-object test/golden/goldens/h01_blocked_dark.png            ← 9c4b6fe43e31287d6c5853eaf6565f1afa19da46
  git hash-object test/golden/goldens/h01_blocked_light.png           ← 69cf58fc100e73d1131dd433682b86efddcba9c7
  git hash-object test/golden/goldens/h01_normal_dark.png             ← d6a2b0ecd9ff42b01879f80cfa4219dcc36d642d
  git hash-object test/golden/goldens/h01_normal_light.png            ← ae8eff765a999c5c744d0bd15bda56e5c4129fff
  git hash-object test/golden/goldens/h01_recon_diff_dark.png         ← 4baa8292750afb00ec4b90f0ac9892b69e37890a
  git hash-object test/golden/goldens/h01_recon_diff_light.png        ← 41c0eb6fd1233b3c60276f95b1311f9322d0f6da
  git hash-object test/golden/goldens/h01_resume_gap7_dark.png        ← 1d7ba179985f5f21140a5482e6e79de03d60cd20
  git hash-object test/golden/goldens/h01_resume_gap7_light.png       ← 7ff08b6ee21fc482048bd5eefcc263cc6a757960
  git hash-object test/golden/goldens/h01_self_audit_due_dark.png     ← aa2cf0ae84f964c4161105b4c7b6f6e3e143be24
  git hash-object test/golden/goldens/h01_self_audit_due_light.png    ← 4a46cbc35800031046c7ee6bc68fb4d89a1d6654
  ← 16줄이 모두 같으면 = C4 판과 바이트 같음 → 크기 390×1120 · 위치 전제 dy 도 C4 실측 그대로다(normal 952.0 · blocked 1020.0 · resume_gap7 1000.0 · recon_diff 972.0 ·
     advice_open 1020.0 · advice_zero 952.0 · advice_suppressed 980.0 · self_audit_due 1104.0 · light = dark) — 아래 «크기·dy 확인» 은 건너뛰고 «■ 테스트 수 묶음» 으로.
     하나라도 다르면 멈추지 않는다 — PNG 를 열지 말고 아래 «크기·dy 확인» 둘을 돌린다(다른 해시는 C4 가 2회차에 띠 모양으로 대조한다 · 채팅 글에 따로 적지 않는다 — 조각 밖 글 0).
  크기·dy 확인 (해시가 하나라도 다를 때만 · PowerShell · 커밋 0 · 파일을 바꾼 채 두지 않는다):
   ① 크기 — PNG 머리의 가로·세로 수만 읽는다(이미지를 열지 않는다 · 한 줄):
      Get-ChildItem test\golden\goldens\h01_*.png | ForEach-Object { $b = [IO.File]::ReadAllBytes($_.FullName); '{0} {1}x{2}' -f $_.Name, ($b[18]*256+$b[19]), ($b[22]*256+$b[23]) }
      ← 16줄 모두 «h01_<…>.png 390x1120»
   ② dy — 위치 전제를 잠깐 lessThan(0) 으로 바꿔 «Actual:» 값만 읽고 되돌린다(1회차 카드 436행과 같은 잰 법 · 다섯 줄 차례대로):
      $p = "$PWD\test\golden\h01_golden_test.dart"; $t = [IO.File]::ReadAllText($p); [IO.File]::WriteAllText($p, $t.Replace('lessThan(_kTallPhone.height)', 'lessThan(0)'))
      flutter test test/golden/h01_golden_test.dart | Out-File -Encoding utf8 $env:TEMP\r13b_dy.txt        ← 16개 실패가 정상(전제를 일부러 틀리게 했다)
      [IO.File]::WriteAllText($p, $t)                                                                     ← 🔴 되돌리기(꼭 · 이 줄을 빼먹으면 커밋하지 않는다)
      git hash-object test/golden/h01_golden_test.dart                                                    ← 위 «고친 뒤 확인» 의 h01_golden_test 해시와 같아야(되돌림 확인)
      Select-String -Path $env:TEMP\r13b_dy.txt -Pattern 'Actual: <' -Encoding UTF8 | ForEach-Object { $_.Line.Trim() }
      ← 16줄 = 차례대로 «Actual: <952.0>» 2 · «Actual: <1020.0>» 2 · «Actual: <1000.0>» 2 · «Actual: <972.0>» 2 · «Actual: <1020.0>» 2 · «Actual: <952.0>» 2 · «Actual: <980.0>» 2 · «Actual: <1104.0>» 2
        (테스트 차례 = normal → blocked → resume_gap7 → recon_diff → advice_open → advice_zero → advice_suppressed → self_audit_due · 이름마다 dark → light)
      git status --short   ← 위와 같은 22줄(test/golden/failures/ 가 생겼으면 그 폴더만 지운다 · 그 밖의 줄이 늘었으면 멈춤)
   ①② 가 기대와 같으면 그대로 다음으로(골든 표 = 조각 17 상자 그대로) · 다르면 커밋하지 말고 멈춘 뒤 ①② 출력을 채팅으로(PNG 를 열지 않는다 · 다시 찍지 않는다 · 질문 파일을 고쳐 쓰지 않는다).

커밋 — 하나 · 맨 위에(상자 1~47 전부 + h01_* PNG 16 · format:fix 가 바꾼 줄이 있으면 그것도 같은 커밋 — 기대는 0 줄):
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M8] R13b (8) C4 반려 수정 — 골든 높이 1120 · 흐름 클로저 · 경우 칸 · if 감추기 제거 · 경미 4
      └── 커밋 제목 복사 끝(이 줄 앞까지)
   🔴 지난 커밋(81d9ace · 4513041 · c1a38ae · 78869ea · a794443 · c347846 · d6dc617)을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.

■ 고치지 않는 것 (1회차가 맞았거나 이 글 밖 — 손대면 반려)
 · 상자 1~47 밖의 lib·테스트 본문 전부 · s01_*·h02_* PNG(--update-goldens 는 h01_golden_test.dart 하나만 · PNG 는 열지도 않는다) · labels.dart · ui_shell.dart · 셸 파일 · 그 밖의 테스트 파일
 · h01_* PNG 를 손으로 바꾸는 일 — 바꾸는 길은 «■ PNG 다시 찍기» 명령 한 줄뿐(두 번 찍지 않는다)
 · ⓡ·ⓗ·// pre 줄의 수(H18 11 · H19 3 · H31 17) · testWidgets·test 줄 수(H03 1 · 12) · 테스트 이름 · 경우 이름과 수 · 골든 이름 8 · 골든 입력(today · safety · advice · alloc · diag · trust)
 · 지난 7개 커밋(제목 포함 — C4h-16 은 통합 담당 몫) · 다음 카드 보강 후보(C4 보고 §8 · 카드 구멍 C4h-17~21)는 이번에 넣지 않는다(넣으면 범위 밖 변경)

■ 질문 파일
· 상자 47 이 A1~A9 행을 통째로 바꿉니다(A1~A8 = 새 dy · «< 1120» · A9 = 여백 축소 «측정:» 행 — 자리 · 정수 전 → 뒤 · 줄이기 전 dy → 줄인 뒤 dy). 머리말(«다음 번호» 포함)·표 머리는 그대로입니다.
· 🔴 상자 47 밖의 행을 더하지 않습니다(측정·추측·질문 어느 것이든) — 새 행이 필요해 보이면 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 · dy 가 C4 값과 다르게 나와도(위 «크기·dy 확인») 행을 고쳐 쓰지 않고 멈춥니다.
· 답 칸은 비워 둡니다(병합 때 통합 담당이 닫는다) · 상태는 «⬜ 미답» 그대로(상자 글자).

(읽는 법 — 아래 «■ 정적 묶음» 절은 1회차 카드 371~413행 글자 그대로다(절 안의 «N행» = 원 카드 줄 번호). 이 재제출에서는 «PR 본문 ②» = 채팅 글 조각 11 · «블록 뒤 S05 결과 줄» = 조각 12 상자 · «flutter test 출력» = 이 글의 «■ 테스트 수 묶음» ·
  H26·H30 의 origin/main...HEAD 는 점 세 개라 기록 커밋이 main 에 더해져도 1회차와 같은 밑동(4206274)에서 잰다 ·
  대조에서 빼는 것 = 빈 줄 · EXIT 표기 · warning:·error: 줄 · PowerShell 장식 줄 · 줄 머리 경과 시각 · 한국어가 깨져 보이면 [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 돌린다.)
■ 정적 묶음 — packages/ui_shell 에서 아래 31줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (R13a 카드와 같은 대조 규칙 — 줄을 고르거나 줄이거나 설명으로 바꾸지 않는다 · 대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 ·
   flutter test·dart test 출력은 파일로 떠서 붙인다 · «EXIT:1»/«EXIT:False» = 출력 없음 · 블록 뒤 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»)
echo "## H01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/ops_home_test.dart test/golden/h01_golden_test.dart; echo "EXIT:$?"
echo "## H02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/ops_home_test.dart test/golden/h01_golden_test.dart; echo "EXIT:$?"
echo "## H03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/ops_home_test.dart test/golden/h01_golden_test.dart; echo "EXIT:$?"
echo "## H04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H06 subscription lines (6)"; git grep -nE "watchState\(|watchToday\(|watchSummary\(|watchAllocation\(|watchDiagnostics\(|watchGrade\(" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H07 forbidden words in ops_home 0"; git grep -nE "DateTime\.now|kIsWeb|Platform\.|dart:io|HoldingPnl|PerformanceSeries|afterTax|cagrPct|endMult|deployedText|parkingText|deployedRatio|parkingRatio|gauge|drawdown|killSwitch|FeatureFlags|operatingMode|runMode|watchOpenDiffs|watchInbox|watchRhythm|stateCode|NumberFormat|toStringAsFixed|toString\(" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H08 AppRoutes constants in ops_home"; git grep -nE "AppRoutes\.[a-zA-Z]+" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H09 FlagIds and filter lines"; git grep -nE "FlagIds\.|\.where\(|\.any\(|openCount|parentSleeve" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H10 switch arms (UiLevel 5 x2 + lifecycle 5)"; git grep -nE "UiLevel\.|AppLifecycleState\." -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H11 shell labels (31)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## H12 barrel exports (6)"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## H13 shell providers"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## H14 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## H15 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## H16 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## H17 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## H18 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/ops_home_test.dart; echo "EXIT:$?"
echo "## H19 H lines (hasLength)"; git grep -c "hasLength(" -- test/ops_home_test.dart; echo "EXIT:$?"
echo "## H20 h01 key names"; git grep -noP "h01-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H21 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## H22 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## H23 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## H24 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## H25 Scaffold AppBar Navigator in ops_home 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/ops_home.dart; echo "EXIT:$?"
echo "## H26 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_shell.dart lib/src/shell_providers.dart test/shell_fakes.dart lib/src/shell_scaffold.dart lib/src/routing/shell_router.dart lib/src/common/shell_common.dart lib/src/ops_rhythm.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart; echo "EXIT:$?"
echo "## H27 implements in new tests (2)"; git grep -n " implements " -- test/shell_fakes.dart test/ops_home_test.dart test/golden/h01_golden_test.dart; echo "EXIT:$?"
echo "## H28 copyWith in tests"; git grep -n "copyWith(" -- test/ops_home_test.dart test/golden/h01_golden_test.dart; echo "EXIT:$?"
echo "## H29 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/ops_home_test.dart test/golden/h01_golden_test.dart; echo "EXIT:$?"
echo "## H30 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## H31 precondition marks (pre)"; git grep -c "// pre$" -- test/ops_home_test.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(드라이런 실측) — H01 = 주석 줄 말고 출력 없음 · H02 = 출력 없음 · H03 = 2줄(h01_golden 1 · ops_home_test 12) · H04 = 0 ·
   S05 = 10줄(블록 1 · 2 · 3 · 7 · 3b · 4 · 6 · 8 행 · 8 더 보기 · 9b — 파일 줄 차례(3b·4·6·8·9b 는 아래 private 조각이라 7 뒤에 나온다) · 줄마다 탭 콜백 안) ·
   H06 = 6줄 · H07 = 0 · H08 = 8줄(m5BlockBoard 2 · opsRhythm 3 · adviceInbox · holdingsAllocation · ledgerDiffs) · H09 = 6줄(ⓑ 1 · ⓕ 3(dart format 이 any 를 세 줄로) · ⓒ 1 · ⓔ 1) · H10 = 15줄(생명주기 5 · UiLevel 5 × 2 — 9b _levelColor · 🆕 v1.13 칸 _cellLook · 재드라이런 실측) ·
   H11 = «lib/l10n/labels.dart:31»(🔴 정확히 — R13a 25 + R13b 6 · 줄머리 셈이라 예시 주석은 셈 밖) · H12 = 6줄(l10n/labels.dart · src/ops_home.dart · src/ops_rhythm.dart · src/routing/shell_router.dart · src/shell_providers.dart · src/shell_scaffold.dart 순) ·
   H13 = 14줄(R13a 병합본 9줄 — 2026-10-27 실측 · 줄 머리 final Provider<…> · final StateProvider<int> · final StreamProvider<FeatureFlags> + R13b 5줄 · 끝 5줄 = 위 «주입 구조» 차례 · 🔵 2026-10-27 정정 C4s-30 — 옛 패턴 ^final shell 은 R13a 병합본에서 0줄(타입 붙은 꼴)이라 패턴을 바꿨다 · R13b 절을 타입 없이 쓰면 9줄만 나온다 = 꼴이 카드와 다름) · H14~H17 = 0 · H18 = «test/ops_home_test.dart:11» · H19 = «test/ops_home_test.dart:3»(🔴 정확히 — 다르면 반려) ·
   H20 = 이름 21 = 위 «Key 표» 그대로(같은 이름이 갈래마다 두 번 나와도 된다 · 표 밖 0) · H21~H25 = 0 · H26 = 네 줄(labels.dart · shell_providers.dart · ui_shell.dart · shell_fakes.dart — 둘째 수 0 · ui_shell.dart 첫째 수 1 · v1.12 드라이런 8/0 · 32/0 · 1/0 · 201/0 → 재드라이런 8/0 · 37/0 · 1/0 · 201/0(shell_providers +5 = 타입 붙은 꼴 · v1.13 도우미는 ops_home.dart 안)) · 그 밖 파일 줄 없음 ·
   H27 = 2줄(test/shell_fakes.dart 의 FakeShellAlertRepository · FakeShellOpsStatusRepository) · H28 = 3줄(h01_golden_test 의 none · ops_home_test 의 none · viewer — 2종) · H29 = 0 · H30 = 16줄 전부 «A»(h01_* 만) ·
   H31 = «test/ops_home_test.dart:17»(= 최소 목록의 (전제) 수 · 🔴 정확히))
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다)
  (🆕 이번 기대 — 위 «(줄의 뜻과 기대(드라이런 실측) …)» 묶음(원 카드 405~412행) 보다 이 줄이 이긴다: 31줄의 출력 = C4 수정안 시험 재실행과 같은 179줄(EXIT 줄 31 포함 · warning: 줄 0) ·
   1회차 출력과 다른 곳은 아래뿐이다 — 수는 전부 1회차 그대로(🔴 정확히 셋 H11 31 · H18 11 · H19 3 · H31 17 포함):
   · S05 의 ops_home.dart 줄 번호 «290 · 324 · 411 · 465 · 503 · 525 · 580» → «291 · 327 · 416 · 470 · 508 · 530 · 585»(207 · 233 · 261 은 그대로) · H08 도 같은 꼴(앞 여섯 수만 · 207 · 261 은 그대로) ·
   · H09 «284 · 319 · 557 · 559 · 560» → «285 · 320 · 562 · 564 · 565»(253 은 그대로) · H10 의 UiLevel 열 줄 «616~620 · 624~628» → «621~625 · 629~633»(생명주기 77 · 84~87 은 그대로) ·
   · H13 14줄의 차례 — 9번째 줄이 «lib/src/shell_providers.dart:88:final StreamProvider<FeatureFlags> shellFlagsProvider =» 가 되고 끝 5줄 = R13b 주입 5줄(113 · 120 · 127 · 134 · 141 — C4h-7) ·
   · H20 의 h01-advice 부터 끝까지 12줄 «288 · 322 · 352 · 385 · 409 · 440 · 463 · 492 · 501 · 523 · 567 · 578» → «289 · 325 · 357 · 390 · 414 · 445 · 468 · 497 · 506 · 528 · 572 · 583» ·
   · H26 «219	0	packages/ui_shell/test/shell_fakes.dart» → «218	0	…»(C4h-8 — 나머지 세 줄 8/0 · 37/0 · 1/0 그대로) · H28 «test/golden/h01_golden_test.dart:66:» → «…:68:» ·
   · 나머지 줄(H01~H04 · H06 · H07 · H11 · H12 · H14~H19 · H21~H25 · H27 · H29 · H30 · H31)은 1회차와 글자 같다.
   🔴 H11·H18·H19·H31 이 31 · 11 · 3 · 17 과 다르거나 H13 끝 5줄이 R13b 주입 5줄이 아니면 제출하지 말고 상자를 다시 본다 · 그 밖의 줄이 이와 다르면 멈춘 뒤 채팅으로)

■ 테스트 수 묶음 — packages/ui_shell 에서 세 줄(조각 15 와 조각 21 의 끝 줄은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다 · 파일로 떠서 붙인다)
  flutter test test/ops_home_test.dart              ← 끝 줄 «+35: All tests passed!» 기대(1회차와 같음 — 상자 32~46 은 testWidgets·경우 수를 바꾸지 않는다)
  flutter test test/golden/h01_golden_test.dart     ← «+16: All tests passed!» 기대(1회차와 같음 · 🔴 --update-goldens 없이 — 방금 찍은 PNG 와 대조)
  flutter test                                      ← 끝 줄 «+117: All tests passed!» 기대(1회차와 같음 — C4 시험 «00:08 +117»)
  PowerShell 에서 파일로 뜨는 꼴(예 — 이름은 아무것이나 · 저장소 밖):
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    flutter test test/ops_home_test.dart | Out-File -Encoding utf8 $env:TEMP\r13b_t_ops.txt
    Get-Content -Encoding UTF8 $env:TEMP\r13b_t_ops.txt | Select-Object -Last 1   ← 이 줄을 그대로 복사(나머지 둘도 같은 꼴로 r13b_t_gold.txt · r13b_t_all.txt)
  (수가 +35 · +16 · +117 과 다르면 제출하지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로 — 상자의 수를 맞추려 고쳐 쓰지 않는다 · 골든이 실패하면 PNG 를 다시 찍지 않고 멈춘다.)

■ 제출
  (상자 1~47 · PNG 다시 찍기 · «테스트 수 묶음» 이 기대와 같은 뒤 · packages/ui_shell 에서)
  cd ../..
  melos.bat run format:fix
  git status --short   ← 위 «■ PNG 다시 찍기» 의 22줄과 같은 파일들(이제 저장소 뿌리 기준 경로 — docs/ai-context/inbox/H01_questions.md · packages/ui_shell/…) · 더 바뀐 파일이 있으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
  git add packages/ui_shell/lib/src/ops_home.dart packages/ui_shell/lib/src/shell_providers.dart packages/ui_shell/test/shell_fakes.dart packages/ui_shell/test/golden/h01_golden_test.dart packages/ui_shell/test/ops_home_test.dart docs/ai-context/inbox/H01_questions.md "packages/ui_shell/test/golden/goldens/h01_*.png"
     ← 한 줄 · 마지막 경로는 큰따옴표째(별표는 git 이 풀어 16장을 고른다 · Git Bash·PowerShell 같음) · 🔴 git add . 금지
  git status --short   ← 22줄 모두 «M  …»(왼쪽 칸 M · 오른쪽 칸 빈칸) · 오른쪽 칸 M 이나 ?? 가 있으면 커밋하지 말고 멈춘 뒤 채팅으로
  git commit -m "[M8] R13b (8) C4 반려 수정 — 골든 높이 1120 · 흐름 클로저 · 경우 칸 · if 감추기 제거 · 경미 4"   ← 위 «커밋 제목» 상자 글자 그대로
  bash tool/check_boundaries.sh   ← 실패 0 · ui_shell 의 🟡 [C-5] 0 · 🔵 main 에 원래 있는 ui_journal 1건(«packages/ui_journal/lib/src/timeline.dart:109»)은 이 재제출과 무관 — 그대로 둔다
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+389 ~30: All tests passed!»(계약 1.13.0 그대로) ·
     출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed(🔴 백그라운드·파이프 금지 · && 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git diff --stat HEAD~1   ← 마지막 줄 « 22 files changed, 433 insertions(+), 215 deletions(-)»(PNG 16 은 «Bin …» 줄)
  git -c core.quotePath=false diff --name-status 81d9ace HEAD
     ← 재제출 커밋의 변경만 봅니다. 🔴 정확히 이 22줄이어야 합니다:
        M	docs/ai-context/inbox/H01_questions.md
        M	packages/ui_shell/lib/src/ops_home.dart
        M	packages/ui_shell/lib/src/shell_providers.dart
        M	packages/ui_shell/test/golden/goldens/h01_advice_open_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_advice_open_light.png
        M	packages/ui_shell/test/golden/goldens/h01_advice_suppressed_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_advice_suppressed_light.png
        M	packages/ui_shell/test/golden/goldens/h01_advice_zero_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_advice_zero_light.png
        M	packages/ui_shell/test/golden/goldens/h01_blocked_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_blocked_light.png
        M	packages/ui_shell/test/golden/goldens/h01_normal_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_normal_light.png
        M	packages/ui_shell/test/golden/goldens/h01_recon_diff_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_recon_diff_light.png
        M	packages/ui_shell/test/golden/goldens/h01_resume_gap7_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_resume_gap7_light.png
        M	packages/ui_shell/test/golden/goldens/h01_self_audit_due_dark.png
        M	packages/ui_shell/test/golden/goldens/h01_self_audit_due_light.png
        M	packages/ui_shell/test/golden/h01_golden_test.dart
        M	packages/ui_shell/test/ops_home_test.dart
        M	packages/ui_shell/test/shell_fakes.dart
        다른 줄이 한 줄이라도 나오면(s01_*·h02_* PNG · labels.dart · 그 밖의 파일) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git log --oneline -2   ← 맨 위 = 재제출 커밋 · 그 아래 = 81d9ace [M8] R13b (7) H25 주석 수정 · format(지난 커밋은 그대로)
  사전검사 ① 코드만(저장소 뿌리에서 · 1회차 카드 461~463행과 같은 명령 · 출력은 채팅에 붙이지 않는다 — C4 가 같은 줄을 다시 돌린다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 첫 줄 «── 사전검사 · head <재제출 커밋> · 공통 조상 4206274» · 끝 줄 «── 결과: 🔴 0 · 🟡 0 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)»(C4 시험).
        🔴 가 하나라도 나오면 푸시하지 않고 고치지도 않는다 — 출력 전부를 채팅으로(이 글의 상자대로면 0 이다 · 다른 꼴로 감추는 고침 = 반려 · 1회차 C4h-2 가 바로 그것이다).
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push origin ui/m8-h01-home   (같은 브랜치 → PR #74 자동 반영 · 새 PR·라벨·강제 푸시(--force · --force-with-lease)·rebase·main 병합 금지)
  아래 출력은 푸시한 그 커밋 위에서 · git status 가 빈 채로 · 1회차 출력을 쓰지 않는다 · 전부 파일로 떠서:
   git -c core.quotePath=false diff --name-status origin/main...HEAD   ← 조각 3(기대 = 1회차와 같은 24줄 · 고친 여섯 파일·PNG 16 은 1회차부터 A·M 이라 줄이 늘지 않는다 · 첫 줄 «M	docs/ai-context/inbox/H01_questions.md» · 끝 줄 «M	packages/ui_shell/test/shell_fakes.dart» · 다르면 멈춘 뒤 채팅으로)
   git log --oneline origin/main..HEAD         ← 조각 5(8줄 · 맨 위 = 재제출 커밋 · 그 아래 7줄 = 1회차 그대로 «81d9ace [M8] R13b (7) H25 주석 수정 · format» … «d6dc617 [M8] R13b (1) 정적 라벨 · 주입» · 다르면 멈춤)
   cd packages/ui_shell → 위 «정적 묶음» 31줄 → 조각 11 → 위 «테스트 수 묶음» 세 줄 → 조각 15 · 조각 21 → cd ../..
   git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/H01_questions.md | Out-File -Encoding utf8 $env:TEMP\r13b_q.txt   ← 저장소 뿌리에서
   Select-String -Path $env:TEMP\r13b_q.txt -Pattern '^\+\|' -Encoding UTF8 | ForEach-Object { $_.Line }   ← 조각 19(«+|» 로 시작하는 줄 전부 · 9줄 · 손으로 만들지 않는다)
  git status --short   ← 🔴 다시 비어 있어야 합니다(명령이 파일을 바꾸었으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다.

■ 보고 글 — ①~⑤ 전체판 (12 §3 재제출 조문 «전체판 + 바뀔 자리만 상자»)
  🔴 채팅 글 = 아래 조각 1~21 을 이 차례로 이은 것뿐입니다. 조각은 세 갈래입니다:
     [상자] = 복사 상자 글자 그대로(한 글자도 바꾸지 않는다 — 바뀌지 않는 자리는 1회차 Bob 글자를 그대로 옮긴 상자 · 바뀌는 자리는 C4 가 준 상자) ·
     [출력] = 위 «■ 제출» 에서 다시 돌린 명령 출력을 파일로 떠서 그대로(줄을 고르거나 줄이거나 고쳐 쓰지 않는다) · [틀] = 상자 글자 그대로 두고 <…> 자리에만 출력.
  🔴 상자와 출력 밖에는 아무 글도 짓지 않습니다 — 머리말(«모든 확인 완료 …» · «재제출 글입니다» · «이제 제출 글을 작성합니다») · 구분선 --- · 요약 · 설명 · 까닭 줄 · 끝인사 0.
     기대와 다른 출력이 나오면 글로 설명하지 말고 제출을 멈춘 뒤 채팅으로 출력을 보입니다(위 «■ 제출» 의 멈춤 줄).
  🔴 첫 줄 = 조각 1 의 첫 줄 «## ① 구현한 화면 ID · 바뀐 파일 · 커밋»(1회차 카드 477행 N1) · 조각 사이에는 빈 줄 하나를 둔다(빈 줄은 대조에서 뺀다) · 상자 머리·끝 줄(┌── · └──)은 붙이지 않는다.
  🔴 «코드 블록 하나로» = 위아래에 백틱 세 개 줄을 두른다(1회차 글과 같은 꼴) · «코드 블록 없이» = 줄만 그대로 · 조각마다 둘 중 하나를 적어 두었다.
  🔴 PNG 는 열지 않는다 — 골든 표(조각 17)는 통합 담당이 맞춘 글자다(카드 5열 = 이름 · 입력 픽스처 · 크기 · 위치 전제 dy · 배치·잘림 · 배치·잘림 칸 = C4 가 1회차 PNG 를 열어 센 글자 · 크기·dy = C4 가 다시 찍은 판 · dark 행 = light 칸 글자 그대로).
  조각 1 [상자 · 바뀌지 않는 자리 · ① 섹션 머리 + 화면 ID 한 줄] — 코드 블록 없이
      ┌── 조각 1 복사 시작(다음 줄부터 · 2줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
화면 ID: H-01 — 운영 홈(OpsHome())
      └── 조각 1 복사 끝(이 줄 앞까지)
  조각 2 [상자] — 코드 블록 없이
      ┌── 조각 2 복사 시작(다음 줄부터 · 1줄)
바뀐 파일:
      └── 조각 2 복사 끝(이 줄 앞까지)
  조각 3 [출력] 위 «■ 제출» 의 git -c core.quotePath=false diff --name-status origin/main...HEAD 출력 그대로 — 코드 블록 하나로
      (기대 24줄 = 1회차와 같음 · 첫 줄 «M	docs/ai-context/inbox/H01_questions.md» · 끝 줄 «M	packages/ui_shell/test/shell_fakes.dart»)
  조각 4 [상자] — 코드 블록 없이
      ┌── 조각 4 복사 시작(다음 줄부터 · 1줄)
커밋 목록:
      └── 조각 4 복사 끝(이 줄 앞까지)
  조각 5 [출력 · 바뀌는 자리] 위 «■ 제출» 의 git log --oneline origin/main..HEAD 출력 8줄 그대로 — 코드 블록 하나로
      (맨 위 = 재제출 커밋 «<해시> [M8] R13b (8) C4 반려 수정 — 골든 높이 1120 · 흐름 클로저 · 경우 칸 · if 감추기 제거 · 경미 4» · 그 아래 7줄 = 1회차 그대로 «81d9ace [M8] R13b (7) H25 주석 수정 · format» … «d6dc617 [M8] R13b (1) 정적 라벨 · 주입»)
  조각 6 [상자 · 바뀌지 않는 자리 · ② 섹션 머리] — 코드 블록 없이
      ┌── 조각 6 복사 시작(다음 줄부터 · 1줄)
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
      └── 조각 6 복사 끝(이 줄 앞까지)
  조각 7 [상자 · 바뀌지 않는 자리 · 자체 점검 10항 10줄(1회차 괄호까지 · 다시 채우지 않는다)] — 코드 블록 없이
      ┌── 조각 7 복사 시작(다음 줄부터 · 10줄)
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 H14 — 허용 밖 import 0줄 · pubspec·analysis_options 무변경(H26))
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] (산술 = 신선도 한 식 + 규칙 5 의 식(H09 6줄)뿐 · 건수·D+n·D-day·편차 0 · 금지 수치 H16 0건 · 소수·% 리터럴 H17 0건)
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] (DateTime.now 0(H07) · 시계 = shellClockProvider 주입 · 오래됨 = T01-09(today_stale) · 신선 = T01-01)
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] (이 카드 범위 밖(5탭 = R13a) · 홈 손익·금액 0(H07 · T01-05))
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] (이 카드 범위 밖(알림 센터 = R14) · 홈은 알림을 읽지 않는다(H07 watchInbox 0))
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] (이 카드 범위 밖(DND = R14))
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] (이 카드 범위 밖(W-01 = R15~R16))
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] (이 카드 범위 밖(시크릿 입력 0))
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] (이 카드 범위 밖(온보딩 = R15))
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] (삽입 자리 직접 구현 0 · 블록 1·3 = 보드 링크만(T01-03) · 킬스위치 0(H07))
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
  조각 11 [출력] 위 «정적 묶음» 31줄의 출력 전부 — 코드 블록 하나로
      (줄이지 않는다 · 빈 줄도 지우지 않는다 · warning: 줄이 나오면 지우지 않고 그대로 · 기대 = 위 «🆕 이번 기대»(179줄 · 1회차와 다른 곳 = 줄 번호 · H13 차례 · H26 shell_fakes · H28 줄 번호))
  조각 12 [상자 · 바뀌는 자리 · C4h-15 · S05 결과(1회차에 없음 → 카드 517행 꼴)] — 코드 블록 없이
      🔴 둘째 줄부터 열 줄은 조각 11 의 S05 출력(경로·줄 번호 · 같은 차례)과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 멈춘 뒤 채팅으로(lib 가 상자 밖에서 바뀌었다).
      ┌── 조각 12 복사 시작(다음 줄부터 · 11줄)
S05 결과:
lib/src/ops_home.dart:207 — 탭 콜백 안
lib/src/ops_home.dart:233 — 탭 콜백 안
lib/src/ops_home.dart:261 — 탭 콜백 안
lib/src/ops_home.dart:291 — 탭 콜백 안
lib/src/ops_home.dart:327 — 탭 콜백 안
lib/src/ops_home.dart:416 — 탭 콜백 안
lib/src/ops_home.dart:470 — 탭 콜백 안
lib/src/ops_home.dart:508 — 탭 콜백 안
lib/src/ops_home.dart:530 — 탭 콜백 안
lib/src/ops_home.dart:585 — 탭 콜백 안
      └── 조각 12 복사 끝(이 줄 앞까지)
  조각 13 [상자 · 바뀌는 자리 · C4h-15 · ⓡⓗ(카드 519~524행 꼴)] — 코드 블록 없이
      🔴 둘째 줄은 조각 11 의 H18 출력 줄, 넷째 줄은 H19 출력 줄과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 멈춘 뒤 채팅으로(상자가 다르게 옮겨졌다).
      ┌── 조각 13 복사 시작(다음 줄부터 · 4줄)
ⓡ = H18 출력:
test/ops_home_test.dart:11
ⓗ = H19 출력:
test/ops_home_test.dart:3
      └── 조각 13 복사 끝(이 줄 앞까지)
  조각 14 [상자 · 바뀌는 자리 · C4h-15] — 코드 블록 없이
      ┌── 조각 14 복사 시작(다음 줄부터 · 1줄)
테스트 파일별:
      └── 조각 14 복사 끝(이 줄 앞까지)
  조각 15 [출력 · 바뀌는 자리 · C4h-15] 위 «테스트 수 묶음» 의 두 파일 끝 줄 그대로 2줄(ops_home_test · h01_golden_test 순) — 코드 블록 없이
      (기대 «+35» · «+16» — 줄 머리 경과 시각은 출력 그대로)
  조각 16 [상자 · 바뀌는 자리 · C4h-12 · ③ 섹션 머리 + 스크린샷 서술 3줄(카드 526~530행 꼴 · 코드 차례 그대로 — C4 가 코드로 맞춘 글자)] — 코드 블록 없이
      ┌── 조각 16 복사 시작(다음 줄부터 · 4줄)
## ③ 스크린샷 서술 · 골든 표
H-01 «로딩» = ShellSkeleton(Key('h01-loading'))
H-01 «정상» = ListView → Key('h01-asof') → ShellStaleBanner(있을 때) → Key('h01-status') → Key('h01-resume')(있을 때) → Key('h01-blocked')(있을 때) → Key('h01-advice')(있을 때) → Key('h01-alloc') → ValueKey<String>('h01-sleeve-$i') → Key('h01-process') → Key('h01-recon') → ValueKey<String>('h01-cell-$i') → Key('h01-today') → Key('h01-upcoming') → ValueKey<String>('h01-up-$i') → Key('h01-more') → Key('h01-audit')(있을 때) → Key('h01-audit-action')(있을 때)
H-01 «에러» = ShellErrorView(Key('h01-fail'))
      └── 조각 16 복사 끝(이 줄 앞까지)
  조각 17 [상자 · 바뀌는 자리 · C4h-10 · C4h-11 · ③ 골든 표 머리 2줄 + 16행(카드 5열 · 배치·잘림 칸 = C4 · 크기·dy = C4 가 다시 찍은 판)] — 코드 블록 없이
      ┌── 조각 17 복사 시작(다음 줄부터 · 18줄)
| 이름 | 입력 픽스처 | 크기 | 위치 전제 dy | 배치·잘림 |
|---|---|---|---|---|
| h01_normal light | m8/ops_home_normal.json | 390×1120 | 952.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_normal dark | m8/ops_home_normal.json | 390×1120 | 952.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_blocked light | m8/ops_home_blocked.json | 390×1120 | 1020.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 2 → 글자 줄 17 → 글자 줄 3 → 글자 줄 8(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_blocked dark | m8/ops_home_blocked.json | 390×1120 | 1020.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 2 → 글자 줄 17 → 글자 줄 3 → 글자 줄 8(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_resume_gap7 light | m8/ops_home_resume_gap7.json | 390×1120 | 1000.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 2 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_resume_gap7 dark | m8/ops_home_resume_gap7.json | 390×1120 | 1000.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 2 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_recon_diff light | m8/ops_home_normal.json | 390×1120 | 972.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 8(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_recon_diff dark | m8/ops_home_normal.json | 390×1120 | 972.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 8(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_advice_open light | m8/ops_home_advice_open.json | 390×1120 | 1020.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 3 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_advice_open dark | m8/ops_home_advice_open.json | 390×1120 | 1020.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 3 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_advice_zero light | m8/ops_home_advice_zero.json | 390×1120 | 952.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_advice_zero dark | m8/ops_home_advice_zero.json | 390×1120 | 952.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_advice_suppressed light | m8/ops_home_advice_zero.json | 390×1120 | 980.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_advice_suppressed dark | m8/ops_home_advice_zero.json | 390×1120 | 980.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 — 잘림 없음 |
| h01_self_audit_due light | m8/ops_home_normal.json | 390×1120 | 1104.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 → 배경 덩어리(글자 줄 3 · 버튼 글자 1) — 잘림 없음 |
| h01_self_audit_due dark | m8/ops_home_normal.json | 390×1120 | 1104.0 | 글자 줄 1 → 글자 줄 1 → 글자 줄 17 → 글자 줄 3 → 글자 줄 7(칸 줄 다섯마다 앞에 작은 네모 표식 하나) → 글자 줄 2 → 글자 줄 10 → 버튼 글자 1 → 배경 덩어리(글자 줄 3 · 버튼 글자 1) — 잘림 없음 |
      └── 조각 17 복사 끝(이 줄 앞까지)
  조각 18 [상자] — 코드 블록 없이
      ┌── 조각 18 복사 시작(다음 줄부터 · 1줄)
## ④ 질문 목록
      └── 조각 18 복사 끝(이 줄 앞까지)
  조각 19 [출력 · 바뀌는 자리 · C4h-13 · ④] 위 «■ 제출» 의 질문 파일 diff 에서 «+|» 로 시작하는 줄 전부 9줄 그대로 — 코드 블록 하나로
      (기대 = 상자 47 «이 줄로» 의 둘째~열째 줄(A1~A9) 앞에 «+» 하나를 붙인 글자 · 첫 줄 «+| A1 | R13b-Bob-H01 | 추측 | 측정: h01_normal dy 실측값 (light=952.0, dark=952.0) < 1120 | …» · 끝 줄 «+| A9 | R13b-Bob-H01 | 추측 | 측정: 여백 축소(12 §3 골든 높이 조문 · 높이 1120 그대로) — …» · 다르면 멈춘 뒤 채팅으로)
  조각 20 [상자 · 바뀌는 자리 · C4h-14 · ⑤(새 A 행이 전부 «측정:» 이라 «없음»)] — 코드 블록 없이
      ┌── 조각 20 복사 시작(다음 줄부터 · 2줄)
## ⑤ 추측한 것 목록
없음
      └── 조각 20 복사 끝(이 줄 앞까지)
  조각 21 [틀 · 바뀌는 자리 · C4h-15 · 끝 줄] — 코드 블록 없이
      <…> 자리에만 위 «테스트 수 묶음» 의 flutter test(전체) 끝 줄 그대로(시각·«+수»·«All tests passed!» 까지 · «끝 117» 처럼 수만 쓰지 않는다 · «시작 기준 66» 은 1회차 글자 그대로 · 117 = 66 + 51 이라 «까닭:» 줄 없음)
      ┌── 조각 21 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 66 → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 조각 21 복사 끝(이 줄 앞까지)
■ 내기 전 자기 확인 — 사전검사 ② (1회차 카드 478~480행 글자 그대로 · 이번 기대는 그 아래 «🆕 이번 기대» 가 이긴다)
  제출 글 전체 = 조각 1~21 을 이은 글(①~⑤ + flutter test 한 줄) · $env:TEMP 에 쓸 수 없으면 저장소 뿌리의 build\R13b-Bob-H01_submit.md(커밋하지 않는다) — 아래 세 줄은 1회차 카드 478~480행 글자 그대로:
      🔴 N3 — 내기 전 사전검사 ② — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R13b-Bob-H01_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R13b-Bob-H01_submit.md --golden-prefix h01_ --goldens 16
        ← 🔴 0 이어야 채팅에 낸다 · 출력은 채팅에 붙이지 않는다 · 🔵 🟡 [G1] 은 멈춤이 아니다(재드라이런 = 🟡 0 — 셈 단위대로 칸 앞 아이콘을 글자 줄 괄호 안 «작은 네모 표식» 으로 쓴 글 · «상자» 로 쓰면 🟡 16) — 표는 이 카드의 셈 단위대로.
  🆕 이번 기대(위 480행의 «재드라이런 = 🟡 0» 은 카드 저자 드라이런 판의 셈 · 이번은 C4 상자라 아래가 맞다):
     끝 줄 «── 결과: 🔴 0 · 🟡 16 — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)» 이어야 채팅에 낸다(출력은 채팅에 붙이지 않는다).
     🟡 16 = 골든 표 16행마다 [G1] «골든 표 ↔ PNG 셈» 하나 — 기계 셈이 8이름 모두 C4 칸보다 5줄 적게 센다(예 normal «글자 42줄» ↔ PNG «글자 37줄» · 셈 단위 차이로 보이며 원인은 확정하지 않았다 · 멈춤 아님).
     🔴 끝 줄의 «🟡 는 PNG·글을 다시 보고 판단» 은 이번에는 따르지 않는다 — PNG 0장 · 조각 17 은 통합 담당이 맞춘 상자다 · 🟡 를 없애려고 상자를 고쳐 쓰지 않는다.
     🔴 가 나오거나 🟡 의 수가 16 과 다르면 상자를 다시 옮긴다(조각을 빠뜨렸거나 글자가 바뀐 것) · 그래도 다르면 멈춘 뒤 채팅으로.
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m8-h01-home` 에 추가 커밋 **1개**: `[M8] R13b (8) C4 반려 수정 — 골든 높이 1120 · 흐름 클로저 · 경우 칸 · if 감추기 제거 · 경미 4`. main 병합 커밋 **없음** · 지난 7개 커밋 **그대로**(`git log --oneline origin/main..HEAD` = 8줄 · 맨 위 = 재제출 커밋 · 아래 7줄 = 1회차 글자).
- 파일 수정 6(lib 2 · test 3 · 질문 1) — 상자 1~47 자리뿐(합 +433/−215 · C4 시험 diff `judge/fix.diff` 와 같은 글자 — 통합 담당이 `git diff 81d9ace HEAD` 를 그 diff 와, 트리의 파일을 C4 수정안 파일(blob `e9bb4df` · `3c831ef` · `35c3fe9` · `2abe8f9` · `807cd1e` · `a49d3f3`)과 대조한다) + `h01_*` PNG 16 M(C4 판 blob 16과 대조 · 다르면 띠 모양 대조) — `git diff --name-status 81d9ace HEAD` = 22줄.
- `s01_*`·`h02_*` PNG · labels · 배럴 · 셸 파일 · 그 밖의 테스트 변경 0.
- `ui_shell` `flutter test` **117**(파일별 +35 · +16 — 1회차와 같음 · 카드 539행 «M = N + 51» = 66 + 51 · 까닭 줄 없음이 정답) · 정적 31줄 출력 = C4 수정안 출력과 같은 글자(1회차와 다른 곳 = S05·H08·H09·H10·H20 줄 번호 · H13 차례 · H26 shell_fakes 218/0 · H28 줄 번호) · 사전검사 ① 🔴 0 · 🟡 0.
- 채팅: 보고 글 ①~⑤ **전체판** = 조각 1~21(상자 15 · 출력 5 · 틀 1) — 첫 줄 `## ① 구현한 화면 ID · 바뀐 파일 · 커밋` · 섹션 머리 5줄(1회차와 같은 글자) · 조각 3 name-status 24줄 · 조각 5 git log 8줄 · 조각 11 정적 31줄 출력 전부 · 조각 12·13 S05·ⓡⓗ 상자 · 조각 15 테스트 파일별 2줄 · 조각 16 ③ 서술 3줄 · 조각 17 골든 표 16행(C4 상자) · 조각 19 ④ «+|» 9줄 · 조각 20 ⑤ «없음» · 조각 21 끝 줄 · 그 밖은 1회차 글자 상자 그대로 · 상자·출력 밖 글 0 · 사전검사 ② 🔴 0 · 🟡 16(G1).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R13b-Bob-H01 재제출: PR #74 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 채팅 글(①~⑤ 전체판 — 첫 줄 `## ①` 부터 끝 줄 `flutter test: …` 까지)을 붙여넣습니다(Claude 가 PR #74 본문을 이 글로 통째로 바꿉니다). 0단계·«먼저 할 것»·«고친 뒤 확인»·«■ PNG 다시 찍기»·«■ 제출» 에서 멈췄다면 `R13b-Bob-H01 재제출 0단계에서 멈춤 — 확인해줘`(멈춘 자리 이름으로) + Bob 이 보여 준 출력. Bob 이 상자 밖 글(머리말·요약·까닭 줄)을 더해 냈다면 그대로 붙여넣되 «상자 밖 글 있음» 이라고 함께 알립니다(통합 담당이 strict 나눔으로 가른다). Bob 이 PNG 를 열었거나 두 번 찍었거나 «크기·dy 확인» 을 돌렸다면 그 사실도 함께 알립니다.

## 5. 주의

- **5분 눈 검사**(PR #74 «Commits» · «Files changed» — `81d9ace` 뒤 커밋만 보면 된다): ① 커밋 수가 8 이 아님 · 지난 7개 해시가 바뀜(강제 푸시·rebase 흔적) · `Merge … origin/main` 커밋 ② 여섯 파일 + `h01_*` PNG 16 밖의 변경(`labels.dart` · `ui_shell.dart` · 셸 파일 · 다른 테스트 · `pubspec.yaml` · `domain_contracts/**`) ③ `s01_*`·`h02_*` PNG 변경 ④ `h01_golden_test.dart` 에 `Size(390, 1300)` · `ops_home.dart` 에 `vertical: 12` · `!)` · `ops_home_test.dart` 에 `name ==` · `which ==` · `data.isEmpty ||` · `opener.opened[` · `shell_fakes.dart` 에 `actionDeepLink` 가 남음 ⑤ 채팅 글 조각 17 이 상자와 다름 · 첫 줄 위의 섹션 밖 글 · 상자 밖 글 — 하나라도 있으면 반려 신호(⑤ 는 strict 나눔 ① 표기만이면 C4 정정 대상).
- CI: 3/3 기대 — `golden:approved` 는 붙이지 않는다(«골든 스냅샷» 잡 = `git diff --name-status BASE...HEAD` 세 점 · `h01_*` 16장은 `main` 에 없어 A 만 → «신규 추가만 있다 — 허용» · 2026-10-27 Claude 가 `.github/workflows/ci.yml` 52~99행으로 확인). «분석 · 테스트(melos)» 는 Bob 의 푸시로 그 시점 `main`(이 기록 커밋 포함) 위의 병합 미리보기를 다시 돈다 — 기록 커밋은 문서뿐이라 수는 C4 시험과 같은 것이 기대.
- C4 가 2회차에서 볼 것(C4 보고 §0 · §5-A): 기계 = `81d9ace..HEAD` 6파일 M + PNG 16 M · hunk 가 상자 1~47 자리뿐(`judge/fix.diff` 와 글자 대조 · 트리의 파일 = C4 수정안 **blob 6개**(`e9bb4df` · `3c831ef` · `35c3fe9` · `2abe8f9` · `807cd1e` · `a49d3f3`) · PNG = **blob 16개**(`git ls-tree 24d8984` · C4 보고 §5-A — 다르면 `bands.py` 띠 모양 대조 · dy 재실측)) · 지난 7개 해시 불변 · 전체 +117 · analyze · format · 사전검사 ①② · CI / 변이 = 카드 예고 64꼴 + 참고 24 + 탐침 3 재실행(탐침 P1~P3 이 이제 잡혀야 함 · 약해진 꼴 0) / 정직 = 전체판의 [상자] 조각은 이 패킷 상자 글자와(바뀌지 않는 자리 = 1회차 Bob 글자 · 조각 12·13·16·17·20 = C4 상자 · 조각 21 = 틀) · [출력] 조각(3·5·11·15·19 · 21 의 끝 자리)은 재실행 출력과 글자 대조(테스트 끝 줄의 줄 머리 경과 시각(mm:ss)은 대조에서 뺀다) · 상자·출력 밖 글 0 · N1·N3 다시. 판정 기준 = 1회차 카드 strict 나눔(카드 148행 · ① 표기만 = C4 정정 · ② 코드·테스트·거짓 = 반려 · ③ 예고 변이 = 반려).
  - 대조 기준 = blob 6 + PNG blob 16 — scratchpad `judge/new/` · `judge/png_fix/` 의 파일은 이 blob 들과 같다(2026-10-27 확인) · `judge/fix.diff` 는 저장소 뿌리에서 `git apply` 로 적용한다.
  - 정직성 대조의 바이트 기준 = 이 패킷 조각 1~21 + 재실행 출력 — C4 미리보기 `judge/resubmit_preview.md` 는 커밋 제목(«… 골든 높이 1120(여백만) · …»)·조각 경계(빈 줄)가 이 패킷과 다른 **조립 전 판**이라 🟡 수 확인에만 쓴다 · C4 보고 §5-A 의 커밋 제목(«… 골든 높이 1120(여백만) · …»)·정적 묶음 범위(«:371~404»)도 조립 전 판 — 제목은 이 패킷 «커밋» 상자 · 범위는 371~413행이 이긴다.
  - 엔진 E8a PR #73 은 이 카드 병합 뒤(발주자 결정 ②) — 2회차 C4 의 합친 트리 = 그 시점 `main`(1.13.0) · E8a 와 합친 시험(+117 · +392 ~30)은 1회차 C4 §10 에 있다.
- 병합 뒤 할 일(Claude · C4 보고 §6 · §7-M): 질문 파일 A1~A9 답 칸(앞 6칸 = 재제출 Bob 글자 그대로 · §6 초안) · 머리말 «다음 번호 = Q1·A10» · golden README «🆕 R13» 절 ✅·R13b 병합본 실측 줄(16장 · 높이 1120 · dy 952~1104) · `packages/ui_shell/README.md` 지금 상태 · PR 본문 «C4 정정» 한 곳(C4h-16 커밋 (6)(7) · 커밋은 고치지 않음) · 1회차 본문 댓글 보존 · 패킷 이동은 이 재제출 패킷 `send/R13b-Bob-H01-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · 🏁 R13 2장 완료 · 다음 = 엔진 E8a PR #73 병합 차례 · 2회차 보고 보존본 `10_리뷰/<날짜>_R13b_C4_2회차_보고.md`.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R13b 패킷은 이 파일 하나입니다. 원 패킷 `R13b-Bob-H01.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 한다).
- 범위 밖: C4 보고 §8 의 보강 후보 C4r13b-1~7 은 설계 12 §3 «R13b C4 이월 부록» 에 적었다 — 다음 카드 조립 때 · 이 재제출에는 넣지 않는다(이 재제출은 위 상자 1~47 · PNG 다시 찍기 1줄 · «커밋» 상자 1개 그대로 · 조각 12·13·16·17·20 상자는 C4h-10~15 표기 정정이지 카드 조문 개정이 아니다).
