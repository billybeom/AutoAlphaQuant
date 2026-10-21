# 발송 패킷 R4b-Bob-H62H63 — H6-2 종목 상세 · H6-3 슬리브·비중 (계약 v1.8 · R4 2장 중 2번째)

> ~~▶~~ 🔴 **1회차 반려**(2026-10-21 · PR #62 `6b2e00d` · C4b-1·2) → `send/R4b-Bob-H62H63-재제출.md` · ~~**보낼 수 있음**~~(2026-10-21 발주자 확인 10항 = 기본값 그대로 · ⑦ ✅ · 이 파일이 GitHub `main` 의 `send/` 에 있으면 보낸다 · Bob **새 대화**) — ~~⏸ 아직 보내지 않음 — 발주자 확인(아래 «발주자 확인 대기» 목록 ①~⑥ · ⑧~⑪ = 10항 — ⑦ C-40 ⑧ 보강은 ✅ 결정·병합) + R4a 병합 기록 커밋 푸시(이 파일이 GitHub `main` 의 `send/` 에 있어야 0단계 `ls` 와 ■ 제출 name-status 기대가 맞는다) 뒤 ▶ · ~~재드라이런 대기~~ ✅ 재드라이런 끝**(2026-10-21 R4a 병합 기록 · 이 파일을 `send/_대기/` 에서 `send/` 로 옮겼다 · 머리 첫 줄 ▶ 는 발주자 확인 + 푸시 뒤 Claude 가 단다 · 실제 R4a 병합본 위 재드라이런 = ✅ 아래 «드라이런» 줄) — ✅ 선행 = **R4a-Bob-H61 병합**(2026-10-21 · PR #57 squash `faeb458` · C4 1회차 merge-with-fixes · 코드 정정 0)과 이 파일을 `send/` 로 옮긴 R4a 병합 기록 커밋 · ✅ **선행 2 = C-40 ⑧ 보강 병합**(2026-10-21 · PR #55 squash `e494817` · 계약 테스트 C-40 ⑧ 의 `RebalanceRepository` 금지에서 H6 대상 파일(C-44 ⑫ 와 같은 집합)만 뺌 · `orderIntentIds` 는 어디서나 금지 그대로 · 합성 표본 자기 검사 · 이 카드대로 지으면 `domain_contracts` «+336 ~30: All tests passed!» — 보강 전 드라이런 «+335 ~30 -1: Some tests failed.») · ✅ 누적 드라이런(2026-10-21 · worktree `C:/Work/AAQ-claude-r4dryB` · 가지 `dry/r4b` · `dry/r4a` 끝 = R4a 병합본 흉내 위 · 사전검사 🔴 0 · 재분할 불필요) · 🔄 R4a 병합 기록이 이 파일의 R4a squash 자리와 실측 표식(부호 U+27E6)을 실제 병합본 `faeb458` 실측으로 채웠고, 0단계 확인 줄·공용 파일 기대(labels 끝 절 = R4a 절 `holdingsRegisteredOn` · `journal_common.dart` 무변경 · 배럴 차례 · `holdings_overview_fakes.dart` 의 공용 도우미 `FakeHoldingsSafetyRepository`·`holdingsShownTexts`·`holdingsChipIcon` · `h61-` Key 22이름 · 정적 S06 3줄 · S15 1줄 · S16 7줄 · S26 3줄 · C-44 ⑫ «1파일»)를 그 병합본에서 다시 쟀다 — 드라이런 흉내(`dry/r4a` `06668f0`)와 같아 기대 수 변경 0 · ~~⬜ 재드라이런(실제 병합본 위 · 이 기록 뒤)~~ ✅ 재드라이런(2026-10-21 · 실제 병합본 위 — 아래 «드라이런» 줄 · 기대 수 변경 0 · 지적 5 = 표기·안내만 반영). **R4 2장 중 2번째** · 한 번에 카드 1장 · 순서 고정 R4a → **R4b**(앞 카드 병합 뒤).
> 만든 날 2026-10-21 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R4b-Bob-H62H63` 행 + «R3 C4 이월 부록»(C4r3-1 · C4r3-4 · C4r3-5 = 이 카드 몫) + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · 커밋 = 제목만 맞추기 · 골든 높이 = 재량 + 기록 · 재제출 = 전체판 + 상자) · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-20_R4선행_계약v1.8_설계서.md` §2-5 · §2-6 · §2-7 · §2-8 · §3-1b · §3-4 · §6 · §9(K1~K29 전부 확정) · 조문 = `01_…` §17(17-4 · 17-6 · 17-7 · 17-8 · 17-10 · 17-16) · `02_…` §4-2 · §4-3 + §4 끝 «🆕 계약 v1.8 — `H6-*` R4 범위 · 이 블록이 이긴다» 블록 ⓐ~ⓛ · 코드 = `packages/domain_contracts`(`HoldingDetailVm` · `StopLineNormalized` · `TradeJournalEntry` · `SleeveAllocationVm` · `SleeveAllocationRow` · `SleeveBandGauge` · `SleeveBandState` · `NextRebalanceVm` · `HoldingsRepository.watchHoldingDetail`·`watchAllocation` · `RebalanceRepository.watchNext` · 받침대 `UnimplementedHoldingsRepository`·`UnimplementedRebalanceRepository`) · 계약 테스트 C-44(이 카드의 두 화면 파일이 B 절 ⑬~⑲ 대상에 들어 «정확히 3파일» 이 된다) · golden README «🆕 R4» 절.
> 사전 조건 — ✅ 계약 v1.8 병합(앱 PR #48 · squash `dcac7ec` · 2026-10-21 · `contractVersion '1.8.0'` · 픽스처 159 · 라우트 48 · 그 뒤 엔진 PR #50 `f978706` 이 `domain_contracts` testing.dart·계약 테스트 +1 → 336 통과 · 30 skip · `ui_journal` 영향 0 · 병합본 `faeb458` 실측도 «+336 ~30: All tests passed!» — 엔진 PR #51~#56 · C-40 ⑧ PR #55 = 수 불변) · ✅ **R4a-Bob-H61 병합**(2026-10-21 · PR #57 squash `faeb458` — `H6-1` · `HoldingsOverview` · `journalHoldingsRepositoryProvider`(주입 · 이 카드가 import 해서 재사용) · `holdings_overview.dart` · 정적 라벨 3(`holdingsAvgPrice` · `holdingsEntryDate` · `holdingsRegisteredOn` — 이 카드가 재사용) · `test/holdings_overview_fakes.dart`(`FakeHoldingsSafetyRepository` — 이 카드가 import 해서 재사용) · 골든 `h61_*` 10장 · 배럴 +1). 병합 확인은 본문 0단계의 확인 줄로 합니다(해시 없이 내용으로). 시작 기준 `flutter test`(packages/ui_journal) = **322**(R4a 병합본 `faeb458` 실측 2026-10-21 «+322: All tests passed!» · R4a 드라이런 끝과 같음 · 재드라이런 0단계 «00:27 +322: All tests passed!» · 그 뒤 엔진 PR #58 `ecf842d`(`data_sync` 만) = 수 불변) · 이 카드 끝 기대 = 시작 기준 N + 66(H6-2 뷰 21 · H6-3 뷰 29 · 골든 h62 8 · h63 8 · 322 → 388).
> 카드 확정값(카드 권한): 새 lib 파일 2개(`lib/src/holding_detail.dart` · `lib/src/holdings_allocation.dart` · `lib/src/holdings/` 폴더 만들지 않음 · 🔴 R4a 의 `holdings_overview.dart` 는 **고치지 않는다** — import 만) · 정적 라벨 5개(`holdingsStopLines` 손절선 · `holdingsRecentEntries` 최근 체결 · `holdingsDeployed` 투자분 · `holdingsParking` 파킹 · `holdingsNextRebalance` 다음 리밸런싱) · Key 표 `h62-` 14이름 · `h63-` 15이름(순번만 · 에러 갈래 = `h62-fail`·`h63-fail`) · 최근 체결 행 = `JournalEntryCard` 무수정 재사용(탭 = 행 `detailDeepLink`) · 게이지 = `CustomPaint`(× 폭만) · 잔고 막대 = `LayoutBuilder` + 두 `SizedBox(width: c.maxWidth * x)` · 행 펼침(`engineColumnNote`) = 위젯 State + `IconButton` · 하단 다음 회차 = 정상·빈 두 갈래 모두 · 스켈레톤 = `JournalSkeleton` 무수정(6장 — R4a 와 같다 · 발주자 확인 ⑪) · 테스트 파일 `test/holding_detail_test.dart` · `test/holdings_allocation_test.dart` + 가짜 `test/holding_detail_fakes.dart` · `test/holdings_allocation_fakes.dart` · 골든 8이름 16장(`test/golden/h62_golden_test.dart` 4이름 · `test/golden/h63_golden_test.dart` 4이름 · 크기 = 파일마다 상수 — h62 390 × 1400 · h63 390 × 1100(드라이런)).
> 🔴 **보내는 조건(Claude 확인)** — ✅ R4a PR 병합(PR #57 `faeb458`) + ✅ C-40 ⑧ 보강 병합(PR #55 `e494817`) + 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있음(`_대기/` 가 아니라 · = R4a 병합 기록 커밋 푸시 뒤 — 0단계 `ls docs/ai-context/send/R4b-Bob-H62H63.md` 와 ■ 제출 `git diff --name-status origin/main...HEAD` 기대 27줄이 이것을 전제 · 푸시 전이면 name-status 에 기록 커밋의 문서 줄이 더 나온다(재드라이런 37줄 = 27 + 10)) + 질문 파일 `inbox/H62H63_questions.md` 가 `main` 에 있음(빈 머리말 — R4 조립 기록 커밋이 만든다 · 카드마다 1개 · 두 화면 질문을 한 파일에) + golden README «🆕 R4» 절의 R4b 행(`git grep -c "h63_pot_under_a" -- packages/ui_journal/test/golden/README.md` = 숫자 하나) + 이 파일에 R4a squash 자리표시 0 · 실측 표식 0(`LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R4b-Bob-H62H63.md` = 0) + 누적 드라이런 사전검사 🔴 0 + 재분할 불필요 판정 + 🆕 발주자 확인(머리 «발주자 확인 대기») · ✅ 실제 R4a 병합본 위 재드라이런(2026-10-21) → 머리 첫 줄 ▶. 0단계의 `ls`·`git grep` 줄이 그 증명입니다.
> ✅ **기록 커밋 체크리스트(Claude · R4a 병합 기록 2026-10-21 — 끝)** — ⓪ ✅ `send/R4a-Bob-H61.md` → `send/_완료/R4a-Bob-H61.md`(git mv · send/README 표 행 · send/ 바로 아래 패킷 = 이 카드 하나) ① ✅ `send/_대기/R4b-Bob-H62H63.md` → `send/R4b-Bob-H62H63.md` 이동 · 머리 첫 줄 = ⏸ 유지(선행 2 C-40 ⑧ 보강은 ✅ 병합 · ▶ 는 발주자 확인 + 재드라이런 뒤) ② ✅ R4a squash 자리 → 해시 `faeb458`(2026-10-21) ③ ✅ 실측 표식 → R4a 병합본 `faeb458` 실측(시작 기준 N = 322 · R4a 가 남긴 S06 3줄 · S15 1줄 · S16 배럴 7줄 · S26 라벨 3줄 · C-44 ⑫ «1파일» 2줄 — 병합본에서 다시 셈 · 드라이런 흉내와 같음 · R4a 통합 수정 0 → 이 카드의 누계 수정 0) ④ ✅ `inbox/H62H63_questions.md` 빈 머리말(다음 번호 Q1·A1 · 행 0 — R4 조립 기록이 만듦) ⑤ ✅ golden README «🆕 R4» 절 R4b 행 그대로(8이름 · 크기 = 드라이런 실측 — R4a 통합 수정 0 · R4b 화면은 R4a 배치에 기대지 않는다 · 🆕 재드라이런 뒤 R4b 행 dy 만 실제 병합본 위 실측으로 바꿈 — h62 −28 · h63 +4 · 이름·크기 그대로 · 간격 재량) ⑥ ✅ C-40 ⑧ 보강 병합(PR #55 squash `e494817`) 확인 → 0단계 확인 줄 · ■ 제출 «domain_contracts» 기대 수 채움.
> 🔴 **카드 덮개 필수 문장(01 §17-7 · 02 §4 v1.8 블록 ⓐⓓⓕⓘⓙ)** — «`H6-2` 는 생성자의 `holdingId` 하나로 `watchHoldingDetail(holdingId, includePnl: …)` 만 부른다 — 종목 코드로 찾지 않는다 · 손익 펼침 = 토글 탭으로 true 재구독(State 변수로만 · 리터럴 `true` 0) · 열람 기록 0 · 손절선 = 글자 행만(게이지 0 · 남은 % 계산 0)» · «`H6-3` 의 막대 둘(밴드 게이지 · 잔고 막대)은 엔진의 0~1 값 × 폭 **만** — 여집합·차·합·0 대입 0 · 색 = `bandState` switch 하나 · 파킹은 경고가 아니다» · «화면은 묶지도 거르지도 더하지도 가리지도 않는다 — 행 = 받은 순서 · POT 들여쓰기 = `parentSleeve != null` · «?»·«숨김» 은 엔진 글자 그대로 · 가림이면 기하 null = 부재». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — K3(손절선 = 글자 행) · K7(`holdingId` 키 · 모르는 id = 스트림 에러 잠정) · K8(D-day = `watchNext()` · 탭 = `previewRoute`) · K9(밴드 축 = `sleeveWeight` + `bandState` + `gauge`) · K10(가림 = 엔진 · INTEGRITY 기하 null · RECON 기하 유지) · K12(데이터 링크만) · K13(계절 보류 = `stateChips`) · K15(뷰어 토글 부재) · K16 ⓑⓓⓔⓕ(골든 이름 · `entryDecisionLink` 늘 있음 · RECON = 글자 끝 «?») · K17(POT = A 바로 뒤 들여쓰기) · K19(이력 = VM 안) · K21 · K26 · K27(밴드 행 = B 만) · K28(토글 = 화면 단위 1개 · autoDispose 0) · K29 = **✅ 발주자 확정(2026-10-20 · 2026-10-21 · 전부 권고대로 · 01 §17-14)**.
> ✅ **발주자 확인 완료(2026-10-21 · ①~⑥·⑧~⑪ 기본값 그대로 · ⑦ = C-40 ⑧ 병합)**: ① 정적 라벨 5개(«손절선»·«최근 체결» = 절 머리 · «투자분»·«파킹» = 금액 앞 머리 · «다음 리밸런싱» = D-day 앞 머리 — 예정 없음 갈래에서는 붙이지 않는다 · 🔵 «투자분»·«파킹» 머리는 **모든** 배분 행(A · POT · B · C · 현금 대기)에 붙는다 — 현금 대기 행은 «파킹 100만원 …» 으로 읽힌다 · 화면이 슬리브로 붙일 행을 고르는 것은 금지라 대안은 «두 머리를 전부 뺌» 하나) ② `H6-3` 하단 다음 회차를 빈 갈래(배분 행 0)에도 그림(두 창구는 따로다) ③ `NextRebalanceVm` 의 `kindLabel`·`noticeText`·`asOf` 는 `H6-3` 에서 그리지 않음(`S7-6c` 몫 · 하단 = 날짜·D-day 또는 빈 문장 한 줄) ④ 최근 체결 행 = `JournalEntryCard` 무수정 재사용(J-1 행과 같은 모양 · 수수료·세금 줄 포함 · 🔵 사유 칩이 3개를 넘으면 그 위젯이 «+n» 으로 접는다 — H6 원칙 «자르지 않는다» 와 다름 · 표본 `recentEntries` 의 사유 칩 = 행마다 1(드라이런)) ⑤ 3분할 때 = R4b-Bob-H62(`H6-2` · `ui/m6-h62-detail` · `h62_`) / R4c-Bob-H63(`H6-3` · `ui/m6-h63-allocation` · `h63_`)(드라이런 = 세 임계 모두 안 — 지금은 나누지 않는다) ⑥ `H6-2` 트랜치 칩 = label + filled 아이콘만 — `filledOn`(채운 날)은 그리지 않는다(02 §4-2 컴포넌트는 `filledOn` 을 든다 · R4a ② 와 같은 결정) ⑦ ✅ **C-40 ⑧ 보강 — 결정·병합 끝**(2026-10-21 발주자 결정 = 권고 · PR #55 squash `e494817` — C-40 ⑧ 의 `RebalanceRepository` 금지를 C-44 ⑫ 의 `H6` 대상 파일 밖으로 한정 · `orderIntentIds` 는 전역 금지 그대로 · 대상 집합을 C-44 파일과 맞대는 줄 · 합성 표본 자기 검사(음성 3 · 양성 5) · ~~대안 = 셸이 `Stream<NextRebalanceVm> Function()` 꼴 프로바이더를 주입~~) ⑧ `H6-3` «이탈 = 행 강조»(02 §4-3 상태) — 카드 기본 = 상태 점·게이지 표식 색(`cs.error`)으로 갈음 · 행 배경 강조 없음(행 강조를 고르면 `SleeveBandState` 전수 switch 로 행 배경을 정하고 T63-02 · 골든 `h63_out_of_band` 를 다시 잰다) ⑨ 자리 표 밖 필드도 그린다 — 행의 `deployedPctText`·`parkingPctText`(02 §4-3 «M8 홈 재사용 전용» 요청 필드) · 하단 `expectedDateText`(01 §17-6 하단 자리 = `dDayText`/`emptyLabel`) — 규칙 2 «계약이 주는 표시 값은 전부 그린다» 를 따름 ⑩ 배지 = `GateState` 아이콘(02 «`state`로 색» 을 J-5 선례대로 갈음 — R4a ⑤ 와 같음) ⑪ 스켈레톤 = `JournalSkeleton` 6장(R4a ⑥ 과 같음).
> 드라이런: ✅ `C:/Work/AAQ-claude-r4dryB` · `dry/r4b` · HEAD `cf28087`(`dry/r4a` 끝 `06668f0` = R4a 병합본 흉내 위 · 권장 5커밋 + 지적 반영 1커밋) · 시작 322 → 끝 «00:27 +388: All tests passed!»(N + 66) · 파일별 «+21»(holding_detail_test) · «+29»(holdings_allocation_test) · «+8»(h62_golden) · «+8»(h63_golden) · `domain_contracts` «+335 ~30 -1»(C-40 ⑧ 1건 — 선행 2 · 보강 PR #55 의 테스트만 얹으면 «+336 ~30: All tests passed!») · C-44 20/20(«⑫ 대상 H6 3파일» 4줄 그대로) · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0 · 🟡 3(전부 G1) · 정적 묶음 33줄 = 본문 기대 그대로(S02c 1·1·11·14 · S05 2 · S06 5 · S07 3 · S08 3 · S12 4 · S16 9 · S22 17/0·2/0 · S23 10·13 · S24 3·4 · S30 6) · 크기 h62 390 × 1400 · h63 390 × 1100 · dy 표 = golden README «🆕 R4» · 새 testWidgets 줄 27 · lib +596/-0 · 새 PNG 16 → 재분할 불필요 · 예고 변이(이 판 목록) 전부 KILLED(여집합 = C-44 ⑯). · 🔄 ~~실제 R4a 병합본(`faeb458`) 위 재드라이런 = ⬜(R4a 병합 기록 뒤 — 0단계·시작 기준 N·공용 파일은 병합본에서 다시 쟀고 드라이런 흉내와 같다)~~ → ✅ **재드라이런**(2026-10-21 · worktree `C:/Work/AAQ-claude-r4bdry2`(끝난 뒤 지움) · 가지 `dry/r4b2` HEAD `c5ae7f4` = R4a 병합본 `faeb458` + R4a 병합 기록 위 권장 5커밋) — 0단계 `git grep` 11줄 전부 `:1` · `ls` 17개 있음 · README `h63_pot_under_a` 숫자 하나(2) · 없어야 할 5개 없음 · 시작 «00:27 +322: All tests passed!» → 끝 «00:30 +388: All tests passed!» · 파일별 «+21» · «+29» · «+8» · «+8» · `domain_contracts` «+336 ~30: All tests passed!»(c44 +20 · ⑫ 4줄 그대로 · c40 +10) · format 0 changed · analyze 전 패키지 No issues · check_boundaries 실패 0(🟡 C-5 `timeline.dart:109` 기존) · check_labels 위반 0 · name-status 27줄 = ■ 제출 기대 · 정적 33줄 = 본문 기대 그대로 · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0 · 🟡 9(전부 G1 — ■ 제출 N3 🔵) · dy = golden README «🆕 R4» R4b 행(h62 최대 1340 · h63 최대 1056) · 새 testWidgets 줄 27 · lib +603/-0 · 새 PNG 16 → 재분할 불필요 · 예고 변이 52/52 KILLED(H6-2 25 · H6-3 27 · 여집합 = c44 만 · 파킹 문장 경고색 = 골든만 · 🆕 빈 문장 글자 바꾸기 = T63-08 · T63-11) · 지적 5(모두 경미 — 질문 행 꼴 · G1 🟡 수 · dy 참고값 · melos 줄(그대로 · 규칙 12) · 푸시 전제) 반영 · 🆕 기록을 엔진 PR #58 `ecf842d`(`data_sync`·`check_boundaries` 만) 위로 rebase 한 판에서도 다시 돌림 — 끝 «00:28 +388: All tests passed!» · `domain_contracts` «+336 ~30: All tests passed!» · 사전검사 ① 🔴 0 · 🟡 0 · name-status 27줄 · lib +603 · check_boundaries 실패 0 — 같음).
> 프롬프트 = `docs/ai-context/prompt_M6.md`(범위 치환값은 R2b 판 그대로 — 이 카드의 범위·브랜치·PR 제목은 이 패킷이 정한다 · 본문 «프롬프트보다 이 카드가 이긴다» ①⑭) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 · Bob 은 R4a 의 대화를 기억하지 못합니다 — 앞 카드가 만든 것은 «이미 `main` 에 있다 · 고치지 않는다 · 이렇게 쓴다»로 0단계·규칙 요약·주입 구조에 담았습니다.
> R3 교훈 반영: 🆕 PNG 열람 = 이름마다 light 1장(8장 — 이미지 20장 한도) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) · C4r3-1(구독마다 «로딩·에러 × 배너» — T62-08 · T63-11 · `next` 에러 = 본문 영향 0) · C4r3-4(골든 흐름 = 클로저) · C4r3-5(위치 전제 = `expect` 코드 견본) · 공용 파일 «끝 절 더하기만» · «정확히 N» 은 이 카드(R4 마지막)가 소유(S16 배럴 9줄 · S26 라벨 8줄 · C-44 ⑫ 3파일). · 🆕 R4a C4 이월 C4a-5(2026-10-21 발주자 결정 — R4a 의 `h61-empty` 글자 단언 없음 = 카드 구멍 · 반려 사유 아님) → 규칙 10 «빈 문장» 견본(경우 표의 빈 칸 = 기대 글자 `String?` · 있으면 글자 == `emptyLabel` · 없으면 findsNothing) + T63-11 빈 갈래 셋에 적용(✅ 재드라이런 — 사전검사 T1·T2 🔴 0 · 전제 `expect(allocEmpty.emptyLabel, isNotNull)` 통과 · 예고 변이 «빈 문장 글자 바꾸기» = T63-08 · T63-11 로 KILLED · ⓡ 13 · ⓗ 4 · T63-11 testWidgets 10 불변).

## 0. 한 줄 목적

보유 1건(`holdingId`)의 요약·손익 펼침·매수 결정 링크·손절선 글자 행·최근 체결을 그리는 `H6-2`(`HoldingDetail(holdingId:)`)와, 배분 행(A → POT(A 하위) → B → C → 현금 대기)의 밴드 문장·상태색·밴드 게이지·잔고 막대·트랜치 문장·보류 칩·엔진 열 안내와 하단 다음 회차를 그리는 `H6-3`(`HoldingsAllocation()`)을 계약 v1.8 그대로 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-h62-h63-holdings`**(base = 최신 `origin/main` · `--no-track` · 브랜치 이름 = 설계 12 §3 R4b 행 · 01 §17-16 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — `_대기/` 에 있거나 ⏸ 이면 아직입니다(2026-10-21 R4a 병합 기록이 `send/` 로 옮겼다 · 머리 첫 줄 ▶ 는 발주자 확인 + 재드라이런 뒤 Claude 가 단다).
2. Bob 에 R4a 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R4b-Bob-H62H63.md> (🔴 `_대기/` 경로의 옛 판을 열지 않습니다 · `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ```text 다음 줄(«R4b-Bob-H62H63 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 울타리·구분선은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R4a-Bob-H61*.md` · `_완료/R3-Bob-J4*.md` 를 붙여넣지 않습니다.

## 3. 붙여넣을 본문 — ```text 다음 줄(«R4b-Bob-H62H63 — 범위»)부터 닫는 ``` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

```text
R4b-Bob-H62H63 — 범위: H6-2 종목 상세(HoldingDetail({required String holdingId}) — 머리 · 오래됨 · 공통 배너 · 슬리브 글자 · 요약(표시 문자열·칩·배지) · 손익 펼침 토글 ·
  손익 줄 · 「매수 결정 보기」 · 손절선 글자 행 또는 문장 · 최근 체결 행 또는 문장) + H6-3 슬리브·비중(HoldingsAllocation() — 머리 · 오래됨 · 공통 배너 · 고지 ·
  배분 행(밴드 문장 · 상태색 · 밴드 게이지 · 잔고 막대 · 투자분·파킹 · 트랜치 문장 · 파킹 문장 · 보류 칩 · 엔진 열 안내 펼침 · POT 들여쓰기) · 하단 다음 회차 · 빈 문장) +
  데이터 프로바이더 3 + 주입 프로바이더 1(journalRebalanceRepositoryProvider) + 정적 라벨 5 + 배럴 export 2줄.
🔴 H6-2 는 생성자의 holdingId 하나로 watchHoldingDetail(holdingId, includePnl: …) 만 부른다 — 종목 코드로 찾지 않는다 · 손익 펼침 = 토글 탭으로 true 재구독(State 변수로만) · 열람 기록 0 · 손절선 = 글자 행만.
🔴 H6-3 의 막대 둘(밴드 게이지 · 잔고 막대)은 엔진의 0~1 값 × 폭 만 — 여집합·차·합·0 대입 0 · 색 = bandState switch 하나 · 파킹은 경고가 아니다.
🔴 화면은 묶지도 거르지도 더하지도 가리지도 않는다 — 행 = 받은 순서 · POT 들여쓰기 = parentSleeve != null · «?»·«숨김» 은 엔진 글자 그대로 · 가림이면 기하 null = 부재.
하지 않는 것: H6-1(R4a — 이미 main · 고치지 않음) · 손절선 게이지(01 §8 미결 104) · 모멘텀·신호 결측 패널(미결 106 — momentum 은 읽지 않는다) · 「이 종목 전체 이력」(미결 105) · J·H6-3 → H6-* 역참조(미결 110) ·
  S7-6c 미리보기 화면(previewRoute 를 열기만) · 셸 몫(라우트 holdingsDetail·holdingsAllocation 배선 · 웹 «부재» 가드 · 조립 앱 override — R13) · 웹 좌우 배치·스파크라인(Q-D 뒤) ·
  기존 화면(J-1~J-5 · H6-1) 코드·테스트 수정 · journal_common.dart 수정.
🔴 이 카드가 docs/ai-context/prompt_M6.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 20항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R4a(ui/m6-h61-holdings — 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 lib/src/holding_detail.dart · lib/src/holdings_allocation.dart · journalRebalanceRepositoryProvider · Key h62-asof · h63-asof 가 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-h61-holdings 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m6-h62-h63-holdings origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git grep -c "contractVersion = '1.8.0'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»
  git grep -c "abstract class HoldingDetailVm with" -- packages/domain_contracts/lib/src/dto/holdings.dart                     ← «…holdings.dart:1»
  git grep -c "abstract class SleeveAllocationVm with" -- packages/domain_contracts/lib/src/dto/rebalance.dart                 ← «…rebalance.dart:1»
  git grep -c "abstract class SleeveBandGauge with" -- packages/domain_contracts/lib/src/dto/rebalance.dart                    ← «…rebalance.dart:1»
  git grep -c "Stream<SleeveAllocationVm> watchAllocation();" -- packages/domain_contracts/lib/src/repositories/holdings_repository.dart   ← «…holdings_repository.dart:1»
  git grep -c "class UnimplementedRebalanceRepository implements RebalanceRepository" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»
  git grep -c "final journalHoldingsRepositoryProvider = Provider<HoldingsRepository>(" -- packages/ui_journal/lib/src/holdings_overview.dart   ← «…holdings_overview.dart:1»(R4a 병합 — 이 카드가 import 한다)
  git grep -c "class FakeHoldingsSafetyRepository extends UnimplementedSafetyRepository" -- packages/ui_journal/test/holdings_overview_fakes.dart   ← «…holdings_overview_fakes.dart:1»(R4a — import 해서 재사용)
  git grep -c "holdingsAvgPrice = " -- packages/ui_journal/lib/l10n/labels.dart                                               ← «…labels.dart:1»(R4a 라벨 — 재사용)
  git grep -c "IconData? holdingsChipIcon(" -- packages/ui_journal/test/holdings_overview_fakes.dart                          ← «…holdings_overview_fakes.dart:1»(R4a 도우미 — import 해서 재사용)
  git grep -c "final RegExp _bannedOutsideH6 = " -- packages/domain_contracts/test/contracts/c40_rebalance_journal_link_test.dart   ← «…c40_rebalance_journal_link_test.dart:1»(선행 2 — C-40 ⑧ 보강 PR #55 e494817 · H6 대상 파일만 RebalanceRepository 허용)
  ls docs/ai-context/send/R4b-Bob-H62H63.md                                          ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/H62H63_questions.md                                       ← 보여야 함(빈 표가 이미 있다)
  ls tool/precheck.dart                                                              ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holding_detail_with_stops.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holding_detail_no_stop.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holding_detail_pnl.json                   ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holding_detail_recon.json                 ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/holding_detail_integrity.json             ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_in_band.json                   ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_out_of_band.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_tranche_progress.json          ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_parking_large.json             ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_integrity.json                 ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_recon.json                     ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/allocation_empty.json                     ← 보여야 함
  ls packages/domain_contracts/fixtures/m7/m7_next_rebalance_countdown.json          ← 보여야 함
  ls packages/domain_contracts/fixtures/m7/m7_next_rebalance_none.json               ← 보여야 함
  git grep -c "h63_pot_under_a" -- packages/ui_journal/test/golden/README.md                                                   ← 숫자 하나(golden README «🆕 R4» 절)
     (🔴 경로는 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — R4a 병합보다 카드가 먼저 왔습니다 · && 가 안 되는 셸이면 한 줄씩)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R4b 가 들어간 것 — 멈추고 알림):
  ls packages/ui_journal/lib/src/holding_detail.dart                                 ← 없어야 함
  ls packages/ui_journal/lib/src/holdings_allocation.dart                            ← 없어야 함
  git grep -c journalRebalanceRepositoryProvider -- packages/ui_journal/lib          ← 출력 없음이어야 함
  git grep -c h62- -- "packages/ui_journal/*.dart"                                   ← 출력 없음이어야 함
  git grep -c h63- -- "packages/ui_journal/*.dart"                                   ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · 브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_journal
  flutter test   ← 시작 기준: R4a 병합본 전부 통과 · 0 실패 · 기대 «+322: All tests passed!»(R4a 병합본 실측 · 앞 시각은 달라도 된다)(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · 다르면 멈추지 말고 PR 본문에 까닭 한 줄 —
                   그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on ui/m6-…» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·C-44) > 이 카드(지시) > 01 §17 > 02 §4 끝 v1.8 블록 > 02 §4-2·§4-3 본문·그림 M6-17~M6-19 > prompt_M6.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox/H62H63_questions.md 만. 고치면 반려: domain_contracts/** · pubspec.yaml · analysis_options.yaml · test/flutter_test_config.dart ·
   test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·README · 기존 골든 테스트 파일 · 기존 PNG 전부(h61_* 포함 · 하나라도 M 이면 되돌리고 멈춤) ·
   lib 의 기존 파일 전부(🔴 lib/src/holdings_overview.dart(R4a) 포함 — import 만 · journal_common.dart · timeline.dart · 그 밖) · 기존 테스트 파일 전부(🔴 test/holdings_overview_fakes.dart 도 import 만).
   공용 파일 2개는 **더하기만** 한다 — 기존 줄은 한 글자도 바꾸지 않는다(정적 S22 의 삭제 수 0):
     lib/l10n/labels.dart = 파일의 마지막 절(R4a 절 — holdingsRegisteredOn) 뒤에 이 카드의 절 하나 ·
     lib/ui_journal.dart = export 두 줄(🔴 끝이 아니라 정렬 자리 — 아래 «주입 구조»).
 2 두 화면은 받은 글자와 null 여부만 본다 — 값 = DTO 의 *Text·*Label·label·원문 그대로 · 계약이 주는 표시 값은 전부 그린다(아래 3 의 «읽지 않는 필드» 는 예외) · 원값·.wire·키 표시 금지 ·
   폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = labels.dart 의 JournalLabels 에만(테스트에도 금지) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱만).
 3 읽지 않는 필드(카드가 정함 — 질문 아님):
   H6-2 — HoldingRow 의 symbol · sleeve · accountAlias · quantity · avgPrice · entryDecision(이동은 vm.entryDecisionLink) · stopLine · momentum(🔴 패널 0 — 미결 106) · scope · scopeLabel · asOf · holdingId ·
     detailDeepLink(자기 자신) · HoldingPnl 의 unrealizedPnl · pnlPct · TrancheStep 의 stepNo · filledOn · GateBadge 의 code · blockedReasonCode · StopLineNormalized 의 tierCode · level(🔴 글자 = tierLabel · levelText · basisLabel · 강조 = isActive) ·
     TradeJournalEntry 는 JournalEntryCard 가 그리는 그대로(이 카드는 필드를 직접 읽지 않는다).
   H6-3 — SleeveAllocationRow 의 sleeve · basis · parentSleeve 값(🔴 null 여부만 — 들여쓰기) · SleeveWeight 의 sleeve · weight · targetWeight · bandLow · bandHigh · basis(label 만) ·
     ReasonChip 은 JournalReasonChip 이 그린다 · NextRebalanceVm 의 expectedKind · kindLabel · noticeText · asOf(하단 = expectedDateText · dDayText · emptyLabel · previewRoute 만 — S7-6c 몫은 그리지 않는다).
   🔴 C-44 ⑮ 는 .quantity .avgPrice .unrealizedPnl .pnlPct .level .weight .targetWeight .bandLow .bandHigh .symbol .sleeve .scope .basis .tierCode .entryDecision .code .wire 류 · holdingId 를 Text·Key·보간에 넣는 꼴 · .stopLine! · .momentum! 을 기계로 본다.
   🔵 HoldingDetail 의 생성자 값 widget.holdingId 는 데이터 프로바이더 열쇠로만 쓴다(Text·Key·보간 0 — C-44 ⑮).
 4 이동 = AppLinkOpener.open(link) 하나(journalLinkOpenerProvider · 탭 콜백 안 ref.read) · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재 · Navigator 금지 · 플랫폼 판정 금지 ·
   공개 위젯 생성자 = HoldingDetail({super.key, required this.holdingId}) · HoldingsAllocation({super.key}) 뿐(콜백·다른 인자 0).
   화면 파일이 직접 여는 링크: H6-2 = vm.entryDecisionLink.deepLink 하나(최근 체결 행 탭은 JournalEntryCard 가 · 칩은 JournalReasonChip 이 · 배너는 공통 배너가 안에서 연다) · H6-3 = next.previewRoute 하나(칩은 JournalReasonChip).
   이 카드가 쓰는 AppRoutes 상수는 0 개다(check_boundaries [5b] · C-44 ⑱).
 5 화면 산술 0 — 행·칩·체결을 거르지도 세지도 정렬하지도 자르지도 묶지도 옮기지도 않는다(받은 순서 · 순번 = .indexed 의 i) · 목록 길이·int 를 글자로 0 · C-44 ⑰ 낱말 0(.where .sort .take .skip .fold .reduce .toSet .last
   .sublist .contains( .split( .substring( .trim( · maxLines · TextOverflow.ellipsis · reverse: true · groupBy · FlagIds · activeFlags · markerOnly 외 — R4a 카드와 같은 목록) · 펼침 상태 = Map<int, bool>(Set.contains( 금지).
   허용되는 산술은 둘뿐이다: ⓐ 신선도 한 식(vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc())) ⓑ × 폭(아래 «화면» 의 게이지·잔고 막대 — c.maxWidth * d · w * gauge.bandLowNormalized 꼴 · size.height / 2).
   🔴 C-44 ⑯ 은 (Ratio|Normalized) 옆의 - + / · «1 -» · «?? » · Ratio × Normalized 를 기계로 막는다 — 막대 너비 차(높음 − 낮음)·여집합(1 − 비율)·여유 폭을 화면이 만들지 않는다(밴드 음영은 Rect.fromLTRB(왼쪽, 위, 오른쪽, 아래) 로 두 끝을 각각 × 폭).
 6 switch 는 열거값 전수(C-12) — 이 카드의 열거형 switch: SleeveBandState 3값(H6-3 상태색 하나 — inBand → colorScheme.primary · nearEdge → tertiary · outOfBand → error · R4a 와 같은 매핑 · 정적 S28 = 3줄) ·
   GateState 4값(H6-2 배지 아이콘 — pass → Icons.check_circle_outline · block → Icons.cancel_outlined · notApplicable → Icons.radio_button_unchecked · unknown → Icons.help_outline · 정적 S29 = 4줄).
   (R4a 의 private 함수는 다른 파일에서 쓸 수 없다 — 각 파일 안에 같은 매핑의 private 함수를 둔다 · 공용 파일로 옮기지 않는다)
 7 시계 = journalClockProvider(DateTime.now() 금지 — 주입 Clock.nowUtc() 만) · 공통 상태 = 스켈레톤(JournalSkeleton) · 에러 = JournalErrorView(onRetry: invalidate · lastAsOfLabel: valueOrNull?.asOf.label) ·
   오래됨 = JournalStaleBanner · 차단 = JournalSafetyBanners(safety: ref.watch(journalSafetyStateProvider).valueOrNull) — 🔴 .watchState( · FlagIds · activeFlags 0 · 플래그로 값을 바꾸지 않는다 ·
   🔴 로딩·에러 갈래에서는 배너를 그리지 않는다(구독마다 — detail · detail(pnl) · allocation · C4r3-1) · 🔴 next 의 로딩·에러 = 하단 줄 부재뿐(본문·배너 영향 0).
 8 공개 위젯은 본문만(Scaffold·AppBar·SafeArea·ScaffoldMessenger 금지 · 주석에도 이 낱말 0) · Row 안 엔진 문자열은 Expanded/Flexible · 말줄임·maxLines·trim·FittedBox 금지 · 390px overflow 0 · 글꼴 200% overflow 0 ·
   선 굵기·간격·크기는 정수·N.0·colorScheme 만(소수부 ≠ 0 소수 리터럴 0 — C-44 ⑲) · 띠 높이 예약 금지 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
 9 프로바이더는 넷만 더한다 — H6-2: _holdingDetailProvider(StreamProvider.family · 열쇠 = (String, bool) 레코드 = (holdingId, 손익 펼침)) ·
   H6-3: 주입 journalRebalanceRepositoryProvider(기본 throw UnimplementedError) + _allocationProvider(StreamProvider) + _nextRebalanceProvider(StreamProvider) · 🔴 각자 자기 화면 파일 안(아래 «주입 구조» 글자 그대로) ·
   autoDispose 0(정적 S15) · 🔴 주입 journalHoldingsRepositoryProvider 는 R4a 의 것을 import 해서 쓴다(새로 만들지 않는다 · holdings_overview.dart 를 고치지 않는다) ·
   기존 프로바이더(journalSafetyRepositoryProvider · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider)는 그대로 · 🔴 journalTimelineRepositoryProvider · journalConfigRepositoryProvider ·
   journalCommandApiProvider · journalDraftStoreProvider 0 · 주입은 탭 핸들러 안 ref.read · 데이터는 build 에서 ref.watch · 펼침 상태는 위젯 State 필드(전역 프로바이더 금지).
10 테스트 = 받침대 extends(UnimplementedHoldingsRepository · UnimplementedRebalanceRepository · R4a 의 FakeHoldingsSafetyRepository 재사용 — implements 금지) · 받은 인자 전부 기록 · 호출마다 새 Stream ·
   전제는 expect · 동작은 UI 를 실제로 눌러서 · 🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처에서 — 🔴 HoldingDetailVm(…) · SleeveAllocationVm(…) · NextRebalanceVm(…) 생성자 0) · copyWith 0(이 카드에는 허용 꼴이 없다) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 가짜의 호출 기록은 목록 == 목록(또는 수 == 수)으로(🔴 기록 목록에 hasLength 0) ·
   픽스처마다 갈리는 단언은 if/else **양쪽에** expect 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴 · 테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII(\u 이스케이프) ·
   «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2 · for (… in <T>[?x])·?.let 류로 감추는 것도 반려) · «… 0»·«… 1» 은 find.… 로 화면에서 센다 ·
   스켈레톤 1 = expect(find.byKey(const Key('h62-loading')), findsOneWidget) 꼴 · 테스트는 package:ui_journal/src/common/journal_common.dart 를 직접 import 해도 된다 ·
   Key 를 단 Text 는 그 글자 == 픽스처 필드까지 본다 · if/else 의 else 쪽 findsNothing 이 없으면 반려 · «<» 를 «<=» 로 · «N개» 를 greaterThanOrEqualTo 로 바꾸지 않는다 ·
   늦게 구독되거나 값을 끝까지 내지 않는 StreamController 의 teardown = addTearDown(() { unawaited(ctrl.close()); }).
   ⓡ = 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 한 줄 — 둘 다 도우미로 감싸지 않는다 · dart format 뒤에도 한 줄 ·
      정적 S23·S24 가 파일마다 git grep -c 로 센다 — 🔴 아래 최소 목록의 표시 수와 **정확히** 같아야 한다(holding_detail_test.dart ⓡ 10 · ⓗ 3 · holdings_allocation_test.dart ⓡ 13 · ⓗ 4 · 다르면 제출 전에 고친다 · 다른 채 내면 반려).
   «없는 쪽» 견본(코드 글자 · 이름은 재량):
        if (row.sleeveWeight != null) {
          expect(tester.widget<Text>(find.byKey(ValueKey<String>('h63-weight-$i'))).data, row.sleeveWeight!.label);
        } else {
          expect(find.byKey(ValueKey<String>('h63-weight-$i')), findsNothing);
        }
        🔴 반려 꼴: if (row.sleeveWeight != null) { expect(…); }(else 없음)
   🆕 «빈 문장» 견본(R4a C4a-5 — Key 를 단 빈 문장을 경우 표의 bool 칸(want ? findsOneWidget : findsNothing)만으로 보지 않는다 · 경우 표의 빈 칸 = 기대 글자 String? · 칸 이름은 재량):
        final String? wantEmpty = c.empty;   // 빈 갈래 = allocEmpty.emptyLabel · 그 밖 = null
        if (wantEmpty != null) {
          expect(tester.widget<Text>(find.byKey(const Key('h63-empty'))).data, wantEmpty);
        } else {
          expect(find.byKey(const Key('h63-empty')), findsNothing);
        }
   «화면의 Text 전부» 단언 = 이 코드 글자 꼴(T62-07 · T63-10 · C4d-1):
          final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
          expect(shown, isNotEmpty);
          for (final String? data in shown) {
            expect(data, isIn(allowed));
          }
        (allowed = null-aware 원소로 만든 Set<String> · RichText·SelectableText·Text.rich 는 두 화면 파일에 쓰지 않는다 = 정적 S27)
11 골든 = 새 PNG h62_* 8장 + h63_* 8장 · --update-goldens 는 그 골든 테스트 파일만 · 기존 PNG 재생성 0 · golden:approved 안 붙임 · 찍기 전 위치 전제 둘(맨 아래 위젯 dy < 높이 · 머리 dy == 0).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 ·
   패키지 테스트는 packages/ui_journal 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다.
   🔴 이 카드의 위험 = 잔고 막대 — r.deployedRatio · r.parkingRatio 를 지역 변수에 받을 때 **중립 이름**으로(final double? deployed = r.deployedRatio; · final double? parked = r.parkingRatio;) 받고 c.maxWidth * deployed 꼴로 쓴다 ·
   deployedRatio 같은 이름의 지역 변수·매개변수를 곱하면 C-4 실패 · ?? 0 대입 금지(C-44 ⑯) · pnl.pnlText · deployedPctText · avgPriceText 옆에 연산자 0 · 글자 잇기 0(라벨과 값은 Text 두 개).
14 모르는 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — 두 화면 파일과 labels.dart 새 절의 주석에 이 낱말을 쓰지 않는다: AppRoutes · AppLinkSchemes · journal_draft · journalHoldingsRepositoryProvider · journalRebalanceRepositoryProvider ·
   journalLinkOpenerProvider · watchHoldingDetail · watchAllocation · watchNext · includePnl · SleeveBandState. · GateState. · Navigator · DateTime.now · kIsWeb · Platform. · 'aaq:// · NumberFormat · Colors · Scaffold ·
   AppBar · SafeArea · SnackBar · autoDispose · RunMode · FeatureFlags · watchState · maxLines · TextOverflow · .trim( · .where · .contains( · Decimal · Money · holdingId · Ratio · Normalized · .quantity · .symbol · .sleeve(주석은 짧게).
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려**.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 열어 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모).
   🆕 PNG 는 이름마다 light 한 장만 연다(8장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · «띠»·«고정»·«스크롤 밖» · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지 · 버튼 = «버튼 글자») · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 줄 n» = PNG 의 글자 **행** 수(줄바꿈 포함) · «상자» = 테두리·모서리가 보이는 덩어리 · «배경 덩어리» = 폭 전체 배경 · «칩 n개» = 한 무리의 칩 개수 · «막대» = 가로로 긴 덩어리 · «점» = 막대 위의 작은 둥근 표식.
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 채팅으로만) · S05 결과 줄 = 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M6.md 159~168행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외).

■ 프롬프트보다 이 카드가 이긴다 — 20항 (prompt_M6.md 169줄 판)
 ① 2행 {{범위}} · 106행 «이번 과제 범위» → 이 카드의 범위 = H6-2 · H6-3(위 첫 줄) · ※ «첫 과제는 J-1 하나» 도 덮는다
 ② 104행 «H-1 … · H-2 종목 상세 · H-3 목표 대비 편차·밴드 여유» → 화면 ID = H6-1 · H6-2 · H6-3(01 §17-3)
 ③ 11행 의존 추가 → 없음 ④ 12~13행 «라우트 상수로 딥링크» → DTO 링크(entryDecisionLink · previewRoute · 체결 행·칩 링크)를 AppLinkOpener.open 에 · AppRoutes 상수 0
 ⑤ 19~21행 «허용되는 산술은 레이아웃 계산뿐 · 입력도 M2 가 준 0.0~1.0 정규값» → 그대로 유효 — × 폭만(SleeveBandGauge 네 값 · deployedRatio · parkingRatio · 규칙 5)
 ⑥ 21~23행 «건수 집계도 재계산» → 그대로 유효 ⑦ 28~30행 «목록이 비면 그 자리를 그리지 않는다» → stopLines 빈 = noStopLineText 한 줄 · recentEntries 빈 = recentEmptyLabel · stateChips 0 = 칩 줄 0 · rows 빈 = emptyLabel
 ⑧ 38~41행 자리표시자 → 링크 null = 부재 ⑨ 46·67행 띠 높이 → 예약 안 함 ⑩ 48~54행 수치·금액 리터럴 금지 → 그대로 유효(C-44 ⑲)
 ⑪ 58~61행 «슬리브 비중 = 회계 기준 · POT 는 A 소속 · 엔진 열은 C 에 합산 — 화면이 산술로 변환 금지» · «B 도달 두 지표 · 파킹을 미달·경고색으로 그리지 마라» → 그대로 유효 — POT = A 바로 뒤 들여쓰기 · 엔진 열 = engineColumnNote 한 줄(펼침) · 파킹 = 경고색 0
 ⑫ 88~90행 자체 점검·스크린샷·PR → «■ 제출» ②③ · PR 만들지 않음 ⑬ 93~94행 위조 → 그대로 유효 ⑭ 107~116행 읽을 문서·브랜치 예시·PR 제목 → 아래 «먼저 읽을 것» · 브랜치 ui/m6-h62-h63-holdings · PR 제목 «[M6] H6-2·H6-3 종목 상세·슬리브 비중»
 ⑮ 118~120행 기준일 고지 = AsOf.label → 그대로 유효(두 화면 머리 = vm.asOf.label) ⑯ 121~122행 ListResult 봉투 → 두 화면 모두 봉투 없는 VM(빈 = VM 의 emptyLabel·문장 필드 · «모름» = 스켈레톤·에러)
 ⑰ 124~125행 «watchHoldings() 기본 구독 includePnl: false» → H6-2 창구 = watchHoldingDetail(holdingId, includePnl: …) — 진입 false · 펼침 = true 재구독 · watchHoldings 0
 ⑱ 126~133행 «SAT 칸·TIER 위젯·손절선 카드는 숨김 · POT … ⚠️ SleeveAllocationRow 미정의 · B 계좌 잔고와 투자분 · SMA 3-트랜치는 상시 규칙 — «잔여 단계» 라벨 금지» →
    손절선 = 엔진이 준 글자 행만(0행이면 noStopLineText) · SleeveAllocationRow = 계약 v1.8 정의(고정 모드 아님) · 잔고 막대 = deployedRatio·parkingRatio × 폭 · 트랜치 = trancheStateText 그대로(«잔여» 류 화면 글자 0)
 ⑲ 155~157행 «⚠️ M2 미정의 7건(H-1/H-3 슬리브 배분 행 · H-2 손절선 정규값 …)» → 배분 행 = v1.8 정의 · 손절선 = 글자 행(정규값 = 미결 104 — 게이지를 그리지 않는다) · 지어낼 이름 없음
 ⑳ 158행 «명세 §7과 1:1» · 162~163행 자체 점검 4·5 → 159~168행 10항(5 «J-4» · 9 «부분 동기» 는 [x] + 괄호 «이 카드 범위 밖») · 97~99행 TODO 자리표시자 → 넣지 않는다 · 질문 파일로

■ 먼저 읽을 것 (🔴 03·04·05 명세는 읽지 않음 · 02 는 아래 ③ 의 자리만)
 ① prompt_M6.md 전문 ② 01 §17 — 17-1 · 17-4 · 17-6 · 17-7 · 17-8 · 17-10(⑥~⑰) · 17-16
 ③ 02 §4-2 «`H6-2` 종목 상세» · §4-3 «`H6-3` 슬리브·비중» + §4 끝 v1.8 블록(찾는 말 = «R4 범위 · 이 블록이 이긴다») ⓐ~ⓛ
 ④ packages/domain_contracts/lib/ — src/dto/holdings.dart(HoldingRow · TrancheStep · HoldingPnl · StopLineNormalized · HoldingDetailVm) · src/dto/rebalance.dart(SleeveWeight · SleeveAllocationRow · SleeveBandGauge · SleeveAllocationVm · NextRebalanceVm) ·
    src/enums/rebalance.dart(SleeveBandState) · src/dto/journal.dart(TradeJournalEntry — 읽기만) · src/dto/common.dart(ReasonChip · LinkAction · GateBadge) · src/enums/ui.dart(GateState) ·
    src/repositories/holdings_repository.dart · src/repositories/rebalance_repository.dart(watchNext) · testing.dart(UnimplementedHoldingsRepository · UnimplementedRebalanceRepository · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c44_holdings_test.dart 머리 주석 + «B. 정규식» 절(⑫~⑲ — 읽기만)
 ⑥ packages/ui_journal/test/golden/README.md «🆕 R4» 절 + «🆕 R3» · «🆕 R2» · «규칙»·«하네스» 절
 ⑦ 지금 코드(packages/ui_journal) — lib/ui_journal.dart · lib/l10n/labels.dart · lib/src/common/journal_common.dart 전문(JournalEntryCard 포함) · lib/src/holdings_overview.dart(R4a — 주입·family·State·행 모양의 원형 · 고치지 않는다) ·
    lib/src/timeline.dart 머리 40줄 + journalSafetyStateProvider · test/holdings_overview_fakes.dart · test/holdings_overview_test.dart · test/golden/h61_golden_test.dart(흐름 = 클로저 · 위치 전제 둘) · test/golden/golden_support.dart
 ⑧ packages/domain_contracts/fixtures/README.md «계약 v1.8» 절 + 아래 «픽스처» ⑨ docs/ai-context/inbox/README.md · H62H63_questions.md 머리말

■ 본받지 않는 것 — R4a 카드와 같다(배너 관용구 · .take(3)+«+n» · nullable 에 ! · FlutterError.reportError · implements 가짜 · 한국어 테스트 이름 · 조건부 단언) +
 · JournalEntryCard 안의 .take(3) 은 공통 위젯 몫이라 그대로 둔다(그 위젯을 고치지 않는다 · 이 카드의 화면 파일에는 .take 0)
 · H6-1 의 private 함수를 import 하려고 holdings_overview.dart 의 이름을 공개로 바꾸지 않는다(각 파일 안 private 복사)

■ 주입 구조 (이름·타입 고정 = 01 §17-8 · 설계서 §2-5 글자 그대로 · 계약 변경 없음)
· 재사용: journalHoldingsRepositoryProvider(holdings_overview.dart · R4a — import 'holdings_overview.dart';) · timeline.dart 의 journalSafetyRepositoryProvider · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider /
  journal_common.dart: JournalAsOfHeader · JournalStaleBanner · JournalReasonChip · JournalEntryCard · JournalSkeleton · JournalErrorView · JournalSafetyBanners(🔴 무수정) / labels.dart: retry · staleBannerTitle · holdingsAvgPrice · holdingsEntryDate(R4a · 고치지 않는다).
· 🆕 lib 파일 2개 — lib/src/holding_detail.dart(H6-2) · lib/src/holdings_allocation.dart(H6-3)(이것 말고 새 lib 파일 0 · lib/src/holdings/ 폴더 0 · 조각은 각 파일 안 private).
  import(두 파일 같은 꼴 · directives_ordering · 쓰지 않는 import = analyze 실패):
     import 'package:domain_contracts/domain_contracts.dart'; → import 'package:flutter/material.dart'; → import 'package:flutter_riverpod/flutter_riverpod.dart'; →
     import '../l10n/labels.dart'; → import 'common/journal_common.dart'; → import 'holdings_overview.dart'; → import 'timeline.dart';
  H6-2 프로바이더 — holding_detail.dart 머리(이름·타입 고정 · 줄 배치는 dart format 결과):
    /// H6-2 보유 1건 — 열쇠 = (보유 id, 손익 펼침 여부).
    final _holdingDetailProvider = StreamProvider.family<HoldingDetailVm, (String, bool)>(
      (Ref ref, (String, bool) key) => ref
          .watch(journalHoldingsRepositoryProvider)
          .watchHoldingDetail(key.$1, includePnl: key.$2),
    );
  H6-3 프로바이더 셋 — holdings_allocation.dart 머리:
    /// H6-3 하단 다음 회차 창구 주입 — 조립 앱 3종이 override 한다(01 §17-8).
    final journalRebalanceRepositoryProvider = Provider<RebalanceRepository>(
      (Ref ref) => throw UnimplementedError(
        'journalRebalanceRepositoryProvider must be overridden',
      ),
    );

    /// H6-3 배분 행 전부(회계 기준) — 인자 없이.
    final _allocationProvider = StreamProvider<SleeveAllocationVm>(
      (Ref ref) => ref.watch(journalHoldingsRepositoryProvider).watchAllocation(),
    );

    /// H6-3 하단 — 다음 회차(D-day · 예정 없음).
    final _nextRebalanceProvider = StreamProvider<NextRebalanceVm>(
      (Ref ref) => ref.watch(journalRebalanceRepositoryProvider).watchNext(),
    );
  🔴 H6-2 가 부르는 창구 = watchHoldingDetail 하나 · H6-3 = watchAllocation · watchNext 둘 · autoDispose 0 · 주입 새로 1개(journalRebalanceRepositoryProvider).
  🔵 Provider<RebalanceRepository> 줄은 계약 테스트 C-40 ⑧ 보강(카드 머리 «선행 2») 뒤에만 통과한다 — 0단계의 C-40 확인 줄이 그것을 본다(보강 전이면 0단계에서 멈춘다).
· 🆕 공개 위젯 — class HoldingDetail extends ConsumerStatefulWidget { const HoldingDetail({super.key, required this.holdingId}); final String holdingId; }(State = bool _pnlOpen = false) ·
  class HoldingsAllocation extends ConsumerStatefulWidget { const HoldingsAllocation({super.key}); }(State = final Map<int, bool> _noteOpen = <int, bool>{})
· 배럴 lib/ui_journal.dart 에 export 두 줄 — export 'src/holding_detail.dart'; · export 'src/holdings_allocation.dart'; —
  🔴 자리 = export 'src/decision_detail.dart'; 줄과 export 'src/holdings_overview.dart'; 줄 **사이**에 이 차례로(holding_detail → holdings_allocation → holdings_overview · 끝에 두면 directives_ordering 린트 실패 · 드라이런 analyze 로 확인한 차례 그대로).

■ 픽스처 (FixturePaths.… · singleFixture(<경로>, HoldingDetailVm.fromJson / SleeveAllocationVm.fromJson / NextRebalanceVm.fromJson) · safetyFixtureRow(n) · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 withStops   m6HoldingDetailWithStops — A 069500 · stopLines 1(TIER_1B · isActive true · 🔵 보존 경로 표본 — 골든 아님 · 테스트만) · noStopLineText null · recentEntries 3(시간 역순 · 행마다 detailDeepLink) · recentEmptyLabel null · pnlToggleLabel 있음
 noStop      m6HoldingDetailNoStop — B 133690 · holding.pendingText «반영 대기 +12주» · 트랜치 3단계 · stopLines 0 + noStopLineText · recentEntries 0 + recentEmptyLabel · pnl 없음
 pnl         m6HoldingDetailPnl — noStop 과 같고 holding.pnl(pnlText · pnlPctText · disclosureNote)
 recon       m6HoldingDetailRecon — noStop 과 같고 holding.quantityText·weightText·pendingText 끝 «?»
 integrity   m6HoldingDetailIntegrity — withStops 의 가림판(holding 글자 «숨김» · pendingText null · sma_tranches 빈 · stopLines[0].levelText·basisLabel «숨김» · recentEntries 2(가림 원천 행))
 inBand      m6AllocationInBand — 5행 A → POT(parentSleeve A) → B → C → CASH · 밴드 행 = B 만(sleeveWeight · bandState IN_BAND · gauge) · 그 밖 = bandNoteText · A·POT 행 engineColumnNote 있음 · stateChips 0 · noticeText 있음
 outOfBand   m6AllocationOutOfBand — inBand 에서 B = OUT_OF_BAND(게이지 실제 > 상단)
 tranche     m6AllocationTrancheProgress — B = NEAR_EDGE · A 행 stateChips 1(F1_ENTRY_DEFER · handbook 링크)
 parking     m6AllocationParkingLarge — B = IN_BAND · parkingRatio 큼 · parkingNoteText «… 미달이 아닙니다»(🔴 경고색 아님)
 allocInteg  m6AllocationIntegrity — 전 행 sleeveWeight·bandState·gauge·두 비율 null · 금액·%·트랜치·bandNoteText 글자 «숨김»
 allocRecon  m6AllocationRecon — inBand 의 B 행 금액·%·sleeveWeight.label 끝 «?» · 기하·bandState 유지
 allocEmpty  m6AllocationEmpty — rows 0 · emptyLabel 있음 · noticeText null
 countdown   m7M7NextRebalanceCountdown — expectedDateText · dDayText · previewRoute 있음 · emptyLabel null
 none        m7M7NextRebalanceNone — emptyLabel 만(previewRoute null)
 안전        safetyFixtureRow(n) — 0 정상 · 3 차단 2(RECON_MISMATCH · JOURNAL_MISSING) · 4 무결성(LEDGER_INTEGRITY)
 쓰지 않는 것: holdings_6 · m6/holdings_overview_*(R4a) · m6/entry_gate_nov_pass_1 · m6/external_holdings_2 · m7/realized_alloc_S7 · journal_30(체결 행은 VM 안에 이미 있다).
 🔴 픽스처끼리 이어 붙인 시나리오 금지 · copyWith 0 · «내 픽스처» 금지 · 모자라면 질문 파일에.

■ 화면 1 — H6-2 HoldingDetail (01 §17-6 · 17-7 · 02 §4 v1.8 블록 ⓐⓓⓗⓘⓙ)
 상태 표(구독마다 — C4r3-1): detail(false) 첫 값 전 → JournalSkeleton(key: const Key('h62-loading'))(배너 0 · 6장 = 공통 위젯 그대로) · detail 에러(모르는 id 포함 — 잠정) → JournalErrorView(key: const Key('h62-fail') · 재시도 = 같은 열쇠 invalidate · 배너 0) ·
   detail 값 → 정상 갈래(가림 포함) · 손익 펼침(true) 첫 값 전 · 에러 → 위와 같다(열쇠 = (id, true) · 배너 0) · safety → 배너만. (빈 갈래 없음 — 1건 · 손절선만 noStopLineText · 이력만 recentEmptyLabel)
 배치(정상 갈래 · 위 → 아래 · 🔴 이 순서):
   ListView[
    1 JournalAsOfHeader(key: const Key('h62-asof'), asOf: vm.asOf)
    2 (오래됐으면) JournalStaleBanner(asOf: vm.asOf)
    3 JournalSafetyBanners(safety: safety)
    4 Padding(Text(vm.sleeveLabel, key: const Key('h62-sleeve')))
    5 Padding(key: const Key('h62-summary'), Column[            ← 🔴 아래 Text 순서 = 테스트 도우미 holdingDetailSummaryTexts 의 순서(R4a 행과 같고 손익 줄이 없다)
        Text(h.symbolLabel)
        Wrap[ Text(h.quantityText) · (pending != null) Chip(key: const Key('h62-pending'), label: Text(pending)) · (subBook != null) Chip(key: const Key('h62-subbook'), label: Text(subBook)) ]
        Row[ Text(JournalLabels.holdingsAvgPrice) · SizedBox(width: 6) · Flexible(Text(h.avgPriceText)) ]
        Row[ Text(JournalLabels.holdingsEntryDate) · SizedBox(width: 6) · Flexible(Text(h.entryDate.yyyyMmDd)) ]
        Text(h.weightText)
        Wrap[ for (final ReasonChip chip in h.entryReasons) JournalReasonChip(chip: chip) ]
        Wrap[ for (final TrancheStep step in h.smaTranches) Chip(avatar: Icon(step.filled ? Icons.check_circle : Icons.radio_button_unchecked, size: 16), label: Text(step.label)) ]
        Wrap[ for (final GateBadge gate in h.gates) Chip(avatar: Icon(_gateIcon(gate.state), size: 16), label: Text(gate.label)) ] ])
    6 (toggleLabel != null) Padding(TextButton.icon(key: const Key('h62-pnl-toggle'), onPressed: () { setState(() { _pnlOpen = !_pnlOpen; }); }, icon: Icon(_pnlOpen ? Icons.expand_less : Icons.expand_more), label: Text(toggleLabel)))
      ← 뷰어(K15 · toggleLabel null) = H6-2 표본 없음(5벌 모두 «종목 손익») — 정적 검토만
    7 (pnl != null) Padding(key: const Key('h62-pnl'), Column[ Text(pnl.pnlText) · Text(pnl.pnlPctText) · Text(pnl.disclosureNote) ])     ← final HoldingPnl? pnl = h.pnl;(데이터로만 열린다)
    8 Padding(OutlinedButton(key: const Key('h62-entry-link'), onPressed: () { ref.read(journalLinkOpenerProvider).open(vm.entryDecisionLink.deepLink); }, child: Text(vm.entryDecisionLink.label)))   ← 늘(K16 ⓔ · required)
    9 Padding(Text(JournalLabels.holdingsStopLines))
   10 for (final (int i, StopLineNormalized s) in vm.stopLines.indexed) Padding(key: ValueKey<String>('h62-stop-$i'), Column[
        Text(s.tierLabel, style: TextStyle(fontWeight: s.isActive ? FontWeight.bold : FontWeight.normal)) · Text(s.levelText) · Text(s.basisLabel) ])
   11 (noStop != null) Padding(Text(noStop, key: const Key('h62-no-stop')))                         ← final String? noStop = vm.noStopLineText;
   12 Padding(Text(JournalLabels.holdingsRecentEntries))
   13 for (final (int k, TradeJournalEntry e) in vm.recentEntries.indexed) JournalEntryCard(key: ValueKey<String>('h62-entry-$k'), entry: e)   ← 탭 = 그 행 detailDeepLink(JournalEntryCard 안)
   14 (recentEmpty != null) Padding(Text(recentEmpty, key: const Key('h62-recent-empty')))            ← final String? recentEmpty = vm.recentEmptyLabel;
   ]
   ← final HoldingRow h = vm.holding; final String? pending = h.pendingText; final String? subBook = h.subBookLabel; final String? toggleLabel = vm.pnlToggleLabel;
 코드 스케치: build = R4a 와 같은 꼴 — final bool pnlOpen = _pnlOpen; final AsyncValue<HoldingDetailVm> detail = ref.watch(_holdingDetailProvider((widget.holdingId, pnlOpen)));
   detail.when(loading: () => const JournalSkeleton(key: Key('h62-loading')), error: (Object e, StackTrace s) => JournalErrorView(key: const Key('h62-fail'), lastAsOfLabel: detail.valueOrNull?.asOf.label,
     onRetry: () => ref.invalidate(_holdingDetailProvider((widget.holdingId, pnlOpen)))), data: (HoldingDetailVm vm) => _buildBody(vm, clock, safety)) · _gateIcon = R4a 와 같은 GateState switch(private 복사).
   🔴 손절선까지 남은 %·폭 · 게이지 0 · momentum 0 · holding.detailDeepLink 0(자기 자신) · 이력 정렬·거르기 0.

■ 화면 2 — H6-3 HoldingsAllocation (01 §17-6 · 17-7 · 02 §4 v1.8 블록 ⓐⓑⓓⓕ)
 상태 표(구독마다 — C4r3-1): allocation 첫 값 전 → JournalSkeleton(key: const Key('h63-loading'))(배너·하단 0 · 6장) · allocation 에러 → JournalErrorView(key: const Key('h63-fail') · 재시도 = invalidate(_allocationProvider) · 배너·하단 0) ·
   allocation 값 · rows 빈 → 빈 갈래(머리 + 오래됨 + 배너 + emptyLabel + 하단) · rows 있음 → 정상 갈래(가림 포함) · next 첫 값 전 · 에러 → 하단 줄 부재(본문·배너 영향 0) · next 값 → 하단 · safety → 배너만.
 배치(정상 갈래 · 위 → 아래 · 🔴 이 순서):
   ListView[
    1 JournalAsOfHeader(key: const Key('h63-asof'), asOf: vm.asOf) · 2 (오래됐으면) JournalStaleBanner(asOf: vm.asOf) · 3 JournalSafetyBanners(safety: safety)
    4 (notice != null) Padding(Text(notice, key: const Key('h63-notice')))                           ← final String? notice = vm.noticeText;
    5 for (final (int i, SleeveAllocationRow r) in vm.rows.indexed) 행 i(아래)
    6 하단(아래 · next 값이 있을 때만 · 로딩·에러 = const SizedBox.shrink())
   ]
 행 i(🔴 아래 Text 순서 = 테스트 도우미 allocationRowTexts 의 순서 · 들여쓰기 = 왼쪽 여백만 바꾼다):
   Padding(key: ValueKey<String>('h63-row-$i'), padding: EdgeInsets.fromLTRB(r.parentSleeve == null ? 16 : 40, 8, 16, 8), child: Column(crossAxisAlignment: start)[
     Row[ Expanded(Text(r.sleeveLabel, key: ValueKey<String>('h63-label-$i'))) · (note != null) IconButton(key: ValueKey<String>('h63-note-toggle-$i'), onPressed: () { setState(() { _noteOpen[i] = !open; }); }, icon: Icon(open ? Icons.expand_less : Icons.expand_more)) ]
     (w != null) Text(w.label, key: ValueKey<String>('h63-weight-$i'), style: textTheme.titleMedium)                   ← final SleeveWeight? w = r.sleeveWeight;
     (bandNote != null) Text(bandNote, key: ValueKey<String>('h63-band-note-$i'))                                     ← final String? bandNote = r.bandNoteText;
     (state != null && stateLabel != null) Row[ Icon(Icons.circle, size: 12, color: _bandColor(context, state)) · SizedBox(width: 6) · Expanded(Text(stateLabel, key: ValueKey<String>('h63-state-$i'))) ]
     (g != null && state != null) SizedBox(key: ValueKey<String>('h63-gauge-$i'), width: double.infinity, height: 16, child: CustomPaint(painter: _GaugePainter(gauge: g, colors: cs, mark: _bandColor(context, state))))
     (deployed != null && parked != null) SizedBox(key: ValueKey<String>('h63-bar-$i'), height: 8, child: LayoutBuilder(builder: (BuildContext context, BoxConstraints c) => Row[
        SizedBox(width: c.maxWidth * deployed, height: 8, child: ColoredBox(color: cs.primary)) · SizedBox(width: c.maxWidth * parked, height: 8, child: ColoredBox(color: cs.outlineVariant)) ]))
        ← 🔴 안쪽 SizedBox 에도 height: 8(없으면 자식 없는 ColoredBox 의 높이가 0 이라 막대가 안 보인다)
     Row[ Text(JournalLabels.holdingsDeployed) · SizedBox(width: 6) · Flexible(Text(r.deployedText)) · SizedBox(width: 6) · Flexible(Text(r.deployedPctText)) ]
     Row[ Text(JournalLabels.holdingsParking) · SizedBox(width: 6) · Flexible(Text(r.parkingText)) · SizedBox(width: 6) · Flexible(Text(r.parkingPctText)) ]
     Text(r.trancheStateText)
     (parkingNote != null) Text(parkingNote)                                                                            ← final String? parkingNote = r.parkingNoteText;
     Wrap(spacing: 6, runSpacing: 4)[ for (final ReasonChip chip in r.stateChips) JournalReasonChip(chip: chip) ]
     (open && note != null) Text(note, key: ValueKey<String>('h63-note-$i'))                                         ← final String? note = r.engineColumnNote; final bool open = _noteOpen[i] ?? false;
   ])
   ← final double? deployed = r.deployedRatio; final double? parked = r.parkingRatio; final SleeveBandGauge? g = r.gauge; final SleeveBandState? state = r.bandState; final String? stateLabel = r.bandStateLabel;
      final ColorScheme cs = Theme.of(context).colorScheme;(🔴 지역 변수 이름에 ratio·pct 금지 — 규칙 13)
 게이지(private 클래스 · 이 모양 그대로 · 색은 재량이지만 colorScheme 만):
   class _GaugePainter extends CustomPainter {
     _GaugePainter({required this.gauge, required this.colors, required this.mark});
     final SleeveBandGauge gauge; final ColorScheme colors; final Color mark;
     @override
     void paint(Canvas canvas, Size size) {
       final double w = size.width;
       canvas.drawRect(Offset.zero & size, Paint()..color = colors.surfaceContainerHighest);
       canvas.drawRect(Rect.fromLTRB(w * gauge.bandLowNormalized, 0, w * gauge.bandHighNormalized, size.height), Paint()..color = colors.secondaryContainer);
       canvas.drawRect(Rect.fromLTWH(w * gauge.targetNormalized, 0, 2, size.height), Paint()..color = colors.outline);
       canvas.drawCircle(Offset(w * gauge.actualNormalized, size.height / 2), 6, Paint()..color = mark);
     }
     @override
     bool shouldRepaint(_GaugePainter old) => old.gauge != gauge || old.mark != mark || old.colors != colors;
   }
   ← 🔴 × 폭 말고 다른 산술 0(밴드 음영 = 두 끝을 각각 × 폭 · 표식 가운데 맞춤 빼기 0 · 차·여유 0) · 게이지와 잔고 막대는 다른 막대다(두 값을 한 식에서 곱하지 않는다 · C-44 ⑯).
 하단(next 값 n · 🔴 «둘 다 null» 은 계약 상태가 아니다 — C-41 ③ · 각각 null 검사):
   Padding(key: const Key('h63-next'), child: InkWell(onTap: route == null ? null : () { ref.read(journalLinkOpenerProvider).open(route); }, child: Wrap(spacing: 8, runSpacing: 4)[
     (dDay != null) const Text(JournalLabels.holdingsNextRebalance) · (date != null) Text(date) · (dDay != null) Text(dDay) · (empty != null) Text(empty) ]))
   ← final String? empty = n.emptyLabel; final String? date = n.expectedDateText; final String? dDay = n.dDayText; final String? route = n.previewRoute;
 배치(빈 갈래 · rows 빈): ListView[ JournalAsOfHeader(key: const Key('h63-asof'), asOf: vm.asOf) · (오래됐으면) JournalStaleBanner · JournalSafetyBanners ·
   (label != null) Padding(padding: EdgeInsets.all(16), Text(label, key: const Key('h63-empty'))) · 하단 ]      ← final String? label = vm.emptyLabel;
 코드 스케치: build — final AsyncValue<SleeveAllocationVm> alloc = ref.watch(_allocationProvider); final AsyncValue<NextRebalanceVm> next = ref.watch(_nextRebalanceProvider);
   alloc.when(loading: () => const JournalSkeleton(key: Key('h63-loading')), error: … JournalErrorView(key: const Key('h63-fail'), lastAsOfLabel: alloc.valueOrNull?.asOf.label, onRetry: () => ref.invalidate(_allocationProvider)),
     data: (SleeveAllocationVm vm) => vm.rows.isEmpty ? _buildEmpty(vm, next, clock, safety) : _buildBody(vm, next, clock, safety)) ·
   하단 위젯 = next.when(loading: () => const SizedBox.shrink(), error: (Object e, StackTrace s) => const SizedBox.shrink(), data: (NextRebalanceVm n) => <하단>) · _bandColor = R4a 와 같은 SleeveBandState switch(private 복사).
 🔴 갈래를 고르는 것은 AsyncValue · rows 빈 여부 · _pnlOpen · _noteOpen · null 여부 · bandState(색) · GateState(아이콘) · step.filled · s.isActive(굵기) 뿐 — 글자 비교·«?» 검사·SleeveId·플래그로 고르지 않는다.

■ Key 표 (h62- 14이름 · h63- 15이름 — 정본 = 이 표 · 🔴 표 밖 Key 0 · 영어 색·테마 낱말 0 · holdingId·symbol 0 — 순번만)
   h62-loading · h62-fail · h62-asof · h62-sleeve(Text sleeveLabel) · h62-summary(Padding 요약) · h62-pending(Chip · 있을 때만) · h62-subbook(Chip · 있을 때만) · h62-pnl-toggle(TextButton.icon · 있을 때만) ·
   h62-pnl(Padding 손익 · 있을 때만) · h62-entry-link(OutlinedButton · 늘) · h62-stop-$i(Padding 손절선 행) · h62-no-stop(Text · 있을 때만) · h62-entry-$k(JournalEntryCard) · h62-recent-empty(Text · 있을 때만)
   h63-loading · h63-fail · h63-asof · h63-notice(Text · 있을 때만) · h63-empty(Text · 빈 갈래) · h63-row-$i(Padding 행) · h63-label-$i(Text sleeveLabel) · h63-weight-$i(Text · 있을 때만) · h63-band-note-$i(Text · 있을 때만) ·
   h63-state-$i(Text · 있을 때만) · h63-gauge-$i(SizedBox 게이지 · 있을 때만) · h63-bar-$i(SizedBox 잔고 막대 · 있을 때만) · h63-note-toggle-$i(IconButton · engineColumnNote 있을 때만) · h63-note-$i(Text · 펼침일 때만) · h63-next(Padding 하단 · next 값)
   (요약·행 안 그 밖의 Text · 칩 · 배지 · 절 머리 · 배너에는 Key 를 달지 않는다)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 그 커밋 내용 · 🔴 amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일)
 (1) 정적 라벨 5개(labels.dart 끝 R4b 절). 커밋 «[M6] R4b (1) 정적 라벨 5»
 (2) lib/src/holding_detail.dart + 배럴 한 줄 + test/holding_detail_fakes.dart + test/holding_detail_test.dart(T62-01~T62-10). 🔴 커밋 전에 git add . 뒤 «정적 묶음» 미리 돌리기. 커밋 «[M6] R4b (2) H6-2 종목 상세 화면 + 테스트»
 (3) lib/src/holdings_allocation.dart + 배럴 한 줄 + test/holdings_allocation_fakes.dart + test/holdings_allocation_test.dart(T63-01~T63-14). 🔴 같은 미리 돌리기. 커밋 «[M6] R4b (3) H6-3 슬리브·비중 화면 + 테스트»
 (4) 골든 16장 — test/golden/h62_golden_test.dart(8) · test/golden/h63_golden_test.dart(8). 커밋 «[M6] R4b (4) 골든 h62_* 8장 · h63_* 8장»
 (5) melos.bat run format:fix · 질문 파일(H62H63_questions.md — dy 측정 행 A1~A8 · 그 밖의 질문). 커밋 «[M6] R4b (5) format · 질문». 🔴 (5) 뒤 커밋 0(예외 = 사전검사 ① 🔴 수정 커밋 (6)).

■ 정적 라벨 — JournalLabels 끝(R4a 절 holdingsRegisteredOn 뒤)에 절 주석(// ── 🆕 R4b — H6-2 종목 상세 · H6-3 슬리브·비중 ──…)과 함께 5개(이름·글자 고정 · doc 주석에 «holdings» 낱말 0 — 정적 S26):
   holdingsStopLines = '손절선' · holdingsRecentEntries = '최근 체결' · holdingsDeployed = '투자분' · holdingsParking = '파킹' · holdingsNextRebalance = '다음 리밸런싱'
   🔴 만들지 않는 글자(엔진 몫): 슬리브 글자 · 손절선 등급·수준·기준 글자 · «개별 손절선을 쓰지 않습니다» · «최근 체결이 없습니다» · «매수 결정 보기» · «종목 손익» · 밴드 문장·«밴드 내»·«이탈» · «해당 없음» · 트랜치 문장 ·
      파킹 문장 · 보류 칩 · 엔진 열 안내 · 회계 기준 고지 · 날짜·«D-1» · «예정된 … 없습니다» · «배분 현황이 없습니다» · «숨김» · «?» · «원»·«%». 라벨 글자에 숫자·금액 0(C-32). 더 필요하면 질문 파일에(새 라벨 5개로 고정).

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 는 정적 S23·S24 와 대조)
공통: 띄우기 = pumpHoldingDetail · pumpHoldingsAllocation(뷰포트 Size(390, 4000) + DPR 1.0 + teardown 2 · 글꼴 1.0 내용 끝 = H6-2 1400 안 · H6-3 1100 안(재드라이런 골든 dy 최대 1340 · 1056 — 참고값 · 간격 재량으로 달라도 된다 · 🔵 h63 여유 44 — 넘으면 멈추고 dy 를 질문 파일에)) · 가짜 = 받침대 extends · 받은 인자 전부 기록 · 호출마다 새 Stream ·
  시계 = FixedClock(kGoldenNowUtc)(오래됨 = +2일) · 안전 기본 = safetyFixtureRow(0) · 기대 글자는 픽스처에서 · 띄운 뒤 await tester.pump(); 한 번 더 ·
  경우가 여럿인 테스트 = for 로 testWidgets 를 경우마다(이름 '<번호> <설명> <경우>') · 경우의 흐름 = 클로저 칸(Future<void> Function(WidgetTester) steps — bool 칸 + if 금지 · C4r3-4) · 띄우기는 한 테스트에 한 번(예외 = T62-04 재진입).
  계획 = H6-2 뷰 21(T62-01 1 · 02 1 · 03 1 · 04 1 · 05 1 · 06 1 · 07 2 · 08 7 · 09 3 · 10 2 · 11 1) · H6-3 뷰 29(T63-01 1 · 02 3 · 03 1 · 04 1 · 05 1 · 06 1 · 07 1 · 08 1 · 09 2 · 10 2 · 11 10 · 12 2 · 13 2 · 14 1) ·
    testWidgets 줄 11 + 14(드라이런 «+21» · «+29»).
  import(directives_ordering · 파일마다 이 줄 그대로 = 드라이런 analyze «No issues found!» 로 확인한 목록 · 🔴 holdings_overview_fakes.dart 를 빼면 holdingsShownTexts·holdingsChipIcon 이 «undefined»):
     test/holding_detail_test.dart(11줄) = 'dart:async' → 'package:domain_contracts/domain_contracts.dart' → 'package:domain_contracts/testing.dart' → 'package:flutter/material.dart' →
        'package:flutter_riverpod/flutter_riverpod.dart' → 'package:flutter_test/flutter_test.dart' → 'package:ui_journal/src/common/journal_common.dart' → 'package:ui_journal/ui_journal.dart' →
        'golden/golden_support.dart' → 'holding_detail_fakes.dart' → 'holdings_overview_fakes.dart'
     test/holdings_allocation_test.dart(10줄) = 위에서 flutter_riverpod 를 뺀 것(Override·ProviderScope 를 쓰지 않는다 — 넣으면 unused_import) · 끝 두 줄 = 'holdings_allocation_fakes.dart' → 'holdings_overview_fakes.dart'
  🆕 test/holding_detail_fakes.dart(새 파일 · 공개 이름 · 한국어 리터럴 0 · if 0 · collection-if 0 · import = domain_contracts · testing · flutter/material · flutter_riverpod · flutter_test · ui_journal · 'golden/golden_support.dart' · 'holdings_overview_fakes.dart'):
    class FakeHoldingDetailRepository extends UnimplementedHoldingsRepository {
      FakeHoldingDetailRepository({required this.detail});
      final Stream<HoldingDetailVm> Function(String holdingId, bool includePnl, int call) detail;
      final List<(String, bool)> calls = <(String, bool)>[];
      @override
      Stream<HoldingDetailVm> watchHoldingDetail(String holdingId, {bool includePnl = false}) { final int call = calls.length; calls.add((holdingId, includePnl)); return detail(holdingId, includePnl, call); }
    }
    FakeHoldingDetailRepository fakeHoldingDetail(HoldingDetailVm closed, HoldingDetailVm open) =>
        FakeHoldingDetailRepository(detail: (String id, bool includePnl, int call) => Stream<HoldingDetailVm>.value(includePnl ? open : closed));
    List<Override> holdingDetailOverrides({required FakeHoldingDetailRepository repo, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
        ← journalHoldingsRepositoryProvider · journalSafetyRepositoryProvider(FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)) — R4a 가짜 재사용) · journalClockProvider · journalLinkOpenerProvider
    Future<void> pumpHoldingDetail(WidgetTester tester, {required List<Override> overrides, required String holdingId, Key? screenKey})   ← 390×4000 · DPR 1 · teardown 2 · HoldingDetail(key: screenKey, holdingId: holdingId) · pump 1번
    Future<void> tapHoldingDetailPnlToggle(WidgetTester tester)            ← Key('h62-pnl-toggle') → ensureVisible → tap → pump 두 번
    List<String> holdingDetailSummaryTexts(HoldingRow h) => <String>[ h.symbolLabel, h.quantityText, ?h.pendingText, ?h.subBookLabel, JournalLabels.holdingsAvgPrice, h.avgPriceText,
        JournalLabels.holdingsEntryDate, h.entryDate.yyyyMmDd, h.weightText, for (final ReasonChip c in h.entryReasons) c.label, for (final TrancheStep s in h.smaTranches) s.label, for (final GateBadge g in h.gates) g.label ];
    List<String> holdingDetailStopTexts(StopLineNormalized s) => <String>[ s.tierLabel, s.levelText, s.basisLabel ];
    Set<String> holdingDetailAllowed(HoldingDetailVm v) => <String>{ v.asOf.label, v.sleeveLabel, ...holdingDetailSummaryTexts(v.holding), ?v.pnlToggleLabel, ?v.holding.pnl?.pnlText, ?v.holding.pnl?.pnlPctText,
        ?v.holding.pnl?.disclosureNote, v.entryDecisionLink.label, JournalLabels.holdingsStopLines, for (final StopLineNormalized s in v.stopLines) ...holdingDetailStopTexts(s), ?v.noStopLineText,
        JournalLabels.holdingsRecentEntries, ?v.recentEmptyLabel };      ← 최근 체결 행(JournalEntryCard)의 글자는 넣지 않는다 — T62-07 은 체결 0 표본만 본다
    (holdingsShownTexts(tester, key) · holdingsChipIcon(tester, scope, label) 은 R4a 의 holdings_overview_fakes.dart 것을 import 해서 쓴다 — 새로 만들지 않는다)
  🆕 test/holdings_allocation_fakes.dart(같은 규칙 · import 끝 = 'golden/golden_support.dart' · 'holdings_overview_fakes.dart'):
    class FakeAllocationRepository extends UnimplementedHoldingsRepository {
      FakeAllocationRepository({required this.allocation});
      final Stream<SleeveAllocationVm> Function(int call) allocation;
      int calls = 0;
      @override
      Stream<SleeveAllocationVm> watchAllocation() { final int call = calls; calls = calls + 1; return allocation(call); }
    }
    class FakeNextRebalanceRepository extends UnimplementedRebalanceRepository {
      FakeNextRebalanceRepository({required this.next});
      final Stream<NextRebalanceVm> Function(int call) next;
      int calls = 0;
      @override
      Stream<NextRebalanceVm> watchNext() { final int call = calls; calls = calls + 1; return next(call); }
    }
    List<Override> holdingsAllocationOverrides({required FakeAllocationRepository holdings, required FakeNextRebalanceRepository rebalance, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
        ← journalHoldingsRepositoryProvider(holdings) · journalRebalanceRepositoryProvider(rebalance) · journalSafetyRepositoryProvider(FakeHoldingsSafetyRepository(…)) · journalClockProvider · journalLinkOpenerProvider
    Future<void> pumpHoldingsAllocation(WidgetTester tester, {required List<Override> overrides})   ← 390×4000 · DPR 1 · teardown 2 · const HoldingsAllocation() · pump 1번
    Future<void> openAllocationNote(WidgetTester tester, int i)            ← ValueKey<String>('h63-note-toggle-$i') → ensureVisible → tap → pump
    List<String> allocationRowTexts(SleeveAllocationRow r) => <String>[ r.sleeveLabel, ?r.sleeveWeight?.label, ?r.bandNoteText, ?r.bandStateLabel, JournalLabels.holdingsDeployed, r.deployedText, r.deployedPctText,
        JournalLabels.holdingsParking, r.parkingText, r.parkingPctText, r.trancheStateText, ?r.parkingNoteText, for (final ReasonChip c in r.stateChips) c.label ];   ← 펼침 전(엔진 열 글자 없음)
    List<String> nextRebalanceTexts(NextRebalanceVm n) => <String>[ ?(n.dDayText == null ? null : JournalLabels.holdingsNextRebalance), ?n.expectedDateText, ?n.dDayText, ?n.emptyLabel ];
    Set<String> allocationAllowed(SleeveAllocationVm v, NextRebalanceVm n) => <String>{ v.asOf.label, ?v.noticeText, ?v.emptyLabel, for (final SleeveAllocationRow r in v.rows) ...<String>[...allocationRowTexts(r), ?r.engineColumnNote], ...nextRebalanceTexts(n) };
  파일 머리(main() 안)에서 픽스처를 한 번 읽는다(위 «픽스처» 의 이름) · Stream<T> valueThenFail<T>(T v) async* { yield v; throw StateError('fail'); } 를 두 테스트 파일에 각각(지역 함수 선언).
H6-2 — test/holding_detail_test.dart
 T62-01 진입 · 요약 · 링크(수용 (c) · K7 · K16 ⓔ) — repo = fakeHoldingDetail(noStop, pnl) · id = noStop.holding.holdingId · pumpHoldingDetail(holdingId: id) →
        expect(repo.calls, <(String, bool)>[(id, false)]) · holdingsShownTexts(Key('h62-asof')) == [noStop.asOf.label] · h62-sleeve data == noStop.sleeveLabel ·
        holdingsShownTexts(Key('h62-summary')) == holdingDetailSummaryTexts(noStop.holding) · 반영 대기 칩 = if/else 짝(pendingText · h62-pending) · 하위 칩 = 같은 꼴(subBookLabel · h62-subbook) ·
        칩 아이콘 = final Finder summary = find.byKey(const Key('h62-summary')); → for (s in noStop.holding.smaTranches) expect(holdingsChipIcon(tester, summary, s.label), s.filled ? Icons.check_circle : Icons.radio_button_unchecked) ·
          for (g in noStop.holding.gates) { expect(g.state, GateState.pass)(전제) · expect(holdingsChipIcon(tester, summary, g.label), Icons.check_circle_outline) } ·
        find.descendant(of: h62-entry-link, matching: find.text(noStop.entryDecisionLink.label)) 1 → 탭 → opener.opened == <String>[noStop.entryDecisionLink.deepLink] ·
        손절선 = expect(noStop.stopLines, isEmpty) 전제 → h62-stop-0 findsNothing · h62-no-stop data == noStop.noStopLineText · 이력 = expect(noStop.recentEntries, isEmpty) 전제 → h62-entry-0 findsNothing · h62-recent-empty data == noStop.recentEmptyLabel ·
        h62-pnl findsNothing · find.descendant(of: h62-pnl-toggle, matching: find.text(noStop.pnlToggleLabel!)) 1(전제 isNotNull) · 사슬 dy: h62-asof → h62-sleeve → h62-summary → h62-pnl-toggle → h62-entry-link → h62-no-stop → h62-recent-empty · ⓡ.
 T62-02 손절선 글자 행(K3 · ⑥ 보존 경로 — 테스트만) — withStops · ⓗ expect(withStops.stopLines, hasLength(1)) → i 마다 holdingsShownTexts(ValueKey('h62-stop-$i')) == holdingDetailStopTexts(s) ·
        tester.widget<Text>(find.descendant(of: ValueKey('h62-stop-$i'), matching: find.text(s.tierLabel))).style?.fontWeight == (s.isActive ? FontWeight.bold : FontWeight.normal) → h62-stop-1 findsNothing ·
        expect(withStops.noStopLineText, isNull) → h62-no-stop findsNothing · ⓡ.
 T62-03 최근 체결 = VM 안(K19) — withStops · opener · ⓗ expect(withStops.recentEntries, hasLength(3)) → k 마다 find.descendant(of: ValueKey('h62-entry-$k'), matching: find.text(e.symbolLabel)) findsOneWidget →
        사슬 dy: h62-entry-0 → h62-entry-1 → h62-entry-2 · h62-entry-3 findsNothing · h62-recent-empty findsNothing →
        k 마다(차례대로) expect(e.detailDeepLink, isNotNull) → tap(find.descendant(of: ValueKey('h62-entry-$k'), matching: find.text(e.symbolLabel))) → pump →
        expect(opener.opened, <String>[for (final TradeJournalEntry e in withStops.recentEntries) e.detailDeepLink!])(🔴 세 행을 모두 탭 — 세 행의 symbolLabel 이 같아 글자로는 차례를 못 가린다 · 링크 차례가 행 차례를 증명) · ⓡ.
 T62-04 손익 펼침 = 재구독 · 접기 · 재진입(K28 · 결정 ⑤) — final List<Override> overrides = holdingDetailOverrides(repo: repo) 한 번 · repo = fakeHoldingDetail(noStop, pnl) →
        calls == [(id, false)] · h62-pnl findsNothing → tapHoldingDetailPnlToggle → calls == [(id, false), (id, true)] · expect(pnl.holding.pnl, isNotNull) → holdingsShownTexts(Key('h62-pnl')) == <String?>[p.pnlText, p.pnlPctText, p.disclosureNote] ·
        summary 글자 == holdingDetailSummaryTexts(pnl.holding) → 다시 탭(접기) → calls 그대로(새 호출 0) · h62-pnl findsNothing →
        다시 탭(펼친 채로 나간다) → calls 그대로(캐시) · find.descendant(of: h62-pnl-toggle, matching: find.byIcon(Icons.expand_less)) 1 →
        재진입 = pumpHoldingDetail(overrides: overrides, holdingId: id, screenKey: const ValueKey<String>('again')) + pump → calls 그대로 · h62-pnl findsNothing(접힘 — 펼침이 전역이면 여기서 걸린다) ·
        find.descendant(of: h62-pnl-toggle, matching: find.byIcon(Icons.expand_more)) 1 · ⓡ.
 T62-05 RECON = 글자만(K16 ⓕ) — recon · 안전 = safetyFixtureRow(3) · 플래그마다 find.text(f.label) findsOneWidget(전제 isNotEmpty) · summary 글자 == holdingDetailSummaryTexts(recon.holding) ·
        find.descendant(of: h62-summary, matching: find.byIcon(Icons.warning_amber_rounded)) findsNothing · Icons.error_outline 도 findsNothing · ⓡ.
 T62-06 INTEGRITY = 가림 글자 · 칩 부재(K10 · K29) — integrity · 안전 = safetyFixtureRow(4) · 플래그마다 find.text(f.label) 1 · expect(integrity.holding.smaTranches, isEmpty) · expect(integrity.holding.pendingText, isNull) 전제 →
        summary 글자 == holdingDetailSummaryTexts(integrity.holding) · find.descendant(of: h62-summary, matching: find.byIcon(Icons.check_circle)) findsNothing · h62-pending findsNothing ·
        holdingsShownTexts(ValueKey('h62-stop-0')) == holdingDetailStopTexts(integrity.stopLines[0]) · ⓗ expect(integrity.recentEntries, hasLength(2)) → k 마다 ValueKey('h62-entry-$k') findsOneWidget · ⓡ.
 T62-07 화면 Text 전부(C4d-1) — 두 경우 (closed · noStop · steps 없음 · allowed = holdingDetailAllowed(noStop)) · (expanded · steps = tapHoldingDetailPnlToggle · allowed = holdingDetailAllowed(pnl))마다
        (repo = fakeHoldingDetail(noStop, pnl) · 안전 행 0 · 정상 시계): 규칙 10 의 «화면의 Text 전부» 견본 그대로 · ⓡ.
 T62-08 갈래 × 배너(C4r3-1 — detail · detail(pnl)) — 일곱 경우 ㉠ (이름, detail, clock, steps, 스켈레톤, 에러, 머리, 배너, 오래됨): (loading · 값 안 내는 컨트롤러) · (fail · Stream.error) · (normal · noStop) ·
        (normal_stale · noStop + 시계 +2일) · (integrity · integrity) · (pnl_loading · false = noStop · true = 값 안 내는 컨트롤러 · steps = 토글) · (pnl_fail · false = noStop · true = Stream.error · steps = 토글)마다 ·
        안전 = 모두 safetyFixtureRow(3) · Key('h62-loading') · Key('h62-fail') · Key('h62-asof') · find.text(JournalLabels.staleBannerTitle) · find.text(JournalLabels.retry) = want ? findsOneWidget : findsNothing 꼴 ·
        플래그마다 expect(find.text(f.label), wantBanner ? findsOneWidget : findsNothing)(배너 = normal · normal_stale · integrity 만) · CircularProgressIndicator · LinearProgressIndicator findsNothing(ⓡ·ⓗ 없음).
 T62-09 에러와 재시도 — 세 경우 (detail_fail · call 0 = Stream.error · 그 뒤 noStop · 기대 lastAsOf null · 재시도 뒤 calls [(id, false), (id, false)]) · (pnl_fail · true 의 첫 호출 = error · 그 뒤 pnl · steps = 토글 · null ·
        [(id, false), (id, true), (id, true)]) · (value_then_fail · call 0 = valueThenFail(noStop) · noStop.asOf.label · [(id, false), (id, false)])마다(안전 = safetyFixtureRow(3)):
        h62-fail 1 · JournalErrorView.lastAsOfLabel == 기대 · 플래그마다 find.text(f.label) findsNothing(에러 갈래 배너 0) → retry 탭 → pump 두 번 → h62-fail findsNothing · h62-asof 1 · calls == 기대 · ⓡ.
 T62-10 큰 글꼴 — 두 경우 (with_stops · withStops) · (expanded · noStop + 토글)마다 textScaleFactorTestValue = 2.0(+ teardown clear) → expect(tester.takeException(), isNull) · h62-asof 1 · ⓡ.
 T62-11 손익 줄 = 데이터(화면이 _pnlOpen 으로 줄을 고르지 않는다) — repo = fakeHoldingDetail(pnl, noStop)(🔴 일부러 뒤집은 짝 — 접힘 구독에 손익이 실린 값) · expect(pnl.holding.pnl, isNotNull) 전제 →
        calls == [(id, false)] · h62-pnl findsOneWidget(토글 전에도 데이터가 열면 열린다) → tapHoldingDetailPnlToggle → calls == [(id, false), (id, true)] · h62-pnl findsNothing · ⓡ.
 ⓡ 기대 = holding_detail_test.dart 10줄(T62-01·02·03·04·05·06·07·09·10·11) · ⓗ 기대 = 3줄(T62-02 · T62-03 · T62-06) — 🔴 정확히.
H6-3 — test/holdings_allocation_test.dart
 T63-01 진입 · 행 순서 · 들여쓰기 · 막대 유무(수용 (a)(e) · K17 · K27) — holdings = 값(inBand) · rebalance = 값(countdown) · expect(holdings.calls, 1) · expect(rebalance.calls, 1) ·
        holdingsShownTexts(Key('h63-asof')) == [inBand.asOf.label] · h63-notice data == inBand.noticeText(전제 isNotNull) · ⓗ expect(inBand.rows, hasLength(5)) → i 마다:
          holdingsShownTexts(ValueKey('h63-row-$i')) == allocationRowTexts(r) · 비중 = 위 «없는 쪽» 견본 · 메모(bandNoteText · h63-band-note-$i) · 상태(bandStateLabel · h63-state-$i) · 게이지(gauge != null ⇒ h63-gauge-$i 1 / else 0) ·
          막대(deployedRatio != null ⇒ h63-bar-$i 1 / else 0) · 펼침 단추(engineColumnNote != null ⇒ h63-note-toggle-$i 1 / else 0) · h63-note-$i findsNothing(처음 접힘) ·
          (들여쓰기는 이 루프 밖) →
        들여쓰기 = expect(inBand.rows[0].parentSleeve, isNull) 전제 · baseDx = tester.getTopLeft(h63-label-0).dx · for (final (int i, SleeveAllocationRow r) in inBand.rows.indexed.skip(1))(🔴 기준 행 0 은 자기와 비교하지 않는다 — 늘 참 0)
          if (r.parentSleeve != null) dx(h63-label-$i) greaterThan(baseDx) / else equals(baseDx)(if/else 짝) →
        사슬 dy: h63-row-0 → h63-row-1 → h63-row-2 → h63-row-3 → h63-row-4 → h63-next · ⓡ.
 T63-02 상태색 3값(C-12 · 02 §4-3 수용 (b)) — 세 경우 (in_band · inBand · SleeveBandState.inBand) · (out_of_band · outOfBand · outOfBand) · (tranche_progress · tranche · nearEdge)마다 b = v.rows[2]:
        expect(b.bandState, want) 전제 → h63-state-2 data == b.bandStateLabel · h63-weight-2 data == b.sleeveWeight!.label · 상태 아이콘(find.descendant(of: h63-row-2, matching: find.byIcon(Icons.circle)))의 color ==
        기대색(테스트 안 switch — inBand → cs.primary · nearEdge → cs.tertiary · outOfBand → cs.error) · h63-gauge-2 findsOneWidget · ⓡ.
 T63-03 계절 보류 칩(K13) — tranche · opener · a = tranche.rows[0] · ⓗ expect(a.stateChips, hasLength(1)) → j 마다 find.descendant(of: h63-row-0, matching: find.text(chip.label)) 1 → expect(a.stateChips[0].detailDeepLink, isNotNull) →
        tap(find.descendant(of: h63-row-0, matching: find.byType(ActionChip))) → opener.opened == <String>[a.stateChips[0].detailDeepLink!] · ⓡ.
 T63-04 파킹 큼 = 경고 아님(02 §4-3 · prompt 60~61행) — parking · b = parking.rows[2] · expect(b.bandState, SleeveBandState.inBand) 전제 → 상태 아이콘 color == cs.primary · find.descendant(of: h63-row-2, matching: find.text(b.parkingNoteText!)) 1 ·
        find.descendant(of: h63-row-2, matching: find.byIcon(Icons.warning_amber_rounded)) findsNothing · h63-bar-2 1 · ⓡ.
 T63-05 INTEGRITY = 기하 부재 · 글자 «숨김»(K10) — allocInteg · 안전 = safetyFixtureRow(4) · 플래그마다 find.text(f.label) 1 · ⓗ expect(allocInteg.rows, hasLength(5)) → i 마다:
        expect(r.gauge, isNull) · expect(r.deployedRatio, isNull) 전제 → h63-gauge-$i findsNothing · h63-bar-$i findsNothing · h63-weight-$i findsNothing · h63-state-$i findsNothing · shown(h63-row-$i) == allocationRowTexts(r) · ⓡ.
 T63-06 RECON = 기하 유지 · 글자만(K10 · K16 ⓕ) — allocRecon · 안전 = safetyFixtureRow(3) · ⓗ expect(allocRecon.rows, hasLength(5)) → i 마다 shown(h63-row-$i) == allocationRowTexts(r) ·
        find.descendant(of: h63-row-$i, matching: find.byIcon(Icons.warning_amber_rounded)) findsNothing → b(행 2): h63-gauge-2 1 · h63-bar-2 1 · h63-state-2 data == b.bandStateLabel · ⓡ.
 T63-07 엔진 열 안내 펼침(02:1348 · 위젯 State) — inBand · expect(inBand.rows[0].engineColumnNote, isNotNull) → openAllocationNote(tester, 0) → h63-note-0 data == inBand.rows[0].engineColumnNote ·
        h63-row-1 1(POT 행은 펼침과 무관하게 보임) · h63-note-1 findsNothing(행마다 따로) → openAllocationNote(tester, 0)(접기) → h63-note-0 findsNothing · ⓡ.
 T63-08 빈(K26) — allocEmpty + countdown · h63-empty data == allocEmpty.emptyLabel · h63-row-0 findsNothing · expect(allocEmpty.noticeText, isNull) → h63-notice findsNothing · h63-asof 1 · h63-next 1 · ⓡ.
 T63-09 하단 다음 회차 두 갈래(C-41 ③ · K8) —두 경우 (countdown · 탭하면 previewRoute) · (none · 탭해도 이동 0)마다(inBand):
        holdingsShownTexts(Key('h63-next')) == nextRebalanceTexts(n) → tap(Key('h63-next')) → expect(opener.opened, wantRoute ? <String>[n.previewRoute!] : <String>[])(전제 = 경우마다 expect(n.previewRoute, wantRoute ? isNotNull : isNull)) · ⓡ.
 T63-10 화면 Text 전부(C4d-1) — 두 경우 (closed · inBand · countdown · steps 없음) · (note_open · inBand · countdown · steps = openAllocationNote 0 · 1)마다 allowed = allocationAllowed(inBand, countdown) · 규칙 10 견본 그대로 · ⓡ.
 T63-11 갈래 × 배너(C4r3-1 — allocation × next × safety) — 열 경우 ㉠ (이름, allocation, next, clock, 스켈레톤, 에러, 머리, 배너, 오래됨, 빈, 하단, 행 — 🆕 빈 = 기대 빈 문장 String?(빈 갈래 셋 alloc_empty · empty_next_loading · empty_next_fail = allocEmpty.emptyLabel · 그 밖 일곱 = null)):
        (alloc_loading · 값 안 내는 컨트롤러 · countdown) · (alloc_fail · Stream.error · countdown) · (alloc_empty · allocEmpty · countdown) · (normal · inBand · countdown) · (normal_stale · inBand · countdown · +2일) ·
        (integrity · allocInteg · countdown) · (next_loading · inBand · 값 안 내는 컨트롤러) · (next_fail · inBand · Stream.error) ·
        (empty_next_loading · allocEmpty · 값 안 내는 컨트롤러) · (empty_next_fail · allocEmpty · Stream.error)마다(🔵 빈 갈래도 next 로딩·에러 = 하단 0 · 배너 그대로) · 안전 = 모두 safetyFixtureRow(3) ·
        Key('h63-loading') · Key('h63-fail') · Key('h63-asof') · find.text(JournalLabels.staleBannerTitle) · Key('h63-next') · ValueKey('h63-row-0') · find.text(JournalLabels.retry) = want ? findsOneWidget : findsNothing 꼴 · 🆕 빈 문장 = 규칙 10 «빈 문장» 견본 그대로(빈 갈래 셋 = h63-empty 글자 == allocEmpty.emptyLabel(전제 expect(allocEmpty.emptyLabel, isNotNull)) · 그 밖 일곱 = h63-empty findsNothing — C4a-5) ·
        플래그마다 expect(find.text(f.label), wantBanner ? findsOneWidget : findsNothing)(배너 = alloc_empty · normal · normal_stale · integrity · next_loading · next_fail · empty_next_loading · empty_next_fail — 🔴 next 로딩·에러는 본문·배너 영향 0) ·
        CircularProgressIndicator · LinearProgressIndicator findsNothing(ⓡ·ⓗ 없음).
 T63-12 에러와 재시도 — 두 경우 (alloc_fail · call 0 = Stream.error · 그 뒤 inBand · 기대 lastAsOf null) · (value_then_fail · call 0 = valueThenFail(inBand) · inBand.asOf.label)마다(안전 = safetyFixtureRow(3) · next = countdown):
        h63-fail 1 · lastAsOfLabel == 기대 · 플래그마다 find.text(f.label) findsNothing · h63-next findsNothing(에러 갈래 하단 0) → retry 탭 → pump 두 번 → h63-fail findsNothing · h63-asof 1 · expect(holdings.calls, 2) · ⓡ.
 T63-13 큰 글꼴 — 두 경우 (in_band · inBand + openAllocationNote 0) · (out_of_band · outOfBand)마다 textScaleFactorTestValue = 2.0 → takeException isNull · h63-asof 1 · ⓡ.
 T63-14 잔고 막대 = 비율 × 폭(K10 · 01 §13-2) — inBand · b = inBand.rows[2] · expect(b.deployedRatio, isNotNull) · expect(b.parkingRatio, isNotNull) 전제 · final double full = tester.getSize(find.byKey(ValueKey('h63-bar-2'))).width ·
        final Finder segs = find.descendant(of: find.byKey(const ValueKey<String>('h63-bar-2')), matching: find.byType(ColoredBox)) · expect(segs, findsNWidgets(2)) →
        expect(tester.getSize(segs.at(0)).width, closeTo(full * b.deployedRatio!, 0.5)) · expect(tester.getSize(segs.at(1)).width, closeTo(full * b.parkingRatio!, 0.5)) ·
        expect(tester.getSize(segs.at(0)).height, greaterThan(0)) · ⓡ.
 ⓡ 기대 = holdings_allocation_test.dart 13줄(T63-01·02·03·04·05·06·07·08·09·10·12·13·14) · ⓗ 기대 = 4줄(T63-01 · T63-03 · T63-05 · T63-06) — 🔴 정확히.

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려):
   (H6-2) 진입 includePnl true · 접기 때 새 구독 · 다른 id 로 구독 · 펼침 상태 전역(재진입 때 펼침 유지) · 손익 줄을 _pnlOpen 으로 고르기(`&&` 꼴 포함) · 손익 토글 아이콘 고정 · 요약 Text 순서 바꾸기 · 반영 대기 칩 빼기 ·
     트랜치 칩 아이콘 맞바꾸기 · 배지 아이콘 매핑 바꾸기(PASS 의 아이콘) · 매수 결정 링크 무반응 · 다른 링크 ·
     isActive 굵기 뒤집기 · noStopLineText 안 그림 · 손절선 행 있을 때 문장도 그림 · 최근 체결 순서 바꾸기(T62-03 탭 차례) · 체결 행 탭 무반응 · recentEmptyLabel 안 그림 · RECON 요약에 경고 아이콘 ·
     로딩·에러 갈래에 배너(detail · detail(pnl) 각각) · 에러를 스켈레톤으로 · lastAsOfLabel 안 넘김 · 재시도에 다른 열쇠 · 화면에 정적 글자 하나 더하기.
   (H6-3) 행 순서 바꾸기 · POT 들여쓰기 빼기 · 모든 행 들여쓰기 · 상태색 매핑 바꾸기(세 값 각각) · 게이지를 sleeveWeight 없을 때도 · 막대를 가림에도(0 대입) ·
     잔고 막대 여집합(1 − 비율 — 🔵 표본은 두 비율 합 = 1 이라 화면 테스트로는 못 가린다 · C-44 ⑯ 계약 테스트가 판정) · 두 막대 너비 바꾸기 ·
     투자분·파킹 머리 빼기 · 트랜치 문장 빼기 · 파킹 큼에 경고색(상태 아이콘 = T63-04 · 막대·문장 색 = 골든 h63_* 가 판정) · 보류 칩 무반응 · 엔진 열 안내를 처음부터 펼침 · 펼침 상태 공유(행마다 따로 아님) · notice 안 그림 · 빈 갈래 하단 빼기 ·
     하단 previewRoute 무반응 · 예정 없음에 날짜 머리 붙임 · next 로딩·에러에 배너 빼기(정상·빈 갈래 각각 · 본문 영향) · allocation 로딩·에러에 배너 · 🆕 빈 문장 글자 바꾸기(emptyLabel 대신 다른 글자 — T63-08 · T63-11 빈 갈래 셋 · C4a-5) · 화면에 정적 글자 하나 더하기.
   🔵 판정 = 변이마다 그 화면의 테스트 파일 + 그 골든 파일 + domain_contracts 의 c44_holdings_test.dart 를 함께 돌린다(여집합 = C-44 ⑯ · 순서·색 일부 = 골든) ·
      골든은 아이콘 차이를 못 본다(테스트 글꼴) — 아이콘 변이는 T62-01·T62-04 가 잡는다 ·
      v1.8 표본으로 검증할 수 없어 목록에서 뺀 것(정적 검토만): H6-2 하위 칩 빼기(detail 표본 5벌 모두 subBookLabel null) · 손절선 행 순서 바꾸기(표본 손절선 1행) · 뷰어 토글 부재(표본 없음) · 순번으로 행 고르기(i == 2 류 — 5분 눈 검사) ·
      드라이런(이 판) = 이 목록 전부 KILLED · 재드라이런(실제 R4a 병합본 위) = 52/52 KILLED.

■ 정적 묶음 — packages/ui_journal 에서 아래 33줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (R4a 카드와 같은 대조 규칙 — 줄을 고르거나 줄이거나 설명으로 바꾸지 않는다 · 대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 ·
   flutter test·dart test 출력은 파일로 떠서 붙인다 · «EXIT:1»/«EXIT:False» = 출력 없음 · 블록 뒤 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»)
echo "## S01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/holding_detail_test.dart test/holding_detail_fakes.dart test/holdings_allocation_test.dart test/holdings_allocation_fakes.dart test/golden/h62_golden_test.dart test/golden/h63_golden_test.dart; echo "EXIT:$?"
echo "## S02a test names ASCII (same line)"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/holding_detail_test.dart test/holdings_allocation_test.dart test/golden/h62_golden_test.dart test/golden/h63_golden_test.dart; echo "EXIT:$?"
echo "## S02b test names ASCII (wrapped line)"; git grep -nP "^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/holding_detail_test.dart test/holdings_allocation_test.dart test/golden/h62_golden_test.dart test/golden/h63_golden_test.dart; echo "EXIT:$?"
echo "## S02c testWidgets lines"; git grep -c "testWidgets(" -- test/holding_detail_test.dart test/holdings_allocation_test.dart test/golden/h62_golden_test.dart test/golden/h63_golden_test.dart; echo "EXIT:$?"
echo "## S03 string reshaping 0 (H6-2 H6-3 files)"; git grep -nP "(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|endsWith|indexOf|padLeft|padRight)\(" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S04 route constants and link literals 0"; git grep -nE "AppRoutes|AppLinkSchemes|'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "journalLinkOpenerProvider" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S06 holdings repository provider lines"; git grep -n "journalHoldingsRepositoryProvider" -- lib; echo "EXIT:$?"
echo "## S07 rebalance repository provider lines"; git grep -n "journalRebalanceRepositoryProvider" -- lib; echo "EXIT:$?"
echo "## S08 subscription lines"; git grep -nE "watchHoldingDetail|watchAllocation|watchNext|includePnl" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S09 forbidden calls 0 (H6-2 H6-3 files)"; git grep -nE "watchHoldings\(|watchHoldingsOverview|watchSleeves|watchFlags|ConfigRepository|JournalRepository|watchTimeline|LedgerRepository|watchExternalHoldings|PerformanceRepository|AdviceRepository|ExecutionGapRepository|CommandApi|recordDisclosureView|DraftStore|\.watchState\(|watchEvents|watchEvent\(|journalTimelineRepositoryProvider|journalConfigRepositoryProvider|journalCommandApiProvider|journalDraftStoreProvider" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S10 branch shell format words 0 (H6-2 H6-3 files)"; git grep -nE "operatingMode|OperatingMode|RunMode|runMode|FeatureFlags|satelliteEnabled|kIsWeb|Platform\.|DateTime\.now|DateTime\.timestamp|clock\.now\b|Scaffold|AppBar|SafeArea|SnackBar|Navigator|GestureDetector|toStringAsFixed|toStringAsPrecision|NumberFormat|journal_draft|SleeveId\.|HoldingScope\.|AllocationBasis\." -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S11 raw keys and unread fields 0 (H6-2 H6-3 files)"; git grep -nP "\.(quantity|avgPrice|unrealizedPnl|pnlPct|absoluteStop|trailStop|customStop|highWaterMark|level|weight|targetWeight|bandLow|bandHigh|symbol|sleeve|scope|scopeLabel|basis|tierCode|entryDecision|blockedReasonCode|code|wire|isDeviation|kindCode|accountAlias|stopLine|momentum|stepNo|filledOn|expectedKind|kindLabel)\b|\.holding\.detailDeepLink|\.(stopLine|momentum)!" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S12 holdingId lines (key only)"; git grep -n "holdingId" -- lib/src/holding_detail.dart; echo "EXIT:$?"
echo "## S13 trimming 0"; git grep -nE "maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S14 sort filter pick words 0"; git grep -nP "(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet|last|lastOrNull|sublist|getRange|elementAt|removeAt|removeWhere|retainWhere|shuffle)\b|\breverse:\s*true|groupBy|FlagIds|activeFlags|markerOnly" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S15 autoDispose (old comment line only)"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## S16 barrel exports 9"; git grep -n "^export " -- lib/ui_journal.dart; echo "EXIT:$?"
echo "## S17 operator barrel 1"; git grep -n "^export " -- lib/journal_draft.dart; echo "EXIT:$?"
echo "## S18 item1 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_journal/)" -- lib; echo "EXIT:$?"
echo "## S19 item3 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## S20 figures 0 (prompt 48-54)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## S21 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S22 shared files add-only (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_journal.dart lib/src/common/journal_common.dart lib/src/holdings_overview.dart; echo "EXIT:$?"
echo "## S23 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/holding_detail_test.dart test/holdings_allocation_test.dart; echo "EXIT:$?"
echo "## S24 H lines (hasLength)"; git grep -c "hasLength(" -- test/holding_detail_test.dart test/holdings_allocation_test.dart; echo "EXIT:$?"
echo "## S25 h62 h63 key names"; git grep -noP "h6[23]-[A-Za-z]+(-[A-Za-z]+)*" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S26 labels holdings (8)"; git grep -n "holdings" -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## S27 rich text widgets 0"; git grep -nE "RichText|SelectableText|Text\.rich" -- lib/src/holding_detail.dart lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S28 band state switch lines (3)"; git grep -n "SleeveBandState\." -- lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S29 gate state switch lines (4)"; git grep -n "GateState\." -- lib/src/holding_detail.dart; echo "EXIT:$?"
echo "## S30 width products (gauge 4 + bar 2)"; git grep -nP "(?:[Ww]idth|\bw)\s*\*\s*[\w.]+" -- lib/src/holdings_allocation.dart; echo "EXIT:$?"
echo "## S31 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
  (줄의 뜻과 기대 — S01 = 주석 줄 말고 출력 없음 · S02a·S02b = ASCII · S02c = 4줄 «test/golden/h62_golden_test.dart:1» · «test/golden/h63_golden_test.dart:1» · «test/holding_detail_test.dart:11» · «test/holdings_allocation_test.dart:14»(git grep 경로 순) ·
   S03·S04 = 0 · S05 = 탭 콜백 안 2줄(h62-entry-link 의 onPressed · h63-next 의 onTap) · S06 = 5줄(R4a 의 holdings_overview 3 + holding_detail 1 + holdings_allocation 1 — 드라이런) · S07 = 3줄(정의 1 · throw 문구 1 · next 의 .watch 1) ·
   S08 = 3줄(watchHoldingDetail·includePnl 한 줄 — dart format 이 한 줄로 둔다 · watchAllocation 1 · watchNext 1) · S09·S10·S11 = 0 · S12 = 4줄(생성자 매개변수 · 필드 · 열쇠 레코드 두 줄(watch · invalidate) — Text·Key·보간 0) ·
   S13·S14 = 0 · S15 = «lib/src/journal_draft/journal_draft_form.dart:37:» 주석 1줄뿐 ·
   🔴 «정확히 N»(이 카드 = R4 마지막이 소유) — S16 = 9줄(l10n/labels.dart · src/blind_review.dart · src/decision_detail.dart · src/holding_detail.dart · src/holdings_allocation.dart · src/holdings_overview.dart · src/journal_read.dart · src/timeline.dart · src/unknown_board.dart 순 ·
   드라이런 analyze 로 확인한 차례) · S17 = 1줄 · S18~S21 = 0 · S22 = 두 줄(labels.dart · ui_journal.dart) 둘째 수 0 · 첫째 수 = labels 17 · 배럴 2(드라이런 · 주석·빈 줄을 세므로 짓는 모양에 따라 달라도 된다) · journal_common·holdings_overview 줄 없음 ·
   S23 = 2줄 «test/holding_detail_test.dart:10» · «test/holdings_allocation_test.dart:13» · S24 = 2줄 «test/holding_detail_test.dart:3» · «test/holdings_allocation_test.dart:4»(🔴 정확히 — 다르면 반려) ·
   S25 = 이름 29개(h62-loading · h62-fail · h62-asof · h62-sleeve · h62-summary · h62-pending · h62-subbook · h62-pnl-toggle · h62-pnl · h62-entry-link · h62-stop · h62-no-stop · h62-entry · h62-recent-empty ·
   h63-loading · h63-fail · h63-asof · h63-notice · h63-empty · h63-row · h63-label · h63-weight · h63-band-note · h63-state · h63-gauge · h63-bar · h63-note-toggle · h63-note · h63-next — 같은 이름이 갈래마다 두 번 나와도 된다 · 표 밖 0) ·
   S26 = 8줄(R4a 3 + 이 카드 5) · S27 = 0 · S28 = 3줄 · S29 = 4줄 · S30 = 6줄(게이지 w × 네 값 — bandLow · bandHigh · target · actual 이 dart format 으로 줄마다 · 막대 c.maxWidth × 둘 · 드라이런) · S31 = 출력 없음)

■ 골든 — 8이름 × light/dark = 16장(전부 신규 · 설계서 §3-4 · golden README «🆕 R4» 절 표 그대로 · ✅ K16 ⓑⓓ 이름)
  h62 — test/golden/h62_golden_test.dart · const Size _kTallPhone = Size(390, 1400)(재드라이런 dy 최대 1340 = h62_integrity · 참고값) · 위젯 = HoldingDetail(holdingId: <그 VM 의 holding.holdingId>):
    h62_etf_no_stop(closed = noStop · open = pnl · 안전 행 0 · 흐름 없음) · h62_pnl_expanded(noStop/pnl · 행 0 · 흐름 = 토글 탭 — 손익 줄 + disclosureNote) ·
    h62_recon_mismatch(recon · 행 3 · 흐름 없음) · h62_integrity(integrity · 행 4 · 흐름 없음 — ⑮ · 손절선 글자 «숨김» · 체결 2)
  h63 — test/golden/h63_golden_test.dart · const Size _kTallPhone = Size(390, 1100)(재드라이런 dy 최대 1056 = h63_pot_under_a · 참고값 · 여유 44) · 위젯 = const HoldingsAllocation() · 하단 = countdown · 안전 행 0:
    h63_in_band(inBand · 흐름 없음) · h63_out_of_band(outOfBand) · h63_tranche_progress(tranche — 보류 칩) · h63_pot_under_a(inBand · 흐름 = A 행 엔진 열 펼침(openAllocationNote 0))
  모양 = h61_golden_test.dart(R4a)와 같은 (이름, 흐름) 목록 × Brightness.values 루프 · 흐름 = 클로저 칸(C4r3-4 — 흐름 없음 = (WidgetTester t) async {}) · 테스트 이름 '$name ${brightnessSuffix(b)}' ·
  차례 = await pumpForGolden(…) → await tester.pump();(한 번 더 — 값 도착) → await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden.
  🆕 위치 전제 둘 = 이 코드 글자 꼴(C4r3-5 · 흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(<맨 아래 Key>)).dy, lessThan(_kTallPhone.height));
    expect(tester.getTopLeft(find.byKey(const Key('h62-asof'))).dy, 0.0);   // h63 파일은 Key('h63-asof')
    ← 맨 아래 Key = h62_etf_no_stop · h62_pnl_expanded · h62_recon_mismatch → Key('h62-recent-empty') · h62_integrity → ValueKey<String>('h62-entry-1') · h63_* → Key('h63-next')
  명령(packages/ui_journal): flutter test --update-goldens test/golden/h62_golden_test.dart · flutter test --update-goldens test/golden/h63_golden_test.dart → flutter test(옵션 없이 · git status 에 새 PNG 16 만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 높이(_kTallPhone)를 늘리지 않는다 · 머리 dy == 0 전제가 실패하면(ListView padding 등) 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 · 여백을 줄였으면 «측정:» 행(전·후 dy) · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0 · R4a 카드 «골든» 절과 같은 법).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개 · 두 화면 질문을 한 파일에)
· H62H63_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일(H61 · J1~J5) 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지 · 행 앞에 «H6-2:» 또는 «H6-3:» 접두(🔵 예외 = 골든 dy «측정:» 행 — 접두 없이 «측정:» 으로 시작 · 이름 h62_·h63_ 가 화면을 가른다).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A8 = h62_etf_no_stop · h62_pnl_expanded · h62_recon_mismatch · h62_integrity · h63_in_band · h63_out_of_band · h63_tranche_progress · h63_pot_under_a 순 · 종류 «추측» · 첫머리 «측정:») ·
    | A1 | R4b-Bob-H62H63 | 추측 | 측정: h62_etf_no_stop dy 실측값 (light=<값>, dark=<값>) < <높이> | 골든 위치 전제 실측 | <높이> 미만 확인 | ⬜ 미답 | |
    (🔵 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖 — H61 행 «(light=1268.0, dark=1268.0) < 2480» 과 같은 꼴)
  여백을 줄였으면 A9 부터 «측정:» 전·후 행 · 권고와 다르게 지은 이름 · 5개 밖에 더 필요했던 정적 라벨 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 5 · 읽지 않는 필드 · 게이지·막대 모양 · 색·아이콘 매핑 · 배치 순서 · Text 순서 · 골든 이름·입력·흐름 · 재량(여백·크기·모서리).
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(5) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋)
  cd packages/ui_journal
  flutter test test/holding_detail_test.dart            ← 끝 줄 그대로(기대 «+21: All tests passed!»)
  flutter test test/holdings_allocation_test.dart       ← 끝 줄 그대로(기대 «+29: All tests passed!»)
  flutter test test/golden/h62_golden_test.dart         ← 끝 줄 그대로(기대 «+8: All tests passed!»)
  flutter test test/golden/h63_golden_test.dart         ← 끝 줄 그대로(기대 «+8: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄 그대로 · 기대 = 시작 기준 N + 66(322 → 388))
  cd ../domain_contracts
  dart test test/contracts/c44_holdings_test.dart -r expanded   ← 전부 통과 · «C-44 ⑫ 대상» 줄과 그 아래 들여쓴 경로 줄을 그대로 적어 둔다
     (기대 4줄: «C-44 ⑫ 대상 H6 3파일 — packages/ui_journal/{lib/src/holdings_overview.dart, lib/src/holding_detail.dart, lib/src/holdings_allocation.dart} + packages/ui_journal/lib/src/holdings/**» +
      공백 4칸 들여쓴 «packages/ui_journal/lib/src/holding_detail.dart» · «packages/ui_journal/lib/src/holdings_allocation.dart» · «packages/ui_journal/lib/src/holdings_overview.dart»(정렬 순) · C-44 20/20 · domain_contracts 전체 = «+336 ~30: All tests passed!»(C-40 ⑧ 보강 PR #55 e494817 뒤 · 병합본 faeb458 실측 +336 ~30 · 재드라이런 끝도 «+336 ~30: All tests passed!» · 이 카드는 domain_contracts 를 바꾸지 않는다 · 보강 전 드라이런 «+335 ~30 -1: Some tests failed.»))
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_journal/): A lib/src/holding_detail.dart · A lib/src/holdings_allocation.dart · M lib/l10n/labels.dart · M lib/ui_journal.dart ·
        A test/holding_detail_fakes.dart · A test/holding_detail_test.dart · A test/holdings_allocation_fakes.dart · A test/holdings_allocation_test.dart · A test/golden/h62_golden_test.dart · A test/golden/h63_golden_test.dart ·
        A test/golden/goldens/h62_*.png 8장 · A test/golden/goldens/h63_*.png 8장 · M docs/ai-context/inbox/H62H63_questions.md · 그 밖의 줄(특히 M lib/src/holdings_overview.dart · M test/holdings_overview_fakes.dart · M PNG) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0 --golden-prefix h6 --goldens 16
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M6] R4b (6) 사전검사 지적 수정» · amend 금지 · format:fix 먼저) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
        (🔵 접두 «h6» 는 h62_·h63_ 행을 함께 센다 — 골든 표 행은 정확히 16 · h61_ 행을 표에 넣지 않는다)
  git push -u origin ui/m6-h62-h63-holdings
  git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD   ← ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · 권장대로면 커밋 5줄)
  cd packages/ui_journal → 위 «정적 묶음» 33줄 → cd ../..   ← ② 에 그대로 붙일 출력
  10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r4b_box2.txt)에 저장 → (Get-Content $env:TEMP\r4b_box2.txt).Count 또는 grep -c "" "$TEMP/r4b_box2.txt" ← 출력 한 줄(기대 10 · 코드 블록 하나 · 명령 줄은 붙이지 않는다)
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M6] H6-2·H6-3 종목 상세·슬리브 비중
  PR 본문 5섹션을 채팅으로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R4b-Bob-H62H63_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R4b-Bob-H62H63_submit.md --golden-prefix h6 --goldens 16
        ← 🔴 0 이어야 채팅에 낸다 · 출력은 채팅에 붙이지 않는다 · 🔵 🟡 [G1](골든 표 ↔ PNG 덩어리 수)은 이 두 화면에서 나와도 멈춤이 아니다 — h62 = 사전검사가 테두리 있는 버튼을 «칩 1개» 로 · 배너·체결 카드를 «상자(안 글자 n줄)» 로 세어 표의 «버튼 글자»·«상자» 와 갈린다(행마다 🟡) · h63 = 칸을 «·» 없이 «→» 로만 잇는다(«막대 · 막대» 처럼 «·» 로 나열하면 그 칸을 덩어리로 못 세어 🟡 1) · 재드라이런 🟡 9(h62 8행 + h63 «·» 칸 1) — 표는 이 카드의 셈 단위대로.
   ① 아래 «① 머리 복사 상자» 두 줄 그대로 + «바뀐 파일:» + name-status 출력 그대로(코드 블록 하나) + «커밋 목록:» + log 출력 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: H6-2 — 종목 상세(HoldingDetail(holdingId:))
화면 ID: H6-3 — 슬리브·비중(HoldingsAllocation())
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항 — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «정적 묶음 S18 — 허용 밖 import 0줄»
        2번 = «두 화면 파일 산술 = 신선도 한 식 + × 폭(S30 <N>줄)뿐 · 여집합·차·합 0(C-44 ⑯) · 금지 수치 S20 0건 · 소수·% 리터럴 S21 0건»
        3번 = «정적 묶음 S19 — 0건»
        4번 = «H6-2 진입 구독 includePnl false 한 번(T62-01) · 펼침 = 토글 탭 재구독 · 접기 새 호출 0(T62-04) · 손익 정렬·합계 0(T62-07) · watchHoldings 부르지 않음(S09)»
        5번 = «이 카드 범위 밖(H6-2·H6-3 에 J-4 없음)»
        6번 = «M5·X1·X5 화면 0 · 배너 clearDeepLink 는 공통 배너 그대로 · 이동 = 데이터 링크만(T62-01·T62-03·T63-03·T63-09)»
        7번 = «배너 = JournalSafetyBanners 그대로(T62-08·T63-11) · RECON «?»·INTEGRITY «숨김» = 엔진 글자 그대로 · 아이콘 0 · 가림 기하 부재(T62-05·T62-06·T63-05·T63-06)»
        8번 = «두 화면 머리 = vm.asOf.label(h62-asof · h63-asof · T62-01 · T63-01)»
        9번 = «로딩·빈·에러·오래된 데이터·차단 = T62-08·T62-09·T63-08·T63-11·T63-12 · 부분 동기 = 이 카드 범위 밖(Q-D)»
        10번 = «픽스처 변경 0 · 새 PNG = h62_* 8장 + h63_* 8장 · 재생성 <N>장 · 미정의 타입 이름 짓기 0(H6-2·H6-3 = 계약 v1.8)»
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
      이어서 «10항 줄 수:» + 출력 한 줄 + «정적 묶음 출력:» + 33줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 2줄 +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(S23·S24 출력 줄 그대로 복사 · test/ 를 떼지 않는다) + «C-44 ⑫ 출력:» + 출력 4줄 그대로 + «테스트 파일별:» + 위 flutter test 네 파일 끝 줄 그대로(holding_detail · holdings_allocation · h62_golden · h63_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 6줄)
ⓡ = S23 출력:
<S23 출력 줄 그대로>
<S23 출력 줄 그대로>
ⓗ = S24 출력:
<S24 출력 줄 그대로>
<S24 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — H6-2 로딩·정상·차단 3줄 + H6-3 로딩·정상·빈·차단 4줄 + 골든 표 16행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2):
         H6-2 «정상» = ListView → Key('h62-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('h62-sleeve') → Key('h62-summary') → Key('h62-pending')(있을 때) → Key('h62-subbook')(있을 때) →
                       Key('h62-pnl-toggle')(있을 때) → Key('h62-pnl')(있을 때) → Key('h62-entry-link') → ValueKey<String>('h62-stop-$i')(있을 때) → Key('h62-no-stop')(있을 때) → ValueKey<String>('h62-entry-$k')(있을 때) → Key('h62-recent-empty')(있을 때)
         H6-3 «정상» = ListView → Key('h63-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('h63-notice')(있을 때) → ValueKey<String>('h63-row-$i') → ValueKey<String>('h63-label-$i') → ValueKey<String>('h63-note-toggle-$i')(있을 때) →
                       ValueKey<String>('h63-weight-$i')(있을 때) → ValueKey<String>('h63-band-note-$i')(있을 때) → ValueKey<String>('h63-state-$i')(있을 때) → ValueKey<String>('h63-gauge-$i')(있을 때) → ValueKey<String>('h63-bar-$i')(있을 때) →
                       ValueKey<String>('h63-note-$i')(있을 때) → Key('h63-next')(있을 때)
         «로딩» = JournalSkeleton(Key('h62-loading')) · JournalSkeleton(Key('h63-loading')) — 배너 없음 · H6-3 «빈» = ListView → Key('h63-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('h63-empty')(있을 때) → Key('h63-next')(있을 때) ·
         «차단» = JournalSafetyBanners 의 자리를 코드 그대로(H6-2 «Key('h62-asof') 아래 · Key('h62-sleeve') 위» · H6-3 «Key('h63-asof') 아래 · Key('h63-notice') 위»)
      골든 표 16행(h62_* 8 · h63_* 8 · 한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |» · 이름 칸 = «h62_etf_no_stop light» 꼴 · 입력 = 경로 그대로(h63 은 배분 경로 + m7/m7_next_rebalance_countdown.json) ·
        크기 = 390×<높이> · dy = 이름·밝기마다 잰 값 · 배치·잘림 = 🆕 이름마다 light PNG 한 장만 연다(8장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 배경 덩어리 · 칩 n개 · 막대 · 점 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(16행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0).
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/H62H63_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = H62H63_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(없으면 «없음»)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_journal 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 66 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-h62-h63-holdings` 푸시 1건 · 커밋 권장 5개(마지막 = format·질문 · amend·rebase·강제 푸시 0).
- `lib/` 새 파일 **2**(`src/holding_detail.dart` · `src/holdings_allocation.dart`) · 수정 2(더하기만 — `labels.dart` 끝 R4b 절 라벨 5 · `ui_journal.dart` export 2줄) · `holdings_overview.dart`(R4a)·`journal_common.dart` 변경 0 · `lib/src/holdings/` 없음.
- `test/` 새 파일 6(뷰 테스트 2 · 가짜 2 · 골든 2) + 새 PNG 16장(`h62_*` 8 · `h63_*` 8) · 기존 테스트·PNG·하네스·README 불변(재생성 0 → `golden:approved` 불필요).
- 질문 파일 `H62H63_questions.md`(새 행 A1~A8 «측정:» 반드시).
- 채팅: PR 본문 5섹션 + flutter test 한 줄 · 사전검사 두 번 🔴 0.
- `flutter test` = 시작 기준 N(= 322 · R4a 병합본 `faeb458` 실측) + 66(322 → 388) · 정적 S23 = 10·13 · S24 = 3·4(🔴 정확히) · S06 = 5 · S07 = 3 · S08 = 3 · S12 = 4 · S30 = 6 · S05 = 2 · S16 = 9 · S25 = 29이름 · S26 = 8 · S28 = 3 · S29 = 4 · C-44 ⑫ = «H6 3파일»(4줄).
- 재분할 임계(카드 계획): 새 testWidgets 줄 27(뷰 11 + 14 · 골든 1 + 1 · 임계 «> 33» 안) · lib +603/-0(재드라이런 — holding_detail 249 · holdings_allocation 335 · labels 17 · 배럴 2 · ~~드라이런 +596~~ · 임계 «> +900» 안) · 새 PNG 16(임계 «> 16» 의 경계 — 넘지 않음) — 넘으면 3분할(R4b-Bob-H62 · R4c-Bob-H63 · 머리 «발주자 확인 대기» ⑤). 드라이런·재드라이런 판정 = 재분할 불필요(세 임계 모두 안 · ~~발송을 막는 것은 분할이 아니라 선행 2 C-40 ⑧~~ 선행 2 ✅ PR #55).
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것: 원판(조립 판 테스트)에서 통과한 것 — 손익 줄 `_pnlOpen &&` 꼴 · 빈 갈래 next 로딩·에러 배너 빼기 · (H6-2) 하위 칩 빼기 · 손절선 행 순서 바꾸기 · 여집합(화면 테스트·골든만으로는) · 최근 체결 순서(골든으로만) →
  이 판 테스트(T62-11 · T63-11 empty_next_* · T62-03 세 행 탭 · T62-04 펼친 채 재진입 · T62-01 칩 아이콘)로 KILLED · 여집합 = C-44 ⑯ · 하위 칩·손절선 순서 = 목록에서 뺌(표본 없음 — 정적 검토) · 이 판 목록 전부 KILLED(드라이런 변이 70 = KILLED 62(그중 골든만 1) · 통과 8 = 목록에서 뺀 2(하위 칩 · 손절선 순서) + C-44 ⑯ 판정 1(여집합 — c44 로 KILLED 확인) + 목록 밖 참고 변이 5(순번 i == 2·i == 1 셋 · 가림 행 보류 칩 · 첫 id 고정 — 5분 눈 검사 ⑧ · 다음 ui_journal 카드)) · 재드라이런(실제 R4a 병합본 위 · 이 판 목록 52꼴 = H6-2 25 · H6-3 27) = 52/52 KILLED(여집합 = c44_holdings 만 · 파킹 문장 경고색 = 골든만 · 빈 문장 글자 = T63-08 · T63-11).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R4b-Bob-H62H63 결과: 브랜치 ui/m6-h62-h63-holdings 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. 0단계에서 멈췄다면 `R4b-Bob-H62H63 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① 기존 PNG(`h61_*` 포함)가 `M` ② `holdings_overview.dart`·`holdings_overview_fakes.dart` 가 `M` ③ 하네스·README·`journal_common.dart` 가 `M` ④ 화면 코드의 `aaq://`·`AppRoutes`·`Navigator`·`DateTime.now`·`SleeveId.`·`.watchState(`·`Scaffold` ⑤ `1 -`·`- … Ratio`·`?? 0`·`deployedRatio` 이름 지역 변수 곱 · `.level`·`.weight`·`.symbol`·`.sleeve`·`holdingId` 표시·Key · «?» 검사 · `includePnl: true` · `.where`·`.sort`·`.take` ⑥ 마지막 커밋이 format·질문이 아님 · 공용 2파일 삭제 줄 ⑦ ⓡ·ⓗ 수(S23·S24)가 10·13 · 3·4 가 아님 ⑧ 순번 비교(`i == 2` 류)로 행을 고름(밴드 행·POT 자리를 표본 순번으로 박음) — 하나라도 있으면 반려 신호.
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 만) — 혹시 필요해지면(카드 개정) 라벨은 **Bob 푸시 전에** 통합 담당이 붙인다(R3 교훈).
- C-44 B 절은 이 브랜치에서 «3파일» 을 본다 — 병합 검사 때 Claude 가 `dart test test/contracts/c44_holdings_test.dart -r expanded` 의 «C-44 ⑫ 대상» 4줄을 PR 본문 ② 와 대조한다 · `check_boundaries.sh` [5][5b][5c] 도 새 두 파일을 본다.
- 셸(R13)에 넘길 것: `holdingsDetail` → `HoldingDetail(holdingId: <라우트 파라미터>)` · `holdingsAllocation` → `HoldingsAllocation()` · 홈 블록 4 탭 → `holdingsAllocation` · override + `journalRebalanceRepositoryProvider`(조립 앱 3종 · 폰 앱은 M7 의 리밸런싱 창구와 같은 인스턴스) — 이 카드에 없습니다.
- 범위 고지(01 §17-17): 미결 103~110 은 이 카드에 없습니다(특히 손절선 게이지 104 · 신호 결측 106 · 역참조 110 · M7 픽스처 밴드 정합 109 — `S7-6a`·`S7-6b` 의 밴드 그림과 `H6-3` 의 B 만 밴드가 당분간 다르게 보인다).
- 🔵 표본 사실: 손절선 행 표본 ⑥(`m6/holding_detail_with_stops`)은 «보존 경로 — P0S 정상 장면 아님»(앱 `fixtures/README` «계약 v1.8 · 표본 사실» 절) — 그래서 골든이 아니라 테스트만 본다(K16 ⓓ).
