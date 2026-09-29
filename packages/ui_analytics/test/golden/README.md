# `test/golden/` — 위젯 골든 스냅샷 (C-2 · 하네스 ✅ 2026-09-17 · PNG ✅ S7-1·S7-3·S7-3b 18장 · 🆕 차트 하네스 2026-09-28)

정본: 01_M2_도메인계약 **§7**(C-1·C-2 + 골든 규칙) · 07_AI어시스턴트_배포프롬프트 **§9** 기계 검사 4

## 🔴 «최초 생성»과 «재생성»은 다르다

| 구분 | 누가 | 규칙 |
|---|---|---|
| **뷰모델 골든** `*.golden.json`(C-1) | 🔴 M2(Claude) 소유 | 화면 담당은 **읽기만**. 깨지면 표시 계약이 바뀐 것이므로 **고치지 말고 질문 목록에 올린다** |
| **위젯 골든 PNG**(C-2) | 화면 담당 | **신규 화면의 최초 베이스라인은 그 화면을 만드는 PR에서 함께 커밋한다** — 그 PR에서만 «추가»가 허용된다. 이후 **픽스처가 그대로인데 스냅샷을 다시 찍는 것은 위조**이며 반려 |

병합 검사는 `git diff --name-status`로 **A(추가)**와 **M(수정)**을 구별한다.

## 규칙

- 렌더 입력은 `packages/domain_contracts/fixtures/`의 픽스처다. **화면 담당은 픽스처를 수정하지 않는다.**
- light / dark 두 벌을 찍는다.
- 플랫폼·폰트 차이로 스냅샷이 흔들리면 **임계 조정은 M2가 한다**. 스스로 임계를 풀지 않는다.

## 하네스 (M2 제공 · 2026-09-17 · ui_journal 과 같은 규약)

화면 담당이 만드는 것은 **골든 테스트 파일과 PNG** 뿐이다.

| 파일 | 누가 | 무엇 |
|---|---|---|
| `test/flutter_test_config.dart` | 🔴 M2 | `flutter test` 가 자동으로 먼저 부른다. 골든 비교기를 **이동·AA 허용 비교기(3판)** 로 바꾼다 — 두 그림을 3×3 으로 살짝 흐린 뒤 **양방향**으로 «이웃 3×3 어디에도 비슷한 색이 없는 유의 픽셀»을 세고, **가장 빽빽한 24×24 창의 밀도 12% 이하(주 판정) 그리고 전체 0.5% 이하(보조)** 면 통과(`golden/shift_tolerant_compare.dart` · 자체 검증 `golden/comparator_test.dart` 11건). 🔵 2026-09-17 실측(리눅스 CI vs Windows 골든 14장): 플랫폼 소음은 전체 ≤0.18%·창 ≤5.6% 로 **얇게 흩어지고**, 구조 변화는 18px 아이콘 1개 누락도 창 27% 로 **뭉친다**(칩 47% · 글자 줄 83% · 배너 96%). 화면 담당은 고치지 않는다 |
| `test/golden/golden_support.dart` | 🔴 M2 | 픽스처 로더(`fixtureEnvelope`·`listFixture<T>`·`singleFixture<T>`) · 고정 시계 `FixedClock`·`kGoldenNowUtc` · 폰 크기 `kGoldenPhoneSize`(390×844) · `pumpForGolden`(light/dark) · `expectGolden(name, brightness)` |
| `test/golden/chart_probe.dart` | 🔴 M2 | 🆕 계약 v1.3 — 차트의 «그리기 기록» 하네스. painter 를 기록용 캔버스에 다시 그려 읽고, 픽스처와 맞는지 **단언까지 한다**(아래 «R10» 절). 화면 담당은 고치지 않는다 |
| `test/golden/chart_probe_test.dart` | 🔴 M2 | 🆕 위 하네스의 자체 검증 46건 — 본보기 painter 는 통과하고 나쁜 painter 17종은 실패함을 고정한다. 본보기 `PerfChart` 의 눈금 글자가 그림 왼쪽 바깥 열에 있다는 것도 여기서 본다 |
| `test/golden/reference/` | 🔴 M2 | 🆕 차트 본보기 구현 3파일. 화면 담당은 `lib/` 로 **글자 그대로 베껴** 쓴다(아래 «R10» 절). 여기 있는 원본은 지우지도 고치지도 않는다 |
| `test/golden/<화면id>_golden_test.dart` | 화면 담당 | 아래 예시대로. `s71_golden_test.dart` |
| `test/golden/goldens/<name>_<light\|dark>.png` | 화면 담당(최초 1회) | `expectGolden` 이 만드는 경로. **커밋 대상** |

