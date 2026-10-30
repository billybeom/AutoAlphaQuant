# 발송 패킷 R14a-Bob-N01N02 — N-01 알림 센터 · N-02 알림 상세 (계약 v1.15 전제 · R14 2장 중 1번째 · M8)

> ⬜ **조립됨 · 🆕 계약 v1.15 실물 반영 재조립**(2026-10-30 · 앱 `rec/r14` · 글자 기준 = M2 가지 `m2/v115-r14` `d9916ca` 의 코드 — 이름·서명·픽스처 경로·`FixturePaths`·`AppRoutes`) · 🔴 **선행 1 = 계약 v1.15 보강 병합**(R14 선행 M2 — ✅ 설계 확정(01 §24 · 설계서 `10_리뷰/2026-10-30_R14선행_계약v1.15_설계서.md`) · ✅ M2 가지 검증(`domain_contracts` +408 ~30) · ⬜ PR·병합(squash `__R14V115_SQ__`) · ▶ 금지) · ⬜ 재드라이런(v1.15 가지 위 — 아래 «드라이런» 줄 · 실측 표식 자리를 채운다) · ✅ 발주자 확인 ①~⑭(2026-10-30 — 아래 «✅ 확정») · ⬜ 「푸시해」 — 셋(v1.15 병합 · 재드라이런 · 「푸시해」)이 다 풀리고 머리 첫 줄이 ▶ 일 때만 보낸다. 🔴 Bob 의 R13 브랜치(`ui/m8-s01-shell` · `ui/m8-h01-home` · 병합됨)는 건드리지 않는다.
> 만든 날 2026-10-30 · 원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 `R14-Bob-M8b` 행(378행 · ✅ 2분할 확정 — 아래 «재분할 판정») · `R14a-Bob-N01N02` 행(379행) + §3-0 사전검사 블록 + §3 공통 조문(strict 나눔 · PR 본문은 통합 담당 · 커밋 = 제목만 맞추기 · 골든 높이 = 재량 + 기록 · 재제출 = 전체판 + 상자) + 이월 부록 «R14» 대상(«R5e C4 이월 부록» C4r5e-3~7 · «R5a» C4r5a-5·7 · «R5c» C4r5c-5 · «R5d» C4r5d-5 — 아래 «6») · 화면 몫 원본 = `04_…` §5-1(등급 표시 계약) · §5-1b~d(카탈로그 — 아이콘만) · §5-2(`N-01`) · §5-3(`N-02` 블록 순서) · §5-4(ack 사다리) · §11-13 · `01_…` §2-10 `AlertItem`·`AckState` · §4-1 `AlertRepository` · §4-2 `acknowledgeAlert` · §8-10(뷰어 ALERT_ACK) · 🆕 §24(계약 v1.15 — R14 선행 · K1~K23) · §8 미결 138~148 · 🆕 설계서 §8(카드 영향 표) · 판독 메모(통합 담당 스크래치 `r14/read_memo.md` · 2026-10-29 · 앱 `origin/main` `1bb1a84` · 설계 `1650769`).
> 사전 조건 — ✅ R13 병합(R13a PR #71 `315bbbd` · R13b PR #74 `49e4329` · `ui_shell` = lib 7파일 · 라벨 31 · 배럴 export 6줄 · 셸 주입 14줄 · PNG 24) · ⬜ **선행 1 계약 v1.15**(R14 선행 M2 보강 PR · 가지 `m2/v115-r14` — 알림 센터·상세 VM · `AlertItem` +3 · `watchCenter`·`watchAlert` · `acknowledgeAlert(String alertId)` · 라우트 54 · 받침대 2 · 셸 가짜 extends · 알림 픽스처 신설 9(센터 5 · 상세 3 · 접수증 1) · 아래 이름표 · 병합 squash = `__R14V115_SQ__`) · ✅ 프롬프트 v2(`34bf60a`). 시작 기준 = 계약 v1.15 병합본의 `flutter test`(packages/ui_shell) = **⟦실측: 재드라이런 — v1.15 가지 위 · 기대 117(M2 검증 실측 · v1.15 가 `shell_fakes.dart` 의 implements 가짜 둘을 extends 로 바꿔도 수 불변)⟧** · 이 카드 끝 기대 = 시작 기준 N + **47**(뷰 37 = `alert_center_test` 24 + `alert_detail_test` 13 · 골든 10 = `n01_*` 6 + `n02_*` 4) · 끝 = ⟦실측: 재드라이런 · 기대 «+164»⟧(첫 판 «+158» → 지적 반영 «+160» → 🆕 v1.15 반영 +4 = N01-07 `rejected` · N02-04 `stale`·`stale_missing` · N02-06 `missing`).
> 🔀 **재분할 판정(12 §3 공통 임계 = 새 `testWidgets(`·`test(` 줄 > 33 · lib > +900 · 새 PNG > 16 · K35 새 원천·쓰기 창구 ≤ 5)** — 드라이런 첫 판 실측(감사 지적 — 조립 때 «세 축 경계 이상» 은 추정이었고 틀렸다): R14 를 한 장(N-01·N-02·W-01)으로 내도 줄 **28**(20 + 8) · lib **+556**(+429 + +127) · 새 PNG **16**(경계 · 넘지 않음) · 원천·쓰기 **4**(`watchCenter` · `watchAlert` · `acknowledgeAlert` · `watchWatchdog`) → **임계는 어느 축도 넘지 않는다(한 장도 된다 — R13a ⑯ 선례)** · 🆕 v1.15 반영 뒤 = 줄 29(이 카드 20 그대로 · R14b 8 → 9) · PNG·원천 불변 → 판정 불변. ✅ **2분할 확정**(발주자 결정 ①) — 까닭 = 임계 밖 셋: ⓐ Bob 대화 길이(한 장이면 «3» 본문이 두 카드 합 · 정적 66줄 · PNG 열람 8장 — 대화가 길면 멈춘다) ⓑ 계약 v1.15 의 알림 몫·워치독 몫이 서로 독립 → 먼저 풀리는 쪽부터 보낼 수 있다(R14b ①) ⓒ strict 반려 1회의 되돌림 폭이 반. 이 카드 = `N-01`·`N-02`(줄 **20**(`alert_center_test` 12 · `alert_detail_test` 6 · 골든 2) · lib ⟦실측: 재드라이런 · 첫 판 +429 · N-02 머리·모르는 id 몇 줄이 붙는다⟧ · 새 PNG **10** · 원천·쓰기 **3**(`watchCenter` · `watchAlert` · `acknowledgeAlert`)) → 다음 장 `send/_대기/R14b-Bob-W01.md`(`W-01` · 줄 9 · PNG 6 · 원천 1) · `F-01` = 엔진 레인(화면 카드 0).
> 카드 기본값(✅ 발주자 확인 ①~⑭ 로 확정 — 2026-10-30 · 아래 «✅ 확정»): ⓐ 위젯 = `AlertCenter({super.key})`(`lib/src/alerts/alert_center.dart` · `ConsumerStatefulWidget` — «P0만 보기» bool 1) · `AlertDetail({super.key, required this.alertId})`(`lib/src/alerts/alert_detail.dart` · `ConsumerWidget`) · 공용 조각 `AlertAckBlock`(`lib/src/alerts/alert_ack.dart` · 배럴 export 0 · `ConsumerStatefulWidget`) ⓑ **셸 파일은 고치지 않는다** — 알림 센터·상세의 셸 연결 = 조립 앱 레지스트리 칸(`AppRoutes.alertsInbox` · `alertDetail` · 이 카드 밖) · 셸 진입 UI(AppBar 종 아이콘·탭) = 0(⑥ · 01 §8 미결 141 · `s01_*` 재생성 0) ⓒ 원천 = `watchCenter(p0Only:)` → `AlertCenterVm`(창구 인자 재구독 — H6-1 `_holdingsOverviewProvider` 꼴) · `watchAlert(alertId)` → 🆕 `AlertDetailVm`(✅ 결정 ②(a)) · 쓰기 = `acknowledgeAlert(alertId)` 1종(셸 주입 `shellAlertCommandApiProvider` · 뷰어 = null = 버튼 부재 · 주입 타입 = `CommandApi` 전체(선례 = ui_analytics `analyticsWhatIfApiProvider`) — `confirmKillChecklist` 를 막는 것은 타입이 아니라 정적 N07) · `watchInbox` = 부르지 않는다(S-01 P0 점 몫) ⓓ 정렬·그룹·고정·접힘 = 전부 엔진(`AlertCenterVm.pinned` · `sections` · `digestLabel` — 01 §24 K10) — 화면은 받은 차례 그대로 · 펼침 = 표시 상태 bool(데이터 0) ⓔ 확인 버튼 = `ack != null && !ack.acked && 주입 non-null` 일 때만 «확인했습니다» 1개 · 누르면 `acknowledgeAlert` 1회 · 받은 접수증 `stateLabel` 한 줄(🆕 거부 접수증 `REJECTED`·`INPUT_INVALID` 도 그 글자 그대로 — N01-07 `rejected`) · 실패(예외) = 정적 «접수되지 않았습니다» · 버튼은 숨기지 않는다(데이터 `acked` 가 바뀌면 사라짐) · 확인 다이얼로그 0 · 낙관 갱신 0 · `watchCommand` 0(A-1 «내일 다시» `deferAdviceConfirm` 선례) · 기다리는 동안 버튼 `onPressed` null(두 번 누름 0 — N01-07 `pending`) · 재발행 = 조각 상태 초기화(`didUpdateWidget` — 같은 자리의 `alertId` 가 바뀌면 `_busy`·`_failed`·`_label` 을 비우고, 누른 때의 id 와 완료 때의 id 가 다르면 반영 0 · 명세 지적 — 엔진 재발행·재정렬은 정상 경로라, 앞 알림의 «접수됨» 이 다른 P0 밑에 남으면 확인 안 한 P0 를 확인한 것으로 읽는다 · N01-12) · 접수 뒤 다시 누름 = 막지 않는다(01 §24 K12 «`acknowledgeAlert` 는 `alertId` 단위 멱등 — 두 번째 확인 = `executed` 효과 0» · ⑤) ⓕ 묶음 배지 = `groupedText`(엔진 글자 · null = 부재) · 시각 = `raisedAtText`(null = 부재) · 행 탭 = `detailDeepLink`(null = 탭 없음) — `groupedCount`·`raisedAt` 미참조 ⓖ N-02 블록 = 🆕 머리(`ShellAsOfHeader` · 오래됨 `ShellStaleBanner`) → (모르는 id 면) `missingLabel` 한 줄 · (있으면) 제목 → 시각 → 무슨 일(`bodyText`) → 지금 할 조치(`actionLine`) → 근거(`deepLink` · null = 부재) → 확인 조각 · 핸드북 앵커 = 부재(01 §8 미결 139 · R16) · 사다리 단계 줄 = 부재(`ack.stateLabel` 한 줄만 · 🔴 결정 ② «넣지 않음» · 01 §8 미결 138 · 소유 = R14 뒤 셸 손질 카드 — ⑩) ⓗ 신선도 = 두 화면 각 `vm.asOf` 한 식(N-01 `AlertCenterVm` · 🆕 N-02 `AlertDetailVm` — 04 §2-3 «as-of 고지·오래됨 배너·에러의 마지막 as-of = 모든 조회 화면» · ⑪) ⓘ 새 lib 파일 3 · 공용 4(`labels.dart` R14a 절 4개 · `shell_providers.dart` 끝 절 주입 1 · 배럴 +2 · `test/shell_fakes.dart` 끝 절 — 전부 **끝 절 더하기만** · «정확히 N»(라벨·PNG 총수) = R14b 만) · Key 접두 `n01-`·`n02-`(순번만 · `alertId` 0) · 테스트 `test/alert_center_test.dart` · `test/alert_detail_test.dart` · 골든 5이름 10장(`test/golden/n01_golden_test.dart` 3이름 · `n02_golden_test.dart` 2이름 · 크기 = `kGoldenPhoneSize`(390 × 844 — 드라이런 맨 아래 dy 최대 416.0 · 확정)) ⓙ copyWith 예외 0 · implements 가짜 0(v1.15 받침대 `UnimplementedAlertRepository` · `UnimplementedCommandApi` extends) ⓚ 픽스처 = v1.15 의 `m8/alert_center_*` 5(재발행 표본 `m8/alert_center_p0_ack_reordered` 포함 — N01-12) + 🆕 `m8/alert_detail_*` 3(`full` · `no_link` · `missing`) + `m8/alert_ack_receipts_3`(🆕 3행 — REJECTED 포함) — 12 §3 원 행의 `alerts_12`·`m8/alerts_p0_ack`·`alerts_digest`·`alerts_advice_9codes` 는 **쓰지 않는다**(봉투 `ListResult<AlertItem>` = `watchInbox` 꼴 · S-01 몫 · v1.15 가 뜻을 정정했지만(K13 차례 · K14 사다리) 이 카드 입력 아님) · X7 인접 규약(04 §5-1b `ADVICE_REVOKED` 와 킬스위치 알림) = 엔진 순서로 인접(01 §24 K21 · `groupKey` 필드 0 · 화면 몫 0).
> 🔴 **카드 덮개 필수 문장(04 §5-1 · §5-2 · §5-3 · §5-4 · §11-13 · 01 §2-10 · prompt_M8 134~140)** — «등급·정렬·그룹·고정·접힘·묶음은 엔진이 끝냈다 — 화면은 받은 차례 그대로 그린다(재분류·재정렬·재그룹·건수 집계 0 · `level` 은 아이콘·색 switch 에만)» · «확인 = `acknowledgeAlert` 하나(효력 없는 수신 확인) — `confirmKillChecklist` 버튼·문구 0 · 확인 다이얼로그 0 · 버튼 숨김 0 · «읽음» 로컬 상태 0 · 뷰어 = 버튼 부재(주입 null)» · «N-02 = 머리(asOf · 오래됨 배너) · 두 문단 분리(`bodyText` / `actionLine`) · 제목 늘리기·합치기 0 · 모르는 id = `missingLabel` 한 줄(값 — 에러 화면 아님) · 링크 = 데이터(`detailDeepLink` · `deepLink` · null = 부재)» · «셸 파일·R13 테스트·PNG 는 고치지 않는다». 본문 머리 · 규칙 요약 · «프롬프트보다 이 카드가 이긴다» 에 있습니다.
> ✅ **K 결정 표식** — 새 K 0 · 관련 = 결정 7c(등급 = 엔진 한 번) · K32(픽스처 등급 5행 · 01 §8 미결 114 ✅) · K35(새 원천·쓰기 ≤ 5) · 01 §4-2(ack 두 갈래 · 2026-09-07 해소) · 🆕 01 §24 K1~K23(계약 v1.15 — K2 `AlertDetailVm` · K5 사다리 넣지 않음 · K9 이름 · K10 센터 불변식 · K12 ack 인자·멱등 · K21 `groupKey` 0).
> ✅ **확정(2026-10-30 · 발주자 · ① 2장 + F-01 이관 + v1.15 선행 · ② v1.15 에 ⑪·R14b ⑤·R14b ⑩ 포함 · R14a ⑩ 사다리 = 부재 + 01 §8 소유 카드 · ③ 나머지 권고대로)** — 이 카드 14건이 정한 것(글자 = 위 «카드 기본값» · 아래 본문): ① 2장(이 카드 `N-01`·`N-02` → `R14b-Bob-W01` `W-01`) · `F-01` FGS = 화면 카드 밖(엔진 레인 06 `M1-11`·`M1-15` · `FgsNotification` DTO 0) · 선행 = 계약 v1.15 보강 ② 이름표 = v1.15 코드(아래 «■ 계약 v1.15 이름표» · 🔵 조립 때 권고와 달라진 것 4 = `detailLink` → `detailDeepLink`(선례 `AdviceItem.detailDeepLink`) · `watchAlert` → `Stream<AlertDetailVm>` · `m8/alert_ack_receipts_2` → `_3`(REJECTED 행) · 라우트 글자 `aaq://alerts/inbox`·`aaq://alerts/detail/:alertId` — 01 §24 K9) ③ 추가형 `watchCenter({required bool p0Only})` · `watchInbox` 무변경 ④ `acknowledgeAlert(String alertId)`(와이어 `AlertAck` = 구현이 맥락을 붙인다) ⑤ 버튼 조건 = `ack != null && !ack.acked && 주입 non-null` · 접수 뒤 다시 누름 = 막지 않는다(K12 멱등) · `watchCommand` 0 ⑥ 셸 진입 UI 0(01 §8 미결 141) ⑦ 배지 = `groupedText` ⑧ 시각 = `raisedAtText` · 날짜 머리 = `headerText` · 접힌 머리 = `digestLabel` · 펼침 = 표시 상태 bool ⑨ N-01 행 = 제목·배지·시각 · 행 탭 = `detailDeepLink` ⑩ 확인 조각 자리 = 근거 버튼 뒤 · 🔴 사다리 단계 줄 = **부재**(v1.15 에 넣지 않음 · `AckState` 무변경 · 01 §8 미결 138 · 소유 = «R14 뒤 셸 손질 카드») · 핸드북 앵커 = 부재(미결 139 · R16) ⑪ 🆕 N-02 신선도·모르는 id = **v1.15 `AlertDetailVm{asOf, item?, missingLabel?}`**(머리 `ShellAsOfHeader` · 오래됨 `ShellStaleBanner` · 에러 = `lastAsOfLabel` · 모르는 id = `missingLabel` 한 줄 — 아래 «화면 2» · N02-04 · N02-06 · `n02_*` 4장 다시 · 재드라이런) ⑫ 정적 라벨 4 ⑬ 골든 5이름(`n01_p0_ack` · `n01_digest` · `n01_empty` · `n02_detail` · `n02_no_link`) · `kGoldenPhoneSize` ⑭ 이월 반영(아래 «6») · C4r13a-3 · C4r13b-4 = 통합 담당 test-only PR(R14b 병합 뒤).
> 🔵 **판독 빈틈 → v1.15 처리(01 §24 · 설계서 §2)**: G1 봉투 = `AlertCenterVm` + 추가형 `watchCenter` · G2 = `AlertSection`·`raisedAtText`·`groupedText` · G3 = 라우트 54(`alertsInbox`·`alertDetail`) · `detailDeepLink` · `watchAlert` → `AlertDetailVm` · G4 = `acknowledgeAlert(String alertId)` + 접수증 3갈래 · G5 = 표본 뜻 정정(K13 차례 · K14 «ack ⇒ P0 ∧ ≠ EXIT_URGENT») · G14 = 받침대 2 + 셸 가짜 extends · 🟡 G6 사다리 = 부재(미결 138) · G7 핸드북 앵커 = 부재(미결 139 · R16) · G8 채널 고지 = 부재(미결 140 · M9) · G9 `groupKey` 필드 0(K21) · G16 셸 스캔 빈틈(미결 144 — 이 카드 정적 묶음이 메운다) · 🔵 G17 = 1.15.0(PR 직전 재확인 · 엔진 다음 판 1.16.0) · ⛔ G15 F-01 = 엔진 레인.
> 드라이런: 🆕 ⬜ **재드라이런**(v1.15 반영 재조립 뒤 · 기준 = M2 가지 `m2/v115-r14` `d9916ca`(흉내 아님 — 실물) · 실측 표식 자리 = 시작 기준 N · 끝 N · `domain_contracts` 수 · lib 줄 · 정적 출력 줄 수 · `n02_*` dy · `n02_detail` 견본 칸 · 🟡 기대 · 변이 표(늘어난 N-02·거부 접수증 변이 포함)) ← 이전 판: ✅ 누적 드라이런 1번째(2026-10-30 · worktree `C:/Work/AAQ-claude-r14dry` · 첫 판 가지 `dry/r14-1` = `origin/main` `1bb1a84` → 기록 커밋 `5336177` ff → v1.15 흉내 `758e314`(이름표 그대로 · 비교 기준 `dry/r14-1base`) → 권장 4커밋 + (5) 주석 줄 고침 `e7cdbd9` · 🆕 지적 반영판 가지 `dry/r14-1b` = + 재발행 표본 `76cde31` + (6) `d57ce62`) · 시작 «+117» → 끝 «+158»(첫 판) → **«+160»**(반영판 · 파일별 `alert_center_test` +23 · `alert_detail_test` +10 · `n01_golden` +6 · `n02_golden` +4) · `domain_contracts` «+392 ~30» · 정적 = 아래 «정적 묶음» 머리 수 · 사전검사 ① 🔴 0 · 🟡 0 · ② 🔴 0(머리 «12항») · 🟡 6(■ 제출 N3 기대) · 골든 dy 5(light = dark) · lib +429 · 변이 72꼴 = KILLED 66(예고 전부 · 🆕 막은 3 = N01-07 `pending`·상태 글자 · N01-12) · 참고 6(동치·정적 몫 — «예고 변이» 🔵 참고).
> 프롬프트 = `docs/ai-context/prompt_M8.md`(**v2 판 183줄** · 2행 `{{범위}}` = `S-01` · 119행 «이번 과제 범위: S-01» · 128행 PR 제목 = 형식만 → 이 카드가 덮는다(«이긴다» ①⑮) · 재조립 0). 🔴 Bob **새 대화** 전제 — R13 대화를 기억하지 못합니다. 0단계·규칙 요약·본받지 않는 것·스케치·테스트 목록은 본문에 담았습니다.
> R4·R13·R5 교훈 반영(공통 교훈만): PNG 열람 = 이름마다 light 1장(5장 — 이미지 20장 한도) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 같을 때만) · 구독마다 «로딩·에러 × 갈래»(C4r3-1) · 🆕 갈래마다 배너 단언(C4r5e-3) · 흐름 = 클로저 칸(C4r3-4 · C4r5c-5 (a) = 코드 글자) · 위치 전제 = `expect` 코드 견본(C4r3-5) · 전제는 if 밖·`// pre`(C4r4b-1·2) · 커밋마다 `git add <파일>` + `git show --stat HEAD`(C4r5a-3) · 제네릭 위젯 술어 = `tester.widget<T>(find.byKey(…))` 만(`find.byType(Radio)` 류 늘 참 금지 · C4r5a-4) · 저장 파일로 받기 · 채팅 두 줄(C4r5a-1) · 정적 묶음 = 파일로 꺼내 Git Bash 전체 경로 · EXIT 0/1 밖이면 다시(C4r5a-2 · C4L-4) · 🆕 정적 머리 ASCII · `Get-Content -Encoding UTF8` · `[Console]::OutputEncoding`(C4r5e-5) · 골든 칸 셈 단위 견본 · G1 🟡 조문(C4r5d-1) · ③ 표 구분 줄 · ④ «+»(C4r5d-8) · 단언 없는 `takeException` 0(C4r5d-6) · 🆕 «자리 바꿈» 견본 = 글자 그대로 · 입력 칸 = 파일 이름만(C4r5e-7).

