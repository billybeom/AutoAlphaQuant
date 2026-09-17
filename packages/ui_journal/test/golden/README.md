# `test/golden/` — 위젯 골든 스냅샷 (C-2 · 하네스 ✅ 2026-09-17 · PNG ⬜ 첫 화면 PR 대기)

정본: 01_M2_도메인계약 **§7**(C-1·C-2 + 골든 규칙) · 07_AI어시스턴트_배포프롬프트 **§9** 기계 검사 4

## 🔴 «최초 생성»과 «재생성»은 다르다

이 구별이 없으면 신규 화면의 첫 PR은 통과할 방법이 없다.

| 구분 | 누가 | 규칙 |
|---|---|---|
| **뷰모델 골든** `*.golden.json`(C-1) | 🔴 M2(Claude) 소유 | 화면 담당은 **읽기만**. 깨지면 표시 계약이 바뀐 것이므로 **고치지 말고 질문 목록에 올린다** |
| **위젯 골든 PNG**(C-2) | 화면 담당 | **신규 화면의 최초 베이스라인은 그 화면을 만드는 PR에서 함께 커밋한다** — 그 PR에서만 «추가»가 허용된다. 이후 **픽스처가 그대로인데 스냅샷을 다시 찍는 것은 위조**이며 반려 |

병합 검사는 `git diff --name-status`로 **A(추가)**와 **M(수정)**을 구별한다. 기존 위젯 골든의 수정과 `*.golden.json`의 어떤 변경이든 «무엇이 왜 바뀌었는가»를 되묻는다.

## 규칙

- 렌더 입력은 `packages/domain_contracts/fixtures/`의 픽스처다. **화면 담당은 픽스처를 수정하지 않는다** — 「테스트가 안 맞아서」 픽스처를 고치는 것은 반려 사유다.
- light / dark 두 벌을 찍는다.
- 플랫폼·폰트 차이로 스냅샷이 흔들리면 **임계 조정은 M2가 한다**. 스스로 임계를 풀지 않는다.
- 대표 화면 9개가 C-2의 대상이다(01 §7). 어느 9개인지는 화면 명세 확정과 함께 정한다.

## 하네스 (M2 제공 · 2026-09-17 · C4 R1-Bob-J1 질문 Q1 의 답 · 비교기 2판 = 이동·AA 허용)

화면 담당이 만드는 것은 **골든 테스트 파일과 PNG** 뿐이다. 나머지는 이미 있다.

| 파일 | 누가 | 무엇 |
|---|---|---|
| `test/flutter_test_config.dart` | 🔴 M2 | `flutter test` 가 자동으로 먼저 부른다. 골든 비교기를 **이동·AA 허용 비교기(3판)** 로 바꾼다 — 두 그림을 3×3 으로 살짝 흐린 뒤 **양방향**으로 «이웃 3×3 어디에도 비슷한 색이 없는 유의 픽셀»을 세고, **가장 빽빽한 24×24 창의 밀도 12% 이하(주 판정) 그리고 전체 0.5% 이하(보조)** 면 통과(`golden/shift_tolerant_compare.dart` · 자체 검증 `golden/comparator_test.dart` 11건). 🔵 2026-09-17 실측(리눅스 CI vs Windows 골든 14장): 플랫폼 소음은 전체 ≤0.18%·창 ≤5.6% 로 **얇게 흩어지고**, 구조 변화는 18px 아이콘 1개 누락도 창 27% 로 **뭉친다**(칩 47% · 글자 줄 83% · 배너 96%). 화면 담당은 고치지 않는다 |
| `test/golden/golden_support.dart` | 🔴 M2 | 픽스처 로더(`journalFixture`·`journalSlice`·`safetyFixtureRow`) · 고정 시계 `FixedClock`·`kGoldenNowUtc` · 폰 크기 `kGoldenPhoneSize`(390×844) · `pumpForGolden`(light/dark 테마) · `expectGolden(name, brightness)` |
| `test/golden/<화면id>_golden_test.dart` | 화면 담당 | 아래 예시대로. 파일명은 `j1_golden_test.dart` 처럼 화면 ID 소문자 |
| `test/golden/goldens/<name>_<light\|dark>.png` | 화면 담당(최초 1회) | `expectGolden` 이 만드는 경로. `.gitignore` 의 `!**/test/golden/**` 로 **커밋 대상**이다 |

