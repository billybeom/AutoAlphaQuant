# core_engine — M1(신호·목표비중·한도) · M3(What-if)

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M1** engine-runtime(계산부) · **M3** whatif-service
> **정본**: 전략·규칙은 `06_시스템설계/00_SPEC.md` **v2.32 P0S**(🆕 v1.4 정정 — 구 «v2.31» · v2.32 = 연금 납입 조달 경로 `PENSION_FUNDING`), 등가성 게이트는 `06_시스템설계/05_수용기준_골든벡터.md` · 계약은 `domain_contracts` **v1.4.0**(`WhatIfApi` = 01 §4-1 · §14)

## 무엇을 담나

| 폴더 | 담을 것 |
|---|---|
| `lib/src/signals/` | 국면 판정·진입 게이트·추세/모멘텀 신호 |
| `lib/src/portfolio/` | 슬리브 목표비중·밴드·리밸런싱 수량 산출 |
| `lib/src/risk/` | 청산 티어(TIER 0~3)·손절선·SAF 한도 게이트 |
| `lib/src/costs/` | 거래비용(수수료·세금·슬리피지·시장충격)·참여율 절단·보유비용(백테스트 전용) |
| `lib/src/whatif/` | M3 — 부작용 0의 입금·인출·리밸런싱 미리보기(`WhatIfApi` 구현) |

> ⚠️ 01 §4-1의 주석은 `core_engine/lib/whatif/`로 적혀 있으나 여기서는 `lib/src/whatif/`를 쓴다. 공개 API는 배럴 `lib/core_engine.dart`로만 노출한다 — 경로 차이일 뿐 소유·성격은 같다.

## 의존 — 허용 (01 §1-1)

`domain_contracts` · `decimal` · 🆕 `crypto`(SHA-256 — 멱등키 · 발주자 결정 2026-10-20 · 01 §1-1 개정은 다음 M2 창). **순수 Dart**다.

## 의존 — 🔴 금지

`ui_journal` · `ui_analytics` · `ui_shell` · `ui_settings` · `ui_safety` · Flutter SDK · 브로커 SDK · DB 클라이언트(`sqflite`·`supabase_flutter`).

> 순수 Dart를 유지하는 이유는 취향이 아니다 — 골든벡터를 화면·플랫폼·기기 없이 그대로 돌릴 수 있어야 등가성 게이트가 성립한다.

## 이 패키지가 지는 규칙 3개

1. **Decimal 규약 5조**(01 §1-2 · `01_모듈_인터페이스 §0`)
   ① 금액 × 비율은 비율을 `Decimal.parse(r.toString())`로 승격한 뒤 곱한다
   ② 중간값은 `Decimal`로 계산하고 DTO의 `double` 필드에 담을 때만 `.toDouble()`
   ③ 금액 필드는 끝까지 `Decimal`
   ④ 🔴 **곱셈 먼저, 나눗셈 나중** — `(equity * riskPct) / riskPerShare`
   ⑤ 🔴 `(1 − 비율)`은 Decimal 안에서 — `entry * (Decimal.one - Decimal.parse('0.07'))`
   > **GV-8a는 1 ULP 차이로 판정이 뒤집힌 실측 사례다.** 규약을 어기면 골든이 깨진다.
2. **골든벡터 전량 통과 전에는 DRY_RUN을 벗어나지 않는다**(결정 2). 이 패키지의 Dart 재현이 그 게이트다.
3. **사유 문구는 여기서 만들어진다.** 화면은 만들지 않는다 — 엔진이 `label`·`actionLine` 필드에 실어 보낸다.

## 지금 상태 — 🟢 E1 · E2a · E2b · E3a · E3b · E4 · E5a~E5d · E6a~E6e · E7a(E7a0~E7a3-2) · E10a · E10b · 나머지는 🟡

실행 계획(블록 E1~E18)은 설계 저장소 `11_앱설계/13_엔진레인_착수계획.md` 가 정본이다.

