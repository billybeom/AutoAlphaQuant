# 발송 패킷 R14b-Bob-W01 — W-01 워치독 상태 (계약 v1.15 전제 · R14 2장 중 2번째 · M8 · «정확히 N» 소유)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-10-30 조립 · 앱 `rec/r14`) · 선행 = ① R14a 병합(squash `__R14A_SQ__` · 시작 기준 N = R14a 병합본 실측) ② 🔴 계약 v1.15 보강의 워치독 몫(G10 `WatchdogCheck.level` · G11 `m8/watchdog_paused` · `m8/watchdog_empty` · 휴장 표본 정리 · G14 `UnimplementedOpsStatusRepository` — ⬜ 발주자 결정 · ▶ 금지) ③ ⬜ 누적 드라이런(R14a 드라이런 끝 위) ④ ⬜ 발주자 확인 ①~⑨ ⑤ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R14a 브랜치(`ui/m8-n01-alerts`)는 건드리지 않는다.
> 만든 날 2026-10-30 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R14-Bob-M8b` 행(🔀 2분할 — R14a 카드 머리 «재분할 판정») + §3-0 + §3 공통 조문 + 이월 부록 «R14» 대상(R14a 카드 «6» 과 같은 표 · W-01 자리) · 화면 몫 원본 = `04_…` §7(`W-01` · 3분법 + `paused` · 수용 (a)~(e) · 그림 15) · §2-5(뷰어 = 조회) · `01_…` §4-1 `watchWatchdog` · 판독 메모(통합 담당 스크래치 `r14/read_memo.md` §2-3 · §5 G10~G13).
> 사전 조건 — ⬜ R14a 병합(PR `__R14A_PR__` squash `__R14A_SQ__` · `ui_shell` = lib 10파일 · 라벨 35 · 배럴 export 8줄 · 셸 주입 15줄 · PNG 34) · ⬜ 계약 v1.15(R14a 와 같은 보강 PR · 워치독 몫 = 아래 이름표) · ✅ 프롬프트 v2. 시작 기준 = R14a 병합본의 `flutter test`(packages/ui_shell) = **⟦실측: R14a 병합본 — 드라이런 기대 158⟧** · 이 카드 끝 기대 = 시작 기준 N + **23**(뷰 17 + 골든 6) · 끝 = ⟦실측: 드라이런 «+181» 기대⟧.
> 🔀 **재분할 판정** — 카드 계획 = 새 `testWidgets(`·`test(` 줄 **8**(`watchdog_board_test` 7 · 골든 1) · lib ⟦실측: 드라이런 — 추정 +150~210⟧ · 새 PNG **6** · 원천 **1**(`watchWatchdog`) → 임계 안 · 재분할 없음.
> 카드 기본값(⬜ 아래 «발주자 확인» ①~⑨ 가 확정 · 조립 단계 = 권고 = 카드 기본값): ⓐ 위젯 = `WatchdogBoard({super.key})`(`lib/src/watchdog_board.dart` · `ConsumerWidget` — R13a `OpsRhythm` 꼴) ⓑ **셸 파일·R14a 파일은 고치지 않는다** — 셸 연결 = 조립 앱 레지스트리 `AppRoutes.opsWatchdog` 칸(이 카드 밖) ⓒ 원천 = 기존 셸 주입 `shellOpsStatusRepositoryProvider` 의 `watchWatchdog()` 하나(새 주입 0) ⓓ 상태 모양 = `check.level`(`UiLevel` 전수 switch `_checkLook` · v1.15) — `stateCode` 미참조 · 지연(watch) ≠ 실패(blocked) 색 · paused·휴장 = 실패·결측 색 아님 ⓔ 글자 = `label` · `stateLabel` · `lastPingText` · `graceText`(null = 부재) 원문 그대로 — 유예값·개수·이름 리터럴 0 ⓕ 🔴 `slug` = 시크릿급 — 그리지도 · Key 로도 · 로그로도 · 비교로도 쓰지 않는다(Key = 순번만) · ping URL·키 필드 = 계약에 0(04 §7 «뷰모델에 없어야 정상») ⓖ 행 탭 = `check.route`(데이터 · null = 탭 없음 · 🔵 표본 DELAYED 행 route = W-01 자기 자신 — 데이터대로 연다 · 판독 G13) ⓗ 하단 한계 고지 · 머리 «마지막 수신» · `holiday_notice` = 부재(필드 0 · G12) ⓘ 새 lib 파일 1 · 공용 2(배럴 +1 · `test/shell_fakes.dart` 끝 절 — **끝 절 더하기만** · 라벨·주입 0) · 🔴 이 카드가 «정확히 N» 을 **소유**한다(R14 마지막 — 라벨 35 · 배럴 9 · 주입 15 · PNG 40) · Key 접두 `w01-` · 테스트 `test/watchdog_board_test.dart` · 골든 3이름 6장(`test/golden/w01_golden_test.dart` · 크기 = `kGoldenPhoneSize`).
> 🔴 **카드 덮개 필수 문장(04 §7 · prompt_M8 141~144)** — «체크 목록은 서버가 준 것만 — 개수·이름·유예값 리터럴 0 · 받은 차례 그대로» · «상태 = `level` 하나(성공·지연·실패 + 일시정지 · 지연을 실패색으로 칠하지 않는다 · paused·휴장을 실패·결측으로 칠하지 않는다)» · «슬러그·ping URL·키 = 시크릿급 — 화면·Key·로그·PR 어디에도 0 · 슬러그 파싱 0 · `/pause`·`/resume` 버튼 0» · «셸 파일·R13·R14a 테스트·PNG 는 고치지 않는다».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 결정 9c(healthchecks.io) · v1.13 `DiagnosticCell.level` 선례(상태 모양 = `UiLevel`).
> ⬜ **발주자 확인 9건(권고 = 카드 기본값)** — ① 순서 = R14a 병합 뒤(기본 · 공용 파일 «정확히 N» 을 이 카드가 소유) · 대안 = 계약 v1.15 워치독 몫만 먼저 풀리면 이 카드 먼저(그때는 «정확히 N» 을 R14a 로 옮겨 두 카드 재조립) ② 상태 모양 원천 = v1.15 `WatchdogCheck.level: UiLevel`(엔진 매핑 권고 = `OK`→ok · `DELAYED`→watch · `FAILED`→blocked · `PAUSED`→info · 휴장 성공 핑 → ok · 대안 = `WatchdogStateCodes` 상수 + 화면 switch — 코드 리터럴 비교라 비권고) ③ `w01_paused` 입력 = v1.15 `m8/watchdog_paused`(신설 · X1 유지보수 창 문구 · 대안 = 2이름 4장 · `w01_paused` = 01 §8 대기) ④ 휴장 표본 = v1.15 가 `m8/watchdog_holiday` 의 휴장 행을 «휴장 성공 핑»(`PAUSED` → 성공 · level ok · 문구에 휴장)으로 정리(04 §7 «휴장 = 성공 핑» ↔ «paused = 네 번째 상태» 를 가름) · `holiday_notice` 형제 키 = 화면 밖 ⑤ 하단 한계 고지 · 머리 «마지막 수신» = 부재 + 01 §8 미결 신설(대안 = M2 `WatchdogBoardVm{rows, asOf, emptyLabel, holidayNotice?, limitNotice?}` 로 창구 교체) ⑥ 자기 링크 행 = 데이터대로(같은 화면 한 장 더 쌓임 · 01 §8 미결 137 과 같은 뿌리) · v1.15 가 표본 정리(권고 = 그 행 route null) ⑦ 빈 갈래 입력 = v1.15 `m8/watchdog_empty`(신설 · rows 0 · emptyLabel) · `FAILED` 표본 1행 = v1.15 `watchdog_delayed` 에 더함(6행) ⑧ 골든 크기 = `kGoldenPhoneSize` ⑨ 이월 반영(R14a «6» 과 같은 표 · 아래 «6»).
> 드라이런: ⬜ ⟦실측: 누적 드라이런 2번째 — worktree `C:/Work/AAQ-claude-r14dry` · 가지 `dry/r14-2`(R14a 드라이런 끝 = R14a 병합본 흉내) → 권장 4커밋 · 시작 · 끝 · 정적 출력 · 사전검사 · 골든 dy · lib 줄 · 변이 표⟧.
> 프롬프트 = `docs/ai-context/prompt_M8.md`(**v2 판 183줄** · 2행·119행 범위 · 128행 PR 제목 형식 → 이 카드가 덮는다). 🔴 Bob **새 대화** 전제 — R14a 대화를 기억하지 못합니다.
> R4·R13·R5·R14a 교훈 반영: R14a 카드 머리 «교훈 반영» 줄과 같다(PNG 열람 = 이름마다 light 1장(3장) · 갈래마다 배너 · 흐름 = 클로저 · 전제는 if 밖·`// pre` · 커밋마다 `git show --stat HEAD` · 저장 파일 · 정적 = 파일로 Git Bash · 머리 ASCII · G1 🟡 조문 · ③ 구분 줄 · ④ «+» · 단언 없는 `takeException` 0 · «자리 바꿈» 견본 · 입력 칸 = 파일 이름만).

## 0. 한 줄 목적

`WatchdogBoard()` 하나가 `watchWatchdog()` 의 **서버가 준** 체크 목록을 받은 차례 그대로 그리고(개수·이름·유예값 리터럴 0), 상태 모양은 `level` 하나로(지연 ≠ 실패색 · paused·휴장 ≠ 실패·결측), 슬러그는 어디에도 내지 않으며, 행 탭은 `route` 데이터로만 여는 `W-01` 을 계약 v1.15 그대로 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-w01-watchdog`**(base = 최신 `origin/main` · `--no-track` · 이름 = 분할 뒤 새 이름 — 12 §3 R14b 행 · 01 표에 함께 적음 · 발주자 확인 R14a ①).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 `send/_대기/`(R14a 병합 기록이 옮긴다).
2. Bob 에 R14a 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다.
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R14b-Bob-W01.md>(`send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R14b-Bob-W01 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R14a-Bob-N01N02*.md` 를 붙여넣지 않습니다.
6. 🔴 **받는 법** — R14a 와 같다(`$env:TEMP\R14b-Bob-W01_submit.md` · 채팅 두 줄 · 그 파일을 열어 통째로 붙여 넣기).
7. 🔵 이전 창의 `flutter_tester` 를 직접 끝내지 마세요(다른 세션 것도 있습니다).

## 3. 붙여넣을 본문 — ````text 다음 줄(«R14b-Bob-W01 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R14b-Bob-W01 — 범위: W-01 워치독 상태(WatchdogBoard() — 머리 · 오래됨 · 체크 행(아이콘·색 = level · 이름 · 상태 · 마지막 확인 · 유예) · 행 탭 = route · 빈 문장) + 배럴 export 1줄 + 가짜 끝 절.
🔴 체크 목록은 서버가 준 것만 — 개수·이름·유예값 리터럴 0 · 받은 차례 그대로 · 거르기·세기·정렬 0.
🔴 상태 = level 하나(UiLevel 전수 switch) — stateCode 미참조 · 지연(watch)을 실패(blocked)색으로 칠하지 않는다 · paused·휴장을 실패·결측으로 칠하지 않는다.
🔴 슬러그·ping URL·키 = 시크릿급 — 화면·Key·로그·PR 어디에도 0 · slug 필드를 읽지 않는다 · 슬러그 파싱 0 · /pause·/resume 버튼 0.
🔴 셸 파일·R13 화면·R14a 알림 파일·테스트·PNG 는 고치지 않는다 — 셸 연결은 레지스트리 opsWatchdog 칸(조립 앱 몫 · 이 카드 밖).
하지 않는 것: 알림 센터(R14a · 병합됨) · F-01 FGS(화면 카드 밖) · 하단 한계 고지 · 머리 «마지막 수신» · 휴장 고지 문장(holiday_notice) · 장기 이력 · 조립 앱 배선 · domain_contracts·pubspec 수정 · 다른 ui_* 수정 · 새 주입 · 새 정적 라벨.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 16항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R14a(ui/m8-n01-alerts — 병합됨)가 아닙니다. 앞 카드의 브랜치는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_shell/lib/src/watchdog_board.dart · WatchdogBoard 가 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m8-n01-alerts 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m8-w01-watchdog origin/main      ← 🔴 git checkout main 금지
  git grep -c "contractVersion = '⟦실측: 1.15.0⟧'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»
  git grep -c "Stream<ListResult<WatchdogCheck>> watchWatchdog();" -- packages/domain_contracts/lib/src/repositories/ops_repository.dart  ← «…ops_repository.dart:1»
  git grep -c "required UiLevel level," -- packages/domain_contracts/lib/src/dto/ops.dart                                           ← «…ops.dart:⟦실측: 2 — DiagnosticCell(v1.13) + WatchdogCheck(v1.15)⟧»
  git grep -c "class UnimplementedOpsStatusRepository" -- packages/domain_contracts/lib/testing.dart                                ← «…testing.dart:1»
  git grep -c "static const String m8WatchdogPaused =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart              ← «…fixture_paths.dart:1»(v1.15)
  git grep -c "static const String m8WatchdogEmpty =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart               ← «…fixture_paths.dart:1»(v1.15)
  git grep -c "final Provider<OpsStatusRepository> shellOpsStatusRepositoryProvider" -- packages/ui_shell/lib/src/shell_providers.dart  ← «…shell_providers.dart:1»(R13b)
  git grep -c "final Provider<CommandApi?> shellAlertCommandApiProvider" -- packages/ui_shell/lib/src/shell_providers.dart            ← «…shell_providers.dart:1»(R14a 병합)
  git grep -c "class AlertAckBlock" -- packages/ui_shell/lib/src/alerts/alert_ack.dart                                               ← «…alert_ack.dart:1»(R14a 병합)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                              ← «…prompt_M8.md:1»
  ls docs/ai-context/send/R14b-Bob-W01.md                                   ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/W01_questions.md                                 ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m8/watchdog_delayed.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m8/watchdog_holiday.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m8/watchdog_paused.json             ← 보여야 함(v1.15)
  ls packages/domain_contracts/fixtures/m8/watchdog_empty.json              ← 보여야 함(v1.15)
     (🔴 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — R14a 병합·계약 v1.15 보다 카드가 먼저 왔습니다)
  아래 세 줄만 반대다 — 🔴 «없음»·출력 없음이 정상:
  ls packages/ui_shell/lib/src/watchdog_board.dart                          ← 없어야 함
  ls packages/ui_shell/test/watchdog_board_test.dart                        ← 없어야 함
  git grep -c WatchdogBoard -- packages/ui_shell/lib                        ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_shell
  flutter test   ← 시작 기준: R14a 병합본 전부 통과 · 기대 «+⟦실측: 158⟧: All tests passed!»(끝 줄의 수를 «시작 기준 N» 으로 · 다르면 PR 본문에 까닭 한 줄 · 실패가 있으면 멈추고 끝 20줄을 채팅으로)
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 계약 v1.15 이름표(워치독 몫 · 🔴 코드가 정본 — 다르면 멈추고 질문 파일에)
  dto/ops.dart  WatchdogCheck 에 required UiLevel level(엔진 매핑 — 성공·휴장 성공 핑 = ok · 지연 = watch · 실패 = blocked · 일시정지 = info) · 그 밖 필드 그대로(slug · label · stateCode · stateLabel · lastPingText · graceText? · route?)
  testing.dart  UnimplementedOpsStatusRepository(받침대)
  FixturePaths  m8WatchdogDelayed(6행 — 성공 3 · 지연 2 · 실패 1) · m8WatchdogHoliday(5행 — 휴장 성공 핑 3 · 성공 2 · 형제 키 holiday_notice) · m8WatchdogPaused(🆕 5행 — 일시정지 3 · 성공 2) · m8WatchdogEmpty(🆕 행 0 · emptyLabel)

■ 규칙 요약 (전문 = prompt_M8.md · 우선순위 = 코드 > 이 카드 > 01 §4-1 > 04 §7 본문·그림 15 > prompt_M8 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_shell + docs/ai-context/inbox/W01_questions.md 만. 새 파일 = lib/src/watchdog_board.dart · test/watchdog_board_test.dart · test/golden/w01_golden_test.dart · 새 PNG 6.
   공용 2파일은 **끝 절 더하기만**: lib/ui_shell.dart = export 한 줄(자리 = 정렬 차례 — export 'src/watchdog_board.dart'; 는 export 'src/shell_scaffold.dart'; 바로 뒤 · 맨 끝) · test/shell_fakes.dart = 파일 끝에 R14b 절.
   고치면 반려: 그 밖의 ui_shell 파일 전부(lib/l10n/labels.dart · lib/src/shell_providers.dart · 셸·홈·리듬·알림 lib · 앞 카드 테스트 · 비교기 · golden_support.dart · golden README · 기존 PNG · pubspec · analysis_options · README) · domain_contracts/** · apps/** · 다른 ui_*.
 2 화면은 받은 글자와 null 여부만 본다 — 값 = label · stateLabel · lastPingText · graceText · asOf.label · emptyLabel 원문 그대로 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 0(라벨도 새로 0) · lib 주석의 Key·글자 인용 = 백틱만.
 3 읽지 않는 필드(카드가 정함): WatchdogCheck 의 slug(🔴 시크릿급 — 읽기 0 · 정적 W07·W09) · stateCode(🔴 모양 = level) · ListResult 의 emptyKind · hasMore · AsOf 의 source · tradeDate · 봉투 형제 키 holiday_notice(창구로 오지 않는다).
 4 이동 = AppLinkOpener.open(route) 하나(ref.read(shellLinkOpenerProvider) · 행 탭 콜백 안 · route null = onTap null) · 🔴 'aaq://' 리터럴 0 · AppRoutes 0(자기 링크 행도 데이터대로 — 링크 비교 0) · 공개 위젯 생성자 = WatchdogBoard({super.key}) 하나.
 5 산술·판정 0 — 허용 = ⓐ 신선도 한 식(r.asOf.observedAt.add(r.asOf.staleAfter).isBefore(clock.nowUtc())) ⓑ null 여부(route · graceText · emptyLabel) ⓒ UiLevel 5값 전수 switch(_checkLook) 셋뿐 ·
   목록 길이·int 를 글자로 0 · Duration 계산 0 · maxLines · TextOverflow · FittedBox · .trim( 0 · DateTime.now 0 · 문자열 split·startsWith·contains·RegExp 0(🔴 슬러그 파싱 금지) · FeatureFlags·OperatingMode·RunMode 0.
 6 switch 는 열거값 전수(default 0): UiLevel 5값 한 곳(_checkLook) — 하나뿐.
 7 시계 = shellClockProvider · 공통 조각 = R13a 의 ShellAsOfHeader · ShellStaleBanner · ShellSkeleton · ShellErrorView 재사용(새 공용 조각 0) · 상태 갈래 = 아래 «상태 표» 글자 그대로 · 스피너 금지.
 8 본문이다 — Scaffold·AppBar·SafeArea·Navigator 0 · 부모 높이 안 ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 · 간격·크기 = 정수·N.0.
 9 프로바이더 — 새 주입 0(기존 shellOpsStatusRepositoryProvider) · 데이터 1(파일 안 private StreamProvider · autoDispose 0 · 꼴 = ops_rhythm.dart _rhythmProvider) · 탭 핸들러 안 ref.read · 데이터는 build 에서 ref.watch.
10 테스트 = R14a 카드 규칙 10 과 같은 글자(받침대 extends = UnimplementedOpsStatusRepository · 🔴 implements 가짜 0 · 호출마다 새 Stream · 가짜 공장 = call 삼항 · 픽스처 = main() 머리 final · 전제 = testWidgets 본문 첫머리 if 밖 + `// pre` ·
   «없는 쪽» 견본 + 양성 기준점 · copyWith 0 · collection-if 0 · else 없는 if 0 · bool 칸 + if · name == · opened[0] · expect(a || b, isTrue) · 괄호 단언 · 단언 없는 takeException = 반려 꼴 ·
   제네릭 위젯 술어 = tester.widget<Icon>(find.descendant(of: find.byKey(…), matching: find.byType(Icon))) 꼴만) ·
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 한 줄(n = 정수 리터럴 — 지연 표본 6 · 경우 칸의 리터럴) · 🔴 전제에 hasLength 0 ·
      정적 W17·W18 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(watchdog_board_test ⓡ 6 · ⓗ 2).
11 골든 = 새 PNG w01_* 6장 · --update-goldens 는 w01_golden_test.dart 만 · 기존 PNG(34장) 재생성 0 · golden:approved 안 붙임 · 🔴 높이(kGoldenPhoneSize 844)는 늘리지 않는다(카드 확정값 · 여백을 줄이면 «측정:» 전·후 행).
12 도구 = R14a 와 같다(format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · 🔴 melos.bat run test 백그라운드·파이프 금지 · 패키지 테스트는 packages/ui_shell 에서 flutter test 직접).
13 C-4 이름 함정 — R14a 와 같다(산술 0).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL·슬러그 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — lib/src/watchdog_board.dart 주석에 이 낱말을 쓰지 않는다: slug · secret · healthchecks · ping url · api key · stateCode · DateTime.now · AppRoutes · FeatureFlags · runMode · Duration · Colors · RichText · autoDispose · Scaffold · Navigator · 추천 · 권유 · 자문 · 시그널.
🔴 보고 규칙(strict 나눔) — R14a 카드와 같은 글자(① 표기만 = C4 정정 ② 코드·테스트 결함·거짓 주장 = 반려 ③ 예고 변이 통과 = 반려 · 카드 구멍 = 반려 근거 아님 · PNG = 이름마다 light 한 장(3장) · 셈 단위 · PR 본문 = 통합 담당 · S05 결과 줄 · ② 상자 · ③ 이름 나열).

■ 프롬프트보다 이 카드가 이긴다 — 16항 (prompt_M8.md 183줄 판 v2)
 ① 2행 {{범위}} = S-01 · 119행 → 이 카드의 범위 = W-01
 ② 113~118행 역할·범위 → 이 카드 = W-01 · N-01·N-02 = R14a(병합됨) · F-01 = 화면 카드 밖(엔진 레인 M1-15) · 그 밖 = R13·R15·R16
 ③ 12~13행 의존 셋 → 추가 0 · pubspec 무변경
 ④ 15~19행 링크는 데이터 → 그대로 유효(행 탭 = route · null = 탭 없음 · 상수 진입 0)
 ⑤ 20~23행 DateTime.now 금지 · 신선도 → 그대로 유효(한 식 · 마지막 확인 = lastPingText 엔진 글자)
 ⑥ 25~31행 산술·집계·거르기·재정렬 금지 → 그대로 유효(규칙 5 의 셋)
 ⑦ 32~35행 한국어 리터럴 = labels.dart → 그대로 유효(이 카드 라벨 0)
 ⑧ 36~38행 «아무 일 없음 문장 금지» → 그대로 유효(빈 문장 = emptyLabel 데이터)
 ⑨ 41~47행 안전 화면 금지 → 그대로 유효(/pause·/resume 버튼 0 — X1 유지보수 창 전용)
 ⑩ 48~57행 모드 접두·띠 = 셸 → 그대로 유효(슬러그의 모드 축을 화면이 읽지 않는다)
 ⑪ 87~105행 «■ 제출» → 그대로 유효 · 글자·명령 = 아래 «■ 제출»(저장 파일 · 채팅 두 줄)
 ⑫ 106~111행 질문 파일 → inbox/W01_questions.md
 ⑬ 127~128행 브랜치·PR 제목 형식 → ui/m8-w01-watchdog · «[M8] W-01 워치독 상태»
 ⑭ 141~144행 워치독 시크릿 · 4상태 · 표시 이름 = 뷰모델 → 그대로 유효 — 4상태의 원천 = level(v1.15) · 표시 이름 = label
 ⑮ 134~140행 알림 → 이 카드 범위 밖(R14a)
 ⑯ 172~182행 자체 점검 10항 → «■ 제출» ② 복사 상자(7 해당 · 1·2·3·5 해당 · 4·6·8·9·10 = [x] + 괄호 «이 카드 범위 밖(…)»)
 🔵 낡은 줄 하나: 끝난 R13b 카드 «이긴다» ② 의 «W-01 = R15~R16» → 정본 = 설계 12 §3 R14 행(W-01 = R14 · 이 카드).

■ 먼저 읽을 것 (🔴 02·03·05 명세는 읽지 않음)
 ① prompt_M8.md 전문 ② 04 §7(W-01 · 표 · 수용 (a)~(e) · 그림 15) · §2-5(뷰어 = 조회) ③ 01 §4-1 watchWatchdog · ⟦v1.15: 01 §24 절 번호⟧
 ④ packages/domain_contracts/lib/ — src/dto/ops.dart(WatchdogCheck · level) · src/enums/ui.dart(UiLevel) · src/repositories/ops_repository.dart · src/primitives/list_result.dart · as_of.dart · testing.dart(UnimplementedOpsStatusRepository · RecordingLinkOpener)
 ⑤ packages/ui_shell — lib/src/ops_rhythm.dart(🔵 이 화면의 꼴 선례 · 읽기만) · test/ops_rhythm_test.dart · test/shell_fakes.dart · test/golden/h02_golden_test.dart · golden_support.dart · golden README «🆕 R14» 절
 ⑥ fixtures/README.md(m8 행 · 봉투 형제 키) ⑦ docs/ai-context/inbox/README.md · W01_questions.md 머리말

■ 본받지 않는 것
 · S-02 웹 사이드바·셸 파일에 워치독 진입을 더하는 것 · R13b 의 FakeShellOpsStatusRepository 를 고치는 것(새 가짜 = 끝 절)
 · stateCode == 'DELAYED' 류 문자열 비교로 색을 고르는 것 · 지연을 errorContainer·error 로 · paused 를 회색 «결측» 표시로 · 휴장 행을 따로 거르기
 · slug 를 Key·Text·print·debugPrint·로그·assert 메시지에 쓰는 것 · 슬러그에서 sim/live·auto/advisory 를 읽는 것 · 행 수·체크 이름을 상수로 두는 것 · «2h»·«30분» 유예 글자를 짓는 것
 · route 가 자기 자신이면 막는 것(링크 판정) · /pause·/resume 버튼 · implements 가짜 · 한국어 테스트 이름 · 조건부 단언 · lib nullable 에 !

■ 주입 구조
· 🆕 lib 파일 1개 = lib/src/watchdog_board.dart — WatchdogBoard(공개 · ConsumerWidget) · _watchdogProvider · _CheckRow(ConsumerWidget) · _checkLook
  import 차례 = package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart → ../l10n/labels.dart(안 쓰면 뺀다) → common/shell_common.dart → routing/shell_router.dart → shell_providers.dart
· 데이터 1 = final StreamProvider<ListResult<WatchdogCheck>> _watchdogProvider = StreamProvider<ListResult<WatchdogCheck>>((Ref ref) => ref.watch(shellOpsStatusRepositoryProvider).watchWatchdog());
· 🆕 배럴 lib/ui_shell.dart 에 export 한 줄 — export 'src/watchdog_board.dart';(자리 = export 'src/shell_scaffold.dart'; 뒤 · 맨 끝 · 삭제 0)
· 조립 앱(이 카드 밖 · 참고만): ShellRouteBodies 의 AppRoutes.opsWatchdog 칸 = (_) => const WatchdogBoard().

■ 호출 표
 WatchdogBoard — 부르는 것: watchWatchdog() 한 번(재시도 = 한 번 더) · shellClockProvider · shellLinkOpenerProvider(행 탭 콜백 안). 부르지 않는 것: OpsStatusRepository 의 나머지 5 · SettingsActions · CommandApi · AlertRepository · AppRoutes.isRegistered.

■ 상태 표 (구독 하나 — 꼴 = R13a OpsRhythm)
 watchdog  hasError → ShellErrorView(key: const Key('w01-fail'), onRetry: () => ref.invalidate(_watchdogProvider), lastAsOfLabel: watchdog.valueOrNull?.asOf.label) · 값 전 → ShellSkeleton(key: const Key('w01-loading')) · 값 → 아래 «화면»(빈 문장도 같은 목록 안)

■ 화면 (위 → 아래 · 🔴 이 순서)
 머리    Key w01-asof       ShellAsOfHeader(asOf: r.asOf) · (stale) ShellStaleBanner(asOf: r.asOf)                                  · 늘
 행      for (final (int i, WatchdogCheck c) in r.rows.indexed) _CheckRow(i, c)                                                  · 받은 차례
         _CheckRow = InkWell(key: ValueKey<String>('w01-row-$index'), onTap: route == null ? null : () { ref.read(shellLinkOpenerProvider).open(route); }, Padding(EdgeInsets.symmetric(horizontal: 16, vertical: 12))[ Row(crossAxisAlignment: start)[
           Icon(look.$1, color: look.$2, size: 20) · SizedBox(width: 8) · Expanded(Text(check.label)) · Expanded(Column(crossAxisAlignment: start)[ Text(check.stateLabel) · Text(check.lastPingText) · (grace != null) Text(grace) ]) ] ])
         ← final String? route = check.route; final String? grace = check.graceText; final (IconData, Color) look = _checkLook(Theme.of(context).colorScheme, check.level);
 빈      (empty != null) Padding(EdgeInsets.all(16), Text(empty, key: const Key('w01-empty')))                                    ← final String? empty = r.emptyLabel;(다른 조건 0)
 _checkLook(ColorScheme cs, UiLevel l) = switch (l) { UiLevel.ok → (Icons.check_circle_outline, cs.primary) · info → (Icons.pause_circle_outline, cs.onSurfaceVariant) · watch → (Icons.schedule, cs.tertiary) ·
         act → (Icons.error_outline, cs.secondary) · blocked → (Icons.cancel_outlined, cs.error) }(🔴 watch ≠ blocked · info ≠ blocked · 아이콘에 Key 0 · 반환 = (IconData, Color) 레코드)
 하단 한계 고지 · 머리 «마지막 수신» · 휴장 고지 문장 = 부재(필드 0 · 코드 0)

■ 픽스처 (FixturePaths.… · listFixture · 🔴 전제 expect 로 다시 확인)
 delayed  listFixture(m8WatchdogDelayed, WatchdogCheck.fromJson) — 6행(성공 3 · 지연 2(graceText · [1] route non-null — 자기 링크 표본) · 실패 1) · [0] route null · emptyLabel null · asOf «워치독 기준 2026-08-31»(26h)
 holiday  listFixture(m8WatchdogHoliday, …) — 5행(휴장 성공 핑 3 · 성공 2 · level 전부 ok) · 형제 키 holiday_notice 는 읽지 않는다
 paused   listFixture(m8WatchdogPaused, …) — 5행(일시정지 3 level info · 성공 2)
 emptyV   listFixture(m8WatchdogEmpty, …) — 행 0 · emptyLabel non-null
 🔴 쓰지 않는 것: 알림 픽스처 · copyWith · 지은 DTO · holiday_notice.

■ Key 표 (w01- 5이름 — 정본 · 표 밖 Key 0 · 🔴 slug 0 — 순번만)
   w01-loading(ShellSkeleton) · w01-fail(ShellErrorView) · w01-asof(ShellAsOfHeader) · w01-row-$i(_CheckRow 의 InkWell) · w01-empty(빈 문장 Text)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 내용 · 커밋마다 git add <파일> + git show --stat HEAD · amend·rebase·강제 푸시 금지 · 마지막 = format · 질문)
 (1) lib/src/watchdog_board.dart + 배럴 한 줄. 커밋 «[M8] R14b (1) W-01 워치독 상태»
 (2) test/shell_fakes.dart 끝 절 + test/watchdog_board_test.dart(W01-01~W01-07) · 🔴 커밋 전에 «정적 묶음» 미리 돌리기. 커밋 «[M8] R14b (2) W-01 테스트»
 (3) 골든 6장 — test/golden/w01_golden_test.dart(3이름 × 2). 커밋 «[M8] R14b (3) 골든 w01_* 6장»
 (4) melos.bat run format:fix · analyze 한 번 · 질문 파일(W01_questions.md — dy 측정 행 A1~A3). 커밋 «[M8] R14b (4) format · 질문» · 🔴 (4) 뒤 커밋 0(예외 = 사전검사 ① 🔴 · analyze · format 수정 (5) 하나).

