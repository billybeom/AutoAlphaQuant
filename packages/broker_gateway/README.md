# broker_gateway — M1 브로커 게이트웨이 (KIS)

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M1** engine-runtime(브로커 경계)
> **정본**: `06_시스템설계/04_안전장치.md`(주문 게이트·NR-1) · `01_모듈_인터페이스.md`

## 무엇을 담나

KIS 접근토큰 수명 관리 · 유량(rate) 제어 · **멱등 주문 발주** · 체결/잔고 조회 · 일일 대사 입력.

**멱등키**는 `v1|{market}|{account}|{symbol}|{side}|{decision_id}`이다(NR-1). 같은 결정이 두 번 주문되지 않게 하는 브로커 주문 식별자이며, `decision_id`는 시각·UUID·난수를 넣지 않는 **결정론적 생성 규칙**을 따른다.

## 의존 — 허용

`domain_contracts` · `core_engine` · 🆕 `http`(E8d2a · 01 §1-1 v1.14 허용 — data_sync 와 같은 클라이언트 하나 · `dio` 아님) · 🆕 `decimal`(E10d — core 주문 포트의 금액 타입 · ⏸ 01 §1-1 개정은 다음 계약 창 · 설계 13 §8 R37 Y1).

## 의존 — 🔴 금지

`ui_journal` · `ui_analytics` · `ui_shell` · `ui_settings` · `ui_safety`.

## 이 패키지가 지는 규칙 3개

1. **주문의 유일한 통로다.** 다른 패키지가 브로커 API를 직접 부르면 유량 제어와 멱등키가 우회된다.
2. **웹·데스크탑 타깃에서는 빌드에서 제외**된다(경계 규칙 ③ · 결정 6). 뷰어는 킬스위치 «발동만» 할 수 있고 주문 경로는 아예 없다.
3. **`status = prevented`는 실패가 아니라 성공이다** — 이중 발주 차단이 작동한 것이며 화면에도 그렇게 렌더된다(01 §2-2).

## ⚠️ 착수 전 실측 1건

**KIS 앱키를 새로 발급하면 기존 접근토큰(24h)이 살아 있는가.** X1(기기 이전) 착수 전 필수이며 결과는 `06_시스템설계/07_검증원장.md`에 기록한다. 실측 전에는 X1의 토큰 처리 분기를 확정하지 않는다.

## 🆕 KIS REST 핵심 · 시세(E8d2a · 설계 13 §8 R29)

- `KisEnvironment`(mock · live — 도메인·유량 간격) · `KisCredentials`(키 세트가 환경을 **지닌다** · 클라이언트 환경과 다르면 요청 전에 거절 = 잘못된 키 세트로 실전 전환 차단 · `toString` 가림)
- `KisTokenStore`(메모리 · 파일 — 키 금고 M4-4 전 · 저장소 밖) · 만료 5분 전 새로 · 발급 1분 1회(`EGW00133`)는 다시 보내지 않음
  - 🆕 **E11d — 보관 키 = `KisTokenKey`(환경 · 앱키 지문)**(설계 13 §8 R44 E8 · X11) — 같은 환경 두 계좌(실전 · ISA)가 서로 덮지 않는다 · 파일 칸 = `환경:지문`(옛 칸은 안 읽는다 → 1회 재발급) · `VaultKisTokenStore`(core `SecretVault` 한 칸 `kis.tokens` · 기동 때 메모리로 · 쓰기 = 메모리 즉시 + 금고 비동기 순서 보존 · 금고 실패는 센다 · 던지지 않는다)
