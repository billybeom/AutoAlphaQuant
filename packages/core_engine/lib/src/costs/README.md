# `lib/src/costs/` — 거래비용 · 보유비용

정본: `06_시스템설계/03_알고리즘.md` §5-6(거래비용 · 참여율) · §5-7(보유비용) · `02_데이터모델.md` §4 `costs` · 05 GV-11 · GV-19 · GV-24

- 🔴 `total = commission + tax + slippage + market_impact` — 시장충격을 뺀 합계를 만들지 않는다(02 §3 불변식).
- 🔴 슬리피지 구간은 `min_adv` 내림차순 · `adv20 >= min_adv` 인 첫 구간. `min_adv: 0` 구간이 없는 설정은 받지 않는다.
- 🔴 국내상장 ETF 매도세는 `etf_tax_rate_sell`(0) — P0S 주문은 전부 ETF 다. 개별주 세율 `tax_rate_sell` 은 제도 종속 값이라 설정에서만 읽는다.
- 🔴 미국 비용식은 명세에 없다 → `UnimplementedError`(fail-closed). P0S 에 미국 주문이 없다.
- 🔴 보유비용(총보수)은 **백테스트 전용**이다 — 실거래 경로에서 부르면 시세에 이미 든 보수를 두 번 뺀다.
- 🔵 화면용 `CostEstimate`(domain_contracts · 문자열 포함)로 옮기는 일은 읽기 경로(M3-1) 몫이다. 여기는 숫자만 낸다.
