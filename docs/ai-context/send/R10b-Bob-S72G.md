# 발송 패킷 R10b-Bob-S72G — S7-2G 열람 게이트 + 수익률 탐색 화면 합성(본문 껍데기) (계약 v1.3)

> ▶ **R10a 병합됨(PR #15 · squash `02e8e06`) — 보낼 수 있습니다**(이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 보이면) — **R10 3장 중 2번째 · 한 번에 카드 1장 · 순서 a → b → c**.
> 만든 날 2026-09-29 — 통합 패킷 v5 `R10-Bob-S7x.md`(origin/main `86168d4` · 네 번 검증)를 발주자 결정(「3장으로 쪼개는 안으로 바꿔주세요」)에 따라 3장으로 나눈 둘째 장. 글자·코드·테스트 문장은 v5 그대로이고 카드 경계 때문에 번호·수·가리킴·브랜치·PR 제목만 고쳤다 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R10 행 · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-09-28_R10선행_계약v1.3_설계서.md` §2 Δ6 + §3 «4. 화면 구성»·«5. 증명 계획» · 조문 = `01_…` §13(13-5 · 13-6 · 13-7) · `03_…` §5 의 R10 범위 블록 · golden README «🆕 R10(계약 v1.3)» 절 «1»·«2».
> 사전 조건 — ✅ 계약 v1.3 병합(M2 PR #14 · squash `e820042`) · ✅ R2b-Bob-J3 병합(PR #13 squash `b59a5e1`) · ✅ **R10a-Bob-S71b 병합**(PR #15 · squash `02e8e06` · 2026-09-29 — 아카이브 + 공용 위젯 `AnalyticsSkeleton`·`AnalyticsErrorView`). 병합 확인은 본문 0단계의 확인 줄로(해시 없이 내용으로 확인한다).
> 카드 확정값(카드 권한): 정적 라벨 3개(본문 «정적 라벨») · 위젯·프로바이더·Key·파일 이름(본문 «주입 구조») · 골든 4이름 8장.
> 🔴 **올리는 순서(Claude)** — 3장 패킷(`R10a-Bob-S71b.md` · 이 파일 · `R10c-Bob-S72.md`)과 질문 파일 3개는 R10a 를 보내기 전에 이미 `main` 에 있다. R10a 병합 뒤 C4 기록 때 이 머리 첫 줄을 ▶ 로 바꿔 같이 푸시한다. 0단계의 `ls` 줄(R10a 가 만든 파일이 보이는가)이 그 증명이다.
> 드라이런: 통합 패킷 드라이런(2026-09-29 · 3차 · v3 본문 · `flutter test` 223 통과)의 이 카드 몫 = 게이트 20 + 골든 8. 3분할 드라이런(R10a 위 · 이 카드 본문만): flutter test 139(기존 111 + 새 28 = 게이트 20 · 골든 8) · 새 PNG 8 · 기존 22장 불변 · 변이 6개 잡힘 · dy 196~272.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다.
> 🔴 Bob **새 대화** 전제(R10a 를 받은 대화를 이어 쓰지 않는다 — 앞 카드를 기억하지 못한다) — 0단계·규칙 요약·본받지 않는 것·코드 틀·R10a 가 만든 것의 쓰는 법을 본문에 담았습니다.

## 0. 한 줄 목적

수익률 탐색을 «마찰을 거쳐 · 기록을 남기고» 들어가게 하는 열람 게이트(S7-2G)와, 게이트를 지나면 같은 위젯 안에서 탐색 본문으로 바뀌는 합성(본문은 껍데기 — 차트·값은 R10c)을 계약 v1.3 그대로 만들기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s72g-gate`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **선행 = R10a-Bob-S71b 병합** — 이 파일 머리 첫 줄이 ▶ 로 바뀌었는지 봅니다(⏸ 이면 아직 보내지 않습니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
   🔴 단 이 패킷이 GitHub `main` 에 올라간 뒤에 보냅니다(0단계가 `main` 에서 이 파일과 질문 파일 `S7-2G_questions.md` 를 찾습니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다.
   🔴 R10a 를 보낸 대화를 이어 쓰지 않습니다(카드마다 새 대화).
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R10b-Bob-S72G.md`** 에서 엽니다(Bob 폴더는 옛 브랜치에 있어 이 파일이 안 보일 수 있습니다 · 그 폴더가 아직 최신 `main` 을 받지 않았으면 GitHub 의 `main` 에서 · 보낼지는 GitHub `main` 에 있는지로 판단).
4. 붙여넣을 것은 «3» 본문 **전부**(«R10b-Bob-S72G — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 R10 의 `R10a-Bob-S71b.md`(앞 카드 · 병합됨)·`R10c-Bob-S72.md`(다음 카드 — 이 카드 병합 뒤)와 헷갈리지 않습니다. 통합 패킷 `R10-Bob-S7x.md` 가 어딘가에 보여도 그것은 3장으로 대체된 것입니다 — 붙여넣지 않습니다. 같은 M7 의 끝난 카드 `_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md` 와 M6 의 끝난 카드 `R2b-Bob-J3.md` 도 붙여넣지 않습니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R10b-Bob-S72G — 범위: S7-2G 열람 게이트 + S7-2 수익률 탐색 화면의 합성(공개 위젯 1개 PerformanceExploreScreen —
  언제나 게이트로 시작하고 통과하면 같은 위젯 안에서 탐색 본문으로 바뀐다) · 탐색 본문은 **껍데기**(기록 줄 + 구독 + 시리즈 호출 + 스켈레톤)까지.
하지 않는 것: 탐색 본문의 토글·차트·글자·캡션·고지·값 표·불가 카드·이동 버튼·배너 · 차트 3파일 옮기기(전부 R10c 몫) ·
  S7-1·S7-1b·S7-3·S7-3b 기존 화면과 공용 위젯 2개 수정(R10a 가 만든 것 포함 — 고치지 않는다 · S7-1 A13 «값 열 오른쪽 정렬»은 R11 부록 후보(미결 63)) · 웹 2열·통계 패널·툴팁·하단 시트·차트 탭 읽기·선택 표시 · 기간 선택 UI ·
  «주» 주기 · afterTax · 「이전 기록 보기」 토글 · 절단선 · 「월 1회 권장」 문구 · 부분 동기 · 애니메이션 · 셸 몫(라우트 등록·라우터 가드·「더 보기」 진입점·실제 닫기 동작 — M8).
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 16항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R10a(ui/m7-s71b-archive · 병합됨)가 아닙니다. ui/m6-* · ui/m7-s71b-archive 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/screens/performance_explore_screen.dart · analyticsCommandApiProvider · AnalyticsLabels.gateBackButton 이 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s71b-archive 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s72g-gate origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.3.0'" -- packages/domain_contracts/lib/src/contract_version.dart     ← «…contract_version.dart:1»(계약 v1.3 병합)
  ls docs/ai-context/send/R10b-Bob-S72G.md                                                              ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/ui_analytics/lib/src/screens/report_archive_screen.dart                                   ← 보여야 R10a 가 병합된 것입니다
  ls packages/ui_analytics/lib/src/widgets/analytics_skeleton.dart                                      ← 보여야 함(R10a)
  ls packages/domain_contracts/fixtures/m7/m7_disclosure_view_receipts_4.json                           ← 보여야 함
  ls docs/ai-context/inbox/S7-2G_questions.md                                                           ← 보여야 함(빈 표가 이미 있다)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  🔴 아래 두 줄만 반대다 — «없음»·출력 없음이 정상(보이면 이미 R10b 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/screens/performance_explore_screen.dart                              ← 없어야 함
  git grep -c -e analyticsCommandApiProvider -e gateBackButton -- packages/ui_analytics/lib            ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.3 새 타입(PerfAxisTick …)과 새 필드의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §13 > 03 §5 의 R10 범위 블록 > 03 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml(차트 패키지 추가 = C-3 실패) · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·reference/**·s71_golden_test·s73_golden_test·s71b_golden_test·README ·
   goldens/s71_*.png · s73_*.png · s73b_*.png · s71b_*.png(기존 22장 — 아래 «되돌리고 멈춘다» 줄) ·
   기존 화면 4파일(monthly_report·drawdown_context·contribution·report_archive)·기존 위젯 5파일(stale_banner·safety_block_banner·trust_badge_view·analytics_skeleton·analytics_error_view)·
   기존 테스트 5파일(contribution_view·drawdown_context_view·monthly_report_view·report_archive_view + 자리표시 ui_analytics_test — 지우지도 고치지도 않는다).
   (report_archive_screen · analytics_skeleton · analytics_error_view · report_archive_view_test · s71b_golden_test · s71b_*.png 은 앞 카드 R10a 가 만들어 이미 main 에 있다 — 쓰기만 한다.)
   🔴 기존 PNG 22장은 하나라도 M 이면 되돌리고 멈춘다 · 예외 없음.
 2 03 §5 본문의 구 초안(「데이터」·「컴포넌트」·「상태」·「모의」 줄과 그림 M7-9·M7-10)은 03 §5 의 R10 범위 블록(머리글 «🆕 계약 v1.3 — `S7-2G` R10 범위»)과 01 §13 에 집니다.
   01 §13 머리·§13-13 의 «카드 1장»·«카드 3분할 기각», 질문 파일 머리말의 «R10-Bob-S7x» 는 발주자 결정(2026-09-29 3분할) 전의 글이다 — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(공개 위젯 PerformanceExploreScreen 의 생성자에는 key 뿐 — 내부 위젯은 콜백을 가져도 된다).
   이 카드가 쓰는 고정 상수는 하나뿐: AppNavActions.back(「돌아가기」). (AppRoutes.performanceDrawdown · performanceContribution 은 R10c 몫)
 4 값 = DTO 의 *Text·*Label·*Line·label·headline 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(double·int·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값의 부호로 색을 고르지 않음 · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
 5 읽지 않는 필드(카드가 정함 — 질문 아님): PerfPoint.value · gapReasonCode · date / PerfSegment.from · to / PerformanceSeries.metric · granularity · cumulative(되돌아온 요청 인자) · afterTax /
   PerfDisclosure.interstitialText · viewCountThisMonth / DisclosureGateVm.route /
   CommandReceipt 는 stateLabel(그린다)과 commandId(watchCommand 인자) 둘만 읽는다.
   🔴 PerfPoint.value 는 C-36 ⑦ 이 빌드를 깬다 — 차트·탐색 파일에 «.value»(괄호가 바로 오는 Future.value( 와 valueOrNull 은 통과)나 PerfPoint(:value) 패턴 분해가 있으면 실패.
      그 파일들에서는 MapEntry 의 .value 도 · AsyncValue 의 .value 도 쓰지 않는다(when(…)·valueOrNull · 패턴 분해 (k, v) 로).
      대상 = 이 카드의 lib/src/screens/performance_explore_screen.dart 와 lib/src/screens/explore/ 두 파일(게이트 그림·탐색 본문 껍데기) — 셋 다 대상.
      게이트 화면에서도 AsyncValue 의 .value 금지(valueOrNull · when).
 6 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에는 열거형 switch 가 없다(차트의 SegmentKind 는 R10c).
   🔴 CommandState 로 갈래·문구를 고르지 않는다(lib 에 CommandState 0건) · rejectReasonCode 를 읽지 않는다.
 7 시계 = analyticsClockProvider(DateTime.now() 금지). 쓰는 자리는 둘: ① StaleBanner(기존 위젯이 한다) ② DisclosureViewEvent.viewedAt. 머문 시간을 재지 않는다.
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = 마지막 성공 asOf.label(없으면 null — 탐색 시리즈 에러는 첫 요청이라 앞 값이 없으니 늘 null) + AnalyticsLabels.retryButton + ref.invalidate ·
   오래됨 = StaleBanner(asOf:) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(기존 화면과 같다 — 값이 온 뒤에만). (탐색 본문의 배너는 R10c 몫 — 이 카드의 껍데기에는 배너가 없다.)
 8 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지 ·
   390px overflow 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
 9 주입 프로바이더만 throw 기본값(데이터 프로바이더는 throw 금지) · 이름·타입은 아래 «주입 구조» 고정 · 새 프로바이더는 analytics_providers.dart 에(타입 명시) ·
   오프너·CommandApi·시계는 탭 콜백 안에서 ref.read(예외 하나 — 기록 줄 구독은 PerformanceExploreBody.initState 에서) — build 에서 read 금지.
   🔴 이 카드의 새 데이터 프로바이더 2개도 전부 autoDispose(기존 비-autoDispose 3개를 본뜨지 않는다 — 본뜨면 월→일→월에서 호출이 0).
10 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO·CommandReceipt 를 지어 넣지 않는다(픽스처 행에서 — 이 카드에는 예외가 없다) · 링크는 RecordingLinkOpener 를 픽스처 값·상수와 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'G2 back: opens AppNavActions.back, no command') ·
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다(R10a A6 은 행 Key 0 을 archiveEmpty.rows 로 적었다) ·
   스켈레톤 1 = expect(find.byType(AnalyticsSkeleton), findsOneWidget)(package:ui_analytics/src/widgets/analytics_skeleton.dart import) — 스피너 부재로 대신하지 않는다 ·
   if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다(R10a A9) · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다(R10a A8).
11 골든 = 이 카드의 새 PNG 8장만 · --update-goldens 는 새 테스트 파일 하나를 지정(폴더 지정 금지) · golden:approved 는 안 붙임 · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)).
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: ratio · aspectRatio · devicePixelRatio · duration · durationSec · iteration · decoration · syntax. 글자 잇기는 보간 '${a}${b}'.
14 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10a 교훈) — 🔴 이 카드부터 «보고와 코드·파일·PNG 가 다르면 1건이라도 재량 없이 반려»입니다.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모).
   자체 점검 ② 는 prompt_M7.md 154~168행 12항을 글자 그대로 복사한 뒤 [x] 와 괄호 근거만 붙입니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 · 항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다 —
   R10a 는 12항을 전부 자기 말로 바꿔 1·2·3·11항의 원문 검사가 빠졌습니다).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(PR 본문 ① 한 줄 · 골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 16항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 9~11행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변) ② 12~13행 라우트 상수 딥링크 → DTO 링크를 AppLinkOpener.open 에 · 고정 상수는 규칙 3 의 하나뿐
 ③ 14~16행 DateTime.now() 금지 → 그대로 + 주입 시계의 둘째 자리 = viewedAt(01 §13-6)
 ④ 31~32행 C-6(PerformanceSeries 참조 = 실패) → 그 검사의 대상은 홈·알림·셸이다 · S7-2 는 PerformanceSeries 를 쓰는 화면이다 ⑤ 38~41행 자리표시자 → 링크 null = 부재
 ⑥ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9) ⑦ 88행 «자체 점검 10항» → 154~168행 12항(이 카드 밖 5·6·7·8·12 와 10 앞절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑧ 88~89행 스크린샷 4장 → 서술 + 골든 표(«제출» ③) ⑨ 87~88행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅)
 ⑩ 97~99행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 이 카드 화면의 타입은 코드에 확정 ⑪ 102~106행 역할 문단 → 범위 = 이 카드의 게이트 + 탐색 화면 합성(본문 껍데기) · 폰 세로 하나
 ⑫ 109~114행 «읽을 문서 5개» → 아래 «먼저 읽을 것» ⑬ 116행 브랜치 형식 → ui/m7-s72g-gate
 ⑭ 123~125행 기간 프리셋 → 이 카드에는 기간 선택이 없다(DateRange·ConfigRepository 가 나오지 않는다) · 153행 «명세 §12와 1:1» → 무시
 ⑮ 118~120행 «① 격리된 위치 ② 인터스티셜 ③ 열람 기록을 전부» → 이 카드의 몫은 ② 게이트와 ③ recordDisclosureView 둘이다 · ① 격리 위치(라우트·진입점)는 셸(M8) ·
    «월간 리포트에 열람 횟수 표기»는 S7-1(이미 병합)
 ⑯ 107·116행 — prompt_M7.md 의 {{범위}} 와 PR 제목 치환값은 R10 세 장을 함께 적은 것이다 — 이 카드의 범위·PR 제목은 카드 머리가 정한다(범위 = 이 본문 첫 줄 · PR 제목 = 아래 «제출»).
 (93~94행 «기존 스냅샷을 다시 찍는 것은 위조»는 그대로 유효 — 이 카드에는 예외가 없다.)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문 ② 01 §13-5 · §13-6 · §13-7 + §4-2 «Future 에러 = 접수 실패» + §12-3(접수 실패 1줄 5원칙) + §11-1(링크 4조)
 ③ 03 §5 의 R10 범위 블록 — 머리글 «🆕 계약 v1.3 — `S7-2G` R10 범위»(찾는 말 = «R10 범위(» ·
    그 절 「모의」 줄 바로 아래 · 그림 앞 — 그림과 위쪽 본문은 «구 초안»이라 블록이 이긴다)
 ④ packages/domain_contracts/lib/ — src/dto/performance.dart 의 PerformanceSeries(껍데기는 받기만 한다)·DisclosureGateVm ·
    src/repositories/performance_repository.dart(series · watchDisclosureGate) · src/commands/payloads.dart(DisclosureViewEvent) · src/commands/command_api.dart(recordDisclosureView · watchCommand) ·
    src/commands/command_receipt.dart · src/labels/disclosure_codes.dart · src/navigation/app_links.dart(규칙 4조 · AppNavActions) ·
    testing.dart(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R10(계약 v1.3)» 절의 «1» 표(s72g_* 네 행)와 «2» 높이와 위치 전제 + «규칙»·«하네스» 절
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 ·
    lib/src/screens/contribution_screen.dart(화면 틀의 본보기 — 틀만 본다) · lib/src/widgets/stale_banner.dart · safety_block_banner.dart ·
    R10a 가 만든 lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart(쓰는 법만 — 고치지 않는다) ·
    test/monthly_report_view_test.dart(가짜 = extends 받침대 · 링크 기록기) · test/golden/s71_golden_test.dart · test/golden/golden_support.dart
 ⑦ packages/domain_contracts/fixtures/README.md 의 v1.3 절 + 이 카드가 쓰는 픽스처 6건 + 안전 상태 1건(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · 질문 파일 S7-2G_questions.md 의 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → 새 화면은 AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton — R10a 가 만들어 main 에 있다)
 · analytics_providers.dart 의 비-autoDispose family 3개 → 새 것은 autoDispose
 · 테스트의 class … implements SafetyRepository · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · 띄우기 도우미를 만들어 쓴다(이름은 아래 «테스트 최소 목록» 공통)
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s72g-… · s72-…)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsLabels.retryButton · staleBannerTitle.
· R10a 가 만든 것 — 이미 main 에 있다 · 고치지 않는다 · 이렇게 쓴다(import — lib 안에서는 상대 경로(기존 파일과 같게) · 테스트는 package:ui_analytics/src/…):
    widgets/analytics_skeleton.dart     const AnalyticsSkeleton({super.key, this.blocks = 4})   — Column 회색 상자(높이 72 · colorScheme.surfaceContainerHighest)
        🔴 스크롤 없음(ListView 안에 들어간다)
    widgets/analytics_error_view.dart   const AnalyticsErrorView({super.key, required this.onRetry, this.lastAsOfLabel})   — (있으면) 라벨 → 아이콘 → FilledButton(AnalyticsLabels.retryButton)
    reportArchiveProvider(analytics_providers.dart 끝 — 이 카드는 쓰지 않는다 · 그 줄도 고치지 않는다)
· 🆕 lib/src/providers/analytics_providers.dart 끝(reportArchiveProvider 뒤)에 더한다(기존 줄은 고치지 않는다):
    final Provider<CommandApi> analyticsCommandApiProvider = Provider<CommandApi>((ref) {
      throw UnimplementedError('analyticsCommandApiProvider must be overridden');
    });
    final AutoDisposeStreamProvider<DisclosureGateVm> disclosureGateProvider =
        StreamProvider.autoDispose<DisclosureGateVm>((ref) {
          return ref.watch(performanceRepositoryProvider).watchDisclosureGate();
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
· 🆕 파일 3개(전부 packages/ui_analytics/lib/src/ 아래):
    screens/performance_explore_screen.dart     const PerformanceExploreScreen({super.key})     — ConsumerStatefulWidget · 공개
    screens/explore/disclosure_gate_view.dart   DisclosureGateView(내부 — 게이트 그림 · 생성자 매개변수는 재량)
    screens/explore/performance_explore_body.dart   PerformanceExploreBody({super.key, required this.receipt})(내부 — 탐색 본문 · 이 카드는 껍데기)
· 배럴 lib/ui_analytics.dart = 머리 주석 유지 + export **1줄만** 추가: 'src/screens/performance_explore_screen.dart'.
  🔴 export 는 알파벳 순서다(directives_ordering · --fatal-infos) — performance_explore_screen 은 monthly_report_screen 바로 다음 줄(R10a 가 맨 끝에 넣은 report_archive_screen 의 앞 줄). 끝에 붙이면 analyze 가 실패한다.
  🔴 explore/ · chart/ · perf_chart · analytics_skeleton · analytics_error_view 는 export 하지 않는다. 테스트는 package:ui_analytics/src/… 로 직접 import.

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / listFixture / fixtureEnvelope)
 게이트    m7M7DisclosureGate(열림 · 마찰 줄 있음) · m7M7DisclosureGateFirst(열림 · frictionLine 없음) · m7M7DisclosureGateFrequent(열림) · m7M7DisclosureGateClosed(gateOpen false · route 없음)
 접수증    m7M7DisclosureViewReceipts4 — listFixture(…, CommandReceipt.fromJson).rows
           🔴 행 순서 = 뜻: 0 REQUESTED · 1 EXECUTED · 2 EXPIRED · 3 HELD_FOR_INTEGRITY(거부 행은 없다)
 성과      performance24m(가짜 series() 의 기본 답)
           🔴 2행 — listFixture(…).rows[0] = 시간가중 · rows[1] = 금액가중 · singleFixture 는 던진다 · 이 카드는 행 0 만 쓴다
 안전      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상 · 3 차단 2건 · 4 무결성
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(서로 다른 날의 그림이다). 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 — PerformanceExploreScreen = S7-2G 게이트 → 탐색 본문(껍데기) (03 §5 블록 · 01 §13-5·§13-6)
 State: CommandReceipt? _receipt(null = 아직 게이트) · bool _submitting · bool _notAccepted.
 build: _receipt == null 이면 게이트, 아니면 PerformanceExploreBody(receipt: _receipt!).
 🔴 통과 사실은 이 State 에만 둔다 — 전역 프로바이더·정적 변수·세션 캐시 금지(위젯이 새로 만들어지면 언제나 게이트부터).
 🔴 performanceSeriesProvider 는 PerformanceExploreBody 안에서만 watch 한다(통과 전 series 호출 0).

 게이트 상태 표 (그리는 것 / 「돌아가기」 / 「그래도 보기」 / 1줄)
  로딩(첫 값 전)          AnalyticsSkeleton(blocks: 2)            / 있음 / 없음 / —
  스트림 에러              AnalyticsErrorView(재시도 = ref.invalidate(disclosureGateProvider) · lastAsOfLabel = 마지막 성공 asOf.label — 없으면 null) / 있음 / 없음 / —
  열림(gateOpen true)     카드: headline · viewCountText · frictionLine(있을 때) · asOf.label / 있음 / 있음(활성) / —
  닫힘(gateOpen false)    같은 카드                                 / 있음 / 없음(부재 — 비활성 아님) / —
  제출 중                  같은 카드                                 / 있음(눌린다) / 있음(비활성) / 직전 1줄은 제출 시작 때 사라짐
  접수 실패(Future 에러)   같은 카드                                 / 있음 / 있음(활성 — 다시 누르면 새 명령) / AnalyticsLabels.recordNotAccepted(버튼 줄 바로 위 · colorScheme.error)
  접수증 도착(상태 불문)   → 탐색 본문으로 바뀜(거부·만료·보류여도 들어간다)
  오래됨·차단              카드 위에 StaleBanner(asOf: vm.asOf) · SafetyBlockBanner — 들여보낼지는 gateOpen 이 말한다(화면이 플래그로 판정하지 않는다)
 배치: Column[ StaleBanner , SafetyBlockBanner , Expanded(ListView(padding 16)[ 카드 , (접수 실패 1줄) ,
        Row[ Expanded(FilledButton 「돌아가기」) , SizedBox(width: 12) , Expanded(OutlinedButton 「그래도 보기」) ] ]) ]   ← 두 버튼은 같은 줄·같은 크기(동급 배치)
       「그래도 보기」가 없는 상태(닫힘·로딩·에러)에서는 「돌아가기」 하나가 줄 전체 폭이다(빈 반쪽을 남기지 않는다).
       로딩·에러도 같은 틀 — Column[ Expanded(ListView(padding 16)[ 스켈레톤 또는 에러 뷰 , 버튼 줄 ]) ] · 배너는 값이 온 뒤에만.
 「돌아가기」 = ref.read(analyticsLinkOpenerProvider).open(AppNavActions.back) · 명령 0건 · 로딩·에러·제출 중에도 항상 있고 눌린다.
 Key: s72g-card · s72g-headline · s72g-count · s72g-friction · s72g-asof · s72g-back · s72g-continue · s72g-record-not-accepted.
      다는 자리 = card 는 Card 자체(G8 이 그 폭을 잰다) · back·continue 는 그 버튼(FilledButton·OutlinedButton) · 나머지는 그 Text.

 명령 호출 틀(「그래도 보기」 — 모양 그대로 · try 는 명령 호출의 대기 하나만 감싼다):
    Future<void> _continue() async {
      setState(() {
        _submitting = true;
        _notAccepted = false;
      });
      final CommandReceipt receipt;
      try {
        receipt = await ref.read(analyticsCommandApiProvider).recordDisclosureView(
          DisclosureViewEvent(
            surfaceCode: DisclosureSurfaceCodes.performanceExplore,
            viewedAt: ref.read(analyticsClockProvider).nowUtc(),
          ),
        );
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stack, library: 'ui_analytics'),
        );
        if (mounted) {
          setState(() {
            _submitting = false;
            _notAccepted = true;
          });
        }
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _receipt = receipt;
        _submitting = false;
      });
    }
 🔴 durationSec 는 적지 않는다(기본값 0) · 에러의 내용·타입으로 문구를 만들거나 분기하지 않는다 · SnackBar·다이얼로그 금지 · 접수 실패면 탐색 화면을 열지 않는다 · vm.route 를 열지 않는다.
    (03 §5 위쪽 본문의 «호출 실패(오프라인)여도 진입»은 구 초안이다 — 오프라인은 실패가 아니라 REQUESTED 접수증으로 온다.)

 탐색 본문 껍데기 PerformanceExploreBody — 이 카드는 껍데기까지(정확한 모양):
 - 파일 `lib/src/screens/explore/performance_explore_body.dart` · `PerformanceExploreBody({super.key, required this.receipt})`.
 - State(선언 모양 그대로):
     `final PerfSeriesQuery _query = (metric: PerfMetric.twr, granularity: PerfGranularity.monthly, cumulative: true);`
       — R10b 에서는 바뀌지 않아 final(린트 prefer_final_fields · analyze --fatal-infos)
     `late CommandReceipt _shown`(initState 에서 `_shown = widget.receipt;` — 초기값 없는 필드는 컴파일이 안 된다)
     `StreamSubscription<CommandReceipt>? _subscription`. (`_valuesOpen` 은 R10c.)
 - 기록 줄 구독 = 아래 initState 코드 그대로.
     기록 줄 구독(initState): _subscription = ref.read(analyticsCommandApiProvider).watchCommand(widget.receipt.commandId).listen(
         (next) { if (mounted) setState(() => _shown = next); },
         onError: (Object error, StackTrace stack) { FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'ui_analytics')); });   ← 에러면 마지막 글자 유지
       dispose 에서 _subscription?.cancel().
       🔴 StreamProvider 로 감싸지 않는다(에러가 삼켜진다).
 - build: Column[ 0 기록 줄 `Text(_shown.stateLabel)`(Key `s72-record-line`) , Expanded(ListView(padding 16)[ series 갈래 ]) ] · series = `ref.watch(performanceSeriesProvider(_query))` · 에러 = `AnalyticsErrorView(onRetry: () => ref.invalidate(performanceSeriesProvider(_query)), lastAsOfLabel: null)` · **로딩이든 값이 왔든 `AnalyticsSkeleton(blocks: 3)`**(값을 그리는 것은 R10c).
     기록 줄은 항상 · 상태로 고르지 않는다.
 - 배너·토글·차트·글자는 **없다**(R10c). 🔵 R10b 병합 뒤 main 의 탐색 본문은 값이 와도 스켈레톤이다 — 라우트·진입점(셸 M8)이 아직 없어 사용자에게 보이지 않는다.
 - R10c 는 이 파일을 **채운다**: 기록 줄·구독·series watch 는 그대로 두고 나머지를 더한다(R10c 카드가 채운다 — 차단 배너 · 토글 · 값).
   → 그러니 기록 줄·구독·series watch 의 모양을 위와 다르게 짓지 않는다(다음 카드가 그 위에 쌓는다).

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R10b (1) 주입·라벨») · 테스트는 그 단계 커밋에 함께
 (1) analyticsCommandApiProvider · disclosureGateProvider · typedef PerfSeriesQuery · performanceSeriesProvider + 정적 라벨 3개
     (기존 화면·위젯 무변경 — 시작할 때의 flutter test 가 그대로 통과).
 (2) PerformanceExploreScreen(게이트 + 합성) + DisclosureGateView + PerformanceExploreBody 의 **껍데기**(기록 줄 + watchCommand 구독 + ref.watch(performanceSeriesProvider(_query)) 호출까지 —
     에러면 AnalyticsErrorView · 로딩이든 값이 왔든 AnalyticsSkeleton(blocks: 3) · 토글·배너·그림은 R10c) + 배럴 export 1줄 + test/performance_explore_gate_test.dart(G1~G14)
     + 가짜 도우미 test/explore_fakes.dart.
     🔴 껍데기가 series 를 부르지 않으면 G3 의 «series 1» 이 실패한다.
 (3) 골든 8장 — test/golden/s72g_golden_test.dart.
 (4) format:fix · 질문 파일 · 정적 검사.

■ 정적 라벨 — AnalyticsLabels 끝에 절 주석(// ── 🆕 R10b — S7-2G ──)과 함께 3개(이름·글자 고정):
   gateBackButton = '돌아가기' · gateContinueButton = '그래도 보기' · recordNotAccepted = '열람 기록이 접수되지 않았습니다. 화면은 열리지 않았습니다.'
   (탐색 본문의 라벨 13개 — metricTwr … contributionLinkButton — 는 R10c 몫이다. 이 카드에서 미리 만들지 않는다.)
   🔴 만들지 않는 글자(엔진 몫): «기록 대기» · «월 1회 권장» · 연도·월 이름.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용)
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future/Stream ·
  픽스처는 golden_support.dart 의 singleFixture/listFixture/fixtureEnvelope 로만 읽는다(자체 파일 읽기 도우미 금지) · 띄우기 도우미는 한 벌(시계·오프너는 선택 매개변수) ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 보고된 에러는 tester.takeException() 으로 단언 ·
  가짜 PerformanceRepository 는 series() 의 답을 생성자 인자로 받는다(기본 = performance24m 행 0 — 이 카드의 테스트는 기본 답만 쓴다 · 값이 아니라 호출을 본다) —
    받은 네 인자(metric·granularity·cumulative·range)를 호출마다 기록.
  🔴 가짜 CommandApi 는 recordDisclosureView 와 watchCommand 를 **둘 다** override 한다(받침대는 던진다 — 안 하면 탐색 본문의 initState 가 던진다) ·
    watchCommand 의 기본 답 = Stream<CommandReceipt>.value(그 테스트가 recordDisclosureView 로 돌려준 바로 그 접수증)(호출마다 새로 — G6 은 그 행 · 그 밖은 행 0) ·
    G7 만 StreamController. (행 0 을 기본 답으로 굳히면 G6 의 행 1·2·3 에서 기록 줄이 곧바로 행 0 의 글자로 바뀐다.)
  StreamController 는 만든 줄 바로 뒤 addTearDown(() { unawaited(controller.close()); })(close_sinks 린트 · analyze --fatal-infos · unawaited 는 dart:async) —
  🔴 addTearDown(controller.close) 로 쓰지 않는다: 탭 뒤에야 구독되는 비방송 컨트롤러(G7 의 watchCommand)는 탭 전 단언이 실패하면 구독자 0 이라 close() Future 가
  끝나지 않고 teardown 이 testWidgets 타임아웃까지 매달린다(R2b C4 7547d3c). add·addError 직후는 await tester.pump(Duration.zero)(pump() 한 번은 반영되지 않는다).
  가짜와 띄우기 도우미(파일 안에서만 쓰면 `_pump` · 파일 밖에서 쓰면 밑줄 없는 공개 이름 — 예 `pumpExplore`)는 test/explore_fakes.dart 한 파일에 모은다
    (도우미라 «새 테스트 파일 1» 에 세지 않는다 · 골든 테스트는 '../explore_fakes.dart' 로 import).
    띄우기 도우미(공개 이름)는 가짜 리포지토리·가짜 CommandApi·시계·오프너·안전 상태를 인자로 받는다(기본값 = 지금 동작).
    🔴 다음 카드 R10c 가 이 파일에 더하기만 한다 — 가짜 series() 의 기본 답(performance24m 행 0)을 이 카드의 G 테스트가 쓴다.
게이트 — test/performance_explore_gate_test.dart
 G1 띄운다(m7M7DisclosureGate) → headline·viewCountText·frictionLine 글자 · 버튼 2 · find.byKey(const Key('s72-chart')) 0
    (`s72-chart` = R10c 가 넣을 차트 Key — 이 카드에서는 늘 0 이지만 R10c 뒤의 경계 단언이라 둔다) · s72-record-line 0 · series 호출 0 · 명령 0.
 G2 「돌아가기」 → opener.opened == <String>[AppNavActions.back] · 명령 0 · series 0.
 G3 「그래도 보기」(명령 = 접수증 행 0) → 명령 1 · event.surfaceCode == DisclosureSurfaceCodes.performanceExplore · event.viewedAt == kGoldenNowUtc · event.durationSec == 0 ·
    s72-record-line 글자 = 행 0 의 stateLabel · series 1 · watchCommand 가 받은 id == 행 0 의 commandId ·
    opener.opened 비어 있음(「그래도 보기」는 어떤 링크도 열지 않는다 — vm.route 포함).
 G4 명령을 Completer 로 멈춘다 → 「그래도 보기」 비활성 — tester.widget<OutlinedButton>(find.byKey(const Key('s72g-continue'))).onPressed == null 과 다시 눌러도 명령 1 둘 다 · 「돌아가기」는 눌린다(opened 1) ·
    그 뒤 트리를 pumpWidget(const SizedBox()) 로 내리고 Completer 를 끝낸다 → 예외 없음(tester.takeException() == null).
 G5 명령이 던진다 → 게이트 그대로 · s72g-record-not-accepted 1 · takeException 비null · series 0 → 다시 누른다(이번엔 접수증 행 0) → 그 줄 0 · 명령 누계 2 · 탐색 본문.
 G6 첫 접수증을 4행 각각으로(testWidgets 넷 · 가짜 watchCommand 도 같은 행을 낸다) → 전부 탐색 본문(s72-record-line 1) · 글자 = 그 행의 stateLabel · opener.opened 비어 있음.
 G7 watchCommand 가 행 1 을 낸다 → 기록 줄 글자가 행 1 의 stateLabel 로 / watchCommand 가 에러를 낸다 → 마지막 글자 유지 + takeException 비null.
 G8 닫힌 게이트 → s72g-continue 0 · s72g-back 1 · headline 글자 1 · 명령 0 ·
    tester.getSize(s72g-back).width == tester.getSize(s72g-card).width(「돌아가기」 하나가 줄 전체 폭).
 G9 첫 열람 게이트 → s72g-friction 0 · viewCountText 글자 1.
 G10 통과 → pumpWidget(const SizedBox()) → 같은 가짜로 다시 띄운다 → 게이트가 다시 보인다(s72g-card 1 · s72-record-line 0) → 다시 통과 → 명령 누계 2.
 G11 게이트 스트림 미방출(add 하지 않은 StreamController) → AnalyticsSkeleton 1 · s72g-back 1 · s72g-continue 0 / 스트림 에러 → retryButton 1 · s72g-back 1 · s72g-continue 0 ·
     둘 다 안전 상태 행 3 + 시계 +3일로 띄운다 → 로딩·에러에서는 staleBannerTitle 0 · 그 플래그 label 글자 0(값이 오면 보인다는 것은 G14 가 본다).
 G12 통과한 뒤 게이트 스트림이 새 값(m7M7DisclosureGateClosed)을 낸다 → 탐색 본문 그대로(s72-record-line 1 · s72g-card 0).
 G13 File('lib/ui_analytics.dart') 를 읽는다 → export 줄의 집합이 정확히 { l10n/labels.dart · src/providers/analytics_providers.dart · src/screens/contribution_screen.dart ·
     src/screens/drawdown_context_screen.dart · src/screens/monthly_report_screen.dart · src/screens/report_archive_screen.dart · src/screens/performance_explore_screen.dart }.
     export 줄은 RegExp(r"^export '([^']+)';", multiLine: true).allMatches(내용).map((m) => m.group(1)).toSet() 으로 뽑아 7개 집합과 equals — 파일 전체 contains 로 대신하지 않는다.
 G14 시계 +3일 → staleBannerTitle 1 / safetyStates 행 3 → 플래그 label 글자 각 1 · 그 dy < s72g-card 의 dy.
 (G3·G5·G6·G10·G12 가 «탐색 본문» 을 보는 곳은 s72-record-line 과 s72g-card 뿐이다 — 껍데기로 통과한다.)
(정적 — PR 본문 ② 에 결과를 적는다) packages/ui_analytics 에서 git grep 으로:
  새 테스트 파일에 한글 문자열 0 — git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/performance_explore_gate_test.dart test/explore_fakes.dart test/golden/s72g_golden_test.dart 가 주석 줄 말고는 출력 없음 ·
    테스트 이름은 ASCII 만(«—»·«→» 도 금지) ·
  git grep -nE "AppRoutes|replaceFirst|replaceAll" -- lib/src/screens/performance_explore_screen.dart lib/src/screens/explore → 0(링크는 DTO route 그대로 — 패턴에 값을 끼워 조립 금지) ·
  git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/performance_explore_screen.dart lib/src/screens/explore → 결과 줄마다 «탭 콜백 안» 인지 적는다(build 본문에서 읽는 줄 0 · 오프너는 탭 콜백 안에서 읽고 바로 open) ·
  lib 에 CommandState 0 · Navigator 0 · DateTime.now 0 · kIsWeb·Platform. 0 · 'aaq:// 0 · toStringAsFixed 0 · GestureDetector 0 ·
  머티리얼 색 상수 Colors 는 기존 파일에만(새 파일 0 — git grep -nw Colors -- lib 로 센다) ·
  lib/src/screens/explore·performance_explore_screen.dart 에 DateRange·ConfigRepository 0 ·
  lib/src/providers 에 autoDispose 3(대소문자 구분 — -i 로 세면 타입 이름까지 6 · R10a 의 1 + 이 카드의 2
    · 🔴 주석도 센다 — 주석에 autoDispose 라는 말을 쓰지 않는다) · lib/ui_analytics.dart 에 explore/·chart/·perf_chart·analytics_skeleton·analytics_error_view 0.
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 통과 전 series 호출 · 명령을 두 번 · 에러인데 진입 · vm.route 열기 ·
   게이트 로딩·에러에 배너 그리기 · 「돌아가기」 반쪽 폭.

■ 골든 — 4이름 × light/dark = 8장(전부 신규 · golden README R10 «1»·«2» 표 그대로)
  s72g_first · s72g_frequent · s72g_closed · s72g_not_accepted(열린 게이트 + 던지는 명령 가짜 · 「그래도 보기」를 1번 누른 뒤 ·
    🔴 찍기 전에 expect(tester.takeException(), isNotNull) — 보고된 에러를 받아 두지 않으면 그 테스트가 실패한다)
  입력은 README «1» 표의 열 그대로 — s72g_first = m7M7DisclosureGateFirst · s72g_frequent = m7M7DisclosureGateFrequent · s72g_closed = m7M7DisclosureGateClosed · 넷 다 «띄운다».
  크기는 넷 다 390×844(= kGoldenPhoneSize · 그 상수는 고치지 않는다) · 찍기 전 위치 전제(README «2») — s72g_* = s72g-back 의 아래 끝 < 844 · 안전 상태 = 행 0.
  golden README «1» 의 만드는 명령은 세 파일을 적었다 — 이 카드는 `s72g_golden_test.dart` 하나만 ·
    기존 PNG 는 README 의 18 이 아니라 22(카드가 이긴다).
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s72g_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 8장만 ??
  위치 전제가 실패하면(본문이 844 를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md)
🔴 새 파일을 만들지 않는다 — 파일이 이미 있다.
· S7-2G_questions.md — 머리말의 «다음 번호»에서 이어 붙인다. 이 카드의 질문(R10a 가 만든 공용 위젯을 쓰다 생긴 질문 포함)은 전부 여기에.
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 권고와 다르게 지은 이름 · 3개 밖에 새로 더한 정적 라벨 · 골든 위치 전제의 실제 dy(종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리에 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 3개 · 읽지 않는 필드 목록(규칙 5) · 「돌아가기」 = AppNavActions.back · 접수 실패 때 진입 안 함 ·
  접수증이면 상태 불문 진입 · 첫 요청 값 · 탐색 본문이 껍데기(값이 와도 스켈레톤)인 것 · 기간 선택 없음 · 골든 이름·높이 ·
  재량인 것(내부 위젯 DisclosureGateView 등의 생성자 모양 · 여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  melos.bat run format:fix
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git status --short
     ← test/golden/goldens/ 에서: s71_*·s73_*·s73b_*·s71b_*.png 의 M = 금지(git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로) · 새 PNG 는 8장뿐 ·
        test/golden/chart_probe*.dart · reference/** · README.md 의 M = 금지 · R10a 파일(report_archive_screen·analytics_skeleton·analytics_error_view·report_archive_view_test·s71b_golden_test)의 M = 금지
  git add packages/ui_analytics docs/ai-context/inbox
  git commit -m "[M7] R10b (4) format·질문 파일"   ← 고친 것이 있을 때만
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push -u origin ui/m7-s72g-gate
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M7] S7-2G 열람 게이트 + 수익률 탐색 화면 합성
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(S7-2G) + 탐색 화면 합성(PerformanceExploreScreen · 탐색 본문은 껍데기 — 본문 전부는 R10c)
   ② 자체 점검 12항 — prompt_M7.md 154~168행 원문 12항 글자 그대로 복사(위 보고 규칙) · 코드에 실제로 있는 것만 [x] · 위 «정적» 줄의 grep 결과 ·
      4번 = [x] + 괄호 «인터스티셜·열람 기록 = 이 PR · 격리 위치(라우트·진입점) = 셸 몫» · 5·6·7·8·12 와 10 앞절 = [x] + 괄호 «이 카드 범위 밖»(7·8 = 탐색 본문 R10c) ·
      9번 = [x] + 괄호 «as-of 는 게이트 카드 안 1줄 · 오래됨 배너 = StaleBanner · 탐색 본문의 as-of = R10c» ·
      11번 = [x] + 괄호 «git grep -nE '\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b' -- lib 결과 N건» · 10번 뒷절(픽스처·골든 스냅샷) = [x] + 괄호 «git status 의 기존 PNG M 0 · domain_contracts 변경 0» ·
      «정적» 줄은 항목마다 명령 1줄 + 결과 1줄(빠진 항목 = 보고 불일치 = 반려)
   ③ 스크린샷 서술 — 로딩·열림·닫힘·접수 실패·차단 최소 4 + 골든 표(8장: 이름·입력 픽스처·크기·위치 전제 · PNG 를 열어 배치·잘림만 · 못 본 것은 «미열람»)
   ④ 질문 표(새 행 번호·요지) ⑤ 추측한 것(없으면 «없음»)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s72g-gate` 푸시 1건 · 커밋 3~4개(본문 (1)~(3) + format·질문 파일).
- `lib/` 새 파일 3(`screens/performance_explore_screen.dart` · `screens/explore/disclosure_gate_view.dart` · `screens/explore/performance_explore_body.dart`(껍데기)) · 수정 3(`providers/analytics_providers.dart` 끝에 추가 · `l10n/labels.dart` 3개 · `ui_analytics.dart` export 1줄). 기존 화면 4·위젯 5(R10a 의 `report_archive_screen`·`analytics_skeleton`·`analytics_error_view` 포함)는 바뀌지 않는 것이 정상.
- `test/` 새 파일 1(`performance_explore_gate_test.dart`) + 도우미 1(`explore_fakes.dart` — R10c 가 더하기만 하므로 이 카드에서 만든다) + 골든 테스트 1(`test/golden/s72g_golden_test.dart`) + 새 PNG 8장. 하네스·본보기·기존 PNG 22장(`s71_*`·`s73_*`·`s73b_*`·`s71b_*`)은 불변.
- 질문 파일 1개(`S7-2G_questions.md` — 새 행이 있을 때만 바뀜) · 채팅: PR 본문 5섹션.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R10b-Bob-S72G 결과: 브랜치 ui/m7-s72g-gate 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R10b-Bob-S72G 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R10b-Bob-S72G 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s71_*`·`s73_*`·`s73b_*`·`s71b_*`)가 `M`, 또는 R10a 파일(`report_archive_screen`·`analytics_skeleton`·`analytics_error_view`·그 테스트)이 `M` ② `pubspec.yaml` 변경(차트 패키지 = C-3) ③ `test/golden/chart_probe*.dart`·`reference/**` 가 `M` ④ 게이트에 「다시 보지 않기」·스킵, 또는 통과를 전역에 기억 ⑤ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now` ⑥ `value` 를 읽거나 숫자를 글자로 만드는 코드(`toStringAsFixed`) — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **추가만** 하므로 초록이 정상입니다(빨간색이면 기존 PNG 를 건드린 것).
- 계약 테스트 C-36 ⑦⑧(차트·탐색 파일의 `value` 참조 · 숫자 포맷)은 Bob 브랜치가 들어와야 실제 파일을 봅니다 — 병합 검사 때 Claude 가 그 위에서 돌립니다(이 카드의 `lib/src/screens/performance_explore_screen.dart` 와 `lib/src/screens/explore/` 두 파일 — 셋 다 대상 · 게이트 화면에서도 AsyncValue 의 `.value` 금지(valueOrNull · when)).
- 「돌아가기」는 셸(R13)이 생기기 전까지 실제로 화면을 닫지 못합니다 — 지금은 «`AppNavActions.back` 을 넘겼다»까지만 증명합니다(01 §8 미결 62).
- 범위 고지: 🔵 R10b 병합 뒤 `main` 의 탐색 본문은 값이 와도 스켈레톤입니다(껍데기 — 본문은 R10c) · 라우트·진입점(셸 M8)이 아직 없어 사용자에게 보이지 않습니다. 「주」 주기 · 기간 선택 · 웹 2열·툴팁 · 차트 탭 읽기 · 절단선은 R10 에 없습니다(01 §8 미결 54·55·58·61). S7-1 A13 «값 열 오른쪽 정렬»은 R11 부록 후보입니다(미결 63).
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 🔴 **파일 이름 주의** — `R10a-Bob-S71b.md`(끝난 앞 카드) · `R10c-Bob-S72.md`(다음 카드) · 통합 패킷 `R10-Bob-S7x.md`(3장으로 대체) · 같은 M7 의 끝난 카드(`_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md`) · M6 의 끝난 카드 `R2b-Bob-J3.md` 를 붙여넣지 않습니다.
- 드라이런 실측(통합 패킷 2026-09-29 · 3차 · 참고): 이 카드 몫 새 테스트 = 게이트 20 · 골든 8 · 맨 아래 위젯의 아래 끝 = `s72g_*` 196~272 — 높이 844 에 여유가 있습니다. 3분할 드라이런(R10a 위 · 이 카드 본문만): flutter test 139(기존 111 + 새 28 = 게이트 20 · 골든 8) · 새 PNG 8 · 기존 22장 불변 · 변이 6개 잡힘 · dy 196~272. Bob 의 수가 이보다 적다고 반려는 아닙니다(최소 목록의 번호가 기준).
- 그 밖의 공통 알림은 R10a 패킷 «5» 참고.