- `KisRateGate` — 앱키 하나에 하나(주문 E10 과 나눠 쓴다) · 모의 1.1초 · 실전 1/18초 · 신규 키 `kKisNewKeyInterval`
- `KisRestClient.get` — 조회만 1 → 2 → 4초 최대 3회(유량 코드 · 429 · 502~504 · 비JSON 500 · 시간 초과 · 연결 실패) · 업무 거절은 그대로 · 토큰 무효면 새 토큰으로 1회 · 다 쓰면 `KisUnavailable` · 오류에 주소·키·계좌·토큰 없음
- `KisQuotes` — 시세 6종(실험 5 확정 TR · 07 §6-2): 국내 일봉(수정/원) · 현재가 · 국내 지수 일봉(50행) · 해외 일봉(MODP 원/수정) · 해외 지수 일봉(🔴 거래량 0) · 휴장일(모의 미지원) · 범위 조회 = 창 밀기(`pageBack`) · 수 = `pandasPreciseXstrtod`
- 시험 픽스처 `test/fixtures/kis/` = 실험 5 **실응답 본문**(헤더·키·계좌 없음) · 실호출 = `network` 태그(`AAQ_NETWORK=1` · `AAQ_KIS_MOCK_KEY_FILE`)
- 🆕 `KisQuoteFeed`(E8d2b · 설계 13 §8 R30) — core_engine 일봉 원천 포트 구현: 저장 이름 → KIS 코드(`^GSPC` → SPX · `KQ11` → 1001 · `SPY`·`RSP` → AMS · 표 밖 = `ArgumentError`) · 실패 3종 → `QuoteFeedDown` · 쪽 본문·시도 수(`KisQuotes.onPage` · `KisResponse.text`). 원장에 넣는 것은 data_sync `QuoteCollector`(이 패키지는 SQLite 를 모른다)
- 🆕 **E10d — 국내 주문**(설계 13 §8 R37 · 04 §3-3 v2.38 · 07 §6-3):
  - `KisRestClient.postOrder` — 주문 POST 분류는 **값**(`KisOrderAccepted` · `KisOrderRefused` · `KisOrderUnknown`) · 판정 순서 = 전송 예외 → 본문 JSON → 본문 코드(유량 · 토큰 먼저) → HTTP 상태 · 🔴 결과 불명(시간 초과 · 연결 예외 · 5xx · 200 비JSON)은 0회 재시도 · 유량 1→2→4s 3회 의무 · 토큰 무효 1회 · 5xx 는 `EGW02006` 만 거절 · `get` 이어받기(`tr_cont`)
  - `KisTr.of(환경)`(모의 V · 실전 T — TR 은 환경에서만) · `KisOrderBroker`(core `OrderBroker` 구현 · 계좌 한 벌): 매수 · 매도(지정가 `00` · 시장가 `01`) · 취소(그날 체결조회에서 지점 찾기 · 없으면 `ORDER_NOT_FOUND`) · 일별주문체결조회(`parseKisFillRow` → `DailyFillRow` · 10쪽 상한) · 예수금(`prvs_rcdl_excc_amt` · ✅ 모의 실측 2026-11-04 — R41 J8)
  - `KisPrice` 넓힘(기준가 · 호가 · 상하한 · 거래정지) · 픽스처 `test/fixtures/kis/orders/` = 실험 2·7·8 실응답(가림 자리표시 — 시험이 치환) · 시험 F-14b S01~S13(주문 전송 수 · 잠 열)
  - 🔴 실주문 `network` 시험은 없다(실험 278 스크립트가 그 몫 · 실전 키 때 다시)
- 🆕 **E10g — 대사 잔고**(설계 13 §8 R41 · core 포트 `BrokerBalanceSource` · E10f 대사의 짝): `KisOrderBroker.balance()` = 보유(`output1` `pdno` → `hldg_qty` · 종목 합 · 0 은 빼고 · 빠진 칸 = FormatException) + 관측 현금(`dnca_tot_amt` · 없으면 null) · 이어받기 10쪽 상한 · 픽스처 `orders/balance_balance.json` = 실험 278 판 3 실응답(보유 0주 — 여러 행 · 이어받기는 시험 코드가 실응답 본문에 넣는다) · 🆕 `orders/held_balance_held.json` = 실험 278 판 4 실응답(보유 1주 실물 행 · D+0 예수금 그대로 · D+2 만 줄어듦)

## 지금 상태 — 🟢 시세(E8d) · 주문 REST(E10d) · 대사 잔고(E10g) · 토큰 금고 보관(E11d) · 🟡 배선(E11)

배럴과 `lib/src/fake_broker/` 자리만 있다. **⚠️ 이 PC에는 Flutter·Dart·melos가 없다**(2026-09-06).
