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

🔴 데이터·정답지를 손으로 고치지 않는다 — 원본이 바뀌면 두 도구를 다시 돌리고 해시를 갱신한다.
🔴 저장소는 비공개여야 한다(원천 = Yahoo·FRED·FDR 공개 시세의 재현용 사본).
