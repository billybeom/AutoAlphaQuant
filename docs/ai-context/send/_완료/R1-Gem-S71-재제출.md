# 발송 패킷 R1-Gem-S71 — 재제출 (1회차 반려 · 2026-09-17 · 웹 채팅 방식)

> 만든 날 2026-09-17 · 1회차(같은 날 수신)의 C4 검사 결과가 **반려**여서 만든 패킷입니다. 프롬프트·규칙은 이전과 같고(`docs/ai-context/prompt_M7.md`) 이 패킷은 **반려 사유 + 고칠 것 + 출력 형식**만 담았습니다. 1회차 원문은 로컬 브랜치 `ui/m7-s71-monthly-report`(커밋 `9a007fa` · 미푸시)에 그대로 보관돼 있습니다.

## 0. 한 줄 목적

같은 Gemini 채팅에서 반려 사유를 고친 **전체 파일**을 다시 받기(웹 방식 — 저장·포맷·검사·골든 PNG 생성·브랜치·PR 은 Claude 가 대행).

## 1. 어디에 보내나

**Gemini Pro 웹 채팅** — 1회차를 보낸 **같은 대화**에 이어서 보냅니다(새 대화면 1회차 패킷 `R1-Gem-S71.md` 의 «2. 첨부» 전체를 다시 올린 뒤 이 패킷).

## 2. 먼저 첨부할 파일 (바뀐 것만 5개 · 전부 `C:\Work\Bob\AutoAlphaQuant\` 아래)

1. `docs/ai-context/inbox/S7-1_questions.md` ← 1회차 질문의 답 + 검사가 찾은 A1~A9
2. `docs/ai-context/03_화면명세_M7_성과_리밸런싱_플래너.md` ← §1-4 · §3 「🔵 C4 R1-Gem-S71 반영」 갱신판
3. `docs/ai-context/01_M2_도메인계약_초안.md` ← §2-10 «값 가림의 주체» · §4-1 «화면 위젯의 모양» 갱신판
4. `packages/ui_analytics/test/golden/README.md` ← 골든 하네스 레시피·뼈대
5. `packages/ui_analytics/test/golden/golden_support.dart` ← 테스트가 부를 도우미 API(픽스처 로더·고정 시계·pump·expect)

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R1-Gem-S71 재제출 요청 — 1회차 판정: 반려(병합 불가). 프롬프트·규칙은 이전과 같고 범위도 S7-1 하나입니다.
방금 첨부한 5개 파일을 먼저 읽으십시오. 읽는 순서:
  ① S7-1_questions.md 의 «답» 칸(Q1 · A1~A9)  ② 03 §3 「🔵 C4 R1-Gem-S71 반영」 7항과 §1-4(2026-09-17 동기)
  ③ 01 §4-1 「화면 위젯의 모양」· §2-10 「값 가림의 주체」  ④ test/golden/README.md 「하네스」  ⑤ golden_support.dart

■ 잘된 것 — 그대로 유지하십시오
의존 3패키지뿐 · 산술 0 · 한국어 리터럴은 labels.dart 에만 · 신선도 판정식이 주입 Clock 하나 · 13항목을 받은 순서대로 ·
제외 4종 위젯 없음 · 신뢰 등급을 리포트 필드(report.trust)에서 읽음 · UiLevel 망라 switch 로만 색 선택 · '+N' 개수 표기.

■ 왜 반려인가
1. 기계 검사 — `dart analyze --fatal-infos` 1건: monthly_report_screen.dart 의 `loading: () => _buildSkeletonLoader()` (unnecessary_lambdas — 티어오프로).
   자체 테스트 3건 중 2건 실패: ListView 는 화면 밖 항목을 만들지 않아 「항목 7」 이후와 `***` 13개를 찾지 못합니다.
   (dart format 6파일은 제가 대행합니다 — 신경 쓰지 않아도 됩니다.)
2. 명세 위반·적지 않은 추측 — S7-1_questions.md A1~A9. ⑤ «추측한 것 목록 = 없음» 은 사실과 달랐습니다(A2·A3·A4).

