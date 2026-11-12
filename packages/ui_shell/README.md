# ui_shell — M8 셸 · 운영 홈 · 알림 · 핸드북 · X3 온보딩

> **owner**: **공동** — 등급·헬스 계약은 **Claude**, 렌더는 **다른 AI(화면)**
> **청사진 카드**: **M8** shell-ops-ui · **X3** onboarding-account(위저드 렌더)
> **화면 명세**: `11_앱설계/04_화면명세_M8_셸_운영홈_알림_온보딩.md`
> **선행 의존**: **M2 계약(G3)** · 알림 등급표(`06_시스템설계/04_안전장치.md §5-3`) · M4 키 금고 · X1 리스 RPC

## 무엇을 담나

5탭 셸 · 운영 홈(과정 지표) · 알림함 · 워치독 상태 · 핸드북 · 온보딩 위저드(처음 시작 / 재연결 / viewer 페어링).

## 의존 — 허용 (01 §1-1)

`domain_contracts` · Flutter · `flutter_riverpod`.

## 의존 — 🔴 금지 (넣으면 C-3이 빌드를 막는다)

`core_engine` · **`decimal`** · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · `http`.

## 이 패키지가 지는 규칙 5개

1. **🔴 홈·알림·FGS·위젯에 손익 숫자가 없다**(결정 8). 홈에 두는 것은 **슬리브별 목표 대비 편차·밴드 여유·과정 지표 3개**다 — `SleeveWeight`가 그 타입이다. `HoldingPnl`·`PerformanceSeries` 참조는 C-6이 잡는다.
2. **알림 등급을 재분류하지 않는다**(결정 7c). P0=즉시 개입 / P1=오늘 확인 / P2=기록만은 **조치 기준**이고 엔진이 한 번만 정의한다. 묶음(`groupedCount`)도 엔진이 이미 묶어서 준다.
3. **«무슨 일인가»(`bodyText`)와 «지금 할 일»(`actionLine`)을 합치지 않는다.** 조치가 다르면 다르게 말한다 — 경보 피로 방지 규칙.
4. **온보딩에서 «모름»은 통과가 아니다.** `GateState.unknown`은 `notApplicable`과 달리 **진행 차단**이다(리스·기기 원장 판정).
5. **시각을 화면이 포맷하지 않는다.** 소요 시간·경과·D-day·TTL 잔여는 엔진 문자열이다. 유일한 예외는 신선도 배너 비교 하나(`observedAt + staleAfter < clock.nowUtc()`)이며 그것도 주입된 `Clock`으로 한다 — `DateTime.now()` 직접 호출은 금지다.

## ✅ 허용 / 🔒 금지 — 안전 상태 (01 §2-10 표)

- ✅ 홈 요약의 `breakerLabel` 한 줄 · `BlockFlag` 배너와 `clearRoute` **딥링크**.
- 🔒 `killSwitch`·`releaseProgress` 게이지 · 재개 게이트 · 플래그 **해제 조작** — 전부 `ui_safety`(Claude)다. 게이트를 **확인 대화상자로 대체하는 것**도 반려다.

## ⚠️ 시크릿 입력 위젯을 만들지 않는다

온보딩이 키를 다루더라도 **입력 위젯 자체가 이 패키지에 있어서는 안 된다**(뷰어 빌드에 경로가 생긴다). 검증·저장은 `SettingsActions` 주입 콜백이고, 구현체가 없으면 **컨트롤을 렌더하지 않는다** — «비활성»이 아니라 **부재**다.

## 지금 상태 — ✅ S-01·S-02 셸 · H-02 운영 리듬 · H-01 운영 홈 · N-01·N-02 알림 · W-01 워치독 · O-00·O-00b 온보딩 첫 실행 · O-01~O-03 단계 목록·상세·검증 · O-04 온보딩 마무리 · R-01 다시 시작 · V-01 조회 전용 페어링 · D-01 장애 배너 · D-02 DR 런북 · D-03 오프라인 긴급정지 카드 · B-01 전략 핸드북 목차 · B-02 핸드북 페이지 · H-03 물리 리스크 점검 병합(2026-11-13 · R13a PR #71 `315bbbd` · R13b PR #74 `49e4329` · R14a PR #87 `185e9c7` · R14b PR #88 `afe3e1d` · 🏁 R14 · ✅ R14 test-only(PR #89 squash `14d6374`) · R15a PR #99 `940082c` · R15b PR #103 `a79f620` · R15c PR #107 `0e96ed3` · R15d PR #110 `4b31603` · 🏁 R15 · ✅ R15 test-only(PR #113 squash `69afd33`) · R16a PR #126 `1e113ef` · R16b PR #132 `8af4722` · R16c PR #135 `4db3ddf` · 🏁 R16)

