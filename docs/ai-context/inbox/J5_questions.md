# `J5_questions.md` — J-5 UNKNOWN 해소 보드 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 화면의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다.
>
> **R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 작성.
> **C4 R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 행 Q1~Q5 는 전부 종류 «추측»인데 `Q` 번호로 붙었다(규약 = 추측은 `A`). PR 본문이 번호로 참조하므로 **번호는 바꾸지 않는다 — 종류 칸이 정본**. C4 발견 행 = A1~A3 · 재제출 추측 행 = A4~. 다음 번호 = Q6·A4.

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| Q1 | J-5 | 추측 | `UnknownResolutionStep.state`의 4가지 `GateState` 값을 `exhaustive switch`로 처리 — `notApplicable`과 `unknown`을 다른 `stateLabel`로 표시(값은 DTO에서 온다) | GateState 렌더 | exhaustive switch | ✅ 답함 | 4값 exhaustive · unknown ≠ notApplicable. switch 가 고르는 것은 **아이콘**이고 문구는 DTO `stateLabel` 이다(질문 문장 보정) |
| Q2 | J-5 | 추측 | 단계 칸(`_StepRow`)의 탭은 `step.deepLink`가 non-null일 때만 활성화 — 현재 픽스처에서 전부 null이라 탭 테스트 없음. `j5_card_step_deeplink_tap` 골든도 없음 | 단계 칸 탭 | null이면 탭 없음 | ✅ 답함 | `step.deepLink` non-null 일 때만(카드 (3) · 02 §3-5 ⓑ) |
| Q3 | J-5 | 추측 | `_UnknownCard`에 `JournalEntryCard`를 쓰지 않고 직접 InkWell을 사용 — `JournalEntryCard(tappable: true)`는 `entry.detailDeepLink` 탭만 지원하는데 J-5 카드는 `elapsedText`·`effectLine`·`steps` 같은 추가 필드가 있어서 | 카드 구조 | 직접 구현 | ✅ 답함 | `JournalEntryCard` 미사용 = 카드 (3) 지시. 단 ⓒ `emphasized` 강조 누락은 A2(G3) |
| Q4 | J-5 | 추측 | 골든 높이 1600px에서 두 카드(`m6UnknownBoard2`)의 `nextBatchNoticeText`가 뷰포트 안에 들어감 — 높이 조정 불필요 | 골든 뷰포트 높이 | 1600px 유지 | ✅ 답함 | 1600 유지 맞다. `j5_long_open` 전제 대상 → A1(G8) |
| Q5 | J-5 | 추측 | `escalationLink` 버튼 레이블을 그대로(`link.label`) 사용 — 버튼 스타일은 `OutlinedButton` | 에스컬레이션 버튼 | OutlinedButton + link.label | ✅ 답함 | non-null 일 때만 · label 그대로(02 §3-5 ⓒ) · `OutlinedButton` 재량 |
| A1 | J-5 | 추측 | (R2 1회차 · C4 발견) `j5_long_open` 전제 대상이 `nextBatchNoticeText` 가 아니라 card-0 · 주석 자기모순 | 골든 전제 | — | 🔴 반려(재제출 G8) | 카드 (6) |
| A2 | J-5 | 추측 | (C4 발견) `emphasized` 강조 미구현(lib 에서 읽는 곳 0) | 계약 값 누락 | — | 🔴 반려(재제출 G3) | 02 §3-5 ⓒ + «(C4 R2 · 2026-09-24)» |
| A3 | J-5 | 추측 | (C4 발견) 재시도 미탭 · 카드별 세기·stateLabel/whyLine 누락 · 가짜 `Stream.error` 재사용 | 테스트 증명 범위 | — | 🔴 반려(재제출 G7) | 카드 테스트 목록 J-5 |
| A4 | J-5 | 추측 | (R2 재제출) `emphasized == true` 강조 모양 = `Card(shape: RoundedRectangleBorder(side: BorderSide(color: cs.error, width: 2)))` — escalationLink 와 별개 | G3 모양 선택 | cs.error 테두리 2px | ✅ 구현 완료 | G3 재제출에서 결정 — `RoundedRectangleBorder(side: BorderSide(color: cs.error, width:2))` |