■ 고칠 것
G1 (A7) pubspec.yaml 을 내지 마십시오. 기존 파일에 의존 3종이 이미 있고, 저장소 13개 pubspec 은 같은 SDK 제약·알파벳 정렬·flutter_lints 를 공유합니다.
G2 (A1) Scaffold·AppBar·SafeArea 를 없애고 **본문 위젯만** 공개하십시오(클래스 이름 MonthlyReportScreen 유지 가능). 타이틀·접두·띠는 셸(M8) 소유입니다.
        부모가 주는 높이 안에서 스크롤되는 위젯 하나면 됩니다(Column[배너들, Expanded(ListView)] 구조는 유지 가능).
G3 (Q1·A2) 이동 콜백 매개변수 6종(onOpenArchive·onOpenGoalPath·onOpenExecutionGap·onOpenDrawdownDetail·onOpenContributionDetail·onOpenSafetyRoute),
        `_hasItemDetailAction`·`_handleItemDetailTap`, 「지난 리포트」·「자세히」 버튼을 **전부 삭제**하십시오. 라우트 상수·항목 링크 필드가 계약에 없습니다
        (01 §8 미결 36·41 — R1b 라운드). 순번(order == 5)으로 버튼을 고르는 것은 화면 판정이라 금지입니다. labels 의 reportArchiveButton·detailsButton 도 삭제.
G4 (A3) `_resolveDisplayValue`·maskedIntegrity·maskedReconMismatch 삭제 — `item.valueText` 를 **항상 그대로** 찍습니다. 값 가림은 엔진(읽기 경로) 몫이고
        화면은 차단 **배너만** 얹습니다. `***` 같은 기호를 발명하지 않습니다.
G5 (A4) labels 의 emptyReportDefault·closeButton 삭제. 빈 상태·미생성 문구를 화면이 만들지 않습니다 — 미생성도 MonthlyReport 1건이 13항목 valueText 로 말합니다.
G6 (A5) StaleBanner: stale 이면 **제목은 항상** 표시하고, `asOf.staleLabel` 은 null 이 아닐 때만 그 아래에 표시합니다.
G7 (A6) SafetyBlockBanner: ① `FlagIds.markerOnly.contains(f.flagId)` 인 플래그는 배너에서 빼 **회색 정보 칩 줄**로 따로 그립니다 ② 나머지는 받은 순서 그대로
        상위 2개 + '+N'(지금 구현 유지) ③ `flag.label` 과 `flag.clearInstruction` 은 **두 개의 Text**(' · ' 로 이어 붙이지 않음) ④ chevron 버튼·onClearRouteTap 삭제.
G8 (A9) 에러 상태: 재시도 버튼 위에 마지막 성공 값의 `asOf.label`(`reportAsync.valueOrNull?.asOf.label`, 있으면) 표시. 재시도는 `ref.invalidate(monthlyReportProvider(yyyyMm))`.
G9 (A8) 테스트를 다시 쓰십시오 — **입력은 픽스처**입니다. golden_support.dart 의 `singleFixture`·`listFixture`·`fixtureEnvelope`·`FixedClock`·`kGoldenNowUtc`·
        `pumpForGolden`·`expectGolden`·`brightnessSuffix` 를 씁니다.
        · test/monthly_report_view_test.dart — 13항목 title 전수(예 `tester.view.physicalSize = const Size(390, 4000); devicePixelRatio = 1.0` 후 find, 또는 scrollUntilVisible) ·
          stale 제목(시계를 kGoldenNowUtc + 3일로) · 차단 배너 label(safety_states.json 3행) · 표식 칩(1행 SELF_AUDIT_DUE 는 배너가 아니라 칩).
          기대값은 픽스처에서 읽은 값으로 비교합니다(예 `find.text(report.items.first.title)`) — 테스트에도 한국어 리터럴을 쓰지 않습니다.
        · test/golden/s71_golden_test.dart — README 뼈대대로. 이름은 명세 지정: s71_normal · s71_partial_gap · s71_not_generated × light/dark = 6.
          입력: FixturePaths.m7M7Monthly202608 / m7M7MonthlyGap / m7M7MonthlyPending 을 `singleFixture(..., MonthlyReport.fromJson)` 로,
          안전 상태는 `SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[0])`, 시계는 `FixedClock(kGoldenNowUtc)`.
          PNG 는 만들 수 없으니 테스트 파일만 내십시오 — 최초 베이스라인은 발주자 PC 에서 1회 생성합니다.
