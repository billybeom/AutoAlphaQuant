# `test/golden/` — 위젯 골든 스냅샷 (~~**아직 비어 있다**~~ → ~~**6장** · R6a 병합 PR #146 `9840603` · 2026-11-14~~ → **14장** · R6b 병합 PR #155 `f58e2f9` · 2026-11-14)

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

## 🆕 R6(계약 v1.18 전제 · 🔀 3분할 ✅ 확정) — `S01`(R6a) · `S07`(R6b) · `S05`(R6c) (2026-11-13 조립 · ✅ 선행 = 계약 v1.18 병합 PR #142 squash `b582c49` · ✅ R6a 병합 PR #146 `9840603` 2026-11-14(1회차 반려 → 재제출 → 2회차 merge) · ✅ R6b 병합 PR #155 `f58e2f9` 2026-11-14(1회차 반려 → 재제출 → 2회차 merge) · R6c 조립 전(선행 = 계약 v1.19))

- 카드 = `docs/ai-context/send/_완료/R6a-Bob-M9S01.md`(R6a · ✅ 병합 PR #146 `9840603` 2026-11-14 · 1회차 반려 → 재제출 `_완료/R6a-Bob-M9S01-재제출.md` → 2회차 merge) · R6b = `docs/ai-context/send/_완료/R6b-Bob-M9S07.md`(✅ 병합 PR #155 `f58e2f9` 2026-11-14 · 1회차 반려 → 재제출 `_완료/R6b-Bob-M9S07-재제출.md` → 2회차 merge) · R6c `R6c-Bob-M9S05` = 조립 전(선행 = 계약 v1.19).
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

- R6 시작 **0장** → R6a 병합 뒤 **6장**(+ `m9s01_*` 6 · ✅ 2026-11-14 PR #146 `9840603` · `git ls-tree` 6) → R6b 병합 뒤 **14장**(+ `m9s07_connections` · `m9s07_telegram` · `m9s07_locked` · `m9s07_viewer` × 2 · ✅ 2026-11-14 PR #155 `f58e2f9` · `git ls-tree` 14) → R6c(`m9s05_*` · v1.19 표본 · 계획).

### 3. 골든 이름 — R6b 4이름 × 2 = 8장(✅ 병합 PR #155 `f58e2f9` · 2026-11-14)

| 이름 | 장수 | 테스트 파일 | 입력 · 동작 주입 · 크기 · 위치 전제(맨 아래 · 머리) |
|---|---|---|---|
| `m9s07_connections` | 2 | `test/golden/m9s07_golden_test.dart` | `m9/connections` · operator(`UnimplementedSettingsActions` · 버튼 있음) · 390×1040(`_kM9s07Tall` · 키 큰 판 · 발주자 확인 ①) · 맨 아래 `Key('m9s07-asof')` dy **956** < 1040 · 머리 `ValueKey('m9s07-row-0')` dy 0.0 |
| `m9s07_telegram` | 2 | 〃 | `m9/connections_telegram` · operator · 390×844(`kGoldenPhoneSize` 무수정) · `m9s07-asof` dy **788** < 844 · 머리 `m9s07-row-0` 0.0 |
| `m9s07_locked` | 2 | 〃 | `m9/connections_locked` · operator · 390×844 · `m9s07-asof` dy **796** < 844 · 머리 `Key('m9s07-locked')` 0.0 |
| `m9s07_viewer` | 2 | 〃 | `m9/connections`(`m9s07_connections` 와 같은 표본) · null(뷰어 = 버튼 부재) · 390×844 · `m9s07-asof` dy **740** < 844 · 머리 `m9s07-row-0` 0.0 |

- 공통: 흐름 = 클로저 칸 non-null(`(WidgetTester t) async {}`) · 가짜 = testWidgets 안에서 새로(`FakeSettingsOpsStatusRepository` · `RecordingLinkOpener`) · 시계 `FixedClock(kGoldenNowUtc)` · 탭을 찍는 골든 0.
- 🆕 **R6b 병합본 실측**(PR #155 squash `f58e2f9` · 2026-11-14 · Bob `be89e09`(커밋 6) + 재제출 `30704c9`(테스트 파일 +11/−5 · lib·PNG 0) · C4 재실측 일치(이름마다 `--plain-name` · 1회차 · 2회차) · light = dark · 머리 dy 0.0): `m9s07_connections` **956**(390×1040 · `_kM9s07Tall`) · `m9s07_telegram` **788** · `m9s07_locked` **796** · `m9s07_viewer` **740**(390×844) — 드라이런 dy 와 같음 · PNG 8 = 드라이런과 바이트 같음 · 동작 주입 = operator 3이름(`UnimplementedSettingsActions`) · viewer = null · `ui_settings` 테스트 **60**(R6a 23 + `connections_test` 29 + 골든 8) · `git ls-tree` PNG **14**(`m9s01` 6 + `m9s07` 8) · 질문 파일 `docs/ai-context/inbox/M9S07_questions.md` A1~A4 ✅.