### 만드는 순서 (S7-1 예)

1. `test/golden/s71_golden_test.dart` 를 아래 뼈대로 쓴다. 골든 이름은 **명세가 지정** — `s71_normal` · `s71_partial_gap` · `s71_not_generated`. 입력은 전부 픽스처:
   `s71_normal` = `m7/m7_monthly_2026_08.json`(1행 `MonthlyReport`) ·
   `s71_partial_gap` = `m7/m7_monthly_gap.json` ·
   `s71_not_generated` = `m7/m7_monthly_pending.json`(`empty_kind: NOT_LOADED` · 🔵 v1.1 — D-day 문장은 행의 `MonthlyReport.pendingNoticeText` 로 온다. 구 봉투 키 `pending_d_day_text` 는 폐기 — 값을 화면이 만들지 않는다) ·
   헤더 신뢰 등급 = `m7/ledger_trust_4.json`(4행 `LedgerTrustBadge` — 골든에는 0행 `RECONCILED` 사용).
2. 최초 베이스라인 **한 번만**: 패키지 루트(`packages/ui_analytics`)에서 **새 테스트 파일을 지정해**
   ```
   flutter test --update-goldens test/golden/s71_golden_test.dart
   ```
   🔴 ~~`flutter test --update-goldens test/golden`~~(폴더 지정) **금지**(2026-09-23) — 폴더를 주면 이미 있는 다른 화면의 PNG
   (`s71_*`·`s73_*`)까지 다시 찍힌다 = 기존 골든 재생성 = 위조(CI 골든 잡이 `M` 으로 막는다). 새 PNG 만 `??`(추적 안 됨)인지 본다.
   → `test/golden/goldens/s71_normal_light.png` … 6장. 열어서 눈으로 확인한다.
   (🔵 지금 `s71_*` 은 5이름 10장이다 — 뒤에 가림 2종 `s71_masked_integrity`·`s71_masked_recon` 이 더해졌다.)
3. 그 뒤로는 `flutter test` 가 **비교만** 한다. 실패하면 `test/golden/failures/` 의 diff 를 본다 — 픽스처가 그대로인데 다시 찍으면 위조다.
4. PR 에는 테스트 파일 + PNG 6장을 **추가(A)** 로 넣는다.

### 뼈대 — `s71_golden_test.dart` (실물과 같은 이름 · 2026-09-28 정정)

```dart
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden_support.dart';

// 픽스처를 그대로 돌려주는 최소 가짜(테스트 전용). 값을 만들지 않는다.
// 🔴 받침대를 `extends` 한다 — 쓰는 메서드만 @override 하고 나머지는 받침대가 던진다.
//    `implements XRepository` 로 통째 구현하면 M2 가 창구를 더할 때마다 컴파일이 깨진다.
class _FakePerformanceRepository extends UnimplementedPerformanceRepository {
  _FakePerformanceRepository(this._report);
  final MonthlyReport _report;

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async => _report;
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  final MonthlyReport normal = singleFixture(FixturePaths.m7M7Monthly202608, MonthlyReport.fromJson);
  final SafetyState safety = SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[0]);

  for (final Brightness b in Brightness.values) {
    testWidgets('s71_normal ${brightnessSuffix(b)}', (WidgetTester tester) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            // 화면 패키지가 공개한 Provider 들을 override (01 §4-1 주입 규약)
            analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            analyticsLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
            performanceRepositoryProvider.overrideWithValue(_FakePerformanceRepository(normal)),
            safetyRepositoryProvider.overrideWithValue(_FakeSafetyRepository(safety)),
          ],
          child: const MonthlyReportScreen(yyyyMm: '2026-08'),
        ),
        brightness: b,
      );
      await expectGolden('s71_normal', b);
    });
    // s71_partial_gap · s71_not_generated · s71_masked_integrity · s71_masked_recon 도 같은 모양
  }
}
```

