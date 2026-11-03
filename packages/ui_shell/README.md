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

## 지금 상태 — ✅ S-01·S-02 셸 · H-02 운영 리듬 · H-01 운영 홈 · N-01·N-02 알림 · W-01 워치독 병합(2026-10-31 · R13a PR #71 `315bbbd` · R13b PR #74 `49e4329` · R14a PR #87 `185e9c7` · R14b PR #88 `afe3e1d` · 🏁 R14 · ✅ R14 test-only(PR #89 squash `14d6374`))

`flutter test` **193**(R14 test-only 병합본 `14d6374` 실측 · 2026-11-02 · 178 + 15 — `shell_scaffold_test` 24→28 · `shell_router_test` 18→19 · `ops_rhythm_test` 15→18 · `ops_home_test` 35→39 · `alert_center_test` 24→25 · `alert_detail_test` 13→14 · `watchdog_board_test` 8→9(파일별 = PR 본문 · 합계만 실측) · 테스트 파일만 · lib·픽스처·PNG·fakes 0) · 골든 PNG **40장**(그대로 · `git ls-tree` 실측) · 🏁 R14 2장 완료 + ✅ 통합 담당 test-only PR #89(C4r13a-3 · C4r13b-4 · C4r14a-1 · C4r14b-4 = ✅ 전부 · 근거 변이 16 SURVIVED → KILLED · 탐침 4 KILLED · 기존 테스트 수정 0 · 설계 12 §3 «R14 test-only PR 묶음») → 다음 셸 카드 = R15(조립 전 · 설계 12 §6 10).

~~`flutter test` **178**(R14b 병합본 `afe3e1d` 실측 · 2026-10-31 · 164 + R14b 14 — `watchdog_board_test` +8 · `w01_golden` +6 · 경우 for 를 testWidgets 안에 묶은 꼴(경우 19·단언 전부 · 카드 계획 +19/+189 와 다름 = 기록만 C4H-11)) · 골든 PNG **40장**(`git ls-tree` 실측 · 34 + `w01_*` 6 · `test/golden/README.md` «🆕 R14») · 🏁 R14 2장 완료 — 다음 = 통합 담당 R14 test-only PR(테스트 파일만 · lib·픽스처·PNG·fakes 무수정 · 설계 12 §3 «R14 test-only PR 묶음»: C4r13a-3 = 셸·리듬 참고 변이 6꼴(iosViewer 셸 배치 · opener 경유 음성 링크 · T02-03 route/dDay null 따로 · 사이드바 `ListTile.selected` · TS-02 `Badge.label` null) · C4r13b-4 = `ops_home` T01-09 today_stale «항상» 블록 전부 · valueThenFail · C4r14a-1 = `alert_center_test` N01-07 `failed_then_accepted` 한 경우 · `alert_detail_test` N02-02 operator 주입 · C4r14b-4 = `watchdog_board_test` W01-05 `stale_holiday` · 배너 dy < `w01-received` · 값 쥔 채 다시 읽기) → 다음 셸 카드 조립.~~(2026-10-31 R14b 판)

~~`flutter test` **164**(R14a 병합본 `185e9c7` 실측 · 2026-10-31 · 117 + R14a 47 — `alert_center_test` +24 · `alert_detail_test` +13 · `n01_golden` +6 · `n02_golden` +4) · 골든 PNG **34장**(`git ls-tree` 실측 · 24 + `n01_*` 6 + `n02_*` 4 · `test/golden/README.md` «🆕 R14») · R14 2장 중 1장 완료 — 다음 셸 카드 = R14b-Bob-W01(`W-01` 워치독 · ▶ `docs/ai-context/send/R14b-Bob-W01.md` 「푸시해」 뒤 · 끝 기대 189 · 골든 +6 · «정확히 N» 소유) · 그 뒤 통합 담당 R14 test-only PR(C4r13a-3 · C4r13b-4 · C4r14a-1 = `alert_center_test` N01-07 `failed_then_accepted` 한 경우 · `alert_detail_test` N02-02 operator 주입).~~(2026-10-31 R14a 판)

