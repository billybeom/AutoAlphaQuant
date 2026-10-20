# 발송 패킷 R3-Bob-J4 — J-4 사후 blind 리뷰 (계약 v1.7) + 부록 S-1·S-8·S-10·S-11·S-12

> ▶ **보낼 수 있음**(2026-10-20 발주자 확인 5건 = 기본값 그대로 · 이 파일이 GitHub `main` 의 `send/` 에 있으면 보낸다 · Bob **새 대화**) — ~~⏸ 아직 보내지 않음~~(2026-10-20 조립 · 기록 = 이 기록 커밋 · 가지 `rec/r3-j4` · 🆕 같은 날 C4 검증 반영 — 드라이런·변이·감사·명세 지적 40건 · 기록 커밋 amend) — 남은 것 = ① ✅ **누적 드라이런**(worktree `C:/Work/AAQ-claude-r3dry` 가지 `dry/r3-j4` · HEAD `390f218`)으로 이 파일의 실측 표식(부호 U+27E6)을 전부 채웠다 ② ✅ 드라이런 브랜치 사전검사 🔴 0 ③ ✅ 재분할 불필요(아래 «드라이런» 줄) ④ ✅ **발주자 확인**(2026-10-20 · 다섯 가지 모두 기본값 그대로) ⑤ 발주자 «푸시해» → 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 → 머리 첫 줄 ▶. 선행 = ✅ **계약 v1.7 병합(앱 PR #32 · squash `0905377` · 2026-10-20 · CI 3/3 · 가지 삭제)** — `main` 에 있다(0단계 확인 줄이 다시 본다). 🔴 Bob 의 현재 브랜치(`ui/m7-s710-gap` · R12d 병합됨)는 건드리지 않는다.
> 만든 날 2026-10-20 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R3-Bob-J4` 행 + «R2b 잔여 부록»(S-1·S-8·S-10·S-11·S-12 — 그 블록의 «■ 보고 규칙» 줄은 싣지 않고 §3 공통 조문(strict 나눔 2026-10-01 · `[—]` 금지 — R12d 카드 :220)으로 바꿈) + «R12d C4 이월 부록»(C4d-1 견본 · C4d-5 · if 짝 세기 = 사전검사 T1·T2·T4) + §3-0 사전검사 블록 · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-19_미결46_계약v1.7_설계서.md` §2-5(공개 위젯·파일·주입) · §2-6(호출 표) · §2-7(상태 표 + 갈래별 정적 글자) · §2-8(필드 → 자리) · §3-4(골든 ↔ 입력) · §6(카드에 넘길 것) · §9 결정 K1~K24(✅ 발주자 확정 2026-10-20 · 전부 권고대로) · 조문 = `01_…` §16(16-5 · 16-6 · 16-7 · 16-8 · 16-10 · 16-16) · `02_…` §3-4 의 «🆕 계약 v1.7 — `J-4` R3 범위 · 이 블록이 이긴다» 블록 ⓐ~ⓛ · §3-1 ⓗ(S-12) · 코드 = `packages/domain_contracts`(`BlindReviewCard` · `BlindReviewQuestion` · `BlindReviewChoice` · `BlindReviewResult` · `JournalRepository.watchBlindReviewQueue`·`watchBlindReviewCard` · `CommandApi.submitBlindReviewScore` · `BlindReviewRejectCodes` · 받침대 `UnimplementedJournalRepository`·`UnimplementedCommandApi`) · 계약 테스트 C-43(`test/contracts/c43_blind_review_test.dart` — 이 카드의 화면 파일이 처음으로 B 절 ⑩~⑯ 의 대상이 된다) · golden README «🆕 R3» 절(이 기록 커밋 몫).
> 사전 조건 — ✅ 계약 v1.7 병합(PR #32 · squash `0905377` · `contractVersion '1.7.0'` · 픽스처 141 · 라우트 45 그대로 · `domain_contracts` 315 통과 · 30 skip · 0 실패 · `ui_journal` lib·테스트·PNG 변경 0). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 시작 기준 = `0905377` 의 `flutter test`(packages/ui_journal) = **207**(드라이런 실측 «+207: All tests passed!» — 앱 PR #32 (3b) 커밋 본문 인용 207 과 같다) · 이 카드 끝 기대 = 시작 기준 N + 77(뷰 45 · 골든 j4 12 · S-12 뷰 12 · 골든 j1_rebalance 4 · S-1 1 · S-11 3 · 드라이런 실측 207 → **284**).
> 카드 확정값(카드 권한 — 설계서 §6 «후보 · 카드 확정» 자리를 이 카드가 정한다): 정적 라벨 2개(본문 «정적 라벨» — 제출은 `JournalLabels.draftSubmit` 재사용 · «다시 시도» = `retry` · 접수 실패 = `submitNotAccepted` 재사용) · Key 표 21이름(`j4-` 접두 · 본문 «Key 표» — 설계서 후보의 `j4-banner` 는 빼고 `j4-submit-not-accepted` 를 더함 · 에러 갈래 Key = `j4-fail`(사전검사 R2 가 «error» 낱말을 보고 글에서 잡으므로)) · 위젯·프로바이더·파일 이름(설계서 §2-5 글자 그대로 · 본문 «주입 구조») · 새 lib 파일 1개(`lib/src/blind_review.dart` · `lib/src/blind_review/` 폴더 만들지 않음) · 선택 위젯 = `ChoiceChip` · 저널 본문 = J-4 안에서 그림(J-3R 위젯 재사용 0) · 고지 = 스크롤 밖 · 골든 6이름 12장(크기 390 × 1600 — 테스트 파일 안 `_kTallPhone` · 드라이런 최대 dy 1480) · S-12 `JournalTimeline({super.key, this.rebalanceEventId})` · `Key('j1-chip-rebalance')` · 골든 2이름 4장(390 × 844 = `kGoldenPhoneSize` · 🆕 찍기 전 필터 줄을 맨 아래 위젯까지 가로 끝 정렬 스크롤) · 🆕 접수증 = `Text(stateLabel)`(02 §3-4 본문의 «전송 대기 칩»은 표현 꼴 — J-3 접수증 줄과 같은 Text · 카드 확정) · 🆕 접수 실패 줄은 결과 갈래에서 그리지 않는다(`result == null && _submitNotAccepted` — 01 §16-6 결과 행 · K15).
> 🔴 **보내는 조건(Claude 확인)** — 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/J4_questions.md` 가 `main` 에 있음(빈 머리말 — 이 기록 커밋이 만든다 · 카드마다 1개) + golden README «🆕 R3» 절이 `main` 에 있음(`git grep -c "j4_before_reveal" -- packages/ui_journal/test/golden/README.md` = 숫자 하나) + 이 파일에 실측 표식 0(`LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R3-Bob-J4.md` = 0 — Git Bash 기본 로캘에서는 `LC_ALL=C.UTF-8` 없이 오류가 나므로 오류를 0 으로 읽지 않는다 · 지금 남은 표식 = 0 — 2026-10-20 C4 검증 반영 때 드라이런 실측으로 채웠다) + 드라이런 브랜치 사전검사 🔴 0 + 재분할 불필요 판정. 0단계의 `ls`·`grep` 줄이 그 증명입니다.
> 🔴 **카드 덮개 필수 문장(01 §16-7 · 02 §3-4 v1.7 블록 ⓓⓔⓕⓖ)** — «채점 전 카드에는 결과·손익이 **없다** — 가리는 코드를 짜지 않는다 · 결과 섹션은 `card.result != null` **하나로만** 연다(접수증 상태로 고르지 않는다)» · «점수는 **옮기기만** — 고른 `BlindReviewChoice.score` 를 `BlindReviewScore.answers[questionId]` 에 그대로 · 점수 표시·합산·비교 0 · 과정 점수 글자 = 엔진 `processScoreText`» · «결과 글자 = 엔진 문장(금액(원) 0 · 수익률·보유기간·방향만) · 채점 전 카드의 앱 안 링크 0(칩 = 핸드북만 · `J-2` 링크는 `result.decisionLink` 에만)». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» ⑮⑯ 에 있습니다. Key 표와 라벨 글자 표도 본문에 있습니다.
> ✅ **K 결정 표식** — 이 카드가 기대는 K1(점수 축) · K2(창구 2) · K3(큐 대상·시점 — 엔진 규칙 · 화면 판정 0) · K4(정렬 = 엔진 · 고정 카드) · K5(공개 = `result != null`) · K6(결과 = 엔진 문장 · 금액 0 · 열람 기록 0) · K8(채점 전 링크 0) · K10(전 문항 선택 시에만 제출) · K12(이중 채점 = 엔진) · K13(명령 주입 = 이 화면 파일 안) · K14(인자 없는 공개 위젯 · 라우트 45) · K15(고지·«다음 건» = 정적 라벨 · 갈래별 노출 표) · K17(공통 배너 조각) · K18(수용 (c) = (가) 위젯 트리 대조) · K22(카드 구성 · S-12 같은 카드 — 임계 안이면) · K24(LIVE 만 · 인자 없이) = **✅ 발주자 확정(2026-10-20 · 전부 권고대로 · 01 §16-14)** — 카드 본문은 «확정»으로 인용한다.
> 드라이런: ✅ **완료**(2026-10-20 · worktree `C:/Work/AAQ-claude-r3dry` · 가지 `dry/r3-j4`(남겨 둠) · `0905377` 에서 만든 뒤 이 기록 커밋으로 ff = «푸시 뒤 `main`» 흉내 · 비교 기준 = 기록 커밋 · HEAD `390f218` = 할 일 (1)~(7) + (6b) T4-10 보강 + (9) C4 검증 반영) — 시작 207 → 끝 284(N + 77) · 파일별 «+45»(blind_review_test) · «+12»(j4_golden) · «+12»(timeline_rebalance) · «+4»(j1_rebalance_golden) · S-1 +1 · S-11 +3 · 사전검사 ① 코드만 🔴 0 · 🟡 0(테스트 파일 11 · collection-if 0) · ② 제출 글까지 🔴 0 · 🟡 8(G1 버튼 셈 — 아래 «발주자 확인 대기» ③) · 정적 묶음 32줄 = 본문 기대 그대로 · `_kTallPhone` = 1600(최대 dy 1480 · 여백 줄이기 0) · dy 표 = golden README «🆕 R3» · S-1 = 시도 3 모양 · 재생성 6장 · 새 testWidgets 줄 33(= 임계 «> 33» 의 경계 · 넘지 않음 — C4 보강은 전부 기존 경우 루프·기존 테스트 안) · lib +743/-47(< +900) · 새 PNG 16(= 경계) → **재분할 불필요**(S-12 를 떼지 않는다) · 예고 변이 확인 = «3-1» 끝 줄).
> ✅ **발주자 확인 완료**(2026-10-20 · ①~⑤ 모두 아래 기본값 그대로 · ② 회차 칩 자리 = 설계 개정 후보로만 기록 · ③④ 사전검사 정정 = 나중 infra PR — 이 카드는 🟡 8·«12항» 머리를 그대로 쓴다): ① C4d-3(문맥 칩 `tone` 색) = 그리지 않음(`JournalReasonChip` 무수정 재사용 — 01 §16-8 · 규칙 3) · C4d-6(Text.rich·RichText·SelectableText 글자) = 허용 집합 루프에 넣지 않고 정적 S30 «J-4 파일에 그 위젯 0» 으로 막음(한계: 공통 위젯 안의 RichText 는 S30 밖 — 지금 공통 위젯은 Text 만 쓴다) · C4d-2 = T4-12·T4-13 으로 같은 효과 · C4d-4 = 해당 없음(빈 문장 = Padding(Text)) · ㉠·㉡ = 미포함 ② 부록 S-12 회차 칩 자리 = 설계 02 §3-1 ⓗ (다) «기간 칩 다음» 그대로 — 390 폭에서는 가로 스크롤 필터 줄의 화면 밖(x 460.5~816.6)이라 진입 직후 칩이 안 보인다 (골든은 끝 정렬 스크롤로 보이게 찍는다 · 기간 칩 앞으로 옮기거나 줄바꿈하려면 설계 변경) ③ 사전검사 G1 이 «버튼 글자» 를 글자 1줄로 세어 버튼 있는 골든 행마다 🟡(드라이런 8행 — 멈춤 아님 · infra 정정 PR 여부) ④ 사전검사 ② 섹션 머리 «12항» 고정(M6 자체 점검 10항이어도 머리 글자 그대로 — infra 정정 PR 여부) ⑤ 카드 확정값 이의(에러 Key `j4-fail` · `j4-banner` 제외 · 고지 스크롤 밖 · 고정 = 첫 data 의 rows[0] · 저널 본문 J-4 안 · J-4 는 FlutterError.reportError 0 · 이탈 배지 늘 · 접수증 Text · 테스트 copyWith 다섯 꼴(규칙 10)).
> 프롬프트 = `docs/ai-context/prompt_M6.md`(🔴 범위 치환값은 아직 R2b 판(2행 `{{범위}}` = `J-3 (+ R2 잔여 R-1~R-7)` · 106행 «이번 과제 범위:» · 116행 PR 제목) — 이 기록 커밋은 그 파일을 바꾸지 않는다 · 이 카드의 범위·브랜치·PR 제목은 이 패킷이 정한다 · 본문 «프롬프트보다 이 카드가 이긴다» ①⑫⑭) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R2b·R12 의 대화를 기억하지 못합니다 — 0단계·규칙 요약·본받지 않는 것·코드 스케치·테스트 목록은 본문에 담았습니다.
> R10~R12 교훈 반영: 보고 기계화(② 10항 복사 상자 + «정적 묶음» 출력 그대로 · ① name-status 출력 그대로 · ③ 위젯·Key 이름 나열) · 🆕 **푸시 전 사전검사 `tool/precheck.dart`**(12 §3-0 · 앱 PR #31 `76c2404` — ■ 제출에 두 줄 · 🔴 0 이어야 푸시 · 🟡 는 멈춤 아님 · C4d-1 의 «if 짝 세는 git grep 줄»은 이 검사의 T1·T2·T4 가 맡는다 — 정적 묶음에 싣지 않는다) · ⓡ·ⓗ 개수는 정적 `grep -c` 줄로 대조 · 조건부 단언 금지(사슬의 «없는 쪽»은 else 로) · 공용 파일은 «끝 절 더하기만» · strict 보고 규칙 나눔(12 §3 R10~R16 머리) · «PR 본문은 통합 담당이 바꾼다» · 재제출 = ①~⑤ 전체판 + 바뀔 자리 상자 · 골든 높이 = 재량 + 기록 · 커밋 = 제목만 맞추기 · 🆕 C4d-1(«화면의 Text 전부» 코드 견본) · 🆕 C4d-5(골든 표 «글자 줄 n» = PNG 행 수 · «상자»·«배경 덩어리»·«칩 n개» 셈 단위) · R2b 카드 설계 교훈 ①~④(잠금 = 버튼 부재 + 입력 비활성 둘 다 · 창은 add 하지 않은 StreamController · 늦게 구독되는 컨트롤러 teardown = `unawaited(close())` · 델타 0 단언 허용).

## 0. 한 줄 목적

손익을 가린 채 결정의 **과정을 먼저 채점**하고 그 뒤에만 엔진의 결과 문장을 여는 `J-4` 화면 하나(`JournalBlindReview()` — 대기 목록의 머리 카드를 고정 · 문맥·저널·문항 · 제출 · 접수증 · 결과 · «다음 건» · 빈 문장)를 계약 v1.7 그대로 짓고, R2b·R12d 가 남긴 `ui_journal` 잔여(S-1 드롭다운 둘째 줄 · S-8·S-10·S-11 테스트 보강 · S-12 `J-1` 회차 칩)를 같은 브랜치에서 닫기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-j4-review`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음 · 브랜치 이름 = 설계 12 §3 R3 행 · 01 §16-16 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일 머리 첫 줄이 ▶ 일 때만 보냅니다** — ⏸ 이면 아직입니다(실측 표식은 2026-10-20 누적 드라이런으로 채웠다 — 남은 것 = 머리의 «발주자 확인 대기» 5건 · 그 뒤 Claude 가 「푸시해」로 `main` 에 올린 다음 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R12d 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R3-Bob-J4.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r3rec\docs\ai-context\send\R3-Bob-J4.md`(가지 `rec/r3-j4` · 2026-10-20 Claude 작성) · 기록 푸시 뒤 `main` 과 글자가 같습니다). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 R12d 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부** — ```text 다음 줄(«R3-Bob-J4 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `ui_journal` 의 끝난 카드 `_완료/R2b-Bob-J3.md` · `_완료/R2-Bob-J2J3*.md` · `_완료/R1b-Bob-J1*.md`, M7 의 `_완료/R12*-Bob-*.md` 를 붙여넣지 않습니다. `send/` 바로 아래의 보낼 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R3-Bob-J4 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

```text
R3-Bob-J4 — 범위: J-4 사후 blind 리뷰(JournalBlindReview() — 대기 목록 머리 카드 고정 · 고지(스크롤 밖) · 머리(asOf·제목·안내) · 공통 배너 ·
  문맥 칩·이탈 배지 · 저널 상태·본문 · 문항(근거 줄 · ChoiceChip 선택지) · 접수증 줄 · 접수 실패 1줄 · 제출 · 결과 섹션(과정 점수·결과·보조 줄·이 결정 보기) ·
  «다음 건» · 빈 문장) + 주입·데이터 프로바이더 3 + 공통 배너 조각 JournalSafetyBanners(journal_common 끝에 더하기만) + 정적 라벨 2 + 배럴 export 1줄 +
  부록: S-1 J-3 인용 규칙 드롭다운 선택 label 둘째 줄 밑줄 겹침 해소(j3 PNG 지정 목록만 재생성) · S-8·S-10·S-11 기존 테스트 보강 ·
  S-12 J-1 회차 칩(JournalTimeline({String? rebalanceEventId}) · 씨앗 기간 · 칩 ✕ · 진입 격리).
🔴 채점 전 카드에는 결과·손익이 없다 — 가리는 코드를 짜지 않는다 · 결과 섹션은 card.result != null 하나로만 연다(접수증 상태로 고르지 않는다).
🔴 점수는 옮기기만 — 고른 BlindReviewChoice.score 를 BlindReviewScore.answers[questionId] 에 그대로 · 점수 표시·합산·비교 0 · 과정 점수 글자 = 엔진 processScoreText.
🔴 결과 글자 = 엔진 문장 그대로(금액 0 · 수익률·보유기간·방향 — 화면은 받은 글자만) · 채점 전 카드의 앱 안 링크 0(칩 = 핸드북 · 이 결정 보기 = result.decisionLink 에만).
하지 않는 것: outcome_score 입력·2×2 배치(01 §8 미결 98) · 모의투자(SIM) 결정 리뷰·모드 고르기(미결 99 — 큐는 인자 없이) · 공개 결과 재열람·단건 라우트(미결 100) ·
  경합 거부 뒤 «기록된 답» 표시(미결 101) · X7 미이행 결정 표본(미결 102) · 결정 8 열람 기록(recordDisclosureView 0)·S7-2G 게이트 ·
  셸 몫(라우트 journalBlindReview 배선 · 웹 «부재» 가드 · 조립 앱 override — M8 · R13) · 웹 2열·대화면(Q-D) · 기존 M6 화면 넷의 배너 관용구 옮기기 ·
  J-2·J-3R·J-5 화면 코드 수정(S-8·S-10·S-11 은 테스트만) · S-12 의 셸 라우트 journalRebalance 배선(R13).
🔴 이 카드가 docs/ai-context/prompt_M6.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 23항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R2b(ui/m6-j3-complete) · R12d(ui/m7-s710-gap) — 둘 다 병합됨 — 가 아닙니다.
앞 카드의 브랜치(ui/m6-* · ui/m7-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/blind_review.dart · JournalSafetyBanners · journalBlindReviewCommandApiProvider · Key j4-notice · Key j1-chip-rebalance 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s710-gap 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m6-j4-review origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.7.0'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»(계약 v1.7 병합)
  git grep -c "class BlindReviewChoice" -- packages/domain_contracts/lib/src/dto/journal.dart                                 ← «…journal.dart:1»
  git grep -c "class BlindReviewResult" -- packages/domain_contracts/lib/src/dto/journal.dart                                 ← «…journal.dart:1»
  git grep -c "Stream<BlindReviewCard> watchBlindReviewCard(String decisionId)" -- packages/domain_contracts/lib/src/repositories/journal_repository.dart   ← «…journal_repository.dart:1»
  git grep -c "Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({" -- packages/domain_contracts/lib/testing.dart      ← «…testing.dart:1»(받침대)
  git grep -c "Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) =>" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»(S-12 받침대)
  git grep -c "abstract final class BlindReviewRejectCodes" -- packages/domain_contracts/lib/src/labels/journal_codes.dart      ← «…journal_codes.dart:1»(읽기만 — 화면은 쓰지 않는다)
  git grep -c "static const String journalBlindReview = 'aaq://journal/blind-review';" -- packages/domain_contracts/lib/src/navigation/app_links.dart   ← «…app_links.dart:1»(읽기만)
  ls docs/ai-context/send/R3-Bob-J4.md                                              ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls docs/ai-context/inbox/J4_questions.md                                          ← 보여야 함(빈 표가 이미 있다)
  ls tool/precheck.dart                                                             ← 보여야 함(푸시 전 사전검사 — ■ 제출)
  ls packages/domain_contracts/test/contracts/c43_blind_review_test.dart            ← 보여야 함(C-43 — 이 카드의 화면 파일이 처음 대상이 된다)
  ls packages/domain_contracts/fixtures/m6/blind_review_queue_3.json                ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/blind_review_queue_empty.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/blind_review_card_before.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/blind_review_card_revealed.json          ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/blind_review_card_revealed_open.json     ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/blind_review_receipts_6.json             ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/journal_rebalance_scope_1.json           ← 보여야 함(S-12)
  ls packages/ui_journal/test/golden/goldens/j3_rejected_light.png                  ← 보여야 함(S-1 재생성 대상)
  git grep -c "j4_before_reveal" -- packages/ui_journal/test/golden/README.md                               ← 숫자 하나(golden README «🆕 R3» 절 — 기록 커밋 몫)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir · && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R3 가 들어간 것 — 멈추고 알림):
  ls packages/ui_journal/lib/src/blind_review.dart                                  ← 없어야 함
  git grep -c JournalSafetyBanners -- packages/ui_journal/lib                       ← 출력 없음이어야 함
  git grep -c journalBlindReviewCommandApiProvider -- packages/ui_journal/lib       ← 출력 없음이어야 함
  git grep -c j4- -- "packages/ui_journal/*.dart"                                   ← 출력 없음이어야 함(.dart 만 본다 — golden README 의 R3 절은 j4 글자를 담고 있어도 정상)
  git grep -c j1-chip-rebalance -- "packages/ui_journal/*.dart"                     ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.7 새 타입(BlindReviewChoice · BlindReviewResult …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류). «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_journal
  flutter test   ← 시작 기준: 계약 v1.7 병합본 전부 통과 · 0 실패 · 기대 «+207: All tests passed!»(드라이런 실측 · 끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · README 의 수치는 보지 않는다 ·
                   그 수와 다르면 멈추지 말고 PR 본문에 까닭 한 줄 — 그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·C-43) > 이 카드(지시) > 01 §16 > 02 §3-4 의 v1.7 블록 > 02 §3-1 ⓗ(S-12) > 02 본문·그림 M6-12·M6-13 > prompt_M6.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 ·
   이 카드에서 «규칙 N» = 바로 아래 규칙 요약의 N 번 · «설계서 §n» 은 출처 표시일 뿐(Bob 은 설계서를 열지 않는다 — 정본 = 이 카드의 글자))
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox/J4_questions.md 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart·test/contracts/** 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·README · 기존 골든 테스트 파일의 단언·입력(j1·j2·j3·j3_r2b·j3r·j5 —
   예외 = 부록 S-12 (타)의 가짜 watchRebalanceScope 한 덩어리 + 배선이 바꾸게 하는 override 모양 줄 뿐) · 기존 PNG 전부(56장 · 예외 = 부록 S-1 의 재생성 목록 6장 하나 · 그 밖에 하나라도 M 이면 되돌리고 멈춤) ·
   lib/journal_draft.dart · lib/src/decision_detail.dart · lib/src/journal_read.dart · lib/src/unknown_board.dart(이 카드는 J-2·J-3R·J-5 화면 코드를 고치지 않는다) ·
   lib/src/journal_draft/journal_draft_form.dart 는 부록 S-1 의 인용 규칙 드롭다운 자리(DropdownButton<ReasonOption> 한 덩어리)만 · lib/src/timeline.dart 는 부록 S-12 만 ·
   기존 테스트 파일(journal_draft_test · journal_read_test · decision_detail_test · unknown_board_test · timeline_test)은 부록 S-1·S-8·S-10·S-11·S-12 가 지시한 자리만(더하기·보강 — 기존 단언을 지우거나 약하게 바꾸지 않는다 · 부록이 정한 import 한 줄·도우미 반환형 바꾸기 포함).
   공용 파일 3개는 **더하기만** 한다 — 기존 줄은 한 글자도 바꾸지 않는다(정적 묶음 S23 의 삭제 수 0 이 증명):
     lib/l10n/labels.dart = 파일의 마지막 절(R2b 절 — submitNotAccepted) 뒤에 이 카드의 절 하나 ·
     lib/src/common/journal_common.dart = 파일 끝(JournalErrorView 뒤)에 JournalSafetyBanners 절 하나 ·
     lib/ui_journal.dart = export 한 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
 2 J-4 는 받은 글자와 null 여부만 본다 — 값 = DTO 의 *Text·*Label·label·text·원문 그대로 · 계약이 주는 표시 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 3) ·
   원값(int·DateTime)·.wire·키(decisionId·questionId) 표시 금지 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = lib/l10n/labels.dart 의 JournalLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20 은 주석 줄도 센다.
 3 읽지 않는 필드(카드가 정함 — 질문 아님): BlindReviewChoice.score 는 «옮기기» 자리 하나에서만(제출 answers 맵) · BlindReviewCard.decisionId 는 고정 카드 id·제출 인자로만 ·
   BlindReviewQuestion.questionId 는 선택 상태 맵 키·제출 맵 키로만 · DeviationBadge.isDeviation·kindCode(이탈 배지는 늘 label 그대로 — 판정 0) · ReasonChip.code ·
   ReasonChip.tone(J-4 는 JournalReasonChip 을 무수정으로 다시 쓰므로 tone 색을 그리지 않는다 — 01 §16-5 «label·tone» 과 다른 점은 카드 기본값 · 발주자 확인 대기 ①(C4d-3) · 공통 위젯을 고치면 범위 확대) ·
   CommandReceipt.rejectReasonCode·commandId 외 키(commandId 는 watchCommand 인자로만) · ListResult.hasMore · DecisionJournalBody 밖의 J-3R 창구.
   🔴 C-43 ⑬ 은 .isDeviation .kindCode .journalId .rejectReasonCode .code .wire .result! 를, ⑫ 는 .score 의 모든 등장이 맵 값 자리(] = 또는 :)인지를 기계로 본다(주석은 빼고 · 문자열 리터럴은 남김).
 4 이동 = AppLinkOpener.open(link) 하나(journalLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지(J-4 파일) · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백·인자 금지(JournalBlindReview 의 생성자에는 key 뿐).
   J-4 화면 파일이 직접 여는 링크는 result.decisionLink.deepLink 하나다. 칩 detailDeepLink 는 JournalReasonChip 이 · 배너 clearDeepLink 는 JournalBlockingFlags 가 안에서 연다(기존 위젯 그대로 · 고치지 않는다).
   이 카드가 쓰는 AppRoutes 상수는 0 개다(journalBlindReview · journalRebalance 는 셸 R13 이 배선 — 읽기만 · 화면은 파라미터 라우트 상수·AppLinkSchemes 를 참조하지 않는다 = check_boundaries [5b]).
 5 화면 산술 0 · 점수 0 — 목록을 거르지도 세지도 정렬하지도 자르지도 않는다(큐 = rows[0] 고정 · 문항·선택지·칩·보조 줄 = 받은 순서 · 순번 = .indexed 의 i) ·
   목록 길이·int 를 글자로 0 · C-43 ⑮ 낱말 0(.where .sort .sorted .reversed .take .skip .fold .reduce .toSet .compareTo .last .lastOrNull .sublist .getRange .elementAt
   .removeAt .removeWhere .retainWhere .shuffle · .contains( .split( .substring( .replaceAll( .trim( · maxLines · TextOverflow.ellipsis · reverse: true) —
   .indexed · .map · .isNotEmpty · .isEmpty · .every · .first · [0] · .containsKey( 는 허용(«전 문항 선택» = questions.every(… _picked.containsKey(q.questionId))).
   허용되는 산술은 신선도 한 식뿐이다(asOf.observedAt.add(asOf.staleAfter).isBefore(clock.nowUtc()) — J-1·J-5 와 같은 식).
 6 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드의 열거형 switch 는 둘이다: CommandState 9값(잠금 판정 하나 — 정적 S07 = dart format 결과 8줄: 7값 한 줄씩 + `CommandState.rejected || CommandState.expired => false,` 한 줄) · EmptyKind 3값(빈 문장 고르기 — J-1 _EmptyState 꼴).
 7 시계 = journalClockProvider(DateTime.now()·DateTime.timestamp()·clock.now() 금지 — 주입 Clock.nowUtc() 만) · 쓰는 자리 = 신선도 한 식(카드 갈래·빈 갈래 머리).
   공통 상태 = 스켈레톤(JournalSkeleton · 스피너 금지) · 에러 = JournalErrorView(onRetry: invalidate · lastAsOfLabel: 그 AsyncValue 의 valueOrNull?.asOf.label) · 오래됨 = JournalStaleBanner ·
   차단 = 🆕 JournalSafetyBanners(safety: ref.watch(journalSafetyStateProvider).valueOrNull) — 🔴 J-4 파일에 .watchState((C-43 ⑪) · .where(C-43 ⑮) · FlagIds(정적 S08 — C-43 에는 없다) 0(차단/표식 분리는 공통 조각 안) ·
   🔴 플래그로 문항·제출을 끄지 않는다(배너만 얹는다) · 🔴 로딩·에러 갈래에서는 고지·배너를 그리지 않는다(값이 온 뒤에만 — J-1·J-5 와 같다).
 8 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지 — 🔴 C-43 ⑭ 는 «Scaffold» 를 부분 일치로 보므로 ScaffoldMessenger 도 걸린다 · J-4 파일에 ScaffoldMessenger·SnackBar 0 ·
   주석에도 이 낱말 0 · 정적 S09) · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장·사람이 쓴 원문에 FittedBox·말줄임·maxLines·trim 금지 · 390px overflow 0 · 글꼴 200% overflow 0(T4-17) ·
   선 굵기·투명도·간격은 정수·N.0·colorScheme 만(소수부 ≠ 0 소수 리터럴 0 — C-43 ⑯ · 정적 S22) · 띠 높이 예약 금지 ·
   엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(정적 글자 = 아래 «정적 라벨» + 재사용 라벨뿐).
 9 프로바이더는 셋만 더한다 — 명령 주입 journalBlindReviewCommandApiProvider(기본 throw UnimplementedError) + 데이터 journalBlindReviewQueueProvider(StreamProvider) +
   journalBlindReviewCardProvider(StreamProvider.family · 열쇠 = 고정 카드의 decisionId) · 🔴 셋 다 blind_review.dart 안(아래 «주입 구조» 글자 그대로) · autoDispose 0(J-1 꼴 · 정적 S16) ·
   기존 프로바이더(journalTimelineRepositoryProvider · journalSafetyRepositoryProvider · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider · journalCommandApiProvider ·
   journalDraftStoreProvider)는 이름·타입·위치 그대로 · 🔴 J-4 파일에 journalCommandApiProvider · journalDraftStoreProvider · DraftStore 0(C-43 ⑪ · operator 라이브러리 = C-35 ⑥) ·
   주입 프로바이더는 탭·제출·구독 핸들러 안에서 ref.read 만(build 에서 read·watch 금지) · 데이터 프로바이더는 build 에서 ref.watch.
10 테스트 = testing.dart 받침대 extends(UnimplementedJournalRepository · UnimplementedCommandApi · UnimplementedSafetyRepository · UnimplementedConfigRepository — 새 가짜에 implements 금지) ·
   받은 인자 전부 기록 · 호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처 행에서 — 🔴 접수증은 receipts_6 의 6행에서 · CommandReceipt(…) 생성자 0) · 허용되는 copyWith 는 이 다섯 꼴뿐: ① 큐 봉투의 rows 슬라이스(rows.sublist(k) — 값을 더하지 않는다 · j5_long_open 선례)
   ② 빈 큐의 emptyKind 갈래(T4-02 의 notApplicable · notLoaded — 글자는 픽스처 그대로) ③ 🆕 접수증 state 만 바꾸기 = receipts[0].copyWith(state: s)(T4-05 의 네 경우 received · staleContext · pendingLeaseConfirm · noOperator —
   픽스처 6행에 없는 상태의 잠금 판정 시험 전용 · stateLabel 은 행 0 글자 그대로) ④ 🆕 지우기만 = revealedOpen.copyWith(journal: null)(T4-08) ⑤ 🆕 지우기만 = revealed.copyWith(result: r.copyWith(decisionLink: null))(T4-07 · r = 전제 isNotNull 뒤 revealed.result!) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴(경우 목록의 bool) ·
   테스트 이름은 번호 + ASCII(예 'T4-05 receipt rejected_invalid') · 새 테스트 파일의 문자열 리터럴은 전부 ASCII 만(이름 · reason: · 그 밖 모두 — «—»·«→»·«·» 도 금지 · 정적 S01·S02a·S02b · 한국어가 필요하면 \u 이스케이프) ·
   목록·집합을 «있으면 넣는다»로 만들 때는 null-aware 원소(?q.evidenceText · ?body.note · ?(조건 ? null : 값))로 만든다 — 🔴 collection-if 0 · else 없는 if 0(SDK ^3.13 · 사전검사 T1·T2) ·
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 기록은 목록 == 목록으로 — 🔴 기록 목록에 hasLength 를 쓰지 않는다 · ⓗ 수가 달라진다) ·
   스켈레톤 1 = expect(find.byKey(const Key('j4-loading')), findsOneWidget) — 스피너 부재로 대신하지 않는다 ·
   테스트는 package:ui_journal/src/common/journal_common.dart 를 직접 import 해도 된다(JournalErrorView·JournalSkeleton 은 배럴이 export 하지 않는다) ·
   🆕 C4b-14 — Key 를 단 Text 마다 tester.widget<Text>(find.byKey(…)).data == 픽스처 필드(Key 가 있는지만 보지 않는다) · if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 ·
   카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 «잠금» = 제출 버튼 부재(또는 제출 중 비활성) + 모든 ChoiceChip.onSelected == null **둘 다** 단언한다(R2b 교훈 ① — 라벨 부재만으로 정의하지 않는다).
   🆕 늦게 구독되거나 값을 끝까지 내지 않는 StreamController 의 teardown = addTearDown(() { unawaited(ctrl.close()); })(R2b 교훈 ③ — addTearDown(ctrl.close) 는 구독자 0 이면 매달린다).
   🆕 «창»(카드 첫 값 전 · 결과 전 · 다음 접수증 전)을 보는 테스트는 그다음 값을 아직 add 하지 않은 StreamController 로 준다(R2b 교훈 ② — Stream.value 는 창 없이 곧바로 값을 낸다 ·
      이 카드의 창 = T4-06 · T4-07 · T4-09 · T4-10 · T4-13 card_skeleton · T4-16 · T4-15 의 재시도 창(재구독 뒤 첫 값 전)은 단언하지 않는다 — 카드 확정 · 로딩 갈래는 T4-13 이 본다).
   ⓡ = 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing); 를 **한 줄에 하나**(여러 경우를 도는 테스트는 본문에 한 줄) ·
      ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 전제 한 줄. 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄이어야 한다(사전검사 T5 · 접히면 기대 수를 final int 변수로 받아 줄을 짧게 — 아래 «ⓗ 한 줄 견본») —
      정적 묶음 S26·S27 이 git grep -c 로 센다 — 🔴 아래 최소 목록의 ⓡ·ⓗ 표시 수와 **정확히** 같아야 한다
      (test/blind_review_test.dart ⓡ 15 · ⓗ 7 · 다르면 제출 전에 테스트를 고친다 · PR 본문의 까닭 한 줄로 갈음하지 못한다 · 다른 채 내면 반려 · ⓡ·ⓗ 셈은 이 파일 하나 — 부록 테스트 파일은 세지 않는다).
      🆕 ⓗ 한 줄 견본 — 코드 글자로(경우마다 기대 수가 다른 ⓗ(T4-14)에 쓴다 · 변수·경우 이름은 재량):
        ㉠ 경우 목록(레코드)에 기대 수를 넣는 꼴(권장 — for 로 testWidgets 를 경우마다 만들 때):
          for (final (String caseName, int row, int flagCount, int blockingIcons) in <(String, int, int, int)>[
            ('row0', 0, 0, 0),
            ('row3', 3, 2, 2),
          ]) {
            … (testWidgets 본문 — 목록 단언 루프 앞에)
              expect(flags, hasLength(flagCount));
        🔴 반려 꼴(dart format 뒤 여러 줄): expect(flags, hasLength(caseName == 'row0' ? 0 : caseName == 'row3' ? 2 : 1)); 처럼 hasLength( 안에 중첩 삼항을 쓰기.
   🔴 ⓗ(hasLength)를 두는 곳은 아래 최소 목록에 ⓗ 로 표시한 자리뿐이다(7). 그 밖의 루프·기록 목록·경우 목록에는 hasLength( 를 쓰지 않는다.
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기 · 빈 if 블록 · 목록에 넣기)와 firstWhere 다. 양쪽에 expect 가 있는 if/else 는 허용한다.
      🆕 «없는 쪽» 견본 — 코드 글자로(R11b C4b-5 · R12b C12b-1 · R12d C12d-1 — 같은 꼴 세 번 · 조건·변수 이름은 재량):
        ㉠ if/else 문(권장):
          if (q.evidenceText != null) {
            expect(tester.widget<Text>(find.byKey(ValueKey<String>('j4-evidence-$i'))).data, q.evidenceText);
          } else {
            expect(find.byKey(ValueKey<String>('j4-evidence-$i')), findsNothing);
          }
        ㉡ 경우 목록의 bool 로 한 줄: expect(find.text(JournalLabels.blindReviewNext), wantNext ? findsOneWidget : findsNothing);
        🔴 반려 꼴(else 없는 if): if (q.evidenceText != null) { expect(…, q.evidenceText); }
   🆕 C4d-1 — «화면의 Text 전부» 단언은 이 코드 글자 꼴로 쓴다(T4-12 · R12d C12d-1 — Text 루프 자리에서 else 없는 if 가 세 번째로 났다 · if 짝 세기는 사전검사 T1·T2·T4 가 기계로 본다):
          final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
          expect(shown, isNotEmpty);
          for (final String? data in shown) {
            expect(data, isIn(allowed));
            expect(money.hasMatch(data!), isFalse);
            expect(percent.hasMatch(data), isFalse);
            expect(pnlWords.hasMatch(data), isFalse);
          }
        (allowed 는 null-aware 원소로 만든 Set<String> · data 가 null(Text.rich 등)이면 첫 단언이 실패한다 — 그것이 의도다 · 🆕 RichText·SelectableText 를 직접 쓴 글자는 이 목록에 아예 들어오지 않으므로 J-4 파일에는 그 위젯을 쓰지 않는다 = 정적 S30)
11 골든 = 새 PNG j4_* 12장 + 부록 S-12 j1_rebalance_* 4장 · --update-goldens 는 그 골든 테스트 파일만(폴더 지정 금지) · 기존 PNG 재생성 = 부록 S-1 목록만(--plain-name 으로 그 이름만) ·
   golden:approved 는 안 붙임(통합 담당) · 찍기 전 위치 전제(맨 아래 위젯 dy < 높이 — 아래 «골든»).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(멈출 수 있다) · 패키지 테스트는 packages/ui_journal 에서 flutter test 를 직접 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)) · directives_ordering 린트(import·export 는 경로 알파벳 순) · strict-raw-types·strict-inference(타입을 적는다).
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   이 카드의 위험: body.rationaleBefore(«ratio» 가 든다) 옆에 연산자 0 · 지역 변수 이름에 ratio·pct 금지 · duration·decoration 옆 연산자 0 · 글자 잇기는 보간.
14 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다**(C-43 은 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄
   (blind_review.dart 전부 · journal_common.dart 의 새 절 · labels.dart 의 새 절)의 주석에 이 낱말을 쓰지 않는다:
   AppRoutes · AppLinkSchemes · journal_draft · journalCommandApiProvider · DraftStore · Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · NumberFormat · GestureDetector · Colors ·
   Scaffold · AppBar · SafeArea · SnackBar · autoDispose · RunMode · operatingMode · FeatureFlags · watchState · maxLines · TextOverflow · .trim( · .where · .score · Decimal · Money (카드 문장을 가드 주석으로 옮겨 적지 않는다).
🔴 보고 규칙(strict 나눔 — 발주자 결정 2026-10-01 · 12 §3 R10~R16 머리 · 이 카드에 적용 — 옛 R2b 부록의 «1건이라도 재량 없이 반려» · «[x]/[—]» 줄은 이 나눔으로 바뀌었다) —
   ① 보고 **표기만**의 결함(경로 앞머리·백틱·요지 줄임·까닭 누락 등 — 내용은 사실이고 글자 모양만 카드와 다른 것) = 반려하지 않는다 → 통합 담당이 PR 본문을 정정하고 병합한다.
   ② **코드·테스트 결함**(카드 규칙 위반 — 예 규칙 10 «else 없는 if»)과 **거짓 주장**(보고 내용이 코드·파일·PNG 와 다름) = **반려**(재량 없음).
   ③ 아래 «예고 변이» 가 하나라도 테스트를 그대로 통과하면 = **반려**.
   그래도 원칙은 «출력 그대로» 다 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고(부록 S-1 은 시도한 모양과 PNG 결과를 그대로), 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다(글자는 테스트 글꼴이라 네모).
   🆕 배치·잘림 칸에는 PNG 에서 보이는 것만 쓴다 — 글자 내용·글자 길이의 차이 · «띠» · «고정» · «스크롤 밖» · 색·테마 이름 · 코드 이름(위젯·필드·Key — Row · Card · label 같은 낱말) · 픽스처 낱말 금지 ·
      버튼은 «버튼 글자» 로만(색 이름 금지 · 🆕 사전검사 ② G1 은 «버튼 글자» 를 글자 1줄로 세어, PNG 에서 상자·칩으로 잡히는 버튼이 있는 골든 행마다 🟡 를 낸다 —
      드라이런 8행(j4_before_reveal · j4_after_reveal · j4_after_reveal_open · j4_rejected × light/dark) · 🟡 는 멈춤 아님 · 그대로 «버튼 글자» 로 쓴다) · 칸 끝은 «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» 둘 중 하나로 고정(꼴 = «■ 제출» ③ 골든 표 줄 · 이 금지는 골든 표 칸 몫 — ③ 서술은 위젯·Key 이름 나열 그대로).
   🆕 C4d-5 셈 단위(발주자 확정 2026-10-15) — «글자 줄 n» = PNG 에 보이는 글자 **행** 수(줄바꿈된 행도 센다 · Text 위젯 수가 아니다 · 예 «글자 8줄(줄바꿈 포함)») ·
      «상자» = 테두리·모서리가 보이는 덩어리 · 폭 전체 배경은 «배경 덩어리» · «칩 n개» = 한 무리의 칩 개수(한 무리가 두 행으로 줄바꿈돼도 하나) · «상자» 속 글자 행은 세지 않는다(상자 하나뿐인 화면만 «상자 안 글자 n줄»).
   🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 GitHub 에서 PR 본문을 직접 고치지 않는다(채팅으로만 낸다 · 통합 담당이 «■ 제출» 의 섹션 머리 ①~⑤ 글자 그대로 PR 본문을 통째로 쓴다).
   🔴 정적 묶음 S05 의 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만 적습니다 — 괄호·위젯 이름·매개변수 이름·설명 금지(정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ · <파일> = git grep 출력의 경로 그대로 · 사전검사 R4).
   🔴 «까닭» 류의 수(테스트 파일별 통과 수 · ⓡ·ⓗ · S05·S06·S07 줄 수 · C-43 대상 수 · 10항 줄 수)는 손으로 세지 않는다 — 이 카드가 준 명령의 출력을 그대로 붙인다.
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M6.md 159~168행 10항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 · 항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다 · 사전검사 R5).
   ③ 은 코드를 위에서 아래로 읽으며 나오는 위젯·Key 이름 나열로만 씁니다(«순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(골든 위치 전제의 dy · 부록 S-1 시도 기록은 예외 — 아래 «질문 파일» 절). 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 23항 (prompt_M6.md 행 번호 = 169줄 판 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 2행 치환값 {{범위}}=«J-3 (+ R2 잔여 R-1~R-7)» · 106행 «이번 과제 범위» → 이 카드의 범위 = J-4 + 부록 S-1·S-8·S-10·S-11·S-12(위 첫 줄) · ※ «첫 과제는 J-1 하나» 도 덮는다
 ② 11행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변)
 ③ 12~13행 «라우트 상수로 딥링크» → DTO 링크(result.decisionLink · 칩 detailDeepLink · 배너 clearDeepLink)를 AppLinkOpener.open 에 · 쓰는 AppRoutes 상수 0(규칙 4)
 ④ 21~23행 «건수 집계도 재계산» → 그대로 유효 — 큐 행 수를 세지 않는다(«리뷰 대기 n건» 은 J-1 배지 글자 · J-4 에 «n/3»·«남은 n건» 0)
 ⑤ 28~30행 «목록이 비면 그 자리를 그리지 않는다» → 큐 빈 = 봉투 emptyKind 3갈래(J-1 꼴 · 고른 글자가 null 이면 문구 0) · detailLines 0줄 = 보조 줄 0 · evidenceText null = 줄 부재 · note null = 메모 머리·글 부재
 ⑥ 38~41행 자리표시자 → 링크 null = 부재
 ⑦ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ⑧ 48~54행 수치·금액 리터럴 금지 → 그대로 유효 · 결과 문장의 «%» 는 엔진 글자(K6 — 화면 리터럴 0 · C-43 ⑯ · 정적 S21·S22)
 ⑨ 88~89행 «자체 점검 10항 체크박스» · «스크린샷 4장» → «■ 제출» ②(10항 복사 상자) · ③(서술 + 골든 표)
 ⑩ 88~90행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅 · PR 본문은 통합 담당이 바꾼다)
 ⑪ 93~94행 «픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조» → 그대로 유효 · 예외 = 부록 S-1 목록(6장 — 드롭다운 모양이 바뀌어 픽셀이 바뀐다 · golden:approved = 통합 담당) 하나
 ⑫ 102~105행 역할 문단 · 106행 «첫 과제» → 폰 세로 하나(J-4 본문 = Android·iOS · 웹 = Q-D 전 «부재» 가드 · 셸 몫)
 ⑬ 107~114행 «읽을 문서 5개» → 아래 «먼저 읽을 것»
 ⑭ 116행 브랜치 예시·PR 제목 치환값(«[M6] J-3 완성 …») → 브랜치 ui/m6-j4-review · PR 제목은 «■ 제출» 이 정한다(«[M6] J-4 사후 blind 리뷰»)
 ⑮ 124~125행 «J-4는 채점 전에 손익·결과가 보이면 blind가 아닙니다» → 그대로 유효 + 🔴 v1.7 = 채점 전 카드 DTO 에 결과가 **없다**(가리는 코드 0 · 결과 섹션 = result != null 하나)
 ⑯ 155~157행 «⚠️ M2 미정의 7건(… J-4 리뷰 카드 …) — 이름을 지어내지 말고 요청 목록으로 · 픽스처 고정 모드로만» → J-4 = 계약 v1.7 정의(BlindReviewCard · BlindReviewQuestion · BlindReviewChoice ·
    BlindReviewResult · watchBlindReviewQueue · watchBlindReviewCard) — 지어낼 이름 없음 · 고정 모드 아님(창구로 받는다)
 ⑰ 158행 «명세 §7과 1:1» → 159~168행 10항(이 카드 밖의 4 · 9 의 «부분 동기» 는 [x] + 괄호 «이 카드 범위 밖»)
 ⑱ 163행 자체 점검 5 «가리는가» → [x] + 괄호 «채점 전 카드 데이터에 결과 없음(가리는 코드 0) · 화면 Text 에 금액·백분율·손익 낱말 0(T4-12) · 결과 섹션 = result != null 일 때만(T4-07·T4-13)»
 ⑲ 167행 자체 점검 9 «공통 상태 6종» → J-4 = 로딩·빈·에러·오래된 데이터·차단(공통 배너) · 부분 동기 = 이 카드 범위 밖(J-4 에 부분 동기 갈래 없음)
 ⑳ 168행 자체 점검 10 «골든 스냅샷을 재생성하지 않았는가» → [x] + 괄호 «재생성 = 부록 S-1 목록만(golden:approved 는 통합 담당) · 그 밖 M 0 · 미정의 타입 이름 짓기 0»
 ㉑ 153~154행 «J-3은 폰 전용 — 웹·iOS 빌드에 폼 포함 금지» → 그대로 유효 · 부록 S-1 은 journal_draft_form.dart 의 드롭다운만 고친다(배럴·import 방향 불변 · J-4 파일은 operator 라이브러리를 import 하지 않는다 — C-35 ⑥ · C-43 ⑭)
 ㉒ 31~32행 «손익 정렬·손익 필터 금지» → 그대로 유효 · J-4 결과 = 엔진 문장(수익률 % 글자 허용 — K6) · 정렬·필터 0 · S-12 회차 칩은 필터 축이 아니라 범위(시트에 회차 섹션 0)
 ㉓ 97~99행 «자리표시자(TODO(question-3))를 넣고 그 부분을 비워 두는 편이 …» → 넣지 않는다 · 모르는 것은 질문 파일로(규칙 14 «UI 자리표시자 금지»)

■ 먼저 읽을 것 (🔴 03·04·05 명세는 읽지 않음 · 02 는 아래 ③ 의 두 블록만)
 ① prompt_M6.md 전문
 ② 01 §16 — 16-1(한 문장) · 16-3(점수 축) · 16-4(창구 2 · 엔진 의무 · 코드 서명) · 16-5(필드 → 자리) · 16-6(상태 표 + 갈래별 정적 글자) · 16-7(결과·손익 경계) · 16-8(주입·호출 표) · 16-10(픽스처) · 16-16(이 카드)
    + 01 §15-3(15-3-4 JournalRebalanceScope · 15-3-6 생성자 인자 — 부록 S-12) · §12-4(J-3 상태 표 — 부록 S-1·S-10 의 J-3 테스트를 읽을 때)
 ③ 02 §3-4 의 v1.7 블록 — 머리글 «🆕 계약 v1.7 — `J-4` R3 범위»(찾는 말 = «J-4` R3 범위») ⓐ~ⓛ + 02 §3-1 의 ⓗ(찾는 말 = «ⓗ 계약 v1.5 — `J-1` 회차 칩») (가)~(타)·테스트 ③f~③o·골든 2
 ④ packages/domain_contracts/lib/ — src/dto/journal.dart 의 BlindReviewCard · BlindReviewQuestion · BlindReviewChoice · BlindReviewResult · DecisionJournalBody · DeviationBadge · JournalRebalanceScope ·
    src/dto/common.dart 의 ReasonChip · LinkAction · src/repositories/journal_repository.dart 끝 «계약 v1.7» 절 + watchRebalanceScope · src/commands/payloads.dart 의 BlindReviewScore ·
    src/commands/command_api.dart(submitBlindReviewScore · watchCommand) · src/commands/command_receipt.dart · src/enums/command.dart(CommandState 9값) ·
    testing.dart(UnimplementedJournalRepository — 두 창구는 동기로 던진다 · UnimplementedCommandApi · UnimplementedSafetyRepository · UnimplementedConfigRepository · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c43_blind_review_test.dart 머리 주석 + B 절(⑩~⑰)의 정규식(읽기만 — 이 카드의 화면 파일이 처음으로 그 대상이 된다)
 ⑥ packages/ui_journal/test/golden/README.md «🆕 R3» 절(기록 커밋 몫) + «🆕 R2» 절(높이 · 베이스라인 규칙) + «규칙»·«하네스» 절
 ⑦ 지금 코드(packages/ui_journal) — lib/ui_journal.dart · lib/l10n/labels.dart · lib/src/common/journal_common.dart 전문 · lib/src/timeline.dart(주입 프로바이더 · _EmptyState · 필터 시트 — 부록 S-12) ·
    lib/src/unknown_board.dart(배너 관용구의 원형 — 틀만) · lib/src/journal_read.dart(본문 칸 머리의 원형 — 틀만) · lib/src/journal_draft/journal_draft_form.dart(제출·접수증·구독의 원형 — 틀만 · 부록 S-1 의 드롭다운) ·
    test/journal_draft_test.dart(가짜·_receiptIn 모양) · test/timeline_test.dart(③b·③d·③e — 부록 S-12) · test/golden/golden_support.dart · test/golden/j3_golden_test.dart(루프 모양 · _kTallPhone)
 ⑧ packages/domain_contracts/fixtures/README.md 의 «계약 v1.7» 절 + 이 카드가 쓰는 픽스처(아래 «픽스처») ⑨ docs/ai-context/inbox/README.md · J4_questions.md 머리말

■ 본받지 않는 것 (ui_journal 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · timeline.dart·unknown_board.dart·journal_draft_form.dart 의 배너 관용구(activeFlags.where(… FlagIds.markerOnly.contains …)) → J-4 파일은 JournalSafetyBanners(safety:) 한 줄(분리는 공통 조각 안 · 기존 넷은 그대로 둔다)
 · J-3 의 FlutterError.reportError 보고(_report) → J-4 는 보고하지 않는다(제출 실패 = submitNotAccepted 1줄 · 구독 에러 = 마지막 접수증 유지 · 테스트가 takeException 없이 끝난다)
 · J-3 의 _canSubmit 안 trim() 길이 판정 → J-4 제출 조건 = 전 문항 선택 하나(K10 · 글자 판정 0)
 · J-3R(journal_read.dart)의 JournalReadContent 끼워 넣기 → J-4 는 저널 본문을 자기 파일 안에서 그린다(j3r-* Key 0 · watchDecisionJournal 0 — C-43 ⑪)
 · J-3 deviation 배지의 «if (spec.deviation.isDeviation)» → J-4 이탈 배지는 늘 label 그대로(isDeviation 0 — C-43 ⑬)
 · 테스트의 class … implements SafetyRepository(timeline_test 의 _FakeSafetyRepository) · 한국어 테스트 이름(timeline_test 의 «③ …») · «if (x != null) { expect… }» 조건부 단언(unknown_board_test :533 — 부록 S-10 이 고친다) ·
   _receiptIn 의 firstWhere(state) → 받침대 extends · ASCII 이름 · else 짝 · 접수증은 행 번호 + 전제 expect
 · 매 테스트 ProviderScope 통째 반복 → 띄우기 도우미 하나(pumpBlindReview) · 새 Key 는 화면id-하이픈(j4-…) · 아래 Key 표 21이름뿐

■ 주입 구조 (이름·타입 고정 = 01 §16-8 · 설계서 §2-5 글자 그대로 · 계약 변경 없음)
· 재사용(이름·위치 불변 · timeline.dart): journalTimelineRepositoryProvider(J-4 의 읽기 창구 둘도 이것) · journalSafetyRepositoryProvider · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider /
  journal_common.dart: JournalAsOfHeader · JournalStaleBanner · JournalReasonChip · JournalSkeleton · JournalErrorView · JournalBlockingFlags · JournalMarkerChips(🔴 기존 위젯 무수정 — 새로 짓지 않는다) /
  labels.dart: JournalLabels.retry · staleBannerTitle · draftSubmit · draftRuleCited · draftRationale · draftExpected · draftNote · submitNotAccepted(이미 있다 — 고치지 않는다).
· 🆕 lib 파일 1개 — lib/src/blind_review.dart(이것 말고 새 lib 파일을 만들지 않는다 — lib/src/blind_review/ 폴더도 만들지 않는다 · 조각은 이 파일 안 private 클래스·메서드로 ·
  private 로 나누면 파일 글자 순서와 화면 순서가 달라진다 — 제출 ③ 은 «렌더 순서»(호출을 그 자리에 펼친 순서)로 쓴다).
  import(directives_ordering · 6줄 · 쓰지 않는 import = analyze 실패):
     import 'dart:async'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
     import '../l10n/labels.dart'; → import 'common/journal_common.dart'; → import 'timeline.dart';   (journal_read.dart 와 같은 상대 경로 꼴 · 🔴 journal_draft 를 import 하지 않는다)
  프로바이더 셋 — 파일 머리(공개 위젯 앞)에 이 모양으로(이름·타입·throw 글자 고정 · 줄 배치는 dart format 결과):
    /// J-4 명령 주입 — 조립 앱 3종이 override 한다(01 §16-8 · 01 §13-9 v1.7 문언).
    final journalBlindReviewCommandApiProvider = Provider<CommandApi>(
      (Ref ref) => throw UnimplementedError(
        'journalBlindReviewCommandApiProvider must be overridden',
      ),
    );

    /// J-4 대기 목록(봉투) — 인자 없이 부른다(K24 · v1.7 = 실전 결정만).
    final journalBlindReviewQueueProvider = StreamProvider<ListResult<BlindReviewCard>>(
      (Ref ref) =>
          ref.watch(journalTimelineRepositoryProvider).watchBlindReviewQueue(),
    );

    /// J-4 고정 카드 1건 — 채점 집행 뒤 같은 스트림에 결과가 실린 값이 온다(02 그림 M6-13).
    final journalBlindReviewCardProvider =
        StreamProvider.family<BlindReviewCard, String>(
          (Ref ref, String decisionId) => ref
              .watch(journalTimelineRepositoryProvider)
              .watchBlindReviewCard(decisionId),
        );
  🔴 큐는 인자 없이(watchBlindReviewQueue() — C-43 ⑪ 이 인자를 막는다 · RunMode 낱말 0) · 이 파일이 부르는 창구는 이 둘 + CommandApi 의 submitBlindReviewScore · watchCommand 둘뿐 ·
     .family 에 autoDispose 를 붙이지 않는다(J-1 꼴 — 비-autoDispose 라 고정 카드를 놓아도 구독이 남는다 · 정상).
· 🆕 공개 위젯 — class JournalBlindReview extends ConsumerStatefulWidget { const JournalBlindReview({super.key}); } (State = 고정 카드 id · 선택 · 접수증 · 제출 중 · 접수 실패 — 아래 «코드 스케치»)
· 🆕 공통 배너 조각 — lib/src/common/journal_common.dart 끝(JournalErrorView 뒤)에 이 절 하나(기존 줄 무변경 · 기존 import 로 충분 — import 줄을 더하지 않는다):
    // ── 🆕 R3 — 공통 배너 조각(J-4 · 01 §16-8 K17) ─────────────────────────────

    /// 차단 카드(최대 2 + 넘침 수)와 표식 칩 — 받은 순서 그대로. 차단/표식 분리는 여기 한 곳.
    class JournalSafetyBanners extends StatelessWidget {
      const JournalSafetyBanners({super.key, required this.safety});

      final SafetyState? safety;

      @override
      Widget build(BuildContext context) {
        final List<BlockFlag> flags = safety?.activeFlags ?? <BlockFlag>[];
        final List<BlockFlag> blockingFlags = flags
            .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
            .toList();
        final List<BlockFlag> markerFlags = flags
            .where((BlockFlag f) => FlagIds.markerOnly.contains(f.flagId))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (blockingFlags.isNotEmpty) JournalBlockingFlags(flags: blockingFlags),
            if (markerFlags.isNotEmpty) JournalMarkerChips(flags: markerFlags),
          ],
        );
      }
    }
  (이 모양이 J-5 의 분리식을 그대로 옮긴 것이다 · 줄 배치는 dart format 결과 · 🔴 J-4 파일은 이 위젯을 부를 뿐 — 분리식을 J-4 파일에 다시 쓰지 않는다)
· 배럴 lib/ui_journal.dart 에 export 'src/blind_review.dart'; 한 줄 —
  🔴 자리 = export 'l10n/labels.dart'; 줄과 export 'src/decision_detail.dart'; 줄 **사이**(끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패) · 머리 주석은 고치지 않는다.
· import 하지 않는 것: lib/journal_draft.dart · lib/src/journal_draft/**(operator 라이브러리 — C-35 ⑥ · C-43 ⑭ 의 «journal_draft» 낱말) · lib/src/journal_read.dart(J-3R) · decision_detail.dart · unknown_board.dart.

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 listFixture / singleFixture / safetyFixtureRow · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 큐       listFixture(FixturePaths.m6BlindReviewQueue3, BlindReviewCard.fromJson) — rows 3 = d_20260811_c_28(행0) → d_mf_0002(행1) → d_mf_0004(행2) · 세 행 모두 result 없음 · journal 있음 ·
          문항 5 × 선택지 2(score 1 «예» · 0 «아니오» 의 엔진 글자) · contextChips 1(handbook 링크) · 문항 ④ 의 evidenceText 만 null · note = 행0·행2 있음 · 행1 없음 · emptyLabel null
 빈 큐    listFixture(FixturePaths.m6BlindReviewQueueEmpty, BlindReviewCard.fromJson) — rows 0 · emptyKind noData · emptyLabel 있음 · asOf.staleLabel 없음
 카드     singleFixture(FixturePaths.m6BlindReviewCardBefore, BlindReviewCard.fromJson) == 큐 행0(result 없음) ·
          singleFixture(FixturePaths.m6BlindReviewCardRevealed, …) = 행0 + result(보조 줄 1 · decisionLink 있음) ·
          singleFixture(FixturePaths.m6BlindReviewCardRevealedOpen, …) = 행1 + result(«미청산» · 보조 줄 0 · decisionLink 있음)
 접수증   listFixture(FixturePaths.m6BlindReviewReceipts6, CommandReceipt.fromJson).rows — 6행 = 0 requested · 1 heldForIntegrity · 2 executed · 3 expired ·
          4 rejected(BLIND_REVIEW_ANSWERS_INVALID) · 5 rejected(BLIND_REVIEW_ALREADY_SCORED) · 한 commandId · 🔴 행 번호로 고르고 전제 expect(receipts[k].state, …) · firstWhere 0 · copyWith 0(예외 = 규칙 10 ③ — T4-05 네 경우의 state 만)
 안전     safetyFixtureRow(n) — 0 정상(플래그 0) · 1 표식만(SELF_AUDIT_DUE — 차단 카드 0 · 칩 1) · 3 차단 2(RECON_MISMATCH · JOURNAL_MISSING · 화살표 2) · 4 무결성(LEDGER_INTEGRITY · 화살표 1)
 S-12     singleFixture(FixturePaths.m6JournalRebalanceScope1, JournalRebalanceScope.fromJson)(re_20260803_01 · label · range(isDefault false · label 있음)) ·
          journalFixture(FixturePaths.m6JournalRebalanceUnknown)(0행 · noData · emptyLabel) · journalFixture(FixturePaths.journal30) · rangePresets4 · sleeveCatalog4 · m6JournalFilterCatalog(필터 시트용)
 쓰지 않는 것: journal_read_* · journal_badges_2 · manual_fills_8(C-43 ⑤⑦ 대조용 — 화면이 부르지 않는 창구) · journal_draft_spec_*(J-4 와 무관 — S-1·S-10 은 기존 테스트가 쓰는 그대로).
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(예외 = 위 규칙 10 의 rows 슬라이스) · 픽스처를 복사해 고친 «내 픽스처» 금지 · 모자라면 질문 파일에.

■ 화면 — J-4 JournalBlindReview (01 §16-5 · 16-6 · 02 §3-4 v1.7 블록 ⓐ~ⓘ)
 상태 표(01 §16-6 — 행 = 상황 · 열 = 문항 / 제출 버튼 / 문구 / 결과 섹션):
   큐 첫 값 전 · 카드 첫 값 전                → JournalSkeleton(Key j4-loading) 하나(고지·배너 없음)
   큐·카드 스트림 에러                         → JournalErrorView(Key j4-fail · «다시 시도» = invalidate 로 재구독 · lastAsOfLabel = 그 AsyncValue 의 valueOrNull?.asOf.label)
   큐 빈(rows 0) + 고정 카드 없음              → 빈 갈래: 문구 = emptyKind 3갈래(noData · notApplicable → emptyLabel · notLoaded → asOf.staleLabel · 고른 글자가 null 이면 Text 0)
   result == null · 접수증 없음                → 문항 편집 / 제출 = 전 문항 선택 시에만 활성(K10) / — / 부재
   제출 중(Future 대기 · 새 접수증 전)         → 잠금(선택 표시 유지) / 비활성(이중 제출 금지) / — / 부재
   제출 Future 에러                             → 편집(선택 유지) / 활성 / submitNotAccepted 1줄(Key j4-submit-not-accepted) / 부재 · 그 뒤 결과가 오면 그 줄은 사라진다(배치 13 — 결과 갈래 0)
   requested·received·staleContext·heldForIntegrity·pendingLeaseConfirm·noOperator → 잠금 / 없음 / stateLabel / 부재
   rejected·expired                             → 편집(선택 유지) / 재제출(제출 버튼 그대로) / stateLabel / 부재
   executed · result == null(읽기 모델 지연)   → 잠금 / 없음 / stateLabel / 부재
   result != null(접수증 상태 무관 — ALREADY_SCORED 거부 뒤 포함) → 잠금(선택 유지 · 이 카드를 처음 연 것이면 선택 없음) / 없음 / 접수증이 있으면 stateLabel / **결과 섹션 + 정적 «다음 건»**
 갈래별 정적 글자(K15 · 01 §16-6 표 — 테스트 T4-13 이 그대로 단언):
   갈래              고지   제출   «다음 건»   «다시 시도»   submitNotAccepted
   스켈레톤          0      0      0           0             0
   에러              0      0      0           1             0
   빈                0      0      0           0             0
   카드(result null) 1      편집·rejected·expired·제출 중 = 1 / 접수증 잠금 = 0      0      0      Future 에러 뒤에만 1
   결과(result 있음) 1      0      1           0             0
 배치(카드 갈래 · 위 → 아래 · 🔴 이 순서 · 테스트 T4-03 이 사슬로 증명):
   Column[
    1 Padding(Text(JournalLabels.blindReviewNotice, key: const Key('j4-notice')))                     ← 🔴 스크롤 밖(Column 첫째 자식 · Expanded(ListView) 바깥 — «상단 고정 고지»)
    ── 이하 Expanded(ListView(children: […])) ──
    2 JournalAsOfHeader(key: const Key('j4-asof'), asOf: card.asOf)
    3 (오래됐으면) JournalStaleBanner(asOf: card.asOf)                                                  ← final bool stale = card.asOf.observedAt.add(card.asOf.staleAfter).isBefore(clock.nowUtc());
    4 Padding(Text(card.titleText, key: const Key('j4-title')))
    5 Padding(Text(card.promptText, key: const Key('j4-prompt')))
    6 JournalSafetyBanners(safety: safety)                                                              ← final SafetyState? safety = ref.watch(journalSafetyStateProvider).valueOrNull;
    7 Padding(Wrap(spacing: 6, runSpacing: 4, children: [for (final (int i, ReasonChip chip) in card.contextChips.indexed) JournalReasonChip(key: ValueKey<String>('j4-chip-$i'), chip: chip)]))
    8 Padding(DecoratedBox(테두리 = colorScheme.outline · 모서리 8 · J-3 이탈 배지 꼴) → Padding(Text(card.deviation.label, key: const Key('j4-deviation'))))   ← 🔴 늘(isDeviation 판정 0)
    9 Padding(Text(card.journalStateLabel, key: const Key('j4-journal-state')))
   10 (card.journal != null) Padding(key: const Key('j4-journal-body'), Column[ Text(body.writtenAtText) · const Text(JournalLabels.draftRuleCited) · Text(body.ruleCitedLabel) ·
        const Text(JournalLabels.draftRationale) · Text(body.rationaleBefore) · const Text(JournalLabels.draftExpected) · Text(body.expectedOutcome) ·
        (body.note != null) const Text(JournalLabels.draftNote) + Text(note) ])                       ← 원문 그대로(maxLines·overflow·trim·자르기 0 — 여러 줄 원문도 그대로)
   11 for (final (int i, BlindReviewQuestion q) in card.questions.indexed)
        Padding(key: ValueKey<String>('j4-question-$i'), Column[ Text(q.text) · (q.evidenceText != null) Text(evidence, key: ValueKey<String>('j4-evidence-$i')) ·
          Wrap(spacing: 8, runSpacing: 4, children: [for (final (int j, BlindReviewChoice c) in q.choices.indexed)
            ChoiceChip(key: ValueKey<String>('j4-choice-$i-$j'), label: Text(c.label), selected: _picked[q.questionId] == c,
                       onSelected: locked ? null : (bool _) { setState(() { _picked[q.questionId] = c; }); })]) ])
        ← 🔴 탭 = 그 선택지로 바꿈(같은 칩을 다시 탭해도 해제하지 않는다) · 점수 글자 0 · 선택 상태 = Map<String, BlindReviewChoice> _picked(State)
   12 (receipt != null) Padding(Text(receipt.stateLabel, key: const Key('j4-receipt')))   ← 접수증 = Text(02 §3-4 본문의 «전송 대기 칩»은 표현 꼴 — J-3 접수증 줄과 같은 Text · 카드 확정)
   13 (result == null && _submitNotAccepted) Padding(Text(JournalLabels.submitNotAccepted, key: const Key('j4-submit-not-accepted'), style: TextStyle(color: colorScheme.error)))
   14 (showSubmit) Padding(FilledButton(key: const Key('j4-submit'), onPressed: canSubmit ? () => _submit(card) : null, child: const Text(JournalLabels.draftSubmit)))
   15 (result != null) Padding(key: const Key('j4-result'), Column[ Text(result.processScoreText) · Text(result.outcomeText) ·
        for (final (int k, String line) in result.detailLines.indexed) Text(line, key: ValueKey<String>('j4-result-line-$k')) ·
        (link != null) OutlinedButton(key: const Key('j4-link-decisionLink'), onPressed: () { ref.read(journalLinkOpenerProvider).open(link.deepLink); }, child: Text(link.label)) ])
        ← final BlindReviewResult? result = card.result; · final LinkAction? link = result?.decisionLink; · 🔴 card.result! · link! 0(C-43 ⑬ — 지역 변수 null 검사로 좁힌다)
   16 (result != null) Padding(FilledButton(key: const Key('j4-next'), onPressed: _next, child: const Text(JournalLabels.blindReviewNext)))
   ]
 배치(빈 갈래 · 큐 rows 0 · 고정 카드 없음): ListView[ JournalAsOfHeader(key: const Key('j4-asof'), asOf: queue.asOf) · (오래됐으면) JournalStaleBanner(asOf: queue.asOf) · JournalSafetyBanners(safety: safety) ·
   (고른 글자 != null) Padding(padding: EdgeInsets.all(16), Text(label, key: const Key('j4-empty'))) ]   ← 고지·제출·«다음 건» 0 · 🔴 빈 문장을 Card 로 감싸지 않는다(J-5 꼴 Padding(Text))
 잠금·제출 계산(build 안 · 이 글자 그대로의 뜻 — 이름은 재량):
   final CommandReceipt? receipt = _receipt;
   final bool receiptLocks = receipt != null && switch (receipt.state) {
     CommandState.requested || CommandState.received || CommandState.staleContext || CommandState.heldForIntegrity ||
     CommandState.pendingLeaseConfirm || CommandState.noOperator || CommandState.executed => true,
     CommandState.rejected || CommandState.expired => false,
   };                                                                                                 ← 🔴 CommandState 를 쓰는 곳은 이 switch 하나(정적 S07 = dart format 뒤 8줄 — `CommandState.rejected || CommandState.expired => false,` 가 한 줄 · 9값 전부 등장)
   final bool showSubmit = result == null && !receiptLocks;
   final bool locked = result != null || receiptLocks || _submitting;
   final bool allAnswered = card.questions.every((BlindReviewQuestion q) => _picked.containsKey(q.questionId));
   final bool canSubmit = showSubmit && !_submitting && allAnswered;
 코드 스케치(State · 모양은 그대로, 이름·줄 배치·패딩 정수는 재량 — 테스트가 동작을 단언한다):
   String? _pinnedId; final Map<String, BlindReviewChoice> _picked = <String, BlindReviewChoice>{}; CommandReceipt? _receipt;
   StreamSubscription<CommandReceipt>? _cmdSub; bool _submitting = false; bool _submitNotAccepted = false;
   dispose() → unawaited(_cmdSub?.cancel() ?? Future<void>.value()) 뒤 super.dispose()
   build:
     final Clock clock = ref.watch(journalClockProvider); final SafetyState? safety = ref.watch(journalSafetyStateProvider).valueOrNull;
     final String? pinned = _pinnedId;
     if (pinned == null) → final AsyncValue<ListResult<BlindReviewCard>> queueAsync = ref.watch(journalBlindReviewQueueProvider);
        queueAsync.when(loading: 스켈레톤 · error: JournalErrorView(key: const Key('j4-fail'), lastAsOfLabel: queueAsync.valueOrNull?.asOf.label, onRetry: () => ref.invalidate(journalBlindReviewQueueProvider)) ·
          data: (queue) → queue.rows.isEmpty ? 빈 갈래 : (_pinnedId = queue.rows[0].decisionId; 그 id 로 카드 갈래))
          ← 🔴 고정은 «첫 data 의 rows[0]» 한 번 — 이 프레임에 바로 그리므로 setState 없이 State 필드에 둔다 · 고정된 동안 큐를 watch 하지 않는다(재방출 = 화면 변화 0 · T4-01) ·
             listenManual 로 잡는 꼴도 허용(재량) — 단 T4-01·T4-10 이 그대로 통과해야 한다
     카드 갈래(id) → final AsyncValue<BlindReviewCard> cardAsync = ref.watch(journalBlindReviewCardProvider(id));
        cardAsync.when(loading: 스켈레톤 · error: JournalErrorView(key: const Key('j4-fail'), lastAsOfLabel: cardAsync.valueOrNull?.asOf.label, onRetry: () => ref.invalidate(journalBlindReviewCardProvider(id))) ·
          data: (card) → 위 «배치(카드 갈래)»)
   _submit(BlindReviewCard card) async:
     final BlindReviewScore score = BlindReviewScore(decisionId: card.decisionId, answers: <String, int>{
       for (final BlindReviewQuestion q in card.questions) q.questionId: _picked[q.questionId]!.score,
     });                                                                                              ← 🔴 .score 가 나오는 줄은 이 한 줄(정적 S10 = 1줄 · C-43 ⑫ 의 맵 값 자리)
     setState(() { _submitting = true; _submitNotAccepted = false; });
     final CommandReceipt initial;
     try { initial = await ref.read(journalBlindReviewCommandApiProvider).submitBlindReviewScore(score); }
     catch (_) { if (mounted) { setState(() { _submitting = false; _submitNotAccepted = true; }); } return; }   ← 선택 유지 · 보고 0
     if (!mounted) return;
     setState(() { _submitting = false; _receipt = initial; });
     _subscribe(initial.commandId);
   _subscribe(String commandId):
     unawaited(_cmdSub?.cancel() ?? Future<void>.value());
     _cmdSub = ref.read(journalBlindReviewCommandApiProvider).watchCommand(commandId).listen(
       (CommandReceipt r) { if (mounted) { setState(() { _receipt = r; }); } },
       onError: (Object e, StackTrace st) {},                                                         ← 마지막 접수증 유지(01 §8 미결 51 ③) · 문구 0 · 재구독 0
     );
   _next():
     unawaited(_cmdSub?.cancel() ?? Future<void>.value()); _cmdSub = null;
     setState(() { _pinnedId = null; _picked.clear(); _receipt = null; _submitting = false; _submitNotAccepted = false; });
     ← 다음 build 가 큐의 최신 값 rows[0] 을 다시 고정한다(없으면 빈 갈래) · 🔴 고정 카드가 큐에서 빠졌는지 화면이 확인하지 않는다(엔진 의무)
 🔴 상태를 고르는 것은 _pinnedId(null 여부) · 큐 rows(빈 여부) · emptyKind(3갈래) · card.result(null 여부) · 접수증 state(잠금 switch 하나) · _submitting · _submitNotAccepted · 전 문항 선택 · 링크·note·evidenceText(null 여부) 뿐이다.
    isDeviation · kindCode · rejectReasonCode · score · 문장 글자(포함·비교)로 고르지 않는다.
 🔴 뒤로가기 = 점수 미저장(02 수용 (b)) = State 소멸 — dispose 에서 제출·저장 0 · 초안 포트 0.
 간격(SizedBox 높이·Padding 정수)·글자 굵기·크기·모서리는 재량(질문 아님) — 단 소수부 ≠ 0 소수 리터럴 0.

■ Key 표 (J-4 Key 21이름 — 정본 = 이 표의 글자 · 🔴 여기 없는 j4- Key 를 더하지 않는다 · 이름에 영어 색·테마 낱말(error · surface …)을 넣지 않는다 — 보고 글의 사전검사 R2)
   스켈레톤      Key('j4-loading')                              JournalSkeleton(key:) — 큐·카드 첫 값 전
   에러          Key('j4-fail')                                 JournalErrorView(key:) — 큐·카드 스트림 에러
   빈 문장       Key('j4-empty')                                Text(고른 빈 글자) — 빈 갈래 · 고른 글자가 null 이면 0
   고지          Key('j4-notice')                               Text(JournalLabels.blindReviewNotice) — 카드 갈래 · 스크롤 밖
   머리          Key('j4-asof')                                 JournalAsOfHeader(key:) — 카드·빈 갈래
   제목          Key('j4-title')                                Text(card.titleText)
   안내          Key('j4-prompt')                               Text(card.promptText)
   문맥 칩       ValueKey<String>('j4-chip-$i')                  JournalReasonChip(key:) — i = .indexed
   이탈 배지     Key('j4-deviation')                            Text(card.deviation.label)
   저널 상태     Key('j4-journal-state')                        Text(card.journalStateLabel)
   저널 본문     Key('j4-journal-body')                         Padding(본문 Column) — journal 있을 때만
   문항          ValueKey<String>('j4-question-$i')              Padding(문항 Column) — i = .indexed
   근거 줄       ValueKey<String>('j4-evidence-$i')              Text(q.evidenceText) — 있을 때만
   선택지        ValueKey<String>('j4-choice-$i-$j')             ChoiceChip(key:) — j = 선택지 .indexed
   접수증        Key('j4-receipt')                              Text(receipt.stateLabel) — 접수증 있을 때만
   접수 실패     Key('j4-submit-not-accepted')                  Text(JournalLabels.submitNotAccepted) — Future 에러 뒤에만
   제출          Key('j4-submit')                               FilledButton — showSubmit 일 때만
   결과          Key('j4-result')                               Padding(결과 Column) — result 있을 때만
   보조 줄       ValueKey<String>('j4-result-line-$k')           Text(result.detailLines[k])
   이 결정 보기  Key('j4-link-decisionLink')                    OutlinedButton — decisionLink 있을 때만
   다음 건       Key('j4-next')                                 FilledButton — result 있을 때만
   (질문 text · 저널 본문 칸 · 칸 머리 · 결과 processScoreText·outcomeText · 배너 · 신선도 배너에는 Key 를 달지 않는다 — 테스트는 find.text · find.descendant 로 찾는다)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량 — 커밋 제목이 그 커밋 내용과 맞기만 하면 된다(발주자 결정 2026-10-14 ④ · 12 §3 공통 조문 «커밋 = 제목만 맞추기»)
   (각 단계 끝 «커밋 «…»» 는 단계마다 하나씩 나눌 때의 권장 제목이다(7개) · 합치거나 더 나누면 제목을 그 커밋에 실제로 든 내용에 맞게 쓴다 — 제목 ≠ 내용 = 보고 규칙 ① 표기(반려 아님) ·
    🔴 그대로인 것: amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일(그 뒤 커밋 0 · 제출 단계의 format 0 changed) · 아래 «이 커밋 전에» 의 정적 묶음 미리 돌리기)
 (1) 정적 라벨 2개(labels.dart 끝 R3 절) + JournalSafetyBanners(journal_common.dart 끝 절) — 기존 화면·위젯 무변경 · 0단계의 시작 기준 N 이 그대로 통과. 커밋 «[M6] R3 (1) 정적 라벨 · 공통 배너 조각»
 (2) lib/src/blind_review.dart(프로바이더 셋 + JournalBlindReview) + 배럴 export 한 줄(정렬 자리) + test/blind_review_fakes.dart + test/blind_review_test.dart(T4-01~T4-17).
     🔴 이 커밋 전에 packages/ui_journal 에서 «정적 묶음» 32줄을 한 번 미리 돌려 본다 — 🔴 git grep 은 add 하지 않은 새 파일을 보지 않는다(출력 없음 = 거짓 안심) →
        먼저 git add . (packages/ui_journal 안에서 · 커밋은 그다음)로 올린 뒤 돌린다(아래 «정적 묶음» 의 기대와 대조 · 주석도 센다 — 규칙 15). 커밋 «[M6] R3 (2) J-4 사후 blind 리뷰 화면 + 테스트»
 (3) 골든 12장 — test/golden/j4_golden_test.dart. 커밋 «[M6] R3 (3) 골든 j4_* 12장»
 (4) 부록 S-1 — journal_draft_form.dart 드롭다운 + journal_draft_test.dart 에 S-1 테스트 1개 + 재생성 목록 PNG(아래 «부록 S-1»). 커밋 «[M6] R3 (4) 부록 S-1 드롭다운 둘째 줄 + j3 PNG 재생성»
 (5) 부록 S-8 · S-10 · S-11 — 기존 테스트 보강(lib 0). 커밋 «[M6] R3 (5) 부록 S-8·S-10·S-11 테스트 보강»
 (6) 부록 S-12 — timeline.dart + test/timeline_rebalance_test.dart(T1-3f~T1-3o) + 기존 J-1 가짜의 watchRebalanceScope 한 덩어리 + test/golden/j1_rebalance_golden_test.dart(4장).
     커밋 «[M6] R3 (6) 부록 S-12 J-1 회차 칩 + 골든 j1_rebalance_* 4장»
 (7) melos.bat run format:fix · 질문 파일(J4_questions.md — 골든 dy 측정 행 A1~A8 · 부록 S-1 시도 기록 · 그 밖의 질문) · 커밋 «[M6] R3 (7) format · 질문».
     🔴 (7) 뒤에 다른 커밋을 더하지 않는다(제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지 · 예외 하나 = «■ 제출» 사전검사 ① 의 🔴 를 고치는 커밋 (8)).

■ 정적 라벨 — JournalLabels 끝에(파일의 마지막 절 = R2b 절 submitNotAccepted 뒤) 절 주석(// ── 🆕 R3 — J-4 사후 blind 리뷰 ──…)과 함께 2개(이름·글자 고정):
   blindReviewNotice = '결과는 채점 후 공개됩니다'   (02 §3-4 «상단 고정 고지» 글자 그대로 · K15 · 카드 갈래에서만)
   blindReviewNext = '다음 건'                        (02 §3-4 «공개 후 「다음 건」» · K15 · 결과 갈래에서만)
   (제출 = draftSubmit '제출' 재사용 · 다시 시도 = retry · 접수 실패 = submitNotAccepted · 본문 칸 머리 = draftRuleCited·draftRationale·draftExpected·draftNote 재사용 — 고치지 않는다.)
   🔴 만들지 않는 글자(엔진 몫): 점수·«n점»·«과정 점수»·«좋은 결정» · 건수·«n/3»·«남은 n건» · «결과 없음»·«미청산»·«결과 미확정» · «예»·«아니오»(선택지 글자) · 문항 글자 · «채점»·«리뷰할 결정이 없습니다» ·
      «이 결정 보기»(링크 label) · «저널 작성됨/미작성» · 제목·안내 · «전송 대기»·«거부됨» 류(stateLabel) · «원»·«%».
   🔴 라벨 글자에 숫자·금액을 넣지 않는다(C-32 · labels.dart 도 본다). 더 필요하면 더하지 말고 질문 파일에 적는다(이 카드의 새 정적 라벨은 2개로 고정).

■ 테스트 최소 목록 (J-4 · 번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S26·S27 과 대조 · 파일 = test/blind_review_test.dart)
공통: 띄우기 = pumpBlindReview(뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 — 드라이런 확인: 탭 대상 전부 보임 · 내용 끝 ≈1488) · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Stream/Future ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨 = kGoldenNowUtc.add(const Duration(days: 2))) · 안전 기본 = safetyFixtureRow(0) · 기대 글자는 픽스처에서 ·
  값 단언 전 pump 두 번 = pumpBlindReview(끝에 pump 1번) 뒤 각 테스트에서 await tester.pump(); 를 한 번 더(스트림이 도착할 틈) · 컨트롤러에 add 할 때마다 await tester.pump(); 두 번 ·
  🆕 큐가 마운트 뒤에 오는 테스트(T4-01 의 ctrl.add(queue3))와 큐 재구독 뒤 카드가 처음 구독되는 테스트(T4-15 의 재시도 탭 뒤)는 pump 세 번(큐 값 → 고정 → 카드 구독 → 카드 값 — 두 번이면 아직 j4-loading · 드라이런 실측) ·
  탭 = 도우미 pickBlindReviewAnswers(위 → 아래 · 탭 전 ensureVisible) · 제출 탭 = await tester.ensureVisible(find.byKey(const Key('j4-submit'))); → tap → pump 두 번.
  🔴 경우가 여럿인 테스트(«…마다» — T4-02·03·05·10·12·13·14·15·17)는 for 로 testWidgets 를 경우마다 만든다(이름 = '<번호> <설명> <경우 이름>' · ⓡ·ⓗ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 같다) ·
     pumpBlindReview 는 한 테스트에서 한 번만 부른다(T4-11 의 pumpWidget(const SizedBox()) 는 «떠나기» 동작이라 예외).
     계획 = 뷰 45개(T4-01 1 · 02 3 · 03 3 · 04 1 · 05 10 · 06 1 · 07 1 · 08 1 · 09 1 · 10 2 · 11 1 · 12 3 · 13 7 · 14 4 · 15 3 · 16 1 · 17 2 · 드라이런 «+45») · testWidgets 줄 17(경우 루프 안의 testWidgets( 는 한 줄로 센다 · test( 를 쓰지 않는다).
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순 · 드라이런 확인: 이 9줄 그대로 analyze «No issues found!»):
     import 'dart:async'; →
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_test/flutter_test.dart'; →
     import 'package:ui_journal/src/common/journal_common.dart'; → import 'package:ui_journal/ui_journal.dart'; →
     import 'blind_review_fakes.dart'; → import 'golden/golden_support.dart';   (쓰지 않는 import 가 있으면 analyze 가 실패한다 — 실제로 쓰는 것만)
  🆕 test/blind_review_fakes.dart(새 파일 · 공개 이름 · 🔴 한국어 리터럴 0 · import 7줄 = 'package:domain_contracts/domain_contracts.dart' → 'package:domain_contracts/testing.dart' → 'package:flutter/material.dart' →
     'package:flutter_riverpod/flutter_riverpod.dart' → 'package:flutter_test/flutter_test.dart' → 'package:ui_journal/ui_journal.dart' → 'golden/golden_support.dart'):
    class FakeBlindReviewJournalRepository extends UnimplementedJournalRepository {
      FakeBlindReviewJournalRepository({required Stream<ListResult<BlindReviewCard>> Function(int call) queue, required Stream<BlindReviewCard> Function(String decisionId, int call) card})
      final List<RunMode> queueModes = <RunMode>[];    ← watchBlindReviewQueue 의 mode 를 호출마다 더한다(인자 없이 = 기본 live)
      final List<String> cardCalls = <String>[];        ← watchBlindReviewCard 의 decisionId 를 호출마다 더한다
      watchBlindReviewQueue({RunMode mode = RunMode.live}) = 기록 → queue(호출 순번 0부터) · watchBlindReviewCard(id) = 기록 → card(id, 호출 순번 0부터 — 창구 전체의 순번)
    }   (그 밖 창구는 override 하지 않는다 — 받침대가 던진다 · 화면이 부르면 테스트가 실패한다)
    class FakeBlindReviewCommandApi extends UnimplementedCommandApi {
      FakeBlindReviewCommandApi({required Future<CommandReceipt> Function(BlindReviewScore score, int call) submit, required Stream<CommandReceipt> Function(String commandId) watch})
      final List<BlindReviewScore> submitted = <BlindReviewScore>[]; final List<String> watched = <String>[];
      submitBlindReviewScore(score) = 기록 → submit(score, 순번) · watchCommand(id) = 기록 → watch(id)
    }
    class FakeBlindReviewSafetyRepository extends UnimplementedSafetyRepository { FakeBlindReviewSafetyRepository(SafetyState state) · watchState() = 호출마다 Stream<SafetyState>.value(state) }
    List<Override> blindReviewOverrides({required FakeBlindReviewJournalRepository repo, required FakeBlindReviewCommandApi commands, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 5개(journalTimelineRepositoryProvider · journalSafetyRepositoryProvider(FakeBlindReviewSafetyRepository(safety ?? safetyFixtureRow(0))) · journalClockProvider(clock ?? FixedClock(kGoldenNowUtc)) ·
          journalLinkOpenerProvider(opener ?? RecordingLinkOpener()) · journalBlindReviewCommandApiProvider(commands))
    Future<void> pumpBlindReview(WidgetTester tester, {required … repo, required … commands, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
        ← 390×2400 · DPR 1.0 · teardown 2 · ProviderScope(overrides: blindReviewOverrides(…)) → MaterialApp(home: Scaffold(body: JournalBlindReview())) · 끝에 pump() 1번
    Future<void> pickBlindReviewAnswers(WidgetTester tester, BlindReviewCard card, int Function(int questionIndex) choiceOf)
        ← 문항 i 마다 find.byKey(ValueKey<String>('j4-choice-$i-${choiceOf(i)}')) → ensureVisible → tap → pump
    void expectBlindReviewChoicesLocked(WidgetTester tester, {required bool locked})
        ← final List<ChoiceChip> chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList(); expect(chips, isNotEmpty); for (…) expect(c.onSelected == null, locked);
    List<String> blindReviewPickedKeys(WidgetTester tester)      ← selected 인 ChoiceChip 의 Key 글자 목록(위 → 아래)
        코드 꼴(드라이런 그대로 · 🔴 if·collection-if 0 — fakes 파일도 사전검사 T1·T2 대상 · 거르기 = null-aware 원소):
          => <String>[for (final ChoiceChip c in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) ?(c.selected ? (c.key! as ValueKey<String>).value : null)];
    List<String?> blindReviewTextsOutsideBottom(WidgetTester tester)
        ← find.byType(Text).evaluate() 중 Key j4-asof · j4-receipt · j4-submit-not-accepted · j4-submit · j4-result · j4-next 의 자손(matchRoot: true) Element 를 뺀 Text 의 data 목록(위 → 아래 · K18)
        코드 꼴(드라이런 그대로): final Set<Element> bottom = <Element>{ for (final String k in <String>['j4-asof', 'j4-receipt', 'j4-submit-not-accepted', 'j4-submit', 'j4-result', 'j4-next'])
            ...find.descendant(of: find.byKey(Key(k)), matching: find.byType(Text), matchRoot: true).evaluate() };
          return <String?>[for (final Element e in find.byType(Text).evaluate()) ?(bottom.contains(e) ? null : (e.widget as Text).data)];
    골든은 pumpBlindReview 를 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: blindReviewOverrides(…), child: const JournalBlindReview()), brightness: b, logicalSize: _kTallPhone).
    🔴 새 띄우기 도우미는 pumpBlindReview 하나 · 테스트마다 ProviderScope 를 통째로 쓰지 않는다.
  파일 머리(main() 안 · testWidgets 밖)에서 픽스처를 한 번 읽는다: queue3 · queueEmpty · before · revealed · revealedOpen · receipts(위 «픽스처» 의 읽는 법) ·
    Stream<CommandReceipt> receiptThenFail(CommandReceipt r) async* { yield r; throw StateError('watch'); }   ← T4-04 의 watch(접수증 하나를 낸 뒤 에러 · 지역 함수 선언)
    ListResult<BlindReviewCard> queueFrom(int k) => queue3.copyWith(rows: queue3.rows.sublist(k));   ← 머리가 행 k 인 큐(슬라이스 · 규칙 10 · 지역 함수 선언 — 변수에 담으면 prefer_function_declarations_over_variables 린트)
    금지어 정규식 3개(한국어는 \u 이스케이프로만): money = RegExp(r'\d[\d,.]*\s*(\uC5B5|\uB9CC|\uCC9C)?\s*\uC6D0|\u20A9') · percent = RegExp(r'\d+(\.\d+)?\s*%') · pnlWords = RegExp(r'\uC190\uC775|\uC218\uC775|\uD3C9\uAC00\uC561')
J-4 — test/blind_review_test.dart
 T4-01 큐 머리 고정 — 큐 = StreamController(addTearDown unawaited close) · 카드 = (id, _) → Stream.value(before) · ctrl.add(queue3) → pump 세 번(위 공통) →
        expect(repo.queueModes, <RunMode>[RunMode.live]) · expect(repo.cardCalls, <String>[queue3.rows[0].decisionId]) · tester.widget<Text>(j4-title).data == before.titleText · j4-prompt == before.promptText ·
        j4-notice data == JournalLabels.blindReviewNotice · find.ancestor(of: find.byKey(const Key('j4-notice')), matching: find.byType(Scrollable)) findsNothing ·
        find.ancestor(of: find.byKey(const Key('j4-title')), matching: find.byType(Scrollable)) findsOneWidget →
        ctrl.add(queueFrom(1)) → pump 두 번 → cardCalls 그대로 <String>[queue3.rows[0].decisionId] · j4-title 그대로 before.titleText · find.text(queue3.rows[1].titleText) findsNothing · ⓡ.
 T4-02 빈 큐 — 세 경우 (noData · queueEmpty 그대로 · 보임) · (notApplicable · copyWith(emptyKind: EmptyKind.notApplicable) · 보임) · (notLoaded · copyWith(emptyKind: EmptyKind.notLoaded) · 안 보임)마다(큐 = Stream.value(그 값)):
        보이면 expect(v.emptyLabel, isNotNull) → tester.widget<Text>(j4-empty).data == v.emptyLabel / 안 보이면 expect(v.asOf.staleLabel, isNull) → j4-empty findsNothing · find.text(queueEmpty.emptyLabel!) findsNothing(이 둘은 안 보이는 갈래 = else 쪽에만 · if/else 짝) ·
        공통 j4-asof 1 · find.text(v.asOf.label) 1 · j4-notice 0 · j4-submit 0 · j4-next 0 · expect(repo.cardCalls, isEmpty) · ⓡ.
 T4-03 카드 본문 — row0 · row1 · row2 마다(큐 = Stream.value(queueFrom(k)) · 카드 = Stream.value(queue3.rows[k]) · c = queue3.rows[k] · 열린 오프너):
        j4-title·j4-prompt·j4-deviation·j4-journal-state 의 Text data == c.titleText · c.promptText · c.deviation.label · c.journalStateLabel ·
        ⓗ expect(c.contextChips, hasLength(1)) → i 마다 find.descendant(of: find.byKey(ValueKey<String>('j4-chip-$i')), matching: find.text(chip.label)) findsOneWidget · j4-chip-<길이> 0 ·
        expect(c.journal, isNotNull) → body = c.journal! → find.descendant(of: j4-journal-body, matching: find.text(…)) 가 writtenAtText · ruleCitedLabel · rationaleBefore · expectedOutcome 마다 1 ·
        tester.widget<Text>(find.text(body.rationaleBefore)) 의 maxLines isNull · overflow isNull(원문 그대로) ·
        note — 있으면 find.text(body.note!) 1 · find.text(JournalLabels.draftNote) 1 / 없으면 find.text(JournalLabels.draftNote) 0(if/else 짝) ·
        ⓗ expect(c.questions, hasLength(5)) → i 마다 find.descendant(of: j4-question-$i, matching: find.text(q.text)) 1 · 근거 줄 = 위 «없는 쪽» 견본 ㉠(있으면 data == evidenceText / 없으면 0) ·
          ⓗ expect(q.choices, hasLength(2)) → j 마다 (tester.widget<ChoiceChip>(j4-choice-$i-$j).label as Text).data == choice.label · .selected isFalse · find.text('${choice.score}') findsNothing(점수 글자 0) ·
        사슬 = 이웃끼리 tester.getTopLeft(…).dy lessThan: j4-asof → j4-title → j4-prompt → j4-chip-0 → j4-deviation → j4-journal-state → j4-journal-body → j4-question-0 → … → j4-question-4 → j4-submit ·
        j4-chip-0 탭 → pump → expect(c.contextChips[0].detailDeepLink, isNotNull) → opener.opened == <String>[c.contextChips[0].detailDeepLink!] · ⓡ.
 T4-04 제출 — 활성 조건 · 인자 · 이중 제출 — 큐 queue3 · 카드 before · 제출 = Completer<CommandReceipt>(끝내지 않은 채 시작) · 🆕 watch = (_) → receiptThenFail(receipts[0])(접수증을 낸 뒤 에러 — 01 §16-8 ④ «구독 에러 = 마지막 접수증 유지»):
        tester.widget<FilledButton>(j4-submit).onPressed isNull → 문항 0~3 을 (i % 2) 선택지로 탭할 때마다 onPressed isNull → 문항 4 탭 → onPressed isNotNull →
        제출 탭 → expect(commands.submitted, <BlindReviewScore>[BlindReviewScore(decisionId: before.decisionId, answers: <String, int>{ for (final (int i, BlindReviewQuestion q) in before.questions.indexed) q.questionId: q.choices[i % 2].score })]) ·
        제출 중: j4-submit 1 · onPressed isNull · expectBlindReviewChoicesLocked(locked: true) → 제출 다시 탭 → submitted 그대로 1건(목록 == 목록) →
        completer.complete(receipts[0]) → pump 두 번 → tester.widget<Text>(j4-receipt).data == receipts[0].stateLabel · j4-submit 0 · expect(commands.watched, <String>[receipts[0].commandId]) ·
        🆕 구독 에러 뒤: expect(find.byKey(const Key('j4-fail')), findsNothing) · expect(tester.takeException(), isNull)(접수증 data 는 위 단언 그대로) · ⓡ.
 T4-05 접수증 갈래 — 열 경우 ㉠(이름, 행, 상태, 잠금, 상태만 바꿈) (requested, 0, CommandState.requested, 잠금, false) · (held, 1, heldForIntegrity, 잠금, false) · (executed, 2, executed, 잠금, false) ·
        (expired, 3, expired, 편집, false) · (rejected_invalid, 4, rejected, 편집, false) · (rejected_already, 5, rejected, 편집, false) ·
        🆕 (received, 0, received, 잠금, true) · (stale_context, 0, staleContext, 잠금, true) · (pending_lease, 0, pendingLeaseConfirm, 잠금, true) · (no_operator, 0, noOperator, 잠금, true)마다(잠금 switch 9값 전부 — 넷은 규칙 10 ③):
        ⓗ expect(receipts, hasLength(6)) → expect(receipts[row].state, stateOnly ? CommandState.requested : state) →
        final CommandReceipt receipt = stateOnly ? receipts[row].copyWith(state: state) : receipts[row]; · 카드 = Stream.value(before)(결과 안 옴) · 제출 = Future.value(receipt) · watch = Stream.value(receipt) ·
        pickBlindReviewAnswers(tester, <그 카드>, (int i) => 0) → 제출 탭 → j4-receipt data == receipt.stateLabel · j4-result 0 · j4-next 0 ·
        잠금이면 j4-submit findsNothing · expectBlindReviewChoicesLocked(locked: true) / 편집이면 j4-submit 1 · onPressed isNotNull · expectBlindReviewChoicesLocked(locked: false)(if/else 짝) ·
        그 뒤 공통 blindReviewPickedKeys == 탭한 Key 5개 · ⓡ.
 T4-06 제출 Future 에러 — expect(receipts[3].state, CommandState.expired) · 카드 = StreamController(add(before) · 결과는 아직 add 하지 않음) ·
        제출 = 순번 1 이면 Future.value(receipts[3]) · 그 밖(순번 0 · 2)은 Future.error(StateError('offline')) · watch = Stream.value(receipts[3]) ·
        pickBlindReviewAnswers(tester, before, (int i) => i % 2) → 제출 탭 → j4-submit-not-accepted data == JournalLabels.submitNotAccepted ·
        j4-submit onPressed isNotNull · expectBlindReviewChoicesLocked(locked: false) · blindReviewPickedKeys 그대로 · j4-receipt 0 · expect(commands.watched, isEmpty) →
        🆕 제출 다시 탭(순번 1 = 성공 · expired = 편집) → submitted 2건(같은 점수 둘 — 목록 == 목록) · j4-submit-not-accepted findsNothing(재제출 시작이 지운다) · j4-receipt data == receipts[3].stateLabel →
        🆕 제출 한 번 더(순번 2 = 에러) → j4-submit-not-accepted findsOneWidget → 카드 컨트롤러에 add(revealed) → pump 두 번 →
        j4-submit-not-accepted findsNothing(결과 갈래 0 — 배치 13) · j4-result 1 · j4-next 1 · ⓡ.
 T4-07 집행 뒤 결과 도착 — 카드 = StreamController(add(before)) · 제출 = Future.value(receipts[2]) · watch = Stream.value(receipts[2]) · pickBlindReviewAnswers(tester, before, (int i) => 0) → 제출 탭 →
        창(결과 전): j4-receipt data == receipts[2].stateLabel · j4-result 0 · j4-next 0 · j4-submit 0 · expectBlindReviewChoicesLocked(locked: true) → ctrl.add(revealed) → pump 두 번 →
        expect(revealed.result, isNotNull) → r = revealed.result! · find.descendant(of: j4-result, matching: find.text(r.processScoreText)) 1 · outcomeText 1 ·
        ⓗ expect(r.detailLines, hasLength(1)) → k 마다 tester.widget<Text>(j4-result-line-$k).data == line · j4-result-line-1 0 ·
        expect(r.decisionLink, isNotNull) → find.descendant(of: j4-link-decisionLink, matching: find.text(r.decisionLink!.label)) 1 → 탭 → opener.opened == <String>[r.decisionLink!.deepLink] ·
        j4-next data(자손 Text) == JournalLabels.blindReviewNext · j4-submit 0 · expectBlindReviewChoicesLocked(locked: true) · blindReviewPickedKeys 그대로 · expect(repo.cardCalls, <String>[before.decisionId])(재구독 0) ·
        사슬 dy: j4-receipt → j4-result → j4-next ·
        🆕 결과 섹션 안 글자 = 엔진 글자만 · 이 순서: final Finder resultTexts = find.descendant(of: find.byKey(const Key('j4-result')), matching: find.byType(Text)); →
          expect(tester.widgetList<Text>(resultTexts).map((Text t) => t.data).toList(), <String?>[r.processScoreText, r.outcomeText, ...r.detailLines, r.decisionLink!.label]) →
        🆕 카드 컨트롤러에 add(revealed.copyWith(result: r.copyWith(decisionLink: null)))(규칙 10 ⑤) → pump 두 번 → j4-link-decisionLink findsNothing(부재 · 비활성 아님) ·
          같은 목록 == <String?>[r.processScoreText, r.outcomeText, ...r.detailLines] · ⓡ.
 T4-08 열 때 이미 결과(+ 저널 없음) — 큐 = Stream.value(queueFrom(1)) · 🆕 카드 = Stream.value(revealedOpen.copyWith(journal: null))(규칙 10 ④ · 전제 expect(revealedOpen.journal, isNotNull)) ·
        expect(revealedOpen.decisionId, queue3.rows[1].decisionId) · r = revealedOpen.result!(전제 isNotNull) ·
        🆕 j4-journal-state data == revealedOpen.journalStateLabel · j4-journal-body findsNothing · find.text(JournalLabels.draftRuleCited) · draftRationale · draftExpected 각 findsNothing(본문 블록 부재 · 자리표시자 0) ·
        j4-result 안 processScoreText 1 · outcomeText 1 · ⓗ expect(r.detailLines, hasLength(0)) · j4-result-line-0 0 · j4-submit 0 · j4-receipt 0 · j4-next 1 ·
        expectBlindReviewChoicesLocked(locked: true) · expect(blindReviewPickedKeys(tester), isEmpty)(선택 없음) · ⓡ.
 T4-09 거부(이미 채점됨) 뒤 결과 — 카드 = StreamController(add(before)) · 제출 = Future.value(receipts[5]) · watch = Stream.value(receipts[5]) · expect(receipts[5].state, CommandState.rejected) ·
        pickBlindReviewAnswers(tester, before, (int i) => 0) → 제출 탭 → 창: j4-submit 1(재제출 · 편집) → ctrl.add(revealed) → pump 두 번 → j4-result 1 · j4-submit 0(result 가 이긴다) · j4-receipt data == receipts[5].stateLabel ·
        j4-next 1 · expectBlindReviewChoicesLocked(locked: true) · ⓡ.
 T4-10 «다음 건» — 두 경우 (next_row · 다음 큐 = queueFrom(1)) · (next_empty · 다음 큐 = queueEmpty)마다: 큐 = StreamController(add(queue3)) ·
        🆕 카드 = 행0 id 이면 StreamController(add(before) · 결과는 아직 add 하지 않음) · 그 밖이면 queue3.rows 에서 같은 id 의 행(맵 조회 — <String, BlindReviewCard>{for (c in queue3.rows) c.decisionId: c}) ·
        제출 = Future.value(receipts[2]) · 🆕 watch = broadcast StreamController(처음엔 add 하지 않음 · teardown unawaited close) →
        pickBlindReviewAnswers(tester, before, (int i) => 0) → 제출 탭 → 카드 컨트롤러에 add(revealed) → pump 두 번 →
        전제 j4-next 1 · expect(blindReviewPickedKeys(tester), isNotEmpty) · j4-receipt findsOneWidget(지울 선택·접수증이 실제로 있다 — 문항 id 가 행끼리 같아 안 지우면 다음 카드에 남는다) →
        ctrl.add(다음 큐) → pump 두 번 → j4-title 그대로 행0 글자(고정) → j4-next 탭 → pump 두 번 →
        🆕 watch 컨트롤러에 add(receipts[0])(옛 카드의 늦은 접수증 — 구독을 끊었으면 아무 일 없다) → pump 두 번 →
        next_row 이면 expect(repo.cardCalls, <String>[queue3.rows[0].decisionId, queue3.rows[1].decisionId]) · j4-title data == queue3.rows[1].titleText · j4-result 0 · j4-next 0 · j4-receipt 0 ·
          j4-submit 1 · onPressed isNull · expect(blindReviewPickedKeys(tester), isEmpty) /
        next_empty 이면 tester.widget<Text>(j4-empty).data == queueEmpty.emptyLabel · expect(repo.cardCalls, <String>[queue3.rows[0].decisionId]) · j4-notice 0 · j4-title 0(이 둘은 else 쪽 · if/else 짝) · ⓡ.
 T4-11 떠나기 = 미저장(수용 (b)) — 큐 queue3 · 카드 before · pickBlindReviewAnswers(tester, before, (int i) => 0) → await tester.pumpWidget(const SizedBox()); → expect(commands.submitted, isEmpty) · expect(commands.watched, isEmpty).
 T4-12 채점 전 화면 글자(수용 (a) · C4d-1) — row0 · row1 · row2 마다(큐 queueFrom(k) · 카드 queue3.rows[k] · 안전 행 0 · 정상 시계 — 배너·신선도 글자 0): 위 규칙 10 의 «C4d-1 견본» 그대로 —
        allowed = <String>{ JournalLabels.blindReviewNotice, c.asOf.label, c.titleText, c.promptText, for (chip in c.contextChips) chip.label, c.deviation.label, c.journalStateLabel,
          body.writtenAtText, JournalLabels.draftRuleCited, body.ruleCitedLabel, JournalLabels.draftRationale, body.rationaleBefore, JournalLabels.draftExpected, body.expectedOutcome,
          ?(body.note == null ? null : JournalLabels.draftNote), ?body.note, for (q in c.questions) ...<String>[q.text, ?q.evidenceText, for (choice in q.choices) choice.label], JournalLabels.draftSubmit }
        (화면이 지은 글자 = 0 · 🔴 집합은 null-aware 원소로 — collection-if 0 · 결과 갈래 글자(processScoreText 등)는 집합에 넣지 않는다 = 채점 전 갈래만의 집합) · ⓡ.
 T4-13 갈래별 정적 글자(K15 · 위 «갈래별 정적 글자» 표) — 일곱 경우 ㉠ (이름, 스켈레톤, 고지, 제출, 다음 건, 다시 시도, 오래됨, 배너):
        (skeleton · 큐 = 값을 내지 않는 StreamController) · 🆕 (card_skeleton · 큐 = Stream.value(queue3) · 카드 = 값을 내지 않는 StreamController — 카드 첫 값 전) · (fail · 큐 = Stream.error(StateError('queue'))) ·
        (empty · queueEmpty) · (card · queue3 + before) · (card_stale · queue3 + before + 시계 +2일) · (result · queue3 + revealed)마다 · 🆕 안전 = 일곱 경우 모두 safetyFixtureRow(3)(차단 2):
        경우 목록의 카드 칸은 BlindReviewCard?(null = 값을 내지 않는 카드 컨트롤러 — 가짜의 card 콜백 = card == null ? silentCard.stream : Stream<BlindReviewCard>.value(card)) ·
        expect(find.byKey(const Key('j4-loading')), wantSkeleton ? findsOneWidget : findsNothing) · 같은 꼴로 find.text(JournalLabels.blindReviewNotice) · find.text(JournalLabels.draftSubmit) ·
        find.text(JournalLabels.blindReviewNext) · find.text(JournalLabels.retry) · find.text(JournalLabels.staleBannerTitle) ·
        🆕 expect(safety.activeFlags, isNotEmpty) 전제 → 플래그마다 expect(find.text(f.label), wantBanner ? findsOneWidget : findsNothing)(배너 = empty · card · card_stale · result 만 · 로딩 둘 · 에러 = 0) ·
        공통 find.text(JournalLabels.submitNotAccepted) findsNothing · find.byType(CircularProgressIndicator) findsNothing · find.byType(LinearProgressIndicator) findsNothing
        (ⓡ·ⓗ 없음 — 다시 시도 단언이 bool 꼴이다 · 플래그 루프 앞 전제는 isNotEmpty).
 T4-14 공통 배너 — 네 경우 ㉠ (row0, 0, 0, 0) · (row1, 1, 1, 0) · (row3, 3, 2, 2) · (row4, 4, 1, 1)마다(카드 before · 안전 = safetyFixtureRow(row)):
        flags = safetyFixtureRow(row).activeFlags · ⓗ expect(flags, hasLength(flagCount)) → 플래그마다 find.text(f.label) findsOneWidget ·
        expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(blockingIcons)) · expectBlindReviewChoicesLocked(locked: false)(플래그로 문항 끄기 0) ·
        플래그가 있으면 사슬 dy j4-prompt → find.text(flags.first.label) → j4-chip-0 / 없으면 find.byIcon(Icons.warning_amber_rounded) findsNothing(if/else 짝) ·
        row4 이면 find.byIcon(Icons.arrow_forward_ios) 탭 → pump → opener.opened == <String>[flags.single.clearDeepLink!] / 그 밖이면 탭하지 않고 expect(opener.opened, isEmpty)(if/else 짝) · ⓡ.
 T4-15 에러와 재시도 — 세 경우 ㉠ (queue_fail · 큐 순번 0 = Stream.error · 1 = Stream.value(queue3) · 카드 = before) · (card_fail · 큐 queue3 · 카드 순번 0 = Stream.error · 1 = Stream.value(before)) ·
        (card_value_then_fail · 큐 queue3 · 카드 순번 0 = before 를 낸 뒤 에러를 내는 스트림 · 1 = Stream.value(before))마다:
        j4-fail 1 · tester.widget<JournalErrorView>(find.byType(JournalErrorView)).lastAsOfLabel == <null · null · before.asOf.label>(경우 목록의 값) · j4-notice 0 ·
        find.text(JournalLabels.retry) 탭 → pump 세 번(위 공통 — 재시도 뒤 큐 값 → 고정 → 카드 구독 → 카드 값 · 세 경우 같은 꼴) → j4-title data == before.titleText · 기록 = 경우 목록의 기대 목록(queue_fail: queueModes == [live, live] · 그 밖: cardCalls == [id, id]) · ⓡ(재시도 뒤).
 T4-16 수용 (c) 위젯 트리 대조(K18 (가)) — 큐 queue3 · 카드 = StreamController(add(before)) · 제출 = Future.value(receipts[2]) · watch = Stream.value(receipts[2]) ·
        pickBlindReviewAnswers(tester, before, (int i) => 0) → final List<String?> beforeTexts = blindReviewTextsOutsideBottom(tester); expect(beforeTexts, isNotEmpty); final List<String> beforeKeys = blindReviewPickedKeys(tester); ·
        j4-submit 1 · j4-result 0 · j4-next 0 → 제출 탭 → ctrl.add(revealed) → pump 두 번 →
        expect(blindReviewTextsOutsideBottom(tester), beforeTexts)(순서 포함) · expect(blindReviewPickedKeys(tester), beforeKeys) · j4-submit 0 · j4-result 1 · j4-next 1 ·
        expectBlindReviewChoicesLocked(locked: true)(차이 허용 = 잠금 표현 + 하단) · ⓡ.
 T4-17 큰 글꼴 — before · revealed 마다: 띄우기 전에 tester.platformDispatcher.textScaleFactorTestValue = 2.0 + addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue) →
        pumpBlindReview(카드 = 그 값) → expect(tester.takeException(), isNull) · j4-title 1 · ⓡ.
 (T4 에 없는 번호는 없다 — 01~17.)
 ⓡ 기대 = blind_review_test.dart 15줄(T4-01·02·03·04·05·06·07·08·09·10·12·14·15·16·17) · ⓗ 기대 = 7줄(T4-03 3 · T4-05 1 · T4-07 1 · T4-08 1 · T4-14 1) ·
   🔴 정확히 이 수(다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 — 규칙 10).

■ 부록 — R2b 잔여(S-1 · S-8 · S-10 · S-11) + S-12 (같은 브랜치 · 할 일 (4)~(6) · 원문 = 설계 12 §3 «R2b 잔여 부록»)
 S-1 (R-6b · J3 A7·A11) 인용 규칙 드롭다운 선택 label 둘째 줄 밑줄 겹침 해소 — journal_draft_form.dart 의 DropdownButton<ReasonOption> 한 덩어리만.
     🔴 선택 label 에 maxLines·overflow(ellipsis/fade/clip)·softWrap false 금지 — «한 줄 렌더»는 둘째 줄을 감추므로 해법 아님(계약 값 전부 그림 · 말줄임 0).
     해법 모양 = 드라이런 시도 3(변이 도구로 재현 · 확정 — 이 글자 그대로 · DropdownButton<ReasonOption> 의 isExpanded · value · hint · items · onChanged 는 그대로):
       itemHeight: _effectiveRule(spec) == null ? kMinInteractiveDimension : null,   ← 고른 것이 있을 때만 높이를 내용에 맡긴다(고르기 전 = 지금 모양 그대로)
       selectedItemBuilder: (BuildContext context) => spec.ruleCitedOptions.map((ReasonOption o) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(o.label))).toList(growable: false),
       (🔴 조건 없는 itemHeight null 은 고르기 전 PNG(j3_discretion · j3_recon_clear · j3_rule_menu_open)까지 바꾼다 — 드라이런 시도 2 · itemHeight null 단독은 S1 테스트 실패 — 시도 1)
     🔴 고른 것이 없을 때(hint)의 모양은 그대로여야 한다 — j3_discretion·j3_recon_clear·j3_executed_read·j3_rule_menu_open·j3r_*·j1·j2·j5 PNG = M 0.
     수용 = 새 테스트 1개 'S1 long selected rule label wraps above the underline'(journal_draft_test.dart 끝 · 스펙 = m6JournalDraftSpecDiscretion · 행 1 시드(RULE_DISCRETION_BUDGET 선택 상태)):
       선택 label 글자의 RenderParagraph(tester.renderObject<RenderParagraph>(find.descendant(of: find.byType(DropdownButton<ReasonOption>), matching: find.text(그 label)).first) 꼴 · 재량)의
       maxLines isNull · softWrap isTrue · 기하 전제 tester.getBottomLeft(그 글자).dy < tester.getBottomLeft(find.byType(DropdownButton<ReasonOption>)).dy − 1 + PNG(둘째 줄이 밑줄 위) ·
       RenderParagraph 를 쓰려면 journal_draft_test.dart 에 import 'package:flutter/rendering.dart'; 한 줄(정렬 자리 = 'package:flutter/material.dart' 다음).
     재생성 허용 = 6장(j3_rejected_* · j3_restored_rejected_* · j3_submit_not_accepted_* — 드라이런 확정 · 메뉴 열린 j3_rule_menu_open_* 는 불변) — golden:approved(통합 담당) · 목록 밖 M = 반려.
     명령(packages/ui_journal · 이름마다 한 줄 · 🔴 --plain-name 없이 돌리지 않는다 — 같은 파일의 다른 PNG 까지 다시 찍힌다):
       flutter test --update-goldens test/golden/j3_golden_test.dart --plain-name "j3_rejected"
       flutter test --update-goldens test/golden/j3_r2b_golden_test.dart --plain-name "j3_restored_rejected"
       flutter test --update-goldens test/golden/j3_r2b_golden_test.dart --plain-name "j3_submit_not_accepted"
       → git status --short test/golden/goldens   ← M 은 목록의 장수만 · 그 밖 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
     질문 파일 — 시도한 것과 PNG 결과(시도 순서대로 · 되돌린 시도 포함)를 «부록 S-1» 접두 A 행으로(종류 «추측» · 시도·결과 사실 — ⑤ 에는 세지 않는다 · 아래 «질문 파일»).
     B14 로 지워진 G5 trim 근거 주석(옛 _canSubmit 의 «// G5: trim() …» 한 줄 · 01 §11-10) = 되살리지 않는다(카드 확정 — _canSubmit 는 드롭다운 한 덩어리 밖 = 규칙 1 범위 밖 · 근거 조문은 01 §11-10 에 있다).
 S-8 (M21 · F6) — test/journal_read_test.dart 'T22: not_written row 0 …' 에 expect(find.text(JournalLabels.draftRationale), findsNothing);(키 없는 자리표시자 대비) ·
     test/journal_draft_test.dart 'T7: EXECUTED → …'(또는 'T11: row 2 + EXECUTED …') 에 J-3 executed 끼워 넣기가 받은 id 단언 expect(<그 테스트의 저장소 가짜>.receivedIds, <String>[spec.decisionId]);
     (그 가짜는 _pump 안에서 만들어진다 → _pump 의 반환형을 Future<void> 에서 Future<_FakeJournalRepo> 로 바꿔 만든 가짜를 돌려준다 — 이 헬퍼 한 곳 · 다른 테스트의 호출 줄 무변경 · 카드 확정 ·
      final _FakeJournalRepo repo = await _pump(…); 로 받는다)
 S-10 약한 단언 보강(테스트만 · lib 0 · 기존 단언은 지우지 않고 더한다 — 단언을 약하게 바꾸지 않는다):
     · test/decision_detail_test.dart 'full: raw values not shown' — thresholdRegistered 는 행이 아니라 TriggerSnapshot 의 필드 하나다: expect(vm.thresholds, isNotEmpty) · expect(trigger.thresholdRegistered, isNotNull) 전제 →
       expect(find.text(trigger.thresholdRegistered!.toString()), findsNothing); 한 번(원값 미표시).
     · test/unknown_board_test.dart 'R-7: emptyLabel null → no empty label text shown' — if (base.emptyLabel != null) { … } 를 expect(base.emptyLabel, isNotNull); 전제 + 그 아래 단언으로 바꾸고 asOf 기준점 expect(find.text(vm.asOf.label), findsOneWidget) 추가.
     · test/journal_draft_test.dart — T8(-rejected · -expired · -heldForIntegrity)은 초안을 시드하지 않는다 → 근거·기대 결과 두 칸의 controller.text == _fillToReady 가 넣은 글자('a' * spec.rationaleMinChars · 'some outcome') ·
       enabled == 기대(heldForIntegrity = false · rejected·expired = true — 도우미 하나로 묶어도 된다) /
       T25 = 입력란 루프 앞에 expect(find.byType(TextField), findsNWidgets(3)); 전제를 새로 넣고 주석을 고친다(«load 동기 throw» → 행 1 복원은 정상 · save 만 동기 throw) /
       T28 find.text(<선택된 규칙 label>) / T26 죽은 분기 정리(동작 불변) / T29 데이터 기준점(머리 글자 1) / 새 정상·부재 테스트(T1~T11 · T18a · 'recon_clear: pledge block absent …')에 expect(find.text(JournalLabels.retry), findsNothing);
     · test/journal_read_test.dart — T20 tester.widget<Text>() 의 overflow·maxLines 가 세 원문(rationaleBefore · expectedOutcome · note) 모두 null / T19 호출마다 새 스트림(1회차 에러 · 2회차 값) + 재시도 뒤 journalStateLabel 1 · retry 0 /
       T23 데이터 기준점 / T20 · T22 에 retry findsNothing.
     🔴 고친 줄은 사전검사가 본다(PR 이 바꾼 줄만) — 고친 자리에 else 없는 if·늘 참 단언·여러 줄 ⓗ 를 남기지 않는다(옛 줄이 그런 꼴이면 바꾸는 김에 if/else 짝으로).
 S-11 (선택 · M39 — 이 카드는 싣는다 · 새 testWidgets 3):
     · test/unknown_board_test.dart 끝 'S11 gate unknown and notApplicable icons differ' — m6UnknownBoard2 카드 0 의 단계 1(UNKNOWN)·단계 2(NOT_APPLICABLE)(전제 expect 로 state 확인) Icon.icon 이 서로 다르다.
     · test/decision_detail_test.dart 끝 'S11 J-2 value then error keeps lastAsOfLabel' — StreamController(값 → addError) → JournalErrorView.lastAsOfLabel == 그 값의 asOf.label
       (StreamController 를 쓰려면 decision_detail_test.dart 에 import 'dart:async'; 한 줄 — 맨 위 dart: 묶음).
     · test/journal_draft_test.dart 끝 'S11 J-3 executed read value then error keeps lastAsOfLabel' — executed 뒤 끼워 넣은 읽기 본문의 watchDecisionJournal 이 값 → 에러 → 그 자리 JournalErrorView.lastAsOfLabel == 그 값의 asOf.label.
 S-12 (계약 v1.5 · 01 §15-3 · 02 §3-1 ⓗ — 발주자 결정 ⑤ = R12 뒤 · R13 앞 · K22 = 같은 카드 · 🔴 재분할 임계를 넘으면 이 절만 떼어 소카드 — 그래서 할 일 (6) 한 커밋 · 새 파일 2개로 따로 둔다)
     J-1 회차 칩 + 생성자 인자 + 진입 격리 — 🔴 관찰 가능한 동작이 계약이고 배선(프로바이더 모양)은 재량이다(C4 는 동작 단언만 본다).
     (가) 생성자 — const JournalTimeline({super.key, this.rebalanceEventId}) · final String? rebalanceEventId — 값은 키·씨앗으로만 · timeline.dart 65행 주석 «Composition root may override with an initial query (e.g. rebalance event).» 는 지운다
         (journalTimelineQueryProvider override 는 셸의 전달 수단이 아니라 테스트·골든 주입용으로만 남는다).
     (나) 씨앗 — 인자가 non-null 이면 첫 유효 쿼리 = range 는 scope.range(엔진이 준 구간) · rebalanceEventId = 인자 · 다른 축 null · scope 가 null(모르는 회차)이면 range = isDefault 프리셋 + 회차 = 인자 ·
         씨앗은 한 번만 — 「초기화」·회차 칩 ✕ 뒤 되살아나지 않는다(「적용」은 그때의 회차 조건을 보존할 뿐) · 날짜 산술·고르기 0.
     (다) 회차 칩 — 유효 쿼리의 rebalanceEventId != null ∧ watchRebalanceScope(그 id) 값 non-null 일 때만 · 글자 = scope.label 그대로 · Key('j1-chip-rebalance') · 자리 = 기간 칩 다음(설계 02 §3-1 ⓗ 그대로 — 🔵 390 폭에서는 가로 스크롤 필터 줄의 화면 밖 x 460.5~816.6 · 다른 활성 필터 칩과 같은 꼴 · 자리 변경 = ⬜ 발주자 확인 ②) · 칩 본문 탭 = 무반응 ·
         칩은 유효 쿼리에서 나온다(생성자 경로든 테스트 override 경로든 같은 칩).
     (라) 칩 ✕ — rebalanceEventId 만 null · 나머지 축 보존(씨앗 기간 포함 · 다른 칩 ✕ 와 대칭).
     (마) 「적용」·「초기화」 뜻 불변 — 「적용」 = 회차 조건 보존(시트에서 기간을 안 골랐으면 씨앗 기간도 보존) · 「초기화」 = 회차 포함 전부 지우고 isDefault 프리셋(_reset 을 바꿔야 (나)가 지켜지면 바꿔도 된다 · 단언 불변).
     (바) 시트 — 회차 섹션·시트 상태 필드 신설 0 · labels.dart 회차 라벨 0.
     (사) 구독 — 유효 쿼리의 rebalanceEventId 가 null 이면 watchRebalanceScope 를 부르지 않는다(기준 = 위젯 인자가 아니라 유효 쿼리).
     (아) «보이지 않는 조건» 0 — 회차 조건이 있는 동안 ⓐ scope 첫 값 전 = J-1 공통 로딩(목록 0 · 생성자 경로는 watchTimeline 첫 호출도 그 뒤) ⓑ scope 스트림 에러 = J-1 공통 에러(재시도 · 목록 0)
         ⓒ scope null = 칩 부재 + 목록은 봉투 그대로(emptyLabel) · 모르는 회차를 에러·not-found 문구로 바꾸지 않는다.
     (자) 기간 칩 — 씨앗이 걸린 동안 scope.range.label · 사용자가 시트에서 고르면 그 값.
     (차) 격리 — ⓐ 회차 진입의 조건이 같은 ProviderScope 의 인자 없는 JournalTimeline() 에 묻어나지 않는다 ⓑ 회차 A 뒤 회차 B 진입의 첫 호출 = B 의 씨앗 ⓒ 인자 없는 J-1 에서 고른 필터가 회차 진입의 씨앗을 덮지 않는다
         (같은 id 재진입이 씨앗부터인지는 재량 · 단언하지 않는다).
     (카) 금지 — ui_journal/lib 에 'aaq:// · AppRoutes.journalRebalance · AppLinkSchemes · RebalanceRepository · orderIntentIds 0(check_boundaries [5][5b] · C-40 ⑧) · rows 거르기 0 · 칩 글자·기간을 id·날짜로 만들기 0.
     (타) 가짜 — 새 파일 test/timeline_rebalance_test.dart 에 자기 가짜(UnimplementedJournalRepository extends — watchTimeline(호출 인자 기록 · 그 id 행만 또는 journal30 그대로) · watchRebalanceScope(호출 id 기록 · 경우마다
         Stream.value(scope) / Stream.value(null) / 값 안 내는 StreamController / Stream.error) · watchFilterCatalog · watchTimelineBadges) · UnimplementedSafetyRepository · UnimplementedConfigRepository(rangePresets4 · sleeveCatalog4)) ·
         기존 test/timeline_test.dart 의 _FakeJournalRepository 와 test/golden/j1_golden_test.dart 의 가짜에는 watchRebalanceScope override 한 덩어리만 더한다(Stream<JournalRebalanceScope?>.value(null) — 단언·입력 불변 ·
         받침대의 동기 throw 가 (아)ⓑ 공통 에러로 번지지 않게) · 배선을 바꿔 journalTimelineQueryProvider 의 모양(.family 등)이 바뀌면 그 두 파일의 override 줄 모양만 바꾼다(단언·PNG 불변 · golden README 예시 줄은 통합 담당이 병합 기록 때 맞춘다 — Bob 은 README 를 고치지 않는다) ·
         기존 j1_* 16장 = M 0(회차 조건 없는 골든은 칩 0 이라 픽셀 불변).
     테스트(test/timeline_rebalance_test.dart · testWidgets 줄 10 · 뷰 12(T1-3n · T1-3o 가 두 경우씩) · 02 §3-1 ⓗ 의 ③f~③o 그대로 · reId = scope 픽스처의 rebalanceEventId · 🔴 이름 = 번호 + ASCII 설명(예 'T1-3g reset clears rebalance' — 아래 한국어는 설명일 뿐 이름이 아니다 · 정적 S02a·S02b)):
       T1-3f 'T1-3f constructor seeds range and chip' — JournalTimeline(rebalanceEventId: reId) 를 쿼리 override 없이 → 첫 watchTimeline 호출: rebalanceEventId == reId ∧ range == scope.range ∧ 다른 축 null · 칩 글자 == scope.label · 기간 칩 글자 == scope.range.label · 행 수 == 가짜 rows 길이
       T1-3g 「초기화」 → 마지막 호출의 rebalanceEventId null ∧ range == isDefault 프리셋 ∧ 칩 0 ∧ 프리셋·scope 재방출·추가 pump 뒤에도 그 뒤 호출에 id 재등장 0
       T1-3h 칩 ✕ → rebalanceEventId 만 null · range·status·origin 직전과 같음(✕ 탭 전 await tester.ensureVisible(<칩 안 Icons.close>); + pumpAndSettle — 390 폭에서 칩이 화면 밖이라 없으면 «outside the bounds» 경고 뒤 실패)
       T1-3i scope null → 칩 0 · find.textContaining(reId) 0 · 첫 호출 rebalanceEventId == reId ∧ range == isDefault 프리셋 · 목록 = journal_rebalance_unknown 의 emptyLabel
       T1-3j JournalTimeline()(override 없음) → 첫 호출 rebalanceEventId null · watchRebalanceScope 호출 0
       T1-3k 같은 ProviderScope 에서 JournalTimeline(key: ValueKey(A), rebalanceEventId: A) → 🆕 A 에서 회차 칩 ✕ 탭으로 한 번 쓴다(T1-3h 꼴 · ensureVisible · 그 뒤 repo.calls.last.rebalanceEventId isNull —
         진입 상태를 공유 키로 두면 B 에 묻어난다) → JournalTimeline(key: ValueKey(B), rebalanceEventId: B) → B 쪽 첫 호출 rebalanceEventId == B ∧ range == isDefault 프리셋(B = scope null 인 테스트 id 로 충분 — ASCII)
       T1-3l 회차 진입 뒤 같은 스코프의 JournalTimeline() → 첫 호출 rebalanceEventId == null ∧ 칩 0
       T1-3m 같은 스코프의 JournalTimeline() 에서 상태 필터를 UI 로 「적용」한 뒤 JournalTimeline(rebalanceEventId: reId) → 첫 호출 = 씨앗(status == null ∧ rebalanceEventId == reId ∧ range == scope.range)
       T1-3n scope 스트림이 값을 안 냄 → watchTimeline 호출 0 · 행 0(로딩) · 칩 0 → 값을 내면 T1-3f 와 같다 — 🆕 두 경우(constructor · override)마다(testWidgets 한 줄 · 경우 루프):
         constructor = JournalTimeline(rebalanceEventId: reId) · override = const JournalTimeline() + journalTimelineQueryProvider.overrideWith((Ref ref) => JournalTimelineQuery(range: scope.range, rebalanceEventId: reId))
         (테스트 주입 경로 — (다) «칩은 유효 쿼리에서 나온다» · 화면 관문을 지난다) · 오버라이드 목록 = null-aware 원소 <Override>[...overridesFor(repo), ?(override 경우 ? 그 override : null)](collection-if 0) · 단언은 두 경우 같다
       T1-3o scope 스트림 에러 → J-1 공통 에러(재시도 보임) · 행 0 · 칩 0 · watchTimeline 호출 0 — 🆕 T1-3n 과 같은 두 경우(constructor · override — override 경로는 화면 관문의 에러 갈래를 지난다)
     골든 2이름 × light/dark = 4장(새 파일 test/golden/j1_rebalance_golden_test.dart · j1_golden_test.dart 의 wrapApp 꼴 · 크기 = 기본 kGoldenPhoneSize 390×844):
       j1_rebalance_chip(JournalTimeline(rebalanceEventId: reId) + scope_1 + journal30 의 그 회차 행 · 안전 행 0) · j1_rebalance_unknown(모르는 회차 + scope null + journal_rebalance_unknown)
       🆕 찍기 전(pumpAndSettle 뒤) 맨 아래 위젯(chip = Key('j1-chip-rebalance') · unknown = 빈 문장)을 가로 끝 정렬로 보이게 한다:
         await Scrollable.ensureVisible(tester.element(bottom), alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd); → pumpAndSettle(세로 스크롤 0 — tester.ensureVisible 은 세로까지 맨 위로 당겨 머리를 잘라 쓰지 않는다)
       위치 전제 = expect(tester.getBottomRight(bottom).dx, lessThanOrEqualTo(kGoldenPhoneSize.width))(끝 정렬이라 칩은 정확히 390.0 — «<=») + 기간 칩 글자·맨 아래 위젯의 dy < 844 · --update-goldens 는 이 파일 하나.
 (카드 설계 교훈 ④ — «saved 개수 단언은 T5 에만» 대신 «saved 전후 같음(델타 0) 단언 허용»: S-10 의 J-3 테스트를 고칠 때 저장 호출 수를 «전후 같음»으로 단언해도 된다.)

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려):
   큐 재방출마다 고정 카드 바꾸기(늘 rows[0] watch) · «다음 건» 뒤 이전 고정 카드 다시 잡기 · «다음 건» 뒤 선택·접수증 안 지우기 · 결과 섹션을 접수증 executed 로 열기(result null 에 빈 결과 블록) ·
   일부 문항만 골라도 제출 활성 · answers 에 score 대신 선택지 순번(j) · 점수 뒤집기(1 − score 꼴) · 제출 중 버튼 활성(이중 제출) · rejected·expired 에서 잠금 유지 · requested·held 에서 제출 버튼 남김 ·
   executed · result null 창에 «다음 건» · result != null 인데 rejected 라 제출 버튼 남김 · watchCommand 구독 안 함 · 제출 Future 에러 뒤 선택 지우기 · submitNotAccepted 안 그림 ·
   결과 링크 탭 무반응(또는 칩 링크를 결과 링크 자리에) · detailLines 마지막 줄 빼기 · 결과 섹션 안 글자 순서 바꾸기 · 빈 큐에 고지 그리기 · notLoaded 에 emptyLabel 그리기 · 빈 문장 대신 정적 글자 ·
   고지를 ListView 안으로 · 로딩·에러에 고지·배너 · 에러를 스켈레톤으로 · 로딩에 스피너 · note 없을 때 «메모» 머리 그리기 · evidenceText null 에 빈 Text · 선택지 글자 옆에 점수 표시 ·
   문맥 칩을 탭 없는 Chip 으로 · 배너 플래그로 문항 잠그기 · 결과 뒤 고지·제목·안내 하나 숨기기(K18) · 뒤로가기(dispose)에서 제출 · 채점 전 화면에 정적 글자 하나 더하기 ·
   (S-12) 생성자 경로 첫 호출이 조건 없이 나감 · 「초기화」 뒤 재시드 · rows 거르기 · id 를 칩 글자로 · 인자 없는 진입의 헛구독 · 진입 사이 조건 누수(전역 질의에 씨앗 · 진입 상태를 공유 키로) ·
   미리 고른 필터가 씨앗을 덮음 · scope 첫 값 전 목록 그림(생성자 경로 · override 경로 둘 다) · override 경로의 scope 에러를 목록으로 ·
   (S-1) 선택 label maxLines 1 · softWrap false ·
   🆕(C4 검증 2026-10-20) 잠금 switch 에서 received·staleContext·pendingLeaseConfirm·noOperator 를 풀림 쪽으로 · 재제출 때 submitNotAccepted 안 지움 · 결과 갈래에 submitNotAccepted 남김 ·
   «다음 건» 에서 명령 구독 안 끊음 · 구독 에러 때 접수증 지움 · onError 없음 · 결과 섹션에 정적 글자 하나 더하기 · journal null 에 칸 머리 그리기 · decisionLink null 에 빈 버튼 ·
   카드 첫 값 전(큐 값 뒤)에 배너·스피너 · 큐 에러에 배너 · 빈 큐에서 배너 빼기.
   (이탈 배지를 isDeviation 일 때만 그리기는 픽스처가 전부 이탈 행이라 테스트가 아니라 정적 S11 이 잡는다 — S11 출력 0 이 기준.)

■ 정적 묶음 — packages/ui_journal 에서 아래 32줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 32줄을 돌려 글자로 대조한다 — 다르면 거짓 주장 = 반려 · 대조에서 빼는 것은 빈 줄·EXIT 표기(1/0 ↔ False/True)·
   warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐 · 테스트 이름·패키지 이름 한 낱말이라도 다르면 반려).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로(«길어서 줄였습니다» 같은 주의 문장으로 갈음하지 않는다).
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(«■ 제출» 의 flutter test 줄들 · C-43 dart test · Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
     <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙 · 사전검사 R4).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/blind_review_test.dart test/blind_review_fakes.dart test/golden/j4_golden_test.dart test/timeline_rebalance_test.dart test/golden/j1_rebalance_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/blind_review_test.dart test/golden/j4_golden_test.dart test/timeline_rebalance_test.dart test/golden/j1_rebalance_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/blind_review_test.dart test/golden/j4_golden_test.dart test/timeline_rebalance_test.dart test/golden/j1_rebalance_golden_test.dart; echo "EXIT:$?"
echo "## S02c testWidgets lines"; git grep -c "testWidgets(" -- test/blind_review_test.dart test/golden/j4_golden_test.dart test/timeline_rebalance_test.dart test/golden/j1_rebalance_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (J-4 file)"; git grep -nP "(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S04 route constants and link literals 0"; git grep -nE "AppRoutes|AppLinkSchemes|'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "journalLinkOpenerProvider" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S06 command api lines (definition + submit + subscribe)"; git grep -n "journalBlindReviewCommandApiProvider" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S07 CommandState lines (one switch, 9 values)"; git grep -n "CommandState\." -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S08 forbidden calls 0 (J-4 file)"; git grep -nE "watchTimeline|watchFilterCatalog|watchDecisionDetail|watchDecisionJournal|findByDecisionId|chainOf|fillChain|watchTimelineBadges|watchUnknownBoard|draftFormSpec|watchRebalanceScope|\.watchState\(|HoldingsRepository|PerformanceRepository|DraftStore|journalDraftStoreProvider|journalCommandApiProvider|recordDisclosureView|FlagIds" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S09 branch shell format words 0 (J-4 file and common)"; git grep -nE "journal_draft|RunMode|runMode|operatingMode|OperatingMode|FeatureFlags|kIsWeb|Platform\.|DateTime\.now|DateTime\.timestamp|Navigator|GestureDetector|Scaffold|AppBar|SafeArea|SnackBar|toStringAsFixed|NumberFormat" -- lib/src/blind_review.dart lib/src/common/journal_common.dart; echo "EXIT:$?"
echo "## S10 score lines (1)"; git grep -nP "\.score\b" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S11 raw keys and branch fields 0 (J-4 file)"; git grep -nP "\.(isDeviation|kindCode|journalId|rejectReasonCode|code|wire|hasMore)\b|\.result!" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S12 trimming 0 (J-4 file)"; git grep -nE "maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S13 sort filter pick words 0 (J-4 file)"; git grep -nP "(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet|last|lastOrNull|sublist|getRange|elementAt|removeAt|removeWhere|retainWhere|shuffle)\b|\breverse:\s*true" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S14 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S15 exhaustive switch escapes 0 (J-4 file)"; git grep -nE "default:|case _:|^\s*_ =>" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S16 autoDispose (old comment line only)"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## S17 barrel exports 6"; git grep -n "^export " -- lib/ui_journal.dart; echo "EXIT:$?"
echo "## S18 operator barrel 1"; git grep -n "^export " -- lib/journal_draft.dart; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_journal/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 figures 0 (prompt 48-54)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S22 decimal and percent literals 0 (J-4 file)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S23 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/common/journal_common.dart lib/ui_journal.dart; echo "EXIT:$?"
echo "## S24 S12 bans 0"; git grep -nE "orderIntentIds|RebalanceRepository|AppRoutes\.journalRebalance" -- lib; echo "EXIT:$?"
echo "## S25 S12 chip key (1)"; git grep -n "j1-chip-rebalance" -- lib; echo "EXIT:$?"
echo "## S26 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/blind_review_test.dart; echo "EXIT:$?"
echo "## S27 H lines (hasLength)"; git grep -c "hasLength(" -- test/blind_review_test.dart; echo "EXIT:$?"
echo "## S28 j4 key names"; git grep -noP "j4-[A-Za-z]+(-[A-Za-z]+)*" -- lib/src/blind_review.dart; echo "EXIT:$?"
echo "## S29 new labels (2)"; git grep -n "blindReview" -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## S30 rich text widgets 0 (J-4 file)"; git grep -nE "RichText|SelectableText|Text\.rich" -- lib/src/blind_review.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름·문자열 리터럴은 ASCII 만 · S02c = 4줄 «test/blind_review_test.dart:17» · «test/golden/j1_rebalance_golden_test.dart:1» · «test/golden/j4_golden_test.dart:1» ·
   «test/timeline_rebalance_test.dart:10»(git grep 경로 순 · 드라이런 확인) · S03 = 엔진 글자 가공 0 · S04 = lib 전체 출력 없음(J-4·S-12 가 쓰는 AppRoutes 0 · [5][5b]) ·
   S05 = 탭 콜백 안 1줄(이 결정 보기 OutlinedButton 의 onPressed · 줄 번호는 짓는 모양마다 다르다) — build 본문에서 읽는 줄 0 ·
   S06 = 4줄(정의 1 · throw 문구 1 · _submit 의 ref.read 1 · _subscribe 의 ref.read 1 — dart format 이 정의 줄과 문구 줄을 나눈다 · 드라이런 확인) ·
   S07 = 8줄(잠금 switch 하나 · 7값 한 줄씩 + 마지막 줄 «CommandState.rejected || CommandState.expired => false,» · 9값 전부 · 드라이런 확인) ·
   S08 = 호출 금지·초안 포트·안전 상태 직접 구독·FlagIds 0 · S09 = 두 파일 모두 0(주석도) · S10 = 1줄(제출 answers 맵의 «q.questionId: _picked[q.questionId]!.score,» 줄) · S11·S12·S13 = 0 ·
   S14 = 출력 없음(ui_journal lib 에 Colors 0 — 지금도 0) · S15 = 0 · S16 = «lib/src/journal_draft/journal_draft_form.dart:37:» 주석 1줄뿐(새 줄 0 — 줄 번호가 다르면 S-1 이 그 위를 고친 것 · 줄 수 1 이 기준) ·
   S17 = 6줄(l10n/labels.dart · src/blind_review.dart · src/decision_detail.dart · src/journal_read.dart · src/timeline.dart · src/unknown_board.dart 순) · S18 = 1줄(src/journal_draft/journal_draft_form.dart) ·
   S19~S21 = 10항의 1·3·2 항 근거 · S22 = C-43 ⑯ 0 · S23 = 세 파일 모두 둘째 수(삭제) 0 · 첫째 수 = 드라이런 labels 8 · journal_common 28 · 배럴 1(주석·빈 줄을 세므로 짓는 모양에 따라 달라도 된다 · 기준 = 둘째 수 0 · 배럴 1) ·
   S24 = 0 · S25 = timeline.dart 1줄 · S26·S27 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대와 정확히 같아야 한다(15 · 7 · 다르면 반려) ·
   S28 = 이름 21개(j4-loading · j4-fail · j4-empty · j4-notice · j4-asof · j4-title · j4-prompt · j4-chip · j4-deviation · j4-journal-state · j4-journal-body · j4-question · j4-evidence · j4-choice ·
   j4-receipt · j4-submit-not-accepted · j4-submit · j4-result · j4-result-line · j4-link-decisionLink · j4-next — 같은 이름이 갈래마다 두 번 나와도 된다(j4-loading·j4-fail·j4-asof) · Key 표 밖의 j4- 0) ·
   S29 = 2줄(blindReviewNotice · blindReviewNext) · 🆕 S30 = 0(J-4 파일에 RichText · SelectableText · Text.rich 0 — T4-12 의 Text 루프가 보지 못하는 글자 위젯 · C4d-6 기본값))

■ 골든 — 6이름 × light/dark = 12장(전부 신규 · 설계서 §3-4 · golden README «🆕 R3» 절 표 그대로) + 부록 S-12 2이름 × 2 = 4장 + 부록 S-1 재생성 6장
  j4_before_reveal(큐 queue3 · 카드 before · 접수증 없음 · 전 문항 선택 0번 선택지 = pickBlindReviewAnswers(tester, <그 카드>, (int i) => 0) · 제출 전) ·
  j4_after_reveal(같은 흐름 → 제출(제출 = receipts[2] · watch = receipts[2]) → 카드 컨트롤러에 revealed) ·
  j4_after_reveal_open(큐 = queueFrom(1) · 카드 컨트롤러 queue3.rows[1] → 전 문항 선택 0번 → 제출(receipts[2]) → revealedOpen) ·
  j4_waiting(before · 전 문항 선택 0번 → 제출(제출 = receipts[0] · watch = receipts[0]) → 잠금 + «전송 대기» stateLabel) ·
  j4_rejected(before · 전 문항 선택 0번 → 제출(제출 = receipts[4] · watch = receipts[4] — 🔴 ANSWERS_INVALID 행 · ALREADY_SCORED 행(5)으로 그리지 않는다) → 편집 복귀 + 재제출 + stateLabel) ·
  j4_empty(큐 queueEmpty)
  🔵 골든의 선택(전 문항 0번 = «예»)과 결과 픽스처의 과정 점수 글자(revealed «4점» · revealed_open «3점»)는 합성이라 서로 맞지 않는다 — 화면은 점수를 셈하지 않으므로 그대로 둔다(PNG 글자는 테스트 글꼴 네모 · golden README «🆕 R3»).
  모두 const JournalBlindReview() · 안전 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 크기 = 테스트 파일 안 상수 const Size _kTallPhone = Size(390, 1600)(ui_journal 꼴 — j3_golden_test.dart · 여섯 이름 모두 맨 아래 위젯이 그 높이 안 ·
  이 값을 바꾸지 않는다 · kGoldenPhoneSize 는 M2 소유).
  모양 = j3_golden_test.dart 처럼 (이름, 흐름) 목록 × Brightness.values 루프 · 테스트 이름 '$name ${brightnessSuffix(b)}' · 흐름의 탭·제출은 blind_review_fakes.dart 의 도우미로 · 찍기 전 await tester.pumpAndSettle().
  골든 파일 import(directives_ordering · 8줄): import 'dart:async'; → 'package:domain_contracts/domain_contracts.dart' → 'package:flutter/material.dart' → 'package:flutter_riverpod/flutter_riverpod.dart' →
     'package:flutter_test/flutter_test.dart' → 'package:ui_journal/ui_journal.dart' → '../blind_review_fakes.dart' → 'golden_support.dart'(쓰지 않는 것은 뺀다 — analyze)
  찍기 전 위치 전제(golden README «🆕 R2» 의 «세로가 긴 화면» · 이름마다 맨 아래 위젯 하나):
    expect(tester.getBottomLeft(find.byKey(Key(bottomKey))).dy, lessThan(_kTallPhone.height));
    ← bottomKey = j4_before_reveal · j4_rejected → 'j4-submit' · j4_after_reveal · j4_after_reveal_open → 'j4-next' · j4_waiting → 'j4-receipt' · j4_empty → 'j4-empty'
  → await expectGolden(name, b);
  packages/ui_journal 에서:
    flutter test --update-goldens test/golden/j4_golden_test.dart
    flutter test --update-goldens test/golden/j1_rebalance_golden_test.dart     ← 할 일 (6)
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG(j4_* 12 · j1_rebalance_* 4)만 ?? · M = 부록 S-1 목록뿐
  🔴 다른 골든 테스트 파일·폴더를 --update-goldens 에 넣지 않는다(S-1 은 위 «부록 S-1» 의 --plain-name 줄만).
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이(_kTallPhone — 카드 확정값)를 늘리지 않는다.
  화면 여백(간격 — SizedBox 높이·Padding 의 정수)을 줄여 맞추는 것은 간격 재량으로 허용한다 — 단 줄였으면 «줄이기 전 dy» 와 «줄인 뒤 dy» 를 질문 파일에 «측정:» 사실 행으로 남긴다
     (발주자 결정 2026-10-14 ③ · 12 §3 공통 조문 «골든 높이 = 재량 + 기록»). 여백을 줄여도 넘거나, 여백 말고 다른 것(글자·배치·요소 수)을 바꿔야 들어가면 멈춘 뒤 실제 dy 값을 질문 파일에 적는다(바꾸지 않는다).
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다):
    그 골든 테스트 파일의 위치 전제 lessThan(<높이>) 한 곳을 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/j4_golden_test.dart(--update-goldens 없이 · j1_rebalance 도 같은 법)
    → 테스트 이름('j4_before_reveal light' … )마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- <그 파일> 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개)
· J4_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 이 카드의 질문은 전부 여기에(부록 S-n 의 질문도 «부록 S-n» 접두로 이 파일에 · 다른 질문 파일을 고치지 않는다 — J1·J2·J3·J5 포함).
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A8 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  부록 S-1 시도 기록(A9~ · «측정:» 으로 시작 · 시도한 모양 · PNG 결과 · 남긴 모양) · 권고와 다르게 지은 이름 · 2개 밖에 더 필요했던 정적 라벨(더하지 않고 질문으로) · 문서에 없어 정한 것 전부.
    | A1 | R3-Bob-J4 | 추측 | 측정: j4_before_reveal dy 실측값 (light=<값>, dark=<값> < <높이>) | 골든 위치 전제 실측 | <높이> 미만 확인 | ⬜ 미답 | |
    (A2 = j4_after_reveal · A3 = j4_after_reveal_open · A4 = j4_waiting · A5 = j4_rejected · A6 = j4_empty · A7 = j1_rebalance_chip · A8 = j1_rebalance_unknown · 같은 형식 ·
     <높이> = j4 는 _kTallPhone 의 높이 숫자 · j1_rebalance 는 844 · <값> 자리에만 잰 숫자)
    | A9 | R3-Bob-J4 | 추측 | 측정: 부록 S-1 시도 <n> — <시도한 모양> → <PNG 결과(둘째 줄 위치)> | 부록 S-1 드롭다운 | <남겼는지 · 되돌렸는지> | ⬜ 미답 | |
  골든 높이를 맞추려고 여백을 줄였으면 S-1 행 다음 번호부터 줄인 이름마다 한 행(«측정: <이름> 여백 줄이기 전 dy (light=<값>, dark=<값>) · 줄인 뒤 dy = 그 이름의 A 행 값» · 줄이지 않았으면 이 행 0).
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 2개 · 읽지 않는 필드 목록(규칙 3) · 고정 카드 꼴 · 잠금 switch · 고지 자리 · 이탈 배지 늘 그림 · 저널 본문 칸 머리 재사용 ·
  보고하지 않는 오류 처리 · 배치 순서 · 골든 이름·입력·흐름 · S-12 칩 Key · 부록 S-1·S-8·S-10·S-11 의 코드 꼴(해법 모양 · import 한 줄 · _pump 반환형 · T8 기대 글자 · T25 전제) · 재량인 것(여백·글자 크기·모서리 — 단 골든 높이를 맞추려 여백을 줄였으면 위 «측정:» 행은 적는다). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(7) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(권장대로 나눴으면 (7)))
  cd packages/ui_journal
  flutter test test/blind_review_test.dart                   ← 끝 줄을 그대로 적어 둔다(기대 «+45: All tests passed!»(드라이런 확인) · 손으로 세지 않는다)
  flutter test test/golden/j4_golden_test.dart               ← 끝 줄 그대로(기대 «+12: All tests passed!»)
  flutter test test/timeline_rebalance_test.dart             ← 끝 줄 그대로(기대 «+12: All tests passed!»)
  flutter test test/golden/j1_rebalance_golden_test.dart     ← 끝 줄 그대로(기대 «+4: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄을 그대로 적어 둔다 · 기대 = 시작 기준 N + 77(드라이런 207 → 284))
  cd ../domain_contracts
  dart test test/contracts/c43_blind_review_test.dart -r expanded   ← 전부 통과 · 출력에서 «C-43 ⑩ 대상» 으로 시작하는 줄과 그 바로 아래 들여쓴(공백 4칸) 경로 줄을 그대로 적어 둔다(진행 표시 줄 «00:00 +0: …» 은 빼고)
     (기대 2줄(드라이런 확인): «C-43 ⑩ 대상 J-4 1파일 — packages/ui_journal/lib/src/blind_review.dart + packages/ui_journal/lib/src/blind_review/**» + 공백 4칸 들여쓴 «packages/ui_journal/lib/src/blind_review.dart» · 출력 그대로 적는다 · C-43 17/17 통과 · domain_contracts «+315 ~30»)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 다음으로 간다 — 커밋 안 된 수정은 CI 포맷 게이트를 빨갛게 만든다
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 경로 앞머리 packages/ui_journal/ 가 붙어 찍힌다): A lib/src/blind_review.dart · M lib/l10n/labels.dart · M lib/src/common/journal_common.dart · M lib/ui_journal.dart ·
        M lib/src/journal_draft/journal_draft_form.dart(S-1) · M lib/src/timeline.dart(S-12) · A test/blind_review_fakes.dart · A test/blind_review_test.dart · A test/golden/j4_golden_test.dart ·
        A test/timeline_rebalance_test.dart · A test/golden/j1_rebalance_golden_test.dart · A test/golden/goldens/j4_*.png 12장 · A test/golden/goldens/j1_rebalance_*.png 4장 ·
        M test/golden/goldens/<부록 S-1 목록>.png 6장 · M test/journal_draft_test.dart · M test/journal_read_test.dart · M test/decision_detail_test.dart · M test/unknown_board_test.dart · M test/timeline_test.dart ·
        M test/golden/j1_golden_test.dart(S-12 (타)의 watchRebalanceScope 한 덩어리 · override 모양 줄만) · M docs/ai-context/inbox/J4_questions.md ·
        그 밖의 줄(목록 밖 M PNG · 기존 lib 의 다른 파일 · 하네스 · README · domain_contracts/** · 다른 질문 파일) = 금지 — 하나라도 있으면 푸시하지 말고 멈춘 뒤 출력을 채팅으로
  🆕 사전검사 ① 코드만(저장소 뿌리에서 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다 — C4 가 같은 줄을 다시 돌린다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0 --golden-prefix j4_ --goldens 12
     ← 끝 줄 «── 결과: 🔴 a · 🟡 b». 🔴 가 하나라도 있으면 푸시하지 않는다 — 줄마다 적힌 <파일>:<줄> 을 고친다(테스트만 · 검사를 피하려고 if 를 다른 꼴로 감추지 않는다) →
        고친 것은 새 커밋 하나로 더한다(권장 제목 «[M6] R3 (8) 사전검사 지적 수정» · 🔴 amend·rebase 금지 · 이때는 이 커밋이 마지막이어도 된다 — melos.bat run format:fix 를 먼저 돌려 format 0 changed 는 그대로 지킨다) →
        이 줄을 다시 돌려 🔴 0 을 본다 · 🟡 는 멈춤이 아니다(PNG·글을 다시 열어 보고 맞으면 그대로).
  git push -u origin ui/m6-j4-review
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  git log --oneline origin/main..HEAD         ← 아래 ① 에 그대로 붙일 출력(나눈 수만큼 · 권장대로면 7줄 · 맨 위 = format·질문 커밋)
  cd packages/ui_journal → 위 «정적 묶음» 32줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  10항 줄 수 — 아래 ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일에 저장(예 PowerShell 에서 메모장으로 $env:TEMP\r3_box2.txt)한 뒤
     PowerShell: (Get-Content $env:TEMP\r3_box2.txt).Count      또는 Git Bash: grep -c "" "$TEMP/r3_box2.txt"
     ← 출력 그대로(기대 10 · 다르면 줄을 이었거나 나눈 것 — 고친 뒤 다시 센다 · 이 파일은 커밋하지 않는다)
         ② 에 붙이는 꼴 = 아래 견본처럼 명령의 **출력 한 줄만** 코드 블록 하나로(명령 줄은 붙이지 않는다 · «….Count = 10» 처럼 명령과 잇지 않는다):
      ┌── 세는 줄 견본(출력 한 줄)
10
      └──
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다(golden:approved 포함). PR 제목: [M6] J-4 사후 blind 리뷰
  PR 본문 5섹션을 채팅으로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로 쓰고 그 아래에 내용을 둔다(통합 담당이 이 글을 PR 본문으로 통째로 옮긴다 · GitHub 에서 직접 고치지 않는다):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄 — 각 섹션 맨 위에 한 줄씩)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      (이 다섯 줄은 사전검사가 글자로 보는 고정 머리다 — 🔴 ② 머리의 «12항» 은 그대로 둔다(M6 의 자체 점검은 10항이지만 머리 글자를 바꾸면 사전검사 R1 🔴) · 무엇을 어느 섹션에 붙이는지는 아래 ①~⑤ 설명이 정한다)
      채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(«모든 확인 완료 …» · «이제 제출 글을 작성합니다» 같은 머리말 · 구분선 --- 금지).
      🆕 내기 전 사전검사 ② 제출 글까지 — ①~⑤ 와 flutter test 한 줄까지 다 쓴 제출 글 전체를 저장소 밖 파일에 저장(예 PowerShell 에서 notepad $env:TEMP\R3-Bob-J4_submit.md 로 열어 붙여 넣고 «UTF-8» 로 저장 ·
         이 파일은 커밋하지 않는다)한 뒤 저장소 뿌리에서 한 줄:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R3-Bob-J4_submit.md --golden-prefix j4_ --goldens 12
        ← 🔴 0 이어야 채팅에 낸다 · 🔴 가 보고 글 줄(R1~R5)이면 글을 고쳐 다시 저장한 뒤 다시 돌린다 · 출력은 채팅에 붙이지 않는다(이 한 줄이 옛 PowerShell 다섯 줄 자기 확인을 대신한다).
   ① 아래 «① 머리 복사 상자» 두 줄 그대로 + «바뀐 파일:» + 위 git diff --name-status origin/main...HEAD 출력 그대로(코드 블록 하나 · 손으로 쓰지 않음 · A/M · PNG 포함) +
      «커밋 목록:» + 위 git log --oneline origin/main..HEAD 출력 그대로(코드 블록 하나 · 맨 위 = format·질문 커밋) +
      «부록 S-1:» 한 줄(남긴 해법 모양 · 재생성한 PNG 장수 · J4 행 번호 — 코드에 실제로 있는 것만)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: J-4 — 사후 blind 리뷰(JournalBlindReview())
부록: S-1 J-3 드롭다운 · S-8·S-10·S-11 테스트 보강 · S-12 J-1 회차 칩(JournalTimeline({String? rebalanceEventId}))
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항 — 아래 복사 상자의 10줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 10항이 10줄 그대로인지 «10항 줄 수» 명령의 출력으로 확인한다 · 항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음·명령 결과의 수):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «J-4 화면 파일 산술 0 · 점수 = 고른 score 를 answers 에 옮기기만(T4-04 · 정적 S10 1줄) · 큐 행 수 세기 0 · 금지 수치 S21 0건»
        3번 = «정적 묶음 S20 — 0건»
        4번 = «이 카드 범위 밖(J-4·S-12 에 보유 손익·정렬 없음)»
        5번 = «채점 전 카드 데이터에 결과 없음(가리는 코드 0) · 화면 Text 에 금액·백분율·손익 낱말 0(T4-12) · 결과 섹션 = result != null 일 때만(T4-07·T4-13)»
        6번 = «M5·X1·X5 화면 0 · 배너 clearDeepLink 는 AppLinkOpener.open 그대로(T4-14)»
        7번 = «배너 = JournalSafetyBanners(J-5 와 같은 차단 카드·표식 칩 · journal_common 더하기만) · 배너 글자 = BlockFlag 글자 그대로(T4-14)»
        8번 = «J-4 머리 = card.asOf.label(j4-asof · T4-03) · 빈 갈래 = 봉투 asOf.label(T4-02)»
        9번 = «로딩·에러·빈·오래된 데이터·차단 = T4-13·T4-15·T4-02·T4-14 · 부분 동기 = 이 카드 범위 밖»
        10번 = «픽스처 변경 0 · 새 PNG = j4_* 12장 + j1_rebalance_* 4장 · 재생성 = 부록 S-1 목록 <N>장만(golden:approved 는 통합 담당) · 미정의 타입 이름 짓기 0(J-4 = 계약 v1.7)»
      ┌── 복사 시작(다음 줄부터)
 1. `ui_journal`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 금액·비율 산술이 없는가 (레이아웃 정규값 소비 제외) [x] ( )
 3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (`label` 계열 DTO 필드 경유만) [x] ( )
 4. 종목 손익이 기본 접힘인가 / 손익 정렬·필터가 없는가 / `watchHoldings` 기본이 `includePnl: false`인가 [x] ( )
 5. J-4가 채점 전 화면에서 손익·결과를 가리는가 [x] ( )
 6. M5·X1·X5 소유 화면을 렌더하거나 조작 버튼을 만들지 않았는가 (딥링크만인가) [x] ( )
 7. 명세 §2-2 표에 없는 차단 표기를 발명하지 않았는가 / 배너 문구를 내가 쓰지 않았는가 [x] ( )
 8. 「현재」 표기가 기준일 고지 없이 나가지 않는가 [x] ( )
 9. 공통 상태 6종(로딩·빈·에러·오래된 데이터·차단·부분 동기)을 전부 구현했는가 [x] ( )
10. 픽스처를 편집하지 않았는가 / 골든 스냅샷을 재생성하지 않았는가 / ⚠️ 미정의 타입을 임의로 이름 짓지 않았는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M6.md 159~168행과 같습니다)
      이어서 «10항 줄 수:» + 위 «10항 줄 수» 명령의 출력 그대로 한 줄 +
      «정적 묶음 출력:» + 32줄 출력 전부를 코드 블록 하나로 그대로 +
      «S05 결과:» 다음 줄부터 S05 출력 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄씩(1줄 · 괄호·백틱·앞머리·설명·줄 끝 빈칸 없이 · 줄을 빼거나 줄이면 = 보고 불일치) +
      ⓡ·ⓗ = 아래 상자의 글자 틀 그대로(<…> 자리에만 정적 묶음 S26·S27 출력 줄을 그대로 복사 · 손으로 쓰지 않는다 · test/ 를 떼지 않는다) +
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = S26 출력:
<S26 출력 줄 그대로>
ⓗ = S27 출력:
<S27 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
      «C-43 ⑩ 출력:» 다음 줄부터 위 dart test 의 «C-43 ⑩ 대상» 줄과 그 아래 들여쓴 경로 줄 전부 그대로(들여쓰기 그대로) +
      «테스트 파일별:» 다음 줄부터 위 flutter test 네 파일의 끝 줄 그대로(blind_review_test · j4_golden_test · timeline_rebalance_test · j1_rebalance_golden_test 순)
   ③ 스크린샷 서술 — 로딩·정상(카드 · 결과)·빈·차단 4줄 + 골든 표 12행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤) + 부록 표 둘(S-12 새 골든 4행 · S-1 다시 찍은 PNG 행)
      🔴 서술은 코드의 위젯·Key 이름 나열로만 쓴다 — blind_review.dart 의 «렌더 순서» 그대로 «→» 로 잇는다
         (렌더 순서 = build 에서 시작해 private 메서드·클래스 호출을 그 자리에 펼쳐 읽은 순서 · 파일 글자 순서가 아니다) ·
         조건으로 붙는 것(JournalStaleBanner · JournalSafetyBanners 안의 카드·칩 · j4-journal-body · j4-evidence-$i · j4-receipt · j4-submit-not-accepted · j4-submit · j4-result · j4-result-line-$k · j4-link-decisionLink · j4-next)은 «(있을 때)» 를 붙인다 ·
         그 렌더 순서가 위 «화면» 의 배치 1~16 과 다르면 제출하지 말고 멈춘 뒤 채팅으로 · 파일 글자 순서만 다른 것은 멈출 일이 아니다(서술에 덧붙이지도 않는다).
         «로딩» = JournalSkeleton(Key('j4-loading')) — 고지·배너 없음 ·
         «정상» = Key('j4-notice') → Expanded(ListView) → Key('j4-asof') → JournalStaleBanner(있을 때) → Key('j4-title') → Key('j4-prompt') → JournalSafetyBanners → ValueKey<String>('j4-chip-$i') → Key('j4-deviation') →
                  Key('j4-journal-state') → Key('j4-journal-body')(있을 때) → ValueKey<String>('j4-question-$i') → ValueKey<String>('j4-evidence-$i')(있을 때) → ValueKey<String>('j4-choice-$i-$j') → Key('j4-receipt')(있을 때) →
                  Key('j4-submit-not-accepted')(있을 때) → Key('j4-submit')(있을 때) → Key('j4-result')(있을 때) → ValueKey<String>('j4-result-line-$k')(있을 때) → Key('j4-link-decisionLink')(있을 때) → Key('j4-next')(있을 때)
                  — 이 글자와 코드가 같으면 이 글자 그대로 쓴다(낱말을 바꾸거나 요약어를 더하지 않는다) ·
         «빈» = ListView → Key('j4-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('j4-empty')(있을 때) ·
         «차단» = JournalSafetyBanners 의 자리를 코드 그대로 — «Key('j4-prompt') 아래 · ValueKey<String>('j4-chip-0') 위 · ListView 안».
      🔴 «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지 · 🔴 이 서술·골든 표에 영어 색·테마 낱말(error · primary · surface …)·우리말 색 이름 0(사전검사 R2 — 에러 갈래 Key 를 j4-fail 로 지은 까닭).
      골든 표 12행(j4_*): «| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |» 꼴 마크다운 표 · 한 행 한 줄 · 이름 칸 = «j4_before_reveal light» 꼴 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m6/blind_review_card_before.json + m6/blind_review_receipts_6.json 행 2 — 상수 이름과 섞지 않는다) · 크기 = 390×<높이> ·
        dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다) ·
        배치·잘림 = PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 글자 내용·글자 길이의 차이는 쓰지 않는다 · 못 본 것은 «미열람») ·
        칸 꼴 = «<위에서부터 PNG 에 보이는 덩어리를 → 로 — 글자 n줄 · 상자 · 배경 덩어리 · 칩 n개 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>» ·
           «글자 n줄» = PNG 에 보이는 글자 행 수(줄바꿈 포함 · 예 «글자 8줄(줄바꿈 포함)») · «칩 n개» = 한 무리의 칩 개수 · 버튼 = «버튼 글자» · 코드 이름·픽스처 낱말 금지 · 칸 끝의 «— 잘림 …» 은 빠뜨리지 않는다(12행 모두).
      부록 표 — S-12 새 골든 4행(같은 칸 꼴 · 크기 390×844) · S-1 다시 찍은 PNG 행(이름 · 다시 찍은 까닭 «부록 S-1 드롭다운» · 배치·잘림 칸 = 둘째 줄이 밑줄 위로 갔는지 PNG 에서 본 것만 · 같은 칸 꼴) ·
        🔴 이 두 표의 행은 j4_ 로 시작하지 않는다(사전검사 R3 는 j4_ 행만 센다 — 섞으면 12 가 아니게 된다).
   ④ 질문 목록 — 아래 명령 출력에서 «+|» 로 시작하는 줄 전부를 코드 블록 하나로 그대로(이 카드가 질문 파일에 더한 새 행 전부 — 측정 행 포함 · 앞의 + 와 줄 순서 그대로 · 요지 표를 손으로 만들지 않는다):
      git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/J4_questions.md   ← 저장소 뿌리에서 · 푸시한 그 커밋 위에서 · «+++ b/…» 줄은 넣지 않는다(표 행만)
      (셸에서 한글이 깨져 보이면 PowerShell 에서 [Console]::OutputEncoding = [Text.Encoding]::UTF8 를 한 번 돌린 뒤 다시 돌린다 — 출력을 손으로 고쳐 쓰지 않는다)
   ⑤ 추측한 것 = J4_questions.md 의 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄 · <…> 자리에만 출력 그대로 · 아래 «(+ flutter test 한 줄 …)» 의 상자)
flutter test: 시작 기준 <N> → 끝 <packages/ui_journal 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = «끝 00:16 +354: All tests passed!» 꼴 — 시각·«+수»·«All tests passed!» 까지 출력 끝 줄 그대로 · «끝 354» 처럼 수만 쓰지 않는다 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 77 · 수를 따로 계산해 덧붙이지 않는다 · 다르면 그 위 한 줄에 «까닭:» + 위 테스트 파일별 끝 줄로 설명))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-j4-review` 푸시 1건 · 커밋 권장 7개(본문 (1)~(7) · **마지막 = format·질문 커밋** · amend·rebase·강제 푸시 0 · 나누기는 재량 — 각 커밋 제목이 그 내용과 맞으면 된다 · 발주자 결정 2026-10-14 ④).
- `lib/` 새 파일 **1**(`src/blind_review.dart`) · 수정 3(더하기만 — `l10n/labels.dart` 끝 R3 절 라벨 2 · `src/common/journal_common.dart` 끝 `JournalSafetyBanners` · `ui_journal.dart` export 1줄(정렬 자리)) — 삭제 0(S23) + 부록 수정 2(`src/journal_draft/journal_draft_form.dart` 드롭다운만 · `src/timeline.dart` S-12). 그 밖의 `lib/`(J-2·J-3R·J-5 화면)는 바뀌지 않는 것이 정상 · `lib/src/blind_review/` 없음.
- `test/` 새 파일 5(`blind_review_test.dart` · `blind_review_fakes.dart` · `golden/j4_golden_test.dart` · `timeline_rebalance_test.dart` · `golden/j1_rebalance_golden_test.dart`) + 새 PNG 16장(`j4_*` 12 · `j1_rebalance_*` 4) + 부록 S-1 재생성 6장(M · `golden:approved` 는 통합 담당) · 기존 테스트 수정 6파일(S-8·S-10·S-11 · S-12 가짜 한 덩어리) · 하네스·README 불변.
- 질문 파일 `J4_questions.md`(새 행 A1~A8 «측정:» 은 반드시 · 부록 S-1 시도 기록 · 그 밖은 있을 때만).
- 채팅: PR 본문 5섹션(섹션 머리 ①~⑤ 글자 그대로 · ① 머리 2줄 + name-status 출력 그대로 + 커밋 목록 + 부록 S-1 한 줄 · ② 복사 상자 10항(10줄) + 괄호 + 10항 줄 수 출력 + «정적 묶음» 32줄 출력 전부 + S05 1줄 + ⓡ·ⓗ 출력 줄 + C-43 ⑩ 출력 + 테스트 파일별 끝 줄 · ③ Key 나열 + 골든 표 12행(dy 는 이름·밝기마다) + 부록 표 둘 · ④ · ⑤) + flutter test 한 줄 · 사전검사 두 번(① 코드만 · ② 제출 글까지) 🔴 0.
- `flutter test` = 시작 기준 N(0단계 · 드라이런 207) + 새 77(뷰 45 + 골든 j4 12 + S-12 뷰 12 + 골든 j1_rebalance 4 + S-1 1 + S-11 3 · 드라이런 284) · 정적 S26 = 15 · S27 = 7(🔴 정확히 — 다르면 반려) · S06 = 4 · S07 = 8 · S10 = 1 · S17 = 6 · S28 = 21이름 · S30 = 0 · S23 = 8/0 · 28/0 · 1/0(드라이런 · 기준 = 둘째 수 0) · C-43 ⑩ = «J-4 1파일»(2줄).
- 재분할 임계 확인(카드 계획): 새 testWidgets 줄 33(J-4 뷰 17 + 골든 1 + S-12 10 + 골든 1 + S-1 1 + S-11 3 · 임계 «> 33» — 넘지 않음 · 경계) · lib +743/-47(임계 «> +900» · 드라이런) · 새 PNG 16(임계 «> 16» — 경계) — 하나라도 넘으면 C4 가 S-12 를 떼어 소카드로 다시 나눈다(설계서 §6 «크기» · K22). 드라이런 판정 = 재분할 불필요(C4 검증 보강은 전부 기존 경우 루프·기존 테스트 안 — testWidgets 줄 · PNG 증가 0).
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것(2026-10-20 · 변이 도구 — 드라이런 43건 + 검증 83건 + 반영 뒤 재시험 22건): 원판에서 통과한 것 = «다음 건» 뒤 선택·접수증 유지(→ T4-10 보강) · scope 첫 값 전 목록(override 경로 → T1-3n 두 경우) ·
  override 경로 scope 에러 목록(→ T1-3o 두 경우) · 큐 에러 배너 · 카드 로딩 배너·스피너 · 빈 큐 배너 빼기(→ T4-13 card_skeleton · 배너 열) · 잠금 switch 네 값(→ T4-05 네 경우) · 재제출 때 플래그 유지(→ T4-06) · «다음 건» 구독 유지(→ T4-10 watch) ·
  진입 상태 공유 키(→ T1-3k) · 결과 섹션 글자 순서(골든만 잡던 것 → T4-07) — 보강 뒤 전부 KILLED(뷰 테스트만으로) · 🆕 결과 갈래 submitNotAccepted · 구독 에러 두 꼴 · 결과 섹션 정적 글자 · journal null 머리 · decisionLink null 버튼 = KILLED ·
  남은 것 = 이탈 배지 isDeviation 조건(정적 S11 이 잡는다 — 드라이런 확인).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R3-Bob-J4 결과: 브랜치 ui/m6-j4-review 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다(Claude 가 PR 을 만들고 본문을 이 글로 통째로 씁니다 · 부록 S-1 재생성 PNG 가 있으므로 `golden:approved` 라벨도 Claude 가 판단해 붙입니다). Bob 이 PR 을 직접 만들었다면 `R3-Bob-J4 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R3-Bob-J4 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`j1_*` 16 · `j2_*` · `j3_*`(부록 S-1 목록 밖) · `j3r_*` · `j5_*`)가 `M` ② `pubspec.yaml` 변경 ③ `test/golden/` 하네스·README·기존 골든 테스트의 단언이 `M` · `journal_common.dart` 의 기존 위젯 줄이 바뀜 ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now`·`RunMode`·`journalCommandApiProvider`·`DraftStore`·`.watchState(`·`ScaffoldMessenger` ⑤ `.score` 가 맵 값 자리 밖에 · `isDeviation`·`rejectReasonCode`·`card.result!` · 점수·건수를 글자로 만드는 코드 · `'%'` 문자열 ⑥ 마지막 커밋이 format·질문 커밋이 아님 · 공용 3파일에 삭제 줄 ⑦ ② 의 S05·S06·S07·S28 출력에 주석 줄이 찍힘 · ⓡ·ⓗ 수(S26·S27)가 15·7 이 아님 — 하나라도 있으면 반려 신호(⑦ 의 S05 줄 표기만의 결함은 strict 나눔 ① = C4 정정).
- CI «골든 스냅샷» 잡은 이번 PR 이 부록 S-1 로 **기존 PNG 를 바꾸므로 빨강이 정상**입니다 — 통합 담당이 «재생성 목록 = 카드 목록(6장)»과 PNG 를 대조한 뒤 `golden:approved` 를 붙입니다(목록 밖 M 이 있으면 붙이지 않고 반려).
- 계약 테스트 C-43 의 B 절(⑩~⑯)은 이 브랜치에서 처음 `lib/src/blind_review.dart` 를 실제로 본다 — 병합 검사 때 Claude 가 그 위에서 `dart test test/contracts/c43_blind_review_test.dart -r expanded` 를 돌리고 «C-43 ⑩ 대상» 출력을 PR 본문 ② 와 대조한다. `check_boundaries.sh` [5][5b][5c] 도 S-12 의 `timeline.dart`·새 테스트를 처음 본다.
- 셸(R13)에 넘길 것: `journalBlindReview` → `JournalBlindReview()`(전 플랫폼 등록 · 본문 Android·iOS · 웹 = Q-D 전 «부재» 가드) · override 목록 + `journalBlindReviewCommandApiProvider`(자리 = 조립 앱 3종 `apps/app_*/lib` · 폰 앱은 `journalCommandApiProvider` 와 같은 인스턴스) · `journalRebalance` → `JournalTimeline(key: ValueKey(id), rebalanceEventId: id)` — 이 카드에 없습니다.
- 범위 고지(01 §16-17 · 설계서 §7): outcome_score·2×2(미결 98) · SIM 결정 리뷰(미결 99 — DRY_RUN 동안 큐 = 빈 문장이 정상 · K24) · 공개 결과 재열람·뒤늦은 결과(미결 100) · 경합 거부 뒤 «기록된 답»(미결 101 — 두 기기가 같은 카드를 채점하면 뒤 기기는 기록되지 않은 자기 선택 옆에 앞 기기의 답으로 셈한 과정 점수를 본다 · 1인 운영 · 드묾) · X7 미이행 결정 표본(미결 102) · 기존 M6 화면 넷의 배너 관용구 중복 1벌(옮기기 = 범위 밖) · P2 알림 목적지(K23 — 엔진이 `deep_link` 로 고른다 · R13~)는 이 카드에 없습니다.
- 🔵 «다음 건» 은 엔진 의무(«결과가 실리는 같은 갱신에서 그 결정은 큐에서 빠진다»)를 믿는다 — 엔진이 어기면 방금 공개한 카드가 한 번 더 잡힌다(화면은 판정하지 않는다 · 06 M1-25 ① · 실엔진 대조 몫).
- 그 밖의 알릴 것은 `_완료/R12d-Bob-S710.md` «5» 와 `_완료/R2b-Bob-J3.md` 를 참고합니다.
