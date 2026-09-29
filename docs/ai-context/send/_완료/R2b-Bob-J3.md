# 발송 패킷 R2b-Bob-J3 — J-3 완성(초안 저장·읽기 뷰·접수 실패 1줄) + R2 잔여 R-1~R-7 (계약 v1.2)

> 만든 날 2026-09-25 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 R2b 행 + «R2b-Bob-J3 부록 — R2 잔여» 블록 · 화면 몫 원본 = 설계 저장소 `10_리뷰/2026-09-25_R2b선행_계약v1.2_설계서.md` §2-16(검증 반영판 — 코드 스케치 · 상태 표 · 테스트 29 · 기존 테스트 손볼 곳) · 조문 = `01_…` §12(+ §11-10 · §8 미결 51·52) · `02_…` §3-3 «🆕 계약 v1.2 — `J-3` R2b 범위» 블록 ⓐ~ⓚ · golden README «🆕 R2b» 절.
> 사전 조건 — ✅ R2-Bob-J2J3 병합(PR #11 squash `f4023f4` · 2026-09-25) · ✅ 계약 v1.2 병합(PR #12 squash `44e8100` · 2026-09-25 — `DraftStore`·`watchDecisionJournal`·`AppRoutes.journalRead`·받침대 `RecordingDraftStore`·픽스처 104 · C-12 ui_* 게이트 가동) — 병합 확인은 본문 0단계의 확인 줄로.
> 51④ 이름·문구 확정(카드 권한 — 01 §12-3): `JournalLabels.submitNotAccepted = '제출이 접수되지 않았습니다. 입력은 그대로 있습니다.'` · 키 `Key('j3-submit-not-accepted')`.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 `prompt_M6.md` 범위·PR 제목 치환(`J-3 (+ R2 잔여 R-1~R-7)`) · `rounds.md` · `send/README.md` 와 **같은 푸시**로 `main` 에 올린다. 0단계의 `ls` 줄이 그 증명이다.
> 프롬프트 = `docs/ai-context/prompt_M6.md`(범위 치환판) — 본문에 붙이지 않고 Bob 이 저장소에서 읽습니다. 🔴 Bob **새 대화** 전제 — 0단계·규칙 요약·상태 표·코드 스케치를 본문에 담았습니다.

## 0. 한 줄 목적

J-3 을 계약 v1.2 그대로 완성하고(초안 저장·복원·재구독 잠금 · `executed` 뒤 읽기 본문 · 읽기 뷰 `J-3R` · 접수 실패 1줄), R2 C4 가 남긴 잔여 R-1~R-7 을 같은 브랜치에서 닫기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m6-j3-complete`**(base = 최신 `origin/main` · `--no-track` — 로컬 `main` 을 거치지 않음).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷(과 `prompt_M6.md` 범위 치환·`rounds.md`·`send/README.md`)을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다.
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R2b-Bob-J3.md`** 에서 엽니다(Bob 폴더는 병합·삭제된 옛 브랜치 `ui/m6-j2-detail` 에 있어 이 파일이 안 보입니다).
4. 붙여넣을 것은 «3» 본문 **전부**(«R2b-Bob-J3 — 범위» ~ «■ 제출» 끝) · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 지금 보낼 패킷은 **이것 하나**입니다. `_완료/R2-Bob-J2J3.md`·`_완료/R2-Bob-J2J3-재제출.md` 는 끝난 카드입니다(09-22 비슷한 이름의 옛 카드로 Bob 이 8시간 멈춘 사고).

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R2b-Bob-J3 — 범위: J-3 완성 = 초안 저장·복원·clear(DraftStore) · lastCommandId 재구독 잠금 · executed 뒤 읽기 본문(JournalReadContent) + 읽기 뷰 J-3R(JournalReadView) ·
  접수 실패 1줄(01 §12-3) · J-2 저널 링크 탭 테스트 + R2 잔여 R-1~R-7(J-2·J-3·J-5 — C4 R2 재제출 부록).
하지 않는 것: J-4 · X7 화면(A-3·A-4·L-3 — 같은 포트지만 이 카드 밖 · 01 §8 미결 52) · J-2 웹 2열 · 셸 가드(iOS «Android 운영 기기에서만» 1줄·웹 부재 가드·라우트 등록 — M8 · 04 §1-2) ·
  실물 저장소(data_sync 암호화 구현 — 06 M4-9) · 초안 «버리기» 버튼(01 §8 미결 53 ⑥) · J-2 저널 버튼 코드 변경(목적지는 엔진이 고른다 — 테스트만).
🔴 이 카드가 docs/ai-context/prompt_M6.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 12항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R2(PR #11 · ui/m6-j2-detail · 2026-09-25 병합·원격 브랜치 삭제)가 아닙니다. ui/m6-j2-detail · ui/m6-j1-* 는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 journalDraftStoreProvider · lib/src/journal_read.dart · JournalLabels.submitNotAccepted 가 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← 지금은 ui/m6-j2-detail 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← «[deleted] … origin/ui/m6-j2-detail» 줄은 정상
  git checkout --no-track -b ui/m6-j3-complete origin/main
     ← 🔴 git checkout main 금지 — main 은 통합 담당 폴더(같은 저장소의 다른 worktree)에 체크아웃돼 있어 git 이 거부합니다.
     ← --no-track: origin/main 을 추적하지 않게(제출은 git push -u origin ui/m6-j3-complete 로 명시).
  git merge-base --is-ancestor 44e8100 HEAD && echo OK                     ← OK(계약 v1.2 병합)
  ls docs/ai-context/send/R2b-Bob-J3.md                                     ← 보여야 올바른 기준(이 카드가 main 에 있다)
  git grep -c "contractVersion = '1.2.0'" -- packages/domain_contracts/lib/src/contract_version.dart
                                                                            ← «…contract_version.dart:1»
  ls packages/domain_contracts/fixtures/m6/draft_records_j3.json            ← 보여야 함
  ls packages/domain_contracts/fixtures/m6/journal_read_written.json        ← 보여야 함(🔴 두 경로를 ls 한 줄에 넣지 않는다 — PowerShell 은 둘째 경로를 필터로 읽어 첫 파일만 보인다)
     (하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다. ls 가 없는 셸이면 dir ·
      && 가 안 되는 셸(Windows PowerShell 5.1)이면 && 앞뒤를 한 줄씩 따로 돌리고 첫 줄의 종료 코드($LASTEXITCODE == 0)를 본다)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수 — 계약 v1.2 새 타입(DraftRecord·DecisionJournalVm …)의 생성물은 git 에 없습니다(안 하면 «타입 없음·when 모호» 가짜 오류).
                              «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
git stash list 의 «WIP on ui/m6-j1-timeline …» 은 옛 R1 사본입니다 — pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · R2 카드 docs/ai-context/send/_완료/R2-Bob-J2J3.md «규칙 요약» 1~14 가 그대로 유효 — 규칙 12(골든)와 규칙 10 끝 괄호 «골든은 둘 다 주입하지 않는다» 는 이 카드 (7)이 대체
   (골든은 링크 오프너만 주입하지 않는다 · CommandApi·DraftStore·읽기 가짜는 (7) 입력대로 주입 — 기존 j3_rejected 가 이미 CommandApi 가짜를 쓴다) ·
   우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §12 > 01 §11-10 > 02 §3-3 «v1.2 R2b 범위» 블록 > 02 «R2 범위» 블록 > 02 본문.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로)
 1 고치는 곳 = packages/ui_journal + docs/ai-context/inbox 만. 고치면 반려: domain_contracts/**(픽스처·testing.dart 포함) · pubspec.yaml(저장 패키지 = C-3 실패) · analysis_options.yaml ·
   test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·j1_golden_test·README · goldens/j1_*.png · goldens/j5_*.png ·
   기존 goldens/j3_{discretion,recon_clear,rule_menu_open,rejected}_*.png(R-6 포함 재생성 금지 — j3_golden_test.dart 는 override 1줄만).
 2 값 = DTO 의 *Text·*Label·*Line·label·원문 그대로 · 계약이 주는 값은 전부 그린다(생략하려면 먼저 질문 파일에) · 폴백 문구 금지 · 색 = colorScheme · 한국어 리터럴 = labels.dart 의 JournalLabels 에만(테스트에도 금지).
 3 이동 = AppLinkOpener.open(link) 하나(journalLinkOpenerProvider · 콜백 안 ref.read) · 링크 null = 부재 · 'aaq://' 리터럴·조립·파싱 금지 · 플랫폼 판정(kIsWeb·Platform.*) 금지.
 4 주입 프로바이더(journalCommandApiProvider · 🆕 journalDraftStoreProvider)만 throw 기본값 · initState·콜백 안 ref.read 만(build 에서 watch·read 금지) · 데이터 프로바이더는 throw 금지.
 5 폼 동작 = CommandState 9값 exhaustive switch · 🆕 C-12 가 이제 ui_*/lib 의 switch «전부 받기»(default: · _ => · case _: · T _ => · final x => · case final x:)를 대상 타입 불문 기계로 막는다.
 6 문구 = stateLabel + 정적 1줄(submitNotAccepted)뿐 · rejectReasonCode 표시·분기 금지 · 낙관 갱신 금지 · FlagIds(ledgerFix 포함)로 제출 버튼 끄기 금지 · 「40자 이상」 같은 안내 금지.
 7 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지) · Row 안 엔진 문자열은 Expanded/Flexible · FittedBox 금지 · 말줄임은 configHash 1줄만(🆕 읽기 본문 원문은 maxLines·말줄임·trim 금지) · 390px overflow 0.
 8 테스트 = testing.dart 받침대 extends(UnimplementedJournalRepository · UnimplementedCommandApi · UnimplementedSafetyRepository · 🆕 RecordingDraftStore — 새 가짜에 implements 금지) · 받은 인자 전부 기록 ·
   전제는 expect(조용한 return·if 건너뛰기 금지) · 동작은 UI 를 실제로 조작 · 🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지(store.current·시드 행끼리 비교로 끝내지 않고 화면으로 확인) ·
   늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점 1.
 9 🆕 J-3 테스트·골든은 항상 RecordingDraftStore(빈 것 포함) — UnimplementedDraftStore 금지(J-3 은 마운트마다 load 한다) ·
   🆕 DraftRecord(...)·DecisionJournalVm(...)·CommandReceipt(...) 를 지어 넣지 않는다 — 픽스처 행에서(draft_records_j3 는 한 행씩 시드) · 테스트가 치는 입력은 ASCII.
