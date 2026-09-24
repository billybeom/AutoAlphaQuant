# 발송 패킷 R2-Bob-J2J3 — J-2 거래 상세 · J-3 사전 저널(폰 전용) · J-5 UNKNOWN 보드 + J-1 후속 A14~A16(+A17) (계약 v1.1)

> 만든 날 2026-09-23 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R2 행 · 조문 = `01_…` §11-10(+ §8 미결 47~50) · `02_…` §3-2·§3-3·§3-5 «🆕 계약 v1.1 — R2 범위» 블록.
> 사전 조건 — ✅ R1b-Bob-J1 병합(PR #7 `b85a532` · 2026-09-22) · ✅ **M2 보강 PR 2건 병합**(2026-09-24 · infra PR #9 `cd5b9f1` · M2 PR #10 `3eb12c1`): infra PR ①(골든 하네스 DEBUG 배너 제거 + 기존 골든 34장 재생성) · M2 PR ②(받침대 `UnimplementedCommandApi`·`UnimplementedSafetyRepository` · 접수증 픽스처 `m6/journal_draft_receipts_5.json` · `JournalDraftRejectCodes` · TARGETS T-3 · golden README) — 병합 확인은 본문 0단계의 확인 세 줄로(`ls` 2 = 카드·② · `git grep` 1 = ①).
> 🔴 **올리는 순서(Claude)** — 이 패킷 파일은 ①·② 가 **둘 다** 병합된 뒤 **별도 커밋**으로 `main` 에 올린다(② 에 싣지 않는다). ② 에 실려 먼저 들어가면 `ls` 두 줄이 같은 병합 하나만 증명하게 된다 — ① 없이 찍은 새 골든 30장에는 DEBUG 리본이 박힌다.
> 프롬프트 = `docs/ai-context/prompt_M6.md`(범위 치환판) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 — 0단계·규칙 요약을 본문에 담았습니다.

## 0. 한 줄 목적

J-1 행을 누르면 열리는 거래 상세(J-2)·사전 저널 폼(J-3, 폰 전용)·UNKNOWN 보드(J-5)를 계약 v1.1 그대로 만들고, J-1 테스트의 빈틈 4가지(A14~A17)를 막아 브랜치로 받기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-j2-detail`**(base = 최신 `origin/main` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. ✅ **「푸시해」 완료(2026-09-24)** — M2 보강 PR #9(`cd5b9f1`)·#10(`3eb12c1`) 병합 · 이 패킷은 그 뒤 별도 커밋으로 `main` 에 올라갔습니다. **바로 보내도 됩니다**(0단계 확인 세 줄이 보여야 정상 — 안 보이면 멈추는 것이 안전장치).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)**.
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R2-Bob-J2J3.md`** 에서 엽니다(Bob 폴더는 옛 브랜치라 안 보입니다).
4. 붙여넣을 것은 «3» 본문 **전부**(«R2-Bob-J2J3 — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 파일 이름 주의 — `send/` 바로 아래에서 지금 보낼 패킷은 **이것 하나**입니다(`_완료/R2-Gem-S73.md` 는 끝난 카드 · 09-22 비슷한 이름의 옛 카드로 Bob 이 8시간 멈춘 사고).

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R2-Bob-J2J3 — 범위: J-2 거래 상세 · J-3 사전 저널(폰 전용) · J-5 UNKNOWN 보드 + J-1 후속 A14~A16(+A17)(테스트 보강 + 코드 한 줄).
하지 않는 것: J-4·H·L·A 화면 · J-2 웹 2열 · J-3 초안 영속화·저널 읽기 뷰(→ 다음 카드 R2b-Bob-J3) · 주문을 조작하는 「재시도」·「강제 취소」 · 브로커를 다시 부르는 「재조회」 ·
  「강제 해소」·게이트 통과·차단 해제 버튼. (에러 상태의 JournalLabels.retry «다시 시도» = 화면 재구독 — 공통 상태라 필수. 위 금지와 다르다.)
🔴 이 카드가 docs/ai-context/prompt_M6.md 보다 이깁니다(106행 «※ 첫 과제는 «J-1 하나»» 와 아래 «프롬프트보다 이 카드가 이긴다» 9항 포함).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R1b(PR #7 · ui/m6-j1-complete · 2026-09-22 병합·종료)가 아닙니다. ui/m6-j1-complete · ui/m6-j1-timeline 은 건드리지 않습니다(삭제도 안 함).
지금 코드에는 J-2·J-3·J-5 파일이 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-j1-complete 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m6-j2-detail origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있을 수 있어 git 이 거부합니다.
     ← --no-track: origin/main 을 추적하지 않게(제출은 git push -u origin ui/m6-j2-detail 로 명시).
  git merge-base --is-ancestor b85a532 HEAD && echo OK                      ← OK
  ls docs/ai-context/send/R2-Bob-J2J3.md                                    ← 보여야 올바른 기준(이 카드가 main 에 있다)
  ls packages/domain_contracts/fixtures/m6/journal_draft_receipts_5.json   ← 보여야 M2 보강 ② 가 들어 있다
  git grep -c "debugShowCheckedModeBanner: false" -- packages/ui_journal/test/golden/golden_support.dart
                                                                            ← «…golden_support.dart:1» 이어야 골든 하네스 보강 ① 이 들어 있다
     (하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 && 앞뒤를 한 줄씩 따로 돌리고 첫 줄의 종료 코드($LASTEXITCODE == 0)를 본다)
  melos.bat bootstrap
  melos.bat run build:gen   ← 브랜치를 바꿨으니 생성물 재생성(안 하면 «타입 없음·when 모호» 가짜 오류). «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
git stash list 의 «WIP on ui/m6-j1-timeline …» 은 옛 R1 사본입니다 — pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 우선순위 = 코드(DTO·인터페이스) > 이 카드(지시) > 01 §11-10 > 02 «R2 범위» 블록 > 02 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_journal 만(+ inbox/ 질문 파일). 고치면 반려: domain_contracts/**(픽스처 포함) · pubspec.yaml · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·j1_golden_test·README · goldens/j1_*.png.
 2 02 본문의 구 초안(chainOf·«M2 미정의»·snake_case·리터럴 문구·그림)은 02 «R2 범위» 블록·01 §11-10 에 집니다.
 3 이동 = AppLinkOpener.open(link) 하나 · 'aaq://'·'handbook://' 리터럴·조립·파싱 금지(lib·테스트) · 링크 null = 부재(비활성 아님) · 이동 콜백 매개변수 금지.
 4 값 = DTO 의 *Text·*Label·*Line·label 그대로 · 원값(Decimal·double·int·DateTime)·.wire·rawValues 표시 금지 · 폴백 문구 금지.
 5 stageCode·stepId·flagId·fillOrigin·operatingMode 로 문구·아이콘·갈래를 고르지 않음 · 목록을 거르지도 세지도 정렬하지도 않음.
   예외(J-1 코드 그대로 옮겨 씀 · 02 §2-2) = 규칙 6 의 FlagIds.markerOnly 로 배너/표식 칩 나누기 · 차단 상위 2 + '+N' · 사유 칩 reasons.take(3) + '+N'.
 6 가림은 엔진이 *Text 안에서 끝냄(숨김 if 금지 · 배너만) · 차단 배너 = J-1 규칙(엔진 순서 · FlagIds.markerOnly · 상위 2 + '+N').
 7 한국어 리터럴 = labels.dart 의 JournalLabels 에만 · 테스트에도 금지(기대값은 픽스처 — singleFixture·listFixture·journalFixture·safetyFixtureRow).
 8 시계 = journalClockProvider(DateTime.now() 금지) · 공통 상태 = 01 §11-10 «봉투 없는 VM 의 공통 상태»(스켈레톤 · JournalLabels.retry + ref.invalidate · stale 배너).
 9 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지) · 띠 높이 예약 금지 · Row 안 엔진 문자열은 Expanded/Flexible · FittedBox 금지 · 말줄임은 configHash 1줄만 · 390px overflow 0 · 색 = colorScheme.
10 주입 프로바이더만 throw 기본값(데이터 프로바이더는 throw 금지) · 이름·타입은 아래 «주입 구조» 고정 ·
   오프너(journalLinkOpenerProvider)·CommandApi(journalCommandApiProvider)는 탭·제출 콜백 안에서 ref.read — build 에서 watch·read 금지(골든은 둘 다 주입하지 않는다).
11 테스트 = testing.dart 받침대 extends(새 가짜에 implements 금지) · 받은 인자 전부 기록 · 전제는 expect(조용한 return 금지) · 동작은 UI 를 실제로 조작해서 ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 링크는 RecordingLinkOpener 를 픽스처 값과 비교.
12 골든 = (6)의 30장만 신규 · --update-goldens 는 새 파일 3개를 지정 · j1_*.png 가 M 이면 되돌리고 멈춤 · golden:approved 는 안 붙임.
13 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · package:collection 없음(.cast<T?>().firstWhere(..., orElse: () => null)) ·
   bash tool/check_boundaries.sh 의 🟡 = 비-UTF-8 셸에서 timeline.dart:102 의 영어 문자열 속 '—' 를 한국어로 잘못 보는 것(CI·LANG=C.UTF-8 에서는 0건) —
   새 🟡 가 '—'·'·' 같은 기호 때문이면 무시, 한국어 글자면 labels.dart 로 옮긴다.
14 모르는 것·문서에 없어 정한 것은 질문 파일에(생략해도 적는다) · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.

■ 프롬프트보다 이 카드가 이긴다 (prompt_M6.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 12~13행 라우트 상수 딥링크 → DTO 링크 필드를 AppLinkOpener.open 에(AppRoutes.* 안 씀) ② 38~41행 자리표시자 → 링크 null = 부재 ③ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9)
 ④ 98~99행 TODO(question-3) → 질문 파일로 ⑤ 106행 «J-1 하나» → 이 카드 범위 ⑥ 116행 브랜치 예시 → ui/m6-j2-detail ⑦ 120행 «열거값 미확정» → FillVisibility 확정 · 문구 분기 금지는 그대로
 ⑧ 153행 «웹·iOS 빌드에 폼 포함 금지» → 방법 = 배럴 밖 package:ui_journal/journal_draft.dart(docs/TARGETS.md T-3) · 플랫폼 판정 금지 ⑨ 155~157행 «J-2·J-3·J-5 미정의» → v1.1 로 확정(미정의는 J-4 뿐).

■ 먼저 읽을 것 (🔴 03~05 명세는 읽지 않음)
 ① prompt_M6.md 전문 ② 02 §2 + §3-2·§3-3·§3-5 의 «🆕 계약 v1.1 — `J-x` R2 범위» 블록(각 절 «모의 데이터» 줄 바로 아래 · 그림 앞 — 절 끝이 아님) ③ 01 §11(11-1·11-2·11-3·11-7·11-10) + §8 미결 47~50
 ④ packages/domain_contracts/lib/ — src/dto/journal.dart **전문**(DecisionSnapshot·ThresholdCompare·RejectTrace·JournalDraftFormSpec·UnknownResolutionStep·DecisionChainStep 이 DecisionDetailVm 보다 위에 있다) ·
    src/dto/common.dart · src/dto/rebalance.dart(TriggerSnapshot) · src/dto/advice.dart(ReasonOption.requiresNote) · src/dto/safety.dart(SafetyState·BlockFlag) · src/labels/flag_ids.dart ·
    src/enums/ui.dart(GateState·ChipTone) · src/navigation/app_links.dart(AppLinkOpener) · src/repositories/journal_repository.dart · src/commands/command_api.dart·command_receipt.dart ·
    src/enums/command.dart · testing.dart ⑤ packages/ui_journal/test/golden/README.md 끝 «🆕 R2 — 새 화면 베이스라인을 찍는 규칙» ⑥ docs/TARGETS.md T-3 · inbox/README.md · inbox/J1_questions.md A14~A17

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용 — lib/src/timeline.dart 에 그대로(이름·위치 불변): journalTimelineRepositoryProvider(J-1·J-2·J-3·J-5 공용) · journalSafetyRepositoryProvider · journalClockProvider ·
  journalLinkOpenerProvider · journalSafetyStateProvider. 새 파일은 상대 import(예 import 'timeline.dart';).
· 🆕 (주입 1 + 데이터 3 — 이 모양 그대로):
    lib/src/journal_draft/journal_draft_form.dart:
      final journalCommandApiProvider = Provider<CommandApi>((Ref ref) => throw UnimplementedError('journalCommandApiProvider'));
      final journalDraftFormSpecProvider = FutureProvider.family<JournalDraftFormSpec, String>(
          (Ref ref, String decisionId) => ref.watch(journalTimelineRepositoryProvider).draftFormSpec(decisionId));
    lib/src/decision_detail.dart:
      final journalDecisionDetailProvider = StreamProvider.family<DecisionDetailVm, String>(
          (Ref ref, String decisionId) => ref.watch(journalTimelineRepositoryProvider).watchDecisionDetail(decisionId));
    lib/src/unknown_board.dart:
      final journalUnknownBoardProvider = StreamProvider<UnknownBoardVm>(
          (Ref ref) => ref.watch(journalTimelineRepositoryProvider).watchUnknownBoard());
· 위젯(decisionId 는 셸이 라우트 :decisionId 에서 꺼내 생성자로 준다 — 화면은 링크를 파싱하지 않음 · 01 §11-10):
      const JournalDecisionDetail({super.key, required this.decisionId});   // ConsumerWidget
      const JournalDraftForm({super.key, required this.decisionId});        // ConsumerStatefulWidget
      const JournalUnknownBoard({super.key});                               // ConsumerWidget
· 배럴 lib/ui_journal.dart = 머리 주석 유지 + export 2줄('src/decision_detail.dart' · 'src/unknown_board.dart'). 🔴 J-3 은 배럴에 넣지 않음 — 새 라이브러리
  lib/journal_draft.dart 가 'src/journal_draft/journal_draft_form.dart' 를 export(머리 주석 «operator 앱 전용 · iOS·웹 앱은 import 하지 않는다 · TARGETS T-3»).
  🔴 lib/journal_draft.dart·lib/src/journal_draft/ 를 뺀 나머지 lib 파일(배럴 · timeline.dart · decision_detail.dart · unknown_board.dart · common/)은 journal_draft 를 import 하지 않는다
     — 배럴이 export 하는 파일이 끌어오면 J-3 폼이 전이로 iOS 빌드에 들어간다(방향은 journal_draft → 배럴 쪽 파일만 허용).

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M6] R2 (1) J-1 후속 A14~A17») · 테스트는 그 단계 커밋에 함께

(1) J-1 후속 A14~A17 — 파일 2개뿐(lib/src/timeline.dart 한 줄 · test/timeline_test.dart) · J-1 골든 16장 불변 · 기존 _FakeSafetyRepository(implements)는 그대로.
    준비(main() 안 · filterCatalog 정의 바로 다음 — 그보다 앞이면 컴파일되지 않음 · 픽스처에서 읽는다):
      final DateRange nonDefaultPreset = rangePresets4.firstWhere((DateRange r) => !r.isDefault);
      final String reId = journal30.rows.firstWhere((TradeJournalEntry e) => e.rebalanceEventId != null).rebalanceEventId!;
      final FillOriginOption originPick = filterCatalog.originOptions.first;
    A14 _FilterSheetState._apply() 의 «origin: _origin,» 다음 줄에  rebalanceEventId: widget.initialQuery.rebalanceEventId,
        (시트 안에 «q» 는 없음 · 시트 상태 필드 신설 금지). 가짜 watchTimeline 의 calls.add 맵에 'rebalanceEventId'·'mode'·'limit' 추가.
        🆕 '③d filter apply keeps rebalanceEventId from the initial query': _pump(… query: JournalTimelineQuery(range: defaultPreset, rebalanceEventId: reId),
          rangePresets: rangePresets4, filterCatalog: filterCatalog)(기존 ③ 과 같은 인자) → 전제 calls.first['rebalanceEventId'] == reId → 「필터」 → 상태 선택지(③ 과 같은 REVERSED) 탭
          → 「적용」 → calls.last 의 status == pick.status · rebalanceEventId == reId.
        🆕 '③e filter reset clears rebalanceEventId too': _pump(… query: JournalTimelineQuery(range: nonDefaultPreset, rebalanceEventId: reId),
          rangePresets: rangePresets4, filterCatalog: filterCatalog) — 🔴 rangePresets 필수(없으면 초기화 뒤 기본 프리셋을 풀지 못해 새 호출이 나지 않고, 실패가 _reset 탓처럼 보인다)
          → 전제 2개(calls.first['rebalanceEventId'] == reId · calls.first['range'] == nonDefaultPreset) → 「필터」 → 「초기화」
          → calls.last 의 rebalanceEventId == null · range == defaultPreset. 🔴 _reset() 은 고치지 않음(회차 조건은 칩이 없어 안 보임 · 01 §8 미결 49).
    A15 ③a: 시작 = JournalTimelineQuery(range: nonDefaultPreset, status: pick.status) + 전제 calls.first['range'] == nonDefaultPreset.
        ③b: 시작 = JournalTimelineQuery(range: nonDefaultPreset, status: pick.status, origin: originPick.origin, rebalanceEventId: reId) · ✕ 는 상태 칩 «안의» 것:
            find.descendant(of: find.widgetWithText(Chip, pick.label), matching: find.byIcon(Icons.close)) → findsOneWidget → ensureVisible → tap
            → calls.last: status null · range == nonDefaultPreset · origin == originPick.origin · rebalanceEventId == reId.
        ③c: 시작에 sleeve: SleeveId.pot · origin: originPick.origin 추가 → pick.status.wire · SleeveId.pot.wire · originPick.origin.wire 모두 findsNothing.
    A16 ⑦: 대상 = safetyFixtureRow(2)(차단 플래그 · clearDeepLink 없음) · «if (!anyNullLink) { return; }» → expect(anyNullLink, isTrue, reason: '…') ·
            그 플래그 label findsOneWidget · Icons.arrow_forward_ios findsNothing · 틀린 주석을 사실대로.
        🆕 '⑦b BlockFlag with clearDeepLink shows arrow; tap opens that link': halted = safetyFixtureRow(3) + RecordingLinkOpener ·
            links = halted.activeFlags.where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId)).take(2).map((BlockFlag f) => f.clearDeepLink).whereType<String>().toList()
            → expect(links.length, 2, reason: '…') → 화살표 findsNWidgets(2) → 첫 화살표 탭 → expect(opener.opened, <String>[links.first]).
        ⑧: «if (integrityFlag?.checkpointLabel == null) { return; }» → expect(integrityFlag?.checkpointLabel, isNotNull, reason: '…').
    A17 ⑥(이름은 «… chip tap fires chip.detailDeepLink» 인데 칩 탭 확인이 없음) — 행 탭 다음에:
            final ReasonChip linkedChip = tappableEntry.reasons.firstWhere((ReasonChip c) => c.detailDeepLink != null);
            await tester.tap(find.descendant(of: find.byType(ActionChip), matching: find.text(linkedChip.label)).first);
            await tester.pump();
            expect(opener.opened, <String>[tappableEntry.detailDeepLink!, linkedChip.detailDeepLink!]);   // 기존 contains(...) 대신 · 칩 탭이 행 탭을 함께 부르지 않는다
    J1_questions A14~A17 상태 칸은 고치지 않음. 커밋 전: flutter test test/timeline_test.dart test/golden/j1_golden_test.dart 통과 · j1_*.png 변경 0.

(2) 공통 위젯 추출 — 새 파일 lib/src/common/journal_common.dart(배럴에 넣지 않음). 🔴 렌더 불변 «순수 이동»(패딩·순서·위젯 종류·조건 그대로).
    권고 이름: _AsOfHeader → JournalAsOfHeader · _StaleBanner → JournalStaleBanner · _BlockingFlags(+_BlockFlagCard) → JournalBlockingFlags · _MarkerChips → JournalMarkerChips ·
    _BadgeChip._toneColor → 최상위 Color journalToneColor(BuildContext context, ChipTone tone) · _ReasonChipWidget → JournalReasonChip ·
    _JournalRow → JournalEntryCard({super.key, required this.entry, this.tappable = true})(false 면 InkWell 없음) · _TimelineSkeleton → JournalSkeleton · _TimelineError → JournalErrorView.
    필터·배지·날짜 머리·빈 상태는 timeline.dart 에 남김 · 공통 파일의 import '../timeline.dart'; 순환 import 는 허용.
    JournalBlockingFlags·JournalMarkerChips 는 이미 나뉜 목록을 받는다 — 새 화면의 나누기는 J-1 _TimelineContent 의 두 줄
    (activeFlags.where(!markerOnly) · where(markerOnly))을 그대로 쓴다(규칙 5 의 예외). 머리·신선도는 J-1 과 같게 JournalAsOfHeader·JournalStaleBanner.
    🔴 이 커밋 뒤 flutter test test/golden/j1_golden_test.dart 가 --update-goldens 없이 통과 + j1_*.png 변경 0. 깨지면 되돌려 다시 옮김.

(3) J-5 — lib/src/unknown_board.dart + 배럴 1줄. 02 §3-5 블록 ⓐ~ⓕ 그대로. 보충: 카드 탭 = entry.detailDeepLink · 칸 모양 = step.state(GateState 4값) exhaustive switch(unknown ≠ notApplicable).
    · 머리·신선도·에러의 asOf = vm.asOf · 카드 i 에 Key ValueKey<String>('j5-card-$i')(i = items 받은 순서) · 카드 = InkWell 하나(탭 = entry.detailDeepLink) 안에
      entry 의 symbolLabel·sideLabel·quantityText·statusLabel(Text) + elapsedText + effectLine + steps 4칸 + escalationLink 버튼 — JournalEntryCard 는 쓰지 않음(ⓑ 밖 필드를 그리고 InkWell 이 겹친다).
    · 칸 탭 = step.deepLink(non-null 일 때만 · J-2 체인 칸과 같은 규칙) — 현재 픽스처는 전부 null 이라 테스트 없음(질문 파일 불필요).
    🔴 CommandApi import·호출 0 · stepId 로 문구·아이콘 금지 · 경과·건수 계산 금지 · 「재조회」·「강제 해소」 없음.

(4) J-2 — lib/src/decision_detail.dart + 배럴 1줄. 02 §3-2 블록 ⓐ~ⓙ + 01 §11-10 «J-2» 그대로 · 폰 1열만. 보충:
    · 머리·신선도·에러의 asOf = vm.asOf(🔴 entry.asOf 아님 — entry.asOf 는 체결 당시라 골든 시각에 이미 오래됐다) · JournalAsOfHeader 를 상단에.
    · 고정 Key(테스트가 이것으로 범위를 좁힌다 · 이름 그대로): 체인 컨테이너 const Key('j2-chain') · 단계 행 ValueKey<String>('j2-step-$i')(i = steps 받은 순서 · 코드로 고르지 않음) ·
      링크 버튼 ValueKey<String>('j2-link-parentLink')·('j2-link-rebalanceLink')·('j2-link-journalLink')·('j2-link-amendLink')(필드 이름 그대로 · non-null 일 때만 존재).
    · 상단 요약 = entry 의 symbolLabel·sideLabel·quantityText·statusLabel(색 statusTone → journalToneColor) · 체결 행 = fills 순서대로 JournalEntryCard(entry: f, tappable: false)
      + remainingText·pendingNoticeText(있으면) · 행 안 사유 칩 탭은 살아 있음.
    · 정적 머리: 스냅샷 접이식 JournalLabels.decisionSnapshot(기본 접힘 · snapshot == null 이면 접이식 대신 snapshotMissingLabel) ·
      임계 표 JournalLabels.thresholdCompare(0건이면 머리째 부재) · 거부 추적 접이식 JournalLabels.rejectTrace(기본 접힘 · 0건이면 부재).
    · configHash = 모노스페이스 Text(hash, maxLines: 1, overflow: TextOverflow.ellipsis) · 길게 누르면 await Clipboard.setData(ClipboardData(text: hash));
      (import 'package:flutter/services.dart'; — Flutter SDK 라 pubspec 변경 없음) → context.mounted 확인 뒤 ScaffoldMessenger 로 SnackBar(content: Text(JournalLabels.copied)).
    🔴 chainOf·findByDecisionId·fillChain(조인) · entry·fills 행 탭 · substring · trigger.configHash·entry.decision.configHash 로 채우기 · rawValues·triggerPrice·
       thresholdRegistered 표시 · 국면 배지 · reasonCode 를 리터럴과 비교·분기 · parentDecisionId·rebalanceEventId·플랫폼으로 버튼 판정 — 전부 금지.

(5) J-3 — lib/journal_draft.dart + lib/src/journal_draft/journal_draft_form.dart. 02 §3-3 블록 ⓐ~ⓘ + 01 §11-10 «J-3» 제출 조건·상태 표 그대로
    (CommandState 9값 exhaustive switch · default: 금지 · 문구는 stateLabel 하나). 보충:
    · 입력값 = State 안(TextEditingController 3개 + 고른 ReasonOption) — 화면이 살아 있는 동안만 · 인용 규칙 = 드롭다운(ruleCitedOptions 의 label ·
      긴 label 이 390px 에서 넘치지 않게, 예 isExpanded: true) · deviation.isDeviation 이면 deviation.label 배지 · contextChips 탭 = detailDeepLink.
    · 제출 = ref.read(journalCommandApiProvider).submitJournalDraft(JournalDraft(decisionId: spec.decisionId, …, ruleCited: 고른 code, note: 비면 null))
      → 돌려받은 commandId 로 watchCommand 구독(StreamSubscription 을 들면 dispose 에서 cancel).
    · 머리·신선도·에러의 asOf = spec.asOf · 서약 블록(pledgeLines 가 1줄 이상일 때만)에 Key const Key('j3-pledge-block').
    · 잠금 = 입력란 enabled: false + 드롭다운 비활성 + 제출 버튼 없음 · rejected·expired = 값 그대로 재편집·재제출 ·
      executed = 입력 영역(입력란 3·드롭다운·제출 버튼) 부재 + 그 자리에 stateLabel 한 줄 — 머리·서약·문맥 칩·이탈 배지·noticeLine 은 그대로(입력값을 읽기 글로 다시 그리지 않음 — 읽기 뷰 = R2b).
    · submitJournalDraft 의 Future 가 에러면: 입력값 유지 + 제출 전 상태(문구 없음) — 계약에 없는 동작이라 J3_questions 에 «추측» 행.
    🔴 배럴 export · 저장 패키지·파일 쓰기·pubspec 변경(재시작 생존 = R2b) · 어떤 플래그(FlagIds.ledgerFix 포함)로 제출 버튼 끄기 · kIsWeb·Platform.* ·
       「40자 이상」 같은 안내 문장 · rejectReasonCode 표시·분기 · 낙관 갱신 · 「Android 운영 기기에서만」 안내·읽기 뷰 — 전부 금지.

(6) 골든 — 새 파일 test/golden/j2_golden_test.dart · j3_golden_test.dart · j5_golden_test.dart → 15종 × light/dark = PNG 30장(전부 신규).
    공통: 테스트 파일 안 const Size _kTallPhone = Size(390, 1600);(하네스에 상수 추가 금지 · 모자라면 올리고 질문 파일에) · 15종 모두
      pumpForGolden(tester, <화면>, brightness: b, logicalSize: _kTallPhone, wrapApp: (Widget app) => ProviderScope(overrides: <Override>[…], child: app))
      · FixedClock(kGoldenNowUtc) · safetyFixtureRow(0) · 링크 오프너·CommandApi 주입 안 함(12 만 명령 가짜) · «탭» 항목은 실제로 탭 → pumpAndSettle → expectGolden.
      · 찍기 전 전제(화면 끝이 골든 안에 있는가 — 스크롤 뷰라 잘려도 오류가 나지 않는다): J-2 = expect(tester.getBottomLeft(find.text(vm.journalStateLabel)).dy, lessThan(_kTallPhone.height)) ·
        J-3·J-5 = 그 화면에서 맨 아래에 그린 위젯(J-3 = 제출 버튼 · J-5 = nextBatchNoticeText · j5_empty = emptyLabel)으로 같은 식. 넘치면 높이를 올리고 질문 파일에 그 값을 적는다.
     1 j2_full — m6DecisionDetailFull — 기본(스냅샷 접힘)
     2 j2_full_snapshot_open — m6DecisionDetailFull — 스냅샷 머리 탭(configHash 1줄)
     3 j2_partial — m6DecisionDetailPartial — 기본(임계 미달 · 체결 3행 · remainingText)
     4 j2_unknown — m6DecisionDetailUnknown — 기본(pendingNoticeText · 표·거부 추적 부재)
     5 j2_rejected_saf309 — m6DecisionDetailRejectedSaf309 — 기본(거부 추적 접힘)
     6 j2_rejected_saf309_trace_open — m6DecisionDetailRejectedSaf309 — 거부 추적 머리 탭
     7 j2_reevaluated_child — m6DecisionDetailReevaluatedChild — 기본(parentLink 버튼)
     8 j2_amended — m6DecisionDetailAmended — 기본(advisory 6칸 · snapshotMissingLabel · 체결 3행 · amendLink)
     9 j3_discretion — m6JournalDraftSpecDiscretion — 초기(빈 입력 · 제출 비활성)
    10 j3_recon_clear — m6JournalDraftSpecReconClear — 초기(서약 블록 부재)
    11 j3_rule_menu_open — m6JournalDraftSpecDiscretion — 인용 규칙 드롭다운 탭(메뉴 열림)
    12 j3_rejected — m6JournalDraftSpecDiscretion + m6JournalDraftReceipts5 — UI 로 사전 근거 'a' * spec.rationaleMinChars · 기대 결과 'b' ·
       requiresNote == false 첫 선택지 → 제출 탭 → 가짜 submitJournalDraft = REQUESTED 행 · watchCommand = REJECTED 행 → pumpAndSettle
    13 j5_two_open — m6UnknownBoard2 — 전체
    14 j5_long_open — m6UnknownBoard2 슬라이스 — vm.copyWith(items: vm.items.where((UnknownResolutionItem i) => i.emphasized).toList()) · 전제 expect(slice.items.length, 1)
    15 j5_empty — m6UnknownBoardEmpty — 빈(emptyLabel)
    명령(packages/ui_journal 에서 — 🔴 폴더가 아니라 파일 3개. 폴더를 주면 J-1 16장이 다시 찍힘 · 하네스 주석·golden README «🆕 R2» 도 같은 규칙):
      flutter test --update-goldens test/golden/j2_golden_test.dart test/golden/j3_golden_test.dart test/golden/j5_golden_test.dart
      flutter test   ← 옵션 없이 전부 통과 · git status ← 새 PNG 30장만 ?? · j1_*.png 가 M 이면 커밋하지 말고 git checkout -- <그 파일> → 멈추고 채팅으로

■ 정적 라벨 — JournalLabels 에 절 주석(// ── 🆕 R2 — J-2 거래 상세 ── 등)과 함께. 권고(필드·머리 이름만):
   decisionSnapshot '결정 당시 스냅샷' · thresholdCompare '트리거 값 vs 사전 등록 임계값' · rejectTrace '검사 기록' · copied '복사했습니다' ·
   draftRationale '사전 근거' · draftExpected '기대 결과' · draftRuleCited '인용 규칙' · draftNote '메모' · draftSubmit '제출'.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적음. 🔴 noticeLine·서약문·stateLabel·거부 사유·빈 상태·not-found 문구는 옮기지도 만들지도 않음.

■ 테스트 최소 목록 (새 파일 test/decision_detail_test.dart · journal_draft_test.dart · unknown_board_test.dart)
공통: ProviderScope 는 MaterialApp 위(J-1 _pump 모양) · 긴 화면은 J-1 _pump 의 뷰포트 4줄을 높이만 바꿔 그대로
  (tester.view.physicalSize = const Size(390, 1600) + tester.view.devicePixelRatio = 1.0 + addTearDown(tester.view.resetPhysicalSize) · addTearDown(tester.view.resetDevicePixelRatio)
  — DPR 을 빼면 기본 3.0 이라 논리 폭 130 이 되어 전부 overflow) 또는 scrollUntilVisible · 안전 상태 가짜 = extends UnimplementedSafetyRepository(값 = safetyFixtureRow(n)) ·
  세 화면 모두 공통 상태 4종: 첫 값 전 스켈레톤(find.byType(JournalSkeleton) — 테스트에서 import 'package:ui_journal/src/common/journal_common.dart'; 허용) ·
  에러 → JournalLabels.retry 탭 → 가짜 호출 수 증가 · FixedClock(kGoldenNowUtc) 에서 JournalLabels.staleBannerTitle findsNothing(머리의 asOf 가 VM 최상위 것인지 증명) →
  FixedClock(kGoldenNowUtc.add(const Duration(days: 2))) 에서 보임 · safetyFixtureRow(3) → 차단 카드 2장.
  정상 상태 테스트는 «에러 상태 없음»(JournalLabels.retry findsNothing)도 함께 단언 — 프로바이더 안에서 던진 오류는 에러 상태로 삼켜져 테스트가 초록일 수 있다.
J-2 (가짜 extends UnimplementedJournalRepository — watchDecisionDetail 이 받은 decisionId 기록)
 · 6 픽스처: 단계 i 의 글자는 그 행 안에서 찾는다 — find.descendant(of: find.byKey(ValueKey<String>('j2-step-$i')), matching: find.text(steps[i].stageLabel)) findsOneWidget ·
   stateLabel 도 같은 식(«완료»·«체결»·«거부» 는 화면 여러 곳에 있어 find.text 만으로는 «Too many elements») · 6개 행 Key 가 모두 const Key('j2-chain') 의 자손 ·
   순서 = tester.getTopLeft(find.byKey(ValueKey<String>('j2-step-$i'))).dy 가 i 순서대로 커짐 · 위젯에 준 decisionId(= entry.decision.decisionId)가 가짜에 도착.
 · amended: snapshotMissingLabel 보임 · entry.decision.configHash findsNothing / unknown: JournalLabels.thresholdCompare·rejectTrace findsNothing.
 · rejected_saf309: 탭 전 rejectTraces.first.stageLabel findsNothing → 머리 탭 → 보임 + reasonCode 개수 1 증가(체인 detailLines 에도 같은 원문이 있어 «탭 전 findsNothing» 은 틀린 검사).
 · full: 스냅샷 머리 탭 → configHash 길게 누름 → 받은 텍스트 == snapshot!.ref.configHash 전문 · JournalLabels.copied 보임. 클립보드 받기(테스트에 import 'package:flutter/services.dart';):
     tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
       if (call.method == 'Clipboard.setData') { copiedText = (call.arguments as Map<Object?, Object?>)['text'] as String?; }
       return null;
     });   // addTearDown 에서 같은 채널에 null 로 되돌린다
 · 링크 탭 → opener.opened == 픽스처 값: full.rebalanceLink · reevaluated_child.parentLink · amended.amendLink · amended 의 deepLink 있는 단계 · 링크 있는 사유 칩.
 · 링크 버튼 존재 = 6 픽스처 × 4 필드: 링크가 non-null 이면 find.byKey(ValueKey<String>('j2-link-<필드>')) findsOneWidget + 그 안에 link.label ·
   null 이면 findsNothing(→ journalLink 는 6건 모두 null 이라 저널 버튼 부재가 여기서 증명된다 · 양성 3건 = full.rebalanceLink·reevaluated_child.parentLink·amended.amendLink).
 · journalStateLabel 은 6건 모두 보임 · 부재:
   full 의 trigger.rawValues «키»·thresholdRegistered.toString()·entry.price.toString() findsNothing(rawValues 값은 observedText 와 같은 글자라 검사 안 함) ·
   entry.symbolLabel(.first) 탭 → opener.opened 비어 있음.
J-3 (저장소 가짜 = draftFormSpec · 명령 가짜 extends UnimplementedCommandApi — 나머지 11종은 부르면 던진다: 제출 핸들러에서 부르면 테스트 실패 ·
     프로바이더 안이면 에러 상태로 삼켜질 수 있으니 위 «에러 상태 없음» 단언과 함께 «다른 명령 0건»의 증명이 된다)
 · 접수증은 픽스처에서: receipts = listFixture(FixturePaths.m6JournalDraftReceipts5, CommandReceipt.fromJson).rows · receiptIn(CommandState s) => receipts.firstWhere((CommandReceipt r) => r.state == s).
 · 명령 가짜 = submitJournalDraft 가 받은 JournalDraft 를 기록하고 정해 둔 행(보통 REQUESTED)을 돌려줌 · watchCommand 가 받은 commandId 를 기록하고
   Stream<CommandReceipt>.value(정해 둔 행) — 행이 없으면 const Stream<CommandReceipt>.empty(). 시나리오마다 새 가짜(StreamController 는 쓰지 않아도 됨).
 · discretion: find.byKey(const Key('j3-pledge-block')) findsOneWidget + 그 안에 pledgeLines 전부·순서대로 / recon_clear(pledgeLines 0줄 — 전제 expect): 같은 Key findsNothing ·
   스켈레톤 = Completer<JournalDraftFormSpec>().future(import 'dart:async';).
 · 제출 비활성 → 사전 근거 'a' * (min - 1) → 비활성 → 'a' * min → 기대 결과 입력 → requiresNote == false 선택지 탭 → 활성 /
   ruleCitedOptions.firstWhere((ReasonOption o) => o.requiresNote) 를 고르면 메모가 빌 때 비활성 → 메모 입력 → 활성.
 · 제출 탭 → 기록된 JournalDraft 1건: decisionId == spec.decisionId · 입력값 · ruleCited == 고른 code · 메모를 비웠으면 note == null · 구독 id == 돌려준 행의 commandId.
 · watchCommand = 빈 스트림(행 없음 — 제출이 돌려준 REQUESTED 만 있음) → REQUESTED 의 stateLabel · TextField 전부 enabled == false · 제출 버튼 없음 /
   EXECUTED → TextField·DropdownButton·제출 버튼 부재 + stateLabel·noticeLine 보임 / REJECTED·EXPIRED → find.text('a' * min) 그대로 ·
   다시 제출 → 기록 2건 / HELD_FOR_INTEGRITY → 잠금 / REJECTED 행의 rejectReasonCode findsNothing.
 · 드롭다운 탭 → ruleCitedOptions 의 label 전부 · noticeLine·contextChips label·deviation.label 보임 · 링크 있는 문맥 칩 탭 → 그 detailDeepLink.
J-5 (가짜 = watchUnknownBoard)
 · two_open: 두 카드의 글자가 같다(effectLine·단계 title·whyLine · «대기» 는 한 카드에 2번) → 카드 i 안에서 센다: find.descendant(of: find.byKey(ValueKey<String>('j5-card-$i')),
   matching: find.text(t)) findsNWidgets(n) — t = 그 카드의 symbolLabel·elapsedText·effectLine·steps 의 title·stateLabel·whyLine, n = 그 카드의 표시 필드
   (entry 4필드·elapsedText·effectLine·steps 3필드)에서 t 가 나오는 횟수(테스트가 vm.items[i] 에서 센다) · nextBatchNoticeText / empty: emptyLabel · 카드 Key 0.
 · escalationLink 버튼은 한 카드에만(label findsOneWidget) → 탭 → 그 deepLink · 카드 i 의 symbolLabel 탭(카드 Key 안) → 그 entry.detailDeepLink.
(정적 — PR 본문 ② 에 적음) ui_journal.dart 에 journal_draft 0건 · lib/ 에 kIsWeb·Platform. 0건 · FlagIds.ledgerFix 0건 · unknown_board.dart 에 CommandApi 0건 ·
  git grep -n "import .*journal_draft" -- packages/ui_journal/lib ← 나오는 줄이 있다면 전부 lib/src/journal_draft/ 안(그 밖 0건 · 대개 전체 0줄).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md)
· 새 파일 inbox/J2_questions.md · J3_questions.md · J5_questions.md(각 Q1·A1 부터) · J-1 은 J1_questions.md 에 이어서 — A17 은 통합 담당이 이미 넣었으니 Q6·A18 부터.
· 01 §8 미결 47~50(초안 저장 포트 · 저널 읽기 뷰 · 회차 링크 경로 · 국면 배지·정정 행 decision_id·잘못된 decisionId)은 이 카드대로 했다면 다시 적지 않아도 됩니다.
· 꼭 적을 것: J-3 제출 Future 에러 처리(추측) · 권고와 다르게 지은 이름 · 새로 더한 정적 라벨 · 골든 높이를 바꿨다면 그 값 · 문서에 없어 정한 것 전부.
· 🔴 질문 파일은 **브랜치에 커밋**한다(docs/ai-context/inbox/ — 채팅 보고만으로는 제출이 아니다 · R1 반려 사유였다).

■ 제출
  melos.bat run format:fix
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS (먼저 빠르게: cd packages/ui_journal && flutter test)
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git status 에 test/golden/goldens/j1_*.png 가 M 이면: git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로.
  git add packages/ui_journal docs/ai-context/inbox
  git commit -m "[M6] R2 (7) format·질문 파일"   ← format:fix 가 고친 것·질문 파일이 있을 때만(없으면 «nothing to commit» 이 정상)
  git status --short   ← 🔴 비어 있어야 푸시한다(아니면 멈추고 출력을 채팅으로) — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다(R1 1회차 반려 사유)
  git push -u origin ui/m6-j2-detail
  PR 은 만들지 않습니다(통합 담당 대행). PR 제목: [M6] J-2·J-3·J-5 거래 상세·사전 저널·UNKNOWN 보드(+J-1 후속 A14~A16)
     (제목은 고정값 그대로 — prompt_M6.md 의 PR 제목과 같다. A17 은 제목에 없어도 범위에 포함되고 본문 ① 에 적는다)
  PR 본문 5섹션을 채팅으로: ① 화면 ID(J-2 · J-3 · J-5 · J-1 후속 A14~A16(+A17)) ② 자체 점검 10항 — 코드에 실제로 있는 것만 [x](위 «정적» 줄 포함 ·
    9번 «공통 상태 6종» = J-2·J-3 은 4종(빈·부분 동기 해당 없음) · J-5 는 5종(부분 동기 해당 없음) — [x] 로 적고 괄호로 해당 없음을 밝힌다 · 「일부 항목 동기화 중」 칩은 만들지 않는다)
    ③ 스크린샷 서술 — 로딩·정상·빈·차단 최소 4 + 골든 30장 목록(픽스처에 실제로 있는 값만 · 못 본 것은 «미열람» · «기존 골든 재생성 없음» 한 줄) ④ 질문 표 ⑤ 추측한 것(없으면 «없음»)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-j2-detail` 푸시 1건 · 커밋 6개 안팎(본문 (1)~(6)).
- `lib/` 새 파일 5(`src/common/journal_common.dart` · `src/unknown_board.dart` · `src/decision_detail.dart` · `journal_draft.dart` · `src/journal_draft/journal_draft_form.dart`) · 수정 3(`src/timeline.dart` · `ui_journal.dart` export 2줄 · `l10n/labels.dart`).
- `test/` 새 파일 3 + 수정 1(`timeline_test.dart`) · 골든 테스트 새 파일 3 + PNG 30장(전부 신규) · 질문 파일 J2·J3·J5(신규) · J1(새 행이 있을 때만) · 채팅: PR 본문 5섹션.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R2-Bob-J2J3 결과: 브랜치 ui/m6-j2-detail 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R2-Bob-J2J3 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R2-Bob-J2J3 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① `j1_*.png` 가 `M` ② `lib/ui_journal.dart` 에 `journal_draft` export 또는 `lib/src/journal_draft/` 밖의 lib 파일이 `journal_draft` 를 import(둘 다 J-3 이 iOS 빌드에 들어감) ③ `pubspec.yaml` 변경 ④ 화면 코드의 `aaq://` ⑤ J-3 의 「40자 이상」 같은 안내 문장 ⑥ J-5 의 「재조회」 버튼 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 **새 PNG(A)만**이라 **초록이 정상**입니다(빨간색 = 기존 골든 변경 = 반려 신호). `golden:approved` 는 Claude 만 붙이며 이번 카드에서는 붙일 일이 없어야 합니다 — 기존 골든 재생성은 M2 보강 infra PR ① 에서 끝났습니다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 `C:\Work\AAQ-claude`·`C:\Work\AAQ-claude-infra` 에서만).
- 범위 축소 고지: J-3 의 «앱 재시작 뒤 초안 생존»(02 §3-3 수용 (c))·«제출 뒤 읽기 뷰»는 다음 카드 **`R2b-Bob-J3`**(선행 = 01 §8 미결 47·48). 결정 9b(폰 전용)는 그대로이고 iOS 에서도 **빌드 제외**가 됩니다.
