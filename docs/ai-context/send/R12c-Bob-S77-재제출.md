# 발송 패킷 R12c-Bob-S77 — 재제출 (1회차 반려 · 2026-10-14)

> ⬜ **「푸시해」 뒤 보냄** — 이 파일이 GitHub `main` 의 `send/` 에 있으면 이 조건은 풀린 것(이 패킷과 원 패킷의 `send/_완료/` 이동이 `main` 에 올라간 뒤 · 다른 선행 없음 — PR #28 반려 댓글 게시됨(2026-10-14 · issuecomment-6163925931) · 아래 «보내는 조건» · `send/README.md` 배지 규칙).
> 만든 날 2026-10-14 · 1회차(PR #28 · 브랜치 `ui/m7-s77-annual` · 커밋 `6043119` · 밑동 `9067f8b` · 커밋 4 · CI 3/3 run 38528098648)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-14): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #28 · Bob 이 R1·R2 를 **test 1파일 커밋 1개**로 · 보고 글 = 부분 제출 P1~P4 · C12c-4(섹션 밖 머리말)는 C4 가 본문에서 정정 · lib 0 · PNG 0) ② 다음 카드 보강 C12c-N2(개수 단언 한 줄 견본)와 새 공통 조문 ③ 골든 높이 = 재량 + 기록 · ④ 커밋 = 제목만 맞추기는 `send/_대기/R12d-Bob-S710.md` 와 설계 12 §3 에 넣었다(이 패킷 몫 아님 — 이 재제출의 커밋은 아래 «커밋» 상자 1개로 정해져 있다). 규칙·범위(S7-7 12월 연간 리뷰)는 1회차 카드(`send/_완료/R12c-Bob-S77.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 R1·R2 + 보고 글 P1~P4** 만 담았습니다.
> 고치는 것 = **테스트 파일 하나**(`packages/ui_analytics/test/annual_review_view_test.dart` — 아래 R1·R2 의 «이 줄을 → 이 줄로» 그대로 · +16/−16) **+ 채팅 글 P1~P4(부분 제출)** — `lib/**` 0 · PNG 0 · 골든 테스트·가짜·질문 파일 `inbox/S7-7_questions.md` 0(A1~A5 행·머리말 그대로 · 답은 병합 때 통합 담당) · PR 본문·라벨 0(통합 담당이 1회차 PR 본문의 그 자리에 P1~P4 를 바꿔 넣는다). 같은 브랜치 `ui/m7-s77-annual` · 같은 PR #28(새 PR·새 브랜치 금지) · 커밋은 맨 위에 1개 · amend·rebase·cherry-pick·reset·강제 푸시 금지.
> 판정 근거 = C4 보고 §0 · §4(설계 저장소 `10_리뷰/2026-10-14_R12c_C4_보고.md`) — 1회차 카드 보고 규칙 strict 나눔 ② «코드·테스트 결함(카드 규칙 위반) = 반려(재량 없음)»(카드 195행). [가] 2건: **C12c-1** T77-14 의 «`'annual_review/'` 를 품은 export 0» 단언이 이미 걸러 낸 목록에 `any` 를 걸어 **늘 참**(6043119 798~805행 · 카드 145행 «늘 참인 단언 금지» · 476~478행) · **C12c-2** T77-12 ⓗ 가 dart format 뒤 **10줄**(6043119 655~664행 · 카드 155~156행 «dart format 뒤에도 한 줄 — 접히면 변수로 받아 줄을 짧게»). [나] 2건(C12c-3 골든 표 «파란 버튼» = 색 이름 → P3 로 고친다 · C12c-4 섹션 밖 머리말 → C4 정정) · 거짓 주장 0 · 예고 변이 29항목 56꼴 전부 잡힘. 합격(그대로): lib · 새 PNG 10 · 질문 파일 · `flutter test` 405 → 448 · 정적 37줄 출력 · CI 3/3.
> 🔴 **N2 조문 적용(12 §3 · 2026-10-14) = 부분 제출로 못박는다** — 이 재제출에서 Bob 은 «1회차 글자 그대로» 를 다시 쓰지 않는다. 바뀌는 자리 **P1~P4 만** 채팅으로 내고, 통합 담당(C4)이 1회차 PR #28 본문의 그 자리에 바꿔 넣는다. 1회차 글의 나머지(① 화면 ID·name-status 17줄 · ② 12항 15줄·괄호·세는 줄 · ③ «로딩»·«정상»·«첫 해»·«차단» 4줄 · 골든 표 머리·나머지 7행 · ④ · ⑤ «없음»)는 Bob 이 다시 내지 않는다(다시 내면 통합 담당은 그 글을 쓰지 않는다). P1~P4 의 글자는 명령 출력(파일로 떠서) 아니면 이 패킷의 복사 상자뿐이다.
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기를 돌린다(R11a·R11b·R12b 재제출 선례). Bob 의 푸시가 CI 를 다시 돌린다(새 PNG 만이라 «골든 스냅샷» 은 라벨 없이 초록이 정상).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R12c-Bob-S77.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R12c 행·재제출 행 · `rounds.md` R12c 행·재제출 행과 **같은 푸시**로 `main` 에 올린다(0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/S7-7_questions.md` · golden README · `send/_대기/` 의 `__R12C_SQ__`·⟦실측⟧ 자리 · 01~05 사본은 건드리지 않는다(병합 때).
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R12c-Bob-S77.md` 는 `send/` 에 없음). 확인 = `git cat-file -t origin/main:docs/ai-context/send/R12c-Bob-S77-재제출.md`(= `blob`) · PR #28 «Conversation» 에 C4 반려 댓글(«C4 병합 검사 — R12c-Bob-S77 1회차: 반려(재제출)»)이 있다(게시됨) · 그 밖의 선행(infra PR 등)은 없다.
> C4 수정안 시험(2026-10-14 · 통합 담당 worktree `C:/Work/AAQ-claude-c4cj` @ `6043119` · 끝에 삭제): 아래 R1·R2 와 같은 글자(+16/−16)를 넣고 `dart format --output=none --set-exit-if-changed .` «70 files (0 changed)» · `flutter analyze --fatal-infos` No issues found! · 뷰 `00:01 +33: All tests passed!` · `flutter test`(ui_analytics 전체) `00:21 +448: All tests passed!` · S29 13 · S30 6 · 한 줄 ⓗ 6 · 그 위에 참고 변이(배럴에 `annual_review/` 아래 경로의 export 한 줄)를 넣으면 `T77-14 file checks` 실패(잡힘 — 6043119 판에서는 뷰·골든·C-42 를 모두 통과). 안 돌린 것 = `melos.bat run test`(중첩 melos · CI 몫).

## 0. 한 줄 목적

PR #28 의 테스트 파일 하나를 R1·R2 글자대로 고쳐 커밋 1개로 올리고, 바뀌는 보고 자리 P1~P4 만 채팅으로 다시 내기 — **lib·PNG·골든 테스트·가짜·질문 파일은 한 글자도 바꾸지 않고, 지난 4개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s77-annual` · 같은 PR #28.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). PR #28 의 C4 반려 댓글은 이미 올라가 있습니다.
2. Bob 은 **1회차와 같은 대화여도 됩니다**(Bob 폴더가 지금 `ui/m7-s77-annual` `6043119` 입니다 · 1회차 카드의 «(4) 가 마지막 커밋» 은 이 카드가 덮습니다 — 아래 본문 0단계). 새 대화로 시작해도 됩니다 — 본문은 Bob 이 1회차를 기억하지 못한다는 전제로 썼고, 부분 제출이라 1회차 글을 다시 붙여 줄 필요가 없습니다.
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12c-Bob-S77-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R12c-Bob-S77-재제출.md` · 가지 `rec/r12-cards` · 2026-10-14 Claude 확인 · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R12c-Bob-S77.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ```text 다음 줄(«R12c-Bob-S77 재제출 요청»)부터 닫는 ``` 직전 줄까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12c 패킷은 **이것 하나**(`R12c-Bob-S77-재제출.md`)입니다. 원 패킷 `R12c-Bob-S77.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R12b-Bob-S76c-재제출.md` · `_완료/R12a-Bob-S76ab-재제출.md` · `_완료/R12a-Bob-S76ab-재제출2.md` · `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` 는 끝난 카드이고, `send/_대기/R12d-Bob-S710.md` 는 아직 보내지 않는 카드입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12c-Bob-S77 재제출 요청»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12c-Bob-S77 재제출 요청 — 1회차(PR #28 · 6043119) 판정: 반려(재제출). 같은 브랜치 ui/m7-s77-annual · 같은 PR #28 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 테스트 파일 하나(packages/ui_analytics/test/annual_review_view_test.dart — 아래 R1·R2 글자 그대로)와 채팅 글 P1~P4 뿐입니다.
🔴 lib 0 · PNG 0 · 골든 테스트·가짜·질문 파일 0 · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12c 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner · ui/m7-s79-goal-path · ui/m7-s76ab-rebalance · ui/m7-s76c-preview)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #28 · 브랜치 ui/m7-s77-annual(커밋 6043119)에 아래 R1·R2 커밋 하나를 «더하는» 일입니다. R1·R2 는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돌기 때문에, main 에 들어간 기록 커밋은 병합하지 않아도 CI 에 들어갑니다.
🔴 1회차 카드의 «(할 일 (1)~(4) 커밋이 끝난 뒤 — (4) 가 마지막 커밋)» · «(4) 뒤에 다른 커밋을 더하지 않는다» 는 이번에 이 카드가 덮습니다 — 재제출 커밋 1개를 맨 위에 더하는 것이 이번 일입니다.
   지난 4개 커밋(6043119 · 9dd7ce6 · 97c1c8f · b4fb13e — 순서·제목 포함)은 그대로 둡니다(커밋 단위·제목 ≠ 내용은 통합 담당이 기록으로 닫았습니다 · 고치려 하면 반려).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m7-s77-annual 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m7-s77-annual
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git rev-parse --short HEAD    ← 6043119 이면 정상 · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m7-s77-annual   ← 6043119 · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R12c-Bob-S77-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R12c-Bob-S77.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 · _대기 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R12c-Bob-S77-» 로 시작하는 줄이 있으면 정상.
        «R12c-Bob-S77-재제출» 줄이 없거나 꼬리 없는 «R12c-Bob-S77.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 카드가 먼저 왔습니다.
  ls docs/ai-context/send/R12c-Bob-S77.md   ← 보여야 함(이 브랜치에는 1회차 카드가 있다 — 아래 «규칙 요약» 이 가리키는 파일 · 읽기만)
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
🔴 이 카드와 1회차 카드(R12c-Bob-S77.md)의 글이 다르면 이 카드가 이깁니다 — 예: 커밋은 재제출 커밋 1개만 맨 위에 · 질문 파일을 고치지 않는다 · 골든을 다시 찍지도 dy 를 다시 재지도 않는다 ·
   채팅 글은 이 카드 «■ 제출» 의 P1~P4 만(부분 제출) · 테스트 수 기대 = 뷰 +33 · 전체 +448(1회차와 같은 수) · main 을 병합하지 않는다.
   PR #28 반려 댓글의 «보고 글은 부분 제출 P1~P4 다» 와 이 카드의 P1~P4 는 같은 범위다 — 글자·차례는 이 카드 «■ 제출» 상자가 정한다.

■ 규칙 요약 (1회차 카드 = 이 브랜치의 docs/ai-context/send/R12c-Bob-S77.md(main 에서는 send/_완료/ 로 옮겨졌다 — 글자는 같다)의 규칙 11(143~175행) · 보고 규칙(193~209행) · 테스트 최소 목록(380~490행) · 정적 묶음(492~557행) · 골든 표(713~718행)가 유효 —
   단 이 카드와 다른 곳은 이 카드가 이긴다 · 여기엔 핵심만)
· 이번에 고치는 곳 = 아래 한 파일뿐입니다.
    packages/ui_analytics/test/annual_review_view_test.dart   (R1·R2 — T77-14 · T77-12 본문만 · 새 testWidgets 줄을 더하지 않는다 · 경우 목록도 그대로)
· 🔴 고치면 반려: 위 한 파일 밖의 전부 — packages/ui_analytics/lib/**(annual_review_screen.dart · labels.dart · analytics_providers.dart · ui_analytics.dart 포함 · 🔴 lib 0) ·
  test/golden/goldens/*.png 전부(s77_* 10장 포함 · 🔴 PNG 0 · --update-goldens 를 돌리지 않는다) · test/golden/s77_golden_test.dart · test/annual_review_fakes.dart ·
  그 밖의 기존 테스트 전부 · test/golden/ 의 하네스·README · test/flutter_test_config.dart · domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml ·
  docs/ai-context/**(질문 파일 inbox/S7-7_questions.md 포함).
  🔴 PNG 나 lib 가 하나라도 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 테스트 규칙(1회차 카드 규칙 11 — 이번에 걸린 곳만 글자 그대로):
   «🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지»(145행) — 단언은 «틀린 코드에서 실패할 수 있어야» 뜻이 있다.
   ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 전제 한 줄 — «dart format 뒤에도 한 줄이어야 한다(접히면 변수로 받아 줄을 짧게)»(155~156행).
   ⓡ = expect(find.text(AnalyticsLabels.retryButton), findsNothing); 줄 · 정적 S29·S30 이 정확히 13 · 6 이어야 한다(R1·R2 는 ⓡ·ⓗ 줄을 더하지도 빼지도 않는다 —
   🔴 R2 의 final int 줄에는 hasLength 가 없다 · R1 의 «같은 것만 모은 목록» 단언은 hasLength 가 아니라 == 목록이다(카드 477행 «hasLength 를 쓰지 않는다» 그대로)).
  (그 밖 — 테스트 이름 그대로 · 테스트에 한국어 리터럴 금지 · 주석에도 한국어를 새로 쓰지 않는다(정적 S01) · 새 띄우기 도우미·새 가짜 금지 · if 를 새로 쓰지 않는다.)
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인.
· 보고 규칙(1회차 카드 194~196행 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당(C4)이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음) · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 머리 첫 줄과 P1~P4 머리는 «■ 제출» 상자 글자 그대로).
  🔴 채팅 글은 머리 첫 줄부터 시작한다 — 그 위에 «모든 확인 완료 …» 같은 섹션 밖 글이나 --- 를 두지 않는다(1회차 C12c-4).
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 카드가 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.
   🔴 git log · flutter test · dart test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
      <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다 — 새 화면 1(«화면» 배치 1~7 · 로딩·에러에 배너 없음 · 배너 둘은 ListView 밖 · 반사실 = _cfOpen 하나 · 기본 접힘 · 세후 Card 기본 고도) ·
  공용 2파일 더하기만(S27 7 0 / 1 0 · 둘째 수 0) · providers R12c 절 = 카드 글자 그대로 · 배럴 정렬 자리 1줄 · Key 9종 = Key 표 · 라벨 0 · lib/src/annual_review/ 없음 · 읽지 않는 필드 0.
테스트는 R1·R2 자리 밖이 모두 맞았습니다 — 뷰 15 testWidgets(경우 33) · 골든 3 testWidgets(10) · ⓡ 13 · ⓗ 6 자리 · else 없는 if 0 · C4b-12·14 반영 · 한국어 리터럴 0 · ASCII 이름.
flutter test 405 → 448 · analyze --fatal-infos No issues · format 0 changed · C-42 +14(S7-7 1파일 · 합 4파일 · 45줄) · 새 PNG 10장(390×1440 · 영역 2이름) · 기존 86장 그대로 · dy 10값 = C4 재실측 · CI 3/3.
보고에서 맞은 곳 — 거짓 주장 0 · 정적 37줄 출력이 C4 재실행과 글자가 같았습니다(warning: 줄만 차이 = 대조 밖) · ① 17줄·4커밋 · ② 12항 15줄·괄호 12·세는 줄 · C-42 3줄 · S05 2줄 · ③ 4줄 · ④ 5행 · ⑤ «없음».
카드가 예고한 변이 29항목(56꼴)은 모두 잡혔습니다.

■ 왜 반려인가 — 카드 / 실제 (C4 검사 갈래가 따로 냈고 통합 담당이 코드·재현·수정안 시험으로 직접 다시 확인)
① T77-14 «'annual_review/' 를 품은 export 0» 이 늘 참 (C12c-1 · 테스트 결함 · strict 나눔 ②)
   카드:  규칙 11(145행) «🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지» ·
          T77-14(476~478행) «export 경로 목록(RegExp(…))에서 'src/screens/annual_review_screen.dart' 와 같은 것만 모은 목록 == <String>[…] · 'annual_review/' 를 품은 export 0(exports.any(…) isFalse)» ·
          보고 규칙(195행) «코드·테스트 결함(카드 규칙 위반) = 반려(재량 없음)».
   실제:  annual_review_view_test.dart(6043119) 798~802행이 exports 를 만들면서 .where((String e) => e == 'src/screens/annual_review_screen.dart') 로 이미 그 한 글자만 남긴다.
          805행 expect(exports.any((String e) => e.contains('annual_review/')), isFalse); 의 목록에는 'src/screens/annual_review_screen.dart' 하나뿐이고,
          이 글자는 'annual_review/' 를 품지 않는다('annual_review_' 다). 그래서 배럴에 무엇이 있든 any 는 거짓이고, 단언은 늘 통과한다.
   놓친 것: 배럴(lib/ui_analytics.dart)이 annual_review 아래 폴더(src/screens/annual_review/… 같은 내부 경로)를 export 해도 뷰 33 · 골든 10 · C-42 를 모두 통과한다 —
          같은 테스트의 Directory('lib/src/annual_review') 검사는 그 한 폴더만 본다. CI 에 없는 손 검사(정적 S16)만 잡는다(통합 담당 재현).
② T77-12 ⓗ 가 dart format 뒤 10줄 (C12c-2 · 테스트 결함 · strict 나눔 ②)
   카드:  규칙 11(155~156행) «ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 전제 한 줄 … dart format 뒤에도 한 줄이어야 한다(접히면 변수로 받아 줄을 짧게)» · 195행.
   실제:  655~664행 expect( activeFlags, hasLength( caseName == 'row0' ? 0 : caseName == 'row3' ? 2 : 1, ), ); 가 중첩 삼항 때문에 10줄로 접혔다((2) 커밋 97c1c8f 에서 이미 같은 꼴).
          실효 손실은 0 이다(S30 = 6 은 hasLength( 가 657행 한 줄에 따로 놓여 맞았을 뿐이다). 그래도 카드가 처방(«변수로 받아»)까지 적어 둔 조문이라 [가] 다(R12b C12b-1 과 같은 가름).
함께 고칠 것: 표기 C12c-3(골든 표 3행의 «파란 버튼» = 색 이름 · 카드 200·718행) = 아래 P3. C12c-4(제출 글 맨 위 섹션 밖 머리말)는 통합 담당이 병합 본문에서 정정한다(Bob 몫 아님 — 이번 글은 머리 첫 줄부터).
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 생성물은 git 에 없습니다(브랜치를 바꿨거나 새로 받았으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류 · 생성물은 git 이 무시하므로 git status 는 빈 채).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test test/annual_review_view_test.dart   ← 시작 기준: 끝 줄 «+33: All tests passed!»(1회차 그대로)
  flutter test   ← 시작 기준: 끝 줄 «+448: All tests passed!» · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·푸시 -u 는 하지 않습니다):
   · docs/ai-context/send/R12c-Bob-S77.md(1회차 카드 — 이 브랜치에 있다) — 143~175행 규칙 11 · 464~468행 T77-12 · 474~479행 T77-14 · 483~484행 ⓡⓗ 기대 · 492~557행 정적 묶음 · 713~718행 골든 표
   · packages/ui_analytics/test/annual_review_view_test.dart 의 아래 R1·R2 자리(6043119 행 번호 · 고치기 전에 «이 줄을» 상자와 한 글자씩 대조)

■ 고칠 것 — R1·R2 (1회차 반려 · C4 2026-10-14) — 파일 하나 · 아래 상자의 «이 줄을 → 이 줄로» 그대로 · 손으로 다시 짜지 않는다
   🔴 행 번호는 6043119 의 것이다. 아래 차례(파일 **아래쪽부터** 위로 — ⑴ → ⑵)로 고치면 앞의 수정이 뒤 자리의 행 번호를 밀지 않는다.
   🔴 «이 줄을» 상자와 파일의 그 행이 한 글자라도 다르면(들여쓰기 포함) 고쳐 쓰지 말고 멈춘 뒤 채팅으로 — 파일이 6043119 가 아니다.
   🔴 상자 안의 들여쓰기(빈칸 수)를 그대로 옮긴다 · 탭 문자 0 · 상자 밖의 줄은 한 글자도 바꾸지 않는다(빈 줄 포함 — 803행과 805행 사이 빈 줄 · 805행 expect(exports.any(…), isFalse); 는 그대로 둔다) · lib 0 · PNG 0.

⑴ R1 (C12c-1 · T77-14 · 798~803행) — exports 를 배럴 전체 export 목록으로 두고, «같은 것만 모은 목록» 은 단언 안에서 만든다
      ┌── 이 줄을(798~803행 · 6줄)
    final List<String> exports = RegExp(r"^export '([^']+)';", multiLine: true)
        .allMatches(barrelContent)
        .map((RegExpMatch m) => m.group(1)!)
        .where((String e) => e == 'src/screens/annual_review_screen.dart')
        .toList();
    expect(exports, <String>['src/screens/annual_review_screen.dart']);
      └──
      ┌── 이 줄로(10줄)
    final List<String> exports = RegExp(
      r"^export '([^']+)';",
      multiLine: true,
    ).allMatches(barrelContent).map((RegExpMatch m) => m.group(1)!).toList();
    expect(
      exports
          .where((String e) => e == 'src/screens/annual_review_screen.dart')
          .toList(),
      <String>['src/screens/annual_review_screen.dart'],
    );
      └──
   (805행 expect(exports.any((String e) => e.contains('annual_review/')), isFalse); 는 글자 그대로 둔다 — 이제 그 exports 가 배럴 전체 목록이라 단언이 뜻을 갖는다 ·
    «같은 것만 모은 목록 == <String>[…]» 단언은 hasLength 가 아니다(카드 477행 그대로) · 줄 나눔은 dart format 결과 그대로다.)

⑵ R2 (C12c-2 · T77-12 · 655~664행) — 기대 수를 final int 변수로 받아 ⓗ 를 한 줄로(654행 final List<BlockFlag> activeFlags = safety.activeFlags; 는 그대로 둔다)
      ┌── 이 줄을(655~664행 · 10줄)
      expect(
        activeFlags,
        hasLength(
          caseName == 'row0'
              ? 0
              : caseName == 'row3'
              ? 2
              : 1,
        ),
      );
      └──
      ┌── 이 줄로(6줄)
      final int flagCount = caseName == 'row0'
          ? 0
          : caseName == 'row3'
          ? 2
          : 1;
      expect(activeFlags, hasLength(flagCount));
      └──
   (final int flagCount = … 는 값을 고르는 식이지 if 가 아니다 · 단언 0 → 규칙 11 의 금지 대상이 아니다 · 682행 findsNWidgets(caseName == 'row3' ? 2 : 1) 은 그대로 둔다 ·
    ⓗ 줄 수는 그대로 1 — S30 은 6 그대로.)

고친 뒤 확인(packages/ui_analytics 에서 · 고치지 않고 보기만):
  git diff --stat                     ← 마지막 줄이 « 1 file changed, 16 insertions(+), 16 deletions(-)»(위에 파일 줄 하나가 더 있는 것이 정상 · 다르면 상자와 다시 대조 · 커밋하지 않는다)
  dart format --output=none --set-exit-if-changed test/annual_review_view_test.dart   ← «Formatted 1 file (0 changed)» 꼴 · 바뀐 줄이 있으면 상자와 다르게 옮긴 것 — 다시 대조
  git grep -c 'hasLength(' -- test/annual_review_view_test.dart                                  ← «test/annual_review_view_test.dart:6»(6043119 와 같은 수)
  git grep -c -E '^ *expect\(.*hasLength\(.*\)\);$' -- test/annual_review_view_test.dart          ← «test/annual_review_view_test.dart:6»(한 줄 ⓗ · 6043119 에서는 5 — R2 가 하나를 한 줄로)
  git grep -c -F 'allMatches(barrelContent).map((RegExpMatch m) => m.group(1)!).toList();' -- test/annual_review_view_test.dart   ← «test/annual_review_view_test.dart:1»(R1 · 6043119 에서는 출력 없음)
  git grep -c -F 'expect(activeFlags, hasLength(flagCount));' -- test/annual_review_view_test.dart   ← «test/annual_review_view_test.dart:1»(R2 · 6043119 에서는 출력 없음)
  (위 여섯 줄 다 자기 점검이다 · 작은따옴표 그대로(Git Bash·PowerShell 둘 다 그대로 돈다) · 다르면 커밋하지 말고 멈춘 뒤 출력을 채팅으로 · 이 출력은 채팅 글에 붙이지 않는다)

커밋 — 하나 · 맨 위에(R1·R2 전부 · format:fix 가 바꾼 줄이 있으면 그것도 같은 커밋 — 기대는 0 줄):
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M7] R12c (5) 재제출 — T77-14 전체 export 목록 · T77-12 ⓗ 한 줄
      └── 커밋 제목 복사 끝(이 줄 앞까지)
   🔴 지난 커밋(6043119 · 9dd7ce6 · 97c1c8f · b4fb13e)을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.

■ 고치지 않는 것 (1회차가 맞았거나 이 카드 밖 — 손대면 반려)
 · lib/** 전부 · PNG 전부(s77_* 10장 포함 — --update-goldens 금지) · s77_golden_test.dart · annual_review_fakes.dart · labels.dart · 그 밖의 테스트 파일
 · 골든 dy — lib·골든 테스트·PNG 가 그대로라 다시 재지 않습니다(질문 파일 A1~A5 = 1회차 실측 = C4 재실측 · s77_golden_test.dart 를 열어 lessThan(0) 으로 바꾸는 일도 하지 않는다)
 · 질문 파일 docs/ai-context/inbox/S7-7_questions.md — A1~A5 행·머리말(«다음 번호» 포함)을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 닫는다)
 · R1·R2 상자 밖의 테스트 본문 전부(T77-01~11 · 13 · 15 · T77-12 의 경우 목록·플래그 루프·아이콘·탭 단언 · T77-14 의 정규식 검사·Directory 검사·805행)
 · ⓡ·ⓗ 줄 — 더하지도 빼지도 않는다(S29 13 · S30 6) · 테스트 이름 · 경우 목록
 · 지난 4개 커밋 · 보강 후보(C4 보고 §7 N1·N3~N6 — 다음 카드 몫)는 이번에 넣지 않는다(넣으면 범위 밖 변경)

■ 질문 파일
· 이번 R1·R2 는 전부 이 패킷이 정했고 lib·PNG 가 그대로라 잴 것도 없으므로, 질문 파일은 바뀌지 않는 것이 정상입니다(새 행 0).
· 🔴 새 행이 필요해 보이면(측정·추측·질문 어느 것이든) 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 — 이번 커밋은 테스트 파일 하나만 add 하고, 아래 «git diff --name-status 6043119 HEAD» 는 테스트 한 줄이어야 합니다.

(읽는 법 — 아래 «■ 정적 묶음» 절은 1회차 카드 492~557행 글자 그대로다. 이 재제출에서는 «PR 본문 ②» = 채팅 글 P2 · ««■ 제출» 의 flutter test 세 줄» = 이 카드의 «■ 테스트 수 묶음» ·
  «이어서 packages/domain_contracts 에서» 의 C-42 줄 = P2 에 함께 붙인다(1회차와 같은 꼴 — 정적 37줄 출력 바로 아래 · 같은 코드 블록) · S15·S16b 의 «R12b 병합본 + 1» = 1회차와 같은 8줄 · 12줄 ·
  대조에서 빼는 것 = 빈 줄 · EXIT 표기 · warning:·error: 줄 · PowerShell 장식 줄 · 줄 머리 경과 시각 · 한국어가 깨져 보이면 [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 돌린다.)
■ 정적 묶음 — packages/ui_analytics 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 37줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로(줄 수가 많아도 · «길어서 줄였습니다» 같은 주의 문장으로 갈음하지 않는다 · R12a C12a-2).
  🔴 **테스트 이름·패키지 이름 한 낱말이라도 다르면 반려 — 대조에서 빼는 것은 빈 줄·EXIT 표기·warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐**(R12a 2회차 C12a2-1 — 다시 돌린 출력을 채팅 글로 옮기다 테스트 제목의 패키지 이름 한 낱말이 바뀌어 반려).
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(이 절 끝 «이어서 packages/domain_contracts 에서» 의 C-42 dart test · «■ 제출» 의 flutter test 세 줄 · Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 → <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힐 수 있다 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명·백틱·앞머리 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/annual_review_view_test.dart test/annual_review_fakes.dart test/golden/s77_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/annual_review_view_test.dart test/golden/s77_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/annual_review_view_test.dart test/golden/s77_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (C-42 9a)"; git grep -nE "\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S03b sort filter reverse 0 (C-42 9b)"; git grep -nE "\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|reverse: *true" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes 0 (annual)"; git grep -n "AppRoutes" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S05 opener lines annual (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 number formatting 0"; git grep -nE "toStringAsFixed|toStringAsPrecision|NumberFormat" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 old draft names and other windows 0 (annual)"; git grep -nE "ReviewSectionVm|changeWindowNoticeText|oathText|KeyValueVm|AsOfStamp|afterTaxLadder|OpsStatusRepository|monthlyReport|CommandApi|ExpansionTile" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S15 autoDispose lines"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "annual_review/|goal_path/|chart/|explore/|planner|perf_chart|widgets/|rebalance/|execution_gap/" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16c annual export 1"; git grep -n "annual_review" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint" -- lib; echo "EXIT:$?"
echo "## S25 decimal literal and percent string 0 (C-42 6 annual)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%[^'\n]*'" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea 0 (annual)"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 raw fields 0 (C-42 2 3 annual)"; git grep -nE "\.(year|windowStateCode|code|stepCode|cagrPct|endMult|branch|isReferenceOnly|configHash|kind|mode|wire|journalTimelineLink|detailDeepLink)\b" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/annual_review_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/annual_review_view_test.dart; echo "EXIT:$?"
echo "## S31 providers R12c section lines"; git grep -nE "R12c|annualReview" -- lib/src/providers/analytics_providers.dart; echo "EXIT:$?"
echo "## S32 s77 key glyphs (annual)"; git grep -noE "s77-[a-z-]+" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) ·
   S03·S03b = 받은 글자·순서 그대로(C-42 ⑨ 와 같은 낱말 · 주석도 센다) · S04 = 출력 없음(이 카드가 쓰는 AppRoutes 상수 0) ·
   S05 = 2줄(SafetyBlockBanner(onOpenLink:) 자리 1 · 섹션 「자세히」 onPressed 자리 1 · 줄 번호는 짜임에 따라 다르다) — 둘 다 build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) ·
   S06~S12 = 출력 없음 · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐(R12a·R12b 병합본과 같다 · annual_review_screen 0) ·
   S14 = 출력 없음 · S15 = 대소문자 구분 · 8줄(R12b 병합본 + annualReviewProvider 1 · 설계서 E12 «R12c 8») · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = 12줄(R12b 병합본 + 1 · 🔵 «정확히 N» 은 R12d 몫 — 이 카드의 기준은 S16c 와 «R12b 병합본 + 1») ·
   S16c = 1줄(export 'src/screens/annual_review_screen.dart'; · analytics_providers 줄 바로 다음 · contribution_screen 줄 바로 앞) ·
   S17·S18·S18b = R10·R11 차트 파일 무변경 · S19~S23 = 12항의 1·3·11항 근거(S22·S23 = 11항 보강 — 계약 테스트 C-38 ⑫ 와 같은 정규식 · S19 는 허용 밖 import 줄만 찍는다 — 출력 0 이 정상) ·
   S24 = 폐기·금지 이름 0 · S25 = C-42 ⑥ 과 같은 소수 리터럴 정규식 + % 문자열 0(Card elevation 0.5 를 본뜨면 여기서 1건) · S26 = 공개 위젯은 본문만(ScaffoldMessenger 도 1건) ·
   S27 = 공용 파일의 «끝 절 더하기만» — 2줄(analytics_providers.dart · ui_analytics.dart)의 둘째 수(삭제)가 0 · labels.dart 줄은 나오지 않는 것이 정상(이 카드는 라벨 0) ·
     첫째 수 = providers 7 · 배럴 1(드라이런 · 차이가 나면 PR 본문에 까닭 — 기준은 둘째 수 0) ·
   S28 = 출력 없음(읽지 않는 필드 — 규칙 5) · S29·S30 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 정확히 같아야 한다(13 / 6 · 다르면 반려 — 규칙 11) ·
   S31 = 3줄(머리 줄 // ── 🆕 R12c — S7-7 ── · annualReviewProvider 선언 줄 · .annualReview() 호출 줄 — 주석에 R12c·annualReview 낱말을 쓰지 않으면 이 셋뿐 · 규칙 17) ·
   S32 = 줄마다 «…:<줄>:s77-…» — 글자 부분의 집합이 정확히 {s77-root · s77-year · s77-window · s77-aftertax · s77-step- · s77-cf · s77-cf-toggle · s77-section- · s77-asof} 아홉(줄 수는 짜임에 따라 다르다 · 표 밖 글자 1개라도 = 반려))
  이어서 packages/domain_contracts 에서(정적 묶음과 별도 · 출력 중 아래 줄만 ② 에 그대로 붙인다):
    cd ../domain_contracts
    dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded
       ← «C-42 ① 대상 S7-7(R12c) 1파일 — …» 로 시작하는 줄과 그 다음 줄(«    lib/src/screens/annual_review_screen.dart»)·«C-42 ① 역할 대상 합 …» 줄을 그대로 · 끝 줄 «All tests passed!» 확인 ·
         역할 대상 합·providers R12 절 줄 수 = R12b 병합본 + 1파일 · + R12c 절 줄 수(드라이런 «역할 대상 합 4파일 · providers R12 절 45줄» — 앞 카드 병합본에 따라 다를 수 있다 · 기준은 «S7-7(R12c) 1파일» 줄과 «All tests passed!»)
    cd ../ui_analytics
  (🆕 이번 기대 — lib·PNG·다른 테스트 불변이고 R1·R2 는 한국어·비 ASCII 이름·ⓡ·ⓗ 줄을 더하지 않으므로, 37줄의 출력은 1회차 출력과 같다(EXIT 표기·warning 줄·PowerShell 장식 줄 말고):
   S05 = lib/src/screens/annual_review_screen.dart:56 · :172 두 줄 · S13 옛 4파일 · S15 8줄 · S16b 12줄 · S16c = lib/ui_analytics.dart:12 한 줄 · S27 = 7 0 · 1 0 · S29 = test/annual_review_view_test.dart:13 · S30 = test/annual_review_view_test.dart:6 ·
   S31 3줄 · S32 9글자 집합 · 나머지 출력 없음 · C-42 = «C-42 ① 대상 S7-7(R12c) 1파일 — …» · 그 다음 줄 · «C-42 ① 역할 대상 합 4파일 · providers R12 절 45줄» — C4 1회차 재실행과 같음 ·
   🔴 S29·S30 이 13·6 과 다르면 제출하지 말고 R1·R2 를 다시 본다 · 그 밖의 줄이 1회차와 다르면 멈춘 뒤 채팅으로)

■ 테스트 수 묶음 — packages/ui_analytics 에서 세 줄(P4 의 끝 줄은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다 · 파일로 떠서 붙인다)
  flutter test test/annual_review_view_test.dart   ← 끝 줄 «+33: All tests passed!» 기대(1회차와 같음 — R1·R2 는 testWidgets·경우 수를 바꾸지 않는다 · C4 시험 «+33»)
  flutter test test/golden/s77_golden_test.dart    ← «+10: All tests passed!» 기대(1회차와 같음)
  flutter test                                     ← 끝 줄 «+448: All tests passed!» 기대(1회차와 같음 — C4 시험 «+448»)
  PowerShell 에서 파일로 뜨는 꼴(예 — 이름은 아무것이나 · 저장소 밖):
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    flutter test test/annual_review_view_test.dart | Out-File -Encoding utf8 $env:TEMP\r12c_t_view.txt
    Get-Content -Encoding UTF8 $env:TEMP\r12c_t_view.txt | Select-Object -Last 1   ← 이 줄을 그대로 복사(golden · 전체도 같은 꼴로 r12c_t_golden.txt · r12c_t_all.txt)

■ 제출
  (R1·R2 를 고치고 «고친 뒤 확인» 이 기대와 같은 뒤)
  cd packages/ui_analytics
  flutter test test/annual_review_view_test.dart   ← 먼저 이 파일만 · «+33: All tests passed!»(실패하면 고친 곳을 상자와 다시 대조 · lib 를 고치지 않는다)
  flutter test   ← 옵션 없이 전부 통과 · «+448: All tests passed!»
  cd ../..
  melos.bat run format:fix
  git status --short   ← M 은 packages/ui_analytics/test/annual_review_view_test.dart 하나뿐이어야 합니다(PNG·lib·질문 파일의 M = 금지 → git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  git add packages/ui_analytics/test/annual_review_view_test.dart
  git commit -m "[M7] R12c (5) 재제출 — T77-14 전체 export 목록 · T77-12 ⓗ 한 줄"   ← 위 «커밋 제목» 상자 글자 그대로
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git diff --name-status 6043119 HEAD
     ← 재제출 커밋의 변경만 봅니다. 🔴 정확히 이 한 줄이어야 합니다:
        M	packages/ui_analytics/test/annual_review_view_test.dart
        다른 줄이 한 줄이라도 나오면(lib · PNG · 질문 파일 · annual_review_fakes · s77_golden_test …) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git log --oneline -2   ← 맨 위 = 재제출 커밋 · 그 아래 = 6043119(지난 커밋은 그대로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #28 자동 반영 · 새 PR·라벨·강제 푸시(--force · --force-with-lease)·rebase·main 병합 금지)
  git log --oneline origin/main..HEAD   ← 아래 P1 에 붙일 출력(5줄 — 맨 위 = 재제출 커밋 · 그 아래 4줄 = 1회차 그대로 · 파일로 떠서)
  git diff --name-status 6043119 HEAD   ← 아래 P1 에 붙일 출력(위와 같은 한 줄 · 파일로 떠서)
  cd packages/ui_analytics → 위 «정적 묶음» 37줄 → C-42 줄(cd ../domain_contracts → dart test … → cd ../ui_analytics) → 위 «테스트 수 묶음» 3줄 → cd ../..   ← 아래 P2·P4 에 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로 · 1회차 출력을 쓰지 않는다)
  git status --short   ← 🔴 다시 비어 있어야 합니다(명령이 파일을 바꾸었으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다(golden:approved 포함).
  🔴 부분 제출 — 채팅 글 = 맨 위 머리 첫 줄 + P1~P4 네 토막뿐입니다. 1회차 글 ①~⑤ 를 다시 내지 않습니다(통합 담당이 1회차 PR 본문의 그 자리에 P1~P4 를 바꿔 넣는다 — 바꿔 넣는 자리는 각 토막 머리의 괄호).
  🔴 머리 첫 줄 위에 아무 글도 두지 않습니다(«모든 확인 완료 …» · «이제 제출 글을 작성합니다» · --- 같은 섹션 밖 글 0 — 1회차 C12c-4).
      ┌── 머리 첫 줄 복사 시작(다음 줄부터 · 1줄 · <해시> 자리에만 위 git log 맨 위 줄의 해시 7자)
R12c 재제출 글(P1~P4 · 부분 제출)입니다 — 재제출 커밋 1개(`<해시>` · test 1파일 · lib·PNG·질문 파일 0) · force push 0.
      └── 머리 첫 줄 복사 끝(이 줄 앞까지)
      ┌── 토막 머리(네 줄 · 글자 그대로 · 각 토막 맨 위에 한 줄씩 · 이 차례로)
## P1 ① 커밋 목록 · 재제출 커밋 범위
## P2 ② 정적 묶음 · C-42 · S05 · ⓡⓗ
## P3 ③ 골든 표 3행(december · first_year · offwindow light)
## P4 ⑤ flutter test 세 줄
      └──
   P1 (① 의 «커밋 목록:» 코드 블록 4줄을 바꾼다) =
       위 git log --oneline origin/main..HEAD 출력 5줄을 코드 블록 하나로 그대로 +
       위 git diff --name-status 6043119 HEAD 출력 1줄을 코드 블록 하나로 그대로(① 의 머리 줄·name-status 17줄은 그대로라 다시 내지 않는다 — 점 세 개 diff origin/main...HEAD 는 1회차와 같은 17줄이다).
   P2 (② 의 «정적 묶음 출력:» 코드 블록 · «S05 결과:» 2줄 · ⓡⓗ 4줄을 바꾼다 — 12항 15줄·괄호·세는 줄은 그대로라 다시 내지 않는다) = 이 차례로:
       ㄱ. «정적 묶음 출력:» 다음에 정적 묶음 37줄 출력 **전부**와 C-42 ① 줄(«C-42 ① 대상 S7-7(R12c) 1파일 — …» · 그 다음 줄 · «C-42 ① 역할 대상 합 …» 세 줄)을 코드 블록 하나로 그대로
           (1회차와 같은 꼴 · 줄이지 않는다 · 빈 줄도 지우지 않는다 · 1회차 출력을 쓰지 않는다 · C-42 출력은 파일로 떠서).
       ㄴ. «S05 결과:» 다음 줄부터 아래 상자 글자 그대로 2줄(정적 묶음 S05 출력의 경로·줄 번호와 같아야 한다 — 다르면 lib 가 바뀐 것이니 멈춘 뒤 채팅으로):
      ┌── S05 복사 시작(다음 줄부터 · 2줄)
lib/src/screens/annual_review_screen.dart:56 — 탭 콜백 안
lib/src/screens/annual_review_screen.dart:172 — 탭 콜백 안
      └── S05 복사 끝(이 줄 앞까지)
       ㄷ. ⓡⓗ = 아래 상자 글자 그대로 4줄(정적 묶음 S29·S30 출력 줄과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 R1·R2 를 다시 본다):
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = S29 출력:
test/annual_review_view_test.dart:13
ⓗ = S30 출력:
test/annual_review_view_test.dart:6
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   P3 (③ 골든 표의 s77_december_light · s77_first_year_light · s77_offwindow_light 세 행을 바꾼다 — C12c-3 · «파란 버튼» 의 색 이름을 뺀다) = 아래 상자 글자 그대로 3줄.
       🔴 붙이기 전에 PNG 세 장(test/golden/goldens/s77_december_light.png · s77_first_year_light.png · s77_offwindow_light.png)을 다시 연다 —
          (골든 글꼴은 글자를 네모로 그린다 — 줄 수·차례·버튼 글자 네모의 있고 없음·잘림만 본다 · 색 이름은 쓰지 않는다 — 1회차 카드 200·718행) 첫 섹션 Card 끝에 버튼 글자가 있고(december · offwindow) ·
          first_year 에는 없으며, 그 밖의 차례와 잘림 없음이 상자와 같으면 이 글자로 바꾼다. 다르면 제출하지 말고 멈춘 뒤 채팅으로.
          (PNG 는 이번 재제출에서 바뀌지 않는다 — 골든 테스트·lib 0 · dy 그대로 · 표의 다른 7행과 머리는 1회차 그대로라 다시 내지 않는다.)
      ┌── P3 복사 시작(다음 줄부터 · 3줄)
| s77_december_light | m7/m7_annual_2026.json | 390×1440 | 1252 | 상단 2줄(연도·창상태), 세후 Card(본문 6층+cf 접힘), 섹션 Card 4개(첫 번째에 버튼 글자), 하단 기준일 줄 — 잘림 없음 |
| s77_first_year_light | m7/m7_annual_first_year.json | 390×1440 | 1184 | 상단 2줄, 세후 Card(6층+cf 접힘), 섹션 Card 4개(버튼 글자 없음), 하단 기준일 줄 — 잘림 없음 |
| s77_offwindow_light | m7/m7_annual_offwindow.json | 390×1440 | 1272 | 상단 창상태 줄 여러 행으로 줄바꿈, 세후 Card(6층+cf 접힘), 섹션 Card 4개(첫 번째에 버튼 글자), 하단 기준일 줄 — 잘림 없음 |
      └── P3 복사 끝(이 줄 앞까지)
   P4 (끝의 flutter test 세 줄을 바꾼다) = 아래 상자의 글자 틀 그대로 3줄(<…> 자리에만 위 «테스트 수 묶음» 의 끝 줄 그대로 · 시각·«+수»·«All tests passed!» 까지 · 파일로 떠서 ·
       줄 머리 경과 시각(mm:ss)은 돌릴 때마다 달라 C4 대조에서 뺀다 · «시작 기준 405» 는 1회차 시작 기준 글자 그대로 · 기대 +33 · +10 · +448 = 1회차와 같은 수라 까닭 줄 없음):
      ┌── P4 복사 시작(다음 줄부터 · 3줄)
flutter test(view): <test/annual_review_view_test.dart 끝 줄 그대로>
flutter test(golden): <s77_golden_test.dart 끝 줄 그대로>
flutter test: 시작 기준 405 → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>
      └── P4 복사 끝(이 줄 앞까지)
       (수가 +33 · +10 · +448 과 다르면 끝 줄을 출력 그대로 적은 뒤 채팅 글 끝에 «테스트 수가 기대와 다름» 한 줄을 더한다 — 상자의 수를 맞추려 고쳐 쓰지 않는다.)
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s77-annual` 에 추가 커밋 **1개**: `[M7] R12c (5) 재제출 — T77-14 전체 export 목록 · T77-12 ⓗ 한 줄`. main 병합 커밋 **없음** · 지난 4개 커밋 **그대로**(`git log --oneline origin/main..HEAD` = 5줄 · 맨 위 = 재제출 커밋 · 아래 4줄 = 1회차 글자).
- `test/` 수정 1 — `annual_review_view_test.dart` 의 R1·R2 자리만(+16/−16 · C4 시험 diff `j_fix.diff` 와 같은 글자 — 통합 담당이 `git diff 6043119 HEAD` 를 그 diff 와 대조한다).
- `lib/` 변경 0 · PNG 변경 0 · 골든 테스트·가짜·질문 파일 변경 0 — `git diff --name-status 6043119 HEAD` = `M	packages/ui_analytics/test/annual_review_view_test.dart` 한 줄.
- `ui_analytics` `flutter test` **448**(뷰 33 · 골든 10 — 1회차와 같은 수) · 정적 37줄 출력 = 1회차와 같은 글자(EXIT·warning·장식 줄 말고 · S29 13 · S30 6 · S05 `:56` · `:172`).
- 채팅: 머리 첫 줄(상자) + P1~P4 — P1 git log 5줄 + `6043119..HEAD` name-status 1줄 · P2 정적 37줄 출력 전부 + C-42 ① 3줄(한 코드 블록) + S05 2줄(상자) + ⓡⓗ 4줄(상자) · P3 골든 표 3행(상자) · P4 flutter test 세 줄(틀). 1회차 ①~⑤ 의 나머지는 다시 내지 않는다(부분 제출) · 머리 첫 줄 위의 섹션 밖 글 0.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12c-Bob-S77 재제출: PR #28 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 채팅 글(머리 첫 줄 + P1~P4)을 붙여넣습니다(Claude 가 1회차 PR #28 본문의 그 자리에 바꿔 넣습니다). 0단계·«먼저 할 것»·«고친 뒤 확인»에서 멈췄다면 `R12c-Bob-S77 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력. Bob 이 1회차 글 ①~⑤ 전체를 다시 냈다면 그대로 붙여넣되 «부분 제출이 아님» 이라고 함께 알립니다(통합 담당은 P1~P4 자리만 씁니다).

## 5. 주의

- **5분 눈 검사**(PR #28 «Commits» · «Files changed» — `6043119` 뒤 커밋만 보면 된다): ① 커밋 수가 5 가 아님 · 지난 4개 해시가 바뀜(강제 푸시·rebase 흔적) · `Merge … origin/main` 커밋 ② `packages/ui_analytics/lib/` 의 변경 ③ PNG 변경(`s77_*` 포함 — 이번에는 한 장도 바뀌면 안 된다) ④ `annual_review_fakes.dart`·`s77_golden_test.dart`·`labels.dart`·`pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README·질문 파일 변경 ⑤ T77-14 에 아직 `.where((String e) => e == 'src/screens/annual_review_screen.dart')` 가 `exports` 를 만드는 사슬 안에 남음 · T77-12 에 `expect(activeFlags, hasLength(flagCount));` 한 줄이 없음 ⑥ 채팅 글 P3 에 «파란» 같은 색 이름 · 머리 첫 줄 위의 섹션 밖 글 — 하나라도 있으면 반려 신호(⑥ 은 strict 나눔 ① 표기만이면 C4 정정 대상).
- CI: 새 PNG 만이라 «골든 스냅샷» 은 라벨 없이 초록이 정상(PR #28 라벨 0 그대로 · 붙이지 않는다). «분석 · 테스트(melos)» 는 Bob 의 푸시(새 `pull_request` synchronize)로 새 `main`(기록 커밋 포함) 위의 병합 미리보기를 다시 돌린다 — 기록 커밋은 문서뿐이라 수는 C4 시험과 같은 것이 기대.
- C4 가 2회차에서 볼 것: 기계 = `6043119..HEAD` test 1파일 M · hunk 가 R1·R2 자리뿐(`j_fix.diff` 와 글자 대조) · 지난 4개 해시 불변 · 전체 +448 · analyze · format · C-42 · CI / 변이 = 표 56꼴 + 참고 변이 E13~E16 전체 재실행(테스트가 강해지기만 했는지 · E16 이 T77-14 로 잡히는지 — E16 = scratchpad `j_E16.diff`(배럴 export 1줄 + 새 파일 `annual_review/extra.dart` 두 hunk) · 잡힘 = 실패 테스트 이름이 `T77-14 file checks` 인지 확인 · loading(컴파일) 실패는 잡힘으로 세지 않는다) / 정직 = 머리 첫 줄·S05·ⓡⓗ·P3·P4 틀은 복사 상자 글자와 · P1·P2 의 출력은 재실행 출력과 글자 대조(정적 37줄 · C-42 · git log · 테스트 끝 줄 — 테스트 끝 줄의 줄 머리 경과 시각(mm:ss)은 대조에서 뺀다) · 질문 파일 불변. 판정 기준 = 1회차 카드 strict 나눔(카드 194~196행 · ① 표기만 = C4 정정 · ② 코드·테스트·거짓 = 반려 · ③ 예고 변이 = 반려).
- 병합 뒤 할 일(Claude · C4 보고 §5·§6-1): 질문 파일 A1~A5 답 칸(«PR #28 `6043119` 측정값 = C4 재실측 …» · 재제출은 골든 테스트·lib·PNG 0 이라 같다) · 머리말 «다음 번호 = Q1·A6» · golden README 1행(96장)·R12c 병합본 실측 줄 · 패킷 이동은 이 재제출 패킷 `send/R12c-Bob-S77-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · `_대기/R12d-Bob-S710.md` → `send/`(머리 ⏸ → ▶ · `__R12C_SQ__`·⟦실측⟧ 채움 · 끝 기대 513 → 514 정정 — 병합본 448 + 66 · C4 보고 §6-1 3) · 팩 판은 그다음 접미 · 2회차 보고 보존본 `10_리뷰/<날짜>_R12c_C4_2회차_보고.md` · 병합 본문의 C12c-4 «C4 정정» 인용.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12c 패킷은 이 파일 하나입니다. 원 패킷 `R12c-Bob-S77.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 한다). `_완료/R12b-Bob-S76c-재제출.md` · `_완료/R12a-Bob-S76ab-재제출.md` · `_완료/R12a-Bob-S76ab-재제출2.md` · `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` 는 끝난 카드입니다.
- 범위 밖(발주자 결정 2026-10-14): C4 보고 §7 의 보강 후보 N1(전체 목록·걸러 낸 목록을 코드 글자로 갈라 싣기 — 부분 목록 검사를 하는 다음 카드) · N3(RichText·SelectableText 글자까지 — R12d ▶ 때 재드라이런과 함께) · N4(제네릭 위젯 «… 0» — 그 장면이 있는 카드)는 이 재제출에 넣지 않는다 · N2(개수 단언 한 줄 견본) · N5(골든 높이 = 재량 + 기록 — 발주자 결정 ③) · N6(커밋 = 제목만 맞추기 — 결정 ④)는 `send/_대기/R12d-Bob-S710.md` 와 설계 12 §3 R10~R16 공통 조문에 넣었다(이 카드 몫 아님 — 이 재제출은 위 «커밋» 상자 1개 그대로).
