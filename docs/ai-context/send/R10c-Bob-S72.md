# 발송 패킷 R10c-Bob-S72 — S7-2 수익률 탐색 본문(차트·값 표) (계약 v1.3 · R10 3장 중 3번째)

> ⏸ **R10b 가 병합된 뒤에 보냅니다**(Claude 가 C4 병합 기록 때 이 줄을 ▶ 로 바꿉니다) — **R10 3장 중 3번째** · 한 번에 카드 1장 · 순서 R10a → R10b → R10c.
> 만든 날 2026-09-29(3분할판 — 발주자 결정 2026-09-29 «3장으로 쪼개는 안» · 원본 = 통합 패킷 `R10-Bob-S7x.md` v5(origin/main `86168d4` · 검증 4번)의 S7-2 탐색 본문·차트 몫) · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R10 행 · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-09-28_R10선행_계약v1.3_설계서.md` §2 Δ6 + §3 «4. 화면 구성»·«5. 증명 계획» · 조문 = `01_…` §13(13-1~13-4) · `03_…` §6 의 R10 범위 블록 · golden README «🆕 R10(계약 v1.3)» 절.
> 사전 조건 — ✅ 계약 v1.3 병합(M2 PR #14 · squash `e820042` · 2026-09-29) · ✅ R2b-Bob-J3 병합(PR #13 squash `b59a5e1` · 2026-09-29) · ⏸ **R10a-Bob-S71b 병합**(S7-1b 아카이브 + 공용 위젯 2개) · ⏸ **R10b-Bob-S72G 병합**(S7-2G 열람 게이트 + `PerformanceExploreScreen` + 탐색 본문 껍데기). 병합 확인은 본문 0단계의 확인 줄로(해시 없이 내용으로 확인한다).
> 카드 확정값(카드 권한): 정적 라벨 13개(본문 «정적 라벨») · 위젯·Key·파일 이름(본문 «주입 구조»·«화면») · 골든 6이름 12장.
> 🔴 **보내는 조건(Claude 확인)** — R10b PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-2_questions.md` 가 `main` 에 있음(빈 머리말 — `86168d4` 에서 이미 있다). 0단계의 `ls` 줄이 그 증명이다.
> 드라이런: 통합 패킷 드라이런(2026-09-29 · 3차 · v3 본문 · `flutter test` 223 통과)의 이 카드 몫 = 기하 3 · 탐색 70 · 골든 12(기존 골든 변경 0 · 계약 테스트 230 유지 · 차트 3파일 차이 0). 3분할 드라이런(R10a·R10b 위 · 이 카드 본문만): flutter test 224(기존 139 + 새 85 = 기하 3 · 탐색 70 · 골든 12) · 새 PNG 12 · 기존 30장 불변 · 변이 11개 잡힘 · dy 608~972.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 치환값은 R10 세 장을 함께 적은 것이다 · 이 카드의 범위·PR 제목은 이 패킷이 정한다) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R10a·R10b 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 이렇게 쓴다»로, 0단계·규칙 요약·본받지 않는 것·코드 틀은 본문에 담았습니다.

## 0. 한 줄 목적

