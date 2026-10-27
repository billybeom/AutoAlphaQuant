# 발송 패킷 R5d-Bob-A3 — A-3 수기 체결 기록 (계약 v1.12~v1.14 · prompt_M6 v2 · R5 5장 중 4번째 · M6 X7 기록 · operator)

> ⬜ **_대기 — R5c 병합 기록 때 `send/` 로**(2026-10-27 조립 · 앱 기록 가지 `rec/r5`) — 남은 것: ① R5c 병합(`R5c-Bob-A2A4` · squash = `__R5C_SQ__` — R5c 병합 기록 커밋이 이 파일의 자리표시자를 채우고 `send/` 로 옮긴다) ② 🔴 **선행 M2 보강 — C-46 ⑰ 의 `ManualFillPrefillFields.quantity` 예외**(아래 발주자 확인 ① · ⬜ 결정 · ⬜ 작은 M2 PR — 지금 계약으로는 이 카드의 필수 줄 `ManualFillPrefillFields.quantity` 가 C-46 ⑰ `\.quantity\b` 에 걸려 `test:contracts` 가 실패한다 · 2026-10-27 판독 실측) ③ 누적 드라이런(worktree `C:/Work/AAQ-claude-r5dry` · 가지 `dry/r5d` = `dry/r5c` 끝(R5c 병합본 흉내) + ② 의 보강을 얹은 판에서 · 권장 5커밋 · ⟦실측⟧ 표식을 실측으로 — `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R5d-Bob-A3.md` 로 센다 · 🔴 보내기 전 0 · `__R5C_SQ__` 0) ④ 실제 병합본 위 재드라이런(앞 카드가 통합 수정으로 바뀌면) ⑤ 드라이런 브랜치 사전검사 ① 🔴 0 · ② `a3` 8 🔴 0 ⑥ 발주자 확인(아래 ①~⑫ — 카드 기본값 = 권고) ⑦ 재분할 판정(임계 = 새 `testWidgets(`·`test(` 줄 > 33 · lib > +900 · 새 PNG > 16 — 계획 = 줄 15 · PNG 8) → 「푸시해」 → 머리 첫 줄 ▶.
> 만든 날 2026-10-27 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R5d-Bob-A3` 행 + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · PR 본문은 통합 담당 · 재제출 = 전체판 + 상자 · 골든 높이 = 카드 확정값 + 여백 재량 · 커밋 = 제목만) + R4a·R4b·R13a·R13b C4 이월 부록의 **공통 교훈만**(R5d 의 이월 = R5a~R5c C4 결과 — 병합 기록 때 ⟦실측⟧) · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-22_R5R13선행_계약v1.12_설계서.md` §8-1~§8-3 · K4 · K10 · K11 · K19 · K20 · K21 · K35 · K37(✅ 발주자 확정 2026-10-22) · 조문 = `01_…` §21-3 · §21-6 `A-3` 행 · §21-7 · §21-8 · §21-10-4 · §21-12-1(C-46 ⑰~㉖) · §21-16-1 · §12-1(초안) · §12-4(접수증 잠금) · `02_…` §3-A · §3-8 · §3-10 끝 «계약 v1.12» 블록 ⓐⓖⓙⓚ · 코드 = `packages/domain_contracts`(`AdviceItem` · `ManualFillFormSpec` · `SymbolOption` · `AccountOption` · `SideOption` · `TradeDateOption` · `ManualFillSubmission` · `ManualFillInput` · `ManualFillPrefillFields` · `DraftKey` · `DraftRecord` · `CommandReceipt`(`retryCode`·`retryLabel`) · `CommandState` · `AppNavActions.back` · `AdviceRepository.findById`·`watchManualFillFormSpec` · `CommandApi.recordManualFill`·`watchCommand` · 받침대 · C-46).
> 사전 조건 — ✅ 계약 v1.12(PR #68 `fb67caf`) · ✅ v1.13 · ✅ v1.14(`contractVersion = '1.14.0'` — ⟦실측⟧ 엔진 카드·② 보강이 버전을 올리면 0단계 버전 줄을 병합 기록이 고친다) · ✅ `prompt_M6` v2 · ⬜ R5a·R5b 병합(`__R5A_SQ__` · `__R5B_SQ__`) · ⬜ **R5c 병합(`__R5C_SQ__`)** — 이 카드는 R5c 의 `JournalLabels.adviceNotFound` · `test/advice_skip_fakes.dart`(`FakeAdviceFormRepository` · `adviceFormRefTexts`)를 **import 만** 하고 `advice_skip_form.dart` 의 제출·초안·잠금 꼴을 본뜬다 · ⬜ **② M2 보강**. 시작 기준 = R5c 병합본(+ ② 보강)의 `flutter test`(packages/ui_journal) = **⟦실측⟧**(카드 계획 = 481 + R5c 48 = 529) · 이 카드 끝 기대 = 시작 기준 N + **뷰 28 + 골든 8 = N + 36**(카드 계획 · 드라이런 ⟦실측⟧) · `domain_contracts` «+⟦실측⟧ ~30»(② 보강이 테스트를 더하면 그 수 · 이 카드 몫 0).
> 카드 기본값(카드 권한 — 🔵 아래 «발주자 확인» ①~⑫ 이 권고대로면 그대로): ⓐ 위젯 = `ManualFillForm({super.key, required this.adviceId})`(`lib/src/journal_draft/manual_fill_form.dart` · **operator** · ConsumerStatefulWidget) ⓑ 주입 = **새 주입 0** — `journalAdviceRepositoryProvider`(R5b `advice_inbox.dart`) · `journalCommandApiProvider`·`journalDraftStoreProvider`(J-3) · 안전·링크·시계(`timeline.dart`) import 만 · 데이터 2 = 이 파일 안 private(`findById` FutureProvider.family · `watchManualFillFormSpec()` StreamProvider) ⓒ 입력란은 **비운 채** 연다 · 위 = 읽기 전용 참조 카드(엔진 글자 6) · 프리필 = 「안내 수량 채우기」 버튼 하나(`prefillQuantityLabel` non-null 일 때 · 탭 = 수량 칸 ← `prefillQuantityText` + `prefilledFields` 에 `ManualFillPrefillFields.quantity`) ⓓ 거래일 = `tradeDateOptions` 칩 · 방향 = `sides` 칩 · 종목 = `symbols` 드롭다운 · 계좌 = `accounts` 드롭다운 · 수량·가격·수수료·세금 = 원문 칸(검사·파싱 0 · K4) ⓔ 제출 = `recordManualFill(ManualFillSubmission(adviceId:, input:, retryCodes:))` · 거부 = 입력 보존 + `stateLabel` + `retryLabel` 버튼(누르면 `retryCode` 를 `retryCodes` 에 **더해** 다시 제출 · 누적 · K20) ⓕ 접수증 = R5c `A-4` 꼴(첫 접수증 전 잠금 · `clear` = `executed` 한 곳 · 이 화면이 낸 명령 = `clear` + pop · 복원 id = `clear` + 빈 폼 · K11) · 초안 = 입력마다 `save`(J-3 꼴) ⓖ 정적 라벨 6(⑪) ⓗ Key 접두 `a3-`(순번만) ⓘ 테스트 = `test/manual_fill_fakes.dart`(새 · 자기 파일) · `test/manual_fill_form_test.dart` · 골든 4이름 8장(`a3_golden_test.dart`) ⓙ 공용 파일 2(`labels.dart` R5d 절 · operator 배럴 export 1줄 — 정렬 자리) = **더하기만**.
> 🔴 **카드 덮개 필수 문장(02 §3-8 · §3-10 끝 v1.12 블록 · 01 §21-3 · §21-6 · §21-7 · §21-8)** — «`A-3` 은 이미 한 매매를 **사실로** 적는 폼이다 — 입력란은 비운 채 열고 참조 카드는 복사 대상이지 초기값이 아니다 · 프리필 = 수량 버튼 하나(가격·거래일 버튼 0) · 부분 체결 버튼·시간외·단주 체크박스·슬리브 선택·자유 티커·연속 입력 0» · «원문 → 명령 — 화면은 `int.parse`·`Decimal`·빈칸 검사·상한 검사·`CommandContext`·`ManualFillRecord(` 를 하지 않는다 · 방향 = `option.side` 그대로 · 거래일 = `option.date` 그대로(날짜를 만들거나 비교·서식 0) · 형식 오류 = 구현이 낸 `INPUT_INVALID` 접수증의 `stateLabel`» · «낙관 갱신 0 — `requested`·보류 3상태 = 머문다 · 이 화면이 낸 명령의 `executed` 에서만 `clear` + pop · 거부 = 입력 보존» · «화면은 안전 상태를 읽지 않는다 — 제출 부재 = `blockedText` · 폼 배너 = `bannerText` · `.watchState(`·`activeFlags`·`FlagIds` 0». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — K4(원문 DTO · 검증·파싱 0) · K10 ⓐ(기존 operator 배럴 · 주입 재사용) · K11(복원 id `executed` = `clear` + 빈 폼) · K19(`prefillQuantityText`·`prefillQuantityLabel` · `ManualFillPrefillFields.quantity`) · K20(`retryLabel` → `retryCodes` 누적) · K21(`blockedText`·`bannerText`) · K35(R5d 8장) · K37(`sides`·`tradeDateOptions` · `minTradeDate`·`maxTradeDate`·`nonTradingDates`·`quantityMax` ui 미참조) = **✅ 발주자 확정(2026-10-22 · 01 §21-14)**.
> 🔵 **발주자 확인 대기(카드 기본값 = 권고 · 🔴 확인 전 ▶ 금지)**: ① 🔴 **선행 M2 보강 — C-46 ⑰ 과 `ManualFillPrefillFields.quantity`**(판독 실측 2026-10-27: `_dotField(_rawCommonFields)` = `\.(?:…|quantity|…)\b` 가 폼 파일의 `ManualFillPrefillFields.quantity` 를 잡는다 · 자체 검증 음성 스니펫에 이 꼴이 없다 · 02 §3-8·§3-10 끝 ⓖ·prompt 202~203행은 그 상수를 쓰라고 적었다) → 권고 = **C-46 ⑰ 에 앞보기 예외 한 개**(`RegExp('(?<!ManualFillPrefillFields)\\.(?:…)\\b')` 꼴 · 음성 스니펫 `ManualFillPrefillFields.quantity` 1줄 + 양성 `r.quantity` 그대로 · 계약 코드·픽스처 무변경 — 버전 판정은 M2 창) · 대안 ⓑ = 상수 이름을 `quantityField` 류로 바꾸기(공개 API 변경 · `prefilledFields` 값 `'quantity'` 그대로) ⓒ = `ManualFillPrefillFields.values` 를 넣기(뜻이 «전부» 라 권고하지 않음) · ⬜ 보강 PR 병합 전 이 카드 ▶ 금지 · 0단계 확인 줄 = ⟦실측⟧ ② **참조 카드 = 엔진 글자 6**(`symbolLabel?` · `sideLabel?` · `sizingLabel` · `priceBand?.label` · `validityLabel` · `progressLabel` — 02 §3-8 «종목·방향·수량·priceBand.label·validityLabel» + 01 §21-10-4 `a3_advice_linked` «진행 글자» · R5c `A-4` 참조 카드와 같은 글자 — 도우미 `adviceFormRefTexts` 재사용) ③ **선택 표시 = `==` 하나**(선택지 값 == 고른 값 · 거래일·방향·종목·계좌 — 크기 비교·차이·서식 0 · 드롭다운 값이 선택지에 없으면 null 로 그린다 = `_known` 한 메서드 — DropdownButton 단언 방지) ④ **입력 모양** = 거래일·방향 = `ChoiceChip` 줄(정적 머리 1줄씩) · 종목·계좌 = `DropdownButton<String>`(`isExpanded` · 힌트 = 정적 라벨) · 수량·가격·수수료·세금 = `TextField`(라벨 = 정적 · 가격 도움말 = `priceHintLabel` · `inputFormatters` 0) ⑤ **수량 채우기 표식** = 누른 뒤 유지(칸을 고쳐도 `prefilledFields` 그대로 — 사실 = «눌렀다» · 비교는 엔진) · 복원 = 초안 `prefilledFields` 에 그 값이 있으면 유지 ⑥ **제출 버튼 = 입력 검사 0**(빈칸이어도 활성 — K4 · 구현이 `INPUT_INVALID`) · 잠금 = R5c `A-4` 와 같은 `CommandState` 전수 switch ⑦ **`deviationNote` = UI 0**(제출·초안 = 기본값 '' · v1 칸 없음) ⑧ **사양 신선도 초과 = 폼 열지 않음** — 머리 + `JournalStaleBanner`(엔진 `staleLabel` 이 그 안에) + 배너만(참조 카드·칸·버튼 0 · R5c `A-4` 와 같다) ⑨ **재제출 버튼** = 제출 버튼과 따로(둘 다 잠금 규칙 하나) · `retryCodes` = 폼 수명 동안 누적(초안 밖 · 복원 0 · 빈 폼에서 비움) ⑩ 골든 크기 `a3` = `Size(390, ⟦실측⟧)`(권고 1700 · 칸 9 + 버튼) · `a3_form_spec_stale` 의 맨 아래 Key = `a3-asof`(폼을 열지 않아 Key 달린 것이 머리뿐) ⑪ 정적 라벨 6(`manualFillTradeDate` «거래일» · `manualFillSymbol` «종목» · `manualFillSide` «방향» · `manualFillQuantity` «수량» · `manualFillPrice` «가격» · `manualFillAccount` «계좌») + 기존 `commission` «수수료» · `tax` «세금» · `draftSubmit` «제출» · `adviceNotFound`(R5c) 재사용 ⑫ `a3_rejected_price` 흐름 = 초안 시드(`draft_records_x7` rows[0] · ad_0002) 복원 + 제출 탭 → `recordManualFill` Future = `fill_rejected_price` rows[0](`retryLabel` 버튼 보임 · 형제 키 `preserved_input`·`reject_reason` 은 읽지 않는다).
> 드라이런: ⬜ ⟦실측⟧(worktree `C:/Work/AAQ-claude-r5dry` · 가지 `dry/r5d`(`dry/r5c` 끝 + ② 보강에서) · 시작 ⟦실측⟧ → 끝 ⟦실측⟧ · 파일별 ⟦실측⟧ · 사전검사 ⟦실측⟧ · 정적 묶음 ⟦실측⟧ · 변이 ⟦실측⟧).
> 프롬프트 = `docs/ai-context/prompt_M6.md`(**v2 판 275줄** · 2행 `{{범위}}` · 121행 «이번 과제 범위» → 이 카드가 덮는다(R5d = `A-3`) · 130행 PR 제목 = 형식만 → «[M6] A-3 수기 체결 기록» · X7 기록 공통 = 189~199행 · `A-3` = 200~205행 · 자체 점검 23항 = 252~274행 · 수치·금액 = 68~74행). 🔴 Bob **새 대화** 전제 — 앞 카드 대화를 기억하지 못합니다.
> R4·R13·R5a~R5c 교훈 반영(공통 교훈만): PNG 열람 = 이름마다 light 1장(4장) · dark 행 = light 행 칸 글자 그대로(dy 같을 때만) · 구독마다 «로딩·에러 × 갈래» · 흐름 = 클로저 칸 · 기대 링크·명령·초안 = 목록 칸 · 🔴 bool 칸 + if · `name ==`·`which ==` · `opened[0]` · `expect(a || b, isTrue)` = 반려 꼴 · 전제 if 밖 + `// pre` · 픽스처 = `main()` 머리 `final` · 가짜 공장 = `call` 삼항 · 커밋마다 `git add <파일>` · «23항 줄 수» 상자 · 골든 높이 = 카드 확정값(늘리지 않는다 · 여백만 + 측정 행) · lib 의 nullable `!` 0 · 허용 집합에 링크 문자열 0 · 🆕 `TextEditingController.clear(` 금지 — 칸 비우기 = `.text = ''`(C-46 ㉓ 은 폼 파일의 **모든** `.clear(` 를 본다 · 초안 `clear` 한 곳만) · ⟦실측⟧ R5a~R5c C4 이월(병합 기록 때 이 줄에 더한다).

## 0. 한 줄 목적

`ManualFillForm(adviceId:)`(operator) 가 `findById` 의 안내로 읽기 전용 참조 카드를 그리고, 폼 사양(`watchManualFillFormSpec()`)의 선택지(거래일·방향·종목·계좌)와 원문 칸(수량·가격·수수료·세금)을 **비운 채** 열어(프리필 = 수량 버튼 하나) 입력마다 초안을 저장하고, `recordManualFill(ManualFillSubmission)` 으로 원문을 그대로 제출해 접수증을 R5c `A-4` 꼴(잠금 · `executed` = `clear` + pop · 복원 id = 빈 폼 · 거부 = 보존 + `retryLabel` 재제출 누적)로 그리는 X7 기록 화면을 계약 v1.12 그대로 짓기(검증·파싱 0 · 비교 0 · 낙관 갱신 0).

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-a3-fill`**(base = 최신 `origin/main` · `--no-track` · 브랜치 이름 = 설계 12 §3 R5d 행 · 01 §21-16-1 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 `send/_대기/` 에 있습니다(R5c 병합 기록이 옮긴다 · 선행 M2 보강도 필요).
2. Bob 에 R5c 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R5d-Bob-A3.md> (🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다 · `send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R5d-Bob-A3 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 바깥 울타리 = 백틱 네 개 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R5c-Bob-A2A4*.md` 를 붙여넣지 않습니다.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R5d-Bob-A3 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R5d-Bob-A3 — 범위: A-3 수기 체결 기록(ManualFillForm(adviceId:) — operator · 머리 · 오래됨 · 배너 · 폼 배너 · 참조 카드 · 수량 채우기 버튼 · 거래일·방향 칩 · 종목·계좌 드롭다운 · 수량·가격·수수료·세금 칸 ·
  원본 고지 · 접수증 · 재제출 버튼 · 접수 실패 · 재구독 · 제출 또는 차단 문장 · 부재) + 정적 라벨 6 + operator 배럴 export 1줄.
🔴 A-3 은 이미 한 매매를 사실로 적는 폼이다 — 입력란은 비운 채 연다 · 참조 카드 = 복사 대상(초기값 아님) · 프리필 = 수량 버튼 하나 · 부분 체결 버튼·시간외 체크박스·슬리브 선택·자유 티커·연속 입력 0.
🔴 원문 → 명령 — int.parse · Decimal · 빈칸·상한 검사 · CommandContext · ManualFillRecord( 0 · 방향 = option.side · 거래일 = option.date(날짜 만들기·비교·서식 0) · 형식 오류 = 구현의 INPUT_INVALID 접수증 stateLabel.
🔴 낙관 갱신 0 — requested·보류 3상태 = 머문다 · 이 화면이 낸 명령의 executed = clear + pop · 복원 id 의 executed = clear + 빈 폼 · 거부 = 입력 보존 + stateLabel + retryLabel 버튼(retryCodes 누적).
🔴 화면은 안전 상태를 읽지 않는다 — .watchState( · activeFlags · FlagIds · killSwitch 0 · 배너 = JournalSafetyBanners(safety:) · 제출 부재 = blockedText · 폼 배너 = bannerText.
하지 않는 것: L-1·L-2(R5a) · A-1·AdviceCard(R5b) · A-2·A-4(R5c — 병합됨 · 고치지 않음) · L-3(R5e) · 정정·무효(M5-12) · 안내 밖 수기(M5-6 · adviceId null) · 셸·라우터 · domain_contracts·pubspec 수정 · 다른 ui_* · 기존 화면·테스트 수정.
🔴 이 카드가 docs/ai-context/prompt_M6.md(판 v2) 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 24항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R5c(ui/m6-a2a4 — 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_journal/lib/src/journal_draft/manual_fill_form.dart · ManualFillForm 이 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-a2a4 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m6-a3-fill origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git branch -r --contains __R5C_SQ__                                                                                         ← «  origin/main» 이 보여야 함(R5c 병합)
  git grep -c "class AdviceSkipForm extends ConsumerStatefulWidget" -- packages/ui_journal/lib/src/journal_draft/advice_skip_form.dart   ← «…advice_skip_form.dart:1»(R5c 병합본 · 본뜰 꼴 · ⟦실측⟧ 꼴)
  git grep -c "static const String adviceNotFound = " -- packages/ui_journal/lib/l10n/labels.dart                             ← «…labels.dart:1»(R5c · import 해서 쓴다)
  git grep -c "static const String adviceRecordedFills = " -- packages/ui_journal/lib/l10n/labels.dart                        ← «…labels.dart:1»(R5c 절의 마지막 상수 — R5d 절은 그 뒤 · ⟦실측⟧)
  git grep -c "class FakeAdviceFormRepository extends UnimplementedAdviceRepository" -- packages/ui_journal/test/advice_skip_fakes.dart   ← «…advice_skip_fakes.dart:1»(R5c 도우미 — import 해서 쓴다 · ⟦실측⟧ 꼴)
  git grep -c "List<String> adviceFormRefTexts(AdviceItem v)" -- packages/ui_journal/test/advice_skip_fakes.dart               ← «…advice_skip_fakes.dart:1»(⟦실측⟧ 꼴)
  git grep -c "ManualFillPrefillFields" -- packages/domain_contracts/test/contracts/c46_advice_x7_test.dart                   ← «…c46_advice_x7_test.dart:⟦실측⟧»(🔴 선행 M2 보강 — ⑰ 의 예외가 들어간 판 · 출력 없음이면 멈춤)
  git grep -c "contractVersion = '1.14.0'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»(⟦실측⟧)
  git grep -c "Future<CommandReceipt> recordManualFill(ManualFillSubmission submission);" -- packages/domain_contracts/lib/src/commands/command_api.dart   ← «…command_api.dart:1»
  git grep -c "Stream<ManualFillFormSpec> watchManualFillFormSpec();" -- packages/domain_contracts/lib/src/repositories/advice_repository.dart   ← «…advice_repository.dart:1»
  git grep -c "static const String quantity = 'quantity';" -- packages/domain_contracts/lib/src/labels/advice_codes.dart      ← «…advice_codes.dart:1»(ManualFillPrefillFields)
  git grep -c "required List<TradeDateOption> tradeDateOptions," -- packages/domain_contracts/lib/src/dto/advice.dart         ← «…advice.dart:1»
  git grep -c "String? prefillQuantityLabel," -- packages/domain_contracts/lib/src/dto/advice.dart                           ← «…advice.dart:1»
  git grep -c "String? retryLabel," -- packages/domain_contracts/lib/src/commands/command_receipt.dart                       ← «…command_receipt.dart:1»
  git grep -c "'lib/src/journal_draft/manual_fill_form.dart'," -- packages/domain_contracts/test/contracts/c46_advice_x7_test.dart   ← «…c46_advice_x7_test.dart:1»(폼 파일 이름 = 소스 스캔 대상)
  git grep -c "판 v2" -- docs/ai-context/prompt_M6.md                                                                         ← «…prompt_M6.md:1»(없으면 멈춤)
  git grep -c "a3_rejected_price" -- packages/ui_journal/test/golden/README.md                                                 ← 숫자 하나(golden README «🆕 R5» 절)
  ls docs/ai-context/send/R5d-Bob-A3.md                                              ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/A3_questions.md                                           ← 보여야 함(빈 표가 이미 있다)
  ls tool/precheck.dart                                                              ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_form_spec.json                       ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_form_spec_stale.json                 ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_form_spec_blocked.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_12.json                            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_detail_partial.json                ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_rejected_price.json                  ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/manual_fill_receipts_7.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/draft_records_x7.json                     ← 보여야 함
     (🔴 경로는 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — R5c 병합·M2 보강보다 카드가 먼저 왔습니다 · && 가 안 되는 셸이면 한 줄씩)
  아래 세 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R5d 가 들어간 것 — 멈추고 알림):
  ls packages/ui_journal/lib/src/journal_draft/manual_fill_form.dart                 ← 없어야 함
  git grep -c "ManualFillForm(" -- "packages/ui_journal/*.dart"                      ← 출력 없음이어야 함(🔵 golden README 의 글자는 세지 않는다 — .dart 만)
  git grep -c "a3-" -- "packages/ui_journal/*.dart"                                  ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · 브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_journal
  flutter test   ← 시작 기준: R5c 병합본 전부 통과 · 0 실패 · 기대 «+⟦실측⟧: All tests passed!»(앞 시각은 달라도 된다)(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · 다르면 멈추지 말고 PR 본문에 까닭 한 줄 —
                   그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·AppNavActions·C-46) > 이 카드(지시) > 01 §21 > 02 §3-10 끝 v1.12 블록 > 02 §3-A·§3-8 본문·그림 M6-26 > prompt_M6.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox/A3_questions.md 만. 새 파일 = lib/src/journal_draft/manual_fill_form.dart · test/manual_fill_fakes.dart · test/manual_fill_form_test.dart · test/golden/a3_golden_test.dart · 새 PNG 8.
   공용 2파일은 **더하기만**(기존 줄 한 글자도 바꾸지 않는다 · 정적 D26 의 삭제 수 0): lib/l10n/labels.dart = JournalLabels 안 R5c 절의 마지막 상수(adviceRecordedFills · ⟦실측⟧) 뒤 · 닫는 } 앞에 R5d 절 ·
     lib/journal_draft.dart = export 'src/journal_draft/manual_fill_form.dart'; 한 줄(🔴 끝 줄 — 기존 export 'src/journal_draft/journal_draft_form.dart'; **뒤** · «j» < «m»).
   고치면 반려: 그 밖의 ui_journal 파일 전부(lib/ui_journal.dart · lib/src/common/** · lib/src/timeline.dart · lib/src/advice/** · lib/src/advice_*.dart · lib/src/journal_draft/advice_skip_form.dart(R5c) · journal_draft_form.dart(J-3) · lib/src/ledger_* ·
     기존 테스트 파일 전부(🔴 test/advice_skip_fakes.dart(R5c) · test/advice_fakes.dart(R5b) · test/holdings_overview_fakes.dart 는 import 만) · golden_support.dart · golden README · flutter_test_config.dart · goldens/ 의 기존 PNG(⟦실측⟧ 136장) ·
     pubspec.yaml · analysis_options.yaml · README.md) · domain_contracts/**(🔴 ② 보강은 통합 담당의 M2 PR 몫 — Bob 은 고치지 않는다) · apps/** · 다른 ui_*.
 2 화면은 받은 글자와 null 여부만 본다 — 값 = DTO 의 *Label·*Text·label 원문 그대로 · 원값·.wire·.name·코드 표시 금지 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) ·
   한국어 리터럴 = labels.dart 의 JournalLabels 에만(테스트에도 금지) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱만).
 3 읽지 않는 필드(카드가 정함 — 질문 아님): AdviceItem 은 참조 카드 글자 6(symbolLabel · sideLabel · sizingLabel · priceBand.label · validityLabel · progressLabel) + prefillQuantityText · prefillQuantityLabel 만 ·
   ManualFillFormSpec 의 skipReasons · skipNoticeText(A-4 몫) · minTradeDate · maxTradeDate · nonTradingDates · quantityMax(🔴 K37 ui 미참조) · SymbolOption 의 sleeve(🔴 슬리브 선택 0) · AsOf 의 staleReasonCode ·
   CommandReceipt 의 kind · requestedAt · expiresAt · nonce · issuedByDeviceId · rejectReasonCode(🔴 해석·분기 0) · DraftRecord 의 journal · adviceSkip · selfReport · ManualFillInput 의 deviationNote(🔵 UI 0 · 발주자 확인 ⑦).
   🔵 읽는 원값(폼이라 C-46 ⑰ 읽기 목록 밖 · 선택·제출에만): SideOption.side · TradeDateOption.date · SymbolOption.symbol · AccountOption.alias · CommandReceipt.state(잠금 switch) · commandId(구독) · retryCode(재제출 버튼이 retryCodes 에 더하는 한 곳 — 해석 0).
   🔴 C-46 ⑰~㉔ 이 이 파일(journal_draft/manual_fill_form.dart = 폼)의 .status .onHold .suppressed .actionId .quantity(🔵 ② 보강 뒤 ManualFillPrefillFields.quantity 만 예외) .recordedQuantity .quantityMax .minTradeDate .maxTradeDate .nonTradingDates
     .low .high .reference .sleeve .wire .name .closeReasonCode .asOfTradeDate .decision · 객체 패턴 구조 분해 · AdviceStatus. AdviceActionId. AdviceSkipReason. OrderSide.(점 축약 포함 — side: .buy 꼴도) · *.parse · tryParse · Decimal · .round( 류 · ~/ · showDatePicker ·
     CommandContext · ManualFillRecord( · .watchState( · activeFlags · FlagIds · markerOnly · .killSwitch · watchDecisionDetail · JournalRepository · HoldingsRepository · AppRoutes. · aaq:// · .clear( 가 executed 갈래 밖 · dispose 안 ref. 를 기계로 본다
     (주석은 벗기고 본다 · ⑲ 는 문자열도 벗긴다).
 4 이동 = pop 하나 — 이 화면이 낸 명령의 executed 처리 안 ref.read(journalLinkOpenerProvider).open(AppNavActions.back) · 그 밖 링크 0(참조 카드·선택지에 링크 0) · 🔴 lib·테스트에 'aaq://'·'handbook://' 리터럴 0 · Navigator 0 ·
   공개 위젯 생성자 = ManualFillForm({super.key, required this.adviceId}) 하나.
 5 산술·판정 0 — 허용되는 것은 넷뿐이다: ⓐ 신선도 한 식(spec.asOf.observedAt.add(spec.asOf.staleAfter).isBefore(clock.nowUtc())) ⓑ 선택 표시 = 선택지 값 == 고른 값(== 하나 · 발주자 확인 ③) ⓒ 드롭다운 값이 선택지에 있는가(_known 한 메서드 — for + == ) ·
   ⓓ 잠금 = CommandState 전수 switch 하나 + 진행 bool. 그 밖에 거르지도 세지도 정렬하지도 자르지도 묶지도 옮기지도 않는다(받은 순서 · 순번 = .indexed 의 i) · 입력 글자 검사·변환 0(.trim( · .isEmpty 검사 · 길이 · 숫자 판정 0) ·
   목록 길이·int 를 글자로 0 · .length 0 · maxLines · TextOverflow · FittedBox · .take( 0 · DateTime.now 0 · 날짜 차이·서식 0 · FeatureFlags · RunMode · OperatingMode 0.
 6 switch = 잠금 하나뿐(CommandState 9값 전수 · default·_ 0 · C-12 · R5c advice_skip_form.dart 의 _locked 꼴).
 7 시계 = journalClockProvider(주입 Clock.nowUtc() 만) · 공통 조각 = JournalAsOfHeader · JournalStaleBanner · JournalSafetyBanners · JournalSkeleton · JournalErrorView 재사용(🔴 무수정 · 새 공용 조각 0) ·
   상태 갈래 = 아래 «상태 표» 글자 그대로 · 스피너 금지 · 배너 = ref.watch(journalSafetyStateProvider).valueOrNull 을 JournalSafetyBanners(safety:) 에 넘기기만.
 8 화면은 본문이다 — Scaffold · AppBar · SafeArea · ScaffoldMessenger · SnackBar · Navigator · FloatingActionButton 0(주석에도) · ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 ·
   간격·크기는 정수·N.0 만 · 띠 높이 예약 0 · Checkbox · Switch · inputFormatters · showDatePicker 0(시간외·단주 체크박스 0 · 달력 0).
 9 프로바이더 — 이름·타입·파일 = 아래 «주입 구조» 글자 그대로 · autoDispose 0 · 새 주입 0 · 데이터 2(이 파일 안 private · import 바로 뒤) · 기존 journalAdviceRepositoryProvider(advice_inbox.dart) · journalCommandApiProvider · journalDraftStoreProvider(journal_draft_form.dart) ·
   journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider(timeline.dart) 는 import 해서 쓴다 · 주입은 콜백·initState 안 ref.read(build 에서 명령·초안 주입 watch 0) · 데이터는 build 에서 ref.watch · lib 의 nullable 에 ! 0(정적 D33).
10 테스트 = 받침대 extends(R5c 의 FakeAdviceFormRepository 재사용 — import 만 · UnimplementedCommandApi · RecordingDraftStore · FakeHoldingsSafetyRepository — implements 금지) · 받은 인자 전부 기록(recordManualFill 의 제출 · watchCommand 의 id) · 호출마다 새 Future/Stream ·
   가짜 공장 = 받은 call 로 삼항(C4r4b-7) · 따로 세는 변수 0 · 공장 안 early-return if 0 · 픽스처 = main() 머리에서 final 로 한 번(setUpAll + late 금지) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 · testWidgets 본문 첫머리 · 문장마다 끝에 `// pre`(정적 D31) ·
   동작은 UI 를 실제로 눌러서(ensureVisible 뒤 tap · 칸 = enterText · 드롭다운 = 그 Key 탭 → pumpAndSettle → find.text(<선택지 글자>).last 탭) · 🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 ·
   정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(AdviceItem(…) · ManualFillFormSpec(…) · CommandReceipt(…) · DraftKey(…) · DraftRecord(…) · ManualFillSubmission(…) · ManualFillInput(…) 0 ·
     기대 초안 키 = draft_records_x7 rows[0].key · 기대 제출 본문 = 초안 시드 본문(drafts.rows[0].manualFill) 또는 칸마다 필드 비교) · 🔵 예외 1 = 복원 id 시드: manual_fill_fakes.dart 의 manualFillSeedWithCommand 한 곳만 copyWith(정적 D28 1줄) ·
   링크·명령·초안 기록 = 목록 == 목록(expect(opener.opened, c.opened) · expect(store.cleared, c.cleared) — 🔴 원소 비교 [0] 금지) · 🔴 흐름은 경우 칸의 클로저(steps)에 · bool 칸 + if · c.name == · which == · expect(a || b, isTrue) = 반려(정적 D32) ·
   경우마다 갈리는 단언은 «없는 쪽» 견본(if/else 양쪽) 또는 expect(finder, c.<Matcher 칸>) 한 꼴 · 테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII(입력 글자 '8' 류 포함) ·
   «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2) · 단언은 따로(괄호 단언 금지) · 스켈레톤 1 = expect(find.byKey(const Key('a3-loading')), findsOneWidget) 꼴 ·
   operator 화면 = import 'package:ui_journal/journal_draft.dart'; · Key 를 단 묶음의 글자 = adviceShownTexts(tester, <Finder>)(R5b advice_fakes.dart) == 기대 목록 · 칸 글자 = tester.widget<TextField>(find.byKey(…)).controller?.text ·
   칩 선택 = tester.widget<ChoiceChip>(find.byKey(…)).selected · 드롭다운 값 = tester.widget<DropdownButton<String>>(find.byKey(…)).value · 값을 끝까지 내지 않는 것 = Completer<T>().future ·
   폼의 Future 에러·스트림 에러 테스트는 끝에 expect(tester.takeException(), isNotNull);(폼은 _report 로 보고한다 — J-3·R5c 꼴).
   ⓡ = 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 한 줄 — 🔴 n = 정수 리터럴(거래일 6 · 방향 2) · 끝 Key 도 리터럴(a3-date-6 · a3-side-2) ·
      🔴 hasLength( 는 ⓗ 줄에만 · 정적 D18·D19 가 git grep -c 로 센다 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(manual_fill_form_test.dart ⓡ 12 · ⓗ 2 · 다르면 제출 전에 고친다 · 다른 채 내면 반려).
   «없는 쪽» 견본(코드 글자 · 이름은 재량 · A3-03 · A3-05 · A3-09):
        final String? want = c.prefill;                    // 경우 칸 = 기대 글자 String?(open = ad0002.prefillQuantityLabel · filled = null)
        if (want != null) {
          expect(tester.widget<Text>(find.descendant(of: find.byKey(const Key('a3-prefill')), matching: find.byType(Text))).data, want);
        } else {
          expect(find.byKey(const Key('a3-prefill')), findsNothing);
        }
        🔴 반려 꼴: if (want != null) { expect(…); }(else 없음) · if (want != null) { await tester.tap(…); … }(흐름이 if 안) · if (c.name == 'rejected') {…} · expect(cmd.recorded[0], …) · expect(data.isEmpty || allowed.contains(data), isTrue)
   «화면의 Text 전부» 단언 = 이 코드 글자 꼴(A3-14):
          final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
          expect(shown, isNotEmpty);
          for (final String? data in shown) {
            expect(data, isIn(allowed));
          }
        (allowed = manual_fill_fakes.dart 의 manualFillAllowed — null-aware 원소로 만든 Set<String> · 🔴 링크·경로 문자열 0 · RichText · SelectableText · Text.rich 는 화면 파일에 쓰지 않는다 = 정적 D23)
11 골든 = 새 PNG a3_* 8장 · --update-goldens 는 그 골든 테스트 파일만 · 기존 PNG(⟦실측⟧ 136장) 재생성 0 · golden:approved 안 붙임 · 찍기 전 위치 전제 둘 · 🔴 높이(_kTallPhone)는 늘리지 않는다(카드 확정값).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 ·
   패키지 테스트는 packages/ui_journal 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · prefer_final_locals · unnecessary_lambdas · use_build_context_synchronously(await 뒤 setState 는 mounted 검사 뒤).
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(🔴 이 카드의 _priceCtrl · _commissionCtrl · _taxCtrl · manualFillPrice 옆에 연산자 0 · 글자 잇기 0).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — 화면 파일의 주석에 이 낱말을 쓰지 않는다(위 규칙 3 끝 🔴 의 C-46 낱말 전부 +): DateTime · DateRange · kIsWeb · Platform. · dart:io · FeatureFlags · RunMode · skipAdvice · submitSelfReportBalance · deferAdviceConfirm ·
   fillsOfAdvice · amendManualFill · voidManualFill · rejectReasonCode · .kind · .length · .trim( · NumberFormat · toString( · Navigator · ScaffoldMessenger · SnackBar · Scaffold · AppBar · SafeArea · RichText · SelectableText · maxLines · TextOverflow · .take( ·
   autoDispose · Colors · 'aaq:// · Checkbox · inputFormatters · 추천 · 권유 · 자문 · 시그널(🔵 D06·D07·D34·D35·D36 은 줄 수를 정확히 세므로 AppNavActions · findById · watchManualFillFormSpec · recordManualFill · watchCommand · .clear( · .retryCode ·
   ManualFillPrefillFields 를 주석에 쓰지 않는다).
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려**.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다).
   PNG 는 이름마다 light 한 장만 연다(4장) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름 · 코드 이름 · 픽스처 낱말 금지 · 버튼 = «버튼 글자» · 입력 칸 = «입력 칸») · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 줄 n» = PNG 의 글자 **행** 수 · «상자» = 테두리·모서리가 보이는 덩어리 · «배경 덩어리» = 폭 전체 배경 · «칩 n개» = 한 무리의 칩 개수 · «막대» = 가로로 긴 덩어리 · «점» = 작은 둥근 표식 · «아이콘» = 글자 줄 안의 작은 표식 ·
   🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다.
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 채팅으로만) · S05 결과 = 이 카드는 S05 출력 0줄 → «S05 결과:» 다음 줄 정확히 «없음» · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M6.md 252~274행 23항) 그대로 + [x] 와 괄호만([—] 금지 · 🔴 23항을 코드 블록으로 감싸지 않는다) · ③ = 위젯·Key 이름 나열(요약어 금지) ·
   질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외) · ⑤ 추측이 없으면 정확히 «없음» 한 낱말.

