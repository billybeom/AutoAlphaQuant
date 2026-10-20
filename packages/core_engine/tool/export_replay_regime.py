# -*- coding: utf-8 -*-
"""E6b 재현 정답지 — 참조 엔진(백테스트6)의 국면 파이프라인 산출을 해시·표본 값으로 내보낸다.

참조 엔진 코드를 그대로 부른다: `regime.build_raw_indicators` → `normalize` → `direction_score` →
(추세성 세 부분) → `trendiness_score` → `run_fsm` · `trend_score_kr`. 설계 저장소에는 아무것도 쓰지 않는다.

실행(저장소 밖 가상환경 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_regime.py <설계 저장소>/09_백테스트/백테스트6
산출: packages/core_engine/test/replay/fixtures/regime_parity.json

🔵 원지표(백분위 전)는 이동평균 합산 순서(pandas 온라인 합 ↔ Dart 왼쪽 합)에 따라 끝자리가 다를 수 있어
   표본 값만 싣는다(허용오차 비교). 정규화 이후는 순위 기반이라 비트 해시로 본다(이식 지도 §0-3 실측).
"""
from __future__ import annotations

import hashlib
import json
import math
import pathlib
import struct
import sys

sys.dont_write_bytecode = True
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "fixtures" / "regime_parity.json"
NAN = struct.pack("<Q", 0x7FF8000000000000)


def fhash(values) -> str:
    h = hashlib.sha256()
    for v in values:
        v = float(v)
        h.update(NAN if math.isnan(v) else struct.pack("<d", v))
    return h.hexdigest()


def shash(values) -> str:
    return hashlib.sha256("".join(f"{v}\n" for v in values).encode()).hexdigest()


def main(bt6: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, bt6)
    import numpy as np
    import pandas as pd
    from engine import data as D, regime as R, indicators as I

    raw = D.load_all()
    idx = D.us_index(raw)
    cal = idx.index
    raws = R.build_raw_indicators(raw, idx)
    norm = R.normalize(raws)
    ds = R.direction_score(norm, cal)
    h, l, c = idx["high"], idx["low"], idx["close"]
    tparts = {
        "chop": I.pit_percentile(100.0 - I.chop(h, l, c, 14), R.MIN_PERIODS_PCT),
        "adx": I.pit_percentile(I.adx(h, l, c, 14, 150), R.MIN_PERIODS_PCT),
        "bbw": I.rolling_percentile(I.bbw(c, 20, 2.0), 126),
    }
    tr = R.trendiness_score(idx)
    fsm = R.run_fsm(ds["direction"], tr)

    kq = D.kosdaq(raw)
    kc = kq["close"]
    s50, s200 = I.sma(kc, 50), I.sma(kc, 200)
    kparts = {
        "ma200_gap": I.pit_percentile(kc / s200 - 1.0, R.MIN_PERIODS_PCT),
        "golden_cross": (s50 > s200).astype(float).where(s200.notna() & s50.notna()) * 100.0,
        "ma200_slope": (s200 > s200.shift(21)).astype(float).where(s200.shift(21).notna()) * 100.0,
        "mom_12_1": I.pit_percentile(I.momentum_12_1(kc), R.MIN_PERIODS_PCT),
    }
    tskr = R.trend_score_kr(kq)

    picks = pd.DatetimeIndex(sorted(set(cal[::200]) | {cal[-1]}))

    def samples(s):
        s = s.reindex(cal)
        return {d.strftime("%Y-%m-%d"): repr(float(s.loc[d])) for d in picks}

    first_ok = fsm.index[fsm["status"] == "OK"][0]
    from_cmp = pd.Timestamp("1985-11-27")
    start, end = pd.Timestamp("2000-01-03"), pd.Timestamp("2026-08-14")
    kr = kq.index[(kq.index >= start) & (kq.index <= end)]
    us = cal[(cal >= start) & (cal <= end)]
    all_days = us.union(kr)
    f = fsm.reindex(fsm.index.union(all_days)).sort_index().ffill().reindex(all_days)
    st = f["direction_state"].fillna("UNKNOWN")
    s = pd.Series(kr, index=kr)
    kr_me = pd.DatetimeIndex(s.groupby([s.index.year, s.index.month]).max().values)
    me_counts = st.reindex(kr_me).value_counts().to_dict()

    doc = {
        "meta": {"purpose": "참조 엔진 백테스트6 국면 파이프라인 산출 — E6b 대조", "pandas": pd.__version__,
                 "generator": "packages/core_engine/tool/export_replay_regime.py"},
        "calendar": {"n": int(len(cal)), "first": cal[0].strftime("%Y-%m-%d"), "last": cal[-1].strftime("%Y-%m-%d")},
        "raw": {k: {"nan": int(v.reindex(cal).isna().sum()), "samples": samples(v)} for k, v in raws.items()},
        "normalized": {k: {"nan": int(v.reindex(cal).isna().sum()), "sha256": fhash(v.reindex(cal).to_numpy(dtype=float))}
                       for k, v in norm.items()},
        "categories": {k: fhash(ds[k].to_numpy(dtype=float)) for k in ["trend", "breadth", "volatility", "credit", "macro"]},
        "direction": {"nan": int(ds["direction"].isna().sum()), "sha256": fhash(ds["direction"].to_numpy(dtype=float)),
                      "samples": samples(ds["direction"])},
        "trendiness_parts": {k: fhash(v.reindex(cal).to_numpy(dtype=float)) for k, v in tparts.items()},
        "trendiness": {"nan": int(tr.isna().sum()), "sha256": fhash(tr.to_numpy(dtype=float))},
        "fsm": {
            "first_ok": first_ok.strftime("%Y-%m-%d"),
            "compare_from": from_cmp.strftime("%Y-%m-%d"),
            "state_from_sha256": shash(fsm.loc[from_cmp:, "direction_state"]),
            "bars_from_sha256": shash(int(x) for x in fsm.loc[from_cmp:, "bars_in_state"]),
            "trend_from_sha256": shash(fsm.loc[from_cmp:, "trend_state"]),
            "insufficient_days": int((fsm["status"] != "OK").sum()),
            "state_counts": {k: int(v) for k, v in fsm["direction_state"].value_counts().to_dict().items()},
            "kr_month_end_counts_2000_2026": {k: int(v) for k, v in me_counts.items()},
            "early": {d.strftime("%Y-%m-%d"): [fsm.loc[d, "direction_state"], int(fsm.loc[d, "bars_in_state"])]
                      for d in fsm.loc[first_ok:from_cmp].index},
        },
        "tskr": {
            "calendar": {"n": int(len(kq.index)), "first": kq.index[0].strftime("%Y-%m-%d")},
            "parts": {k: fhash(v.to_numpy(dtype=float)) for k, v in kparts.items()},
            "nan": int(tskr.isna().sum()),
            "sha256": fhash(tskr.to_numpy(dtype=float)),
            "samples": {d.strftime("%Y-%m-%d"): repr(float(tskr.loc[d])) for d in kq.index[::300]},
        },
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    print("US", len(cal), "· 첫 OK", first_ok.date(), "· KR 월말 상태", me_counts, "→", OUT.name)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_regime.py <설계 저장소>/09_백테스트/백테스트6")
    main(sys.argv[1])
