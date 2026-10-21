# 발송 패킷 R4a-Bob-H61 — H6-1 보유현황 (계약 v1.8 · R4 2장 중 1번째)

> ▶ **보낼 수 있음**(2026-10-21 발주자 확인 7건 = 기본값 그대로 · 이 파일이 GitHub `main` 의 `send/` 에 있으면 보낸다 · Bob **새 대화**) — ~~⏸ 아직 보내지 않습니다~~(2026-10-21 조립 · 기록 = 앱 가지 `rec/r4-h` 의 R4 조립 기록 커밋) — ✅ ① **누적 드라이런 끝**(2026-10-21 · worktree `C:/Work/AAQ-claude-r4dryA` · 가지 `dry/r4a` · 이 기록 커밋을 푸시 직전 `origin/main`(`3aa0ed8` — 엔진 PR #49·#50·#51 뒤) 위로 rebase 한 그 커밋에서 = «푸시 뒤 `main`» 흉내 · 실측 표식(부호 U+27E6) 0 · 지적 반영 판으로 다시 잼) ✅ ② 드라이런 브랜치 사전검사 🔴 0 ✅ ③ 재분할 불필요(R4a = 화면 1개 — 임계 = 새 `testWidgets(` 줄 > 33 · lib > +900 · 새 PNG > 16) — 남은 것 = ④ 발주자 확인(아래 «발주자 확인 대기» 7건) ⑤ 「푸시해」(🔴 푸시 전에 `rec/r4-h` 를 그때의 `origin/main` 위로 다시 rebase — 문서만이라 충돌 0 예상) → 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 → 머리 첫 줄 ▶. 선행 = ✅ **계약 v1.8 병합(앱 PR #48 · squash `dcac7ec` · 2026-10-21 · CI 3/3 · 가지 삭제)** — `main` 에 있다(0단계 확인 줄이 다시 본다). 🔴 Bob 의 현재 브랜치(`ui/m6-j4-review` · R3 병합됨)는 건드리지 않는다.
> 만든 날 2026-10-21 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R4a-Bob-H61` 행 + «R3 C4 이월 부록»(C4r3-1 · C4r3-4 · C4r3-5 = 이 카드 몫 · C4r3-8 = R4a 병합 기록 커밋(Claude) · C4r3-2·3·6 = infra 후보 · C4r3-7 = R13) + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · 커밋 = 제목만 맞추기 · 골든 높이 = 재량 + 기록 · 재제출 = 전체판 + 상자) · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-20_R4선행_계약v1.8_설계서.md` §2-5(공개 위젯·파일·주입) · §2-6(호출 표) · §2-7(상태 표) · §2-8(필드 → 자리) · §3-1b(갈래 ↔ 픽스처) · §3-4(골든 ↔ 입력) · §6(카드에 넘길 것) · §9 결정 K1~K29(✅ 전부 발주자 확정 2026-10-20·21) · 조문 = `01_…` §17(17-4 · 17-6 · 17-7 · 17-8 · 17-10 · 17-16) · `02_…` §4-1 + §4 끝 «🆕 계약 v1.8 — `H6-*` R4 범위 · 이 블록이 이긴다» 블록 ⓐ~ⓛ · 코드 = `packages/domain_contracts`(`HoldingsOverviewVm` · `HoldingsSleeveCard` · `HoldingsExternalSection` · `HoldingRow` · `HoldingPnl` · `SleeveAllocationRow` · `SleeveWeight` · `SleeveBandState` · `ExternalHoldingRow` · `HoldingsRepository.watchHoldingsOverview` · 받침대 `UnimplementedHoldingsRepository`) · 계약 테스트 C-44(`test/contracts/c44_holdings_test.dart` — 이 카드의 화면 파일이 처음으로 B 절 ⑬~⑲ 의 대상이 된다) · golden README «🆕 R4» 절(이 기록 커밋 몫).
> 사전 조건 — ✅ 계약 v1.8 병합(PR #48 · squash `dcac7ec` · `contractVersion '1.8.0'` · 픽스처 159 · 라우트 48 · `domain_contracts` 335 통과 · 30 skip · 0 실패 · `ui_journal` lib·테스트·PNG 변경 0 · PNG 72) · 그 뒤 앱 `main` = 엔진 PR #49 `bbcf06f` · #50 `f978706`(🔵 `domain_contracts/lib/testing.dart` +5줄(`what_if_rules` export) · 계약 테스트 C-38·C-41 수정 → `domain_contracts` **336** 통과 · 30 skip) · #51 `3aa0ed8`(core_engine 만) — `ui_journal` 영향 0(드라이런 실측). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 시작 기준 = 푸시 직전 `origin/main` 의 `flutter test`(packages/ui_journal) = **284**(드라이런 실측 · R3 병합본과 같다) · 이 카드 끝 기대 = 시작 기준 N + 38(뷰 28 · 골든 h61 10 · 드라이런 284 → 322).
> 카드 확정값(카드 권한 — 설계서 §6 «카드 조립 때 정할 것» ①~⑥ 을 이 카드가 정한다): 새 lib 파일 1개(`lib/src/holdings_overview.dart` · `lib/src/holdings/` 폴더 만들지 않음) · 정적 라벨 3개(`holdingsAvgPrice` 매수가 · `holdingsEntryDate` 진입일 · `holdingsRegisteredOn` 등록일 — 값 앞 머리) · Key 표 22이름(`h61-` 접두 · 순번만 · 에러 갈래 = `h61-fail`) · 「비중 보기」 = 머리·배너 바로 아래(02 §4-3 «`H6-1` 상단 「비중 보기」» · 손익 토글·카드보다 위) · 스켈레톤 = `JournalSkeleton` 무수정 재사용(6장 — 01 §17-7 «N 은 카드가 정한다» · 02 §4-1 «카드 3장» 과 다름 = 발주자 확인 ⑥) · 카드·시스템 밖 섹션 펼침 = 위젯 `State`(처음 전부 접힘) · 손익 토글 = 화면 단위 1개(`TextButton.icon` · 글자 = `pnlToggleLabel` 그대로 · 펼침/접힘 = 아이콘) · 테스트 파일 `test/holdings_overview_test.dart` + 가짜 `test/holdings_overview_fakes.dart` · 골든 5이름 10장(`test/golden/h61_golden_test.dart` · 크기 390 × 2480 — 다섯 이름 공용 상수 하나(j4 꼴) · `h61_empty` 는 아래가 비어도 그대로).
> 🔴 **보내는 조건(Claude 확인)** — 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/H61_questions.md` 가 `main` 에 있음(빈 머리말 — 이 기록 커밋이 만든다 · 카드마다 1개) + golden README «🆕 R4» 절이 `main` 에 있음(`git grep -c "h61_normal" -- packages/ui_journal/test/golden/README.md` = 숫자 하나) + 이 파일에 실측 표식 0(`LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R4a-Bob-H61.md` = 0 — Git Bash 기본 로캘에서는 `LC_ALL=C.UTF-8` 없이 오류가 나므로 오류를 0 으로 읽지 않는다 · 지금 남은 표식 = 드라이런이 채울 자리 전부) + 드라이런 브랜치 사전검사 🔴 0 + 재분할 불필요 판정. 0단계의 `ls`·`git grep` 줄이 그 증명입니다.
> 🔴 **카드 덮개 필수 문장(01 §17-7 · 02 §4 v1.8 블록 ⓐⓓⓔⓗ)** — «손익은 기본 접힘 — 진입 = `includePnl` false 구독 한 번 · 펼침 = 토글 탭으로 true 재구독(State 변수로만 · 리터럴 `true` 0) · 열람 기록 0» · «화면은 묶지도 거르지도 더하지도 가리지도 않는다 — 카드 수 = `cards.length` · 카드·행·섹션 = 받은 순서 · «?»·«숨김» 은 엔진 글자 그대로(아이콘 0)» · «이동 = 데이터 링크만(`detailDeepLink` · `allocationLink` · 칩 링크) — `AppRoutes` 상수 0 · Key = 순번만(`holdingId` 0)». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — 이 카드가 기대는 K6(묶인 VM 창구) · K10(가림 = 엔진) · K12(데이터 링크만) · K14(시스템 밖 섹션 = `ExternalHoldingRow` · 가리지 않음 · 뷰어 `external` null) · K15(뷰어 토글 부재) · K16 ⓐ(카드 수 = 데이터 — 슬라이스 테스트) · K16 ⓕ(RECON = 글자 끝 «?» · 아이콘 0) · K17(POT = A 카드 맨 끝 + `subBookLabel`) · K21(이름·자리) · K26(빈 = `emptyLabel` 만 · «모름» = 스켈레톤·에러) · K27(밴드 행 = B 만 · A·C 카드 머리 = `bandNoteText`) · K28(토글 = 화면 단위 1개 · autoDispose 0) · K29(INTEGRITY 트랜치 칩 `[]`) = **✅ 발주자 확정(2026-10-20 · 2026-10-21 · 전부 권고대로 · 01 §17-14)** — 카드 본문은 «확정»으로 인용한다.
> ✅ **발주자 확인 완료(2026-10-21 · ①~⑦ 모두 아래 기본값 그대로)**: ① 정적 라벨 3개(«매수가»·«진입일»·«등록일» — 값 앞 머리 · 엔진 글자가 이미 말한 것은 다시 말하지 않는다) ② 행에 `accountAlias`(계좌 별칭)·`TrancheStep.filledOn`(트랜치 날짜)·`ExternalHoldingRow.accountAlias` 를 그리지 않음(02 §4-1 행 목록·설계서 §2-8 대로 · POT 의 계좌는 `subBookLabel` 이 말한다) ③ 손익 펼침의 첫 값 전 = 본문 전체 스켈레톤(설계서 §2-7 «펼친 뒤 첫 값 전 = JournalSkeleton» 그대로 · 펼친 카드·섹션 State 는 유지) ④ C4r3-4·C4r3-5 = 카드 기본값(골든 흐름·위치 전제를 코드 견본으로 실음) ⑤ 배지 = `GateState` **아이콘**(02 §4-1·§4-2 «`GateBadge`(`state`로 색)» 을 J-5 선례대로 아이콘으로 갈음 · 칩 색은 기본) ⑥ 스켈레톤 = `JournalSkeleton` 6장(02 §4-1 «카드 3장 스켈레톤» 과 다름 — 공통 위젯 무수정 원칙 · 3장이면 새 조각이 든다) ⑦ 질문 파일 이름 `H61_questions.md`(J 꼴 — 하이픈을 뺌 · inbox/README «ID 원문 그대로»·S7-1 선례로 읽으면 `H6-1_questions.md` · 바꾸면 카드 0단계·■ 질문 파일·④ 명령·01 §17-16·12 R4a 행을 함께 고친다).
> 드라이런: ✅ `C:/Work/AAQ-claude-r4dryA` · `dry/r4a` · HEAD `06668f0`(`3aa0ed8` + 이 기록 커밋(지적 반영 전 판) 위 · 권장 4커밋 + 지적 반영 1커밋) · 시작 284 → 끝 «00:32 +322: All tests passed!»(N + 38) · 파일별 «+28»(holdings_overview_test) · «+10»(h61_golden) · `domain_contracts` «+336 ~30» · C-44 20/20(«⑫ 대상 H6 1파일» 2줄 그대로) · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0 · 🟡 8(전부 G1 — ■ 제출 🔵) · 정적 묶음 31줄 = 본문 기대 그대로(S02c 1·15 · S05 2 · S06 3 · S07 2 · S16 7 · S22 11/0·1/0 · S23 14 · S24 8 · S25 22이름) · `_kTallPhone` = 390 × 2480 · dy 표 = golden README «🆕 R4» · 새 testWidgets 줄 16 · lib +407/-0 · 새 PNG 10 → 재분할 불필요 · 예고 변이(이 판 목록) 전부 KILLED(변이 62 중 57 KILLED — 골든만 2 · 통과 5 = 목록 밖 참고 변이: 표본 없는 칸 4 + 링크 조립 1).
> 프롬프트 = `docs/ai-context/prompt_M6.md`(🔴 범위 치환값은 아직 R2b 판 — 2행 `{{범위}}` = `J-3 (+ R2 잔여 R-1~R-7)` · 104행 옛 화면 ID `H-1`~`H-3` · 106행 «이번 과제 범위:» · 116행 PR 제목 — 이 기록 커밋은 그 파일을 바꾸지 않는다 · 이 카드의 범위·브랜치·PR 제목은 이 패킷이 정한다 · 본문 «프롬프트보다 이 카드가 이긴다» ①⑭) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R3 의 대화를 기억하지 못합니다 — 0단계·규칙 요약·본받지 않는 것·코드 스케치·테스트 목록은 본문에 담았습니다.
> R3 교훈 반영: 🆕 **PNG 열람 = 이름마다 light 1장(5장)** — Bob 은 한 대화 이미지 20장 한도 · dark 행은 같은 이름 light 행의 칸 글자를 그대로 쓴다(위치 전제 dy 가 light 와 같을 때만 · 다르면 dark 도 연다) · 🆕 C4r3-1(구독마다 «로딩·에러 × 배너» 경우 — T61-12 · 안전 플래그 있음으로 띄워 «로딩·에러 갈래 배너 0» 단언) · 🆕 C4r3-4(골든 흐름 = 클로저 코드 견본) · 🆕 C4r3-5(위치 전제 = `expect` 코드 견본) · 카드 본문을 짧고 기계적으로(«스케치 그대로 짓기») · 사전검사 두 줄 · ⓡ·ⓗ 정확히 · else 없는 if 0 · 화면 Text 전부 견본(C4d-1) · «글자 줄 n = PNG 행 수»(C4d-5).

## 0. 한 줄 목적

슬리브 카드(받은 순서 · 처음 접힘 · 머리 = 밴드 문장·상태색 또는 `bandNoteText`) · 펼친 종목 행(표시 문자열·칩·배지 · 탭 = 데이터 링크) · 시스템 밖 자산 섹션(접힘 · 고지 상시) · 손익 펼침 토글(재구독) · 「비중 보기」 링크를 계약 v1.8 의 `HoldingsOverviewVm` 하나로 그리는 `H6-1` 화면(`HoldingsOverview()`)을 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-h61-holdings`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음 · 브랜치 이름 = 설계 12 §3 R4a 행 · 01 §17-16 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일 머리 첫 줄이 ▶ 일 때만 보냅니다** — ⏸ 이면 아직입니다(남은 것 = 머리 첫 줄 ①~⑤ · Claude 가 드라이런으로 실측 표식을 채우고 「푸시해」로 `main` 에 올린 다음 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R3 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R4a-Bob-H61.md> (로컬 사본 = Claude 기록 폴더 `C:\Work\AAQ-claude-r4rec\docs\ai-context\send\R4a-Bob-H61.md`(가지 `rec/r4-h` · 2026-10-21 Claude 작성) · 기록 푸시 뒤 `main` 과 글자가 같습니다). 🔴 `C:\Work\AAQ-claude\` 는 최신 `main` 을 받지 않아 이 파일이 없고, Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 R3 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부** — ```text 다음 줄(«R4a-Bob-H61 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `ui_journal` 의 끝난 카드 `_완료/R3-Bob-J4*.md` · `_완료/R2b-Bob-J3.md` 와 `_대기/R4b-Bob-H62H63.md`(R4a 병합 뒤 카드)를 붙여넣지 않습니다. `send/` 바로 아래의 보낼 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R4a-Bob-H61 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

```text
R4a-Bob-H61 — 범위: H6-1 보유현황(HoldingsOverview() — 머리(asOf) · 오래됨 배너 · 공통 배너 · 「비중 보기」(상단) · 손익 펼침 토글 · 슬리브 카드(받은 순서 · 처음 접힘 ·
  머리 = 밴드 문장·상태색 또는 bandNoteText) · 펼친 종목 행(표시 문자열 · 반영 대기 칩 · POT 하위 칩 · 사유 칩 · 트랜치 칩 · 배지 · 손익 줄) ·
  시스템 밖 자산 섹션(접힘 · 고지 상시) · 빈 문장) + 주입 프로바이더 1 + 데이터 프로바이더 1 + 정적 라벨 3 + 배럴 export 1줄.
🔴 손익은 기본 접힘 — 진입 = watchHoldingsOverview(includePnl: false) 한 번 · 펼침 = 토글 탭으로 true 재구독(State 변수로만 · 리터럴 true 0) · 열람 기록 0.
🔴 화면은 묶지도 거르지도 더하지도 가리지도 않는다 — 카드 수 = cards.length · 카드·행·섹션 = 받은 순서 · «?»·«숨김» 은 엔진 글자 그대로(아이콘 0).
🔴 이동 = 데이터 링크만(row.detailDeepLink · vm.allocationLink · 칩 detailDeepLink) — AppRoutes 상수 0 · Key = 순번만(holdingId·symbol 0).
하지 않는 것: H6-2 종목 상세 · H6-3 슬리브·비중(R4b) · 손절선·모멘텀 패널(H6-2 몫) · 게이지·잔고 막대(H6-3 몫) · J·H6-3 → H6-1 역참조 링크(01 §8 미결 110) ·
  셸 몫(라우트 holdingsOverview 배선 · 하단 탭 「보유」 · 웹 «부재» 가드 · 조립 앱 override — M8 · R13) · 웹 3열 그리드·통합 표·카드별 동기화 칩(Q-D 뒤) ·
  기존 화면(J-1~J-5) 코드·테스트 수정 · journal_common.dart 수정.
🔴 이 카드가 docs/ai-context/prompt_M6.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 20항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R3(ui/m6-j4-review — 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/holdings_overview.dart · journalHoldingsRepositoryProvider · Key h61-asof 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-j4-review 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상
  git checkout --no-track -b ui/m6-h61-holdings origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c "contractVersion = '1.8.0'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»(계약 v1.8 병합)
  git grep -c "abstract class HoldingsOverviewVm with" -- packages/domain_contracts/lib/src/dto/holdings.dart                  ← «…holdings.dart:1»
  git grep -c "abstract class HoldingsSleeveCard with" -- packages/domain_contracts/lib/src/dto/holdings.dart                  ← «…holdings.dart:1»
  git grep -c "Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false});" -- packages/domain_contracts/lib/src/repositories/holdings_repository.dart   ← «…holdings_repository.dart:1»
  git grep -c "class UnimplementedHoldingsRepository implements HoldingsRepository" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»(받침대)
  git grep -c "enum SleeveBandState" -- packages/domain_contracts/lib/src/enums/rebalance.dart                                 ← «…rebalance.dart:1»
  git grep -c "static const String holdingsOverview = 'aaq://holdings/overview';" -- packages/domain_contracts/lib/src/navigation/app_links.dart   ← «…app_links.dart:1»(읽기만)
  ls docs/ai-context/send/R4a-Bob-H61.md                                             ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls docs/ai-context/inbox/H61_questions.md                                          ← 보여야 함(빈 표가 이미 있다)
  ls tool/precheck.dart                                                              ← 보여야 함(푸시 전 사전검사 — ■ 제출)
  ls packages/domain_contracts/test/contracts/c44_holdings_test.dart                 ← 보여야 함(C-44 — 이 카드의 화면 파일이 처음 대상이 된다)
  ls packages/domain_contracts/fixtures/m6/holdings_overview_normal.json             ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holdings_overview_recon.json              ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holdings_overview_integrity.json          ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holdings_overview_empty.json              ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holdings_overview_pnl.json                ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holdings_overview_viewer.json             ← 보여야 함
  git grep -c "h61_normal" -- packages/ui_journal/test/golden/README.md                                                        ← 숫자 하나(golden README «🆕 R4» 절 — 기록 커밋 몫)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir · && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 네 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R4a 가 들어간 것 — 멈추고 알림):
  ls packages/ui_journal/lib/src/holdings_overview.dart                              ← 없어야 함
  git grep -c journalHoldingsRepositoryProvider -- packages/ui_journal/lib           ← 출력 없음이어야 함
  git grep -c h61- -- "packages/ui_journal/*.dart"                                   ← 출력 없음이어야 함(.dart 만 본다 — golden README 의 R4 절은 h61 글자를 담고 있어도 정상)
  git grep -c holdingsAvgPrice -- packages/ui_journal/lib                            ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.8 새 타입(HoldingsOverviewVm · SleeveBandGauge …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류). «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_journal
  flutter test   ← 시작 기준: 계약 v1.8 병합본 전부 통과 · 0 실패 · 기대 «+284: All tests passed!»(드라이런 실측 · 끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · README 의 수치는 보지 않는다 ·
                   그 수와 다르면 멈추지 말고 PR 본문에 까닭 한 줄 — 그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·C-44) > 이 카드(지시) > 01 §17 > 02 §4 끝 v1.8 블록 > 02 §4-1 본문·그림 M6-15·M6-16 > prompt_M6.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · «설계서 §n» 은 출처 표시일 뿐(Bob 은 설계서를 열지 않는다 — 정본 = 이 카드의 글자))
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox/H61_questions.md 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart·test/contracts/** 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·README · 기존 골든 테스트 파일 · 기존 PNG 전부(72장 — 하나라도 M 이면 되돌리고 멈춤) ·
   lib 의 기존 파일 전부(lib/src/common/journal_common.dart · timeline.dart · blind_review.dart · decision_detail.dart · journal_read.dart · unknown_board.dart · journal_draft/** · lib/journal_draft.dart) · 기존 테스트 파일 전부.
   공용 파일 2개는 **더하기만** 한다 — 기존 줄은 한 글자도 바꾸지 않는다(정적 묶음 S22 의 삭제 수 0 이 증명):
     lib/l10n/labels.dart = 파일의 마지막 절(R3 절 — blindReviewNext) 뒤에 이 카드의 절 하나 ·
     lib/ui_journal.dart = export 한 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
 2 H6-1 은 받은 글자와 null 여부만 본다 — 값 = DTO 의 *Text·*Label·label·원문 그대로 · 계약이 주는 표시 값은 전부 그린다(아래 3 의 «읽지 않는 필드» 는 예외) ·
   원값(int·double·Decimal)·.wire·키(holdingId·symbol·sleeve) 표시 금지 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = lib/l10n/labels.dart 의 JournalLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S19 는 주석 줄도 센다.
 3 읽지 않는 필드(카드가 정함 — 질문 아님): HoldingRow 의 symbol · sleeve · accountAlias · quantity · avgPrice · entryDecision · stopLine · momentum · scope · scopeLabel · asOf · holdingId(Key·글자 모두) ·
   HoldingPnl 의 unrealizedPnl · pnlPct · TrancheStep 의 stepNo · filledOn(트랜치 칩 = label + filled 아이콘만) · GateBadge 의 code · blockedReasonCode(배지 = label + state 아이콘만) ·
   HoldingsSleeveCard.sleeve · SleeveAllocationRow 의 sleeve · basis · sleeveLabel · deployedText · parkingText · deployedRatio · parkingRatio · trancheStateText · deployedPctText · parkingPctText ·
   parentSleeve · engineColumnNote · parkingNoteText · gauge · stateChips(이 열들은 H6-3 몫 — H6-1 카드 머리는 sleeveWeight?.label · bandNoteText · bandState · bandStateLabel 넷만) ·
   SleeveWeight 의 sleeve · weight · targetWeight · bandLow · bandHigh · basis(label 만) · ExternalHoldingRow 의 externalId · symbol · accountAlias · quantity · scopeLabel · decision(행 = symbolLabel · quantityText · registeredOn 셋만).
   🔴 C-44 ⑮ 는 .quantity .avgPrice .unrealizedPnl .pnlPct .level .weight .symbol .sleeve .scope .scopeLabel .basis .entryDecision .code .wire 류와 holdingId 표시·Key 를 기계로 본다(주석은 빼고 · 문자열 리터럴은 남김) — 정적 S10 이 이 카드의 넓은 목록을 본다.
 4 이동 = AppLinkOpener.open(link) 하나(journalLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(행은 탭 반응 없음 · 버튼은 그리지 않음) ·
   Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백·인자 금지(HoldingsOverview 의 생성자에는 key 뿐).
   이 화면 파일이 직접 여는 링크는 둘이다: 행의 row.detailDeepLink · 「비중 보기」 vm.allocationLink.deepLink. 칩 detailDeepLink 는 JournalReasonChip 이 · 배너 clearDeepLink 는 공통 배너가 안에서 연다(기존 위젯 그대로).
   이 카드가 쓰는 AppRoutes 상수는 0 개다(holdingsOverview · holdingsDetail · holdingsAllocation 은 셸 R13 이 배선 — 읽기만 · check_boundaries [5b] · C-44 ⑱).
 5 화면 산술 0 — 카드·행·칩을 거르지도 세지도 정렬하지도 자르지도 묶지도 옮기지도 않는다(카드 = cards 받은 순서 · 행 = rows 받은 순서 · 순번 = .indexed 의 i) · 목록 길이·int 를 글자로 0 ·
   C-44 ⑰ 낱말 0(.where .sort .sorted .reversed .take .skip .fold .reduce .toSet .compareTo .last .lastOrNull .sublist .getRange .elementAt .removeAt .removeWhere .retainWhere .shuffle ·
   .contains( .split( .substring( .replaceAll( .startsWith( .endsWith( .indexOf( .trim( · maxLines · TextOverflow.ellipsis · reverse: true · groupBy · FlagIds · activeFlags · markerOnly) —
   .indexed · .map · .isEmpty · .isNotEmpty · .length 비교 · [0] 은 허용(🔴 펼침 상태는 Map<int, bool> 로 — Set.contains( 는 ⑰ 에 걸린다).
   허용되는 산술은 신선도 한 식뿐이다(vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc()) — J-1·J-4 와 같은 식). 이 화면에 × 폭·기하는 없다(게이지·막대 = H6-3).
 6 switch 는 열거값 전수 — C-12 가 «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 기계로 막는다.
   이 카드의 열거형 switch 는 둘이다: SleeveBandState 3값(상태색 하나 — inBand → colorScheme.primary · nearEdge → tertiary · outOfBand → error · 정적 S28 = 3줄) ·
   GateState 4값(배지 아이콘 하나 — pass → Icons.check_circle_outline · block → Icons.cancel_outlined · notApplicable → Icons.radio_button_unchecked · unknown → Icons.help_outline · J-5 와 같은 매핑 · 정적 S29 = 4줄).
 7 시계 = journalClockProvider(DateTime.now()·DateTime.timestamp()·clock.now() 금지 — 주입 Clock.nowUtc() 만) · 쓰는 자리 = 신선도 한 식(정상·빈 갈래 머리).
   공통 상태 = 스켈레톤(JournalSkeleton · 스피너 금지) · 에러 = JournalErrorView(onRetry: invalidate · lastAsOfLabel: 그 AsyncValue 의 valueOrNull?.asOf.label) · 오래됨 = JournalStaleBanner ·
   차단 = JournalSafetyBanners(safety: ref.watch(journalSafetyStateProvider).valueOrNull) — 🔴 이 파일에 .watchState( · FlagIds · activeFlags 0(분리는 공통 조각 안) ·
   🔴 플래그로 카드·행을 끄거나 값을 바꾸지 않는다(배너만 얹는다) · 🔴 로딩·에러 갈래에서는 배너를 그리지 않는다(값이 온 뒤에만 — 정상·빈·가림 갈래 · C4r3-1 — 구독마다).
 8 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지 — 🔴 C-44 ⑱ 은 «Scaffold» 를 부분 일치로 보므로 ScaffoldMessenger 도 걸린다 · 주석에도 이 낱말 0 · 정적 S09) ·
   ListView 에 padding 을 주지 않는다(골든 위치 전제 «머리 dy == 0») · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장에 FittedBox·말줄임·maxLines·trim 금지 · 390px overflow 0 · 글꼴 200% overflow 0(T61-14) ·
   선 굵기·간격·크기는 정수·N.0·colorScheme 만(소수부 ≠ 0 소수 리터럴 0 — C-44 ⑲ · 정적 S21) · 띠 높이 예약 금지 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
 9 프로바이더는 둘만 더한다 — 주입 journalHoldingsRepositoryProvider(기본 throw UnimplementedError) + 데이터 _holdingsOverviewProvider(StreamProvider.family · 열쇠 = bool includePnl) ·
   🔴 둘 다 holdings_overview.dart 안(아래 «주입 구조» 글자 그대로 · R4b 가 import 해서 재사용) · autoDispose 0(J-1·J-4 꼴 · 정적 S15 — 그래서 접기 = 캐시된 false 값 · 새 호출 0) ·
   기존 프로바이더(journalSafetyRepositoryProvider · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider)는 이름·타입·위치 그대로 ·
   🔴 이 파일에 journalTimelineRepositoryProvider · journalConfigRepositoryProvider · journalCommandApiProvider · journalDraftStoreProvider 0(C-44 ⑬ · 정적 S08) ·
   주입 프로바이더는 탭 핸들러 안에서 ref.read 만 · 데이터 프로바이더는 build 에서 ref.watch · 🔴 펼침 상태(손익·카드·섹션)는 위젯 State 필드 — 전역 프로바이더 금지(재진입 = 접힘).
10 테스트 = testing.dart 받침대 extends(UnimplementedHoldingsRepository · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 · 호출마다 새 Stream ·
   전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지(예: expect(calls.length, greaterThanOrEqualTo(calls.length)) · expect(x, anything)) ·
   정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처에서 — 🔴 HoldingsOverviewVm(…) · HoldingRow(…) 생성자 0) · 허용되는 copyWith 는 이 한 꼴뿐: normal.copyWith(cards: normal.cards.sublist(0, 2))(T61-02 · 카드 수 = 데이터 증명 · K16 ⓐ · 값을 더하지 않는다 · j5_long_open 선례) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 가짜의 호출 기록은 목록 == 목록으로(🔴 기록 목록에 hasLength 를 쓰지 않는다 — ⓗ 수가 달라진다) ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0) 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴(경우 목록의 bool) ·
   테스트 이름은 번호 + ASCII(예 'T61-02 card count follows data first_two') · 새 테스트 파일의 문자열 리터럴은 전부 ASCII 만(이름 · reason: · 그 밖 모두 — «—»·«→»·«·» 도 금지 · 정적 S01·S02a·S02b · 한국어가 필요하면 \u 이스케이프) ·
   목록·집합을 «있으면 넣는다»로 만들 때는 null-aware 원소(?row.pendingText · ?v.allocationLink?.label)로 만든다 — 🔴 collection-if 0 · else 없는 if 0(SDK ^3.13 · 사전검사 T1·T2) ·
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다 · 스켈레톤 1 = expect(find.byKey(const Key('h61-loading')), findsOneWidget) — 스피너 부재로 대신하지 않는다 ·
   테스트는 package:ui_journal/src/common/journal_common.dart 를 직접 import 해도 된다(JournalErrorView 는 배럴이 export 하지 않는다) ·
   Key 를 단 Text·칩은 그 안 글자 == 픽스처 필드까지 본다(Key 가 있는지만 보지 않는다) · if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 ·
   카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 늦게 구독되거나 값을 끝까지 내지 않는 StreamController 의 teardown = addTearDown(() { unawaited(ctrl.close()); })(addTearDown(ctrl.close) 는 구독자 0 이면 매달린다).
   ⓡ = 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing); 를 **한 줄에 하나**(여러 경우를 도는 테스트는 본문에 한 줄) ·
      ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 전제 한 줄. 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄이어야 한다(사전검사 T5 · 접히면 기대 수를 final int 변수로 받아 줄을 짧게) —
      정적 묶음 S23·S24 가 git grep -c 로 센다 — 🔴 아래 최소 목록의 ⓡ·ⓗ 표시 수와 **정확히** 같아야 한다(test/holdings_overview_test.dart ⓡ 14 · ⓗ 8 · 다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 · 다른 채 내면 반려).
   🔴 ⓗ(hasLength)를 두는 곳은 아래 최소 목록에 ⓗ 로 표시한 자리뿐이다(8). 그 밖의 루프·기록 목록·경우 목록에는 hasLength( 를 쓰지 않는다.
   🔴 금지하는 if 는 «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기 · 빈 if 블록 · 목록에 넣기)와 firstWhere 다. 양쪽에 expect 가 있는 if/else 는 허용한다.
      «없는 쪽» 견본 — 코드 글자로(조건·변수 이름은 재량):
        if (row.pendingText != null) {
          expect(find.descendant(of: find.byKey(ValueKey<String>('h61-pending-$c-$r')), matching: find.text(row.pendingText!)), findsOneWidget);
        } else {
          expect(find.byKey(ValueKey<String>('h61-pending-$c-$r')), findsNothing);
        }
        🔴 반려 꼴(else 없는 if): if (row.pendingText != null) { expect(…, findsOneWidget); } · 🔴 if 를 for (… in <T>[?x]) · ?.let 류로 감추는 꼴도 반려(R3 C3-1).
   «화면의 Text 전부» 단언은 이 코드 글자 꼴로 쓴다(T61-09 · C4d-1):
          final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
          expect(shown, isNotEmpty);
          for (final String? data in shown) {
            expect(data, isIn(allowed));
          }
        (allowed 는 null-aware 원소로 만든 Set<String> · data 가 null(Text.rich 등)이면 실패한다 — 그것이 의도다 · RichText·SelectableText·Text.rich 는 이 파일에 쓰지 않는다 = 정적 S27)
11 골든 = 새 PNG h61_* 10장 · --update-goldens 는 그 골든 테스트 파일만(폴더 지정 금지) · 기존 PNG 재생성 0 · golden:approved 는 안 붙임(통합 담당 — 이 카드는 새 PNG 만이라 필요 없을 것) ·
   찍기 전 위치 전제 둘(맨 아래 위젯 dy < 높이 · 머리 dy == 0 — 아래 «골든»).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(멈출 수 있다) · 패키지 테스트는 packages/ui_journal 에서 flutter test 를 직접 ·
   package:collection 없음 · unawaited_futures 린트 · directives_ordering 린트(import·export 는 경로 알파벳 순) · strict-raw-types·strict-inference(타입을 적는다).
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   이 카드의 위험: JournalLabels.holdingsAvgPrice · row.avgPriceText · gain.pnlText · gain.pnlPctText 옆에 연산자 0 · 지역 변수 이름에 price·pnl·pct·ratio 금지(스케치의 gain · expanded 처럼 짓는다) · 글자 잇기 0(라벨과 값은 Text 두 개).
14 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다**(C-44 는 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄(holdings_overview.dart 전부 · labels.dart 의 새 절)의
   주석에 이 낱말을 쓰지 않는다: AppRoutes · AppLinkSchemes · journal_draft · journalHoldingsRepositoryProvider · journalLinkOpenerProvider · watchHoldingsOverview · includePnl · SleeveBandState. · GateState. ·
   Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · toStringAsFixed · NumberFormat · GestureDetector · Colors · Scaffold · AppBar · SafeArea · SnackBar · autoDispose · RunMode · operatingMode ·
   FeatureFlags · watchState · maxLines · TextOverflow · .trim( · .where · .contains( · Decimal · Money · holdingId · .quantity · .symbol · .sleeve(카드 문장을 가드 주석으로 옮겨 적지 않는다 · 주석은 짧게).
🔴 보고 규칙(strict 나눔 — 발주자 결정 2026-10-01 · 12 §3 공통 조문) —
   ① 보고 **표기만**의 결함(경로 앞머리·백틱·요지 줄임·까닭 누락 등 — 내용은 사실이고 글자 모양만 카드와 다른 것) = 반려하지 않는다 → 통합 담당이 PR 본문을 정정하고 병합한다.
   ② **코드·테스트 결함**(카드 규칙 위반 — 예 규칙 10 «else 없는 if»)과 **거짓 주장**(보고 내용이 코드·파일·PNG 와 다름) = **반려**(재량 없음).
   ③ 아래 «예고 변이» 가 하나라도 테스트를 그대로 통과하면 = **반려**.
   그래도 원칙은 «출력 그대로» 다 — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 골든 표는 PNG 를 열어 픽스처와 대조한 뒤 «배치·잘림»만 적습니다(글자는 테스트 글꼴이라 네모).
   🆕 PNG 는 이름마다 light 한 장만 연다(5장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행의 칸 글자 그대로(위치 전제 dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 열어 본 것을 쓴다).
   배치·잘림 칸에는 PNG 에서 보이는 것만 쓴다 — 글자 내용·글자 길이의 차이 · «띠» · «고정» · «스크롤 밖» · 색·테마 이름(«밝은»·«어두운» 은 이 칸에 쓰지 않는다) · 코드 이름(위젯·필드·Key — Row · Card · label 같은 낱말) ·
      픽스처 낱말 금지 · 버튼은 «버튼 글자» 로만 · 칸 끝은 «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» 둘 중 하나로 고정(꼴 = «■ 제출» ③ 골든 표 줄).
   셈 단위 — «글자 줄 n» = PNG 에 보이는 글자 **행** 수(줄바꿈된 행도 센다 · Text 위젯 수가 아니다 · 예 «글자 8줄(줄바꿈 포함)») · «상자» = 테두리·모서리가 보이는 덩어리 · 폭 전체 배경은 «배경 덩어리» ·
      «칩 n개» = 한 무리의 칩 개수(한 무리가 두 행으로 줄바꿈돼도 하나) · «상자» 속 글자 행은 세지 않는다(상자 하나뿐인 화면만 «상자 안 글자 n줄»).
   🔴 PR 본문은 통합 담당이 바꾼다 — Bob 은 PR 을 만들지 않고 GitHub 에서 PR 본문을 직접 고치지 않는다(채팅으로만 낸다 · 통합 담당이 «■ 제출» 의 섹션 머리 ①~⑤ 글자 그대로 PR 본문을 통째로 쓴다).
   🔴 정적 묶음 S05 의 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만 적습니다 — 괄호·위젯 이름·매개변수 이름·설명 금지(사전검사 R4).
   🔴 «까닭» 류의 수(테스트 파일별 통과 수 · ⓡ·ⓗ · S05~S07 줄 수 · C-44 대상 수 · 10항 줄 수)는 손으로 세지 않는다 — 이 카드가 준 명령의 출력을 그대로 붙인다.
   자체 점검 ② 는 «■ 제출» ② 의 복사 상자(= prompt_M6.md 159~168행 10항 글자 그대로)를 그대로 붙인 뒤 [x] 와 괄호 근거만 채웁니다(범위 밖도 [x] + 괄호 · [—] 금지 · 사전검사 R5).
   ③ 은 코드를 위에서 아래로 읽으며 나오는 위젯·Key 이름 나열로만 씁니다(«순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지).
   질문 파일에 카드 지시 이행 내역을 추측 행으로 적지 않습니다(골든 위치 전제의 dy 는 예외 — «측정:» 행). 새 행의 상태는 «⬜ 미답» · 답 칸 비움.

■ 프롬프트보다 이 카드가 이긴다 — 20항 (prompt_M6.md 행 번호 = 169줄 판 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 2행 치환값 {{범위}}=«J-3 (+ R2 잔여 R-1~R-7)» · 106행 «이번 과제 범위» → 이 카드의 범위 = H6-1 하나(위 첫 줄) · ※ «첫 과제는 J-1 하나» 도 덮는다
 ② 104행 «H-1 슬리브 A/B/C · H-2 종목 상세 · H-3 …» → 화면 ID = H6-1 · H6-2 · H6-3(01 §17-3 · 옛 ID H-1~H-3 은 2026-10-20 이전 문서 글자)
 ③ 11행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변)
 ④ 12~13행 «라우트 상수로 딥링크» → DTO 링크(row.detailDeepLink · vm.allocationLink · 칩 detailDeepLink)를 AppLinkOpener.open 에 · 쓰는 AppRoutes 상수 0(규칙 4)
 ⑤ 21~23행 «건수 집계도 재계산» → 그대로 유효 — 카드·행 수를 세어 글자로 만들지 않는다
 ⑥ 28~30행 «목록이 비면 그 자리를 그리지 않는다» → cards 빈 = emptyLabel 한 문장(빈 갈래) · 칩 목록 0 = 칩 줄 0 · pendingText·subBookLabel·bannerText null = 그 칩·줄 부재
 ⑦ 38~41행 자리표시자 → 링크 null = 부재
 ⑧ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ⑨ 48~54행 수치·금액 리터럴 금지 → 그대로 유효 · «%»·«원»·«주» 는 엔진 글자(화면 리터럴 0 · C-44 ⑲ · 정적 S21)
 ⑩ 88~89행 «자체 점검 10항 체크박스» · «스크린샷 4장» → «■ 제출» ②(10항 복사 상자) · ③(서술 + 골든 표)
 ⑪ 88~90행 PR → 만들지 않음(브랜치 푸시까지 · 5섹션은 채팅 · PR 본문은 통합 담당이 바꾼다)
 ⑫ 93~94행 «픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조» → 그대로 유효(재생성 0)
 ⑬ 102~105행 역할 문단 → 폰 세로 하나(H6-1 본문 = Android·iOS · 웹 = Q-D 전 «부재» 가드 · 셸 몫)
 ⑭ 107~114행 «읽을 문서 5개» → 아래 «먼저 읽을 것» · 116행 브랜치 예시·PR 제목 치환값 → 브랜치 ui/m6-h61-holdings · PR 제목은 «■ 제출» 이 정한다(«[M6] H6-1 보유현황»)
 ⑮ 118~120행 «「현재」는 전일 종가 기준 · 기준일 고지 = AsOf.label 그대로» → 그대로 유효(머리 = vm.asOf.label · 행의 asOf 는 읽지 않는다)
 ⑯ 121~122행 «목록은 ListResult<T> 봉투» → H6-1 은 봉투 없는 VM(HoldingsOverviewVm) — 빈 = vm.emptyLabel · «모름» = 스켈레톤·에러(EmptyKind 없음 · K26)
 ⑰ 124~125행 «watchHoldings() 기본 구독은 includePnl: false» → H6-1 창구 = watchHoldingsOverview — 진입 false · 펼침 = true 재구독 · watchHoldings 는 부르지 않는다(C-44 ⑬)
 ⑱ 126~130행 «슬리브는 A/B/C 3칸 · SAT 칸 … 숨김 · POT … ⚠️ SleeveAllocationRow 미정의 → 픽스처 고정 모드» → 카드 수 = cards.length(화면은 3 을 모른다 · FeatureFlags 0) · POT 행 = 엔진이 A 카드 맨 끝에 넣어 준다(subBookLabel 칩) ·
    SleeveAllocationRow = 계약 v1.8 정의(고정 모드 아님 · 창구로 받는다)
 ⑲ 155~157행 «⚠️ M2 미정의 7건(… H-1/H-3 슬리브 배분 행 · H-2 손절선 정규값 …) — 이름을 지어내지 말고 요청 목록으로» → H6-1 = 계약 v1.8 정의(HoldingsOverviewVm · HoldingsSleeveCard · HoldingsExternalSection) — 지어낼 이름 없음
 ⑳ 158행 «명세 §7과 1:1» · 162행 자체 점검 4 · 163행 자체 점검 5 → 159~168행 10항(이 카드 밖의 5 «J-4» · 9 의 «부분 동기» 는 [x] + 괄호 «이 카드 범위 밖») · 97~99행 «TODO(question-3) 자리표시자» → 넣지 않는다 · 질문 파일로

■ 먼저 읽을 것 (🔴 03·04·05 명세는 읽지 않음 · 02 는 아래 ③ 의 두 자리만)
 ① prompt_M6.md 전문
 ② 01 §17 — 17-1(한 문장) · 17-4(창구 3 · 엔진 의무) · 17-6(필드 → 자리) · 17-7(상태 표) · 17-8(주입·호출 표) · 17-10(픽스처 — ①~⑤·⑱) · 17-16(이 카드)
 ③ 02 §4-1 «`H6-1` 보유현황» + §4 끝 v1.8 블록 — 머리글 «🆕 계약 v1.8 — `H6-*` R4 범위»(찾는 말 = «R4 범위 · 이 블록이 이긴다») ⓐ~ⓛ
 ④ packages/domain_contracts/lib/ — src/dto/holdings.dart(HoldingRow · TrancheStep · HoldingPnl · HoldingsOverviewVm · HoldingsSleeveCard · HoldingsExternalSection) ·
    src/dto/rebalance.dart(SleeveAllocationRow · SleeveWeight) · src/enums/rebalance.dart(SleeveBandState) · src/dto/ledger_trust.dart(ExternalHoldingRow) · src/dto/common.dart(ReasonChip · LinkAction · GateBadge) ·
    src/enums/ui.dart(GateState) · src/repositories/holdings_repository.dart · testing.dart(UnimplementedHoldingsRepository · UnimplementedSafetyRepository · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c44_holdings_test.dart 머리 주석 + «B. 정규식» 절(⑫~⑲ — 읽기만 · 이 카드의 화면 파일이 처음으로 그 대상이 된다)
 ⑥ packages/ui_journal/test/golden/README.md «🆕 R4» 절(기록 커밋 몫) + «🆕 R3» 절(흐름 클로저 꼴) + «🆕 R2» 절(높이 · 베이스라인 규칙) + «규칙»·«하네스» 절
 ⑦ 지금 코드(packages/ui_journal) — lib/ui_journal.dart · lib/l10n/labels.dart · lib/src/common/journal_common.dart 전문 · lib/src/timeline.dart 머리 40줄(주입 프로바이더) + journalSafetyStateProvider ·
    lib/src/blind_review.dart(프로바이더·when 갈래·빈 갈래의 원형 — 틀만) · lib/src/unknown_board.dart(GateState 아이콘 매핑 — 틀만) ·
    test/blind_review_fakes.dart(가짜·도우미 모양) · test/golden/j4_golden_test.dart(흐름 = 클로저 · 위치 전제) · test/golden/golden_support.dart
 ⑧ packages/domain_contracts/fixtures/README.md 의 «계약 v1.8» 절 + 이 카드가 쓰는 픽스처(아래 «픽스처») ⑨ docs/ai-context/inbox/README.md · H61_questions.md 머리말

■ 본받지 않는 것 (ui_journal 의 기존 코드에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · timeline.dart·unknown_board.dart 의 배너 관용구(activeFlags.where(… FlagIds.markerOnly.contains …)) → 이 파일은 JournalSafetyBanners(safety:) 한 줄
 · JournalEntryCard 의 사유 칩 .take(3) + «+n» 글자 → H6-1 행의 칩은 받은 것 전부(.take · 길이 글자 0 — C-44 ⑰)
 · unknown_board.dart 의 item.escalationLink! 처럼 nullable 에 ! → 지역 변수에 받아 null 검사(final String? link = row.detailDeepLink;)
 · J-3 의 FlutterError.reportError 보고 → 보고 0 · 테스트의 class … implements SafetyRepository · 한국어 테스트 이름 · «if (x != null) { expect… }» 조건부 단언 → 받침대 extends · ASCII · if/else 짝
 · 매 테스트 ProviderScope 통째 반복 → 띄우기 도우미 하나(pumpHoldingsOverview) · 새 Key 는 화면id-하이픈(h61-…) · 아래 Key 표 22이름뿐

■ 주입 구조 (이름·타입 고정 = 01 §17-8 · 설계서 §2-5 글자 그대로 · 계약 변경 없음)
· 재사용(이름·위치 불변 · timeline.dart): journalSafetyRepositoryProvider · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider /
  journal_common.dart: JournalAsOfHeader · JournalStaleBanner · JournalReasonChip · JournalSkeleton · JournalErrorView · JournalSafetyBanners(🔴 무수정 — 새로 짓지 않는다) /
  labels.dart: JournalLabels.retry · staleBannerTitle(이미 있다 — 고치지 않는다).
· 🆕 lib 파일 1개 — lib/src/holdings_overview.dart(이것 말고 새 lib 파일을 만들지 않는다 — lib/src/holdings/ 폴더도 만들지 않는다 · 조각은 이 파일 안 private 메서드·클래스로 ·
  private 로 나누면 파일 글자 순서와 화면 순서가 달라진다 — 제출 ③ 은 «렌더 순서»(호출을 그 자리에 펼친 순서)로 쓴다).
  import(directives_ordering · 6줄 · 쓰지 않는 import = analyze 실패):
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
     import '../l10n/labels.dart'; → import 'common/journal_common.dart'; → import 'timeline.dart';
  프로바이더 둘 — 파일 머리(공개 위젯 앞)에 이 모양으로(이름·타입·throw 글자 고정 · 줄 배치는 dart format 결과 · 주석은 짧게 — 규칙 15):
    /// H6-1·H6-2 보유 읽기 창구 주입 — 조립 앱 3종이 override 한다(01 §17-8).
    final journalHoldingsRepositoryProvider = Provider<HoldingsRepository>(
      (Ref ref) => throw UnimplementedError(
        'journalHoldingsRepositoryProvider must be overridden',
      ),
    );

    /// H6-1 한 화면 — 열쇠 = 손익 펼침 여부(펼침 = 같은 창구 재구독).
    final _holdingsOverviewProvider = StreamProvider.family<HoldingsOverviewVm, bool>(
      (Ref ref, bool includePnl) => ref
          .watch(journalHoldingsRepositoryProvider)
          .watchHoldingsOverview(includePnl: includePnl),
    );
  🔴 이 파일이 부르는 창구는 이 하나(watchHoldingsOverview)뿐 · .family 에 autoDispose 를 붙이지 않는다(접기 = family(false) 캐시 · 새 호출 0 · 재진입도 캐시) · 주입은 첫 프로바이더 하나.
· 🆕 공개 위젯 — class HoldingsOverview extends ConsumerStatefulWidget { const HoldingsOverview({super.key}); }
  (State = bool _pnlOpen = false · bool _externalOpen = false · final Map<int, bool> _cardOpen = <int, bool>{} — 아래 «코드 스케치»)
· 배럴 lib/ui_journal.dart 에 export 'src/holdings_overview.dart'; 한 줄 —
  🔴 자리 = export 'src/decision_detail.dart'; 줄과 export 'src/journal_read.dart'; 줄 **사이**(끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패) · 머리 주석은 고치지 않는다.
· import 하지 않는 것: lib/journal_draft.dart · lib/src/journal_draft/** · blind_review.dart · decision_detail.dart · journal_read.dart · unknown_board.dart.

■ 픽스처 (FixturePaths.… · 읽는 법 = singleFixture(<경로>, HoldingsOverviewVm.fromJson) · safetyFixtureRow(n) — golden_support.dart · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 normal     m6HoldingsOverviewNormal — 카드 3(A · B · C 순) · A 카드 행 3(069500 · POT 133690 · POT 411060 — POT 두 행 = subBookLabel 있음) · B 카드 행 2(133690 = pendingText «반영 대기 +12주» · 411060) · C 카드 행 1 ·
            카드 머리: A·C = sleeveWeight null + bandNoteText · B = sleeveWeight(label) + bandState IN_BAND + bandStateLabel · 트랜치 칩 = B 두 행만(3단계) · 배지 = 행마다 1(전부 PASS) · 사유 칩 = 행마다 1(handbook 링크) ·
            external = 2행(bannerText null) · allocationLink 있음 · pnlToggleLabel 있음 · emptyLabel null · 모든 행 detailDeepLink 있음 · pnl 없음
 recon      m6HoldingsOverviewRecon — normal 과 같고 B 카드 머리 글자(sleeveWeight.label 끝 «?») · B 행 0 의 quantityText·weightText·pendingText 끝 «?» · 기하·bandState 유지
 integrity  m6HoldingsOverviewIntegrity — 카드 머리 = 전부 sleeveWeight·bandState null + bandNoteText «숨김» · 관리 대상 행 quantityText·avgPriceText·weightText «숨김» · pendingText null · sma_tranches 빈 목록(K29) ·
            시스템 밖 행 quantityText = normal 과 같음(K14)
 empty      m6HoldingsOverviewEmpty — cards 0 · emptyLabel 있음 · external·allocationLink·pnlToggleLabel null
 pnl        m6HoldingsOverviewPnl — normal 과 같고 세 행(A 069500 · B 133690 · C 0085P0)에 pnl(pnlText · pnlPctText · disclosureNote)
 viewer     m6HoldingsOverviewViewer — normal 과 같고 pnlToggleLabel null · external null(K15 · K14 ⓑ)
 안전       safetyFixtureRow(n) — 0 정상(플래그 0) · 3 차단 2(RECON_MISMATCH · JOURNAL_MISSING) · 4 무결성(LEDGER_INTEGRITY)
 쓰지 않는 것: holdings_6 · m6/external_holdings_2 · m6/entry_gate_nov_pass_1 · sleeve_catalog_4 · m6/allocation_* · m6/holding_detail_*(R4b · 계약 테스트 몫).
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다(예외 = 규칙 10 의 cards 슬라이스 하나) · 픽스처를 복사해 고친 «내 픽스처» 금지 · 모자라면 질문 파일에.

■ 화면 — H6-1 HoldingsOverview (01 §17-6 · 17-7 · 02 §4 v1.8 블록 ⓐ~ⓗ · 02 §4-3 진입 경로 «H6-1 상단 「비중 보기」»)
 상태 표(구독마다 한 줄 — C4r3-1):
   overview(false) 첫 값 전        → JournalSkeleton(key: const Key('h61-loading')) 하나(배너 없음 · 6장 = 공통 위젯 그대로)
   overview 스트림 에러             → JournalErrorView(key: const Key('h61-fail') · «다시 시도» = invalidate 로 같은 열쇠 재구독 · lastAsOfLabel = 그 AsyncValue 의 valueOrNull?.asOf.label · 배너 없음)
   overview 값 · cards 빈           → 빈 갈래: 머리 + 오래됨 + 배너 + emptyLabel 문장(카드·섹션·토글·링크 0)
   overview 값 · cards 있음         → 정상 갈래(가림 포함 — «?»·«숨김» 은 글자 그대로 · INTEGRITY 의 sleeveWeight null 은 그 Text 부재)
   손익 펼침(true) 첫 값 전 · 에러  → 위 두 줄과 같다(열쇠 = true · 배너 없음 · 펼친 카드·섹션 State 는 유지)
   safety 스트림                    → 배너만(본문 영향 0 · 값이 오기 전 = 배너 없음)
 갈래별 정적 글자(테스트 T61-12 가 그대로 단언):
   갈래                 머리(h61-asof)  배너   다시 시도   오래됨 제목   빈 문장   매수가·진입일·등록일
   스켈레톤             0               0      0           0             0         0
   에러                 0               0      1           0             0         0
   빈                   1               있음   0           오래됐으면 1  1         0
   정상(접힘)           1               있음   0           오래됐으면 1  0         0(카드·섹션을 펼친 뒤에만)
 배치(정상 갈래 · 위 → 아래 · 🔴 이 순서 · 테스트 T61-01 · T61-03~T61-05 가 사슬로 증명 · ListView 에 padding 없음):
   ListView[
    1 JournalAsOfHeader(key: const Key('h61-asof'), asOf: vm.asOf)
    2 (오래됐으면) JournalStaleBanner(asOf: vm.asOf)        ← final bool stale = vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc());
    3 JournalSafetyBanners(safety: safety)                    ← final SafetyState? safety = ref.watch(journalSafetyStateProvider).valueOrNull;
    4 (allocationLink != null) Padding(OutlinedButton(key: const Key('h61-alloc-link'), onPressed: () { ref.read(journalLinkOpenerProvider).open(link.deepLink); }, child: Text(link.label)))   ← 「비중 보기」 = 상단(02 §4-3)
    5 (pnlToggleLabel != null) Padding(TextButton.icon(key: const Key('h61-pnl-toggle'), onPressed: 토글, icon: Icon(_pnlOpen ? Icons.expand_less : Icons.expand_more), label: Text(toggleLabel)))
    6 for (final (int c, HoldingsSleeveCard card) in vm.cards.indexed) 카드 c(아래)
    7 (external != null) 시스템 밖 섹션(아래)
   ]
 카드 c(🔴 처음 접힘 · 펼침 = _cardOpen[c] ?? false · 탭 = 머리 InkWell 하나):
   Card(key: ValueKey<String>('h61-card-$c'), child: Column[
     InkWell(key: ValueKey<String>('h61-card-toggle-$c'), onTap: () { setState(() { _cardOpen[c] = !open; }); }, child: Padding(Row[
       Expanded(Column[
         Text(card.titleText, key: ValueKey<String>('h61-card-title-$c'))
         (w != null) Text(w.label, key: ValueKey<String>('h61-card-weight-$c'), style: textTheme.titleLarge)   ← final SleeveWeight? w = card.allocation.sleeveWeight; (큰 글자 · 매일 볼 숫자)
         (note != null) Text(note, key: ValueKey<String>('h61-card-note-$c'))                                   ← final String? note = card.allocation.bandNoteText; (K27 — A·C · INTEGRITY 는 전 카드)
         (state != null && stateLabel != null) Row[Icon(Icons.circle, size: 12, color: _bandColor(context, state)) · SizedBox(width: 6) · Expanded(Text(stateLabel, key: ValueKey<String>('h61-card-state-$c')))]
       ])
       Icon(open ? Icons.expand_less : Icons.expand_more)
     ]))
     (open) for (final (int r, HoldingRow row) in card.rows.indexed) 행 (c, r)(아래)
     (open && rowsEmpty != null) Padding(Text(rowsEmpty, key: ValueKey<String>('h61-rows-empty-$c')))      ← final String? rowsEmpty = card.rowsEmptyText;(표본 없음 — 정적 검토만)
   ])
   ← 🔴 머리 글자는 w.label 과 note 를 각각 null 검사로(else 사슬 0 · 계약이 둘 중 하나만 준다) · 색은 _bandColor 의 switch 하나(규칙 6) · 편차 부호·글자로 색을 고르지 않는다.
 행 (c, r)(🔴 아래 Text 순서가 테스트 도우미 holdingsRowTexts 의 순서다 — 바꾸면 T61-03 이 실패한다):
   InkWell(key: ValueKey<String>('h61-row-$c-$r'), onTap: link == null ? null : () { ref.read(journalLinkOpenerProvider).open(link); }, child: Padding(Column(crossAxisAlignment: start)[
     Text(row.symbolLabel)
     Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center)[ Text(row.quantityText) ·
       (pending != null) Chip(key: ValueKey<String>('h61-pending-$c-$r'), label: Text(pending)) · (subBook != null) Chip(key: ValueKey<String>('h61-subbook-$c-$r'), label: Text(subBook)) ]
     Row[ Text(JournalLabels.holdingsAvgPrice) · SizedBox(width: 6) · Flexible(Text(row.avgPriceText)) ]
     Row[ Text(JournalLabels.holdingsEntryDate) · SizedBox(width: 6) · Flexible(Text(row.entryDate.yyyyMmDd)) ]
     Text(row.weightText)
     Wrap(spacing: 6, runSpacing: 4)[ for (final ReasonChip chip in row.entryReasons) JournalReasonChip(chip: chip) ]
     Wrap(spacing: 6, runSpacing: 4)[ for (final TrancheStep step in row.smaTranches) Chip(avatar: Icon(step.filled ? Icons.check_circle : Icons.radio_button_unchecked, size: 16), label: Text(step.label)) ]
     Wrap(spacing: 6, runSpacing: 4)[ for (final GateBadge gate in row.gates) Chip(avatar: Icon(_gateIcon(gate.state), size: 16), label: Text(gate.label)) ]
     (gain != null) Padding(key: ValueKey<String>('h61-pnl-$c-$r'), Column[ Text(gain.pnlText) · Text(gain.pnlPctText) · Text(gain.disclosureNote) ])
   ]))
   ← final String? pending = row.pendingText; final String? subBook = row.subBookLabel; final String? link = row.detailDeepLink; final HoldingPnl? gain = row.pnl;(지역 변수 이름에 pnl 0 — 규칙 13)
   ← 🔴 손익 줄은 데이터로만 열린다(펼침 = family(true) 값에 pnl 이 실려 온다 · 화면의 _pnlOpen 으로 줄을 고르지 않는다) · disclosureNote 는 손익 줄과 늘 함께 · RECON 행에 아이콘·색 0(글자 끝 «?» 그대로 · K16 ⓕ).
 시스템 밖 섹션(🔴 처음 접힘 · 고지 = 접혀도 늘):
   Card(key: const Key('h61-ext'), child: Column[
     InkWell(key: const Key('h61-ext-toggle'), onTap: () { setState(() { _externalOpen = !open; }); }, child: Padding(Row[ Expanded(Text(ext.titleText)) · Icon(open ? Icons.expand_less : Icons.expand_more) ]))
     Padding(Text(ext.noticeText, key: const Key('h61-ext-notice')))
     (banner != null) Padding(Text(banner, key: const Key('h61-ext-banner')))                                ← final String? banner = ext.bannerText;(표본 없음 — 정적 검토만)
     (open) for (final (int k, ExternalHoldingRow x) in ext.rows.indexed) Padding(key: ValueKey<String>('h61-ext-row-$k'), Column[
        Text(x.symbolLabel) · Text(x.quantityText) · Row[ Text(JournalLabels.holdingsRegisteredOn) · SizedBox(width: 6) · Flexible(Text(x.registeredOn.yyyyMmDd)) ] ])
   ])
   ← 🔴 시스템 밖 수량을 관리 대상과 합치거나 비중을 만들지 않는다 · INTEGRITY 에서도 엔진이 준 그대로(K14).
 배치(빈 갈래 · cards 빈): ListView[ JournalAsOfHeader(key: const Key('h61-asof'), asOf: vm.asOf) · (오래됐으면) JournalStaleBanner(asOf: vm.asOf) · JournalSafetyBanners(safety: safety) ·
   (label != null) Padding(padding: EdgeInsets.all(16), Text(label, key: const Key('h61-empty'))) ]   ← final String? label = vm.emptyLabel; · 🔴 빈 문장을 Card 로 감싸지 않는다
 코드 스케치(State · 모양은 그대로, 이름·줄 배치·패딩 정수는 재량 — 테스트가 동작을 단언한다):
   build:
     final Clock clock = ref.watch(journalClockProvider); final SafetyState? safety = ref.watch(journalSafetyStateProvider).valueOrNull;
     final bool expanded = _pnlOpen;   ← 지역 변수 이름에 pnl 0(규칙 13)
     final AsyncValue<HoldingsOverviewVm> overview = ref.watch(_holdingsOverviewProvider(expanded));
     return overview.when(
       loading: () => const JournalSkeleton(key: Key('h61-loading')),
       error: (Object error, StackTrace stackTrace) => JournalErrorView(key: const Key('h61-fail'), lastAsOfLabel: overview.valueOrNull?.asOf.label,
                onRetry: () => ref.invalidate(_holdingsOverviewProvider(expanded))),
       data: (HoldingsOverviewVm vm) => vm.cards.isEmpty ? _buildEmpty(vm, clock, safety) : _buildBody(vm, clock, safety),
     );
   토글: setState(() { _pnlOpen = !_pnlOpen; });   ← 🔴 구독을 바꾸는 것은 이 State 변수 하나(열쇠) · 다른 곳에서 ref.read(_holdingsOverviewProvider(…)) 0
   _bandColor(BuildContext context, SleeveBandState s) => switch (s) { SleeveBandState.inBand => cs.primary, SleeveBandState.nearEdge => cs.tertiary, SleeveBandState.outOfBand => cs.error }   ← final ColorScheme cs = Theme.of(context).colorScheme;
   _gateIcon(GateState s) => switch (s) { GateState.pass => Icons.check_circle_outline, GateState.block => Icons.cancel_outlined, GateState.notApplicable => Icons.radio_button_unchecked, GateState.unknown => Icons.help_outline }
 🔴 갈래를 고르는 것은 AsyncValue(로딩·에러·값) · cards 빈 여부 · _pnlOpen(열쇠) · _cardOpen · _externalOpen · null 여부(sleeveWeight · bandNoteText · bandState·bandStateLabel · pendingText · subBookLabel ·
    detailDeepLink · row.pnl · external · bannerText · allocationLink · pnlToggleLabel · emptyLabel · rowsEmptyText) · bandState(색 switch) · GateState(아이콘 switch) · step.filled(아이콘) 뿐이다 —
    글자 비교·«?» 검사·SleeveId·플래그로 고르지 않는다.
 간격(SizedBox 높이·Padding 정수)·글자 굵기·크기·모서리는 재량(질문 아님) — 단 소수부 ≠ 0 소수 리터럴 0.

■ Key 표 (H6-1 Key 22이름 — 정본 = 이 표의 글자 · 🔴 여기 없는 h61- Key 를 더하지 않는다 · 이름에 영어 색·테마 낱말(error · surface …)을 넣지 않는다 · 🔴 Key 에 holdingId·symbol 0 — 순번만)
   스켈레톤      Key('h61-loading')                          JournalSkeleton(key:)
   에러          Key('h61-fail')                             JournalErrorView(key:)
   머리          Key('h61-asof')                             JournalAsOfHeader(key:) — 정상·빈 갈래
   빈 문장       Key('h61-empty')                            Text(vm.emptyLabel) — 빈 갈래 · null 이면 0
   손익 토글     Key('h61-pnl-toggle')                       TextButton.icon — pnlToggleLabel 있을 때만
   카드          ValueKey<String>('h61-card-$c')             Card — c = cards.indexed
   카드 머리     ValueKey<String>('h61-card-toggle-$c')      InkWell(펼침 탭)
   카드 제목     ValueKey<String>('h61-card-title-$c')       Text(card.titleText)
   카드 비중     ValueKey<String>('h61-card-weight-$c')      Text(sleeveWeight.label) — 있을 때만
   카드 메모     ValueKey<String>('h61-card-note-$c')        Text(bandNoteText) — 있을 때만
   카드 상태     ValueKey<String>('h61-card-state-$c')       Text(bandStateLabel) — bandState·bandStateLabel 있을 때만
   종목 행       ValueKey<String>('h61-row-$c-$r')           InkWell — 카드 펼침 · r = rows.indexed
   반영 대기     ValueKey<String>('h61-pending-$c-$r')       Chip — pendingText 있을 때만
   하위 칩       ValueKey<String>('h61-subbook-$c-$r')       Chip — subBookLabel 있을 때만
   손익 줄       ValueKey<String>('h61-pnl-$c-$r')           Padding(손익 Column) — pnl 있을 때만
   행 없음       ValueKey<String>('h61-rows-empty-$c')       Text(rowsEmptyText) — 펼침 + 있을 때만
   섹션          Key('h61-ext')                              Card — external 있을 때만
   섹션 머리     Key('h61-ext-toggle')                       InkWell(펼침 탭)
   섹션 고지     Key('h61-ext-notice')                       Text(ext.noticeText) — 늘
   섹션 배너     Key('h61-ext-banner')                       Text(ext.bannerText) — 있을 때만
   섹션 행       ValueKey<String>('h61-ext-row-$k')          Padding — 섹션 펼침 · k = rows.indexed
   비중 보기     Key('h61-alloc-link')                       OutlinedButton — allocationLink 있을 때만
   (행 안 Text · 칩 안 글자 · 배지 · 사유 칩 · 섹션 제목 · 배너 · 신선도 배너에는 Key 를 달지 않는다 — 테스트는 find.text · find.descendant 로 찾는다)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량 — 커밋 제목이 그 커밋 내용과 맞기만 하면 된다(12 §3 공통 조문 «커밋 = 제목만 맞추기»)
   (각 단계 끝 «커밋 «…»» 는 단계마다 하나씩 나눌 때의 권장 제목이다(4개) · 합치거나 더 나누면 제목을 그 커밋에 실제로 든 내용에 맞게 쓴다 — 제목 ≠ 내용 = 보고 규칙 ① 표기(반려 아님) ·
    🔴 그대로인 것: amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일(그 뒤 커밋 0 · 제출 단계의 format 0 changed) · 아래 «이 커밋 전에» 의 정적 묶음 미리 돌리기)
 (1) 정적 라벨 3개(labels.dart 끝 R4a 절) — 기존 화면 무변경 · 0단계의 시작 기준 N 이 그대로 통과. 커밋 «[M6] R4a (1) 정적 라벨 3»
 (2) lib/src/holdings_overview.dart(프로바이더 둘 + HoldingsOverview) + 배럴 export 한 줄(정렬 자리) + test/holdings_overview_fakes.dart + test/holdings_overview_test.dart(T61-01~T61-14).
     🔴 이 커밋 전에 packages/ui_journal 에서 «정적 묶음» 31줄을 한 번 미리 돌려 본다 — 🔴 git grep 은 add 하지 않은 새 파일을 보지 않는다(출력 없음 = 거짓 안심) →
        먼저 git add . (packages/ui_journal 안에서 · 커밋은 그다음)로 올린 뒤 돌린다(아래 «정적 묶음» 의 기대와 대조 · 주석도 센다 — 규칙 15).
        🔵 S22 는 커밋끼리 비교(origin/main...HEAD)라 커밋 전에는 labels.dart 한 줄만 나온다(정상 — 배럴 줄은 이 커밋 뒤에 나온다). 커밋 «[M6] R4a (2) H6-1 보유현황 화면 + 테스트»
 (3) 골든 10장 — test/golden/h61_golden_test.dart. 커밋 «[M6] R4a (3) 골든 h61_* 10장»
 (4) melos.bat run format:fix · 질문 파일(H61_questions.md — 골든 dy 측정 행 A1~A5 · 그 밖의 질문) · 커밋 «[M6] R4a (4) format · 질문».
     🔴 (4) 뒤에 다른 커밋을 더하지 않는다(제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지 · 예외 하나 = «■ 제출» 사전검사 ① 의 🔴 를 고치는 커밋 (5)).

■ 정적 라벨 — JournalLabels 끝에(파일의 마지막 절 = R3 절 blindReviewNext 뒤) 절 주석(// ── 🆕 R4a — H6-1 보유현황 ──…)과 함께 3개(이름·글자 고정):
   holdingsAvgPrice = '매수가'        (종목 행 — 값 avgPriceText 앞 머리 · 펼친 행에서만)
   holdingsEntryDate = '진입일'       (종목 행 — 값 entryDate 앞 머리 · 펼친 행에서만)
   holdingsRegisteredOn = '등록일'    (시스템 밖 행 — 값 registeredOn 앞 머리 · 섹션 펼침에서만)
   (다시 시도 = retry · 오래됨 = staleBannerTitle 재사용 — 고치지 않는다 · 라벨 doc 주석에 «holdings» 낱말을 쓰지 않는다 — 정적 S26 은 그 낱말로 3줄을 센다)
   🔴 만들지 않는 글자(엔진 몫): 카드 제목·«A · 국내 지수 ETF» · 밴드 문장·«밴드 내»·«경계 근접» · «비중 n%»·합계·«총 n주» · «반영 대기» · «POT 서브북» · «종목 손익»(토글 글자 = pnlToggleLabel) ·
      «전일 종가 기준» · «시스템 밖 자산»·«비중 계산에서 빠집니다» · «비중 보기»(링크 label) · «보유 종목이 없습니다» · «숨김» · «?» · «원»·«%»·«주».
   🔴 라벨 글자에 숫자·금액을 넣지 않는다(C-32 · labels.dart 도 본다). 더 필요하면 더하지 말고 질문 파일에 적는다(이 카드의 새 정적 라벨은 3개로 고정).

■ 테스트 최소 목록 (H6-1 · 번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S23·S24 와 대조 · 파일 = test/holdings_overview_test.dart)
공통: 띄우기 = pumpHoldingsOverview(뷰포트 Size(390, 4000) + DPR 1.0 + addTearDown 2개 — 글꼴 1.0 에서 세 카드·섹션을 다 펼친 내용 끝 = 드라이런 약 2400(손익 접힘)·2592(손익 펼침) — 4000 안 ·
  🔴 글꼴 2.0(T61-14)에서는 약 6034 로 4000 을 넘는다 — ListView 는 화면 밖 자식을 짓지 않으므로 펼침 도우미는 탭 전에 scrollUntilVisible 로 끌어온다) ·
  가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Stream · 시계 = FixedClock(kGoldenNowUtc)(오래됨 = kGoldenNowUtc.add(const Duration(days: 2))) · 안전 기본 = safetyFixtureRow(0) · 기대 글자는 픽스처에서 ·
  값 단언 전 pump 두 번 = pumpHoldingsOverview(끝에 pump 1번) 뒤 각 테스트에서 await tester.pump(); 를 한 번 더 · 펼침 탭 = 도우미(openHoldingsCard · openHoldingsExternal · tapHoldingsPnlToggle — 탭 전 await tester.scrollUntilVisible(<finder>, 300) · 이미 보이면 움직이지 않는다(골든 불변) · 🔴 ensureVisible 금지 — 큰 글꼴에서 «No element» 로 실패).
  🔴 경우가 여럿인 테스트(T61-02·09·12·13·14)는 for 로 testWidgets 를 경우마다 만든다(이름 = '<번호> <설명> <경우 이름>' · ⓡ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 같다) ·
     🔴 경우 목록의 «흐름»(탭·펼침)은 클로저 칸으로 둔다(Future<void> Function(WidgetTester) steps — 흐름 없는 경우 = (WidgetTester t) async {} · 🔴 bool 칸 + if 로 흐름을 고르지 않는다 · C4r3-4).
     pumpHoldingsOverview 는 한 테스트에서 한 번만 부른다(예외 = T61-06 의 재진입 — 같은 overrides 목록 · 다른 screenKey 로 한 번 더).
     계획 = 뷰 28개(T61-01 1 · 02 2 · 03 1 · 04 1 · 05 1 · 06 1 · 07 1 · 08 1 · 09 2 · 10 1 · 11 1 · 12 9 · 13 3 · 14 2 · 15 1 · 드라이런 «+28») · testWidgets 줄 15(경우 루프 안의 testWidgets( 는 한 줄로 센다 · test( 를 쓰지 않는다).
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순 · 쓰지 않는 import 는 analyze 실패 — 실제로 쓰는 것만):
     import 'dart:async'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; →
     import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_journal/src/common/journal_common.dart'; → import 'package:ui_journal/ui_journal.dart'; →
     import 'golden/golden_support.dart'; → import 'holdings_overview_fakes.dart';   (이 10줄 = 드라이런 analyze «No issues found!» 로 확인한 줄 목록 그대로)
  🆕 test/holdings_overview_fakes.dart(새 파일 · 공개 이름 · 🔴 한국어 리터럴 0 · if 0 · collection-if 0 · import 7줄 = 'package:domain_contracts/domain_contracts.dart' → 'package:domain_contracts/testing.dart' →
     'package:flutter/material.dart' → 'package:flutter_riverpod/flutter_riverpod.dart' → 'package:flutter_test/flutter_test.dart' → 'package:ui_journal/ui_journal.dart' → 'golden/golden_support.dart'):
    class FakeHoldingsRepository extends UnimplementedHoldingsRepository {
      FakeHoldingsRepository({required this.overview});
      final Stream<HoldingsOverviewVm> Function(bool includePnl, int call) overview;
      final List<bool> calls = <bool>[];                 ← watchHoldingsOverview 의 includePnl 을 호출마다 더한다(02 수용 (e) 의 증거)
      @override
      Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false}) { final int call = calls.length; calls.add(includePnl); return overview(includePnl, call); }
    }   (그 밖 창구는 override 하지 않는다 — 받침대가 던진다 · 화면이 watchHoldings 등을 부르면 테스트가 실패한다)
    FakeHoldingsRepository fakeHoldingsOverview(HoldingsOverviewVm closed, HoldingsOverviewVm open) =>
        FakeHoldingsRepository(overview: (bool includePnl, int call) => Stream<HoldingsOverviewVm>.value(includePnl ? open : closed));
    class FakeHoldingsSafetyRepository extends UnimplementedSafetyRepository { FakeHoldingsSafetyRepository(this.state) · watchState() = 호출마다 Stream<SafetyState>.value(state) }
    List<Override> holdingsOverviewOverrides({required FakeHoldingsRepository repo, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 4개: journalHoldingsRepositoryProvider.overrideWithValue(repo) · journalSafetyRepositoryProvider.overrideWithValue(FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0))) ·
          journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)) · journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener())
    Future<void> pumpHoldingsOverview(WidgetTester tester, {required List<Override> overrides, Key? screenKey})
        ← 390×4000 · DPR 1.0 · teardown 2 · pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: Scaffold(body: HoldingsOverview(key: screenKey))))) · 끝에 pump() 1번
    Future<void> openHoldingsCard(WidgetTester tester, int c)        ← ValueKey<String>('h61-card-toggle-$c') → scrollUntilVisible(head, 300) → tap → pump
    Future<void> openHoldingsExternal(WidgetTester tester)           ← Key('h61-ext-toggle') → scrollUntilVisible(head, 300) → tap → pump
    Future<void> tapHoldingsPnlToggle(WidgetTester tester)           ← Key('h61-pnl-toggle') → scrollUntilVisible(toggle, 300) → tap → pump 두 번
    List<String> holdingsRowTexts(HoldingRow row) => <String>[ row.symbolLabel, row.quantityText, ?row.pendingText, ?row.subBookLabel, JournalLabels.holdingsAvgPrice, row.avgPriceText,
        JournalLabels.holdingsEntryDate, row.entryDate.yyyyMmDd, row.weightText, for (final ReasonChip c in row.entryReasons) c.label, for (final TrancheStep s in row.smaTranches) s.label,
        for (final GateBadge g in row.gates) g.label, ?row.pnl?.pnlText, ?row.pnl?.pnlPctText, ?row.pnl?.disclosureNote ];      ← 위 «행 (c, r)» 의 Text 순서 그대로
    List<String> holdingsCardHeadTexts(HoldingsSleeveCard card) => <String>[ card.titleText, ?card.allocation.sleeveWeight?.label, ?card.allocation.bandNoteText, ?card.allocation.bandStateLabel ];
    List<String> holdingsExternalRowTexts(ExternalHoldingRow x) => <String>[ x.symbolLabel, x.quantityText, JournalLabels.holdingsRegisteredOn, x.registeredOn.yyyyMmDd ];
    List<String?> holdingsShownTexts(WidgetTester tester, Key key) =>
        tester.widgetList<Text>(find.descendant(of: find.byKey(key), matching: find.byType(Text))).map((Text t) => t.data).toList();   ← 그 Key 아래 Text 글자(위 → 아래)
    IconData? holdingsChipIcon(WidgetTester tester, Finder scope, String label) => tester.widget<Icon>(find.descendant(of: find.ancestor(
        of: find.descendant(of: scope, matching: find.text(label)), matching: find.byType(Chip)), matching: find.byType(Icon))).icon;   ← scope 아래 글자가 label 인 Chip 의 아이콘(T61-03 · R4b 가 재사용)
    Set<String> holdingsOverviewAllowed(HoldingsOverviewVm v) => <String>{ v.asOf.label, ?v.pnlToggleLabel, ?v.allocationLink?.label,
        for (final HoldingsSleeveCard c in v.cards) ...<String>[ ...holdingsCardHeadTexts(c), ?c.rowsEmptyText, for (final HoldingRow r in c.rows) ...holdingsRowTexts(r) ],
        ?v.external?.titleText, ?v.external?.noticeText, ?v.external?.bannerText,
        for (final ExternalHoldingRow x in v.external?.rows ?? <ExternalHoldingRow>[]) ...holdingsExternalRowTexts(x) };
    골든은 pumpHoldingsOverview 를 쓰지 않는다 — pumpForGolden(tester, const HoldingsOverview(), brightness: b, logicalSize: _kTallPhone, wrapApp: (Widget app) => ProviderScope(overrides: holdingsOverviewOverrides(…), child: app)).
    🔴 새 띄우기 도우미는 pumpHoldingsOverview 하나 · 테스트마다 ProviderScope 를 통째로 쓰지 않는다.
  파일 머리(main() 안 · testWidgets 밖)에서 픽스처를 한 번 읽는다: normal · recon · integrity · empty · pnl · viewer(singleFixture(FixturePaths.m6HoldingsOverview…, HoldingsOverviewVm.fromJson)) ·
    Stream<HoldingsOverviewVm> valueThenFail(HoldingsOverviewVm v) async* { yield v; throw StateError('overview'); }   ← T61-13(지역 함수 선언)
H6-1 — test/holdings_overview_test.dart
 T61-01 진입 · 카드 머리(수용 (a)(c)(e) · K27) — repo = fakeHoldingsOverview(normal, pnl) →
        expect(repo.calls, <bool>[false]) · holdingsShownTexts(tester, const Key('h61-asof')) == <String?>[normal.asOf.label] ·
        ⓗ expect(normal.cards, hasLength(3)) → c 마다: holdingsShownTexts(ValueKey('h61-card-toggle-$c')) == holdingsCardHeadTexts(card) ·
          비중 = if (w != null) tester.widget<Text>(h61-card-weight-$c).data == w.label / else h61-card-weight-$c findsNothing · 메모 = 같은 꼴(bandNoteText · h61-card-note-$c) ·
          상태 = if (state != null) h61-card-state-$c data == bandStateLabel + 카드 머리 안 Icons.circle 의 color == 기대색 / else h61-card-state-$c findsNothing + 머리 안 Icons.circle findsNothing
          (기대색 = 테스트 안 switch — inBand → cs.primary · nearEdge → cs.tertiary · outOfBand → cs.error · cs = Theme.of(tester.element(find.byKey(const Key('h61-asof')))).colorScheme) ·
          h61-row-$c-0 findsNothing(처음 접힘) →
        h61-card-3 findsNothing · find.descendant(of: h61-pnl-toggle, matching: find.text(normal.pnlToggleLabel!)) 1(전제 isNotNull) ·
        find.descendant(of: h61-alloc-link, matching: find.text(normal.allocationLink!.label)) 1(전제 isNotNull) ·
        사슬 dy lessThan(「비중 보기」 = 상단): h61-asof → h61-alloc-link → h61-pnl-toggle → h61-card-0 · find.text(JournalLabels.holdingsAvgPrice) findsNothing · ⓡ.
 T61-02 카드 수 = 데이터(K16 ⓐ · 수용 (b)) — 두 경우 ㉠ (all · normal · 3) · (first_two · normal.copyWith(cards: normal.cards.sublist(0, 2)) · 2)마다(규칙 10 의 copyWith 한 꼴):
        ⓗ expect(v.cards, hasLength(cardCount)) → c 마다 h61-card-title-$c data == v.cards[c].titleText → ValueKey('h61-card-$cardCount') findsNothing · expect(repo.calls, <bool>[false]) · ⓡ.
 T61-03 B 카드 펼침·접기(자리 · 수용 (c)) — normal · openHoldingsCard(tester, 1) → b = normal.cards[1] · ⓗ expect(b.rows, hasLength(2)) → r 마다:
          expect(holdingsShownTexts(tester, ValueKey<String>('h61-row-1-$r')), holdingsRowTexts(b.rows[r])) · 반영 대기 칩 = 위 «없는 쪽» 견본 그대로 · 하위 칩 = 같은 꼴(subBookLabel · h61-subbook-1-$r) ·
          칩 아이콘 = final Finder rowFinder = find.byKey(ValueKey<String>('h61-row-1-$r')); → for (s in row.smaTranches) expect(holdingsChipIcon(tester, rowFinder, s.label), s.filled ? Icons.check_circle : Icons.radio_button_unchecked) ·
          for (g in row.gates) { expect(g.state, GateState.pass)(전제 — 표본 배지는 전부 PASS) · expect(holdingsChipIcon(tester, rowFinder, g.label), Icons.check_circle_outline) } ·
        사슬 = 이웃끼리 tester.getTopLeft(…).dy lessThan: h61-card-toggle-1 → h61-row-1-0 → h61-row-1-1 → h61-card-2 · h61-row-0-0 · h61-row-2-0 findsNothing(다른 카드는 접힘) →
        openHoldingsCard(tester, 1)(다시 탭 = 접기) → h61-row-1-0 findsNothing · ⓡ.
 T61-04 A 카드 · POT = 맨 끝(K17) — normal · expect(normal.cards[0].rows[2].subBookLabel, isNotNull) 전제 · openHoldingsCard(tester, 0) → a = normal.cards[0] · ⓗ expect(a.rows, hasLength(3)) → r 마다:
          shown == holdingsRowTexts(a.rows[r]) · 하위 칩 = if/else 짝(있으면 칩 안 글자 == subBookLabel / 없으면 h61-subbook-0-$r findsNothing) ·
        사슬 dy: h61-row-0-0 → h61-row-0-1 → h61-row-0-2 → h61-card-1 · ⓡ.
 T61-05 시스템 밖 섹션(K14 · 02 §8 행 15) — normal · expect(normal.external, isNotNull) → ext = normal.external! ·
        find.descendant(of: h61-ext, matching: find.text(ext.titleText)) 1 · h61-ext-notice data == ext.noticeText · expect(ext.bannerText, isNull) → h61-ext-banner findsNothing · h61-ext-row-0 findsNothing(접힘) →
        openHoldingsExternal(tester) → ⓗ expect(ext.rows, hasLength(2)) → k 마다 holdingsShownTexts(ValueKey('h61-ext-row-$k')) == holdingsExternalRowTexts(ext.rows[k]) · h61-ext-row-2 findsNothing ·
        h61-ext-notice 1(펼쳐도) · 사슬 dy: h61-card-2 → h61-ext → openHoldingsExternal(tester) → h61-ext-row-0 findsNothing · h61-ext-notice 1 · ⓡ.
 T61-06 손익 펼침 = 재구독 · 접기 · 재진입(수용 (e) · K28 · 결정 ⑤) — final List<Override> overrides = holdingsOverviewOverrides(repo: repo) 한 번 · repo = fakeHoldingsOverview(normal, pnl) ·
        openHoldingsCard 0 · 1 · 2 → expect(repo.calls, <bool>[false]) · ⓗ expect(pnl.cards, hasLength(3)) → (c, r) 마다 h61-pnl-$c-$r findsNothing →
        tapHoldingsPnlToggle → expect(repo.calls, <bool>[false, true]) · (c, r) 마다: if (row.pnl != null) shown(h61-row-$c-$r) == holdingsRowTexts(row) + h61-pnl-$c-$r findsOneWidget / else h61-pnl-$c-$r findsNothing(if/else 짝 · row = pnl.cards[c].rows[r]) ·
          h61-row-0-0 1(카드 펼침 유지) · find.descendant(of: h61-pnl-toggle, matching: find.text(pnl.pnlToggleLabel!)) 1 →
        tapHoldingsPnlToggle(접기) → expect(repo.calls, <bool>[false, true])(새 호출 0) · (c, r) 마다 h61-pnl-$c-$r findsNothing →
        tapHoldingsPnlToggle(다시 펼침 — 펼친 채로 나간다) → expect(repo.calls, <bool>[false, true])(캐시 · 새 호출 0) · find.descendant(of: h61-pnl-toggle, matching: find.byIcon(Icons.expand_less)) 1 →
        재진입 = await pumpHoldingsOverview(tester, overrides: overrides, screenKey: const ValueKey<String>('again')); await tester.pump(); → expect(repo.calls, <bool>[false, true]) · h61-row-0-0 findsNothing(접힘) ·
        find.descendant(of: h61-pnl-toggle, matching: find.byIcon(Icons.expand_more)) 1(새 State = 손익 접힘) → openHoldingsCard 0 → h61-pnl-0-0 findsNothing(펼침이 전역이면 여기서 걸린다) · ⓡ.
 T61-07 RECON = 글자만(K16 ⓕ · K10) — recon · 안전 = safetyFixtureRow(3) · expect(safetyFixtureRow(3).activeFlags, isNotEmpty) → 플래그마다 find.text(f.label) findsOneWidget ·
        rc = recon.cards[1] · expect(rc.allocation.sleeveWeight, isNotNull) → h61-card-weight-1 data == rc.allocation.sleeveWeight!.label · h61-card-state-1 data == rc.allocation.bandStateLabel ·
        openHoldingsCard 1 → ⓗ expect(rc.rows, hasLength(2)) → r 마다 shown == holdingsRowTexts(rc.rows[r]) · find.descendant(of: h61-row-1-$r, matching: find.byIcon(Icons.warning_amber_rounded)) findsNothing ·
          find.descendant(of: h61-row-1-$r, matching: find.byIcon(Icons.error_outline)) findsNothing(아이콘 0) · ⓡ.
 T61-08 INTEGRITY = 가림 글자 · 칩 부재(K10 · K29 · K14) — integrity · 안전 = safetyFixtureRow(4) · 플래그마다 find.text(f.label) findsOneWidget(전제 isNotEmpty) ·
        ⓗ expect(integrity.cards, hasLength(3)) → c 마다: expect(card.allocation.sleeveWeight, isNull) 전제 → head shown == holdingsCardHeadTexts(card) · h61-card-weight-$c findsNothing · h61-card-state-$c findsNothing ·
          openHoldingsCard(tester, c) → r 마다: expect(row.smaTranches, isEmpty) · expect(row.pendingText, isNull) 전제 → shown == holdingsRowTexts(row) · h61-pending-$c-$r findsNothing ·
          find.descendant(of: h61-row-$c-$r, matching: find.byIcon(Icons.check_circle)) findsNothing(트랜치 칩 0) →
        openHoldingsExternal → k 마다 expect(integrity.external!.rows[k].quantityText, normal.external!.rows[k].quantityText) 전제 → shown(h61-ext-row-$k) == holdingsExternalRowTexts(그 행) · ⓡ.
 T61-09 화면 Text 전부(수용 (d) · C4d-1 — 손익 정렬·합계 위젯 0) — 두 경우 ㉠ (closed · steps = 카드 0·1·2 + 섹션 펼침 · allowed = holdingsOverviewAllowed(normal)) ·
        (expanded · steps = tapHoldingsPnlToggle → 카드 0·1·2 + 섹션 펼침 · allowed = holdingsOverviewAllowed(pnl))마다(repo = fakeHoldingsOverview(normal, pnl) · 안전 행 0 · 정상 시계):
        위 규칙 10 의 «화면의 Text 전부» 견본 그대로 · ⓡ.
 T61-10 뷰어(K15 · K14 ⓑ) — viewer · expect(viewer.pnlToggleLabel, isNull) · expect(viewer.external, isNull) 전제 → h61-pnl-toggle findsNothing · h61-ext findsNothing · h61-card-2 1 · h61-card-3 findsNothing ·
        h61-alloc-link 1 · expect(find.byType(Card), findsNWidgets(viewer.cards.length))(빈 섹션 0 — Key 없는 Card 도 센다) · expect(repo.calls, <bool>[false]) · ⓡ.
 T61-11 링크 = 데이터만(규칙 4) — normal · opener = RecordingLinkOpener() · openHoldingsCard 1 → r0 = normal.cards[1].rows[0] · r1 = normal.cards[1].rows[1] ·
        expect(r0.detailDeepLink, isNotNull) · expect(r1.entryReasons[0].detailDeepLink, isNotNull) · expect(normal.allocationLink, isNotNull) 전제 →
        tap(find.descendant(of: h61-row-1-0, matching: find.text(r0.symbolLabel))) → tap(find.descendant(of: h61-row-1-1, matching: find.byType(ActionChip))) → tap(h61-alloc-link) →
        tap(h61-card-toggle-2)(펼침 탭 = 이동 아님) → expect(opener.opened, <String>[r0.detailDeepLink!, r1.entryReasons[0].detailDeepLink!, normal.allocationLink!.deepLink]) · ⓡ.
 T61-12 갈래별 정적 글자 × 배너(C4r3-1 · 위 «갈래별 정적 글자» 표) — 아홉 경우 ㉠ (이름, overview, clock, steps, 스켈레톤, 에러, 머리, 배너, 오래됨, 빈):
        (loading · 값을 내지 않는 StreamController) · (fail · Stream.error(StateError('overview'))) · (empty · empty) · (empty_stale · empty + 시계 +2일) · (normal · normal) · (normal_stale · normal + 시계 +2일) · (integrity · integrity) ·
        (pnl_loading · false = normal · true = 값을 내지 않는 StreamController · steps = tapHoldingsPnlToggle) · (pnl_fail · false = normal · true = Stream.error · steps = tapHoldingsPnlToggle)마다 ·
        🆕 안전 = 아홉 경우 모두 safetyFixtureRow(3)(차단 2) · 경우 목록의 overview 칸 = Stream<HoldingsOverviewVm> Function(bool includePnl, StreamController<HoldingsOverviewVm> silent)(silent = 테스트 안에서 만든 컨트롤러 · teardown unawaited close) ·
        expect(find.byKey(const Key('h61-loading')), wantSkeleton ? findsOneWidget : findsNothing) · 같은 꼴로 Key('h61-fail') · Key('h61-asof') · find.text(JournalLabels.staleBannerTitle) · Key('h61-empty') ·
        find.text(JournalLabels.retry)(= 에러 칸) · expect(safety.activeFlags, isNotEmpty) 전제 → 플래그마다 expect(find.text(f.label), wantBanner ? findsOneWidget : findsNothing)(배너 = empty · empty_stale · normal · normal_stale · integrity 만) ·
        공통 find.byType(CircularProgressIndicator) findsNothing · find.byType(LinearProgressIndicator) findsNothing · find.text(JournalLabels.holdingsAvgPrice) findsNothing(카드 접힘)
        (ⓡ·ⓗ 없음 — 다시 시도 단언이 bool 꼴이다 · 플래그 루프 앞 전제는 isNotEmpty).
 T61-13 에러와 재시도(lastAsOfLabel) — 세 경우 ㉠ (overview_fail · (p, call) → call == 0 ? Stream.error : Stream.value(normal) · steps 없음 · 기대 lastAsOf null · 재시도 뒤 calls == [false, false]) ·
        (pnl_fail · (p, call) → p ? (call == 1 ? Stream.error : Stream.value(pnl)) : Stream.value(normal) · steps = tapHoldingsPnlToggle · null · [false, true, true]) ·
        (value_then_fail · (p, call) → call == 0 ? valueThenFail(normal) : Stream.value(normal) · 없음 · normal.asOf.label · [false, false])마다(안전 = safetyFixtureRow(3)):
        h61-fail 1 · tester.widget<JournalErrorView>(find.byType(JournalErrorView)).lastAsOfLabel == 경우의 기대값 · 플래그마다 find.text(f.label) findsNothing(에러 갈래 배너 0 · 전제 isNotEmpty) →
        find.text(JournalLabels.retry) 탭 → pump 두 번 → h61-fail findsNothing · h61-asof 1 · expect(repo.calls, <경우의 기대 목록>) · ⓡ(재시도 뒤).
 T61-14 큰 글꼴 — 두 경우 (open · normal · steps = 카드 0·1·2 + 섹션 펼침) · (empty · empty · 없음)마다: 띄우기 전에 tester.platformDispatcher.textScaleFactorTestValue = 2.0 +
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue) → pumpHoldingsOverview → steps → expect(tester.takeException(), isNull) ·
        await tester.scrollUntilVisible(find.byKey(const Key('h61-asof')), -300)(펼친 뒤 머리가 위로 밀려 지어지지 않는다 — 되돌려 올린다) · h61-asof 1 · ⓡ.
 T61-15 손익 줄 = 데이터(규칙 «손익 줄은 데이터로만 열린다» · 화면이 _pnlOpen 으로 줄을 고르지 않는다) — repo = fakeHoldingsOverview(pnl, normal)(🔴 일부러 뒤집은 짝 — 접힘 구독에 손익이 실린 값 · 펼침 구독에 손익 없는 값) ·
        expect(pnl.cards[0].rows[0].pnl, isNotNull) 전제 → openHoldingsCard 0 → expect(repo.calls, <bool>[false]) · h61-pnl-0-0 findsOneWidget(토글 전에도 데이터가 열면 열린다) →
        tapHoldingsPnlToggle → expect(repo.calls, <bool>[false, true]) · h61-row-0-0 1 · h61-pnl-0-0 findsNothing · ⓡ.
 (T61 에 없는 번호는 없다 — 01~15.)
 ⓡ 기대 = holdings_overview_test.dart 14줄(T61-01·02·03·04·05·06·07·08·09·10·11·13·14·15) · ⓗ 기대 = 8줄(T61-01·02·03·04·05·06·07·08 각 1) ·
   🔴 정확히 이 수(다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 불가 — 규칙 10).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려):
   진입을 includePnl true 로(리터럴은 C-44 ⑭ 가 · 변수 초기값 true 는 T61-01) · 접기 때 새 구독(autoDispose · 다른 열쇠) · 펼침 상태를 전역 프로바이더로(재진입 때 펼침 유지) · 손익 줄을 _pnlOpen 으로 고르기(데이터 무시 — `if (_pnlOpen && gain != null)` 꼴 · `if (_pnlOpen)` 꼴 둘 다) · 손익 토글 아이콘 고정 ·
   카드 수 3 하드코딩 · 카드 순서 뒤집기 · 카드를 처음부터 펼침 · 카드 펼침 상태 공유(한 카드 탭에 전부 펼침) · sleeveWeight 있을 때 bandNoteText 자리에 글자 · 상태색 매핑 바꾸기(inBand → error — 표본 카드 상태는 전부 IN_BAND · nearEdge·outOfBand 칸 = 정적 S28 검토) ·
   상태 아이콘을 bandState 없을 때도 그림 · 행 순서 바꾸기 · 행 안 Text 순서 바꾸기 · 반영 대기 칩 빼기 · 하위 칩 빼기 · 트랜치 칩을 filled 만 · 트랜치 칩 아이콘 맞바꾸기 · 배지 아이콘 매핑 바꾸기(PASS 의 아이콘 — 표본 배지는 전부 PASS · 나머지 3값 칸 = 정적 S29 검토) · 행 탭 무반응 · 행 탭에 다른 링크 ·
   RECON 행에 경고 아이콘 덧붙임 · 섹션 고지를 접힘에서 숨김 · 섹션 행을 처음부터 펼침 · 섹션 행 등록일 머리 빼기 · 「비중 보기」 무반응 · 「비중 보기」 를 카드·섹션 아래로 옮기기 · 토글 글자를 정적 라벨로 ·
   로딩에 배너(overview) · 에러에 배너(overview) · 로딩에 배너(pnl) · 에러에 배너(pnl) · 빈 갈래에 배너 빼기 · 빈 갈래에 머리 빼기 · 에러를 스켈레톤으로 · 로딩에 스피너 · 오래됨 배너 안 그림(정상·빈 갈래 각각) ·
   lastAsOfLabel 안 넘김 · 재시도에 다른 열쇠 invalidate · 뷰어(토글 null)에 토글 · external null 에 빈 섹션(Key 가 있든 없든) · 손익 줄에서 disclosureNote 빼기 · 화면에 정적 글자 하나 더하기(합계 줄).
   🔵 판정 = 변이마다 test/holdings_overview_test.dart + test/golden/h61_golden_test.dart 를 함께 돌린다 · 골든은 아이콘 차이를 못 본다(테스트 글꼴에서 아이콘은 같은 네모) — 아이콘 변이는 T61-03·T61-06 이 잡는다 ·
      표본이 없는 칸(rowsEmptyText · bannerText · 상태색 nearEdge·outOfBand · 배지 PASS 밖 3값)은 «정적 검토만» — 변이로 판정하지 않는다 · 드라이런(이 판) = 이 목록 전부 KILLED.

■ 정적 묶음 — packages/ui_journal 에서 아래 31줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 31줄을 돌려 글자로 대조한다 — 다르면 거짓 주장 = 반려 · 대조에서 빼는 것은 빈 줄·EXIT 표기(1/0 ↔ False/True)·
   warning:·error: 로 시작하는 줄·PowerShell 장식 줄(«At line:…»·«위치 줄:…» · «+ …» 로 시작하는 줄 — CategoryInfo · FullyQualifiedErrorId 류)·줄 머리의 경과 시각(mm:ss)뿐 · 테스트 이름·패키지 이름 한 낱말이라도 다르면 반려).
  🔴 **출력은 줄이지 않는다** — 길어도 그대로.
  🔴 dart test·flutter test 출력은 화면에서 손으로 옮겨 적지 않는다 — 파일로 떠서 붙인다(Windows PowerShell 5.1: 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8 →
     <명령> | Out-File -Encoding utf8 $env:TEMP\<이름>.txt → Get-Content -Encoding UTF8 $env:TEMP\<이름>.txt 가 보여 준 줄을 그대로 복사 · 파일은 저장소 밖이라 git status 는 빈 채).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  🔴 블록 뒤에 S05 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 사전검사 R4).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/holdings_overview_test.dart test/holdings_overview_fakes.dart test/golden/h61_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/holdings_overview_test.dart test/golden/h61_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/holdings_overview_test.dart test/golden/h61_golden_test.dart; echo "EXIT:$?"
echo "## S02c testWidgets lines"; git grep -c "testWidgets(" -- test/holdings_overview_test.dart test/golden/h61_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (H6-1 file)"; git grep -nP "(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S04 route constants and link literals 0"; git grep -nE "AppRoutes|AppLinkSchemes|'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "journalLinkOpenerProvider" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S06 holdings repository provider lines"; git grep -n "journalHoldingsRepositoryProvider" -- lib; echo "EXIT:$?"
echo "## S07 overview subscription lines"; git grep -nE "watchHoldingsOverview|includePnl" -- lib; echo "EXIT:$?"
echo "## S08 forbidden calls 0 (H6-1 file)"; git grep -nE "watchHoldings\(|watchSleeves|watchFlags|ConfigRepository|JournalRepository|watchTimeline|LedgerRepository|watchExternalHoldings|PerformanceRepository|AdviceRepository|ExecutionGapRepository|CommandApi|recordDisclosureView|DraftStore|\.watchState\(|watchEvents|watchEvent\(|journalTimelineRepositoryProvider|journalConfigRepositoryProvider|journalCommandApiProvider|journalDraftStoreProvider" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S09 branch shell format words 0 (H6-1 file)"; git grep -nE "operatingMode|OperatingMode|RunMode|runMode|FeatureFlags|satelliteEnabled|kIsWeb|Platform\.|DateTime\.now|DateTime\.timestamp|clock\.now\b|Scaffold|AppBar|SafeArea|SnackBar|Navigator|GestureDetector|toStringAsFixed|toStringAsPrecision|NumberFormat|journal_draft|SleeveId\.|HoldingScope\.|AllocationBasis\." -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S10 raw keys and unread fields 0 (H6-1 file)"; git grep -nP "\.(quantity|avgPrice|unrealizedPnl|pnlPct|absoluteStop|trailStop|customStop|highWaterMark|level|weight|targetWeight|bandLow|bandHigh|symbol|sleeve|scope|scopeLabel|basis|tierCode|entryDecision|blockedReasonCode|code|wire|isDeviation|kindCode|holdingId|accountAlias|stopLine|momentum|stepNo|filledOn|externalId|decision|sleeveLabel|deployedText|parkingText|deployedRatio|parkingRatio|trancheStateText|deployedPctText|parkingPctText|parentSleeve|engineColumnNote|parkingNoteText|gauge|stateChips)\b" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S11 trimming 0 (H6-1 file)"; git grep -nE "maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S12 sort filter pick words 0 (H6-1 file)"; git grep -nP "(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet|last|lastOrNull|sublist|getRange|elementAt|removeAt|removeWhere|retainWhere|shuffle)\b|\breverse:\s*true|groupBy|FlagIds|activeFlags|markerOnly" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S13 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 exhaustive switch escapes 0 (H6-1 file)"; git grep -nE "default:|case _:|^\s*_ =>" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S15 autoDispose (old comment line only)"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## S16 barrel exports 7"; git grep -n "^export " -- lib/ui_journal.dart; echo "EXIT:$?"
echo "## S17 operator barrel 1"; git grep -n "^export " -- lib/journal_draft.dart; echo "EXIT:$?"
echo "## S18 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_journal/)" -- lib; echo "EXIT:$?"
echo "## S19 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S20 figures 0 (prompt 48-54)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S21 decimal and percent literals 0 (H6-1 file)"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S22 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_journal.dart lib/src/common/journal_common.dart; echo "EXIT:$?"
echo "## S23 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/holdings_overview_test.dart; echo "EXIT:$?"
echo "## S24 H lines (hasLength)"; git grep -c "hasLength(" -- test/holdings_overview_test.dart; echo "EXIT:$?"
echo "## S25 h61 key names"; git grep -noP "h61-[A-Za-z]+(-[A-Za-z]+)*" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S26 new labels (3)"; git grep -n "holdings" -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## S27 rich text widgets 0 (H6-1 file)"; git grep -nE "RichText|SelectableText|Text\.rich" -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S28 band state switch lines (3)"; git grep -n "SleeveBandState\." -- lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S29 gate state switch lines (4)"; git grep -n "GateState\." -- lib/src/holdings_overview.dart; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름·문자열 리터럴은 ASCII 만 · S02c = 2줄 «test/golden/h61_golden_test.dart:1» · «test/holdings_overview_test.dart:15»(git grep 경로 순) ·
   S03 = 엔진 글자 가공 0 · S04 = lib 전체 출력 없음 · S05 = 탭 콜백 안 2줄(종목 행 InkWell 의 onTap · 「비중 보기」 OutlinedButton 의 onPressed — 줄 번호는 짓는 모양마다 다르다) — build 본문에서 읽는 줄 0 ·
   S06 = 3줄(정의 1 · throw 문구 1 · family 의 .watch 1 — dart format 이 나눈 대로 · 줄 번호는 짓는 모양마다 다르다) · S07 = 2줄(family 매개변수 줄 · .watchHoldingsOverview(includePnl: includePnl) 줄) ·
   S08·S09·S10·S11·S12 = 0 · S13 = 출력 없음 · S14 = 0 · S15 = «lib/src/journal_draft/journal_draft_form.dart:37:» 주석 1줄뿐(새 줄 0) ·
   S16 = 7줄(l10n/labels.dart · src/blind_review.dart · src/decision_detail.dart · src/holdings_overview.dart · src/journal_read.dart · src/timeline.dart · src/unknown_board.dart 순) · S17 = 1줄(src/journal_draft/journal_draft_form.dart) ·
   S18~S20 = 10항의 1·3·2 항 근거 · S21 = C-44 ⑲ 0 · S22 = 두 줄(labels.dart · ui_journal.dart) 둘째 수(삭제) 0 · 첫째 수 = labels 11 · 배럴 1(드라이런 · 주석·빈 줄을 세므로 짓는 모양에 따라 달라도 된다 · 기준 = 둘째 수 0 · 배럴 1 · journal_common 줄 없음) ·
   S23·S24 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대와 정확히 같아야 한다(14 · 8 · 다르면 반려) ·
   S25 = 이름 22개(h61-loading · h61-fail · h61-asof · h61-empty · h61-pnl-toggle · h61-card · h61-card-toggle · h61-card-title · h61-card-weight · h61-card-note · h61-card-state · h61-row · h61-pending · h61-subbook · h61-pnl ·
   h61-rows-empty · h61-ext · h61-ext-toggle · h61-ext-notice · h61-ext-banner · h61-ext-row · h61-alloc-link — 같은 이름이 갈래마다 두 번 나와도 된다(h61-asof) · Key 표 밖의 h61- 0) ·
   S26 = 3줄(holdingsAvgPrice · holdingsEntryDate · holdingsRegisteredOn) · S27 = 0 · S28 = 3줄(inBand · nearEdge · outOfBand) · S29 = 4줄(pass · block · notApplicable · unknown))

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · 설계서 §3-4 · golden README «🆕 R4» 절 표 그대로)
  h61_normal(normal · 안전 행 0 · 흐름 = B 카드 펼침(openHoldingsCard 1)) · h61_recon_mismatch(recon · 안전 행 3 · 흐름 = B 카드 펼침) · h61_integrity(integrity · 안전 행 4 · 흐름 없음 = 카드 전부 접힘 · K29) ·
  h61_empty(empty · 안전 행 0 · 흐름 없음) · h61_pnl_expanded(normal/pnl · 안전 행 0 · 흐름 = tapHoldingsPnlToggle → 카드 0·1·2 펼침 — 손익 줄 3 + disclosureNote)
  모두 const HoldingsOverview() · 시계 = FixedClock(kGoldenNowUtc) · 크기 = 테스트 파일 안 상수 const Size _kTallPhone = Size(390, 2480)(ui_journal 꼴 — j4_golden_test.dart · 다섯 이름 모두 맨 아래 위젯이 그 높이 안 — 드라이런 dy 최대 2436(h61_pnl_expanded) ·
  이 값을 바꾸지 않는다 · kGoldenPhoneSize 는 M2 소유).
  모양 = j4_golden_test.dart 처럼 (이름, 흐름) 목록 × Brightness.values 루프 · 테스트 이름 '$name ${brightnessSuffix(b)}' ·
  차례 = await pumpForGolden(…) → await tester.pump();(한 번 더 — 값 도착 · 빼면 흐름의 첫 탭이 «0 widgets» 로 실패) → await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden.
  🆕 (이름, 흐름) 목록 = 이 코드 글자 꼴(C4r3-4 · 흐름 = 클로저 · 🔴 흐름을 nullable 칸 + if 로 고르지 않는다 · 이름·칸 이름은 재량):
    class _Flow {
      const _Flow({required this.name, required this.closed, required this.open, required this.safetyRow, required this.steps, required this.bottomKey});
      final String name;
      final HoldingsOverviewVm closed;   // includePnl false 의 값
      final HoldingsOverviewVm open;     // includePnl true 의 값
      final int safetyRow;
      final Future<void> Function(WidgetTester tester) steps;
      final String bottomKey;
    }
    final List<_Flow> flows = <_Flow>[
      _Flow(name: 'h61_normal', closed: normal, open: pnl, safetyRow: 0, steps: (WidgetTester t) => openHoldingsCard(t, 1), bottomKey: 'h61-ext'),
      _Flow(name: 'h61_recon_mismatch', closed: recon, open: pnl, safetyRow: 3, steps: (WidgetTester t) => openHoldingsCard(t, 1), bottomKey: 'h61-ext'),
      _Flow(name: 'h61_integrity', closed: integrity, open: pnl, safetyRow: 4, steps: (WidgetTester t) async {}, bottomKey: 'h61-ext'),
      _Flow(name: 'h61_empty', closed: empty, open: empty, safetyRow: 0, steps: (WidgetTester t) async {}, bottomKey: 'h61-empty'),
      _Flow(name: 'h61_pnl_expanded', closed: normal, open: pnl, safetyRow: 0, steps: (WidgetTester t) async {
        await tapHoldingsPnlToggle(t); await openHoldingsCard(t, 0); await openHoldingsCard(t, 1); await openHoldingsCard(t, 2);
      }, bottomKey: 'h61-ext'),
    ];
  골든 파일 import(directives_ordering · 7줄): 'package:domain_contracts/domain_contracts.dart' → 'package:flutter/material.dart' → 'package:flutter_riverpod/flutter_riverpod.dart' →
     'package:flutter_test/flutter_test.dart' → 'package:ui_journal/ui_journal.dart' → '../holdings_overview_fakes.dart' → 'golden_support.dart'(쓰지 않는 것은 뺀다 — analyze)
  🆕 찍기 전 위치 전제 둘 = 이 코드 글자 꼴(C4r3-5 · 흐름 뒤 pumpAndSettle 다음 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(Key(flow.bottomKey))).dy, lessThan(_kTallPhone.height));   // 맨 아래 위젯이 화면 안
    expect(tester.getTopLeft(find.byKey(const Key('h61-asof'))).dy, 0.0);                                // 스크롤 0(펼침 탭의 scrollUntilVisible 이 머리를 밀어 올리지 않았다)
    → await expectGolden(flow.name, b);
  맨 아래 Key = h61_empty 만 'h61-empty' · 나머지 넷 = 'h61-ext'(「비중 보기」 는 상단 — 맨 아래가 아니다).
  둘째 전제(머리 dy == 0)가 실패하면(ListView padding · 펼침 탭의 스크롤 등) 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 «측정:» 행으로 적는다.
  packages/ui_journal 에서:
    flutter test --update-goldens test/golden/h61_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG(h61_* 10)만 ?? · M 0
  🔴 다른 골든 테스트 파일·폴더를 --update-goldens 에 넣지 않는다.
  위치 전제가 실패하면(본문이 높이를 넘으면) 높이(_kTallPhone — 카드 확정값)를 늘리지 않는다.
  화면 여백(간격 — SizedBox 높이·Padding 의 정수)을 줄여 맞추는 것은 간격 재량으로 허용한다 — 단 줄였으면 «줄이기 전 dy» 와 «줄인 뒤 dy» 를 질문 파일에 «측정:» 사실 행으로 남긴다
     (12 §3 공통 조문 «골든 높이 = 재량 + 기록»). 여백을 줄여도 넘거나, 여백 말고 다른 것(글자·배치·요소 수)을 바꿔야 들어가면 멈춘 뒤 실제 dy 값을 질문 파일에 적는다(바꾸지 않는다).
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다):
    그 골든 테스트 파일의 위치 전제 lessThan(<높이>) 한 곳을 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/h61_golden_test.dart(--update-goldens 없이)
    → 테스트 이름('h61_normal light' … )마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- <그 파일> 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개)
· H61_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 이 카드의 질문은 전부 여기에(다른 질문 파일을 고치지 않는다 — J1~J5 포함).
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A5 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  권고와 다르게 지은 이름 · 3개 밖에 더 필요했던 정적 라벨(더하지 않고 질문으로) · 문서에 없어 정한 것 전부.
    | A1 | R4a-Bob-H61 | 추측 | 측정: h61_normal dy 실측값 (light=<값>, dark=<값> < <높이>) | 골든 위치 전제 실측 | <높이> 미만 확인 | ⬜ 미답 | |
    (A2 = h61_recon_mismatch · A3 = h61_integrity · A4 = h61_empty · A5 = h61_pnl_expanded · 같은 형식 · <높이> = _kTallPhone 의 높이 숫자 · <값> 자리에만 잰 숫자)
  골든 높이를 맞추려고 여백을 줄였으면 A6 부터 줄인 이름마다 한 행(«측정: <이름> 여백 줄이기 전 dy (light=<값>, dark=<값>) · 줄인 뒤 dy = 그 이름의 A 행 값» · 줄이지 않았으면 이 행 0).
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 3개 · 읽지 않는 필드 목록(규칙 3) · 처음 접힘 · 펼침 = State · 토글 모양 · 색·아이콘 매핑 ·
  배치 순서 · 행 Text 순서 · 골든 이름·입력·흐름 · 재량인 것(여백·글자 크기·모서리 — 단 골든 높이를 맞추려 여백을 줄였으면 위 «측정:» 행은 적는다). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(4) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(권장대로 나눴으면 (4)))
  cd packages/ui_journal
  flutter test test/holdings_overview_test.dart              ← 끝 줄을 그대로 적어 둔다(기대 «+28: All tests passed!» · 손으로 세지 않는다)
  flutter test test/golden/h61_golden_test.dart              ← 끝 줄 그대로(기대 «+10: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄을 그대로 적어 둔다 · 기대 = 시작 기준 N + 38(드라이런 284 → 322))
  cd ../domain_contracts
  dart test test/contracts/c44_holdings_test.dart -r expanded   ← 전부 통과 · 출력에서 «C-44 ⑫ 대상» 으로 시작하는 줄과 그 바로 아래 들여쓴(공백 4칸) 경로 줄을 그대로 적어 둔다(진행 표시 줄 «00:00 +0: …» 은 빼고)
     (기대 2줄: «C-44 ⑫ 대상 H6 1파일 — packages/ui_journal/{lib/src/holdings_overview.dart, lib/src/holding_detail.dart, lib/src/holdings_allocation.dart} + packages/ui_journal/lib/src/holdings/**» +
      공백 4칸 들여쓴 «packages/ui_journal/lib/src/holdings_overview.dart» · 출력 그대로 적는다 · C-44 20/20 통과 · domain_contracts 전체는 «+336 ~30»(PR #50 뒤 · melos run test 가 돈다))
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 다음으로 간다
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 경로 앞머리 packages/ui_journal/ 가 붙어 찍힌다): A lib/src/holdings_overview.dart · M lib/l10n/labels.dart · M lib/ui_journal.dart ·
        A test/holdings_overview_fakes.dart · A test/holdings_overview_test.dart · A test/golden/h61_golden_test.dart · A test/golden/goldens/h61_*.png 10장 · M docs/ai-context/inbox/H61_questions.md ·
        그 밖의 줄(M PNG · 기존 lib·테스트 파일 · 하네스 · README · domain_contracts/** · 다른 질문 파일) = 금지 — 하나라도 있으면 푸시하지 말고 멈춘 뒤 출력을 채팅으로
  사전검사 ① 코드만(저장소 뿌리에서 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다 — C4 가 같은 줄을 다시 돌린다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0 --golden-prefix h61_ --goldens 10
     ← 끝 줄 «── 결과: 🔴 a · 🟡 b». 🔴 가 하나라도 있으면 푸시하지 않는다 — 줄마다 적힌 <파일>:<줄> 을 고친다(테스트만 · 검사를 피하려고 if 를 다른 꼴로 감추지 않는다 —
        for (… in <T>[?x]) · ?.let 류로 바꾸는 것도 감추기다) → 고친 것은 새 커밋 하나로 더한다(권장 제목 «[M6] R4a (5) 사전검사 지적 수정» · 🔴 amend·rebase 금지 ·
        이때는 이 커밋이 마지막이어도 된다 — melos.bat run format:fix 를 먼저 돌려 format 0 changed 는 그대로 지킨다) → 이 줄을 다시 돌려 🔴 0 을 본다 · 🟡 는 멈춤이 아니다(PNG·글을 다시 열어 보고 맞으면 그대로).
  git push -u origin ui/m6-h61-holdings
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  git log --oneline origin/main..HEAD         ← 아래 ① 에 그대로 붙일 출력(나눈 수만큼 · 권장대로면 4줄 · 맨 위 = format·질문 커밋)
  cd packages/ui_journal → 위 «정적 묶음» 31줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  10항 줄 수 — 아래 ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일에 저장(예 PowerShell 에서 메모장으로 $env:TEMP\r4a_box2.txt)한 뒤
     PowerShell: (Get-Content $env:TEMP\r4a_box2.txt).Count      또는 Git Bash: grep -c "" "$TEMP/r4a_box2.txt"
     ← 출력 그대로(기대 10 · 다르면 줄을 이었거나 나눈 것 — 고친 뒤 다시 센다 · 이 파일은 커밋하지 않는다)
         ② 에 붙이는 꼴 = 명령의 **출력 한 줄만** 코드 블록 하나로(명령 줄은 붙이지 않는다 · «….Count = 10» 처럼 명령과 잇지 않는다)
  PR 은 만들지 않습니다(통합 담당 대행) · 라벨도 붙이지 않습니다. PR 제목: [M6] H6-1 보유현황
  PR 본문 5섹션을 채팅으로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로 쓰고 그 아래에 내용을 둔다(통합 담당이 이 글을 PR 본문으로 통째로 옮긴다 · GitHub 에서 직접 고치지 않는다):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄 — 각 섹션 맨 위에 한 줄씩)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      (이 다섯 줄은 사전검사가 글자로 보는 고정 머리다 — 🔴 ② 머리의 «12항» 은 그대로 둔다(M6 의 자체 점검은 10항이지만 머리 글자를 바꾸면 사전검사 R1 🔴) · 무엇을 어느 섹션에 붙이는지는 아래 ①~⑤ 설명이 정한다)
      🔴 N1 — 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(«모든 확인 완료 …» · «이제 제출 글을 작성합니다» 같은 머리말 · 구분선 --- 금지).
      🔴 N3 — 내기 전 사전검사 ② 제출 글까지 — ①~⑤ 와 flutter test 한 줄까지 다 쓴 제출 글 전체를 저장소 밖 파일에 저장(예 PowerShell 에서 notepad $env:TEMP\R4a-Bob-H61_submit.md 로 열어 붙여 넣고 «UTF-8» 로 저장 ·
         이 파일은 커밋하지 않는다)한 뒤 저장소 뿌리에서 한 줄:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R4a-Bob-H61_submit.md --golden-prefix h61_ --goldens 10
        ← 🔴 0 이어야 채팅에 낸다 · 🔴 가 보고 글 줄(R1~R5)이면 글을 고쳐 다시 저장한 뒤 다시 돌린다 · 출력은 채팅에 붙이지 않는다.
        🔵 🟡 [G1](골든 표 «배치·잘림» ↔ PNG 덩어리 수)는 이 화면에서 나와도 멈춤이 아니다 — 사전검사는 테두리 버튼·글자 버튼·상자 속 칩을 이 카드의 셈 단위와 다르게 센다
           (드라이런 🟡 8 = 전부 G1) · 표는 이 카드의 셈 단위대로 쓰고 사전검사에 맞추려고 고치지 않는다.
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + 위 git diff --name-status origin/main...HEAD 출력 그대로(코드 블록 하나 · 손으로 쓰지 않음 · A/M · PNG 포함) +
      «커밋 목록:» + 위 git log --oneline origin/main..HEAD 출력 그대로(코드 블록 하나 · 맨 위 = format·질문 커밋)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: H6-1 — 보유현황(HoldingsOverview())
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항 — 아래 복사 상자의 10줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 10항이 10줄 그대로인지 «10항 줄 수» 명령의 출력으로 확인한다 · 항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음·명령 결과의 수):
        1번 = «정적 묶음 S18 — 허용 밖 import 0줄»
        2번 = «H6-1 화면 파일 산술 0(신선도 한 식 외) · 기하 0 · 금지 수치 S20 0건 · 소수·% 리터럴 S21 0건»
        3번 = «정적 묶음 S19 — 0건»
        4번 = «진입 구독 includePnl false 한 번(T61-01) · 펼침 = 토글 탭 재구독 · 접기 새 호출 0(T61-06) · 손익 정렬·합계 0(T61-09) · watchHoldings 부르지 않음(S08)»
        5번 = «이 카드 범위 밖(H6-1 에 J-4 없음)»
        6번 = «M5·X1·X5 화면 0 · 배너 clearDeepLink 는 공통 배너 그대로 · 이동 = 데이터 링크만(T61-11)»
        7번 = «배너 = JournalSafetyBanners 그대로(T61-07·T61-08·T61-12) · RECON «?»·INTEGRITY «숨김» = 엔진 글자 그대로 · 아이콘 0(T61-07)»
        8번 = «머리 = vm.asOf.label(h61-asof · T61-01) · 정상·빈 갈래 모두(T61-12)»
        9번 = «로딩·빈·에러·오래된 데이터·차단 = T61-12·T61-13 · 부분 동기 = 이 카드 범위 밖(Q-D)»
        10번 = «픽스처 변경 0 · 새 PNG = h61_* 10장 · 재생성 <N>장 · 미정의 타입 이름 짓기 0(H6-1 = 계약 v1.8)»
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
      «정적 묶음 출력:» + 31줄 출력 전부를 코드 블록 하나로 그대로 +
      «S05 결과:» 다음 줄부터 S05 출력 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄씩(2줄 · 괄호·백틱·앞머리·설명·줄 끝 빈칸 없이) +
      ⓡ·ⓗ = 아래 상자의 글자 틀 그대로(<…> 자리에만 정적 묶음 S23·S24 출력 줄을 그대로 복사 · 손으로 쓰지 않는다 · test/ 를 떼지 않는다) +
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = S23 출력:
<S23 출력 줄 그대로>
ⓗ = S24 출력:
<S24 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
      «C-44 ⑫ 출력:» 다음 줄부터 위 dart test 의 «C-44 ⑫ 대상» 줄과 그 아래 들여쓴 경로 줄 전부 그대로(들여쓰기 그대로) +
      «테스트 파일별:» 다음 줄부터 위 flutter test 두 파일의 끝 줄 그대로(holdings_overview_test · h61_golden_test 순)
   ③ 스크린샷 서술 — 로딩·정상·빈·차단 4줄 + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술은 코드의 위젯·Key 이름 나열로만 쓴다 — holdings_overview.dart 의 «렌더 순서» 그대로 «→» 로 잇는다
         (렌더 순서 = build 에서 시작해 private 메서드·클래스 호출을 그 자리에 펼쳐 읽은 순서 · 파일 글자 순서가 아니다) ·
         조건으로 붙는 것은 «(있을 때)» 를 붙인다 · 그 렌더 순서가 위 «화면» 의 배치와 다르면 제출하지 말고 멈춘 뒤 채팅으로.
         «로딩» = JournalSkeleton(Key('h61-loading')) — 배너 없음 ·
         «정상» = ListView → Key('h61-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('h61-alloc-link')(있을 때) → Key('h61-pnl-toggle')(있을 때) → ValueKey<String>('h61-card-$c') → ValueKey<String>('h61-card-toggle-$c') →
                  ValueKey<String>('h61-card-title-$c') → ValueKey<String>('h61-card-weight-$c')(있을 때) → ValueKey<String>('h61-card-note-$c')(있을 때) → ValueKey<String>('h61-card-state-$c')(있을 때) →
                  ValueKey<String>('h61-row-$c-$r')(있을 때) → ValueKey<String>('h61-pending-$c-$r')(있을 때) → ValueKey<String>('h61-subbook-$c-$r')(있을 때) → ValueKey<String>('h61-pnl-$c-$r')(있을 때) →
                  ValueKey<String>('h61-rows-empty-$c')(있을 때) → Key('h61-ext')(있을 때) → Key('h61-ext-toggle') → Key('h61-ext-notice') → Key('h61-ext-banner')(있을 때) → ValueKey<String>('h61-ext-row-$k')(있을 때)
                  — 이 글자와 코드가 같으면 이 글자 그대로 쓴다(낱말을 바꾸거나 요약어를 더하지 않는다) ·
         «빈» = ListView → Key('h61-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('h61-empty')(있을 때) ·
         «차단» = JournalSafetyBanners 의 자리를 코드 그대로 — «Key('h61-asof') 아래 · Key('h61-alloc-link') 위 · ListView 안».
      🔴 «순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지 · 🔴 이 서술·골든 표에 영어 색·테마 낱말(error · primary · surface …)·우리말 색 이름 0(사전검사 R2 — 에러 갈래 Key 를 h61-fail 로 지은 까닭).
      골든 표 10행(h61_*): «| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |» 꼴 마크다운 표 · 한 행 한 줄 · 이름 칸 = «h61_normal light» 꼴 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m6/holdings_overview_normal.json — 상수 이름과 섞지 않는다 · h61_pnl_expanded 는 두 경로) · 크기 = 390×<높이> ·
        dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다) ·
        배치·잘림 = PNG 를 열어 본 것만 — 🆕 이름마다 light PNG 한 장만 연다(5장) · dark 행 = 같은 이름 light 행의 칸 글자 그대로(그 이름의 dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다) ·
        (PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 글자 내용·글자 길이의 차이는 쓰지 않는다 · 못 본 것은 «미열람») ·
        칸 꼴 = «<위에서부터 PNG 에 보이는 덩어리를 → 로 — 글자 n줄 · 상자 · 배경 덩어리 · 칩 n개 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>» ·
           «글자 n줄» = PNG 에 보이는 글자 행 수(줄바꿈 포함) · «칩 n개» = 한 무리의 칩 개수 · 버튼 = «버튼 글자» · 코드 이름·픽스처 낱말 금지 · 칸 끝의 «— 잘림 …» 은 빠뜨리지 않는다(10행 모두).
   ④ 질문 목록 — 아래 명령 출력에서 «+|» 로 시작하는 줄 전부를 코드 블록 하나로 그대로(이 카드가 질문 파일에 더한 새 행 전부 — 측정 행 포함 · 앞의 + 와 줄 순서 그대로 · 요지 표를 손으로 만들지 않는다):
      git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/H61_questions.md   ← 저장소 뿌리에서 · 푸시한 그 커밋 위에서 · «+++ b/…» 줄은 넣지 않는다(표 행만)
      (셸에서 한글이 깨져 보이면 PowerShell 에서 [Console]::OutputEncoding = [Text.Encoding]::UTF8 를 한 번 돌린 뒤 다시 돌린다 — 출력을 손으로 고쳐 쓰지 않는다)
   ⑤ 추측한 것 = H61_questions.md 의 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄 · <…> 자리에만 출력 그대로 · 아래 «(+ flutter test 한 줄 …)» 의 상자)
flutter test: 시작 기준 <N> → 끝 <packages/ui_journal 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = «끝 00:16 +320: All tests passed!» 꼴 — 시각·«+수»·«All tests passed!» 까지 출력 끝 줄 그대로 · «끝 320» 처럼 수만 쓰지 않는다 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 38 · 수를 따로 계산해 덧붙이지 않는다 · 다르면 그 위 한 줄에 «까닭:» + 위 테스트 파일별 끝 줄로 설명))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-h61-holdings` 푸시 1건 · 커밋 권장 4개(본문 (1)~(4) · **마지막 = format·질문 커밋** · amend·rebase·강제 푸시 0 · 나누기는 재량 — 각 커밋 제목이 그 내용과 맞으면 된다).
- `lib/` 새 파일 **1**(`src/holdings_overview.dart`) · 수정 2(더하기만 — `l10n/labels.dart` 끝 R4a 절 라벨 3 · `ui_journal.dart` export 1줄(정렬 자리)) — 삭제 0(S22). 그 밖의 `lib/`(J-1~J-5 화면 · `journal_common.dart`)는 바뀌지 않는 것이 정상 · `lib/src/holdings/` 없음.
- `test/` 새 파일 3(`holdings_overview_test.dart` · `holdings_overview_fakes.dart` · `golden/h61_golden_test.dart`) + 새 PNG 10장(`h61_*`) · 기존 테스트·PNG·하네스·README 불변(재생성 0 → `golden:approved` 불필요 · CI 골든 잡 초록이 정상).
- 질문 파일 `H61_questions.md`(새 행 A1~A5 «측정:» 은 반드시 · 그 밖은 있을 때만).
- 채팅: PR 본문 5섹션(섹션 머리 ①~⑤ 글자 그대로 · ① 머리 1줄 + name-status 출력 그대로 + 커밋 목록 · ② 복사 상자 10항(10줄) + 괄호 + 10항 줄 수 출력 + «정적 묶음» 31줄 출력 전부 + S05 2줄 + ⓡ·ⓗ 출력 줄 + C-44 ⑫ 출력 + 테스트 파일별 끝 줄 · ③ Key 나열 + 골든 표 10행(dy 는 이름·밝기마다 · PNG 열람 5장) · ④ · ⑤) + flutter test 한 줄 · 사전검사 두 번(① 코드만 · ② 제출 글까지) 🔴 0.
- `flutter test` = 시작 기준 N(0단계 · 드라이런 284) + 새 38(뷰 28 + 골든 10 · 드라이런 322) · 정적 S23 = 14 · S24 = 8(🔴 정확히 — 다르면 반려) · S05 = 2 · S06 = 3 · S07 = 2 · S16 = 7 · S25 = 22이름 · S26 = 3 · S28 = 3 · S29 = 4 · S22 = 11/0 · 1/0 · C-44 ⑫ = «H6 1파일»(2줄).
- 재분할 임계 확인(카드 계획): 새 testWidgets 줄 16(뷰 15 + 골든 1 · 임계 «> 33» — 넘지 않음) · lib +407/-0(드라이런 · 임계 «> +900» — 넘지 않음) · 새 PNG 10(임계 «> 16» — 넘지 않음) — 넘으면 C4 가 다시 나눈다. 드라이런 판정 = 재분할 불필요(세 임계 모두 안).
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것: 원판(조립 판 테스트)에서 통과한 것 5 — 배지 PASS 아이콘 맞바꿈 · 손익 줄 `_pnlOpen &&` 꼴 · 손익 펼침 전역(재진입 때 펼침 유지) · 빈 갈래 오래됨 배너 빼기 · 뷰어에 Key 없는 빈 섹션 →
  이 판 테스트(T61-03 칩 아이콘 · T61-15 · T61-06 펼친 채 재진입 · T61-12 empty_stale · T61-10 Card 수)로 전부 KILLED · 「비중 보기」 아래로 옮기기 = T61-01 사슬이 KILLED · 이 판 목록 전부 KILLED(드라이런 변이 62 = KILLED 57(그중 골든만 2) · 통과 5 = 목록 밖 참고 변이 — rowsEmptyText · bannerText · 상태색 nearEdge · 배지 BLOCK · 링크 조립(정적 검토 · S04)).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R4a-Bob-H61 결과: 브랜치 ui/m6-h61-holdings 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다(Claude 가 PR 을 만들고 본문을 이 글로 통째로 씁니다 · 이 카드는 기존 PNG 를 바꾸지 않으므로 `golden:approved` 라벨은 필요 없습니다 — 기존 PNG 가 `M` 이면 그것이 반려 신호). Bob 이 PR 을 직접 만들었다면 `R4a-Bob-H61 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R4a-Bob-H61 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(72장)가 `M` ② `pubspec.yaml` 변경 ③ `test/golden/` 하네스·README·기존 골든 테스트가 `M` · `journal_common.dart` 가 바뀜 ④ 화면 코드의 `aaq://`·`AppRoutes`·`Navigator`·`DateTime.now`·`FeatureFlags`·`SleeveId.`·`.watchState(`·`Scaffold` ⑤ `.quantity`·`.symbol`·`.sleeve`·`holdingId`·`.weight` 원값·키 · «?» 를 검사하는 코드 · `includePnl: true` 리터럴 · `.where`·`.sort`·`.take` · `'%'` 문자열 ⑥ 마지막 커밋이 format·질문 커밋이 아님 · 공용 2파일에 삭제 줄 ⑦ ② 의 S05~S07·S25 출력에 주석 줄이 찍힘 · ⓡ·ⓗ 수(S23·S24)가 14·8 이 아님 — 하나라도 있으면 반려 신호(⑦ 의 S05 줄 표기만의 결함은 strict 나눔 ① = C4 정정).
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 10장만 · 기존 PNG 재생성 0) — 혹시 C4 가 기존 PNG 재생성을 허용하게 되면(카드 개정) 라벨은 **Bob 푸시 전에** 통합 담당이 붙인다(R3 교훈 — 라벨을 뒤늦게 붙이면 CI 가 새로 돌지 않아 PR 을 닫고 다시 열어야 했다).
- 계약 테스트 C-44 의 B 절(⑬~⑲)은 이 브랜치에서 처음 `lib/src/holdings_overview.dart` 를 실제로 본다 — 병합 검사 때 Claude 가 그 위에서 `dart test test/contracts/c44_holdings_test.dart -r expanded` 를 돌리고 «C-44 ⑫ 대상» 출력을 PR 본문 ② 와 대조한다. `check_boundaries.sh` [5][5b][5c] 도 새 파일을 처음 본다.
- 🔵 **C4r3-8(R4a 병합 기록 커밋 · Claude 몫)** — `packages/ui_journal/README.md` 의 옛 줄 «⚠️ 이 PC에는 Flutter·Dart·melos가 없다(2026-09-06)» 삭제 · «무엇을 담나» 에 `H6-1` 파일·주입 1줄(`holdings_overview.dart` · `journalHoldingsRepositoryProvider`) · 테스트 수 자리 = R4a 병합본 실측(README owner = Claude — 이 카드의 Bob 몫이 아니다 · 규칙 1 이 README 수정을 막는다).
- R4a 병합 기록 커밋(Claude) 체크리스트: ⓪ `send/R4a-Bob-H61.md` → `send/_완료/R4a-Bob-H61.md`(git mv) · send/README 표 행 갱신(send/ 바로 아래 보낼 패킷 = 하나) ① `send/_대기/R4b-Bob-H62H63.md` → `send/R4b-Bob-H62H63.md` 이동 + 머리 ⏸ → ▶(🔴 R4b 머리 «선행 2» C-40 ⑧ 보강이 병합됐을 때만 ▶) ② R4b 의 `__R4A_SQ__` · 실측 표식(부호 U+27E6 · R4a 병합본 실측 — 시작 기준 · 누적 수) 채움 ③ golden README «🆕 R4» 절의 R4a 병합본 실측 dy ④ 질문 파일 `H61` A1~A5 ✅ ⑤ C4r3-8.
- 셸(R13)에 넘길 것: `holdingsOverview` → `HoldingsOverview()`(전 플랫폼 등록 · 본문 Android·iOS · 웹 = Q-D 전 «부재» 가드) · 하단 탭 「보유」 · override + `journalHoldingsRepositoryProvider`(자리 = 조립 앱 3종 `apps/app_*/lib`) — 이 카드에 없습니다.
- 범위 고지(01 §17-17 · 설계서 §7): 평면 창구 `EXTERNAL` 행 꼴(미결 103) · 손절선 게이지(미결 104 — H6-2) · 전체 이력 링크(미결 105) · 신호 결측·위성 패널(미결 106) · 뷰어 종목 손익(미결 107 — K15) · 옛 라벨 잔여·표본 시점(미결 108) · M7 픽스처 밴드 정합(미결 109) · J·`H6-3` → `H6-*` 역참조(미결 110) 는 이 카드에 없습니다.
- 🔵 표본 사실(앱 `fixtures/README` «계약 v1.8 · 표본 사실» 절) — 봉투 날짜 2026-08-31 은 계절 캘린더 미반영 합성(A 휴지기인데 A 보유 · K27 ⓒ) · 화면은 날짜로 판정하지 않으므로 그대로 그린다.
- 그 밖의 알릴 것은 `_완료/R3-Bob-J4.md` «5» 를 참고합니다.
