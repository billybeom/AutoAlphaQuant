# `lib/src/signals/` — 신호·국면·진입 게이트 (일부 — E1·E2a·E2b)

> 들어온 것: `regime_states.dart`(`DirectionState`·`TrendState` — 히스테리시스를 **거친** 상태) · `exposure_gate.dart`(곱셈 구조 · UNKNOWN = 0 · GV-3·3c) · `indicators.dart`(SMA·TR·rma·ATR·ADX·CHOP·BBW · GV-2 — E2a). `regime_score.dart`(카테고리 가중 평균·재정규화 · GV-1) · `hysteresis.dart`(방향·추세성 FSM 봉 하나씩 · GV-4 — E2b). `sleeve_b_tranche.dart`(B 3-트랜치 · P0S 하한·BEAR 차감 · GV-20 — E5b) · `seasonal_exit.dart`(4월 말 청산 비율 · GV-23·38 — E5b). 백분위 정규화·추세성 스코어 조립은 다음 블록.

정본: `06_시스템설계/03_알고리즘.md` · 전략 수치는 `00_SPEC.md` v2.31 P0S

담을 것: 국면 점수(regime) 판정 · 슬리브별 진입 게이트(계절 창·SMA 트랜치) · 추세/모멘텀 지표 산출.

- 🔴 지표의 **사전 등록 임계값**(`threshold_registered`)과 실제 발동 근거(`trigger_price`)를 결정과 함께 남긴다 — 사후 변경 감사용이다.
- 🔴 `holding_signal_daily.source`가 `BACKFILL`인 행은 **집행 근거가 아니다**(X2).
- 🔵 v2.31 P0S에서 개별주 모멘텀은 소멸했다. 스키마·타입은 유지하되 산출 대상이 거의 없다.
