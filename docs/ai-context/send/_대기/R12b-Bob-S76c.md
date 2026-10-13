# 발송 패킷 R12b-Bob-S76c — S7-6c 다음 리밸런싱 · 지금 기준 초안 (계약 v1.6 · R12 4장 중 2번째)

> ⏸ **아직 보내지 않습니다** — 선행 = R12a 병합(squash `__R12A_SQ__`)과, 이 파일을 `send/_대기/` 에서 `send/` 로 옮기는 R12a 병합 기록 커밋이 GitHub `main` 에 있을 것(이 파일은 R12 조립 기록 커밋 `952b3eb` 이 `send/_대기/` 에 둔다 · Claude 가 R12a 병합을 기록할 때 옮기고 이 줄을 ▶ 로 바꾼다). **R12 4장 중 2번째** · 한 번에 카드 1장 · 순서 고정 R12a → **R12b** → R12c → R12d(앞 카드 병합 뒤 다음 카드).
> 만든 날 2026-10-08 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R12b 행 · R12 행 «v1.6 4분할 공통» · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-08_R12선행_계약v1.6_설계서.md` §2-3 ②③④ · §2-5 · §2-6 · §2-7(S7-6c 행) · §3-1 · §3-5(R12b 5행) · §6 공통 규칙 1~19 + R12b 규칙 24~26 · §7 · 조문 = `01_…` §15-4(15-4-4 · 15-4-7 · 15-4-8 · 15-4-9 · 15-4-18) · `03_…` §11-c 의 «🆕 계약 v1.6 — `S7-6c` R12 범위 · 이 블록이 이긴다» 블록 + §1-4 의 «🆕 계약 v1.6 — R12 범위» 줄 · golden README «🆕 R12(계약 v1.6)» 절.
> 사전 조건 — ✅ 계약 v1.6 병합(M2 PR #25 · squash `995c1f4` — `contractVersion '1.6.0'` · 픽스처 135 · 라우트 45) · ✅ 기록 커밋 `952b3eb`(`prompt_M7.md` 2·3·109·118행 R12 치환 · golden README «🆕 R12(계약 v1.6)» 절 · `inbox/S7-6c_questions.md` 빈 머리말 — K21) · ⬜ **R12a-Bob-S76ab 병합**(squash `__R12A_SQ__` — `S7-6a`·`S7-6b` · `RebalanceTimelineScreen`·`RebalanceEventScreen` · `rebalanceRepositoryProvider`(주입 · 이 카드가 재사용) · 골든 `s76a_*`·`s76b_*` 12장 · `labels.dart`·`analytics_providers.dart` 끝 R12a 절 · 배럴 +2). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 시작 기준 `flutter test`(packages/ui_analytics) = **+354**(누적 드라이런 실측 — R12a 드라이런 끝 · R12a 병합본이 통합 수정으로 달라지면 C4 가 ▶ 로 바꿀 때 이 수를 고친다).
> 카드 확정값(카드 권한): 정적 라벨 2개(본문 «정적 라벨») · Key 표 11개(설계서 §6 규칙 17 의 `S7-6c` 줄 그대로 · 본문 «Key 표») · 프로바이더 2개·화면·파일 이름(본문 «주입 구조» — 이름 = 01 §15-4-18 · 설계서 §6 규칙 5 글자 그대로) · 테스트 가짜·도우미 이름(본문 «테스트 최소 목록») · 골든 5이름 10장(설계서 §3-5 · 크기 390 × 844 — 누적 드라이런 실측 · 가장 깊은 s76c_preview dy 752).
> 🔴 **보내는 조건(Claude 확인)** — R12a PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-6c_questions.md` 가 `main` 에 있음(빈 머리말 — 기록 커밋 `952b3eb` 이 만든다 · K21) + `prompt_M7.md` 치환(0단계 `git grep -c "R12b = S7-6c"` 가 `:2`) + golden README «🆕 R12(계약 v1.6)» 절의 R12b 행(`s76c_*` 5이름 10장 · `kS76cGoldenSize` 390 × 844 — 이 카드 머리 6행과 같은 크기 · 다르면 README 를 고친 뒤 보낸다 · 0단계 `git grep -c "s76c_countdown"` 이 절을 증명) + 🔴 이 파일에 실측 자리표시자(흰 겹꺾쇠 «실측» 표식) 0건(겹꺾쇠 글자 grep -c = 0 — 지금 0) + 🔴 보강분 누적 재드라이런 통과(아래 «드라이런» 줄의 🔴). 0단계의 `ls`·`git grep` 줄이 그 증명입니다.
> 🔴 **기록 커밋 체크리스트(Claude)** — R12a 병합 기록 때 본다: ① `docs/ai-context/inbox/S7-6c_questions.md` 빈 머리말(`952b3eb` 몫 · 다음 번호 Q1·A1 · 표 머리 + 구분줄 · 행 0) ② golden README «🆕 R12» 절 R12b 행(5이름 · 390 × 844) ③ `prompt_M7.md` 2·3·109·118행 치환(2행 = `{{범위}}`·PR 제목 · 3행 = 조립 이력 · 109행 = 범위 · 118행 = PR 제목 — 모두 R12 네 장을 함께 적은 값 · «R12x = » 글자는 2·109행에만 · 171줄 유지) ④ `send/_대기/R12b-Bob-S76c.md` → `send/R12b-Bob-S76c.md` 이동 + 머리 ⏸ → ▶(이동은 R12a 병합 기록 커밋) ⑤ ✅ 재드라이런(2026-10-13 · `dry/r12b-plus` `7272a43`) 결과로 R12c·R12d 머리의 누계 기준을 고쳤다(보강 전 판 위 드라이런 403·446·512 → 보강판 404 실측 · 447·513 = 앞 드라이런 실측 + 1).
> 🔴 **카드 덮개 필수 문장(01 §15-4-4 · 03 §11-c 블록 ② ⑤)** — «`S7-6c` 는 「지금 기준 초안 보기」 **탭 뒤에만** `previewRebalance()` 를 **인자 없이** 부른다 — 진입·`watchNext` 값만으로는 호출 0 · 마지막 요청만 반영» · «뷰어 = 주입 `analyticsWhatIfApiProvider` 가 null = **카운트다운만**(초안 버튼·영역 부재) — 고르는 조건은 주입 null 여부 하나 · `kIsWeb`·`Platform` 0» · «`planner` 낱말 0(lib · 주석 포함)». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» ②⑩⑲ 에 있습니다.
> 결정 표기: 이 카드가 기대는 K2(뷰어 = 주입 null)·K15(표본 «2026년 9월 1일 · D-1»)·K17(조달 절·전후 비중 미표시)·K22(차단 = 배너만)는 **권고 선반영**이다(설계서 §10 · 🔴 K22 는 «확인 필수» 8건 중 하나) — ~~카드·C4 는 K 를 «확정»으로 인용하지 않는다.~~ **✅ 발주자 확정(2026-10-13 «권고대로 확정하고 푸시해» — K1~K26 전부 권고대로 · 01 §15-4-16)** — 뒤집힌 K 0 · 다시 조립 0. Bob 은 이 표기로 멈추지 않는다(카드가 정한 대로 짓는다).
> 드라이런: ✅ **1회**(2026-10-12 · 누적 드라이런 `C:/Work/AAQ-claude-review` · 가지 `dry/r12b` · 밑동 `7f72538`(R12a 드라이런 끝) · 끝 `a62f783` · 카드 본문만 보고 커밋 5개) — 결과 = 아래 «5» 끝 줄 · 놓친 변이 4개 중 3개(결과 캐시 · `s76c-asof` 를 `preview.asOf` 로 · 경고 줄 역순)는 이 판에서 테스트 보강(T76c-05 · T76c-06)으로 막고 1개(초안 행 `Wrap`→`Row`)는 변이 문구를 좁혔다 — 보강분(T76c-05 다시 탭 · `previewCalls` 2 · T76c-06 탭 뒤 `s76c-asof` == 카운트다운 `asOf.label` · 셋째 경우 `in_band_two_warnings` → 뷰 39 → 40)은 `dry/r12b`(`a62f783`) 코드에 없다 → **2026-10-13 재측정 ✅(`dry/r12b-plus` `7272a43`)** — `a62f783` 위 보강 커밋 1개(뷰 테스트 파일 하나만 · lib 0 · 새 `testWidgets(` 줄 0 — 셋째 경우는 for 루프) · 뷰 «+40» · 골든 «+10» · 끝 M = N + 50(354 → 404) · S29 16 · S30 6 · `analyze --fatal-infos` No issues · format 0 changed · 놓쳤던 변이 셋(결과 캐시 · `s76c-asof` 를 `preview.asOf` 로 · 경고 줄 역순) 모두 잡힘(보강 전 `a62f783` 에서는 셋 다 «+39» 통과) → R12c·R12d 머리의 누계 기준을 이 실측 근거로 고쳤다(R12c 시작 404 → 끝 기대 447 · R12d 시작 기대 447 → 끝 기대 513 — 늘어난 1 은 R12b 뷰 파일 안이라 R12c·R12d 드라이런 실측 446·512 에 1 을 더한 값). 재분할 임계(새 `testWidgets(`/`test(` 줄 > 33 · lib > +900 · 새 PNG > 16) = 이 카드 새 줄 20(뷰 19 + 골든 루프 1 · 경우는 for 로 40 + 10) · PNG 10 · lib +325(드라이런 실측) → 재분할 불필요.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 2행 `{{범위}}`·PR 제목 · 109행 범위 · 118행 PR 제목은 기록 커밋이 R12 네 장을 함께 적은 값으로 바꾼다 · 0단계 확인 줄 `git grep -c "R12b = S7-6c"` = `:2`(2행 · 109행) · 🔴 머리 줄 수는 바뀌지 않는다 — 아래 «프롬프트보다 이 카드가 이긴다» 의 행 번호가 그 전제다) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R12a 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 이렇게 쓴다»로 0단계·규칙 요약·본받지 않는 것·주입 구조에 담았습니다.
> R10·R11 교훈 반영: 보고 기계화(② 12항 복사 상자 + 15줄 세는 명령 · «정적 묶음» 출력 그대로 · «테스트 수 묶음» 끝 줄 그대로(12 §3 재발 방지 ①) · ① name-status 출력 그대로 · ③ 위젯·Key 이름 나열) · S05 줄 = «<파일>:<줄> — 탭 콜백 안» 만 · 보강 줄 수는 `git grep -c` 로 대조 · 배치 순서는 사슬 단언 · 조건부 단언 금지 · 공용 3파일은 «시작 기준 + N · 더하기만»(«정확히 N» = R12d 한 곳) · strict 보고 규칙 나눔 · «PR 본문은 통합 담당이 바꾼다»(12 §3 머리) · 단언 보강 C4b-12(배너·고지 «스크롤 밖») · C4b-13 준용(칩 톤 색) · C4b-14(Key 자리 글자 == vm 필드).

## 0. 한 줄 목적