~~`flutter test` **117**(R13b 병합본 · `origin/main` `49e4329` · 66 + 51 — 패키지 트리 = C4 수정안 · C4·드라이런 실측) · 골든 PNG **24장**(`test/golden/README.md` «🆕 R13») · 🏁 R13 2장 완료 · 다음 셸 카드 = R14(알림 · 설계 12 §6 · 조립 전).~~(2026-10-27 R13b 판)

- `ShellRoot` · `ShellBandOverlay` = `lib/src/shell_scaffold.dart`(폰 5탭 · 웹 사이드바 · 띠).
- 라우터 = `lib/src/routing/shell_router.dart`(`AppRoutes.all` 64 정적 등록 — 🆕 계약 v1.16 온보딩 6(`onboardingStep` 앞)·`ledgerSimOpening`·`m5SimOpeningCash`·X1 2 · v1.15 `alertsInbox`·`alertDetail` · 가드 · `ShellLinkOpener` · `shellLinkOpenerProvider`).
- `OpsRhythm` = `lib/src/ops_rhythm.dart`(`H-02` · `watchRhythm()` 1구독).
- `OpsHome` = `lib/src/ops_home.dart`(`H-01` · 블록 1~9b · 구독 6 · 홈 탭 연결 = 레지스트리 `home` 칸 · 조립 앱 몫).
- 🆕 `AlertCenter` · `AlertDetail` = `lib/src/alerts/alert_center.dart` · `alert_detail.dart`(`N-01` 알림 센터 · `N-02` 알림 상세 · R14a PR #87 `185e9c7` · 원천 `watchCenter(p0Only:)` · `watchAlert(alertId)` · 정렬·그룹·접힘 = 엔진) · 공용 조각 `AlertAckBlock` = `alert_ack.dart`(배럴 밖 · 쓰기 `acknowledgeAlert` 1종) · 주입 `shellAlertCommandApiProvider`(뷰어 null = 확인 버튼 부재) · 셸 연결 = 레지스트리 칸(조립 앱 몫).
- 🆕 `WatchdogBoard` = `lib/src/watchdog_board.dart`(`W-01` 워치독 상태 · R14b PR #88 `afe3e1d` · 원천 `watchWatchdog()` 1구독 → `WatchdogBoardVm`(머리 «마지막 수신» · 하단 휴장·한계 고지) · 상태 모양 = `level` · `checkId` 미참조 · 슬러그·ping URL·키 = 계약에 0 · 새 주입 0(`shellOpsStatusRepositoryProvider` 그대로) · 셸 연결 = 레지스트리 칸(조립 앱 몫)).
- 공통 조각 = `lib/src/common/shell_common.dart`(`ShellAsOfHeader` · `ShellStaleBanner` · `ShellSkeleton` · `ShellErrorView` · `ShellPlaceholder`).
- 주입 = `lib/src/shell_providers.dart`(🆕 R13b 주입 5 = 파일 끝 절 · 조립 앱 3종이 override · 본문 레지스트리 `ShellRouteBodies` 의 64 패턴·`home` 칸 = 조립 앱 몫).
- 테스트 가짜 = `test/shell_fakes.dart` — 🆕 계약 v1.15 부터 전부 `extends Unimplemented…`(받침대 `UnimplementedAlertRepository`·`UnimplementedOpsStatusRepository` · 구 `implements` 가짜 2 → `extends` · 테스트 수 불변) · 🆕 R14b `FakeShellWatchdogRepository`(`extends UnimplementedOpsStatusRepository`).
- 정적 라벨 = `lib/l10n/labels.dart`(`ShellLabels` 35 = R13a 25 + R13b 6 + R14a 4 · R14b 0).
