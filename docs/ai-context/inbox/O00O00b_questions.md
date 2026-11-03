# `O00O00b_questions.md` — O-00 첫 실행 3갈래 · O-00b 운영 방식 선택 질문·추측 접수표

> 형식 정본 = `inbox/README.md`. 한 카드의 질문은 라운드가 바뀌어도 **이 파일에 쌓인다**(새 파일 금지). 답이 달린 행은 지우지 않고 상태만 바꾼다.
> 🔴 «답» 칸은 결론이 아니라 **어느 문서 어느 절이 갱신됐는가**다. 표는 색인이지 정본이 아니다 — 정본은 01 §2-11 · §4-1 · §4-3 · §6-3 · 계약 v1.16 절(01 §25 · R15 선행 M2 보강 · ✅ 병합 PR #96 squash `dd9e162`) · 04 §9-1 · §9-1b 와 `packages/domain_contracts/` 코드.
>
> **R15a-Bob-O00O00b**(2026-11-02 조립 · ~~`send/R15a-Bob-O00O00b.md`~~ → `send/_완료/R15a-Bob-O00O00b.md` · ✅ 선행 = 계약 v1.16 보강(R15 선행 M2 · R15a 몫 G1~G7 · PR #96 `dd9e162` · 2026-11-03) · ✅ 드라이런 · ✅ 발주자 확인 ①~⑬ · ~~▶ 보낼 수 있음(「푸시해」 뒤)~~ → ✅ 병합(PR #99 `940082c` · 아래 줄)) — 다음 번호 = **Q1 · A5**(A1~A4 = 골든 dy «측정:» 행 · 카드 «■ 질문 파일» 상자 · C4 R15a §6 — 머리말 미갱신을 병합 기록이 고침).
> **R15a-Bob-O00O00b ✅ 병합(2026-11-04 · PR #99 squash `940082c` · C4 1회차 `8c89b14` merge-with-fixes(C4 정정 1곳))** — A1~A4(골든 dy)는 C4 재실측과 같다(A 행 괄호 꼴 = 카드 틀 그대로 · light = dark). 질문 0.
> 🔴 실키·앱키·토큰·복구 코드·계좌번호는 이 파일에도 적지 않는다(prompt_M8 85~86 · 시크릿 입력 = `SecretField` 몫).

| 번호 | 카드ID | 종류 | 질문·추측 | 막힌 곳 | 제안 | 상태 | 답 |
|---|---|---|---|---|---|---|---|
| A1 | R15a-Bob-O00O00b | 추측 | 측정: o00_start dy 실측값 (light=308.0, dark=308.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ✅ 답함(문서 갱신) | ✅ 재측정 일치 — C4 재실측(`lessThan(0)` · light = dark · 머리 dy 0.0)과 같다. 병합본 기록 = `packages/ui_shell/test/golden/README.md` «🆕 R15» 절 «R15a 병합본 실측» 줄(PR #99 squash `940082c` · 2026-11-04) · o00_start 맨 아래 308 < 844(`kGoldenPhoneSize` 844 = 카드 확정값 · 높이 무수정 · 여유 536px) · 드라이런 `dry/r15v2-1` 값과 같음 · PNG = 드라이런 바이트 같음 — 측정값 기록이며 추측 아님 |
| A2 | R15a-Bob-O00O00b | 추측 | 측정: o00b_unselected dy 실측값 (light=584.0, dark=584.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ✅ 답함(문서 갱신) | ✅ 재측정 일치 — C4 재실측(`lessThan(0)` · light = dark · 머리 dy 0.0)과 같다. 병합본 기록 = `packages/ui_shell/test/golden/README.md` «🆕 R15» 절 «R15a 병합본 실측» 줄(PR #99 squash `940082c` · 2026-11-04) · o00b_unselected 맨 아래 584 < 844(`kGoldenPhoneSize` 844 = 카드 확정값 · 높이 무수정 · 체크·버튼 0 · 여유 260px) · 드라이런 `dry/r15v2-1` 값과 같음 · PNG = 드라이런 바이트 같음 — 측정값 기록이며 추측 아님 |
| A3 | R15a-Bob-O00O00b | 추측 | 측정: o00b_auto dy 실측값 (light=652.0, dark=652.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ✅ 답함(문서 갱신) | ✅ 재측정 일치 — C4 재실측(`lessThan(0)` · light = dark · 머리 dy 0.0)과 같다. 병합본 기록 = `packages/ui_shell/test/golden/README.md` «🆕 R15» 절 «R15a 병합본 실측» 줄(PR #99 squash `940082c` · 2026-11-04) · o00b_auto 맨 아래 652 < 844(`kGoldenPhoneSize` 844 = 카드 확정값 · 높이 무수정 · 왼쪽 카드 고름 · «다음» 1 · 여유 192px) · 드라이런 `dry/r15v2-1` 값과 같음 · PNG = 드라이런 바이트 같음 — 측정값 기록이며 추측 아님 |
| A4 | R15a-Bob-O00O00b | 추측 | 측정: o00b_advisory dy 실측값 (light=648.0, dark=648.0) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ✅ 답함(문서 갱신) | ✅ 재측정 일치 — C4 재실측(`lessThan(0)` · light = dark · 머리 dy 0.0)과 같다. 병합본 기록 = `packages/ui_shell/test/golden/README.md` «🆕 R15» 절 «R15a 병합본 실측» 줄(PR #99 squash `940082c` · 2026-11-04) · o00b_advisory 맨 아래 648 < 844(`kGoldenPhoneSize` 844 = 카드 확정값 · 높이 무수정 · 오른쪽 카드 고름 · «다음» 1 · 여유 196px) · 드라이런 `dry/r15v2-1` 값과 같음 · PNG = 드라이런 바이트 같음 — 측정값 기록이며 추측 아님 |