다음 리밸런싱이 언제인지(엔진이 준 D-day 글자 그대로)와, 사용자가 누를 때만 계산되는 «지금 기준 초안»(주문 초안 표 · 예상 비용 · 경고 · 미리보기 고지 · 또는 차단 문장)을 계약 v1.6 그대로 짓기 — 승인·실행 버튼 없이, 뷰어에서는 카운트다운만.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s76c-preview`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **R12a 가 `main` 에 병합된 뒤에 보냅니다** — 이 파일 머리 첫 줄이 ⏸ 이면 아직입니다(Claude 가 R12a 병합을 기록할 때 `send/_대기/` 에서 `send/` 로 옮기고 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R12a 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12b-Bob-S76c.md> (로컬 사본 = Claude 기록 폴더의 `docs/ai-context/send/R12b-Bob-S76c.md` · 기록 푸시 뒤 `main` 과 글자가 같습니다 · 경로는 ▶ 로 바꿀 때 Claude 가 확인한 절대 경로로 적습니다). 🔴 Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 R12a 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부**(«R12b-Bob-S76c — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 같은 R12 의 끝난 카드 `_완료/R12a-Bob-S76ab*.md`, M7 의 끝난 카드 `_완료/R11a-Bob-S74*.md`·`_완료/R11b-Bob-S79*.md`·`_완료/R10a-Bob-S71b.md`·`_완료/R10b-Bob-S72G*.md`·`_완료/R10c-Bob-S72*.md`, 아직 보낼 차례가 아닌 `_대기/R12c-Bob-S77.md`·`_대기/R12d-Bob-S710.md` 를 붙여넣지 않습니다. `send/` 바로 아래의 R12 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — 아래 ```text 다음 줄 «R12b-Bob-S76c — 범위» 부터 닫는 ``` 직전 줄(«■ 제출» 끝)까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12b-Bob-S76c — 범위: S7-6c 다음 리밸런싱 · 지금 기준 초안(RebalancePreviewScreen — 카운트다운 카드(dDayText · expectedDateText · kindLabel · noticeText) ·
  기준일 · 예정 없음 문장 · 「지금 기준 초안 보기」 버튼(탭 뒤에만 previewRebalance() 인자 없이 · 마지막 요청만) · 초안 영역(기다림 · 에러 · 초안 · 차단 문장) ·
  초안 = 회차 글자 · 표 제목 · 주문 초안 행(또는 빈 초안 문장) · 사유 칩(label·tone) · 예상 비용 · 경고 줄 · 초안 기준일 · 미리보기 고지(스크롤 밖 고정)) +
  주입 analyticsWhatIfApiProvider(뷰어 셸 = null = 카운트다운만) 생성 + 결과 nextRebalanceProvider 생성.
  R12 4장 중 2번째(R12a 는 이미 main 에 병합됨).
🔴 S7-6c 는 「지금 기준 초안 보기」 탭 뒤에만 previewRebalance() 를 인자 없이 부른다 — 진입·watchNext 값만으로는 호출 0 · 결과 캐시 0 · 늦게 온 이전 결과는 버린다.
🔴 뷰어 = 주입 null = 카운트다운만(초안 버튼·영역 부재) — 고르는 조건은 «주입 null 여부» 하나 · kIsWeb·Platform 0.
🔴 lib 에 planner 라는 낱말 0(주석 포함 — T74-22 · 플래너 파일·라벨을 import·인용하지 않는다).
하지 않는 것: S7-6a·S7-6b(R12a 몫 — 이미 main) · S7-7(R12c) · S7-10(R12d) · S7-8(R12 밖) · 전후 비중(before/after)·조달 절(fundingSteps) 표시(미결 92) ·
  뷰어 초안(미결 73) · 재개 미완 차단 골든(미결 87) · 회차별 흐리게·「미확정」·배지(K22 권고 선반영 · 미결 87) · 사유 칩 핸드북 연결(칩 탭 0 · 미결 81) ·
  advisory 초안 제목 표본(미결 71 — 글자는 orderDraftsTitle 그대로) · 승인·확인·「이대로 실행」·수량 편집·주문 버튼 · 「다시 계산」 별도 버튼 ·
  previewRoute 사용(자기 자신 — H-02·알림 행 몫) · D-day·예정일 계산 · 홈 H-02 D-7 예고 행 · 알림 · 셸 몫(라우트 등록·라우터 가드·탭 — M8 · R13) ·
  웹 2열·반응형(Q-D) · 애니메이션 · 기존 화면·위젯·R12a 파일 수정.
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 22항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R12a(ui/m7-s76ab-rebalance · 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner ·
ui/m7-s79-goal-path · ui/m7-s76ab-rebalance)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/screens/rebalance_preview_screen.dart · RebalancePreviewScreen · analyticsWhatIfApiProvider · nextRebalanceProvider · Key s76c-… 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s76ab-rebalance 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s76c-preview origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.6.0'" -- packages/domain_contracts/lib/src/contract_version.dart                          ← «…contract_version.dart:1»(계약 v1.6 병합)
  git grep -c "Future<RebalancePreviewResult> previewRebalance" -- packages/domain_contracts/lib/src/repositories/what_if_api.dart ← «…what_if_api.dart:1»
  git grep -c "Stream<NextRebalanceVm> watchNext" -- packages/domain_contracts/lib/src/repositories/rebalance_repository.dart    ← «…rebalance_repository.dart:1»
  ls docs/ai-context/send/R12b-Bob-S76c.md                                                    ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls docs/ai-context/inbox/S7-6c_questions.md                                                 ← 보여야 함(빈 표가 이미 있다)
  ls packages/ui_analytics/lib/src/screens/rebalance_timeline_screen.dart                     ← 보여야 R12a 가 병합된 것입니다
  ls packages/ui_analytics/lib/src/screens/rebalance_event_screen.dart                        ← 보여야 함(R12a)
  ls packages/ui_analytics/test/golden/goldens/s76a_list_light.png                            ← 보여야 함(R12a 골든)
  git grep -n "// ── 🆕 R12a" -- packages/ui_analytics/lib/src/providers/analytics_providers.dart  ← 1줄(R12a 절 표식 — 이 카드의 절은 그 절 뒤 파일 끝에 붙는다)
  git grep -c "rebalanceRepositoryProvider" -- packages/ui_analytics/lib/src/providers/analytics_providers.dart   ← 숫자 하나(0 이 아니면 된다 · 출력 없음 = R12a 미병합)
  ls packages/domain_contracts/fixtures/m7/m7_next_rebalance_countdown.json                   ← 보여야 함(v1.6 개명 — 구 m7_next_rebalance_d6)
  ls packages/domain_contracts/fixtures/m7/m7_next_rebalance_none.json                        ← 보여야 함(v1.6 신설)
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_preview_default.json                  ← 보여야 함(v1.6 신설)
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_preview_in_band.json                  ← 보여야 함(v1.6 신설)
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_preview_blocked.json                  ← 보여야 함(v1.6 신설 · 2행)
  git grep -c "s76c_countdown" -- packages/ui_analytics/test/golden/README.md                 ← 숫자 하나(golden README «🆕 R12» 절이 있다)
  git grep -c "R12b = S7-6c" -- docs/ai-context/prompt_M7.md                                  ← «…prompt_M7.md:2»(프롬프트의 범위 치환값이 R12 로 바뀌었다 — 2행·109행)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 여섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R12b 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/screens/rebalance_preview_screen.dart                      ← 없어야 함
  ls packages/ui_analytics/lib/src/rebalance/preview                                          ← 없어야 함
  git grep -c analyticsWhatIfApiProvider -- packages/ui_analytics/lib                         ← 출력 없음이어야 함
  git grep -c nextRebalanceProvider -- packages/ui_analytics/lib                              ← 출력 없음이어야 함
  git grep -c "s76c-" -- packages/ui_analytics/lib                                            ← 출력 없음이어야 함
  git grep -c rebalanceDraft -- packages/ui_analytics/lib/l10n/labels.dart                    ← 출력 없음이어야 함(이 카드의 라벨 이름이 아직 없다)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 새 필드(RebalancePreviewResult · NextRebalanceVm.asOf …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/domain_contracts
  dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded
     ← 0 실패 · 출력의 «C-42 ① 대상 S7-6c(R12b) 0파일 — …» 줄과 «C-42 ① 역할 대상 합 …파일 · providers R12 절 …줄» 줄을 «C-42 시작 기준» 으로 적어 둔다
       (S7-6c 가 0파일이 아니면 멈추고 채팅으로 · 시작 기준 값 = «S7-6c(R12b) 0파일» · «합 2파일 · providers R12 절 24줄»(누적 드라이런 실측 — R12a 병합본이 다르면 C4 가 ▶ 때 고친다))
  cd ../ui_analytics
  flutter test   ← 시작 기준: R12a 병합본 전부 통과 · 0 실패 · 끝 줄 «+354: All tests passed!» 기대(누적 드라이런 실측 · 다르면 PR 본문에 까닭 한 줄 — 나온 수를 «시작 기준 N» 으로 적어 둔다).
                   실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  git grep -n autoDispose -- lib/src/providers     ← 줄 수를 «시작 기준 S15» 로 적어 둔다(드라이런 실측 6줄)
  git grep -n "^export " -- lib/ui_analytics.dart   ← 줄 수를 «시작 기준 S16b» 로 적어 둔다(드라이런 실측 10줄 · rebalance_event_screen 과 rebalance_timeline_screen 두 줄이 보여야 함)
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §15-4·§15-3 > 03 §11-c 의 «🆕 계약 v1.6 — `S7-6c` R12 범위» 블록 · §1-4 의 v1.6 줄 > 03 본문·그림 M7-21·M7-22 > prompt_M7.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox/S7-6c_questions.md 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·goal_path_probe_test·reference/**·README ·
   기존 골든 테스트 전부 · 기존 PNG 76장(v1.6 병합본 64 + R12a s76a_*·s76b_* 12) — 하나라도 M 이면 되돌리고 멈춤 · 예외 없음 ·
   기존 lib 파일(planner · chart · goal_path · widgets · 기존 screens — R12a 의 두 화면 파일 rebalance_timeline_screen.dart · rebalance_event_screen.dart 포함 · lib/src/rebalance/ 폴더는 R12a 도 만들지 않았다) · 기존 테스트 전부(R12a 의 테스트·가짜 포함 · import 만).
   🔴 새 lib 파일은 lib/src/screens/rebalance_preview_screen.dart **하나**다 — lib/src/rebalance/preview/ 는 만들지 않는다(화면 본문·초안 영역·칩 톤 색은 그 파일 안의 private 위젯·메서드로).
   공용 파일 3개는 **더하기만** 한다 — 기존 줄(R12a 절 포함)은 한 글자도 바꾸지 않는다(정적 묶음 S27 의 삭제 수 0 이 증명):
     lib/l10n/labels.dart = 끝 절(R12a 병합본의 마지막 절 뒤)에 이 카드의 절 하나 ·
     lib/src/providers/analytics_providers.dart = 끝(R12a 절 뒤 · 파일 끝)에 이 카드의 절 하나(머리 줄 `// ── 🆕 R12b — S7-6c ──` — C-42 ⑬ 이 첫 `// ── 🆕 R12` 표식부터 파일 끝을 본다) ·
     lib/ui_analytics.dart = export 한 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
 2 03 §11-c 의 구 초안(「데이터」 ~~줄~~ · 「컴포넌트」 · 「상태」 «「예정된 회차 없음」» · 「수용」 (c) `s76c_d7` · 「모의」 `m7_next_rebalance_d6` · 그림 M7-21 `PRE` «previewRebalance(plannedDate)» ·
   그림 M7-22 «RebalancePreview · 필드 미확정이라 픽스처 고정 모드»)은 03 §11-c 의 v1.6 블록과 01 §15-4 에 집니다 —
   구 이름·모양(non-null `String expectedDateText` · `previewRebalance(plannedDate)` · 반환 `RebalancePreview` · «예정된 회차 없음» 자작 문구)을 코드에 쓰지 않는다.
   01·03·12 의 «⬜ 로컬 커밋 — PR 대기» · «K … 🔴 확인 대기» 표기와 12 §3 «⬜ 조립 대기» 흔적은 병합 전의 글이다 — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 매개변수 금지(RebalancePreviewScreen 의 생성자에는 key 뿐 — const RebalancePreviewScreen({super.key})).
   이 카드가 여는 링크는 DTO 문자열 둘뿐이다: BlockFlag.clearDeepLink(차단 배너 — SafetyBlockBanner 가 onOpenLink 로 넘긴다) · RebalancePreviewResult.blockedAction.deepLink(차단 카드 버튼).
   이 카드가 쓰는 AppRoutes 상수는 0 개다 — NextRebalanceVm.previewRoute 는 읽지 않는다(자기 자신을 가리킨다 · H-02·알림 행 몫) · 사유 칩 detailDeepLink 도 읽지 않는다(칩 탭 0 · 미결 81).
 4 값 = DTO 의 *Text·*Label·label·*Title·*Line(s) 그대로 · 계약이 주는 표시 글자는 전부 그린다(이 카드가 «읽지 않는다»고 적은 필드는 예외 — 아래 5) · 원값(int·Decimal·TradeDate·DateTime)·.wire 표시 금지 ·
   폴백 문구 금지(?? '' · ?? AnalyticsLabels.… 0) · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값으로 색을 고르지 않음(예외 = 사유 칩 tone — 아래 «화면» 의 톤 표 하나) ·
   한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20·S28 은 주석 줄도 센다.
 5 읽지 않는 필드(카드가 정함 — 질문 아님 · C-42 ②③③' 가 빌드를 깬다 — stripComments 뒤 문자열 보간 안까지 본다):
   NextRebalanceVm.expectedKind · previewRoute / RebalancePreview.planId · plannedDate · before · after · fundingSteps / OrderDraft.symbol · sleeve · side · quantity · limitPrice /
   ReasonChip.code · detailDeepLink / CostEstimate.commission · tax · total · source / AsOf 의 observedAt·tradeDate·source·staleAfter(StaleBanner 안쪽만 읽는다).
   🔴 패턴 분해로 읽어도 같은 위반이다(C-42 ③' — case OrderDraft(quantity: final q) · final RebalancePreview(:before) = p).
   🔴 C-42 ⑩ 가드 — R12 전용 이름(NextRebalanceVm · RebalancePreviewResult · RebalancePreview · RebalanceRepository …)은 화면 파일과 providers 의 R12 절에만.
   🔴 화면 파일·providers 에는 **주석에도** planner 낱말 0(T74-22 가 screens·providers·widgets·배럴을 주석까지 센다 — 01 의 «plannerWhatIfApiProvider 와 같은 인스턴스» 문장을 옮겨 적지 않는다 ·
      AnalyticsLabels.planner… 라벨도 쓰지 않는다).
 6 화면 산술 0 — D-day·예정일·비용·수량을 계산하지 않는다(엔진 글자 그대로). 목록(orderDrafts · reasons · warningLines · activeFlags)을 거르지도 세지도 정렬하지도 묶지도 않는다
   (받은 순서 · C-42 ⑨ = .where·.sort·.reversed·.take·.skip·.contains(·.split( … 0 · reverse: true 0 · .map·.indexed·for-in 은 허용).
   🔴 고르는 조건(분기)은 이것뿐이다: emptyLabel null 여부 · 주입 null 여부 · 기다림(_pending) · 에러(_failed) · 결과의 preview/blockedText null 여부 · blockedAction null 여부 ·
      ordersEmptyText null 여부 · kindLabel·noticeText·limitPriceText·pendingNoteText null 여부 · 사유 칩 tone(색). orderDrafts.isEmpty · flagId · kind · expectedKind 로 고르지 않는다.
 7 switch 는 열거값 전수 — C-12 가 ui_*/lib 의 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드에서 열거형 switch 는 사유 칩 ChipTone 톤 색 하나다(4갈래 전수). 🔴 CommandState 0 · CommandApi 0 · rejectReasonCode 0(이 카드에는 명령이 없다).
 8 시계 = analyticsClockProvider(DateTime 금지 — 이 화면 파일에 DateTime 이라는 낱말 0) — 쓰는 자리는 StaleBanner(asOf: vm.asOf) 하나다(위젯이 안에서 읽는다 · 기준 = 카운트다운 NextRebalanceVm.asOf).
   초안의 preview.asOf 는 글자만(s76c-draft-asof) — StaleBanner 를 하나 더 두지 않는다.
   공통 상태(카운트다운 스트림) = 스켈레톤(스피너 금지) · 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(nextRebalanceProvider), lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ·
   오래됨 = StaleBanner · 차단 = SafetyBlockBanner 만(값을 가리지 않는다 · 회차별 흐리게·배지 0 — K22 권고 선반영).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(값이 온 뒤에만 — R11b 꼴). 초안 영역의 기다림·에러는 R11a 꼴(영역 스켈레톤·영역 에러 — 카운트다운·버튼은 그대로 남는다).
   🔴 초안 계산 Future 에러는 FlutterError.reportError 하지 않는다(에러 뷰가 말한다 · 에러 내용으로 분기하지 않는다 · T76c-09 가 takeException == null 을 본다).
 9 공개 위젯은 본문만 — Scaffold·AppBar·SafeArea 금지(🔴 C-42 ⑤ 는 주석을 뺀 코드에서 부분 일치 — ScaffoldMessenger.of(…) 도 같은 실패 · SnackBar 와 주석 속 낱말은 C-42 가 아니라 정적 S17·T76c-17 이 막는다 — 주석에도 이 낱말 0) · 띠 높이 예약 금지 ·
   🔴 Card() 기본 고도(elevation 인자 없음 · C-42 ⑥ = 소수부 ≠ 0 소수 리터럴 0 · 선 굵기·투명도도 N.0 또는 colorScheme) ·
   Row 안 엔진 문자열은 Expanded/Flexible 또는 Wrap · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지 · 390px overflow 0 · 글꼴 200% overflow 0(T76c-18) ·
   엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(정적 글자 = 버튼 1 · 비용 머리 1 — 아래 «정적 라벨»).
10 프로바이더는 둘만 더한다(analytics_providers.dart 끝 R12b 절 · 아래 «주입 구조») — 주입 analyticsWhatIfApiProvider · 결과 nextRebalanceProvider. 나머지는 이름·타입 그대로 재사용
   (rebalanceRepositoryProvider = R12a 가 만든 주입 · 다시 만들지 않는다). 🔴 미리보기 결과는 프로바이더가 아니라 화면 State 에 둔다(previewRebalance 를 providers 파일에 쓰면 C-42 ④⑬ 실패).
   오프너는 탭 콜백 안에서 ref.read — build 에서 read 금지. 🔴 nextRebalanceProvider 는 autoDispose 다 — 기존 비-autoDispose family 를 본뜨지 않는다 · 🔴 주석에 autoDispose 라는 낱말을 쓰지 않는다(정적 S15 가 주석도 센다).
11 테스트 = testing.dart 받침대 extends(UnimplementedRebalanceRepository · UnimplementedWhatIfApi · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   호출마다 새 Future/Stream · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처 행에서 · 예외 = 최소 목록에 «규칙 11 예외» 라 적은 copyWith 세 곳뿐 — T76c-02 둘째 경우 · T76c-06 셋째 경우 · T76c-16) · 링크는 RecordingLinkOpener 를 픽스처 값과 비교 ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0 — 한쪽만 쓰면 조건부 단언) · 테스트 이름은 번호 + ASCII(예 'T76c-05 preview only after tap no args').
   «… 0»·«… 1»(Key·글자·위젯)은 find.… 로 화면에서 센다(호출 수는 기록 목록 · 픽스처 필드 expect 는 전제일 뿐) · 스켈레톤 1 = find.byType(AnalyticsSkeleton) findsOneWidget · 에러는 tester.takeException() ·
   StreamController 는 만든 줄 바로 뒤 addTearDown(() { unawaited(controller.close()); })(🔴 addTearDown(controller.close) 로 쓰지 않는다 — 구독자 0 이면 close() 가 끝나지 않는다 · R2b C4) ·
   테스트는 package:ui_analytics/src/widgets/analytics_error_view.dart · analytics_skeleton.dart 를 직접 import 한다(배럴이 export 하지 않는다 — find.byType · tester.widget 에 필요) ·
   카드의 «<» 를 «<=» 로 · «N개» 를 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 C4b-14(Key 자리 글자 == vm 필드) — Key 를 단 Text 는 tester.widget<Text>(find.byKey(…)).data == 그 vm 필드로, Key 를 단 묶음(Card·Column)은
      tester.widgetList<Text>(find.descendant(of: find.byKey(…), matching: find.byType(Text))).map((Text t) => t.data).toList() == 픽스처 필드로 만든 목록(순서까지)으로 단언한다
      (find.text 로 «있다»만 세면 Key 자리 글자를 맞바꾼 변이가 산다 — R11b C4 P07b·X01·X23b·X24).
   🆕 C4b-12(스크롤 밖) — StaleBanner·SafetyBlockBanner 글자와 미리보기 고지는 expect(find.ancestor(of: <그 Finder>, matching: find.byType(Scrollable)), findsNothing) +
      양성 기준점 expect(find.ancestor(of: find.byKey(const Key('s76c-countdown')), matching: find.byType(Scrollable)), findsOneWidget).
   🆕 C4b-13 준용(색 단언) — 사유 칩 톤 색은 tester.widget<Chip>(…).backgroundColor == colorScheme 의 그 값(T76c-16).
   🆕 ⓡ = 정상 상태 테스트마다 expect(find.text(AnalyticsLabels.retryButton), findsNothing); 를 **한 줄에 하나**(여러 경우를 도는 테스트는 그 본문에 한 줄) ·
      ⓗ = 목록 단언 앞의 expect(<목록>, hasLength(n)); 전제 한 줄. 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄이어야 한다(접히면 줄을 얕게) —
      정적 S29·S30 의 git grep -c 가 최소 목록의 ⓡ·ⓗ 표시 수와 🔴 **정확히** 같아야 한다(ⓡ 16 · ⓗ 6 · 다르면 제출 전에 고친다 · 까닭 한 줄로 갈음 불가 · 다른 채 내면 반려) ·
      hasLength( 는 ⓗ 자리에만(사슬 Finder 목록 · Text 글자 목록 비교 · 경우 목록 · 플래그 루프 · 파일 검사에는 쓰지 않는다).
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기)와 firstWhere 다. 양쪽에 expect 가 있는 if/else(최소 목록에 «양쪽 다» 라 적은 곳)는 허용한다.
      기대 목록·사슬 목록을 만드는 collection-if(«있는 것만 넣는다»)는 «없는 쪽은 따로 단언»과 짝일 때만 허용한다 —
      Key 묶음 안 Text 글자 목록 전체를 == 로 비교하면(길이·순서 포함) 그 비교가 곧 «없는 쪽 단언»이다(T76c-02·06·07 의 collection-if 는 허용 · null 필드마다 부재 단언을 따로 더하지 않아도 된다).
      단언이 없는 동작 if(골든 루프의 «탭 결과가 있으면 탭 → pumpAndSettle»)는 금지 대상이 아니다(단언이 아니라 장면 만들기 — «■ 골든» 모양 그대로).
12 골든 = 새 PNG 10장(s76c_*) · --update-goldens 는 테스트 파일 하나씩 지정(폴더 지정 금지 — test/golden/s76c_golden_test.dart) · golden:approved 는 안 붙임(통합 담당) ·
   찍기 전 위치 전제(맨 아래 위젯의 아래 끝 dy < 높이) · 재생성 0(기존 골든 테스트·PNG 는 한 줄·한 장도 안 바뀐다).
13 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…) · dart:async import) · directives_ordering 린트(import·export 는 가나다가 아니라 경로 알파벳 순).
14 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   걸리는 이름 예: ratio · aspectRatio · devicePixelRatio · duration · iteration · decoration · syntax · limitPrice… . 글자 잇기는 보간 '${a}${b}'.
15 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
16 정적 묶음은 git grep 이라 **주석도 센다**(C-42 는 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄
   (rebalance_preview_screen.dart · analytics_providers.dart 의 R12b 절 · labels.dart 의 R12b 절)의 주석에 이 낱말을 쓰지 않는다:
   AppRoutes · analyticsLinkOpenerProvider · CommandApi · CommandState · Navigator · DateTime · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · NumberFormat · GestureDetector · InkWell · Colors ·
   Scaffold · AppBar · SafeArea · SnackBar · autoDispose · planner · operatingMode · RunMode · previewRebalance · watchNext · elevation · reportError · replaceAll · replaceFirst · % ·
   그리고 «읽지 않는 필드»(규칙 5)의 점 접근 꼴(.before · .quantity · .total …) — 카드 문장을 가드 주석으로 옮기지 않는다(주석은 «무엇을 그리는가» 한 줄).
   🔴 화면 파일은 analytics_providers.dart 를 show 없이 import — S05 에는 탭 콜백 두 줄(SafetyBlockBanner onOpenLink · 차단 카드 버튼 onPressed)만(import·주석 줄 = 위반 · 사실 아닌 «탭 콜백 안» = 거짓 보고).
   🔴 previewRebalance 는 lib 전체에서 **한 줄**(화면 파일 _requestPreview 안의 호출)에만 · watchNext 는 lib 전체에서 **한 줄**(providers R12b 절)에만 나온다(정적 S31·S32).
🔴 보고 규칙(R2 재제출 · R2b B01·B02 · R10·R11 교훈 · 🆕 strict 나눔 = 12 §3 머리 «strict 보고 규칙 나눔»(발주자 결정 2026-10-01) · R12 에 적용) —
   ① **보고 표기만의 결함**(경로 앞머리·백틱·요지 줄임·까닭 누락 등 — 내용은 사실이고 글자 모양만 카드와 다른 것) = 반려하지 않는다 → 통합 담당(C4)이 PR 본문을 정정하고 병합한다.
   ② **코드·테스트 결함**(카드 규칙 위반 — 예 규칙 11 «else 없는 if» · ⓡ·ⓗ 수 불일치)과 **거짓 주장**(보고 내용이 코드·파일·PNG 와 다름 — 시도하지 않은 것을 «시도했다» · PNG 를 열지 않고 «잘림 없음») = **반려**(재량 없음).
   ③ 아래 «통합 담당이 넣어 볼 변이» 가 하나라도 테스트를 그대로 통과하면 = **반려**(여기서 «테스트» = 이 카드의 위젯·골든 테스트 + 정적 묶음 38줄의 기대 + C-42 계약 테스트 — 셋 중 하나라도 걸리면 잡힌 것).
   🆕 **PR 본문은 통합 담당이 바꾼다** — Bob 은 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 섹션 머리 ①~⑤ 글자는 «■ 제출» 의 복사 상자 그대로).
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다(글자는 테스트 글꼴이라 네모).
   🆕 배치·잘림 칸에는 PNG 에서 보이는 것만 쓴다 — 글자 내용·글자 길이의 차이는 테스트 글꼴 네모로 보이지 않으므로 쓰지 않는다(픽스처 설명을 PNG 서술로 옮기지 않는다 · R12a 1회차 반려 사유 C12a-1 = 보고 ≠ PNG = 거짓 주장 = 반려).
   🔴 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만(정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ · <파일> = git grep 출력 경로 그대로 · 괄호·위젯·매개변수 이름·설명 금지 —
      금지 예(R10c 2회차 반려): «…:103 — 탭 콜백 안 (SafetyBlockBanner onTap)»).
   🔴 테스트별 수(«까닭» 류 포함 — «테스트 수 묶음» 끝 줄) · ⓡ·ⓗ 줄 수 · S15·S16b·S27·S28 · C-42 대상 수는 손으로 세지 않고 카드가 준 명령의 출력을 그대로 붙입니다(12 §3 재발 방지 ①).
   ② 12항은 복사 상자 15줄 그대로 + 괄호만(범위 밖도 [x] + 괄호 · [—] 금지 · 자기 말로 바꿔 쓰기 금지 — R10a) · ③ 은 위젯·Key 이름 나열만(요약어 금지 — R10c) ·
   질문 파일에 카드 지시 이행 내역·카드가 정한 것을 추측 행으로 적지 않는다(골든 dy «측정:» 행만 예외) — 자세한 것은 «■ 제출» · «■ 질문 파일».

■ 프롬프트보다 이 카드가 이긴다 — 22항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 12~13행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변)
 ② 14~15행 «라우트 상수로 딥링크» → DTO 링크(BlockFlag.clearDeepLink · RebalancePreviewResult.blockedAction.deepLink)를 AppLinkOpener.open 에 · 이 카드가 쓰는 AppRoutes 상수 0 ·
    NextRebalanceVm.previewRoute 는 읽지 않는다(규칙 3)
 ③ 16~18행 DateTime.now() 금지 · «카운트다운·D-day … 이미 문자열로 계산돼 옵니다» → 그대로 · dDayText·expectedDateText 를 그대로 찍는다 · 주입 시계를 읽는 자리는 StaleBanner 하나
 ④ 22~25행 «산술 입력은 0.0~1.0 정규값» · «건수 집계도 재계산» → 이 카드의 산술 0(정규값 필드도 없다) · 초안 행·칩·경고 줄을 세어 글자로 만들지 않는다
 ⑤ 27~32행 «정적 UI 라벨만 예외 · 아이콘·색 매핑은 재량» · «아무 일 없음 문장 금지» → 정적 라벨 = 이 카드의 2개 · 칩 톤 색 = 이 카드의 톤 표(재량 아님 — T76c-16) ·
    예정 없음 = NextRebalanceVm.emptyLabel · 빈 초안 = RebalancePreview.ordersEmptyText(화면이 짓지 않는다)
 ⑥ 40~43행 딥링크 목적지 이름 목록(x2/resume-report …) → 그대로 유효 — 목적지는 픽스처의 blockedAction.deepLink 가 준다(화면·테스트가 이름을 적지 않는다)
 ⑦ 48·69행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ⑧ 50~56행 수치·금액 리터럴 금지 → 그대로 유효 · 실제 강제 = C-42 ⑥(소수부 ≠ 0 소수 · % 문자열) + C-38 ⑫(CI · ui_analytics/lib 전체 · labels.dart·주석 포함) + 정적 S21~S25
 ⑨ 70~74행 축(RunMode·ExecPolicy·OperatingMode) 분기 금지 → 그대로 · advisory 초안 제목도 orderDraftsTitle 그대로(C-42 ⑤ — operatingMode·RunMode 낱말 0)
 ⑩ 80~81행 «viewer 에서는 종목·수량·지정가가 값 자체로 오지 않습니다 · phoneOnlyLabel» → S7-6c 에 해당 없음(그 조문은 안내 모드 — S7-6c 초안은 안내가 아니다 · 03 §11-d) ·
    뷰어 = 주입 analyticsWhatIfApiProvider 가 null = 초안 버튼·영역 부재(K2 권고 선반영) · phoneOnlyLabel 을 찾지 않는다
 ⑪ 90행 «자체 점검 10항» · 155행 «명세 §12와 1:1» → 156~170행 12항(이 카드 밖의 4·5·7·8·12번 · 10 앞절은 [x] + 괄호 «이 카드 범위 밖»)
 ⑫ 90~91행 스크린샷 4장 → 서술 + 골든 표(«제출» ③)
 ⑬ 89~90행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅 · PR 본문은 통합 담당이 바꾼다)
 ⑭ 95~96행 «픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조» → 그대로 유효 · 이 카드는 재생성 0(예외 없음)
 ⑮ 99~102행 TODO(question-3)·«M2 미정의» → 질문 파일로 · 이 화면의 타입은 코드에 확정(RebalancePreviewResult · NextRebalanceVm v1.6)
 ⑯ 103~109행 역할 문단 · «반응형으로 넓히십시오» · 109행 범위 치환값 → 범위 = 이 카드의 S7-6c · 폰 세로 하나 · 치환값은 R12 네 장을 함께 적은 것이다(0단계 확인 줄)
 ⑰ 110~116행 «읽을 문서 5개» → 아래 «먼저 읽을 것»
 ⑱ 117~118행 브랜치 형식 · PR 제목 치환값 → ui/m7-s76c-preview · PR 제목은 «■ 제출» 이 정한다
 ⑲ 133~135행 플래너 규칙(«미리보기입니다» 고지 상시 · 주문 초안을 실제 주문으로 바꾸는 버튼 0 · 등록 = 명령 API) → S7-6c 초안에 준용:
    previewNotice 는 초안(preview 갈래)이 있는 동안 스크롤 밖 고정(초안이 없으면 고지할 미리보기도 없다 — 부재) · 승인·확인·「이대로 실행」·수량 편집·주문·등록 버튼 0 ·
    «즉시 vs 다음 리밸런싱 대기» 비교 = 이 카드에 없음
 ⑳ 136~151행 S7-8 · 목표 경로 · 세후 사다리 · 가정 카드 · S7-10 · 회차↔일지 양방향 딥링크 → 이 카드 범위 밖(S7-8 = R12 밖 · S7-7 = R12c · S7-10 = R12d · S7-6b = R12a)
 ㉑ 152~154행 값을 두면 안 되는 미결 → 이 카드에 해당 없음
 ㉒ 4행 «정정 표식»(S7-9) · 5행 «보충 표식»(S7-6b ↔ J-2) → 이 카드에 해당 없음(S7-9 = R11b · S7-6b = R12a)
 (119~132행 S7-2·기간 프리셋·결측·행동 갭 → 12항 4·7·8번 괄호 «이 카드 범위 밖»)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록·줄만)
 ① prompt_M7.md 전문(머리 1~5행 포함)
 ② 01 §15-4 의 15-4-1(한 문장) · 15-4-4(S7-6c) · 15-4-7(공개 위젯·파일 자리·주입) · 15-4-8(호출 표) · 15-4-9(필드 → 자리 표의 NextRebalanceVm·WhatIfApi?·RebalancePreviewResult·RebalancePreview·OrderDraft·costs 행) · 15-4-18(카드)
 ③ 03 §11-c 의 «🆕 계약 v1.6 — `S7-6c` R12 범위 · 이 블록이 이긴다» 블록 ①~⑧(찾는 말 = «`S7-6c` R12 범위» · 「모의」 줄 바로 아래 · 그림 M7-21 앞) + §1-4 의 «🆕 계약 v1.6 — R12 범위» 줄(찾는 말 = «의 차단 표시 = `SafetyBlockBanner` 만» — 03 사본에 한 곳뿐 · «R12 범위 · 이 블록이 이긴다» 는 일곱 곳에 걸리니 쓰지 않는다)
 ④ packages/domain_contracts/lib/ — src/repositories/what_if_api.dart(머리 «v1.6 호출 표» · previewRebalance 의 ①~⑤) · src/repositories/rebalance_repository.dart(watchNext) ·
    src/dto/plan.dart 의 RebalancePreviewResult · RebalancePreview · OrderDraft · CostEstimate · src/dto/rebalance.dart 의 NextRebalanceVm · src/dto/common.dart 의 ReasonChip · LinkAction ·
    src/enums/ui.dart 의 ChipTone · testing.dart(UnimplementedRebalanceRepository — watchNext 는 동기로 던진다 · UnimplementedWhatIfApi — previewRebalance 는 Future 에러 · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c42_r12_screen_scan_test.dart 머리 주석(①~⑬) + support/r12_targets.dart 의 R12Role.s76c — 이 카드의 lib 이 받는 스캔
 ⑥ packages/ui_analytics/test/golden/README.md «🆕 R12(계약 v1.6)» 절 전부 + «🆕 R10» 절의 «2»(높이와 위치 전제) + «규칙»·«하네스» 절
 ⑦ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문(R12a 절 포함) ·
    lib/src/screens/goal_path_screen.dart(R11b — 로딩·에러·값 뒤 배너 뼈대의 선례 — 틀만) · lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · stale_banner.dart · safety_block_banner.dart ·
    lib/src/planner/deposit_planner_screen.dart(R11a — 마지막 요청만·영역 스켈레톤·영역 에러·차단 카드·칩 톤 색의 선례 — 🔴 읽기만 · import·이름·낱말을 가져오지 않는다) ·
    R12a 의 lib/src/screens/rebalance_timeline_screen.dart · rebalance_event_screen.dart(같은 R12 의 꼴 — 읽기만) ·
    test/explore_fakes.dart(FakeSafetyRepository — import 만) · test/goal_path_fakes.dart(가짜·띄우기 도우미의 모양) · test/golden/golden_support.dart · test/golden/s79_golden_test.dart(루프 모양)
 ⑧ packages/domain_contracts/fixtures/README.md 의 «계약 v1.6» 절 + 이 카드가 쓰는 픽스처(아래 «픽스처») ⑨ docs/ai-context/inbox/README.md · S7-6c_questions.md 머리말

■ 본받지 않는 것 (ui_analytics 의 기존 코드·문서에 남아 있는 다른 모양 — 고치지도 베끼지도 않는다)
 · elevation: 0.5(contribution · drawdown_context · monthly_report) → Card() 기본 고도 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState·Colors.grey·ElevatedButton → AnalyticsSkeleton·AnalyticsErrorView
 · 비-autoDispose family 3개 → nextRebalanceProvider 는 autoDispose · ValueKey<String>('bar_…') 꼴 → s76c-… Key 표만
 · R11a 플래너의 이름·라벨(plannerWhatIfApiProvider · plannerCostsHeader · plannerRecalculateButton …) · test/planner_fakes.dart 의 FakeWhatIfApi → 이 카드의 이름·라벨·FakeRebalancePreviewApi(planner 파일 import 0 · T74-22 · C-35 ⑥ · C-42 ⑤)
 · 테스트의 class _FakeSafetyRepository implements SafetyRepository(monthly_report_view_test · s71_golden_test) · 한국어 테스트 이름 · «if (x != null) { expect… }» · 매 테스트 ProviderScope 통째 →
   받침대 extends · 전제는 expect · pumpRebalancePreview · ASCII 이름
 · report_archive_screen.dart 의 클래스 주석(«Scaffold·AppBar 는 셸 소유 …») · ScaffoldMessenger·SnackBar 에러 → 주석에도 그 낱말 0 · 초안 영역 AnalyticsErrorView(C-42 ⑤)
 · 03 §11-c 위쪽 구 초안·그림 M7-21·M7-22 의 이름(previewRebalance(plannedDate) · RebalancePreview 반환 · «예정된 회차 없음» · s76c_d7 · m7_next_rebalance_d6 · D-7 예고) → 코드의 v1.6 이름

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음 · 이름 = 01 §15-4-18 · 설계서 §6 규칙 5 글자 그대로)
· 재사용(이름·위치 불변 · import 만): analyticsClockProvider · analyticsLinkOpenerProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  🔴 rebalanceRepositoryProvider(R12a 가 만든 주입 · Provider<RebalanceRepository> · 기본 throw — 다시 만들지 않는다) ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsSkeleton({super.key, this.blocks = 4}) · AnalyticsErrorView({super.key, required this.onRetry, this.lastAsOfLabel}) ·
  AnalyticsLabels.retryButton · staleBannerTitle.
  (화면 파일은 상대 import 로 필요한 파일만 — '../../l10n/labels.dart' · '../providers/analytics_providers.dart'(show 없이 · 규칙 16) · '../widgets/…'. 배럴 package:ui_analytics/ui_analytics.dart 를 lib 안에서 import 하지 않는다.)