- 🔴 `DateTime.now()` 를 테스트에서도 부르지 않는다 — 시계는 `FixedClock(kGoldenNowUtc)`.
- 🔴 테스트 파일에도 한국어 문자열 리터럴을 두지 않는다 — 글자는 전부 픽스처에서 온다.
- 🔴 픽스처를 복사·편집해 «내 픽스처»를 만들지 않는다. 상태 조합이 더 필요하면 `docs/ai-context/inbox/S7-1_questions.md` 에 발주한다.
- 🔵 위 뼈대의 Provider·위젯 이름은 **지금 `lib/` 에 있는 실물**이다(`analyticsClockProvider` · `analyticsLinkOpenerProvider` · `performanceRepositoryProvider` · `safetyRepositoryProvider` · `MonthlyReportScreen`). 새 Provider 는 `Provider<XRepository>((_) => throw UnimplementedError('...'))` 규약(01 §4-1)을 따른다.

## R2 — `S7-3` · `S7-3b` (2026-09-17)

골든 이름(명세 지정) — `s73_normal` · `s73_deep_dd` · `s73b_three_sleeves` · `s73b_partial` × light/dark = **8장**(전부 있다). 테스트 파일 `test/golden/s73_golden_test.dart`.
- `s73b_partial` 의 입력 = `FixturePaths.m7M7ContribPartial`(`m7/m7_contrib_partial.json` · 계약 v1.1 에서 생겼다 — 01 §8 미결 45 ✅). 🔴 이미 찍혀 있다 — 새로 만들지 않는다.
- `s73_insufficient` 만 아직 없다 — 01 §8 미결 44 가 닫힌 뒤(입력 픽스처가 없다).

```dart
final DrawdownContextVm normal = singleFixture(FixturePaths.m7M7DdContextNormal, DrawdownContextVm.fromJson);
final DrawdownContextVm deep = singleFixture(FixturePaths.m7M7DdContextDeep, DrawdownContextVm.fromJson);
final ContributionVm contrib = singleFixture(FixturePaths.m7M7Contrib3sleeve, ContributionVm.fromJson);
final SafetyState safety = SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[0]);
final DateRange range = DateRange(from: TradeDate('2026-08-01'), to: TradeDate('2026-08-31'), presetCode: 'FIXTURE');
// overrides: analyticsClockProvider → FixedClock(kGoldenNowUtc) · performanceRepositoryProvider → 픽스처를 돌려주는 Fake ·
//            safetyRepositoryProvider → Stream.value(safety)
```

- 🔴 **긴 엔진 문자열은 Row 안에서 Expanded/Flexible** — 테스트 폰트는 글자당 1em 폭이라 390px 에서 쉽게 넘친다(S7-1 2회차 실패 원인).
- 비교기는 3판이다(가장 빽빽한 24×24 창 밀도 ≤12% · 전체 ≤0.5%) — 아이콘 하나만 빠져도 실패한다.

## 🆕 계약 v1.1(2026-09-17) — 테스트에서 달라지는 것 3가지

1. **가짜 리포지토리는 받침대를 상속한다** — `import 'package:domain_contracts/testing.dart';` 한 뒤
   `class _FakeX extends UnimplementedXRepository { @override …필요한 메서드만… }`.
   `implements XRepository` 로 통째 구현하면 M2 가 창구를 하나 더할 때마다 테스트가 컴파일에서 깨진다
   (v1.1 에서 실제로 일어났다). 받침대: `UnimplementedJournalRepository` · `UnimplementedPerformanceRepository` ·
   `UnimplementedConfigRepository` · 🆕 `UnimplementedSafetyRepository` · `UnimplementedCommandApi`(2026-09-23 · R2 준비 —
   안전 상태 가짜도 `implements SafetyRepository` 가 아니라 이것을 `extends`). 없는 것이 필요하면 **질문 표에 적는다**(M2 가 더한다).
2. **링크는 기록기로 확인한다** — 화면은 DTO 가 준 링크를 `AppLinkOpener.open(link)` 에 **그대로** 넘긴다(01 §4-4).
   테스트는 `RecordingLinkOpener`(같은 `testing.dart`)를 주입하고
   `expect(opener.opened, <String>[entry.detailDeepLink!])` 처럼 **픽스처에서 읽은 값**과 비교한다.
   🔴 테스트에도 `'aaq://…'` 리터럴을 적지 않는다 — 링크가 null 인 픽스처 행에서는 「버튼이 없다」를 확인한다.
