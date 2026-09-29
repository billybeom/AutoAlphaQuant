# 발송 패킷 R10a-Bob-S71b — S7-1b 리포트 아카이브 + 공용 위젯 2개 (계약 v1.3 · R10 3장 중 1번째)

> ✅ 선행 병합(계약 v1.3 PR #14 `e820042` · R2b PR #13 `b59a5e1`) — 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 보이면 보냅니다.
> **R10 3장 중 1번째 · 한 번에 카드 1장 · 순서 a → b → c**(R10a `S7-1b` 아카이브 → R10b `S7-2G` 열람 게이트 → R10c `S7-2` 수익률 탐색 · 뒤 카드는 앞 카드가 병합된 뒤에 보냅니다).
> 만든 날 2026-09-29(3분할판 — 발주자 결정 「3장으로 쪼개는 안으로 바꿔주세요」 · 원본 = 통합 패킷 v5 `send/R10-Bob-S7x.md`(origin/main `86168d4` · 검증 4회) · 문장·코드·테스트 문장은 v5 그대로 옮기고 카드 경계에 맞춰 번호·수·가리킴만 고쳤다) · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R10 행 · 조문 = `01_…` §13 머리 · §13-8 · §11-1 · `03_…` §4 의 R10 범위 블록 · golden README «🆕 R10(계약 v1.3)» 절의 `s71b` 두 행.
> 사전 조건 — ✅ 계약 v1.3 병합(M2 PR #14 · squash `e820042` · 2026-09-29) · ✅ R2b-Bob-J3 병합(PR #13 squash `b59a5e1` · 2026-09-29). 병합 확인은 본문 0단계의 확인 줄로(해시 없이 내용으로 확인한다 · R2b 는 계약 v1.3 의 조상이다 — contractVersion 1.3.0 줄이 함께 확인한다).
> 카드 확정값(카드 권한): 정적 라벨 **0개**(재시도는 기존 `retryButton`) · 위젯·프로바이더·Key·파일 이름(본문 «주입 구조») · 골든 2이름 **4장** · 규칙 요약 15항 · 덮어쓰기 14항.
> 🔴 **올리는 순서(Claude)** — 이 패킷(과 R10b·R10c 패킷) + `rounds.md` + `send/README.md` 를 **같은 푸시**로 `main` 에(질문 파일 `inbox/S7-1b_questions.md` 는 `86168d4` 로 이미 `main` 에 있고, 그 머리말과 `prompt_M7.md` 치환값은 같은 푸시에서 세 장 기준으로 바꾼다). 0단계의 `ls` 줄이 그 증명이다. 통합판 `R10-Bob-S7x.md` 는 보내지 않는다(3분할로 대체).
> 드라이런: 통합 패킷 드라이런(v3 본문 · flutter test 223)의 이 카드 몫 = 아카이브 11 + 골든 4(A10 은 3분할에서 더했다 — 통합 드라이런 수(아카이브 11) 밖).
> 3분할 드라이런(2026-09-29 · 새 worktree · 이 카드 본문만): flutter test 111 통과(기존 95 + 새 16 = A1~A10 12 · 골든 4) · 새 PNG 4 · 기존 18장 불변 · 변이 4개 잡힘(정적 줄 포함) · 골든 dy s71b_list 1330 · s71b_empty 104.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 치환값은 R10 세 장을 함께 적은 것) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다.
> 🔴 Bob **새 대화** 전제 · Bob 은 `ui_analytics` 가 처음입니다 — 0단계·규칙 요약·본받지 않는 것·코드 틀을 본문에 담았습니다.

## 0. 한 줄 목적

지난 월간 리포트 목록(`S7-1b`)을 «숫자 없이 · 받은 순서 그대로» 계약 v1.3 그대로 만들고, 뒤 두 카드(R10b 게이트 · R10c 탐색)가 함께 쓸 공용 위젯 2개(스켈레톤 · 에러)를 먼저 깔기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s71b-archive`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **선행은 모두 끝났습니다** — 계약 v1.3(PR #14)과 R2b-Bob-J3(PR #13) 둘 다 `main` 에 병합됐습니다. Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
   🔴 단 이 패킷이 GitHub `main` 에 올라간 뒤에 보냅니다(0단계가 `main` 에서 이 파일과 질문 파일을 찾습니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다.
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R10a-Bob-S71b.md`** 에서 엽니다(Bob 폴더는 옛 브랜치에 있어 이 파일이 안 보일 수 있습니다 · 그 폴더가 아직 최신 `main` 을 받지 않았으면 `C:\Work\AAQ-claude-r10\docs\ai-context\send\R10a-Bob-S71b.md` 나 GitHub 의 `main` 에서 · 그 폴더의 파일은 푸시 전에도 보입니다 — 보낼지는 GitHub `main` 에 있는지로 판단).
4. 붙여넣을 것은 «3» 본문 **전부**(«R10a-Bob-S71b — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 M7 의 끝난 카드 `_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md` 와 헷갈리지 않습니다. `send/` 바로 아래에 `R2b-Bob-J3.md` 가 아직 보여도 그것은 **끝난 카드**입니다(병합됨 PR #13) — 붙여넣지 않습니다. `R10-Bob-S7x.md`(통합판 — 3분할로 대체)도 붙여넣지 않습니다. `R10b-Bob-S72G.md`·`R10c-Bob-S72.md` 는 **뒤 카드**입니다 — 이 카드가 병합된 뒤 차례로 보냅니다.

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R10a-Bob-S71b — 범위: S7-1b 월간 리포트 아카이브(ReportArchiveScreen · reportArchiveProvider) · 공용 위젯 2개(AnalyticsSkeleton · AnalyticsErrorView —
  뒤 카드 R10b(S7-2G 열람 게이트)·R10c(S7-2 수익률 탐색)가 이 두 위젯을 그대로 쓴다). R10 3장 중 1번째 카드입니다.
하지 않는 것: S7-1·S7-3·S7-3b 기존 화면 수정(S7-1 A13 «값 열 오른쪽 정렬» 포함 — R11 부록 후보(미결 63)) · 정렬·필터 옵션 · 부분 동기 · 애니메이션 ·
  셸 몫(라우트 등록·라우터 가드·「더 보기」 진입점 — M8) ·
  R10b 몫 = S7-2G 열람 게이트 · PerformanceExploreScreen · analyticsCommandApiProvider · disclosureGateProvider · PerfSeriesQuery · performanceSeriesProvider · 정적 라벨 3개 ·
  R10c 몫 = S7-2 탐색 본문(토글·차트 3파일·값 표·고지·이동 버튼) · 정적 라벨 13개. (뒤 카드 몫은 이 브랜치에서 미리 만들지 않는다.)
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 14항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R2b(ui/m6-j3-complete · 병합됨)가 아닙니다. ui/m6-* 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
이 카드는 R10 3장 중 1번째(R10a)입니다 — 통합판 R10-Bob-S7x 가 아닙니다.
지금 코드에는 lib/src/screens/report_archive_screen.dart · lib/src/widgets/analytics_skeleton.dart 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-j3-complete 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s71b-archive origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.3.0'" -- packages/domain_contracts/lib/src/contract_version.dart     ← «…contract_version.dart:1»(계약 v1.3 병합)
  ls docs/ai-context/send/R10a-Bob-S71b.md                                                              ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/domain_contracts/fixtures/m7/m7_report_archive_empty.json                                 ← 보여야 함
  ls docs/ai-context/inbox/S7-1b_questions.md                                                           ← 보여야 함(빈 표가 이미 있다)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      위 ls 줄과 contractVersion 줄 중 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 줄은 반대다 — 🔴 출력이 없어야(없음이) 정상(무언가 찍히면 이미 만들어진 것 — 잘못된 카드 · 멈추고 알림):
  git grep -c "AnalyticsSkeleton" -- packages/ui_analytics                                              ← 출력이 없어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.3 새 타입(PerfAxisTick …)과 새 필드의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §13 > 03 §4 의 R10 범위 블록 > 03 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox(S7-1b_questions.md) 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml(차트 패키지 추가 = C-3 실패) · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·reference/**·s71_golden_test·s73_golden_test·README ·
   goldens/s71_*.png · s73_*.png · s73b_*.png(기존 18장) ·
   기존 화면 3파일(monthly_report·drawdown_context·contribution)·기존 위젯 3파일(stale_banner·safety_block_banner·trust_badge_view)·
   기존 테스트 4파일(contribution_view·drawdown_context_view·monthly_report_view + 자리표시 ui_analytics_test — 지우지도 고치지도 않는다).
   🔴 기존 PNG 18장 중 하나라도 M 이면 되돌리고 멈춤 · 예외 없음.
 2 03 본문의 구 초안(§4 「진입」·「데이터」·「컴포넌트」·「상태」·「모의」 줄과 그림 M7-8)은 03 §4 의 R10 범위 블록(머리글 «🆕 계약 v1.3 — `S7-1b` R10 범위»)과 01 §13-8 에 집니다.
   01 §13 머리·§13-13 의 «카드 1장»·«카드 3분할 기각», 질문 파일 머리말의 «R10-Bob-S7x» 는 발주자 결정(2026-09-29 3분할) 전의 글이다 — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(이 카드의 공개 위젯 1개 ReportArchiveScreen 의 생성자에는 key 뿐 — 내부 위젯은 콜백을 가져도 된다).
   이 카드는 고정 라우트 상수를 쓰지 않는다 — 행의 링크는 row.route 그대로(AppRoutes.reportMonthly 에 값을 끼우지 않는다).
 4 값 = DTO 의 *Text·*Label·*Line·label·headline 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(double·int·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값의 부호로 색을 고르지 않음 · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
 5 읽지 않는 필드(카드가 정함 — 질문 아님): ReportArchiveRow.yyyyMm 은 Key 에만(글자로 찍지 않는다).
 6 이 카드의 화면에는 산술이 없다(정규값을 받는 차트는 R10c 몫). 최솟값·최댓값·합·차·누적곱·이동평균 · 숫자를 글자로(toStringAsFixed·NumberFormat) ·
   행 수를 글자로 — 전부 금지. 목록을 거르지도 세지도 정렬하지도 묶지도 않는다.
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에는 열거형 switch 가 없다(generated 는 bool → 아이콘 모양 하나).
 8 시계 = analyticsClockProvider(DateTime.now() 금지). 이 카드에서 쓰는 자리는 StaleBanner 하나(기존 위젯이 한다).
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = 마지막 성공 asOf.label(없으면 null) + AnalyticsLabels.retryButton + ref.invalidate ·
   오래됨 = StaleBanner(asOf:) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(기존 화면과 같다 — 값이 온 뒤에만).
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible(이 카드가 배치에 적은 짧은 글자 —
   아카이브 행의 모드 칩 — 는 예외 · 적힌 대로 짓는다) · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지 ·
   390px overflow 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
10 주입 프로바이더만 throw 기본값(데이터 프로바이더는 throw 금지) · 이름·타입은 아래 «주입 구조» 고정 · 새 프로바이더는 analytics_providers.dart 에(타입 명시) ·
   오프너는 탭 콜백 안에서 ref.read — build 에서 read 금지.
   🔴 새 데이터 프로바이더(reportArchiveProvider)는 autoDispose(기존 3개를 본뜨지 않는다).
11 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처 행에서) · 링크는 RecordingLinkOpener 를 픽스처 값과 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'A3 not-generated row: reason shown, no link').
12 골든 = 이 카드의 새 PNG 4장만 · --update-goldens 는 새 테스트 파일 하나(s71b_golden_test.dart)를 지정(폴더 지정 금지) · golden:approved 는 안 붙임 · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이).
13 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)).
14 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: ratio · aspectRatio · devicePixelRatio · duration · durationSec · iteration · decoration · syntax. 글자 잇기는 보간 '${a}${b}'.
15 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
🔴 보고 규칙(R2 재제출 교훈) — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다
   (글자는 테스트 글꼴이라 네모). 자체 점검 ② 는 prompt_M7.md 154~168행 **12항** 원문 번호 그대로. 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 14항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 9~11행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변) ② 12~13행 라우트 상수 딥링크 → DTO 링크(row.route)를 AppLinkOpener.open 에 · 이 카드에 고정 상수 없음(규칙 3)
 ③ 38~41행 자리표시자 → 링크 null = 부재 ④ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ⑤ 88행 «자체 점검 10항» → 154~168행 12항(이 카드 밖 4·5·6·7·8·12 와 10 앞절은 [x] + 괄호 — 괄호 글자는 «■ 제출» ②)
 ⑥ 88~89행 스크린샷 4장 → 서술 + 골든 표(«제출» ③) ⑦ 87~88행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅)
 ⑧ 97~99행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 이 화면의 타입은 코드에 확정 ⑨ 102~106행 역할 문단 → 범위 = 이 카드의 화면 1개(S7-1b) + 공용 위젯 2개 · 폰 세로 하나
 ⑩ 109~114행 «읽을 문서 5개» → 아래 «먼저 읽을 것» ⑪ 116행 브랜치 형식 → ui/m7-s71b-archive
 ⑫ 153행 «명세 §12와 1:1» → 무시
 ⑬ 118~120행 «① 격리된 위치 ② 인터스티셜 ③ 열람 기록을 전부» → 이 카드에는 셋 다 없다 — ② 게이트와 ③ recordDisclosureView 는 R10b 몫 · ① 격리 위치(라우트·진입점)는 셸(M8) ·
    «월간 리포트에 열람 횟수 표기»는 S7-1(이미 병합)
 ⑭ 107·116행 «이번 과제 범위»·PR 제목 → prompt_M7.md 의 `{{범위}}` 와 PR 제목 치환값은 R10 세 장을 함께 적은 것이다 — 이 카드의 범위·PR 제목은 카드 머리가 정한다
 (93~94행 «기존 스냅샷을 다시 찍는 것은 위조»는 그대로 유효 — 이 카드에는 예외가 없다.)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문 ② 01 §13 머리(«무엇»~«판정 기록») + §13-8(아카이브) + §11-1(링크 4조)
 ③ 03 §4 의 R10 범위 블록 — 머리글 «🆕 계약 v1.3 — `S7-1b` R10 범위»(찾는 말 = «R10 범위(» ·
    §4 「모의」 줄 바로 아래 · 그림 앞 — 그림과 위쪽 본문은 «구 초안»이라 블록이 이긴다)
 ④ packages/domain_contracts/lib/ — src/dto/performance.dart 의 ReportArchiveVm·ReportArchiveRow ·
    src/repositories/performance_repository.dart(reportArchive) · src/navigation/app_links.dart(규칙 4조) ·
    testing.dart(UnimplementedPerformanceRepository · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R10(계약 v1.3)» 절의 «1» 표 중 s71b 두 행 · «2» 높이와 위치 전제 + «규칙»·«하네스» 절
    (그 절의 나머지 — s72g_*·s72_* 골든 · chart_probe · 본보기 3파일 — 는 R10b·R10c 몫이라 읽지 않아도 된다)
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 ·
    lib/src/screens/contribution_screen.dart(화면 틀의 본보기 — 틀만 본다) · lib/src/screens/monthly_report_screen.dart 의 「지난 리포트」 버튼과 «링크 있는 항목에만 버튼» 자리 ·
    lib/src/widgets/stale_banner.dart · safety_block_banner.dart · test/monthly_report_view_test.dart(가짜 = extends 받침대 · 링크 기록기) · test/golden/s71_golden_test.dart · test/golden/golden_support.dart
 ⑦ packages/domain_contracts/fixtures/README.md 의 v1.3 절 + 이 카드가 쓰는 픽스처 2건 + 안전 상태 1건(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · 질문 파일 S7-1b_questions.md 의 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → 새 화면은 AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton)
 · analytics_providers.dart 의 비-autoDispose family 3개 → 새 것은 autoDispose
 · 테스트의 class … implements SafetyRepository · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · _pump 도우미를 만들어 쓴다
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s71b-…)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsLabels.retryButton · staleBannerTitle.
· 🆕 lib/src/providers/analytics_providers.dart 끝에 더한다(기존 줄은 고치지 않는다):
    final AutoDisposeFutureProvider<ReportArchiveVm> reportArchiveProvider =
        FutureProvider.autoDispose<ReportArchiveVm>((ref) {
          return ref.watch(performanceRepositoryProvider).reportArchive();
        });
  (R10b 가 이 아래에 프로바이더를 더 붙인다 — 이 카드는 이 하나만.)
· 🆕 파일(전부 packages/ui_analytics/lib/src/ 아래):
    widgets/analytics_skeleton.dart     const AnalyticsSkeleton({super.key, this.blocks = 4})   — Column 회색 상자(높이 72 · colorScheme.surfaceContainerHighest)
                                        🔴 스크롤 없음(ListView 안에 들어간다)
    widgets/analytics_error_view.dart   const AnalyticsErrorView({super.key, required this.onRetry, this.lastAsOfLabel})   — (있으면) 라벨 → 아이콘 → FilledButton(AnalyticsLabels.retryButton)
    screens/report_archive_screen.dart          const ReportArchiveScreen({super.key})          — ConsumerWidget · 공개
  🔴 두 공용 위젯의 생성자 모양은 위 그대로 — 뒤 카드(R10b 는 AnalyticsSkeleton(blocks: 2·3) · R10c 는 blocks: 3 · 두 카드의 AnalyticsErrorView)가 이 모양으로 부른다.
· 배럴 lib/ui_analytics.dart = 머리 주석 유지 + export **1줄만** 추가: 'src/screens/report_archive_screen.dart'.
  🔴 export 는 알파벳 순서다(directives_ordering · --fatal-infos) — report_archive_screen 은 맨 끝 줄(monthly_report_screen 다음).
  🔴 analytics_skeleton · analytics_error_view 는 export 하지 않는다. 테스트는 package:ui_analytics/src/… 로 직접 import.

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / listFixture / fixtureEnvelope)
 아카이브  m7M7ReportArchive18(최신 달부터 18행 · 머리글 3 · 미생성 2 · 모의 3 — 링크 있는 행 13) · m7M7ReportArchiveEmpty(rows 0 + emptyLabel)
           🔴 읽는 법 = singleFixture(…, ReportArchiveVm.fromJson) — 봉투는 1행이고 그 안의 rows 가 18이다(listFixture 로 열면 깨진다)
 안전      SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상 · 3 차단 2건 · 4 무결성
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(서로 다른 날의 그림이다). 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 — S7-1b ReportArchiveScreen (03 §4 블록 · 01 §13-8)
 build: ref.watch(reportArchiveProvider) + ref.watch(safetyStateStreamProvider) → activeFlags = safety.valueOrNull?.activeFlags ?? const <BlockFlag>[].
 배치: Column[ StaleBanner(asOf: vm.asOf) , SafetyBlockBanner(activeFlags:, onOpenLink: 오프너로 open) , Expanded(ListView(padding 16)[ asOf 줄 , 행 … ]) ]
       행은 children 안에서 for (final row in vm.rows) 로 늘어놓는다(ListView.builder·itemCount 를 쓰지 않는다 — 이 파일에 .length 0).
 상태: 로딩 = ListView(padding 16)[ AnalyticsSkeleton() ] / 에러 = ListView(padding 16)[ AnalyticsErrorView(onRetry: () => ref.invalidate(reportArchiveProvider),
       lastAsOfLabel: 마지막 성공 asOf.label — 없으면 null) ] — 로딩·에러에서는 배너를 그리지 않는다 /
       빈 = vm.emptyLabel != null 이면 asOf 줄 아래에 Text(emptyLabel)(Key s71b-empty) · 행은 받은 대로(0 개면 0 개) · null 이면 글자 없음(폴백 금지) / 차단 = 배너만.
 🔴 빈 상태를 고르는 식은 emptyLabel 하나다 — rows 의 isEmpty·isNotEmpty·length 로 갈래를 고르지 않는다(이 파일에 그 셋 0 — 아래 «정적» 줄).
    (03 §4 블록 ⓕ 와 같은 말이다 — 빈 목록에는 엔진이 반드시 emptyLabel 을 싣는다 · C-34)
 행(받은 순서 그대로):
   row.sectionLabel != null 이면 그 행 **앞에** Text(sectionLabel)(Key s71b-section-<yyyyMm>)
     🔴 앞 행과 비교하지 않는다 · 자르지 않는다
   Card → Row[ 아이콘(generated ? Icons.description_outlined : Icons.remove_circle_outline) , Expanded(Column[ Text(label) , reasonLabel != null 이면 Text(reasonLabel) ]) ,
               Chip(label: Text(modeLabel)) , route != null 이면 Icon(Icons.chevron_right) ]
   route != null 일 때만 InkWell(onTap: () => ref.read(analyticsLinkOpenerProvider).open(row.route!)).
   🔴 reasonLabel 은 generated 로 고르지 않는다(모의 달은 generated true 인데 사유가 온다) · modeLabel 을 다른 글자와 비교하지 않는다(전 행 같은 모양의 칩) ·
      AppRoutes.reportMonthly 에 값을 끼우지 않는다 · yyyyMm 을 글자로 찍지 않는다.
 Key: s71b-asof · s71b-section-<yyyyMm> · s71b-row-<yyyyMm>(ValueKey<String>) · s71b-mode-<yyyyMm> · s71b-reason-<yyyyMm> · s71b-empty.
      다는 자리 = row 는 행 전체(Card) · mode 는 Chip · asof·section·reason·empty 는 그 Text.

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R10a (1) 공용 위젯·프로바이더») · 테스트는 그 단계 커밋에 함께
 (1) 공용 위젯 2개(AnalyticsSkeleton · AnalyticsErrorView) + reportArchiveProvider(기존 화면·위젯 무변경 — 시작할 때의 flutter test(기존 95건)가 그대로 통과).
 (2) S7-1b ReportArchiveScreen + 배럴 export 1줄(report_archive_screen = 맨 끝 줄) + test/report_archive_view_test.dart(A1~A10).
 (3) 골든 4장 — test/golden/s71b_golden_test.dart.
 (4) format:fix · 질문 파일 · 정적 검사.

■ 정적 라벨 — 이 카드는 0개(기준 = lib/l10n/labels.dart 무변경 — 더하면 질문 파일에 · 재시도 = 기존 AnalyticsLabels.retryButton · 오래됨 = 기존 staleBannerTitle).
   뒤 카드가 더한다(R10b 3개 · R10c 13개) — 이 카드에서 미리 만들지 않는다.
   🔴 만들지 않는 글자(엔진 몫): «아직 발행된 리포트가 없습니다» · 연도·월 이름.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용)
공통: ProviderScope 는 MaterialApp 위(_pump 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future/Stream ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서
  (이 카드의 던지는 가짜는 AsyncError 로 잡혀 보고되지 않는다 — takeException 을 쓰지 않는다).
S7-1b — test/report_archive_view_test.dart
 A1 18행 Key 전부 있음 · 행의 세로 자리(dy)가 픽스처 순번대로 커진다(화면이 뒤집지 않았다).
 A2 전 행의 label·modeLabel 글자가 픽스처와 같다(find.descendant(of: 행 Key, matching: find.text(…))).
 A3 미생성 행(generated false)을 누른다 → 그 행 안에서(find.descendant(of: 행 Key, matching: find.text(reasonLabel))) 1 · opener.opened 비어 있음 · 그 행에 Icons.chevron_right 0.
    (같은 사유 글자가 다른 행에도 있다 — 화면 전체에서 find.text 로 세면 1 이 아니다)
 A4 링크 있는 행을 누른다 → opener.opened == <String>[row.route!].
 A5 모의 행(generated true · route null)을 누른다 → opened 비어 있음 · 그 행 안에서 reasonLabel 1(generated 로 고르지 않았다는 증명).
 A6 빈 픽스처 → emptyLabel 글자 1 · 행 Key 0 · retryButton 0.
 A7 끝나지 않는 Future → AnalyticsSkeleton 1 / 던지는 가짜 → retryButton 1 → 누른다 → reportArchive 호출 2회 ·
    둘 다 안전 상태 행 3 으로 띄운다 → 로딩·에러에서는 그 플래그 label 글자 0(배너는 값이 온 뒤에만 — 값이 오면 보인다는 것은 A8 이 본다).
 A8 시계 +3일 → staleBannerTitle 1(신선하면 0) / safetyStates 행 3 → 그 플래그 label 글자 각 1(플래그 2개 · label 이 서로 다르다).
 A9 머리글 — section_label 이 있는 행 수(픽스처에서 센다: rows.where((r) => r.sectionLabel != null))만큼 s71b-section-* · 글자 그대로 · 머리글의 dy < 그 행의 dy < 다음 행의 dy.
 A10 File('lib/ui_analytics.dart') 의 export 줄에 src/screens/report_archive_screen.dart 1 · 기존 다섯 줄(l10n/labels.dart · src/providers/analytics_providers.dart ·
     src/screens/contribution_screen.dart · src/screens/drawdown_context_screen.dart · src/screens/monthly_report_screen.dart)도 각 1(그대로 있다) ·
     analytics_skeleton·analytics_error_view·explore/·chart/·perf_chart 를 담은 export 줄 0(예 'A10 barrel keeps its exports and hides internals').
     (집합 완전 일치는 R10b 의 G13 한 곳만 본다 — 뒤 카드가 export 를 더해도 A10 은 깨지지 않는다.)
(정적 — PR 본문 ② 에 결과를 적는다) packages/ui_analytics 에서 git grep 으로:
  lib 에 CommandState 0 · Navigator 0 · DateTime.now 0 · kIsWeb·Platform. 0 · 'aaq:// 0 · toStringAsFixed 0 · GestureDetector 0 ·
  머티리얼 색 상수 Colors 는 기존 파일에만(새 파일 0 — git grep -nw Colors -- lib 로 센다) ·
  lib/src/screens/report_archive_screen.dart 에 substring·startsWith·split·isEmpty·isNotEmpty·.length 0 · «.rows» 는 행을 도는 for 1곳뿐 · modeLabel 은 Text 에 넘기는 1곳뿐(비교 0) ·
  lib/src/providers 에 autoDispose 1(대소문자 구분 — -i 로 세면 타입 이름까지 2) · lib/ui_analytics.dart 에 explore/·chart/·perf_chart·analytics_skeleton·analytics_error_view 0.
  🔴 autoDispose 는 주석도 센다 — lib/src/providers 의 주석에 autoDispose 라는 말을 쓰지 않는다.
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 목록 뒤집기 · reasonLabel 을 generated 로 고르기 · 아카이브 로딩·에러에 배너 그리기.
   («머리글을 글자 비교로 만들기»와 «빈 상태를 rows.isEmpty 로 고르기»는 테스트가 아니라 위 «정적» 줄로 본다 — 이 픽스처에서는 그림이 같아진다.)

■ 골든 — 2이름 × light/dark = 4장(전부 신규 · golden README R10 «1»·«2» 표 그대로 · 그 표의 나머지 10이름 s72g_*·s72_* 는 R10b·R10c 몫)
  s71b_list(390×1700) · s71b_empty(390×844)
  높이는 테스트 파일 안 상수로 pumpForGolden(…, logicalSize:) 에 · 찍기 전 위치 전제(README «2») — s71b_list = 끝 행 < 1700 · s71b_empty = s71b-empty 의 아래 끝 < 844 · 안전 상태 = 행 0.
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s71b_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 4장만 ??
  (README «1» 의 명령은 세 파일을 적었다 — 나머지 둘(s72g_golden_test · s72_golden_test)은 R10b·R10c 가 만든다. 이 카드는 위 한 파일만.)
  위치 전제가 실패하면(본문이 1700·844 를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다)
· S7-1b_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 공용 위젯의 질문도 여기에. (S7-2G·S7-2 파일은 뒤 카드 몫 — 건드리지 않는다.)
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 권고와 다르게 지은 이름 · 새로 더한 정적 라벨(이 카드는 0개가 기준) · 골든 위치 전제의 실제 dy · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 0개 · 읽지 않는 필드(규칙 5) · 골든 이름·높이 ·
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
     ← test/golden/goldens/ 에서: s71_*·s73_*·s73b_*.png 의 M = 금지(git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로) · 새 PNG 는 4장뿐 ·
        test/golden/chart_probe*.dart · reference/** · README.md 의 M = 금지
  git add packages/ui_analytics docs/ai-context/inbox
  git commit -m "[M7] R10a (4) format·질문 파일"   ← 고친 것이 있을 때만
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push -u origin ui/m7-s71b-archive
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M7] S7-1b 리포트 아카이브 + 공용 스켈레톤·에러 뷰
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(S7-1b) + 공용 위젯 2(AnalyticsSkeleton · AnalyticsErrorView)
   ② 자체 점검 12항 — prompt_M7.md 154~168행 원문 번호 그대로 · 코드에 실제로 있는 것만 [x] · 위 «정적» 줄의 grep 결과 ·
      4번 = [x] + 괄호 «이 카드 범위 밖 — 인터스티셜·열람 기록 = R10b · 격리 위치(라우트·진입점) = 셸 몫» ·
      7·8번 = [x] + 괄호 «이 카드 범위 밖 — 결측 공백·고지 문구 = R10c» · 5·6·12 와 10 앞절 = [x] + 괄호 «이 카드 범위 밖» ·
      9번 = [x] + 괄호 «as-of 는 목록 위 1줄 · 오래됨 배너 = StaleBanner»
   ③ 스크린샷 서술 — 로딩·정상·빈·차단 최소 4 + 골든 표(4장: 이름·입력 픽스처·크기·위치 전제 · PNG 를 열어 배치·잘림만 · 못 본 것은 «미열람»)
   ④ 질문 표(새 행 번호·요지) ⑤ 추측한 것(없으면 «없음»)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s71b-archive` 푸시 1건 · 커밋 3~4개(본문 (1)~(3) + format·질문 파일).
- `lib/` 새 파일 3(`widgets/analytics_skeleton.dart` · `widgets/analytics_error_view.dart` · `screens/report_archive_screen.dart`) · 수정 2(`providers/analytics_providers.dart` 끝에 `reportArchiveProvider` 추가 · `ui_analytics.dart` export 1줄). `l10n/labels.dart` 는 바뀌지 않는 것이 정상(정적 라벨 0개) · 기존 화면 3·위젯 3도 바뀌지 않는 것이 정상.
- `test/` 새 파일 1(`report_archive_view_test.dart` — A1~A10) + 골든 테스트 1(`golden/s71b_golden_test.dart`) + 새 PNG 4장(`s71b_list`·`s71b_empty` × light/dark). 하네스·본보기·기존 PNG 18장은 불변.
- 질문 파일 1개(`S7-1b_questions.md` — 새 행이 있을 때만 바뀜) · 채팅: PR 본문 5섹션.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R10a-Bob-S71b 결과: 브랜치 ui/m7-s71b-archive 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R10a-Bob-S71b 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R10a-Bob-S71b 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s71_*`·`s73_*`·`s73b_*`)가 `M` ② `pubspec.yaml` 변경 ③ 아카이브 행에 숫자·색·스파크라인, 또는 목록을 뒤집거나 묶는 코드, 또는 머리글을 `sectionLabel` 이 아니라 앞 행과 비교해 만드는 코드 ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now` ⑤ 숫자를 글자로 만드는 코드(`toStringAsFixed`) — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **추가만** 하므로 초록이 정상입니다(빨간색이면 기존 PNG 를 건드린 것).
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 🔴 **파일 이름 주의** — 같은 M7 의 끝난 카드(`_완료/R1b-Gem-S71.md`·`_완료/R2-Gem-S73.md`)와 M6 의 끝난 카드 `R2b-Bob-J3.md`, 통합판 `R10-Bob-S7x.md` 를 붙여넣지 않습니다. `R10b-Bob-S72G.md`·`R10c-Bob-S72.md` 는 이 카드가 병합된 뒤 차례로 보냅니다.
- 드라이런 실측(참고): 통합 패킷 드라이런(2026-09-29 · 3차 · v3 본문 · flutter test 223)의 이 카드 몫 = 새 테스트 15건(아카이브 11 · 골든 4 · A10 은 3분할에서 더했다 — 통합 드라이런 수(아카이브 11) 밖) · 맨 아래 위젯의 아래 끝 = `s71b_list` 1330 · `s71b_empty` 104 — 높이 1700·844 에 여유가 있습니다.
  3분할 드라이런(2026-09-29 · 새 worktree · 이 카드 본문만): flutter test 111 통과(기존 95 + 새 16 = A1~A10 12 · 골든 4) · 새 PNG 4 · 기존 18장 불변 · 변이 4개 잡힘(정적 줄 포함) · 골든 dy s71b_list 1330 · s71b_empty 104.
  Bob 의 수가 이보다 적다고 반려는 아닙니다(최소 목록의 번호가 기준).
- 범위 고지: S7-1 A13 «값 열 오른쪽 정렬»은 R11 부록 후보입니다(미결 63). 게이트(`S7-2G`)·탐색(`S7-2`)은 R10b·R10c 에서 차례로 옵니다 · 웹 사이드바 진입·「더 보기」 진입점은 셸(R13).
- 🔵 **발주자에게 알릴 것 7건**(01 §13-13 · 결정 요청 아님 — 이의가 있으면 되돌림 · R10 세 장 전체에 대한 것이라 이 카드에만 싣고 R10b·R10c 는 이 절을 가리킵니다): ① 계약이 1.2.0 → **1.3.0** 으로 오른다 ② 「주」 주기는 이번에 빠진다(일·월·년) ③ 기간 고르기는 이번에 없다(엔진 기본 구간 · 무엇이 그려졌는지는 글자로 나온다) ④ 열람 기록이 접수되지 않으면 수익률 화면이 **열리지 않는다**(오프라인은 실패가 아니라 접수) ⑤ 접수증이 오면 상태가 무엇이든(거부 포함) 화면은 열린다 — 기록 상태 1줄이 맨 위에 늘 보인다 ⑥ 첫 화면은 **월간 · 누적 · 시간가중**이다 ⑦ 숫자는 「값 보기」를 눌러야 표로 보인다(기본은 접힘).
