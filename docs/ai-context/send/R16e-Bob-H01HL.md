# 발송 패킷 R16e-Bob-H01HL — H-01 운영 홈 hold 배너 (계약 v1.35 전제 · R16 뒤 추가 2장째 · M8 `ui_shell` · 🆕 홈 머리 배너 층에 엔진 hold 문장(`SafetyState.holdLabels`)을 받은 차례대로 · 셸 공통 조각 `ShellHoldBanner`(`lib/src/common/shell_common.dart` · 배럴 밖) · 기존 lib 2파일에 더하기만(새 lib 파일 0 · 지운 줄 0) · 🔴 «정확히 N» 소유(라벨 37 · 배럴 23 · 주입 23 · PNG 100) · 크기 작음 — 1회차 merge 목표)

> ▶ **보낼 수 있음(「푸시해」 뒤 — 이 줄이 `origin/main` 에 있으면 조건은 풀린 것)**(2026-11-23 · 조립 자리 = 앱 worktree `C:/Work/AAQ-claude-r16e`(가지 `proto/r16e` · 밑동 `origin/main` `69c0ce7d` = #317 · `contractVersion` `'1.35.0'`)) · ✅ 드라이런(2026-11-23 · 통합 담당 · 가지 `dry/r16e` · 아래 «드라이런:» 줄 · 지적 5 반영) · ✅ 확인 = 권고대로(통합 담당 결정 · 발주자 위임 2026-11-14 — 아래 «확인» ①~⑩) · ✅ 선행 = 계약 v1.35 병합(PR #319 squash `e26760a0` · 01 §44 K295 · 01 §8 미결 221) · 그 밖 선행 0 · ✅ 질문 파일 빈 표 `docs/ai-context/inbox/H01HL_questions.md`(조립 기록 커밋 · 다음 번호 Q1 · A1) · ✅ `send/README.md` 표 줄 · ⬜ 「푸시해」 · 🔵 엔진 hold 생산(01 §8 미결 220 ⓓ · Claude)과 독립 — 엔진이 문장을 싣기 전에는 배너가 부재일 뿐.
> 만든 날 2026-11-21 · 원문 = 01 §8 미결 221(«홈 · 배너 hold 줄 — `ui_shell` 운영 홈(`ops_home.dart`) · 공통 배너가 `SafetyState.holdLabels` 를 차례대로 그린다(hold 줄 한 꼴 · 색 · 아이콘 = 정적 · `holds` · `SafetyHoldCodes` 미참조 — C-68 ⑧) · 표본 `safety_states_holds` 2행 · 빈 = 줄 없음» · «Bob 카드 1 · 작음 · `ui_shell` · 엔진 생산(220 ⓓ) 전에도 화면 판 가능») + 01 §44 K295(«화면 = `holdLabels` 만 차례대로 · hold 줄 한 꼴 · 색 · 아이콘을 코드로 고르지 않는다 · 빈 = 줄 없음 · `holds` = 화면 미참조») · K302 · §44-5 + 계약 코드 `packages/domain_contracts/lib/src/dto/safety.dart`(`SafetyState.holdLabels` · 기본 빈 · JSON `hold_labels`) · 표본 `packages/domain_contracts/fixtures/safety_states_holds.json`(행 0 = `LIVE_AWAITING_KEYS` 문장 · 행 1 = `MIGRATION_IN_PROGRESS` 문장) · 계약 시험 `test/contracts/c68_v135_contract_debts_test.dart` ⑧(ui_* lib 의 `\.holds\b` · `SafetyHoldCodes` 0) + 04 §2-4(전역 배너 슬롯 — ③ 오래된 데이터 배너 → ④ 본문) · §4-1(블록 순서 고정) · §12 표 14 ⑥(«`LIVE_AWAITING_KEYS` hold 의 홈 한 줄 — 문구 = 엔진») + 카드 꼴 = 직전 셸 카드 `_완료/R16d-Bob-S01KS.md`(0~6 절 · 쓰기 단계 · 저장 파일 세 번 나눠 쓰기 · 명령이 채우는 수) · 12 §3 공통 조문(사전검사 ① 줄 · `--factory-if 0`).
> 사전 조건(2026-11-21 조립 실측 · `origin/main` `6eef0f97` = 계약 v1.35 병합 기록) — `ui_shell` = 라벨 **37**(`git grep -cE "^\s*static const String " -- lib/l10n/labels.dart`) · 배럴 export **23** · 주입 **23** · PNG **96** · lib 의 `holdLabels` **0** · `shell_common.dart` = 공용 조각 5(배럴 밖 — 머리 주석 «배럴(lib/ui_shell.dart)에 export 하지 않는다») · 홈은 `SafetyState` 를 이미 구독(`_homeSafetyProvider` · 블록 1 · 3 · 9b) · 시작 기준 = `flutter test`(packages/ui_shell) **+493**(✅ 조립 실측 «00:46 +493: All tests passed!») · 끝 기대 = N + **18**(뷰 14 = `hold_banner_test` · 골든 4 = `hl_h01_keys` · `hl_h01_two` × light/dark) · 끝 = **+511**(✅ 조립 시제품 «00:46 +511: All tests passed!») · `domain_contracts` `dart test` «+669 ~30»(✅ 조립 시제품 — C-68 ⑧ 포함 통과 · 이 카드 몫 0).
> 🔀 **나눔 판정(K26 임계 = 새 `testWidgets(`·`test(` 줄 ≤ 33 · lib ≤ +900 · PNG ≤ 16 · 원천+쓰기 ≤ 5)** — 줄 **8**(뷰 7 · 골든 1) · lib **+47 / −0**(기존 2파일 — `lib/src/common/shell_common.dart` «40 0» · `lib/src/ops_home.dart` «7 0» · 새 lib 파일 0) · 새 PNG **4** · 원천 0 · 쓰기 0(새 구독·주입 0) → **한 장** · 다섯째 축 «새 테스트 파일 줄 수» = `hold_banner_test.dart` **229**줄(dart format 뒤 · < 750) → 쓰기 단계 = R16d 꼴 **12 답**.
> 카드 기본값(✅ 통합 담당 결정 = 권고대로 — 발주자 위임 2026-11-14 · 아래 «확인» · 이름 = v1.35 실물 · 🔴 코드가 정본): ⓐ 자리 = **H-01 운영 홈 머리 배너 층** — `ShellAsOfHeader(h01-asof)` · (있을 때) `ShellStaleBanner` 바로 아래 · 블록 1(`h01-status`) 위 · 🔵 블록이 아니다(04 §2-4 배너 층 — ③ 오래된 데이터 배너 뒤 · 04 §4-1 블록 순서 1→…→9b 무변경) ⓑ 원천 = 홈이 이미 받는 `SafetyState`(`_homeSafetyProvider` · 새 구독 0 · 주입 +0)의 **`holdLabels` 만** — `holds` · `SafetyHoldCodes` · hold 코드 글자 0(C-68 ⑧ · K295) ⓒ 빈 = **부재** — `safety != null && safety.holdLabels.isNotEmpty` 일 때만 둔다(Key `h01-holds` 부재 · 빈 상자·자리표시 0) · 안전 상태 오류·로딩 = 부재(블록 1 재시도가 이미 말한다) ⓓ 꼴 = 공통 조각 **`ShellHoldBanner(labels:)`** 한 벌 — `Card(color: cs.tertiaryContainer)` > `Padding` > `Column` > 줄마다 `Row(ValueKey<String>('hold-line-$i'))` [`Icon(Icons.pause_circle_outline, color: cs.onTertiaryContainer, size: 20)` · `SizedBox(width: 8)` · `Expanded(Text(줄))`] — 줄마다 같은 꼴 · 색·아이콘 = 정적(글자·차례·개수로 고르지 않는다) ⓔ 차례 = **받은 차례 그대로**(`labels.indexed` 하나 · 정렬·뒤집기·자르기·합치기·중복 제거 0) ⓕ 탭 0 · 링크 0(계약에 hold 링크 칸 없음 · K295) · 셸 글자(`ShellLabels`) 0 · 라벨 +0 ⓖ 공통 조각 자리 = `lib/src/common/shell_common.dart` 의 `ShellStaleBanner` 바로 뒤 새 절 «Hold banner»(배럴 밖 · 홈은 이미 상대 경로로 import) · 지금 쓰는 곳 = 홈 하나 ⓗ 공용 파일 = `test/shell_fakes.dart` 끝 절 «더하기만»(numstat 둘째 0) · `lib/ui_shell.dart`(배럴 23) · `lib/l10n/labels.dart`(라벨 37) · `lib/src/shell_providers.dart`(주입 23) **무수정** ⓘ 새 파일 = `test/hold_banner_test.dart` · `test/golden/hold_banner_golden_test.dart` · PNG 4(`hl_h01_keys` · `hl_h01_two` × light/dark) ⓙ 골든 = 폰 `kGoldenPhoneSize`(390 × 844) · 입력 = 표본 `safety_states_holds` 행 0(한 줄) · 행 0 + 행 1 을 차례대로 이어 붙인 상태(두 줄 — 표본 값 무수정 · 테스트가 입력을 준비 · golden_support 머리 «슬라이스 허용» 꼴) ⓚ 기존 PNG 96 재생성 0 · 기존 테스트 무수정(기존 표본 `holdLabels` = 빈 → 홈 그대로 · ✅ 조립 시제품 +493 무변화 · `golden:approved` 불필요).
> 🔴 **카드 덮개 필수 문장(01 §44 K295 · C-68 ⑧)** — «**화면 = 문장만** — hold 줄 글자는 엔진이 지은 `SafetyState.holdLabels` 그대로 · `holds` · `SafetyHoldCodes` 를 읽지 않는다(C-68 ⑧ — 읽으면 계약 시험이 깨진다)» · «**받은 차례 그대로 · 한 꼴** — 줄마다 같은 아이콘·색(정적) · 글자·차례·개수·코드로 꼴을 고르지 않는다 · 정렬·자르기·합치기 0» · «**빈 = 부재** — 줄이 없으면 배너도 없다(빈 상자·자리표시 0)» · «**탭 0 · 링크 0 · 셸 글자 0** — 라벨 +0 · 주입 +0 · 배럴 +0 · 기존 테스트·PNG 무수정 · 계약·엔진·`apps/`·다른 `ui_*` 무변경».
> ✅ **확인 = 권고대로(통합 담당 결정 2026-11-21 · 발주자 위임 2026-11-14 — ①~⑩)** — ① «공통 배너» 읽기 = **셸 공통 조각 `ShellHoldBanner`**(`shell_common.dart` · `ShellStaleBanner` 옆) · 대안 ⓐ 셸 전역 슬롯(04 §2-4 · `_PhoneHome` · `_WebBody` 탭 본문 위)에 두기 — 비권고: 셸 스캐폴드에 `SafetyState` 새 구독 + 뷰어 앱(iOS · 웹)은 `shellSafetyRepositoryProvider` 를 넣지 않는다(운영 앱 `operator_shell.dart` 하나뿐 · 조립 실측) + 04 §2-4 «4단» 개정 = 명세 창 몫 · 대안 ⓑ 다른 모듈 공통 배너(M6 `JournalSafetyBanners` · M7 `SafetyBlockBanner`) — 비권고: 221 = «Bob 카드 1 · 작음 · `ui_shell`» ② 자리 = 홈 머리 배너 층(오래된 데이터 배너 뒤 · 블록 1 위) · 대안 = 블록 1 안(상태 글자 밑) — 비권고: 블록 1 은 `m5BlockBoard` 로 가는 탭 칸이라 hold 줄이 탭 대상이 된다(hold 해제 길은 보드가 아니다) ③ 빈 처리 = 홈의 collection-if(`isNotEmpty`) 하나 · 조각은 받은 줄만 그린다 ④ 꼴 = `Card` · `tertiaryContainer` · `Icons.pause_circle_outline` · `onTertiaryContainer` · 20 — «멈춤» 뜻 한 꼴(오류색 `error*` 은 블록 9b 차단 등급 몫이라 피함) ⑤ 줄 Key = `ValueKey<String>('hold-line-$i')`(조각 안 · 공통이라 `h01-` 머리 없음) · 배너 Key = `Key('h01-holds')`(홈이 단다) ⑥ 테스트 파일 = 새 `test/hold_banner_test.dart` 하나(기존 `ops_home_test.dart` 무수정 · 7줄 14개) ⑦ 골든 = 2이름 4장(`hl_h01_keys` 한 줄 · `hl_h01_two` 두 줄) · 크기 = `kGoldenPhoneSize` ⑧ 사전검사 ① = `--collection-if 0 --factory-if 0` · ② = `--golden-prefix hl_ --goldens 4` ⑨ 커밋 = 넷((1) lib (2) 테스트 (3) 골든 (4) format · 질문) ⑩ 질문 파일 이름 `H01HL_questions.md`(조립 커밋이 빈 표를 만든다).
> 🔵 **판독 빈틈 → 이 카드가 정함**: 221 «공통 배너» = 위 ① · 다른 셸 화면(H-02 · N · D · W · B · O) · 셸 전역 슬롯 · 다른 모듈 화면의 hold 줄 = 이 카드 밖(필요하면 새 미결 — 통합 담당) · 엔진 생산(01 §8 미결 220 ⓓ — `MIGRATION_IN_PROGRESS` 짝 문장 · `LIVE_AWAITING_KEYS` 를 `SafetyState` 에 싣기) 전에는 실기기 홈에 배너가 **보이지 않는다**(`holdLabels` 빈 = 부재 · 결함 아님) · 04 §12 표 14 ⑥ «홈 한 줄» = 이 배너.
> 🆕 **조립 시제품**(통합 담당 조립자 · 2026-11-21~23 · 앱 worktree `C:/Work/AAQ-claude-r16e` 가지 `proto/r16e`(origin/main `69c0ce7d` 위 커밋 3 — `6429f095` lib · `21ccadee` 테스트 · `6b2cc12e` 골든 · 미푸시) · 이 카드 글자 = 그 커밋에서 기계로 옮김): lib numstat «40 0» · «7 0» · dart format 0 changed · analyze «No issues found!» · fakes 끝 절 «69 0» · `hold_banner_test.dart` 229줄 «+14» · `hold_banner_golden_test.dart` 47줄 «+4» · 전체 «+511»(기존 493 무수정 통과) · domain_contracts «+669 ~30»(C-68 ⑧ 통과) · 골든 배너 아래 dy `hl_h01_keys` 104.0 · 104.0 · `hl_h01_two` 164.0 · 164.0(light = dark) · PNG blob light `hl_h01_keys` `be4740a3` · `hl_h01_two` `7b78d816` · dark `fec08e0f` · `14eead9c` · 정적(아래 30줄) 131줄 · EXIT:1 13 · EXIT:0 17 · 미리 돌리기 124줄(EXIT:1 14 · EXIT:0 16) · 사전검사 ① 🔴 0 🟡 0 · 변이 12 = KILLED 12(아래 «예고 변이» · 🔴 하나뿐 2).
> 드라이런: ✅ 2026-11-23(통합 담당 · `C:/Work/AAQ-claude-r16edry`(지움) · 가지 `dry/r16e` `3c1fcde1` · 조립 기록 커밋 위 · `origin/main` 자리 = 그 기록 커밋 · 카드 글자대로(복사 상자 = 카드 파일에서 기계로 꺼냄) · 커밋 4(`c8fed721` (1) · `d5058dd9` (2) · `b4598cc4` (3) · `3c1fcde1` (4)) · name-status 10 · +493 → +511(«00:40 +511: All tests passed!» · 파일별 «+14» · «+4») · PNG 96 → 100 · lib · fakes · PNG blob = 조립 시제품과 같음 · dart format 0 changed · analyze 0 · 정적 해시 일치 · 131 / 13 / 17 · 미리 돌리기 124 / 14 / 16 · 골든 dy 104.0 / 164.0(light = dark) · N7 전부 기대 · N5 ⓑ T20 2 · T21 2 · N9 · N10 · N6 · N8 통과 · check_labels apps 196(main 원래 🔴 · ui_shell 0) · domain_contracts «+669 ~30» · 사전검사 ① 🔴 0 🟡 0 · 사전검사 ② 🔴 0 🟡 1([G1] 골든 표 4행 한 항목 «덩어리로 셀 수 없어 PNG 와 대조하지 않았다» — 헛경보 꼴) · 드라이런 지적 5 반영(T13 머리 «exactly 37» · check_boundaries 🟡 2건 · 🟡 기대 1 · 단계 7 · 8 git add · fakes 줄 수 문구)).
> 프롬프트 = `prompt_M8.md`(v2 183줄 · «이긴다» 13항이 범위·낡은 줄을 덮음 · 재조립 0). 🔴 Bob **새 대화** 전제.

## 0. 한 줄 목적

H-01 운영 홈 머리 배너 층(오래된 데이터 배너 뒤 · 블록 1 위)에 엔진 hold 문장 `SafetyState.holdLabels` 를 **받은 차례대로 · 줄마다 같은 꼴**로 그리는 셸 공통 조각 `ShellHoldBanner` 를 두고(빈 = 부재 · 탭·링크·셸 글자 0 · `holds` · `SafetyHoldCodes` 0), 기존 lib 2파일에 47줄을 더하는 것만으로 계약 v1.35 K295 의 화면 몫(01 §8 미결 221)을 짓기.

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-h01-hold-banner`**(base = 최신 `origin/main` · `--no-track`) · PR 제목 = «[M8] H-01 hold 배너(R16e)».

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄(3행 — «>» 로 시작하는 첫 줄)이 ▶ 일 때만 보냅니다** — 「푸시해」 뒤 이 줄이 `origin/main` 에 있으면 조건은 풀린 것입니다(배지 규칙).
2. 🔴 **Bob 폴더 `git status --short` 가 비었는지 먼저 봅니다(C4r7b-3)** — `C:\Work\Bob\AutoAlphaQuant` 에서 `git status --short` 를 돌려 출력이 없으면 보냅니다 · 남은 미커밋이 있으면 지우거나 커밋하지 말고 **Claude 에게 묻습니다**. 🔴 **지금 Bob 폴더는 분리 HEAD `29649223`**(#313 · 2026-11-21 조립 실측 — 가지 없음) — 그대로 둡니다(손으로 `git checkout main` 하지 않습니다 — `main` 은 다른 worktree(`C:\Work\AAQ-claude`)에 체크아웃돼 있어 거부됩니다). 카드 0단계 셋째 줄 `git fetch origin --prune` 뒤 넷째 줄 `git checkout --no-track -b ui/m8-h01-hold-banner origin/main` 이 **최신 `main` 에서 새 가지를 파 옮깁니다**. 출력이 그 꼴이 아니면 Bob 이 멈추고 채팅으로 냅니다 — 그 출력을 Claude 에게 보냅니다.
3. Bob 에 앞 카드를 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
4. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R16e-Bob-H01HL.md> · 로컬 사본 = 통합 담당이 「푸시해」 뒤 발송 안내 때 확인한 절대 경로로 알립니다(🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 옛 판입니다 — Bob 폴더는 #313 분리 HEAD 라 이 파일이 없습니다).
5. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R16e-Bob-H01HL — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 바깥 울타리 = 백틱 네 개 · 고치지 않습니다.
6. 🔴 **파일 이름 주의** — 끝난 `_완료/R16d-Bob-S01KS.md` · `_완료/R16c-Bob-H03.md` · `_완료/R8b-Bob-M9S04.md` 를 붙여넣지 않습니다 · 🔴 헷갈림 주의: **R16e**(이 카드 · Bob · `ui_shell` 홈 hold 배너) ↔ **미결 220**(Claude 엔진 몫 · hold 문장 생산 — Bob 에게 보내지 않습니다) ↔ **S05 `RunModeCard.holdLabel`**(M9 설정 화면 · 병합됨 — 이 카드는 건드리지 않습니다).
7. 🔴 **쓰기 단계(C4r7a-8 · C4r7b-4 · C4r7c-5)** — Bob 은 본문 «■ 쓰기 단계» 12 답(1 ~ 12)을 **한 답에 한 단계**씩 하고, 단계 끝마다 채팅에 «R16e 단계 N 끝» 한 줄만 냅니다(단계 1 만 «— 시작 기준 +N» 꼬리). 그 한 줄을 받으면 **«계속» 한 낱말만** 보냅니다(다른 글 0 · 11번 안팎). Bob 이 한 단계 안에서 길이 한도로 멈추면 «그 단계를 반으로 나눠 이어서» 한 줄을 보냅니다(Bob 은 «R16e 단계 Na 끝» · «R16e 단계 Nb 끝» 꼴로 잇습니다). 🔵 단계 9 · 12 는 일이 많아 Bob 이 묻지 않고 둘로 나눌 수 있습니다(«R16e 단계 9-1 끝» · «R16e 단계 9-2 끝» · «R16e 단계 12-1 끝» — 그 줄에도 «계속» 한 낱말).
8. 🔴 **받는 법(C4r5a-1 · R16d 와 같은 꼴)** — Bob 은 보고 글 전문을 채팅에 내지 않고 `$env:TEMP\R16e-Bob-H01HL_submit.md`(UTF-8 **BOM 없이** · 줄 끝 LF — C4r14b-5 · C4O-2 · C4Q-3)에 **세 번 나눠**(단계 10 = ① · 11 = ② · 12 = ③~⑤) 저장한 뒤 사전검사 ② 를 한 번(`hl_`) 돌리고, 채팅에는 두 줄(«…저장했음: <경로>» · 사전검사 ② 끝 줄 한 줄)만 냅니다. 받은 뒤에는 아래 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다. 보고 글의 수 세 자리(② «ⓡ = T20 출력:» · «ⓗ = T21 출력:» 다음 줄 · ② 끝 check:labels 줄의 apps 수)는 Bob 이 손으로 적지 않고 **명령이 채웁니다**(C4r9a-1 · -2).
9. 🔵 Bob 의 이전 창은 닫은 뒤 새 대화를 엽니다 — 그 창이 띄운 `flutter_tester` 는 창과 함께 끝납니다. 작업 관리자 등에서 `flutter_tester` 를 직접 끝내지 마세요(다른 세션 것도 있습니다 · C4r5a-9 ⑥).

## 3. 붙여넣을 본문 — ````text 다음 줄(«R16e-Bob-H01HL — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R16e-Bob-H01HL — 범위: M8 H-01 운영 홈 hold 배너 — 홈 머리 배너 층(오래된 데이터 배너 뒤 · 블록 1 위)에 엔진 hold 문장 SafetyState.holdLabels 를 받은 차례대로 · 줄마다 같은 꼴로 그리는 셸 공통 조각 ShellHoldBanner(lib/src/common/shell_common.dart · 배럴 밖) + 홈 배치 + 공용 가짜 끝 절 · 기존 lib 2파일에 더하기만(새 lib 파일 0 · 지운 줄 0).
🔴 화면 = 문장만 — hold 줄 글자 = 엔진 SafetyState.holdLabels 그대로 · holds · SafetyHoldCodes · hold 코드 글자(LIVE_AWAITING_KEYS · MIGRATION_IN_PROGRESS) 0(lib · 새 테스트 파일) — lib 에 .holds 나 SafetyHoldCodes 가 한 글자라도 있으면 계약 시험 C-68 ⑧(domain_contracts c68_v135_contract_debts_test)이 깨진다(정적 T11 · T12).
🔴 받은 차례 그대로 · 한 꼴 — 줄마다 같은 Icon(Icons.pause_circle_outline · cs.onTertiaryContainer · 20) · 같은 Card 색(cs.tertiaryContainer) · 글자·차례·개수로 꼴을 고르지 않는다 · 정렬·뒤집기·자르기·합치기·중복 제거 0(정적 T10).
🔴 빈 = 부재 — safety != null && safety.holdLabels.isNotEmpty 일 때만 배너(Key h01-holds)를 둔다 · 빈 상자·자리표시 0 · 탭 0 · 링크 0 · 셸 글자(ShellLabels) 0 · 라벨 +0 · 주입 +0 · 배럴 +0.
🔴 기존 테스트·PNG 96·라벨·배럴·주입·계약·엔진·apps·다른 ui_* 무변경 — 기존 표본은 holdLabels 가 비어 있어 기존 홈 테스트·골든은 손대지 않고 그대로 통과해야 한다.
하지 않는 것: hold 해제·재개 버튼 · 링크(AppRoutes) · 셸 전역 슬롯(04 §2-4)·다른 셸 화면·다른 모듈 화면의 hold 줄 · 블록 1~9b 수정 · 새 구독·주입·라벨·배럴 · domain_contracts·pubspec 수정 · 엔진 hold 생산(01 §8 미결 220 — Claude 몫).
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 13항) — 0단계 확인 뒤 prompt_M8.md 를 처음부터 끝까지 한 번 읽는다(M8 모듈 규칙 전문 · 이 카드와 다른 줄은 아래 13항이 덮는다).
🔴 이 카드는 아래 «■ 쓰기 단계» 12 답(1 ~ 12)을 한 답에 한 단계씩 한다 — 단계 끝 채팅 = «R16e 단계 N 끝» 한 줄뿐(설명·요약·코드 붙이기 0 · 단계 1 만 «— 시작 기준 +N» 꼬리) · 발주자가 «계속» 이라고 하면 다음 단계.
🔵 괄호 안 꼬리표(C4r…·C4…·K…·카드 이름·«1회차» 류)는 출처 표시입니다 — 따로 찾아 읽지 않아도 되고, 지킬 규칙은 그 문장에 다 적혀 있습니다(ⓡ·ⓗ·N1~N10·T01~T30·HL-NN·단계 이름은 이 본문 안에서 정의됩니다).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터 · = 쓰기 단계 1)
이 카드는 R16a~R16d(병합됨)도 R8b(M9)도 Claude 의 엔진 카드(미결 220)도 아닙니다 — M8 H-01 운영 홈의 hold 배너입니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-* · ui/m9-*)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 홈 hold 배너가 없습니다(ui_shell 의 holdLabels 0) — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 출력 없음(분리 HEAD 29649223 · 2026-11-21 조립 실측) 일 것입니다 — ui/m6-*·ui/m7-*·ui/m8-*·ui/m9-* 가지여도 멈추지 않음
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune      ← 원격에서 지워진 가지 표시가 정리된다(«[deleted]» 줄이 나와도 정상)
  git checkout --no-track -b ui/m8-h01-hold-banner origin/main      ← 🔴 최신 main 에서 새 가지로 옮긴다 · git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부) · 끝에 git branch --show-current ← «ui/m8-h01-hold-banner» 한 줄(아니면 멈추고 채팅으로)
  git grep -c "contractVersion = '1.35.0'" -- packages/domain_contracts/lib/src/contract_version.dart   ← «…contract_version.dart:1»(2026-11-21 조립 실측 · 🔵 출력이 없으면(계약 판이 1.36.0+ 로 오른 뜻) 멈추지 말고 제출 글 ① 끝(커밋 목록 코드 블록 뒤)에 «계약 줄 출력 없음 — 아래 이름 줄 전부 기대대로» 한 줄 · 이 카드 몫 이름이 그대로인지 아래 줄들이 본다)
  git grep -c "@Default(<String>\[\]) List<String> holdLabels," -- packages/domain_contracts/lib/src/dto/safety.dart   ← «…safety.dart:1»(v1.35 K295 · 화면이 읽는 칸)
  git grep -c "static const String safetyStatesHolds = 'safety_states_holds.json';" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart   ← «…fixture_paths.dart:1»(표본 2행)
  git grep -c -F "final RegExp holdsRead = RegExp(r'\.holds\b');" -- packages/domain_contracts/test/contracts/c68_v135_contract_debts_test.dart   ← «…c68_v135_contract_debts_test.dart:1»(C-68 ⑧ — ui_* lib 의 .holds 를 막는 줄 · 읽기만)
  git grep -c "class RecordingLinkOpener implements AppLinkOpener" -- packages/domain_contracts/lib/testing.dart   ← «…testing.dart:1»(테스트의 링크 기록기 · 읽기만)
  git grep -c "class ShellStaleBanner extends StatelessWidget" -- packages/ui_shell/lib/src/common/shell_common.dart   ← «…shell_common.dart:1»(이 클래스 바로 뒤에 새 절을 더한다)
  git grep -c "배럴(lib/ui_shell.dart)에 export 하지 않는다" -- packages/ui_shell/lib/src/common/shell_common.dart   ← «…shell_common.dart:1»(공용 조각 = 배럴 밖 · 그대로)
  git grep -c "if (stale) ShellStaleBanner(asOf: today.asOf)," -- packages/ui_shell/lib/src/ops_home.dart   ← «…ops_home.dart:1»
  git grep -c "final SafetyState? safety = safetyAv.valueOrNull;" -- packages/ui_shell/lib/src/ops_home.dart   ← «…ops_home.dart:1»(홈이 이미 받는 안전 상태 · 새 구독 0)
  git grep -c "kill switch slot fakes" -- packages/ui_shell/test/shell_fakes.dart   ← «…shell_fakes.dart:1»(R16d 끝 절 머리 · 이 카드 = 그 뒤 끝 절 · 검색어 = ASCII)
  git grep -c "Set<String> homeAllowed({" -- packages/ui_shell/test/shell_fakes.dart   ← «…shell_fakes.dart:1»(R13b 도우미 · 재사용)
  git grep -c "SafetyState safetyFixtureRow(int index)" -- packages/ui_shell/test/golden/golden_support.dart   ← «…golden_support.dart:1»(재사용)
  git grep -c "07 v2" -- docs/ai-context/prompt_M8.md   ← «…prompt_M8.md:1»(판 v2 머리 줄 · 아래 줄 번호가 이 판 기준 · 없으면 멈춤 · 검색어 = ASCII)
  ls docs/ai-context/send/R16e-Bob-H01HL.md   ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/H01HL_questions.md   ← 보여야 함(빈 표가 이미 있다 — 새로 만들지 않는다)
  ls packages/ui_shell/test/golden/goldens/h01_normal_light.png   ← 보여야 함(R13b PNG · 읽기만 · 다시 찍지 않는다)
  반대(출력 없어야 함): git grep -n "holdLabels" -- packages/ui_shell
  반대(없어야 함): ls packages/ui_shell/test/hold_banner_test.dart
  반대(없어야 함): ls packages/ui_shell/test/golden/hold_banner_golden_test.dart
  melos.bat bootstrap → melos.bat run build:gen → cd packages/ui_shell → flutter test ← 시작 기준 «+493: All tests passed!»(2026-11-21 조립 실측 «00:46 +493» · 줄 머리 시각은 실행마다 다름 · 끝 줄의 수를 «시작 기준 N» 으로 · 다르면 제출 글 ① 끝에 «까닭: …» 한 줄(확인한 사실만 · 모르면 `까닭 미상`) · 실패가 있으면 멈추고 끝 20줄을 채팅으로) → cd ../..
  → 채팅 «R16e 단계 1 끝 — 시작 기준 +N» 한 줄(N = 위 끝 줄 수)

■ 계약 v1.35 이름표 — R16e 몫(0단계가 확인한 것 · 🔴 코드가 정본 — 아래와 다르면 멈추고 질문 파일에 · v1.35 실제 글자 = 병합 PR #319 squash e26760a0 · 01 §44 K295)
  dto/safety.dart  SafetyState { … holds(🔴 화면 미참조) · 🆕 holdLabels: List<String>(기본 빈 · JSON hold_labels · holds[i] ↔ holdLabels[i] 같은 차례 · 같은 길이 — 엔진 완성 문장) … }
                — 🔴 화면은 holdLabels 만 받은 차례대로 그린다 · domain_contracts 배럴로 이미 보인다(import 더하기 0)
  fixtures/safety_states_holds.json  행 0 = holdLabels 한 줄(키 검증 전 hold 문장) · 행 1 = holdLabels 한 줄(기기 이전 hold 문장) · 🔴 표본 값을 고치지 않는다(테스트는 행을 이어 붙여 두 줄 입력을 준비할 뿐)
  ui_shell lib/src/ops_home.dart  final SafetyState? safety = safetyAv.valueOrNull;(홈이 이미 받는 값 · 블록 1 · 3 · 9b 가 쓴다 · 🔴 새 Provider·구독 0)
  ui_shell lib/src/common/shell_common.dart  ShellAsOfHeader · ShellStaleBanner · ShellSkeleton · ShellErrorView · ShellPlaceholder(공용 조각 · 배럴 밖 · 홈은 import 'common/shell_common.dart'; 로 이미 본다)
  🔴 쓰지 않는 것: holds · SafetyHoldCodes · LIVE_AWAITING_KEYS · MIGRATION_IN_PROGRESS 글자 · FlagIds · activeFlags · breakerLevel · RunModeCard · AppRoutes · shellLinkOpenerProvider(배너에서) · ShellLabels(새 라벨 0 · 배너 안 셸 글자 0) · 새 Provider · DateTime · Colors.* · Color(…) 리터럴 · TextStyle.

■ 자리 표 (하나 · 위치 = 홈 ListView 머리 배너 층 · 블록 밖)
  H-01 OpsHome ListView children 차례: ShellAsOfHeader(Key h01-asof) → ShellStaleBanner(있을 때) → 🆕 ShellHoldBanner(Key h01-holds · safety != null && safety.holdLabels.isNotEmpty 일 때만) → 블록 1 InkWell(Key h01-status) 또는 재시도(h01-status-fail) → 블록 2 … 9b(무변경)
  ShellHoldBanner(공통 조각) 안: Card(cs.tertiaryContainer · margin 12/4) > Padding(16/8) > Column(start) > 줄마다 Row(ValueKey<String>('hold-line-$i') · start) > Icon(Icons.pause_circle_outline · cs.onTertiaryContainer · 20) · SizedBox(width 8) · Expanded(Text(받은 글자))
  🔴 빈 = 부재: safety 가 null(로딩·오류) 이거나 holdLabels 가 비면 배너 자리 0(Key h01-holds 부재 · 아이콘 0) · 줄 수 = 받은 목록 길이 그대로 · 차례 = 받은 차례 그대로.

■ 규칙 요약 (전문 = prompt_M8.md · 우선순위 = 코드 > 이 카드 > 01 §44(계약 v1.35) > 04 §2-4 · §4-1 > prompt_M8 · 정본 = 이 카드의 글자 — 앞 카드를 찾지 않는다)
 1 고치는 곳 = packages/ui_shell + inbox/H01HL_questions.md 만. 고치는 lib = 둘뿐 — lib/src/common/shell_common.dart(새 절 «Hold banner» 40줄 더하기) · lib/src/ops_home.dart(배너 7줄 더하기) — 아래 «■ 화면» 글자 그대로(🔴 그 밖 줄 수정 0 · numstat «40 0» · «7 0» — 정적 T04 · 지운 줄 0 — T05).
   import 줄 더하기 0(두 파일 모두 필요한 import 를 이미 갖는다 — shell_common = domain_contracts · material · ops_home = common/shell_common.dart · 넣으면 analyze 중복).
   새 파일 = test/hold_banner_test.dart · test/golden/hold_banner_golden_test.dart · 새 PNG 4. 공용 = test/shell_fakes.dart 파일 끝에 절 머리 «// ── R16e — H-01 hold banner fakes ──» + 그 아래만(🔴 기존 줄 수정 0 · import 더하기 0 · numstat «<재량> 0» — T19 · 이 절에서 ASCII 밖 글자는 절 머리 한 줄뿐 — T22).
   고치면 반려: 그 밖 ui_shell 파일 전부 — 🔴 lib/ui_shell.dart(배럴 23) · lib/l10n/labels.dart(라벨 37) · lib/src/shell_providers.dart(주입 23) · lib/src/shell_scaffold.dart · lib/src/routing/** · lib/src/incident/** · lib/src/handbook/** · lib/src/onboarding/** · lib/src/alerts/** · ops_rhythm.dart · watchdog_board.dart · device_risk_board.dart ·
     기존 테스트 전부(🔴 test/ops_home_test.dart · test/golden/h01_golden_test.dart 포함 — 이 카드 테스트는 새 파일에만) · 기존 PNG 96 · test/golden/golden_support.dart · test/golden/README.md · test/flutter_test_config.dart · pubspec.yaml · analysis_options.yaml · README.md · domain_contracts/** · apps/** · 다른 ui_*(정적 T18).
 2 값 = SafetyState.holdLabels 하나를 받은 그대로 — 셸이 짓는 글자 0 · 정적 라벨 +0(T13 정확히 37) · 한국어 리터럴 0(T17) · 🔴 lib 의 .holds · SafetyHoldCodes 0(C-68 ⑧ · T11) · 새 테스트 파일의 .holds · SafetyHoldCodes · hold 코드 글자 0(T12 — 두 줄 입력은 fakes 의 holdPair 가 준비한다).
 3 고르기 0 — 배너 유무 = safety != null && safety.holdLabels.isNotEmpty 하나 · 줄 꼴 = 정적 하나(아이콘 1 · 색 2 — T09 정확히 3줄) · 글자 내용·차례·개수·hold 코드·모드·플래그·차단 등급으로 꼴·색·아이콘·자리를 고르지 않는다(더한 lib 줄의 낱말 0 — T10).
 4 차례 = 받은 차례 그대로 — for (final (int i, String l) in labels.indexed) 하나 · 정렬·뒤집기·자르기·합치기·중복 제거·first·last·length 0(T10).
 5 탭 0 · 링크 0 — InkWell · GestureDetector · onTap · onPressed · Tooltip · Semantics · AppRoutes · ref. 더하기 0(T10) · 배너는 블록 1 탭 칸(InkWell h01-status) 밖에 있다.
 6 주입 +0 — 홈이 이미 받는 safety 를 넘긴다 · 새 Provider 0(T15 정확히 23) · 🔴 shell_providers.dart 무수정(T18).
 7 새 위젯 클래스 = ShellHoldBanner 하나(shell_common · 배럴 밖 — T30) · 그 밖 private 위젯·도우미 메서드 0 · ShellHoldBanner 이름 줄 정확히 3(T08 — 클래스 · 생성자 · 홈의 사용) · 배너·줄 Key 줄 정확히 2(T07).
 8 기존 동작 무변경 — 기존 표본 holdLabels 빈 → 배너 부재 = 지금과 같은 홈 → 기존 홈 테스트(T01-01 ~ T01-12 · 골든 h01_* 16장)는 손대지 않고 그대로 통과해야 한다 — 🔴 기존 테스트·PNG 를 고쳐서 맞추면 반려 사유 ②.
 9 본문 0 — 블록 1~9b · 재시도 · 스켈레톤 · 오래된 데이터 배너 무수정 · 새 Scaffold·SafeArea·오버레이 0 · 시계·asOf 0.
10 테스트 = 아래 «■ 테스트 최소 목록» 의 두 파일 글자 그대로(🔴 견본 = 파일 전문 — 바꿔 쓰기(단언 빼기 · 경우 빼기 · greaterThanOrEqualTo 를 greaterThan 으로 · 목록 == 를 length 로 · .first 빼기) 금지 — 같은 뜻이라도 견본보다 약하면 반려 사유 ② · dart format 0 changed 기대(✅ 조립 시제품)) ·
   🔴 가짜·도우미 = fakes 끝 절 글자 그대로(블록 몸 · if · 셈 변수로 바꿔 쓰지 않는다 — C4r8a-9) · 🔴 if 0(새 테스트 파일 · fakes 더한 줄 — T25) · 경우 for 는 testWidgets 밖(C4r14b-1) · 경우 루프 꼴 = 이름 붙은 레코드(C4r9a-9 — for (final c in <({String name, SafetyState safety})>[…]) · 위치 레코드·분해 꼴 0) ·
   경우 이름 = 견본 글자 그대로(keys · migration · keys_then_migration · migration_then_keys · normal · blocked · two — C4r9b-4) · 정상 상태 테스트마다 ⓡ = expect(find.text(ShellLabels.retry), findsNothing); 한 줄(HL-01~HL-06 — T20 정확히 6) ·
   ⓗ = hasLength 2줄(HL-01 · HL-02 의 전제 줄 — T21) · (전제) = 3줄(HL-01 · HL-02 · HL-03 본문 첫 줄 · 주석 정확히 `// pre` — T29 · 표본이 바뀌어 줄 수가 달라지면 공허 통과 대신 먼저 실패한다 · R16b C4O-1 선례) ·
   «부재 쪽» 양성 기준점(C4r15c-1 — HL-03 = h01-status findsOneWidget · HL-07 = h01-status-fail findsOneWidget) · 배너마다 shownTexts == 받은 목록(C4r16a-1 — HL-01 · HL-02) ·
   C4r9b-1 · C4r7b-5 · C4r7a-1 · C4r15b-1 · C4r8a-4(누름·기다림·결과·실패·잠금·입력칸) = **R16e 해당 없음**(쓰기 0 · 결과 0 · 입력칸 0 · 탭 0 — HL-05 가 «탭해도 링크 0» 을 본다 — 기록) ·
   테스트 이름 = 번호 + ASCII · C4r9a-5 — 새 테스트 파일 둘은 **주석 포함 전부 ASCII**(정적 T23) · 🔴 반려 꼴: bool 칸 + if · nullable 흐름 칸 · c.name == 비교 · expect(a || b, isTrue) · 단언 없는 tester.takeException();(T28) · isNotNull 단언 · find.byType(X) 를 findsWidgets 로 세기 · 목록을 length 로만 보기.
11 골든 = 새 PNG 4(hl_h01_keys · hl_h01_two × light/dark) · 크기 = kGoldenPhoneSize(pumpForGolden 기본 · 높이 재량 0 · 여백 재량 0 = lib 글자 고정) · --update-goldens 는 hold_banner_golden_test.dart 만 · 🔴 기존 PNG 96 재생성 0 · golden:approved 안 붙임.
12 도구 = melos.bat run format:fix(저장소 뿌리 · 안 되면 packages/ui_shell 에서 dart format .) → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로 · 🔵 check:labels 예외 — 아래 줄) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다(5분 넘게 출력이 없으면 끊고 패키지별 flutter test) ·
   melos.bat run test:contracts 도 5분 넘게 출력이 없으면 끊고 패키지별로 — melos.bat run check:boundaries · packages/domain_contracts 에서 dart test — 끊은 사실 한 줄(C4r16b-5 · 중첩 melos 라 같은 멈춤 꼴) ·
   🔵 check:labels 는 main 에서 이미 🔴(apps/app_operator_android 한글 리터럴 — 엔진·조립 레인 몫 · ui_shell 0줄 · 이 카드 무관) — test:contracts 가 그 단계에서 FAILED 로 끝나는 것은 멈춤 사유가 아니다(우회 = «■ 제출» ⓐ~ⓒ · [FAIL] 경로에 packages/ui_shell 가 있으면 그것은 이 카드 결함 — 고친다) ·
   🔴 C4r6c2-5 · C4r9a-2 — ② 끝에 check:labels 줄 **한 줄 필수** · apps 줄 수는 **Git Bash 경로로 check_labels.sh 를 따로 돌린 출력 파일을 세는 명령**이 채운다(제출 글에는 자리표시 <L_APPS> 를 쓰고 명령이 숫자로 바꾼다 · 🔴 손으로 세거나 화면에서 옮겨 적지 않는다) ·
     🔵 이 PC 의 PowerShell · cmd 에서 그냥 bash 라고 치면 WSL 이 돈다 — Git Bash 는 늘 경로로 부른다(& "C:\Program Files\Git\bin\bash.exe" …) ·
   패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · directives_ordering · strict-raw-types·strict-inference · prefer_final_locals · unnecessary_lambdas.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr·size·count·total 이 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 카드 lib 에 산술 0 · 테스트의 size 칸 0).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·URL·토큰·기기 식별자 0 · PR·라벨·병합은 통합 담당.
