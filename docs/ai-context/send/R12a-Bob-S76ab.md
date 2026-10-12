# 발송 패킷 R12a-Bob-S76ab — S7-6a 리밸런싱 회차 타임라인 + S7-6b 회차 상세 (계약 v1.6 · R12 4장 중 1번째)

> ⏸ **아직 보내지 않습니다**(2026-10-08 조립 · 드라이런·콜드 리드 반영판) — 계약 v1.6 병합(PR #`__V16_PR__` · squash `__V16_SQ__`)과 이 카드를 `send/` 로 올리는 기록 커밋(`__REC__`)이 GitHub `main` 에 있어야 합니다. **R12 4장 중 1번째**(순서 고정 R12a → R12b → R12c → R12d · 앞 카드 병합 뒤 다음 카드) · 한 번에 카드 1장 · R12b~R12d 는 기록 커밋 `__REC__` 이 `send/_대기/` 에 두고, 앞 카드 병합 기록 커밋이 `send/` 로 옮기며 ⏸ → ▶ 로 바꾼다.
> 만든 날 2026-10-08 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R12 행 «v1.6 4분할 공통» + R12a 행 · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-08_R12선행_계약v1.6_설계서.md` §2-5(위젯·파일 자리·주입) · §2-6(호출 표) · §2-7(필드 → 자리) · §3-5(골든 ↔ 입력) · §6 카드 규칙 1~19(공통)·20~23(R12a) · §7(분할) · 조문 = `01_…` §15-4(15-4-3 · 15-4-7 · 15-4-8 · 15-4-9 · 15-4-18) · §15-3(v1.5 링크) · `03_…` §11 머리 «v1.6 블록 읽는 법» · §11-a «🆕 계약 v1.6 — `S7-6a` R12 범위» 블록 · §11-b «🆕 계약 v1.5 — `S7-6b` R12 범위» 블록(ⓐ~ⓙ) + «🆕 계약 v1.6 — `S7-6b` R12 범위» 블록(①~⑧) · §1-4 «🆕 계약 v1.6 — R12 범위» 줄 · golden README «🆕 R12(계약 v1.6)» 절(기록 커밋 `__REC__` 이 만든다).
> 사전 조건 — ⬜ **계약 v1.6 병합**(M2 PR #`__V16_PR__` · squash `__V16_SQ__` · `contractVersion '1.6.0'` · 픽스처 135 · 라우트 45 · 받침대 `UnimplementedExecutionGapRepository` · C-41 · C-42) · ⬜ 기록 커밋 `__REC__`(이 카드 `send/` · `inbox/S7-6ab_questions.md` 빈 머리말 · `prompt_M7.md` 2·3·109·118행 R12 치환 · golden README «🆕 R12» 절). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 시작 기준 = 병합본 `flutter test`(packages/ui_analytics) — **304 기대**(v1.6 은 ui lib 0 · PNG 0 · ui 테스트 3파일만 바꿨다 · 01 §15-4-17 ①) · 드라이런 = 304(끝 354 − 새 50 · 기존 테스트 파일 M 0 으로 맞춘 값 — 기록 커밋 위 누적 드라이런에서 0단계로 다시 잰다).
> 카드 확정값(카드 권한): 정적 라벨 6개(본문 «정적 라벨») · Key 표(본문 «Key 표» — 설계서 §6 규칙 17 글자 그대로) · 위젯·프로바이더·파일 이름(본문 «주입 구조» — 01 §15-4-7 · §15-4-18 글자 그대로) · 테스트·가짜 파일 이름 · 골든 6이름 12장(크기 390 × 960 · 드라이런 실측 맨 아래 dy 최대 892 · 테스트 파일 `s76ab_golden_test.dart`).
> 🔴 **보내는 조건(Claude 확인)** — v1.6 PR 병합 + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음 + 질문 파일 `inbox/S7-6ab_questions.md` 가 `main` 에 있음(빈 머리말 — 기록 커밋 `__REC__` 이 만든다) + `prompt_M7.md` 의 `R12a = S7-6a` 치환이 `main` 에 있음(그 글자는 2행·109행에만 — 3행 이력·118행 PR 제목에는 쓰지 않는다) + golden README «🆕 R12(계약 v1.6)» 절이 `main` 에 있음(그 절의 R12a 행 = `s76a_*`·`s76b_*` 6이름 12장 · `kS76abGoldenSize` 390 × 960 — 이 카드 머리 6행과 같은 크기 · 다르면 README 를 고친 뒤 보낸다). 0단계의 `ls`·`git grep` 줄이 그 증명입니다. + 🔴 이 파일에 실측 자리표시자(흰 겹꺾쇠 «실측» 표식) 0건(겹꺾쇠 글자 grep -c = 0) + 기록 커밋 위의 누적 드라이런 폴더에서 0단계 전부(특히 기록 커밋 몫 네 줄 — `send/` · `inbox/` · `prompt_M7.md :2` · golden README 절)를 다시 돌려 통과(드라이런 `dry/r12a` 는 기록 커밋 전 `e716fe0` 위라 그 네 줄은 확인하지 못했다).
> 🔴 **기록 커밋 체크리스트(Claude)** — `__REC__` 이 다섯을 다 했는지 ▶ 로 바꾸기 전에 본다: ① `docs/ai-context/send/R12a-Bob-S76ab.md`(머리 ⏸ → ▶) ② `docs/ai-context/inbox/S7-6ab_questions.md` 빈 머리말(다음 번호 Q1·A1 · 표 머리 + 구분줄 · 행 0) ③ `packages/ui_analytics/test/golden/README.md` «🆕 R12(계약 v1.6)» 절 — R12a 행 6이름 · 390 × 960 / R12b 행 5이름 · 390 × 844 / R12c 행 5이름 · 390 × 1440 / R12d 행 6이름 · 390 × 844(네 카드 머리의 크기와 같게) ④ `prompt_M7.md` 2·3·109·118행 치환(2행 = `{{범위}}`·PR 제목 · 3행 = 조립 이력 · 109행 = 범위 · 118행 = PR 제목 — 모두 R12 네 장을 함께 적은 값 · «R12x = » 글자는 2·109행에만 · 171줄 유지 · 156~170행 = 12항 15줄) ⑤ `send/_대기/R12b-Bob-S76c.md` · `send/_대기/R12c-Bob-S77.md` · `send/_대기/R12d-Bob-S710.md`(머리 ⏸ 그대로).
> 🔴 **결정 K 표기** — 이 카드가 기대는 K5(라우트 `rebalanceHistory`) · K10(`RebalanceEvent.asOf` = 관측 시각) · K11(`SleeveWeight.label` = 완성 문장) · K22(R12 차단 표시 = 배너만)는 **권고 선반영 · 🔴 「푸시해」 전 발주자 확인 대기**다(K7 · K14 · K26 = 권고 선반영). 카드 본문은 K 를 «확정»으로 인용하지 않는다. 🔴 8건 확인에서 K5·K10·K11·K22 가운데 하나라도 뒤집히면 이 카드는 무효 — Claude 가 다시 조립한다(01 §15-4-19).
> 드라이런: ✅ 2026-10-08~12(가지 `dry/r12a` 끝 `7f72538` · 밑동 = v1.6 로컬 tip `e716fe0` — 🔴 기록 커밋 `__REC__` 전이라 0단계의 기록 커밋 몫 네 줄은 확인 못 함 · 질문 파일은 새로 만들어 A 로 찍힘 — 보내기 전 누적 드라이런 폴더에서 기록 커밋 위 재확인) — 카드 본문만 보고 커밋 6개 · `flutter test`(packages/ui_analytics) 304 → 354(+50 = timeline 15 · event 23 · 골든 12) · 새 PNG 12(390×960) · 기존 PNG M 0 · domain_contracts 변경 0 · lib +416/−0(timeline 170 · event 211 · labels +8 · providers +25 · barrel +2) · 맨 아래 dy(light=dark) s76a_list 848 · s76a_empty 120 · s76a_sim 324 · s76b_band 892 · s76b_seasonal 692 · s76b_advisory 892 · S05a 3줄 · S05b 2줄 · S15 6줄 · S27 8/0 · 25/0 · 2/0 · S29 10·8 · S30 3·7 · C-42 대상 S7-6a 1 · S7-6b 1 · providers R12 절 24줄 · format 0 changed · analyze·test:contracts SUCCESS · 예고 변이 32건 모두 잡힘(살아남은 변이 0) · 드라이런 지적 9건 + 콜드 리드 12건 반영(이 판). 재분할 임계(설계서 §7 — 새 `testWidgets(`/`test(` 줄 > 33 · lib > +900 · 새 PNG > 16) = 새 줄 23(timeline 10 · event 11 · 골든 2) · lib +416 · PNG 12 → 재분할 불필요.
> 프롬프트 = `docs/ai-context/prompt_M7.md`(범위 치환판 — 2행 `{{범위}}` · 109행 «이번 과제 범위:» · 118행 PR 제목은 기록 커밋 `__REC__` 이 R12 네 장(R12a~R12d)을 함께 적은 값으로 바꾼다 · 0단계 확인 줄 `git grep -c "R12a = S7-6a"` = `:2` 가 그 증명(🔴 기록 커밋은 그 글자를 2행·109행에만 쓴다) · 🔴 기록 커밋은 줄을 더하지 않는다(171줄 그대로 — 이 카드가 행 번호로 덮는다) · 이 카드의 범위·PR 제목은 이 패킷이 정한다 · 그 파일 머리 4·5행 표식(«🔵 정정 표식» · «보충 표식» — 양방향 딥링크 필드)은 그대로 읽는다) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R11 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 이렇게 쓴다»로, 0단계·규칙 요약·본받지 않는 것·코드 틀은 본문에 담았습니다.
> R10·R11 교훈 반영: 보고 기계화(② 12항 복사 상자 + 15줄 세는 명령 · «정적 묶음» 출력 그대로 · ① name-status 출력 그대로 · ③ 위젯·Key 이름 나열 + 픽스처 경로) · S05 줄 = «<파일>:<줄> — 탭 콜백 안» 만(R10c 2회차 반려 사유) · 보강 줄(ⓡ·ⓗ) 수는 `git grep -c` 출력으로 대조 · 테스트별 수는 «테스트 수 묶음» 명령 출력 그대로(12 §3 R11c «재발 방지 ①») · 배치 순서는 테스트가 사슬로 증명 · 조건부 단언 금지 · 공용 파일은 «정확히 N»으로 못박지 않고 «끝 절 더하기만»(R10 3분할 교훈 · «정확히 N» = R12d 한 곳) · 🆕 strict 보고 규칙 나눔(12 §3:228) · 🆕 «PR 본문은 통합 담당이 바꾼다»(12 §3:230 — 제출 상자에 섹션 머리 ①~⑤) · 🆕 다음 카드 단언 보강 후보 C4b-12(배너 «스크롤 밖») · C4b-13(배지 색 = `colorScheme` — 범례 견본 색의 준용) · C4b-14(Key 자리마다 글자 == vm 필드).

## 0. 한 줄 목적

리밸런싱 회차가 **언제·왜·무엇이 바뀌었나**를 보는 두 화면 — `S7-6a` 회차 타임라인(`watchEvents()` 봉투 · 엔진이 시간 역순으로 준 행 · 「모의」 배지 그룹 · 행 탭 = `detailDeepLink` · 빈 봉투 = `emptyLabel` + «다음 예상») 과 `S7-6b` 회차 상세(`watchEvent(id)` 하나 · 전·후 비중 = `SleeveWeight.label` 문장 · 임계 대조 = `thresholds` · 당시 스냅샷(접힘) · 실행 품질 · 하단 `journalTimelineLink` · 신선도 = `event.asOf`) — 를 계약 v1.6 그대로 짓기. 차단은 배너만.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m7-s76ab-rebalance`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **계약 v1.6 이 `main` 에 병합되고 기록 커밋이 푸시된 뒤에 보냅니다** — 이 파일 머리 첫 줄이 ⏸ 이면 아직입니다(Claude 가 v1.6 병합을 기록할 때 ▶ 로 바꿉니다). Bob 의 0단계 확인 줄이 그것을 다시 확인합니다(하나라도 안 보이면 Bob 이 멈춥니다 — 그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화나 R11 을 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R12a-Bob-S76ab.md> (로컬 사본 = Claude 기록 폴더의 `docs/ai-context/send/R12a-Bob-S76ab.md` · 기록 푸시 뒤 `main` 과 글자가 같습니다 · 폴더 경로는 Claude 가 ▶ 로 바꿀 때 확인한 절대 경로로 적습니다). 🔴 Bob 폴더 `C:\Work\Bob\AutoAlphaQuant\` 는 앞 카드 브랜치에 있어 이 파일이 안 보이거나 옛 카드만 보일 수 있습니다. 보낼지는 GitHub `main` 에 있는지로 판단합니다.
4. 붙여넣을 것은 «3» 본문 **전부** — ```text 다음 줄(«R12a-Bob-S76ab — 범위»)부터 닫는 ``` 직전 줄(«■ 제출» ⑤ 의 «(없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)»)까지 · 울타리(```)와 구분선(---)은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — M7 의 끝난 카드 `_완료/R11a-Bob-S74*.md` · `_완료/R11b-Bob-S79*.md` · `_완료/R10a-Bob-S71b.md` · `_완료/R10b-Bob-S72G*.md` · `_완료/R10c-Bob-S72*.md` · `_완료/R1b-Gem-S71.md` · `_완료/R2-Gem-S73*.md`, M6 의 끝난 카드 `_완료/R2b-Bob-J3.md` 를 붙여넣지 않습니다. `send/_대기/` 의 `R12b-Bob-S76c.md` · `R12c-Bob-S77.md` · `R12d-Bob-S710.md` 도 붙여넣지 않습니다(기록 커밋 `__REC__` 이 `_대기/` 에 둔다 → 앞 카드 병합 기록 커밋이 `send/` 로 옮기고 ⏸ → ▶ 로 바꾼 뒤 발송). `send/` 바로 아래의 R12 패킷은 이것 하나입니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R12a-Bob-S76ab — 범위»)부터 닫는 ``` 직전 줄까지 그대로(울타리 두 줄과 구분선 `---` 은 넣지 않는다 · «2» 의 4 와 같은 범위)

---

```text
R12a-Bob-S76ab — 범위: S7-6a 리밸런싱 회차 타임라인(RebalanceTimelineScreen — 봉투 rows 를 받은 순서 그대로 · 행 = 일자 · 유형 칩 · 「모의」 배지 ·
  요약 한 줄 · 행 위 머리글 · 행 탭 = detailDeepLink · 빈 봉투 = emptyLabel + «다음 예상» 버튼 · 하단 기준일) +
  S7-6b 회차 상세(RebalanceEventScreen — 일자·유형 → 리밸런싱 전 → 리밸런싱 후 → 임계 대조 → 당시 스냅샷(기본 접힘) → 실행 품질 →
  이 회차의 기록 버튼 → 하단 기준일). R12 4장 중 1번째(R12b S7-6c · R12c S7-7 · R12d S7-10 은 이 카드 병합 뒤).
🔴 S7-6a 는 기간을 고르지 않는다 — watchEvents() 를 인자 없이(전체 기간) 부른다 · S7-6b 는 watchEvent(id) 하나만 구독한다(목록을 id 로 고르지 않는다).
🔴 비중·밴드·이탈은 SleeveWeight.label 문장 안에서 끝난다 — weight·targetWeight·bandLow·bandHigh·sleeve 를 읽지 않는다. 임계 대조 = thresholds(접힘 밖).
🔴 차단 = SafetyBlockBanner 만(회차별 흐리게·「미확정」·배지 0 — 결정 K22 권고 선반영 · 01 §8 미결 87).
하지 않는 것: S7-6c 다음 예상·초안(R12b) · S7-7(R12c) · S7-10(R12d) · S7-8(R12 밖) · S7-6a 유형 필터·기간 칩·프리셋·기간 글자·주문 건수(미결 83·88) ·
  S7-6a·6b 회차별 흐리게·「미확정」·배지(K22 · 미결 87) · S7-6b 상태 3종(스냅샷 결측·미확정 수량·갭 회차)·골든 s76b_missing_snapshot(입력 없음 · 미결 87) ·
  국면 배지·rawValues·triggerPrice·thresholdRegistered 표시(J-2 ⓒ · 미결 50 ①) · 「재실행」·손익·승인 버튼 · LIVE·SIM 섞인 목록 정렬(미결 89) ·
  J-1 회차 칩·J-2 → S7-6b 링크(ui_journal 몫) · 셸 몫(라우트 등록·라우터 가드 — M8 · R13) · 웹 표형·2열·반응형(Q-D) · 애니메이션.
🔴 이 카드가 docs/ai-context/prompt_M7.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 23항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R11b(ui/m7-s79-goal-path · 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-s71b-archive · ui/m7-s72g-gate · ui/m7-s72-explore · ui/m7-s74-planner ·
ui/m7-s79-goal-path)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/screens/rebalance_timeline_screen.dart · rebalance_event_screen.dart · rebalanceRepositoryProvider · Key s76a-… 가 없습니다 —
변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m7-s79-goal-path(또는 앞 카드 브랜치)일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 출력이 없어도 · «[deleted] …» 줄이 나와도 정상(병합된 브랜치는 원격에서 지워졌다)
  git checkout --no-track -b ui/m7-s76ab-rebalance origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
  git grep -c -F "contractVersion = '1.6.0'" -- packages/domain_contracts/lib/src/contract_version.dart                      ← «…contract_version.dart:1»(계약 v1.6 병합)
  git grep -c -F "watchEvents({DateRange? range})" -- packages/domain_contracts/lib/src/repositories/rebalance_repository.dart ← «…:1»
  git grep -c -F "class RebalancePreviewResult" -- packages/domain_contracts/lib/src/dto/plan.dart                            ← «…:1»
  git grep -c -F "class ExecutionGapResult" -- packages/domain_contracts/lib/src/dto/ledger_trust.dart                        ← «…:1»
  git grep -c -F "annualReview({String? year})" -- packages/domain_contracts/lib/src/repositories/performance_repository.dart ← «…:1»
  git grep -c -F "required String yearLabel" -- packages/domain_contracts/lib/src/dto/performance.dart                       ← «…:1»
  git grep -c -F "class UnimplementedExecutionGapRepository" -- packages/domain_contracts/lib/testing.dart                    ← «…:1»
  git grep -c -F "static const String ledgerExecutionGapMonth" -- packages/domain_contracts/lib/src/navigation/app_links.dart ← «…:1»
  git grep -c -F "static const String rebalanceHistory" -- packages/domain_contracts/lib/src/navigation/app_links.dart        ← «…:1»
  git grep -c -F "required List<ThresholdCompare> thresholds" -- packages/domain_contracts/lib/src/dto/rebalance.dart        ← «…:1»
  ls docs/ai-context/send/R12a-Bob-S76ab.md                                                     ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls docs/ai-context/inbox/S7-6ab_questions.md                                                  ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/test/contracts/c42_r12_screen_scan_test.dart                      ← 보여야 함(R12 화면 소스 스캔 — CI)
  ls packages/domain_contracts/test/contracts/support/r12_targets.dart                           ← 보여야 함(역할 표 — 파일 자리)
  ls packages/domain_contracts/fixtures/rebalance_6.json
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_empty.json
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_sim.json                                 ← v1.6 신설
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_detail_band.json
  ls packages/domain_contracts/fixtures/m7/m7_rebalance_detail_advisory.json
  ls packages/domain_contracts/fixtures/safety_states.json
  ls packages/ui_analytics/test/golden/goldens/s79_on_track_light.png                            ← 보여야 함(R11b 병합본 골든)
  git grep -c "R12a = S7-6a" -- docs/ai-context/prompt_M7.md                                    ← «…prompt_M7.md:2»(프롬프트 범위 치환값이 R12 로 바뀌었다 — 2행·109행)
  git grep -c "s76a_list" -- packages/ui_analytics/test/golden/README.md                      ← 숫자 하나(golden README «🆕 R12» 절의 R12a 행이 있다 — 기록 커밋 몫)
     (🔴 경로는 한 줄에 하나 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다.
      하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 명령을 한 줄씩 따로 돌린다)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R12a 가 들어간 것 — 멈추고 알림):
  ls packages/ui_analytics/lib/src/screens/rebalance_timeline_screen.dart                        ← 없어야 함
  ls packages/ui_analytics/lib/src/screens/rebalance_event_screen.dart                           ← 없어야 함
  ls packages/ui_analytics/lib/src/rebalance                                                     ← 없어야 함
  git grep -c rebalanceRepositoryProvider -- 'packages/ui_analytics/*.dart'                     ← 출력 없음이어야 함(코드만 — README 는 보지 않는다)
  git grep -c s76a- -- 'packages/ui_analytics/*.dart'                                           ← 출력 없음이어야 함(코드만)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.6 새 필드(RebalanceEvent.thresholds · modeLabel · sectionLabel …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·필드 없음» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_analytics
  flutter test   ← 시작 기준: v1.6 병합본 전부 통과 · 0 실패 · 304 기대(드라이런 304 — 304 가 아니면 PR 본문에 까닭 한 줄 — 이 수를 «시작 기준 N» 으로 적어 둔다).
                   README 의 수치는 보지 않는다(0단계 실측이 기준). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M7.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·r12_targets.dart) > 이 카드(지시) > 01 §15-4·§15-3 > 03 §11 의 «🆕 계약 v1.6·v1.5 R12 범위» 블록 >
   03 본문·그림 M7-19·M7-20 > prompt_M7. 카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_analytics + docs/ai-context/inbox/S7-6ab_questions.md 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart·계약 테스트 포함) · pubspec.yaml · analysis_options.yaml · test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·chart_probe·chart_probe_test·goal_path_probe_test·reference/**·README ·
   기존 골든 테스트 전부(s71·s71b·s72·s72g·s73·s74·s79 _golden_test) · 기존 PNG 64장 · 기존 lib(lib/planner.dart · lib/src/planner/** · lib/src/chart/** · lib/src/goal_path/** · lib/src/widgets/** · 기존 화면 7파일(contribution · drawdown_context · goal_path · monthly_report · performance_explore · report_archive · screens/explore/**)) ·
   기존 테스트 전부(ui_analytics_test · *_view_test · *_fakes · performance_explore_gate_test · perf_chart_geometry_test) · 다른 질문 파일(S7-6c·S7-7·S7-10 — 뒤 카드 몫).
   🔴 기존 PNG 64장은 하나라도 M 이면 되돌리고 멈춤 · 예외 없음(이 카드에 재생성 0). 공용 파일 3개는 **끝 절 더하기만** 한다 — 기존 줄은 한 글자도 바꾸지 않는다(정적 묶음 S27 의 삭제 수 0 이 증명 · 뒤 카드도 그 뒤에 더한다):
     lib/l10n/labels.dart = 끝 절(R11b 절 «// ── 🆕 R11b — S7-9 ──» 의 마지막 줄 뒤 · 클래스 닫는 } 앞)에 이 카드의 절 하나 ·
     lib/src/providers/analytics_providers.dart = 파일 끝(R11b 절 goalPathProvider 뒤)에 이 카드의 절 하나 — 머리 줄 «// ── 🆕 R12a — S7-6a·S7-6b ──» ·
     lib/ui_analytics.dart = export 두 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조» · directives_ordering 린트).
 2 03 §11 위쪽 본문(«데이터»·«컴포넌트»·«상태»·«수용» 줄과 그림 M7-19·M7-20)은 같은 절의 «🆕 계약 v1.6 — R12 범위» 블록과 «🆕 계약 v1.5 — S7-6b R12 범위» 블록에 집니다. 구 초안 이름·모양(«목표·현재·밴드 하한/상한·이탈 여부» 열 · 국면 배지 · thresholdRegistered 나란히 · 「이 회차의 주문 N건」 고정 글자 · 주문 건수 · 유형 필터 · 상태 3종 · ReviewSectionVm · AsOfStamp · KeyValueVm)을 코드에 쓰지 않는다. 03·01 머리의 «⬜ 로컬 커밋 — PR 대기» 흔적은 병합 전의 글이다 — 멈추지 않는다(이 카드가 이긴다).
 3 이동 = AppLinkOpener.open(link) 하나(analyticsLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트 — 경계 검사 [5b][5c]) · 링크 null = 부재(비활성 아님) · Navigator 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지 · 공개 위젯에 콜백 매개변수 금지. 이 카드가 여는 링크는 넷뿐이다: RebalanceEvent.detailDeepLink(S7-6a 행 탭 — S7-6a 에서만) · RebalanceEvent.journalTimelineLink.deepLink(S7-6b 하단 버튼 — S7-6b 에서만) ·
   BlockFlag.clearDeepLink(차단 배너 — SafetyBlockBanner 가 onOpenLink 로 넘긴다) · 고정 상수 AppRoutes.rebalancePreview(S7-6a 빈 상태 «다음 예상» 버튼 — R12 화면에서 고정 링크 상수를 쓰는 **유일한** 자리 · 01 §15-4-9). 그 밖의 AppRoutes 상수(rebalanceEvent · journalRebalance 같은 파라미터 상수 포함)·AppLinkSchemes 는 쓰지 않는다. eventId 로 링크를 짓지 않는다.
 4 값 = DTO 의 *Text·*Label·label 그대로 · 계약이 주는 표시 필드는 전부 그린다(아래 5 의 «읽지 않는 필드»는 예외) · 원값(double·int·DateTime·enum)·.wire 표시 금지 ·
   🔴 원값 표시의 이름 붙인 예외 **하나** = 일자 tradeDate.yyyyMmDd(그 문자열 그대로 — 재포맷·요일·상대일 0 · J-1 ui_journal/lib/src/timeline.dart 선례 · 01 §15-4-9) · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 값으로 색을 고르지 않음(예외 = 규칙 7 목록) · 한국어 리터럴 = lib/l10n/labels.dart 의 AnalyticsLabels 에만(테스트에도 금지).
   🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표(')를 쓰지 않는다(백틱만) — 정적 S20 은 주석 줄도 센다.
 5 읽지 않는 필드(카드가 정함 — 질문 아님 · 계약 테스트 C-42 ②③③' 가 CI 에서 기계로 본다):
   RebalanceEvent.eventId(Key 에만 — 🔴 표시 금지) · mode · kind · orderIntentIds · tradeDate(.yyyyMmDd 밖) · S7-6a 에서 journalTimelineLink · S7-6b 에서 detailDeepLink(자기 자신) · SleeveWeight.sleeve · weight · targetWeight · bandLow · bandHigh · basis / TriggerSnapshot.rawValues · triggerPrice · thresholdRegistered / ThresholdCompare.metricKey /
   ListResult.hasMore · emptyKind / S7-6a 의 행 before · after · quality · thresholds · asOf(하단 기준일은 봉투 asOf 하나) · RebalanceEventScreen 생성자 rebalanceEventId(키·호출 인자에만 — 표시 금지).
   🔴 패턴 분해(case RebalanceEvent(:mode) · final RebalanceEvent(:kind) = e)로도 읽지 않는다(C-42 ③'). S7-6b 의 final RebalanceEvent(:before, :after) = e 는 허용.
 6 화면 산술 0 · 목록 = 받은 순서·개수 그대로 — rows · before · after · thresholds 를 거르지도 세지도 정렬하지도 묶지도 합치지도 않는다(LIVE·SIM 묶음도 엔진 몫 — sectionLabel 이 말한다). C-42 ⑨ 가 S7-6 파일과 providers R12 절에서 .sort · .sorted · .reversed · .where · .whereType · .firstWhere · .lastWhere · .singleWhere · .fold · .reduce · .take · .takeWhile ·
   .skip · .skipWhile · .compareTo · .toSet · reverse: true 와 문자열 가공 .substring( · .split( · .replaceAll( · .replaceFirst( · .contains( · .startsWith( · .endsWith( · .indexOf( · .padLeft( · .padRight( 를 막는다. 허용 = for (… in …) · .map · .indexed · .length · .isEmpty · .isNotEmpty.
 7 분기 금지 — operatingMode·OperatingMode·RunMode·runMode·FeatureFlags·.mode·.kind·kIsWeb·Platform. 0 · kind·code·bool·flagId·emptyKind·값 부호로 문구·색·배너·버튼을 고르지 않는다.
   🔴 고르는 조건은 아래 목록뿐이다(목록의 bool 은 정해진 모양·색 두 갈래만 고른다):
     S7-6a: 봉투 rows 빈 여부 · emptyLabel · detailDeepLink · modeLabel · sectionLabel 의 null 여부
     S7-6b: thresholds 빈 여부 · quality · journalTimelineLink 의 null 여부 · ThresholdCompare.passed(Icons.check / Icons.remove(colorScheme.onSurfaceVariant) 두 모양 고정 —
            J-2 ui_journal/lib/src/decision_detail.dart 의 _ThresholdTable 꼴) · State 의 _snapshotOpen(스냅샷 접기·펴기)
   switch 0(C-12 — «전부 받기» 금지 · 이 카드에는 열거형 switch 가 필요 없다). 🔴 CommandState 0 · CommandApi 0(이 카드에는 명령이 없다).
 8 시계 = analyticsClockProvider(DateTime.now() 금지) — 쓰는 자리는 StaleBanner 하나다(위젯이 안에서 읽는다). 공통 상태 = 스켈레톤(스피너 금지) · 에러 = AnalyticsErrorView(onRetry: () => ref.invalidate(…) · lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) · 오래됨 = StaleBanner(asOf: …)(S7-6a = 봉투 page.asOf · S7-6b = event.asOf — 관측 시각 · K10 권고 선반영) · 차단 = SafetyBlockBanner 만(값을 가리지 않는다 · 최대 2 + «+N» 은 위젯 몫).
   🔴 로딩·에러 상태에서는 두 배너를 그리지 않는다(값이 온 뒤에만 — R11b 꼴) · 🔴 두 배너는 스크롤 밖(값이 온 뒤의 Column 첫째·둘째 자식 · ListView 바깥 위 — C4b-12 단언). 모르는 회차 id = 스트림 에러 → 공통 에러 상태(잠정 · 01 §8 미결 50 ③).
 9 공개 위젯은 본문만 — Scaffold·AppBar·SafeArea 금지(🔴 두 화면 파일의 주석에도 이 세 낱말을 쓰지 않는다 · 정적 S26 이 주석도 센다 ·
   🔴 «Scaffold» 는 부분 일치다 — ScaffoldMessenger(스낵바)도 C-42 ⑤ 와 S26 에 걸린다 · 이 카드에는 스낵바가 없다 · report_archive_screen.dart 의 클래스 주석 «Scaffold·AppBar 는 셸 소유»를 본뜨지 않는다) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible · 엔진 문장에 FittedBox 금지 · 말줄임·maxLines 금지(예외 하나 = S7-6b 스냅샷의 configHash 1줄 — maxLines: 1 · TextOverflow.ellipsis · 01 §15-4-9 «말줄임 = 레이아웃») ·
   390px overflow 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다(정적 글자 = 아래 «정적 라벨» 6개뿐) ·
   🔴 카드 = Card() 기본 고도(elevation 인자 없음) — 기존 M7 화면의 elevation: 0.5 를 본뜨지 않는다(C-42 ⑥ «소수부가 0 이 아닌 소수 리터럴 0» · 0.5·1.5 금지 · N.0·정수는 허용).
10 프로바이더는 셋만 더한다(analytics_providers.dart 끝 R12a 절 · 아래 «주입 구조» 글자 그대로) · 나머지는 이름·타입 그대로 재사용 · 오프너는 탭 콜백 안에서 ref.read — build 에서 read 금지. 🔴 결과 프로바이더 둘은 autoDispose 다(기존 비-autoDispose family 3개를 본뜨지 않는다) ·
   🔴 주석에 autoDispose 라는 낱말을 쓰지 않는다(정적 S15 가 주석도 센다) · 🔴 R12a 절 안에서 watchEvents 에 인자를 넘기지 않는다 · DateRange·TradeDate·DateTime 낱말 0(C-42 ⑬).
11 파일 자리 = 역할 표(01 §15-4-7 · test/contracts/support/r12_targets.dart 의 R12Role — C-42 의 대상) — 이 카드의 새 lib 파일은 **두 개뿐**이다(아래 «주입 구조»). 내부 위젯은 그 화면 파일 안의 private 클래스·메서드로 둔다(🔴 lib/src/rebalance/** 폴더는 이 카드에서 만들지 않는다 · 두 화면이 위젯 파일을 공유하지 않는다).
   🔴 C-42 ⑩ 가드 — R12 전용 이름(RebalanceEvent · RebalanceRepository · RebalancePreview · RebalancePreviewResult · NextRebalanceVm · AnnualReviewVm · AnnualReviewSection · ExecutionGapResult · ExecutionGapReport · ExecutionGapRepository)은 두 화면 파일과 analytics_providers.dart 의 R12a 표식 **아래**에만 둔다(표식 위 · widgets · 다른 화면에 두면 CI 실패).
12 테스트 = testing.dart 받침대 extends(UnimplementedRebalanceRepository · UnimplementedSafetyRepository — 새 가짜에 implements 금지) · 받은 인자 전부 기록 · 호출마다 새 Stream(예외 = 로딩 테스트의 StreamController 하나 — 그 테스트는 한 번만 구독한다) · 전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 눌러서(프로바이더·State 에 값을 직접 넣지 않는다) · 🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 ·
   정상 상태 테스트는 expect(find.text(AnalyticsLabels.retryButton), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(픽스처 행에서) · 링크는 RecordingLinkOpener 를 픽스처 값과 비교(테스트에 'aaq://'·'handbook://' 리터럴 0 — [5c]) · 픽스처마다 갈리는 단언은 if/else **양쪽에** expect(있으면 1 · 없으면 그 Key 0) · 테스트 이름은 번호 + ASCII(예 'T76A-02 rows in received order rebalance_6').
   «… 0» · «… 1»(화면 요소 — Key·글자·위젯)은 find.… 로 화면에서 센다(가짜의 호출 수는 기록 목록으로) — 픽스처 필드를 expect 하는 줄은 전제일 뿐 증명으로 세지 않는다 · 스켈레톤 1 = expect(find.byType(AnalyticsSkeleton), findsOneWidget) — 스피너 부재로 대신하지 않는다 · 테스트는 package:ui_analytics/src/widgets/analytics_error_view.dart · analytics_skeleton.dart 를 직접 import 한다(배럴이 export 하지 않는다) ·
   🆕 C4b-14 사슬 — Key 를 단 Text 는 tester.widget<Text>(find.byKey(…)).data == 그 vm 필드로 본다 · Key 를 단 묶음(Column·Card·버튼)은
      tester.widgetList<Text>(find.descendant(of: find.byKey(…), matching: find.byType(Text))).map((Text t) => t.data).toList() == 기대 목록(순서까지)으로 본다 ·
   🆕 C4b-12 — 차단 배너 글자와 «오래된 데이터» 글자는 expect(find.ancestor(of: find.text(…), matching: find.byType(Scrollable)), findsNothing) 로 «스크롤 밖»을 증명한다 · if/else 양쪽 단언에서 else 쪽 findsNothing 이 없으면 반려 · 카드가 «<» 라 적은 곳을 «<=» 로 바꾸지 않는다 · 카드가 «N개» 라 적은 곳을 greaterThanOrEqualTo 로 바꾸지 않는다.
   🆕 ⓡ = 아래 최소 목록에 ⓡ 로 표시한 테스트마다(정상 상태 + 로딩 T76A-06 · T76B-08a — 표시가 정의다) expect(find.text(AnalyticsLabels.retryButton), findsNothing); **한 줄** · ⓗ = 최소 목록에 ⓗ 로 표시한 자리의 expect(<목록>, hasLength(n)); 전제 한 줄 ·
      둘 다 도우미로 감싸지 않고 dart format 뒤에도 한 줄 — 정적 S29·S30 의 git grep -c 가 최소 목록의 표시 수와 **정확히** 같아야 한다(timeline ⓡ 8 · ⓗ 7 / event ⓡ 10 · ⓗ 3 ·
      다르면 제출 전에 테스트를 고친다 · 까닭 한 줄로 갈음 못 함 · 다른 채 내면 반려) · 그 밖의 루프(플래그·사슬 Finder·Text·경우 목록)에는 hasLength( 0.
   🔴 금지하는 if = «한쪽만 단언하는 if»(else 없는 if · 조용한 건너뛰기) · 양쪽에 expect 가 있는 if/else(최소 목록의 «양쪽 다»)와
      «없는 쪽은 따로 단언»과 짝인 collection-if(사슬 Finder·기대 글자 목록을 «있는 것만» 만드는 것)는 허용.
   🔴 firstWhere 는 테스트에서도 쓰지 않는다 — 예외 **하나** = rebalance_fakes.dart 의 도우미 rebalance6Event(id)(rebalance_6 픽스처 행을 event_id 로 고르는 슬라이스 ·
      golden_support.dart «슬라이스(행 고르기)는 허용» · 설계서 §3-5 s76b_seasonal 입력). 테스트 본문은 그 도우미만 부른다.
13 골든 = 새 PNG 12장(s76a_* · s76b_*) · --update-goldens 는 새 테스트 파일 하나 지정(test/golden/s76ab_golden_test.dart · 폴더 지정 금지) · golden:approved 는 안 붙임(통합 담당) · 찍기 전 위치 전제(맨 아래 위젯의 dy < 높이) · 입력 없는 골든(s76b_missing_snapshot) 0 · 시계 FixedClock(kGoldenNowUtc).
14 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · Windows 의 melos 는 안쪽 실패를 SUCCESS 로 낼 수 있다 — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   🔴 ui_analytics 의 테스트는 패키지 폴더에서 flutter test 로 직접 돌린다(제출 단계의 melos.bat run test 는 한 번 · 백그라운드·파이프로 돌리지 않는다) · package:collection 없음 · unawaited_futures 린트(기다리지 않는 Future 는 unawaited(…)) · directives_ordering 린트(import·export 는 가나다가 아니라 경로 알파벳 순) · 쓰지 않는 import 금지(analyze --fatal-infos).
15 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 카드는 산술이 0 이라 걸릴 자리가 없다 — 만들지 않는다).
16 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
17 정적 묶음은 git grep 이라 **주석도 센다**(C-42 는 주석을 빼고 보므로 CI 가 초록이어도 정적 묶음은 달라진다) — 이 카드가 lib 에 쓰는 줄(두 화면 파일 · providers·labels 의 R12a 절)의 주석에 정적 묶음 S03~S26 이 찾는 낱말을 쓰지 않는다 — 예: AppRoutes(허용 상수 줄 밖) · analyticsLinkOpenerProvider · CommandApi · CommandState · Navigator · DateTime · DateRange · TradeDate ·
   kIsWeb · Platform. · 'aaq:// · toStringAsFixed · GestureDetector · Colors · .replaceAll · .contains · .where · .sort · .reversed · reverse: true · autoDispose · Scaffold · AppBar · SafeArea · planner · operatingMode · RunMode · FeatureFlags · orderIntentIds · rawValues · thresholdRegistered · triggerPrice · .weight · .mode · .kind · .sleeve · .hasMore · journalTimelineLink(S7-6a 파일) ·
   detailDeepLink(S7-6b 파일) · ReviewSectionVm · AsOfStamp · KeyValueVm(카드 문장을 가드 주석으로 옮겨 적지 않는다 — 주석은 한국어 설명만 · Key·글자 인용은 백틱).
18 🔴 두 화면 파일은 analytics_providers.dart 를 show 없이 import 한다 — S05a 에는 탭 콜백 줄 3개만(행 InkWell · s76a-empty-next · SafetyBlockBanner onOpenLink) · S05b 에는 2개만(s76b-link-journalTimelineLink · SafetyBlockBanner onOpenLink) 나와야 한다(import 줄·주석 줄이 찍히면 위반 · 그 줄에 «— 탭 콜백 안» 을 적으면 거짓 보고 = 반려).
🔴 보고 규칙(12 §3:228 strict 보고 규칙 나눔 · 발주자 결정 2026-10-01 — R11b 재제출 판정부터 모든 Bob 카드) —
   ① **보고 표기만의 결함**(경로 앞머리·백틱·요지 줄임·까닭 누락 등 — 내용은 사실이고 글자 모양만 카드와 다른 것) = 반려하지 않는다 → 통합 담당(C4)이 PR 본문을 정정하고 병합
      (고친 곳에 «C4 정정» 인용 · Bob 원문은 PR 댓글로 보존) ② **코드·테스트 결함**(카드 규칙 위반 — 예 규칙 12 «else 없는 if»)과 **거짓 주장**(보고 ≠ 코드·파일·PNG) = **반려**(재량 없음)
   ③ 아래 «예고 변이»가 테스트를 **통과**하면 = **반려**.
   🔴 **PR 본문은 통합 담당이 바꾼다**(12 §3:230) — Bob 은 PR 을 만들지 않고 PR 본문을 GitHub 에서 직접 고치지 않는다(채팅으로만 · 섹션 머리 ①~⑤ 는 «■ 제출» 상자 글자 그대로).
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 시도하지 않은 것을 «시도했다»고 쓰지 않는다 · 골든 표는 PNG 를 열어 픽스처와 대조한 «배치·잘림»만(글자는 테스트 글꼴이라 네모).
   🔴 S05a·S05b 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 만(정규식 ^[^ ]+:[0-9]+ — 탭 콜백 안$ · <파일> = git grep 출력 경로 그대로 · 괄호·위젯 이름·매개변수 이름·설명 금지 —
      금지 예 = R10c 2회차 반려 사유 «…:103 — 탭 콜백 안 (SafetyBlockBanner onTap)»).
   🔴 ⓡ·ⓗ 개수 = 정적 S29·S30 의 git grep -c 출력 · 테스트별 수(«까닭» 류 포함) = «테스트 수 묶음» 명령의 끝 줄 그대로(손으로 세지 않는다 · 12 §3 R11c «재발 방지 ①»).
   ② 의 12항 = «■ 제출» 복사 상자(prompt_M7.md 156~170행 글자 그대로)를 붙이고 [x] 와 괄호만 채운다(범위 밖도 [x] + 괄호 · [—] 0 · 항목 신설·고쳐 쓰기 0) → «12항 15줄» 명령으로 센다.
   ③ = 코드를 위에서 아래로 읽으며 나오는 위젯·Key 이름 나열만(«순서대로»·«정상 배치»·«모두»·«상단» 같은 요약어 금지).
   질문 파일에 테스트 강화·카드 지시 이행 내역을 추측 행으로 적지 않는다(골든 dy 측정 행은 예외 — «질문 파일» 절) · 새 행 상태 «⬜ 미답» · 답 칸 비움.

■ 프롬프트보다 이 카드가 이긴다 — 23항 (prompt_M7.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 12~13행 «의존 … 추가하려면 먼저 질문» → 추가 없음(pubspec 불변)
 ② 14~15행 «다른 화면으로는 라우트 상수로 딥링크만 요청» → 링크는 데이터로 온다(detailDeepLink · journalTimelineLink.deepLink · BlockFlag.clearDeepLink) · 고정 상수 = S7-6a 빈 상태 «다음 예상» AppRoutes.rebalancePreview 하나만(규칙 3)
 ③ 16~18행 DateTime.now() 금지 · «화면이 포맷해도 되는 것은 TzInstant 뿐» → 그대로 · 주입 시계를 읽는 자리는 StaleBanner 하나 · 일자는 tradeDate.yyyyMmDd 문자열 그대로(포맷이 아니다 — 원값 표시의 이름 붙인 예외 하나 · 규칙 4)
 ④ 20~25행 산술·건수 집계 금지 → 그대로 유효 — 이 카드는 산술 0(비중 double·밴드를 읽지 않는다) · 행·대조 행·회차를 세지 않는다(개수 단언은 테스트에서 .length)
 ⑤ 27~29행 «아이콘·색 매핑은 재량» → 두 곳은 재량 아님: 대조 표 passed = Icons.check / Icons.remove(colorScheme.onSurfaceVariant) 두 모양 고정 · 「모의」 배지 = colorScheme.tertiaryContainer 바탕 + colorScheme.onTertiaryContainer 글자(아래 «화면») · 그 밖의 간격·굵기·모서리는 재량
 ⑥ 30~32행 «아무 일 없음 문장도 만들지 않는다 · 비어서 아무것도 오지 않으면 그리지 않는다» → 그대로 · S7-6a 빈 봉투 = emptyLabel 그대로 + «다음 예상» 버튼 · thresholds 0건 = 표 부재 · quality null = 패널 부재 · journalTimelineLink null = 버튼 부재
 ⑦ 40~43행 «딥링크의 목적지 이름을 지어내지 마십시오» → 그대로(이 카드는 목적지를 짓지 않는다 — 규칙 3 의 넷뿐)
 ⑧ 44~48행·64~69행 «띠가 차지할 높이를 비워 두기» → 예약 안 함(01 §9) · 「모의」 배지와 «모의투자 회차» 머리글은 **셸 접두가 아니라 행 데이터**(엔진 글자 modeLabel·sectionLabel · 결정 K7 권고 선반영)라 이 카드가 그린다 — FeatureFlags·RunMode 를 읽지 않는다(행의 mode 도 읽지 않는다)
 ⑨ 50~56행 수치·금액 리터럴 금지 → 그대로 유효 · 실제 강제 = C-38 ⑫ + C-42 ⑥(소수부 ≠ 0 소수 · % 를 품은 문자열 0) + 정적 S21~S23
 ⑩ 70~71행 축을 분기 조건으로 쓰지 마십시오 → 그대로(advisory 갈래는 journalTimelineLink.label 글자 안에서 끝난다 — 03 §11-d · 위젯트리 operatingMode 0)
 ⑪ 89~91행 PR · 자체 점검 10항 · 스크린샷 4장 → PR 은 만들지 않음(브랜치 푸시까지 · 제출 글은 채팅) · 12항(156~170행) · 스크린샷 = 서술 + 골든 표(«제출» ③)
 ⑫ 95~96행 «픽스처가 그대로인데 기존 스냅샷을 다시 찍는 것은 위조» → 그대로 유효 · 이 카드에 재생성 0(기존 PNG 64장 M 0 · 예외 없음)
 ⑬ 99~102행 TODO(question-3)·«M2 미정의» → 자리표시자 금지 · 질문 파일로 · 이 두 화면의 타입은 코드에 확정(RebalanceEvent v1.6)
 ⑭ 103~109행 역할 문단 · «반응형으로 넓히십시오» · 109행 범위 치환값 → 범위 = 이 카드의 S7-6a + S7-6b · 폰 세로 하나(웹 표형·2열 = Q-D 범위 밖) · 치환값은 R12 네 장을 함께 적은 것이다(0단계 확인 줄)
 ⑮ 110~116행 «읽을 문서 5개» → 아래 «먼저 읽을 것»
 ⑯ 117~118행 브랜치 형식 ui/m7-<화면ID소문자> · PR 제목 치환값 → ui/m7-s76ab-rebalance · PR 제목은 «■ 제출» 이 정한다
 ⑰ 120~124행 S7-2 손익 노출 3종 → 12항 4번 괄호 «이 카드 범위 밖»
 ⑱ 125~127행 기간 프리셋 → S7-6a 는 기간을 고르지 않는다 — watchEvents() 를 인자 없이(전체 기간 · 01 §15-4 · 결정 K26 권고 선반영) · 기간 칩·프리셋·기간 글자 0
 ⑲ 128~132행 결측 보간·TWR−MWR·DD 게이지 → 이 카드에 해당 없음(12항 7번·8번 «이 카드 범위 밖»)
 ⑳ 133~148행 플래너·S7-8·세후 사다리·목표 경로 가정 카드·S7-10 → 이 카드 범위 밖(S7-6c = R12b · S7-7 = R12c · S7-10 = R12d · S7-8 = R12 밖)
 ㉑ 149~151행 «양방향 딥링크 … 필드가 아직 없으면 링크를 만들지 말고 요청 목록에» → 필드는 있다(v1.5 · 머리 5행 표식) — 이 카드 = S7-6b 하단 journalTimelineLink 버튼 하나 · J-2 → S7-6b(DecisionDetailVm.rebalanceLink)는 ui_journal 몫(범위 밖) · «같은 날짜로 짝 찾기» 0
 ㉒ 152~154행 값을 두면 안 되는 미결 → 해당 없음
 ㉓ 164행(12항 9번) «as-of 기준일이 모든 성과 화면 상단에 상시 표기» → R12 화면의 기준일 자리는 **하단 1줄**이다(01 §15-4-9 «모든 asOf.label — 하단» · R10a·R11b 의 상단 배치를 본뜨지 않는다) · «오래된 데이터» 배너(StaleBanner)는 맨 위(스크롤 밖) · 9번 괄호에 그 자리를 적는다(복사 상자 글자는 그대로)

■ 먼저 읽을 것 (🔴 02·04·05 명세는 읽지 않음 · 03 은 아래 ③ 의 블록만)
 ① prompt_M7.md 전문(머리 4행 «🔵 정정 표식» · 5행 «보충 표식» 포함)
 ② 01 §15-4 — 15-4-1(한 문장) · 15-4-3(S7-6a·S7-6b — watchEvents 범위 · RebalanceEvent 3필드 · asOf 뜻 · SleeveWeight.label 뜻 · ThresholdCompare 이동) · 15-4-7(공개 위젯·파일 자리·주입) · 15-4-8(호출 표) · 15-4-9(필드 → 자리 · 어긴 채 통과하는 길) · 15-4-10 의 rebalance_6·detail_band·detail_advisory·m7_rebalance_sim 행 · 15-4-18(카드 4장 · 이름) — 참고로 §15-3(v1.5 회차 링크)
 ③ 03 §11 머리 «🆕 계약 v1.6 블록 읽는 법» · §11-a «🆕 계약 v1.6 — S7-6a R12 범위» 블록(①~⑦) · §11-b «🆕 계약 v1.5 — S7-6b R12 범위» 블록(ⓐ~ⓙ) + «🆕 계약 v1.6 — S7-6b R12 범위» 블록(①~⑧) · §1-4 «🆕 계약 v1.6 — R12 범위» 줄 · §11-d(advisory) — 찾는 말 = «R12 범위 · 이 블록이 이긴다»
 ④ packages/domain_contracts/lib/ — src/dto/rebalance.dart(RebalanceEvent · SleeveWeight · TriggerSnapshot · ExecutionQuality — 주석의 «ui 미참조(C-42)» 표식) · src/dto/common.dart(ThresholdCompare · LinkAction) · src/primitives/list_result.dart(ListResult) · src/primitives/money.dart(TradeDate — yyyyMmDd) · src/repositories/rebalance_repository.dart(watchEvents · watchEvent · watchNext — 머리 주석) · src/navigation/app_links.dart(rebalanceHistory · rebalanceEvent · rebalancePreview — 읽기만 · 쓰는 것은 rebalancePreview 하나) · testing.dart(UnimplementedRebalanceRepository — 세 메서드 모두 동기로 던진다 · UnimplementedSafetyRepository · RecordingLinkOpener) · packages/domain_contracts/test/contracts/support/r12_targets.dart(역할 표) · c42_r12_screen_scan_test.dart 머리(금지 정규식 ②~⑬)
 ⑤ packages/ui_analytics/test/golden/README.md «🆕 R12(계약 v1.6)» 절 전부 + «🆕 R10» 절의 «2»(높이와 위치 전제) + «규칙»·«하네스» 절
 ⑥ 지금 코드(packages/ui_analytics) — lib/ui_analytics.dart · lib/l10n/labels.dart · lib/src/providers/analytics_providers.dart 전문 · lib/src/screens/goal_path_screen.dart(R11b — 로딩·에러·배너 뼈대의 선례 · 틀만) · lib/src/screens/report_archive_screen.dart(sectionLabel 머리글 · Card + InkWell 행의 선례 — 틀만 · 클래스 주석과 상단 as-of 는 본뜨지 않는다) · lib/src/widgets/analytics_skeleton.dart · analytics_error_view.dart · stale_banner.dart · safety_block_banner.dart · test/explore_fakes.dart(FakeSafetyRepository — import 만) · test/goal_path_fakes.dart(가짜·띄우기 도우미 모양 — 틀만) · test/golden/golden_support.dart · test/golden/s79_golden_test.dart(루프 모양) · packages/ui_journal/lib/src/decision_detail.dart 의 _ThresholdTable(대조 표 행 모양 — 읽기만 · ui_journal 을 import 하지 않는다)
 ⑦ packages/domain_contracts/fixtures/README.md 의 «계약 v1.6» 절 + 이 카드가 쓰는 픽스처(아래 «픽스처») ⑧ docs/ai-context/inbox/README.md · S7-6ab_questions.md 머리말

■ 본받지 않는 것 (ui_analytics·ui_journal 의 기존 코드·문서에 남아 있는 옛 모양 — 고치지도 베끼지도 않는다)
 · 화면 3파일의 _buildSkeletonLoader·_buildErrorState 복붙 · Colors.grey · ElevatedButton 재시도 → AnalyticsSkeleton·AnalyticsErrorView(colorScheme · FilledButton — R10a · 이미 main)
 · contribution·drawdown_context·monthly_report 화면의 Card(elevation: 0.5) → Card() 기본 고도(규칙 9 · C-42 ⑥)
 · analytics_providers.dart 의 비-autoDispose family 3개 → R12a 결과 프로바이더 둘은 autoDispose
 · report_archive_screen.dart 의 클래스 주석(«Scaffold·AppBar 는 셸 소유 …»)과 맨 위 as-of 줄 → 주석에 Scaffold·AppBar·SafeArea 낱말 0 · R12 기준일은 하단(㉓)
 · ui_journal _ThresholdTable 의 행 Key j2-thr-$i 와 JournalLabels.thresholdCompare → 대조 표 행에는 Key 를 달지 않는다(Key 표 밖) · 머리 글자는 AnalyticsLabels 새 라벨 ·
   ui_journal import 0(C-3 — ui_analytics 의존은 domain_contracts·flutter·flutter_riverpod 뿐)
 · 테스트의 class … implements SafetyRepository · 한국어 테스트 이름 · «if (x != null) { expect… }» 조건부 단언 · 매 테스트 ProviderScope 통째 반복 →
   받침대 extends · 전제는 expect · 띄우기 도우미(pumpRebalance) 하나 · ASCII 이름
 · 03 §11-a·§11-b 위쪽 구 초안(«목표·현재·밴드 하한/상한·이탈 여부» 열 · 국면·신호 원값 · thresholdRegistered 나란히 · 주문 건수 · 유형 필터 · 「이 회차의 주문 N건」 고정 글자 · 상태 3종) → v1.6·v1.5 블록
 · ValueKey('bar_…') 모양의 Key → 새 Key 는 화면id-하이픈(s76a-… · s76b-…)

■ 주입 구조 (이름·타입 고정 — 01 §15-4-7 · §15-4-18 글자 그대로 · 계약 변경 없음)
· 재사용(이름·위치 불변): analyticsClockProvider · analyticsLinkOpenerProvider · safetyRepositoryProvider · safetyStateStreamProvider ·
  StaleBanner(asOf:) · SafetyBlockBanner(activeFlags:, onOpenLink:) · AnalyticsSkeleton() · AnalyticsErrorView(onRetry:, lastAsOfLabel:) · AnalyticsLabels.retryButton · staleBannerTitle.
· 🆕 프로바이더 셋 — lib/src/providers/analytics_providers.dart **끝**(R11b 절의 goalPathProvider 뒤 · 빈 줄 하나)에 이 모양으로 더한다(기존 줄 무변경):
    // ── 🆕 R12a — S7-6a·S7-6b ──
    /// S7-6a·S7-6b 리밸런싱 읽기 창구 — 조립 앱이 주입한다(01 §15-4)
    final Provider<RebalanceRepository> rebalanceRepositoryProvider =
        Provider<RebalanceRepository>((ref) {
          throw UnimplementedError('rebalanceRepositoryProvider must be overridden');
        });

    /// S7-6a 회차 타임라인 — 인자 없이 부른다(전체 기간 · 01 §15-4)
    final AutoDisposeStreamProvider<ListResult<RebalanceEvent>>
    rebalanceEventsProvider =
        StreamProvider.autoDispose<ListResult<RebalanceEvent>>((ref) {
          return ref.watch(rebalanceRepositoryProvider).watchEvents();
        });

    /// S7-6b 회차 1건 — 받은 id 그대로(01 §15-4)
    final AutoDisposeStreamProviderFamily<RebalanceEvent, String>
    rebalanceEventProvider = StreamProvider.autoDispose
        .family<RebalanceEvent, String>((ref, rebalanceEventId) {
          return ref
              .watch(rebalanceRepositoryProvider)
              .watchEvent(rebalanceEventId);
        });
  🔴 첫 줄(표식)은 글자 그대로 — «// ── 🆕 R12» 로 시작하는 첫 줄부터 파일 끝까지를 계약 테스트 C-42 ⑬ 이 «providers R12 절»로 잘라 본다(표식 위에 R12 이름을 두면 실패) ·
  🔴 이름·타입·인자 그대로(rebalanceRepositoryProvider · rebalanceEventsProvider · rebalanceEventProvider — R12b~d 가 이 이름을 import 만 한다) · 기본값 throw(주입 누락이 조용히 묻히지 않게) ·
  주석에 autoDispose 낱말 금지 · dart format 이 줄을 나눠도 된다(autoDispose 가 든 줄이 프로바이더마다 하나면 된다 — S15 = 기존 4 + 2 = 6).
· 🆕 lib 파일 2개(이 둘 말고 새 lib 파일을 만들지 않는다 — 행·묶음·패널은 그 화면 파일 안의 private 위젯·메서드로):
    lib/src/screens/rebalance_timeline_screen.dart   RebalanceTimelineScreen({super.key}) — 공개 · ConsumerWidget(생성자 = key 만 · 01 §15-4-7)
    lib/src/screens/rebalance_event_screen.dart      RebalanceEventScreen({super.key, required this.rebalanceEventId}) — 공개 · ConsumerStatefulWidget(State 에 bool _snapshotOpen = false 하나)
  두 파일의 import(directives_ordering — 이 순서):
    import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
    import '../../l10n/labels.dart'; → import '../providers/analytics_providers.dart';(🔴 show 없이 — 규칙 18) → import '../widgets/analytics_error_view.dart'; →
    import '../widgets/analytics_skeleton.dart'; → import '../widgets/safety_block_banner.dart'; → import '../widgets/stale_banner.dart';
· 배럴 lib/ui_analytics.dart 에 export 두 줄 — 🔴 자리 = export 'src/screens/performance_explore_screen.dart'; 줄과 export 'src/screens/report_archive_screen.dart'; 줄 **사이**,
  그 안에서 event 가 timeline 앞(끝에 두면 directives_ordering 린트 → analyze --fatal-infos 실패):
    export 'src/screens/performance_explore_screen.dart';
    export 'src/screens/rebalance_event_screen.dart';       ← 🆕 (4) 커밋
    export 'src/screens/rebalance_timeline_screen.dart';    ← 🆕 (3) 커밋
    export 'src/screens/report_archive_screen.dart';
  🔴 lib/src/rebalance/ 는 만들지도 export 하지도 않는다. 배럴 export 수는 이 카드 뒤 10(«정확히» 단언은 R12d 몫 — 이 카드 테스트는 «두 줄이 각 1회»만 본다).
· 이 카드는 lib/planner.dart · lib/src/planner/** 를 import 하지도 고치지도 않는다(C-35 ⑥ · C-42 ⑤ «package:ui_analytics/planner» 0).

■ 픽스처 (FixturePaths.… · 읽는 법은 golden_support.dart 의 listFixture / singleFixture / fixtureEnvelope · 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 S7-6a  listFixture(FixturePaths.rebalance6, RebalanceEvent.fromJson) — 6행 · 거래일 내림차순(엔진 = 시간 역순 · 2026-10-30 → 2026-04-03) · 6행 모두 LIVE(modeLabel·sectionLabel 없음) ·
          6행 모두 detailDeepLink 있음 · 봉투 asOf.label «자료 기준 …»(관측 시각 · K10 권고 선반영) · 첫 행 2026-10-30 은 봉투 as_of 뒤 날짜다(사실 · 01 §8 미결 84 · 고치지 않는다)
        listFixture(FixturePaths.m7M7RebalanceEmpty, …) — 0행 · emptyLabel 있음 · 봉투 asOf.label 이 rebalance_6 과 다르다
        listFixture(FixturePaths.m7M7RebalanceSim, …) — 2행 · 둘 다 modeLabel 있음 · sectionLabel 은 행0 에만 · 봉투 meta.mode 는 LIVE(SIM 은 행에만 — C-15)
 S7-6b  singleFixture(FixturePaths.m7M7RebalanceDetailBand, RebalanceEvent.fromJson) — thresholds 1(passed true) · quality 있음 · journalTimelineLink 있음
        singleFixture(FixturePaths.m7M7RebalanceDetailAdvisory, …) — band 의 거울(같은 회차 · journalTimelineLink.label 글자만 다르다 — advisory 갈래는 글자 안에서 끝난다)
        rebalance6Event(kSeasonalEventId) — rebalance_6 의 계절 회차 · thresholds 1 · quality 없음 · journalTimelineLink 없음(부재 표본)
        rebalance6Event(kMonthlyEventId) — rebalance_6 의 월간 정기 회차 · thresholds 0(0건 표본) · quality 없음 · journalTimelineLink 있음
 안전   SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]) — 0 정상(플래그 0) · 3 차단 2건(Icons.block 2 · R11b 병합본 실측) · 4 무결성 1건(clearDeepLink 1)
 🔴 픽스처끼리 이어 붙인 시나리오를 만들지 않는다. 픽스처를 복사해 고친 «내 픽스처» 금지. 모자라면 질문 파일에.
 🔴 detailDeepLink 가 null 인 행·passed 가 false 인 대조 행의 표본은 없다 — 그 갈래는 코드로 짓되(null = InkWell 부재 · false = Icons.remove) 테스트를 지어내지 않는다(DTO 를 짓지 않는다).

■ 화면 — S7-6a RebalanceTimelineScreen (01 §15-4-9 · 03 §11-a v1.6 블록 ①~⑦)
 build:
   final AsyncValue<ListResult<RebalanceEvent>> asyncValue = ref.watch(rebalanceEventsProvider);
   final List<BlockFlag> activeFlags = ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ?? const <BlockFlag>[];
   asyncValue.when(
     loading: () => ListView(padding: 16, children: [ AnalyticsSkeleton() ]),                                        ← 배너 없음
     error:   (error, stack) => ListView(padding: 16, children: [ AnalyticsErrorView(onRetry: () => ref.invalidate(rebalanceEventsProvider),
                                                                                    lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ]),   ← 배너 없음
     data:    (page) => 아래 배치)
 배치(값이 온 뒤 · 위 → 아래):
   Column(key: Key('s76a-root'))[
    1 StaleBanner(asOf: page.asOf)                                                  ← 스크롤 밖
    2 SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (link) { ref.read(analyticsLinkOpenerProvider).open(link); })   ← 스크롤 밖
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    3 (page.rows.isEmpty) 빈 상태 —
        3a (page.emptyLabel != null) Text(page.emptyLabel!)                         ← 봉투 문장 그대로(폴백 0 · Key 없음)
        3b TextButton(key: Key('s76a-empty-next'), onPressed: () { ref.read(analyticsLinkOpenerProvider).open(AppRoutes.rebalancePreview); },
                      child: Text(AnalyticsLabels.rebalanceNextPreviewButton))
    4 (page.rows 의 행마다 · 받은 순서) —
        4a (e.sectionLabel != null) Padding(top 8 · bottom 4 · Text(e.sectionLabel!, key: ValueKey<String>('s76a-section-${e.eventId}')))   ← 그 행 **위** 머리글(Card 밖)
        4b Card(key: ValueKey<String>('s76a-row-${e.eventId}'), clipBehavior: Clip.antiAlias,
                child: e.detailDeepLink != null ? InkWell(onTap: () { ref.read(analyticsLinkOpenerProvider).open(e.detailDeepLink!); }, child: 본문) : 본문)
           본문 = Padding(12 · Column(start)[
                    Wrap(spacing 8 · runSpacing 4 · crossAxisAlignment center)[
                      Text(e.tradeDate.yyyyMmDd) ,                                  ← 일자(그 문자열 그대로)
                      Chip(label: Text(e.kindLabel)) ,                              ← 유형 칩(탭 0 · 한 모양 · onPressed·onDeleted 없음)
                      (e.modeLabel != null) DecoratedBox(decoration: BoxDecoration(color: colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(4)),
                         child: Padding(horizontal 6 · vertical 2 · Text(e.modeLabel!, key: ValueKey<String>('s76a-mode-${e.eventId}'),
                                                                      style: TextStyle(color: colorScheme.onTertiaryContainer)))) ]   ← 「모의」 배지
                    SizedBox(height 4) ,
                    Text(e.trigger.summary) ])                                        ← 한 줄 요약(엔진 문장)
    5 SizedBox(height 8) · Text(page.asOf.label)                                    ← 하단 기준일(Key 없음 · 빈 상태에도 있다 · 맨 아래 = 골든 위치 전제의 기준)
   ]
 🔴 상태를 고르는 것은 규칙 7 의 S7-6a 목록뿐이다. rows 를 mode·kind·날짜로 거르거나 다시 정렬하지 않는다 · 앞 행과 비교해 머리글을 만들지 않는다(sectionLabel 이 말한다).
 🔴 행에 주문 건수·손익·비중·기간 글자 자리를 만들지 않는다 · 유형 칩을 kind 로 고르지 않는다(kindLabel 그대로) · 「모의」 배지를 mode 로 고르지 않는다(modeLabel null 여부).
 간격(SizedBox 높이)·글자 굵기·Card 모서리는 재량(질문 아님 · 배지 색·대조 표 아이콘은 재량 아님 — ⑤).

■ 화면 — S7-6b RebalanceEventScreen (01 §15-4-9 · 03 §11-b v1.5 블록 ⓐ~ⓙ + v1.6 블록 ①~⑧)
 build:
   final AsyncValue<RebalanceEvent> asyncValue = ref.watch(rebalanceEventProvider(widget.rebalanceEventId));
   final List<BlockFlag> activeFlags = (S7-6a 와 같다);
   asyncValue.when(
     loading: () => ListView(padding: 16, children: [ AnalyticsSkeleton() ]),                                        ← 배너 없음
     error:   (error, stack) => ListView(padding: 16, children: [ AnalyticsErrorView(onRetry: () => ref.invalidate(rebalanceEventProvider(widget.rebalanceEventId)),
                                                                                    lastAsOfLabel: asyncValue.valueOrNull?.asOf.label) ]),   ← 배너 없음 · 모르는 id 도 여기
     data:    (event) => 아래 배치)
 배치(값이 온 뒤 · 위 → 아래 · 지역 변수 final ExecutionQuality? quality = event.quality; final LinkAction? link = event.journalTimelineLink; 로 null 을 고른다):
   Column(key: Key('s76b-root'))[                                                   ← rebalanceEventId 는 프로바이더 키·호출 인자에만(🔴 표시 금지 · didUpdateWidget 0)
    1 StaleBanner(asOf: event.asOf)                                                 ← 스크롤 밖 · 기준 = 관측 시각(K10 권고 선반영)
    2 SafetyBlockBanner(activeFlags: activeFlags, onOpenLink: (String flagLink) { ref.read(analyticsLinkOpenerProvider).open(flagLink); })   ← 스크롤 밖
       ← 🔴 매개변수 이름은 flagLink(지역 변수 link 를 가리지 않게 — 배너 콜백은 BlockFlag.clearDeepLink 문자열 · 일지 버튼은 link.deepLink)
    ── 이하 Expanded(ListView(padding 16)[ … ]) ──
    3 머리 — Wrap(spacing 8 · runSpacing 4 · crossAxisAlignment center)[ Text(event.tradeDate.yyyyMmDd) , Chip(label: Text(event.kindLabel)) ]
    4 Column(key: Key('s76b-before'), start)[ Text(AnalyticsLabels.rebalanceBeforeHeader) , 행마다 Text(w.label)(event.before · 받은 순서 · POT·CASH 포함) ]
    5 Column(key: Key('s76b-after'), start)[ Text(AnalyticsLabels.rebalanceAfterHeader) , 행마다 Text(w.label)(event.after · 받은 순서) ]
    6 (event.thresholds.isNotEmpty) Column(key: Key('s76b-thresholds'), start)[ Text(AnalyticsLabels.rebalanceThresholdsHeader) ,
         행마다(받은 순서) Padding(vertical 2 · Row[ Expanded(Text(t.metricLabel)) , Expanded(Text(t.observedText)) , Expanded(Text(t.thresholdText)) ,
                                                     Expanded(Text(t.verdictLabel)) ,
                                                     t.passed ? Icon(Icons.check, size: 16) : Icon(Icons.remove, size: 16, color: colorScheme.onSurfaceVariant) ]) ]
       ← 🔴 접힘 밖(폰에서도 늘 보인다 · 03 v1.6 ③) · 여유폭 계산 0 · 행 Key 없음 · 0건 = 이 묶음 부재
    7 TextButton(key: Key('s76b-snapshot'), onPressed: () => setState(() => _snapshotOpen = !_snapshotOpen), child: Text(AnalyticsLabels.rebalanceSnapshotHeader))
      + (_snapshotOpen) Text(event.trigger.summary) · Text(event.trigger.configHash, maxLines: 1, overflow: TextOverflow.ellipsis)
       ← 당시 스냅샷 = 기본 접힘(폰) · 펼치면 요약 → configHash · 국면·rawValues·triggerPrice·thresholdRegistered 는 없다
    8 (quality != null) Card(key: Key('s76b-quality'))[ Padding(12 · Column(start)[ Text(AnalyticsLabels.rebalanceQualityHeader) , Text(quality.slippageText) ,
         Text(quality.assumedSlippageText) , Text(quality.unfilledRateText) , Text(quality.summary) ]) ]   ← null = 패널 부재(자리표시자 0)
    9 (link != null) TextButton(key: Key('s76b-link-journalTimelineLink'), onPressed: () { ref.read(analyticsLinkOpenerProvider).open(link.deepLink); }, child: Text(link.label))
       ← 글자·링크 모두 엔진(«이 회차의 주문 2건» · advisory «이 회차의 기록 2건») · null = 부재(비활성 아님)
   10 SizedBox(height 8) · Text(event.asOf.label, key: Key('s76b-asof'))            ← 하단 기준일 · 맨 아래(골든 위치 전제의 기준)
   ]
 🔴 01 §15-4-9 의 «kindLabel · trigger.summary — S7-6b 머리» 는 이 카드에서 «kindLabel = 머리(3) · summary = 당시 스냅샷 안(7)»으로 읽는다(03 v1.6 ② · 설계서 §6 규칙 21 — 요약을 두 번 그리지 않는다).
 🔴 상태를 고르는 것은 규칙 7 의 S7-6b 목록뿐이다. «재실행»·손익·승인 버튼 0 · 비중 차이·슬리피지 bp 화면 계산 0 · 트리거 문구 자작 0.
 간격·굵기·모서리는 재량(질문 아님 — 아이콘 두 모양은 재량 아님).

■ Key 표 (카드 확정 — 설계서 §6 규칙 17 글자 그대로 · 🔴 여기 없는 s76a-·s76b- Key 를 더하지 않는다)
   S7-6a 루트        Key('s76a-root')                                  값이 온 뒤의 Column
   S7-6a 행          ValueKey<String>('s76a-row-${e.eventId}')          행 Card(InkWell 은 그 안쪽)
   S7-6a 배지        ValueKey<String>('s76a-mode-${e.eventId}')         Text(e.modeLabel!) — 있을 때만
   S7-6a 머리글      ValueKey<String>('s76a-section-${e.eventId}')      Text(e.sectionLabel!) — 있을 때만(행 Card 밖 · 위)
   S7-6a 빈 상태     Key('s76a-empty-next')                             TextButton(«다음 예상») — rows 가 빌 때만
   S7-6b 루트        Key('s76b-root')                                  값이 온 뒤의 Column
   S7-6b 전·후       Key('s76b-before') · Key('s76b-after')             Column(머리 글자 + label 줄)
   S7-6b 대조        Key('s76b-thresholds')                            Column(머리 글자 + 행) — thresholds 가 비지 않을 때만
   S7-6b 스냅샷      Key('s76b-snapshot')                              TextButton(접기·펴기)
   S7-6b 품질        Key('s76b-quality')                               Card — quality 가 있을 때만
   S7-6b 일지 버튼   Key('s76b-link-journalTimelineLink')              TextButton(link.label) — 있을 때만(03·12 인용 글자 유지)
   S7-6b 기준일      Key('s76b-asof')                                  Text(event.asOf.label)

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M7] R12a (1) 정적 라벨») · 테스트는 그 단계 커밋에 함께
 (1) 정적 라벨 6개(labels.dart 끝 R12a 절 · 기존 화면·위젯 무변경 — 0단계의 시작 기준 N 이 그대로 통과).
 (2) 주입 — analytics_providers.dart 끝 R12a 절(프로바이더 셋 · 위 «주입 구조» 글자 그대로) + test/rebalance_fakes.dart(가짜·띄우기 도우미 · 테스트 0).
 (3) S7-6a — lib/src/screens/rebalance_timeline_screen.dart + 배럴 export 한 줄(timeline · 정렬 자리) + test/rebalance_timeline_view_test.dart(T76A-01~T76A-10).
     🔴 이 커밋의 T76A-10 경로 목록은 timeline 하나(src/screens/rebalance_timeline_screen.dart)뿐이다 — event 화면·export 는 (4) 에서 생기므로 (3) 에서 두 경로를 넣으면 실패한다.
 (4) S7-6b — lib/src/screens/rebalance_event_screen.dart + 배럴 export 한 줄(event · timeline 앞) + test/rebalance_event_view_test.dart(T76B-01~T76B-10)
     + T76A-10 경로 목록에 src/screens/rebalance_event_screen.dart 를 더한다(rebalance_timeline_view_test.dart 의 그 목록 한 줄 수정 = 이 (4) 커밋 · 이 카드가 만든 파일이라 «기존 테스트 수정» 아님 · ⓗ 줄 수 불변).
     🔴 이 커밋 전에 packages/ui_analytics 에서 git add . (커밋은 그다음 — git grep 은 add 하지 않은 새 파일을 보지 않는다 · 출력 없음 = 거짓 안심) 뒤 «정적 묶음» 39줄을
        한 번 미리 돌려 «정적 묶음» 절 괄호의 기대와 맞춘다(주석도 센다 — 규칙 17) · (6) 뒤에는 커밋을 더할 수 없으니(amend·rebase 금지) 여기서 고친다.
        🔴 S27 만 커밋끼리 비교(origin/main...HEAD)라 이 미리 돌림에서는 스테이징한 (4) 몫이 빠진다 — barrel 첫째 수 1 이 정상이고 S27 은 대조에서 뺀다(최종 실행에서만 본다 · 코드를 고치지 않는다).
 (5) 골든 12장 — test/golden/s76ab_golden_test.dart(아래 «골든»).
 (6) format:fix · 질문 파일(S7-6ab_questions.md — 골든 dy 측정 행 A1~A6 · 그 밖의 질문) · 커밋 «[M7] R12a (6) format · 질문».
     🔴 (6) 뒤에 다른 커밋을 더하지 않는다(format 수정도 (6) 커밋 안에 — 제출 단계의 melos.bat run format 이 0 changed 여야 한다 · 아니면 멈추고 채팅으로 · amend·rebase 금지).

■ 정적 라벨 — AnalyticsLabels 끝에(R11b 절 뒤 · 닫는 } 앞) 절 주석(// ── 🆕 R12a — S7-6a·S7-6b ──)과 함께 6개(이름·글자 고정):
   rebalanceNextPreviewButton = '다음 예상' · rebalanceBeforeHeader = '리밸런싱 전' · rebalanceAfterHeader = '리밸런싱 후' ·
   rebalanceThresholdsHeader = '임계 대조' · rebalanceSnapshotHeader = '당시 스냅샷' · rebalanceQualityHeader = '실행 품질'
   (retryButton · staleBannerTitle 은 이미 있다 — 고치지 않는다. R10b·R10c·R11a·R11b 의 라벨 절도 고치지 않는다.)
   🔴 만들지 않는 글자(엔진 몫): «모의» · «모의투자 회차» · 유형 이름(«월간 정기»·«밴드 이탈»·«계절 진입 게이트»·«월 납입 배분» 류) · «아직 리밸런싱 회차가 없습니다» ·
      «이 회차의 주문 N건» · «이 회차의 기록 N건» · «통과»·«발동»·«진입 게이트 통과» · «자료 기준» · «실측 슬리피지»·«가정치»·«미체결» · «이탈» · «건» · «%» · «bp» ·
      «D-» · «원» · «주문 초안» · «예정 없음» · 연도 · 날짜.
   🔴 라벨 글자에 숫자·금액을 넣지 않는다(C-38 ⑫ 가 labels.dart 도 본다). 더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적는다.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 표시는 정적 S29·S30 과 대조)
공통: ProviderScope 는 MaterialApp 위(띄우기 도우미) · 뷰포트 Size(390, 2400) + DPR 1.0 + addTearDown 2개 · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Stream ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨은 kGoldenNowUtc.add(const Duration(days: 3))) · 기대 글자는 픽스처에서 · 픽스처는 golden_support.dart 의 도우미로만 읽는다 ·
  값 단언 전 pump() 한 번 더(스트림·안전 스트림이 도착할 틈).
  🔴 경우가 여럿인 테스트(«…마다» — T76A-02·05·08·09 · T76B-02·03·04·06·07·09·10)는 for 로 testWidgets 를 경우마다 만든다
     (이름 = '<번호> <설명> <경우 이름>' · 예 'T76B-07 journal link only when present seasonal' · ⓡ·ⓗ 는 그 테스트 본문에 한 줄 — 파일 안 줄 수는 같다).
     pumpRebalance 는 한 테스트에서 한 번만 부른다(한 테스트 안에서 픽스처를 바꿔 다시 띄우지 않는다 — State(_snapshotOpen)·프로바이더 값이 남는다).
  import 순서(directives_ordering · dart: → package: → 상대 경로 · 묶음 안은 경로 알파벳 순 · 🔴 쓰지 않는 줄은 빼고 순서만 지킨다):
     view 테스트 = import 'dart:async'; → (timeline 만) import 'dart:io'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/src/widgets/analytics_error_view.dart'; → import 'package:ui_analytics/src/widgets/analytics_skeleton.dart'; → import 'package:ui_analytics/ui_analytics.dart'; → import 'golden/golden_support.dart'; → import 'rebalance_fakes.dart';
     골든 = import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:flutter_test/flutter_test.dart'; → import 'package:ui_analytics/ui_analytics.dart'; → import '../rebalance_fakes.dart'; → import 'golden_support.dart';
  🆕 test/rebalance_fakes.dart(새 파일 · 공개 이름 · 🔴 한국어 리터럴 0 · explore_fakes.dart 는 import 만):
    import 순서(9줄 · directives_ordering) = import 'dart:async'; → import 'package:domain_contracts/domain_contracts.dart'; → import 'package:domain_contracts/testing.dart'; →
       import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; → import 'package:flutter_test/flutter_test.dart'; →
       import 'package:ui_analytics/ui_analytics.dart'; → import 'explore_fakes.dart' show FakeSafetyRepository; → import 'golden/golden_support.dart';
       (FakeSafetyRepository(SafetyState state) — 위치 인자 하나 · R10b · 고치지 않는다)
    class FakeRebalanceRepository extends UnimplementedRebalanceRepository {
      FakeRebalanceRepository({ListResult<RebalanceEvent>? events, RebalanceEvent? event, Object? error, StreamController<ListResult<RebalanceEvent>>? eventsController, StreamController<RebalanceEvent>? eventController})
          ← 테스트가 쓰는 창구 하나에 대해 «값 · error · controller» 중 정확히 하나를 준다
      final List<DateRange?> watchEventsCalls = <DateRange?>[];   ← 받은 range 를 호출마다 더한다(인자 없이 부르면 null)
      final List<String> watchEventCalls = <String>[];            ← 받은 rebalanceEventId 를 호출마다 더한다
      watchEvents({DateRange? range}) = 기록 → eventsController 가 있으면 그 stream / error 가 있으면 Stream<ListResult<RebalanceEvent>>.error(error) / 아니면 Stream<…>.value(events!)
      watchEvent(String rebalanceEventId) = 기록 → eventController 가 있으면 그 stream / error 가 있으면 Stream<RebalanceEvent>.error(error) / 아니면 Stream<RebalanceEvent>.value(event!)
      (watchNext 는 override 하지 않는다 — 받침대가 던진다 · 화면이 부르면 테스트가 깨진다)
    }   (controller 는 로딩을 멈추는 테스트에서만 — 그 테스트는 addTearDown(() { unawaited(controller.close()); }) 를 둔다)
    const String kSeasonalEventId = 're_20261030_01';  const String kMonthlyEventId = 're_20260701_01';   ← rebalance_6 행을 고르는 id(표시 글자 아님)
    RebalanceEvent rebalance6Event(String eventId) => listFixture(FixturePaths.rebalance6, RebalanceEvent.fromJson).rows.firstWhere((RebalanceEvent e) => e.eventId == eventId);   ← 규칙 12 의 firstWhere 예외 하나
    List<Override> rebalanceOverrides({required FakeRebalanceRepository repo, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 오버라이드 4개(analyticsClockProvider · analyticsLinkOpenerProvider · rebalanceRepositoryProvider · safetyRepositoryProvider(FakeSafetyRepository(…))) · 기본값: 안전 = safetyStates 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 오프너 = 새 RecordingLinkOpener(링크를 단언하려면 opener: 로 넘긴다)
    Future<void> pumpRebalance(WidgetTester tester, {required FakeRebalanceRepository repo, required Widget screen, SafetyState? safetyState, Clock? clock, RecordingLinkOpener? opener})
        ← 390×2400 · DPR 1.0 · teardown 2 · ProviderScope(overrides: rebalanceOverrides(…)) → MaterialApp(home: Scaffold(body: screen)) · 끝에 pump() 1번 (screen = const RebalanceTimelineScreen() 또는 RebalanceEventScreen(rebalanceEventId: event.eventId) — id 는 픽스처의 eventId 를 넘긴다 · 리터럴 금지)
    골든은 pumpRebalance 를 쓰지 않는다 — pumpForGolden(tester, ProviderScope(overrides: rebalanceOverrides(repo: …), child: <화면>), brightness: b, logicalSize: kS76abGoldenSize).
  🔴 새 띄우기 도우미는 이 하나뿐(pumpRebalance) · 테스트 파일 안에서 pumpRebalance 를 감싸는 private 도우미(예 _pumpEvent)도 만들지 않는다 — 테스트 본문이 pumpRebalance 를 직접 부른다 ·
     테스트마다 ProviderScope 를 통째로 쓰지 않는다.
S7-6a — test/rebalance_timeline_view_test.dart (화면 = const RebalanceTimelineScreen())
 T76A-01 rebalance_6 · 안전 행 0 → ⓗ expect(repo.watchEventsCalls, hasLength(1)) · expect(repo.watchEventsCalls.single, isNull)(인자 없이 · 비평 #5) ·
        expect(repo.watchEventCalls, isEmpty) · Key s76a-root 1 · ⓡ.
 T76A-02 rebalance_6 · sim 마다: ⓗ expect(page.rows, hasLength(<6 · 2>)) → expect(find.byType(Card), findsNWidgets(page.rows.length)) · s76a-empty-next 0 ·
        행 i 마다 ValueKey<String>('s76a-row-${e.eventId}') 1 · i ≥ 1 이면 getTopLeft(행 i−1).dy lessThan getTopLeft(행 i).dy(받은 순서 그대로 · 엄격 증가 — 비평 #6) ·
        행 안 Text 글자 목록 == <String?>[e.tradeDate.yyyyMmDd, e.kindLabel, if (e.modeLabel != null) e.modeLabel, e.trigger.summary](순서까지 · C4b-14 — 배지 쪽은 T76A-05 가 따로 단언) · ⓡ.
 T76A-03 rebalance_6 · 오프너 → ⓗ expect(page.rows, hasLength(6)) → 행마다 전제 expect(e.detailDeepLink, isNotNull) → 그 행 Key 탭 → pump →
        루프 뒤 expect(opener.opened, <String>[행마다 e.detailDeepLink!])(받은 순서 그대로) · ⓡ.
 T76A-04 m7_rebalance_empty · 오프너 → 전제 expect(page.rows, isEmpty) · expect(page.emptyLabel, isNotNull) → find.text(page.emptyLabel!) 1 · Key s76a-empty-next 1 ·
        그 버튼 안 Text 글자 == AnalyticsLabels.rebalanceNextPreviewButton · find.byType(Card) 0 ·
        사슬 find.text(page.emptyLabel!) → s76a-empty-next → find.text(page.asOf.label)(getTopLeft · lessThan · 이웃끼리) ·
        s76a-empty-next 탭 → pump → expect(opener.opened, <String>[AppRoutes.rebalancePreview]) · ⓡ.
 T76A-05 rebalance_6 · sim 마다: ⓗ expect(page.rows, hasLength(<6 · 2>)) → 행마다 —
        modeLabel 이 있으면 ValueKey('s76a-mode-<id>') 1 · tester.widget<Text>(…).data == e.modeLabel · 그 Text 의 style.color == colorScheme.onTertiaryContainer ·
          가장 가까운 조상 DecoratedBox(find.ancestor(…, matching: find.byType(DecoratedBox)).first)의 (decoration as BoxDecoration).color == colorScheme.tertiaryContainer
          (colorScheme = Theme.of(tester.element(그 Key)).colorScheme · C4b-13 준용) / 없으면 그 Key 0(양쪽 다) ·
        sectionLabel 이 있으면 ValueKey('s76a-section-<id>') 1 · data == e.sectionLabel · getTopLeft(머리글).dy lessThan getTopLeft(그 행 Key).dy / 없으면 그 Key 0(양쪽 다) ·
        끝에 배지 Key 수(find.byWidgetPredicate — Key 의 값이 's76a-mode-' 로 시작) == modeLabel 이 있는 행 수(테스트 쪽에서 픽스처로 셈 · rebalance_6 = 0 · sim = 2) · ⓡ.
 T76A-06 로딩 — eventsController(값 0 · teardown close) · 안전 행 3 → AnalyticsSkeleton 1 · find.byType(CircularProgressIndicator) 0 · find.byType(LinearProgressIndicator) 0 ·
        s76a-root 0 · 그 플래그 label 글자 각 0(🔴 로딩에는 배너 없음 — 규칙 8) · ⓡ.
 T76A-07 에러 — error 가짜 · 안전 행 3 → retryButton 1 · tester.widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView)).lastAsOfLabel == null ·
        그 플래그 label 글자 각 0 · s76a-root 0 → retryButton 탭 → pump → ⓗ expect(repo.watchEventsCalls, hasLength(2)) · 두 기록 모두 null.
 T76A-08 rebalance_6 — 세 경우(정상 시계 · 안전 행 0) · (+3일 · 행 3) · (정상 · 행 4)마다: ⓗ expect(activeFlags, hasLength(<0 · 2 · 1>)) →
        오래됐으면 find.text(AnalyticsLabels.staleBannerTitle) 1 + expect(find.ancestor(of: 그 글자, matching: find.byType(Scrollable)), findsNothing) / 아니면 그 글자 0(양쪽 다) ·
        플래그마다 그 label 글자 1 + 조상 Scrollable findsNothing(C4b-12) · find.byIcon(Icons.block) — 플래그 0 이면 findsNothing / 있으면 findsNWidgets(<행 3 = 2 · 행 4 = 1>)(양쪽 다) ·
        탭 — 행 4 만 find.byIcon(Icons.chevron_right) 탭 → pump → opener.opened == <String>[행 4 의 activeFlags.single.clearDeepLink!] / 행 0·3 은 탭하지 않고 expect(opener.opened, isEmpty)(양쪽 다 ·
          🔵 이 isEmpty 는 «늘 참인 단언»이 아니다 — 화면·배너가 build 중에 링크를 저절로 열지 않는다는 대조 단언(카드가 정함 · 규칙 12 반려 사유 아님)) ·
        find.text(page.asOf.label) 1 · getTopLeft(끝 행 s76a-row-<rows.last.eventId>).dy lessThan getTopLeft(find.text(page.asOf.label)).dy(기준일 = 하단) · ⓡ.
 T76A-09 rebalance_6 · sim 마다: 화면의 Text 위젯 data 전부(tester.widgetList<Text>(find.byType(Text)))가 «허용 글자 집합» 안에 있다 —
        집합 = 행마다 { tradeDate.yyyyMmDd · kindLabel · trigger.summary · modeLabel(있으면) · sectionLabel(있으면) } + page.asOf.label(화면이 지은 글자 = 0) ·
        행마다 find.text(e.eventId) 0(🔴 eventId 표시 금지) · ⓡ.
 T76A-10 배럴 — File('lib/ui_analytics.dart') 의 export 경로 목록(RegExp(r"^export '([^']+)';", multiLine: true))에서
        두 경로(src/screens/rebalance_event_screen.dart · src/screens/rebalance_timeline_screen.dart — (3) 커밋에서는 timeline 하나 · event 는 (4) 커밋에서 더한다 · «할 일» (3)·(4))마다 ⓗ expect(exports.where((String e) => e == path), hasLength(1)) ·
        exports.where((String e) => e.startsWith('src/rebalance/')) isEmpty(🔵 «정확히 N» 은 R12d 몫 — 이 카드는 «두 줄이 각 1회»만 본다 · T79-14·G13 은 고치지 않는다).
 (T76A 에 없는 번호는 없다 — 01~10.)
 ⓡ 기대 = rebalance_timeline_view_test.dart 8줄(T76A-01·02·03·04·05·06·08·09) · ⓗ 기대 = 7줄(T76A-01·02·03·05·07·08·10) — 🔴 정확히 이 수(규칙 12 · 드라이런 실측 8·7 과 같다).
S7-6b — test/rebalance_event_view_test.dart (화면 = RebalanceEventScreen(rebalanceEventId: event.eventId))
 T76B-01 detail_band · 안전 행 0 → ⓗ expect(repo.watchEventCalls, hasLength(1)) · expect(repo.watchEventCalls.single, band.eventId) ·
        expect(repo.watchEventsCalls, isEmpty)(🔴 목록을 id 로 고르지 않는다) · Key s76b-root 1 · find.text(band.eventId) 0 · ⓡ.
 T76B-02 배치 사슬 — 세 경우(detail_band · 정상 시계 · 안전 행 0) · (seasonal · +3일 · 행 4) · (monthly · 정상 · 행 3)마다:
        위 → 아래 Finder 목록을 만들고(있는 것만 넣는다) 이웃끼리 tester.getTopLeft(…).dy 를 lessThan 으로 잇는다(각 Finder 는 findsOneWidget 도):
        [오래됐으면 find.text(AnalyticsLabels.staleBannerTitle)] → [플래그가 있으면 find.text(activeFlags.first.label)] → find.text(e.kindLabel) →
        s76b-before → s76b-after → [thresholds 가 비지 않으면 s76b-thresholds] → s76b-snapshot → [quality 가 있으면 s76b-quality] →
        [journalTimelineLink 가 있으면 s76b-link-journalTimelineLink] → s76b-asof · 일자는 칩과 같은 줄(Wrap)이라 사슬에 넣지 않고 따로
        find.text(e.tradeDate.yyyyMmDd) 1 + getTopLeft(일자).dy lessThan getTopLeft(s76b-before).dy 로 본다(같은 줄끼리 lessThan 금지 — 늘 실패).
        없는 쪽은 따로 단언한다(if/else 양쪽 — staleBannerTitle 0 · find.byIcon(Icons.block) 0 · s76b-thresholds 0 · s76b-quality 0 · s76b-link-journalTimelineLink 0) ·
        있는 쪽의 차단 아이콘 수 = find.byIcon(Icons.block) findsNWidgets(<seasonal 행 4 = 1 · monthly 행 3 = 2>) ·
        세 경우가 양쪽을 한 번 이상씩 지난다 · tester.widget<Text>(find.byKey(const Key('s76b-asof'))).data == e.asOf.label(C4b-14) · ⓡ.
 T76B-03 detail_band · seasonal 마다: s76b-before 안 Text 글자 목록 == [AnalyticsLabels.rebalanceBeforeHeader, …e.before 의 label](받은 순서 · 거르기 0) ·
        s76b-after 안 == [AnalyticsLabels.rebalanceAfterHeader, …e.after 의 label] · ⓡ.
 T76B-04 detail_band · seasonal · monthly 마다: thresholds 가 비지 않으면 —
        s76b-thresholds 1 · 그 안 Text 글자 목록 == [AnalyticsLabels.rebalanceThresholdsHeader, 행마다 metricLabel · observedText · thresholdText · verdictLabel](순서까지 — 행 i 글자 == thresholds[i]) ·
        그 안 find.byType(Icon) == findsNWidgets(e.thresholds.length)(행 수 == 길이) · Icons.check 수 == passed 가 true 인 행 수 · Icons.remove 수 == false 인 행 수(테스트 쪽에서 셈) /
        비면(monthly — 전제 expect(e.thresholds, isEmpty)) s76b-thresholds 0(양쪽 다) · ⓡ.
 T76B-05 detail_band → 처음: s76b-snapshot 1 · 그 안 Text 글자 == AnalyticsLabels.rebalanceSnapshotHeader · find.text(e.trigger.summary) 0 · find.text(e.trigger.configHash) 0 ·
        s76b-thresholds 1(🔴 대조 표는 접힘 밖) → s76b-snapshot 탭 → pump → summary 1 · configHash 1 ·
        사슬 s76b-snapshot → find.text(summary) → find.text(configHash) → s76b-quality(lessThan · 이웃끼리) → 다시 탭 → pump → summary 0 · ⓡ.
 T76B-06 detail_band · seasonal 마다: quality 가 있으면 s76b-quality 1 · 그 안 Text 글자 목록 ==
        [AnalyticsLabels.rebalanceQualityHeader, slippageText, assumedSlippageText, unfilledRateText, summary] / 없으면 s76b-quality 0(양쪽 다) · ⓡ.
 T76B-07 detail_band · detail_advisory · seasonal 마다(오프너): journalTimelineLink 가 있으면 s76b-link-journalTimelineLink 1 · 그 안 Text 글자 == link.label ·
        탭 → pump → expect(opener.opened, <String>[link.deepLink]) / 없으면 그 Key 0 · expect(opener.opened, isEmpty)(양쪽 다) · ⓡ.
 T76B-08a 로딩 — eventController(값 0 · teardown close) · 안전 행 3 → AnalyticsSkeleton 1 · CircularProgressIndicator 0 · LinearProgressIndicator 0 · s76b-root 0 ·
        그 플래그 label 글자 각 0 · ⓡ.
 T76B-08b 에러 — error 가짜 · 안전 행 3 · id = band.eventId → retryButton 1 · lastAsOfLabel == null · 그 플래그 label 글자 각 0 · s76b-root 0 →
        retryButton 탭 → pump → ⓗ expect(repo.watchEventCalls, hasLength(2)) · 두 기록 모두 band.eventId.
 T76B-09 detail_band — 세 경우(정상 · 행 0) · (+3일 · 행 3) · (정상 · 행 4)마다: ⓗ expect(activeFlags, hasLength(<0 · 2 · 1>)) → T76A-08 의 괄호 안 단언만
        (staleBannerTitle 1 + 조상 Scrollable 0 / 0 · 플래그 label 1 + 조상 Scrollable 0 · Icons.block 수 · 행 4 만 chevron_right 탭 → opened == [clearDeepLink] / 아니면 opened 빈 목록 — 양쪽 다) ·
        양성 기준점 = Key s76b-asof findsOneWidget(🔴 T76A-08 의 «끝 행 dy < 하단 기준일 dy» 는 넣지 않는다 — S7-6b 에는 끝 행이 없고 하단 위치는 T76B-02 사슬이 증명) · ⓡ.
 T76B-10 detail_band · seasonal · detail_advisory 마다: s76b-snapshot 을 한 번 탭해 편 채로 화면의 Text 위젯 data 전부가 «허용 글자 집합» 안에 있다 —
        집합 = { tradeDate.yyyyMmDd · kindLabel · before·after 의 label · thresholds 의 metricLabel·observedText·thresholdText·verdictLabel · trigger.summary · trigger.configHash ·
                 quality 의 네 글자(있으면) · journalTimelineLink.label(있으면) · asOf.label } + 정적 라벨 5개(rebalanceBeforeHeader · AfterHeader · ThresholdsHeader · SnapshotHeader · QualityHeader) ·
        find.text(e.eventId) 0 · ⓡ.
 (T76B 에 없는 번호는 없다 — 01~10 · 08 만 a·b 두 개.)
 ⓡ 기대 = rebalance_event_view_test.dart 10줄(T76B-01·02·03·04·05·06·07·08a·09·10) · ⓗ 기대 = 3줄(T76B-01·08b·09) — 🔴 정확히 이 수(규칙 12 · 드라이런 실측 10·3 과 같다).
테스트 수(최소 목록의 경우 수 그대로): timeline 15(01 1 · 02 2 · 03 1 · 04 1 · 05 2 · 06 1 · 07 1 · 08 3 · 09 2 · 10 1) · event 23(01 1 · 02 3 · 03 2 · 04 3 · 05 1 · 06 2 · 07 3 · 08a 1 · 08b 1 · 09 3 · 10 3) ·
  골든 12 = 새 50(드라이런 실측 15 · 23 · 12 = 50 과 같다 — 끝 수는 «테스트 수 묶음» 출력 그대로).
🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려 — 보고 규칙 ③):
   S7-6a: 행 순서 뒤집기(rows.reversed · ListView(reverse: true)) · 일자 재포맷(요일 붙이기 · 점 구분) · 유형 칩 글자를 kind 로 고른 정적 글자 · 「모의」 배지를 모든 행에 ·
     배지 색 맞바꿈(tertiary ↔ secondary) · 머리글을 모든 SIM 행에 · 머리글을 행 아래로 · 행 탭이 다른 링크를 엶 · 빈 상태 문구 자작 · 빈 상태 버튼이 다른 상수를 엶 ·
     기준일을 맨 위로 · watchEvents 에 범위를 넘김 · eventId 를 글자로 그림 ·
   S7-6b: watchEvents 로 행을 고름 · 전·후 묶음 순서 맞바꿈 · before 의 한 줄 빼기(POT·CASH 거르기) · 대조 표를 스냅샷 접힘 안으로 · 0건인데 빈 대조 표 ·
     passed 아이콘 뒤집기 · 스냅샷 기본 펼침 · 요약을 머리에도 그림 · quality null 에 빈 패널 · 일지 버튼 null 에 비활성 버튼 · 일지 버튼이 다른 링크를 엶 · 기준일을 머리로 ·
   공통: 로딩·에러에 차단 배너 · 배너를 ListView 안으로(C4b-12) · 에러를 스켈레톤으로 · 로딩에 스피너 · 화면이 지은 글자 하나(예 정적 «리밸런싱 회차»).

■ 정적 묶음 — packages/ui_analytics 에서 아래 39줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (줄을 고르거나 · 줄이거나 · 설명으로 바꾸지 않는다 · 통합 담당이 같은 39줄을 돌려 글자로 대조한다 — 다르면 반려 · EXIT 표기(1/0 ↔ False/True)와 warning:·error: 로 시작하는 줄은 셸에 따라 있거나 없다 — 대조에서 뺀다).
  «EXIT:1» 또는 «EXIT:False» = 출력 없음(0건) · 셸에 따라 둘 중 하나로 찍힌다(둘 다 정상).
  Windows PowerShell 5.1 이면 git 의 stderr 경고에 장식 줄(«git : warning: …» · «At line:…» · «+ CategoryInfo …» · «+ FullyQualifiedErrorId : NativeCommandError» · «+ … ~~~» 류)이 덧붙는다 — 지우지 않고 그대로 붙이고, 대조에서는 warning: 줄과 함께 뺀다.
  S17·S18·S18b 만 git diff 라 반대다 — 차이 0 = «… file(s) changed» 요약 줄이 없음(🔴 EXIT 값은 보지 않는다 · «warning: … LF will be replaced by CRLF» 줄은 차이가 아니다 — 나오면 지우지 않고 그대로 붙인다).
  S31 만 dart test 다(domain_contracts 폴더에서 C-42 한 파일 · 1분 안팎) — 출력 전부를 그대로 붙인다.
  🔴 블록 뒤에 S05a·S05b 결과 줄마다 한 줄씩 정확히 «<파일>:<줄> — 탭 콜백 안» 만 사람이 적는다(괄호·이름·설명 금지 — 위 보고 규칙).
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/rebalance_fakes.dart test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart test/golden/s76ab_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart test/golden/s76ab_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart test/golden/s76ab_golden_test.dart; echo "EXIT:$?"
echo "## S03 string processing 0 (S7-6 files)"; git grep -nP "\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S03b sort filter words 0 (S7-6 files)"; git grep -nP "\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b|\breverse:\s*true\b" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S04 AppRoutes (S7-6a empty-state constant only)"; git grep -n "AppRoutes\." -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart lib/src/providers/analytics_providers.dart; echo "EXIT:$?"
echo "## S05a opener lines timeline (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/rebalance_timeline_screen.dart; echo "EXIT:$?"
echo "## S05b opener lines event (each must be inside a tap callback)"; git grep -n "analyticsLinkOpenerProvider" -- lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S06 CommandState CommandApi 0 (S7-6 files)"; git grep -nE "CommandState|CommandApi" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S07 Navigator 0"; git grep -n "Navigator" -- lib; echo "EXIT:$?"
echo "## S08 DateTime.now 0"; git grep -n "DateTime.now" -- lib; echo "EXIT:$?"
echo "## S09 kIsWeb Platform. 0"; git grep -nE "kIsWeb|Platform\." -- lib; echo "EXIT:$?"
echo "## S10 aaq literal 0"; git grep -n "'aaq://" -- lib; echo "EXIT:$?"
echo "## S11 toStringAsFixed 0"; git grep -n "toStringAsFixed" -- lib; echo "EXIT:$?"
echo "## S12 GestureDetector 0"; git grep -n "GestureDetector" -- lib; echo "EXIT:$?"
echo "## S13 Colors files (old 4 only)"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## S14 DateRange DateTime TradeDate 0 (S7-6 files)"; git grep -nE "DateRange|DateTime|TradeDate" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S14b mode axes 0 (S7-6 files)"; git grep -nE "operatingMode|OperatingMode|RunMode|runMode|FeatureFlags" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S15 autoDispose 6"; git grep -n "autoDispose" -- lib/src/providers; echo "EXIT:$?"
echo "## S16 barrel internal folders 0"; git grep -nE "rebalance/|goal_path/|chart/|explore/|planner|perf_chart|analytics_skeleton|analytics_error_view" -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S16b barrel exports 10"; git grep -n "^export " -- lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S17 chart diff 0 (a)"; git diff --no-index --stat test/golden/reference/chart lib/src/chart; echo "EXIT:$?"
echo "## S18 chart diff 0 (b)"; git diff --no-index --stat test/golden/reference/widgets/perf_chart.dart lib/src/widgets/perf_chart.dart; echo "EXIT:$?"
echo "## S18b goal path chart diff 0"; git diff --no-index --stat test/golden/reference/goal_path lib/src/goal_path; echo "EXIT:$?"
echo "## S19 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_analytics/)" -- lib; echo "EXIT:$?"
echo "## S20 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S21 item11 number literals 0"; git grep -nE "\b(10\.(2|4|63|85|91|96)|11\.13|12\.(6|70)|8\.38|35\.05)\b" -- lib; echo "EXIT:$?"
echo "## S22 rates and figures 0 (C-38 12)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S23 amounts 0 (C-38 12)"; git grep -nP "(?<![0-9,])(100|90|97|124)[_,]?000(?![0-9]|[_,][0-9])|(?<![0-9.])(10|9|9\.7|12\.4)\s*\x{B9CC}|(?<![0-9.,])[0-9]{1,3}(,[0-9]{3})+\s*\x{B9CC}|[0-9,]+\x{B9CC}\s*\x{C6D0}|[0-9]+\x{C5B5}" -- lib; echo "EXIT:$?"
echo "## S24 retired and old-draft names 0"; git grep -nE "rejectReasonCode|seriesCode|GoalPathPoint|ReviewSectionVm|changeWindowNoticeText|oathText|AsOfStamp|KeyValueVm" -- lib; echo "EXIT:$?"
echo "## S25 raw fields 0 (S7-6 files)"; git grep -nP "(?<!Labels)\.(weight|targetWeight|bandLow|bandHigh|rawValues|thresholdRegistered|triggerPrice|metricKey|orderIntentIds|mode|kind|hasMore|emptyKind|code|wire|sleeve|basis)\b|\.tradeDate\b(?!\.yyyyMmDd)|SleeveId\." -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S25b journalTimelineLink 0 (S7-6a file)"; git grep -n "journalTimelineLink" -- lib/src/screens/rebalance_timeline_screen.dart; echo "EXIT:$?"
echo "## S25c detailDeepLink 0 (S7-6b file)"; git grep -n "detailDeepLink" -- lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S26 Scaffold AppBar SafeArea 0 (S7-6 files)"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/screens/rebalance_timeline_screen.dart lib/src/screens/rebalance_event_screen.dart; echo "EXIT:$?"
echo "## S27 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/src/providers/analytics_providers.dart lib/ui_analytics.dart; echo "EXIT:$?"
echo "## S28 keys (empty-next journal-link asof)"; git grep -n -e "s76a-empty-next" -e "s76b-link-journalTimelineLink" -e "s76b-asof" -- lib; echo "EXIT:$?"
echo "## S29 R lines (retryButton findsNothing)"; git grep -c "retryButton), findsNothing" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart; echo "EXIT:$?"
echo "## S30 H lines (hasLength)"; git grep -c "hasLength(" -- test/rebalance_timeline_view_test.dart test/rebalance_event_view_test.dart; echo "EXIT:$?"
echo "## S31 C-42 role scan (domain_contracts)"; cd ../domain_contracts; dart test test/contracts/c42_r12_screen_scan_test.dart -r expanded; echo "EXIT:$?"; cd ../ui_analytics
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = 테스트 이름은 ASCII 만(«—»·«→» 도 금지) · S03·S03b = 문자열 가공·정렬·거르기 0(C-42 ⑨ 와 같은 낱말 · 주석도 센다) ·
   S04 = rebalance_timeline_screen.dart 의 AppRoutes.rebalancePreview 한 줄뿐(R12 화면의 고정 상수 = 이것 하나) · S05a = 3줄(행 InkWell onTap · s76a-empty-next onPressed · SafetyBlockBanner onOpenLink — 드라이런 62 · 78 · 162 · 줄 번호는 코드마다 다르다 · dart format 이 s76a-empty-next 콜백을 «ref» / «.read(analyticsLinkOpenerProvider)» / «.open(AppRoutes.rebalancePreview);» 로 나누면 그 줄은 «.read(analyticsLinkOpenerProvider)» 로 시작하는 줄로 찍힌다 — 정상(그 줄도 «— 탭 콜백 안» · S04 줄도 그 아래 «.open(…)» 줄로 찍힌다)) · S05b = 2줄(s76b-link-journalTimelineLink onPressed · SafetyBlockBanner onOpenLink — 드라이런 76 · 197) ·
   S05a·S05b 모두 build 본문에서 읽는 줄 0(오프너는 탭 콜백 안에서 읽고 바로 open) · S06~S12 = 출력 없음 · S13 = 기존 4파일(contribution_screen · drawdown_context_screen · monthly_report_screen · trust_badge_view)뿐 · 새 파일 0 ·
   S14·S14b = 두 화면 파일에 날짜 타입·모드 축 낱말 0(일자는 tradeDate.yyyyMmDd — 소문자 t 라 걸리지 않는다) · S15 = 대소문자 구분 · 6줄(기존 4 + rebalanceEventsProvider 1 + rebalanceEventProvider 1 · 드라이런 63 · 78 · 91 · 105 · 121 · 127) · 🔴 주석도 센다 ·
   S16 = 내부 폴더 export 0 · S16b = export 10줄(rebalance_event_screen · rebalance_timeline_screen 은 performance_explore_screen 과 report_archive_screen 사이) · S17·S18·S18b = 옮긴 차트 파일 무변경 · S19~S23 = 출력 없음(12항 1·3·11항 근거 · S22·S23 = 계약 테스트 C-38 ⑫ 와 같은 정규식) ·
   S24 = 폐기·구 초안 이름 0 · S25 = C-42 ② 와 같은 원값 정규식(+ basis · SleeveId.) — 출력 0 · S25b·S25c = 링크 필드는 제 화면에서만 · S26 = 공개 위젯은 본문만(ScaffoldMessenger 포함) · S27 = 공용 파일의 «더하기만» — 세 줄 모두 둘째 수(삭제)가 0 · 첫째 수 = 드라이런 labels 8 · providers 25(주석·format 에 따라 다를 수 있다 — 기준은 둘째 수 0) · barrel 2(정확히) ·
   S28 = 3줄(Key 세 개가 각 한 번) · S29·S30 = 위 «테스트 최소 목록» 의 ⓡ·ⓗ 기대 줄 수와 파일마다 정확히 같아야 한다 (S29 = rebalance_event_view_test.dart:10 · rebalance_timeline_view_test.dart:8 / S30 = :3 · :7 · 다르면 반려 — 규칙 12) ·
   S31 = 전부 통과 + 출력에 «C-42 ① 대상 S7-6a(R12a) 1파일» · «C-42 ① 대상 S7-6b(R12a) 1파일» · S7-6c·S7-7·S7-10 은 0파일 · «역할 대상 합 2파일 · providers R12 절 <N>줄»(드라이런 24 — 주석 줄 수에 따라 다를 수 있다))

■ 테스트 수 묶음 — packages/ui_analytics 에서 네 줄(PR 본문의 «시작 N → 끝 M» 과 테스트별 수 · «까닭» 은 이 출력의 끝 줄 그대로 — 손으로 세지 않는다)
  flutter test test/rebalance_timeline_view_test.dart   ← 끝 줄 «+15: All tests passed!» 기대(드라이런 +15)
  flutter test test/rebalance_event_view_test.dart      ← «+23: All tests passed!» 기대(드라이런 +23)
  flutter test test/golden/s76ab_golden_test.dart       ← «+12: All tests passed!» 기대
  flutter test                                          ← 끝 줄 = «끝 M»(기대 M = N + 50)

■ 골든 — 6이름 × light/dark = 12장(전부 신규 · golden README «🆕 R12(계약 v1.6)» 절 표의 R12a 행 그대로 · 설계서 §3-5)
  s76a_list(rebalance_6.json · 6행 내림차순 · 화면 전체) · s76a_empty(m7/m7_rebalance_empty.json · 빈 문장 + «다음 예상» 버튼) · s76a_sim(m7/m7_rebalance_sim.json · 머리글 1 + 배지 2) · s76b_band(m7/m7_rebalance_detail_band.json · 전·후 · 대조 표 1행 · 품질 패널 · 하단 버튼) ·
  s76b_seasonal(rebalance_6.json 의 re_20261030_01 — rebalance6Event(kSeasonalEventId) · 대조 표 1행 · 품질 패널 부재 · 하단 버튼 부재) · s76b_advisory(m7/m7_rebalance_detail_advisory.json · band 와 버튼 글자만 다름)
  모두 스냅샷 접힌 채 · 안전 상태 = 행 0 · 시계 = FixedClock(kGoldenNowUtc) · 크기 390 × 960(테스트 파일 안 상수 const Size kS76abGoldenSize = Size(390, 960); — 기본 폰 높이 844 로는 모자란다 · 드라이런 실측 맨 아래 dy = s76a_list 848 · s76a_empty 120 · s76a_sim 324 · s76b_band 892 · s76b_seasonal 692 · s76b_advisory 892(light·dark 같음 · 높이 960) · kGoldenPhoneSize 는 고치지 않는다 · dy 가 이와 다르면 PR 본문에 까닭).
  모양 = s79_golden_test.dart 처럼 (이름, 입력) 목록 × Brightness.values 루프 두 개(S7-6a 세 이름 = (이름, FixturePaths 경로) · S7-6b 세 이름 = (이름, RebalanceEvent)) · 테스트 이름 '$name ${brightnessSuffix(b)}' · 골든은 '../rebalance_fakes.dart' 로 import.
  pumpForGolden 뒤 await tester.pumpAndSettle()(값이 오게) → 찍기 전 위치 전제(golden README «R10» 절 «2. 높이와 위치 전제») — 루프마다 한 곳:
    S7-6a: expect(tester.getBottomLeft(find.text(page.asOf.label)).dy, lessThan(kS76abGoldenSize.height));        ← 맨 아래 = 하단 기준일
    S7-6b: expect(tester.getBottomLeft(find.byKey(const Key('s76b-asof'))).dy, lessThan(kS76abGoldenSize.height)); ← 맨 아래 = s76b-asof
  → await expectGolden(name, b);
  packages/ui_analytics 에서:
    flutter test --update-goldens test/golden/s76ab_golden_test.dart
    flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 12장만 ??
  🔴 다른 골든 테스트 파일을 --update-goldens 에 넣지 않는다(영영 아님).
  위치 전제가 실패하면(본문이 높이를 넘으면 · 맨 아래 글자가 화면 밖이라 찾지 못해도) 높이를 늘리지 말고 멈춘 뒤 실제 dy 값(못 찾았으면 실패 문구)을 질문 파일에 적는다.
  위치 전제의 dy 는 골든 이름·밝기마다 직접 잰다(한 값을 여러 행에 복사하지 않는다 — R10b 1회차 반려 사유):
    s76ab_golden_test.dart 의 위치 전제 lessThan(kS76abGoldenSize.height) 두 곳을 잠시 lessThan(0) 으로 바꾸고 → flutter test test/golden/s76ab_golden_test.dart(--update-goldens 없이)
    → 테스트 이름('s76a_list light' … 12개)마다 실패 문구의 «Actual: <숫자>» 를 적는다(헷갈리면 --plain-name 으로 한 이름씩) → 되돌린다(git diff -- test/golden/s76ab_golden_test.dart 로 확인).
    🔴 이 lessThan(0) 임시 수정은 커밋하지 않는다(위치 전제가 expectGolden 보다 먼저라 실패해도 PNG 는 쓰이지 않는다).
  입력 없는 골든 s76b_missing_snapshot 은 만들지 않는다(실을 필드가 없다 — 01 §8 미결 87 · golden README «R12» 절에 기록돼 있다).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · K21 = 카드마다 1개)
· S7-6ab_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다. 🔴 S7-6c·S7-7·S7-10 질문 파일에는 쓰지 않는다(뒤 카드 몫 · 이 카드의 질문도 여기에만).
· 표 끝에 새 행만 더한다(머리말은 고치지 않는다) · 질문 = Q · 추측 = A · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
· 꼭 적을 것: 골든 위치 전제의 실제 dy — 이름마다 한 행(A1~A6 · 형식은 아래 · 종류 칸은 «추측» 그대로 · «질문·추측» 칸 첫머리 «측정:» — ⑤ «추측한 것» 에는 세지 않는다 · C4 가 재실측해 ✅ 로 닫는다) ·
  권고와 다르게 지은 이름 · 6개 밖에 새로 더한 정적 라벨 · 문서에 없어 정한 것 전부.
    | A1 | R12a-Bob-S76ab | 추측 | 측정: s76a_list dy 실측값 (light=<값>, dark=<값> < 960) | 골든 위치 전제 실측 | 960 미만 확인 | ⬜ 미답 | |
    (A2 = s76a_empty · A3 = s76a_sim · A4 = s76b_band · A5 = s76b_seasonal · A6 = s76b_advisory · 같은 형식 · 960 = kS76abGoldenSize 의 높이 · <값> 자리에만 잰 숫자)
· 적지 않을 것(카드가 정함 = 추측 아님): 위젯·프로바이더·Key·파일·테스트·가짜 이름 · 정적 라벨 6개 · 읽지 않는 필드 목록(규칙 5) · 스냅샷 기본 접힘 · 대조 표 접힘 밖 ·
  배치 순서 · 배지 색·대조 표 아이콘(「모의」 배지가 StaleBanner 띠와 같은 tertiaryContainer 계열인 것은 알고 정한 것 — 질문 아님) · configHash 1줄 말줄임 · 기준일 하단 · 골든 이름·입력 · 재량인 것(여백·글자 크기·모서리). 동작·상태·글자·Key 가 갈리는 것만 적는다.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다(찾는 말 = 위젯·필드 이름) · «카드 지시대로»·«카드대로» 라는 말이 들어가는 행은 쓰지 않는다.
· 🔴 질문 파일은 브랜치에 커밋한다(채팅 보고만으로는 제출이 아니다).

■ 제출
  (할 일 (1)~(6) 커밋이 끝난 뒤 — (6) 이 마지막 커밋)
  cd packages/ui_analytics
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건 · format 은 0 changed
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤 · format 이 무엇이든 바꾸면 커밋을 더하지 말고 멈춘 뒤 채팅으로)
  git status --short   ← 🔴 비어 있어야 푸시한다 — 커밋 안 된 수정은 CI 포맷 게이트를 빨갛게 만든다
  git diff --name-status origin/main...HEAD
     ← 기대 = 22줄 · 출력 글자 그대로(저장소 루트 기준 경로 · git 이 경로 알파벳 순으로 찍는다):
        M docs/ai-context/inbox/S7-6ab_questions.md · M packages/ui_analytics/lib/l10n/labels.dart · M packages/ui_analytics/lib/src/providers/analytics_providers.dart ·
        A packages/ui_analytics/lib/src/screens/rebalance_event_screen.dart · A packages/ui_analytics/lib/src/screens/rebalance_timeline_screen.dart · M packages/ui_analytics/lib/ui_analytics.dart ·
        A packages/ui_analytics/test/golden/goldens/s76a_{empty,list,sim}_{dark,light}.png 6줄 · A packages/ui_analytics/test/golden/goldens/s76b_{advisory,band,seasonal}_{dark,light}.png 6줄 ·
        A packages/ui_analytics/test/golden/s76ab_golden_test.dart · A packages/ui_analytics/test/rebalance_event_view_test.dart · A packages/ui_analytics/test/rebalance_fakes.dart ·
        A packages/ui_analytics/test/rebalance_timeline_view_test.dart
        그 밖의 줄(기존 PNG M · domain_contracts/** · 기존 lib·테스트 · 하네스 · 다른 질문 파일) = 금지(하나라도 있으면 푸시하지 말고 멈춘 뒤 출력을 채팅으로)
  git push -u origin ui/m7-s76ab-rebalance
  git diff --name-status origin/main...HEAD   ← 아래 ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서)
  git log --oneline origin/main..HEAD          ← 아래 ① 에 그대로(6줄 · (6) 이 맨 위)
  cd packages/ui_analytics → 위 «정적 묶음» 39줄 → 위 «테스트 수 묶음» 4줄 → cd ../..   ← 아래 ② 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · git status 가 빈 채로)
  PR 은 만들지 않습니다(통합 담당 대행) · PR 본문도 GitHub 에서 고치지 않습니다 · 라벨도 붙이지 않습니다(golden:approved 포함). PR 제목: [M7] S7-6a·S7-6b 리밸런싱 회차 타임라인·상세
  제출 글 = 채팅으로 아래 상자의 섹션 머리 다섯 줄을 **글자 그대로** 두고 그 아래를 채운다(통합 담당이 이 글로 PR 본문을 통째로 만든다 · 12 §3:230):
      ┌── 제출 글 머리(다섯 줄 · 글자 그대로)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └──
      (이 다섯 줄은 R12 네 장(R12a~R12d)이 같은 글자다 — 무엇을 어느 섹션에 붙이는지는 아래 ①~⑤ 설명이 정한다)
   ① 화면 ID(S7-6a — 리밸런싱 회차 타임라인 · S7-6b — 회차 상세) + 바뀐 파일 = 위 git diff --name-status origin/main...HEAD 출력 그대로(손으로 쓰지 않음 · A/M · PNG 포함) +
      커밋 목록(git log --oneline origin/main..HEAD 출력 그대로 — (6) 이 맨 위)
   ② 자체 점검 12항 — 아래 복사 상자의 15줄을 한 글자도 바꾸지 않고(들여쓰기 포함) 붙인 뒤, 각 항목 끝의 « [x] ( )» 괄호 안만 채운다(위 보고 규칙 · 코드에 실제로 있는 것만 [x]).
      🔴 붙인 뒤 12항이 15줄 그대로인지 센다 — 11번·12번은 각각 3줄·2줄(들여쓰기 4칸 줄 포함)이고, 한 줄로 잇지 않습니다 · 세는 명령(12항 15줄만 임시 파일에 붙여 넣고):
         PowerShell: (Get-Content "$env:TEMP\r12a_item12.txt" -Encoding UTF8).Count   ← 15
         bash:       wc -l < "$TEMP/r12a_item12.txt"                                  ← 15(끝 줄 뒤 줄바꿈이 있을 때)
         (🔴 임시 파일은 저장소 밖 · 15 가 아니면 붙인 글을 고친다 · 이 명령의 출력 한 줄도 ② 에 붙인다)
      항목을 더하거나 빼거나 합치거나 고쳐 쓰지 않는다.
      붙일 괄호(글자 그대로 · <N> 자리에만 정적 묶음 결과의 수):
        1번 = «정적 묶음 S19 — 허용 밖 import 0줄»
        2번 = «화면 산술 0 — 비중·밴드 이탈은 엔진 문장(SleeveWeight.label · ThresholdCompare 글자) 그대로 · 원값 참조 0(정적 S25 · C-42 ②)»
        3번 = «정적 묶음 S20 — 0건 · 유형 칩 = kindLabel · 「모의」 배지 = modeLabel(엔진 글자)»
        4번 · 5번 · 6번 · 7번 · 8번 = «이 카드 범위 밖»
        9번 = «as-of = 하단 1줄(S7-6a 봉투 asOf.label · S7-6b s76b-asof — 01 §15-4-9 «하단») · 오래됨 배너 = StaleBanner(스크롤 밖 · T76A-08 · T76B-09)»
        10번 = «앞절 이 카드 범위 밖 / 뒷절 기존 PNG M 0 · domain_contracts 변경 0»
        11번 = «정적 묶음 S21 결과 <N>건 · 보강 S22 결과 <N>건 · S23 결과 <N>건»
        12번 = «이 카드 범위 밖(세후 사다리 = R12c · 목표 경로 가정 카드 = R11b)»
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
      이어서 «정적 묶음» 출력 전부를 코드 블록 하나로 그대로 + S05a·S05b 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안» 한 줄(괄호 금지 · 줄을 빼거나 줄이면 = 보고 불일치)
      + «ⓡ = S29 출력 · ⓗ = S30 출력» 한 줄(숫자는 출력 그대로 — 파일마다) + «테스트 수 묶음» 4줄의 끝 줄 그대로 + «시작 기준 N → 끝 M» 한 줄(N = 0단계 · M = 마지막 flutter test 끝 줄 그대로)
   ③ 스크린샷 서술 — S7-6a 로딩·정상·빈·차단 4줄 + S7-6b 로딩·정상·차단 3줄 + 골든 표 12행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술은 코드의 위젯·Key 이름 나열로만 쓴다 — 두 화면 파일을 위에서 아래로 읽으며 나오는 순서 그대로 «→» 로 잇는다 ·
         조건으로 붙는 것(StaleBanner · SafetyBlockBanner · s76a-section-<id> · s76a-mode-<id> · s76a-empty-next · s76b-thresholds · s76b-quality · s76b-link-journalTimelineLink · 스냅샷의 summary·configHash)은 «(있을 때)» 를 붙인다 ·
         그 순서가 위 «화면» 의 배치(S7-6a 1~5 · S7-6b 1~10)와 다르면 제출하지 말고 멈춘 뒤 채팅으로.
         «로딩» = AnalyticsSkeleton(배너 없음) · «정상» = 배치 번호 순 Key·위젯 나열 · «빈»(S7-6a) = emptyLabel Text → s76a-empty-next → 하단 기준일 Text ·
         «차단» = SafetyBlockBanner 의 자리를 코드 그대로 — «StaleBanner 아래 · Expanded(ListView) 바깥 위(값이 온 뒤의 Column 둘째 자식)».
      골든 표 12행: 이름(밝기 포함) · 입력 픽스처 · 크기 · 위치 전제 dy · 배치·잘림 —
        입력 픽스처 칸 = FixturePaths 상수가 가리키는 경로 그대로(예 m7/m7_rebalance_detail_band.json · s76b_seasonal = rebalance_6.json 의 re_20261030_01) · 크기 = 390×<높이> · dy = 위 «골든» 절 끝의 방법으로 이름·밝기마다 잰 값(한 값을 여러 행에 복사하지 않는다) ·
        배치·잘림 = PNG 를 열어 본 것만(PNG 의 꽉 찬 네모는 전부 테스트 글꼴 글자 — 점·아이콘으로 읽지 않는다 · 못 본 것은 «미열람»).
   ④ 질문 표(새 행 번호·요지 — 질문 파일에 쓴 글자와 같게)
   ⑤ 추측한 것 = S7-6ab_questions.md 의 새 A 행 중 «측정:» 이 아닌 행 전부 — 파일 접두를 붙인 번호로(예 S7-6ab A7)
      (없으면 «없음» — 질문 파일과 ⑤ 가 다르면 반려)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m7-s76ab-rebalance` 푸시 1건 · 커밋 6개(본문 (1)~(6) · (6) 이 맨 위).
- `lib/` 새 파일 2(`screens/rebalance_timeline_screen.dart` · `screens/rebalance_event_screen.dart`) · 수정 3(`l10n/labels.dart` 끝 R12a 절 6개 · `providers/analytics_providers.dart` 끝 R12a 절 프로바이더 3 · `ui_analytics.dart` export 2줄(정렬 자리)). 그 밖의 `lib/`(R10 차트 · 위젯 · 다른 화면 · R11a `planner.dart`·`src/planner/**` · R11b `goal_path/**`·`goal_path_screen.dart`)는 바뀌지 않는 것이 정상 · `lib/src/rebalance/` 없음.
- `test/` 새 파일 4(`rebalance_fakes.dart` · `rebalance_timeline_view_test.dart` · `rebalance_event_view_test.dart` · `golden/s76ab_golden_test.dart`) + 새 PNG 12장(`s76a_*` 6 · `s76b_*` 6). 하네스·본보기·기존 골든 테스트·기존 PNG 64장·기존 테스트는 불변.
- 질문 파일 `S7-6ab_questions.md`(새 행 A1~A6 «측정:» 은 반드시 · 그 밖은 있을 때만).
- 채팅: 제출 글 ①~⑤(섹션 머리 다섯 줄 글자 그대로 · ① name-status 출력 그대로 + 커밋 목록 · ② 복사 상자 12항 + 괄호 + 15줄 명령 출력 + «정적 묶음» 39줄 출력 전부 + S05a·S05b 줄 + 테스트 수 묶음 · ③ Key 나열 + 골든 표 12행(dy 는 이름·밝기마다) · ④ · ⑤).
- `flutter test` = 시작 기준 N(0단계 · v1.6 병합본 실측 · 304 기대) + 새 50(timeline 15 + event 23 + 골든 12) = **354** 기대(드라이런 354 — 최소 목록의 번호가 기준 · 수가 다르면 PR 본문에 까닭 · 적다고 곧 반려는 아님) · 정적 S29 = 10·8 · S30 = 3·7(🔴 정확히 — 다르면 반려).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R12a-Bob-S76ab 결과: 브랜치 ui/m7-s76ab-rebalance 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 제출 글 ①~⑤ 를 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R12a-Bob-S76ab 결과: PR #<번호> — 병합 검사하고 질문 반영해줘`(PR 본문은 Claude 가 제출 글로 통째로 바꿉니다) · 0단계에서 멈췄다면 `R12a-Bob-S76ab 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① 기존 PNG(`s71_*`·`s71b_*`·`s72g_*`·`s72_*`·`s73_*`·`s73b_*`·`s74_*`·`s79_*`)가 `M` ② `pubspec.yaml`·`domain_contracts/**` 변경 ③ 하네스(`golden_support`·`chart_probe*`·`reference/**`·README)가 `M` ④ 화면 코드의 `aaq://`·`Navigator`·`DateTime`·`DateRange`·`.weight`·`.mode`·`.kind`·`thresholdRegistered`·`elevation: 0.5` ⑤ 계산(비중 차이·밴드 비교·행 세기) · 지은 글자(«모의»·유형 이름·«건») · 손익 · 실행/승인 버튼 ⑥ `labels.dart`·`analytics_providers.dart`·`ui_analytics.dart` 에 삭제 줄 · providers R12a 표식 위에 R12 이름 ⑦ ② 의 S04·S05a·S05b·S13·S15·S28 출력에 주석 줄·import 줄이 찍힘(규칙 17) · ⓡ·ⓗ 수(S29·S30)가 10·8 / 3·7 이 아님 · S31 에 실패 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 새 PNG 12장만 더하므로 라벨 없이 초록이어야 합니다(기존 PNG 재생성 0 · `golden:approved` 불필요). 빨간색이면 기존 PNG 가 바뀐 것 — 반려 신호.
- 계약 테스트 C-42(②~⑬ — 역할 파일·providers R12 절 스캔)는 Bob 브랜치가 들어와야 실제 파일을 봅니다(그 전에는 공허 통과) — 병합 검사 때 Claude 가 그 위에서 돌리고 «대상 S7-6a 1파일 · S7-6b 1파일»을 확인합니다(Bob 의 S31 출력과 대조).
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 자기 worktree 에서만).
- 🔴 **파일 이름 주의** — 끝난 카드(`_완료/R11a-Bob-S74*.md` · `_완료/R11b-Bob-S79*.md` · `_완료/R10*-Bob-*.md` · `_완료/R1b-Gem-S71.md` · `_완료/R2-Gem-S73*.md` · `_완료/R2b-Bob-J3.md`)를 붙여넣지 않습니다.
- 드라이런 실측(가지 `dry/r12a` 끝 `7f72538` · 밑동 `e716fe0` = v1.6 로컬 tip · 기록 커밋 전 · 2026-10-08~12): 커밋 6개((6) 맨 위) · `flutter test`(packages/ui_analytics) 304 → 354(+50 = timeline 15 · event 23 · 골든 12 · 새 `testWidgets(`/`test(` 줄 timeline 10 · event 11 · 골든 2 = 23) · 새 PNG 12(390×960 · 기존 PNG M 0) · domain_contracts 변경 0 · lib +416/−0(timeline 170 · event 211 · labels 8 · providers 25 · barrel 2) · test +1141 · 맨 아래 dy(light=dark · 높이 2000·960 두 번 같음) s76a_list 848 · s76a_empty 120 · s76a_sim 324 · s76b_band 892 · s76b_seasonal 692 · s76b_advisory 892(844 초과 2장 → 960) · S05a 3줄(62 · 78 · 162) · S05b 2줄(76 · 197) · S15 6줄(63 · 78 · 91 · 105 · 121 · 127) · S16b 10 · S27 8/0 · 25/0 · 2/0 · S28 3 · S29 10·8 · S30 3·7 · C-42 ① 대상 S7-6a 1 · S7-6b 1 · S7-6c·S7-7·S7-10 0 · providers R12 절 24줄 · C-42 +14 통과 · 12항 복사 상자 == prompt_M7.md 156~170행(diff 0 · 15줄) · format 0 changed · analyze 13패키지 No issues · test:contracts SUCCESS · 예고 변이 32건(A 19 · B 13) 모두 잡힘 · 살아남은 변이 0(배지·머리글 «모든 행» 두 건은 첫 시도가 컴파일 오류라 컴파일되는 변이로 다시 돌려 T76A-05 에서 잡힘) · 재분할 임계(새 줄 > 33 · lib > +900 · 새 PNG > 16) = 23 · +416 · 12 → 재분할 불필요(설계서 추측 lib +550~750 보다 작다). 🔴 0단계의 기록 커밋 몫 네 줄(send · inbox · prompt :2 · golden README R12 절)은 이 드라이런에서 확인하지 못했다 — 기록 커밋 위 누적 드라이런에서 다시 본다(머리 «보내는 조건»).
- 범위 고지: 유형 필터·주문 건수(01 §8 미결 83·88) · 회차별 흐리게·「미확정」·배지(K22 권고 선반영 · 미결 87) · 상태 3종과 `s76b_missing_snapshot`(미결 87) · LIVE·SIM 섞인 목록의 정렬 키(미결 89) · 국면 라벨(미결 50 ①) · advisory 회차의 `quality` 뜻(03 §17 #11) · `J-1` 회차 칩(«R2b 잔여 부록» S-12) · 셸 배선(R13)은 이 카드에 없습니다. `S7-6c`·`S7-7`·`S7-10` 은 R12b·R12c·R12d 입니다.
- 🔵 ⓡ·ⓗ 정책 = R11b 와 같다(**정확히** — ⓗ 자리를 최소 목록에 못박았고 경우마다 testWidgets 를 for 로 만들어 파일 안 줄 수가 짜임과 무관하다).
- 그 밖의 알릴 것은 `_완료/R10a-Bob-S71b.md` «5» 를 참고합니다.