10 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS · 🆕 Windows 의 melos 는 안쪽 패키지가 실패해도 SUCCESS 를 낼 수 있다(C4 R2 실측) — 출력에 «Some tests failed»·«FAILED» 0건을 눈으로 확인 ·
   bash tool/check_boundaries.sh 의 🟡 가 '—'·'·' 같은 기호 때문이면 무시, 한국어 글자면 labels.dart 로.
   🆕 C-4(test:contracts)는 ui_*/lib 코드(주석·문자열 밖)에서 이름 속에 ratio·price·tax·amount·cash·pct·pnl 이 든 식별자(rationale*·*Duration 포함) 옆의 * / + 를
   금액 산술로 잡는다 — 그런 식이 필요하면 비교(>=)·문자열 보간으로 쓴다(예 'a' * spec.rationaleMinChars 는 테스트에만).
11 모르는 것·문서에 없어 정한 것은 질문 파일에 · UI 자리표시자 금지 · 실키·계좌·비밀번호 0 · PR·라벨(golden:approved 포함)·병합은 통합 담당.
🔴 보고 규칙(E07 교훈 — 설계 12 §3 부록 원문) — 채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 적습니다. 시도하지 않은 것을 «시도했다»고 쓰지 않고, 골든 표는 픽스처와 대조한 뒤 «배치·잘림»만 적습니다(글자·아이콘은 테스트 글꼴이라 □).
   자체 점검 ② 는 prompt_M6.md «자체 점검 체크리스트» 10항 원문 그대로 번호를 맞춥니다(기계 검사 목록이 아님).
   질문 파일 새 행의 상태는 README 4값(⬜ 미답·🟡 확인 중·✅ 답함·🔴 반려) 중 «⬜ 미답»으로 두고 답 칸은 비웁니다. 카드·패킷이 정한 것은 추측 행으로 적지 않습니다.
   (R2 재제출 실측 — «itemHeight: null 시도·PNG 확인» 보고가 코드·파일·그림 어디에도 없었고 · 골든 표 4줄이 PNG 와 달랐고 · 새 행 상태가 4값 밖 «✅ 구현 완료»였다. 되풀이하면 반려 사유.)

■ 프롬프트보다 이 카드가 이긴다 (prompt_M6.md 행 번호 · 그 파일은 «치환값 외 무수정»이라 여기서 덮습니다)
 ① 12~13행 라우트 상수 딥링크 → DTO 링크 필드를 AppLinkOpener.open 에(AppRoutes.* 안 씀 · journalRead 도 화면이 조립하지 않는다) ② 38~41행 자리표시자 → 링크 null = 부재
 ③ 46·67행 띠 높이 비워 두기 → 예약 안 함(01 §9) ④ 98~99행 TODO(question-3) → 질문 파일로 ⑤ 106행 «※ 첫 과제는 «J-1 하나»» → 이 카드 범위 ⑥ 116행 브랜치 예시 → ui/m6-j3-complete
 ⑦ 120행 «열거값 미확정» → FillVisibility 확정 · 문구 분기 금지는 그대로 ⑧ 153행 «웹·iOS 빌드에 폼 포함 금지» → 방법 = 배럴 밖 package:ui_journal/journal_draft.dart(TARGETS T-3) ·
   🆕 초안 포트 주입도 그 안(C-35 ⑥) · 읽기 뷰 J-3R 은 배럴 쪽(iOS 포함) · 플랫폼 판정 금지 ⑨ 155~157행 «미정의 7건» → J-2·J-3·J-5(v1.1) + J-3R(v1.2) 확정(미정의는 J-4 뿐)
 ⑩ 168행 «골든 스냅샷을 재생성하지 않았는가» → 이 카드는 R-1 로 j2_* 재생성을 지시한다(golden:approved = Claude) — [x] 로 적고 괄호로 재생성한 파일·이유
 ⑪ 93~94행 «기존 스냅샷을 다시 찍는 것은 위조» → 예외는 ⑩(R-1 의 j2_*) 하나뿐 — 기존 j1_*·j3_*·j5_* 는 다시 찍지 않는다(R-6 도 — (6) 보충).
 ⑫ 167행 자체 점검 9번 «공통 상태 6종 전부» → J-3R 의 «차단»은 해당 없음(안전 상태를 구독하지 않는다 — 설계 §2-16 (1) · 02 §2-6 ⑤ 를 J-3R 에는 적용하지 않는다 ·
   끼워 넣기(J-3 executed)는 J-3 위쪽 차단 블록이 이미 있다).

■ 먼저 읽을 것 (🔴 03~05 명세는 읽지 않음)
 ① prompt_M6.md 전문 ② 01 §12 전체(12-1~12-10 — 특히 12-1-2 «동기 throw 금지» · 12-1-4 수명 주기 · 12-2 · 12-3 · 12-4) + §11-10 «공통»·«J-3» + §8 미결 51(결정) · 52(X7 — 이 카드 밖임만 확인)
 ③ 02 §3-3 «🆕 계약 v1.2 — J-3 R2b 범위» 블록 ⓐ~ⓚ(R2 블록 ⓐ~ⓘ 바로 아래 · 그림 M6-10 앞 — 그림은 «구 초안»이라 블록이 이긴다) + 그 위 R2 블록
 ④ packages/domain_contracts/lib/ — src/commands/draft_store.dart·drafts.dart 전문 · src/enums/draft.dart · src/dto/journal.dart 끝 «계약 v1.2» 절(DecisionJournalVm·DecisionJournalBody) + DecisionDetailVm.journalLink 주석 ·
    src/repositories/journal_repository.dart(watchDecisionJournal) · src/navigation/app_links.dart(journalRead) · testing.dart(RecordingDraftStore · UnimplementedDraftStore · UnimplementedJournalRepository.watchDecisionJournal)
 ⑤ packages/domain_contracts/fixtures/README.md 의 v1.2 m6 행 + draft_records_j3 행 표 ⑥ packages/ui_journal/test/golden/README.md «🆕 R2» + «🆕 R2b» 절(초안 시드하는 법 · 한 행씩 시드)
 ⑦ 지금 코드 — lib/src/journal_draft/journal_draft_form.dart 전문 · lib/src/common/journal_common.dart(JournalSkeleton·JournalErrorView·JournalAsOfHeader·JournalStaleBanner) · lib/src/decision_detail.dart:255-290 ·
    test/journal_draft_test.dart · test/golden/j3_golden_test.dart ⑧ docs/TARGETS.md T-3 · docs/ai-context/inbox/README.md · inbox/J2·J3·J5_questions.md 머리말

■ 주입 구조 (이름·타입 고정 · 계약 변경 없음)
· 재사용(이름·위치 불변): timeline.dart — journalTimelineRepositoryProvider(J-3R 도 이것) · journalSafetyRepositoryProvider · journalClockProvider · journalLinkOpenerProvider · journalSafetyStateProvider /
  journal_draft_form.dart — journalCommandApiProvider · journalDraftFormSpecProvider.
· 🆕 주입 1 — lib/src/journal_draft/journal_draft_form.dart(journalCommandApiProvider 바로 아래 · 같은 파일):
    final journalDraftStoreProvider = Provider<DraftStore>(
      (Ref ref) => throw UnimplementedError('journalDraftStoreProvider'),
    );
  initState·콜백 안 ref.read 만 · 🔴 FutureProvider(.family) 로 감싸지 않는다(ui_* 에 autoDispose 0 → 재진입 때 캐시된 옛 초안).
· 🆕 데이터 1 + 위젯 2 — 새 파일 lib/src/journal_read.dart(배럴 쪽 · 스케치는 (4)):
    final journalReadProvider = StreamProvider.family<DecisionJournalVm, String>(
      (Ref ref, String decisionId) =>
          ref.watch(journalTimelineRepositoryProvider).watchDecisionJournal(decisionId),
    );
    const JournalReadContent({super.key, required this.decisionId, this.showAsOfHeader = true});   // ConsumerWidget · Column · 스크롤 없음(끼워 넣기용)
    const JournalReadView({super.key, required this.decisionId});                                  // ListView 한 겹 = 라우트 journalRead 본문
