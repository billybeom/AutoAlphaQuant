# `test/golden/` — 위젯 골든 스냅샷 (~~**아직 비어 있다**~~ → ~~**8장** · 2026-10-27 R13a 병합 PR #71 `315bbbd`~~ → ~~**24장** · 2026-10-27 R13b 병합 PR #74 `49e4329`~~ → **34장** · 2026-10-31 R14a 병합 PR #87 `185e9c7`)

정본: 01_M2_도메인계약 **§7** · 07_AI어시스턴트_배포프롬프트 **§9** 기계 검사 4

## 🔴 «최초 생성»과 «재생성»은 다르다

| 구분 | 누가 | 규칙 |
|---|---|---|
| **뷰모델 골든** `*.golden.json`(C-1) | 🔴 M2(Claude) 소유 | 화면 담당은 **읽기만**. 깨지면 표시 계약이 바뀐 것이므로 **고치지 말고 질문 목록에 올린다** |
| **위젯 골든 PNG**(C-2) | 화면 담당 | **신규 화면의 최초 베이스라인은 그 화면을 만드는 PR에서 함께 커밋**한다. 이후 **픽스처가 그대로인데 다시 찍는 것은 위조**이며 반려 |

병합 검사는 `git diff --name-status`로 **A(추가)**와 **M(수정)**을 구별한다.

## 규칙

- 렌더 입력은 `packages/domain_contracts/fixtures/`다. **화면 담당은 픽스처를 수정하지 않는다.**
- light / dark 두 벌.
- 임계 조정은 M2가 한다.
- 🔴 홈 골든은 **손익 숫자가 한 개도 없다는 것**을 눈으로 확인하는 프레임이기도 하다(결정 8 · C-6).

## 🆕 R13(계약 v1.12) — `S-01`·`S-02`·`H-02`(R13a) · `H-01`(R13b) (2026-10-26 조립 · ✅ 누적 드라이런 실측(`dry/r13a` `8ea11c9` · `dry/r13b` `d469af0`) · ~~⬜ 병합 전~~ ✅ R13a 병합 PR #71 `315bbbd` 2026-10-27 · R13b ~~⬜ 재드라이런 대기~~ ✅ 재드라이런 2026-10-27(계약 v1.13 PR #72 `638fca4` 위 · `dry/r13b2` · 16장 · dy 그대로) · ~~▶ 「푸시해」 뒤 보냄~~ → 🔴 1회차 반려(PR #74 `81d9ace` · C4h-1 골든 높이 1300 외) → 재제출 `deb37d7` → ✅ R13b 병합 PR #74 `49e4329` 2026-10-27)

정본: 01 §21-16(21-16-1b R13 분할 · 21-16-4 범위) · 04 §3-1 수용 (d) · §4-6 수용 (f) · 설계 저장소 `10_리뷰/2026-10-22_R5R13선행_계약v1.12_설계서.md` §8-1b(✅ K46 · R13a 8장 → R13b 16장). 카드 = ~~`docs/ai-context/send/R13a-Bob-S01H02.md`~~ `docs/ai-context/send/_완료/R13a-Bob-S01H02.md`(R13a · 재제출 `_완료/R13a-Bob-S01H02-재제출.md`) · ~~`docs/ai-context/send/_대기/R13b-Bob-H01.md`~~ ~~`docs/ai-context/send/R13b-Bob-H01.md`~~ `docs/ai-context/send/_완료/R13b-Bob-H01.md`(R13b · 2026-10-27 R13a 병합 기록 때 `send/` 로 · 1회차 반려 기록 때 `_완료/` · 재제출 `_완료/R13b-Bob-H01-재제출.md`). 🔴 화면 담당(Bob)은 이 README 를 고치지 않는다 — 병합 기록 커밋(통합 담당)이 실측을 적는다.

### 0. 하네스 — `ui_shell` 첫 골든(R13a)이 비교기를 옮긴다

