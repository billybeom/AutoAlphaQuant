# ui_analytics — M7 성과 · 리밸런싱 · 플래너

> **owner(계약·사양)**: Claude · **코드 담당**: **다른 AI(화면)**
> **청사진 카드**: **M7** analytics-planner-ui
> **화면 명세**: `11_앱설계/03_화면명세_M7_성과_리밸런싱_플래너.md`(화면 13개 — `S7-1`~`S7-10` + `S7-1b`·`S7-2G`·`S7-3b` · `S7-10` = X7 안내 이행 리포트)
> **선행 의존**: **M2 계약 확정(G3) + 픽스처(G4)** · **M3 미리보기 API**(`WhatIfApi`)

## 무엇을 담나

성과 차트(TWR/MWR) · 월간 리포트 · 리밸런싱 이력 · 입금·인출 플래너 미리보기 · blind 리뷰.

## 의존 — 허용 (01 §1-1)

`domain_contracts` · Flutter · `flutter_riverpod`.

## 의존 — 🔴 금지 (넣으면 C-3이 빌드를 막는다)

`core_engine` · **`decimal`** · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · `http`.

## 이 패키지가 지는 규칙 5개

1. **TWR/MWR을 계산하지 않는다.** 누적/비누적 토글도 화면 누적곱이 아니라 엔진 재요청이다 — 단일 산식 원칙.
2. **결측을 은폐하지 않는다.** `PerfPoint.value == null`은 **보간 금지, 공백으로** 그린다(C-10). 분절 구간(`PerfSegment`)의 사유 문구도 엔진이 준다.
3. **손익은 격리된 자리에서만 보인다**(결정 8) — 진입 인터스티셜 + 격리 화면 + **열람 기록**(`recordDisclosureView`) 3종이 함께 있어야 한다. 열람 기록은 화면 내부 상태가 아니라 명령 API로 남긴다.
4. **미리보기는 미리보기다.** 계획에는 유효기한이 있고 만료 계획으로는 등록이 거부된다. 「미리보기입니다」 같은 고지도 **엔진 문구**(`previewNotice`)다.
5. **`ResumeReport`는 읽기 사본까지만**이다(`S7-8`). 원본 화면은 `ui_safety`(M5) 소유다.

## 차트 — 라이브러리를 쓰지 않는다 (계약 v1.3 · 2026-09-28 확정)

차트 라이브러리는 **고르지 않는다**. `CustomPaint` 로 직접 그린다. 의존은 위 셋으로 **고정**이다.

- 까닭: 대부분의 차트 라이브러리는 null 을 조용히 이어 그린다. 결측은 **공백**이어야 한다(C-10). 의존을 더하면 C-3 도 막는다.
- 입력: 엔진이 준 0.0~1.0 정규값(`xNormalized`·`yNormalized`·`startNormalized`·`endNormalized`·`PerfAxisTick.normalized`)뿐이다. 화면의 산술은 «정규값 × 폭·높이» 하나다. 축 범위·눈금·최솟값·최댓값을 화면이 구하지 않는다.
- 글자: 숫자 글자는 전부 엔진 문자열(`valueText`·`dateText`·`PerfAxisTick.label`)이다. painter 안에서 글자를 그리지 않는다.
- 코드: 본보기 3파일이 `test/golden/reference/` 에 있다. `lib/src/chart/`·`lib/src/widgets/` 로 **글자 그대로 베껴** 쓴다(`test/golden/README.md` «R10» 절). 🆕 v1.4 — S7-9 목표 경로 본보기 2파일은 `test/golden/reference/goal_path/` → `lib/src/goal_path/`(같은 절 §4 · «R11» 절).
- 증명: 그리기 기록 하네스 `test/golden/chart_probe.dart` 가 주 증명이고 골든은 보조다(같은 절). 🆕 v1.4 — 목표 경로는 같은 파일의 `expectGoalPathMatches`(«R11» 절).
- 층·색·굵기 표는 01 §13-2 가 정본이다 — 고정이다.

## 지금 상태 (2026-09-30 · 계약 v1.4 선행 M2 보강 시점)

| 무엇 | 상태 |
|---|---|
| 도구 | Flutter·Dart·melos 설치돼 있다(`docs/toolchain_notes.md`). 테스트는 패키지 폴더에서 `flutter test`(🔴 중첩 `melos run test` 는 쓰지 않는다) |
| 화면(13개 중) | ✅ 6개 — `S7-1` `MonthlyReportScreen` · `S7-1b` `ReportArchiveScreen` · `S7-2G`·`S7-2` `PerformanceExploreScreen` · `S7-3` `DrawdownContextScreen` · `S7-3b` `ContributionScreen` |
| 다음 카드 R11 | ⬜ **R11a** `S7-4` 투자금 플래너(폰 전용 · 배럴 밖 `package:ui_analytics/planner.dart` · TARGETS T-4) → **R11b** `S7-9` 목표 경로(`GoalPathScreen` · 배럴 +1) + S7-1 진입 버튼 부록. `S7-5` 인출은 **R11c · 인출 규칙 결정 뒤 첫 minor 로 보류** |
| 그 밖 | ⬜ `S7-6`~`S7-8` · `S7-10` — 아직 없다 |
| 공용 위젯 | `StaleBanner` · `SafetyBlockBanner` · `TrustBadgeView` · `PerfChart`(내부 — 배럴에 없다) |
| 차트 | `lib/src/chart/`·`lib/src/widgets/perf_chart.dart` = R10 본보기의 diff 0 사본. 🆕 목표 경로 본보기 2파일은 아직 `test/golden/reference/goal_path/` 에만 있다(M2 소유 · R11b 가 `lib/src/goal_path/` 로 옮긴다) |
| 배럴 검사 | G13(`performance_explore_gate_test.dart`) = 7경로 각 1 + `src/planner`·`src/chart/`·`src/screens/explore/`·`src/goal_path/` export 0(🆕 v1.4 완화 · 집합 완전 일치는 R11a T74-22 · R11b T79-14 로 이관) |
| 정적 라벨 | `lib/l10n/labels.dart` `AnalyticsLabels` 21개 |
| 테스트 | 196건 통과(R10 병합 뒤 180 + 🆕 목표 경로 하네스 자체 검증 16 · 실측 2026-09-30) |
| 골든 PNG | 42장(`s71_*` 10 · `s71b_*` 4 · `s72g_*` 8 · `s72_*` 12 · `s73_*` 4 · `s73b_*` 4) |
