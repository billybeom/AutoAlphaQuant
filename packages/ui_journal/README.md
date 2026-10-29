# ui_journal — M6 매매일지 · 보유현황

> **owner(계약·사양)**: Claude · **코드 담당**: **다른 AI(화면)**
> **청사진 카드**: **M6** journal-holdings-ui
> **화면 명세**: `11_앱설계/02_화면명세_M6_매매일지_보유현황.md`(화면 10개)
> **선행 의존**: **M2 계약 확정(G3) + 픽스처 실물(G4)** — 그 전에는 착수하지 않는다

## 무엇을 담나

매매일지 타임라인(첫 과제 **J-1**) · 일지 상세(결정 체인) · 보유현황 목록 · 종목 상세 · 차단 배너.

`H6-1` 보유현황 = `lib/src/holdings_overview.dart`(`HoldingsOverview()` · 주입 `journalHoldingsRepositoryProvider` — 조립 앱 3종이 override · R4b 가 import 해 재사용).

`H6-2` 종목 상세 = `lib/src/holding_detail.dart`(`HoldingDetail(holdingId:)`) · `H6-3` 슬리브·비중 = `lib/src/holdings_allocation.dart`(`HoldingsAllocation()` · 주입 `journalRebalanceRepositoryProvider` — 조립 앱 3종이 override · R13 셸 몫).