### 만드는 순서 (J-1 예)

1. `test/golden/j1_golden_test.dart` 를 아래 뼈대로 쓴다. 상태 슬라이스 4종의 **입력은 전부 픽스처**다 —
   `normal` = `journal_30.json` 전량 + `safety_states.json` 0행(NORMAL) ·
   `blocked` = 전량 + 3행(HALTED · `RECON_MISMATCH`+`JOURNAL_MISSING`) ·
   `empty` = `m6/journal_empty.json` + 0행 ·
   `prevented` = `journal_30.json` 에서 `status == prevented` 행만 + 0행.
2. 최초 베이스라인 **한 번만**: 패키지 루트(`packages/ui_journal`)에서
   ```
   flutter test --update-goldens test/golden
   ```
   → `test/golden/goldens/j1_normal_light.png` … 8장이 생긴다. 열어서 눈으로 확인한다.
3. 그 뒤로는 `flutter test`(또는 `melos.bat run test`)가 **비교만** 한다. 실패하면 `test/golden/failures/` 에 diff 이미지가 남는다 — 스냅샷을 다시 찍기 전에 **무엇이 바뀌었는지** 본다. 픽스처가 그대로인데 다시 찍으면 위조다.
4. PR 에는 테스트 파일 + PNG 8장을 **추가(A)** 로 넣는다. CI 골든 잡은 «추가만 있음»을 통과시킨다.

### 뼈대 — `j1_golden_test.dart` (화면 담당이 채운다)

```dart
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

// 픽스처를 그대로 흘려 주는 최소 구현체(테스트 전용). 값을 만들지 않는다.
class _FakeJournalRepository implements JournalRepository { /* Stream.value(result) … */ }
class _FakeSafetyRepository implements SafetyRepository { /* Stream.value(state) … */ }

void main() {
  final ListResult<TradeJournalEntry> all = journalFixture(FixturePaths.journal30);
  final ListResult<TradeJournalEntry> empty = journalFixture(FixturePaths.m6JournalEmpty);
  final ListResult<TradeJournalEntry> prevented = journalSlice(
    all,
    (TradeJournalEntry e) => e.status == JournalStatus.prevented,
  );
  final SafetyState normal = safetyFixtureRow(0);
  final SafetyState blocked = safetyFixtureRow(3);
  final DateRange range = DateRange(
    from: TradeDate('2026-08-01'),
    to: TradeDate('2026-08-31'),
    presetCode: 'FIXTURE',
  );

  // 이름 → (목록, 안전 상태)
  final Map<String, (ListResult<TradeJournalEntry>, SafetyState)> cases = {
    'j1_normal': (all, normal),
    'j1_blocked': (all, blocked),
    'j1_empty': (empty, normal),
    'j1_prevented': (prevented, normal),
  };

  for (final Brightness b in Brightness.values) {
    for (final MapEntry<String, (ListResult<TradeJournalEntry>, SafetyState)> c in cases.entries) {
      testWidgets('${c.key} ${brightnessSuffix(b)}', (WidgetTester tester) async {
        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: <Override>[
              journalTimelineRepositoryProvider.overrideWithValue(_FakeJournalRepository(c.value.$1)),
              journalSafetyRepositoryProvider.overrideWithValue(_FakeSafetyRepository(c.value.$2)),
              journalTimelineQueryProvider.overrideWithValue(JournalTimelineQuery(range: range)),
              journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
            ],
            child: const JournalTimeline(),
          ),
          brightness: b,
        );
        await expectGolden(c.key, b);
      });
    }
  }
}
```

- 🔴 `DateTime.now()` 를 테스트에서도 부르지 않는다 — 시계는 `FixedClock(kGoldenNowUtc)` 로 주입한다.
- 🔴 테스트 파일에도 한국어 문자열 리터럴을 두지 않는다 — 화면에 보이는 글자는 전부 픽스처에서 온다(`range.label` 도 비워 둔다).
- 🔴 `journal_30.json` 을 복사·편집해 «내 픽스처»를 만들지 않는다. 상태 조합이 더 필요하면 질문 목록(`docs/ai-context/inbox/<화면ID>_questions.md`)에 발주한다.