■ 정적 라벨 — 0개(🔴 labels.dart 무변경 · 총수 = 정적 W10 이 «정확히» 센다 = R13 31 + R14a 4)

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ = W17·W18 · (전제) = W30)
공통: 띄우기 = pumpWatchdogBoard(tester, overrides:)(Size(390, 2400) · DPR 1.0 · teardown 2 · ProviderScope > MaterialApp > Scaffold(body: WatchdogBoard()) · pump 두 번) · overrides = watchdogOverrides(ops:, opener:, clock:)(3줄) ·
  시계 = FixedClock(kGoldenNowUtc) · 오래됨 = FixedClock(kGoldenNowUtc.add(const Duration(days: 2))) · 경우 = for · 흐름 = 클로저 칸 · 계획 = watchdog_board_test testWidgets 줄 7(테스트 17개) · 골든 1 · 합 8.
  🆕 test/shell_fakes.dart 끝 절(한국어 리터럴 0 · if 0 · collection-if 0):
    class FakeShellWatchdogRepository extends UnimplementedOpsStatusRepository { FakeShellWatchdogRepository({required this.watchdog}); final Stream<ListResult<WatchdogCheck>> Function(int call) watchdog; int calls = 0;
      @override watchWatchdog() → final int call = calls; calls = calls + 1; return watchdog(call); }(🔴 나머지 5 는 넘기지 않는다 — 받침대가 던진다)
    List<Override> watchdogOverrides({required FakeShellWatchdogRepository ops, required RecordingLinkOpener opener, required Clock clock})
        ← shellOpsStatusRepositoryProvider.overrideWithValue(ops) · shellLinkOpenerProvider.overrideWithValue(opener) · shellClockProvider.overrideWithValue(clock) — 3줄
    Future<void> pumpWatchdogBoard(WidgetTester tester, {required List<Override> overrides}) · List<String> watchdogRowTexts(WatchdogCheck c) => <String>[c.label, c.stateLabel, c.lastPingText, ?c.graceText]
    Set<String> watchdogAllowed(ListResult<WatchdogCheck> v)(= asOf.label · ?asOf.staleLabel · 행마다 label·stateLabel·lastPingText·?graceText · ?emptyLabel + ShellLabels.staleBannerTitle · 🔴 slug·route 0)
  `one<T>` · `shownTexts` = 앞 카드 도우미 그대로 · valueThenFail = 지역 함수 · 값 안 내는 스트림 = Stream.multi(…{}).