· 배럴 lib/ui_journal.dart = 머리 주석 유지 + export 'src/journal_read.dart'; 1줄. lib/journal_draft.dart 는 무변경(폼 파일을 이미 export).
  import 방향: journal_draft_form.dart → import '../journal_read.dart';(허용) · 🔴 역방향(journal_read.dart·배럴·timeline·decision_detail·unknown_board·common → journal_draft) 0 ·
  journal_read.dart 에 DraftStore·DraftKey·DraftRecord·DraftKind·…Input 이름 0(C-35 ⑥ 이 ui_journal/lib 를 기계 검사 — test:contracts).

■ J-3 상태 표 v1.2 (01 §12-4 — 01 §11-10 표를 대체 · 창 → 입력 / 제출 버튼 / 문구 / DraftStore)
 ① 복원 중(load 미완료) → 전체 JournalSkeleton / — / — / load 1회
 ② 복원 실패(load 에러) → 빈 폼 편집 / 조건부 활성 / — / reportError
 ③ 제출 전(초안 없음 · lastCommandId == null) → 편집(복원값 · 사라진 code = 미선택) / 조건부 활성 / — / 입력마다 save(lastCommandId: null)
 ④ 🆕 재구독 대기(복원 lastCommandId ≠ null · 첫 접수증 전) → 잠금(값 표시) / 부재 / — / —
 ⑤ 🆕 재구독 에러(그 창의 watchCommand 에러) → 잠금 유지 / 부재 / TextButton «다시 시도»(제출 버튼 자리 · 키 j3-resubscribe · 탭 = 재구독) / reportError
 ⑥ 🆕 재구독 무값 완료(그 창의 스트림이 첫 접수증 없이 onDone) → 잠금 유지 / 부재 / ⑤ 와 같은 «다시 시도» / —
 ⑦ 제출 중(명령 Future 대기 · 재제출 포함) → 잠금 / 비활성 / 직전 stateLabel 유지 / —
 ⑧ 🆕 접수 실패(명령 Future 에러) → 편집(값 유지) / 조건부 활성 / submitNotAccepted 1줄(+ 재제출이면 직전 stateLabel) / 호출 없음 · reportError
 ⑨ 접수·보류(requested·received·staleContext·heldForIntegrity·pendingLeaseConfirm·noOperator) → 잠금 / 부재 / stateLabel / 첫 접수증 직후 save(lastCommandId) 1회
 ⑩ 거부·만료(rejected·expired) → 값 그대로 편집 / 재제출 / stateLabel / 입력마다 save(같은 lastCommandId)
 ⑪ 집행(executed) → 입력 영역 부재 → 그 자리에 JournalReadContent / 부재 / stateLabel + 읽기 본문 / clear 1회
 포트 에러(load·save·clear — 동기 throw 포함) = reportError 만 · 문구 없음 · 입력은 화면에 그대로 · 🔴 51④ 줄을 띄우지 않는다. 이탈(뒤로가기·앱 종료) = 호출 없음(마지막 save 가 이미 기록).

■ J-3 코드 스케치 (설계 §2-16 (3) 검증 반영판 — 규칙을 보이는 것 · 모양은 그대로, 줄 배치·패딩은 재량 · W main 의 계약 코드로 이름 확인함)
  // State 필드 추가(기존 _rationaleCtrl·_expectedCtrl·_noteCtrl·_selectedRule·_receipt·_cmdSub·_submitting 은 그대로)
  late final DraftKey _draftKey =
      DraftKey(kind: DraftKind.journalDraft, targetId: widget.decisionId);   // 🔴 생성자 인자 그대로(링크 조립 아님)
  bool _restoreDone = false;        // load 끝(값·null·에러 모두)
  bool _applyingRestore = false;    // 복원값을 컨트롤러에 넣는 동안 save 금지
  bool _awaitingReceipt = false;    // 복원한 lastCommandId 의 첫 접수증 전
  bool _resubscribeFailed = false;  // 그 창의 watchCommand 에러·무값 완료
  bool _submitNotAccepted = false;  // 01 §12-3(미결 51 ④)
  bool _draftCleared = false;       // executed 때 clear 1회
  String? _pendingRuleCode;         // 복원한 ruleCited(선택지와 code 대조 전)
  String? _commandId;               // 복원 lastCommandId 또는 새 접수증 id
  DraftRecord? _lastPersisted;      // 직전 저장(또는 복원) 레코드 — 같으면 save 생략

  void _report(Object e, StackTrace st) => FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal'), // 🔴 입력값을 싣지 않는다
      );

  // 포트 호출 감싸기 — 동기 throw(미주입 throw 기본값 · 계약을 어긴 구현)도 onError 로 모은다.
  // 감싸지 않으면 _submit 의 «연결 저장 → 반영 → 구독»이 첫 단계에서 끊겨 잠금이 풀리고 이중 제출이 된다(01 §12-1-4).
  void _port(Future<void> Function(DraftStore s) call) => unawaited(
        Future<void>.sync(() => call(ref.read(journalDraftStoreProvider)))
            .then<void>((_) {}, onError: _report),
      );

  // initState 끝(addListener 3줄 뒤)에: unawaited(_restore());
  Future<void> _restore() async {
    DraftRecord? r;
    try {
      r = await ref.read(journalDraftStoreProvider).load(_draftKey); // async 안 try — ref.read 의 동기 throw 도 잡힌다
    } catch (e, st) {
      _report(e, st); // 문구 없음 · 빈 폼으로 계속
    }
    if (!mounted) return;
    final JournalDraftInput? j = r?.journal;
    // 복원값(없으면 빈 본문)을 «직전 저장»으로 둔다 — 포커스·선택만으로는 save 가 나가지 않는다.
    _lastPersisted = r ?? DraftRecord(key: _draftKey, journal: const JournalDraftInput());
    _applyingRestore = true;
    if (j != null) {
      _rationaleCtrl.text = j.rationaleBefore;
      _expectedCtrl.text = j.expectedOutcome;
      _noteCtrl.text = j.note;
      _pendingRuleCode = j.ruleCited;
    }
    _applyingRestore = false;
    setState(() {
      _commandId = r?.lastCommandId;
      _awaitingReceipt = _commandId != null;
      _restoreDone = true;
    });
    if (_commandId != null) _subscribe(_commandId!);
  }

  ReasonOption? _effectiveRule(JournalDraftFormSpec spec) =>
      _selectedRule ??
      spec.ruleCitedOptions
          .where((ReasonOption o) => o.code == _pendingRuleCode)
          .firstOrNull; // 엔진 code 끼리 대조 · 사라졌으면 null(미선택) · firstOrNull = dart:core(package:collection 아님)

  void _persist() {
    if (!_restoreDone || _applyingRestore) return;
    final DraftRecord record = DraftRecord(
      key: _draftKey,
      journal: JournalDraftInput(
        rationaleBefore: _rationaleCtrl.text, // 원문(trim 전)
        expectedOutcome: _expectedCtrl.text,
        ruleCited: _selectedRule?.code ?? _pendingRuleCode,
        note: _noteCtrl.text,
      ),
      lastCommandId: _commandId,
    );
    if (record == _lastPersisted) return; // 같은 값 저장 생략(freezed 값 동등)
    _lastPersisted = record;
    _port((DraftStore s) => s.save(record));
  }

  void _applyReceipt(CommandReceipt r) {
    if (!mounted) return;
    setState(() {
      _receipt = r;
      _awaitingReceipt = false;
      _resubscribeFailed = false;
    });
    if (r.state == CommandState.executed && !_draftCleared) {
      _draftCleared = true;
      _port((DraftStore s) => s.clear(_draftKey)); // 🔴 clear 를 부르는 곳은 여기 하나(C17)
    }
  }

  void _subscribe(String commandId) {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    _cmdSub = ref.read(journalCommandApiProvider).watchCommand(commandId).listen(
      _applyReceipt,
      onError: (Object e, StackTrace st) {
        _report(e, st);
        if (mounted && _awaitingReceipt) { // 🔴 중괄호 필수 — 한 줄 if 는 format:fix 가 두 줄로 나눠 curly_braces_in_flow_control_structures → analyze 실패
          setState(() => _resubscribeFailed = true);
        }
        // 접수증이 이미 있으면 마지막 접수증 유지(51 ③)
      },
      onDone: () { // 첫 접수증 없이 끝나면 = 에러와 같다(영구 잠금 탈출구 · 01 §12-4)
        if (mounted && _awaitingReceipt) {
          setState(() => _resubscribeFailed = true);
        }
      },
    );
  }

  void _resubscribe() {
    setState(() => _resubscribeFailed = false);
    _subscribe(_commandId!);
  }

  // _onInputChanged: setState(() {}); _persist();   // 같은 값이면 _persist 가 스스로 생략
  // _submit: JournalDraft 만드는 줄은 지금 그대로(rule 만 _effectiveRule(spec)!) →
  //   setState(() { _submitting = true; _submitNotAccepted = false; });
  //   try { initial = await ref.read(journalCommandApiProvider).submitJournalDraft(draft); }   // try 는 명령 대기 하나만(51 ①)
  //   catch (e, st) → 주석 «// 01 §4-2 · §8 미결 51 ① (J3_questions Q1) · ④ = §12-3» 유지 · _report(e, st) ·
  //                   if (mounted) setState(() { _submitting = false; _submitNotAccepted = true; }); return;
  //   성공 → if (!mounted) return; setState(() { _submitting = false; _commandId = initial.commandId; });
  //          _persist(); _applyReceipt(initial); _subscribe(initial.commandId);   // 순서: 연결 저장 → 반영(executed 면 clear) → 구독
  // 드롭다운: value: _effectiveRule(spec) · onChanged: (locked || _submitting) ? null : (ReasonOption? v) { setState(() { _selectedRule = v; _pendingRuleCode = null; }); _persist(); }
  // _canSubmit·_submit 은 _selectedRule 대신 _effectiveRule(spec) · final bool locked = _isLocked() || _awaitingReceipt;
  // build: specAsync 를 watch 한 바로 뒤 if (!_restoreDone) return const JournalSkeleton();
  // executed 분기: const SizedBox.shrink() → JournalReadContent(decisionId: widget.decisionId, showAsOfHeader: false)
  // 입력 영역 끝(제출 버튼 자리):
  //   if (_submitNotAccepted) Text(JournalLabels.submitNotAccepted, key: const Key('j3-submit-not-accepted'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
  //   if (_resubscribeFailed) TextButton(key: const Key('j3-resubscribe'), onPressed: _resubscribe, child: const Text(JournalLabels.retry))
  //   else if (!locked) FilledButton(… 지금 그대로 — onPressed: (!_submitting && _canSubmit(spec)) ? () => _submit(spec) : null …),

