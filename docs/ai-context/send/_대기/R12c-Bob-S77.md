# 발송 패킷 R12c-Bob-S77 — S7-7 12월 연간 리뷰 (계약 v1.6 · R12 4장 중 3번째)

> ⏸ **대기**(2026-10-08 조립) — 이 파일은 R12 조립 기록 커밋 `952b3eb` 이 `send/_대기/` 에 둔다. **R12b 병합**(squash `__R12B_SQ__`) 기록 커밋이 이 파일을 `send/` 로 옮기고 이 줄을 ▶ 로 바꾼다. **R12 4장 중 3번째** · 한 번에 카드 1장 · 순서 R12a → R12b → **R12c** → R12d(앞 카드 병합 뒤 다음 카드).
> 만든 날 2026-10-08 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R12c 행 · §6 4c · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-08_R12선행_계약v1.6_설계서.md` §2-5(공개 위젯·파일 자리) · §2-6(호출 표) · §2-7(필드 → 자리) · §3-5(골든 ↔ 입력 R12c 5행) · §6 규칙 1~19(공통) · 27~29(R12c) · §7(분할) · 조문 = `01_…` §15-4-5 · §15-4-7 · §15-4-8 · §15-4-9 · `03_…` §12 의 «🆕 계약 v1.6 — `S7-7` R12 범위 · 이 블록이 이긴다» 블록 · golden README «🆕 R12(계약 v1.6)» 절(기록 커밋 `952b3eb` 이 만든다).
> 사전 조건 — ✅ 계약 v1.6 병합(M2 PR #25 · squash `995c1f4` · 기록 `952b3eb`) · ⬜ **R12a-Bob-S76ab 병합**(squash `708fde1` — `S7-6a`·`S7-6b` · `rebalanceRepositoryProvider` · 골든 `s76a_*`·`s76b_*` 12장) · ⬜ **R12b-Bob-S76c 병합**(squash `__R12B_SQ__` — `S7-6c` · `analyticsWhatIfApiProvider` · 골든 `s76c_*` 10장). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 병합본 `flutter test`(packages/ui_analytics) = ⟦실측 — R12b 병합 기록 때 C4 가 채운다⟧(누적 드라이런 기준 = R12a·R12b 드라이런 위 `a62f783` 에서 403 — 🔴 R12b 보강 전 판 위의 값이다 · R12b 보강판 재측정 = 404(2026-10-13 · `dry/r12b-plus` `7272a43` · 뷰 40 · 보강 전 403 + 1) → 이 카드 끝 기대 447(= 이 카드 드라이런 실측 446 + 1 · 늘어난 1 은 R12b 뷰 파일 안이라 이 카드가 건드리지 않는다) · 병합본 실측으로 채운다).
> 카드 확정값(카드 권한): **정적 라벨 0개**(새 라벨 없음 — 재사용 `detailButton`·`retryButton`·`staleBannerTitle`) · Key 표(본문 «Key 표») · 위젯·프로바이더·파일 이름(본문 «주입 구조») · 골든 5이름 10장(크기 390 × 1440 — `kS77GoldenSize` · 드라이런 확정 · 영역 골든 2이름) · 테스트 번호 T77-01~T77-15.
> 🔴 **보내는 조건(Claude 확인)** — R12b PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-7_questions.md` 가 `main` 에 있음(빈 머리말 — 기록 커밋 `952b3eb` 이 만든다) + `prompt_M7.md` 의 R12 치환(0단계 `git grep -c "R12c = S7-7"` = `:2` · 줄 수 171 그대로) + golden README «🆕 R12(계약 v1.6)» 절의 R12c 행(`s77_*` 5이름 · `kS77GoldenSize` 390 × 1440 — 이 카드 «먼저 읽을 것» ⑤ 가 읽는다) + 파일 안 실측 표식(겹흰낫표 «실측» 자리) 0개 — 보내기 전 `grep -c` 로 0 을 확인한다(지금 남은 것은 «시작 기준 N» 3곳(머리 5행 · 0단계 flutter test 줄 · 3-1 끝 줄)뿐 — R12b 병합 기록 때 병합본 수로 채운다). 0단계의 `ls`·`git grep` 줄이 그 증명입니다.
> 🔴 **기록 커밋 체크리스트(Claude)** — `952b3eb` 이 넷을 다 했는지 R12b 병합 기록 때 다시 본다: ① `docs/ai-context/inbox/S7-7_questions.md` 빈 머리말(다음 번호 Q1·A1 · 표 머리 + 구분줄 · 행 0) — 없으면 Bob 의 0단계가 멈추고 ① name-status 의 `M` 이 `A` 로 바뀐다 ② `packages/ui_analytics/test/golden/README.md` «🆕 R12(계약 v1.6)» 절 R12c 행 ③ `prompt_M7.md` 2·3·109·118행 치환(2행 = `{{범위}}`·PR 제목 · 3행 = 조립 이력 · 109행 = 범위 · 118행 = PR 제목 — 모두 R12 네 장을 함께 적은 값 · «R12x = » 글자는 2·109행에만 · 171줄 유지 · 156~170행 = 12항 15줄) ④ `send/_대기/R12c-Bob-S77.md` → `send/R12c-Bob-S77.md` 이동 + 머리 ⏸ → ▶(이동은 R12b 병합 기록 커밋).
> 🔴 **카드 덮개 필수 문장(01 §15-4-5 · 03 §12 블록 ②④⑤)** — «`S7-7` 은 `annualReview()` 하나만 부른다 — 연도를 넘기지 않는다(엔진 기본 연도 · 어느 해인지는 `yearLabel` 이 말한다)» · «세후는 VM 최상위 `afterTax`(본문 갈래 하나) · `afterTaxCounterfactual`(접힘 카드) — `afterTaxLadder`·`OpsStatusRepository`·`monthlyReport` 를 부르지 않는다» · «서약문·«규칙 변경은 설정에서» M9 링크는 R12 에 자리가 없다(K4 권고 선반영 · 01 §8 미결 93)». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» ⑰ 에 있습니다. Key 표와 Text 순서 표도 본문에 있습니다.
> 🔵 결정 인용 — K4·K9·K12·K13·K16·K20·K25 = **권고 선반영**(00_README §8-4) · **K22**(R12 차단 표시 = `SafetyBlockBanner` 만 — 규칙 8) · **K24**(`yearLabel` 필수 필드 · 기본 연도 규칙) = ~~🔴 «권고 선반영 · 확인 대기»(01 §15-4-16 표 · v1.6 「푸시해」 전 발주자 확인 대상 — 뒤집히면 이 카드는 보내기 전에 다시 조립한다). 카드·C4 는 K 를 «확정»으로 인용하지 않는다~~ **✅ 발주자 확정(2026-10-13 «권고대로 확정하고 푸시해» — K1~K26 전부 권고대로 · 01 §15-4-16)** · 뒤집힌 K 0 · 다시 조립 0 — 이 카드가 쓰는 것은 **코드에 있는 이름**뿐이다.
> 드라이런: ✅ 2026-10-12 누적 드라이런(검사 폴더 `C:/Work/AAQ-claude-review` · 가지 `dry/r12c` 끝 `78189b0` · R12a·R12b 드라이런 `a62f783` 위 · 카드 본문만 보고 커밋 4개) — `flutter test`(packages/ui_analytics) = 시작 403 + 새 43(뷰 33 + 골든 10) = 446(🔴 R12b 보강 전 판 `a62f783` 위 — R12b 보강판 재측정 404(`dry/r12b-plus` `7272a43`) 위 기대 = 447) · domain_contracts +297 ~30 · format 0 changed · analyze No issues · test:contracts SUCCESS · 새 PNG 10(기존 86 M 0 · 합 96) · `kS77GoldenSize` = Size(390, 1440)(반사실을 펼친 cf 의 아래 끝 1400 · 여유 40) · 위치 전제 dy(light·dark 같음) = december 1320 · first_year 1252 · offwindow 1340 · aftertax_ladder_spec 812 · aftertax_ladder_cf 1400 · 영역 PNG = spec 358×724 · cf 358×1312(ListView 자식 RepaintBoundary — 세후 카드 하나만 찍힘 · 눈 확인) · S05 2줄(:66 · :211) · S15 8 · S16b 12 · S16c 1 · S27 `7 0` / `1 0`(a62f783 기준) · S29 13 · S30 6 · S31 3 · S32 9글자 · C-42 ① «S7-7(R12c) 1파일» · 역할 대상 합 4파일 · providers R12 절 45줄 · lib +228(화면 220 + providers 7 + 배럴 1) · test 줄 = 뷰 603 · 가짜 98 · 골든 117 · prompt_M7.md 156~170행 15줄 확인 · 예고 변이 36종 중 35 잡힘 → 놓친 1(«버튼이 늘 첫 섹션 route») = 현 픽스처로 구별 불가(route 가 섹션 0 에만 있음 · 미결 94) → 목록에서 «C4 적용 안 함» 표시로 옮김(이 판) · 드라이런 지적 4건 + 콜드 리드 10건 반영(이 판). 재분할 임계(설계서 §7 · 새 `testWidgets(` 줄 > 33 · lib > +900 · 새 PNG > 16) — 이 카드 = `testWidgets(` 줄 18(뷰 15 + 골든 3) · 새 PNG 10 · lib +228 → 재분할 불필요.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 치환값(2행 `{{범위}}` · 109행 «이번 과제 범위:» · 2행 뒤쪽·118행 PR 제목)은 기록 커밋 `952b3eb` 이 R12 네 장을 함께 적은 값으로 바꾼다 · 0단계 확인 줄 `git grep -c "R12c = S7-7"` 이 그 증명(2행·109행 = `:2`) · 🔴 기록 커밋은 줄을 더하지 않는다(171줄 그대로 — 아래 «프롬프트보다 이 카드가 이긴다» 의 행 번호는 `e716fe0` 판과 같다) · 이 카드의 범위·PR 제목은 이 패킷이 정한다 · 그 파일 4행 «🔵 정정 표식» ② «`S7-7` 에만 맞다»가 말하는 세후 사다리가 이 카드다) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R12a·R12b 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 이렇게 쓴다»로, 0단계·규칙 요약·본받지 않는 것·코드 틀은 본문에 담았습니다.
> R10·R11 교훈 반영: 보고 기계화(① name-status 출력 그대로 · ② 12항 복사 상자 + «정적 묶음» 37줄 출력 그대로 + S05 줄 · ③ 위젯·Key 이름 나열 복사 상자 · ④ 질문 파일 글자 그대로) · S05 줄 괄호 금지(R10c 2회차) · ⓡ·ⓗ 줄 수는 정적 S29·S30 `grep -c` 로 대조(R10c C4c2-2) · 테스트별 수는 명령 출력 그대로(12 §3 재발 방지 ① · R11a 2회차) · 배치 순서는 테스트가 사슬로 증명(R10c 1회차) · 조건부 단언 금지(R10b·R10c · R11b 1회차 C4b-5) · 공용 파일은 «정확히 N»으로 못박지 않고 «끝 절 더하기만»(R10 3분할 교훈 · «정확히 N» = R12d 한 곳 — 이 카드에는 0) · strict 보고 규칙 나눔(12 §3 · 2026-10-01) · «PR 본문은 통합 담당이 바꾼다»(12 §3 · 2026-10-01) · C4b-12(배너 «스크롤 밖» 단언) · C4b-14(Key 자리마다 글자 == vm 필드) 반영 · C4b-13(범례 견본 색)은 이 화면에 견본·게이지가 없어 해당 없음.

## 0. 한 줄 목적

12월 규칙 변경 창에 들어가기 전에 **한 해를 한 부로 묶어 보는 연간 리뷰(S7-7)** 를 계약 v1.6 그대로 짓기 — 연도 글자(`yearLabel`) → 창 상태 한 줄 → 세후 사다리(본문 갈래 하나 · 층 쌓기 · 반사실 접힘 · 참고치 표지) → 엔진이 준 섹션 카드 → 하단 기준일. 화면은 연도를 고르지 않고, 섹션을 세지 않고, 세후를 계산하지 않는다.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s77-annual`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **R12b 가 `main` 에 병합된 뒤에 보냅니다** — 이 파일 머리 첫 줄이 ⏸ 이면 아직입니다(Claude 가 R12b 병합을 기록할 때 ▶ 로 바꾸고 `send/_대기/` 에서 `send/` 로 옮깁니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R12a·R12b 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12c-Bob-S77.md> (로컬 사본 = Claude 기록 폴더의 `docs\ai-context\send\R12c-Bob-S77.md` · 기록 푸시 뒤 `main` 과 글자가 같습니다 · 어느 폴더인지는 R12b 병합 기록 때 Claude 가 확인한 절대 경로로 알립니다). 🔴 Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 R12b 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다 · `C:\Work\AAQ-claude\` 는 최신이 아닙니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부** — ```text 다음 줄(«R12c-Bob-S77 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 세 줄 …)» 의 끝 줄)까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 R12 의 끝난 카드 `_완료/R12a-Bob-S76ab*.md`·`_완료/R12b-Bob-S76c*.md`, 아직 보낼 차례가 아닌 `_대기/R12d-Bob-S710.md`, M7 의 끝난 카드 `_완료/R11a-Bob-S74*.md`·`_완료/R11b-Bob-S79*.md`·`_완료/R10*-Bob-*.md` 를 붙여넣지 않습니다. `send/` 바로 아래의 R12 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12c-Bob-S77 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 세 줄 …)» 의 끝 줄)까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12c-Bob-S77 — 범위: S7-7 12월 연간 리뷰(AnnualReviewScreen — 연도 글자(yearLabel) · 창 상태 한 줄(windowStateLabel) ·
  세후 사다리 블록(본문 갈래 하나 · 층을 받은 순서대로 한 열 · 정직 기대 문장 · 근거 문장 · 참고치 표지 · 반사실 접힘 카드) ·
  섹션 카드(제목 + 줄 + 링크 있으면 「자세히」) · 하단 기준일).
  R12 4장 중 3번째(R12a·R12b 는 이미 main 에 병합됨 · R12d 는 이 카드 병합 뒤).
