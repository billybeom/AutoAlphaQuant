# -*- coding: utf-8 -*-
"""E7a1 재현 정답지 — 정본 세후 규약 `exp/tax_lib.py::aftertax_full` 의 S7 계산을 반올림 전 값으로 내보낸다.

`tax_lib.aftertax_full` 은 결과를 4자리로 반올림해 돌려준다(골든 `aftertax_full_S7`). 여기서는 같은 모듈의
`realized_gains` · `_apply_daily_tax` · `_cagr` · `_comprehensive_extra` 를 그대로 불러 사다리 한 갈래(`ladder`)를
**반올림 없이** 다시 적는다 — 그리고 반올림한 값이 `aftertax_full` 의 출력과 글자까지 같음을 여기서 확인한다
(옮겨 적은 것이 정본과 다르면 멈춘다).
설정 = `tool/export_replay_engine.py` 의 S7(P0S 정본 · ramp 6). 🔴 캐시 번들을 읽기만 한다(없으면 멈춘다).

실행(저장소 밖 가상환경 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_aftertax.py <설계 저장소>/09_백테스트/백테스트6
산출: packages/core_engine/test/replay/fixtures/aftertax_parity.json
"""
from __future__ import annotations

import json
import os
import pathlib
import sys

sys.dont_write_bytecode = True
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "fixtures" / "aftertax_parity.json"


