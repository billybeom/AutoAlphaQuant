# 발송 패킷 R5a-Bob-L1L2 — L-1 원장 차이 상세 · L-2 정정 이력·감사 (계약 v1.12~v1.14 · prompt_M6 v2 · R5 5장 중 1번째 · M6 X5 읽기)

> ▶ **보낼 수 있음(「푸시해」 뒤)**(2026-10-28 발주자 확인 ①~⑩ = 전부 권고대로 · 이 파일이 GitHub `main` 의 `docs/ai-context/send/` 에 있으면 조건 풀림 — 보낸다 · Bob **새 대화**) — ~~⬜ 조립됨 — 드라이런 ✅ · 발주자 확인 대기~~(2026-10-27 조립 · 2026-10-28 드라이런 지적 반영 · 앱 기록 가지 `rec/r5` · 2026-10-28 발주자 확인 기록 커밋) — 남은 것: ~~① 드라이런~~ ✅(아래 «드라이런» 줄 · 실측 표식 0 — `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R5a-Bob-L1L2.md` = 0 · 🔴 보내기 전에도 0) ~~② 사전검사~~ ✅(드라이런 가지 ① 🔴 0 · 🟡 0 · ② `l` 12 🔴 0 · 🟡 2 = 아래 N3 의 G1 예상분) ~~③ 발주자 확인 10건~~ ✅ 발주자 확인 10건 = 전부 권고대로(2026-10-28 · 발주자 · 🔴 ②·⑨ = K26 꼬리를 덮음 — 발주자 결정 2026-10-28) ~~④ 재분할 판정~~ ✅(새 `testWidgets(`·`test(` 줄 22 · lib +298 · 새 PNG 12 → 재분할 없음) → ✅ 머리 첫 줄 ▶ «보낼 수 있음»(「푸시해」 뒤 보냄).
> 만든 날 2026-10-27 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R5a-Bob-L1L2` 행 + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · PR 본문은 통합 담당이 바꾼다 · 재제출 = 전체판 + 상자 · 골든 높이 = 재량 + 기록(🔴 높이는 늘리지 않는다 · 여백만) · 커밋 = 제목만 맞추기) + 🔵 ✅ **K47 — «R4a C4 이월 부록»·«R4b C4 이월 부록» 두 블록을 이 카드에 옮김**(맨 아래 «6. 이월 부록» · 반영 자리 표) + «R13a C4 이월 부록»·«R13b C4 이월 부록» 의 M6 에 맞는 항목(같은 절) · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-10-22_R5R13선행_계약v1.12_설계서.md` §8-1~§8-3 · K24 · K25 · K26 · K27 · K35 · K47 · K48(✅ 발주자 확정 2026-10-22) · 조문 = `01_…` §21-6 `L-1`·`L-2` 행 · §21-7 · §21-8(위젯·파일·주입·호출 표) · §21-9(상수 진입 `ledgerRepairs`) · §21-10-4 · §21-11 · §21-16-1 · §21-17-2(미결 117 · 121 · 124) · `02_…` §5-1 · §5-2 · §5-2 끝 «계약 v1.12» 블록 ⓐ~ⓔ · 코드 = `packages/domain_contracts`(`LedgerDiffRow` · `LedgerRepairRow` · `LedgerRepository` · `ReasonChip` · `LinkAction` · `ListResult` · `DiffSeverity` · `ChipTone` · `AppRoutes.ledgerRepairs` · 받침대 `UnimplementedLedgerRepository` · `RecordingLinkOpener` · C-47 ⑦).
> 사전 조건 — ✅ 계약 v1.12(PR #68 squash `fb67caf` · 2026-10-22 · `L-1`·`L-2` 표시 필드 · `watchRepairs` · 라우트 `ledgerRepairs` · C-47) · ✅ v1.13(PR #72 `638fca4` · `DiagnosticCell.level` — ui_journal 영향 0) · ✅ v1.14(엔진 E8a PR #73 `ab78a15` · 시세·지표 — ui_journal 영향 0 · `contractVersion = '1.14.0'`) · ✅ `prompt_M6` v2(앱 `34bf60a` · 275줄 · 머리 3행 «판 v2») · `origin/main` = `4bb7067`(E8c PR #75 · ui_journal·domain_contracts lib 무변경). 시작 기준 = `origin/main` `4bb7067` 의 `flutter test`(packages/ui_journal) = **388**(2026-10-27 실측 · README 388 과 같음) · 이 카드 끝 기대 = 시작 기준 N + **뷰 30(L-1 15 + L-2 15) + 골든 12 = 430**(드라이런 실측 2026-10-28 — 조립 판 29 + L2-05 셋째 경우 `slice_empty` 1) · `domain_contracts` «+392 ~30»(E8c 병합 커밋 실측 · 이 카드 몫 0).
> 카드 기본값(카드 권한 — ✅ 아래 «발주자 확인» ①~⑩ = 권고대로 확정(2026-10-28 · 발주자)): ⓐ 위젯 = `LedgerDiffs({super.key})`(`lib/src/ledger_diffs.dart` · ConsumerWidget) + 공개 조각 `LedgerDiffTile({super.key, required LedgerDiffRow row})`(같은 파일 · ConsumerWidget · `L-3`(R5e) 결과가 재사용) · `LedgerRepairs({super.key})`(`lib/src/ledger_repairs.dart` · ConsumerWidget) ⓑ 주입 2 = `journalLedgerRepositoryProvider` · `journalLedgerTrustRepositoryProvider`(둘 다 `ledger_diffs.dart` 머리 · 배럴 쪽 · 01 §21-8 글자 그대로 · 신뢰 창구는 선언만 — R5e 가 import) · 데이터 2 = 각 파일 안 private StreamProvider ⓒ 구독 = `watchOpenDiffs()`(L-1) · `watchRepairs()`(L-2 · 🔴 인자 없이 = 기본 50) + 기존 `journalSafetyStateProvider`(배너) · 🔴 **재구독 0 · `hasMore` 무시**(①) ⓓ `L-1` 하단 = `AppRoutes.ledgerRepairs` 상수 진입(01 §21-9 규칙 ④) · 행 조치 = `actionLink`(null = 부재) ⓔ 색 = `DiffSeverity` 전수 switch 하나(아이콘 + 색 · `L-1`) + `L-2` 방향 배지 = 공용 `journalToneColor(context, row.directionTone)`(새 switch 0) · `statusLabel` 은 style 없는 Text(accepted = resolved 같은 비중 — ④) ⓕ `applicable` 읽지 않음(②) ⓖ 체인 스탬프 = Text + 복사 `IconButton`(`Clipboard.setData` · SnackBar 0 — ③) ⓗ 정적 라벨 3(⑤) ⓘ Key 접두 `l1-`·`l2-`(순번만 · `LedgerDiffTile`·L-2 행 안 Key 0) ⓙ 테스트 = `test/ledger_fakes.dart`(새 · 자기 파일) · `test/ledger_diffs_test.dart` · `test/ledger_repairs_test.dart` · 골든 6이름 12장(`l1_golden_test.dart` 4 · `l2_golden_test.dart` 2 · 크기 `l1` = `Size(390, 844)` · `l2` = `Size(390, 1200)` — ⑥) ⓚ 공용 파일 2(`labels.dart` R5a 절 · 배럴 export 2줄 — 정렬 자리) = **더하기만**.
> 🔴 **카드 덮개 필수 문장(02 §5-1 · §5-2 · §5-2 끝 v1.12 블록 · 01 §21-6 · §21-7 · §21-8)** — «`L-1`·`L-2` 는 받은 글자·칩·링크만 그린다 — 받은 순서 그대로 · 거르기·묶기·재정렬·세기 0 · 원값(`candidateOriginCodes`·`originCode`·`directionCode`·`decisionId`·`appliedAt`·`recomputedFrom`·`diffId`·`repairId`·`.name`·`.wire`)은 표시·분기 0 · 색 = 열거 switch 만» · «정정 UI 를 만들지 않는다 — 정정 진입 = 행 `actionLink`(엔진이 고른 조치 1개 · null = 부재) · 되돌리기·삭제·수정 버튼 0 · 원본을 숨기지 않는다 · 들여쓰기 = `supersedes != null` 하나» · «화면은 플랫폼을 모른다 — `L-2` 본문 Android 만 = 셸 가드(R13a 완료)». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — K24(`watchRepairs` 창구) · K25(L-2 자리 · 계단 = 엔진 순서) · K26(L-1 자리 · 근거 = 해시만 · 조치 = `actionLink`) · K27(라우트 `ledgerDiffs`·`ledgerRepairs` · L-2 본문 Android 만) · K35(R5 5분할 · R5a 12장) · K47(R4a·R4b 이월 부록 → R5a) · K48(`extraFixture` — R5a 는 쓰지 않음) = **✅ 발주자 확정(2026-10-22 · 01 §21-14)**.
> ✅ **발주자 확인 10건 = 전부 권고대로(2026-10-28 · 발주자)** — 확정 값 = 각 항의 권고 글자(권고가 따로 없는 항 = 카드 기본값 · 대안은 쓰지 않는다 · 항목 글자는 판독 원문 그대로) · ~~🔵 발주자 확인 대기 10건(카드 기본값 = 권고 · 🔴 확인 전 ▶ 금지)~~: ① 🔴 **`hasMore`·무한 스크롤** — prompt_M6 v2 144행 «무한 스크롤은 `limit += 100` 재구독 하나뿐» ↔ 01 §21-8 호출 표 «`watchOpenDiffs()` · `watchRepairs()`»(인자 없음 · `watchOpenDiffs` 에는 `limit` 인자 자체가 없다) → 권고 = **v1 재구독 0 · `hasMore` 를 읽지 않는다**(`L-1` = 전체 목록 1화면 · `L-2` = 기본 50행 · 표본 `has_more` 전부 false) + 01 §8 미결 신설 «X5·X7 목록의 `hasMore`(L-2 `watchRepairs(limit:)` · A-1 `watchInbox(limit:)`)» · 대안 = `L-2` 만 끝에서 `limit += 100` 재구독(엔진 표본 0 · 테스트 경우 +2) ② 🔴 **`applicable == false` — 이 권고는 확정 조문을 덮는다**(✅ K26 꼬리를 덮음 — 발주자 결정 2026-10-28 · 권고대로): 01 §21-14 K26 꼬리 «`applicable == false` = `deltaLabel` 문장만(04:523)» · 02 §5-2 끝 v1.12 ⓑ · 02 §5-1 «「해당 없음」 문구만 렌더하고 0·`-` 로 채우지 않는다» · C15(자동 모드 canonSelfReport 칸) · prompt 220행 → 권고 = **화면이 `applicable` 을 읽지 않는다**(엔진이 «해당 없음» 문장을 `deltaLabel` 로 싣고 화면은 같은 자리를 그대로 그림 · 나머지 자리(심각도·상태·경로·근거 해시)도 그대로 그려진다 · L-1 입력 표본 4벌 전부 `applicable: true` · `self_report_diff_result` 도 true — 갈래를 만들어도 잡을 표본 0 · 정적 L07 `\.applicable\b` 금지) + 01 §21-6 L-1 행 정정 후보·01 §8 미결 신설 «L-1 `applicable == false` 표본(canonSelfReport · autoTrade)» · 대안 ⓐ = **K26 대로** — `LedgerDiffTile` 에서 `row.applicable` 이 false 면 `Text(row.deltaLabel)` 하나만(엔진 불 값 읽기 — `isUrgent`·`deferAvailable` 꼴 · L07 에서 `\.applicable\b` 를 뺌) + 표본(M2 `m6/ledger_diffs_not_applicable` 선행 PR 또는 copyWith 예외 1 — R13b `h01_advice_zero` 선례) + L-1 테스트 1·예고 변이 1(→ 카드 수정 + 재드라이런 1회) ③ `chainStampText` «표시·복사»(02 §5-2 ⓒ) → 권고 = Text + 복사 `IconButton(Icons.copy)` → `Clipboard.setData`(피드백 SnackBar 0 — 본문 위젯은 ScaffoldMessenger 를 쓰지 않는다) · 대안 = `J-2` 꼴 길게 누르기 + `JournalLabels.copied` SnackBar ④ «accepted = resolved 같은 비중»(02 §5-1 (b)) → 권고 = `statusLabel` 은 style·Opacity 없는 Text 하나(세 상태가 같은 꼴 — 색·아이콘은 심각도 switch 만) ⑤ 정적 라벨 3(`ledgerRepairsLink` «정정 이력» · `ledgerCandidateOrigins` «원인 후보» · `ledgerEvidence` «근거») ⑥ 골든 크기 — `l1` = `Size(390, 844)`(= `kGoldenPhoneSize` 와 같은 높이 · 행 1개 · 드라이런 맨 아래 dy 최대 412.0) · `l2` = `Size(390, 1200)`(행 4 · 드라이런 맨 아래 dy 최대 964.0 · light = dark) = 카드 확정값(권고 그대로 · 여백 무수정) ⑦ `L-2` 의 iOS·웹 = 셸 «폰에서만»(R13a 배선 완료 · 화면 코드 0 · 테스트 0) ⑧ K47 부록의 후보 항목(C4r4a-2~7 · C4r4b-1~7)은 이 카드 규칙·테스트 지시에 반영했다(맨 아래 «6» 표) · C4r4b-8(계약 PR 후보)은 부록 그대로 ⑨ 🔴 🆕 **`RepairRoute` 색 — 이 권고도 확정 조문을 덮는다**(✅ K26 꼬리를 덮음 — 발주자 결정 2026-10-28 · 권고대로 = v1 경로 색 생략): K26 꼬리 «색 = `DiffSeverity`·`RepairRoute` exhaustive switch(C-12)» · 02 §5-1 «경로 배지 3종(auto · approval · x1Emergency)» ↔ 카드 = `routeLabel` 은 style 없는 Text(RepairRoute switch 0 · 정적 L09 = DiffSeverity 2줄) → 권고 = v1 경로 색 생략(경로 글자 = 엔진 `routeLabel` 그대로 · 01 §21-6 L-1 행 정정 후보로 기록) · 대안 = `_routeLook(ColorScheme, RepairRoute)` 전수 switch 하나(3값 · default 0) + `routeLabel` 을 Chip(backgroundColor) 으로 + L1-02 경로 색 단언 + 예고 변이 «경로 색 하나로 고정» + L09 기대 5줄(→ 카드 수정 + 재드라이런 1회) ⑩ 🆕 M2 후보 3건(이 카드 판정 밖 · ▶ 를 막지 않음 · 01 §8 미결 신설 후보로 기록만): ⓐ L-1 `emptyLabel` non-null 표본(드라이런 변이 «L-1 빈 문장 글자 바꾸기» = 표본 0 으로 생존 → 예고 변이에서 L-1 몫은 «참고») ⓑ L-1 칩 0 표본(변이 «칩 Wrap 을 칩 0 이면 숨김» 생존) ⓒ C-47 ⑦ 에 `'aaq://` 리터럴 검사(변이 «하단 링크를 같은 값 리터럴로» = 테스트·C-47 통과 · 정적 L04 만 잡음) → 권고 = 기록만.
> 드라이런: ✅ 2026-10-28 · worktree `C:/Work/AAQ-claude-r5dry` · 가지 `dry/r5a`(`origin/main` `4bb7067` + 이 기록 커밋 `31ac3e3` → 권장 5커밋 `92f83f2`·`298f396`·`26c7372`·`28cfa06`·`053a483` → 지적 반영 1커밋 `1790c94`(L2-05 `slice_empty` · `ledgerRepairSlice` · 전제 1) · 기준 = `31ac3e3`) — 0단계 확인 줄 전부 기대대로(`git grep` 12줄 «:1» · README `l2_chain_two_repairs` «:2» · `ls` 8 있음 · 없어야 할 5 없음) · 시작 «00:24 +388» → 끝 «00:24 +430: All tests passed!»(N + 뷰 30 + 골든 12) · 파일별 «+15»(ledger_diffs_test) · «+15»(ledger_repairs_test) · «+8»(l1_golden) · «+4»(l2_golden) · `domain_contracts` «+392 ~30» · C-47 ⑦ 3줄 = 기대 그대로 · check_boundaries 실패 0(🟡 기존 timeline.dart:109 1) · format 0 changed · analyze No issues · 사전검사 ① 🔴 0 · 🟡 0 · ② `l` 12 = 🔴 0 · 🟡 2(G1 `l2_chain_two_repairs` light·dark — N3) · 정적 묶음 32줄 → 출력 125줄(bash = PowerShell 5.1) = 아래 «줄의 뜻과 기대» 그대로 · import 차례 = 아래 «주입 구조» 글자 그대로(analyze 확정) · 골든 `l1` 844 · `l2` 1200 · 맨 아래 dy(light = dark) `l1_broker_qty` 412.0 · `l1_cash_observe` 404.0 · `l1_accepted` 364.0 · `l1_push_lag` 364.0 · `l2_chain_two_repairs` 964.0 · `l2_empty` 76.0 · 머리 dy 전부 0.0 · 열어 본 PNG 6(light) · 새 testWidgets·test 줄 22 · lib +298/-0 · 새 PNG 12 · 변이 = 예고 55꼴 중 KILLED 52(지적 반영 뒤 «L-2 emptyLabel null 에도 빈 자리» 포함) · 참고로 내린 3 SURVIVED(L-1 빈 문장 = 표본 0 · 칩 0 = 표본 0 · applicable = 정적 L07 몫) · 참고 변이 8 중 KILLED 6 · SURVIVED 2(링크 리터럴 = 정적 L04 몫 · Key 없는 빈 자리 = 잡는 검사 0) · 테스트 쪽 변이 2(else 지움 · 늘 참 단언) = 사전검사 ① T1·T3 🔴 · 질문 파일 A1~A6 «측정:» + A7(L1-03 행 0 좁히기) · A8(L2-06 Key 목록) → 이 카드 글자에 반영함.
> 프롬프트 = `docs/ai-context/prompt_M6.md`(🆕 **v2 판 275줄** · 2026-10-26 재조립(설계 07 v2) · 2행 `{{범위}}` = «R5a~R5e 중 붙여넣은 카드 한 장의 범위» · 121행 «이번 과제 범위» → 이 카드가 덮는다(R5a = `L-1` · `L-2`) · 130행 PR 제목 = 형식만 → 이 카드의 제목 «[M6] L-1·L-2 원장 차이·정정 이력»(«■ 제출») · 자체 점검 23항 = 252~274행 · 수치·금액 조문 = 68~74행). 🔴 Bob **새 대화** 전제 — R4b·R13 대화를 기억하지 못합니다. 0단계·규칙 요약·본받지 않는 것·스케치·테스트 목록은 본문에 담았습니다.
> R4·R13 교훈 반영(맨 아래 «6» 표): PNG 열람 = 이름마다 light 1장(6장 — 이미지 20장 한도) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) · 구독마다 «로딩·에러 × 갈래» · 골든·테스트 흐름 = 클로저 칸 · 기대 링크 = 목록 칸(`opener.opened == <String>[…]`) · 🔴 bool 칸 + if · `name ==`·`which ==` 경우 비교 · `opened[0]` 원소 비교 · if 를 단언 안으로 감추기(`expect(a || b, isTrue)`) = 반려 꼴 · 전제는 if 밖 + `// pre` · 픽스처 = `main()` 머리 `final` · 가짜 공장 = `call` 삼항 · 커밋마다 `git add <파일>` · «23항 줄 수» 상자 · 골든 높이 = 카드 확정값(늘리지 않는다 · 여백만 + 측정 행) · lib 의 nullable `!` 0 · 주입 절 = 파일 머리(import 바로 뒤) · «화면 Text 전부» 허용 집합에 링크·경로 문자열 0.

