# `test/golden/` — 위젯 골든 스냅샷 (C-2 · 하네스 ✅ 2026-09-17 · PNG ✅ `J-1` 16장(R1b 병합 PR #7) · 🆕 `J-2`·`J-3`·`J-5` 는 R2 PR 에서 최초 생성)

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

## 하네스 (M2 제공 · 2026-09-17 · C4 R1-Bob-J1 질문 Q1 의 답 · 비교기 3판 = 이동·AA 허용 · infra PR #3)

화면 담당이 만드는 것은 **골든 테스트 파일과 PNG** 뿐이다. 나머지는 이미 있다.

| 파일 | 누가 | 무엇 |
|---|---|---|
| `test/flutter_test_config.dart` | 🔴 M2 | `flutter test` 가 자동으로 먼저 부른다. 골든 비교기를 **이동·AA 허용 비교기(3판)** 로 바꾼다 — 두 그림을 3×3 으로 살짝 흐린 뒤 **양방향**으로 «이웃 3×3 어디에도 비슷한 색이 없는 유의 픽셀»을 세고, **가장 빽빽한 24×24 창의 밀도 12% 이하(주 판정) 그리고 전체 0.5% 이하(보조)** 면 통과(`golden/shift_tolerant_compare.dart` · 자체 검증 `golden/comparator_test.dart` 11건). 🔵 2026-09-17 실측(리눅스 CI vs Windows 골든 14장): 플랫폼 소음은 전체 ≤0.18%·창 ≤5.6% 로 **얇게 흩어지고**, 구조 변화는 18px 아이콘 1개 누락도 창 27% 로 **뭉친다**(칩 47% · 글자 줄 83% · 배너 96%). 화면 담당은 고치지 않는다 |
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
| 기존 `j3_*` 4종 | + `journalDraftStoreProvider.overrideWithValue(RecordingDraftStore())` → 🔴 **픽셀 불변 · 재생성 금지**(바뀌면 복원 전 상태가 찍힌 것 = 결함) |

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
