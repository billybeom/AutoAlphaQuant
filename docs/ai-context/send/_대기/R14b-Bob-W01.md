# 발송 패킷 R14b-Bob-W01 — W-01 워치독 상태 (계약 v1.15 전제 · R14 2장 중 2번째 · M8 · «정확히 N» 소유)

> ⬜ **_대기 — 앞 카드 병합 기록 때 send/ 로**(2026-10-30 조립 · 앱 `rec/r14`) · 선행 = ① R14a 병합(squash `__R14A_SQ__` · 시작 기준 N = R14a 병합본 실측) ② 🔴 계약 v1.15 보강의 워치독 몫(G10 `WatchdogCheck.level` · G11 `m8/watchdog_paused` · `m8/watchdog_empty` · 휴장 표본 정리 · G14 `UnimplementedOpsStatusRepository` — ⬜ 발주자 결정 · ▶ 금지) ③ ✅ 누적 드라이런·지적 반영(R14a 드라이런 끝 위 · 아래 «드라이런» 줄) ④ ⬜ 발주자 확인 ①~⑪ ⑤ 「푸시해」 — 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R14a 브랜치(`ui/m8-n01-alerts`)는 건드리지 않는다.
> 만든 날 2026-10-30 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R14-Bob-M8b` 행(🔀 2분할 — R14a 카드 머리 «재분할 판정») + §3-0 + §3 공통 조문 + 이월 부록 «R14» 대상(R14a 카드 «6» 과 같은 표 · W-01 자리) · 화면 몫 원본 = `04_…` §7(`W-01` · 3분법 + `paused` · 수용 (a)~(e) · 그림 15) · §2-5(뷰어 = 조회) · `01_…` §4-1 `watchWatchdog` · 판독 메모(통합 담당 스크래치 `r14/read_memo.md` §2-3 · §5 G10~G13).
> 사전 조건 — ⬜ R14a 병합(PR `__R14A_PR__` squash `__R14A_SQ__` · `ui_shell` = lib 10파일 · 라벨 35 · 배럴 export 8줄 · 셸 주입 15줄 · PNG 34) · ⬜ 계약 v1.15(R14a 와 같은 보강 PR · 워치독 몫 = 아래 이름표) · ✅ 프롬프트 v2. 시작 기준 = R14a 병합본의 `flutter test`(packages/ui_shell) = **⟦실측: R14a 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 160(R14a 반영판 117 + 43)⟧** · 이 카드 끝 기대 = 시작 기준 N + **23**(뷰 17 + 골든 6) · 끝 = ⟦실측: 앞 카드 병합 기록 때 채움 · 드라이런 기대 «+183»⟧.
> 🔀 **재분할 판정** — 드라이런 = 새 `testWidgets(`·`test(` 줄 **8**(`watchdog_board_test` 7 · 골든 1) · lib **+127**(`watchdog_board.dart` 126 + 배럴 1) · 새 PNG **6** · 원천 **1**(`watchWatchdog`) → 임계 안 · 재분할 없음(R14 를 두 장으로 나눈 까닭 = R14a 카드 머리 «재분할 판정» — 🆕 임계는 한 장이어도 안 넘는다 · 감사 지적).
> 카드 기본값(⬜ 아래 «발주자 확인» ①~⑪ 가 확정 · 조립 단계 = 권고 = 카드 기본값): ⓐ 위젯 = `WatchdogBoard({super.key})`(`lib/src/watchdog_board.dart` · `ConsumerWidget` — R13a `OpsRhythm` 꼴) ⓑ **셸 파일·R14a 파일은 고치지 않는다** — 셸 연결 = 조립 앱 레지스트리 `AppRoutes.opsWatchdog` 칸(이 카드 밖) ⓒ 원천 = 기존 셸 주입 `shellOpsStatusRepositoryProvider` 의 `watchWatchdog()` 하나(새 주입 0) ⓓ 상태 모양 = `check.level`(`UiLevel` 전수 switch `_checkLook` · v1.15) — `stateCode` 미참조 · 지연(watch) ≠ 실패(blocked) 색 · paused·휴장 = 실패·결측 색 아님 · 🆕 글리프·색 = H-01 `_cellLook`(`ops_home.dart`) 글자 그대로(같은 `UiLevel` 은 화면마다 같은 기호 — 04 §2-3 «공통 계약(화면별로 다시 정하지 말 것)» · 명세 지적 · «일시정지» 라는 뜻은 엔진 `stateLabel` 이 말한다 · 발주자 확인 ⑪) ⓔ 글자 = `label` · `stateLabel` · `lastPingText` · `graceText`(null = 부재) 원문 그대로 — 유예값·개수·이름 리터럴 0 ⓕ 🔴 `slug` = 시크릿급 — 그리지도 · Key 로도 · 로그로도 · 비교로도 쓰지 않는다(Key = 순번만) · ping URL·키 필드 = 계약에 0(04 §7 «뷰모델에 없어야 정상» · 🆕 `slug` 필드 자체를 계약에서 빼는 안 = 발주자 확인 ⑩) ⓖ 행 탭 = `check.route`(데이터 · null = 탭 없음 · 🔵 표본 DELAYED 행 route = W-01 자기 자신 — 데이터대로 연다 · 판독 G13 · 🆕 v1.15 표본 정리 0 — W01-03 이 이 행으로 «탭 = route» 를 잡는다 · 발주자 확인 ⑥) ⓗ 하단 한계 고지 · 머리 «마지막 수신» · `holiday_notice` = 부재(필드 0 · G12 · 🆕 v1.15 가 워치독 창구를 고치는 지금이 가장 싼 창 — 발주자 확인 ⑤) ⓘ 새 lib 파일 1 · 공용 2(배럴 +1 · `test/shell_fakes.dart` 끝 절 — **끝 절 더하기만** · 라벨·주입 0) · 🔴 이 카드가 «정확히 N» 을 **소유**한다(R14 마지막 — 라벨 35 · 배럴 9 · 주입 15 · PNG 40) · Key 접두 `w01-` · 테스트 `test/watchdog_board_test.dart` · 골든 3이름 6장(`test/golden/w01_golden_test.dart` · 크기 = `kGoldenPhoneSize`).
> 🔴 **카드 덮개 필수 문장(04 §7 · prompt_M8 141~144)** — «체크 목록은 서버가 준 것만 — 개수·이름·유예값 리터럴 0 · 받은 차례 그대로» · «상태 = `level` 하나(성공·지연·실패 + 일시정지 · 지연을 실패색으로 칠하지 않는다 · paused·휴장을 실패·결측으로 칠하지 않는다)» · «슬러그·ping URL·키 = 시크릿급 — 화면·Key·로그·PR 어디에도 0 · 슬러그 파싱 0 · `/pause`·`/resume` 버튼 0» · «셸 파일·R13·R14a 테스트·PNG 는 고치지 않는다».
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 결정 9c(healthchecks.io) · v1.13 `DiagnosticCell.level` 선례(상태 모양 = `UiLevel`).
> ⬜ **발주자 확인 11건(권고 = 카드 기본값 · ⑩ 만 «판독 권고 ≠ 카드 기본값» — 아래 글)** — ① 순서 = R14a 병합 뒤(기본 · 공용 파일 «정확히 N» 을 이 카드가 소유) · 대안 = 계약 v1.15 워치독 몫만 먼저 풀리면 이 카드 먼저(그때는 «정확히 N» 을 R14a 로 옮겨 두 카드 재조립) ② 상태 모양 원천 = v1.15 `WatchdogCheck.level: UiLevel`(엔진 매핑 권고 = `OK`→ok · `DELAYED`→watch · `FAILED`→blocked · `PAUSED`→info · 휴장 성공 핑 → ok · 대안 = `WatchdogStateCodes` 상수 + 화면 switch — 코드 리터럴 비교라 비권고) ③ `w01_paused` 입력 = v1.15 `m8/watchdog_paused`(신설 · X1 유지보수 창 문구 · 대안 = 2이름 4장 · `w01_paused` = 01 §8 대기) ④ 휴장 표본 = v1.15 가 `m8/watchdog_holiday` 의 휴장 행을 «휴장 성공 핑»(`state_code` `PAUSED` → `OK` · level ok · 문구에 휴장)으로 정리(04 §7 «휴장 = 성공 핑» ↔ «paused = 네 번째 상태» 를 가름) · `holiday_notice` 형제 키 = 화면 밖 · 🆕 그래서 예고 변이 «`stateCode` 문자열 비교로 모양» 은 표본상 `level` 과 같다 → 🔵 참고로 옮김(정적 W07 이 `stateCode` 를 잡는다 · 드라이런 M10a) · 대안 = 휴장 행 `state_code` `PAUSED` 그대로 + level ok(일부러 갈리는 표본 — W01-02 holiday 가 그 변이를 잡는다 · 드라이런 M10c KILLED · 04 §7 «성공 핑» 글자와 어긋나 비권고) ⑤ 하단 한계 고지 · 머리 «마지막 수신» = 부재 + 01 §8 미결 신설(대안 = M2 `WatchdogBoardVm{rows, asOf, emptyLabel, holidayNotice?, limitNotice?, lastReceivedText?}` 로 창구 교체 — 🆕 명세 지적: 하단 고지는 «healthchecks.io 자체 장애 = 무경보» 를 알리는 안전 고지(04 §7 표 «한계·이력») · 호출처 = 셸 1곳뿐 · v1.15 가 `WatchdogCheck`·워치독 픽스처를 고치는 지금이 가장 싼 창 · 고르면 이 카드 재조립(머리 1줄·하단 1줄·테스트 +1 · `w01_*` 6장 다시 · 재드라이런) · 미루면 01 §8 미결에 소유 카드를 못박는다) ⑥ 자기 링크 행 = 데이터대로(같은 화면 한 장 더 쌓임 · 01 §8 미결 137 과 같은 뿌리) · 🆕 v1.15 표본 정리 0(권고 바꿈 — 그 행 route 를 null 로 지우면 W01-03 의 «링크 있는 행» 표본이 사라지고 전제 `// pre` 가 실패한다 · 감사·드라이런 지적) · 대안 = 실패 행 [4] 에 다른 route(예 `aaq://ops/rhythm`) + 자기 링크 둘 null · W01-03 을 [4] 로 · 예고 변이 «자기 링크 행 탭 막기» 빼기 ⑦ 빈 갈래 입력 = v1.15 `m8/watchdog_empty`(신설 · rows 0 · emptyLabel) · `FAILED` 표본 1행 = v1.15 `watchdog_delayed` 에 더함(6행) ⑧ 골든 크기 = `kGoldenPhoneSize` ⑨ 이월 반영(R14a «6» 과 같은 표 · 아래 «6») ⑩ 🆕 `WatchdogCheck.slug` — 카드 지금 글자 = 계약에 그대로(화면은 읽지 않는다 · 정적 W07·W09 · W01-07 탐침) · 판독 권고(명세 지적) = v1.15 에서 `slug` 를 빼고 비밀 아닌 `checkId`(엔진이 짓는 불투명 id · 슬러그 파생 금지)로 · 워치독 픽스처 4개에서 slug 키 삭제 · 슬러그 탐침은 domain_contracts «워치독 픽스처 JSON 에 slug 키 0» 계약 테스트로(이 카드 W01-07 의 슬러그 두 단언을 빼고 재드라이런) — W-01 은 전 플랫폼(뷰어 조회)이라 읽기 모델에 시크릿을 싣지 않는 쪽 · 남기기로 정하면 01 에 «slug 는 시크릿이 아니다(ping 키 없이는 위조 불가)» 를 적고 12 §3 조문(«슬러그 = 시크릿급»)을 고친다 — 두 문서가 다른 말을 하는 채로 두지 않는다 ⑪ 🆕 상태 아이콘 = H-01 `_cellLook` 글자 그대로(ok `check_circle_outline`·primary · info `info_outline`·onSurfaceVariant · watch `visibility_outlined`·tertiary · act `error_outline`·secondary · blocked `block`·error · 드라이런 = PNG 불변 — 테스트 글꼴에서 아이콘은 작은 네모 · 색은 조립 판과 같다) · 대안 = 조립 판(`pause_circle_outline` · `schedule` · `cancel_outlined` — 같은 `UiLevel` 이 화면마다 다른 기호) · 공용 모양 함수 추출 = 다음 셸 손질 카드(01 §8 후보).
> 드라이런: ✅ 누적 드라이런 2번째(2026-10-30 · worktree `C:/Work/AAQ-claude-r14dry` · 첫 판 가지 `dry/r14-2` = R14a 드라이런 끝 `e7cdbd9` → v1.15 워치독 몫 흉내 + R14a 병합 기록 흉내 `7a47f0f`(비교 기준 `dry/r14-2base`) → 권장 4커밋 · 🆕 반영판 가지 `dry/r14-2b` = R14a 반영판 `d57ce62` 위 같은 흉내(`a9effc7` · 비교 기준 `dry/r14-2base2`) + 4커밋 + (5) 글리프 `a5c149c`) · 시작 «+158» → 끝 «+181»(첫 판) · 반영판 «+160» → **«+183»**(`watchdog_board_test` +17 · `w01_golden` +6) · `domain_contracts` «+392 ~30» · 정적 = 아래 머리 수 · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0(머리 «12항») · 🟡 0 · 골든 dy 3(light = dark) · lib +127 · 변이 38꼴 + 테스트 쪽 2 = 예고 KILLED 29 · 🔵 참고로 옮김 1(M10a 동치 — 정적 W07) · 탐침 M10c KILLED · 참고 7 중 KILLED 5 · SURVIVED 2(R3 정적 W04 · R8 act 표본 0) · 테스트 쪽 T-a = 사전검사 T1 🔴 · T-b = 🔴 0(눈 — «예고 변이» 🔵).
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
  git grep -c "contractVersion = '⟦실측: v1.15 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 1.15.0⟧'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»
  git grep -c "Stream<ListResult<WatchdogCheck>> watchWatchdog();" -- packages/domain_contracts/lib/src/repositories/ops_repository.dart  ← «…ops_repository.dart:1»
  git grep -c "required UiLevel level," -- packages/domain_contracts/lib/src/dto/ops.dart                                           ← «…ops.dart:⟦실측: 앞 카드 병합 기록 때 채움 · 드라이런 기대 2 — DiagnosticCell(v1.13) + WatchdogCheck(v1.15)⟧»
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
  flutter test   ← 시작 기준: R14a 병합본 전부 통과 · 기대 «+⟦실측: R14a 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 160⟧: All tests passed!»(끝 줄의 수를 «시작 기준 N» 으로 · 다르면 PR 본문에 까닭 한 줄 · 실패가 있으면 멈추고 끝 20줄을 채팅으로)
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 계약 v1.15 이름표(워치독 몫 · 🔴 코드가 정본 — 다르면 멈추고 질문 파일에)
  dto/ops.dart  WatchdogCheck 에 required UiLevel level(엔진 매핑 — 성공·휴장 성공 핑 = ok · 지연 = watch · 실패 = blocked · 일시정지 = info) · 그 밖 필드 그대로(slug · label · stateCode · stateLabel · lastPingText · graceText? · route? — 🆕 slug 를 빼는 안 = 발주자 확인 ⑩)
  testing.dart  UnimplementedOpsStatusRepository(받침대)
  FixturePaths  m8WatchdogDelayed(6행 — 성공 3 · 지연 2(route = 자기 링크 그대로) · 실패 1) · m8WatchdogHoliday(5행 — 휴장 성공 핑 3(state_code OK · level ok) · 성공 2 · 형제 키 holiday_notice) · m8WatchdogPaused(🆕 5행 — 일시정지 3 · 성공 2) · m8WatchdogEmpty(🆕 행 0 · emptyLabel)

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
10 테스트 = 받침대 extends(UnimplementedOpsStatusRepository) · 🔴 implements 가짜 0(정적 W26) · 호출마다 새 Stream · 가짜 공장 = 받은 call 로 삼항 · 따로 세는 변수 = calls 하나 · 공장 안 early-return if 0 ·
   픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다 — 자리 = testWidgets 본문 첫머리
     (main() 바로 아래의 expect 는 테스트 밖이라 파일 적재가 OutsideTestException 으로 실패한다) · 전제 문장마다 끝에 `// pre`(ASCII · 정적 W30 이 센다 = 최소 목록의 «(전제)» 수) · 동작은 UI 를 실제로 눌러서 ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(ShellLabels.retry), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(전부 픽스처 · copyWith 0 — 정적 W27) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 픽스처마다 갈리는 단언은 if/else 양쪽에 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴 ·
   테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII · «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2) ·
   🔴 반려 꼴: bool 칸 + if 로 경우 흐름 가르기 · c.name == / flow.name == 비교 · opened[0] 만 보기 · expect(a || b, isTrue) · 괄호 단언(«X 0(Y 0)» — 단언마다 따로) · 단언 없는 tester.takeException();(쓰면 expect(tester.takeException(), isNull) 꼴 · 정적 W31) ·
   제네릭 위젯 술어 = tester.widget<Icon>(find.descendant(of: find.byKey(…), matching: find.byType(Icon))) 꼴만 — 아이콘 단언 = expect(icon.icon, _wantIcon(…)) · expect(icon.color, _wantColor(…)) 두 줄
     (🔴 find.byType(Icon) 류를 단독으로 세기 · isNotNull · findsWidgets 로 약하게 바꾸기 = 늘 참 — 사전검사는 못 잡아도 C4 가 눈으로 본다 · 드라이런 T-b) ·
   스켈레톤 1 = expect(find.byKey(const Key('w01-loading')), findsOneWidget) 꼴 · Key 를 단 묶음(InkWell)의 글자 = shownTexts(tester, find.byKey(…)) == 기대 목록(R13a 도우미 · 트리 순서) ·
   🔴 Key 가 Text 자체에 붙은 자리(w01-empty)는 shownTexts 가 [] 를 낸다(find.descendant 는 뿌리를 세지 않는다 — 드라이런 지적) → expect(tester.widget<Text>(find.byKey(const Key('w01-empty'))).data, want) 꼴만.
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 한 줄(n = 정수 리터럴 — 지연 표본 6 · 경우 칸의 리터럴) · 🔴 전제에 hasLength 0 ·
      정적 W17·W18 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(watchdog_board_test ⓡ 6 · ⓗ 2).
   «없는 쪽» 견본 · «화면 Text 전부» 견본 = 아래 글자 꼴(🆕 이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
        final String? want = c.want;                              // 경우 칸 = 기대 글자 String?(empty = 픽스처 emptyLabel · 그 밖 = null)
        if (want != null) {
          expect(tester.widget<Text>(find.byKey(const Key('w01-empty'))).data, want);
          expect(find.byKey(const ValueKey<String>('w01-row-0')), findsNothing);
        } else {
          expect(find.byKey(const Key('w01-empty')), findsNothing);
          expect(find.byKey(const ValueKey<String>('w01-row-0')), findsOneWidget);   // 양성 기준점
        }
        🔴 반려 꼴: if (want != null) { expect(…); }(else 없음) · if (x != null) { expect(x, isNotNull); … }(if 안의 전제 = 늘 참)
        «화면 Text 전부»(R13a T02-07 꼴 · allowed = watchdogAllowed(c.v) · 🔴 견본 뒤 ⓡ 는 테스트 끝 한 줄만 — 견본 안에 ⓡ 를 두지 않는다):
        final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(allowed));
        }