## 0. 한 줄 목적

`AlertCenter()` 가 `watchCenter(p0Only:)` 의 **엔진이 다 묶고 정렬한** `AlertCenterVm`(고정 P0 · 날짜 묶음 · 접힌 P2 묶음 · 빈 문장)을 받은 차례 그대로 그리고, `AlertDetail(alertId:)` 가 `watchAlert` 의 `AlertDetailVm`(머리 asOf · 한 건 또는 «모르는 id» 엔진 문장)을 «머리 → 제목 → 시각 → 무슨 일 → 지금 할 조치 → 근거» 고정 순서로 그리며, 두 화면의 «확인했습니다» 가 `acknowledgeAlert` 한 번만 부르는 `N-01`·`N-02` 를 계약 v1.15 그대로 짓기(셸 파일 무수정).

## 1. 어디에 보내나

**IBM Bob** — 작업 공간 `C:\Work\Bob\AutoAlphaQuant` · **새 브랜치 `ui/m8-n01-alerts`**(base = 최신 `origin/main` · `--no-track` · 이름 = 설계 12 §3 R14 행 그대로 · PR 제목 = «[M8] N-01·N-02 알림 센터·상세»(분할 뒤 글자 · ✅ 발주자 확인 ①)).

## 2. 보내기 전에 발주자가 할 것 🔴