· 🆕 프로바이더 둘 — lib/src/providers/analytics_providers.dart 끝(R12a 절 뒤 · 파일 끝)에 이 모양으로 더한다(기존 줄 무변경 · 🔴 주석에 planner·autoDispose·DateTime 낱말 0):
    // ── 🆕 R12b — S7-6c ──
    /// S7-6c 지금 기준 초안 — 미리보기 계산 주입 창구(뷰어 셸 = null = 카운트다운만 · 01 §15-4)
    final Provider<WhatIfApi?> analyticsWhatIfApiProvider = Provider<WhatIfApi?>((ref) {
      throw UnimplementedError('analyticsWhatIfApiProvider must be overridden');
    });

    /// S7-6c 다음 리밸런싱 예고 — 인자 없이(01 §15-4)
    final AutoDisposeStreamProvider<NextRebalanceVm> nextRebalanceProvider =
        StreamProvider.autoDispose<NextRebalanceVm>((ref) {
          return ref.watch(rebalanceRepositoryProvider).watchNext();
        });
  🔴 기본값 = throw(주입 누락이 조용히 묻히지 않게) — 기본값을 null 로 두지 않는다(뷰어 null 은 셸이 override 한다 · R13).
  🔴 이 절에 previewRebalance 를 쓰지 않는다(미리보기 결과는 State · C-42 ④⑬) · watchNext 는 인자 없이 · dart format 이 줄을 나눠도 된다(autoDispose 가 든 줄이 하나면 된다 — S15 = 시작 + 1).