11 골든 = 새 PNG w01_* 6장 · --update-goldens 는 w01_golden_test.dart 만 · 기존 PNG(34장) 재생성 0 · golden:approved 안 붙임 · 🔴 높이(kGoldenPhoneSize 844)는 늘리지 않는다(카드 확정값 · 여백을 줄이면 «측정:» 전·후 행).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(5분 넘게 출력이 없으면 끊고 패키지별 flutter test) ·
   패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · close_sinks · prefer_final_locals.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 화면에는 산술이 없다).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL·슬러그 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — lib/src/watchdog_board.dart 주석에 이 낱말을 쓰지 않는다: slug · secret · healthchecks · ping url · api key · stateCode · DateTime.now · AppRoutes · FeatureFlags · runMode · Duration · Colors · RichText · autoDispose · Scaffold · Navigator · 추천 · 권유 · 자문 · 시그널.
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려** · 카드 구멍 = 반려 근거 아님.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다).
   PNG 는 이름마다 light 한 장만 연다(3장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지) · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 줄 n» = PNG 의 글자 **행** 수 · «상자» = 테두리·모서리가 보이는 덩어리 · «배경 덩어리» = 폭 전체 배경 · «막대» = 가로로 긴 덩어리 · «점» = 작은 둥근 표식 · «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다 ·
     🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 제출 글은 저장 파일로) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · 출력 줄 수만큼) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M8.md 173~182행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외).

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
 ⑯ 172~182행 자체 점검 10항 → «■ 제출» ② 복사 상자 + 괄호(🆕 괄호 글자 = ■ 제출 ② «붙일 괄호» 가 정본 · 범위 밖도 [x] · 섹션 머리는 «12항» 그대로 — 사전검사 R1)
 🔵 낡은 줄 하나: 끝난 R13b 카드 «이긴다» ② 의 «W-01 = R15~R16» → 정본 = 설계 12 §3 R14 행(W-01 = R14 · 이 카드).

