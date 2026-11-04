# KIS 응답 픽스처 — 실험 5 실응답(설계 13 §8 R29 L10 · R23 D11)

- 출처: 실험 5(2026-10-29 00:41 KST · 발주자 모의 앱키 · 모의 서버 `openapivts.koreainvestment.com:29443`).
  보존본 = 설계 저장소 `11_앱설계/tool/kis-exp5/results/20261029_004112/fixtures/` · 결과 = `06_시스템설계/07_검증원장.md` §6-2.
- **응답 본문만** 담았다. 요청 헤더(앱키·시크릿·토큰)와 계좌번호는 없다. 실험 스크립트가 쓰기 전에 비밀값을 훑었고, Claude 가 한 번 더 훑었다.
  잔고 응답은 담지 않았다(→ 🆕 `orders/balance_balance.json` · 실험 278 판 3 · E10g).
- 손으로 고치지 않는다. 꼴이 바뀌면 실험 스크립트로 다시 받아 통째로 바꾼다.

| 파일 | 요청 |
|---|---|
| `kr_daily_133690_adj0.json` · `_adj1.json` | 국내 일봉 `FHKST03010100` · `133690` · `FID_ORG_ADJ_PRC` 0(수정) · 1(원) · 2026-06-02~10-28 100행 |
| `kr_daily_0085P0_adj0.json` | 같음 · 영문 섞인 종목코드 `0085P0` |
| `kr_price_133690.json` | 국내 현재가 `FHKST01010100` |
| `kr_index_daily_1001_recent.json` | 국내 지수 일봉 `FHKUP03500100` · KOSDAQ `1001` · 50행(한 번에 50) |
| `kr_holiday.json` | 휴장일 `CTCA0903R` — 모의 미지원(HTTP 500 · `EGW02006`) |
| `us_daily_SPY_modp0_latest.json` · `_modp1_latest.json` | 해외 일봉 `HHDFS76240000` · `AMS` · `SPY` · `MODP` 0(원) · 1(배당 수정) |
| `us_daily_RSP_modp1_latest.json` | 같음 · `RSP` · `MODP=1` |
| `us_index_daily_spx_recent.json` | 해외 지수 일봉 `FHKST03030100` · `N`/`SPX` — 🔴 거래량 `acml_vol` 전부 `0` |

## 🆕 `orders/` — 실험 2·7·8 실응답(E10d · 설계 13 §8 R37 Y9)

- 출처: 실험 2·7·8(2026-10-29 장중 `open` · 장후 `post` · 10-30 장전 `pre` · 다음 날 `next` · 발주자 모의 앱키 · 133690 1주).
  보존본 = 설계 저장소 `11_앱설계/tool/kis-exp278/results/*/fixtures/` · 결과 = `06_시스템설계/07_검증원장.md` §6-3. 파일 이름 = `{단계}_{원래 이름}`.
- **응답 본문만**(HTTP 상태는 없다 — `post_resv_order.json` 은 HTTP 500 · `EGW02006`). 계좌 · 연락처 · IP 칸은 비어 있거나 가렸다(훑음 2회).
- 🔴 주문번호 · 지점은 **가림 자리표시** `<주문번호#n>` · `<지점#n>` 이다 — 번호는 **실행(단계)마다 따로** 매겨진다(open 의 원주문 자리 `#7` · next 의 같은 자리 = `#2`).
  시험은 `test/kis_orders_test.dart` 의 치환기로 숫자(10자리 · 5자리)로 바꿔 읽는다 — 파일은 고치지 않는다.
- ⚠️ `open_ccld_e2_buy.json` · `open_ccld_e2_sell.json` 은 `output1` **한 행 발췌**다(`rt_cd` · `output2` 없음 — 전체 본문 아님).
- 신규 주문 행의 `orgn_odno` 는 전부 같은 자리표시다(의미 없음 — 취소 행에서만 원주문을 가리킨다 · 07 §6-3).

| 단계 | 파일 | 응답 |
|---|---|---|
| open | `order_buy_*` · `order_sell_e2-sell` | 매수 `40600000` · 매도 `40590000` · `output` = `KRX_FWDG_ORD_ORGNO` · `ODNO` · `ORD_TMD` |
| open | `cancel_e7-1~3` | 취소 `40630000` — 새 주문번호 |
| open | `ccld_*` | 일별주문체결조회 — 원주문 행 + «매수취소» 행(`cncl_yn=Y`) · 누적 체결 |
| post | `order_buy_post` · `resv_order` · `ccld_*` | 장 마감 뒤 지정가 `40580000` · 예약주문 `EGW02006` · 남긴 주문 잔여 1 |
| pre | `order_buy_pre` · `cancel_pre` | 장전 08:32 지정가 접수 → 바로 취소 |
| next | `cancel_next-prevday` · `ccld_next_*` | 전날 주문 취소 `40320000` · 전날 행 잔여 1 그대로 · 오늘 조회엔 없음 |
| 🆕 balance | `balance_balance` | 잔고 `VTTC8434R` `20310000` — 실험 278 **판 3** `--phase balance`(2026-11-04 01:07 · 주문 0) · `output1` = **빈 목록**(보유 0주) · `output2` 1행(`dnca_tot_amt` = `prvs_rcdl_excc_amt` = 49,999,965) · 이어받기 머리 빈칸(E10g · R41) |
| 🆕 held | `held_balance_held` | 잔고 `VTTC8434R` `20310000` — 실험 278 **판 4** `--phase held`(2026-11-04 09:23 · 133690 1주 매수 체결 직후 · 곧 되팔아 0주로 되돌림) · `output1` **한 행**(`pdno` `133690` · `hldg_qty` `1` · 칸 26개) · `output2` `dnca_tot_amt` 49,999,965(D+0 · 매수 전과 같음) · `prvs_rcdl_excc_amt` 49,832,955(D+2 · 매수 166,990 + 수수료 20 만큼 줄었다) |
