# `test/golden/` — 위젯 골든 스냅샷 (~~**아직 비어 있다**~~ → ~~**6장** · R6a 병합 PR #146 `9840603` · 2026-11-14~~ → ~~**14장** · R6b 병합 PR #155 `f58e2f9` · 2026-11-14~~ → ~~**26장** · R6c1 병합 PR #168 `b3b759c` · 2026-11-14~~ → ~~**28장** · R6c2 병합 PR #176 `02099df` · 2026-11-15 · 🏁 R6 · ✅ R6 test-only 병합 뒤 **28장 그대로**(PR #184 `e36a310` · 테스트 파일만 · PNG 0 변경)~~ → ~~**36장** · R7a 병합 PR #197 `18d241b` · 2026-11-15(🔁 통합 대행)~~ → **44장** · R7b 병합 PR #210 `6195b88` · 2026-11-17)

정본: 01_M2_도메인계약 **§7** · 07_AI어시스턴트_배포프롬프트 **§9** 기계 검사 4

## 🔴 «최초 생성»과 «재생성»은 다르다

| 구분 | 누가 | 규칙 |
|---|---|---|
| **뷰모델 골든** `*.golden.json`(C-1) | 🔴 M2(Claude) 소유 | 화면 담당은 **읽기만**. 깨지면 표시 계약이 바뀐 것이므로 **고치지 말고 질문 목록에 올린다** |
| **위젯 골든 PNG**(C-2) | 화면 담당 | **신규 화면의 최초 베이스라인은 그 화면을 만드는 PR에서 함께 커밋**한다. 이후 **픽스처가 그대로인데 다시 찍는 것은 위조**이며 반려 |

병합 검사는 `git diff --name-status`로 **A(추가)**와 **M(수정)**을 구별한다.

## 하네스

