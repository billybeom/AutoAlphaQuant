# 발송 패킷 R12d-Bob-S710 — S7-10 안내 이행 리포트 (계약 v1.6 · R12 4장 중 4번째 · «정확히 N» 소유)

> ⏸ **아직 보내지 않습니다**(2026-10-08 조립 · 드라이런 1회 반영(2026-10-12 · `dry/r12d` @ `2edba9a`)) — 선행 = 계약 v1.6 병합(M2 PR #25 · squash `995c1f4` · 기록 `952b3eb`) → R12a 병합(squash `__R12A_SQ__`) → R12b 병합(squash `__R12B_SQ__`) → **R12c-Bob-S77 병합**(squash `__R12C_SQ__`) → 이 파일을 `send/_대기/` 에서 `send/` 로 옮긴 R12c 병합 기록 커밋이 GitHub `main` 에 있을 것(이 파일은 R12 조립 기록 커밋 `952b3eb` 이 `send/_대기/` 에 둔다). Claude 가 R12c 병합을 기록할 때 옮기고 이 줄을 ▶ 로 바꿉니다. **R12 4장 중 4번째**(K3 권고 선반영 · 순서 고정 R12a → R12b → R12c → R12d · 앞 카드 병합 뒤 다음 카드 · 한 번에 카드 1장).
> 만든 날 2026-10-08 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R12d 행 + R12 행 «v1.6 4분할 공통» · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-08_R12선행_계약v1.6_설계서.md` §2-5(공개 위젯·파일 자리·주입) · §2-6(호출 표) · §2-7(필드 → 자리 — `S7-10` 행) · §3-5(골든 ↔ 입력 R12d 6행) · §6 공통 규칙 1~19 + R12d 규칙 30~33 · §7(분할·재분할 임계) · 조문 = `01_…` §15-4(15-4-6 · 15-4-7 · 15-4-8 · 15-4-9 · 15-4-17 ⑨ · 15-4-18) · `03_…` §14-b 의 «🆕 계약 v1.6 — `S7-10` R12 범위 · 이 블록이 이긴다» 블록 ①~⑨ · §1-4 의 v1.6 줄 · 코드 = `packages/domain_contracts`(`ExecutionGapResult` · `ExecutionGapReport` · `ExecutionGapRepository.monthly({String? yyyyMm})` · `UnimplementedExecutionGapRepository`) · 계약 테스트 C-42(`test/contracts/c42_r12_screen_scan_test.dart` + `test/contracts/support/r12_targets.dart` 의 `R12Role.s710`) · golden README «🆕 R12(계약 v1.6)» 절(기록 커밋 몫).
> 사전 조건 — ✅ 계약 v1.6 병합(PR #25 · squash `995c1f4` · 기록 `952b3eb` · `contractVersion '1.6.0'` · 픽스처 135 · 라우트 45) · ⬜ R12a-Bob-S76ab 병합(`__R12A_SQ__` — `S7-6a`·`S7-6b` · 배럴 +2 · providers «R12a» 절 · `labels.dart` «R12a» 절) · ⬜ R12b-Bob-S76c 병합(`__R12B_SQ__` — `S7-6c` · 배럴 +1 · providers «R12b» 절 · `labels.dart` «R12b» 절) · ⬜ R12c-Bob-S77 병합(`__R12C_SQ__` — `S7-7` · 배럴 +1 · providers «R12c» 절 · labels 0). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 시작 기준 = R12c 병합본 `flutter test`(packages/ui_analytics) = ⟦실측 — R12c 병합 기록 때 C4 가 채운다⟧(누적 드라이런 446 = R12c 드라이런 `78189b0` 위 «+446: All tests passed!» — 🔴 R12b 보강 전 판(`a62f783`) 위의 값이다 · R12b 보강판 재측정 404(2026-10-13 · `dry/r12b-plus` `7272a43` · 보강 전 403 + 1)에 따라 R12c 병합본 기대 447(= R12c 드라이런 실측 446 + 1 · 늘어난 1 은 R12b 뷰 파일 안) → 이 카드 끝 기대 513(= 이 카드 드라이런 실측 512 + 1) · ▶ 로 바꿀 때 Claude 가 실제 R12c 병합본에서 재어 이 자리와 본문 0단계 · «3-1» 의 같은 표식, 모두 세 곳을 채운다).
> 카드 확정값(카드 권한): 정적 라벨 1개(본문 «정적 라벨») · Key 표(설계서 §6 규칙 17 의 `S7-10` 7개 글자 그대로 · 본문 «Key 표») · 위젯·프로바이더·파일 이름(설계서 §2-5 · §6 규칙 5 글자 그대로 · 본문 «주입 구조») · 새 lib 파일 1개 · 골든 6이름 12장(크기 390 × 844 — `kS710GoldenSize` · 드라이런 확정) · 🔴 **«정확히 N» 은 R12 에서 이 카드 한 곳만**(설계서 §6 규칙 33) — 배럴 export 집합 == **13**(T710-16) · `lib/src/providers` 의 `autoDispose` 줄 == **9**(T710-17).
> 🔴 **보내는 조건(Claude 확인)** — R12c PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-10_questions.md` 가 `main` 에 있음(빈 머리말 — R12 기록 커밋이 만든다 · K21 = 카드마다 1개) + `prompt_M7.md` 치환값이 R12 판(0단계 `git grep -c "R12d = S7-10"` = `:2` — 🔴 Claude 가 ▶ 로 바꾸기 전에 실제 `main` 에서 이 grep 을 돌려 확인한다) + golden README «🆕 R12(계약 v1.6)» 절에 R12d 행(`s710_*` 6이름 12장 · `kS710GoldenSize` 390 × 844 — 이 카드 머리 6행과 같은 크기) + 이 파일에 실측 표식 0(`grep -cP '\x{27E6}' R12d-Bob-S710.md` = 0 — 지금 남은 것은 «시작 기준 N» 3곳(머리 5행 · 0단계 flutter test 줄 · «3-1» 의 `flutter test` 줄)뿐 · R12c 병합 기록 때 병합본 실측으로 채운다) + ✅ 드라이런 뒤 바뀐 할 일 (2)/(3) 분할을 누적 드라이런에서 확인함(2026-10-13 · 아래 «드라이런» 줄 끝). 0단계의 `ls`·`grep` 줄이 그 증명입니다.
> 🔴 **카드 덮개 필수 문장(01 §15-4-6 · 03 §14-b v1.6 블록 ①④⑤⑥)** — «`S7-10` 은 받은 글자와 null 여부만 본다 — 건수·이행률·교정은 엔진 글자(`countLines`·`correctionLines`·`complianceRateLabel`)이고 게이지는 `complianceRateNormalized` 폭 전용(null = 게이지 부재)» · «`modeAdviceLine` null = 줄 부재 — 갈래를 화면이 고르지 않는다(문자열 비교 0)» · «원화·`Money`·`Decimal` 0 — 가격 갭은 bp 글자 그대로». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» ⑤⑳ 에 있습니다. Key 표와 라벨 글자 표도 본문에 있습니다.
> ✅ **K 결정 표식** — 이 카드가 기대는 K1(달 라우트 · `ExecutionGapScreen({String? yyyyMm})`) · K6(`modeAdviceLine` nullable · 03 §14-b 수용 (b) 정정) · K8(`ExecutionGapResult` 래퍼 · 게이지 nullable · 빈·해당없음·가림 표본)은 ~~**권고 선반영 · 🔴 발주자 확인 대기**(설계서 §10 · 01 §15-4-16)입니다 — 카드 본문은 K 를 «확정»으로 인용하지 않습니다. 「푸시해」 전 확인에서 하나라도 거절되면 이 카드는 다시 조립합니다(보내지 않음).~~ **✅ 발주자 확정(2026-10-13 «권고대로 확정하고 푸시해» — K1~K26 전부 권고대로 · 01 §15-4-16)** — 거절 0 · 다시 조립 0.
> 드라이런: ✅ **1회 실시(2026-10-12 · `C:/Work/AAQ-claude-review` 브랜치 `dry/r12d` @ `2edba9a` · 누적 = R12c 드라이런 `78189b0` 위 · 카드 본문만 보고 커밋 5개)** — 시작 N 446 → 끝 512(= N + 66 · 🔴 R12b 보강 전 판 위 — R12b 보강판 재측정 404(`dry/r12b-plus` `7272a43`) 위 기대 447 → 513) · 뷰 «+54» · 골든 «+12» · domain_contracts 계약 «+296 ~30» · C-42 ① 11줄(역할 5 + 경로 5 + «역할 대상 합 5파일 · providers R12 절 61줄») · 골든 390×844(기본 높이로 충분) · dy(light/dark 같음) cant 609 · wont 623 · mixed 685 · empty 112 · not_applicable 152 · masked_recon 574 · S02c 18 + 1 · S05 2줄(66·111) · S15 9줄 · S16b 13 · S27 3/0 · 16/0 · 1/0 · S31 15 · S32 8 · S33 7 · 12항 15줄 · lib +214(새 화면 194 · providers +16 · labels +3 · 배럴 +1 · 삭제 0) · T710-18 통과 · format 0 changed · analyze 0 issue · 예고 변이 = 보강 전 2건 통과(«제안 줄 TextButton» · «에러 + 스켈레톤») → 이 판에서 T710-08·T710-11 단언 보강 · «Key 없는 빈 막대» 는 변이 문장을 좁히고 T710-07 에 `FractionallySizedBox` 0 보강 · 재분할 임계 = 새 testWidgets 19(≤ 33) · lib +214(≤ +900) · 새 PNG 12(≤ 16) → 재분할 불필요. 드라이런 지적 10 + 콜드 리드 13 을 이 판에 반영(브랜치 이름 지적 1건은 기각 — 01 §15-4-18 · 설계서 §7 · 12 §3 모두 `ui/m7-s710-gap`). 🔴 드라이런 뒤 바뀐 것 — 할 일 (2)/(3) 분할(`pumpExecutionGap` 을 (3) 으로 옮김 · 드라이런 `7896d7c` 의 (2) 는 아직 없는 `ExecutionGapScreen` 을 쓰는 판) · fakes 의 (2) 판 import 7줄 · 커밋 제목 (2)~(4) 고정 — 은 ✅ 2026-10-13 누적 드라이런에서 확인했다 — 카드 (2) 절대로 다시 짠 판(`7896d7c` 에서 `pumpExecutionGap` 과 그것만 쓰는 import 2줄을 빼고 format · 커밋 안 함 · 패치는 Claude 기록 폴더) = fakes import 7줄(카드 (2) 판과 글자·순서 같음) · `analyze`(--fatal-infos 포함) No issues · `flutter test` 446 + 1 = «+447» · format 0 changed. 🔴 `7896d7c` 그대로는 (2)/(3) 분할 전 판이라 근거가 아니다(fakes 가 아직 없는 `ExecutionGapScreen` 을 불러 analyze 1 issue · import 9줄 · providers format 1 changed — 테스트는 +447 통과).
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 치환값(2행 `{{범위}}` · 109행 «이번 과제 범위:» · 118행 PR 제목)은 R12 기록 커밋이 **R12 네 장을 함께 적은 값**으로 바꾼다(R11 «두 장 한 치환판» 선례) · 0단계 확인 줄 `git grep -c "R12d = S7-10"` = `:2`(2행 · 109행) 가 그 증명 · 이 카드의 범위·PR 제목은 이 패킷이 정한다 · 그 파일 5행 «보충 표식»의 «범위 치환(2행)은 R12 조립 때 바꾼다»가 이것이다 · 아래 행 번호는 `e716fe0` 판 — 기록 커밋은 머리에 줄을 더하지 않는다) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R12a~R12c 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 끝 절 뒤에 더한다»로, 0단계·규칙 요약·본받지 않는 것·코드 틀은 본문에 담았습니다.
> R10·R11 교훈 반영: 보고 기계화(② 12항 복사 상자 + «정적 묶음» 출력 그대로 · ① name-status 출력 그대로 · ③ 위젯·Key 이름 나열) · S05 줄 괄호 금지 · ⓡ·ⓗ 개수는 정적 `grep -c` 줄로 대조 · 배치 순서는 테스트가 사슬로 증명 · 조건부 단언 금지(R11b 재제출 F1 — 사슬의 «없는 쪽»은 else findsNothing) · 공용 파일은 «끝 절 더하기만»(R10 3분할 교훈 — 앞 카드들은 «+N» · «정확히 N» = 이 카드의 T710-16·T710-17 두 곳) · 🆕 strict 보고 규칙 나눔(12 §3 R10~R16 머리) · 🆕 «PR 본문은 통합 담당이 바꾼다»(제출 상자에 섹션 머리 ①~⑤ 글자) · 🆕 재발 방지 ①(테스트별 수·12항 15줄·C-42 대상 수는 카드가 준 명령의 출력 그대로) · 🆕 C4b-12(배너 «스크롤 밖» 단언) · C4b-13(게이지 채운 막대 색·폭 — 범례 견본 색 단언 준용) · C4b-14(Key 자리마다 글자 == 픽스처 필드).

## 0. 한 줄 목적