## 0. 한 줄 목적

`LedgerDiffs()` 가 `watchOpenDiffs()` 의 차이 행을 받은 순서 그대로 공개 조각 `LedgerDiffTile` 로 그리고(글자 · 원인 후보 칩 · 근거 해시 · 조치 `actionLink` · 심각도 색 = 열거 switch · 하단 «정정 이력» = `AppRoutes.ledgerRepairs`), `LedgerRepairs()` 가 `watchRepairs()` 의 정정 행을 받은 순서 그대로(들여쓰기 = `supersedes != null` · 방향 배지 색 = 공용 tone · 체인 스탬프 표시·복사 · 결정 링크 = `decisionLink`) 그리는 X5 읽기 두 화면을 계약 v1.12 그대로 짓기(정정 UI 0 · 원값 0 · 쓰기 0).

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-l1l2-recon`**(base = 최신 `origin/main` · `--no-track` · 브랜치 이름 = 설계 12 §3 R5a 행 · 01 §21-16-1 글자 그대로).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 머리 첫 줄이 ⬜(드라이런 대기)입니다.
2. Bob 에 R4b·R13b 를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R5a-Bob-L1L2.md> (🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다 · `send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R5a-Bob-L1L2 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 🔵 이 카드는 바깥 울타리를 **백틱 네 개**로 둡니다(안의 «23항 줄 수» 상자가 백틱 세 개를 쓰기 때문 — GitHub 화면에서도 상자가 끊기지 않습니다) · 울타리·구분선은 넣지 않습니다 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R4b-Bob-H62H63*.md` · `_완료/R13b-Bob-H01*.md` 를 붙여넣지 않습니다 · `send/_대기/R5b-Bob-A1.md` 는 R5a 병합 뒤 카드입니다.

## 3. 붙여넣을 본문 — ````text 다음 줄(«R5a-Bob-L1L2 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R5a-Bob-L1L2 — 범위: L-1 원장 차이 상세(LedgerDiffs() + 공개 조각 LedgerDiffTile(row:) — 머리 · 오래됨 · 배너 · 차이 행 · 빈 문장 · 하단 «정정 이력») ·
  L-2 정정 이력·감사(LedgerRepairs() — 머리 · 오래됨 · 배너 · 정정 행(들여쓰기 · 방향 배지 · 체인 스탬프 복사 · 결정 링크) · 빈 문장) + 주입 2 + 정적 라벨 3 + 배럴 export 2줄.
🔴 두 화면은 받은 글자·칩·링크만 그린다 — 받은 순서 그대로 · 거르기·묶기·재정렬·세기 0 · 원값(candidateOriginCodes · originCode · directionCode · decisionId · appliedAt · recomputedFrom · diffId · repairId · .name · .wire) 표시·분기 0 · 색 = 열거 switch 만.
🔴 정정 UI 를 만들지 않는다 — 정정 진입 = 행 actionLink(엔진이 고른 조치 1개 · null = 부재) · 되돌리기·삭제·수정 버튼 0 · 원본을 숨기지 않는다 · 들여쓰기 = supersedes != null 하나.
🔴 화면은 플랫폼을 모른다(kIsWeb · Platform. 0) — L-2 본문 Android 만 = 셸 가드(R13a 가 이미 배선) · 이 카드 코드·테스트 0.
하지 않는 것: A-1~A-4 · L-3(R5b~R5e) · 정정 마법사 · 필터(미결 117) · J-3R 링크·J-2 배지 진입(미결 121) · 쌍·차이 단위 착지(미결 124) · 무한 스크롤 · domain_contracts·pubspec 수정 · 다른 ui_* · 셸 · 기존 ui_journal 화면·테스트 수정.
🔴 이 카드가 docs/ai-context/prompt_M6.md(판 v2) 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 22항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R4b·R13b(병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_journal/lib/src/ledger_diffs.dart · ledger_repairs.dart · LedgerDiffs · LedgerRepairs 가 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m8-h01-home 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m6-l1l2-recon origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git grep -c "contractVersion = '1.14.0'" -- packages/domain_contracts/lib/src/contract_version.dart                          ← «…contract_version.dart:1»
  git grep -c "Stream<ListResult<LedgerDiffRow>> watchOpenDiffs();" -- packages/domain_contracts/lib/src/repositories/ledger_repository.dart   ← «…ledger_repository.dart:1»
  git grep -c "Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50});" -- packages/domain_contracts/lib/src/repositories/ledger_repository.dart   ← «…ledger_repository.dart:1»
  git grep -c "required String chainStampText," -- packages/domain_contracts/lib/src/dto/ledger.dart                            ← «…ledger.dart:1»
  git grep -c "LinkAction? actionLink," -- packages/domain_contracts/lib/src/dto/ledger.dart                                   ← «…ledger.dart:1»
  git grep -c "class UnimplementedLedgerRepository implements LedgerRepository" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»
  git grep -c "static const String ledgerRepairs = " -- packages/domain_contracts/lib/src/navigation/app_links.dart           ← «…app_links.dart:1»
  git grep -c "C-47 ⑦ 대상" -- packages/domain_contracts/test/contracts/c47_ledger_ops_test.dart                               ← «…c47_ledger_ops_test.dart:1»(화면 소스 스캔이 이 두 파일을 본다)
  git grep -c "final journalLinkOpenerProvider = Provider<AppLinkOpener>(" -- packages/ui_journal/lib/src/timeline.dart       ← «…timeline.dart:1»
  git grep -c "Color journalToneColor(BuildContext context, ChipTone tone)" -- packages/ui_journal/lib/src/common/journal_common.dart   ← «…journal_common.dart:1»
  git grep -c "class FakeHoldingsSafetyRepository extends UnimplementedSafetyRepository" -- packages/ui_journal/test/holdings_overview_fakes.dart   ← «…holdings_overview_fakes.dart:1»(import 해서 쓴다)
  git grep -c "판 v2" -- docs/ai-context/prompt_M6.md                                                                       ← «…prompt_M6.md:1»(프롬프트 v2 — 아래 줄 번호가 이 판 기준 · 없으면 멈춤)
  git grep -c "l2_chain_two_repairs" -- packages/ui_journal/test/golden/README.md                                            ← 숫자 하나(golden README «🆕 R5» 절)
  ls docs/ai-context/send/R5a-Bob-L1L2.md                                            ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/L1L2_questions.md                                         ← 보여야 함(빈 표가 이미 있다)
  ls tool/precheck.dart                                                              ← 보여야 함
  ls packages/domain_contracts/fixtures/ledger_diffs_4.json                          ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/ledger_diffs_cash_observe.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/ledger_repairs_4.json                     ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/ledger_repairs_empty.json                 ← 보여야 함
     (🔴 경로는 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 카드가 계약보다 먼저 왔습니다 · && 가 안 되는 셸이면 한 줄씩)
  아래 다섯 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 R5a 가 들어간 것 — 멈추고 알림):
  ls packages/ui_journal/lib/src/ledger_diffs.dart                                   ← 없어야 함
  ls packages/ui_journal/lib/src/ledger_repairs.dart                                 ← 없어야 함
  git grep -c journalLedgerRepositoryProvider -- packages/ui_journal                 ← 출력 없음이어야 함
  git grep -c "l1-" -- "packages/ui_journal/*.dart"                                  ← 출력 없음이어야 함
  git grep -c "l2-" -- "packages/ui_journal/*.dart"                                  ← 출력 없음이어야 함
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · 브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_journal
  flutter test   ← 시작 기준: origin/main 전부 통과 · 0 실패 · 기대 «+388: All tests passed!»(앞 시각은 달라도 된다)(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · 다르면 멈추지 말고 PR 본문에 까닭 한 줄 —
                   그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스·testing.dart·AppRoutes·C-47) > 이 카드(지시) > 01 §21 > 02 §5-2 끝 v1.12 블록 > 02 §5-1·§5-2 본문·그림 M6-20~22 > prompt_M6.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox/L1L2_questions.md 만. 새 파일 = lib/src/ledger_diffs.dart · lib/src/ledger_repairs.dart · test/ledger_fakes.dart ·
   test/ledger_diffs_test.dart · test/ledger_repairs_test.dart · test/golden/l1_golden_test.dart · test/golden/l2_golden_test.dart · 새 PNG 12.
   공용 2파일은 **더하기만**(기존 줄 한 글자도 바꾸지 않는다 · 정적 L25 의 삭제 수 0): lib/l10n/labels.dart = JournalLabels 안 R4b 절의 마지막 상수(holdingsNextRebalance) 뒤 · 닫는 } 앞에 R5a 절 ·
     lib/ui_journal.dart = export 두 줄(🔴 끝이 아니라 정렬 자리 — export 'src/ledger_diffs.dart'; · export 'src/ledger_repairs.dart'; 를 export 'src/journal_read.dart'; 와 export 'src/timeline.dart'; **사이**에 이 차례로 · 끝에 두면 directives_ordering 실패).
   고치면 반려: 그 밖의 ui_journal 파일 전부(lib/journal_draft.dart · lib/src/common/** · lib/src/timeline.dart · lib/src/holdings_overview.dart · 그 밖 lib · 기존 테스트 파일 전부(🔴 test/holdings_overview_fakes.dart 도 import 만) ·
     golden_support.dart · golden README · flutter_test_config.dart · goldens/ 의 기존 PNG 98장 · pubspec.yaml · analysis_options.yaml · README.md) · domain_contracts/** · apps/** · 다른 ui_*.
 2 두 화면은 받은 글자와 null 여부만 본다 — 값 = DTO 의 *Label·*Text·label·deltaLabel·evidenceHash·chainStampText 원문 그대로 · 원값·.wire·.name·코드 표시 금지 · 폴백 문구 금지 ·
   색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = labels.dart 의 JournalLabels 에만(테스트에도 금지) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱만).
 3 읽지 않는 필드(카드가 정함 — 질문 아님): ListResult 의 hasMore · emptyKind(🔴 빈 갈래 = rows.isEmpty ∧ emptyLabel non-null 하나) ·
   LedgerDiffRow 의 diffId · pair · axis · authoredDate · candidateOriginCodes · status · route · applicable(🔵 엔진 글자 그대로 — 발주자 확인 ②) · severity(🔵 색·아이콘 switch 에만) ·
   LedgerRepairRow 의 repairId · diffId · directionCode · originCode · decisionId · evidenceHash(🔵 L-2 는 그리지 않는다 — L-2 자리는 chainStampText) · recomputedFrom · appliedAt · supersedes(🔵 != null 들여쓰기에만) ·
   ReasonChip 은 JournalReasonChip 이 그린다 · SafetyState 는 JournalSafetyBanners 가 그린다(화면 파일은 safety 를 넘기기만).
   🔴 C-47 ⑦ 이 두 화면 파일의 .candidateOriginCodes .originCode .directionCode .decisionId .appliedAt .recomputedFrom .diffId .repairId .wire .name · 객체 패턴 구조 분해 · .where/.firstWhere/…/.sort/.fold/.reduce/groupBy ·
     CommandApi · DraftStore · .watchState( · AppRoutes.(ledgerRepairs 밖) · kIsWeb · Platform. · defaultTargetPlatform · TargetPlatform. · .platform 을 기계로 본다(주석은 벗기고 본다).
 4 이동 = AppLinkOpener.open(link) 하나(ref.read(journalLinkOpenerProvider) · 탭 콜백 안) — 링크 = 아래 «화면» 의 세 자리뿐: L-1 행 action.deepLink · L-1 하단 AppRoutes.ledgerRepairs · L-2 행 link.deepLink ·
   원인 후보 칩 탭 = JournalReasonChip 이 안에서 연다(이 카드 코드 0) · 🔴 lib·테스트에 'aaq://'·'handbook://' 리터럴 0 · 링크 조립·파싱 0 · 링크 null = 부재(비활성 아님) · Navigator 0 ·
   공개 위젯 생성자 = LedgerDiffs({super.key}) · LedgerDiffTile({super.key, required this.row}) · LedgerRepairs({super.key}) 셋뿐(콜백·다른 인자 0).
 5 산술·판정 0 — 허용되는 것은 셋뿐이다: ⓐ 신선도 한 식(list.asOf.observedAt.add(list.asOf.staleAfter).isBefore(clock.nowUtc())) ⓑ 빈 갈래 = list.rows.isEmpty ⓒ 들여쓰기 = row.supersedes == null ? 16 : 40.
   그 밖에 거르지도 세지도 정렬하지도 자르지도 묶지도 옮기지도 않는다(받은 순서 · 순번 = .indexed 의 i) · 목록 길이·int 를 글자로 0 · maxLines · TextOverflow · FittedBox · .trim( · .take( 0 · DateTime.now 0 · 날짜 차이 0 ·
   FeatureFlags · RunMode · OperatingMode 0(두 화면은 모드를 모른다) · 칩 목록이 비어도 Wrap 을 그대로 둔다(빈 Wrap = 칩 줄 0 · «비었으면 숨김» 갈래 0 — C4r4a-5 한 뜻).
 6 switch 는 열거값 전수(C-12 · default 0): DiffSeverity 2값 한 곳(L-1 심각도 아이콘·색 _severityLook) — 하나뿐. L-2 방향 배지 색 = 공용 journalToneColor(context, row.directionTone)(common 에 이미 있는 ChipTone switch · 새 switch 0).
 7 시계 = journalClockProvider(주입 Clock.nowUtc() 만) · 공통 조각 = JournalAsOfHeader · JournalStaleBanner · JournalSafetyBanners · JournalReasonChip · JournalSkeleton · JournalErrorView 재사용(🔴 무수정 · 상대 경로 import · 새 공용 조각 0 · 공개 조각은 LedgerDiffTile 하나) ·
   상태 갈래 = 아래 «상태 표» 글자 그대로(구독마다) · 스피너 금지 · 배너 = ref.watch(journalSafetyStateProvider).valueOrNull 을 JournalSafetyBanners(safety:) 에 넘기기만(🔴 .watchState( 0 · FlagIds · activeFlags 0).
 8 두 화면은 본문이다 — Scaffold · AppBar · SafeArea · ScaffoldMessenger · SnackBar · Navigator 0(주석에도) · ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 ·
   간격·크기는 정수·N.0 만 · 띠 높이 예약 0 · 엔진 문자열이 이미 말한 것을 정적 제목으로 다시 말하지 않는다.
 9 프로바이더 — 이름·타입·파일 = 아래 «주입 구조» 글자 그대로 · autoDispose 0 · 주입 2(ledger_diffs.dart 머리 · import 바로 뒤 · 데이터 프로바이더보다 앞 · 기본값 throw) · 데이터 2(각 파일 안 private StreamProvider) ·
   기존 journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider(timeline.dart)는 import 해서 쓴다 · 🔴 journalTimelineRepositoryProvider · journalConfigRepositoryProvider · journalCommandApiProvider · journalDraftStoreProvider 0 ·
   주입은 탭 핸들러 안 ref.read · 데이터는 build 에서 ref.watch · lib 의 nullable 에 ! 0(null 검사 뒤 지역 변수 · collection-for 안에서 지역 변수가 필요하면 private 조각으로 — 정적 L32).
10 테스트 = 받침대 extends(UnimplementedLedgerRepository · R4a 의 FakeHoldingsSafetyRepository 재사용 — import 만 · implements 금지) · 받은 인자 전부 기록 · 호출마다 새 Stream ·
   가짜 공장 = 받은 call 로 삼항(call == 0 ? Stream<T>.error(StateError('fail')) : Stream<T>.value(v) — C4r4b-7) · 따로 세는 변수 0 · 공장 안 early-return if 0 ·
   픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지 · C4r4b-6) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다(C4r4b-1) — 자리 = testWidgets 본문 첫머리
     (main() 바로 아래의 expect 는 테스트 밖이라 파일 적재가 OutsideTestException 으로 실패한다) · 전제 문장마다 끝에 `// pre`(ASCII · 정적 L30 이 센다 = 최소 목록의 «(전제)» 수 · C4r4b-2) · 동작은 UI 를 실제로 눌러서 ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1 ·
   DTO 를 지어 넣지 않는다(픽스처에서 — LedgerDiffRow(…) · LedgerRepairRow(…) · ListResult(…) 생성자 0) · 🔵 예외 1 = 행 슬라이스(테스트의 입력 준비 · golden_support 의 journalSlice 꼴): ledger_fakes.dart 의 ledgerDiffSlice · ledgerRepairSlice 두 곳만 copyWith(정적 L27 2줄) ·
   링크는 RecordingLinkOpener 를 픽스처 값·상수와 비교 · 기대 링크 = 경우 칸의 목록(expect(opener.opened, c.opened) — 🔴 opener.opened[0] 류 원소 비교 금지 · 탭 한 번에 두 번 여는 변이를 못 본다) ·
   🔴 흐름(탭·링크 단언)은 경우 칸의 클로저(Future<void> Function(WidgetTester) steps)에 · bool 칸 + if 로 흐름을 가르는 꼴 · c.name == · which == 같은 이름 비교 · if 를 단언 안으로 감추는 꼴(expect(a.isEmpty || …, isTrue)) = 반려(정적 L31) ·
   경우마다 갈리는 단언은 «없는 쪽» 견본(if/else 양쪽 단언) 또는 expect(finder, c.<Matcher 칸>) 한 꼴 · 테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII ·
   «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2 · for (… in <T>[?x]) · ?.let 류로 감추는 것도 반려) · 단언은 «X 0 · Y 0» 처럼 따로(«X 0(Y 0)» 괄호 단언 금지 — C4r13a-2) ·
   스켈레톤 1 = expect(find.byKey(const Key('l1-loading')), findsOneWidget) 꼴 · 테스트는 package:ui_journal/src/common/journal_common.dart 를 직접 import 해도 된다(journalToneColor · JournalReasonChip — R4b 선례) · Key 를 단 묶음의 글자 = ledgerShownTexts(tester, <Finder>) == 기대 목록(트리 순서) · 겹쳐 나오는 정적 라벨 = find.text(<라벨>) findsNWidgets(<행 수 리터럴>)(C4r4a-4) ·
   늦게 구독되거나 값을 끝까지 내지 않는 스트림 = Stream<T>.fromFuture(Completer<T>().future)(값도 끝도 없다 · teardown 0) · StreamController 를 쓰면 addTearDown(() { unawaited(ctrl.close()); }).
   ⓡ = 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 **앞**의 expect(<목록>, hasLength(n)); 한 줄 — 🔴 n = 정수 리터럴(행 4 · 칩 2 — 같은 목록에서 센 수와 맞대면 늘 참이다) ·
      끝 Key 도 리터럴(l1-row-4 · l2-row-4) · 도우미로 감싸지 않는다 · 🔴 hasLength( 는 ⓗ 줄에만(전제에는 쓰지 않는다 — .length 비교 또는 집합 비교) ·
      정적 L17·L18 이 파일마다 git grep -c 로 센다 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(ledger_diffs_test.dart ⓡ 10 · ⓗ 2 · ledger_repairs_test.dart ⓡ 8 · ⓗ 1 · 다르면 제출 전에 고친다 · 다른 채 내면 반려).
   «없는 쪽» 견본(코드 글자 · 이름은 재량):
        final String? want = c.want;                      // 경우 칸 = 기대 글자 String?(broker_qty = full.rows[0].actionLink!.label · push_lag = null)
        if (want != null) {
          expect(ledgerShownTexts(tester, find.descendant(of: find.byKey(const ValueKey<String>('l1-row-0')), matching: find.byType(FilledButton))), <String?>[want]);
        } else {
          expect(find.descendant(of: find.byKey(const ValueKey<String>('l1-row-0')), matching: find.byType(FilledButton)), findsNothing);
        }
        await c.steps(tester);                             // 흐름 = 클로저 칸(없음 = (WidgetTester t) async {})
        expect(opener.opened, c.opened);                   // 기대 링크 = 목록 칸(없음 = <String>[])
        🔴 반려 꼴: if (want != null) { expect(…); }(else 없음) · if (want != null) { await tester.tap(…); expect(opener.opened, …); }(흐름이 if 안) · if (x != null) { expect(x, isNotNull); … }(if 안의 전제 = 늘 참) ·
           if (c.name == 'broker_qty') {…} · expect(opener.opened[0], …) · expect(data.isEmpty || allowed.contains(data), isTrue)
   «빈 문장» 견본(Key 를 단 빈 문장 — 경우 칸 = 기대 글자 String? · C4r4a-1):
        final String? wantEmpty = c.empty;                 // 빈 갈래 = empty.emptyLabel · 그 밖 = null
        if (wantEmpty != null) {
          expect(tester.widget<Text>(find.byKey(const Key('l2-empty'))).data, wantEmpty);
        } else {
          expect(find.byKey(const Key('l2-empty')), findsNothing);
        }
   «화면의 Text 전부» 단언 = 이 코드 글자 꼴(L1-11 · L2-09 · C4d-1):
          final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
          expect(shown, isNotEmpty);
          for (final String? data in shown) {
            expect(data, isIn(allowed));
          }
        (allowed = ledger_fakes.dart 의 ledgerDiffsAllowed · ledgerRepairsAllowed — null-aware 원소로 만든 Set<String> · 🔴 링크·경로 문자열(deepLink · aaq:// · handbook://) 0 — 화면에 링크 글자가 나오면 잡히게 ·
         RichText · SelectableText · Text.rich 는 두 화면 파일에 쓰지 않는다 = 정적 L22)
11 골든 = 새 PNG l1_* 8장 + l2_* 4장 · --update-goldens 는 그 두 골든 테스트 파일만 · 기존 PNG 98장 재생성 0 · golden:approved 안 붙임 · 찍기 전 위치 전제 둘(아래 «골든» 코드 글자) · 🔴 높이(_kTallPhone)는 늘리지 않는다(카드 확정값).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 ·
   패키지 테스트는 packages/ui_journal 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · prefer_final_locals · unnecessary_lambdas.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(두 화면에는 그런 산술이 없다 — 들여쓰기 16 : 40 은 삼항 · 연산자 0).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — 두 화면 파일의 주석에 이 낱말을 쓰지 않는다: DateTime.now · kIsWeb · Platform. · dart:io · HoldingPnl · FeatureFlags · RunMode · CommandApi · DraftStore · watchState · activeFlags · FlagIds ·
   candidateOriginCodes · originCode · directionCode · decisionId · recomputedFrom · diffId · repairId · appliedAt( · .name · .wire · applicable · watchExternalHoldings · NumberFormat · toString( · Navigator · ScaffoldMessenger · SnackBar · Scaffold · AppBar · SafeArea ·
   RichText · SelectableText · maxLines · TextOverflow · .trim( · .take( · .where · .sort · autoDispose · Colors · 'aaq:// · journalLinkOpenerProvider · watchOpenDiffs · watchRepairs · AppRoutes ·
   추천 · 권유 · 자문 · 시그널(주석은 짧게 · 🔵 S05·L06·L08 은 줄 수를 정확히 세므로 그 이름이 주석에 나오면 수가 늘어난다).
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려**.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다 — 🟡 는 PNG 를 다시 볼 신호일 뿐 · C4r4b-3).
   PNG 는 이름마다 light 한 장만 연다(6장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지 · 버튼 = «버튼 글자») · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 줄 n» = PNG 의 글자 **행** 수 · «상자» = 테두리·모서리가 보이는 덩어리 · «배경 덩어리» = 폭 전체 배경 · «칩 n개» = 한 무리의 칩 개수 · «막대» = 가로로 긴 덩어리 · «점» = 작은 둥근 표식 ·
   «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다(테스트 글꼴에서 테두리가 보이는 작은 네모로 찍힌다 · 모양 차이는 골든이 못 본다 = L1-02 몫) · 🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 채팅으로만) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · S05 출력 줄 수만큼) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M6.md 252~274행 23항) 그대로 + [x] 와 괄호만([—] 금지 · 🔴 23항을 코드 블록으로 감싸지 않는다 — C4r4a-6 ㄱ) · ③ = 위젯·Key 이름 나열(요약어 금지) ·
   질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외) · ⑤ 추측이 없으면 정확히 «없음» 한 낱말(🔴 빈 칸·«해당 없음»·설명 문장 금지 — C4r13a-6).

■ 프롬프트보다 이 카드가 이긴다 — 22항 (prompt_M6.md 275줄 판 v2 · 2026-10-26 재조립)
 ① 2행 {{범위}} · 121행 «이번 과제 범위: R5a~R5e 중 …» → 이 카드의 범위 = L-1 · L-2(위 첫 줄)
 ② 113~119행 역할·범위(M6 15화면 나열) → 이 카드 = L-1 · L-2 · J-*·H6-* = R1~R4(병합됨) · A-1~A-4 · L-3 = R5b~R5e(12 §6 7b~7e)
 ③ 12~13행 «의존 셋뿐 · 추가하려면 먼저 질문» → 추가 0 · pubspec 무변경(🔵 package:flutter/services.dart 의 Clipboard 는 flutter 안 — J-2 decision_detail.dart 선례)
 ④ 15~19행 «링크는 데이터 · 고정 상수 = 명세·카드가 이름을 든 것만 · null = 부재 · 라우터·플랫폼 가드 = 셸» → 그대로 유효 · 상수 = L-1 하단 AppRoutes.ledgerRepairs 하나(01 §21-9 규칙 ④)
 ⑤ 20~23행 DateTime.now 금지 · 신선도 = 주입 Clock + asOf → 그대로 유효(journalClockProvider · 규칙 5 ⓐ 한 식)
 ⑥ 29~31행 «건수 집계·거르기·묶기·재정렬 금지» → 그대로 유효 · 예외 = 규칙 5 의 셋(신선도 · rows.isEmpty · 들여쓰기 삼항)
 ⑦ 32~38행 «한국어 리터럴 = labels.dart 한 파일 · «아무 일 없음» 문장 금지» → 그대로 유효(JournalLabels R5a 절 3개 · 빈 = emptyLabel 그대로 · null 이면 그리지 않는다)
 ⑧ 41~47행 안전 화면 금지 · 목적지 이름 정본 = AppRoutes.all → 그대로 유효 — 정정 마법사 렌더 0 · «정정하기»·«다시 실사하기» = 행 actionLink(엔진이 고름) · M5 화면 이름을 짓지 않는다
 ⑨ 68~74행 수치·금액 리터럴 금지 → 그대로 유효(정적 L15 · L16 · deltaLabel·targetText 안 숫자는 엔진 글자)
 ⑩ 87~93행 «melos run test · check_boundaries · precheck(인자는 카드)» → 패키지 테스트 = packages/ui_journal 에서 flutter test 직접(🔴 백그라운드·파이프 금지) · 사전검사 인자 = 아래 «■ 제출»
 ⑪ 94~99행 «PR 만들지 않음 · 5섹션 채팅 · 섹션 머리·복사 상자 = 카드 글자» → 그대로 유효 · 글자 = 아래 «■ 제출»(섹션 머리 5줄 · ② 머리의 «12항» 은 그대로 — 사전검사 R1)
 ⑫ 100~105행 골든 두 갈래 → *.golden.json 0 · 새 PNG 12 = 최초 베이스라인(두 골든 파일만 --update-goldens) · 기존 98장 재생성 0
 ⑬ 106~111행 «모르는 것 = 질문 파일 · TODO 자리표시자 0» → 그대로 유효(질문 파일 = inbox/L1L2_questions.md — 이미 있다)
 ⑭ 122~128행 읽을 문서 5 → 아래 «먼저 읽을 것»(02 는 §5-1 · §5-2 · §5-2 끝 v1.12 블록만 · 00 README §5~§7 · 08 Mermaid 는 그림 M6-20~22 만 참고)
 ⑮ 130행 브랜치 ui/m6-<화면ID소문자>… · PR 제목 형식 «[M6] <화면 ID> <이름>»(글자는 카드) → 브랜치 ui/m6-l1l2-recon · 제목 «[M6] L-1·L-2 원장 차이·정정 이력»
 ⑯ 131~134행 라이브러리 둘(배럴 · operator) → 이 카드 = 배럴 쪽 2파일만(operator 파일·lib/journal_draft.dart 0)
 ⑰ 135~137행 플랫폼 → L-2 본문 Android 만 = 셸 가드(R13a 배선 완료 · 01 §21-9) · L-1 웹 = 셸 «부재» · 화면 코드 0 · 뷰어 판의 조치 = 엔진이 actionLink null 로
 ⑱ 143~145행 «ListResult 봉투 · 무한 스크롤 = limit += 100 재구독» → 🔴 재구독 0 · hasMore 무시(L-1 = 전체 목록 1화면 · L-2 = watchRepairs() 기본 50 · 발주자 확인 ①) · 빈 = emptyLabel 그대로
 ⑲ 146~150행 «차단 표기 = 공용 JournalSafetyBanners · X5 화면 .watchState( 0(C-47)» → 그대로 유효(배너 = journalSafetyStateProvider 의 valueOrNull)
 ⑳ 218~230행 «X5 읽기 L-1·L-2» → 그대로 유효 · 자리·순서·Key = 아래 «화면» 글자 · 🔵 «applicable == false = deltaLabel 문장만» = 화면이 applicable 을 읽지 않고 엔진 글자를 같은 자리에 그대로(🔴 K26 꼬리를 덮는 권고 — 발주자 확인 ② · ✅ K26 꼬리를 덮음 — 발주자 결정 2026-10-28) ·
    «chainStampText(표시·복사)» = Text + 복사 IconButton(발주자 확인 ③) · «accepted = resolved 같은 비중» = statusLabel style 0(발주자 확인 ④) · «필터 = v1 부재 · J-3R 링크·J-2 배지 진입 = v1 부재» 그대로
 ㉑ 231~250행 타입 지위 표 → L-1 · L-2 행만(watchOpenDiffs → LedgerDiffRow · LedgerDiffTile · watchRepairs → LedgerRepairRow · 안전 배너) · 249행 «부르지 않는 것» = 아래 «호출 표»
 ㉒ 251~274행 자체 점검 23항 → «■ 제출» ② 복사 상자(3 · 4 · 12 · 13 · 14 · 15 · 16 · 22 · 23 = [x] + 괄호 «이 카드 범위 밖(…)»)

■ 먼저 읽을 것 (🔴 03·04·05 명세는 읽지 않음 · 02 는 아래 ③ 의 자리만)
 ① prompt_M6.md 전문(판 v2) ② 01 §21 — 21-6 의 L-1·L-2 행 · 21-7 · 21-8(위젯·파일·주입·호출 표) · 21-9 · 21-10-4 의 L-1·L-2 행 · 21-11 · 21-16-1 · 21-17-2(미결 117 · 121 · 124)
 ③ 02 §5-1 «L-1 차이 상세» · §5-2 «L-2 정정 이력·감사» + §5-2 끝 «계약 v1.12 — R5 범위(X5 읽기 L-1·L-2) · 이 블록이 이긴다» ⓐ~ⓔ
 ④ packages/domain_contracts/lib/ — src/dto/ledger.dart(LedgerDiffRow · LedgerRepairRow) · src/enums/ledger.dart(DiffSeverity 외 — 읽기만) · src/dto/common.dart(ReasonChip · LinkAction) · src/enums/ui.dart(ChipTone) ·
    src/primitives/list_result.dart(ListResult) · src/repositories/ledger_repository.dart · src/navigation/app_links.dart(AppRoutes.ledgerRepairs) · testing.dart(UnimplementedLedgerRepository · RecordingLinkOpener)
 ⑤ packages/domain_contracts/test/contracts/c47_ledger_ops_test.dart 머리 주석 + «⑦ 화면 소스 스캔» 절(읽기만)
 ⑥ 지금 코드(packages/ui_journal) — lib/ui_journal.dart · lib/l10n/labels.dart · lib/src/common/journal_common.dart 전문(JournalReasonChip · journalToneColor 포함) · lib/src/holding_detail.dart(R4b — 상태 3갈래·신선도 한 식의 원형 · 고치지 않는다) ·
    lib/src/timeline.dart 머리 40줄 + journalSafetyStateProvider · test/holdings_overview_fakes.dart(FakeHoldingsSafetyRepository) · test/holdings_allocation_fakes.dart(가짜·도우미 꼴) · test/golden/h63_golden_test.dart(골든 꼴) · test/golden/golden_support.dart
 ⑦ packages/ui_journal/test/golden/README.md «🆕 R5» 절 + «🆕 R4» · «규칙» · «하네스» 절 ⑧ packages/domain_contracts/fixtures/README.md(m6/ledger_* 행 · 표본 사실 «정정 적용 ≠ 차이 해소») ⑨ docs/ai-context/inbox/README.md · L1L2_questions.md 머리말

■ 본받지 않는 것
 · R4a·R4b 카드와 같다 — 배너 관용구(화면이 배너를 직접 그리기) · .take(3)+«+n» · lib nullable 에 ! · 읽기 화면의 FlutterError.reportError · implements 가짜 · 한국어 테스트 이름 · 조건부 단언
 · JournalEntryCard · JournalBlockingFlags 안의 .take 는 공통 위젯 몫이라 그대로 둔다(고치지 않는다 · 이 카드의 화면 파일에는 .take 0)
 · lib/src/decision_detail.dart(J-2)의 복사 꼴 — 길게 누르기 + ScaffoldMessenger.showSnackBar + maxLines·TextOverflow.ellipsis(이 카드 = IconButton + Clipboard.setData 한 줄 · SnackBar·말줄임 0)
 · test/decision_detail_test.dart 의 클립보드 가짜 — if (call.method == 'Clipboard.setData') { … }(else 없는 if) → 이 카드 = 받은 MethodCall 전부를 목록에 담고 단언에서 고른다(L2-04 견본)
 · test/journal_draft_test.dart :36·:43 의 공장 안 if … return(옛 꼴) · test/golden/j3_golden_test.dart :62 의 collection-if(옛 꼴)
 · R13b 1회차 반려 꼴(C4h-2~4) — 탭·링크 단언이 if 안 · bool 칸 + if · opened[0]·[1] 원소 비교 · name ==·which == 15줄 · 사전검사 T1 을 지우려고 if 를 단언 안 || 로 감춤
 · 홈·대조 보드 꼴(ui_shell ops_home.dart)의 칸 5 고정·쌍 묶기 — L-1 은 차이 **행** 목록이다(칸 수 5 를 코드에 두지 않는다 · 쌍으로 묶지 않는다)

■ 주입 구조 (이름·타입·파일 고정 = 01 §21-8 글자 그대로 · 계약 변경 없음)
· 재사용: timeline.dart 의 journalSafetyStateProvider · journalClockProvider · journalLinkOpenerProvider · journalSafetyRepositoryProvider(테스트 override 용) /
  journal_common.dart: JournalAsOfHeader · JournalStaleBanner · JournalSafetyBanners · JournalReasonChip · JournalSkeleton · JournalErrorView · journalToneColor(🔴 무수정) / labels.dart: retry · staleBannerTitle(기존 · 고치지 않는다).
· 🆕 lib 파일 2개 — lib/src/ledger_diffs.dart(L-1 + LedgerDiffTile) · lib/src/ledger_repairs.dart(L-2)(이것 말고 새 lib 파일 0 · lib/src/ledger/ 폴더 0 · 그 밖 조각은 각 파일 안 private).
  import(directives_ordering · 쓰지 않는 import = analyze 실패 · 차례 = 드라이런 analyze «No issues found!» 로 확정 2026-10-28 — 아래 글자 그대로):
     ledger_diffs.dart  = package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart → ../l10n/labels.dart → common/journal_common.dart → timeline.dart
     ledger_repairs.dart = dart:async → package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter/services.dart → package:flutter_riverpod/flutter_riverpod.dart →
                           common/journal_common.dart → ledger_diffs.dart → timeline.dart(🔵 L-2 는 정적 라벨을 쓰지 않는다 — labels.dart import 0)
  🆕 주입 2 — ledger_diffs.dart 머리(🔴 import 바로 뒤 · 데이터 프로바이더보다 앞 · 이름·타입·throw 문구 고정 · 줄 나눔은 dart format 그대로 · 꼴 = timeline.dart 의 final journalXProvider = Provider<…>(…)):
    /// L-1·L-2 원장 읽기 창구 — 조립 앱이 override 한다(01 §21-8).
    final journalLedgerRepositoryProvider = Provider<LedgerRepository>(
      (Ref ref) => throw UnimplementedError('journalLedgerRepositoryProvider'),
    );
    /// 원장 신뢰 창구 — L-3(R5e)가 import 한다(이 카드는 선언만 · 부르는 곳 0).
    final journalLedgerTrustRepositoryProvider = Provider<LedgerTrustRepository>(
      (Ref ref) => throw UnimplementedError('journalLedgerTrustRepositoryProvider'),
    );
  데이터 2(autoDispose 0):
    final _ledgerDiffsProvider = StreamProvider<ListResult<LedgerDiffRow>>((Ref ref) => ref.watch(journalLedgerRepositoryProvider).watchOpenDiffs());        ← ledger_diffs.dart
    final _ledgerRepairsProvider = StreamProvider<ListResult<LedgerRepairRow>>((Ref ref) => ref.watch(journalLedgerRepositoryProvider).watchRepairs());     ← ledger_repairs.dart(🔴 인자 없이)
· 🆕 배럴 lib/ui_journal.dart 에 export 두 줄 — export 'src/ledger_diffs.dart'; · export 'src/ledger_repairs.dart';(자리 = export 'src/journal_read.dart'; 와 export 'src/timeline.dart'; 사이 · 이 차례 · 삭제 0)
· 조립 앱(이 카드 밖 · 참고만): 라우트 ledgerDiffs → const LedgerDiffs() · ledgerRepairs → const LedgerRepairs() + overrides = journalLedgerRepositoryProvider(·journalLedgerTrustRepositoryProvider — R5e 뒤).

■ 호출 표 (부르는 것 · 부르지 않는 것 — 01 §21-8 글자)
 L-1 — 부르는 것: watchOpenDiffs()(한 번 · 재시도 = invalidate) · journalSafetyStateProvider(배너) · journalClockProvider · opener.open(action.deepLink)(행 조치 탭) · opener.open(AppRoutes.ledgerRepairs)(하단 탭).
       부르지 않는 것: watchRepairs · watchExternalHoldings · CommandApi · DraftStore · .watchState( · AppRoutes.isRegistered.
 L-2 — 부르는 것: watchRepairs()(인자 없이 = 기본 50 · 한 번 · 재시도 = invalidate) · 안전 배너 · journalClockProvider · opener.open(link.deepLink)(행 결정 링크 탭) · Clipboard.setData(ClipboardData(text: row.chainStampText))(복사 탭).
       부르지 않는 것: watchOpenDiffs · CommandApi · DraftStore · .watchState( · limit 을 늘린 재구독.

■ 상태 표 (구독마다 — C4r3-1 · 꼴 = R4b holding_detail.dart 의 list.when(loading · error · data))
 L-1 diffs   첫 값 전 → JournalSkeleton(key: const Key('l1-loading')) · 에러(값 뒤 에러 포함) → JournalErrorView(key: const Key('l1-fail'), lastAsOfLabel: list.valueOrNull?.asOf.label, onRetry: () => ref.invalidate(_ledgerDiffsProvider)) ·
             값 → 본문(rows 빈 ∧ emptyLabel non-null = 빈 문장 · rows 빈 ∧ null = 행·문장 0 · 머리·배너·하단은 그대로) · 🔴 로딩·에러 갈래에서는 배너·하단을 그리지 않는다
 L-2 repairs 같은 꼴 — l2-loading · l2-fail(onRetry: invalidate(_ledgerRepairsProvider)) · 값 → 본문(빈 문장 Key l2-empty)
 safety      두 화면 공통 — 첫 값 전·에러 → 배너 부재(valueOrNull null) · 값 → JournalSafetyBanners(본문 영향 0)
 🔴 갈래를 고르는 것은 AsyncValue · rows.isEmpty · null 여부 · DiffSeverity switch · supersedes != null 뿐 — 글자 비교·코드 비교·플랫폼·플래그로 고르지 않는다.

■ 화면 1 — L-1 LedgerDiffs (02 §5-1 · §5-2 끝 v1.12 블록 ⓐⓑⓓ · 01 §21-6 L-1 행)
 배치(값 갈래 · 위 → 아래 · 🔴 이 순서):
   ListView(padding: EdgeInsets.zero)[
    1 JournalAsOfHeader(key: const Key('l1-asof'), asOf: list.asOf)
    2 (오래됐으면 — 규칙 5 ⓐ) JournalStaleBanner(asOf: list.asOf)
    3 JournalSafetyBanners(safety: safety)
    4 for (final (int i, LedgerDiffRow r) in list.rows.indexed) LedgerDiffTile(key: ValueKey<String>('l1-row-$i'), row: r)
    5 (list.rows.isEmpty && empty != null) Padding(padding: EdgeInsets.all(16), child: Text(empty, key: const Key('l1-empty')))          ← final String? empty = list.emptyLabel;
    6 Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child: Align(alignment: Alignment.centerLeft, child: TextButton(key: const Key('l1-repairs-link'),
        onPressed: () { ref.read(journalLinkOpenerProvider).open(AppRoutes.ledgerRepairs); }, child: const Text(JournalLabels.ledgerRepairsLink))))
   ]
 LedgerDiffTile(row:) — ConsumerWidget · Card(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4)) > Padding(EdgeInsets.all(16)) > Column(crossAxisAlignment: start)[  ← 🔴 아래 Text 순서 = 도우미 ledgerDiffTexts 의 순서
     Row[ Icon(look.$1, color: look.$2, size: 20) · SizedBox(width: 8) · Expanded(child: Text(row.pairLabel)) ]          ← final (IconData, Color) look = _severityLook(Theme.of(context).colorScheme, row.severity);
     Text(row.axisLabel)
     Text(row.severityLabel)
     Text(row.deltaLabel)
     Text(row.statusLabel)                                   ← 🔴 style·Opacity·크기 0(open · accepted · resolved 가 같은 꼴 — 발주자 확인 ④)
     Text(row.routeLabel)
     Text(JournalLabels.ledgerCandidateOrigins)
     Wrap(spacing: 6, runSpacing: 4)[ for (final ReasonChip c in row.candidateOrigins) JournalReasonChip(chip: c) ]     ← 받은 순서 · 비어도 Wrap 그대로(규칙 5 끝)
     Text(row.detectedAtText)
     Row[ Text(JournalLabels.ledgerEvidence) · SizedBox(width: 6) · Flexible(child: Text(row.evidenceHash)) ]
     (action != null) Align(alignment: Alignment.centerLeft, child: FilledButton(onPressed: () { ref.read(journalLinkOpenerProvider).open(action.deepLink); }, child: Text(action.label)))   ← final LinkAction? action = row.actionLink;
   ]
 _severityLook(ColorScheme cs, DiffSeverity s) = switch (s) { DiffSeverity.blocking => (Icons.block, cs.error), DiffSeverity.observational => (Icons.visibility_outlined, cs.onSurfaceVariant) }
   (반환 = (IconData, Color) 레코드 · 🔴 전수 switch · default 0 · 아이콘에 Key 0 · 아이콘 크기 20 = 글자 줄 이하(재량 — 바꾸면 기록))
 코드 스케치: build — final Clock clock = ref.watch(journalClockProvider); final SafetyState? safety = ref.watch(journalSafetyStateProvider).valueOrNull;
   final AsyncValue<ListResult<LedgerDiffRow>> list = ref.watch(_ledgerDiffsProvider); return list.when(loading: …, error: …, data: (ListResult<LedgerDiffRow> v) => _buildBody(context, ref, v, clock, safety));
   _isStale(ListResult<LedgerDiffRow> v, Clock clock) = v.asOf.observedAt.add(v.asOf.staleAfter).isBefore(clock.nowUtc())(R4b 꼴 한 식).

■ 화면 2 — L-2 LedgerRepairs (02 §5-2 · §5-2 끝 v1.12 블록 ⓐⓒⓓ · 01 §21-6 L-2 행)
 배치(값 갈래 · 위 → 아래 · 🔴 이 순서):
   ListView(padding: EdgeInsets.zero)[
    1 JournalAsOfHeader(key: const Key('l2-asof'), asOf: list.asOf) · 2 (오래됐으면) JournalStaleBanner(asOf: list.asOf) · 3 JournalSafetyBanners(safety: safety)
    4 for (final (int i, LedgerRepairRow r) in list.rows.indexed) _RepairRow(key: ValueKey<String>('l2-row-$i'), row: r)
    5 (list.rows.isEmpty && empty != null) Padding(padding: EdgeInsets.all(16), child: Text(empty, key: const Key('l2-empty')))          ← final String? empty = list.emptyLabel;
   ]
 _RepairRow(row:) — private ConsumerWidget · Padding(padding: EdgeInsets.fromLTRB(row.supersedes == null ? 16 : 40, 8, 16, 8)) > Column(crossAxisAlignment: start)[   ← 🔴 아래 Text 순서 = 도우미 ledgerRepairTexts 의 순서 · 들여쓰기 = 왼쪽 여백만
     Chip(label: Text(row.directionLabel), backgroundColor: journalToneColor(context, row.directionTone))     ← 행마다 Chip 1개(이 칩 하나)
     Text(row.label)                                         ← 재계산 고지(C-29)
     Text(row.originLabel)
     Text(row.targetText)
     Text(row.appliedAtText)
     (superseded != null) Text(superseded)                   ← final String? superseded = row.supersededLabel;(«이후 정정됨» — 원본을 숨기지 않는다)
     Row[ Flexible(child: Text(row.chainStampText)) · IconButton(icon: const Icon(Icons.copy), onPressed: () { unawaited(Clipboard.setData(ClipboardData(text: row.chainStampText))); }) ]   ← 행마다 Icon 1개(이것 하나 · tooltip 0)
     (link != null) Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () { ref.read(journalLinkOpenerProvider).open(link.deepLink); }, child: Text(link.label)))     ← final LinkAction? link = row.decisionLink;
   ]
 🔴 되돌리기·삭제·수정·정정 버튼 0 · 행을 옮기거나 묶지 않는다(계단 = 엔진 순서 · 정정의 정정은 원본 바로 뒤로 온다) · evidenceHash 를 그리지 않는다(L-2 자리 = chainStampText).
 🔵 02 §5-2 상태 «LEDGER_FIX 진행 중 = 상단 배너 + 목록 갱신 지연 고지» = 그 BlockFlag.label(엔진 글자 · JournalSafetyBanners 조각이 그림 — 화면 글자 0) · «LEDGER_INTEGRITY = 대상 수량·금액 숨김» = 엔진 targetText 그대로 · 표본에 LEDGER_FIX 행 0 — 엔진 몫(L2-08 = safetyFixtureRow(3) 그대로).