1. **이 파일이 `send/` 바로 아래에 있고 머리 첫 줄이 ▶ 일 때만 보냅니다** — 지금은 ⬜(선행 1 계약 v1.15 병합 · 재드라이런 · 「푸시해」 남음 · ✅ 발주자 확인 ①~⑭).
2. Bob 에 R13 을 한 대화가 있으면 이어 쓰지 않고 **새 대화(new task)** 로 시작합니다(멈춘 대화는 **강제 중지**).
3. 패킷은 **GitHub `main`** 에서 엽니다 — <https://github.com/billybeom/AutoAlphaQuant/blob/main/docs/ai-context/send/R14a-Bob-N01N02.md> (🔴 `C:\Work\AAQ-claude\` 와 Bob 폴더의 사본은 최신이 아닐 수 있습니다 · `send/_대기/` 판은 보내지 않습니다).
4. 붙여넣을 것은 «3» 본문 **전부** — ````text 다음 줄(«R14a-Bob-N01N02 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 · 바깥 울타리 = 백틱 네 개 · 고치지 않습니다.
5. 🔴 **파일 이름 주의** — 끝난 `_완료/R13*-Bob-*.md` · 다음 장 `_대기/R14b-Bob-W01.md` 를 붙여넣지 않습니다.
6. 🔴 **받는 법(C4r5a-1 · R5 와 같은 꼴)** — Bob 은 보고 글 전문을 채팅에 내지 않고 `$env:TEMP\R14a-Bob-N01N02_submit.md`(UTF-8 · BOM 있어도 됨 — 사전검사가 견딘다)에 저장한 뒤 사전검사 ② 를 두 번(`n01` · `n02`) 돌리고, 채팅에는 두 줄(«…저장했음: <경로>» · 사전검사 ② 끝 줄 둘을 « / » 로 이은 한 줄)만 냅니다. 받은 뒤에는 아래 «4» 대로 **그 파일을 열어** 통째로 붙여 넣습니다.
7. 🔵 Bob 의 이전 창은 닫은 뒤 새 대화를 엽니다 — 그 창이 띄운 `flutter_tester` 는 창과 함께 끝납니다. 작업 관리자 등에서 `flutter_tester` 를 직접 끝내지 마세요(다른 세션 것도 있습니다 · C4r5a-9 ⑥).

## 3. 붙여넣을 본문 — ````text 다음 줄(«R14a-Bob-N01N02 — 범위»)부터 닫는 ```` 직전 줄(«(+ flutter test 한 줄 …)»)까지 그대로

---

````text
R14a-Bob-N01N02 — 범위: N-01 알림 센터(AlertCenter() — 머리 · 오래됨 · «P0만 보기» 하나 · 고정 P0 행 · 날짜 묶음 · 접힌 묶음 펼침 · 빈 문장 · 행 탭 = 상세 링크) ·
  N-02 알림 상세(AlertDetail(alertId:) — 머리 · 오래됨 · 제목 → 시각 → 무슨 일 → 지금 할 조치 → 근거 · 모르는 id = 엔진 문장 한 줄) · 공용 확인 조각(AlertAckBlock — «확인했습니다» = acknowledgeAlert 1회 · 접수증 한 줄) + 새 주입 1 + 정적 라벨 4 + 배럴 export 2줄 + 가짜 끝 절.
🔴 등급·정렬·그룹·고정·접힘·묶음은 엔진이 끝냈다 — 받은 차례 그대로(재분류·재정렬·재그룹·건수 집계 0 · level 은 아이콘·색 switch 에만 · code 로 분기 0).
🔴 확인 = acknowledgeAlert 하나 — confirmKillChecklist 0 · 확인 다이얼로그 0 · 버튼 숨김 0 · «읽음» 로컬 상태 0 · 낙관 갱신 0 · 뷰어 = 버튼 부재(주입 null).
🔴 N-02 = 머리(asOf · 오래됨 배너) · 두 문단 분리(bodyText / actionLine) · 제목 늘리기·합치기 0 · 모르는 id = missingLabel 한 줄(값 — 에러 화면 아님) · 링크 = 데이터(detailDeepLink · deepLink · null = 부재) · 링크 조립·AppRoutes 상수 0.
🔴 셸 파일(shell_scaffold · shell_router · shell_common · ops_rhythm · ops_home)·R13 테스트·PNG 는 고치지 않는다 — 셸 연결은 레지스트리 칸(조립 앱 몫 · 이 카드 밖).
하지 않는 것: W-01 워치독(R14b) · F-01 FGS(엔진 레인) · 셸 진입 UI(종 아이콘·탭) · DND·채널 고지(M9) · 사다리 단계 줄(01 §8 미결 138) · 핸드북 앵커(R16) · watchInbox · watchCommand · 조립 앱 배선 · domain_contracts·pubspec 수정 · 다른 ui_* 수정.
🔴 이 카드가 docs/ai-context/prompt_M8.md 보다 이깁니다(아래 «프롬프트보다 이 카드가 이긴다» 22항).

■ 0단계 — 대상 확인 (새 대화라면 아무것도 읽기 전에 이것부터)
이 카드는 R13a·R13b(병합됨)가 아닙니다. 앞 카드의 브랜치(ui/m6-* · ui/m7-* · ui/m8-s01-shell · ui/m8-h01-home)는 건드리지 않습니다(로컬 삭제도 안 함).
지금 코드에는 packages/ui_shell/lib/src/alerts/ 가 없습니다 — 변경 0건 커밋·«이미 돼 있다» 보고 = 실패(멈추고 알림).
  git branch --show-current     ← 지금은 ui/m8-h01-home 일 것입니다
  git status --short            ← 비어 있어야 합니다. 아니면 멈추고 출력을 채팅으로(커밋·stash·reset 금지)
  git fetch origin --prune
  git checkout --no-track -b ui/m8-n01-alerts origin/main      ← 🔴 git checkout main 금지(다른 worktree 에 체크아웃돼 있어 거부)
  git grep -c "contractVersion = '1.15.0'" -- packages/domain_contracts/lib/src/contract_version.dart                  ← «…contract_version.dart:1»(계약 v1.15 · M2 가지 m2/v115-r14 의 글자 · 🔵 G17 엔진 레인이 먼저 1.15.0 을 병합하면 이 보강이 1.16.0 으로 밀린다 — 통합 담당이 v1.15 병합 기록 때 이 줄을 main 글자로 다시 잰 뒤 보낸다)
  git grep -c "Stream<AlertCenterVm> watchCenter({required bool p0Only});" -- packages/domain_contracts/lib/src/repositories/alert_repository.dart   ← «…alert_repository.dart:1»
  git grep -c "Stream<AlertDetailVm> watchAlert(String alertId);" -- packages/domain_contracts/lib/src/repositories/alert_repository.dart         ← «…alert_repository.dart:1»(v1.15 · N-02 VM)
  git grep -c "Stream<List<AlertItem>> watchInbox({AlertLevel? min});" -- packages/domain_contracts/lib/src/repositories/alert_repository.dart     ← «…alert_repository.dart:1»(S-01 몫 · 그대로)
  git grep -c "Future<CommandReceipt> acknowledgeAlert(String alertId);" -- packages/domain_contracts/lib/src/commands/command_api.dart           ← «…command_api.dart:1»
  git grep -c "abstract class AlertCenterVm" -- packages/domain_contracts/lib/src/dto/safety.dart                                            ← «…safety.dart:1»
  git grep -c "abstract class AlertDetailVm" -- packages/domain_contracts/lib/src/dto/safety.dart                                            ← «…safety.dart:1»(v1.15 · N-02)
  git grep -c "String? digestLabel," -- packages/domain_contracts/lib/src/dto/safety.dart                                                    ← «…safety.dart:1»
  git grep -c "String? detailDeepLink," -- packages/domain_contracts/lib/src/dto/safety.dart                                                 ← «…safety.dart:1»(v1.15 · AlertItem)
  git grep -c "String? raisedAtText," -- packages/domain_contracts/lib/src/dto/safety.dart                                                   ← «…safety.dart:1»
  git grep -c "String? groupedText," -- packages/domain_contracts/lib/src/dto/safety.dart                                                    ← «…safety.dart:1»
  git grep -c "String? missingLabel," -- packages/domain_contracts/lib/src/dto/safety.dart                                                   ← «…safety.dart:1»(v1.15 · 모르는 id)
  git grep -c "class UnimplementedAlertRepository" -- packages/domain_contracts/lib/testing.dart                                             ← «…testing.dart:1»
  git grep -c "static const String m8AlertCenterP0Ack =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart                    ← «…fixture_paths.dart:1»
  git grep -c "static const String m8AlertDetailMissing =" -- packages/domain_contracts/lib/src/fixtures/fixture_paths.dart                  ← «…fixture_paths.dart:1»(v1.15)
  git grep -c "final Provider<AlertRepository> shellAlertRepositoryProvider" -- packages/ui_shell/lib/src/shell_providers.dart                ← «…shell_providers.dart:1»(R13a)
  git grep -c "final Provider<AppLinkOpener> shellLinkOpenerProvider" -- packages/ui_shell/lib/src/routing/shell_router.dart                  ← «…shell_router.dart:1»(R13a)
  git grep -c "class ShellErrorView" -- packages/ui_shell/lib/src/common/shell_common.dart                                                   ← «…shell_common.dart:1»(R13a)
  git grep -c "List<String?> shownTexts" -- packages/ui_shell/test/shell_fakes.dart                                                          ← «…shell_fakes.dart:1»(R13a 도우미)
  git grep -c "판 v2" -- docs/ai-context/prompt_M8.md                                                                                       ← «…prompt_M8.md:1»(아래 줄 번호가 이 판 기준 · 없으면 멈춤)
  ls docs/ai-context/send/R14a-Bob-N01N02.md                                ← 보여야 올바른 기준(이 카드가 main 의 send/ 에 있다)
  ls docs/ai-context/inbox/N01N02_questions.md                              ← 보여야 함(빈 표가 이미 있다)
  ls packages/domain_contracts/fixtures/m8/alert_center_p0_ack.json         ← 보여야 함(v1.15)
  ls packages/domain_contracts/fixtures/m8/alert_center_digest.json         ← 보여야 함(v1.15)
  ls packages/domain_contracts/fixtures/m8/alert_center_empty.json          ← 보여야 함(v1.15)
  ls packages/domain_contracts/fixtures/m8/alert_center_p0_only.json        ← 보여야 함(v1.15)
  ls packages/domain_contracts/fixtures/m8/alert_center_p0_ack_reordered.json  ← 보여야 함(v1.15 · 재발행 표본)
  ls packages/domain_contracts/fixtures/m8/alert_detail_full.json          ← 보여야 함(v1.15 · N-02)
  ls packages/domain_contracts/fixtures/m8/alert_detail_no_link.json       ← 보여야 함(v1.15 · N-02)
  ls packages/domain_contracts/fixtures/m8/alert_detail_missing.json       ← 보여야 함(v1.15 · N-02 모르는 id)
  ls packages/domain_contracts/fixtures/m8/alert_ack_receipts_3.json        ← 보여야 함(v1.15 · 3행)
     (🔴 한 줄에 하나 · 하나라도 «없음»·출력 없음이면 멈추고 채팅으로 — 계약 v1.15 보다 카드가 먼저 왔습니다 · && 가 안 되는 셸이면 한 줄씩)
  아래 네 줄만 반대다 — 🔴 «없음»·출력 없음이 정상(보이면 이미 들어간 것 — 멈추고 알림):
  ls packages/ui_shell/lib/src/alerts                                       ← 없어야 함
  ls packages/ui_shell/test/alert_center_test.dart                          ← 없어야 함
  git grep -c AlertCenter -- packages/ui_shell/lib                          ← 출력 없음이어야 함
  git grep -n " implements " -- packages/ui_shell/test/shell_fakes.dart     ← 출력 없음이어야 함(v1.15 가 R13 가짜 둘을 extends 로 바꿨다)
  melos.bat bootstrap
  melos.bat run build:gen   ← 🔴 필수(계약 생성물은 git 에 없다 · 브랜치를 바꾼 뒤마다) · «Can't load Kernel binary: Invalid SDK hash.» 경고는 SUCCESS 면 무시.
  cd packages/ui_shell
  flutter test   ← 시작 기준: v1.15 병합본 전부 통과 · 0 실패 · 기대 «+117: All tests passed!»(앞 시각은 달라도 된다)(끝 줄의 수를 «시작 기준 N» 으로 적어 둔다 · 다르면 멈추지 말고 PR 본문에 까닭 한 줄 —
                   그 뒤 기대는 전부 «N + …» 로 읽는다). 실패가 있으면 아무것도 고치지 말고 멈춘 뒤 출력 끝 20줄을 채팅으로.
  cd ../..
git stash list 의 옛 «WIP on …» 은 pop 하지 말고 그대로.

■ 계약 v1.15 이름표 — 이 카드가 쓰는 새 이름(0단계가 확인한 것 · 🔴 코드가 정본 — 아래와 다르면 멈추고 질문 파일에 · 글자 = M2 가지 m2/v115-r14)
  dto/safety.dart  AlertItem 에 더한 nullable 3: String? raisedAtText(표시 시각 «10:05» — 엔진) · String? groupedText(묶음 배지 «2건» — 엔진 · 묶음 1 = null) · String? detailDeepLink(N-02 링크 — 엔진이 완성 · null = 행 탭 없음)
                   AlertCenterVm({required AsOf asOf, required List<AlertItem> pinned, required List<AlertSection> sections, String? emptyLabel})
                     — pinned = P0 고정(엔진 순서 · 맨 위 · 확인됨 포함) · sections = 날짜 묶음(엔진 순서 · 최신 날 먼저) · emptyLabel = 고정·묶음이 다 빈 날의 엔진 문장(정상 = 무소식 · 행이 있으면 null)
                   AlertSection({required String headerText, required List<AlertItem> rows, String? digestLabel, required List<AlertItem> digestRows})
                     — headerText = 날짜 머리(«오늘» · «2026-08-30») · rows = 펼친 P1 행 · digestLabel non-null = 접힌 P2 묶음 머리(«P2 3건») · digestRows = 접힌 행(digestLabel null 이면 빈 목록)
                   AlertDetailVm({required AsOf asOf, AlertItem? item, String? missingLabel})
                     — 🆕 N-02 한 화면 · item non-null XOR missingLabel non-null · item = 센터의 같은 alertId 객체와 같은 값 · 모르는·지난 id = item null + missingLabel(엔진 문장 — 🔴 스트림 에러가 아니라 값)
  repositories/alert_repository.dart  Stream<AlertCenterVm> watchCenter({required bool p0Only}); · Stream<AlertDetailVm> watchAlert(String alertId);(스트림 에러 = 읽기 실패) · watchInbox 그대로
  commands/command_api.dart  Future<CommandReceipt> acknowledgeAlert(String alertId);(와이어 AlertAck 의 맥락 = 구현이 붙인다 · 구현 의무 = alertId 단위 멱등 · 모르는 id·사다리 없는 알림 = rejected INPUT_INVALID 접수증)
  testing.dart  UnimplementedAlertRepository · UnimplementedOpsStatusRepository(받침대) · UnimplementedCommandApi(기존 · acknowledgeAlert(String alertId))
  FixturePaths  m8AlertCenterP0Ack · m8AlertCenterDigest · m8AlertCenterEmpty · m8AlertCenterP0Only · m8AlertCenterP0AckReordered · m8AlertDetailFull · m8AlertDetailNoLink · m8AlertDetailMissing · m8AlertAckReceipts3(아래 «픽스처» 표)
  01 §24  acknowledgeAlert 는 alertId 단위 멱등(K12 — 이미 확인된 알림의 두 번째 확인 = executed · 효과 0 — 화면은 접수 뒤 다시 눌러도 막지 않는다) · 사다리 단계 줄 = 부재(K5 · 01 §8 미결 138)
  AppRoutes  alertsInbox = aaq://alerts/inbox · alertDetail = aaq://alerts/detail/:alertId(52 → 54 · 🔴 이 카드는 이 상수를 쓰지 않는다 — 링크는 데이터)

■ 규칙 요약 (전문 = prompt_M8.md · 우선순위 = 코드(DTO·인터페이스·testing.dart) > 이 카드(지시) > 01 §2-10·§4-1·§4-2 > 04 §5-1~§5-4 본문·그림 10·11·12 > prompt_M8.
   카드는 코드와 다를 수 없습니다 — 다르게 보이면 멈추고 질문 파일에 적은 뒤 채팅으로 · «규칙 N» = 바로 아래의 N 번 · 정본 = 이 카드의 글자)
 1 고치는 곳 = packages/ui_shell + docs/ai-context/inbox/N01N02_questions.md 만. 새 파일 = lib/src/alerts/alert_center.dart · alert_detail.dart · alert_ack.dart · test/alert_center_test.dart · test/alert_detail_test.dart ·
   test/golden/n01_golden_test.dart · test/golden/n02_golden_test.dart · 새 PNG 10.
   공용 4파일은 **끝 절 더하기만**(기존 줄 한 글자도 바꾸지 않는다 · 정적 N26 의 삭제 수 0): lib/l10n/labels.dart = ShellLabels 안 R13b 절의 마지막 상수(homeParking) 뒤 · 닫는 } 앞에 R14a 절 ·
     lib/src/shell_providers.dart = 파일 끝에 R14a 절(주입 1) · lib/ui_shell.dart = export 두 줄(자리 = 정렬 차례 — export 'src/alerts/alert_center.dart'; export 'src/alerts/alert_detail.dart'; 는 export 'l10n/labels.dart'; 바로 뒤) ·
     test/shell_fakes.dart = 파일 끝에 R14a 절.
   고치면 반려: 그 밖의 ui_shell 파일 전부(lib/src/shell_scaffold.dart · routing/shell_router.dart · common/shell_common.dart · ops_rhythm.dart · ops_home.dart · R13 테스트 · 비교기 2파일 · golden_support.dart ·
     golden README · test/ui_shell_test.dart · goldens/ 의 기존 PNG · pubspec.yaml · analysis_options.yaml · README.md) · domain_contracts/** · apps/** · 다른 ui_*.
 2 화면은 받은 글자와 null 여부만 본다 — 값 = DTO 의 title·bodyText·actionLine·raisedAtText·groupedText·headerText·digestLabel·emptyLabel·missingLabel·ack.stateLabel·접수증 stateLabel·asOf.label 원문 그대로 ·
   원값·.wire·code 표시 금지 · 폴백 문구 금지 · 색 = Theme.of(context).colorScheme(Colors.* 금지) · 한국어 리터럴 = labels.dart 의 ShellLabels 에만(테스트에도 금지) · 🔴 lib 주석에서 Key·글자를 인용할 때 작은따옴표 금지(백틱만).
 3 읽지 않는 필드(카드가 정함 — 질문 아님): AlertItem 의 raisedAt(🔴 UTC DateTime · 표시 = raisedAtText) · code(🔴 분기 0 · 아이콘 등재 전) · groupedCount(🔴 배지 = groupedText) · AckState 의 ackedAt · escalationStep(🔴 사다리 단계 글자 0) ·
   CommandReceipt 의 stateLabel 밖 전부(commandId · kind · state · requestedAt · expiresAt · nonce · issuedByDeviceId · rejectReasonCode · retryCode · retryLabel) · AsOf 의 source · tradeDate.
 4 이동 = AppLinkOpener.open(link) 하나(ref.read(shellLinkOpenerProvider) · 탭 콜백 안) — 링크 = 행 탭 item.detailDeepLink · N-02 근거 item.deepLink 둘뿐 · 🔴 lib 에 'aaq://' 리터럴 0 · AppRoutes 0 · 링크 조립·파라미터·비교 0 ·
   공개 위젯 생성자 = AlertCenter({super.key}) · AlertDetail({super.key, required this.alertId}) 둘 · AlertAckBlock 은 배럴 밖(src 안 공용).
 5 산술·판정 0 — 허용되는 것은 여섯뿐이다: ⓐ 신선도 한 식(vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc()) — N-01·N-02 화면마다 한 번) ⓑ null 여부(링크·시각·배지·머리·빈 문장·item·missingLabel·ack·접수증 글자·주입) ·
   ⓒ ack 조건 = !a.acked && api != null(a = non-null ack) ⓓ AlertLevel 3값 전수 switch(아이콘·색) ⓔ 표시 상태 bool 둘 — _p0Only(창구 인자 · 칩 선택) · _open(접힌 묶음 펼침) · 확인 조각의 _busy·_failed ·
   ⓕ 확인 조각의 alertId 같음 비교 둘(didUpdateWidget 의 oldWidget.alertId != widget.alertId · 완료 때 widget.alertId != id — 재발행 초기화 · 링크 비교 아님). 그 밖에 거르기·세기·정렬·자르기 0 ·
   목록 길이·int 를 글자로 0 · maxLines · TextOverflow · FittedBox · .trim( 0 · DateTime.now 0 · DateFormat·NumberFormat 0 · FeatureFlags·OperatingMode·RunMode 0(모드를 모른다).
 6 switch 는 열거값 전수(C-12 · default 0): AlertLevel 3값 한 곳(alert_center.dart _levelLook) — 하나뿐.
 7 시계 = shellClockProvider(주입 Clock.nowUtc() 만) · 공통 조각 = R13a 의 ShellAsOfHeader · ShellStaleBanner · ShellSkeleton · ShellErrorView 재사용(상대 경로 import · 새 공용 조각 = alert_ack.dart 하나) ·
   상태 갈래 = 아래 «상태 표» 글자 그대로(구독마다) · 스피너 금지.
 8 두 화면은 본문이다 — Scaffold·AppBar·SafeArea·Navigator 0 · 부모 높이 안 ListView(padding: EdgeInsets.zero) · Row 안 엔진 문자열은 Expanded/Flexible · 390px overflow 0 · 글꼴 200% overflow 0 · 간격·크기는 정수·N.0 만.
 9 프로바이더 — 이름·타입·파일 = 아래 «주입 구조» 글자 그대로 · autoDispose 0 · 새 주입 1(throw 기본값) · 데이터 2(family · 파일 안 private) · 탭 핸들러 안 ref.read · 데이터와 «주입 null 여부»는 build 에서 ref.watch.
10 테스트 = 받침대 extends(UnimplementedAlertRepository · UnimplementedCommandApi) · 🔴 implements 가짜 0(정적 N27) · 받은 인자 전부 기록 · 호출마다 새 Stream/Future · 가짜 공장 = 받은 call 로 삼항(C4r4b-7) · 따로 세는 변수 0 ·
   공장 안 early-return if 0 · 픽스처 = main() 머리에서 final 로 한 번 읽는다(setUpAll + late 금지 · C4r4b-6) · 🔴 전제는 expect 로 · 경우를 가르기 전(if 밖)에 둔다(C4r4b-1) — 자리 = testWidgets 본문 첫머리
     (main() 바로 아래의 expect 는 테스트 밖이라 파일 적재가 OutsideTestException 으로 실패한다) · 전제 문장마다 끝에 `// pre`(ASCII · 정적 N31 이 센다 = 최소 목록의 «(전제)» 수) · 동작은 UI 를 실제로 눌러서 ·
   🔴 자기가 주입한 값을 그대로 확인하는 테스트 금지 · 늘 참인 단언 금지 · 정상 상태 테스트는 expect(find.text(ShellLabels.retry), findsNothing) + 양성 기준점 1 · DTO 를 지어 넣지 않는다(전부 픽스처 · copyWith 0 — 정적 N28) ·
   링크는 RecordingLinkOpener 를 픽스처 값과 비교 · 가짜의 호출 기록은 목록 == 목록 · 픽스처마다 갈리는 단언은 if/else 양쪽에 또는 expect(finder, want ? findsOneWidget : findsNothing) 한 꼴 ·
   테스트 이름 = 번호 + ASCII · 새 테스트 파일의 문자열 리터럴은 전부 ASCII · «있으면 넣는다» 목록 = null-aware 원소(?x) — 🔴 collection-if 0 · else 없는 if 0(사전검사 T1·T2) ·
   🔴 반려 꼴: bool 칸 + if 로 경우 흐름 가르기 · c.name == / flow.name == 비교 · opened[0] 만 보기 · expect(a || b, isTrue) · 괄호 단언(«X 0(Y 0)» — 단언마다 따로) · 단언 없는 tester.takeException();(쓰면 expect(tester.takeException(), isNull) 꼴 · 정적 N34) ·
   제네릭 위젯 술어 = tester.widget<FilterChip>(find.byKey(…)) · tester.widget<Icon>(find.descendant(of: find.byKey(…), matching: find.byType(Icon))) 꼴만(🔴 find.byType(FilledButton) 류를 단독으로 세면 늘 참 · C4r5a-4) ·
   스켈레톤 1 = expect(find.byKey(const Key('n01-loading')), findsOneWidget) 꼴 · Key 를 단 묶음(Padding·InkWell)의 글자 = shownTexts(tester, find.byKey(…)) == 기대 목록(R13a 도우미 · 트리 순서) ·
   🔴 Key 가 Text 자체에 붙은 자리(n01-empty · n02-missing · $base-state · $base-receipt · $base-ack-fail)는 shownTexts 가 [] 를 낸다(find.descendant 는 뿌리를 세지 않는다 — 드라이런 지적) →
     그 자리는 expect(tester.widget<Text>(find.byKey(…)).data, want) 꼴만(R13a T02-04 · H-02 h02-empty 선례).
   ⓡ = 정상 상태 테스트마다 expect(find.text(ShellLabels.retry), findsNothing); 한 줄 · ⓗ = 목록 단언 루프 앞의 expect(<목록>, hasLength(n)); 한 줄 — 🔴 n = 정수 리터럴(고정 3 · 묶음 행 2 · 접힌 행 3 · P0 필터 고정 3 —
      v1.15 픽스처 표본 수 · 같은 목록에서 센 수와 맞대면 늘 참이다) · 끝 Key 도 리터럴(n01-pin-3 · n01-row-0-2 · n01-drow-1-3) — 도우미로 감싸지 않는다 · 🔴 전제에는 hasLength 를 쓰지 않는다(ⓗ 셈에 섞인다 — .single · isEmpty 꼴) ·
      정적 N17·N18 이 git grep -c 로 센다 — 🔴 아래 최소 목록의 표시 수와 정확히 같아야 한다(alert_center_test ⓡ 11 · ⓗ 4 · alert_detail_test ⓡ 5 · ⓗ 0 · 다르면 제출 전에 고친다 · 다른 채 내면 반려).
   «없는 쪽» 견본 · «화면 Text 전부» 견본 = 아래 글자 꼴(🆕 이 카드에 다 담았다 — 앞 카드를 찾지 않는다):
        final String? want = c.want;                              // 경우 칸 = 기대 글자 String?(empty = 픽스처 emptyLabel · 그 밖 = null)
        if (want != null) {
          expect(tester.widget<Text>(find.byKey(const Key('n01-empty'))).data, want);
          expect(find.byKey(const ValueKey<String>('n01-pin-0')), findsNothing);
        } else {
          expect(find.byKey(const Key('n01-empty')), findsNothing);
          expect(find.byKey(const ValueKey<String>('n01-pin-0')), findsOneWidget);   // 양성 기준점(C4r5a-7)
        }
        🔴 반려 꼴: if (want != null) { expect(…); }(else 없음) · if (x != null) { expect(x, isNotNull); … }(if 안의 전제 = 늘 참)
        «화면 Text 전부»(R13a T02-07 꼴 · allowed = 아래 alertCenterAllowed / alertDetailAllowed · 🔴 견본 뒤 ⓡ 는 테스트 끝 한 줄만 — 견본 안에 ⓡ 를 두지 않는다):
        final List<String?> shown = tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data).toList();
        expect(shown, isNotEmpty);
        for (final String? data in shown) {
          expect(data, isIn(allowed));
        }
11 골든 = 새 PNG n01_* 6장 · n02_* 4장 · --update-goldens 는 n01_golden_test.dart · n02_golden_test.dart 두 파일만(폴더 지정 금지) · 기존 PNG(s01_* · h02_* · h01_*) 재생성 0 · golden:approved 안 붙임 ·
   찍기 전 위치 전제 둘(아래 «골든» 코드 글자) · 🔴 높이(kGoldenPhoneSize 844)는 늘리지 않는다(카드 확정값) — 여백을 줄여 맞추면 «측정:» 전·후 행(12 §3 골든 높이 조문).
12 도구 = format:fix → format·analyze(--fatal-infos)·test·test:contracts SUCCESS(«Some tests failed»·«FAILED» 0건을 눈으로) · 🔴 melos.bat run test 를 백그라운드·파이프로 돌리지 않는다 ·
   패키지 테스트는 packages/ui_shell 에서 flutter test 직접 · unawaited_futures · directives_ordering · strict-raw-types·strict-inference · close_sinks · prefer_final_locals.
13 C-4 이름 함정 — 식별자 이름에 amount·price·pnl·commission·tax·cash·pct·ratio·cagr 가 (부분 문자열로도) 들고 바로 옆에 + * / 가 오면 계약 테스트가 실패한다(이 화면에는 산술이 없다).
14 모르는 것은 질문 파일에 · UI 자리표시자 글자 금지 · 실키·계좌·비밀번호 0 · PR·라벨·병합은 통합 담당.
15 정적 묶음은 git grep 이라 **주석도 센다** — lib/src/alerts/ 주석에 이 낱말을 쓰지 않는다: DateTime.now · kIsWeb · Platform. · dart:io · HoldingPnl · PerformanceSeries · afterTax · confirmKillChecklist · killSwitch ·
   CommandContext · watchInbox · watchCommand · raisedAt(단독) · groupedCount · escalationStep · ackedAt · FeatureFlags · operatingMode · runMode · AppRoutes · showDialog · AlertDialog · SnackBar · slug · secret · Colors ·
   RichText · autoDispose · Scaffold · Navigator · Clipboard · Share · print( · 추천 · 권유 · 자문 · 시그널 ·
   🆕 괄호 붙은 watchCenter( · watchAlert( · acknowledgeAlert((정적 N06 이 «3줄» 로 센다 — 주석에 쓰려면 괄호 없이 «watchCenter» · 드라이런 지적)(주석은 짧게).
🔴 보고 규칙(strict 나눔 — 12 §3 공통 조문) — ① 보고 **표기만**의 결함 = 반려 아님(통합 담당이 PR 본문 정정) ② **코드·테스트 결함**과 **거짓 주장** = **반려** ③ «예고 변이» 하나라도 통과 = **반려** · 카드 구멍 = 반려 근거 아님.
   채팅 보고에는 코드·파일·PNG 에 실제로 있는 것만 · 골든 표는 PNG 를 **열어** 대조한 뒤 «배치·잘림»만(글자는 테스트 글꼴이라 네모 · 🔴 사전검사 G1 출력을 표에 옮기지 않는다 · 🟡 를 없애려고 칸을 고치지 않는다 — C4r4b-3).
   PNG 는 이름마다 light 한 장만 연다(5장 — 이미지 20장 한도) · dark 행의 «배치·잘림» 칸 = 같은 이름 light 행 칸 글자 그대로(dy 가 light 와 같을 때만 · 다르면 그 dark PNG 도 연다).
   배치·잘림 칸 = PNG 에서 보이는 것만(글자 내용·길이 · 색·테마 이름(«밝은»·«어두운» 포함) · 코드 이름 · 픽스처 낱말 금지 · 버튼 = «버튼 글자») · 칸 끝 = «— 잘림 없음» 또는 «— 잘림: <어디가 어떻게>» ·
   셈 단위 — «글자 줄 n» = PNG 의 글자 **행** 수 · «상자» = 테두리·모서리가 보이는 덩어리 · «배경 덩어리» = 폭 전체 배경 · «막대» = 가로로 긴 덩어리 · «점» = 작은 둥근 표식 · «아이콘» = 글자 줄 안의 작은 표식 — 상자로 세지 않는다 ·
     «칩 n개» = 한 줄에 선 작은 둥근 상자(필터 칩 = 칩 1개) · 한 행 버튼 둘 = «버튼 글자 2» · 🔴 글자 줄 덩어리의 괄호 안에도 «상자» 낱말을 쓰지 않는다(사전검사 G1 은 «상자» 가 든 덩어리를 상자 하나로 센다) ·
     🆕 사전검사 G1 은 FilledButton·OutlinedButton 을 «칩 1개» 로 읽는다 — 표 칸은 이 카드 단위(«버튼 글자») 그대로 · 그 차이로 나는 🟡 = ■ 제출 N3 «드라이런 기대 🟡» 6행(그대로 · 다시 열지 않음 · 드라이런 지적).
   🔴 PR 본문은 통합 담당이 바꾼다(Bob 은 PR 을 만들지 않는다 · 제출 글은 저장 파일로) · S05 결과 줄 = 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»(사전검사 R4 · 출력 줄 수만큼) · 수는 손으로 세지 않고 명령 출력을 붙인다 ·
   자체 점검 ② = «■ 제출» ② 의 복사 상자(= prompt_M8.md 173~182행 10항) 그대로 + [x] 와 괄호만([—] 금지) · ③ = 위젯·Key 이름 나열(요약어 금지) · 질문 파일에 추측 행으로 카드 이행 내역을 적지 않는다(dy «측정:» 행은 예외).

■ 프롬프트보다 이 카드가 이긴다 — 22항 (prompt_M8.md 183줄 판 v2 · 2026-10-26 재조립)
 ① 2행 {{범위}} = S-01 · 119행 «이번 과제 범위: S-01» → 이 카드의 범위 = N-01 · N-02(위 첫 줄)
 ② 113~118행 역할·범위(M8 전 화면 나열) → 이 카드 = N-01·N-02 · W-01 = R14b(다음 장) · F-01 = 엔진 레인(06 M1-15 · 화면 카드 0) · S-01·S-02·H-01·H-02 = R13(병합됨) · H-03·D-*·B-*·O-* = R15~R16
 ③ 12~13행 «의존 셋뿐 · 추가하려면 먼저 질문» → 추가 0 · pubspec 무변경
 ④ 15~19행 «링크는 데이터 · null = 부재 · 라우터·플랫폼 가드 = 셸» → 그대로 유효 — 상수 진입 0(행 탭 = detailDeepLink · 근거 = deepLink)
 ⑤ 20~23행 DateTime.now 금지 · 신선도 = 주입 Clock + asOf → 그대로 유효(N-01·N-02 각 한 식 · 행 시각 = raisedAtText)
 ⑥ 25~31행 «산술·건수 집계 · 거르기·묶기·재정렬 금지» → 그대로 유효 · 예외 = 규칙 5 의 여섯 · «P0만 보기» = 창구 인자(받은 목록을 거르지 않는다)
 ⑦ 32~35행 «한국어 리터럴 = labels.dart 한 파일» → 그대로 유효(ShellLabels R14a 절 4개)
 ⑧ 36~38행 «아무 일 없음 문장 금지 · 오지 않으면 그리지 않는다» → 그대로 유효(빈 문장 = emptyLabel · 정상 = 무소식)
 ⑨ 39~40행 손익 0(C-6) → 그대로 유효(HoldingPnl·PerformanceSeries·afterTax 0 · 알림 본문 수량·가격 = 엔진 몫)
 ⑩ 41~47행 안전 화면 금지 · 목적지 이름 정본 = AppRoutes.all → 그대로 유효 — 🔴 confirmKillChecklist 0(04 §5-4 · §11-13 — 그리면 반려)
 ⑪ 48~57행 «■ 모드 — 접두·띠는 셸 한 곳 · 띠 높이를 예약하지 마십시오» → 그대로 유효(본문은 띠를 모른다)
 ⑫ 58~66행 X7 → 안내 알림도 등급·묶음 = 엔진 · 이 화면의 몫 = 받은 행을 그대로
 ⑬ 82~86행 데이터 규칙 → 그대로 유효(copyWith 0)
 ⑭ 87~105행 «■ 제출» → 그대로 유효 · 글자·명령·사전검사 인자 = 아래 «■ 제출»(제출 글 = 저장 파일 · 채팅 두 줄)
 ⑮ 127~128행 브랜치 ui/m8-<화면ID소문자>… · PR 제목 형식 → 브랜치 ui/m8-n01-alerts · 제목 «[M8] N-01·N-02 알림 센터·상세»
 ⑯ 106~111행 «모르는 것 = 질문 파일 · TODO 자리표시자 0» → 그대로 유효(질문 파일 = inbox/N01N02_questions.md)
 ⑰ 120~126행 읽을 문서 5 → 아래 «먼저 읽을 것»
 ⑱ 134~137행 등급 재분류·재정렬·자체 묶기 금지 · 정상 = 무소식 · DND → 그대로 유효 · DND UI = 이 카드 밖(M9)
 ⑲ 138~140행 «뷰모델의 액션 목록에 그 항목이 있을 때만 버튼» → 계약에 액션 목록 0 → 이 카드: ack != null && !ack.acked && 주입 non-null 일 때만 «확인했습니다» 1개 · «읽음 처리» 로컬 상태 0 그대로
 ⑳ 141~144행 워치독 → 이 카드 범위 밖(R14b)
 ㉑ 165행 «안내 알림 9종» → 04 §5-1b 11종 · 이름표만 다르다(화면 몫 = 등급·코드로 분기 0 — 같다)
 ㉒ 172~182행 자체 점검 10항 → «■ 제출» ② 복사 상자 + 괄호(🆕 괄호 글자 = ■ 제출 ② «붙일 괄호» 가 정본 · 범위 밖도 [x] · 섹션 머리는 «12항» 그대로 — 사전검사 R1)

■ 먼저 읽을 것 (🔴 02·03·05 명세는 읽지 않음 — 모듈 명세 1부 규칙)
 ① prompt_M8.md 전문 ② 04 §5-1(표 · 사적 재분류 금지) · §5-1b~d(카탈로그 — 🔵 화면이 code 로 하는 일 = 0) · §5-2(N-01 · 그림 10) · §5-3(N-02 · 그림 11) · §5-4(사다리 · 그림 12 · ADVICE_EXIT_URGENT 문단) · §11 13번
    (🔵 등급 정본표 = 엔진 06_시스템설계/04_안전장치.md §5-3 — 앱 04 의 «§5-3» 은 N-02 상세 절이다 · 헷갈리지 않는다 · 화면은 그 표를 읽지 않는다 = level 만)
 ③ 01 §2-10 AlertItem·AckState · §4-1 AlertRepository · §4-2 acknowledgeAlert · §8-10(뷰어 ALERT_ACK) · §24(계약 v1.15 — R14 선행 · 24-3 코드 · 24-6 결정 K1~K23) · §8 미결 138~148
 ④ packages/domain_contracts/lib/ — src/dto/safety.dart(AlertItem · AckState · AlertCenterVm · AlertSection · AlertDetailVm) · src/enums/safety.dart(AlertLevel) · src/repositories/alert_repository.dart · src/commands/command_api.dart(acknowledgeAlert) ·
    src/commands/command_receipt.dart · src/primitives/as_of.dart · testing.dart(UnimplementedAlertRepository · UnimplementedCommandApi · RecordingLinkOpener)
 ⑤ packages/ui_shell — lib 전부(R13 병합본 · 읽기만) · test/shell_fakes.dart · test/ops_rhythm_test.dart · test/golden/h02_golden_test.dart(꼴) · test/golden/golden_support.dart · test/golden/README.md «🆕 R13»·«🆕 R14» 절
 ⑥ packages/domain_contracts/fixtures/README.md(m8 행) ⑦ tool/check_boundaries.sh [5] ⑧ docs/ai-context/inbox/README.md · N01N02_questions.md 머리말
 ⑨ 꼴 선례(읽기만): packages/ui_journal/lib/src/holdings_overview.dart(bool family 재구독) · packages/ui_journal/lib/src/advice_inbox.dart 의 _defer(명령 1회 · 접수증 글자 · 실패 글자)

■ 본받지 않는 것
 · 셸 파일(shell_scaffold.dart)에 종 아이콘·알림 탭을 더하는 것 — 셸 진입 UI = 이 카드 밖(✅ 발주자 확인 ⑥ · 01 §8 미결 141) · s01_* 골든을 다시 찍게 된다
 · S-01 P0 점의 watchInbox · shell_fakes 의 FakeShellAlertRepository·alertsOf 를 고치거나 쓰는 것 — 알림 센터 원천은 watchCenter 하나(새 가짜 = 끝 절)
 · alerts_12 · m8/alerts_p0_ack · alerts_digest · alerts_advice_9codes(봉투 = watchInbox 꼴)를 읽는 것 — 이 카드 입력 = v1.15 m8/alert_center_* 5 + m8/alert_detail_* 3 + 접수증 1
 · level 로 정렬하거나 P0 를 화면이 위로 올리는 것 · raisedAt 으로 날짜 머리를 짓는 것 · digestRows 를 세어 «P2 3건» 을 짓는 것 · groupedCount 를 글자로 그리는 것 · code 로 아이콘·문구를 고르는 것
 · ack 를 누른 뒤 행을 숨기거나 acked 처럼 그리는 것(낙관 갱신) · 확인 다이얼로그 · SnackBar · 두 번 묻기 · watchCommand 구독 · «읽음» bool
 · 모르는 id 를 에러 화면(ShellErrorView)·스켈레톤으로 그리는 것 — 값이다(missingLabel 한 줄 · 01 §24 K2) · 거부 접수증(REJECTED)을 실패 글자로 바꾸는 것(접수증 stateLabel 그대로)
 · ui_journal 의 위젯을 import 하는 것(ui_shell 은 ui_journal 을 의존하지 못한다) · implements 가짜 · 한국어 테스트 이름 · 조건부 단언 · lib 의 nullable 에 !(null 검사 뒤 지역 변수로)

■ 주입 구조 (이름·타입·파일 고정 — 카드 기본값 · Key 접두 n01- · n02-)
· 🆕 lib 파일 3개 = lib/src/alerts/
    alert_center.dart — AlertCenter(공개 · ConsumerStatefulWidget) · _AlertCenterState(bool _p0Only = false) · _centerProvider · _SectionBlock · _DigestBlock(StatefulWidget · bool _open = false) · _AlertTile · _levelLook
    alert_detail.dart — AlertDetail(공개 · ConsumerWidget · final String alertId) · _alertDetailProvider
    alert_ack.dart — AlertAckBlock(ConsumerStatefulWidget · 배럴 export 0 · 두 화면이 상대 경로로 import) · _AlertAckBlockState(bool _busy · bool _failed · String? _label · 🆕 didUpdateWidget = 재발행 초기화)
  import 차례(directives_ordering) = 'dart:async'(alert_ack.dart 만 — unawaited) → package:domain_contracts/domain_contracts.dart → package:flutter/material.dart → package:flutter_riverpod/flutter_riverpod.dart →
    ../../l10n/labels.dart → ../common/shell_common.dart → ../routing/shell_router.dart → ../shell_providers.dart → alert_ack.dart(안 쓰는 import 는 뺀다 — analyze 가 정본)
· 🆕 shell_providers.dart 끝 절(R13 절과 같은 꼴 · 왼쪽 타입 · 줄 나눔은 dart format 그대로 · 정적 N12 가 이 꼴로 센다):
    // ── R14a — N-01·N-02 injection providers ──…
    final Provider<CommandApi?> shellAlertCommandApiProvider = Provider<CommandApi?>((Ref ref) => throw UnimplementedError('shellAlertCommandApiProvider must be overridden'));
      (뷰어 조립 = overrideWithValue(null) → 확인 버튼 부재 · operator 조립 = 실제 CommandApi · 꼴 선례 = ui_analytics analyticsWhatIfApiProvider)
· 데이터 2(파일 안 private · autoDispose 0 · family 꼴 = H6-1 _holdingsOverviewProvider):
    final StreamProviderFamily<AlertCenterVm, bool> _centerProvider = StreamProvider.family<AlertCenterVm, bool>((Ref ref, bool p0Only) => ref.watch(shellAlertRepositoryProvider).watchCenter(p0Only: p0Only));
    final StreamProviderFamily<AlertDetailVm, String> _alertDetailProvider = StreamProvider.family<AlertDetailVm, String>((Ref ref, String alertId) => ref.watch(shellAlertRepositoryProvider).watchAlert(alertId));
· 🆕 배럴 lib/ui_shell.dart 에 export 두 줄 — export 'src/alerts/alert_center.dart'; · export 'src/alerts/alert_detail.dart';(자리 = export 'l10n/labels.dart'; 바로 뒤 · 정렬 차례 · 삭제 0)
· 조립 앱(이 카드 밖 · 참고만): ShellRouteBodies 의 AppRoutes.alertsInbox 칸 = (_) => const AlertCenter() · alertDetail 칸 = 경로의 :alertId 로 AlertDetail(alertId: …) · overrides = shellAlertCommandApiProvider.

■ 호출 표 (부르는 것 · 부르지 않는 것)
 AlertCenter — 부르는 것: watchCenter(p0Only: false) 한 번 · 칩을 켜면 watchCenter(p0Only: true) 한 번(🔵 끄면 앞 구독이 살아 있어 다시 부르지 않는다 — autoDispose 0) · 재시도 = 지금 인자로 한 번 더 · shellClockProvider · shellLinkOpenerProvider(행 탭 콜백 안).
 AlertDetail — 부르는 것: watchAlert(alertId)(받은 id 그대로 · 재시도 = 한 번 더) · shellClockProvider(🆕 신선도) · shellLinkOpenerProvider(근거 탭 콜백 안).
 AlertAckBlock — 부르는 것: acknowledgeAlert(alertId)(버튼 한 번에 한 번 · 결과 기다리는 동안 버튼 onPressed null) · shellAlertCommandApiProvider(build 에서 watch — null 여부).
 셋 다 부르지 않는 것: watchInbox · watchCommand · confirmKillChecklist · CommandApi 의 그 밖 전부 · SettingsActions · AppRoutes.isRegistered · OpsStatusRepository · SafetyRepository.

■ 상태 표 (구독마다 — C4r3-1 · 꼴 = R13a OpsRhythm: hasError 가 먼저 · 값 뒤 에러 = 에러 화면 + 마지막 asOf 글자)
 center   hasError → ShellErrorView(key: const Key('n01-fail'), onRetry: () => ref.invalidate(_centerProvider(_p0Only)), lastAsOfLabel: center.valueOrNull?.asOf.label) ·
          값 전 → ShellSkeleton(key: const Key('n01-loading')) · 값 → 아래 «화면 1»(빈 문장도 같은 목록 안 — 갈래 1)
 detail   hasError → ShellErrorView(key: const Key('n02-fail'), onRetry: () => ref.invalidate(_alertDetailProvider(alertId)), lastAsOfLabel: detail.valueOrNull?.asOf.label)(ConsumerWidget 이라 widget. 0 · 🆕 v1.15 AlertDetailVm 에 asOf) ·
          값 전 → ShellSkeleton(key: const Key('n02-loading')) · 값 → «화면 2»(🆕 모르는 id 도 값 — 같은 갈래 · 에러 아님)
 ack      버튼 누름 → _busy = true(버튼 onPressed null) → acknowledgeAlert 완료 → _busy = false · _failed = false · _label = 접수증 stateLabel → 실패(예외) → _busy = false · _failed = true · _label = null
          (🔴 mounted 확인 뒤 setState · 버튼은 그대로 — 사라지는 것은 데이터 ack.acked 가 true 로 다시 올 때뿐)
          🆕 재발행(같은 자리에 다른 alertId) → didUpdateWidget 에서 _busy = false · _failed = false · _label = null(setState 0 — build 가 뒤따른다) · 완료가 늦게 와도 누른 id ≠ 지금 id 면 반영 0
 🆕 04 §2-3 공통 상태 6종 중 ⑤ 차단 = 셸 §2-4 배너 슬롯 몫(본문 0) · ⑥ 부분 동기 = 계약 필드 0 → 부재(01 §8 미결 148) — 두 화면 다(R13a «부분 동기 = 이 카드 밖» 선례 · 명세 지적).
 🔴 갈래를 고르는 것은 AsyncValue · null 여부 · 규칙 5 의 식 · AlertLevel switch 뿐.

■ 화면 1 — N-01 (lib/src/alerts/alert_center.dart · 위 → 아래 · 🔴 이 순서 · 묶음 Key = Padding/InkWell · 묶음 안 Text 에는 Key 를 달지 않는다(n01-empty 는 예외 — Text 하나))
 머리    Key n01-asof        ShellAsOfHeader(asOf: vm.asOf) · (stale) ShellStaleBanner(asOf: vm.asOf)                                     · 늘
 필터    Key n01-p0-only     Padding(EdgeInsets.fromLTRB(16, 8, 16, 0)) · Align(centerLeft) · FilterChip(key, label: const Text(ShellLabels.alertsP0Only), selected: _p0Only, onSelected: (bool v) => setState(() => _p0Only = v))   · 늘
 고정    for (final (int i, AlertItem a) in vm.pinned.indexed) _AlertTile(keyBase: 'n01-pin-$i', item: a)                                    · 받은 차례
 묶음    for (final (int s, AlertSection sec) in vm.sections.indexed) _SectionBlock(index: s, section: sec)                                  · 받은 차례
         _SectionBlock = Column[ Padding(key: ValueKey<String>('n01-sec-$s'), EdgeInsets.fromLTRB(16, 12, 16, 4), Text(sec.headerText)) ·
                                 for (final (int i, AlertItem a) in sec.rows.indexed) _AlertTile(keyBase: 'n01-row-$s-$i', item: a) ·
                                 (digest != null) _DigestBlock(index: s, label: digest, rows: sec.digestRows) ]       ← final String? digest = sec.digestLabel;(build 지역 변수)
         _DigestBlock = Column[ InkWell(key: ValueKey<String>('n01-digest-$index'), onTap: () => setState(() => _open = !_open), Padding(16, 8)[ Row[ Expanded(Text(label)) · Icon(_open ? Icons.expand_less : Icons.expand_more) ] ]) ·
                                if (_open) for (final (int i, AlertItem a) in rows.indexed) _AlertTile(keyBase: 'n01-drow-$index-$i', item: a) ]   (기본 접힘 · 04 «P2 3건 ▾ 접힘»)
 빈      (empty != null) Padding(EdgeInsets.all(16), Text(empty, key: const Key('n01-empty')))      ← final String? empty = vm.emptyLabel;(🔴 다른 조건 0 — 데이터가 정한다)
 _AlertTile({required String keyBase, required AlertItem item}) (ConsumerWidget) = Column(crossAxisAlignment: start)[
         InkWell(key: ValueKey<String>(keyBase), onTap: link == null ? null : () { ref.read(shellLinkOpenerProvider).open(link); }, Padding(EdgeInsets.symmetric(horizontal: 16, vertical: 8))[ Row[
           Icon(look.$1, color: look.$2, size: 20) · SizedBox(width: 8) · Expanded(Text(item.title)) · (grouped != null) Badge(label: Text(grouped)) · (when != null) Padding(EdgeInsets.only(left: 8), Text(when)) ] ]) ·
         AlertAckBlock(keyBase: keyBase, alertId: item.alertId, ack: item.ack) ]
         ← final String? link = item.detailDeepLink; final String? grouped = item.groupedText; final String? when = item.raisedAtText; final (IconData, Color) look = _levelLook(Theme.of(context).colorScheme, item.level);
 _levelLook(ColorScheme cs, AlertLevel l) = switch (l) { AlertLevel.p0 => (Icons.error_outline, cs.error) · AlertLevel.p1 => (Icons.warning_amber_outlined, cs.tertiary) · AlertLevel.p2 => (Icons.info_outline, cs.onSurfaceVariant) }
         (04 §5-1 «P0 적 · P1 주황 · P2 회색» 의 colorScheme 근사 · 아이콘에 Key 0 · 반환 = (IconData, Color) 레코드 · 규칙 6 의 유일한 switch)
 🔴 행 사이 = Divider 또는 SizedBox(height: 정수) 재량 · 정적 글자 = 칩 라벨 하나 + 확인 조각의 둘 · 그 밖 0.

■ 화면 2 — N-02 (lib/src/alerts/alert_detail.dart · 04 §5-3 블록 순서 고정 · 위 → 아래 · 🆕 v1.15 AlertDetailVm)
 머리    Key n02-asof        ShellAsOfHeader(asOf: vm.asOf) · (stale) ShellStaleBanner(asOf: vm.asOf)                                      · 늘(🆕 · 🔵 머리 dy 0.0 = 이 위젯)
 모르는 id (missing != null) Padding(EdgeInsets.all(16), Text(missing, key: const Key('n02-missing')))                                      ← final String? missing = vm.missingLabel;(🔴 다른 조건 0 — 데이터가 정한다)
 아래 여섯 = item 이 있을 때만 — final AlertItem? item = vm.item;(build 지역 변수 · ! 0 · 꼴 = if (item != null) ...<Widget>[ … ] — 안에서 item 이 승격된다)
 제목    Padding(key: const Key('n02-title'), EdgeInsets.fromLTRB(16, 16, 16, 4), Text(item.title, style: Theme.of(context).textTheme.titleMedium))
 시각    (when != null) Padding(key: const Key('n02-time'), EdgeInsets.fromLTRB(16, 0, 16, 8), Text(when))                                               ← final String? when = item?.raisedAtText;
 무슨 일 Padding(key: const Key('n02-body'), EdgeInsets.fromLTRB(16, 8, 16, 8), Text(item.bodyText))
 조치    Padding(key: const Key('n02-action'), EdgeInsets.fromLTRB(16, 8, 16, 8), Text(item.actionLine))                                                  · (🔴 두 문단 = Text 둘 · 잇기 0)
 근거    (link != null) Padding(EdgeInsets.fromLTRB(16, 8, 16, 8)) · Align(centerLeft) · OutlinedButton(key: const Key('n02-link'), onPressed: () { ref.read(shellLinkOpenerProvider).open(link); }, child: const Text(ShellLabels.alertsEvidence))   ← final String? link = item?.deepLink;
 확인    AlertAckBlock(keyBase: 'n02', alertId: item.alertId, ack: item.ack)
 핸드북  (부재 — 01 §8 미결 139 · R16 · 코드 0)
 신선도  final bool stale = vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc());(규칙 5 ⓐ · clock = ref.watch(shellClockProvider) · build 에서 한 번)

■ 공용 조각 — AlertAckBlock (lib/src/alerts/alert_ack.dart)
 AlertAckBlock({super.key, required this.keyBase, required this.alertId, required this.ack}) · final String keyBase · final String alertId · final AckState? ack
 build: final AckState? a = widget.ack; if (a == null) return const SizedBox.shrink(); final CommandApi? api = ref.watch(shellAlertCommandApiProvider); final String base = widget.keyBase; final String? label = _label;
   → Padding(EdgeInsets.fromLTRB(44, 0, 16, 8)) · Column(crossAxisAlignment: start)[
       Text(a.stateLabel, key: ValueKey<String>('$base-state')) ·
       if (!a.acked && api != null) FilledButton(key: ValueKey<String>('$base-ack'), onPressed: _busy ? null : () { unawaited(_ack(api)); }, child: const Text(ShellLabels.alertsAck)) ·
       if (label != null) Text(label, key: ValueKey<String>('$base-receipt')) ·
       if (_failed) Text(ShellLabels.alertsAckNotAccepted, key: ValueKey<String>('$base-ack-fail')) ]
 🆕 didUpdateWidget(AlertAckBlock oldWidget) = super.didUpdateWidget(oldWidget); if (oldWidget.alertId != widget.alertId) { _busy = false; _failed = false; _label = null; }(재발행 — 엔진이 목록을 다시 내면 같은 자리의 알림이 바뀐다)
 _ack(CommandApi api) async = final String id = widget.alertId; setState(() => _busy = true) → try { final CommandReceipt r = await api.acknowledgeAlert(id); if (!mounted || widget.alertId != id) return; setState(() { _busy = false; _failed = false; _label = r.stateLabel; }); }
   catch (_) { if (!mounted || widget.alertId != id) return; setState(() { _busy = false; _failed = true; _label = null; }); }(꼴 = ui_journal advice_inbox.dart _defer + id 잡아 두기)
 🔴 이 조각 밖에서 acknowledgeAlert 를 부르지 않는다 · confirmKillChecklist 0 · 확인 다이얼로그 0 · dispose 0(구독 0).

■ 픽스처 (FixturePaths.… · singleFixture / listFixture · 🔴 테스트는 이 표를 믿지 말고 전제 expect 로 다시 확인한다 · 글자 = v1.15 픽스처 실물(M2 가지 m2/v115-r14))
 p0ack    singleFixture(m8AlertCenterP0Ack, AlertCenterVm.fromJson) — pinned 3(P0 · [0] ack 미확인 사다리 + raisedAtText + groupedText «2건» + deepLink + detailDeepLink · [1] ack acked · [2] ADVICE_EXIT_URGENT ack null) ·
          sections 1(«오늘» · rows 2 P1 · digestLabel null) · emptyLabel null · asOf «알림 기준 2026-08-31»(observed 2026-08-31T09:00Z · 26h)
 digest   singleFixture(m8AlertCenterDigest, …) — pinned 0 · sections 2: [0] «오늘» rows 1 P1(detailDeepLink **null** · raisedAtText non-null) · digestLabel null / [1] «2026-08-30» rows 0 · digestLabel «P2 3건» · digestRows 3 P2
          ([2] = raisedAtText null · deepLink null · ack null · detailDeepLink non-null · groupedText «3건») · emptyLabel null
 empty    singleFixture(m8AlertCenterEmpty, …) — pinned 0 · sections 0 · emptyLabel non-null(엔진 «정상 = 무소식» 문장)
 p0only   singleFixture(m8AlertCenterP0Only, …) — pinned 3(p0ack 의 pinned 와 같은 행) · sections 0 · emptyLabel null
 reordered singleFixture(m8AlertCenterP0AckReordered, …) — p0ack 와 같고 pinned 차례만 [1][0][2](재발행 표본 — [0] = p0ack.pinned[1](확인됨) · [1] = p0ack.pinned[0](미확인))
 🆕 fullV  singleFixture(m8AlertDetailFull, AlertDetailVm.fromJson) — item = p0ack.pinned[0] 과 같은 값(시각·근거·사다리 있음 · K11) · missingLabel null · asOf «알림 기준 2026-08-31»
 🆕 bareV  singleFixture(m8AlertDetailNoLink, …) — item = digest.sections[1].digestRows[2] 와 같은 값(raisedAtText · deepLink · ack null) · missingLabel null
 🆕 missingV singleFixture(m8AlertDetailMissing, …) — item null · missingLabel non-null(엔진 문장) · asOf 같음
 receipts listFixture(m8AlertAckReceipts3, CommandReceipt.fromJson) — 3행 · kind ALERT_ACK · [0] REQUESTED · [1] EXECUTED · 🆕 [2] REJECTED(rejectReasonCode INPUT_INVALID)(stateLabel 은 엔진 글자)
 full = fullV.item! · bare = bareV.item!(main() 머리 final · 두 픽스처 다 item non-null — 아니면 파일 적재가 큰 소리로 실패한다)
 🔴 쓰지 않는 것: alerts_12 · m8/alerts_p0_ack · alerts_digest · alerts_advice_9codes · 워치독 · copyWith · 지은 DTO.

■ Key 표 (n01- 10이름 + n02- 9이름 + 조각 4꼴 — 정본 = 이 표 · 🔴 표 밖 Key 0 · id 0 — 순번만 · 같은 이름을 두 자리에 달면 반려)
   이름                 다는 자리
   n01-loading          ShellSkeleton(값 전)
   n01-fail             ShellErrorView(에러)
   n01-asof             ShellAsOfHeader
   n01-p0-only          FilterChip
   n01-pin-$i           고정 행 _AlertTile 의 InkWell
   n01-sec-$s           _SectionBlock 머리 Padding
   n01-row-$s-$i        묶음 행 _AlertTile 의 InkWell
   n01-digest-$s        _DigestBlock 머리 InkWell
   n01-drow-$s-$i       접힌 행 _AlertTile 의 InkWell
   n01-empty            빈 문장 Text
   n02-loading · n02-fail · n02-asof(ShellAsOfHeader) · n02-missing(모르는 id 문장 Text) · n02-title · n02-time · n02-body · n02-action(각 Padding) · n02-link(OutlinedButton)
   조각 4꼴($base = keyBase — n01-pin-$i · n01-row-$s-$i · n01-drow-$s-$i · n02): $base-state(ack 글자 Text) · $base-ack(FilledButton) · $base-receipt(접수증 Text) · $base-ack-fail(실패 Text)

■ 할 일 — 이 순서로 · 커밋 나누기는 재량(제목 = 그 커밋 내용 · 🔴 커밋마다 git add <파일> 로 지정 — git add . 금지 · 커밋마다 바로 git show --stat HEAD 로 파일 목록 확인(C4r5a-3) · amend·rebase·강제 푸시 금지 · 마지막 커밋 = format · 질문 파일)
 (1) 정적 라벨 4(labels.dart R14a 절) + shell_providers.dart 끝 절(주입 1). 커밋 «[M8] R14a (1) 정적 라벨 · 주입»
 (2) lib/src/alerts/ 3파일 + 배럴 두 줄 + test/shell_fakes.dart 끝 절 + test/alert_center_test.dart(N01-01~N01-12) + test/alert_detail_test.dart(N02-01~N02-06). 🔴 커밋 전에 git add <그 파일들> 뒤 «정적 묶음» 미리 돌리기(실행 꼴 그대로).
     커밋 «[M8] R14a (2) N-01·N-02 알림 센터·상세 + 테스트»
 (3) 골든 10장 — test/golden/n01_golden_test.dart(3이름 × 2) · test/golden/n02_golden_test.dart(2이름 × 2). 커밋 «[M8] R14a (3) 골든 n01_* 6장 · n02_* 4장»
 (4) melos.bat run format:fix · melos.bat run analyze(🔴 (4) 전에 한 번) · 질문 파일(N01N02_questions.md — dy 측정 행 A1~A5 · 그 밖의 질문). 커밋 «[M8] R14a (4) format · 질문»
     🔴 (4) 뒤 커밋 0 — 예외 = 사전검사 ① 🔴 · analyze · format 실패를 고친 (5) 하나(«[M8] R14a (5) <까닭>» · 주석 고침도 여기에 · C4r5d-4).

■ 정적 라벨 — ShellLabels 안 R13b 절의 마지막 상수(homeParking) 뒤 · 닫는 } 앞에 절 주석(// ── 🆕 R14a — N-01·N-02 알림 ──…)과 함께 4개(이름·글자 고정 · static const String · 이름 머리 alerts — 정적 N10 이 센다):
   alertsP0Only = 'P0만 보기' · alertsAck = '확인했습니다' · alertsEvidence = '근거 보기' · alertsAckNotAccepted = '접수되지 않았습니다'
   🔴 만들지 않는 글자(엔진 몫): 날짜 머리 · 접힌 묶음 머리 · 묶음 배지 · 시각 · 제목·본문·조치 · ack 상태 글자 · 접수증 글자 · 빈 문장 · 「확인됨」 · 「읽음」 · 「알림 없음」.
   라벨 글자에 금액 0 · «추천·권유·자문·시그널» 0 · R13 절 31개는 그대로(🔵 총수 «정확히» = R14b 몫 — 이 카드는 R14a 절 4개만 센다).

■ 테스트 최소 목록 (번호는 PR 본문 ② 에 인용 · ⓡ·ⓗ 는 정적 N17·N18 · (전제) 는 N31 과 대조)
공통: 센터 띄우기 = pumpAlertCenter(tester, overrides:)(Size(390, 2400) · DPR 1.0 · teardown 2 · ProviderScope(overrides) > MaterialApp > Scaffold(body: AlertCenter()) · pump 두 번) ·
  상세 띄우기 = pumpAlertDetail(tester, overrides:, alertId:)(같은 꼴 · body: AlertDetail(alertId: alertId)) · overrides = alertOverrides(alerts:, api:, opener:, clock:)(4줄 · 아래 fakes) ·
  시계 = FixedClock(kGoldenNowUtc) · 오래됨 = FixedClock(kGoldenNowUtc.add(const Duration(days: 2)))(테스트 파일 안 final) ·
  경우가 여럿인 테스트 = for 로 testWidgets 를 경우마다(이름 '<번호> <설명> <경우>') · 경우의 흐름 = 클로저 칸((WidgetTester t) async {} · 🔴 bool 칸 + if 금지 · C4r5c-5 (a) — 이 꼴이 코드 글자다) · 기대 글자는 픽스처·ShellLabels 에서 · 띄우기는 한 테스트에 한 번 ·
  계획 = alert_center_test testWidgets 줄 12(테스트 24개) · alert_detail_test 줄 6(테스트 13개) · 골든 1 + 1 · testWidgets·test 줄 합 20(≤ 33) · import = 안 쓰는 것 0(analyze «No issues found!» 가 정본) —
     꼴 = 'dart:async'(🆕 두 테스트 파일 — Stream.multi 의 MultiStreamController · Completer · 드라이런 지적) → 'package:domain_contracts/domain_contracts.dart' → 'package:domain_contracts/testing.dart' → 'package:flutter/material.dart' → 'package:flutter_test/flutter_test.dart' → 'package:ui_shell/ui_shell.dart' → 'golden/golden_support.dart' → 'shell_fakes.dart'.
  🆕 test/shell_fakes.dart 끝 절(공개 이름 · 한국어 리터럴 0 · if 0 · collection-if 0 · import 추가 = 'package:ui_shell/src/…' 0(배럴로 충분) — 꼭 필요한 import 만):
    class FakeShellAlertCenterRepository extends UnimplementedAlertRepository { FakeShellAlertCenterRepository({required this.center, required this.detail});
      final Stream<AlertCenterVm> Function(int call) center; final Stream<AlertDetailVm> Function(int call) detail; final List<bool> p0Onlys = <bool>[]; final List<String> alertIds = <String>[];
      @override watchCenter({required bool p0Only}) → call = p0Onlys.length · p0Onlys.add(p0Only) · center(call) · @override watchAlert(String alertId) → call = alertIds.length · alertIds.add(alertId) · detail(call) }
    class FakeShellAlertCommandApi extends UnimplementedCommandApi { FakeShellAlertCommandApi({required this.receipt}); final Future<CommandReceipt> Function(int call) receipt; final List<String> acks = <String>[];
      @override acknowledgeAlert(String alertId) → call = acks.length · acks.add(alertId) · receipt(call) }(🔴 confirmKillChecklist 는 넘기지 않는다 — 받침대가 던진다)
    List<Override> alertOverrides({required FakeShellAlertCenterRepository alerts, required CommandApi? api, required RecordingLinkOpener opener, required Clock clock})
        ← shellAlertRepositoryProvider.overrideWithValue(alerts) · shellAlertCommandApiProvider.overrideWithValue(api) · shellLinkOpenerProvider.overrideWithValue(opener) · shellClockProvider.overrideWithValue(clock) — 4줄
    Future<void> pumpAlertCenter(WidgetTester tester, {required List<Override> overrides}) · Future<void> pumpAlertDetail(WidgetTester tester, {required List<Override> overrides, required String alertId})
    List<String> alertTileTexts(AlertItem a) => <String>[a.title, ?a.groupedText, ?a.raisedAtText](행 InkWell 안 Text 차례)
    Set<String> alertCenterAllowed(AlertCenterVm v)(= v 의 표시 글자 전부 — asOf.label · ?asOf.staleLabel · 행마다 title·?groupedText·?raisedAtText·?ack?.stateLabel(고정·묶음·접힌 행) · headerText · ?digestLabel · ?emptyLabel ·
      + ShellLabels.alertsP0Only · alertsAck · staleBannerTitle · null-aware 원소 · collection-for 만 · 🔴 링크·경로 문자열 0(C4r13b-6))
    Set<String> alertDetailAllowed(AlertDetailVm v)(= asOf.label · ?asOf.staleLabel · ?missingLabel · ?item?.title · ?item?.raisedAtText · ?item?.bodyText · ?item?.actionLine · ?item?.ack?.stateLabel
      + ShellLabels.alertsEvidence · alertsAck · staleBannerTitle · null-aware 원소만 · 🔴 링크 문자열 0)
  `one<T>(T v)` = R13b 도우미 그대로(새로 만들지 않는다) · 파일 머리(main() 안)에서 위 «픽스처» 를 한 번 final 로 읽는다 · Stream<T> valueThenFail<T>(T v) async* { yield v; throw StateError('fail'); } 를 지역 함수로 ·
  값을 끝까지 내지 않는 스트림 = Stream<T>.multi((MultiStreamController<T> c) {})(닫지 않는다 · teardown 0).
N-01 — test/alert_center_test.dart
 N01-01 렌더 순서·행 글자(04 §5-2 · 그림 10 · 받은 차례) — p0ack · operator: 전제 둘(testWidgets 본문 첫머리 · if 밖): expect(p0ack.sections.single.digestLabel, isNull); // pre · expect(p0ack.emptyLabel, isNull); // pre →
        alerts.p0Onlys == <bool>[false] · 사슬 Key getTopLeft dy 가 앞 것보다 크다: n01-asof → n01-p0-only → n01-pin-0 → n01-pin-1 → n01-pin-2 → n01-sec-0 → n01-row-0-0 → n01-row-0-1 ·
        shownTexts(n01-asof) == [p0ack.asOf.label] · ⓗ expect(p0ack.pinned, hasLength(3)) → i 마다 shownTexts(n01-pin-$i) == alertTileTexts(p0ack.pinned[i]) · n01-pin-3 findsNothing ·
        shownTexts(n01-sec-0) == [p0ack.sections.single.headerText] · ⓗ expect(p0ack.sections.single.rows, hasLength(2)) → i 마다 shownTexts(n01-row-0-$i) == alertTileTexts(rows[i]) · n01-row-0-2 findsNothing ·
        n01-digest-0 findsNothing · n01-empty findsNothing · find.text(ShellLabels.staleBannerTitle) findsNothing · ⓡ.
 N01-02 등급 모양 = AlertLevel 전수 switch(04 §5-1) — 두 경우 ㉠ (이름, 입력, 흐름, 행 목록 = (Key 이름, AlertItem) 레코드 — main() 머리에서 픽스처로 짓는다):
        (p0ack · 흐름 없음 · n01-pin-0..2 = pinned · n01-row-0-0..1 = rows) · (digest_open · 흐름 = tap(n01-digest-1) → pump · n01-row-0-0 = sections[0].rows[0] · n01-drow-1-0..2 = digestRows)마다 —
        전제 셋: expect(p0ack.pinned.first.level, AlertLevel.p0); // pre · expect(p0ack.sections.single.rows.first.level, AlertLevel.p1); // pre · expect(digest.sections[1].digestRows.first.level, AlertLevel.p2); // pre →
        await c.steps(tester) → 행마다 final Icon icon = tester.widget<Icon>(find.descendant(of: find.byKey(ValueKey<String>(k)), matching: find.byType(Icon))); expect(icon.icon, wantIcon(item.level)); expect(icon.color, wantColor(cs, item.level));
        (wantIcon·wantColor = 테스트 파일 안 private switch 둘 · 기대 원천 = 이 카드 «화면 1» _levelLook 글자 · cs = Theme.of(tester.element(find.byType(AlertCenter))).colorScheme) · ⓡ.
 N01-03 «P0만 보기» = 창구 인자 재구독(04 §5-2 · prompt 31 — 받은 목록을 거르지 않는다) — 센터 공장 = (int call) => call == 1 ? one(p0only) : one(digest) · 전제 둘: expect(p0only.sections, isEmpty); // pre · expect(digest.pinned, isEmpty); // pre →
        n01-sec-0 findsOneWidget · tester.widget<FilterChip>(find.byKey(const Key('n01-p0-only'))).selected isFalse → tap(n01-p0-only) → pump 두 번 → alerts.p0Onlys == <bool>[false, true] · selected isTrue ·
        ⓗ expect(p0only.pinned, hasLength(3)) → i 마다 shownTexts(n01-pin-$i) == alertTileTexts(p0only.pinned[i]) · n01-sec-0 findsNothing → tap(n01-p0-only) → pump 두 번 → alerts.p0Onlys == <bool>[false, true](앞 구독 그대로 · autoDispose 0) ·
        n01-sec-0 findsOneWidget · n01-pin-0 findsNothing · selected isFalse · ⓡ.
 N01-04 접힌 묶음 = 엔진 머리 · 펼침 = 표시 상태(04 §5-1 P2 · §5-2 «P2 3건 ▾ 접힘») — digest: final AlertSection d = digest.sections[1];(main() 머리) · 전제 셋: expect(d.digestLabel, isNotNull); // pre · expect(d.rows, isEmpty); // pre ·
        expect(digest.sections.first.digestLabel, isNull); // pre → shownTexts(n01-digest-1) == [d.digestLabel!] · n01-drow-1-0 findsNothing · n01-digest-0 findsNothing → tap(n01-digest-1) → pump →
        ⓗ expect(d.digestRows, hasLength(3)) → i 마다 shownTexts(n01-drow-1-$i) == alertTileTexts(d.digestRows[i]) · n01-drow-1-3 findsNothing → tap(n01-digest-1) → pump → n01-drow-1-0 findsNothing · alerts.p0Onlys == <bool>[false](재구독 0) · ⓡ.
 N01-05 빈 인박스 = 데이터(04 §5-2 «빈 인박스가 정상 · 문구 = 뷰모델») — 두 경우 ㉠ (empty · want = empty.emptyLabel) · (p0ack · null)마다 — 전제 넷: expect(empty.emptyLabel, isNotNull); // pre · expect(empty.pinned, isEmpty); // pre ·
        expect(empty.sections, isEmpty); // pre · expect(p0ack.emptyLabel, isNull); // pre → 규칙 10 «없는 쪽» 견본 그대로(양성 기준점 n01-pin-0) · n01-asof findsOneWidget · n01-p0-only findsOneWidget · ⓡ.
 N01-06 확인 버튼 = 데이터 + 주입(04 §5-4 · 01 §8-10 · «이긴다» ⑲) — 두 경우 ㉠ (operator · api = FakeShellAlertCommandApi(…) · 버튼 [true, false, false]) · (viewer · api = null · [false, false, false])마다 —
        전제 셋: expect(p0ack.pinned[0].ack?.acked, isFalse); // pre · expect(p0ack.pinned[1].ack?.acked, isTrue); // pre · expect(p0ack.pinned[2].ack, isNull); // pre →
        i(0..2)마다 final String? s = p0ack.pinned[i].ack?.stateLabel; «없는 쪽» 견본 꼴(s → tester.widget<Text>(find.byKey(n01-pin-$i-state)).data == s / findsNothing — Text 에 붙은 Key) · expect(find.byKey(ValueKey<String>('n01-pin-$i-ack')), c.buttons[i] ? findsOneWidget : findsNothing) ·
        find.byKey(ValueKey<String>('n01-pin-0-receipt')) findsNothing · ⓡ.
 N01-07 확인 누르기 = 명령 1회 · 접수증 한 줄 · 기다리는 동안 비활성(04 §5-4 · A-1 _defer 선례) — 네 경우 ㉠ (accepted · 접수 공장 = (int call) => Future<CommandReceipt>.value(receipts.rows[0]) · want = receipts.rows[0].stateLabel · 실패 글자 false · busy false) ·
        🆕 (rejected · (int call) => Future<CommandReceipt>.value(receipts.rows[2]) · receipts.rows[2].stateLabel · false · false — 거부 접수증도 엔진 글자 그대로 · 실패 글자 아님) ·
        (failed · (int call) => Future<CommandReceipt>.error(StateError('fail')) · null · true · false) · 🆕 (pending · (int call) => Completer<CommandReceipt>().future(끝나지 않는다) · null · false · true)마다 —
        전제 둘: expect(receipts.rows[0].kind, CommandKind.alertAck); // pre · expect(receipts.rows[2].state, CommandState.rejected); // pre →
        tap(n01-pin-0-ack) → pump 두 번 → api.acks == <String>[p0ack.pinned[0].alertId] · «없는 쪽» 견본 꼴(want → tester.widget<Text>(find.byKey(n01-pin-0-receipt)).data == want / findsNothing) ·
        expect(find.byKey(const ValueKey<String>('n01-pin-0-ack-fail')), c.failText ? findsOneWidget : findsNothing) · n01-pin-0-ack findsOneWidget(숨기지 않는다) ·
        🆕 expect(tester.widget<FilledButton>(find.byKey(const ValueKey<String>('n01-pin-0-ack'))).onPressed, c.busy ? isNull : isNotNull)(두 번 누름 막기) ·
        🆕 expect(tester.widget<Text>(find.byKey(const ValueKey<String>('n01-pin-0-state'))).data, p0ack.pinned[0].ack!.stateLabel)(낙관 갱신 0 — 상태 글자는 데이터가 바뀔 때만) · find.byType(AlertDialog) findsNothing ·
        alerts.p0Onlys == <bool>[false](낙관 갱신·재구독 0) · ⓡ.
 N01-08 행 탭 = detailDeepLink(데이터 · 링크 조립 0) — 두 경우 ㉠ (linked · p0ack · Key n01-pin-0 · want = <String>[p0ack.pinned[0].detailDeepLink!]) · (unlinked · digest · Key n01-row-0-0 · want = <String>[])마다 —
        전제 둘: expect(p0ack.pinned[0].detailDeepLink, isNotNull); // pre · expect(digest.sections.first.rows.first.detailDeepLink, isNull); // pre → tap(c.key) → pump → expect(opener.opened, c.want) · ⓡ.
 N01-09 갈래 × 상태(C4r3-1 · 🆕 갈래마다 배너 C4r5e-3) — 다섯 경우 ㉠ (이름, 센터 공장, 시계, 있어야 할 Key, 없어야 할 Key, 배너, 흐름):
        (loading · Stream.multi(값 0) · 정상 · [n01-loading] · [n01-asof, n01-fail] · 0) · (fail · Stream.error · 정상 · [n01-fail] · [n01-asof, n01-loading] · 0) ·
        (value_then_fail · valueThenFail(p0ack) · 정상 · [n01-fail] · [n01-asof] · 0 · 흐름 = expect(find.text(p0ack.asOf.label), findsOneWidget)) ·
        (stale · one(p0ack) · 오래됨 · [n01-asof, n01-pin-0] · [n01-fail] · 1 · 흐름 = expect(t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy, lessThan(t.getTopLeft(find.byKey(const Key('n01-p0-only'))).dy))) ·
        (stale_empty · one(empty) · 오래됨 · [n01-asof, n01-empty] · [n01-fail] · 1 · 흐름 = 배너 dy < n01-empty dy)마다 Key 목록마다 findsOneWidget / findsNothing ·
        find.text(ShellLabels.staleBannerTitle) = c.banner ? findsOneWidget : findsNothing · 흐름 · CircularProgressIndicator · LinearProgressIndicator findsNothing(ⓡ·ⓗ 없음).
 N01-10 재시도 — 센터 공장 = (int call) => call == 0 ? Stream<AlertCenterVm>.error(StateError('fail')) : one(p0ack) → tap(find.text(ShellLabels.retry)) → pump 두 번 → n01-fail findsNothing · n01-asof findsOneWidget ·
        alerts.p0Onlys == <bool>[false, false] · ⓡ.
 N01-11 화면 Text 전부 · 큰 글꼴(C4d-1) — 두 경우 ㉠ (p0ack · 흐름 없음 · allowed = alertCenterAllowed(p0ack)) · (digest_open · 흐름 = tap(n01-digest-1) → pump · allowed = alertCenterAllowed(digest))마다 규칙 10 «화면 Text 전부» 견본 그대로 →
        textScaleFactorTestValue = 2.0(+ teardown clear) → pump → expect(tester.takeException(), isNull) · ⓡ.
 🆕 N01-12 재발행 = 확인 조각 상태 초기화(04 §5-4 «갱신은 뷰모델 재발행으로만» · 명세 지적) — 한 경우: 전제 둘: expect(reordered.pinned[0].alertId, p0ack.pinned[1].alertId); // pre · expect(reordered.pinned[1].alertId, p0ack.pinned[0].alertId); // pre →
        final Completer<void> gate = Completer<void>(); · 센터 공장 = (int call) => twice()(지역 async* — yield p0ack → await gate.future → yield reordered) · api = FakeShellAlertCommandApi(receipt: (int call) => Future<CommandReceipt>.value(receipts.rows[0])) →
        tap(n01-pin-0-ack) → pump 두 번 → tester.widget<Text>(find.byKey(n01-pin-0-receipt)).data == receipts.rows[0].stateLabel(양성 기준점) → gate.complete() → pump 두 번 →
        tester.widget<Text>(find.byKey(n01-pin-0-state)).data == reordered.pinned[0].ack!.stateLabel · n01-pin-0-receipt findsNothing · n01-pin-1-receipt findsNothing · api.acks == <String>[p0ack.pinned[0].alertId] · ⓡ.
 ⓡ 기대 = alert_center_test.dart 11줄(N01-01~08 · 10 · 11 · 12) · ⓗ 기대 = 4줄(N01-01 둘 · N01-03 · N01-04) — 🔴 정확히 · (전제) = 23(01 2 · 02 3 · 03 2 · 04 3 · 05 4 · 06 3 · 07 2 · 08 2 · 12 2 — 정적 N31).
N-02 — test/alert_detail_test.dart(🆕 v1.15 — 입력 = AlertDetailVm 픽스처 3 · main() 머리 final: fullV · bareV · missingV · receipts · full = fullV.item! · bare = bareV.item! · const String goneId = 'al_gone_01'(ASCII · 픽스처에 없는 id — 가짜는 받은 id 를 기록만 한다))
 N02-01 블록 순서 고정 · 두 문단 · 머리(04 §5-3 · 그림 11 · §2-3) — fullV · operator: 전제 넷: expect(full.raisedAtText, isNotNull); // pre · expect(full.deepLink, isNotNull); // pre · expect(full.ack, isNotNull); // pre ·
        expect(fullV.missingLabel, isNull); // pre → alerts.alertIds == <String>[full.alertId](받은 id 그대로) · 사슬 dy: n02-asof → n02-title → n02-time → n02-body → n02-action → n02-link → n02-state ·
        shownTexts: n02-asof == [fullV.asOf.label] · n02-title == [full.title] · n02-time == [full.raisedAtText!] · n02-body == [full.bodyText] · n02-action == [full.actionLine] · n02-link == [ShellLabels.alertsEvidence] ·
        n02-missing findsNothing · find.text(ShellLabels.staleBannerTitle) findsNothing → tap(n02-link) → pump → opener.opened == <String>[full.deepLink!] · ⓡ.
 N02-02 부재 = 데이터(null = 부재) — bareV: 전제 셋: expect(bare.raisedAtText, isNull); // pre · expect(bare.deepLink, isNull); // pre · expect(bare.ack, isNull); // pre →
        n02-time · n02-link · n02-state · n02-ack · n02-missing findsNothing(단언마다 따로) · 양성 기준점 n02-asof · n02-title · n02-body · n02-action findsOneWidget · ⓡ.
 N02-03 확인 = 공용 조각 · 주입(04 §5-4) — 두 경우 ㉠ (operator · api 공장 = () => FakeShellAlertCommandApi(receipt: (int call) => Future<CommandReceipt>.value(receipts.rows[1])) · 흐름 = tap(n02-ack) → pump 두 번 → api!.acks == [full.alertId] ·
        tester.widget<Text>(find.byKey(n02-receipt)).data == receipts.rows[1].stateLabel) · (viewer · api 공장 = () => null · 흐름 = n02-ack findsNothing · n02-state findsOneWidget)마다 — 전제 하나: expect(full.ack?.acked, isFalse); // pre → 상세 공장 = one(fullV) ·
        흐름 칸 = (WidgetTester t, FakeShellAlertCommandApi? api) async {}(이 테스트만 두 인자 — testWidgets 안에서 공장으로 만든 가짜를 흐름에 넘긴다 · 드라이런 지적) → final FakeShellAlertCommandApi? api = c.api(); … await c.steps(tester, api) · ⓡ.
 N02-04 갈래 × 상태(C4r3-1 · 🆕 갈래마다 배너 C4r5e-3 · 모르는 id = 값 — 01 §24 K2) — 다섯 경우 ㉠ (이름, 상세 공장, 시계, id, 있어야 할 Key, 없어야 할 Key, 배너, 흐름):
        (loading · Stream.multi(값 0) · 정상 · full.alertId · [n02-loading] · [n02-asof, n02-fail] · 0) · (fail · Stream.error(StateError('fail')) · 정상 · full.alertId · [n02-fail] · [n02-asof, n02-loading] · 0) ·
        (value_then_fail · valueThenFail(fullV) · 정상 · full.alertId · [n02-fail] · [n02-asof] · 0 · 흐름 = expect(find.text(fullV.asOf.label), findsOneWidget)) ·
        (stale · one(fullV) · 오래됨 · full.alertId · [n02-asof, n02-title] · [n02-fail, n02-missing] · 1 · 흐름 = expect(t.getTopLeft(find.text(ShellLabels.staleBannerTitle)).dy, lessThan(t.getTopLeft(find.byKey(const Key('n02-title'))).dy))) ·
        (stale_missing · one(missingV) · 오래됨 · goneId · [n02-asof, n02-missing] · [n02-fail, n02-title, n02-loading] · 1 · 흐름 = 배너 dy < n02-missing dy · expect(t.widget<Text>(find.byKey(const Key('n02-missing'))).data, missingV.missingLabel))마다 —
        전제 둘: expect(missingV.item, isNull); // pre · expect(missingV.missingLabel, isNotNull); // pre → Key 목록마다 findsOneWidget / findsNothing · find.text(ShellLabels.staleBannerTitle) = c.banner ? findsOneWidget : findsNothing · 흐름 ·
        CircularProgressIndicator · LinearProgressIndicator findsNothing(ⓡ·ⓗ 없음 · 🔵 옛 unknown_id(스트림 에러) 경우는 없앴다 — v1.15 에서 모르는 id 는 값이다).
 N02-05 재시도 — 상세 공장 = (int call) => call == 0 ? Stream<AlertDetailVm>.error(StateError('fail')) : one(fullV) → tap(find.text(ShellLabels.retry)) → pump 두 번 → n02-fail findsNothing · n02-asof findsOneWidget · n02-title findsOneWidget ·
        alerts.alertIds == <String>[full.alertId, full.alertId] · ⓡ.
 N02-06 화면 Text 전부 · 큰 글꼴 — 세 경우 ㉠ (full · fullV · full.alertId) · (bare · bareV · bare.alertId) · 🆕 (missing · missingV · goneId)마다 operator · allowed = alertDetailAllowed(c.v) · 규칙 10 «화면 Text 전부» 견본 →
        textScaleFactorTestValue = 2.0 → takeException isNull · ⓡ.
 ⓡ 기대 = alert_detail_test.dart 5줄(N02-01 · 02 · 03 · 05 · 06) · ⓗ 기대 = 0줄(정적 N18 에 이 파일 줄이 나오지 않는다) — 🔴 정확히 · (전제) = 10(01 4 · 02 3 · 03 1 · 04 2).

🔴 병합 검사 때 통합 담당이 넣어 볼 변이(하나라도 테스트가 그대로 통과하면 반려 · 🆕 «갈래마다» — 공통 변이는 갈래 수만큼 짝으로 넣는다 · C4r5e-3):
   (순서·묶음) 고정 행 뒤집기 · 고정 둘 자리 바꾸기 · 묶음 머리 빼기 · 묶음 행을 시각 글자로 정렬 · P1 을 고정 쪽으로 올리기 · 접힌 행을 처음부터 펼침 · 접힌 머리 빼기 · 접힌 행 둘만(take(2)) · 묶음 둘 자리 바꾸기 ·
     🔵 참고 — 동치(예고 아님 · 드라이런 지적): «묶음 행·접힌 행을 level 로 정렬»(엔진 정의상 rows = P1 · digestRows = P2 라 묶음 안 등급이 하나 — 표본상 바뀌지 않는다 · 드라이런 M04·M04b SURVIVED · 시각 글자 정렬 M04c = KILLED).
   (등급) 아이콘·색을 하나로 고정 · p1 ↔ p2 모양 바꾸기 · p0 색을 tertiary 로 · 🔵 참고 — 타입이 막음(적용 불가 · C4r5e-6): «level 을 화면이 다른 값으로 다시 매기기»(AlertItem.level 은 final · 재분류는 비교로만 가능 = 위 정렬 꼴).
   (필터) «P0만 보기» 를 받은 목록 거르기로(where(level == p0) · 창구 인자 false 고정) · 칩 두 개 · 칩 탭에 재구독 0.
   (빈) emptyLabel 빼기 · 빈 문장을 고정 행이 있을 때도 정적 글자로 · 빈 갈래에 칩 빼기 ·
     🔵 참고 — 동치: «빈 문장에 화면 조건 더하기(고정·묶음 0 일 때만)»(계약상 emptyLabel 은 고정·묶음이 다 빈 날만 온다 — 잡을 표본 0 · 드라이런 R3).
   (확인) 버튼을 acked 에도 · 버튼을 ack null 에도 · 버튼을 주입 null 에도(비활성) · 누르면 acknowledgeAlert 두 번 · 누르면 0번 · 누른 뒤 버튼 숨김 · 누른 뒤 행 숨김(낙관) · 접수증 글자 빼기 · 실패 글자 빼기 ·
     확인 다이얼로그 겹치기 · ack.stateLabel 빼기 · 기다리는 동안 버튼 살리기(_busy 무시 — N01-07 pending) · 누른 뒤 상태 글자를 접수증으로(낙관 — N01-07 accepted) · 재발행 초기화 빼기(didUpdateWidget 0 — N01-12) ·
     🆕 거부 접수증을 실패 글자로(N01-07 rejected) ·
     🔵 참고 — 타입이 막음: «confirmKillChecklist 를 같은 버튼에»(가짜 받침대가 던진다 = 테스트 실패로 드러남 · 정적 N07 이 이름 0 을 본다) · 🔵 참고 — 테스트 밖: «완료 때 id 비교 빼기»(늦은 완료 경합 · 드라이런 D2 SURVIVED · 눈으로 본다).
   (링크) 행 탭 0 · 행 탭에 deepLink · detailDeepLink null 에도 탭(빈 링크) · N-02 근거 0 · 근거에 detailDeepLink · 링크를 글자로 그리기(탐침 · C4r13b-6) ·
     🔵 참고 — 정적이 잡음(테스트로는 동치 · 드라이런 R2·R6): «행 탭 링크를 'aaq://alerts/detail/<id>' 로 조립»(표본 detailDeepLink 가 조립 꼴과 같다 — 정적 N04 EXIT:0) · «slug·secret 낱말 주석»(정적 N32).
   (N-02) bodyText·actionLine 한 Text 로 잇기 · 두 블록 자리 바꾸기 · 시각 빼기 · 제목을 title + code 로 늘리기 · raisedAtText null 에도 빈 줄 · 근거 버튼을 deepLink null 에도 ·
     🆕 머리(asOf) 빼기 · 모르는 id 를 에러 화면으로(item null → ShellErrorView) · missingLabel 빼기 · 모르는 id 를 정적 글자로.
   (상태 — 갈래마다) 센터·상세 에러를 스켈레톤으로 · 값 뒤 에러에 마지막 asOf 글자 빼기(센터 · 🆕 상세) · 재시도에 invalidate 0(센터 · 상세) · 오래됨 배너 빼기(센터 행 있음 · 빈 · 🆕 상세 item · 모르는 id — 넷) · 배너를 칩 아래로 ·
     신선도 비교 뒤집기(센터 · 🆕 상세) · 벽시계로 신선도(센터 · 🆕 상세) ·
     화면에 정적 글자 하나 더하기(센터 · 상세 — 둘 다) · 스피너 더하기.
   🔵 판정 = 변이마다 ui_shell 의 flutter test 전부(골든 포함) + 정적 묶음(🔵 참고 «정적이 잡음» 몫). 골든은 아이콘 모양 일부를 못 본다 — 모양 변이는 N01-02 가 잡는다 ·
     드라이런 = 72꼴(갈래·짝마다 · 판정 4파일 alert_center_test · alert_detail_test · n01_golden · n02_golden · --update-goldens 0) — 예고 전부 KILLED 66 · 🔵 참고 6(M04·M04b·R3 동치 · R2·R6 정적 · D2 테스트 밖) · 예고 SURVIVED 0(첫 판) ·
     🆕 v1.15 반영판 = ⟦실측: 재드라이런 — 늘어난 N-02·거부 접수증 변이 포함 · 예고 SURVIVED 0 이어야 보낸다⟧.

■ 정적 묶음 — 아래 34줄을 파일로 꺼내 Git Bash 로 돌리고(C4r5a-2 · 🔴 터미널에 붙여 넣어 돌리지 않는다 — 대화형 bash 는 ! 든 줄을 건너뛸 수 있다 · bash 라고만 치면 이 PC 에서는 WSL), 나온 출력 전부를 PR 본문 ② 에 코드 블록 하나로 그대로 붙인다
  (대조에서 빼는 것 = 빈 줄·EXIT 표기·warning:·error: 줄·PowerShell 장식 줄·줄 머리 경과 시각뿐 · 🔴 출력은 줄이지 않는다 · 출력 줄 수(EXIT 줄 포함) = ⟦실측: 재드라이런 · 기대 147줄(첫 판 145 + N19 의 n02-asof · n02-missing)⟧ — 붙이기 전에 세어 같은지 본다 ·
   🆕 머리 글자 = ASCII 만(C4r5e-5) · 🆕 줄 수 기대는 판정 줄 위주(목록 줄은 N11 · N12 · N19 셋 — format 이 줄을 나눠도 수가 흔들리지 않는 꼴 · C4r5e-4) · «EXIT:1» = 출력 없음 · 블록 뒤 S05 결과 줄마다 정확히 «<파일>:<줄> — 탭 콜백 안»)
  실행 꼴(packages/ui_shell 에서 · PowerShell · 🔴 손으로 옮겨 쓰지 않는다 — 꺼내기 줄이 이 카드 main 판의 34줄을 그대로 꺼낸다):
  & "C:\Program Files\Git\bin\bash.exe" -c "mkdir -p ../../build && git show 'origin/main:docs/ai-context/send/R14a-Bob-N01N02.md' | sed -n '484,517p' > ../../build/r14a_static.sh"
  git hash-object ../../build/r14a_static.sh   ← 23b9bda2c893636be47a3c5b683cdb48de40fc27(= 아래 34줄 · 다르면 멈추고 채팅으로)
  & "C:\Program Files\Git\bin\bash.exe" -c "LC_ALL=C.UTF-8 bash ../../build/r14a_static.sh > ../../build/r14a_static_out.txt"
  Select-String -Path ..\..\build\r14a_static_out.txt -Pattern '^EXIT:(?![01]$)'
     ← 출력 없음이어야 한다 · 🔴 EXIT 가 0·1 밖(128 · 2 …)인 줄이 하나라도 나오면 그 검사가 돌지 않은 것 — 바로 위 줄을 한 번 더 돌린다 · 두 번째에도 나오면 멈추고 출력 파일 전부를 채팅으로(C4L-4)
  (Get-Content ..\..\build\r14a_static_out.txt).Count   ← ⟦실측: 재드라이런 · 기대 147⟧(EXIT 줄 34 포함) · (Select-String -Path ..\..\build\r14a_static_out.txt -Pattern '^EXIT:1$').Count ← 19 · -Pattern '^EXIT:0$' ← 15
  ② 에 붙일 출력 = Get-Content -Encoding UTF8 ..\..\build\r14a_static_out.txt 전부(build/ 는 .gitignore 대상 — git status 는 빈 채 · 커밋 0 · 할 일의 «미리 돌리기» 도 이 꼴)
echo "## N01 new test files hangul 0 (comment lines only)"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- test/shell_fakes.dart test/alert_center_test.dart test/alert_detail_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## N02 test names ASCII"; git grep -nP "(testWidgets|test|group)\('[^']*[^\x00-\x7F]|^\s*'[^']*[^\x00-\x7F][^']*',?\s*$" -- test/alert_center_test.dart test/alert_detail_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## N03 testWidgets and test lines"; git grep -cE "^\s*(testWidgets|test)\(" -- test/alert_center_test.dart test/alert_detail_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## N04 link literals in lib 0"; git grep -nE "'aaq://|'handbook://" -- lib; echo "EXIT:$?"
echo "## S05 opener lines (each must be inside a tap callback)"; git grep -n "shellLinkOpenerProvider" -- lib/src/alerts; echo "EXIT:$?"
echo "## N06 source and command lines (3)"; git grep -nE "watchCenter\(|watchAlert\(|acknowledgeAlert\(" -- lib/src/alerts; echo "EXIT:$?"
echo "## N07 forbidden words in alerts 0"; git grep -nE "DateTime\.now|kIsWeb|Platform\.|dart:io|HoldingPnl|PerformanceSeries|afterTax|confirmKillChecklist|killSwitch|CommandContext|AlertAck\b|watchInbox|watchCommand|raisedAt\b|groupedCount|escalationStep|ackedAt|\.code\b|\.wire\b|FeatureFlags|operatingMode|runMode|NumberFormat|DateFormat|toStringAsFixed|toString\(|\.sort|sorted|\.where\(|\.length|\.take\(|\.skip\(|AppRoutes|AppLinkSchemes|showDialog|AlertDialog|SnackBar|Clipboard|Share|print\(" -- lib/src/alerts; echo "EXIT:$?"
echo "## N08 AlertLevel switch arms (3)"; git grep -nE "AlertLevel\.(p0|p1|p2)" -- lib/src/alerts; echo "EXIT:$?"
echo "## N09 ack condition lines"; git grep -nE "\.acked|api != null" -- lib/src/alerts; echo "EXIT:$?"
echo "## N10 R14a labels (4)"; git grep -cE "^\s*static const String alerts" -- lib/l10n/labels.dart; echo "EXIT:$?"
echo "## N11 barrel exports"; git grep -n "^export " -- lib/ui_shell.dart; echo "EXIT:$?"
echo "## N12 shell providers"; git grep -nE "^final [A-Za-z]+<[^ ]+> shell" -- lib/src/shell_providers.dart; echo "EXIT:$?"
echo "## N13 imports outside the three packages 0"; git grep -nP "^import 'package:(?!domain_contracts/|flutter/|flutter_riverpod/|ui_shell/)" -- lib; echo "EXIT:$?"
echo "## N14 hangul literals in lib except labels 0"; git grep -nP "'[^'\n]*[\x{AC00}-\x{D7A3}]" -- lib ":!lib/l10n/labels.dart"; echo "EXIT:$?"
echo "## N15 figures 0 (prompt 68-74)"; git grep -nP "(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.4|10\.63|10\.85|10\.91|10\.96|11\.13|12\.5[0-9]|12\.60|8\.38|35\.05)(?![0-9])" -- lib; echo "EXIT:$?"
echo "## N16 decimal and percent literals 0"; git grep -nP "(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])|'[^'\n]*%" -- lib/src; echo "EXIT:$?"
echo "## N17 R lines (retry findsNothing)"; git grep -c "retry), findsNothing" -- test/alert_center_test.dart test/alert_detail_test.dart; echo "EXIT:$?"
echo "## N18 H lines (hasLength)"; git grep -c "hasLength(" -- test/alert_center_test.dart test/alert_detail_test.dart; echo "EXIT:$?"
echo "## N19 n01 n02 key names"; git grep -noP "n0[12]-[A-Za-z0-9]+(-[A-Za-z]+)*" -- lib/src/alerts; echo "EXIT:$?"
echo "## N20 keyBase keys (4)"; git grep -nF '$base-' -- lib/src/alerts; echo "EXIT:$?"
echo "## N21 banned vocabulary 0"; git grep -nE "추천|권유|자문|시그널" -- lib; echo "EXIT:$?"
echo "## N22 Colors files 0"; git grep -lw Colors -- lib; echo "EXIT:$?"
echo "## N23 rich text and trimming 0"; git grep -nE "RichText|SelectableText|Text\.rich|maxLines|TextOverflow|softWrap|\.trim\(|FittedBox" -- lib; echo "EXIT:$?"
echo "## N24 autoDispose 0"; git grep -n "autoDispose" -- lib; echo "EXIT:$?"
echo "## N25 Scaffold AppBar Navigator in alerts 0"; git grep -nE "Scaffold|AppBar|SafeArea|Navigator" -- lib/src/alerts; echo "EXIT:$?"
echo "## N26 shared files add-only and frozen files (numstat)"; git diff --numstat origin/main...HEAD -- lib/l10n/labels.dart lib/ui_shell.dart lib/src/shell_providers.dart test/shell_fakes.dart lib/src/shell_scaffold.dart lib/src/routing/shell_router.dart lib/src/common/shell_common.dart lib/src/ops_rhythm.dart lib/src/ops_home.dart pubspec.yaml analysis_options.yaml README.md test/ui_shell_test.dart test/golden/golden_support.dart test/golden/README.md test/flutter_test_config.dart test/golden/shift_tolerant_compare.dart test/shell_router_test.dart test/shell_scaffold_test.dart test/ops_rhythm_test.dart test/ops_home_test.dart test/golden/s01_golden_test.dart test/golden/h01_golden_test.dart test/golden/h02_golden_test.dart; echo "EXIT:$?"
echo "## N27 implements in new tests 0"; git grep -n " implements " -- test/shell_fakes.dart test/alert_center_test.dart test/alert_detail_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## N28 copyWith in tests 0"; git grep -n "copyWith(" -- test/alert_center_test.dart test/alert_detail_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## N29 collection-if in tests 0"; git grep -nE "^\s*if \(.*\) [^{]*,$|\[\s*if \(|<[A-Za-z]+>\[[^]]*\bif \(" -- test/shell_fakes.dart test/alert_center_test.dart test/alert_detail_test.dart test/golden/n01_golden_test.dart test/golden/n02_golden_test.dart; echo "EXIT:$?"
echo "## N30 golden files"; git diff --name-status origin/main...HEAD -- test/golden/goldens; echo "EXIT:$?"
echo "## N31 precondition marks (pre)"; git grep -c "// pre$" -- test/alert_center_test.dart test/alert_detail_test.dart; echo "EXIT:$?"
echo "## N32 secret words in alerts 0"; git grep -niE "slug|ping url|api.?key|healthchecks|secret" -- lib/src/alerts; echo "EXIT:$?"
echo "## N33 local read state 0"; git grep -nE "isRead|markRead|_read\b|_seen|dismiss" -- lib/src/alerts; echo "EXIT:$?"
echo "## N34 bare takeException 0"; git grep -nE "^\s*tester\.takeException\(\);" -- test/alert_center_test.dart test/alert_detail_test.dart; echo "EXIT:$?"
  (줄의 뜻과 기대(✅ 첫 판 드라이런 실측 · 🆕 v1.15 반영으로 바뀐 것 = N19 · N31 · 출력 줄 수 — 재드라이런이 다시 잰다) — N01 = 주석 줄 말고 출력 없음 · N02 = 출력 없음 · N03 = 4줄(alert_center_test 12 · alert_detail_test 6 · n01_golden 1 · n02_golden 1) · N04 = 0 ·
   S05 = 2줄(alert_center.dart 행 탭 · alert_detail.dart 근거 탭 — 줄마다 탭 콜백 안) · N06 = 3줄(alert_center watchCenter · alert_detail watchAlert · alert_ack acknowledgeAlert) · N07 = 0 · N08 = 3줄(_levelLook 세 갈래) ·
   N09 = 1줄(alert_ack.dart 의 if (!a.acked && api != null) — 드라이런) · N10 = «lib/l10n/labels.dart:4» · N11 = 8줄(l10n/labels.dart · src/alerts/alert_center.dart · src/alerts/alert_detail.dart · src/ops_home.dart · src/ops_rhythm.dart ·
   src/routing/shell_router.dart · src/shell_providers.dart · src/shell_scaffold.dart 차례 — R14a 몫 = 둘째·셋째 · 기대 — 🔵 «정확히» 판정 = R14b W11) · N12 = 15줄(R13 14 + 끝 1 = final Provider<CommandApi?> shellAlertCommandApiProvider · 기대 — «정확히» = R14b W12 · 이 카드 판정 = +1 · 삭제 0(N26)) · N13~N16 = 0 ·
   N17 = «test/alert_center_test.dart:11» · «test/alert_detail_test.dart:5» · N18 = «test/alert_center_test.dart:4»(alert_detail 줄 없음)(🔴 정확히 — 다르면 반려) ·
   N19 = 이름 19 = 위 «Key 표» 의 리터럴 이름(n01-loading · n01-fail · n01-asof · n01-p0-only · n01-pin · n01-sec · n01-row · n01-digest · n01-drow · n01-empty · n02-loading · n02-fail · n02-asof · n02-missing · n02-title · n02-time · n02-body · n02-action · n02-link — 순번 꼴은 머리만 · 같은 이름이 갈래마다 두 번 나와도 된다 · 표 밖 0) ·
   N20 = 4줄($base-state · $base-ack · $base-receipt · $base-ack-fail) · N21~N25 = 0 · N26 = 네 줄(labels.dart · shell_providers.dart · ui_shell.dart · shell_fakes.dart — 둘째 수 0 · ui_shell.dart 첫째 수 2 · 첫째 수는 재량 — 삭제 0 만 본다) ·
   그 밖 파일 줄 없음(🆕 R13 골든 테스트 3파일 포함 — 고치면 줄이 나온다) · N27 = 0 · N28 = 0 · N29 = 0 · N30 = 10줄 전부 «A»(n01_* 6 · n02_* 4 만) · N31 = «test/alert_center_test.dart:23» · «test/alert_detail_test.dart:10»(🔴 정확히) · N32 = 0 · N33 = 0 · N34 = 0)
  (🔵 git grep -c 가 0 인 파일은 줄로 나오지 않는다 — 출력 그대로 붙이고 «:0» 을 손으로 더하지 않는다 · N07 · N32 · N33 은 주석 줄도 센다(규칙 15))

■ 골든 — 5이름 × light/dark = 10장(전부 신규 · 이름 = 04 §5-2 (c) 글자 그대로 + N-02 권고 이름 · golden README «🆕 R14» 절 표 그대로)
  n01 — test/golden/n01_golden_test.dart · 크기 = kGoldenPhoneSize(390 × 844 · 드라이런 맨 아래 dy = n01_p0_ack 416.0 · n01_digest 244.0 · n01_empty 152.0 — light = dark · 🆕 n02_detail · n02_no_link = ⟦실측: 재드라이런 — v1.15 머리(asOf)가 붙어 첫 판 276.0 · 116.0 보다 내려간다⟧) · 위젯 = AlertCenter() · 명령 = FakeShellAlertCommandApi(receipt: …) · 저장소 = FakeShellAlertCenterRepository(…) · 시계 = FixedClock(kGoldenNowUtc)
    (🔴 가짜·저장소·명령은 testWidgets 안에서 새로 — 공장 꼴(C4r5d-5) · _Flow 칸에 인스턴스 0 · light·dark 공유 금지):
    이름           입력      주입       흐름    맨 아래 Key
    n01_p0_ack     p0ack     operator   없음    ValueKey<String>('n01-row-0-1')
    n01_digest     digest    operator   없음    ValueKey<String>('n01-digest-1')(🔵 접힌 채 — 04 «P2 3건 ▾ 접힘»)
    n01_empty      empty     operator   없음    Key('n01-empty')
  n02 — test/golden/n02_golden_test.dart · 크기 = kGoldenPhoneSize · 위젯 = AlertDetail(alertId: flow.vm.item!.alertId) · 상세 공장 = (int call) => one(flow.vm):
    n02_detail     fullV     operator   없음    ValueKey<String>('n02-ack')
    n02_no_link    bareV     operator   없음    Key('n02-action')
  모양 = h02_golden_test.dart(R13a)와 같은 (이름, 입력, 맨 아래 Key, 흐름) 목록(private class _Flow) × Brightness.values 루프 · 흐름 = 클로저 칸(전부 (WidgetTester t) async {}) · 테스트 이름 '${flow.name} ${brightnessSuffix(b)}' ·
  주입 = pumpForGolden(tester, <위젯>, brightness: b, logicalSize: kGoldenPhoneSize, wrapApp: (Widget app) => ProviderScope(overrides: alertOverrides(…), child: app)) → await tester.pump(); → await flow.steps(tester); →
    (<위젯> = n01 파일 const AlertCenter() · n02 파일 AlertDetail(alertId: flow.vm.item!.alertId) — n02 의 _Flow 입력 칸 = AlertDetailVm vm(🆕 v1.15 · 드라이런 지적 꼴 그대로))
    await tester.pumpAndSettle(); → 위치 전제 둘 → expectGolden(flow.name, b).
  위치 전제 둘 = 이 코드 글자 꼴(C4r3-5 · 흐름 뒤 · expectGolden 앞):
    expect(tester.getBottomLeft(find.byKey(flow.bottom)).dy, lessThan(kGoldenPhoneSize.height));
    expect(tester.getTopLeft(find.byKey(const Key('n01-asof'))).dy, 0.0);      ← n02 파일은 Key('n02-asof')(🆕 v1.15 — 머리가 맨 위)
  명령(packages/ui_shell): flutter test --update-goldens test/golden/n01_golden_test.dart → flutter test --update-goldens test/golden/n02_golden_test.dart → flutter test(옵션 없이 · git status 에 새 PNG 10 만 ?? · M 0).
  🔴 다른 골든 파일·폴더를 --update-goldens 에 넣지 않는다 · 🔴 높이는 늘리지 않는다(카드 확정값) · 머리 dy == 0 전제가 실패하면 고치지 말고 멈춘 뒤 실측 dy 를 질문 파일에 ·
     골든 높이 = 카드 확정값 + 여백 재량 — 줄였으면 «측정:» 행(줄이기 전 dy · 줄인 뒤 dy · 자리)을 질문 파일에 · 여백 밖을 바꿔야 들어가면 멈추고 dy 를 질문 파일에.
  dy = 이름·밝기마다 직접 잰다(lessThan(0) 임시 수정 → «Actual: <숫자>» → 되돌리기 · 커밋 0).

■ 질문 파일 (형식 = docs/ai-context/inbox/README.md · 🔴 새 파일을 만들지 않는다 — 이미 있다 · 카드마다 1개)
· N01N02_questions.md — 머리말의 «다음 번호»(Q1·A1)에서 이어 붙인다 · 다른 질문 파일 수정 0 · 표 끝에 새 행만 · 새 행 상태 «⬜ 미답» · 답 칸 비움 · 칸 안 세로 막대 금지 · 행 앞에 «N-01:» 또는 «N-02:» 접두(🔵 예외 = 골든 dy «측정:» 행).
· 꼭 적을 것: 골든 dy — 이름마다 한 행(A1~A5 = 위 골든 표 차례 · 종류 «추측» · 첫머리 «측정:») — 이 복사 상자 5줄을 그대로 붙이고 <값> 자리에만 잰 수를 넣는다(높이 = 리터럴):
      ┌── 측정 행 복사 시작(다음 줄부터 · 5줄)
| A1 | R14a-Bob-N01N02 | 추측 | 측정: n01_p0_ack dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A2 | R14a-Bob-N01N02 | 추측 | 측정: n01_digest dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A3 | R14a-Bob-N01N02 | 추측 | 측정: n01_empty dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A4 | R14a-Bob-N01N02 | 추측 | 측정: n02_detail dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
| A5 | R14a-Bob-N01N02 | 추측 | 측정: n02_no_link dy 실측값 (light=<값>, dark=<값>) < 844 | 골든 위치 전제 실측 | 844 미만 확인 | ⬜ 미답 | |
      └── 측정 행 복사 끝(이 줄 앞까지 · 괄호는 light·dark 두 값만 감싸고 «< 높이» 는 괄호 밖)
  여백을 줄였으면 A6 부터 «측정:» 전·후 행 · 더 필요해 보인 정적 라벨(🔴 만들지 말고 행으로) · 문서에 없어 정한 것 전부.
· 적지 않을 것(카드가 정함): 위젯·프로바이더·Key·파일 이름 · 정적 라벨 4 · 읽지 않는 필드 · 배치 순서 · 갈래 차례 · 확인 조각 꼴 · 펼침 기본값 · 필터 되돌리기의 재구독 0 · 골든 이름·입력 · 재량(여백·크기·모서리).
· 🔴 행을 쓰기 전에 그 내용을 카드에서 찾는다 · «카드대로» 행 금지 · 질문 파일은 브랜치에 커밋한다.

■ 제출
  (할 일 (1)~(4) 커밋이 끝난 뒤 — 마지막 커밋 = format·질문 커밋(또는 (5)))
  cd packages/ui_shell
  flutter test test/alert_center_test.dart          ← 끝 줄 그대로(기대 «+24: All tests passed!»)
  flutter test test/alert_detail_test.dart          ← 끝 줄 그대로(기대 «+13: All tests passed!»)
  flutter test test/golden/n01_golden_test.dart     ← 끝 줄 그대로(기대 «+6: All tests passed!»)
  flutter test test/golden/n02_golden_test.dart     ← 끝 줄 그대로(기대 «+4: All tests passed!»)
  flutter test   ← 옵션 없이 전부 통과(끝 줄 그대로 · 기대 = 시작 기준 N + 47 — ⟦실측: 재드라이런 · 기대 117 → «+164: All tests passed!»⟧)
  cd ../..
  & "C:\Program Files\Git\bin\bash.exe" tool/check_boundaries.sh   ← Git Bash 전체 경로(C4r5a-2) · 실패 0 · 🔵 main 에 원래 있는 ui_journal 🟡 1건(«packages/ui_journal/lib/src/timeline.dart:109»)은 이 카드와 무관 — 그대로 둔다
  melos.bat run format && melos.bat run analyze && melos.bat run test && melos.bat run test:contracts   ← 전부 SUCCESS · test:contracts 의 domain_contracts 끝 줄 «+⟦실측: 재드라이런 · 기대 408 — M2 가지 d9916ca 실측⟧ ~30: All tests passed!»(v1.15 병합본에서 다시 잰다 · 이 카드 몫 0) · «Some tests failed»·«FAILED» 0건 · format 0 changed(&& 가 안 되면 한 줄씩 · 🔴 백그라운드·파이프 금지)
  git status --short   ← 🔴 비어 있어야 다음으로
  git diff --name-status origin/main...HEAD
     ← 기대(이 줄들만 · 앞머리 packages/ui_shell/): M lib/l10n/labels.dart · A lib/src/alerts/alert_ack.dart · A lib/src/alerts/alert_center.dart · A lib/src/alerts/alert_detail.dart · M lib/src/shell_providers.dart · M lib/ui_shell.dart ·
        A test/alert_center_test.dart · A test/alert_detail_test.dart · A test/golden/goldens/n01_*.png 6장 · A test/golden/goldens/n02_*.png 4장 · A test/golden/n01_golden_test.dart · A test/golden/n02_golden_test.dart · M test/shell_fakes.dart ·
        M docs/ai-context/inbox/N01N02_questions.md · 그 밖의 줄(특히 M lib/src/shell_scaffold.dart · M lib/src/routing/shell_router.dart · M lib/src/ops_home.dart · M PNG · apps/** · packages/domain_contracts/** · 다른 ui_*) = 금지 — 멈추고 채팅으로
  사전검사 ① 코드만(저장소 뿌리 · 마지막 커밋 바로 뒤 · 출력은 채팅에 붙이지 않는다):
     [Console]::OutputEncoding = [Text.Encoding]::UTF8      ← PowerShell 5.1 이면 먼저 한 번(C4r5e-5)
     dart tool/precheck.dart --base origin/main --collection-if 0
     ← 🔴 가 하나라도 있으면 푸시하지 않는다 — 고친다(테스트만 · if 를 다른 꼴로 감추지 않는다) → 새 커밋 하나(«[M8] R14a (5) 사전검사 지적 수정» · amend 금지 · format:fix 먼저 · analyze·format 실패를 고칠 때도 이 (5) 하나) → 다시 돌려 🔴 0 · 🟡 는 멈춤 아님.
  git push -u origin ui/m8-n01-alerts
  git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD   ← ① 에 그대로 붙일 출력(권장대로면 커밋 4줄)
  cd packages/ui_shell → 위 «정적 묶음» 의 실행 꼴(파일로 꺼내 Git Bash · EXIT 확인) → cd ../..   ← ② 에 그대로 붙일 출력(r14a_static_out.txt 전부)
  PR 은 만들지 않습니다 · 라벨도 붙이지 않습니다. PR 제목: [M8] N-01·N-02 알림 센터·상세
  🔴 제출 글 = 아래 ①~⑤ 의 **전문**(재료·요약·«출력은 위와 같음» 이 아님) + 끝 flutter test 한 줄 — 채팅에 내지 않고 저장 파일 $env:TEMP\R14a-Bob-N01N02_submit.md 로(아래 N3 · C4r5a-1 · UTF-8 · BOM 있어도 됨) ·
     🔴 채팅 답 = 두 줄뿐: «R14a-Bob-N01N02 제출 글 저장했음: <(Resolve-Path $env:TEMP\R14a-Bob-N01N02_submit.md).Path 출력>» · 사전검사 ② 끝 줄 둘(n01 · n02 — « / » 로 이은 한 줄) · 대화 요약(Previous conversation summary)을 내지 않는다.
  PR 본문 5섹션을 저장 파일로 — 🔴 아래 섹션 머리 다섯 줄을 글자 그대로(사전검사 R1 · ② 머리의 «12항» 은 그대로 — 아래 자체 점검 상자는 10줄이지만 머리 글자는 사전검사가 정한다 · 🔴 «10항» 으로 고치면 🔴 R1):
      ┌── 섹션 머리 복사 시작(다음 줄부터 · 5줄)
## ① 구현한 화면 ID · 바뀐 파일 · 커밋
## ② 자체 점검 12항 · 정적 묶음 · 명령 출력
## ③ 스크린샷 서술 · 골든 표
## ④ 질문 목록
## ⑤ 추측한 것 목록
      └── 섹션 머리 복사 끝(이 줄 앞까지)
      🔴 N1 — 저장 파일 첫 줄 = «## ① 구현한 화면 ID · 바뀐 파일 · 커밋» — 그 위에 아무 글도 두지 않는다(머리말·구분선 금지).
      🔴 N3 — 내기 전 사전검사 ② 두 번 — 제출 글 전체(①~⑤ + flutter test 한 줄)를 저장소 밖 파일(notepad $env:TEMP\R14a-Bob-N01N02_submit.md · «UTF-8» 저장 · 커밋 0)에 저장한 뒤 저장소 뿌리에서:
     [Console]::OutputEncoding = [Text.Encoding]::UTF8
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R14a-Bob-N01N02_submit.md --golden-prefix n01 --goldens 6 | Out-File -Encoding utf8 $env:TEMP\r14a_pre2_n01.txt; Get-Content -Encoding UTF8 $env:TEMP\r14a_pre2_n01.txt | Select-Object -Last 1
     dart tool/precheck.dart --base origin/main --collection-if 0 --report $env:TEMP\R14a-Bob-N01N02_submit.md --golden-prefix n02 --goldens 4 | Out-File -Encoding utf8 $env:TEMP\r14a_pre2_n02.txt; Get-Content -Encoding UTF8 $env:TEMP\r14a_pre2_n02.txt | Select-Object -Last 1
        ← 🔴 두 출력 끝 줄 «── 결과: 🔴 0 · …» 를 눈으로 확인한 뒤에만 낸다(🔴 1 이상이면 글을 고쳐 다시 돌린다) · 출력은 채팅에 붙이지 않는다(출력 전부 = $env:TEMP\r14a_pre2_n0?.txt · 화면엔 끝 줄 한 줄씩) ·
          🔵 🟡 [G1] 은 멈춤이 아니다(드라이런 기대 🟡 = ⟦실측: 재드라이런 — 첫 판 6행 = n01 4 · n02 2⟧ — n01: n01_p0_ack light·dark «덩어리 차례 다름»(G1 이 버튼을 «칩 1개» 로 읽는다 · 표는 «버튼 글자») · n01_digest light·dark «글자 줄 수만 다름»(표 4줄 · G1 3줄) ·
          n02: n02_detail light·dark «덩어리 차례 다름»(같은 까닭 · 🆕 v1.15 머리 줄이 붙어 재드라이런이 다시 잰다) → 🔴 이 행들은 그대로 낸다 · PNG 를 다시 열지 않는다 · 칸을 고치지 않는다) · 🟡 [G1] 이 그 밖의 행에서 **상자 수·덩어리 차례**를 다르게 읽으면 그 이름의 light PNG 를 다시 열어 표를 맞춘다(안 줄 수만 다른 🟡 · «덩어리로 셀 수 없어 대조하지 않았다» 🟡 는 그대로 · C4r5b-4) ·
          🔴 🟡 수가 카드 기대보다 많으면 늘어난 🟡 행의 light PNG 를 다시 열어 표를 맞춘다 — 다시 열지 않고 그대로 내면 ② 반려(C4r5d-1).
   ① 아래 «① 머리 복사 상자» 한 줄 그대로 + «바뀐 파일:» + name-status 출력 그대로(코드 블록 하나) + «커밋 목록:» + log 출력 그대로(코드 블록 하나)
      ┌── ① 머리 복사 시작(다음 줄부터)
화면 ID: N-01 — 알림 센터(AlertCenter()) · N-02 — 알림 상세(AlertDetail(alertId:)) · 공용 조각 AlertAckBlock · 주입 shellAlertCommandApiProvider
      └── ① 머리 복사 끝(이 줄 앞까지)
   ② 자체 점검 10항(머리는 «12항») — 아래 복사 상자 10줄을 한 글자도 바꾸지 않고 붙인 뒤 « [x] ( )» 괄호 안만 채운다(코드에 실제로 있는 것만 · 10줄 그대로인지 «10항 줄 수» 출력으로 확인 · 🔴 코드 블록으로 감싸지 않는다 ·
     🆕 꼴 = «N. <prompt 글자> [x] ( )» — [x] 는 글자 뒤(R13b 선례 · 사전검사 R5 가 빈 괄호를 이 꼴로 잡는다 · 감사 지적)):
      붙일 괄호(글자 그대로 · <N> 자리에만 결과의 수):
        1번 = «정적 묶음 N13 — 허용 밖 import 0줄 · pubspec 무변경(N26)»
        2번 = «산술 = 신선도 한 식 · null 여부 · ack 조건 한 식 · AlertLevel switch · 표시 bool 뿐 · 거르기·정렬·세기 0(N07) · 금지 수치 N15 0건 · 소수·% 리터럴 N16 0건»
        3번 = «DateTime.now 0(N07) · 시각 = raisedAtText 그대로 · 사다리 남은 시간 계산 0(escalationStep 미참조 · N07)»
        4번 = «이 카드 범위 밖(5탭·홈·F-01 = R13·엔진 레인) · 손익 0(N07)»
        5번 = «재분류·재정렬·재묶기 0(N07 · N01-01 · N01-02 · N01-03 · N01-04) · 빈 인박스 = emptyLabel 데이터(N01-05) · 확인 = acknowledgeAlert 1회(N01-07)»
        6번 = «이 카드 범위 밖(DND UI = M9)»
        7번 = «이 카드 범위 밖(W-01 = R14b) · 알림 화면 slug·키·URL 0(N32)»
        8번 = «이 카드 범위 밖(시크릿 입력 = M9)»
        9번 = «이 카드 범위 밖(온보딩 = R15)»
        10번 = «삽입 자리 직접 구현 0 · confirmKillChecklist 0(N07) · 킬스위치 진입 = 셸 몫(무수정 N26)»
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
      10항 줄 수 — ② 복사 상자를 괄호까지 채운 글을 저장소 밖 파일($env:TEMP\r14a_box2.txt)에 저장 → (Get-Content -Encoding UTF8 $env:TEMP\r14a_box2.txt).Count → 출력 한 줄을 아래 «10항 줄 수» 상자 글자 틀 그대로(코드 블록 하나 · 명령 줄은 붙이지 않는다 · 기대 10):
      ┌── 10항 줄 수 복사 시작(다음 줄부터 · 4줄)
10항 줄 수:
```
<출력 한 줄>
```
      └── 10항 줄 수 복사 끝(이 줄 앞까지)
      이어서 «정적 묶음 출력:» + 34줄 출력 전부(코드 블록 하나) + «S05 결과:» 다음 줄부터 정확히 «<파일>:<줄> — 탭 콜백 안» 줄들(S05 출력 줄마다 한 줄 · 같은 차례 · 기대 2줄) +
      ⓡ·ⓗ = 아래 상자 글자 틀 그대로(N17·N18 출력 줄 그대로 복사) + «테스트 파일별:» + 위 flutter test 네 파일 끝 줄 그대로(alert_center · alert_detail · n01_golden · n02_golden 순)
      ┌── ⓡⓗ 복사 시작(다음 줄부터 · 4줄)
ⓡ = N17 출력:
<N17 출력 줄 그대로>
ⓗ = N18 출력:
<N18 출력 줄 그대로>
      └── ⓡⓗ 복사 끝(이 줄 앞까지)
   ③ 스크린샷 서술 — 센터 로딩·정상·빈·에러·오래됨 5줄 + 상세 로딩·정상·부재·모르는 id·에러·오래됨 6줄 + 골든 표 10행(처음부터 · 코드와 PNG 를 다시 열어 맞춘 뒤)
      🔴 서술 = 코드의 위젯·Key 이름 나열(«렌더 순서» 그대로 «→» · 조건부는 «(있을 때)» · 위 «화면 1·2» 배치와 다르면 제출하지 말고 멈춤) · 요약어 금지 · 색·테마 낱말 0(사전검사 R2) — 이 견본 글자 그대로(🆕 «자리 바꿈» 줄은 이 글자 그대로 — 펼치지 않는다 · C4r5e-7):
         «센터 정상» = ListView → Key('n01-asof') → ShellStaleBanner(있을 때) → Key('n01-p0-only') → ValueKey<String>('n01-pin-$i')(AlertAckBlock) → ValueKey<String>('n01-sec-$s') → ValueKey<String>('n01-row-$s-$i')(AlertAckBlock) →
                     ValueKey<String>('n01-digest-$s')(있을 때) → ValueKey<String>('n01-drow-$s-$i')(펼쳤을 때) → Key('n01-empty')(있을 때)
         «센터 빈» = «센터 정상» 의 행 자리에 Key('n01-empty')
         «센터 로딩» = ShellSkeleton(Key('n01-loading')) · «센터 에러» = ShellErrorView(Key('n01-fail')) · «센터 오래됨» = ListView → Key('n01-asof') → ShellStaleBanner → Key('n01-p0-only')
         «상세 정상» = ListView → Key('n02-asof') → ShellStaleBanner(있을 때) → Key('n02-title') → Key('n02-time')(있을 때) → Key('n02-body') → Key('n02-action') → Key('n02-link')(있을 때) →
                     AlertAckBlock(ValueKey<String>('n02-state') → ValueKey<String>('n02-ack')(있을 때))
         «상세 부재» = «상세 정상» 에서 Key('n02-time') · Key('n02-link') · AlertAckBlock 글자가 빠진 꼴
         «상세 모르는 id» = «상세 정상» 의 Key('n02-title') 부터 끝까지 자리에 Key('n02-missing')
         «상세 로딩» = ShellSkeleton(Key('n02-loading')) · «상세 에러» = ShellErrorView(Key('n02-fail')) · «상세 오래됨» = ListView → Key('n02-asof') → ShellStaleBanner → Key('n02-title')
      골든 표 10행(한 표 · 한 행 한 줄): «| 이름 | 입력 픽스처 | 주입 | 크기 | 위치 전제 dy | 배치·잘림 |» + 바로 다음 줄 구분 줄 «|---|---|---|---|---|---|»(없으면 표로 그려지지 않는다 · C4r5d-8) · 이름 칸 = «n01_p0_ack light» 꼴 ·
        🆕 입력 = 파일 이름만(경로 앞머리 없이 · C4r5e-7 — alert_center_p0_ack.json · alert_center_digest.json · alert_center_empty.json · n02 두 행 = alert_detail_full.json · alert_detail_no_link.json) · 주입 = operator · 크기 = 390×844 ·
        dy = 이름·밝기마다 잰 값 · 배치·잘림 = 이름마다 light PNG 한 장만 연다(5장) · dark 행 = 같은 이름 light 행 칸 글자 그대로(dy 가 같을 때만) ·
        칸 꼴 = «<덩어리 → 로 — 글자 n줄 · 상자 · 칩 n개 · 버튼 글자> — 잘림 없음» 또는 «… — 잘림: <어디가 어떻게>»(10행 모두 꼬리 · 코드 이름·픽스처 낱말·영문 0 · 🔴 사전검사 G1 출력을 옮기지 않는다) ·
        셈 단위 견본 2행(드라이런이 PNG 를 열어 쓴 칸 · 꼴만 본뜬다 · 🔴 견본과 같은 이름의 행은 꼬리까지 견본 글자 그대로 — PNG 가 견본과 다르게 보이면 칸을 바꾸지 말고 질문 파일에 · C4r5d-1):
         «| n01_p0_ack light | alert_center_p0_ack.json | operator | 390×844 | 416.0 | 글자 1줄 → 칩 1개 → 글자 2줄 → 버튼 글자 → 글자 6줄 — 잘림 없음 |»
         «| n02_detail light | alert_detail_full.json | operator | 390×844 | ⟦실측: 재드라이런 — dy⟧ | ⟦실측: 재드라이런 — PNG 를 열어 쓴 칸(첫 판 «글자 4줄 → 버튼 글자 → 글자 1줄 → 버튼 글자 — 잘림 없음» 앞에 머리 글자 줄이 붙는다)⟧ |».
   ④ 질문 목록 — git -c core.quotePath=false diff origin/main...HEAD -- docs/ai-context/inbox/N01N02_questions.md 출력에서 «+|» 로 시작하는 줄 전부(코드 블록 하나 · 순서 그대로 · 줄머리 «+» 까지 출력 그대로 — 지우지 않는다 · C4r5d-8 · 손으로 만들지 않는다)
   ⑤ 추측한 것 = N01N02_questions.md 새 A 행 중 «측정:» 이 아닌 행 전부 — 번호로(🔴 없으면 정확히 «없음» 한 낱말)
      ┌── 시작·끝 복사 시작(다음 줄부터 · 1줄)
flutter test: 시작 기준 <N> → 끝 <packages/ui_shell 의 flutter test 끝 줄 그대로>
      └── 시작·끝 복사 끝(이 줄 앞까지 · 끝 자리 = 시각·«+수»·«All tests passed!» 까지 끝 줄 그대로 · 사전검사 R5)
   (+ flutter test 한 줄 — 위 상자의 글자 틀 그대로(기대 M = N + 47 · 다르면 그 위 한 줄에 «까닭:» + 테스트 파일별 끝 줄))
````

---

## 3-1. 받아야 하는 것

- 브랜치 `ui/m8-n01-alerts` 푸시 1건 · 커밋 권장 4개(마지막 = format·질문 · amend·rebase·강제 푸시 0 · 커밋마다 지정 파일 add · (4) 뒤 = 사전검사 ① 🔴 · analyze · format 수정 (5) 하나만 · 제목 = 까닭).
- `lib/` 새 파일 **3**(`src/alerts/alert_center.dart` · `alert_detail.dart` · `alert_ack.dart`) · 수정 3(더하기만 — `labels.dart` R14a 절 4 · `shell_providers.dart` 끝 절 1 · `ui_shell.dart` export 2) · 셸 파일·R13 화면·`apps/`·`domain_contracts`·pubspec 변경 0.
- `test/` 새 파일 4(`alert_center_test.dart` · `alert_detail_test.dart` · `golden/n01_golden_test.dart` · `golden/n02_golden_test.dart`) + 수정 1(`shell_fakes.dart` 끝 절) + 새 PNG 10장 · 재생성 0.
- 질문 파일 `N01N02_questions.md`(새 행 A1~A5 «측정:» 반드시).
- 저장 파일 `$env:TEMP\R14a-Bob-N01N02_submit.md`(PR 본문 5섹션 + flutter test 한 줄) + 채팅 두 줄 · 사전검사 ① 한 번 · ② 두 번(`n01` 6 · `n02` 4) 🔴 0.
- `flutter test` = 시작 기준 N(⟦실측: 재드라이런 · 기대 117⟧) + 47(뷰 37 + 골든 10) · 정적 N10 = 4 · N17 = 11 · 5 · N18 = 4 · N20 = 4 · N30 = 10 A · N31 = 23 · 10(🔴 정확히) · N11 = 8줄 · N12 = 15(기대 — «정확히» = R14b · 이 카드 = 더하기만) · N19 = 이름 19 · 출력 ⟦실측: 재드라이런 · 기대 147⟧줄 · S05 = 2 · N06 = 3 · N08 = 3.
- 재분할 임계: 새 `testWidgets(`·`test(` 줄 20 · lib ⟦실측: 재드라이런 · 첫 판 +429⟧ · 새 PNG 10 → 재분할 없음.
- 🔴 C4 가 넣어 볼 예고 변이 중 드라이런이 확인한 것: 첫 판 = 예고 전부 KILLED(66꼴 · 갈래·짝마다) · 🔵 참고 6(동치 3 · 정적 2 · 테스트 밖 1 — «예고 변이» 🔵 참고 줄) · 표 = 통합 담당 스크래치 `r14/mut_R14a-Bob-N01N02/table.md` + `r14/mut_fix/` · 🆕 v1.15 반영판 = 재드라이런이 다시 넣는다(실측 표식 자리).

## 4. 받은 뒤 Claude에게 보낼 문장(한 줄)

```
R14a-Bob-N01N02 결과: 브랜치 ui/m8-n01-alerts 푸시됨 — PR 만들고 병합 검사하고 질문 반영해줘
```

그 아래에 **Bob 이 저장한 파일의 글 전부**를 붙여넣습니다(C4r5a-1 — Bob 채팅 화면의 글을 복사하지 않습니다 · 여는 법: PowerShell 에서 `notepad $env:TEMP\R14a-Bob-N01N02_submit.md`(또는 Bob 채팅 답 첫 줄의 경로를 메모장으로) → Ctrl+A → Ctrl+C → 붙여넣기 · 첫 줄이 `## ① 구현한 화면 ID · 바뀐 파일 · 커밋` 이고 끝 줄이 `flutter test: 시작 기준 … → 끝 …` 이면 맞게 연 것). 0단계에서 멈췄다면 `R14a-Bob-N01N02 0단계에서 멈춤 — 확인해줘` + Bob 이 보여 준 출력.

## 5. 주의

- **5분 눈 검사**: ① `shell_scaffold.dart`·`shell_router.dart`·`shell_common.dart`·`ops_rhythm.dart`·`ops_home.dart`·R13 테스트·기존 PNG 가 `M` ② `apps/**`·`packages/domain_contracts/**`·다른 `ui_*` 가 `M` ③ `lib/src/alerts/` 에 `watchInbox`·`watchCommand`·`confirmKillChecklist`·`CommandContext`·`AlertAck(`·`raisedAt`(단독)·`groupedCount`·`escalationStep`·`.code`·`AppRoutes`·`'aaq://`·`.where(`·`.sort`·`showDialog`·`DateTime.now` ④ 확인 버튼이 `acked` 에도 · 누른 뒤 사라짐 · 다이얼로그 ⑤ 날짜 머리·«P2 n건» 을 화면이 지음 ⑥ «P0만 보기» 가 받은 목록 거르기 ⑦ N-02 두 문단 한 Text ⑧ implements 가짜 · copyWith · 한국어 리터럴(테스트).
- 🔵 `golden:approved` 는 **이 카드에 필요 없다**(새 PNG 만 · 기존 24장 무변경).
- 🔵 C-46·C-47·경계 [5b][5c] 의 화면 스캔은 `ui_shell` 을 뺀다(01 §8 미결 91) — 이 카드는 정적 N07 · N13 · N14 · N32 가 그 구멍을 메운다(통합 담당이 C4 때 같은 줄을 다시 돌린다).
- 🔵 R14 2장 중 1번째 — 이 카드 병합 기록이 `send/_대기/R14b-Bob-W01.md` 를 `send/` 로 옮기고 `__R14A_SQ__`·`__R14A_PR__`·«앞 카드 병합 기록 때 채움» 실측 자리를 채운다 · «정확히 N»(라벨 35 · PNG 40 · README 장수) = R14b.
- ⬜ 남은 표식 = 실측 표식(꺾쇠 U+27E6 으로 여는 자리 — 셈 = `LC_ALL=C.UTF-8 grep -cP '\x{27E6}' R14a-Bob-N01N02.md` · 🔵 이 안내 줄에는 그 글자를 쓰지 않았다 — 셈이 이 줄을 세지 않는다) + 자리표시자 `__R14V115_SQ__`(계약 v1.15 squash — v1.15 병합 기록 때) · 🆕 실측 표식은 전부 **재드라이런 몫**(v1.15 가지 위 — 시작 기준 N · 끝 N · `domain_contracts` 수 · lib 줄 · 정적 출력 줄 수 · `n02_*` dy · `n02_detail` 견본 칸 · 🟡 기대 · 변이 표 — 꺼내기 줄 범위·해시는 이 판 글자로 이미 맞췄다 · 재드라이런이 카드 글자를 고치면 다시 잰다) · ✅ 이 판에서 채운 것 = 01 §24 절 번호 · 이름표(M2 코드 글자) · 0단계 계약 버전 줄(`1.15.0`) — 🔴 보내기 전 표식 0 · 자리표시자 0.
- 범위 고지: 01 §8 미결 10(뷰어 ALERT_ACK · v1 = 부재) · 91(셸 스캔 제외) · 137(ShellLinkOpener 늘 push)은 이 카드가 닫지 않는다 · 🆕 v1.15 가 01 §8 에 적은 미결(이 카드가 닫지 않는다 · 소유 카드 = 01 §24-8) = 138 사다리 단계 줄(소유 = R14 뒤 셸 손질 카드) · 139 N-02 핸드북 앵커(R16) · 140 §5-5 채널 능력 고지(M9 — «첫 진입 1회» = 엔진 플래그 · 화면 로컬 기억 0 = N33 과 같은 뜻) · 141 알림 센터 셸 진입점 · 142 뷰어 원천(엔진 레인) · 144 `ui_shell` 화면 스캔 빈틈(이 카드 정적 묶음이 메운다) · 145 공용 모양 함수(`AlertLevel`·`UiLevel` 아이콘·색 — R14b 가 H-01 `_cellLook` 글자를 복사 · P0 `error_outline` 은 H-01 act 와 같은 글리프 · 색만 다름) · 146 구 `watchInbox` 표본의 표시 필드 null · 148 공통 상태 ⑤ 차단·⑥ 부분 동기 · F-01 = 엔진 레인(06 `M1-15` · 04 §5-6 네 규약).

## 6. R14 이월 반영 — 설계 12 §3 부록 중 대상 «R14» 항목(2026-10-30 · 조립 — ✅ 는 병합된 것만이라 쓰지 않는다)

원문 = 설계 저장소 `11_앱설계/12_AI별_요청_스크립트.md` §3 «R5e C4 이월 부록»(`10_리뷰/2026-10-29_R5e_C4_보고.md` §8) · «R5a·R5c·R5d C4 이월 부록» · «R13a·R13b C4 이월 부록». R14b 카드 «6» 이 같은 표를 W-01 자리로 싣는다.

| 항목 | 이 카드에 반영한 자리 | 반영 안 함 · 남은 몫 |
|---|---|---|
| C4r5e-3 예고 변이 «갈래마다» 짝 | 예고 변이 머리 «갈래마다 — 공통 변이는 갈래 수만큼 짝» · (상태 — 갈래마다) 줄(배너 빼기 = 행 있음·빈 둘 · 정적 글자 = 센터·상세 둘 · 재시도 invalidate 0 = 센터·상세) · 최소 목록 N01-09 `stale`·`stale_empty` 두 경우(갈래마다 배너 단언) | 상태 묶음 변이(보류 3상태 류) = 이 카드에 없음(확인 조각 상태 = _busy·_failed 둘 — N01-07 두 경우) · copyWith 시드 = 0(N28) |
| C4r5e-4 정적 줄 수를 format 에 덜 흔들리게 | ■ 정적 묶음 머리(판정 줄 위주 · 목록 줄 = N11 · N12 · N19 셋) · N09 = 판정 한 줄 기대 | 이 카드는 `dispose` 자리 0(확인 조각 구독 0) → «dispose 범위 안 ref 0» 판정 줄 불필요 · C-46 ㉔ `\bref\s*\.` = M2 창(01 §8 미결 135) 그대로 |
| C4r5e-5 PowerShell 5.1 인코딩 | 정적 묶음 머리 글자 ASCII(34줄 전부) · ② 붙이기 줄 `Get-Content -Encoding UTF8` · ■ 제출 사전검사 ①·N3 앞 `[Console]::OutputEncoding` · «2» 6번 · ■ 제출 «UTF-8 · BOM 있어도 됨» | infra(사전검사 ② «??»·U+FFFD 🟡) = 12 §3 부록 그대로 |
| C4r5e-6 타입이 막는 변이 = 참고 | 예고 변이 (등급) «level 다시 매기기» · (확인) «confirmKillChecklist 같은 버튼» = «🔵 참고 — 타입이 막음(적용 불가)» | — |
| C4r5e-7 ③ «자리 바꿈» 줄 · 입력 칸 = 파일 이름만 | ■ 제출 ③ 견본 머리(«자리 바꿈» 줄 = 글자 그대로) · «센터 빈» · «상세 부재» 줄 · 골든 표 «입력 = 파일 이름만» | — |
| C4r5a-5 «선택 UI 더하기» · «rows 있을 때도 빈 문장» | 예고 변이 (필터) «칩 두 개» · (빈) «빈 문장을 고정 행이 있을 때도» | ✅ 01 §24 K10(«`emptyLabel` non-null ⇔ `pinned` 0 ∧ `sections` 0» · 계약 C-49 가 픽스처로 지킨다) |
| C4r5a-7 «없는 쪽» 양성 기준점 | 규칙 10 «없는 쪽» 견본(`n01-pin-0` findsOneWidget) · N02-02 양성 기준점 | — |
| C4r5a-8 G1 «상자(안 n)» · 같은 기하 같은 셈 | 규칙 요약 셈 단위(칩 · 버튼 글자 2) | infra 그대로 |
| C4r5c-5 견본 «그대로» 의 폭 | (a) 공통 «흐름 = 클로저 칸 — 이 꼴이 코드 글자다» · 골든 흐름 = 전부 `(WidgetTester t) async {}` | (b) X7 `_restoreDone` = 해당 없음(초안 0) |
| C4r5d-5 골든 «명령 칸» = 공장 | ■ 골든 «가짜·저장소·명령은 testWidgets 안에서 새로 — 공장 꼴 · _Flow 칸에 인스턴스 0» | 이 카드는 X7 카드가 아니지만 골든이 확인 버튼(명령 주입)을 찍어 반영 · 다음 X7 카드 몫 = 부록 그대로 |
| C4r13a-3 참고 변이 6꼴(셸) | — | 🔵 이 카드는 S-01·H-02 테스트 파일을 고치지 않는다(규칙 1) → 통합 담당 test-only PR(R5 #85 선례 · R14b 병합 뒤) 권고 · «빈 + emptyLabel null» 표본 = test-only PR 몫(✅ ⑭ 권고대로 · v1.15 는 싣지 않았다) |
| C4r13b-4 T01-09 today_stale 존재 목록 · valueThenFail | — | 🔵 홈 연결 0(셸 진입 0 · ⑥) → C4r13a-3 와 한 test-only PR 권고(⑭) |
| 공통 교훈(R5a~R5e) | 머리 «교훈 반영» 줄 · «2» 6·7번 · 규칙 10 반려 꼴 · ■ 정적 묶음 실행 꼴 · ■ 제출 N3 G1 조문 · ③ 구분 줄 · ④ «+» · N34 | — |
