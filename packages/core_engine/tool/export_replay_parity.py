# -*- coding: utf-8 -*-
"""E6 재현 정답지 내보내기 — 참조 엔진(백테스트6)이 읽은 값을 Dart 가 비트까지 같게 읽는지 볼 해시.

왜: pandas `read_csv` 의 기본 수 변환(`float_precision=None` = `precise_xstrtod`)은 정확 반올림이 아니다 —
24개 CSV 807,854 셀 중 64,661 셀이 Python `float()`(= Dart `double.parse`)와 최대 2 ULP 다르다(2026-10-20 실측).
골든(`golden_p0s.json`)은 이 기본 변환으로 만들어졌으므로 Dart 도 같은 변환을 써야 첫날부터 갈리지 않는다.

실행(저장소 밖 가상환경 — pandas 필요 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_parity.py <설계 저장소>/09_백테스트/data
산출: packages/core_engine/test/replay/fixtures/parse_parity.json

해시 = 열마다 float64(리틀 엔디언) 바이트를 이어 붙인 sha256. NaN 은 0x7ff8000000000000 하나로 맞춘다.
"""
from __future__ import annotations

import hashlib
import json
import math
import pathlib
import struct
import sys

import pandas as pd

HERE = pathlib.Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True   # tool/__pycache__ 를 저장소에 남기지 않는다
sys.path.insert(0, str(HERE / "tool"))
from freeze_replay_data import NAMES  # noqa: E402

OUT = HERE / "test" / "replay" / "fixtures" / "parse_parity.json"
NAN = struct.pack("<Q", 0x7FF8000000000000)


def column_hash(values) -> str:
    h = hashlib.sha256()
    for v in values:
        v = float(v)
        h.update(NAN if math.isnan(v) else struct.pack("<d", v))
    return h.hexdigest()


def main(src: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    files = {}
    for name in NAMES:
        # 참조 엔진 engine/data.py::_read 와 같은 호출 — index_col=0 · 기본 float_precision.
        df = pd.read_csv(pathlib.Path(src) / f"{name}.csv", index_col=0)
        cols = {}
        for col in df.columns:
            s = pd.to_numeric(df[col], errors="coerce")   # engine/data.py::_num 과 같은 변환
            cols[col] = {"rows": int(len(s)), "nan": int(s.isna().sum()), "sha256": column_hash(s.to_numpy())}
        files[name] = {"index_first": str(df.index[0]), "index_last": str(df.index[-1]), "columns": cols}
    doc = {
        "meta": {
            "purpose": "pandas read_csv(index_col=0) + to_numeric(coerce) 가 읽은 float64 비트의 열별 해시",
            "pandas": pd.__version__,
            "float_precision": "None (precise_xstrtod)",
            "generator": "packages/core_engine/tool/export_replay_parity.py",
        },
        "files": files,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    print("열", sum(len(f["columns"]) for f in files.values()), "→", OUT.name)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_parity.py <09_백테스트/data 경로>")
    main(sys.argv[1])