W-01 — test/watchdog_board_test.dart
 W01-01 행 글자·받은 차례(04 §7 수용 (a) · 서버가 준 목록) — delayed: 전제 하나: expect(delayed.emptyLabel, isNull); // pre → ops.calls == 1 · 사슬 dy w01-asof → w01-row-0 → … → w01-row-5 ·
        shownTexts(w01-asof) == [delayed.asOf.label] · ⓗ expect(delayed.rows, hasLength(6)) → i 마다 shownTexts(w01-row-$i) == watchdogRowTexts(delayed.rows[i]) · w01-row-6 findsNothing · w01-empty findsNothing · staleBannerTitle findsNothing · ⓡ.
 W01-02 상태 모양 = level 전수(04 §7 3분법 + paused · 수용 (b)(d)) — 세 경우 ㉠ (delayed · 6) · (holiday · 5) · (paused · 5)마다 — 전제 셋: expect(delayed.rows.any((WatchdogCheck r) => r.level == UiLevel.watch), isTrue); // pre ·
        expect(delayed.rows.any((WatchdogCheck r) => r.level == UiLevel.blocked), isTrue); // pre · expect(paused.rows.any((WatchdogCheck r) => r.level == UiLevel.info), isTrue); // pre →
        ⓗ expect(c.v.rows, hasLength(c.n)) → i 마다 final Icon icon = tester.widget<Icon>(find.descendant(of: find.byKey(ValueKey<String>('w01-row-$i')), matching: find.byType(Icon))); expect(icon.icon, wantIcon(row.level)); expect(icon.color, wantColor(cs, row.level));
        (wantIcon·wantColor = 테스트 파일 안 private switch · 기대 원천 = 이 카드 «화면» _checkLook 글자 · 🔵 지연 행 색 ≠ cs.error · 일시정지 행 색 ≠ cs.error 가 이 표로 드러난다) · ⓡ.
 W01-03 행 탭 = route(데이터 · 링크 판정 0) — 두 경우 ㉠ (linked · 행 1 · want = <String>[delayed.rows[1].route!]) · (unlinked · 행 0 · want = <String>[])마다 — 전제 둘: expect(delayed.rows[1].route, isNotNull); // pre ·
        expect(delayed.rows[0].route, isNull); // pre → tap(w01-row-$k) → pump → expect(opener.opened, c.want) · ⓡ(🔵 행 1 의 route = W-01 자기 링크 표본 — 데이터대로 연다).
 W01-04 빈 = 데이터 — 두 경우 ㉠ (empty · emptyV · want = emptyV.emptyLabel) · (delayed · null)마다 — 전제 셋: expect(emptyV.rows, isEmpty); // pre · expect(emptyV.emptyLabel, isNotNull); // pre · expect(delayed.emptyLabel, isNull); // pre →
        «없는 쪽» 견본(want → shownTexts(w01-empty) == [want] · w01-row-0 findsNothing / w01-empty findsNothing · w01-row-0 findsOneWidget = 양성 기준점) · w01-asof findsOneWidget · ⓡ.
 W01-05 갈래 × 상태(🆕 갈래마다 배너 C4r5e-3) — 다섯 경우 ㉠ (loading · Stream.multi(값 0) · [w01-loading] · [w01-asof, w01-fail] · 배너 0) · (fail · Stream.error · [w01-fail] · [w01-asof, w01-loading] · 0) ·
        (value_then_fail · valueThenFail(delayed) · [w01-fail] · [w01-asof] · 0 · 흐름 = find.text(delayed.asOf.label) findsOneWidget) · (stale · one(delayed) · 오래됨 · [w01-asof, w01-row-0] · [w01-fail] · 1 · 흐름 = 배너 dy < w01-row-0 dy) ·
        (stale_empty · one(emptyV) · 오래됨 · [w01-asof, w01-empty] · [w01-fail] · 1 · 흐름 = 배너 dy < w01-empty dy)마다 Key 목록 findsOneWidget / findsNothing · 배너 = c.banner ? findsOneWidget : findsNothing · 흐름 · CircularProgressIndicator findsNothing.
 W01-06 재시도 — 공장 = (int call) => call == 0 ? Stream<ListResult<WatchdogCheck>>.error(StateError('fail')) : one(delayed) → tap(find.text(ShellLabels.retry)) → pump 두 번 → w01-fail findsNothing · w01-asof findsOneWidget · ops.calls == 2 · ⓡ.
 W01-07 화면 Text 전부 · 슬러그 0 · 큰 글꼴(04 §7 수용 (c) · prompt 141) — 세 경우 ㉠ (delayed) · (holiday) · (paused)마다 «화면의 Text 전부» 견본(allowed = watchdogAllowed(c.v)) →
        행마다 expect(find.textContaining(row.slug), findsNothing) · expect(find.byKey(ValueKey<String>(row.slug)), findsNothing) → textScaleFactorTestValue = 2.0 → takeException isNull · ⓡ.
 ⓡ 기대 = watchdog_board_test.dart 6줄(W01-01 · 02 · 03 · 04 · 06 · 07) · ⓗ 기대 = 2줄(W01-01 · 02) — 🔴 정확히 · (전제) = 9(01 1 · 02 3 · 03 2 · 04 3 — 정적 W30).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 통과하면 반려 · 갈래마다 짝):
   (순서·목록) 행 뒤집기 · 행 둘 자리 바꾸기 · 행 다섯만(take(5)) · 휴장 행 거르기 · 실패 행을 맨 위로.
   (상태) 지연을 실패색으로(watch → cs.error) · 일시정지를 실패색으로(info → cs.error) · 아이콘 하나로 고정 · 색 하나로 고정 · stateCode 문자열 비교로 모양(level 무시) · 🔵 참고 — 타입이 막음(적용 불가): «level 을 화면이 다시 매기기»(final 필드).
   (글자) stateLabel 빼기 · lastPingText 빼기 · graceText 빼기 · graceText null 에도 빈 줄 · 유예 글자를 화면이 짓기(정적 라벨 더하기) · 슬러그를 글자로(탐침) · 슬러그를 Key 로.
   (링크) 행 탭 0 · route null 에도 탭 · 자기 링크 행 탭 막기(링크 비교).
   (빈·상태 — 갈래마다) emptyLabel 빼기 · 에러를 스켈레톤으로 · 값 뒤 에러에 마지막 asOf 글자 빼기 · 재시도 invalidate 0 · 오래됨 배너 빼기(행 있음 · 빈 — 둘 다) · 신선도 비교 뒤집기 · 벽시계로 신선도 · 화면에 정적 글자 하나 더하기.
   🔵 판정 = 변이마다 ui_shell 의 flutter test 전부(골든 포함) · 드라이런 = ⟦실측: 변이 표⟧.