■ 할 일 — 이 순서로, 단계마다 커밋(예 «[M6] R2b (1) 초안 포트 주입 선언 + 기존 J-3 테스트·골든 override») · 테스트는 그 단계 커밋에 함께 · T 번호 = 아래 «테스트 최소 목록»

(1) 🔴 첫 작업 — 주입 프로바이더 선언 + 기존 J-3 테스트·골든 override(렌더·동작 불변 커밋)
    · lib/src/journal_draft/journal_draft_form.dart: journalDraftStoreProvider 선언만(«주입 구조» 모양 — 이 커밋에서는 아직 부르지 않는다).
    · test/journal_draft_test.dart: _pump(:69-104)에 매개변수 RecordingDraftStore? store 를 더하고 overrides 에
        journalDraftStoreProvider.overrideWithValue(store ?? RecordingDraftStore()),
      직접 만든 ProviderScope 2곳('error → retry re-fetches spec' :161 · 'stale banner shown when clock advances 2 days' :213)에도 같은 줄(빈 RecordingDraftStore()).
      _FakeJournalRepo(:24-35)에 watchDecisionJournal override — 받은 decisionId 기록 · 호출마다 새 스트림 · 이 커밋에서는 Stream<DecisionJournalVm>.value(singleFixture(FixturePaths.m6JournalReadWritten, DecisionJournalVm.fromJson)) 고정.
      (스트림을 바꾸는 생성자 매개변수 Stream<DecisionJournalVm> Function()? journalStream 과 _pump 의 같은 매개변수 journal · 시계 매개변수 Clock? clock(기본 FixedClock(kGoldenNowUtc))은
       T27·T29 를 쓰는 (4) 에서 더한다 — private 클래스 생성자의 쓰지 않는 선택 매개변수는 unused_element_parameter 경고라 analyze --fatal-infos 가 실패한다.)
      _pump 끝에 await tester.pump(); 한 줄 더(복원은 한 마이크로태스크 뒤 끝난다).
    · test/golden/j3_golden_test.dart: _baseOverrides(:53-63)에 journalDraftStoreProvider.overrideWithValue(RecordingDraftStore()) 한 줄. PNG 는 다시 찍지 않는다.
    · 왜 먼저인가: (2) 부터 J-3 은 initState 에서 load 를 부른다 — override 가 없으면 ref.read 가 throw 기본값을 던져 reportError → J-3 단위 22건 + 골든 4종 × light/dark 8건 = 30건이
      «잡히지 않은 예외»로 전부 실패한다. (4) 부터 EXECUTED 테스트는 읽기 본문을 구독한다 — watchDecisionJournal override 가 없으면 받침대가 던져 읽기 본문이 에러 상태(FilledButton «다시 시도»)가 되고
      «FilledButton findsNothing»·«retry findsNothing» 단언이 깨진다.
    🔴 UnimplementedDraftStore 로 대신하지 않는다(그 load 도 Future 에러 → 역시 전부 실패 · 초안 포트를 읽지 않는 화면용이다).
    커밋 전(packages/ui_journal): flutter test test/journal_draft_test.dart test/golden/j3_golden_test.dart   ← --update-goldens 없이 통과 · git status 에 PNG 변경 0.
                                  dart analyze . --fatal-infos   ← «No issues found!»(단계마다 이 두 줄을 돌리면 제출 때 되돌아가지 않는다)

(2) 초안 포트 연결 — 스케치의 _report·_port·_restore·_effectiveRule·_persist·_applyReceipt·_subscribe · _submit 새 순서 · build 의 복원 게이트. 01 §12-1-4 수명 주기 그대로:
    진입 load 1회(끝날 때까지 JournalSkeleton) → 복원 적용 중 save 금지 → 입력 변화마다 save(현재 원문 + 유지된 lastCommandId · unawaited · 디바운스 없음 · 직전 저장(또는 복원)과 같으면 생략) →
    명령 Future 성공 = «연결 저장 save(lastCommandId) → 접수증 반영(executed 면 clear 1회) → 구독» 이 순서 → 명령 Future 에러 = 포트 호출 없음(지우지 않는다).
    · 인용 규칙 복원 = 스펙이 온 뒤 ruleCitedOptions 에서 code 로(_effectiveRule) · 없으면 미선택(문구 없음).
    · 포트 에러(load·save·clear) = reportError 만(값을 싣지 않음) · 문구 없음 · 입력은 그대로 · load 에러 = 빈 폼 편집.
    🔴 포트를 _port 밖에서 직접 부르기(load 는 _restore 의 async try 안이라 예외) · 초안 값을 reportError·print·로그에 싣기 · executed 밖에서 clear · 다른 targetId 로 save ·
       Timer·디바운스 · DraftKind switch · 초안을 데이터 프로바이더로 감싸기 · build 에서 포트 read · didUpdateWidget 구현(04 §1-2 셸 ValueKey 규칙이 막는다) — 전부 금지.
    테스트: T1~T6 · T8 · T13 · T14 · T18a·b · T25 · T28.

(3) 재시작 이중 제출 차단 — 복원한 lastCommandId 가 있으면 watchCommand 재구독(_subscribe) · 첫 접수증 전(_awaitingReceipt) = 입력 잠금(값 표시) · 제출 버튼 부재 · 문구 없음 ·
    그 창의 구독 에러 또는 첫 값 없는 완료(onDone) = 잠금 유지 + 제출 버튼 자리에 TextButton «다시 시도»(키 j3-resubscribe · 탭 = 재구독) · 접수증이 이미 있는 뒤의 구독 에러 = 마지막 접수증 유지 + 보고(51 ③).
    🔴 «다시 시도»에 JournalErrorView 재사용 금지(그 재시도는 FilledButton — 기존 테스트의 «제출 버튼 = find.byType(FilledButton)» 과 겹친다) · 재구독 에러에서 편집 허용 금지(기각된 안 · 01 §12 판정 기록).
    테스트: T9 · T10 · T12 · T26.

