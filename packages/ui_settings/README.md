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

## 지금 상태 — ✅ S01 설정 홈 병합(2026-11-14 · R6a PR #146 squash `9840603` · M9 첫 카드) · ✅ S07 연결 관리 병합(2026-11-14 · R6b PR #155 squash `f58e2f9` · M9 첫 쓰기) · ✅ S05 운용 관리 1/2 병합(2026-11-14 · R6c1 PR #168 squash `b3b759c` · `lib/src/operations.dart` · `Operations()`) · ✅ S05 운용 관리 2/2 병합(2026-11-15 · R6c2 PR #176 squash `02099df` · 램프·잡·엔진·게이트 · `Operations()` 끼워 넣기) · 🏁 R6 · ✅ R6 test-only(PR #184 squash `e36a310` · lib 주석 PR #185 `fef59a3`) · 배럴 export 5 · 라벨 3 · 주입 5(«정확히 N» 확정 — T13 3 · T14 5 · T15 5) · `flutter test` 141 · 골든 PNG 28 · 다음 = R7(S02 · S03 · S06)

`flutter test` ~~**23**~~ ~~**60**~~ ~~**110**~~ ~~**140**~~ **141**(R6 test-only PR #184 squash `e36a310` · 2026-11-15 · 140 + 1 — `connections_test` 29 → 30(새 testWidgets M9S07-14 `loading_viewer`) · `settings_home_test` 16 · `operations_board_test` 28(자리 옮김 · 기존 경우에 단언 줄만) · PR 실측(head `04ffef0` · 파일별 = PR 본문 · 병합본 재실행 0 · CI 3/3) · 테스트 파일만 +119/−67 · lib 주석 PR #185 `fef59a3` 2줄 · 픽스처·PNG·fakes 0 ← R6c2 병합본 140 = R6c1 110 + 뷰 28 `operations_board_test` + 골든 2 `m9s05_board_golden_test` · R6c1 골든 12 다시 찍기(`golden:approved`) · 1회차 `d500433` 반려(C4T-1) → 재제출 `7cc7ea8`(테스트 +7/−9) → 2회차 merge · C4 정정 2(C4T-2 · C4T-3) · 코드 정정 0 ← R6c1 병합본 110 = R6b 60 + 뷰 38 `operations_test` + 골든 12 `m9s05_golden_test` · C4 1회차 `00668d3` merge-with-fixes · C4 정정 1(C4S-1 ① 빈 블록) · 코드 정정 0 ← R6b 병합본 60 = R6a 23 + 뷰 29 `connections_test` + 골든 8 `m9s07_golden_test` · R6b 1회차 `be89e09` 반려(C4R-1 · C4R-2) → 재제출 `30704c9`(테스트 +11/−5) → 2회차 merge · C4 정정 1 · 코드 정정 0 ← R6a 병합본 23 = 뷰 16 `settings_home_test` · 골든 6 `m9s01_golden_test` · 자리표시 1 `ui_settings_test` · 1회차 `7c5ac34` 반려(C4Q-1) → 재제출 `60803aa`(테스트 +11) → 2회차 merge · C4 정정 0 · 코드 정정 0) · 골든 PNG ~~**6장**~~ ~~**14장**~~ ~~**26장**~~ **28장**(`m9s01` 6 + `m9s07` 8 + `m9s05` 14 · `test/golden/README.md` «🆕 R6») · 도구 = Flutter·Dart·melos 설치돼 있다(`docs/toolchain_notes.md` · ~~«이 PC에는 Flutter·Dart·melos가 없다»(2026-09-06)~~ 낡은 줄) · 테스트는 패키지 폴더에서 `flutter test`(🔴 중첩 `melos run test` 는 쓰지 않는다).

- `SettingsHome` = `lib/src/settings_home.dart`(`S01` 설정 홈 · R6a · 원천 `SettingsRepository.watchHome()` 1구독 · 엔진 상태 칩 · 12월 연간 리뷰 카드 · 일반 → 운영 → 규칙 묶음(자물쇠 = `tier`) · 카드 행(등급 아이콘 · 제목 · 상태 한 줄 · 주의 배지 `attentionText`) · 맨 아래 asOf · 쓰기 0).
- `Connections` = `lib/src/connections.dart`(`S07` 연결 관리 · R6b · 원천 `OpsStatusRepository.watchConnections()` → `ConnectionsVm` · 행 = 상태 아이콘 `level` · 이름 · 상태 · 마지막 성공 · 상세 · 상세 링크 · 알림 채널 블록 `channelPicker` · 잠김 `lockedLabel` · 🆕 M9 첫 쓰기 `SettingsActions.run`(행 `actions` · 옵션 `selectAction` 그대로) · 동작 주입 null = 뷰어 = 버튼 부재).
- `Operations` = `lib/src/operations.dart`(`S05` 운용 관리 1/2 · R6c1 · 원천 `SettingsRepository.watchOperations()` → `OperationsVm`(v1.19) 1구독 · 엔진 상태 칩 · 모드 카드(hold 줄 · 관찰 줄 · 승격 버튼 `runtimeLivePromotion` · 고지 · 전환 요청 `switchActions`) · 운영 방식 카드(선택지 · 신뢰 배지 · 전환 점검 · 전환 요청) · 모의 체험 카드 · 지난 요청 줄 · 잠김 `lockedLabel` 한 줄 · 쓰기 = `SettingsActions.run` 1곳(id · args 그대로 · 기다리는 동안 모든 버튼 막기 · 결과 조각 맨 위) · 넘김 = 결과 뒤 `handoffRoute` open 한 곳 · 동작 주입 null = 버튼 부재 · R6c2 가 체험 카드 뒤 · 지난 요청 줄 앞에 램프 · 잡 · 엔진 · 게이트를 끼운다). 🆕 S05 운용 관리 2/2(R6c2 · PR #176 `02099df` · 같은 파일 끝 절 — 램프 `RampBoard` · 잡 `JobRow` · 엔진 시작·중지 `EngineControl`(중지 사유 = 받은 args) · 업데이트 게이트 `UpdateGateCard` · 쓰기 = 같은 `SettingsActions.run` 1곳 · 골든 `m9s05_hold_keys`).
- 주입 ~~3~~ 5 = `lib/src/settings_providers.dart`(R6a 3 = `settingsRepositoryProvider` · `settingsClockProvider` · `settingsLinkOpenerProvider` · 기본 throw — 조립 앱이 override · R6b 끝 절 +2 = `settingsOpsStatusRepositoryProvider`(기본 throw) · `settingsActionsProvider`(`SettingsActions?` 기본 null = 뷰어)).
- 공용 조각 = `lib/src/common/settings_common.dart`(배럴 밖 · `SettingsAsOfLine` · `SettingsStaleBanner` · `SettingsSkeleton` · `SettingsErrorView`).
- 라벨 = `lib/l10n/labels.dart` 3(`retry` · `staleBannerTitle` · R6b `notAccepted`) · 배럴 `lib/ui_settings.dart` export ~~4~~ 5(`l10n/labels.dart` · `src/connections.dart`(R6b) · `src/operations.dart`(R6c1) · `src/settings_home.dart` · `src/settings_providers.dart`).
- 공용 test 파일 = `test/settings_fakes.dart`(~~81줄~~ ~~186줄~~ ~~347줄~~ 384줄 · 첫 절 «// ── R6a — M9 S01 fakes ──» · «// ── R6b — M9 S07 fakes ──»(+105) · «// ── R6c1 — M9 S05 fakes ──»(+161) · 끝 절 «// ── R6c2 — M9 S05 board fakes ──»(+37) · 다음 카드는 끝 절을 더한다 — 둘째 정의 0 · C4r16c-2) · 비교기 `test/flutter_test_config.dart` · `test/golden/shift_tolerant_compare.dart`(`ui_shell` 판 복사 · R6a) · 받침 `test/golden/golden_support.dart`(M2 계약 v1.18).
- 다음 = ~~R6b-Bob-M9S07(`S07` 연결 관리 · M9 첫 쓰기 · 조립 대기 · 밑동 = R6a 병합본) →~~ ~~R6c-Bob-M9S05(`S05` 운용 관리 · 선행 = 계약 v1.19(S05 `OperationsVm` + 엔진 E13i 조율) · 그 뒤 조립 · 밑동 = R6b 병합본 · «정확히 N»)~~ → ~~R6c2-Bob-M9S05b(`S05` 운용 관리 2/2 · 램프 · 잡 · 엔진 · 게이트 · ▶ 「푸시해」 뒤 · 시작 기준 110 · 밑동 = R6c1 병합본 `b3b759c` · «정확히 N» · R6 마지막)~~ ✅ R6c2 병합(2026-11-15 · PR #176 `02099df`) · 🏁 R6 → R7-Bob-M9b(`S02` 키 관리 · `S03` 계좌 매핑 · `S06` 기기·접근 · 조립 대기 · 시작 기준 ~~140~~ 141) · ~~R6 test-only 묶음(통합 담당 · 테스트만)~~ ✅ R6 test-only(PR #184 squash `e36a310` · 140 → 141 · lib 주석 PR #185 `fef59a3` · 2026-11-15) · 🏁 R6 회차 전부 끝.
