# 발송 패킷 R10c-Bob-S72 — 재제출 (1회차 반려 · 2026-09-30)

> 만든 날 2026-09-30 · 1회차(PR #17 · 브랜치 `ui/m7-s72-explore` · 커밋 `9230112`)의 C4 병합 검사 결과가 **반려(재제출)** 여서 만든 패킷입니다(발주자 결정 2026-09-30 = (A) 반려 → 재제출 · [나] 테스트 보강도 함께). 규칙·범위(S7-2 수익률 탐색 본문 + 차트 3파일)는 1회차 카드(`send/_완료/R10c-Bob-S72.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 F1~F7 + 질문 파일 새 행**만 담았습니다.
> 같은 브랜치 `ui/m7-s72-explore` · 같은 PR #17 에 커밋을 더하면 됩니다(새 PR 을 만들지 않습니다). 기대 = **lib 1파일**(`performance_explore_body.dart` — 고지 카드 블록 이동만) · **test 1파일**(`performance_explore_view_test.dart` — E22 새 1개 · V2 두 곳 · 보강 줄) · **PNG 는 `s72_*` 만 다시 찍기**(기존 30장 `s71_*`·`s73_*`·`s73b_*`·`s71b_*`·`s72g_*` 는 M 0) · 질문 파일 새 행 A7~A12(A1~A6 은 그대로) · PR 본문 ③ 다시 쓰기 + ①②④⑤ 새로.
> 판정 근거 = C4 보고 §0(카드 🔴 «보고와 코드·파일·PNG 가 다르면 1건이라도 재량 없이 반려» · 테스트 규칙 11) — [가] 4건: C4c-1 코드(고지 카드 `s72-disclosure` 가 값 보기/값 표 아래) · C4c-2 ③ «정상» «순서대로» 거짓 + `s72-benchmark-note` 누락 · C4c-3 ③ «차단» «리스트뷰 상단» 거짓 · C4c-4 V2 두 곳 조건부 목록. 고칠 것 = C4 보고 §6-0 · §6-A(F6 은 실측값을 뺐다 — Bob 이 재고 C4 가 대조) · [나] = C4c-5~C4c-8(C4c-9 V3 넓히기는 카드 밖 선택이라 넣지 않았다).
> 🔴 **올리는 순서(Claude)** — 이 패킷은 원 패킷 `R10c-Bob-S72.md` 의 `send/_완료/` 이동과 **같은 푸시**로 `main` 에 올린다(Bob 은 «먼저 할 것»의 병합 한 번으로 둘 다 받는다). 0단계의 `ls-tree` 확인 줄이 그 증명이다. 같은 푸시에 `send/README.md` 의 ▶ 줄과 R10c 행도 이 재제출(같은 브랜치 · 같은 PR #17 · 원 패킷 `_완료/`)로 고친다. 🔴 같은 푸시에서 `inbox/S7-2_questions.md` 는 건드리지 않는다(낡은 머리말 «다음 번호 = Q1·A1» 도 — 고치면 Bob 의 «먼저 할 것» 병합에서 A1~A12 행과 충돌할 수 있다 · 머리말은 PR #17 병합 때 통합 담당이 고친다).

## 0. 한 줄 목적

PR #17 의 탐색 본문에서 고지 카드(배치 10)를 카드가 정한 자리(구간 캡션 아래 · 벤치마크 구성 위)로 옮기고, 그 순서를 테스트가 실제로 증명하게 하며(E22 · V2 전제 · 보강 줄), `s72_*` 골든과 PR 본문 ③ 을 고친 코드 그대로 다시 만들기.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m7-s72-explore` · 같은 PR #17.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷과 원 패킷의 `_완료/` 이동을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다. 🔴 1회차를 보낸 대화를 이어 쓰지 않습니다(Bob 은 1회차를 기억하지 못한다는 전제로 본문을 썼습니다).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R10c-Bob-S72-%EC%9E%AC%EC%A0%9C%EC%B6%9C.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r10\docs\ai-context\send\R10c-Bob-S72-재제출.md` · 글자 같음). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 PR 브랜치라 **1회차 카드 `R10c-Bob-S72.md` 만** 있습니다(그것을 보내면 안 됩니다). 보낼지는 GitHub `main` 에 있는지로 판단합니다. (2026-09-30 고침 — 처음 판은 `AAQ-claude` 폴더를 가리켰다)
4. 붙여넣을 것은 아래 «3» 의 본문 **전부**(첫 줄 «R10c-Bob-S72 재제출 요청» ~ «■ 제출» 끝) · 고치지 않습니다. 새 대화라 규칙 요약 · 카드 배치 · 자체 점검 12항 복사 상자 · 정적 22줄 묶음이 본문에 들어 있습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R10c 패킷은 **이것 하나**(`R10c-Bob-S72-재제출.md`)입니다. 원 패킷 `R10c-Bob-S72.md`(꼬리 없음)는 `send/_완료/` 로 옮겼습니다(다시 보내면 Bob 이 새 브랜치를 만들려 합니다). 이름이 비슷한 `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 카드입니다(R10b · PR #16 병합됨 — 보내지 않음).

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R10c-Bob-S72 재제출 요청 — 1회차(PR #17 · 9230112) 판정: 반려(재제출). 같은 브랜치 ui/m7-s72-explore · 같은 PR #17 에 커밋을 더하십시오(새 PR 금지).
이번 반려의 중심은 코드입니다 — 고지 카드(s72-disclosure)가 카드 배치와 다른 자리에 있습니다. 고치는 lib 는 performance_explore_body.dart 한 파일(블록 이동만)입니다.

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R10c 1회차 카드(새 브랜치를 만들던 카드 · 이미 끝남)가 아닙니다. 새 브랜치를 만들지 않습니다(git checkout -b 금지).
ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
이번 대상 = PR #17 · 브랜치 ui/m7-s72-explore(커밋 9230112)에 아래 F1~F7 커밋을 «더하는» 일입니다.
F1~F7 은 아직 브랜치에 없습니다.
🔴 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← ui/m7-s72-explore
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  (다른 브랜치였다면 status 가 빈 것을 본 뒤) git checkout ui/m7-s72-explore
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git log --oneline -1          ← 9230112 [M7] R10c (5) format·질문 파일 · 다르면 멈추고 출력을 채팅으로
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git rev-parse --short origin/ui/m7-s72-explore   ← 9230112 로 시작 · 다르면 멈추고 출력을 채팅으로(PR 브랜치에 다른 커밋이 올라와 있으면 마지막 푸시가 막힌다 — rebase·강제 푸시 금지)
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력)
        docs/ai-context/send/R10c-Bob-S72-재제출.md 줄이 있고, 꼬리 없는 docs/ai-context/send/R10c-Bob-S72.md 줄이 없으면 = 이 패킷이 main 에 있다(올바른 기준).
        그 밖의 줄(README.md · _완료 등)은 상관없습니다. 한글이 깨져 보여도 파일 이름(마지막 / 뒤)이 «R10c-Bob-S72-» 로 시작하는 줄이 있으면 정상.
        «R10c-Bob-S72-재제출» 줄이 없거나 꼬리 없는 «R10c-Bob-S72.md» 가 보이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다.
  (&& 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (1회차 카드 docs/ai-context/send/_완료/R10c-Bob-S72.md 의 규칙 1~16 · 보고 규칙 · 주입 구조 · 화면 배치 · 테스트 최소 목록 · 정적 묶음 · 골든 · 질문 파일 절이 그대로 유효 — 여기엔 핵심만)
· 이번에 고치는 곳 = 아래 네 곳뿐입니다.
    packages/ui_analytics/lib/src/screens/explore/performance_explore_body.dart   (F1 — 고지 카드 블록 이동만)
    packages/ui_analytics/test/performance_explore_view_test.dart                 (F2~F4)
    packages/ui_analytics/test/golden/goldens/s72_*.png                           (F5 — 다시 찍기만)
    docs/ai-context/inbox/S7-2_questions.md                                       (F6 — 새 행 A7~A12 만)
· 🔴 고치면 반려: 위 네 곳 밖의 packages/ui_analytics/** 전부 — lib/l10n/labels.dart · 차트 3파일(lib/src/chart/perf_chart_geometry.dart · perf_chart_painter.dart · lib/src/widgets/perf_chart.dart) ·
  lib/src/providers/analytics_providers.dart · 배럴 lib/ui_analytics.dart · R10a·R10b 파일(report_archive_screen · analytics_skeleton · analytics_error_view · performance_explore_screen · disclosure_gate_view 와 그 테스트) ·
  test/explore_fakes.dart · test/perf_chart_geometry_test.dart · test/golden/s72_golden_test.dart(F6 의 임시 수정은 되돌린다) · test/golden/ 의 하네스·reference/**·README ·
  기존 PNG 30장(s71_* · s73_* · s73b_* · s71b_* · s72g_*) · domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml · test/flutter_test_config.dart.
  🔴 기존 PNG 30장은 하나라도 M 이면 되돌리고 멈춤 · 예외 없음.
· F1 은 «옮기기»입니다 — 고지 카드 안의 글자·Key·안쪽 여백·순서(sampleSizeLine → honestExpectationLine → drawdownCaveatLine)는 한 글자도 바꾸지 않습니다. 다른 배치(0~9 · 11~13)도 그대로입니다.
· 테스트 규칙(1회차 카드 규칙 11 — 글자 그대로):
11 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO·CommandReceipt 를 지어 넣지 않는다(픽스처 행에서 — 예외는 기하 단위 테스트 U2 하나) · 링크는 RecordingLinkOpener 를 픽스처 값·상수와 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'E8 no weekly segment').
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다(R10a A6 은 행 Key 0 을 archiveEmpty.rows 로 적었다) ·
   스켈레톤 1 = expect(find.byType(AnalyticsSkeleton), findsOneWidget)(package:ui_analytics/src/widgets/analytics_skeleton.dart import) — 스피너 부재로 대신하지 않는다 ·
   if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다(R10a A9) ·
   카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다(R10a A8).
  (그 밖 — 테스트 이름에 «—»·«→» 금지 · 테스트에 한국어 리터럴 금지 · 받침대 extends · 픽스처는 golden_support.dart 의 singleFixture/listFixture/fixtureEnvelope 로만 · 새 띄우기 도우미 금지 — 이미 있는 pumpExplore · passGate 를 쓴다.)
· 골든: --update-goldens 는 test/golden/s72_golden_test.dart 한 파일만 지정(폴더 지정 금지 · s71b·s72g 골든 테스트를 넣지 않는다) · golden:approved 라벨 안 붙임.
· 도구: format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
  package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)).
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10a 교훈) — 🔴 이 카드부터 «보고와 코드·파일·PNG 가 다르면 1건이라도 재량 없이 반려»입니다.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모).
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M7.md 154~168행 12항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 · 항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다 —
   R10a 는 12항을 전부 자기 말로 바꿔 1·2·3·11항의 원문 검사가 빠졌습니다).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(PR 본문 ① 한 줄 · 골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.
   → 이번 재제출의 ③ 은 1회차가 이 규칙을 어긴 곳(«순서대로» · «리스트뷰 상단»)을 고치는 일입니다. 같은 결함이 한 번 더 나오면 다시 반려입니다.

■ 잘된 것 — 그대로 유지하십시오
보고를 기계로 만든 곳은 전부 사실이었습니다 — ① name-status 22줄(git diff --name-status 와 글자 같음) · ② 12항 원문 15줄(복사 상자와 15/15 같음 · 괄호 근거 12개 모두 사실) ·
② 정적 22줄 묶음 출력(C4 가 같은 22줄을 돌린 출력과 차이 0) · ③ 골든 표 픽스처 = FixturePaths 경로 그대로 · 크기 390×1400 · dy 12개(C4 재실측 12/12 일치) · ④ = 질문 파일 A1~A6 · ⑤ «없음».
기계 검사 전부 초록 — dart format 0 changed · analyze 13/13 · ui_analytics flutter test 179 통과·0 실패 · domain_contracts 230 통과·30 skip·0 실패 · 경계·라벨 검사 · CI 3/3.
차트 3파일은 본보기와 차이 0 · 기존 PNG 30장 M 0 · 새 PNG 12장은 잘림·넘침·겹침 0 · 카드가 예고한 변이 21개(11종)는 넣어 보니 전부 테스트가 잡았습니다.
배치 0~9 · 11~13 · 로딩·에러·불가 갈래 · 토글 3줄(주 없음) · 값 표(기본 접힘 · 폭 88 · 결측 행 포함) · 이동 버튼 2(탭 콜백 안)는 카드대로입니다.

■ 왜 반려인가 — 카드 / 코드 · 보고 글 / 실제 (C4 검사 갈래 둘 이상이 따로 확인)
① 코드 — 고지 카드 자리 (C4c-1)
   카드:  배치(위 → 아래)는 9 구간 캡션 → 10 고지 카드(s72-disclosure) → 11 벤치마크 구성(s72-benchmark-note) → 12 「값 보기」/값 표(s72-values-toggle) → 13 이동 버튼 2개.
   코드:  9 → 11 → 12 → 10 → 13. 고지 카드 블록(// 10 고지 카드)이 if/else 밖, 값 표 뒤에 있습니다(performance_explore_body.dart 412~431행 · 앞뒤 SizedBox 410·432행).
          값 표를 펴면(점 최대 60행) 고지 카드가 표 밑으로 밀립니다. 세로 순서를 보는 테스트가 없어 골든 10장(불가 2장 제외)에 이 순서가 그대로 굳었습니다.
② PR ③ «정상» (C4c-2)
   보고 글: «… 구간 캡션(s72-segment-caption-*), 고지 카드(s72-disclosure), 값 표 토글(s72-values-toggle), 이동 버튼 2개(…)가 순서대로 배치됨»
   실제:    코드·PNG 순서는 구간 캡션 → 벤치마크 구성 → 「값 보기」 → 고지 카드 → 이동 버튼입니다(«순서대로» 가 거짓) · s72-benchmark-note(배치 11)가 서술에서 빠졌습니다.
③ PR ③ «차단» (C4c-3)
   보고 글: «SafetyBlockBanner 가 기록 줄 바로 아래(리스트뷰 상단)에 위치»
   실제:    SafetyBlockBanner 는 Column 의 둘째 자식으로 Expanded(ListView) 바깥 위입니다(코드는 카드 배치 1 그대로 — 서술만 틀림).
④ 테스트 V2 두 곳 (C4c-4)
   코드:  final checkIndices = <int>[0, if (missingIdx != null) missingIdx, s.points.length - 1];  — 결측 점이 없으면 결측 행 단언이 소리 없이 빠집니다.
   카드:  규칙 11 «전제는 expect(조용한 return·if 건너뛰기 금지)» · «본받지 않는 것» 조건부 단언 · V2 «첫·끝·결측 순번 행마다».
          (지금 픽스처에는 결측이 있어 실제로는 단언됩니다 — 그래도 카드 반려 조건입니다. R10b 에서 같은 부류가 반려 사유였습니다.)
«재량 없이 반려» = 통합 담당(C4 = 병합 검사)이 대신 고쳐 병합하지 않고 되돌려 보낸다는 뜻입니다. 이번에는 코드까지 틀려 더욱 그렇습니다 — 보고만 틀려도 반려입니다.
코드·테스트의 나머지가 좋다는 것은 판정을 바꾸지 않습니다.

카드 배치 원문(1회차 카드 «■ 화면» — 글자 그대로 · F1 과 ③ 의 기준):
  배치(위 → 아래):
    0 기록 줄 Text(_shown.stateLabel)                                   Key s72-record-line     ← 항상 · 상태로 고르지 않는다
    1 SafetyBlockBanner(있을 때)
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    2 토글 3줄 SegmentedButton(showSelectedIcon: false)                 Key s72-toggle-metric · s72-toggle-granularity · s72-toggle-cumulative
        지표 2칸(PerfMetric.twr · mwr) · 주기 3칸(daily · monthly · yearly) · 누적 2칸(true · false)
        🔴 주기에 weekly 칸이 없다.
        누르면 setState(() => _query = (…그 칸만 바꾼 새 레코드…)) — 재요청은 프로바이더 열쇠가 바뀌어 저절로 일어난다.
    3 series = ref.watch(performanceSeriesProvider(_query))
        로딩(첫 요청·재요청) = 토글 아래 AnalyticsSkeleton(blocks: 3) / 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(performanceSeriesProvider(_query)), lastAsOfLabel: null)
        🔴 로딩·에러 때는 0·1·2 와 그 스켈레톤/에러 뷰만 그린다(4~13 없음 — 고지 카드·이동 버튼도 값이 온 뒤에만 · 고지 글자는 시리즈에 실려 온다).
    4 StaleBanner(asOf: series.asOf)
    5 Text(series.asOf.label) · Text(series.periodLabel)                Key s72-asof · s72-period
    6 PerfChart(series: series)                                          안쪽 CustomPaint Key s72-chart · 눈금 글자 s72-tick-<순번>(본보기가 이미 단다)
    7 x 양 끝 글자 — Padding(left: PerfChart.plotInsetLeft) 안 Row(spaceBetween)[ Flexible(Text(points.first.dateText)) , Flexible(Text(points.last.dateText)) ]   Key s72-x-first · s72-x-last
        (왼쪽을 그림의 왼쪽 변에 맞춘다 — 숫자 64 를 적지 않고 상수를 쓴다 · Key s72-x-first·s72-x-last 는 그 Text 에 단다)
    8 범례 — 견본 + Expanded(Text(series.seriesLabel)) / (benchmark != null) 견본 + Expanded(Text(benchmark.label))   Key s72-legend-main · s72-legend-benchmark
        견본은 색 상자다(painter·산술 없음 · Container·Colors 없이) — 본선 = SizedBox(width: 24, height: 3, child: ColoredBox(color: colorScheme.primary)) ·
        벤치마크 = Row[ 상자 , 빈칸 4 , 상자 , 빈칸 4 , 상자 ] · 상자 = SizedBox(width: 6, height: 2, child: ColoredBox(color: colorScheme.tertiary))
    9 구간 캡션 — kind != SegmentKind.measured 인 구간마다 Text(seg.label)                                                Key s72-segment-caption-<순번>
        <순번> = series.segments 안의 자리(0 부터 · 측정 구간의 번호는 비어 있다 — 캡션을 따로 세지 않는다)
   10 고지 카드 — sampleSizeLine · honestExpectationLine · drawdownCaveatLine(있을 때)                                   Key s72-disclosure
   11 (benchmark != null) Text(benchmark.compositionNote)                                                               Key s72-benchmark-note
   12 「값 보기」/「값 접기」 TextButton + (펴졌을 때) 값 표                                                               Key s72-values-toggle · s72-values-table · 행 s72-value-row-<순번>
        표 = 머리 1줄(첫 칸은 글자 없는 Expanded · AnalyticsLabels.valuesColumnMain · benchmark != null 이면 valuesColumnBenchmark) + 점마다 1줄(받은 순서 · Column — 점은 많아야 60개)
        행 = Row[ Expanded(Text(point.dateText)) , 값 칸 , (benchmark != null) 값 칸 ] — 값 칸 = SizedBox(width: 88, child: Text(…valueText, textAlign: TextAlign.end))(두 값이 붙지 않게) ·
        머리 줄도 같은 칸 폭 · 결측 점도 행이 있다(엔진 글자) · 값 표 글자는 기본 크기(14) 이하로(칸 폭 88 은 6자에 맞춰져 있다)
        토글을 바꿔도 _valuesOpen 은 그대로다.
   13 이동 버튼 2개(세로로 쌓는다 · 각 전체 폭) — OutlinedButton 「낙폭 맥락 보기」 = open(AppRoutes.performanceDrawdown) · 「슬리브 기여 보기」 = open(AppRoutes.performanceContribution)   Key s72-link-drawdown · s72-link-contribution
  불가(series.unavailableLabel != null): 6·7·8·9·11·12 를 그리지 않고 그 자리에 불가 카드 Text(unavailableLabel)(Key s72-unavailable) — 0~5·10·13 은 그린다.
    🔴 points.isEmpty·every(null) 로 상태를 고르지 않는다 — 고르는 것은 unavailableLabel 하나다.
  구간 캡션의 kind 비교(9)는 if (seg.kind != SegmentKind.measured) 하나다(switch 아님 · 글자는 seg.label 그대로).

■ 먼저 할 것
  git fetch origin && git merge --no-edit origin/main
     ← 이 패킷과 원 패킷의 _완료/ 이동을 받습니다. 병합 커밋이 하나 생기는 것은 정상입니다(&& 가 안 되는 셸이면 두 줄로).
        충돌이 나면 아무것도 고치지 말고 멈춘 뒤 git status 출력을 채팅으로.
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.3 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: 179 통과 · 0 실패(1회차 그대로). 다르면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
  읽을 것(읽기만 — 그 카드의 0단계·브랜치 만들기·푸시 -u 는 하지 않습니다):
   · docs/ai-context/send/_완료/R10c-Bob-S72.md — «■ 규칙 요약» 11 · «■ 화면» 배치 · «■ 테스트 최소 목록» · «■ 정적 묶음» · «■ 골든» · «■ 질문 파일» · «■ 제출» ②③
   · docs/ai-context/prompt_M7.md 154~168행(자체 점검 12항 원문 — 아래 «■ 제출» ② 상자와 같은 글자)

■ 고칠 것 — F1~F7 (1회차 반려 · C4 2026-09-30) — 같은 브랜치 ui/m7-s72-explore 에 커밋을 더해 푸시합니다(rebase·강제 푸시 금지).
   (F1 = 코드 · F2·F3 = 테스트(반려 사유) · F4 = 테스트 보강(발주자 결정으로 이번에 함께) · F5·F6 = 골든·질문 파일 · F7 = PR 본문 ③)
   행 번호는 9230112 의 것입니다(병합 뒤에도 이 두 파일은 main 에서 바뀌지 않으므로 같습니다).

F1 (코드 · lib/src/screens/explore/performance_explore_body.dart) 고지 카드를 카드 배치 10 의 자리로 옮깁니다.
   지금: 410행 const SizedBox(height: 16), + 412~431행 «// 10 고지 카드» Card(key: const Key('s72-disclosure'), …) 가 if/else(226~409행) 밖, 값 표 뒤에 있습니다.
   ① 그 Card 를 data 갈래 첫머리(215행 final unavailableLabel = series.unavailableLabel; 다음 줄)에서 지역 변수로 뽑습니다 — 예:
        // 10 고지 카드
        final Widget disclosureCard = Card(key: const Key('s72-disclosure'), child: …지금의 Padding(12)·Column 그대로…);
      (이름은 재량 · 안쪽 글자·Key·여백·순서 그대로)
      🔴 규칙 15 의 C-4 이름 함정(amount·price·pnl·commission·tax·cash·pct·ratio·cagr)이 드는 이름은 쓰지 않는다.
   ② 불가 갈래(226~228행 if (unavailableLabel != null) ...<Widget>[ … ]): Text(unavailableLabel, key: const Key('s72-unavailable')), 다음에
        const SizedBox(height: 16),
        disclosureCard,
   ③ 정상 갈래(else): 9 구간 캡션 for(318~327행) 바로 뒤 · 11 «if (benchmark != null) … s72-benchmark-note»(329~336행) 앞에
        const SizedBox(height: 16),
        disclosureCard,
   ④ if/else 밖의 옛 블록 — 410행 const SizedBox(height: 16), 과 412~431행 «// 10 고지 카드» Card(…) — 를 지웁니다.
      432행 const SizedBox(height: 16), 와 13 이동 버튼 2개(434~457행)는 그대로 둡니다.
   → 결과(위 → 아래): 정상 = … 8 범례 → 9 구간 캡션 → 10 고지 카드 → 11 벤치마크 구성(있을 때) → 12 「값 보기」/값 표 → 13 이동 버튼 2개
                      불가 = … 5 s72-asof · s72-period → s72-unavailable → 10 고지 카드 → 13 이동 버튼 2개(0~5·10·13 — 카드 «불가» 줄 그대로)
   🔴 옮긴 뒤 정적 묶음 S05 의 줄 번호 중 1회차 :440 · :451 은 바뀝니다(:103 은 옮긴 블록보다 위라 그대로일 수 있습니다) — ② 에는 새로 돌린 출력의 번호를 그대로 적습니다(1회차 번호를 옮겨 적지 않습니다).
   (권함: F2 의 E22 를 F1 보다 먼저 쓰고 9230112 코드에서 돌려 E22 가 실패하는 것을 한 번 본 뒤 F1 을 하면, E22 가 이 결함을 잡는다는 것이 확인됩니다.)

F2 (테스트 · 새 E22 — 세로 순서 단언 · test/performance_explore_view_test.dart)
   이름: 'E22 layout order caption disclosure note values links'
   자리: group('PerformanceExploreView - E11 to E19 fixtures rendering') 안 · E21(563~584행) 다음(normalFixtureList 를 그대로 쓴다 · 그룹 이름은 바꾸지 않는다).
   띄우기: 픽스처마다 pumpExplore(tester, repo: FakePerformanceRepository(seriesResult: s), commandApi: FakeCommandApi(), bodyReceipt: receipt0())
           (E11~E19 와 같은 모양 · pumpExplore 의 뷰포트 390×2400 이라 값 표가 접힌 본문은 전부 지어진다 · 새 도우미·가짜 금지)
   비교: 위쪽 변 dy — testWidgets 안에 작은 지역 함수 하나(예 double topOf(String k) => tester.getTopLeft(find.byKey(Key(k))).dy;).
   🔴 «<» 는 lessThan 그대로(<= 로 바꾸지 않는다).
   정상 7개(for (final s in normalFixtureList)) — 픽스처마다:
     expect(find.text(AnalyticsLabels.retryButton), findsNothing);
     expect(topOf('s72-legend-main'), lessThan(topOf('s72-disclosure')));          // 8 < 10 (정상 7개 모두에 있는 기준점)
     for (var i = 0; i < s.segments.length; i++) {                                  // 9 < 10 — 양쪽 다 단언
       if (s.segments[i].kind != SegmentKind.measured) {
         expect(topOf('s72-segment-caption-$i'), lessThan(topOf('s72-disclosure')));
       } else {
         expect(find.byKey(ValueKey<String>('s72-segment-caption-$i')), findsNothing);
       }
     }
     if (s.benchmark != null) {                                                     // 10 < 11 < 12 — 양쪽 다 단언
       expect(topOf('s72-disclosure'), lessThan(topOf('s72-benchmark-note')));
       expect(topOf('s72-benchmark-note'), lessThan(topOf('s72-values-toggle')));
     } else {
       expect(find.byKey(const Key('s72-benchmark-note')), findsNothing);
       expect(topOf('s72-disclosure'), lessThan(topOf('s72-values-toggle')));
     }
     expect(topOf('s72-values-toggle'), lessThan(topOf('s72-link-drawdown')));     // 12 < 13
   불가 2개(FixturePaths.m7M7PerfUnavailableGap · FixturePaths.m7M7PerfMaskedIntegrity — E18 처럼 singleFixture 로) — 픽스처마다:
     expect(find.text(AnalyticsLabels.retryButton), findsNothing);
     expect(topOf('s72-unavailable'), lessThan(topOf('s72-disclosure')));
     expect(topOf('s72-disclosure'), lessThan(topOf('s72-link-drawdown')));
   (testWidgets 는 이것 하나 — flutter test 수 = 179 + 1 = 180. F1 전 코드에서는 첫 픽스처(벤치마크 있음)의 «disclosure < benchmark-note» 에서 실패하면 정상입니다 — 첫 실패에서 멈추므로 실패는 한 곳만 보입니다.)

F3 (테스트 · V2 두 곳 — 카드 규칙 11 «if 건너뛰기 금지») 'V2 values table expanded with benchmark'(636~648행) · 'V2 without benchmark'(699~711행)
   결측 순번을 찾는 for 다음 줄에 전제를 두고, 목록에서 if 를 지웁니다:
     expect(missingIdx, isNotNull);   // 전제 — 두 픽스처 모두 결측 점이 있다
     final checkIndices = <int>[0, missingIdx!, s.points.length - 1];
   🔴 if (missingIdx != null) 이 한 곳이라도 남으면 다시 반려입니다.

F4 (테스트 보강 — 발주자 결정으로 함께 · 전부 같은 파일)
   ⓐ 정상 상태 테스트마다 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 한 줄(카드 규칙 11 «정상 상태 테스트는 … retryButton findsNothing»)
      대상 = E1 · E2 · E3 · E4 · E5 · E6 · E8 · E11 · E12 · E13 · E14 · E15 · E16 · E18 · E19 · E20 · E21 · V1 · V2(둘) · V3(E22 는 F2 에 이미 있음).
      픽스처를 for 로 도는 테스트(E11~E16 · E18 · E19)는 루프 안에서 픽스처마다 · 나머지는 마지막 단언 뒤 한 줄.
      (E9 = 에러 상태라 retryButton 1 이 맞다 — 넣지 않는다 · E10 은 253행에 이미 있다.)
   ⓑ E18(497~506행 루프 안): expect(find.byKey(const Key('s72-tick-0')), findsNothing);   (카드 E18 «s72-tick-* … 0»)
   ⓒ 루프 앞 수 전제(루프가 0번 돌면 단언이 소리 없이 빠진다):
      E9(217행) · E10(274행) · E21(581행)의 for (final flag in safety3.activeFlags) 바로 앞에 expect(safety3.activeFlags, hasLength(2));   // 안전 상태 행 3 = 차단 2건
      E8(180행)의 for (final call in repo.seriesCalls) 바로 앞에 expect(repo.seriesCalls, hasLength(1));
   ⓓ 두 V2 — 행 Key 를 도는 for(629~634행 · 692~697행) 바로 뒤에 위쪽 닫기:
      expect(find.byKey(ValueKey<String>('s72-value-row-${s.points.length}')), findsNothing);   (V3 의 765~768행과 같은 모양)

F5 (골든 — s72_* 만 다시 찍기) F1~F4 뒤에, packages/ui_analytics 에서:
     flutter test --update-goldens test/golden/s72_golden_test.dart   ← 🔴 그 파일 하나만(폴더·다른 골든 파일 지정 금지)
     flutter test                                                     ← 옵션 없이 전부 통과 · 180
   git status --short 에서 바뀐 PNG 는 test/golden/goldens/s72_*.png 뿐이어야 합니다(고지 카드가 움직인 10장 · s72_unavailable 2장은 자리가 같아 안 바뀔 수 있음 — 안 바뀌면 그대로).
   🔴 s71_* · s73_* · s73b_* · s71b_* · s72g_* 가 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로.
   새 PNG 를 열어 고지 카드가 구간 캡션 아래 · 벤치마크 구성·「값 보기」 위에 있는지 눈으로 봅니다(글자는 테스트 글꼴이라 네모).

F6 (dy 재실측 + 질문 파일 새 행) 고지 카드가 움직였으므로 위치 전제 dy 를 12개 모두 다시 잽니다(1회차 값 1040·944·944·944·1040·604 는 바뀔 수 있습니다 — 옮겨 적지 않습니다).
   고지 카드를 옮겨도 앞뒤 간격 합이 같아 1회차와 같은 값이 나올 수 있습니다 — 같아도 정상입니다 · 잰 값을 그대로 적습니다(따로 설명을 붙이지 않습니다).
   재는 법(1회차 카드 «■ 골든» 절 끝 — 글자 그대로):
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s72_golden_test.dart 의 위치 전제 lessThan(<높이 상수>) 를 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/s72_golden_test.dart(--update-goldens 없이)
    → 테스트 이름마다 실패 문구의 «Actual: <숫자>» 를 적는다(12개 · 헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- test/golden/s72_golden_test.dart 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).
   (s72_golden_test.dart 에서 바꿀 곳 = lessThan(kS72GoldenSize.height) 여섯 곳(83·118·151·186·221·256행) · 테스트 이름 = '<골든 이름> light' / '<골든 이름> dark')
   질문 파일 docs/ai-context/inbox/S7-2_questions.md 표 끝(A6 행 다음)에 새 행 6개를 더합니다 — 형식은 A1~A6 과 같고, <값> 자리에만 잰 숫자를 넣습니다:
     | A7 | R10c-Bob-S72 | 추측 | 측정: s72_monthly_cum dy 재제출 실측값 (light=<값>, dark=<값> < 1400) | 골든 위치 전제 실측 | 1400 미만 확인 | ⬜ 미답 | |
     | A8 | R10c-Bob-S72 | 추측 | 측정: s72_daily_gap dy 재제출 실측값 (light=<값>, dark=<값> < 1400) | 골든 위치 전제 실측 | 1400 미만 확인 | ⬜ 미답 | |
     | A9 | R10c-Bob-S72 | 추측 | 측정: s72_sim_split dy 재제출 실측값 (light=<값>, dark=<값> < 1400) | 골든 위치 전제 실측 | 1400 미만 확인 | ⬜ 미답 | |
     | A10 | R10c-Bob-S72 | 추측 | 측정: s72_manual_segment dy 재제출 실측값 (light=<값>, dark=<값> < 1400) | 골든 위치 전제 실측 | 1400 미만 확인 | ⬜ 미답 | |
     | A11 | R10c-Bob-S72 | 추측 | 측정: s72_monthly_period dy 재제출 실측값 (light=<값>, dark=<값> < 1400) | 골든 위치 전제 실측 | 1400 미만 확인 | ⬜ 미답 | |
     | A12 | R10c-Bob-S72 | 추측 | 측정: s72_unavailable dy 재제출 실측값 (light=<값>, dark=<값> < 1400) | 골든 위치 전제 실측 | 1400 미만 확인 | ⬜ 미답 | |
   🔴 A1~A6 행과 머리말(«다음 번호» 포함)은 지우지도 고치지도 않습니다(답이 달릴 행은 지우지 않는 것이 규약 · 머리말은 통합 담당 몫) · 칸 안에 세로 막대 문자 금지.
   (머리말의 «다음 번호» 가 낡아 있어도 새 행 번호는 이 패킷이 정한 A7~A12 입니다 — 1회차 카드 «■ 질문 파일» 의 «다음 번호에서 이어 붙인다» 보다 이 줄이 앞섭니다.)
   이번 F1~F7 은 전부 이 패킷이 정했으므로 A7~A12 밖의 새 행이 없는 것이 정상입니다(문서에 없어 꼭 정해야 한 것이 생기면 그때만 A13 부터 · «⬜ 미답» · 답 칸 비움).
   답은 병합 때 통합 담당이 C4 재실측과 대조해 A1~A12 를 함께 닫습니다. 🔴 test/golden/README 를 고치면 반려입니다.

F7 (PR 본문 ③ — 처음부터 새로) 아래 «■ 제출» ③ 대로 씁니다. 핵심:
   «정상» = 고친 performance_explore_body.dart 를 위에서 아래로 읽으며 나오는 위젯·Key 이름을 그 순서 그대로 «→» 로 잇습니다 — s72-benchmark-note 를 빠뜨리지 않습니다.
      고지 카드(s72-disclosure)는 지역 변수를 정의한 줄(F1 ① 로 215행 다음에 둔 Card(key: … s72-disclosure))이 아니라 return <Widget>[ … ] 목록 안에서 고지 카드 변수(예 disclosureCard)를 «쓴» 자리로 셉니다
      (정상 = 구간 캡션 for 뒤 · 불가 = s72-unavailable 뒤 — 화면·PNG 의 세로 순서와 같습니다).
   «차단» = SafetyBlockBanner 의 자리를 코드 그대로 — «기록 줄(s72-record-line) 아래 · Expanded(ListView) 바깥 위(Column 둘째 자식)». «리스트뷰 상단» 이라고 쓰지 않습니다.
   🔴 «순서대로»·«정상 배치»·«모두» 같은 요약어는 코드와 PNG 를 다시 열어 맞는지 본 뒤에만 씁니다(1회차 «순서대로» 가 거짓이었습니다 — 반려 사유).

■ 제출
  (F1~F4 를 고친 뒤)
  melos.bat run format:fix
  cd packages/ui_analytics
  flutter test --update-goldens test/golden/s72_golden_test.dart   ← F5 · 그 파일 하나만
  flutter test   ← 옵션 없이 전부 통과 · 수 = 180(E22 +1 — 채팅에 실제 수를 적습니다)
  (F6 — dy 12개 재기 · 임시 lessThan(0) 되돌리기 · git diff -- test/golden/s72_golden_test.dart 출력 없음 확인 · 질문 파일 A7~A12)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git status --short
     ← M 이 정상인 곳 = packages/ui_analytics/lib/src/screens/explore/performance_explore_body.dart · packages/ui_analytics/test/performance_explore_view_test.dart ·
        packages/ui_analytics/test/golden/goldens/s72_*.png(12장 이하) · docs/ai-context/inbox/S7-2_questions.md 뿐.
        🔴 그 밖의 M(기존 PNG 30장 · s72_golden_test.dart · explore_fakes.dart · labels.dart · 차트 3파일 등) = 금지 — git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로.
  git add packages/ui_analytics/lib packages/ui_analytics/test/performance_explore_view_test.dart
  git commit -m "[M7] R10c 재제출 — 고지 카드 자리·순서 단언"   ← F1~F4
  git add packages/ui_analytics/test/golden/goldens docs/ai-context/inbox
  git commit -m "[M7] R10c 재제출 — 골든·질문 파일"   ← F5·F6
  git diff --name-status HEAD~2 HEAD
     ← 방금 만든 재제출 커밋 2개의 변경만 봅니다(HEAD~2 = «먼저 할 것»의 병합 커밋 · 병합할 것이 없었으면 9230112 — 경로를 붙이지 않습니다).
     ← 🔴 위 «M 이 정상인 곳»의 줄만 나와야 합니다(M · s72_*.png 는 12줄 이하). 다른 줄이 한 줄이라도 나오면 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
        (main 병합으로 들어온 변경은 HEAD~2 에 이미 들어 있어 이 출력에 나오지 않습니다 — 정상)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push   (같은 브랜치 → PR #17 자동 반영 · 새 PR·라벨·강제 푸시·rebase 금지)
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(1회차와 같은 22줄이 정상 — main 기준으로는 파일 집합이 같다)
  cd packages/ui_analytics → 아래 «정적 묶음» 22줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력
     🔴 푸시한 그 커밋 위에서 · git status 가 빈 채로 새로 돌린다 · 1회차 출력을 쓰지 않는다.
■ 정적 묶음 — packages/ui_analytics 에서 아래 22줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 22줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18 만 git diff 라 반대다 — 차이 0 = «… changed» 줄 없이 «EXIT:0»·«EXIT:True»(«warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  블록 뒤에 S05 결과 줄마다 한 줄씩 «<파일:줄> — 탭 콜백 안» 만 사람이 적는다.
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/performance_explore_view_test.dart test/perf_chart_geometry_test.dart test/golden/s72_golden_test.dart test/explore_fakes.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/performance_explore_view_test.dart test/perf_chart_geometry_test.dart test/golden/s72_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/performance_explore_view_test.dart test/perf_chart_geometry_test.dart test/golden/s72_golden_test.dart; echo "EXIT:$?"
echo "## S03 replaceFirst replaceAll 0"; git grep -nE "replaceFirst|replaceAll" -- lib/src/screens/explore/performance_explore_body.dart; echo "EXIT:$?"
echo "## S04 AppRoutes other than two 0"; git grep -nP "AppRoutes\.(?!performanceDrawdown\b|performanceContribution\b)" -- lib/src/screens/explore/performance_explore_body.dart; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/explore/performance_explore_body.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 DateRange ConfigRepository 0"; git grep -nE "DateRange|ConfigRepository" -- lib/src/screens/explore lib/src/chart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S15 autoDispose 3"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel exports 0"; git grep -nE "explore/|chart/|perf_chart|analytics_skeleton|analytics_error_view" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S19 item1 package imports"; git grep -nE "^import 'package:" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
  (줄의 뜻 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) · S03 = 링크는 DTO route 그대로(패턴에 값을 끼워 조립 금지) ·
   S04 = 고정 상수는 규칙 3 의 둘뿐 · S05 = build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) ·
   S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0(옮긴 차트 파일의 PerfChartColors 는 클래스 이름이라 -w 에 걸리지 않는다) ·
   S15 = 대소문자 구분(-i 로 세면 타입 이름까지 6 · 이 카드는 더하지 않는다) · 🔴 autoDispose 는 주석도 센다 — 주석에 autoDispose 라는 말을 쓰지 않는다 ·
   S17·S18 = «차트» 절의 두 줄 · S19~S21 = 12항의 1·3·11항 근거(② 괄호가 이 출력을 가리킨다))
  채팅으로 — PR 본문 5섹션을 처음부터 새로(지난 본문을 고쳐 쓰지 않습니다). PR 본문 수정은 통합 담당이 합니다:
   ① 화면 ID(S7-2 — 탐색 본문) + 차트 3파일(정적 묶음 S17·S18 = 차이 0) 한 줄 +
      바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(손으로 쓰지 않음 · A/M · PNG 포함)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다(R10a · R10b 1회차에 틀린 곳).
      붙일 괄호: 1번 = «정적 묶음 S19 — domain_contracts·flutter·flutter_riverpod 밖 0줄» · 3번 = «정적 묶음 S20 — 0건» ·
      4번 = «인터스티셜·열람 기록 = R10b(이미 main) · 격리 위치(라우트·진입점) = 셸 몫» · 5·6·12 와 10 앞절 = «이 카드 범위 밖» ·
      2번 = «화면 산술은 엔진 정규값 × 크기 1종뿐이며 DTO 값 원문 렌더» · 7번 = «splitRuns 분할 및 보간 없는 렌더 확인» ·
      8번 = «disclosure.sampleSizeLine, honestExpectationLine, benchmark.compositionNote 그대로 렌더»(2·7·8 = 1회차 괄호 — C4 가 사실로 확인) ·
      9번 = «as-of 는 탐색 본문에 1줄(s72-asof) · 오래됨 배너 = StaleBanner» · 11번 = «정적 묶음 S21 결과 N건» ·
      10번 뒷절(픽스처·골든 스냅샷) = «git status 의 기존 PNG M 0 · domain_contracts 변경 0»(10번은 «앞절 … / 뒷절 …» 로 괄호 하나)
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
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M7.md 154~168행과 같습니다)
      이어서 «정적 묶음» 출력 전부를 코드 블록 하나로 그대로 + S05 결과 줄마다 «탭 콜백 안» 한 줄(줄을 빼거나 줄이면 = 보고 불일치 = 반려)
   ③ 스크린샷 서술 — 로딩·정상·빈(불가)·차단 4줄 + 골든 표 12행(처음부터 새로 — 1회차 ③ 을 고쳐 쓰지 않는다)
      🔴 서술은 코드의 위젯·Key 이름 나열로만 쓴다(1회차 카드 «서술은 코드의 위젯·Key 이름으로만» 그대로 · 예 AnalyticsSkeleton · s72-unavailable · s72-link-drawdown).
         고친 performance_explore_body.dart 를 위에서 아래로 읽으며 나오는 순서 그대로 «→» 로 잇는다 · 조건으로 붙는 것(SafetyBlockBanner · s72-legend-benchmark ·
         s72-segment-caption-<순번> · s72-benchmark-note · s72-values-table)은 «(있을 때)» 를 붙인다 · 그 순서가 위 «카드 배치 원문» 0~13 과 다르면 제출하지 말고 멈춘 뒤 채팅으로
         (불가 = 카드 «불가» 줄 순서 0~5 → s72-unavailable → 10 → 13 과 비교).
         고지 카드(s72-disclosure)는 지역 변수를 정의한 줄이 아니라 return <Widget>[ … ] 목록 안에서 고지 카드 변수(예 disclosureCard)를 «쓴» 자리로 센다
         (정상 = 구간 캡션 for 뒤 · 불가 = s72-unavailable 뒤 — 화면·PNG 의 세로 순서와 같다 · 정의 줄은 세지 않는다).
      🔴 «순서대로»·«정상 배치»·«모두» 같은 요약어는 코드와 PNG 를 다시 열어 맞을 때만 쓴다(1회차 «순서대로» 가 거짓 — 반려 사유).
      «정상» 에 s72-benchmark-note 를 빠뜨리지 않는다 · «차단» = SafetyBlockBanner 가 s72-record-line 아래 · Expanded(ListView) 바깥 위(Column 둘째 자식) — «리스트뷰 상단» 이라고 쓰지 않는다 ·
      «로딩» · «불가» 도 코드의 위젯·Key 이름 그대로(불가 자리는 코드 그대로 Text(s72-unavailable)).
      골든 표 12행: 이름 · 입력 픽스처 · 크기 · 위치 전제 dy · 배치·잘림 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 performance_24m.json 행 0 · m7/m7_perf_daily_gap.json — 상수 이름과 섞지 않는다) · 크기 = 390×1400 ·
        dy = F6 로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다 · 1회차 값을 옮겨 적지 않는다) ·
        배치·잘림 = 새 PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 못 본 것은 «미열람»).
   ④ 질문 표 — 새 행 A7~A12 번호·요지(질문 파일에 쓴 글자와 같게)
   ⑤ 추측한 것 = 질문 파일의 새 A 행 중 «측정:» 이 아닌 행의 번호 전부(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
   (+ flutter test 실제 통과 수 한 줄)
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m7-s72-explore` 에 추가 커밋: `main` 병합 커밋 1 + 재제출 커밋 2(`[M7] R10c 재제출 — 고지 카드 자리·순서 단언` · `[M7] R10c 재제출 — 골든·질문 파일`).
- `lib/` 수정 1 — `screens/explore/performance_explore_body.dart`(고지 카드 블록 이동만: 정상 갈래 = 구간 캡션 for 뒤 · `s72-benchmark-note` 앞 / 불가 갈래 = `s72-unavailable` 뒤 · if/else 밖 옛 블록 삭제 · 카드 안 글자·Key·여백 불변).
- `test/` 수정 1 — `performance_explore_view_test.dart`(F2 새 E22 · F3 V2 두 곳 `expect(missingIdx, isNotNull)` + `missingIdx!` · F4 retryButton 0 줄 · E18 `s72-tick-0` 0 · E8/E9/E10/E21 루프 앞 수 전제 · 두 V2 `s72-value-row-<points.length>` 0).
- PNG — `s72_*` 만 M(12장 이하 · `s72_unavailable_*` 2장은 안 바뀔 수 있음) · 기존 30장 M 0 · `s72_golden_test.dart` 불변.
- `docs/ai-context/inbox/S7-2_questions.md` — 새 행 A7~A12(«측정:» · 재제출 dy) · A1~A6·머리말 불변.
- `git diff --name-status HEAD~2 HEAD`(재제출 커밋 2개만 · HEAD~2 = 병합 커밋 또는 `9230112`) = 위 파일들뿐.
- `ui_analytics` flutter test 180 · 채팅: PR 본문 5섹션(① `git diff --name-status origin/main...HEAD` 그대로(22줄) · ② 복사 상자 12항 + [x] + 괄호 + 정적 22줄 새 출력(S05 의 1회차 :440·:451 은 바뀜 · :103 은 그대로일 수 있음) · ③ 새로(Key 이름 나열 · 골든 표 12행 dy 이름·밝기마다) · ④ A7~A12 · ⑤ «없음»).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R10c-Bob-S72 재제출: PR #17 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. 0단계·«먼저 할 것»에서 멈췄다면 `R10c-Bob-S72 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR #17 «Files changed» — 9230112 뒤 커밋만 보면 된다): ① `packages/ui_analytics/lib/` 에서 `performance_explore_body.dart` 밖의 변경 ② 기존 PNG 30장(`s71_*`·`s73_*`·`s73b_*`·`s71b_*`·`s72g_*`)이 바뀜 ③ `explore_fakes.dart`·`s72_golden_test.dart`·`labels.dart`·차트 3파일·`pubspec.yaml`·`domain_contracts/**`·골든 하네스·golden README 변경 ④ 질문 파일의 A1~A6 행이나 머리말이 바뀜 · A7~A12 가 없음 ⑤ V2 에 `if (missingIdx != null)` 가 남음 · E22 가 없음 ⑥ ③ 에 «순서대로»·«리스트뷰 상단» 이 그대로 · `s72-benchmark-note` 가 없음 — 하나라도 있으면 반려 신호. dy 는 1회차 값과 같게 나와도 결함이 아닙니다(고지 카드를 옮겨도 간격 합이 같으면 맨 아래 위치는 그대로일 수 있다 — C4 가 재실측으로 대조).
- CI «골든 스냅샷» 잡은 이 PR 의 PNG 가 `main` 기준으로 전부 새 파일(A)이라 **초록이 정상**입니다(빨간색 = 기존 PNG 를 건드린 것 = 반려 신호). `golden:approved` 는 필요 없고 붙이지 않습니다.
- PR 에 `Merge remote-tracking branch 'origin/main'` 커밋이 보이는 것은 정상입니다(squash 병합이라 결과에 남지 않음 · `git diff --name-status origin/main...HEAD` 는 1회차와 같은 22줄이어야 함).
- C4 가 2회차에서 볼 것: E22 실행 · V2 두 곳 · lib diff = 블록 이동뿐 · 골든 diff(바뀐 PNG = `s72_*` 만) · dy 12개 재실측 대조 · ② 12항(15줄) 글자 diff · 정적 묶음 글자 대조(S05 새 줄 번호) · ③ 을 코드·PNG 와 대조 · 변이 «고지 카드를 12 뒤로» 1개 추가(이제 E22 가 잡아야 함) + 1회차 변이 재실행.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 worktree 에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래에서 R10c 패킷은 이 파일 하나입니다. 원 패킷 `R10c-Bob-S72.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 합니다). `_완료/R10b-Bob-S72G-재제출.md` 는 끝난 R10b 카드입니다.