- `golden_support.dart` = ✅ K48 · M2 소유(계약 v1.12 · `ui_journal` 판 + `extraFixture`) — 화면 카드는 고치지 않는다.
- 비교기 2파일 = R13a 가 **추가**한다(카드 규칙 1 예외 · 그 밖에는 «고치면 반려» 파일): `test/flutter_test_config.dart` = `packages/ui_journal/test/flutter_test_config.dart` 그대로 + 머리 1행의 패키지 이름만 `ui_shell` · `test/golden/shift_tolerant_compare.dart` = `ui_journal` 판 바이트 그대로 · `comparator_test.dart` 는 옮기지 않는다(자체 검증 = `ui_journal`·`ui_analytics` 판). 이 둘이 없으면 기본 비교기(픽셀 완전 일치)라 리눅스 CI 에서 깨진다.
- 베이스라인 = **새 테스트 파일만 지정** `flutter test --update-goldens test/golden/<id>_golden_test.dart`(폴더 지정 금지 · `ui_journal` README «🆕 R2» 와 같은 규칙) → 옵션 없이 `flutter test` 전부 통과.

### 1. 골든 이름 — R13a 4이름 × light/dark = 8장 · R13b 8이름 × 2 = 16장 · 재생성 0

| 이름 | 장수 | 테스트 파일 | 입력 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `s01_tabs_p0` | 2 | `s01_golden_test.dart`(R13a) | 위젯 `const ShellBandOverlay(child: ShellRoot())` · 플랫폼 androidOperator · 레지스트리 빈 · 알림 = `alerts_12`(P0 미확인 2) · 플래그 = 테스트 const `kFlagsSimAdvisory`(픽스처 0) — 띠 칩 2(띠 바탕 = 폭 전체 · `Column(crossAxisAlignment: stretch)`) · 제목 접두 2 · 홈 점 · `Key('s01-tabs')` 아래 끝 = 844 · `Key('s01-band')` 머리 0.0 |
| `s01_tabs_clean` | 2 | 〃 | 알림 = `m8/alerts_digest`(P2 3 · P0 0) · 플래그 = `kFlagsLiveAuto` — 띠 0 · 점 0 · `Key('s01-tabs')` = 844 · `AppBar` 머리 0.0 |
| `h02_rows` | 2 | `h02_golden_test.dart`(R13a) | 위젯 `const OpsRhythm()` · `m8/ops_rhythm_rows`(5행) · `ValueKey<String>('h02-row-4')` < 높이 · `Key('h02-asof')` 0.0 |
| `h02_not_loaded` | 2 | 〃 | `m8/ops_rhythm_empty`(NOT_LOADED · `emptyLabel`) · `Key('h02-empty')` < 높이 · `Key('h02-asof')` 0.0 |
| `h01_normal` | 2 | `h01_golden_test.dart`(R13b) | 위젯 `const OpsHome()` · `m8/ops_home_normal` · `safety_states` 행 0 · 안내 요약 = `m8/ops_home_advice_zero` 의 `advice_summary` `copyWith(hasSuppressedNotice: false)`(값으로 와서 3b 부재 — 정상 계열 6이름 공통) · `m6/allocation_in_band` · 진단 = `m8/recon_board_ok`(계약 v1.13 · PR #72 `638fca4` · 칸 5 일치 4 OK · 자가보고 INFO · 🆕 칸 `level` = 블록 6 아이콘·색) · `m7/ledger_trust_self_audit_due` · `Key('h01-more')` < 높이 · `Key('h01-asof')` 0.0 |
| `h01_blocked` | 2 | 〃 | `m8/ops_home_blocked` · `safety_states` 행 3(차단 2) · 진단 `m8/recon_board_diff` · 그 밖 위와 같음 |
| `h01_resume_gap7` | 2 | 〃 | `m8/ops_home_resume_gap7`(`resumeLine` · K44) · 행 0 · 진단 ok |
| `h01_recon_diff` | 2 | 〃 | `m8/ops_home_normal` · 행 0 · 진단 `m8/recon_board_diff`(어긋남 1 · 자가보고 해당 없음 · 🆕 v1.13 칸 `level` BLOCKED·WATCH·OK·OK·INFO) · 🔵 섞인 표본(안전 NORMAL 머리 + 브로커 칸 BLOCKED — 픽스처끼리의 사실 · fixtures README «표본 사실» · 반려 사유 아님 · 01 §23-7) |
| `h01_advice_open` | 2 | 〃 | `m8/ops_home_advice_open` + 형제 키 `advice_summary`(`extraFixture`) · 진단 ok |
| `h01_advice_zero` | 2 | 〃 | `m8/ops_home_advice_zero` + 그 `advice_summary` 의 `copyWith(hasSuppressedNotice: false)`(표본 0 — 카드 규칙 10 예외 · 블록 3b 미렌더) · 진단 ok |
| `h01_advice_suppressed` | 2 | 〃 | `m8/ops_home_advice_zero` + `m6/advice_no_action` 의 `summary`(억제 = `headline` 한 줄 · K45) · 진단 ok |
| `h01_self_audit_due` | 2 | 〃 | `m8/ops_home_normal` · `safety_states` 행 1(`SELF_AUDIT_DUE`) · `m7/ledger_trust_self_audit_due`(블록 9b · 버튼 있음) · 진단 ok · `Key('h01-audit')` < 높이 |

- 공통: 시계 `FixedClock(kGoldenNowUtc)` · 흐름 = (이름, 입력, 흐름) 목록의 **클로저 칸**(흐름 없음 = `(WidgetTester t) async {}` · bool 칸 + if 금지) · 차례 = `pumpForGolden` → `pump()` 한 번 더(값 도착) → 흐름 → `pumpAndSettle()` → 위치 전제 둘 → `expectGolden`.
- 크기 = `s01_*` = `kGoldenPhoneSize`(390 × 844 · 셸은 화면을 꽉 채운다 — 늘리지 않는다) · `h02_*` = `kGoldenPhoneSize`(드라이런 — `_kTallPhone` 없음) · `h01_*` = 테스트 파일 안 `const Size _kTallPhone = Size(390, 1120)`(드라이런 · ✅ 병합본 그대로 — 1회차 `1300` 은 C4h-1 반려 · 재제출이 1120 으로 되돌리고 여백만 줄임) · 🔵 `S-02` 웹 사이드바는 골든 0(위젯 테스트만 · 1280 × 800 · ✅ K46 8장 유지).
- 위치 전제(찍기 전 · 이름마다 둘 · 코드 꼴 = 카드 «골든»): 맨 아래 Key 의 `getBottomLeft(…).dy` · 머리 Key 의 `getTopLeft(…).dy == 0.0`(🔴 실패하면 고치지 말고 실측 dy 를 질문 파일에).
- 보고 «배치·잘림» 칸 — Bob 은 이름마다 **light PNG 한 장만** 연다(R13a 4장 · R13b 8장 — 한 대화 이미지 20장 한도) · dark 행은 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만).
- 🔵 셸 골든은 본문을 찍지 않는다 — 레지스트리가 빈 채(본문 = 글자 0 자리)라 R13b 병합 뒤에도 `s01_*` 재생성 0(홈 탭 연결 = 레지스트리 `home` 칸 · 조립 앱 몫).
- 드라이런 실측 dy(맨 아래 Key · light = dark · 머리 dy 0.0 전부 통과 — 🔵 실제 병합본 위 값은 병합 기록 때 다시 적는다 · `h01_*` 8행 = v1.12 드라이런 값 — 🆕 v1.13 칸 아이콘 뒤 R13b 재드라이런(2026-10-27 · `dry/r13b2`)이 다시 재어 8행 모두 같다(light = dark · 아이콘 20 은 글자 줄 높이 안 · 맨 아래 최대 1108.0 → `_kTallPhone` 1120 그대로)):