(4) executed 뒤 읽기 본문 + 읽기 뷰 J-3R — 새 파일 lib/src/journal_read.dart + 배럴 export 1줄 + J-3 executed 분기 교체.
    · J-3 executed: 입력 영역 자리(지금 const SizedBox.shrink())에 JournalReadContent(decisionId: widget.decisionId, showAsOfHeader: false). 위쪽 블록(asOf 헤더·차단·이탈 배지·서약·문맥 칩·stateLabel·noticeLine) 그대로.
      이동·링크 조립 없음. 끼워 넣은 본문은 자기 asOf 헤더·신선도 배너를 그리지 않는다(J-3 위쪽 헤더 하나 — 읽기 VM 과 스펙의 as_of.label 이 같아 같은 줄 두 번이 된다).
    · 스케치(import = domain_contracts · material · flutter_riverpod · '../l10n/labels.dart' · 'common/journal_common.dart' · 'timeline.dart' — 패딩·글자 스타일 재량):
      class JournalReadContent extends ConsumerWidget {
        const JournalReadContent({super.key, required this.decisionId, this.showAsOfHeader = true});
        final String decisionId;
        final bool showAsOfHeader; // J-3 executed 자리 = false · JournalReadView = true
        @override
        Widget build(BuildContext context, WidgetRef ref) {
          final AsyncValue<DecisionJournalVm> readAsync = ref.watch(journalReadProvider(decisionId));
          return readAsync.when(
            loading: () => const Card( // 🔴 JournalSkeleton(ListView) 금지 — J-3 ListView 안에서 중첩 오류
              key: Key('j3r-loading'),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SizedBox(height: 132),
            ),
            error: (Object e, _) => JournalErrorView(
              lastAsOfLabel: readAsync.valueOrNull?.asOf.label,
              onRetry: () => ref.invalidate(journalReadProvider(decisionId)),
            ),
            data: (DecisionJournalVm vm) {
              final bool isStale = vm.asOf.observedAt
                  .add(vm.asOf.staleAfter)
                  .isBefore(ref.watch(journalClockProvider).nowUtc());
              final DecisionJournalBody? body = vm.body;
              final LinkAction? link = vm.decisionLink;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (showAsOfHeader) JournalAsOfHeader(asOf: vm.asOf),
                  if (showAsOfHeader && isStale) JournalStaleBanner(asOf: vm.asOf),
                  Text(vm.journalStateLabel, key: const Key('j3r-state')),
                  if (body != null)
                    Column(
                      key: const Key('j3r-body'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(body.writtenAtText, key: const Key('j3r-written-at')),
                        const Text(JournalLabels.draftRuleCited), Text(body.ruleCitedLabel),
                        const Text(JournalLabels.draftRationale), Text(body.rationaleBefore), // 🔴 maxLines·overflow·trim 없음
                        const Text(JournalLabels.draftExpected), Text(body.expectedOutcome),
                        if (body.note != null) ...<Widget>[const Text(JournalLabels.draftNote), Text(body.note!)],
                      ],
                    ),
                  if (link != null)
                    OutlinedButton(
                      key: const Key('j3r-link-decision'),
                      onPressed: () => ref.read(journalLinkOpenerProvider).open(link.deepLink),
                      child: Text(link.label),
                    ),
                ],
              );
            },
          );
        }
      }
      class JournalReadView extends StatelessWidget {
        const JournalReadView({super.key, required this.decisionId});
        final String decisionId;
        @override
        Widget build(BuildContext context) =>
            ListView(children: <Widget>[JournalReadContent(decisionId: decisionId)]);
      }
      · body null = 본문 블록 부재(자리표시자 금지 — «미작성»은 journalStateLabel 이 말한다) · note null = 메모 머리·본문 둘 다 부재 · decisionLink null = 버튼 부재.
    🔴 안전 상태 구독 0 · 선택지 목록으로 라벨 찾기 0(ruleCitedLabel 은 엔진이 준다) · 본문 원문 자르기·substring 0 · 결과·손익 표시 0 · 읽기 링크 조립 0 · 시각 포맷 0(writtenAtText 그대로).
    테스트: T7 · T11 · T27 · T29(J-3 쪽) · T19~T23(새 test/journal_read_test.dart) · T24(J-2 — test/decision_detail_test.dart).
    이 단계에서 test/journal_draft_test.dart 의 _FakeJournalRepo 에 journalStream 매개변수, _pump 에 journal·clock 매개변수를 더한다((1) 괄호 — T27·T29 가 쓴다 · 직접 만든 ProviderScope 로 우회하지 않는다).

(5) 접수 실패 1줄(01 §12-3 · 미결 51 ④) — 가장 최근 제출 시도의 명령 Future 가 에러일 때만, 입력 유지·제출 전 복귀와 같은 setState 에서 켠다(_submitNotAccepted).
    위치 = 입력 영역 안 제출 버튼 바로 위 1줄 Text(키 j3-submit-not-accepted · 색 colorScheme.error 허용) · 재제출 실패면 위쪽 직전 stateLabel 도 그대로(둘 다 보인다) ·
    사라짐 = 다음 제출 시작(탭 → 제출 중) · 위젯 폐기 · executed(입력 영역째 부재) — 입력 편집으로는 사라지지 않는다 · 저장하지 않는다(초안에도 없다). reportError 는 그대로.
    🔴 SnackBar·다이얼로그 · 아이콘·톤 배지 · 에러 내용(toString·타입·코드·숫자) · «오프라인»·«전송 대기» · stateLabel 흉내 ·
       watchCommand 구독 에러·재구독 대기 에러·DraftStore 에러·스펙 로드 에러에서 띄우기 — 전부 금지.
    테스트: T15~T17.
    🔴 (5) 커밋에서도 flutter test test/golden/j3_golden_test.dart 가 --update-goldens 없이 통과해야 한다 — 기존 j3_* 4종 픽셀 불변 증명(이 커밋 해시를 PR 본문 ② 10번 괄호에).

(6) R2 잔여 R-1~R-7 — 아래는 설계 12 §3 «R2b-Bob-J3 부록» 원문 그대로입니다(부록의 «보고 규칙»은 위 «규칙 요약» 끝).
    ■ R2 잔여(C4 R2 재제출 · 2026-09-25) — R2b 범위에 더함
    R-1 (E01) J-2 체인 행 상태 칩이 넘치면 줄바꿈되게 — 지금 Row 안 Wrap(children:[Chip])은 폭 제약이 없어 효과 0(긴 stateLabel 에서 RenderFlex overflow 재현).
        칩을 Row 밖 다음 줄로 내리거나 J-3 이탈 배지처럼 DecoratedBox+Padding+Text(글자색·배경 짝 유지), 또는 행 전체 Wrap. 긴 stateLabel(copyWith) overflow 0 테스트 1개. j2 PNG 재생성(golden:approved).
    R-2 (E02) 'partial: remainingText' — 체인 detailLines 출현 수 nChain(전제 expect(nChain, 1)) + 1 로 findsNWidgets. 늘 참인 findsAtLeastNWidgets(1) 금지.
    R-3 (E03) 스냅샷 펼친 뒤 find.text(thresholdRegistered!.toString()) findsNothing — ':305' 주석이 말하는 것을 단언으로(주석만 있는 단언 = 1회차 D06 과 같은 결함).
    R-4 (E04) expect(falseIdx, isNot(-1)) · expect(n0, 1) · full passed 루프 앞 expect(vm.thresholds.every((t) => t.passed), isTrue) · G3 셋째 테스트 전제(emphasized true · link non-null) + color 비교 ·
        contains 2곳 → 정확 목록(J-5 옛 카드0 테스트는 삭제 가능) · 부재 전용 테스트에 양성 기준점 1개 + retry findsNothing.
    R-5 (E05) 루프 시나리오를 testWidgets 로 나누거나 ProviderScope 에 key: UniqueKey() — 그 뒤 receivedIds == <String>[id].
    R-6 (E13 · J3 A7) 인용 규칙 드롭다운 선택 label 둘째 줄 밑줄 겹침 — DropdownButtonFormField(initialValue)·selectedItemBuilder·itemHeight 중 실제로 시도한 것과 PNG 결과를 J3_questions 에.
    R-7 (선택 · E09·E10·E12) 링크 행렬에 OutlinedButton 개수 == non-null 링크 수 · 값→에러 순서 StreamController 로 lastAsOfLabel 단언 · safety row(3) 에서 제출 활성 · emptyLabel null 이면 문구 0 · GateState unknown ≠ notApplicable 아이콘.
    위치(현 main f4ed8e8 기준 · 참고): R-1 lib/src/decision_detail.dart:267-285(Row · Wrap 은 :270-277) · R-2 test/decision_detail_test.dart:631-633 · R-3 같은 파일 :305-312 · :447-456 ·
      R-4 같은 파일 :640(falseIdx) · :886(n0) · :676-692(full passed 루프) · test/unknown_board_test.dart:407-443(G3 셋째) · contains 2곳 = test/unknown_board_test.dart:471 · test/journal_draft_test.dart:1062 ·
        «부재 전용 테스트»(카드가 정함 — 현 main 에서 findsNothing 만 단언하고 양성 기준점이 없는 testWidgets 7건) = test/decision_detail_test.dart:117('stale banner absent with fresh clock') ·
        :377·:397·:415('full: journalLink/parentLink/amendLink absent' — retry 단언도 없음) · test/unknown_board_test.dart:104('stale banner absent…') · test/journal_draft_test.dart:184('stale banner absent…') ·
        :294('recon_clear: pledge block absent…') — 각각 그 화면 픽스처 값 1개 findsOneWidget(양성 기준점) + retry findsNothing(없는 곳만 더함) ·
      R-5 test/journal_draft_test.dart:771-867 · test/decision_detail_test.dart:507-613 · R-6 lib/src/journal_draft/journal_draft_form.dart:355-370 · goldens/j3_rejected_* ·
      R-7 링크 행렬 test/decision_detail_test.dart:583-611 · lastAsOfLabel = decision_detail.dart:56 · journal_draft_form.dart:199 · safety row(3) test/journal_draft_test.dart:746-767 ·
      emptyLabel unknown_board.dart:90-93 · GateState 아이콘 unknown_board.dart:193-198.
    보충(카드가 정함 — 추측 행 아님):
     · R-1 = 부록이 준 세 모양 중 하나(고른 모양은 PR 본문 ① 에 한 줄). 🔴 어느 모양이든 상태 배지에 Chip 을 쓰지 않는다 — Material Chip 라벨은 maxLines 1 · softWrap false · fade 라
       긴 글이 줄바꿈되지 않고 잘린다(예외가 없어 아래 첫 두 단언은 통과해 버린다 · J3 A9 이탈 배지와 같은 결함). 배지 = DecoratedBox+Padding+Text(글자색·배경 짝 유지 — J-3 이탈 배지 모양) —
       칩을 다음 줄로 내리든 행 전체 Wrap 이든 같다. 긴 stateLabel 테스트는 픽스처 값을 늘려 쓴다(한국어 리터럴 금지) — 예
         vm.copyWith(steps: <DecisionChainStep>[vm.steps.first.copyWith(stateLabel: vm.steps.first.stateLabel * 20), ...vm.steps.skip(1)])
       → pump 뒤 expect(tester.takeException(), isNull)(RenderFlex overflow 는 예외로 보고된다) + 늘린 stateLabel findsOneWidget
         + 줄바꿈 증명: final RenderParagraph p = tester.renderObject<RenderParagraph>(find.text(<늘린 stateLabel>)); expect(p.maxLines, isNull); expect(p.softWrap, isTrue);
           (import 'package:flutter/rendering.dart' show RenderParagraph; — material 이 내보내지 않는다).
       j2 PNG 재생성 = 이 커밋에서 flutter test --update-goldens test/golden/j2_golden_test.dart 만(🔴 폴더 지정 금지 · j1·j3·j5 는 찍지 않는다) · 높이 2400 이 모자라면 올리고 J2_questions 에 값.
       (6) 커밋 전 git status --short — test/golden/goldens/ 의 M 은 j2_*.png 뿐이어야 한다(j1_*·j3_*·j5_* 의 M = git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로).
     · R-6 은 «고치기»가 아니라 «실제로 시도하고 결과를 적기»입니다(부록 원문). 🔴 기존 j3_* PNG 는 다시 찍지 않는다(01 §12-9 · 02 §3-3 ⓙ · golden README «R2b» — R-6 도 예외 아님).
       시도마다 flutter test test/golden/j3_golden_test.dart 를 --update-goldens 없이 돌려 j3_rejected 가 달라지는지 본다 — 달라지면 그 테스트가 실패하고
       test/golden/failures/ 아래(git 무시)에 j3_rejected_*_testImage.png·*_isolatedDiff.png 가 남는다 = «PNG 결과»(그 그림에서 밑줄 겹침이 없어졌는지 본다).
       시도가 끝나면 lib 를 되돌린다(겹침을 없앤 모양을 찾았어도 — 고치기는 다음 카드에서 golden:approved 와 함께). R-6 은 lib 커밋이 없는 것이 정상입니다.
       J3 새 A 행에 시도마다: 바꾼 코드 한 줄(위젯·속성·값) · 무갱신 실행 결과 줄 원문(통과, 또는 실패 메시지의 diff 비율) · failures 그림에서 본 겹침(없어짐/그대로) — C4 가 같은 코드로 재현합니다.
       시도하지 않았으면 «시도 0» 으로 적는다(시도하지 않은 것을 «시도했다»고 쓰면 반려 — E07).
     · R-4 의 J-5 몫·R-7 은 테스트 파일만 고칩니다 — J-5 lib(unknown_board.dart)은 바꾸지 않습니다(j5_*.png 불변).