■ 먼저 읽을 것 (🔴 02·03·05 명세는 읽지 않음)
 ① prompt_M8.md 전문 ② 04 §7(W-01 · 표 · 수용 (a)~(e) · 그림 15) · §2-5(뷰어 = 조회) ③ 01 §4-1 watchWatchdog · ⟦v1.15: 01 §24 절 번호⟧
 ④ packages/domain_contracts/lib/ — src/dto/ops.dart(WatchdogCheck · level) · src/enums/ui.dart(UiLevel) · src/repositories/ops_repository.dart · src/primitives/list_result.dart · as_of.dart · testing.dart(UnimplementedOpsStatusRepository · RecordingLinkOpener)
 ⑤ packages/ui_shell — lib/src/ops_rhythm.dart(🔵 이 화면의 꼴 선례 · 읽기만) · test/ops_rhythm_test.dart · test/shell_fakes.dart · test/golden/h02_golden_test.dart · golden_support.dart · golden README «🆕 R14» 절
 ⑥ fixtures/README.md(m8 행 · 봉투 형제 키) ⑦ docs/ai-context/inbox/README.md · W01_questions.md 머리말

■ 본받지 않는 것
 · S-02 웹 사이드바·셸 파일에 워치독 진입을 더하는 것 · R13b 의 FakeShellOpsStatusRepository 를 고치는 것(새 가짜 = 끝 절)
 · stateCode == 'DELAYED' 류 문자열 비교로 색을 고르는 것 · 지연을 errorContainer·error 로 · paused·휴장을 «결측» 으로(행을 빼거나 «-»·빈칸으로 채우기 — 🔵 info 의 onSurfaceVariant 아이콘은 결측이 아니다 · H-01 과 같은 기호) · 휴장 행을 따로 거르기
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
 _checkLook(ColorScheme cs, UiLevel l) = switch (l) { UiLevel.ok → (Icons.check_circle_outline, cs.primary) · info → (Icons.info_outline, cs.onSurfaceVariant) · watch → (Icons.visibility_outlined, cs.tertiary) ·
         act → (Icons.error_outline, cs.secondary) · blocked → (Icons.block, cs.error) }(🆕 = H-01 ops_home.dart _cellLook 글자 그대로 · 🔴 watch ≠ blocked · info ≠ blocked · 아이콘에 Key 0 · 반환 = (IconData, Color) 레코드)
 하단 한계 고지 · 머리 «마지막 수신» · 휴장 고지 문장 = 부재(필드 0 · 코드 0)