| 이름 | 맨 아래 Key | dy | 높이 |
|---|---|---|---|
| `s01_tabs_p0` | `Key('s01-tabs')` | 844.0 | 844 |
| `s01_tabs_clean` | `Key('s01-tabs')` | 844.0 | 844 |
| `h02_rows` | `ValueKey<String>('h02-row-4')` | 292.0 | 844 |
| `h02_not_loaded` | `Key('h02-empty')` | 76.0 | 844 |
| `h01_normal` | `Key('h01-more')` | 936.0 | 1120 |
| `h01_blocked` | `Key('h01-more')` | 1012.0 | 1120 |
| `h01_resume_gap7` | `Key('h01-more')` | 992.0 | 1120 |
| `h01_recon_diff` | `Key('h01-more')` | 956.0 | 1120 |
| `h01_advice_open` | `Key('h01-more')` | 1012.0 | 1120 |
| `h01_advice_zero` | `Key('h01-more')` | 936.0 | 1120 |
| `h01_advice_suppressed` | `Key('h01-more')` | 972.0 | 1120 |
| `h01_self_audit_due` | `Key('h01-audit')` | 1108.0 | 1120 |

- 🆕 **R13a 병합본 실측**(PR #71 `315bbbd` · 2026-10-27 · Bob `1195787`(+ 재제출 `38cafd7` — PNG 0) · C4 재실측 일치 · light=dark · 머리 dy 0.0): `s01_tabs_p0` **844** · `s01_tabs_clean` **844**(= 844) · `h02_rows` **292** · `h02_not_loaded` **76**(< 844) — 드라이런과 같음 · 새 8장 = 드라이런 8장과 바이트 같음 · `git ls-tree` 실측 = `goldens/` **8장**(`s01_*` 4 · `h02_*` 4 · 전부 A · blob 중복 0) · 질문 `S01H02` A1~A4 ✅ · `flutter test` 병합본 **66**(`638fca4` 위 · 1 + 65).
- 🆕 **R13b 병합본 실측**(PR #74 squash `49e4329` · 2026-10-27 · Bob `81d9ace` + 재제출 `deb37d7`(PNG 16 재촬영 · 높이 1120 그대로 · 여백 축소 = 질문 A9) · C4 재실측 일치 · light=dark · 머리 `h01-asof` dy 0.0): `h01_normal` **952** · `h01_blocked` **1020** · `h01_resume_gap7` **1000** · `h01_recon_diff` **972** · `h01_advice_open` **1020** · `h01_advice_zero` **952** · `h01_advice_suppressed` **980**(여기까지 `Key('h01-more')`) · `h01_self_audit_due` **1104**(`Key('h01-audit')`) — 전부 < 1120 · 드라이런(위 표 936 ~ 1108)과 다른 까닭 = Bob 판 배치(예정 행 Column 3줄 · 재량 — 줄이기 전 1096 ~ 1256) + 여백 축소(블록 Padding vertical 12 → 4 아홉 곳 · `_AllocRow`·`_UpcomingRow` 4 → 0) · 새 16장 = C4 수정안(`24d8984`) 16장과 바이트 같음(트리 `2e65131`) · 크기 16/16 = 390×1120(PNG 머리 실측) · `git ls-tree` 실측 = `goldens/` **24장**(`s01_*` 4 · `h02_*` 4 · `h01_*` 16 · 전부 A · blob 중복 0) · 질문 `H01` A1~A9 ✅ · `flutter test` 병합본 **117**(66 + 51 · 파일별 +35 · +16 — 패키지 트리 = `deb37d7` = C4 수정안 · C4·드라이런 실측 · 기록 단계 재실행 0).

### 2. 장수

- R13 시작 **0장**(`ui_shell` 첫 골든) → R13a 병합 뒤 **8장**(+ `s01_*` 4 · `h02_*` 4 · ✅ 2026-10-27 PR #71 `315bbbd` · `git ls-tree` 8) → R13b 병합 뒤 **24장**(+ `h01_*` 16 · ✅ 2026-10-27 PR #74 `49e4329` · `git ls-tree` 24). 질문 파일 = `docs/ai-context/inbox/S01H02_questions.md`(R13a) · `H01_questions.md`(R13b).

## 🆕 R14(계약 v1.15 전제 · ✅ 2분할 확정) — `N-01`·`N-02`(R14a) · `W-01`(R14b) (2026-10-30 조립 · 🆕 v1.15 실물 반영 재조립 · ✅ 선행 = 계약 v1.15 보강 병합(PR #86 squash `e9e71c8` · 2026-10-30 · ui PNG 0) · ✅ 발주자 확인(2026-10-30) · ✅ 재드라이런(2026-10-30 · v1.15 실물 위) · ✅ R14a 병합 PR #87 `185e9c7` 2026-10-31(10장 · dy 병합본 실측 = 드라이런 · PNG 바이트 같음) · ▶ R14b `send/`(「푸시해」 뒤) — 이 절의 dy 는 드라이런 실측(`n01_*` = 첫 판 · 재드라이런 같음 · `n02_*`·`w01_*` = 재드라이런) · 장수는 계획이다)

- 카드 = ~~`docs/ai-context/send/R14a-Bob-N01N02.md`~~ `docs/ai-context/send/_완료/R14a-Bob-N01N02.md`(R14a · ✅ 병합 PR #87 `185e9c7` 2026-10-31) · ~~`docs/ai-context/send/_대기/R14b-Bob-W01.md`~~ `docs/ai-context/send/R14b-Bob-W01.md`(R14b · ✅ 선행 R14a 병합 · 2026-10-31 R14a 병합 기록이 `send/` 로 · ▶ 「푸시해」 뒤) · `F-01` FGS = 화면 카드 밖(골든 0 · ✅ 엔진 레인 06 `M1-15` · 2026-10-30 발주자).
- 이 절은 통합 담당이 쓴다(화면 담당 무수정 — 카드 규칙 1 «golden README 고치면 반려»).

### 1. 골든 이름 — R14a 5이름 × light/dark = 10장 · R14b 3이름 × 2 = 6장 · 재생성 0

| 이름 | 장수 | 테스트 파일 | 입력 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `n01_p0_ack` | 2 | `test/golden/n01_golden_test.dart` | `m8/alert_center_p0_ack`(v1.15 · 고정 P0 3 — 미확인 사다리·확인됨·EXIT_URGENT ack 없음 · «오늘» 묶음 P1 2) · 주입 operator(확인 버튼 1) · `ValueKey('n01-row-0-1')` < 844 · `Key('n01-asof')` dy 0.0 |
| `n01_digest` | 2 | 〃 | `m8/alert_center_digest`(v1.15 · «오늘» P1 1 · «2026-08-30» 접힌 묶음 «P2 3건» — 접힌 채) · `ValueKey('n01-digest-1')` < 844 · 머리 0.0 |
| `n01_empty` | 2 | 〃 | `m8/alert_center_empty`(v1.15 · 고정·묶음 0 · 엔진 빈 문장) · `Key('n01-empty')` < 844 · 머리 0.0 |
| `n02_detail` | 2 | `test/golden/n02_golden_test.dart` | 🆕 `m8/alert_detail_full`(v1.15 `AlertDetailVm` · item = 센터 고정 행 0 과 같은 값 — 시각·근거·사다리 있음) · 주입 operator · `ValueKey('n02-ack')` < 844 · 🆕 `Key('n02-asof')` dy 0.0(머리) |
| `n02_no_link` | 2 | 〃 | 🆕 `m8/alert_detail_no_link`(v1.15 · item = 센터 접힌 행 2 와 같은 값 — 시각·근거·ack 없음) · `Key('n02-action')` < 844 · 머리 0.0 |
| `w01_delayed` | 2 | `test/golden/w01_golden_test.dart` | `m8/watchdog_delayed`(v1.15 `WatchdogBoardVm` · 6행 — 성공 3 · 지연 2 · 실패 1 · `level` · 머리 «마지막 수신» · 하단 한계 고지) · 🆕 `Key('w01-limit')` < 844 · `Key('w01-asof')` dy 0.0 |
| `w01_holiday` | 2 | 〃 | `m8/watchdog_holiday`(v1.15 정리 · 휴장 성공 핑 3(`state_code` OK · level ok) · 성공 2 · 🆕 휴장 고지 `holidayNotice` = 하단에 그린다) · 🆕 `Key('w01-limit')` < 844 · 머리 0.0 |
| `w01_paused` | 2 | 〃 | 🆕 `m8/watchdog_paused`(v1.15 신설 · 일시정지 3 · 성공 2) · 🆕 `Key('w01-limit')` < 844 · 머리 0.0(✅ 발주자 확인 R14b ③ 권고대로 = 이 이름 그대로) |

- 공통: 시계 `FixedClock(kGoldenNowUtc)` · 흐름 = 클로저 칸(전부 `(WidgetTester t) async {}`) · 가짜·저장소·명령 = testWidgets 안에서 새로(공장 꼴 · C4r5d-5) · 크기 = `kGoldenPhoneSize`(390 × 844 · 카드 확정값 — 늘리지 않는다 · 드라이런 dy 로 확인).
- 드라이런 실측 dy(맨 아래 Key · light = dark · 2026-10-30 · 첫 판 `dry/r14-1`·`dry/r14-1b`(n01·n02) · `dry/r14-2`·`dry/r14-2b`(w01) · 🆕 재드라이런 `dry/r14v-1`(n01·n02 — v1.15 실물 `d9916ca` 위) · `dry/r14v-2`(w01)): `n01_p0_ack` 416.0 · `n01_digest` 244.0 · `n01_empty` 152.0(첫 판 = 재드라이런) · 🆕 `n02_detail` 316.0 · `n02_no_link` 156.0(첫 판 276.0 · 116.0 → +40 = v1.15 머리 `n02-asof` 한 줄) · `w01_delayed` 696.0 · `w01_holiday` 580.0 · `w01_paused` 592.0(맨 아래 = `w01-limit` · 첫 판 행 끝 584.0 · 440.0 · 480.0 → 머리 `w01-received`·하단 `w01-holiday`·`w01-limit` 만큼) — 전부 844 미만 · 머리 dy 0.0 · 높이 늘림 0.
- 🔵 W-01 상태 아이콘 = H-01 `_cellLook` 글리프 그대로(R14b ⑪ · 드라이런 반영판 = PNG 불변 — 테스트 글꼴에서 아이콘은 작은 네모 · 색만 PNG 에 남는다).
- 보고 «배치·잘림» 칸 — Bob 은 이름마다 light PNG 한 장만 연다(R14a 5장 · R14b 3장).
- 🆕 **v1.15 병합본 실측**(PR #86 squash `e9e71c8` · 2026-10-30 · 측정 worktree `C:/Work/AAQ-claude-r14chk` · 끝에 삭제): `ui_shell` `flutter test` 시작 **+117**(드라이런 기대와 같음) · `domain_contracts` **+408 ~30** · `git ls-tree` PNG **24** · 가벼운 확인 = `dry/r14v-1` 의 R14a 구현 3커밋(`571b01b`·`7ec70b0`·`801eb58`) cherry-pick 충돌 0 → **+164**(파일별 `alert_center_test` +24 · `alert_detail_test` +13 · `n01_golden` +6 · `n02_golden` +4) · `n01_*`·`n02_*` **10장 = `dry/r14v-1` 과 바이트 같음(10/10 · `--update-goldens` 0)** → 위 dy 표·장수 고칠 곳 0(dy 는 다시 재지 않음 — PNG 같음으로 갈음) · PNG 34(24 + 10).
- 🆕 **R14a 병합본 실측**(PR #87 squash `185e9c7` · 2026-10-31 · Bob `a9a0cae` · C4 재실측 일치(`lessThan(0)` · 갈래 G·H · 10/10) · light = dark · 머리 dy 0.0 · 390×844 · 높이 무수정): `n01_p0_ack` **416** · `n01_digest` **244** · `n01_empty` **152** · `n02_detail` **316** · `n02_no_link` **156**(< 844) — 드라이런과 같음 · PNG 10장 = 드라이런 `dry/r14v-1` 과 바이트 같음 · 여유 428px(`n01_p0_ack` — 최소) · 측정 worktree `C:/Work/AAQ-claude-r14bchk`(끝에 삭제) 병합본 `flutter test` **00:09 +164** · `domain_contracts` **00:10 +408 ~30** · `git ls-tree` 실측 = `goldens/` **34장**(`n01_*` 6 · `n02_*` 4 포함) · 질문 `N01N02_questions.md` A1~A5 ✅ · 🔵 R14b 가벼운 확인(2026-10-31 · 병합본 `185e9c7` 위 `dry/r14v-2c` R14b 커밋 4(`e802f70`·`74d2b64`·`e106486`·`bbd8264`) cherry-pick · 충돌 0 · `--update-goldens` 0) = `w01_*` 6장 = `dry/r14v-2c` blob 그대로(6/6) · `w01_golden` «00:00 +6» · `watchdog_board_test` «00:01 +19» · 기존 34장 전부 통과(R14b 가 기존 픽셀 0) · 끝 **40장** · `flutter test` **00:10 +189** · dy 는 다시 재지 않음(PNG 같음으로 갈음 — 위 표 696.0 · 580.0 · 592.0 그대로).

### 2. 장수(계획)

- R14 시작 **24장**(R13 병합본 · ✅ v1.15 병합본 `e9e71c8` `git ls-tree` 24) → R14a 병합 뒤 **34장**(+ `n01_*` 6 · `n02_*` 4 · ✅ 2026-10-31 PR #87 `185e9c7` · `git ls-tree` 34) → R14b 병합 뒤 **40장**(+ `w01_*` 6 · ⬜ · 🔴 «정확히» = R14b 정적 W32 · 병합본 위 가벼운 확인 40). 질문 파일 = `docs/ai-context/inbox/N01N02_questions.md`(R14a) · `W01_questions.md`(R14b).