■ 픽스처 (FixturePaths.… · listFixture(<경로>, LedgerDiffRow.fromJson / LedgerRepairRow.fromJson) · safetyFixtureRow(n) · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다)
 full      listFixture(FixturePaths.ledgerDiffs4, LedgerDiffRow.fromJson) — 4행: [0] ld_0001 브로커 대조·수량 · BLOCKING · OPEN «열림» · actionLink «정정하기» · 칩 2(첫 칩만 detailDeepLink) ·
           [1] ld_0002 미러 대조·체결 건 · OBSERVATIONAL · actionLink null · 칩 1 · [2] ld_0003 아카이브 · ACCEPTED «받아들임 · …» · [3] ld_0004 캘린더 · RESOLVED «해소됨 · …» · emptyLabel null · hasMore false
 cash      listFixture(FixturePaths.m6LedgerDiffsCashObserve, LedgerDiffRow.fromJson) — 1행 ld_0005 브로커·현금 · OBSERVATIONAL · actionLink null · 칩 2
 four      listFixture(FixturePaths.m6LedgerRepairs4, LedgerRepairRow.fromJson) — 4행: [0] rp_0002 파생 재생성 NEUTRAL · 결정 링크 null · [1] rp_0003 정본 정정 CAUTION · decisionLink 있음 · supersededLabel «이후 정정됨» ·
           [2] rp_0004 supersedes rp_0003(바로 뒤 · 들여쓰기) · decisionLink 있음 · [3] rp_0001 파생 재생성 · emptyLabel null
 empty     listFixture(FixturePaths.m6LedgerRepairsEmpty, LedgerRepairRow.fromJson) — 0행 · emptyLabel «정정 이력이 없습니다»
 슬라이스  ledgerDiffSlice(full, <int>[0]) = l1_broker_qty · <int>[2] = l1_accepted · <int>[1] = l1_push_lag · <int>[] = 빈 슬라이스(L1-10 · emptyLabel null 그대로)
 안전      safetyFixtureRow(0) 정상(플래그 0) · (3) HALTED 차단 2(RECON_MISMATCH · JOURNAL_MISSING)
 🔴 쓰지 않는 것: m6/self_report_* · m8/recon_board_* · m6/advice_* · journal_30 · 형제 키 · 슬라이스 밖 copyWith · «내 픽스처» — 모자라면 질문 파일에.

