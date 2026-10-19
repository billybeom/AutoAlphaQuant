# 정답지 출처 — `test/golden/vectors/`

> 🔴 여기 파일은 **원본을 그대로 옮긴 것**이다. 값을 고치지 않는다(`../README.md` 규칙 1·3).
> 원본이 바뀌면 다시 복사하고 이 표의 sha256·복사일을 갱신한다 — 손으로 고친 정답지는 위조다.
> 🔴 파일 이름을 `*.golden.json` 꼴로 짓지 않는다 — CI «골든 스냅샷» 잡이 그 꼴을 화면 스냅샷으로 보고 수정·삭제를 막는다(`.github/workflows/ci.yml`).
> 원본 경로는 설계 저장소(`C:\Work\클로드-백그라운드-작업\투자`, 커밋 `ba91cc3` 기준) 상대 경로다.

| 파일 | 원본 | 원본 판 | 복사일 |
|---|---|---|---|
| `gv08_sizing.json` | `08_파일럿/파일럿1/tests/golden/gv08_sizing.json` — 파일 통째(sha256 원본과 같음) | 파일 커밋 `d479e19` | 2026-10-19 |
| `gv08_machine_block.json` | `06_시스템설계/05_수용기준_골든벡터.md` §GV-8 «🆕 v1.5 — GV-8 기계 채점 블록» 코드 블록(1082~1105행) | 05 **v1.22** | 2026-10-19 |
| `gv03_exposure_gate.json` | 같은 문서 §GV-3 코드 블록(525~535행) | 05 **v1.22** | 2026-10-19 |
| `gv03c_unknown_fail_closed.json` | 같은 문서 §GV-3c 코드 블록(549~555행) | 05 **v1.22** | 2026-10-19 |

sha256(복사본 — `sha256sum *.json`):

```
a0a15d8697ef6b32d6689990750ecd27a711e6b97dfd74e2bc62b5e8f5ebed5b  gv03_exposure_gate.json
d156edff943a329a7702362466528291e852d5dbc664f70f07d6e2503121e1e1  gv03c_unknown_fail_closed.json
b641fabb30a5ce8ea898fd93ca3c62276b850f21c517b68c37b9282a5ec76025  gv08_machine_block.json
bdbd9b654b1b72ff320d96015c9b06dfa69612a70a8f63a6d2816d8bd642e4cc  gv08_sizing.json
```

## 일부러 옮기지 않은 것

- **파일럿1 `GV-3_exposure_gate.json`** — 두 번째 인자가 원시 점수 `trendiness` 이고 35 와 직접 비교하는 **v1.9 이전 의미**다. 05 v1.10 이 «`trend_state`(히스테리시스를 거친 상태)를 받는다»로 바꾸며 폐기했다(05 §GV-3 주석 · 03 §1-8). 이 파일로 시험하면 폐기된 규칙을 정답으로 고정하게 된다. 경계값(35/45 · 3봉 확인)은 GV-4f 몫이고 E2 에서 들어온다.
- **05 §GV-8e 블록** — `expect` 칸이 산문(«ValueError (손절가가 진입가 이상)»)이라 기계 판정이 안 된다. 같은 4건을 구조화한 파일럿1 판(`exception_cases`)을 쓴다.
