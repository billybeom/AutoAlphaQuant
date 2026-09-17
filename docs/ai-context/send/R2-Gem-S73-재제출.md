# 발송 패킷 R2-Gem-S73 — 재제출 (1회차 반려 · 2026-09-17 · 웹 채팅 방식)

> 만든 날 2026-09-17 · 1회차(같은 날 수신)의 C4 검사 결과가 **반려**여서 만든 패킷입니다. 프롬프트·규칙은 이전과 같고(`docs/ai-context/prompt_M7.md`) 이 패킷은 **반려 사유 + 고칠 것 + 출력 형식**만 담았습니다. 1회차 원문은 로컬 브랜치 `ui/m7-s73-drawdown-context`(커밋 `88428c5` · 미푸시)에 그대로 보관돼 있습니다.
> 이번 반려는 가볍습니다 — 기계 검사는 전부 통과했고 **S7-3b 는 합격**입니다. 고칠 파일은 **2개**(+ 테스트 1건 추가)입니다.

## 0. 한 줄 목적

같은 Gemini 채팅에서 S7-3 의 **값 3개 배치**만 고친 파일을 다시 받기(웹 방식 — 저장·포맷·검사·골든 PNG 생성·브랜치·PR 은 Claude 가 대행).

## 1. 어디에 보내나

**Gemini Pro 웹 채팅** — R2-Gem-S73 을 보낸 **같은 대화**에 이어서 보냅니다.

## 2. 먼저 첨부할 파일 (2개 · 전부 `C:\Work\Bob\AutoAlphaQuant\` 아래)

1. `docs/ai-context/inbox/S7-3_questions.md` ← 1회차 질문 2건의 답 + 검사가 찾은 A1~A5
2. `docs/ai-context/03_화면명세_M7_성과_리밸런싱_플래너.md` ← §7 에 「🔵 C4 R2-Gem-S73 반영」 4항 추가판

(픽스처는 첨부하지 않아도 됩니다 — 필요한 값을 아래 본문에 **그대로 옮겨** 두었습니다.)

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R2-Gem-S73 재제출 요청 — 1회차 판정: S7-3b 합격 · S7-3 반려(고칠 것 2가지). 프롬프트·규칙·범위는 이전과 같습니다.
방금 첨부한 2개 파일을 먼저 읽으십시오: ① S7-3_questions.md 의 «답» 칸(Q1·Q2·A1~A5) ② 03 §7 「🔵 C4 R2-Gem-S73 반영」 4항.

■ 잘된 것 — 그대로 유지하십시오 (이번에는 기계 검사가 전부 통과했습니다: analyze 0 · 자체 테스트 6/6)
의존 3패키지뿐 · 산술 0 · 한국어 리터럴은 labels.dart 에만 · 본문 위젯만 · 이동 버튼·콜백 0 · 값 문자열 그대로 · StaleBanner·SafetyBlockBanner 재사용 ·
rows 를 받은 순서·개수 그대로 · 중립색 막대 · null 인 줄 생략 · 스켈레톤·에러 상태 · 프로바이더 타입 명시 · 테스트 기대값을 픽스처에서 읽음.
contribution_screen.dart · analytics_providers.dart · ui_analytics.dart · contribution_view_test.dart · s73_golden_test.dart 는 **합격 — 다시 내지 마십시오.**

■ 왜 반려인가 — 골든 그림에서만 보이는 것 하나
세 값(currentDdText · maxDdText · tuwText)은 짧은 숫자가 아니라 **엔진이 완성한 문장**입니다. 픽스처 실물(그대로 옮김):

  m7/m7_dd_context_normal.json
    period_label            "최근 24개월"
    current_dd_text         "현재 낙폭 −2.1%"
    max_dd_text             "최대 낙폭 −6.4%"
    tuw_text                "회복까지 걸린 최장 기간 3개월"
    dd_normalized           0.21
    reference_band_text     "백테스트 참조 구간 −8% ~ −15%"
    reference_band_caveat_text  (없음 = null)

  m7/m7_dd_context_deep.json
    period_label            "최근 24개월"
    current_dd_text         "현재 낙폭 −13.1%"
    max_dd_text             "최대 낙폭 −15.8%"
    tuw_text                "회복까지 걸린 최장 기간 11개월"
    dd_normalized           0.83
    reference_band_text     "백테스트 참조 구간 −8% ~ −15%"
    reference_band_caveat_text  "최대낙폭은 관측된 하한이며 앞으로의 상한이 아닙니다."

1회차는 이 문장들을 3열 카드(Row + Expanded×3)에 넣고 FittedBox(scaleDown) 로 넘침을 막았습니다. 폰 폭 390px 에서 카드 안쪽은 98px 인데
"회복까지 걸린 최장 기간 11개월"은 16px 글꼴로 약 288px 이라 **0.34배 = 약 5px** 로 줄어 읽을 수 없습니다(앞의 두 값도 약 9px).
넘치지 않는 것과 읽히는 것은 다릅니다. 또 정적 제목 '현재 DD'·'최대 DD'·'TUW' 가 엔진 문장과 겹쳐 같은 말을 두 번 합니다
(03 §7 「컴포넌트」 줄의 그 이름은 문서가 값을 부르는 이름이지 화면 제목이 아닙니다 — 이 오해는 명세 탓이 절반이라 03 에 명문화했습니다).