■ Key 표 (l1- 6이름 · l2- 5이름 — 정본 = 이 표 · 🔴 표 밖 Key 0 · id 0 — 순번만 · 같은 이름을 두 자리에 달면 반려 · 정적 L19 = 이름마다 1줄)
   이름                 다는 자리                                              있을 때
   l1-loading           JournalSkeleton(L-1)                                    목록 첫 값 전
   l1-fail              JournalErrorView(L-1)                                   목록 에러
   l1-asof              JournalAsOfHeader(L-1)                                  값
   l1-row-$i            LedgerDiffTile(행 i · ValueKey<String>)                 행마다
   l1-empty             Text(emptyLabel)(L-1)                                   rows 빈 ∧ emptyLabel non-null
   l1-repairs-link      TextButton(L-1 하단)                                    값(늘)
   l2-loading · l2-fail · l2-asof · l2-row-$i(_RepairRow · ValueKey<String>) · l2-empty — L-1 과 같은 자리 꼴
   (LedgerDiffTile 안 · _RepairRow 안 · 칩 · 아이콘 · 버튼 · 배너에는 Key 를 달지 않는다 — 테스트는 행 Key 의 descendant 로 찾는다)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 그 커밋 내용 · 🔴 커밋마다 git add <파일> 로 지정 — git add . 금지(C4r4b-4) · amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일)
 (1) 정적 라벨 3(labels.dart R5a 절). 커밋 «[M6] R5a (1) 정적 라벨 3»
 (2) lib/src/ledger_diffs.dart + 배럴 한 줄(export 'src/ledger_diffs.dart';) + test/ledger_fakes.dart(L-1 몫) + test/ledger_diffs_test.dart(L1-01~L1-11). 🔴 커밋 전에 git add <그 파일들> 뒤 «정적 묶음» 미리 돌리기(규칙 15 금지 낱말 포함). 커밋 «[M6] R5a (2) L-1 원장 차이 상세 + 테스트»
 (3) lib/src/ledger_repairs.dart + 배럴 한 줄(export 'src/ledger_repairs.dart';) + test/ledger_fakes.dart 끝에 L-2 몫 + test/ledger_repairs_test.dart(L2-01~L2-09). 🔴 같은 미리 돌리기. 커밋 «[M6] R5a (3) L-2 정정 이력 + 테스트»
 (4) 골든 12장 — test/golden/l1_golden_test.dart(4이름 × 2) · test/golden/l2_golden_test.dart(2이름 × 2). 커밋 «[M6] R5a (4) 골든 l1_* 8장 · l2_* 4장»
 (5) melos.bat run format:fix · 질문 파일(L1L2_questions.md — dy 측정 행 A1~A6 · 그 밖의 질문). 커밋 «[M6] R5a (5) format · 질문».
     🔴 (5) 뒤 커밋 0 — 예외 = 사전검사 ① 🔴 수정 커밋 (6) **하나**(주석 고침 · 금지 낱말 고침도 (6) 하나에 모은다 · format:fix 먼저 · C4r13a-7 · C4r13b-7).

