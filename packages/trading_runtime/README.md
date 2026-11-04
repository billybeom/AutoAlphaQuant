# trading_runtime — M1 실행 런타임 · X2 장기 미실행 재개

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M1** engine-runtime(실행부) · **X2** catch-up-ledger
> **정본**: `06_시스템설계/04_안전장치.md` · 01_M2_도메인계약 **§2-7**(`PlannedWorkSummary`·`ResumeReport`) · **§6-3**(`planned_work`·`resume_run`·`data_gap`)

## 무엇을 담나

FGS(포그라운드 서비스) 수명 · 정확 알람 · 일 1회 배치 잡 스케줄 · 워치독 · **장기 미실행 재개(catch-up)** 절차 R0~R8.

## 의존 — 허용

`domain_contracts` · `core_engine` · `broker_gateway`.

## 의존 — 🔴 금지

`ui_journal` · `ui_analytics` · `ui_shell` · `ui_settings` · `ui_safety`.

> 재개 리포트를 **그리는** 화면은 `ui_safety`(M5 소유)다. 런타임은 상태를 만들고, 화면은 받는다.

## 이 패키지가 지는 규칙 3개

1. **재개는 «밀린 일을 몰아서 실행»이 아니라 «재판정»이다.** 계획은 만료(`EXPIRED`)·대체(`SUPERSEDED`)·차단(`BLOCKED`)·복구 불가(`UNRECOVERABLE`)로 갈릴 수 있고, 그 판정 결과가 사용자에게 보이는 전부다.
2. **Supabase 미러에는 계획 원문이 아니라 digest + 한 줄 요약만 올린다**(X2 원칙 ②).
3. **재개 리포트에 손익 필드가 없다**(결정 8 · 청사진 X2 화면). 헤드라인은 «7거래일 미실행: 실행 4 / 만료 3 / 대체 2 / 차단 1 / 복구 불가 2» 형태의 **과정 지표**다.

## ⚠️ 구현 시 판단할 것 — 플랫폼 경계

FGS·정확 알람은 Android 기능이라 Flutter 플러그인이 필요해질 수 있다. 그러면 이 패키지가 순수 Dart를 벗어나고 재개 로직을 폰 없이 테스트할 수 없게 된다. **플랫폼 호출을 `app_operator_android` 쪽 얇은 어댑터로 밀어낼 수 있는지 먼저 검토할 것.**

## 지금 상태 — 🟢 주문 잡(E11a) · 잡 표 · 3분법 · FGS 문구(E11b) · 워치독 보드(E11c) · 🟡 알람 · FGS 서비스 · 재개

- 🆕 **E11a — 잡 규약 · 주문 잡**(설계 13 §8 R42 · 01 §10 · 00_SPEC 잡 표 v2.38 · 04 §4-2 · §3-5 · §5-2) — 순수 Dart · 포트만(플랫폼 0):
  - `runJob`(01 §10 잡 규약) — 휴장(동결 XKRX 비세션) = 성공 핑 «휴장» 하나 · 아니면 start → 본체 → success | fail · 본체 예외 = fail 핑(다시 던지지 않음) · 핑 실패는 결과를 바꾸지 않는다(센다) · 알림 발송 실패 = fail 핑 · 달력 범위 밖 = fail · 체크 이름 `{sim|live}-{auto|advisory}-{잡}`
  - `KrOrderJobs` — `runOpen`(`kr_order` · 09:05 앞 = 실패 · 15:00 뒤 = 내지 않고 다음 거래일 · UNKNOWN 해소 → 앞 세션 실효 이월 + 오늘 대상 → 초안 → 배치 → 배치 직후 대사) · `runClose`(`kr_order_close` · 15:40 뒤 · 해소 → 일 마감 체결 동기화) · `runDailyReconcile`(`daily_reconcile` · 07:00)
  - 포트 = `JobHeartbeat`(healthchecks 어댑터 = M1-12) · `AlertSink`(발송 = M5 · E13) · `TargetSource`(월말 계획 · 계절 몫 = 이 판 밖) · `DraftQuoteSource` · 원장 = core `OrderPathLedger` · 브로커 = core `AccountBroker`
  - 시험 전용 dev 의존 `decimal`(lib 는 쓰지 않는다)