■ 픽스처 (FixturePaths.… · listFixture · 🔴 전제 expect 로 다시 확인)
 delayed  listFixture(m8WatchdogDelayed, WatchdogCheck.fromJson) — 6행(성공 3 · 지연 2(graceText · [1] route non-null — 자기 링크 표본 · v1.15 정리 0) · 실패 1) · [0] route null · emptyLabel null · asOf «워치독 기준 2026-08-31»(26h)
 holiday  listFixture(m8WatchdogHoliday, …) — 5행(휴장 성공 핑 3 · 성공 2 · level 전부 ok · 휴장 행 state_code OK — 04 §7 «휴장 = 성공 핑») · 형제 키 holiday_notice 는 읽지 않는다
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
  `one<T>` · `shownTexts` = 앞 카드 도우미 그대로(shell_fakes.dart) · valueThenFail = 지역 함수 · 값 안 내는 스트림 = Stream<T>.multi((MultiStreamController<T> c) {})(닫지 않는다) ·
  🆕 test/watchdog_board_test.dart import 차례 = 'dart:async'(MultiStreamController · 드라이런 지적) → 'package:domain_contracts/domain_contracts.dart' → 'package:domain_contracts/testing.dart' → 'package:flutter/material.dart' →
     'package:flutter_test/flutter_test.dart' → 'package:ui_shell/ui_shell.dart' → 'golden/golden_support.dart' → 'shell_fakes.dart'(안 쓰는 것 0 — analyze 가 정본).
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
        규칙 10 «없는 쪽» 견본 그대로(Text 에 붙은 Key — tester.widget<Text>(find.byKey(const Key('w01-empty'))).data == want · 양성 기준점 w01-row-0) · w01-asof findsOneWidget · ⓡ.
 W01-05 갈래 × 상태(🆕 갈래마다 배너 C4r5e-3) — 다섯 경우 ㉠ (loading · Stream.multi(값 0) · [w01-loading] · [w01-asof, w01-fail] · 배너 0) · (fail · Stream.error · [w01-fail] · [w01-asof, w01-loading] · 0) ·
        (value_then_fail · valueThenFail(delayed) · [w01-fail] · [w01-asof] · 0 · 흐름 = find.text(delayed.asOf.label) findsOneWidget) · (stale · one(delayed) · 오래됨 · [w01-asof, w01-row-0] · [w01-fail] · 1 · 흐름 = 배너 dy < w01-row-0 dy) ·
        (stale_empty · one(emptyV) · 오래됨 · [w01-asof, w01-empty] · [w01-fail] · 1 · 흐름 = 배너 dy < w01-empty dy)마다 Key 목록 findsOneWidget / findsNothing · 배너 = c.banner ? findsOneWidget : findsNothing · 흐름 · CircularProgressIndicator findsNothing.
 W01-06 재시도 — 공장 = (int call) => call == 0 ? Stream<ListResult<WatchdogCheck>>.error(StateError('fail')) : one(delayed) → tap(find.text(ShellLabels.retry)) → pump 두 번 → w01-fail findsNothing · w01-asof findsOneWidget · ops.calls == 2 · ⓡ.
 W01-07 화면 Text 전부 · 슬러그 0 · 큰 글꼴(04 §7 수용 (c) · prompt 141) — 세 경우 ㉠ (delayed) · (holiday) · (paused)마다 규칙 10 «화면 Text 전부» 견본(allowed = watchdogAllowed(c.v)) →
        행마다 expect(find.textContaining(row.slug), findsNothing) · expect(find.byKey(ValueKey<String>(row.slug)), findsNothing) → textScaleFactorTestValue = 2.0 → takeException isNull · ⓡ.
 ⓡ 기대 = watchdog_board_test.dart 6줄(W01-01 · 02 · 03 · 04 · 06 · 07) · ⓗ 기대 = 2줄(W01-01 · 02) — 🔴 정확히 · (전제) = 9(01 1 · 02 3 · 03 2 · 04 3 — 정적 W30).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 통과하면 반려 · 갈래마다 짝):
   (순서·목록) 행 뒤집기 · 행 둘 자리 바꾸기 · 행 다섯만(take(5)) · 휴장 행 거르기 · 실패 행을 맨 위로.
   (상태) 지연을 실패색으로(watch → cs.error) · 일시정지를 실패색으로(info → cs.error) · 아이콘 하나로 고정 · 색 하나로 고정 · stateCode 두 갈래 비교로 모양(DELAYED·FAILED 밖 = ok) ·
     🔵 참고 — 타입이 막음(적용 불가): «level 을 화면이 다시 매기기»(final 필드) · 🔵 참고 — 표본상 동치 · 정적이 잡음(예고 아님): «stateCode 네 갈래 문자열 비교로 모양»(엔진 매핑이 state_code 의 함수라 v1.15 표본에서 level 과 같다 · 드라이런 M10a SURVIVED · 정적 W07 이 stateCode 를 본다) ·
     🔵 참고 — 표본 0: «act 갈래 색 바꾸기»(엔진 매핑이 act 를 쓰지 않는다 · 드라이런 R8).
   (글자) stateLabel 빼기 · lastPingText 빼기 · graceText 빼기 · graceText null 에도 빈 줄 · 유예 글자를 화면이 짓기(정적 라벨 더하기) · 슬러그를 글자로(탐침) · 슬러그를 Key 로.
   (링크) 행 탭 0 · route null 에도 탭 · 자기 링크 행 탭 막기(링크 비교) · 🔵 참고 — 정적이 잡음: «행 탭 링크를 'aaq://ops/watchdog' 리터럴로»(표본 route 와 같다 · 정적 W04 · 드라이런 R3).
   (빈·상태 — 갈래마다) emptyLabel 빼기 · 에러를 스켈레톤으로 · 값 뒤 에러에 마지막 asOf 글자 빼기 · 재시도 invalidate 0 · 오래됨 배너 빼기(행 있음 · 빈 — 둘 다) · 신선도 비교 뒤집기 · 벽시계로 신선도 · 화면에 정적 글자 하나 더하기.
   🔵 판정 = 변이마다 ui_shell 의 flutter test 전부(골든 포함) + 정적 묶음(🔵 참고 «정적이 잡음» 몫) · 🔵 C4 눈 검사 — W01-02 아이콘 단언이 _wantIcon/_wantColor 두 줄 꼴인지(약하게 바꿔도 사전검사 🔴 0 · 드라이런 T-b) ·
     드라이런 = 38꼴(예고 30 · 탐침 1 · 참고 7) + 테스트 쪽 2 — 예고 KILLED 29 · M10a → 🔵 참고 · 탐침 M10c KILLED · 참고 KILLED 5 · SURVIVED 2(R3 · R8 → 🔵 참고) · T-a(else 없는 if) = 사전검사 T1 🔴 · 예고 SURVIVED 0 · 🆕 글리프 반영판 = 전부 통과(PNG 불변).

