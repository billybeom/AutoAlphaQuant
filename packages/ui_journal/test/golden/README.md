# `test/golden/` — 위젯 골든 스냅샷 (C-2 · 하네스 ✅ 2026-09-17 · PNG ✅ `J-1` 16장(R1b 병합 PR #7) · 🆕 `J-2`·`J-3`·`J-5` 는 R2 PR 에서 최초 생성 · ✅ R3 병합 뒤 **72장**(56 + `j4_*` 12 · `j1_rebalance_*` 4 · 부록 S-1 6장 = M · PR #41 `be1b46f`) · ✅ R4a 병합 뒤 **82장**(72 + `h61_*` 10 · PR #57 `faeb458`))

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
- 플랫폼·폰트 차이로 스냅샷이 흔들리면 **임계 조정은 M2가 한다**. 스스로 임계를 풀지 않는다. 조정 기록: 비교기 3판 = infra PR #3(2026-09-17) · 보조 기준 0.5% → **1.0%** + **P2**(0.5% 초과는 창 7% 이하만 통과) = 2026-10-01(R11a PR #19 리눅스 CI 실측 + 적대 검토 · 아래 표).
- 대표 화면 9개가 C-2의 대상이다(01 §7). 어느 9개인지는 화면 명세 확정과 함께 정한다.

## 하네스 (M2 제공 · 2026-09-17 · C4 R1-Bob-J1 질문 Q1 의 답 · 비교기 3판 = 이동·AA 허용 · infra PR #3)

화면 담당이 만드는 것은 **골든 테스트 파일과 PNG** 뿐이다. 나머지는 이미 있다.