| 들어온 것 | 06 항목 | 골든·검사 |
|---|---|---|
| `lib/src/decimal_rules.dart` — 규약 ①④⑤ 실행체 + 환원 규칙 | M1-1 | `test/decimal_rules_test.dart` |
| `lib/src/risk/position_sizing.dart` — 이중 상한 사이징 | M1-1 게이트(GV-8 · 새틀 비활성이라 채점 외) | GV-8a~8e · 8f · `test/position_sizing_test.dart` |
| `lib/src/signals/regime_states.dart` · `exposure_gate.dart` — 방향·추세성 상태와 익스포저 곱셈 | M1-2 일부 | GV-3(6) · GV-3c(2) |
| `lib/src/signals/indicators.dart` — SMA · TR · Wilder rma · ATR · ADX(150봉 게이트) · CHOP · BBW(ddof 0) | M1-2 일부(E2a) | GV-2a~2f(10) · `test/indicators_test.dart`(결측·±DM 동률) |
| `lib/src/signals/regime_score.dart` · `hysteresis.dart` — 카테고리 가중 평균·재정규화 · 방향/추세성 히스테리시스(봉 하나씩) | M1-2 일부(E2b) | GV-1(7) · GV-4 계열(13) · `test/regime_test.dart`(UNKNOWN 직전 · 경계 strict · 설정 거부) |
| `lib/src/risk/breaker.dart` — 드로다운 서킷브레이커(악화 즉시 · 유지 20봉 · 한 단계씩 · STOPPED 자동 해제 없음) · v2.29 재개 «자격» 이벤트 · 슬리브별 승수 | M1-3 일부 · M5-3·M5-4 계산부(E3a) | GV-31(29 · AC-S16) · s_h5_1(off/on) · GV-18(5) · `test/breaker_test.dart` |
| `lib/src/risk/limits.dart` — 한도 판정 `checkAllLimits`(L4→L3→L2→L1 전수 · P1~P6 · `trace` 관측면 · fail-closed `RiskCheckUnavailable`) · 🆕 E10a v2.38 L1 범위 = 개별주 BUY 만(`InstrumentKind` · 비면 개별주) · SELL 은 평가액 불요(R33 D1 · D23) | M1-3 일부(E3b · E10a) | GV-32(63 · AC-S17) · GV-39(🆕 17) · GV-17(6 · AC-S14) · `test/limits_test.dart`(ALERT 표시 · ETF 매수 평가액 · 비면 개별주) |
| `lib/src/calendar/exchange_calendar.dart` — 거래소 캘린더(세션 데이터를 받아 판정 · 범위 밖 = 모름) · `Market`(KR/XKRX · US/XNYS) · 🆕 E10a `nthSessionBefore` | M1-6(E4) | GV-12(5) · GV-12c(9) · `test/calendar_test.dart`(범위·입력 거부·n번째 세션 뒤 · 앞) |
| 🆕 `lib/src/calendar/frozen_calendar.dart` · `frozen_sessions.dart`(생성 — `tool/make_frozen_calendars.py`) — 동결 세션 표 lib 자산(XKRX 6,920 · XNYS 7,063 · 1999-12-01~2027-12-31 · 덮어쓰기 R15 · 연 1회 재생성) · `frozenExchangeCalendar` · `frozenCalendarInfo` | M1-7(E8b1 · 설계 13 §8 R23 D14 · R24 B2) | `test/frozen_calendar_test.dart`(lib = 원천 JSON 전 날짜 · 머리 sha256 · 범위 밖 · 덮어쓰기) · GV-12 시험도 lib 자산을 쓴다 |
| 🆕 `lib/src/data/dated_series.dart` · `pit_align.dart` — 날짜 시리즈(as-of · ffill · dropna) · 발표 지연(`kPublishLagDays` · `alignWithLag`) · 미국 → 한국 매핑 두 갈래(`toKrCalendar` 엄격 d−1 · `alignAsOfInclusive` 같은 날짜 포함 = 국면 · D13) | M1-7(E8b1 — 하네스에서 옮김) | 26년 재현 비트 일치(하네스가 lib 를 부른다) · `test/data_align_test.dart` |
| 🆕 `lib/src/data/regime_inputs.dart` — 국면 원천 한 벌(`RegimeSources`) → 원지표 13개 → 정규화 → 방향 → 추세성 → FSM(`computeRegime` · 하네스에서 옮김) · 🆕 E8d1 `dist_days` 거래량 = `RegimeSources.distVolume`(`gspcIndex` 골든 · `spyEtf` 실전 = `kP0sDistVolume` · R27 I1 V6a) + 창 결측 규칙 `maskVolumeGaps`(거래량 결측이 «조용히 0» 이 되지 않게 · R28 K3) · 신선도 상한(`RegimeFreshnessCaps` 일간 5세션 · 주간 21일 · 월간 지연 뒤 45일 · `regimeStaleDays` · `applyFreshnessCaps` — 실전 경로만) · 미국 달력 지연(`usCalendarLagSessions`) | M1-7 → M1-2(E8b2 · 설계 13 §8 R23 D6) | 26년 재현 비트 일치 · `test/replay/replay_freshness_test.dart`(26년 경로 상한 초과 = vix_term 15 · sahm 10 · 월말 판정 영향 0) · `test/data_judge_test.dart` |
| 🆕 `lib/src/data/data_checks.dart` — KR 결측 판정(`judgeKrPlanDay` — 행 없음 · 종가 ≤ 0 · 거래량 < 0 · |변동| ≥ 60% → 그날 계획 중단 · 전 종목 공백 = 캘린더 의심) · 월말 판정 시점(`monthEndRegimeReady` — 미국 그날 종가 뒤 · D13 (c)) · 사유 열거 `DataGapCause`(⏸ 계약 등재 = E8a) | M1-7(E8b2 · R23 D4 · D13) | `test/data_judge_test.dart` |
| 🆕 `lib/src/data/pandas_number.dart` — 수 변환 `pandasPreciseXstrtod`(pandas `read_csv` 기본 = `precise_xstrtod` · 정확 반올림이 아니다 — 시드·실전 수집이 참조 엔진과 같은 비트로 읽는다) | M1-7(E8c — 하네스 `test/replay/replay_csv.dart` 에서 옮김 · 설계 13 §8 R26 H9) | `test/replay/replay_csv_test.dart`(parse_parity) · data_sync `seed_bundle_test.dart`(시드 → 원장 → 국면 = 정답지 비트 일치) |
| 🆕 `lib/src/data/quote_feed.dart` — 일봉 원천 포트(`DailyQuoteFeed` · `QuoteFetch` · `QuoteFeedDown` — broker_gateway 가 구현 · data_sync 가 부른다 · 저장 이름으로 말한다) · 끝난 세션(`lastFinishedSession` — KR 세션 d = d 18:00 KST · US 세션 d = d+1 07:00 KST · 동결 달력 · 범위 밖 = StateError) | M1-7(E8d2b — 설계 13 §8 R30 N2·N3 · R29 L11) | `test/quote_feed_test.dart`(경계 17:59:59/18:00 · 06:59:59/07:00 · 주말 · 휴장 · 범위 밖) |
| `lib/src/orders/idempotency.dart` — decision_id 6종 형식(시각·TIER 인자 없음 · strategy_id 포함) · 멱등키 원문·SHA-256 · 🆕 E10a P0S 7형식(`DEP` · `FUND` · `SEAS-A-IN/OUT` · `POT-SMA` · `POT-LIQ` · `C-REBAL`) · 집행일 접미 `forExecution` = `{논리 id}@{집행일}` · 순매매 결합 `combined`(정렬 `+`) | M1-5(E4 · E10a — 04 §3-2 v2.38 · 설계 13 §8 R33 D2 · R34 U2) | GV-9(2 + 불변식) · GV-13 형식 부분(v1~v4) · `test/decision_ids_test.dart` |
| 🆕 `lib/src/orders/split_execution.dart` — 계절 분할 집행(`seasonalExecutionDays` = anchor 포함 거꾸로 N · 월말 아니면 거절 · 달을 넘으면 StateError · `splitDay` = 중간 날 ceil(계획 잔량 ÷ 남은 일수) · 마지막 날 목표 − 누적 체결 + 시장가) | M1-9b(E10a — 03 §5-3-1 v2.38 · R33 D7 · D8 · R34 U8) | 🆕 GV-30(4 · AC-B23 · 집행일 = 동결 달력) · `test/split_execution_test.dart` |
| 🆕 `lib/src/orders/order_draft.dart` — 주문 초안기(`OrderTarget` 금액 · 주수 · 전량 → `OrderIntentDraft` 계좌 · strategy_id · 수량 · 지정가 · decision_id · 멱등키 · 한도 판정 입력) · 지정가 = 직전 원 종가 × (1 ± offset) → 호가 안쪽 맞춤 → 상 · 하한 안(호가 · 상하한 = 시세 입력) · 순매매(같은 전략 안 · 다른 전략이 같은 (계좌 · 종목) = 내지 않음) · fail-closed 사유 7 · 월말 계획 → 대상 5종(`targetsFromMonthEnd`) · strategy_id `P0sStrategyIds` · 계좌 = 설정 맵 | M1-9 · M1-9b 계산부(E10a — R33 D9 · D17 · D18 · D19 · R34 U3~U7) | `test/order_draft_test.dart` |
| 🆕 `lib/src/orders/fills.dart` — 체결 델타(R31 (a) — `brokerOrderNoOf` `{주문일}:{ODNO}` · `executionIdOf` `#{누적}` · `fillDeltas` Δ누적 > 0 인 원주문 행만 · 취소 행 거름 · 앞뒤 안 맞으면 StateError) | X4-3 · M1-9 계산부(E10a — 02 §3-2 v2.38 · R33 D3 · D4 · R34 U9) | `test/fills_test.dart`(멱등 · 단가 · 날짜 다른 같은 ODNO) |
| 🆕 `lib/src/orders/block_bundles.dart` — NR-1 2단계 묶음 3(전 주문 · 신규 매수 · 진입 안내) + `blockingFlagsFor` | X5-2 계산부(E10a — 04 §3-1 v2.33 ① · R34 U10) | `test/block_bundles_test.dart`(합 = `FlagIds.blocking` · 겹침 0 · 표식 · `LEDGER_FIX` 밖) |
| 🆕 `lib/src/orders/order_ports.dart` — 주문 경로 포트(`OrderBroker` 계좌 한 벌 · `OrderLedger` · `AdviceSink`) · `IntentStatus` 10값 · `IntentRow` · `intentIdFor`(멱등키 앞 24자) · `OrderOutcomeUnknown` — 구현 = broker_gateway(E10d) · data_sync(E10c) · E18 | M1-8 · M1-9 포트(E10b — R33 D12 · R35 V2~V4) | `test/execute_intent_test.dart` |
| 🆕 `lib/src/orders/execute_intent.dart` — NR-1 순서기 `executeIntent`(1 킬스위치 → 2 묶음(🆕 E10c — 매수면 SAF-408 · 410 판정을 먼저 갱신 · R36 W9) → 2.5 미해소 UNKNOWN → 3 SAF-406 → 4 한도(원장 값으로 덮음) → 5 화이트리스트 → 6 INSERT → 6.5 → 안내 · DRY_RUN → 7~9 · 1~5 거부도 행 · 결과 불명 = UNKNOWN 뒤 다시 던짐 · 응답 뒤 기록 실패 = UNKNOWN) | M1-9(E10b — 04 §3-1 · §3-3 · R35 V5~V7) | 04 §7 포트 수준 9종 + 21 · `test/execute_intent_test.dart` |
| 🆕 `lib/src/orders/order_batch.dart` — `kr_order` 2단계 `runOrderBatch`(계좌마다 매도 → 예수금 → 매수) · `fitBuysToCash`(비례 축소 · 비용 포함 · 0주 = 부족분) | M1-9(E10b — R33 D10 · R35 V8) | 🆕 GV-13 발주 횟수(v1~v4 · AC-S13) · `test/order_batch_test.dart` |
| 🆕 `lib/testing.dart`(+ `lib/src/testing/`) — 시험 전용 받침대: `FakeOrderBroker`(각본 · 제출 기록 · 제출 순간 걸이 · 예수금) · `FakeOrderLedger`(메모리 · UNIQUE · 엄격한 전이 · 실패 주입) · `RecordingAdviceSink` — 🔴 lib 는 import 하지 않는다 | G-FB v1 포트 수준(E10b — R33 D13 · R35 V9) | 위 시험들이 쓴다 |
| `lib/src/costs/trade_costs.dart` — 거래비용(`total` 에 시장충격 포함 · 구간 `>=` · ETF 매도세 0 · 미국 = `UnimplementedError`) · 참여율 절단 · 왕복 손익 · 보유비용 `(1 − er/연거래일)^일수`(🔴 백테스트 전용) · 가중 총보수 | M1-4 일부 · M3-1 `estimate_costs` 계산부(E5a) | GV-11(3) · GV-11e(6) · GV-11d · GV-19 · GV-24(5 + 가중) · `test/costs_test.dart`(ETF 면제 · 구간표 정렬·0 구간 · 입력 거부) |
| `lib/src/portfolio/allocation.dart` — 자본 배분 해석·검증(합 1.0 아니면 거부 · 하나 빠지면 잔여 · 새틀 밴드 = 목표 × 15/18 · 21/18 · 새틀 0 허용 · 오류 문구 = 참조 구현) | M1-4 일부(E5a) | GV-42(12 · AC-B30) · `test/allocation_test.dart`(문구 전체 · 키 순서 · 잔여 반올림) |
| `lib/src/signals/sleeve_b_tranche.dart` — 슬리브 B 3-트랜치 SMA(다수결 아님 · 월봉 · 판정월 포함 · 워밍업 0.0) · P0S 하한 1/3 먼저 → BEAR 차감 2/3 나중(B 본책 전용) | M1-4 일부(E5b) | GV-20(5 · AC-B13) · `test/sleeve_signals_test.dart`(P0S 하한·차감 · 03 v2.27 블록 값) |
| `lib/src/signals/seasonal_exit.dart` — 4월 말 청산 비율(v2.19 기본 = 전량 · enabled 경로 `1 − score/100` · 결측·40 미만 = 전량) | M1-4 일부(E5b) | GV-38(4) · GV-23(8 · enabled 경로) |
| `lib/src/portfolio/sleeve_c.dart` — 슬리브 C 달러 목표(분모 = 달러 잔액 · 원화는 인자 없음 · 금 = min(비중 몫, 총자산 × 8%) · 초과분은 현금성) · 원화 유입 = 전액 원화 현금성 | M1-4 일부(E5c) | GV-22(4) · GV-35(4 · 숨은 인자 명시) · `test/sleeve_c_funding_test.dart`(P0S 비중 0/0.65/0.35) |
| `lib/src/portfolio/funding.dart` — 원화 조달 상대(잉여 큰 순 · 🔴 B 제외(연금 인출 불가) · 잉여까지만 · 동률 = 입력 순서 · 부족분 반환) | M1-4 일부(E5c) | GV-36(4) · 동률·B 단독·입력 거부 |
| `lib/src/portfolio/core_band.dart` — 코어 밴드(B 지분 목표 ± band 이탈분 **전액** · strict · B→C = 계좌 안 재분류 · C→B = 환원(한도 무관) → 납입(연 한도 · 재진입 재원 보호) · v2.32 조달 필요액) | M1-4 일부(E5d) | GV-37(8 · 숨은 인자 명시) · `test/core_band_deposit_test.dart`(P0S B 0.42 · 두 다리 분리 · 조달 필요액) |
| `lib/src/portfolio/deposit.dart` — 납입 배분(부족분 큰 순 · 연금 한도가 남으면 B 먼저·한도까지만 · 한도 0 이면 B 제외 · 잔여 반환(목적지 D2 대기)) | M1-4 일부(E5d) | GV-28d(8) · 동률·부족분 0·입력 거부 |
| `lib/src/signals/percentile.dart` — PIT 백분위(확장 윈저화 1%·99% → 확장 평균 순위 · 그 시점 경계로 한 번만 자름) · 이동 백분위(창 전부 있을 때만) | M1-2(E6b) | 26년 재현 비트 일치(test/replay) · `test/regime_pipeline_test.dart` |
| `lib/src/signals/regime_pipeline.dart` — 지표 설정 표(13개 · 02 §4 기본값) · TREND 4지표 · 분산일 · 12-1 모멘텀 · 정규화 · 날마다 방향 스코어 · 추세성 세 부분 · FSM 봉 루프(🔴 03 방식 — 데이터 부족일 UNKNOWN 저장 · 나이·추세성 유지 · R9) · KOSDAQ 추세 점수 | M1-2 · 03 §5-3-2(E6b) | 26년 재현: 정규화 13 · 방향 · 추세성 · tskr **비트 일치** · FSM 1985-11-27 이후 상태·나이 일치 |
| `lib/src/numeric/pandas_compat.dart` — numpy 짝 합산 · pandas 무리 합(카한) · 파이썬 `round`(이진수 정확값 · 동률 짝수) | 골든 대조의 수치 받침(E7a1 — 하네스에서 옮김) | 26년 재현 비트 일치(E6c · E6e · E7a1) · `test/after_tax_test.dart` |
| `lib/src/whatif/after_tax.dart` — 세후 산식(정본 `exp/tax_lib.py::aftertax_full` 을 같은 연산 순서의 double 로 · 갈래 4 × 층 9 · 🔴 무납입 전용 — 외부 현금흐름이 있으면 거부 · §8 미결 18) · `after_tax_ladder.dart` — `AfterTaxLadder` 조립(엔진 문장 · 늘 골든 참고치) | M3-5(무납입) · M2-9 ⓒⓓⓔ(E7a1) | `aftertax_full_S7` **글자까지 일치**(test/replay — 26년 S7 원장) · 픽스처 `aftertax_ladder_1.json` 과 DTO 일치 · C-30 · C-41 ⑦ |
| `lib/src/whatif/` 앞단 — 입력 포트 `WhatIfState` · `WhatIfConfig` · 표시 글자(«4만 2천원» 꼴) · 금액 입력 판정 · 차단 표(D21 · H64) | M3-1 ⓐⓑ(E7a2-1) | 계약 픽스처 글자 일치 · 차단·거부 = C-38 ① · C-41 ① 한 갈래 · `test/what_if_inputs_test.dart` |
| `lib/src/whatif/deposit_plan.dart` — 입금 미리보기 계산(배분 03 §5-5b · 초안 = B 파킹 ETF 매수만 · A·C·잔여 원화 대기 — 설계 13 §8 R18 D-1) | M3-1(E7a2-2) | 시나리오 14 × C-38 ①~⑧ · `test/what_if_deposit_test.dart` |
| `lib/src/whatif/engine_what_if_api.dart` · `plan_store.dart` — `EngineWhatIfApi`(`simulateDeposit` · `findPlan` 등록 불가·만료 다시 판정 · `estimateCosts`) · 계획 스냅샷(메모리 · planId `pl_<한국 날짜>_<순번>`) | M3-1 · M3-2(E7a2-3) | 부작용 0(쓰기 = 스냅샷뿐) · `test/what_if_api_test.dart` |
| `lib/src/portfolio/month_end_plan.dart` — 월말 계획기(램프 납입 → 코어 밴드(B 비례 매도 재원 · 재분류 · 환원 · 납입 · v2.32 조달) → B 3-트랜치 주문 → C 리밸런싱 주문 → POT 당일 매매 · Decimal · 값만) | M1-4 실행 경로(E7a3-1 · D-14) | 26년 재현 5실행 × 월말 320 — 하네스와 **순서·종류·종목·방향 일치 · 금액 차이 1.2e-7원 이하** · `test/month_end_plan_test.dart`(경계) |
| `lib/src/whatif/rebalance_preview.dart` · `lib/src/calendar/next_rebalance.dart` — 리밸런싱 미리보기(월말 계획기 그대로 → 정수 주 초안 · H64 관문 · 사유 칩 `RebalanceReasonCodes` · 회계 기준 전후 비중 A·B·C · 납입 경고 줄 · 원화 조달 `fundingSteps` · 결과 캐시 0) · 다음 정기 회차(월말 판정 다음 세션 — `watchNext` 와 같은 함수) | M3-1 v1.6(E7a3-2) | 26년 재현 2실행 × 월말 320 — C-41 ①② · 초안 = 계획 매매의 정수 주 · `test/what_if_rebalance_test.dart` |