15 주석 — 고친 lib 2파일의 주석 = «■ 화면» 글자 안의 세 줄뿐(shell_common 절 머리 · 클래스 문서 한 줄 · ops_home 배너 위 한 줄 — numstat 이 «40 0» · «7 0» 으로 못박는다) · 새 테스트 파일 = 견본 글자의 영어 ASCII 주석 그대로(머리 2줄 · 구획 «// -- HL-0n: … --» 일곱 줄 · 골든 머리 2줄).
🔴 보고 규칙(strict 나눔 — 통합 담당 공통 조문 · 아래 글자가 전부) — 반려 사유 ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) · 반려 사유 ② **코드·테스트 결함**과 **거짓 주장** = **반려** · 반려 사유 ③ «예고 변이» 하나라도 통과 = **반려**(«🔵 참고» 줄의 변이 = 기록만 · ③ 밖) · 카드 구멍 = 반려 근거 아님.
   C4r6b-8 — 최소 목록의 **굵은 단언 하나라도 빠짐 = 반려 사유 ② + ③** → «■ 제출» N7 의 줄마다 기대 수와 대조한 뒤에만 낸다 · 🔴 기존 테스트·골든 파일 수정 = 반려 사유 ②(T18).
   C4r6c2-10 — 카드가 «그대로» 라고 적은 견본(코드 글자 — «■ 화면» lib 글자 · fakes 끝 절 · 테스트 두 파일 전문)을 같은 뜻으로라도 바꿔 쓰면 반려 사유 ② — 견본보다 약하면 반려 · C4r8a-9 — 가짜(fakes 끝 절)를 블록 몸 · if · 셈 변수로 바꿔 쓰면 반려 사유 ② — 실효 0 이어도.
   C4r9a-1 · -2 — 보고 글의 수 · 출력 줄은 **명령 출력을 파일로 떠서 기계로** 채운다(② «ⓡ = T20 출력:» · «ⓗ = T21 출력:» 다음 줄 = 정적 출력 파일의 «## T20» · «## T21» 다음 줄을 명령으로 덧붙임 · ② 끝 check:labels 의 apps 수 = 명령이 <L_APPS> 를 바꿔 넣음) — 손으로 옮긴 줄 하나 · 손으로 적은 수 하나가 실제와 다르면 실효 0 이어도 반려 사유 ② 거짓 주장.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 dy 는 이름마다 --plain-name 으로 잰 수를 출력 파일에서 옮긴다(C4r16a-4 — 아래 «■ 골든» dy 다시 재기 · «■ 제출» N4 ⓐ ⓑ 자기 대조) · 정적 T20 · T21 · T29 출력을 카드 «줄의 뜻과 기대» 의 수와 대조한 뒤 붙인다(C4r16b-1 — N5) ·
   골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다) · PNG 는 이름마다 light 한 장만 연다(2장) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다) ·
   C4r6b-4 — 아래 «■ 제출» ③ 견본 2이름(조립 시제품 PNG blob)과 내 PNG 가 blob 같으면 견본 글자 그대로 · blob 이 다르면(git hash-object 로 본다) 그 이름 light PNG 를 열어 센다 ·
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 · 영문 금지) · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 n줄» = PNG 의 글자 **행** 수(이어진 글자 행은 한 덩어리 — 쪼개지 않는다 · C4r14a-3) · «상자» = 테두리·모서리가 보이는 덩어리 · «아이콘» = 작은 표식 — 상자로 세지 않는다 · 🔴 글자 줄 덩어리의 괄호 안에 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다) ·
     드라이런 기대 🟡 = **1**(✅ 드라이런 — [G1] 골든 표 4행 한 항목 «배치·잘림 칸을 덩어리로 셀 수 없어 PNG 와 대조하지 않았다» · 사전검사 ②(보고 글 검사) 기대 = 🔴 0 · 🟡 1)(그대로 둔다 · 다시 열지 않음 · 칸을 고치지 않는다 · 헛경보 · C4r5b-4 꼴).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 제출 글은 저장 파일로) · 🔵 이 카드에는 «S05 결과:» 상자가 없다(링크 0 · 정적 T 에 S05 자리 없음) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M8.md 173~182행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지 · 상태 이름을 감싼 «» 까지 견본 글자 그대로 — C4r15a-1 · C4r16a-5) · «테스트 파일별:» 줄 = 끝 줄 그대로(파일 이름 접두 0 — C4r16a-6) ·
   저장 파일·붙인 출력에 깨진 글자 0 · CR 0 · 코드 울타리 = 백틱 세 개 · 빈 코드 블록 0(C4r8a-6 — N10 · C4O-2 · C4Q-2 · C4Q-3 — N6 · N8) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외 — C4r15c-4).

