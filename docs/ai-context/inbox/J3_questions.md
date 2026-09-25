# `J3_questions.md` — J-3 사전 저널 폼 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 화면의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다.
>
> **R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 작성.
> **C4 R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 행 Q1~Q8 은 전부 종류 «추측»인데 `Q` 번호로 붙었다(규약 = 추측은 `A`). PR 본문과 코드 주석(`journal_draft_form.dart` 제출 catch 의 «J3_questions Q1» — 재제출 G6)이 번호로 참조하므로 **번호는 바꾸지 않는다 — 종류 칸이 정본**. C4 발견 행 = A1~A9 · 재제출 추측 행 = A10~. 다음 번호 = Q9·A10.

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| Q1 | J-3 | 추측 | `submitJournalDraft`의 `Future`가 에러로 끝났을 때 계약에 명시된 동작이 없다 — 입력값을 유지하고 제출 전 상태(문구 없음)로 돌아가는 것으로 구현함 | 에러 처리 | 에러 무시·입력 유지 | ✅ 답함(동작 허용) · 01 §8 미결 51 ①②③ 결정(2026-09-24) · ④ ⏭ R2b | 입력 유지 + 제출 전 상태는 카드 (5) 대로 허용. `Future` 에러 = «로컬 큐 미적재(명령 없음)»뿐(01 §4-2 «Future 의 에러는 «접수 실패»다»). `try` 는 `submitJournalDraft` 대기 하나만 · 보고 = `FlutterError.reportError` · 제출 중(재제출 포함) = 잠금 + 버튼 비활성 · 구독 에러 = 마지막 접수증 유지 + 보고 → 재제출 G5·G6 · 01 §11-10 `J-3` 상태 표 🆕 2행 · 02 §3-3 ⓒ. 접수 실패 안내 1줄은 R2b(미결 51 ④) |
| Q2 | J-3 | 추측 | 드롭다운을 `DropdownButtonFormField` 대신 `DropdownButton`으로 구현 — `DropdownButtonFormField`의 `value` 파라미터가 `deprecated_member_use` analyzer 경고를 내어 변경함 | 인용 규칙 드롭다운 | DropdownButton 사용 | ✅ 답함 | 위젯 종류는 카드가 정하지 않았다(허용). 참고: `DropdownButtonFormField` 는 `initialValue` 로 경고 없이 유지할 수 있었다. 밑줄 겹침은 A7(선택) |
| Q3 | J-3 | 추측 | `REQUESTED`·`RECEIVED`·`STALE_CONTEXT`·`HELD_FOR_INTEGRITY`·`PENDING_LEASE_CONFIRM`·`NO_OPERATOR` 상태를 "잠금"으로 처리해 제출 버튼을 숨기고 입력란을 비활성화함 | 잠금 상태 범위 | 보류 4 + requested + received | ✅ 답함 | 6상태 잠금 = 01 §11-10 표 그대로. `_isLocked` 의 `_ =>` 는 A4(재제출 G9 · 01 §7 C-12 «(C4 R2)» 한 구 · 02 §3-3 ⓔ) |
| Q4 | J-3 | 추측 | `REJECTED`·`EXPIRED` 상태는 재편집·재제출 가능으로 처리 — 입력값은 그대로 보존되고 제출 버튼이 다시 활성화됨 | 거부·만료 후 재제출 | 재편집 허용 | ✅ 답함 | rejected·expired = 값 그대로 재편집·재제출(01 §11-10 · §10-8). EXPIRED 증명 누락은 A5(G7) |
| Q5 | J-3 | 추측 | `pledgeLines`가 0줄인 경우 서약 블록 전체를 렌더링하지 않음 — `Key('j3-pledge-block')` 자체가 없어짐 | 빈 서약 처리 | 부재 처리 | ✅ 답함 | 0줄이면 블록·Key 부재(01 §11-3 · DTO 주석) · «순서대로» 단언은 G7 |
| Q6 | J-3 | 추측 | `commandId` 구독(`watchCommand`)을 `dispose`에서 `cancel`하는 `StreamSubscription` 패턴 사용 | 명령 구독 정리 | dispose에서 cancel | ✅ 답함 | dispose 에서 cancel · 교체 전 cancel — 맞다(카드 (5)) |
| Q7 | J-3 | 추측 | 골든 높이 1600px에서 모든 J-3 픽스처의 제출 버튼이 뷰포트 안에 들어감 — 높이 조정 불필요 | 골든 뷰포트 높이 | 1600px 유지 | ✅ 답함 | 1600 유지 맞다(PNG 잘림 없음). 위치 전제가 `j3_rejected` 에만 있음 → A6(G8) |
| Q8 | J-3 | 추측 | `spec.noticeLine` 표시 위치를 입력 영역 바로 앞에 배치 — 카드에 위치 규정 없어 임의 선택 | noticeLine 위치 | 입력 영역 위 | ✅ 답함 | 위치 무규정(02 §3-3 ⓑ) · 입력 영역 앞 = 취지에 맞다. executed 의 stateLabel 위치 차이는 기록만 |
| A1 | J-3 | 추측 | (R2 1회차 · C4 발견) 에러 상태에 마지막 성공 `asOf.label` 없음(`journal_draft_form.dart:187-190`) | 공통 상태 — 에러 | — | 🔴 반려(재제출 G9) | 카드 (5) · 01 §11-10 공통 |
| A2 | J-3 | 추측 | (C4 발견) `try` 가 `watchCommand` 구독까지 감싸 `StateError` 를 삼킴 · 테스트 가짜가 같은 `Stream.value` 를 재사용 | 제출 에러 처리 · 테스트 가짜 | — | 🔴 반려(재제출 G6) | 01 §8 미결 51 ①③ · 01 §4-2 인용 블록 |
| A3 | J-3 | 추측 | (C4 발견) 제출 대기 중 버튼 활성(이중 제출) · 대기 중 입력 잠금을 질문 파일에 안 적음 | 제출 중 창 | — | 🔴 반려(재제출 G5) | 01 §8 미결 51 ② · 01 §11-10 J-3 상태 표 «제출 중» 행 |
| A4 | J-3 | 추측 | (C4 발견) `_isLocked` 의 switch 식 `_ => false`(`journal_draft_form.dart:130`) | C-12 | — | 🔴 반려(재제출 G9) | 카드 (5) · 01 §7 C-12 · 02 §3-3 ⓔ «(C4 R2)» |
| A5 | J-3 | 추측 | (C4 발견) EXPIRED·기록된 입력값·noticeLine·서약 순서·차단 2장·잠금 중 드롭다운 증명 누락 | 테스트 증명 범위 | — | 🔴 반려(재제출 G7) | 카드 테스트 목록 J-3 |
| A6 | J-3 | 추측 | (C4 발견) 골든 위치 전제가 `j3_rejected` 에만 | 골든 전제 | — | 🔴 반려(재제출 G8) | 카드 (6) |
| A7 | J-3 | 추측 | (C4 발견) 선택된 긴 인용 규칙 label 둘째 줄이 드롭다운 밑줄에 닿음(`j3_rejected`) | 390px 레이아웃 | — | 🟡 확인 중(재제출 G9 · 선택) | 카드 규칙 9 |
| A8 | J-3 | 추측 | (C4 발견) 제출 조건 `trim` 누락(`journal_draft_form.dart:113` — 공백 40자로 활성) | 제출 조건 | — | 🔴 반려(재제출 G5) | 01 §11-10 J-3 · 02 §3-3 ⓓ |
| A9 | J-3 | 추측 | (C4 발견) 이탈 배지 `Chip` 이 긴 `deviation.label` 끝을 fade 로 자름 | 390px 레이아웃 | — | 🔴 반려(재제출 G9) | 카드 규칙 9 «말줄임은 configHash 1줄만» |
| A10 | J-3 | 추측 | (R2 재제출) 이탈 배지를 `DecoratedBox + Padding + Text` 로 바꿔 줄바꿈 허용 · `_isLocked` switch 에 `rejected`, `expired`, `executed` 명시(와일드카드 제거) | G9 모양 선택 | DecoratedBox·명시 switch | ✅ 구현 완료 | G9 재제출에서 결정 — `DecoratedBox(border: outline)` · switch 전수 3값 명시 |