(7) 골든 — 🆕 5종 × light/dark = PNG 10장 · 새 파일 2개(기존 j3_golden_test.dart 에 넣지 않는다 — 넣으면 --update-goldens 가 기존 j3 4종까지 다시 찍는다):
    test/golden/j3_r2b_golden_test.dart(J-3 3종) · test/golden/j3r_golden_test.dart(J-3R 2종). 입력 = golden README «🆕 R2b» 표 그대로.
    공통: 파일 안 const Size _kTallPhone = Size(390, 1600); · pumpForGolden(tester, <화면>, brightness: b, logicalSize: _kTallPhone, wrapApp: (Widget app) => ProviderScope(overrides: <Override>[…], child: app)) ·
      FixedClock(kGoldenNowUtc) · safetyFixtureRow(0) · 링크 오프너 주입 안 함 · 가짜 = 받침대 extends · 초안 = RecordingDraftStore(seed: <DraftRecord>[한 행]) · 찍기 전 await tester.pumpAndSettle() ·
      위치 전제(화면 끝이 골든 안): expect(tester.getBottomLeft(<맨 아래 위젯>).dy, lessThan(_kTallPhone.height)) — 넘치면 높이를 올리고 J3_questions 에 값.
     1 j3_restored_rejected — JournalDraftForm(decisionId: spec.decisionId) · 스펙 m6JournalDraftSpecDiscretion · 시드 m6DraftRecordsJ3 행 2 · watchCommand = Stream.value(REJECTED 행)
       → 전제 find.text(rejected.stateLabel) findsOneWidget · 맨 아래 = find.byType(FilledButton)
     2 j3_submit_not_accepted — 같은 스펙 · 시드 행 1 · submitJournalDraft = 호출 때 만드는 콜백 () => Future<CommandReceipt>.error(Exception())
       (🔴 필드에 미리 만들어 둔 Future.error 는 탭 전에 «잡히지 않은 비동기 에러»로 실패 — 기존 j3_golden_test 의 필드 모양이 아니라 journal_draft_test.dart 의 _FakeCommandApi(onSubmit:, onWatch:) 모양)
       → 제출 버튼 탭 1회 → pumpAndSettle → expect(tester.takeException(), isNotNull)
       → 전제 find.byKey(const Key('j3-submit-not-accepted')) findsOneWidget · 맨 아래 = find.byType(FilledButton)
     3 j3_executed_read — 같은 스펙 · 시드 행 2 · watchCommand = Stream.value(EXECUTED 행) · watchDecisionJournal = singleFixture(FixturePaths.m6JournalReadWritten, DecisionJournalVm.fromJson)
       → 전제 find.byType(JournalAsOfHeader) findsOneWidget(끼워 넣기 헤더 생략 증명) · 맨 아래 = find.byKey(const Key('j3r-link-decision'))
     4 j3r_written — JournalReadView(decisionId: vm.decisionId) · m6JournalReadWritten → 맨 아래 = find.byKey(const Key('j3r-link-decision'))
     5 j3r_not_written — JournalReadView · listFixture(FixturePaths.m6JournalReadNotWritten, DecisionJournalVm.fromJson).rows[0]
       (🔴 singleFixture 는 2행 파일이라 던진다 · 행 1 은 전환 표본) → 맨 아래 = find.byKey(const Key('j3r-state'))
    선택 골든 2종(j3r_no_note · j2_journal_written)은 이번에 만들지 않는다(카드 결정 — T21·T24 가 증명).
    명령(packages/ui_journal 에서 — 🔴 새 파일 2개 지정 · 폴더 지정 금지):
      flutter test --update-goldens test/golden/j3_r2b_golden_test.dart test/golden/j3r_golden_test.dart
      flutter test   ← 옵션 없이 전부 통과 · git status 에 새 PNG 10장만 ??