def main(bt6: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, bt6)
    sys.path.insert(0, os.path.join(bt6, "exp"))
    import pandas as pd
    import numpy as np
    from engine import market as M
    from engine.backtest import Backtest
    from engine.config import Config
    import tax_lib as T

    if not os.path.exists(M.CACHE):
        raise SystemExit(f"캐시 번들이 없다 — market.build() 가 새로 쓰게 되므로 멈춘다: {M.CACHE}")
    cfg = Config(start="2000-01-03", end="2026-08-14", label="S7_P0S", preset="P0S")
    cfg.ramp_months = 6
    res = Backtest(cfg, M.apply_p0_market(M.build())).run()
    eq, ledger = res["equity"], res["ledger"]
    golden = T.aftertax_full(eq, ledger)

    # ── tax_lib.aftertax_full 본문을 반올림 없이(줄 순서 그대로) ──
    e = eq["equity"].dropna()
    yrs = (e.index[-1] - e.index[0]).days / 365.25
    e0 = float(e.iloc[0])
    g_pot = T.realized_gains(ledger, "POT")
    g_c = T.realized_gains(ledger, "C", syms=["IEI", "IAU"])
    contrib = ledger[(ledger["symbol"] == "C->B")].copy()
    contrib["year"] = pd.to_datetime(contrib["date"]).dt.year
    by_year = contrib.groupby("year")["gross_krw"].sum()
    credited = float(by_year.clip(upper=T.CREDIT_CAP).sum())
    non_credited = float((by_year - by_year.clip(upper=T.CREDIT_CAP)).sum())
    pen_end_b = float(eq["B"].dropna().iloc[-1])
    pen_end = pen_end_b + float(eq["c_park_c"].dropna().iloc[-1])
    taxable = max(0.0, pen_end - non_credited)
    refund_nominal = credited * T.CREDIT_RATE

    def ladder(pot_rate, comprehensive):
        e1 = T._apply_daily_tax(e, g_pot * pot_rate) if pot_rate > 0 else e.copy()
        e2 = T._apply_daily_tax(e1, g_c * T.T_DIV)
        extra = None
        if comprehensive:
            extra = T._comprehensive_extra(pd.concat([g_pot, g_c]).sort_index(), comprehensive)
            e2 = T._apply_daily_tax(e2, extra)
        refund_reinv = 0.0
        for y, c in by_year.items():
            amt = min(float(c), T.CREDIT_CAP) * T.CREDIT_RATE
            t = pd.Timestamp(int(y) + 1, 5, 31)
            base = e2[e2.index >= t]
            refund_reinv += amt * (float(e2.iloc[-1]) / float(base.iloc[0])) if len(base) else amt
        end2 = float(e2.iloc[-1])
        raw = {"pretax": (T._cagr(e) * 100, float(e.iloc[-1]) / e0),
               "after_pot": (T._cagr(e1) * 100, float(e1.iloc[-1]) / e0),
               "after_pot_c": (T._cagr(e2) * 100, end2 / e0)}
        for name, rate in (("wd_5p5", 0.055), ("wd_16p5", 0.165)):
            for suffix, add in (("", 0.0), ("_refund_nominal", refund_nominal), ("_refund_reinvested", refund_reinv)):
                end_v = end2 - taxable * rate + add
                raw[name + suffix] = ((end_v / e0) ** (1 / yrs) * 100 - 100, end_v / e0)
        out = {k: dict(cagr_pct=float(c), end_mult=float(m)) for k, (c, m) in raw.items()}
        out["refund_reinvested_krw"] = float(refund_reinv)
        out["e1_last"] = float(e1.iloc[-1])
        out["e2_last"] = float(e2.iloc[-1])
        if extra is not None:
            out["comprehensive_extra"] = {d.strftime("%Y-%m-%d"): float(v) for d, v in extra.items()}
        # 확인: 반올림하면 tax_lib 출력과 같다
        rounded = {k: dict(cagr_pct=round(v["cagr_pct"], 4), end_mult=round(v["end_mult"], 4))
                   for k, v in out.items() if isinstance(v, dict) and "cagr_pct" in v}
        rounded["refund_reinvested_krw"] = round(refund_reinv)
        return out, rounded

    branches = {}
    for key, (rate, comp) in {"spec_pot_taxfree": (0.0, None), "cf_pot_taxable_comp26": (T.T_DIV, 0.264),
                              "cf_pot_taxable_comp38": (T.T_DIV, 0.385), "cf_pot_taxable_flat": (T.T_DIV, None)}.items():
        raw, rounded = ladder(rate, comp)
        if rounded != golden[key]:
            raise SystemExit(f"옮겨 적은 사다리가 tax_lib 와 다르다: {key}")
        branches[key] = raw

    yearly = pd.concat([g_pot, g_c]).sort_index()
    yg = yearly.groupby(yearly.index.year).sum() if len(yearly) else pd.Series(dtype=float)
    doc = {
        "meta": {"purpose": "정본 세후 규약 tax_lib.aftertax_full 의 S7 반올림 전 값 — E7a1 대조",
                 "generator": "packages/core_engine/tool/export_replay_aftertax.py",
                 "versions": {"python": sys.version.split()[0], "pandas": pd.__version__, "numpy": np.__version__}},
        "branches": branches,
        "intermediate": {
            "years": yrs, "e0": e0,
            "pot_gain_dates": [d.strftime("%Y-%m-%d") for d in g_pot.index], "pot_gains": [float(v) for v in g_pot],
            "c_gain_dates": [d.strftime("%Y-%m-%d") for d in g_c.index], "c_gains": [float(v) for v in g_c],
            "contrib_by_year": {str(int(y)): float(v) for y, v in by_year.items()},
            "credited": credited, "non_credited": non_credited,
            "pension_end": pen_end, "pension_end_b": pen_end_b, "taxable": taxable, "refund_nominal": refund_nominal,
            "yearly_gain_sum": {str(int(y)): float(v) for y, v in yg.items()},
        },
        "golden_inputs": golden["inputs"],
    }
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    print(f"갈래 4개 반올림 = tax_lib 출력 · POT 이익 {len(g_pot)}일 · C 이익 {len(g_c)}일 · 납입 {len(by_year)}년 → {OUT.name}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_aftertax.py <설계 저장소>/09_백테스트/백테스트6")
    main(sys.argv[1])
