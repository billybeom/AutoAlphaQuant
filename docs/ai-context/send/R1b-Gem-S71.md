# 발송 패킷 R1b-Gem-S71 — S7-1 월간 리포트 «완성» + S7-3b 결측 행 (계약 v1.1 · 웹 채팅 방식)

> 만든 날 2026-09-17 · 원문 = `11_앱설계/12_AI별_요청_스크립트.md`(카드 R3-Gem-S7x 의 ①② = 이 패킷) · 사전 조건 «R2-Gem-S73 병합»(PR #5 ✅) + «계약 v1.1 이 `origin/main` 에 있음»(PR #4 ✅) — **둘 다 충족**.
> 프롬프트·규칙은 이전과 같습니다(`docs/ai-context/prompt_M7.md`). 같은 Gemini 대화에 이어서 보내므로 07 원문은 다시 붙이지 않습니다.
> 🔵 R2 의 교훈 반영: 이 패킷은 이 카드가 쓰는 **모든 픽스처의 표시 문자열**과 **바뀐 계약 타입**을 본문에 그대로 실었습니다(웹 방식은 저장소를 못 읽습니다).

## 0. 한 줄 목적

R1 에서 «계약이 없어서» 미뤄 둔 S7-1 의 나머지(항목 「자세히」 · 미생성 D-day · 헤더 생성일/해시 · 이동) + S7-3b 의 «산출 불가» 행을 계약 v1.1 위에서 마무리해 받기.

## 1. 어디에 보내나

**Gemini Pro 웹 채팅** — S7-1·S7-3 을 작업한 **같은 대화**에 이어서.

## 2. 먼저 첨부할 파일 (10개 · 전부 `C:\Work\Bob\AutoAlphaQuant\` 아래 — 병합본이라 Gemini 가 기억하는 것과 줄바꿈이 조금 다릅니다)

1. `docs/ai-context/03_화면명세_M7_성과_리밸런싱_플래너.md` ← §3 「🆕 계약 v1.1 — S7-1 R1b 범위」 · §8 「결측 슬리브」
2. `packages/domain_contracts/lib/src/navigation/app_links.dart` ← 내비게이션 계약(읽기 전용)
3. `packages/domain_contracts/lib/testing.dart` ← 테스트 받침대(읽기 전용)
4. `packages/ui_analytics/lib/src/screens/monthly_report_screen.dart`
5. `packages/ui_analytics/lib/src/screens/contribution_screen.dart`
6. `packages/ui_analytics/lib/src/widgets/safety_block_banner.dart`
7. `packages/ui_analytics/lib/src/widgets/trust_badge_view.dart`
8. `packages/ui_analytics/lib/src/providers/analytics_providers.dart`
9. `packages/ui_analytics/test/monthly_report_view_test.dart`
10. `packages/ui_analytics/test/golden/s71_golden_test.dart`

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R1b-Gem-S71 — S7-1 월간 리포트 «완성» + S7-3b «산출 불가» 행. 프롬프트·규칙은 이전과 같습니다. S7-3·S7-3b 는 방금 병합됐습니다(수고하셨습니다 — 통합 수정 0건이었습니다).
방금 첨부한 10개 파일이 **지금 main 에 있는 병합본**입니다. 이 파일들을 고쳐서 내십시오(기억 속 옛 버전이 아니라).

■ 계약이 v1.1 로 바뀌었습니다 — 이번 카드에 필요한 것만 (정본은 코드 · 아래는 그 원문 발췌)
[1] 내비게이션 — «링크는 데이터로 온다» (첨부 2 app_links.dart)
    abstract interface class AppLinkOpener { void open(String link); }   // 구현은 셸(M8) · 화면은 주입받아 부르기만
    화면 규칙 4조: ① 링크 필드가 null 이면 그 버튼은 **부재**(비활성·자리표시자 금지) ② 링크 문자열을 파싱·분기하지 않음
    ③ AppRoutes 의 `:param` 패턴에 값을 끼워 링크를 조립하지 않음 ④ 파라미터 없는 고정 목적지는 **명세가 그 버튼을 명시한 경우에만** AppRoutes 상수 그대로.
    🔴 lib/ 코드에 'aaq://…'·'handbook://…' 리터럴이 있으면 CI 경계 검사가 실패시킵니다. 테스트에도 링크 리터럴을 적지 않습니다(픽스처에서 읽은 값과 비교).
[2] DTO 새 필드(전부 nullable — null 이면 그 줄·그 버튼이 없습니다)
    MonthlyReport   + String? pendingNoticeText   // 미생성 달의 한 문장. non-null 이면 헤더 아래에 그대로
                    + String? generatedAtText     // "2026-09-01 생성"
                    + String? configHash          // 모노스페이스로 **표시만**(다른 값과 비교 금지). 길면 앞 12자 + '…' 같은 축약은 하지 말고 그대로 한 줄(ellipsis 허용)
    ReportItem      + String? detailDeepLink      // 🔴 non-null 인 항목에만 「자세히」. order·code·모드로 고르지 않음
    LedgerTrustBadge  String? actionDeepLink      // (v1.0 부터 있던 필드) non-null 이면 배지 안에 이동 버튼
    BlockFlag       + String? clearDeepLink       // 차단 배너의 이동 화살표. null 이면 화살표 **부재**
                    + String? checkpointLabel     // 배너 보조 줄("마지막 검증 08-30 18:10"). null 이면 없음
    ContributionRow + String? unavailableLabel    // 🔴 non-null 이면 **막대를 그리지 않고** 이 문장을 그림(normalized 는 0.0 으로 옴). 재정규화 금지
[3] 테스트 받침대(첨부 3 testing.dart) — import 'package:domain_contracts/testing.dart';
    class _FakePerf extends UnimplementedPerformanceRepository { @override …필요한 메서드만… }   // implements 로 통째 구현 금지
    RecordingLinkOpener — open() 에 넘어온 문자열을 `opened` 리스트에 순서대로 기록

■ 할 일
ⓐ 주입 프로바이더 1개 추가(analytics_providers.dart): 
     final Provider<AppLinkOpener> analyticsLinkOpenerProvider = Provider<AppLinkOpener>((ref) { throw UnimplementedError('analyticsLinkOpenerProvider must be overridden'); });
ⓑ S7-1 항목 「자세히」 — `item.detailDeepLink != null` 인 항목 카드에만 작은 텍스트 버튼(정적 라벨 「자세히」). 탭 = `ref.read(analyticsLinkOpenerProvider).open(item.detailDeepLink!)`.
   🔴 Row 안의 긴 문자열은 계속 Expanded/Flexible — 버튼을 넣어도 390px 에서 어떤 픽스처 문자열도 넘치지 않아야 합니다(값 아래 줄에 버튼을 두는 배치가 안전합니다).
ⓒ S7-1 미생성 고지 — `report.pendingNoticeText` 가 non-null 이면 헤더 바로 아래에 한 줄 그대로. (D-day 를 화면이 만들지 않습니다.)
ⓓ S7-1 헤더 — `generatedAtText`(있으면 asOf.label 옆/아래) · `configHash`(있으면 monospace 작은 글씨 한 줄). 둘 다 null 이면 그 줄 없음.
ⓔ 신뢰 배지(TrustBadgeView) — `trust.actionDeepLink != null` 이면 배지 안에 이동 버튼(정적 라벨 「조치 보기」). `trust.upgradeHint` 도 non-null 이면 그대로 한 줄(지금 안 그리고 있으면 추가).
   TrustBadgeView 는 StatelessWidget 이므로 `onOpenLink`(void Function(String)?) 콜백을 매개변수로 받아 화면이 opener 를 연결해 주는 모양이 간단합니다.
ⓕ 차단 배너(SafetyBlockBanner) — 각 차단 플래그에 `checkpointLabel`(non-null 이면 clearInstruction 아래 한 줄) · `clearDeepLink`(non-null 이면 오른쪽 chevron 아이콘 버튼, 탭 = open).
   같은 방식으로 `onOpenLink` 콜백. 🔴 null 이면 chevron 을 **그리지 않습니다**. 표식 칩(markerOnly)은 링크가 있어도 칩 탭으로 열어도 되고 안 열어도 됩니다 — 이번에는 **열지 않음**으로 통일.
   S7-3·S7-3b·S7-1 세 화면 모두 이 배너를 쓰므로 세 화면에서 콜백을 연결하십시오(drawdown_context_screen.dart 는 첨부하지 않았습니다 — 바꾼 줄만 있는 전체 파일로 다시 내 주십시오. 기억하는 2회차 코드에 콜백 연결 1곳만 더하면 됩니다).
ⓖ 「지난 리포트」 — S7-1 하단에 텍스트 버튼(정적 라벨 「지난 리포트」). 탭 = `open(AppRoutes.reportArchive)`. 이 버튼은 명세(03 §3)가 명시한 고정 목적지라 규칙 ④에 해당합니다 — AppRoutes 상수를 쓰는 **유일한** 자리입니다.
ⓗ S7-3b 산출 불가 행 — `row.unavailableLabel != null` 이면 그 행은 제목(label) + contributionText + **막대 대신 unavailableLabel 문장**. 다른 행은 그대로(재정규화 없음).
ⓘ 값 가림은 여전히 화면 일이 아닙니다 — 가림 픽스처는 문자열이 **이미 가려져** 옵니다. 화면 코드 변화 0 이 정답이고, 골든으로 그 사실만 확인합니다.

■ 픽스처 실물 — 이 카드가 쓰는 표시 문자열 **전부** (FixturePaths 상수 · 그대로 옮김)
m7M7Monthly202608 (m7/m7_monthly_2026_08.json) — yyyy_mm "2026-08" · as_of.label "리포트 기준 2026-08-31" · generated_at_text "2026-09-01 생성" · config_hash "cfg_fake_0000000000000000"
   · pending_notice_text null · backdate_footnote null · 13항목 중 링크가 있는 것 3개:
     ④ "최대 낙폭" / "−6.4%" / detail_deep_link 있음   ⑤ "회복까지 걸린 기간" / "최장 3개월" / 있음   ⑧ "규칙 이행" / "규칙대로 21건 · 재량 1건 · 이행률 88%" / 있음   (나머지 10개는 null)
   · trust: label "대사 완료" · consequence_line "브로커 원장과 수량·현금이 맞습니다." · action_deep_link null · upgrade_hint null
   · goal_line "목표 경로 대비 앞서 있습니다. 앞으로의 약속은 아닙니다." · disclosure_view_count_text "이번 달 2번 열어 보셨습니다"
m7M7MonthlyGap — generated_at_text·config_hash 위와 같음 · 링크는 ⑧ 하나 · backdate_footnote "전월에 소급 정정 1건이 있었습니다. 마감된 달은 다시 계산하지 않습니다."
   · trust: label "자가 보고" · consequence_line "그 달의 원장은 자가 보고 상태였습니다." · upgrade_hint "증권사 연결을 마치면 대사 등급으로 올라갑니다." · action_deep_link null
m7M7MonthlyPending — pending_notice_text "이번 달 리포트는 9월 1일 생성일에 만들어집니다 · D-4" · generated_at_text null · config_hash null · 링크 0개
   · 13항목 value_text 는 전부 "이번 달 리포트는 생성일에 만들어집니다" · goal_line "아직 마감되지 않았습니다."
m7M7MonthlyMaskedIntegrity 🆕 — 13항목 value_text 전부 "숨김 — 원장 무결성 점검 중" · 링크 0개 · goal_line "원장 무결성 점검이 끝날 때까지 표시하지 않습니다."
   · trust: label "검증 불가" · consequence_line "원장을 믿을 수 없어 수치를 숨겼습니다." · action_deep_link **있음**
m7M7MonthlyMaskedRecon 🆕 — ⑦ 만 "회계 기준 A 20.0%? · B 42.0%? · C 32.0%? / 엔진 열 기준 A 24.0%?" + note_text "브로커 원장과 어긋난 종목이 있어 비중이 미확정입니다." · 나머지는 2026_08 과 같음
   · trust: label "어긋남 확인 중" · consequence_line "브로커 원장과 수량이 어긋난 종목이 있습니다." · action_deep_link **있음**
m7M7ContribPartial 🆕 (m7/m7_contrib_partial.json) — period_label "2026년 8월" · as_of.label "기여 분해 기준 2026-08-31"
   · "A · 국내 지수 ETF" "+0.42%p" 0.31 / "B · 해외 지수·금 ETF" "+0.71%p" 0.52 / "C · 방어 자산" "산출 불가" 0.0 + unavailable_label "8월 12~14일 가격 결측 — 이 슬리브는 산출할 수 없습니다"
   · method_note_text "산출할 수 없는 슬리브는 비워 둡니다. 나머지를 100%로 다시 맞추지 않습니다." · fx_note_text (3sleeve 와 같음)
safetyStates (safety_states.json) — 0행: 플래그 없음 / 1행: 표식 "분기 실사 기한이 다가옵니다"(링크 있음)
   · 3행: "브로커 원장과 어긋납니다"(clear_deep_link 있음 · checkpoint 없음) + "일지가 비어 있습니다"(clear_deep_link 있음)
   · 4행: "원장 무결성 점검이 필요합니다" · clear_instruction "복구 위저드에서만 해소됩니다." · checkpoint_label "마지막 검증 08-30 18:10" · clear_deep_link 있음
   · 2행: "TIER B 판정이 남아 있습니다" — clear_deep_link **null**(화살표 부재 확인용)
(링크의 실제 문자열은 일부러 적지 않았습니다 — 코드·테스트에 옮겨 적을 일이 없습니다. 테스트는 `item.detailDeepLink!` 처럼 픽스처에서 읽은 값과 비교합니다.)

■ 테스트·골든
· 가짜는 `extends UnimplementedPerformanceRepository`(기존 테스트의 implements 가짜도 이참에 바꾸십시오 — 메서드 목록을 다 적을 필요가 없어집니다).
· 링크: `analyticsLinkOpenerProvider.overrideWithValue(opener)`(opener = RecordingLinkOpener()) → 탭 → `expect(opener.opened, <String>[normal.items[3].detailDeepLink!])` 식.
· 단위 테스트 최소: ① 링크 있는 항목에만 「자세히」(2026_08 = 3개 · pending = 0개 — 개수도 픽스처에서 세어 비교: `report.items.where((i) => i.detailDeepLink != null).length`)
  ② 「자세히」 탭 → 그 항목의 링크가 그대로 기록 ③ pendingNoticeText 표시/미표시 ④ generatedAtText·configHash 표시/미표시 ⑤ trust.actionDeepLink 버튼 유무(masked_integrity 있음 / 2026_08 없음)
  ⑥ 배너 chevron: safety 4행 있음·탭 링크 기록 / 2행 없음 ⑦ checkpointLabel 표시(4행) ⑧ 「지난 리포트」 탭 → `AppRoutes.reportArchive` 기록
  ⑨ S7-3b partial: unavailableLabel 문장 표시 + 그 행에 막대 없음(예: 막대를 감싼 위젯에 Key 를 주고 개수 = rows 중 unavailableLabel == null 인 수)
· 골든(이름 지정): 기존 `s71_normal`·`s71_partial_gap`·`s71_not_generated` 는 표시가 늘어나므로 **다시 찍힙니다**(Claude 가 대행 · CI 는 golden:approved 라벨로 통과 — 신경 쓰지 않아도 됩니다).
  새로 3종: `s71_masked_integrity`(MaskedIntegrity + safety 4행) · `s71_masked_recon`(MaskedRecon + safety 3행) · `s73b_partial`(ContribPartial + safety 0행) × light/dark.
  s71 3종은 s71_golden_test.dart 에, s73b_partial 은 s73_golden_test.dart 에 추가(s73_golden_test.dart 는 기억하는 파일에 testWidgets 1개를 더한 전체 파일로).

■ 그대로인 것
본문 위젯만 · 의존 3패키지 · 산술 0 · 한국어 리터럴은 labels.dart 에만(새 정적 라벨 3개: 「자세히」·「조치 보기」·「지난 리포트」) · 값 문자열 그대로 · 엔진 문장을 FittedBox 로 줄이지 않음 ·
픽스처·하네스·pubspec 은 내지 않음 · lint(--fatal-infos) 주의 항목은 R2 와 같음.

■ 출력 형식 (웹)
**바꾼·새 파일만** 파일별로 `경로` 한 줄 + 전체 코드(부분 diff 금지). 예상 목록:
  lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart · lib/src/widgets/safety_block_banner.dart · lib/src/widgets/trust_badge_view.dart ·
  lib/src/screens/monthly_report_screen.dart · lib/src/screens/contribution_screen.dart · lib/src/screens/drawdown_context_screen.dart ·
  test/monthly_report_view_test.dart · test/contribution_view_test.dart · test/drawdown_context_view_test.dart(가짜를 받침대로 바꾸는 경우) ·
  test/golden/s71_golden_test.dart · test/golden/s73_golden_test.dart
마지막에 ① PR 본문 5섹션 — 🔴 ③ «스크린샷 서술»에는 **이 패킷에 실린 값만** 적고, 패킷에 없는 값은 지어내지 말고 «미열람»이라고 쓰십시오(R2 2회차 ③에 S7-3b 값이 지어져 있었습니다)
② 새 질문이 있으면 질문 표 ③ 추측한 것 목록(정직하게).
브랜치 `ui/m7-s71-complete`, PR 제목 `[M7] S7-1 완성·S7-3b 결측 행(계약 v1.1)`.
```

---

## 3-1. 받아야 하는 것

바꾼·새 파일의 전체 코드(약 10~12개) + PR 본문 5섹션 + (있으면) 질문 표 + 추측 목록. 골든 PNG(기존 6장 재생성 + 신규 6장)·PR·`golden:approved` 라벨은 Claude 가 대행합니다.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄) — Gemini 의 **가장 최근 답 전체**를 그 아래에 그대로 붙여넣습니다

```
R1b-Gem-S71 결과(웹): 아래 전체 — 저장·검사·PR·병합 검사까지 해줘
```

## 5. 주의

- 답이 길어 Gemini 가 중간에 끊으면 「이어서」라고 한 번 더 보내고, **두 답을 순서대로 이어 붙여** 주십시오(또는 메모장에 모아 `C:\Work\Bob\gemini_s71b.md` 로 저장하고 경로만 알려 주셔도 됩니다).
- 5분 눈 검사 추가 2항: ① 코드에 `aaq://` 글자가 없을 것 ② `order == 5` 같은 순번 비교가 없을 것.
