# `test/golden/` — 위젯 골든 스냅샷 (C-2 · 하네스 ✅ 2026-09-17 · PNG ⬜ S7-1 PR 대기)

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
3. 그 뒤로는 `flutter test` 가 **비교만** 한다. 실패하면 `test/golden/failures/` 의 diff 를 본다 — 픽스처가 그대로인데 다시 찍으면 위조다.
4. PR 에는 테스트 파일 + PNG 6장을 **추가(A)** 로 넣는다.

### 뼈대 — `s71_golden_test.dart` (화면 담당이 채운다)

```dart
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden_support.dart';

// 픽스처를 그대로 돌려주는 최소 구현체(테스트 전용). 값을 만들지 않는다.
// PerformanceRepository 의 다른 메서드는 UnimplementedError 로 둔다(S7-1 은 monthlyReport 만 쓴다).
class _FakePerformanceRepository implements PerformanceRepository { /* monthlyReport(yyyyMm) => Future.value(report) … */ }
class _FakeLedgerTrustRepository implements LedgerTrustRepository { /* watchGrade() => Stream.value(badge) … */ }

void main() {
  final MonthlyReport normal = singleFixture(FixturePaths.m7M7Monthly202608, MonthlyReport.fromJson);
  final MonthlyReport gap = singleFixture(FixturePaths.m7M7MonthlyGap, MonthlyReport.fromJson);
  // 미생성: 봉투는 NOT_LOADED — 화면이 그리는 것은 13항목 valueText 와 (v1.1) report.pendingNoticeText 다.
  final FixtureEnvelope pending = fixtureEnvelope(FixturePaths.m7M7MonthlyPending);
  final LedgerTrustBadge trust = listFixture(FixturePaths.m7LedgerTrust4, LedgerTrustBadge.fromJson).rows.first;

  for (final Brightness b in Brightness.values) {
    testWidgets('s71_normal ${brightnessSuffix(b)}', (WidgetTester tester) async {
      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: <Override>[
            // 화면 패키지가 공개한 Provider 들을 override (01 §4-1 주입 규약)
            // performanceRepositoryProvider.overrideWithValue(_FakePerformanceRepository(normal)),
            // ledgerTrustRepositoryProvider.overrideWithValue(_FakeLedgerTrustRepository(trust)),
            // monthlyReportClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          ],
          child: const MonthlyReportView(/* yyyyMm: '2026-08' */),
        ),
        brightness: b,
      );
      await expectGolden('s71_normal', b);
    });
    // s71_partial_gap · s71_not_generated 도 같은 모양
  }
}
```

- 🔴 `DateTime.now()` 를 테스트에서도 부르지 않는다 — 시계는 `FixedClock(kGoldenNowUtc)`.
- 🔴 테스트 파일에도 한국어 문자열 리터럴을 두지 않는다 — 글자는 전부 픽스처에서 온다.
- 🔴 픽스처를 복사·편집해 «내 픽스처»를 만들지 않는다. 상태 조합이 더 필요하면 `docs/ai-context/inbox/S7-1_questions.md` 에 발주한다.
- 🔴 위 뼈대의 Provider·위젯 이름은 **예시**다 — 실제 이름은 화면 담당이 정하되 `Provider<XRepository>((_) => throw UnimplementedError('...'))` 규약(01 §4-1)을 따른다.

## R2 — `S7-3` · `S7-3b` (2026-09-17)

골든 이름(명세 지정) — `s73_normal` · `s73_deep_dd` · `s73b_three_sleeves` × light/dark = 6장. 테스트 파일 `test/golden/s73_golden_test.dart`.
(`s73_insufficient`·`s73b_partial` 은 01 §8 미결 44·45 가 닫힌 뒤 — 입력 픽스처가 아직 없다.)

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
