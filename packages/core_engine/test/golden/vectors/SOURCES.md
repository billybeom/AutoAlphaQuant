# 정답지 출처 — `test/golden/vectors/`

> 🔴 여기 파일은 **원본을 그대로 옮긴 것**이다. 값을 고치지 않는다(`../README.md` 규칙 1·3).
> 원본이 바뀌면 다시 복사하고 이 표의 sha256·복사일을 갱신한다 — 손으로 고친 정답지는 위조다.
> 🔴 줄 끝은 저장소 규칙(`.gitattributes` `eol=lf`)대로 LF 다 — 원본이 CRLF 면 줄 끝만 바꾸고 원본 sha256 을 함께 적는다.
> 🔴 파일 이름을 `*.golden.json` 꼴로 짓지 않는다 — CI «골든 스냅샷» 잡이 그 꼴을 화면 스냅샷으로 보고 수정·삭제를 막는다(`.github/workflows/ci.yml`).
> 원본 경로는 설계 저장소(`C:\Work\클로드-백그라운드-작업\투자`, E1 = 커밋 `ba91cc3` · E2a·E2b·E3a·E3b·E4 = 커밋 `d3aaabb` · E5a = 커밋 `f11d2b5` · E5b = 커밋 `a64d4e1` · E5c = 커밋 `2a59c81` · E5d = 커밋 `a622930` 기준 — 05 는 그 사이 바뀌지 않았다) 상대 경로다.