■ 정적 묶음 — 아래 32줄을 파일로 꺼내 Git Bash 로 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다(대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 머리 ASCII · «EXIT:1» = 출력 없음 · 출력 줄 수(EXIT 줄 포함) = 115줄 — 붙이기 전에 세어 같은지 본다)
  🔴 터미널에 붙여 넣어 돌리지 않는다(대화형 bash 는 ! 든 줄을 건너뛸 수 있다 · bash 라고만 치면 이 PC 에서는 WSL)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 손으로 옮겨 쓰지 않는다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R14b-Bob-W01.md' | sed -n '268,299p' > ../../build/r14b_static.sh"
  git hash-object ../../build/r14b_static.sh   ← ffe157aa1672d18ebc86980eb3a46158992e5590(= 아래 32줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r14b_static.sh > ../../build/r14b_static_out.txt"
  Select-String -Path ..\..\build\r14b_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음이어야 한다(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r14b_static_out.txt).Count   ← 115(EXIT 줄 32 포함) · (Select-String -Path ..\..\build\r14b_static_out.txt -Pattern '^EXIT:1$').Count ← 18 · -Pattern '^EXIT:0$' ← 14
  ② 에 붙일 출력 = Get-Content -Encoding UTF8 ..\..\build\r14b_static_out.txt 전부(build/ 는 .gitignore 대상 — git status 는 빈 채 · 커밋 0 · 할 일의 «미리 돌리기» 도 이 꼴)
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
echo "## W25 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/ui_shell.dart test/shell_fakes.dart lib/l10n/labels.dart lib/src/shell_providers.dart lib/src/shell_scaffold.dart lib/src/routing/shell_router.dart lib/src/common/shell_common.dart lib/src/ops_rhythm.dart lib/src/ops_home.dart lib/src/alerts pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/alert_center_test.dart test/alert_detail_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## W26 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W27 copyWith in tests 0"; git grep -n "copyWith(" -- test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W28 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/watchdog_board_test.dart test/golden/w01_golden_test.dart; echo "EXIT:$?"
echo "## W29 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## W30 precondition marks (pre)"; git grep -c "// pre$" -- test/watchdog_board_test.dart; echo "EXIT:$?"
echo "## W31 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/watchdog_board_test.dart; echo "EXIT:$?"
echo "## W32 golden PNG total (40 exact)"; git ls-files -- test/golden/goldens | grep -c "\.png$"; echo "EXIT:$?"
  (줄의 뜻과 기대(✅ 드라이런 실측과 같다 · 2026-10-30) — W01 = 주석 줄 말고 출력 없음 · W02 = 출력 없음 · W03 = 2줄(w01_golden 1 · watchdog_board_test 7) · W04 = 0 · S05 = 1줄(행 탭 콜백 안) · W06 = 1줄 · W07 = 0 ·
   W08 = 5줄(_checkLook 다섯 갈래) · W09 = 0(🔴 주석 포함 · 앞 카드 파일 포함) · W10 = «lib/l10n/labels.dart:35»(🔴 정확히 — R13 31 + R14a 4 + 이 카드 0) · W11 = 9줄(… src/shell_scaffold.dart · 🆕 src/watchdog_board.dart 차례 · 🔴 정확히) ·
   W12 = 15줄(🔴 정확히 — 이 카드 몫 0) · W13~W16 = 0 · W17 = «test/watchdog_board_test.dart:6» · W18 = «test/watchdog_board_test.dart:2»(🔴 정확히) · W19 = 이름 5 = 위 «Key 표»(w01-row 는 머리만 · 표 밖 0) · W20~W24 = 0 ·
   W25 = 두 줄(lib/ui_shell.dart 1 · 0 · test/shell_fakes.dart <n> · 0 — 그 밖 파일 줄 없음(🆕 앞 카드 골든 테스트 5파일 포함) · 🔴 labels.dart · shell_providers.dart 줄 0) · W26 = 0 · W27 = 0 · W28 = 0 · W29 = 6줄 전부 «A»(w01_* 만) · W30 = «test/watchdog_board_test.dart:9»(🔴 정확히) · W31 = 0 ·
   W32 = «40»(🔴 정확히 — R13 24 + R14a 10 + 이 카드 6))

■ 골든 — 3이름 × light/dark = 6장(전부 신규 · 이름 = 04 §7 수용 (d) 글자 그대로 · golden README «🆕 R14» 절 표 그대로)
  w01 — test/golden/w01_golden_test.dart · 크기 = kGoldenPhoneSize(390 × 844 · 드라이런 맨 아래 dy = w01_delayed 584.0 · w01_holiday 440.0 · w01_paused 480.0 — light = dark) · 위젯 = WatchdogBoard() · 저장소 = FakeShellWatchdogRepository(…)(🔴 testWidgets 안에서 새로 · _Flow 칸에 인스턴스 0) · 시계 = FixedClock(kGoldenNowUtc):
    이름           입력      흐름    맨 아래 Key
    w01_delayed    delayed   없음    ValueKey<String>('w01-row-5')
    w01_holiday    holiday   없음    ValueKey<String>('w01-row-4')
    w01_paused     paused    없음    ValueKey<String>('w01-row-4')
  모양 = h02_golden_test.dart 와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록 × Brightness.values · 흐름 = 클로저 칸 · 테스트 이름 '${flow.name} ${brightnessSuffix(b)}' ·
  주입 = pumpForGolden(tester, const WatchdogBoard(), brightness: b, logicalSize: kGoldenPhoneSize, wrapApp: (Widget app) => ProviderScope(overrides: watchdogOverrides(…), child: app)) → pump → 흐름 → pumpAndSettle → 위치 전제 둘 → expectGolden.
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
  flutter test   ← 옵션 없이 전부 통과(기대 = 시작 기준 N + 23 — ⟦실측: 앞 카드 병합 기록 때 채움 · 드라이런 기대 160 → «+183: All tests passed!»⟧)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← 실패 0 · 기존 ui_journal 🟡 1건 그대로
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · domain_contracts «+⟦실측: v1.15 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 392⟧ ~30»(이 카드 몫 0) · «Some tests failed»·«FAILED» 0건 · format 0 changed · 🔴 백그라운드·파이프 금지(&& 가 안 되면 한 줄씩)
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
  PR 본문 5섹션을 저장 파일로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로 — 자체 점검 상자는 10줄이지만 머리 글자는 사전검사가 정한다 · 🔴 «10항» 으로 고치면 🔴 R1 · 드라이런 지적):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 저장 파일 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R14b-Bob-W01_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R14b-Bob-W01_submit.md --golden-prefix w01 --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r14b_pre2.txt; Get-Content -Encoding UTF8 $env:TEMP\r14b_pre2.txt | Select-Object -Last 1
        ← 🔴 끝 줄 «── 결과: 🔴 0 · …» 를 확인한 뒤에만 낸다 · 출력은 채팅에 붙이지 않는다 · 🟡 [G1] = 멈춤 아님(드라이런 기대 🟡 = 0) · 🔴 🟡 가 하나라도 나오면 그 행의 light PNG 를 다시 열어 표를 맞춘다 — 다시 열지 않고 그대로 내면 ② 반려(C4r5d-1).
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + name-status 출력 그대로(코드 블록 하나) + «커밋 목록:» + log 출력 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: W-01 — 워치독 상태(WatchdogBoard())
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항(머리는 «12항») — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다 ·
     꼴 = «N. <prompt 글자> [x] ( )» — [x] 는 글자 뒤 · 🆕 이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
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
      ┌── 복사 시작(다음 줄부터 · 10줄)
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] ( )
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] ( )
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] ( )
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] ( )
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] ( )
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] ( )
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] ( )
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] ( )
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M8.md 173~182행과 같습니다)
      10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r14b_box2.txt)에 저장 → (Get-Content -Encoding UTF8 $env:TEMP\r14b_box2.txt).Count → 출력 한 줄을 아래 «10항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 10):
      ┌── 10항 줄 수 복사 시작(다음 줄부터 · 4줄)