■ 정적 라벨 — JournalLabels 안 R4b 절의 마지막 상수(holdingsNextRebalance) 뒤 · 닫는 } 앞에 절 주석(// ── 🆕 R5a — L-1 차이 상세 · L-2 정정 이력 ──…)과 함께 3개(이름·글자 고정 · static const String · doc 주석 짧게):
   ledgerRepairsLink = '정정 이력' · ledgerCandidateOrigins = '원인 후보' · ledgerEvidence = '근거'
   🔴 만들지 않는 글자(엔진 몫): 쌍·축·심각도·상태·경로 글자 · 델타 문장 · «관측 항목 — 주문을 막지 않습니다» · «해당 없음» · 원인 후보 칩 글자 · 탐지 시각 · «정정하기»·«다시 실사하기» · 방향 배지 · 재계산 고지 ·
      원인 글자 · 대상 글자 · 적용 시각 · «이후 정정됨» · 체인 스탬프 · «결정 당시 근거 보기» · «정정 이력이 없습니다» · «복사됨» · «일치»·«통과»·«0»·«-». 라벨 글자에 숫자·금액 0(C-32) · «추천·권유·자문·시그널» 0 · 기존 34개는 그대로(합 37 — 정적 L10 이 정확히 센다).

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 는 정적 L17·L18 · (전제) 는 L30 과 대조)
공통: 띄우기 = pumpLedgerDiffs(tester, overrides:) · pumpLedgerRepairs(tester, overrides:)(Size(390, 4000) · DPR 1.0 · teardown 2 · ProviderScope(overrides) > MaterialApp > Scaffold(body: const LedgerDiffs()/LedgerRepairs()) · pump 한 번) ·
  overrides = ledgerOverrides(repo:, safety:, clock:, opener:)(4줄 · 아래 fakes) · 시계 = FixedClock(kGoldenNowUtc) · 오래됨 = ledgerStaleClock()(+2일) ·
  경우가 여럿인 테스트 = for 로 testWidgets 를 경우마다(이름 '<번호> <설명> ${c.name}') · 경우 = 테스트 파일 안 private class _Case(이름 · 입력 · 기대 · steps · opened — 칸은 테스트마다 재량 · bool 칸 0) ·
  기대 글자는 픽스처·JournalLabels 에서 · 띄우기는 한 테스트에 한 번 ·
  계획 = ledger_diffs_test testWidgets 줄 11(테스트 15 — 경우 for 안의 한 줄 포함) · ledger_repairs_test 줄 9(테스트 15) · 골든 1 + 1 · testWidgets·test 줄 합 22(≤ 33) · import = directives_ordering 차례(analyze «No issues found!» 가 판정 · 쓰지 않는 import 0).
  🆕 test/ledger_fakes.dart(새 · 공개 이름 · 한국어 리터럴 0 · if 0 · collection-if 0 · 🔴 다른 fakes 파일 무수정 — holdings_overview_fakes.dart 는 import 만):
    class FakeLedgerDiffsRepository extends UnimplementedLedgerRepository { FakeLedgerDiffsRepository({required this.diffs}); final Stream<ListResult<LedgerDiffRow>> Function(int call) diffs; int calls = 0;
      @override watchOpenDiffs() → final int call = calls; calls = calls + 1; return diffs(call); }(watchRepairs·watchExternalHoldings 는 넘기지 않는다 — 받침대가 던진다 = «부르지 않는 것» 증명)
    class FakeLedgerRepairsRepository extends UnimplementedLedgerRepository { … required this.repairs; final List<int> limits = <int>[];
      @override watchRepairs({int limit = 50}) → final int call = limits.length; limits.add(limit); return repairs(call); }(받은 인자 기록 = limit)
    List<Override> ledgerOverrides({required LedgerRepository repo, SafetyState? safety, Clock? clock, RecordingLinkOpener? opener})
      ← journalLedgerRepositoryProvider.overrideWithValue(repo) · journalSafetyRepositoryProvider.overrideWithValue(FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0))) ·
        journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)) · journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()) — 4줄
    Future<void> pumpLedgerDiffs(WidgetTester tester, {required List<Override> overrides}) · Future<void> pumpLedgerRepairs(…)(같은 꼴)
    ListResult<LedgerDiffRow> ledgerDiffSlice(ListResult<LedgerDiffRow> source, List<int> pick) => source.copyWith(rows: <LedgerDiffRow>[for (final int i in pick) source.rows[i]], hasMore: false);   ← 🔵 copyWith 예외 1
    ListResult<LedgerRepairRow> ledgerRepairSlice(ListResult<LedgerRepairRow> source, List<int> pick) => (같은 꼴 · LedgerRepairRow)   ← 🔵 copyWith 예외 2(L2-05 slice_empty · 드라이런 지적 반영)
    Stream<T> ledgerValueThenFail<T>(T v) async* { yield v; throw StateError('fail'); } · Clock ledgerStaleClock() => FixedClock(kGoldenNowUtc.add(const Duration(days: 2)));
    List<String?> ledgerShownTexts(WidgetTester tester, Finder scope)(scope 아래 Text 의 data · 위 → 아래 — holdingsShownTexts 꼴 · 인자 = Finder)
    List<String> ledgerDiffTexts(LedgerDiffRow r) => <String>[r.pairLabel, r.axisLabel, r.severityLabel, r.deltaLabel, r.statusLabel, r.routeLabel, JournalLabels.ledgerCandidateOrigins,
      for (final ReasonChip c in r.candidateOrigins) c.label, r.detectedAtText, JournalLabels.ledgerEvidence, r.evidenceHash, ?r.actionLink?.label];
    List<String> ledgerRepairTexts(LedgerRepairRow r) => <String>[r.directionLabel, r.label, r.originLabel, r.targetText, r.appliedAtText, ?r.supersededLabel, r.chainStampText, ?r.decisionLink?.label];
    Set<String> ledgerDiffsAllowed(ListResult<LedgerDiffRow> v) => <String>{v.asOf.label, ?v.emptyLabel, for (…r in v.rows) ...ledgerDiffTexts(r), JournalLabels.ledgerRepairsLink};
    Set<String> ledgerRepairsAllowed(ListResult<LedgerRepairRow> v) => <String>{v.asOf.label, ?v.emptyLabel, for (…r in v.rows) ...ledgerRepairTexts(r)};
      (🔴 허용 집합에 deepLink·링크·경로 문자열 0 — 링크를 글자로 그리는 변이를 잡게 · C4r13b-6)
    🔵 R5e(L-3)가 import 하는 이름 = ledgerDiffTexts · ledgerShownTexts · ledgerStaleClock · ledgerValueThenFail(+ lib 의 LedgerDiffTile · journalLedgerTrustRepositoryProvider) — 이름·서명 고정(R5e 0단계가 grep 으로 확인).
  파일 머리(main() 안)에서 위 «픽스처» 를 한 번 final 로 읽는다 · 기대 아이콘·색 = 테스트 파일 안 private switch 둘(_wantIcon · _wantColor — 기대 원천 = 이 카드 «화면 1» 의 _severityLook 글자).
L-1 — test/ledger_diffs_test.dart
 L1-01 전체 목록 · 받은 순서 · 글자(02 §5-1 · K26) — full · pumpLedgerDiffs → ⓗ expect(full.rows, hasLength(4)); → i 마다 ledgerShownTexts(tester, find.byKey(ValueKey<String>('l1-row-$i'))) == ledgerDiffTexts(full.rows[i]) ·
        find.byKey(const ValueKey<String>('l1-row-4')) findsNothing · l1-asof 아래 Text == [full.asOf.label] · getTopLeft(…).dy 가 l1-asof → l1-row-0 → … → l1-row-3 → l1-repairs-link 차례로 크다 ·
        find.text(JournalLabels.ledgerCandidateOrigins) findsNWidgets(4) · find.text(JournalLabels.ledgerEvidence) findsNWidgets(4)(C4r4a-4) · find.text(JournalLabels.staleBannerTitle) findsNothing · repo.calls == 1 · ⓡ.
 L1-02 심각도 아이콘·색 = 열거 switch(규칙 6 · C4r4a-3) — full · 전제(testWidgets 본문 첫머리 · if 밖): expect(<DiffSeverity>{for (final LedgerDiffRow r in full.rows) r.severity}, <DiffSeverity>{DiffSeverity.blocking, DiffSeverity.observational}); // pre →
        i 마다 find.descendant(of: 행 i, matching: find.byType(Icon)) findsOneWidget(행 안 아이콘 = 심각도 하나) · final Icon icon = tester.widget<Icon>(…); expect(icon.icon, _wantIcon(r.severity)); expect(icon.color, _wantColor(cs, r.severity)) ·
        cs = Theme.of(tester.element(find.byType(LedgerDiffs))).colorScheme · ⓡ.
 L1-03 accepted = resolved 같은 비중(02 §5-1 (b)) — full · 전제 둘: expect(full.rows[2].status, DiffStatus.accepted); // pre · expect(full.rows[3].status, DiffStatus.resolved); // pre →
        tester.widget<Text>(find.text(full.rows[2].statusLabel)).style == tester.widget<Text>(find.text(full.rows[3].statusLabel)).style == 행 0 의 statusLabel Text style ·
        (🔴 행 0·1 의 statusLabel 이 같은 글자 «열림» — 행 0 은 tester.widget<Text>(find.descendant(of: find.byKey(const ValueKey<String>('l1-row-0')), matching: find.text(full.rows[0].statusLabel))).style 로 좁힌다 · find.text 만 쓰면 «Too many elements») ·
        find.ancestor(of: find.text(full.rows[2].statusLabel), matching: find.byType(Opacity)) findsNothing · ⓡ.
 L1-04 조치 링크 = actionLink · null = 부재(K26 · 수용 18) — 두 경우 (broker_qty · ledgerDiffSlice(full, <int>[0]) · want = full.rows[0].actionLink!.label · steps = 행 0 의 FilledButton 탭 · opened = <String>[full.rows[0].actionLink!.deepLink]) ·
        (push_lag · ledgerDiffSlice(full, <int>[1]) · want = null · steps = 없음 · opened = <String>[])마다 — 전제 둘: expect(full.rows[0].actionLink, isNotNull); // pre · expect(full.rows[1].actionLink, isNull); // pre →
        규칙 10 «없는 쪽» 견본 그대로(await c.steps(tester); → expect(opener.opened, c.opened);) · ⓡ.
 L1-05 원인 후보 칩 — 받은 순서 · 열람만 · 칩 탭 = 핸드북(02 §5-1) — full · 전제: expect(full.rows[0].candidateOrigins[0].detailDeepLink, isNotNull); // pre →
        ⓗ expect(full.rows[0].candidateOrigins, hasLength(2)); → find.descendant(of: 행 0, matching: find.byType(JournalReasonChip)) findsNWidgets(2) · k 마다 find.descendant(of: 행 0, matching: find.text(chip.label)) findsOneWidget ·
        첫 칩 탭(find.descendant(of: 행 0, matching: find.text(full.rows[0].candidateOrigins[0].label))) → expect(opener.opened, <String>[full.rows[0].candidateOrigins[0].detailDeepLink!]) · TextField·Checkbox·Radio findsNothing(선택 UI·자유 입력 0) · ⓡ.
 L1-06 하단 «정정 이력» = 상수(01 §21-9 · K27) — full · tap(l1-repairs-link) → expect(opener.opened, <String>[AppRoutes.ledgerRepairs]) · ⓡ.
 L1-07 상태 × 갈래(C4r3-1 · «상태 표») — 네 경우 (loading · (int call) => Stream<…>.fromFuture(Completer<…>().future) · 있음 [l1-loading] · 없음 [l1-asof, l1-fail, l1-repairs-link] · stale findsNothing · asOfText findsNothing) ·
        (fail · (int call) => Stream<…>.error(StateError('fail')) · 있음 [l1-fail] · 없음 [l1-loading, l1-asof, l1-repairs-link] · findsNothing · findsNothing) ·
        (value_then_fail · (int call) => ledgerValueThenFail(full) · 있음 [l1-fail] · 없음 [l1-asof, l1-row-0, l1-repairs-link] · findsNothing · asOfText findsOneWidget(lastAsOfLabel)) ·
        (stale · (int call) => Stream<…>.value(full) · 시계 ledgerStaleClock() · 있음 [l1-asof, l1-row-0, l1-repairs-link] · 없음 [l1-loading, l1-fail] · stale findsOneWidget · asOfText findsOneWidget)마다 —
        Key 목록마다 findsOneWidget / findsNothing(경우 칸의 두 목록 — 🔴 «로딩이면 …» 같은 if 0) · expect(find.text(JournalLabels.staleBannerTitle), c.stale) · expect(find.text(full.asOf.label), c.asOfText)(Matcher 칸 · bool 칸 0) ·
        CircularProgressIndicator findsNothing(ⓡ·ⓗ 없음).
 L1-08 재시도(상태 표 에러 갈래) — 공장 = (int call) => call == 0 ? Stream<…>.error(StateError('fail')) : Stream<…>.value(full) → tap(find.text(JournalLabels.retry)) → pump 두 번 → l1-fail findsNothing · l1-row-0 findsOneWidget · repo.calls == 2 · ⓡ.
 L1-09 안전 배너 = 공용 조각(규칙 7) — full · safety = safetyFixtureRow(3) · 전제: expect(safetyFixtureRow(3).activeFlags, isNotEmpty); // pre → find.text(첫 플래그 label) findsOneWidget ·
        그 dy 가 l1-asof 보다 크고 l1-row-0 보다 작다 · ⓡ.
 L1-10 빈 슬라이스 — ledgerDiffSlice(full, <int>[]) · 전제: expect(full.emptyLabel, isNull); // pre → l1-row-0 findsNothing · l1-empty findsNothing · l1-asof findsOneWidget · l1-repairs-link findsOneWidget · ⓡ.
 L1-11 화면 Text 전부 · 큰 글꼴(C4d-1) — full · allowed = ledgerDiffsAllowed(full) → 규칙 10 «화면의 Text 전부» 견본 그대로 → tester.platformDispatcher.textScaleFactorTestValue = 2.0(+ addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue)) →
        pump → expect(tester.takeException(), isNull) · ⓡ.
 ⓡ 기대 = ledger_diffs_test.dart 10줄(L1-01·02·03·04·05·06·08·09·10·11 — 경우 for 안의 한 줄) · ⓗ 기대 = 2줄(L1-01 · L1-05) — 🔴 정확히 · (전제) = 8(L1-02 1 · L1-03 2 · L1-04 2 · L1-05 1 · L1-09 1 · L1-10 1).
