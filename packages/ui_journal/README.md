# ui_journal — M6 매매일지 · 보유현황

> **owner(계약·사양)**: Claude · **코드 담당**: **다른 AI(화면)**
> **청사진 카드**: **M6** journal-holdings-ui
> **화면 명세**: `11_앱설계/02_화면명세_M6_매매일지_보유현황.md`(화면 10개)
> **선행 의존**: **M2 계약 확정(G3) + 픽스처 실물(G4)** — 그 전에는 착수하지 않는다

## 무엇을 담나

매매일지 타임라인(첫 과제 **J-1**) · 일지 상세(결정 체인) · 보유현황 목록 · 종목 상세 · 차단 배너.

`H6-1` 보유현황 = `lib/src/holdings_overview.dart`(`HoldingsOverview()` · 주입 `journalHoldingsRepositoryProvider` — 조립 앱 3종이 override · R4b 가 import 해 재사용).

## 의존 — 허용 (01 §1-1)

`domain_contracts` · Flutter · `flutter_riverpod`. **이 셋이 전부다.**

## 의존 — 🔴 금지 (넣으면 C-3이 빌드를 막는다)

`core_engine` · **`decimal`** · `broker_gateway` · `trading_runtime` · `data_sync` · `sqflite` · `supabase_flutter` · `http` · KIS SDK.

> `decimal`이 없어야 화면이 금액 산술을 **아예 할 수 없다**. 있으면 경계 규칙 ①이 코드 리뷰 의존이 된다.

## 금지 4항 (병합 전 검수 항목)

1. **화면에서 재계산 금지** — 수익률·비중·손절선·기여도는 계약이 준 값을 표시만 한다. `.fold`·`.reduce`·`sum`·`DateTime.now()`·`DateTime.difference`가 특히 위험하다.
2. **사유 문구 생성 금지** — 규칙 트리거·청산 티어·거부 사유는 DTO의 `label` 계열 필드를 **그대로** 쓴다. 조건 분기로 문구를 고르는 것도 «생성»이다. 정적 UI 라벨만 `lib/l10n/labels.dart` **한 파일**에.
3. **홈·알림·위젯에 손익 금지** — `HoldingPnl`·`PerformanceSeries`를 타임라인·홈에 렌더하면 C-6이 실패한다. 종목 손익은 **기본 접힘**이고 손익 정렬은 제공하지 않는다.
4. **안전 화면 접근 금지** — 킬스위치·재개 게이트·정정 마법사는 `ui_safety`(Claude 소유)다.

## ✅ 허용되는 안전 관련 렌더 (01 §2-10 표)

경계는 «상태를 보였나»가 아니라 **«상태를 바꾸는 경로를 만들었나»**다.

- 허용: `BlockFlag`의 `label`·`clearInstruction` 배너 + `clearRoute` **딥링크** · `breakerLabel` 한 줄 · `LedgerDiffRow` **읽기 목록·상세**.
- 반려: `killSwitch`·`releaseProgress` 게이지 렌더 · `ResumeReport` **원본 화면** · 플래그 해제·재개·정정 **조작 위젯**.

## 이 패키지가 지는 규칙 3개

1. **정렬·페이징을 만들지 않는다.** rows는 엔진이 이미 정렬해서 준다. 무한 스크롤은 바닥에서 `limit += 100` 재구독이고 `hasMore == false`면 멈춘다.
2. **빈 상태를 지어내지 않는다.** `ListResult`의 `emptyKind`(없음/못 받음/해당 없음)와 `emptyLabel`을 그대로 쓴다.
3. **`prevented`는 실패가 아니라 성공이다** — 이중 발주 차단이 작동한 것이며 그렇게 렌더한다. `unknown`은 «실패»로 단정하지 말고 해소 보드로 딥링크한다.
4. **v2.31 P0S 정합**: 슬리브 칸은 **A/B/C 3칸**이되 그 3을 상수로 알지 않는다 — `SleeveCatalogEntry` 목록에서 온다. 새틀라이트는 «비활성»이 아니라 **숨김**이다.

## 지금 상태 — ✅ J-1~J-5 · H6-1 병합(2026-10-21 · R4a PR #57 `faeb458`)

`flutter test` **322**(R4a 병합본 `faeb458` 실측 · 2026-10-21) · 골든 PNG **82장**(`test/golden/README.md`) · 다음 = R4b(`H6-2` 종목 상세 · `H6-3` 슬리브·비중 — `docs/ai-context/send/R4b-Bob-H62H63.md`).
