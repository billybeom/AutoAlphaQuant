# 발송 패킷 R11b-Bob-S79 — S7-9 목표 금액 경로 + 부록(S7-1 목표 경로 버튼 · 값 열 정렬) (계약 v1.4 · R11 2장 중 2번째)

> ▶ **보낼 수 있습니다**(2026-10-01) — R11a 병합(PR #19 · squash `df42632`)과 이 카드를 `send/` 로 올린 R11a 병합 기록 커밋이 GitHub `main` 에 있습니다. **R11 2장 중 2번째**(R11c `S7-5` 는 보류) · 한 번에 카드 1장 · 순서 R11a → R11b.
> 만든 날 2026-09-30 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R11b 행 · §6 3b · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-09-30_R11선행_계약v1.4_설계서.md` §2 Δ6(R11b)·Δ7 + §3 «4-3»·«5-1»·«5-2» + §5 패킷 규칙([b]·공통) · 조문 = `01_…` §14-9 · §14-10 · §14-11 · §14-19 · `03_…` §14 의 «🆕 계약 v1.4 — `S7-9` R11 범위» 블록 · golden README «🆕 R11(계약 v1.4)» 절.
> 사전 조건 — ✅ 계약 v1.4 병합(M2 PR #18 · squash `b288a00` · 기록 `c3fa414`) · ✅ **R11a-Bob-S74 병합**(PR #19 · squash `df42632` — `S7-4` 플래너 · `lib/planner.dart` · 골든 `s74_*` 14장 · `labels.dart` 끝 R11a 절 · 1회차 `92999a8` 반려 → 재제출 `fe85f36`(테스트 1파일 · lib·PNG 0)) · ✅ 골든 비교기 infra PR #20(squash `a0e1ae1` · 보조 1.0% + P2 · `comparator_test` 11 → 32). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 병합본 `flutter test`(packages/ui_analytics) = **256**(v1.4 196 + 비교기 +21 + R11a 39 · C4 실측 — 드라이런의 235 는 비교기 PR 앞의 수).
> 카드 확정값(카드 권한): 정적 라벨 4개(본문 «정적 라벨») · Key 표(본문 «Key 표») · 위젯·프로바이더·파일 이름(본문 «주입 구조») · 골든 4이름 8장(크기 390 × 900) · 부록 재생성 허용 목록 `s71_*` 10장(드라이런 실제 M = 6장).
> 🔴 **보내는 조건(Claude 확인)** — R11a PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-9_questions.md` 가 `main` 에 있음(빈 머리말 — 기록 커밋 `c3fa414` 이 만든다). 0단계의 `ls` 줄이 그 증명입니다.
> ✅ **`send/` 로 올림**(2026-10-01 · R11a 병합 기록 커밋 — R11a 재제출 패킷은 `_완료/` 로 · 원 패킷은 1회차 반려 기록 `a1d300f` 에서 이미 `_완료/`). `send/` 바로 아래의 카드는 이것 하나다(설계서 §5 · R11a §2-5 «이것 하나»와 맞춤).
> 🔴 **카드 덮개 필수 문장(01 §14-19)** — «`S7-9` 에는 세후 사다리가 없다 — 정직 기대는 인용 문장 한 줄씩» · «`S7-9` 는 `ConfigRepository` 를 읽지 않는다 — 가정 카드 2줄은 `startingCapitalAssumptionText`». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» ⑰⑱ 에 있습니다. Key 표와 라벨 글자 표도 본문에 있습니다.
> 드라이런: ✅ 2026-09-30 누적 드라이런(검사 폴더 `C:/Work/AAQ-claude-review` · 가지 `dry/r11b` 끝 `b896ebb` · R11a 드라이런 `a8d8c7f` 위 · 카드 본문만 보고 커밋 6개) — `flutter test`(packages/ui_analytics) = 기존 235 + 새 48(뷰 34 + 골든 8 + TA 6) = 283 · domain_contracts 257 통과 · 30 skip · 0 실패 · 새 PNG 8 · 재생성 `s71_*` 6장(normal·partial_gap·masked_recon × light/dark) · 기존 46장 불변 · `s79-disclaimer` 아래 끝 dy = on 803 · off 847 · hold 562 · realworld 827(light·dark 같음 · 높이 900) · 예고 변이 20종 중 19 잡힘 → 놓친 1(부록 «버튼을 Divider 아래로»)은 TA-2 사슬에 Divider 를 넣어 잡음(드라이런 확인 · 이 판에 반영) · S05a 1줄 · S05b 5줄 · S15 4 · S27 6/0 · 8/0 · 17/2 · 1/0 · 146/0(TA-2 보강 전) · S29 13·3 · S30 8·1 · 드라이런 지적 10건 + 콜드 리드 13건 반영(이 판).
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 치환값(2행 · 108행 범위 · 117행 PR 제목)은 기록 커밋 `c3fa414` 이 R11 두 장(R11a·R11b)을 함께 적은 값으로 바꾼다 · 0단계 확인 줄 `git grep -c "R11b = S7-9"` 이 그 증명 · 🔴 `c3fa414` 은 R10 판 모양 그대로 쓴다 — 2행 `{{범위}}` 값 = `S7-4 · S7-9 중 붙여넣은 카드 한 장의 범위(R11a = S7-4 · R11b = S7-9)` · 108행 «이번 과제 범위:» 도 같은 괄호(한 줄 1회) · PR 제목 부분(2행 뒤쪽 · 117행)은 «R11b `[M7] …`» 모양으로 «R11b = S7-9» 글자를 넣지 않는다 · 괄호 안 `S7-9` 에 백틱을 두르지 않는다 → 합계 `:2` · ⚠ 드라이런 모사 커밋(`a85883d`)은 prompt_M7 치환을 하지 않아 이 확인 줄은 드라이런 미검증이다 — Claude 가 ▶ 로 바꾸기 전에 실제 `main` 에서 이 grep 을 돌려 `:2` 를 확인한다 · 이 카드의 범위·PR 제목은 이 패킷이 정한다 · 그 파일 머리 4행 «🔵 정정 표식»이 말하는 «R11b 카드 덮개»가 아래 «프롬프트보다 이 카드가 이긴다» ⑥⑰⑱ 이다) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R10·R11a 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 이렇게 쓴다»로, 0단계·규칙 요약·본받지 않는 것·코드 틀은 본문에 담았습니다.
> R10 교훈 반영: 보고 기계화(② 12항 복사 상자 + «정적 묶음» 출력 그대로 · ① name-status 출력 그대로 · ③ 위젯·Key 이름 나열 + `FixturePaths` 경로) · S05 줄 괄호 금지(R10c 2회차 반려 사유) · 보강 줄 개수는 정적 묶음 `grep -c` 줄로 대조(R10c C4c2-2) · 배치 순서는 테스트가 사슬로 증명(R10c 1회차 반려 사유) · 조건부 단언 금지(R10b·R10c) · 공용 파일은 «정확히 N»으로 못박지 않고 «더하기만»(R10 3분할 교훈 · «정확히 N» = 이 카드의 새 테스트 T79-14 한 곳).

## 0. 한 줄 목적