L-2 — test/ledger_repairs_test.dart
 L2-01 전체 목록 · 받은 순서 · 들여쓰기 · 인자 없이(02 §5-2 · K25) — four · 전제 둘: expect(four.rows[0].supersedes, isNull); // pre · expect(four.rows[2].supersedes, isNotNull); // pre →
        ⓗ expect(four.rows, hasLength(4)); → i 마다 ledgerShownTexts(행 i) == ledgerRepairTexts(four.rows[i]) · l2-row-4 findsNothing · dy 가 l2-asof → l2-row-0 → … → l2-row-3 차례로 크다 ·
        i 마다 expect(_dx(tester, i), four.rows[i].supersedes == null ? _dx(tester, 0) : greaterThan(_dx(tester, 0)))(_dx = 행 i 의 첫 Text 의 getTopLeft(…).dx · 한 식 — if 0) · expect(repo.limits, <int>[50]) · ⓡ.
 L2-02 방향 배지 색 = 공용 tone — four · 전제: expect(<ChipTone>{for (final LedgerRepairRow r in four.rows) r.directionTone}, <ChipTone>{ChipTone.neutral, ChipTone.caution}); // pre →
        i 마다 find.descendant(of: 행 i, matching: find.byType(Chip)) findsOneWidget · expect(tester.widget<Chip>(…).backgroundColor, journalToneColor(tester.element(find.byType(LedgerRepairs)), four.rows[i].directionTone)) · ⓡ.
 L2-03 결정 링크 = decisionLink · null = 부재 — 두 경우 (with_link · 행 1 · want = four.rows[1].decisionLink!.label · steps = 행 1 의 TextButton 탭 · opened = <String>[four.rows[1].decisionLink!.deepLink]) ·
        (no_link · 행 0 · want = null · steps = 없음 · opened = <String>[])마다 — 전제 둘: expect(four.rows[1].decisionLink, isNotNull); // pre · expect(four.rows[0].decisionLink, isNull); // pre → «없는 쪽» 견본 꼴(TextButton) · ⓡ.
 L2-04 체인 스탬프 복사(발주자 확인 ③) — four · 클립보드 가짜 = 이 코드 꼴(else 없는 if 0):
          final List<MethodCall> calls = <MethodCall>[];
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async { calls.add(call); return null; });
          addTearDown(() { tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null); });
        → tap(find.descendant(of: 행 1, matching: find.byType(IconButton))) → pump →
          expect(calls.where((MethodCall c) => c.method == 'Clipboard.setData').map((MethodCall c) => (c.arguments as Map<Object?, Object?>)['text']).toList(), <Object?>[four.rows[1].chainStampText]) ·
        i 마다 find.descendant(of: 행 i, matching: find.byType(Icon)) findsOneWidget(행 안 아이콘 = 복사 하나) · opener.opened == <String>[](복사는 링크가 아니다) · ⓡ.
 L2-05 빈 문장(K25 · 01 §21-7) — 세 경우 (empty · empty · wantEmpty = empty.emptyLabel · firstRow findsNothing) · (four · four · wantEmpty = null · firstRow findsOneWidget) ·
        (slice_empty · ledgerRepairSlice(four, <int>[]) · wantEmpty = null · firstRow findsNothing — 행 0 ∧ emptyLabel null = 빈 자리 0)마다 —
        전제 셋: expect(empty.rows, isEmpty); // pre · expect(empty.emptyLabel, isNotNull); // pre · expect(four.emptyLabel, isNull); // pre → 규칙 10 «빈 문장» 견본 그대로 · expect(find.byKey(const ValueKey<String>('l2-row-0')), c.firstRow) · l2-asof findsOneWidget · ⓡ.
 L2-06 상태 × 갈래 — L1-07 과 같은 꼴 네 경우(입력 four · 오래됨 = ledgerStaleClock() · ⓡ·ⓗ 없음) · Key 목록 = 이 글자 그대로(L-2 에는 하단 링크가 없다):
        (loading · 있음 [l2-loading] · 없음 [l2-asof, l2-fail]) · (fail · 있음 [l2-fail] · 없음 [l2-loading, l2-asof]) ·
        (value_then_fail · 있음 [l2-fail] · 없음 [l2-asof, l2-row-0] · asOfText findsOneWidget) · (stale · 있음 [l2-asof, l2-row-0] · 없음 [l2-loading, l2-fail] · stale findsOneWidget).
 L2-07 재시도 — L1-08 과 같은 꼴(l2-fail → l2-row-0 · repo.limits == <int>[50, 50]) · ⓡ.
 L2-08 안전 배너 — four · safetyFixtureRow(3) · 전제: expect(safetyFixtureRow(3).activeFlags, isNotEmpty); // pre → 첫 플래그 label findsOneWidget · dy 가 l2-asof 보다 크고 l2-row-0 보다 작다 · ⓡ.
 L2-09 화면 Text 전부 · 큰 글꼴 — four · allowed = ledgerRepairsAllowed(four) → L1-11 과 같은 꼴 · ⓡ.
 ⓡ 기대 = ledger_repairs_test.dart 8줄(L2-01·02·03·04·05·07·08·09) · ⓗ 기대 = 1줄(L2-01) — 🔴 정확히 · (전제) = 9(L2-01 2 · L2-02 1 · L2-03 2 · L2-05 3 · L2-08 1).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려 · 갈래마다 — 행 있을 때 · 빈 갈래 · 오래됨 · 에러):
   (순서) L-1 행 순서 뒤집기 · L-2 행 순서 뒤집기 · L-2 정정의 정정을 맨 끝으로 · 배너를 행 아래로 · 하단 링크를 머리 위로.
   (존재) actionLink null 에도 비활성 버튼 · decisionLink null 에도 비활성 버튼 · supersededLabel 숨김 · 원본 행(superseded) 숨김 · 빈 문장 글자 바꾸기(L-2 만 · L-1 은 emptyLabel 표본 0 — 참고) ·
     emptyLabel null 에도 빈 자리(L-1 = L1-10 · L-2 = L2-05 slice_empty) · 칩 Wrap 을 칩 0 이면 숨김(표본 0 — 참고) ·
     applicable 로 deltaLabel 숨김(표본 0 — 참고) · 근거 해시 빼기 · 원인 후보 머리 라벨 빼기 · 정적 글자 하나 더하기 · 링크 글자를 화면에 그리기(탐침 — C4r13b-6).
   (값) 심각도 아이콘 하나로 고정 · 심각도 색 하나로 고정 · accepted 를 회색·작게 · 방향 배지 색 하나로 고정 · 들여쓰기 0 · 들여쓰기 전 행 · 체인 스탬프 대신 evidenceHash · 복사 글자 = 다른 필드 · 칩 순서 뒤집기 · 칩 하나만.
   (링크) 하단 = 다른 상수 · 행 조치 탭 0 · 행 조치 = 조립 링크 · 결정 링크 탭 0 · 탭 한 번에 두 번 열기 · 칩 탭을 화면이 직접.
   (상태) 에러를 스켈레톤으로 · 재시도에 invalidate 0 · 값 뒤 에러에 lastAsOfLabel 0 · 오래됨 배너 빼기 · 신선도 비교 뒤집기 · 벽시계로 신선도 · 로딩 중 하단 링크 · watchRepairs(limit: 100).
   🔵 판정 = 변이마다 ui_journal 의 flutter test 전부(골든 포함) + C-47 ⑦ · 골든은 아이콘·색 차이를 못 본다(L1-02 · L2-02 몫) · 드라이런 2026-10-28 = 목록 55꼴 중 «참고» 3(L-1 빈 문장 · 칩 0 · applicable) 말고 전부 KILLED ·
     «참고» = 반려 근거 아님 — applicable = 정적 L07 몫 · 표본 0 = M2 후보(발주자 확인 ⑩) · 하단 링크를 같은 값 리터럴로 = 정적 L04 몫(C-47 ⑦ 은 리터럴을 보지 않는다) · Key 없는 빈 자리 = 잡는 검사 0.

■ 정적 묶음 — packages/ui_journal 에서 아래 32줄을 한 번에 붙여 넣어 돌리고, 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 출력 줄 수(EXIT 줄 포함) = 125줄(드라이런 실측 · bash = PowerShell 5.1) — 붙이기 전에 세어 같은지 본다(C4r4a-6 ㄴ) ·
   flutter test·dart test 출력은 파일로 떠서 붙인다 · «EXIT:1»/«EXIT:False» = 출력 없음 · 블록 뒤 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»)
echo "## L01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/ledger_fakes.dart test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]" -- test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "journalLinkOpenerProvider" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L06 subscription lines (2)"; git grep -nE "watchOpenDiffs\(|watchRepairs\(" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L07 forbidden words in new lib files 0"; git grep -nP "DateTime\.now|kIsWeb|Platform\.|dart:io|HoldingPnl|PerformanceSeries|FeatureFlags|RunMode|operatingMode|CommandApi|DraftStore|watchState|activeFlags|FlagIds|watchExternalHoldings|candidateOriginCodes|originCode|directionCode|decisionId|recomputedFrom|diffId|repairId|\.appliedAt\b|\.wire\b|\.name\b|\.applicable\b|NumberFormat|toStringAsFixed|toString\(|Navigator|ScaffoldMessenger|SnackBar" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L08 AppRoutes constants (1)"; git grep -nE "AppRoutes\.[a-zA-Z]+" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L09 enum switch arms (DiffSeverity 2)"; git grep -nE "DiffSeverity\.|DiffStatus\.|RepairRoute\.|LedgerPair\.|LedgerAxis\.|ChipTone\." -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L10 journal labels (37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## L11 barrel exports (11)"; git grep -n "^export " -- lib/ui_journal.dart; echo "EXIT:$?"
echo "## L12 ledger providers"; git grep -nP "^final \w+Provider\b" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L13 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_journal/)" -- lib; echo "EXIT:$?"
echo "## L14 hangul literals in new lib files 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L15 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart lib/l10n/labels.dart; echo "EXIT:$?"
echo "## L16 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L17 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/ledger_diffs_test.dart test/ledger_repairs_test.dart; echo "EXIT:$?"
echo "## L18 H lines (hasLength)"; git grep -c "hasLength(" -- test/ledger_diffs_test.dart test/ledger_repairs_test.dart; echo "EXIT:$?"
echo "## L19 key names (one line each)"; git grep -noP "'l[12]-[a-z]+(-[a-z]+)*" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L20 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## L21 Colors files 0"; git grep -lw Colors -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L22 rich text trimming taking 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox|\.take\(|\.where|\.sort" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L23 autoDispose 0"; git grep -n "autoDispose" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L24 Scaffold AppBar SafeArea 0"; git grep -nE "Scaffold|AppBar|SafeArea" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
echo "## L25 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_journal.dart lib/journal_draft.dart lib/src/common lib/src/timeline.dart lib/src/holdings_overview.dart lib/src/holding_detail.dart pubspec.yaml analysis_options.yaml README.md test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/holdings_overview_fakes.dart test/holdings_allocation_fakes.dart; echo "EXIT:$?"
echo "## L26 implements in new tests 0"; git grep -n " implements " -- test/ledger_fakes.dart test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L27 copyWith in tests (slice 2)"; git grep -n "copyWith(" -- test/ledger_fakes.dart test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L28 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/ledger_fakes.dart test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L29 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## L30 precondition marks (pre)"; git grep -c "// pre$" -- test/ledger_diffs_test.dart test/ledger_repairs_test.dart; echo "EXIT:$?"
echo "## L31 name compares element picks and hidden ifs in tests 0"; git grep -nP "\b(name|which)\s*==|opened\[\d\]|\|\|[^;]*isTrue\)" -- test/ledger_fakes.dart test/ledger_diffs_test.dart test/ledger_repairs_test.dart test/golden/l1_golden_test.dart test/golden/l2_golden_test.dart; echo "EXIT:$?"
echo "## L32 non-null assertion in new lib 0"; git grep -nP "[\w\)\]]!(?![=])" -- lib/src/ledger_diffs.dart lib/src/ledger_repairs.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(카드 계획 = 드라이런 2026-10-28 실측) — L01 = 주석 줄 말고 출력 없음 · L02 = 출력 없음 · L03 = 4줄(l1_golden 1 · l2_golden 1 · ledger_diffs_test 11 · ledger_repairs_test 9) · L04 = 0 ·
   S05 = 3줄(ledger_diffs.dart 행 조치 · 하단 · ledger_repairs.dart 결정 링크 — 파일 줄 차례 · 줄마다 탭 콜백 안) · L06 = 2줄 · L07 = 0 · L08 = 1줄(ledgerRepairs) · L09 = 2줄(DiffSeverity.blocking · .observational) ·
   L10 = «lib/l10n/labels.dart:37»(🔴 정확히 — R4b 까지 34 + R5a 3 · 줄머리 셈이라 예시 주석은 셈 밖) · L11 = 11줄(l10n/labels · src/blind_review · src/decision_detail · src/holding_detail · src/holdings_allocation · src/holdings_overview · src/journal_read · 🆕 src/ledger_diffs · 🆕 src/ledger_repairs · src/timeline · src/unknown_board 차례 · 🔴 정확히) · L12 = 4줄(ledger_diffs.dart 3 = 주입 2 + _ledgerDiffsProvider · ledger_repairs.dart 1) ·
   L13~L16 = 0 · L17 = «test/ledger_diffs_test.dart:10» · «test/ledger_repairs_test.dart:8» · L18 = «test/ledger_diffs_test.dart:2» · «test/ledger_repairs_test.dart:1»(🔴 정확히 — 다르면 반려) ·
   L19 = 11줄 = 위 «Key 표» 이름마다 정확히 1줄(같은 이름 두 줄 = 두 자리에 단 것 = 반려) · L20~L24 = 0 · L25 = 두 줄(labels.dart · ui_journal.dart — 둘째 수 0 · ui_journal.dart 첫째 수 2 · labels.dart 첫째 수 = 재량(드라이런 11 · 절 주석·doc 주석·빈 줄 포함 — 수는 재량 · 삭제 0 만 본다 · C4r13a-8)) · 그 밖 파일 줄 없음 ·
   L26 = 0 · L27 = 2줄(test/ledger_fakes.dart 의 ledgerDiffSlice · ledgerRepairSlice) · L28 = 0 · L29 = 12줄 전부 «A»(l1_* 8 · l2_* 4) · L30 = «test/ledger_diffs_test.dart:8» · «test/ledger_repairs_test.dart:9»(= 최소 목록의 (전제) 수 · 🔴 정확히) · L31 = 0 · L32 = 0)
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · L07 · L22 는 주석 줄도 센다(규칙 15))

■ 골든 — 6이름 × light/dark = 12장(전부 신규 · ✅ K35 · 이름 = 02 §5-1 (d) · §5-2 (c) 글자 그대로 · golden README «🆕 R5» 절 표 그대로)
  l1 — test/golden/l1_golden_test.dart · const Size _kTallPhone = Size(390, 844)(폭 390 고정 · kGoldenPhoneSize 불변 · 드라이런 맨 아래 dy 최대 412.0) · 위젯 = const LedgerDiffs() · 안전 = safetyFixtureRow(0):
    이름               watchOpenDiffs 입력                          흐름
    l1_broker_qty      ledgerDiffSlice(full, <int>[0])               없음
    l1_cash_observe    cash(m6/ledger_diffs_cash_observe 그대로)      없음
    l1_accepted        ledgerDiffSlice(full, <int>[2])               없음
    l1_push_lag        ledgerDiffSlice(full, <int>[1])               없음
  l2 — test/golden/l2_golden_test.dart · const Size _kTallPhone = Size(390, 1200)(드라이런 맨 아래 dy 최대 964.0) · 위젯 = const LedgerRepairs() · 안전 = safetyFixtureRow(0):
    l2_chain_two_repairs   four(m6/ledger_repairs_4)     없음
    l2_empty               empty(m6/ledger_repairs_empty) 없음
  모양 = h63_golden_test.dart(R4b)와 같은 (이름, 입력, 흐름) 목록(private class _Flow) × Brightness.values 루프 · 흐름 = 클로저 칸(전부 (WidgetTester t) async {}) · 테스트 이름 '${flow.name} ${brightnessSuffix(b)}' ·
  주입 = pumpForGolden(tester, const LedgerDiffs(), brightness: b, logicalSize: _kTallPhone, wrapApp: (Widget app) => ProviderScope(overrides: ledgerOverrides(repo: FakeLedgerDiffsRepository(diffs: (int call) => Stream<…>.value(flow.input))), child: app)) →
    await tester.pump(); → await flow.steps(tester); → await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden(flow.name, b).
  위치 전제 둘 = 이 코드 글자 꼴(C4r3-5 · 흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(<맨 아래 Key>)).dy, lessThan(_kTallPhone.height));   // l1_* → const Key('l1-repairs-link') · l2_chain_two_repairs → const ValueKey<String>('l2-row-3') · l2_empty → const Key('l2-empty')
    expect(tester.getTopLeft(find.byKey(const Key('l1-asof'))).dy, 0.0);                       // l2 파일은 Key('l2-asof')
  명령(packages/ui_journal): flutter test --update-goldens test/golden/l1_golden_test.dart · flutter test --update-goldens test/golden/l2_golden_test.dart → flutter test(옵션 없이 · git status 에 새 PNG 12 만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이(_kTallPhone)는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     골든 높이 = 카드 확정값 + 여백 재량(12 §3 공통 조문) — 화면 여백(SizedBox 높이·Padding 정수)을 줄여 맞추는 것은 허용 · 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개 · 두 화면 질문을 한 파일에)
