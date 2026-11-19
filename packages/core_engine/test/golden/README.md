# `test/golden/` — 골든벡터 Dart 재현

정본: `06_시스템설계/05_수용기준_골든벡터.md`
입력 JSON: `vectors/`(원본 그대로 옮긴 사본 — 출처·sha256 은 `vectors/SOURCES.md`) · 원본 위치 `08_파일럿/파일럿1·3·4·5/…` 와 05 본문 JSON 블록 · 전략 수치 정본 `09_백테스트/백테스트6/runs/N2_golden/golden_p0s.json`
진척: E1 = GV-8(8a~8f) · GV-3(6) · GV-3c(2) · E2a = GV-2a~2f(10) · E2b = GV-1(7) · GV-4 계열(13) · E3a = GV-31(29) · s_h5_1 · GV-18(5) · E3b = GV-32(63) · GV-39(15 → 🆕 E10a 17 · v2.38) · GV-17(6) · E4 = GV-9(2) · GV-12(5) · GV-12c(9) · GV-13 형식(4) · E5a = GV-11(3 + 왕복) · GV-11e(6) · GV-11d(1) · GV-19(옛 세율 원문 + 현행 세율) · GV-24(5 + 가중 총보수) · GV-42(12) · E5b = GV-20(5) · GV-23(8) · GV-38(4) · E5c = GV-22(4) · GV-35(4) · GV-36(4) · E5d = GV-37(8) · GV-28d(8) · 🆕 E10a = GV-30(4 · 분할 집행) · 🆕 E10b = GV-13 발주 횟수(v1~v4 · `gv13_submit_count_test.dart`) · E6e = GV-P0S(스택 S6·S7 · 스트레스 3종·순서 · 세후 S7 · 금 비중 5 · 실현 배분 9 — 26년 재현 실행이라 `../replay/replay_golden_p0s_test.dart` 가 `vectors/golden_p0s.json` 을 읽는다). 세션 데이터 = `vectors/sessions_x*.json`(exchange_calendars 4.13.2 동결 · `tool/gen_exchange_sessions.py`). 블록별 범위는 설계 저장소 `11_앱설계/13_엔진레인_착수계획.md` §2.

## 무엇을 하나

골든벡터는 **동결된 입력 → 기대 출력 정답지**다. 언어 중립 자산이라 파이썬 파일럿에서 쓰던 JSON을 **그대로** Dart 재구현의 등가성 게이트로 쓴다. 여기 테스트는 그 JSON을 읽어(`golden_vectors.dart`) `core_engine`의 출력과 비교한다.

## 🔴 규칙

