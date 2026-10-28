# KIS 응답 픽스처 — 실험 5 실응답(설계 13 §8 R29 L10 · R23 D11)

- 출처: 실험 5(2026-10-29 00:41 KST · 발주자 모의 앱키 · 모의 서버 `openapivts.koreainvestment.com:29443`).
  보존본 = 설계 저장소 `11_앱설계/tool/kis-exp5/results/20261029_004112/fixtures/` · 결과 = `06_시스템설계/07_검증원장.md` §6-2.
- **응답 본문만** 담았다. 요청 헤더(앱키·시크릿·토큰)와 계좌번호는 없다. 실험 스크립트가 쓰기 전에 비밀값을 훑었고, Claude 가 한 번 더 훑었다.
  잔고 응답은 담지 않았다.
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