■ 정적 라벨 — JournalLabels 의 «🆕 R2 — J-3 사전 저널 폼» 블록 끝에 절 주석(// ── 🆕 R2b — J-3 접수 실패 1줄(01 §12-3) ──)과 함께:
   /// 명령 Future 에러 때 제출 버튼 바로 위 1줄(01 §12-3 · 문구 5원칙).
   static const String submitNotAccepted = '제출이 접수되지 않았습니다. 입력은 그대로 있습니다.';
   J-3R 필드 이름은 draftRuleCited·draftRationale·draftExpected·draftNote 재사용 · «다시 시도» = retry 재사용 — 새 라벨은 이것 하나가 권고입니다.
   더 필요하면 더하고(데이터가 바뀌어도 글자가 같은 것만) 질문 파일에 적음. 🔴 journalStateLabel·writtenAtText·stateLabel·noticeLine·ruleCitedLabel 은 옮기지도 만들지도 않음.

■ 테스트 최소 목록 (T 번호 = 설계 §2-16 (4) 원본 번호 · PR 본문 ② 9번 괄호에 근거로만 인용 — 새 항목·번호로 늘어놓지 않는다)
공통: ProviderScope 는 MaterialApp 위(_pump 모양) · 뷰포트 390×1600 + DPR 1.0(J-2 는 2400) · 가짜 = 받침대 extends · RecordingDraftStore 항상(시드 = listFixture(FixturePaths.m6DraftRecordsJ3, DraftRecord.fromJson).rows[n] 한 행) ·
  🔴 R2b 초안 테스트는 시드 유무와 상관없이 전부 _pump(…, decisionId: spec.decisionId) 로 띄운다(기본값 'test-id' 금지 — 그 값으로는 어떤 행도 복원되지 않고 아래 key 와도 어긋난다) ·
  시드 테스트는 그에 더해 전제 expect(spec.decisionId, row.key.targetId)(T18a 만 «다름»이 전제 — isNot) · 접수증 = _receiptIn(state)(m6JournalDraftReceipts5) ·
  key = DraftKey(kind: DraftKind.journalDraft, targetId: <위젯에 준 decisionId>) — 🔴 lib 의 키를 spec 에서 만들지 않는다(스케치 _draftKey = widget.decisionId) ·
  🔴 saved 개수 단언은 T5(0건)에만 — 나머지는 saved.last·내용으로 · 한 testWidgets 에서 decisionId 를 바꾸려면 pumpWidget(const SizedBox()) 로 트리를 내린 뒤 ·
  상태·시나리오마다 testWidgets 를 나눈다(R-5 교훈) · 보고된 에러는 tester.takeException() 으로 단언 · 입력란 찾기 = find.byType(TextField) .first(사전 근거)·.at(1)(기대 결과)·.at(2)(메모) ·
  StreamController 는 만든 줄 바로 뒤 addTearDown(ctrl.close);(close_sinks · analyze --fatal-infos) · 🔴 StreamController 에 add·addError 한 직후는 await tester.pump(Duration.zero)(또는 pump 두 번) —
  pump() 한 번은 예약된 프레임이 없어 반영되지 않는다(탭 뒤 pump 는 탭이 프레임을 예약하므로 한 번으로 된다).
J-3 초안 — test/journal_draft_test.dart 에 추가
 T1 행 0 → 세 입력란 컨트롤러 text = 행 0 원문 · 드롭다운 value == null · 제출 비활성 · store.loaded == <DraftKey>[key].
 T2 행 1 → 드롭다운 value.code == 행 1 의 journal!.ruleCited · 그 선택지 label 보임 · 제출 활성.
 T3 화면층 재시작 생존: 빈 store → ASCII 입력·requiresNote == false 규칙 선택 → pumpWidget(const SizedBox()) → 같은 store 로 새 ProviderScope → 값·규칙 복원(주석 «실물 영속 증명 아님 — 06 M4-9»).
 T4 입력마다 저장: 앞뒤 공백을 넣은 ASCII(예 '  ab  ') → saved.last.journal!.rationaleBefore == 친 원문 그대로(trim 없음) · saved 의 key 전부 == key · 제출 전 saved.last.lastCommandId == null.
 T5 행 1 복원만 → saved 비어 있음 · 입력란을 탭(포커스)만 해도 비어 있음(같은 값 저장 생략).
 T6 제출 성공(REQUESTED) → saved.last.lastCommandId == 돌려준 commandId · api.watchedIds == <String>[그 commandId].
 T7 EXECUTED → store.cleared == <DraftKey>[key] · TextField 0 · find.byType(JournalReadContent) 1 · spec.noticeLine 1.   ((4) 커밋)
 T8 rejected · expired · heldForIntegrity 각각(testWidgets 셋) → cleared 비어 있음 · (거부·만료) 입력값 그대로 + 제출 버튼 활성(재제출) · (보류) 잠금 · 제출 라벨 0.
 T9 행 2 → api.watchedIds == <String>[행 2 의 lastCommandId] · 첫 접수증 전(watchCommand = 아직 add 하지 않은 StreamController): TextField 3개 전부 enabled == false(전제 findsNWidgets(3)) ·
    find.text(JournalLabels.draftSubmit) 0 · j3-resubscribe 0 · j3-submit-not-accepted 0 → REQUESTED 행 add → pump(Duration.zero) → 그 stateLabel 1 · 여전히 잠금.
 T10 행 2 + REJECTED → 행 2 원문 복원 · rejected.stateLabel 1 · 제출 버튼 활성(재제출 가능).
 T11 행 2 + EXECUTED → cleared == <DraftKey>[key] · find.byKey(const Key('j3r-body')) 1.   ((4))
 T12 행 2 + 첫 값 전 구독 에러(onWatch 1회차 = Stream.error · 2회차 = Stream.value(REQUESTED 행)) → 잠금 유지 · find.text(JournalLabels.draftSubmit) 0(🔴 find.byType(FilledButton) 로 세지 않는다) ·
     find.byKey(const Key('j3-resubscribe')) 1 이고 TextButton · takeException 비null → 탭 → pump → watchedIds.length == 2 · REQUESTED stateLabel 1 · 여전히 잠금.
 T13 load 에러(extends RecordingDraftStore — load 만 Future.error) → 빈 폼 편집 가능 · j3-submit-not-accepted 0 · takeException 비null.
 T14 save 에러(save 만 Future.error) → enterText 한 번 → 입력 유지 · 문구 0 · takeException 비null · retry 0(에러 상태 아님).
 T15 51④: 1회차 제출 Future.error → j3-submit-not-accepted 1 · 입력 유지 · cleared 0 · takeException 비null → 2회차(끝나지 않는 Completer<CommandReceipt>().future) 제출 탭 → pump → 그 줄 0.   ((5))
 T16 51④ 공존: 1회차 REQUESTED → watchCommand REJECTED → 2회차 Future.error → rejected.stateLabel 1 그리고 j3-submit-not-accepted 1.   ((5))
 T17 51③ 경계: 제출 REQUESTED 뒤 watchCommand = Stream.error → j3-submit-not-accepted 0 · requested.stateLabel 1 · takeException 비null.   ((5))
 T18a 행 3 시드 + JournalDraftForm(decisionId: discretion 스펙의 decisionId) → 행 3 원문 findsNothing(다른 키) · 입력란 3개 빈 칸.
 T18b(별도 testWidgets) 행 3 시드 + recon_clear 스펙(decisionId = 행 3 key.targetId) → 원문 복원 · 드롭다운 value == null(폐기 code) · 제출 비활성.
 T25 동기 throw 방어: class _SyncThrowStore extends RecordingDraftStore { _SyncThrowStore({super.seed}); @override Future<void> save(DraftRecord record) => throw StateError('save'); }
     (생성자는 상속되지 않는다 — {super.seed} 가 없으면 시드할 수 없다 · T13·T14 의 실패 저장소도 시드가 필요하면 같은 모양) + 행 1 시드 + 제출 = REQUESTED
     → 제출 탭 → watchedIds == <String>[commandId] · REQUESTED stateLabel 1 · 입력 잠금 · 제출 라벨 0 · api.submitted.length == 1 · takeException 비null.
 T26 재구독 무값 완료: 행 2 + watchCommand = const Stream<CommandReceipt>.empty() → 잠금 유지 · j3-resubscribe 1 → 탭 → watchedIds.length == 2.
 T27 executed 직후 전환: 행 2 + EXECUTED + watchDecisionJournal = StreamController(_pump 의 journal 매개변수 — (4)) → listFixture(FixturePaths.m6JournalReadNotWritten, DecisionJournalVm.fromJson).rows[1] add
     → pump(Duration.zero) → j3r-body 0 · 그 journalStateLabel 1 → singleFixture(FixturePaths.m6JournalReadWritten, …) add → pump(Duration.zero) → j3r-body 1(재시도·이동 없이).   ((4))
 T28 행 4 → 메모 칸 = 행 4 원문 · 드롭다운 label = 행 4 code 의 선택지 label(requiresNote true) · 제출 활성 → 메모 칸 enterText('') → 비활성.
 T29 T11 의 화면에서 find.byType(JournalAsOfHeader) 1(J-3 위쪽만) · FixedClock(kGoldenNowUtc.add(const Duration(days: 2))) 로 같은 화면(_pump 의 clock 매개변수 — (4)) → find.byType(JournalStaleBanner) 1.   ((4))
J-3R — 새 test/journal_read_test.dart(가짜 = extends UnimplementedJournalRepository 의 watchDecisionJournal · 받은 decisionId 기록 · 호출마다 새 스트림 · 위젯 = JournalReadView)
 T19 첫 값 전(add 하지 않은 StreamController) j3r-loading 1 · 스트림 에러 → JournalLabels.retry 탭 → 호출 수 증가 ·
     값 → 에러 순서(StreamController add → pump(Duration.zero) → addError → pump(Duration.zero)) → 마지막 asOf.label 1 + retry 1.
 T20 written → writtenAtText·ruleCitedLabel·rationaleBefore·expectedOutcome·note 각 findsOneWidget · 원문 Text 의 maxLines == null · overflow == null(잘림 0) ·
     j3r-link-decision 탭 → opener.opened == <String>[vm.decisionLink!.deepLink] · 가짜가 받은 id == <String>[위젯에 준 decisionId].
 T21 no_note → JournalLabels.draftNote 0 · j3r-link-decision 0 · 양성 기준점(journalStateLabel 1) · retry 0.
 T22 not_written 행 0(listFixture(…).rows[0]) → journalStateLabel 1 · j3r-body 0 · j3r-link-decision 0.
 T23 신선도: FixedClock(kGoldenNowUtc) → JournalLabels.staleBannerTitle 0 · FixedClock(kGoldenNowUtc.add(const Duration(days: 2))) → 1.
J-2 저널 링크 — test/decision_detail_test.dart 에 추가
 T24 m6DecisionDetailJournalWritten · m6DecisionDetailJournalDraftLink 각각 → find.byKey(const ValueKey<String>('j2-link-journalLink')) 1 · 그 안에 journalLink.label · 그 버튼이 목록 마지막 OutlinedButton
     (find.byType(OutlinedButton).evaluate().last == find.descendant(of: find.byKey(const ValueKey<String>('j2-link-journalLink')), matching: find.byType(OutlinedButton)).evaluate().single) ·
     탭 → opener.opened == <String>[journalLink.deepLink] · journalStateLabel 1.
R-1~R-7 — (6) 원문대로(R-1 overflow 1 · R-2~R-5 기존 테스트 강화 · R-7 선택 5종).
(정적 — 결과는 PR 본문 ② 1번 괄호에 근거로만) git grep 으로(packages/ui_journal 에서): lib/ui_journal.dart·lib/src/journal_read.dart 에 journal_draft 0 · lib/src/journal_draft/ 밖 lib 에 DraftStore·DraftKey·DraftRecord·DraftKind 0 ·
  lib/ 의 코드 줄(주석 줄 제외)에 kIsWeb·Platform.·Timer·didUpdateWidget·rejectReasonCode·FlagIds.ledgerFix 0 —
    git grep -nE '^[^/]*(kIsWeb|Platform\.|Timer|didUpdateWidget|rejectReasonCode|FlagIds\.ledgerFix)' -- lib/     ← 출력 0
    (🔴 주석을 빼지 않은 grep 은 journal_draft_form.dart 머리 주석 8~10행의 «🔴 … 금지» 3줄이 나온다 — 규칙 문서라 정상 · 지우지 않는다) ·
  lib/src/journal_draft/·lib/src/journal_read.dart 에 SnackBar·showDialog 0 · 초안 clear 호출 1곳(_applyReceipt 의 executed).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 새 파일을 만들지 않는다 — J-3R 도 J3 에)