| 파일 | 누가 | 무엇 |
|---|---|---|
| `test/flutter_test_config.dart` | 🔴 M2 | `flutter test` 가 자동으로 먼저 부른다. 골든 비교기를 **이동·AA 허용 비교기(3판)** 로 바꾼다 — 두 그림을 3×3 으로 살짝 흐린 뒤 **양방향**으로 «이웃 3×3 어디에도 비슷한 색이 없는 유의 픽셀»을 세고, **가장 빽빽한 24×24 창의 밀도 12% 이하(주 판정) 그리고 전체 1.0% 이하(보조) 그리고 전체가 0.5% 를 넘으면 창 7% 이하(P2)** 면 통과(`golden/shift_tolerant_compare.dart` · 판정 함수 `acceptsSignificantDiff` · 자체 검증 `golden/comparator_test.dart` 32건 — 폰 크기 판정 9건 + P2 5건 + 창 12% 양쪽 4건 + 비교기 연결 3건(실제 PNG 로 `compare` 직접 호출) 포함). 🔵 2026-09-17 실측(리눅스 CI vs Windows 골든 14장): 플랫폼 소음은 전체 ≤0.18%·창 ≤5.6% 로 **얇게 흩어지고**, 구조 변화는 18px 아이콘 1개 누락도 창 27% 로 **뭉친다**(칩 47% · 글자 줄 83% · 배너 96%). 🔵 **2026-10-01 보조 기준 0.5% → 1.0%**(R11a PR #19 리눅스 CI 실측 112장 = ui_analytics 56 + ui_journal 56): 글자가 빽빽한 S7-4 화면의 흩어진 소음이 전체 0.592%(`s74_pension_limit_hit` light · 창 5.2%)로 옛 보조 기준**만** 넘었다. 112장의 창 밀도는 모두 ≤5.2% 라 주 기준 12% 는 그대로다. 새 값은 소음 최대 0.592% 의 1.69배이고, 전체 비율로도 잡히던 구조 변화(칩 1.4% · 글자 줄 3.4% · 배너 15.8%)는 여전히 1.0% 위다(아이콘 누락 0.06% 는 처음부터 창 기준 몫). 🔵 **같은 날 P2**(적대 검토): 보조 기준만 올리면 «1px 선 → 3px»(테두리·차트 격자 전부 굵어짐 — S7-2 6장 전체 0.606~0.607% · 창 51/576 8.9%)를 옛 판정은 잡고 새 판정은 놓친다. 전체 비율로는 소음(0.592%)과 겹쳐 못 가르고 창이 가른다(소음 ≤5.2% vs 8.9%) → **전체 0.5% 초과는 창 7%(≈40/576) 이하일 때만 통과** (`kGoldenStrictDiffTolerance` 0.005 · `kGoldenThinWindowDensity` 0.07). PR #19 CI 112장은 모두 통과(0.5% 를 넘는 장은 1장 · 창 5.2%) · 검토가 찾은 «옛 판정만 잡던» 7건은 모두 실패. 화면 담당은 고치지 않는다 |
| `test/golden/golden_support.dart` | 🔴 M2 | 픽스처 로더(`journalFixture`·`journalSlice`·`safetyFixtureRow` · v1.1 `listFixture`·`singleFixture`·`fixtureEnvelope`) · 고정 시계 `FixedClock`·`kGoldenNowUtc` · 폰 크기 `kGoldenPhoneSize`(390×844) · `pumpForGolden`(light/dark 테마 · 선택 인자 `logicalSize:`·`wrapApp:`) · `expectGolden(name, brightness)` |
| `test/golden/<화면id>_golden_test.dart` | 화면 담당 | 아래 예시대로. 파일명은 `j1_golden_test.dart` 처럼 화면 ID 소문자 |
| `test/golden/goldens/<name>_<light\|dark>.png` | 화면 담당(최초 1회) | `expectGolden` 이 만드는 경로. `.gitignore` 의 `!**/test/golden/**` 로 **커밋 대상**이다 |

### 만드는 순서 (J-1 예)

1. `test/golden/j1_golden_test.dart` 를 아래 뼈대로 쓴다. 상태 슬라이스 4종의 **입력은 전부 픽스처**다 —
   `normal` = `journal_30.json` 전량 + `safety_states.json` 0행(NORMAL) ·
   `blocked` = 전량 + 3행(HALTED · `RECON_MISMATCH`+`JOURNAL_MISSING`) ·
   `empty` = `m6/journal_empty.json` + 0행 ·
   `prevented` = `journal_30.json` 에서 `status == prevented` 행만 + 0행.
2. 최초 베이스라인 **한 번만**: 패키지 루트(`packages/ui_journal`)에서 **새 테스트 파일을 지정해**
   ```
   flutter test --update-goldens test/golden/j1_golden_test.dart
   ```
   → `test/golden/goldens/j1_normal_light.png` … 이 생긴다. 열어서 눈으로 확인한다.
   🔴 ~~`flutter test --update-goldens test/golden`~~(폴더 지정) **금지** — 폴더를 주면 이미 있는 다른 화면의 PNG 까지
   다시 찍힌다(= 기존 골든 재생성 = 위조 · CI 골든 잡이 `M` 으로 막는다). 아래 «🆕 R2» 절 참조.
3. 그 뒤로는 `flutter test`(또는 `melos.bat run test`)가 **비교만** 한다. 실패하면 `test/golden/failures/` 에 diff 이미지가 남는다 — 스냅샷을 다시 찍기 전에 **무엇이 바뀌었는지** 본다. 픽스처가 그대로인데 다시 찍으면 위조다.
4. PR 에는 테스트 파일 + 새 PNG(이름마다 light/dark 두 장)를 **추가(A)** 로 넣는다. CI 골든 잡은 «추가만 있음»을 통과시킨다.

### 뼈대 — `j1_golden_test.dart` (화면 담당이 채운다)

> 🔵 이 뼈대는 R1(2026-09-17) 시점의 모양이다. 실물은 병합된 `j1_golden_test.dart`(R1b) 이고, 새 화면 테스트는
> 아래 «🆕 계약 v1.1» 절(가짜는 받침대를 `extends`)과 «🆕 R2» 절을 따른다 — 뼈대의 가짜 두 줄도 그 규칙대로 적었다.

```dart
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

// 픽스처를 그대로 흘려 주는 최소 구현체(테스트 전용). 값을 만들지 않는다.
class _FakeJournalRepository extends UnimplementedJournalRepository { /* @override watchTimeline(…) => Stream.value(result) */ }
class _FakeSafetyRepository extends UnimplementedSafetyRepository { /* @override watchState() => Stream.value(state) */ }

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

## 🆕 계약 v1.1(2026-09-17) — 테스트에서 달라지는 것 3가지

1. **가짜 리포지토리는 받침대를 상속한다** — `import 'package:domain_contracts/testing.dart';` 한 뒤
   `class _FakeX extends UnimplementedXRepository { @override …필요한 메서드만… }`.
   `implements XRepository` 로 통째 구현하면 M2 가 창구를 하나 더할 때마다 테스트가 컴파일에서 깨진다
   (v1.1 에서 실제로 일어났다). 받침대: `UnimplementedJournalRepository` · `UnimplementedPerformanceRepository` ·
   `UnimplementedConfigRepository` · 🆕 `UnimplementedSafetyRepository` · `UnimplementedCommandApi`(2026-09-23 · R2 준비 —
   `CommandApi` 13종 전부 · override 하지 않은 명령을 부르면 곧바로 던진다 — 탭·제출 핸들러에서 부른 것은 테스트가 실패하고,
   프로바이더 안에서 부른 것은 에러 상태로 삼켜질 수 있으니 «에러 상태 없음(정상 본문이 보임)»을 함께 확인한다).
   없는 것이 필요하면 **질문 표에 적는다**(M2 가 더한다). 🔵 이미 병합된 J-1 테스트의 `implements SafetyRepository` 는 그대로 둔다.
2. **링크는 기록기로 확인한다** — 화면은 DTO 가 준 링크를 `AppLinkOpener.open(link)` 에 **그대로** 넘긴다(01 §4-4).
   테스트는 `RecordingLinkOpener`(같은 `testing.dart`)를 주입하고
   `expect(opener.opened, <String>[entry.detailDeepLink!])` 처럼 **픽스처에서 읽은 값**과 비교한다.
   🔴 테스트에도 `'aaq://…'` 리터럴을 적지 않는다 — 링크가 null 인 픽스처 행에서는 「버튼이 없다」를 확인한다.
3. **값은 `*Text` 만 그린다** — 일지 행은 `sideLabel`·`quantityText`·`priceText`·`commissionText`·`taxText`,
   가림도 그 문자열 안에 이미 들어 있다(`m6/journal_masked_integrity.json` · `m7/m7_monthly_masked_*.json`).
   화면이 차단 플래그를 보고 값을 감추거나 바꾸는 코드는 v1.1 부터 **반려**다(배너만 얹는다).

### `J-1` R1b · `J-2` · `J-3` · `J-5` 의 입력 픽스처(v1.1 · 🆕 R2 준비 2026-09-23)

| 화면·상태 | 픽스처(`FixturePaths.*`) | 타입 |
|---|---|---|
| `J-1` 필터 선택지 | `m6JournalFilterCatalog` + 코어 `rangePresets4`·`sleeveCatalog4` | `JournalFilterCatalog` · `DateRange` · `SleeveCatalogEntry` |
| `J-1` 상단 배지 | `m6JournalBadges2` | `JournalTimelineBadge` |
| `J-1` 무결성 가림 | `m6JournalMaskedIntegrity` + `safetyStates` 4행 | `TradeJournalEntry` |
| `J-2` 6갈래 | `m6DecisionDetailFull`·`Partial`·`RejectedSaf309`·`Unknown`·`ReevaluatedChild`·`Amended` | `DecisionDetailVm` |
| `J-3` 2갈래 | `m6JournalDraftSpecDiscretion`·`m6JournalDraftSpecReconClear` | `JournalDraftFormSpec` |
| 🆕 `J-3` 제출 결과 5상태 | `m6JournalDraftReceipts5` — `REQUESTED`·`EXECUTED`·`REJECTED`·`EXPIRED`·`HELD_FOR_INTEGRITY`. 한 명령(같은 `command_id`)의 갈래라 `state` 로 골라 쓴다. 🔴 문구(거부 사유 포함)는 `stateLabel` 하나 — `rejectReasonCode` 는 표시·분기하지 않는다 | `CommandReceipt` |
| `J-5` 2갈래 | `m6UnknownBoard2`·`m6UnknownBoardEmpty` | `UnknownBoardVm` |
| `J-2`·`J-3`·`J-5` 안전 상태 | `safetyStates` 0행(NORMAL · 골든 기본) · 3행(HALTED · 차단 배너 — 위젯 테스트로 증명) | `SafetyState` |

읽는 법(v1.1 에서 `golden_support.dart` 에 추가된 범용 도우미 — ui_analytics 와 같은 이름):
`singleFixture(FixturePaths.m6DecisionDetailFull, DecisionDetailVm.fromJson)`(1행 픽스처) ·
`listFixture(FixturePaths.m6JournalBadges2, JournalTimelineBadge.fromJson).rows`(목록) ·
`fixtureEnvelope(path)`(봉투 원형). 기존 `journalFixture`·`journalSlice`·`safetyFixtureRow` 는 그대로다.

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

## 🆕 R2 — 새 화면 베이스라인을 찍는 규칙 (2026-09-23 · `J-2`·`J-3`·`J-5`)

1. **베이스라인은 새 테스트 파일만 지정해서 찍는다** — 폴더를 주지 않는다. 패키지 루트(`packages/ui_journal`)에서:
   ```
   flutter test --update-goldens test/golden/j2_golden_test.dart test/golden/j3_golden_test.dart test/golden/j5_golden_test.dart
   ```
   🔴 ~~`flutter test --update-goldens test/golden`~~ 은 `j1_*` 16장까지 다시 찍는다 = **기존 골든 재생성 = 위조**(CI 골든 잡이 `M` 으로 막는다).
   찍은 뒤 `git status` 에서 `goldens/` 의 **새 PNG 만 `??`(추적 안 됨 · 커밋 뒤 PR 에서는 `A`)** 인지 본다. `j1_*` 에 `M` 이 보이면 커밋하지 않는다.
2. **세로가 긴 화면**(`J-2` 체인·표·체결 행 · `J-3` 폼 · `J-5` 카드 2장)은 한 화면(390×844)에 다 들어가지 않는다 →
   **테스트 파일 안** 상수로 높이만 늘려 `logicalSize:` 로 넘긴다. 폭 390 은 그대로 둔다(넘침 검사가 골든의 목적이다).
   ```dart
   const Size _kTallPhone = Size(390, 1600);   // 테스트 파일 안 — 하네스(golden_support.dart)에 상수를 더하지 않는다
   await pumpForGolden(tester, child, brightness: b, logicalSize: _kTallPhone, wrapApp: …);
   ```
   🔴 `kGoldenPhoneSize` 는 M2 만 바꾼다(바꾸면 전 골든이 깨진다). 1600 으로 모자라면 값을 올리고 그 사실을 질문 파일에 적는다.
3. **`J-3` 제출 결과는 접수증 픽스처에서 고른다** — 테스트가 `CommandReceipt(...)`·한국어 `stateLabel` 을 짓지 않는다.
   ```dart
   final List<CommandReceipt> receipts =
       listFixture(FixturePaths.m6JournalDraftReceipts5, CommandReceipt.fromJson).rows;
   CommandReceipt receiptIn(CommandState s) =>
       receipts.firstWhere((CommandReceipt r) => r.state == s);

   class _FakeCommandApi extends UnimplementedCommandApi {   // 나머지 11종은 부르면 던진다
     @override
     Future<CommandReceipt> submitJournalDraft(JournalDraft draft) async => …;   // 예: receiptIn(CommandState.requested)
     @override
     Stream<CommandReceipt> watchCommand(String commandId) => …;                // 예: Stream.value(receiptIn(CommandState.rejected))
   }
   ```
   🔴 제출은 **UI 를 실제로 조작해서** 한다(입력 → 인용 규칙 선택 → 제출 버튼 탭). 가짜가 받은 `JournalDraft` 를 기록해 입력값과 대조한다.
4. **시계·안전 상태** — `FixedClock(kGoldenNowUtc)` · `safetyFixtureRow(0)`(NORMAL). `J-2`·`J-3`·`J-5` 픽스처 10건과 접수증 픽스처는 전부 그 시각에 신선하다(VM **최상위** `asOf` 기준 — `J-2` 의 `entry.asOf` 는 체결 당시라 이미 오래됐다 · 머리·신선도에 쓰지 않는다).
   «오래된 데이터» 배너는 골든이 아니라 위젯 테스트에서 `FixedClock(kGoldenNowUtc.add(const Duration(days: 2)))` 로 켠다(테스트 파일 안 로컬 값).

## 🆕 R2b(계약 v1.2 · 2026-09-25) — 초안 복원·접수 실패·읽기 뷰 골든

계약 v1.2(01 §12)가 `J-3` 에 기기 로컬 초안 포트 `DraftStore` 와 읽기 창구 `watchDecisionJournal` 을 더했다.
골든 입력은 전부 픽스처에서 온다 — 🔴 테스트가 `DraftRecord(...)`·`DecisionJournalVm(...)` 을 지어 한국어 값을 넣지 않는다.

| 골든(× light/dark) | 입력 |
|---|---|
| `j3_restored_rejected` | 스펙 `m6JournalDraftSpecDiscretion` + `m6DraftRecordsJ3` **행 2** 시드 + `watchCommand` = `m6JournalDraftReceipts5` 의 `REJECTED` 행 |
| `j3_submit_not_accepted` | 스펙 discretion + 행 1 시드 + `submitJournalDraft` = `Future.error(Exception())` → 제출 탭 1회(`tester.takeException()` 단언) |
| `j3_executed_read` | 스펙 discretion + 행 2 시드 + `watchCommand` = `EXECUTED` 행 + `watchDecisionJournal` = `m6JournalReadWritten` · 🔴 끼워 넣은 `JournalReadContent` 는 **자기 asOf 헤더·신선도 배너를 그리지 않는다**(`J-3` 위쪽 헤더 하나 — 02 §3-3 v1.2 ⓕ) |
| `j3r_written` | `JournalReadView` + `m6JournalReadWritten` |
| `j3r_not_written` | `JournalReadView` + `m6JournalReadNotWritten` **행 0**(`d_20260810_b_27` — 행 1 은 전환 표본) |
| (선택) `j3r_no_note` · `j2_journal_written` | `m6JournalReadNoNote` · `m6DecisionDetailJournalWritten`(+ 안전 행 0) |
| 기존 `j3_*` 4종 | + `journalDraftStoreProvider.overrideWithValue(RecordingDraftStore())` → 🔴 **픽셀 불변 · 재생성 금지**(바뀌면 복원 전 상태가 찍힌 것 = 결함) · 🆕 (예외 = R-6b 해소 카드 `R3-Bob-J4` 부록 S-1 의 재생성 목록 — 아래 «🆕 R3» 절 · `golden:approved`) |

### 초안 시드하는 법

`RecordingDraftStore`(`package:domain_contracts/testing.dart`)는 메모리 저장소 + 호출 기록(`loaded`·`saved`·`cleared`·`current`)이다.
값을 지어내지 않고, 본문 칸이 `key.kind` 의 칸 1개가 아니면 `save` 가 `Future` 에러(`ArgumentError`)다(계약 사후조건 — C-35 ⑦ 이 받침대 자체를 검사한다).

```dart
final RecordingDraftStore store = RecordingDraftStore(
  seed: <DraftRecord>[
    listFixture(FixturePaths.m6DraftRecordsJ3, DraftRecord.fromJson).rows[1],
  ],
);
```

- 실패 재현은 `class _FailingStore extends RecordingDraftStore` 로 `load`/`save` 만 `Future.error(...)` 로 override 한다(받침대에 스위치를 두지 않는다).
- 🔴 **`J-3` 테스트는 항상 `RecordingDraftStore`**(빈 것 포함)다 — `J-3` 은 마운트할 때마다 `load` 를 부르므로 «초안 포트를 부르지 않는 `J-3` 테스트»는 없다. `UnimplementedDraftStore`(전부 `Future` 에러 · 동기로 던지지 않음)는 **초안 포트를 읽지 않는 화면**용이다 — `J-3` 에 넣으면 전부 에러 보고로 실패한다(🆕 검증 반영 · 구 문장 «부르면 안 되는 테스트는 `UnimplementedDraftStore`» 폐기).
- 🔴 시드한 행이 보이려면 `J-3` 의 `decisionId` = 그 행의 `key.targetId` 다 — 기존 `_pump` 의 기본값(`'test-id'`)으로는 어떤 행도 복원되지 않는다.
- 한 테스트에서 **다른 `decisionId`** 두 개를 보려면 `testWidgets` 를 둘로 나누거나 사이에 `pumpWidget(const SizedBox())` 로 트리를 내린다 — 같은 자리에 다시 `pumpWidget` 하면 State 가 재사용돼(`late final _draftKey` · `didUpdateWidget` 금지) 옛 키가 남는다.
- `saved` 는 `.last`·내용으로 단언한다 — 개수 단언은 «복원만 하고 입력하지 않으면 0건»(같은 값 저장 생략 규칙 — 02 §3-3 v1.2 ⓑ)에만 쓴다.
- «재시작 생존»의 **화면층** 증명 = 같은 `store` 인스턴스로 트리를 내렸다(`pumpWidget(const SizedBox())`) 새 `ProviderScope` 로 다시 띄운다. 🔴 실물 영속 증명은 06 M4-9 다 — 카드·PR 보고에서 두 증명을 섞지 않는다.

### 🔴 한 행씩 시드 — `draft_records_j3` 는 행 순서가 의미다

| 행 | 이름 | 키 | 본문 · 연결 | 쓰는 곳 |
|---|---|---|---|---|
| 0 | `J3_PARTIAL` | `d_20260901_a_31` | 근거 < 40자 · 기대 결과 비어 있음 · 인용 규칙 미선택 · 연결 없음 | 복원 · 버튼 비활성 |
| 1 | `J3_COMPLETE` | `d_20260901_a_31` | 완성 본문 · `RULE_DISCRETION_BUDGET` · 연결 없음 | 복원 · 버튼 활성 · 접수 실패 골든 |
| 2 | `J3_SUBMITTED` | `d_20260901_a_31` | 행 1 본문 · `lastCommandId` = 접수증 픽스처의 명령 | 재구독 · 거부/집행 복원 골든 |
| 3 | `J3_RETIRED_RULE` | `d_20260810_b_27` | 완성 본문 · 폐기 표본 code(선택지에 없음) | 사라진 code = 미선택 · 다른 키 비노출 |
| 4 | `J3_OTHER_NOTE` (🆕 검증 반영) | `d_20260901_a_31` | 완성 본문 · `RULE_OTHER`(`requiresNote`) · **메모 있음**(한국어 원문) · 연결 없음 | 메모 복원 · 메모 필수 규칙의 버튼 판정 |

🔴 여러 행을 한꺼번에 시드하지 않는다 — 행 0·1·2·4 는 **같은 키**라 마지막 행만 남는다(시드 순서가 결과를 바꾼다).
🔵 `executed` 직후 «미작성 → 본문» 전환은 `m6JournalReadNotWritten` **행 1**(`d_20260901_a_31` 미작성) → `m6JournalReadWritten` 순으로 흘린다(`StreamController` · 같은 결정). `m6JournalReadWritten` 의 본문은 읽기 레이아웃 표본이라 행 2 원문과 다르다 — 초안 원문 ↔ 읽기 본문을 대조하지 않는다.
🔴 `watchDecisionJournal` 을 쓰는 화면(`executed` 뒤 `J-3` · `JournalReadView`)의 가짜 저장소는 `extends UnimplementedJournalRepository` 에서
`watchDecisionJournal` 을 override 한다 — 빠뜨리면 받침대가 던져 읽기 본문이 에러 상태(«다시 시도»)가 된다.

## 🆕 R3(계약 v1.7) — `J-4` 사후 blind 리뷰 + 부록 S-1 · S-12 (2026-10-20 조립 · ✅ 같은 날 누적 드라이런 실측 반영 — 높이·dy·S-1 목록 · ✅ 병합 PR #41 `be1b46f` 2026-10-20)

정본: 01 §16(16-6 · 16-8 · 16-10 · 16-16) · 02 §3-4 의 «🆕 계약 v1.7 — `J-4` R3 범위» 블록 ⓗ(수용 (c) = K18 (가) 위젯 트리 대조) · 02 §3-1 ⓗ(S-12) · 설계 저장소 `10_리뷰/2026-10-19_미결46_계약v1.7_설계서.md` §3-4(골든 ↔ 입력). 카드 = `docs/ai-context/send/R3-Bob-J4.md`(«■ 골든» 절과 같은 말). 이 절은 **골든**만 말한다.

### 1. 골든 이름 — 신규 6이름 × light/dark = 12장(`j4_*`) + 부록 S-12 신규 2이름 × 2 = 4장(`j1_rebalance_*`) · 새 PNG 합 16(재분할 임계 «> 16» 의 경계)

| 이름 | 장수 | 테스트 파일 | 입력(흐름) · 크기 · 맨 아래 위젯(위치 전제) |
|---|---|---|---|
| `j4_before_reveal` | 2 | `j4_golden_test.dart` | 큐 `m6/blind_review_queue_3` · 카드 `m6/blind_review_card_before`(= 큐 행 0) · 접수증 없음 · 전 문항 0번 선택지(«예») 선택 · 제출 전 · 맨 아래 `Key('j4-submit')` |
| `j4_after_reveal` | 2 | 〃 | 위 흐름 → 제출(`m6/blind_review_receipts_6` 행 2 `EXECUTED`) → 카드 스트림에 `m6/blind_review_card_revealed` · 같은 선택·잠금 + 결과 섹션 + «다음 건» · `Key('j4-next')` |
| `j4_after_reveal_open` | 2 | 〃 | 큐 = 행 1 이 머리인 슬라이스(`rows.sublist(1)`) · 카드 = 큐 행 1(`d_mf_0002`) → 전 문항 0번 → 제출(행 2 `EXECUTED`) → `m6/blind_review_card_revealed_open`(«미청산 — 결과 미확정» · 보조 줄 0) · `Key('j4-next')` |
| `j4_waiting` | 2 | 〃 | before · 전 문항 0번 → 제출(행 0 `REQUESTED`) · 잠금 + «전송 대기» `stateLabel` · `Key('j4-receipt')` |
| `j4_rejected` | 2 | 〃 | before · 전 문항 0번 → 제출(행 4 `REJECTED` · `BLIND_REVIEW_ANSWERS_INVALID`) · 편집 복귀 + 재제출 + `stateLabel` · 🔴 행 5(`ALREADY_SCORED`)로 그리지 않는다(곧 결과가 흐르는 장면 — 위젯 테스트 T4-09 몫) · `Key('j4-submit')` |
| `j4_empty` | 2 | 〃 | 큐 `m6/blind_review_queue_empty`(«리뷰할 결정이 없습니다») · 고지·제출 없음 · `Key('j4-empty')` |
| `j1_rebalance_chip` | 2 | `j1_rebalance_golden_test.dart`(부록 S-12) | `JournalTimeline(rebalanceEventId: <scope id>)` + `m6/journal_rebalance_scope_1` + `journal_30` 의 그 회차 행 · 회차 칩 + 씨앗 기간 칩 · 크기 = 기본 `kGoldenPhoneSize` 390 × 844 · 🆕 찍기 전 필터 줄을 회차 칩까지 가로 끝 정렬 스크롤(`Scrollable.ensureVisible(tester.element(bottom), alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd)` — 390 폭에서 칩은 x 460.5~816.6 이라 스크롤 없이는 안 보인다 · 세로 스크롤 0) · 위치 전제 `getBottomRight(칩).dx <= 390` + dy < 844 · `Key('j1-chip-rebalance')` |
| `j1_rebalance_unknown` | 2 | 〃 | 모르는 회차(scope null) + `m6/journal_rebalance_unknown`(0행 · `emptyLabel`) · 칩 부재 + 빈 문장 · 390 × 844 · 같은 끝 정렬(이미 보여 스크롤 0) · 맨 아래 = 빈 문장 |

- 공통: 안전 행 0(`safetyFixtureRow(0)`) · 시계 `FixedClock(kGoldenNowUtc)` · `const JournalBlindReview()`(인자 없음) · 탭·제출은 `test/blind_review_fakes.dart` 의 도우미(`pickBlindReviewAnswers` 등) · 찍기 전 `pumpAndSettle()`.
- `j4_*` 크기 = 테스트 파일 안 상수 `const Size _kTallPhone = Size(390, 1600)`(드라이런 확정 — 최대 dy 1480 · 여백 줄이기 0 · 이 파일의 «🆕 R2» 절 2번 «세로가 긴 화면» 꼴 · `kGoldenPhoneSize` 불변).
- 위치 전제(찍기 전 · 이름마다 맨 아래 위젯 하나): `expect(tester.getBottomLeft(find.byKey(Key(bottomKey))).dy, lessThan(_kTallPhone.height));` — `bottomKey` 는 위 표 마지막 칸.
- 🔴 `j4_before_reveal` ↔ `j4_after_reveal` 의 «차이가 결과 섹션뿐»(02 수용 (c))은 **골든 픽셀 비교로 증명하지 않는다** — 위젯 테스트 T4-16(K18 (가) 위젯 트리 대조: 하단 영역 밖 Text 목록 동일 · 고른 선택지 Key 동일 · 차이 허용 = 잠금 표현 + 하단)이 증명하고, PNG 눈 대조는 C4 보조다.
- 드라이런 실측 dy(light/dark · `dry/r3-j4` `390f218`): `j4_before_reveal` 1320.0/1320.0 · `j4_after_reveal` 1480.0/1480.0 · `j4_after_reveal_open` 1300.0/1300.0 · `j4_waiting` 1288.0/1288.0 · `j4_rejected` 1368.0/1368.0 · `j4_empty` 76.0/76.0(< 1600) · `j1_rebalance_chip` 92.0/92.0(dx 390.0) · `j1_rebalance_unknown` 480.0/480.0(dx 316.125)(< 844).
- 🆕 병합본 실측(R3 · PR #41 `be1b46f` · 2026-10-20 · Bob `47e87ce`(+ 재제출 `48a06a1` — 테스트 4파일 · lib·PNG 불변) · C4 재실측 일치 · light=dark): `j4_before_reveal` **1248** · `j4_after_reveal` **1392** · `j4_after_reveal_open` **1212** · `j4_waiting` **1220** · `j4_rejected` **1296** · `j4_empty` **76**(< 1600) · `j1_rebalance_chip` **92**(dx 390) · `j1_rebalance_unknown` **480**(< 844). 드라이런과의 차(68~88)는 간격 재량(결함 아님 · 여백 줄이기 0 · 질문 파일 여백 행 0 = 정상). «배치·잘림» 칸 = Bob 이 이미지 한도로 쓰지 못해 C4 가 PNG 를 열어 채움(발주자 예외 · 2026-10-20). 새 PNG 16장 blob 중복 0 · S-1 재생성 6장 = 드라이런 PNG 와 블롭 같음 · 기존 50장 M 0 → **72장**(`be1b46f` 트리 `git ls-tree` 실측).
- 🔵 선택과 점수: 흐름의 선택(전 문항 0번 = «예»)과 결과 픽스처의 과정 점수 글자(`revealed` «4점» · `revealed_open` «3점»)는 **합성 — 서로 무관**(화면은 점수를 셈하지 않는다 · PNG 글자는 테스트 글꼴 네모라 읽히지 않는다).

### 2. 부록 S-1 — 기존 `j3_*` 재생성 허용 목록(R-6b · R2b C4 B03)

- 재생성 = **6장**(드라이런 확정) = `j3_rejected_*` · `j3_restored_rejected_*` · `j3_submit_not_accepted_*`(인용 규칙 드롭다운의 선택 label 둘째 줄 밑줄 겹침이 들어 있는 장면) · 해법 = `itemHeight: <고른 것 없음> ? kMinInteractiveDimension : null` + `selectedItemBuilder`(`Padding(vertical: 8)` + `Text(o.label)` 전문 — 카드 «부록 S-1») · 메뉴 열린 `j3_rule_menu_open_*` 는 불변.
- 그 밖의 PNG(`j3_discretion` · `j3_recon_clear` · `j3_executed_read` · `j3_rule_menu_open` · `j3r_*` · `j1_*` · `j2_*` · `j5_*`) = **M 0**(고른 것이 없을 때의 드롭다운 모양은 그대로여야 한다 — 조건 없는 `itemHeight: null` 은 이 PNG 들까지 바꾼다 · 드라이런 시도 2).
- 명령 = 이름마다 `--plain-name` 한 줄(예 `flutter test --update-goldens test/golden/j3_golden_test.dart --plain-name "j3_rejected"`) — 🔴 파일 통째·폴더 지정 금지(같은 파일의 다른 PNG 까지 다시 찍힌다).
- 이 PR 은 기존 PNG 를 바꾸므로 CI «골든 스냅샷» 잡이 빨갛다 — 통합 담당이 목록과 PNG 를 대조한 뒤 `golden:approved` 를 붙인다(목록 밖 M = 반려).

### 3. 장수(카드가 받는 장수 · 기존 PNG 56장 = R3 시작 기준)

- R3 시작 56장(`j1_*` 16 · `j2_*` · `j3_*` · `j3r_*` · `j5_*`) → R3 병합 뒤 **72장**(+ `j4_*` 12 · `j1_rebalance_*` 4 · 부록 S-1 은 M 이라 장수 불변).
- 명령(packages/ui_journal 에서): `flutter test --update-goldens test/golden/j4_golden_test.dart` · `flutter test --update-goldens test/golden/j1_rebalance_golden_test.dart` → 옵션 없이 `flutter test` 전부 통과.

## 🆕 R4(계약 v1.8) — `H6-1` 보유현황(R4a) · `H6-2` 종목 상세 · `H6-3` 슬리브·비중(R4b) (2026-10-21 조립 · ✅ 누적 드라이런 실측 — R4a `dry/r4a` · R4b `dry/r4b` · ✅ R4a 병합 PR #57 `faeb458` 2026-10-21)

정본: 01 §17(17-6 · 17-7 · 17-8 · 17-10 · 17-16) · 02 §4 끝 «🆕 계약 v1.8 — `H6-*` R4 범위» 블록 · 설계 저장소 `10_리뷰/2026-10-20_R4선행_계약v1.8_설계서.md` §3-4(골든 ↔ 입력 · ✅ K16 이름 확정). 카드 = ~~`docs/ai-context/send/R4a-Bob-H61.md`~~ `docs/ai-context/send/_완료/R4a-Bob-H61.md`(R4a · 2026-10-21 병합) · ~~`docs/ai-context/send/_대기/R4b-Bob-H62H63.md`~~ `docs/ai-context/send/R4b-Bob-H62H63.md`(R4b — 2026-10-21 R4a 병합 기록 때 `send/` 로)(«■ 골든» 절과 같은 말). 이 절은 **골든**만 말한다.

### 1. 골든 이름 — R4a 신규 5이름 × light/dark = 10장(`h61_*`) · R4b 신규 8이름 × 2 = 16장(`h62_*` 8 · `h63_*` 8) · 재생성 0

| 이름 | 장수 | 테스트 파일 | 입력(흐름) · 맨 아래 위젯(위치 전제) |
|---|---|---|---|
| `h61_normal` | 2 | `h61_golden_test.dart`(R4a) | `m6/holdings_overview_normal` · `safety_states` 행 0 · 흐름 = B 카드(순번 1) 펼침 — 카드 3(처음 전부 접힘) · B 종목 행 2 + 반영 대기 칩 · 시스템 밖 섹션 접힘(고지 상시) · 「비중 보기」 = 머리·배너 바로 아래(02 §4-3 «상단») · 맨 아래 `Key('h61-ext')` |
| `h61_recon_mismatch` | 2 | 〃 | `m6/holdings_overview_recon` · 행 3 · 흐름 = B 카드 펼침(«?» 행) · 배너 2 · `Key('h61-ext')` |
| `h61_integrity` | 2 | 〃 | `m6/holdings_overview_integrity` · 행 4 · 흐름 없음(카드 전부 접힘 — 머리 `bandNoteText` «숨김» · ✅ K29 칩은 화면에 안 나온다) · 배너 1 · `Key('h61-ext')` |
| `h61_empty` | 2 | 〃 | `m6/holdings_overview_empty` · 행 0 · 흐름 없음(머리 + 빈 문장) · `Key('h61-empty')` |
| `h61_pnl_expanded` | 2 | 〃 | `m6/holdings_overview_normal`(접힘) / `m6/holdings_overview_pnl`(펼침) · 행 0 · 흐름 = 손익 토글 탭 → 카드 0·1·2 펼침 — 손익 줄 3 + `disclosureNote` · `Key('h61-ext')` |
| `h62_etf_no_stop` | 2 | `h62_golden_test.dart`(R4b) | `m6/holding_detail_no_stop` · 행 0 · 흐름 없음(손절선 문장 · 최근 체결 문장) · `Key('h62-recent-empty')` |
| `h62_pnl_expanded` | 2 | 〃 | `m6/holding_detail_no_stop`(접힘) / `m6/holding_detail_pnl`(펼침) · 행 0 · 흐름 = 손익 토글 탭 · `Key('h62-recent-empty')` |
| `h62_recon_mismatch` | 2 | 〃 | `m6/holding_detail_recon` · 행 3 · 흐름 없음 · `Key('h62-recent-empty')` |
| `h62_integrity` | 2 | 〃 | `m6/holding_detail_integrity` · 행 4 · 흐름 없음(요약·손절선 글자 «숨김» · 최근 체결 2) · `ValueKey<String>('h62-entry-1')` |
| `h63_in_band` | 2 | `h63_golden_test.dart`(R4b) | `m6/allocation_in_band` + 하단 `m7/m7_next_rebalance_countdown` · 행 0 · 흐름 없음(5행 · B 밴드 내 · POT 들여쓰기) · `Key('h63-next')` |
| `h63_out_of_band` | 2 | 〃 | `m6/allocation_out_of_band` + countdown · 행 0 · B 밴드 이탈 · `Key('h63-next')` |
| `h63_tranche_progress` | 2 | 〃 | `m6/allocation_tranche_progress` + countdown · 행 0 · B 경계 근접 · A 보류 칩 1 · `Key('h63-next')` |
| `h63_pot_under_a` | 2 | 〃 | `m6/allocation_in_band` + countdown · 행 0 · 흐름 = A 행(순번 0) 엔진 열 안내 펼침 · `Key('h63-next')` |

- 공통: 시계 `FixedClock(kGoldenNowUtc)` · 화면 위젯 = `const HoldingsOverview()` · `HoldingDetail(holdingId: <그 VM 의 holding.holdingId>)` · `const HoldingsAllocation()` · 흐름 = (이름, 흐름) 목록의 **클로저 칸**(C4r3-4 — 흐름 없음 = `(WidgetTester t) async {}` · bool 칸 + if 금지) · 차례 = `pumpForGolden` → `pump()` 한 번 더(값 도착) → 흐름 → `pumpAndSettle()` → 위치 전제 둘 → `expectGolden`.
- 크기 = 테스트 파일마다 안 상수 `const Size _kTallPhone` — h61 = `Size(390, 2480)` · h62 = `Size(390, 1400)` · h63 = `Size(390, 1100)`(드라이런이 정했다 · `kGoldenPhoneSize` 불변 · 이 파일의 «🆕 R2» 절 2번 «세로가 긴 화면» 꼴).
- 위치 전제(찍기 전 · 이름마다 둘 · C4r3-5 코드 꼴): `expect(tester.getBottomLeft(find.byKey(<맨 아래 Key>)).dy, lessThan(_kTallPhone.height));` + `expect(tester.getTopLeft(find.byKey(const Key('h6N-asof'))).dy, 0.0);`(스크롤 0 — 펼침 탭(h61 = `scrollUntilVisible(finder, 300)` · h62·h63 = `ensureVisible`)이 머리를 밀어 올리지 않았다 · N = 1·2·3 · 🔴 그래서 `ListView` 에 padding 0 — 실패하면 고치지 말고 실측 dy 를 질문 파일에).
- 🆕 보고 «배치·잘림» 칸 — Bob 은 이름마다 **light PNG 한 장만** 연다(R4a 5장 · R4b 8장 — 한 대화 이미지 20장 한도) · dark 행은 같은 이름 light 행의 칸 글자 그대로(위치 전제 dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
- 드라이런 실측 dy(맨 아래 Key 의 아래 끝 · light = dark 전부 · 머리 dy = 0.0 전부 · R4a `dry/r4a` `06668f0` · R4b ~~`dry/r4b` `cf28087` — R4b 값은 R4a 병합본 흉내 위라 R4a 가 통합 수정으로 바뀌면 R4a 병합 기록 때 다시 잰다~~ → 🆕 재드라이런 `dry/r4b2` `c5ae7f4`(실제 R4a 병합본 `faeb458` + 병합 기록 위 · 2026-10-21 · 옛 값 = 취소선 · 차 h62 −28 · h63 +4 = 간격 재량 · 🔵 h63 여유 44 · Bob 실측이 달라도 높이 안이면 된다)):

  | 이름 | dy | 높이 |
  |---|---|---|
  | `h61_normal` | 1292.0 | 2480 |
  | `h61_recon_mismatch` | 1512.0 | 2480 |
  | `h61_integrity` | 608.0 | 2480 |
  | `h61_empty` | 116.0 | 2480 |
  | `h61_pnl_expanded` | 2436.0 | 2480 |
  | `h62_etf_no_stop` | ~~700.0~~ 672.0 | 1400 |
  | `h62_pnl_expanded` | ~~768.0~~ 740.0 | 1400 |
  | `h62_recon_mismatch` | ~~920.0~~ 892.0 | 1400 |
  | `h62_integrity` | ~~1368.0~~ 1340.0 | 1400 |
  | `h63_in_band` | ~~1012.0~~ 1016.0 | 1100 |
  | `h63_out_of_band` | ~~1036.0~~ 1040.0 | 1100 |
  | `h63_tranche_progress` | ~~1040.0~~ 1044.0 | 1100 |
  | `h63_pot_under_a` | ~~1052.0~~ 1056.0 | 1100 |

- 🆕 R4a 병합본 실측(PR #57 `faeb458` · 2026-10-21 · Bob `3bcd5ca` · C4 재실측 일치 · light=dark · 머리 dy 0.0): `h61_normal` **1268** · `h61_recon_mismatch` **1488** · `h61_integrity` **584** · `h61_empty` **116** · `h61_pnl_expanded` **2412**(< 2480). 드라이런과의 차 −24(빈 갈래 0)는 간격 재량(결함 아님 · 여백 줄이기 0 · 질문 파일 여백 행 0 = 정상). 새 10장 블롭 중복 0 · 기존 72장 M 0 → **82장**(`git ls-tree` 실측). «배치·잘림» 칸 = Bob 제출 글이 비워 두어 C4 가 PNG 10장을 열어 채움(발주자 예외 · PR #57 본문 «C4 정정»). ~~R4b 행 dy 는 드라이런 값 그대로(R4a 통합 수정 0 · R4b 화면은 R4a 배치에 기대지 않는다)~~ → R4b 행 dy 는 재드라이런(실제 병합본 위) 실측으로 바꿈(위 표 · R4b 병합 기록 때 Bob 실측으로 다시 바꾼다).
- 🔵 골든은 아이콘 차이를 못 본다(테스트 글꼴에서 아이콘 = 같은 네모) — 아이콘 매핑은 화면 테스트(T61-03 · T61-06 · T62-01 · T62-04)가 본다.
- 🔴 재생성 0 — 이 두 카드는 기존 PNG(72장)를 바꾸지 않는다(`golden:approved` 불필요 · 기존 PNG `M` = 반려 신호).

### 2. 장수

- R4 시작 72장(`dcac7ec` = R3 병합본 72 · 계약 v1.8 은 ui PNG 0) → R4a 병합 뒤 **82장**(+ `h61_*` 10 · ✅ PR #57 `faeb458` · `git ls-tree` 실측 82) → R4b 병합 뒤 **98장**(+ `h62_*` 8 · `h63_*` 8).
- 명령(packages/ui_journal 에서 · 🔴 파일마다 · 폴더 지정 금지): `flutter test --update-goldens test/golden/h61_golden_test.dart`(R4a) · `flutter test --update-goldens test/golden/h62_golden_test.dart` · `flutter test --update-goldens test/golden/h63_golden_test.dart`(R4b) → 옵션 없이 `flutter test` 전부 통과.
