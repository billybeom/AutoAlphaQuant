# ui_settings — M9 설정 · 자격증명 · 계좌 · 기기 · 연결

> **owner**: **공동** — 등급 판정·검증 드라이런·저장 경로는 **Claude**, 렌더는 **다른 AI(화면)**
> **청사진 카드**: **M9** admin-settings-ui (+ **X4** 캘린더 설정 화면 1개)
> **화면 명세**: `11_앱설계/05_화면명세_M9_설정_관리자.md`(설정 화면 12개)
> **선행 의존**: **M2 계약(G3)** · M4 키 금고

## 무엇을 담나

일반 설정 · 자격증명 등록/검증 · 계좌↔슬리브 매핑 · 전략 미리보기/적용 요청 · 런타임(모드·엔진 시작/정지) 요청 · 기기 페어링 · 연결 진단 · 백업/복원 · 셀프테스트 · 캘린더(X4).

## 의존 — 허용 (01 §1-1)

`domain_contracts` · Flutter · `flutter_riverpod`.

## 의존 — 🔴 금지 (넣으면 C-3이 빌드를 막는다)

`core_engine` · **`decimal`** · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · `http` · KIS SDK.

> 설정 화면이라고 해서 예외가 아니다. 저장·검증·동기화는 **전부 `SettingsActions` 뒤**에 있다.

## 이 패키지가 지는 규칙 4개

1. **동작은 `run()` 1회 + `handoffRoute` 이동으로 끝난다**(01 §4-3). 냉각 30일·12월 창·48h 대기·체크리스트 7항 UI를 화면이 만들면 **반려**다 — 그 마찰은 M5 소유다.
2. **구현체가 없으면 버튼을 만들지 않는다.** 뷰어 빌드에서 `SettingsActions`는 `null`이고, 그때 화면은 컨트롤을 **렌더하지 않는다** — «비활성»이 아니라 **부재**다(05 §5-2). 시크릿이 관여하는 경로가 뷰어에 존재해서는 안 된다.
3. **결과 문구를 요약·의역하지 않는다.** `ActionResult.headline`을 그대로 쓰고, 원문 코드(`reasonCode`)가 오면 함께 보인다.
4. **v2.31 P0S 정합**: 계좌 연결에 «해외주식»이 없다(1차 자동화는 국내상장 ETF만) · 슬리브 칸은 A/B/C이되 개수를 상수로 알지 않는다 · 새틀라이트는 **숨김**이다.

## ⚠️ 미결 — 임의 확정 금지

- `SettingsActionId`의 **인자 스키마·반환 필드**가 미확정이다(01 §8-13). ~~열거형 20종만 고정돼 있다~~ 열거형 값은 계약 판마다 늘어난다(계약 v1.18 기준 31종 — 2026-11-14 · 개수를 상수로 알지 않는다) — 화면은 인자 이름을 상상하지 말고 요청 목록에 올린다.
- `FeatureFlags.calendarEnabled`가 `false`면 **M9 캘린더 화면 자체가 없다**. X4 채택은 OAuth 동의화면 만료 실측에 달려 있다.
- 골든벡터 서브케이스 **총계를 화면에 상수로 적지 않는다**(01 §8-14) — 진단 화면이 총계를 표시할지 자체가 미결이다.

## 지금 상태 — ✅ S01 설정 홈 병합(2026-11-14 · R6a PR #146 squash `9840603` · M9 첫 카드)

`flutter test` **23**(R6a 병합본 · 뷰 16 `settings_home_test` · 골든 6 `m9s01_golden_test` · 자리표시 1 `ui_settings_test` · 1회차 `7c5ac34` 반려(C4Q-1) → 재제출 `60803aa`(테스트 +11) → 2회차 merge · C4 정정 0 · 코드 정정 0) · 골든 PNG **6장**(`test/golden/README.md` «🆕 R6») · 도구 = Flutter·Dart·melos 설치돼 있다(`docs/toolchain_notes.md` · ~~«이 PC에는 Flutter·Dart·melos가 없다»(2026-09-06)~~ 낡은 줄) · 테스트는 패키지 폴더에서 `flutter test`(🔴 중첩 `melos run test` 는 쓰지 않는다).

- `SettingsHome` = `lib/src/settings_home.dart`(`S01` 설정 홈 · R6a · 원천 `SettingsRepository.watchHome()` 1구독 · 엔진 상태 칩 · 12월 연간 리뷰 카드 · 일반 → 운영 → 규칙 묶음(자물쇠 = `tier`) · 카드 행(등급 아이콘 · 제목 · 상태 한 줄 · 주의 배지 `attentionText`) · 맨 아래 asOf · 쓰기 0).
- 주입 3 = `lib/src/settings_providers.dart`(`settingsRepositoryProvider` · `settingsClockProvider` · `settingsLinkOpenerProvider` · 기본 throw — 조립 앱이 override).
- 공용 조각 = `lib/src/common/settings_common.dart`(배럴 밖 · `SettingsAsOfLine` · `SettingsStaleBanner` · `SettingsSkeleton` · `SettingsErrorView`).
- 라벨 = `lib/l10n/labels.dart` 2(`retry` · `staleBannerTitle`) · 배럴 `lib/ui_settings.dart` export 3(`l10n/labels.dart` · `src/settings_home.dart` · `src/settings_providers.dart`).
- 공용 test 파일 = `test/settings_fakes.dart`(81줄 · 첫 절 «// ── R6a — M9 S01 fakes ──» · 다음 카드는 끝 절을 더한다 — 둘째 정의 0 · C4r16c-2) · 비교기 `test/flutter_test_config.dart` · `test/golden/shift_tolerant_compare.dart`(`ui_shell` 판 복사 · R6a) · 받침 `test/golden/golden_support.dart`(M2 계약 v1.18).
- 다음 = R6b-Bob-M9S07(`S07` 연결 관리 · M9 첫 쓰기 · 조립 대기 · 밑동 = R6a 병합본) → R6c-Bob-M9S05(`S05` 운용 관리 · 선행 = 계약 v1.19 · «정확히 N»).
