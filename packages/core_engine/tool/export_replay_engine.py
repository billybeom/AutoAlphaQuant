# -*- coding: utf-8 -*-
"""E6c~E6e 재현 정답지 — 참조 엔진(백테스트6)의 S7(P0S 정본) 실행 원장·일별 기록을 그대로 내보낸다.

`exp/N2_golden_p0s.py` 의 S7 실행과 같은 설정: `Config(start="2000-01-03", end="2026-08-14", preset="P0S")` ·
`ramp_months = 6` · 시장 = `apply_p0_market(market.build())`. 🔴 `market.build()` 는 캐시 번들(`data/market_bundle.pkl`)을
**읽기만** 한다 — 캐시가 없으면 새로 쓰므로 그때는 멈춘다(설계 저장소에 아무것도 쓰지 않는다). 이식 지도 §0-2:
캐시 번들 = CSV 에서 새로 만든 번들(비트 일치) · 이 실행 = 골든(CAGR 11.133096 · 934행 · 24,289,863.12원).

실행(저장소 밖 가상환경 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_engine.py <설계 저장소>/09_백테스트/백테스트6
산출: packages/core_engine/test/replay/fixtures/s7_engine.json.gz (gzip 머리 시각 0)
"""
from __future__ import annotations

import gzip
import json
import math
import os
import pathlib
import sys

sys.dont_write_bytecode = True
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "fixtures" / "s7_engine.json.gz"


def num(v):
    v = float(v)
    return None if math.isnan(v) else v


def main(bt6: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, bt6)
    import pandas as pd
    from engine import market as M
    from engine.backtest import Backtest
    from engine.config import Config

    if not os.path.exists(M.CACHE):
        raise SystemExit(f"캐시 번들이 없다 — market.build() 가 새로 쓰게 되므로 멈춘다: {M.CACHE}")
    mkt = M.apply_p0_market(M.build())
    cfg = Config(start="2000-01-03", end="2026-08-14", label="S7_P0S", preset="P0S")
    cfg.ramp_months = 6
    res = Backtest(cfg, mkt).run()
    led, eq, ev = res["ledger"], res["equity"], res["events"]

    ledger = [[r.date.strftime("%Y-%m-%d"), r.sleeve, r.symbol, r.side, num(r.qty), num(r.price),
               num(r.gross_krw), num(r.cost_krw), r.event, r.dir_state, r.breaker] for r in led.itertuples()]
    cols = ["equity", "A", "B", "C", "c_krw", "c_park_c", "c_iei", "c_iau", "b_park", "pot", "dd"]
    daily = {"date": [d.strftime("%Y-%m-%d") for d in eq.index]}
    for c in cols:
        daily[c] = [num(x) for x in eq[c].to_numpy(dtype=float)]
    daily["breaker"] = list(eq["breaker"])
    daily["dir_state"] = list(eq["dir_state"])
    events = [[r.date.strftime("%Y-%m-%d"), r.kind] for r in ev.itertuples()] if len(ev) else []
    doc = {
        "meta": {"purpose": "참조 엔진 백테스트6 S7(P0S) 실행 원장·일별 기록 — E6c~E6e 대조", "pandas": pd.__version__,
                 "config": "preset=P0S start=2000-01-03 end=2026-08-14 ramp_months=6",
                 "ledger_columns": ["date", "sleeve", "symbol", "side", "qty", "price", "gross_krw", "cost_krw",
                                    "event", "dir_state", "breaker"],
                 "n_ledger": len(ledger), "cost_krw_sum": float(led["cost_krw"].sum()),
                 "generator": "packages/core_engine/tool/export_replay_engine.py"},
        "ledger": ledger, "daily": daily, "events": events,
    }
    raw = (json.dumps(doc, ensure_ascii=False, separators=(",", ":")) + "\n").encode("utf-8")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_bytes(gzip.compress(raw, compresslevel=9, mtime=0))
    print("원장", len(ledger), "· 비용", round(doc["meta"]["cost_krw_sum"], 2), "· 일별", len(daily["date"]),
          "· 끝 자산", daily["equity"][-1], "→", OUT.name, f"({OUT.stat().st_size:,} 바이트)")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_engine.py <설계 저장소>/09_백테스트/백테스트6")
    main(sys.argv[1])
