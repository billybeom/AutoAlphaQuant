# 발송 패킷 R12b-Bob-S76c — 재제출 (1회차 반려 · 2026-10-14)

> ⬜ **「푸시해」 뒤 보냄** — 이 파일이 GitHub `main` 의 `send/` 에 있으면 이 조건은 풀린 것(이 패킷과 원 패킷의 `send/_완료/` 이동이 `main` 에 올라간 뒤 · 다른 선행 없음 — PR #27 반려 댓글 게시됨(2026-10-14 · issuecomment-6159084132) · 아래 «보내는 조건» · `send/README.md` 배지 규칙).
> 만든 날 2026-10-14 · 1회차(PR #27 · 브랜치 `ui/m7-s76c-preview` · 커밋 `c4c8e7d` · 밑동 `8bbf8e3` · 커밋 5 · CI 3/3 run 38490664308)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다. 발주자 결정(2026-10-14): ① **(A) 반려 → 재제출**(같은 브랜치·같은 PR #27 · Bob 이 R1~R4 를 **test 1파일 커밋 1개**로 · 보고 글 새 판 P1~P6 · lib 0 · PNG 0) ② 다음 카드 보강 N3·N6·N7 은 `send/_대기/` 의 R12c·R12d 두 장에 넣는다(이 패킷 몫 아님 · N1·N2·N4·N5 는 각 카드 ▶ 때). 규칙·범위(S7-6c 다음 리밸런싱 · 지금 기준 초안)는 1회차 카드(`send/_완료/R12b-Bob-S76c.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 R1~R4 + 보고 글 P1~P6** 만 담았습니다.
> 고치는 것 = **테스트 파일 하나**(`packages/ui_analytics/test/rebalance_preview_view_test.dart` — 아래 R1~R4 의 «이 줄을 → 이 줄로» 그대로 · +28/−9) **+ 채팅 글 P1~P6(부분 제출)** — `lib/**` 0 · PNG 0 · 골든 테스트·가짜·질문 파일 `inbox/S7-6c_questions.md` 0(A1~A5 행·머리말 그대로 · 답은 병합 때 통합 담당) · PR 본문·라벨 0(통합 담당이 1회차 PR 본문의 그 자리에 P1~P6 을 바꿔 넣는다). 같은 브랜치 `ui/m7-s76c-preview` · 같은 PR #27(새 PR·새 브랜치 금지) · 커밋은 맨 위에 1개 · amend·rebase·cherry-pick·reset·강제 푸시 금지.
> 판정 근거 = C4 보고 §0 · §4(설계 저장소 `10_리뷰/2026-10-14_R12b_C4_보고.md`) — 1회차 카드 보고 규칙 strict 나눔 ② «코드·테스트 결함(카드 규칙 위반 — 예 규칙 11 «else 없는 if») = 반려(재량 없음)»(카드 191행) · ③ «예고 변이가 하나라도 테스트를 그대로 통과하면 반려»(카드 192행 · 511행). [가] 3건: **C12b-1** T76c-14 의 부재 단언 넷이 else 없는 if(c4c8e7d 929·932·935·945행 · 카드 171·492행 위반 · R11b C4b-5 와 같은 모양) · **C12b-2** 예고 변이 «늦은 결과 반영(identical 빼기)» 의 onError 쪽 꼴 F04b 생존 · **C12b-3** 예고 변이 «previewRebalance 에 plannedDate 넘기기» 의 둘째 요청 꼴 F02c 생존(C12b-2·3 은 카드 최소 목록이 그 장면을 요구하지 않은 구멍이기도 하다 — 통합 담당 드라이런에도 같은 구멍). [나] 3건(C12b-4~6 · 표기만 — P3~P5 로 함께 고친다) · 거짓 주장 0. 합격(그대로): lib · 새 PNG 10 · 질문 파일 · `flutter test` 354 → 404 · 정적 38줄 출력 · CI 3/3.
> 🔴 **N2 조문 적용(12 §3 · 2026-10-14) = 부분 제출로 못박는다** — 이 재제출에서 Bob 은 «1회차 글자 그대로» 를 다시 쓰지 않는다. 바뀌는 자리 **P1~P6 만** 채팅으로 내고, 통합 담당(C4)이 1회차 PR #27 본문의 그 자리에 바꿔 넣는다. 1회차 글의 나머지(① 화면 ID·name-status 18줄·C-42 3줄 · ② 12항 15줄과 괄호 · ③ «로딩»·«정상»·«초안»·«빈 초안» 4줄 · 골든 표 머리·나머지 6행 · ④ · ⑤ «없음»)는 Bob 이 다시 내지 않는다(다시 내면 통합 담당은 그 글을 쓰지 않는다). P1~P6 의 글자는 명령 출력(파일로 떠서) 아니면 이 패킷의 복사 상자뿐이다.
> 🔴 **main 병합 안 함** — PR CI 는 PR 의 병합 미리보기를 돌린다(R11a·R11b 재제출 선례). Bob 의 푸시가 CI 를 다시 돌린다(새 PNG 만이라 «골든 스냅샷» 은 라벨 없이 초록이 정상).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R12b-Bob-S76c.md` 의 `send/_완료/` 이동 · `send/README.md` 의 ▶ 줄과 R12b 행·재제출 행 · `rounds.md` R12b 행·재제출 행과 **같은 푸시**로 `main` 에 올린다(0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 🔴 같은 푸시에서 `inbox/S7-6c_questions.md` · golden README · `send/_대기/` 의 `__R12B_SQ__`·⟦실측⟧ 자리 · 01~05 사본은 건드리지 않는다(병합 때).
> 🔴 **보내는 조건** — 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R12b-Bob-S76c.md` 는 `send/` 에 없음). 확인 = `git cat-file -t origin/main:docs/ai-context/send/R12b-Bob-S76c-재제출.md`(= `blob`) · PR #27 «Conversation» 에 C4 반려 댓글(«C4 병합 검사 — R12b-Bob-S76c 1회차: 반려(재제출)»)이 있다(게시됨) · 그 밖의 선행(infra PR 등)은 없다.
> C4 수정안 시험(2026-10-14 · 통합 담당 worktree `C:/Work/AAQ-claude-c4bj` @ `c4c8e7d` · 끝에 삭제): 아래 R1~R4 와 같은 글자(+28/−9)를 넣고 `dart format --output=none --set-exit-if-changed .` 0 changed · `flutter analyze --fatal-infos` No issues · 뷰 `+41: All tests passed!` · `flutter test`(ui_analytics 전체) `+405: All tests passed!` · S29 16 · S30 6 · «expect 가 든 else 없는 if» 0 · 그 위에 변이를 넣으면 F04b → `T76c-10 last request only b_then_a_error` 실패 · F02c → `T76c-05 preview only after tap no args` 실패(둘 다 잡힘). 안 돌린 것 = `melos.bat run test`(중첩 melos · CI 몫).

## 0. 한 줄 목적

PR #27 의 테스트 파일 하나를 R1~R4 글자대로 고쳐 커밋 1개로 올리고, 바뀌는 보고 자리 P1~P6 만 채팅으로 다시 내기 — **lib·PNG·골든 테스트·가짜·질문 파일은 한 글자도 바꾸지 않고, 지난 5개 커밋도 고쳐 쓰지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s76c-preview` · 같은 PR #27.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). PR #27 의 C4 반려 댓글은 이미 올라가 있습니다.
2. Bob 은 **1회차와 같은 대화여도 됩니다**(Bob 폴더가 지금 `ui/m7-s76c-preview` `c4c8e7d` 입니다 · 1회차 카드의 «(5) 가 마지막 커밋» 은 이 카드가 덮습니다 — 아래 본문 0단계). 새 대화로 시작해도 됩니다 — 본문은 Bob 이 1회차를 기억하지 못한다는 전제로 썼고, 부분 제출이라 1회차 글을 다시 붙여 줄 필요가 없습니다.
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12b-Bob-S76c-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R12b-Bob-S76c-재제출.md` · 가지 `rec/r12-cards` · 2026-10-14 Claude 확인 · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R12b-Bob-S76c.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부** — ```text 다음 줄(«R12b-Bob-S76c 재제출 요청»)부터 닫는 ``` 직전 줄까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12b 패킷은 **이것 하나**(`R12b-Bob-S76c-재제출.md`)입니다. 원 패킷 `R12b-Bob-S76c.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R12a-Bob-S76ab-재제출.md` · `_완료/R12a-Bob-S76ab-재제출2.md` · `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` 는 끝난 카드이고, `send/_대기/` 의 `R12c-Bob-S77.md` · `R12d-Bob-S710.md` 는 아직 보내지 않는 카드입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12b-Bob-S76c 재제출 요청»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12b-Bob-S76c 재제출 요청 — 1회차(PR #27 · c4c8e7d) 판정: 반려(재제출). 같은 브랜치 ui/m7-s76c-preview · 같은 PR #27 에 커밋 1개를 맨 위에 더하십시오(새 PR·새 브랜치 금지).
이번에 고치는 곳은 테스트 파일 하나(packages/ui_analytics/test/rebalance_preview_view_test.dart — 아래 R1~R4 글자 그대로)와 채팅 글 P1~P6 뿐입니다.
🔴 lib 0 · PNG 0 · 골든 테스트·가짜·질문 파일 0 · amend·rebase·cherry-pick·reset·강제 푸시 0 — 하나라도 어기면 반려입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12b 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner · ui/m7-s79-goal-path · ui/m7-s76ab-rebalance)는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #27 · 브랜치 ui/m7-s76c-preview(커밋 c4c8e7d)에 아래 R1~R4 커밋 하나를 «더하는» 일입니다. R1~R4 는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main · git pull 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돌기 때문에, main 에 들어간 기록 커밋은 병합하지 않아도 CI 에 들어갑니다.
🔴 1회차 카드의 «(할 일 (1)~(5) 커밋이 끝난 뒤 — (5) 가 마지막 커밋)» 은 이번에 이 카드가 덮습니다 — 재제출 커밋 1개를 맨 위에 더하는 것이 이번 일입니다.
   지난 5개 커밋(c4c8e7d · ef25bf3 · 21b6296 · 4300e0b · 059ca60 — 순서·제목 포함)은 그대로 둡니다(커밋 제목 ≠ 내용 · (5) 의 format 밖 정리 2건은 통합 담당이 기록으로 닫았습니다 · 고치려 하면 반려).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git branch --show-current     ← ui/m7-s76c-preview 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m7-s76c-preview
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git rev-parse --short HEAD    ← c4c8e7d 이면 정상 · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m7-s76c-preview   ← c4c8e7d · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R12b-Bob-S76c-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R12b-Bob-S76c.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 · _대기 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R12b-Bob-S76c-» 로 시작하는 줄이 있으면 정상.
        «R12b-Bob-S76c-재제출» 줄이 없거나 꼬리 없는 «R12b-Bob-S76c.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 카드가 먼저 왔습니다.
  ls docs/ai-context/send/R12b-Bob-S76c.md   ← 보여야 함(이 브랜치에는 1회차 카드가 있다 — 아래 «규칙 요약» 이 가리키는 파일 · 읽기만)
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
🔴 이 카드와 1회차 카드(R12b-Bob-S76c.md)의 글이 다르면 이 카드가 이깁니다 — 예: 커밋은 재제출 커밋 1개만 맨 위에 · 질문 파일을 고치지 않는다 · 골든을 다시 찍지도 dy 를 다시 재지도 않는다 ·
   채팅 글은 이 카드 «■ 제출» 의 P1~P6 만(부분 제출) · T76c-10 은 경우 셋 · 테스트 수 기대 = 뷰 +41 · 전체 +405 · main 을 병합하지 않는다.
   PR #27 반려 댓글의 «보고 글 새 판 ①~⑤ 를 채팅으로 낸다» 도 이 카드의 P1~P6 부분 제출이 이깁니다(댓글은 N2 조문 적용 전 글자 · 1회차 글 ①~⑤ 를 다시 내지 않는다).

■ 규칙 요약 (1회차 카드 = 이 브랜치의 docs/ai-context/send/R12b-Bob-S76c.md(main 에서는 send/_완료/ 로 옮겨졌다 — 글자는 같다)의 규칙 11(152~174행) · 보고 규칙(189~200행) · 테스트 최소 목록(391~517행) · 정적 묶음(519~574행)이 유효 —
   단 이 카드와 다른 곳은 이 카드가 이긴다 · 여기엔 핵심만)
· 이번에 고치는 곳 = 아래 한 파일뿐입니다.
    packages/ui_analytics/test/rebalance_preview_view_test.dart   (R1~R4 — T76c-05 · T76c-10 · T76c-14 본문만 · 새 testWidgets 줄을 더하지 않는다 · T76c-10 의 경우 목록에 한 줄)
· 🔴 고치면 반려: 위 한 파일 밖의 전부 — packages/ui_analytics/lib/**(rebalance_preview_screen.dart · labels.dart · analytics_providers.dart · ui_analytics.dart 포함 · 🔴 lib 0) ·
  test/golden/goldens/*.png 전부(s76c_* 10장 포함 · 🔴 PNG 0 · --update-goldens 를 돌리지 않는다) · test/golden/s76c_golden_test.dart · test/rebalance_preview_fakes.dart ·
  그 밖의 기존 테스트 전부 · test/golden/ 의 하네스·README · test/flutter_test_config.dart · domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml ·
  docs/ai-context/**(질문 파일 inbox/S7-6c_questions.md 포함).
  🔴 PNG 나 lib 가 하나라도 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 테스트 규칙(1회차 카드 규칙 11 — 이번에 걸린 곳만 글자 그대로):
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) ·
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기)와 firstWhere 다 · 사슬 목록을 만드는 collection-if(«있는 것만 넣는다»)는 «없는 쪽은 따로 단언»과 짝일 때만 허용 ·
   단언이 없는 동작 if/else(R2 의 «if (d.aFails) { completeError } else { complete }» — 장면 만들기)는 금지 대상이 아니다.
   ⓡ = expect(find.text(AnalyticsLabels.retryButton), findsNothing); 줄 · ⓗ = expect(<목록>, hasLength(n)); 전제 줄 — 정적 S29·S30 이 정확히 16 · 6 이어야 한다(R1~R4 는 ⓡ·ⓗ 줄을 더하지도 빼지도 않는다 ·
   🔴 R3 는 hasLength 가 아니라 isNull 이다 — 쓰면 S30 이 7 이 된다).
  (그 밖 — 테스트 이름 그대로(새 경우 이름 b_then_a_error 는 ASCII) · 테스트에 한국어 리터럴 금지 · 주석에도 한국어를 새로 쓰지 않는다(정적 S01) · 새 띄우기 도우미·새 가짜 금지.)
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인.
· 보고 규칙(1회차 카드 190~192행 strict 나눔 그대로): ① 보고 표기만의 결함 = 통합 담당(C4)이 PR 본문을 정정하고 병합 · ② 코드·테스트 결함과 거짓 주장(보고 ≠ 코드·파일·PNG) = 반려(재량 없음) · ③ 예고 변이 통과 = 반려.
  🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 머리 첫 줄과 P1~P6 머리는 «■ 제출» 상자 글자 그대로).
🔴 보고 규칙 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   명령 출력은 줄을 고르거나 · 줄이거나 · 앞머리를 붙이거나 · 백틱으로 감싸지 않고 그대로 옮깁니다. 이 카드가 «복사 상자» 로 준 글자는 한 글자도 바꾸지 않고 붙입니다.
   🔴 git log · flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
      <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다 — 새 화면 1(«화면» 배치 1~7 · _requestPreview 모양 · 인자 없는 previewRebalance() · 결과 캐시 0 · then·onError 양쪽 identical · reportError 0) ·
  공용 3파일 더하기만(S27 4/14/1 · 둘째 수 0) · 주입 2개 카드 글자 그대로 · Key 11 · 라벨 2(바이트 = 카드) · lib/src/rebalance/ 없음.
테스트는 R1~R4 자리 밖이 모두 맞았습니다 — 최소 목록 경우 수 40 · ⓡ 16 · ⓗ 6 정확히 · C4b-12·13·14 반영 · copyWith 세 곳 · 한국어 리터럴 0 · ASCII 이름.
flutter test 354 → 404 · analyze --fatal-infos No issues · format 0 changed · C-42 +14(S7-6c 1파일 · 합 3파일 · 38줄) · 새 PNG 10장(390×844) · 기존 76장 그대로 · dy 10값 = C4 재실측 · CI 3/3.
보고에서 맞은 곳 — 거짓 주장 0 · 정적 38줄 출력 118줄이 C4 재실행과 한 글자도 다르지 않았습니다 · ① 18줄·5커밋·C-42 3줄 · ② 12항 15줄·괄호 12 · S05 2줄 · ④ 5행 · ⑤ «없음».
카드가 예고한 변이 30항목은 기본형이 모두 잡혔습니다(꼴 57 중 55 — 남은 2꼴이 아래 ②).

■ 왜 반려인가 — 카드 / 실제 (C4 검사 갈래가 따로 냈고 통합 담당이 코드·변이를 직접 다시 확인)
① T76c-14 «없는 쪽» 단언 (C12b-1 · 테스트 결함 · strict 나눔 ②)
   카드:  규칙 11(171행) «🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기)» · T76c-14(492행) «없는 쪽은 따로 단언한다(if/else 양쪽 — staleBannerTitle 0 · find.byIcon(Icons.block) 0 · s76c-notice 0 · …)» ·
          보고 규칙(191행) «코드·테스트 결함(카드 규칙 위반 — 예 규칙 11 «else 없는 if» …) = 반려(재량 없음)».
   실제:  rebalance_preview_view_test.dart(c4c8e7d) 929행 if (!d.isStale) { … findsNothing } · 932행 if (activeFlags.isEmpty) { … findsNothing } · 935행 if (!hasPreview) { … findsNothing ×2 } ·
          945행 if (!isBlocked) { … findsNothing } — 넷 다 else 가 없다(939행 if (d.isNone) … else … 만 짝).
          실효 손실은 0 이다(있는 쪽은 921~922행 사슬 루프의 findsOneWidget 이 본다). 그래도 규칙 위반이다.
   선례:  R11b C4b-5(T79-02 — else 없는 if 둘 + 빈 if 블록 · 그때도 «실효 손실 없음»)가 [가] 반려였고, 이 카드는 그 교훈으로 492행에 «if/else 양쪽» 을 굵게 적었다.
② 예고 변이 두 꼴이 테스트 셋(뷰·골든 + 정적 38줄 + C-42)을 모두 통과 (C12b-2 · C12b-3 · strict 나눔 ③)
   카드:  511행 «병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려)».
   C12b-2(항목 «늦은 결과 반영(identical 빼기)» 의 onError 쪽 꼴):
          then 쪽은 그대로 두고 onError 쪽의 identical(future, _pending) 확인만 빼면, 앞 요청이 늦게 «에러» 로 끝날 때 마지막 요청의 초안이 지워지고 에러 뷰가 뜬다 —
          T76c-10 은 늦은 «성공» 두 경우만 보므로 이 꼴이 산다(then 쪽·양쪽 꼴은 T76c-10 이 잡는다).
   C12b-3(항목 «previewRebalance 에 plannedDate 넘기기» 의 둘째 요청 꼴):
          첫 요청은 인자 없이 · 초안이 뜬 뒤의 다시 탭부터 plannedDate 를 넘겨도 산다 — T76c-05 둘째 탭이 previewCalls.length 만 보고 그 호출의 인자를 보지 않는다.
   🔵 두 구멍은 카드 최소 목록이 그 장면을 요구하지 않아 생긴 것이기도 하다(통합 담당 드라이런에도 같은 구멍). Bob 코드 자체는 맞다(then·onError 양쪽에 identical · previewRebalance() 인자 없이).
      막는 글자는 통합 담당이 시험해 통과한 것을 아래 R2·R3 로 그대로 준다 — Bob 이 손으로 새로 짤 테스트는 없다.
함께 고칠 것: R4(C12b-8 · 공통 규칙 «탭 뒤에는 pump() 두 번» — T76c-10 의 두 탭 뒤 pump 가 한 번씩 · 같은 파일이라 함께) · 표기 C12b-4~6 · C12b-7 = 아래 P2~P5.
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 생성물은 git 에 없습니다(브랜치를 바꿨거나 새로 받았으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류 · 생성물은 git 이 무시하므로 git status 는 빈 채).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test test/rebalance_preview_view_test.dart   ← 시작 기준: 끝 줄 «+40: All tests passed!»(1회차 그대로)
  flutter test   ← 시작 기준: 끝 줄 «+404: All tests passed!» · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·푸시 -u 는 하지 않습니다):
   · docs/ai-context/send/R12b-Bob-S76c.md(1회차 카드 — 이 브랜치에 있다) — 152~174행 규칙 11 · 444~446행 T76c-05 · 468~471행 T76c-10 · 488~493행 T76c-14 · 509~517행 ⓡⓗ 기대·예고 변이
   · packages/ui_analytics/test/rebalance_preview_view_test.dart 의 아래 R1~R4 자리(c4c8e7d 행 번호 · 고치기 전에 «이 줄을» 상자와 한 글자씩 대조)

■ 고칠 것 — R1~R4 (1회차 반려 · C4 2026-10-14) — 파일 하나 · 아래 상자의 «이 줄을 → 이 줄로» 그대로 · 손으로 다시 짜지 않는다
   🔴 행 번호는 c4c8e7d 의 것이다. 아래 차례(파일 **아래쪽부터** 위로 — ⑴ → ⑺)로 고치면 앞의 수정이 뒤 자리의 행 번호를 밀지 않는다.
   🔴 «이 줄을» 상자와 파일의 그 행이 한 글자라도 다르면(들여쓰기 포함) 고쳐 쓰지 말고 멈춘 뒤 채팅으로 — 파일이 c4c8e7d 가 아니다.
   🔴 상자 안의 들여쓰기(빈칸 수)를 그대로 옮긴다 · 탭 문자 0 · 상자 밖의 줄은 한 글자도 바꾸지 않는다(빈 줄 포함) · lib 0 · PNG 0.

⑴ R1 둘째 토막 (C12b-1 · T76c-14 · 945~947행) — else 없는 if → if/else 짝
      ┌── 이 줄을(945~947행 · 3줄)
      if (!isBlocked) {
        expect(find.byKey(const Key('s76c-blocked')), findsNothing);
      }
      └──
      ┌── 이 줄로(5줄)
      if (isBlocked) {
        expect(find.byKey(const Key('s76c-blocked')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s76c-blocked')), findsNothing);
      }
      └──

⑵ R1 첫 토막 (C12b-1 · T76c-14 · 929~938행) — else 없는 if 셋 → if/else 짝 셋(939~944행 «if (d.isNone) … else …» 은 그대로 둔다)
      ┌── 이 줄을(929~938행 · 10줄)
      if (!d.isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }
      if (activeFlags.isEmpty) {
        expect(find.byIcon(Icons.block), findsNothing);
      }
      if (!hasPreview) {
        expect(find.byKey(const Key('s76c-notice')), findsNothing);
        expect(find.byKey(const Key('s76c-draft')), findsNothing);
      }
      └──
      ┌── 이 줄로(17줄)
      if (d.isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }
      if (activeFlags.isNotEmpty) {
        expect(find.text(activeFlags.first.label), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.block), findsNothing);
      }
      if (hasPreview) {
        expect(find.byKey(const Key('s76c-notice')), findsOneWidget);
        expect(find.byKey(const Key('s76c-draft')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s76c-notice')), findsNothing);
        expect(find.byKey(const Key('s76c-draft')), findsNothing);
      }
      └──
   (있는 쪽 = findsOneWidget · 없는 쪽 = findsNothing — 사슬 목록을 만드는 904~918행 collection-if 와 920~927행 사슬 루프는 그대로 둔다.)

⑶ R2 셋째 토막 (C12b-2 · T76c-10 · 533행 뒤에 한 줄) — 늦은 에러 뒤 에러 뷰 0
      ┌── 이 줄 바로 뒤에(533행 · 1줄 — 같은 글자 줄이 c4c8e7d 946행에도 있다(⑴ 뒤에는 아래로 밀린다) · 🔴 533행 쪽이다: 529행 completerA.complete(blockedResult); 아래 · 534행 «} else {» 위)
        expect(find.byKey(const Key('s76c-blocked')), findsNothing);
      └──
      ┌── 이 줄을 더한다(1줄)
        expect(find.byType(AnalyticsErrorView), findsNothing);
      └──

⑷ R2 둘째 토막 (C12b-2 · T76c-10 · 529행) — 앞 요청 A 를 경우에 따라 에러로 끝낸다(단언 없는 동작 if/else — 금지 대상 아님)
      ┌── 이 줄을(529행 · 1줄)
        completerA.complete(blockedResult);
      └──
      ┌── 이 줄로(5줄)
        if (d.aFails) {
          completerA.completeError(StateError('x'));
        } else {
          completerA.complete(blockedResult);
        }
      └──

⑸ R4 (C12b-8 · T76c-10 · 518~521행) — 두 탭 뒤 pump 두 번
      ┌── 이 줄을(518~521행 · 4줄)
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      └──
      ┌── 이 줄로(6줄)
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byKey(const Key('s76c-preview-button')));
      await tester.pump();
      await tester.pump();
      └──

⑹ R2 첫 토막 (C12b-2 · T76c-10 · 482~485행) — 경우 목록에 셋째 경우 b_then_a_error(aFails 칸을 더한다)
      ┌── 이 줄을(482~485행 · 4줄)
  for (final ({String name, bool bFirst}) d in <({String name, bool bFirst})>[
    (name: 'b_then_a', bFirst: true),
    (name: 'a_then_b', bFirst: false),
  ]) {
      └──
      ┌── 이 줄로(6줄)
  for (final ({String name, bool bFirst, bool aFails}) d
      in <({String name, bool bFirst, bool aFails})>[
        (name: 'b_then_a', bFirst: true, aFails: false),
        (name: 'a_then_b', bFirst: false, aFails: false),
        (name: 'b_then_a_error', bFirst: true, aFails: true),
      ]) {
      └──
   (경우 수 2 → 3 · testWidgets 줄 수는 그대로 · 이름 'T76c-10 last request only ${d.name}' 그대로 · ⓡ·ⓗ 줄 수 그대로 — 본문에 한 줄씩.)

⑺ R3 (C12b-3 · T76c-05 · 188행 뒤에 한 줄) — 다시 탭한 둘째 요청도 인자 없이
      ┌── 이 줄 바로 뒤에(188행 · 1줄)
    expect(whatIf.previewCalls.length, 2);
      └──
      ┌── 이 줄을 더한다(1줄)
    expect(whatIf.previewCalls[1], isNull);
      └──
   (🔴 hasLength 가 아니다 · previewCalls.length 줄은 그대로 둔다 — S30 은 6 그대로.)

고친 뒤 확인(packages/ui_analytics 에서 · 고치지 않고 보기만):
  git diff --stat                     ← 마지막 줄이 « 1 file changed, 28 insertions(+), 9 deletions(-)»(위에 파일 줄 하나가 더 있는 것이 정상 · 다르면 상자와 다시 대조 · 커밋하지 않는다)
  dart format --output=none --set-exit-if-changed test/rebalance_preview_view_test.dart   ← «Formatted 1 file (0 changed)» 꼴 · 바뀐 줄이 있으면 상자와 다르게 옮긴 것 — 다시 대조
  git grep -c -E "^ {6}if \(" -- test/rebalance_preview_view_test.dart        ← «test/rebalance_preview_view_test.dart:19»(c4c8e7d 와 같은 수)
  git grep -c -E "^ {6}\} else \{" -- test/rebalance_preview_view_test.dart   ← «test/rebalance_preview_view_test.dart:17»(c4c8e7d 13 + R1 넷)
  git grep -n -E "^ {6}if \(!" -- test/rebalance_preview_view_test.dart        ← 출력 없음(c4c8e7d 에서는 929 · 935 · 945 세 줄 — R1 이 없앤다)
  (세 줄 다 «else 없는 if 0» 의 자기 점검이다 · 다르면 커밋하지 말고 멈춘 뒤 출력을 채팅으로 · 이 출력은 채팅 글에 붙이지 않는다)

커밋 — 하나 · 맨 위에(R1~R4 전부 · format:fix 가 바꾼 줄이 있으면 그것도 같은 커밋 — 기대는 0 줄):
      ┌── 커밋 제목 복사 시작(다음 줄부터 · 1줄)
[M7] R12b (6) 재제출 — T76c-14 if/else 짝 · T76c-10 늦은 에러 · T76c-05 둘째 요청 인자 없음
      └── 커밋 제목 복사 끝(이 줄 앞까지)
   🔴 지난 커밋(c4c8e7d · ef25bf3 · 21b6296 · 4300e0b · 059ca60)을 고치지 않습니다 — rebase·amend·cherry-pick·reset·squash·강제 푸시 금지.

■ 고치지 않는 것 (1회차가 맞았거나 이 카드 밖 — 손대면 반려)
 · lib/** 전부 · PNG 전부(s76c_* 10장 포함 — --update-goldens 금지) · s76c_golden_test.dart · rebalance_preview_fakes.dart · labels.dart · 그 밖의 테스트 파일
 · 골든 dy — lib·골든 테스트·PNG 가 그대로라 다시 재지 않습니다(질문 파일 A1~A5 = 1회차 실측 = C4 재실측 · s76c_golden_test.dart 를 열어 lessThan(0) 으로 바꾸는 일도 하지 않는다)
 · 질문 파일 docs/ai-context/inbox/S7-6c_questions.md — A1~A5 행·머리말(«다음 번호» 포함)을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 닫는다)
 · R1~R4 상자 밖의 테스트 본문 전부(T76c-01~04 · 06~09 · 11~13b · 15~18 · T76c-05 의 첫 탭 부분 · T76c-10 의 단언 나머지 · T76c-14 의 경우 목록·사슬 목록·사슬 루프·d.isNone if/else·ⓡ 줄)
 · ⓡ·ⓗ 줄 — 더하지도 빼지도 않는다(S29 16 · S30 6) · 테스트 이름 · pumpRebalancePreview 의 addTearDown(기능 같음 — 기록만)
 · 지난 5개 커밋 · 보강 후보(C4 보고 §7 N1·N2·N4·N5 — 다음 카드 몫)는 이번에 넣지 않는다(넣으면 범위 밖 변경)

■ 질문 파일
· 이번 R1~R4 는 전부 이 패킷이 정했고 lib·PNG 가 그대로라 잴 것도 없으므로, 질문 파일은 바뀌지 않는 것이 정상입니다(새 행 0).
· 🔴 새 행이 필요해 보이면(측정·추측·질문 어느 것이든) 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 — 이번 커밋은 테스트 파일 하나만 add 하고, 아래 «git diff --name-status c4c8e7d HEAD» 는 테스트 한 줄이어야 합니다.

(읽는 법 — 아래 «■ 정적 묶음» 절은 1회차 카드 519~574행 글자 그대로다. 이 재제출에서는 «PR 본문 ②» = 채팅 글 P2 · «아래 «테스트 수 묶음»» = 이 카드의 «■ 테스트 수 묶음» ·
  ««■ 제출» 의 C-42 dart test» = 이 카드에서는 붙이지 않는다(C-42 줄은 1회차 글 그대로 — lib 불변) · «0단계 «시작 기준 S15»·«시작 기준 S16b»» = 1회차 시작 기준(6 · 10) — 그래서 S15 = 7줄 · S16b = 11줄 ·
  대조에서 빼는 것 = 빈 줄 · EXIT 표기 · warning:·error: 줄 · PowerShell 장식 줄 · 줄 머리 경과 시각 · 한국어가 깨져 보이면 [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 돌린다.)
■ 정적 묶음 — packages/ui_analytics 에서 아래 38줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 38줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로(줄 수가 많아도 · «길어서 줄였습니다» 같은 주의 문장으로 갈음하지 않는다 · R12a C12a-2).
  🔴 **테스트 이름·패키지 이름 한 낱말이라도 다르면 반려 — 대조에서 빼는 것은 빈 줄·EXIT 표기·warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐**(R12a 2회차 C12a2-1 — 다시 돌린 출력을 채팅 글로 옮기다 테스트 제목의 패키지 이름 한 낱말이 바뀌어 반려).
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(아래 «테스트 수 묶음» 세 줄 · «■ 제출» 의 C-42 dart test · Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 → <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S27·S34 만 git diff 다 — «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다(나오면 지우지 않고 그대로 붙인다 · EXIT 값은 보지 않는다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/rebalance_preview_view_test.dart test/rebalance_preview_fakes.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/rebalance_preview_view_test.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/rebalance_preview_view_test.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshape 0 (screen)"; git grep -nE "\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes 0 (screen)"; git grep -n "AppRoutes" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S06a CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S06b CommandApi 0 (screen)"; git grep -n "CommandApi" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08a DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S08b DateTime 0 (screen)"; git grep -n "DateTime" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 link literals 0 (lib + new tests)"; git grep -nE "'aaq://|'handbook://" -- lib test/rebalance_preview_view_test.dart test/rebalance_preview_fakes.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S11 toStringAsFixed NumberFormat 0"; git grep -nE "toStringAsFixed|NumberFormat" -- lib; echo "EXIT:$?"
echo "## S12 tap widgets 0 (screen)"; git grep -nE "GestureDetector|InkWell|ActionChip|InputChip|onSelected|onDeleted" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S13 Colors 0 (screen providers labels)"; git grep -nw Colors -- lib/src/screens/rebalance_preview_screen.dart lib/src/providers lib/l10n; echo "EXIT:$?"
echo "## S14 planner 0 (T74-22 scope)"; git grep -n "planner" -- lib/ui_analytics.dart lib/src/screens lib/src/widgets lib/src/providers; echo "EXIT:$?"
echo "## S15 autoDispose (start + 1)"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "src/rebalance/|goal_path/|chart/|explore/|planner|perf_chart|analytics_skeleton|analytics_error_view|stale_banner|safety_block_banner" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports (start + 1)"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 Scaffold AppBar SafeArea SnackBar 0 (screen)"; git grep -nE "Scaffold|AppBar|SafeArea|SnackBar" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S18 unread raw fields 0 (screen - C-42 3)"; git grep -nE "\.(planId|plannedDate|before|after|fundingSteps|quantity|limitPrice|side|commission|tax|total|source|expectedKind|previewRoute|detailDeepLink|symbol|sleeve|code|kind|mode)\b" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 decimal literals 0 (screen - C-42 6)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S25 percent elevation 0 (screen)"; git grep -nE "%|elevation" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S26 sort filter 0 (screen providers - C-42 9)"; git grep -nE "\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|reverse:\s*true" -- lib/src/screens/rebalance_preview_screen.dart lib/src/providers/analytics_providers.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 s76c keys (11 lines - each key once)"; git grep -h -o -E "'s76c-[a-z-]+'" -- lib; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/rebalance_preview_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/rebalance_preview_view_test.dart; echo "EXIT:$?"
echo "## S31 previewRebalance 1 line (screen)"; git grep -n "previewRebalance" -- lib; echo "EXIT:$?"
echo "## S32 watchNext 1 line (providers)"; git grep -n "watchNext" -- lib; echo "EXIT:$?"
echo "## S33 reportError 0 (screen)"; git grep -nE "reportError|FlutterError" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S34 lib files changed (A 1 + M 3)"; git diff --name-status origin/main...HEAD -- lib; echo "EXIT:$?"
  (줄의 뜻과 기대 — 출력 없음 = S01(주석 줄 말고) · S02a·S02b(테스트 이름 ASCII 만 · «—»·«→» 도 금지) · S03·S04·S06a~S14·S16·S17~S26·S33(주석 포함 · S17 은 ScaffoldMessenger 도 ·
   S18 = C-42 ③ 의 S7-6c 몫 + symbol·sleeve·code·kind·mode · S19~S23 = 12항 1·3·11항 근거 · S22·S23 = C-38 ⑫ 와 같은 정규식 · S24·S25 = C-42 ⑥ + Card() 기본 고도 · S26 = C-42 ⑨) ·
   S05 = 2줄(SafetyBlockBanner onOpenLink 자리 · 차단 카드 버튼 onPressed 자리 · 줄 번호는 내 코드 그대로(드라이런은 106·288) · build 본문·import·주석 줄 0) ·
   S15 = 0단계 «시작 기준 S15» + 1줄(nextRebalanceProvider · 드라이런 6 → 7 · 대소문자 구분 · 주석도 센다) ·
   S16b = 0단계 «시작 기준 S16b» + 1줄(rebalance_event_screen 과 rebalance_timeline_screen 사이 · 드라이런 10 → 11) ·
   S27 = 세 줄의 둘째 수(삭제) 전부 0(첫째 수 = 드라이런 labels 4 · providers 14 · 배럴 1 — labels·providers 는 주석·빈 줄에 따라 다를 수 있다 · 기준은 둘째 수 0 · 배럴 1) · S28 = Key 표 11개가 각 1줄(대조는 글자 집합 · 12줄 이상 = 두 번 · 10줄 이하 = 빠짐) ·
   S29·S30 = 16 · 6(최소 목록의 ⓡ·ⓗ 표시 수 — 다르면 반려) · S31 = 1줄(화면 파일 _requestPreview 안) · S32 = 1줄(providers R12b 절) ·
   S34 = A packages/ui_analytics/lib/src/screens/rebalance_preview_screen.dart + M packages/ui_analytics/lib/l10n/labels.dart · M packages/ui_analytics/lib/src/providers/analytics_providers.dart ·
         M packages/ui_analytics/lib/ui_analytics.dart 의 4줄뿐(줄 순서 = git 출력 그대로 · 경로 가나다순 — labels → providers → screens → ui_analytics.dart)
   🔴 S27·S34(git diff)의 경로는 저장소 뿌리 기준(packages/ui_analytics/…)으로 찍힌다 — git grep(cwd 기준 lib/…)과 꼴이 다른 것이 정상 · 출력을 손으로 고치지 않는다)
  (🆕 이번 기대 — lib·PNG·다른 테스트 불변이고 R1~R4 는 한국어·비 ASCII 이름·ⓡ·ⓗ 줄을 더하지 않으므로, 38줄의 출력은 1회차 출력(118줄)과 같다(EXIT 표기·warning 줄·PowerShell 장식 줄 말고):
   S05 = lib/src/screens/rebalance_preview_screen.dart:117 · :242 두 줄 · S15 7줄 · S16b 11줄 · S27 = 4 0 · 14 0 · 1 0 · S28 11줄 · S29 = test/rebalance_preview_view_test.dart:16 · S30 = test/rebalance_preview_view_test.dart:6 ·
   S31 screen 1줄 · S32 providers 1줄 · S34 = A 1 + M 3 · 나머지 출력 없음 — C4 1회차 재실행과 같음 · 🔴 S29·S30 이 16·6 과 다르면 제출하지 말고 R1~R4 를 다시 본다 · 그 밖의 줄이 1회차와 다르면 멈춘 뒤 채팅으로)

■ 테스트 수 묶음 — packages/ui_analytics 에서 세 줄(P2 의 테스트 수 · P6 의 끝 줄은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다 · 파일로 떠서 붙인다)
  flutter test test/rebalance_preview_view_test.dart   ← 끝 줄 «+41: All tests passed!» 기대(1회차 +40 · R2 로 T76c-10 셋째 경우 +1 — C4 시험 «+41»)
  flutter test test/golden/s76c_golden_test.dart       ← «+10: All tests passed!» 기대(1회차와 같음)
  flutter test                                         ← 끝 줄 «+405: All tests passed!» 기대(1회차 404 + 1 — C4 시험 «+405»)
  PowerShell 에서 파일로 뜨는 꼴(예 — 이름은 아무것이나 · 저장소 밖):
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    flutter test test/rebalance_preview_view_test.dart | Out-File -Encoding utf8 $env:TEMP\r12b_t_view.txt
    Get-Content -Encoding UTF8 $env:TEMP\r12b_t_view.txt | Select-Object -Last 1   ← 이 줄을 그대로 복사(golden · 전체도 같은 꼴로 r12b_t_golden.txt · r12b_t_all.txt)

■ 제출
  (R1~R4 를 고치고 «고친 뒤 확인» 이 기대와 같은 뒤)
  cd packages/ui_analytics
  flutter test test/rebalance_preview_view_test.dart   ← 먼저 이 파일만 · «+41: All tests passed!»(실패하면 고친 곳을 상자와 다시 대조 · lib 를 고치지 않는다)
  flutter test   ← 옵션 없이 전부 통과 · «+405: All tests passed!»
  cd ../..
  melos.bat run format:fix
  git status --short   ← M 은 packages/ui_analytics/test/rebalance_preview_view_test.dart 하나뿐이어야 합니다(PNG·lib·질문 파일의 M = 금지 → git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  git add packages/ui_analytics/test/rebalance_preview_view_test.dart
  git commit -m "[M7] R12b (6) 재제출 — T76c-14 if/else 짝 · T76c-10 늦은 에러 · T76c-05 둘째 요청 인자 없음"   ← 위 «커밋 제목» 상자 글자 그대로
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git diff --name-status c4c8e7d HEAD
     ← 재제출 커밋의 변경만 봅니다. 🔴 정확히 이 한 줄이어야 합니다:
        M	packages/ui_analytics/test/rebalance_preview_view_test.dart
        다른 줄이 한 줄이라도 나오면(lib · PNG · 질문 파일 · rebalance_preview_fakes · s76c_golden_test …) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git log --oneline -2   ← 맨 위 = 재제출 커밋 · 그 아래 = c4c8e7d(지난 커밋은 그대로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #27 자동 반영 · 새 PR·라벨·강제 푸시(--force · --force-with-lease)·rebase·main 병합 금지)
  git log --oneline origin/main..HEAD   ← 아래 P1 에 붙일 출력(6줄 — 맨 위 = 재제출 커밋 · 그 아래 5줄 = 1회차 그대로 · 파일로 떠서)
  git diff --name-status c4c8e7d HEAD   ← 아래 P1 에 붙일 출력(위와 같은 한 줄 · 파일로 떠서)
  12항 줄 수 — 아래 «12항 15줄 상자» 를 저장소 밖 임시 파일 $env:TEMP\r12b_item12.txt 에 그대로 저장한 뒤(1회차 파일이 남아 있어도 이 상자로 덮어쓴다)
     PowerShell: (Get-Content "$env:TEMP\r12b_item12.txt" -Encoding UTF8).Count   ← 출력 한 줄 «15»(기대) · bash: wc -l < "$TEMP/r12b_item12.txt"   ← 15(끝 줄 뒤 줄바꿈이 있을 때)
     (15 가 아니면 상자를 다시 옮긴다 · 이 파일은 커밋하지 않는다 · 아래 P2 에는 명령 줄이 아니라 출력 한 줄만 붙인다 — C12b-7)
      ┌── 12항 15줄 상자(다음 줄부터 · 15줄 · 1회차 ② 와 같은 글자 · 세기 전용 — 채팅 글에 붙이지 않는다)
 1. `ui_analytics`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] (정적 묶음 S19 — 허용 밖 import 0줄)
 2. 화면 코드에 산술이 없는가 — 행동 갭·워터폴 잔여·밴드 이탈·페널티 금액을 내가 계산하지 않았는가 [x] (S7-6c 화면 산술 0 — 카운트다운·초안·비용 글자는 엔진 문자열 그대로(정적 S18·S24 · C-42 ③⑥))
 3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (리밸런싱 트리거 배지·«미달» 경고문 포함) [x] (정적 묶음 S20 — 0건)
 4. S7-2에 인터스티셜·격리 위치·열람 기록 3종이 모두 있는가 [x] (이 카드 범위 밖)
 5. M8 홈·알림에 넘기는 요약과 D-7/D-1 알림 본문에 손익·금액이 없는가 [x] (이 카드 범위 밖)
 6. 플래너가 M3 결과만 그리는가 / «미리보기입니다» 고지가 상시인가 / 주문 실행 버튼이 없는가 [x] (앞절 S7-6c 초안은 previewRebalance 결과만 그린다(T76c-06) / 가운데 previewNotice 는 초안이 있는 동안 스크롤 밖 고정(T76c-11) / 뒷절 승인·실행·주문 버튼 0(T76c-15))
 7. 결측 구간을 보간하지 않고 공백으로 두는가 / «산출 불가»에 근사 배지를 붙이지 않았는가 [x] (이 카드 범위 밖)
 8. 표본 크기 고지·벤치마크 구성 문구가 뷰모델 문자열 그대로인가 [x] (이 카드 범위 밖)
 9. as-of 기준일이 모든 성과 화면 상단에 상시 표기되고, 유예 초과 시 «오래된 데이터» 배너가 뜨는가 [x] (as-of 는 화면에 1줄(s76c-asof) + 초안 기준 1줄(s76c-draft-asof) · 오래됨 배너 = StaleBanner(T76c-12))
10. S7-8의 게이트·개입 UI를 자체 구현하지 않았는가 / 픽스처·골든 스냅샷을 손대지 않았는가 [x] (앞절 이 카드 범위 밖 / 뒷절 기존 PNG M 0 · domain_contracts 변경 0)
11. `ui_analytics` 소스에 세후·기대수익률·낙폭 수치가 리터럴로 없는가 —
    정규식 `\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b` 로 `lib/` 만 검사(pubspec·버전 문자열·
    `fixtures/`·테스트는 대상 제외 — 픽스처는 M2 소유) [x] (정적 묶음 S21 결과 0건 · 보강 S22 결과 0건 · S23 결과 0건)
12. 세후 카드에 계좌 배치 갈래가 정확히 하나만 펼쳐져 있는가 / 층을 화면에서 합치거나 빼지 않았는가 /
    목표 경로 가정 카드가 «백테스트 기준 실행»과 «현재 원금·납입» 두 줄로 갈라져 있는가 [x] (이 카드 범위 밖(세후 사다리·목표 경로 가정 카드는 S7-7·S7-9 몫))
      └── 12항 15줄 상자 끝(이 줄 앞까지)
  cd packages/ui_analytics → 위 «정적 묶음» 38줄 → 위 «테스트 수 묶음» 3줄 → cd ../..   ← 아래 P2 에 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로 · 1회차 출력을 쓰지 않는다)
  git status --short   ← 🔴 다시 비어 있어야 합니다(명령이 파일을 바꾸었으면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  PR 은 만들지 않습니다 · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다(golden:approved 포함).
  🔴 부분 제출 — 채팅 글 = 맨 위 머리 첫 줄 + P1~P6 여섯 토막뿐입니다. 1회차 글 ①~⑤ 를 다시 내지 않습니다(통합 담당이 1회차 PR 본문의 그 자리에 P1~P6 을 바꿔 넣는다 — 바꿔 넣는 자리는 각 토막 머리의 괄호).
      ┌── 머리 첫 줄 복사 시작(다음 줄부터 · 1줄 · <해시> 자리에만 위 git log 맨 위 줄의 해시 7자)
R12b 재제출 글(P1~P6 · 부분 제출)입니다 — 재제출 커밋 1개(`<해시>` · test 1파일 · lib·PNG·질문 파일 0) · force push 0.
      └── 머리 첫 줄 복사 끝(이 줄 앞까지)
      ┌── 토막 머리(여섯 줄 · 글자 그대로 · 각 토막 맨 위에 한 줄씩 · 이 차례로)
## P1 ① 커밋 목록 · 재제출 커밋 범위
## P2 ② 12항 줄 수 · 정적 묶음 · S05 · ⓡⓗ · 테스트 수
## P3 ③ «빈» · «뷰어»
## P4 ③ «차단»
## P5 ③ 골든 표 4행(preview · draft_empty)
## P6 ⑤ 끝 줄 · 까닭
      └──
   P1 (① 의 커밋 목록 코드 블록 5줄을 바꾼다) =
       위 git log --oneline origin/main..HEAD 출력 6줄을 코드 블록 하나로 그대로 +
       위 git diff --name-status c4c8e7d HEAD 출력 1줄을 코드 블록 하나로 그대로(① 의 name-status 18줄은 그대로라 다시 내지 않는다 — 점 세 개 diff origin/main...HEAD 는 1회차와 같은 18줄이다).
   P2 (② 의 12항 세는 줄 · 정적 묶음 코드 블록 · S05 2줄 · ⓡⓗ 줄 · 테스트 수 3줄을 바꾼다 — 12항 15줄과 괄호는 그대로라 다시 내지 않는다) = 이 차례로:
       ㄱ. 12항 줄 수 = 위 Count 명령의 **출력 한 줄**만 코드 블록 하나로(기대 «15» · «(Get-Content …).Count = 15» 처럼 명령과 잇지 않는다 — C12b-7).
       ㄴ. 정적 묶음 38줄 출력 **전부**를 코드 블록 하나로 그대로(줄이지 않는다 · 빈 줄도 지우지 않는다 · 1회차 출력을 쓰지 않는다).
       ㄷ. S05 결과 2줄 = 아래 상자 글자 그대로(정적 묶음 S05 출력의 경로·줄 번호와 같아야 한다 — 다르면 lib 가 바뀐 것이니 멈춘 뒤 채팅으로):
      ┌── S05 복사 시작(다음 줄부터 · 2줄)
lib/src/screens/rebalance_preview_screen.dart:117 — 탭 콜백 안
lib/src/screens/rebalance_preview_screen.dart:242 — 탭 콜백 안
      └── S05 복사 끝(이 줄 앞까지)
       ㄹ. ⓡⓗ 한 줄 = 아래 상자 글자 그대로(정적 묶음 S29·S30 출력 줄과 같아야 한다 — 다르면 상자를 고쳐 쓰지 말고 제출하지 말고 R1~R4 를 다시 본다):
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 1줄)
ⓡ = S29 출력 · ⓗ = S30 출력 = test/rebalance_preview_view_test.dart:16 / test/rebalance_preview_view_test.dart:6
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
       ㅁ. 테스트 수 = 위 «테스트 수 묶음» 3줄의 끝 줄을 view · golden · 전체 차례로 코드 블록 하나에 그대로(파일로 떠서 · 시각 포함 — 줄 머리 경과 시각(mm:ss)은 돌릴 때마다 달라 C4 대조에서 뺀다 · 기대 +41 · +10 · +405).
   P3 (③ 의 «빈» 줄과 «뷰어» 줄을 바꾼다 — C12b-5 · 견본 꼬리 괄호) = 아래 상자 글자 그대로 2줄.
       🔴 붙이기 전에(읽기만) lib/src/screens/rebalance_preview_screen.dart 를 열어 빈(예정 없음) 갈래에 버튼·초안 영역이 없고, 주입 null 갈래에 s76c-preview-button·초안 영역이 없음을 본다(맞지 않으면 멈춘 뒤 채팅으로 · 고치지 않는다).
      ┌── P3 복사 시작(다음 줄부터 · 2줄)
«빈» = s76c-root → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → s76c-empty → s76c-asof(버튼·초안 부재)
«뷰어» = s76c-root → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → s76c-countdown → s76c-asof(s76c-preview-button · 초안 영역 부재)
      └── P3 복사 끝(이 줄 앞까지)
   P4 (③ 의 «차단» 줄을 바꾼다 — C12b-4 · 첫 «→» 를 견본의 «+» 로) = 아래 상자 글자 그대로 1줄.
       🔴 붙이기 전에(읽기만) 화면 파일에서 SafetyBlockBanner 가 StaleBanner 아래 · Expanded(ListView) 바깥 위에 있음을 본다(1회차 113·114·125행 — lib 불변).
      ┌── P4 복사 시작(다음 줄부터 · 1줄)
«차단» = SafetyBlockBanner(StaleBanner 아래 · Expanded(ListView) 바깥 위) + s76c-root → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → s76c-countdown → s76c-asof → s76c-preview-button → s76c-blocked → s76c-blocked-action(있을 때)
      └── P4 복사 끝(이 줄 앞까지)
   P5 (③ 골든 표의 s76c_preview dark · light · s76c_draft_empty dark · light 네 행을 바꾼다 — C12b-6 · «고지 띠(상단 고정)» 를 PNG 에서 보이는 것만으로) = 아래 상자 글자 그대로 4줄.
       🔴 붙이기 전에 PNG 네 장(test/golden/goldens/s76c_preview_dark.png · s76c_preview_light.png · s76c_draft_empty_dark.png · s76c_draft_empty_light.png)을 다시 연다 —
          (골든 글꼴은 글자를 네모로 그린다 — 줄 수·배경·차례·잘림만 본다) 맨 위 고지가 배경 없는 글자 2줄이고(«띠» 가 아니다 · «고정» 은 정지 PNG 로 보이지 않는다), 그 아래 차례와 잘림 없음이 상자와 같으면 이 글자로 바꾼다. 다르면 제출하지 말고 멈춘 뒤 채팅으로.
          (PNG 는 이번 재제출에서 바뀌지 않는다 — 골든 테스트·lib 0 · dy 그대로 · 표의 다른 6행과 머리는 1회차 그대로라 다시 내지 않는다.)
      ┌── P5 복사 시작(다음 줄부터 · 4줄)
| s76c_preview dark | m7/m7_next_rebalance_countdown.json + m7/m7_rebalance_preview_default.json | 390×844 | 660.0 | 고지 문장(맨 위 2줄)·카운트다운·버튼·초안 표(2행·사유 칩)·비용 카드·기준일 세로 배치 · 잘림 없음 |
| s76c_preview light | m7/m7_next_rebalance_countdown.json + m7/m7_rebalance_preview_default.json | 390×844 | 660.0 | 고지 문장(맨 위 2줄)·카운트다운·버튼·초안 표(2행·사유 칩)·비용 카드·기준일 세로 배치 · 잘림 없음 |
| s76c_draft_empty dark | m7/m7_next_rebalance_countdown.json + m7/m7_rebalance_preview_in_band.json | 390×844 | 524.0 | 고지 문장(맨 위 2줄)·카운트다운·버튼·빈 초안 문장·비용 카드·경고 줄·기준일 세로 배치 · 잘림 없음 |
| s76c_draft_empty light | m7/m7_next_rebalance_countdown.json + m7/m7_rebalance_preview_in_band.json | 390×844 | 524.0 | 고지 문장(맨 위 2줄)·카운트다운·버튼·빈 초안 문장·비용 카드·경고 줄·기준일 세로 배치 · 잘림 없음 |
      └── P5 복사 끝(이 줄 앞까지)
   P6 (끝의 «flutter test: …» 한 줄을 바꾸고 그 아래에 까닭 한 줄을 더한다) = 아래 상자 두 줄(<…> 자리에만 위 «테스트 수 묶음» 셋째 줄의 끝 줄 그대로 · 시각·«+수»·«All tests passed!» 까지):
      ┌── P6 복사 시작(다음 줄부터 · 2줄)
flutter test: 시작 기준 354 → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>
까닭(뷰 +41 · 전체 +405 · 카드 기대 +40 · +404): C4 재제출 지적 R2 로 T76c-10 에 셋째 경우 b_then_a_error 를 더했다(경우 2 → 3)
      └── P6 복사 끝(이 줄 앞까지)
       (까닭 줄의 수는 실제 출력이 +41 · +405 일 때의 글자다 — 다르면 상자의 까닭 줄을 쓰지 말고 출력 그대로 끝 줄만 적은 뒤 멈추지 말고 채팅 글 끝에 «테스트 수가 기대와 다름» 한 줄을 더한다.)
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s76c-preview` 에 추가 커밋 **1개**: `[M7] R12b (6) 재제출 — T76c-14 if/else 짝 · T76c-10 늦은 에러 · T76c-05 둘째 요청 인자 없음`. main 병합 커밋 **없음** · 지난 5개 커밋 **그대로**(`git log --oneline origin/main..HEAD` = 6줄 · 맨 위 = 재제출 커밋 · 아래 5줄 = 1회차 글자).
- `test/` 수정 1 — `rebalance_preview_view_test.dart` 의 R1~R4 자리만(+28/−9 · C4 시험 diff `j_fix.diff` 와 같은 글자 — 통합 담당이 `git diff c4c8e7d HEAD` 를 그 diff 와 대조한다).
- `lib/` 변경 0 · PNG 변경 0 · 골든 테스트·가짜·질문 파일 변경 0 — `git diff --name-status c4c8e7d HEAD` = `M	packages/ui_analytics/test/rebalance_preview_view_test.dart` 한 줄.
- `ui_analytics` `flutter test` **405**(뷰 41 · 골든 10 — 1회차 404 + T76c-10 셋째 경우 1) · 정적 38줄 출력 = 1회차와 같은 글자(EXIT·warning·장식 줄 말고 · S29 16 · S30 6 · S05 `:117` · `:242`).
- 채팅: 머리 첫 줄(상자) + P1~P6 — P1 git log 6줄 + `c4c8e7d..HEAD` name-status 1줄 · P2 Count 출력 «15» 한 줄 + 정적 38줄 출력 전부 + S05 2줄(상자) + ⓡⓗ 한 줄(상자) + 테스트 수 끝 줄 3줄 · P3 «빈»·«뷰어»(상자) · P4 «차단»(상자) · P5 골든 표 4행(상자) · P6 끝 줄 + 까닭(상자). 1회차 ①~⑤ 의 나머지는 다시 내지 않는다(부분 제출).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12b-Bob-S76c 재제출: PR #27 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 채팅 글(머리 첫 줄 + P1~P6)을 붙여넣습니다(Claude 가 1회차 PR #27 본문의 그 자리에 바꿔 넣습니다). 0단계·«먼저 할 것»·«고친 뒤 확인»에서 멈췄다면 `R12b-Bob-S76c 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력. Bob 이 1회차 글 ①~⑤ 전체를 다시 냈다면 그대로 붙여넣되 «부분 제출이 아님» 이라고 함께 알립니다(통합 담당은 P1~P6 자리만 씁니다).

## 5. 주의

- **5분 눈 검사**(PR #27 «Commits» · «Files changed» — `c4c8e7d` 뒤 커밋만 보면 된다): ① 커밋 수가 6 이 아님 · 지난 5개 해시가 바뀜(강제 푸시·rebase 흔적) · `Merge … origin/main` 커밋 ② `packages/ui_analytics/lib/` 의 변경 ③ PNG 변경(`s76c_*` 포함 — 이번에는 한 장도 바뀌면 안 된다) ④ `rebalance_preview_fakes.dart`·`s76c_golden_test.dart`·`labels.dart`·`pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README·질문 파일 변경 ⑤ T76c-14 에 아직 `if (!d.isStale) {` · `if (activeFlags.isEmpty) {` · `if (!hasPreview) {` · `if (!isBlocked) {` 가 else 없이 남음 · T76c-10 에 `b_then_a_error` 없음 · T76c-05 에 `previewCalls[1], isNull` 없음 ⑥ 채팅 글 P5 에 «띠»·«고정» · P3 꼬리 괄호 없음 · P4 첫 «→» — 하나라도 있으면 반려 신호(⑥ 은 strict 나눔 ① 표기만이면 C4 정정 대상).
- CI: 새 PNG 만이라 «골든 스냅샷» 은 라벨 없이 초록이 정상(PR #27 라벨 0 그대로 · 붙이지 않는다). «분석 · 테스트(melos)» 는 Bob 의 푸시(새 `pull_request` synchronize)로 새 `main`(기록 커밋 포함) 위의 병합 미리보기를 다시 돌린다 — 기록 커밋은 문서뿐이라 수는 C4 시험과 같은 것이 기대.
- C4 가 2회차에서 볼 것: 기계 = `c4c8e7d..HEAD` test 1파일 M · hunk 가 R1~R4 자리뿐(`j_fix.diff` 와 글자 대조) · 지난 5개 해시 불변 · 전체 +405 · analyze · format · C-42 · CI · «else 없는 if» 0(문장 if 전수 훑기) / 변이 = 표 F 57꼴 + E16 전체 재실행(테스트가 강해지기만 했는지 · F04b·F02c 가 잡히는지) / 정직 = 머리 첫 줄·S05·ⓡⓗ·P3~P6 은 복사 상자 글자와 · P1·P2 의 출력은 재실행 출력과 글자 대조(정적 38줄 · git log · 테스트 끝 줄 — 테스트 끝 줄의 줄 머리 경과 시각(mm:ss)은 대조에서 뺀다) · 질문 파일 불변. 판정 기준 = 1회차 카드 strict 나눔(카드 189~192행 — 1회차 반려 댓글의 «카드 158~161행» 은 틀린 행 번호 · 2회차 댓글은 189~192행으로 · ① 표기만 = C4 정정 · ② 코드·테스트·거짓 = 반려 · ③ 예고 변이 = 반려).
- 병합 뒤 할 일(Claude · C4 보고 §5·§6-1): 질문 파일 A1~A5 답 칸(«PR #27 `c4c8e7d` 측정값 = C4 재실측 …» · 재제출은 골든 테스트·lib·PNG 0 이라 같다) · 머리말 «다음 번호 = Q1·A6» · golden README 1행(86장)·R12b 병합본 실측 줄 · 패킷 이동은 이 재제출 패킷 `send/R12b-Bob-S76c-재제출.md` → `_완료/` 만(원 패킷은 반려 기록 때 이미 `_완료/`) · `_대기/R12c-Bob-S77.md` → `send/`(머리 ⏸ → ▶ · `__R12B_SQ__`·⟦실측⟧ 채움 — 병합본 기대 405 = R12c 드라이런 기준 404 와 1 다름 · C4 보고 §6-1 3) · `_대기/R12d-Bob-S710.md` 의 `__R12B_SQ__` · 팩 판은 그다음 접미 · 2회차 보고 보존본 `10_리뷰/<날짜>_R12b_C4_2회차_보고.md`.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R12b 패킷은 이 파일 하나입니다. 원 패킷 `R12b-Bob-S76c.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 한다). `_완료/R12a-Bob-S76ab-재제출.md` · `_완료/R12a-Bob-S76ab-재제출2.md` · `_완료/R11b-Bob-S79-재제출.md` · `_완료/R11a-Bob-S74-재제출.md` 는 끝난 카드입니다.
- 범위 밖(발주자 결정 2026-10-14): C4 보고 §7 의 테스트 보강 후보 N1(늦은 에러 장면을 예고 변이와 함께 · 카드 조립 점검표) · N2(«인자 없이» 단언은 모든 호출 기록에) · N4(«else 없는 if» 자기 점검 줄) · N5(«화면이 지은 글자 0» 집합에 에러 갈래)는 이 재제출에 넣지 않는다(각 카드 ▶ 때 재드라이런과 함께) · 보고·테스트 꼴 견본 N3·N6·N7 은 `send/_대기/` 의 R12c·R12d 에 넣었다(이 카드 몫 아님).