1. **골든 JSON을 이 저장소에서 다시 만들지 않는다.** 원본을 복사해 오고, 값을 손대야 할 이유가 생기면 그것은 전략 변경이므로 `06_시스템설계`에서 결정한다.
2. **전량 통과 전에는 DRY_RUN을 벗어나지 않는다**(결정 2). 이 폴더가 그 게이트다.
3. **테스트가 깨졌을 때 기대값을 고치지 않는다.** 깨진 것은 계산이 바뀌었다는 신호다. GV-8a는 **1 ULP 차이로 `binding` 판정이 뒤집힌 실측 사례**이며, 계약 쪽 C-9 와 여기 `gv08_sizing_test.dart` 가 둘 다 재현한다(C-9 = «Dart Decimal 이 파이썬과 같은 답을 내는가» · 여기 = «엔진 코드가 그 답을 내는가»).
4. ⚠️ **서브케이스 총계를 상수로 적지 않는다.** 196 → … → 345(v1.15)로 재합산된 이력이 있다. 화면·계약 어디에도 총계를 굳히지 않는다.
5. 🔴 **파일럿 사본이 정본보다 낡았을 수 있다.** 옮기기 전에 05 본문의 같은 벡터와 의미가 같은지 본다 — 파일럿1 `GV-3_exposure_gate.json` 은 05 v1.10 이 폐기한 «원시 점수 35 비교» 판이라 옮기지 않았다. 파일럿1 `GV-2_indicators.json` 도 05 보다 낡아(2e·2f 없음) 05 본문 블록을 썼다(`vectors/SOURCES.md`).
6. 🔴 **파일 이름을 `*.golden.json` 꼴로 짓지 않는다** — CI «골든 스냅샷» 잡이 그 꼴을 화면 스냅샷으로 취급해 수정·삭제를 막는다.
7. 🔴 **한 정본(E11o · 설계 13 §8 R161 · R162)** — 옮긴 계열의 비교 논리는 엔진 `lib/src/golden/`(순수)에 있고 폰(S10 골든 카드 · O-04 ④)도 **같은 케이스**를 돈다. 옮긴 계열의 시험은 `runFamily(...)`(`golden_vectors.dart`)로 lib 케이스를 하나씩 부른다 — 판정을 시험에만 새로 적지 않는다(두 벌 0). 계열은 읽는 벡터 파일을 `files` 에 선언하고, 시험 묶음(`bundleOf`)은 선언한 파일만 담는다(선언 밖 파일 = «벡터 없음» 실패 · 앱 자산 목록 = 선언 합). 벡터는 이 `vectors/` 에 그대로 둔다(이동 0). 옮긴 계열(`golden_runner_test.dart` 가 옛 시험 수와 대조): E11o-a = GV-1 · 2 · 3 · 4(40) · E11o-b = GV-8 · 9(+13 형식) · 11(+11d · 11e · 19 · 24) · 12(+12c) · 13 발주 횟수 · 30(71) · E11o-c1 = GV-20(+23 · 38) · 22(+35 · 36) · 31(+s_h5_1 · 18) · 32(+39 · 17) · 37(+28d) · 40d · 40e · 42(201 · 한도 받침은 lib `gv_limits.dart` 안으로) · E11o-c2 = GV-16(7 · 새로 옮김 — 05 §GV-16 블록 원문) · E3c = GV-40a · b · c(30 · 새로 옮김 — 판정은 엔진 `risk/warn_limits.dart` · 문턱 = 생성기 상수 · 05 대기 세부 = 참조 생성기 판 · 설계 13 §8 R166) — 시험에만 남은 것 = GV-3 코드 읽기 거부 3 · GV-12 세션 표 머리말 1(원천 데이터 확인). 설정 받침(`krCostsFromSpec`)은 엔진 lib `src/golden/golden_fixtures.dart` · 주문 경로 받침(`draftOf` 등)은 `package:core_engine/testing.dart` 다. 🔴 GV-13 발주 횟수는 05 가 정한 «mock» 그대로 엔진의 결정론 가짜로만 돈다 — lib 안에서 `src/testing/` 을 부르는 곳은 `testing.dart` · `src/golden/gv_orders.dart` 뿐(`golden_boundary_test.dart`).
8. 🔴 **«전량» = 05 처리 구분표(E11o-c2 · 설계 13 §8 R165 · §7 P-2)** — 엔진 lib `src/golden/golden_coverage.dart` 가 05 의 GV 계열마다 «기기 · CI 전용 · 제외(P-2 사유) · 빠짐»을 적는다. 실행기 케이스는 전부 «기기» 계열에 속해야 하고, «기기» 계열은 케이스가 있어야 하며, `kDeviceGoldenSuite.complete` 는 «빠짐» 0 일 때만 참이다(`golden_coverage_test.dart`). 지금 «빠짐» = **0**(E3c 가 GV-40a~c 경고 한도 판정을 엔진에 넣어 «전량» 참 · 설계 13 §8 R166). `test/golden/` 밖에서 벡터를 읽는 시험의 처리: `breaker_consume_test` 의 s_h5_1 on(실제 `replayBreaker`) = 같은 벡터의 소비 경로 시험(기기판 = GV-31 s_h5_1) · `calendar_test` 의 «20거래일» 검산 = GV-14(비활성) · `after_tax*` 의 `golden_p0s.json` = GV-P0S(CI) · `ledger_hash*` 의 `ledger_hash_v1.json` = 05 GV 아님(장부 해시 골든) · `frozen_calendar_test` = 원천 대조(시험 전용).