**STOPPED 실재개**는 `releaseStoppedToHalted` 하나뿐이다 — 부르는 자리는 M5-3(`decision_id` 등록 뒤)과 재현 하네스다. 참조 엔진의 `stopped_release_enabled`(자격 = 재개 근사)는 앱 코드에 두지 않는다.

**환원 규칙(E1 에서 정함)** — 나눗셈·곱셈 결과는 파이썬 `decimal` 기본 문맥과 같은 **유효숫자 28 · ROUND_HALF_EVEN** 으로 끊는다(`divide` · `multiply` · `mulDiv`). Dart 의 `Rational.toDecimal(scaleOnInfinitePrecision:)` 은 **버림**이라 파이썬과 반대 방향으로 갈 수 있다 — 05 §GV-8f 의 «나눗셈 선행» 값 `500.0000000000000000000000002` 를 그대로 재현하는 것이 그 확인이다. 기대값은 파이썬 `decimal` 로 뽑았다.

**지표의 기준 구현**은 `09_백테스트/백테스트6/engine/indicators.py`(전략 골든을 만든 엔진)다. 합·평균은 창마다 왼쪽부터 더하므로 pandas·numpy 와 마지막 자리가 다를 수 있다 — 26년 경로의 경계 판정 영향은 E6 에서 잰다.

