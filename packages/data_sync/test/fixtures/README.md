# data_sync 시험 픽스처 — 원천 응답 본문(E8c · 설계 13 §8 R23 D11)

- 🔴 **응답 본문만** 둔다. 요청 주소·헤더(키·토큰)는 넣지 않는다 — FRED 주소에는 `api_key` 가 들어간다.
- `fred/<계열>.json` = FRED API `series/observations`(file_type=json) 꼴 · `fred_csv/<계열>.csv` = 키 없는
  `fredgraph.csv` 꼴(머리 칸 이름은 `observation_date`·`DATE` 둘 다 받는다) · `ofr/fsi.csv` = OFR 금융스트레스지수 CSV.
- 🟡 **손으로 쓴 픽스처다**(문서·참조 엔진 `fetch/fetch_market.py` 꼴 기준). 2026-08-14 이하 값은 동결 번들(시드)과
  같은 값이라 «번들 vs 실전 원천» 겹친 날 대조(D9)가 «같음»으로 나와야 한다. 그 뒤 날짜의 값은 **지어낸 값**이다
  (T10Y3M 2026-08-17 `0.85` 만 번들에 있던 실제 값). 첫 실호출(발주자 승인 · `network` 태그 시험) 때 받은 본문으로
  바꾼다.