G10 lint — 저장소는 `--fatal-infos` 입니다. 자주 걸리는 것: unnecessary_lambdas(티어오프) · prefer_final_locals · always_declare_return_types ·
        prefer_single_quotes · directives_ordering(dart: → package: → 상대 import, 각 묶음 알파벳순) · strict-inference/strict-raw-types(빈 리터럴은 `const <BlockFlag>[]` 처럼 타입 명시) · unawaited_futures.
G11 (권장) `Colors.amber.shade100` 같은 고정 밝은 색은 dark 골든에서 글자가 묻힙니다 — `Theme.of(context).colorScheme`(errorContainer/onErrorContainer ·
        surfaceContainerHighest 등)를 쓰십시오. 색 매핑은 재량이지만 light/dark 둘 다 읽혀야 합니다.
G12 lib/ui_analytics.dart 는 **기존 머리 주석을 지우지 말고** export 줄만 더하십시오. 기존 파일 원문:
        // ui_analytics — M7(성과·리밸런싱·플래너) 화면 패키지의 배럴.
        //
        // 🔴 의존은 domain_contracts · Flutter · Riverpod **만**이다(C-3).
        // 🔴 TWR·MWR·누적곱을 화면이 계산하지 않는다. 누적/비누적 토글도 엔진이 두
        //    시리즈를 주거나 cumulative 플래그로 재요청한다(C-4).
        // 🔴 결측(value == null)은 **보간하지 않고 공백으로** 그린다(C-10).
        // 🔴 손익 노출은 인터스티셜·격리·열람 기록 3종이 함께 있을 때만이다(결정 8).
        //
        // 화면 위젯은 lib/src/ 아래에 두고 공개할 것만 여기에서 export 한다.
        export 'l10n/labels.dart';
        (여기에 src export 를 추가)

■ 출력 형식 (웹)
파일별로 `경로` 한 줄 + **전체 코드**(부분 diff 금지). 낼 파일 — lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart ·
lib/src/widgets/stale_banner.dart · lib/src/widgets/safety_block_banner.dart · lib/src/widgets/trust_badge_view.dart ·
lib/src/screens/monthly_report_screen.dart · lib/ui_analytics.dart · test/monthly_report_view_test.dart · test/golden/s71_golden_test.dart.
내지 말 것 — pubspec.yaml · analysis_options.yaml · test/flutter_test_config.dart · test/golden/golden_support.dart · shift_tolerant_compare.dart · comparator_test.dart.
마지막에 ① PR 본문 5섹션(자체 점검은 프롬프트의 12항 — 코드에 실제로 있는 것만 [x]) ② 질문 표(inbox/README.md 형식 · Q2 부터) ③ 추측한 것 목록(정직하게 — 없으면 «없음»).
브랜치 이름은 `ui/m7-s71-monthly-report`, PR 제목은 `[M7] S7-1 월간 리포트 뷰어` 입니다.
```

---

## 3-1. 받아야 하는 것

파일 9개의 전체 코드 + PR 본문 5섹션 + 질문 표(Q2~) + 추측 목록. PNG·PR 은 오지 않습니다(웹 방식 — Claude 가 저장 → `format:fix` → analyze·test → 골든 6장 1회 생성·눈 검사 → 브랜치 푸시 → PR → 병합 검사까지 대행).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄) — Gemini 의 답 전체를 그 아래에 그대로 붙여넣습니다

```
R1-Gem-S71 재제출 결과(웹): 아래 전체 — 저장·검사·PR·병합 검사까지 해줘
```

## 5. 주의

- Gemini 의 답을 **자르지 말고 전부** 붙여넣어 주십시오(1회차는 중간에 끊겨 세 번에 나눠 왔습니다). 너무 길면 파일로 저장해 경로만 알려 주셔도 됩니다.
- 5분 눈 검사는 1회차와 같습니다 + M7 추가 1항(제외 4종: 종목 손익 순위·일간 손익 차트·반사실 손익·1개월 벤치마크 승패 강조가 코드에 없을 것).