3. **값은 `*Text` 만 그린다** — 일지 행은 `sideLabel`·`quantityText`·`priceText`·`commissionText`·`taxText`,
   가림도 그 문자열 안에 이미 들어 있다(`m6/journal_masked_integrity.json` · `m7/m7_monthly_masked_*.json`).
   화면이 차단 플래그를 보고 값을 감추거나 바꾸는 코드는 v1.1 부터 **반려**다(배너만 얹는다).

## 🆕 모달(바텀시트·다이얼로그)이 열린 상태를 찍는 법 (2026-09-21)

모달은 `MaterialApp` 의 Navigator 위에 뜬다. 그래서 `ProviderScope(overrides: …)` 를 `pumpForGolden` 의 `child` **안에** 넣으면
모달이 그 주입을 보지 못해 `UnimplementedError` 가 난다(실제 앱은 `ProviderScope` 가 앱 루트에 있어 문제없다 — 하네스만의 제약).
주입을 `wrapApp` 으로 **MaterialApp 바깥**에 올린다:

```dart
await pumpForGolden(
  tester,
  const JournalTimeline(),                    // child 에는 화면만
  brightness: b,
  wrapApp: (Widget app) => ProviderScope(overrides: <Override>[ /* … */ ], child: app),
);
await tester.tap(find.text(JournalLabels.filter));   // 모달 열기(정적 라벨로 찾는다)
await tester.pumpAndSettle();
await expectGolden('j1_filter_open', b);
```

단위 테스트도 같다 — `ProviderScope` 를 `MaterialApp` **위에** 두면 시트 안의 위젯이 같은 주입을 본다.
시트 안의 목록은 지연 생성이라 화면 밖 선택지는 위젯 트리에 없다 → `tester.scrollUntilVisible(finder, 120, scrollable: find.byType(Scrollable).last)` 로 내린 뒤 탭한다.
🔴 「필터를 고르면 그 값이 리포지토리 인자로 간다」는 **UI 를 실제로 조작해서** 확인한다 — 테스트가 쿼리를 직접 주입하면 아무것도 검증하지 않는다.

## 🆕 R10(계약 v1.3) — `S7-1b` · `S7-2G` · `S7-2` (2026-09-28)

정본: 01 §13 · 03 §4·§5·§6 의 R10 범위 블록 3개. 이 절은 **골든과 차트 증명**만 말한다.

### 1. 골든 이름 — 12이름 × light/dark = 24장 (전부 신규)

| 이름 | 테스트 파일 | 입력 픽스처(`FixturePaths.…`) | 가는 길 | 크기 |
|---|---|---|---|---|
| `s71b_list` | `s71b_golden_test.dart` | `m7M7ReportArchive18` | 띄운다 | 390 × **1700** |
| `s71b_empty` | 〃 | `m7M7ReportArchiveEmpty` | 띄운다 | 390 × 844 |
| `s72g_first` | `s72g_golden_test.dart` | `m7M7DisclosureGateFirst` | 띄운다 | 390 × 844 |
| `s72g_frequent` | 〃 | `m7M7DisclosureGateFrequent` | 띄운다 | 390 × 844 |
| `s72g_closed` | 〃 | `m7M7DisclosureGateClosed` | 띄운다 | 390 × 844 |
| `s72g_not_accepted` | 〃 | 열린 게이트(`m7M7DisclosureGate`) + **던지는** 명령 가짜 | 「그래도 보기」를 1번 누른다 → 찍기 전에 `expect(tester.takeException(), isNotNull)` | 390 × 844 |
| `s72_monthly_cum` | `s72_golden_test.dart` | `performance24m` 행 0 | 게이트를 눌러 지난다 | 390 × **1400** |
| `s72_daily_gap` | 〃 | `m7M7PerfDailyGap` | 게이트 → «일» | 390 × 1400 |
| `s72_sim_split` | 〃 | `m7M7PerfMonthlySimSplit` | 게이트 | 390 × 1400 |
| `s72_manual_segment` | 〃 | `m7M7PerfDailyManual` | 게이트 → «일» | 390 × 1400 |
| `s72_monthly_period` | 〃 | `m7M7PerfMonthlyPeriod` | 게이트 → «기간별» | 390 × 1400 |
| `s72_unavailable` | 〃 | `m7M7PerfUnavailableGap` | 게이트 → «일» | 390 × 1400 |

