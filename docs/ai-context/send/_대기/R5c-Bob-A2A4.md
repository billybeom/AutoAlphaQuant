# 발송 패킷 R5c-Bob-A2A4 — A-2 안내 상세 · A-4 미이행 사유 (계약 v1.12~v1.14 · prompt_M6 v2 · R5 5장 중 3번째 · M6 X7 — 제출·초안 꼴 처음)

> ⬜ **_대기 — R5b 병합 기록 때 `send/` 로**(2026-10-27 조립 · 앱 기록 가지 `rec/r5`) — 남은 것: ① R5b 병합(`R5b-Bob-A1` · squash = `__R5B_SQ__` — R5b 병합 기록 커밋이 이 파일의 자리표시자를 채우고 `send/` 로 옮긴다) ② 누적 드라이런(worktree `C:/Work/AAQ-claude-r5dry` · 가지 `dry/r5c` = `dry/r5b` 끝(R5b 병합본 흉내)에서 · 권장 5커밋 · ⟦실측⟧ 표식을 실측으로 — `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R5c-Bob-A2A4.md` 로 센다 · 🔴 보내기 전 0 · `__R5B_SQ__` 0) ③ 실제 병합본 위 재드라이런(R5a·R5b 가 통합 수정으로 바뀌면) ④ 드라이런 브랜치 사전검사 ① 🔴 0 · ② `a2` 6 · `a4` 4 🔴 0 ⑤ 발주자 확인(아래 ①~⑬ — 카드 기본값 = 권고) ⑥ 재분할 판정(임계 = 새 `testWidgets(`·`test(` 줄 > 33 · lib > +900 · 새 PNG > 16 — 계획 = 줄 21 · PNG 10) → 「푸시해」 → 머리 첫 줄 ▶.
> 만든 날 2026-10-27 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R5c-Bob-A2A4` 행 + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · PR 본문은 통합 담당 · 재제출 = 전체판 + 상자 · 골든 높이 = 카드 확정값 + 여백 재량 · 커밋 = 제목만) + R4a·R4b·R13a·R13b C4 이월 부록의 **공통 교훈만**(부록 블록 자체는 ✅ K47 대로 R5a 카드 «6» · R5c 의 이월 = R5a·R5b C4 결과 — 병합 기록 때 ⟦실측⟧) · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-22_R5R13선행_계약v1.12_설계서.md` §8-1~§8-3 · K4 · K10 · K11 · K12 · K18 · K21 · K22 · K35 · K37 · K39 · K40(✅ 발주자 확정 2026-10-22) · 조문 = `01_…` §21-3 · §21-6 `A-2`·`A-4` 행 · §21-7 · §21-8 · §21-10-4 · §21-12-1(C-46 ⑰~㉖) · §21-16-1 · §12-1(초안) · §12-4(접수증 잠금) · `02_…` §3-A · §3-7 · §3-9 · §3-10 끝 «계약 v1.12» 블록 ⓐⓑⓕⓗⓙⓚ · 코드 = `packages/domain_contracts`(`AdviceItem` · `ManualFillFormSpec` · `ReasonOption` · `TradeJournalEntry` · `AdviceSkipSubmission` · `AdviceSkipInput.fromReasonCode` · `DraftKey` · `DraftRecord` · `CommandReceipt` · `CommandState` · `AppNavActions.back` · `AdviceRepository.findById`·`fillsOfAdvice`·`watchManualFillFormSpec` · `CommandApi.skipAdvice`·`watchCommand` · 받침대 `UnimplementedAdviceRepository` · `UnimplementedCommandApi` · `RecordingDraftStore` · `RecordingLinkOpener` · C-46).
> 사전 조건 — ✅ 계약 v1.12(PR #68 `fb67caf`) · ✅ v1.13 · ✅ v1.14(ui_journal 영향 0 · `contractVersion = '1.14.0'` — ⟦실측⟧ 엔진 카드가 먼저 병합되면 0단계 버전 줄을 병합 기록이 고친다) · ✅ `prompt_M6` v2 · ⬜ **R5a 병합**(`__R5A_SQ__` — R5a 병합 기록이 채움 · 이 카드는 R5a 파일을 쓰지 않는다) · ⬜ **R5b 병합(`__R5B_SQ__`)** — 이 카드는 R5b 의 `AdviceCard`·`journalAdviceRepositoryProvider`·`test/advice_fakes.dart` 도우미를 **import 만** 한다. 시작 기준 = R5b 병합본의 `flutter test`(packages/ui_journal) = **⟦실측⟧**(카드 계획 = 388 + R5a 41 + R5b 52 = 481) · 이 카드 끝 기대 = 시작 기준 N + **뷰 38(A-2 15 + A-4 23) + 골든 10 = N + 48**(카드 계획 · 드라이런 ⟦실측⟧) · `domain_contracts` «+⟦실측⟧ ~30»(이 카드 몫 0).
> 카드 기본값(카드 권한 — 🔵 아래 «발주자 확인» ①~⑬ 이 권고대로면 그대로): ⓐ 위젯 = `AdviceDetail({super.key, required this.adviceId})`(`lib/src/advice_detail.dart` · 배럴 쪽 · ConsumerWidget) · `AdviceSkipForm({super.key, required this.adviceId})`(`lib/src/journal_draft/advice_skip_form.dart` · **operator** · ConsumerStatefulWidget — X7 제출·초안 꼴 처음) ⓑ 주입 = **새 주입 0** — `journalAdviceRepositoryProvider`(R5b `advice_inbox.dart`) · `journalCommandApiProvider`·`journalDraftStoreProvider`(J-3 `journal_draft_form.dart`) · 안전·링크·시계(`timeline.dart`) 를 import 만 · 데이터 4 = 각 파일 안 private(A-2 = `findById`·`fillsOfAdvice` FutureProvider.family 둘 · A-4 = `findById` FutureProvider.family + `watchManualFillFormSpec()` StreamProvider) ⓒ A-2 = 머리 · 배너 · 공개 조각 `AdviceCard`(R5b · 버튼 = `actions`) · 회수 `closeReasonLabel` · 기록 편차 칩 · 결정 링크 `decisionLink` 1개(✅ K18) · 「기록된 체결」 = `fillsOfAdvice` 받은 순서 + 공용 `JournalEntryCard`(행 탭 = `detailDeepLink` → J-2) ⓓ A-4 = 1탭이 곧 제출(`skipAdvice(AdviceSkipSubmission(adviceId:, input: AdviceSkipInput.fromReasonCode(option.code)))` · K12) · 예산 코드 2종(`option.deepLink` non-null) = 그 링크 push 만(명령 0 · `save`·`clear` 0) · 제출 전 `skipNoticeText` 1줄 ⓔ 접수증 = J-3 꼴(`watchCommand` · 첫 접수증 전 잠금 · `clear` = `executed` 한 곳) + 이 화면이 낸 명령의 `executed` = `clear` + pop(`AppNavActions.back`) · 복원 id 의 `executed` = `clear` + 빈 폼(K11 · pop 0) ⓕ 정적 라벨 2(⑪) ⓖ Key 접두 `a2-`·`a4-`(순번만 · `AdviceCard` 안 Key 0) ⓗ 테스트 = `test/advice_detail_fakes.dart` · `test/advice_skip_fakes.dart`(새 · 자기 파일 · R5d 가 `FakeAdviceFormRepository`·`adviceFormRefTexts` 를 import) · `test/advice_detail_test.dart` · `test/advice_skip_form_test.dart` · 골든 5이름 10장(`a2_golden_test.dart` 3 · `a4_golden_test.dart` 2) ⓘ 공용 파일 3(`labels.dart` R5c 절 · 배럴 export 1줄 · operator 배럴 export 1줄 — 정렬 자리) = **더하기만**.
> 🔴 **카드 덮개 필수 문장(02 §3-7 · §3-9 · §3-10 끝 v1.12 블록 · 01 §21-3 · §21-6 · §21-7 · §21-8)** — «`A-2` 는 계획의 근거다 — 안내 수량·지정가를 편집하는 컨트롤 0 · 스냅샷 = `decisionLink` 링크 1개(`J-2` 임베드·`watchDecisionDetail` 0) · 「기록된 체결」 = 받은 순서 그대로(접기·묶기·`fillKind` 0) · 화면이 안내 값과 기록값을 비교해 칩을 만들지 않는다(`recordedDeviationChips` = 엔진)» · «`A-4` 는 1탭이 곧 제출이다 — `note` 입력란 0 · 「전부 건너뛰기」 0 · 예산 코드 2종 = `option.deepLink` 로 push 만(명령·초안 0) · 사유 글자 = `option.label` 그대로 · 코드 비교 0(`option.deepLink` 의 null 여부 하나로 가른다)» · «원문 → 명령 — 화면은 와이어(`AdviceSkip(`)·`CommandContext` 를 만들지 않는다 · 낙관 갱신 0 · `requested`·보류 3상태 = 머문다 · `clear` = `executed` 한 곳» · «화면은 안전 상태를 읽지 않는다 — `.watchState(`·`activeFlags`·`FlagIds` 0 · 제출 부재 = `blockedText` · 폼 배너 = `bannerText`». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — K4(제출 = 원문 DTO · 화면 검증·파싱 0) · K10 ⓐ(기존 `journal_draft.dart` 에 X7 폼 export · 주입 재사용) · K11(복원 id 의 `executed` = `clear` + 빈 폼 · pop 0) · K12(`A-4` 탭 = 제출 · 예산 코드 = `deepLink` push · `fromReasonCode`) · K18(스냅샷 = `decisionLink` 1개 · 체결 = 받은 순서) · K21(`blockedText`·`bannerText`) · K22(`requiresNote` = 예산 2종만 — 화면은 읽지 않는다) · K35(R5c 10장) · K37(`skipNoticeText`) · K39(`closeReasonLabel`) · K40(뷰어 체결 = 빈 목록) = **✅ 발주자 확정(2026-10-22 · 01 §21-14)**.
> 🔵 **발주자 확인 대기(카드 기본값 = 권고 · 🔴 확인 전 ▶ 금지)**: ① **`A-2` «부재» 갈래 글자**(01 §21-7 «`findById` 가 null = 공용 «부재» 갈래(정적 라벨 사전)» · 지금 사전에 없다) → 권고 = 정적 라벨 `adviceNotFound` «이 안내를 찾을 수 없습니다» 한 줄(`A-2`·`A-4` · R5d `A-3` 도 import 해 쓴다) · 대안 = 빈 화면(머리 0) ② **체결 행 = 공용 `JournalEntryCard(key:, entry:)` 재사용**(R4b `H6-2` 최근 체결 선례 `holding_detail.dart:217` · 행 탭 = 그 조각 안 `detailDeepLink` → `J-2` · 01 §21-8 «체결 행 `detailDeepLink`») · 대안 = 이 파일 private 행 ③ **체결 블록 갈래** — 첫 값 전 = 블록 부재(스피너 0) · 에러 = `JournalErrorView(key: a2-fills-fail)`(그 블록만 · 01 §21-7) · 빈 목록 = 머리 «기록된 체결» 까지 부재 · 값 = 정적 머리 1줄 + 행 ④ **`A-2` 배치 순서** = 머리 → 오래됨 → 배너 → `AdviceCard`(버튼 포함) → 회수 `closeReasonLabel` → 기록 편차 칩 `recordedDeviationChips` → 결정 링크 → 「기록된 체결」 ⑤ **`A-4` 머리 참조 카드** = 엔진 글자 6(`symbolLabel?` · `sideLabel?` · `sizingLabel` · `priceBand?.label` · `validityLabel` · `progressLabel` — R5d `A-3` 참조 카드와 같은 글자 · 버튼 0 · `AdviceCard` 재사용 아님 — 그 조각은 `actions` 버튼을 그려 `A-4` 가 자기 자신으로 가는 고리가 생긴다) · 대안 = 참조 카드 0 ⑥ **`A-4` 사양 신선도 초과 = 폼 열지 않음**(prompt 194행 «쓰기 화면 공통» · 01 §21-7 `A-3` 행 준용) — 머리 + `JournalStaleBanner` + 배너만(참조 카드·문구·사유 0) ⑦ **`A-4` `blockedText` = 사유 버튼 전부 부재**(예산 코드 포함 · 01 §21-7 «A-3 과 같은 접수증 갈래» + K21 «`A-4` 는 같은 폼 사양을 읽으니 같은 칸») + 문장 ⑧ **`A-4` 복원 = `lastCommandId` 하나**(입력 칸이 없어 사유 글자를 복원해 보여 줄 자리 0 · `draft_records_x7` rows[1] 의 `reason` 은 읽지 않는다) · 복원 id 의 첫 접수증 `executed` = `clear` + 빈 폼(접수증 줄 지움 · 버튼 활성 · pop 0 — K11) ⑨ **`A-4` 의 pop** — 01 §21-8 `A-4` 호출 표에는 `AppNavActions.back` 이 없지만 01 §21-7 `A-4` 행 «A-3 과 같은 접수증 갈래» + prompt 191~193행 → 권고 = 이 화면이 낸 명령의 `executed` = `clear` + pop · 01 §21-8 `A-4` 행에 `AppNavActions.back` 한 칸 더하기 = 병합 기록 후보 ⑩ **잠금 중 사유 버튼 전부 비활성**(예산 코드 포함 · 첫 접수증 전 · 제출 중 · `requested`·보류 3상태 · `executed`) ⑪ 정적 라벨 2(`adviceNotFound` «이 안내를 찾을 수 없습니다» · `adviceRecordedFills` «기록된 체결» — R4b `holdingsRecentEntries` «최근 체결» 꼴) ⑫ 골든 크기 — `a2` = `Size(390, ⟦실측⟧)`(권고 1400 · `a2_partial` 체결 1행 포함) · `a4` = `Size(390, ⟦실측⟧)`(권고 1000) — 드라이런 확정값 = 카드 확정값 ⑬ **폼의 `FlutterError.reportError`** — 읽기 화면은 0(R4b·R5b «본받지 않는 것») · 폼은 J-3 `_report` 꼴 그대로 허용(01 §12-1-6 ③ · 입력값 싣지 않음) · 사전검사 ② = 두 번(`--golden-prefix a2 --goldens 6` · `--golden-prefix a4 --goldens 4` — `a` 하나로는 `a1_`·`a3_` 이 섞인다).
> 드라이런: ⬜ ⟦실측⟧(worktree `C:/Work/AAQ-claude-r5dry` · 가지 `dry/r5c`(`dry/r5b` 끝에서) · 시작 ⟦실측⟧ → 끝 ⟦실측⟧ · 파일별 ⟦실측⟧ · 사전검사 ⟦실측⟧ · 정적 묶음 ⟦실측⟧ · 변이 ⟦실측⟧).
> 프롬프트 = `docs/ai-context/prompt_M6.md`(**v2 판 275줄** · 2행 `{{범위}}` · 121행 «이번 과제 범위» → 이 카드가 덮는다(R5c = `A-2` · `A-4`) · 130행 PR 제목 = 형식만 → «[M6] A-2 안내 상세·A-4 미이행 사유» · X7 열람 `A-2` = 183~187행 · X7 기록 공통 = 189~199행 · `A-4` = 206~209행 · 자체 점검 23항 = 252~274행 · 수치·금액 = 68~74행). 🔴 Bob **새 대화** 전제 — R5a·R5b 대화를 기억하지 못합니다.
> R4·R13·R5a·R5b 교훈 반영(공통 교훈만): PNG 열람 = 이름마다 light 1장(5장 — 이미지 20장 한도) · dark 행 = light 행 칸 글자 그대로(dy 같을 때만) · 구독마다 «로딩·에러 × 갈래» · 흐름 = 클로저 칸 · 기대 링크·명령·초안 = 목록 칸 · 🔴 bool 칸 + if · `name ==`·`which ==` · `opened[0]` · `expect(a || b, isTrue)` = 반려 꼴 · 전제 if 밖 + `// pre` · 픽스처 = `main()` 머리 `final` · 가짜 공장 = `call` 삼항 · 커밋마다 `git add <파일>` · «23항 줄 수» 상자 · 골든 높이 = 카드 확정값(늘리지 않는다 · 여백만 + 측정 행) · lib 의 nullable `!` 0 · 주입 절 = 파일 머리(이 카드는 새 주입 0) · 허용 집합에 링크 문자열 0 · 뷰어 갈래에도 «화면 Text 전부»(C4r4a-2) · 🆕 `TextEditingController` 류의 `.clear(` 금지(이 카드는 입력 칸 0 — C-46 ㉓ 은 폼 파일의 모든 `.clear(` 를 본다) · ⟦실측⟧ R5a·R5b C4 이월(병합 기록 때 이 줄에 더한다).

## 0. 한 줄 목적

`AdviceDetail(adviceId:)` 가 `findById` 의 안내 한 건을 공개 조각 `AdviceCard` 로 그리고(머리 = 안내 `asOf` · 버튼 = `actions` · 회수 문장 · 기록 편차 칩 · 결정 링크 1개 · 「기록된 체결」 = `fillsOfAdvice` 받은 순서 + 공용 `JournalEntryCard`), `AdviceSkipForm(adviceId:)`(operator) 가 폼 사양의 `skipReasons` 를 받은 순서 그대로 버튼으로 그려 **1탭 = `skipAdvice` 제출**(예산 코드 = `deepLink` push 만) · 접수증 = J-3 꼴(첫 접수증 전 잠금 · `executed` = `clear` + pop · 복원 id = 빈 폼)로 짓는 X7 화면 두 개를 계약 v1.12 그대로 짓기(원값 0 · 판정 0 · 화면 검증 0).

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-a2a4`**(base = 최신 `origin/main` · `--no-track` · 브랜치 이름 = 설계 12 §3 R5c 행 · 01 §21-16-1 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 `send/_대기/` 에 있습니다(R5b 병합 기록이 옮긴다).
2. Bob 에 R5b 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R5c-Bob-A2A4.md> (🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다 · `send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R5c-Bob-A2A4 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 바깥 울타리 = 백틱 네 개(안의 «23항 줄 수» 상자 때문) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R5b-Bob-A1*.md` 를 붙여넣지 않습니다.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R5c-Bob-A2A4 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R5c-Bob-A2A4 — 범위: A-2 안내 상세(AdviceDetail(adviceId:) — 머리 · 오래됨 · 배너 · AdviceCard · 회수 문장 · 기록 편차 칩 · 결정 링크 · 「기록된 체결」 · 부재) ·
  A-4 미이행 사유(AdviceSkipForm(adviceId:) — operator · 머리 · 배너 · 참조 카드 · 문구 1줄 · 사유 버튼 = 1탭 제출 · 예산 코드 push · 접수증 · 재구독) + 정적 라벨 2 + 배럴 export 1줄 + operator 배럴 export 1줄.
🔴 A-2 는 계획의 근거다 — 안내 수량·지정가 편집 0 · 스냅샷 = decisionLink 링크 1개(J-2 임베드·watchDecisionDetail 0) · 「기록된 체결」 = 받은 순서(접기·묶기·fillKind 0) · 기록 편차 칩 = 엔진 글자 그대로.
🔴 A-4 는 1탭이 곧 제출이다 — note 입력란 0 · 「전부 건너뛰기」 0 · 예산 코드(option.deepLink non-null) = 그 링크 push 만(명령 0 · 초안 save·clear 0) · 사유 글자 = option.label · 코드 비교 0.
🔴 원문 → 명령 — AdviceSkip( · CommandContext 0 · 낙관 갱신 0 · requested·보류 3상태 = 머문다 · clear = executed 한 곳 · 이 화면이 낸 명령의 executed = clear + pop · 복원 id 의 executed = clear + 빈 폼.
🔴 화면은 안전 상태를 읽지 않는다 — .watchState( · activeFlags · FlagIds · killSwitch 0 · 배너 = JournalSafetyBanners(safety:) · 제출 부재 = blockedText · 폼 배너 = bannerText.
하지 않는 것: L-1·L-2(R5a) · A-1·「지난 안내」·AdviceCard(R5b — 병합됨 · 고치지 않음) · A-3(R5d) · L-3(R5e) · 체결 행 「정정」 · note 입력 · M5-6 화면 · 셸·라우터 · domain_contracts·pubspec 수정 · 다른 ui_* · 기존 화면·테스트 수정.
🔴 이 카드가 docs/ai-context/prompt_M6.md(판 v2) 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 24항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R5b(ui/m6-a1-inbox — 병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_journal/lib/src/advice_detail.dart · lib/src/journal_draft/advice_skip_form.dart · AdviceDetail · AdviceSkipForm 이 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-a1-inbox 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m6-a2a4 origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git branch -r --contains __R5B_SQ__                                                                                         ← «  origin/main» 이 보여야 함(R5b 병합)
  git grep -c "class AdviceCard extends ConsumerWidget" -- packages/ui_journal/lib/src/advice/advice_card.dart                 ← «…advice_card.dart:1»(R5b 병합본 · ⟦실측⟧ 꼴)
  git grep -c "final journalAdviceRepositoryProvider = Provider<AdviceRepository>(" -- packages/ui_journal/lib/src/advice_inbox.dart   ← «…advice_inbox.dart:1»(⟦실측⟧ 꼴)
  git grep -c "static const String adviceHistoryLink = " -- packages/ui_journal/lib/l10n/labels.dart                          ← «…labels.dart:1»(R5b 절의 마지막 상수 — R5c 절은 그 뒤 · ⟦실측⟧)
  git grep -c "List<String> adviceCardTexts(AdviceItem v)" -- packages/ui_journal/test/advice_fakes.dart                      ← «…advice_fakes.dart:1»(R5b 도우미 — import 해서 쓴다 · ⟦실측⟧ 꼴)
  git grep -c "contractVersion = '1.14.0'" -- packages/domain_contracts/lib/src/contract_version.dart                         ← «…contract_version.dart:1»(⟦실측⟧)
  git grep -c "Future<AdviceItem?> findById(String adviceId);" -- packages/domain_contracts/lib/src/repositories/advice_repository.dart   ← «…advice_repository.dart:1»
  git grep -c "Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId);" -- packages/domain_contracts/lib/src/repositories/advice_repository.dart   ← «…advice_repository.dart:1»
  git grep -c "Stream<ManualFillFormSpec> watchManualFillFormSpec();" -- packages/domain_contracts/lib/src/repositories/advice_repository.dart   ← «…advice_repository.dart:1»
  git grep -c "Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission);" -- packages/domain_contracts/lib/src/commands/command_api.dart   ← «…command_api.dart:1»
  git grep -c "Stream<CommandReceipt> watchCommand(String commandId);" -- packages/domain_contracts/lib/src/commands/command_api.dart   ← «…command_api.dart:1»
  git grep -c "factory AdviceSkipInput.fromReasonCode(String code) =>" -- packages/domain_contracts/lib/src/commands/drafts.dart   ← «…drafts.dart:1»
  git grep -c "static const String back = " -- packages/domain_contracts/lib/src/navigation/app_links.dart                    ← «…app_links.dart:1»(AppNavActions.back)
  git grep -c "class RecordingDraftStore implements DraftStore" -- packages/domain_contracts/lib/testing.dart                 ← «…testing.dart:1»
  git grep -c "class UnimplementedAdviceRepository implements AdviceRepository" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»
  git grep -c "class UnimplementedCommandApi implements CommandApi" -- packages/domain_contracts/lib/testing.dart             ← «…testing.dart:1»
  git grep -c "'lib/src/journal_draft/advice_skip_form.dart'," -- packages/domain_contracts/test/contracts/c46_advice_x7_test.dart   ← «…c46_advice_x7_test.dart:1»(폼 파일 이름 = 소스 스캔 대상)
  git grep -c "'lib/src/advice_detail.dart'," -- packages/domain_contracts/test/contracts/c46_advice_x7_test.dart             ← «…c46_advice_x7_test.dart:1»
  git grep -c "final journalCommandApiProvider = Provider<CommandApi>(" -- packages/ui_journal/lib/src/journal_draft/journal_draft_form.dart   ← «…journal_draft_form.dart:1»
  git grep -c "final journalDraftStoreProvider = Provider<DraftStore>(" -- packages/ui_journal/lib/src/journal_draft/journal_draft_form.dart   ← «…journal_draft_form.dart:1»
  git grep -c "판 v2" -- docs/ai-context/prompt_M6.md                                                                         ← «…prompt_M6.md:1»(없으면 멈춤)
  git grep -c "a4_budget_push" -- packages/ui_journal/test/golden/README.md                                                    ← 숫자 하나(golden README «🆕 R5» 절)
  ls docs/ai-context/send/R5c-Bob-A2A4.md                                            ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/A2A4_questions.md                                         ← 보여야 함(빈 표가 이미 있다)
  ls tool/precheck.dart                                                              ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_detail_partial.json                ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_detail_onhold.json                 ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_viewer_4.json                      ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_fills_ad0005.json                  ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_12.json                            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_form_spec.json                       ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_form_spec_stale.json                 ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/fill_form_spec_blocked.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/advice_skip_receipts_5.json               ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/draft_records_x7.json                     ← 보여야 함
     (🔴 경로는 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — R5b 병합보다 카드가 먼저 왔습니다 · && 가 안 되는 셸이면 한 줄씩)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R5c 가 들어간 것 — 멈추고 알림):
  ls packages/ui_journal/lib/src/advice_detail.dart                                  ← 없어야 함
  ls packages/ui_journal/lib/src/journal_draft/advice_skip_form.dart                 ← 없어야 함
  git grep -c "AdviceSkipForm" -- "packages/ui_journal/*.dart"                       ← 출력 없음이어야 함(🔵 golden README 의 글자는 세지 않는다 — .dart 만)
  git grep -c "a2-" -- "packages/ui_journal/*.dart"                                  ← 출력 없음이어야 함
  git grep -c "a4-" -- "packages/ui_journal/*.dart"                                  ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · 브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_journal
  flutter test   ← 시작 기준: R5b 병합본 전부 통과 · 0 실패 · 기대 «+⟦실측⟧: All tests passed!»(앞 시각은 달라도 된다)(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · 다르면 멈추지 말고 PR 본문에 까닭 한 줄 —
                   그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·AppNavActions·C-46) > 이 카드(지시) > 01 §21 > 02 §3-10 끝 v1.12 블록 > 02 §3-A·§3-7·§3-9 본문·그림 M6-27 > prompt_M6.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox/A2A4_questions.md 만. 새 파일 = lib/src/advice_detail.dart · lib/src/journal_draft/advice_skip_form.dart · test/advice_detail_fakes.dart · test/advice_skip_fakes.dart ·
   test/advice_detail_test.dart · test/advice_skip_form_test.dart · test/golden/a2_golden_test.dart · test/golden/a4_golden_test.dart · 새 PNG 10.
   공용 3파일은 **더하기만**(기존 줄 한 글자도 바꾸지 않는다 · 정적 C28 의 삭제 수 0): lib/l10n/labels.dart = JournalLabels 안 R5b 절의 마지막 상수(adviceHistoryLink · ⟦실측⟧) 뒤 · 닫는 } 앞에 R5c 절 ·
     lib/ui_journal.dart = export 'src/advice_detail.dart'; 한 줄(🔴 끝이 아니라 정렬 자리 — export 'src/advice/advice_card.dart'; 와 export 'src/advice_history.dart'; **사이** · «/» 가 «_» 보다 앞이고 «d» 가 «h» 보다 앞) ·
     lib/journal_draft.dart = export 'src/journal_draft/advice_skip_form.dart'; 한 줄(🔴 기존 export 'src/journal_draft/journal_draft_form.dart'; **앞** · 머리 주석 6줄 그대로).
   고치면 반려: 그 밖의 ui_journal 파일 전부(lib/src/common/** · lib/src/timeline.dart · lib/src/advice/** · lib/src/advice_inbox.dart · lib/src/advice_history.dart(R5b) · lib/src/ledger_*(R5a) ·
     lib/src/journal_draft/journal_draft_form.dart(J-3 — import 만) · 그 밖 lib · 기존 테스트 파일 전부(🔴 test/advice_fakes.dart(R5b) · test/holdings_overview_fakes.dart 는 import 만 · test/ledger_fakes.dart 는 import 하지 않는다) ·
     golden_support.dart · golden README · flutter_test_config.dart · goldens/ 의 기존 PNG(⟦실측⟧ 126장) · pubspec.yaml · analysis_options.yaml · README.md) · domain_contracts/** · apps/** · 다른 ui_*.
 2 두 화면은 받은 글자와 null 여부만 본다 — 값 = DTO 의 *Label·*Text·label 원문 그대로 · 원값·.wire·.name·코드 표시 금지 · 폴백 문구 금지(null 자리에 «해당 없음» 0) · 색 = Theme.of(context).colorScheme(Colors.* 금지) ·
   한국어 리터럴 = labels.dart 의 JournalLabels 에만(테스트에도 금지) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱만).
 3 읽지 않는 필드(카드가 정함 — 질문 아님):
   A-2 — AdviceItem 의 batchId · kind · tradeDate · issuedAt · validUntilDate · sleeve · status · effectiveStatus · onHold · suppressed · decision · symbol · side · quantity · recordedQuantity · closeReasonCode · dependsOnAdviceId · accountAlias ·
     expiredConfirmLabel · deferAvailable(🔵 「내일 다시」 는 A-1 인박스 몫) · prefillQuantityText · prefillQuantityLabel(A-3 몫) · isUrgent · statusTone(🔵 둘 다 AdviceCard 가 안에서 읽는다 — 이 파일은 0) · TradeJournalEntry 의 모든 필드(🔵 JournalEntryCard 에 넘기기만).
   A-4 — AdviceItem 은 참조 카드 글자 6(symbolLabel · sideLabel · sizingLabel · priceBand.label · validityLabel · progressLabel)만 · ManualFillFormSpec 의 symbols · accounts · minTradeDate · maxTradeDate · nonTradingDates ·
     priceHintLabel · quantityMax · appendOnlyNotice · sides · tradeDateOptions(🔵 A-3 몫 — A-4 는 skipReasons · skipNoticeText · blockedText · bannerText · asOf 만) · ReasonOption 의 requiresNote(🔵 K22 — 예산 = deepLink 의 null 여부) ·
     CommandReceipt 의 kind · requestedAt · expiresAt · nonce · issuedByDeviceId · rejectReasonCode · retryCode · retryLabel(🔵 A-4 표본에는 재제출 선택지가 없다 — stateLabel · state(잠금 switch) · commandId(구독)만) · DraftRecord 의 adviceSkip(🔵 복원 = lastCommandId 하나 · 발주자 확인 ⑧).
   🔴 C-46 ⑰~㉖ 이 두 파일(advice_detail.dart = 읽기 · journal_draft/advice_skip_form.dart = 폼)의 .status .onHold .suppressed .actionId .quantity .recordedQuantity .quantityMax .minTradeDate .maxTradeDate .nonTradingDates .low .high .reference .sleeve .wire .name
     .closeReasonCode .asOfTradeDate .decision · (읽기만) .symbol .side .code .fillKind · .adviceId(읽기 — 인자 자리 밖) · 객체 패턴 구조 분해 · AdviceStatus. AdviceActionId. AdviceSkipReason. OrderSide.(점 축약 포함) · *.parse · tryParse · Decimal · .round( 류 · ~/ ·
     CommandContext · AdviceSkip( · .watchState( · activeFlags · FlagIds · markerOnly · .killSwitch · watchDecisionDetail · JournalRepository · HoldingsRepository · AppRoutes. · aaq:// · (읽기만) .where/.firstWhere/…/.sort/.fold/.reduce/groupBy ·
     recordManualFill · skipAdvice · submitSelfReportBalance · amendManualFill · voidManualFill · recordLedgerEvent · .clear( 가 executed 갈래 밖 · dispose 안 ref. 를 기계로 본다(주석은 벗기고 본다 · 문자열 안도 본다).
     🔵 A-2 는 ConsumerWidget 이라 adviceId 를 필드로 바로 쓴다(.adviceId 접근 0 · family 인자 자리) · A-4 는 폼이라 option.code · widget.adviceId 를 써도 된다(⑰ 읽기 목록 밖).
 4 이동 = AppLinkOpener.open(link) 하나(ref.read(journalLinkOpenerProvider) · 탭 콜백 안 · 예외 1 = A-4 의 pop — 접수증 executed 처리 안 AppNavActions.back) — 링크 = 아래 «화면» 의 자리뿐:
   A-2 결정 링크 decisionLink.deepLink · AdviceCard 버튼(그 조각 안) · 칩(JournalReasonChip 안) · 체결 행(JournalEntryCard 안) / A-4 예산 코드 option.deepLink · pop AppNavActions.back ·
   🔴 lib·테스트에 'aaq://'·'handbook://' 리터럴 0 · 링크 조립·파싱 0 · 링크 null = 부재 · Navigator 0 · 공개 위젯 생성자 = AdviceDetail({super.key, required this.adviceId}) · AdviceSkipForm({super.key, required this.adviceId}) 둘뿐.
 5 산술·판정 0 — 허용되는 것은 넷뿐이다: ⓐ 신선도 한 식(<asOf>.observedAt.add(<asOf>.staleAfter).isBefore(clock.nowUtc()) — A-2 = item.asOf · A-4 = spec.asOf) ⓑ 빈 갈래 = 목록.isEmpty ⓒ 예산 코드 = option.deepLink 의 null 여부 ·
   ⓓ 잠금 = CommandState 전수 switch 하나(아래 «화면 2» 글자) + 진행 bool. 그 밖에 거르지도 세지도 정렬하지도 자르지도 묶지도 옮기지도 않는다(받은 순서 · 순번 = .indexed 의 i) · 사유 코드 비교 0 ·
   목록 길이·int 를 글자로 0 · .length 0 · maxLines · TextOverflow · FittedBox · .trim( · .take( 0 · DateTime.now 0 · 날짜 차이 0 · FeatureFlags · RunMode · OperatingMode 0 · 칩 목록이 비어도 Wrap 을 그대로 둔다(빈 Wrap = 칩 줄 0).
 6 switch = A-4 의 잠금 하나뿐(CommandState 9값 전수 · default·_ 0 · C-12) · A-2 = 0(상태 칩 색은 AdviceCard 안 · 새 switch 0).
 7 시계 = journalClockProvider(주입 Clock.nowUtc() 만) · 공통 조각 = JournalAsOfHeader · JournalStaleBanner · JournalSafetyBanners · JournalReasonChip · JournalEntryCard · JournalSkeleton · JournalErrorView 재사용(🔴 무수정 · 새 공용 조각 0) ·
   R5b 공개 조각 AdviceCard(item:) = A-2 가 그대로 쓴다(🔴 무수정 · 감싸는 InkWell 0 — 카드 탭 = 자기 자신이라 부재) · 상태 갈래 = 아래 «상태 표» 글자 그대로(구독마다) · 스피너 금지 ·
   배너 = ref.watch(journalSafetyStateProvider).valueOrNull 을 JournalSafetyBanners(safety:) 에 넘기기만.
 8 두 화면은 본문이다 — Scaffold · AppBar · SafeArea · ScaffoldMessenger · SnackBar · Navigator · FloatingActionButton 0(주석에도) · ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 ·
   간격·크기는 정수·N.0 만 · 띠 높이 예약 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다 · A-4 의 사유 버튼 = 전부 같은 꼴(OutlinedButton · 예산·비예산 같은 크기 — 02 §3-9 «동등한 크기·위치»).
 9 프로바이더 — 이름·타입·파일 = 아래 «주입 구조» 글자 그대로 · autoDispose 0 · 새 주입 0 · 데이터 4(각 파일 안 private · 주입 import 바로 뒤) · 기존 journalAdviceRepositoryProvider(advice_inbox.dart) · journalCommandApiProvider ·
   journalDraftStoreProvider(journal_draft_form.dart) · journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider(timeline.dart) 는 import 해서 쓴다 · 🔴 journalAdviceCommandApiProvider(「내일 다시」 몫) · journalTimelineRepositoryProvider 0 ·
   주입은 탭·제출 콜백과 initState 안 ref.read(build 에서 명령·초안 주입 watch 0) · 데이터는 build 에서 ref.watch · lib 의 nullable 에 ! 0(null 검사 뒤 지역 변수 · collection-for 안에서 지역 변수가 필요하면 private 조각/메서드로 — 정적 C35).
10 테스트 = 받침대 extends(UnimplementedAdviceRepository · UnimplementedCommandApi · RecordingDraftStore · R4a 의 FakeHoldingsSafetyRepository 재사용 — import 만 · implements 금지) · 받은 인자 전부 기록(findById·fillsOfAdvice 의 id · skipAdvice 의 제출 · watchCommand 의 id) · 호출마다 새 Future/Stream ·
   가짜 공장 = 받은 call 로 삼항(call == 0 ? Future<T>.error(StateError('fail')) : Future<T>.value(v) — C4r4b-7) · 따로 세는 변수 0 · 공장 안 early-return if 0 ·
   픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 · 자리 = testWidgets 본문 첫머리 · 전제 문장마다 끝에 `// pre`(정적 C33 이 센다 = 최소 목록의 «(전제)» 수) · 동작은 UI 를 실제로 눌러서(ensureVisible 뒤 tap) ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처에서 — AdviceItem(…) · ManualFillFormSpec(…) · CommandReceipt(…) · DraftKey(…) · DraftRecord(…) · AdviceSkipSubmission(…) · AdviceSkipInput(…) 생성자·팩토리 0 · 기대 초안 키 = draft_records_x7 rows[1].key) ·
     🔵 예외 1 = 복원 id 시드(테스트의 입력 준비): advice_skip_fakes.dart 의 adviceSkipSeedWithCommand 한 곳만 copyWith(정적 C30 1줄) · 기대 제출·초안 본문 = .toJson() 을 지도 리터럴과 비교(<String, dynamic>{'reason': <코드>, 'note': ''} — 키 글자 ASCII) ·
   링크는 RecordingLinkOpener 를 픽스처 값·상수와 비교 · 기대 링크 = 경우 칸의 목록(expect(opener.opened, c.opened) — 🔴 opener.opened[0] 류 원소 비교 금지) · 명령·초안 기록도 목록 == 목록(expect(store.cleared, c.cleared) · expect(cmd.watched, c.watched)) ·
   🔴 흐름(탭·링크 단언)은 경우 칸의 클로저(steps)에 · bool 칸 + if 로 흐름을 가르는 꼴 · c.name == · which == 이름 비교 · if 를 단언 안으로 감추는 꼴(expect(a.isEmpty || …, isTrue)) = 반려(정적 C34) ·
   경우마다 갈리는 단언은 «없는 쪽» 견본(if/else 양쪽 단언) 또는 expect(finder, c.<Matcher 칸>) / expect(finder, <불 값> ? findsOneWidget : findsNothing) 한 꼴 · 테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII ·
   «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2 · for (… in <T>[?x]) · ?.let 류로 감추는 것도 반려) · 단언은 «X 0 · Y 0» 처럼 따로(괄호 단언 금지) ·
   스켈레톤 1 = expect(find.byKey(const Key('a2-loading')), findsOneWidget) 꼴 · 테스트는 package:ui_journal/src/common/journal_common.dart 를 직접 import 해도 된다(JournalEntryCard · JournalReasonChip) · operator 화면 = import 'package:ui_journal/journal_draft.dart'; ·
   Key 를 단 묶음의 글자 = adviceShownTexts(tester, <Finder>)(R5b advice_fakes.dart) == 기대 목록(트리 순서) · 겹쳐 나오는 글자 = find.text(<글자>) findsNWidgets(<수 리터럴>) ·
   값을 끝까지 내지 않는 것 = Completer<T>().future(같은 테스트에서 complete 하지 않으면 «첫 값 전») · 폼의 Future 에러·스트림 에러 테스트는 끝에 expect(tester.takeException(), isNotNull);(폼은 _report 로 보고한다 — J-3 꼴 · A-2 는 보고 0).
   ⓡ = 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 한 줄 — 🔴 n = 정수 리터럴(체결 1 · 사유 6) ·
      끝 Key 도 리터럴(a2-fill-1 · a4-reason-6) · 도우미로 감싸지 않는다 · 🔴 hasLength( 는 ⓗ 줄에만(전제에는 .length 비교 · isEmpty · isNotEmpty) ·
      정적 C20·C21 이 파일마다 git grep -c 로 센다 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(advice_detail_test.dart ⓡ 8 · ⓗ 1 · advice_skip_form_test.dart ⓡ 8 · ⓗ 1 · 다르면 제출 전에 고친다 · 다른 채 내면 반려).
   «없는 쪽» 견본(코드 글자 · 이름은 재량 · A2-06 · A4-08):
        final String? want = c.close;                      // 경우 칸 = 기대 글자 String?(revoked = revoked.closeReasonLabel · partial = null)
        if (want != null) {
          expect(tester.widget<Text>(find.byKey(const Key('a2-close-reason'))).data, want);
        } else {
          expect(find.byKey(const Key('a2-close-reason')), findsNothing);
        }
        🔴 반려 꼴: if (want != null) { expect(…); }(else 없음) · if (want != null) { await tester.tap(…); … }(흐름이 if 안) · if (x != null) { expect(x, isNotNull); … } ·
           if (c.name == 'executed') {…} · expect(store.cleared[0], …) · expect(opener.opened[0], …) · expect(data.isEmpty || allowed.contains(data), isTrue)
   «접수증 갈래» 견본(경우 칸 = Matcher·목록 · A4-04):
        await c.steps(tester);                             // 흐름 = 클로저 칸(사유 1 탭 · pump)
        expect(tester.widget<Text>(find.byKey(const Key('a4-receipt'))).data, c.watch.stateLabel);
        expect(tester.widget<OutlinedButton>(find.byKey(const ValueKey<String>('a4-reason-1'))).onPressed, c.enabled);   // Matcher 칸 = isNull / isNotNull
        expect(store.cleared, c.cleared);                  // 목록 칸 = <DraftKey>[] 또는 <DraftKey>[drafts.rows[1].key]
        expect(opener.opened, c.opened);                   // 목록 칸 = <String>[] 또는 <String>[AppNavActions.back]
   «화면의 Text 전부» 단언 = 이 코드 글자 꼴(A2-04 뷰어 · A2-09 · A4-10 · C4d-1 · C4r4a-2):
          final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
          expect(shown, isNotEmpty);
          for (final String? data in shown) {
            expect(data, isIn(allowed));
          }
        (allowed = advice_detail_fakes.dart 의 adviceDetailAllowed · advice_skip_fakes.dart 의 adviceSkipAllowed — null-aware 원소로 만든 Set<String> · 🔴 링크·경로 문자열(deepLink · aaq:// · handbook://) 0 ·
         RichText · SelectableText · Text.rich 는 두 화면 파일에 쓰지 않는다 = 정적 C25)
11 골든 = 새 PNG a2_* 6장 + a4_* 4장 · --update-goldens 는 그 두 골든 테스트 파일만 · 기존 PNG(⟦실측⟧ 126장) 재생성 0 · golden:approved 안 붙임 · 찍기 전 위치 전제 둘 · 🔴 높이(_kTallPhone)는 늘리지 않는다(카드 확정값).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 ·
   패키지 테스트는 packages/ui_journal 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · prefer_final_locals · unnecessary_lambdas · use_build_context_synchronously(await 뒤 setState 는 mounted 검사 뒤).
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 카드에는 산술이 없다 — 지역 변수 band 옆에 연산자 0 · 글자 잇기 0).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — 두 화면 파일의 주석에 이 낱말을 쓰지 않는다(위 규칙 3 끝 🔴 의 C-46 낱말 전부 +): DateTime · DateRange · kIsWeb · Platform. · dart:io · HoldingPnl · FeatureFlags · RunMode · watchInbox · watchSummary ·
   watchHistory · deferAdviceConfirm · fillChain · requiresNote · rejectReasonCode · retryCode · retryLabel · .kind · .effectiveStatus · .length · NumberFormat · toString( · Navigator · ScaffoldMessenger · SnackBar · Scaffold · AppBar · SafeArea · RichText · SelectableText ·
   maxLines · TextOverflow · .trim( · .take( · autoDispose · Colors · 'aaq:// · TextField · 추천 · 권유 · 자문 · 시그널(주석은 짧게 · 🔵 S05·C06·C07·C36 은 줄 수를 정확히 세므로 그 이름이 주석에 나오면 수가 늘어난다 — journalLinkOpenerProvider · AppNavActions · findById ·
   fillsOfAdvice · watchManualFillFormSpec · skipAdvice · watchCommand · .clear( 를 주석에 쓰지 않는다).
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려**.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다).
   PNG 는 이름마다 light 한 장만 연다(5장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지 · 버튼 = «버튼 글자») · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 줄 n» = PNG 의 글자 **행** 수 · «상자» = 테두리·모서리가 보이는 덩어리 · «배경 덩어리» = 폭 전체 배경 · «칩 n개» = 한 무리의 칩 개수 · «막대» = 가로로 긴 덩어리 · «점» = 작은 둥근 표식 ·
   «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다 · 🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다.
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 채팅으로만) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · S05 출력 줄 수만큼) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M6.md 252~274행 23항) 그대로 + [x] 와 괄호만([—] 금지 · 🔴 23항을 코드 블록으로 감싸지 않는다) · ③ = 위젯·Key 이름 나열(요약어 금지) ·
   질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외) · ⑤ 추측이 없으면 정확히 «없음» 한 낱말.