`L-1` 원장 차이 상세 = `lib/src/ledger_diffs.dart`(`LedgerDiffs()` · 공개 조각 `LedgerDiffTile(row:)` · 주입 2 `journalLedgerRepositoryProvider`·`journalLedgerTrustRepositoryProvider` = 이 파일 머리 — 조립 앱이 override) · `L-2` 정정 이력·감사 = `lib/src/ledger_repairs.dart`(`LedgerRepairs()` · `journalLedgerRepositoryProvider` 재사용) — R5a(PR #77 `a28db65`).

`A-1` 오늘의 매매 안내 = `lib/src/advice_inbox.dart`(`AdviceInbox()` · 주입 2 `journalAdviceRepositoryProvider`·`journalAdviceCommandApiProvider` = 이 파일 머리 — 조립 앱이 override) · 공개 조각 `lib/src/advice/advice_card.dart`(`AdviceCard(item:)` — R5c `A-2` 가 import) · 「지난 안내」 = `lib/src/advice_history.dart`(`AdviceHistory()` · `journalAdviceRepositoryProvider` 재사용) — R5b(PR #78 `4736b10`).

`A-2` 안내 상세 = `lib/src/advice_detail.dart`(`AdviceDetail(adviceId:)` · 배럴 · 데이터 2 = 이 파일 안 private — `journalAdviceRepositoryProvider` 재사용 · `AdviceCard` import) · `A-4` 미이행 사유 = `lib/src/journal_draft/advice_skip_form.dart`(`AdviceSkipForm(adviceId:)` · operator 배럴 `journal_draft.dart` · X7 제출·초안 꼴 첫 화면 — 새 주입 0 · J-3 주입 `journalCommandApiProvider`·`journalDraftStoreProvider` 재사용 · R5d `A-3` 이 `_restore`·`_applyReceipt`·`_afterExecuted`·`_locked` 꼴을 본뜬다) — R5c(PR #81 `df4a4d4`).

`A-3` 수기 체결 기록 = `lib/src/journal_draft/manual_fill_form.dart`(`ManualFillForm(adviceId:)` · operator 배럴 `journal_draft.dart` · 새 주입 0 — `journalAdviceRepositoryProvider`·`journalCommandApiProvider`·`journalDraftStoreProvider` 재사용 · 데이터 2 = 이 파일 안 private · R5c `A-4` 꼴(`_restore`·`_subscribe`·`_applyReceipt`·`_afterExecuted`·`_locked`)을 본뜸 · R5e `L-3` 가 이 꼴을 본뜬다) — R5d(PR #83 `a5de817`).

## 의존 — 허용 (01 §1-1)

`domain_contracts` · Flutter · `flutter_riverpod`. **이 셋이 전부다.**

## 의존 — 🔴 금지 (넣으면 C-3이 빌드를 막는다)

`core_engine` · **`decimal`** · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · `http` · KIS SDK.

> `decimal`이 없어야 화면이 금액 산술을 **아예 할 수 없다**. 있으면 경계 규칙 ①이 코드 리뷰 의존이 된다.

## 금지 4항 (병합 전 검수 항목)

1. **화면에서 재계산 금지** — 수익률·비중·손절선·기여도는 계약이 준 값을 표시만 한다. `.fold`·`.reduce`·`sum`·`DateTime.now()`·`DateTime.difference`가 특히 위험하다.
2. **사유 문구 생성 금지** — 규칙 트리거·청산 티어·거부 사유는 DTO의 `label` 계열 필드를 **그대로** 쓴다. 조건 분기로 문구를 고르는 것도 «생성»이다. 정적 UI 라벨만 `lib/l10n/labels.dart` **한 파일**에.
3. **홈·알림·위젯에 손익 금지** — `HoldingPnl`·`PerformanceSeries`를 타임라인·홈에 렌더하면 C-6이 실패한다. 종목 손익은 **기본 접힘**이고 손익 정렬은 제공하지 않는다.
4. **안전 화면 접근 금지** — 킬스위치·재개 게이트·정정 마법사는 `ui_safety`(Claude 소유)다.

## ✅ 허용되는 안전 관련 렌더 (01 §2-10 표)

경계는 «상태를 보였나»가 아니라 **«상태를 바꾸는 경로를 만들었나»**다.

- 허용: `BlockFlag`의 `label`·`clearInstruction` 배너 + `clearRoute` **딥링크** · `breakerLabel` 한 줄 · `LedgerDiffRow` **읽기 목록·상세**.
- 반려: `killSwitch`·`releaseProgress` 게이지 렌더 · `ResumeReport` **원본 화면** · 플래그 해제·재개·정정 **조작 위젯**.

## 이 패키지가 지는 규칙 3개

1. **정렬·페이징을 만들지 않는다.** rows는 엔진이 이미 정렬해서 준다. 무한 스크롤은 바닥에서 `limit += 100` 재구독이고 `hasMore == false`면 멈춘다.
2. **빈 상태를 지어내지 않는다.** `ListResult`의 `emptyKind`(없음/못 받음/해당 없음)와 `emptyLabel`을 그대로 쓴다.
3. **`prevented`는 실패가 아니라 성공이다** — 이중 발주 차단이 작동한 것이며 그렇게 렌더한다. `unknown`은 «실패»로 단정하지 말고 해소 보드로 딥링크한다.
4. **v2.31 P0S 정합**: 슬리브 칸은 **A/B/C 3칸**이되 그 3을 상수로 알지 않는다 — `SleeveCatalogEntry` 목록에서 온다. 새틀라이트는 «비활성»이 아니라 **숨김**이다.

## 지금 상태 — ✅ J-1~J-5 · H6-1~H6-3 · L-1·L-2 · A-1·「지난 안내」 · A-2·A-4 · A-3 병합(2026-10-29 · R5d PR #83 squash `a5de817`)

`flutter test` **579**(R5d 병합본 `a5de817` 실측 · 2026-10-29 · 538 + R5d 41 — `manual_fill_form_test` +33 · `a3_golden` +8) · 골든 PNG **144장**(`git ls-tree` 실측 · 136 + `a3_*` 8 · `test/golden/README.md` «🆕 R5») · R5 5장 중 4장 완료 — 다음 화면 카드 = 설계 12 §6 큐 7e R5e-Bob-L3(`L-3` · ▶ `docs/ai-context/send/R5e-Bob-L3.md` 「푸시해」 뒤 · 끝 기대 614 · 골든 +4 · R5 마지막) · 그 뒤 통합 담당 test-only PR(`advice_inbox_test` A1-04 두 경우 + `a1-overdue` 부재 1줄 · C4r5b-1·2 + `advice_skip_form_test` A4-07 «에러 뒤 열린 채인 스트림» · executed 접수증 두 번 · 미접수 뒤 재제출 성공 · C4r5c-1 + `manual_fill_form_test` A3-12 «에러 뒤 열린 채인 스트림» · A3-05 잠금 전부 · A3-04 선택마다 저장 · C4r5d-7).

~~`flutter test` **538**(R5c 병합본 실측 · 2026-10-29 · `origin/main` `a1aa807` = `df4a4d4` + 엔진 E8d2b(ui 변경 0) · 485 + R5c 53 — `advice_detail_test` +16 · `advice_skip_form_test` +27 · `a2_golden` +6 · `a4_golden` +4) · 골든 PNG **136장**(`git ls-tree` 실측 · 126 + `a2_*` 6 + `a4_*` 4 · `test/golden/README.md` «🆕 R5») · R5 5장 중 3장 완료 — 다음 화면 카드 = 설계 12 §6 큐 7d R5d-Bob-A3(`A-3` · ▶ `docs/ai-context/send/R5d-Bob-A3.md` 「푸시해」 뒤 · 끝 기대 579 · 골든 +8) → R5e(`L-3`) · 그 뒤 통합 담당 test-only PR(`advice_inbox_test` A1-04 두 경우 + `a1-overdue` 부재 1줄 · C4r5b-1·2 + `advice_skip_form_test` A4-07 «에러 뒤 열린 채인 스트림» · executed 접수증 두 번 · 미접수 뒤 재제출 성공 · C4r5c-1).~~(2026-10-29 R5c 판)

~~`flutter test` **485**(R5b 병합본 `4736b10` 실측 · 2026-10-29 · 430 + R5b 55 — `advice_inbox_test` +26 · `advice_history_test` +13 · `a1_golden` +14 · `a1_history_golden` +2) · 골든 PNG **126장**(`git ls-tree` 실측 · 110 + `a1_*` 14 + `a1_history` 2 · `test/golden/README.md` «🆕 R5») · R5 5장 중 2장 완료 — 다음 화면 카드 = 설계 12 §6 큐 7c R5c-Bob-A2A4(`A-2`·`A-4` · ▶ `docs/ai-context/send/R5c-Bob-A2A4.md` 「푸시해」 뒤 · 끝 기대 538 · 골든 +10) → R5d(`A-3`) → R5e(`L-3`) · 그 뒤 통합 담당 test-only PR(`advice_inbox_test` A1-04 두 경우 + `a1-overdue` 부재 1줄 · C4r5b-1·2).~~(2026-10-29 R5b 판)

~~`flutter test` **430**(R5a 병합본 `a28db65` 실측 · 2026-10-28 · 388 + R5a 42 — `ledger_diffs_test` +15 · `ledger_repairs_test` +15 · `l1_golden` +8 · `l2_golden` +4) · 골든 PNG **110장**(`git ls-tree` 실측 · 98 + `l1_*` 8 + `l2_*` 4 · `test/golden/README.md` «🆕 R5») · R5 5장 중 1장 완료 — 다음 화면 카드 = 설계 12 §6 큐 7b R5b-Bob-A1(`A-1`·「지난 안내」 · ▶ `docs/ai-context/send/R5b-Bob-A1.md` 「푸시해」 뒤 · 끝 기대 485 · 골든 +16) → R5c(`A-2`·`A-4`) → R5d(`A-3`) → R5e(`L-3`).~~(2026-10-28 판)

~~`flutter test` **388**(R4b 병합본 `fe4fbff` 실측 · 2026-10-21) · 골든 PNG **98장**(`test/golden/README.md`) · R4 2장 완료 — 다음 화면 카드 = 설계 12 §6 큐 7번 R5-Bob-L-X7(`L-1`·`L-2`·`A-1`~`A-4`·`L-3` · ⬜ 조립 대기).~~(2026-10-21 판)
