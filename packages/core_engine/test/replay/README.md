# `test/replay/` — E6 엔진 재현(전략 4자리 대조)

정본: 설계 저장소 `11_앱설계/13_엔진레인_착수계획.md` §2 E6 · `06_시스템설계/05_수용기준_골든벡터.md` §GV-P0S ·
참조 엔진 `09_백테스트/백테스트6/engine/`(`Config(preset="P0S")`) · 정답 `runs/N2_golden/golden_p0s.json`

🔵 **시험 전용**이다 — 백테스트 입력·합성 시세·모의 체결은 앱(`lib/`)에 넣지 않는다. 규칙(신호·배분·밴드·한도)은
`lib/` 의 함수를 그대로 부른다(실전과 같은 코드 경로).

| 파일 | 담는 것 |
|---|---|
| `data/*.csv.gz` · `data/MANIFEST.json` | 참조 엔진 `engine/data.py::load_all` 이 읽는 원천 CSV 24개 — 바이트 그대로 gzip(`tool/freeze_replay_data.py` · 발주자 결정 2026-10-20 · 설계 13 §8 R3). 원본 sha256 은 MANIFEST |
| `fixtures/parse_parity.json` | pandas 3.0.6 이 읽은 열별 float64 해시(`tool/export_replay_parity.py`) |
| `replay_csv.dart` | 번들 읽개 — 🔴 pandas `precise_xstrtod` 와 같은 수 변환(정확 반올림 `double.parse` 와 최대 2 ULP 다르다) |
| `replay_market.dart` | 시장 번들 — 환율(FRED 우선) · 세션 = **데이터 날짜**(US 6,694 · KR 6,561 · 합집합 6,900) · 월말 320/320 · 월 끝 3세션 · 슬리브 B 원화 지수(133690 = QQQ ← ^NDX 소급 · 411060 = 금 선물 · 한국 세션 = 엄격히 앞선 미국 종가) · 원화 현금 지수 · UST10 · 금 USD · 가격 패널 · 월봉 |
| `replay_regime.dart` | 국면 재현 — 외부 시리즈 발표 지연(ofr_fsi 1 · nfci 7 · cfnai 55 · t10y3m 1 · sahm 40 달력일) 정렬만 여기서, 계산은 `lib/src/signals/` 를 그대로 |
| `fixtures/regime_parity.json` | 참조 엔진 `regime.py` 산출의 해시·표본(`tool/export_replay_regime.py`) — 정규화 이후 비트 일치 · FSM 은 03 방식이라 1985-11-14~26 9봉만 다름 |
| `replay_engine.dart` | 장부 재현 — 참조 엔진 `backtest.py` P0S 일별 루프를 **같은 연산 순서의 double** 로: 보유비용(세션마다 수량 × (1 − ER×1.15/252)) · 평가 · 브레이커 · 체결(B·C — 매수 슬리피지는 체결가에 · 원장 비용은 «보고») · 램프 · 코어 밴드(재분류 · 환원 · 납입 · B 조달 매도) · B 트랜치(numpy 짝 합산 평균) · C 리밸런싱 · 스냅숏. E6d 몫(계절 A · POT · 조달 `_take_krw`)에 닿으면 멈춘다 |
| `fixtures/s7_engine.json.gz` | 참조 엔진 S7(P0S 정본) 실행의 원장 934행 · 일별 6,900행(`tool/export_replay_engine.py` — 골든 생성기와 같은 설정 · 캐시 번들 읽기만) |
| `fixtures/market_parity.json` | 참조 엔진 `market.build` 본문 + `apply_p0_market` + `Backtest._prep` 산출의 해시·표본 값(`tool/export_replay_market.py`) — 전부 비트 일치 |

🔴 데이터·정답지를 손으로 고치지 않는다 — 원본이 바뀌면 두 도구를 다시 돌리고 해시를 갱신한다.
🔴 저장소는 비공개여야 한다(원천 = Yahoo·FRED·FDR 공개 시세의 재현용 사본).