■ 프롬프트보다 이 카드가 이긴다 — 24항 (prompt_M6.md 275줄 판 v2 · 2026-10-26 재조립)
 ① 2행 {{범위}} · 121행 «이번 과제 범위: R5a~R5e 중 …» → 이 카드의 범위 = A-3(위 첫 줄)
 ② 113~119행 역할·범위(M6 15화면 나열) → 이 카드 = A-3 · L-1·L-2 = R5a · A-1·「지난 안내」 = R5b · A-2·A-4 = R5c(병합됨) · L-3 = R5e(12 §6 7e)
 ③ 12~13행 «의존 셋뿐» → 추가 0 · pubspec 무변경
 ④ 15~19행 «링크는 데이터 · null = 부재» → 그대로 유효 · 상수 = AppNavActions.back 하나(01 §21-8 A-3 행 · executed pop)
 ⑤ 20~23행 DateTime.now 금지 · 신선도 = 주입 Clock + asOf → 그대로 유효(spec.asOf) · 거래일 = 엔진 선택지(날짜를 만들지 않는다)
 ⑥ 29~31행 «건수 집계·거르기·묶기·재정렬 금지» → 그대로 유효 · 예외 = 규칙 5 의 넷(신선도 · 선택 == · 드롭다운 값 확인 · 잠금 switch)
 ⑦ 32~38행 «한국어 리터럴 = labels.dart 한 파일» → 그대로 유효(JournalLabels R5d 절 6개 · 선택지·도움말·고지·접수증·재제출 글자 = 엔진)
 ⑧ 41~47행 안전 화면 금지 · 목적지 이름 정본 → 그대로 유효(정정·무효 = M5-12 · 이 화면에 진입 0)
 ⑨ 48~66행 «■ 모드 — 프리필·비교 금지 · 계획/사실» → 그대로 유효(61~63행 = 수량 버튼 하나 · 비교 0 · 이 화면 = 사실)
 ⑩ 68~74행 수치·금액 리터럴 금지 → 그대로 유효(정적 D16 · D17)
 ⑪ 87~93행 «melos run test · check_boundaries · precheck(인자는 카드)» → 패키지 테스트 = packages/ui_journal 에서 flutter test 직접(🔴 백그라운드·파이프 금지) · 사전검사 인자 = «■ 제출»
 ⑫ 94~99행 «PR 만들지 않음 · 5섹션 채팅 · 섹션 머리·복사 상자 = 카드 글자» → 그대로 유효 · 글자 = «■ 제출»(② 머리의 «12항» 그대로 — 사전검사 R1)
 ⑬ 100~105행 골든 두 갈래 → *.golden.json 0 · 새 PNG 8 = 최초 베이스라인(그 골든 파일만 --update-goldens) · 기존 PNG 재생성 0
 ⑭ 106~111행 «모르는 것 = 질문 파일» → 그대로 유효(inbox/A3_questions.md — 이미 있다)
 ⑮ 122~128행 읽을 문서 5 → 아래 «먼저 읽을 것»(02 는 §3-A · §3-8 · §3-10 끝 v1.12 블록 ⓐⓖⓙⓚ 만)
 ⑯ 130행 브랜치·PR 제목 형식 → 브랜치 ui/m6-a3-fill · 제목 «[M6] A-3 수기 체결 기록»
 ⑰ 131~134행 라이브러리 둘 → 이 카드 = operator 1파일(lib/src/journal_draft/ + lib/journal_draft.dart export) · 방향 = operator → 배럴 쪽만(../advice_inbox.dart import · 배럴은 operator 파일 0)
 ⑱ 135~137행 플랫폼 → 폰 전용(iOS «폰에서만» = 셸 가드 · 웹 = ui_journal 부재 · R13a) · 화면 코드 0
 ⑲ 143~145행 «무한 스크롤 = limit += 100 재구독» → 해당 없음(목록 = 폼 사양 선택지)
 ⑳ 146~150행 «차단 표기 = 공용 배너 · X7 화면 .watchState(·activeFlags·FlagIds 0(C-46 ㉑)» → 그대로 유효
 ㉑ 189~199행 «쓰기 화면 공통» → 그대로 유효 + 카드가 정한 것 — 잠금(⑥) · 신선도 초과(⑧) · 재제출(⑨) · 빈 폼(K11)
 ㉒ 200~205행 «A-3» → 그대로 유효 + 참조 카드(②) · 선택 표시(③) · 입력 모양(④) · 수량 표식(⑤) · deviationNote(⑦) · 🔴 203행 «ManualFillPrefillFields.quantity 를 더한다» = 선행 M2 보강 뒤(①) · 159~187행 X7 열람 · 206~217행 A-4·L-3 · 218~230행 X5 = 이 카드 범위 밖
 ㉓ 231~250행 타입 지위 표 → A-3 행만(findById · watchManualFillFormSpec · DraftStore · recordManualFill(ManualFillSubmission) · watchCommand → ManualFillFormSpec · ManualFillInput) · 249행 «부르지 않는 것» = 아래 «호출 표»
 ㉔ 251~274행 자체 점검 23항 → «■ 제출» ② 복사 상자(3 · 4 · 12 · 14 · 16 = [x] + 괄호 «이 카드 범위 밖(…)»)

■ 먼저 읽을 것 (🔴 03·04·05 명세는 읽지 않음 · 02 는 아래 ③ 의 자리만)
 ① prompt_M6.md 전문(판 v2) ② 01 §21 — 21-3 · 21-6 의 A-3 행 · 21-7 · 21-8 · 21-10-4 의 A-3 행 · 21-12-1(C-46 ⑰~㉔) · 21-16-1 · 01 §12-1(초안 키·본문) · §12-4(접수증 잠금 표)
 ③ 02 §3-A «X7 다섯 화면 공통 전제» · §3-8 «A-3 수기 체결 기록»(표 · 그림 M6-26) · §3-10 끝 «계약 v1.12 — R5 범위(X7 …) · 이 블록이 이긴다» ⓐⓖⓙⓚ
 ④ packages/domain_contracts/lib/ — src/dto/advice.dart(AdviceItem 의 참조 글자·prefill* · ManualFillFormSpec · SymbolOption · AccountOption · SideOption · TradeDateOption) · src/commands/payloads_x7.dart(ManualFillSubmission) ·
    src/commands/drafts.dart(ManualFillInput) · src/labels/advice_codes.dart(ManualFillPrefillFields · AdviceRetryCodes — 이름만) · src/commands/command_receipt.dart(retryCode · retryLabel) · src/enums/command.dart(CommandState) · src/commands/command_api.dart ·
    testing.dart(UnimplementedCommandApi · RecordingDraftStore)
 ⑤ packages/domain_contracts/test/contracts/c46_advice_x7_test.dart «B. 정규식» 절(⑰~㉔ · 🔵 ② 보강으로 생긴 ⑰ 예외 · ㉓ .clear( 갈래)
 ⑥ 지금 코드(packages/ui_journal) — lib/journal_draft.dart · lib/l10n/labels.dart · lib/src/journal_draft/advice_skip_form.dart 전문(🔴 R5c — 본뜰 꼴 · 고치지 않는다) · lib/src/journal_draft/journal_draft_form.dart(J-3 — 칸·컨트롤러·_persist 꼴 · 고치지 않는다) ·
    lib/src/common/journal_common.dart · lib/src/timeline.dart 머리 40줄 · test/advice_skip_fakes.dart(R5c — import 만) · test/advice_fakes.dart(R5b — import 만) · test/golden/h63_golden_test.dart · test/golden/golden_support.dart
 ⑦ packages/ui_journal/test/golden/README.md «R2b» 절(초안 시드 법) · «🆕 R5» 절 ⑧ packages/domain_contracts/fixtures/README.md(m6/fill_* · manual_fill_receipts_7 · draft_records_x7 행 · fill_rejected_price 의 형제 키는 읽지 않는다) ⑨ docs/ai-context/inbox/README.md · A3_questions.md 머리말

■ 본받지 않는 것
 · R4·R5a~R5c 카드와 같다 — 배너 관용구 · lib nullable 에 ! · implements 가짜 · 한국어 테스트 이름 · 조건부 단언
 · journal_draft_form.dart(J-3)의 화면 검증(.trim().length · rationaleMinChars · requiresNote) · activeFlags·FlagIds 배너 · .where(…).firstOrNull · _receipt! · _commandId! 꼴(X7 = 검증 0 · JournalSafetyBanners · lib ! 0)
   🔵 본받는 것 = R5c advice_skip_form.dart 의 _report · _port · _subscribe · _resubscribe · _applyReceipt(clear 한 곳) · _afterExecuted(pop / 빈 폼) · _locked(전수 switch) · J-3 의 컨트롤러 리스너 → _persist(record == _lastPersisted 면 생략) · _applyingRestore 가드
 · TextEditingController.clear() · Map·List 의 .clear()(C-46 ㉓ 이 잡는다 — 칸 = .text = '' · 목록 = 새 목록 대입)
 · test/journal_draft_test.dart 의 공장 안 if … return · _receiptIn(CommandState) 으로 접수증 짓기 · test/golden/j3_golden_test.dart 의 collection-if(옛 꼴)
 · fill_rejected_price.json 의 형제 키 preserved_input·reject_reason 을 읽는 것(화면 입력 아님 — 보존 = 화면 State)
 · R13b 1회차 반려 꼴(C4h-2~4) — 탭·링크 단언이 if 안 · bool 칸 + if · opened[0] · name ==·which == · if 를 단언 안 || 로 감춤

■ 주입 구조 (이름·타입·파일 고정 = 01 §21-8 글자 그대로 · 🔴 새 주입 0)
· 재사용: advice_inbox.dart 의 journalAdviceRepositoryProvider / journal_draft_form.dart 의 journalCommandApiProvider · journalDraftStoreProvider / timeline.dart 의 journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider · journalSafetyRepositoryProvider(테스트 override 용) /
  journal_common.dart: JournalAsOfHeader · JournalStaleBanner · JournalSafetyBanners · JournalSkeleton · JournalErrorView(🔴 무수정) / labels.dart: retry · staleBannerTitle · submitNotAccepted · commission · tax · draftSubmit · adviceNotFound(기존 · 고치지 않는다).
· 🆕 lib 파일 1개 — lib/src/journal_draft/manual_fill_form.dart(이것 말고 새 lib 파일 0 · 그 밖 조각은 이 파일 안 private).
  import(directives_ordering · 차례 = 드라이런 analyze 로 확정 ⟦실측⟧): dart:async → package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart → ../../l10n/labels.dart →
     ../advice_inbox.dart → ../common/journal_common.dart → ../timeline.dart → journal_draft_form.dart
  데이터 2(autoDispose 0 · import 바로 뒤):
    final _manualFillItemProvider = FutureProvider.family<AdviceItem?, String>((Ref ref, String id) => ref.watch(journalAdviceRepositoryProvider).findById(id));
    final _manualFillSpecProvider = StreamProvider<ManualFillFormSpec>((Ref ref) => ref.watch(journalAdviceRepositoryProvider).watchManualFillFormSpec());
· 🆕 operator 배럴 lib/journal_draft.dart 에 export 'src/journal_draft/manual_fill_form.dart'; 한 줄(자리 = 끝 · 기존 2줄 뒤 · 삭제 0)
· 조립 앱(이 카드 밖 · 참고만): 라우트 adviceFill → ManualFillForm(adviceId: …)(operator 앱만) · overrides 추가 0.

■ 호출 표 (부르는 것 · 부르지 않는 것 — 01 §21-8 글자)
 A-3 — 부르는 것: DraftStore.load(key)(initState 한 번) · findById(adviceId)(한 번) · watchManualFillFormSpec()(한 번) · DraftStore.save(입력·선택·수량 채우기마다 · 제출 Future 성공 뒤 lastCommandId) · recordManualFill(ManualFillSubmission)(제출·재제출 탭마다) ·
       watchCommand(id)(제출 뒤 · 복원 id · 재구독) · DraftStore.clear(key)(executed 한 곳) · opener.open(AppNavActions.back)(이 화면이 낸 명령의 executed).
       부르지 않는 것: skipAdvice · amendManualFill · voidManualFill · fillsOfAdvice · deferAdviceConfirm · 와이어·CommandContext · 안전 상태로 제출 판정 · 그 밖의 링크 · .watchState(.

■ 상태 표 (구독마다 — C4r3-1 · 01 §21-7 A-3 행 · §12-4)
 draft     initState 의 load 가 끝나기 전 → a3-loading(입력 잠금 = 화면 전체 · J-3 꼴) · load 에러 → _report 뒤 빈 초안으로 진행
 item      첫 값 전 → a3-loading · 에러 → a3-fail(onRetry: invalidate(_manualFillItemProvider(widget.adviceId))) · 값 null → Text(JournalLabels.adviceNotFound, key: const Key('a3-absent'))(폼 부재) · 값 → 다음 줄
 spec      첫 값 전 → a3-loading · 에러 → a3-fail(onRetry: invalidate(_manualFillSpecProvider) · lastAsOfLabel = 마지막 값의 asOf.label) · 값 + 신선도 초과 → 머리 + JournalStaleBanner + 배너만(폼 열지 않음 — 발주자 확인 ⑧) · 값 → 본문
 receipt   R5c 꼴 — lastCommandId 복원 non-null = 첫 접수증 전 잠금 + 구독 · 구독 에러·첫 값 없이 끝남 = a3-resubscribe · 제출 Future 에러 = a3-submit-not-accepted · 접수증 = a3-receipt(stateLabel) ·
           requested·received·staleContext·heldForIntegrity·pendingLeaseConfirm·noOperator = 잠금(칸·칩·드롭다운·버튼 전부) · rejected·expired = 잠금 풀림 + 입력 보존 + (retryLabel non-null) a3-retry ·
           executed = clear 한 곳 → 이 화면이 낸 명령이면 pop(AppNavActions.back) · 복원 id 면 빈 폼(칸 '' · 선택 null · 표식 false · retryCodes 비움 · 접수증 줄 0 · 잠금 풀림 · K11)
 safety    첫 값 전·에러 → 배너 부재 · 값 → JournalSafetyBanners(본문 영향 0)
 🔴 a3-loading · a3-fail 은 파일 안 한 곳에서만 짓는다(private const 위젯 하나 · private 함수 하나 — 정적 D20 = 이름마다 1줄).
 🔴 갈래를 고르는 것은 AsyncValue · null 여부 · 잠금 switch · State bool · 선택 == 뿐 — 글자 비교·거부 코드·재제출 코드·플래그·플랫폼으로 고르지 않는다.

■ 화면 — A-3 ManualFillForm (lib/src/journal_draft/manual_fill_form.dart · operator · ConsumerStatefulWidget · 02 §3-8 · 01 §21-6·§21-7 A-3 행 · K4 · K11 · K19 · K20 · K21 · K37)
 State 필드(🔴 이 이름·타입): late final DraftKey _draftKey = DraftKey(kind: DraftKind.manualFillRecord, targetId: widget.adviceId); · 컨트롤러 4 = _quantityCtrl · _priceCtrl · _commissionCtrl · _taxCtrl(TextEditingController) ·
   TradeDate? _tradeDate; · String? _symbol; · OrderSide? _side; · String? _account; · bool _prefilledQuantity = false; · List<String> _retryCodes = <String>[]; ·
   R5c 와 같은 접수증 필드(_receipt · _cmdSub · _commandId · _restoreDone · _awaitingReceipt · _resubscribeFailed · _submitting · _submitNotAccepted · _draftCleared · _issuedHere) + bool _applyingRestore = false; · DraftRecord? _lastPersisted;
 initState = 컨트롤러 4 에 addListener(_onInputChanged) · unawaited(_restore()); · dispose = _cmdSub?.cancel(); 컨트롤러 4 dispose; super.dispose();(🔴 dispose 안 ref. 0)
 _onInputChanged() = setState(() {}); _persist();(J-3 꼴)
 _input() — 초안·제출 공용 본문(🔴 이 꼴 · deviationNote 0 = 기본값):
     ManualFillInput _input() => ManualFillInput(tradeDate: _tradeDate, symbol: _symbol, side: _side, quantityText: _quantityCtrl.text, priceText: _priceCtrl.text, commissionText: _commissionCtrl.text, taxText: _taxCtrl.text,
       accountAlias: _account, prefilledFields: <String>[if (_prefilledQuantity) ManualFillPrefillFields.quantity]);
 _persist() — J-3 꼴: if (!_restoreDone || _applyingRestore) return; final DraftRecord record = DraftRecord(key: _draftKey, manualFill: _input(), lastCommandId: _commandId); if (record == _lastPersisted) return; _lastPersisted = record; _port((DraftStore s) => s.save(record));
 _restore() — J-3 꼴(load → 칸·선택 채우기 · _applyingRestore 가드 · _lastPersisted = r ?? DraftRecord(key: _draftKey, manualFill: const ManualFillInput()) · lastCommandId → 잠금 + 구독):
     final ManualFillInput? m = r?.manualFill;   →   (m != null) 이면 _applyingRestore = true; 칸 4 = m.quantityText · m.priceText · m.commissionText · m.taxText; _tradeDate = m.tradeDate; _symbol = m.symbol; _side = m.side; _account = m.accountAlias;
       _prefilledQuantity = m.prefilledFields.contains(ManualFillPrefillFields.quantity); _applyingRestore = false;   →   setState(_commandId = id · _awaitingReceipt = id != null · _restoreDone = true) → (id != null) _subscribe(id)
 _onPrefill(String text) — 수량 채우기 탭(🔴 발주자 확인 ⑤): setState(() { _prefilledQuantity = true; }); _quantityCtrl.text = text;(리스너가 저장한다)
 선택 탭 — 칩·드롭다운의 onSelected·onChanged 안: setState(() { _tradeDate = o.date; }); _persist();(방향 = _side = o.side · 종목 = _symbol = v · 계좌 = _account = v · 🔴 OrderSide.* · 점 축약 0)
 _known(String? v, List<String> values) — 드롭다운 값(🔴 이 꼴 · 발주자 확인 ③): for (final String x in values) { if (x == v) { return v; } } return null;
 _submit() — R5c _submit 꼴(🔴 «연결 저장 → 반영 → 구독»):
     setState(() { _submitting = true; _submitNotAccepted = false; });
     final CommandReceipt initial;
     try {
       initial = await ref.read(journalCommandApiProvider).recordManualFill(ManualFillSubmission(adviceId: widget.adviceId, input: _input(), retryCodes: _retryCodes));
     } catch (e, st) { _report(e, st); if (mounted) { setState(() { _submitting = false; _submitNotAccepted = true; }); } return; }
     if (!mounted) return;
     setState(() { _submitting = false; _commandId = initial.commandId; _issuedHere = true; });
     _persist();
     _applyReceipt(initial);
     _subscribe(initial.commandId);
 _retry(String? code) — 재제출 버튼(🔴 해석 0 · 더하기만 · K20): if (code != null) { _retryCodes = <String>[..._retryCodes, code]; } unawaited(_submit());
 _applyReceipt · _afterExecuted · _locked = R5c advice_skip_form.dart 꼴 그대로(clear 한 곳 · 이 화면 = pop · 복원 id = 빈 폼) — 🔵 빈 폼 몫만 더 넓다:
     setState(() { _applyingRestore = true; _quantityCtrl.text = ''; _priceCtrl.text = ''; _commissionCtrl.text = ''; _taxCtrl.text = ''; _tradeDate = null; _symbol = null; _side = null; _account = null; _prefilledQuantity = false;
       _retryCodes = <String>[]; _applyingRestore = false; _lastPersisted = DraftRecord(key: _draftKey, manualFill: const ManualFillInput()); _receipt = null; _commandId = null; _draftCleared = false; });   ← 🔴 .clear( 0
 배치(item 값 · spec 값 · 신선도 안 · 위 → 아래 · 🔴 이 순서 · final bool locked = _locked(); · final String? blocked = spec.blockedText;):
   ListView(padding: EdgeInsets.zero)[
    1 JournalAsOfHeader(key: const Key('a3-asof'), asOf: spec.asOf)
    2 (오래됐으면) JournalStaleBanner(asOf: spec.asOf) — 🔴 오래됐으면 3 다음에서 끝(4~19 0)
    3 JournalSafetyBanners(safety: safety)
    4 (banner != null) Padding(… Text(banner, key: const Key('a3-banner')))                                     ← final String? banner = spec.bannerText;
    5 _FillReferenceCard(key: const Key('a3-ref'), item: item)                                                ← R5c _SkipReferenceCard 와 같은 글자 6 · 버튼 0
    6 (prefillLabel != null ∧ prefillText != null) Padding(… OutlinedButton(key: const Key('a3-prefill'), onPressed: locked ? null : () { _onPrefill(prefillText); }, child: Text(prefillLabel)))
                                                                                                              ← final String? prefillLabel = item.prefillQuantityLabel; final String? prefillText = item.prefillQuantityText;
    7 Padding(… Text(JournalLabels.manualFillTradeDate)) · Padding(… Wrap(spacing: 6, runSpacing: 4, children: [ for (final (int i, TradeDateOption o) in spec.tradeDateOptions.indexed)
        ChoiceChip(key: ValueKey<String>('a3-date-$i'), label: Text(o.label), selected: _tradeDate == o.date, onSelected: locked ? null : (bool _) { <선택 탭> }) ]))
    8 Padding(… DropdownButton<String>(key: const Key('a3-symbol'), isExpanded: true, hint: const Text(JournalLabels.manualFillSymbol), value: _known(_symbol, <String>[for (final SymbolOption s in spec.symbols) s.symbol]),
        items: [ for (final SymbolOption s in spec.symbols) DropdownMenuItem<String>(value: s.symbol, child: Text(s.label)) ], onChanged: locked ? null : (String? v) { <선택 탭> }))
    9 Padding(… Text(JournalLabels.manualFillSide)) · Padding(… Wrap([ for (final (int i, SideOption o) in spec.sides.indexed) ChoiceChip(key: ValueKey<String>('a3-side-$i'), label: Text(o.label), selected: _side == o.side, onSelected: …) ]))
   10 Padding(… TextField(key: const Key('a3-quantity'), controller: _quantityCtrl, enabled: !locked, decoration: const InputDecoration(labelText: JournalLabels.manualFillQuantity)))
   11 Padding(… TextField(key: const Key('a3-price'), controller: _priceCtrl, enabled: !locked, decoration: InputDecoration(labelText: JournalLabels.manualFillPrice, helperText: spec.priceHintLabel)))
   12 Padding(… TextField(key: const Key('a3-commission'), controller: _commissionCtrl, enabled: !locked, decoration: const InputDecoration(labelText: JournalLabels.commission)))
   13 Padding(… TextField(key: const Key('a3-tax'), controller: _taxCtrl, enabled: !locked, decoration: const InputDecoration(labelText: JournalLabels.tax)))
   14 Padding(… DropdownButton<String>(key: const Key('a3-account'), isExpanded: true, hint: const Text(JournalLabels.manualFillAccount), value: _known(_account, <String>[for (final AccountOption a in spec.accounts) a.alias]),
        items: [ for (final AccountOption a in spec.accounts) DropdownMenuItem<String>(value: a.alias, child: Text(a.label)) ], onChanged: locked ? null : (String? v) { <선택 탭> }))
   15 Padding(… Text(spec.appendOnlyNotice, key: const Key('a3-append-notice')))
   16 (receipt != null) Padding(… Text(receipt.stateLabel, key: const Key('a3-receipt')))                          ← final CommandReceipt? receipt = _receipt;
   17 (retryLabel != null) Padding(… OutlinedButton(key: const Key('a3-retry'), onPressed: locked ? null : () { _retry(retryCode); }, child: Text(retryLabel)))   ← final String? retryLabel = receipt?.retryLabel; final String? retryCode = receipt?.retryCode;
   18 (_submitNotAccepted) Padding(… Text(JournalLabels.submitNotAccepted, key: const Key('a3-submit-not-accepted'), style: TextStyle(color: Theme.of(context).colorScheme.error))) ·
      (_resubscribeFailed) Padding(… TextButton(key: const Key('a3-resubscribe'), onPressed: _resubscribe, child: const Text(JournalLabels.retry)))
   19 (blocked == null) Padding(… FilledButton(key: const Key('a3-submit'), onPressed: locked ? null : () { unawaited(_submit()); }, child: const Text(JournalLabels.draftSubmit)))
      (blocked != null) Padding(padding: EdgeInsets.all(16), child: Text(blocked, key: const Key('a3-blocked')))   ← 제출 부재 + 문장(K21 · 칸은 그대로 — 적어 두면 초안이 남는다)
   ]
 _FillReferenceCard(item:) — private StatelessWidget · R5c _SkipReferenceCard 와 같은 꼴(Card > Padding(16) > Column[(symbol) · (side) · sizingLabel · (band) band.label · validityLabel · progressLabel]) · 🔴 Text 순서 = 도우미 adviceFormRefTexts
 코드 스케치: build — if (!_restoreDone) return _fillLoading; item.when(loading → _fillLoading · error → _fillFail(…) · data null → a3-absent · data v → spec.when(loading → _fillLoading · error → _fillFail(…) · data s → _buildBody(context, v, s, clock, safety)))
   _fillLoading = const JournalSkeleton(key: Key('a3-loading')) · _fillFail(VoidCallback onRetry, String? lastAsOf) => JournalErrorView(key: const Key('a3-fail'), lastAsOfLabel: lastAsOf, onRetry: onRetry).
 🔴 가격·거래일 채우기 버튼 0 · 부분 체결 버튼 0 · 시간외·단주 체크박스 0 · 슬리브 선택 0 · 자유 티커 0 · 연속 입력 0 · 입력 검사 0 · 안내 값과 비교 0 · rejectReasonCode 0 · .clear( 는 초안 한 곳.

■ 픽스처 (FixturePaths.… · listFixture / singleFixture / safetyFixtureRow · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 ad0001 · ad0002 · filled   listFixture(FixturePaths.m6Advice12, AdviceItem.fromJson).rows[3] · [4] · [7] — ad_0001 OPEN(골든 a3_empty · a3_form_spec_stale) · ad_0002 OPEN(테스트 기본 · prefill «8») · ad_0006 FILLED(prefill 둘 다 null)
 partial        singleFixture(FixturePaths.m6AdviceDetailPartial, AdviceItem.fromJson) — ad_0005 PARTIAL · progressLabel «20주 중 8주…» · prefill «20»(골든 a3_advice_linked)
 spec · blockedSpec · staleSpec   singleFixture(FixturePaths.m6FillFormSpec / m6FillFormSpecBlocked / m6FillFormSpecStale, ManualFillFormSpec.fromJson) — tradeDateOptions 6 · sides 2 · symbols 6 · accounts 2 · priceHintLabel · appendOnlyNotice ·
                blocked = blockedText·bannerText 있음 · stale = asOf 오래됨 + staleLabel 있음
 receipts       listFixture(FixturePaths.m6ManualFillReceipts7, CommandReceipt.fromJson) — [0] REQUESTED · [1] EXECUTED · [2] REJECTED(DUPLICATE_SUSPECTED · retryCode·retryLabel 있음) · [3] REJECTED(INPUT_INVALID · retry 없음) · [4] HELD_FOR_INTEGRITY ·
                [5] PENDING_LEASE_CONFIRM · [6] STALE_CONTEXT(같은 commandId)
 rejectedPrice  singleFixture(FixturePaths.m6FillRejectedPrice, CommandReceipt.fromJson) — REJECTED(PRICE_OUT_OF_RANGE · retryCode·retryLabel 있음) · 🔴 형제 키 preserved_input·reject_reason·price_range_source_date 는 읽지 않는다
 drafts         listFixture(FixturePaths.m6DraftRecordsX7, DraftRecord.fromJson) — [0] = RECORD_MANUAL_FILL / ad_0002 · 본문(거래일 2026-08-31 · 379810 · BUY · «8» · «18900» · «120» · '' · 연금저축 · prefilledFields [quantity]) · lastCommandId null
                (🔵 복원 id 시드 = manualFillSeedWithCommand(drafts.rows[0], receipts.rows[0].commandId) · 기대 키 = drafts.rows[0].key)
 안전           safetyFixtureRow(0) 정상
 🔴 쓰지 않는 것: m6/manual_fills_8(J-1·J-2 몫) · m6/advice_skip_* · m6/self_report_* · ledger_* · 형제 키 · 시드 밖 copyWith · «내 픽스처».

■ Key 표 (a3- 22이름 — 정본 = 이 표 · 🔴 표 밖 Key 0 · id 0 — 순번만 · 같은 이름을 두 자리에 달면 반려 · 정적 D20 = 이름마다 1줄)
   a3-loading · a3-fail · a3-absent(Text adviceNotFound) · a3-asof · a3-banner(Text bannerText) · a3-ref(_FillReferenceCard) · a3-prefill(OutlinedButton) · a3-date-$i(ChoiceChip · ValueKey<String>) · a3-symbol(DropdownButton) ·
   a3-side-$i(ChoiceChip · ValueKey<String>) · a3-quantity · a3-price · a3-commission · a3-tax(TextField) · a3-account(DropdownButton) · a3-append-notice(Text appendOnlyNotice) · a3-receipt(Text stateLabel) · a3-retry(OutlinedButton retryLabel) ·
   a3-submit-not-accepted · a3-resubscribe(TextButton) · a3-submit(FilledButton) · a3-blocked(Text blockedText) — 다는 자리 = 위 «화면» 배치 글자 · 있을 때 = 위 «상태 표»
   (참조 카드 안 · 정적 머리 Text · 칩 글자 · 드롭다운 항목 · 배너에는 Key 를 달지 않는다)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 그 커밋 내용 · 🔴 커밋마다 git add <파일> 로 지정 — git add . 금지 · amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일)
 (1) 정적 라벨 6(labels.dart R5d 절). 커밋 «[M6] R5d (1) 정적 라벨 6»
 (2) lib/src/journal_draft/manual_fill_form.dart + operator 배럴 한 줄. 🔴 커밋 전에 git add <그 파일들> 뒤 «정적 묶음» 미리 돌리기. 커밋 «[M6] R5d (2) A-3 수기 체결 기록»
 (3) test/manual_fill_fakes.dart + test/manual_fill_form_test.dart(A3-01~A3-14). 커밋 «[M6] R5d (3) A-3 테스트»
 (4) 골든 8장 — test/golden/a3_golden_test.dart(4이름 × 2). 커밋 «[M6] R5d (4) 골든 a3_* 8장»
 (5) melos.bat run format:fix · 질문 파일(A3_questions.md — dy 측정 행 A1~A4 · 그 밖의 질문). 커밋 «[M6] R5d (5) format · 질문».
     🔴 (5) 뒤 커밋 0 — 예외 = 사전검사 ① 🔴 수정 커밋 (6) **하나**(format:fix 먼저).

■ 정적 라벨 — JournalLabels 안 R5c 절의 마지막 상수(adviceRecordedFills · ⟦실측⟧) 뒤 · 닫는 } 앞에 절 주석(// ── 🆕 R5d — A-3 수기 체결 기록 ──…)과 함께 6개(이름·글자 고정 · static const String · doc 주석 짧게):
   manualFillTradeDate = '거래일' · manualFillSymbol = '종목' · manualFillSide = '방향' · manualFillQuantity = '수량' · manualFillPrice = '가격' · manualFillAccount = '계좌'
   🔴 만들지 않는 글자(엔진 몫): 참조 카드 글자 · 수량 채우기 글자 · 거래일·방향·종목·계좌 선택지 글자 · 가격 도움말 · 원본 고지 · 접수증 · 재제출 글자 · 차단 문장 · 폼 배너 · 신선도 문장 · «부분 체결» · «시간외» · «매수»·«매도».
   라벨 글자에 숫자·금액 0(C-32) · «추천·권유·자문·시그널» 0 · 기존 라벨은 그대로(R5c 병합본 41 · ⟦실측⟧ → 합 47 — 정적 D11 이 정확히 센다) · 🔵 수수료·세금·제출 = 기존 commission · tax · draftSubmit.

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 는 정적 D18·D19 · (전제) 는 D31 과 대조)
공통: 띄우기 = pumpManualFill(tester, overrides:, adviceId:)(Size(390, 4000) · DPR 1.0 · teardown 2 · ProviderScope(overrides) > MaterialApp > Scaffold(body: ManualFillForm(adviceId: id)) · pump 두 번) ·
  overrides = manualFillOverrides(repo:, cmd:, store:, safety:, clock:, opener:)(6줄) · repo = FakeAdviceFormRepository(R5c · item · spec 공장) · 시계 = FixedClock(kGoldenNowUtc) · id = 픽스처 행의 adviceId ·
  경우가 여럿인 테스트 = for 로 testWidgets 를 경우마다(이름 '<번호> <설명> ${c.name}') · 경우 = private class _Case(bool 칸 0 · Matcher 칸 허용) · 탭 앞에 ensureVisible · 띄우기는 한 테스트에 한 번 ·
  계획 = manual_fill_form_test testWidgets 줄 14(테스트 28) · 골든 1 · testWidgets·test 줄 합 15(≤ 33) · import = 드라이런 analyze «No issues found!» 차례(⟦실측⟧).
  🆕 test/manual_fill_fakes.dart(새 · 공개 이름 · 한국어 리터럴 0 · if 0 · collection-if 0 · 🔴 다른 fakes 파일 무수정 — advice_skip_fakes.dart · advice_fakes.dart · holdings_overview_fakes.dart 는 import 만):
    class FakeManualFillCommandApi extends UnimplementedCommandApi { FakeManualFillCommandApi({required this.record, required this.watch}); final Future<CommandReceipt> Function(int call) record; final Stream<CommandReceipt> Function(int call) watch;
      final List<ManualFillSubmission> recorded = <ManualFillSubmission>[]; final List<String> watched = <String>[];
      @override recordManualFill(ManualFillSubmission submission) → final int call = recorded.length; recorded.add(submission); return record(call); · @override watchCommand(String commandId) → 같은 꼴(watched) }
    List<Override> manualFillOverrides({required FakeAdviceFormRepository repo, required CommandApi cmd, required DraftStore store, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener}) — 6줄(R5c adviceSkipOverrides 꼴)
    Future<void> pumpManualFill(WidgetTester tester, {required List<Override> overrides, required String adviceId})
    DraftRecord manualFillSeedWithCommand(DraftRecord r, String commandId) => r.copyWith(lastCommandId: commandId);   ← 🔵 copyWith 1곳(규칙 10 예외)
    Future<void> manualFillPick(WidgetTester tester, Key dropdown, String label)(드롭다운 Key 탭 → pumpAndSettle → find.text(label).last 탭 → pumpAndSettle · if 0)
    Set<String> manualFillAllowed(ManualFillFormSpec s, AdviceItem v) => <String>{s.asOf.label, ?s.bannerText, ...adviceFormRefTexts(v), ?v.prefillQuantityLabel, JournalLabels.manualFillTradeDate, for (… o in s.tradeDateOptions) o.label,
      JournalLabels.manualFillSymbol, for (… x in s.symbols) x.label, JournalLabels.manualFillSide, for (… o in s.sides) o.label, JournalLabels.manualFillQuantity, JournalLabels.manualFillPrice, s.priceHintLabel, JournalLabels.commission, JournalLabels.tax,
      JournalLabels.manualFillAccount, for (… a in s.accounts) a.label, s.appendOnlyNotice, JournalLabels.draftSubmit, ?s.blockedText};   (🔴 허용 집합에 링크 문자열 0)
  파일 머리(main() 안)에서 위 «픽스처» 를 한 번 final 로 읽는다.
 A3-01 빈 폼 — 참조 카드 · 선택지 · 제출 활성(02 §3-8 · K4 · K37) — ad0002 + spec + RecordingDraftStore() · 전제 둘: expect(drafts.rows[0].key.targetId, ad0002.adviceId); // pre · expect(ad0002.prefillQuantityLabel, isNotNull); // pre →
        a3-asof 아래 Text == [spec.asOf.label] · adviceShownTexts(a3-ref) == adviceFormRefTexts(ad0002) · 칸 4 의 controller?.text 전부 '' · ⓗ expect(spec.tradeDateOptions, hasLength(6)); → i 마다 a3-date-$i 칩 글자 == options[i].label · selected isFalse ·
        a3-date-6 findsNothing · ⓗ expect(spec.sides, hasLength(2)); → i 마다 a3-side-$i 글자 == sides[i].label · selected isFalse · a3-side-2 findsNothing · a3-symbol · a3-account 의 value isNull ·
        a3-submit 의 onPressed isNotNull(빈칸이어도 — K4) · expect(store.loaded, <DraftKey>[drafts.rows[0].key]) · expect(store.saved, <DraftRecord>[]) · a3-receipt findsNothing · ⓡ.
 A3-02 수량 채우기(K19) — ad0002 · a3-prefill 탭 → pump → a3-quantity 글자 == ad0002.prefillQuantityText · expect(store.saved.last.manualFill?.quantityText, ad0002.prefillQuantityText) ·
        expect(store.saved.last.manualFill?.prefilledFields, <String>[ManualFillPrefillFields.quantity]) · a3-price 글자 == ''(가격 채우기 0) · ⓡ.
 A3-03 수량 채우기 버튼 존재 — 두 경우 (open · item = ad0002 · prefill = ad0002.prefillQuantityLabel) · (filled · item = filled · prefill = null)마다 — 전제: expect(filled.prefillQuantityLabel, isNull); // pre → «없는 쪽» 견본 그대로 · a3-quantity findsOneWidget · ⓡ.
 A3-04 입력·선택 → 초안 → 제출 원문(K4 · K37) — ad0002 + spec · record = (int call) => Future<CommandReceipt>.value(receipts.rows[0]) · watch = Stream.value(receipts.rows[0]) →
        흐름 = a3-date-5 탭 → manualFillPick(a3-symbol, spec.symbols[1].label) → a3-side-0 탭 → a3-quantity 에 '8' · a3-price 에 '18900' 입력 → manualFillPick(a3-account, spec.accounts[0].label) → a3-submit 탭 → pump →
        final ManualFillSubmission s = cmd.recorded.single; · expect(s.adviceId, ad0002.adviceId) · expect(s.input.tradeDate, spec.tradeDateOptions[5].date) · expect(s.input.symbol, spec.symbols[1].symbol) · expect(s.input.side, spec.sides[0].side) ·
        expect(s.input.quantityText, '8') · expect(s.input.priceText, '18900') · expect(s.input.commissionText, '') · expect(s.input.taxText, '') · expect(s.input.accountAlias, spec.accounts[0].alias) · expect(s.input.prefilledFields, <String>[]) ·
        expect(s.retryCodes, <String>[]) · expect(store.saved.last.manualFill, s.input) · expect(store.saved.last.lastCommandId, receipts.rows[0].commandId) · expect(cmd.watched, <String>[receipts.rows[0].commandId]) · ⓡ.
 A3-05 접수증 갈래(01 §21-7 · §12-4) — 일곱 경우(칸 = 이름 · watch 접수증 · enabled Matcher · retry String? · cleared 목록 · opened 목록) — 초안 시드 = drafts.rows[0](복원 칸 있음) · record = rows[0]:
        (requested · rows[0] · isNull · null · [] · []) · (executed · rows[1] · isNull · null · [drafts.rows[0].key] · [AppNavActions.back]) · (rejected_dup · rows[2] · isNotNull · rows[2].retryLabel · [] · []) ·
        (rejected_invalid · rows[3] · isNotNull · null · [] · []) · (held · rows[4] · isNull · null · [] · []) · (lease · rows[5] · isNull · null · [] · []) · (stale_context · rows[6] · isNull · null · [] · [])마다 —
        전제 둘: expect(receipts.rows[2].retryLabel, isNotNull); // pre · expect(receipts.rows[3].retryLabel, isNull); // pre → steps = a3-submit 탭 · pump → a3-receipt 글자 == c.watch.stateLabel(executed 는 pop 뒤에도 같은 화면 — 테스트의 pop 은 기록뿐) ·
        a3-submit onPressed == c.enabled · «없는 쪽» 견본 꼴(a3-retry 글자 · want = c.retry) · a3-quantity 글자 == drafts.rows[0].manualFill?.quantityText(보존) · expect(store.cleared, c.cleared) · expect(opener.opened, c.opened) · ⓡ.
 A3-06 재제출 누적(K20) — 시드 rows[0] · record = (int call) => Future<CommandReceipt>.value(<CommandReceipt>[rejectedPrice, receipts.rows[2], receipts.rows[0]][call]) · watch = 같은 차례의 Stream.value ·
        전제 둘: expect(rejectedPrice.retryCode, isNotNull); // pre · expect(receipts.rows[2].retryCode, isNotNull); // pre → 흐름 = a3-submit 탭 → a3-retry 글자 == rejectedPrice.retryLabel → a3-retry 탭 → a3-retry 글자 == receipts.rows[2].retryLabel → a3-retry 탭 →
        expect(<List<String>>[for (final ManualFillSubmission s in cmd.recorded) s.retryCodes], <List<String>>[<String>[], <String>[rejectedPrice.retryCode!], <String>[rejectedPrice.retryCode!, receipts.rows[2].retryCode!]]) · ⓡ.
 A3-07 초안 복원(01 §12-1) — 시드 rows[0] · 전제: expect(drafts.rows[0].manualFill?.prefilledFields, isNotEmpty); // pre → 칸 4 글자 == 시드 본문의 quantityText · priceText · commissionText · taxText ·
        i 마다 a3-date-$i selected == (spec.tradeDateOptions[i].date == 시드 tradeDate) · i 마다 a3-side-$i selected == (spec.sides[i].side == 시드 side) · a3-symbol value == 시드 symbol · a3-account value == 시드 accountAlias ·
        a3-submit 탭 → expect(cmd.recorded.single.input, drafts.rows[0].manualFill)(표식까지 그대로) · ⓡ.
 A3-08 복원 id — 잠금 · executed = 빈 폼(K11) — 두 경우 (restored_requested · watch = rows[0] · receipt = rows[0].stateLabel · enabled isNull · quantity = 시드 quantityText · cleared []) ·
        (restored_executed · watch = rows[1] · receipt = null · enabled isNotNull · quantity = '' · cleared [drafts.rows[0].key])마다 — 시드 = manualFillSeedWithCommand(drafts.rows[0], receipts.rows[0].commandId) ·
        전제: expect(drafts.rows[0].lastCommandId, isNull); // pre → expect(cmd.watched, <String>[receipts.rows[0].commandId]) · «없는 쪽» 견본 꼴(a3-receipt) · a3-submit onPressed == c.enabled · a3-quantity 글자 == c.quantity ·
        expect(store.cleared, c.cleared) · expect(opener.opened, <String>[])(🔴 복원 id = pop 0) · expect(cmd.recorded, <ManualFillSubmission>[]) · ⓡ.
 A3-09 제출 차단 · 폼 배너(K21) — 두 경우 (blocked · blockedSpec · blocked = blockedSpec.blockedText · banner = blockedSpec.bannerText · submit findsNothing) · (normal · spec · null · null · findsOneWidget)마다 —
        전제 둘: expect(blockedSpec.blockedText, isNotNull); // pre · expect(blockedSpec.bannerText, isNotNull); // pre → «없는 쪽» 견본 꼴 두 번(a3-blocked · a3-banner) · expect(find.byKey(const Key('a3-submit')), c.submit) · a3-quantity findsOneWidget · ⓡ.
 A3-10 사양 신선도 초과 = 폼 열지 않음(02 §3-8 (a)) — ad0002 + staleSpec · 전제: expect(staleSpec.asOf.staleLabel, isNotNull); // pre → a3-asof 아래 Text == [staleSpec.asOf.label] · find.text(staleSpec.asOf.staleLabel!) findsOneWidget ·
        find.text(JournalLabels.staleBannerTitle) findsOneWidget · a3-ref findsNothing · a3-quantity findsNothing · a3-submit findsNothing · ⓡ.
 A3-11 제출 Future 에러 = 접수 실패 1줄 — record = Future.error → a3-submit 탭 → a3-submit-not-accepted 글자 == JournalLabels.submitNotAccepted · a3-submit onPressed isNotNull · expect(cmd.watched, <String>[]) · ⓡ · expect(tester.takeException(), isNotNull).
 A3-12 재구독 — 복원 id 시드 · watch = (int call) => call == 0 ? Stream<CommandReceipt>.error(StateError('fail')) : Stream<CommandReceipt>.value(receipts.rows[0]) → a3-resubscribe findsOneWidget · a3-submit onPressed isNull → a3-resubscribe 탭 →
        a3-receipt 글자 == receipts.rows[0].stateLabel · expect(cmd.watched, <String>[receipts.rows[0].commandId, receipts.rows[0].commandId]) · expect(tester.takeException(), isNotNull).
 A3-13 상태 × 갈래(구독 둘 + 초안 · 01 §21-7) — 여섯 경우(칸 = 이름 · item 공장 · spec 공장 · store · 있음 · 없음): (draft_pending · ad0002 · spec · load 가 끝나지 않는 저장소(extends RecordingDraftStore · 테스트 파일 안 private class) · [a3-loading] · [a3-asof, a3-quantity]) ·
        (item_loading · Completer · spec · 기본 · [a3-loading] · [a3-asof]) · (item_fail · Future.error · spec · 기본 · [a3-fail] · [a3-loading, a3-asof]) · (item_null · Future.value(null) · spec · 기본 · [a3-absent] · [a3-asof, a3-quantity, a3-submit]) ·
        (spec_loading · ad0002 · Stream.fromFuture(Completer().future) · 기본 · [a3-loading] · [a3-asof]) · (spec_fail · ad0002 · Stream.error · 기본 · [a3-fail] · [a3-loading, a3-asof])마다 —
        Key 목록마다 findsOneWidget / findsNothing · CircularProgressIndicator findsNothing(ⓡ·ⓗ 없음).
 A3-14 화면 Text 전부 · 큰 글꼴 — ad0002 + spec · allowed = manualFillAllowed(spec, ad0002) → 규칙 10 «화면의 Text 전부» 견본 그대로 → textScaleFactorTestValue = 2.0(+ teardown clear) → pump → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = manual_fill_form_test.dart 12줄(A3-01~A3-11 · A3-14 — 경우 for 안의 한 줄) · ⓗ 기대 = 2줄(A3-01 둘) — 🔴 정확히 · (전제) = 12(A3-01 2 · 03 1 · 05 2 · 06 2 · 07 1 · 08 1 · 09 2 · 10 1).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려 · 갈래마다 — 빈 · 복원 · 접수증 7 · 차단 · 오래됨 · 에러 · 잠금):
   (프리필) 참조 카드 값으로 칸 채우기 · 가격 채우기 · 수량 채우기 표식 0 · 표식을 칸 수정에 지우기 · 복원 때 표식 버림 · prefillQuantityLabel null 에도 버튼.
   (원문) 수량 글자를 다듬어 넣기 · 빈칸에 '0' · 제출 버튼을 빈칸에 끄기 · 방향을 OrderSide 로 고정 · 거래일을 첫 선택지로 · 종목·계좌를 첫 선택지로 · retryCodes 를 덮어쓰기(누적 0) · retryCodes 를 초안에 · adviceId 대신 다른 글자.
   (접수증) requested 에 pop · 보류 3상태에 잠금 풀기 · rejected 에 칸 비우기 · rejected 에 잠금 유지 · retryLabel 버튼 숨김 · retryLabel 이 없는데 버튼 · executed 밖 clear · executed 에 clear 0 · 복원 id executed 에 pop · 이 화면 executed 에 pop 0 ·
     복원 id executed 에 칸 남기기 · 첫 접수증 전 잠금 0 · 구독 에러에 재구독 버튼 0 · Future 에러에 글자 0 · 낙관 갱신(진행 글자를 화면이 고치기).
   (상태) 신선도 초과에도 폼 · 신선도 초과에 배너 0 · blockedText 에도 제출 · blockedText 숨김 · bannerText 숨김 · 초안 load 전에 칸 열기 · 재시도에 invalidate 0 · 벽시계로 신선도 · 부재에 폼.
   (배치) 참조 카드를 칸 아래로 · 칸 순서 바꾸기 · 원본 고지 빼기 · 정적 글자 하나 더하기 · 링크 글자를 화면에 그리기(탐침 — C4r13b-6).
   🔵 판정 = 변이마다 ui_journal 의 flutter test 전부(골든 포함) + C-46 ⑯~㉔ · 드라이런 = ⟦실측⟧(목록 KILLED 수 · 참고 변이 통과 목록).

■ 정적 묶음 — packages/ui_journal 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 출력 줄 수(EXIT 줄 포함) = ⟦실측⟧ 줄 — 붙이기 전에 세어 같은지 본다 ·
   flutter test·dart test 출력은 파일로 떠서 붙인다 · «EXIT:1»/«EXIT:False» = 출력 없음)
echo "## D01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/manual_fill_fakes.dart test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n -e journalLinkOpenerProvider --and --not -e AppNavActions.back -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D06 pop line (1)"; git grep -n "AppNavActions.back" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D07 read and command lines (4)"; git grep -nE "findById\(|watchManualFillFormSpec\(|recordManualFill\(|watchCommand\(" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D08 forbidden words in A-3 0"; git grep -nP "DateTime\.|DateRange|kIsWeb|Platform\.|dart:io|FeatureFlags|RunMode|operatingMode|watchState|activeFlags|FlagIds|markerOnly|killSwitch|skipAdvice|submitSelfReportBalance|deferAdviceConfirm|fillsOfAdvice|amendManualFill|voidManualFill|watchDecisionDetail|JournalRepository|HoldingsRepository|CommandContext|ManualFillRecord\(|\.status\b|(?<!ManualFillPrefillFields)\.quantity\b|\.quantityMax|\.minTradeDate|\.maxTradeDate|\.nonTradingDates|\.sleeve\b|\.decision\b|\.name\b|\.wire\b|AdviceStatus\.|AdviceActionId\.|AdviceSkipReason\.|OrderSide\.|rejectReasonCode|\.level\b|\.length\b|\.trim\(|\.isEmpty|int\.parse|double\.parse|tryParse|Decimal|showDatePicker|inputFormatters|Checkbox|Switch\(|NumberFormat|toString\(|Navigator|ScaffoldMessenger|SnackBar|FloatingActionButton|\.where|[fF]irstWhere|\.sort|\.fold\(|\.reduce\(|groupBy" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D09 AppRoutes constants 0"; git grep -nE "AppRoutes\.[a-zA-Z]+" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D10 enum names other than CommandState 0"; git grep -nE "AdviceStatus\.|AdviceActionId\.|AdviceKind\.|AdviceSkipReason\.|OrderSide\.|ChipTone\.|UiLevel\.|DraftKind\.(journalDraft|adviceSkip|selfReportBalance)" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D11 journal labels (47)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## D12 operator barrel exports (3)"; git grep -n "^export " -- lib/journal_draft.dart; echo "EXIT:$?"
echo "## D13 providers in new lib (2)"; git grep -nP "^final \w+Provider\b" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D14 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_journal/)" -- lib; echo "EXIT:$?"
echo "## D15 hangul literals in new lib 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D16 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib/src/journal_draft/manual_fill_form.dart lib/l10n/labels.dart; echo "EXIT:$?"
echo "## D17 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D18 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/manual_fill_form_test.dart; echo "EXIT:$?"
echo "## D19 H lines (hasLength)"; git grep -c "hasLength(" -- test/manual_fill_form_test.dart; echo "EXIT:$?"
echo "## D20 key names (one line each)"; git grep -noP "'a3-[a-z]+(-[a-z]+)*" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D21 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## D22 Colors files 0"; git grep -lw Colors -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D23 rich text trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|FittedBox|\.take\(" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D24 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## D25 Scaffold AppBar SafeArea 0"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D26 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_journal.dart lib/journal_draft.dart lib/src/common lib/src/timeline.dart lib/src/advice lib/src/advice_inbox.dart lib/src/advice_history.dart lib/src/advice_detail.dart lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart lib/src/journal_draft/journal_draft_form.dart lib/src/journal_draft/advice_skip_form.dart pubspec.yaml analysis_options.yaml README.md test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/holdings_overview_fakes.dart test/advice_fakes.dart test/advice_skip_fakes.dart test/advice_detail_fakes.dart; echo "EXIT:$?"
echo "## D27 implements in new tests 0"; git grep -n " implements " -- test/manual_fill_fakes.dart test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D28 copyWith in tests (seed 1)"; git grep -n "copyWith(" -- test/manual_fill_fakes.dart test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D29 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/manual_fill_fakes.dart test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D30 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## D31 precondition marks (pre)"; git grep -c "// pre$" -- test/manual_fill_form_test.dart; echo "EXIT:$?"
echo "## D32 name compares element picks and hidden ifs in tests 0"; git grep -nP "\b(name|which)\s*==|opened\[\d\]|cleared\[\d\]|saved\[\d\]|recorded\[\d\]|watched\[\d\]|\|\|[^;]*isTrue\)" -- test/manual_fill_fakes.dart test/manual_fill_form_test.dart test/golden/a3_golden_test.dart; echo "EXIT:$?"
echo "## D33 non-null assertion in new lib 0"; git grep -nP "[\w\)\]]!(?![=])" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D34 clear calls (1)"; git grep -n "\.clear(" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D35 retry code read (1)"; git grep -nP "\.retryCode\b" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D36 prefill constant lines (2)"; git grep -n "ManualFillPrefillFields" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
echo "## D37 error report lines (1)"; git grep -n "FlutterError" -- lib/src/journal_draft/manual_fill_form.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(카드 계획 · 드라이런 ⟦실측⟧) — D01 = 주석 줄 말고 출력 없음 · D02 = 출력 없음 · D03 = 2줄(a3_golden 1 · manual_fill_form_test 14) · D04 = 0 · S05 = 0(EXIT:1 · 링크를 여는 탭 0) · D06 = 1줄(_afterExecuted) ·
   D07 = 4줄(findById · watchManualFillFormSpec · recordManualFill · watchCommand) · D08 = 0 · D09 = 0 · D10 = 0 · D11 = «lib/l10n/labels.dart:47»(🔴 정확히 — R5c 병합본 41(⟦실측⟧) + R5d 6) ·
   D12 = 3줄(src/journal_draft/advice_skip_form.dart · src/journal_draft/journal_draft_form.dart · 🆕 src/journal_draft/manual_fill_form.dart 차례 · 🔴 정확히) · D13 = 2줄 · D14~D17 = 0 · D18 = «test/manual_fill_form_test.dart:12» · D19 = «test/manual_fill_form_test.dart:2»(🔴 정확히) ·
   D20 = 22줄 = 위 «Key 표» 이름마다 정확히 1줄 · D21~D25 = 0 · D26 = 두 줄(labels.dart · journal_draft.dart — 둘째 수 0 · journal_draft.dart 첫째 수 1 · labels.dart 첫째 수 = ⟦실측⟧) · 그 밖 파일 줄 없음 · D27 = 0 · D28 = 1줄(manualFillSeedWithCommand) · D29 = 0 ·
   D30 = 8줄 전부 «A» · D31 = «test/manual_fill_form_test.dart:12»(🔴 정확히) · D32 = 0 · D33 = 0 · D34 = 1줄(s.clear(_draftKey) — 🔴 컨트롤러·목록의 .clear( 0) · D35 = 1줄(재제출 버튼) · D36 = 2줄(_input · _restore) · D37 = 1줄(_report))
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · D08 · D23 은 주석 줄도 센다(규칙 15))

■ 골든 — 4이름 × light/dark = 8장(전부 신규 · ✅ K35 · 이름 = 02 §3-8 (e) 글자 그대로 · golden README «🆕 R5» 절 표 그대로)
  a3 — test/golden/a3_golden_test.dart · const Size _kTallPhone = Size(390, ⟦실측⟧)(폭 390 고정 · 드라이런 맨 아래 dy 최대 ⟦실측⟧) · 위젯 = ManualFillForm(adviceId: flow.item.adviceId) · import 'package:ui_journal/journal_draft.dart'; · 열기 = 테스트마다 새 RecordingLinkOpener:
    이름                  findById    사양         초안(RecordingDraftStore)       명령(FakeManualFillCommandApi)                        흐름                                맨 아래 Key
    a3_empty              ad0001      spec         빈                             받침대(UnimplementedCommandApi — 부르지 않는다)       없음                                Key('a3-submit')
    a3_advice_linked      partial     spec         빈                             받침대                                               a3-prefill 탭(칸 = «20»)            Key('a3-submit')
    a3_rejected_price     ad0002      spec         seed = [drafts.rows[0]]        record·watch = rejectedPrice                          a3-submit ensureVisible 뒤 탭        Key('a3-submit')
    a3_form_spec_stale    ad0001      staleSpec    빈                             받침대                                               없음                                Key('a3-asof')(폼 0 · 발주자 확인 ⑩)
  모양 = h63_golden_test.dart(R4b)와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록(private class _Flow) × Brightness.values 루프 · 흐름 = 클로저 칸 · 테스트 이름 '${flow.name} ${brightnessSuffix(b)}' ·
  주입 = pumpForGolden(tester, ManualFillForm(adviceId: …), brightness: b, logicalSize: _kTallPhone, wrapApp: (Widget app) => ProviderScope(overrides: manualFillOverrides(…), child: app)) → await tester.pump(); → await tester.pump(); →
    await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden(flow.name, b) · 🔵 명령 칸 = 경우 칸의 CommandApi(받침대 또는 가짜 — collection-if 0 · 삼항 0).
  위치 전제 둘 = 이 코드 글자 꼴(C4r3-5 · 흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(_kTallPhone.height));
    expect(tester.getTopLeft(find.byKey(const Key('a3-asof'))).dy, 0.0);
  명령(packages/ui_journal): flutter test --update-goldens test/golden/a3_golden_test.dart → flutter test(옵션 없이 · git status 에 새 PNG 8 만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이(_kTallPhone)는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     골든 높이 = 카드 확정값 + 여백 재량 — 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개)
· A3_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지 · 행 앞에 «A-3:» 접두(🔵 예외 = 골든 dy «측정:» 행).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A4 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 4줄을 그대로 붙이고 <값> 자리에만 잰 수를 넣는다(높이 = 리터럴):
      ┌── 측정 행 복사 시작(다음 줄부터 · 4줄)
| A1 | R5d-Bob-A3 | 추측 | 측정: a3_empty dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A2 | R5d-Bob-A3 | 추측 | 측정: a3_advice_linked dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A3 | R5d-Bob-A3 | 추측 | 측정: a3_rejected_price dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A4 | R5d-Bob-A3 | 추측 | 측정: a3_form_spec_stale dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖)
  여백을 줄였으면 A5 부터 «측정:» 전·후 행 · 6개 밖에 더 필요했던 정적 라벨 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 6 · 읽지 않는 필드 · 배치 순서 · 참조 카드 · 입력 모양 · 선택 표시 · 수량 표식 · 잠금 · 신선도 초과 · 재제출 · 빈 폼 · 골든 이름·입력 · 재량(여백·크기·모서리).
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(5) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋)
  cd packages/ui_journal
  flutter test test/manual_fill_form_test.dart          ← 끝 줄 그대로(기대 «+28: All tests passed!»)
  flutter test test/golden/a3_golden_test.dart          ← 끝 줄 그대로(기대 «+8: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄 그대로 · 기대 = 시작 기준 N + 36 — ⟦실측⟧ → «+⟦실측⟧: All tests passed!»)
  cd ../domain_contracts
  dart test test/contracts/c46_advice_x7_test.dart -r expanded   ← 전부 통과 · «C-46 ⑯ 대상» 줄과 그 아래 들여쓴 경로 줄을 그대로 적어 둔다
     (기대 7줄: «C-46 ⑯ 대상 6파일 — …» + 공백 4칸 들여쓴 경로 6줄(…/advice/advice_card.dart · advice_detail.dart · advice_history.dart · advice_inbox.dart · journal_draft/advice_skip_form.dart · 🆕 journal_draft/manual_fill_form.dart — 정렬 순) ·
      🔴 «5파일» 이면 파일 이름이 카드와 다르다 — 멈춤 · ⑰ 이 ManualFillPrefillFields.quantity 로 실패하면 선행 M2 보강 전 판이다 — 멈추고 채팅으로)
  cd ../..
  bash tool/check_boundaries.sh   ← 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건(«packages/ui_journal/lib/src/timeline.dart:109»)은 이 카드와 무관 — 그대로 둔다 · 그 밖 🟡 [C-5] 0
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+⟦실측⟧ ~30: All tests passed!» · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_journal/): M lib/journal_draft.dart · M lib/l10n/labels.dart · A lib/src/journal_draft/manual_fill_form.dart · A test/golden/a3_golden_test.dart · A test/golden/goldens/a3_*.png 8장 ·
        A test/manual_fill_fakes.dart · A test/manual_fill_form_test.dart · M docs/ai-context/inbox/A3_questions.md · 그 밖의 줄(특히 M lib/src/journal_draft/advice_skip_form.dart · M lib/src/journal_draft/journal_draft_form.dart · M lib/ui_journal.dart ·
        M test/advice_skip_fakes.dart · M PNG · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M6] R5d (6) 사전검사 지적 수정» · amend 금지 · format:fix 먼저) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m6-a3-fill
  git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD   ← ① 에 그대로 붙일 출력(권장대로면 커밋 5줄)
  cd packages/ui_journal → 위 «정적 묶음» 37줄 → cd ../..   ← ② 에 그대로 붙일 출력
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M6] A-3 수기 체결 기록
  🔴 채팅 답 = 아래 제출 글 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님) + 끝 flutter test 한 줄.
  PR 본문 5섹션을 채팅으로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R5d-Bob-A3_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R5d-Bob-A3_submit.md --golden-prefix a3 --goldens 8
        ← 🔴 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 채팅에 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다) · 출력은 채팅에 붙이지 않는다 · 🔵 🟡 [G1] 은 멈춤이 아니다(셈 단위 견본 = 아래 ③ · ⟦실측⟧).
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + name-status 출력 그대로(코드 블록 하나) + «커밋 목록:» + log 출력 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: A-3 — 수기 체결 기록(ManualFillForm(adviceId:) · operator)
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 23항 — 아래 복사 상자 23줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 23줄 그대로인지 «23항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «산술 = 신선도 한 식 · 선택 == · 드롭다운 값 확인 · 잠금 switch 뿐 · 입력 검사·변환 0 · 금지 수치 D16 0건 · 소수·% 리터럴 D17 0건»
        2번 = «한국어 리터럴 = labels.dart(R5d 절 6개 · 합 <N> — D11) 한 파일뿐(D15 0건) · 엔진 글자 = DTO *Label·label·stateLabel·retryLabel 그대로»
        3번 = «이 카드 범위 밖(손익·J-4 없음) · 손익 0(D08)»
        4번 = «이 카드 범위 밖(H6-1·H6-2 = R4)»
        5번 = «M5 화면 렌더 0 · 정정·무효 진입 0(M5-12) · 링크 = pop 하나(D06)»
        6번 = «정적 묶음 D14 — 허용 밖 import 0줄 · pubspec·analysis_options 무변경(D26)»
        7번 = «A-3 = operator 파일(journal_draft/ · operator 배럴 D12 <N>줄) · 배럴은 operator 파일 export·import 0(C-35 ⑥) · 근거 원문 필드 0»
        8번 = «배너 = JournalSafetyBanners 그대로 · 폼 배너 = bannerText 그대로(A3-09) · 화면이 지은 배너 문구 0»
        9번 = «머리 = spec.asOf.label(a3-asof · A3-01) · 로딩·부재·에러·오래됨·차단 = A3-13 · A3-10 · A3-09»
        10번 = «타입·필드 이름 짓기 0 · 픽스처 변경 0 · 새 PNG = a3_* 8장 · 재생성 <N>장(D30)»
        11번 = «모드 필드 0(D08) · 접두·띠 0 · 존재 = 데이터(prefillQuantityLabel · retryLabel · blockedText · bannerText 의 null 여부)»
        12번 = «이 카드 범위 밖(A-1·A-2 = R5b·R5c · 이 화면 = 기록 폼)»
        13번 = «안내 값과 입력값 비교 0 · 프리필 = 수량 버튼 하나(A3-02 · A3-03) · 가격·거래일 채우기 0 · 정정 모드 0»
        14번 = «이 카드 범위 밖(폰 전용 폼 · 뷰어 = 셸 «폰에서만»)»
        15번 = «안내를 J-1 에 섞지 않음(J-1 파일 무수정 · D26) · 예산 차감 명령 0(D08)»
        16번 = «이 카드 범위 밖(L-3 = R5e)»
        17번 = «내보내기·공유·인쇄 0»
        18번 = «링크 null = 부재(이 화면 링크 = pop 하나) · 재제출 버튼 = retryLabel null 이면 부재(A3-05) · id 로 버튼 존재 판정 0»
        19번 = «거르기·묶기·재정렬 0(D08) · 선택지 = 받은 순서 · 링크 조립 0(D04 · D09)»
        20번 = «띠 높이 예약 0 · 신선도 = 주입 Clock + asOf 한 식(A3-10)»
        21번 = «플래그 재정렬·리터럴 비교 0 · FlagIds·activeFlags 0(C-46 ㉑ · D08)»
        22번 = «DraftStore 주입 = operator 쪽(manual_fill_form.dart)만 · pubspec 무변경(D26)»
        23번 = «clear = executed 한 곳(D34 <N>줄 · A3-05) · 확인값(retryCodes) 초안 밖 · 첫 접수증 전 잠금(A3-08) · 복원 id executed = 빈 폼(A3-08)»
      ┌── 복사 시작(다음 줄부터 · 23줄)
 1. 화면 코드에 금액·비율 산술이 없는가(레이아웃 정규값 × 폭만) / 건수·잔량·D-day 를 세지 않았는가 [x] ( )
 2. 사유·상태·규칙 문구의 문자열 리터럴이 없는가(DTO `label` 계열만 · 정적 라벨은 `labels.dart` 한 파일) [x] ( )
 3. 종목 손익이 기본 접힘이고 손익 정렬·필터가 없는가 / `J-4` 채점 전 데이터에 결과가 없고 공개 결과에 금액이 없는가 [x] ( )
 4. `H6-1`·`H6-2` 기본 구독이 `includePnl: false` 인가(펼침 = 토글 재구독) [x] ( )
 5. M5·X1·X5 소유 화면을 렌더하거나 조작 버튼을 만들지 않았는가(딥링크·삽입 자리만) [x] ( )
 6. `ui_journal`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import 하지 않는가 [x] ( )
 7. 폰 전용 쓰기 화면이 operator 라이브러리에만 있고 배럴이 그것을 export·import 하지 않는가 / 브로커 근거 원문 필드를 웹·뷰어 판에 그리지 않는가 [x] ( )
 8. 명세 §2-2 표에 없는 차단 표기·배너 문구를 발명하지 않았는가 [x] ( )
 9. 「현재」 표기에 기준일 고지(`AsOf.label`)가 붙는가(공통 상태 6종 = 02 §2-6) [x] ( )
