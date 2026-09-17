# `rounds.md` — 라운드 로그

한 «라운드» = **한 AI에게 한 번 준 것과 받은 것**. 이 표가 「누가 무엇을 언제 받았고 지금 어디까지
왔는가」의 유일한 색인입니다. 팩을 다시 조립했으면(01·02~05 변경) **행을 새로 추가**하고,
이미 보낸 행의 값을 덮어쓰지 않습니다.

- **라운드ID** = `R<번호>-<AI>-<태그>`. `R0`은 착수 전 준비(환경·읽기)이고 구현은 `R1`부터입니다.
- **상태** = `미발송` · `발송` · `수신(PR)` · `검사 중` · `반려` · `병합` 여섯.
- **팩 판** = 이 폴더를 조립한 날짜. 문서가 바뀌면 판이 올라가고, 옛 판으로 작업 중인 라운드는
  **반려가 아니라 재발송** 대상입니다.
- 🔴 발송 전 확인: 실키 0 · 06_시스템설계와 청사진 HTML 미포함 · 프롬프트 본문 무수정.
- **팩 판 이력**: 2026-09-09(C2 조립) → **2026-09-17**(C4 R1-Bob-J1 반영 — 01·02 사본 갱신, 픽스처 78, `inbox/J1_questions.md`). 2026-09-09 판으로 작업 중인 라운드 = R1-Bob-J1 1회차 → 재발송 대상(재제출 행). → **2026-09-17b**(C4 R1-Gem-S71 1회차 반영 — 03·01 사본 갱신, `inbox/S7-1_questions.md`).