■ 고칠 것
G1 (A1) drawdown_context_screen.dart — `_buildMetricCards` 를 **세로로 쌓은 전체 폭 3행**으로 바꾸십시오(예 Column(crossAxisAlignment: CrossAxisAlignment.stretch)
        안에 값마다 Card 또는 단순 Padding + Text 하나씩, 사이 간격 8). 각 행은 엔진 문장 **Text 하나**입니다(softWrap 기본값 — 긴 문장은 줄바꿈).
        🔴 FittedBox 를 쓰지 마십시오 — 엔진 문장을 줄이지 않습니다. ListView 안의 Column 에는 Expanded 를 두지 마십시오(높이 무한 오류).
G2 (A2) labels.dart — `currentDdTitle`·`maxDdTitle`·`tuwTitle` 3개를 **삭제**하십시오(정적 라벨은 staleBannerTitle·retryButton 2개로 복귀).
        `_buildSingleMetricCard` 의 title 매개변수도 없앱니다. 엔진 문자열이 이미 말한 것을 화면이 다시 말하지 않습니다.
G3 (선택) 하단 footer 의 asOf.label 은 상단 헤더와 같은 문자열이 두 번 나오는 것입니다 — 상단 하나만 남겨도 됩니다(contribution_screen.dart 는 합격이므로 그대로 둡니다).
G4 (A3) PR 본문 ③에는 **위 픽스처 값만** 적으십시오. 1회차 ③의 «-6.2% · -12.4% · 5개월 · 0.41» 은 픽스처에 없는 값이었습니다.
        보지 않은 것은 «미열람»이라고 쓰고, 가정한 것은 ⑤ «추측한 것 목록»에 적습니다.
G5 테스트 1건 추가 — test/drawdown_context_view_test.dart 에 «세 값 Text 의 조상에 FittedBox 가 없다»를 확인하는 testWidgets 를 더하십시오:
        expect(find.ancestor(of: find.text(deep.tuwText), matching: find.byType(FittedBox)), findsNothing);  (currentDdText·maxDdText 도 같은 방식)
        기존 테스트 4건은 그대로 두십시오(지금 전부 통과합니다). 테스트에 한국어 리터럴은 쓰지 않습니다(test 설명 문자열은 예외).

■ 1회차 질문의 답
Q1 range == null → 엔진 기본 구간입니다. 그 결과가 무엇인지는 periodLabel 이 말합니다("최근 24개월"). `DateRange? range`(기본 null) 유지.
Q2 `required DateRange range` 생성자 매개변수 유지. «어느 프리셋이 기본인가»는 01 §8 미결 33(DateRange.isDefault)이고 M2 가 곧 닫습니다 —
   그 뒤 상위(셸)가 watchRangePresets() 에서 isDefault 인 항목을 골라 넘깁니다. 화면은 날짜를 만들지 않습니다.
A5 막대 폭의 `.clamp(0.0, 1.0)` 은 렌더 가드로 **허용**입니다(그대로 두십시오).

■ 출력 형식 (웹)
**바꾼 파일만** 파일별로 `경로` 한 줄 + **전체 코드**로 내십시오(부분 diff 금지):
  lib/l10n/labels.dart · lib/src/screens/drawdown_context_screen.dart · test/drawdown_context_view_test.dart
마지막에 ① PR 본문 5섹션(③은 위 픽스처 값으로 · 자체 점검은 코드에 실제로 있는 것만 [x]) ② 새 질문이 있으면 질문 표(Q3 부터) ③ 추측한 것 목록(정직하게).
브랜치 `ui/m7-s73-drawdown-context`, PR 제목 `[M7] S7-3·S7-3b 드로다운 맥락·슬리브 기여` — 그대로입니다.
```

---

## 3-1. 받아야 하는 것

바꾼 파일 3개의 전체 코드(`labels.dart` · `drawdown_context_screen.dart` · `drawdown_context_view_test.dart`) + PR 본문 5섹션 + (있으면) 질문 표 + 추측 목록. 나머지 5개 파일은 1회차 것을 Claude 가 그대로 씁니다.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄) — Gemini 의 **가장 최근 답 전체**를 그 아래에 그대로 붙여넣습니다

```
R2-Gem-S73 재제출(웹): 아래 전체 — 저장·검사·PR·병합 검사까지 해줘
```

## 5. 주의

- 붙여넣기 전 확인 2가지: ① 복사한 것이 **가장 최근 답**인가(코드에 `FittedBox` 가 없고 `labels.dart` 의 라벨이 2개) ② 파일 경로 줄이 3개 있는가.
- Gemini 가 8개 파일을 전부 다시 내도 괜찮습니다 — Claude 가 바뀐 것만 골라 씁니다.