■ 프롬프트보다 이 카드가 이긴다 — 13항 (prompt_M8.md 183줄 판 v2)
 ① 2행·119행 «범위 S-01» → 이 카드 = H-01 운영 홈 머리 배너 층의 hold 배너 하나 + 셸 공통 조각 하나 · 다른 블록·화면 0
 ② 113~118행 범위 목록 → 이 카드 = H-01 hold 배너 · 블록 1~9b · S-01 · S-02 · H-02 · H-03 · N · D · W · B · O · R · V = 병합됨 — 고치지 않는다
 ③ 12~14행 의존 → 그대로 · 새 import 0(T16 · T18 pubspec)
 ④ 15~19행 «라우터·플랫폼 가드는 셸 한 곳» → 해당 없음(플랫폼 분기 0 · 홈 = 운영 앱 폰 홈 자리)
 ⑤ 20~23행 시계 → 해당 없음(시계·asOf 0)
 ⑥ 24~31행 재계산 → 산술 0(판정 = 빈 목록 여부 하나)
 ⑦ 32~38행 문구 → 라벨 +0 · 셸 글자 0(줄 글자 = 엔진 holdLabels · T13 · T17)
 ⑧ 41~47행 «안전 화면 … 렌더·복제·요약 금지 · 딥링크와 삽입 자리만» → hold 배너 = 안전 «화면» 이 아니라 엔진이 지은 상태 문장의 표시(01 §44 K295 «화면 = holdLabels 만») · 해제·재개 버튼·링크·확인 대화 0 · hold 코드 해석 0
 ⑨ 87~99행 제출 → ■ 제출(저장 파일 세 번 나눠 쓰기 · 채팅 두 줄 · 사전검사 두 번 · ⓡ · ⓗ 둘째 줄 · check:labels 수 = 명령)
 ⑩ 100~105행 골든 → 새 PNG 4 · 기존 96 재생성 0(기존 표본 = 배너 부재 → 기존 화면 그대로)
 ⑪ 106~111행 질문 파일 → inbox/H01HL_questions.md(조립 커밋이 만든 빈 표 · 새 파일 금지)
 ⑫ 127~128행 브랜치·PR → ui/m8-h01-hold-banner · «[M8] H-01 hold 배너(R16e)»
 ⑬ 153~154행 «킬스위치 … 삽입 자리만 · 진입 경로 항상 살아 있어야» → 해당 없음(킬스위치 자리 · 블록 1 탭 무변경 — 배너는 블록 1 위에 끼울 뿐) · 172~182행 자체 점검 → ■ 제출 ② 상자 + 괄호(🔴 10번 = 이 카드 범위 안)

■ 화면 — lib 글자(🔴 이 글자 그대로 · 더하기만 · dart format 0 changed 기대 — ✅ 조립 시제품)
 (가) lib/src/common/shell_common.dart — 기존 줄 «// ── Skeleton ──…» 바로 **앞**(ShellStaleBanner 클래스를 닫는 «}» 와 그 뒤 빈 줄 다음)에 아래 40줄(마지막 줄 = 빈 줄 · 머리 줄의 «─» 수 = 위 «// ── Skeleton» 줄과 같은 너비 — 아래 글자 그대로 복사):
      ┌── (가) 복사 시작(다음 줄부터 · 40줄 · 마지막 줄 = 빈 줄)
// ── Hold banner ────────────────────────────────────────────────────────────────

