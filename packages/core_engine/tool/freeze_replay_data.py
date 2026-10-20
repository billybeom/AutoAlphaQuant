# -*- coding: utf-8 -*-
"""엔진 재현(E6) 입력 데이터 동결기 — 참조 엔진(백테스트6)이 P0S 에서 읽는 원천 CSV 24개를 gzip 으로 옮긴다.

왜: `golden_p0s.json`(05 GV-P0S)을 Dart 엔진이 4자리까지 재현하려면 참조 엔진과 **같은 입력**이 필요하다.
발주자 결정(2026-10-20 · 설계 저장소 11_앱설계/13_엔진레인_착수계획.md §8 R3): 원천 CSV 24개만
비공개 앱 저장소에 동결한다 — 새틀 유니버스·개별주 패널·캐시 pkl 은 P0S 가 쓰지 않아 넣지 않는다.

실행(표준 라이브러리만 씀):
    python -I packages/core_engine/tool/freeze_replay_data.py <설계 저장소>/09_백테스트/data
산출: packages/core_engine/test/replay/data/<이름>.csv.gz · MANIFEST.json

🔴 바이트를 고치지 않는다(줄 끝·열·기간 그대로). gzip 머리의 시각은 0 으로 고정해 같은 입력이면 같은 해시다.
🔴 목록은 참조 엔진 `engine/data.py::load_all` 과 같아야 한다 — 바뀌면 이 목록도 바꾼다.
"""
from __future__ import annotations

import gzip
import hashlib
import json
import pathlib
import sys

NAMES = [
    "gspc", "spy", "qqq", "ndx", "vix", "vix3m", "rsp",
    "gold_fut", "gld", "iau", "bil", "iei",
    "usdkrw_fred", "nfci", "t10y3m", "cfnai_ma3", "sahm",
    "dgs3mo", "dgs5", "kr_3m", "ofr_fsi", "kq11", "ks11", "usdkrw_fdr",
]
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "data"


def main(src: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    src_dir = pathlib.Path(src)
    OUT.mkdir(parents=True, exist_ok=True)
    files = {}
    for name in NAMES:
        raw = (src_dir / f"{name}.csv").read_bytes()
        gz = gzip.compress(raw, compresslevel=9, mtime=0)
        (OUT / f"{name}.csv.gz").write_bytes(gz)
        files[name] = {
            "source": f"09_백테스트/data/{name}.csv",
            "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest(),
            "crlf": b"\r\n" in raw,
            "gz_sha256": hashlib.sha256(gz).hexdigest(),
        }
        print(f"{name:12} {len(raw):>9,} → {len(gz):>8,}")
    manifest = {
        "meta": {
            "purpose": "E6 엔진 재현 입력 — 참조 엔진 백테스트6 engine/data.py::load_all 의 24개",
            "decision": "발주자 2026-10-20 (설계 13 §8 R3)",
            "as_of": "2026-08-14",
            "generator": "packages/core_engine/tool/freeze_replay_data.py",
        },
        "files": files,
    }
    (OUT / "MANIFEST.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=1) + "\n",
        encoding="utf-8", newline="\n")
    total = sum(f["bytes"] for f in files.values())
    gz_total = sum((OUT / f"{n}.csv.gz").stat().st_size for n in NAMES)
    print(f"합계 {total:,} → {gz_total:,} 바이트")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: freeze_replay_data.py <09_백테스트/data 경로>")
    main(sys.argv[1])