10. 표·코드에 없는 타입·필드 이름을 지어내지 않았는가 / 픽스처·`*.golden.json` 을 고치거나 기존 PNG 를 지시 없이 다시 찍지 않았는가 [x] ( )
11. 모드 필드로 블록·배지의 존재나 문구를 정하지 않았는가 / 타이틀 접두·띠를 화면이 붙이지 않았는가 [x] ( )
12. `A-1`·`A-2` 버튼이 `actions` 목록 그대로이고 `status`·`onHold`·`suppressed` 조합 분기가 없는가 [x] ( )
13. 안내 값과 입력값을 비교하지 않았는가 / `A-3` 프리필이 수량 버튼 하나뿐이고 정정 모드가 없는가 [x] ( )
14. viewer 판에서 종목·수량·가격을 화면이 채우지 않고 온 글자(`phoneOnlyLabel`)만 그리는가 [x] ( )
15. 안내를 `J-1` 원장 타임라인에 섞지 않았는가 / 예산 차감 명령 2종을 M6 코드가 부르지 않는가 [x] ( )
16. `L-3` 세션 중 안내 수량·`priceBand` 를 가리지 않고, 가림 대상을 화면이 판정하지 않는가 [x] ( )
17. 내보내기·공유·인쇄 버튼이 없는가 [x] ( )
18. 링크가 null 이면 버튼·행 탭이 부재인가(비활성으로 그리지 않는가 — `J-2` `rebalanceLink` 포함) / id 로 버튼 존재를 판정하지 않았는가 [x] ( )
19. 목록을 화면이 거르거나 묶거나 다시 정렬하지 않았는가(`J-1` 출처·회차 = 서버 인자 · `orderIntentIds` 순회 0 · 회차 칩·씨앗 = `watchRebalanceScope` 만 — 02 §7 19 세목) / 링크를 `AppRoutes` 패턴·id·날짜로 조립하지 않았는가 [x] ( )
20. 띠 높이를 고정 예약하지 않았는가 / 신선도를 주입 `Clock` 과 `asOf` 로 판정하는가 [x] ( )
21. 차단 플래그를 재정렬하거나 표식 플래그를 경고 배너로 그리거나 `flagId` 를 리터럴로 비교하지 않았는가 [x] ( )
22. `DraftStore` 주입이 operator 쪽에만 있고 pubspec 에 저장 패키지를 더하지 않았는가 [x] ( )
23. 초안을 `executed` 밖에서 지우거나 확인값을 담거나 첫 접수증 전에 입력·제출을 열지 않았는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M6.md 252~274행과 같습니다)
      23항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r5d_box2.txt)에 저장 → (Get-Content $env:TEMP\r5d_box2.txt).Count 또는 grep -c "" "$TEMP/r5d_box2.txt" →
        출력 한 줄을 아래 «23항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 23):
      ┌── 23항 줄 수 복사 시작(다음 줄부터 · 4줄)
