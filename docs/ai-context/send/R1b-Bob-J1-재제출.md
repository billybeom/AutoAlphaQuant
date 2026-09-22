# 발송 패킷 R1b-Bob-J1 — 재제출 (1회차 반려 · 2026-09-21)

> 만든 날 2026-09-21 · 1회차(PR #7 · 커밋 `928f04e`)의 C4 병합 검사 결과가 **반려(가벼운 재제출)**여서 만든 패킷입니다. 프롬프트·규칙·범위(J-1)는 그대로이고, 이 패킷은 **반려 사유 + 고칠 것 4가지 + 질문 Q3~Q5 의 답**만 담았습니다.
> 같은 브랜치 `ui/m6-j1-complete` · 같은 PR #7 에 커밋을 더하면 됩니다(새 PR 을 만들지 않습니다).

## 0. 한 줄 목적

J-1 필터가 «실제로 조작했을 때» 맞게 동작한다는 것을 테스트·골든으로 증명하고, 기본 기간을 화면이 스스로 고르게 하기.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m6-j1-complete`.

## 2. 보내기 전에 발주자가 할 것

없습니다. (Claude 가 골든 하네스 수정 PR #8 을 `main` 에 병합해 두었습니다 — Bob 이 아래 «먼저 할 것»에서 받아 갑니다.)

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R1b-Bob-J1 재제출 요청 — 1회차(PR #7 · 928f04e) 판정: 반려(가벼운 재제출). 같은 브랜치·같은 PR 에 커밋을 더하십시오.

■ 잘된 것 — 그대로 유지하십시오
format·analyze·test 34/34·경계 검사 전부 통과 · 표시 전환(sideLabel·*Text)과 화면측 가림 삭제가 정확함 · 링크는 전부 AppLinkOpener 로(리터럴 0) ·
clearDeepLink null → 화살표 부재 · checkpointLabel · 배지 0건이면 줄 없음 · 받침대(extends Unimplemented*) · RecordingLinkOpener 를 픽스처 값과 비교 ·
통합 담당이 필터 시트를 직접 열어 조작해 봤고(임시 테스트) **시트는 정상 동작합니다**: 열림 → 선택지 탭 → 「적용」 → watchTimeline(status:) 에 그 값이 감.

■ 왜 반려인가 — 「동작은 하는데, 증명이 없다」
F1 기본 기간을 화면이 고르지 않습니다. journalTimelineQueryProvider 가 throw 하는 StateProvider 라 «조립 앱이 기본 프리셋을 골라 override» 해야만 화면이 뜹니다.
   그런데 프리셋은 Stream 으로 옵니다 — 조립 앱이 화면을 만들기 전에 스트림 첫 값을 기다려 override 를 짜야 하고, 그 일을 모든 화면마다 셸이 떠안게 됩니다.
   테스트 ②는 **테스트 자신이** isDefault 프리셋을 골라 query 로 주입한 뒤 «isDefault 가 넘어갔다»고 확인합니다 — 화면이 아무것도 안 해도 통과하는 테스트입니다.
   자체 점검의 「[x] isDefault == true 항목이 초기 range로 전달됨」은 화면이 한 일이 아니었습니다.
F2 테스트 ③도 같습니다 — status 를 query 에 직접 주입하고 «status 가 넘어갔다»고 확인합니다. 필터 시트(이번 카드의 가장 큰 새 UI · 약 400줄)를
   여는 테스트가 **한 건도 없습니다**. 골든 j1_filter_open 도 시트가 닫힌 화면입니다(Q5 — 아래 답: 하네스 제약이었고 고쳤습니다).
F3 활성 필터 칩의 wire 폴백 — 카탈로그가 아직 안 왔거나 선택지를 못 찾으면 `status.wire`·`sleeve.wire`·`origin.wire`("FILLED"·"A")를 사용자에게 그대로 보여 줍니다.
   R1 의 `side.wire` 허용은 «짝 라벨이 계약에 없던 동안»의 임시 조치였고 v1.1 에서 끝났습니다. 내부 코드 문자열은 화면에 나오지 않습니다.
F4 `Text(query.range.label ?? JournalLabels.filterAll)` — 기간에 라벨이 없으면 「전체」라고 찍습니다. 라벨이 없는 것과 «전체 기간»은 다릅니다
   (없는 사실을 화면이 말하는 것 = 문구 생성). 

■ 먼저 할 것
  git fetch origin && git merge origin/main        ← 골든 하네스에 wrapApp 이 생겼습니다(PR #8) + 이 패킷·기록 문서
  읽을 것: packages/ui_journal/test/golden/README.md 끝의 「🆕 모달(바텀시트·다이얼로그)이 열린 상태를 찍는 법」

■ 고칠 것
G1 (F1·Q3) 기본 기간 자가 초기화 —
   · `journalTimelineQueryProvider` = `StateProvider<JournalTimelineQuery?>((Ref ref) => null);`  (throw 하지 않음 · null = «사용자가 아직 고르지 않음»)
   · 새 파생 프로바이더(이름 예 `journalEffectiveQueryProvider`, 타입 예 `Provider<AsyncValue<JournalTimelineQuery>>`):
       state != null → 그 값 / null → `_journalRangePresetsProvider` 의 목록에서 **isDefault == true 인 항목**으로 `JournalTimelineQuery(range: 그 항목)`
       프리셋 로딩 중 → 로딩(타임라인은 스켈레톤) / 프리셋은 왔는데 isDefault 가 없음(계약 위반 — C-34 가 픽스처에서 막음) → 에러 상태(재시도). 🔴 첫 항목·임의 항목으로 대신하지 않습니다.
   · `journalTimelineProvider` 는 이 파생 값을 구독합니다. 필터 「적용」·칩 제거는 지금처럼 StateProvider 에 씁니다. 「초기화」= state 를 null 로(→ 다시 기본 프리셋).
   · 조립 앱의 override 는 여전히 가능합니다(예: 리밸런싱 회차에서 넘어올 때 rebalanceEventId 가 든 초기 쿼리) — 그래서 StateProvider 자체는 §4-1 규약에 맞습니다(Q3 답).
   · `_FilterBar` 등 query 를 읽는 곳은 파생 값 기준으로.
G2 (F3) wire 폴백 삭제 — `_sleeveLabel`·`_statusLabel`·`_originLabel`·`_symbolLabel` 이 라벨을 못 찾으면 **null** 을 돌려주고, null 이면 그 활성 칩을 **그리지 않습니다**
   (카탈로그가 도착하면 나타납니다). lib/ 에 `.wire` 를 Text 로 넘기는 코드가 0건이어야 합니다.
G3 (F4) 기간 칩 — `query.range.label == null` 이면 기간 칩을 그리지 않습니다(「전체」로 대신하지 않음). 시트 안의 `Text(r.label ?? '')` 도 label 이 null 인 프리셋은 선택지에서 뺍니다.
G4 (F1·F2·Q5) 테스트·골든을 «UI 를 실제로 조작해서» —
   · 테스트 ② 교체: query override **없이** pump(가짜 Config 가 rangePresets4 픽스처를 줌) → `fakeJournal` 이 받은 **첫** watchTimeline 의 range 가
     `presets.firstWhere((r) => r.isDefault)` 와 **같은 객체 값**인지(`equals(defaultPreset)`). isDefault 가 없는 목록을 주면 에러 상태가 뜨는지 1건 추가.
   · 테스트 ③ 교체: 「필터」 탭 → 시트에서 상태 선택지 탭 → 「적용」 탭 → 마지막 watchTimeline 의 status 가 그 선택지의 status. 아래 뼈대를 그대로 써도 됩니다.
   · 추가: 「초기화」 → 「적용」 뒤 status/sleeve/symbol/origin 이 null 이고 range 가 기본 프리셋 · 활성 칩의 ✕ 탭 → 그 인자만 null.
   · 추가: 카탈로그를 주지 않은 상태(가짜가 `Stream.empty()` 또는 미구현)에서 status 가 걸린 초기 쿼리를 override 로 주면 **wire 문자열이 화면에 없다**
     (`find.text(JournalStatus.filled.wire)` findsNothing).
   · 골든 `j1_filter_open` 을 **시트가 실제로 열린 상태**로 다시 찍습니다(README 레시피: `pumpForGolden(..., wrapApp: (app) => ProviderScope(overrides: …, child: app))`
     → `tester.tap(find.text(JournalLabels.filter))` → `pumpAndSettle()` → `expectGolden`). 이 1종(light/dark 2장)은 이 PR 안에서 새로 만든 파일이므로 다시 찍어도 됩니다.
     활성 칩이 보이는 화면은 `j1_filter_active`(status 1개 선택 상태) 로 **이름을 바꿔** 1종 더 둡니다.
   뼈대(통합 담당이 돌려 본 것 — test/timeline_filter_sheet_test.dart 로 넣고 다듬으십시오. 시트 목록은 지연 생성이라 화면 밖 선택지는 scrollUntilVisible 로 내립니다.
   타임라인 행에도 같은 글자(예 「체결」)가 있으니, 행에 없는 선택지(픽스처의 「상쇄됨」 등)를 고르거나 시트 범위로 finder 를 좁히십시오):
       await tester.tap(find.text(JournalLabels.filter));
       await tester.pumpAndSettle();
       expect(find.text(JournalLabels.filterReset), findsOneWidget);
       final JournalStatusOption pick = catalog.statusOptions.firstWhere((o) => o.status == JournalStatus.reversed);
       final Finder sheetScroll = find.byType(Scrollable).last;
       await tester.scrollUntilVisible(find.text(pick.label), 120, scrollable: sheetScroll);
       await tester.tap(find.text(pick.label));
       await tester.pumpAndSettle();
       await tester.scrollUntilVisible(find.text(JournalLabels.filterApply), 120, scrollable: sheetScroll);
       await tester.tap(find.text(JournalLabels.filterApply));
       await tester.pumpAndSettle();
       expect(fakeJournal.calls.last['status'], pick.status);           // 가짜는 받은 인자를 호출마다 기록
       expect(find.text(JournalLabels.filterApply), findsNothing);        // 시트가 닫혔다
   (ProviderScope 는 MaterialApp **위에** — 기존 `_pump` 가 이미 그렇게 돼 있습니다.)
G5 PR 본문 ② 자체 점검을 실제와 맞추십시오 — 「isDefault 항목이 초기 range 로 전달됨」은 G1 이 끝난 뒤에 [x].

■ 질문의 답 — docs/ai-context/inbox/J1_questions.md 의 Q3~Q5 «상태·답» 칸에 그대로 옮겨 적으십시오(상태 = ✅ 답함)
Q3 StateProvider 는 §4-1 규약에 맞습니다(override 가능 · 필터 UI 가 써야 하므로 필요). 단 **throw 하는 기본값은 안 됩니다** — nullable + 기본 프리셋 자가 초기화(G1).
   조립 앱 override 는 «다른 화면에서 넘어온 초기 쿼리»용으로 남습니다. 01 §11-3 「기본 기간」 문단에 명문화.
Q4 맞습니다 — 모달은 Navigator(=MaterialApp) 위에 뜨므로 **ProviderScope 가 MaterialApp 위에 있으면** 시트가 같은 주입을 봅니다. 실제 앱(ProviderScope = 앱 루트)과
   기존 `_pump` 는 그 모양이라 문제없습니다(통합 담당이 시트를 열어 확인). 문제는 골든 하네스였습니다 — child 를 MaterialApp 안에 넣어서. → `wrapApp` 추가(PR #8).
Q5 ② 시트가 **실제로 열린** 상태여야 합니다. 방법은 위 G4 · README 레시피. active chip 화면은 `j1_filter_active` 로 따로.
   그리고 아래 4행을 표 끝에 추가하십시오(C4 검사가 찾은 것):
   | A10 | J-1 | 추측 | (R1b 1회차 · C4 발견) 기본 기간을 화면이 고르지 않고 조립 앱 override 에 맡김 · 테스트 ②가 스스로 주입한 값을 확인 | 기본 기간 | — | 🔴 재제출 | G1 · 01 §11-3 |
   | A11 | J-1 | 추측 | (C4 발견) 필터 시트를 여는 테스트·골든이 0건 — 테스트 ③도 주입값 확인 | 테스트 | — | 🔴 재제출 | G4 · 하네스 wrapApp(PR #8) |
   | A12 | J-1 | 추측 | (C4 발견) 활성 칩의 wire 폴백(`status.wire` 등을 화면에 표시) | 정적 라벨 경계 | — | 🔴 재제출 | G2 — 내부 코드 문자열은 화면에 나오지 않는다 |
   | A13 | J-1 | 추측 | (C4 발견) `range.label ?? 「전체」` — 없는 사실을 화면이 말함 | 문구 생성 | — | 🔴 재제출 | G3 |

■ 제출
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS
  git push   (같은 브랜치 → PR #7 에 자동 반영). PR 본문 수정은 통합 담당이 합니다 — 바뀐 자체 점검·골든 표·새 질문만 채팅으로 주십시오.
```

---

## 3-1. 받아야 하는 것

같은 브랜치에 추가 커밋(화면 1파일 + 테스트 + 골든 `j1_filter_open` 재생성·`j1_filter_active` 신규 + `inbox/J1_questions.md`) + 바뀐 자체 점검.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R1b-Bob-J1 재제출: PR #7 에 푸시됨 — 병합 검사해줘
```

## 5. 주의

- PR #7 의 CI «골든 스냅샷» 잡이 빨간 것은 정상입니다(기존 골든 8장을 다시 찍었기 때문 · 카드가 지시한 것). 병합 검사를 통과하면 Claude 가 `golden:approved` 라벨을 붙입니다.
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 전용 폴더 `C:\Work\AAQ-claude` 에서만 작업합니다).