목표는 수익률이 아니라 **금액**이다 — 월간 리포트(S7-1)의 한 줄에서만 들어가는 **목표 경로 화면(S7-9 · 판정·계획선 대 실제선·가정 카드 두 줄·값 표)** 을 계약 v1.4 그대로 짓고, 마지막 별도 커밋으로 S7-1 에 그 진입 버튼과 값 열 오른쪽 정렬(미결 63)을 더하기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s79-goal-path`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **R11a 가 `main` 에 병합된 뒤에 보냅니다** — 이 파일 머리 첫 줄이 ⏸ 이면 아직입니다(Claude 가 R11a 병합을 기록할 때 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R11a 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R11b-Bob-S79.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r11\docs\ai-context\send\R11b-Bob-S79.md` · 기록 푸시 뒤 `main` 과 글자가 같습니다). 🔴 Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 R11a 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부**(«R11b-Bob-S79 — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 R11 의 끝난 카드 `_완료/R11a-Bob-S74.md`·`_완료/R11a-Bob-S74-재제출.md`(R11a 병합 PR #19 · 1회차 + 재제출), M7 의 끝난 카드 `_완료/R10a-Bob-S71b.md`·`_완료/R10b-Bob-S72G*.md`·`_완료/R10c-Bob-S72*.md`·`_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73*.md`, M6 의 끝난 카드 `_완료/R2b-Bob-J3.md` 를 붙여넣지 않습니다. `send/` 바로 아래의 R11 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R11b-Bob-S79 — 범위: S7-9 목표 금액 경로(GoalPathScreen — 기준일 · 판정 · 판정 근거 · 이탈 문장 · 기간 · 차트(본보기 2파일을 글자 그대로 옮김) ·
  x 양 끝 글자 · 범례 · 띠 캡션 · 「숫자로 보기」 값 표 · 판정 유보 카드 · 가정 카드 두 줄 · 정직 기대 인용 두 줄 · 고지) ·
  부록(마지막 별도 커밋) = S7-1 «목표 경로 보기» 버튼 + S7-1 값 열 오른쪽 정렬(01 §8 미결 63 · S7-1 질문 A13) + s71_* 골든 재생성.
  R11 2장 중 2번째(R11a 는 이미 main 에 병합됨).
🔴 S7-9 에는 세후 사다리가 없다 — 정직 기대는 인용 문장 한 줄씩(honestExpectationText · honestExpectationWorstText).
🔴 S7-9 는 ConfigRepository 를 읽지 않는다 — 가정 카드 2줄은 startingCapitalAssumptionText(엔진 문장)이다.
하지 않는 것: S7-4 플래너(R11a 몫 — 이미 main) · S7-5 인출(R11c · 보류) · 핸드북 «기대치의 한계» 연결(버튼 없음 · 미결 76) · 목표 금액 입력(미결 80) ·
  달 고르기·과거 달 재현 · 달성률·필요 수익률·게이지 · 홈·알림·플래너 진입점 · 셸 몫(라우트 등록·라우터 가드·실제 닫기 — M8 · R13) ·
  웹 2열·반응형 · 차트 탭 읽기·툴팁·선택 표시 · 애니메이션 · S7-1 의 부록 밖 수정 · S-4(아카이브 여백 — 싣지 않음).
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 19항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R11a(ui/m7-s74-planner · 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/goal_path/ · GoalPathScreen · goalPathProvider · Key s71-goal-link 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s74-planner 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s79-goal-path origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.4.0'" -- packages/domain_contracts/lib/src/contract_version.dart     ← «…contract_version.dart:1»(계약 v1.4 병합)
  ls docs/ai-context/send/R11b-Bob-S79.md                                                               ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/ui_analytics/lib/planner.dart                                                             ← 보여야 R11a 가 병합된 것입니다
  ls packages/ui_analytics/test/golden/goldens/s74_step1_default_light.png                              ← 보여야 함(R11a 골든)
  ls packages/ui_analytics/test/golden/reference/goal_path/goal_path_chart.dart                         ← 보여야 함(본보기 — 옮길 코드)
  ls packages/ui_analytics/test/golden/reference/goal_path/goal_path_chart_painter.dart                 ← 보여야 함
  ls packages/ui_analytics/test/golden/goal_path_probe_test.dart                                        ← 보여야 함(하네스 자체 검증)
  ls packages/ui_analytics/lib/src/chart/perf_chart_geometry.dart                                       ← 보여야 함(R10c — 본보기가 import 한다)
  ls packages/domain_contracts/fixtures/m7/m7_goal_path_off.json                                        ← 보여야 함(v1.4 신설 픽스처)
  ls docs/ai-context/inbox/S7-9_questions.md                                                            ← 보여야 함(빈 표가 이미 있다)
  git grep -c "R11b = S7-9" -- docs/ai-context/prompt_M7.md                                             ← «…prompt_M7.md:2»(프롬프트의 범위 치환값이 R11 로 바뀌었다 — 2행·108행)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 네 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R11b 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/goal_path                                                            ← 없어야 함
  ls packages/ui_analytics/lib/src/screens/goal_path_screen.dart                                        ← 없어야 함
  git grep -c goalPathProvider -- packages/ui_analytics/lib                                             ← 출력 없음이어야 함
  git grep -c s71-goal-link -- packages/ui_analytics/lib                                                ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.4 새 필드(GoalPathVm 재설계 · MonthlyReport.goalDeepLink …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: R11a 병합본 전부 통과 · 0 실패 · 256(통합 담당 병합본 실측 = 계약 v1.4 196 + 비교기 infra PR #20 의 comparator_test 21 + R11a 39 · 드라이런 235 는 비교기 PR 앞의 수 · 256 이 아니면 PR 본문에 까닭 한 줄 — 이 수를 «시작 기준 N» 으로 적어 둔다).
                   실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·chart_probe·본보기) > 이 카드(지시) > 01 §14 > 03 §14 의 R11 범위 블록 > 03 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·goal_path_probe_test·reference/**·README ·
   기존 골든 테스트 전부(s71_golden_test 포함 — 부록의 재생성은 PNG 만 · 테스트 파일은 한 줄도 안 바꾼다) ·
   기존 PNG 56장 가운데 허용 목록 s71_* 10장 밖의 46장(s73_* · s73b_* · s71b_* · s72g_* · s72_* · s74_*) ·
   기존 lib 파일(lib/src/chart/** · lib/src/widgets/**(perf_chart 포함) · 화면 contribution·drawdown_context·performance_explore·report_archive · screens/explore/**) ·
   기존 테스트(contribution_view · drawdown_context_view · report_archive_view · performance_explore_gate · performance_explore_view · perf_chart_geometry · explore_fakes · ui_analytics_test) ·
   R11a 가 만든 것(lib/planner.dart · lib/src/planner/** · R11a 의 테스트·가짜(planner_* · deposit_planner_* — R11a 병합본의 이름 그대로) · test/golden/s74_golden_test.dart · goldens/s74_*.png).
   🔴 기존 PNG 46장은 하나라도 M 이면 되돌리고 멈춤 · 예외 없음.
   공용 파일 3개는 **더하기만** 한다 — 기존 줄은 한 글자도 바꾸지 않는다(정적 묶음 S27 의 삭제 수 0 이 증명):
     lib/l10n/labels.dart = 끝 절(R11a 병합본의 마지막 절 뒤)에 이 카드의 절 하나 ·
     lib/src/providers/analytics_providers.dart = 끝(R10b 절 뒤)에 이 카드의 절 하나 ·
     lib/ui_analytics.dart = export 한 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
   monthly_report_screen.dart 와 monthly_report_view_test.dart 는 **부록 커밋에서만** 고친다(아래 «부록» — 허용 diff 가 정해져 있다).
 2 03 본문의 구 초안(§14 「데이터」·「컴포넌트」·「상태」·「금지」 ④·「수용」·「모의」 줄과 그림 M7-25)은 03 §14 의 R11 범위 블록(머리글 «🆕 계약 v1.4 — `S7-9` R11 범위»)과 01 §14 에 집니다.
   구 초안 이름(contributionAssumptionText · PathPointVm · «두 필드를 동시에 그리지 않는다»)을 코드에 쓰지 않는다 — v1.4 는 역할 고정 · 셋 다 그린다.
   또 01 §14 머리의 «🟡 로컬 빌드 · 미푸시»와 12 §3 의 «R11-Bob-S74 1장» 흔적은 병합 전의 글이다 — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(GoalPathScreen 의 생성자에는 key·yyyyMm 뿐).
   이 카드가 여는 링크는 DTO 문자열 둘뿐이다: BlockFlag.clearDeepLink(차단 배너 — SafetyBlockBanner 가 onOpenLink 로 넘긴다) · MonthlyReport.goalDeepLink(부록 버튼).
   이 카드가 새로 쓰는 AppRoutes 상수는 0 개다(AppRoutes.reportGoalPath 도 쓰지 않는다 — 링크는 엔진이 완성해서 준다). S7-1 의 기존 AppRoutes.reportArchive 줄은 그대로 둔다.
 4 값 = DTO 의 *Text·*Label·label 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(double·int·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값으로 색을 고르지 않음 · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20 은 주석 줄도 센다(작은따옴표 뒤 같은 줄에 한글이 있으면 1건 · 기대 0건).
 5 읽지 않는 필드(카드가 정함 — 질문 아님): PerfPoint.value · date · gapReasonCode / PerfSegment.from · to / GoalPathVm.yyyyMm 은 Key 에만(🔴 표시 금지) /
   MonthlyReport 는 부록에서 goalDeepLink 하나만 새로 읽는다(goalLine·disclosureViewCountText 는 이미 그리는 것).
   🔴 PerfPoint.value 는 C-36 ⑦·C-39 ⑨ 가 빌드를 깬다 — S7-9 파일(lib/src/screens/goal_path_screen.dart · lib/src/goal_path/**)에 «.value»(괄호가 바로 오는 Future.value( 와 valueOrNull 은 통과)나
      PerfPoint(:value) 패턴 분해가 있으면 실패. 그 파일들에서는 MapEntry 의 .value 도 · AsyncValue 의 .value 도 쓰지 않는다(when(…)·valueOrNull 로).
   🔴 C-39 ⑨ 가드 — GoalPathVm · goalPath · goalPathProvider 라는 낱말(주석 말고)은 S7-9 파일과 analytics_providers.dart 에만 둔다.
      부록의 monthly_report_screen.dart 에도 쓰지 않는다(그 파일이 읽는 것은 report.goalDeepLink · AnalyticsLabels.goalPathDetailButton — 이 둘은 가드에 걸리지 않는다).
   🔴 S7-9 파일(goal_path_screen.dart · lib/src/goal_path/**)에는 **주석에도** ConfigRepository · configRepository · planner 라는 낱말을 쓰지 않는다
      (정적 S14 와 T79-12 가 주석도 센다 — 주석을 빼고 보는 계약 C-39 와 다르다 · 위 두 🔴 문장을 주석으로 옮겨 적지 않는다).
 6 화면 산술 0 — 차트 산술(«엔진이 준 0.0~1.0 정규값 × 폭·높이»)은 옮긴 본보기 2파일 안에 이미 있다. planned·actual 을 합치거나 차액·달성률·비율을 계산하지 않는다 ·
   정규값이나 value 를 글자로(toStringAsFixed·NumberFormat — C-36 ⑧) · 결측 보간·직전 값 유지·0 대입 · 점·행 수를 글자로 — 전부 금지. 목록을 거르지도 세지도 정렬하지도 묶지도 않는다
   (값 표·캡션은 받은 순서 · 순번은 목록 안의 자리 i · 예외 하나 = 띠 캡션 7e 의 kind != SegmentKind.measured 조건 — 계약이 정한 부재 규칙이다).
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에서 열거형 switch 는 옮긴 painter 의 SegmentKind 뿐이다. 캡션의 kind 비교는 if (seg.kind != SegmentKind.measured) 하나다(switch 아님).
   🔴 CommandState 0 · rejectReasonCode 0(이 카드에는 명령이 없다).
 8 시계 = analyticsClockProvider(DateTime.now() 금지) — 쓰는 자리는 StaleBanner 하나다(위젯이 안에서 읽는다).
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(goalPathProvider(widget.yyyyMm)), lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ·
   오래됨 = StaleBanner(asOf: vm.asOf) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다 — 숫자 가림은 엔진 읽기 경로 몫).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(값이 온 뒤에만 — R10a 아카이브와 같다 · R10c 탐색 본문의 «차단 배너 예외»는 이 화면에 없다).
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지 — 🔴 S7-9 파일의 주석에도 이 세 낱말을 쓰지 않는다 · 정적 S26 이 주석도 센다 ·
   report_archive_screen.dart 의 클래스 주석 «Scaffold·AppBar 는 셸 소유»를 본뜨지 않는다 — 드라이런에서 이 한 줄로 S26 이 깨졌다) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible(값 표의 값 칸 SizedBox 104 는 예외 · 적힌 대로 짓는다) ·
   엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지(차트 눈금 글자만 예외 — 본보기 그대로) · 390px overflow 0 ·
   엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(정적 글자 = 가정 머리 1 · 값 표 날짜 열 머리 1 · 버튼 글자 — 아래 «정적 라벨»).
10 프로바이더는 goalPathProvider 하나만 더한다(analytics_providers.dart 끝 · 아래 «주입 구조») · 나머지는 이름·타입 그대로 재사용 ·
   오프너는 탭 콜백 안에서 ref.read — build 에서 read 금지. 🔴 goalPathProvider 는 autoDispose 다 — 기존 3개(비-autoDispose family)를 본뜨지 않는다.
   🔴 주석에 autoDispose 라는 낱말을 쓰지 않는다(정적 S15 가 주석도 센다).
11 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처 행에서) · 링크는 RecordingLinkOpener 를 픽스처 값과 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'T79-03 deviation line only when present').
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다 ·
   스켈레톤 1 = expect(find.byType(AnalyticsSkeleton), findsOneWidget) — 스피너 부재로 대신하지 않는다 ·
   테스트는 package:ui_analytics/src/widgets/analytics_error_view.dart · analytics_skeleton.dart 를 직접 import 한다(배럴이 export 하지 않는다 — T79-08a·08b 의 find.byType · tester.widget 에 필요 · 드라이런 실측) ·
   if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 ⓡ = 정상 상태 테스트마다 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 를 **한 줄에 하나**(여러 픽스처를 도는 테스트는 루프 안에 한 줄) ·
      ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 전제 한 줄. 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄이어야 한다(접히면 루프를 얕게) —
      정적 묶음 S29·S30 이 git grep -c 로 파일별 개수를 센다 — 🔴 아래 최소 목록의 ⓡ·ⓗ 표시 수와 **정확히** 같아야 한다
      (goal_path_view_test.dart ⓡ 13 · ⓗ 8 / monthly_report_view_test.dart ⓡ 3 · ⓗ 1 · 다르면 제출 전에 테스트를 고친다 · PR 본문의 까닭 한 줄로 갈음하지 못한다 · 다른 채 내면 반려).
   목록 단언은 대상 목록 → hasLength 전제(ⓗ) → for 로 전부 단언.
   🔴 ⓗ(hasLength)를 두는 곳은 아래 최소 목록에 ⓗ 로 표시한 자리뿐이다(뷰 8 · 부록 1). 그 밖의 루프 — T79-02·T79-04 의 사슬 Finder 목록 · T79-08a·08b 의 플래그 루프 ·
      T79-10 의 Text 루프 · 픽스처·경우 목록 — 에는 hasLength( 를 쓰지 않는다(쓰면 S30 이 기대 8 과 달라진다 — 제출 전에 고친다 · 다른 채 내면 반려).
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기)와 firstWhere 다. 양쪽에 expect 가 있는 if/else(T79-02 · T79-03 · T79-13 · T79-15 에 카드가 «양쪽 다»라 적은 곳)는 허용한다.
      T79-02 의 사슬 목록을 만드는 collection-if(«있는 것만 넣는다»)는 «없는 쪽은 따로 단언»과 짝일 때만 허용한다.
12 차트의 증명 = test/golden/chart_probe.dart 의 expectGoalPathMatches 하나(M2 소유 · 기대값은 픽스처에서 하네스가 계산한다) ·
   recordChart·chartSchemeOf 에는 key: kGoalPathChartProbeKey(= Key('s79-chart')) · 차트 단언을 직접 짜지 않는다 · 판정 유보(hold)에서는 recordChart 를 부르지 않는다 · 골든은 보조.
13 골든 = 새 PNG 8장(s79_*) + 부록의 s71_* 재생성(허용 목록 10장) · --update-goldens 는 테스트 파일 하나씩 지정(폴더 지정 금지 — s79_golden_test.dart · 부록 커밋에서 s71_golden_test.dart) ·
   golden:approved 는 안 붙임(통합 담당) · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이).
14 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)) · directives_ordering 린트(import·export 는 가나다가 아니라 경로 알파벳 순).
15 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: ratio · aspectRatio · devicePixelRatio · duration · durationSec · iteration · decoration · syntax. 글자 잇기는 보간 '${a}${b}'.
16 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
17 정적 묶음은 git grep 이라 **주석도 센다**(C-38·C-39 는 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄
   (goal_path_screen.dart · analytics_providers.dart 의 R11b 절 · labels.dart 의 R11b 절 · 부록의 monthly_report_screen.dart 줄)의 주석에 이 낱말을 쓰지 않는다:
   AppRoutes · analyticsLinkOpenerProvider · CommandState · Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · GestureDetector · Colors ·
   replaceAll · replaceFirst · rejectReasonCode · seriesCode · GoalPathPoint · DateRange · .value · s71-goal-link · autoDispose · Scaffold · AppBar · SafeArea · ConfigRepository · planner
   (카드 문장을 가드 주석으로 옮겨 적지 않는다 · 옮긴 본보기 2파일은 글자 그대로 둔다 — 이 목록은 Bob 이 쓰는 주석에만).
   🔴 goal_path_screen.dart 는 analytics_providers.dart 를 show 없이 import 한다 — S05a 에는 SafetyBlockBanner onOpenLink 1줄만 나와야 한다(import 줄·주석 줄이 찍히면 위반 ·
      그 줄에 «— 탭 콜백 안» 을 적으면 거짓 보고 = 반려). 부록의 monthly_report_screen.dart 는 import 를 더하지 않는다(이미 show 없이 import 돼 있다) — S05b = 기존 4줄 + 부록 버튼 1줄.
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10a·R10b·R10c 교훈 · 발주자 결정 5(2026-09-30) — R11 에도 적용) —
   🔴 «보고와 코드·파일·PNG 가 1건이라도 다르면 재량 없이 반려»입니다(R10b 부터 적용 · R10b·R10c 모두 이 규칙으로 반려됐습니다).
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모).
   🔴 정적 묶음 S05a·S05b 의 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만 적습니다 — 괄호·위젯 이름·매개변수 이름·설명 금지.
      정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ 와 완전히 같아야 합니다 · <파일> = git grep 출력의 경로 그대로(예 lib/src/screens/monthly_report_screen.dart:92 — 탭 콜백 안).
      금지 예(R10c 2회차 반려 사유 · 코드에 없는 이름을 괄호에 적었다): «…:103 — 탭 콜백 안 (SafetyBlockBanner onTap)».
   🔴 테스트 보강 줄(ⓡ·ⓗ)의 개수는 정적 묶음 S29·S30 의 git grep -c 출력으로 대조합니다(R10c 2회차 — 보강 대상 21곳 중 1곳이 빠졌다).
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M7.md 155~169행 12항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 ·
   항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다 — R10a 는 12항을 전부 자기 말로 바꿔 1·2·3·11항의 원문 검사가 빠졌습니다).
   ③ 은 코드를 위에서 아래로 읽으며 나오는 위젯·Key 이름 나열로만 씁니다(«순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지 — R10c 1회차 반려 사유).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 19항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 11~12행 «의존 … 추가하려면 먼저 질문» → 추가 없음(차트는 본보기 복사 · pubspec 불변)
 ② 13~14행 «라우트 상수로 딥링크» → DTO 링크(BlockFlag.clearDeepLink · MonthlyReport.goalDeepLink)를 AppLinkOpener.open 에 · 새로 쓰는 AppRoutes 상수 0(규칙 3)
 ③ 15~17행 DateTime.now() 금지 → 그대로 · 주입 시계를 읽는 자리는 StaleBanner 하나
 ④ 21~22행 «산술 입력은 0.0~1.0 정규값» → 그대로 유효(그래서 PerfPoint.value 를 읽지 않는다 · 차트 산술은 옮긴 본보기 안에만)
 ⑤ 47·68행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ⑥ 49~55행 수치·금액 리터럴 금지 → 그대로 유효 · 실제 강제 = 계약 테스트 C-38 ⑫(CI · ui_analytics/lib 전체 · labels.dart·주석 포함) + 정적 S21~S23 ·
    54~55행 «같은 값을 네 자리(… M7 목표 경로 …)가 그리지만» → v1.4 에서 셋이다 — S7-9 는 설정값을 읽지 않는다(아래 ⑱)
 ⑦ 89행 «자체 점검 10항» · 154행 «명세 §12와 1:1» → 155~169행 12항(이 카드 밖의 4·5·6·8 · 10 앞절 · 12 앞 두 절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑧ 89~90행 스크린샷 4장 → 서술 + 골든 표(«제출» ③)
 ⑨ 88~89행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅)
 ⑩ 94~95행 «픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조» → 그대로 유효 · 예외 하나 = 부록의 s71_* 재생성(화면이 바뀐다 — 값 열 정렬 · 목표 경로 버튼은 844 골든 밖이라 PNG 에 없다 ·
    허용 목록 10장 · golden:approved 는 통합 담당) · 그 밖의 기존 PNG 46장은 예외 없음
 ⑪ 98~101행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 이 화면의 타입은 코드에 확정(GoalPathVm v1.4)
 ⑫ 102~108행 역할 문단 · «반응형으로 넓히십시오» · 108행 범위 치환값 → 범위 = 이 카드의 S7-9 + 부록 · 폰 세로 하나 · 치환값은 R11 두 장을 함께 적은 것이다(0단계 확인 줄)
 ⑬ 109~115행 «읽을 문서 5개» → 아래 «먼저 읽을 것»
 ⑭ 116~117행 브랜치 형식 · PR 제목 치환값 → ui/m7-s79-goal-path · PR 제목은 «■ 제출» 이 정한다
 ⑮ 132~134행 플래너(«즉시 vs 다음 리밸런싱 대기» · 게이트 핸드오프) → 이 카드 범위 밖(R11a · 01 §8 미결 66·68)
 ⑯ 135~136행 «목표 금액 경로 판정은 월간 리포트 시점에 한 줄만 · 상시 노출하지 않음» → 그대로 유효 — 진입점 = S7-1 goalLine 바로 아래 «목표 경로 보기» 버튼 하나
    (goalDeepLink 가 null 이면 부재) · 다른 진입점·달성률 게이지 0
 ⑰ 137~141행 «세후 수익률은 사다리 · 연간 리뷰(S7-7)와 목표 경로(S7-9)에서 네 층» → 🔴 S7-9 에는 세후 사다리가 없다 — 정직 기대는 인용 문장 한 줄씩
    (honestExpectationText · honestExpectationWorstText · 01 §14-10 «정직 기대 인용 예외») · 층 타입·steps 를 찾지 않는다
 ⑱ 142~144행 가정 카드 두 줄(«시작 2,000만원 + 월 9만원» · «월 납입은 M9 설정값이며 기본 100,000원») → 두 줄 = backtestBasisText · startingCapitalAssumptionText 엔진 문장 그대로 ·
    🔴 S7-9 는 ConfigRepository 를 읽지 않는다 · 괄호 안 숫자는 서술일 뿐 — 옮겨 적으면 C-38 ⑫ 가 CI 를 깬다
 ⑲ 151~153행 값을 두면 안 되는 미결(주 경계 · 인출 가능 금액 비율 · X2 갭 임계값 · 모의 체험 리포트) → 이 카드에 해당 없음(인출 = R11c)
 (118~121행 S7-2 3종 → 12항 4번 괄호 «이 카드 범위 밖» · 145~150행 S7-10·회차 딥링크 → 이 카드에 없음)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문(머리 4행 «🔵 정정 표식» 포함)
 ② 01 §14-9 · §14-10(필드 → 자리 표 · C-4 결정 뒤집기 · 정직 기대 인용 예외 · ConfigRepository 금지) · §14-11(차트) · §14-19(이 카드) — 참고로 §13-2(차트 세 식 · 층 표)
 ③ 03 §14 의 R11 범위 블록 — 머리글 «🆕 계약 v1.4 — `S7-9` R11 범위»(찾는 말 = «S7-9` R11 범위(» · 「모의」 줄 바로 아래 · 그림 M7-25 앞 — 그림과 위쪽 본문은 «구 초안»이라 블록이 이긴다)
 ④ packages/domain_contracts/lib/ — src/dto/performance.dart 의 GoalPathVm · PerfPoint · PerfAxisTick · PerfSegment · MonthlyReport(goalLine · disclosureViewCountText · goalDeepLink) ·
    src/repositories/performance_repository.dart(goalPath) · src/navigation/app_links.dart(reportGoalPath — 읽기만 · 쓰지 않는다) ·
    testing.dart(UnimplementedPerformanceRepository — goalPath 는 동기로 던진다 · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R11(계약 v1.4)» 절 전부 + «🆕 R10» 절의 «2»(위치 전제)·«3»(하네스)·«4»(본보기 옮기는 법) + «규칙»·«하네스» 절
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 ·
    lib/src/screens/report_archive_screen.dart(로딩·에러·배너 뼈대의 선례 — 틀만) · lib/src/screens/explore/performance_explore_body.dart(x 끝 글자·범례·값 표의 선례 — 틀만) ·
    lib/src/screens/monthly_report_screen.dart(부록) · lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · stale_banner.dart · safety_block_banner.dart ·
    test/explore_fakes.dart(FakeSafetyRepository — import 만) · test/monthly_report_view_test.dart(부록 — 끝에 더하기만) · test/golden/golden_support.dart · test/golden/s71_golden_test.dart(루프 모양) ·
    test/golden/reference/goal_path/ 의 두 파일(옮길 코드) · test/golden/goal_path_probe_test.dart 머리(하네스를 부르는 모양)
 ⑦ packages/domain_contracts/fixtures/README.md 의 «계약 v1.4» 절 + 이 카드가 쓰는 픽스처(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · S7-9_questions.md 머리말 · S7-1_questions.md 의 A13 행

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → 목표 경로 화면은 AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton — R10a · 이미 main)
 · analytics_providers.dart 의 비-autoDispose family 3개 → goalPathProvider 는 autoDispose
 · 테스트의 class … implements SafetyRepository(monthly_report_view_test · s71_golden_test 의 _FakeSafetyRepository) · 한국어 테스트 이름(monthly_report_view_test 의 기존 테스트) ·
   «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · 띄우기 도우미(pumpGoalPath) · ASCII 이름
   (부록 TA 는 예외 — 아래 «부록» ②: 그 파일의 기존 가짜를 그대로 쓰고, 기존 테스트처럼 testWidgets 안에 ProviderScope 를 직접 쓴다)
 · report_archive_screen.dart 의 클래스 주석(«Scaffold·AppBar 는 셸 소유 …») → S7-9 파일 주석에 Scaffold·AppBar·SafeArea·ConfigRepository·planner 낱말 0(정적 S14·S26 · T79-12 가 주석도 센다)
 · 03 §14 위쪽 구 초안의 이름·규칙(contributionAssumptionText · PathPointVm · «두 필드를 동시에 그리지 않는다» · C-18 ui_planner) → 코드의 v1.4 이름 · 역할 고정
 · 차트 = CustomPaint(의존 3개 고정) — 새로 짜지 않고 본보기를 옮긴다
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s79-… · 부록은 s71-…)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsSkeleton() · AnalyticsErrorView(onRetry:, lastAsOfLabel:) ·
  AnalyticsLabels.retryButton · staleBannerTitle · valuesHideButton(R10c 의 «값 접기» — 값 표를 편 뒤의 버튼 글자로 재사용).
· 🆕 프로바이더 하나 — lib/src/providers/analytics_providers.dart 끝(R10b 절의 performanceSeriesProvider 뒤)에 이 모양으로 더한다(기존 줄 무변경):
    // ── 🆕 R11b — S7-9 ──
    /// S7-9 목표 경로 — 받은 달 그대로(01 §14-9)
    final AutoDisposeFutureProviderFamily<GoalPathVm, String> goalPathProvider =
        FutureProvider.autoDispose.family<GoalPathVm, String>((ref, yyyyMm) {
          return ref.watch(performanceRepositoryProvider).goalPath(yyyyMm: yyyyMm);
        });
  🔴 열쇠 = 받은 달 문자열 그대로(달을 고르거나 바꾸지 않는다) · 주석에 autoDispose 낱말 금지 · dart format 이 줄을 나눠도 된다(autoDispose 가 든 줄이 하나면 된다).
· 🆕 lib 파일 3개(이 셋 말고 새 lib 파일을 만들지 않는다 — 화면 본문·값 표·범례는 goal_path_screen.dart 안의 private 위젯·메서드로):
    lib/src/screens/goal_path_screen.dart            GoalPathScreen({super.key, required this.yyyyMm}) — 공개 · ConsumerStatefulWidget(State 에 bool _valuesOpen 하나)
    lib/src/goal_path/goal_path_chart.dart           본보기 글자 그대로(GoalPathChart({super.key, required this.path}) · 상수 plotInsetLeft = 64)
    lib/src/goal_path/goal_path_chart_painter.dart   본보기 글자 그대로
· 배럴 lib/ui_analytics.dart 에 export 'src/screens/goal_path_screen.dart'; 한 줄 —
  🔴 자리 = export 'src/screens/drawdown_context_screen.dart'; 줄과 export 'src/screens/monthly_report_screen.dart'; 줄 **사이**(끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패).
  🔴 lib/src/goal_path/ 는 export 하지 않는다(G13 · T79-14). 테스트는 package:ui_analytics/src/… 로 직접 import.
· 이 카드는 R11a 의 lib/planner.dart · lib/src/planner/** 를 import 하지도 고치지도 않는다(C-35 ⑥ 확장 — planner 밖 파일이 planner 를 import 하면 계약 테스트 실패).

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / fixtureEnvelope)
 목표 경로  singleFixture(FixturePaths.m7M7GoalPathOn, GoalPathVm.fromJson) · m7M7GoalPathOff · m7M7GoalPathHold · m7M7GoalPathRealworld
            (모양 — 테스트는 이 표를 믿지 말고 hasLength 전제로 다시 확인한다:
             on·off = planned·actual 8점 · actual 결측 0 · 띠 0 · 눈금 4 / off 만 deviationText 있음 /
             hold = chartUnavailableLabel 있음 + planned·actual·yTicks·segments 빈 목록 + periodLabel 있음 · deviationText 없음 /
             realworld = 8점 · actual 결측 2점(자리 3·4 — valueText 는 엔진 글자) · 띠 1(UNAVAILABLE) · 눈금 4 · deviationText 없음 · 네 픽스처 모두 yyyyMm 이 같다)
 부록(월간)  m7M7Monthly202608 · m7M7MonthlyGap(goalDeepLink 있음) / m7M7MonthlyMaskedIntegrity · m7M7MonthlyMaskedRecon · m7M7MonthlyPending(goalDeepLink 없음)
 안전        SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상(플래그 0) · 3 차단 2건(RECON_MISMATCH · JOURNAL_MISSING) · 4 무결성(LEDGER_INTEGRITY · clearDeepLink 1)
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다. 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 — S7-9 GoalPathScreen (01 §14-10 «필드 → 자리» 표 · 03 §14 블록 ⓑ~ⓕ)
 build:
   final AsyncValue<GoalPathVm> asyncValue = ref.watch(goalPathProvider(widget.yyyyMm));
   final List<BlockFlag> activeFlags = ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ?? const <BlockFlag>[];
   asyncValue.when(
     loading: () => ListView(padding: 16, children: [ AnalyticsSkeleton() ]),                                     ← 배너 없음
     error:   (error, stack) => ListView(padding: 16, children: [ AnalyticsErrorView(onRetry: …invalidate…, lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ]),   ← 배너 없음
     data:    (vm) => 아래 배치)
 배치(값이 온 뒤 · 위 → 아래):
   Column(key: ValueKey<String>('s79-${vm.yyyyMm}'))[                              ← 루트 Key(yyyyMm 은 Key 에만 · 표시 금지)
    1 StaleBanner(asOf: vm.asOf)                                                  ← 스크롤 밖
    2 SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (link) { ref.read(analyticsLinkOpenerProvider).open(link); })   ← 스크롤 밖
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    3 Text(vm.asOf.label)                                          Key s79-asof
    4 Text(vm.judgementText)                                       Key s79-judgement
    5 Text(vm.basisText)                                           Key s79-basis          ← 판정 근거 줄(역할 고정 · 늘 그린다)
    6 (vm.deviationText != null) Text(vm.deviationText!)           Key s79-deviation      ← null 이면 부재(빈 Text 금지)
    7a Text(vm.periodLabel)                                        Key s79-period         ← 🔴 판정 유보여도 그린다
    ── 7b~7f: vm.chartUnavailableLabel == null 일 때만 ──
    7b GoalPathChart(path: vm)                                     안쪽 CustomPaint Key s79-chart · 눈금 글자 s79-tick-<순번>(본보기가 이미 단다)
    7c x 양 끝 글자 — Padding(left: GoalPathChart.plotInsetLeft) 안 Row(spaceBetween)[ Flexible(Text(vm.actual.first.dateText)) , Flexible(Text(vm.actual.last.dateText)) ]
                                                                   Key s79-x-first · s79-x-last(그 Text 에 단다 · 숫자 64 를 적지 않고 상수를 쓴다)
    7d 범례 두 줄(실제 → 계획) — Row[ 견본 , 빈칸 8 , Expanded(Text(vm.actualLabel)) ] · Row[ 견본 , 빈칸 8 , Expanded(Text(vm.plannedLabel)) ]
                                                                   Key s79-legend-actual · s79-legend-planned(그 Text 에)
        견본은 색 상자다(painter·산술 없음 · Container·Colors 없이) — 실제 = SizedBox(width: 24, height: 3, child: ColoredBox(color: colorScheme.primary)) ·
        계획 = Row[ 상자 , 빈칸 4 , 상자 , 빈칸 4 , 상자 ] · 상자 = SizedBox(width: 6, height: 2, child: ColoredBox(color: colorScheme.tertiary))
    7e 띠 캡션 — kind != SegmentKind.measured 인 구간마다 Text(seg.label)   Key s79-segment-caption-<순번>
        <순번> = vm.segments 안의 자리(0 부터 · 측정 구간의 번호는 비어 있다 — 캡션을 따로 세지 않는다)
    7f 값 표 — TextButton(글자 = _valuesOpen ? AnalyticsLabels.valuesHideButton : AnalyticsLabels.goalPathValuesButton)   Key s79-values-toggle
        + (_valuesOpen) Column   Key s79-values-table
            머리 줄 Row   Key s79-values-header = [ Expanded(Text(AnalyticsLabels.goalPathColumnDate)) , 값 칸(vm.plannedLabel) , 값 칸(vm.actualLabel) ]
            점마다 1줄 Row   Key s79-value-row-<i>(i = 0 … planned 의 끝 · 받은 순서) = [ Expanded(Text(vm.planned[i].dateText)) , 값 칸(vm.planned[i].valueText) , 값 칸(vm.actual[i].valueText) ]
            값 칸 = SizedBox(width: 104, child: Text(…, textAlign: TextAlign.end)) · 결측 점(actual 의 yNormalized == null)도 행이 있다(글자 = 엔진의 valueText 그대로) ·
            값 표 글자는 기본 크기(14) 이하 · 기본 접힘 · 누를 때마다 setState(() => _valuesOpen = !_valuesOpen)
        planned 와 actual 은 같은 길이다(C-39 ② — 계약이 보장한다 · 화면이 확인·맞추기를 하지 않는다).
    7b' (vm.chartUnavailableLabel != null) 판정 유보 카드 — Card(Padding 16 · Text(vm.chartUnavailableLabel!))   Key s79-unavailable(그 Text 에) — 7b~7f 는 전부 부재
    8~10 가정 카드 — Card(Padding 12 · Column[
         8 Text(AnalyticsLabels.goalPathAssumptionHeader)            Key s79-assumption-header
         9 Text(vm.backtestBasisText)                                Key s79-backtest-basis     ← 가정 카드 1줄 «백테스트 기준 실행»
        10 Text(vm.startingCapitalAssumptionText)                    Key s79-starting-capital   ← 가정 카드 2줄 «당신의 현재 원금·납입»(ConfigRepository 아님)
       ])
   11 Text(vm.honestExpectationText)                               Key s79-honest             ← 정직 기대 인용 문장(사다리 아님)
   12 Text(vm.honestExpectationWorstText)                          Key s79-honest-worst
   13 Text(vm.disclaimerText)                                      Key s79-disclaimer         ← 맨 아래(골든 위치 전제의 기준)
   ]
 🔴 상태를 고르는 것은 chartUnavailableLabel(null 여부) · deviationText(null 여부) · _valuesOpen 셋뿐이다. planned.isEmpty·actual 의 결측 여부로 상태를 고르지 않는다.
 🔴 판정 문구·근거·이탈·가정·정직 기대·고지는 전부 엔진 문장 그대로 — 화면이 짓거나 고르지 않는다(«유지/이탈» 같은 정적 라벨 금지).
 간격(SizedBox 높이)·글자 굵기·Card 모서리는 재량(질문 아님).

■ Key 표 (카드 확정 — 이 글자 그대로 · 🔴 여기 없는 s79- Key 를 더하지 않는다)
   루트          ValueKey<String>('s79-${vm.yyyyMm}')   값이 온 뒤의 Column
   기준일        Key('s79-asof')                        Text(vm.asOf.label)
   판정          Key('s79-judgement')                   Text(vm.judgementText)
   판정 근거     Key('s79-basis')                       Text(vm.basisText)
   이탈          Key('s79-deviation')                   Text(vm.deviationText!) — 있을 때만
   기간          Key('s79-period')                      Text(vm.periodLabel)
   차트          Key('s79-chart') · ValueKey<String>('s79-tick-$i')   본보기가 단다(쓰지 않고 옮기기만)
   판정 유보     Key('s79-unavailable')                 Text(vm.chartUnavailableLabel!) — 있을 때만
   x 양 끝       Key('s79-x-first') · Key('s79-x-last')
   범례          Key('s79-legend-actual') · Key('s79-legend-planned')
   띠 캡션       ValueKey<String>('s79-segment-caption-$i')
   값 표         Key('s79-values-toggle') · Key('s79-values-table') · Key('s79-values-header') · ValueKey<String>('s79-value-row-$i')
   가정          Key('s79-assumption-header') · Key('s79-backtest-basis') · Key('s79-starting-capital')
   정직 기대     Key('s79-honest') · Key('s79-honest-worst')
   고지          Key('s79-disclaimer')
   부록(S7-1)    Key('s71-goal-link')                   TextButton(«목표 경로 보기»)

■ 차트 — 본보기 2파일을 글자 그대로 옮긴다 (golden README R10 «4» 표의 🆕 v1.4 두 행 · R11 «3»)
  packages/ui_analytics 에서:
    mkdir -p lib/src/goal_path
    cp test/golden/reference/goal_path/goal_path_chart_painter.dart lib/src/goal_path/
    cp test/golden/reference/goal_path/goal_path_chart.dart         lib/src/goal_path/
    git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path   ← «… changed» 요약 줄(예 «1 file changed» · «2 files changed»)이 없어야 한다(차이 0 · 종료 코드·EXIT 값은 보지 않는다)
    («warning: in the working copy of … LF will be replaced by CRLF» 줄은 차이가 아니다 — 무시한다)
    (🔴 diff -r 을 쓰지 않는다 — PowerShell 에서 diff 는 다른 명령이라 파일이 같아도 차이가 찍힌다 · mkdir·cp 가 안 되는 셸이면 편집기로 복사)
  painter 의 import '../chart/perf_chart_geometry.dart'; 는 lib 쪽 R10c 파일(lib/src/chart/perf_chart_geometry.dart)로 그대로 풀린다 — 고치지 않는다.
  🔴 옮긴 파일을 고치지 않는다(이름·색·굵기·층 순서·여백·Key — 하네스와 맞물린 계약이다). 고치고 싶으면 질문 파일에. 본보기 원본은 지우지 않는다.
  R10 차트 3파일(lib/src/chart/ · lib/src/widgets/perf_chart.dart)도 고치지 않는다(정적 S17·S18 이 계속 본다).
  차트 상자 = GoalPathChart(path: vm) 하나. 바깥 여백은 ListView 의 padding 이 준다(차트 안쪽·위아래에 여백을 더하지 않는다 — 위아래 12 는 본보기 안에 이미 있다).

■ 부록 — 마지막 별도 커밋 (01 §8 미결 63 · 03 §14 블록 ⓖ · 이 커밋 밖에서 이 두 파일을 고치지 않는다)
 ① lib/src/screens/monthly_report_screen.dart — 허용 diff 는 셋뿐(그 밖의 줄 — 글자·Colors.grey·ElevatedButton 옛 모양 포함 — 은 고치지 않는다 · format:fix 가 바꾼 줄 말고):
    ⓐ A13 값 열 오른쪽 정렬 — 항목 카드의 Row(지금 231행 `child: Row(` · 그 안 첫 줄이 crossAxisAlignment.start)에 한 줄:
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
       (Expanded 제목 · SizedBox 8 · Flexible 값 열 — 이 셋은 그대로. 남는 폭이 값 열 앞으로 가서 값의 오른쪽 끝이 카드 안쪽 오른쪽 끝에 붙는다)
    ⓑ `_buildFooter` 에 WidgetRef ref 인자 — 선언 `Widget _buildFooter(BuildContext context, WidgetRef ref, MonthlyReport report)` + 호출부(지금 103행) `_buildFooter(context, ref, report),`
    ⓒ 버튼 — `_buildFooter` 의 Text(report.goalLine, …)(지금 315~318행) **바로 아래** · const Divider(height: 16)(지금 319행) **위**에:
         if (report.goalDeepLink != null)
           TextButton(
             key: const Key('s71-goal-link'),
             onPressed: () {
               ref.read(analyticsLinkOpenerProvider).open(report.goalDeepLink!);
             },
             child: const Text(AnalyticsLabels.goalPathDetailButton),
           ),
       🔴 goalDeepLink == null 이면 **부재**(자리표시자·비활성 버튼 없음) · 링크를 해석·조립하지 않는다 · 버튼 글자에 달·금액을 붙이지 않는다.
 ② test/monthly_report_view_test.dart — **끝에 더하기만**(void main() 의 마지막 `}` 앞에 TA-1~TA-3 · 기존 줄 diff 0 · 새 import 0).
    이 파일의 기존 가짜 _FakePerformanceRepository · _FakeSafetyRepository 를 그대로 쓴다(새 가짜 금지 — 🔵 _FakeSafetyRepository 는 implements 라 «본받지 않는 것»이지만 이 파일은 끝에 더하기만이라 고치지 않는다) ·
    띄우는 모양도 이 파일의 기존 테스트와 같다(390×4000 · DPR 1.0 · teardown 2 · FixedClock(kGoldenNowUtc) · RecordingLinkOpener · safety 행 0 · pumpAndSettle).
    🔴 TA 는 이 파일 기존 테스트처럼 testWidgets 안에 ProviderScope(오버라이드 4개)를 직접 쓴다 — «새 띄우기 도우미는 pumpGoalPath 하나뿐 · ProviderScope 통째 금지»의 예외는 TA 뿐이다 ·
       이 파일에 도우미(private 함수 포함)를 더하지 않는다 · pumpGoalPath 는 GoalPathScreen 전용이라 TA 에 쓰지 않는다.
    경우가 여럿인 TA-2·TA-3 도 for 로 testWidgets 를 경우마다 만든다(아래 «테스트 최소 목록» 공통 줄 — 드라이런: TA-1 1 · TA-2 2 · TA-3 3 = 6개).
    🔴 TA 테스트 이름은 ASCII(기존 테스트의 한국어 이름을 본뜨지 않는다) · TA 줄에 한국어 리터럴 0(정적 S01b·S02c 가 본다).
 ③ packages/ui_analytics 에서:
      flutter test --update-goldens test/golden/s71_golden_test.dart   ← 🔴 그 파일 하나만(폴더·다른 골든 파일 지정 금지 · s71_golden_test.dart 자체는 한 줄도 안 고친다)
      flutter test                                                     ← 옵션 없이 전부 통과
    git status --short 에서 바뀐 PNG 는 test/golden/goldens/s71_*.png 뿐이어야 한다(허용 목록 10장 이하 — 화면에서 정렬이 바뀌지 않은 장은 M 이 아닐 수 있다 · 안 바뀌면 그대로).
    드라이런 실측: M = 6장(s71_normal · s71_partial_gap · s71_masked_recon × light/dark) · s71_masked_integrity · s71_not_generated 는 불변(값이 이미 반 폭을 채우거나 항목이 없다) ·
    «목표 경로 보기» 버튼은 s71 골든(844 높이)의 화면 밖(footer)이라 어느 PNG 에도 보이지 않는다 — PNG 가 바뀐 까닭은 값 열 정렬 하나 · 버튼의 증명은 TA-2·TA-3 이다
    (차이가 나면 PR 본문에 까닭).
    🔴 그 밖의 PNG(s73_* · s73b_* · s71b_* · s72g_* · s72_* · s74_* · s79_*)가 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로.
 ④ 부록에서 생긴 질문은 inbox/S7-1_questions.md 표 끝(A13 행 다음)에 Q5·A14 부터(없으면 안 고친다) · 🔴 A13 행은 고치지 않는다(통합 담당이 병합 때 닫는다).

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R11b (1) 정적 라벨») · 테스트는 그 단계 커밋에 함께
 (1) 정적 라벨 4개(기존 화면·위젯 무변경 — 0단계의 시작 기준 N 이 그대로 통과).
 (2) 본보기 2파일 옮기기(lib/src/goal_path/ · 차이 0).
 (3) goalPathProvider(analytics_providers.dart 끝) + GoalPathScreen(lib/src/screens/goal_path_screen.dart) + 배럴 export 한 줄(정렬 자리) +
     test/goal_path_fakes.dart(가짜·띄우기 도우미) + test/goal_path_view_test.dart(T79-01~T79-15).
     🔴 이 커밋 전에 packages/ui_analytics 에서 «정적 묶음» 37줄을 한 번 미리 돌려 본다 — 🔴 git grep 은 add 하지 않은 새 파일을 보지 않는다(출력 없음 = 거짓 안심) →
        먼저 git add . (packages/ui_analytics 안에서 · 커밋은 그다음)로 올린 뒤 돌린다: S04 = 옛 reportArchive 1줄뿐 · S05a = 1줄 · S13 = 옛 4파일뿐 · S15 = 4줄 ·
        S06~S12·S14·S20·S24·S25·S26 = 출력 없음(주석도 센다 — 규칙 17). (6) 뒤에는 커밋을 더할 수 없으니(amend·rebase 금지) 여기서 고친다.
 (4) 골든 8장 — test/golden/s79_golden_test.dart.
 (5) format:fix · 질문 파일(S7-9_questions.md — 골든 dy 측정 행 A1~A4 · 그 밖의 질문) · 커밋.
 (6) 🔴 부록 — **마지막 별도 커밋** «[M7] R11b (6) 부록 — S7-1 목표 경로 버튼·값 열 정렬(미결 63)»: 위 «부록» ①②③(④ 있으면) → melos.bat run format:fix → 커밋.
     🔴 (6) 뒤에 다른 커밋을 더하지 않는다(format 수정도 (6) 커밋 안에 — 제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지).

■ 정적 라벨 — AnalyticsLabels 끝에(R11a 병합본의 마지막 절 뒤) 절 주석(// ── 🆕 R11b — S7-9 ──)과 함께 4개(이름·글자 고정):
   goalPathDetailButton = '목표 경로 보기' · goalPathAssumptionHeader = '가정' · goalPathValuesButton = '숫자로 보기' · goalPathColumnDate = '날짜'
   (retryButton · staleBannerTitle · valuesHideButton 은 이미 있다 — 고치지 않는다. R11a 의 라벨 절도 고치지 않는다.)
   🔴 만들지 않는 글자(엔진 몫): «유지» · «이탈» · «판정 유보» · «계획 경로» · «실제 평가액» · «백테스트 기준 실행» · «당신의 현재 원금·납입» · «보증하지 않습니다» · 금액·% · 달 이름.
   🔴 라벨 글자에 숫자·금액을 넣지 않는다(C-38 ⑫ 가 labels.dart 도 본다). 더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S29·S30 과 대조)
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 픽스처는 golden_support.dart 의 singleFixture/fixtureEnvelope 로만 읽는다 ·
  값 단언 전 pump() 한 번 더(Future·안전 스트림이 도착할 틈 — 드라이런 확인: 없어도 34/34 통과 · 넣어도 해 없음(안전 여유)).
  🔴 경우가 여럿인 테스트(«…마다» · «루프로» — T79-02·03·05·06·07·09·10·11·13·15 · 부록 TA-2·TA-3)는 for 로 testWidgets 를 경우마다 만든다
     (이름 = '<번호> <설명> <경우 이름>' · 예 'T79-03 deviation line only when present off' · ⓡ·ⓗ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 같다).
     pumpGoalPath 는 한 테스트에서 한 번만 부른다(한 테스트 안에서 픽스처를 바꿔 다시 띄우지 않는다 — State(_valuesOpen)·프로바이더 값이 남는다).
     드라이런 = 뷰 34개(T79-01 1 · 02 3 · 03 4 · 04 1 · 05 3 · 06 3 · 07 2 · 08a 1 · 08b 1 · 09 3 · 10 2 · 11 2 · 12 1 · 13 3 · 14 1 · 15 3).
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순 — 드라이런 goal_path_view_test.dart 의 실제 순서):
     import 'dart:async'; → import 'dart:io'; →
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
     import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/src/widgets/analytics_error_view.dart'; →
     import 'package:ui_analytics/src/widgets/analytics_skeleton.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
     import 'goal_path_fakes.dart'; → import 'golden/chart_probe.dart'; → import 'golden/golden_support.dart';(goal_ 이 golden 보다 앞 · error_view 가 skeleton 앞)
     (드라이런에서 상대 경로 순서를 바꿔 analyze --fatal-infos 가 한 번 실패했다).
  🆕 test/goal_path_fakes.dart(새 파일 · 공개 이름 · 🔴 한국어 리터럴 0 · explore_fakes.dart 는 import 만):
    import 'explore_fakes.dart' show FakeSafetyRepository;   (FakeSafetyRepository(SafetyState state) — 위치 인자 하나 · R10b · 고치지 않는다)
    class FakeGoalPathRepository extends UnimplementedPerformanceRepository {
      FakeGoalPathRepository({GoalPathVm? vm, Object? error, Completer<GoalPathVm>? completer})   ← 셋 중 정확히 하나를 준다(테스트가 정한다)
      final List<String> goalPathCalls = <String>[];   ← 받은 yyyyMm 을 호출마다 더한다
      goalPath({required String yyyyMm}) = 기록 → completer 가 있으면 completer.future / error 가 있으면 Future<GoalPathVm>.error(error) / 아니면 Future<GoalPathVm>.value(vm!)
    }   (completer 는 로딩을 멈추는 한 테스트에서만 — 그 테스트는 한 번만 부른다)
    List<Override> goalPathOverrides({required FakeGoalPathRepository repo, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 4개(analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider(FakeSafetyRepository(…)))
        · 기본값: 안전 = safetyStates 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 오프너 = 새 RecordingLinkOpener(링크를 단언하려면 opener: 로 넘긴다)
    Future<void> pumpGoalPath(WidgetTester tester, {required FakeGoalPathRepository repo, required String yyyyMm, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 390×2400 · DPR 1.0 · teardown 2 · ProviderScope(overrides: goalPathOverrides(…)) → MaterialApp(home: Scaffold(body: GoalPathScreen(yyyyMm: yyyyMm))) · 끝에 pump() 1번
    골든은 pumpGoalPath 를 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: goalPathOverrides(repo: …), child: GoalPathScreen(yyyyMm: vm.yyyyMm)), brightness: b, logicalSize: kS79GoldenSize).
  🔴 새 띄우기 도우미는 이 하나뿐(pumpGoalPath) · 테스트마다 ProviderScope 를 통째로 쓰지 않는다 · yyyyMm 은 픽스처의 vm.yyyyMm 을 넘긴다(리터럴 금지).
목표 경로 — test/goal_path_view_test.dart
 T79-01 on → goalPathCalls == <String>[on.yyyyMm](ⓗ hasLength(1) 전제) · 루트 Key ValueKey<String>('s79-${on.yyyyMm}') 1 · find.text(on.yyyyMm) 0 · ⓡ.
 T79-02 배치 사슬 — 세 경우(on · 정상 시계 · 안전 행 0) · (off · +3일 · 행 4) · (realworld · 정상 · 행 3)마다:
        위 → 아래 Finder 목록을 만들고(있는 것만 넣는다) 이웃끼리 tester.getTopLeft(…).dy 를 lessThan 으로 잇는다(각 Finder 는 findsOneWidget 도):
        [오래됐으면 find.text(AnalyticsLabels.staleBannerTitle)] → [플래그가 있으면 find.text(activeFlags.first.label)] → s79-asof → s79-judgement → s79-basis →
        [deviationText 가 있으면 s79-deviation] → s79-period → s79-chart → s79-x-first → s79-legend-actual → s79-legend-planned →
        [측정 아닌 구간마다 s79-segment-caption-<i>] → s79-values-toggle → s79-assumption-header → s79-backtest-basis → s79-starting-capital →
        s79-honest → s79-honest-worst → s79-disclaimer.
        없는 쪽은 따로 단언한다(if/else 양쪽 — staleBannerTitle 0 · find.byIcon(Icons.block) 0 · s79-deviation 0 · s79-segment-caption-0 0). 세 경우가 양쪽을 한 번 이상씩 지난다. ⓡ.
 T79-03 네 픽스처마다 deviationText 가 있으면 그 글자 1 · s79-deviation 1 / 없으면 s79-deviation 0(양쪽 다 단언) · ⓡ.
 T79-04 hold → s79-unavailable 1(그 Text 의 data == chartUnavailableLabel) · find.byKey(kGoalPathChartProbeKey) 0 · s79-tick-0 0 · s79-x-first 0 · s79-legend-actual 0 · s79-legend-planned 0 ·
        s79-values-toggle 0 · s79-period 1 · 사슬 s79-asof → s79-judgement → s79-basis → s79-period → s79-unavailable → s79-assumption-header → … → s79-disclaimer · ⓡ.
        🔴 T79-04 에서는 recordChart 를 부르지 않는다.
 T79-05 on·off·realworld 마다 ⓗ expect(vm.yTicks, hasLength(4)) → i 마다 ValueKey<String>('s79-tick-$i') 의 Text data == yTicks[i].label ·
        그 글자의 오른쪽 끝 ≤ 차트(s79-chart)의 왼쪽 변(tester.getRect) · 그 다음 번호 s79-tick-4 0 · ⓡ.
 T79-06 on·off·realworld 마다 s79-x-first 의 Text data == actual.first.dateText · s79-x-last == actual.last.dateText ·
        tester.getTopLeft(s79-x-first).dx == tester.getRect(s79-chart).left(x 글자 줄의 왼쪽 = 그림의 왼쪽 변) · ⓡ.
 T79-07 on·realworld 마다 ⓗ expect(vm.planned, hasLength(8)) · 전제 expect(vm.actual.any((p) => p.yNormalized == null), <on 이면 isFalse / realworld 이면 isTrue>) →
        처음: s79-value-row-0 0 · find.text(AnalyticsLabels.goalPathValuesButton) 1 → s79-values-toggle 탭 →
        머리 줄 안 Text 글자 목록 == [AnalyticsLabels.goalPathColumnDate, vm.plannedLabel, vm.actualLabel] ·
        i 마다 행 안 Text 글자 목록(tester.widgetList<Text>(find.descendant(of: 행 Key, matching: find.byType(Text))).map((t) => t.data).toList()) ==
        [planned[i].dateText, planned[i].valueText, actual[i].valueText](순서까지 · 결측 행 포함 · 🔴 find.text 로 세지 않는다 — 첫 행은 두 값의 글자가 같다) ·
        s79-value-row-8 0 · 버튼 글자 = valuesHideButton → 다시 탭 → s79-value-row-0 0 · ⓡ.
 T79-08a 로딩 — completer 가짜 · 안전 행 3 → AnalyticsSkeleton 1 · find.byType(CircularProgressIndicator) 0 · find.byType(LinearProgressIndicator) 0(R10a 선례) · s79-judgement 0 ·
        그 플래그 label 글자 각 0(🔴 로딩에는 배너 없음 — 규칙 8) · ⓡ.
 T79-08b 에러 — error 가짜 · 안전 행 3 → retryButton 1 · tester.widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView)).lastAsOfLabel == null ·
        그 플래그 label 글자 각 0 · s79-judgement 0 → retryButton 탭 → pump → ⓗ expect(repo.goalPathCalls, hasLength(2)) · 두 기록 모두 on.yyyyMm.
 T79-09 on·off·realworld 마다 expectGoalPathMatches(recordChart(tester, key: kGoalPathChartProbeKey), vm, chartSchemeOf(tester, key: kGoalPathChartProbeKey))   ← 주 증명 · ⓡ.
 T79-10 on·realworld 마다 값 표를 편 채로(s79-values-toggle 탭 → pump → 전제 expect(find.byKey(const Key('s79-values-table')), findsOneWidget)): 화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있다 —
        집합 = vm 의 문자열 필드(asOf.label · judgementText · basisText · deviationText(있으면) · periodLabel · plannedLabel · actualLabel · backtestBasisText ·
        startingCapitalAssumptionText · honestExpectationText · honestExpectationWorstText · disclaimerText) + yTicks 의 label + planned·actual 의 dateText·valueText +
        segments 의 label + AnalyticsLabels.goalPathAssumptionHeader · goalPathValuesButton · valuesHideButton · goalPathColumnDate
        (화면이 지은 글자 = 0 · 수용 (d) «가정 카드 위젯트리에 수익률·낙폭·금액 리터럴 0» · 정적 S22·S23 과 짝) · ⓡ.
 T79-11 on — 시계 두 경우(kGoldenNowUtc · +3일)를 루프로: 오래됐으면 find.text(AnalyticsLabels.staleBannerTitle) 1 / 아니면 0(양쪽 다) · ⓡ(루프 안 한 줄).
 T79-12 파일 검사 — File('lib/src/screens/goal_path_screen.dart') + Directory('lib/src/goal_path') 의 .dart 파일(ⓗ 합쳐 hasLength(3)) 어느 것에도
        RegExp('[Cc]onfigRepository|planner') 가 없다(🔴 S7-9 는 ConfigRepository 를 읽지 않는다 · 플래너를 import 하지 않는다).
 T79-13 on·off·realworld 마다 ⓗ expect(vm.segments, hasLength(<on 0 · off 0 · realworld 1>)) → i 마다 kind != measured 면 ValueKey<String>('s79-segment-caption-$i') 1 · 그 Text data == seg.label /
        measured 면 그 Key 0(양쪽 다) · 끝 다음 번호 s79-segment-caption-<길이> 0 · ⓡ.
 T79-14 배럴 — File('lib/ui_analytics.dart') 의 export 경로 목록(RegExp(r"^export '([^']+)';", multiLine: true)) ⓗ hasLength(8) · 집합이 정확히
        { l10n/labels.dart · src/providers/analytics_providers.dart · src/screens/contribution_screen.dart · src/screens/drawdown_context_screen.dart ·
          src/screens/goal_path_screen.dart · src/screens/monthly_report_screen.dart · src/screens/performance_explore_screen.dart · src/screens/report_archive_screen.dart }
        (🔵 «정확히 N» 은 이 카드에서 이 테스트 하나다 — G13(performance_explore_gate_test)은 고치지 않는다).
 T79-15 on — 안전 행 0·3·4 마다(경우마다 testWidgets): ⓗ expect(activeFlags, hasLength(<0 · 2 · 1>)) → 플래그마다 그 label 글자 1 ·
        find.byIcon(Icons.block) — 플래그 0 이면 findsNothing / 있으면 findsNWidgets(<행 3 = 2 · 행 4 = 1>)(양쪽 다 · 드라이런 실측) ·
        탭 — 행 4 만 find.byIcon(Icons.chevron_right) 탭 → pump → opener.opened == <String>[행 4 의 activeFlags.single.clearDeepLink!] /
        행 0·3 은 탭하지 않고 expect(opener.opened, isEmpty)(양쪽 다) · ⓡ.
 (T79 에 없는 번호는 없다 — 01~15 · 08 만 a·b 두 개.)
 ⓡ 기대 = goal_path_view_test.dart 13줄(T79-01·02·03·04·05·06·07·08a·09·10·11·13·15) · ⓗ 기대 = 8줄(T79-01·05·07·08b·12·13·14·15) — 드라이런 실측 13 · 8 과 같다 ·
   🔴 정확히 이 수(다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 — 규칙 11).
부록 — test/monthly_report_view_test.dart 끝(TA 이름은 짧은 ASCII — 예 'TA-1 value column right edge' · 'TA-2 goal link opens deep link' · 'TA-3 goal link absent')
 TA-1 m7M7Monthly202608 · 안전 행 0 → ⓗ expect(report.items, hasLength(13)) → 항목마다 tester.getRect(find.text(item.valueText)).right 가
      그 항목 Card 의 오른쪽 끝 − 12 와 같다(closeTo(…, 0.5) · Card = find.ancestor(of: find.text(item.valueText), matching: find.byType(Card)) ·
      12 = 이 파일 기존 항목 Card 의 안쪽 여백 EdgeInsets.all(12.0) — 부록이 바꾸지 않는다) · ⓡ.   ← A13 을 되돌리면 짧은 값에서 실패해야 한다
 TA-2 m7M7Monthly202608 · m7M7MonthlyGap 마다: 전제 expect(report.goalDeepLink, isNotNull) → Key s71-goal-link 1 · 그 안 글자 AnalyticsLabels.goalPathDetailButton 1 ·
      전제 expect(find.byType(Divider), findsOneWidget)(이 화면의 Divider 는 _buildFooter 의 하나뿐 — 3f3c923 실측) →
      사슬 find.text(report.goalLine) 의 dy < s71-goal-link 의 dy < find.byType(Divider) 의 dy < find.text(report.disclosureViewCountText) 의 dy(getTopLeft · lessThan · 이웃끼리 3줄) →
      s71-goal-link 탭 → opener.opened == <String>[report.goalDeepLink!] · ⓡ.
 TA-3 m7M7MonthlyMaskedIntegrity · m7M7MonthlyMaskedRecon · m7M7MonthlyPending 마다: 전제 expect(report.goalDeepLink, isNull) → s71-goal-link 0 · find.text(AnalyticsLabels.goalPathDetailButton) 0 · ⓡ.
 ⓡ 기대 = monthly_report_view_test.dart 3줄 · ⓗ 기대 = 1줄(TA-1) — 이 파일의 기존 줄에는 ⓡ·ⓗ 가 0 이다(3f3c923 실측) · 🔴 정확히 이 수(위와 같다).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 이탈 문장 늘 그리기(null 에 빈 Text) · 판정 유보에서 값 표 버튼·x 글자 그리기 ·
   판정 유보에서 기간 줄 빼기 · 값 표 기본 펼침 · 값 표 열 순서 바꾸기(계획 ↔ 실제) · 값 표에서 결측 행 빼기 · 가정 카드 두 줄 순서 바꾸기 · 판정 근거 줄 빼기(옛 C-4 «동시 금지») ·
   로딩·에러에 차단 배너 그리기 · 에러를 스켈레톤으로 · 로딩에 스피너 · goalPath 에 다른 달 넘기기 · yyyyMm 을 글자로 그리기 · x 글자 줄 여백 0 · 배너 링크를 열지 않기 ·
   화면이 지은 글자 하나(예 정적 «목표 경로») · 부록: 버튼을 Divider 아래로 · goalDeepLink null 에 버튼 그리기 · 버튼이 다른 링크를 열기 · A13 되돌리기.

■ 정적 묶음 — packages/ui_analytics 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 37줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 2>&1 로 모으면 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힐 수 있다 · R11a 드라이런 실측 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05a·S05b 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/goal_path_view_test.dart test/goal_path_fakes.dart test/golden/s79_golden_test.dart; echo "EXIT:$?"
echo "## S01b appendix test hangul lines unchanged (HEAD = origin/main)"; git grep -cP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/monthly_report_view_test.dart; git grep -cP "'[^'\n]*[\x{AC00}-\x{D7A3}]" origin/main -- test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/goal_path_view_test.dart test/golden/s79_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/goal_path_view_test.dart test/golden/s79_golden_test.dart; echo "EXIT:$?"
echo "## S02c appendix test names ASCII"; git grep -nP "testWidgets\('TA-[^']*[^\x00-\x7F]" -- test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S02d appendix tests 3"; git grep -c "testWidgets('TA-" -- test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S03 replaceFirst replaceAll 0"; git grep -nE "replaceFirst|replaceAll" -- lib/src/screens/goal_path_screen.dart lib/src/screens/monthly_report_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes (old reportArchive line only)"; git grep -n "AppRoutes\." -- lib/src/screens/goal_path_screen.dart lib/src/screens/monthly_report_screen.dart; echo "EXIT:$?"
echo "## S05a opener lines goal path (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/goal_path_screen.dart; echo "EXIT:$?"
echo "## S05b opener lines monthly report (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/monthly_report_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 DateRange ConfigRepository 0"; git grep -nE "DateRange|[Cc]onfigRepository" -- lib/src/screens/goal_path_screen.dart lib/src/goal_path; echo "EXIT:$?"
echo "## S15 autoDispose 4"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "goal_path/|chart/|explore/|planner|perf_chart|analytics_skeleton|analytics_error_view" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports 8"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint" -- lib; echo "EXIT:$?"
echo "## S25 value refs 0 (goal path files)"; git grep -nP "\.value\b(?!OrNull)(?!\s*\()|PerfPoint\s*\([^)]*\bvalue\b" -- lib/src/screens/goal_path_screen.dart lib/src/goal_path; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea 0 (goal path files)"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/screens/goal_path_screen.dart lib/src/goal_path; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/src/screens/monthly_report_screen.dart lib/ui_analytics.dart test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S28 goal link key 1"; git grep -n "s71-goal-link" -- lib; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/goal_path_view_test.dart test/monthly_report_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/goal_path_view_test.dart test/monthly_report_view_test.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S01b = 두 수가 같다(부록 TA 줄에 한국어 리터럴 0 · 3f3c923 실측 11 = 11) ·
   S02a·S02b·S02c = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) · S02d = «test/monthly_report_view_test.dart:3» ·
   S03 = 링크는 DTO 문자열 그대로(끼워 조립 금지) · S04 = 기존 S7-1 의 AppRoutes.reportArchive 한 줄뿐(이 카드가 새로 쓰는 상수 0) ·
   S05a = GoalPathScreen 의 SafetyBlockBanner(onOpenLink:) 자리 1줄(드라이런 72 — 줄 번호는 코드마다 다르다) ·
   S05b = 기존 4줄(92 · 109 · 179 · 항목 「자세히」 — A13 한 줄 때문에 284 → 285) + 부록 버튼 1줄(드라이런 329) = 5줄(드라이런 92 · 109 · 179 · 285 · 329) ·
   S05a·S05b 모두 build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) ·
   S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0(옮긴 차트 파일의 GoalPathChartColors 는 클래스 이름이라 -w 에 걸리지 않는다) ·
   S15 = 대소문자 구분 · 4줄(기존 3 + goalPathProvider 1) · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = export 8줄(goal_path_screen 은 drawdown_context_screen 과 monthly_report_screen 사이) ·
   S17·S18 = R10 차트 3파일 무변경 · S18b = «차트» 절의 줄(본보기 2파일 차이 0) · S19~S23 = 12항의 1·3·11항 근거(S22·S23 = 11항 보강 — 계약 테스트 C-38 ⑫ 와 같은 정규식 ·
   S19 는 R10c 와 달리 허용 밖 import 줄만 찍는다 — 출력 0 이 정상) ·
   S24 = 폐기·금지 이름 0 · S25 = C-36 ⑦·C-39 ⑨ 와 같은 .value 두 정규식 · S26 = 공개 위젯은 본문만 ·
   S27 = 공용 파일의 «더하기만» — labels.dart · analytics_providers.dart · ui_analytics.dart · monthly_report_view_test.dart 의 둘째 수(삭제)가 0 · monthly_report_screen.dart 만 부록 허용 diff(드라이런 «17 2» — 삭제 2 = _buildFooter 선언·호출 두 줄 · 더한 수는 format 에 따라 다를 수 있다 · 드라이런 전체 = 6/0 · 8/0 · 17/2 · 1/0 · 146/0 — monthly_report_view_test 의 146 은 이 판의 TA-2 Divider 보강 전 수라 몇 줄 늘어난다 · 기준은 둘째 수 · 차이가 나면 PR 본문에 까닭) ·
   S28 = 부록 버튼 Key 1줄 · S29·S30 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 파일마다 정확히 같아야 한다(13·3 / 8·1 · 다르면 반려 — 규칙 11))

■ 골든 — 4이름 × light/dark = 8장(전부 신규 · golden README «🆕 R11» 절 표의 R11b 행 그대로) + 부록 재생성
  s79_on_track(m7/m7_goal_path_on.json) · s79_off_track(m7/m7_goal_path_off.json) · s79_hold(m7/m7_goal_path_hold.json) · s79_realworld(m7/m7_goal_path_realworld.json)
  모두 띄운다(게이트 없음) · 값 표는 접힌 채 · 안전 상태 = 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 크기 390 × 900(테스트 파일 안 상수 kS79GoldenSize = Size(390, 900) —
  기본 폰 높이 844 로는 모자란다 · 드라이런 실측 s79-disclaimer 아래 끝 = on 803 · off 847 · hold 562 · realworld 827(light·dark 같음) · 차이가 나면 PR 본문에 까닭).
  모양 = s71_golden_test.dart 처럼 (이름, 픽스처 경로) 목록 × Brightness.values 루프 · 테스트 이름 '$name ${brightnessSuffix(b)}' · 골든은 '../goal_path_fakes.dart' 로 import.
  pumpForGolden 뒤 pump() 한 번 더(값이 오게 — 드라이런 확인: 없어도 통과 · 넣어도 해 없음(안전 여유)) → 찍기 전 위치 전제(golden README «R10» 절 «2. 높이와 위치 전제» · «🆕 R11» 절 «1» 의 dart 줄) — 한 곳:
    expect(tester.getBottomLeft(find.byKey(const Key('s79-disclaimer'))).dy, lessThan(kS79GoldenSize.height));   ← 맨 아래 = 고지(판정 유보도 같다)
  → await expectGolden(name, b);
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s79_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 8장만 ??
  🔴 다른 골든 테스트 파일을 --update-goldens 에 넣지 않는다(s71_golden_test.dart 는 부록 커밋에서 따로 · 그 밖은 영영 아님).
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s79_golden_test.dart 의 위치 전제 lessThan(kS79GoldenSize.height) 한 곳을 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/s79_golden_test.dart(--update-goldens 없이)
    → 테스트 이름('s79_on_track light' … 8개)마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- test/golden/s79_golden_test.dart 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).
  부록 재생성 = 위 «부록» ③(s71_golden_test.dart 하나 · 허용 목록 s71_* 10장 · 위치 전제 없음 — 그 테스트 파일은 고치지 않는다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다)
· S7-9_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 차트 질문도 여기에. 부록 질문만 S7-1_questions.md(Q5·A14 부터 · A13 행은 고치지 않는다).
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A4 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  권고와 다르게 지은 이름 · 4개 밖에 새로 더한 정적 라벨 · 본보기 차트에 고치고 싶은 점 · 문서에 없어 정한 것 전부.
    | A1 | R11b-Bob-S79 | 추측 | 측정: s79_on_track dy 실측값 (light=<값>, dark=<값> < 900) | 골든 위치 전제 실측 | 900 미만 확인 | ⬜ 미답 | |
    (A2 = s79_off_track · A3 = s79_hold · A4 = s79_realworld · 같은 형식 · 900 = kS79GoldenSize 의 높이 · <값> 자리에만 잰 숫자)
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 4개 · 읽지 않는 필드 목록(규칙 5) · 값 표 기본 접힘 · 값 칸 폭 104 ·
  배치 순서 · 골든 이름·입력 · 본보기 2파일을 그대로 옮긴 것 · 부록 허용 diff 셋 · 재량인 것(여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(6) 커밋이 끝난 뒤 — (6) 부록이 마지막 커밋)
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 수정은 CI 포맷 게이트를 빨갛게 만든다
  git diff --name-status origin/main...HEAD
     ← test/golden/goldens/ 에서: 새 PNG = s79_*.png 8장(A) · M = s71_*.png 만(10장 이하 · 부록) · 그 밖의 PNG(s73_* · s73b_* · s71b_* · s72g_* · s72_* · s74_*) 줄 = 금지 ·
        test/golden/chart_probe*.dart · goal_path_probe_test.dart · reference/** · README.md · 기존 골든 테스트(s71_golden_test.dart 포함) 줄 = 금지 ·
        R11a 파일 · R10 파일 · 기존 화면(monthly_report_screen.dart 말고) · 기존 테스트(monthly_report_view_test.dart 말고) 줄 = 금지 · domain_contracts/** 줄 = 금지
        (하나라도 있으면 푸시하지 말고 멈춘 뒤 출력을 채팅으로)
  git push -u origin ui/m7-s79-goal-path
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  cd packages/ui_analytics → 위 «정적 묶음» 37줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다(golden:approved 포함). PR 제목: [M7] S7-9 목표 경로 + S7-1 진입 버튼·값 열 정렬(부록)
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(S7-9 — 목표 금액 경로 · 부록 S7-1 — 목표 경로 버튼·값 열 정렬) + 본보기 2파일(정적 묶음 S18b = 차이 0) 한 줄 +
      바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(손으로 쓰지 않음 · A/M · PNG 포함) + 커밋 목록(git log --oneline origin/main..HEAD 출력 그대로 — 부록 (6) 이 맨 위)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 12항이 15줄 그대로인지 셉니다 — 11번·12번은 각각 3줄·2줄(들여쓰기 4칸 줄 포함)이고, 한 줄로 잇지 않습니다(R11a 2회차에 틀린 곳 · 줄을 이으면 = 보고 불일치 = 반려).
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다(R10a · R10b 1회차에 틀린 곳).
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음 결과의 수):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «S7-9 화면 파일 산술 0 · 차트 산술은 옮긴 본보기의 정규값 × 크기뿐(정적 S18b 차이 0)»
        3번 = «정적 묶음 S20 — 0건»
        4번 · 5번 · 6번 · 8번 = «이 카드 범위 밖»
        7번 = «앞절 T79-09 expectGoalPathMatches(realworld 실제선 끊김) / 뒷절 값 표 결측 행 = 엔진 valueText 그대로(T79-07) · 배지 0»
        9번 = «as-of 는 목표 경로 화면에 1줄(s79-asof) · 오래됨 배너 = StaleBanner(T79-11)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 기존 PNG M = 허용 목록 s71_* 만(부록 재생성) · domain_contracts 변경 0»
        11번 = «정적 묶음 S21 결과 <N>건 · 보강 S22 결과 <N>건 · S23 결과 <N>건»
        12번 = «앞 두 절 이 카드 범위 밖(S7-9 에는 세후 사다리가 없다) / 뒷절 가정 카드 두 줄 = s79-backtest-basis · s79-starting-capital(T79-02)»
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
      이어서 «정적 묶음» 출력 전부를 코드 블록 하나로 그대로 + S05a·S05b 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄(괄호 금지 · 줄을 빼거나 줄이면 = 보고 불일치 = 반려)
      + «ⓡ = S29 출력 · ⓗ = S30 출력» 한 줄(숫자는 출력 그대로 — 파일마다)
   ③ 스크린샷 서술 — 로딩·정상·빈(판정 유보)·차단 4줄 + 부록 1줄 + 골든 표 8행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술은 코드의 위젯·Key 이름 나열로만 쓴다 — goal_path_screen.dart 를 위에서 아래로 읽으며 나오는 순서 그대로 «→» 로 잇는다 ·
         조건으로 붙는 것(StaleBanner · SafetyBlockBanner · s79-deviation · s79-segment-caption-<순번> · s79-values-table)은 «(있을 때)» 를 붙인다 ·
         그 순서가 위 «화면» 의 배치 1~13 과 다르면 제출하지 말고 멈춘 뒤 채팅으로(판정 유보 = 1~7a → s79-unavailable → 8~13 과 비교).
         «로딩» = AnalyticsSkeleton(배너 없음) · «정상» = 1~13 의 Key 나열(s79-legend-planned · s79-assumption-header 를 빠뜨리지 않는다) · «빈» = 판정 유보 나열 ·
         «차단» = SafetyBlockBanner 의 자리를 코드 그대로 — «StaleBanner 아래 · Expanded(ListView) 바깥 위(값이 온 뒤의 Column 둘째 자식)» ·
         «부록» = «S7-1 _buildFooter: goalLine Text → s71-goal-link(goalDeepLink 있을 때) → Divider → disclosureViewCountText».
      🔴 «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지(R10c 1회차 반려 사유).
      골든 표 8행: 이름 · 입력 픽스처 · 크기 · 위치 전제 dy · 배치·잘림 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m7/m7_goal_path_on.json — 상수 이름과 섞지 않는다) · 크기 = 390×<높이> ·
        dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다) ·
        배치·잘림 = PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 못 본 것은 «미열람»).
      부록 PNG 는 서술하지 않는다 — ① 의 s71_* M 줄로 갈음한다.
   ④ 질문 표(새 행 번호·요지 — 질문 파일에 쓴 글자와 같게 · S7-9 와 S7-1 을 나눠서)
   ⑤ 추측한 것 = 두 질문 파일(S7-9_questions.md · S7-1_questions.md)의 새 A 행 중 «측정:» 이 아닌 행 전부 — 파일 접두를 붙인 번호로(예 S7-9 A5 · S7-1 A14)
      (없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
   (+ flutter test 한 줄 — «시작 기준 N → 끝 M»(M = packages/ui_analytics 의 flutter test 끝 줄 그대로 · 기대 M = N + 48))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s79-goal-path` 푸시 1건 · 커밋 6개(본문 (1)~(5) + **(6) 부록이 마지막**).
- `lib/` 새 파일 3(`screens/goal_path_screen.dart` · `goal_path/goal_path_chart.dart` · `goal_path/goal_path_chart_painter.dart` — 본보기와 차이 0) · 수정 4(`l10n/labels.dart` 끝 절 4개 · `providers/analytics_providers.dart` 끝 절 `goalPathProvider` · `ui_analytics.dart` export 1줄(정렬 자리) · `screens/monthly_report_screen.dart` 부록 허용 diff 셋). 그 밖의 `lib/`(R10 차트 3파일 · 위젯 · 다른 화면 · R11a `planner.dart`·`src/planner/**`)는 바뀌지 않는 것이 정상.
- `test/` 새 파일 3(`goal_path_view_test.dart` · `goal_path_fakes.dart` · `golden/s79_golden_test.dart`) + 새 PNG 8장(`s79_*`) · 수정 1(`monthly_report_view_test.dart` — 끝에 TA-1~TA-3 · 삭제 0) · M PNG = `s71_*` 만(허용 10장 이하 · 드라이런 실제 6장 = `s71_normal`·`s71_partial_gap`·`s71_masked_recon` × light/dark). 하네스·본보기·`goal_path_probe_test.dart`·다른 골든 테스트·기존 PNG 46장·R11a 테스트는 불변.
- 질문 파일 `S7-9_questions.md`(새 행 A1~A4 «측정:» 은 반드시 · 그 밖은 있을 때만) · `S7-1_questions.md`(부록 질문이 있을 때만 · A13 행 불변).
- 채팅: PR 본문 5섹션(① name-status 출력 그대로 + 커밋 목록 · ② 복사 상자 12항 + 괄호 + «정적 묶음» 37줄 출력 전부 + S05a·S05b 줄 · ③ Key 나열 + 골든 표 8행(dy 는 이름·밝기마다) · ④ · ⑤) + flutter test 통과 수.
- `flutter test` = 시작 기준 N(0단계 · R11a 병합본 실측 256) + 새 48(뷰 34 + 골든 8 + TA 6) = **304** 기대(드라이런 = 235 + 48 = 283 — 드라이런은 비교기 infra PR #20(`comparator_test` +21) 앞이라 N 이 21 작았다 · 최소 목록의 번호가 기준 — 수가 다르면 PR 본문에 까닭 · 적다고 곧 반려는 아님) · 정적 S29 = 13·3 · S30 = 8·1(🔴 정확히 — 다르면 반려).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R11b-Bob-S79 결과: 브랜치 ui/m7-s79-goal-path 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R11b-Bob-S79 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R11b-Bob-S79 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① `s71_*` 밖의 기존 PNG(`s73_*`·`s73b_*`·`s71b_*`·`s72g_*`·`s72_*`·`s74_*`)가 `M` ② `pubspec.yaml` 변경 ③ `test/golden/chart_probe*.dart`·`goal_path_probe_test.dart`·`reference/**`·README 가 `M`, 또는 `lib/src/goal_path/` 가 본보기와 다름 ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now`·`ConfigRepository` ⑤ `value` 를 읽거나 숫자를 글자로 만드는 코드(`toStringAsFixed`) ⑥ 부록 커밋이 마지막이 아님 · `monthly_report_view_test.dart` 에 삭제 줄 · R11a 파일 `M` ⑦ ② 의 S04·S05a·S05b·S13·S28 출력에 주석 줄·import 줄이 찍힘(규칙 17) · ⓡ·ⓗ 수(S29·S30)가 13·3 / 8·1 이 아님 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 `s71_*` 를 **다시 찍으므로** `golden:approved` 라벨 전에는 빨간색이 정상입니다(라벨은 Claude 가 병합 검사에서 허용 목록 `s71_*` 10장 밖 M 0 을 확인한 뒤 붙입니다). 라벨을 붙인 뒤에도 빨간색이면 반려 신호입니다.
- 계약 테스트 C-36 ⑦ · C-39 ⑨(S7-9 파일의 `value` 참조 · `ConfigRepository` · 목표 경로 낱말 가드) · C-35 ⑥(planner 방향)은 Bob 브랜치가 들어와야 실제 파일을 봅니다 — 병합 검사 때 Claude 가 그 위에서 돌립니다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 🔴 **파일 이름 주의** — 같은 R11 의 끝난 카드 `R11a-Bob-S74.md`, M7 의 끝난 카드(`_완료/R10a-Bob-S71b.md`·`_완료/R10b-Bob-S72G*.md`·`_완료/R10c-Bob-S72*.md`·`_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73*.md`), M6 의 끝난 카드 `_완료/R2b-Bob-J3.md` 를 붙여넣지 않습니다.
- 드라이런 실측(누적 · 검사 폴더 `C:/Work/AAQ-claude-review` · 가지 `dry/r11b` 끝 `b896ebb` · 2026-09-30): 커밋 6개(부록 (6) 맨 위) — 새 테스트 48건(뷰 34 · 골든 8 · TA 6 · packages/ui_analytics 283 통과) · domain_contracts 257 통과 · 30 skip · 0 실패 · 맨 아래 위젯(`s79-disclaimer`)의 아래 끝 = on 803 · off 847 · hold 562 · realworld 827(light·dark 같음 · 높이 900) · 재생성 `s71_*` M 6장 · 기존 46장 불변 · 변이 20종 중 19 잡힘(놓친 «버튼을 Divider 아래로»는 TA-2 Divider 사슬로 잡힘을 확인 — 이 판에 반영 · 반영 뒤 20/20 기대) · S05a 1줄(72) · S05b 5줄(92 · 109 · 179 · 285 · 329) · S15 4줄(63 · 78 · 91 · 106) · S27 6/0 · 8/0 · 17/2 · 1/0 · 146/0(TA-2 보강 전) · S29 13·3 · S30 8·1 · format 0 changed · analyze 전 패키지 SUCCESS.
- 드라이런에서 걸린 곳(이 판에 규칙으로 반영): goal_path_screen.dart 머리 주석에 report_archive 선례를 본떠 «Scaffold·AppBar» 를 적어 S26 이 1줄(→ 규칙 9) · 테스트 import 순서 directives_ordering(→ 최소 목록 공통 줄) · 844 높이로 off 가 넘침(→ 900).
- 범위 고지: 핸드북 «기대치의 한계» 연결(01 §8 미결 76) · 목표 금액 입력(미결 80) · 과거 달 경로 재현(06 M1-23 · 엔진이 null 로 둘 수 있다) · 셸 라우터 가드(R13)는 이 카드에 없습니다. S7-5 인출은 R11c(보류 · 미결 79 → 계약 v1.5)입니다.
- 🔵 ⓡ·ⓗ 정책이 R11a 와 다르다(C4 판정 기준) — R11a = 드라이런 실측과 달라도 반려 아님(반려는 «PR 본문의 수 ≠ grep -c 출력»과 표식마다 1줄 미달뿐 · S27 이 호출 수 단언까지 세어 테스트 짜임에 따라 변한다) · R11b = **정확히 13·3 / 8·1**(ⓗ 를 두는 자리를 최소 목록에 못박았고 경우마다 testWidgets 를 for 로 만들어 파일 안 줄 수가 짜임과 무관하다). 병합 검사 보고에 이 차이를 적는다.
- 그 밖의 알릴 것은 `_완료/R10a-Bob-S71b.md` «5» 를 참고합니다.
