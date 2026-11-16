import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

// 배럴 연기(smoke) 테스트 — 「패키지가 컴파일되고 배럴이 계약 버전을 노출한다」까지.
//
// ✅ G3 확정(2026-09-08): 01 §7 의 계약 회귀 테스트 C-1~C-32 는 `test/contracts/` 에
//    실물로 들어왔다(33파일). 이 파일은 그것들에 «대체»된 것이 아니라, 배럴
//    `lib/domain_contracts.dart` 하나만 import 해도 계약 버전이 보이는지를 지키는 가장 바깥
//    껍데기로 남는다 — C-1·C-15 는 봉투와 상수를 대조할 뿐 배럴 노출 여부를 보지 않는다.
void main() {
  test('배럴이 계약 버전을 노출하고, 값이 확정판이다', () {
    // 🔴 이 상수와 전 픽스처 봉투(v1.21 = 283건 — 기존 271 + v1.21 신설 12(개정 1 포함 수 불변))의 `meta.contract_version` 은
    //    같은 축이며 한쪽만 올리지 않는다(C-1 · C-15 ④ 가 전량 대조한다).
    // 🔵 '1.1.0'(2026-09-17 · M2 보강) — 내비게이션 계약·표시 문자열·J-2/J-3/J-5 읽기 창구.
    // 🔵 '1.2.0'(R2b 선행 M2 보강 · 01 §12) — 초안 포트 `DraftStore` · `watchDecisionJournal` ·
    //    라우트 `journalRead`.
    // 🔵 '1.3.0'(R10 선행 M2 보강 · 01 §13) — 성과 시리즈 표시 필드 · 아카이브 머리글 ·
    //    열람 이벤트 기본값 · `series(range:)` nullable.
    // 🔵 '1.4.0'(R11 선행 M2 보강 · 01 §14) — 입금 미리보기 `DepositPreviewResult` · 목표 경로
    //    `goalPath(yyyyMm)`·`GoalPathVm` 재설계 · `MonthlyReport.goalDeepLink` · `DepositRegistration(planId:)`.
    // 🔵 '1.5.0'(R12 선행 M2 보강 · 01 §15-3) — 라우트 `journalRebalance` · `RebalanceEvent` 버튼·행 링크 ·
    //    `JournalRebalanceScope`·`watchRebalanceScope` · `watchEvent` · `watchEvents` 봉투.
    //    S7-5 는 인출 규칙 결정 뒤 첫 minor(번호는 그때).
    // 🔵 '1.6.0'(R12 선행 M2 보강 · 01 §15-4) — `RebalancePreviewResult`·`ExecutionGapResult` 래퍼 ·
    //    `watchEvents({range})`·`annualReview({year})`·`monthly({yyyyMm})` · R12 표시 필드 · 라우트
    //    `ledgerExecutionGapMonth`·`rebalanceHistory`(45) · `ThresholdCompare` → `common.dart`.
    // 🔵 '1.7.0'(J-4 선행 M2 보강 · 01 §16 · §8 미결 46) — `BlindReviewChoice`·`BlindReviewResult` ·
    //    `BlindReviewCard` 표시 필드 · `watchBlindReviewQueue({mode})`·`watchBlindReviewCard` ·
    //    `BlindReviewRejectCodes` · 라우트 45 그대로.
    // 🔵 '1.8.0'(R4 선행 M2 보강 · 01 §17 · 화면 ID `H6-*`) — `watchHoldingsOverview`·`watchHoldingDetail`·
    //    `watchAllocation` · 보유 VM 4 · `SleeveAllocationRow` 밴드 축(`SleeveBandState`·`SleeveBandGauge`) ·
    //    `StopTierCodes` · 라우트 48.
    // 🔵 '1.9.0'(E9a · 단계 1b) — 스키마 v1 결정 반영(`mode` 3값 + 파일별 CHECK · 명령 state 8값 ·
    //    `CORPORATE_ACTION` 통합) · `schemaVersion`·`hashFormatVersion` = 1 · `LedgerFile`·`ledgerDdlFor`.
    // 🔵 '1.10.0'(E9a2 · ㊲) — 원장 사건 `recordLedgerEvent` · `LedgerEventKind` · `CashFlowKind.isExternal` ·
    //    `ledger_event` 표 · `cash_flow` 5값.
    // 🔵 '1.11.0'(E7b0 · M3-2·M3-4) — `DepositRegisterRejectCodes` · `DEPOSIT_REGISTERED` ·
    //    `cash_flow.account_alias` · 접수증 `_5`(거부 행) · `depositReceiptViolations`.
    // 🔵 '1.12.0'(R5·R13 선행 M2 보강 · 01 §21) — X7 제출 DTO 3 · `deferAdviceConfirm` · `L-3` 세션 VM·창구 ·
    //    `L-1`·`L-2` 표시 필드 · `watchRepairs` · `watchRhythm` · 라우트 52 · 픽스처 174 · C-46·C-47.
    // 🔵 '1.13.0'(R13b 선행 M2 보강 · 01 §23) — `DiagnosticCell.level` · `headline` «늘 엔진 문장» ·
    //    `m8/recon_board_ok`·`m8/ops_home_advice_suppressed_due` · 픽스처 176 · C-47 ⑩⑪.
    // 🔵 '1.14.0'(E8a · M1-7) — `MarketDataSource` · `GapReasonCodes` +5 · 배치 G(`market_series`·`fetch_log`) · C-48.
    // 🔵 '1.15.0'(R14 선행 · 01 §24) — `AlertCenterVm`·`AlertSection`·`AlertDetailVm` · `watchCenter`·`watchAlert` ·
    //    `acknowledgeAlert(String alertId)` · 라우트 54 · `WatchdogBoardVm` · `WatchdogCheck` −slug +checkId +level ·
    //    받침대 2 · 픽스처 187 · C-49.
    // 🔵 '1.16.0'(R15 선행 · 01 §25) — 온보딩 VM 7 · 라우트 64 · 사전 3 · 받침대 2 · 픽스처 219 · C-50.
    // 🔵 '1.17.0'(R16 선행 + E10 D11 · 01 §26) — 장애·런북·카드·핸드북·기기 리스크 · 라우트 69 · 사전 2 · 받침대 3+1 · 픽스처 240 · C-51.
    // 🔵 '1.18.0'(R6 선행 + 엔진 등재형 7 · 01 §27) — S01 설정 홈 · S07 연결 관리 · 라우트 80 · 사전 3 · 받침대 1 · 픽스처 248 · C-52.
    // 🔵 '1.19.0'(R6c 선행 + 엔진 E15i 굳은 몫 · 01 §28) — S05 운용 관리 `OperationsVm` · 승격 동작 · 사전 7 · 받침대 1 ·
    //    픽스처 256 · C-53 · 엔진 다음 판 = 1.20.0.
    // 🔵 '1.20.0'(R7 선행 + 엔진 겹침 · 01 §29) — S02·S06·S03 · 사전 2 · 받침대 2 · 픽스처 271 · C-54 · 엔진 다음 판 = 1.21.0.
    // 🔵 '1.21.0'(엔진 예고 1/2 · 01 §30) — `SafetyActions` · 킬스위치 기록·재개 · 서약 · 게이지 · 라우트 84 · 픽스처 283 · C-55 ·
    //    엔진 다음 판 = 1.22.0.
    expect(contractVersion, '1.21.0');
    expect(schemaVersion, 1);
    expect(hashFormatVersion, 1);
    // 🔴 draft 표식이 남아 있으면 화면이 «필드명을 굳혀도 되는가»를 판단할 수 없다.
    expect(contractVersion, isNot(contains('draft')));
  });
}