| 라운드ID | AI | 모듈 | 범위(화면ID) | 준 것 | 팩 판 | 발송일 | 상태 | PR·브랜치 | 질문 파일 | 비고 |
|---|---|---|---|---|---|---|---|---|---|---|
| R0-Bob-ENV | Bob | M6 | — | 11 시작가이드 부록 A · 저장소 접근 | 2026-09-09 | 2026-09-16 | **수신** | `chore/bob-env-check`(푸시 후 삭제) | | 클론·`melos bootstrap`·`melos run test:contracts` 통과 확인까지 · **패킷 `send/R0-Bob-ENV.md`(09-14)** · ✅ **2026-09-16 결과**: `analyze`(13패키지 · 경고 0) · `test` SUCCESS(skip 은 의도된 것) · 원격 브랜치 생성·푸시·삭제로 **권한 확인 완료** · 파일 수정 0 |
| R0-Bob-READ | Bob | M6 | J-1 | `prompt_M6.md` + 문서 5부 | 2026-09-09 | — | 미발송 | | `inbox/J1_questions.md` | 읽기만. 구현 착수 전 질문 목록 1회 제출 · **패킷 `send/R0-Bob-READ.md`(09-14)** · ℹ️ 발주자가 R1 을 바로 보내 **이 라운드는 R1 에 흡수**됨(질문 2건이 R1 인라인으로 옴) — 별도 발송 불필요 |
| R0-Gem-ENV | Gemini | M7 | — | 11 시작가이드 부록 B · 저장소 접근 | 2026-09-09 | 2026-09-17 | **수신** | | | 클론·`melos bootstrap`·`melos run test:contracts` 통과 확인까지 · **패킷 `send/R0-Gem-ENV.md`(09-14)**(CLI/웹 두 본문)  · ✅ **2026-09-17 결과: 방식 = 웹 채팅**(CLI 아님) → 이후 Gemini 카드는 전부 «웹 변형»(파일 첨부 + 전체 코드 출력 · 저장·포맷·검사·PNG·PR 은 Claude 대행) |
| R0-Gem-READ | Gemini | M7 | S7-1 | `prompt_M7.md` + 문서 5부 | 2026-09-09 | | 미발송 | | `inbox/S7-1_questions.md` | 읽기만. 구현 착수 전 질문 목록 1회 제출 · **패킷 `send/R0-Gem-READ.md`(09-14)** · ℹ️ R1-Gem-S71 과 같은 날 보내도 됨(Bob 처럼 R1 에 흡수돼도 무방) |
| R1-Gem-S71 | Gemini | M7 | S7-1 | `prompt_M7.md`(범위 S7-1) + 문서 5부 + `m7/m7_monthly_2026_08`·`m7_monthly_gap`·`m7_monthly_pending`·`ledger_trust_4`·`realized_alloc_S7` | **2026-09-17** | 2026-09-17 | 🔴 **반려**(2026-09-17) | `ui/m7-s71-monthly-report` · `[M7] S7-1 월간 리포트 뷰어` | `inbox/S7-1_questions.md` | 🆕 **패킷 `send/R1-Gem-S71.md`(2026-09-17 · CLI/웹 두 갈래)** · 사전 조건 J-1 병합 ✅ · 골든 하네스 `packages/ui_analytics/test/`(M2 설치 완료) · 골든 `s71_normal`·`s71_partial_gap`·`s71_not_generated`  · **C4 1회차(웹)**: Claude 가 원문을 로컬 브랜치 `ui/m7-s71-monthly-report`(`9a007fa` · 미푸시)에 옮겨 검사 — boundaries·labels·C-3/C-5/C-7 ✅ · 금지 4항의 산술·손익·안전 0 / `format` 6파일 ❌ · analyze 1(`unnecessary_lambdas`) ❌ · 자체 테스트 2/3 ❌(lazy ListView) · 추측·누락 A1~A9(Scaffold/AppBar · 순번 판정 버튼·콜백 6 · `***`/`?` 가림 발명 · 빈 상태 폴백 라벨 · stale 무고지 · 표식 플래그 미분리 · pubspec 교체 · 손 DTO 테스트·골든 테스트 없음) → 재제출 = 아래 행 |
| R1-Gem-S71 (재제출) | Gemini(웹) | M7 | S7-1 | 재제출 패킷 + 갱신 5파일(`inbox/S7-1_questions.md` · 03 · 01 · `ui_analytics/test/golden/README.md` · `golden_support.dart`) | **2026-09-17b**(03·01 사본 갱신) | | 미발송 | `ui/m7-s71-monthly-report` · `[M7] S7-1 월간 리포트 뷰어` | `inbox/S7-1_questions.md`(Q2 부터) | **패킷 `send/R1-Gem-S71-재제출.md`** · 범위 = 03 §3 「C4 R1-Gem 반영」 ③(딥링크·상세 버튼은 R1b) · 받은 뒤 문장 「R1-Gem-S71 재제출 결과(웹): 아래 전체 — 저장·검사·PR·병합 검사까지 해줘」 |
| R2-Bob-J2J3 | Bob | M6 | J-2 · J-3 | (미조립) | — | | 미발송 | `ui/m6-j2-detail` · `[M6] J-2·J-3 거래 상세·사전 저널` | `inbox/J2_questions.md` · `inbox/J3_questions.md` | 🔴 **M2 선행(2026-09-17 C4 확인)** — 타입은 확정(`DecisionSnapshot`·`ThresholdCompare`·`RejectTrace`·`JournalDraftFormSpec`)이나 **픽스처가 없다**: `chainOf` 체인 3건(정상 6단계·부분 3회+잔여·`SAF309_` 거부) · 스냅샷/임계/거부 trace · J-3 폼 스펙(`rule_cited_options`) → M2 가 만들고 팩 재조립 뒤 패킷. 라우트 상수(01 §8 미결 36)도 J-2 진입에 걸림 |
| R1-Bob-J1 | Bob | M6 | J-1 | `prompt_M6.md`(범위 J-1) + 문서 5부 + `fixtures/journal_30.json` | 2026-09-09 | 2026-09-16 | 🔴 **반려**(2026-09-17) | `ui/m6-j1-timeline` **로컬·미커밋** · PR 없음 | 미생성(인라인 보고 2건) → Claude 가 `inbox/J1_questions.md` 생성(Q1·Q2 + A1~A9) | 첫 코드 과제 · **패킷 `send/R1-Bob-J1.md`(09-14)** · **C4 검사(2026-09-17)**: analyze·test:contracts·boundaries·labels ✅ / **`melos run format` 2파일 ❌**(CI 포맷 게이트) / 제출물 4종(PR·질문 파일·골든·스크린샷) 미제출 / 추측·누락 A1~A8 → 재제출 = 아래 행 |
| R1-Bob-J1 (재제출) | Bob | M6 | J-1 | 재제출 패킷 + **팩 판 2026-09-17**(01·02 사본 갱신 · 🆕 `m6/journal_empty.json` · C-2 하네스 · `inbox/J1_questions.md` 답) | **2026-09-17** | 2026-09-17 | ✅ **병합** | **PR #1** `ui/m6-j1-timeline` → main squash `b5255f4` · `[M6] J-1 매매일지 타임라인` | `inbox/J1_questions.md`(새 질문 0) | **패킷 `send/R1-Bob-J1-재제출.md`** · Bob 은 브랜치 푸시까지(MCP 토큰이 private PR 생성 불가) → PR 은 Claude 가 대행 생성 · C4: format·analyze·boundaries·labels·test:contracts ✅ · 금지 4항 0 · F1~F9 ✅ · CI 1회 ❌(리눅스 골든 원시 차 0.74~1.44%) → **비교기 2판**(`f4bd1c9`, 이동·AA 허용 유의 픽셀 0.2%) → 3잡 ✅ → squash 병합. 범위 = 목록·상태 6종·골든(필터·딥링크는 R1b) |

## 아직 열지 않은 라운드

`prompt_M9.md`(Bob · M9 `S01`)와 `prompt_M8.md`(Gemini · M8 `S-01`)는 **조립돼 있으나 발송 대상이
아닙니다.** 순서는 Bob = M6 → M9, Gemini = M7 → M8이고, 앞 모듈이 병합된 뒤에 행을 추가합니다.
