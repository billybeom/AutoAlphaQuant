# 발송 패킷 R11a-Bob-S74 — 재제출 (1회차 반려 · 2026-10-01)

> 만든 날 2026-10-01 · 1회차(PR #19 · 브랜치 `ui/m7-s74-planner` · 커밋 `92999a8`)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다(발주자 결정 2026-10-01 = «(A) 반려하고 재제출, 비교기 PR 도 진행해» · C4a-5 는 [나] = 재제출에 함께). 규칙·범위(S7-4 투자금 플래너)는 1회차 카드(`send/_완료/R11a-Bob-S74.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 F1~F8**만 담았습니다.
> 같은 브랜치 `ui/m7-s74-planner` · 같은 PR #19 에 커밋을 더하면 됩니다(새 PR 을 만들지 않습니다). 기대 = **lib 0**(`lib/**` 변경 0) · **PNG 0**(새로 찍지 않는다) · **test 1파일**(`test/deposit_planner_view_test.dart` — 기존 테스트 안의 단언 추가·모양 변경 · testWidgets/test 수 불변 → `flutter test` 235 그대로) · 질문 파일 변경 0(A1~A7·머리말 그대로) · PR 본문 5섹션 새 판(③ 다시 쓰기 · ② 끝 까닭 한 줄).
> 판정 근거 = C4 보고 §0(설계 저장소 `10_리뷰/2026-10-01_R11a_C4_보고.md`) — 카드 🔴 «보고와 코드·파일·PNG 가 1건이라도 다르면 재량 없이 반려»(R10b 부터 적용) · «예고 변이가 하나라도 그대로 통과하면 반려» · «else 쪽 findsNothing 이 없으면 반려». [가] 3건: C4a-2 예고 변이 «건드린 뒤 첫 값이 덮기»(P04)를 뷰 25·골든 14 가 모두 통과(T74-02 장면 B 가 첫 값과 같은 글자를 입력) · C4a-3 T74-15 else 누락 · C4a-4 PR ③ 이 코드와 다름(스텝 ② 에 없는 `s74-register-blocked` 주장 · «상단» 요약어 · 스텝 ③ 사슬 4개 누락). [나] 3건(재제출에 함께): C4a-5 T74-11·T74-13 «ruleCited·code 글자 0» · C4a-6 T74-22 `test(` + 경로 없음 실패 · C4a-7 재시도 버튼을 에러 뷰 안에서 찾기. [다] 2건(이 패킷이 정함): C4a-8 ⓡ·ⓗ 까닭 한 줄 · C4a-9 «format» 커밋은 format 만. 고칠 것의 코드 모양 = C4 보고 §6 1~6.
> 🔴 **main 병합 안 함(판단)** — PR CI 는 PR 의 병합 미리보기(`refs/pull/19/merge` — `ci.yml` 이 `pull_request` 에서 `actions/checkout@v4` 를 `ref` 없이 쓴다 · 확인함)를 돌리므로 main 에 들어간 비교기 수정이 저절로 들어가고, 패킷은 GitHub 에서 붙여 넣어 0단계 `ls-tree` 로 main 에 있는지만 보면 되므로 Bob 브랜치에 main 을 병합할 까닭이 없다(병합하지 않으면 «먼저 할 것» 병합 충돌 · 병합 커밋 · `flutter test` 수가 비교기 PR 의 새 테스트만큼 바뀌는 일이 없다). PR #19 의 C4 댓글(«재제출 카드가 main 을 브랜치에 병합하라고 안내합니다»)과 다르다 — 본문 0단계에 «이 카드가 이긴다» 한 줄을 넣었다.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `send/R11a-Bob-S74.md` 의 `send/_완료/` 이동과 **같은 푸시**로 `main` 에 올린다(R10c 선례 · 0단계의 `ls-tree` 줄이 그 증명 — 원 패킷이 `send/` 에 남아 있으면 Bob 이 멈춘다). 같은 푸시에 `send/README.md` 의 ▶ 줄과 R11a 행도 이 재제출(같은 브랜치 · 같은 PR #19 · 원 패킷 `_완료/`)로 고친다. 🔴 같은 푸시에서 `inbox/S7-4_questions.md` 는 건드리지 않는다(머리말 «다음 번호» 도 — 머리말과 A1~A7 답은 PR #19 병합 때 통합 담당이 C4 보고 §7 대로 고친다). 원 패킷을 이번에 옮기면 C4 보고 §8 «2-1 ①» 의 `git mv … R11a-Bob-S74.md` 줄은 병합 때 할 일이 아니다(재제출 패킷만 `_완료/` 로).
> 🔴 **보내는 조건** — ① 「푸시해」 뒤(이 패킷이 GitHub `main` 의 `docs/ai-context/send/` 에 있고, 꼬리 없는 `R11a-Bob-S74.md` 는 `send/` 에 없음) ② 권장: **비교기 infra PR(C4a-1 · 보조 기준 0.5% 상향)이 `main` 에 병합된 뒤** — 그러면 Bob 의 푸시가 PR #19 CI 를 새 `main` 위에서 다시 돌려 «분석 · 테스트» 가 초록이 된다. infra PR 이 Bob 푸시보다 늦으면 PR #19 CI 는 빨강(234/1 · `s74_pension_limit_hit_light`)인 채로 남는다 — Bob 몫이 아니며, 그 경우 Claude 가 infra PR 병합 뒤 PR #19 의 CI 를 새 `main` 위에서 다시 돌린다 — **기본 길 = PR #19 를 닫았다 다시 열기**(새 `pull_request` 이벤트가 새 `main` 으로 병합 미리보기를 다시 만든다 · 「Re-run」 버튼은 알려진 동작으로는 처음 만든 병합 미리보기를 다시 돌 뿐이라 기본 길로 쓰지 않는다 — 둘 다 이번에 확인하지는 않았다).
> 시험 적용(2026-10-01 · 검사 폴더 `C:\Work\AAQ-claude-review` · 로컬 가지 `dry/r11a-resub` = `92999a8` 위에 앞 판 F1~F8 을 본문대로 적용 · 커밋 `34c6f12`(1) + `bcec42f`(2) · 끝난 뒤 `92999a8` 분리 HEAD 로 되돌림 · git status 빈): ui_analytics `flutter test` **235 통과 · 0 실패** · 뷰 파일 25 통과 · **S26 = 39 · S27 = 16**(1회차 15 + F3ⓑ `hasLength(1)` 1줄) · 정적 29줄 = 1회차 출력과 S27 한 줄만 다름 · S05 = `:165`·`:312` · **P04 KILLED**(T74-02 · Expected `'1000000'` · Actual `'100000'`) · 1회차 생존 변이 16개는 그대로 생존(겨눈 것 아님) · `diff --name-status 92999a8 HEAD` = test 1줄 · `origin/main...HEAD` 22줄 = 1회차 글자 · format 커밋 (2) = 앞 판에서는 **필요했다**(F4 의 expect 한 줄이 80자를 넘어 4줄로 접힘 · 그것만 바뀜) → 이 판은 F4 를 처음부터 4줄 모양으로 적었다 · 이 판의 F3ⓑ(if 쪽 `s74-funding` 1 줄 추가)+F4 4줄 모양을 `bcec42f` 위에 얹어 다시 봄: `dart format` 0 changed · 뷰 25 통과 · S26 39 · S27 16 → **(2) 없음이 기대**. 셸 = Git Bash 만(PowerShell 미실행 — 정적 29줄은 1회차와 같은 글자라 PowerShell 5.1 에서 도는 것은 1회차에 확인됨). 기대값 = 시험 적용 실측 · 다르면 PR 본문에 까닭.
> 🔵 C4 보고 §6-6 의 스텝 ③ 줄은 « / » 묶음이 코드와 다르게 읽힌다(등록 자리) — 이 패킷의 F6 대조 줄 · «■ 제출» ③ 글자가 그것을 고친 판이다(C4 보고 §6-6 을 Bob 에게 보내지 않는다).

## 0. 한 줄 목적

PR #19 의 테스트가 카드가 예고한 변이(P04)를 실제로 잡고 카드 규칙 11(else 쪽 단언 · 조용한 건너뛰기 금지)을 지키게 고치고, PR 본문 ③ 을 코드에 있는 Key 순서 그대로 다시 쓰기 — **lib·PNG 는 한 글자도 바꾸지 않는다**.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s74-planner` · 같은 PR #19.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다). 비교기 infra PR 이 `main` 에 들어간 뒤에 보내면 CI 가 한 번에 초록이 됩니다(위 «보내는 조건» ②).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다. 🔴 1회차를 보낸 대화를 이어 쓰지 않습니다(Bob 은 1회차를 기억하지 못한다는 전제로 본문을 썼습니다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R11a-Bob-S74-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R11a-Bob-S74-재제출.md` · 기록 푸시 뒤 `main` 과 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R11a-Bob-S74.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 아래 «3» 의 본문 **전부**(첫 줄 «R11a-Bob-S74 재제출 요청» ~ «(+ flutter test 실제 통과 수 한 줄)» 끝) · 고치지 않습니다. 새 대화라 규칙 요약 · 고칠 곳의 코드 모양 · 자체 점검 12항 복사 상자 · 정적 29줄 묶음 · ③ 6줄 복사 상자가 본문에 들어 있습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R11a 패킷은 **이것 하나**(`R11a-Bob-S74-재제출.md`)입니다. 원 패킷 `R11a-Bob-S74.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R10c-Bob-S72-재제출.md` · `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드입니다(보내지 않음). R11b(`_대기/R11b-Bob-S79.md`)는 R11a 병합 뒤입니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R11a-Bob-S74 재제출 요청 — 1회차(PR #19 · 92999a8) 판정: 반려(재제출). 같은 브랜치 ui/m7-s74-planner · 같은 PR #19 에 커밋을 더하십시오(새 PR 금지).
이번에 고치는 곳은 테스트 파일 하나(test/deposit_planner_view_test.dart)와 PR 본문뿐입니다. 🔴 lib 0 · PNG 0 — lib/** 나 PNG 가 하나라도 바뀌면 반려입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R11a 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #19 · 브랜치 ui/m7-s74-planner(커밋 92999a8)에 아래 F1~F5 커밋을 «더하는» 일입니다. F1~F5 는 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
🔴 main 을 이 브랜치에 병합하지 않습니다(git merge origin/main 금지) — PR CI 는 GitHub 가 PR 을 main 위에 얹어 본 모양(병합 미리보기)으로 돌기 때문에, main 에 들어간 수정은 병합하지 않아도 CI 에 들어갑니다.
   PR #19 의 C4 댓글에는 «재제출 카드가 main 을 브랜치에 병합하라고 안내합니다» 라고 적혀 있지만, 이 카드가 이깁니다(병합하지 않는다).
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git branch --show-current     ← ui/m7-s74-planner 가 아니면(status 가 빈 것을 본 뒤) git checkout ui/m7-s74-planner
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git log --oneline -1          ← 92999a8 로 시작하면 정상(제목 «[M7] R11a (6) format·질문 파일» 의 한글은 셸에 따라 깨져 보일 수 있다) · 다른 해시면 멈추고 출력을 채팅으로(pull·rebase·reset 금지)
  git rev-parse --short origin/ui/m7-s74-planner   ← 92999a8 로 시작 · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R11a-Bob-S74-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R11a-Bob-S74.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 · _대기 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R11a-Bob-S74-» 로 시작하는 줄이 있으면 정상.
        «R11a-Bob-S74-재제출» 줄이 없거나 꼬리 없는 «R11a-Bob-S74.md» 가 보이면 멈추고 채팅으로 — 기록 푸시보다 카드가 먼저 왔습니다.
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.
🔴 이 카드와 1회차 카드(R11a-Bob-S74.md)의 글이 다르면 이 카드가 이깁니다 — 예: 커밋에 질문 파일을 add 하지 않는다 · «(6) format·질문 파일» 커밋을 만들지 않는다 · 골든 dy 를 다시 재지 않는다 · PR 본문 ③ 의 글자와 표기는 이 카드 «■ 제출» ③ 대로 · main 을 병합하지 않는다.

■ 규칙 요약 (1회차 카드 = 이 브랜치의 docs/ai-context/send/R11a-Bob-S74.md(main 에서는 send/_완료/ 로 옮겨졌다 — 글자는 같다)의 규칙 1~17 · 보고 규칙 · 화면 · 테스트 최소 목록 · 정적 묶음 · 골든 · 질문 파일 절이 유효 — 단 이 카드와 다른 곳은 이 카드가 이긴다 · 여기엔 핵심만)
· 이번에 고치는 곳 = 아래 한 곳뿐입니다.
    packages/ui_analytics/test/deposit_planner_view_test.dart   (F1~F5 — 기존 테스트 안의 단언 추가·모양 변경 · 새 testWidgets/test 를 더하지 않는다)
· 🔴 고치면 반려: 위 한 파일 밖의 전부 — packages/ui_analytics/lib/**(planner.dart · src/planner/** · l10n/labels.dart 포함 · 🔴 lib 0) ·
  test/golden/goldens/*.png 전부(s74_* 14장 포함 · 🔴 PNG 0 · --update-goldens 를 돌리지 않는다) · test/golden/s74_golden_test.dart · test/planner_fakes.dart ·
  test/explore_fakes.dart · 기존 테스트 전부 · test/golden/ 의 하네스·reference/**·README · test/flutter_test_config.dart ·
  domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml · docs/ai-context/inbox/S7-4_questions.md(아래 «질문 파일»).
  🔴 PNG 가 하나라도 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로 · 예외 없음.
· 테스트 규칙(1회차 카드 규칙 11 — 이번에 걸린 곳만 글자 그대로):
   전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) ·
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다 · if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려.
   ⓡ = 정상 상태 테스트의 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 줄 — 한 줄에 하나 · 이번 F 는 ⓡ 줄을 더하지도 빼지도 않는다.
   ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(<숫자>)) 전제 줄 — F3 이 하나 더한다.
  (그 밖 — 테스트 이름은 번호 + ASCII(«—»·«→» 금지) · 테스트에 한국어 리터럴 금지 · 주석에도 한국어를 새로 쓰지 않는다(정적 S01) · 새 띄우기 도우미·새 가짜 금지 — 이미 있는 pumpPlanner · tapAndSettle 를 쓴다.)
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인.
🔴 보고 규칙 — «보고와 코드·파일·PNG 가 1건이라도 다르면 재량 없이 반려» 입니다(R10b 부터 적용 · 발주자 결정 5).
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않습니다.
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M7.md 155~169행 12항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 ·
   항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다).
   ③ 은 코드의 위젯·Key 이름을 위 → 아래 순서 그대로 «→» 로 잇습니다 — «순서대로»·«정상 배치»·«모두»·«상단»·«연이어» 같은 요약어는 코드와 PNG 를 다시 열어 맞을 때만(R10c 1회차 · 이번 1회차 반려 사유).
   → 이번 재제출의 ③ 은 1회차가 이 규칙을 어긴 곳을 고치는 일입니다. 같은 결함이 한 번 더 나오면 다시 반려입니다.
     이번 ③ 6줄은 «■ 제출» ③ 의 복사 상자 글자 그대로입니다(F6 대조 줄로 코드와 맞는지 본 뒤 · 맞지 않으면 멈춤).

■ 잘된 것 — 그대로 유지하십시오
lib 코드는 카드와 맞았습니다 — 정적 라벨 15 · lib/planner.dart export 2 · 프로바이더 4 · 스텝 ①②③ 배치·Key · previewNotice·StaleBanner·배너 스크롤 밖 · 칩 = Chip + 톤 switch · null 규칙 · C-38 ⑩ 0건 · 금지 낱말 0.
새 PNG 14장은 카드 배치·픽스처와 맞고(넘침·잘림·겹침 0) 기존 PNG 42장은 그대로였습니다. dy 14값 = C4 재실측 14/14 일치(384·716·960·828·988·1181·541 · light=dark).
보고를 기계로 만든 곳은 전부 사실이었습니다 — ① name-status 22줄 · ② 12항 원문 15줄(글자 차이 0 · 괄호 12개 모두 사실) · ② 정적 29줄 출력(C4 가 같은 29줄을 돌린 출력과 차이 0) ·
S05 2줄 «— 탭 콜백 안»(정규식 일치 · 둘 다 실제 탭 콜백 안) · ⓡ 39 = S26 · ⓗ 15 = S27 · ④ = 질문 파일 A1~A7 · ⑤ «없음» · flutter test 235 통과 · 0 실패.
기계 검사 — dart format 0 changed · analyze 13/13 · domain_contracts 257 통과·30 skip·0 실패 · 경계·라벨 검사 위반 0 · 카드가 예고한 변이 27항목 중 26항목은 테스트가 잡았습니다.
(CI «분석 · 테스트» 빨강 = 리눅스 렌더 소음으로 s74_pension_limit_hit_light 가 비교기 보조 기준 0.5% 를 넘은 것(0.592%) — Bob 몫이 아닙니다. 통합 담당이 비교기 infra PR 로 고칩니다. PNG 를 다시 찍지 않습니다.)

■ 왜 반려인가 — 카드 / 코드 · 보고 글 / 실제 (C4 검사 갈래 둘 이상이 따로 확인)
① 예고 변이가 살아남음 (C4a-2)
   카드:  «병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): … 건드린 뒤 첫 값이 덮기 …»
   실제:  화면의 onChanged: (_) => _touched = true 를 지우고(«건드린 뒤 첫 값이 덮기») 테스트를 돌리면 뷰 25·골든 14 가 모두 통과합니다(두 번 돌려 같음).
          T74-02 장면 B(139~142행)가 첫 값 전에 입력한 글자가 defaultSetting.amountInputText — 첫 값과 **같은 글자**라, 첫 값이 입력을 덮어써도 글자가 같아 차이가 안 보입니다.
② T74-15 else 누락 (C4a-3)
   코드:  973~975행 if (identical(res, fundingResult)) { expect(find.byKey(const Key('s74-funding')), findsOneWidget); } — else 가 없어 기본·만료 픽스처에서 s74-funding 0 을 보지 않습니다.
   카드:  T74-15 «funding 은 s74-funding 1 도 함께» + 규칙 11 «if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려».
③ PR ③ 이 코드와 다름 (C4a-4)
   보고 글: «차단: … 스텝 ②③에서는 상단 SafetyBlockBanner(있을 때) 및 등록 버튼 자리에 s74-register-blocked가 표시됩니다.»
   실제:    s74-register-blocked 는 스텝 ③ 에만 있습니다(_buildStepResult 567행 · 스텝 ② 에는 등록 자리가 없다 = 코드에 없는 사실). 이것은 안전 차단이 아니라 엔진의 등록 불가 문장(registerBlockedText)입니다.
            스텝 ②③ 의 SafetyBlockBanner 는 «상단» 이 아니라 s74-preview-notice(339·455행) → StaleBanner(341·457행) 다음(342·458행 _buildSafetyBanner) · Expanded(ListView) 바깥 위입니다.
   보고 글: «스텝 ③: … s74-orders-title → s74-order-<i>(있을 때) → s74-costs → s74-funding(있을 때) → s74-register(있을 때) → s74-recalculate(있을 때) → s74-back(있을 때)»
   실제:    코드의 스텝 ③ 에는 s74-orders-empty(486행) · s74-register-blocked(567행) · s74-register-not-accepted(573행) · s74-receipt(591행) 가 더 있습니다 — 사슬에서 빠졌습니다.
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. 이번 반려 셋 중 둘은 테스트(코드) 결함이고 하나는 보고가 코드에 없는 것을 말한 것입니다.
lib·PNG 가 좋다는 것은 판정을 바꾸지 않습니다.

■ 먼저 할 것
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.4 생성물은 git 에 없습니다(브랜치를 바꿨거나 새로 받았으면 꼭 · 안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: 235 통과 · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·푸시 -u 는 하지 않습니다):
   · docs/ai-context/send/R11a-Bob-S74.md(1회차 카드 — 이 브랜치에 있다) — «■ 규칙 요약» 11 · «■ 화면» · «■ 테스트 최소 목록» T74-02·T74-05·T74-11·T74-13·T74-15·T74-22·T74-25·T74-26 · «■ 정적 묶음» · «■ 골든» · «■ 제출» ②(③ 은 이 카드의 «■ 제출» ③ 이 이긴다)
   · docs/ai-context/prompt_M7.md 155~169행(자체 점검 12항 원문 — 아래 «■ 제출» ② 상자와 같은 글자)
   · packages/ui_analytics/lib/src/planner/deposit_planner_screen.dart 전문(F6 의 ③ 을 쓰려면 꼭 — 고치지는 않는다)

■ 고칠 것 — F1~F8 (1회차 반려 · C4 2026-10-01) — 같은 브랜치 ui/m7-s74-planner 에 커밋을 더해 푸시합니다(rebase·강제 푸시 금지).
   (F1·F2 = 테스트(반려 사유) · F3~F5 = 테스트 보강(발주자 결정으로 이번에 함께) · F6·F7 = PR 본문 · F8 = 커밋)
   F1~F5 는 전부 packages/ui_analytics/test/deposit_planner_view_test.dart 안입니다. 행 번호는 92999a8 의 것입니다 — 🔵 파일 아래쪽부터(F5 의 T74-26 → … → F1 의 T74-02) 고치면 위쪽 번호가 밀리지 않습니다.

F1 (T74-02 장면 B · 125~157행 · C4a-2) 첫 값 전에 입력하는 글자를 첫 값과 **다른 글자**로 바꿉니다.
   지금: 139~142행 await tester.enterText(find.byKey(const Key('s74-amount-field')), defaultSetting.amountInputText);  ← 첫 값과 같은 글자
         149~155행 expect(… .controller!.text, defaultSetting.amountInputText);  · 156행 expect(find.text(defaultSetting.amountText), findsOneWidget);
   바꾼 뒤(137행 ⓡ 줄 다음부터 156행까지를 이 모양으로 · 장면 B 의 앞부분(127~137행)과 } 는 그대로):
      final edited = '${defaultSetting.amountInputText}0';
      await tester.enterText(find.byKey(const Key('s74-amount-field')), edited);
      await tester.pump();

      streamController.add(defaultSetting);
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('s74-amount-field')))
            .controller!
            .text,
        edited,
      );
      expect(find.byKey(const Key('s74-setting-amount')), findsOneWidget);
   (카드 T74-02 ⓑ «첫 값 전에 enterText(같은 글자)» 의 «같은 글자» = 바로 앞 ⓐ 의 '${amountInputText}0' 입니다 — 1회차는 첫 값과 같은 글자로 읽었습니다.
    마지막 줄은 카드 글자 «s74-setting-amount 1» 그대로 Key 로 셉니다 — find.text(amountText) 로 대신하지 않습니다.)
   🔴 확인(권함 · 🔴 packages/ui_analytics 폴더에서 · 커밋 전에): 고친 뒤 lib/src/planner/deposit_planner_screen.dart 의 onChanged: (_) => _touched = true, 를 잠시 onChanged: (_) {}, 로 바꾸고
      flutter test test/deposit_planner_view_test.dart --plain-name "T74-02" → 실패하면 정상(이 테스트가 변이를 잡는다)
      → 🔴 반드시 되돌린다: git checkout -- lib/src/planner/deposit_planner_screen.dart
      → git diff --stat -- lib   ← 빈 출력이어야 lib 0(packages/ui_analytics 폴더에서 돌려야 뜻이 있다 — 저장소 뿌리에서는 lib 를 안 되돌려도 늘 빈 출력이 나온다).

F2 (T74-15 · 973~975행 · C4a-3) else 쪽을 더합니다:
      if (identical(res, fundingResult)) {
        expect(find.byKey(const Key('s74-funding')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s74-funding')), findsNothing);
      }

F3 (T74-11 · T74-13 «ruleCited·code 글자 0» · C4a-5 · 카드 T74-11 «🔴 ruleCited·code 글자 0» · T74-13 «ruleCited 글자 0»)
   ⓐ T74-11 칩 루프(762~767행 for (final chip in d.reasons) { … }) 안, label 단언 다음 줄에:
         expect(find.text(chip.code), findsNothing);
   ⓑ T74-11 773행 expect(find.byType(ActionChip), findsNothing); 바로 다음에(픽스처마다 갈리므로 양쪽 다 — 기본 = 조달 없음 · funding = 조달 1단):
         if (plan.fundingSteps != null) {
           expect(find.byKey(const Key('s74-funding')), findsOneWidget);
           expect(plan.fundingSteps!, hasLength(1));
           for (final step in plan.fundingSteps!) {
             expect(find.text(step.ruleCited), findsNothing);
           }
         } else {
           expect(find.byKey(const Key('s74-funding')), findsNothing);
         }
      (if 쪽 = s74-funding 1 · else 쪽 = s74-funding 0 — 규칙 11 «있으면 1 · 없으면 0» 양쪽 · hasLength(1) 은 ⓗ 전제 줄 — 정적 S27 이 1 늘어난다 · 루프 대신 [0] 하나로 쓰지 않는다)
   ⓒ T74-13 871행 expect(find.text(plan.fundingSteps![0].label), findsOneWidget); 바로 다음에:
         expect(find.text(plan.fundingSteps![0].ruleCited), findsNothing);
   (필드 이름은 DTO 그대로 — ReasonChip.code · FundingStep.ruleCited. 화면이 이 글자를 그리지 않으므로 지금 lib 에서 통과해야 정상입니다.)

F4 (T74-22 · 1512~1554행 · C4a-6) 파일 읽기 test 로 바꾸고, 경로가 없으면 실패하게 합니다(카드 «T74-22 만 파일 읽기 test» · 규칙 11 «조용한 if 건너뛰기 금지»).
   ① 1512행 testWidgets('T74-22 planner library export structure', (tester) async {  →  test('T74-22 planner library export structure', () {
      (이름 글자는 그대로 · 본문에 await 가 없다 · 끝의 }); 는 그대로)
   ② 1533행 for (final path in checkDirs) { 안의 if (FileSystemEntity.isFileSync(path)) { … } else if (FileSystemEntity.isDirectorySync(path)) { … } 를 이 모양으로(두 갈래의 안쪽 본문은 그대로 ·
      expect 는 아래처럼 4줄로 접은 모양 그대로 — 한 줄로 쓰면 80자를 넘어 format 이 접는다):
         for (final path in checkDirs) {
           final type = FileSystemEntity.typeSync(path);
           expect(
             type,
             isNot(FileSystemEntityType.notFound),
             reason: 'Missing $path',
           );
           if (type == FileSystemEntityType.file) {
             …지금 isFileSync 갈래 본문 그대로…
           } else {
             …지금 isDirectorySync 갈래 본문 그대로…
           }
         }
   (testWidgets → test 는 테스트 수를 바꾸지 않는다 — flutter test 235 그대로.)

F5 (재시도 버튼을 에러 뷰 «안에서» 찾아 누르기 · C4a-7 · 카드 T74-05 «그 안의 retryButton 1» · T74-25 ⓑ «그 안의 retryButton 1»)
   지금은 화면 전체에서 retryButton 글자를 세고(276·1728행), 에러 뷰 Key 의 가운데를 누릅니다(287·1732·1811행 tapAndSettle(tester, 's74-…-error')) — 버튼이 가운데에 있어서 우연히 통과합니다.
   세 곳 모두 같은 모양으로 바꿉니다(<에러 Key> 만 다름 · 띄우기·다른 단언은 그대로):
      final retry = find.descendant(
        of: find.byKey(const Key('<에러 Key>')),
        matching: find.text(AnalyticsLabels.retryButton),
      );
      expect(retry, findsOneWidget);
      …(그 사이의 기존 단언 그대로)…
      await tester.tap(retry);
      await tester.pump();
      await tester.pump();
   ⓐ T74-05: <에러 Key> = s74-result-error · 276행 expect(find.text(AnalyticsLabels.retryButton), findsOneWidget); 을 위 final retry … expect(retry, findsOneWidget); 로 · 287행 tapAndSettle(tester, 's74-result-error') 를 tap(retry) + pump() 두 번으로.
   ⓑ T74-25 ⓑ: <에러 Key> = s74-setting-error · 1728행 → 같은 방법 · 1732행 tapAndSettle(tester, 's74-setting-error') → tap(retry) + pump() 두 번.
   ⓒ T74-26 ⓐ 에러 갈래(1810~1811행 · 같은 모양이라 함께): <에러 Key> = s74-result-error · 1810행 expect(find.byKey(const Key('s74-result-error')), findsOneWidget); 다음에 final retry … expect(retry, findsOneWidget); · 1811행 tapAndSettle(tester, 's74-result-error') → tap(retry) + pump() 두 번.
   (tapAndSettle 도우미는 tap → pump → pump 이라 누른 뒤의 펌프 수는 같다 · 🔴 tapAndSettle·planner_fakes.dart 를 고치지 않는다 · pumpAndSettle 로 바꾸지 않는다.)

F6 (PR 본문 ③ — 처음부터 새로 · C4a-4) 아래 «■ 제출» ③ 대로 씁니다. 핵심:
   🔴 deposit_planner_screen.dart 를 다시 열어 위 → 아래로 읽으며 아래 대조 줄과 맞는지 봅니다. 먼저 이 줄로 Key 줄을 뽑아 대조합니다(lib 를 안 바꾸므로 줄 번호는 1회차와 같다):
      (packages/ui_analytics 에서) git grep -n -e "Key('s74-" -e "StaleBanner(" -e "_buildSafetyBanner(" -- lib/src/planner/deposit_planner_screen.dart
   표기(대조 줄 · ③ 공통 — 이 넷뿐):
      «→» = 위 → 아래 순서 · «(있을 때)» 또는 «(접수표 없을 때)» 같은 괄호 = 그 조건일 때만 그려짐 ·
      «( … )» = 여러 이름이 한 덩어리로 함께 그려지거나 함께 빠짐 ·
      « / » = 바로 앞의 하나와 바로 뒤의 하나 중 하나만 그려짐(«하나» = 이름 하나 또는 ( ) 한 덩어리 · a / b / c = 셋 중 하나).
      🔴 « / » 로 여러 줄을 묶지 않습니다 — 여러 줄이 한 덩어리로 갈리면 반드시 ( ) 로 묶고 « / ».
   C4 가 92999a8 에서 확인한 줄(대조용 — grep 줄 번호나 코드의 갈래가 이와 같지 않으면 제출하지 말고 멈춘 뒤 채팅으로):
      (161 은 도우미 정의 줄 — 사슬에 세지 않는다 · _buildSafetyBanner = 안전 플래그가 있을 때만 SafetyBlockBanner(없으면 SizedBox.shrink · 161~167행) ·
       Expanded 줄(209 · 343 · 459)은 grep 에 안 나온다 — 파일에서 본다)
      스텝 ① _buildStepInput: 208 SafetyBlockBanner(있을 때 · Column 첫째) → 209 Expanded → 211 s74-list-input → 216 s74-step-title → 221 s74-intro → 226 s74-setting-header →
             ( 233 s74-setting-amount → 237 s74-setting-equivalent → 241 s74-setting-applies → 246 s74-setting-limit-note(있을 때) → 248 s74-setting-asof ) / 251 s74-setting-loading / 255 s74-setting-error →
             263 s74-amount-field → 275 s74-input-rejected(있을 때) → 281 s74-calculate → ( 288 s74-result-loading / 294 s74-result-error / 300 s74-blocked-card )(있을 때)
             (설정 자리 = settingAsync.when 229~260행 — loading·error 는 amount~asof 다섯 줄 전부를 대신한다 · 결과 자리 = 285~321행 if · else if · else if — 셋 다 아니면 아무것도 없음 · 310 s74-blocked-action 은 카드 안)
      스텝 ② _buildStepAllocation: 339 s74-preview-notice → 341 StaleBanner(있을 때) → 342 SafetyBlockBanner(있을 때) → 343 Expanded → 345 s74-list-allocation → 350 s74-step-title → 353 s74-asof → 356 s74-warning-<i>(있을 때) →
             360 s74-deposit-amount → 365 s74-allocation-<i> → 391 s74-residual(있을 때) → 396 s74-pension-limit(있을 때) → 425 s74-next → 434 s74-back
      스텝 ③ _buildStepResult: 455 s74-preview-notice → 457 StaleBanner(있을 때) → 458 SafetyBlockBanner(있을 때) → 459 Expanded → 461 s74-list-result → 466 s74-step-title → 469 s74-asof → 472 s74-warning-<i>(있을 때) →
             476 s74-result-loading / ( 481 s74-orders-title → 486 s74-orders-empty / 491 s74-order-<i> → 533 s74-costs → 551 s74-funding(있을 때) →
             567 s74-register-blocked / ( 573 s74-register-not-accepted(있을 때) → 581 s74-register )(접수표 없을 때) → 591 s74-receipt(접수표 있을 때) → 598 s74-recalculate(접수표 없을 때) → 611 s74-back(접수표 없을 때) )
             (473~620행: 다시 계산 기다림(_pending)이면 s74-result-loading 하나가 orders-title~back 전부를 대신 · 등록 자리 564~588행 = 등록 불가 문장(registerBlockedText)이 있으면 s74-register-blocked 하나만,
              없고 접수표가 없으면 [접수 실패 줄(_notAccepted 일 때) → 등록 버튼] · 589~592행 접수표는 있을 때만 · 593~619행 다시 계산·뒤로는 접수표가 없을 때만)
   «차단» 에 s74-register-blocked 를 쓰지 않습니다(그것은 스텝 ③ 사슬 안의 등록 불가 문장 · 안전 차단이 아니다) · 스텝 ② 에는 등록 자리가 없습니다.
   «상단» 이라고 쓰지 않습니다 — 자리는 «s74-preview-notice → StaleBanner(있을 때) 다음 · Expanded(ListView) 바깥 위» 처럼 코드 그대로.
   사슬은 ListView 의 직접 자식(과 Column 머리)의 Key 를 하나도 빼지 않습니다.
   (카드 안·행 안의 Key — s74-blocked-action · s74-allocation-<i>-account · -reason · s74-pension-suggestion · s74-pension-funding-note · s74-order-<i>-limit · -pending · s74-funding-<i> — 는 사슬에 넣지 않습니다.)

F7 (PR 본문 ② 끝 — ⓡ·ⓗ 까닭 한 줄 · C4a-8) «ⓡ = <S26 출력의 수> · ⓗ = <S27 출력의 수>» 줄 바로 다음에 «까닭: …» 한 줄을 적습니다.
   1회차 카드의 드라이런 수(S26 = 29 · S27 = 20)와 수가 다른 까닭을 **자기 테스트 파일에서 grep -n 으로 줄을 보고 센 사실로만** 적습니다 — 자기 파일의 짜임만(어느 테스트에 ⓡ 줄이 몇 줄인지 · hasLength( 줄 가운데 목록 전제가 몇 줄 · 호출 수 단언이 몇 줄인지와 그 행 번호).
   🔴 드라이런 쪽 짜임(드라이런 테스트가 어디에 몇 줄을 두었는지)은 쓰지 않습니다 — 드라이런 파일은 저장소에 없어 볼 수 없습니다(추측해 쓰면 보고 ≠ 사실 = 반려).
   (C4 가 92999a8 에서 센 것 — 확인용: ⓡ 39 중 T74-02·T74-21·T74-23 이 3줄씩 · ⓗ 15 에서 T74-10 은 스텝 ②③ 을 hasLength 한 줄로 받친다. F3 뒤 ⓗ 는 T74-11 에 한 줄이 늘어난다.)
   🔴 수는 F1~F5 를 고친 뒤 푸시한 커밋에서 새로 돌린 S26·S27 출력 그대로(1회차 39·15 를 옮겨 적지 않는다 · 손으로 센 수를 따로 적지 않는다).

F8 (커밋 · C4a-9) 커밋은 «한 일» 하나씩 — «format» 커밋에는 dart format 이 바꾼 줄만 넣습니다(다른 수정을 섞지 않는다).
   (1) F1~F5 → git commit -m "[M7] R11a 재제출 (1) 테스트 보강"
   (2) 그 뒤 melos.bat run format:fix 가 무엇을 바꿨을 때만 → git commit -m "[M7] R11a 재제출 (2) format"(바뀐 것이 없으면 (2) 는 만들지 않는다)
   (F1~F5 를 이 카드의 모양(F4 의 expect 4줄 포함)대로 쓰면 format 이 바꿀 것이 없어 (2) 가 없는 것이 기대입니다 — 통합 담당 시험 적용 실측. (2) 가 생겨도 반려 사유는 아니며, 생겼으면 PR 본문 ② 끝에 «(2) format = <바뀐 곳>» 한 줄을 적습니다.)

■ 고치지 않는 것 (1회차가 맞았거나 이 카드 밖 — 손대면 반려)
 · lib/** 전부 · PNG 전부(s74_* 14장 포함 — --update-goldens 금지) · s74_golden_test.dart · planner_fakes.dart · labels.dart
 · 골든 dy — lib·골든 테스트·PNG 가 그대로라 다시 재지 않습니다(질문 파일 A1~A7 = 1회차 실측 · C4 재실측 14/14 일치 · s74_golden_test.dart 를 열어 lessThan(0) 으로 바꾸는 일도 하지 않는다)
 · 질문 파일 docs/ai-context/inbox/S7-4_questions.md — A1~A7 행·머리말(«다음 번호» 포함)을 지우지도 고치지도 않는다(답은 병합 때 통합 담당이 C4 재실측과 대조해 닫는다)
 · T74-02 의 장면 A·C · T74-15 의 앞쪽 if/else · 나머지 테스트(T74-01 · 03 · 04 · 06~10 · 12 · 14 · 16~18 · 20 · 21 · 23 · 24) — 이번에 걸린 곳이 아니다
 · ⓡ 줄 — 더하지도 빼지도 않는다 · 테스트 이름 · 테스트 수(235 그대로)

■ 질문 파일
· 이번 F1~F8 은 전부 이 패킷이 정했고 lib·PNG 가 그대로라 잴 것도 없으므로, 질문 파일은 바뀌지 않는 것이 정상입니다(새 행 0).
· 🔴 새 행이 필요해 보이면(측정·추측·질문 어느 것이든) 질문 파일에 쓰지 말고 멈춘 뒤 채팅으로 — 이번 커밋은 테스트 파일 하나만 add 하고, 아래 «git diff --name-status 92999a8 HEAD» 는 테스트 한 줄이어야 합니다(질문 파일 줄이 나오면 멈춤).
· 🔴 test/golden/README 를 고치면 반려입니다.

■ 제출
  (F1~F5 를 고친 뒤)
  cd packages/ui_analytics
  flutter test test/deposit_planner_view_test.dart   ← 먼저 이 파일만 · 25 통과(실패하면 고친 곳을 다시 본다 · lib 를 고치지 않는다)
  flutter test   ← 옵션 없이 전부 통과 · 수 = 235(1회차와 같다 — 채팅에 실제 수를 적습니다)
  git status --short   ← M 은 test/deposit_planner_view_test.dart 하나뿐이어야 합니다(PNG·lib 의 M = 금지 → git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로)
  cd ../..
  git add packages/ui_analytics/test/deposit_planner_view_test.dart
  git commit -m "[M7] R11a 재제출 (1) 테스트 보강"   ← F1~F5
  melos.bat run format:fix
  git status --short   ← 비었으면 (2) 없음(기대) · packages/ui_analytics/test/deposit_planner_view_test.dart 가 M 이면:
     git add packages/ui_analytics/test/deposit_planner_view_test.dart
     git commit -m "[M7] R11a 재제출 (2) format"   ← format 이 바꾼 줄만(F8)
     (그 밖의 파일이 M 이면 커밋하지 말고 멈춘 뒤 출력을 채팅으로)
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git diff --name-status 92999a8 HEAD
     ← 재제출 커밋(1개 또는 2개)의 변경만 봅니다. 🔴 정확히 이 한 줄이어야 합니다:
        M	packages/ui_analytics/test/deposit_planner_view_test.dart
        다른 줄이 한 줄이라도 나오면(lib · PNG · 질문 파일 · planner_fakes · s74_golden_test …) 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #19 자동 반영 · 새 PR·라벨·강제 푸시·rebase·main 병합 금지)
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(1회차와 같은 22줄이 정상 — main 이 앞으로 갔어도 점 세 개 diff 는 갈라진 곳(e821f36)부터 센다)
  cd packages/ui_analytics → 아래 «정적 묶음» 29줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력
     🔴 푸시한 그 커밋 위에서 · git status 가 빈 채로 새로 돌린다 · 1회차 출력을 쓰지 않는다.
■ 정적 묶음 — packages/ui_analytics 에서 아래 29줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 29줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 2>&1 로 모으면 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힌다 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 사람이 적는 줄은 **정확히** «<파일>:<줄> — 탭 콜백 안» 만(정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ · 괄호·설명·위젯 이름 금지 · R10c 2회차 반려 사유).
     lib 를 안 바꾸므로 S05 는 1회차와 같은 2줄(…deposit_planner_screen.dart:165 · :312)이 나와야 합니다 — 다르면 lib 가 바뀐 것이니 멈춘 뒤 채팅으로.
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/deposit_planner_view_test.dart test/planner_fakes.dart test/golden/s74_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/deposit_planner_view_test.dart test/golden/s74_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/deposit_planner_view_test.dart test/golden/s74_golden_test.dart; echo "EXIT:$?"
echo "## S03 input normalization 0"; git grep -nE "replaceAll|replaceFirst|\.trim\(|int\.parse|num\.parse|double\.parse|tryParse|inputFormatters" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S04 AppRoutes 0"; git grep -n "AppRoutes" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/planner; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 other WhatIfApi calls 0"; git grep -nE "estimateCosts|findPlan|previewRebalance|simulateWithdrawal" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S15 autoDispose 3"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 planner outside planner 0"; git grep -n "planner" -- lib/ui_analytics.dart lib/src/screens lib/src/widgets lib/src/providers lib/src/chart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S19 item1 package imports"; git grep -nE "^import 'package:" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 planner autoDispose 1"; git grep -n "autoDispose" -- lib/src/planner; echo "EXIT:$?"
echo "## S23 chip link state 0"; git grep -nE "ActionChip|detailDeepLink|rejectReasonCode|expiresAt|computedAt" -- lib/planner.dart lib/src/planner; echo "EXIT:$?"
echo "## S24 rate literals 0"; git grep -nP '(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])' -- lib; echo "EXIT:$?"
echo "## S25 amount literals 0"; git grep -nP '(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}' -- lib; echo "EXIT:$?"
echo "## S26 retry-nothing lines"; git grep -c "retryButton), findsNothing" -- test/deposit_planner_view_test.dart; echo "EXIT:$?"
echo "## S27 hasLength lines (premise + call counts)"; git grep -c "hasLength(" -- test/deposit_planner_view_test.dart; echo "EXIT:$?"
echo "## S28 planner exports 2"; git grep -n "^export" -- lib/planner.dart; echo "EXIT:$?"
  (줄의 뜻 — 1회차 카드 «■ 정적 묶음» 끝의 설명 그대로 · S26 = ⓡ 줄 수 · S27 = hasLength( 가 든 줄 전부(ⓗ 전제 + 호출 수 단언) — 둘 다 숫자 한 줄 «파일:N» · PR 본문의 수와 글자로 대조)
  (기대 출력 — lib·PNG 불변이라 S26·S27 밖의 27줄은 1회차 출력과 같다 · S26 = test/deposit_planner_view_test.dart:39(1회차와 같다 — ⓡ 줄을 더하지도 빼지도 않으므로) · S27 = test/deposit_planner_view_test.dart:16(F3 ⓑ 의 hasLength 한 줄 때문에 1회차 15 보다 1 많다) — 둘 다 통합 담당 시험 적용 실측 · 🔴 PR 본문에는 자기가 새로 돌린 출력 그대로 적고, 이 기대와 다르면 PR 본문 ② 끝 까닭 줄에 그 까닭을)
  채팅으로 — PR 본문 5섹션을 처음부터 새로(지난 본문을 고쳐 쓰지 않습니다). PR #19 본문은 통합 담당이 이 새 판으로 통째로 바꿉니다:
   ① 화면 ID(S7-4 — DepositPlannerScreen · package:ui_analytics/planner.dart) 한 줄 +
      바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(손으로 쓰지 않음 · A/M · PNG 포함 · 22줄이 정상)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · N 만 채운다 — 1회차와 같은 글자):
        1번 = «정적 묶음 S19 — domain_contracts·flutter·flutter_riverpod 밖 0줄»
        2번 = «워터폴 잔여 = residualKrwCashText 그대로(T74-07) · 금액 원값 미참조(C-38 ⑩ · 정적 묶음 S24·S25 0건)»
        3번 = «정적 묶음 S20 — 0건»
        4·5·7·8·12번 = «이 카드 범위 밖»
        6번 = «plan 은 simulateDeposit 결과만(T74-03) / previewNotice 스텝 ②③ 스크롤 밖 고정(T74-09) / 주문 실행 버튼 0 — registerDeposit 1회(T74-16)»
        9번 = «스텝 ②③ s74-asof + StaleBanner(asOf: plan.asOf)(T74-21·T74-24) · 스텝 ① setting.asOf.label(s74-setting-asof)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 git status 의 기존 PNG M 0 · domain_contracts 변경 0»(10번은 «앞절 … / 뒷절 …» 로 괄호 하나)
        11번 = «정적 묶음 S21 결과 N건»
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
      이어서 «정적 묶음» 출력 전부를 코드 블록 하나로 그대로 + S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄
      (괄호·설명 금지 · 줄을 빼거나 줄이면 = 보고 불일치 = 반려) + «ⓡ = S26 출력 · ⓗ = S27 출력» 한 줄(숫자는 출력 그대로) + 바로 다음 «까닭: …» 한 줄(F7).
   ③ 스크린샷 서술 — 6줄(로딩 1 · 정상은 스텝마다 1줄 = 3 · 빈 1 · 차단 1) + 골든 표 14행(처음부터 새로 — 1회차 ③ 을 고쳐 쓰지 않는다)
      🔴 6줄은 아래 글자 그대로 씁니다. 통합 담당이 92999a8 코드와 대조해 만든 글자이고, lib 를 안 바꾸므로 답이 하나입니다.
         Bob 이 할 일 = deposit_planner_screen.dart 를 열고 F6 의 grep 줄 번호·갈래와 대조해 맞는지 보는 것. 맞지 않는 곳이 하나라도 있으면 고쳐 쓰지 말고 멈춘 뒤 채팅으로.
         표기는 F6 의 넷(«→» · 조건 괄호 · «( … )» · « / »)뿐 · 요약어(«상단»·«순서대로»·«정상 배치»·«모두»·«연이어») 금지 · 줄 머리(«- 로딩:» 등)를 빼거나 낱말을 바꾸지 않는다.
      ┌── ③ 6줄 복사 시작(다음 줄부터)
- 로딩: 스텝 ① 설정 자리 = s74-setting-header 다음 s74-setting-loading(첫 값 전) / s74-setting-error(에러) — 둘 다 s74-setting-amount 부터 s74-setting-asof 까지를 대신 · 스텝 ① 결과 자리 = s74-calculate 다음 s74-result-loading(계산 기다림) · 스텝 ③ = s74-warning-<i>(있을 때) 다음 s74-result-loading(다시 계산 기다림 — s74-orders-title 부터 s74-back 까지를 대신)
- 정상 스텝 ①: SafetyBlockBanner(있을 때) → Expanded(ListView s74-list-input) → s74-step-title → s74-intro → s74-setting-header → ( s74-setting-amount → s74-setting-equivalent → s74-setting-applies → s74-setting-limit-note(있을 때) → s74-setting-asof ) / s74-setting-loading / s74-setting-error → s74-amount-field → s74-input-rejected(있을 때) → s74-calculate → ( s74-result-loading / s74-result-error / s74-blocked-card )(있을 때)
- 정상 스텝 ②: s74-preview-notice → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → Expanded(ListView s74-list-allocation) → s74-step-title → s74-asof → s74-warning-<i>(있을 때) → s74-deposit-amount → s74-allocation-<i> → s74-residual(있을 때) → s74-pension-limit(있을 때) → s74-next → s74-back
- 정상 스텝 ③: s74-preview-notice → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → Expanded(ListView s74-list-result) → s74-step-title → s74-asof → s74-warning-<i>(있을 때) → s74-result-loading / ( s74-orders-title → s74-orders-empty / s74-order-<i> → s74-costs → s74-funding(있을 때) → s74-register-blocked / ( s74-register-not-accepted(있을 때) → s74-register )(접수표 없을 때) → s74-receipt(접수표 있을 때) → s74-recalculate(접수표 없을 때) → s74-back(접수표 없을 때) )
- 빈: s74-orders-empty — 스텝 ③ · s74-orders-title 다음 · s74-order-<i> 대신 · s74-costs 앞
- 차단: SafetyBlockBanner — 스텝 ① = Column 첫째 · Expanded(ListView s74-list-input) 바깥 위 · 스텝 ②③ = s74-preview-notice → StaleBanner(있을 때) 다음 · Expanded(ListView) 바깥 위 + 스텝 ① 결과 자리(s74-calculate 다음)의 s74-blocked-card
      └── ③ 6줄 복사 끝(이 줄 앞까지)
         🔴 s74-register-blocked 는 «차단» 에 쓰지 않는다(스텝 ③ «정상» 사슬 안의 등록 불가 문장) · 스텝 ② 에 등록 자리가 있다고 쓰지 않는다.
      골든 표 14행: 머리 줄 «| 골든 이름 | 입력 픽스처 | 크기 | 위치 전제 dy | 배치·잘림 |» · 이름은 «s74_step1_default light» 처럼 이름 + 밝기(1회차와 같은 순서 — 장면마다 light → dark) —
        입력 픽스처 칸 = 1회차 칸 글자 그대로(장면이 쓰는 경로 전부 · 설정·안전 행 포함) · blocked 의 «m7/m7_deposit_plan_blocked.json (행 0)» 만 «m7/m7_deposit_plan_blocked.json 행 0» 으로 고친다(괄호 없이). 장면별 글자(light·dark 같음):
          s74_step1_default = m9/contribution_setting_default.json · safety_states.json 행 0
          s74_step2_normal = m9/contribution_setting_default.json · m7/m7_deposit_plan_default.json · safety_states.json 행 0
          s74_step3_normal = m9/contribution_setting_default.json · m7/m7_deposit_plan_default.json · safety_states.json 행 0
          s74_pension_limit_hit = m9/contribution_setting_default.json · m7/m7_deposit_plan_limit.json · safety_states.json 행 0
          s74_expired = m9/contribution_setting_default.json · m7/m7_deposit_plan_expired.json · safety_states.json 행 0
          s74_funding = m9/contribution_setting_default.json · m7/m7_deposit_plan_funding.json · safety_states.json 행 3
          s74_blocked = m9/contribution_setting_default.json · m7/m7_deposit_plan_blocked.json 행 0 · safety_states.json 행 4
        크기 = 390×844 / 390×844 / 390×1100 / 390×844 / 390×1100 / 390×1300 / 390×844(위 장면 순서 · 1회차 그대로) ·
        dy = 질문 파일 A1~A7 의 값 그대로(1회차에 이름·밝기마다 잰 값 · lib·골든 테스트·PNG 가 그대로라 같다 — 다시 재지 않는다) ·
        배치·잘림 = PNG 14장을 다시 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 못 본 것은 «미열람» · «정상 배치» 는 다시 열어 맞을 때만).
   ④ 질문 표 — 질문 파일 docs/ai-context/inbox/S7-4_questions.md 의 표(머리 줄 2줄 + A1~A7 7행)를 글자 그대로 붙이고, 그 아래에 «새 행 없음 — A1~A7 그대로» 한 줄을 붙인다(표 + 한 줄 · 둘 다).
   ⑤ 추측한 것 = «없음» 한 줄 — A1~A7 은 «종류» 칸이 «추측» 이지만 «질문·추측» 칸이 «측정:» 으로 시작하는 측정 행이라 ⑤ 에 넣지 않는다(1회차 ⑤ «없음» 과 같다 · 질문 파일과 ⑤ 가 다르면 반려).
   (+ flutter test 실제 통과 수 한 줄)
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s74-planner` 에 추가 커밋: `[M7] R11a 재제출 (1) 테스트 보강` + (format 이 무엇을 바꿨을 때만) `[M7] R11a 재제출 (2) format`. main 병합 커밋 **없음**(이 카드가 금한다). (2) = **없음이 기대**(시험 적용: 앞 판 F4 한 줄 모양으로는 format 이 그 한 줄을 4줄로 접어 (2) 가 생겼다 → 이 판은 F4 를 4줄 모양으로 적었고, 그 모양을 얹어 `dart format` 0 changed 확인 · 생기면 반려 사유는 아니고 PR 본문 ② 끝 한 줄).
- `test/` 수정 1 — `deposit_planner_view_test.dart`: F1 T74-02 장면 B(입력 글자 `'${amountInputText}0'` · 끝 단언 `s74-setting-amount` Key) · F2 T74-15 else `s74-funding` findsNothing · F3 T74-11 칩 `code` 0 + 조달 if/else(if = `s74-funding` 1 · `hasLength(1)` 전제 · `ruleCited` 0 / else = `s74-funding` 0) · T74-13 `ruleCited` 0 · F4 T74-22 `test(` + `typeSync` 전제 · F5 T74-05·T74-25ⓑ·T74-26ⓐ 재시도 = 에러 뷰 안 `retryButton` descendant.
- `lib/` 변경 0 · PNG 변경 0 · 질문 파일 변경 0 — `git diff --name-status 92999a8 HEAD` = `M	packages/ui_analytics/test/deposit_planner_view_test.dart` 한 줄.
- `ui_analytics` `flutter test` 235(1회차와 같음 · 시험 적용 실측 235 통과 · 0 실패) · 채팅: PR 본문 5섹션(① `git diff --name-status origin/main...HEAD` 그대로(22줄 · 1회차와 같은 글자) · ② 복사 상자 12항 + [x] + 괄호 + 정적 29줄 새 출력(S05 = `:165`·`:312` 그대로 · S26 = `:39` · S27 = `:16` — 시험 적용 실측 · 다르면 PR 본문에 까닭) + «ⓡ = … · ⓗ = …» + «까닭: …»(자기 파일 짜임만) · ③ 6줄 = «■ 제출» ③ 복사 상자 글자 그대로 + 골든 표 14행(입력 픽스처 = 1회차 글자 · blocked «행 0» 괄호 없음 · dy = A1~A7) · ④ A1~A7 표 + «새 행 없음 — A1~A7 그대로» · ⑤ «없음»).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R11a-Bob-S74 재제출: PR #19 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다(Claude 가 PR #19 본문을 이 새 판으로 통째로 바꿉니다). 0단계·«먼저 할 것»에서 멈췄다면 `R11a-Bob-S74 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR #19 «Files changed» — `92999a8` 뒤 커밋만 보면 된다): ① `packages/ui_analytics/lib/` 의 변경 ② PNG 변경(`s74_*` 포함 — 이번에는 한 장도 바뀌면 안 된다) ③ `planner_fakes.dart`·`s74_golden_test.dart`·`labels.dart`·`pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README·질문 파일 변경 ④ `Merge … origin/main` 커밋(이번에는 없어야 정상) ⑤ T74-02 장면 B 의 입력이 아직 `defaultSetting.amountInputText` 그대로 · T74-15 에 else 없음 · T74-22 가 아직 `testWidgets(` ⑥ ③ 에 «상단» · 스텝 ② 의 `s74-register-blocked` · 스텝 ③ 사슬에 `s74-orders-empty`·`s74-register-blocked`·`s74-register-not-accepted`·`s74-receipt` 가 없음 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이 PR 의 PNG 가 `main` 기준으로 전부 새 파일(A)이라 **초록이 정상**입니다(빨간색 = 기존 PNG 를 건드린 것 = 반려 신호). `golden:approved` 는 필요 없고 붙이지 않습니다.
- CI «분석 · 테스트(melos)» 는 비교기 infra PR(C4a-1)이 `main` 에 들어간 **뒤의** 푸시부터 초록이 됩니다(PR CI 는 병합 미리보기를 돌린다 — main 병합 불필요). 그 PR 이 Bob 푸시보다 늦으면 빨강(234/1 · `s74_pension_limit_hit_light`)이 남는 것이 정상이고 Bob 몫이 아닙니다 — Claude 가 infra PR 병합 뒤 PR #19 를 닫았다 다시 열어 CI 를 새 `main` 위에서 다시 돌린다(«보내는 조건» ②). CI 의 테스트 수는 infra PR 이 비교기 테스트를 더한 만큼 235 보다 많을 수 있다(로컬 Bob 수 235 와 다른 것이 정상).
- C4 가 2회차에서 볼 것: lib diff 0 · PNG diff 0 · `git diff --name-status 92999a8 HEAD` 한 줄 · 예고 변이 P04(`_touched` 제거)를 다시 넣어 T74-02 가 실패하는지(🔴 **반려 판정 대상 = 1회차 카드의 예고 기본형 27항목(P04 포함)뿐** · 1회차 생존 변이 16개(P05c·P14b·X02·X19·X23·X28·X32·X33·X34·X36·X39·X47~X51)는 재실행하더라도 참고 — 시험 적용에서도 그대로 산다 · 카드가 겨눈 것이 아니다 · C4 보고 §5 [다] 그대로 · 반려 사유 아님) · T74-15 else · T74-11·T74-13 `code`·`ruleCited` 단언 · T74-22 `test(` + 없는 경로 실패(경로 하나를 잠시 틀리게 해 본다) · 재시도 descendant 3곳(버튼을 에러 뷰 밖으로 옮기는 변이) · ② 12항(15줄) 글자 diff · 정적 29줄 글자 대조(S26·S27 새 수) · ③ 을 코드 Key 줄 번호와 대조 · 골든 dy 14개 재실측(1회차와 같아야 함) · 질문 파일 불변.
- 병합 뒤 할 일(Claude · C4 보고 §7·§8): 질문 A1~A7 ✅ + 머리말 «다음 번호 = Q1·A8»(재제출이 새 행을 더했으면 그 뒤 번호) · 재제출 패킷 `send/R11a-Bob-S74-재제출.md` → `_완료/` · `_대기/R11b-Bob-S79.md` → `send/`(R11b 시작 기준 235 = 재제출 병합본 실측으로 다시 확인) · infra PR 번호·해시를 rounds R11a 행·12 §3·핸드오프에 한 마디.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R11a 패킷은 이 파일 하나입니다. 원 패킷 `R11a-Bob-S74.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 합니다). `_완료/R10c-Bob-S72-재제출.md` · `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드입니다.
