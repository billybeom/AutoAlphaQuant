# `test/golden/` — 위젯 골든 스냅샷 (C-2 · 하네스 ✅ 2026-09-17 · PNG ✅ S7-1·S7-1b·S7-2G·S7-2·S7-3·S7-3b·S7-4·S7-9·S7-6a·S7-6b 76장 · 차트 하네스 2026-09-28 · 🆕 목표 경로 본보기 2026-09-30)

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
- 플랫폼·폰트 차이로 스냅샷이 흔들리면 **임계 조정은 M2가 한다**. 스스로 임계를 풀지 않는다. 조정 기록: 비교기 3판 = infra PR #3(2026-09-17) · 보조 기준 0.5% → **1.0%** + **P2**(0.5% 초과는 창 7% 이하만 통과) = 2026-10-01(R11a PR #19 리눅스 CI 실측 + 적대 검토 · 아래 표).

## 하네스 (M2 제공 · 2026-09-17 · ui_journal 과 같은 규약)

화면 담당이 만드는 것은 **골든 테스트 파일과 PNG** 뿐이다.

| 파일 | 누가 | 무엇 |
|---|---|---|
| `test/flutter_test_config.dart` | 🔴 M2 | `flutter test` 가 자동으로 먼저 부른다. 골든 비교기를 **이동·AA 허용 비교기(3판)** 로 바꾼다 — 두 그림을 3×3 으로 살짝 흐린 뒤 **양방향**으로 «이웃 3×3 어디에도 비슷한 색이 없는 유의 픽셀»을 세고, **가장 빽빽한 24×24 창의 밀도 12% 이하(주 판정) 그리고 전체 1.0% 이하(보조) 그리고 전체가 0.5% 를 넘으면 창 7% 이하(P2)** 면 통과(`golden/shift_tolerant_compare.dart` · 판정 함수 `acceptsSignificantDiff` · 자체 검증 `golden/comparator_test.dart` 32건 — 폰 크기 판정 9건 + P2 5건 + 창 12% 양쪽 4건 + 비교기 연결 3건(실제 PNG 로 `compare` 직접 호출) 포함). 🔵 2026-09-17 실측(리눅스 CI vs Windows 골든 14장): 플랫폼 소음은 전체 ≤0.18%·창 ≤5.6% 로 **얇게 흩어지고**, 구조 변화는 18px 아이콘 1개 누락도 창 27% 로 **뭉친다**(칩 47% · 글자 줄 83% · 배너 96%). 🔵 **2026-10-01 보조 기준 0.5% → 1.0%**(R11a PR #19 리눅스 CI 실측 112장 = ui_analytics 56 + ui_journal 56): 글자가 빽빽한 S7-4 화면의 흩어진 소음이 전체 0.592%(`s74_pension_limit_hit` light · 창 5.2%)로 옛 보조 기준**만** 넘었다. 112장의 창 밀도는 모두 ≤5.2% 라 주 기준 12% 는 그대로다. 새 값은 소음 최대 0.592% 의 1.69배이고, 전체 비율로도 잡히던 구조 변화(칩 1.4% · 글자 줄 3.4% · 배너 15.8%)는 여전히 1.0% 위다(아이콘 누락 0.06% 는 처음부터 창 기준 몫). 🔵 **같은 날 P2**(적대 검토): 보조 기준만 올리면 «1px 선 → 3px»(테두리·차트 격자 전부 굵어짐 — S7-2 6장 전체 0.606~0.607% · 창 51/576 8.9%)를 옛 판정은 잡고 새 판정은 놓친다. 전체 비율로는 소음(0.592%)과 겹쳐 못 가르고 창이 가른다(소음 ≤5.2% vs 8.9%) → **전체 0.5% 초과는 창 7%(≈40/576) 이하일 때만 통과** (`kGoldenStrictDiffTolerance` 0.005 · `kGoldenThinWindowDensity` 0.07). PR #19 CI 112장은 모두 통과(0.5% 를 넘는 장은 1장 · 창 5.2%) · 검토가 찾은 «옛 판정만 잡던» 7건은 모두 실패. 화면 담당은 고치지 않는다 |
| `test/golden/golden_support.dart` | 🔴 M2 | 픽스처 로더(`fixtureEnvelope`·`listFixture<T>`·`singleFixture<T>`) · 고정 시계 `FixedClock`·`kGoldenNowUtc` · 폰 크기 `kGoldenPhoneSize`(390×844) · `pumpForGolden`(light/dark) · `expectGolden(name, brightness)` |
| `test/golden/chart_probe.dart` | 🔴 M2 | 🆕 계약 v1.3 — 차트의 «그리기 기록» 하네스. painter 를 기록용 캔버스에 다시 그려 읽고, 픽스처와 맞는지 **단언까지 한다**(아래 «R10» 절). 화면 담당은 고치지 않는다 |
| `test/golden/chart_probe_test.dart` | 🔴 M2 | 🆕 위 하네스의 자체 검증 46건 — 본보기 painter 는 통과하고 나쁜 painter 17종은 실패함을 고정한다. 본보기 `PerfChart` 의 눈금 글자가 그림 왼쪽 바깥 열에 있다는 것도 여기서 본다 |
| `test/golden/reference/` | 🔴 M2 | 🆕 차트 본보기 구현 3파일(`chart/`·`widgets/`) + 🆕 v1.4 목표 경로 2파일(`goal_path/`). 화면 담당은 `lib/` 로 **글자 그대로 베껴** 쓴다(아래 «R10» 절 §4). 여기 있는 원본은 지우지도 고치지도 않는다 |
| `test/golden/goal_path_probe_test.dart` | 🔴 M2 | 🆕 v1.4 — 목표 경로 하네스(`expectGoalPathMatches`)와 본보기 `reference/goal_path/` 의 자체 검증 16건: 본보기는 목표 경로 픽스처 on·off·realworld 로 통과하고 hold 는 그리지 않으며, 나쁜 painter 2종(보간 · 층 바꿈)은 실패함을 고정한다(아래 «R11» 절) |
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
- 비교기는 3판이다(가장 빽빽한 24×24 창 밀도 ≤12% · 전체 ≤1.0% · 전체 0.5% 초과면 창 ≤7% — 2026-10-01 0.5% 에서 조정 + P2) — 아이콘 하나만 빠져도, 선이 화면 넓게 굵어져도 실패한다.

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

🆕 **3분할(2026-09-29)** — 골든은 카드마다 자기 몫만 만든다: **R10a-Bob-S71b** = `s71b_*` 4장(`s71b_golden_test.dart`) · **R10b-Bob-S72G** = `s72g_*` 8장(`s72g_golden_test.dart`) · **R10c-Bob-S72** = `s72_*` 12장(`s72_golden_test.dart`). 앞 카드가 만든 PNG 는 다음 카드에게 **기존 PNG** 다(바뀌면 반려). ✅ 세 장 모두 병합(R10a PR #15 `02e8e06` · R10b PR #16 `510a8d1` · R10c PR #17 `1cada8a`) — 다음 카드에게 `ui_analytics` 기존 PNG 는 **42장**(`s71_*`·`s73_*`·`s73b_*` 18 + `s71b_*` 4 + `s72g_*` 8 + `s72_*` 12).

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
- 🔴 기존 PNG 18장(`s71_*` · `s73_*` · `s73b_*`)은 한 바이트도 바뀌지 않는다(3분할 — R10b 에게는 22장 · R10c 에게는 30장 · R10 뒤 카드에게는 42장). 만드는 명령은 **자기 카드의 새 파일 하나만** 지정한다(아래는 세 장을 합친 모양 — R10a = `s71b_golden_test.dart` · R10b = `s72g_golden_test.dart` · R10c = `s72_golden_test.dart`):
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
- 병합본 실측(R10a · PR #15 `02e8e06` · 2026-09-29 · C4 재실측 일치): `s71b_list` 끝 행 아래 끝 = **1284**(< 1700) · `s71b_empty` 빈 글자 아래 끝 = **76**(< 844). 드라이런(1330 · 104)과의 차이는 여백·행 높이 재량이다(결함 아님).
- 병합본 실측(R10b · PR #16 `510a8d1` · 2026-09-29 · C4 2회차 재실측 일치): `s72g-back` 아래 끝 = first **191** · frequent **235** · closed **215** · not_accepted **262**(모두 < 844 · light=dark). 드라이런(196~272)과의 차이는 여백 재량이다(결함 아님).
- 병합본 실측(R10c · PR #17 `1cada8a` · 2026-09-30 · C4 2회차 재실측 일치): `s72-link-contribution` 아래 끝 = monthly_cum **1040** · daily_gap **944** · sim_split **944** · manual_segment **944** · monthly_period **1040** · unavailable **604**(모두 < 1400 · light=dark). 1회차(`9230112`)와 같은 값이다 — 재제출의 고지 카드 자리 이동은 맨 아래 값을 바꾸지 않았다. 드라이런(608~972)과의 차이는 여백 재량이다(결함 아님 — 고지 카드 높이 160 대 136 · 기록 줄은 R10b 짜임대로 맨 위 0).

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
- 🆕 `PerfChart` 의 짜임(2026-09-29) = 상자(높이 220) → 위아래 12 → 가로로 [ **눈금 글자 열(폭 56)** · 빈칸 8 · 그림(`CustomPaint` · 남은 폭 전부) ]. 눈금 글자는 그림 **왼쪽 바깥 열**에 있다 — 글자가 선과 띠를 덮지 않는다(누적 시리즈의 첫 점은 늘 왼쪽 아래 끝에 온다). 글자 자리 = `Align(alignment: FractionalOffset(1, 1 - tick.normalized))`(열의 오른쪽 끝 · 세로는 정규값 그대로). 그림 폭 = 부모 폭 − 64(폰 폭 390 이면 326 × 196). 그림의 왼쪽 변 자리는 상수 `PerfChart.plotInsetLeft`(64)로 공개한다 — x 양 끝 글자 줄이 그만큼 왼쪽을 띄운다. 실측 여유: 맨 아래 위젯의 아래 끝 = `s71b_list` 1284 · `s71b_empty` 76(R10a 병합본 · 드라이런 1330 · 104) · `s72_*` 604~1040(R10c 병합본 · 드라이런 608~972) · `s72g_*` 191~262(R10b 병합본 · 드라이런 196~272).
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
| 🆕 v1.4 `test/golden/reference/goal_path/goal_path_chart_painter.dart` | `lib/src/goal_path/goal_path_chart_painter.dart`(R11b) |
| 🆕 v1.4 `test/golden/reference/goal_path/goal_path_chart.dart` | `lib/src/goal_path/goal_path_chart.dart`(R11b) |

```
# packages/ui_analytics 에서
mkdir -p lib/src/chart
cp test/golden/reference/chart/perf_chart_geometry.dart lib/src/chart/
cp test/golden/reference/chart/perf_chart_painter.dart  lib/src/chart/
cp test/golden/reference/widgets/perf_chart.dart        lib/src/widgets/
# 병합 검사가 보는 것 — 둘 다 «… changed» 요약 줄(예 «1 file changed» · «3 files changed»)이 없어야 한다(차이 0)
# («warning: in the working copy of … LF will be replaced by CRLF» 줄은 차이가 아니다 — Windows 의 core.autocrlf 경고)
git diff --no-index --stat test/golden/reference/chart lib/src/chart
git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart
# 🆕 v1.4 — R11b(S7-9)는 목표 경로 2파일을 더 옮긴다. geometry 는 '../chart/perf_chart_geometry.dart' 로 lib 쪽 R10 파일에 그대로 풀린다
mkdir -p lib/src/goal_path
cp test/golden/reference/goal_path/goal_path_chart_painter.dart lib/src/goal_path/
cp test/golden/reference/goal_path/goal_path_chart.dart         lib/src/goal_path/
git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path
# (R10 의 위 두 줄도 그대로 돌린다 — R10 파일 무변경도 계속 본다)
# (🔴 diff -r 을 쓰지 않는다 — PowerShell 에서 diff 는 Compare-Object 라 파일이 같아도 차이가 찍힌다)
```

- 본보기 원본은 **지우지 않는다** — 하네스 자체 검증이 쓴다.
- 배럴(`lib/ui_analytics.dart`)에 세 파일을 export 하지 않는다(내부 파일이다). 🆕 v1.4 — `lib/src/goal_path/` 두 파일도 같다(G13 이 `src/chart/`·`src/goal_path/` export 0 을 본다). 테스트는 `package:ui_analytics/src/…` 로 직접 import 한다.
- 세 파일은 `lib/` 의 기계 검사를 이미 통과한 글자다(C-3 import · C-4 산술 이름 · C-5 한글 리터럴 · C-12 switch 전부 받기 · C-36 ⑦⑧). 이름을 바꾸면 C-4 에 걸릴 수 있다 — `ratio`·`tax`·`cash`·`pct`·`price`·`amount`·`pnl`·`commission`·`cagr` 가 든 이름(`aspectRatio`·`duration`·`iteration` 포함)을 쓰지 않는다.
- 차트에 더할 것이 생기면(예 선택 표시) 코드를 고치지 말고 질문 표에 적는다 — 층 표가 계약이다.

### 5. 미리보기 PNG (눈 확인용 · 골든 아님)

```
# packages/ui_analytics 에서 — 폴더는 저장소 밖 아무 곳
AAQ_CHART_PREVIEW_DIR=/tmp/chart_preview flutter test test/golden/chart_probe_test.dart --plain-name "preview png"
```

본보기 `PerfChart` 를 성과 픽스처 7개(정상 6건 · `performance24m` 은 2행) × light/dark 로 찍어 그 폴더에 둔다. 변수가 없으면 아무것도 하지 않는다.
🔴 `test/golden/goldens/` 를 가리키지 않는다.

## 🆕 R11(계약 v1.4) — `S7-4` · `S7-9` (2026-09-30 · ~~뼈대 — 카드 조립 때 채운다~~ → ✅ 카드 조립 반영 · 누적 드라이런 실측 R11a `a8d8c7f` · R11b `b896ebb` · ✅ R11a 병합 PR #19 `df42632` 2026-10-01 · ✅ R11b 병합 PR #21 `bce1a56` 2026-10-01 — R11 2장 완료)

정본: 01 §14 · 03 §9·§14 의 «🆕 계약 v1.4 — R11 범위» 블록(골든↔픽스처 표는 거기가 이긴다). 이 절은 **골든과 차트 증명**만 말한다.
카드는 나눠 간다: **R11a-Bob-S74**(플래너 · 폰 전용 · `package:ui_analytics/planner.dart`) → **R11b-Bob-S79**(목표 경로 + S7-1 진입 버튼 부록). S7-5(인출)는 **R11c · 인출 규칙 결정 뒤 첫 minor 로 보류**다 — 여기에 골든을 적지 않는다.

### 1. 골든 이름 (✅ 높이·입력 = 누적 드라이런 실측 · 2026-09-30 · 카드 «■ 골든» 절과 같은 말)

| 카드 | 이름 | 장수 | 테스트 파일 | 입력 픽스처 |
|---|---|---|---|---|
| R11a | `s74_step1_default` · `s74_step2_normal` · `s74_step3_normal` · `s74_pension_limit_hit` · `s74_expired` · `s74_funding` · `s74_blocked` | 7 × light/dark = **14** | `s74_golden_test.dart` | ✅ 03 §9 ⓗ 표(입력 픽스처 · 안전 상태 `safety_states` 행 · 설정 픽스처 짝까지 — 🔧 2026-09-30 검토 반영: `s74_blocked` = `m7_deposit_plan_blocked` 행0 + safety 행4 · `s74_funding` = safety 행3 · 나머지 행0 · 설정 = `m9/contribution_setting_default`) |
| R11b | `s79_on_track` · `s79_off_track` · `s79_hold` · `s79_realworld` | 4 × light/dark = **8** | `s79_golden_test.dart` | `m7M7GoalPathOn` · `m7M7GoalPathOff` · `m7M7GoalPathHold` · `m7M7GoalPathRealworld`(`m7/m7_goal_path_on·_off·_hold·_realworld.json`) · 띄운다(게이트 없음) · 값 표 접힌 채 · 안전 행 0 · 시계 `kGoldenNowUtc` · 크기 390 × **900**(상수 `kS79GoldenSize` · 844 는 off 847 로 모자람) |
| R11b 부록 | `s71_*` **재생성** 10(S7-1 진입 버튼 · 값 열 정렬) | 허용 10(드라이런 실제 M **6**) | `s71_golden_test.dart`(기존 · **무수정**) | 기존 그대로 · 위치 전제 없음 · 명령 = `flutter test --update-goldens test/golden/s71_golden_test.dart`(파일 하나) · 드라이런 실제 M 6 = normal · partial_gap · masked_recon × light/dark(버튼은 844 밖이라 PNG 에 없음 · masked_integrity · not_generated 불변) · 🔴 재생성은 `golden:approved` 라벨로만(Claude) |

- 🔴 `s74_viewer` 는 **없다**(폰 전용 · 뷰어 셸은 `planDeposit` 에 부재 안내 — 01 §14).
- 기존 PNG 불변 수: R11a 에게 **42장** · R11b 에게 **56장** 가운데 허용 목록 `s71_*` 10 을 뺀 **46장**. ✅ R11a 병합 뒤 `ui_analytics` 기존 PNG 는 **56장**(42 + `s74_*` 14). ✅ R11b 병합 뒤 `ui_analytics` PNG 는 **64장**(56 + `s79_*` 8 · `s71_*` 10 은 6장 재생성 — 장수 불변).
- 높이는 테스트 파일 안 상수 · 찍기 **전에** «맨 아래 위젯 dy < 높이»를 단언한다(R10 §2 와 같다).
- **R11a**(`s74_golden_test.dart` · 드라이런 `a8d8c7f`) — 가는 길: `s74_step1_default` = 띄우기만 · `s74_step2_normal`·`s74_pension_limit_hit`·`s74_blocked` = «미리보기 계산» · `s74_step3_normal`·`s74_expired`·`s74_funding` = 계산 → «다음». 맨 아래 Key: `s74_step1_default` = `s74-calculate` · `s74_blocked` = `s74-blocked-card` · 나머지 = `s74-back`. 높이(390 ×) = step1_default **844** · step2_normal **844** · step3_normal **1100** · pension_limit_hit **844** · expired **1100** · funding **1300** · blocked **844**. 찍는 모양 = `pumpForGolden(…, logicalSize: Size(390, <높이 상수>))` → 탭(`tapAndSettle`) → 🔴 찍기 전 `await tester.pumpAndSettle()`(버튼 물결) → 위치 전제 → `expectGolden`. 파일 모양 = 밝기 루프 하나 × 이름마다 `testWidgets` 1(7개). 설정은 전부 `m9ContributionSettingDefault` · 입력칸에 포커스를 주지 않는다(커서 깜빡임). 명령 = `flutter test --update-goldens test/golden/s74_golden_test.dart`(기존 골든 테스트 5파일을 넣지 않는다).
- **R11b**(`s79_golden_test.dart` · 드라이런 `b896ebb`) — 모양 = `s71_golden_test.dart` 처럼 (이름, 픽스처 경로) 목록 × `Brightness.values` 루프 · 위치 전제 **한 곳**. 명령 = `flutter test --update-goldens test/golden/s79_golden_test.dart`(부록 재생성은 부록 커밋에서 `s71_golden_test.dart` 하나만 따로).
  ```dart
  // s74_* — 맨 아래 Key 는 위 R11a 줄 · 높이는 이름마다 상수
  expect(tester.getBottomLeft(find.byKey(const Key('s74-back'))).dy, lessThan(1100));   // 예: s74_step3_normal
  // s79_* — 맨 아래 = 고지(판정 유보 hold 도 같다)
  expect(tester.getBottomLeft(find.byKey(const Key('s79-disclaimer'))).dy, lessThan(kS79GoldenSize.height));
  ```
- 드라이런 실측 dy(light=dark · 이름·밝기마다 `lessThan(0)` 임시 수정으로 잼 · 참고값 — 병합본 실측 줄은 C4 기록 커밋에서): `s74_*` step1_default **379** · step2_normal **759** · step3_normal **964** · pension_limit_hit **814** · expired **992** · funding **1175** · blocked **532**(배분 행 `Wrap` 반영 전 값 — step2_normal · pension_limit_hit 는 더 작아질 수 있다) · `s79-disclaimer` on_track **803** · off_track **847** · hold **562** · realworld **827**(900 과 2000 두 높이에서 같은 값).
- 병합본 실측(R11a · PR #19 `df42632` · 2026-10-01 · 1회차 `92999a8` 와 재제출 `fe85f36` 이 같은 값 — 재제출은 lib·골든 테스트·PNG 0 · C4 1·2회차 재실측 일치): 맨 아래 위젯 아래 끝 = step1_default **384**(`s74-calculate` < 844) · step2_normal **716**(< 844) · step3_normal **960**(< 1100) · pension_limit_hit **828**(< 844 · 여유 16 — 가장 작다) · expired **988**(< 1100) · funding **1181**(< 1300) · blocked **541**(`s74-blocked-card` < 844)(모두 light=dark). 드라이런(379·759·964·814·992·1175·532)과의 차이는 글자 크기·여백 재량이다(결함 아님 — Bob 은 제목·as-of·보조 줄을 본문 크기로 그렸다).
- CI 판정(R11a): PR #19 1회차 CI 에서 `s74_pension_limit_hit` light 가 리눅스 소음으로 유의 0.592%(창 5.2%)를 내 옛 보조 기준 0.5% 에 걸렸다 → 비교기 infra PR #20(`a0e1ae1`)의 «전체 ≤1.0% · 창 ≤12% · 전체 0.5% 초과면 창 ≤7%»(위 «하네스» 표 `flutter_test_config.dart` 행)로 통과 · R11b 의 새 `s79_*` 와 `s71_*` 재생성도 같은 판정을 받는다.
- 병합본 실측(R11b · PR #21 `bce1a56` · 2026-10-01 · 1회차 `a816264` 와 재제출 `daf90e1` 이 같은 값 — 재제출은 lib·골든 테스트·PNG 0 · C4 1·2회차 재실측 일치): `s79-disclaimer` 아래 끝 = on_track **784** · off_track **824**(여유 76 — 가장 작다) · hold **532** · realworld **804**(모두 light=dark · < 900). 드라이런(803·847·562·827)과의 차이는 글자 크기·여백 재량이다(결함 아님). off_track 이 844 안에 들어왔지만 높이 상수 `kS79GoldenSize` 390 × 900 은 카드 확정값이라 그대로 둔다(바꾸면 `s79_*` 8장 재생성).
- 부록 재생성 실측(R11b): `s71_*` M **6**(normal · partial_gap · masked_recon × light/dark) = 드라이런과 같다 · masked_integrity · not_generated 불변 · «목표 경로 보기» 버튼은 844 밖이라 어느 PNG 에도 없다(증명 = TA-2·TA-3) · `golden:approved` 라벨 뒤 CI 3/3(1회차 라벨 전 첫 실행의 «골든 스냅샷» 실패는 라벨 없는 기존 PNG 변경 때문 — 같은 판정식 · 재제출은 PNG 0 이라 라벨 그대로 초록).
- 기존 PNG 불변 실측: R11a 드라이런 42장 M 0(새 14) · ✅ R11a 병합본(PR #19) 42장 M 0(새 14 · 가지 56장) · R11b 드라이런 46장 불변(새 8 · `s71_*` M 6). · ✅ R11b 병합본(PR #21) 46장 M 0(새 8 · `s71_*` M 6 · 가지 64장).

### 2. 목표 경로 차트의 주 증명 — `expectGoalPathMatches`

S7-9 차트는 R10 차트와 **같은 층 표**를 쓴다: 띠 → 눈금선 → **계획선**(벤치마크 자리 · `tertiary` 점선 6·4 · 굵기 2) → **실제선**(본선 자리 · `primary` 실선 · 굵기 3 · 둥근 끝·이음). 결측(`yNormalized == null`)에서 실제선을 끊는다.

```dart
import 'chart_probe.dart';
import 'golden_support.dart';

final GoalPathVm path = singleFixture(FixturePaths.m7M7GoalPathRealworld, GoalPathVm.fromJson);
// … 화면을 띄운다(차트가 화면에 있어야 한다) …
final ColorScheme scheme = chartSchemeOf(tester, key: kGoalPathChartProbeKey);        // Key('s79-chart')
final ChartRecording recording = recordChart(tester, key: kGoalPathChartProbeKey);
expectGoalPathMatches(recording, path, scheme);
```

| 함수 | 통과 조건 |
|---|---|
| `expectGoalPathMatches(r, path, scheme)` | `actual` 에 본선 규칙(`expectMainLineMatches`) · `planned` 에 벤치마크 규칙(`expectBenchmarkMatches`) · `segments` 에 띠 규칙 · `yTicks` 에 눈금선 규칙을 건다. 층의 순서 = 띠 → 눈금선 → 계획선 → 실제선. 실패 메시지는 `goal path actual line …` · `goal path planned line …` · `goal path bands …` · `goal path ticks …` 로 시작한다. `chartUnavailableLabel != null` 인 경로로 부르면 실패한다 |

- 🔴 hold(`chartUnavailableLabel` 있음 · 골든 `s79_hold`)는 차트가 없다 — `find.byKey(kGoalPathChartProbeKey)` 가 0 임을 보고 `recordChart` 를 **부르지 않는다**.
- 🔴 기대 수(«실선 2개» 같은)를 손으로 적지 않는다 — 픽스처를 넘기면 하네스가 센다(realworld = 실제선 윤곽 2 · 띠 채움 1 · on/off = 실제선 윤곽 1 · 띠 0).
- 자체 검증: `goal_path_probe_test.dart`(16건) — 본보기는 on·off·realworld × light/dark · 크기 3가지 · 성과 픽스처의 띠(SegmentKind 4값)를 얹은 경로 · 실제로 띄운 `GoalPathChart` 에서 통과하고, hold 에서는 아무것도 그리지 않으며, 나쁜 painter 2종 — ① **보간**(실제선의 결측을 건너 이음) ② **층 바꿈**(실제선을 계획선 아래에 · 두 선의 붓을 서로 바꿈) — 은 실패한다.
- 🔴 `chart_probe.dart` · `goal_path_probe_test.dart` · `reference/goal_path/` 는 **고치면 반려**다. 맞지 않으면 질문 표에 적는다.

### 3. 본보기 옮기기

R10 절 §4 표의 🆕 v1.4 두 행대로 `reference/goal_path/` → `lib/src/goal_path/` 로 **diff 0** 복사한다. `GoalPathChart` 의 짜임은 `PerfChart` 와 같다 — 상자 220 → 위아래 12 → [ 눈금 글자 열 56 · 빈칸 8 · 그림 ] · 눈금 글자 Key `'s79-tick-$i'` · 그림 왼쪽 변 = `GoalPathChart.plotInsetLeft`(64).
🔵 M2 실측(2026-09-30): 두 파일을 `lib/src/goal_path/` 로 임시 복사해 `git diff --no-index --stat` 차이 0 · `flutter analyze lib` 0 · 계약 C-3·C-4·C-5·C-10·C-12·C-36·C-38·C-39 통과 · `check_labels.sh` 위반 없음 · `check_boundaries.sh` 실패 0 을 본 뒤 지웠다.

## 🆕 R12(계약 v1.6) — `S7-6a` · `S7-6b` · `S7-6c` · `S7-7` · `S7-10` (2026-10-08 조립 · 2026-10-12 기록 · 누적 드라이런 실측 R12a `7f72538` · R12b `a62f783` · R12c `78189b0` · R12d `2edba9a` · ✅ R12a 병합 PR #26 `708fde1` 2026-10-14)

정본: 01 §15-4(15-4-7 · 15-4-9 · 15-4-18) · 03 §11·§12·§14-b 의 «🆕 계약 v1.6 — R12 범위» 블록 · 설계 저장소 `10_리뷰/2026-10-08_R12선행_계약v1.6_설계서.md` §3-5(골든 ↔ 입력 — 22이름 × light/dark = **44 PNG**). 이 절은 **골든**만 말한다.
카드는 나눠 간다(순서 고정 · 앞 카드 병합 뒤 다음 카드): **R12a-Bob-S76ab**(`S7-6a`·`S7-6b`) → **R12b-Bob-S76c**(`S7-6c`) → **R12c-Bob-S77**(`S7-7`) → **R12d-Bob-S710**(`S7-10`). `S7-8` 은 R12 밖이다 — 여기에 골든을 적지 않는다.

### 1. 골든 이름 (✅ 높이·입력 = 누적 드라이런 실측 · 카드 «■ 골든» 절과 같은 말)

| 카드 | 이름 | 장수 | 테스트 파일 | 입력 · 크기 |
|---|---|---|---|---|
| R12a | `s76a_list` · `s76a_empty` · `s76a_sim` · `s76b_band` · `s76b_seasonal` · `s76b_advisory` | 6 × light/dark = **12** | `s76ab_golden_test.dart` | `s76a_list` = `rebalance_6.json`(6행 내림차순) · `s76a_empty` = `m7/m7_rebalance_empty.json` · `s76a_sim` = `m7/m7_rebalance_sim.json` · `s76b_band` = `m7/m7_rebalance_detail_band.json` · `s76b_seasonal` = `rebalance_6.json` 의 `re_20261030_01`(`rebalance6Event(kSeasonalEventId)`) · `s76b_advisory` = `m7/m7_rebalance_detail_advisory.json` · 스냅샷 접힌 채 · 안전 행 0 · 시계 `FixedClock(kGoldenNowUtc)` · 크기 390 × **960**(상수 `kS76abGoldenSize = Size(390, 960)` · 기본 폰 높이 844 로는 모자란다 · `kGoldenPhoneSize` 불변) |
| R12b | `s76c_countdown` · `s76c_none` · `s76c_preview` · `s76c_draft_empty` · `s76c_blocked` | 5 × light/dark = **10** | `s76c_golden_test.dart` | `s76c_countdown` = `m7/m7_next_rebalance_countdown.json`(탭 없음 · 버튼 있음) · `s76c_none` = `m7/m7_next_rebalance_none.json` · `s76c_preview` = countdown + 탭 → `m7/m7_rebalance_preview_default.json` · `s76c_draft_empty` = countdown + 탭 → `m7/m7_rebalance_preview_in_band.json` · `s76c_blocked` = countdown + 탭 → `m7/m7_rebalance_preview_blocked.json` 행 0 · 안전 행 0(`s76c_blocked` 만 `safety_states` 행 **4** = LEDGER_INTEGRITY) · 시계 `FixedClock(kGoldenNowUtc)` · 크기 390 × **844**(상수 `kS76cGoldenSize = Size(390, 844)`) |
| R12c | `s77_december` · `s77_first_year` · `s77_offwindow` · `s77_aftertax_ladder_spec` · `s77_aftertax_ladder_cf` | 5 × light/dark = **10** | `s77_golden_test.dart` | `s77_december` = `m7M7Annual2026` · `s77_first_year` = `m7M7AnnualFirstYear` · `s77_offwindow` = `m7M7AnnualOffwindow`(화면 전체 · 반사실 접힘) · `s77_aftertax_ladder_spec` = `m7M7Annual2026` 세후 블록 영역(반사실 접힘) · `s77_aftertax_ladder_cf` = `m7M7Annual2026` 세후 블록 영역(`s77-cf-toggle` 1회 탭 = 반사실 펼침) · 게이트 없음 · 안전 행 0 · 시계 `kGoldenNowUtc` · 크기 390 × **1440**(상수 `kS77GoldenSize = Size(390, 1440)` · 다섯 이름이 같은 상수) · 🔵 **영역 2이름** = `matchesGoldenFile` 를 `Key('s77-aftertax')` Finder 에 건다(ListView 직접 자식 RepaintBoundary) · `m7/aftertax_ladder_1` 은 읽지 않는다(C-30 전용) |
| R12d | `s710_cant` · `s710_wont` · `s710_mixed` · `s710_empty` · `s710_not_applicable` · `s710_masked_recon` | 6 × light/dark = **12** | `s710_golden_test.dart` | `m7/execution_gap_cant.json` · `_wont` · `_mixed`(제안 줄 부재) · `_empty`(문장 카드 하나) · `_not_applicable`(문장 카드 하나) · `_masked_recon`(배너 + «?» 글자 · 게이지 부재) · 모두 `const ExecutionGapScreen()`(`yyyyMm` 없이) · 안전 행 0(`s710_masked_recon` 만 `safety_states` 행 **3**) · 시계 `FixedClock(kGoldenNowUtc)` · 크기 390 × **844**(상수 `kS710GoldenSize = Size(390, 844)`) · `m7ExecutionGap1` 은 위젯 테스트 전용(골든 없음) |

- 🔴 **만들지 않는 골든**(01 §8 미결 87): 입력 없는 골든 `s76b_missing_snapshot`(실을 필드가 없다) · `S7-6c` 차단 행 1(재개 미완 차단 + 버튼 표본 — `safety_states` 에 RESUME_INCOMPLETE 행이 없어 «재개 미완 차단 + 플래그 0» 이 굳는다 · 위젯 테스트 T76c-07·15·18 전용).
- 기존 PNG 불변 수(카드가 받는 장수 · 전부 M 0): R12a 에게 **64장** → R12b 에게 **76장**(64 + `s76a_*`·`s76b_*` 12) → R12c 에게 **86장**(+ `s76c_*` 10) → R12d 에게 **96장**(+ `s77_*` 10) · R12d 병합 뒤 108장. 재생성 허용 목록 = 없음(R12 네 장 모두 `--update-goldens` 는 그 카드의 골든 테스트 파일 하나만). ✅ R12a 병합 뒤 `ui_analytics` PNG 는 **76장**(64 + `s76a_*`·`s76b_*` 12 · 기존 64 M 0).
- 높이는 테스트 파일 안 상수 · 찍기 **전에** «맨 아래 위젯 dy < 높이»를 단언한다(R10 §2 와 같다). 모양 = `s79_golden_test.dart` 처럼 (이름, 입력) 목록 × `Brightness.values` 루프 · 테스트 이름 `'$name ${brightnessSuffix(b)}'`.
- 맨 아래 위젯(위치 전제):
  - R12a — `S7-6a` = 하단 기준일 `find.text(page.asOf.label)` · `S7-6b` = `Key('s76b-asof')`.
  - R12b — `s76c_countdown` = `Key('s76c-preview-button')` · `s76c_none` = `Key('s76c-asof')` · `s76c_preview`·`s76c_draft_empty` = `Key('s76c-draft-asof')` · `s76c_blocked` = `Key('s76c-blocked')`.
  - R12c — 화면 전체 3이름 = `Key('s77-asof')` · 영역 2이름 = `Key('s77-aftertax')`.
  - R12d — 여섯 이름 모두 `Key('s710-asof')`(빈 갈래도 같다).
  ```dart
  expect(tester.getBottomLeft(find.text(page.asOf.label)).dy, lessThan(kS76abGoldenSize.height));               // S7-6a
  expect(tester.getBottomLeft(find.byKey(const Key('s76b-asof'))).dy, lessThan(kS76abGoldenSize.height));     // S7-6b
  expect(tester.getBottomLeft(find.byKey(Key(bottomKey))).dy, lessThan(kS76cGoldenSize.height));              // S7-6c — 위 표의 Key
  expect(tester.getBottomLeft(find.byKey(const Key('s77-asof'))).dy, lessThan(kS77GoldenSize.height));        // S7-7 화면 전체
  expect(tester.getBottomLeft(find.byKey(const Key('s77-aftertax'))).dy, lessThan(kS77GoldenSize.height));    // S7-7 영역
  await expectLater(find.byKey(const Key('s77-aftertax')), matchesGoldenFile('goldens/s77_aftertax_ladder_spec_${brightnessSuffix(b)}.png'));
  expect(tester.getBottomLeft(find.byKey(const Key('s710-asof'))).dy, lessThan(kS710GoldenSize.height));      // S7-10
  ```
- 드라이런 실측 dy(light=dark · 이름·밝기마다 `lessThan(0)` 임시 수정으로 잼 · 참고값 — 병합본 실측 줄은 C4 기록 커밋에서): `s76a_list` **848** · `s76a_empty` **120** · `s76a_sim` **324** · `s76b_band` **892** · `s76b_seasonal` **692** · `s76b_advisory` **892**(< 960) · `s76c_countdown` **224** · `s76c_none` **64** · `s76c_preview` **752** · `s76c_draft_empty` **596** · `s76c_blocked` **377**(< 844) · `s77_december` **1320** · `s77_first_year` **1252** · `s77_offwindow` **1340** · `s77_aftertax_ladder_spec` **812** · `s77_aftertax_ladder_cf` **1400**(< 1440 · 영역 PNG = spec 358×724 · cf 358×1312) · `s710_cant` **609** · `s710_wont` **623** · `s710_mixed` **685** · `s710_empty` **112** · `s710_not_applicable` **152** · `s710_masked_recon` **574**(< 844).
- 🆕 병합본 실측(R12a · PR #26 `708fde1` · 2026-10-14 · Bob `34dab77` · 2회차·3회차 커밋 0 — 1회차 `34dab77` 그대로 · C4 재실측 두 번 일치 · light=dark): `s76a_list` **848** · `s76a_empty` **112** · `s76a_sim` **324** · `s76b_band` **884** · `s76b_seasonal` **692** · `s76b_advisory` **884**(< 960). 드라이런과의 차(empty 120 → 112 · band·advisory 892 → 884)는 버튼 앞 `SizedBox(height: 8)` 유무 = 간격 재량(결함 아님). `s76b_advisory_*` PNG 는 `s76b_band_*` 와 바이트가 같다(거울 픽스처 · 버튼 글자 수 같음 · 테스트 글꼴 네모 — 설계대로 · 드라이런도 같음). 기존 64장 M 0 · 새 12 → **76장**.
- 명령(packages/ui_analytics 에서 · 카드마다 그 파일 하나): `flutter test --update-goldens test/golden/s76ab_golden_test.dart` · `… s76c_golden_test.dart` · `… s77_golden_test.dart` · `… s710_golden_test.dart` → 옵션 없이 `flutter test` 전부 통과 · 🔴 다른 골든 테스트 파일·폴더를 넣지 않는다.