- 🆕 **E11b — 잡 표 · 회차 · 3분법 · FGS 문구**(설계 13 §8 R43 B1~B9 · 00_SPEC §6-4 · 06 M1-11 계산 몫 · M1-15 · M1-16):
  - `kJobTable`(07:00 대사 · 09:10 주문(늦은 끝 15:00) · 15:45 마감 · 18:30 · 20:00 · 20:30 · 20:45 월말 · us_data 07:30 KST) · 🟡 유예 = 잠정(04 §5-2 서버 전제값 — 폰 실측 뒤 config)
  - 🔴 KR 잡은 **평일마다** 발화(평일 공휴일 = «휴장» 성공 핑) · 월말 잡 = 마지막 KR 세션 · `us_data` = XNYS 세션 d → (d+1) 07:30 KST(DST 무관 · 화~토)
  - `nextOccurrence` · `occurrencesBetween` · `wakeDecisions`(깨어났을 때 — 돌았음 · 지금 · 놓침) · `judgeOccurrence`(성공 · 지연 · 실패 · 휴장 · 일시정지 · 아직 → `UiLevel` · 🔴 지연 ≠ 실패)
  - `runJob` = 시장별 달력 + 세션일 함수 + 회차 `rid`(start · 끝 같은 값) · `buildFgsNotice`(완성 문자열 1 · 손익 0 · P0 = `ops_p0` · 딥링크) · `shouldRepostFgs`(전이 때만)
- 🆕 **E11c — 워치독 보드 · 자기 점검**(설계 13 §8 R45 C7~C9 · 06 M1-12 · 지도 D12 · 앱 04 §7 `W-01`): `buildWatchdogBoard` = 로컬 판정(정본) → `WatchdogBoardVm`(문구 = 계약 표본 꼴 · 지연 watch · 일시정지 info · `checkId` = 차례 · 🔴 슬러그 0) · 바깥 대조(로컬이 받았다는데 바깥 `last_ping` 이 60초 넘게 앞서거나 없음 · 체크 없음 · 겹침 · 바깥만 멈춤 = watch · 바깥 못 읽음 = 머리만) · `auditRemoteChecks`(없음 · 겹침 · 멈춤 · new · down · 기대 밖) · 포트 `JobHeartbeat` · `PingStatus` = core 에서 다시 내보냄
- 🆕 **E11f2 — 잡 표 · 포트**(설계 13 §8 R48 P1 · P2 · 발주자 결정 2026-11-04): `monthly_rebalance` = 새 주기 `krAfterMonthEnd`(월 마지막 KR 세션의 다음 KR 세션 08:00 · 세션일 = 그 월말 · 유예 1시간 · 늦은 끝 15:00 — 골든과 같은 판정 · 🔴 SPEC 문언 = v2.39 창) · 옛 `krMonthEnd` 지움 · `TargetSource` = core 에서 다시 내보냄(구현 = data_sync `StoredPlanTargetSource`)
- 🆕 **E11f3 — 잡 표**(설계 13 §8 R49 Q1 · 발주자 결정 2026-11-04): `seasonal_a` = KR 평일 08:00 · 유예 1시간 · 늦은 끝 09:05(`kr_order` 앞) · 판정 날(마지막 3 KR 세션의 첫날)에만 움직인다 · 🔴 SPEC 잡 표 추가 = v2.39 창
- 아직 없는 것: 알람 · FGS 서비스(M1-11 — `app_operator_android` 어댑터 · E11p) · 핑 배선(조립 앱이 data_sync `HealthchecksClient` 를 `runJob` 에 넣는다) · 알림 발송 · 재개 R0~R8(X2)