수익률을 «격리된 자리에서 · 마찰을 거쳐 · 기록을 남기고» 보게 하는 세 화면 중 마지막 — 게이트를 지난 뒤의 **수익률 탐색 본문(토글·차트·값 표)** 을 계약 v1.3 그대로 채우기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s72-explore`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **R10b 가 `main` 에 병합된 뒤에 보냅니다** — 이 파일 머리 첫 줄이 ⏸ 이면 아직입니다(Claude 가 R10b 병합을 기록할 때 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
   🔴 이 패킷이 GitHub `main` 에 올라간 뒤에 보냅니다(0단계가 `main` 에서 이 파일과 질문 파일을 찾습니다).
2. Bob 에 «멈춘» 대화나 R10b 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R10c-Bob-S72.md`** 에서 엽니다(Bob 폴더는 옛 브랜치에 있어 이 파일이 안 보일 수 있습니다 · 그 폴더가 아직 최신 `main` 을 받지 않았으면 GitHub 의 `main` 에서 — 보낼지는 GitHub `main` 에 있는지로 판단).
4. 붙여넣을 것은 «3» 본문 **전부**(«R10c-Bob-S72 — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 R10 의 끝난 카드 `R10a-Bob-S71b.md`·`R10b-Bob-S72G.md`, 3분할 전 통합판 `R10-Bob-S7x.md`(보이더라도), M7 의 끝난 카드 `_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md`, M6 의 끝난 카드 `R2b-Bob-J3.md` 를 붙여넣지 않습니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R10c-Bob-S72 — 범위: S7-2 수익률 탐색 본문(PerformanceExploreBody 를 채운다 — 토글 · 차트 · 글자 · 캡션 · 고지 · 값 표 · 불가 카드 · 이동 버튼) ·
  차트 3파일(본보기를 글자 그대로 옮김). R10 3장 중 3번째(R10a·R10b 는 이미 main 에 병합됨).
하지 않는 것: S7-1b 아카이브·공용 위젯 2개(R10a 몫 — 이미 main) · S7-2G 게이트·PerformanceExploreScreen·열람 기록 명령(R10b 몫 — 이미 main) ·
  S7-1·S7-3·S7-3b 기존 화면 수정(S7-1 A13 «값 열 오른쪽 정렬» 포함 — R11 부록 후보(미결 63)) · 웹 2열·통계 패널·툴팁·하단 시트·차트 탭 읽기·선택 표시 · 기간 선택 UI ·
  «주» 주기 · afterTax · 「이전 기록 보기」 토글 · 절단선 · 「월 1회 권장」 문구 · 부분 동기 · 애니메이션 · 셸 몫(라우트 등록·라우터 가드·「더 보기」 진입점·실제 닫기 동작 — M8).
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 16항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R10b(ui/m7-s72g-gate · 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/chart/ · AnalyticsLabels.metricTwr 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s72g-gate 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s72-explore origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.3.0'" -- packages/domain_contracts/lib/src/contract_version.dart     ← «…contract_version.dart:1»(계약 v1.3 병합)
  ls docs/ai-context/send/R10c-Bob-S72.md                                                               ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/ui_analytics/lib/src/screens/performance_explore_screen.dart                              ← 보여야 R10b 가 병합된 것입니다
  ls packages/ui_analytics/lib/src/screens/explore/performance_explore_body.dart                        ← 보여야 함(R10b 의 껍데기 — 이 카드가 채운다)
  ls packages/ui_analytics/test/golden/chart_probe.dart                                                 ← 보여야 함
  ls packages/ui_analytics/test/golden/reference/chart/perf_chart_painter.dart                          ← 보여야 함
  ls packages/domain_contracts/fixtures/m7/m7_perf_monthly_sim_split.json                               ← 보여야 함
  ls docs/ai-context/inbox/S7-2_questions.md                                                            ← 보여야 함(빈 표가 이미 있다)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 두 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R10c 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/chart                                                                ← 없어야 함
  git grep -c metricTwr -- packages/ui_analytics/lib                                                    ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.3 새 타입(PerfAxisTick …)과 새 필드의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·chart_probe) > 이 카드(지시) > 01 §13 > 03 §6 의 R10 범위 블록 > 03 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml(차트 패키지 추가 = C-3 실패) · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·reference/**·s71_golden_test·s73_golden_test·README ·
   goldens/s71_*.png · s73_*.png · s73b_*.png · s71b_*.png · s72g_*.png(기존 30장) ·
   기존 화면 3파일(monthly_report·drawdown_context·contribution)·기존 위젯 3파일(stale_banner·safety_block_banner·trust_badge_view)·
   기존 테스트 4파일(contribution_view·drawdown_context_view·monthly_report_view + 자리표시 ui_analytics_test — 지우지도 고치지도 않는다) ·
   R10a 가 만든 것(screens/report_archive_screen.dart · widgets/analytics_skeleton.dart · widgets/analytics_error_view.dart · test/report_archive_view_test.dart · test/golden/s71b_golden_test.dart) ·
   R10b 가 만든 것(screens/performance_explore_screen.dart · screens/explore/disclosure_gate_view.dart · test/performance_explore_gate_test.dart · test/golden/s72g_golden_test.dart).
   🔴 기존 PNG 30장은 하나라도 M 이면 되돌리고 멈춤 · 예외 없음.
   test/explore_fakes.dart(R10b)는 **더하기만** 한다 — 있는 가짜·도우미의 동작을 바꾸면 반려.
   더하기 = 기존 클래스를 extends 한 새 가짜 · 새 함수 · 기존 함수·생성자에 선택 매개변수(기본값 = 지금 동작) —
   기존 이름·기본 동작·기존 매개변수는 바꾸지 않는다(R10b 의 G 테스트가 그대로 통과해야 한다).
 2 03 본문의 구 초안(§6 「데이터」·「컴포넌트」·「상태」·「모의」 줄과 그림 M7-11·M7-12)은 03 §6 의 R10 범위 블록(머리글 «🆕 계약 v1.3 — `S7-2` R10 범위»)과 01 §13 에 집니다.
   또 01 §13 머리·§13-13 의 «카드 1장»·«카드 3분할 기각», 질문 파일 머리말의 «R10-Bob-S7x» 는 발주자 결정(2026-09-29 3분할) 전의 글이다 —
   멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(공개 위젯 PerformanceExploreScreen 의 생성자에는 key 뿐 — R10b · 이미 main ·
   이 카드가 채우는 내부 위젯 PerformanceExploreBody 의 생성자는 key·receipt 그대로).
   이 카드가 쓰는 고정 상수는 둘뿐: AppRoutes.performanceDrawdown · AppRoutes.performanceContribution.
 4 값 = DTO 의 *Text·*Label·*Line·label·headline 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(double·int·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값의 부호로 색을 고르지 않음 · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
 5 읽지 않는 필드(카드가 정함 — 질문 아님): PerfPoint.value · gapReasonCode · date / PerfSegment.from · to / PerformanceSeries.metric · granularity · cumulative(되돌아온 요청 인자) · afterTax /
   PerfDisclosure.interstitialText · viewCountThisMonth /
   CommandReceipt 는 stateLabel(그린다)과 commandId(watchCommand 인자) 둘만 읽는다(둘 다 R10b 의 껍데기가 이미 읽는다 — 그대로 둔다).
   🔴 PerfPoint.value 는 C-36 ⑦ 이 빌드를 깬다 — 차트·탐색 파일에 «.value»(괄호가 바로 오는 Future.value( 와 valueOrNull 은 통과)나 PerfPoint(:value) 패턴 분해가 있으면 실패.
      그 파일들에서는 MapEntry 의 .value 도 · AsyncValue 의 .value 도 쓰지 않는다(when(…)·valueOrNull · 패턴 분해 (k, v) 로).
 6 화면 산술은 «엔진이 준 0.0~1.0 정규값 × 폭·높이» 하나뿐(차트 3파일 안에 이미 있다). 최솟값·최댓값·합·차·누적곱·이동평균 · 정규값이나 value 를 글자로(toStringAsFixed·NumberFormat — C-36 ⑧) ·
   결측 보간·직전 값 유지·0 대입 · 점·행 수를 글자로 — 전부 금지. 목록을 거르지도 세지도 정렬하지도 묶지도 않는다.
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에서 열거형 switch 는 차트 3파일의 SegmentKind 뿐이다.
   🔴 CommandState 로 갈래·문구를 고르지 않는다(lib 에 CommandState 0건) · rejectReasonCode 를 읽지 않는다.
 8 시계 = analyticsClockProvider(DateTime.now() 금지). 쓰는 자리는 둘: ① StaleBanner(기존 위젯이 한다) ② DisclosureViewEvent.viewedAt(게이트 — R10b 가 이미 했다). 머문 시간을 재지 않는다.
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = 마지막 성공 asOf.label(없으면 null — 탐색 시리즈 에러는 열쇠가 바뀌어 앞 값이 없으니 늘 null) + AnalyticsLabels.retryButton + ref.invalidate ·
   오래됨 = StaleBanner(asOf:) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(기존 화면과 같다 — 값이 온 뒤에만). 예외 하나 — 탐색 본문의 SafetyBlockBanner(배치 1)는
      시리즈가 아니라 안전 상태에서 오므로 시리즈가 로딩·에러여도 그 자리에 있다 · StaleBanner(배치 4)는 시리즈 값이 온 뒤에만.
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지 — 그 안에 들어가는 탐색 본문도 같다) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible(이 카드가 배치에 적은 짧은 글자 —
   값 표의 값 칸(SizedBox 88) — 는 예외 · 적힌 대로 짓는다) · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지(차트 눈금 글자만 예외 — 본보기 그대로) ·
   390px overflow 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
10 프로바이더는 이 카드에 필요한 것이 전부 이미 있다(R10a·R10b) — 더하지도 고치지도 않는다 · 이름·타입은 아래 «주입 구조» 고정 ·
   오프너·CommandApi·시계는 탭 콜백 안에서 ref.read(예외 하나 — 기록 줄 구독은 PerformanceExploreBody.initState 에서 · 이미 있다) — build 에서 read 금지.
   🔴 데이터 프로바이더 3개(reportArchiveProvider · disclosureGateProvider · performanceSeriesProvider)는 전부 autoDispose 다 — 기존 3개(비-autoDispose)를 본떠 바꾸지 않는다(바꾸면 월→일→월에서 호출이 0).
11 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO·CommandReceipt 를 지어 넣지 않는다(픽스처 행에서 — 예외는 기하 단위 테스트 U2 하나) · 링크는 RecordingLinkOpener 를 픽스처 값·상수와 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'E8 no weekly segment').
12 차트의 증명 = test/golden/chart_probe.dart 의 expect* 네 함수만(M2 소유 · 기대값은 픽스처에서 하네스가 계산한다). 차트 단언을 직접 짜지 않는다. 골든은 보조.
13 골든 = 이 카드의 새 PNG 12장만 · --update-goldens 는 새 테스트 파일 하나(test/golden/s72_golden_test.dart)를 지정(폴더 지정 금지) · golden:approved 는 안 붙임 · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이).
14 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)).
15 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: ratio · aspectRatio · devicePixelRatio · duration · durationSec · iteration · decoration · syntax. 글자 잇기는 보간 '${a}${b}'.
16 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
🔴 보고 규칙(R2 재제출 교훈) — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모). 자체 점검 ② 는 prompt_M7.md 154~168행 **12항** 원문 번호 그대로. 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 16항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 9~11행 «의존 … 추가하려면 먼저 질문» → 추가 없음(차트는 CustomPaint · pubspec 불변) ② 12~13행 라우트 상수 딥링크 → DTO 링크를 AppLinkOpener.open 에 · 고정 상수는 규칙 3 의 둘뿐
 ③ 14~16행 DateTime.now() 금지 → 그대로 + 주입 시계의 둘째 자리 = viewedAt(01 §13-6 · 게이트 — R10b 가 이미 했다) ④ 19~21행 «산술 입력은 0.0~1.0 정규값» → 그대로 유효(그래서 PerfPoint.value 를 읽지 않는다)
 ⑤ 31~32행 C-6(PerformanceSeries 참조 = 실패) → 그 검사의 대상은 홈·알림·셸이다 · S7-2 는 PerformanceSeries 를 쓰는 화면이다
 ⑥ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9) ⑦ 88행 «자체 점검 10항» → 154~168행 12항(이 카드 밖 5·6·12 와 10 앞절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑧ 88~89행 스크린샷 4장 → 서술 + 골든 표(«제출» ③) ⑨ 87~88행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅)
 ⑩ 97~99행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 이 화면의 타입은 코드에 확정 ⑪ 102~106행 역할 문단 → 범위 = 이 카드의 S7-2 탐색 본문 · 폰 세로 하나
 ⑫ 109~114행 «읽을 문서 5개» → 아래 «먼저 읽을 것» ⑬ 116행 브랜치 형식 → ui/m7-s72-explore
 ⑭ 123~125행 기간 프리셋 → 이 카드에는 기간 선택이 없다(DateRange·ConfigRepository 가 나오지 않는다) · 150행 «주 … 미정 시 비활성» → 선택지 자체가 없다 · 153행 «명세 §12와 1:1» → 무시
 ⑮ 118~120행 «① 격리된 위치 ② 인터스티셜 ③ 열람 기록을 전부» → 이 카드의 몫은 게이트를 지난 뒤의 탐색 본문이다 · ② 게이트와 ③ recordDisclosureView 는 R10b(이미 main) ·
    ① 격리 위치(라우트·진입점)는 셸(M8) · «월간 리포트에 열람 횟수 표기»는 S7-1(이미 병합)
 ⑯ 107행 «이번 과제 범위: S7-1b · S7-2G · S7-2»와 116행 PR 제목 치환값은 R10 세 장을 함께 적은 것이다 — 이 카드의 범위·PR 제목은 이 카드 머리(«범위»)와 «■ 제출» 이 정한다
 (93~94행 «기존 스냅샷을 다시 찍는 것은 위조»는 그대로 유효 — 이 카드에는 예외가 없다.)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문 ② 01 §13-1~§13-4(특히 13-2 허용·금지 표와 층 표)
 ③ 03 §6 의 R10 범위 블록 — 머리글 «🆕 계약 v1.3 — `S7-2` R10 범위»(찾는 말 = «R10 범위(» ·
    「모의」 줄 바로 아래 · 그림 앞 — 그림과 위쪽 본문은 «구 초안»이라 블록이 이긴다)
 ④ packages/domain_contracts/lib/ — src/dto/performance.dart 의 PerformanceSeries·PerfPoint·PerfSegment·PerfAxisTick·BenchmarkSeries·PerfDisclosure·DisclosureGateVm(게이트를 지날 때) ·
    src/repositories/performance_repository.dart(series · watchDisclosureGate) · src/commands/command_api.dart(recordDisclosureView · watchCommand) ·
    src/commands/command_receipt.dart · src/navigation/app_links.dart(규칙 4조 · performanceDrawdown·performanceContribution) ·
    testing.dart(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R10(계약 v1.3)» 절 전부(골든 표 · 위치 전제 · chart_probe 쓰는 법 · 본보기 3파일 옮기는 법) + «규칙»·«하네스» 절
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 ·
    lib/src/screens/performance_explore_screen.dart(게이트 → 탐색 본문 — 틀만 본다) · lib/src/screens/explore/performance_explore_body.dart(이 카드가 채울 껍데기) ·
    lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · stale_banner.dart · safety_block_banner.dart ·
    test/explore_fakes.dart(가짜·띄우기 도우미 — 더하기만) · test/performance_explore_gate_test.dart(가짜를 쓰는 모양 · 게이트를 누르는 법) · test/golden/s72g_golden_test.dart · test/golden/golden_support.dart ·
    test/golden/reference/ 의 세 파일(옮길 코드) · test/golden/chart_probe_test.dart 머리(하네스를 부르는 모양)
 ⑦ packages/domain_contracts/fixtures/README.md 의 v1.3 절 + 이 카드가 쓰는 픽스처 10건 + 안전 상태 1건(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · S7-2_questions.md 의 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → 탐색 본문은 AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton — R10a · 이미 main)
 · analytics_providers.dart 의 비-autoDispose family 3개 → performanceSeriesProvider 는 autoDispose 다(R10b · 이미 main · 고치지 않는다)
 · 테스트의 class … implements SafetyRepository · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · 띄우기 도우미를 만들어 쓴다
 · 차트 = CustomPaint(의존 3개 고정) — 패키지 README «차트» 절과 pubspec 주석이 같은 말을 한다
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s72-…)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음 · 🔴 이 카드는 프로바이더를 더하지도 고치지도 않는다)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsLabels.retryButton · staleBannerTitle.
· 이미 main 에 있다(R10b — lib/src/providers/analytics_providers.dart 끝 · 고치지 않는다) · 이렇게 생겼다(발췌 — 사이의 disclosureGateProvider 는 뺐다):
    final Provider<CommandApi> analyticsCommandApiProvider = Provider<CommandApi>((ref) {
      throw UnimplementedError('analyticsCommandApiProvider must be overridden');
    });
    typedef PerfSeriesQuery = ({PerfMetric metric, PerfGranularity granularity, bool cumulative});
    final AutoDisposeFutureProviderFamily<PerformanceSeries, PerfSeriesQuery> performanceSeriesProvider =
        FutureProvider.autoDispose.family<PerformanceSeries, PerfSeriesQuery>((ref, query) {
          return ref.watch(performanceRepositoryProvider).series(
            metric: query.metric,
            granularity: query.granularity,
            cumulative: query.cumulative,
          );
        });
  🔴 series 에 range 를 넘기지 않는다(= 엔진 기본 구간) · 열쇠는 레코드(== 가 없는 클래스를 열쇠로 쓰면 build 마다 새 열쇠 = 무한 재요청).
  (같은 파일의 reportArchiveProvider(R10a) · disclosureGateProvider(R10b)는 이 카드가 쓰지 않는다.)
· 이미 main 에 있는 파일(전부 packages/ui_analytics/lib/src/ 아래 · 고치지 않는다 · 쓰는 법):
    widgets/analytics_skeleton.dart     const AnalyticsSkeleton({super.key, this.blocks = 4})   — Column 회색 상자(높이 72 · colorScheme.surfaceContainerHighest) — R10a
        🔴 AnalyticsSkeleton 은 스크롤 없음(ListView 안에 들어간다).
    widgets/analytics_error_view.dart   const AnalyticsErrorView({super.key, required this.onRetry, this.lastAsOfLabel})   — (있으면) 라벨 → 아이콘 → FilledButton(AnalyticsLabels.retryButton) — R10a
    screens/performance_explore_screen.dart     const PerformanceExploreScreen({super.key})     — ConsumerStatefulWidget · 공개 — R10b
    screens/explore/disclosure_gate_view.dart   DisclosureGateView(내부 — 게이트 그림) — R10b
· 이 카드가 채우는 파일: screens/explore/performance_explore_body.dart   PerformanceExploreBody({super.key, required this.receipt})(내부 — 탐색 본문 · R10b 가 껍데기로 만들었다)
· 🆕 파일: chart/perf_chart_geometry.dart · chart/perf_chart_painter.dart · widgets/perf_chart.dart   — 본보기 3파일을 글자 그대로
· 배럴 lib/ui_analytics.dart 는 고치지 않는다(R10b 의 G13 이 export 줄의 집합을 본다).
  🔴 explore/ · chart/ · perf_chart · analytics_skeleton · analytics_error_view 는 export 하지 않는다. 테스트는 package:ui_analytics/src/… 로 직접 import.

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / listFixture / fixtureEnvelope)
 성과      performance24m(🔴 2행 — listFixture(…).rows[0] = 시간가중 · rows[1] = 금액가중 · singleFixture 는 던진다) · m7M7PerfDailyGap · m7M7PerfMonthlySimSplit · m7M7PerfDailyManual ·
           m7M7PerfMonthlyPeriod · m7M7PerfYearly · m7M7PerfUnavailableGap(points 0 + unavailableLabel) · m7M7PerfMaskedIntegrity(같은 모양 — 차단 가림)
 접수증    m7M7DisclosureViewReceipts4 — listFixture(…, CommandReceipt.fromJson).rows · 이 카드는 행 0 만 쓴다(PerformanceExploreBody 를 직접 띄울 때의 receipt · 게이트를 지날 때 가짜 recordDisclosureView 의 답)
 게이트    m7M7DisclosureGate(열림 — 게이트를 눌러 들어갈 때)
 안전      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상 · 3 차단 2건 · 4 무결성
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(서로 다른 날의 그림이다). 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 이미 main 에 있는 화면 — PerformanceExploreScreen = S7-2G 게이트 → S7-2 탐색 (R10b · 고치지 않는다 · 쓰는 법)
 State: CommandReceipt? _receipt(null = 아직 게이트) · bool _submitting · bool _notAccepted.
 build: _receipt == null 이면 게이트, 아니면 PerformanceExploreBody(receipt: _receipt!).
 🔴 performanceSeriesProvider 는 PerformanceExploreBody 안에서만 watch 한다(통과 전 series 호출 0).
 게이트를 지나는 법(테스트·골든): 열린 게이트(m7M7DisclosureGate)에서 「그래도 보기」(Key s72g-continue)를 누른다 → 가짜 recordDisclosureView 가 접수증을 돌려주면 탐색 본문으로 바뀐다.

■ 화면 — S7-2 탐색 본문 PerformanceExploreBody 를 채운다 (03 §6 블록 · 01 §13-1~§13-4)
 지금 main 의 껍데기(R10b):
  - 파일 `lib/src/screens/explore/performance_explore_body.dart` · `PerformanceExploreBody({super.key, required this.receipt})`.
  - State: `final PerfSeriesQuery _query`(첫 값 = `(metric: PerfMetric.twr, granularity: PerfGranularity.monthly, cumulative: true)` · R10b — 이 카드가 토글을 붙일 때 final 을 뗀다) ·
    `late CommandReceipt _shown`(initState 에서 widget.receipt) · `StreamSubscription<CommandReceipt>? _subscription`. (`_valuesOpen` 은 이 카드가 더한다.)
  - 기록 줄 구독 = 아래 «채운 뒤의 모양» 의 initState 코드(이미 있다) · dispose cancel.
  - build: Column[ 0 기록 줄 `Text(_shown.stateLabel)`(Key `s72-record-line`) , Expanded(ListView(padding 16)[ series 갈래 ]) ] · series = `ref.watch(performanceSeriesProvider(_query))` · 에러 = `AnalyticsErrorView(onRetry: () => ref.invalidate(performanceSeriesProvider(_query)), lastAsOfLabel: null)` · **로딩이든 값이 왔든 `AnalyticsSkeleton(blocks: 3)`**(값을 그리는 것은 이 카드).
  - 배너·토글·차트·글자는 **없다**(이 카드가 채운다). 🔵 R10b 병합 뒤 main 의 탐색 본문은 값이 와도 스켈레톤이다 — 라우트·진입점(셸 M8)이 아직 없어 사용자에게 보이지 않는다.
  - 이 카드는 이 파일을 **채운다**: 기록 줄·구독·series watch 는 그대로 두고 1(차단 배너)·2(토글)·그리고 값 갈래(4~13)를 더한다 ·
    토글을 붙이며 `_query` 의 final 을 뗀다.
 채운 뒤의 모양:
  State: PerfSeriesQuery _query(첫 값 = (metric: PerfMetric.twr, granularity: PerfGranularity.monthly, cumulative: true)) · bool _valuesOpen(첫 값 false) ·
         late CommandReceipt _shown(initState 에서 widget.receipt — 껍데기 그대로) · StreamSubscription<CommandReceipt>? _subscription.
  기록 줄 구독(initState — 껍데기에 이미 있다 · 그대로 둔다): _subscription = ref.read(analyticsCommandApiProvider).watchCommand(widget.receipt.commandId).listen(
         (next) { if (mounted) setState(() => _shown = next); },
         onError: (Object error, StackTrace stack) { FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'ui_analytics')); });   ← 에러면 마지막 글자 유지
       dispose 에서 _subscription?.cancel().
       🔴 StreamProvider 로 감싸지 않는다(에러가 삼켜진다).
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

■ 차트 — 본보기 3파일을 글자 그대로 옮긴다 (golden README R10 «4»)
  packages/ui_analytics 에서:
    mkdir -p lib/src/chart
    cp test/golden/reference/chart/perf_chart_geometry.dart lib/src/chart/
    cp test/golden/reference/chart/perf_chart_painter.dart  lib/src/chart/
    cp test/golden/reference/widgets/perf_chart.dart        lib/src/widgets/
    git diff --no-index --stat test/golden/reference/chart lib/src/chart                                       ← «… changed» 요약 줄(예 «1 file changed» · «3 files changed»)이 없어야 한다(차이 0)
    git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart   ← 같음(병합 검사가 본다)
    («warning: in the working copy of … LF will be replaced by CRLF» 줄은 차이가 아니다 — 무시한다)
    (🔴 diff -r 을 쓰지 않는다 — PowerShell 에서 diff 는 다른 명령이라 파일이 같아도 차이가 찍힌다 · mkdir·cp 가 안 되는 셸이면 편집기로 복사)
  🔴 옮긴 파일을 고치지 않는다(이름·색·굵기·층 순서·여백 — 하네스와 맞물린 계약이다). 고치고 싶으면 질문 파일에. 본보기 원본은 지우지 않는다.
  차트 상자 = PerfChart(series:) 하나. 바깥 여백은 ListView 의 padding 이 준다(차트 안쪽에 여백을 더하지 않는다).
  01 §13-2 의 «위아래 12» 는 PerfChart 안에 이미 있다 — 밖에서 Padding 을 더 주지 않는다.

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R10c (1) 정적 라벨») · 테스트는 그 단계 커밋에 함께
 (1) 정적 라벨 13개(기존 화면·위젯·게이트 무변경 — 시작할 때의 flutter test 가 그대로 통과).
 (2) 차트 3파일 옮기기 + test/perf_chart_geometry_test.dart(U1·U2·U4).
 (3) 탐색 본문 전부(토글·차트·글자·캡션·고지·값 표·불가 카드·이동) — performance_explore_body.dart 를 채운다(기록 줄·구독·series watch 는 그대로 · 토글을 붙이며 `_query` 의 final 을 뗀다) +
     test/performance_explore_view_test.dart(E1~E21 · V1~V3) + test/explore_fakes.dart 에 가짜 더하기(가짜 series() 표 · 그림용 가짜).
     🔴 R10b 의 performance_explore_gate_test.dart·게이트 파일(performance_explore_screen.dart · disclosure_gate_view.dart)은 고치지 않는다 — G1~G14 가 그대로 통과해야 한다.
 (4) 골든 12장 — test/golden/s72_golden_test.dart.
 (5) format:fix · 질문 파일 · 정적 검사.

■ 정적 라벨 — AnalyticsLabels 끝에(R10b 의 절 뒤) 절 주석(// ── 🆕 R10c — S7-2 ──)과 함께 13개(이름·글자 고정):
   metricTwr = '시간가중' · metricMwr = '금액가중' · granularityDaily = '일' · granularityMonthly = '월' · granularityYearly = '년' · cumulativeOn = '누적' · cumulativeOff = '기간별'
   valuesShowButton = '값 보기' · valuesHideButton = '값 접기' · valuesColumnMain = '내 계좌' · valuesColumnBenchmark = '비교 기준'
   drawdownLinkButton = '낙폭 맥락 보기' · contributionLinkButton = '슬리브 기여 보기'
   (gateBackButton · gateContinueButton · recordNotAccepted 는 R10b 가 이미 더했다 — 고치지 않는다.)
   🔴 만들지 않는 글자(엔진 몫): «기록 대기» · «모의 — 합산 제외» · «수동 집행 구간» · «산출 불가» · «산출 가능한 구간이 없습니다» · «월 1회 권장» · «주» · 연도·월 이름.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용)
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future/Stream ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 보고된 에러는 tester.takeException() 으로 단언 ·
  가짜 series() 의 답 = (twr·monthly·true → performance24m 행 0) · (mwr·monthly·true → 행 1) · (twr·daily·true → m7M7PerfDailyGap) · (twr·yearly·true → m7M7PerfYearly) ·
  (twr·monthly·false → m7M7PerfMonthlyPeriod) · 그 밖 = performance24m 행 0(값이 아니라 호출을 본다) — 받은 네 인자(metric·granularity·cumulative·range)를 호출마다 기록.
  토글을 누른 뒤에는 pump 를 한 번 더(autoDispose 가 옛 열쇠를 버릴 틈).
  가짜 series() — ⓐ E1~E8 · V3 = 위 표의 가짜 · E9 = 던지는 가짜 · E10 = 첫 답은 표 가짜 · 재요청은 Completer(둘 다 explore_fakes 에 더하거나 테스트 파일 안에)
    ⓑ 그림 테스트(E11~E21 · V1·V2)와 골든 = «인자가 무엇이든 그 테스트의 픽스처 하나를 돌려주는» 가짜(받은 인자 기록은 같다).
  🔴 가짜 CommandApi 는 recordDisclosureView 와 watchCommand 를 **둘 다** override 한다(받침대는 던진다 — 안 하면 탐색 본문의 initState 가 던진다) ·
    watchCommand 의 기본 답 = Stream<CommandReceipt>.value(그 테스트가 recordDisclosureView 로 돌려준 바로 그 접수증)(호출마다 새로 — 이 카드의 테스트는 행 0 · 탐색 본문을 직접 띄우는 테스트는 receipt 로 넘긴 그 접수증 = 행 0) ·
    StreamController 는 R10b 의 G7 만 쓴다. (행 0 을 기본 답으로 굳히면 R10b 의 G6 의 행 1·2·3 에서 기록 줄이 곧바로 행 0 의 글자로 바뀐다.)
  StreamController 는 만든 줄 바로 뒤 addTearDown(controller.close)(close_sinks 린트 · analyze --fatal-infos) · add·addError 직후는 await tester.pump(Duration.zero)(pump() 한 번은 반영되지 않는다).
  가짜와 띄우기 도우미(파일 안에서만 쓰면 `_pump` · 파일 밖에서 쓰면 밑줄 없는 공개 이름 — 예 `pumpExplore`)는 이미 main 의 test/explore_fakes.dart(R10b)에 있다 —
  이 카드는 그 파일에 **더하기만** 한다(가짜 series() 표 · 그림용 가짜) · R10b 테스트가 쓰는 기본 답(performance24m 행 0)은 바꾸지 않는다 ·
  권하는 모양 = 새 클래스(예 `extends` 로 series() 만 override) · 새 함수 — 기존 클래스의 생성자·필드·기본 동작은 그대로(선택 매개변수를 더하는 것은 규칙 1 대로 된다)
  (R10b 가 series 답을 생성자 인자로 열어 두었으면 그것을 써도 된다) ·
  이 카드의 새 테스트 파일 = performance_explore_view_test · perf_chart_geometry_test 2개 + 골든 s72_golden_test 1개(explore_fakes.dart 는 R10b 파일 — 더하기만) ·
  골든 테스트는 '../explore_fakes.dart' 로 import.
  🔴 R10b 의 performance_explore_gate_test.dart·게이트 파일(performance_explore_screen.dart · disclosure_gate_view.dart)은 **고치지 않는다** — G1~G14 가 그대로 통과해야 한다.
탐색 — test/performance_explore_view_test.dart (E1~E10 은 게이트를 실제로 눌러 들어간다 · E11 부터는 PerformanceExploreBody(receipt: 접수증 행 0) 를 직접 띄워도 된다)
 E1 통과 → series 기록 1건 = (PerfMetric.twr, PerfGranularity.monthly, true, range == null).
 E2 「금액가중」 → 2건 · 마지막의 metric 만 mwr.   E3 「일」 → +1 · granularity daily.   E4 「년」 → +1 · yearly.   E5 「기간별」 → +1 · cumulative false.
 E6 월 → 일 → 월 → 매번 +1(마지막 기록 = monthly · 캐시 적중 0).
 (E7·E17 은 없는 번호다 — 설계에서 뺐다: «이미 고른 칸 다시 누르기»는 증명이 아니고 차트 탭 읽기는 이 카드에 없다.)
 E8 기록 전체에 PerfGranularity.weekly 0 · tester.widget<SegmentedButton<PerfGranularity>>(find.byKey(const Key('s72-toggle-granularity'))).segments 의 value 목록 ==
    <PerfGranularity>[daily, monthly, yearly] · AnalyticsLabels.granularityDaily·granularityMonthly·granularityYearly 글자 각 1.
 E9 던지는 가짜(안전 상태 행 3 으로 띄운다) → retryButton 1 · s72-disclosure 0 · s72-link-drawdown 0 · s72-link-contribution 0 ·
     에러 상태에서도 그 플래그 label 글자 각 1(규칙 8 의 예외 — 탐색 본문의 차단 배너) → 누른다 → +1 · 같은 인자.
 E10 재요청을 Completer 로 멈춘다(안전 상태 행 3 으로 띄운다) → 토글 3줄 있음 · s72-chart 0 · AnalyticsSkeleton 1 · s72-disclosure 0 · s72-link-drawdown 0 ·
     s72-link-contribution 0(로딩·에러 때는 배치 4~13 이 없다) · 멈춘 동안에도 그 플래그 label 글자 각 1(탐색의 차단 배너는 시리즈와 무관하다).
 E11 성과 시리즈 9개마다(파일 8개 — 정상 7 시리즈 + 불가 2 · performance24m 만 2행) → sampleSizeLine·honestExpectationLine 각 1 ·
     전제 expect(disclosure.drawdownCaveatLine, isNotNull)(9개 전부 있다) 뒤 그 글자 1 · find.text(disclosure.interstitialText) 0.
 E12 정상 시리즈 7개마다 → expectMainLineMatches(recordChart(tester), series, chartSchemeOf(tester))   ← 수용 (a) 의 주 증명
 E13 같음 → expectBandsMatch.   E14 같음 → expectBenchmarkMatches · benchmark 가 있으면 s72-legend-benchmark 1 · s72-benchmark-note 1, 없으면 둘 다 0(양쪽 다 단언).
 E15 같음 → expectTicksMatch · yTicks 의 label 글자 각 1 · 눈금 글자의 오른쪽 끝 ≤ 차트(s72-chart)의 왼쪽 변(tester.getRect).
 E16 정상 시리즈 7개마다 → 측정 아닌 구간의 seg.label 각 1 · 측정 구간(kind == measured)의 seg.label 을 픽스처에서 읽어 find.text 0 ·
     series.segments 의 자리 i 마다 find.byKey(ValueKey<String>('s72-segment-caption-$i')) — 측정 아닌 구간이면 1 · 측정 구간이면 0(양쪽 다 단언).
 E18 불가 2건 → unavailableLabel 글자 1 · find.byKey(kChartProbeKey) 0 · s72-tick-* · s72-legend-main · s72-values-toggle 0 · 고지 카드 1 · 이동 버튼 2.
     🔴 E18 에서는 recordChart 를 부르지 않는다.
 E19 정상 시리즈 7개마다 → points.first.dateText · points.last.dateText · periodLabel · seriesLabel · asOf.label 글자 각 1 ·
     tester.getTopLeft(s72-x-first).dx == tester.getRect(s72-chart).left(x 글자 줄의 왼쪽 = 그림의 왼쪽 변).
 E20 이동 버튼 → opened == <String>[AppRoutes.performanceDrawdown] / <String>[AppRoutes.performanceContribution].
 E21 시계 +3일 → staleBannerTitle 1 / safetyStates 행 3 → 그 플래그 label 글자 각 1(E9 와 같은 단언).
 V1 기본 접힘 — s72-value-row-* 0 · find.text(AnalyticsLabels.valuesShowButton) 1.
 V2 「값 보기」 → 행 수 = series.points.length · 첫·끝·결측 순번 행마다 그 행 안 Text 의 글자 목록
    (tester.widgetList<Text>(find.descendant(of: 행 Key, matching: find.byType(Text))).map((t) => t.data).toList())이
    [dateText, valueText, (벤치마크가 있으면) benchmark.points[i].valueText] 와 순서까지 같다 ·
    🔴 find.text 로 세지 않는다(첫 행은 두 값의 글자가 같다).
    결측 순번 = yNormalized == null 인 첫 자리(테스트에서도 value 를 읽지 않는다) ·
    testWidgets 둘 — 벤치마크가 있는 시리즈(performance24m 행 0 · 머리 줄에 valuesColumnBenchmark 1) · 없는 시리즈(m7M7PerfDailyGap · 목록이 2칸 · 머리 줄에 valuesColumnBenchmark 0) ·
    버튼 글자 = valuesHideButton.
 V3 편 채로 「일」 → 여전히 펴져 있고 행이 새 시리즈(m7M7PerfDailyGap)의 것으로 바뀐다(행 수 = 새 points.length · 첫 행 dateText = 새 points.first.dateText).
기하 — test/perf_chart_geometry_test.dart
 U1 splitRuns(픽스처의 points) 가 아래 표와 같다(표는 M2 가 픽스처에서 뽑았다 — 계약 테스트 C-36 이 같은 픽스처를 지킨다):
      performance24m 행 0·1 → (0,5) (7,23) · 벤치마크 (0,23) / m7M7PerfDailyGap → (0,12) (15,20) / m7M7PerfMonthlySimSplit → (3,17) /
      m7M7PerfDailyManual → (0,20) / m7M7PerfMonthlyPeriod → (0,5) (8,23) · 벤치마크 (0,23) / m7M7PerfYearly → (0,2)
 U2 경계(🔴 이 테스트에 한해 점을 지어도 된다 — 자리 숫자만 · 글자는 ASCII): [] → [] · [null] → [] · [v] → [(0,0)] · [null,v,null] → [(1,1)] · [v,null,null,v] → [(0,0),(3,3)].
 U4 xOf(0)·xOf(1)·yOf(0)·yOf(1) 이 plot 의 네 변 · 범위 밖 값(−0.5 · 1.5)은 변에 붙는다.
 (U3 은 없는 번호다 — 설계에서 뺐다: 가장 가까운 점 찾기는 차트 탭 읽기의 것이고 이 카드에 없다.)
(정적 — PR 본문 ② 에 결과를 적는다) packages/ui_analytics 에서 git grep 으로:
  lib 에 CommandState 0 · Navigator 0 · DateTime.now 0 · kIsWeb·Platform. 0 · 'aaq:// 0 · toStringAsFixed 0 · GestureDetector 0 ·
  머티리얼 색 상수 Colors 는 기존 파일에만(새 파일 0 — git grep -nw Colors -- lib 로 센다 · 옮긴 차트 파일의 PerfChartColors 는 클래스 이름이라 대상이 아니다) ·
  lib/src/screens/explore·lib/src/chart·perf_chart.dart 에 DateRange·ConfigRepository 0 ·
  lib/src/providers 에 autoDispose 3(대소문자 구분 — -i 로 세면 타입 이름까지 6 · 이 카드는 더하지 않는다) ·
    🔴 autoDispose 는 주석도 센다 — 주석에 autoDispose 라는 말을 쓰지 않는다 ·
  lib/ui_analytics.dart 에 explore/·chart/·perf_chart·analytics_skeleton·analytics_error_view 0 · 차트 3파일 차이 0(«차트» 절의 git diff --no-index 두 줄).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 결측을 이어 그림 · 띠 누락 · 세로 뒤집힘 · family 를 비-autoDispose 로 ·
   값 표에 value 를 포맷해 찍기 · 구간 캡션 Key 순번 어긋남 · 로딩에 이동 버튼 그리기 · 탐색 로딩·에러에서 차단 배너 빼기 · x 글자 줄 여백 0 ·
   값 표 칸 순서 바꾸기 · 값 표에서 결측 행 빼기.

■ 골든 — 6이름 × light/dark = 12장(전부 신규 · golden README R10 «1»·«2» 표의 s72_* 행 그대로)
  s72_monthly_cum · s72_daily_gap · s72_sim_split · s72_manual_segment · s72_monthly_period · s72_unavailable(각 390×1400 · 게이트를 실제로 눌러 들어간다 · 값 표는 접힌 채)
  가는 길은 README «1» 표의 열 그대로 — daily_gap·manual_segment·unavailable 은 «일», monthly_period 는 «기간별»을 누른 뒤 · 골든의 가짜 series() 는 인자와 무관하게 그 골든의 픽스처를 돌려준다.
  높이는 테스트 파일 안 상수로 pumpForGolden(…, logicalSize:) 에 · 찍기 전 위치 전제(README «2») — s72_* = s72-link-contribution 의 아래 끝 < 1400 · 안전 상태 = 행 0.
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s72_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 12장만 ??
  (README «1» 의 명령은 골든 테스트 세 파일을 함께 적었다 — s71b·s72g 골든은 이미 main 에 있다(R10a·R10b).)
  🔴 s71b·s72g 골든 테스트 둘을 --update-goldens 에 넣지 않는다.
  위치 전제가 실패하면(본문이 1400 을 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다)
· S7-2_questions.md — 머리말의 «다음 번호»에서 이어 붙인다. 차트 질문도 여기에.
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 권고와 다르게 지은 이름 · 13개 밖에 새로 더한 정적 라벨 · 골든 위치 전제의 실제 dy · 본보기 차트에 고치고 싶은 점 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 13개 · 읽지 않는 필드 목록(규칙 5) ·
  첫 요청 값 · «주» 없음 · 기간 선택 없음 · 값 표 기본 접힘 · 골든 이름·높이 · 차트 3파일을 그대로 옮긴 것 ·
  재량인 것(여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  melos.bat run format:fix
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git status --short
     ← test/golden/goldens/ 에서: s71_*·s73_*·s73b_*·s71b_*·s72g_*.png 의 M = 금지(git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로) · 새 PNG 는 12장뿐 ·
        test/golden/chart_probe*.dart · reference/** · README.md 의 M = 금지 ·
        R10a·R10b 파일(report_archive_screen · analytics_skeleton · analytics_error_view · performance_explore_screen · disclosure_gate_view ·
        그 테스트 · s71b/s72g 골든 테스트)의 M = 금지 · explore_fakes.dart 는 더한 줄만
  git add packages/ui_analytics docs/ai-context/inbox
  git commit -m "[M7] R10c (5) format·질문 파일"   ← 고친 것이 있을 때만
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push -u origin ui/m7-s72-explore
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M7] S7-2 수익률 탐색 차트·값 표
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(S7-2 — 탐색 본문) + 차트 3파일(diff 0 확인 결과 한 줄)
   ② 자체 점검 12항 — prompt_M7.md 154~168행 원문 번호 그대로 · 코드에 실제로 있는 것만 [x] · 위 «정적» 줄의 grep 결과 ·
      4번 = [x] + 괄호 «인터스티셜·열람 기록 = R10b(이미 main) · 격리 위치(라우트·진입점) = 셸 몫» · 5·6·12 와 10 앞절 = [x] + 괄호 «이 카드 범위 밖» ·
      9번 = [x] + 괄호 «as-of 는 탐색 본문에 1줄(s72-asof) · 오래됨 배너 = StaleBanner»
   ③ 스크린샷 서술 — 로딩·정상·빈(불가 카드)·차단 최소 4 + 골든 표(12장: 이름·입력 픽스처·크기·위치 전제 · PNG 를 열어 배치·잘림만 · 못 본 것은 «미열람»)
   ④ 질문 표(새 행 번호·요지) ⑤ 추측한 것(없으면 «없음»)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s72-explore` 푸시 1건 · 커밋 4~5개(본문 (1)~(4) + format·질문 파일).
- `lib/` 새 파일 3(`chart/perf_chart_geometry.dart` · `chart/perf_chart_painter.dart` · `widgets/perf_chart.dart` — 본보기와 차이 0) · 수정 2(`screens/explore/performance_explore_body.dart` 채움 · `l10n/labels.dart` 13개). `providers/analytics_providers.dart` · `ui_analytics.dart`(배럴) · 게이트 파일 2(`performance_explore_screen.dart` · `explore/disclosure_gate_view.dart`) · R10a 파일 3 · 기존 화면 3·위젯 3은 바뀌지 않는 것이 정상.
- `test/` 새 파일 2(`performance_explore_view_test.dart` · `perf_chart_geometry_test.dart`) + 골든 테스트 1(`golden/s72_golden_test.dart`) + 새 PNG 12장 · 수정 1(`explore_fakes.dart` — 더하기만). 하네스·본보기·기존 PNG 30장·`performance_explore_gate_test.dart`·`report_archive_view_test.dart`·`s71b_golden_test.dart`·`s72g_golden_test.dart` 는 불변.
- 질문 파일 1개(`S7-2_questions.md` — 새 행이 있을 때만 바뀜) · 채팅: PR 본문 5섹션.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R10c-Bob-S72 결과: 브랜치 ui/m7-s72-explore 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R10c-Bob-S72 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R10c-Bob-S72 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG 30장(`s71_*`·`s73_*`·`s73b_*`·`s71b_*`·`s72g_*`)이 `M`, 또는 R10a·R10b 파일(게이트 2 · `performance_explore_gate_test.dart` 등)이 `M` ② `pubspec.yaml` 변경(차트 패키지 = C-3) ③ `test/golden/chart_probe*.dart`·`reference/**` 가 `M`, 또는 `lib/src/chart/` 가 본보기와 다름 ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now` ⑤ `value` 를 읽거나 숫자를 글자로 만드는 코드(`toStringAsFixed`) — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **추가만** 하므로 초록이 정상입니다(빨간색이면 기존 PNG 를 건드린 것).
- 계약 테스트 C-36 ⑦⑧(차트·탐색 파일의 `value` 참조 · 숫자 포맷)은 Bob 브랜치가 들어와야 실제 파일을 봅니다 — 병합 검사 때 Claude 가 그 위에서 돌립니다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 🔴 **파일 이름 주의** — 같은 R10 의 끝난 카드(`R10a-Bob-S71b.md`·`R10b-Bob-S72G.md`)와 3분할 전 통합판 `R10-Bob-S7x.md`, 같은 M7 의 끝난 카드(`_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md`), M6 의 끝난 카드 `R2b-Bob-J3.md` 를 붙여넣지 않습니다.
- 드라이런 실측(통합 패킷 드라이런 2026-09-29 · 3차의 이 카드 몫 · 참고): 새 테스트 85건(기하 3 · 탐색 70 · 골든 12) · 맨 아래 위젯의 아래 끝 = `s72_*` 608~972 — 높이 1400 에 여유가 있습니다. 년 시리즈의 x 끝 글자(«2026년(8월까지)»)는 테스트 글꼴에서 두 줄로 접힐 수 있습니다(정상 — overflow 아님 · 골든에는 년 시리즈가 없습니다). Bob 의 수가 이보다 적다고 반려는 아닙니다(최소 목록의 번호가 기준). 3분할 드라이런(R10a·R10b 위 · 이 카드 본문만): flutter test 224(기존 139 + 새 85 = 기하 3 · 탐색 70 · 골든 12) · 새 PNG 12 · 기존 30장 불변 · 변이 11개 잡힘 · dy 608~972.
- 범위 고지: 「주」 주기 · 기간 선택 · 웹 2열·툴팁 · 차트 탭 읽기 · 절단선은 이 카드에 없습니다(01 §8 미결 54·55·58·61). S7-1 A13 «값 열 오른쪽 정렬»은 R11 부록 후보입니다(미결 63).
- 그 밖의 알릴 것은 `R10a-Bob-S71b.md` «5» 를 참고합니다.