/// hold 줄 — 엔진 문장(SafetyState.holdLabels)을 받은 차례대로 · 줄마다 같은 꼴(01 §44 K295).
class ShellHoldBanner extends StatelessWidget {
  const ShellHoldBanner({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.tertiaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final (int i, String l) in labels.indexed)
              Row(
                key: ValueKey<String>('hold-line-$i'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.pause_circle_outline,
                    color: cs.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

      └── (가) 복사 끝(이 줄 앞까지)
 (나) lib/src/ops_home.dart · _OpsHomeState.build 의 ListView children — 기존 줄 «        // 블록 1 — 안전 상태» 바로 **앞**(«if (stale) ShellStaleBanner(asOf: today.asOf),» 와 그 뒤 빈 줄 다음)에 아래 7줄(마지막 줄 = 빈 줄):
      ┌── (나) 복사 시작(다음 줄부터 · 7줄 · 마지막 줄 = 빈 줄)
        // hold 배너 — 블록 아님(배너 층 · 01 §44 K295)
        if (safety != null && safety.holdLabels.isNotEmpty)
          ShellHoldBanner(
            key: const Key('h01-holds'),
            labels: safety.holdLabels,
          ),

      └── (나) 복사 끝(이 줄 앞까지)
 🔴 들여쓰기 = 위 글자 그대로(dart format 이 고치지 않는 꼴 — ✅ 조립 시제품 0 changed) · numstat = shell_common.dart «40 0» · ops_home.dart «7 0»(T04) · 지운 줄 0(T05) · 줄 번호(✅ 조립 시제품) = shell_common.dart 55(절 머리) · 58 · 59(클래스 · 생성자) · 67(Card 색) · 76(줄 Key) · 80 · 81(아이콘 · 색) / ops_home.dart 139(주석) · 140(if) · 142(배너 Key) · 143(labels).
■ Key 표 (2 — ✅ 조립 시제품 T07 2줄) — h01-holds(홈 · ShellHoldBanner 에 · 빈 = 부재) · hold-line-$i(조각 안 · 줄마다 Row · ValueKey<String>) · 🔴 Key 를 Text·Icon·Card 안쪽에 달지 않는다 · 새 Key 그 밖 0.
■ 할 일 — (1) «[M8] R16e (1) H-01 hold 배너 공통 조각 · 홈 배너 층» = (가) + (나) — lib 2파일 · (2) «[M8] R16e (2) hold 배너 테스트» = fakes 끝 절 + hold_banner_test.dart · (3) «[M8] R16e (3) 골든 hl_h01_keys · hl_h01_two 4장» = 골든 테스트 파일 + PNG 4 · (4) «[M8] R16e (4) format · 질문» · 커밋 제목 = 내용(C4r15c-3) ·
   C4r16c-1 — 골든 테스트 파일(test/golden/hold_banner_golden_test.dart)은 (3) 골든 커밋에 PNG 와 함께 — (2) 에 넣지 않는다 · (4) 고정 제목은 format 0 changed 여도 그대로(질문 파일 «측정:» 행이 이 커밋의 몫) ·
   (2) 커밋 전에 git add <그 두 파일> 뒤 «정적 묶음» 미리 돌리기(git add 전이면 새 테스트 파일을 git grep 이 못 봐 «통과» 처럼 보인다 · ✅ 조립 시제품 미리 돌리기 124줄(EXIT:1 14 · EXIT:0 16) — T19 · T22 는 git diff origin/main...HEAD(커밋된 것만)를 읽고 T03 · T26 · T27 은 골든 파일·PNG((3) 커밋 몫)를 세므로 미리 돌리기에서는 T03 한 줄(test/hold_banner_test.dart:7) · T19 0줄 · T22 EXIT:1 · T26 0줄 · T27 96 이 정상 — 멈추지 않는다 · 이 다섯은 (4) 뒤에야 기대와 맞는다) ·
   커밋 꼴(C4r6a-7 · C4r6b-5) — 고칠 때마다 새 커밋 (5)·(6)… · 제목 = 그 커밋 몫 + 까닭 낱말 = 실제 출처(«정적 Txx» · «사전검사 Tx» · «analyze <lint>» — 예: «[M8] R16e (5) 정적 T10 더한 lib 줄 낱말 빼기») · amend 금지 · C4r8a-7 — 정적 Txx 를 맞추려 lib 를 고치면 그 커밋은 따로 (n) «정적 Txx» — 테스트 커밋에 섞지 않는다 ·
   골든 커밋 뒤 lib 코드 줄을 바꾸면 골든을 다시 돌려 통과시키고 제목 끝에 «· 골든 다시 돌려 통과» · C4r6c2-4 — (4) 를 낸 뒤 고치면 (5) — (4) 를 두 번 쓰지 않는다 · 번호는 커밋마다 하나씩 늘린다.
■ 쓰기 단계 — C4r7a-8 · C4r7b-4 · C4r7c-5(쓰기 단계 = «새 테스트 파일 계획 > 750줄» 기본 꼴 · 이 카드 = 테스트 파일 229줄 · lib +47 — 750 아래지만 답 길이 한도 예방과 제출 글 세 번 나눠 쓰기를 위해 R16d 꼴을 쓴다) · 🔴 한 답 = 한 단계 · 단계 끝 채팅 = «R16e 단계 N 끝» 한 줄뿐(단계 1 만 «— 시작 기준 +N» 꼬리) · 발주자가 «계속» 이라고 하면 다음 단계 · 단계 = 12 답 ·
   🔴 파일은 덩어리마다 ≤ 250줄로 쓴다 — 첫 덩어리 = 새 파일로 쓰기 · 다음 덩어리 = 그 파일 **끝에 덧붙이기**(편집기 도구의 «끝에 넣기» · 앞 덩어리를 다시 쓰거나 고치지 않는다) · 그래도 넘을 것 같으면 그 단계를 테스트 사이에서 둘로 나눠 «R16e 단계 Na 끝» · «R16e 단계 Nb 끝» ·
   🔴 단계 4 ~ 5 동안(테스트 파일이 닫히기 전 — 5 가 main() 을 닫는다)에는 format·analyze·test 를 돌리지 않는다 · 도는 순서(차례 그대로 · 건너뛰기 0):
   단계 1 = 위 «■ 0단계» 전부(시작 기준 N) → «R16e 단계 1 끝 — 시작 기준 +N»
   단계 2 = docs/ai-context/prompt_M8.md 를 처음부터 끝까지 읽기 + «■ 화면» (가) · (나) 를 글자 그대로 → packages/ui_shell 에서 dart format lib(0 changed 기대) → flutter analyze(끝 줄 «No issues found!») → flutter test(옵션 없이 · 🔴 끝 줄 = 시작 기준 N 그대로 «+N: All tests passed!» — 기존 테스트가 하나라도 깨지면 고칠 곳은 이 카드 lib 글자다 · 기존 테스트·PNG 를 고치지 않는다 · 멈추고 끝 20줄을 채팅으로) → git add lib/src/common/shell_common.dart lib/src/ops_home.dart → 커밋 (1) → «R16e 단계 2 끝»
   단계 3 = test/shell_fakes.dart 끝 절(아래 «■ 테스트 최소 목록» 공통 — 한 덩어리 · 덧붙이기 · 69줄) → «R16e 단계 3 끝»
   단계 4 = test/hold_banner_test.dart 첫 덩어리(새 파일 · 아래 «■ 테스트 최소 목록» 덩어리 A — 머리 주석 두 줄 · import · void main() { · 머리 입력 · HL-01 · HL-02 · HL-03 · 109줄) → «R16e 단계 4 끝»
   단계 5 = 덧붙이기: 덩어리 B(HL-04 · HL-05 · HL-06 · HL-07 + main() 을 닫는 } 한 줄 · 120줄) → «R16e 단계 5 끝»
   단계 6 = dart format test → flutter analyze(packages/ui_shell · 끝 줄 «No issues found!» — info 하나라도 나오면 고친다) → flutter test test/hold_banner_test.dart(끝 «+14: All tests passed!» · 실패면 고친다) → git add test/shell_fakes.dart test/hold_banner_test.dart → «정적 묶음» 미리 돌리기 → 커밋 (2) → «R16e 단계 6 끝»
   단계 7 = 골든 테스트 파일(새 · 한 덩어리 · 47줄) → dart format test → flutter analyze → «■ 골든» 명령(--update-goldens → 옵션 없이) → git add test/golden/hold_banner_golden_test.dart test/golden/goldens/hl_h01_keys_light.png test/golden/goldens/hl_h01_keys_dark.png test/golden/goldens/hl_h01_two_light.png test/golden/goldens/hl_h01_two_dark.png → 커밋 (3) → «R16e 단계 7 끝»
   단계 8 = «■ 골든» dy 다시 재기(네 출력 파일 r16e_dy1~4) → 질문 파일 A1 · A2 → cd ../..(저장소 뿌리) → melos.bat run format:fix → git status --short(← M docs/ai-context/inbox/H01HL_questions.md 한 줄 · format 이 고친 파일이면 이 카드가 만든·고친 10개 경로(«■ 제출» name-status 기대 목록) 안의 M 만 허용 · 그 밖 경로가 보이면 커밋하지 말고 멈추고 채팅으로) → git add docs/ai-context/inbox/H01HL_questions.md(저장소 뿌리 · + format 이 고친 목록 안 파일) → 커밋 (4) → «R16e 단계 8 끝»
   단계 9 = «■ 제출» 명령 줄(flutter test 셋 → 출력 파일 r16e_t_hl · r16e_t_gold · r16e_t_all · check_boundaries · melos 네 줄 · check_labels 직접 · git status · name-status · 사전검사 ① · push · ① 출력 파일 · 정적 출력 파일 · ④ 줄 파일) → N7 · N5 ⓐ · N4 ⓐ → «R16e 단계 9 끝»(🔵 길면 묻지 않고 둘로 — 9-1 = flutter test 셋 · check_boundaries · melos 네 줄 · check_labels 직접 → «R16e 단계 9-1 끝» / 9-2 = git status 부터 N4 ⓐ 까지 → «R16e 단계 9-2 끝»)
   단계 10 = PowerShell 에서 $env:TEMP 한 줄(출력 = 저장 폴더 절대 경로 — 편집기 도구에는 이 절대 경로를 쓴다 · 편집기는 $env:TEMP 를 풀지 못한다) → 제출 글 ① 을 저장 파일에 새로 쓰기(«■ 제출» 저장 꼴) → «R16e 단계 10 끝»
   단계 11 = 제출 글 ② 를 저장 파일 끝에 덧붙이기(정적 출력 · ⓡ · ⓗ 둘째 줄 · 테스트 파일별 두 줄 = 출력 파일에서 AppendAllText 로 · check:labels 줄 = 편집기로 <L_APPS> 를 쓴 뒤 바꿔 넣기 한 줄) → «R16e 단계 11 끝»
   단계 12 = 제출 글 ③ · ④ · ⑤ + flutter test 한 줄(r16e_t_all.txt 끝 줄을 이 단계에서 화면에 띄워 그대로)을 덧붙이기 → N4 ⓑ → N5 ⓑ → N1 · N9 · N10 · N6 · N8 · N3(사전검사 ②) → 채팅 두 줄(이 단계의 끝 채팅은 «단계 12 끝» 대신 그 두 줄 · 🔵 길면 묻지 않고 둘로 — 12-1 = ③ · ④ · ⑤ + flutter test 한 줄 덧붙이기 → «R16e 단계 12-1 끝» / 12-2 = N4 ⓑ 부터 채팅 두 줄까지)
■ 정적 라벨 — 🔴 **0개 더함 · 정확히 37**(lib/l10n/labels.dart 무수정 · T13 «lib/l10n/labels.dart:37» · 배너 글자 = 엔진 몫).
■ 테스트 최소 목록 (줄 8 · 테스트 18 = 뷰 14 + 골든 4 · ✅ 조립 시제품 hold_banner «+14» · hold_banner_golden «+4»)
 공통: test/shell_fakes.dart 끝 절(🔴 앞 절 무수정 · import 더하기 0 — 필요한 import 는 이미 있다 · numstat «<재량> 0»(✅ 시제품 «69 0» — 첫째 = 재량 · 둘째 0 = 필수 · C4r16c-2) · 이 절에 if 0 · 절 머리 밖 ASCII 밖 글자 0 — T22) = 파일 끝(마지막 줄 «bool isAnyWidget(Widget w) => true;») 뒤에 빈 줄 하나 + 아래 글자 그대로:
      ┌── fakes 끝 절 복사 시작(다음 줄부터 · 68줄 — 앞 빈 줄 하나를 더하면 69줄 = numstat «69 0»)
// ── R16e — H-01 hold banner fakes ──

typedef HoldHomeInputs = ({
  OpsDailySummary today,
  AdviceInboxSummary advice,
  SleeveAllocationVm alloc,
  DiagnosticsVm diag,
  LedgerTrustBadge trust,
});

HoldHomeInputs holdHomeInputs() => (
  today: singleFixture(FixturePaths.m8OpsHomeNormal, OpsDailySummary.fromJson),
  advice: extraFixture(
    FixturePaths.m8OpsHomeAdviceZero,
    'advice_summary',
    AdviceInboxSummary.fromJson,
  ).copyWith(hasSuppressedNotice: false),
  alloc: singleFixture(
    FixturePaths.m6AllocationInBand,
    SleeveAllocationVm.fromJson,
  ),
  diag: singleFixture(FixturePaths.m8ReconBoardOk, DiagnosticsVm.fromJson),
  trust: singleFixture(
    FixturePaths.m7LedgerTrustSelfAuditDue,
    LedgerTrustBadge.fromJson,
  ),
);

SafetyState holdRow(int index) => SafetyState.fromJson(
  decodeEnvelope(fixtureText(FixturePaths.safetyStatesHolds)).rows[index],
);

SafetyState holdPair(SafetyState a, SafetyState b) => a.copyWith(
  holds: <String>[...a.holds, ...b.holds],
  holdLabels: <String>[...a.holdLabels, ...b.holdLabels],
);

List<Override> holdHomeOverrides({
  required HoldHomeInputs inputs,
  required Stream<SafetyState> Function(int call) safety,
  required RecordingLinkOpener opener,
}) => homeOverrides(
  safety: FakeShellSafetyRepository(state: safety),
  today: FakeShellOpsTodayRepository(today: (int call) => one(inputs.today)),
  advice: FakeShellAdviceRepository(summary: (int call) => one(inputs.advice)),
  alloc: FakeShellHoldingsRepository(
    allocation: (int call) => one(inputs.alloc),
  ),
  diag: FakeShellOpsStatusRepository(
    diagnostics: (int call) => one(inputs.diag),
  ),
  trust: FakeShellLedgerTrustRepository(grade: (int call) => one(inputs.trust)),
  opener: opener,
  clock: FixedClock(kGoldenNowUtc),
);

Set<String> holdHomeAllowed(HoldHomeInputs inputs, SafetyState safety) =>
    <String>{
      ...homeAllowed(
        today: inputs.today,
        safety: safety,
        advice: inputs.advice,
        alloc: inputs.alloc,
        diag: inputs.diag,
        trust: inputs.trust,
      ),
      ...safety.holdLabels,
    };
      └── fakes 끝 절 복사 끝(이 줄 앞까지)
   (🔵 기존 도우미 재사용 = homeOverrides · homeAllowed · pumpOpsHome · one · shownTexts · FakeShell*Repository · safetyFixtureRow · singleFixture · extraFixture · fixtureText · FixedClock · kGoldenNowUtc — 고치지 않는다 · pumpOpsHome 크기 = 390 × 2400 · 🔴 holdPair 는 두 상태의 holds 와 holdLabels 를 같은 차례로 함께 잇는다 — 계약 «같은 차례 · 같은 길이»(C-68 ⑥)를 테스트 입력에서도 지킨다 · holds 글자는 이 절에만)
 R16e — test/hold_banner_test.dart(줄 7 · 테스트 14 = HL-01 둘 · HL-02 둘 · HL-03 둘 · HL-04 셋 · HL-05 하나 · HL-06 셋 · HL-07 하나 · 229줄 = 덩어리 A 109줄 + 덩어리 B 120줄)
   🔴 견본 = 아래 두 덩어리 글자 그대로(파일 전문 · 차례 그대로 · 단언 하나도 빼거나 약하게 바꾸지 않는다) · 굵은 단언(빠지면 예고 변이가 산다 — N7 이 센다) = **shownTexts(h01-holds) == c.safety.holdLabels**(HL-01 · HL-02) · **hold-line-0 글자 == holdLabels.first · hold-line-1 이 hold-line-0 아래**(HL-02) · **h01-status 위쪽 ≥ 배너 아래쪽**(HL-01 · greaterThanOrEqualTo) · **h01-holds findsNothing · 아이콘 findsNothing**(HL-03 · HL-07) · **아이콘 목록 == filled(pause_circle_outline) · 아이콘 색 집합 == {onTertiaryContainer} · Card 색 == tertiaryContainer**(HL-04) · **InkWell 0 · opener.opened isEmpty**(HL-05) · **화면 글자 ⊆ 홈 글자 + hold 문장 · 문장마다 한 번**(HL-06):
      ┌── 덩어리 A 복사 시작(다음 줄부터 · 109줄 · 단계 4 — 새 파일)
// test/hold_banner_test.dart - R16e H-01 hold banner (engine hold lines in
// engine order, one static look, no lines = no banner). ASCII only.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

void main() {
  final HoldHomeInputs inputs = holdHomeInputs();
  final SafetyState keys = holdRow(0);
  final SafetyState migration = holdRow(1);

  // -- HL-01: one hold line per fixture row, banner above block 1 --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys', safety: keys),
    (name: 'migration', safety: migration),
  ]) {
    testWidgets('HL-01 one hold line ${c.name}', (WidgetTester tester) async {
      expect(c.safety.holdLabels, hasLength(1)); // pre
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('h01-holds'))),
        c.safety.holdLabels,
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('h01-holds'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('h01-asof'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('h01-status'))).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byKey(const Key('h01-holds'))).dy,
        ),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-02: two hold lines keep the engine order --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys_then_migration', safety: holdPair(keys, migration)),
    (name: 'migration_then_keys', safety: holdPair(migration, keys)),
  ]) {
    testWidgets('HL-02 hold lines in order ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.safety.holdLabels, hasLength(2)); // pre
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('h01-holds'))),
        c.safety.holdLabels,
      );
      expect(
        shownTexts(tester, find.byKey(const ValueKey<String>('hold-line-0'))),
        <String?>[c.safety.holdLabels.first],
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<String>('hold-line-1'))).dy,
        greaterThan(
          tester
              .getTopLeft(find.byKey(const ValueKey<String>('hold-line-0')))
              .dy,
        ),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-03: no hold lines = no banner --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'normal', safety: safetyFixtureRow(0)),
    (name: 'blocked', safety: safetyFixtureRow(3)),
  ]) {
    testWidgets('HL-03 no hold lines ${c.name}', (WidgetTester tester) async {
      expect(c.safety.holdLabels, isEmpty); // pre
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('h01-status')), findsOneWidget);
      expect(find.byKey(const Key('h01-holds')), findsNothing);
      expect(find.byIcon(Icons.pause_circle_outline), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

      └── 덩어리 A 복사 끝(이 줄 앞까지)
      ┌── 덩어리 B 복사 시작(다음 줄부터 · 120줄 · 단계 5 — 끝에 덧붙이기)
  // -- HL-04: every line has the same static icon and colors --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys', safety: keys),
    (name: 'migration', safety: migration),
    (name: 'two', safety: holdPair(keys, migration)),
  ]) {
    testWidgets('HL-04 one look ${c.name}', (WidgetTester tester) async {
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      final Finder banner = find.byKey(const Key('h01-holds'));
      final ColorScheme cs = Theme.of(tester.element(banner)).colorScheme;
      final List<Icon> icons = tester
          .widgetList<Icon>(
            find.descendant(of: banner, matching: find.byType(Icon)),
          )
          .toList();
      expect(
        icons.map((Icon i) => i.icon).toList(),
        List<IconData?>.filled(
          c.safety.holdLabels.length,
          Icons.pause_circle_outline,
        ),
      );
      expect(icons.map((Icon i) => i.color).toSet(), <Color?>{
        cs.onTertiaryContainer,
      });
      expect(
        tester
            .widget<Card>(
              find.descendant(of: banner, matching: find.byType(Card)),
            )
            .color,
        cs.tertiaryContainer,
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-05: the banner is not a tap target, no link opens --
  testWidgets('HL-05 banner is not a tap target', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpOpsHome(
      tester,
      overrides: holdHomeOverrides(
        inputs: inputs,
        safety: (int call) => one(holdPair(keys, migration)),
        opener: opener,
      ),
    );
    final Finder banner = find.byKey(const Key('h01-holds'));
    expect(
      find.descendant(of: banner, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      find.ancestor(of: banner, matching: find.byType(InkWell)),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey<String>('hold-line-0')));
    await tester.pumpAndSettle();
    expect(opener.opened, isEmpty);
    expect(banner, findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- HL-06: screen text = home texts plus the hold lines, each line once --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys', safety: keys),
    (name: 'migration', safety: migration),
    (name: 'two', safety: holdPair(keys, migration)),
  ]) {
    testWidgets('HL-06 screen text ${c.name}', (WidgetTester tester) async {
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((Text t) => t.data)
            .toSet()
            .difference(holdHomeAllowed(inputs, c.safety)),
        isEmpty,
      );
      expect(
        c.safety.holdLabels
            .map((String l) => find.text(l).evaluate().length)
            .toList(),
        List<int>.filled(c.safety.holdLabels.length, 1),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-07: safety stream error = retry block, no banner --
  testWidgets('HL-07 safety error shows retry and no banner', (
    WidgetTester tester,
  ) async {
    await pumpOpsHome(
      tester,
      overrides: holdHomeOverrides(
        inputs: inputs,
        safety: (int call) => Stream<SafetyState>.error(StateError('fail')),
        opener: RecordingLinkOpener(),
      ),
    );
    expect(find.byKey(const Key('h01-status-fail')), findsOneWidget);
    expect(find.byKey(const Key('h01-holds')), findsNothing);
  });
}
      └── 덩어리 B 복사 끝(이 줄 앞까지)
🔵 Bob 은 이 변이를 돌리지 않는다(통합 담당 · C4 가 돌린다) — 견본 글자를 그대로 쓰고 N7 을 통과하면 된다 · 🔴 예고 변이 — 괄호 = 잡는 테스트(✅ 조립 시제품 실측 · 숫자 = HL-NN 의 NN · 영문 = 경우 이름 · «×n» = 그 테스트의 경우 n 개 전부 · «/ 골든 n» = 잡는 골든 장수) · 🔵 «참고» 줄 = 기록만(보고 규칙 ③ 밖):
   🔴 = 잡는 테스트 하나뿐 — 최소 목록에서 굵게(✅ 조립 시제품 = **2** — 줄 수로 Card 색 고르기(HL-04 two) · 배너 탭(HL-05) · 그 밖 변이는 두 테스트 이상 또는 골든이 함께 잡는다):
   [배너 유무 · 자리] 배너 통째 빼기(01 ×2 · 02 ×2 · 04 ×3 · 05 · 06 ×3 / 골든 4) · 빈 목록에도 배너(isNotEmpty 빼기 — 03 ×2) · 블록 1 아래로 옮기기(01 ×2 / 골든 4) ·
   [차례 · 줄] 뒤집기(reversed — 02 ×2 / 골든 2) · 첫 줄만(take(1) — 02 ×2 · 04 two · 06 two / 골든 2) · 정렬(sort — 02 keys_then_migration / 골든 2) · 한 줄로 합치기(join — 02 ×2 · 04 two · 06 two / 골든 2) ·
   [꼴] 글자로 아이콘 고르기(startsWith — 04 keys · 04 two) · 🔴 줄 수로 Card 색 고르기(length > 1 — 04 two) · 차례로 아이콘 색 고르기(i == 0 — 04 ×3 / 골든 2(light)) · 셸 글자 머리 줄 더하기(Text(ShellLabels.staleBannerTitle) — 01 ×2 · 02 ×2 / 골든 4) ·
   [탭] 🔴 배너를 InkWell 로 감싸 차단 보드 열기(05).
   🔵 참고(테스트 몫 아님 · 기록만): lib 에서 .holds · SafetyHoldCodes 로 꼴 고르기 = 계약 시험 C-68 ⑧ · 정적 T11 이 잡는다(뷰 테스트는 코드 글자를 못 본다) · 중복 제거(toSet — 표본 문장이 서로 달라 테스트로 갈리지 않는다 · 정적 T10) · 시계·모드로 갈리는 판정 = 이 카드 해당 없음.
■ 정적 묶음 — 아래 30줄(조립 판 · 머리 «## T01» ~ «## T30» · T04 = lib 바뀐 파일 «정확히» 2(«40 0» · «7 0») · T05 = 지운 lib 줄 «정확히» 0 · T06 = safety.holdLabels 읽기 줄 «정확히» 2 · T07 = 배너·줄 Key 줄 «정확히» 2 · T08 = ShellHoldBanner 줄 «정확히» 3 · T09 = 정적 꼴 줄 «정확히» 3 · T10 = 더한 lib 줄의 고르기·정렬·탭·글자·링크·모드·시계 낱말 0 · T11 = lib 의 .holds · SafetyHoldCodes 0(C-68 ⑧) · T12 = 새 테스트 파일의 hold 코드 0 · 🔴 T13 · T14 · T15 = **정확히**(37 · 23 · 23) · T18 = 그 밖 패키지 파일 무변경 · T19 = 공용 fakes 더하기만 · 🔴 T27 = PNG **정확히** 100 · T29 = 전제 줄 «정확히» 3 · T30 = 공통 조각 배럴 밖)을 파일로 꺼내 Git Bash 로 돌리고, 나온 출력 전부를 제출 글 ②(저장 파일)에 코드 블록 하나로 그대로 붙인다(대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 머리 ASCII · «EXIT:1» = 출력 없음 · 출력 줄 수(EXIT 줄 포함) = 131 · EXIT:1 = 13 · EXIT:0 = 17(✅ 조립 시제품) — 붙이기 전에 세어 같은지 본다 · 다르면 아래 «줄의 뜻과 기대» 와 T 머리마다 대조해 다른 T 를 찾는다 → 코드가 이 카드 글자와 다르면 코드를 고친다(새 커밋 · 제목 «정적 Txx» · 출력을 고치지 않는다) · 코드가 이 카드 글자 그대로인데도 다르면 멈추고 그 T 머리·출력 줄을 채팅으로(카드 구멍) · 꺼내기 = 줄 번호가 아니라 머리 «## T» 줄 30개 — 카드 줄이 밀려도 같은 30줄 · 해시가 지킨다)
  🔴 터미널에 붙여 넣어 돌리지 않는다(대화형 bash 는 ! 든 줄을 건너뛸 수 있다 · bash 라고만 치면 이 PC 에서는 WSL)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 손으로 옮겨 쓰지 않는다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R16e-Bob-H01HL.md' | grep '^echo .## T[0-9][0-9] ' > ../../build/r16e_static.sh"
  git hash-object ../../build/r16e_static.sh   ← 186df4db3ae7112562430cec60746edb5d0bf2ce(= 아래 30줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r16e_static.sh > ../../build/r16e_static_out.txt"
  Select-String -Path ..\..\build\r16e_static_out.txt -Pattern '^EXIT:(?![01]$)'   ← 출력 없음이어야 한다(나오면 한 번 더 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로)
  (Get-Content ..\..\build\r16e_static_out.txt).Count   ← 131(EXIT 줄 30 포함 · ✅ 조립 시제품) · (Select-String -Path ..\..\build\r16e_static_out.txt -Pattern '^EXIT:1$').Count ← 13 · -Pattern '^EXIT:0$' ← 17
  제출 글 ② 에 붙일 출력 = ..\..\build\r16e_static_out.txt 전부(build/ 는 .gitignore 대상 — git status 는 빈 채 · 커밋 0 · 할 일의 «미리 돌리기» 도 이 꼴 · 붙이는 법 = «■ 제출» 단계 11 — 파일에서 읽어 덧붙인다)
echo "## T01 new test files hangul literal 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; echo "EXIT:$?"
echo "## T02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; echo "EXIT:$?"
echo "## T03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; echo "EXIT:$?"
echo "## T04 lib changed files (exactly 2 - shell_common 40 0, ops_home 7 0)"; git diff --numstat origin/main...HEAD -- lib; echo "EXIT:$?"
echo "## T05 lib removed lines (exactly 0)"; git diff -U0 origin/main...HEAD -- lib | grep -E "^-[^-]"; echo "EXIT:$?"
echo "## T06 hold label reads in lib (exactly 2 - ops_home)"; git grep -n "safety\.holdLabels" -- lib; echo "EXIT:$?"
echo "## T07 hold keys in lib (exactly 2)"; git grep -noE "h01-holds|hold-line-" -- lib; echo "EXIT:$?"
echo "## T08 ShellHoldBanner in lib (exactly 3)"; git grep -n "ShellHoldBanner" -- lib; echo "EXIT:$?"
echo "## T09 static look lines in shell_common (exactly 3)"; git grep -nE "Icons\.|tertiaryContainer|onTertiaryContainer" -- lib/src/common/shell_common.dart; echo "EXIT:$?"
echo "## T10 added lib lines pick sort tap text words 0"; git diff -U0 origin/main...HEAD -- lib | grep -nE "^\+[^+].*(switch|\?\?| \? |\.sort|sorted|reversed|\.where|\.map\(|\.join|\.take|\.skip|\.first|\.last|toSet|substring|split|contains|startsWith|length|InkWell|GestureDetector|onTap|onPressed|Tooltip|Semantics|AppRoutes|ShellLabels|Text\('|Colors\.|Color\(|TextStyle|FlagIds|activeFlags|breaker|runMode|operatingMode|ref\.|setState|DateTime|LIVE_AWAITING|MIGRATION)"; echo "EXIT:$?"
echo "## T11 hold codes in lib 0 (C-68 8)"; git grep -nE "\.holds\b|SafetyHoldCodes" -- lib; echo "EXIT:$?"
echo "## T12 hold codes in new test files 0"; git grep -nE "\.holds\b|SafetyHoldCodes|LIVE_AWAITING_KEYS|MIGRATION_IN_PROGRESS" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; echo "EXIT:$?"
echo "## T13 shell labels (exactly 37)"; git grep -cE "^\s*static const String " -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## T14 barrel exports (exactly 23)"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## T15 shell providers (exactly 23)"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## T16 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## T17 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## T18 frozen files in package (numstat 0 lines)"; git diff --numstat origin/main...HEAD -- . ":!lib/src/common/shell_common.dart" ":!lib/src/ops_home.dart" ":!test/shell_fakes.dart" ":!test/hold_banner_test.dart" ":!test/golden/hold_banner_golden_test.dart" ":!test/golden/goldens/hl_h01_keys_*" ":!test/golden/goldens/hl_h01_two_*"; echo "EXIT:$?"
echo "## T19 shared fakes add-only (numstat second 0)"; git diff --numstat origin/main...HEAD -- test/shell_fakes.dart; echo "EXIT:$?"
echo "## T20 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/hold_banner_test.dart; echo "EXIT:$?"
echo "## T21 H lines (hasLength - pre lines 2)"; git grep -c "hasLength(" -- test/hold_banner_test.dart; echo "EXIT:$?"
echo "## T22 fakes added non-ASCII lines (exactly 1 - section head)"; git diff -U0 origin/main...HEAD -- test/shell_fakes.dart | grep -P "^\+.*[^\x00-\x7F]"; echo "EXIT:$?"
echo "## T23 new test files non-ASCII 0 (comments included)"; git grep -nP "[^\x00-\x7F]" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; echo "EXIT:$?"
echo "## T24 implements and copyWith in new tests 0"; git grep -nE " implements |copyWith\(" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; echo "EXIT:$?"
echo "## T25 if in new test files and fakes added lines 0"; git grep -n "if (" -- test/hold_banner_test.dart test/golden/hold_banner_golden_test.dart; git diff -U0 origin/main...HEAD -- test/shell_fakes.dart | grep -n "^+.*if ("; echo "EXIT:$?"
echo "## T26 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## T27 golden PNG total (exactly 100 = 96 + hl_h01_keys 2 + hl_h01_two 2)"; git ls-files -- "test/golden/goldens/*.png" | wc -l; echo "EXIT:$?"
echo "## T28 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/hold_banner_test.dart; echo "EXIT:$?"
echo "## T29 precondition marks (pre)"; git grep -c "// pre$" -- test/hold_banner_test.dart; echo "EXIT:$?"
echo "## T30 common piece stays out of the barrel 0"; git grep -nE "ShellHoldBanner|shell_common" -- lib/ui_shell.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(✅ 조립 시제품 — 아래 수 전부 · 출력 131줄) — T01 · T02 = 0 · T03 = 2줄(이 차례 — test/golden/hold_banner_golden_test.dart:1 · test/hold_banner_test.dart:7) ·
   🔴 T04 = 2줄(이 차례 — «40 0 packages/ui_shell/lib/src/common/shell_common.dart» · «7 0 packages/ui_shell/lib/src/ops_home.dart» · 🔴 «정확히» — 다른 lib 파일 줄 0 · 수가 다르면 «■ 화면» 글자와 다르다) · 🔴 T05 = 0(출력 없음 · EXIT:1 — 지운 lib 줄 0) ·
   🔴 T06 = 2줄(ops_home.dart:140 «if (safety != null && safety.holdLabels.isNotEmpty)» · :143 «labels: safety.holdLabels,» · 🔵 줄 번호는 달라도 된다 — 이 글자 두 줄이면 통과) · 🔴 T07 = 2줄(이 차례 — shell_common.dart «hold-line-» · ops_home.dart «h01-holds») ·
   🔴 T08 = 3줄(shell_common.dart «class ShellHoldBanner extends StatelessWidget {» · «const ShellHoldBanner({super.key, required this.labels});» · ops_home.dart «ShellHoldBanner(») · 🔴 T09 = 3줄(«color: cs.tertiaryContainer,» · «Icons.pause_circle_outline,» · «color: cs.onTertiaryContainer,» — 이 차례) ·
   T10 = 0(출력 없음 · EXIT:1 — 더한 lib 줄에 고르기·정렬·자르기·합치기·탭·링크·셸 글자·색 리터럴·모드·시계 낱말 0) · T11 = 0(🔴 C-68 ⑧) · T12 = 0 · 🔴 T13 «lib/l10n/labels.dart:37»(**정확히**) · 🔴 T14 = **정확히** 23줄(무수정) · 🔴 T15 = **정확히** 23줄(무수정) · T16 · T17 = 0 ·
   T18 = 0줄 + EXIT:0(그 밖 패키지 파일 무변경 — 기존 테스트·PNG·배럴·라벨·주입·pubspec·README 포함) · 🔴 T19 = 한 줄(«<재량> 0 packages/ui_shell/test/shell_fakes.dart» — 둘째 수 0 = 필수 · 첫째 = 재량(✅ 시제품 «69 0») · C4r16c-2) ·
   T20 = 한 줄(«test/hold_banner_test.dart:6») · T21 = 한 줄(«test/hold_banner_test.dart:2» — 전제 줄의 hasLength 둘) · 🔴 T22 = 한 줄(«+// ── R16e — H-01 hold banner fakes ──» — 절 머리 밖 주석·문자열 = ASCII) · T23 · T24 · T25 = 0 ·
   T26 PNG 4줄 «A»(hl_h01_keys_dark · hl_h01_keys_light · hl_h01_two_dark · hl_h01_two_light — 그 밖 접두 줄 0 · 출력 경로 = packages/ui_shell/test/golden/goldens/… 앞머리) · 🔴 T27 «100»(**정확히**) · T28 = 0 · T29 = 한 줄(«test/hold_banner_test.dart:3» — 최소 목록 «(전제)» 수) · T30 = 0(출력 없음 · EXIT:1 — 공통 조각은 배럴 밖))
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · git diff --numstat 는 바뀐 파일이 없으면 출력 0줄 · EXIT:0 · T05 · T22 의 EXIT = grep 의 종료 코드(한 줄 나오면 0) · T25 의 EXIT = 둘째 grep 의 것(첫째가 한 줄이라도 내면 그 줄이 출력에 남는다 — 0줄이어야))
■ 골든 — 2이름 × light/dark = 4장(시계 = FixedClock(kGoldenNowUtc) · 홈 입력 = holdHomeInputs()(m8/ops_home_normal · 안내 0 · 비중 · 대조 정상 · 원장 배지) · 안전 상태만 갈림 · 흐름 없음(누르지 않는다) · 높이 확장 = 해당 없음(화면 크기 고정))
    이름            안전 상태 입력                          크기                         배너 Key            머리                     배너 아래 dy(✅ 조립 시제품 · light = dark)
    hl_h01_keys     holdRow(0)(한 줄)                       kGoldenPhoneSize 390×844     Key('h01-holds')    Key('h01-asof') dy 0.0   104.0
    hl_h01_two      holdPair(holdRow(0), holdRow(1))(두 줄) kGoldenPhoneSize 390×844     Key('h01-holds')    Key('h01-asof') dy 0.0   164.0
  hold_banner_golden — test/golden/hold_banner_golden_test.dart = 아래 글자 그대로(47줄 · 머리 주석 두 줄 ASCII · 위치 전제 둘 = 배너 아래 dy < 화면 높이 · 머리 dy == 0.0):
      ┌── 골든 테스트 복사 시작(다음 줄부터 · 47줄 · 단계 7 — 새 파일)
// test/golden/hold_banner_golden_test.dart - R16e H-01 hold banner goldens
// (2 names x light/dark = 4 PNG). ASCII only.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

void main() {
  final HoldHomeInputs inputs = holdHomeInputs();
  for (final c in <({String name, SafetyState safety})>[
    (name: 'hl_h01_keys', safety: holdRow(0)),
    (name: 'hl_h01_two', safety: holdPair(holdRow(0), holdRow(1))),
  ]) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${c.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const OpsHome(),
          brightness: b,
          wrapApp: (Widget app) => ProviderScope(
            overrides: holdHomeOverrides(
              inputs: inputs,
              safety: (int call) => one(c.safety),
              opener: RecordingLinkOpener(),
            ),
            child: app,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byKey(const Key('h01-holds'))).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('h01-asof'))).dy, 0.0);
        await expectGolden(c.name, b);
      });
    }
  }
}
      └── 골든 테스트 복사 끝(이 줄 앞까지)
  명령(packages/ui_shell): flutter test --update-goldens test/golden/hold_banner_golden_test.dart → flutter test test/golden/hold_banner_golden_test.dart(옵션 없이 · 끝 «+4: All tests passed!») → (3) 커밋 전 git status 에 새 PNG 4 · 새 골든 테스트 1 만 ?? · M 0(🔴 기존 PNG 가 M 이면 다른 화면을 건드린 것 · 멈춤).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다(기존 96장 바이트 그대로 — 정적 T18 · T26) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 · 🔵 높이·여백 재량 = 0(화면 크기 고정 · lib 글자 고정 · 배너 dy 는 기록만).
  🔴 이 네 번은 일부러 실패시키는 측정이다 — 실패 출력이 정상 · `Actual:` 줄만 읽는다 · 끝나면 `git checkout -- test/golden`.
  dy = 이름·밝기마다 직접 잰다 — 한 이름씩 --plain-name(C4r16a-4) · 커밋 0 · 끝나면 되돌린다 · PNG 를 열지 않는다:
    dy 다시 재기(packages/ui_shell 에서 · (3) 골든 커밋 뒤 · 질문 파일에 적기 전 · = 쓰기 단계 8):
    & "C:\Program Files\Git\bin\bash.exe" -c "sed -i 's/lessThan(kGoldenPhoneSize.height)/lessThan(0.0)/' test/golden/hold_banner_golden_test.dart"
    git diff --stat   ← 두 줄(먼저 파일 줄 «… test/golden/hold_banner_golden_test.dart | 2 +-» · 다음 « 1 file changed, 1 insertion(+), 1 deletion(-)» — 골든 테스트 한 줄)
    flutter test test/golden/hold_banner_golden_test.dart --plain-name "hl_h01_keys light" | Out-File -Encoding utf8 $env:TEMP\r16e_dy1.txt
    flutter test test/golden/hold_banner_golden_test.dart --plain-name "hl_h01_keys dark" | Out-File -Encoding utf8 $env:TEMP\r16e_dy2.txt
    flutter test test/golden/hold_banner_golden_test.dart --plain-name "hl_h01_two light" | Out-File -Encoding utf8 $env:TEMP\r16e_dy3.txt
    flutter test test/golden/hold_banner_golden_test.dart --plain-name "hl_h01_two dark" | Out-File -Encoding utf8 $env:TEMP\r16e_dy4.txt
       ← 🔴 한 이름씩(--plain-name) — 여러 이름을 한 번에 돌려 출력에서 고르지 않는다
    1..4 | ForEach-Object { (Select-String -Path "$env:TEMP\r16e_dy$_.txt" -Pattern 'Actual:' | Select-Object -First 1).Line.Trim() }
       ← 네 줄 «Actual: <수>»(차례 = 위 네 이름 · ✅ 조립 시제품 <104.0> · <104.0> · <164.0> · <164.0> · 잰 수를 질문 «측정:» 행 · ③ 골든 표에 옮긴다 · 🔵 옮길 때 꺾쇠 없이 — «Actual: <104.0>» 이면 «104.0»)
    git checkout -- test/golden
    git status --short   ← 🔴 비어 있어야 한다(되돌림 확인 · 커밋 0)
■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 조립 커밋이 만든 빈 표가 이미 있다 · C4r15c-4 — 행 꼴을 이 카드에 글자로 싣는다)
· H01HL_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답»(«⬜» 까지) · 답 칸 비움(병합 때 통합 담당이 갱신된 문서 절을 적는다) · 칸 안 세로 막대 금지 ·
  카드ID 칸 = «R16e-Bob-H01HL» · 행 앞 접두 = «H-01:»(🔵 예외 = 골든 dy «측정:» 행 — 접두 없이 «측정:» 으로 시작) · 파일 끝 = 표 마지막 행 뒤 줄바꿈 하나(빈 줄 0).
· 꼭 적을 것: 골든 배너 dy — 이름마다 한 행(A1~A2 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 2줄을 그대로 붙이고 <값> 자리에만 잰 수(위 «dy 다시 재기» 출력 · 꺾쇠 없이 104.0 꼴)를 넣는다(높이 = 리터럴 — 상자에 화면 높이를 실었다):
      ┌── 측정 행 복사 시작(다음 줄부터 · 2줄)
| A1 | R16e-Bob-H01HL | 추측 | 측정: hl_h01_keys 배너 아래 dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A2 | R16e-Bob-H01HL | 추측 | 측정: hl_h01_two 배너 아래 dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 844» 는 괄호 밖 · 🔴 상태 칸 «⬜ 미답» · 답 칸 비움 그대로 — 제출 때 채우지 않는다)
  더 필요해 보인 정적 라벨(🔴 만들지 말고 행으로) · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 자리(배너 층 · 블록 1 위) · Key · 파일 이름 · 공통 조각 이름·자리(shell_common · 배럴 밖) · 꼴(Card · 아이콘 · 색) · 빈 = 부재 · 탭·링크 0 · 셸 글자 0 · 주입·라벨·배럴 +0 · 가짜 꼴(holdPair) · 골든 이름·크기·위치 전제 · 엔진 생산 = 미결 220 · 다른 화면 hold 줄 = 범위 밖.
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다 · 기대 = «측정:» 이 아닌 추측 행 0(새 행 = «측정:» A1~A2 뿐) → ⑤ = «없음» 기대.
■ 제출 (= 쓰기 단계 9~12)
  (단계 9 — 할 일 (1)~(4) 커밋(단계 8 까지)이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(또는 (5)·(6)…) · flutter test 세 줄은 출력 파일로 받는다(단계 11 · 12 가 그 파일에서 읽는다 — 다른 답에서 기억으로 옮기지 않는다 · 고쳐서 다시 돌리면 세 파일도 다시 받는다))
  cd packages/ui_shell
  flutter test test/hold_banner_test.dart | Out-File -Encoding utf8 $env:TEMP\r16e_t_hl.txt; Get-Content -Encoding UTF8 $env:TEMP\r16e_t_hl.txt | Select-Object -Last 1   ← 끝 줄 그대로 — 줄 머리 시각까지(«+14: All tests passed!» · ✅ 조립 시제품 «00:01 +14: All tests passed!» · 시각은 실행마다 다름 · C4r14a-2)
  flutter test test/golden/hold_banner_golden_test.dart | Out-File -Encoding utf8 $env:TEMP\r16e_t_gold.txt; Get-Content -Encoding UTF8 $env:TEMP\r16e_t_gold.txt | Select-Object -Last 1   ← 끝 줄 그대로(«+4: All tests passed!» · ✅ 조립 시제품 «00:00 +4: All tests passed!»)
  flutter test | Out-File -Encoding utf8 $env:TEMP\r16e_t_all.txt; Get-Content -Encoding UTF8 $env:TEMP\r16e_t_all.txt | Select-Object -Last 1   ← 옵션 없이 전부 통과 — 끝 줄 그대로 — 줄 머리 시각까지(기대 = 시작 기준 N + 18 — 493 → «+511: All tests passed!» · ✅ 조립 시제품 «00:46 +511: All tests passed!» · N 이 다르면 N + 18 · 실패가 있으면 그 파일 끝 20줄을 보고 고친다)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← Git Bash 전체 경로(C4r5a-2) · 실패 0 · 🔵 main 에 원래 있는 🟡 2건(ui_journal · ui_safety 의 [C-5] 한국어 문자열 — ✅ 드라이런 실측)은 이 카드와 무관 — 그대로 둔다 · 끝 줄 «✅ 실패 항목 없음» 이면 통과
  melos.bat run format              ← 🔴 아래 네 줄은 한 줄씩 차례로 친다(PowerShell 5.1 은 && 를 모른다 · 앞 줄이 SUCCESS 일 때만 다음 줄)
  melos.bat run analyze
  melos.bat run test
  melos.bat run test:contracts      ← format · analyze · test = SUCCESS · test:contracts = 🔵 아래 check:labels 줄 · domain_contracts 끝 줄 «+669 ~30: All tests passed!»(✅ 2026-11-21 조립 시제품 «00:29 +669 ~30» · C-68 ⑧ 포함 · 수가 달라도 끝이 «All tests passed!» 면 통과 · 나온 수 그대로 적는다) · 🔴 melos.bat run test 가 5분 넘게 출력이 없으면 Ctrl+C 로 끊고
     packages/ui_shell 에서 flutter test(위 줄) + melos.bat run test:contracts 만 · test:contracts 도 5분 넘게 출력이 없으면 Ctrl+C 로 끊고 melos.bat run check:boundaries · packages/domain_contracts 에서 dart test(끝 줄 «All tests passed!») 를 하나씩(C4r16b-5) —
     끊은 사실을 ② 끝에 한 줄로 · «Some tests failed»·«FAILED» 0건 · format 0 changed(🔴 백그라운드·파이프 금지) · 🔴 domain_contracts 의 C-68 ⑧(화면 경계) 이 실패하면 lib 에 .holds · SafetyHoldCodes 가 든 것 — 그 글자를 지운다(새 커밋 · 제목 «C-68 ⑧»)
  🔵 check:labels(test:contracts 의 둘째 단계)는 main 에서 이미 🔴 — [FAIL] C-5 ① 한글 문자열 리터럴 = apps/app_operator_android/lib/**(엔진·조립 레인 몫 · 이 카드 무관 · 줄 수는 늘 바뀌므로 카드에 적지 않았다) — test:contracts 가 그 단계에서 FAILED 로 끝나면 멈추지 않는다(🔵 main 이 고쳐져 SUCCESS 로 끝나도 멈추지 않는다 — 아래 «check_labels 직접» 종료 0 · [FAIL] 0 꼴):
     ⓐ 그 출력의 [FAIL] 줄에 packages/ui_shell 경로가 0 인지 눈으로(있으면 이 카드 결함 — 고친다 · 새 커밋) ⓑ melos.bat run check:boundaries 와 packages/domain_contracts 에서 dart test(끝 줄 «All tests passed!») 를 따로 — 둘 다 통과 ⓒ apps 줄 수 = 아래 «check_labels 직접» 다섯 줄이 센다(C4r9a-2 — test:contracts 화면 출력에서 세지 않는다 · melos 를 끊었어도 이 다섯 줄은 돈다)
  check_labels 직접(저장소 뿌리 · Git Bash 경로로 · melos 를 거치지 않는다 · C4r9a-2):
     & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p build && LC_ALL=C.UTF-8 bash packages/domain_contracts/tool/check_labels.sh > build/r16e_labels.txt 2>&1"
     $LASTEXITCODE   ← 1(main 원래 🔴) · 🔵 0 이고 아래 [FAIL] 수도 0 이면 main 이 고쳐진 것 — 멈추지 않는다(② 끝 줄 = 아래 «통과» 상자) · 2 나 그 밖 값만 멈추고 build\r16e_labels.txt 전부를 채팅으로(경보 피로 방지)
     (Get-Content -Encoding UTF8 build\r16e_labels.txt | Select-String -Pattern '^\[FAIL\]' | Measure-Object).Count   ← 1(C-5 ① 한 종 · 위 종료 코드가 0 이면 0 이 정상 · 그 밖 수면 멈추고 그 파일 전부를 채팅으로)
     (Get-Content -Encoding UTF8 build\r16e_labels.txt | Select-String -SimpleMatch '/apps/' | Measure-Object).Count   ← <N>(잰 수 — 카드 숫자 없음 · 이 수를 손으로 옮기지 않는다 — 단계 11 의 바꿔 넣기 한 줄이 같은 명령으로 다시 센다)
     (Get-Content -Encoding UTF8 build\r16e_labels.txt | Select-String -SimpleMatch '/packages/ui_shell/' | Measure-Object).Count   ← 0(1 이상이면 이 카드 결함 — 고친다 · 새 커밋)
  git status --short   ← 🔴 비어 있어야 다음으로(build/ 는 .gitignore 대상)
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 10줄 · 앞머리 packages/ui_shell/ — 단 첫 줄 M docs/ai-context/inbox/H01HL_questions.md 한 줄만 저장소 뿌리 기준 · 차례 = git 정렬(docs 가 packages 앞)): M docs/ai-context/inbox/H01HL_questions.md · M lib/src/common/shell_common.dart · M lib/src/ops_home.dart · A test/golden/goldens/hl_h01_keys_dark.png · A …hl_h01_keys_light.png · A …hl_h01_two_dark.png · A …hl_h01_two_light.png · A test/golden/hold_banner_golden_test.dart · A test/hold_banner_test.dart · M test/shell_fakes.dart ·
        그 밖의 줄(특히 M lib/ui_shell.dart · M lib/l10n/labels.dart · M lib/src/shell_providers.dart · M lib/src/shell_scaffold.dart · M test/ops_home_test.dart · M test/golden/h01_golden_test.dart · M 기존 테스트 · M PNG · M pubspec.yaml · M README.md · M test/golden/README.md · apps/** · packages/domain_contracts/** · 다른 ui_* · 다른 질문 파일) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다 · 12 §3 공통 조문 — 이 카드 가짜에 공장 0 · if 0 → --factory-if 0):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번(C4r5e-5)
     dart tool/precheck.dart --base origin/main --collection-if 0 --factory-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 고칠 때마다 새 커밋((5)·(6)… · 제목 = 그 커밋 몫 + 실제 출처 낱말 — 예: «[M8] R16e (5) 사전검사 T1 else 없는 if» · 고정 제목 금지 · amend 금지 · melos.bat run format:fix 먼저 ·
        골든 커밋 뒤 lib 코드 줄을 바꿨으면 골든을 다시 돌려 통과 · 제목 끝 «· 골든 다시 돌려 통과») → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님(✅ 조립 시제품 🔴 0 · 🟡 0).
  git push -u origin ui/m8-h01-hold-banner
  ① 에 붙일 출력 — 파일로 받는다(C4r14b-5 · 화면 복사·문자열 안 "$x" 배열 0):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     git -c core.quotePath=false diff --name-status origin/main...HEAD | Out-File -Encoding utf8 $env:TEMP\r16e_ns.txt
     git log --oneline origin/main..HEAD | Out-File -Encoding utf8 $env:TEMP\r16e_log.txt
     (Get-Content -Encoding UTF8 $env:TEMP\r16e_ns.txt).Count · (Get-Content -Encoding UTF8 $env:TEMP\r16e_log.txt).Count   ← 줄 수 = git 출력 줄 수(권장대로면 바뀐 파일 10줄 · 커밋 4줄((5)… 를 만들었으면 그만큼 더) — 위 기대 목록을 세어도 10)
  cd packages/ui_shell → 위 «정적 묶음» 의 실행 꼴(파일로 꺼내 Git Bash · EXIT 확인 · 출력 = ..\..\build\r16e_static_out.txt) → cd ../..   ← ② 에 붙일 출력
  ④ 에 붙일 줄 — [Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/H01HL_questions.md | Out-File -Encoding utf8 $env:TEMP\r16e_q.txt
  N7 · N5 · N4 ⓐ 자기 대조(아래) → 다르면 고친다(새 커밋 · push 한 번 더 · ① 출력·정적 출력·사전검사 ① · ④ 줄 파일 · flutter test 세 출력 파일을 다시 받는다) → 채팅 «R16e 단계 9 끝»
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M8] H-01 hold 배너(R16e)
  🔴 제출 글 = 아래 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님) + 끝 flutter test 한 줄 — 채팅에 내지 않고 저장 파일 $env:TEMP\R16e-Bob-H01HL_submit.md 로(C4r5a-1) · **세 번 나눠 쓴다**(C4r7a-8 — 단계 10 = ① 새로 쓰기 · 단계 11 = ② 덧붙이기 · 단계 12 = ③ · ④ · ⑤ + flutter test 한 줄 덧붙이기) ·
     저장 = UTF-8 **BOM 없이** · 줄 끝 LF(C4r14b-5 · C4Q-3) — 한국어 글(머리 · 복사 상자 · 괄호 · 서술 · 골든 표)은 편집기 도구로 쓰고(«UTF-8(BOM 없음) · LF» · 새로 쓰기 / 끝에 넣기 · 🔴 편집기 도구에는 절대 경로 — 단계 10 의 $env:TEMP 출력 + \R16e-Bob-H01HL_submit.md) · 🔴 PowerShell 명령 줄에 한국어 글을 쳐 넣지 않는다(코드 페이지 깨짐 — C4O-2 · 🔵 범위 = 제출 글 저장·덧붙이기 · 검색 명령 — 커밋 제목은 «■ 할 일» 글자 그대로(한국어 포함) git commit 한다) ·
     출력 파일(① r16e_ns.txt · r16e_log.txt · ② build\r16e_static_out.txt · ④ r16e_q.txt 의 «+|» 줄)은 손으로 다시 치지 않고 이 꼴 한 줄로 파일 끝에 코드 블록째 덧붙인다(답 길이 절약 · 글자 그대로 · 저장소 뿌리에서):
       [IO.File]::AppendAllText("$env:TEMP\R16e-Bob-H01HL_submit.md", '```' + "`n" + ((Get-Content -Encoding UTF8 <출력 파일>) -join "`n") + "`n" + '```' + "`n", (New-Object Text.UTF8Encoding($false)))
       (④ 만 <출력 파일> 자리에 (Get-Content -Encoding UTF8 $env:TEMP\r16e_q.txt | Select-String -Pattern '^\+\|' | ForEach-Object { $_.Line }) · 덧붙이기 전 파일 끝이 줄바꿈 하나인지 본다 · Set-Content · Out-File · > · 화면 복사로 저장 파일을 쓰지 않는다 ·
        🔴 이 한 줄은 블록마다 **한 번만** 돈다 — 같은 출력 파일로 두 번 돌리거나 «정적 묶음 출력:» 머리 줄을 편집기로 쓸 때 빈 울타리를 함께 넣지 않는다(아래 N10)) ·
     코드 블록 울타리 = 백틱 세 개(```)뿐(🔴 네 개 이상 0 — C4Q-2) ·
     🔴 채팅 답 = 두 줄뿐(단계 12 끝): «R16e-Bob-H01HL 제출 글 저장했음: <(Resolve-Path $env:TEMP\R16e-Bob-H01HL_submit.md).Path 출력>» · 사전검사 ② 끝 줄 한 줄(hl_) · 대화 요약(Previous conversation summary)을 내지 않는다.
  PR 본문 5섹션을 저장 파일로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로 — 아래 자체 점검 상자는 10줄이지만 머리 글자는 사전검사가 정한다 · 🔴 «10항» 으로 고치면 🔴 R1):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 저장 파일 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지). (🔵 N 번호 = 이월 이름 그대로 — N2 없음 · 하는 차례 = 단계 9 에서 N7 → N5 ⓐ → N4 ⓐ · 단계 12 에서 N4 ⓑ → N5 ⓑ → N1 → N9 → N10 → N6 → N8 → N3)
      🔴 N4 — dy 자기 대조(C4r16a-4) — 기준 = «■ 골든» «dy 다시 재기» 네 출력 파일(r16e_dy1~4.txt 의 «Actual:» 줄 · 이름마다 --plain-name) · 두 번: ⓐ 단계 9 = 커밋된 질문 파일(git show HEAD:docs/ai-context/inbox/H01HL_questions.md 의 A1~A2 행) ↔ 네 값 · ⓑ 단계 12 = 저장 파일 ③ 골든 표 4행의 dy 칸 ↔ 네 값 — 이름마다 눈으로 대조 —
        하나라도 다르면 내지 말고 고친다(ⓐ 커밋된 질문 파일이 틀렸으면 새 커밋 하나로 · git push 한 번 더 · ① 출력 · 정적 출력 · 사전검사 ① · ④ 줄 파일을 다시 받는다 · ⓑ ③ 표가 틀렸으면 저장 파일의 그 칸을 고친다).
      🔴 N5 — 정적 T20 · T21 · T29 줄 대조(C4r16b-1) — ⓐ 단계 9 = 붙일 정적 출력의 T20 · T21 · T29 줄을 위 «줄의 뜻과 기대» 의 수와 대조한다(이 카드 = T20 «test/hold_banner_test.dart:6» · T21 «test/hold_banner_test.dart:2» · T29 «test/hold_banner_test.dart:3» = 최소 목록 «(전제)» 수) — 다르면 내지 말고 테스트를 고친다(출력을 고치지 않는다 · 새 커밋 · 다시 돌려 같은지 본다 · git push 한 번 더 · 다시 받는다) ·
        ⓑ 단계 12(C4r9a-1) = 저장 파일 안 T20 출력 줄 글자 수 = 2 · T21 출력 줄 글자 수 = 2(② 정적 블록의 그 줄 + ⓡ · ⓗ 둘째 줄) — 저장소 뿌리에서:
        $t20 = (Get-Content -Encoding UTF8 build\r16e_static_out.txt | Select-String -SimpleMatch '## T20 ' -Context 0,1).Context.PostContext[0]
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -SimpleMatch $t20 | Measure-Object).Count   ← 2(1 이면 ⓡ 둘째 줄이 빠졌거나 손으로 썼다 — 그 줄을 지우고 단계 11 의 ⓡ 덧붙이기 한 줄로 다시)
        $t21 = (Get-Content -Encoding UTF8 build\r16e_static_out.txt | Select-String -SimpleMatch '## T21 ' -Context 0,1).Context.PostContext[0]
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -SimpleMatch $t21 | Measure-Object).Count   ← 2(1 이면 ⓗ 둘째 줄 — 같은 꼴로 다시)
      🔴 N7 — 굵은 단언별 등장 수 대조(C4r6a-1 · C4r6b-1 · C4r6c2-2 · 굵은 단언마다 그 단언의 고유 글자로) — 저장소 뿌리에서 아래 줄들을 돌려 기대 수와 대조한다 ·
        C4r9b-2 — **기대 수 = 최소**: 나온 수가 **적으면** 내지 말고 그 경우의 단언을 더한다(새 커밋) · **많으면** 더한 단언이다 — 그대로 둔다 · 🔴 예외 = 끝 줄 «if (» 하나만 «정확히 0»(출력 없음) · 통합 담당 · C4 도 «기대 이상» 으로 대조한다 · 출력은 붙이지 않는다 · 기대 수 = ✅ 조립 시제품 실측:
     git grep -c -F "shownTexts(tester, find.byKey(const Key('h01-holds')))," -- packages/ui_shell/test/hold_banner_test.dart   ← 2(HL-01 · 02 · «배너 빼기» · «셸 글자 머리 줄»)
     git grep -c -F "<String?>[c.safety.holdLabels.first]," -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-02 · «뒤집기» · «정렬»)
     git grep -c -F "find.byKey(const ValueKey<String>('hold-line-1'))).dy," -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-02 · «첫 줄만» · «합치기»)
     git grep -c -F "greaterThanOrEqualTo(" -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-01 · «블록 1 아래로»)
     git grep -c -F "find.byKey(const Key('h01-holds')), findsNothing" -- packages/ui_shell/test/hold_banner_test.dart   ← 2(HL-03 · 07 · «빈 목록에도 배너»)
     git grep -c -F "find.byIcon(Icons.pause_circle_outline), findsNothing" -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-03)
     git grep -c -F "List<IconData?>.filled(" -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-04 · «글자로 아이콘»)
     git grep -c -F "cs.onTertiaryContainer," -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-04 · «차례로 아이콘 색»)
     git grep -c -F "cs.tertiaryContainer," -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-04 · 🔴 «줄 수로 Card 색»)
     git grep -c -F "matching: find.byType(InkWell))," -- packages/ui_shell/test/hold_banner_test.dart   ← 2(HL-05 · 🔴 «배너 탭»)
     git grep -c -F "expect(opener.opened, isEmpty);" -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-05 · 🔴 «배너 탭»)
     git grep -c -F ".difference(holdHomeAllowed(inputs, c.safety))," -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-06 · 화면 글자 ⊆ 홈 글자 + hold 문장)
     git grep -c -F "List<int>.filled(c.safety.holdLabels.length, 1)," -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-06 · 문장마다 한 번)
     git grep -c -F "find.byKey(const Key('h01-status-fail')), findsOneWidget" -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-07 · 양성 기준점)
     git grep -c -F "find.byKey(const Key('h01-status')), findsOneWidget" -- packages/ui_shell/test/hold_banner_test.dart   ← 1(HL-03 · 양성 기준점)
     git grep -c -F "// pre" -- packages/ui_shell/test/hold_banner_test.dart   ← 3(HL-01 · 02 · 03 전제 · 정적 T29 와 같은 수)
     git grep -c -F "if (" -- packages/ui_shell/test/hold_banner_test.dart packages/ui_shell/test/golden/hold_banner_golden_test.dart   ← 출력 없음(🔴 «정확히 0» · C4r8a-1 — 한 줄이라도 나오면 내지 말고 그 자리를 견본 글자로 고친다 · 새 커밋)
      🔴 N9 — ② 끝 check:labels 줄 1(C4r6c2-5) · 자리표시 0 · 잰 수 1(C4r9a-2) · «N» 글자 0(C4r8a-5) — 저장 뒤 저장소 뿌리에서:
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -SimpleMatch 'check:labels = ' | Measure-Object).Count   ← 1(0 이면 내지 말고 ② 끝에 아래 «check:labels 줄» 상자를 더한 뒤 바꿔 넣기 한 줄을 돌린다)
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -SimpleMatch '<L_APPS>' | Measure-Object).Count   ← 0(1 이면 단계 11 의 바꿔 넣기 한 줄을 돌린다)
        $n = (Get-Content -Encoding UTF8 build\r16e_labels.txt | Select-String -SimpleMatch '/apps/' | Measure-Object).Count
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -SimpleMatch "apps/** $n" | Measure-Object).Count   ← 1(0 이면 ② 끝 줄의 수가 잰 수와 다르다 — 그 수를 지우고 <L_APPS> 로 되돌린 뒤 바꿔 넣기 한 줄을 다시 돌린다 · 손으로 고치지 않는다)
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -CaseSensitive -Pattern 'apps/\*\* N' | Measure-Object).Count   ← 0(검색어 = ASCII — 명령 줄에 한국어 0)
      🔴 N10 — 빈 코드 블록 0 · 울타리 짝(C4r8a-6) — 저장 뒤:
        ([regex]::Matches([IO.File]::ReadAllText("$env:TEMP\R16e-Bob-H01HL_submit.md"), '(?m)^```\n\n?```$')).Count   ← 0(울타리 줄 바로 다음 줄이 울타리이거나 빈 줄 하나 뒤 울타리 = 빈 블록 · 1 이상이면 그 빈 블록을 지운다)
        (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -Pattern '^```$' | Measure-Object).Count   ← 10(블록 5 × 2 — ① 둘(바뀐 파일 · 커밋 목록) · ② 둘(10항 줄 수 · 정적 묶음 출력) · ④ 하나 · 홀수면 울타리가 깨졌다 — 다시 저장)
      🔴 N6 — 깨진 글자 0 자기 확인(C4O-2) — 저장 뒤 저장소 뿌리에서:
     (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -SimpleMatch '| R16e-Bob-H01HL | ' | Measure-Object).Count   ← 2(④ 의 «+|» 줄 수와 같아야 한다 · 검색어 = ASCII · 0 이면 저장 꼴이 틀림 — 멈추고 채팅으로)
     (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -Pattern '[\uFFFD\u4E00-\u9FFF]' | Measure-Object).Count   ← 0(제출 글에는 한자도 U+FFFD 도 한 글자도 없다 · 1 이상이면 저장·붙이기 꼴이 틀림 — 내지 말고 다시 저장)
      🔴 N8 — CR 0 · 울타리 백틱 세 개 자기 확인(C4Q-2 · C4Q-3):
     ([IO.File]::ReadAllText("$env:TEMP\R16e-Bob-H01HL_submit.md").Split([char]13).Count - 1)   ← 0(🔴 CR 0 · 1 이상이면 저장 꼴이 틀림 — 내지 말고 다시 저장)
     (Get-Content -Encoding UTF8 $env:TEMP\R16e-Bob-H01HL_submit.md | Select-String -Pattern '^````' | Measure-Object).Count   ← 0(🔴 백틱 네 개 이상으로 여는 울타리 0)
      🔴 N3 — 내기 전 사전검사 ② 한 번 — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일($env:TEMP\R16e-Bob-H01HL_submit.md · BOM 없이 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --factory-if 0 --report $env:TEMP\R16e-Bob-H01HL_submit.md --golden-prefix hl_ --goldens 4 | Out-File -Encoding utf8 $env:TEMP\r16e_pre2_hl.txt; Get-Content -Encoding UTF8 $env:TEMP\r16e_pre2_hl.txt | Select-Object -Last 1
        ← 🔴 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다 · R6(ⓡ ↔ T20 · ⓗ ↔ T21) · R7(check:labels 수 재실측) · R8(② 상자 뒤 빈 줄) · R9(① 블록 줄 수 · 깨진 글자)가 저절로 돈다 — 🟡 R7 · R8 이 나오면 그 줄을 고친 뒤 다시 돌린다) · 출력은 채팅에 붙이지 않는다 ·
          🔵 🟡 [G1] 은 멈춤이 아니다(✅ 드라이런 기대 = 🔴 0 · 🟡 1 — 위 «보고 규칙» 줄의 [G1] 한 항목 · 그 행은 그대로 낸다 · PNG 를 다시 열지 않는다 · 칸을 고치지 않는다) · 🟡 [G1] 이 그 밖의 행에서 **상자 수·덩어리 차례**를 다르게 읽으면 그 이름의 light PNG 를 다시 열어 표를 맞춘다(«덩어리로 셀 수 없어 대조하지 않았다» 🟡 는 그대로 · C4r5b-4) ·
          🔴 🟡 수가 카드 기대보다 많으면 늘어난 🟡 행의 light PNG 를 다시 열어 표를 맞춘다 — 다시 열지 않고 그대로 내면 반려 사유 ②(C4r5d-1).
   ① (단계 10 — 새로 쓰기) 아래 «① 머리 복사 상자» 두 줄(섹션 머리 · 화면 ID) + «바뀐 파일:» + r16e_ns.txt 코드 블록(덧붙이기 꼴) + «커밋 목록:» + r16e_log.txt 코드 블록(덧붙이기 꼴) · (0단계 계약 줄 «출력 없음» · 시작 기준이 493 이 아니면 그 까닭 한 줄을 커밋 목록 코드 블록 뒤에 — 확인한 사실만 · 모르면 `까닭 미상`) ·
      C4r6c1-2 — 저장 뒤 ① 두 코드 블록이 비지 않았고 줄 수 = r16e_ns.txt · r16e_log.txt 줄 수인지 본다(비면 내지 않는다 · 사전검사 ② R9 도 본다) → 채팅 «R16e 단계 10 끝»
      ┌── ① 머리 복사 시작(다음 줄부터 · 2줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
화면 ID: H-01 — 운영 홈 hold 배너(머리 배너 층 · 공통 조각 ShellHoldBanner)
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② (단계 11 — 덧붙이기) 섹션 머리 «## ② 자체 점검 12항 · 정적 묶음 · 명령 출력» 한 줄 + 자체 점검 10항(머리는 «12항») — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다 ·
     꼴 = «N. <prompt 글자> [x] ( )» — [x] 는 글자 뒤 · C4r6c2-6 · C4r7b-1 · C4r8a-3 — 괄호의 근거 테스트 번호 = 그 낱말을 **단언하는** 테스트와 1:1(차례 = HL-02 · 한 꼴 = HL-04 · 빈 = 부재 = HL-03 · HL-07 · 탭 0 = HL-05 · 문장만 = HL-01 · HL-06)):
      붙일 괄호(글자 그대로 · 🔴 10번 = 이 카드 범위 안):
        1번 = «정적 T16 — 허용 밖 import 0줄 · 새 import 0 · pubspec 무변경(T18)»
        2번 = «산술 0 — 판정 = 빈 목록 여부 하나(T06) · 더한 lib 줄에 정렬·뒤집기·자르기·합치기·길이 낱말 0(T10) · 차례 그대로(HL-02)»
        3번 = «DateTime.now 0 — 이 카드 시계 0(더한 lib 줄 47 · T04 · T10)»
        4번 = «손익 숫자 0 — 홈 블록 무변경 · 배너 글자 = 엔진 hold 문장만(HL-06)»
        5번 = «이 카드 범위 밖(알림 = R14) · hold 줄을 재분류·재정렬하지 않음(HL-02) · 줄 없으면 배너 없음(HL-03)»
        6번 = «이 카드 범위 밖(DND UI = M9)»
        7번 = «이 카드 범위 밖(워치독 = R14b)»
        8번 = «시크릿 입력 0 · 입력 위젯 0 · 로컬 상태 0(더한 lib 줄 setState 0 — T10)»
        9번 = «이 카드 범위 밖(온보딩 = R15)»
        10번 = «삽입 자리 무변경 — 킬스위치 자리 · 블록 1 탭 그대로 · hold 배너 = 탭 0 · 링크 0(HL-05 · T10) · hold 코드 0(T11 · C-68 ⑧)»
      ┌── 복사 시작(다음 줄부터 · 10줄)
 1. `ui_shell`이 `domain_contracts`·`flutter`·`flutter_riverpod` 외를 import하지 않는가 [x] ( )
 2. 화면 코드에 산술이 없는가 — 편차%p·진행률·경과 시간·D-day·건수 합계를 내가 만들지 않았는가 [x] ( )
 3. `DateTime.now()` 기반 카운트다운이 없는가 (신뢰 시각은 서버 값) [x] ( )
 4. 5탭에 수익률 탭이 없는가 / 홈·F-01·위젯의 손익 숫자가 0개인가 [x] ( )
 5. 알림 등급을 화면이 재분류·재정렬·재묶기하지 않는가 / 정상일 때 조용한가 [x] ( )
 6. DND UI가 P0를 끌 수 있게 보이지 않는가 [x] ( )
 7. 워치독 키·슬러그·ping URL이 화면·로그·PR 어디에도 없는가 [x] ( )
 8. 시크릿 입력을 `SecretField` 삽입으로만 처리했는가 / 자체 입력 위젯·임시 저장·확인 필드가 없는가 [x] ( )
 9. 온보딩에 «건너뛰기» 경로나 «해외주식» 항목이 없는가 / 검증 실패 문구를 의역하지 않았는가 [x] ( )
10. 🔒 삽입 자리(킬스위치·게이트·마법사)를 직접 구현하지 않았는가 / 앱 잠금 중에도 킬스위치 진입이 살아 있는가 [x] ( )
      └── 복사 끝(이 줄 앞까지 — « [x] ( )» 를 뺀 글자는 prompt_M8.md 173~182행과 같습니다)
      🔝 빈 줄 **정확히 한 줄**(C4r15c-6 · C4r9c-2 · 사전검사 ② R8 이 🟡 로 본다) — ② 복사 상자 10줄 바로 뒤에 빈 줄을 하나만 두고 아래 «10항 줄 수» 상자를 붙인다 · 저장 뒤 «10.» 줄 다음 한 줄만 빈 줄인지 본다(두 줄이면 하나 지운다).
      10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r16e_box2.txt · 편집기 도구 = 단계 10 의 절대 경로로 · UTF-8 BOM 없음)에 저장 → (Get-Content -Encoding UTF8 $env:TEMP\r16e_box2.txt).Count → 출력 한 줄을 아래 «10항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 10):
      ┌── 10항 줄 수 복사 시작(다음 줄부터 · 4줄)
10항 줄 수:
```
<출력 한 줄>
```
      └── 10항 줄 수 복사 끝(이 줄 앞까지)
      이어서(차례 그대로 · 저장소 뿌리에서):
      ⓐ «정적 묶음 출력:» 한 줄(편집기 · 🔴 그 줄 뒤에 울타리·빈 블록을 쓰지 않는다 — 블록은 다음 AppendAllText 한 줄이 짓는다 · C4r8a-6) → build\r16e_static_out.txt 전부(덧붙이기 꼴 — 코드 블록 하나 · 30줄 묶음 출력 그대로)
      ⓑ ⓡ·ⓗ(C4r9a-1 — 🔴 둘째 줄은 손으로 쓰지 않는다): 머리 «ⓡ = T20 출력:» 한 줄만 편집기로 → 둘째 줄 = 아래 명령 한 줄이 정적 출력 파일의 «## T20» 다음 줄을 꺼내 덧붙인다 → 머리 «ⓗ = T21 출력:» 한 줄만 편집기로 → 둘째 줄 = 아래 둘째 명령 한 줄(«## T21» 다음 줄)(ASCII 명령 · 출력 없음이 정상):
         [IO.File]::AppendAllText("$env:TEMP\R16e-Bob-H01HL_submit.md", ((Get-Content -Encoding UTF8 build\r16e_static_out.txt | Select-String -SimpleMatch '## T20 ' -Context 0,1).Context.PostContext[0] + "`n"), (New-Object Text.UTF8Encoding($false)))
         [IO.File]::AppendAllText("$env:TEMP\R16e-Bob-H01HL_submit.md", ((Get-Content -Encoding UTF8 build\r16e_static_out.txt | Select-String -SimpleMatch '## T21 ' -Context 0,1).Context.PostContext[0] + "`n"), (New-Object Text.UTF8Encoding($false)))
      ⓒ «테스트 파일별:» = 머리 한 줄은 편집기로 · 두 줄은 출력 파일 r16e_t_hl.txt · r16e_t_gold.txt 끝 줄을 아래 AppendAllText 한 줄로(손으로 다시 치지 않는다 · hold_banner · hold_banner_golden 순 · 줄 앞에 파일 이름·«:» 접두 0 — C4r16a-6 · 줄마다 flutter test 끝 줄 글자 그대로):
         [IO.File]::AppendAllText("$env:TEMP\R16e-Bob-H01HL_submit.md", ((Get-Content -Encoding UTF8 $env:TEMP\r16e_t_hl.txt | Select-Object -Last 1) + "`n" + (Get-Content -Encoding UTF8 $env:TEMP\r16e_t_gold.txt | Select-Object -Last 1) + "`n"), (New-Object Text.UTF8Encoding($false)))
      ⓓ ② 맨 끝 = check:labels 한 줄(🔴 필수 · C4r6c2-5) — 아래 상자 한 줄을 편집기로 **글자 그대로**(<L_APPS> 자리표시 그대로 · 숫자를 쓰지 않는다 · melos 를 끊었으면 상자 줄 끝 «통과» 뒤에 « · melos 끊음» 만 더한다) → 바꿔 넣기 한 줄(ASCII · 같은 명령으로 다시 센 수를 넣는다 · C4r9a-2):
      ┌── check:labels 줄 복사 시작(다음 줄부터 · 1줄)
check:labels = main 원래 🔴(apps/** <L_APPS>줄 · ui_shell 0줄) — Git Bash 로 check_labels.sh 를 따로 돌려 셈 · test:contracts 대신 check:boundaries · domain_contracts dart test 통과
      └── check:labels 줄 복사 끝(이 줄 앞까지)
      🔵 위 «check_labels 직접» 이 종료 0 · [FAIL] 0 이면(main 이 고쳐짐) 위 상자 대신 아래 한 줄(같은 바꿔 넣기 한 줄이 <L_APPS> 를 0 으로 바꾼다 · N9 그대로 통과):
      ┌── check:labels 통과 줄 복사 시작(다음 줄부터 · 1줄)
check:labels = 통과(apps/** <L_APPS>줄 · ui_shell 0줄) — Git Bash 로 check_labels.sh 를 따로 돌려 셈(종료 0 · [FAIL] 0 — main 이 고쳐짐)
      └── check:labels 통과 줄 복사 끝(이 줄 앞까지)
         $n = (Get-Content -Encoding UTF8 build\r16e_labels.txt | Select-String -SimpleMatch '/apps/' | Measure-Object).Count; $s = [IO.File]::ReadAllText("$env:TEMP\R16e-Bob-H01HL_submit.md", [Text.Encoding]::UTF8); [IO.File]::WriteAllText("$env:TEMP\R16e-Bob-H01HL_submit.md", $s.Replace('<L_APPS>', [string]$n), (New-Object Text.UTF8Encoding($false)))
         ← 출력 없음이 정상 · 🔴 이 한 줄 말고 그 수를 손으로 쓰거나 고치지 않는다 · 🔵 «S05 결과:» 상자 없음(위 «보고 규칙») → 채팅 «R16e 단계 11 끝»
   ③ (단계 12 — 덧붙이기) 섹션 머리 «## ③ 스크린샷 서술 · 골든 표» 한 줄 + 스크린샷 서술 2줄(= 아래 견본 2줄 · 머리와 견본이 같은 차례·줄 수 — C4r15a-1) + 골든 표 4행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «자리 표» 와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로(상태 이름을 감싼 «» · «=» 앞뒤 띄어쓰기 · «·» 까지 한 글자도 바꾸지 않는다 · 줄을 나누거나 합치지 않는다 — C4r15a-1 · «$i» = 받은 차례 순번):
      C4r16a-5 — 두 줄 모두 줄 머리가 «H-01 hold 배너 있음» 처럼 «» 로 감싼 상태 이름으로 시작하는지 내기 전에 본다:
         «H-01 hold 배너 있음» = ShellAsOfHeader(Key('h01-asof')) → ShellStaleBanner(있을 때) → ShellHoldBanner(Key('h01-holds')) → Card → Row(ValueKey<String>('hold-line-$i'))(받은 줄마다 · Icon → Text) → InkWell(Key('h01-status')) → 블록 2 ~ 9b(무변경)
         «H-01 hold 배너 없음» = ShellAsOfHeader(Key('h01-asof')) → ShellStaleBanner(있을 때) → InkWell(Key('h01-status')) → 블록 2 ~ 9b(무변경)
      골든 표 4행(한 표 · 한 행 한 줄 · 🔴 이 표 밖에 `| hl_` 로 시작하는 표 줄을 두지 않는다 — 사전검사 R3 가 골든 행으로 센다): «| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |» + 바로 다음 줄 구분 줄 «|---|---|---|---|---|---|»(없으면 표로 그려지지 않는다 · C4r5d-8) · 이름 칸 = «hl_h01_keys light» 꼴 ·
        입력 = «safety_states_holds 행 0 · m8/ops_home_normal»(keys 두 행) · «safety_states_holds 행 0 + 행 1 · m8/ops_home_normal»(two 두 행) · 주입 = «가짜 저장소 6»(네 행 모두) · 크기 = 390×844(네 행 모두) ·
        dy = 이름·밝기마다 잰 값(위 «■ 골든» «dy 다시 재기» 출력 · N4 ⓑ 자기 대조) · 배치·잘림 = 이름마다 light PNG 한 장만 연다(2장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 아이콘> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(4행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다) ·
        셈 단위 견본(C4r6b-4 — 조립 시제품 PNG 두 이름(열어 읽음) · 꼴만 본뜬다 · 🔴 내 PNG 가 견본 PNG 와 blob 같으면 그 이름 행은 꼬리까지 견본 글자 그대로 · blob 이 다르면 열어서 센다 — PNG 가 견본과 다르게 보이면 칸을 바꾸지 말고 질문 파일에 · C4r5d-1):
          hl_h01_keys light = «글자 1줄 → 상자(아이콘 1개 · 글자 2줄) → 글자 여러 줄(아이콘 5개 섞임) — 잘림: 화면 아래 끝에서 목록이 이어짐(맨 위 두 덩어리는 다 보임)»
          hl_h01_two light = «글자 1줄 → 상자(아이콘 2개 · 글자 5줄) → 글자 여러 줄(아이콘 5개 섞임) — 잘림: 화면 아래 끝에서 목록이 이어짐(맨 위 두 덩어리는 다 보임)»
          (견본 PNG blob(light · ✅ 조립 시제품) = hl_h01_keys be4740a38bfe091855d13d27ea2bf241209abc0f · hl_h01_two 7b78d8167c37ab7542ad93793268d5eeabec625d · dark = fec08e0f6ad978fdb1257fcb692be002e7f2a374 · 14eead9c1f46945cabc63587b0cdd702af889070 · 비교 = git hash-object packages/ui_shell/test/golden/goldens/<이름>_light.png · dark 행 = 같은 이름 light 행 글자 그대로 — dy 같음)
   ④ 섹션 머리 «## ④ 질문 목록» 한 줄 + r16e_q.txt 의 «+|» 로 시작하는 줄 전부(덧붙이기 꼴 · 코드 블록 하나 · 순서 그대로 · 줄머리 «+» 까지 출력 그대로 — 지우지 않는다 · C4r5d-8 · 손으로 만들지 않는다 · 기대 두 줄 = N6 첫 줄 수와 같다)
   ⑤ 섹션 머리 «## ⑤ 추측한 것 목록» 한 줄 + 추측한 것 = H01HL_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말 · 기대 = «없음»)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(끝 자리 = Get-Content -Encoding UTF8 $env:TEMP\r16e_t_all.txt | Select-Object -Last 1 로 이 단계에서 화면에 띄워 그대로 옮긴다 · 기대 M = N + 18 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄) → N4 ⓑ → N5 ⓑ → N1 · N9 · N10 · N6 · N8 · N3 → 채팅 두 줄)
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-h01-hold-banner` · 커밋 권장 4 · lib 기존 2파일에 더하기만(`common/shell_common.dart` «40 0» · `ops_home.dart` «7 0» · 새 lib 0 · 지운 줄 0) · 라벨 0 · 주입 0 · 배럴 0 · test 새 2(`hold_banner_test.dart` · `golden/hold_banner_golden_test.dart`) + `shell_fakes.dart` 끝 절 · PNG 4 · `H01HL_questions.md` A1~A2 · 🔴 기존 테스트·PNG 96·`labels.dart`·`ui_shell.dart`·`shell_providers.dart`·`domain_contracts`·조립 앱 무변경 · 🔴 «정확히 N» = 라벨 37 · 배럴 23 · 주입 23 · PNG 100.

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R16e-Bob-H01HL 결과: 브랜치 ui/m8-h01-hold-banner 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

## 5. 주의

- **5분 눈 검사**(hold 배너 몫): hold 코드 읽기(`.holds` · `SafetyHoldCodes` · `LIVE_AWAITING_KEYS` · `MIGRATION_IN_PROGRESS` — lib · 새 테스트) · 고르기(`switch` · 삼항 · `==` 로 아이콘·색 고르기 · `length` · `contains` · `startsWith`) · 차례 바꾸기(`sort` · `reversed` · `take` · `first` · `join` · `toSet`) · 탭·링크(`InkWell` · `GestureDetector` · `onTap` · `AppRoutes` · `ref.read`) · 셸 글자(`ShellLabels.` · `Text('…')`) · 빈 목록 자리표시(빈 `Card` · `SizedBox` 자리) · 색 리터럴(`Colors.` · `Color(`) · 배럴 export(`ShellHoldBanner` · `shell_common`) · 새 Provider · 기존 테스트·PNG 손대기 · `labels.dart` · `ui_shell.dart` · `shell_providers.dart` 손대기 · fakes 기존 줄 수정(T19 둘째 수) · 새 테스트 파일 ASCII 밖 글자(T23).
- 🔵 C4 눈 검사(테스트가 일부만 증명): 두 자리가 «■ 화면» 글자 그대로인지(T04 «40 0» · «7 0» · T05 0) · 배너가 블록 1 `InkWell` 밖(형제)인지 · 조각이 배럴 밖인지(T30) · 🔵 참고: 중복 제거(`toSet`)는 표본 문장이 서로 달라 테스트로 갈리지 않는다 — 정적 T10 이 잡는다 · lib 의 `.holds` 는 계약 시험 C-68 ⑧ · 정적 T11 이 잡는다.
- 🔵 C4 사람 grep(일곱 다 출력 0 이어야 · 🔴 반드시 돌린다): `git grep -nE "findsWidgets|findsAtLeast" -- packages/ui_shell/test/hold_banner_test.dart` · `git grep -nE "Function\(WidgetTester [A-Za-z_]*\)\?" -- packages/ui_shell/test/hold_banner_test.dart packages/ui_shell/test/golden/hold_banner_golden_test.dart` · `git grep -nE "isNotNull\)" -- packages/ui_shell/test/hold_banner_test.dart | grep -v "// pre$"` · `git grep -nE "^\s*tester\.takeException\(\);" -- packages/ui_shell/test/hold_banner_test.dart` · `git grep -nE "whereType<|\.forEach\(\(" -- packages/ui_shell/test/hold_banner_test.dart` · `git grep -nE "^\s+if \(" -- packages/ui_shell/test/hold_banner_test.dart packages/ui_shell/test/golden/hold_banner_golden_test.dart`(C4r8a-1) · `git grep -nE "for \(final \(String|c\.\$[0-9]" -- packages/ui_shell/test/hold_banner_test.dart`(C4r9a-9) · 🔵 fakes 끝 절 · 테스트 두 파일 = 카드 글자 그대로인지 `git diff` 로 카드 견본과 대조(C4r8a-9 · C4r6c2-10).
- 🔵 C4 검사 환경(카드 밖 · C4 워크플로 몫 · «C4 공통 체크리스트» 1~4 · C4r16c-3): 기존 worktree 꺼내 쓰기 금지 — 새로 `worktree add` · 끝에 `worktree remove` · 시작 때 자기 `dart` · `flutter_tester` PID 목록을 남기고 끝에 대조 · 변이 대본 = `if __name__ == '__main__':` 가드 · `py -3 -m py_compile` · check:labels apps 수 재실측 필수 · ② ⓡ · ⓗ 둘째 줄 ↔ 정적 블록 T20 · T21 줄 글자 대조 · 발주 글 숫자(바뀐 파일 «10줄» · PNG «4장» · 골든 rows «4» · 테스트 «+18»)는 이 카드 «드라이런:» 줄 · `git diff --name-status` 기대 줄에서 grep 한 변수로 채우고 앞 회차 숫자 잔재 0 을 assert · N7 대조 = «기대 이상»(«if (» 만 정확히 0). 반려 시 재제출 = 전체판 + 상자(R12c 조문).
- 🔴 **R16e 병합 기록 할 일(통합 담당)**: `packages/ui_shell/test/golden/README.md` 에 «🆕 R16e» 절(2이름 4장 · 크기 · 배너 dy) · `packages/ui_shell/README.md`(🔴 «정확히 N» 라벨 37 · 배럴 23 · 주입 23 · `flutter test` 511 · PNG 100) · 12 §3 R16 표 `R16e` 행 🏁 · 01 §8 미결 221 ✅(엔진 생산 = 220 ⓓ 남음) · `send/README.md` 표 · 질문 파일 A1 · A2 답 · 04 §2-4 · §4-1 에 «홈 hold 배너 = 배너 층(블록 아님)» 한 줄 · 04 §12 표 14 ⑥ 해소 표기.
- 🔵 **엔진 몫(카드 밖) · 체험 고지**: 엔진이 `holdLabels` 를 싣기 전(01 §8 미결 220 ⓓ 병합 전)에는 실기기 홈에 배너가 **보이지 않는다**(빈 = 부재 · 결함 아님) · `MIGRATION_IN_PROGRESS` 는 ds 안전 읽기 모델이 `holds` 를 이미 싣지만 짝 문장이 아직 없고, `LIVE_AWAITING_KEYS` 는 기동 게이트가 `SafetyState` 에 아직 싣지 않는다(K295) — 둘 다 220 ⓓ.
- 범위 고지: 01 §8 미결 221(이 카드 = 홈 배너 · 공통 조각) · 220(엔진 생산 — Claude) · 다른 셸 화면 · 셸 전역 슬롯 · 다른 모듈의 hold 줄 = 이 카드 밖(필요하면 통합 담당이 새 미결).
- 🔵 명세 낡은 글자(카드 «이긴다» · 우선순위로 덮음): 01 §8 221 «공통 배너»(→ 셸 공통 조각 `ShellHoldBanner` · 머리 «확인» ①) · 04 §2-4 «전역 배너 슬롯 4단»(→ 그대로 · hold 배너는 홈 본문 머리 배너 층 · 전역 슬롯 개정 0) · 04 §12 표 14 ⑥ «홈 한 줄»(→ 이 배너 · 줄 수 = 엔진 목록 길이).

## 6. R16·R16d 이월 반영 — R16d «6» 과 같은 표(M8 셸 · 🔴 이 카드 자급 — 앞 카드 견본을 가리키지 않는다)

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| R16d 꼴 전부(0~6 절 · 쓰기 단계 · 저장 파일 세 번 · N1~N10 · 사전검사 두 번 · check:labels `<L_APPS>` · ⓡ 명령 줄) | 본문 전체 · 쓰기 단계 12 답 | — |
| 🆕 ⓗ 도 명령으로(이 카드 ⓗ = 2 — 전제 줄의 hasLength) | «■ 제출» ② ⓑ 둘째 명령 · N5 ⓑ `$t21` · 사전검사 ② R6 | — |
| 🆕 견본 = 테스트 파일 전문(덩어리 A · B · 골든 · fakes) — 바꿔 쓰기 여지 0 | 규칙 10 · «■ 테스트 최소 목록» · «■ 골든» · 보고 규칙 C4r6c2-10 | — |
| 🆕 계약 시험 C-68 ⑧(ui_* lib `.holds` · `SafetyHoldCodes` 0)이 이 카드 lib 를 본다 | 범위 조문 · 규칙 2 · 정적 T11 · T12 · «■ 제출» test:contracts 줄 | ✅ 조립 시제품 domain_contracts «+669 ~30» 통과(R16d 드라이런 교훈 — 새 lib 글자가 계약 시험에 막히는지 시제품에서 먼저) |
| C4r16c-1 골든 테스트 파일 = 골든 커밋 · 고정 제목 (4) | «■ 할 일» (3) · (4) · 쓰기 단계 7 · 8 | — |
| C4r16c-2 공용 fakes numstat 첫째 = 재량 · 둘째 0 = 필수 | 정적 T19 · 규칙 1 · 최소 목록 공통 머리 | — |
| C4r9b-2 N7 «기대 수 = 최소» | «■ 제출» N7 머리 | 12 §3 공통 조문 |
| C4r9b-4 경우 이름 = 견본 글자 그대로 | 규칙 10(keys · migration · keys_then_migration · migration_then_keys · normal · blocked · two) | — |
| C4r9a-1 · -2 ⓡ · check:labels 수 = 명령 | «■ 제출» ② ⓑ · ⓓ · N5 ⓑ · N9 | (사전검사 ② R6 · R7) |
| C4r9a-5 새 테스트 파일 주석 ASCII | 규칙 10 · 15 · 정적 T22 · T23 | — |
| C4r9a-9 경우 루프 = 이름 붙은 레코드 | 규칙 10 · «5» C4 사람 grep 일곱째 | — |
| C4r8a-1 · -9 if 0 · 가짜 글자 그대로 | fakes 끝 절 글자 · 정적 T25 · N7 끝 줄 · «5» 여섯째 | — |
| C4r7a-8 · C4r7b-4 · C4r7c-5 쓰기 단계 | «■ 쓰기 단계» 12 답 · §2 7번 | — |
| C4r7b-3 발송 전 Bob 폴더 `git status` | §2 2번(Bob 폴더 = 분리 HEAD `29649223` · 0단계 `fetch --prune` + `checkout --no-track -b`) | 발송 체크리스트 |
| C4r16a-1 블록마다 shownTexts · C4r16a-4 · -5 · -6 | HL-01 · 02 shownTexts == 받은 목록 · «■ 골든» dy 네 줄 · N4 · ③ 견본 · ② ⓒ | — |
| C4r16b-1 · -5 T20 · T21 대조 · test:contracts 5분 | N5 · 규칙 12 | — |
| C4r15c-1 «부재 쪽» 양성 기준점 | HL-03 h01-status · HL-07 h01-status-fail | — |
| C4r14a-3 · -4 · C4r14b-1 · -5 · C4O-2 · C4Q-2 · C4Q-3 | 셈 단위 · 경우 이름 · 경우 for 밖 · 저장 꼴 · N6 · N8 · N10 | — |
| R16b C4O-1 전제 줄 `// pre` | HL-01 · 02 · 03 첫 줄 · 정적 T29 · N7 | — |
| 🔴 «정확히 N»(R16d 선례) | 정적 T13 «:37» · T14 23 · T15 23 · T27 100 · 머리 · 규칙 1 · «■ 정적 라벨» | R16e 병합 기록이 `ui_shell/README.md` 에 «정확히 N» 을 적는다 |
| K295 · 미결 221 · C-68 ⑧ · 04 §2-4 · §4-1 | 카드 기본값 ⓐ~ⓚ · 덮개 필수 문장 · 규칙 2~5 · «자리 표» · 정적 T10 · T11 · HL-01~07 · «이긴다» ⑧ | 엔진 생산(220 ⓓ) |
| prompt «이긴다» | 13항(④ · ⑤ · ⑬ = 해당 없음 · ⑧ = 문장 표시 · 해제 버튼 0) | 07 §7 정정 표식 후보 = 기록만 |