■ 정적 묶음 — 아래 32줄을 파일로 꺼내 Git Bash 로 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다(R14a 와 같은 대조 규칙 · 머리 ASCII · 출력 줄 수(EXIT 줄 포함) = ⟦실측⟧줄)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 손으로 옮겨 쓰지 않는다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R14b-Bob-W01.md' | sed -n '⟦실측: 줄 범위⟧p' > ../../build/r14b_static.sh"
  git hash-object ../../build/r14b_static.sh   ← ⟦실측: 해시⟧(다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r14b_static.sh > ../../build/r14b_static_out.txt"
  Select-String -Path ..\..\build\r14b_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음이어야 한다(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r14b_static_out.txt).Count   ← ⟦실측⟧(EXIT 줄 32 포함) · '^EXIT:1$' ← ⟦실측⟧ · '^EXIT:0$' ← ⟦실측⟧
  ② 에 붙일 출력 = Get-Content -Encoding UTF8 ..\..\build\r14b_static_out.txt 전부
echo "## W01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/watchdog_board.dart; echo "EXIT:$?"
echo "## W06 subscription lines (1)"; git grep -n "watchWatchdog(" -- lib/src/watchdog_board.dart; echo "EXIT:$?"
echo "## W07 forbidden words in watchdog board 0"; git grep -nE "\.slug|stateCode|hasMore|emptyKind|DateTime\.now|Duration\(|kIsWeb|Platform\.|dart:io|HoldingPnl|PerformanceSeries|afterTax|FeatureFlags|operatingMode|runMode|AppRoutes|AppLinkSchemes|\.where\(|\.length|\.sort|sorted|\.take\(|toString\(|NumberFormat|DateFormat|split\(|startsWith|substring|RegExp|SettingsActions|/pause|/resume|showDialog|SnackBar|Clipboard|print\(" -- lib/src/watchdog_board.dart; echo "EXIT:$?"
echo "## W08 UiLevel switch arms (5)"; git grep -nE "UiLevel\.(ok|info|watch|act|blocked)" -- lib/src/watchdog_board.dart; echo "EXIT:$?"
echo "## W09 secret words in lib 0"; git grep -niE "slug|ping url|api.?key|healthchecks|secret" -- lib; echo "EXIT:$?"
echo "## W10 shell labels (35 exact)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## W11 barrel exports (9 exact)"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## W12 shell providers (15 exact)"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## W13 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## W14 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## W15 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## W16 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## W17 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/watchdog_board_test.dart; echo "EXIT:$?"
echo "## W18 H lines (hasLength)"; git grep -c "hasLength(" -- test/watchdog_board_test.dart; echo "EXIT:$?"
echo "## W19 w01 key names"; git grep -noP "w01-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/watchdog_board.dart; echo "EXIT:$?"
echo "## W20 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## W21 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## W22 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## W23 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## W24 Scaffold AppBar Navigator in watchdog board 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/watchdog_board.dart; echo "EXIT:$?"
echo "## W25 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/l10n/labels.dart lib/src/shell_providers.dart lib/src/shell_scaffold.dart lib/src/routing/shell_router.dart lib/src/common/shell_common.dart lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart; echo "EXIT:$?"
echo "## W26 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W27 copyWith in tests 0"; git grep -n "copyWith(" -- test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W28 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W29 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## W30 precondition marks (pre)"; git grep -c "// pre$" -- test/watchdog_board_test.dart; echo "EXIT:$?"
echo "## W31 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/watchdog_board_test.dart; echo "EXIT:$?"
echo "## W32 golden PNG total (40 exact)"; git ls-files -- test/golden/goldens | grep -c "\.png$"; echo "EXIT:$?"
  (줄의 뜻과 기대(카드 계획 · ⟦실측⟧ = 드라이런이 채운다) — W01 = 주석 줄 말고 출력 없음 · W02 = 출력 없음 · W03 = 2줄(w01_golden 1 · watchdog_board_test 7) · W04 = 0 · S05 = 1줄(행 탭 콜백 안) · W06 = 1줄 · W07 = 0 ·
   W08 = 5줄(_checkLook 다섯 갈래) · W09 = 0(🔴 주석 포함 · 앞 카드 파일 포함) · W10 = «lib/l10n/labels.dart:35»(🔴 정확히 — R13 31 + R14a 4 + 이 카드 0) · W11 = 9줄(… src/shell_scaffold.dart · 🆕 src/watchdog_board.dart 차례 · 🔴 정확히) ·
   W12 = 15줄(🔴 정확히 — 이 카드 몫 0) · W13~W16 = 0 · W17 = «test/watchdog_board_test.dart:6» · W18 = «test/watchdog_board_test.dart:2»(🔴 정확히) · W19 = 이름 5 = 위 «Key 표»(w01-row 는 머리만 · 표 밖 0) · W20~W24 = 0 ·
   W25 = 두 줄(lib/ui_shell.dart 1 · 0 · test/shell_fakes.dart <n> · 0 — 그 밖 파일 줄 없음 · 🔴 labels.dart · shell_providers.dart 줄 0) · W26 = 0 · W27 = 0 · W28 = 0 · W29 = 6줄 전부 «A»(w01_* 만) · W30 = «test/watchdog_board_test.dart:9»(🔴 정확히) · W31 = 0 ·
   W32 = «40»(🔴 정확히 — R13 24 + R14a 10 + 이 카드 6))

■ 골든 — 3이름 × light/dark = 6장(전부 신규 · 이름 = 04 §7 수용 (d) 글자 그대로 · golden README «🆕 R14» 절 표 그대로)
  w01 — test/golden/w01_golden_test.dart · 크기 = kGoldenPhoneSize(390 × 844 · 드라이런 맨 아래 dy ⟦실측⟧) · 위젯 = WatchdogBoard() · 저장소 = FakeShellWatchdogRepository(…)(🔴 testWidgets 안에서 새로 · _Flow 칸에 인스턴스 0) · 시계 = FixedClock(kGoldenNowUtc):
    이름           입력      흐름    맨 아래 Key
    w01_delayed    delayed   없음    ValueKey<String>('w01-row-5')
    w01_holiday    holiday   없음    ValueKey<String>('w01-row-4')
    w01_paused     paused    없음    ValueKey<String>('w01-row-4')
  모양 = h02_golden_test.dart 와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록 × Brightness.values · 흐름 = 클로저 칸 · 테스트 이름 '${flow.name} ${brightnessSuffix(b)}' ·
  주입 = pumpForGolden(tester, const <Widget>(), brightness: b, logicalSize: kGoldenPhoneSize, wrapApp: (Widget app) => ProviderScope(overrides: watchdogOverrides(…), child: app)) → pump → 흐름 → pumpAndSettle → 위치 전제 둘 → expectGolden.
  위치 전제 둘:
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(kGoldenPhoneSize.height));
    expect(tester.getTopLeft(find.byKey(const Key('w01-asof'))).dy, 0.0);
  명령(packages/ui_shell): flutter test --update-goldens test/golden/w01_golden_test.dart → flutter test(옵션 없이 · 새 PNG 6 만 ?? · M 0) · 🔴 높이 늘리지 않는다 · 머리 dy 실패 = 멈추고 질문 파일에 · dy = 이름·밝기마다 직접 잰다.