🔴 S7-7 은 annualReview() 하나만 부른다 — 연도를 넘기지 않는다(엔진 기본 연도 · 어느 해인지는 yearLabel 이 말한다).
🔴 세후는 VM 최상위 afterTax(본문 갈래 하나) · afterTaxCounterfactual(접힘 카드) — afterTaxLadder · OpsStatusRepository · monthlyReport 를 부르지 않는다.
🔴 서약문 · «규칙 변경은 설정에서» M9 링크는 R12 에 자리가 없다(K4 권고 선반영 · 01 §8 미결 93) — 자리표시자 · 빈 카드 · 버튼 0.
하지 않는 것: S7-6a/b/c(R12a·R12b 몫 — 이미 main) · S7-10 이행 리포트(R12d) · S7-7 → S7-10 링크(K16 · ㉟) · 서약문·M9 링크(미결 93) ·
  적용·승인·투표 버튼 · 체크박스 · 총평 · 연도 고르기·과거 연도 · reportAfterTax 단독 화면 · 섹션 8개 표본 · 섹션별 «산출 불가» 구조 필드 ·
  창 상태와 «첫 해» 축 분리 · SIM 표본(미결 94) · S12 표시 범위(미결 95) · 셸 몫(라우트 등록·라우터 가드 — M8 · R13) ·
  웹 2열·반응형(Q-D) · 애니메이션 · 큰 글꼴 200% 시험(규칙 9 의 «overflow 0»은 지키되 이 카드에 테스트는 없다) · 기존 화면·위젯·앞 카드(R12a·R12b) 파일 수정.
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 22항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12a(ui/m7-s76ab-rebalance · 병합됨) · R12b(ui/m7-s76c-preview · 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate ·
ui/m7-s72-explore · ui/m7-s74-planner · ui/m7-s79-goal-path · ui/m7-s76ab-rebalance · ui/m7-s76c-preview)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/screens/annual_review_screen.dart · AnnualReviewScreen · annualReviewProvider · Key s77-* 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s76c-preview 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s77-annual origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.6.0'" -- packages/domain_contracts/lib/src/contract_version.dart                          ← «…contract_version.dart:1»(계약 v1.6 병합)
  git grep -c "annualReview({String? year})" -- packages/domain_contracts/lib/src/repositories/performance_repository.dart    ← «…performance_repository.dart:1»
  git grep -c "required String yearLabel" -- packages/domain_contracts/lib/src/dto/performance.dart                           ← «…performance.dart:1»
  git grep -c "String? referenceOnlyLabel" -- packages/domain_contracts/lib/src/dto/performance.dart                          ← «…performance.dart:1»
  git grep -c "AfterTaxLadder? afterTaxCounterfactual" -- packages/domain_contracts/lib/src/dto/performance.dart              ← «…performance.dart:1»
  ls docs/ai-context/send/R12c-Bob-S77.md                                          ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/S7-7_questions.md                                       ← 보여야 함(빈 표가 이미 있다)
  ls packages/ui_analytics/lib/src/screens/rebalance_timeline_screen.dart          ← 보여야 R12a 가 병합된 것입니다
  ls packages/ui_analytics/lib/src/screens/rebalance_event_screen.dart             ← 보여야 함(R12a)
  ls packages/ui_analytics/lib/src/screens/rebalance_preview_screen.dart           ← 보여야 R12b 가 병합된 것입니다
  ls packages/ui_analytics/test/golden/goldens/s76c_countdown_light.png            ← 보여야 함(R12b 골든)
  ls packages/domain_contracts/fixtures/m7/m7_annual_2026.json                     ← 보여야 함(v1.6 개정 픽스처)
  ls packages/domain_contracts/fixtures/m7/m7_annual_first_year.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m7/m7_annual_offwindow.json                ← 보여야 함(v1.6 신설 — 2025 · 창 닫힘)
  ls packages/domain_contracts/fixtures/safety_states.json                         ← 보여야 함
  git grep -c "R12c = S7-7" -- docs/ai-context/prompt_M7.md                        ← «…prompt_M7.md:2»(프롬프트의 범위 치환값이 R12 로 바뀌었다 — 2행·109행)
  git grep -c "s77_december" -- packages/ui_analytics/test/golden/README.md                ← 숫자 하나(golden README «🆕 R12» 절의 R12c 행이 있다 — 기록 커밋 몫)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음·다른 수면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R12c 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/screens/annual_review_screen.dart               ← 없어야 함
  ls packages/ui_analytics/lib/src/annual_review                                   ← 없어야 함
  git grep -c annualReviewProvider -- packages/ui_analytics/lib                    ← 출력 없음이어야 함
  git grep -c "s77-" -- packages/ui_analytics/lib                                  ← 출력 없음이어야 함
  git grep -c "R12c" -- packages/ui_analytics/lib/src/providers/analytics_providers.dart   ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 새 필드(AnnualReviewVm.yearLabel · afterTax · afterTaxCounterfactual · AfterTaxLadder.referenceOnlyLabel …)의 생성물은 git 에 없습니다
                              (안 하면 «타입 없음·필드 없음» 가짜 오류). «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: R12b 병합본 전부 통과 · 0 실패 · ⟦실측 — R12b 병합 기록 때 C4 가 채운다⟧(이 수가 아니면 PR 본문에 까닭 한 줄 — 출력 끝 줄을 «시작 기준 N» 으로 적어 둔다).
                   실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §15-4 > 03 §12 의 «🆕 계약 v1.6 — S7-7 R12 범위» 블록 > 03 §12 본문·그림 M7-23 > prompt_M7.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox/S7-7_questions.md 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·goal_path_probe_test·reference/**·README ·
   기존 골든 테스트 전부(s71 · s71b · s72 · s72g · s73 · s74 · s79 · R12a·R12b 의 s76a·s76b·s76c 골든 테스트) · 기존 PNG 전부(86장 = 64 + R12a 12 + R12b 10 — 하나라도 M 이면 되돌리고 멈춤 · 예외 없음) ·
   기존 lib 파일(lib/src/chart/** · lib/src/widgets/** · lib/src/goal_path/** · lib/src/planner/** · lib/planner.dart · 기존 screens/** · R12a·R12b 가 만든 lib/src/screens/rebalance_*.dart · lib/src/rebalance/**(폴더가 있으면 — R12a·R12b 는 만들지 않았다 · C-42 역할 표의 internalDir 자리)) ·
   기존 테스트 전부(R12a·R12b 의 테스트·가짜 포함 — import 도 하지 않는다 · explore_fakes.dart 의 FakeSafetyRepository 만 import).
   공용 파일 2개는 **끝 절 더하기만** 한다 — 기존 줄은 한 글자도 바꾸지 않는다(정적 묶음 S27 의 삭제 수 0 이 증명):
     lib/src/providers/analytics_providers.dart = 파일 끝(R12b 절 뒤)에 이 카드의 절 하나(머리 줄 // ── 🆕 R12c — S7-7 ── · 아래 «주입 구조») ·
     lib/ui_analytics.dart = export 한 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
   🔴 lib/l10n/labels.dart 는 이 카드에서 고치지 않는다(새 정적 라벨 0 — 아래 «정적 라벨»). 앞 카드가 만든 공용 파일의 R12a·R12b 절도 한 글자도 고치지 않는다.
 2 03 §12 본문의 구 초안(「데이터」·「컴포넌트」·「상태」·「수용」·「모의」 줄과 그림 M7-23 — OATH·NOTICE·SEC «섹션 카드 8개·요약 수치»·M9·OFF 배너)은 03 §12 의 «🆕 계약 v1.6 — S7-7 R12 범위» 블록 ①~⑨ 와 01 §15-4 에 집니다.
   구 초안 이름(ReviewSectionVm · changeWindowNoticeText · oathText · figures · KeyValueVm · AsOfStamp · summaryText)을 코드에 쓰지 않는다(주석 포함 — T77-14 와 정적 S14 가 센다).
   03 §12 «상태»의 «「변경 창 밖입니다」 배너»는 엔진 windowStateLabel 한 줄이 갈음한다 — 화면이 그 문장을 쓰지 않는다. «관측 미달»도 섹션 lines 의 엔진 글자다.
   또 01 §15-4·03 블록 머리의 «⬜ 로컬 커밋 — PR 대기» 와 12 §3 의 «⬜ 조립 대기» 흔적은 병합 전의 글이다 — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지(AnnualReviewScreen 의 생성자에는 key 뿐).
   이 카드가 여는 링크는 DTO 문자열 둘뿐이다: BlockFlag.clearDeepLink(차단 배너 — SafetyBlockBanner 가 onOpenLink 로 넘긴다) · AnnualReviewSection.route(섹션 「자세히」 버튼).
   이 카드가 쓰는 AppRoutes 상수는 0 개다(AppRoutes.reportAnnual 도 쓰지 않는다 — 라우트 등록은 셸 R13 몫).
 4 값 = DTO 의 *Label·*Text·*Line·label·title·lines 그대로 · 계약이 주는 값은 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(double·int·DateTime·bool)·.wire 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값으로 색을 고르지 않음 · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20 은 주석 줄도 센다(작은따옴표 뒤 같은 줄에 한글이 있으면 1건 · 기대 0건).
 5 읽지 않는 필드(카드가 정함 — 질문 아님 · 01 §15-4-9 · 계약 테스트 C-42 ②③ 와 같다):
     AnnualReviewVm.year · windowStateCode / AnnualReviewSection.code / AfterTaxLadder.branch · isReferenceOnly · configHash · asOf(사다리의 기준일 — 하단은 vm.asOf 하나) /
     AfterTaxStep.stepCode · cagrPct · endMult.
   🔴 C-42 ③(S7-7)은 lib/src/screens/annual_review_screen.dart 에서 «.year» · «.windowStateCode» · «.code» · «.stepCode» · «.cagrPct» · «.endMult» · «.branch» · «.isReferenceOnly» · «.configHash» ·
      «.journalTimelineLink» · «.detailDeepLink» 와 C-42 ② 의 «.mode» · «.kind» · «.wire» 를 빌드에서 막는다(\b 때문에 yearLabel · branchLabel · afterTax · afterTaxCounterfactual 은 걸리지 않는다) ·
      ③' 는 패턴 분해(예 final AnnualReviewVm(:windowStateCode) = vm)도 막는다. 🔴 isReferenceOnly bool 로 참고치 표지를 고르지 않는다 — 표지는 referenceOnlyLabel 의 null 여부다.
   🔴 C-42 ⑩ 가드 — AnnualReviewVm · AnnualReviewSection 이라는 낱말(주석 말고)은 annual_review_screen.dart 와 analytics_providers.dart 의 R12c 절에만 둔다(그 밖의 lib 파일에 쓰면 계약 테스트 실패).
 6 화면 산술 0 — 층·섹션·줄을 세지도 · 거르지도 · 정렬하지도 · 묶지도 · 합치지도 않는다(받은 순서 그대로 · 자리 i = .indexed 의 위치 · 층 수·섹션 수·줄 수 리터럴 0).
   두 사다리(afterTax · afterTaxCounterfactual)를 합치거나 나란히 비교표로 만들지 않는다 · 층 사이 차액을 빼지 않는다 · 연도·창 상태를 계산하거나 판정하지 않는다.
   🔴 C-42 ⑨ 가 S7-7 파일의 .sort · .sorted · .reversed · .where · .whereType · .firstWhere · .lastWhere · .singleWhere · .fold · .reduce · .take · .takeWhile · .skip · .skipWhile · .compareTo · .toSet ·
      .substring( · .split( · .replaceAll( · .replaceFirst( · .contains( · .startsWith( · .endsWith( · .indexOf( · .padLeft( · .padRight( · reverse: true 를 빌드에서 막는다(.indexed · .map · .length 는 허용).
 7 switch 0 — 이 화면에는 열거형 분기가 없다(windowStateCode · section.code · branch 를 읽지 않으므로). 상태를 고르는 것은 아래 «화면» 의 null 여부 다섯(afterTax · afterTaxCounterfactual · noteLine · referenceOnlyLabel · route)과 _cfOpen 뿐이다.
   🔴 CommandState 0 · rejectReasonCode 0(이 카드에는 명령이 없다).
 8 시계 = analyticsClockProvider(DateTime.now() 금지) — 쓰는 자리는 StaleBanner 하나다(위젯이 안에서 읽는다 · 기준 = vm.asOf).
   공통 상태 = 스켈레톤(스피너 금지) · 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(annualReviewProvider), lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ·
   오래됨 = StaleBanner(asOf: vm.asOf) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다 — S7-7 세후는 골든 참고치라 가리지 않는다 · 03 §1-4 «🆕 계약 v1.6» 줄 ④).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(값이 온 뒤에만 — R11b 목표 경로와 같다).
   🔴 C4b-12 — 두 배너는 Scrollable 밖이다(Column 의 첫째·둘째 자식 · Expanded(ListView) 앞) — 테스트가 find.ancestor(of: 배너 글자, matching: find.byType(Scrollable)) 0 으로 본다(T77-02 · T77-11 · T77-12).
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지 — 🔴 C-42 ⑤ 는 부분 일치라 ScaffoldMessenger · Scaffold.of · SnackBar 를 띄우는 코드도 막힌다 ·
   🔴 S7-7 파일의 주석에도 이 세 낱말을 쓰지 않는다 · 정적 S26 이 주석도 센다 · report_archive_screen.dart 13행의 클래스 주석 «Scaffold·AppBar 는 셸 소유»를 본뜨지 않는다) ·
   띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지 · 390px overflow 0(큰 글꼴 200% 에서도 Row 는 글자 쪽이 Expanded) ·
   엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(«세후 사다리»·«연간 리뷰»·«반사실» 같은 정적 머리 0 — 아래 «정적 라벨»).
   🔴 카드 = Card() 기본 고도(elevation 인자 없음 — 기존 M7 화면의 elevation: 0.5 를 본뜨지 않는다 · C-42 ⑥ «소수부가 0 이 아닌 소수 리터럴 0» 이 0.5 · 1.5 를 빌드에서 막는다) ·
   선 굵기·간격은 정수 또는 N.0 · % 를 품은 문자열 리터럴 0(C-42 ⑥).
10 프로바이더는 annualReviewProvider 하나만 더한다(analytics_providers.dart 끝 R12c 절 · 아래 «주입 구조») · 나머지는 이름·타입 그대로 재사용(performanceRepositoryProvider — 새 주입 0) ·
   오프너는 탭 콜백 안에서 ref.read — build 에서 read 금지. 🔴 annualReviewProvider 는 autoDispose 이고 family 가 아니다(키 없음 — 연도를 넘기지 않으므로) — 기존 3개(비-autoDispose family)를 본뜨지 않는다.
   🔴 R12c 절 안에서는 annualReview() 를 인자 없이 부른다(C-42 ⑬ «annualReview(» 뒤에 인자가 오면 실패) · DateRange·TradeDate·DateTime 낱말 0(⑬) · 주석에 autoDispose 낱말 금지(정적 S15 가 주석도 센다).
11 테스트 = testing.dart 받침대 extends(UnimplementedPerformanceRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처 행에서) · 링크는 RecordingLinkOpener 를 픽스처 값과 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key·위젯 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'T77-07 section cards in order 2026').
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다 ·
   스켈레톤 1 = expect(find.byType(AnalyticsSkeleton), findsOneWidget) — 스피너 부재로 대신하지 않는다 ·
   테스트는 package:ui_analytics/src/widgets/analytics_error_view.dart · analytics_skeleton.dart 를 직접 import 한다(배럴이 export 하지 않는다 — T77-09·T77-10 의 find.byType · tester.widget 에 필요) ·
   if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 C4b-14 — Key 를 단 Text 마다 tester.widget<Text>(find.byKey(…)).data == vm 필드(글자를 맞바꾼 변이를 잡는다 · 골든에만 맡기지 않는다 · T77-03).
   Key 를 단 묶음(Column·Card)은 그 안 Text 글자 목록 전체를 순서까지 단언한다(tester.widgetList<Text>(find.descendant(of: <Key>, matching: find.byType(Text))).map((Text t) => t.data).toList() == [...] ·
   🔴 find.text 로 세지 않는다 — 2026 픽스처는 첫 두 층의 valueText 가 같고(같은 글자 둘) · 본문과 반사실의 층 label · referenceOnlyLabel 이 같다).
   ⓡ = 정상 상태 테스트마다 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 를 **한 줄에 하나**(여러 픽스처를 도는 테스트는 testWidgets 본문에 한 줄) ·
   ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 전제 한 줄. 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄이어야 한다(접히면 변수로 받아 줄을 짧게) —
   정적 묶음 S29·S30 이 git grep -c 로 센다 — 🔴 아래 최소 목록의 ⓡ·ⓗ 표시 수와 **정확히** 같아야 한다
   (annual_review_view_test.dart ⓡ 13 · ⓗ 6 · 다르면 제출 전에 테스트를 고친다 · PR 본문의 까닭 한 줄로 갈음하지 못한다 · 다른 채 내면 반려).
   🔴 ⓗ(hasLength)를 두는 곳은 최소 목록에 ⓗ 로 표시한 자리뿐이다(T77-01 · 04 · 06 · 07 · 10 · 12). 그 밖의 루프 — T77-02 의 사슬 Finder 목록 · T77-05 의 기대 글자 목록 · 픽스처·경우 목록 ·
      T77-13 의 Text 루프 · T77-14 의 export 목록 — 에는 hasLength( 를 쓰지 않는다(쓰면 S30 이 6 과 달라진다 — 제출 전에 고친다 · 다른 채 내면 반려).
      ⓗ 를 두지 않는 루프에는 이것도 든다: T77-04·T77-07 의 순서 루프(for (int i = 1; …) — 앞의 ⓗ 전제가 같은 목록을 이미 본다) ·
      T77-09·T77-10 의 «그 플래그 label 글자 각 0» 루프(안전 행 3 의 activeFlags — hasLength 를 쓰지 않는다 · 전제가 필요하면 expect(…activeFlags, isNotEmpty)) · T77-13 의 금지어 넷 루프.
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 빈 if 블록 · 조용한 건너뛰기)와 firstWhere 다. 양쪽에 expect 가 있는 if/else(T77-02 · T77-07 · T77-11 · T77-12 에 카드가 «양쪽 다»라 적은 곳)는 허용한다.
      🔴 T77-04·T77-07 의 «앞 층·앞 섹션 dy < 다음 dy» 는 if 로 쓰지 않는다 — i = 0 부터 도는 루프 안에 if (i >= 1) { expect(…) } 를 두면 else 없는 if = 반려.
      순서 단언은 따로 도는 루프 for (int i = 1; i < <목록>.length; i++) 안에서 i − 1 과 i 를 비교한다(if 0).
      기대 목록을 만드는 collection-if(«if (s.noteLine != null) s.noteLine» · «if (s.route != null) AnalyticsLabels.detailButton»)는 허용한다 — 그 목록 전체를 == 로 단언하므로 양쪽이 함께 증명된다.
      T77-02 의 사슬 목록을 채우는 if/else 는 «있는 쪽 = 사슬에 넣기(뒤의 사슬 루프가 findsOneWidget 으로 단언) · 없는 쪽(else) = 그 자리의 findsNothing 단언 하나» 모양만 허용한다(R11b 재제출 F1 꼴).
      🆕 사슬의 «없는 쪽» 견본 — 코드 글자로(R12b 1회차 C12b-1 · 산문 «if/else 양쪽» 만으로는 같은 꼴이 두 번 나왔다 — R11b C4b-5 · R12b C12b-1 · 조건·변수 이름은 재량 · 실제 Finder·단언은 그 테스트 항목이 정한다):
        ㉠ 사슬을 if/else 문으로 채우는 꼴(권장):
          if (isStale) {
            chain.add(find.text(AnalyticsLabels.staleBannerTitle));
          } else {
            expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
          }
        🔴 반려 꼴(else 없는 if — 있는 쪽 단언이 그 자리에 없다): if (!isStale) { expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing); }
12 골든 = 새 PNG 10장(s77_*) · --update-goldens 는 테스트 파일 하나 지정(test/golden/s77_golden_test.dart · 폴더 지정 금지) · golden:approved 는 안 붙임(통합 담당) ·
   찍기 전 pumpAndSettle → 위치 전제(맨 아래 위젯의 dy < 높이) · 영역 골든 2이름은 아래 «골든» 의 matchesGoldenFile 한 줄로 찍는다(하네스 expectGolden 은 화면 전체용).
13 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음(.indexed 는 dart:core) · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)) · directives_ordering 린트(import·export 는 경로 알파벳 순).
14 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: afterTaxIndex · taxCount · ratio · aspectRatio · devicePixelRatio · duration · iteration · decoration. 글자 잇기는 보간 '${a}${b}'. (afterTax 를 이름에 넣은 변수 옆에 산술을 두지 않는다.)
15 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
16 엔진 글자 그대로 — 잘라 붙이기·파싱·단위 덧붙이기·자작 0. yearLabel 에서 연도를 떼어 쓰거나 windowStateLabel 앞에 머리 글자를 붙이지 않는다. 렌더 글자에 «추천·권유·자문·시그널» 0(픽스처가 이미 0 — T77-13 이 본다).
17 정적 묶음은 git grep 이라 **주석도 센다**(C-42 는 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄
   (annual_review_screen.dart · analytics_providers.dart 의 R12c 절)의 주석에 이 낱말을 쓰지 않는다:
   AppRoutes · analyticsLinkOpenerProvider · CommandApi · CommandState · Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · NumberFormat · GestureDetector · Colors ·
   replaceAll · replaceFirst · rejectReasonCode · seriesCode · GoalPathPoint · autoDispose · Scaffold(ScaffoldMessenger 포함) · AppBar · SafeArea · planner · operatingMode · orderIntentIds ·
   afterTaxLadder · OpsStatusRepository · monthlyReport · ReviewSectionVm · changeWindowNoticeText · oathText · KeyValueVm · AsOfStamp · ExpansionTile · .year · .code · .branch · .configHash · .isReferenceOnly ·
   R12c · annualReview(analytics_providers.dart 의 주석 — 정적 S31 이 센다 · 머리 줄의 R12c 는 예외)
   (카드 문장을 가드 주석으로 옮겨 적지 않는다 — 위 세 🔴 덮개 문장도 주석에 옮기지 않는다).
   🔴 annual_review_screen.dart 는 analytics_providers.dart 를 show 없이 import 한다 — S05 에는 탭 콜백 안 2줄만 나와야 한다(SafetyBlockBanner onOpenLink · 섹션 「자세히」 onPressed ·
      import 줄·주석 줄이 찍히면 위반 · 그 줄에 «— 탭 콜백 안» 을 적으면 거짓 보고 = 반려).
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10a·R10b·R10c · R11a·R11b 교훈 · 발주자 결정 2026-10-01 «strict 나눔» — 이 카드부터 그대로 적용) —
   ① **보고 표기만의 결함**(경로 앞머리·백틱·요지 줄임·까닭 누락 등 — 내용은 사실이고 글자 모양만 카드와 다른 것) = 반려하지 않는다 → 통합 담당(C4)이 PR 본문을 정정하고 병합한다.
   ② **코드·테스트 결함**(카드 규칙 위반 — 예 규칙 11 «else 없는 if»)과 **거짓 주장**(보고 내용이 코드·파일·PNG·출력과 다름) = **반려**(재량 없음).
   ③ 아래 «예고 변이» 가 하나라도 테스트를 통과하면 = **반려**.
   그래도 원칙은 «출력 그대로 · 복사 상자 그대로» 다 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고,
   골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다(글자는 테스트 글꼴이라 네모).
   🆕 배치·잘림 칸에는 PNG 에서 보이는 것만 쓴다 — 글자 내용·글자 길이의 차이는 테스트 글꼴 네모로 보이지 않으므로 쓰지 않는다(픽스처 설명을 PNG 서술로 옮기지 않는다 · R12a 1회차 반려 사유 C12a-1 = 보고 ≠ PNG = 거짓 주장 = 반려).
   🆕 골든 표 «배치·잘림» 칸에는 «띠»(배경이 보이지 않는 글자 줄을 띠라 부르지 않는다 — 배경이 PNG 에 보일 때만) · «고정»·«스크롤 밖»(정지 PNG 로는 보이지 않는 스크롤 성질 — 그것은 테스트가 증명한다) · 색·테마 이름(primary · error · tertiaryContainer 같은 이름 — PNG 는 색을 보여 줄 뿐 이름은 보여 주지 않는다)처럼 PNG 에서 보이지 않는 말도 쓰지 않는다(보이는 것만 — 예 «고지 문장(맨 위 2줄)» · R12b 1회차 C12b-6 «고지 띠(상단 고정)» ↔ PNG 는 배경 없는 글자 2줄 · 이 금지는 골든 표 칸 몫 — 12항 괄호·③ 서술 등 복사 상자 글자는 상자 그대로 쓴다).
   🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 낸다). 제출 글은 «■ 제출» 의 섹션 머리 ①~⑤ 글자를 그대로 쓴다.
   🔴 정적 묶음 S05 의 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만 적습니다 — 괄호·위젯 이름·매개변수 이름·설명·백틱·앞머리 금지.
      정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ 와 완전히 같아야 합니다 · <파일> = git grep 출력의 경로 그대로(예 lib/src/screens/annual_review_screen.dart:57 — 탭 콜백 안 · 줄 끝 빈칸 없음).
      금지 예(R10c 2회차 · R11b 1회차): «…:103 — 탭 콜백 안 (SafetyBlockBanner onTap)» · «`packages/ui_analytics/lib/…:68 — 탭 콜백 안`».
   🔴 테스트 보강 줄(ⓡ·ⓗ)의 개수는 정적 묶음 S29·S30 의 git grep -c 출력으로 대조합니다 · 테스트별 수(«까닭» 류)는 손으로 세지 않고 «■ 제출» 이 준 명령의 출력 끝 줄을 그대로 붙입니다(12 §3 재발 방지 ①).
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M7.md 156~170행 12항 15줄 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 — [—] 는 쓰지 않습니다 ·
   항목을 새로 만들거나 자기 말로 바꿔 쓰지 않습니다 — R10a 는 12항을 전부 자기 말로 바꿔 1·2·3·11항의 원문 검사가 빠졌습니다).
   ③ 은 «■ 제출» ③ 의 복사 상자(build 가 그리는 순서 = 렌더 순서의 위젯·Key 이름 나열 · private 메서드는 호출 자리에서 펼쳐 읽는다)를 코드와 대조한 뒤 그대로 붙입니다(«순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지 — R10c 1회차).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않습니다(골든 위치 전제의 dy 는 예외 — 아래 «질문 파일» 절). 질문 파일 새 행의 상태는 «⬜ 미답» · 답 칸 비움. 카드가 정한 것은 추측 행으로 적지 않습니다.

■ 프롬프트보다 이 카드가 이긴다 — 22항 (prompt_M7.md 행 번호 = 기록 커밋 뒤 main 판 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다 ·
   행이 어긋나 보이면 괄호 안의 찾는 말로 찾는다)
 ① 12~13행(«추가하려면 먼저 질문») → 의존 추가 없음(pubspec 불변)
 ② 14~15행(«라우트 상수로 딥링크만 요청») → DTO 링크(AnnualReviewSection.route · BlockFlag.clearDeepLink)를 AppLinkOpener.open 에 · 쓰는 AppRoutes 상수 0(규칙 3)
 ③ 16~18행(«DateTime.now()를 쓰지 않습니다») → 그대로 · 주입 시계를 읽는 자리는 StaleBanner 하나
 ④ 20~23행(«허용되는 산술은 레이아웃 계산뿐») → S7-7 에는 정규값도 없다 — 산술 0(규칙 6)
 ⑤ 24~25행(«목록 길이를 세지 말고») → 그대로 · 섹션·층·줄 수 리터럴 0 · 화면은 .indexed 로 Key 만 단다
 ⑥ 45~48·66~69행(«띠가 차지할 높이를 레이아웃에서 비워 두는 것») → 예약 안 함(01 §9)
 ⑦ 49~52행(«수익률·세후·낙폭 수치를 … 리터럴로 적지 마십시오 · «세후»는 … 사다리입니다(세전 → 골든 세후 → 전 계좌 세후 → 정직 기대)») → 리터럴 금지는 그대로 유효
    (실제 강제 = 계약 테스트 C-38 ⑫ · C-42 ⑥(CI) + 정적 S21~S23·S25) · 괄호 안 네 단계는 **예시** — 층 수 = steps.length(현재 픽스처 6층 · 연금 수령·연금 외 수령 두 층이 나란한 두 줄)
 ⑧ 90행(«자체 점검 10항») · 155행(«명세 §12와 1:1») → 156~170행 12항(이 카드 밖의 4·5·6·7·8 · 10 앞절 · 12 뒷절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑨ 90~91행(«스크린샷 — … 4장») → 서술 + 골든 표(«제출» ③)
 ⑩ 88~90행(«PR 본문에 5개 섹션») → PR 은 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅 · PR 본문은 통합 담당이 바꾼다)
 ⑪ 95~96행(«픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조») → 그대로 유효 · 이 카드에 재생성 예외 0(기존 PNG M = 반려)
 ⑫ 99~102행(«TODO(question-3)» · «M2 미정의») → 질문 파일로 · 이 화면의 타입은 코드에 확정(AnnualReviewVm · AnnualReviewSection · AfterTaxLadder · AfterTaxStep — v1.6)
 ⑬ 104~109행(역할 문단 · «반응형으로 넓히십시오» · 109행 «이번 과제 범위:») → 범위 = 이 카드의 S7-7 · 폰 세로 한 열 · 웹 2열(03 §12 «플랫폼») 범위 밖 · 치환값은 R12 네 장을 함께 적은 것이다(0단계 확인 줄)
 ⑭ 110~116행(«읽을 문서 (이 5개가 전부입니다)») → 아래 «먼저 읽을 것»
 ⑮ 117~118행(«브랜치 `ui/m7-<화면ID소문자>`» · PR 제목 치환값) → ui/m7-s77-annual · PR 제목은 «■ 제출» 이 정한다
 ⑯ 120~124행(결정 8 · S7-2 3종) → 이 카드 범위 밖(12항 4번 괄호)
 ⑰ 138~142행(««세후 수익률»은 사다리입니다 · 연간 리뷰(S7-7 ①)와 목표 경로(S7-9)에서 … 네 층 … ⚠️ 세후 타입은 M2 확정 대기이니 이름을 지어내지 말고») →
    S7-7 만 해당(S7-9 에는 사다리가 없다 — 4행 정정 표식 ②) · 타입은 코드에 확정 = AfterTaxLadder(VM 최상위 afterTax = 본문 갈래 하나 · afterTaxCounterfactual = 접힘 카드) ·
    층 수 = steps.length(«네 층»은 예시) · 「층을 접거나 합치지 말고 steps 를 순서대로 쌓아」는 그대로 유효 · 🔴 연도를 넘기지 않고 annualReview() 하나 · afterTaxLadder 를 따로 부르지 않는다
 ⑱ 125~127행(«기간 프리셋 … 계약이 줍니다») → S7-7 은 기간·연도를 고르지 않는다(연도 = 엔진 기본 연도 · yearLabel)
 ⑲ 133~137행(플래너 · S7-8 · 목표 경로 한 줄) → 이 카드 범위 밖
 ⑳ 143~145행(목표 경로 가정 카드 두 줄) → 이 카드 범위 밖(12항 12번 뒷절 괄호)
 ㉑ 146~148행(S7-10 · modeAdviceLine) → R12d 몫 · 🔴 S7-7 → S7-10 링크 0(섹션 C_EXECUTION 의 route 는 null 로 온다 · K16)
 ㉒ 149~154행(양방향 딥링크 · 값을 두면 안 되는 미결) → 이 카드에 해당 없음 · 서약문·M9 링크 = 미결 93(자리 0)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문(머리 4·5행 «🔵 정정 표식» · «🔵 보충 표식» 포함)
 ② 01 §15-4-5(S7-7 — annualReview · 기본 연도 · yearLabel · 세후 2필드 · referenceOnlyLabel · S12 창구 세후 null) · §15-4-7(공개 위젯·파일 자리·providers R12 절) · §15-4-8(호출 표) · §15-4-9(필드 → 자리 표)
 ③ 03 §12 의 «🆕 계약 v1.6 — `S7-7` R12 범위 · 이 블록이 이긴다» 블록 ①~⑨(찾는 말 = «S7-7` R12 범위 ·» · 「모의」 줄 바로 아래 · 그림 M7-23 앞 — 그 위쪽 본문과 그림은 구 초안이라 블록이 이긴다) +
    03 §1-4 의 «🆕 계약 v1.6 — R12 범위» 줄(차단 = SafetyBlockBanner 만 · ④ S7-7 세후는 가리지 않는다)
 ④ packages/domain_contracts/lib/ — src/dto/performance.dart 의 AnnualReviewVm · AnnualReviewSection · AfterTaxLadder · AfterTaxStep(주석의 🔴 표식까지) ·
    src/repositories/performance_repository.dart(annualReview({String? year}) 주석) · testing.dart(UnimplementedPerformanceRepository — annualReview·afterTaxLadder·monthlyReport 는 동기로 던진다 · RecordingLinkOpener)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R12(계약 v1.6)» 절 전부 + «🆕 R11» 절의 «1»(위치 전제·dy 재는 법) + «규칙»·«하네스» 절
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart(읽기만) · lib/src/providers/analytics_providers.dart 전문(R11b 절의 goalPathProvider 꼴 · R12a·R12b 절 — 고치지 않는다) ·
    lib/src/screens/goal_path_screen.dart(로딩·에러·배너·Expanded(ListView) 뼈대의 선례 — 틀만 · S7-9 의 규칙은 가져오지 않는다) ·
    lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · stale_banner.dart · safety_block_banner.dart ·
    test/explore_fakes.dart(FakeSafetyRepository — import 만) · test/goal_path_fakes.dart(가짜·오버라이드·띄우기 도우미 꼴의 선례) · test/golden/golden_support.dart · test/golden/s79_golden_test.dart(루프 모양)
 ⑦ packages/domain_contracts/fixtures/README.md 의 «계약 v1.6» 절 + 이 카드가 쓰는 픽스처 4개(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · S7-7_questions.md 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일(contribution · drawdown_context · monthly_report)의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 · Card(elevation: 0.5) →
   연간 리뷰는 AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton — R10a · 이미 main) · Card() 기본 고도
 · analytics_providers.dart 의 비-autoDispose family 3개 → annualReviewProvider 는 autoDispose · family 아님
 · 테스트의 class … implements SafetyRepository(monthly_report_view_test · s71_golden_test 의 _FakeSafetyRepository) · 한국어 테스트 이름(monthly_report_view_test 의 기존 테스트) ·
   «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 → 받침대 extends · 전제는 expect · 띄우기 도우미(pumpAnnualReview) 하나 · ASCII 이름
 · report_archive_screen.dart 13행의 클래스 주석(«Scaffold·AppBar 는 셸 소유 …») → S7-7 파일 주석에 Scaffold·AppBar·SafeArea 낱말 0(정적 S26 · C-42 ⑤ 가 코드에서 · 정적 묶음이 주석까지)
 · goal_path_screen.dart 의 루트 Key ValueKey<String>('s79-${vm.yyyyMm}') → S7-7 의 루트 Key 는 고정 Key('s77-root')(생성자 파라미터가 없다 · vm.year 를 Key 에도 쓰지 않는다)
 · S7-9 의 «세후 사다리가 없다 — 정직 기대는 인용 문장 한 줄씩» → S7-7 은 사다리 전체를 그린다(그 규칙을 가져오지 않는다)
 · 03 §12 위쪽 구 초안의 이름·모양(ReviewSectionVm · changeWindowNoticeText · oathText · figures · KeyValueVm · «섹션 카드 8개·요약 수치» · 하단 M9 링크 · 최상단 서약문) → 코드의 v1.6 이름 · 엔진이 준 섹션 수
 · ExpansionTile · AnimatedSize · AnimatedCrossFade(반사실 접힘) → InkWell + setState + if (_cfOpen)(애니메이션 0 · 접힌 동안 반사실 층은 위젯트리에 없다)
 · R12a·R12b 의 화면·내부 위젯(lib/src/screens/rebalance_*.dart · lib/src/rebalance/**) → import 0 · 본뜨기 0(역할끼리 공유 위젯 파일 0 — C-42 역할 표)
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s77-…)

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsSkeleton() · AnalyticsErrorView(onRetry:, lastAsOfLabel:) ·
  AnalyticsLabels.retryButton · staleBannerTitle · detailButton(섹션 「자세히」 버튼 글자).
· 🆕 프로바이더 하나 — lib/src/providers/analytics_providers.dart **끝**(R12b 절 뒤 · 빈 줄 하나 띄우고)에 이 모양으로 더한다(기존 줄 무변경):
    // ── 🆕 R12c — S7-7 ──
    /// S7-7 연간 리뷰 — 연도 인자 없이(엔진 기본 연도 · 01 §15-4)
    final AutoDisposeFutureProvider<AnnualReviewVm> annualReviewProvider =
        FutureProvider.autoDispose<AnnualReviewVm>((ref) {
          return ref.watch(performanceRepositoryProvider).annualReview();
        });
  🔴 머리 줄은 글자 그대로(// ── 🆕 R12c — S7-7 ──) — 계약 테스트 C-42 ⑬ 이 «// ── 🆕 R12» 로 시작하는 첫 줄부터 파일 끝까지를 R12 절로 잘라 스캔한다(R12a 의 표식이 이미 첫 줄이다 · 이 절은 그 아래 끝에 붙는다) ·
     annualReview() 인자 0 · 주석에 autoDispose 낱말 금지 · dart format 이 줄을 나눠도 된다(autoDispose 가 든 줄이 하나면 된다).
· 🆕 lib 파일 1개(이것 말고 새 lib 파일·폴더를 만들지 않는다 — 🔴 lib/src/annual_review/ 폴더를 만들지 않는다 · 화면 본문·층·섹션 카드는 이 파일 안의 private 위젯·메서드로):
    lib/src/screens/annual_review_screen.dart        AnnualReviewScreen({super.key}) — 공개 · ConsumerStatefulWidget(State 에 bool _cfOpen = false 하나)
  (C-42 의 S7-7 역할 대상 = 이 파일 + lib/src/annual_review/** — 정적 묶음 뒤의 C-42 ① 출력이 «S7-7(R12c) 1파일» 이어야 한다.)
· 배럴 lib/ui_analytics.dart 에 export 'src/screens/annual_review_screen.dart'; 한 줄 —
  🔴 자리 = export 'src/providers/analytics_providers.dart'; 줄과 export 'src/screens/contribution_screen.dart'; 줄 **사이**(끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패).
  R12a·R12b 의 export 줄(rebalance_*)은 그대로 둔다. 🔴 배럴 export 의 «정확한 개수» 단언은 R12d 몫이다 — 이 카드의 테스트는 «annual_review_screen 줄이 정확히 하나» 만 본다(T77-14).
· 이 카드는 R11a 의 lib/planner.dart · lib/src/planner/** 를 import 하지도 고치지도 않는다(C-35 ⑥ · C-42 ⑤ «package:ui_analytics/planner»).
· annual_review_screen.dart 의 import(directives_ordering 순서 · goal_path_screen.dart 와 같은 꼴):
    import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
    import '../../l10n/labels.dart'; → import '../providers/analytics_providers.dart'; → import '../widgets/analytics_error_view.dart'; →
    import '../widgets/analytics_skeleton.dart'; → import '../widgets/safety_block_banner.dart'; → import '../widgets/stale_banner.dart';(show 없이 · trust_badge_view 는 쓰지 않는다)

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / fixtureEnvelope)
 연간 리뷰  singleFixture(FixturePaths.m7M7Annual2026, AnnualReviewVm.fromJson) · m7M7AnnualFirstYear · m7M7AnnualOffwindow
            (모양 — 테스트는 이 표를 믿지 말고 hasLength 전제로 다시 확인한다:
             셋 다 섹션 4개(A_RETURNS · B_AFTERTAX · C_EXECUTION · D_RULES 순 — code 는 읽지 않는다) · 세후 두 블록(본문 · 반사실) 모두 non-null · 두 블록 모두 6층 · referenceOnlyLabel 두 블록 모두 non-null ·
             2026 = 창 OPEN · 섹션 0(A)만 route 있음 · B·C·D 없음 / first_year = 창 FIRST_YEAR · 4섹션 모두 route 없음 / offwindow = 2025 · 창 CLOSED · 섹션 0(A)만 route 있음 ·
             세 픽스처 모두 본문 사다리의 층 2(방어 자산 과세까지 뒤)만 noteLine 없음 · 반사실 사다리의 층 1(파킹 과세 뒤)만 noteLine 없음 · 본문 층 0·1 의 valueText 가 같다 ·
             세 픽스처 모두 asOf = 2026-08-31T09:00Z · stale_after 93600초 → kGoldenNowUtc 신선 · +3일 오래됨)
 안전        SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상(플래그 0) · 3 차단 2건(RECON_MISMATCH · JOURNAL_MISSING · 둘 다 clearDeepLink 있음 → 배너의 chevron_right 2) · 4 무결성(LEDGER_INTEGRITY · clearDeepLink 1 → chevron_right 1)
 🔴 aftertax_ladder_1(FixturePaths.m7AftertaxLadder1)은 이 카드에서 읽지 않는다(C-30 골든 대조 전용 — 화면 경로는 AnnualReviewVm 의 두 필드 · annual 3벌이 그 사본을 싣는다).
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다. 픽스처를 복사해 고친 «내 픽스처» 금지(afterTax 를 null 로 바꾼 표본 등). 모자라면 질문 파일에.
    (afterTax == null · afterTaxCounterfactual == null · referenceOnlyLabel == null 표본은 annual 3벌에 없다 — 그 갈래는 코드로 짓되(null = 부재) 테스트는 표본이 있는 쪽만 · 질문 아님 · 01 §8 미결 94)

■ 화면 — S7-7 AnnualReviewScreen (01 §15-4-9 «필드 → 자리» 표 · 03 §12 블록 ③④⑤⑥)
 build:
   final AsyncValue<AnnualReviewVm> asyncValue = ref.watch(annualReviewProvider);
   final List<BlockFlag> activeFlags = ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ?? const <BlockFlag>[];
   asyncValue.when(
     loading: () => ListView(padding: 16, children: [ AnalyticsSkeleton() ]),                                     ← 배너 없음
     error:   (error, stack) => ListView(padding: 16, children: [ AnalyticsErrorView(onRetry: () => ref.invalidate(annualReviewProvider), lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ]),   ← 배너 없음
     data:    (vm) => 아래 배치)
 배치(값이 온 뒤 · 위 → 아래):
   Column(key: const Key('s77-root'))[
    1 StaleBanner(asOf: vm.asOf)                                                  ← 스크롤 밖
    2 SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (link) { ref.read(analyticsLinkOpenerProvider).open(link); })   ← 스크롤 밖
    ── 이하 Expanded(ListView(padding 16)[ … ]) — 아래 3~7 은 ListView 의 **직접 자식**(사이 간격 SizedBox 도 직접 자식 · 3~7 을 다른 Column·Padding 으로 감싸지 않는다) ──
    3 Text(vm.yearLabel)                                            Key s77-year         ← 맨 위 · 어느 해인지 말하는 유일한 글자
    4 Text(vm.windowStateLabel)                                     Key s77-window       ← 고정 1줄(창 상태로 색·아이콘·배너를 고르지 않는다)
    5 (vm.afterTax != null) 세후 블록 — Card(key: const Key('s77-aftertax')) · Padding 16 · Column(crossAxisAlignment: start)[
        5a Text(ladder.branchLabel)                                                     ← 본문 갈래 이름(엔진 글자 · 정적 머리 0)
        5b 층 — for ((i, step) in ladder.steps.indexed) Column(key: ValueKey<String>('s77-step-$i'), crossAxisAlignment: start)[
               Text(step.label) , Text(step.valueText) , (step.noteLine != null) Text(step.noteLine!) ]   ← 받은 순서 · 한 열 · 위에서 아래로(층 사이 간격 재량)
        5c Text(ladder.honestExpectationLine)
        5d Text(ladder.basisNote)
        5e (ladder.referenceOnlyLabel != null) Text(ladder.referenceOnlyLabel!)        ← 참고치 표지(isReferenceOnly 를 읽지 않는다)
        5f (vm.afterTaxCounterfactual != null) 반사실 접힘 카드 — Card(key: const Key('s77-cf'))[
               InkWell(key: const Key('s77-cf-toggle'), onTap: () => setState(() => _cfOpen = !_cfOpen),
                       child: Padding 12 · Row[ Expanded(Text(cf.branchLabel)) , Icon(_cfOpen ? Icons.expand_less : Icons.expand_more) ])
               (_cfOpen) 펼친 몸 — Padding 12 · Column[ 5b 와 같은 층 Column(cf.steps · Key ValueKey<String>('s77-step-$i')) , Text(cf.honestExpectationLine) , Text(cf.basisNote) ,
                                                        (cf.referenceOnlyLabel != null) Text(cf.referenceOnlyLabel!) ]
             ]
       ]
       ladder = vm.afterTax! · cf = vm.afterTaxCounterfactual!(지역 변수 · 이름 재량 — 단 규칙 14 의 C-4 함정을 피한다).
       층 위젯은 private 메서드 하나(예 _buildStep(int i, AfterTaxStep step))로 본문·반사실이 함께 쓴다 — 🔴 두 사다리를 한 목록으로 합치지 않는다(반사실 층은 s77-cf 안에만).
       🔴 반사실 층의 Key 도 ValueKey<String>('s77-step-$i') 다(Key 표에 새 글자를 더하지 않는다 — 반사실 층은 s77-cf 아래에 있다는 것으로 가른다 · 형제끼리가 아니므로 Key 가 겹쳐도 된다).
    6 섹션 카드 — for ((i, section) in vm.sections.indexed) Card(key: ValueKey<String>('s77-section-$i')) · Padding 16 · Column(crossAxisAlignment: start)[
        Text(section.title) , for (line in section.lines) Text(line) ,
        (section.route != null) TextButton(onPressed: () { ref.read(analyticsLinkOpenerProvider).open(<그 route>); }, child: const Text(AnalyticsLabels.detailButton)) ]
       (섹션 카드는 private 메서드 하나 — 예 Widget _buildSection(int i, AnnualReviewSection section) · 그 안에서 final String? route = section.route; 로 받아 null 검사 뒤 콜백에 넘긴다)
    7 Text(vm.asOf.label)                                           Key s77-asof         ← 맨 아래(골든 위치 전제의 기준 · 사다리의 asOf 는 그리지 않는다)
   ]
 🔴 상태를 고르는 것은 afterTax · afterTaxCounterfactual · step.noteLine · ladder.referenceOnlyLabel · section.route 의 null 여부와 _cfOpen 뿐이다(규칙 7).
    windowStateCode · year · section.code · branch · isReferenceOnly · RunMode · 섹션 순번으로 무엇을 고르지 않는다(B_AFTERTAX 섹션과 세후 블록을 «짝» 짓지 않는다 — 세후 블록은 VM 최상위 필드다).
 🔴 반사실 카드는 **늘 기본 접힘**(_cfOpen = false 로 시작 · 접힌 동안 펼친 몸은 위젯트리에 없다 — Offstage·Visibility 금지) · 탭할 때마다 setState 로 뒤집는다.
 🔴 판정·총평·정적 제목 0 — «연간 리뷰» · «세후» · «반사실» · «변경 창 밖입니다» · «관측 미달» 같은 글자를 화면이 쓰지 않는다(전부 엔진 문장 · 아래 «정적 라벨» 의 «만들지 않는 글자»).
 간격(SizedBox 높이 — 정수)·글자 굵기·Card 모서리·Padding 수(정수)는 재량(질문 아님). 🔴 Card 의 elevation·color 인자 0 · Divider·Chip·배지 0.

■ Key 표 (카드 확정 — 이 글자 그대로 · 🔴 여기 없는 s77- Key 를 더하지 않는다 · 설계서 §6 규칙 17 그대로)
   루트          Key('s77-root')                         값이 온 뒤의 Column
   연도          Key('s77-year')                         Text(vm.yearLabel)
   창 상태       Key('s77-window')                       Text(vm.windowStateLabel)
   세후 블록     Key('s77-aftertax')                     Card — afterTax 있을 때만 · ListView 의 직접 자식(영역 골든의 대상)
   층            ValueKey<String>('s77-step-$i')         층마다 Column(label · valueText · noteLine?) — 본문(s77-aftertax 안 · s77-cf 밖)과 반사실(s77-cf 안 · 펼쳤을 때만)
   반사실        Key('s77-cf') · Key('s77-cf-toggle')    Card — afterTaxCounterfactual 있을 때만 · 토글 = 머리 InkWell(그 안 Text = cf.branchLabel)
   섹션          ValueKey<String>('s77-section-$i')      섹션마다 Card(title · lines · 「자세히」?)
   하단 기준일   Key('s77-asof')                         Text(vm.asOf.label)
 (i = 받은 위치 · 화면이 세지 않고 .indexed 로 Key 만 단다 · 「자세히」 버튼·branchLabel·정직 기대·근거·참고치 Text 에는 Key 를 달지 않는다 — 테스트는 그 Key 묶음 안 글자 목록으로 본다)

■ 정적 라벨 — 🔴 이 카드는 lib/l10n/labels.dart 를 고치지 않는다(새 라벨 0 · 절 머리도 더하지 않는다)
   재사용: AnalyticsLabels.detailButton(«자세히» — 섹션 버튼) · retryButton · staleBannerTitle(위젯 안). R10b~R12b 의 라벨 절은 고치지 않는다.
   🔴 만들지 않는 글자(엔진 몫): 연도(«2026년»·«2025년») · «연간 리뷰» · «변경 창 밖입니다» · «관측 미달» · «세후 사다리» · «세금 전» · «정직 기대» · «반사실» · «골든 참고치» ·
      «참고치» · «모의» · 서약문 · «규칙 변경은 설정에서» · «적용»·«승인» · 총평 · 숫자·%·«연 n%».
   🔴 반사실 토글에 «반사실 보기» 같은 정적 글자를 붙이지 않는다 — 머리 = cf.branchLabel(엔진 글자) + 펼침 아이콘(Icons.expand_more / Icons.expand_less)이다.
   더 필요해 보이면 더하지 말고(카드 확정값 = 0) 질문 파일에 적은 뒤 채팅으로.

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R12c (1) 주입 — annualReviewProvider») · 테스트는 그 단계 커밋에 함께
 (1) annualReviewProvider(analytics_providers.dart 끝 R12c 절 · 기존 화면·위젯 무변경 — 0단계의 시작 기준 N 이 그대로 통과).
     커밋 «[M7] R12c (1) 주입 — annualReviewProvider»
 (2) AnnualReviewScreen(lib/src/screens/annual_review_screen.dart) + 배럴 export 한 줄(정렬 자리) + test/annual_review_fakes.dart(가짜·오버라이드·띄우기 도우미) +
     test/annual_review_view_test.dart(T77-01~T77-15). 커밋 «[M7] R12c (2) S7-7 연간 리뷰 화면 + 테스트»
     🔴 이 커밋 전에 packages/ui_analytics 에서 «정적 묶음» 37줄을 한 번 미리 돌려 본다 — 🔴 git grep 은 add 하지 않은 새 파일을 보지 않는다(출력 없음 = 거짓 안심) →
        먼저 git add . (packages/ui_analytics 안에서 · 커밋은 그다음)로 올린 뒤 돌린다: S04 = 출력 없음 · S05 = 2줄 · S13 = 옛 4파일뿐 · S15 = 8줄 · S28 = 출력 없음 ·
        S03·S03b·S06~S12·S14·S20·S24·S25·S26 = 출력 없음(주석도 센다 — 규칙 17) · S32 = 9글자 집합 안. (4) 뒤에는 커밋을 더할 수 없으니(amend·rebase 금지) 여기서 고친다.
     🔴 packages/domain_contracts 에서 dart test test/contracts/c42_r12_screen_scan_test.dart 를 한 번 돌려 C-42 ①~⑬ 통과를 확인한다(출력의 «C-42 ① 대상 S7-7(R12c) 1파일» 줄 · 실패면 고친다).
 (3) 골든 10장 — test/golden/s77_golden_test.dart. 커밋 «[M7] R12c (3) 골든 s77_* 10장»
 (4) melos.bat run format:fix · 질문 파일(S7-7_questions.md — 골든 dy 측정 행 A1~A5 · 그 밖의 질문) · 커밋 «[M7] R12c (4) format · 질문 파일»
     🔴 (4) 뒤에 다른 커밋을 더하지 않는다(format 수정도 (4) 커밋 안에 — 제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지).
     🔴 커밋 순서·제목은 이대로(질문 파일은 (4) 에 · (4) 뒤에 «(4b)» 를 만들지 않는다 — R11b 1회차 C4b-1).

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S29·S30 과 대조)
 🆕 사슬 테스트의 «없는 쪽» 은 위 규칙 11 의 «사슬의 «없는 쪽» 견본» 꼴(else 짝)로만 쓴다 — else 없는 if = 반려(R12b 1회차 C12b-1 · R11b C4b-5 — 같은 꼴 두 번).
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future ·
  시계 = FixedClock(kGoldenNowUtc)(둘 다 test/golden/golden_support.dart 에 있다 — testing.dart 가 아니다 · 오래됨은 FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))) · 기대 글자는 픽스처에서 · 픽스처는 golden_support.dart 의 singleFixture/fixtureEnvelope 로만 읽는다 ·
  값 단언 전 pump() 한 번 더(Future·안전 스트림이 도착할 틈) · 탭 뒤에는 pumpAndSettle()(InkWell 물결).
  🔴 경우가 여럿인 테스트(«…마다» · «루프로» — T77-02·03·04·05·07·08·11·12·13·15)는 for 로 testWidgets 를 경우마다 만든다
     (이름 = '<번호> <설명> <경우 이름>' · 예 'T77-07 section cards in order first_year' · 경우 이름 = 2026 · first_year · offwindow · fresh · stale · row0 · row3 · row4 ·
      ⓡ·ⓗ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 경우 수와 무관하다).
     pumpAnnualReview 는 한 테스트에서 한 번만 부른다(한 테스트 안에서 픽스처를 바꿔 다시 띄우지 않는다 — State(_cfOpen)·프로바이더 값이 남는다).
     기대 수 = 뷰 33개(T77-01 1 · 02 3 · 03 3 · 04 3 · 05 3 · 06 1 · 07 3 · 08 2 · 09 1 · 10 1 · 11 2 · 12 3 · 13 3 · 14 1 · 15 3 · testWidgets( 줄 15) · 드라이런 «+33: All tests passed!».
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순 — R11b goal_path_view_test.dart 의 꼴):
     import 'dart:async'; → import 'dart:io'; →
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
     import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/src/widgets/analytics_error_view.dart'; →
     import 'package:ui_analytics/src/widgets/analytics_skeleton.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
     import 'annual_review_fakes.dart'; → import 'golden/golden_support.dart';
  🆕 test/annual_review_fakes.dart(새 파일 · 공개 이름 · 🔴 한국어 리터럴 0 · explore_fakes.dart 는 import 만 · 머리 주석·import 꼴 = goal_path_fakes.dart 1~16행):
    import 'dart:async'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
    import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
    import 'explore_fakes.dart' show FakeSafetyRepository; → import 'golden/golden_support.dart';
    (FakeSafetyRepository(SafetyState state) — 위치 인자 하나 · R10b · 고치지 않는다 · FixedClock·kGoldenNowUtc·fixtureEnvelope 는 golden_support.dart 에서)
    class FakeAnnualReviewRepository extends UnimplementedPerformanceRepository {
      FakeAnnualReviewRepository({AnnualReviewVm? vm, Object? error, Completer<AnnualReviewVm>? completer})   ← 셋 중 정확히 하나를 준다(테스트가 정한다)
      final List<String?> annualReviewCalls = <String?>[];    ← 받은 year 를 호출마다 더한다(null 도 그대로 더한다)
      final List<String> afterTaxLadderCalls = <String>[];    ← 받은 fiscalYear(부르면 안 되는 창구 — 기록만 하고 Future<AfterTaxLadder>.error(UnimplementedError('afterTaxLadder')))
      final List<String> monthlyReportCalls = <String>[];     ← 받은 yyyyMm(부르면 안 되는 창구 — 기록만 하고 Future<MonthlyReport>.error(UnimplementedError('monthlyReport')))
      annualReview({String? year}) = 기록 → completer 가 있으면 completer.future / error 가 있으면 Future<AnnualReviewVm>.error(error) / 아니면 Future<AnnualReviewVm>.value(vm!)
      afterTaxLadder({required String fiscalYear}) · monthlyReport(String yyyyMm) = 위 두 줄(받침대의 시그니처 그대로 override)
    }   (completer 는 로딩을 멈추는 한 테스트에서만 — 그 테스트는 한 번만 부른다)
    List<Override> annualReviewOverrides({required FakeAnnualReviewRepository repo, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 4개(analyticsClockProvider · analyticsLinkOpenerProvider · performanceRepositoryProvider · safetyRepositoryProvider(FakeSafetyRepository(…)))
        · 기본값: 안전 = safetyStates 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 오프너 = 새 RecordingLinkOpener(링크를 단언하려면 opener: 로 넘긴다)
    Future<void> pumpAnnualReview(WidgetTester tester, {required FakeAnnualReviewRepository repo, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 390×2400 · DPR 1.0 · teardown 2 · ProviderScope(overrides: annualReviewOverrides(…)) → MaterialApp(home: Scaffold(body: AnnualReviewScreen())) · 끝에 pump() 1번
    골든은 pumpAnnualReview 를 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: annualReviewOverrides(repo: …), child: const AnnualReviewScreen()), brightness: b, logicalSize: kS77GoldenSize).
  🔴 새 띄우기 도우미는 이 하나뿐(pumpAnnualReview) · 테스트마다 ProviderScope 를 통째로 쓰지 않는다 · 생성자 인자 없음(연도 리터럴 금지).
  🔴 테스트에 한국어 리터럴 0 — 금지어 확인(T77-13)은 유니코드 이스케이프로 쓴다: '\u{CD94}\u{CC9C}'(추천) · '\u{AD8C}\u{C720}'(권유) · '\u{C790}\u{BB38}'(자문) · '\u{C2DC}\u{ADF8}\u{B110}'(시그널)
     (괄호 안의 한글은 이 카드의 설명이다 — 테스트 파일에 옮기지 않는다 · 주석에도).
연간 리뷰 — test/annual_review_view_test.dart
 T77-01 2026 → ⓗ expect(repo.annualReviewCalls, hasLength(1)) 전제 → expect(repo.annualReviewCalls, <String?>[null])(연도 인자 없이) · repo.afterTaxLadderCalls isEmpty · repo.monthlyReportCalls isEmpty ·
        Key('s77-root') 1 · find.text(vm.year) 0(연도 원값을 그리지 않는다) · ⓡ.
 T77-02 배치 사슬 — 세 경우 (2026 · 정상 시계 · 안전 행 0) · (first_year · +3일 · 행 4) · (offwindow · 정상 · 행 3)마다:
        전제 expect(vm.afterTax, isNotNull) · expect(vm.afterTaxCounterfactual, isNotNull) →
        사슬 목록 final List<Finder> chain = <Finder>[]; 를 위 → 아래로 채운다. 조건이 붙는 두 자리는 if/else 문(있는 쪽 = chain.add · 없는 쪽 = findsNothing 단언 하나):
          ⓐ 오래됨 — 있는 쪽 chain.add(find.text(AnalyticsLabels.staleBannerTitle)) + expect(find.ancestor(of: find.text(AnalyticsLabels.staleBannerTitle), matching: find.byType(Scrollable)), findsNothing)
                    / else expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing)
          ⓑ 차단   — 있는 쪽 chain.add(find.text(activeFlags.first.label)) + expect(find.ancestor(of: find.text(activeFlags.first.label), matching: find.byType(Scrollable)), findsNothing)
                    / else expect(find.byIcon(Icons.block), findsNothing)
        → 이어서 chain.addAll: Key s77-year → Key s77-window → Key s77-aftertax → (for i) ValueKey<String>('s77-section-$i') → Key s77-asof.
        사슬의 각 Finder 는 findsOneWidget · 이웃끼리 tester.getTopLeft(…).dy 를 lessThan 으로 잇는다. 세 경우가 ⓐⓑ 양쪽을 한 번 이상씩 지난다
        (ⓐ = first_year 참 / 2026·offwindow 거짓 · ⓑ = first_year(행 4)·offwindow(행 3) 있음 / 2026(행 0) 없음 — 픽스처·경우 목록이 정한다 · 다르면 멈추고 채팅으로) · ⓡ.
        🔴 C4b-12 — 두 ancestor 단언은 «있는 쪽» 안에 있다(배너를 ListView 안으로 옮기면 실패해야 한다).
 T77-03 세 픽스처마다(C4b-14 — Key 자리 글자 == vm 필드): tester.widget<Text>(find.byKey(const Key('s77-year'))).data == vm.yearLabel ·
        tester.widget<Text>(find.byKey(const Key('s77-window'))).data == vm.windowStateLabel · tester.widget<Text>(find.byKey(const Key('s77-asof'))).data == vm.asOf.label ·
        s77-cf-toggle 안 Text 글자 목록 == <String?>[vm.afterTaxCounterfactual!.branchLabel] · find.text(vm.yearLabel) 1 · ⓡ.
 T77-04 세 픽스처마다 — 본문 층: final AfterTaxLadder ladder = vm.afterTax!; ⓗ expect(ladder.steps, hasLength(6)) →
        i 마다 find.descendant(of: find.byKey(const Key('s77-aftertax')), matching: find.byKey(ValueKey<String>('s77-step-$i'))) 1 ·
        그 층 Column 안 Text 글자 목록 == <String?>[step.label, step.valueText, if (step.noteLine != null) step.noteLine](순서까지 · 🔴 find.text 로 세지 않는다) ·
        이어서 따로 도는 루프 for (int i = 1; i < ladder.steps.length; i++) 에서 층 i−1 의 dy < 층 i 의 dy(getTopLeft · lessThan — 받은 순서 · 🔴 if (i >= 1) 금지 — 규칙 11) · 끝 다음 번호 ValueKey<String>('s77-step-${ladder.steps.length}') 0 ·
        반사실 접힌 상태에서 화면 전체의 s77-step- Key 수 == ladder.steps.length
        (find.byWidgetPredicate((Widget w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('s77-step-')) · findsNWidgets(ladder.steps.length)) · ⓡ.
 T77-05 세 픽스처마다 — 세후 블록 글자 전체(반사실 접힘): 전제 expect(ladder.referenceOnlyLabel, isNotNull) →
        tester.widgetList<Text>(find.descendant(of: find.byKey(const Key('s77-aftertax')), matching: find.byType(Text))).map((Text t) => t.data).toList() ==
        <String?>[ladder.branchLabel, for (s in ladder.steps) ...<String?>[s.label, s.valueText, if (s.noteLine != null) s.noteLine],
                  ladder.honestExpectationLine, ladder.basisNote, ladder.referenceOnlyLabel, vm.afterTaxCounterfactual!.branchLabel]
        (갈래 하나만 펼침 · 층 받은 순서 · 정직 기대 → 근거 → 참고치 → 반사실 머리 · 정적 글자 0 · 반사실 몸 0 · 사다리 asOf.label·configHash 0 을 한 번에 증명) · ⓡ.
 T77-06 2026 — 반사실 접힘·펼침: final AfterTaxLadder cf = vm.afterTaxCounterfactual!; 처음: Key s77-cf 1 · Key s77-cf-toggle 1 ·
        find.descendant(of: find.byKey(const Key('s77-cf')), matching: find.byKey(const ValueKey<String>('s77-step-0'))) 0 · find.text(cf.honestExpectationLine) 0 →
        s77-cf-toggle 탭 → pumpAndSettle → ⓗ expect(cf.steps, hasLength(6)) → i 마다 s77-cf 아래 ValueKey<String>('s77-step-$i') 1 · 그 안 글자 목록 == [label, valueText, noteLine?] ·
        s77-cf 아래 Text 글자 목록 전체 == <String?>[cf.branchLabel, …층 글자…, cf.honestExpectationLine, cf.basisNote, cf.referenceOnlyLabel] ·
        화면 전체 s77-step- Key 수 == vm.afterTax!.steps.length + cf.steps.length(합치지 않고 따로 쌓았다) →
        다시 탭 → pumpAndSettle → s77-cf 아래 s77-step-0 0 · s77-cf 아래 Text 글자 목록 == <String?>[cf.branchLabel] · ⓡ.
 T77-07 세 픽스처마다 — 섹션: ⓗ expect(vm.sections, hasLength(4)) → i 마다 ValueKey<String>('s77-section-$i') 1 ·
        그 카드 안 Text 글자 목록 == <String?>[section.title, ...section.lines, if (section.route != null) AnalyticsLabels.detailButton](순서까지) ·
        이어서 따로 도는 루프 for (int i = 1; i < vm.sections.length; i++) 에서 섹션 i−1 의 dy < 섹션 i 의 dy(🔴 if (i >= 1) 금지 — 규칙 11) · 끝 다음 번호 ValueKey<String>('s77-section-${vm.sections.length}') 0 ·
        route 가 있으면 그 카드 아래 find.byType(TextButton) 1 / 없으면 0(양쪽 다 — 2026·offwindow 가 양쪽 · first_year 는 없는 쪽만) · ⓡ.
 T77-08 2026 · offwindow 마다: 전제 expect(vm.sections.first.route, isNotNull) → find.descendant(of: find.byKey(const ValueKey<String>('s77-section-0')), matching: find.byType(TextButton)) 탭 →
        pumpAndSettle → opener.opened == <String>[vm.sections.first.route!] · ⓡ.
 T77-09 로딩 — completer 가짜 · 안전 행 3 → AnalyticsSkeleton 1 · find.byType(CircularProgressIndicator) 0 · find.byType(LinearProgressIndicator) 0 · Key s77-year 0 ·
        그 플래그 label 글자 각 0 · find.text(AnalyticsLabels.staleBannerTitle) 0(🔴 로딩에는 배너 없음 — 규칙 8) · ⓡ.
 T77-10 에러 — error 가짜 · 안전 행 3 → retryButton 1 · tester.widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView)).lastAsOfLabel == null ·
        그 플래그 label 글자 각 0 · Key s77-year 0 → retryButton 탭 → pump → ⓗ expect(repo.annualReviewCalls, hasLength(2)) · expect(repo.annualReviewCalls, <String?>[null, null]).
 T77-11 2026 — 시계 두 경우(fresh = kGoldenNowUtc · stale = +3일)를 루프로: 오래됐으면 find.text(AnalyticsLabels.staleBannerTitle) 1 +
        find.ancestor(of: find.text(AnalyticsLabels.staleBannerTitle), matching: find.byType(Scrollable)) 0 / 아니면 find.text(AnalyticsLabels.staleBannerTitle) 0(양쪽 다) · ⓡ.
 T77-12 2026 — 안전 행 0·3·4 마다(경우마다 testWidgets): ⓗ expect(activeFlags, hasLength(<0 · 2 · 1>)) → 플래그마다 그 label 글자 1 +
        find.ancestor(of: find.text(그 label), matching: find.byType(Scrollable)) 0(C4b-12) ·
        find.byIcon(Icons.block) — 플래그 0 이면 findsNothing / 있으면 findsNWidgets(<행 3 = 2 · 행 4 = 1>)(양쪽 다 · R11b T79-15 와 같은 위젯) ·
        탭 — 행 4 만 find.byIcon(Icons.chevron_right) 탭 → pump → opener.opened == <String>[행 4 의 activeFlags.single.clearDeepLink!] /
        행 0·3 은 탭하지 않고 expect(opener.opened, isEmpty)(양쪽 다) · ⓡ.
 T77-13 세 픽스처마다(안전 행 0 · 정상 시계 = 도우미 기본값 — 배너 글자 0) — 화면 글자 허용 집합(반사실 펼친 채): 전제 expect(vm.afterTaxCounterfactual, isNotNull) → s77-cf-toggle 탭 → pumpAndSettle →
        화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있고 · 각 data 에 금지어 넷(위 이스케이프)이 없다 —
        집합 = vm.yearLabel · vm.windowStateLabel · vm.asOf.label + 두 사다리(afterTax · afterTaxCounterfactual)의 branchLabel · 층 label · valueText · noteLine(있으면) ·
        honestExpectationLine · basisNote · referenceOnlyLabel(있으면) + 섹션의 title · lines + AnalyticsLabels.detailButton
        (🔴 사다리의 asOf.label · configHash · year · windowStateCode · section.code 는 집합에 넣지 않는다 — 그리면 실패해야 한다 · 화면이 지은 글자 = 0 · 03 §12 「금지」 ②⑤ · 수용 (b)(d)) · ⓡ.
 T77-14 파일 검사 — File('lib/src/screens/annual_review_screen.dart') 원문(주석 포함)에
        RegExp('ReviewSectionVm|changeWindowNoticeText|oathText|KeyValueVm|AsOfStamp|afterTaxLadder|OpsStatusRepository|monthlyReport|ExpansionTile') 가 없다 ·
        Directory('lib/src/annual_review').existsSync() == false · File('lib/ui_analytics.dart') 의 export 경로 목록(RegExp(r"^export '([^']+)';", multiLine: true))에서
        'src/screens/annual_review_screen.dart' 와 같은 것만 모은 목록 == <String>['src/screens/annual_review_screen.dart'](정확히 한 줄 · 🔴 hasLength 를 쓰지 않는다) ·
        'annual_review/' 를 품은 export 0(exports.any(…) isFalse).
        (🔵 배럴 전체의 «정확히 N» 은 R12d 몫 — 이 카드는 자기 줄 하나만 본다.)
 T77-15 세 픽스처마다(안전 행 0 = 도우미 기본값 — 🔴 차단 배너는 clearDeepLink 가 있으면 IconButton(chevron_right)을 그리므로 행 0 이 전제다) — 실행·승인 성격 위젯 0(03 §12 「금지」 ④ · 수용 (a)): find.byType(FilledButton) 0 · ElevatedButton 0 · OutlinedButton 0 · IconButton 0 · Checkbox 0 · Switch 0 · Radio 0 ·
        find.byType(TextButton) findsNWidgets(<route 가 있는 섹션 수 — 테스트가 vm.sections 에서 센다 · 2026 1 · first_year 0 · offwindow 1>) · ⓡ.
 (T77 에 없는 번호는 없다 — 01~15.)
 ⓡ 기대 = annual_review_view_test.dart 13줄(T77-01·02·03·04·05·06·07·08·09·11·12·13·15) · ⓗ 기대 = 6줄(T77-01·04·06·07·10·12) — 드라이런 S29 «test/annual_review_view_test.dart:13» · S30 «test/annual_review_view_test.dart:6» ·
   🔴 정확히 이 수(다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 — 규칙 11).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 연도 줄 빼기 · 창 상태 줄 빼기 · 연도와 창 상태 순서 바꾸기 · s77-year 자리에 windowStateLabel(글자 맞바꿈 · C4b-14) ·
   annualReview(year: …) 처럼 연도 넘기기 · afterTaxLadder 따로 부르기 · 세후 블록을 섹션 뒤로 · 층 하나 건너뛰기 · 층 순서 뒤집기 · noteLine null 에 빈 Text ·
   정직 기대와 근거 순서 바꾸기 · referenceOnlyLabel 빼기 · 반사실 기본 펼침 · 반사실 토글이 다시 안 접힘 · 반사실 층을 본문 층 목록에 이어 붙이기 · 반사실 머리에 정적 글자 ·
   섹션 순서 뒤집기 · 섹션 lines 첫 줄만 · route 없는 섹션에 버튼 · 버튼이 그 섹션의 route 가 아닌 글자를 연다(다른 필드·조립한 글자 — T77-08) · 로딩·에러에 차단 배너 그리기 · 에러를 스켈레톤으로 · 로딩에 스피너 ·
   배너를 ListView 안으로(C4b-12) · 차단 배너 링크를 열지 않기 · 하단 기준일 빼기 · 사다리 asOf.label 그리기 · 화면이 지은 글자 하나(예 정적 «연간 리뷰») · 「적용」 버튼 하나.
   (🔵 «버튼이 늘 첫 섹션의 route 를 연다» 는 이 목록에 없다 — annual 3벌은 route 가 섹션 0 에만 있어 현 픽스처로는 바른 코드와 구별되지 않는다(드라이런 확인 · 01 §8 미결 94 섹션 표본 몫) · C4 가 적용하지 않는다.)

■ 정적 묶음 — packages/ui_analytics 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 37줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로(줄 수가 많아도 · «길어서 줄였습니다» 같은 주의 문장으로 갈음하지 않는다 · R12a C12a-2).
  🔴 **테스트 이름·패키지 이름 한 낱말이라도 다르면 반려 — 대조에서 빼는 것은 빈 줄·EXIT 표기·warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐**(R12a 2회차 C12a2-1 — 다시 돌린 출력을 채팅 글로 옮기다 테스트 제목의 패키지 이름 한 낱말이 바뀌어 반려).
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(이 절 끝 «이어서 packages/domain_contracts 에서» 의 C-42 dart test · «■ 제출» 의 flutter test 세 줄 · Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 → <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 — PowerShell 5.1 에서 warning 줄 때문에 차이 0 이어도 EXIT:False 가 찍힐 수 있다 ·
  «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명·백틱·앞머리 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/annual_review_view_test.dart test/annual_review_fakes.dart test/golden/s77_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/annual_review_view_test.dart test/golden/s77_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/annual_review_view_test.dart test/golden/s77_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (C-42 9a)"; git grep -nE "\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S03b sort filter reverse 0 (C-42 9b)"; git grep -nE "\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|reverse: *true" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes 0 (annual)"; git grep -n "AppRoutes" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S05 opener lines annual (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 number formatting 0"; git grep -nE "toStringAsFixed|toStringAsPrecision|NumberFormat" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 old draft names and other windows 0 (annual)"; git grep -nE "ReviewSectionVm|changeWindowNoticeText|oathText|KeyValueVm|AsOfStamp|afterTaxLadder|OpsStatusRepository|monthlyReport|CommandApi|ExpansionTile" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S15 autoDispose lines"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "annual_review/|goal_path/|chart/|explore/|planner|perf_chart|widgets/|rebalance/|execution_gap/" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16c annual export 1"; git grep -n "annual_review" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint" -- lib; echo "EXIT:$?"
echo "## S25 decimal literal and percent string 0 (C-42 6 annual)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%[^'\n]*'" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea 0 (annual)"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 raw fields 0 (C-42 2 3 annual)"; git grep -nE "\.(year|windowStateCode|code|stepCode|cagrPct|endMult|branch|isReferenceOnly|configHash|kind|mode|wire|journalTimelineLink|detailDeepLink)\b" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/annual_review_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/annual_review_view_test.dart; echo "EXIT:$?"
echo "## S31 providers R12c section lines"; git grep -nE "R12c|annualReview" -- lib/src/providers/analytics_providers.dart; echo "EXIT:$?"
echo "## S32 s77 key glyphs (annual)"; git grep -noE "s77-[a-z-]+" -- lib/src/screens/annual_review_screen.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) ·
   S03·S03b = 받은 글자·순서 그대로(C-42 ⑨ 와 같은 낱말 · 주석도 센다) · S04 = 출력 없음(이 카드가 쓰는 AppRoutes 상수 0) ·
   S05 = 2줄(SafetyBlockBanner(onOpenLink:) 자리 1 · 섹션 「자세히」 onPressed 자리 1 · 줄 번호는 짜임에 따라 다르다) — 둘 다 build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) ·
   S06~S12 = 출력 없음 · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐(R12a·R12b 병합본과 같다 · annual_review_screen 0) ·
   S14 = 출력 없음 · S15 = 대소문자 구분 · 8줄(R12b 병합본 + annualReviewProvider 1 · 설계서 E12 «R12c 8») · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = 12줄(R12b 병합본 + 1 · 🔵 «정확히 N» 은 R12d 몫 — 이 카드의 기준은 S16c 와 «R12b 병합본 + 1») ·
   S16c = 1줄(export 'src/screens/annual_review_screen.dart'; · analytics_providers 줄 바로 다음 · contribution_screen 줄 바로 앞) ·
   S17·S18·S18b = R10·R11 차트 파일 무변경 · S19~S23 = 12항의 1·3·11항 근거(S22·S23 = 11항 보강 — 계약 테스트 C-38 ⑫ 와 같은 정규식 · S19 는 허용 밖 import 줄만 찍는다 — 출력 0 이 정상) ·
   S24 = 폐기·금지 이름 0 · S25 = C-42 ⑥ 과 같은 소수 리터럴 정규식 + % 문자열 0(Card elevation 0.5 를 본뜨면 여기서 1건) · S26 = 공개 위젯은 본문만(ScaffoldMessenger 도 1건) ·
   S27 = 공용 파일의 «끝 절 더하기만» — 2줄(analytics_providers.dart · ui_analytics.dart)의 둘째 수(삭제)가 0 · labels.dart 줄은 나오지 않는 것이 정상(이 카드는 라벨 0) ·
     첫째 수 = providers 7 · 배럴 1(드라이런 · 차이가 나면 PR 본문에 까닭 — 기준은 둘째 수 0) ·
   S28 = 출력 없음(읽지 않는 필드 — 규칙 5) · S29·S30 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 정확히 같아야 한다(13 / 6 · 다르면 반려 — 규칙 11) ·
   S31 = 3줄(머리 줄 // ── 🆕 R12c — S7-7 ── · annualReviewProvider 선언 줄 · .annualReview() 호출 줄 — 주석에 R12c·annualReview 낱말을 쓰지 않으면 이 셋뿐 · 규칙 17) ·
   S32 = 줄마다 «…:<줄>:s77-…» — 글자 부분의 집합이 정확히 {s77-root · s77-year · s77-window · s77-aftertax · s77-step- · s77-cf · s77-cf-toggle · s77-section- · s77-asof} 아홉(줄 수는 짜임에 따라 다르다 · 표 밖 글자 1개라도 = 반려))
  이어서 packages/domain_contracts 에서(정적 묶음과 별도 · 출력 중 아래 줄만 ② 에 그대로 붙인다):
    cd ../domain_contracts
    dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded
       ← «C-42 ① 대상 S7-7(R12c) 1파일 — …» 로 시작하는 줄과 그 다음 줄(«    lib/src/screens/annual_review_screen.dart»)·«C-42 ① 역할 대상 합 …» 줄을 그대로 · 끝 줄 «All tests passed!» 확인 ·
         역할 대상 합·providers R12 절 줄 수 = R12b 병합본 + 1파일 · + R12c 절 줄 수(드라이런 «역할 대상 합 4파일 · providers R12 절 45줄» — 앞 카드 병합본에 따라 다를 수 있다 · 기준은 «S7-7(R12c) 1파일» 줄과 «All tests passed!»)
    cd ../ui_analytics

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · 설계서 §3-5 R12c 5행 그대로 · golden README «🆕 R12» 절 R12c 행)
  이름 · 입력 · 상태:
    s77_december              FixturePaths.m7M7Annual2026       화면 전체 · 반사실 접힘
    s77_first_year            FixturePaths.m7M7AnnualFirstYear  화면 전체 · 반사실 접힘(섹션 버튼 0)
    s77_offwindow             FixturePaths.m7M7AnnualOffwindow  화면 전체 · 반사실 접힘
    s77_aftertax_ladder_spec  FixturePaths.m7M7Annual2026       세후 블록 Key 영역만(Key('s77-aftertax') · 반사실 접힘)
    s77_aftertax_ladder_cf    FixturePaths.m7M7Annual2026       세후 블록 Key 영역(Key('s77-aftertax') · s77-cf-toggle 1회 탭 = 반사실 펼침)
  모두 띄운다(게이트 없음) · 안전 상태 = 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 크기 390 × 1440(테스트 파일 안 상수 const Size kS77GoldenSize = Size(390, 1440) ·
  기본 폰 높이 844 로는 모자란다 — 반사실을 펼친 세후 블록까지 들어가는 높이로 드라이런이 정한 카드 확정값 · 다섯 이름이 같은 상수를 쓴다).
  모양(s79_golden_test.dart 꼴 · testWidgets( 줄 3개):
    final List<(String, String)> screens = <(String, String)>[ ('s77_december', FixturePaths.m7M7Annual2026), ('s77_first_year', FixturePaths.m7M7AnnualFirstYear),
                                                               ('s77_offwindow', FixturePaths.m7M7AnnualOffwindow) ];
    for (name, path) in screens × for (b in Brightness.values): testWidgets('$name ${brightnessSuffix(b)}', …)   ← 화면 전체
      pumpForGolden(tester, ProviderScope(overrides: annualReviewOverrides(repo: FakeAnnualReviewRepository(vm: vm)), child: const AnnualReviewScreen()), brightness: b, logicalSize: kS77GoldenSize)
      → await tester.pumpAndSettle()
      → expect(tester.getBottomLeft(find.byKey(const Key('s77-asof'))).dy, lessThan(kS77GoldenSize.height));   ← 맨 아래 = 하단 기준일
      → await expectGolden(name, b);
    for (b in Brightness.values):
      testWidgets('s77_aftertax_ladder_spec ${brightnessSuffix(b)}', …)   ← 영역 · 탭 없음
      testWidgets('s77_aftertax_ladder_cf ${brightnessSuffix(b)}', …)     ← 영역 · pumpAndSettle 뒤 await tester.tap(find.byKey(const Key('s77-cf-toggle'))) 1회
      두 테스트 모두: pumpForGolden(같은 모양 · 2026) → pumpAndSettle → (cf 만 탭 → pumpAndSettle) →
        expect(tester.getBottomLeft(find.byKey(const Key('s77-aftertax'))).dy, lessThan(kS77GoldenSize.height));   ← 맨 아래 = 세후 블록 아래 끝
        → await expectLater(find.byKey(const Key('s77-aftertax')), matchesGoldenFile('goldens/<이름>_${brightnessSuffix(b)}.png'));
           (<이름> = s77_aftertax_ladder_spec · s77_aftertax_ladder_cf — 글자 그대로 · 🔴 영역 골든은 이 한 줄만 · golden_support.dart 는 고치지 않는다 ·
            s77-aftertax 카드가 ListView 의 직접 자식이라 Flutter 가 그 자식마다 두는 RepaintBoundary 가 곧 그 카드의 그림이다 — 위 «화면» 5 의 배치를 바꾸면 영역이 달라진다)
    골든 파일 import(directives_ordering · s79_golden_test.dart 꼴):
       import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
       import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/ui_analytics.dart'; → import '../annual_review_fakes.dart'; → import 'golden_support.dart';
    테스트 이름에 한국어 0 · 🔴 cf 테스트의 탭은 if 없이 그 testWidgets 안에 한 번(경우 분기를 if 로 만들지 않는다).
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s77_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 의 ?? 는 test/golden/s77_golden_test.dart 1줄 + 새 PNG 10줄(s77_*)뿐 · M 0(커밋 (3) 전)
  🔴 다른 골든 테스트 파일을 --update-goldens 에 넣지 않는다(기존 PNG 재생성 = 이 카드에 없다).
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다(높이 상수는 드라이런이 정한 카드 확정값이다).
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s77_golden_test.dart 의 위치 전제 세 곳(화면 전체 루프 1 · 영역 2)의 lessThan(kS77GoldenSize.height) 를 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/s77_golden_test.dart(--update-goldens 없이)
    → 테스트 이름('s77_december light' … 10개)마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- test/golden/s77_golden_test.dart 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 골든 비교보다 먼저라 실패해도 PNG 는 쓰이지 않는다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다)
· S7-7_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 골든·세후 블록 질문도 여기에.
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A5 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  권고와 다르게 지은 이름 · 문서에 없어 정한 것 전부 · 픽스처 모순(고치지 말고 적는다).
    | A1 | R12c-Bob-S77 | 추측 | 측정: s77_december dy 실측값 (light=<값>, dark=<값> < <높이>) | 골든 위치 전제 실측 | <높이> 미만 확인 | ⬜ 미답 | |
    (A2 = s77_first_year · A3 = s77_offwindow · A4 = s77_aftertax_ladder_spec · A5 = s77_aftertax_ladder_cf · 같은 형식 · <높이> = kS77GoldenSize 의 높이 숫자 · <값> 자리에만 잰 숫자 ·
     A1~A3 = s77-asof 아래 끝 · A4·A5 = s77-aftertax 아래 끝)
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 0 · 반사실 토글 모양(머리 InkWell + 아이콘) · 반사실 층의 Key 재사용 · 읽지 않는 필드 목록(규칙 5) ·
  배치 순서 · 골든 이름·입력·영역 찍는 법 · lib/src/annual_review/ 를 만들지 않은 것 · 재량인 것(여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다((4) 커밋 · 채팅 보고만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(4) 커밋이 끝난 뒤 — (4) 가 마지막 커밋)
  cd packages/ui_analytics
  flutter test test/annual_review_view_test.dart    ← 끝 줄 그대로 적어 둔다(기대 «+33: All tests passed!»)
  flutter test test/golden/s77_golden_test.dart     ← 끝 줄 그대로 적어 둔다(기대 «+10: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄 그대로 적어 둔다)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 수정은 CI 포맷 게이트를 빨갛게 만든다
  git diff --name-status origin/main...HEAD
     ← 🔴 나와야 하는 줄만(순서는 git 이 정한다 · 17줄):
          M docs/ai-context/inbox/S7-7_questions.md ·
          A packages/ui_analytics/lib/src/screens/annual_review_screen.dart · M packages/ui_analytics/lib/src/providers/analytics_providers.dart · M packages/ui_analytics/lib/ui_analytics.dart ·
          A packages/ui_analytics/test/annual_review_fakes.dart · A packages/ui_analytics/test/annual_review_view_test.dart · A packages/ui_analytics/test/golden/s77_golden_test.dart ·
          A packages/ui_analytics/test/golden/goldens/s77_*.png 10줄.
        그 밖의 줄(labels.dart · 기존 PNG M · 기존 테스트 · 하네스·reference/**·README · R12a·R12b 파일 · domain_contracts/** · pubspec)이 하나라도 있으면 푸시하지 말고 멈춘 뒤 출력을 채팅으로.
  git push -u origin ui/m7-s77-annual
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  git log --oneline origin/main..HEAD         ← 아래 ① 에 그대로 붙일 출력(4줄 — 맨 위 = (4))
  cd packages/ui_analytics → 위 «정적 묶음» 37줄 → C-42 ① 줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  12항 원문 대조(출력은 붙이지 않는다 — 아래 ② 상자와 한 글자씩 대조용):
    Git Bash   : sed -n '156,170p' docs/ai-context/prompt_M7.md   ·   sed -n '156,170p' docs/ai-context/prompt_M7.md | wc -l   ← «15»
    PowerShell : (Get-Content -Encoding UTF8 docs/ai-context/prompt_M7.md)[155..169]   ·   ((Get-Content -Encoding UTF8 docs/ai-context/prompt_M7.md)[155..169]).Count   ← «15»
    첫 줄 « 1. `ui_analytics`가 …» · 끝 줄 «    목표 경로 가정 카드가 …» 가 아니면(행이 밀렸으면) 멈추고 채팅으로.
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다(golden:approved 포함) · PR 본문을 GitHub 에서 고치지 않습니다(통합 담당이 아래 채팅 글로 통째로 쓴다).
  PR 제목: [M7] S7-7 12월 연간 리뷰
  제출 글 = 채팅으로 아래 상자의 섹션 머리 다섯 줄을 **글자 그대로** 두고 그 아래를 채운다(통합 담당이 이 글로 PR 본문을 통째로 만든다 · 12 §3):
      ┌── 제출 글 머리(다섯 줄 · 글자 그대로)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └──
      (이 다섯 줄은 R12 네 장(R12a~R12d)이 같은 글자다 — 무엇을 어느 섹션에 붙이는지는 아래 ①~⑤ 설명이 정한다)
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 +
      «바뀐 파일:» + 위 git diff --name-status origin/main...HEAD 출력 그대로(코드 블록 하나 · 손으로 쓰지 않음 · A/M · PNG 포함 · 17줄이 정상) +
      «커밋 목록:» + 위 git log --oneline origin/main..HEAD 출력 그대로(코드 블록 하나 · 4줄 · 맨 위 = (4))
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: S7-7 — 12월 연간 리뷰(AnnualReviewScreen · 라우트 reportAnnual 배선은 셸 R13 몫)
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 12항이 15줄 그대로인지 셉니다 — 11번·12번은 각각 3줄·2줄(들여쓰기 4칸 줄 포함)이고, 한 줄로 잇지 않습니다(R11a 2회차에 틀린 곳 · 줄을 이으면 = 보고 불일치) ·
         세는 명령(붙일 12항 15줄만 저장소 밖 임시 파일에 붙여 넣고):
         PowerShell: (Get-Content "$env:TEMP\r12c_item12.txt" -Encoding UTF8).Count   ← 15
         bash:       wc -l < "$TEMP/r12c_item12.txt"                                  ← 15(끝 줄 뒤 줄바꿈이 있을 때)
         (🔴 15 가 아니면 붙인 글을 고친다 · 이 명령의 출력 한 줄도 ② 에 붙인다 — 꼴은 아래 견본)
         🆕 ② 에 붙이는 꼴 = 아래 견본처럼 명령의 **출력 한 줄만** 코드 블록 하나로(명령 줄은 붙이지 않는다 · «….Count = 15» 처럼 명령과 잇지 않는다 · R12b 1회차 C12b-7 · 수는 실제 출력 그대로):
      ┌── 세는 줄 견본(출력 한 줄)
15
      └──
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다(R10a · R10b 1회차에 틀린 곳).
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음 결과의 수):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «S7-7 화면 파일 산술 0 · 층·섹션·줄은 받은 순서 그대로(정적 S03·S03b — 0건 · T77-04·T77-07)»
        3번 = «정적 묶음 S20 — 0건»
        4번 · 5번 · 6번 · 7번 · 8번 = «이 카드 범위 밖»
        9번 = «as-of 는 연간 리뷰 화면 하단 1줄(s77-asof · 03 §12 계약 v1.6 블록 ③ 이 이긴다) · 오래됨 배너 = 화면 맨 위 StaleBanner(스크롤 밖 · T77-11)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 기존 PNG M 0 · 새 PNG s77_* 10장만 · domain_contracts 변경 0»
        11번 = «정적 묶음 S21 결과 <N>건 · 보강 S22 결과 <N>건 · S23 결과 <N>건 · S25 결과 <N>건»
        12번 = «앞 두 절 본문 갈래 하나(s77-aftertax) · 반사실 접힘(s77-cf · T77-06) · 층 = steps 받은 순서(T77-04·T77-05) / 뒷절 이 카드 범위 밖(목표 경로)»
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
      이어서 «정적 묶음 출력:» + 37줄 출력 전부와 C-42 ① 줄을 코드 블록 하나로 그대로 +
      «S05 결과:» 다음 줄부터 S05 출력 2줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄(괄호·백틱·앞머리·설명·줄 끝 빈칸 금지 · 줄을 빼거나 줄이면 = 보고 불일치) +
      ⓡ·ⓗ = 아래 상자의 글자 틀 그대로(<…> 자리에만 정적 묶음 S29·S30 출력 줄을 그대로 복사 · test/ 를 떼지 않는다 · 손으로 쓰지 않는다 · R12a C12a-6):
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = S29 출력:
<S29 출력 줄 그대로>
ⓗ = S30 출력:
<S30 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — 아래 복사 상자를 annual_review_screen.dart 와 대조한 뒤 글자 그대로 + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤).
      🔴 대조 기준 = 렌더 순서(build 가 그리는 순서 = 카드 «화면» 배치 1~7) — 소스 파일의 글자 순서가 아니다. private 메서드(_buildStep · _buildSection 등)는 호출 자리에서 펼쳐 읽는다
         (s77-step-$i 는 본문 층 호출 자리와 반사실 펼친 몸의 호출 자리마다 한 번씩 · s77-section-$i 는 섹션 호출 자리).
         렌더 순서가 상자의 나열과 다르면 상자를 고쳐 쓰지 말고 멈춘 뒤 채팅으로(코드를 카드 «화면» 배치 1~7 에 맞춘다 — 상자는 카드 확정값이다).
         «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어를 더하지 않는다(R10c 1회차 반려 사유).
      ┌── ③ 복사 시작(다음 줄부터)
**로딩**: `AnalyticsSkeleton`(배너 없음)

**정상**: `Key('s77-root')` → `StaleBanner`(있을 때) → `SafetyBlockBanner`(있을 때) → `Expanded(ListView)` → `Key('s77-year')` → `Key('s77-window')` → `Key('s77-aftertax')`(있을 때) → `ValueKey<String>('s77-step-$i')` → `Key('s77-cf')`(있을 때) → `Key('s77-cf-toggle')` → `ValueKey<String>('s77-step-$i')`(펼쳤을 때) → `ValueKey<String>('s77-section-$i')` → `Key('s77-asof')`

**첫 해**: `Key('s77-root')` → `StaleBanner`(있을 때) → `SafetyBlockBanner`(있을 때) → `Expanded(ListView)` → `Key('s77-year')` → `Key('s77-window')` → `Key('s77-aftertax')`(있을 때) → `ValueKey<String>('s77-step-$i')` → `Key('s77-cf')`(있을 때) → `Key('s77-cf-toggle')` → `ValueKey<String>('s77-section-$i')`(「자세히」 0) → `Key('s77-asof')`

**차단**: `SafetyBlockBanner` 위치 = `StaleBanner` 아래 · `Expanded(ListView)` 바깥 위(값이 온 뒤의 `Column` 둘째 자식) · 세후 블록은 가리지 않는다
      └── ③ 복사 끝(이 줄 앞까지)
      골든 표 10행: 이름 · 입력 픽스처 · 크기 · 위치 전제 dy · 배치·잘림 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m7/m7_annual_2026.json — 상수 이름과 섞지 않는다) ·
        크기 = 화면 전체 3이름은 390×<높이> · 영역 2이름은 «영역 s77-aftertax(390×<높이> 화면 안)» ·
        dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다 · 질문 파일 A1~A5 와 같은 숫자) ·
        배치·잘림 = PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 글자 내용·글자 길이의 차이는 쓰지 않는다(위 보고 규칙 🆕 줄) · 못 본 것은 «미열람») ·
        🆕 «띠» · «고정» · «스크롤 밖» · 색·테마 이름처럼 정지 PNG 에서 보이지 않는 말 금지(위 보고 규칙 🆕 줄 · R12b C12b-6).
   ④ 질문 목록 — 머리 «S7-7 새 행:» 다음 줄에, 아래 명령 출력에서 «+|» 로 시작하는 줄 전부를 코드 블록 하나로 그대로(이 카드가 질문 파일에 더한 새 행 전부 — 측정 행 포함 · 앞의 + 와 줄 순서 그대로 · 줄을 고르거나 고쳐 쓰지 않는다 · 요지 표를 손으로 만들지 않는다 — R12a C12a-4 · R11b C4b-2):
      git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/S7-7_questions.md   ← 저장소 뿌리에서 · 푸시한 그 커밋 위에서 · «+++ b/…» 줄은 넣지 않는다(표 행만)
      (셸에서 한글이 깨져 보이면 PowerShell 에서 [Console]::OutputEncoding = [Text.Encoding]::UTF8 를 한 번 돌린 뒤 다시 돌린다 — 출력을 손으로 고쳐 쓰지 않는다)
   ⑤ 추측한 것 = S7-7_questions.md 의 새 A 행 중 «측정:» 이 아닌 행 전부 — 파일 접두를 붙인 번호로(예 S7-7 A6)(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
   (+ 까닭 줄 — 아래 수가 이 카드의 기대와 다를 때만 한 줄씩: «까닭(<무엇>): <사실>» · 테스트별 수·줄 번호는 위 명령 출력 그대로만 쓴다(손으로 세지 않는다))
   (+ flutter test 세 줄 — 아래 상자의 글자 틀 그대로(기대 끝 = N + 43 · 수를 따로 계산해 덧붙이지 않는다):
      ┌── flutter test 세 줄 복사 시작(다음 줄부터 · 3줄 · <…> 자리에만 출력 그대로)
flutter test(view): <test/annual_review_view_test.dart 끝 줄 그대로>
flutter test(golden): <s77_golden_test.dart 끝 줄 그대로>
flutter test: 시작 기준 <N> → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>
      └── flutter test 세 줄 복사 끝(이 줄 앞까지 · 끝 자리 예 = R12a «끝 00:16 +354: All tests passed!» 꼴 — 시각·«+수»·«All tests passed!» 까지 출력 끝 줄 그대로 · «끝 354» 처럼 수만 쓰지 않는다 · R12a C12a-6))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s77-annual` 푸시 1건 · 커밋 4개(본문 (1)~(4) · **(4) format·질문 파일이 마지막**).
- `lib/` 새 파일 1(`screens/annual_review_screen.dart` · `lib/src/annual_review/` 없음) · 수정 2(`providers/analytics_providers.dart` 끝 R12c 절 `annualReviewProvider` · `ui_analytics.dart` export 1줄(정렬 자리 — providers 줄 다음)). `labels.dart` 변경 0 · 그 밖의 `lib/`(R10 차트 3파일 · 목표 경로 2파일 · 위젯 · 다른 화면 · R11a `planner.dart`·`src/planner/**` · R12a·R12b `rebalance_*`·`src/rebalance/**`)는 바뀌지 않는 것이 정상.
- `test/` 새 파일 3(`annual_review_view_test.dart` · `annual_review_fakes.dart` · `golden/s77_golden_test.dart`) + 새 PNG 10장(`s77_*` — 화면 전체 6 · 영역 4) · 수정 0. 하네스·본보기·다른 골든 테스트·기존 PNG 86장·앞 카드 테스트는 불변.
- 질문 파일 `S7-7_questions.md`(새 행 A1~A5 «측정:» 은 반드시 · 그 밖은 있을 때만).
- 채팅: PR 본문 5섹션(① 머리 1줄 + name-status 17줄 + 커밋 목록 4줄 · ② 복사 상자 12항 15줄 + 괄호 + «정적 묶음» 37줄 출력 + C-42 ① 줄 + S05 2줄 + ⓡ·ⓗ 출력 줄 · ③ 복사 상자 + 골든 표 10행(dy 는 이름·밝기마다) · ④ · ⑤) + flutter test 세 줄.
- `flutter test` = 시작 기준 N(0단계 · R12b 병합본 ⟦실측 — R12b 병합 기록 때 C4 가 채운다 · 드라이런 403 → 446 = R12b 보강 전 판 위 · 보강판 재측정 404(`7272a43`) → 기대 447⟧) + 새 43(뷰 33 + 골든 10) · 정적 S29 = 13 · S30 = 6(🔴 정확히 — 다르면 반려) · S05 = 2줄 · S27 둘째 수 0 · S16c 1줄 · S32 = 9글자 집합.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12c-Bob-S77 결과: 브랜치 ui/m7-s77-annual 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R12c-Bob-S77 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R12c-Bob-S77 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s71_*`·`s71b_*`·`s72g_*`·`s72_*`·`s73_*`·`s73b_*`·`s74_*`·`s79_*`·`s76a_*`·`s76b_*`·`s76c_*`)가 `M` ② `pubspec.yaml`·`labels.dart` 변경 ③ `test/golden/` 하네스·`reference/**`·README 가 `M` ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime.now`·`afterTaxLadder`·`OpsStatusRepository`·`monthlyReport`·`annualReview(year:` ⑤ 세후 수치·`%` 리터럴 · `elevation: 0.5` · `.cagrPct`·`.year`·`.windowStateCode`·`.isReferenceOnly` ⑥ 「적용」·승인·체크박스·서약문 자리·M9 링크 버튼 · 정적 «연간 리뷰»·«반사실» 글자 ⑦ ② 의 S04·S05·S13·S14·S28 출력에 주석 줄·import 줄이 찍힘(규칙 17) · ⓡ·ⓗ 수(S29·S30)가 13 / 6 이 아님 · S32 에 표 밖 `s77-` 글자 — 하나라도 있으면 반려 신호(⑦ 의 표기만의 차이는 strict 나눔 ① 에 따라 C4 정정).
- CI «골든 스냅샷» 잡은 새 PNG(`A`)만 있으면 라벨 없이 초록이 정상입니다(재생성 0 · `golden:approved` 불필요). 기존 PNG `M` 이 보이면 반려 신호입니다.
- 계약 테스트 C-42(③ S7-7 원값 · ④ 호출 역할 표 `annualReview` = S7-7 만 · ⑤ 셸·포맷 낱말 · ⑥ 소수·% · ⑨ 정렬·거르기 · ⑩ 가드 · ⑬ providers R12 절)는 Bob 브랜치가 들어와야 실제 파일을 봅니다 — 병합 검사 때 Claude 가 그 위에서 돌리고, 출력의 «C-42 ① 대상 S7-7(R12c) 1파일» 을 확인합니다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 드라이런 실측: ✅ 2026-10-12(`dry/r12c` @ `78189b0` · 값은 머리 «드라이런» 줄) — 시작 403 → 끝 446(R12b 보강 전 판 위) · `kS77GoldenSize` 390 × 1440 · dy 10개(이름·밝기마다 lessThan(0) 으로 잼) · S05 2줄 · S15 8 · S16b 12 · S27 `7 0`/`1 0` · S31 3 · C-42 ① 합 4파일 · R12 절 45줄 · lib +228(임계 +900 안) · 예고 변이 36종 중 35 잡힘(놓친 1 = «늘 첫 섹션 route» — 픽스처상 동치 · 목록 밖으로 옮김) · 영역 골든 PNG = spec 358×724 · cf 358×1312(세후 카드 하나만 — `RepaintBoundary` 가 ListView 자식 단위 · 눈 확인) · prompt_M7.md 156~170행 = 12항 15줄(e716fe0 판 · 기록 커밋 뒤 다시 확인 — 머리 줄이 늘면 행이 밀린다). 🔴 시작 기준 N 은 R12b 병합본 수로 R12b 병합 기록 때 다시 채운다.
- 범위 고지: 서약문·«규칙 변경은 설정에서» M9 링크(01 §8 미결 93 · K4) · 섹션 8개 표본·섹션별 «산출 불가» 구조 필드·창 상태와 «첫 해» 축 분리·SIM 표본·`reportAfterTax` 단독 화면(미결 94) · `S12` 표시 범위(미결 95) · 셸 라우터 배선(R13)은 이 카드에 없습니다. `S7-10` 은 R12d 입니다.
- 그 밖의 알릴 것은 `_완료/R10a-Bob-S71b.md` «5» 를 참고합니다.