- `s72_*` 는 모두 게이트를 **실제로 눌러** 들어간다. 게이트 입력 = 열린 게이트 픽스처(`m7M7DisclosureGate`) · 접수증 = `m7M7DisclosureViewReceipts4` 행 0. 카드가 입력을 달리 적으면 카드가 이긴다.
- 가짜 `series()` 는 받은 인자를 기록하고, 그 골든의 픽스처를 돌려준다(값을 만들지 않는다).
- 🔴 **값 표는 접힌 채 찍는다**(「값 보기」를 누르지 않는다). 값 표의 증명은 위젯 테스트가 한다.
- 🔴 기존 PNG 18장(`s71_*` · `s73_*` · `s73b_*`)은 한 바이트도 바뀌지 않는다. 만드는 명령은 새 파일 셋만 지정한다:
  ```
  flutter test --update-goldens test/golden/s71b_golden_test.dart test/golden/s72g_golden_test.dart test/golden/s72_golden_test.dart
  ```

### 2. 높이와 위치 전제

- 높이는 테스트 파일 안 상수로 두고 `pumpForGolden(…, logicalSize: …)` 에 넘긴다. `kGoldenPhoneSize` 는 고치지 않는다.
- 찍기 **전에** «맨 아래 위젯이 그림 안에 있다»를 단언한다. 목록은 지연 생성이라 그림 밖 위젯은 트리에 없다 — 이 단언이 없으면 잘린 골든이 조용히 통과한다.
  ```dart
  // s72_* — 맨 아래 = 이동 버튼 둘째
  expect(tester.getBottomLeft(find.byKey(const Key('s72-link-contribution'))).dy, lessThan(1400));
  // s72g_* — 맨 아래 = 「돌아가기」(닫힌 게이트 포함) · s71b_empty — 맨 아래 = 빈 상태 글자
  expect(tester.getBottomLeft(find.byKey(const Key('s72g-back'))).dy, lessThan(844));
  expect(tester.getBottomLeft(find.byKey(const Key('s71b-empty'))).dy, lessThan(844));
  // s71b_list — 맨 아래 = 끝 행(픽스처의 마지막 yyyyMm)
  expect(tester.getBottomLeft(find.byKey(ValueKey<String>('s71b-row-${rows.last.yyyyMm}'))).dy, lessThan(1700));
  ```

### 3. 골든은 보조다 — 차트의 주 증명은 `chart_probe.dart`

비교기(3판)는 옅은 채움(`surfaceContainerHighest`) · 점선 · 2px 어긋남을 못 본다. 그래서 «결측에서 선이 끊겼다»·«띠가 있다»는
**그리기 기록**으로 증명한다. 기대값은 화면 담당이 쓰지 않는다 — 하네스가 넘겨받은 픽스처에서 계산한다.

```dart
import 'chart_probe.dart';       // test/golden/ 안에서. test/ 바로 아래 파일이면 'golden/chart_probe.dart'
import 'golden_support.dart';

final PerformanceSeries series = singleFixture(FixturePaths.m7M7PerfDailyGap, PerformanceSeries.fromJson);
// … 화면을 띄운다(차트가 화면에 있어야 한다) …
final ColorScheme scheme = chartSchemeOf(tester);        // 차트를 둘러싼 테마의 색
final ChartRecording recording = recordChart(tester);     // Key('s72-chart') 의 painter 를 다시 그려 기록
expectMainLineMatches(recording, series, scheme);
expectBenchmarkMatches(recording, series, scheme);
expectBandsMatch(recording, series, scheme);
expectTicksMatch(recording, series, scheme);
```