■ 질문 파일 (🔴 새 파일을 만들지 않는다 — 이미 있다)
· W01_questions.md — «다음 번호»(Q1·A1)부터 · 행 앞에 «W-01:» 접두(골든 «측정:» 행 예외) · 꼭 적을 것: 골든 dy 3행(이 상자 3줄 그대로 · <값> 만):
      ┌── 측정 행 복사 시작(다음 줄부터 · 3줄)
| A1 | R14b-Bob-W01 | 추측 | 측정: w01_delayed dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A2 | R14b-Bob-W01 | 추측 | 측정: w01_holiday dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A3 | R14b-Bob-W01 | 추측 | 측정: w01_paused dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지)
· 적지 않을 것(카드가 정함): 위젯·Key·파일 이름 · 라벨 0 · 읽지 않는 필드 · 배치 · 갈래 · 아이콘·색 표 · 골든 이름·입력 · 재량(여백). 🔴 «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋.

■ 제출
  cd packages/ui_shell
  flutter test test/watchdog_board_test.dart       ← 끝 줄 그대로(기대 «+17: All tests passed!»)
  flutter test test/golden/w01_golden_test.dart    ← 끝 줄 그대로(기대 «+6: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(기대 = 시작 기준 N + 23 — ⟦실측: 158 → «+181: All tests passed!»⟧)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← 실패 0 · 기존 ui_journal 🟡 1건 그대로
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · domain_contracts «+⟦실측⟧ ~30»(이 카드 몫 0) · 🔴 백그라운드·파이프 금지
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_shell/): A lib/src/watchdog_board.dart · M lib/ui_shell.dart · A test/golden/goldens/w01_*.png 6장 · A test/golden/w01_golden_test.dart · M test/shell_fakes.dart · A test/watchdog_board_test.dart ·
        M docs/ai-context/inbox/W01_questions.md · 그 밖(특히 M lib/l10n/labels.dart · M lib/src/shell_providers.dart · M lib/src/alerts/* · M PNG · apps/** · domain_contracts/**) = 금지 — 멈추고 채팅으로
  사전검사 ①: [Console]::OutputEncoding = [Text.Encoding]::UTF8 → dart tool/precheck.dart --base origin/main --collection-if 0 ← 🔴 0(있으면 테스트만 고쳐 (5) 하나 · amend 금지)
  git push -u origin ui/m8-w01-watchdog
  git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD   ← ① 에 붙일 출력
  cd packages/ui_shell → «정적 묶음» 실행 꼴 → cd ../..   ← ② 에 붙일 출력(r14b_static_out.txt 전부)
  PR 은 만들지 않습니다. PR 제목: [M8] W-01 워치독 상태
  🔴 제출 글 = ①~⑤ 전문 + 끝 flutter test 한 줄 → 저장 파일 $env:TEMP\R14b-Bob-W01_submit.md(UTF-8 · BOM 있어도 됨) · 🔴 채팅 답 = 두 줄뿐: «R14b-Bob-W01 제출 글 저장했음: <경로>» · 사전검사 ② 끝 줄.
  PR 본문 5섹션 — 섹션 머리 다섯 줄 = R14a 카드 «■ 제출» 상자와 같은 글자(② 머리 «자체 점검 10항 · 정적 묶음 · 명령 출력») · N1 = 첫 줄이 «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» · 🔴 N3 — 사전검사 ②:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R14b-Bob-W01_submit.md --golden-prefix w01 --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r14b_pre2.txt; Get-Content -Encoding UTF8 $env:TEMP\r14b_pre2.txt | Select-Object -Last 1
        ← 🔴 끝 줄 «── 결과: 🔴 0 · …» 를 확인한 뒤에만 낸다 · 🟡 [G1] = 멈춤 아님(드라이런 기대 🟡 = ⟦실측⟧ · 늘어난 🟡 행은 light PNG 를 다시 열어 표를 맞춘다 — C4r5d-1).
   ① 머리 한 줄 = «화면 ID: W-01 — 워치독 상태(WatchdogBoard())» + «바뀐 파일:» + name-status(코드 블록 하나) + «커밋 목록:» + log(코드 블록 하나)
   ② 자체 점검 10항 — R14a 카드 ② 복사 상자 10줄(prompt_M8 173~182행 글자)을 한 글자도 바꾸지 않고 붙인 뒤 괄호만(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «정적 묶음 W13 — 허용 밖 import 0줄 · pubspec 무변경(W25)»
        2번 = «산술 = 신선도 한 식 · null 여부 · UiLevel switch 뿐 · 거르기·정렬·세기·Duration 0(W07) · 금지 수치 W15 0건 · 소수·% 리터럴 W16 0건»
        3번 = «DateTime.now 0(W07) · 마지막 확인 = lastPingText 그대로 · 유예 = graceText 그대로»
        4번 = «이 카드 범위 밖(5탭·홈·F-01) · 손익 0»
        5번 = «이 카드 범위 밖(알림 = R14a)»
        6번 = «이 카드 범위 밖(DND UI = M9)»
        7번 = «slug·ping URL·키 = lib 0(W07 · W09 · 주석 포함) · 화면 글자 0(W01-07) · Key 0(W01-07 · W19)»
        8번 = «이 카드 범위 밖(시크릿 입력 = M9)»
        9번 = «이 카드 범위 밖(온보딩 = R15)»
        10번 = «/pause·/resume 버튼 0(W07) · 삽입 자리 직접 구현 0»
      + «10항 줄 수» 상자(R14a 와 같은 꼴 · 기대 10 · 파일 $env:TEMP\r14b_box2.txt) + «정적 묶음 출력:» 32줄 출력 전부(코드 블록 하나) + «S05 결과:» 정확히 «<파일>:<줄> — 탭 콜백 안» 1줄 + ⓡⓗ 상자(W17·W18 출력 그대로) + «테스트 파일별:» 두 파일 끝 줄.
   ③ 스크린샷 서술 — 로딩·정상·빈·에러·오래됨 5줄 + 골든 표 6행 · 견본(이 글자 그대로 · «자리 바꿈» 줄은 펼치지 않는다):
         «정상» = ListView → Key('w01-asof') → ShellStaleBanner(있을 때) → ValueKey<String>('w01-row-$i') → Key('w01-empty')(있을 때)
         «빈» = «정상» 의 행 자리에 Key('w01-empty') · «로딩» = ShellSkeleton(Key('w01-loading')) · «에러» = ShellErrorView(Key('w01-fail')) · «오래됨» = ListView → Key('w01-asof') → ShellStaleBanner → ValueKey<String>('w01-row-$i')
      골든 표 6행 = «| 이름 | 입력 픽스처 | 크기 | 위치 전제 dy | 배치·잘림 |» + 구분 줄 «|---|---|---|---|---|» · 입력 = 파일 이름만(watchdog_delayed.json · watchdog_holiday.json · watchdog_paused.json) · 크기 = 390×844 · light PNG 한 장씩(3장) ·
        셈 단위 견본 1행(🔴 같은 이름 행은 꼬리까지 견본 글자 그대로): «| w01_delayed light | watchdog_delayed.json | 390×844 | ⟦실측⟧ | ⟦실측: 드라이런이 PNG 를 열어 쓴 칸⟧ |»
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/W01_questions.md 의 «+|» 줄 전부(줄머리 «+» 그대로 · 코드 블록 하나)
   ⑤ 추측한 것 = 새 A 행 중 «측정:» 이 아닌 행 — 번호로(없으면 정확히 «없음»)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 23 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-w01-watchdog` 푸시 1건 · 커밋 권장 4개 · (4) 뒤 = (5) 하나만.
- `lib/` 새 파일 **1**(`src/watchdog_board.dart`) · 수정 1(`ui_shell.dart` export 1 · 더하기만) · 라벨·주입·셸·R13·R14a 파일 변경 0.
- `test/` 새 파일 2(`watchdog_board_test.dart` · `golden/w01_golden_test.dart`) + 수정 1(`shell_fakes.dart` 끝 절) + 새 PNG 6 · 재생성 0.
- 질문 파일 `W01_questions.md`(A1~A3 «측정:»).
- 저장 파일 `$env:TEMP\R14b-Bob-W01_submit.md` + 채팅 두 줄 · 사전검사 ① ② 🔴 0.
- `flutter test` = 시작 기준 N(⟦실측: R14a 병합본⟧) + 23 · 정적 W10 = 35 · W11 = 9 · W12 = 15 · W17 = 6 · W18 = 2 · W30 = 9 · W32 = 40(🔴 정확히) · W08 = 5 · S05 = 1 · W06 = 1 · W29 = 6 A.
- 재분할 임계: 줄 8 · lib ⟦실측⟧ · PNG 6 → 재분할 없음.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R14b-Bob-W01 결과: 브랜치 ui/m8-w01-watchdog 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R14b-Bob-W01_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계에서 멈췄다면 `R14b-Bob-W01 0단계에서 멈춤 — 확인해줘` + 출력.

## 5. 주의

- **5분 눈 검사**: ① `labels.dart`·`shell_providers.dart`·셸·홈·리듬·알림 파일·기존 테스트·PNG 가 `M` ② `watchdog_board.dart` 에 `slug`·`stateCode`·`'aaq://`·`AppRoutes`·`Duration(`·`.where(`·`split(`·`print(` ③ 지연 행이 빨강·실패 아이콘 ④ 휴장·일시정지 행이 회색 «결측» ⑤ `/pause` 버튼 ⑥ 슬러그가 Key 에.
- 🔵 `golden:approved` 불필요(새 PNG 만).
- 🔵 R14 마지막 카드 — 병합 기록이 R14 완료(🏁)를 적는다 · 다음 = 12 §6 큐(R15) · 통합 담당 test-only PR(C4r13a-3 · C4r13b-4 · R14a «6» 권고).
- ⬜ 자리표시자 = `__R14A_SQ__` · `__R14A_PR__`(R14a 병합 기록 때 채움) · 실측 표식 ⟦ … ⟧(`grep -cP '\x{27E6}'`) = R14a 병합본 실측(시작 기준 N · 계약 버전 줄 · `required UiLevel level,` 수 · `domain_contracts` 수) + 누적 드라이런(끝 N · 정적 · 해시 · dy · 견본 칸 · lib · 변이) — 🔴 보내기 전 0.
- 범위 고지: 하단 한계 고지 · 머리 «마지막 수신» · 휴장 고지 문장 · 자기 링크 행(G12 · G13) = 01 §8 미결 신설 후보(발주자 확인 ⑤⑥) · 미결 137(ShellLinkOpener 늘 push) = 이 카드가 닫지 않는다.

## 6. R14 이월 반영 — R14a 카드 «6» 과 같은 표(W-01 자리)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r5e-3 «갈래마다» 짝 | 예고 변이 머리 «갈래마다 짝» · (빈·상태) 줄(배너 빼기 = 행 있음·빈 둘) · W01-05 `stale`·`stale_empty` | 상태 묶음 변이 = 해당 없음 |
| C4r5e-4 format 에 덜 흔들리는 셈 | 정적 묶음 = 판정 줄 위주(목록 줄 = W11 · W12 · W19) · W32 = 수 한 줄 | dispose 자리 0 — 판정 줄 불필요 |
| C4r5e-5 PowerShell 5.1 인코딩 | 정적 머리 ASCII · ② `Get-Content -Encoding UTF8` · 사전검사 앞 `[Console]::OutputEncoding` · 저장 파일 «BOM 있어도 됨» | infra 그대로 |
| C4r5e-6 타입이 막는 변이 | 예고 변이 (상태) «level 다시 매기기 = 참고 — 타입이 막음» | — |
| C4r5e-7 «자리 바꿈» · 입력 = 파일 이름만 | ■ 제출 ③ 견본 · 골든 표 입력 칸 | — |
| C4r5a-5 · C4r5a-7 | 예고 변이 «emptyLabel 빼기» · W01-04 양성 기준점 | — |
| C4r5c-5 (a) 흐름 = 클로저 | 공통 «흐름 = 클로저 칸» · 골든 흐름 전부 `(WidgetTester t) async {}` | (b) 해당 없음 |
| C4r5d-5 골든 명령 칸 | — | 해당 없음(명령 0 · 저장소 가짜 = testWidgets 안에서 새로) |
| C4r13a-3 · C4r13b-4 | — | R14a «6» 과 같다 — 통합 담당 test-only PR(이 카드 병합 뒤 권고) |
| 공통 교훈(R5a~R5e) | 머리 «교훈 반영» 줄 · 규칙 10 · 정적 실행 꼴 · N3 G1 조문 · W31 | — |