안내 모드의 **이행 갭**(규칙과 실제 집행 사이의 틈)을 계약 v1.6 그대로 그리는 `S7-10` 화면 하나(`ExecutionGapScreen({String? yyyyMm})` — 리포트 | 빈·해당없음 문장 카드 · 3갈래 제안 줄 · 가림 · 게이지)를 짓고, R12 의 «정확히 N»(배럴 export 13 · `autoDispose` 9)을 새 테스트로 소유하기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s710-gap`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음 · 브랜치 이름 = 01 §15-4-18 · 12 §3 R12d 행 · 설계서 §7 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **R12c 가 `main` 에 병합된 뒤에 보냅니다** — 이 파일 머리 첫 줄이 ⏸ 이면 아직입니다(Claude 가 R12c 병합을 기록할 때 `send/_대기/` 에서 `send/` 로 옮기고 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R12a~R12c 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12d-Bob-S710.md> (로컬 사본 = Claude 기록 폴더의 `docs\ai-context\send\R12d-Bob-S710.md` — 폴더의 절대 경로는 ▶ 로 바꿀 때 Claude 가 확인해 적는다 · 기록 푸시 뒤 `main` 과 글자가 같습니다). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 R12c 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부** — ```text 다음 줄(«R12d-Bob-S710 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 R12 의 끝난 카드 `_완료/R12a-Bob-S76ab*.md` · `_완료/R12b-Bob-S76c*.md` · `_완료/R12c-Bob-S77*.md`, R11 의 `_완료/R11a-Bob-S74*.md` · `_완료/R11b-Bob-S79*.md`, M7 의 `_완료/R10a-Bob-S71b.md` · `_완료/R10b-Bob-S72G*.md` · `_완료/R10c-Bob-S72*.md` 를 붙여넣지 않습니다. `send/` 바로 아래의 R12 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12d-Bob-S710 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

```text
R12d-Bob-S710 — 범위: S7-10 안내 이행 리포트(ExecutionGapScreen({String? yyyyMm}) — 리포트 | 빈·해당없음 문장 카드 ·
  헤더(periodLabel + TrustBadgeView) · 이행률 게이지(complianceRateNormalized 폭 전용 · null = 부재) · 이행률 글자 · 건수 줄(countLines) ·
  중앙값 지연 · 가격 갭(bp) · 교정·소급 줄(correctionLines) · 정정 체인 · 미이행 사유 칩 · 방향 편향 칩 · 말미 제안 줄(modeAdviceLine — null = 부재) · 기준일) +
  주입 executionGapRepositoryProvider · 결과 executionGapProvider · 배럴 export 1줄 + 🔴 R12 «정확히 N» 소유(배럴 export 13 · autoDispose 9).
  R12 4장 중 4번째(R12a·R12b·R12c 는 이미 main 에 병합됨).
🔴 S7-10 은 받은 글자와 null 여부만 본다 — 건수·이행률·교정은 엔진 글자(countLines · correctionLines · complianceRateLabel) · 게이지는 complianceRateNormalized 폭 전용(null = 게이지 부재).
🔴 modeAdviceLine null = 줄 부재 — 갈래(못 함 · 안 함 · 갈리지 않음)를 화면이 고르지 않는다(문자열 비교 0 · 버튼·링크 0).
🔴 원화·Money·Decimal 0 — 가격 갭은 priceGapLabel(bp) 글자 그대로. 이 화면에 손익은 0 이다.
하지 않는 것: S7-6a·6b·6c·S7-7(R12a~c 몫 — 이미 main) · S7-8 · S7-1 ⑧ 의 수정(같은 달 가림 범위 차이 = 01 §8 미결 96 — 맞추지 않는다) · 소급 정정 각주 · LEDGER_INTEGRITY 가림 골든 ·
  뷰어 판 trust.actionDeepLink 목적지(이상 미결 96) · 「계획」 탭 ⑤ 존재 판정(미결 97) · 롤링 창(watchRolling) · 달 고르기·지난 달 이동 ·
  셸 몫(라우트 등록 ledgerExecutionGap·ledgerExecutionGapMonth · 라우터 가드 · 진입점 — M8 · R13) · 웹 2열·반응형(Q-D) · 칩 탭·툴팁·애니메이션 ·
  홈·알림·위젯 렌더(결정 8·㉟) · X7 미확정(㉕~㊷ — 과거 달은 받은 값 그대로 · 각주 자리 없음).
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 22항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12a(ui/m7-s76ab-rebalance) · R12b(ui/m7-s76c-preview) · R12c(ui/m7-s77-annual) — 셋 다 병합됨 — 가 아닙니다.
앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner · ui/m7-s79-goal-path · ui/m7-s76ab-rebalance · ui/m7-s76c-preview · ui/m7-s77-annual)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/screens/execution_gap_screen.dart · executionGapProvider · executionGapRepositoryProvider · Key s710-root 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s77-annual 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s710-gap origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.6.0'" -- packages/domain_contracts/lib/src/contract_version.dart                    ← «…contract_version.dart:1»(계약 v1.6 병합)
  git grep -c "class ExecutionGapResult" -- packages/domain_contracts/lib/src/dto/ledger_trust.dart                      ← «…ledger_trust.dart:1»
  git grep -c "Future<ExecutionGapResult> monthly({String? yyyyMm})" -- packages/domain_contracts/lib/src/repositories/execution_gap_repository.dart   ← «…execution_gap_repository.dart:1»
  git grep -c "class UnimplementedExecutionGapRepository" -- packages/domain_contracts/lib/testing.dart                    ← «…testing.dart:1»
  git grep -c "ledgerExecutionGapMonth =" -- packages/domain_contracts/lib/src/navigation/app_links.dart                  ← «…app_links.dart:1»(읽기만 — 이 카드는 쓰지 않는다)
  git grep -c "rebalanceHistory =" -- packages/domain_contracts/lib/src/navigation/app_links.dart                         ← «…app_links.dart:1»
  git grep -c "watchEvents({DateRange? range})" -- packages/domain_contracts/lib/src/repositories/rebalance_repository.dart   ← «…rebalance_repository.dart:1»
  git grep -c "annualReview({String? year})" -- packages/domain_contracts/lib/src/repositories/performance_repository.dart    ← «…performance_repository.dart:1»
  git grep -c "String yearLabel" -- packages/domain_contracts/lib/src/dto/performance.dart                                ← «…performance.dart:1»
  git grep -c "class RebalancePreviewResult" -- packages/domain_contracts/lib/src/dto/plan.dart                           ← «…plan.dart:1»
  ls docs/ai-context/send/R12d-Bob-S710.md                                                     ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/ui_analytics/lib/src/screens/rebalance_timeline_screen.dart                      ← 보여야 R12a 가 병합된 것입니다
  ls packages/ui_analytics/lib/src/screens/rebalance_event_screen.dart                         ← 보여야 함(R12a)
  ls packages/ui_analytics/lib/src/screens/rebalance_preview_screen.dart                       ← 보여야 R12b 가 병합된 것입니다
  ls packages/ui_analytics/lib/src/screens/annual_review_screen.dart                           ← 보여야 R12c 가 병합된 것입니다
  ls packages/ui_analytics/test/golden/goldens/s77_december_light.png                          ← 보여야 함(R12c 골든)
  ls packages/ui_analytics/lib/src/widgets/trust_badge_view.dart                               ← 보여야 함(헤더 배지 — import 만)
  ls packages/domain_contracts/fixtures/m7/execution_gap_cant.json                             ← 보여야 함(v1.6 개정 — 래퍼 {report, as_of})
  ls packages/domain_contracts/fixtures/m7/execution_gap_empty.json                            ← 보여야 함(v1.6 신설)
  ls packages/domain_contracts/fixtures/m7/execution_gap_not_applicable.json                   ← 보여야 함(v1.6 신설)
  ls packages/domain_contracts/fixtures/m7/execution_gap_masked_recon.json                     ← 보여야 함(v1.6 신설)
  ls docs/ai-context/inbox/S7-10_questions.md                                                  ← 보여야 함(빈 표가 이미 있다)
  git grep -c "R12d = S7-10" -- docs/ai-context/prompt_M7.md                                   ← «…prompt_M7.md:2»(프롬프트의 범위 치환값이 R12 로 바뀌었다 — 2행·109행)
  git grep -c "s710_cant" -- packages/ui_analytics/test/golden/README.md                                ← 숫자 하나(golden README «🆕 R12» 절의 R12d 행이 있다 — 기록 커밋 몫)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir · && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R12d 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/screens/execution_gap_screen.dart                           ← 없어야 함
  ls packages/ui_analytics/lib/src/execution_gap                                               ← 없어야 함
  git grep -c executionGapProvider -- packages/ui_analytics/lib                                ← 출력 없음이어야 함
  git grep -c executionGapRepositoryProvider -- packages/ui_analytics/lib                      ← 출력 없음이어야 함
  git grep -c s710- -- "packages/ui_analytics/*.dart"                                          ← 출력 없음이어야 함(.dart 만 본다 — golden README 의 R12 절은 s710- 글자를 담고 있어도 정상)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 새 타입(ExecutionGapResult · countLines …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류). «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: R12c 병합본 전부 통과 · 0 실패 · 기대 ⟦실측 — R12c 병합 기록 때 C4 가 채운다⟧(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · README 의 수치는 보지 않는다 ·
                   그 수와 다르면 멈추지 말고 PR 본문에 까닭 한 줄 — 그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·C-42) > 이 카드(지시) > 01 §15-4·§15-3 > 03 §14-b 의 v1.6 블록 > 03 본문·그림 M7-26 > prompt_M7.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 ·
   이 카드에서 «규칙 N» · «이 카드 규칙 N» = 바로 아래 규칙 요약의 N 번 · «설계서 §6 규칙 N» 은 출처 표시일 뿐(Bob 은 설계서를 열지 않는다 — 정본 = 이 카드의 글자))
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox/S7-10_questions.md 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart·test/contracts/** 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·goal_path_probe_test·reference/**·README ·
   기존 골든 테스트 전부(s71~s79 · R12a~c 의 골든 테스트) · 기존 PNG 전부(96장 = 64 + R12a 12 + R12b 10 + R12c 10 · 하나라도 M 이면 되돌리고 멈춤 · 예외 없음) ·
   기존 lib 파일 전부(lib/planner.dart · lib/src/planner/** · lib/src/goal_path/** · lib/src/chart/** · lib/src/widgets/**(trust_badge_view·stale_banner·safety_block_banner 포함) ·
   lib/src/screens/** 의 기존 화면(R12a~c 가 만든 화면 파일 포함) · lib/src/rebalance/** · lib/src/annual_review/**(폴더가 있으면 — R12a~c 는 만들지 않았다 · C-42 역할 표의 internalDir 자리)) ·
   기존 테스트 전부(goal_path_view_test 의 T79-14 포함 — v1.6 이 완화했고 정확 집합은 이 카드의 새 테스트가 갖는다 · R12a~c 의 테스트·가짜 · explore_fakes · goal_path_fakes · planner_fakes).
   공용 파일 3개는 **더하기만** 한다 — 기존 줄(R12a~c 절 포함)은 한 글자도 바꾸지 않는다(정적 묶음 S27 의 삭제 수 0 이 증명):
     lib/l10n/labels.dart = 파일의 마지막 절(R12b 절 — R12c 는 라벨 0 이라 labels.dart 에 R12c 절이 없다) 뒤에 이 카드의 절 하나 ·
     lib/src/providers/analytics_providers.dart = 끝(R12c 절 뒤)에 이 카드의 절 하나(머리 줄 = // ── 🆕 R12d — S7-10 ──) ·
     lib/ui_analytics.dart = export 한 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
 2 03 §14-b 위쪽 본문(「데이터」 의 int 나열 · 「컴포넌트」 의 건수 묶음 issued·filled… · 「수용」 (b) 옛 글 · 그림 M7-26 의 CNT·FIX·RATE 노드)은
   03 §14-b 의 v1.6 블록(머리글 «🆕 계약 v1.6 — `S7-10` R12 범위 · 이 블록이 이긴다»)과 01 §15-4 에 집니다.
   int 9종(issued·filled·partial·skipped·lapsed·revoked·lateFilled·backdatedCount·selfReportCorrectionCount)을 코드에 쓰지 않는다 — 건수·교정은 countLines·correctionLines 글자다.
   또 01 §15-4 머리·03 블록의 «⬜ 로컬 커밋 — PR 대기» 흔적과 K 의 «🔴 확인 대기» 표식은 병합 전의 글이다 — 멈추지 않는다(이 카드가 이긴다 · K 를 «확정»으로 인용하지는 않는다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(ExecutionGapScreen 의 생성자에는 key·yyyyMm 뿐).
   이 카드가 여는 링크는 DTO 문자열 둘뿐이다: BlockFlag.clearDeepLink(SafetyBlockBanner 가 onOpenLink 로 넘긴다) ·
   LedgerTrustBadge.actionDeepLink(TrustBadgeView 가 onOpenLink 로 넘긴다 — 화면 파일은 actionDeepLink 를 읽지 않는다). 이 카드가 쓰는 AppRoutes 상수는 0 개다(ledgerExecutionGap · ledgerExecutionGapMonth 는 셸 R13 이 이 위젯으로 배선한다 — 읽기만).
 4 값 = DTO 의 *Label·*Lines·label 그대로 · 계약이 주는 표시 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(int·double·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값으로 색을 고르지 않음(예외 = 칩 tone — 아래 7) · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20 은 주석 줄도 센다.
 5 읽지 않는 필드(카드가 정함 — 질문 아님): ExecutionGapResult.emptyKind(빈·해당없음 둘 다 emptyLabel 문장 카드 — C-42 ② 가 .emptyKind 를 막는다) /
   report.range · int 9종 · report.asOf(하단·배너는 result.asOf 하나 — C-41 ⑧ 이 같은 값을 보장) /
   trust.grade · trust.level · trust.lastVerifiedOn · trust.actionDeepLink(TrustBadgeView 안쪽만 읽는다 — 화면 파일 0) / ReasonChip.code · ReasonChip.detailDeepLink(칩 탭 0) /
   창구 watchRolling · LedgerTrustRepository.watchGrade(구독 0 · 헤더 배지 = report.trust 하나).
   🔴 C-42 ③ 의 S7-10 금지 목록(.issued .filled .partial .skipped .lapsed .revoked .lateFilled .backdatedCount .selfReportCorrectionCount .range .grade .level .lastVerifiedOn)과 ② 공통 목록(.mode .kind .code .emptyKind .wire .hasMore …)은 점 접근뿐 아니라 패턴 분해(③' — 예 final ExecutionGapReport(:issued) = r)도 막는다 — 둘 다 쓰지 않는다.
   🔴 C-42 ⑩ 가드 — R12 전용 이름(ExecutionGapResult · ExecutionGapReport · ExecutionGapRepository …)은 lib/src/screens/execution_gap_screen.dart 와 analytics_providers.dart 의 R12 표식 아래(이 카드의 R12d 절)에만 둔다(주석 말고 — 표식 위에 두면 C-42 ⑩⑬ 실패).
 6 화면 산술 0 — 예외 하나 = 게이지 폭 normalized.clamp(0.0, 1.0)(엔진이 준 0.0~1.0 정규값 · 폭 전용 · 03 「컴포넌트」 «폭으로만»).
   목록을 거르지도 세지도 정렬하지도 묶지도 않는다(countLines · correctionLines · 칩 = 받은 순서 · 순번 = .indexed 의 i) · 목록 길이·int 를 글자로 0 ·
   C-42 ⑨ 낱말 0(.where .sort .sorted .reversed .take .skip .fold .reduce .toSet .compareTo · .contains( .split( .substring( .replaceAll( … · reverse: true) — .indexed · .map · .isNotEmpty 는 허용.
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에서 열거형 switch 는 칩 색(ChipTone 4갈래 — 아래 «화면») 하나다. 🔴 CommandState 0 · rejectReasonCode 0(이 카드에는 명령이 없다).
 8 시계 = analyticsClockProvider(DateTime.now() 금지) — 쓰는 자리는 StaleBanner 하나다(위젯이 안에서 읽는다).
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(executionGapProvider(yyyyMm)), lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ·
   오래됨 = StaleBanner(asOf: result.asOf) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다 — «?» 가림은 엔진 글자 · 03 §1-4 v1.6 줄 «R12 = SafetyBlockBanner 만»).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(값이 온 뒤에만 — R11b 목표 경로와 같다).
   🔴 두 배너는 스크롤 밖이다(값이 온 뒤의 Column 첫째·둘째 자식 · Expanded(ListView) 바깥) — C4b-12: 테스트가 find.ancestor(of: <배너 글자>, matching: find.byType(Scrollable)) findsNothing 으로 본다.
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지 — 🔴 C-42 ⑤ 는 «Scaffold» 를 부분 일치로 보므로 ScaffoldMessenger 도 걸린다 · S7-10 파일에 ScaffoldMessenger·SnackBar 0 ·
   주석에도 이 낱말 0 · 정적 S26 · report_archive_screen.dart 의 클래스 주석 «Scaffold·AppBar 는 셸 소유»를 본뜨지 않는다) ·
   🔴 Card() 는 기본 고도(elevation 인자 없음 — 기존 M7 화면의 elevation: 0.5 를 본뜨지 않는다 · C-42 ⑥ 이 소수부 ≠ 0 소수를 막는다 · 정적 S29) · 선 굵기·투명도도 정수·N.0·colorScheme 만 ·
   띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지 · 390px overflow 0 · 글꼴 200% overflow 0(T710-18) ·
   엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(정적 글자 = 미이행 사유 머리 1 — 아래 «정적 라벨»).
10 프로바이더는 둘만 더한다 — 주입 executionGapRepositoryProvider(기본 throw UnimplementedError) + 결과 executionGapProvider(autoDispose family · 열쇠 = 생성자 yyyyMm 그대로 · String?) ·
   analytics_providers.dart 끝 R12d 절 · 나머지(기존 · R12a~c 의 것)는 이름·타입 그대로 두고 고치지 않는다 · 오프너는 탭 콜백 안에서 ref.read — build 에서 read 금지.
   🔴 executionGapProvider 는 autoDispose 다 — 기존 3개(비-autoDispose family)를 본뜨지 않는다. 🔴 주석에 autoDispose 라는 낱말을 쓰지 않는다(정적 S15·T710-17 이 주석도 센다).
11 테스트 = testing.dart 받침대 extends(UnimplementedExecutionGapRepository · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처 행에서) · 링크는 RecordingLinkOpener 를 픽스처 값과 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'T710-08 advice line cant') ·
   테스트 3파일의 문자열 리터럴은 전부 ASCII 만(이름 · reason: · 그 밖 모두 — «—»·«→»·«·» 도 금지 · 정적 S01·S02a·S02b · 한국어가 필요하면 \u 이스케이프) ·
   목록·집합을 «있으면 넣는다»로 만들 때(T710-03 사슬 말고 — 예 T710-15 의 허용 글자 집합)는 null-aware 원소(?report?.modeAdviceLine · ...?report?.countLines)로 만든다 — else 없는 if 0(SDK ^3.13).
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다 ·
   스켈레톤 1 = expect(find.byType(AnalyticsSkeleton), findsOneWidget) — 스피너 부재로 대신하지 않는다 ·
   테스트는 package:ui_analytics/src/widgets/analytics_error_view.dart · analytics_skeleton.dart · trust_badge_view.dart 를 직접 import 한다(배럴이 export 하지 않는다) ·
   🆕 C4b-14 — Key 를 단 Text 마다 tester.widget<Text>(find.byKey(…)).data == 픽스처 필드(Key 가 있는지만 보지 않는다 — Key 자리 그대로 글자만 맞바꾼 변이를 잡는다) · if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   ⓡ = 정상 상태 테스트마다 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 를 **한 줄에 하나**(여러 경우를 도는 테스트는 본문에 한 줄) ·
      ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 전제 한 줄. 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄이어야 한다(접히면 줄을 얕게) —
      정적 묶음 S31·S32 가 git grep -c 로 센다 — 🔴 아래 최소 목록의 ⓡ·ⓗ 표시 수와 **정확히** 같아야 한다
      (execution_gap_view_test.dart ⓡ 15 · ⓗ 8 · 다르면 제출 전에 테스트를 고친다 · PR 본문의 까닭 한 줄로 갈음하지 못한다 · 다른 채 내면 반려).
   🔴 ⓗ(hasLength)를 두는 곳은 아래 최소 목록에 ⓗ 로 표시한 자리뿐이다(8). 그 밖의 루프 — T710-03 의 사슬 Finder 목록 · T710-10·T710-11 의 플래그 루프 · T710-15 의 Text 루프 ·
      픽스처·경우 목록 — 에는 hasLength( 를 쓰지 않는다(쓰면 S32 가 기대 8 과 달라진다 — 제출 전에 고친다 · 다른 채 내면 반려).
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기 · 빈 if 블록)와 firstWhere 다. 양쪽에 expect 가 있는 if/else(카드가 «양쪽 다»라 적은 곳)는 허용한다. T710-03 의 사슬 목록을 만드는 «있으면 사슬에 넣는다»는 «없으면 else 로 findsNothing»과 짝일 때만 허용한다(R11b 재제출 F1 — 있는 쪽 = chain.add(뒤의 사슬 루프가 findsOneWidget 으로 단언) · 없는 쪽 = else findsNothing).
12 게이지의 증명 = T710-07(채운 막대 폭 ÷ 게이지 폭 == complianceRateNormalized · 채운 막대 색 == colorScheme.primary — C4b-13 «견본 색» 단언 준용) · 골든은 보조.
13 골든 = 새 PNG 12장(s710_*) · --update-goldens 는 test/golden/s710_golden_test.dart 하나만(폴더 지정 금지) · 기존 PNG 재생성 0 ·
   golden:approved 는 안 붙임(통합 담당) · 찍기 전 위치 전제(맨 아래 위젯 s710-asof 의 dy < 높이).
14 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(멈출 수 있다) · 패키지 테스트는 packages/ui_analytics 에서 flutter test 를 직접 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)) · directives_ordering 린트(import·export 는 가나다가 아니라 경로 알파벳 순).
15 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   이 카드의 위험: report.priceGapLabel 옆에 연산자 0 · 지역 변수 이름에 ratio·pct 금지(fillRatio · ratePct 같은 이름 대신 fill · normalized) · aspectRatio·devicePixelRatio·duration·decoration 옆 연산자 0 · 글자 잇기는 보간.
16 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
17 정적 묶음은 git grep 이라 **주석도 센다**(C-42 는 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄
   (execution_gap_screen.dart · analytics_providers.dart 의 R12d 절 · labels.dart 의 R12d 절)의 주석에 이 낱말을 쓰지 않는다:
   AppRoutes · analyticsLinkOpenerProvider · CommandApi · CommandState · Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · NumberFormat · GestureDetector · Colors ·
   Scaffold · AppBar · SafeArea · SnackBar · autoDispose · planner · operatingMode · RunMode · watchGrade · watchRolling · Decimal · Money · elevation · s710- (카드 문장을 가드 주석으로 옮겨 적지 않는다 · 이 목록은 Bob 이 쓰는 주석에만).
   🔴 execution_gap_screen.dart 는 analytics_providers.dart 를 show 없이 import 한다 — S05 에는 탭 콜백 안의 2줄(SafetyBlockBanner onOpenLink · TrustBadgeView onOpenLink)만 나와야 한다
      (import 줄·주석 줄이 찍히면 위반 · 탭 콜백 밖의 줄에 «— 탭 콜백 안» 을 적으면 거짓 보고 = 반려).
🔴 보고 규칙(strict 나눔 — 발주자 결정 2026-10-01 · 12 §3 R10~R16 머리 · R11b 재제출 판정부터 · 이 카드에 적용) —
   ① 보고 **표기만**의 결함(경로 앞머리·백틱·요지 줄임·까닭 누락 등 — 내용은 사실이고 글자 모양만 카드와 다른 것) = 반려하지 않는다 → 통합 담당이 PR 본문을 정정하고 병합한다.
   ② **코드·테스트 결함**(카드 규칙 위반 — 예 규칙 11 «else 없는 if»)과 **거짓 주장**(보고 내용이 코드·파일·PNG 와 다름) = **반려**(재량 없음).
   ③ 아래 «예고 변이» 가 하나라도 테스트를 그대로 통과하면 = **반려**.
   그래도 원칙은 «출력 그대로» 다 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다(글자는 테스트 글꼴이라 네모).
   🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 GitHub 에서 PR 본문을 직접 고치지 않는다(채팅으로만 낸다 · 통합 담당이 «■ 제출» 의 섹션 머리 ①~⑤ 글자 그대로 PR 본문을 통째로 쓴다).
   🔴 정적 묶음 S05 의 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만 적습니다 — 괄호·위젯 이름·매개변수 이름·설명 금지.
      정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ 와 완전히 같아야 합니다 · <파일> = git grep 출력의 경로 그대로(앞머리 packages/ui_analytics/ 없이 · 백틱 없이 · 줄 끝 빈칸 없이).
   🔴 «까닭» 류의 수(테스트 파일별 통과 수 · ⓡ·ⓗ · S05·S15·S16b·S13 줄 수 · C-42 대상 수 · 12항 줄 수)는 손으로 세지 않는다 — 이 카드가 준 명령의 출력을 그대로 붙인다(12 §3 «재발 방지 ①» · R11a 2회차 반려 사유).
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M7.md 156~170행 12항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 · 항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다).
   ③ 은 코드를 위에서 아래로 읽으며 나오는 위젯·Key 이름 나열로만 씁니다(«순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지 — R10c 1회차 반려 사유).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 22항 (prompt_M7.md 행 번호 = e716fe0 판 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 12~13행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변 · 게이지는 FractionallySizedBox 하나)
 ② 14~15행 «라우트 상수로 딥링크» → DTO 링크(BlockFlag.clearDeepLink · LedgerTrustBadge.actionDeepLink)를 AppLinkOpener.open 에 · 쓰는 AppRoutes 상수 0(규칙 3)
 ③ 16~18행 DateTime.now() 금지 → 그대로 · 주입 시계를 읽는 자리는 StaleBanner 하나
 ④ 21~23행 «산술 입력은 0.0~1.0 정규값» → 그대로 유효 — 화면 산술은 게이지 폭 normalized.clamp(0.0, 1.0) 하나(규칙 6)
 ⑤ 24~25행 «건수 집계도 재계산 · 뷰모델이 준 수를 그대로» → 🔴 v1.6 = 건수·교정은 countLines·correctionLines **엔진 문장** 그대로(int 9종 미참조 · 목록 길이를 글자로 0)
 ⑥ 30~32행 «목록이 비면 그 자리를 그리지 않는다» → 그대로 유효 — 칩 빈 목록 = 자리 부재 · correctionLines 빈 목록 = 줄 0 · 리포트가 없으면 emptyLabel 문장 카드 하나
 ⑦ 48·69행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ⑧ 50~56행 수치·금액 리터럴 금지 → 그대로 유효 · 실제 강제 = 계약 테스트 C-42 ⑥⑦ · C-38 ⑫(CI) + 정적 S21~S23·S28
 ⑨ 90행 «자체 점검 10항» · 155행 «명세 §12와 1:1» → 156~170행 12항(이 카드 밖의 4·5·6·8 · 10 앞절 · 12 는 [x] + 괄호 «이 카드 범위 밖»)
 ⑩ 90~91행 스크린샷 4장 → 서술 + 골든 표(«제출» ③)
 ⑪ 89~90행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅 · PR 본문은 통합 담당이 바꾼다)
 ⑫ 95~96행 «픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조» → 그대로 유효 · 이 카드는 재생성 0(새 PNG 12장만)
 ⑬ 99~101행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 이 화면의 타입은 코드에 확정(ExecutionGapResult · ExecutionGapReport v1.6)
 ⑭ 103~108행 역할 문단 · «반응형으로 넓히십시오» → 폰 세로 하나(웹 2열 = Q-D · 범위 밖) · 104~107행 화면 목록에 S7-10 이 없어도 이 카드의 범위다(146행 «S7-10 이 이 모듈에 붙습니다»)
 ⑮ 109행 범위 치환값 → 이 카드의 범위 = S7-10 하나(치환값은 R12 네 장을 함께 적은 것 — 0단계 확인 줄)
 ⑯ 110~116행 «읽을 문서 5개» → 아래 «먼저 읽을 것»
 ⑰ 117~118행 브랜치 형식 ui/m7-<화면ID소문자> · PR 제목 치환값 → 브랜치 ui/m7-s710-gap · PR 제목은 «■ 제출» 이 정한다
 ⑱ 119~135행 결정 8 의 S7-2 3종 · 기간 프리셋 · 결측 · 행동 갭 · 플래너 → 이 카드 범위 밖(12항 4·6번 괄호 «이 카드 범위 밖»)
 ⑲ 136~137행 S7-8 임베드 · 목표 경로 한 줄 → 이 카드 범위 밖(S7-8 = R12 밖 · 2026-10-07 결정)
 ⑳ 146~148행 «S7-10 — bp만 · modeAdviceLine 은 엔진 문자열 · 14번째 항목 아님» → 그대로 유효 + 🔴 v1.6 = modeAdviceLine null = 줄 부재(갈리지 않음·정상 달) ·
    ⓑ 문장 안의 J-4·반증 조건 언급은 글자일 뿐(버튼·링크 0) · ⑧ 부기는 S7-1 몫(이 카드는 S7-1 을 고치지 않는다)
 ㉑ 138~145행 세후 사다리 · 목표 경로 가정 카드 · 149~151행 회차↔일지 양방향 딥링크 → 이 카드에 없음(S7-7 = R12c · S7-9 = R11b · S7-6b = R12a)
 ㉒ 152~154행 값을 두면 안 되는 미결 → 이 카드에 해당 없음 · S7-10 의 남은 것(소급 정정 각주 · 가림 범위 · 뷰어 actionDeepLink)은 01 §8 미결 96 — 화면이 자리를 만들지 않는다

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문(머리 4·5행 «정정·보충 표식» 포함)
 ② 01 §15-4 — 15-4-1(한 문장) · 15-4-6(S7-10 — 래퍼 · 두 줄 목록 · nullable 2 · 달 라우트 · watchRolling 미사용) · 15-4-7(공개 위젯·파일 자리·providers R12 절) · 15-4-8(호출 표) ·
    15-4-9(필드 → 자리 — S7-10 행) · 15-4-17 ⑨(같은 달 가림 차이) · 15-4-18(카드 · 프로바이더 이름 · «정확히 N»)
 ③ 03 §14-b 의 v1.6 블록 — 머리글 «🆕 계약 v1.6 — `S7-10` R12 범위 · 이 블록이 이긴다»(찾는 말 = «S7-10` R12 범위 ·» · 「모의」 줄 바로 아래 · 그림 M7-26 앞) ①~⑨ +
    §1-4 표 아래의 v1.6 줄(«R12 … = SafetyBlockBanner 만» · «S7-10 가림 = 엔진 글자(«?» · 게이지 부재)»)
 ④ packages/domain_contracts/lib/ — src/dto/ledger_trust.dart 의 ExecutionGapResult · ExecutionGapReport · LedgerTrustBadge · src/dto/common.dart 의 ReasonChip · src/enums/ui.dart 의 ChipTone ·
    src/repositories/execution_gap_repository.dart · src/navigation/app_links.dart(ledgerExecutionGap · ledgerExecutionGapMonth — 읽기만 · 쓰지 않는다) ·
    testing.dart(UnimplementedExecutionGapRepository — monthly 는 동기로 던진다 · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c42_r12_screen_scan_test.dart 머리 주석 + support/r12_targets.dart 의 R12Role.s710 행(읽기만 — 이 카드의 화면 파일이 처음으로 그 대상이 된다)
 ⑥ packages/ui_analytics/test/golden/README.md «🆕 R12(계약 v1.6)» 절(기록 커밋 몫) + «🆕 R10» 절의 «2. 높이와 위치 전제» + «규칙»·«하네스» 절
 ⑦ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문(R12a~c 절 포함) ·
    lib/src/screens/goal_path_screen.dart(로딩·에러·배너 뼈대의 선례 — 틀만) · lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · stale_banner.dart · safety_block_banner.dart · trust_badge_view.dart ·
    test/explore_fakes.dart(FakeSafetyRepository — import 만) · test/goal_path_fakes.dart(가짜·띄우기 도우미 모양의 선례) · test/golden/golden_support.dart · test/golden/s79_golden_test.dart(루프 모양)
 ⑧ packages/domain_contracts/fixtures/README.md 의 «계약 v1.6» 절 + 이 카드가 쓰는 픽스처(아래 «픽스처») ⑨ docs/ai-context/inbox/README.md · S7-10_questions.md 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton — R10a · 이미 main)
 · 기존 M7 화면의 Card(elevation: 0.5) → Card() 기본 고도(C-42 ⑥ · 01 §15-4-17 ⑧)
 · analytics_providers.dart 의 비-autoDispose family 3개 → executionGapProvider 는 autoDispose
 · report_archive_screen.dart 의 클래스 주석(«Scaffold·AppBar 는 셸 소유 …») → S7-10 파일 주석에 Scaffold·AppBar·SafeArea 낱말 0(정적 S26 · C-42 ⑤ 는 주석을 빼고 보지만 정적 묶음은 주석도 센다)
 · trust_badge_view.dart 안의 Colors.*·trust.level 분기 → 그 위젯은 고치지 않고 쓰기만 한다(배지 색은 widgets 몫 · C-42 대상 밖) · 화면 파일에서 trust.grade·trust.level 0
 · deposit_planner_screen.dart(R11a)의 _chipToneColor → 색 갈래만 아래 «화면» 글자대로 이 화면 파일 안에 다시 쓴다(planner 파일 import 금지 — C-35 ⑥ · C-42 ⑤ · 역할끼리 공유 파일 0)
 · monthly_report_screen.dart D⑧ 줄의 이행률 글자 → S7-10 은 가림 표본에서 «?» 다(같은 달 차이 = 미결 96 · 맞추지 않는다 · S7-1 을 고치지 않는다)
 · 03 §14-b 위쪽 「데이터」·「컴포넌트」 의 int 나열과 그림 M7-26 의 CNT·FIX 노드 → countLines·correctionLines 글자 · int 9종 0
 · 테스트의 class … implements SafetyRepository(monthly_report_view_test · s71_golden_test 의 _FakeSafetyRepository) · 한국어 테스트 이름 · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · 띄우기 도우미(pumpExecutionGap) · ASCII 이름
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s710-…) · 아래 Key 표 7개뿐