| 함수 | 통과 조건 |
|---|---|
| `recordChart(tester, {key})` | `CustomPaint(key: Key('s72-chart'))` 가 화면에 1개 있고 `painter` 가 있다(`foregroundPainter` 는 쓰지 않는다) |
| `recordPainter(painter, size)` | 위젯 없이 painter 만 볼 때 |
| `chartSchemeOf(tester, {key})` | 그 차트 자리의 `Theme.of(…).colorScheme` |
| `expectMainLineMatches` | `primary` · 획 · 굵기 3 · 둥근 끝·이음. 윤곽(+ 점 1개짜리 원) 수 = 값이 이어진 범위 수. 점 전부가 선 위에 · 선 전부가 점을 직선으로 이은 자리에(±0.02). 가장 큰 `yNormalized` 의 점이 가장 위. 곡선이면 실패. 본선이 맨 위 층 |
| `expectBenchmarkMatches` | `benchmark == null` 이면 `tertiary` 획·원 0. 있으면 `tertiary` · 굵기 2 · **점선**(조각 길이 ≤ 6.5 · 그린 길이가 전체의 0.45~0.75) · 자기 결측에서만 끊김 |
| `expectBandsMatch` | 채움 수 = `unavailable` + `simExcluded` 구간 수 · 가로 범위 = (`startNormalized`, `endNormalized`) ±0.02 · 세로 = 그림 전체. `unavailable` 은 그 띠로 자른 45° 빗금(간격 8). `simExcluded` 양 끝 = 세로 **점선** · `manualExecuted` 양 끝 = 세로 **실선**. 그 밖의 자리에 세로선·빗금이 있으면 실패 |
| `expectTicksMatch` | 가로선 수 = `yTicks` 수 · 세로 자리 = `normalized` ±0.02 · 가로 = 그림 전체 · 기준선은 `outline`·2, 그 밖은 `outlineVariant`·1 |

네 함수가 **공통으로** 먼저 보는 것: ① 금지 호출 0 — `saveLayer` · `translate`·`scale`·`rotate`·`transform` · 글자 그리기 · 그라디언트·`MaskFilter` · 짝 없는 `save`/`restore` · `save` 밖의 `clipRect` ② 층 표에 없는 그리기 0 ③ 층의 순서 = 띠 → 눈금선 → 벤치마크 → 본선.

- 비교는 **비율**이다. 가로 = x ÷ 그림 폭 · 세로 = 1 − y ÷ 그림 높이. 그림 영역 = `CustomPaint` 의 크기 전체(안쪽 여백 없음).
- 🆕 `PerfChart` 의 짜임(2026-09-29) = 상자(높이 220) → 위아래 12 → 가로로 [ **눈금 글자 열(폭 56)** · 빈칸 8 · 그림(`CustomPaint` · 남은 폭 전부) ]. 눈금 글자는 그림 **왼쪽 바깥 열**에 있다 — 글자가 선과 띠를 덮지 않는다(누적 시리즈의 첫 점은 늘 왼쪽 아래 끝에 온다). 글자 자리 = `Align(alignment: FractionalOffset(1, 1 - tick.normalized))`(열의 오른쪽 끝 · 세로는 정규값 그대로). 그림 폭 = 부모 폭 − 64(폰 폭 390 이면 326 × 196). 그림의 왼쪽 변 자리는 상수 `PerfChart.plotInsetLeft`(64)로 공개한다 — x 양 끝 글자 줄이 그만큼 왼쪽을 띄운다. 실측 여유(드라이런 2026-09-29): 맨 아래 위젯의 아래 끝 = `s71b_list` 1330 · `s71b_empty` 104 · `s72_*` 608~972 · `s72g_*` 196~272.
- 🔴 그림 안쪽에 여백을 두면 하네스가 `… got 0.02xx` 꼴로 실패한다(예: `main line: point #0 (0.0000, 0.0000) is not on the drawn line (nearest 0.0204)` · 세로 4px 부터 · 메시지는 여백을 말하지 않는다) — 여백은 `PerfChart` **바깥**에서 준다.
- 🔴 불가 시리즈(`points` 가 비어 있음 · 골든 `s72_unavailable`)는 차트가 없다 — `find.byKey(kChartProbeKey)` 가 0 임을 보고(`findsNothing`) `recordChart` 를 **부르지 않는다**(부르면 실패한다).
- 🔴 `chart_probe.dart` · `chart_probe_test.dart` · `reference/` 는 **고치면 반려**다. 맞지 않으면 `docs/ai-context/inbox/` 질문 표에 적는다.
- 🔴 기대값을 테스트에 손으로 적지 않는다(«선이 2개다» 같은 수도). 픽스처를 넘기면 하네스가 센다.
- 실패 메시지는 영어 한 줄이다. 예: `main line: expected 2 contour(s) — one per run of consecutive non-null points [(0,12) (15,20)] — drew 1. A gap must break the line.`