· L1L2_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지 · 행 앞에 «L-1:» 또는 «L-2:» 접두(🔵 예외 = 골든 dy «측정:» 행 — 접두 없이 «측정:» 으로 시작 · 이름 l1_·l2_ 가 화면을 가른다).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A6 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 6줄을 그대로 붙이고 <값> 자리에만 잰 수를 넣는다(C4r4a-6 ㄷ · 높이 = 리터럴 · C4r13b-1):
      ┌── 측정 행 복사 시작(다음 줄부터 · 6줄)
| A1 | R5a-Bob-L1L2 | 추측 | 측정: l1_broker_qty dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A2 | R5a-Bob-L1L2 | 추측 | 측정: l1_cash_observe dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A3 | R5a-Bob-L1L2 | 추측 | 측정: l1_accepted dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A4 | R5a-Bob-L1L2 | 추측 | 측정: l1_push_lag dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A5 | R5a-Bob-L1L2 | 추측 | 측정: l2_chain_two_repairs dy 실측값 (light=<값>, dark=<값>) < 1200 | 골든 위치 전제 실측 | 1200 미만 확인 | ⬜ 미답 | |
| A6 | R5a-Bob-L1L2 | 추측 | 측정: l2_empty dy 실측값 (light=<값>, dark=<값>) < 1200 | 골든 위치 전제 실측 | 1200 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖)
  여백을 줄였으면 A7 부터 «측정:» 전·후 행 · 3개 밖에 더 필요했던 정적 라벨 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 3 · 읽지 않는 필드 · 배치 순서 · Text 순서 · 심각도 아이콘·색 · 방향 배지 색 · 복사 꼴 · 들여쓰기 폭 · 골든 이름·입력 · 재량(여백·크기·모서리).
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(5) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋)
  cd packages/ui_journal
  flutter test test/ledger_diffs_test.dart              ← 끝 줄 그대로(기대 «+15: All tests passed!»)
  flutter test test/ledger_repairs_test.dart            ← 끝 줄 그대로(기대 «+15: All tests passed!»)
  flutter test test/golden/l1_golden_test.dart          ← 끝 줄 그대로(기대 «+8: All tests passed!»)
  flutter test test/golden/l2_golden_test.dart          ← 끝 줄 그대로(기대 «+4: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄 그대로 · 기대 = 시작 기준 N + 42 — 388 → «+430: All tests passed!»)
  cd ../domain_contracts
  dart test test/contracts/c47_ledger_ops_test.dart -r expanded   ← 전부 통과 · «C-47 ⑦ 대상» 줄과 그 아래 들여쓴 경로 줄을 그대로 적어 둔다
     (기대 3줄: «C-47 ⑦ 대상 2파일 — packages/ui_journal/{lib/src/ledger_diffs.dart, lib/src/ledger_repairs.dart} + lib/src/ledger/**» + 공백 4칸 들여쓴
      «packages/ui_journal/lib/src/ledger_diffs.dart» · «packages/ui_journal/lib/src/ledger_repairs.dart»(정렬 순) · 🔴 «공허 통과» 가 보이면 파일 이름이 카드와 다르다 — 멈춤)
  cd ../..
  bash tool/check_boundaries.sh   ← 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건(«packages/ui_journal/lib/src/timeline.dart:109»)은 이 카드와 무관 — 그대로 둔다 · 그 밖 🟡 [C-5] 0
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+392 ~30: All tests passed!»(이 카드 몫 0) · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_journal/): M lib/l10n/labels.dart · A lib/src/ledger_diffs.dart · A lib/src/ledger_repairs.dart · M lib/ui_journal.dart ·
        A test/golden/goldens/l1_*.png 8장 · A test/golden/goldens/l2_*.png 4장 · A test/golden/l1_golden_test.dart · A test/golden/l2_golden_test.dart · A test/ledger_diffs_test.dart · A test/ledger_fakes.dart · A test/ledger_repairs_test.dart ·
        M docs/ai-context/inbox/L1L2_questions.md · 그 밖의 줄(특히 M lib/src/common/** · M lib/src/timeline.dart · M test/holdings_overview_fakes.dart · M PNG · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다 — || 로 단언 안에 넣기 · bool 칸 · 이름 비교 = 반려) → 새 커밋 하나(«[M6] R5a (6) 사전검사 지적 수정» · amend 금지 · format:fix 먼저) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m6-l1l2-recon
  git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD   ← ① 에 그대로 붙일 출력(푸시한 그 커밋 위에서 · 권장대로면 커밋 5줄)
  cd packages/ui_journal → 위 «정적 묶음» 32줄 → cd ../..   ← ② 에 그대로 붙일 출력
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M6] L-1·L-2 원장 차이·정정 이력
  🔴 채팅 답 = 아래 제출 글 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님 — C4r4a-7) + 끝 flutter test 한 줄.
  PR 본문 5섹션을 채팅으로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 채팅 글 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R5a-Bob-L1L2_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R5a-Bob-L1L2_submit.md --golden-prefix l --goldens 12
        ← 🔴 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 채팅에 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다 · C4r13b-3) · 출력은 채팅에 붙이지 않는다 ·
          🔵 접두 «l» 은 l1_·l2_ 행을 함께 센다 — 골든 표 행은 정확히 12 · 🔵 🟡 [G1] 은 멈춤이 아니다 — 표는 이 카드의 셈 단위대로(칸 견본 = 아래 ③) ·
          🔵 G1 🟡 2 예상 = l2_chain_two_repairs light·dark(기계가 체인 스탬프 + 복사 아이콘 줄·버튼 글자를 다르게 센다 · 드라이런 같음) — 🔴 칸을 고치지 않는다(C4r4b-3).
   ① 아래 «① 머리 복사 상자» 두 줄 그대로 + «바뀐 파일:» + name-status 출력 그대로(코드 블록 하나) + «커밋 목록:» + log 출력 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: L-1 — 원장 차이 상세(LedgerDiffs() · LedgerDiffTile(row:))
화면 ID: L-2 — 정정 이력·감사(LedgerRepairs())
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 23항 — 아래 복사 상자 23줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 23줄 그대로인지 «23항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «두 화면 산술 = 신선도 한 식 · rows.isEmpty · 들여쓰기 삼항뿐 · 건수·잔량·D-day 0 · 금지 수치 L15 0건 · 소수·% 리터럴 L16 0건»
        2번 = «한국어 리터럴 = labels.dart(R5a 절 3개 · 합 <N> — L10) 한 파일뿐(L14 0건) · 엔진 글자 = DTO *Label·*Text·label 그대로»
        3번 = «이 카드 범위 밖(손익·J-4 없음) · 두 화면 손익 0(L07)»
        4번 = «이 카드 범위 밖(H6-1·H6-2 = R4)»
        5번 = «정정 마법사 렌더 0 · 진입 = 행 actionLink 딥링크만(L1-04) · 결정 = decisionLink 딥링크만(L2-03)»
        6번 = «정적 묶음 L13 — 허용 밖 import 0줄 · pubspec·analysis_options 무변경(L25)»
        7번 = «이 카드 = 배럴 쪽 2파일만(operator 0 · L25 journal_draft.dart 줄 없음) · 근거 = evidenceHash 만(원문 필드 0)»
        8번 = «배너 = JournalSafetyBanners 그대로(L1-09 · L2-08) · 화면이 지은 배너 문구 0»
        9번 = «두 화면 머리 = list.asOf.label(l1-asof · l2-asof · L1-01 · L2-01) · 로딩·빈·에러·오래됨·차단 = L1-07·L1-10·L2-05·L2-06·L1-09»
        10번 = «타입·필드 이름 짓기 0 · 픽스처 변경 0 · 새 PNG = l1_* 8장 + l2_* 4장 · 재생성 <N>장(L29)»
        11번 = «모드 필드 0(L07) · 접두·띠 0»
        12번 = «이 카드 범위 밖(A-1·A-2 = R5b·R5c)»
        13번 = «이 카드 범위 밖(A-3 = R5d)»
        14번 = «이 카드 범위 밖(viewer 판 = 엔진이 actionLink null · L-2 본문 Android 만 = 셸 가드)»
        15번 = «이 카드 범위 밖(안내·예산 명령 없음) · CommandApi 0(L07)»
        16번 = «이 카드 범위 밖(L-3 = R5e)»
        17번 = «내보내기·공유·인쇄 0 · 체인 스탬프 복사 = 클립보드 한 줄(L2-04)»
        18번 = «actionLink·decisionLink null = 버튼 부재(L1-04 · L2-03) · id 로 존재 판정 0»
        19번 = «거르기·묶기·재정렬 0(C-47 ⑦ · L22) · 들여쓰기 = supersedes != null 하나(L2-01) · 링크 조립 0(L04 · L08 = ledgerRepairs 상수 <N>줄)»
        20번 = «띠 높이 예약 0 · 신선도 = 주입 Clock + asOf 한 식(L1-07 · L2-06)»
        21번 = «플래그 재정렬·리터럴 비교 0 · 공용 배너 그대로(FlagIds 0 · L07)»
        22번 = «이 카드 범위 밖(DraftStore 0 — 읽기 화면 · L07)»
        23번 = «이 카드 범위 밖(초안 0 — 읽기 화면)»
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
      23항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r5a_box2.txt)에 저장 → (Get-Content $env:TEMP\r5a_box2.txt).Count 또는 grep -c "" "$TEMP/r5a_box2.txt" →
        출력 한 줄을 아래 «23항 줄 수» 상자 글자 틀 그대로(C4r4b-5 · 코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 23):
      ┌── 23항 줄 수 복사 시작(다음 줄부터 · 4줄)
23항 줄 수:
```
<출력 한 줄>
```
      └── 23항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 32줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄들(S05 출력 줄마다 한 줄 · 같은 차례 · 기대 3줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(L17·L18 출력 줄 그대로 복사 · test/ 를 떼지 않는다) + «C-47 ⑦ 출력:» + 출력 3줄 그대로 + «테스트 파일별:» + 위 flutter test 네 파일 끝 줄 그대로(ledger_diffs · ledger_repairs · l1_golden · l2_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 6줄)
ⓡ = L17 출력:
<L17 출력 줄 그대로>
<L17 출력 줄 그대로>
ⓗ = L18 출력:
<L18 출력 줄 그대로>
<L18 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — L-1 로딩·정상·빈·에러 4줄 + L-2 로딩·정상·빈·에러 4줄 + 골든 표 12행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로(C4r13a-6 «채운 견본»):
         L-1 «정상» = ListView → Key('l1-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → ValueKey<String>('l1-row-$i')(LedgerDiffTile) → Key('l1-empty')(있을 때) → Key('l1-repairs-link')
         L-1 «로딩» = JournalSkeleton(Key('l1-loading')) · «빈» = ListView → Key('l1-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('l1-empty')(있을 때) → Key('l1-repairs-link') · «에러» = JournalErrorView(Key('l1-fail'))
         L-2 «정상» = ListView → Key('l2-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → ValueKey<String>('l2-row-$i')(_RepairRow) → Key('l2-empty')(있을 때)
         L-2 «로딩» = JournalSkeleton(Key('l2-loading')) · «빈» = ListView → Key('l2-asof') → JournalStaleBanner(있을 때) → JournalSafetyBanners → Key('l2-empty') · «에러» = JournalErrorView(Key('l2-fail'))
      골든 표 12행(l1_* 8 · l2_* 4 · 한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 안전 행 | 크기 | 위치 전제 dy | 배치·잘림 |» · 이름 칸 = «l1_broker_qty light» 꼴 · 입력 = 경로 그대로(슬라이스는 «ledger_diffs_4.json 행 0» 꼴) ·
        크기 = 390×<높이 리터럴> · dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(6장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 배경 덩어리 · 칩 n개 · 막대 · 점 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(12행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다 ·
        행 앞 심각도 아이콘·복사 아이콘 = 글자 줄 덩어리 괄호 안 «작은 네모 표식»(보고 규칙 셈 단위 — «상자» 낱말 0)) · 셈 단위 견본 2행(드라이런이 PNG 를 열어 쓴 칸 · 꼴만 본뜬다):
         «| l1_broker_qty light | ledger_diffs_4.json 행 0 | 0 | 390×844 | 412.0 | 글자 줄 1 → 상자(안 글자 줄 7 · 칩 2개 · 글자 줄 2 · 버튼 글자 1 · 첫 줄 앞에 작은 네모 표식 하나) → 버튼 글자 1 — 잘림 없음 |»
         «| l2_chain_two_repairs light | m6/ledger_repairs_4.json | 0 | 390×1200 | 964.0 | 글자 줄 1 → 칩 1개 → 글자 줄 5(끝 줄 뒤에 작은 네모 표식 하나) → 칩 1개 → 글자 줄 7(끝 줄 뒤에 작은 네모 표식 하나) → 버튼 글자 1 → 칩 1개 → 글자 줄 6(끝 줄 뒤에 작은 네모 표식 하나) → 버튼 글자 1 → 칩 1개 → 글자 줄 5(끝 줄 뒤에 작은 네모 표식 하나) — 잘림 없음 |»(이 행은 G1 🟡 가 난다 — N3).
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/L1L2_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = L1L2_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_journal 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 42 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-l1l2-recon` 푸시 1건 · 커밋 권장 5개(마지막 = format·질문 · amend·rebase·강제 푸시 0 · 커밋마다 지정 파일 add · (5) 뒤 = 사전검사 ① 수정 (6) 하나만).
- `lib/` 새 파일 **2**(`src/ledger_diffs.dart` · `src/ledger_repairs.dart`) · 수정 2(더하기만 — `labels.dart` R5a 절 라벨 3 · `ui_journal.dart` export 2줄 정렬 자리) · 그 밖 lib·`apps/`·`domain_contracts`·pubspec 변경 0.
- `test/` 새 파일 5(`ledger_fakes.dart` · `ledger_diffs_test.dart` · `ledger_repairs_test.dart` · `golden/l1_golden_test.dart` · `golden/l2_golden_test.dart`) + 새 PNG 12장(`l1_*` 8 · `l2_*` 4) · 재생성 0(`golden:approved` 불필요) · 기존 fakes 무수정.
- 질문 파일 `L1L2_questions.md`(새 행 A1~A6 «측정:» 반드시).
- 채팅: PR 본문 5섹션 + flutter test 한 줄 · 사전검사 ① 한 번 · ② 한 번(`l` · 12) 🔴 0.
- `flutter test` = 시작 기준 N(388 = `origin/main` `4bb7067` 실측 2026-10-27) + 42(뷰 30 + 골든 12 · 드라이런 실측 «+430») · 정적 L10 = 37 · L11 = 11줄 · L12 = 4 · L17 = 10·8 · L18 = 2·1 · L19 = 11 · L27 = 2 · L29 = 12 A · L30 = 8·9(🔴 정확히) · 출력 125줄 · S05 = 3 · L06 = 2 · L08 = 1 · L09 = 2 · C-47 ⑦ = 2파일 · `domain_contracts` «+392 ~30».
- 재분할 임계(카드 계획): 새 `testWidgets(`·`test(` 줄 22(임계 «> 33» 안) · lib +298/-0(드라이런 · 임계 «> +900» 안) · 새 PNG 12(임계 «> 16» 안) → 재분할 없음 예상.
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것(2026-10-28): 목록 55꼴 — «참고» 3 말고 전부 KILLED(순서 6 · 존재 13 · 값 11 · 링크 8 · 상태 14 · 지적 반영 뒤 «L-2 emptyLabel null 에도 빈 자리» = L2-05 `slice_empty` 가 잡음) · 결과 표 = 스크래치 `r5/mut_r5a/mutations.md` + `r5/mut2/a/`.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R5a-Bob-L1L2 결과: 브랜치 ui/m6-l1l2-recon 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. 0단계에서 멈췄다면 `R5a-Bob-L1L2 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① `lib/src/common/**`·`timeline.dart`·`holdings_overview.dart`·기존 테스트·기존 PNG 가 `M` ② `apps/**`·`packages/domain_contracts/**`·다른 `ui_*`·`lib/journal_draft.dart` 가 `M` ③ 두 화면 파일에 `candidateOriginCodes`·`originCode`·`directionCode`·`decisionId`·`.appliedAt`·`.name`·`.where`·`.sort`·`CommandApi`·`watchState`·`kIsWeb`·`'aaq://`·`DateTime.now`·`SnackBar` ④ 배치 순서가 «화면» 과 다름 · 정정·되돌리기 버튼 ⑤ actionLink·decisionLink null 에 비활성 버튼 ⑥ accepted 행만 다른 style ⑦ 들여쓰기를 `supersedes` 밖의 값으로 · 행을 옮김 ⑧ 공용 2파일에 삭제 줄 · 배럴 export 가 끝에 ⑨ L10 ≠ 37 · L11 ≠ 11 · L17·L18·L30 이 카드와 다름 ⑩ 테스트에 `name ==`·`opened[0]`·`|| … isTrue`·bool 칸 + if — 하나라도 있으면 반려 신호.
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 만) — 기존 PNG 를 고친 제출은 그 자체로 반려 신호다.
- 🔵 C-47 ⑦ 의 화면 스캔은 파일 이름으로 대상을 고른다(`lib/src/ledger_diffs.dart`·`ledger_repairs.dart`·`lib/src/ledger/**`) — 다른 이름이면 «공허 통과»(검사 0) → 제출 ② 의 «C-47 ⑦ 출력» 3줄로 확인한다.
- 🔵 R5b(`send/_대기/R5b-Bob-A1.md`)는 이 카드 병합 뒤 — 병합 기록 커밋이 R5b 의 `__R5A_SQ__`·실측 표식(시작 기준 N · R5a 라벨 절 끝 상수 · 골든 장수)을 채우고 `send/` 로 옮긴다 · R5b~R5e 이월 부록 = 이 카드 C4 결과로 다시 만든다(K47 · 12 §3 «R5a C4 이월 부록» 신설 자리).
- 범위 고지: 01 §8 미결 117(L-2 필터 · 뷰어 원천) · 121(J-3R 링크 · J-2 배지 진입) · 124(L-1 착지 단위)는 이 카드가 닫지 않는다 · 🆕 신설 후보 = «X5·X7 목록의 `hasMore`»(발주자 확인 ①) · ⑩ 의 M2 후보 3건 · «`applicable == false` 표본(L-1 입력)»(②).

## 6. 이월 부록 — ✅ K47(R4a·R4b C4 이월 두 블록 · 이 카드에 옮김) + R13a·R13b 이월의 M6 몫

> 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 «R4a C4 이월 부록»·«R4b C4 이월 부록» 블록(K47 · 2026-10-22 발주자 «R5a 카드에 옮긴다») · «R13a C4 이월 부록»·«R13b C4 이월 부록»(M6 에 맞는 항목만 · 셸·홈·M2 몫은 그 부록 그대로). 아래 두 블록은 글자 그대로이고, 맨 아래 표가 «이 카드의 어디에 반영했는가»를 적는다. 🔴 C4r4b-8(계약 PR 후보)은 이 카드 몫이 아니다 — 부록에 그대로 둔다. R5b~R5e 는 이 카드의 C4 결과로 다시 이월한다(카드에는 공통 교훈만).

```text
■ R4a C4 이월(C4 R4a 1회차 · 2026-10-21 · PR #57 3bcd5ca) — 다음 화면 카드 조립 때 붙임
C4r4a-1 ✅ R4b 반영(발주자 결정 2026-10-21 — C4a-5 = 카드 구멍) — Key 를 단 빈 문장은 경우 표의 bool 칸(want ? findsOneWidget : findsNothing)만으로 보지 않는다:
    경우 표의 빈 칸 = 기대 글자(String?) · 있으면 tester.widget<Text>(find.byKey(<빈 문장 Key>)).data == <VM>.emptyLabel · 없으면 findsNothing(if/else 짝) ·
    카드 조립 체크리스트에 «Key 를 단 Text 마다 최소 목록에 글자 단언이 있는가» 한 줄.
    까닭 = C4a-5 — R4a 규칙 10 은 «Key 를 단 Text 는 글자까지» 인데 최소 목록 T61-12 가 h61-empty 를 bool 꼴로만 정했고 드라이런도 같았다 · 그 글자 변이는 h61_empty 골든(글자 길이)만 본다.
    넣은 자리 = R4b 카드 규칙 10 «빈 문장» 견본 · T63-11(alloc_empty · empty_next_loading · empty_next_fail) · H6-3 예고 변이 «빈 문장 글자 바꾸기» · 다음 화면 카드 조립 체크리스트.
C4r4a-2 ⬜ 후보(발주자 미결정) — 뷰어·가림 갈래에도 «화면 Text 전부» 단언(…Allowed(viewer)).
    까닭 = C4a-6 — 참고 변이 X06(뷰어에 «숨김» 덧붙임)이 위젯·골든 통과(정적 S19 몫) · 자리 = 다음 카드 «화면 Text 전부» 경우 목록(R4b T62·T63 뷰어 갈래 후보).
C4r4a-3 ⬜ 후보 — «경고 아이콘 0» 을 특정 아이콘 2개 부재 대신 «행 안 Icon 수 == 칩 아바타 수(트랜치 + 배지)» 로.
    까닭 = C4a-8 — M22b(report_problem 아이콘)는 골든만 잡음 · 자리 = 다음 카드 RECON 테스트 견본.
C4r4a-4 ⬜ 후보 — «정적 글자 하나 더하기» 를 겹친 글자까지 잡게(find.text(<라벨>) 를 findsNWidgets(<펼친 행 수>) 로).
    까닭 = C4a-8 — M43a(«진입일» 겹침)는 골든만 잡음(allowed 는 집합이라 겹침을 못 봄) · 자리 = 다음 카드 «화면 Text 전부» 견본.
C4r4a-5 ⬜ 후보 — 카드 «갈래를 고르는 것 … 뿐이다» 목록과 «칩 목록 0 = 칩 줄 0» 을 한 뜻으로(목록에 «칩 목록 비었는지(.isNotEmpty)» 를 넣거나 «빈 Wrap 그대로» 를 못박기).
    까닭 = C4a-9 — Bob 은 가드 · 드라이런은 가드 없음(동치 · 위반 아님) · 자리 = 다음 카드 글자(R4b 카드 «화면 2» 의 «갈래를 고르는 것은 …» 줄에 같은 문장 — 이번 기록에서는 고치지 않음).
C4r4a-6 ⬜ 후보(infra 후보 포함) — 보고 표기 재발 방지: (ㄱ) ② 10항 «코드 블록으로 감싸지 않는다» (ㄴ) 정적 묶음 «출력 줄 수 = <드라이런 줄 수>(EXIT 줄 포함)» 자기 확인
    (ㄷ) 질문 측정 행 = 이름마다 값 자리만 빈 복사 상자 · 사전검사에 측정 행 꼴 검사.
    까닭 = C4a-1 · C4a-2 · C4a-3(측정 괄호 자리 = R3 C3-6 → R4a 두 번 연속) · 자리 = 다음 카드 ■ 제출 · infra PR(tool/precheck.dart).
C4r4a-7 ⬜ 후보 — 제출 글 누락 재발 방지: ■ 제출 첫 줄 «채팅 답 = 제출 글 ①~⑤ 전문(재료·요약이 아님)» · N3 사전검사 ② 를 «🔴 0 이어야 낸다» 앞에 한 번 더.
    까닭 = C4a-15(Bob 이 재료만 냄 → 발주자 예외로 글만 다시 받음) · 자리 = 다음 카드 ■ 제출.
```

```text
■ R4b C4 이월(C4 R4b 1회차 · 2026-10-21 · PR #62 6b2e00d) — 다음 화면 카드 조립 때 붙임
C4r4b-1 ⬜ 후보(발주자 미결정 · infra PR 포함) — «전제» 견본 한 줄 더: «전제 expect 는 경우를 가르기 전(if 밖)에 · if 안에 두면 늘 참» + 반려 꼴 if (x != null) { expect(x, isNotNull); … } ·
    사전검사 T3 에 «if 조건이 함의하는 단언»(if (a != null) { expect(a…, isNotNull) · 파생 변수 한 단계) 감지.
    까닭 = C4b-1 — R4a C4a-5 를 막으려고 새로 넣은 전제가 if 안에서 죽었다 · T3 가 모양으로 못 봄(R3 C3-2 와 같은 구멍) · 자리 = 다음 카드 규칙 10 · infra PR(tool/precheck.dart).
C4r4b-2 ⬜ 후보 — 카드가 «(전제 …)» 로 적은 자리를 정적 묶음에서 센다(예 git grep -c "activeFlags, isNotEmpty" = 기대 N · 전제 줄 목록 표) · 카드 조립 체크리스트에 «최소 목록의 전제 항목 = 셈 줄» 한 줄.
    까닭 = C4b-2 — 다섯 갈래가 모두 놓쳤고 종합의 «전제» 항목 대조로만 찾았다 · 자리 = 다음 카드 정적 묶음 · 카드 조립 체크리스트.
C4r4b-3 ⬜ 후보(infra PR 포함) — 골든 표: «사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다(🟡 는 PNG 를 다시 볼 신호일 뿐)» 를 🔴 로 · 재드라이런 칸을 «셈 단위 견본» 2행(h62 1 · h63 1)으로 싣기 ·
    사전검사 G1 보강(«상자(안 n)» 의 안 줄 수 비교 · 한 덩어리 줄 누락 · 게이지 + 막대 붙음 · 다크 점).
    까닭 = C4b-3 · C4b-6 · C4b-15 — 16칸이 기계 셈 그대로 · 채팅 «🟡 2» → 글 🟡 0(표를 기계 셈에 맞춘 흔적) · G1 은 «상자(안 글자 n줄)» 의 안 줄 수를 비교하지 않는다 · 자리 = 다음 카드 «보고 규칙»·N3 · infra PR.
C4r4b-4 ⬜ 후보 — 커밋 나누기: «(2) 커밋에는 H6-2 파일만(git add <파일> 로 지정 · git add . 금지)» 한 줄.
    까닭 = C4b-4 — (2) 에 H6-3 전부 · (3) = 테스트 정리만 · 자리 = 다음 다화면 카드 «할 일».
C4r4b-5 ⬜ 후보 — «10항 줄 수» 를 복사 상자 3줄(«10항 줄 수:» · 백틱 세 개 줄 · <출력> · 백틱 세 개 줄)로.
    까닭 = C4b-5 — R4a C4a-1(10항을 코드 블록으로 감쌈)의 반대 방향 재발 · 자리 = 다음 카드 ■ 제출.
C4r4b-6 ⬜ 후보 — 픽스처는 main() 머리에서 final 로 읽는다(setUpAll + late 금지) → 경우 칸에 픽스처·스트림 공장·시계를 직접 넣는다(caseName 이름 비교 if 사슬 0).
    까닭 = C4b-8 — 경우 자료를 caseName 비교 if/else-if 사슬로 고름(T62-07 · T63-02 · T63-09 · T63-11 · 단언 약화 0) · 자리 = 다음 카드 «테스트 최소 목록» 공통.
C4r4b-7 ⬜ 후보 — 가짜 스트림 공장 = 받은 call 인자로 삼항(call == 0 ? Stream.error(…) : Stream.value(…)) 견본 · 따로 세는 변수 0.
    까닭 = C4b-7 — 가짜 공장 안 early-return if 6곳(holding_detail_test 690·707·711·728 · holdings_allocation_test 864·877 · 단언·건너뛰기 0 · 사전검사 T1 정의상 제외 — C4 보고 §9-3 미결정) · 자리 = 다음 카드 규칙 10 견본.
C4r4b-8 ⬜ 후보(계약 PR) — 뷰어(K15 · pnlToggleLabel null) 표본 · GateState.block 게이트 표본.
    까닭 = C4b-12 — 참고 변이 X06(뷰어 토글 null 인데 그림) · X11(block 아이콘 바꿈)이 SURVIVED(표본 없음 · 판정 밖) · 자리 = 01 §8 미결/픽스처 보강 후보.
```

| 항목 | 이 카드에 반영한 자리(R5a) | R5b~R5e 몫 |
|---|---|---|
| C4r4a-1(✅ R4b 반영) | 규칙 10 «빈 문장» 견본(`l2-empty`) · L2-05 · 예고 변이 «빈 문장 글자 바꾸기» | 같은 견본(A-1 `a1-empty` · 「지난 안내」 `ah-empty` · L-3 `sessionClosedText`·`blockedText`) |
| C4r4a-2 | 해당 장면 없음(L-1·L-2 뷰어 갈래 = 셸 · 엔진 `actionLink` null — 뷰어 표본 0) | R5b `a1_viewer` · R5c `a2_viewer` 의 «화면 Text 전부» |
| C4r4a-3 | L1-02 · L2-04 «행 안 Icon 수 == 1» | A-1 급함 아이콘 · 배지 |
| C4r4a-4 | L1-01 `ledgerCandidateOrigins`·`ledgerEvidence` `findsNWidgets(4)` · 규칙 10 | 겹치는 정적 라벨 전부 |
| C4r4a-5 | 규칙 5 끝 «칩 목록이 비어도 Wrap 그대로 · 갈래 0» · 예고 변이(참고) | `reasons`·`recordedDeviationChips` |
| C4r4a-6 (ㄱ)(ㄴ)(ㄷ) | ■ 제출 ② «코드 블록으로 감싸지 않는다» · 정적 묶음 «출력 줄 수 125 자기 확인» · ■ 질문 파일 측정 행 복사 상자 6줄 | 같은 꼴 |
| C4r4a-7 | ■ 제출 «채팅 답 = ①~⑤ 전문» · N3 «끝 줄 🔴 0 확인 뒤» | 같은 꼴 |
| C4r4b-1 | 규칙 10 «전제는 if 밖 · 자리 = testWidgets 본문 첫머리» + 반려 꼴 | 같은 꼴 |
| C4r4b-2 | 정적 L30 `// pre$` 셈 = 최소 목록 (전제) 수(8 · 9) | 같은 꼴 |
| C4r4b-3 | 보고 규칙 «G1 출력 옮기지 않음 · 🟡 지우려 고치지 않음» 🔴 · ③ «셈 단위 견본 2행»(드라이런 2026-10-28 이 채움) · N3 «G1 🟡 2 예상 — 칸 고치지 않음» | 같은 꼴 |
| C4r4b-4 | ■ 할 일 «커밋마다 git add <파일>» · (2) = L-1 파일만 · (3) = L-2 파일만 | 같은 꼴 |
| C4r4b-5 | ■ 제출 «23항 줄 수» 복사 상자(바깥 울타리 백틱 네 개) | 같은 꼴 |
| C4r4b-6 | 규칙 10 «픽스처 = main() 머리 final · 경우 칸에 직접 · 이름 비교 if 사슬 0» | 같은 꼴 |
| C4r4b-7 | 규칙 10 «가짜 공장 = call 삼항» · L1-08 · L2-07 | 같은 꼴 |
| C4r4b-8 | 🔴 이 카드 몫 아님(계약 PR 후보 — 부록 그대로) | M2 창 |
| C4r13a-1 | 예고 변이 머리 «갈래마다 — 행 있을 때 · 빈 갈래 · 오래됨 · 에러» · L1-10 빈 슬라이스 · L2-05 빈 갈래 · L1-07·L2-06 오래됨 | 같은 꼴(`emptyLabel`·`sessionClosedText`·`blockedText` 갈래) |
| C4r13a-2 | 규칙 10 «X 0(Y 0) 괄호 단언 금지 — 따로» | 같은 꼴 |
| C4r13a-4 · C4r13b-2 | 규칙 10 «bool 칸 + if · name ==·which == · expect(a ‖ b, isTrue) = 반려» + 정적 L31(infra 보강은 부록 그대로) | 같은 꼴 |
| C4r13a-5 | Key 표 «다는 자리» 칸 · «두 자리에 달면 반려» · 정적 L19 이름마다 1줄 | 같은 꼴 |
| C4r13a-6 | ③ «채운 견본» 서술 · ⑤ «없음» 🔴 | 같은 꼴 |
| C4r13a-7 · C4r13b-7 | ■ 할 일 «(5) 뒤 커밋 0 · 사전검사 ① 수정·주석 고침 = (6) 하나 · 금지 낱말 미리 돌리기» | 같은 꼴 |
| C4r13a-8 | 정적 묶음 설명 «L07·L22 는 주석도 센다 · L25 labels.dart 첫째 수 = 재량 · 삭제 0 만» | 같은 꼴 |
| C4r13b-1 | 규칙 11 · ■ 골든 «🔴 높이는 늘리지 않는다(카드 확정값)» · 측정 행 «< 844»·«< 1200» = 높이 리터럴(드라이런이 채움) | 같은 꼴 |
| C4r13b-3 | ■ 제출 N3 «출력 끝 줄 🔴 0 확인 뒤에만» · S05 결과 «출력 줄 수만큼» | 같은 꼴 |
| C4r13b-6 | 규칙 10 «화면 Text 전부» 허용 집합 «링크·경로 문자열 0» · 예고 변이 «링크 글자를 화면에 그리기(탐침)» | 같은 꼴 |
| C4r13a-3 · C4r13a-9 · C4r13b-4 · C4r13b-5 | 해당 없음(셸·홈·M2 몫 — 그 부록 그대로) | — |