`flutter test` **472**(R16c 병합본 `4db3ddf` 실측 · 2026-11-13 · 456 + R16c 16 — `device_risk_board_test` +12 · `h03_golden` +4(파일별 = C4 재실행) · 1회차 `29f62be` merge(«C4 정정» 0 · 코드 정정 0)) · 골든 PNG **92장**(`git ls-tree` 실측 · 88 + `h03_*` 4 · `test/golden/README.md` «🆕 R16») · lib `.dart` 26 · 라벨 37 · export 23 · 주입 23(병합본 실측 · «정확히 N» = R16c 정적 T13~T15 · T37 ✅) · 🏁 R16 세 장 완료(R16a #126 `1e113ef` · R16b #132 `8af4722` · R16c #135 `4db3ddf` · 357 → 472 · PNG 70 → 92) — 다음 = R16 test-only 묶음(통합 담당 · 패킷 아님 · C4r16a-2 · C4r16b-3 · C4O-7 · C4O-9 · R16c 몫 0 · 설계 12 §3 «R16a · R16b C4 이월 부록») → 설계 12 §6 큐(R6-Bob-M9a 이후 · 조립 전).

~~`flutter test` **456**(R16b 병합본 `8af4722` 실측 · 2026-11-06 · 414 + R16b 42 — `handbook_contents_test` +14 · `handbook_page_view_test` +20 · `b01_golden` +2 · `b02_golden` +6(파일별 = C4 재실행) · 1회차 `90c2e9b` 반려 → 재제출 `5d5b5c2`(테스트 파일 1줄 · B02-02 전제) → 2회차 merge-with-fixes) · 골든 PNG **88장**(`git ls-tree` 실측 · 80 + `b01_*` 2 + `b02_*` 6 · `test/golden/README.md` «🆕 R16») · lib `.dart` 25 · 라벨 37 · export 22 · 주입 23(병합본 실측 · «정확히 N» = R16c 정적 T13~T15 · T37) · R16 3장 중 2장 완료 — 다음 셸 카드 = R16c-Bob-H03(`H-03` 물리 리스크 점검 · ▶ `docs/ai-context/send/R16c-Bob-H03.md` 「푸시해」 뒤 · 끝 기대 472 · 골든 +4 · «정확히 N» 소유 — 라벨 37 · 배럴 23 · 주입 23 · PNG 92) → 🏁 R16 → R16 test-only 묶음(C4r16a-2 · C4r16b-3 · 설계 12 §3 «R16a · R16b C4 이월 부록»).~~(2026-11-06 R16b 판)

~~`flutter test` **414**(R16a 병합본 `1e113ef` 실측 · 2026-11-05 · 357 + R16a 57 — `incident_banner_test` +20 · `runbook_list_test` +9 · `runbook_detail_test` +9 · `emergency_stop_card_test` +9 · `d01_golden` +4 · `d02_golden` +4 · `d03_golden` +2(파일별 = C4 재실행) · `origin/main` `98ba98c`(+ 엔진 E13f2) 에서 다시 잼 = 같음 · 1회차 `6cd05e6` 반려 → 재제출 `20bbc63`(질문 파일 2줄) → 2회차 merge) · 골든 PNG **80장**(`git ls-tree` 실측 · 70 + `d01_*` 4 + `d02_*` 4 + `d03_*` 2 · `test/golden/README.md` «🆕 R16») · lib `.dart` 23 · 라벨 37 · export 20 · 주입 22(병합본 실측 · «정확히 N» = R16c 정적 T13~T15 · T37) · R16 3장 중 1장 완료 — 다음 셸 카드 = R16b-Bob-B01B02(`B-01`·`B-02` 전략 핸드북 · ▶ `docs/ai-context/send/R16b-Bob-B01B02.md` 「푸시해」 뒤 · 끝 기대 456 · 골든 +8 · 셸 핸드북 자리 두 곳) → R16c-Bob-H03(«정확히 N») → R16 test-only 묶음(C4r16a-2 · 설계 12 §3 «R16a C4 이월 부록»).~~(2026-11-05 R16a 판)

~~`flutter test` **357**(R15 test-only 병합본 `69afd33` 실측 · 2026-11-04 · 355 + 2 — `onboarding_step_detail_test` 23→24(O03-07b) · `onboarding_restart_test` 20→21(R01-05 gap7) · `onboarding_finish_test` 25 · `viewer_pairing_test` 12(단언 줄만 · 파일별 = PR 본문 · 합계만 실측) · 테스트 파일만 · lib·픽스처·PNG·fakes 0) · 골든 PNG **70장**(그대로 · `git ls-tree` 실측) · lib `.dart` 19 · 라벨 37 · export 16 · 주입 19(그대로) · 🏁 R15 4장 완료 + ✅ 통합 담당 test-only PR #113(C4r15b-1 · C4r15c-1 · C4r15c-2 · C4r15d-1 · C4r15d-2 = ✅ 5건 전부 · 근거 변이 8 SURVIVED → KILLED · 탐침 5 KILLED · 기존 테스트 수정 0 · 설계 12 §3 «R15 test-only PR 묶음») → 다음 셸 카드 = R16(조립 전 · 설계 12 §6 11).~~(2026-11-04 R15 test-only 판)

~~`flutter test` **355**(R15d 병합본 `4b31603` 실측 · 2026-11-04 · 315 + R15d 40 — `onboarding_restart_test` +20 · `viewer_pairing_test` +12 · `r01_golden` +4 · `v01_golden` +4 · ← R15c 병합본 `0e96ed3` 315) · 골든 PNG **70장**(`git ls-tree` 실측 · 62 + `r01_*` 4 + `v01_*` 4 · `test/golden/README.md` «🆕 R15») · lib `.dart` 19 · 라벨 37 · export 16 · 주입 19(병합본 실측 · «정확히 N» = R15d 정적 T13 · T14) · 🏁 R15 4장 완료 — 다음 = 통합 담당 R15 test-only PR(테스트 파일만 · lib·픽스처·PNG·fakes 무수정 · 설계 12 §3 «R15 test-only PR 묶음»: C4r15b-1 = `onboarding_step_detail_test` O03-07b 재시도 중 두 번 누름 0 · C4r15c-1 = `onboarding_finish_test` O04-03 `no_builder`·O04-09 `viewer` 양성 기준점 · C4r15c-2 = O04-01 단계 아이콘 icon·color · C4r15d-1 = `viewer_pairing_test` V01-07 버튼 수 · C4r15d-2 = `onboarding_restart_test` R01-05 `gap7`(차단 + 고지)) → R16 조립.~~(2026-11-04 R15d 판)

~~`flutter test` **193**(R14 test-only 병합본 `14d6374` 실측 · 2026-11-02 · 178 + 15 — `shell_scaffold_test` 24→28 · `shell_router_test` 18→19 · `ops_rhythm_test` 15→18 · `ops_home_test` 35→39 · `alert_center_test` 24→25 · `alert_detail_test` 13→14 · `watchdog_board_test` 8→9(파일별 = PR 본문 · 합계만 실측) · 테스트 파일만 · lib·픽스처·PNG·fakes 0) · 골든 PNG **40장**(그대로 · `git ls-tree` 실측) · 🏁 R14 2장 완료 + ✅ 통합 담당 test-only PR #89(C4r13a-3 · C4r13b-4 · C4r14a-1 · C4r14b-4 = ✅ 전부 · 근거 변이 16 SURVIVED → KILLED · 탐침 4 KILLED · 기존 테스트 수정 0 · 설계 12 §3 «R14 test-only PR 묶음») → 다음 셸 카드 = R15(조립 전 · 설계 12 §6 10).~~(2026-11-02 R14 test-only 판)

~~`flutter test` **178**(R14b 병합본 `afe3e1d` 실측 · 2026-10-31 · 164 + R14b 14 — `watchdog_board_test` +8 · `w01_golden` +6 · 경우 for 를 testWidgets 안에 묶은 꼴(경우 19·단언 전부 · 카드 계획 +19/+189 와 다름 = 기록만 C4H-11)) · 골든 PNG **40장**(`git ls-tree` 실측 · 34 + `w01_*` 6 · `test/golden/README.md` «🆕 R14») · 🏁 R14 2장 완료 — 다음 = 통합 담당 R14 test-only PR(테스트 파일만 · lib·픽스처·PNG·fakes 무수정 · 설계 12 §3 «R14 test-only PR 묶음»: C4r13a-3 = 셸·리듬 참고 변이 6꼴(iosViewer 셸 배치 · opener 경유 음성 링크 · T02-03 route/dDay null 따로 · 사이드바 `ListTile.selected` · TS-02 `Badge.label` null) · C4r13b-4 = `ops_home` T01-09 today_stale «항상» 블록 전부 · valueThenFail · C4r14a-1 = `alert_center_test` N01-07 `failed_then_accepted` 한 경우 · `alert_detail_test` N02-02 operator 주입 · C4r14b-4 = `watchdog_board_test` W01-05 `stale_holiday` · 배너 dy < `w01-received` · 값 쥔 채 다시 읽기) → 다음 셸 카드 조립.~~(2026-10-31 R14b 판)

~~`flutter test` **164**(R14a 병합본 `185e9c7` 실측 · 2026-10-31 · 117 + R14a 47 — `alert_center_test` +24 · `alert_detail_test` +13 · `n01_golden` +6 · `n02_golden` +4) · 골든 PNG **34장**(`git ls-tree` 실측 · 24 + `n01_*` 6 + `n02_*` 4 · `test/golden/README.md` «🆕 R14») · R14 2장 중 1장 완료 — 다음 셸 카드 = R14b-Bob-W01(`W-01` 워치독 · ▶ `docs/ai-context/send/R14b-Bob-W01.md` 「푸시해」 뒤 · 끝 기대 189 · 골든 +6 · «정확히 N» 소유) · 그 뒤 통합 담당 R14 test-only PR(C4r13a-3 · C4r13b-4 · C4r14a-1 = `alert_center_test` N01-07 `failed_then_accepted` 한 경우 · `alert_detail_test` N02-02 operator 주입).~~(2026-10-31 R14a 판)

~~`flutter test` **117**(R13b 병합본 · `origin/main` `49e4329` · 66 + 51 — 패키지 트리 = C4 수정안 · C4·드라이런 실측) · 골든 PNG **24장**(`test/golden/README.md` «🆕 R13») · 🏁 R13 2장 완료 · 다음 셸 카드 = R14(알림 · 설계 12 §6 · 조립 전).~~(2026-10-27 R13b 판)

- `ShellRoot` · `ShellBandOverlay` = `lib/src/shell_scaffold.dart`(폰 5탭 · 웹 사이드바 · 띠).
- 라우터 = `lib/src/routing/shell_router.dart`(`AppRoutes.all` 69 정적 등록 — 🆕 계약 v1.17 `opsRunbooks`·`opsRunbook`·`opsEmergencyCard`·`opsDeviceRisk`·`handbookIndex`(`opsRhythm` 뒤 · 가드 = 기본 open) · v1.16 온보딩 6(`onboardingStep` 앞)·`ledgerSimOpening`·`m5SimOpeningCash`·X1 2 · v1.15 `alertsInbox`·`alertDetail` · 가드 · `ShellLinkOpener` · `shellLinkOpenerProvider`).
- `OpsRhythm` = `lib/src/ops_rhythm.dart`(`H-02` · `watchRhythm()` 1구독).
- `OpsHome` = `lib/src/ops_home.dart`(`H-01` · 블록 1~9b · 구독 6 · 홈 탭 연결 = 레지스트리 `home` 칸 · 조립 앱 몫).
- 🆕 `AlertCenter` · `AlertDetail` = `lib/src/alerts/alert_center.dart` · `alert_detail.dart`(`N-01` 알림 센터 · `N-02` 알림 상세 · R14a PR #87 `185e9c7` · 원천 `watchCenter(p0Only:)` · `watchAlert(alertId)` · 정렬·그룹·접힘 = 엔진) · 공용 조각 `AlertAckBlock` = `alert_ack.dart`(배럴 밖 · 쓰기 `acknowledgeAlert` 1종) · 주입 `shellAlertCommandApiProvider`(뷰어 null = 확인 버튼 부재) · 셸 연결 = 레지스트리 칸(조립 앱 몫).
- 🆕 `WatchdogBoard` = `lib/src/watchdog_board.dart`(`W-01` 워치독 상태 · R14b PR #88 `afe3e1d` · 원천 `watchWatchdog()` 1구독 → `WatchdogBoardVm`(머리 «마지막 수신» · 하단 휴장·한계 고지) · 상태 모양 = `level` · `checkId` 미참조 · 슬러그·ping URL·키 = 계약에 0 · 새 주입 0(`shellOpsStatusRepositoryProvider` 그대로) · 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 🆕 `OnboardingStart` · `OnboardingModePick` = `lib/src/onboarding/onboarding_start.dart` · `onboarding_mode_pick.dart`(`O-00` 첫 실행 3갈래 · `O-00b` 운영 방식 선택 · R15a PR #99 `940082c` · 원천 `watchStart()` · `watchModeChoice()` · 쓰기 `run(onboardingOperatingModeSelect)` 1종 · 기본값 없음(고른 표시 = `selected` 비교 하나) · 순서 = 엔진 링크(`deepLink` · `nextDeepLink`) · 주입 `shellOnboardingRepositoryProvider` · `shellOnboardingActionsProvider`(뷰어 null = 탭 부재) · 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 🆕 `OnboardingStepList` · `OnboardingStepDetail` = `lib/src/onboarding/onboarding_step_list.dart` · `onboarding_step_detail.dart`(`O-01` 단계 목록 · `O-02` 단계 상세 · `O-03` 검증 결과(상세 안 결과 조각) · R15b PR #103 `a79f620` · 원천 `watchStepList()` · `watchStep(stepId)` · 검증 = VM 이 준 `run(verify.id, args)` · 판정·게이트 = 엔진(`GateState` 4값 · `unknown` ≠ `notApplicable`) · 🆕 새 주입 `shellOnboardingSlotBuilderProvider`(`SecretField` = M9 슬롯 · 뷰어·미주입 null = 자리 부재) · `whereText` = 글자만 · 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 🆕 `OnboardingFinish` = `lib/src/onboarding/onboarding_finish.dart`(`O-04` 온보딩 마무리 6단계 · R15c PR #107 `0e96ed3` · 원천 `watchFinish()` · 단계 = 받은 차례·열림 그대로(건너뛰기·«n/6» 0 · `state` 비교 0) · 새 주입 0 · 🔒 자리 = R15b 슬롯 빌더(서약문·생체·셀프테스트·체크섬) · 단계 동작 = VM 이 준 `run(action.id, args)` · 시작 상태 선언 = ⑥ 단계 링크 · 완료 체크 = 서버 판정 글자 · 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 🆕 `OnboardingRestart` · `ViewerPairing` = `lib/src/onboarding/onboarding_restart.dart` · `viewer_pairing.dart`(`R-01` 기존 계정에서 다시 시작 · `V-01` 조회 전용 QR 페어링 · R15d PR #110 `4b31603` · 원천 `watchRestart()` · 🆕 주입 `shellPairingRepositoryProvider` → `watchPairing()` · 분기 = 받은 링크(세기·고르기·거르기 0 · 갭 일수 판정 0 · X1 마법사 = 링크로 넘기기만) · 리스 게이트 3상(모름 = 차단 모양) · 🔒 로그인·스캔 = 슬롯 빌더 `place(slotId)` · 결과 = 원문 코드(`reasonCode`) · 발급·폐기 버튼·수동 입력 0 · 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 🆕 `IncidentBannerSlot` · `RunbookList` · `RunbookDetail` · `EmergencyStopCard` = `lib/src/incident/incident_banner.dart` · `runbook_list.dart` · `runbook_detail.dart` · `emergency_stop_card.dart`(`D-01` 장애 배너 · `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드 · R16a PR #126 `1e113ef` · 원천 `watchIncident()` · `watchRunbookIndex()` · `watchRunbook(runbookId)` · `watchEmergencyCard()` · 배너 = 엔진이 고른 0/1건 · 닫기·스와이프 0 · 조치 = 받은 링크 · 런북 «확인» 체크 = 화면 로컬 상태(저장·명령 0) · 인쇄 = 플랫폼 슬롯 빌더 · 셸 틀 = `shell_scaffold.dart` `_PhoneHome` · `_WebBody` 의 `body:` 두 곳(`Column[IncidentBannerSlot(), Expanded(IndexedStack)]`) · 🆕 새 주입 3(`shellIncidentRepositoryProvider` 기본 null = 배너 부재 · `shellRunbookRepositoryProvider` 기본 throw · `shellOpsSlotBuilderProvider` 기본 null = 인쇄 자리 부재) · 라벨 0 · D-02·D-03 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 🆕 `HandbookContents` · `HandbookPageView` = `lib/src/handbook/handbook_contents.dart` · `handbook_page_view.dart`(`B-01` 전략 핸드북 목차 · `B-02` 핸드북 페이지 · R16b PR #132 `8af4722` · 원천 `HandbookRepository.watchIndex()` · `watchPage(anchor)` · 항목·블록 = 받은 차례 · 수 그대로(8 리터럴 0) · 상태 = 아이콘·색 + 엔진 글자 · 뒤처짐 = 엔진 `outdatedNotice` 맨 위(숨김·닫기 0 · 화면 config_hash 비교 0) · 모르는 앵커 = `missingLabel` · 링크 = 받은 `deepLink`(화면 `handbook://` 조립 0) · live 페이지 = asOf 머리 + 오래됨 배너(시계 판정 한 곳) · 셸 핸드북 자리 두 곳(`s01-handbook-slot` · `s02-handbook-slot` · 같은 Key 바깥 상자) · 🆕 새 주입 1(`shellHandbookRepositoryProvider` 기본 null = 자리표시자) · 라벨 0).
- 🆕 `DeviceRiskBoard` = `lib/src/device_risk_board.dart`(`H-03` 물리 리스크 점검 상세 · R16c PR #135 `4db3ddf` · 원천 `shellOpsStatusRepositoryProvider.watchDeviceRisk()` 한 곳 · asOf 머리 `ShellAsOfHeader` 맨 위 · 오래됨 `ShellStaleBanner`(W-01 식 한 곳 · `shellClockProvider`) · 행 = 엔진 글자 다섯 칸(`label` · `currentText` · `thresholdText` · `actionText` · `lastCheckedText`) · 등급 = 받은 `UiLevel` 로 아이콘·색만 · 빈 = 엔진 `emptyLabel` · 맨 아래 안내 = 엔진 `guidanceText` · 조작 버튼·탭 자리 0 · 새 주입 0 · 라벨 0 · 셸 배선 0 · 배럴 +1).
- 공통 조각 = `lib/src/common/shell_common.dart`(`ShellAsOfHeader` · `ShellStaleBanner` · `ShellSkeleton` · `ShellErrorView` · `ShellPlaceholder`).
- 주입 = `lib/src/shell_providers.dart`(🆕 R13b 주입 5 = 파일 끝 절 · 🆕 R15d `shellPairingRepositoryProvider`(기본값 throw · 실물 = 조립 앱) · 🆕 R16a 주입 3(파일 끝 R16a 절) · 🆕 R16b 주입 1(`shellHandbookRepositoryProvider` · 파일 끝 R16b 절) · 주입 23 · 조립 앱 3종이 override · 본문 레지스트리 `ShellRouteBodies` 의 69 패턴·`home` 칸 = 조립 앱 몫).
- 테스트 가짜 = `test/shell_fakes.dart` — 🆕 계약 v1.15 부터 전부 `extends Unimplemented…`(받침대 `UnimplementedAlertRepository`·`UnimplementedOpsStatusRepository` · 구 `implements` 가짜 2 → `extends` · 테스트 수 불변) · 🆕 R14b `FakeShellWatchdogRepository`(`extends UnimplementedOpsStatusRepository`) · 🆕 R16a `FakeShellIncidentRepository` · `FakeShellRunbookRepository`(`extends UnimplementedIncidentRepository` · `UnimplementedRunbookRepository`) · 🆕 R16b `FakeShellHandbookRepository`(`extends UnimplementedHandbookRepository`) · 🆕 R16c `FakeShellDeviceRiskRepository`(`extends UnimplementedOpsStatusRepository` · `watchDeviceRisk` 만 덮음).
- 정적 라벨 = `lib/l10n/labels.dart`(`ShellLabels` 37 = R13a 25 + R13b 6 + R14a 4 · R14b 0 · R15a 2(`onboardingNext` · `onboardingNotAccepted`) · R15b~R16c 0).
