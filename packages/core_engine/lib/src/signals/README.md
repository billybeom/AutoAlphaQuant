# `lib/src/signals/` — 신호·국면·진입 게이트 (일부 — E1)

> 들어온 것: `regime_states.dart`(`DirectionState`·`TrendState` — 히스테리시스를 **거친** 상태) · `exposure_gate.dart`(곱셈 구조 · UNKNOWN = 0 · GV-3·3c). 지표·히스테리시스 전이는 E2.

정본: `06_시스템설계/03_알고리즘.md` · 전략 수치는 `00_SPEC.md` v2.31 P0S

담을 것: 국면 점수(regime) 판정 · 슬리브별 진입 게이트(계절 창·SMA 트랜치) · 추세/모멘텀 지표 산출.

- 🔴 지표의 **사전 등록 임계값**(`threshold_registered`)과 실제 발동 근거(`trigger_price`)를 결정과 함께 남긴다 — 사후 변경 감사용이다.
- 🔴 `holding_signal_daily.source`가 `BACKFILL`인 행은 **집행 근거가 아니다**(X2).
- 🔵 v2.31 P0S에서 개별주 모멘텀은 소멸했다. 스키마·타입은 유지하되 산출 대상이 거의 없다.