■ 주입 구조 (이름·타입 고정 = 01 §15-4-18 · 설계서 §6 규칙 5 글자 그대로 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · TrustBadgeView(trust:, onOpenLink:) · AnalyticsSkeleton() · AnalyticsErrorView(onRetry:, lastAsOfLabel:) ·
  AnalyticsLabels.retryButton · staleBannerTitle · actionViewButton(TrustBadgeView 안의 버튼 글자 — 이미 있다 · 화면 파일은 쓰지 않는다).
· 쓰지 않는 것: performanceRepositoryProvider(S7-10 은 PerformanceRepository 를 부르지 않는다) · R12a~c 의 프로바이더(rebalanceRepositoryProvider · analyticsWhatIfApiProvider ·
  rebalanceEventsProvider · rebalanceEventProvider · nextRebalanceProvider · annualReviewProvider — 같은 파일이라 import 는 되지만 읽지 않는다).
· 🆕 프로바이더 둘 — lib/src/providers/analytics_providers.dart 끝(R12c 절 뒤)에 이 모양으로 더한다(기존 줄 무변경):
    // ── 🆕 R12d — S7-10 ──
    /// S7-10 이행 갭 — 주입 창구(조립 앱이 override · 01 §15-4-7)
    final Provider<ExecutionGapRepository> executionGapRepositoryProvider =
        Provider<ExecutionGapRepository>((ref) {
          throw UnimplementedError(
            'executionGapRepositoryProvider must be overridden',
          );
        });

    /// S7-10 이행 갭 — 받은 달 그대로(null = 엔진 기본 달 · 01 §15-4-6)
    final AutoDisposeFutureProviderFamily<ExecutionGapResult, String?>
    executionGapProvider = FutureProvider.autoDispose
        .family<ExecutionGapResult, String?>((ref, yyyyMm) {
          return ref.watch(executionGapRepositoryProvider).monthly(yyyyMm: yyyyMm);
        });
  🔴 열쇠 = 생성자 yyyyMm 그대로(null 포함 · 달을 고르거나 바꾸지 않는다) · 이 절이 부르는 창구는 monthly 하나 · 주석에 autoDispose 낱말 금지 ·
     이 모양이 dart format 결과다(return 은 한 줄 — (2) 커밋 전에 dart format 을 돌려 (3) 에 포맷 변화가 섞이지 않게 한다) · autoDispose 가 든 줄은 하나(S15 · T710-17) ·
     절 앞의 빈 줄 1 을 더해 이 절은 16줄 더하기다(S27 providers «16 0»).
  🔴 C-42 ⑬ 은 첫 «// ── 🆕 R12» 표식부터 파일 끝까지를 본다 — 이 절에 DateTime·DateRange·TradeDate 0 · previewRebalance 0 · watchRolling·watchGrade 0 · 정렬·거르기 낱말 0.
· 🆕 lib 파일 1개(이것 말고 새 lib 파일을 만들지 않는다 — lib/src/execution_gap/ 폴더도 만들지 않는다 · 본문·게이지·칩은 이 파일 안 private 메서드로 ·
  private 메서드로 나누면 파일 글자 순서와 화면 순서가 달라진다 — 제출 ③ 은 «렌더 순서»(메서드 호출을 그 자리에 펼친 순서)로 쓴다):
    lib/src/screens/execution_gap_screen.dart   ExecutionGapScreen({super.key, this.yyyyMm}) — 공개 · ConsumerWidget(State 없음) · final String? yyyyMm
  (C-42 역할 표 R12Role.s710 = 이 파일 + lib/src/execution_gap/** — 이 카드는 앞의 것 하나만 쓴다 · C-42 ① 출력 «S7-10(R12d) 1파일»)
· 배럴 lib/ui_analytics.dart 에 export 'src/screens/execution_gap_screen.dart'; 한 줄 —
  🔴 자리 = export 'src/screens/drawdown_context_screen.dart'; 줄과 export 'src/screens/goal_path_screen.dart'; 줄 **사이**(끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패).
· import 하지 않는 것: lib/planner.dart · lib/src/planner/**(C-35 ⑥ · C-42 ⑤) · R12a~c 의 화면·폴더(lib/src/rebalance/** · lib/src/annual_review/** · 역할끼리 공유 파일 0 — 설계서 §2-5).

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / fixtureEnvelope · 행 타입 = ExecutionGapResult 래퍼)
 이행 갭  singleFixture(FixturePaths.m7ExecutionGapCant, ExecutionGapResult.fromJson) · m7ExecutionGapWont · m7ExecutionGapMixed · m7ExecutionGap1(아래 «gap1») · m7ExecutionGapMaskedRecon ·
          m7ExecutionGapEmpty · m7ExecutionGapNotApplicable
          (모양 — 테스트는 이 표를 믿지 말고 hasLength 전제로 다시 확인한다:
           cant · wont · mixed · gap1 · masked_recon = report 있음 / empty · not_applicable = report 없음 + emptyLabel 있음 /
           complianceRateNormalized = masked_recon 만 없음 / countLines = 다섯 다 3줄(masked_recon 은 «?» 글자) / correctionLines = cant 2 · wont 0 · mixed 2 · gap1 0 · masked_recon 2 /
           skipReasonBuckets = cant 2 · wont 2 · mixed 3 · gap1 1 · masked_recon 0 / selectiveExecutionChips = wont 1 · mixed 1 · 그 밖 0 /
           modeAdviceLine = cant · wont 있음(서로 다른 문장) · mixed · gap1 · masked_recon 없음 / trust.actionDeepLink = mixed · masked_recon 있음 · 그 밖 없음 /
           일곱 다 result.asOf 가 같은 글자이고 FixedClock(kGoldenNowUtc) 에서 오래됨 아님)
 달       singleFixture(FixturePaths.m7M7Monthly202608, MonthlyReport.fromJson).yyyyMm — T710-02·T710-11 이 넘기는 달(S7-1 ⑧ 이 그 달 라우트로 여는 달 · 🔴 테스트에 리터럴 달 금지)
 안전     SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상(플래그 0) · 1 표식만(SELF_AUDIT_DUE — 차단 줄 0) · 3 차단 2건(RECON_MISMATCH · JOURNAL_MISSING) · 4 무결성(LEDGER_INTEGRITY · clearDeepLink 1)
 쓰지 않는 것: m7LedgerTrust4(S7-10 미사용 · 설계서 §3-5) · m7M7MonthlyMasked*·m7M7MonthlyGap·m7M7MonthlyPending(S7-1 몫).
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다. 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 — S7-10 ExecutionGapScreen (01 §15-4-9 S7-10 행 · 03 §14-b v1.6 블록 ④⑥ · 설계서 §6 규칙 30)
 build(BuildContext context, WidgetRef ref):
   final AsyncValue<ExecutionGapResult> asyncValue = ref.watch(executionGapProvider(yyyyMm));
   final List<BlockFlag> activeFlags = ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ?? const <BlockFlag>[];
   asyncValue.when(
     loading: () => ListView(padding: 16, children: [ AnalyticsSkeleton() ]),                                     ← 배너 없음
     error:   (error, stack) => ListView(padding: 16, children: [ AnalyticsErrorView(onRetry: …invalidate…, lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ]),   ← 배너 없음
     data:    (result) => 아래 배치)
 배치(값이 온 뒤 · 위 → 아래):
   Column(key: const Key('s710-root'))[                                                ← 두 갈래 공통 루트(yyyyMm 은 Key·표시 어디에도 쓰지 않는다)
    1 StaleBanner(asOf: result.asOf)                                                  ← 스크롤 밖
    2 SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (String link) { ref.read(analyticsLinkOpenerProvider).open(link); })   ← 스크롤 밖(표식 줄·차단 줄 = 위젯 그대로 · flagId 로 거르지 않는다)
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    ── 리포트 갈래: final ExecutionGapReport? report = result.report; 가 null 아님 ──
    3 Text(report.periodLabel)
    4 TrustBadgeView(trust: report.trust, onOpenLink: (String link) { ref.read(analyticsLinkOpenerProvider).open(link); })
    5 (normalized != null) 게이지(아래 모양 · Key s710-gauge)              ← final double? normalized = report.complianceRateNormalized;
    6 Text(report.complianceRateLabel)                                       ← 게이지가 없어도 늘
    7 for (final (int i, String line) in report.countLines.indexed) Text(line, key: ValueKey<String>('s710-count-$i'))
    8 Text(report.medianDelayLabel)
    9 Text(report.priceGapLabel)
   10 for (final (int i, String line) in report.correctionLines.indexed) Text(line, key: ValueKey<String>('s710-correction-$i'))   ← 빈 목록 = 줄 0(절 부재 · if 를 두지 않는다)
   11 Text(report.amendChainMaxLabel)                                        ← 늘(교정 줄이 없어도)
   12 (report.skipReasonBuckets.isNotEmpty) Text(AnalyticsLabels.executionGapSkipReasonsHeader) +
        Wrap(spacing: 6, runSpacing: 4)[ for (final ReasonChip chip in report.skipReasonBuckets) Chip(label: Text(chip.label), backgroundColor: _toneColor(colorScheme, chip.tone)) ]
   13 (report.selectiveExecutionChips.isNotEmpty) Wrap(spacing: 6, runSpacing: 4)[ 같은 Chip — 머리 없음 ]
   14 (report.modeAdviceLine != null) Text(report.modeAdviceLine!, key: const Key('s710-advice'))   ← 말미 1줄 · 버튼·링크·아이콘 0
    ── 빈·해당없음 갈래: report 가 null ──
    3' Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(result.emptyLabel!, key: const Key('s710-empty'))))   ← 문장 카드 하나 — 3~14 전부 부재
    ── 두 갈래 공통 ──
   15 Text(result.asOf.label, key: const Key('s710-asof'))                   ← 맨 아래(골든 위치 전제의 기준)
   ]
 게이지 모양(글자 그대로 — 테스트 T710-07 이 이 모양에 맞물린다):
   SizedBox(
     key: const Key('s710-gauge'),
     height: 8,
     child: ColoredBox(
       color: colorScheme.surfaceContainerHighest,
       child: FractionallySizedBox(
         alignment: Alignment.centerLeft,
         widthFactor: normalized.clamp(0.0, 1.0),
         child: ColoredBox(color: colorScheme.primary),
       ),
     ),
   )
 칩 색(ChipTone 4갈래 · 전수 switch 식 · 이 화면 파일 안 private 함수 — R11a 플래너와 같은 갈래 · planner 를 import 하지 않고 이 글자대로 쓴다):
   Color _toneColor(ColorScheme scheme, ChipTone tone) => switch (tone) {
     ChipTone.neutral => scheme.surfaceContainerHighest,
     ChipTone.caution => scheme.errorContainer,
     ChipTone.blocked => scheme.error,
     ChipTone.prevented => scheme.surfaceContainerHighest,
   };
 🔴 상태를 고르는 것은 result.report(null 여부) · complianceRateNormalized(null 여부) · modeAdviceLine(null 여부) · skipReasonBuckets·selectiveExecutionChips(빈 여부) · 칩 tone(색) 뿐이다.
    emptyKind · int · 문장 글자(포함·비교)로 고르지 않는다. correctionLines·countLines 는 루프라 빈 목록이면 줄이 저절로 0 이다.
 🔴 이행률·건수·지연·갭·교정·제안·빈 문장·배지 글자는 전부 엔진 문장 그대로 — 화면이 짓거나 고르지 않는다(«못 함/안 함»·«건»·«%» 같은 정적 글자 금지).
 🔴 TrustBadgeView 는 import 해 쓰기만 한다(고치지 않는다 · 위젯 안쪽의 Colors·level 은 widgets 몫 · C-42 대상 밖).
 간격(SizedBox 높이)·글자 굵기·크기·Card 모서리·Padding 은 재량(질문 아님) — 단 소수부 ≠ 0 소수 리터럴 0(정수 또는 N.0).

■ Key 표 (S7-10 Key 7개 — 정본 = 이 표의 글자 · 출처 표시 = 설계서 §6 규칙 17(열지 않는다) · 🔴 여기 없는 s710- Key 를 더하지 않는다)
   루트          Key('s710-root')                          값이 온 뒤의 Column(두 갈래 공통)
   게이지        Key('s710-gauge')                         게이지 SizedBox — normalized 있을 때만
   건수 줄       ValueKey<String>('s710-count-$i')          Text(countLines[i]) — i = .indexed 의 자리
   교정 줄       ValueKey<String>('s710-correction-$i')     Text(correctionLines[i]) — 빈 목록이면 0
   제안 줄       Key('s710-advice')                        Text(modeAdviceLine!) — 있을 때만
   빈 문장       Key('s710-empty')                         Text(result.emptyLabel!) — report 없을 때만(Card 안의 그 Text 에)
   기준일        Key('s710-asof')                          Text(result.asOf.label) — 맨 아래
   (periodLabel · complianceRateLabel · medianDelayLabel · priceGapLabel · amendChainMaxLabel · 머리글 · 칩 · TrustBadgeView 에는 Key 를 달지 않는다 — 테스트는 find.text · find.byType 로 찾는다)

■ 할 일 — 이 순서로, 단계마다 커밋 · 테스트는 그 단계 커밋에 함께 · 🔴 커밋 순서·제목은 이대로(각 단계 끝 «커밋 «…»» 글자 그대로 · 5개)
 (1) 정적 라벨 1개(labels.dart 끝 R12d 절 · 기존 화면·위젯 무변경 — 0단계의 시작 기준 N 이 그대로 통과). 커밋 «[M7] R12d (1) 정적 라벨»
 (2) 주입·결과 프로바이더(analytics_providers.dart 끝 R12d 절 · 커밋 전에 dart format) + test/execution_gap_fakes.dart(FakeExecutionGapRepository · executionGapOverrides 둘만 — pumpExecutionGap 은 아직 없다) +
     test/execution_gap_view_test.dart(T710-17 하나로 시작 · import 는 dart:io · package:flutter_test/flutter_test.dart 둘만 — 나머지 import 는 (3) 에서 쓰기 시작할 때 더한다).
     🔴 ExecutionGapScreen 은 (3) 에서 생긴다 — (2) 의 어느 파일도 그 이름을 쓰지 않는다(쓰면 (2) 커밋의 analyze 가 실패한다) · fakes 의 import 도 (2) 에서 실제로 쓰는 것만.
     (2) 커밋에서 flutter test 통과 = 시작 기준 N + 1. 커밋 «[M7] R12d (2) 주입 — executionGapRepositoryProvider · executionGapProvider · T710-17»
 (3) ExecutionGapScreen(lib/src/screens/execution_gap_screen.dart) + 배럴 export 한 줄(정렬 자리) + test/execution_gap_fakes.dart 에 pumpExecutionGap(과 그것이 쓰는 import) +
     test/execution_gap_view_test.dart 에 T710-01~T710-16 · T710-18(import 는 아래 «import 순서» 최종형).
     🔴 이 커밋 전에 packages/ui_analytics 에서 «정적 묶음» 37줄을 한 번 미리 돌려 본다 — 🔴 git grep 은 add 하지 않은 새 파일을 보지 않는다(출력 없음 = 거짓 안심) →
        먼저 git add . (packages/ui_analytics 안에서 · 커밋은 그다음)로 올린 뒤 돌린다: S04 = 출력 없음 · S05 = 2줄 · S13 = 옛 4파일뿐 · S15 = 9줄 · S16b = 13줄 · S33 = 7줄 · S03·S06~S12·S14·S16·S20·S24~S26·S28~S30 = 출력 없음(주석도 센다 — 이 카드 규칙 17). (5) 뒤에는 커밋을 더할 수 없으니(amend·rebase 금지) 여기서 고친다. 커밋 «[M7] R12d (3) S7-10 이행 리포트 화면 + 테스트»
 (4) 골든 12장 — test/golden/s710_golden_test.dart. 커밋 «[M7] R12d (4) 골든 s710_* 12장»
 (5) melos.bat run format:fix · 질문 파일(S7-10_questions.md — 골든 dy 측정 행 A1~A6 · 그 밖의 질문) · 커밋 «[M7] R12d (5) format · 질문».
     🔴 (5) 뒤에 다른 커밋을 더하지 않는다(제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지).

■ 정적 라벨 — AnalyticsLabels 끝에(파일의 마지막 절 = R12b 절 뒤 · R12c 는 라벨 0) 절 주석(// ── 🆕 R12d — S7-10 ──)과 함께 1개(이름·글자 고정):
   executionGapSkipReasonsHeader = '미이행 사유 분포'   (03 §14-b 「컴포넌트」 의 그 자리 이름 글자 그대로 · skipReasonBuckets 가 있을 때만 그 칩들 위에)
   (retryButton · staleBannerTitle · actionViewButton 은 이미 있다 — 고치지 않는다. R10b~R12c 의 라벨 절도 고치지 않는다.)
   🔴 만들지 않는 글자(엔진 몫): «안내 …건» · «이행» · «건너뜀» · «이행률» · «중앙 지연» · «안내 대비» · «bp» · «불리» · «정정 체인» · «소급 기록» · «자가 보고 정정» ·
      «못 함» · «안 함» · «자동 매매» · «이 기간에는 …» · 배지 글자 · 달 이름 · «건» · «원» · «%» · «건수»·«교정·소급»·«방향 편향» 머리(줄·칩 글자가 이미 말한다) · «연간 리뷰».
   🔴 라벨 글자에 숫자·금액을 넣지 않는다(C-38 ⑫ 가 labels.dart 도 본다). 더 필요하면 더하지 말고 질문 파일에 적는다(이 카드의 정적 라벨은 1개로 고정).

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S31·S32 와 대조 · 파일 = test/execution_gap_view_test.dart)
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 픽스처는 golden_support.dart 의 singleFixture/fixtureEnvelope 로만 읽는다 ·
  값 단언 전 pump 두 번 = pumpExecutionGap(끝에 pump 1번) 뒤 각 테스트에서 await tester.pump(); 를 한 번 더 부른 다음 단언한다(Future·안전 스트림이 도착할 틈 · T710-10 로딩은 completer 를 끝내지 않은 채 단언).
  🔴 경우가 여럿인 테스트(«…마다» · «루프로» — T710-03·04·05·06·07·08·09·12·13·14·15·18)는 for 로 testWidgets 를 경우마다 만든다
     (이름 = '<번호> <설명> <경우 이름>' · 경우 이름 = cant · wont · mixed · gap1 · masked_recon · empty · not_applicable · row0 … · 예 'T710-06 correction lines wont' · ⓡ·ⓗ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 같다). pumpExecutionGap 은 한 테스트에서 한 번만 부른다(한 테스트 안에서 픽스처를 바꿔 다시 띄우지 않는다).
     계획 = 뷰 54개(T710-01 1 · 02 1 · 03 3 · 04 7 · 05 5 · 06 5 · 07 5 · 08 4 · 09 5 · 10 1 · 11 1 · 12 2 · 13 4 · 14 2 · 15 4 · 16 1 · 17 1 · 18 2) · testWidgets 줄 18(드라이런 확인 — 경우 루프 안의 testWidgets( 는 한 줄로 센다 · test( 를 쓰지 않는다).
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순):
     import 'dart:async'; → import 'dart:io'; →
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
     import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/src/widgets/analytics_error_view.dart'; →
     import 'package:ui_analytics/src/widgets/analytics_skeleton.dart'; → import 'package:ui_analytics/src/widgets/trust_badge_view.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
     import 'execution_gap_fakes.dart'; → import 'golden/golden_support.dart';(execution_ 이 golden 보다 앞 · src/widgets 가 ui_analytics.dart 앞)
     (쓰지 않는 import 가 있으면 analyze 가 실패한다 — 실제로 쓰는 것만 · 드라이런 확인 = 이 12줄 그대로 analyze «No issues found» · (2) 커밋에서는 dart:io · flutter_test 둘만)
  🆕 test/execution_gap_fakes.dart(새 파일 · 공개 이름 · 🔴 한국어 리터럴 0 · explore_fakes.dart 는 import 만):
    import — (2) 판(7줄 · pumpExecutionGap 이 아직 없다):
      import 'dart:async'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; →
      import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
      import 'explore_fakes.dart' show FakeSafetyRepository; → import 'golden/golden_support.dart';
    import — (3) 최종판(9줄 · pumpExecutionGap 이 쓰는 flutter/material · flutter_test 둘을 정렬 자리에 더한다):
      import 'dart:async'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
      import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
      import 'explore_fakes.dart' show FakeSafetyRepository; → import 'golden/golden_support.dart';
    (FakeSafetyRepository(SafetyState state) — 위치 인자 하나 · R10b · 고치지 않는다 · FixedClock·kGoldenNowUtc·fixtureEnvelope 는 golden_support.dart 에서 · 쓰지 않는 import = analyze 실패)
    class FakeExecutionGapRepository extends UnimplementedExecutionGapRepository {
      FakeExecutionGapRepository({ExecutionGapResult? result, Object? error, Completer<ExecutionGapResult>? completer})   ← 셋 중 정확히 하나를 준다(테스트가 정한다)
      final List<String?> monthlyCalls = <String?>[];   ← 받은 yyyyMm(null 포함)을 호출마다 더한다
      monthly({String? yyyyMm}) = 기록 → completer 가 있으면 completer.future / error 가 있으면 Future<ExecutionGapResult>.error(error) / 아니면 Future<ExecutionGapResult>.value(result!)
    }   (watchRolling 은 override 하지 않는다 — 받침대가 던진다 · 화면이 부르면 테스트가 실패한다)
    List<Override> executionGapOverrides({required FakeExecutionGapRepository repo, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 4개(analyticsClockProvider · analyticsLinkOpenerProvider · executionGapRepositoryProvider · safetyRepositoryProvider(FakeSafetyRepository(…)))
        · 기본값: 안전 = safetyStates 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 오프너 = 새 RecordingLinkOpener(링크를 단언하려면 opener: 로 넘긴다)
    Future<void> pumpExecutionGap(WidgetTester tester, {required FakeExecutionGapRepository repo, String? yyyyMm, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})   ← 🔴 (3) 커밋에서 더한다(ExecutionGapScreen 이 (3) 에서 생긴다)
        ← 390×2400 · DPR 1.0 · teardown 2 · ProviderScope(overrides: executionGapOverrides(…)) → MaterialApp(home: Scaffold(body: ExecutionGapScreen(yyyyMm: yyyyMm))) · 끝에 pump() 1번
    골든은 pumpExecutionGap 을 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: executionGapOverrides(repo: …, safetyState: …), child: const ExecutionGapScreen()), brightness: b, logicalSize: kS710GoldenSize). 🔴 새 띄우기 도우미는 이 하나뿐(pumpExecutionGap) · 테스트마다 ProviderScope 를 통째로 쓰지 않는다 · 달은 픽스처의 MonthlyReport.yyyyMm 을 넘긴다(리터럴 금지).
이행 갭 — test/execution_gap_view_test.dart
 T710-01 gap1 · yyyyMm 없이 → ⓗ expect(repo.monthlyCalls, hasLength(1)) → expect(repo.monthlyCalls, <String?>[null]) · Key s710-root 1 · ⓡ.
 T710-02 gap1 · yyyyMm: m(«픽스처»의 달) → ⓗ expect(repo.monthlyCalls, hasLength(1)) → expect(repo.monthlyCalls, <String?>[m]) · find.text(m) 0(달 글자 표시 0) · s710-root 1 · ⓡ.
 T710-03 배치 사슬 — 세 경우 (wont · 정상 시계 · 안전 행 0) · (mixed · +3일 · 행 3) · (masked_recon · 정상 · 행 1)마다:
        위 → 아래 Finder 목록을 만들고(있는 것만 넣는다) 이웃끼리 tester.getTopLeft(…).dy 를 lessThan 으로 잇는다(각 Finder 는 findsOneWidget 도):
        [오래됐으면 find.text(AnalyticsLabels.staleBannerTitle)] → [플래그가 있으면 find.text(activeFlags.first.label)] → find.text(report.periodLabel) → find.text(report.trust.label) →
        [normalized 가 있으면 find.byKey(const Key('s710-gauge'))] → find.text(report.complianceRateLabel) → s710-count-0 … s710-count-2 → find.text(report.medianDelayLabel) → find.text(report.priceGapLabel) →
        [교정 줄마다 s710-correction-<i>] → find.text(report.amendChainMaxLabel) →
        [skip 칩이 있으면 find.text(AnalyticsLabels.executionGapSkipReasonsHeader) → find.widgetWithText(Chip, skipReasonBuckets.first.label)] →
        [방향 편향 칩이 있으면 find.widgetWithText(Chip, selectiveExecutionChips.first.label)] → [modeAdviceLine 이 있으면 s710-advice] → s710-asof.
        없는 쪽은 else 로 따로 단언한다(staleBannerTitle 0 · find.byIcon(Icons.block) 0 · s710-gauge 0 · s710-correction-0 0 · 머리글 0 ·
        find.byType(Chip) findsNWidgets(skipReasonBuckets.length)(방향 편향 칩이 없을 때) · s710-advice 0). 세 경우가 일곱 조건의 양쪽을 한 번 이상씩 지난다. ⓡ.
 T710-04 결과 갈래 — 일곱 픽스처(cant · wont · mixed · gap1 · masked_recon · empty · not_applicable)마다: result.report 가 있으면 find.byType(TrustBadgeView) 1 · find.text(report.periodLabel) 1 · s710-empty 0 /
        없으면 s710-empty 1 · tester.widget<Text>(s710-empty).data == result.emptyLabel · find.byType(TrustBadgeView) 0 · s710-count-0 0 · s710-gauge 0 · s710-advice 0 · find.byType(Chip) 0 ·
        find.byType(Card) 1 · tester.getTopLeft(s710-empty).dy < tester.getTopLeft(s710-asof).dy(빈 갈래에서 — empty · not_applicable 둘 다 · 리포트 갈래에는 s710-empty 가 없어 이 비교를 두지 않는다) ·
        공통 s710-asof 1 · tester.widget<Text>(s710-asof).data == result.asOf.label · ⓡ.
 T710-05 건수 줄 — cant · wont · mixed · gap1 · masked_recon 마다 ⓗ expect(report.countLines, hasLength(3)) → i 마다 tester.widget<Text>(find.byKey(ValueKey<String>('s710-count-$i'))).data == countLines[i] ·
        이웃 행 dy 엄격 증가(받은 순서) · s710-count-3 0 · ⓡ.
 T710-06 교정 줄 — 같은 다섯 픽스처마다 ⓗ expect(report.correctionLines, hasLength(<cant 2 · wont 0 · mixed 2 · gap1 0 · masked_recon 2>)) → i 마다 Text data == correctionLines[i] ·
        이웃 dy 엄격 증가 · s710-correction-<길이> 0(길이 0 이면 s710-correction-0 0 — 빈 목록 = 절 부재) · find.text(report.amendChainMaxLabel) 1(늘) · ⓡ.
 T710-07 게이지 — 같은 다섯 픽스처마다: report.complianceRateNormalized 가 있으면 s710-gauge 1 · 채운 막대 = find.descendant(of: find.byKey(const Key('s710-gauge')), matching: find.byType(ColoredBox)).last ·
        tester.getSize(채운 막대).width / tester.getSize(find.byKey(const Key('s710-gauge'))).width 가 closeTo(normalized, 0.01) ·
        tester.widget<ColoredBox>(채운 막대).color == Theme.of(tester.element(find.byKey(const Key('s710-gauge')))).colorScheme.primary(C4b-13) /
        없으면(masked_recon) s710-gauge 0 · find.byType(FractionallySizedBox) 0(Key 없는 막대도 0 — 이 화면에서 FractionallySizedBox 는 게이지에만 있다)(양쪽 다) ·
        공통 find.text(report.complianceRateLabel) 1 · ⓡ.
 T710-08 제안 줄 — cant · wont · mixed · gap1 마다: modeAdviceLine 이 있으면 s710-advice 1 · tester.widget<Text>(s710-advice).data == modeAdviceLine ·
        다른 갈래의 문장(cant 면 wont 픽스처의 modeAdviceLine · wont 면 cant 의 것) 글자 0 ·
        expect(find.ancestor(of: find.byKey(const Key('s710-advice')), matching: find.byWidgetPredicate((Widget w) => w is ButtonStyleButton || w is InkWell)), findsNothing)(버튼·링크 0) /
        없으면(mixed · gap1) s710-advice 0(양쪽 다) · ⓡ.
 T710-09 칩 — cant · wont · mixed · gap1 · masked_recon 마다: tester.widgetList<Chip>(find.byType(Chip)).map((Chip c) => (c.label as Text).data).toList() ==
        [skipReasonBuckets 의 label 들, 그다음 selectiveExecutionChips 의 label 들](순서까지 · 목록 == 목록) · skip 칩이 있으면 머리글 1 / 없으면 0(양쪽 다) · find.byType(ActionChip) 0 · ⓡ.
 T710-10 로딩 — completer 가짜 · 안전 행 3 → AnalyticsSkeleton 1 · find.byType(CircularProgressIndicator) 0 · find.byType(LinearProgressIndicator) 0 · s710-root 0 ·
        그 플래그 label 글자 각 0(🔴 로딩에는 배너 없음 — 규칙 8) · ⓡ.
 T710-11 에러 — error 가짜 · yyyyMm: m · 안전 행 3 → retryButton 1 · expect(find.byType(AnalyticsSkeleton), findsNothing) · tester.widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView)).lastAsOfLabel == null ·
        그 플래그 label 글자 각 0 · s710-root 0 → retryButton 탭 → pump → ⓗ expect(repo.monthlyCalls, hasLength(2)) → expect(repo.monthlyCalls, <String?>[m, m]).
 T710-12 오래됨 — cant · 시계 두 경우(kGoldenNowUtc · +3일)를 루프로: 오래됐으면 find.text(AnalyticsLabels.staleBannerTitle) 1 ·
        find.ancestor(of: find.text(AnalyticsLabels.staleBannerTitle), matching: find.byType(Scrollable)) 0(C4b-12) / 아니면 staleBannerTitle 0(양쪽 다) · ⓡ.
 T710-13 안전 — cant · 안전 행 0·1·3·4 마다(경우마다 testWidgets): ⓗ expect(activeFlags, hasLength(<0 · 1 · 2 · 1>)) → 플래그마다 그 label 글자 1 ·
        find.ancestor(of: find.text(그 label), matching: find.byType(Scrollable)) 0(C4b-12) ·
        find.byIcon(Icons.block) — 차단 줄이 없으면(행 0 · 행 1 = 표식만) findsNothing / 있으면 findsNWidgets(<행 3 = 2 · 행 4 = 1>)(양쪽 다) ·
        탭 — 행 4 만 find.byIcon(Icons.chevron_right) 탭 → pump → opener.opened == <String>[행 4 의 activeFlags.single.clearDeepLink!] /
        행 0·1·3 은 탭하지 않고 expect(opener.opened, isEmpty)(양쪽 다) · ⓡ.
 T710-14 신뢰 배지 — mixed · cant 마다: find.text(report.trust.label) 1 · trust.actionDeepLink 가 있으면(mixed) find.text(AnalyticsLabels.actionViewButton) 1 → 탭 → pump →
        opener.opened == <String>[report.trust.actionDeepLink!] / 없으면(cant) actionViewButton 0 · opener.opened isEmpty(양쪽 다) · ⓡ.
 T710-15 화면 글자 — cant · mixed · masked_recon · empty 마다(안전 행 0 · 정상 시계 = 도우미 기본값 — 배너 글자 0): 화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있다 —
        집합 = result.asOf.label + (리포트면) periodLabel · complianceRateLabel · countLines · medianDelayLabel · priceGapLabel · correctionLines · amendChainMaxLabel · modeAdviceLine(있으면) ·
        두 칩 목록의 label · trust.label · trust.consequenceLine · trust.upgradeHint(있으면) + (빈이면) emptyLabel + AnalyticsLabels.executionGapSkipReasonsHeader · actionViewButton
        (화면이 지은 글자 = 0 · 🔴 집합은 null-aware 원소(?x · ...?xs)로 만든다 — if 0 · 규칙 11) · 그리고 그 data 어느 것도 금액 정규식 RegExp(r'[0-9][0-9,.]*\s*(\uC5B5\uC6D0|\uB9CC\uC6D0|\uC6D0)|\u20A9') 와
        금지어 정규식 RegExp(r'\uCD94\uCC9C|\uAD8C\uC720|\uC790\uBB38|\uC2DC\uADF8\uB110') 에 걸리지 않는다 (🔴 한국어는 \u 이스케이프로만 — 테스트 파일 한국어 리터럴 0 · 정적 S01 · 03 §14-b 「수용」 (a) 금액 리터럴 0 · C-42 ⑦ 과 짝) · ⓡ.
 T710-16 배럴 — File('lib/ui_analytics.dart') 의 export 경로 목록(RegExp(r"^export '([^']+)';", multiLine: true)) ⓗ hasLength(13) · 집합이 정확히
        { l10n/labels.dart · src/providers/analytics_providers.dart · src/screens/annual_review_screen.dart · src/screens/contribution_screen.dart · src/screens/drawdown_context_screen.dart ·
          src/screens/execution_gap_screen.dart · src/screens/goal_path_screen.dart · src/screens/monthly_report_screen.dart · src/screens/performance_explore_screen.dart ·
          src/screens/rebalance_event_screen.dart · src/screens/rebalance_preview_screen.dart · src/screens/rebalance_timeline_screen.dart · src/screens/report_archive_screen.dart }
        (🔵 «정확히 N» — R12 에서 이 카드만(설계서 §6 규칙 33) · T79-14(goal_path_view_test)·G13(performance_explore_gate_test)은 고치지 않는다).
 T710-17 autoDispose — File('lib/src/providers/analytics_providers.dart') 를 줄로 나눠 'autoDispose'(대소문자 구분 — AutoDispose 타입 이름은 안 센다)를 품은 줄 목록 ⓗ hasLength(9)
        (기존 4 + R12a 2 + R12b 1 + R12c 1 + 이 카드 1 · 🔵 «정확히 N» — 정적 S15 와 같은 수 · 누적 드라이런 확정 9) · testWidgets 로 쓴다(T79-14 선례 · test( 금지 — S02c 18 의 일부).
 (T710-16 도 같다 — testWidgets 로 쓴다 · test( 금지.)
 T710-18 큰 글꼴 — cant · masked_recon 마다: 띄우기 전에 tester.platformDispatcher.textScaleFactorTestValue = 2.0 + addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue) →
        pumpExecutionGap → expect(tester.takeException(), isNull) · s710-root 1 · ⓡ.   (드라이런 확인 — 두 경우 통과 · 칩 넘침 없음)
 (T710 에 없는 번호는 없다 — 01~18.)
 ⓡ 기대 = execution_gap_view_test.dart 15줄(T710-01·02·03·04·05·06·07·08·09·10·12·13·14·15·18) · ⓗ 기대 = 8줄(T710-01·02·05·06·11·13·16·17)(드라이런 확인 — S31 15 · S32 8) ·
   🔴 정확히 이 수(다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 — 규칙 11).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 제안 줄 늘 그리기(null 에 빈 Text) · 제안 줄을 TextButton 으로 · cant·wont 제안 문장을 다른 필드 글자로 ·
   게이지를 null 에 폭 0 으로 그리기(Key s710-gauge 를 단 채 · 또는 Key 없이 FractionallySizedBox 로) · 게이지 폭 고정(widthFactor 1.0) · 채운 막대 색 tertiary · 이행률 글자를 게이지가 있을 때만 · countLines 역순 · countLines 마지막 줄 빼기 ·
   교정 줄과 건수 줄 Key 맞바꿈(글자 그대로 Key 만) · 교정 줄이 없으면 정정 체인 줄 빼기 · 칩 순서 바꾸기(방향 편향을 사유 앞) · 사유 칩이 없어도 머리글 그리기 ·
   빈·해당없음 갈래에 TrustBadgeView · 빈 문장 대신 정적 글자 · 리포트·빈 갈래 뒤바꾸기 · 빈 갈래에서 기준일 빼기 · 로딩·에러에 차단 배너 · 에러를 스켈레톤으로 · 로딩에 스피너 ·
   monthly 에 null 대신 다른 값(또는 받은 달 대신 null) · yyyyMm 을 글자로 그리기 · 차단 배너를 ListView 안으로(C4b-12 · X11) · StaleBanner 를 ListView 안으로 · 배너 링크를 열지 않기 ·
   신뢰 배지 onOpenLink 빼기 · 화면이 지은 글자 하나(예 정적 «이행 리포트») · 배럴 export 하나 더(내부 폴더) · providers 에 autoDispose 줄 하나 더.

■ 정적 묶음 — packages/ui_analytics 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 37줄을 돌려 글자로 대조한다 — 다르면 거짓 주장 = 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 2>&1 로 모으면 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힐 수 있다 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/execution_gap_view_test.dart test/execution_gap_fakes.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/execution_gap_view_test.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/execution_gap_view_test.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S02c testWidgets lines"; git grep -c "testWidgets(" -- test/execution_gap_view_test.dart test/golden/s710_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (S7-10 file)"; git grep -nP "(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes 0 (S7-10 file)"; git grep -n "AppRoutes" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 number formatting 0"; git grep -nE "toStringAsFixed|toStringAsPrecision|NumberFormat" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 S7-10 forbidden windows and types 0"; git grep -nE "watchGrade|watchRolling|LedgerTrustRepository|Decimal|Money|KrwAmount|operatingMode|OperatingMode|RunMode|runMode|FeatureFlags" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S15 autoDispose 9"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "execution_gap/|annual_review/|rebalance/|goal_path/|chart/|explore/|widgets/|planner|perf_chart" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports 13"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint" -- lib; echo "EXIT:$?"
echo "## S25 raw fields 0 (S7-10 file)"; git grep -nP "(?<!Labels)\.(issued|filled|partial|skipped|lapsed|revoked|lateFilled|backdatedCount|selfReportCorrectionCount|range|grade|level|lastVerifiedOn|actionDeepLink|detailDeepLink|emptyKind|code|kind|mode|wire|hasMore)\b" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea SnackBar 0 (S7-10 file)"; git grep -nE "Scaffold|AppBar|SafeArea|SnackBar" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 decimal and percent literals 0 (S7-10 file)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S29 elevation 0 (S7-10 file)"; git grep -n "elevation" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S30 sort filter words 0 (S7-10 file)"; git grep -nP "(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|\breverse:\s*true" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
echo "## S31 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/execution_gap_view_test.dart; echo "EXIT:$?"
echo "## S32 H lines (hasLength)"; git grep -c "hasLength(" -- test/execution_gap_view_test.dart; echo "EXIT:$?"
echo "## S33 s710 keys (7 names)"; git grep -noP "s710-[a-z]+" -- lib/src/screens/execution_gap_screen.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름·문자열 리터럴은 ASCII 만(«—»·«→» 도 금지 · S02b 는 접힌 줄의 reason: 글자도 잡는다 — 규칙 11) · S02c = «test/execution_gap_view_test.dart:18» · «test/golden/s710_golden_test.dart:1»(드라이런 확인) ·
   S03 = 엔진 글자 가공 0 · S04 = 출력 없음(이 카드가 쓰는 AppRoutes 0 · import 도 show 없이라 이름이 안 찍힌다) ·
   S05 = 탭 콜백 안 2줄(SafetyBlockBanner onOpenLink · TrustBadgeView onOpenLink · 줄 번호는 짓는 모양마다 다르다 — 드라이런은 66 · 111) — build 본문에서 읽는 줄 0 ·
   S06~S12 = lib 전체 0(R12a~c 포함 — 앞 카드 병합본에서 이미 0) · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0(누적 드라이런 확인) ·
   S14 = S7-10 파일에 롤링·등급 창구·금액 타입·운영 모드 0 · S15 = 대소문자 구분 · 9줄(기존 4 + R12a 2 + R12b 1 + R12c 1 + executionGapProvider 1 · 마지막 줄 = executionGapProvider 의 «executionGapProvider = FutureProvider.autoDispose» · 줄 번호는 병합본마다 다를 수 있다 — 9줄이 기준) · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = export 13줄(execution_gap_screen 은 drawdown_context_screen 과 goal_path_screen 사이) ·
   S17·S18·S18b = 차트 본보기와 lib 차트 차이 0(이 카드는 차트를 건드리지 않는다) · S19~S23 = 12항의 1·3·11항 근거(S22·S23 = 11항 보강 — 계약 테스트 C-38 ⑫ 와 같은 정규식) ·
   S24 = 폐기·금지 이름 0 · S25 = C-42 ②③ 의 S7-10 원값 점 접근 0(+ actionDeepLink·detailDeepLink — 화면 파일은 링크 필드를 읽지 않는다) ·
   S26 = 공개 위젯은 본문만(ScaffoldMessenger 도 «Scaffold» 로 걸린다) ·
   S27 = 공용 파일의 «더하기만» — 세 파일 모두 둘째 수(삭제)가 0 · 첫째 수 = labels 3(빈 줄 · 절 주석 · 라벨 1) · providers 16(위 «주입 구조» 의 절 그대로 · 빈 줄 포함) · 배럴 1(드라이런 확인 — 다르면 절 모양이 카드와 다른 것) ·
   S28 = C-42 ⑥(소수부 ≠ 0 소수 · % 문자열) 0 · S29 = Card() 기본 고도 · S30 = C-42 ⑨ 정렬·거르기 0 ·
   S31·S32 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 정확히 같아야 한다(15 · 8 · 다르면 반려 — 규칙 11) ·
   S33 = s710-root · s710-gauge · s710-count · s710-correction · s710-advice · s710-empty · s710-asof 7줄(각 1번 · Key 표 밖의 s710- 0 · 줄 번호와 줄 순서는 private 메서드 배치에 따라 다르다 — 이름 7개가 각 1번이면 된다))

■ 골든 — 6이름 × light/dark = 12장(전부 신규 · 설계서 §3-5 R12d 행 · golden README «🆕 R12» 절 표의 R12d 행 그대로)
  s710_cant(m7/execution_gap_cant.json · 안전 행 0) · s710_wont(m7/execution_gap_wont.json · 행 0) · s710_mixed(m7/execution_gap_mixed.json · 행 0 · 제안 줄 부재) ·
  s710_empty(m7/execution_gap_empty.json · 행 0 · 문장 카드 하나) · s710_not_applicable(m7/execution_gap_not_applicable.json · 행 0 · 문장 카드 하나) ·
  s710_masked_recon(m7/execution_gap_masked_recon.json · 🔴 안전 행 3 — 배너 + «?» 글자 · 게이지 부재)
  모두 const ExecutionGapScreen()(yyyyMm 없이) · 시계 = FixedClock(kGoldenNowUtc) · 크기 = 테스트 파일 안 상수 kS710GoldenSize = Size(390, 844)(드라이런 확정 — 여섯 이름 모두 기준일이 844 안 · 이 값을 바꾸지 않는다) (kGoldenPhoneSize 는 M2 소유 — 바꾸지 않는다).
  모양 = s79_golden_test.dart 처럼 (이름, 픽스처 경로, 안전 행) 목록 × Brightness.values 루프 · 테스트 이름 '$name ${brightnessSuffix(b)}' · 골든은 '../execution_gap_fakes.dart' 로 import.
  골든 파일 import(directives_ordering · s79_golden_test.dart 꼴 · 7줄):
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
     import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/ui_analytics.dart'; → import '../execution_gap_fakes.dart'; → import 'golden_support.dart';
  pumpForGolden(tester, ProviderScope(overrides: executionGapOverrides(repo: FakeExecutionGapRepository(result: result), safetyState: SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[<행>])),
    child: const ExecutionGapScreen()), brightness: b, logicalSize: kS710GoldenSize) → await tester.pumpAndSettle() → 찍기 전 위치 전제(golden README «R10» 절 «2. 높이와 위치 전제») — 한 곳:
    expect(tester.getBottomLeft(find.byKey(const Key('s710-asof'))).dy, lessThan(kS710GoldenSize.height));   ← 맨 아래 = 기준일(빈 갈래도 같다)
  → await expectGolden(name, b);
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s710_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 12장만 ??
  🔴 다른 골든 테스트 파일을 --update-goldens 에 넣지 않는다(폴더 지정 금지).
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s710_golden_test.dart 의 위치 전제 lessThan(kS710GoldenSize.height) 한 곳을 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/s710_golden_test.dart(--update-goldens 없이)
    → 테스트 이름('s710_cant light' … 12개)마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- test/golden/s710_golden_test.dart 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · K21 = 카드마다 1개)
· S7-10_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 이 카드의 질문은 전부 여기에(다른 질문 파일을 고치지 않는다 — S7-1_questions.md 포함).
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A6 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  권고와 다르게 지은 이름 · 1개 밖에 더 필요했던 정적 라벨(더하지 않고 질문으로) · 문서에 없어 정한 것 전부.
    | A1 | R12d-Bob-S710 | 추측 | 측정: s710_cant dy 실측값 (light=<값>, dark=<값> < <높이>) | 골든 위치 전제 실측 | <높이> 미만 확인 | ⬜ 미답 | |
    (A2 = s710_wont · A3 = s710_mixed · A4 = s710_empty · A5 = s710_not_applicable · A6 = s710_masked_recon · 같은 형식 · <높이> = kS710GoldenSize 의 높이 숫자 · <값> 자리에만 잰 숫자)
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 1개 · 읽지 않는 필드 목록(규칙 5) · 게이지 모양·색 · 칩 색 갈래 · 정정 체인 줄을 늘 그리는 것 ·
  하단·배너가 result.asOf 하나인 것 · 배치 순서 · 골든 이름·입력·안전 행 · 재량인 것(여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(5) 커밋이 끝난 뒤 — (5) 가 마지막 커밋)
  cd packages/ui_analytics
  flutter test test/execution_gap_view_test.dart        ← 끝 줄을 그대로 적어 둔다(기대 «+54: All tests passed!»(드라이런 확인) · 손으로 세지 않는다)
  flutter test test/golden/s710_golden_test.dart        ← 끝 줄을 그대로 적어 둔다(기대 «+12: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄을 그대로 적어 둔다 · 기대 = 시작 기준 N + 66)
  cd ../domain_contracts
  dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded   ← 전부 통과 · 출력에서 «C-42 ① 대상» 으로 시작하는 줄과 그 바로 아래 들여쓴(공백 4칸) 경로 줄 전부 +
     «C-42 ① 역할 대상 합» 줄을 그대로 적어 둔다(진행 표시 줄 «00:00 +0: …» 은 빼고 · 줄을 고르지 않는다)
     (기대 11줄(드라이런 확인): 역할 5줄(S7-6a(R12a) · S7-6b(R12a) · S7-6c(R12b) · S7-7(R12c) · S7-10(R12d) 각 «1파일») + 그 아래 경로 줄 5 +
      «C-42 ① 대상 S7-10(R12d) 1파일 — lib/src/screens/execution_gap_screen.dart + lib/src/execution_gap/**» 아래 «    lib/src/screens/execution_gap_screen.dart» ·
      마지막 줄 «C-42 ① 역할 대상 합 5파일 · providers R12 절 61줄» — 앞 카드 병합본의 파일 수·절 줄 수가 다르면 그 수가 다를 수 있다 · 출력 그대로 적는다)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 수정은 CI 포맷 게이트를 빨갛게 만든다
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만): A lib/src/screens/execution_gap_screen.dart · M lib/l10n/labels.dart · M lib/src/providers/analytics_providers.dart · M lib/ui_analytics.dart ·
        A test/execution_gap_fakes.dart · A test/execution_gap_view_test.dart · A test/golden/s710_golden_test.dart · A test/golden/goldens/s710_*.png 12장 · M docs/ai-context/inbox/S7-10_questions.md
        (경로 앞머리 packages/ui_analytics/ 가 붙어 찍힌다) · 그 밖의 줄(M PNG · 기존 lib · 기존 테스트 · 하네스 · README · domain_contracts/** · 다른 질문 파일) = 금지 —
        하나라도 있으면 푸시하지 말고 멈춘 뒤 출력을 채팅으로
  git push -u origin ui/m7-s710-gap
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  git log --oneline origin/main..HEAD         ← 아래 ① 에 그대로 붙일 출력(5줄 · 맨 위 = (5))
  cd packages/ui_analytics → 위 «정적 묶음» 37줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  12항 줄 수 — 아래 ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일에 저장(예 PowerShell 에서 메모장으로 $env:TEMP\r12d_box2.txt)한 뒤
     PowerShell: (Get-Content $env:TEMP\r12d_box2.txt).Count      또는 Git Bash: grep -c "" "$TEMP/r12d_box2.txt"
     ← 출력 그대로(기대 15 · 다르면 줄을 이었거나 나눈 것 — 고친 뒤 다시 센다 · 이 파일은 커밋하지 않는다)
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M7] S7-10 안내 이행 리포트
  PR 본문 5섹션을 채팅으로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로 쓰고 그 아래에 내용을 둔다(통합 담당이 이 글을 PR 본문으로 통째로 옮긴다 · GitHub 에서 직접 고치지 않는다):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄 — 각 섹션 맨 위에 한 줄씩)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      (이 다섯 줄은 R12 네 장(R12a~R12d)이 같은 글자다 — 무엇을 어느 섹션에 붙이는지는 아래 ①~⑤ 설명이 정한다)
   ① 아래 «① 머리 복사 상자» 두 줄 그대로 + «바뀐 파일:» + 위 git diff --name-status origin/main...HEAD 출력 그대로(코드 블록 하나 · 손으로 쓰지 않음 · A/M · PNG 포함) +
      «커밋 목록:» + 위 git log --oneline origin/main..HEAD 출력 그대로(코드 블록 하나 · 맨 위 = (5))
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: S7-10 — 안내 이행 리포트(ExecutionGapScreen({String? yyyyMm}))
R12 «정확히 N» 소유: 배럴 export 13(T710-16) · autoDispose 9(T710-17)
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 12항이 15줄 그대로인지 «12항 줄 수» 명령의 출력으로 확인한다 — 11번·12번은 각각 3줄·2줄(들여쓰기 4칸 줄 포함)이고, 한 줄로 잇지 않는다.
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음 결과의 수):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «S7-10 화면 파일 산술 0 · 게이지 폭 = complianceRateNormalized 정규값 clamp 하나(T710-07) · 건수·교정 = 엔진 줄 글자(T710-05·06)»
        3번 = «정적 묶음 S20 — 0건»
        4번 · 5번 · 6번 · 8번 = «이 카드 범위 밖»
        7번 = «앞절 이 카드 범위 밖(S7-10 에 시계열 없음) / 뒷절 가림 = 엔진 «?» 글자 그대로 · 게이지 부재(T710-07 masked_recon) · 배지 0»
        9번 = «as-of 는 이행 리포트 화면에 1줄(s710-asof · T710-04) · 오래됨 배너 = StaleBanner(T710-12)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 기존 PNG M 0 · 새 PNG = s710_* 12장 · domain_contracts 변경 0»
        11번 = «정적 묶음 S21 결과 <N>건 · 보강 S22 결과 <N>건 · S23 결과 <N>건»
        12번 = «이 카드 범위 밖(S7-10 에 세후 카드·목표 경로 가정 카드 없음)»
      ┌── 복사 시작(다음 줄부터)
 1. `ui_analytics`가 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 산술이 없는가 — 행동 갭·워터폴 잔여·밴드 이탈·페널티 금액을 내가 계산하지 않았는가 [x] ( )
 3. 사용자에게 보이는 한국어 문자열 리터럴이 없는가 (리밸런싱 트리거 배지·«미달» 경고문 포함) [x] ( )
 4. S7-2에 인터스티셜·격리 위치·열람 기록 3종이 모두 있는가 [x] ( )
 5. M8 홈·알림에 넘기는 요약과 D-7/D-1 알림 본문에 손익·금액이 없는가 [x] ( )
 6. 플래너가 M3 결과만 그리는가 / «미리보기입니다» 고지가 상시인가 / 주문 실행 버튼이 없는가 [x] ( )
 7. 결측 구간을 보간하지 않고 공백으로 두는가 / «산출 불가»에 근사 배지를 붙이지 않았는가 [x] ( )
 8. 표본 크기 고지·벤치마크 구성 문구가 뷰모델 문자열 그대로인가 [x] ( )
 9. as-of 기준일이 모든 성과 화면 상단에 상시 표기되고, 유예 초과 시 «오래된 데이터» 배너가 뜨는가 [x] ( )
10. S7-8의 게이트·개입 UI를 자체 구현하지 않았는가 / 픽스처·골든 스냅샷을 손대지 않았는가 [x] ( )
11. `ui_analytics` 소스에 세후·기대수익률·낙폭 수치가 리터럴로 없는가 —
    정규식 `\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b` 로 `lib/` 만 검사(pubspec·버전 문자열·
    `fixtures/`·테스트는 대상 제외 — 픽스처는 M2 소유) [x] ( )
12. 세후 카드에 계좌 배치 갈래가 정확히 하나만 펼쳐져 있는가 / 층을 화면에서 합치거나 빼지 않았는가 /
    목표 경로 가정 카드가 «백테스트 기준 실행»과 «현재 원금·납입» 두 줄로 갈라져 있는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M7.md 156~170행과 같습니다)
      이어서 «12항 줄 수:» + 위 «12항 줄 수» 명령의 출력 그대로 한 줄 +
      «정적 묶음 출력:» + 37줄 출력 전부를 코드 블록 하나로 그대로 +
      «S05 결과:» 다음 줄부터 S05 출력 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄씩(2줄 · 괄호·백틱·앞머리·설명·줄 끝 빈칸 없이 · 줄을 빼거나 줄이면 = 보고 불일치) +
      «ⓡ = S31 출력:» 다음 줄에 S31 출력 줄 그대로 · «ⓗ = S32 출력:» 다음 줄에 S32 출력 줄 그대로(손으로 쓰지 않는다 · test/ 를 떼지 않는다) +
      «C-42 ① 출력:» 다음 줄부터 위 dart test 의 «C-42 ①» 줄과 그 아래 들여쓴 경로 줄 전부 그대로(11줄 · 들여쓰기 그대로 — S7-10 줄만 고르지 않는다) +
      «테스트 파일별:» 다음 줄부터 위 flutter test 두 파일의 끝 줄 그대로(execution_gap_view_test · s710_golden_test 순)
   ③ 스크린샷 서술 — 로딩·정상(리포트)·빈(문장 카드)·차단 4줄 + 골든 표 12행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술은 코드의 위젯·Key 이름 나열로만 쓴다 — execution_gap_screen.dart 의 «렌더 순서» 그대로 «→» 로 잇는다
         (렌더 순서 = build 에서 시작해 private 메서드 호출(예 ..._buildReport(…))을 그 자리에 펼쳐 읽은 순서 · 파일 글자 순서가 아니다 — 메서드를 나누면 둘이 다르다) ·
         조건으로 붙는 것(StaleBanner · SafetyBlockBanner · s710-gauge · s710-correction-$i · 머리글 · 칩 · s710-advice)은 «(있을 때)» 를 붙인다 ·
         그 렌더 순서가 위 «화면» 의 배치 1~15 와 다르면 제출하지 말고 멈춘 뒤 채팅으로(빈 = 1·2 → s710-empty(Card 안) → s710-asof 와 비교) · 파일 글자 순서만 다른 것은 멈출 일이 아니다(서술에 덧붙이지도 않는다).
         «로딩» = AnalyticsSkeleton(배너 없음) ·
         «정상» = Key('s710-root') → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → Expanded(ListView) → periodLabel Text → TrustBadgeView → Key('s710-gauge')(있을 때) →
                  complianceRateLabel Text → ValueKey<String>('s710-count-$i') → medianDelayLabel Text → priceGapLabel Text → ValueKey<String>('s710-correction-$i')(있을 때) →
                  amendChainMaxLabel Text → executionGapSkipReasonsHeader Text(있을 때) → Chip(skipReasonBuckets · 있을 때) → Chip(selectiveExecutionChips · 있을 때) → Key('s710-advice')(있을 때) → Key('s710-asof') — 이 글자와 코드가 같으면 이 글자 그대로 쓴다(낱말을 바꾸거나 요약어를 더하지 않는다) ·
         «빈» = Key('s710-root') → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → Expanded(ListView) → Card → Key('s710-empty') → Key('s710-asof') ·
         «차단» = SafetyBlockBanner 의 자리를 코드 그대로 — «StaleBanner 아래 · Expanded(ListView) 바깥 위(값이 온 뒤의 Column 둘째 자식)».
      🔴 «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지(R10c 1회차 반려 사유).
      골든 표 12행: 이름 · 입력 픽스처 · 안전 행 · 크기 · 위치 전제 dy · 배치·잘림 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m7/execution_gap_cant.json — 상수 이름과 섞지 않는다) · 크기 = 390×<높이> ·
        dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다) ·
        배치·잘림 = PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 못 본 것은 «미열람»).
   ④ 질문 목록 — 새 행 번호·요지 표(질문 파일 «질문·추측» 칸 글자 그대로 · «측정:» · light=…, dark=… 포함):
      | 번호 | 요지 |
      |---|---|
      | A1 | <S7-10_questions.md 의 A1 «질문·추측» 칸 글자 그대로> |
      (A6 까지 · 그 밖의 새 행이 있으면 이어서 · 없으면 A1~A6 만)
   ⑤ 추측한 것 = S7-10_questions.md 의 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(예 A7)(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
   (+ flutter test 한 줄 — «flutter test: 시작 기준 <N> → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>»(기대 M = N + 66 · 수를 따로 계산해 덧붙이지 않는다 · 다르면 그 위 한 줄에 «까닭:» + 위 테스트 파일별 끝 줄로 설명))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s710-gap` 푸시 1건 · 커밋 5개(본문 (1)~(5) · **(5) 가 마지막** · amend·rebase·강제 푸시 0).
- `lib/` 새 파일 **1**(`screens/execution_gap_screen.dart`) · 수정 3(`l10n/labels.dart` 끝 R12d 절 라벨 1 · `providers/analytics_providers.dart` 끝 R12d 절 프로바이더 2 · `ui_analytics.dart` export 1줄(정렬 자리)) — 삭제 0(S27). 그 밖의 `lib/`(R12a~c 화면·폴더 · 위젯 · 차트 · 플래너 · 목표 경로)는 바뀌지 않는 것이 정상 · `lib/src/execution_gap/` 없음.
- `test/` 새 파일 3(`execution_gap_view_test.dart` · `execution_gap_fakes.dart` · `golden/s710_golden_test.dart`) + 새 PNG 12장(`s710_*`) · 기존 PNG M 0 · 기존 테스트·하네스·README 불변.
- 질문 파일 `S7-10_questions.md`(새 행 A1~A6 «측정:» 은 반드시 · 그 밖은 있을 때만).
- 채팅: PR 본문 5섹션(섹션 머리 ①~⑤ 글자 그대로 · ① 머리 2줄 + name-status 출력 그대로 + 커밋 목록 · ② 복사 상자 12항(15줄) + 괄호 + 12항 줄 수 출력 + «정적 묶음» 37줄 출력 전부 + S05 2줄 + ⓡ·ⓗ 출력 줄 + C-42 ① 출력 + 테스트 파일별 끝 줄 · ③ Key 나열 + 골든 표 12행(dy 는 이름·밝기마다) · ④ · ⑤) + flutter test 한 줄.
- `flutter test` = 시작 기준 N(0단계 · R12c 병합본 ⟦실측 — R12c 병합 기록 때 C4 가 채운다 · 드라이런 446 → 512 = R12b 보강 전 판 위 · 보강판 기대 447 → 513(R12b 재측정 404 근거)⟧) + 새 66(뷰 54 + 골든 12) = N + 66 기대 · 정적 S31 = 15 · S32 = 8(🔴 정확히 — 다르면 반려) · S15 = 9 · S16b = 13 · S33 = 7 · S27 = 3/0 · 16/0 · 1/0 · C-42 ① = 11줄(«S7-10(R12d) 1파일» 포함 · «역할 대상 합 5파일 · providers R12 절 61줄»).
- 재분할 임계 확인(카드 계획): 새 testWidgets 줄 19(≤ 33) · lib +214(드라이런 — 새 화면 194 · providers +16 · labels +3 · 배럴 +1 · ≤ +900) · 새 PNG 12(≤ 16) — 넘으면 C4 가 다시 나눈다(설계서 §7). 드라이런 판정 = 재분할 불필요.
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것: «제안 줄 TextButton» → T710-08 조상 단언 · «에러 + 스켈레톤» → T710-11 스켈레톤 0 · «Key 없는 FractionallySizedBox 막대» → T710-07 else(이 판 보강 · 드라이런 원판에서 통과했던 2건). Key·FractionallySizedBox 없는 맨 ColoredBox 막대는 예고 변이 밖(변이 문장을 좁혔다).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12d-Bob-S710 결과: 브랜치 ui/m7-s710-gap 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다(Claude 가 PR 을 만들고 본문을 이 글로 통째로 씁니다). Bob 이 PR 을 직접 만들었다면 `R12d-Bob-S710 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R12d-Bob-S710 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s71_*`~`s79_*` · R12a~c 의 `s76a_*`·`s76b_*`·`s76c_*`·`s77_*`)가 `M` ② `pubspec.yaml` 변경 ③ `test/golden/` 하네스·`reference/**`·README·기존 골든 테스트·기존 테스트(`goal_path_view_test.dart` 의 T79-14 포함)가 `M` · `trust_badge_view.dart` 등 위젯 `M` ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now`·`Decimal`·`watchGrade`·`watchRolling`·`ScaffoldMessenger` ⑤ int 원값(`.issued`·`.filled` …)·`.emptyKind`·`trust.level` 을 읽거나 숫자를 글자로 만드는 코드 · `'%'` 문자열 · `elevation: 0.5` ⑥ (5) 가 마지막 커밋이 아님 · 공용 3파일에 삭제 줄 ⑦ ② 의 S04·S05·S13·S33 출력에 주석 줄·import 줄이 찍힘 · ⓡ·ⓗ 수(S31·S32)가 15·8 이 아님 — 하나라도 있으면 반려 신호(⑦ 의 S05 줄 표기만의 결함은 strict 나눔 ① = C4 정정).
- CI «골든 스냅샷» 잡은 이번 PR 이 **추가만** 하므로 초록이 정상입니다(빨간색이면 기존 PNG 를 건드린 것 · `golden:approved` 라벨은 필요 없다).
- 계약 테스트 C-42 의 `S7-10` 역할(②③③'④⑤⑥⑦⑨)과 ⑬(providers R12 절 — 이 카드의 R12d 절 포함)은 이 브랜치에서 처음 `lib/src/screens/execution_gap_screen.dart` 를 실제로 본다 — 병합 검사 때 Claude 가 그 위에서 `dart test test/contracts/c42_r12_screen_scan_test.dart` 를 돌리고 «C-42 ①» 출력의 대상 수를 PR 본문 ② 와 대조한다.
- 🔵 «정확히 N» 의 소유 — 이 카드 병합 뒤 배럴 export·`autoDispose` 줄을 바꾸는 카드(R13~)는 T710-16·T710-17 을 허용 diff 로 함께 고친다(그 카드가 정확 집합을 넘겨받는다 · v1.4 G13 · v1.6 T79-14 선례). 이 카드 안에서는 T79-14·G13 을 고치지 않는다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 범위 고지: 소급 정정 각주 `amendFootnoteText?`(㉞·㊳ 확정 뒤) · LEDGER_INTEGRITY 가림 표본·골든 · 뷰어 판 `trust.actionDeepLink` 목적지 · 가림 표본의 int 원값 운반 여부(이상 01 §8 미결 96) · 「계획」 탭 ⑤ 존재 판정 창구(미결 97) · 롤링 창(06 X7-4) · 셸 배선(R13 — `ledgerExecutionGap` → `ExecutionGapScreen()` · `ledgerExecutionGapMonth` → `ExecutionGapScreen(key: ValueKey(m), yyyyMm: m)` · override 목록에 `executionGapRepositoryProvider`)은 이 카드에 없습니다.
- 알릴 것(01 §15-4-17 ⑨): 같은 달·같은 대사 불일치에서 `S7-1` ⑧(`m7_monthly_masked_recon`)은 이행률 글자를 보이고 `S7-10`(`execution_gap_masked_recon`)은 «?»로 가린다 — 03 §14-b 가 `S7-10` 정본이라 `S7-10` 은 가린다 · `S7-1` 을 맞출지는 미결 96(이 카드는 `S7-1` 을 고치지 않는다).
- 그 밖의 알릴 것은 `_완료/R11b-Bob-S79.md` «5» 와 `_완료/R10a-Bob-S71b.md` «5» 를 참고합니다.