· J3_questions.md(머리말 «다음 번호» = Q9·A11) · J2_questions.md(Q7·A8 — R-1~R-5·R-7) · J5_questions.md(Q6·A5 — R-4·R-7) — 번호는 각 파일 머리말의 «다음 번호»에서 이어 붙인다.
· 표 끝에 새 행만 더한다 — 머리말·기존 행의 상태·답 칸은 고치지 않는다(통합 담당이 병합 때 고친다) · 새 행 상태 = «⬜ 미답» · 답 칸 비움 · 칸 안에 세로 막대 문자 금지.
  (inbox/README.md 예시 A1 의 «⬜ 미확인» 은 옛 표기 — A(추측) 행도 «⬜ 미답»)
· 꼭 적을 것: R-6 에서 실제로 시도한 것과 PNG 결과(J3 새 A 행 · A7 참조 · 형식 = (6) R-6 보충) · 골든 높이를 바꿨다면 그 값 · 권고와 다르게 지은 이름 · submitNotAccepted 밖에 새로 더한 정적 라벨 · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함 = 추측 아님): 51④ 라벨·문구·키 · 위젯·프로바이더·키 이름(j3r-*·j3-resubscribe 포함) · showAsOfHeader · 골든 이름·파일·높이 1600 · 선택 골든 미작성 · R-1 의 부록 선택지 안 모양 · RecordingDraftStore 사용 ·
  01 §8 미결 52·53(X7·실물 저장소 — 이 카드 밖).
· 🔴 질문 파일은 브랜치에 커밋한다(docs/ai-context/inbox/ — 채팅 보고만으로는 제출이 아니다).

■ 제출
  melos.bat run format:fix
  cd packages/ui_journal
  flutter test   ← 옵션 없이 전부 통과(먼저 빠르게)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS + 출력에 «Some tests failed»·«FAILED» 0건
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git diff --name-status origin/main...HEAD -- packages/ui_journal/test/golden/goldens/
     ← 이미 커밋한 PNG 전부(단계마다 커밋했으므로 git status 로는 안 보인다). 기대: j2_*.png = M(R-1 로 바뀐 것만) ·
        새 10장(j3_restored_rejected·j3_submit_not_accepted·j3_executed_read·j3r_written·j3r_not_written × light/dark) = A · 그 밖 줄 0.
        j1_*·기존 j3_{discretion,recon_clear,rule_menu_open,rejected}_*·j5_* 가 한 줄이라도 보이면 멈추고 출력을 채팅으로(푸시하지 않는다 · 정당한 이유가 없다 — R-6 도 재생성 금지).
  git status --short
     ← test/golden/goldens/ 에 커밋 안 된 PNG 가 있으면 같은 규칙: j2_*.png 의 M·새 10장의 ?? 만 정상 · j1_*·기존 j3_*·j5_* 의 M = git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
  git add packages/ui_journal docs/ai-context/inbox
  git commit -m "[M6] R2b (8) format·질문 파일"   ← format:fix 가 고친 것·질문 파일이 있을 때만(없으면 «nothing to commit» 이 정상)
  git status --short   ← 🔴 비어 있어야 푸시한다(아니면 멈추고 출력을 채팅으로) — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다
  git push -u origin ui/m6-j3-complete
  PR 은 만들지 않습니다(통합 담당 대행) · golden:approved 라벨도 붙이지 않습니다(Claude). PR 제목: [M6] J-3 완성(초안 저장·읽기 뷰·접수 실패 1줄) + R2 잔여 R-1~R-7
  PR 본문 5섹션을 채팅으로:
   ① 화면 ID(J-3 · J-3R · J-2(R-1 · 저널 링크 테스트) · J-5(R-4·R-7 테스트)) + R-1 에서 고른 모양 한 줄 + R-6 결과 한 줄(시도한 것 · 겹침 해소 여부 · lib 되돌림 · J3 행 번호)
   ② 자체 점검 10항 — prompt_M6.md 159~168행 원문 번호 그대로 · 코드에 실제로 있는 것만 [x] ·
      🔴 ② 는 10항 체크박스만 — T 번호·정적 grep 결과·PNG 목록은 새 항목·번호로 늘어놓지 않고 해당 항목 괄호의 근거로만(정적 grep = 1번 · T 번호 = 9번 · PNG = 10번) ·
      9번 = J-3 4종(빈·부분 동기 해당 없음) · J-3R 3종(로딩·에러·오래된 데이터 — 빈 = VM 의 «미작성» 값 · 차단 = 해당 없음(이 카드가 정함 — 위 ⑫: 설계 §2-16 (1) «안전 상태를 구독하지 않는다» ·
      02 §2-6 ⑤ 를 J-3R 에는 적용하지 않음 · 끼워 넣기는 J-3 위쪽 차단 블록) · 부분 동기 해당 없음) — [x] 로 적고 괄호로 밝힌다 ·
      10번 = [x] + 괄호 «j2_* 재생성 = R-1 지시(파일 목록) · 기존 j3_* 4종 = 무갱신 통과((5) 커밋 <해시> · 마지막 커밋) · j1·j3·j5 재생성 0 · R-6 = 시도·기록만»
   ③ 스크린샷 서술 — 로딩·정상·빈·차단 최소 4 + 골든 표(새 10장: 이름·입력 픽스처·높이·위치 전제 · PNG 를 열어 배치·잘림만 · 못 본 것은 «미열람») + 다시 찍은 기존 PNG 목록(j2_* 만 · 이유)
   ④ 질문 표(새 행 번호·요지) ⑤ 추측한 것(없으면 «없음»)
```

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m6-j3-complete` 푸시 1건 · 커밋 7~8개(본문 (1)~(7) + format·질문 파일).
- `lib/` 새 파일 1(`src/journal_read.dart`) · 수정 4(`src/journal_draft/journal_draft_form.dart` · `ui_journal.dart` export 1줄 · `l10n/labels.dart` 1개 · `src/decision_detail.dart`(R-1 체인 행만)) · `journal_draft.dart`·`timeline.dart`·`unknown_board.dart`·`common/` 은 바뀌지 않는 것이 정상.
- `test/` 새 파일 1(`journal_read_test.dart`) + 수정(`journal_draft_test.dart` · `decision_detail_test.dart` · `unknown_board_test.dart` · `golden/j3_golden_test.dart` override 1줄) · 골든 테스트 새 파일 2(`j3_r2b_golden_test.dart`·`j3r_golden_test.dart`) + 새 PNG 10장 · `j2_*` PNG 재생성(R-1 — 바뀐 것만 `M`) · 기존 `j1_*`·`j3_*`·`j5_*` PNG 는 `M` 0(R-6 은 시도·기록만 — lib 커밋 없음).
- 질문 파일 `J3_questions.md`(R-6 결과 행 포함) · `J2`·`J5`(새 행이 있을 때만) · 채팅: PR 본문 5섹션.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R2b-Bob-J3 결과: 브랜치 ui/m6-j3-complete 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 Bob 이 준 PR 본문 5섹션을 붙여넣습니다. Bob 이 PR 을 직접 만들었다면 `R2b-Bob-J3 결과: PR #<번호> — 병합 검사하고 질문 반영해줘` · 0단계에서 멈췄다면 `R2b-Bob-J3 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR «Files changed»): ① `j1_*.png`·`j5_*.png` 가 `M` ② `lib/ui_journal.dart`·`lib/src/journal_read.dart` 에 `journal_draft` import/export, 또는 `lib/src/journal_draft/` 밖 lib 파일에 `DraftStore` 류 이름(C-35 ⑥ 도 잡는다) ③ `pubspec.yaml` 변경(저장 패키지 = C-3) ④ 접수 실패 1줄이 SnackBar·다이얼로그이거나 «오프라인»·에러 내용을 담음 ⑤ «다시 시도»(`j3-resubscribe`)가 `FilledButton`·`JournalErrorView` ⑥ `Timer`·`didUpdateWidget` ⑦ 기존 `j3_*` PNG 가 `M`(R-6 도 재생성 금지) ⑧ J3 새 행의 R-6 기록에 «바꾼 코드 한 줄·무갱신 실행 결과»가 없음 — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번 PR 이 기존 `j2_*` PNG 를 다시 찍어(R-1) **빨간색이 정상**입니다 — Claude 가 PNG 차이가 체인 칩 줄바꿈뿐인지 확인한 뒤 `golden:approved` 를 붙입니다(Bob 은 붙이지 않음). 새 10장은 `A` 입니다.
- Bob 이 PR 을 못 만드는 것은 정상(Claude 대행). Bob 작업 중에는 `C:\Work\Bob\AutoAlphaQuant` 에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 `C:\Work\AAQ-claude` 에서만).
- 🔴 **파일 이름 주의** — `send/` 바로 아래 = 이 파일 하나. 끝난 R2 패킷 2장은 `send/_완료/` 에 있습니다(다시 보내면 Bob 이 옛 브랜치를 만들려 합니다).
- 범위 고지: iOS «읽기 뷰 대체»의 셸 가드(정적 1줄 + `JournalReadView`)·웹 부재 가드·라우트 등록은 셸 카드(M8 · 04 §1-2) · 실물 재시작 생존은 06 M4-9(이 카드는 수용 (c) 의 **화면층** 증명 T3 까지 — 두 증명을 섞지 않음) · X7 초안 소비 경로는 01 §8 미결 52 · 초안 «버리기»·X1 게이트는 미결 53.