| 파일 | 원본 | 원본 판 | 복사일 |
|---|---|---|---|
| `golden_p0s.json` | `09_백테스트/백테스트6/runs/N2_golden/golden_p0s.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `b86a47f74cc0a56eaa979b130c05175de94e4cd1438831dbd467984cdfb6555f` · 원본도 끝 줄바꿈 없음) · 05 §GV-P0S 가 지목하는 v2.32 정본 정답지. E6e 는 설계 13 §7 P-2 결정 범위만 판정한다 — `stack` 의 S6·S7 · `stress_S7` · `aftertax_S7` · `gold_share_S7` · `realized_alloc_S7`. `S5_P0`(새틀 6% 경로) · `bootstrap_S7`(numpy 난수) 는 Dart 범위 밖 · `aftertax_full_S7` 은 E7a 몫 | 파일 커밋 `d479e19` | 2026-10-21 |
| `gv28d_deposit.json` | `08_파일럿/파일럿5/vectors/gv28d_vectors.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `8c9142342141226bea15dcc97486b815a7c178d4745624ca8929cb378834c95f`) · 03 §5-5b 가 지목(AC-B21 의 d1~d8) · `_meta.fixed_decisions` D1~D4 — D2(잔여 목적지)는 발주자 대기라 금액만 채점 · D4(동률 = 이름순)는 정답지에 동률이 없어 엔진은 입력 순서를 쓴다 | 파일 커밋 `b1c85de` | 2026-10-20 |
| `gv22_sleeve_c_gold_cap.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-22 코드 블록(2406~2431행) — 비중 0.40/0.35/0.25 는 v1.7 값이지만 블록 안 `config` 에 적혀 있어 자기완결이다 | 05 **v1.22** | 2026-10-20 |
| `gv20_sleeve_b_tranche.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-20 코드 블록(2292~2306행) | 05 **v1.22** | 2026-10-20 |
| `gv23_partial_exit.json` | 같은 문서 §GV-23 코드 블록(2449~2469행) — enabled 경로 전용(P0S 는 꺼짐). GV-38-4 가 같은 함수를 묻는다 | 05 **v1.22** | 2026-10-20 |
| `gv35_38_decisions.json` | `08_파일럿/파일럿5/vectors/gv35_38.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `f85337e698cda0ac8262a20dc853c797db22d8210c9af9ab85018488d14d47ae`) · 05 §GV-35~38 이 지목(AC-B26). E5b 는 GV-38 · E5c 는 GV-35·36 · E5d 는 GV-37 을 시험한다(GV-35·37 의 숨은 인자는 테스트가 드러내 적는다 — 발주자 결정 2026-10-20). ⚠️ GV-35·37 은 생성기(`gen_v220_vectors.py`)가 슬리브 C 가중치 0.40/0.35/0.25 · B 목표 0.287 을 **기본 인자로 숨겨** 계산했다 — 현행 P0S(C 0/0.65/0.35 · B 0.42)와 다르다(설계 13 §8 R14) | 파일 커밋 `b1c85de` | 2026-10-20 |
| `gv11_trade_cost.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-11 코드 블록(1876~1891행) — 설정은 산문이라 `../kr_costs_fixture.dart` 가 02 §4 `costs.kr` 를 옮겨 적는다 | 05 **v1.22** | 2026-10-20 |
| `gv11e_tier_boundary_us.json` | 같은 문서 §GV-11e 코드 블록(1897~1919행) | 05 **v1.22** | 2026-10-20 |
| `gv11d_participation.json` | 같은 문서 §GV-11d 코드 블록(1931~1934행) | 05 **v1.22** | 2026-10-20 |
| `gv19_cost_in_pnl.json` | 같은 문서 §GV-19 코드 블록(2261~2277행) — ⚠️ 기대값은 증권거래세 **0.18%**(02 v2.10 이전) 시절 값이다(05 검산 «18,000»). 고치지 않고, 테스트가 옛 세율로 통합 경로를 맞춘 뒤 현행 0.20% 로 GV-11b 와 같은지를 따로 본다(설계 13 §8 R13) | 05 **v1.22** | 2026-10-20 |
| `gv24_holding_cost.json` | 같은 문서 §GV-24 코드 블록(2494~2518행) | 05 **v1.22** | 2026-10-20 |
| `gv42_allocation.json` | `08_파일럿/파일럿5/vectors/gv42.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `d8c34a23dbf9b8637170bfec55f67ddee9790de2c9658d004539e7cd9cda9c8f`) · 05 §GV-42 가 지목(AC-B30 · v2.31 재생성판 = 허용 6 · 거부 6) | 파일 커밋 `000347b` | 2026-10-20 |
| `gv09_idempotency_key.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-9 코드 블록(1138~1160행) | 05 **v1.22** | 2026-10-20 |
| `gv12_trading_day.json` | 같은 문서 §GV-12 코드 블록(1943~1957행) | 05 **v1.22** | 2026-10-20 |
| `gv12c_last_session_negative.json` | 같은 문서 §GV-12c 코드 블록(1967~1981행) | 05 **v1.22** | 2026-10-20 |
| `gv13_decision_id.json` | 같은 문서 §GV-13 코드 블록(2040~2083행) — 형식 부분만 시험(발주 횟수는 E10) | 05 **v1.22** | 2026-10-20 |
| `gv30_split_execution.json` | 🆕 E10a — `06_시스템설계/05_수용기준_골든벡터.md` §GV-30 코드 블록(1790~1807행) — AC-B23 e1~e4 · e4 = 미체결 이월 + 마지막 날 강제(v2.38 해석 = 중간 날은 계획 잔량 · 마지막 날 = 목표 − 누적 체결 · 기대값 불변 · 설계 13 §8 R33 D8) · `sessions` 는 동결 달력과 대조한다 | 05 **v1.23** | 2026-11-03 |
| `sessions_xkrx.json` · `sessions_xnys.json` | 🔵 **정답지가 아니라 입력 데이터** — `tool/gen_exchange_sessions.py` 가 exchange_calendars **4.13.2**(pandas 3.0.6 · Python 3.14.6)로 1999-12-01~2027-12-31 세션을 동결한 것(발주자 결정 2026-10-20). 05 GV-12 가 지정한 판(4.13.2)과 같다. 🔴 손으로 고치지 않는다 — 판을 올리면 생성기를 다시 돌린다. 🆕 라이브러리가 빠뜨린 임시휴장은 생성기의 `CLOSED_OVERRIDES` 에 근거와 함께 적고 다시 돌린다 — XKRX **2026-06-03**(지방선거일) · **2026-07-17**(제헌절 공휴일 복원) — 한국거래소 2026-05-20 휴장 공지(설계 13 §8 R15 · XKRX 6,922 → 6,920 세션) | 생성 2026-10-20 · 재생성 2026-10-20 | 2026-10-20 |
| `gv32_saf_vectors.json` | `08_파일럿/파일럿4/vectors/saf_vectors.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `6549049dc5711f26d95f90b451902b492e53b6a4eac7f2f968f4b2fede4b57a0`) · 05 §GV-32 가 정본으로 지목 · 63케이스. `_meta.cfg_risk` 의 `circuit_breaker.dd_stop: -0.3` 은 v2.16 이전 값이지만 한도 판정에는 쓰이지 않는다 | 파일 커밋 `b1c85de` | 2026-10-20 |
| `gv39_trace_vectors.json` | `08_파일럿/파일럿5/vectors/gv39_vectors.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `d6350505848d85216f086db795387b5f8f84f517408b7df11427fc1f5140665b`) · 🆕 E10a **17케이스**(v2.38 재생성판 — `intent.instrument` STOCK|ETF · `g05` trace 15 → 12 · 🆕 `g08b` SELL equity 불요 · 🆕 `g15` ETF BUY 손절가 없음 → ALLOW · 05 v1.23 · 설계 13 §8 R33 D1 · D23) · 구판(15 · 원본 sha256 `cd0702d5…5378d` · 파일 커밋 `b1c85de`)을 덮었다 | 파일 커밋 `66aad71` | 2026-11-03 |
| `gv40_saf_warn.json` | `08_파일럿/파일럿5/vectors/gv40_saf_warn.json` — 파일 통째, **줄 끝만 CRLF → LF**(원본 sha256 `9f35b462dfa513286087eb185a075fe07b3758be1003082e8cb84caca4ca2f8d`) · 05 AC-S18 이 지목 · 🆕 E13f1 = **GV-40e 9케이스**(SAF-409 재량 예산 — 경계 ±10%p 포함 · 롤링 12개월 경계일 포함 · 저널 미연결 · 사유 오름차순)만 시험한다. 🆕 E13g1 = **GV-40d 3케이스**(SAF-405 live 기동 통제 — 미승인 · 행 없음 = 기동 거부 · 설계 13 §8 R66 Y9) · a·b·c(경고 한도 · AC-B28)는 이 판 밖 · 적대 2(경계 strict · 달력 연도)는 변이 검사로 대신한다(설계 13 §8 R64 W8) | 파일 커밋 `b1c85de` | 2026-11-05 |
| `gv17_fail_closed.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-17 코드 블록(2209~2225행) — v1.6 상태 모델이라 테스트가 GV-32 이름으로 옮겨 읽는다. x3(`usd_exposure_pct`)은 v2.30 SAF-307 재정의로 판정 입력이 아니게 돼 시험하지 않는다 | 05 **v1.22** | 2026-10-20 |
| `gv31_breaker_vectors.json` | `08_파일럿/파일럿4/vectors/breaker_vectors.json` — 파일 통째(sha256 원본과 같음 · 05 §GV-31 이 정본으로 지목 · v1.13 재생성판 = 단발 23 + 시퀀스 6 · dd_stop −0.35) | 파일 커밋 `2a699f9` | 2026-10-20 |
| `gv31_s_h5_1_J1_stopped.json` | `09_백테스트/백테스트6/runs/J1_stopped/J1_stopped.json` — 파일 통째, **줄 끝만 CRLF → LF**(저장소 `.gitattributes` `eol=lf` — 내용 바이트는 그 밖에 같다 · 원본 sha256 `30e050b3bd88dcf9160eb0bf568410982d1208bd3f6a721d497759d8e175845b`) · 테스트는 `vectorB_deterministic` 만 쓴다(05 §GV-31 계열 s_h5_1 정본 실측). 입력 시퀀스는 05 본문 · `exp/J1_stopped_vector.py` 271~277행대로 테스트가 만든다 | 파일 커밋 `2a699f9` | 2026-10-20 |
| `gv18_exposure_multiplier.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-18 코드 블록(2240~2250행) | 05 **v1.22** | 2026-10-20 |
| `gv01a_all_valid.json` | 같은 문서 §GV-1a 코드 블록(255~263행) | 05 **v1.22** | 2026-10-20 |
| `gv01b_two_missing.json` | 같은 문서 §GV-1b 코드 블록(269~277행) | 05 **v1.22** | 2026-10-20 |
| `gv01c_category_exclusion.json` | 같은 문서 §GV-1c 코드 블록(284~294행) | 05 **v1.22** | 2026-10-20 |
| `gv01d_all_missing.json` | 같은 문서 §GV-1d 코드 블록(311~314행) | 05 **v1.22** | 2026-10-20 |
| `gv01e_zero_is_not_missing.json` | 같은 문서 §GV-1e 코드 블록(320~334행) | 05 **v1.22** | 2026-10-20 |
| `gv04_hysteresis.json` | 같은 문서 §GV-4 코드 블록(593~605행) — GV-4b 의 설정도 이것(«GV-4 와 동일») | 05 **v1.22** | 2026-10-20 |
| `gv04b_nan_fail_closed.json` | 같은 문서 §GV-4b 코드 블록(619~639행) | 05 **v1.22** | 2026-10-20 |
| `gv04c_downward_immediate.json` | 같은 문서 §GV-4c 코드 블록(666~676행) | 05 **v1.22** | 2026-10-20 |
| `gv04d_bull_to_neutral.json` | 같은 문서 §GV-4d 코드 블록(691~701행) | 05 **v1.22** | 2026-10-20 |
| `gv04e_bear_to_neutral_wait.json` | 같은 문서 §GV-4e 코드 블록(719~729행) | 05 **v1.22** | 2026-10-20 |
| `gv04f_trend_deadband.json` | 같은 문서 §GV-4f 코드 블록(747~758행) | 05 **v1.22** | 2026-10-20 |
| `gv04g_boundary_mid.json` | 같은 문서 §GV-4g 코드 블록(781~791행) | 05 **v1.22** | 2026-10-20 |
| `gv04fb_trend_strict.json` | 같은 문서 §GV-4f-b 코드 블록(798~806행) | 05 **v1.22** | 2026-10-20 |
| `gv04fn_trend_nan.json` | 같은 문서 §GV-4f-n 코드 블록(813~819행) | 05 **v1.22** | 2026-10-20 |
| `gv02a_atr_wilder.json` | 같은 문서 §GV-2a 코드 블록(376~388행) — 2b 의 입력도 이것(«위와 동일 입력») | 05 **v1.22** | 2026-10-20 |
| `gv02b_chop.json` | 같은 문서 §GV-2b 코드 블록(428~431행) | 05 **v1.22** | 2026-10-20 |
| `gv02c_adx_warmup.json` | 같은 문서 §GV-2c 코드 블록(441~444행) | 05 **v1.22** | 2026-10-20 |
| `gv02d_wilder_rma.json` · `gv02d_tolerance.json` | 같은 문서 §GV-2d 코드 블록 2개(450~453행 · 459행 — 허용오차 1e-5 는 v1.5 가 따로 적은 블록) | 05 **v1.22** | 2026-10-20 |
| `gv02e_bbw.json` | 같은 문서 §GV-2e 코드 블록(467~471행) | 05 **v1.22** | 2026-10-20 |
| `gv02f_adx_values.json` | 같은 문서 §GV-2f 코드 블록(491~505행) — 생성식은 문자열이라 테스트가 같은 식을 옮겨 쓰고 문자열 일치를 단언한다 | 05 **v1.22** | 2026-10-20 |
| `gv08_sizing.json` | `08_파일럿/파일럿1/tests/golden/gv08_sizing.json` — 파일 통째(sha256 원본과 같음) | 파일 커밋 `d479e19` | 2026-10-19 |
| `gv08_machine_block.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-8 «🆕 v1.5 — GV-8 기계 채점 블록» 코드 블록(1082~1105행) | 05 **v1.22** | 2026-10-19 |
| `gv03_exposure_gate.json` | 같은 문서 §GV-3 코드 블록(525~535행) | 05 **v1.22** | 2026-10-19 |
| `gv03c_unknown_fail_closed.json` | 같은 문서 §GV-3c 코드 블록(549~555행) | 05 **v1.22** | 2026-10-19 |
| `ledger_hash_v1.json` | 🆕 E11h1 — 원본이 설계 저장소가 아니라 **이 저장소의 `tool/make_ledger_hash_golden.py`**(Python 표준 라이브러리만 · Dart 와 독립된 구현)다. 규칙 = 설계 13 §8 R51 H3~H8(정규 행 · 실수 표기 · 문자열 이스케이프 · 한국 날짜 귀속 · day_hash · 체인 · 축약). 🔴 손으로 고치지 않는다 — 규칙을 바꾸면 스크립트를 고치고 다시 만들며 `hashFormatVersion` 을 올린다(01 §6-7) · sha256 `c434602d057da6c40d7e43765bafc4ad561d89ce4cc59ff03b3b22a18c206d9a` | 생성 스크립트 = 브랜치 `feat/E11h1-ledger-hash` | 2026-11-04 |

sha256(복사본 — `sha256sum *.json`):

```
573f027dbdb5bea992d7d0d8eb298136e7b83d924830bdda0aa80d13d9450850  golden_p0s.json
9798993f3be911bc9d86954b61f4b4243786218d947cdf15e5ac08d7561e1f3e  gv28d_deposit.json
61692a7df88697bf5b7b08a05b70af703f72eadbf45e38f7f416c65e3c8fecc7  gv22_sleeve_c_gold_cap.json
2deb53d95e7839559d14fce69702206ca0d2ea0d8e8889aab574119a3fc3058f  gv20_sleeve_b_tranche.json
b5327db1e701fdc505502ce2ab5dabeb51b198a00e70f703f9646f3904d24567  gv23_partial_exit.json
4934e65af8227945f2b095b64afa428e8822113cfac01845f795634ffeacb8c4  gv35_38_decisions.json
38cecab31bac0101e10c8b19f86f8f19831252b114032fc3de92471c27deb405  gv11_trade_cost.json
4296b284a5bc3adfefba0abe83423330a1dd84cbe0eaa4d252a7d6e9c056898f  gv11d_participation.json
1252d7b91e7a95bf9b3710ea2d4fa84312c45c59999d507961d1ab467b38c4b6  gv11e_tier_boundary_us.json
a15de897a6c54f0beecab13e05922bd63115605bf35191b905d0c3d6e69a5981  gv19_cost_in_pnl.json
3e58ac36b3be37759b83d5c22ae650f0ce4ff3b2b2aa0502658411cdaa837536  gv24_holding_cost.json
fab43cf169e63d3b2e3be5cb549fce054d25e23efdd3d94cf36228a352e8dbbf  gv42_allocation.json
a41ab978523027bc99c7664bf2d27e624ca697c6daeeba7266aa2eceaf3fdea6  gv01a_all_valid.json
a19805864e839ee6667c04a6b29cfe5831cf93750ac2358945022ddb6aff43fe  gv01b_two_missing.json
b35bc2f185cc6e2202b9cbc624f9299ccb99959af8551c5608208f7fe2d80ebb  gv01c_category_exclusion.json
7253a02984e4252dffe02ae64584aa3ae30ed637dcf80e257ebd4d67b3a9b982  gv01d_all_missing.json
893c94d94b60c4e9d9c7f6f8c9b0b8e68871ff20da9794cb9cb728b71b871b00  gv01e_zero_is_not_missing.json
0b46e6d16ad26b3908aed6f9ff89942e2b63f8b41aec8dee91b0520eced338c8  gv02a_atr_wilder.json
eed6928eaa1bd91e36c42cc1dc8b0a9ea7d1e0b1b4ce44bcda911968d30f32d2  gv02b_chop.json
2d50a7e5d794a4b6743308b7ed29d96f1e65f6130295f0f6983a6f80c67a1e87  gv02c_adx_warmup.json
4885c7510a5257f620511308def45a25c6b8889eeca024ea145e65fbea32d184  gv02d_tolerance.json
667c5a6873e339c122891e67543384d8eaaeec90365007b1f9115808b4c7c0f9  gv02d_wilder_rma.json
b2c3bb1d25dae278fe8e0fb390bac11e1fd93bffe151268cfdc94259694e4409  gv02e_bbw.json
6e7249a9d35788570415a45fb1eed80e84168c5f6704faf145c15b3e53632d1e  gv02f_adx_values.json
e129f3e5c64aeea318c1c1569f46ff99fde2669ff02cf63e984569b99d513ee0  gv09_idempotency_key.json
31b3638927c3322cd0099be7ecce480af78b553125f9b4c0ef8ceb6d989e271a  gv12_trading_day.json
75bb7bae52c08254637de59b1f9443ef1610abe0544a97beb46ca96d0bf7fb02  gv12c_last_session_negative.json
bd9716f1e6ce14525e659bafc64d6dd52c429b48517cae8e5b7d8fd85b69f797  gv13_decision_id.json
0c3d102bb8f1e229a1d38983d0682bcba1270282904e0e8476e7daa23f7f16d8  gv30_split_execution.json
8b3546977f2280f11a48f20313abd8d0419701ca1432404038d015d9cf632caa  gv17_fail_closed.json
00ec726fe83e363ab2c79e678c90114310e217737987a58cff4c21e7d01b193a  gv18_exposure_multiplier.json
ba67b95e245664103a67ff8bd3de7ddacf0bb9f8fc0a7fa52e98e260512a4ebd  gv31_breaker_vectors.json
e804a744586588a36d1cb6f79e3fb2a1e7f020208a03ccf5b5d5d4ea422b0b22  gv31_s_h5_1_J1_stopped.json
6747c17f86950cbd0b8db5e3a2d5d845bfd4bad37d744312f3500b8504ed610e  gv32_saf_vectors.json
aad01ad857af429b00af3b50323430fb8feef162a566cce715f631ea316df2a6  gv39_trace_vectors.json
3aec46c1f7582f27e5e7f0fb257858c1b58a1e0f59587467a5bb1862b411fba9  sessions_xkrx.json
4c9f436b4bad413636bd38f25961630fdf2d6ade88fc6cd2be8b952f77895195  sessions_xnys.json
a0a15d8697ef6b32d6689990750ecd27a711e6b97dfd74e2bc62b5e8f5ebed5b  gv03_exposure_gate.json
d156edff943a329a7702362466528291e852d5dbc664f70f07d6e2503121e1e1  gv03c_unknown_fail_closed.json
89635795b2eb36293e6922638a070a4eaab75716d56af0b46b8a4e7396dc62c2  gv04_hysteresis.json
4f8c01e695d70af581f9c66bc0e4bbb63b7ea9e299dc8d34aa0eb6c6213c42e5  gv04b_nan_fail_closed.json
9929095508b0f3073c17746dd9e8841a36080865689a9b8f1fe6bbf7744e4948  gv04c_downward_immediate.json
1f69cdd99ebf61656f051327a276cfb96ad7d81ade2ee6c2567f463ef7c7727b  gv04d_bull_to_neutral.json
1ae8e3de20c0785b5c84294004f91506c0c12516b9d1a2118472e04a5914c1b0  gv04e_bear_to_neutral_wait.json
2b5fcbfcd6ba4ed707ffe2291e9bfff9e32350f6d4b8aa19bc9803afc052e34b  gv04f_trend_deadband.json
9d841b84ca3298d513496e220eb36d3684281b2a9fead690c055f8095fdf174e  gv04fb_trend_strict.json
d876ce09cbaa42db1d485b2031bc0282e94cd61288934eddd1b1ad4847beb10f  gv04fn_trend_nan.json
e57019f905b2179ad7c30d4509af11ad5e4ec52db9129bcf8fbfea7e16f19a63  gv04g_boundary_mid.json
b641fabb30a5ce8ea898fd93ca3c62276b850f21c517b68c37b9282a5ec76025  gv08_machine_block.json
bdbd9b654b1b72ff320d96015c9b06dfa69612a70a8f63a6d2816d8bd642e4cc  gv08_sizing.json
```

## 일부러 옮기지 않은 것

- **파일럿1 `GV-3_exposure_gate.json`** — 두 번째 인자가 원시 점수 `trendiness` 이고 35 와 직접 비교하는 **v1.9 이전 의미**다. 05 v1.10 이 «`trend_state`(히스테리시스를 거친 상태)를 받는다»로 바꾸며 폐기했다(05 §GV-3 주석 · 03 §1-8). 이 파일로 시험하면 폐기된 규칙을 정답으로 고정하게 된다. 경계값(35/45 · 3봉 확인)은 GV-4f 몫이고 E2 에서 들어온다.
- **05 §GV-8e 블록** — `expect` 칸이 산문(«ValueError (손절가가 진입가 이상)»)이라 기계 판정이 안 된다. 같은 4건을 구조화한 파일럿1 판(`exception_cases`)을 쓴다.
- **파일럿1 `GV-2_indicators.json`** — 05 v1.22 보다 낡았다: 2e(BBW)·2f(ADX 실제 값)가 없고 2d 허용오차가 v1.5 이전 값(1e-6)이다. 2a·2b·2c 값은 05 본문과 같다(2b 는 v1.4 정정값).
- **파일럿1 `GV-1_regime_categories.json`** — 1c 의 `indicator_means.BREADTH` 가 **60.0**(05 v1.5 가 «50% 임계를 빠뜨린 구현도 같은 값을 내 판별력 0» 이라며 90.0 으로 고친 옛 값)이고 1e 가 없다.
- **파일럿1 `GV-4_hysteresis.json`** — GV-4 본 벡터만 있고 4b~4g·4f-b·4f-n 이 없다.