아직 없는 것: 일별 재현 러너(E6c~E6e — 슬리브 계산을 날마다 엮는 배선 · 골든 판정) · ~~실전 PIT 정렬(발표 지연 맞추기는 데이터 수집 M1-7)~~ 🟢 E8b1 에서 lib 로(판정·조립은 E8b2) — P0S 에서 돌지 않는 GV-25(동적 ETF) · GV-28 인출 · GV-33/33b(새틀 밴드)는 보류(발주자 결정 2026-10-20 · 설계 13 §7 P-2) · 지표 원값 → 백분위(`pit_percentile`)·부호 정렬·추세성 스코어 조립 · 팩터·월중 전이(E2c) · 일간·월간 경고 한도(GV-40 — E3c 후보, 대상 상당수가 새틀·개별주라 P0S 미사용 판정부터). ⚠️ **한도 판정의 적용 범위**(설계 13 §8 R10) — 정답지는 SAF-101·102·103 을 슬리브 구분 없이 모든 매수에 건다. P0S 의 ETF 주문(손절가 없음)에 그대로 쓰면 매수가 막히므로 주문 경로(E10) 전에 정한다. 🔵 P0S 에서 실행되지 않아 보류한 것(설계 13 §7 P-2): GV-5·6·41(E2c) · GV-7·15(위험 기여도·N_eff) · 위험 기여·한도(E3) · 거래일·멱등키(E4) · 슬리브·P0S(E5) · 전략 4자리 대조(E6) · What-if(E7).

✅ SDK 는 설치돼 있다(2026-09-07 · Dart 3.13.2 · Flutter 3.47.2 · melos — `docs/toolchain_notes.md` §1). 이 패키지는 순수 Dart 라 `dart test` 로 돈다(🆕 v1.4 정정 — 구 «이 PC에는 Flutter·Dart·melos가 없다(2026-09-06)»). v1.4 `WhatIfApi` 새 시그니처(`simulateDeposit({required String amountInput})` · `findPlan`)의 구현은 06 M3-1 몫이다(`lib/src/whatif/README.md`).
