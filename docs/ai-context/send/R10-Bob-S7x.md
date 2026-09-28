# 발송 패킷 R10-Bob-S7x — S7-1b 아카이브 · S7-2G 열람 게이트 · S7-2 수익률 탐색 (계약 v1.3)

> ⏸ **아직 보내지 않습니다 — 보내는 때는 아래 «2»의 두 조건이 다 찬 뒤입니다**(계약 v1.3 병합 + R2b-Bob-J3 병합 · 한 번에 카드 1장).
> 만든 날 2026-09-29 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R10 행 · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-09-28_R10선행_계약v1.3_설계서.md` §2 Δ6 + §3 «4. 화면 구성»·«5. 증명 계획» · 조문 = `01_…` §13(13-1~13-14) · `03_…` §4·§5·§6 «🆕 계약 v1.3 — R10 범위» 블록 · golden README «🆕 R10(계약 v1.3)» 절.
> 사전 조건 — ⬜ 계약 v1.3 병합(M2 PR · 로컬 브랜치 `m2/contract-v1.3` — 「푸시해」 뒤 PR 번호·해시를 여기에 채움) · ⬜ R2b-Bob-J3 병합. 병합 확인은 본문 0단계의 확인 줄로(해시 없이 내용으로 확인한다).
> 카드 확정값(카드 권한): 정적 라벨 16개(본문 «정적 라벨») · 위젯·프로바이더·Key·파일 이름(본문 «주입 구조») · 골든 12이름 24장.
> 🔴 **올리는 순서(Claude)** — ① M2 PR 병합 ② 이 패킷 + `prompt_M7.md` 범위·PR 제목 치환 + `rounds.md` + `send/README.md` + 질문 파일 3개(빈 머리말)를 **같은 푸시**로 `main` 에. 0단계의 `ls` 줄이 그 증명이다.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 `ui_analytics` 가 처음입니다 — 0단계·규칙 요약·본받지 않는 것·코드 틀을 본문에 담았습니다.

## 0. 한 줄 목적

수익률을 «격리된 자리에서 · 마찰을 거쳐 · 기록을 남기고» 보게 하는 세 화면(지난 리포트 목록 · 열람 게이트 · 수익률 탐색 차트)을 계약 v1.3 그대로 만들기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s71b-archive`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **두 조건이 다 찬 뒤에 보냅니다** — ⓐ 계약 v1.3 이 `main` 에 병합됐다(Claude 에게 「푸시해」 → PR → 「병합해」) ⓑ R2b-Bob-J3 가 병합됐다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다.
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R10-Bob-S7x.md`** 에서 엽니다(Bob 폴더는 옛 브랜치에 있어 이 파일이 안 보일 수 있습니다).
4. 붙여넣을 것은 «3» 본문 **전부**(«R10-Bob-S7x — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 M7 의 끝난 카드 `_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md` 와 헷갈리지 않습니다. `send/` 바로 아래에 패킷이 두 장 있으면(`R2b-Bob-J3.md` 가 아직 있으면) **R2b 가 먼저**입니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R10-Bob-S7x — 범위: S7-1b 월간 리포트 아카이브(ReportArchiveScreen) · S7-2G 열람 게이트 + S7-2 수익률 탐색(공개 위젯 1개 PerformanceExploreScreen —
  언제나 게이트로 시작하고 통과하면 같은 위젯 안에서 탐색 본문으로 바뀐다) · 공용 위젯 2개(스켈레톤·에러) · 차트 3파일(본보기를 글자 그대로 옮김).
하지 않는 것: S7-1·S7-3·S7-3b 기존 화면 수정(S7-1 A13 «값 열 오른쪽 정렬» 포함 — 다음 카드) · 웹 2열·통계 패널·툴팁·하단 시트·차트 탭 읽기·선택 표시 · 기간 선택 UI ·
  «주» 주기 · afterTax · 「이전 기록 보기」 토글 · 절단선 · 「월 1회 권장」 문구 · 부분 동기 · 애니메이션 · 셸 몫(라우트 등록·라우터 가드·「더 보기」 진입점·실제 닫기 동작 — M8).
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 15항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R2b(ui/m6-j3-complete · 병합됨)가 아닙니다. ui/m6-* 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/screens/report_archive_screen.dart · lib/src/screens/performance_explore_screen.dart · analyticsCommandApiProvider · AnalyticsLabels.gateBackButton 이 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-j3-complete 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← «[deleted] … origin/ui/m6-j3-complete» 줄은 정상
  git checkout --no-track -b ui/m7-s71b-archive origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.3.0'" -- packages/domain_contracts/lib/src/contract_version.dart     ← «…contract_version.dart:1»(계약 v1.3 병합)
  ls docs/ai-context/send/R10-Bob-S7x.md                                                                ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/ui_analytics/test/golden/chart_probe.dart packages/ui_analytics/test/golden/reference/chart/perf_chart_painter.dart   ← 두 줄
  ls packages/domain_contracts/fixtures/m7/m7_disclosure_view_receipts_4.json packages/domain_contracts/fixtures/m7/m7_perf_monthly_sim_split.json   ← 두 줄
  ls packages/ui_journal/lib/src/journal_read.dart                                                      ← 보여야 R2b 가 병합된 것입니다
  ls docs/ai-context/inbox/S7-1b_questions.md docs/ai-context/inbox/S7-2G_questions.md docs/ai-context/inbox/S7-2_questions.md      ← 세 줄(빈 표가 이미 있다)
     (하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.3 새 타입(PerfAxisTick …)과 새 필드의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·chart_probe) > 이 카드(지시) > 01 §13 > 03 «계약 v1.3 — R10 범위» 블록 > 03 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml(차트 패키지 추가 = C-3 실패) · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·reference/**·s71_golden_test·s73_golden_test·README ·
   goldens/s71_*.png · s73_*.png · s73b_*.png(기존 18장 — 하나라도 M 이면 되돌리고 멈춤 · 예외 없음) ·
   기존 화면 3파일(monthly_report·drawdown_context·contribution)·기존 위젯 3파일(stale_banner·safety_block_banner·trust_badge_view)·기존 테스트 3파일.
 2 03 본문의 구 초안(§4·§5·§6 「데이터」·「컴포넌트」·「상태」·「모의」 줄과 그림 M7-8~M7-12)은 03 «계약 v1.3 — R10 범위» 블록과 01 §13 에 집니다.
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(공개 위젯 2개의 생성자에는 key 뿐 — 내부 위젯은 콜백을 가져도 된다).
   R10 의 세 화면이 쓰는 고정 상수는 셋뿐: AppNavActions.back(「돌아가기」) · AppRoutes.performanceDrawdown · AppRoutes.performanceContribution.
 4 값 = DTO 의 *Text·*Label·*Line·label·headline 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(double·int·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값의 부호로 색을 고르지 않음 · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
 5 읽지 않는 필드(카드가 정함 — 질문 아님): PerfPoint.value · gapReasonCode · date / PerfSegment.from · to / PerformanceSeries.metric · granularity · cumulative(되돌아온 요청 인자) · afterTax /
   PerfDisclosure.interstitialText · viewCountThisMonth / DisclosureGateVm.route / ReportArchiveRow.yyyyMm 은 Key 에만.
   🔴 PerfPoint.value 는 C-36 ⑦ 이 빌드를 깬다 — 차트·탐색 파일에 «.value»(괄호가 바로 오는 Future.value( 와 valueOrNull 은 통과)나 PerfPoint(:value) 패턴 분해가 있으면 실패.
      그 파일들에서는 MapEntry 의 .value 도 쓰지 않는다(패턴 분해 (k, v) 로).
 6 화면 산술은 «엔진이 준 0.0~1.0 정규값 × 폭·높이» 하나뿐(차트 3파일 안에 이미 있다). 최솟값·최댓값·합·차·누적곱·이동평균 · 정규값이나 value 를 글자로(toStringAsFixed·NumberFormat — C-36 ⑧) ·
   결측 보간·직전 값 유지·0 대입 · 점·행 수를 글자로 — 전부 금지. 목록을 거르지도 세지도 정렬하지도 묶지도 않는다.
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에서 열거형 switch 는 차트 3파일의 SegmentKind 뿐이다 — 🔴 CommandState 로 갈래·문구를 고르지 않는다(lib 에 CommandState 0건) · rejectReasonCode 를 읽지 않는다.
 8 시계 = analyticsClockProvider(DateTime.now() 금지). 쓰는 자리는 둘: ① StaleBanner(기존 위젯이 한다) ② DisclosureViewEvent.viewedAt. 머문 시간을 재지 않는다.
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = 마지막 성공 asOf.label + AnalyticsLabels.retryButton + ref.invalidate · 오래됨 = StaleBanner(asOf:) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다).
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지(차트 눈금 글자만 예외 — 본보기 그대로) ·
   390px overflow 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
10 주입 프로바이더만 throw 기본값(데이터 프로바이더는 throw 금지) · 이름·타입은 아래 «주입 구조» 고정 · 새 프로바이더는 analytics_providers.dart 에(타입 명시) ·
   오프너·CommandApi·시계는 탭 콜백 안에서 ref.read — build 에서 read 금지. 🔴 새 데이터 프로바이더 3개는 전부 autoDispose(기존 3개를 본뜨지 않는다 — 본뜨면 월→일→월에서 호출이 0).
11 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO·CommandReceipt 를 지어 넣지 않는다(픽스처 행에서 — 예외는 기하 단위 테스트 U2 하나) · 링크는 RecordingLinkOpener 를 픽스처 값·상수와 비교.
12 차트의 증명 = test/golden/chart_probe.dart 의 expect* 네 함수만(M2 소유 · 기대값은 픽스처에서 하네스가 계산한다). 차트 단언을 직접 짜지 않는다. 골든은 보조.
13 골든 = 이 카드의 새 PNG 24장만 · --update-goldens 는 새 테스트 파일 셋을 지정(폴더 지정 금지) · golden:approved 는 안 붙임 · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이).
14 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)).
15 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: ratio · aspectRatio · devicePixelRatio · duration · durationSec · iteration · decoration · syntax. 글자 잇기는 보간 '${a}${b}'.
16 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
🔴 보고 규칙(R2 재제출 교훈) — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모). 자체 점검 ② 는 prompt_M7.md 154~168행 **12항** 원문 번호 그대로. 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 9~11행 «의존 … 추가하려면 먼저 질문» → 추가 없음(차트는 CustomPaint · pubspec 불변) ② 12~13행 라우트 상수 딥링크 → DTO 링크를 AppLinkOpener.open 에 · 고정 상수는 규칙 3 의 셋뿐
 ③ 14~16행 DateTime.now() 금지 → 그대로 + 주입 시계의 둘째 자리 = viewedAt(01 §13-6) ④ 19~21행 «산술 입력은 0.0~1.0 정규값» → 그대로 유효(그래서 PerfPoint.value 를 읽지 않는다)
 ⑤ 31~32행 C-6(PerformanceSeries 참조 = 실패) → 그 검사의 대상은 홈·알림·셸이다 · S7-2 는 PerformanceSeries 를 쓰는 화면이다 ⑥ 38~41행 자리표시자 → 링크 null = 부재
 ⑦ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9) ⑧ 88행 «자체 점검 10항» → 154~168행 12항(이 카드 밖 5·6·12 와 10 앞절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑨ 88~89행 스크린샷 4장 → 서술 + 골든 표(«제출» ③) ⑩ 87~88행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅)
 ⑪ 97~99행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 세 화면의 타입은 코드에 확정 ⑫ 102~106행 역할 문단 → 범위 = 이 카드의 세 화면 · 폰 세로 하나
 ⑬ 109~114행 «읽을 문서 5개» → 아래 «먼저 읽을 것» ⑭ 116행 브랜치 형식 → ui/m7-s71b-archive
 ⑮ 123~125행 기간 프리셋 → 이 카드에는 기간 선택이 없다(DateRange·ConfigRepository 가 나오지 않는다) · 150행 «주 … 미정 시 비활성» → 선택지 자체가 없다 · 153행 «명세 §12와 1:1» → 무시
 (93~94행 «기존 스냅샷을 다시 찍는 것은 위조»는 그대로 유효 — 이 카드에는 예외가 없다.)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문 ② 01 §13 전체(13-1~13-14 — 특히 13-2 허용·금지 표와 층 표 · 13-5 · 13-6 · 13-8) + §4-2 «Future 에러 = 접수 실패» + §12-3(접수 실패 1줄 5원칙) + §11-1(링크 4조)
 ③ 03 §4·§5·§6 의 «🆕 계약 v1.3 — R10 범위» 블록 3개(각 절 「모의」 줄 바로 아래 · 그림 앞 — 그림과 위쪽 본문은 «구 초안»이라 블록이 이긴다)
 ④ packages/domain_contracts/lib/ — src/dto/performance.dart 의 PerformanceSeries·PerfPoint·PerfSegment·PerfAxisTick·BenchmarkSeries·PerfDisclosure·ReportArchiveVm·ReportArchiveRow·DisclosureGateVm ·
    src/repositories/performance_repository.dart(series · reportArchive · watchDisclosureGate) · src/commands/payloads.dart(DisclosureViewEvent) · src/commands/command_api.dart(recordDisclosureView · watchCommand) ·
    src/commands/command_receipt.dart · src/labels/disclosure_codes.dart · src/navigation/app_links.dart(규칙 4조 · AppNavActions · performanceDrawdown·performanceContribution) ·
    testing.dart(UnimplementedPerformanceRepository · UnimplementedCommandApi · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R10(계약 v1.3)» 절 전부(골든 표 · 위치 전제 · chart_probe 쓰는 법 · 본보기 3파일 옮기는 법) + «규칙»·«하네스» 절
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 ·
    lib/src/screens/contribution_screen.dart(화면 틀의 가장 짧은 본보기 — 틀만 본다) · lib/src/screens/monthly_report_screen.dart 의 「지난 리포트」 버튼과 «링크 있는 항목에만 버튼» 자리 ·
    lib/src/widgets/stale_banner.dart · safety_block_banner.dart · test/monthly_report_view_test.dart(가짜 = extends 받침대 · 링크 기록기) · test/golden/s71_golden_test.dart · test/golden/golden_support.dart ·
    test/golden/reference/ 의 세 파일(옮길 코드) · test/golden/chart_probe_test.dart 머리(하네스를 부르는 모양)
 ⑦ packages/domain_contracts/fixtures/README.md 의 v1.3 절 + 이 카드가 쓰는 픽스처 15건(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · 새 질문 파일 3개의 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → 새 화면은 AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton)
 · analytics_providers.dart 의 비-autoDispose family 3개 → 새 것은 autoDispose
 · 테스트의 class … implements SafetyRepository · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · _pump 도우미를 만들어 쓴다
 · 패키지 README·pubspec 주석의 «차트 라이브러리» 이야기 → 차트는 CustomPaint(의존 3개 고정)
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s71b-… · s72g-… · s72-…)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsLabels.retryButton · staleBannerTitle.
· 🆕 lib/src/providers/analytics_providers.dart 끝에 더한다(기존 줄은 고치지 않는다):
    final Provider<CommandApi> analyticsCommandApiProvider = Provider<CommandApi>((ref) {
      throw UnimplementedError('analyticsCommandApiProvider must be overridden');
    });
    final AutoDisposeFutureProvider<ReportArchiveVm> reportArchiveProvider =
        FutureProvider.autoDispose<ReportArchiveVm>((ref) {
          return ref.watch(performanceRepositoryProvider).reportArchive();
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
· 🆕 파일(전부 packages/ui_analytics/lib/src/ 아래):
    widgets/analytics_skeleton.dart     const AnalyticsSkeleton({super.key, this.blocks = 4})   — Column 회색 상자(높이 72 · colorScheme.surfaceContainerHighest) · 🔴 스크롤 없음(ListView 안에 들어간다)
    widgets/analytics_error_view.dart   const AnalyticsErrorView({super.key, required this.onRetry, this.lastAsOfLabel})   — (있으면) 라벨 → 아이콘 → FilledButton(AnalyticsLabels.retryButton)
    screens/report_archive_screen.dart          const ReportArchiveScreen({super.key})          — ConsumerWidget · 공개
    screens/performance_explore_screen.dart     const PerformanceExploreScreen({super.key})     — ConsumerStatefulWidget · 공개
    screens/explore/disclosure_gate_view.dart   DisclosureGateView(내부 — 게이트 그림)
    screens/explore/performance_explore_body.dart   PerformanceExploreBody({super.key, required this.receipt})(내부 — 탐색 본문)
    chart/perf_chart_geometry.dart · chart/perf_chart_painter.dart · widgets/perf_chart.dart   — 본보기 3파일을 글자 그대로
· 배럴 lib/ui_analytics.dart = 머리 주석 유지 + export **2줄만** 추가: 'src/screens/report_archive_screen.dart' · 'src/screens/performance_explore_screen.dart'.
  🔴 explore/ · chart/ · perf_chart · analytics_skeleton · analytics_error_view 는 export 하지 않는다. 테스트는 package:ui_analytics/src/… 로 직접 import.

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / listFixture / fixtureEnvelope)
 아카이브  m7M7ReportArchive18(18행 · 최신 달부터 · 머리글 3 · 미생성 2 · 모의 3 — 링크 있는 행 13) · m7M7ReportArchiveEmpty(rows 0 + emptyLabel)
 게이트    m7M7DisclosureGate(열림 · 마찰 줄 있음) · m7M7DisclosureGateFirst(열림 · frictionLine 없음) · m7M7DisclosureGateFrequent(열림) · m7M7DisclosureGateClosed(gateOpen false · route 없음)
 접수증    m7M7DisclosureViewReceipts4 — listFixture(…, CommandReceipt.fromJson).rows · 🔴 행 순서 = 뜻: 0 REQUESTED · 1 EXECUTED · 2 EXPIRED · 3 HELD_FOR_INTEGRITY(거부 행은 없다)
 성과      performance24m(🔴 2행 — listFixture(…).rows[0] = 시간가중 · rows[1] = 금액가중 · singleFixture 는 던진다) · m7M7PerfDailyGap · m7M7PerfMonthlySimSplit · m7M7PerfDailyManual ·
           m7M7PerfMonthlyPeriod · m7M7PerfYearly · m7M7PerfUnavailableGap(points 0 + unavailableLabel) · m7M7PerfMaskedIntegrity(같은 모양 — 차단 가림)
 안전      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상 · 3 차단 2건 · 4 무결성
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(서로 다른 날의 그림이다). 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 1 — S7-1b ReportArchiveScreen (03 §4 블록 · 01 §13-8)
 build: ref.watch(reportArchiveProvider) + ref.watch(safetyStateStreamProvider) → activeFlags = safety.valueOrNull?.activeFlags ?? const <BlockFlag>[].
 배치: Column[ StaleBanner(asOf: vm.asOf) , SafetyBlockBanner(activeFlags:, onOpenLink: 오프너로 open) , Expanded(ListView(padding 16)[ asOf 줄 , 행 … ]) ]
 상태: 로딩 = AnalyticsSkeleton() / 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(reportArchiveProvider), lastAsOfLabel: 마지막 성공 asOf.label) /
       빈(rows 0) = 배너 · asOf 줄 · emptyLabel(null 이면 글자 없음 — 폴백 금지) / 차단 = 배너만.
 행(받은 순서 그대로):
   row.sectionLabel != null 이면 그 행 **앞에** Text(sectionLabel)(Key s71b-section-<yyyyMm>) — 🔴 앞 행과 비교하지 않는다 · 자르지 않는다
   Card → Row[ 아이콘(generated ? Icons.description_outlined : Icons.remove_circle_outline) , Expanded(Column[ Text(label) , reasonLabel != null 이면 Text(reasonLabel) ]) ,
               Chip(label: Text(modeLabel)) , route != null 이면 Icon(Icons.chevron_right) ]
   route != null 일 때만 InkWell(onTap: () => ref.read(analyticsLinkOpenerProvider).open(row.route!)).
   🔴 reasonLabel 은 generated 로 고르지 않는다(모의 달은 generated true 인데 사유가 온다) · modeLabel 을 다른 글자와 비교하지 않는다(전 행 같은 모양의 칩) ·
      AppRoutes.reportMonthly 에 값을 끼우지 않는다 · yyyyMm 을 글자로 찍지 않는다.
 Key: s71b-asof · s71b-section-<yyyyMm> · s71b-row-<yyyyMm>(ValueKey<String>) · s71b-mode-<yyyyMm> · s71b-reason-<yyyyMm> · s71b-empty.

■ 화면 2 — PerformanceExploreScreen = S7-2G 게이트 → S7-2 탐색 (03 §5·§6 블록 · 01 §13-5·§13-6)
 State: CommandReceipt? _receipt(null = 아직 게이트) · bool _submitting · bool _notAccepted.
 build: _receipt == null 이면 게이트, 아니면 PerformanceExploreBody(receipt: _receipt!).
 🔴 통과 사실은 이 State 에만 둔다 — 전역 프로바이더·정적 변수·세션 캐시 금지(위젯이 새로 만들어지면 언제나 게이트부터).
 🔴 performanceSeriesProvider 는 PerformanceExploreBody 안에서만 watch 한다(통과 전 series 호출 0).

 게이트 상태 표 (그리는 것 / 「돌아가기」 / 「그래도 보기」 / 1줄)
  로딩(첫 값 전)          AnalyticsSkeleton(blocks: 2)            / 있음 / 없음 / —
  스트림 에러              AnalyticsErrorView(재시도 = ref.invalidate(disclosureGateProvider)) / 있음 / 없음 / —
  열림(gateOpen true)     카드: headline · viewCountText · frictionLine(있을 때) · asOf.label / 있음 / 있음(활성) / —
  닫힘(gateOpen false)    같은 카드                                 / 있음 / 없음(부재 — 비활성 아님) / —
  제출 중                  같은 카드                                 / 있음(눌린다) / 있음(비활성) / 직전 1줄은 제출 시작 때 사라짐
  접수 실패(Future 에러)   같은 카드                                 / 있음 / 있음(활성 — 다시 누르면 새 명령) / AnalyticsLabels.recordNotAccepted(버튼 줄 바로 위 · colorScheme.error)
  접수증 도착(상태 불문)   → 탐색 본문으로 바뀜(거부·만료·보류여도 들어간다)
  오래됨·차단              카드 위에 StaleBanner(asOf: vm.asOf) · SafetyBlockBanner — 들여보낼지는 gateOpen 이 말한다(화면이 플래그로 판정하지 않는다)
 배치: Column[ StaleBanner , SafetyBlockBanner , Expanded(ListView(padding 16)[ 카드 , (접수 실패 1줄) ,
        Row[ Expanded(FilledButton 「돌아가기」) , SizedBox(width: 12) , Expanded(OutlinedButton 「그래도 보기」) ] ]) ]   ← 두 버튼은 같은 줄·같은 크기(동급 배치)
 「돌아가기」 = ref.read(analyticsLinkOpenerProvider).open(AppNavActions.back) · 명령 0건 · 로딩·에러·제출 중에도 항상 있고 눌린다.
 Key: s72g-card · s72g-headline · s72g-count · s72g-friction · s72g-asof · s72g-back · s72g-continue · s72g-record-not-accepted.

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

 탐색 본문 PerformanceExploreBody
  State: PerfSeriesQuery _query(첫 값 = (metric: PerfMetric.twr, granularity: PerfGranularity.monthly, cumulative: true)) · bool _valuesOpen(첫 값 false) ·
         CommandReceipt _shown(첫 값 = widget.receipt) · StreamSubscription<CommandReceipt>? _subscription.
  기록 줄 구독(initState): _subscription = ref.read(analyticsCommandApiProvider).watchCommand(widget.receipt.commandId).listen(
         (next) { if (mounted) setState(() => _shown = next); },
         onError: (Object error, StackTrace stack) { FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'ui_analytics')); });   ← 에러면 마지막 글자 유지
       dispose 에서 _subscription?.cancel(). 🔴 StreamProvider 로 감싸지 않는다(에러가 삼켜진다).
  배치(위 → 아래):
    0 기록 줄 Text(_shown.stateLabel)                                   Key s72-record-line     ← 항상 · 상태로 고르지 않는다
    1 SafetyBlockBanner(있을 때)
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    2 토글 3줄 SegmentedButton(showSelectedIcon: false)                 Key s72-toggle-metric · s72-toggle-granularity · s72-toggle-cumulative
        지표 2칸(PerfMetric.twr · mwr) · 주기 3칸(daily · monthly · yearly — 🔴 weekly 칸이 없다) · 누적 2칸(true · false)
        누르면 setState(() => _query = (…그 칸만 바꾼 새 레코드…)) — 재요청은 프로바이더 열쇠가 바뀌어 저절로 일어난다.
    3 series = ref.watch(performanceSeriesProvider(_query))
        로딩(첫 요청·재요청) = 토글 아래 AnalyticsSkeleton(blocks: 3) / 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(performanceSeriesProvider(_query)), lastAsOfLabel: null)
    4 StaleBanner(asOf: series.asOf)
    5 Text(series.asOf.label) · Text(series.periodLabel)                Key s72-asof · s72-period
    6 PerfChart(series: series)                                          안쪽 CustomPaint Key s72-chart · 눈금 글자 s72-tick-<순번>(본보기가 이미 단다)
    7 x 양 끝 글자 Row(spaceBetween)[ Flexible(Text(points.first.dateText)) , Flexible(Text(points.last.dateText)) ]      Key s72-x-first · s72-x-last
    8 범례 — 견본 선 + Expanded(Text(series.seriesLabel)) / (benchmark != null) 견본 점선 + Expanded(Text(benchmark.label))   Key s72-legend-main · s72-legend-benchmark
    9 구간 캡션 — kind != SegmentKind.measured 인 구간마다 Text(seg.label)                                                Key s72-segment-caption-<순번>
   10 고지 카드 — sampleSizeLine · honestExpectationLine · drawdownCaveatLine(있을 때)                                   Key s72-disclosure
   11 (benchmark != null) Text(benchmark.compositionNote)                                                               Key s72-benchmark-note
   12 「값 보기」/「값 접기」 TextButton + (펴졌을 때) 값 표                                                               Key s72-values-toggle · s72-values-table · 행 s72-value-row-<순번>
        표 = 머리 1줄(AnalyticsLabels.valuesColumnMain · benchmark != null 이면 valuesColumnBenchmark) + 점마다 1줄(받은 순서 · Column — 점은 많아야 60개)
        행 = Row[ Expanded(Text(point.dateText)) , Text(point.valueText) , (benchmark != null) Text(benchmark.points[i].valueText) ] — 결측 점도 행이 있다(엔진 글자)
        토글을 바꿔도 _valuesOpen 은 그대로다.
   13 이동 버튼 2개 — OutlinedButton 「낙폭 맥락 보기」 = open(AppRoutes.performanceDrawdown) · 「슬리브 기여 보기」 = open(AppRoutes.performanceContribution)   Key s72-link-drawdown · s72-link-contribution
  불가(series.unavailableLabel != null): 6·7·8·9·11·12 를 그리지 않고 그 자리에 불가 카드 Text(unavailableLabel)(Key s72-unavailable) — 0~5·10·13 은 그린다.
    🔴 points.isEmpty·every(null) 로 상태를 고르지 않는다 — 고르는 것은 unavailableLabel 하나다.
  구간 캡션의 kind 비교(9)는 if (seg.kind != SegmentKind.measured) 하나다(switch 아님 · 글자는 seg.label 그대로).

■ 차트 — 본보기 3파일을 글자 그대로 옮긴다 (golden README R10 «4»)
  packages/ui_analytics 에서:
    mkdir -p lib/src/chart
    cp test/golden/reference/chart/perf_chart_geometry.dart lib/src/chart/
    cp test/golden/reference/chart/perf_chart_painter.dart  lib/src/chart/
    cp test/golden/reference/widgets/perf_chart.dart        lib/src/widgets/
    diff -r test/golden/reference/chart lib/src/chart && diff test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart   ← 차이 0 이어야 한다(병합 검사가 본다)
  🔴 옮긴 파일을 고치지 않는다(이름·색·굵기·층 순서·여백 — 하네스와 맞물린 계약이다). 고치고 싶으면 질문 파일에. 본보기 원본은 지우지 않는다.
  차트 상자 = PerfChart(series:) 하나. 바깥 여백은 ListView 의 padding 이 준다(차트 안쪽에 여백을 더하지 않는다).

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R10 (1) 주입·공용 위젯·라벨») · 테스트는 그 단계 커밋에 함께
 (1) 주입·데이터 프로바이더 4개 + typedef · AnalyticsSkeleton · AnalyticsErrorView · 정적 라벨 16개(기존 화면·위젯 무변경 — flutter test 가 기존 95건 그대로 통과).
 (2) S7-1b ReportArchiveScreen + 배럴 export 1줄 + test/report_archive_view_test.dart(A1~A9).
 (3) PerformanceExploreScreen(게이트 + 합성) + DisclosureGateView + PerformanceExploreBody 의 **껍데기**(기록 줄만) + 배럴 export 1줄 + test/performance_explore_gate_test.dart(G1~G14).
 (4) 차트 3파일 옮기기 + test/perf_chart_geometry_test.dart(U1·U2·U4).
 (5) 탐색 본문 전부(토글·차트·글자·캡션·고지·값 표·불가 카드·이동) + test/performance_explore_view_test.dart(E1~E21 · V1~V3).
 (6) 골든 24장 — test/golden/s71b_golden_test.dart · s72g_golden_test.dart · s72_golden_test.dart.
 (7) format:fix · 질문 파일 · 정적 검사.

■ 정적 라벨 — AnalyticsLabels 끝에 절 주석(// ── 🆕 R10 — S7-1b · S7-2G · S7-2 ──)과 함께 16개(이름·글자 고정):
   gateBackButton = '돌아가기' · gateContinueButton = '그래도 보기' · recordNotAccepted = '열람 기록이 접수되지 않았습니다. 화면은 열리지 않았습니다.'
   metricTwr = '시간가중' · metricMwr = '금액가중' · granularityDaily = '일' · granularityMonthly = '월' · granularityYearly = '년' · cumulativeOn = '누적' · cumulativeOff = '기간별'
   valuesShowButton = '값 보기' · valuesHideButton = '값 접기' · valuesColumnMain = '내 계좌' · valuesColumnBenchmark = '비교 기준'
   drawdownLinkButton = '낙폭 맥락 보기' · contributionLinkButton = '슬리브 기여 보기'
   🔴 만들지 않는 글자(엔진 몫): «기록 대기» · «모의 — 합산 제외» · «수동 집행 구간» · «산출 불가» · «산출 가능한 구간이 없습니다» · «아직 발행된 리포트가 없습니다» · «월 1회 권장» · «주» · 연도·월 이름.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용)
공통: ProviderScope 는 MaterialApp 위(_pump 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future/Stream ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 보고된 에러는 tester.takeException() 으로 단언 ·
  가짜 series() 의 답 = (twr·monthly·true → performance24m 행 0) · (mwr·monthly·true → 행 1) · (twr·daily·true → m7M7PerfDailyGap) · (twr·yearly·true → m7M7PerfYearly) ·
  (twr·monthly·false → m7M7PerfMonthlyPeriod) · 그 밖 = performance24m 행 0(값이 아니라 호출을 본다) — 받은 네 인자(metric·granularity·cumulative·range)를 호출마다 기록.
  토글을 누른 뒤에는 pump 를 한 번 더(autoDispose 가 옛 열쇠를 버릴 틈).
S7-1b — test/report_archive_view_test.dart
 A1 18행 Key 전부 있음 · 행의 세로 자리(dy)가 픽스처 순번대로 커진다(화면이 뒤집지 않았다).
 A2 전 행의 label·modeLabel 글자가 픽스처와 같다(find.descendant(of: 행 Key, matching: find.text(…))).
 A3 미생성 행(generated false)을 누른다 → reasonLabel 1 · opener.opened 비어 있음 · 그 행에 Icons.chevron_right 0.
 A4 링크 있는 행을 누른다 → opener.opened == <String>[row.route!].
 A5 모의 행(generated true · route null)을 누른다 → opened 비어 있음 · reasonLabel 1(generated 로 고르지 않았다는 증명).
 A6 빈 픽스처 → emptyLabel 글자 1 · 행 Key 0 · retryButton 0.
 A7 끝나지 않는 Future → AnalyticsSkeleton 1 / 던지는 가짜 → retryButton 1 → 누른다 → reportArchive 호출 2회.
 A8 시계 +3일 → staleBannerTitle 1(신선하면 0) / safetyStates 행 3 → 그 플래그 label 글자 2.
 A9 머리글 — section_label 이 있는 행 수(픽스처에서 센다: rows.where((r) => r.sectionLabel != null))만큼 s71b-section-* · 글자 그대로 · 머리글의 dy < 그 행의 dy < 다음 행의 dy.
게이트 — test/performance_explore_gate_test.dart
 G1 띄운다(m7M7DisclosureGate) → headline·viewCountText·frictionLine 글자 · 버튼 2 · find.byKey(const Key('s72-chart')) 0 · series 호출 0 · 명령 0.
 G2 「돌아가기」 → opener.opened == <String>[AppNavActions.back] · 명령 0 · series 0.
 G3 「그래도 보기」(명령 = 접수증 행 0) → 명령 1 · event.surfaceCode == DisclosureSurfaceCodes.performanceExplore · event.viewedAt == kGoldenNowUtc · event.durationSec == 0 ·
    s72-record-line 글자 = 행 0 의 stateLabel · series 1 · watchCommand 가 받은 id == 행 0 의 commandId.
 G4 명령을 Completer 로 멈춘다 → 「그래도 보기」 비활성(다시 눌러도 명령 1) · 「돌아가기」는 눌린다(opened 1) ·
    그 뒤 트리를 pumpWidget(const SizedBox()) 로 내리고 Completer 를 끝낸다 → 예외 없음(tester.takeException() == null).
 G5 명령이 던진다 → 게이트 그대로 · s72g-record-not-accepted 1 · takeException 비null · series 0 → 다시 누른다(이번엔 접수증 행 0) → 그 줄 0 · 명령 누계 2 · 탐색 본문.
 G6 첫 접수증을 4행 각각으로(testWidgets 넷) → 전부 탐색 본문(s72-record-line 1) · 글자 = 그 행의 stateLabel.
 G7 watchCommand 가 행 1 을 낸다 → 기록 줄 글자가 행 1 의 stateLabel 로 / watchCommand 가 에러를 낸다 → 마지막 글자 유지 + takeException 비null.
 G8 닫힌 게이트 → s72g-continue 0 · s72g-back 1 · headline 글자 1 · 명령 0.
 G9 첫 열람 게이트 → s72g-friction 0 · viewCountText 글자 1.
 G10 통과 → pumpWidget(const SizedBox()) → 같은 가짜로 다시 띄운다 → 게이트가 다시 보인다(s72g-card 1 · s72-record-line 0) → 다시 통과 → 명령 누계 2.
 G11 게이트 스트림 미방출(add 하지 않은 StreamController) → AnalyticsSkeleton 1 · s72g-back 1 · s72g-continue 0 / 스트림 에러 → retryButton 1 · s72g-back 1 · s72g-continue 0.
 G12 통과한 뒤 게이트 스트림이 새 값(m7M7DisclosureGateClosed)을 낸다 → 탐색 본문 그대로(s72-record-line 1 · s72g-card 0).
 G13 File('lib/ui_analytics.dart') 를 읽는다 → export 줄의 집합이 정확히 { l10n/labels.dart · src/providers/analytics_providers.dart · src/screens/contribution_screen.dart ·
     src/screens/drawdown_context_screen.dart · src/screens/monthly_report_screen.dart · src/screens/report_archive_screen.dart · src/screens/performance_explore_screen.dart }.
 G14 시계 +3일 → staleBannerTitle 1 / safetyStates 행 3 → 배너 글자(게이트 위).
탐색 — test/performance_explore_view_test.dart (E1~E10 은 게이트를 실제로 눌러 들어간다 · E11 부터는 PerformanceExploreBody(receipt: 접수증 행 0) 를 직접 띄워도 된다)
 E1 통과 → series 기록 1건 = (PerfMetric.twr, PerfGranularity.monthly, true, range == null).
 E2 「금액가중」 → 2건 · 마지막의 metric 만 mwr.   E3 「일」 → +1 · granularity daily.   E4 「년」 → +1 · yearly.   E5 「기간별」 → +1 · cumulative false.
 E6 월 → 일 → 월 → 매번 +1(마지막 기록 = monthly · 캐시 적중 0).
 (E7·E17 은 없는 번호다 — 설계에서 뺐다: «이미 고른 칸 다시 누르기»는 증명이 아니고 차트 탭 읽기는 이 카드에 없다.)
 E8 기록 전체에 PerfGranularity.weekly 0 · 주기 칸의 글자 = 일·월·년 3개뿐(find.text 로 셋 · 넷째 없음).
 E9 던지는 가짜 → retryButton → 누른다 → +1 · 같은 인자.
 E10 재요청을 Completer 로 멈춘다 → 토글 3줄 있음 · s72-chart 0 · AnalyticsSkeleton 1.
 E11 성과 픽스처 9건마다(정상 7 시리즈 + 불가 2) → sampleSizeLine·honestExpectationLine 각 1 · drawdownCaveatLine 있으면 1 · find.text(disclosure.interstitialText) 0.
 E12 정상 시리즈 7개마다 → expectMainLineMatches(recordChart(tester), series, chartSchemeOf(tester))   ← 수용 (a) 의 주 증명
 E13 같음 → expectBandsMatch.   E14 같음 → expectBenchmarkMatches · benchmark == null 이면 s72-legend-benchmark 0 · s72-benchmark-note 0.
 E15 같음 → expectTicksMatch · yTicks 의 label 글자 각 1 · 눈금 글자의 오른쪽 끝 ≤ 차트(s72-chart)의 왼쪽 변(tester.getRect).
 E16 측정 아닌 구간의 label 각 1 · 측정 구간의 label(«측정 구간») 0.
 E18 불가 2건 → unavailableLabel 글자 1 · find.byKey(kChartProbeKey) 0(🔴 recordChart 를 부르지 않는다) · s72-tick-* · s72-legend-main · s72-values-toggle 0 · 고지 카드 1 · 이동 버튼 2.
 E19 points.first.dateText · points.last.dateText · periodLabel · seriesLabel · asOf.label 글자 각 1.
 E20 이동 버튼 → opened == <String>[AppRoutes.performanceDrawdown] / <String>[AppRoutes.performanceContribution].
 E21 시계 +3일 → staleBannerTitle 1 / safetyStates 행 3 → 배너.
 V1 기본 접힘 — s72-value-row-* 0 · find.text(AnalyticsLabels.valuesShowButton) 1.
 V2 「값 보기」 → 행 수 = series.points.length · 첫·끝·결측 순번 행의 dateText·valueText 글자 = 픽스처 · 벤치마크가 있으면 같은 순번 valueText 도 · 버튼 글자 = valuesHideButton.
 V3 편 채로 「일」 → 여전히 펴져 있고 행이 새 시리즈(m7M7PerfDailyGap)의 것으로 바뀐다(행 수 = 새 points.length · 첫 행 dateText = 새 points.first.dateText).
기하 — test/perf_chart_geometry_test.dart
 U1 splitRuns(픽스처의 points) 가 아래 표와 같다(표는 M2 가 픽스처에서 뽑았다 — 계약 테스트 C-36 이 같은 픽스처를 지킨다):
      performance24m 행 0·1 → (0,5) (7,23) · 벤치마크 (0,23) / m7M7PerfDailyGap → (0,12) (15,20) / m7M7PerfMonthlySimSplit → (3,17) /
      m7M7PerfDailyManual → (0,20) / m7M7PerfMonthlyPeriod → (0,5) (8,23) · 벤치마크 (0,23) / m7M7PerfYearly → (0,2)
 U2 경계(🔴 이 테스트에 한해 점을 지어도 된다 — 자리 숫자만 · 글자는 ASCII): [] → [] · [null] → [] · [v] → [(0,0)] · [null,v,null] → [(1,1)] · [v,null,null,v] → [(0,0),(3,3)].
 U4 xOf(0)·xOf(1)·yOf(0)·yOf(1) 이 plot 의 네 변 · 범위 밖 값(−0.5 · 1.5)은 변에 붙는다.
(정적 — PR 본문 ② 에 결과를 적는다) packages/ui_analytics 에서 git grep 으로:
  lib 에 CommandState 0 · Navigator 0 · DateTime.now 0 · kIsWeb·Platform. 0 · 'aaq:// 0 · toStringAsFixed 0 · GestureDetector 0 · Colors. 는 기존 파일에만(새 파일 0) ·
  lib/src/screens/explore·lib/src/chart·performance_explore_screen.dart·perf_chart.dart 에 DateRange·ConfigRepository 0 ·
  lib/src/providers 에 autoDispose 3 · lib/ui_analytics.dart 에 explore/·chart/·perf_chart 0.
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 결측을 이어 그림 · 띠 누락 · 세로 뒤집힘 · 통과 전 series 호출 · family 를 비-autoDispose 로 ·
   명령을 두 번 · 에러인데 진입 · vm.route 열기 · 목록 뒤집기 · reasonLabel 을 generated 로 고르기 · 머리글을 글자 비교로 만들기 · 값 표에 value 를 포맷해 찍기.

■ 골든 — 12이름 × light/dark = 24장(전부 신규 · golden README R10 «1»·«2» 표 그대로)
  s71b_list(390×1700) · s71b_empty / s72g_first · s72g_frequent · s72g_closed · s72g_not_accepted(열린 게이트 + 던지는 명령 가짜 · 「그래도 보기」를 1번 누른 뒤) /
  s72_monthly_cum · s72_daily_gap · s72_sim_split · s72_manual_segment · s72_monthly_period · s72_unavailable(각 390×1400 · 게이트를 실제로 눌러 들어간다 · 값 표는 접힌 채)
  높이는 테스트 파일 안 상수로 pumpForGolden(…, logicalSize:) 에 · 찍기 전 위치 전제(README «2»의 두 줄) · 안전 상태 = 행 0.
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s71b_golden_test.dart test/golden/s72g_golden_test.dart test/golden/s72_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 24장만 ??
  위치 전제가 실패하면(본문이 1400 을 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 세 파일이 이미 있다)
· S7-1b_questions.md · S7-2G_questions.md · S7-2_questions.md — 각 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 차트·공용 위젯의 질문은 S7-2 에.
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 권고와 다르게 지은 이름 · 16개 밖에 새로 더한 정적 라벨 · 골든 위치 전제의 실제 dy · 본보기 차트에 고치고 싶은 점 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 16개 · 읽지 않는 필드 목록(규칙 5) · 「돌아가기」 = AppNavActions.back · 접수 실패 때 진입 안 함 ·
  접수증이면 상태 불문 진입 · 첫 요청 값 · «주» 없음 · 기간 선택 없음 · 값 표 기본 접힘 · 골든 이름·높이 · 차트 3파일을 그대로 옮긴 것.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  melos.bat run format:fix
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git status --short
     ← test/golden/goldens/ 에서: s71_*·s73_*·s73b_*.png 의 M = 금지(git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로) · 새 PNG 는 24장뿐 ·
        test/golden/chart_probe*.dart · reference/** · README.md 의 M = 금지
  git add packages/ui_analytics docs/ai-context/inbox
  git commit -m "[M7] R10 (7) format·질문 파일"   ← 고친 것이 있을 때만
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push -u origin ui/m7-s71b-archive
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M7] S7-1b·S7-2G·S7-2 아카이브·열람 게이트·수익률 탐색
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(S7-1b · S7-2G · S7-2) + 공용 위젯 2 + 차트 3파일(diff 0 확인 결과 한 줄)
   ② 자체 점검 12항 — prompt_M7.md 154~168행 원문 번호 그대로 · 코드에 실제로 있는 것만 [x] · 위 «정적» 줄의 grep 결과 ·
      4번 = [x] + 괄호 «인터스티셜·열람 기록 = 이 PR · 격리 위치(라우트·진입점) = 셸 몫» · 5·6·12 와 10 앞절 = [x] + 괄호 «이 카드 범위 밖» ·
      9번 = [x] + 괄호 «as-of 는 화면마다 1줄(게이트는 카드 안) · 오래됨 배너 = StaleBanner»
   ③ 스크린샷 서술 — 로딩·정상·빈·차단 최소 4 + 골든 표(24장: 이름·입력 픽스처·크기·위치 전제 · PNG 를 열어 배치·잘림만 · 못 본 것은 «미열람»)
   ④ 질문 표(새 행 번호·요지) ⑤ 추측한 것(없으면 «없음»)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s71b-archive` 푸시 1건 · 커밋 6~7개(본문 (1)~(6) + format·질문 파일).
