# 발송 패킷 R12a-Bob-S76ab — 재제출 (1회차 반려 · 2026-10-13)

> ⬜ **「푸시해」 뒤 보냄** — 이 파일이 GitHub `main` 의 `send/` 에 있으면 이 조건은 풀린 것(이 패킷과 원 패킷의 `send/_완료/` 이동이 `main` 에 올라간 뒤 · 다른 선행 = PR #26 반려 댓글 게시(통합 담당) · 아래 «보내는 조건» · `send/README.md` 배지 규칙).
> 만든 날 2026-10-13 · 1회차(PR #26 · 브랜치 `ui/m7-s76ab-rebalance` · 커밋 `34dab77` · 밑동 `20056b0` · 커밋 6)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-13): ① **(A) 반려 → 재제출**(보고 글만 · 커밋 0 · HEAD `34dab77` 그대로 · 같은 PR #26 · 2회차 C4 = 정직 대조) ② 재제출 범위 = **F1~F6 한정**(테스트 보강 후보 N2~N5 는 넣지 않는다 · R11b 선례) ③ 다음 카드 보고 상자 보강 N1·N7·N8·N9 는 `send/_대기/` 의 R12b~R12d 세 장에 넣는다(이 패킷 몫 아님). 규칙·범위(S7-6a 타임라인 + S7-6b 회차 상세)는 1회차 카드(`send/_완료/R12a-Bob-S76ab.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 F1~F6** 만 담았습니다.
> 고치는 것 = **채팅 제출 글 ①~⑤ 새 판 하나뿐**입니다 — 새 커밋·amend·rebase·cherry-pick·reset·push 0 · `lib/**` 0 · 테스트 0 · PNG 0 · 질문 파일 `inbox/S7-6ab_questions.md` 0(A1~A6 행·머리말 그대로 · 답은 병합 때 통합 담당) · PR 본문·라벨 0(통합 담당이 새 제출 글로 PR #26 본문을 통째로 바꾼다 · 12 §3:230). 같은 브랜치 `ui/m7-s76ab-rebalance` · 같은 PR #26(새 PR·새 브랜치 금지).
> 판정 근거 = C4 보고 §0 · §4(설계 저장소 `10_리뷰/2026-10-13_R12a_C4_보고.md`) — 1회차 카드 보고 규칙(158~161행) strict 나눔 ② «**거짓 주장**(보고 ≠ 코드·파일·PNG) = **반려**(재량 없음)» · 163행 «골든 표는 PNG 를 열어 픽스처와 대조한 «배치·잘림»만(글자는 테스트 글꼴이라 네모)» · 669행 «배치·잘림 = PNG 를 열어 본 것만». [가] 1건: **C12a-1** ③ 골든 표 `s76b_advisory_light` 배치·잘림 칸 «하단 버튼 글자 길이만 다름» ↔ PNG 는 `s76b_band_light` 와 바이트까지 같고(dark 쌍도 같음) 두 라벨은 길이도 같다(11자) — PNG 에 없는 차이를 PNG 를 본 결과로 적었다(strict 나눔 뒤 첫 «거짓 주장» 적용). [나] 5건(C12a-2~6 · 표기만 — 새 판이라 함께 맞춘다): S31 출력 줄임 · dy 까닭 누락 · ④ 질문 표 없음·⑤ 줄인 표 · 골든 표 «크기» 칸 없음·«(펼쳤을 때)» · «끝 354»·ⓡⓗ 두 줄. 합격(그대로): lib · 테스트 · 새 PNG 12 · 질문 파일 · `flutter test` 304 → 354 · 예고 변이 30/30 · CI 3/3.
> 🔴 **패킷에 기대 해시를 적지 않습니다**(C4 보고 §4 F1) — F1 의 `git hash-object` 4줄은 Bob 이 직접 돌린 출력을 그대로 붙이고, 통합 담당이 같은 명령으로 대조합니다.
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기를 돌린다(R11a·R11b 재제출 선례). 이번 재제출은 푸시가 없으므로 CI 는 1회차(3/3) 그대로다.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R12a-Bob-S76ab.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R12a 행·재제출 행 · `rounds.md` R12a 행·재제출 행과 **같은 푸시**로 `main` 에 올린다(0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/S7-6ab_questions.md` · golden README · `send/_대기/` 의 R12a squash 자리표시자 · 01~05 사본은 건드리지 않는다(병합 때).
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R12a-Bob-S76ab.md` 는 `send/` 에 없음). 확인 = `git cat-file -t origin/main:docs/ai-context/send/R12a-Bob-S76ab-재제출.md`(= `blob`) · 다른 선행 = PR #26 «Conversation» 에 C4 반려 댓글(«C4 병합 검사 1회차: 반려, 재제출 요청 …» — 통합 담당이 게시)이 있다 · 그 밖의 선행(infra PR 등)은 없다.
> 2회차 C4(head `34dab77` · CI 그대로면 정직 대조만): F1 해시 4줄을 같은 명령으로 대조 · F2 정적 39줄을 재실행 출력과 글자로 대조(S31 포함 · 빈 줄·EXIT·warning·PowerShell 장식 줄 말고) · 머리 첫 줄·F2 문장·F3·F4·F6 은 복사 상자 글자와 · F5 는 그 지시와 대조 · 나머지는 1회차 글자와 diff. 시험 적용 없음(커밋 0 · 보고 글만 — 기대 출력의 근거 = C4 1회차 갈래 M·H 의 재실행 출력).

## 0. 한 줄 목적

PR #26 의 제출 글 ①~⑤ 를 F1~F6 대로 고친 **새 판 전체**를 채팅으로 다시 내기 — **커밋·코드·테스트·PNG·질문 파일은 한 글자도 바꾸지 않고, 명령만 다시 돌린다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s76ab-rebalance` · 같은 PR #26.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). PR #26 에 C4 반려 댓글(«C4 병합 검사 1회차: 반려, 재제출 요청 …»)이 올라가 있는지도 봅니다(통합 담당이 게시 — 없으면 보내기 전에 통합 담당에게 알립니다).
2. Bob 은 **1회차와 같은 대화여도 됩니다**(브랜치·HEAD 그대로 · 1회차 카드의 «(6) 뒤 커밋 0» 과 충돌 없음 · C4 보고 §4). 같은 대화면 1회차 제출 글이 대화에 남아 있어 «바뀌지 않는 곳은 1회차 글자 그대로» 를 지키기 쉽습니다. 새 대화로 시작한다면 1회차 제출 글 원문(PR #26 본문 <https://github.com/billybeom/AutoAlphaQuant/pull/26> 의 맨 위 «R12a 제출 글(①~⑤)입니다 …» 부터 «⑤ 추측한 것 목록» 표 끝까지 — 끝의 대행 고지 줄은 빼고)을 아래 «3» 본문 뒤에 함께 붙여 줍니다.
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12a-Bob-S76ab-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R12a-Bob-S76ab-재제출.md` · 가지 `rec/r12-cards` · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R12a-Bob-S76ab.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ```text 다음 줄(«R12a-Bob-S76ab 재제출 요청»)부터 닫는 ``` 직전 줄까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12a 패킷은 **이것 하나**(`R12a-Bob-S76ab-재제출.md`)입니다. 원 패킷 `R12a-Bob-S76ab.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` · `_완료/R10c-Bob-S72-재제출.md` · `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드이고, `send/_대기/` 의 `R12b-Bob-S76c.md` · `R12c-Bob-S77.md` · `R12d-Bob-S710.md` 는 아직 보내지 않는 카드입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12a-Bob-S76ab 재제출 요청»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12a-Bob-S76ab 재제출 요청 — 1회차(PR #26 · 34dab77) 판정: 반려(재제출). 같은 브랜치 ui/m7-s76ab-rebalance · 같은 PR #26 · 🔴 커밋 0 —
이번에 고치는 것은 채팅 제출 글(①~⑤ 새 판 전체)뿐입니다. lib·테스트·PNG·질문 파일·docs 를 한 글자도 바꾸지 않고, 명령만 다시 돌립니다.
🔴 새 커밋·amend·rebase·cherry-pick·reset·stash·push·강제 푸시 0 · git status 는 처음부터 끝까지 빈 채 — 하나라도 바뀌면 반려입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12a 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner · ui/m7-s79-goal-path)는 건드리지 않습니다(로컬 삭제도 안 함).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지) — 이번에는 푸시도 없습니다.
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m7-s76ab-rebalance 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m7-s76ab-rebalance
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git rev-parse --short HEAD    ← 34dab77 이면 정상 · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m7-s76ab-rebalance   ← 34dab77 · 다르면 멈추고 출력을 채팅으로
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R12a-Bob-S76ab-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R12a-Bob-S76ab.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 · _대기 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R12a-Bob-S76ab-» 로 시작하는 줄이 있으면 정상.
        «R12a-Bob-S76ab-재제출» 줄이 없거나 꼬리 없는 «R12a-Bob-S76ab.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 카드가 먼저 왔습니다.
  ls docs/ai-context/send/R12a-Bob-S76ab.md   ← 보여야 함(이 브랜치에는 1회차 카드가 있다 — 아래 «규칙 요약» 이 가리키는 파일 · 읽기만)
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
🔴 이 카드와 1회차 카드(R12a-Bob-S76ab.md)의 글이 다르면 이 카드가 이깁니다 — 예: 커밋 0 · 푸시 0 · 질문 파일을 고치지 않는다 · 골든을 다시 찍지도 dy 를 다시 재지도 않는다 ·
   제출 글 ①~⑤ 의 글자는 이 카드 «■ 고칠 것» · «■ 제출» 대로 · 바뀌지 않는 곳은 1회차 제출 글 글자 그대로.

■ 규칙 요약 (1회차 카드 = 이 브랜치의 docs/ai-context/send/R12a-Bob-S76ab.md(main 에서는 send/_완료/ 로 옮겨졌다 — 글자는 같다)의 보고 규칙(158~169행) · 정적 묶음(502~555행) · 테스트 수 묶음(557~561행) · 제출(595~672행)이 유효 —
   단 이 카드와 다른 곳은 이 카드가 이긴다 · 특히 ② 에 붙이는 차례·꼴은 이 카드 «■ 제출» 의 ② 가 이긴다 · 여기엔 핵심만)
· 이번에 고치는 곳 = 채팅 제출 글 ①~⑤ 뿐(F1~F6). 🔴 고치면 반려: 저장소의 파일 전부 — packages/**(lib · test · PNG · 골든 테스트 · 하네스) · docs/ai-context/**(질문 파일 S7-6ab_questions.md 포함) · pubspec.yaml.
  🔴 git status 에 M·??·D 가 하나라도 보이면 git checkout -- <그 파일>(?? 는 지우지 말고 그대로) 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 🆕 규칙 한 줄(F1 — 이번 반려 사유에서 나온 것): 배치·잘림 칸에는 PNG 에서 보이는 것만 쓴다 — 글자 내용·글자 길이의 차이는 테스트 글꼴 네모로 보이지 않으므로 쓰지 않는다(픽스처 설명을 PNG 서술로 옮기지 않는다).
  🔴 이번 재제출에서 이 규칙으로 고치는 칸은 advisory 두 행(F1 상자)뿐이다 — 다른 10행의 배치 칸은 C4 1회차가 사실로 판정했으므로 1회차 글자 그대로 둔다(s76a_empty 두 행의 «「다음 예상」 버튼» 포함) ·
     F1 상자 안의 픽스처 언급(«주문»↔«기록»)은 C4 가 준 글자라 예외다(상자 글자 그대로 붙인다).
· 보고 규칙(1회차 카드 158~161행 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당(C4)이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음) · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 섹션 머리 ①~⑤ 는 아래 «■ 제출» 상자 글자 그대로).
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 카드가 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다 — «화면» 배치 S7-6a 1~5 · S7-6b 1~10 · 규칙 1~18 · Key 표 12종(표 밖 s76a-·s76b- Key 0) · 공용 3파일 끝 절 더하기만(S27 8/0 · 25/0 · 2/0) · 배럴 정렬 자리 ·
  providers 표식 글자 · autoDispose 2 · watchEvents() 인자 0 · 새 lib 파일 2 · lib/src/rebalance/ 없음 · Card() 기본 고도 · 배지 색 tertiaryContainer/onTertiaryContainer · 아이콘 두 모양 고정.
테스트는 최소 목록 단언이 모두 있었습니다 — ⓡ·ⓗ 정확히 10·8 / 3·7 · C4b-12·13·14 반영 · else 없는 if 0 · 한국어 리터럴 0 · ASCII 이름.
flutter test 304 → 354(+15 · +23 · +12) · analyze --fatal-infos No issues · format 0 changed · C-42 +14(대상 2파일 · 24줄) · 새 PNG 12장(390×960) · 기존 64장 그대로 · dy 12값 = C4 재실측 · CI 3/3.
카드가 예고한 변이 30항목은 전부 잡혔습니다.
보고에서 맞은 곳 — ① name-status 22줄 · 커밋 6줄 · ② 12항 15줄(괄호 12개 = 카드 글자) · 15줄 명령 출력 · 정적 S01~S30 · S05a·S05b 5줄 · 테스트 수 묶음 4줄 ·
  ③ 로딩·정상·빈·차단 서술(코드 순서) · 골든 표의 나머지 11칸(입력 픽스처 · dy · 배치·잘림) · ⑤ «없음» · 질문 파일 A1~A6(«측정:» · ⬜ 미답 · 답 칸 비움 · 값 = 재실측).

■ 왜 반려인가 — 카드 / 보고 글 / 실제 (C4 검사 갈래 셋이 따로 같은 사실을 냈고, 통합 담당이 git blob · 바이트 비교(cmp) · PNG 열람 · 픽스처로 다시 확인)
① ③ 골든 표 s76b_advisory_light 의 «배치·잘림» 칸 (C12a-1 · 거짓 주장)
   카드:  보고 규칙 160행 «거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음)» · 163행 «골든 표는 PNG 를 열어 픽스처와 대조한 «배치·잘림»만(글자는 테스트 글꼴이라 네모)» ·
          669행 «배치·잘림 = PNG 를 열어 본 것만(… 못 본 것은 «미열람»)».
   보고:  «band와 같은 배치. 하단 버튼 글자 길이만 다름».
   실제:  s76b_advisory_light.png 는 s76b_band_light.png 와 바이트까지 같다(git hash-object 가 같다 — dark 쌍도 같다). 두 픽스처의 차이는 하단 버튼 글자 하나이고,
          «이 회차의 주문 2건» 과 «이 회차의 기록 2건» 은 길이도 같다(11자). 테스트 글꼴은 글자를 같은 크기의 네모로 그리므로 PNG 에는 차이가 나타나지 않는다.
          PNG 에 없는 차이를 PNG 를 본 결과로 적었다 — 내용이 사실과 다르므로 «표기만»(①)이 아니라 «거짓 주장»(②)이다. 앞 절 «band와 같은 배치» 와 dark 행 «light와 같은 배치» 는 참이다.
   (결함을 감춘 것은 아니다 — 코드·테스트·PNG 는 맞고 실효 손실은 0 이다. 고칠 것은 보고 글 한 칸이다.)
함께 고칠 것(표기만 — 새 판이라 함께 맞춘다): C12a-2 S31 출력 줄임 · C12a-3 dy 까닭 누락 · C12a-4 ④ 질문 표 없음·⑤ 줄인 표 · C12a-5 골든 표 «크기» 칸 없음·«(펼쳤을 때)» · C12a-6 «끝 354»·ⓡⓗ 두 줄.
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·테스트·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 생성물은 git 에 없습니다(안 하면 S31 dart test · flutter test 에서 «타입 없음·필드 없음» 가짜 오류 · 생성물은 git 이 무시하므로 git status 는 빈 채).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  git status --short   ← 여전히 비어 있어야 합니다(아니면 멈추고 채팅으로)
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·커밋·푸시는 하지 않습니다):
   · docs/ai-context/send/R12a-Bob-S76ab.md(1회차 카드 — 이 브랜치에 있다) — 158~169행 «보고 규칙» · 502~561행 «정적 묶음» · «테스트 수 묶음» · 595~672행 «제출»
   · 1회차 제출 글(같은 대화면 대화 안의 «R12a 제출 글(①~⑤)입니다 …» · 새 대화면 발주자가 이 본문 뒤에 붙여 준 글) — 바뀌지 않는 곳은 이 글자 그대로 옮긴다
   · docs/ai-context/inbox/S7-6ab_questions.md(F4 의 ④ 를 대조하려면 꼭 — 고치지는 않는다)

■ 고칠 것 — F1~F6 (1회차 반려 · C4 2026-10-13) — 🔴 커밋 0 · 채팅 제출 글만 고친다(F1 = 반려 사유 · F2~F6 = 표기 · 새 판이라 함께 맞춘다)
   제출 글 = 새 판 전체 ①~⑤(섹션 머리 다섯 줄 글자 그대로 · 통합 담당이 PR 본문을 통째로 바꾼다 · Bob 은 PR 본문을 GitHub 에서 고치지 않는다 — 12 §3:230).
   바뀌지 않는 곳은 1회차 글자 그대로 둔다(①, ② 12항, S01~S30, S05, ③ 의 S7-6a 4줄, 골든 표의 다른 10행 배치 칸).
   머리 첫 줄 = 아래 상자 글자 그대로 한 줄. 1회차 머리말(«R12a 제출 글(①~⑤)입니다. 푸시한 …» 부터 «… PR과 라벨도 없습니다.» 까지 한 줄)은 지우고 이 한 줄로 바꾼다 · 그 아래 «---» 구분선은 1회차처럼 둔다:
      ┌── 머리 첫 줄 복사 시작(다음 줄부터 · 1줄)
R12a 재제출 글(①~⑤)입니다 — 커밋 0 · HEAD `34dab77` 그대로 · git status 빈 채로 명령만 다시 돌렸습니다.
      └── 머리 첫 줄 복사 끝(이 줄 앞까지)

F1 (C12a-1 · [가] 거짓 주장) — ③ 골든 표 advisory 두 행.
   1. 저장소 루트에서 네 줄을 한 줄씩 돌린다:
      ┌── F1 명령(네 줄)
git hash-object packages/ui_analytics/test/golden/goldens/s76b_band_light.png
git hash-object packages/ui_analytics/test/golden/goldens/s76b_advisory_light.png
git hash-object packages/ui_analytics/test/golden/goldens/s76b_band_dark.png
git hash-object packages/ui_analytics/test/golden/goldens/s76b_advisory_dark.png
      └──
      출력 4줄을 골든 표 바로 아래에 코드 블록으로 그대로 붙인다(C4 가 같은 명령으로 대조한다 · 패킷에는 기대 해시를 적지 않는다).
   2. s76b_band_light.png 와 s76b_advisory_light.png 를 나란히 연다. 해시가 쌍마다 같고 그림도 같으면 두 행의 배치·잘림 칸을 아래 글자로 바꾼다. 해시나 그림이 다르면 제출하지 말고 멈춘 뒤 채팅으로 알린다.
      ┌── F1 두 행 복사 시작(다음 줄부터 · 2줄)
| `s76b_advisory_light` | `m7/m7_rebalance_detail_advisory.json` | 390×960 | 884 | band 와 PNG 바이트 동일(표 아래 git hash-object 가 s76b_band_light 와 같음) — 배치는 band 와 같다 · 하단 버튼 글자는 픽스처에서 «주문»↔«기록» 만 다르고 글자 수가 같아 테스트 글꼴(네모)로는 구별되지 않는다 · 잘림 없음 |
| `s76b_advisory_dark` | `m7/m7_rebalance_detail_advisory.json` | 390×960 | 884 | light와 같은 배치 · s76b_band_dark 와 PNG 바이트 동일(표 아래 git hash-object) |
      └── F1 두 행 복사 끝(이 줄 앞까지)
   3. 규칙 한 줄(위 «■ 규칙 요약» 에 넣었다): «배치·잘림 칸에는 PNG 에서 보이는 것만 쓴다 — 글자 내용·글자 길이의 차이는 테스트 글꼴 네모로 보이지 않으므로 쓰지 않는다(픽스처 설명을 PNG 서술로 옮기지 않는다)».
      이번에 이 규칙으로 고치는 칸은 advisory 두 행뿐이다(다른 10행은 1회차 글자 그대로 · 이 상자의 픽스처 언급은 예외 — 위 «■ 규칙 요약»).

F2 (C12a-2 · [나] 표기) — ② 정적 묶음.
   · 카드 509~547행 39줄을 packages/ui_analytics 에서 다시 돌린다(아래 «■ 정적 묶음» 에 같은 39줄을 옮겨 두었다 — «테스트 수 묶음» 과 함께 1회차 카드 502~561행과 글자 같음). 출력 **전부**를 코드 블록 하나로 붙인다.
     S31 의 «loading» 줄 · +1~+13 제목 전문 · ⑪ 양성 40줄을 **줄이지 않는다**(줄 수가 많아도 그대로).
   · 🔴 S31 은 한국어 제목이 많다(C4 가 글자로 대조한다) — 한국어가 깨져 보이면 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 을 실행한 뒤 39줄을 다시 돌린다 · 깨진 글자를 그대로 붙이지 않는다.
   · 1회차의 «주의 두 가지가 있습니다.» 아래 첫 글머리표(«- 위 S31 블록은 길어서 … 줄였습니다 …» 한 줄)는 지운다. 머리 줄은 «주의 한 가지가 있습니다.» 로 바꾸고, 둘째 글머리표(«- S17·S18·S18b는 …» 한 줄)는 1회차 글자 그대로 둔다(통합 담당 보충).
   · 1회차 ② 의 안내 문장 «정적 묶음 39줄 출력. 빈 줄은 뺐고, S17·S18·S18b의 git 경고 장식 줄은 지우지 않았습니다.» 는 아래 상자 글자로 바꾼다 — 빈 줄도 지우지 않는다(C4 는 대조에서 빈 줄을 뺀다):
      ┌── F2 문장 복사 시작(다음 줄부터 · 1줄)
정적 묶음 39줄 출력 전부입니다. 빈 줄도, S17·S18·S18b의 git 경고 장식 줄도 지우지 않았습니다.
      └── F2 문장 복사 끝(이 줄 앞까지)
   · (S01~S30 은 lib·테스트가 그대로라 1회차와 같은 글자가 나와야 한다 — 빈 줄·EXIT 표기·warning 줄·PowerShell 장식 줄 말고 다르면 제출하지 말고 멈춘 뒤 채팅으로.)

F3 (C12a-3 · [나] 까닭 누락) — ③ 골든 표 아래(F1 해시 블록 다음)에 한 줄을 붙인다(글자 그대로):
      ┌── F3 복사 시작(다음 줄부터 · 1줄)
dy 가 카드 드라이런과 다른 이름 = s76a_empty 112(드라이런 120) · s76b_band 884(892) · s76b_advisory 884(892) — 까닭: 간격 재량(카드 «간격(SizedBox 높이)·글자 굵기·Card 모서리는 재량») · S7-6a 빈 상태의 «다음 예상» 버튼 앞과 S7-6b 일지 버튼 앞에 SizedBox(height: 8) 를 두지 않았다(각 8 작다) · 나머지 세 이름은 드라이런과 같다.
      └── F3 복사 끝(이 줄 앞까지)
   🔴 붙이기 전에(읽기만) 두 화면 파일을 연다 — lib/src/screens/rebalance_timeline_screen.dart 의 빈 상태 Text(page.emptyLabel) 와 s76a-empty-next TextButton 사이,
      lib/src/screens/rebalance_event_screen.dart 의 s76b-link-journalTimelineLink TextButton 바로 앞에 SizedBox 가 없어야 한다(있으면 제출하지 말고 멈춘 뒤 채팅으로 · 고치지 않는다).

F4 (C12a-4 · [나] 요지 줄임) — ④ · ⑤ 를 아래로 바꾼다:
      ┌── F4 복사 시작(다음 줄부터)
## ④ 질문 목록

Q 행 없음. 새 행 = A1~A6(전부 «측정:» — 질문 파일 «질문·추측» 칸 글자 그대로):

| 번호 | 요지 |
|---|---|
| A1 | 측정: s76a_list dy 실측값 (light=848, dark=848 < 960) |
| A2 | 측정: s76a_empty dy 실측값 (light=112, dark=112 < 960) · 카드 드라이런 실측 120 과 8 다름 |
| A3 | 측정: s76a_sim dy 실측값 (light=324, dark=324 < 960) |
| A4 | 측정: s76b_band dy 실측값 (light=884, dark=884 < 960) · 카드 드라이런 실측 892 와 8 다름 |
| A5 | 측정: s76b_seasonal dy 실측값 (light=692, dark=692 < 960) |
| A6 | 측정: s76b_advisory dy 실측값 (light=884, dark=884 < 960) · 카드 드라이런 실측 892 와 8 다름 |

## ⑤ 추측한 것 목록

없음
      └── F4 복사 끝(이 줄 앞까지)
   (질문 파일은 고치지 않는다 — A2·A4·A6 의 덧말은 C4 가 병합 기록 때 그대로 두고 닫는다 · C12a-9.)
   🔴 대조(저장소 뿌리에서 · 읽기만): git grep -n "측정:" -- docs/ai-context/inbox/S7-6ab_questions.md   ← 6줄의 «질문·추측» 칸 글자가 상자의 요지 칸과 한 글자도 다르지 않아야 합니다
      (다르면 상자를 고쳐 쓰지 말고 멈춘 뒤 채팅으로 · 셸에서 한글이 깨져 보이면 편집기로 그 파일을 열어 대조합니다 — 고치지 않는다).

F5 (C12a-5 · [나] 표기) — ③:
   · 골든 표 머리를 | 이름 | 입력 픽스처 | 크기 | dy | 배치·잘림 (PNG 열람) | 로 바꾸고, 12행 모두 크기 칸에 390×960 을 넣는다. 다른 10행의 배치 칸은 1회차 글자 그대로 둔다. advisory 두 행은 F1 글자다.
     (구분줄은 칸 수에 맞춰 |---|---|---|---|---| 로 쓴다 — 통합 담당 보충)
   · S7-6b «정상» 줄에서 «요약 `Text` + `configHash` `Text` (펼쳤을 때)» 의 «(펼쳤을 때)» 만 «(있을 때)» 로 바꾼다 — 그 줄의 나머지(백틱 포함)는 1회차 글자 그대로(카드 663행 표기).

F6 (C12a-6 · [나] 표기 · 1회차 기록만 부류지만 새 판이므로 함께 맞춘다) — ② 끝 · 상자 둘을 두 자리에 나눠 붙인다(1회차와 같은 차례 = 원 카드 660행 차례 ⓡⓗ → 테스트 수 묶음 → 시작·끝):
   ㄱ. ⓡⓗ 한 줄 — S05b 결과 블록 바로 아래 · 1회차의 «ⓡ = S29 출력 · ⓗ = S30 출력:» 줄과 그 아래 ⓡ 줄(두 줄)을 지우고 그 자리에 이 한 줄을 둔다:
      ┌── F6 ⓡⓗ 복사 시작(다음 줄부터 · 1줄 · 상자 글자 그대로 — 앞머리 test/ 를 떼지 않는다)
ⓡ = S29 출력 · ⓗ = S30 출력 = test/rebalance_event_view_test.dart:10 · test/rebalance_timeline_view_test.dart:8 / test/rebalance_event_view_test.dart:3 · test/rebalance_timeline_view_test.dart:7
      └── F6 ⓡⓗ 복사 끝(이 줄 앞까지)
      🔴 F2 에서 다시 돌린 S29·S30 출력의 «파일:수» 네 줄이 이 상자와 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 멈춘 뒤 채팅으로.
   ㄴ. 그 아래 «테스트 수 묶음 끝 줄:» 머리 줄과 코드 블록 4줄 = 1회차 꼴 그대로 — 줄마다 «flutter test … →» 이름표는 1회차 글자 그대로 두고, «→» 뒤만 이번에 다시 돌린 끝 줄 그대로(시각 포함) 바꾼다
      (이름표는 1회차 꼴의 표 글자라 위 «앞머리를 붙이지 않는다» 의 예외 · → 뒤는 출력 그대로).
   ㄷ. 시작·끝 한 줄 — 그 코드 블록 바로 아래 · 1회차의 «시작 기준 304 → 끝 354» 줄을 지우고 그 자리에 이 한 줄을 둔다:
      ┌── F6 시작·끝 복사 시작(다음 줄부터 · 1줄 · <…> 자리에만 마지막 flutter test 끝 줄 그대로)
시작 기준 304 → 끝 <마지막 flutter test 끝 줄 그대로>
      └── F6 시작·끝 복사 끝(이 줄 앞까지)
   (수는 F2 에서 다시 돌린 S29·S30 · 테스트 수 묶음 출력 그대로 · 손으로 쓰지 않는다 — 통합 담당 보충)

■ 고치지 않는 것 (1회차가 맞았거나 이 카드 밖 — 손대면 반려)
 · 저장소 파일 전부 — lib/** · test/**(골든 테스트·가짜·뷰 테스트) · PNG 전부(--update-goldens 금지) · docs/ai-context/**(질문 파일 포함) · pubspec.yaml
 · 골든 dy — lib·골든 테스트·PNG 가 그대로라 다시 재지 않습니다(s76ab_golden_test.dart 를 열어 lessThan(0) 으로 바꾸는 일도 하지 않는다 · A1~A6 = 1회차 실측 = C4 재실측)
 · 질문 파일 docs/ai-context/inbox/S7-6ab_questions.md — A1~A6 행·머리말(«다음 번호» 포함)을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 닫는다)
 · 제출 글의 ① 전부 · ② 12항 15줄과 괄호 · 12항 줄 수 출력 · S05a·S05b 결과 5줄 · ③ S7-6a 4줄 · S7-6b 로딩·차단 줄 · 골든 표의 다른 10행 배치 칸 · ③ 끝 «dy는 이름·밝기마다 …» 문단 — 1회차 글자 그대로
 · 테스트 보강 후보(C4 보고 §7 N2~N5) — 이번에 넣지 않는다(범위 밖 · 발주자 결정 2026-10-13)

(읽는 법 — 아래 «■ 정적 묶음» · «■ 테스트 수 묶음» 두 절은 1회차 카드 502~561행 글자 그대로다. 이 재제출에서는 «PR 본문 ②» = 채팅 제출 글 ② · «PR 본문의 «시작 N → 끝 M»» = F6 ㄷ 줄 ·
  «위 «테스트 최소 목록»» = 1회차 카드의 그 절(S29·S30 기대값 = 39줄 아래 «(줄의 뜻과 기대 —» 괄호의 S29·S30 대목 = :10 · :8 / :3 · :7) · 대조에서 빼는 것 = 빈 줄 · EXIT 표기 · warning:·error: 줄 · PowerShell 장식 줄 ·
  한국어가 깨져 보이면 [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 돌린다(F2).)
■ 정적 묶음 — packages/ui_analytics 에서 아래 39줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 39줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  Windows PowerShell 5.1 이면 git 의 stderr 경고에 장식 줄(«git : warning: …» · «At line:…» · «+ CategoryInfo …» · «+ FullyQualifiedErrorId : NativeCommandError» · «+ … ~~~» 류)이 덧붙는다 — 지우지 않고 그대로 붙이고, 대조에서는 warning: 줄과 함께 뺀다.
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 · «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  S31 만 dart test 다(domain_contracts 폴더에서 C-42 한 파일 · 1분 안팎) — 출력 전부를 그대로 붙인다.
  🔴 블록 뒤에 S05a·S05b 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/rebalance_fakes.dart test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart test/golden/s76ab_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart test/golden/s76ab_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart test/golden/s76ab_golden_test.dart; echo "EXIT:$?"
echo "## S03 string processing 0 (S7-6 files)"; git grep -nP "\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S03b sort filter words 0 (S7-6 files)"; git grep -nP "\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|\breverse:\s*true\b" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes (S7-6a empty-state constant only)"; git grep -n "AppRoutes\." -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart lib/src/providers/analytics_providers.dart; echo "EXIT:$?"
echo "## S05a opener lines timeline (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/rebalance_timeline_screen.dart; echo "EXIT:$?"
echo "## S05b opener lines event (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState CommandApi 0 (S7-6 files)"; git grep -nE "CommandState|CommandApi" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 DateRange DateTime TradeDate 0 (S7-6 files)"; git grep -nE "DateRange|DateTime|TradeDate" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S14b mode axes 0 (S7-6 files)"; git grep -nE "operatingMode|OperatingMode|RunMode|runMode|FeatureFlags" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S15 autoDispose 6"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "rebalance/|goal_path/|chart/|explore/|planner|perf_chart|analytics_skeleton|analytics_error_view" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports 10"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired and old-draft names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint|ReviewSectionVm|changeWindowNoticeText|oathText|AsOfStamp|KeyValueVm" -- lib; echo "EXIT:$?"
echo "## S25 raw fields 0 (S7-6 files)"; git grep -nP "(?<!Labels)\.(weight|targetWeight|bandLow|bandHigh|rawValues|thresholdRegistered|triggerPrice|metricKey|orderIntentIds|mode|kind|hasMore|emptyKind|code|wire|sleeve|basis)\b|\.tradeDate\b(?!\.yyyyMmDd)|SleeveId\." -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S25b journalTimelineLink 0 (S7-6a file)"; git grep -n "journalTimelineLink" -- lib/src/screens/rebalance_timeline_screen.dart; echo "EXIT:$?"
echo "## S25c detailDeepLink 0 (S7-6b file)"; git grep -n "detailDeepLink" -- lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea 0 (S7-6 files)"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 keys (empty-next journal-link asof)"; git grep -n -e "s76a-empty-next" -e "s76b-link-journalTimelineLink" -e "s76b-asof" -- lib; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart; echo "EXIT:$?"
echo "## S31 C-42 role scan (domain_contracts)"; cd ../domain_contracts; dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded; echo "EXIT:$?"; cd ../ui_analytics
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) · S03·S03b = 문자열 가공·정렬·거르기 0(C-42 ⑨ 와 같은 낱말 · 주석도 센다) ·
   S04 = rebalance_timeline_screen.dart 의 AppRoutes.rebalancePreview 한 줄뿐(R12 화면의 고정 상수 = 이것 하나) · S05a = 3줄(행 InkWell onTap · s76a-empty-next onPressed · SafetyBlockBanner onOpenLink — 드라이런 62 · 78 · 162 · 줄 번호는 코드마다 다르다 · dart format 이 s76a-empty-next 콜백을 «ref» / «.read(analyticsLinkOpenerProvider)» / «.open(AppRoutes.rebalancePreview);» 로 나누면 그 줄은 «.read(analyticsLinkOpenerProvider)» 로 시작하는 줄로 찍힌다 — 정상(그 줄도 «— 탭 콜백 안» · S04 줄도 그 아래 «.open(…)» 줄로 찍힌다)) · S05b = 2줄(s76b-link-journalTimelineLink onPressed · SafetyBlockBanner onOpenLink — 드라이런 76 · 197) ·
   S05a·S05b 모두 build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) · S06~S12 = 출력 없음 · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0 ·
   S14·S14b = 두 화면 파일에 날짜 타입·모드 축 낱말 0(일자는 tradeDate.yyyyMmDd — 소문자 t 라 걸리지 않는다) · S15 = 대소문자 구분 · 6줄(기존 4 + rebalanceEventsProvider 1 + rebalanceEventProvider 1 · 드라이런 63 · 78 · 91 · 105 · 121 · 127) · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = export 10줄(rebalance_event_screen · rebalance_timeline_screen 은 performance_explore_screen 과 report_archive_screen 사이) · S17·S18·S18b = 옮긴 차트 파일 무변경 · S19~S23 = 출력 없음(12항 1·3·11항 근거 · S22·S23 = 계약 테스트 C-38 ⑫ 와 같은 정규식) ·
   S24 = 폐기·구 초안 이름 0 · S25 = C-42 ② 와 같은 원값 정규식(+ basis · SleeveId.) — 출력 0 · S25b·S25c = 링크 필드는 제 화면에서만 · S26 = 공개 위젯은 본문만(ScaffoldMessenger 포함) · S27 = 공용 파일의 «더하기만» — 세 줄 모두 둘째 수(삭제)가 0 · 첫째 수 = 드라이런 labels 8 · providers 25(주석·format 에 따라 다를 수 있다 — 기준은 둘째 수 0) · barrel 2(정확히) ·
   S28 = 3줄(Key 세 개가 각 한 번) · S29·S30 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 파일마다 정확히 같아야 한다 (S29 = rebalance_event_view_test.dart:10 · rebalance_timeline_view_test.dart:8 / S30 = :3 · :7 · 다르면 반려 — 규칙 12) ·
   S31 = 전부 통과 + 출력에 «C-42 ① 대상 S7-6a(R12a) 1파일» · «C-42 ① 대상 S7-6b(R12a) 1파일» · S7-6c·S7-7·S7-10 은 0파일 · «역할 대상 합 2파일 · providers R12 절 <N>줄»(드라이런 24 — 주석 줄 수에 따라 다를 수 있다))

■ 테스트 수 묶음 — packages/ui_analytics 에서 네 줄(PR 본문의 «시작 N → 끝 M» 과 테스트별 수 · «까닭» 은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다)
  flutter test test/rebalance_timeline_view_test.dart   ← 끝 줄 «+15: All tests passed!» 기대(드라이런 +15)
  flutter test test/rebalance_event_view_test.dart      ← «+23: All tests passed!» 기대(드라이런 +23)
  flutter test test/golden/s76ab_golden_test.dart       ← «+12: All tests passed!» 기대
  flutter test                                          ← 끝 줄 = «끝 M»(기대 M = N + 50)

■ 제출 (🔴 커밋·푸시 없음 — 명령만 다시 돌려 채팅으로 낸다)
  git status --short            ← 비어 있어야 합니다(아니면 멈춤)
  git rev-parse --short HEAD    ← 34dab77
  위 F1 의 git hash-object 네 줄(저장소 루트에서 · 한 줄씩)   ← 아래 ③ 골든 표 바로 아래에 그대로 붙일 출력
  cd packages/ui_analytics → 위 «정적 묶음» 39줄 → 위 «테스트 수 묶음» 4줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(git status 가 빈 채로 · 1회차 출력을 쓰지 않는다)
  git status --short            ← 🔴 다시 비어 있어야 합니다(명령이 파일을 바꾸었으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  git rev-parse --short HEAD    ← 34dab77 그대로(커밋이 생겼으면 멈추고 채팅으로 — 푸시하지 않는다)
  (① 의 git diff --name-status origin/main...HEAD 22줄 · git log --oneline origin/main..HEAD 6줄은 HEAD 가 같아 1회차 출력과 같다 — 1회차 글자 그대로 옮긴다)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다(golden:approved 포함) · git push 하지 않습니다.
  제출 글 = 채팅으로 — 맨 위에 머리 첫 줄(위 «■ 고칠 것» 머리의 상자 글자 그대로 한 줄 · 1회차 머리말은 지운다 · 그 아래 «---» 는 1회차처럼) ·
     그 아래 섹션 머리 다섯 줄을 **글자 그대로** 두고 그 아래를 채운다(통합 담당이 이 글로 PR #26 본문을 통째로 바꾼다 · 12 §3:230):
      ┌── 제출 글 머리(다섯 줄 · 글자 그대로)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └──
   ① = 1회차 글자 그대로(화면 줄 + name-status 22줄 + 커밋 6줄).
   ② = 12항 15줄 + 괄호 · «12항 줄 수 확인» 출력 = 1회차 글자 그대로 +
       안내 문장 = F2 문장 상자 + «정적 묶음 39줄 출력» = 이번에 다시 돌린 출력 전부를 코드 블록 하나로(F2 · S31 포함 줄이지 않는다 · 빈 줄도 지우지 않는다) + 주의 = F2 대로(머리 «주의 한 가지가 있습니다.» + S17·S18·S18b 글머리표) +
       S05a·S05b 결과 5줄 = 1회차 글자 그대로 + F6 ㄱ ⓡⓗ 한 줄 + F6 ㄴ «테스트 수 묶음 끝 줄:» 머리 줄과 4줄(1회차 꼴 · → 뒤만 이번 끝 줄) + F6 ㄷ 시작·끝 한 줄 — 이 차례로
       (1회차와 같은 차례 = 1회차 카드 ■ 제출 ② 의 ⓡⓗ 한 줄 → 테스트 수 묶음 4줄의 끝 줄 → 시작·끝 한 줄 차례).
   ③ = S7-6a 4줄 = 1회차 글자 그대로 · S7-6b 로딩·정상·차단 3줄 = 1회차 글자 그대로(정상 줄만 F5 «(있을 때)») ·
       «골든 표 12행.» 머리 문장 = 1회차 글자 그대로 + 골든 표(F5 머리 · 크기 칸 · 다른 10행 배치 칸 1회차 글자 · advisory 두 행 = F1 상자) +
       F1 해시 4줄(코드 블록) + F3 한 줄 + 1회차 «dy는 이름·밝기마다 …» 문단 글자 그대로 — 이 차례로.
   ④ · ⑤ = F4 상자 글자 그대로.
```

---

## 3-1. 받아야 하는 것

- 커밋 **0** · 푸시 **0** — PR #26 head = `34dab77` 그대로(`git log --oneline origin/main..origin/ui/m7-s76ab-rebalance` = 1회차 6줄) · CI = 1회차 3/3 그대로.
- 저장소 변경 0 — lib · 테스트 · PNG · 질문 파일 `S7-6ab_questions.md`(A1~A6 · 머리말) · docs 전부 1회차 그대로.
- 채팅: 제출 글 새 판 전체 — 머리 첫 줄(«R12a 재제출 글(①~⑤)입니다 — 커밋 0 …» 상자 글자 · 1회차 머리말 없음) + 섹션 머리 다섯 줄 글자 그대로 + ① 1회차 글자 · ② 12항·괄호·15줄 출력 1회차 글자 + F2 문장 + 정적 39줄 **새 출력 전부**(S31 줄임 없음 · «줄였습니다» 주의 없음) + S05 5줄 1회차 글자 + F6 ㄱ ⓡⓗ 한 줄(test/ 붙음) + 테스트 수 묶음 끝 줄 4줄(1회차 꼴) + F6 ㄷ 시작·끝 한 줄 · ③ S7-6a 4줄·S7-6b 3줄(«(있을 때)») + 골든 표 5칸(크기 390×960 · advisory 두 행 = F1 상자) + `git hash-object` 4줄 + F3 한 줄 · ④ F4 표 6행 · ⑤ «없음».
- 기대 출력(C4 1회차 갈래 M·H 의 재실행과 같아야 함): 정적 S01~S30 = 1회차와 같은 글자(빈 줄·EXIT·warning·PowerShell 장식 줄 말고) · S29 = `test/rebalance_event_view_test.dart:10` · `test/rebalance_timeline_view_test.dart:8` · S30 = `:3` · `:7` · S31 = C-42 +14 · «C-42 ① 역할 대상 합 2파일 · providers R12 절 24줄» · 테스트 수 묶음 끝 줄 +15 · +23 · +12 · +354 · `git hash-object` 4줄 = band 와 advisory 가 쌍마다 같음(해시 값은 이 패킷에 적지 않는다 — C4 가 같은 명령으로 대조).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12a-Bob-S76ab 재제출: 제출 글 받음(커밋 0 · PR #26 34dab77 그대로) — 병합 검사해줘
```

그 아래에 Bob 이 준 제출 글 새 판 ①~⑤ 를 붙여넣습니다(Claude 가 PR #26 본문을 이 새 판으로 통째로 바꿉니다). 0단계·«먼저 할 것»에서 멈췄다면 `R12a-Bob-S76ab 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력. Bob 이 커밋이나 푸시를 했다면 그대로 Claude 에게 알립니다(`R12a-Bob-S76ab 재제출: Bob 이 커밋/푸시함 — 확인해줘`).

## 5. 주의

- **5분 눈 검사**(PR #26 «Commits» · «Files changed»): ① 커밋 수가 6 이 아님 · 맨 위가 `34dab77` 이 아님(새 커밋·강제 푸시 흔적) ② 제출 글 ③ 골든 표에 «길이만 다름» 같은 글자 내용·길이 서술이 남음 · advisory 두 행이 F1 상자와 다름 · `git hash-object` 4줄이 없음 ③ ② 정적 묶음의 S31 블록에 «…»·«줄였습니다» 가 있음 ④ ④ 표가 없거나 요지가 «측정:» 으로 시작하지 않음 ⑤ 섹션 머리가 다섯 줄 글자와 다름 — 하나라도 있으면 Claude 에게 그대로 알립니다(② ③ 은 판정 대상 · 표기만이면 C4 정정).
- C4 가 2회차에서 볼 것: head `34dab77` · CI 3/3 그대로 · 커밋 0 · F1 해시 4줄 = 같은 명령의 출력 · advisory 두 행 = F1 상자 글자 · F2 정적 39줄 = 재실행 출력과 글자 대조(S31 포함 · 빈 줄·EXIT·warning·PowerShell 장식 줄 말고) · 머리 첫 줄 · F2 문장 · F3 · F4 · F6 ㄱ·ㄷ = 복사 상자 글자(F6 ㄱ 은 test/ 붙은 꼴 — 상자 = S29·S30 출력과 같은 글자) · F5 = 머리·크기 칸·«(있을 때)» · 나머지 = 1회차 글자와 diff · 질문 파일 불변. 판정 기준 = 1회차 카드 strict 나눔(① 표기만 = C4 정정 · ② 코드·테스트·거짓 = 반려 · ③ 예고 변이 = 1회차 결과 그대로).
- 병합 뒤 할 일(Claude · C4 보고 §5·§6-1): 질문 파일 A1~A6 답 칸 · 머리말 «다음 번호 = Q1·A7» · golden README 1행(76장)·병합본 실측 줄 · 패킷 이동은 이 재제출 패킷 `send/R12a-Bob-S76ab-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · `_대기/R12b-Bob-S76c.md` → `send/`(머리 «아직 보내지 않습니다» → ▶ · R12a squash 자리 채움) · 팩 판은 그다음 접미 · 2회차 보고 보존본 `10_리뷰/<날짜>_R12a_C4_2회차_보고.md`.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12a 패킷은 이 파일 하나입니다. 원 패킷 `R12a-Bob-S76ab.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 한다). `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` · `_완료/R10c-Bob-S72-재제출.md` · `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드입니다.
- 범위 밖(발주자 결정 2026-10-13): 테스트 보강 후보 N2~N5(빈 상태 Text 닫힌 집합 · 두 배너 순서 · 에러·로딩 루프 앞 isNotEmpty 전제 · 빈 봉투 + 오래됨)는 이 재제출에 넣지 않는다 · 보고 상자 보강 N1·N7·N8·N9 는 `send/_대기/` 의 R12b~R12d 에 넣었다(이 카드 몫 아님).