23항 줄 수:
```
<출력 한 줄>
```
      └── 23항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 37줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄 정확히 «없음» +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(D18·D19 출력 줄 그대로 복사) + «C-46 ⑯ 출력:» + 출력 7줄 그대로 + «테스트 파일별:» + 위 flutter test 두 파일 끝 줄 그대로(manual_fill_form · a3_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = D18 출력:
<D18 출력 줄 그대로>
ⓗ = D19 출력:
<D19 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — 로딩·정상·부재·에러·오래됨·차단 6줄 + 골든 표 8행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로:
         «정상» = ListView → Key('a3-asof') → JournalSafetyBanners → Key('a3-banner')(있을 때) → Key('a3-ref') → Key('a3-prefill')(있을 때) → ValueKey<String>('a3-date-$i') → Key('a3-symbol') → ValueKey<String>('a3-side-$i') →
                  Key('a3-quantity') → Key('a3-price') → Key('a3-commission') → Key('a3-tax') → Key('a3-account') → Key('a3-append-notice') → Key('a3-receipt')(있을 때) → Key('a3-retry')(있을 때) →
                  Key('a3-submit-not-accepted')(있을 때) → Key('a3-resubscribe')(있을 때) → Key('a3-submit')
         «로딩» = JournalSkeleton(Key('a3-loading')) · «부재» = Key('a3-absent') · «에러» = JournalErrorView(Key('a3-fail')) · «오래됨» = ListView → Key('a3-asof') → JournalStaleBanner → JournalSafetyBanners ·
         «차단» = «정상» 의 끝 Key('a3-submit') 자리에 Key('a3-blocked')
      골든 표 8행(한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |» · 이름 칸 = «a3_empty light» 꼴 · 입력 = 경로 그대로(a3_empty = «advice_12.json 행 3 + fill_form_spec.json» ·
        a3_rejected_price = «advice_12.json 행 4 + fill_form_spec.json + draft_records_x7.json 행 0 + fill_rejected_price.json») · 크기 = 390×<높이 리터럴> · dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(4장) ·
        dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) · 칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 칩 n개 · 입력 칸 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(8행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 ·
        🔴 사전검사 G1 출력을 옮기지 않는다) · 셈 단위 견본 2행(드라이런이 PNG 를 열어 쓴 칸 · 꼴만 본뜬다): ⟦실측⟧ · ⟦실측⟧.
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/A3_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = A3_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_journal 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 36 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-a3-fill` 푸시 1건 · 커밋 권장 5개(마지막 = format·질문 · amend·rebase·강제 푸시 0 · 커밋마다 지정 파일 add · (5) 뒤 = 사전검사 ① 수정 (6) 하나만).
- `lib/` 새 파일 **1**(`src/journal_draft/manual_fill_form.dart`) · 수정 2(더하기만 — `labels.dart` R5d 절 라벨 6 · `journal_draft.dart` export 1줄 끝) · 앞 카드 파일·J-3 파일·배럴·그 밖 lib·`apps/`·`domain_contracts`·pubspec 변경 0.
- `test/` 새 파일 3(`manual_fill_fakes.dart` · `manual_fill_form_test.dart` · `golden/a3_golden_test.dart`) + 새 PNG 8장 · 재생성 0 · 기존 fakes 무수정.
- 질문 파일 `A3_questions.md`(새 행 A1~A4 «측정:» 반드시).
- 채팅: PR 본문 5섹션 + flutter test 한 줄 · 사전검사 ① 한 번 · ② 한 번(`a3` · 8) 🔴 0.
- `flutter test` = 시작 기준 N(⟦실측⟧ = R5c 병합본 + M2 보강) + 36(뷰 28 + 골든 8 · 드라이런 ⟦실측⟧) · 정적 D11 = 47 · D12 = 3줄 · D13 = 2 · D18 = 12 · D19 = 2 · D20 = 22 · D28 = 1 · D30 = 8 A · D31 = 12(🔴 정확히) · S05 = 0 · D06 = 1 · D07 = 4 · D34 = 1 · D35 = 1 · D36 = 2 · D37 = 1 · C-46 ⑯ = 6파일.
- 재분할 임계(카드 계획): 새 `testWidgets(`·`test(` 줄 15 · lib +⟦실측⟧/-0 · 새 PNG 8 → 재분할 없음 예상.
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것: ⟦실측⟧.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R5d-Bob-A3 결과: 브랜치 ui/m6-a3-fill 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. 0단계에서 멈췄다면 `R5d-Bob-A3 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① `advice_skip_form.dart`(R5c)·`journal_draft_form.dart`(J-3)·`lib/ui_journal.dart`·`common/**`·기존 테스트·기존 PNG 가 `M` ② `apps/**`·`packages/domain_contracts/**`·다른 `ui_*` 가 `M` ③ `manual_fill_form.dart` 에 `int.parse`·`Decimal`·`.trim(`·`.isEmpty`·`OrderSide.`·`CommandContext`·`ManualFillRecord(`·`rejectReasonCode`·`Checkbox`·`showDatePicker`·`'aaq://`·`AppRoutes.`·`watchState`·`FlagIds` ④ 참조 카드 값을 칸에 채움 · 가격·거래일 채우기 ⑤ 제출 버튼을 입력 검사로 끔 ⑥ `.clear(` 가 둘 이상(컨트롤러·목록) · `executed` 밖 `clear` · 복원 id `executed` 에 pop ⑦ `retryCodes` 를 덮어씀·초안에 담음 ⑧ 공용 2파일에 삭제 줄 · export 가 끝이 아님 ⑨ D11 ≠ 47 · D12 ≠ 3 · D18·D19·D31 이 카드와 다름 ⑩ 테스트에 `name ==`·`opened[0]`·`recorded[0]`·`|| … isTrue`·bool 칸 + if · DTO 생성자 — 하나라도 있으면 반려 신호.
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 만).
- 🔵 C-46 ⑯~㉔ 의 화면 스캔은 파일 이름으로 대상을 고른다(`lib/src/journal_draft/manual_fill_form.dart`) — 다른 이름이면 «공허 통과» → 제출 ② 의 «C-46 ⑯ 출력» 7줄로 확인한다. 🔴 선행 M2 보강이 없으면 ⑰ 이 `ManualFillPrefillFields.quantity` 로 실패한다(카드가 아니라 계약 쪽 결함 — Bob 이 우회하지 않는다).
- 🔵 R5e(`L-3`)는 이 카드 병합 뒤 — 같은 operator 꼴(`_restore`·`_applyReceipt`·`_afterExecuted`·`_locked`)을 본뜨고 operator 배럴 끝에 한 줄을 더한다.
- 🔵 ⟦실측⟧ R5c 병합 기록 때 채울 것(이 파일의 자리표시자): `__R5A_SQ__`~`__R5C_SQ__` · 시작 기준 N(R5c 병합본 + M2 보강 실측) · 0단계 R5c 확인 줄 4개 · 선행 M2 보강 줄(⑰ 예외) · 계약 버전 줄 · 기존 PNG 수(136 예상) · `domain_contracts` 끝 줄 · R5a~R5c C4 이월 · 드라이런 값 전부.
- 범위 고지: 01 §8 미결 115(정정·무효 = M5-12) · 116(안내 밖 수기 = M5-6) · 53 ⑥ 확장(닫힌 안내의 `A-3` 초안 «버리기» — UI 0)은 이 카드가 닫지 않는다 · 🆕 선행 = C-46 ⑰ 예외(발주자 확인 ①).
