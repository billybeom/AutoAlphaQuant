# `J3_questions.md` — J-3 사전 저널 폼 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 화면의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다.
>
> **R2-Bob-J2J3 1회차(2026-09-24 · 브랜치 `ui/m6-j2-detail`)** — Bob 작성.

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| Q1 | J-3 | 추측 | `submitJournalDraft`의 `Future`가 에러로 끝났을 때 계약에 명시된 동작이 없다 — 입력값을 유지하고 제출 전 상태(문구 없음)로 돌아가는 것으로 구현함 | 에러 처리 | 에러 무시·입력 유지 | ⬜ 미확인 | |
| Q2 | J-3 | 추측 | 드롭다운을 `DropdownButtonFormField` 대신 `DropdownButton`으로 구현 — `DropdownButtonFormField`의 `value` 파라미터가 `deprecated_member_use` analyzer 경고를 내어 변경함 | 인용 규칙 드롭다운 | DropdownButton 사용 | ⬜ 미확인 | |
| Q3 | J-3 | 추측 | `REQUESTED`·`RECEIVED`·`STALE_CONTEXT`·`HELD_FOR_INTEGRITY`·`PENDING_LEASE_CONFIRM`·`NO_OPERATOR` 상태를 "잠금"으로 처리해 제출 버튼을 숨기고 입력란을 비활성화함 | 잠금 상태 범위 | 보류 4 + requested + received | ⬜ 미확인 | |
| Q4 | J-3 | 추측 | `REJECTED`·`EXPIRED` 상태는 재편집·재제출 가능으로 처리 — 입력값은 그대로 보존되고 제출 버튼이 다시 활성화됨 | 거부·만료 후 재제출 | 재편집 허용 | ⬜ 미확인 | |
| Q5 | J-3 | 추측 | `pledgeLines`가 0줄인 경우 서약 블록 전체를 렌더링하지 않음 — `Key('j3-pledge-block')` 자체가 없어짐 | 빈 서약 처리 | 부재 처리 | ⬜ 미확인 | |
| Q6 | J-3 | 추측 | `commandId` 구독(`watchCommand`)을 `dispose`에서 `cancel`하는 `StreamSubscription` 패턴 사용 | 명령 구독 정리 | dispose에서 cancel | ⬜ 미확인 | |
| Q7 | J-3 | 추측 | 골든 높이 1600px에서 모든 J-3 픽스처의 제출 버튼이 뷰포트 안에 들어감 — 높이 조정 불필요 | 골든 뷰포트 높이 | 1600px 유지 | ⬜ 미확인 | |
| Q8 | J-3 | 추측 | `spec.noticeLine` 표시 위치를 입력 영역 바로 앞에 배치 — 카드에 위치 규정 없어 임의 선택 | noticeLine 위치 | 입력 영역 위 | ⬜ 미확인 | |
