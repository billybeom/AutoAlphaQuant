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
   `s71_not_generated` = `m7/m7_monthly_pending.json`(`empty_kind: NOT_LOADED` · 봉투 형제 키 `pending_d_day_text` 는 `jsonDecode(fixtureText(...))['pending_d_day_text']` 로 읽는다(`dart:convert`) — 값을 화면이 만들지 않는다) ·
   헤더 신뢰 등급 = `m7/ledger_trust_4.json`(4행 `LedgerTrustBadge` — 골든에는 0행 `RECONCILED` 사용).
2. 최초 베이스라인 **한 번만**: 패키지 루트(`packages/ui_analytics`)에서
   ```
   flutter test --update-goldens test/golden
   ```
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
  // 미생성: 봉투는 NOT_LOADED — 화면이 그리는 것은 asOf.staleLabel / pending_d_day_text 등 봉투 값이다.
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
