# 발송 패킷 R2-Bob-J2J3 — 재제출 (1회차 반려 · 2026-09-24)

> 만든 날 2026-09-24 · 1회차(PR #11 · 브랜치 `ui/m6-j2-detail` · 커밋 `2422175`)의 C4 병합 검사 결과가 **반려(재제출)**여서 만든 패킷입니다. 프롬프트·규칙·범위(J-2·J-3·J-5 + J-1 후속 A14~A17)는 1회차 카드(`send/_완료/R2-Bob-J2J3.md`)와 같고, 이 패킷은 **반려 사유 + 고칠 것 G1~G10 + 질문 19행의 답·C4 발견 A 행**만 담았습니다.
> 같은 브랜치 `ui/m6-j2-detail` · 같은 PR #11 에 커밋을 더하면 됩니다(새 PR 을 만들지 않습니다).
> 계약 결정(2026-09-24) — 01 §8 **미결 51 ①②③ 채택**(제출 `Future` 에러 = 입력 유지·보고 · 제출 중 = 잠금 + 버튼 비활성 · 구독 에러 = 마지막 접수증 유지) · **④ 접수 실패 안내 1줄은 R2b 로 보류**. 조문 = 01 §4-2 인용 블록 · §11-10 `J-3` 상태 표 🆕 2행 · §7 C-12 한 구 · 02 §3-2 ⓓ·ⓔ·ⓖ·ⓙ · §3-3 ⓒ·ⓔ · §3-5 ⓒ 의 «🆕 (C4 R2 · 2026-09-24)» 문장.
> 🔴 **올리는 순서(Claude)** — 이 패킷은 01·02 사본·`inbox/README.md` 보충과 **같은 푸시**로 `main` 에 올린다(Bob 은 «먼저 할 것»의 병합 한 번으로 모두 받는다). 0단계 확인 줄이 그 증명이다.

## 0. 한 줄 목적

J-2·J-3·J-5 가 계약이 주는 값을 빠짐없이 그리고(`reasonCode`·`passed`·`emphasized`), J-3 제출 판정·오류 처리를 01 §11-10·미결 51 대로 고치고, 테스트·골든이 그것을 «실제로 조작해서» 증명하게 하기.

## 1. 어디에 보내나

**IBM Bob** — 같은 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · 같은 브랜치 `ui/m6-j2-detail` · 같은 PR #11.

## 2. 보내기 전에 발주자가 할 것 🔴

1. **「푸시해」 뒤에 보냅니다** — Claude 가 이 패킷 · 원 패킷의 `_완료/` 이동 · 01/02 보충(미결 51 등) · `inbox/README.md` 한 줄을 `main` 에 올린 뒤입니다. 먼저 보내면 Bob 이 0단계에서 멈춥니다(그것이 안전장치입니다).
2. Bob 에 «멈춘» 대화가 있으면 **강제 중지** → **새 대화(new task)** 로 시작합니다.
3. 패킷은 **`C:\Work\AAQ-claude\docs\ai-context\send\R2-Bob-J2J3-재제출.md`** 에서 엽니다(Bob 폴더는 PR 브랜치라 병합 전에는 이 파일이 없습니다).
4. 붙여넣을 것은 아래 «3» 의 본문 **전부**(첫 줄 «R2-Bob-J2J3 재제출 요청» ~ «■ 제출» 끝) · 고치지 않습니다. Bob 이 새 대화라 1회차 카드를 기억하지 못하므로 규칙 요약이 본문에 들어 있습니다.
5. 🔴 **파일 이름 주의** — `send/` 바로 아래에서 지금 보낼 패킷은 **이것 하나**입니다. 원 패킷 `R2-Bob-J2J3.md`(꼬리 없음)는 `send/_완료/` 로 옮겼고, 이름이 비슷한 `_완료/R1b-Bob-J1-재제출.md` 는 9-22 에 끝난 카드입니다(09-22 비슷한 이름의 옛 카드로 Bob 이 8시간 멈춘 사고).

## 3. 붙여넣을 본문 — 아래 구분선 다음 줄부터 «3-1» 직전까지 그대로

---

```text
R2-Bob-J2J3 재제출 요청 — 1회차(PR #11 · 2422175) 판정: 반려(재제출). 같은 브랜치·같은 PR 에 커밋을 더하십시오(새 PR 금지).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R1b(PR #7 · ui/m6-j1-complete · 2026-09-22 병합·종료)가 아닙니다. ui/m6-j1-complete · ui/m6-j1-timeline 은 건드리지 않습니다(삭제도 안 함).
이번 대상 = PR #11 · 브랜치 ui/m6-j2-detail(커밋 2422175)에 아래 G1~G10 커밋을 «더하는» 일입니다.
G1~G10 은 아직 코드에 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(그렇게 보이면 잘못된 카드 — 멈추고 알림).
  git branch --show-current     ← ui/m6-j2-detail
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  (다른 브랜치였다면 status 가 빈 것을 본 뒤) git checkout ui/m6-j2-detail
  git log --oneline -1          ← 2422175 [M6] R2 (7) format·질문 파일
  git fetch origin --prune
  git -c core.quotePath=false ls-tree --full-tree --name-only origin/main -- docs/ai-context/send/
     ← (--full-tree 는 지우지 않습니다 — 없으면 하위 폴더에서 빈 출력) 세 줄: docs/ai-context/send/R2-Bob-J2J3-재제출.md · docs/ai-context/send/README.md · docs/ai-context/send/_완료
        = 이 패킷이 main 에 있다(올바른 기준). 한글이 깨져 보여도 «R2-Bob-J2J3-» 로 시작하는 줄이 있으면 정상.
        «R2-Bob-J2J3-재제출» 줄이 없거나 꼬리 없는 «R2-Bob-J2J3.md» 가 보이면 멈추고 채팅으로 — 병합보다 카드가 먼저 왔습니다.
git stash list 의 «WIP on ui/m6-j1-timeline …» 은 옛 R1 사본입니다 — pop 하지 말고 그대로.

■ 규칙 요약 (전문 = prompt_M6.md · 1회차 카드 docs/ai-context/send/_완료/R2-Bob-J2J3.md 의 규칙 1~14 가 그대로 유효)
· 고치는 곳 = packages/ui_journal + docs/ai-context/inbox 만. 고치면 반려: domain_contracts/**(픽스처 포함) · pubspec.yaml · analysis_options.yaml ·
  test/flutter_test_config.dart · test/golden/ 의 golden_support·shift_tolerant_compare·comparator_test·j1_golden_test·README · goldens/j1_*.png.
· 값 = DTO 의 *Text·*Label·*Line·label·원문 그대로 · 🔴 계약이 주는 값은 전부 그린다(생략하면 반려 · 생략하려면 먼저 질문 파일에) · 폴백 문구 금지 · 색 = colorScheme.
· 이동 = AppLinkOpener.open(link) 하나 · 'aaq://'·'handbook://' 리터럴 금지 · 한국어 리터럴 = labels.dart 에만(테스트 금지).
· 🔴 접수 실패 안내 문구(예 «제출하지 못했습니다»)는 만들지 않습니다 — 01 §8 미결 51 ④ = 다음 카드 R2b. 이번 R2 는 입력 유지 · 문구 없음.
· 테스트: 받침대 extends · 받은 인자 전부 기록 · 전제는 expect(조용한 return 금지) · 동작은 UI 를 실제로 조작 · 자기가 주입한 값을 확인하는 테스트 금지 · 늘 참인 단언 금지.
· 골든: 이 PR 의 새 파일 30장(j2 16 · j3 8 · j5 6)은 다시 찍어도 됩니다(--update-goldens 는 파일 3개 지정) · j1_*.png 16장은 절대 바뀌면 안 됩니다(M 이면 되돌리고 멈춤) ·
  golden:approved 는 필요 없고 라벨은 붙이지 않습니다.

■ 잘된 것 — 그대로 유지하십시오
기계 검사 9개 전부 초록(format · analyze · 경계 · 라벨 · ui_journal test 117 · 골든 · domain_contracts test · test:contracts · CI 3개) · 주입 구조 4종 이름·타입·위치 ·
배럴 export 2줄 + J-3 은 배럴 밖 journal_draft.dart · 공통 위젯 추출이 렌더 불변 «순수 이동»(j1 16장 불변) · A14~A17 카드 그대로 · 링크 null = 부재 ·
configHash(모노스페이스·1줄·길게 눌러 전문 복사) · J-2 고정 Key · GateState 4값 switch · _canSubmit 의 CommandState 9값 전수 ·
오프너·CommandApi 는 콜백 안 ref.read · 대기 중 입력란·드롭다운 잠금(_submitting) · 금지 버튼 0 · 새 라벨 9종이 권고 그대로 · 테스트 한국어 0.

■ 왜 반려인가
F1 계약이 주는 값 3개를 그리지 않았습니다 — J-2 거부 추적의 RejectTrace.reasonCode(SAF 원문 · 01 §11-10 «SAF 원문 = 명시적 예외» · 02 §3-2 ⓔ 수용 (c)) ·
   J-2 임계 표의 ThresholdCompare.passed(02 §3-2 ⓓ «passed = 체크/회색») · J-5 UnknownResolutionItem.emphasized(02 §3-5 ⓒ «강조» — 버튼과 별개 조건).
   셋 다 질문 파일에도 없습니다(생략 자체보다 적지 않은 것이 문제 — R1 선례).
F2 「이 결정의 저널」(journalStateLabel · decision_detail.dart:140-144)이 02 §3-2 ⓖ «하단»이 아니라 요약 바로 아래에 있습니다. 그래서 골든 전제
   (journalStateLabel 아래 끝 < 높이)가 늘 참이 됐고, j2_partial·j2_amended(4장)가 셋째 체결 카드에서 잘려 remainingText·미달 임계 행·snapshotMissingLabel 이 그림에 없습니다.
   J2 Q6 «높이 조정 불필요»와 PR 본문 ③ 의 j2_partial·j2_amended 두 줄은 그림과 다릅니다(단위 테스트는 snapshotMissingLabel 을 «below the fills»라며 스크롤해서 찾았습니다).
F3 J-3 제출 조건이 사전 근거를 trim 없이 셉니다(journal_draft_form.dart:113) — 공백 40자로 버튼이 켜집니다. 01 §11-10 = rationaleBefore.trim().length >= rationaleMinChars.
   그리고 제출 Future 대기 중에도 버튼이 살아 있어(:372 — _submitting 을 보지 않음) 두 번 누르면 명령이 2건 나갑니다(01 §8 미결 51 ②).
F4 카드 «테스트 최소 목록»이 크게 모자랍니다 — 통합 담당이 변이 30개를 넣어 보니 13개가 단위 테스트와 골든을 모두 통과했습니다.
   특히 J-2 추적 테스트는 «reasonCode 개수 +1» 대신 탭 뒤에 잰 reasonLabel ≥ 1(탭 전에도 참 — decision_detail_test.dart:659-661)이라 F1 을 가렸고,
   J-5 'error → retry re-subscribes'(unknown_board_test.dart:88-99)는 재시도를 누르지 않습니다.
   J-3 REJECTED 재제출 테스트(journal_draft_test.dart:474-527)는 가짜(:44-64)가 한 번만 구독되는 같은 Stream.value 를 다시 돌려줘 두 번째 listen 이 StateError 로 실패하는데,
   lib 의 try(journal_draft_form.dart:150-174)가 구독까지 감싸 catch (_) 로 삼켜 초록입니다(끝 상태 = REQUESTED 잠금 · 구독 없음).

■ 먼저 할 것
  git fetch origin && git merge --no-edit origin/main
     ← 이 패킷 + 01/02 보충 + inbox/README 를 받습니다. 병합 커밋이 하나 생기는 것은 정상입니다(&& 가 안 되는 셸이면 두 줄로).
        충돌이 나면 아무것도 고치지 말고 멈춘 뒤 git status 출력을 채팅으로.
  melos.bat bootstrap
  melos.bat run build:gen   ← 생성물 재생성. «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  읽을 것(docs/ai-context/):
   · 02_화면명세_M6_매매일지_보유현황.md — §3-2 ⓓ·ⓔ·ⓖ·ⓙ · §3-3 ⓒ·ⓔ · §3-5 ⓒ 의 «🆕 (C4 R2 · 2026-09-24)» 문장
   · 01_M2_도메인계약_초안.md — §8 미결 51 · §4-2 «Future 의 에러는 «접수 실패»다» 인용 블록 · §11-10 J-3 상태 표(🆕 2행) · §7 C-12
   · inbox/README.md — «틀린 접두로 이미 붙은 번호는 고치지 않습니다» 줄

■ 고칠 것
G1 (F1) J-2 거부 추적 행(decision_detail.dart:437-447 — stageLabel·reasonLabel·occurredAtText)에 Text(trace.reasonCode) 를 더합니다 —
   받은 원문 그대로(리터럴 비교·분기 금지 · 예 모노스페이스 · 줄바꿈 허용 · 말줄임 금지).
   테스트('rejected_saf309: …' decision_detail_test.dart:632-662): 탭 전 n0 = find.text(trace.reasonCode).evaluate().length → expect(n0, 1)(체인 detailLines 에 같은 원문 1 — 전제)
   → 머리 탭 → expect(find.text(trace.reasonCode), findsNWidgets(n0 + 1)). 늘 참인 reasonLabel ≥ 1 단언(:659-661)은 지웁니다.
G2 (F1) J-2 임계 행(_ThresholdTable · decision_detail.dart:384-394)이 row.passed 를 그립니다 — true = 체크 아이콘(예 Icons.check) ·
   false = 체크가 아닌 회색 표시(예 Icons.remove · 색 colorScheme.onSurfaceVariant) — bool → 모양 매핑만(여유폭 계산 금지).
   행 Key ValueKey<String>('j2-thr-$i')(받은 순서 — 지금 :384 는 인덱스 없는 for-in 이라 인덱스 루프로). verdictLabel(:392)은 Flexible(줄바꿈) —
   그것으로 390px overflow 0 이면 세로 쌓기는 하지 않습니다(02 ⓓ 의 세로 쌓기는 넘칠 때만 · 폭 경계 상수·LayoutBuilder 분기 금지).
   테스트: full(passed 2행 모두 true) 행 i 안 find.byIcon(<고른 체크 아이콘>) findsOneWidget ·
         partial(passed false 1행) 그 행 안 체크 아이콘 findsNothing + 회색 표시 findsOneWidget(행이 화면 안에 만들어진 뒤 — G7 공통 주의).
G3 (F1) J-5 emphasized == true 인 카드를 강조합니다(_UnknownCard · unknown_board.dart:113-166) — colorScheme 기반(예 Card(shape: RoundedRectangleBorder(side: BorderSide(color: cs.error, width: 2))) 또는 배경) ·
   임계 계산 금지 · escalationLink 버튼과 별개(emphasized true + 링크 null 이어도 강조 · 버튼이 강조를 대신하지 않음).
   테스트: find.descendant(of: find.byKey(ValueKey<String>('j5-card-$i')), matching: find.byType(Card)) 의 shape 또는 color 가 items[0](emphasized)과 items[1](일반)에서 다름
   (Card 가 아닌 위젯으로 강조했다면 그 위젯의 속성으로 같은 비교) +
   vm.copyWith(items: <UnknownResolutionItem>[vm.items[0].copyWith(escalationLink: null), vm.items[1]]) 로도 강조가 남음 +
   반대 방향: vm.copyWith(items: <UnknownResolutionItem>[vm.items[0].copyWith(emphasized: false), vm.items[1]])(링크는 그대로)이면 카드 0 의 shape·color 가 카드 1(일반)과 같음 — 링크가 강조를 만들지 않음
   (픽스처 m6UnknownBoard2 는 emphasized 와 escalationLink 가 늘 함께 있어 «버튼과 별개»는 이 두 테스트로만 증명됩니다 · 값을 더하지 않고 끄기만). 고른 모양을 J5_questions 에 «추측» 행으로.
G4 (F2) J-2 「이 결정의 저널」 블록(journalStateLabel · decision_detail.dart:140-144 + journalLink 버튼 · :157-161)을 ListView 맨 끝(거부 추적 아래)으로 옮깁니다.
   나머지 링크 버튼(rebalance·parent·amend)의 위치·모양은 재량.
   그다음 _kTallPhone(j2_golden_test.dart:18 — J-2 파일 안 상수 · j3·j5 는 1600 그대로)을 j2_partial·j2_amended 의 전제가 통과하는 값까지 올리고(예 2400) 그 값을 J2_questions 에 적습니다.
   J-2 8종 모두(_open 2종 포함 — 머리 탭 뒤·expectGolden 직전) 전제 expect(tester.getBottomLeft(find.text(vm.journalStateLabel)).dy, lessThan(_kTallPhone.height)).
   (지금 j2_full_snapshot_open(:86-96)·j2_rejected_saf309_trace_open(:141-153)에는 전제가 없습니다.)
G5 (F3 · 미결 51 ②) J-3 제출 판정 —
   · journal_draft_form.dart:113 → _rationaleCtrl.text.trim().length < spec.rationaleMinChars (format:fix 가 줄을 나눕니다).
   · 제출 대기 중 버튼 비활성 — :372 를 onPressed: (!_submitting && _canSubmit(spec)) ? () => _submit(spec) : null 로
     (입력란·드롭다운은 이미 _submitting 으로 잠겨 있습니다 — :297 · :314 · :341 · :355).
   테스트: 기대 결과 입력 + requiresNote == false 선택지를 고른 상태에서 사전 근거 ' ' * min → 비활성 · 'a' * (min - 1) + ' ' → 비활성 · 'a' * min → 활성.
         끝나지 않는 Completer<CommandReceipt>().future 를 돌려주는 가짜로 제출 탭 → pump → FilledButton.onPressed == null · TextField 전부 enabled == false
         → 제출을 한 번 더 탭 → pump → submitted.length == 1.
G6 (F4 · 미결 51 ①③) J-3 제출 오류 처리 범위(journal_draft_form.dart:150-174) —
   · try 는 await ref.read(journalCommandApiProvider).submitJournalDraft(draft) 하나만 감쌉니다. 에러면 입력 유지 + _submitting = false 로 복귀(문구 없음 · 에러 내용 표시·분기 금지)
     + FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal')) 로 보고(미결 51 ① — 삼키지 않음).
   · watchCommand(...).listen 은 try 밖. onError 를 달아 보고만 하고 _receipt 는 바꾸지 않습니다(미결 51 ③ = 마지막 접수증 유지 + 보고 · 낙관 갱신 금지 그대로).
   · catch 안 주석은 아래 예시의 한 줄로 바꿉니다(옛 «(추측 — J3_questions Q1)» 주석은 지움 — 이제 계약이고, J3 머리말이 이 주석을 참조합니다).
     모양(통합 담당 예시 — final 지역 변수를 try 안에서 대입하는 이 모양은 Dart 3.13 분석 0건을 확인했지만 위젯에 넣어 돌려 보지는 않았습니다 · 동작은 테스트로 직접 확인):
       setState(() => _submitting = true);
       final CommandReceipt initial;
       try {
         initial = await ref.read(journalCommandApiProvider).submitJournalDraft(draft);
       } catch (e, st) {
         // 01 §4-2 · §8 미결 51 ① (J3_questions Q1)
         FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal'));
         if (mounted) setState(() => _submitting = false);
         return;
       }
       if (!mounted) return;
       setState(() { _receipt = initial; _submitting = false; });
       unawaited(_cmdSub?.cancel() ?? Future<void>.value());
       _cmdSub = ref.read(journalCommandApiProvider).watchCommand(initial.commandId).listen(
         (CommandReceipt r) { if (mounted) setState(() => _receipt = r); },
         onError: (Object e, StackTrace st) => FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal')),
       );
   · 테스트 가짜(journal_draft_test.dart:44-64 _FakeCommandApi): 🔴 같은 스트림 인스턴스를 두 번 돌려주지 않습니다 — 제출·구독을 «호출마다 새로 만드는 함수»로 받게
     (예 Future<CommandReceipt> Function() onSubmit — 값 · 끝나지 않는 Completer · Future.error / Stream<CommandReceipt> Function() onWatch — Stream.value(행) · const Stream.empty() · Stream.error).
     받은 JournalDraft·commandId 기록은 그대로.
   · REJECTED 재제출 테스트(:474-527) 끝에: watchedIds 길이 2 · 두 번째 REJECTED 뒤 다시 편집 가능(FilledButton findsOneWidget · 사전 근거 입력값 그대로).
   · 🆕 submitJournalDraft 가 Future.error 인 테스트(첫 제출): 입력값 유지 · 제출 버튼 활성 · tester.takeException() 이 보고된 에러(isNotNull).
   · 🆕 재제출이 Future.error 인 테스트(01 §11-10 상태 표 🆕 2행): onSubmit 첫 호출 = _receiptIn(CommandState.requested) · 둘째 호출 = Future.error /
     onWatch = Stream.value(_receiptIn(CommandState.rejected)) → 제출 → REJECTED → 다시 제출 → pump 뒤
     find.text(rejected.stateLabel) findsOneWidget(직전 접수증 그대로 — 새 접수증·낙관 갱신 없음) · watchedIds 길이 1 그대로 · submitted.length == 2 ·
     입력값 유지 · 제출 버튼 활성 · tester.takeException() isNotNull.
   · 🆕 watchCommand 가 Stream.error 인 테스트: 제출 뒤 REQUESTED 의 stateLabel 그대로 · 잠금 그대로(제출 버튼 없음) · tester.takeException() isNotNull.
G7 (F4) 카드 «테스트 최소 목록» 채우기 — 정상 상태 테스트마다 expect(find.text(JournalLabels.retry), findsNothing) + 양성 기준점(예 journalStateLabel·noticeLine findsOneWidget).
   🔴 공통 주의 — J-2·J-3 은 ListView 라 화면 밖(＋약 250px)의 위젯을 만들지 않습니다: findsNothing 이 거저 통과하고 findsOneWidget 은 거짓 실패합니다.
      J-2 테스트의 뷰포트 높이(_pump decision_detail_test.dart:52 · 따로 만든 곳 :138 · :446)를 G4 의 _kTallPhone 높이와 같게 두거나, 찾기 전에 scrollUntilVisible.
   J-2 · 6 픽스처 루프(FixturePaths.m6DecisionDetailFull·Partial·Unknown·RejectedSaf309·ReevaluatedChild·Amended): 단계 i 의 stageLabel·stateLabel 을 find.descendant(of: find.byKey(ValueKey<String>('j2-step-$i'))) 로 ·
         6행 Key 가 const Key('j2-chain') 의 자손 · dy 순서 · journalStateLabel findsOneWidget ·
         _pump(…, decisionId: vm.entry.decision.decisionId) 로 넘긴 뒤(기본값 'test-id' 그대로면 틀린 단언) 가짜가 받은 decisionId == <String>[vm.entry.decision.decisionId]
         (_pump 가 가짜를 돌려주게 — unknown_board_test.dart:41 의 _pump 처럼).
       · 링크 행렬 6 × 4: non-null 이면 find.byKey(ValueKey<String>('j2-link-<필드>')) findsOneWidget + 그 안에 link.label · null 이면 findsNothing.
       · full: 스냅샷 머리를 펼친 뒤 vm.snapshot!.trigger.thresholdRegistered(전제 isNotNull)·vm.entry.price 의 toString() findsNothing ·
         rawValues 키 확인(:435-438)도 펼친 뒤로(지금은 접힌 채 확인해 거저 통과) — 주석(:439-441)이 아니라 단언.
       · 'decisionId is passed …' 테스트(:195-221 — 화면 글자 2개만 확인하고 decisionId 도착은 단언하지 않음 · 주석 :218-219 뿐)는 지우거나 가짜가 받은 id 를 단언하게.
       · 링크 탭은 전부 opener.opened == <String>[…] 정확한 목록(지금 :576 · :604 는 contains) · 사유 칩 탭은
         find.descendant(of: find.byType(ActionChip), matching: find.text(label)).first 를 ensureVisible 뒤 탭 · warnIfMissed 기본값(:602 의 warnIfMissed: false 삭제).
       · full 에서만(fills 1행 · 6 픽스처 루프에 넣지 않음 — unknown·rejected_saf309 는 fills 0 이라 .first 가 «No element») · fills 행 탭 없음(1회차 카드 문장 정정 — 요약 Text 와 글자가 같다):
         find.descendant(of: find.byType(JournalEntryCard), matching: find.text(vm.entry.symbolLabel)).first 탭 → opener.opened 비어 있음.
       · partial: remainingText 보임 · G2 의 passed 단언.
   J-3 · EXPIRED 시나리오 — REJECTED 테스트(:474-527)를 _receiptIn(CommandState.rejected)·_receiptIn(CommandState.expired) 두 상태로(:107 헬퍼) — 'a' * min 그대로 · 다시 제출 → 기록 2건.
       · 기록된 draft(REQUESTED 테스트 :403-408): rationaleBefore == 입력한 사전 근거 · expectedOutcome == 입력한 기대 결과.
       · EXECUTED(:425-470): spec.noticeLine 보임 · discretion 초기: noticeLine·deviation.label·contextChips 의 label 보임 ·
         서약 행(j3-pledge-block 안)의 dy 가 pledgeLines 순서대로 커짐(:257-266 은 존재만 확인).
       · safetyFixtureRow(3)(:216-235): blocking[0]·blocking[1] label 모두 보임(지금 [0] 만).
       · REQUESTED·HELD 잠금(:412-416 · :570-574): 루프 앞 expect(find.byType(TextField), findsNWidgets(3))(빈 목록이면 루프가 거저 통과) +
         tester.widget<DropdownButton<ReasonOption>>(find.byType(DropdownButton<ReasonOption>)).onChanged == null.
       · rejectReasonCode(:520)는 `?? ''` 대신 — REJECTED 만(EXPIRED 픽스처는 reject_reason_code 가 null): 두 상태 루프 안에서
         expect(r.rejectReasonCode, s == CommandState.rejected ? isNotNull : isNull) 로 전제를 먼저 두고, non-null 일 때(= 전제가 보장한 REJECTED 회차)만
         find.text(r.rejectReasonCode!) findsNothing (또는 이 두 단언만 REJECTED 전용 테스트로 분리 · 전제 expect 없이 건너뛰는 분기·조용한 return 금지).
   J-5 · 가짜(unknown_board_test.dart:19-30)는 watchUnknownBoard 호출마다 새 스트림(Stream.error 도 한 번만 구독됩니다) ·
         'error → retry'(:88-99): JournalLabels.retry 탭 → pump → 돌려받은 repo 의 callCount 증가.
       · two_open(:196-237): 카드 i 마다 표시 필드 목록(entry 의 symbolLabel·sideLabel·quantityText·statusLabel · elapsedText · effectLine · steps 의 title·stateLabel·whyLine)에서
         t 의 출현 수 n 을 vm.items[i] 에서 세어 find.descendant(of: find.byKey(ValueKey<String>('j5-card-$i')), matching: find.text(t)) findsNWidgets(n)
         (고정 findsOneWidget·findsAtLeastNWidgets(1) 대신 · «대기» 처럼 한 카드에 2번 나오는 값이 있다).
       · 모든 카드 i: symbolLabel 탭(카드 Key 안) → opener.opened == <String>[vm.items[i].entry.detailDeepLink!](:296-323 은 카드 0 · contains) —
         카드마다 새 opener 로 pump 하거나, 한 테스트에서 차례로 누르면 누적 목록 그대로(<String>[items[0] 의 것, items[1] 의 것]).
G8 골든 위생(PNG 불변 항목) —
   · 세 골든 파일에서 journalLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()) 줄을 지웁니다(j2_golden_test.dart:59 · j3_golden_test.dart:60 · j5_golden_test.dart:57 —
     카드 규칙 10 «(골든은 둘 다 주입하지 않는다)» · (6) «링크 오프너·CommandApi 주입 안 함(12 만 명령 가짜)» · 세 파일 머리 주석과도 맞춤 · j3_rejected 의 명령 가짜(:61)만 예외). testing.dart import 는 받침대 때문에 남습니다.
   · 15종 모두 찍기 전 위치 전제: J-2 = G4 · J-3 4종 = expect(tester.getBottomLeft(find.byType(FilledButton)).dy, lessThan(_kTallPhone.height))
     (j3_rule_menu_open 은 드롭다운 탭 전에 · j3_discretion 의 중복 두 줄 :95-96 은 하나로) · j5_long_open = nextBatchNoticeText(:97-107 의 card-0 대신 · 자기모순 주석도 사실대로).
G9 작은 레이아웃·규칙 정리 —
   · journal_draft_form.dart:130 `_ => false` → CommandState.rejected || CommandState.expired || CommandState.executed => false(C-12 · switch 식의 `_ =>` 도 default:).
   · 에러 상태에 마지막 성공 asOf(JournalErrorView 의 lastAsOfLabel 매개변수 — J-5 unknown_board.dart:42 와 같게):
     J-2 decision_detail.dart:55 에 lastAsOfLabel: detailAsync.valueOrNull?.asOf.label · J-3 journal_draft_form.dart:187 에 lastAsOfLabel: specAsync.valueOrNull?.asOf.label.
   · Row 안 엔진 Text 는 Flexible — 임계 verdictLabel(decision_detail.dart:392 · G2) · 체인 occurredAtText(:240-244) · J-5 sideLabel(unknown_board.dart:134).
     체인 행의 Chip(stateLabel)(:236-239)은 Flexible 로 감싸도 넘침이 fade 로 바뀔 뿐 — 넘치면 줄바꿈되는 모양으로(Row → Wrap 등 · 재량).
   · J-3 이탈 배지(journal_draft_form.dart:227-234): Chip 은 라벨을 한 줄 fade 로 자릅니다(softWrap 을 줘도 높이가 한 줄로 막힘 — 24자 deviation.label 끝이 흐려짐)
     → 줄바꿈되는 테두리 상자(DecoratedBox + Padding + Text)로. 말줄임·fade 0.
   · J-2 상태·단계 칩 글자색을 배경과 짝으로(blocked → cs.onError · caution → cs.onErrorContainer · neutral·prevented → cs.onSurface
     — ChipTone 4값 전수 switch · `_ =>` 금지(C-12) · dark 에서 «거부» 칩이 안 보임) — J-2 사용처(decision_detail.dart:132-135 · :236-239)에서만. 공통 journalToneColor(journal_common.dart:20-28)·J-1 골든은 건드리지 않습니다.
   · (선택) 인용 규칙 드롭다운(journal_draft_form.dart:329): 선택된 긴 label 둘째 줄이 밑줄에 닿으면 itemHeight: null 을 시도하고 j3_rejected PNG 로 확인(효과 불확실 — 결과를 J3_questions 에).
G10 질문 파일·PR 본문 —
   · J2/J3/J5_questions 의 Q 번호는 바꾸지 않습니다(PR 본문이 참조 · J3 Q1 은 G6 의 catch 주석도). 아래 «질문의 답»을 각 행 «상태»·«답» 칸에 옮기고, C4 발견 A 행을 표 끝에 더하고, 머리말 한 줄을 넣습니다.
   · 이번에 문서에 없어 정한 것(G2 아이콘 선택 · G3 강조 모양 · G4 높이 값 · G9 체인 칩 모양 · G9 드롭다운 결과)을 «추측» A 행으로 — 번호는 J2 = A6~ · J3 = A10~ · J5 = A4~.
     카드·이 패킷이 이미 정한 것은 추측 행으로 적지 않습니다(1회차 19행 중 18행이 카드에 답이 있었습니다). 모르는 것은 Q(J2 = Q7~ · J3 = Q9~ · J5 = Q6~).
   · PR 본문은 통합 담당이 고칩니다 — 채팅으로 보낼 것: ② 자체 점검 = prompt_M6.md «자체 점검 체크리스트» 10항을 전부 다시(코드에 실제로 있는 것만 [x] ·
     9번 «공통 상태 6종»의 차단은 G7 로 J-3 가 blocking[1] 까지 확인한 뒤에 [x] · 10번 «골든 스냅샷을 재생성하지 않았는가»는 j1_* 가 그대로면 [x] 하고
     괄호로 «이 PR 신규 30장(j2·j3·j5)을 다시 찍은 것은 재생성 아님» 을 적음) · ③ 골든 표(PNG 를 열어 실제로 보이는 것만 · J-2 높이 값) · 새 질문 행(번호·요지).

■ 질문의 답 — 브랜치의 docs/ai-context/inbox/J2·J3·J5_questions.md 각 행 «상태»·«답» 두 칸만 아래 그대로 바꾸십시오
   (번호·카드ID·종류·질문·막힌 곳·제안 칸은 고치지 않습니다 · 칸 안에 세로 막대 문자를 넣지 않습니다 — 표가 깨집니다)
J2_questions.md
  Q1  상태: ✅ 답함
      답: 맞다 — 머리·신선도·**에러**의 asOf = `vm.asOf`(카드 (4) · 02 §3-2 ⓗ · 01 §11-10 «봉투 없는 VM 의 공통 상태»). 에러 상태의 `lastAsOfLabel` 누락은 A1(재제출 G9)
  Q2  상태: ✅ 답함
      답: 맞다 — `ValueKey('j2-step-$i')`(받은 순서) · `stageCode` 매핑 금지(카드 (4) · 02 §3-2 ⓑ)
  Q3  상태: ✅ 답함
      답: 값·모양은 카드 (4) 그대로 · 길게 누름을 받는 위젯(`GestureDetector`)은 재량
  Q4  상태: ✅ 답함
      답: 카드 (4) 원문 그대로 · SnackBar 는 셸 Scaffold 가 띄운다(테스트의 `Scaffold(body:)` 는 흉내)
  Q5  상태: ✅ 답함
      답: 존재 규칙(non-null · `label` · 콜백 안 `open` · Key 4종)이 정본 · `OutlinedButton` 은 재량. 「이 결정의 저널」 위치는 별개 — A2
  Q6  상태: 🔴 반려(재제출 G4)
      답: 1600 은 모자라다 — `journalStateLabel` 을 상단에 둬 전제가 늘 참이 됐고 `j2_partial`·`j2_amended` 가 잘렸다. 02 §3-2 ⓖ «하단» · 카드 (6) «넘치면 높이를 올리고 값을 적는다» · 02 §3-2 ⓖ·ⓙ «(C4 R2 · 2026-09-24)» 문장
J3_questions.md
  Q1  상태: ✅ 답함(동작 허용) · 01 §8 미결 51 ①②③ 결정(2026-09-24) · ④ ⏭ R2b
      답: 입력 유지 + 제출 전 상태는 카드 (5) 대로 허용. `Future` 에러 = «로컬 큐 미적재(명령 없음)»뿐(01 §4-2 «Future 의 에러는 «접수 실패»다»). `try` 는 `submitJournalDraft` 대기 하나만 · 보고 = `FlutterError.reportError` · 제출 중(재제출 포함) = 잠금 + 버튼 비활성 · 구독 에러 = 마지막 접수증 유지 + 보고 → 재제출 G5·G6 · 01 §11-10 `J-3` 상태 표 🆕 2행 · 02 §3-3 ⓒ. 접수 실패 안내 1줄은 R2b(미결 51 ④)
  Q2  상태: ✅ 답함
      답: 위젯 종류는 카드가 정하지 않았다(허용). 참고: `DropdownButtonFormField` 는 `initialValue` 로 경고 없이 유지할 수 있었다. 밑줄 겹침은 A7(선택)
  Q3  상태: ✅ 답함
      답: 6상태 잠금 = 01 §11-10 표 그대로. `_isLocked` 의 `_ =>` 는 A4(재제출 G9 · 01 §7 C-12 «(C4 R2)» 한 구 · 02 §3-3 ⓔ)
  Q4  상태: ✅ 답함
      답: rejected·expired = 값 그대로 재편집·재제출(01 §11-10 · §10-8). EXPIRED 증명 누락은 A5(G7)
  Q5  상태: ✅ 답함
      답: 0줄이면 블록·Key 부재(01 §11-3 · DTO 주석) · «순서대로» 단언은 G7
  Q6  상태: ✅ 답함
      답: dispose 에서 cancel · 교체 전 cancel — 맞다(카드 (5))
  Q7  상태: ✅ 답함
      답: 1600 유지 맞다(PNG 잘림 없음). 위치 전제가 `j3_rejected` 에만 있음 → A6(G8)
  Q8  상태: ✅ 답함
      답: 위치 무규정(02 §3-3 ⓑ) · 입력 영역 앞 = 취지에 맞다. executed 의 stateLabel 위치 차이는 기록만
J5_questions.md
  Q1  상태: ✅ 답함
      답: 4값 exhaustive · unknown ≠ notApplicable. switch 가 고르는 것은 **아이콘**이고 문구는 DTO `stateLabel` 이다(질문 문장 보정)
  Q2  상태: ✅ 답함
      답: `step.deepLink` non-null 일 때만(카드 (3) · 02 §3-5 ⓑ)
  Q3  상태: ✅ 답함
      답: `JournalEntryCard` 미사용 = 카드 (3) 지시. 단 ⓒ `emphasized` 강조 누락은 A2(G3)
  Q4  상태: ✅ 답함
      답: 1600 유지 맞다. `j5_long_open` 전제 대상 → A1(G8)
  Q5  상태: ✅ 답함
      답: non-null 일 때만 · label 그대로(02 §3-5 ⓒ) · `OutlinedButton` 재량

그리고 각 파일 표 끝에 아래 행을 추가하십시오(C4 발견 · 종류 = 추측 · 상태·답은 재제출 병합 검사 때 통합 담당이 바꿉니다):
J2_questions.md
| A1 | J-2 | 추측 | (R2 1회차 · C4 발견) 에러 상태에 마지막 성공 `asOf.label` 을 넘기지 않는다(`decision_detail.dart:55-58`) | 공통 상태 — 에러 | — | 🔴 반려(재제출 G9) | 카드 (4) · 01 §11-10 공통 · 02 §3-2 ⓗ |
| A2 | J-2 | 추측 | (C4 발견) 「이 결정의 저널」(`journalStateLabel`)을 상단에 둬 골든 전제가 늘 참 — `j2_partial`·`j2_amended` 4장이 1600 에서 잘림 | 배치 · 골든 전제 | — | 🔴 반려(재제출 G4) | 02 §3-2 ⓖ «하단» + ⓖ·ⓙ «(C4 R2 · 2026-09-24)» |
| A3 | J-2 | 추측 | (C4 발견) 거부 추적 `reasonCode`(SAF 원문) 미표시 + 테스트가 늘 참인 단언(탭 뒤 `reasonLabel` ≥ 1)으로 가림 | 계약 값 누락 · 테스트 | — | 🔴 반려(재제출 G1) | 01 §11-10 J-2 «SAF 원문» · 02 §3-2 ⓔ 수용 (c) · ⓔ «(C4 R2 · 2026-09-24)» |
| A4 | J-2 | 추측 | (C4 발견) 임계 행 `passed`(체크/회색) 미표시 · `verdictLabel` 이 Row 안에서 Flexible 없음 | 계약 값 누락 · 390px | — | 🔴 반려(재제출 G2·G9) | 02 §3-2 ⓓ + «(C4 R2 · 2026-09-24)» |
| A5 | J-2 | 추측 | (C4 발견) 테스트 최소 목록 미달(6 픽스처 단계·링크 행렬·toString 부재·빈 테스트) · 골든 오프너 주입 · dark 칩 대비 | 테스트 · 골든 · 색 | — | 🔴 반려(재제출 G7·G8·G9) | 카드 테스트 목록 J-2 · 규칙 10·11 |
J3_questions.md
| A1 | J-3 | 추측 | (R2 1회차 · C4 발견) 에러 상태에 마지막 성공 `asOf.label` 없음(`journal_draft_form.dart:187-190`) | 공통 상태 — 에러 | — | 🔴 반려(재제출 G9) | 카드 (5) · 01 §11-10 공통 |
| A2 | J-3 | 추측 | (C4 발견) `try` 가 `watchCommand` 구독까지 감싸 `StateError` 를 삼킴 · 테스트 가짜가 같은 `Stream.value` 를 재사용 | 제출 에러 처리 · 테스트 가짜 | — | 🔴 반려(재제출 G6) | 01 §8 미결 51 ①③ · 01 §4-2 인용 블록 |
| A3 | J-3 | 추측 | (C4 발견) 제출 대기 중 버튼 활성(이중 제출) · 대기 중 입력 잠금을 질문 파일에 안 적음 | 제출 중 창 | — | 🔴 반려(재제출 G5) | 01 §8 미결 51 ② · 01 §11-10 J-3 상태 표 «제출 중» 행 |
| A4 | J-3 | 추측 | (C4 발견) `_isLocked` 의 switch 식 `_ => false`(`journal_draft_form.dart:130`) | C-12 | — | 🔴 반려(재제출 G9) | 카드 (5) · 01 §7 C-12 · 02 §3-3 ⓔ «(C4 R2)» |
| A5 | J-3 | 추측 | (C4 발견) EXPIRED·기록된 입력값·noticeLine·서약 순서·차단 2장·잠금 중 드롭다운 증명 누락 | 테스트 증명 범위 | — | 🔴 반려(재제출 G7) | 카드 테스트 목록 J-3 |
| A6 | J-3 | 추측 | (C4 발견) 골든 위치 전제가 `j3_rejected` 에만 | 골든 전제 | — | 🔴 반려(재제출 G8) | 카드 (6) |
| A7 | J-3 | 추측 | (C4 발견) 선택된 긴 인용 규칙 label 둘째 줄이 드롭다운 밑줄에 닿음(`j3_rejected`) | 390px 레이아웃 | — | 🟡 확인 중(재제출 G9 · 선택) | 카드 규칙 9 |
| A8 | J-3 | 추측 | (C4 발견) 제출 조건 `trim` 누락(`journal_draft_form.dart:113` — 공백 40자로 활성) | 제출 조건 | — | 🔴 반려(재제출 G5) | 01 §11-10 J-3 · 02 §3-3 ⓓ |
| A9 | J-3 | 추측 | (C4 발견) 이탈 배지 `Chip` 이 긴 `deviation.label` 끝을 fade 로 자름 | 390px 레이아웃 | — | 🔴 반려(재제출 G9) | 카드 규칙 9 «말줄임은 configHash 1줄만» |
J5_questions.md
| A1 | J-5 | 추측 | (R2 1회차 · C4 발견) `j5_long_open` 전제 대상이 `nextBatchNoticeText` 가 아니라 card-0 · 주석 자기모순 | 골든 전제 | — | 🔴 반려(재제출 G8) | 카드 (6) |
| A2 | J-5 | 추측 | (C4 발견) `emphasized` 강조 미구현(lib 에서 읽는 곳 0) | 계약 값 누락 | — | 🔴 반려(재제출 G3) | 02 §3-5 ⓒ + «(C4 R2 · 2026-09-24)» |
| A3 | J-5 | 추측 | (C4 발견) 재시도 미탭 · 카드별 세기·stateLabel/whyLine 누락 · 가짜 `Stream.error` 재사용 | 테스트 증명 범위 | — | 🔴 반려(재제출 G7) | 카드 테스트 목록 J-5 |

머리말 — 각 파일 머리의 «R2-Bob-J2J3 1회차(…) — Bob 작성.» 줄 바로 다음에 «>» 만 있는 줄 하나와 아래 그 파일의 인용 줄 하나(줄 전체를 그대로 붙여 넣음).
   끝의 «다음 번호»만 G10 의 새 행을 더한 뒤 표 끝 기준으로 고칩니다(예 J2 에 A6·A7 을 더했으면 «Q7·A8» · 새 Q 를 더했으면 Q 도 올림 · 더한 행이 없으면 아래 값 그대로).
J2_questions.md:
> **C4 R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 행 Q1~Q6 은 전부 종류 «추측»인데 `Q` 번호로 붙었다(규약 = 추측은 `A`). PR 본문이 번호로 참조하므로 **번호는 바꾸지 않는다 — 종류 칸이 정본**. C4 발견 행 = A1~A5 · 재제출 추측 행 = A6~. 다음 번호 = Q7·A6.
J3_questions.md:
> **C4 R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 행 Q1~Q8 은 전부 종류 «추측»인데 `Q` 번호로 붙었다(규약 = 추측은 `A`). PR 본문과 코드 주석(`journal_draft_form.dart` 제출 catch 의 «J3_questions Q1» — 재제출 G6)이 번호로 참조하므로 **번호는 바꾸지 않는다 — 종류 칸이 정본**. C4 발견 행 = A1~A9 · 재제출 추측 행 = A10~. 다음 번호 = Q9·A10.
J5_questions.md:
> **C4 R2-Bob-J2J3 1회차(2026-09-24 · PR #11 `2422175`)** — Bob 행 Q1~Q5 는 전부 종류 «추측»인데 `Q` 번호로 붙었다(규약 = 추측은 `A`). PR 본문이 번호로 참조하므로 **번호는 바꾸지 않는다 — 종류 칸이 정본**. C4 발견 행 = A1~A3 · 재제출 추측 행 = A4~. 다음 번호 = Q6·A4.

■ 제출
  melos.bat run format:fix
  cd packages/ui_journal
  flutter test --update-goldens test/golden/j2_golden_test.dart test/golden/j3_golden_test.dart test/golden/j5_golden_test.dart
     ← 🔴 폴더가 아니라 파일 3개(폴더를 주면 j1 16장이 다시 찍힘). 새 30장은 이 PR 신규라 바뀌어도 됩니다(안 바뀌는 것이 있어도 정상).
  flutter test   ← 옵션 없이 전부 통과
  git status --short   ← test/golden/goldens/j1_*.png 가 M 이면 git checkout -- <그 파일> 하고 멈춘 뒤 채팅으로
     (j2_·j3_·j5_*.png 의 M 은 정상 — 이 PR 1회차에서 이미 커밋한 신규 파일을 다시 찍은 것이라 되돌리지 않습니다 · 멈추는 것은 j1_* 의 M 뿐)
  PNG 눈 확인: j2_partial·j2_amended light 가 화면 끝(「이 결정의 저널」 줄)까지 잘리지 않고 들어 있는지 · j5_two_open 의 두 카드 모양이 다른지(강조).
     (골든은 테스트 글꼴이라 글자·아이콘이 네모로 찍힙니다 — 내용은 단위 테스트가 증명하고, 골든은 배치·잘림을 봅니다. PR ③ 에는 본 것만.)
  cd ../..
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS
     (&& 가 안 되는 셸이면 네 명령을 한 줄씩 — 하나라도 실패면 멈춤)
  git add packages/ui_journal docs/ai-context/inbox
  git commit -m "[M6] R2 재제출 — G1~G10"   ← G 단위로 나눠 커밋해도 됩니다
  git status --short   ← 🔴 비어 있어야 푸시(아니면 멈추고 출력을 채팅으로 — 커밋 안 된 format 수정은 CI 포맷 게이트를 빨갛게 만든다)
  git push   (같은 브랜치 → PR #11 자동 반영 · 새 PR·라벨 금지)
  채팅으로: 자체 점검(② — prompt_M6.md 10항 전부 · 코드에 실제로 있는 것만 [x] · 10번은 G10 셋째 줄대로) · 골든 표(③ — J-2 높이 값 포함) · 새 질문 행(번호·요지). PR 본문 수정은 통합 담당이 합니다.
```

---

## 3-1. 받아야 하는 것

- 같은 브랜치 `ui/m6-j2-detail` 에 추가 커밋: `main` 병합 커밋 1 + 수정 커밋(G1~G10 — 하나 또는 여럿).
- `lib/` 수정 — `src/decision_detail.dart`(G1·G2·G4·G9) · `src/unknown_board.dart`(G3·G9) · `src/journal_draft/journal_draft_form.dart`(G5·G6·G9). `common/journal_common.dart`·`timeline.dart`·배럴은 바뀌지 않는 것이 정상.
- `test/` 수정 — `decision_detail_test.dart` · `journal_draft_test.dart` · `unknown_board_test.dart` · 골든 테스트 3파일 + 새 PNG 재생성(이 PR 신규 30장 안에서만 · `j1_*` 0).
- `docs/ai-context/inbox/J2·J3·J5_questions.md` — 19행 «상태·답» · C4 A 행 17(J2 5 · J3 9 · J5 3) · 머리말 3줄 · Bob 새 추측 행.
- 채팅: 바뀐 자체 점검 · 골든 표(J-2 높이 값) · 새 질문 행.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R2-Bob-J2J3 재제출: PR #11 에 푸시됨 — 병합 검사해줘
```

그 아래에 Bob 이 준 바뀐 자체 점검·골든 표·새 질문 행을 붙여넣습니다. 0단계에서 멈췄다면 `R2-Bob-J2J3 재제출 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**(PR #11 «Files changed»): ① `j1_*.png` 가 `M` ② `lib/ui_journal.dart` 에 `journal_draft` export 또는 `lib/src/journal_draft/` 밖의 lib 파일이 `journal_draft` 를 import ③ `pubspec.yaml` 변경 ④ 화면 코드의 `aaq://` ⑤ `journal_draft_form.dart` 제출 조건에 `trim` 이 없음(공백만으로 제출 켜짐) ⑥ `decision_detail.dart` 의 「이 결정의 저널」(`journalStateLabel`)이 `ListView` 맨 아래가 아님 ⑦ 「제출하지 못했습니다」 같은 접수 실패 문구(미결 51 ④ = R2b) — 하나라도 있으면 반려 신호.
- CI «골든 스냅샷» 잡은 이번에도 **새 PNG(A)만**이라 **초록이 정상**입니다(빨간색 = `j1_*` 변경 = 반려 신호). `golden:approved` 는 붙일 일이 없어야 합니다 — 30장은 모두 이 PR 에서 처음 생긴 파일이라 다시 찍어도 «기존 골든 재생성»이 아닙니다.
- PR 에 `Merge remote-tracking branch 'origin/main'` 커밋이 보이는 것은 정상입니다(squash 병합이라 결과에 남지 않음 · 변경 경로는 여전히 `packages/ui_journal/**` + `inbox/` 만이어야 함).
- 🔴 Bob 이 작업 중일 때는 `C:\Work\Bob\AutoAlphaQuant` 폴더에서 다른 AI·사람이 브랜치를 바꾸지 않습니다(Claude 는 `C:\Work\AAQ-claude` 등 전용 폴더에서만 작업합니다).
- 🔴 **파일 이름 주의** — `send/` 바로 아래 = 이 파일 하나. 원 패킷 `R2-Bob-J2J3.md` 는 `send/_완료/` 에 있습니다(1회차 카드 — 다시 보내면 Bob 이 새 브랜치를 만들려 합니다).
- 미결 51 ④(접수 실패 안내 1줄)는 다음 카드 **`R2b-Bob-J3`**(미결 47 초안 저장 포트와 한 창)에서 도입합니다 — 이번 재제출에서 «문구 없음»은 반려 사유가 아닙니다.