- `lib/` 새 파일 9(`screens/report_archive_screen.dart` · `screens/performance_explore_screen.dart` · `screens/explore/disclosure_gate_view.dart` · `screens/explore/performance_explore_body.dart` · `widgets/analytics_skeleton.dart` · `widgets/analytics_error_view.dart` · `chart/perf_chart_geometry.dart` · `chart/perf_chart_painter.dart` · `widgets/perf_chart.dart`) · 수정 3(`providers/analytics_providers.dart` 끝에 추가 · `l10n/labels.dart` 16개 · `ui_analytics.dart` export 2줄). 기존 화면 3·위젯 3은 바뀌지 않는 것이 정상.
- `test/` 새 파일 4(`report_archive_view_test.dart` · `performance_explore_gate_test.dart` · `performance_explore_view_test.dart` · `perf_chart_geometry_test.dart`) + 골든 테스트 3 + 새 PNG 24장. 하네스·본보기·기존 PNG 18장은 불변.
- 질문 파일 3개(새 행이 있을 때만 바뀜) · 채팅: PR 본문 5섹션.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R10-Bob-S7x 결과: 브랜치 ui/m7-s71b-archive 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R10-Bob-S7x 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R10-Bob-S7x 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s71_*`·`s73_*`·`s73b_*`)가 `M` ② `pubspec.yaml` 변경(차트 패키지 = C-3) ③ `test/golden/chart_probe*.dart`·`reference/**` 가 `M`, 또는 `lib/src/chart/` 가 본보기와 다름 ④ 게이트에 「다시 보지 않기」·스킵, 또는 통과를 전역에 기억 ⑤ 아카이브 행에 숫자·색·스파크라인, 또는 목록을 뒤집거나 묶는 코드 ⑥ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now` ⑦ `value` 를 읽거나 숫자를 글자로 만드는 코드(`toStringAsFixed`) — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **추가만** 하므로 초록이 정상입니다(빨간색이면 기존 PNG 를 건드린 것).
- 계약 테스트 C-36 ⑦⑧(차트·탐색 파일의 `value` 참조 · 숫자 포맷)은 Bob 브랜치가 들어와야 실제 파일을 봅니다 — 병합 검사 때 Claude 가 그 위에서 돌립니다.
- 「돌아가기」는 셸(R13)이 생기기 전까지 실제로 화면을 닫지 못합니다 — 지금은 «`AppNavActions.back` 을 넘겼다»까지만 증명합니다(01 §8 미결 62).
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 범위 고지: 「주」 주기 · 기간 선택 · 웹 2열·툴팁 · 차트 탭 읽기 · 절단선은 이 카드에 없습니다(01 §8 미결 54·55·58·61). S7-1 A13 «값 열 오른쪽 정렬»은 R11 부록 후보입니다(미결 63).