■ 프롬프트보다 이 카드가 이긴다 — 24항 (prompt_M6.md 275줄 판 v2 · 2026-10-26 재조립)
 ① 2행 {{범위}} · 121행 «이번 과제 범위: R5a~R5e 중 …» → 이 카드의 범위 = A-2 · A-4(위 첫 줄)
 ② 113~119행 역할·범위(M6 15화면 나열) → 이 카드 = A-2 + A-4 · L-1·L-2 = R5a · A-1·「지난 안내」 = R5b(병합됨) · A-3 = R5d · L-3 = R5e(12 §6 7d·7e)
 ③ 12~13행 «의존 셋뿐» → 추가 0 · pubspec 무변경
 ④ 15~19행 «링크는 데이터 · null = 부재» → 그대로 유효 · 상수 = AppNavActions.back 하나(A-4 의 executed pop · 01 §21-8 A-3 행 준용 — 발주자 확인 ⑨) · AppRoutes 0
 ⑤ 20~23행 DateTime.now 금지 · 신선도 = 주입 Clock + asOf → 그대로 유효(A-2 = item.asOf · A-4 = spec.asOf)
 ⑥ 29~31행 «건수 집계·거르기·묶기·재정렬 금지» → 그대로 유효 · 예외 = 규칙 5 의 넷(신선도 · 빈 목록 · deepLink null 여부 · 잠금 switch)
 ⑦ 32~38행 «한국어 리터럴 = labels.dart 한 파일» → 그대로 유효(JournalLabels R5c 절 2개 · 사유 글자 = option.label · 문구 = skipNoticeText · 접수증 = stateLabel)
 ⑧ 41~47행 안전 화면 금지 · 목적지 이름 정본 → 그대로 유효 — 예산 코드 = option.deepLink(M5-6 진입 · 데이터) · M5 화면 렌더 0
 ⑨ 48~66행 «■ 모드 — 축은 화면이 모른다 · actions 순서대로 · 프리필·비교 금지 · viewer 는 온 것을 그린다» → 그대로 유효(A-2 viewer = actions 빈 목록 · 체결 빈 목록 · phoneOnlyLabel)
 ⑩ 68~74행 수치·금액 리터럴 금지 → 그대로 유효(정적 C18 · C19)
 ⑪ 87~93행 «melos run test · check_boundaries · precheck(인자는 카드)» → 패키지 테스트 = packages/ui_journal 에서 flutter test 직접(🔴 백그라운드·파이프 금지) · 사전검사 인자 = «■ 제출»(② 는 두 번)
 ⑫ 94~99행 «PR 만들지 않음 · 5섹션 채팅 · 섹션 머리·복사 상자 = 카드 글자» → 그대로 유효 · 글자 = «■ 제출»(② 머리의 «12항» 그대로 — 사전검사 R1)
 ⑬ 100~105행 골든 두 갈래 → *.golden.json 0 · 새 PNG 10 = 최초 베이스라인(두 골든 파일만 --update-goldens) · 기존 PNG 재생성 0
 ⑭ 106~111행 «모르는 것 = 질문 파일» → 그대로 유효(inbox/A2A4_questions.md — 이미 있다)
 ⑮ 122~128행 읽을 문서 5 → 아래 «먼저 읽을 것»(02 는 §3-A · §3-7 · §3-9 · §3-10 끝 v1.12 블록 ⓐⓑⓕⓗⓙⓚ 만)
 ⑯ 130행 브랜치·PR 제목 형식 → 브랜치 ui/m6-a2a4 · 제목 «[M6] A-2 안내 상세·A-4 미이행 사유»
 ⑰ 131~134행 라이브러리 둘 → A-2 = 배럴 쪽 · A-4 = operator(lib/src/journal_draft/ + lib/journal_draft.dart export) · 방향 = operator → 배럴 쪽만(advice_skip_form.dart 가 ../advice_inbox.dart 를 import · 배럴은 operator 파일 0)
 ⑱ 135~137행 플랫폼 → A-2 = Android·iOS 본문(뷰어 = 엔진이 줄인 값) · A-4 = 폰 전용(iOS «폰에서만» = 셸 가드 · R13a) · 웹 = ui_journal 부재 · 화면 코드 0
 ⑲ 143~145행 «무한 스크롤 = limit += 100 재구독» → 해당 없음(이 카드의 목록 = fillsOfAdvice Future · skipReasons — ListResult 0)
 ⑳ 146~150행 «차단 표기 = 공용 배너 · X7 화면 .watchState(·activeFlags·FlagIds 0(C-46 ㉑)» → 그대로 유효
 ㉑ 183~187행 «A-2» → 그대로 유효 + 카드가 정한 것 — «부재» 글자(발주자 확인 ①) · 체결 행 = JournalEntryCard(②) · 체결 블록 갈래(③) · 배치 순서(④)
 ㉒ 189~199행 «쓰기 화면 공통» → 그대로 유효(A-4 몫) · 206~209행 «A-4» → 그대로 유효 + 참조 카드(⑤) · 신선도 초과(⑥) · blockedText(⑦) · 복원(⑧) · pop(⑨) · 잠금(⑩) · 200~205행 A-3 · 210~217행 L-3 · 218~230행 X5 = 이 카드 범위 밖
 ㉓ 231~250행 타입 지위 표 → A-2 행(findById · fillsOfAdvice) · A-4 행만 · 249행 «부르지 않는 것» = 아래 «호출 표»
 ㉔ 251~274행 자체 점검 23항 → «■ 제출» ② 복사 상자(3 · 4 · 13 · 16 = [x] + 괄호 «이 카드 범위 밖(…)»)

■ 먼저 읽을 것 (🔴 03·04·05 명세는 읽지 않음 · 02 는 아래 ③ 의 자리만)
 ① prompt_M6.md 전문(판 v2) ② 01 §21 — 21-3 · 21-6 의 A-2·A-4 행 · 21-7 · 21-8(위젯·파일·주입·호출 표) · 21-10-4 의 A-2·A-4 행 · 21-12-1(C-46 ⑰~㉖) · 21-16-1 · 01 §12-1(초안 키·본문) · §12-4(접수증 잠금 표)
 ③ 02 §3-A «X7 다섯 화면 공통 전제» · §3-7 «A-2 안내 상세» · §3-9 «A-4 미이행 사유» · §3-10 끝 «계약 v1.12 — R5 범위(X7 …) · 이 블록이 이긴다» ⓐⓑⓕⓗⓙⓚ
 ④ packages/domain_contracts/lib/ — src/dto/advice.dart(AdviceItem · ManualFillFormSpec · ReasonOption) · src/dto/journal.dart(TradeJournalEntry — 이름만) · src/commands/payloads_x7.dart(AdviceSkipSubmission) · src/commands/drafts.dart(DraftKey · DraftRecord · AdviceSkipInput.fromReasonCode) ·
    src/commands/command_receipt.dart · src/enums/command.dart(CommandState 9값) · src/repositories/advice_repository.dart · src/commands/command_api.dart(skipAdvice · watchCommand) · src/navigation/app_links.dart(AppNavActions.back) ·
    testing.dart(UnimplementedAdviceRepository · UnimplementedCommandApi · RecordingDraftStore · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c46_advice_x7_test.dart 머리 주석 + «B. 정규식» 절(⑰~㉖ — 읽기만 · 특히 ㉓ .clear( 갈래 · ⑰ 읽기 목록과 폼 목록의 차이)
 ⑥ 지금 코드(packages/ui_journal) — lib/ui_journal.dart · lib/journal_draft.dart · lib/l10n/labels.dart · lib/src/common/journal_common.dart 전문 · lib/src/journal_draft/journal_draft_form.dart 전문(🔴 접수증·초안 꼴의 원형 — 고치지 않는다) ·
    lib/src/advice/advice_card.dart · lib/src/advice_inbox.dart 머리 30줄(R5b — 고치지 않는다) · lib/src/holding_detail.dart(상태 3갈래 · JournalEntryCard 선례) · lib/src/timeline.dart 머리 40줄 + journalSafetyStateProvider ·
    test/advice_fakes.dart(R5b — import 만) · test/holdings_overview_fakes.dart · test/golden/h63_golden_test.dart · test/golden/golden_support.dart
 ⑦ packages/ui_journal/test/golden/README.md «R2b» 절(초안 시드 법) · «🆕 R5» 절 ⑧ packages/domain_contracts/fixtures/README.md(m6/advice_detail_* · fill_form_spec* · advice_skip_* · draft_records_x7 행) ⑨ docs/ai-context/inbox/README.md · A2A4_questions.md 머리말

■ 본받지 않는 것
 · R4·R5a·R5b 카드와 같다 — 배너 관용구 · .take(3)+«+n»(🔵 JournalEntryCard 안의 것은 공용 조각이라 그대로 쓴다 — 이 카드 파일에 새로 쓰지 않는다) · lib nullable 에 ! · 읽기 화면(A-2)의 FlutterError.reportError · implements 가짜 · 한국어 테스트 이름 · 조건부 단언
 · journal_draft_form.dart(J-3)의 화면 검증(.trim().length · rationaleMinChars · requiresNote 검사 — X7 = 검증 0 · K4) · activeFlags·FlagIds 로 배너 짓기(J-3 의 옛 꼴 — X7 = JournalSafetyBanners) · .where(…).firstOrNull · _receipt! · _commandId! 꼴(lib ! 0)
   🔵 본받는 것 = J-3 의 _report(FlutterError.reportError · 입력값 싣지 않음) · _port(Future.sync 감싸기) · _restore · _applyReceipt(clear 한 곳 · _draftCleared) · _subscribe(onError·onDone = 재구독) · 순서 «연결 저장 → 반영 → 구독» — 폼은 J-3 꼴 그대로(01 §12-1-6 ③)
 · test/journal_draft_test.dart 의 공장 안 if … return · _receiptIn(CommandState) 처럼 접수증을 지어 내는 꼴(X7 = 픽스처 접수증) · test/golden/j3_golden_test.dart 의 collection-if(옛 꼴)
 · R13b 1회차 반려 꼴(C4h-2~4) — 탭·링크 단언이 if 안 · bool 칸 + if · opened[0] · name ==·which == · if 를 단언 안 || 로 감춤

■ 주입 구조 (이름·타입·파일 고정 = 01 §21-8 글자 그대로 · 계약 변경 없음 · 🔴 새 주입 0)
· 재사용: advice_inbox.dart 의 journalAdviceRepositoryProvider(R5b) / journal_draft_form.dart 의 journalCommandApiProvider · journalDraftStoreProvider(J-3 · A-4 만) /
  timeline.dart 의 journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider · journalSafetyRepositoryProvider(테스트 override 용) /
  journal_common.dart: JournalAsOfHeader · JournalStaleBanner · JournalSafetyBanners · JournalReasonChip · JournalEntryCard · JournalSkeleton · JournalErrorView(🔴 무수정) / advice/advice_card.dart: AdviceCard(R5b · 무수정) /
  labels.dart: retry · staleBannerTitle · submitNotAccepted(기존 · 고치지 않는다).
· 🆕 lib 파일 2개 — lib/src/advice_detail.dart(A-2 · 배럴 쪽) · lib/src/journal_draft/advice_skip_form.dart(A-4 · operator)(이것 말고 새 lib 파일 0 · 그 밖 조각은 각 파일 안 private).
  import(directives_ordering · 쓰지 않는 import = analyze 실패 · 차례 = 드라이런 analyze 로 확정 ⟦실측⟧):
     advice_detail.dart            = package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart → ../l10n/labels.dart → advice/advice_card.dart → advice_inbox.dart → common/journal_common.dart → timeline.dart
     journal_draft/advice_skip_form.dart = dart:async → package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart → ../../l10n/labels.dart → ../advice_inbox.dart → ../common/journal_common.dart → ../timeline.dart → journal_draft_form.dart
  데이터 4(autoDispose 0 · 각 파일 import 바로 뒤):
    final _adviceDetailProvider = FutureProvider.family<AdviceItem?, String>((Ref ref, String id) => ref.watch(journalAdviceRepositoryProvider).findById(id));                    ← advice_detail.dart
    final _adviceFillsProvider = FutureProvider.family<List<TradeJournalEntry>, String>((Ref ref, String id) => ref.watch(journalAdviceRepositoryProvider).fillsOfAdvice(id));    ← advice_detail.dart
    final _adviceSkipItemProvider = FutureProvider.family<AdviceItem?, String>((Ref ref, String id) => ref.watch(journalAdviceRepositoryProvider).findById(id));                  ← advice_skip_form.dart
    final _adviceSkipSpecProvider = StreamProvider<ManualFillFormSpec>((Ref ref) => ref.watch(journalAdviceRepositoryProvider).watchManualFillFormSpec());                       ← advice_skip_form.dart
· 🆕 배럴 lib/ui_journal.dart 에 export 'src/advice_detail.dart'; 한 줄(자리 = export 'src/advice/advice_card.dart'; 와 export 'src/advice_history.dart'; 사이 · 삭제 0)
· 🆕 operator 배럴 lib/journal_draft.dart 에 export 'src/journal_draft/advice_skip_form.dart'; 한 줄(자리 = 기존 export 줄 앞 · 삭제 0)
· 조립 앱(이 카드 밖 · 참고만): 라우트 adviceDetail → AdviceDetail(adviceId: …) · adviceSkip → AdviceSkipForm(adviceId: …)(operator 앱만) · overrides 추가 0.

■ 호출 표 (부르는 것 · 부르지 않는 것 — 01 §21-8 글자)
 A-2 — 부르는 것: findById(adviceId)(한 번 · 재시도 = invalidate) · fillsOfAdvice(adviceId)(🔵 findById 가 안내 한 건을 준 뒤에만 · 한 번 · 재시도 = invalidate) · journalSafetyStateProvider(배너) · journalClockProvider · opener.open(decisionLink.deepLink)(+ AdviceCard 버튼 · 칩 · 체결 행이 안에서 연다).
       부르지 않는 것: watchDecisionDetail · fillChain · watchInbox · watchManualFillFormSpec · 명령 전부(skipAdvice · recordManualFill · deferAdviceConfirm · watchCommand) · DraftStore · JournalRepository · .watchState(.
 A-4 — 부르는 것: DraftStore.load(key)(initState 한 번) · findById(adviceId) · watchManualFillFormSpec()(한 번) · skipAdvice(AdviceSkipSubmission)(비예산 사유 탭마다) · DraftStore.save(제출 Future 성공 뒤 한 번 · lastCommandId) ·
       watchCommand(id)(제출 뒤 · 복원 id · 재구독) · DraftStore.clear(key)(executed 한 곳) · opener.open(option.deepLink)(예산 코드 탭) · opener.open(AppNavActions.back)(이 화면이 낸 명령의 executed).
       부르지 않는 것: recordManualFill · deferAdviceConfirm · fillsOfAdvice · 와이어·CommandContext · 예산 코드 탭의 save·clear · 탭 전 save · .watchState(.

■ 상태 표 (구독마다 — C4r3-1 · 01 §21-7 A-2 행 · A-4 행 · §12-4)
 A-2 item      첫 값 전 → JournalSkeleton(key: const Key('a2-loading')) · 에러 → JournalErrorView(key: const Key('a2-fail'), onRetry: () => ref.invalidate(_adviceDetailProvider(adviceId))) ·
               값 null → Padding(padding: EdgeInsets.all(16), child: Text(JournalLabels.adviceNotFound, key: const Key('a2-absent')))(🔵 머리·배너·체결 0 · fillsOfAdvice 부르지 않음) · 값 → 본문
 A-2 fills     첫 값 전 → 블록 부재 · 에러 → JournalErrorView(key: const Key('a2-fills-fail'), onRetry: () => ref.invalidate(_adviceFillsProvider(adviceId)))(그 블록만 · 본문 나머지 그대로) · 빈 목록 → 블록 부재(머리 «기록된 체결» 도 0) · 값 → 머리 1줄 + 행
 A-4 draft     initState 의 load 가 끝나기 전 → a4-loading(입력 잠금 = 화면 전체 · J-3 꼴) · load 에러 → _report 뒤 빈 초안으로 진행(J-3 꼴)
 A-4 item      첫 값 전 → a4-loading · 에러 → a4-fail(onRetry: invalidate(_adviceSkipItemProvider(widget.adviceId))) · 값 null → Text(JournalLabels.adviceNotFound, key: const Key('a4-absent'))(폼 부재) · 값 → 다음 줄
 A-4 spec      첫 값 전 → a4-loading · 에러 → a4-fail(onRetry: invalidate(_adviceSkipSpecProvider) · lastAsOfLabel = 마지막 값의 asOf.label) · 값 + 신선도 초과 → 머리 + JournalStaleBanner + 배너만(폼 열지 않음 — 발주자 확인 ⑥) · 값 → 본문
 A-4 receipt   J-3 꼴 — lastCommandId 복원 non-null = 첫 접수증 전 잠금 + 구독 · 구독 에러·첫 값 없이 끝남 = 재구독 버튼(a4-resubscribe · JournalLabels.retry) · 제출 Future 에러 = a4-submit-not-accepted(submitNotAccepted) ·
               접수증 = a4-receipt(stateLabel) · requested·received·staleContext·heldForIntegrity·pendingLeaseConfirm·noOperator = 잠금 · rejected·expired = 잠금 풀림(입력 0 이라 보존할 것 0 · 다시 탭 = 다시 제출) ·
               executed = clear 한 곳 → 이 화면이 낸 명령이면 pop(AppNavActions.back) · 복원 id 면 빈 폼(접수증 줄 0 · 잠금 풀림 · K11)
 safety        두 화면 공통 — 첫 값 전·에러 → 배너 부재 · 값 → JournalSafetyBanners(본문 영향 0)
 🔴 a4-loading · a4-fail 은 파일 안 한 곳에서만 짓는다(a4-loading = private const 위젯 하나 · a4-fail = private 함수 하나 — Key 글자가 파일에 한 번 · 정적 C22 = 이름마다 1줄).
 🔴 갈래를 고르는 것은 AsyncValue · null 여부 · isEmpty · deepLink null 여부 · 잠금 switch · State bool 뿐 — 글자 비교·사유 코드·상태 코드·플래그·플랫폼으로 고르지 않는다.

■ 화면 1 — A-2 AdviceDetail (lib/src/advice_detail.dart · ConsumerWidget · 02 §3-7 · 01 §21-6·§21-7 A-2 행 · K18 · K39 · K40)
 배치(item 값 갈래 · 위 → 아래 · 🔴 이 순서 · 발주자 확인 ④):
   ListView(padding: EdgeInsets.zero)[
    1 JournalAsOfHeader(key: const Key('a2-asof'), asOf: item.asOf)
    2 (오래됐으면 — 규칙 5 ⓐ · item.asOf) JournalStaleBanner(asOf: item.asOf)
    3 JournalSafetyBanners(safety: safety)
    4 AdviceCard(key: const Key('a2-card'), item: item)                                ← R5b 조각 그대로(버튼 = actions · 칩 · 보류·억제 몸 · 뷰어 = phoneOnlyLabel) · 🔴 InkWell 로 감싸지 않는다
    5 (close != null) Padding(padding: EdgeInsets.fromLTRB(16, 4, 16, 4), child: Text(close, key: const Key('a2-close-reason')))     ← final String? close = item.closeReasonLabel;
    6 Padding(key: const Key('a2-deviation'), padding: EdgeInsets.fromLTRB(12, 4, 12, 4), child: Wrap(spacing: 6, runSpacing: 4, children: [ for (final ReasonChip c in item.recordedDeviationChips) JournalReasonChip(chip: c) ]))   ← 비어도 그대로
    7 (decision != null) Padding(padding: EdgeInsets.fromLTRB(16, 4, 16, 4), child: Align(alignment: Alignment.centerLeft, child: TextButton(key: const Key('a2-decision'),
        onPressed: () { ref.read(journalLinkOpenerProvider).open(decision.deepLink); }, child: Text(decision.label))))   ← final LinkAction? decision = item.decisionLink;(✅ K18 — 스냅샷 = 이 링크 1개)
    8 ..._fillsBlock(ref, fills)                                                       ← final AsyncValue<List<TradeJournalEntry>> fills = ref.watch(_adviceFillsProvider(adviceId));(🔵 이 갈래 안에서만 watch)
   ]
 _fillsBlock(WidgetRef ref, AsyncValue<List<TradeJournalEntry>> fills) → List<Widget> — private 메서드(발주자 확인 ③):
     fills.when(loading: () => <Widget>[], error: (Object e, StackTrace s) => <Widget>[JournalErrorView(key: const Key('a2-fills-fail'), onRetry: () => ref.invalidate(_adviceFillsProvider(adviceId)))],
       data: (List<TradeJournalEntry> rows) => rows.isEmpty ? <Widget>[] : <Widget>[
         Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(JournalLabels.adviceRecordedFills, key: const Key('a2-fills-title'))),
         for (final (int i, TradeJournalEntry e) in rows.indexed) JournalEntryCard(key: ValueKey<String>('a2-fill-$i'), entry: e) ])   ← 받은 순서 · 행 탭 = 조각 안 detailDeepLink(→ J-2)
 코드 스케치: build — final Clock clock = ref.watch(journalClockProvider); final SafetyState? safety = ref.watch(journalSafetyStateProvider).valueOrNull; final AsyncValue<AdviceItem?> detail = ref.watch(_adviceDetailProvider(adviceId));
   return detail.when(loading: () => const JournalSkeleton(key: Key('a2-loading')), error: (Object e, StackTrace s) => <상태 표 에러>, data: (AdviceItem? v) => <null 이면 a2-absent · 아니면 _buildBody(context, ref, v, clock, safety)>);
   🔴 «기록된 체결» 행의 「정정」·접기·묶기 0(01 §8 미결 115) · 화면이 만든 편차 칩 0 · 안내 수량 편집 0 · 「내일 다시」 0(A-1 인박스 몫).

■ 화면 2 — A-4 AdviceSkipForm (lib/src/journal_draft/advice_skip_form.dart · operator · ConsumerStatefulWidget · 02 §3-9 · 01 §21-6·§21-7 A-4 행 · K12 · K21 · K37)
 State 필드(🔴 이 이름·타입 · 입력 칸 0): late final DraftKey _draftKey = DraftKey(kind: DraftKind.adviceSkip, targetId: widget.adviceId); · CommandReceipt? _receipt; · StreamSubscription<CommandReceipt>? _cmdSub; ·
   String? _commandId; · bool _restoreDone = false; · bool _awaitingReceipt = false; · bool _resubscribeFailed = false; · bool _submitting = false; · bool _submitNotAccepted = false; · bool _draftCleared = false; · bool _issuedHere = false;
 initState = super.initState(); unawaited(_restore()); · dispose = _cmdSub?.cancel(); super.dispose();(🔴 dispose 안 ref. 0)
 J-3 에서 그대로 옮기는 것(이름 같게 · 본문은 이 화면 몫으로): _report · _port · _subscribe · _resubscribe(🔴 J-3 의 _subscribe(_commandId!) 는 옮기지 않는다 — final String? id = _commandId; if (id != null) { setState(() { _resubscribeFailed = false; }); _subscribe(id); } · lib ! 0) — 🔵 _restore 는 lastCommandId 만(발주자 확인 ⑧):
     Future<void> _restore() async {
       DraftRecord? r;
       try { r = await ref.read(journalDraftStoreProvider).load(_draftKey); } catch (e, st) { _report(e, st); }
       if (!mounted) return;
       final String? id = r?.lastCommandId;
       setState(() { _commandId = id; _awaitingReceipt = id != null; _restoreDone = true; });
       if (id != null) { _subscribe(id); }
     }
 _onReason(ReasonOption option) — 탭 핸들러(🔴 이 꼴 · 예산 = deepLink 의 null 여부 하나 · 코드 비교 0):
     final String? link = option.deepLink;
     if (link != null) {
       ref.read(journalLinkOpenerProvider).open(link);          // 예산 코드 2종 — 명령 0 · 초안 0(K12)
     } else {
       unawaited(_submit(option.code));
     }
 _submit(String code) — J-3 _submit 의 순서 그대로(🔴 «연결 저장 → 반영 → 구독»):
     setState(() { _submitting = true; _submitNotAccepted = false; });
     final CommandReceipt initial;
     try {
       initial = await ref.read(journalCommandApiProvider).skipAdvice(AdviceSkipSubmission(adviceId: widget.adviceId, input: AdviceSkipInput.fromReasonCode(code)));
     } catch (e, st) { _report(e, st); if (mounted) { setState(() { _submitting = false; _submitNotAccepted = true; }); } return; }
     if (!mounted) return;
     setState(() { _submitting = false; _commandId = initial.commandId; _issuedHere = true; });
     _port((DraftStore s) => s.save(DraftRecord(key: _draftKey, adviceSkip: AdviceSkipInput.fromReasonCode(code), lastCommandId: initial.commandId)));   ← 탭 전 save 0 · 이 한 번(K12)
     _applyReceipt(initial);
     _subscribe(initial.commandId);
 _applyReceipt(CommandReceipt r) — 🔴 clear 는 이 한 곳(C-46 ㉓ · 이 꼴 그대로):
     if (!mounted) return;
     setState(() { _receipt = r; _awaitingReceipt = false; _resubscribeFailed = false; });
     if (r.state == CommandState.executed && !_draftCleared) {
       _draftCleared = true;
       _port((DraftStore s) => s.clear(_draftKey));
       _afterExecuted();
     }
 _afterExecuted() — 이 꼴(발주자 확인 ⑧⑨):
     if (_issuedHere) {
       ref.read(journalLinkOpenerProvider).open(AppNavActions.back);   // 이 화면이 낸 명령 — pop
     } else {
       unawaited(_cmdSub?.cancel() ?? Future<void>.value());
       setState(() { _receipt = null; _commandId = null; _draftCleared = false; });   // 복원 id — 빈 폼(K11 · pop 0)
     }
 _locked() — 🔴 CommandState 전수 switch 하나(C-12 · 발주자 확인 ⑩):
     bool _locked() {
       if (!_restoreDone || _awaitingReceipt || _submitting) return true;
       final CommandReceipt? r = _receipt;
       if (r == null) return false;
       return switch (r.state) {
         CommandState.requested || CommandState.received || CommandState.staleContext || CommandState.heldForIntegrity || CommandState.pendingLeaseConfirm || CommandState.noOperator || CommandState.executed => true,
         CommandState.rejected || CommandState.expired => false,
       };
     }
 배치(spec 값 · 신선도 안 · 위 → 아래 · 🔴 이 순서):
   ListView(padding: EdgeInsets.zero)[
    1 JournalAsOfHeader(key: const Key('a4-asof'), asOf: spec.asOf)
    2 (오래됐으면 — 규칙 5 ⓐ · spec.asOf) JournalStaleBanner(asOf: spec.asOf) — 🔴 오래됐으면 3 다음에서 끝(4~10 0 · 발주자 확인 ⑥)
    3 JournalSafetyBanners(safety: safety)
    4 (banner != null) Padding(padding: EdgeInsets.fromLTRB(16, 4, 16, 4), child: Text(banner, key: const Key('a4-banner')))     ← final String? banner = spec.bannerText;
    5 _SkipReferenceCard(key: const Key('a4-ref'), item: item)                         ← 아래 · 버튼 0
    6 Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(spec.skipNoticeText, key: const Key('a4-notice')))   ← 제출 전 1줄(K37)
    7 (blocked == null) for (final (int i, ReasonOption o) in spec.skipReasons.indexed) Padding(padding: EdgeInsets.fromLTRB(16, 4, 16, 4), child: SizedBox(width: double.infinity, child: OutlinedButton(
        key: ValueKey<String>('a4-reason-$i'), onPressed: locked ? null : () { _onReason(o); }, child: Text(o.label))))   ← 받은 순서 · 전부 같은 꼴 · final bool locked = _locked();
      (blocked != null) Padding(padding: EdgeInsets.all(16), child: Text(blocked, key: const Key('a4-blocked')))   ← final String? blocked = spec.blockedText;(사유 버튼 전부 부재 — 발주자 확인 ⑦)
    8 (receipt != null) Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(receipt.stateLabel, key: const Key('a4-receipt')))    ← final CommandReceipt? receipt = _receipt;
    9 (_submitNotAccepted) Padding(… Text(JournalLabels.submitNotAccepted, key: const Key('a4-submit-not-accepted'), style: TextStyle(color: Theme.of(context).colorScheme.error)))
   10 (_resubscribeFailed) Padding(… TextButton(key: const Key('a4-resubscribe'), onPressed: _resubscribe, child: const Text(JournalLabels.retry)))
   ]
 _SkipReferenceCard(item:) — private StatelessWidget · Card(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4)) > Padding(EdgeInsets.all(16)) > Column(crossAxisAlignment: start)[   ← 🔴 Text 순서 = 도우미 adviceFormRefTexts
     (symbol != null) Text(symbol) · (side != null) Text(side) · Text(item.sizingLabel) · (band != null) Text(band.label) · Text(item.validityLabel) · Text(item.progressLabel) ]
   ← final String? symbol = item.symbolLabel; final String? side = item.sideLabel; final AdvicePriceBand? band = item.priceBand;(발주자 확인 ⑤ · R5d A-3 참조 카드와 같은 글자 6)
 코드 스케치: build — if (!_restoreDone) return _skipLoading;  final AsyncValue<AdviceItem?> item = ref.watch(_adviceSkipItemProvider(widget.adviceId)); final AsyncValue<ManualFillFormSpec> spec = ref.watch(_adviceSkipSpecProvider);
   item.when(loading → _skipLoading · error → _skipFail(…) · data null → a4-absent · data v → spec.when(loading → _skipLoading · error → _skipFail(… lastAsOf: spec.valueOrNull?.asOf.label) · data s → _buildBody(context, v, s, clock, safety)))
   _skipLoading = const JournalSkeleton(key: Key('a4-loading'))(파일 안 private const 하나) · _skipFail(VoidCallback onRetry, String? lastAsOf) => JournalErrorView(key: const Key('a4-fail'), lastAsOfLabel: lastAsOf, onRetry: onRetry)(private 함수 하나).
 🔴 TextField · note · Checkbox · 「전부 건너뛰기」 0 · requiresNote 읽기 0 · 사유 코드 비교 0 · 예산 탭의 save·clear 0 · TextEditingController 0(.clear( 는 초안 한 곳).

■ 픽스처 (FixturePaths.… · listFixture / singleFixture / safetyFixtureRow · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 partial        singleFixture(FixturePaths.m6AdviceDetailPartial, AdviceItem.fromJson) — ad_0005 PARTIAL · actions [기록하기, 건너뛰기] · reasons 1(handbook 링크) · recordedDeviationChips 1 · decisionLink 있음 · closeReasonLabel null · asOf «안내 기준 …»
 fills          listFixture(FixturePaths.m6AdviceFillsAd0005, TradeJournalEntry.fromJson).rows — 1행 mf_0101(detailDeepLink 있음 · fillsOfAdvice 는 봉투 없는 목록 — rows 를 넘긴다)
 onhold         singleFixture(FixturePaths.m6AdviceDetailOnhold, AdviceItem.fromJson) — ad_0006b · holdReasonLabel 있음 · recordedDeviationChips 0 · 체결 = <TradeJournalEntry>[](K40 · 01 §21-10-4)
 viewer         listFixture(FixturePaths.m6AdviceViewer4, AdviceItem.fromJson).rows[2] — ad_0005 뷰어 판 · actions [] · phoneOnlyLabel 있음 · decisionLink 있음 · 체결 = []
 revoked        listFixture(FixturePaths.m6Advice12, AdviceItem.fromJson).rows[11] — ad_0012 REVOKED · closeReasonLabel 있음(A2-06 만)
 ad0001         listFixture(FixturePaths.m6Advice12, AdviceItem.fromJson).rows[3] — ad_0001 OPEN(A-4 참조 카드 · a4 골든)
 spec · blockedSpec · staleSpec   singleFixture(FixturePaths.m6FillFormSpec / m6FillFormSpecBlocked / m6FillFormSpecStale, ManualFillFormSpec.fromJson) — skipReasons 6([0] PRICE_UNACCEPTABLE·[2] INTENTIONAL_PAUSE = deepLink 있음 · 나머지 null) ·
                skipNoticeText 있음 · blocked = blockedText·bannerText 있음 · stale = asOf.observedAt 오래됨 + staleLabel 있음
 receipts       listFixture(FixturePaths.m6AdviceSkipReceipts5, CommandReceipt.fromJson) — [0] REQUESTED · [1] EXECUTED · [2] REJECTED(LEASE_EXPIRED) · [3] REJECTED(ADVICE_NOT_OPEN) · [4] HELD_FOR_INTEGRITY(같은 commandId)
 drafts         listFixture(FixturePaths.m6DraftRecordsX7, DraftRecord.fromJson) — [1] = SKIP_ADVICE / ad_0001 · lastCommandId null(🔵 복원 id 시드 = adviceSkipSeedWithCommand(drafts.rows[1], receipts.rows[0].commandId) · 기대 키 = drafts.rows[1].key)
 안전           safetyFixtureRow(0) 정상(플래그 0)
 🔴 쓰지 않는 것: m6/advice_skip_reasons(C-46 ⑥ 대조용 — 화면 입력 아님) · m6/fill_rejected_price · m6/manual_* · m6/self_report_* · advice_12 의 다른 행 · 형제 키 summary · 슬라이스·시드 밖 copyWith · «내 픽스처».

■ Key 표 (a2- 11이름 · a4- 12이름 — 정본 = 이 표 · 🔴 표 밖 Key 0 · id 0 — 순번만 · 같은 이름을 두 자리에 달면 반려 · 정적 C22 = 이름마다 1줄)
   이름                     다는 자리                                                   있을 때
   a2-loading               JournalSkeleton(A-2)                                         findById 첫 값 전
   a2-fail                  JournalErrorView(A-2)                                        findById 에러
   a2-absent                Text(adviceNotFound)                                         findById 값 null
   a2-asof                  JournalAsOfHeader                                            안내 값
   a2-card                  AdviceCard                                                   안내 값
   a2-close-reason          Text(closeReasonLabel)                                       non-null
   a2-deviation             기록 편차 칩 Wrap 의 Padding                                  안내 값(늘 · 칩 0 이어도)
   a2-decision              TextButton(결정 링크)                                        decisionLink non-null
   a2-fills-title           Text(adviceRecordedFills)                                    체결 값 ∧ 비지 않음
   a2-fill-$i               JournalEntryCard(ValueKey<String>)                           체결 행마다
   a2-fills-fail            JournalErrorView(체결 블록)                                  fillsOfAdvice 에러
   a4-loading · a4-fail · a4-absent · a4-asof · a4-banner(Text bannerText) · a4-ref(_SkipReferenceCard) · a4-notice(Text skipNoticeText) · a4-reason-$i(OutlinedButton · ValueKey<String>) ·
   a4-blocked(Text blockedText) · a4-receipt(Text stateLabel) · a4-submit-not-accepted · a4-resubscribe(TextButton) — 같은 자리 꼴(«상태 표»·«화면 2» 글자)
   (AdviceCard 안 · JournalEntryCard 안 · 칩 · 배너 · 참조 카드 안 Text 에는 Key 를 달지 않는다 — 테스트는 Key 의 descendant 로 찾는다)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 그 커밋 내용 · 🔴 커밋마다 git add <파일> 로 지정 — git add . 금지 · amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일)
 (1) 정적 라벨 2(labels.dart R5c 절). 커밋 «[M6] R5c (1) 정적 라벨 2»
 (2) lib/src/advice_detail.dart + 배럴 한 줄 + test/advice_detail_fakes.dart + test/advice_detail_test.dart(A2-01~A2-09).
     🔴 커밋 전에 git add <그 파일들> 뒤 «정적 묶음» 미리 돌리기(규칙 15 금지 낱말 포함). 커밋 «[M6] R5c (2) A-2 안내 상세 + 테스트»
 (3) lib/src/journal_draft/advice_skip_form.dart + operator 배럴 한 줄 + test/advice_skip_fakes.dart + test/advice_skip_form_test.dart(A4-01~A4-10). 🔴 같은 미리 돌리기. 커밋 «[M6] R5c (3) A-4 미이행 사유 + 테스트»
 (4) 골든 10장 — test/golden/a2_golden_test.dart(3이름 × 2) · test/golden/a4_golden_test.dart(2이름 × 2). 커밋 «[M6] R5c (4) 골든 a2_* 6장 · a4_* 4장»
 (5) melos.bat run format:fix · 질문 파일(A2A4_questions.md — dy 측정 행 A1~A5 · 그 밖의 질문). 커밋 «[M6] R5c (5) format · 질문».
     🔴 (5) 뒤 커밋 0 — 예외 = 사전검사 ① 🔴 수정 커밋 (6) **하나**(주석 고침 · 금지 낱말 고침도 (6) 하나에 · format:fix 먼저).

■ 정적 라벨 — JournalLabels 안 R5b 절의 마지막 상수(adviceHistoryLink · ⟦실측⟧) 뒤 · 닫는 } 앞에 절 주석(// ── 🆕 R5c — A-2 안내 상세 · A-4 미이행 사유 ──…)과 함께 2개(이름·글자 고정 · static const String · doc 주석 짧게):
   adviceNotFound = '이 안내를 찾을 수 없습니다' · adviceRecordedFills = '기록된 체결'
   🔴 만들지 않는 글자(엔진 몫): 안내 카드 글자 전부 · 회수 문장 · 편차 칩 · 결정 링크 글자 · 체결 행 글자 · 사유 글자 · 제출 전 문구 · 접수증 글자 · 차단 문장 · 폼 배너 · 신선도 문장 · «이행하지 않았습니다» · «기록하기» · «건너뛰기» · «정정».
   라벨 글자에 숫자·금액 0(C-32) · «추천·권유·자문·시그널» 0 · 기존 라벨은 그대로(R5b 병합본 39 · ⟦실측⟧ → 합 41 — 정적 C12 이 정확히 센다) · 🔵 adviceNotFound 는 R5d A-3 이 import 해 쓴다(이름·글자 고정).

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 는 정적 C20·C21 · (전제) 는 C33 과 대조)
공통: 띄우기 = pumpAdviceDetail(tester, overrides:, adviceId:) · pumpAdviceSkip(tester, overrides:, adviceId:)(Size(390, 3000) · DPR 1.0 · teardown 2 · ProviderScope(overrides) > MaterialApp > Scaffold(body: AdviceDetail(adviceId: id) / AdviceSkipForm(adviceId: id)) · pump 두 번 — 값 도착) ·
  overrides = adviceDetailOverrides(repo:, safety:, clock:, opener:)(4줄) · adviceSkipOverrides(repo:, cmd:, store:, safety:, clock:, opener:)(6줄) · 시계 = FixedClock(kGoldenNowUtc) · 오래됨 = adviceStaleClock()(R5b advice_fakes.dart · +2일) ·
  id = 픽스처 행의 adviceId(테스트 입력 준비 — 위젯 인자) · 경우가 여럿인 테스트 = for 로 testWidgets 를 경우마다(이름 '<번호> <설명> ${c.name}') · 경우 = 테스트 파일 안 private class _Case(칸은 테스트마다 재량 · bool 칸 0 · Matcher 칸 허용) ·
  탭 앞에 ensureVisible · 띄우기는 한 테스트에 한 번 · 계획 = advice_detail_test testWidgets 줄 9(테스트 15) · advice_skip_form_test 줄 10(테스트 23) · 골든 1 + 1 · testWidgets·test 줄 합 21(≤ 33) · import = 드라이런 analyze «No issues found!» 차례(⟦실측⟧).
  🆕 test/advice_detail_fakes.dart(새 · 공개 이름 · 한국어 리터럴 0 · if 0 · collection-if 0 · 🔴 다른 fakes 파일 무수정 — advice_fakes.dart · holdings_overview_fakes.dart 는 import 만):
    class FakeAdviceDetailRepository extends UnimplementedAdviceRepository { FakeAdviceDetailRepository({required this.item, required this.fills}); final Future<AdviceItem?> Function(int call) item;
      final Future<List<TradeJournalEntry>> Function(int call) fills; final List<String> findArgs = <String>[]; final List<String> fillsArgs = <String>[];
      @override findById(String adviceId) → final int call = findArgs.length; findArgs.add(adviceId); return item(call); · @override fillsOfAdvice(String adviceId) → 같은 꼴(fillsArgs) }(나머지 4 메서드는 넘기지 않는다 — 받침대가 던진다)
    List<Override> adviceDetailOverrides({required FakeAdviceDetailRepository repo, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
      ← journalAdviceRepositoryProvider.overrideWithValue(repo) · journalSafetyRepositoryProvider.overrideWithValue(FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0))) · journalClockProvider · journalLinkOpenerProvider — 4줄
    Future<void> pumpAdviceDetail(WidgetTester tester, {required List<Override> overrides, required String adviceId})
    Set<String> adviceDetailAllowed(AdviceItem v) => <String>{v.asOf.label, ...adviceCardTexts(v), ?v.closeReasonLabel, for (final ReasonChip c in v.recordedDeviationChips) c.label, ?v.decisionLink?.label};
      (🔴 체결 행 글자는 넣지 않는다 — «화면 Text 전부» 는 체결 빈 목록 경우에만 쓴다 · 허용 집합에 링크 문자열 0)
  🆕 test/advice_skip_fakes.dart(새 · 같은 규칙 · 🔵 R5d 가 import 하는 이름 = FakeAdviceFormRepository · adviceFormRefTexts — 이름·서명 고정):
    class FakeAdviceFormRepository extends UnimplementedAdviceRepository { FakeAdviceFormRepository({required this.item, required this.spec}); final Future<AdviceItem?> Function(int call) item;
      final Stream<ManualFillFormSpec> Function(int call) spec; final List<String> findArgs = <String>[]; int specCalls = 0;
      @override findById(String adviceId) → 기록 · item(call) · @override watchManualFillFormSpec() → final int call = specCalls; specCalls = specCalls + 1; return spec(call); }
    class FakeAdviceSkipCommandApi extends UnimplementedCommandApi { FakeAdviceSkipCommandApi({required this.skip, required this.watch}); final Future<CommandReceipt> Function(int call) skip; final Stream<CommandReceipt> Function(int call) watch;
      final List<AdviceSkipSubmission> skipped = <AdviceSkipSubmission>[]; final List<String> watched = <String>[];
      @override skipAdvice(AdviceSkipSubmission submission) → 기록 · skip(call) · @override watchCommand(String commandId) → 기록 · watch(call) }
    List<Override> adviceSkipOverrides({required FakeAdviceFormRepository repo, required CommandApi cmd, required DraftStore store, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
      ← journalAdviceRepositoryProvider · journalCommandApiProvider · journalDraftStoreProvider · 안전 · 시계 · 열기 — 6줄
    Future<void> pumpAdviceSkip(WidgetTester tester, {required List<Override> overrides, required String adviceId})
    DraftRecord adviceSkipSeedWithCommand(DraftRecord r, String commandId) => r.copyWith(lastCommandId: commandId);   ← 🔵 copyWith 1곳(규칙 10 예외)
    List<String> adviceFormRefTexts(AdviceItem v) => <String>[?v.symbolLabel, ?v.sideLabel, v.sizingLabel, ?v.priceBand?.label, v.validityLabel, v.progressLabel];   ← 🔴 화면 2 _SkipReferenceCard 의 Text 순서
    Set<String> adviceSkipAllowed(ManualFillFormSpec s, AdviceItem v) => <String>{s.asOf.label, ?s.bannerText, ...adviceFormRefTexts(v), s.skipNoticeText, for (final ReasonOption o in s.skipReasons) o.label, ?s.blockedText};
  파일 머리(main() 안)에서 위 «픽스처» 를 한 번 final 로 읽는다.
A-2 — test/advice_detail_test.dart
 A2-01 부분 이행 — 전체 글자·차례·호출(02 §3-7 · K18) — partial + fills · 전제 둘: expect(partial.recordedDeviationChips, isNotEmpty); // pre · expect(partial.decisionLink, isNotNull); // pre →
        a2-asof 아래 Text == [partial.asOf.label] · adviceShownTexts(tester, find.byKey(const Key('a2-card'))) == adviceCardTexts(partial) · a2-close-reason findsNothing ·
        adviceShownTexts(a2-deviation) == [for (… c in partial.recordedDeviationChips) c.label] · a2-decision 아래 Text == [partial.decisionLink!.label] · a2-fills-title 글자 == JournalLabels.adviceRecordedFills ·
        ⓗ expect(fills, hasLength(1)); → i 마다 find.descendant(of: find.byKey(ValueKey<String>('a2-fill-$i')), matching: find.text(fills[i].symbolLabel)) findsOneWidget · a2-fill-1 findsNothing ·
        dy 가 a2-asof → a2-card → a2-deviation → a2-decision → a2-fills-title → a2-fill-0 차례로 크다 · expect(repo.findArgs, <String>[partial.adviceId]) · expect(repo.fillsArgs, <String>[partial.adviceId]) · ⓡ.
 A2-02 링크 다섯 — 버튼 둘 · 칩 · 결정 · 체결 행(K5 · K18) — partial + fills · 전제 셋: expect(partial.actions.length, 2); // pre · expect(partial.reasons.first.detailDeepLink, isNotNull); // pre · expect(fills.first.detailDeepLink, isNotNull); // pre →
        흐름 = a2-card 안 actions[0] 글자 버튼 탭 → actions[1] 글자 버튼 탭 → a2-card 안 reasons[0] 글자 칩 탭 → a2-decision 탭 → a2-fill-0 안 fills[0].symbolLabel 탭 →
        expect(opener.opened, <String>[partial.actions[0].deepLink, partial.actions[1].deepLink, partial.reasons[0].detailDeepLink!, partial.decisionLink!.deepLink, fills[0].detailDeepLink!]) · ⓡ.
 A2-03 보류 — 체결 0 · 편차 칩 0(K40) — onhold + [] · 전제 둘: expect(onhold.holdReasonLabel, isNotNull); // pre · expect(onhold.recordedDeviationChips, isEmpty); // pre →
        find.descendant(of: a2-card, matching: find.text(onhold.holdReasonLabel!)) findsOneWidget · find.descendant(of: a2-deviation, matching: find.byType(JournalReasonChip)) findsNothing · a2-deviation findsOneWidget ·
        a2-fills-title findsNothing · a2-fill-0 findsNothing · a2-fills-fail findsNothing · ⓡ.
 A2-04 뷰어 — 버튼 0 · 온 글자만 · 화면 Text 전부(K6 · K40 · C4r4a-2) — viewer + [] · 전제 둘: expect(viewer.actions, isEmpty); // pre · expect(viewer.phoneOnlyLabel, isNotNull); // pre →
        find.descendant(of: a2-card, matching: find.byType(OutlinedButton)) findsNothing · find.text(viewer.phoneOnlyLabel!) findsOneWidget · a2-decision findsOneWidget · a2-fill-0 findsNothing ·
        규칙 10 «화면의 Text 전부» 견본(allowed = adviceDetailAllowed(viewer)) · a2-decision 탭 → expect(opener.opened, <String>[viewer.decisionLink!.deepLink]) · ⓡ.
 A2-05 부재 — findById null(01 §21-7 · 발주자 확인 ①) — item = (int call) => Future<AdviceItem?>.value(null) → a2-absent 글자 == JournalLabels.adviceNotFound · a2-asof findsNothing · a2-card findsNothing ·
        expect(repo.fillsArgs, <String>[]) · ⓡ.
 A2-06 회수 문장(K39) — 두 경우 (revoked · item = revoked · close = revoked.closeReasonLabel) · (partial · item = partial · close = null)마다 — 전제 둘: expect(revoked.closeReasonLabel, isNotNull); // pre · expect(partial.closeReasonLabel, isNull); // pre →
        규칙 10 «없는 쪽» 견본 그대로(a2-close-reason) · a2-card findsOneWidget · ⓡ.
 A2-07 상태 × 갈래(두 구독 · 01 §21-7) — 다섯 경우(칸 = 이름 · item 공장 · fills 공장 · 시계 · 있음 Key 목록 · 없음 Key 목록 · stale Matcher):
        (item_loading · (int call) => Completer<AdviceItem?>().future · fills · 기본 · 있음 [a2-loading] · 없음 [a2-asof, a2-fail, a2-absent] · findsNothing) ·
        (item_fail · Future.error · fills · 기본 · 있음 [a2-fail] · 없음 [a2-loading, a2-asof, a2-absent] · findsNothing) ·
        (fills_loading · partial · (int call) => Completer<List<TradeJournalEntry>>().future · 기본 · 있음 [a2-asof, a2-card, a2-decision] · 없음 [a2-fills-title, a2-fill-0, a2-fills-fail] · findsNothing) ·
        (fills_fail · partial · Future.error · 기본 · 있음 [a2-card, a2-fills-fail] · 없음 [a2-fills-title, a2-fill-0] · findsNothing) ·
        (stale · partial · fills · adviceStaleClock() · 있음 [a2-asof, a2-card, a2-fill-0] · 없음 [a2-loading, a2-fail] · findsOneWidget)마다 —
        Key 목록마다 findsOneWidget / findsNothing(경우 칸의 두 목록 — 🔴 «로딩이면 …» 같은 if 0) · expect(find.text(JournalLabels.staleBannerTitle), c.stale) · CircularProgressIndicator findsNothing(ⓡ·ⓗ 없음).
 A2-08 재시도 — 두 경우 (item · item = (int call) => call == 0 ? Future<AdviceItem?>.error(StateError('fail')) : Future<AdviceItem?>.value(partial) · fills = fills · retryKey = a2-fail · findArgs = [id, id] · fillsArgs = [id]) ·
        (fills · item = partial · fills = (int call) => call == 0 ? Future<…>.error(StateError('fail')) : Future<…>.value(fills) · retryKey = a2-fills-fail · findArgs = [id] · fillsArgs = [id, id])마다 —
        steps = find.descendant(of: find.byKey(c.retryKey), matching: find.text(JournalLabels.retry)) 탭 → pump 두 번 → a2-fill-0 findsOneWidget · expect(repo.findArgs, c.findArgs) · expect(repo.fillsArgs, c.fillsArgs) · ⓡ.
 A2-09 화면 Text 전부 · 큰 글꼴(C4d-1) — onhold + [] · allowed = adviceDetailAllowed(onhold) → 규칙 10 «화면의 Text 전부» 견본 그대로 → textScaleFactorTestValue = 2.0(+ teardown clear) → pump → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = advice_detail_test.dart 8줄(A2-01~A2-06 · A2-08 · A2-09 — 경우 for 안의 한 줄) · ⓗ 기대 = 1줄(A2-01) — 🔴 정확히 · (전제) = 11(A2-01 2 · 02 3 · 03 2 · 04 2 · 06 2).
A-4 — test/advice_skip_form_test.dart(import 'package:ui_journal/journal_draft.dart'; · store = 테스트마다 새 RecordingDraftStore(시드 = 그 칸))
 A4-01 전체 — 받은 순서 · 같은 꼴 · 탭 전 save 0(02 §3-9 · K37) — ad0001 + spec + RecordingDraftStore() · 전제: expect(drafts.rows[1].key.targetId, ad0001.adviceId); // pre →
        a4-asof 아래 Text == [spec.asOf.label] · adviceShownTexts(a4-ref) == adviceFormRefTexts(ad0001) · a4-notice 글자 == spec.skipNoticeText · ⓗ expect(spec.skipReasons, hasLength(6)); →
        i 마다 a4-reason-$i 아래 Text == [spec.skipReasons[i].label] · a4-reason-6 findsNothing · find.byType(OutlinedButton) findsNWidgets(6) · find.byType(TextField) findsNothing ·
        dy 가 a4-asof → a4-ref → a4-notice → a4-reason-0 → … → a4-reason-5 차례로 크다 · expect(store.loaded, <DraftKey>[drafts.rows[1].key]) · expect(store.saved, <DraftRecord>[]) · a4-receipt findsNothing · ⓡ.
 A4-02 1탭 = 제출 · 제출 뒤 save 한 번(K12) — skip = (int call) => Future<CommandReceipt>.value(receipts.rows[0]) · watch = (int call) => Stream<CommandReceipt>.value(receipts.rows[0]) · 전제: expect(spec.skipReasons[1].deepLink, isNull); // pre →
        a4-reason-1 탭 → pump → expect(cmd.skipped.single.adviceId, ad0001.adviceId) · expect(cmd.skipped.single.input.toJson(), <String, dynamic>{'reason': spec.skipReasons[1].code, 'note': ''}) ·
        expect(store.saved.single.lastCommandId, receipts.rows[0].commandId) · expect(store.saved.single.adviceSkip?.toJson(), <String, dynamic>{'reason': spec.skipReasons[1].code, 'note': ''}) · expect(store.saved.single.key, drafts.rows[1].key) ·
        expect(cmd.watched, <String>[receipts.rows[0].commandId]) · expect(opener.opened, <String>[]) · ⓡ.
 A4-03 예산 코드 = push 만(K12) — 두 경우 (budget_price · i = 0 · opened = <String>[spec.skipReasons[0].deepLink!]) · (budget_pause · i = 2 · opened = <String>[spec.skipReasons[2].deepLink!])마다 —
        전제 둘: expect(spec.skipReasons[0].deepLink, isNotNull); // pre · expect(spec.skipReasons[2].deepLink, isNotNull); // pre → steps = a4-reason-<c.i> 탭 → expect(opener.opened, c.opened) · expect(cmd.skipped, <AdviceSkipSubmission>[]) ·
        expect(store.saved, <DraftRecord>[]) · expect(store.cleared, <DraftKey>[]) · a4-receipt findsNothing · ⓡ.
 A4-04 접수증 갈래(01 §21-7 · §12-4) — 다섯 경우(칸 = 이름 · watch = 구독이 낼 접수증 · enabled Matcher · cleared 목록 · opened 목록):
        (requested · receipts.rows[0] · isNull · [] · []) · (executed · receipts.rows[1] · isNull · [drafts.rows[1].key] · [AppNavActions.back]) · (rejected_lease · receipts.rows[2] · isNotNull · [] · []) ·
        (rejected_not_open · receipts.rows[3] · isNotNull · [] · []) · (held · receipts.rows[4] · isNull · [] · [])마다 — skip = rows[0] · watch = (int call) => Stream<CommandReceipt>.value(c.watch) ·
        전제: expect(receipts.rows[1].state, CommandState.executed); // pre → 규칙 10 «접수증 갈래» 견본 그대로 · ⓡ.
 A4-05 제출 Future 에러 = 접수 실패 1줄(01 §12-3) — skip = (int call) => Future<CommandReceipt>.error(StateError('fail')) → a4-reason-1 탭 → pump → a4-submit-not-accepted 글자 == JournalLabels.submitNotAccepted ·
        expect(store.saved, <DraftRecord>[]) · expect(cmd.watched, <String>[]) · a4-reason-1 의 onPressed isNotNull · a4-receipt findsNothing · ⓡ · expect(tester.takeException(), isNotNull).
 A4-06 복원 id — 첫 접수증 전 잠금 · executed = 빈 폼(K11) — 두 경우 (restored_requested · watch = receipts.rows[0] · receipt = receipts.rows[0].stateLabel · enabled isNull · cleared [] ) ·
        (restored_executed · watch = receipts.rows[1] · receipt = null · enabled isNotNull · cleared [drafts.rows[1].key])마다 — store = RecordingDraftStore(seed: <DraftRecord>[adviceSkipSeedWithCommand(drafts.rows[1], receipts.rows[0].commandId)]) ·
        전제: expect(drafts.rows[1].lastCommandId, isNull); // pre → expect(cmd.watched, <String>[receipts.rows[0].commandId]) · «없는 쪽» 견본 꼴(a4-receipt 글자 · want = c.receipt) · a4-reason-1 onPressed == c.enabled ·
        expect(store.cleared, c.cleared) · expect(opener.opened, <String>[])(🔴 복원 id = pop 0) · expect(cmd.skipped, <AdviceSkipSubmission>[]) · ⓡ.
 A4-07 재구독 — 복원 id + 구독 에러 → 다시 시도 — store = 복원 id 시드 · watch = (int call) => call == 0 ? Stream<CommandReceipt>.error(StateError('fail')) : Stream<CommandReceipt>.value(receipts.rows[0]) →
        a4-resubscribe findsOneWidget · a4-reason-1 onPressed isNull · a4-resubscribe 탭 → pump → a4-resubscribe findsNothing · a4-receipt 글자 == receipts.rows[0].stateLabel ·
        expect(cmd.watched, <String>[receipts.rows[0].commandId, receipts.rows[0].commandId]) · expect(tester.takeException(), isNotNull).
 A4-08 제출 차단 · 폼 배너(K21 · 발주자 확인 ⑦) — 두 경우 (blocked · spec = blockedSpec · blocked = blockedSpec.blockedText · banner = blockedSpec.bannerText · reasons findsNothing) ·
        (normal · spec = spec · blocked = null · banner = null · reasons findsOneWidget)마다 — 전제 둘: expect(blockedSpec.blockedText, isNotNull); // pre · expect(blockedSpec.bannerText, isNotNull); // pre →
        «없는 쪽» 견본 꼴 두 번(a4-blocked 글자 · a4-banner 글자) · expect(find.byKey(const ValueKey<String>('a4-reason-0')), c.reasons) · a4-notice findsOneWidget · ⓡ.
 A4-09 상태 × 갈래(구독 셋 + 초안 · 01 §21-7) — 일곱 경우(칸 = 이름 · item 공장 · spec 공장 · store · 있음 Key 목록 · 없음 Key 목록 · stale Matcher):
        (draft_pending · ad0001 · spec · load 가 끝나지 않는 저장소(extends RecordingDraftStore · load → Completer<DraftRecord?>().future — 테스트 파일 안 private class) · 있음 [a4-loading] · 없음 [a4-asof, a4-ref] · findsNothing) ·
        (item_loading · Completer · spec · 기본 · 있음 [a4-loading] · 없음 [a4-asof, a4-absent] · findsNothing) · (item_fail · Future.error · spec · 기본 · 있음 [a4-fail] · 없음 [a4-loading, a4-asof] · findsNothing) ·
        (item_null · Future.value(null) · spec · 기본 · 있음 [a4-absent] · 없음 [a4-asof, a4-ref, a4-reason-0] · findsNothing) ·
        (spec_loading · ad0001 · Stream.fromFuture(Completer().future) · 기본 · 있음 [a4-loading] · 없음 [a4-asof] · findsNothing) · (spec_fail · ad0001 · Stream.error · 기본 · 있음 [a4-fail] · 없음 [a4-loading, a4-asof] · findsNothing) ·
        (spec_stale · ad0001 · staleSpec · 기본 · 있음 [a4-asof] · 없음 [a4-ref, a4-notice, a4-reason-0, a4-blocked] · findsOneWidget)마다 —
        Key 목록마다 findsOneWidget / findsNothing · expect(find.text(JournalLabels.staleBannerTitle), c.stale) · CircularProgressIndicator findsNothing(ⓡ·ⓗ 없음 · 에러 경우의 보고 = 없음 — 리포지토리 에러는 _report 를 타지 않는다).
 A4-10 화면 Text 전부 · 큰 글꼴 — ad0001 + spec · allowed = adviceSkipAllowed(spec, ad0001) → 규칙 10 «화면의 Text 전부» 견본 그대로 → textScaleFactorTestValue = 2.0(+ teardown clear) → pump → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = advice_skip_form_test.dart 8줄(A4-01~A4-06 · A4-08 · A4-10 — 경우 for 안의 한 줄) · ⓗ 기대 = 1줄(A4-01) — 🔴 정확히 · (전제) = 8(A4-01 1 · 02 1 · 03 2 · 04 1 · 06 1 · 08 2).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려 · 갈래마다 — 값 · 빈 · 부재 · 뷰어 · 오래됨 · 에러 · 잠금 · 차단):
   (순서) A-2 결정 링크를 카드 위로 · 회수 문장을 체결 아래로 · 체결 블록을 머리 위로 · 배너를 카드 아래로 · A-4 사유 순서 뒤집기 · 문구를 사유 아래로 · 참조 카드 글자 자리 바꾸기.
   (존재) A-2 카드 탭(InkWell) 더하기 · 체결 빈 목록에 머리 · 체결 로딩에 스켈레톤 · 편차 칩 숨김 · 회수 문장 숨김 · 결정 링크 null 에도 · 부재에 머리 · 부재에 fillsOfAdvice 부르기 · A-4 note 입력란 · 「전부 건너뛰기」 ·
     blockedText 에도 사유 · blockedText 숨김 · bannerText 숨김 · 신선도 초과에도 사유 · 뷰어에 «숨김» 덧붙이기(C4r4a-2) · 정적 글자 하나 더하기 · 링크 글자를 화면에 그리기(탐침 — C4r13b-6).
   (명령·초안) 예산 코드에 skipAdvice · 예산 코드 탭에 save · 비예산 탭에 링크 · 탭 전 save · 제출 뒤 save 0 · save 에 lastCommandId 0 · executed 밖 clear · executed 에 clear 0 · 복원 id executed 에 pop · 이 화면 executed 에 pop 0 ·
     requested 에 pop · 보류 3상태에 잠금 풀기 · rejected 에 잠금 유지 · 첫 접수증 전 잠금 0 · 구독 에러에 재구독 버튼 0 · Future 에러에 글자 0 · AdviceSkipInput(reason: …) 를 화면이 고르기 · adviceId 대신 다른 글자.
   (상태) item 에러를 스켈레톤으로 · 체결 에러에 본문 숨김 · 체결 에러를 화면 전체 에러로 · 재시도에 invalidate 0 · 오래됨 배너 빼기 · 신선도 비교 뒤집기 · 벽시계로 신선도 · 초안 load 전에 사유 열기.
   🔵 판정 = 변이마다 ui_journal 의 flutter test 전부(골든 포함) + C-46 ⑯~㉖ · 드라이런 = ⟦실측⟧(목록 KILLED 수 · 참고 변이 통과 목록).

■ 정적 묶음 — packages/ui_journal 에서 아래 37줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 출력 줄 수(EXIT 줄 포함) = ⟦실측⟧ 줄 — 붙이기 전에 세어 같은지 본다 ·
   flutter test·dart test 출력은 파일로 떠서 붙인다 · «EXIT:1»/«EXIT:False» = 출력 없음 · 블록 뒤 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»)
echo "## C01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/advice_detail_fakes.dart test/advice_skip_fakes.dart test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n -e journalLinkOpenerProvider --and --not -e AppNavActions.back -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C06 pop line (1)"; git grep -n "AppNavActions.back" -- lib; echo "EXIT:$?"
echo "## C07 read and command lines (6)"; git grep -nE "findById\(|fillsOfAdvice\(|watchManualFillFormSpec\(|skipAdvice\(|watchCommand\(" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C08 forbidden words in A-2 0"; git grep -nP "DateTime\.|DateRange|kIsWeb|Platform\.|dart:io|HoldingPnl|FeatureFlags|RunMode|operatingMode|watchState|activeFlags|FlagIds|markerOnly|killSwitch|recordManualFill|skipAdvice|submitSelfReportBalance|deferAdviceConfirm|watchCommand|watchManualFillFormSpec|watchDecisionDetail|fillChain|JournalRepository|HoldingsRepository|DraftStore|CommandApi|\.status\b|\.effectiveStatus|\.onHold\b|\.suppressed\b|\.actionId\b|\.quantity\b|\.recordedQuantity|\.sleeve\b|\.decision\b|\.closeReasonCode|\.adviceId|\.name\b|\.wire\b|\.symbol\b|\.side\b|\.code\b|\.fillKind|\.kind\b|\.isUrgent|\.statusTone|AdviceStatus\.|AdviceActionId\.|AdviceKind\.|OrderSide\.|\.level\b|\.length\b|NumberFormat|toString\(|Navigator|ScaffoldMessenger|SnackBar|FlutterError|FloatingActionButton|InkWell" -- lib/src/advice_detail.dart; echo "EXIT:$?"
echo "## C09 forbidden words in A-4 0"; git grep -nP "DateTime\.|DateRange|kIsWeb|Platform\.|dart:io|HoldingPnl|FeatureFlags|RunMode|operatingMode|watchState|activeFlags|FlagIds|markerOnly|killSwitch|recordManualFill|submitSelfReportBalance|deferAdviceConfirm|fillsOfAdvice|watchDecisionDetail|JournalRepository|HoldingsRepository|CommandContext|AdviceSkip\(|\.status\b|\.quantity\b|\.sleeve\b|\.decision\b|\.name\b|\.wire\b|AdviceStatus\.|AdviceActionId\.|AdviceSkipReason\.|OrderSide\.|requiresNote|rejectReasonCode|retryCode|retryLabel|TextField|TextEditingController|Checkbox|\.level\b|\.length\b|\.trim\(|NumberFormat|toString\(|Navigator|ScaffoldMessenger|SnackBar|FloatingActionButton|\.where|[fF]irstWhere|\.sort|\.fold\(|\.reduce\(|groupBy" -- lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C10 AppRoutes constants 0"; git grep -nE "AppRoutes\.[a-zA-Z]+" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C11 enum names other than CommandState 0"; git grep -nE "AdviceStatus\.|AdviceActionId\.|AdviceKind\.|AdviceSkipReason\.|OrderSide\.|ChipTone\.|UiLevel\.|LedgerTrustGrade\.|DraftKind\.(journalDraft|manualFillRecord|selfReportBalance)" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C12 journal labels (41)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## C13 barrel exports (15)"; git grep -n "^export " -- lib/ui_journal.dart; echo "EXIT:$?"
echo "## C14 operator barrel exports (2)"; git grep -n "^export " -- lib/journal_draft.dart; echo "EXIT:$?"
echo "## C15 providers in new lib (4)"; git grep -nP "^final \w+Provider\b" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_journal/)" -- lib; echo "EXIT:$?"
echo "## C17 hangul literals in new lib files 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C18 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart lib/l10n/labels.dart; echo "EXIT:$?"
echo "## C19 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/advice_detail_test.dart test/advice_skip_form_test.dart; echo "EXIT:$?"
echo "## C21 H lines (hasLength)"; git grep -c "hasLength(" -- test/advice_detail_test.dart test/advice_skip_form_test.dart; echo "EXIT:$?"
echo "## C22 key names (one line each)"; git grep -noP "'(a2|a4)-[a-z]+(-[a-z]+)*" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C23 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## C24 Colors files 0"; git grep -lw Colors -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C25 rich text trimming reshaping 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox|\.take\(|\.where|[fF]irstWhere|\.sort|\.fold\(|\.reduce\(|groupBy" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C26 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## C27 Scaffold AppBar SafeArea 0"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C28 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_journal.dart lib/journal_draft.dart lib/src/common lib/src/timeline.dart lib/src/advice lib/src/advice_inbox.dart lib/src/advice_history.dart lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart lib/src/journal_draft/journal_draft_form.dart pubspec.yaml analysis_options.yaml README.md test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/holdings_overview_fakes.dart test/advice_fakes.dart test/ledger_fakes.dart; echo "EXIT:$?"
echo "## C29 implements in new tests 0"; git grep -n " implements " -- test/advice_detail_fakes.dart test/advice_skip_fakes.dart test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C30 copyWith in tests (seed 1)"; git grep -n "copyWith(" -- test/advice_detail_fakes.dart test/advice_skip_fakes.dart test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C31 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/advice_detail_fakes.dart test/advice_skip_fakes.dart test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C32 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## C33 precondition marks (pre)"; git grep -c "// pre$" -- test/advice_detail_test.dart test/advice_skip_form_test.dart; echo "EXIT:$?"
echo "## C34 name compares element picks and hidden ifs in tests 0"; git grep -nP "\b(name|which)\s*==|opened\[\d\]|cleared\[\d\]|saved\[\d\]|skipped\[\d\]|watched\[\d\]|\|\|[^;]*isTrue\)" -- test/advice_detail_fakes.dart test/advice_skip_fakes.dart test/advice_detail_test.dart test/advice_skip_form_test.dart test/golden/a2_golden_test.dart test/golden/a4_golden_test.dart; echo "EXIT:$?"
echo "## C35 non-null assertion in new lib 0"; git grep -nP "[\w\)\]]!(?![=])" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C36 clear calls (1)"; git grep -n "\.clear(" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
echo "## C37 error report lines (form 1)"; git grep -n "FlutterError" -- lib/src/advice_detail.dart lib/src/journal_draft/advice_skip_form.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(카드 계획 · 드라이런 ⟦실측⟧) — C01 = 주석 줄 말고 출력 없음 · C02 = 출력 없음 · C03 = 4줄(a2_golden 1 · a4_golden 1 · advice_detail_test 9 · advice_skip_form_test 10) · C04 = 0 ·
   S05 = 2줄(advice_detail.dart 결정 링크 1 · journal_draft/advice_skip_form.dart 예산 코드 1 — 줄마다 탭 콜백 안) · C06 = 1줄(advice_skip_form.dart 의 _afterExecuted) ·
   C07 = 6줄(advice_detail.dart findById · fillsOfAdvice · advice_skip_form.dart findById · watchManualFillFormSpec · skipAdvice · watchCommand) · C08 = 0 · C09 = 0 · C10 = 0 · C11 = 0 · C12 = «lib/l10n/labels.dart:41»(🔴 정확히 — R5b 병합본 39(⟦실측⟧) + R5c 2) ·
   C13 = 15줄(R5b 병합본 14줄(⟦실측⟧) 위 · 🆕 src/advice_detail 이 src/advice/advice_card 와 src/advice_history 사이 · 🔴 정확히) · C14 = 2줄(🆕 src/journal_draft/advice_skip_form.dart · src/journal_draft/journal_draft_form.dart 차례 · 🔴 정확히) ·
   C15 = 4줄(advice_detail.dart 2 · advice_skip_form.dart 2) · C16~C19 = 0 · C20 = «test/advice_detail_test.dart:8» · «test/advice_skip_form_test.dart:8» · C21 = «test/advice_detail_test.dart:1» · «test/advice_skip_form_test.dart:1»(🔴 정확히 — 다르면 반려) ·
   C22 = 23줄 = 위 «Key 표» 이름마다 정확히 1줄 · C23~C27 = 0 · C28 = 세 줄(labels.dart · ui_journal.dart · journal_draft.dart — 둘째 수 0 · ui_journal.dart 첫째 수 1 · journal_draft.dart 첫째 수 1 · labels.dart 첫째 수 = ⟦실측⟧(수는 재량 · 삭제 0 만 본다)) · 그 밖 파일 줄 없음 ·
   C29 = 0 · C30 = 1줄(test/advice_skip_fakes.dart 의 adviceSkipSeedWithCommand) · C31 = 0 · C32 = 10줄 전부 «A»(a2_* 6 · a4_* 4) · C33 = «test/advice_detail_test.dart:11» · «test/advice_skip_form_test.dart:8»(🔴 정확히) · C34 = 0 · C35 = 0 ·
   C36 = 1줄(advice_skip_form.dart 의 s.clear(_draftKey) — 🔴 TextEditingController·Map 의 .clear( 0) · C37 = 1줄(advice_skip_form.dart 의 _report · advice_detail.dart 0))
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · C08 · C09 · C25 는 주석 줄도 센다(규칙 15))

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · ✅ K35 · 이름 = 02 §3-7 (d) · §3-9 (d) 글자 그대로 · golden README «🆕 R5» 절 표 그대로)
  a2 — test/golden/a2_golden_test.dart · const Size _kTallPhone = Size(390, ⟦실측⟧)(폭 390 고정 · 드라이런 맨 아래 dy 최대 ⟦실측⟧ = a2_partial) · 위젯 = AdviceDetail(adviceId: flow.item.adviceId):
    이름          findById      fillsOfAdvice   안전    맨 아래 Key                        흐름
    a2_partial    partial       fills           행 0    ValueKey<String>('a2-fill-0')      없음
    a2_onhold     onhold        []              행 0    Key('a2-decision')                 없음
    a2_viewer     viewer        []              행 0    Key('a2-decision')                 없음
  a4 — test/golden/a4_golden_test.dart · const Size _kTallPhone = Size(390, ⟦실측⟧) · 위젯 = AdviceSkipForm(adviceId: ad0001.adviceId) · import 'package:ui_journal/journal_draft.dart'; · 사양 = spec · 초안 = RecordingDraftStore() · 명령 = UnimplementedCommandApi()(이 흐름은 명령을 부르지 않는다 — 부르면 받침대가 던져 테스트가 깨진다) · 열기 = 테스트마다 새 RecordingLinkOpener:
    이름             흐름                                                      맨 아래 Key                            열린 링크(opened 칸)
    a4_reasons       없음                                                      ValueKey<String>('a4-reason-5')        <String>[]
    a4_budget_push   a4-reason-0 ensureVisible 뒤 탭(예산 코드 · 명령 0)       ValueKey<String>('a4-reason-5')        <String>[spec.skipReasons[0].deepLink!]
  모양 = h63_golden_test.dart(R4b)와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록(private class _Flow) × Brightness.values 루프 · 흐름 = 클로저 칸(흐름 없음 = (WidgetTester t) async {}) · 테스트 이름 '${flow.name} ${brightnessSuffix(b)}' ·
  주입 = pumpForGolden(tester, <위젯>, brightness: b, logicalSize: _kTallPhone, wrapApp: (Widget app) => ProviderScope(overrides: adviceDetailOverrides(…) / adviceSkipOverrides(…, opener: opener), child: app)) → await tester.pump(); → await tester.pump(); →
    await flow.steps(tester); → await tester.pumpAndSettle(); →(a4 만) expect(opener.opened, flow.opened); → 위치 전제 둘 → expectGolden(flow.name, b).
  위치 전제 둘 = 이 코드 글자 꼴(C4r3-5 · 흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(_kTallPhone.height));     // flow.bottom = 위 표의 맨 아래 Key(Key 칸 · 테스트 파일 안 const)
    expect(tester.getTopLeft(find.byKey(const Key('a2-asof'))).dy, 0.0);                        // a4 파일 → Key('a4-asof')
  명령(packages/ui_journal): flutter test --update-goldens test/golden/a2_golden_test.dart · flutter test --update-goldens test/golden/a4_golden_test.dart → flutter test(옵션 없이 · git status 에 새 PNG 10 만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이(_kTallPhone)는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     골든 높이 = 카드 확정값 + 여백 재량 — 화면 여백을 줄여 맞추는 것은 허용 · 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개 · 두 화면 질문을 한 파일에)
· A2A4_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지 · 행 앞에 «A-2:» 또는 «A-4:» 접두(🔵 예외 = 골든 dy «측정:» 행).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A5 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 5줄을 그대로 붙이고 <값> 자리에만 잰 수를 넣는다(높이 = 리터럴):
      ┌── 측정 행 복사 시작(다음 줄부터 · 5줄)
| A1 | R5c-Bob-A2A4 | 추측 | 측정: a2_partial dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A2 | R5c-Bob-A2A4 | 추측 | 측정: a2_onhold dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A3 | R5c-Bob-A2A4 | 추측 | 측정: a2_viewer dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A4 | R5c-Bob-A2A4 | 추측 | 측정: a4_reasons dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
| A5 | R5c-Bob-A2A4 | 추측 | 측정: a4_budget_push dy 실측값 (light=<값>, dark=<값>) < ⟦실측⟧ | 골든 위치 전제 실측 | ⟦실측⟧ 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖)
  여백을 줄였으면 A6 부터 «측정:» 전·후 행 · 2개 밖에 더 필요했던 정적 라벨 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 2 · 읽지 않는 필드 · 배치 순서 · Text 순서 · 부재 글자 · 체결 행 조각 · 체결 블록 갈래 · 참조 카드 · 신선도 초과 · 차단 · 복원 · pop · 잠금 · 골든 이름·입력 · 재량(여백·크기·모서리).
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(5) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋)
  cd packages/ui_journal
  flutter test test/advice_detail_test.dart             ← 끝 줄 그대로(기대 «+15: All tests passed!»)
  flutter test test/advice_skip_form_test.dart          ← 끝 줄 그대로(기대 «+23: All tests passed!»)
  flutter test test/golden/a2_golden_test.dart          ← 끝 줄 그대로(기대 «+6: All tests passed!»)
  flutter test test/golden/a4_golden_test.dart          ← 끝 줄 그대로(기대 «+4: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄 그대로 · 기대 = 시작 기준 N + 48 — ⟦실측⟧ → «+⟦실측⟧: All tests passed!»)
  cd ../domain_contracts
  dart test test/contracts/c46_advice_x7_test.dart -r expanded   ← 전부 통과 · «C-46 ⑯ 대상» 줄과 그 아래 들여쓴 경로 줄을 그대로 적어 둔다
     (기대 6줄: «C-46 ⑯ 대상 5파일 — 읽기 {…} + lib/src/advice/** · 폼 {…}» + 공백 4칸 들여쓴 «packages/ui_journal/lib/src/advice/advice_card.dart» · «…/advice_detail.dart» · «…/advice_history.dart» · «…/advice_inbox.dart» ·
      «packages/ui_journal/lib/src/journal_draft/advice_skip_form.dart»(정렬 순) · 🔴 «4파일» 이면 파일 이름이 카드와 다르다 — 멈춤)
  cd ../..
  bash tool/check_boundaries.sh   ← 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건(«packages/ui_journal/lib/src/timeline.dart:109»)은 이 카드와 무관 — 그대로 둔다 · 그 밖 🟡 [C-5] 0
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+⟦실측⟧ ~30: All tests passed!»(이 카드 몫 0) · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_journal/): M lib/journal_draft.dart · M lib/l10n/labels.dart · A lib/src/advice_detail.dart · A lib/src/journal_draft/advice_skip_form.dart · M lib/ui_journal.dart ·
        A test/advice_detail_fakes.dart · A test/advice_detail_test.dart · A test/advice_skip_fakes.dart · A test/advice_skip_form_test.dart · A test/golden/a2_golden_test.dart · A test/golden/a4_golden_test.dart · A test/golden/goldens/a2_*.png 6장 · a4_*.png 4장 ·
        M docs/ai-context/inbox/A2A4_questions.md · 그 밖의 줄(특히 M lib/src/advice/** · M lib/src/advice_inbox.dart · M lib/src/journal_draft/journal_draft_form.dart · M lib/src/common/** · M test/advice_fakes.dart · M PNG · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M6] R5c (6) 사전검사 지적 수정» · amend 금지 · format:fix 먼저) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m6-a2a4
  git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD   ← ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · 권장대로면 커밋 5줄)
  cd packages/ui_journal → 위 «정적 묶음» 37줄 → cd ../..   ← ② 에 그대로 붙일 출력
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M6] A-2 안내 상세·A-4 미이행 사유
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
      🔴 N3 — 내기 전 사전검사 ② **두 번** — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R5c-Bob-A2A4_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R5c-Bob-A2A4_submit.md --golden-prefix a2 --goldens 6
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R5c-Bob-A2A4_submit.md --golden-prefix a4 --goldens 4
        ← 🔴 두 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 채팅에 낸다(🔴 1 이상이면 글을 고쳐 둘 다 다시 돌린다) · 출력은 채팅에 붙이지 않는다 ·
          🔵 접두는 문자열 하나만 받는다 — 골든 표는 한 표(a2 6행 + a4 4행 = 10행)로 두고 접두마다 따로 센다 · 🔵 🟡 [G1] 은 멈춤이 아니다 — 표는 이 카드의 셈 단위대로(셈 단위 견본 = 아래 ③ · ⟦실측⟧).
   ① 아래 «① 머리 복사 상자» 두 줄 그대로 + «바뀐 파일:» + name-status 출력 그대로(코드 블록 하나) + «커밋 목록:» + log 출력 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: A-2 — 안내 상세(AdviceDetail(adviceId:))
화면 ID: A-4 — 미이행 사유(AdviceSkipForm(adviceId:) · operator)
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 23항 — 아래 복사 상자 23줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 23줄 그대로인지 «23항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «산술 = 신선도 한 식 · isEmpty · deepLink null 여부 · 잠금 switch 뿐 · 건수·잔량 0 · 금지 수치 C18 0건 · 소수·% 리터럴 C19 0건»
        2번 = «한국어 리터럴 = labels.dart(R5c 절 2개 · 합 <N> — C12) 한 파일뿐(C17 0건) · 엔진 글자 = DTO *Label·label·stateLabel 그대로»
        3번 = «이 카드 범위 밖(손익·J-4 없음) · 두 화면 손익 0(C08 · C09)»
        4번 = «이 카드 범위 밖(H6-1·H6-2 = R4)»
        5번 = «M5 화면 렌더 0 · 예산 코드 = option.deepLink push 만(A4-03) · 체결 정정 진입 0»
        6번 = «정적 묶음 C16 — 허용 밖 import 0줄 · pubspec·analysis_options 무변경(C28)»
        7번 = «A-4 = operator 파일(journal_draft/ · operator 배럴 C14 <N>줄) · 배럴은 operator 파일 export·import 0(C-35 ⑥) · 근거 원문 필드 0»
        8번 = «배너 = JournalSafetyBanners 그대로 · 폼 배너 = bannerText 그대로(A4-08) · 화면이 지은 배너 문구 0»
        9번 = «머리 = asOf.label(a2-asof = item.asOf · a4-asof = spec.asOf · A2-01 · A4-01) · 로딩·부재·에러·오래됨 = A2-05 · A2-07 · A4-09»
        10번 = «타입·필드 이름 짓기 0 · 픽스처 변경 0 · 새 PNG = a2_* 6장 + a4_* 4장 · 재생성 <N>장(C32)»
        11번 = «모드 필드 0(C08 · C09) · 접두·띠 0 · 존재 = 데이터(actions · null 여부 · deepLink)»
        12번 = «A-2 버튼 = AdviceCard 의 actions 그대로(A2-02) · status·onHold·suppressed 분기 0(C-46 ⑰⑱ · C08)»
        13번 = «이 카드 범위 밖(A-3 = R5d · A-2·A-4 는 입력값 비교 0 · 수량 버튼 0)»
        14번 = «viewer 판 = actions 빈 목록 · 체결 빈 목록 · phoneOnlyLabel 그대로(A2-04) · 화면이 채운 종목·수량·가격 0»
        15번 = «안내를 J-1 에 섞지 않음(J-1 파일 무수정 · C28) · 예산 차감 명령 0(예산 코드 = 링크 push · A4-03)»
        16번 = «이 카드 범위 밖(L-3 = R5e)»
        17번 = «내보내기·공유·인쇄 0»
        18번 = «링크 null = 부재(decisionLink · A2-04 · A2-07 · 예산 = deepLink non-null 만 push · A4-03) · id 로 버튼 존재 판정 0»
        19번 = «거르기·묶기·재정렬 0(C25) · 체결 = fillsOfAdvice 받은 순서 · 사유 = skipReasons 받은 순서 · 링크 조립 0(C04 · C10 · pop = AppNavActions.back <N>줄 C06)»
        20번 = «띠 높이 예약 0 · 신선도 = 주입 Clock + asOf 한 식(A2-07 · A4-09)»
        21번 = «플래그 재정렬·리터럴 비교 0 · FlagIds·activeFlags 0(C-46 ㉑ · C08 · C09)»
        22번 = «DraftStore 주입 = operator 쪽(advice_skip_form.dart)만 · A-2 = 0(C08) · pubspec 무변경(C28)»
        23번 = «clear = executed 한 곳(C36 <N>줄 · A4-04) · 탭 전 save 0 · 확인값 0 · 첫 접수증 전 잠금(A4-06) · 복원 id executed = 빈 폼(A4-06)»
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
      23항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r5c_box2.txt)에 저장 → (Get-Content $env:TEMP\r5c_box2.txt).Count 또는 grep -c "" "$TEMP/r5c_box2.txt" →
        출력 한 줄을 아래 «23항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 23):
      ┌── 23항 줄 수 복사 시작(다음 줄부터 · 4줄)
23항 줄 수:
```
<출력 한 줄>
```
      └── 23항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 37줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄들(S05 출력 줄마다 한 줄 · 같은 차례 · 기대 2줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(C20·C21 출력 줄 그대로 복사 · test/ 를 떼지 않는다) + «C-46 ⑯ 출력:» + 출력 6줄 그대로 + «테스트 파일별:» + 위 flutter test 네 파일 끝 줄 그대로(advice_detail · advice_skip_form · a2_golden · a4_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 6줄)
ⓡ = C20 출력:
<C20 출력 줄 그대로>
<C20 출력 줄 그대로>
ⓗ = C21 출력:
<C21 출력 줄 그대로>
<C21 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — A-2 로딩·정상·부재·에러 4줄 + A-4 로딩·정상·차단·에러 4줄 + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로:
         A-2 «정상» = ListView → Key('a2-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('a2-card')(AdviceCard) → Key('a2-close-reason')(있을 때) → Key('a2-deviation') → Key('a2-decision')(있을 때) →
                      Key('a2-fills-title')(있을 때) → ValueKey<String>('a2-fill-$i')(JournalEntryCard) → Key('a2-fills-fail')(있을 때)
         A-2 «로딩» = JournalSkeleton(Key('a2-loading')) · «부재» = Key('a2-absent') · «에러» = JournalErrorView(Key('a2-fail'))
         A-4 «정상» = ListView → Key('a4-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('a4-banner')(있을 때) → Key('a4-ref') → Key('a4-notice') → ValueKey<String>('a4-reason-$i') →
                      Key('a4-receipt')(있을 때) → Key('a4-submit-not-accepted')(있을 때) → Key('a4-resubscribe')(있을 때)
         A-4 «로딩» = JournalSkeleton(Key('a4-loading')) · «차단» = ListView → Key('a4-asof') → JournalSafetyBanners → Key('a4-banner')(있을 때) → Key('a4-ref') → Key('a4-notice') → Key('a4-blocked') · «에러» = JournalErrorView(Key('a4-fail'))
      골든 표 10행(a2_* 6 · a4_* 4 · 한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |» · 이름 칸 = «a2_partial light» 꼴 · 입력 = 경로 그대로(a2_partial = «advice_detail_partial.json + advice_fills_ad0005.json» ·
        a2_viewer = «advice_viewer_4.json 행 2» · a4_* = «advice_12.json 행 3 + fill_form_spec.json») · 크기 = 390×<높이 리터럴> · dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(5장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 배경 덩어리 · 칩 n개 · 막대 · 점 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(10행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다 · «상자» 낱말은 덩어리 이름에만) ·
        셈 단위 견본 2행(드라이런이 PNG 를 열어 쓴 칸 · 꼴만 본뜬다): ⟦실측⟧ · ⟦실측⟧.
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/A2A4_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = A2A4_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_journal 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 48 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-a2a4` 푸시 1건 · 커밋 권장 5개(마지막 = format·질문 · amend·rebase·강제 푸시 0 · 커밋마다 지정 파일 add · (5) 뒤 = 사전검사 ① 수정 (6) 하나만).
- `lib/` 새 파일 **2**(`src/advice_detail.dart` · `src/journal_draft/advice_skip_form.dart`) · 수정 3(더하기만 — `labels.dart` R5c 절 라벨 2 · `ui_journal.dart` export 1줄 · `journal_draft.dart` export 1줄 — 정렬 자리) · R5a·R5b 파일·J-3 파일·그 밖 lib·`apps/`·`domain_contracts`·pubspec 변경 0.
- `test/` 새 파일 6(`advice_detail_fakes.dart` · `advice_skip_fakes.dart` · `advice_detail_test.dart` · `advice_skip_form_test.dart` · `golden/a2_golden_test.dart` · `golden/a4_golden_test.dart`) + 새 PNG 10장(`a2_*` 6 · `a4_*` 4) · 재생성 0 · 기존 fakes 무수정.
- 질문 파일 `A2A4_questions.md`(새 행 A1~A5 «측정:» 반드시).
- 채팅: PR 본문 5섹션 + flutter test 한 줄 · 사전검사 ① 한 번 · ② 두 번(`a2` 6 · `a4` 4) 🔴 0.
- `flutter test` = 시작 기준 N(⟦실측⟧ = R5b 병합본) + 48(뷰 38 + 골든 10 · 드라이런 ⟦실측⟧) · 정적 C12 = 41 · C13 = 15줄 · C14 = 2줄 · C15 = 4 · C20 = 8·8 · C21 = 1·1 · C22 = 23 · C30 = 1 · C32 = 10 A · C33 = 11·8(🔴 정확히) · S05 = 2 · C06 = 1 · C07 = 6 · C36 = 1 · C37 = 1 · C-46 ⑯ = 5파일 · `domain_contracts` «+⟦실측⟧ ~30».
- 재분할 임계(카드 계획): 새 `testWidgets(`·`test(` 줄 21(임계 «> 33» 안) · lib +⟦실측⟧/-0(임계 «> +900» 안 예상) · 새 PNG 10(임계 «> 16» 안) → 재분할 없음 예상.
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것: ⟦실측⟧.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R5c-Bob-A2A4 결과: 브랜치 ui/m6-a2a4 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. 0단계에서 멈췄다면 `R5c-Bob-A2A4 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① `lib/src/advice/**`·`advice_inbox.dart`·`advice_history.dart`(R5b)·`journal_draft_form.dart`(J-3)·`common/**`·기존 테스트·기존 PNG 가 `M` ② `apps/**`·`packages/domain_contracts/**`·다른 `ui_*` 가 `M` ③ `advice_detail.dart` 에 `InkWell`·`DraftStore`·`CommandApi`·`.status`·`.symbol`·`.fillKind`·`.where`·`watchDecisionDetail`·`fillChain`·`FlutterError` ④ `advice_skip_form.dart` 에 `TextField`·`requiresNote`·`AdviceSkipReason.`·`rejectReasonCode`·`'aaq://`·`AppRoutes.`·`watchState`·`FlagIds` ⑤ 예산 코드에 `skipAdvice`·`save` · 비예산 탭 전 `save` ⑥ `.clear(` 가 둘 이상 · `executed` 밖 `clear` · 복원 id `executed` 에 pop ⑦ 체결 행을 묶거나 접음 · 편차 칩을 화면이 만듦 ⑧ 공용 3파일에 삭제 줄 · export 가 끝에 ⑨ C12 ≠ 41 · C13 ≠ 15 · C14 ≠ 2 · C20·C21·C33 이 카드와 다름 ⑩ 테스트에 `name ==`·`opened[0]`·`cleared[0]`·`|| … isTrue`·bool 칸 + if · DTO 생성자 — 하나라도 있으면 반려 신호.
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 만).
- 🔵 C-46 ⑯~㉖ 의 화면 스캔은 파일 이름으로 대상을 고른다(`lib/src/advice_detail.dart` · `lib/src/journal_draft/advice_skip_form.dart`) — 다른 이름이면 «공허 통과» → 제출 ② 의 «C-46 ⑯ 출력» 6줄로 확인한다. ㉓ 은 폼 파일의 **모든** `.clear(` 를 본다(초안 한 곳만 남긴다).
- 🔵 R5d(`A-3`)는 이 카드 병합 뒤 — `JournalLabels.adviceNotFound` · `test/advice_skip_fakes.dart` 의 `FakeAdviceFormRepository`·`adviceFormRefTexts` 를 import 하고 `A-4` 의 제출·초안·잠금 꼴(`_restore`·`_applyReceipt`·`_afterExecuted`·`_locked`)을 본뜬다(이 이름·서명은 R5d 조립의 전제 · 바꾸면 반려 신호).
- 🔵 ⟦실측⟧ R5b 병합 기록 때 채울 것(이 파일의 자리표시자): `__R5A_SQ__`·`__R5B_SQ__`(R5a·R5b squash) · 시작 기준 N(R5b 병합본 실측) · 0단계 R5b 확인 줄 4개(`AdviceCard` 꼴 · 주입 꼴 · R5b 절 끝 상수 이름 · `adviceCardTexts` 서명) · 계약 버전 줄 · 기존 PNG 수(126 예상) · `domain_contracts` 끝 줄 · R5a·R5b C4 이월(머리 «교훈 반영» 줄) · 드라이런 값 전부.
- 범위 고지: 01 §8 미결 115(체결 행 「정정」·접기 — v1 부재) · 116(`M5-6` 진입 맥락 — 예산 코드 목적지) · 53 ⑥ 확장(닫힌 안내의 `A-4` 초안 «버리기» — UI 0)은 이 카드가 닫지 않는다 · 🆕 기록 후보 = 01 §21-8 `A-4` 호출 표에 `AppNavActions.back`(발주자 확인 ⑨) · «부재» 정적 라벨 이름(①).
