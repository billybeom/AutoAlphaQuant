# `J5_questions.md` — J-5 UNKNOWN 해소 보드 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 화면의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다.
>
> **R2-Bob-J2J3 1회차(2026-09-24 · 브랜치 `ui/m6-j2-detail`)** — Bob 작성.

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| Q1 | J-5 | 추측 | `UnknownResolutionStep.state`의 4가지 `GateState` 값을 `exhaustive switch`로 처리 — `notApplicable`과 `unknown`을 다른 `stateLabel`로 표시(값은 DTO에서 온다) | GateState 렌더 | exhaustive switch | ⬜ 미확인 | |
| Q2 | J-5 | 추측 | 단계 칸(`_StepRow`)의 탭은 `step.deepLink`가 non-null일 때만 활성화 — 현재 픽스처에서 전부 null이라 탭 테스트 없음. `j5_card_step_deeplink_tap` 골든도 없음 | 단계 칸 탭 | null이면 탭 없음 | ⬜ 미확인 | |
| Q3 | J-5 | 추측 | `_UnknownCard`에 `JournalEntryCard`를 쓰지 않고 직접 InkWell을 사용 — `JournalEntryCard(tappable: true)`는 `entry.detailDeepLink` 탭만 지원하는데 J-5 카드는 `elapsedText`·`effectLine`·`steps` 같은 추가 필드가 있어서 | 카드 구조 | 직접 구현 | ⬜ 미확인 | |
| Q4 | J-5 | 추측 | 골든 높이 1600px에서 두 카드(`m6UnknownBoard2`)의 `nextBatchNoticeText`가 뷰포트 안에 들어감 — 높이 조정 불필요 | 골든 뷰포트 높이 | 1600px 유지 | ⬜ 미확인 | |
| Q5 | J-5 | 추측 | `escalationLink` 버튼 레이블을 그대로(`link.label`) 사용 — 버튼 스타일은 `OutlinedButton` | 에스컬레이션 버튼 | OutlinedButton + link.label | ⬜ 미확인 | |