10항 줄 수:
```
<출력 한 줄>
```
      └── 10항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 32줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄(S05 출력 줄마다 한 줄 · 기대 1줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(W17·W18 출력 줄 그대로 복사) + «테스트 파일별:» + 위 flutter test 두 파일 끝 줄 그대로(watchdog_board · w01_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = W17 출력:
<W17 출력 줄 그대로>
ⓗ = W18 출력:
<W18 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — 아래 견본 2줄 글자 그대로(«정상» 한 줄 + «빈»·«로딩»·«에러»·«오래됨» 한 줄 · 🆕 다섯 줄로 펼치지 않는다 · «자리 바꿈» 줄도 펼치지 않는다) + 골든 표 6행 ·
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2):
         «정상» = ListView → Key('w01-asof') → ShellStaleBanner(있을 때) → ValueKey<String>('w01-row-$i') → Key('w01-empty')(있을 때)
         «빈» = «정상» 의 행 자리에 Key('w01-empty') · «로딩» = ShellSkeleton(Key('w01-loading')) · «에러» = ShellErrorView(Key('w01-fail')) · «오래됨» = ListView → Key('w01-asof') → ShellStaleBanner → ValueKey<String>('w01-row-$i')
      골든 표 6행(한 표 · 한 행 한 줄) = «| 이름 | 입력 픽스처 | 크기 | 위치 전제 dy | 배치·잘림 |» + 바로 다음 줄 구분 줄 «|---|---|---|---|---|»(없으면 표로 그려지지 않는다) · 이름 칸 = «w01_delayed light» 꼴 ·
        입력 = 파일 이름만(watchdog_delayed.json · watchdog_holiday.json · watchdog_paused.json) · 크기 = 390×844 · dy = 이름·밝기마다 잰 값 · light PNG 한 장씩(3장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 점 · 아이콘> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(6행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다) ·
        셈 단위 견본 1행(드라이런이 PNG 를 열어 쓴 칸 · 🔴 같은 이름 행은 꼬리까지 견본 글자 그대로 — PNG 가 다르게 보이면 칸을 바꾸지 말고 질문 파일에): «| w01_delayed light | watchdog_delayed.json | 390×844 | 584.0 | 글자 21줄 — 잘림 없음 |»
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
- `flutter test` = 시작 기준 N(⟦실측: R14a 병합본 — 앞 카드 병합 기록 때 채움 · 드라이런 기대 160⟧) + 23 · 정적 W10 = 35 · W11 = 9 · W12 = 15 · W17 = 6 · W18 = 2 · W30 = 9 · W32 = 40(🔴 정확히) · W08 = 5 · S05 = 1 · W06 = 1 · W29 = 6 A.
- 재분할 임계(드라이런): 줄 8 · lib +127 · PNG 6 → 재분할 없음 · 정적 출력 115줄.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R14b-Bob-W01 결과: 브랜치 ui/m8-w01-watchdog 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**(`notepad $env:TEMP\R14b-Bob-W01_submit.md` → Ctrl+A → Ctrl+C)를 붙여넣습니다. 0단계에서 멈췄다면 `R14b-Bob-W01 0단계에서 멈춤 — 확인해줘` + 출력.

## 5. 주의

- **5분 눈 검사**: ① `labels.dart`·`shell_providers.dart`·셸·홈·리듬·알림 파일·기존 테스트·PNG 가 `M` ② `watchdog_board.dart` 에 `slug`·`stateCode`·`'aaq://`·`AppRoutes`·`Duration(`·`.where(`·`split(`·`print(` ③ 지연 행이 빨강·실패 아이콘 ④ 휴장·일시정지 행이 회색 «결측» ⑤ `/pause` 버튼 ⑥ 슬러그가 Key 에.
- 🔵 `golden:approved` 불필요(새 PNG 만).
- 🔵 R14 마지막 카드 — 병합 기록이 R14 완료(🏁)를 적는다 · 다음 = 12 §6 큐(R15) · 통합 담당 test-only PR(C4r13a-3 · C4r13b-4 · R14a «6» 권고).
- ⬜ 자리표시자 = `__R14A_SQ__` · `__R14A_PR__`(R14a 병합 기록 때 채움) · 남은 실측 표식 ⟦ … ⟧(`grep -cP '\x{27E6}'`) = R14a 병합본 실측(시작 기준 N · 끝 N · 계약 버전 줄 · `required UiLevel level,` 수 · `domain_contracts` 수 · 01 v1.15 절 번호 — «앞 카드 병합 기록 때 채움 · 드라이런 기대 …» 표시) · ✅ 누적 드라이런 실측(정적 줄 범위·해시·출력 수 · dy · 견본 칸 · lib · 변이)은 채웠다(2026-10-30 · 앞 카드 병합본이 드라이런과 다르면 그때 다시 잰다) — 🔴 보내기 전 0.
- 범위 고지: 하단 한계 고지 · 머리 «마지막 수신» · 휴장 고지 문장 · 자기 링크 행(G12 · G13) = 01 §8 미결 신설 후보(발주자 확인 ⑤⑥ — 미루면 소유 카드를 함께 적는다) · 미결 137(ShellLinkOpener 늘 push) = 이 카드가 닫지 않는다 · 🆕 04 §2-3 공통 상태 ⑤ 차단 = 셸 §2-4 배너 슬롯 몫(본문 0) · ⑥ 부분 동기 = 계약 필드 0 → 부재(01 §8 미결 후보) · 🆕 공용 모양 함수(`UiLevel` 아이콘·색 — H-01·W-01 이 같은 글자를 따로 둔다) 추출 = 다음 셸 손질 카드(01 §8 후보).

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