· 🆕 lib 파일 1개(이 하나 말고 새 lib 파일을 만들지 않는다):
    lib/src/screens/rebalance_preview_screen.dart   const RebalancePreviewScreen({super.key}) — 공개 · ConsumerStatefulWidget(State 에 아래 셋)
· 배럴 lib/ui_analytics.dart 에 export 'src/screens/rebalance_preview_screen.dart'; 한 줄 —
  🔴 자리 = export 'src/screens/rebalance_event_screen.dart'; 줄과 export 'src/screens/rebalance_timeline_screen.dart'; 줄(R12a 줄) **사이**
  (경로 알파벳 순 — preview < timeline · 끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패).
  🔴 lib/src/rebalance/ 아래는 export 하지 않는다(T79-14 의 내부 폴더 export 0 · G13). 배럴 정확 집합(== 13)은 R12d 몫이다 — 이 카드는 «시작 기준 + 1»(S16b).
· 이 카드는 lib/planner.dart · lib/src/planner/** 를 import 하지도 고치지도 않는다(C-35 ⑥ · C-42 ⑤ · T74-22).

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 singleFixture / listFixture / fixtureEnvelope)
 카운트다운  singleFixture(FixturePaths.m7M7NextRebalanceCountdown, NextRebalanceVm.fromJson)   — emptyLabel 없음 · dDayText «D-1» · expectedDateText «2026년 9월 1일» · kindLabel 있음 · noticeText 있음 · previewRoute 있음(읽지 않음)
             singleFixture(FixturePaths.m7M7NextRebalanceNone, NextRebalanceVm.fromJson)        — emptyLabel 있음 · 나머지 표시 글자 전부 null
             (두 벌의 asOf.label 은 같다 — 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 초안 결과   singleFixture(FixturePaths.m7M7RebalancePreviewDefault, RebalancePreviewResult.fromJson)  — preview · 초안 2행(각 칩 1 · 지정가 있음 · 미확정 줄 없음) · ordersEmptyText 없음 · 경고 0
             singleFixture(FixturePaths.m7M7RebalancePreviewInBand, RebalancePreviewResult.fromJson)   — preview · 초안 0행 + ordersEmptyText · 경고 1
             listFixture(FixturePaths.m7M7RebalancePreviewBlocked, RebalancePreviewResult.fromJson).rows — 🔴 2행: [0] = blockedText 만(버튼 없음 · 골든 입력) · [1] = blockedText + blockedAction(위젯 테스트 전용)
 안전        SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상(플래그 0) · 3 차단 2건(RECON_MISMATCH · JOURNAL_MISSING) · 4 LEDGER_INTEGRITY(clearDeepLink 1)
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(초안 결과는 늘 «카운트다운 + 탭» 위에서만 · 예정 없음에는 버튼이 없다). 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.

■ 화면 — S7-6c RebalancePreviewScreen (01 §15-4-4 · 15-4-9 · 03 §11-c 블록 ①~⑤)
 State(이름은 재량 · 뜻은 고정): Future<RebalancePreviewResult>? _pending(기다리는 계산 — 마지막 요청) · RebalancePreviewResult? _result · bool _failed(첫 값 false).
 build:
   final AsyncValue<NextRebalanceVm> asyncValue = ref.watch(nextRebalanceProvider);
   final List<BlockFlag> activeFlags = ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ?? const <BlockFlag>[];
   final WhatIfApi? api = ref.watch(analyticsWhatIfApiProvider);                          ← 주입 null 여부가 유일한 «뷰어» 조건
   asyncValue.when(
     loading: () => ListView(padding: 16, children: [ AnalyticsSkeleton() ]),                                     ← 배너 없음
     error:   (error, stack) => ListView(padding: 16, children: [ AnalyticsErrorView(onRetry: () => ref.invalidate(nextRebalanceProvider), lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ]),   ← 배너 없음
     data:    (vm) => 아래 배치)
 계산(«지금 기준 초안 보기» 탭 · 초안 영역 에러 뷰의 재시도 — 둘 다 같은 함수 _requestPreview(api)) — 이 모양으로:
   final Future<RebalancePreviewResult> future = api.previewRebalance();                ← 🔴 인자 없이(plannedDate 를 넘기지 않는다)
   setState(() { _pending = future; _result = null; _failed = false; });                ← 결과 캐시 0 — 새 요청이 옛 결과를 지운다
   unawaited(future.then((RebalancePreviewResult result) {
     if (!mounted || !identical(future, _pending)) return;                               ← 🔴 마지막 요청의 결과만(늦게 온 이전 결과는 버린다)
     setState(() { _pending = null; _result = result; });
   }, onError: (Object error, StackTrace stack) {
     if (!mounted || !identical(future, _pending)) return;
     setState(() { _pending = null; _result = null; _failed = true; });                 ← 🔴 reportError 하지 않는다
   }));
 배치(값이 온 뒤 · 위 → 아래):
   Column(key: const Key('s76c-root'))[
    1 StaleBanner(asOf: vm.asOf)                                                         ← 스크롤 밖 · 기준 = 카운트다운 asOf
    2 SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (String link) { ref.read(analyticsLinkOpenerProvider).open(link); })   ← 스크롤 밖
    3 (preview != null) Padding(가로 16 · 세로 8, Text(preview.previewNotice))          Key s76c-notice      ← 스크롤 밖 고정 · 초안(preview 갈래)이 그려진 동안만 · preview = _result?.preview
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    4 (vm.emptyLabel != null) Text(vm.emptyLabel!)                                       Key s76c-empty       ← 예정 없음 — 4~7 의 카운트다운·버튼·초안 영역 전부 부재
      아니면 Card(key: const Key('s76c-countdown'), child: Padding(12, Column[ Text(vm.dDayText!) , Text(vm.expectedDateText!) ,
                (vm.kindLabel != null) Text(vm.kindLabel!) , (vm.noticeText != null) Text(vm.noticeText!) ]))                     ← 이 순서 · null = 줄 부재(빈 Text 금지)
    5 Text(vm.asOf.label)                                                                Key s76c-asof        ← 🔴 4 의 if/else 뒤에 **한 번만** 쓴다(두 갈래에 따로 쓰지 않는다 — S28)
    ── 6·7: vm.emptyLabel == null 이고 api != null 일 때만(뷰어 = 둘 다 부재) ──
    6 FilledButton(key: const Key('s76c-preview-button'), onPressed: () => _requestPreview(api), child: Text(AnalyticsLabels.rebalanceDraftButton))
        🔴 Key 는 FilledButton 자체에(SizedBox 에 달면 T76c-08 의 tester.widget<FilledButton>(…) 이 타입 오류) · 기다리는 동안에도 눌린다(onPressed 를 null 로 만들지 않는다 —
        다시 누르면 새 요청 · 마지막 요청만 반영 · T76c-10)
    7 초안 영역(아래 하나만 · 없으면 부재 · 위에서부터 고른다):
       7a 기다림(_pending != null) = AnalyticsSkeleton()                                 (Key 없음 · 카운트다운·버튼은 그대로)
       7b 에러(_failed) = AnalyticsErrorView(onRetry: () => _requestPreview(api))         (Key 없음 · lastAsOfLabel 없음 · 재시도 = 버튼과 같은 호출)
       7c 초안(_result?.preview != null) = Column(key: const Key('s76c-draft'), crossAxisAlignment: start)[
            Text(preview.plannedDateText) ,                                                ← 초안 머리 «… 회차»
            Text(preview.orderDraftsTitle) ,                                               ← 표 제목(화면이 «주문 초안» 을 쓰지 않는다 · advisory 이름도 이 글자)
            (preview.ordersEmptyText != null) Text(preview.ordersEmptyText!)               Key s76c-draft-empty   ← 🔴 고르는 것은 ordersEmptyText 하나(orderDrafts.isEmpty 로 고르지 않는다)
            아니면 orderDrafts 받은 순서대로 초안 행마다 Column[ Text(d.symbolLabel) , Text(d.accountAlias) ,
                 Wrap(spacing: 8)[ Text(d.sideLabel) , Text(d.quantityText) , (d.limitPriceText != null) Text(d.limitPriceText!) ] ,
                 (d.pendingNoteText != null) Text(d.pendingNoteText!) ,
                 Wrap(spacing: 6, runSpacing: 4)[ 사유 칩마다 Chip(label: Text(chip.label), backgroundColor: _toneColor(chip.tone, colorScheme)) ] ]
                 (초안 행에는 Key 를 달지 않는다 — Key 표 밖 · 테스트는 s76c-draft 안의 Text 목록으로 본다)
            Card(child: Padding(12, Column[ Text(AnalyticsLabels.rebalanceDraftCostsHeader) , Text(preview.costs.totalText) , Text(preview.costs.sourceLabel) , Text(preview.costs.basisNote) ])) ,
                                                                                            ← 초안이 없어도 그린다(엔진이 그때의 글자를 준다 · in_band «예상 비용 없음»)
            warningLines 받은 순서대로 한 줄씩 Text(line) ,                                ← 빈 목록 = 줄 0(자리표시자 0)
            Text(preview.asOf.label)                                                       Key s76c-draft-asof    ← 초안 기준(글자만 · StaleBanner 대상 아님) · 7c 의 맨 끝
          ]
       7d 차단(_result?.blockedText != null) = Card(key: const Key('s76c-blocked'), child: Padding(12, Column[ Text(blockedText) ,
            (blockedAction != null) OutlinedButton(key: const Key('s76c-blocked-action'), onPressed: () { ref.read(analyticsLinkOpenerProvider).open(action.deepLink); }, child: Text(action.label)) ]))
          ← 카운트다운·버튼은 그대로(03 §11-c 블록 ④ «카운트다운 유지») · blockedAction null = 버튼 부재 · flagId 로 버튼을 끄지 않는다
   ]
 사유 칩(🔴 탭 0 — Chip 에 onPressed·onSelected·onDeleted 없음 · ActionChip·InputChip·InkWell·GestureDetector 금지 · chip.detailDeepLink·chip.code 를 읽지 않는다) ·
 톤 색 = 화면 파일 안 비공개 함수 하나의 switch(전수 · 아래 표 그대로 · ui_journal·planner 를 import 하지 않는다):
   ChipTone.caution → colorScheme.errorContainer · ChipTone.blocked → colorScheme.error · ChipTone.neutral → colorScheme.surfaceContainerHighest · ChipTone.prevented → colorScheme.surfaceContainerHighest
 🔴 승인·확인·«이대로 실행»·수량 편집·주문·등록 버튼 0 — 이 화면의 버튼은 6(초안 보기) · 7b 의 재시도(AnalyticsErrorView 안) · 7d 의 이동 버튼(엔진 글자) · 배너의 이동(위젯 안) 넷뿐이다.
 🔴 previewRebalance 는 _requestPreview 안 한 곳에서만 부른다(initState·build·didChangeDependencies·listen 0 — 진입·watchNext 값만으로는 호출 0).
 간격(SizedBox 높이)·글자 굵기·크기·Card 모서리·경고 줄 글자 색(colorScheme 안에서)은 재량(질문 아님).

■ Key 표 (설계서 §6 규칙 17 의 S7-6c 줄 그대로 — 이 글자 그대로 · 🔴 여기 없는 s76c- Key 를 더하지 않는다 · 각 Key 는 lib 에 한 번씩만 — S28)
   루트          Key('s76c-root')               값이 온 뒤의 Column
   고지          Key('s76c-notice')             Text(preview.previewNotice) — 초안이 있을 때만 · 스크롤 밖
   예정 없음     Key('s76c-empty')              Text(vm.emptyLabel!) — 있을 때만
   카운트다운    Key('s76c-countdown')          Card — 그 안 Text 목록 = [dDayText, expectedDateText, kindLabel?, noticeText?]
   기준일        Key('s76c-asof')               Text(vm.asOf.label) — 카운트다운 기준(StaleBanner 기준과 같다)
   초안 보기     Key('s76c-preview-button')     FilledButton — emptyLabel == null 이고 주입 non-null 일 때만
   초안          Key('s76c-draft')              Column — preview 갈래일 때만
   빈 초안       Key('s76c-draft-empty')        Text(preview.ordersEmptyText!) — 있을 때만
   초안 기준일   Key('s76c-draft-asof')         Text(preview.asOf.label) — 초안 기준(글자만)
   차단          Key('s76c-blocked')            Card — 그 안 Text 목록 = [blockedText, blockedAction?.label]
   차단 이동     Key('s76c-blocked-action')     OutlinedButton — blockedAction 이 있을 때만

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R12b (1) 정적 라벨») · 테스트는 그 단계 커밋에 함께
 (1) 정적 라벨 2개(labels.dart 끝 · 기존 화면·위젯·테스트 무변경 — 0단계의 시작 기준 N 이 그대로 통과).
 (2) 자리·주입·카운트다운 — providers 끝 R12b 절(2개) · 배럴 export 한 줄(정렬 자리) · 화면 파일(로딩·에러·배너·고지 자리·예정 없음·카운트다운·기준일·버튼 — 초안 영역 7 은 이 단계에서 아직 비워 둬도 된다) ·
     test/rebalance_preview_fakes.dart · test/rebalance_preview_view_test.dart 의 T76c-01~T76c-04 · T76c-12 · T76c-13a · T76c-13b · T76c-17(이 단계 끝 = 뷰 +12 통과 — 드라이런 실측).
     (2)·(3) 중간 커밋의 analyzer unused 경고(아직 안 쓰는 State 필드 · 다음 단계용 테스트 도우미)는 괜찮다 — analyze --fatal-infos 는 (5) 뒤 «■ 제출» 에서 본다(멈추지 않는다).
 (3) 초안 영역 7a~7d · 고지 3 · 칩 톤 색 + T76c-05~T76c-11 · T76c-14~T76c-16 · T76c-18.
     🔴 이 커밋 전에 git add .(packages/ui_analytics 안 · git grep 은 add 안 한 새 파일을 못 본다 — 출력 없음 = 거짓 안심) 뒤 «정적 묶음» 38줄을 미리 돌려 아래 기대와 맞추고,
        packages/domain_contracts 에서 c42_r12_screen_scan_test.dart 0 실패를 본다 — (5) 뒤에는 커밋을 더할 수 없으니(amend·rebase 금지) 여기서 고친다.
        이때 맞추는 범위 = S27·S34 를 뺀 줄(S27·S34 는 git diff origin/main...HEAD 라 커밋된 것만 본다 — (3) 커밋 뒤에 다시 돌려 본다) ·
        골든 테스트 파일 몫(S01·S02a·S02b·S10 의 test/golden/s76c_golden_test.dart)은 (4) 뒤에 다시 본다.
 (4) 골든 10장 — test/golden/s76c_golden_test.dart.
 (5) format:fix · 질문 파일(S7-6c_questions.md — 골든 dy 측정 행 A1~A5 · 그 밖의 질문) · 커밋 — 🔴 마지막 커밋(그 뒤 format 수정도 커밋을 더하지 않는다 — 제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지).

■ 정적 라벨 — AnalyticsLabels 끝에(R12a 병합본의 마지막 절 뒤) 절 주석(// ── 🆕 R12b — S7-6c ──)과 함께 2개(이름·글자 고정 · 글자 = 03 §11-c 표현 그대로):
   rebalanceDraftButton = '지금 기준 초안 보기' · rebalanceDraftCostsHeader = '예상 비용'
   (retryButton · staleBannerTitle 은 이미 있다 — 고치지 않는다. R12a 의 라벨 절·R11a 의 planner… 라벨도 고치지 않고 쓰지도 않는다.)
   🔴 만들지 않는 글자(엔진 몫): «주문 초안»(orderDraftsTitle) · «… 회차»(plannedDateText) · «D-»·날짜·«월간 정기»(카운트다운) · «예정된 리밸런싱 회차가 아직 없습니다» · «예정 없음» ·
      «모든 슬리브가 밴드 안…»(ordersEmptyText) · «미리보기입니다…»(previewNotice) · «초안 기준 …»·«리밸런싱 예정 기준 …»(asOf.label) · «매수»·«매도»·«…주»·«…원» · «약 …»·«추정치»·«예상 비용 없음» ·
      차단 문장·«재개 리포트 보기» · «승인»·«확인»·«실행»·«주문» 버튼 글자 · «모의» · «다시 계산».
   🔴 라벨 글자에 숫자·금액을 넣지 않는다(C-38 ⑫ 가 labels.dart 도 본다). 더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다 — 🔴 이름에 planner 금지.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S29·S30 과 대조 · 파일 = test/rebalance_preview_view_test.dart · T76c-17 만 파일 읽기 test)
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 기본 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Future/Stream ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 픽스처는 golden_support.dart 의 singleFixture/listFixture/fixtureEnvelope 로만 읽는다 ·
  탭 뒤에는 pump() 두 번(Completer 로 멈춘 동안은 pumpAndSettle 금지).
  🔴 경우가 여럿인 테스트(«…마다» · «두 경우» — T76c-02·04·06·07·09·10·12·14·15·16·18)는 for 로 testWidgets 를 경우마다 만든다
     (이름 = '<번호> <설명> <경우 이름>' · 예 'T76c-06 draft text chain default' · ⓡ·ⓗ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 같다).
     pumpRebalancePreview 는 한 테스트에서 한 번만 부른다(한 테스트 안에서 픽스처를 바꿔 다시 띄우지 않는다 — State(_result·_pending)가 남는다).
     최소 목록의 경우 수 = 뷰 40개(T76c-01 1 · 02 2 · 03 1 · 04 2 · 05 1 · 06 3 · 07 2 · 08 1 · 09 2 · 10 2 · 11 1 · 12 3 · 13a 1 · 13b 1 · 14 4 · 15 5 · 16 4 · 17 1 · 18 3)
       (누적 드라이런 실측 = 이 판 보강 전 39(06 = 2) · T76c-06 셋째 경우를 더한 이 판 = 40 — 2026-10-13 재측정 «+40» ✅ `dry/r12b-plus` `7272a43`).
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순 · 쓰는 것만):
     import 'dart:async'; → import 'dart:io'; →
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
     import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/src/widgets/analytics_error_view.dart'; →
     import 'package:ui_analytics/src/widgets/analytics_skeleton.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
     import 'golden/golden_support.dart'; → import 'rebalance_preview_fakes.dart';(golden 이 rebalance 보다 앞 · error_view 가 skeleton 앞 · 누적 드라이런에서 이 순서로 analyze --fatal-infos 통과).
  🆕 test/rebalance_preview_fakes.dart(새 파일 · 공개 이름 · 이름·매개변수 고정 · 🔴 한국어 리터럴 0 · explore_fakes.dart 는 import 만 · planner_fakes.dart 는 import 하지 않는다):
    import 순서(directives_ordering · 누적 드라이런 확인 · 쓰는 것만):
      import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
      import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/ui_analytics.dart'; →
      import 'explore_fakes.dart' show FakeSafetyRepository; → import 'golden/golden_support.dart';
    (FakeSafetyRepository(SafetyState state) — 위치 인자 하나 · 고치지 않는다)
    class FakeNextRebalanceRepository extends UnimplementedRebalanceRepository {
      FakeNextRebalanceRepository({NextRebalanceVm? vm, Stream<NextRebalanceVm> Function(int call)? streamFactory})   ← 둘 중 정확히 하나를 준다(테스트가 정한다)
      int watchNextCalls = 0;                       ← 호출마다 +1
      final List<String> otherCalls = <String>[];   ← watchEvents · watchEvent 가 불리면 메서드 이름을 더한 뒤 super 를 그대로(받침대가 던진다)
      watchNext() = watchNextCalls += 1 → streamFactory 가 있으면 streamFactory(watchNextCalls)(1 부터) / 아니면 Stream<NextRebalanceVm>.value(vm!)(호출마다 새로)
    }
    class FakeRebalancePreviewApi extends UnimplementedWhatIfApi {
      FakeRebalancePreviewApi({RebalancePreviewResult? result, Future<RebalancePreviewResult> Function(int call)? answerFn})
      final List<TradeDate?> previewCalls = <TradeDate?>[];   ← 받은 plannedDate 를 호출마다 그대로 더한다(인자 없이 불리면 null)
      final List<String> otherCalls = <String>[];              ← simulateDeposit · simulateWithdrawal · estimateCosts · findPlan = 메서드 이름을 더한 뒤 super 를 그대로(받침대의 에러)
      previewRebalance({plannedDate}) = 기록 → answerFn 이 있으면 answerFn(previewCalls.length)(1 부터) / 아니면 Future<RebalancePreviewResult>.value(result ?? m7M7RebalancePreviewDefault 행)
      (override 매개변수의 타입은 생략해도 된다 — 상위 선언에서 추론된다 · decimal 을 import 하지 않는다)
    }
    List<Override> rebalancePreviewOverrides({required FakeNextRebalanceRepository repo, FakeRebalancePreviewApi? whatIf, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 5개(🔴 전부 overrideWithValue): analyticsClockProvider · analyticsLinkOpenerProvider · safetyRepositoryProvider(FakeSafetyRepository(…)) · rebalanceRepositoryProvider(repo) ·
          analyticsWhatIfApiProvider(whatIf — 🔴 null 이면 null 을 그대로 = 뷰어 셸 `(_) => null` 과 같은 값)
        · 기본값: 안전 = safetyStates 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 오프너 = 새 RecordingLinkOpener(링크를 단언하려면 opener: 로 넘긴다) · whatIf 기본값 없음(null = 뷰어 — 테스트가 늘 정한다)
    Future<void> pumpRebalancePreview(WidgetTester tester, {required FakeNextRebalanceRepository repo, FakeRebalancePreviewApi? whatIf, SafetyState? safetyState, Clock? clock,
        RecordingLinkOpener? opener, Size viewSize = const Size(390, 2400), TextScaler textScaler = TextScaler.noScaling})
        ← 첫 줄 = await tester.pumpWidget(const SizedBox.shrink())(앞 장면을 걷어 낸다) → viewSize · DPR 1.0 · teardown 2 → ProviderScope(overrides: rebalancePreviewOverrides(…)) →
           MaterialApp(builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: textScaler), child: child!), home: Scaffold(body: RebalancePreviewScreen())) · 끝에 pump() 두 번
    골든은 pumpRebalancePreview 를 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: rebalancePreviewOverrides(…), child: const RebalancePreviewScreen()), brightness: b, logicalSize: kS76cGoldenSize).
  🔴 새 띄우기 도우미는 이 하나뿐(pumpRebalancePreview) · 테스트마다 ProviderScope 를 통째로 쓰지 않는다 · 탭 도우미를 따로 만들지 않는다(tap → pump → pump 를 그 자리에).
 T76c-01 진입 — countdown · whatIf = FakeRebalancePreviewApi() · 행 0 → repo.watchNextCalls == 1 · repo.otherCalls isEmpty · whatIf.previewCalls isEmpty · whatIf.otherCalls isEmpty ·
        s76c-root 1 · s76c-preview-button 1 · find.text(AnalyticsLabels.rebalanceDraftButton) 1 · s76c-draft 0 · s76c-notice 0 · s76c-blocked 0 · find.byType(AnalyticsSkeleton) 0 · ⓡ.
 T76c-02 카운트다운 글자(C4b-14) — 두 경우: countdown 그대로 · countdown.copyWith(kindLabel: null, noticeText: null)(🔵 규칙 11 예외 — 픽스처에 그 조합이 없다):
        전제 expect(vm.kindLabel, <그대로 = isNotNull / copyWith = isNull>) · s76c-countdown 안 Text 글자 목록 == [vm.dDayText, vm.expectedDateText, (kindLabel 이 있으면) kindLabel, (noticeText 가 있으면) noticeText]
        (순서까지 · 그대로 = 4개 · copyWith = 2개) · tester.widget<Text>(s76c-asof).data == vm.asOf.label · s76c-empty 0 · ⓡ.
 T76c-03 예정 없음 — none · whatIf = FakeRebalancePreviewApi() → tester.widget<Text>(s76c-empty).data == vm.emptyLabel · s76c-countdown 0 · s76c-preview-button 0 ·
        find.text(AnalyticsLabels.rebalanceDraftButton) 0 · tester.widget<Text>(s76c-asof).data == vm.asOf.label · s76c-draft 0 · whatIf.previewCalls isEmpty · ⓡ.
 T76c-04 주입 null(뷰어) — 두 경우(countdown · none) · whatIf: null → s76c-preview-button 0 · find.text(AnalyticsLabels.rebalanceDraftButton) 0 · s76c-draft 0 · s76c-blocked 0 ·
        countdown 이면 s76c-countdown 1 · s76c-empty 0 / none 이면 s76c-empty 1 · s76c-countdown 0(양쪽 다) · s76c-asof 1 · ⓡ.
 T76c-05 탭 뒤에만 · 인자 없이 — countdown · whatIf 기본: 탭 전 expect(whatIf.previewCalls, isEmpty) → s76c-preview-button 탭 → pump×2 → ⓗ expect(whatIf.previewCalls, hasLength(1)) ·
        expect(whatIf.previewCalls.single, isNull)(plannedDate 를 넘기지 않았다) · whatIf.otherCalls isEmpty · repo.watchNextCalls == 1(탭이 다시 구독하지 않는다) · repo.otherCalls isEmpty · s76c-draft 1 · ⓡ →
        초안이 뜬 뒤 s76c-preview-button 을 다시 탭 → pump×2 → expect(whatIf.previewCalls.length, 2)(결과 캐시 0 — 🔴 hasLength 로 쓰지 않는다 · ⓗ 는 6 그대로) · s76c-draft 1.
 T76c-06 초안 글자 사슬(C4b-14) — 세 경우(m7M7RebalancePreviewDefault · m7M7RebalancePreviewInBand ·
        in_band_two_warnings = 🔵 규칙 11 예외 — 픽스처에 경고 2줄짜리가 없다: in_band 결과.copyWith(preview: preview.copyWith(warningLines: [in_band 의 warningLines.single, in_band 의 previewNotice]))
        · 전제 expect(첫 글자, isNot(둘째 글자)) — 둘 다 픽스처 글자 · 🔴 테스트에 한국어 리터럴을 쓰지 않는다 · 경고 줄의 받은 순서를 사슬이 본다) ·
        탭 → ⓗ expect(preview.orderDrafts, hasLength(<default 2 · in_band 0 · in_band_two_warnings 0>)) →
        s76c-draft 안 Text 글자 목록 == 테스트가 픽스처 필드로 만든 목록(순서까지):
          [plannedDateText, orderDraftsTitle, (ordersEmptyText 가 있으면 ordersEmptyText / 없으면 초안마다 symbolLabel, accountAlias, sideLabel, quantityText, (limitPriceText 있으면) limitPriceText,
           (pendingNoteText 있으면) pendingNoteText, 칩마다 label), AnalyticsLabels.rebalanceDraftCostsHeader, costs.totalText, costs.sourceLabel, costs.basisNote, …warningLines, asOf.label]
        · ordersEmptyText 가 있으면 tester.widget<Text>(s76c-draft-empty).data == 그 글자 / 없으면 s76c-draft-empty 0(양쪽 다) ·
        tester.widget<Text>(s76c-draft-asof).data == preview.asOf.label · tester.widget<Text>(s76c-notice).data == preview.previewNotice ·
        🔴 탭 뒤에도 tester.widget<Text>(find.byKey(const Key('s76c-asof'))).data == 카운트다운 픽스처의 asOf.label(초안 기준 글자로 바뀌지 않는다 · 두 픽스처의 asOf.label 은 서로 다르다 — 전제 expect 로 확인) · ⓡ.
 T76c-07 차단 — m7M7RebalancePreviewBlocked 두 행마다(경우 = 행 0 · 행 1) · opener 를 넘겨 · 탭 → ⓗ expect(rows, hasLength(2)) · s76c-blocked 1 ·
        s76c-blocked 안 Text 글자 목록 == [blockedText] (행 0) / [blockedText, blockedAction.label] (행 1) ·
        두 행 모두 차단 버튼을 누르기 전에 expect(opener.opened, isEmpty) → 행 1 은 s76c-blocked-action 1 → 탭 → pump → opener.opened == <String>[row.blockedAction!.deepLink] /
        행 0 은 s76c-blocked-action 0(탭 없음)(양쪽 다) ·
        s76c-countdown 1 · s76c-preview-button 1(카운트다운 유지) · s76c-draft 0 · s76c-notice 0 · ⓡ.
 T76c-08 기다림 — answerFn = Completer → 탭 → pump×2 → find.byType(AnalyticsSkeleton) 1 · find.byType(CircularProgressIndicator) 0 · find.byType(LinearProgressIndicator) 0 · s76c-countdown 1 ·
        tester.widget<FilledButton>(s76c-preview-button).onPressed isNotNull(기다리는 동안에도 눌린다) · s76c-draft 0 · s76c-notice 0 · ⓡ →
        Completer 를 m7M7RebalancePreviewDefault 로 완료 → pump×2 → s76c-draft 1 · find.byType(AnalyticsSkeleton) 0.
 T76c-09 에러·재시도 — 두 경우(재시도 = AnalyticsErrorView 안 retryButton · 재시도 = s76c-preview-button) · answerFn 첫 호출 = Future.error(StateError('x')) · 둘째 = m7M7RebalancePreviewDefault →
        탭 → find.byType(AnalyticsErrorView) 1 · find.text(AnalyticsLabels.retryButton) 1 · tester.takeException() isNull(보고하지 않는다) · s76c-countdown 1 · s76c-preview-button 1 · s76c-draft 0 →
        그 경우의 재시도 탭 → pump×2 → ⓗ expect(whatIf.previewCalls, hasLength(2)) · 두 기록 모두 isNull · s76c-draft 1 · find.byType(AnalyticsErrorView) 0.
 T76c-10 마지막 요청만 — 두 경우 · answerFn 이 호출 순서대로 Completer A · B 를 돌려준다 · 탭 → 탭:
        ⓐ B 를 m7M7RebalancePreviewDefault 로 완료 → s76c-draft 1 → A 를 blocked 행 0 으로 완료 → 여전히 s76c-draft 1 · s76c-blocked 0
        ⓑ A 를 m7M7RebalancePreviewDefault 로 완료 → find.byType(AnalyticsSkeleton) 1 · s76c-draft 0(A 는 버렸다) → B 를 blocked 행 0 으로 완료 → s76c-blocked 1 · s76c-draft 0
        두 경우 다 ⓗ expect(whatIf.previewCalls, hasLength(2)) · ⓡ.
 T76c-11 고지 스크롤 밖(C4b-12) — viewSize: Size(390, 600) · countdown · 기본 결과 → 탭 → tester.widget<Text>(s76c-notice).data == previewNotice ·
        find.ancestor(of: find.byKey(const Key('s76c-notice')), matching: find.byType(Scrollable)) findsNothing ·
        find.ancestor(of: find.byKey(const Key('s76c-countdown')), matching: find.byType(Scrollable)) findsOneWidget(양성 기준점) ·
        고지 dy 와 s76c-countdown dy 를 적어 두고 tester.drag(find.byType(ListView), const Offset(0, -40)) → pumpAndSettle → 고지 dy 는 같고 s76c-countdown dy 는 lessThan(끌기 전 값) · ⓡ.
 T76c-12 배너(C4b-12) — 세 경우(오래됨 +3일 · 행 3) · (정상 시계 · 행 0) · (정상 시계 · 행 4) · countdown · 탭 없음 · opener 를 넘겨:
        ⓗ expect(activeFlags, hasLength(<2 · 0 · 1>)) → 오래됐으면 find.text(AnalyticsLabels.staleBannerTitle) 1 + 그 Finder 의 Scrollable 조상 findsNothing / 아니면 staleBannerTitle 0(양쪽 다) ·
        플래그마다 그 label 글자 1 + find.ancestor(of: find.text(flag.label), matching: find.byType(Scrollable)) findsNothing ·
        find.byIcon(Icons.block) — 플래그 0 이면 findsNothing / 있으면 findsNWidgets(<행 3 = 2 · 행 4 = 1>)(양쪽 다 · 차단 플래그마다 아이콘 1 — 공용 위젯 SafetyBlockBanner · 최대 2) ·
        사슬 dy(getTopLeft · lessThan · 있는 것만): (오래됐으면 staleBannerTitle) → (플래그 있으면 첫 플래그 label) → s76c-countdown ·
        탭 — 행 4 만 find.byIcon(Icons.chevron_right) 탭 → pump → opener.opened == <String>[행 4 의 activeFlags.single.clearDeepLink!] /
        그 밖은 탭하지 않고 expect(opener.opened, isEmpty)(양쪽 다) · ⓡ.
 T76c-13a 로딩 — streamFactory = 값을 주지 않는 StreamController 의 stream · 안전 행 3 → find.byType(AnalyticsSkeleton) 1 · CircularProgressIndicator 0 · LinearProgressIndicator 0 · s76c-root 0 ·
        그 플래그 label 글자 각 0(🔴 로딩에는 배너 없음 — 규칙 8) · ⓡ.
 T76c-13b 에러 — streamFactory 첫 호출 = Stream<NextRebalanceVm>.error(StateError('x')) · 둘째 = countdown 의 Stream.value · 안전 행 3 → find.byType(AnalyticsErrorView) 1 ·
        tester.widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView)).lastAsOfLabel == null · 그 플래그 label 글자 각 0 · s76c-root 0 · s76c-preview-button 0 →
        retryButton 탭 → pump×2 → expect(repo.watchNextCalls, 2) · s76c-countdown 1 · whatIf.previewCalls isEmpty.
 T76c-14 배치 사슬 — 네 경우: (countdown · 탭 → default · 정상 시계 · 행 0) · (countdown · 탭 → in_band · +3일 · 행 3) · (countdown · 탭 → blocked 행 0 · 정상 시계 · 행 4) · (none · 정상 시계 · 행 0 · 탭 없음):
        위 → 아래 Finder 목록을 만들고(있는 것만 넣는다) 이웃끼리 tester.getTopLeft(…).dy 를 lessThan 으로 잇는다(각 Finder 는 findsOneWidget 도):
        [오래됐으면 find.text(AnalyticsLabels.staleBannerTitle)] → [플래그가 있으면 find.text(activeFlags.first.label)] → [preview 갈래면 s76c-notice] →
        (none 이면 s76c-empty / 아니면 s76c-countdown) → s76c-asof → [none 아니면 s76c-preview-button] → [preview 갈래면 s76c-draft → s76c-draft-asof · 차단이면 s76c-blocked].
        없는 쪽은 따로 단언한다(if/else 양쪽 — staleBannerTitle 0 · find.byIcon(Icons.block) 0 · s76c-notice 0 · s76c-preview-button 0 · s76c-draft 0 · s76c-blocked 0 · s76c-empty 0 · s76c-countdown 0).
        네 경우가 양쪽을 한 번 이상씩 지난다 · 🔴 «<» 는 lessThan 그대로 · ⓡ.
 T76c-15 화면이 지은 글자 0 — 다섯 경우(countdown 탭 없음 · none · 탭 → default · 탭 → in_band · 탭 → blocked 행 1) · 정상 시계 · 행 0:
        화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있다 —
        집합 = vm 의 문자열(dDayText · expectedDateText · kindLabel · noticeText · emptyLabel · asOf.label 중 null 아닌 것) +
        (그 경우의 결과가 있으면) preview 의 문자열(plannedDateText · orderDraftsTitle · ordersEmptyText · previewNotice · warningLines · asOf.label · 초안마다 symbolLabel · accountAlias · sideLabel ·
        quantityText · limitPriceText · pendingNoteText · 칩 label · costs.totalText · sourceLabel · basisNote) + blockedText · blockedAction.label + AnalyticsLabels.rebalanceDraftButton · rebalanceDraftCostsHeader
        (화면이 지은 글자 = 0 · 승인·실행 버튼 글자 0 · 금지어(추천·권유·자문·시그널)는 C-41 ⑨ 가 픽스처 전 문자열에서 막고 이 집합 검사가 화면 쪽을 막는다 — 테스트에 한국어 리터럴을 쓰지 않는다) · ⓡ.
 T76c-16 칩 톤 색(C4b-13 준용) — ChipTone.values 마다(경우마다 testWidgets): m7M7RebalancePreviewDefault 의 첫 초안 첫 칩만 copyWith(tone: t)(🔵 규칙 11 예외 — 픽스처는 NEUTRAL 뿐 ·
        result.copyWith(preview: preview.copyWith(orderDrafts: [첫 초안.copyWith(reasons: [첫 칩.copyWith(tone: t), …나머지 칩]), …나머지 초안])) 사슬 허용) 한 결과로 띄워 탭 →
        tester.widget<Chip>(find.descendant(of: find.byKey(const Key('s76c-draft')), matching: find.byType(Chip)).first).backgroundColor == 위 «화면» 의 톤 표(colorScheme 은 Theme.of(tester.element(find.byKey(const Key('s76c-draft')))) 에서) ·
        find.byType(ActionChip) 0 · find.byType(InputChip) 0 · 그 칩을 눌러도 opener.opened isEmpty · ⓡ.
 T76c-17 파일 검사 — (test · 파일 읽기) File('lib/src/screens/rebalance_preview_screen.dart') 의 글자에: 'planner' 0 · RegExp('Scaffold|AppBar|SafeArea|SnackBar') 일치 0(주석 포함 · ScaffoldMessenger 도) ·
        RegExp('previewRebalance').allMatches(…).length == 1(한 자리) · RegExp('DateTime') 일치 0 · Directory('lib/src/rebalance/preview').existsSync() isFalse(새 lib 파일은 하나).
 T76c-18 큰 글꼴 — 세 경우(탭 → default · 탭 → in_band · 탭 → blocked 행 1) · textScaler: TextScaler.linear(2.0) · viewSize 기본 → 탭 → pump×2 → tester.takeException() isNull(overflow 0) ·
        s76c-countdown 1 · 그 경우의 영역 Key(s76c-draft / s76c-draft / s76c-blocked) 1 · ⓡ.
 (T76c 에 없는 번호는 없다 — 01~18 · 13 만 a·b 두 개.)
 ⓡ 기대 = rebalance_preview_view_test.dart 16줄(T76c-01·02·03·04·05·06·07·08·10·11·12·13a·14·15·16·18) · ⓗ 기대 = 6줄(T76c-05·06·07·09·10·12) ·
   🔴 정확히 이 수(다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 — 규칙 11).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려): 진입 때 previewRebalance 호출 · previewRebalance 에 plannedDate 넘기기 · 탭이 nextRebalanceProvider 를 invalidate ·
   늦은 결과 반영(identical 빼기) · 결과 캐시(둘째 탭에 호출 0) · 기다리는 동안 버튼 끄기 · 계산 에러를 스켈레톤으로 · 계산 에러를 reportError · 차단 카드에서 blockedAction 무시 ·
   blockedAction 이 없는데 버튼 그리기 · 차단이면 카운트다운·버튼 숨기기 · 주입 null 인데 버튼 · emptyLabel 인데 카운트다운도 그리기 · kindLabel null 에 빈 Text · 카운트다운 글자 순서 바꾸기 ·
   s76c-asof 를 빼거나 preview.asOf 로 · ordersEmptyText 무시하고 빈 표 · 초안 행 글자 맞바꾸기(sideLabel ↔ quantityText) · 경고 줄 역순 · 비용 머리 빼기 · 비용 카드를 초안 0행일 때 숨기기 ·
   previewNotice 를 ListView 안으로 · 배너를 ListView 안으로 · 로딩·에러에 차단 배너 그리기 · 로딩에 스피너 · 배너 링크를 열지 않기 · 사유 칩을 ActionChip 으로 · 톤 색 맞바꾸기 ·
   화면이 지은 글자 하나(예 정적 «다시 계산» 글자 — 🔴 «주문 초안» 은 픽스처 orderDraftsTitle 과 같은 글자라 예가 아니다 · 엔진 글자와 같은 라벨을 더하면 S27 의 labels 첫째 수가 4 를 넘는다) ·
   글꼴 200% 에서 Row 안 엔진 문장 overflow(카운트다운 noticeText · 비용 basisNote · blockedText 같은 문장을 Row 에 넣고 Expanded/Flexible 를 빼기 — 초안 행 Wrap 의 짧은 글자(sideLabel·quantityText·limitPriceText)는 대상 아님).

■ 정적 묶음 — packages/ui_analytics 에서 아래 38줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 38줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로(줄 수가 많아도 · «길어서 줄였습니다» 같은 주의 문장으로 갈음하지 않는다 · R12a C12a-2).
  🔴 **테스트 이름·패키지 이름 한 낱말이라도 다르면 반려 — 대조에서 빼는 것은 빈 줄·EXIT 표기·warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐**(R12a 2회차 C12a2-1 — 다시 돌린 출력을 채팅 글로 옮기다 테스트 제목의 패키지 이름 한 낱말이 바뀌어 반려).
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(아래 «테스트 수 묶음» 세 줄 · «■ 제출» 의 C-42 dart test · Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 → <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채 · R12a 2회차 C12a2-1).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  S27·S34 만 git diff 다 — «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다(나오면 지우지 않고 그대로 붙인다 · EXIT 값은 보지 않는다).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/rebalance_preview_view_test.dart test/rebalance_preview_fakes.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/rebalance_preview_view_test.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/rebalance_preview_view_test.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshape 0 (screen)"; git grep -nE "\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes 0 (screen)"; git grep -n "AppRoutes" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S06a CommandState 0"; git grep -n "CommandState" -- lib; echo "EXIT:$?"
echo "## S06b CommandApi 0 (screen)"; git grep -n "CommandApi" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08a DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S08b DateTime 0 (screen)"; git grep -n "DateTime" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 link literals 0 (lib + new tests)"; git grep -nE "'aaq://|'handbook://" -- lib test/rebalance_preview_view_test.dart test/rebalance_preview_fakes.dart test/golden/s76c_golden_test.dart; echo "EXIT:$?"
echo "## S11 toStringAsFixed NumberFormat 0"; git grep -nE "toStringAsFixed|NumberFormat" -- lib; echo "EXIT:$?"
echo "## S12 tap widgets 0 (screen)"; git grep -nE "GestureDetector|InkWell|ActionChip|InputChip|onSelected|onDeleted" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S13 Colors 0 (screen providers labels)"; git grep -nw Colors -- lib/src/screens/rebalance_preview_screen.dart lib/src/providers lib/l10n; echo "EXIT:$?"
echo "## S14 planner 0 (T74-22 scope)"; git grep -n "planner" -- lib/ui_analytics.dart lib/src/screens lib/src/widgets lib/src/providers; echo "EXIT:$?"
echo "## S15 autoDispose (start + 1)"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "src/rebalance/|goal_path/|chart/|explore/|planner|perf_chart|analytics_skeleton|analytics_error_view|stale_banner|safety_block_banner" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports (start + 1)"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 Scaffold AppBar SafeArea SnackBar 0 (screen)"; git grep -nE "Scaffold|AppBar|SafeArea|SnackBar" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S18 unread raw fields 0 (screen - C-42 3)"; git grep -nE "\.(planId|plannedDate|before|after|fundingSteps|quantity|limitPrice|side|commission|tax|total|source|expectedKind|previewRoute|detailDeepLink|symbol|sleeve|code|kind|mode)\b" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 decimal literals 0 (screen - C-42 6)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S25 percent elevation 0 (screen)"; git grep -nE "%|elevation" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S26 sort filter 0 (screen providers - C-42 9)"; git grep -nE "\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|reverse:\s*true" -- lib/src/screens/rebalance_preview_screen.dart lib/src/providers/analytics_providers.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 s76c keys (11 lines - each key once)"; git grep -h -o -E "'s76c-[a-z-]+'" -- lib; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/rebalance_preview_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/rebalance_preview_view_test.dart; echo "EXIT:$?"
echo "## S31 previewRebalance 1 line (screen)"; git grep -n "previewRebalance" -- lib; echo "EXIT:$?"
echo "## S32 watchNext 1 line (providers)"; git grep -n "watchNext" -- lib; echo "EXIT:$?"
echo "## S33 reportError 0 (screen)"; git grep -nE "reportError|FlutterError" -- lib/src/screens/rebalance_preview_screen.dart; echo "EXIT:$?"
echo "## S34 lib files changed (A 1 + M 3)"; git diff --name-status origin/main...HEAD -- lib; echo "EXIT:$?"
  (줄의 뜻과 기대 — 출력 없음 = S01(주석 줄 말고) · S02a·S02b(테스트 이름 ASCII 만 · «—»·«→» 도 금지) · S03·S04·S06a~S14·S16·S17~S26·S33(주석 포함 · S17 은 ScaffoldMessenger 도 ·
   S18 = C-42 ③ 의 S7-6c 몫 + symbol·sleeve·code·kind·mode · S19~S23 = 12항 1·3·11항 근거 · S22·S23 = C-38 ⑫ 와 같은 정규식 · S24·S25 = C-42 ⑥ + Card() 기본 고도 · S26 = C-42 ⑨) ·
   S05 = 2줄(SafetyBlockBanner onOpenLink 자리 · 차단 카드 버튼 onPressed 자리 · 줄 번호는 내 코드 그대로(드라이런은 106·288) · build 본문·import·주석 줄 0) ·
   S15 = 0단계 «시작 기준 S15» + 1줄(nextRebalanceProvider · 드라이런 6 → 7 · 대소문자 구분 · 주석도 센다) ·
   S16b = 0단계 «시작 기준 S16b» + 1줄(rebalance_event_screen 과 rebalance_timeline_screen 사이 · 드라이런 10 → 11) ·
   S27 = 세 줄의 둘째 수(삭제) 전부 0(첫째 수 = 드라이런 labels 4 · providers 14 · 배럴 1 — labels·providers 는 주석·빈 줄에 따라 다를 수 있다 · 기준은 둘째 수 0 · 배럴 1) · S28 = Key 표 11개가 각 1줄(대조는 글자 집합 · 12줄 이상 = 두 번 · 10줄 이하 = 빠짐) ·
   S29·S30 = 16 · 6(최소 목록의 ⓡ·ⓗ 표시 수 — 다르면 반려) · S31 = 1줄(화면 파일 _requestPreview 안) · S32 = 1줄(providers R12b 절) ·
   S34 = A packages/ui_analytics/lib/src/screens/rebalance_preview_screen.dart + M packages/ui_analytics/lib/l10n/labels.dart · M packages/ui_analytics/lib/src/providers/analytics_providers.dart ·
         M packages/ui_analytics/lib/ui_analytics.dart 의 4줄뿐(줄 순서 = git 출력 그대로 · 경로 가나다순 — labels → providers → screens → ui_analytics.dart)
   🔴 S27·S34(git diff)의 경로는 저장소 뿌리 기준(packages/ui_analytics/…)으로 찍힌다 — git grep(cwd 기준 lib/…)과 꼴이 다른 것이 정상 · 출력을 손으로 고치지 않는다)

■ 테스트 수 묶음 — packages/ui_analytics 에서 세 줄(PR 본문의 테스트별 수 · «까닭» · «시작 N → 끝 M» 은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다 · 12 §3 재발 방지 ①)
  flutter test test/rebalance_preview_view_test.dart   ← 끝 줄 «+40: All tests passed!» 기대(최소 목록의 경우 수 · 드라이런 보강 전 +39 → T76c-06 셋째 경우 +1 · 재측정 «+40» ✅ `dry/r12b-plus` `7272a43`)
  flutter test test/golden/s76c_golden_test.dart       ← «+10: All tests passed!» 기대
  flutter test                                         ← 끝 줄 = «끝 M»(기대 M = N + 50 · 드라이런 보강 전 354 → 403 · 보강판 재측정 354 → 404 ✅ `dry/r12b-plus` `7272a43`)

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · 설계서 §3-5 R12b 행 · golden README «🆕 R12» 절 표의 R12b 행 그대로)
  s76c_countdown   countdown(m7/m7_next_rebalance_countdown.json) · 탭 없음 · whatIf = 기본(버튼 있음) · 안전 행 0                                   ← 맨 아래 Key = s76c-preview-button
  s76c_none        none(m7/m7_next_rebalance_none.json) · 안전 행 0                                                                                    ← 맨 아래 Key = s76c-asof
  s76c_preview     countdown + 탭 → m7/m7_rebalance_preview_default.json · 안전 행 0                                                                    ← 맨 아래 Key = s76c-draft-asof
  s76c_draft_empty countdown + 탭 → m7/m7_rebalance_preview_in_band.json · 안전 행 0                                                                    ← 맨 아래 Key = s76c-draft-asof
  s76c_blocked     countdown + 탭 → m7/m7_rebalance_preview_blocked.json 행 0(버튼 없음) · 🔴 안전 = safety_states 행 4(LEDGER_INTEGRITY — 차단 행과 그 사유 플래그의 짝 · R11a s74_golden_test 선례)
                                                                                                                                                         ← 맨 아래 Key = s76c-blocked
  (행 1 = 재개 미완 차단·버튼 표본은 골든으로 찍지 않는다 — safety_states 에 RESUME_INCOMPLETE 행이 없어 «재개 미완 차단 + 플래그 0» 이 굳는다 · 미결 87 · 위젯 테스트 T76c-07·15·18 전용)
  모두 시계 = FixedClock(kGoldenNowUtc) · 크기 390 × 844(테스트 파일 안 상수 kS76cGoldenSize = Size(390, 844) — 기본 폰 높이 · 누적 드라이런 실측: 가장 깊은 s76c_preview dy 752 · 바꾸지 않는다).
  모양 = s79_golden_test.dart 처럼 (이름, 카운트다운 픽스처 경로, 탭 결과(없으면 null), 안전 행, 맨 아래 Key) 목록 × Brightness.values 루프 · 테스트 이름 '$name ${brightnessSuffix(b)}' ·
  골든은 '../rebalance_preview_fakes.dart' 로 import · 탭 결과가 있으면 FakeRebalancePreviewApi(result: …) · 없으면 FakeRebalancePreviewApi()(countdown 에 버튼이 보이게).
  pumpForGolden 뒤 pump() 한 번 더 → 탭 결과가 있으면 await tester.tap(find.byKey(const Key('s76c-preview-button'))) → await tester.pumpAndSettle() →
  찍기 전 위치 전제(golden README «R10» 절 «2. 높이와 위치 전제») — 한 곳:
    expect(tester.getBottomLeft(find.byKey(Key(bottomKey))).dy, lessThan(kS76cGoldenSize.height));   ← 맨 아래 = 위 표의 Key
  → await expectGolden(name, b);
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s76c_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 10장 + test/golden/s76c_golden_test.dart 만 ??((4) 커밋 전)
  🔴 다른 골든 테스트 파일을 --update-goldens 에 넣지 않는다(영영 아님).
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값을 질문 파일에 적는다.
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s76c_golden_test.dart 의 위치 전제 lessThan(kS76cGoldenSize.height) 한 곳을 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/s76c_golden_test.dart(--update-goldens 없이)
    → 테스트 이름('s76c_countdown light' … 10개)마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- test/golden/s76c_golden_test.dart 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · K21 = 카드마다 1개)
· S7-6c_questions.md — 머리말의 «다음 번호»(Q1·A1)부터 표 끝에 새 행만(머리말 불변 · S7-6ab_questions.md 는 R12a 몫 — 고치지 않는다) · Q = 질문 · A = 추측 · 새 행 = «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A5 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  권고와 다르게 지은 이름 · 2개 밖에 새로 더한 정적 라벨 · 문서에 없어 정한 것 전부.
    | A1 | R12b-Bob-S76c | 추측 | 측정: s76c_countdown dy 실측값 (light=<값>, dark=<값> < 844) | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
    (A2 = s76c_none · A3 = s76c_preview · A4 = s76c_draft_empty · A5 = s76c_blocked · 같은 형식 · 844 = kS76cGoldenSize 의 높이 · <값> 자리에만 잰 숫자)
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일·가짜·도우미 이름 · 정적 라벨 2개 · 읽지 않는 필드 목록(규칙 5) · 배치 순서 · s76c-asof 의 자리 · 고지의 자리 ·
  초안 영역의 기다림·에러 모양 · 칩 톤 표 · 골든 이름·입력·맨 아래 Key · 재량인 것(여백·글자 크기·모서리·경고 줄 색). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 카드에서 찾는다(«카드 지시대로»·«카드대로» 가 들어가는 행 금지) · 🔴 질문 파일은 브랜치에 커밋한다(채팅만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(5) 커밋이 끝난 뒤 — (5) 가 마지막 커밋)
  cd packages/ui_analytics
  위 «테스트 수 묶음» 세 줄   ← 전부 통과 · 끝 줄 셋을 적어 둔다(아래 ② 끝에 그대로)
  cd ../domain_contracts
  dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded   ← 0 실패 · 출력의 «C-42 ① 대상 S7-6c(R12b) 1파일 — …» 줄(파일 = lib/src/screens/rebalance_preview_screen.dart 하나)과
                                                                          «C-42 ① 역할 대상 합 …파일 · providers R12 절 …줄» 줄 — 아래 ① 에 그대로 붙인다
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 수정은 CI 포맷 게이트를 빨갛게 만든다
  git diff --name-status origin/main...HEAD
     ← test/golden/goldens/ 에서: 새 PNG = s76c_*.png 10장(A)뿐 · M PNG 줄 = 금지(재생성 0) ·
        test/golden/ 의 하네스·README·기존 골든 테스트 줄 = 금지 · R12a 파일 · R11 파일 · 기존 화면 · 기존 테스트 줄 = 금지 · domain_contracts/** 줄 = 금지 ·
        lib 줄 = 정적 묶음 S34 의 4줄뿐(하나라도 어긋나면 푸시하지 말고 멈춘 뒤 출력을 채팅으로)
  git push -u origin ui/m7-s76c-preview
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  git log --oneline origin/main..HEAD         ← 아래 ① 에 그대로 붙일 출력(5줄 — 맨 위 = (5))
  cd packages/ui_analytics → 위 «정적 묶음» 38줄 → 위 «테스트 수 묶음» 3줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  12항 원문 대조(출력은 붙이지 않는다 — 아래 ② 상자와 한 글자씩 대조용 · 저장소 뿌리에서):
    Git Bash   : sed -n '156,170p' docs/ai-context/prompt_M7.md   ·   sed -n '156,170p' docs/ai-context/prompt_M7.md | wc -l   ← «15»
    PowerShell : (Get-Content -Encoding UTF8 docs/ai-context/prompt_M7.md)[155..169]   ·   ((Get-Content -Encoding UTF8 docs/ai-context/prompt_M7.md)[155..169]).Count   ← «15»
    첫 줄 « 1. `ui_analytics`가 …» · 끝 줄 «    목표 경로 가정 카드가 …» 가 아니면(행이 밀렸으면) 멈추고 채팅으로.
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다(golden:approved 포함) · 🔴 PR 이 생겨도 그 본문을 직접 고치지 않습니다(통합 담당이 바꾼다 — 채팅으로만).
  PR 제목: [M7] S7-6c 다음 리밸런싱 · 지금 기준 초안
  PR 본문 5섹션을 채팅으로 — 섹션 머리는 아래 상자의 글자 그대로(순서 고정 · 머리를 바꾸거나 빼지 않는다):
      ┌── 섹션 머리(이 다섯 줄 글자 그대로)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └──
      (이 다섯 줄은 R12 네 장(R12a~R12d)이 같은 글자다 — 무엇을 어느 섹션에 붙이는지는 아래 ①~⑤ 설명이 정한다)
   ① 화면 ID(S7-6c — 다음 리밸런싱 · 지금 기준 초안) +
      바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(손으로 쓰지 않음 · A/M · PNG 포함) + 커밋 목록(git log --oneline origin/main..HEAD 출력 그대로 — (5) 가 맨 위) +
      C-42 두 줄(위 dart test 출력 그대로)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 12항이 15줄 그대로인지 셉니다 — 11번·12번은 각각 3줄·2줄(들여쓰기 4칸 줄 포함)이고, 한 줄로 잇지 않습니다(R11a 2회차에 틀린 곳) · 세는 명령(붙인 15줄만 저장소 밖 임시 파일에):
         PowerShell: (Get-Content "$env:TEMP\r12b_item12.txt" -Encoding UTF8).Count   ← 15   ·   bash: wc -l < "$TEMP/r12b_item12.txt"   ← 15(끝 줄 뒤 줄바꿈이 있을 때)
         (15 가 아니면 붙인 글을 고친다 · 이 명령의 출력 한 줄도 ② 에 붙인다)
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다(R10a · R10b 1회차에 틀린 곳).
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음 결과의 수):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «S7-6c 화면 산술 0 — 카운트다운·초안·비용 글자는 엔진 문자열 그대로(정적 S18·S24 · C-42 ③⑥)»
        3번 = «정적 묶음 S20 — 0건»
        4번 · 5번 · 7번 · 8번 = «이 카드 범위 밖»
        6번 = «앞절 S7-6c 초안은 previewRebalance 결과만 그린다(T76c-06) / 가운데 previewNotice 는 초안이 있는 동안 스크롤 밖 고정(T76c-11) / 뒷절 승인·실행·주문 버튼 0(T76c-15)»
        9번 = «as-of 는 화면에 1줄(s76c-asof) + 초안 기준 1줄(s76c-draft-asof) · 오래됨 배너 = StaleBanner(T76c-12)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 기존 PNG M 0 · domain_contracts 변경 0»
        11번 = «정적 묶음 S21 결과 <N>건 · 보강 S22 결과 <N>건 · S23 결과 <N>건»
        12번 = «이 카드 범위 밖(세후 사다리·목표 경로 가정 카드는 S7-7·S7-9 몫)»
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
      이어서 «정적 묶음» 출력 전부를 코드 블록 하나로 그대로 + S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄(괄호 금지 · 줄을 빼거나 줄이면 = 보고 불일치)
      + ⓡ·ⓗ = 아래 상자의 글자 틀 그대로 한 줄(<…> 자리에만 정적 묶음 S29·S30 출력 줄을 그대로 옮긴다 · test/ 를 떼지 않는다 · 손으로 쓰지 않는다 · R12a C12a-6):
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 1줄)
ⓡ = S29 출력 · ⓗ = S30 출력 = <S29 출력 줄 그대로> / <S30 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
      + «테스트 수 묶음» 3줄의 끝 줄 그대로(view · golden · 전체)
   ③ 스크린샷 서술 — 로딩·정상(카운트다운·탭 전)·빈(예정 없음)·차단(초안 차단 + 배너) 4줄 + 초안·빈 초안·뷰어 3줄 + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = rebalance_preview_screen.dart 의 build 가 그리는 배치(위 «화면» 의 배치 1~7 · 화면에서 위 → 아래) 순서로 위젯·Key 이름을 «→» 로 잇기만
         (조건부 = StaleBanner · SafetyBlockBanner · s76c-notice · s76c-draft-empty · s76c-blocked-action 에 «(있을 때)» · private 메서드가 파일 안 어디에 있는지는 순서와 상관없다) ·
         그려지는 순서가 배치 1~7 과 다르면 제출하지 말고 멈춘 뒤 채팅으로. 일곱 줄의 견본(«…» 자리는 «정상» 줄의 앞부분 그대로 · 이름만 잇는다):
         «로딩» = AnalyticsSkeleton(배너 없음) · «정상» = s76c-root → StaleBanner(있을 때) → SafetyBlockBanner(있을 때) → s76c-countdown → s76c-asof → s76c-preview-button ·
         «빈» = … → s76c-empty → s76c-asof(버튼·초안 부재) · «초안» = … → s76c-notice → s76c-countdown → s76c-asof → s76c-preview-button → s76c-draft → s76c-draft-empty(있을 때) → s76c-draft-asof ·
         «빈 초안» = … → s76c-notice → s76c-countdown → s76c-asof → s76c-preview-button → s76c-draft → s76c-draft-empty → s76c-draft-asof ·
         «차단» = SafetyBlockBanner 의 자리를 코드 그대로(«StaleBanner 아래 · Expanded(ListView) 바깥 위») + … → s76c-preview-button → s76c-blocked → s76c-blocked-action(있을 때) ·
         «뷰어» = … → s76c-countdown → s76c-asof(s76c-preview-button · 초안 영역 부재).
      🔴 «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지(R10c 1회차 반려 사유).
      골든 표 10행: 이름 · 입력 픽스처(경로 그대로 — 예 m7/m7_next_rebalance_countdown.json + m7/m7_rebalance_preview_default.json · 상수 이름과 섞지 않는다) · 크기 390×<높이> ·
        dy(이름·밝기마다 잰 값 · 질문 파일 A1~A5 와 같은 숫자) · 배치·잘림(PNG 를 열어 본 것만 · 꽉 찬 네모 = 테스트 글꼴 글자 · 글자 내용·글자 길이의 차이는 쓰지 않는다(위 보고 규칙 🆕 줄) · 못 본 것은 «미열람»).
   ④ 질문 목록 — 머리 «S7-6c 새 행:» 다음 줄에, 아래 명령 출력에서 «+|» 로 시작하는 줄 전부를 코드 블록 하나로 그대로(이 카드가 질문 파일에 더한 새 행 전부 — 측정 행 포함 · 앞의 + 와 줄 순서 그대로 · 줄을 고르거나 고쳐 쓰지 않는다 · 요지 표를 손으로 만들지 않는다 — R12a C12a-4 · R11b C4b-2):
      git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/S7-6c_questions.md   ← 저장소 뿌리에서 · 푸시한 그 커밋 위에서 · «+++ b/…» 줄은 넣지 않는다(표 행만)
      (셸에서 한글이 깨져 보이면 PowerShell 에서 [Console]::OutputEncoding = [Text.Encoding]::UTF8 를 한 번 돌린 뒤 다시 돌린다 — 출력을 손으로 고쳐 쓰지 않는다)
   ⑤ 추측한 것 = S7-6c_questions.md 의 새 A 행 중 «측정:» 이 아닌 행 전부 — 파일 접두를 붙인 번호로(예 S7-6c A6)(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 = 거짓 주장 = 반려)
   (+ 까닭 줄 — 아래 수가 이 카드의 기대와 다를 때만 한 줄씩: «까닭(<무엇>): <사실>» · 테스트별 수·줄 번호는 위 명령 출력 그대로만 쓴다(손으로 세지 않는다))
   (+ flutter test 한 줄 — 아래 상자의 글자 틀 그대로(기대 끝 = N + 50(뷰 40 + 골든 10) · 수를 따로 계산해 덧붙이지 않는다):
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄 · <…> 자리에만 출력 그대로)
flutter test: 시작 기준 <N> → 끝 <packages/ui_analytics 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 예 = R12a «끝 00:16 +354: All tests passed!» 꼴 — 시각·«+수»·«All tests passed!» 까지 출력 끝 줄 그대로 · «끝 354» 처럼 수만 쓰지 않는다 · R12a C12a-6))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s76c-preview` 푸시 1건 · 커밋 5개(본문 (1)~(5) · (5) format·질문 파일이 마지막).
- `lib/` 새 파일 **1**(`src/screens/rebalance_preview_screen.dart`) · 수정 3(`l10n/labels.dart` 끝 R12b 절 2개 · `src/providers/analytics_providers.dart` 끝 R12b 절(`analyticsWhatIfApiProvider` · `nextRebalanceProvider`) · `ui_analytics.dart` export 1줄(`rebalance_event_screen` 과 `rebalance_timeline_screen` 사이)). `lib/src/rebalance/preview/` 없음. 그 밖의 `lib/` 는 바뀌지 않는 것이 정상 · `test/` 새 파일 3(`rebalance_preview_view_test.dart` · `rebalance_preview_fakes.dart` · `golden/s76c_golden_test.dart`) + 새 PNG 10장(`s76c_*`) · 수정 0 · M PNG 0(기존 76장 불변).
- 질문 파일 `S7-6c_questions.md`(새 행 A1~A5 «측정:» 은 반드시 · 그 밖은 있을 때만) · 채팅 = 제출 글 ①~⑤(섹션 머리 다섯 줄 글자 그대로 · 내용 = «■ 제출» 의 ①~⑤).
- `flutter test` = 시작 기준 N(0단계 · 누적 드라이런 354 · R12a 병합본 실측으로 C4 가 ▶ 때 확인) + 새 50(뷰 40 + 골든 10 · «테스트 수 묶음» 끝 줄 · 수가 다르면 까닭 줄 · 적다고 곧 반려는 아님) · S29 = 16 · S30 = 6(🔴 정확히 — 다르면 반려) · S05 = 2줄 · S15·S16b = 시작 + 1 · S27 둘째 수 0 · S28 = 11줄 · S31·S32 = 1줄씩.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12b-Bob-S76c 결과: 브랜치 ui/m7-s76c-preview 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R12b-Bob-S76c 결과: PR #<번호> — 병합 검사하고 질문 반영해줘`(그 PR 본문은 Claude 가 5섹션으로 통째로 바꿉니다) · 0단계에서 멈췄다면 `R12b-Bob-S76c 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s7*`·`s76a_*`·`s76b_*`)가 `M` ② `pubspec.yaml` 변경 ③ `test/golden/` 하네스·README·기존 골든 테스트가 `M` · `lib/src/rebalance/preview/` 가 생김 ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime`·`Scaffold`·`planner`·`AppRoutes`·`elevation` ⑤ 원값을 읽거나 숫자를 글자로 만드는 코드(`.quantity`·`.total`·`toStringAsFixed`) · 승인·실행·주문 성격 버튼 ⑥ `initState`·`build` 안의 `previewRebalance` 호출 · `previewRebalance(plannedDate: …)` ⑦ ② 의 S05·S14·S15·S16b·S28·S31·S32 출력에 주석 줄·import 줄이 찍힘 · ⓡ·ⓗ 수(S29·S30)가 16·6 이 아님 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **새 PNG 만** 더하므로 `golden:approved` 라벨 없이 초록이어야 합니다(빨간색이면 기존 PNG 가 바뀐 것 — 반려 신호).
- 계약 테스트 C-42(R12 화면 소스 스캔 — ②~⑨ 역할 S7-6c · ⑩ 가드 · ⑬ providers R12 절) · C-35 ⑥(planner 방향) · T74-22(planner 낱말)는 Bob 브랜치가 들어와야 실제 파일을 봅니다 — 병합 검사 때 Claude 가 그 위에서 돌리고 «C-42 ① 대상 S7-6c(R12b) 1파일» 줄을 확인합니다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만). 그 밖의 알릴 것은 `_완료/R11b-Bob-S79.md` «5» 를 참고합니다.
- 드라이런 실측(누적 · 2026-10-12 · `C:/Work/AAQ-claude-review` · 가지 `dry/r12b` · 밑동 `7f72538`(R12a 드라이런 끝) → 끝 `a62f783` · 커밋 5개 · 카드 보강 전 판): 시작 기준 N = +354 · 끝 M = +403(= N + 49) · view «+39: All tests passed!» · golden «+10: All tests passed!»((2) 단계 중간 = 뷰 +12) · `kS76cGoldenSize` = Size(390, 844) · dy(light/dark) = s76c_countdown 224.0/224.0 · s76c_none 64.0/64.0 · s76c_preview 752.0/752.0 · s76c_draft_empty 596.0/596.0 · s76c_blocked 377.0/377.0(전부 < 844 · PNG 10장 열어 봄 · 잘림 없음) · 기존 PNG 76장 불변(HEAD 86장) · M PNG 0 · domain_contracts·pubspec·하네스 변경 0 · S05 2줄(106·288) · S15 6 → 7 · S16b 10 → 11 · S27 첫째 수 labels 4 / providers 14 / 배럴 1 · 둘째 수 0 · S28 11줄 · S29 16 · S30 6 · S31·S32 1줄씩 · C-42 ① 시작 «S7-6c(R12b) 0파일 · 합 2파일 · providers R12 절 24줄» → 끝 «S7-6c(R12b) 1파일 · 합 3파일 · providers R12 절 38줄» · import 실제 순서 = 카드 목록과 같음 · format 0 changed(299파일) · analyze --fatal-infos SUCCESS · domain_contracts dart test +297 ~30 0 실패 · C-42 +14 0 실패 · lib +325(screen 306 신규 · providers +14 · labels +4 · 배럴 +1 — 임계 +900 아래) · test +1171 · 새 testWidgets/test 줄 20 · 새 PNG 10 → 재분할 불필요 · 12항 원문 15줄 일치. 예고 변이(카드 30항목 · 변이 34개 주입) = 잡힘 30 · 살아남음 4(결과 캐시 · `s76c-asof` 를 `preview.asOf` 로 · 경고 줄 역순 · 초안 행 Wrap→Row) → 이 판 반영: T76c-05 다시 탭(`previewCalls.length` 2) · T76c-06 탭 뒤 `s76c-asof` == 카운트다운 asOf.label(이 둘은 드라이런에서 임시로 넣어 잡힘 확인) · T76c-06 셋째 경우 in_band_two_warnings(경고 2줄 순서 · 뷰 39 → 40) — ✅ 2026-10-13 재측정(`dry/r12b-plus` `7272a43` · 뷰 +40 · 골든 +10 · 354 → 404 · S29 16 · S30 6 · analyze No issues · 세 변이 잡힘) · Row 변이 문구를 엔진 문장으로 좁힘(초안 행 Wrap 은 대상 아님 — 2배 글꼴에서도 «매도 2주 16,380원» ≈ 308px 라 넘치지 않는다).
- 범위 고지: 전후 비중·조달 절 표시(01 §8 미결 92) · 뷰어 초안(미결 73) · 재개 미완 차단 골든·회차별 흐리게·배지(미결 87 · K22 권고 선반영 ~~🔴 확인 대기~~ ✅ 확정(2026-10-13)) · 사유 칩 핸드북 연결(미결 81) · advisory 초안 제목 표본(미결 71) · 홈 m8 «D-6» ↔ S7-6c «D-1» 교차 불일치(미결 84 · R13 전) · 셸 배선(`rebalancePreview` → `RebalancePreviewScreen()` · operator = 실구현 · viewer = `(_) => null` — 04 §1-2 · R13)은 이 카드에 없습니다.
