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

## 지금 상태 — ✅ S-01·S-02 셸 · H-02 운영 리듬 · H-01 운영 홈 병합(2026-10-27 · R13a PR #71 `315bbbd` · R13b PR #74 `49e4329`)

`flutter test` **117**(R13b 병합본 · `origin/main` `49e4329` · 66 + 51 — 패키지 트리 = C4 수정안 · C4·드라이런 실측) · 골든 PNG **24장**(`test/golden/README.md` «🆕 R13») · 🏁 R13 2장 완료 · 다음 셸 카드 = R14(알림 · 설계 12 §6 · 조립 전).

- `ShellRoot` · `ShellBandOverlay` = `lib/src/shell_scaffold.dart`(폰 5탭 · 웹 사이드바 · 띠).
- 라우터 = `lib/src/routing/shell_router.dart`(`AppRoutes.all` 54 정적 등록 — 🆕 계약 v1.15 `alertsInbox`·`alertDetail` · 가드 · `ShellLinkOpener` · `shellLinkOpenerProvider`).
- `OpsRhythm` = `lib/src/ops_rhythm.dart`(`H-02` · `watchRhythm()` 1구독).
- `OpsHome` = `lib/src/ops_home.dart`(`H-01` · 블록 1~9b · 구독 6 · 홈 탭 연결 = 레지스트리 `home` 칸 · 조립 앱 몫).
- 공통 조각 = `lib/src/common/shell_common.dart`(`ShellAsOfHeader` · `ShellStaleBanner` · `ShellSkeleton` · `ShellErrorView` · `ShellPlaceholder`).
- 주입 = `lib/src/shell_providers.dart`(🆕 R13b 주입 5 = 파일 끝 절 · 조립 앱 3종이 override · 본문 레지스트리 `ShellRouteBodies` 의 54 패턴·`home` 칸 = 조립 앱 몫).
- 테스트 가짜 = `test/shell_fakes.dart` — 🆕 계약 v1.15 부터 전부 `extends Unimplemented…`(받침대 `UnimplementedAlertRepository`·`UnimplementedOpsStatusRepository` · 구 `implements` 가짜 2 → `extends` · 테스트 수 불변).
- 정적 라벨 = `lib/l10n/labels.dart`(`ShellLabels` 31 = R13a 25 + R13b 6).