**하네스가 못 보는 것**(알고 쓴다):
- 눈금 **글자**의 자리와 내용 — 글자는 위젯이다. `find.byKey(ValueKey<String>('s72-tick-$i'))` 와 픽스처의 `label` 로 위젯 테스트가 본다(글자의 오른쪽 끝 ≤ 그림의 왼쪽 변 — `tester.getRect`).
- 허용 오차(0.02) 안의 **가로 어긋남** — 왼쪽 끝에 붙은 띠는 가로를 0.9배로 줄여 그려도 통과한다(`m7_perf_monthly_sim_split` 의 띠 0~0.1471 → 0~0.1324 · 차 0.0147). 같은 잘못이 본선이나 오른쪽 띠에 있으면 잡힌다.
- 점선 벤치마크의 **아주 좁은 틈**(폭의 0.02 안팎보다 좁은 결측)을 이어 그린 것. 점 60개 · 결측 1점(틈 0.034)까지는 잡는다.
- 실제 픽셀(안티에일리어싱 · 플랫폼 차이) — 그것은 골든 몫이다.

### 4. 본보기 3파일을 `lib/` 로 옮기는 법

차트 코드는 새로 짜지 않는다. `test/golden/reference/` 의 세 파일을 **글자 그대로** 베낀다(폴더 모양이 같아 import 도 그대로다).

| 본보기(M2 · 그대로 둔다) | 베낄 곳(화면 담당) |
|---|---|
| `test/golden/reference/chart/perf_chart_geometry.dart` | `lib/src/chart/perf_chart_geometry.dart` |
| `test/golden/reference/chart/perf_chart_painter.dart` | `lib/src/chart/perf_chart_painter.dart` |
| `test/golden/reference/widgets/perf_chart.dart` | `lib/src/widgets/perf_chart.dart` |

```
# packages/ui_analytics 에서
mkdir -p lib/src/chart
cp test/golden/reference/chart/perf_chart_geometry.dart lib/src/chart/
cp test/golden/reference/chart/perf_chart_painter.dart  lib/src/chart/
cp test/golden/reference/widgets/perf_chart.dart        lib/src/widgets/
# 병합 검사가 보는 것 — 둘 다 출력이 없어야 한다(차이 0)
git diff --no-index --stat test/golden/reference/chart lib/src/chart
git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart
# (🔴 diff -r 을 쓰지 않는다 — PowerShell 에서 diff 는 Compare-Object 라 파일이 같아도 차이가 찍힌다)
```

- 본보기 원본은 **지우지 않는다** — 하네스 자체 검증이 쓴다.
- 배럴(`lib/ui_analytics.dart`)에 세 파일을 export 하지 않는다(내부 파일이다). 테스트는 `package:ui_analytics/src/…` 로 직접 import 한다.
- 세 파일은 `lib/` 의 기계 검사를 이미 통과한 글자다(C-3 import · C-4 산술 이름 · C-5 한글 리터럴 · C-12 switch 전부 받기 · C-36 ⑦⑧). 이름을 바꾸면 C-4 에 걸릴 수 있다 — `ratio`·`tax`·`cash`·`pct`·`price`·`amount`·`pnl`·`commission`·`cagr` 가 든 이름(`aspectRatio`·`duration`·`iteration` 포함)을 쓰지 않는다.
- 차트에 더할 것이 생기면(예 선택 표시) 코드를 고치지 말고 질문 표에 적는다 — 층 표가 계약이다.

### 5. 미리보기 PNG (눈 확인용 · 골든 아님)

```
# packages/ui_analytics 에서 — 폴더는 저장소 밖 아무 곳
AAQ_CHART_PREVIEW_DIR=/tmp/chart_preview flutter test test/golden/chart_probe_test.dart --plain-name "preview png"
```

본보기 `PerfChart` 를 성과 픽스처 7개(정상 6건 · `performance24m` 은 2행) × light/dark 로 찍어 그 폴더에 둔다. 변수가 없으면 아무것도 하지 않는다.
🔴 `test/golden/goldens/` 를 가리키지 않는다.
