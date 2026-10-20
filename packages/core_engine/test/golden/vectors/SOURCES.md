# 정답지 출처 — `test/golden/vectors/`

> 🔴 여기 파일은 **원본을 그대로 옮긴 것**이다. 값을 고치지 않는다(`../README.md` 규칙 1·3).
> 원본이 바뀌면 다시 복사하고 이 표의 sha256·복사일을 갱신한다 — 손으로 고친 정답지는 위조다.
> 🔴 파일 이름을 `*.golden.json` 꼴로 짓지 않는다 — CI «골든 스냅샷» 잡이 그 꼴을 화면 스냅샷으로 보고 수정·삭제를 막는다(`.github/workflows/ci.yml`).
> 원본 경로는 설계 저장소(`C:\Work\클로드-백그라운드-작업\투자`, E1 = 커밋 `ba91cc3` · E2a = 커밋 `d3aaabb` 기준) 상대 경로다.

| 파일 | 원본 | 원본 판 | 복사일 |
|---|---|---|---|
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

sha256(복사본 — `sha256sum *.json`):

```
0b46e6d16ad26b3908aed6f9ff89942e2b63f8b41aec8dee91b0520eced338c8  gv02a_atr_wilder.json
eed6928eaa1bd91e36c42cc1dc8b0a9ea7d1e0b1b4ce44bcda911968d30f32d2  gv02b_chop.json
2d50a7e5d794a4b6743308b7ed29d96f1e65f6130295f0f6983a6f80c67a1e87  gv02c_adx_warmup.json
4885c7510a5257f620511308def45a25c6b8889eeca024ea145e65fbea32d184  gv02d_tolerance.json
667c5a6873e339c122891e67543384d8eaaeec90365007b1f9115808b4c7c0f9  gv02d_wilder_rma.json
b2c3bb1d25dae278fe8e0fb390bac11e1fd93bffe151268cfdc94259694e4409  gv02e_bbw.json
6e7249a9d35788570415a45fb1eed80e84168c5f6704faf145c15b3e53632d1e  gv02f_adx_values.json
a0a15d8697ef6b32d6689990750ecd27a711e6b97dfd74e2bc62b5e8f5ebed5b  gv03_exposure_gate.json
d156edff943a329a7702362466528291e852d5dbc664f70f07d6e2503121e1e1  gv03c_unknown_fail_closed.json
b641fabb30a5ce8ea898fd93ca3c62276b850f21c517b68c37b9282a5ec76025  gv08_machine_block.json
bdbd9b654b1b72ff320d96015c9b06dfa69612a70a8f63a6d2816d8bd642e4cc  gv08_sizing.json
```

## 일부러 옮기지 않은 것

- **파일럿1 `GV-3_exposure_gate.json`** — 두 번째 인자가 원시 점수 `trendiness` 이고 35 와 직접 비교하는 **v1.9 이전 의미**다. 05 v1.10 이 «`trend_state`(히스테리시스를 거친 상태)를 받는다»로 바꾸며 폐기했다(05 §GV-3 주석 · 03 §1-8). 이 파일로 시험하면 폐기된 규칙을 정답으로 고정하게 된다. 경계값(35/45 · 3봉 확인)은 GV-4f 몫이고 E2 에서 들어온다.
- **05 §GV-8e 블록** — `expect` 칸이 산문(«ValueError (손절가가 진입가 이상)»)이라 기계 판정이 안 된다. 같은 4건을 구조화한 파일럿1 판(`exception_cases`)을 쓴다.
- **파일럿1 `GV-2_indicators.json`** — 05 v1.22 보다 낡았다: 2e(BBW)·2f(ADX 실제 값)가 없고 2d 허용오차가 v1.5 이전 값(1e-6)이다. 2a·2b·2c 값은 05 본문과 같다(2b 는 v1.4 정정값).
