# -*- coding: utf-8 -*-
"""E6a 재현 정답지 — 참조 엔진(백테스트6)의 세션·월말·합성 시세·가격 패널을 해시와 표본 값으로 내보낸다.

참조 엔진 코드를 **그대로** 부른다: `engine/market.py::build` 본문(새틀라이트 유니버스·캐시 pkl 쓰기만 뺌) →
`apply_p0_market`(IEI ← UST10) → `Backtest(Config(preset="P0S"))._prep()`. 새틀라이트 패널은 P0S 가 쓰지 않으므로
빈 껍데기를 넣는다. 설계 저장소에는 아무것도 쓰지 않는다(바이트코드 포함).

실행(저장소 밖 가상환경 — pandas·numpy 필요 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_market.py <설계 저장소>/09_백테스트/백테스트6
산출: packages/core_engine/test/replay/fixtures/market_parity.json

해시 = float64(리틀 엔디언) 바이트를 이어 붙인 sha256(NaN = 0x7ff8000000000000) · 날짜 목록은 «YYYY-MM-DD\n» 을 이어 붙인 sha256.
"""
from __future__ import annotations

import hashlib
import json
import math
import pathlib
import struct
import sys

sys.dont_write_bytecode = True
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "fixtures" / "market_parity.json"
NAN = struct.pack("<Q", 0x7FF8000000000000)


def fhash(values) -> str:
    h = hashlib.sha256()
    for v in values:
        v = float(v)
        h.update(NAN if math.isnan(v) else struct.pack("<d", v))
    return h.hexdigest()


def dhash(dates) -> str:
    h = hashlib.sha256()
    for d in dates:
        h.update((d.strftime("%Y-%m-%d") + "\n").encode())
    return h.hexdigest()


def series_doc(s, picks=()) -> dict:
    import pandas as pd
    s = pd.Series(s)
    doc = {"n": int(len(s)), "first": s.index[0].strftime("%Y-%m-%d"), "last": s.index[-1].strftime("%Y-%m-%d"),
           "dates_sha256": dhash(s.index), "values_sha256": fhash(s.to_numpy(dtype=float)),
           "nan": int(s.isna().sum())}
    samples = {}
    for d in list(picks) + [s.index[0], s.index[-1]]:
        d = pd.Timestamp(d)
        if d in s.index:
            samples[d.strftime("%Y-%m-%d")] = repr(float(s.loc[d]))
    doc["samples"] = samples
    return doc


def main(bt6: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, bt6)
    import pandas as pd
    from engine import data as D, regime as R, market as M
    from engine.backtest import Backtest
    from engine.config import Config

    raw = D.load_all()
    idx = D.us_index(raw)
    fx = D.usdkrw(raw)
    norm = R.normalize(R.build_raw_indicators(raw, idx))
    ds = R.direction_score(norm, idx.index)
    tr = R.trendiness_score(idx)
    fsm = R.run_fsm(ds["direction"], tr)
    fsm = fsm.join(ds[["trend", "breadth", "volatility", "credit", "macro"]])
    kq = D.kosdaq(raw)
    tskr = R.trend_score_kr(kq)
    us_sessions, kr_sessions = idx.index, kq.index
    sb_us = D.sleeve_b_assets(raw)
    sb = {t: M._to_kr_calendar(s, kr_sessions, fx).ffill() for t, s in sb_us.items()}
    krw_cash = D.krw_cash_index(raw, kr_sessions)
    usd_cash = D.usd_cash_index(raw, us_sessions)
    iei = D.ust5y_index(raw, us_sessions)
    gold_usd = pd.to_numeric(raw["gold_fut"]["Close"], errors="coerce").dropna()
    iau = gold_usd.reindex(us_sessions).ffill()
    empty = pd.DataFrame(index=pd.DatetimeIndex([us_sessions[0]]))
    sat = {"adj": empty, "sma50": empty, "atr": empty, "mom": empty, "adv20": empty,
           "passed": empty.astype(bool), "meta": {}}
    bundle = dict(raw_keys=sorted(raw.keys()), fx=fx, us_index=idx, fsm=fsm, kosdaq=kq, kospi=None,
                  trend_score_kr=tskr, us_sessions=us_sessions, kr_sessions=kr_sessions, sleeve_b=sb,
                  krw_cash=krw_cash, usd_cash=usd_cash, iei=iei, iau=iau, sat=sat, bench=None)
    m = M.apply_p0_market(bundle)
    cfg = Config(preset="P0S")
    bt = Backtest(cfg, m)
    bt._prep()

    picks = ["2000-01-03", "2000-08-31", "2008-12-30", "2020-03-23", "2026-06-02", "2026-06-04", "2026-08-14"]
    doc = {
        "meta": {
            "purpose": "참조 엔진 백테스트6 market.build + apply_p0_market + Backtest._prep 산출 — E6a 대조",
            "pandas": pd.__version__, "config": f"preset=P0S start={cfg.start} end={cfg.end}",
            "generator": "packages/core_engine/tool/export_replay_market.py",
        },
        "sessions": {
            "us_all": {"n": len(us_sessions), "sha256": dhash(us_sessions)},
            "kr_all": {"n": len(kr_sessions), "sha256": dhash(kr_sessions)},
            "us": {"n": len(bt.us), "sha256": dhash(bt.us)},
            "kr": {"n": len(bt.kr), "sha256": dhash(bt.kr)},
            "all_days": {"n": len(bt.all_days), "sha256": dhash(bt.all_days)},
            "us_month_ends": {"n": len(bt.us_me), "sha256": dhash(sorted(bt.us_me))},
            "kr_month_ends": {"n": len(bt.kr_me), "sha256": dhash(sorted(bt.kr_me))},
            "kr_tail": {"n": len(bt.kr_tail), "sha256": hashlib.sha256("".join(
                f"{d.strftime('%Y-%m-%d')},{i},{k}\n" for d, (i, k) in sorted(bt.kr_tail.items())).encode()).hexdigest()},
        },
        "series": {
            "fx": series_doc(fx, picks),
            "sleeve_b_us_133690": series_doc(sb_us["133690"], picks),
            "sleeve_b_us_411060": series_doc(sb_us["411060"], picks),
            "sleeve_b_kr_133690": series_doc(sb["133690"], picks),
            "sleeve_b_kr_411060": series_doc(sb["411060"], picks),
            "krw_cash": series_doc(krw_cash, picks),
            "ust10": series_doc(m["d2_override"]["IEI"], picks),
            "iau": series_doc(iau, picks),
            "kosdaq_close": series_doc(kq["close"], picks),
        },
        "px": {c: series_doc(bt.PX[c], picks) for c in ["fx", "A", "PARK", "CKRW", "IEI", "IAU", "133690", "411060"]},
        "b_monthly": {t: {"n": len(me), "keys_sha256": hashlib.sha256("".join(
            f"{d.strftime('%Y-%m')}\n" for d in me.index).encode()).hexdigest(), "values_sha256": fhash(me.to_numpy(dtype=float)),
            "last": [me.index[-1].strftime("%Y-%m"), repr(float(me.iloc[-1]))]} for t, me in bt.b_monthly.items()},
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    s = doc["sessions"]
    print("US", s["us"]["n"], "KR", s["kr"]["n"], "합집합", s["all_days"]["n"], "· 월말 KR", s["kr_month_ends"]["n"],
          "US", s["us_month_ends"]["n"], "→", OUT.name)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_market.py <설계 저장소>/09_백테스트/백테스트6")
    main(sys.argv[1])