- 🆕 계약 v1.18(01 §27 · K-y) — `golden_support.dart` = M2 가 `ui_shell` 판을 복사해 두었다(픽스처 → DTO · 고정 크기 폰 · light/dark) ·
  비교기(`flutter_test_config.dart`·`shift_tolerant_compare.dart`) = R6a 첫 카드가 첫 골든과 함께 `ui_shell` 판을 옮긴다(✅ 옮김 · R6a 병합 PR #146 `9840603` · 2026-11-14).

## 규칙

- 렌더 입력은 `packages/domain_contracts/fixtures/`다. **화면 담당은 픽스처를 수정하지 않는다.**
- light / dark 두 벌.
- 임계 조정은 M2가 한다.
- 🔴 골든에 **실키·실계좌번호가 절대 들어가지 않게** 한다. 렌더 입력은 합성 픽스처뿐이고, 계좌는 별칭만 보인다. 뷰어 빌드 프레임에서는 시크릿 컨트롤이 **아예 없는 것**이 정답이다.

## 🆕 R6(계약 v1.18 전제 · 🔀 3분할 ✅ 확정) — `S01`(R6a) · `S07`(R6b) · `S05`(R6c) (2026-11-13 조립 · ✅ 선행 = 계약 v1.18 병합 PR #142 squash `b582c49` · ✅ R6a 병합 PR #146 `9840603` 2026-11-14(1회차 반려 → 재제출 → 2회차 merge) · ✅ R6b 병합 PR #155 `f58e2f9` 2026-11-14(1회차 반려 → 재제출 → 2회차 merge) · ~~R6c 조립 전(선행 = 계약 v1.19)~~ ✅ 계약 v1.19 병합 PR #163 `6b8ed02` · R6c 🔀 2분할 · ✅ R6c1 병합 PR #168 `b3b759c` 2026-11-14(1회차 merge-with-fixes) · ~~R6c2 ▶ 「푸시해」 뒤~~ ✅ R6c2 병합 PR #176 `02099df` 2026-11-15(1회차 반려 → 재제출 → 2회차 merge) · 🏁 R6 · ✅ R6 test-only PR #184 `e36a310` 2026-11-15(테스트 3파일만 · 골든 0 변경 · 28장 그대로))

- 카드 = `docs/ai-context/send/_완료/R6a-Bob-M9S01.md`(R6a · ✅ 병합 PR #146 `9840603` 2026-11-14 · 1회차 반려 → 재제출 `_완료/R6a-Bob-M9S01-재제출.md` → 2회차 merge) · R6b = `docs/ai-context/send/_완료/R6b-Bob-M9S07.md`(✅ 병합 PR #155 `f58e2f9` 2026-11-14 · 1회차 반려 → 재제출 `_완료/R6b-Bob-M9S07-재제출.md` → 2회차 merge) · R6c `R6c-Bob-M9S05` = ~~조립 전(선행 = 계약 v1.19)~~ 🔀 2분할 — R6c1 = `docs/ai-context/send/_완료/R6c1-Bob-M9S05a.md`(✅ 병합 PR #168 `b3b759c` 2026-11-14 · 1회차 merge-with-fixes) · R6c2 = `docs/ai-context/send/_완료/R6c2-Bob-M9S05b.md`(✅ 병합 PR #176 `02099df` 2026-11-15 · 1회차 반려 → 재제출 `_완료/R6c2-Bob-M9S05b-재제출.md` → 2회차 merge · `m9s05_hold_keys` + R6c1 PNG 12 다시 찍기 · `golden:approved`).
- 이 절은 통합 담당이 쓴다(화면 담당 무수정 — 카드 «고치면 반려» 목록에 `test/golden/README.md`). 다음 카드는 이 절 끝에 줄을 더한다(새 절 0).

### 1. 골든 이름 — R6a 3이름 × 2 = 6장

| 이름 | 장수 | 테스트 파일 | 입력 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s01_home` | 2 | `test/golden/m9s01_golden_test.dart` | `m9/settings_home`(묶음 3 · 카드 11 · 칩 = 관찰 중 + 승격 줄 · 연간 리뷰 링크) · 390×1120(`_kM9s01Tall` · 키 큰 판 · 발주자 확인 ①) · 맨 아래 `Key('m9s01-asof')` dy **1048** < 1120 · 머리 `Key('m9s01-chip')` dy 0.0 |
| `m9s01_no_review` | 2 | 〃 | `m9/settings_home_no_review`(리뷰 링크 0 · 승격 줄 0) · 390×1120 · `m9s01-asof` dy **964** < 1120 · 머리 0.0 |
| `m9s01_viewer` | 2 | 〃 | `m9/settings_home_viewer`(뷰어 판 · 폰 전용 행 0 · 카드 3) · 390×844(`kGoldenPhoneSize` 무수정) · `m9s01-asof` dy **516** < 844 · 머리 0.0 |

- 공통: 흐름 = 클로저 칸 non-null(`(WidgetTester t) async {}`) · 가짜 = testWidgets 안에서 새로 · 시계 `FixedClock(kGoldenNowUtc)` · 탭을 찍는 골든 0 · 골든 높이 = 재량 + 기록 확장 ⓐ~ⓔ(12 §3).
- 🆕 **R6a 병합본 실측**(PR #146 squash `9840603` · 2026-11-14 · Bob `7c5ac34`(커밋 7) + 재제출 `60803aa`(테스트 파일 +11 · lib·PNG 0) · C4 재실측 일치(`lessThan(0.0)` 임시 · 이름마다 `--plain-name` · 1회차 · 2회차) · light = dark · 머리 dy 0.0): `m9s01_home` **1048** · `m9s01_no_review` **964**(390×1120) · `m9s01_viewer` **516**(390×844) — 드라이런 dy 와 같음 · PNG = 드라이런과 바이트 다름(리뷰 행 · 묶음 머리 Row 정렬 기본값 · 재량 · dy 영향 0 · 12 §3 ⓐ · ⓒ · ⓔ · C4Q-10 기록만 · 🔵 드라이런 가지 `dry/r6a` 골든 높이는 1080 = 카드 확정 1120 이전 판 · C4Q-12 · R6b 드라이런 밑동 = 이 병합본(C4r6a-9)) · 비교기 = `test/flutter_test_config.dart` · `test/golden/shift_tolerant_compare.dart`(`ui_shell` 판 복사) · `ui_settings` 테스트 **23**(뷰 16 · 골든 6 · 자리표시 1) · `git ls-tree` PNG **6** · 질문 파일 `docs/ai-context/inbox/M9S01_questions.md` A1~A3 ✅.

### 2. 장수(계획)

- R6 시작 **0장** → R6a 병합 뒤 **6장**(+ `m9s01_*` 6 · ✅ 2026-11-14 PR #146 `9840603` · `git ls-tree` 6) → R6b 병합 뒤 **14장**(+ `m9s07_connections` · `m9s07_telegram` · `m9s07_locked` · `m9s07_viewer` × 2 · ✅ 2026-11-14 PR #155 `f58e2f9` · `git ls-tree` 14) → R6c(`m9s05_*` · v1.19 표본 · 계획) → R6c1 병합 뒤 **26장**(+ `m9s05_*` 12 · ✅ 2026-11-14 PR #168 `b3b759c`) → R6c2 병합 뒤 **28장**(+ `m9s05_hold_keys` 2 · R6c1 12장 다시 찍기 · ✅ 2026-11-15 PR #176 `02099df` · `git ls-tree` 28) → R6 test-only PR 병합 뒤 **28장 그대로**(✅ 2026-11-15 PR #184 `e36a310` · 테스트 파일만 · 장수 변화 0 · `git ls-tree` `fef59a3` 28) → R7a 병합 뒤 **36장**(+ `m9s02_*` 8 · ✅ 2026-11-15 PR #197 `18d241b` · `git ls-tree` 36) → R7b 병합 뒤 **44장**(+ `m9s06_*` 8 · ✅ 2026-11-17 PR #210 `6195b88` · `git ls-tree` 44).

### 3. 골든 이름 — R6b 4이름 × 2 = 8장(✅ 병합 PR #155 `f58e2f9` · 2026-11-14)

| 이름 | 장수 | 테스트 파일 | 입력 · 동작 주입 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s07_connections` | 2 | `test/golden/m9s07_golden_test.dart` | `m9/connections` · operator(`UnimplementedSettingsActions` · 버튼 있음) · 390×1040(`_kM9s07Tall` · 키 큰 판 · 발주자 확인 ①) · 맨 아래 `Key('m9s07-asof')` dy **956** < 1040 · 머리 `ValueKey('m9s07-row-0')` dy 0.0 |
| `m9s07_telegram` | 2 | 〃 | `m9/connections_telegram` · operator · 390×844(`kGoldenPhoneSize` 무수정) · `m9s07-asof` dy **788** < 844 · 머리 `m9s07-row-0` 0.0 |
| `m9s07_locked` | 2 | 〃 | `m9/connections_locked` · operator · 390×844 · `m9s07-asof` dy **796** < 844 · 머리 `Key('m9s07-locked')` 0.0 |
| `m9s07_viewer` | 2 | 〃 | `m9/connections`(`m9s07_connections` 와 같은 표본) · null(뷰어 = 버튼 부재) · 390×844 · `m9s07-asof` dy **740** < 844 · 머리 `m9s07-row-0` 0.0 |

- 공통: 흐름 = 클로저 칸 non-null(`(WidgetTester t) async {}`) · 가짜 = testWidgets 안에서 새로(`FakeSettingsOpsStatusRepository` · `RecordingLinkOpener`) · 시계 `FixedClock(kGoldenNowUtc)` · 탭을 찍는 골든 0.
- 🆕 **R6b 병합본 실측**(PR #155 squash `f58e2f9` · 2026-11-14 · Bob `be89e09`(커밋 6) + 재제출 `30704c9`(테스트 파일 +11/−5 · lib·PNG 0) · C4 재실측 일치(이름마다 `--plain-name` · 1회차 · 2회차) · light = dark · 머리 dy 0.0): `m9s07_connections` **956**(390×1040 · `_kM9s07Tall`) · `m9s07_telegram` **788** · `m9s07_locked` **796** · `m9s07_viewer` **740**(390×844) — 드라이런 dy 와 같음 · PNG 8 = 드라이런과 바이트 같음 · 동작 주입 = operator 3이름(`UnimplementedSettingsActions`) · viewer = null · `ui_settings` 테스트 **60**(R6a 23 + `connections_test` 29 + 골든 8) · `git ls-tree` PNG **14**(`m9s01` 6 + `m9s07` 8) · 질문 파일 `docs/ai-context/inbox/M9S07_questions.md` A1~A4 ✅.

### 4. 골든 이름 — R6c1 6이름 × 2 = 12장(✅ 병합 PR #168 `b3b759c` · 2026-11-14 · 🔵 R6c2 가 12장 다시 찍음 — 새 dy = §5)

| 이름 | 장수 | 테스트 파일 | 입력 · 동작 주입 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s05_sim_auto` | 2 | `test/golden/m9s05_golden_test.dart` | `m9/operations_sim_auto` · operator(`UnimplementedSettingsActions`) · 390×2160(`_kM9s05Tall` · 카드 확정값) · 맨 아래 `Key('m9s05-asof')` dy **1072** < 2160 · 머리 `Key('m9s05-chip')` dy 0.0 |
| `m9s05_sim_complete` | 2 | 〃 | `m9/operations_sim_complete` · operator · 390×2160 · `m9s05-asof` dy **1104** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_live_observe` | 2 | 〃 | `m9/operations_live_observe` · operator · 390×2160 · `m9s05-asof` dy **636** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_live_promotable` | 2 | 〃 | `m9/operations_live_promotable` · operator · 390×2160 · `m9s05-asof` dy **692** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_advisory` | 2 | 〃 | `m9/operations_advisory` · operator · 390×2160 · `m9s05-asof` dy **624** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_locked` | 2 | 〃 | `m9/operations_locked` · operator · 390×2160 · `m9s05-asof` dy **692** < 2160 · 머리 `Key('m9s05-locked')` 0.0 |

- 공통: 흐름 = 클로저 칸 non-null(`(WidgetTester t) async {}`) · 가짜 = testWidgets 안에서 새로(`FakeSettingsOperationsRepository` · `RecordingLinkOpener`) · 시계 `FixedClock(kGoldenNowUtc)` · 탭을 찍는 골든 0 · 높이 한 값 `_kM9s05Tall`(R6c2 와 같은 값).
- 🆕 **R6c1 병합본 실측**(PR #168 squash `b3b759c` · Bob `00668d3`(커밋 4) · C4 재실측 일치(이름마다 `--plain-name`) · 병합 기록 재실측 일치(`lessThan(0.0)` 임시 · 되돌림) · light = dark): `m9s05_sim_auto` **1072** · `m9s05_sim_complete` **1104** · `m9s05_live_observe` **636** · `m9s05_live_promotable` **692** · `m9s05_advisory` **624** · `m9s05_locked` **692** — 드라이런 dy 와 같음 · PNG 12 = 드라이런과 바이트 같음 · R6c2 가 12장을 다시 찍는다(`golden:approved`) · `ui_settings` 테스트 **110**(R6b 60 + `operations_test` 38 + 골든 12) · `git ls-tree` PNG **26**(`m9s01` 6 + `m9s07` 8 + `m9s05` 12) · 질문 파일 `docs/ai-context/inbox/M9S05_questions.md` A1~A6 ✅.

### 5. 골든 이름 — R6c2 1이름 × 2 = 2장 + R6c1 12장 다시 찍기(✅ 병합 PR #176 `02099df` · 2026-11-15)

| 이름 | 장수 | 테스트 파일 | 입력 · 동작 주입 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s05_sim_auto` | 2(다시 찍기) | `test/golden/m9s05_golden_test.dart` | `m9/operations_sim_auto` · operator · 390×2160(`_kM9s05Tall`) · `m9s05-asof` dy **2064** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_sim_complete` | 2(다시 찍기) | 〃 | `m9/operations_sim_complete` · operator · 390×2160 · `m9s05-asof` dy **1828** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_live_observe` | 2(다시 찍기) | 〃 | `m9/operations_live_observe` · operator · 390×2160 · `m9s05-asof` dy **1540** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_live_promotable` | 2(다시 찍기) | 〃 | `m9/operations_live_promotable` · operator · 390×2160 · `m9s05-asof` dy **1596** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_advisory` | 2(다시 찍기) | 〃 | `m9/operations_advisory` · operator · 390×2160 · `m9s05-asof` dy **1508** < 2160 · 머리 `m9s05-chip` 0.0 |
| `m9s05_locked` | 2(다시 찍기) | 〃 | `m9/operations_locked` · operator · 390×2160 · `m9s05-asof` dy **1476** < 2160 · 머리 `Key('m9s05-locked')` 0.0 |
| `m9s05_hold_keys` | 2(새) | `test/golden/m9s05_board_golden_test.dart` | `m9/operations_live_hold_keys` · operator(`UnimplementedSettingsActions`) · 390×2160 · `m9s05-asof` dy **1424** < 2160 · 머리 `m9s05-chip` 0.0 |

- 🆕 **R6c2 병합본 실측**(PR #176 squash `02099df` · 2026-11-15 · Bob `d500433`(커밋 5) + 재제출 `7cc7ea8`(테스트 파일 +7/−9 · lib·PNG 0) · C4 재실측 일치(이름마다 `--plain-name` · 1회차 · 2회차) · 병합 기록 재실측 일치(`lessThan(0.0)` 임시 · 되돌림) · light = dark · 머리 dy 0.0): PNG **28**(`m9s01` 6 + `m9s07` 8 + `m9s05` 14) · 다시 찍은 R6c1 12장(`m9s05_sim_auto` **2064** · `m9s05_sim_complete` **1828** · `m9s05_live_observe` **1540** · `m9s05_live_promotable` **1596** · `m9s05_advisory` **1508** · `m9s05_locked` **1476**) · 새 2장 `m9s05_hold_keys` **1424**(`test/golden/m9s05_board_golden_test.dart`) · 390×2160(`_kM9s05Tall`) — 드라이런 dy 와 같음 · PNG 14 = 드라이런 `0465cbda` 와 바이트 같음 · `golden:approved`(통합 담당) · `ui_settings` 테스트 **140**(R6c1 110 + `operations_board_test` 28 + 골든 2) · 질문 파일 `docs/ai-context/inbox/M9S05_questions.md` A7~A13 ✅ · 🏁 R6.
- 🆕 **R6 test-only PR 실측**(PR #184 squash `e36a310` · 2026-11-15 · 통합 담당 · 밑동 `b46aff7` · head `04ffef0` · 테스트 파일 3개만 +119/−67 — `settings_home_test` · `connections_test` · `operations_board_test` · 골든 테스트·PNG·lib·픽스처·fakes 0 변경 · 같은 날 lib 주석 PR #185 `fef59a3` = `operations.dart` 주석 2줄 · 골든 영향 0): `*.png` diff 0 · `git ls-tree` `fef59a3` = `goldens/` **28장 그대로**(장수 변화 0) · 골든 포함 `flutter test` **+141** 통과(140 + 1 · 골든 재생성 0 · `--update-goldens` 0 · PR 실측 · 병합본 재실행 0 · CI 3/3) · `domain_contracts` **+466 ~30** · 근거 변이 H1(S01 리뷰 줄 겹침) = 밑동 `b46aff7` 판에선 골든 `m9s01_home` · `m9s01_viewer` 만 잡던 것 → 뷰 KILLED · H2(S01 오래됨 배너 겹침) · C1(S07 loading 뼈대 주입 null 일 때만) = 전체 SURVIVED(오래됨 · loading 골든 없음) → 뷰 KILLED.

## 🆕 R7(계약 v1.20 전제 · 🔀 3분할) — `S02`(R7a) · `S06`(R7b) · `S03`(R7c)

카드 = `docs/ai-context/send/_완료/R7a-Bob-M9S02.md`(✅ 병합 PR #197 squash `18d241b` · 2026-11-15 · 1회차 merge · 🔁 통합 대행 — lib = Bob `f2fa385c` · 테스트·골든 = 통합 담당 · 발주자 예외 1회) · R7b(`S06`) = `docs/ai-context/send/_완료/R7b-Bob-M9S06.md`(✅ 병합 PR #210 squash `6195b88` · 2026-11-17 · 1회차 merge · Bob 구현 · PR 대행 게시) · ~~R7b(`S06`) · R7c(`S03`) = 조립 전(R7b 선행 ✅ 계약 v1.21 PR #189 `81bf79c`)~~ · R7c(`S03`) = 조립 전(선행 ✅ R7b 병합 · ⬜ 계약 1.22.0 창).

### 6. 골든 이름 — R7a 4이름 × 2 = 8장(✅ 병합 PR #197 `18d241b` · 2026-11-15)

| 이름 | 장수 | 테스트 파일 | 입력 · 동작 주입 · 슬롯 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s02_live` | 2 | `test/golden/m9s02_golden_test.dart` | `credentials.json` · operator(`UnimplementedSettingsActions`) · 슬롯 = `FakeSettingsSlotRecorder().build`(테두리 상자) · 390×960(`_kM9s02Tall` · 카드 확정값) · 맨 아래 `Key('m9s02-asof')` dy **824** < 960 · 머리 `ValueKey('m9s02-card-0')` dy 0.0 |
| `m9s02_sim_sealed` | 2 | 〃 | `credentials_sim_sealed.json` · operator · 슬롯 같음 · 390×960 · `m9s02-asof` dy **824** < 960 · 머리 `Key('m9s02-notice')` 0.0 |
| `m9s02_advisory` | 2 | 〃 | `credentials_advisory.json` · operator · 슬롯 같음 · 390×960 · `m9s02-asof` dy **848** < 960 · 머리 `m9s02-card-0` 0.0 |
| `m9s02_locked` | 2 | 〃 | `credentials_locked.json` · operator · 슬롯 같음 · 390×960 · `m9s02-asof` dy **616** < 960 · 머리 `Key('m9s02-locked')` 0.0 |

- 공통: 뷰어 골든 0(K24 — 뷰어 = 동작 주입 null · 버튼 부재) · 탭을 찍는 골든 0 · 높이 한 값 `_kM9s02Tall`(최댓값 848 → 40 배수 880 + 80).
- 🆕 **R7a 병합본 실측**(PR #197 squash `18d241b` · 2026-11-15 · Bob lib `f2fa385c` + 통합 대행 (2)~(5) · head `4caef654` · C4 재실측 일치(이름마다 `--plain-name` · 합친 트리) · 병합 기록 재실측 일치(`lessThan(0.0)` 임시 · 되돌림) · light = dark · 머리 dy 0.0): `m9s02_live` **824** · `m9s02_sim_sealed` **824** · `m9s02_advisory` **848** · `m9s02_locked` **616**(390×960) — 드라이런 dy 와 같음 · PNG 8 = 드라이런 `2cc47e92` 와 바이트 같음 · 기존 28장 무변경(`golden:approved` 없음) · `ui_settings` 테스트 **188**(141 + `credentials_test` 39 + 골든 8) · `git ls-tree` PNG **36**(`m9s01` 6 + `m9s07` 8 + `m9s05` 14 + `m9s02` 8) · 질문 파일 `docs/ai-context/inbox/M9S02_questions.md` A1~A4 ✅.

### 7. 골든 이름 — R7b 4이름 × 2 = 8장(✅ 병합 PR #210 `6195b88` · 2026-11-17)

| 이름 | 장수 | 테스트 파일 | 입력 · 동작 주입 · 슬롯 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s06_devices` | 2 | `test/golden/m9s06_golden_test.dart` | `device_access.json` · operator(`UnimplementedSettingsActions`) · 슬롯 = `FakeSettingsSlotRecorder().build`(테두리 상자) · 390×960(`_kM9s06Tall` · 카드 확정값) · 맨 아래 `Key('m9s06-asof')` dy **796** < 960 · 머리 `Key('m9s06-pairing')` dy 0.0 |
| `m9s06_ticket` | 2 | 〃 | `device_access_ticket.json` · operator · 슬롯 같음(QR 자리 = 테두리 상자) · 390×960 · `m9s06-asof` dy **844** < 960 · 머리 `m9s06-pairing` 0.0 |
| `m9s06_no_viewers` | 2 | 〃 | `device_access_no_viewers.json` · operator · 슬롯 같음 · 390×960 · `m9s06-asof` dy **412** < 960 · 머리 `m9s06-pairing` 0.0 |
| `m9s06_locked` | 2 | 〃 | `device_access_locked.json` · operator · 슬롯 같음 · 390×960 · `m9s06-asof` dy **636** < 960 · 머리 `Key('m9s06-locked')` 0.0 |

- 공통: 뷰어 골든 0(K24 — 뷰어 = 동작 주입 null · 버튼·펼침 부재) · 탭 · 펼침을 찍는 골든 0(펼침 확인 = 위젯 테스트 `devices_test`) · 높이 한 값 `_kM9s06Tall`(최댓값 844 → 40 배수 880 + 80).
- 🆕 **R7b 병합본 실측**(PR #210 squash `6195b88` · 2026-11-17 · Bob 구현(쓰기 단계 19 답 · 커밋 4) · head `45fb4471` · C4 재실측 일치(이름마다 `--plain-name` · 합친 트리 `fb2b1b21`) · 병합 기록 재실측 일치(`lessThan(0.0)` 임시 · 되돌림) · light = dark · 머리 dy 0.0): `m9s06_devices` **796** · `m9s06_ticket` **844** · `m9s06_no_viewers` **412** · `m9s06_locked` **636**(390×960) — 드라이런 dy 와 같음 · PNG 8 = 드라이런 `788ae501` 과 바이트 같음 · 기존 36장 무변경(`golden:approved` 없음) · `ui_settings` 테스트 **238**(188 + `devices_test` 42 + 골든 8) · `git ls-tree` PNG **44**(`m9s01` 6 + `m9s07` 8 + `m9s05` 14 + `m9s02` 8 + `m9s06` 8) · 질문 파일 `docs/ai-context/inbox/M9S06_questions.md` A1~A4 ✅.
