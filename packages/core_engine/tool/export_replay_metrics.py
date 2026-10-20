# -*- coding: utf-8 -*-
"""E6e 재현 정답지 — 참조 엔진(백테스트6) 실행에서 골든 지표를 반올림 전 값(full precision)으로 내보낸다.

`exp/N2_golden_p0s.py` 와 같은 계산(그 파일은 import 하지 않는다 — 모듈 머리에서 stdout 을 감싸고 시장을 만든다):
- 성과 = `exp/harness.py` 의 `stats` 그대로(S6·S7 = `flows=ext_flow` 로 TWR 다시 쌓기 · 스트레스 = 유출입 없이)
- 세후 S7 = N2 의 `pot_tax` · `aftertax` 를 옮겨 적음(POT 매도 이익 × 15.4% · 평균 단가)
- 금 비중 = N2 의 `GoldTrackBacktest`(B·POT 의 411060 평가액) · 실현 배분 = 일별 열 비율의 평균
설정 = `tool/export_replay_variants.py` 와 같다(S7 · S6 · delay1 · nogate · nocut).
🔴 `market.build()` 는 캐시 번들을 읽기만 한다(없으면 멈춘다). 설계 저장소에 아무것도 쓰지 않는다.

실행(저장소 밖 가상환경 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_metrics.py <설계 저장소>/09_백테스트/백테스트6
산출: packages/core_engine/test/replay/fixtures/metrics_parity.json
"""
from __future__ import annotations

import hashlib
import json
import math
import os
import pathlib
import struct
import sys

sys.dont_write_bytecode = True
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "fixtures" / "metrics_parity.json"
NAN = struct.pack("<Q", 0x7FF8000000000000)
STATS_KEYS = ("cagr", "mdd", "vol", "years", "end_mult")


def fhash(values) -> str:
    h = hashlib.sha256()
    for v in values:
        v = float(v)
        h.update(NAN if math.isnan(v) else struct.pack("<d", v))
    return h.hexdigest()


def main(bt6: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, bt6)
    sys.path.insert(0, os.path.join(bt6, "exp"))
    import numpy as np
    import pandas as pd
    from engine import market as M
    from engine.backtest import Backtest
    from engine.config import Config, P0_PIECES, P0S_PIECES
    from harness import stats

    if not os.path.exists(M.CACHE):
        raise SystemExit(f"캐시 번들이 없다 — market.build() 가 새로 쓰게 되므로 멈춘다: {M.CACHE}")
    mkt = M.apply_p0_market(M.build())

    class GoldTrackBacktest(Backtest):  # N2_golden_p0s.py 32~48행 그대로
        def _snapshot(self, i, d, reg):
            eq = super()._snapshot(i, d, reg)
            row = self.daily[-1]
            g_b = g_pot = 0.0
            t = "411060"
            if t in getattr(self, "b_units", {}):
                px = self._p(i, t)
                if np.isfinite(px):
                    g_b = self.b_units[t] * px
            if t in getattr(self, "pot_b_units", {}):
                px = self._p(i, t)
                if np.isfinite(px):
                    g_pot = self.pot_b_units[t] * px
            row["gold_c"] = row["c_iau"]; row["gold_b"] = g_b; row["gold_pot"] = g_pot
            row["gold_total"] = row["c_iau"] + g_b + g_pot
            return eq

    def pot_tax(ledger):  # N2 69~81행 그대로
        pot = ledger[(ledger["sleeve"] == "POT") & (ledger["symbol"] != "CASH")].sort_values("date")
        basis, taxes = {}, []
        for _, r in pot.iterrows():
            sym, q, g = r["symbol"], float(r["qty"]), float(r["gross_krw"])
            b = basis.setdefault(sym, [0.0, 0.0])
            if r["side"] == "BUY":
                b[0] += q; b[1] += g
            elif r["side"] == "SELL" and b[0] > 0:
                unit = b[1] / b[0]; gain = g - unit * q; b[0] -= q; b[1] -= unit * q
                if gain > 0:
                    taxes.append((r["date"], gain * 0.154))
        return pd.DataFrame(taxes, columns=["date", "tax"])

    def aftertax(eq, res):  # N2 84~94행 그대로(부트스트랩용 두 번째 반환값은 뺌)
        tx = pot_tax(res["ledger"])
        e = eq["equity"].dropna()
        f = eq.get("ext_flow"); f = f.reindex(e.index).fillna(0.0) if f is not None else 0.0
        r = ((e - f) / e.shift(1) - 1.0).fillna(0.0)
        if len(tx):
            for d, tv in tx.groupby("date")["tax"].sum().items():
                if d in r.index:
                    r.loc[d] -= tv / e.loc[:d].iloc[-2]
        e2 = (1 + r).cumprod() * 100.0
        return stats(e2), tx, e2

    sat_off = {k for k in P0S_PIECES if k not in P0_PIECES and (
        k.startswith("alloc.satellite") or k == "satellite.max_positions" or k == "alloc.sleeve_c")}
    absorb = [k for k in P0S_PIECES if k not in P0_PIECES and k not in sat_off]

    def cfg_for(name):  # export_replay_variants.py 와 같다
        cfg = Config(start="2000-01-03", end="2026-08-14", label=name, preset="P0S")
        cfg.ramp_months = 6
        if name == "S6_P0S_residual":
            base = Config(preset="P0")
            for k in absorb:
                o, a = k.split(".") if "." in k else (None, k)
                val = getattr(getattr(base, o), a) if o else getattr(base, k)
                (setattr(getattr(cfg, o), a, val) if o else setattr(cfg, k, val))
        elif name == "delay1":
            cfg.b_sma_regime_assist = dict(P0_PIECES["b_sma_regime_assist"], delay=1)
        elif name == "nogate":
            cfg.f1_entry_gate_score = 0.0
        elif name == "nocut":
            cfg.b_sma_regime_assist = None
            cfg.b_sma_floor = 0.0
        return cfg

    def pick(s):
        return {k: float(s[k]) for k in STATS_KEYS}

    out = {"runs": {}}
    eq7 = res7 = None
    for name in ("S7_P0S", "S6_P0S_residual", "delay1", "nogate", "nocut"):
        cls = GoldTrackBacktest if name == "S7_P0S" else Backtest
        res = cls(cfg_for(name), mkt).run()
        eq = res["equity"]
        stress = name in ("delay1", "nogate", "nocut")
        # N2: 스택(S6·S7)은 flows=ext_flow · 스트레스는 stats(equity) 만
        s = stats(eq["equity"]) if stress else stats(eq["equity"], flows=eq.get("ext_flow"))
        out["runs"][name] = dict(pick(s), flows=not stress, ext_flow_nonzero=int((eq["ext_flow"] != 0).sum()))
        print(f"{name:16} CAGR {s['cagr']!r} · MDD {s['mdd']!r} · vol {s['vol']!r}")
        if name == "S7_P0S":
            eq7, res7 = eq, res

    st_, tx, e2 = aftertax(eq7, res7)
    g = tx.groupby("date")["tax"]
    out["aftertax_S7"] = dict(
        pick(st_),
        n_tax=int(len(tx)),
        tax_dates=[d.strftime("%Y-%m-%d") for d in tx["date"]],
        tax=[float(v) for v in tx["tax"]],
        # 🔵 `sort_values("date")` 는 안정 정렬이 아니라 같은 날 두 건의 순서가 바뀔 수 있다 — 날짜별 합(세후가 쓰는 값)을 함께 낸다.
        tax_by_date_dates=[d.strftime("%Y-%m-%d") for d in g.sum().index],
        tax_by_date=[float(v) for v in g.sum()],
        max_same_day=int(g.size().max()) if len(tx) else 0,
        e2_sha256=fhash(e2.to_numpy(dtype=float)),
    )
    print(f"세후 S7          CAGR {st_['cagr']!r} · 세금 {len(tx)}건 · 같은 날 최대 {out['aftertax_S7']['max_same_day']}")

    e = eq7.dropna(subset=["equity"])
    share = (e["gold_total"] / e["equity"]).replace([np.inf, -np.inf], np.nan).dropna()
    sc = (e["gold_c"] / e["equity"]).reindex(share.index)
    sb = ((e["gold_b"] + e["gold_pot"]) / e["equity"]).reindex(share.index)
    out["gold_share_S7"] = dict(
        n=int(len(share)),
        mean=float(share.mean()), max=float(share.max()), c_mean=float(sc.mean()), b_pot_mean=float(sb.mean()),
        gt20=float((share > 0.20).mean()),
        gold_b_sha256=fhash(e["gold_b"].to_numpy(dtype=float)),
        gold_pot_sha256=fhash(e["gold_pot"].to_numpy(dtype=float)),
    )
    out["realized_alloc_S7"] = dict(
        A=float((e["A"] / e["equity"]).mean()), B=float((e["B"] / e["equity"]).mean()),
        C_incl_pot=float((e["C"] / e["equity"]).mean()),
        krw_cash=float(((e["c_krw"] + e["c_park_c"]) / e["equity"]).mean()),
        c_bond=float((e["c_iei"] / e["equity"]).mean()), c_gold=float((e["c_iau"] / e["equity"]).mean()),
        A_acct_incl_pot=float((eq7["A_acct"] / eq7["equity"]).mean()),
        C_acct_excl_pot=float((eq7["C_acct"] / eq7["equity"]).mean()),
        pot=float((eq7["pot"] / eq7["equity"]).mean()),
        A_acct_is_A_plus_pot=bool((eq7["A_acct"] == eq7["A"] + eq7["pot"]).all()),
        C_acct_is_C_minus_pot=bool((eq7["C_acct"] == eq7["C"] - eq7["pot"]).all()),
    )
    print(f"금 비중 평균 {out['gold_share_S7']['mean']!r} · 실현 B {out['realized_alloc_S7']['B']!r}")

    doc = {"meta": {"purpose": "참조 엔진 백테스트6 골든 지표(반올림 전) — E6e GV-P0S 대조",
                    "generator": "packages/core_engine/tool/export_replay_metrics.py",
                    "versions": {"python": sys.version.split()[0], "pandas": pd.__version__, "numpy": np.__version__}},
           **out}
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    print("→", OUT.name)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_metrics.py <설계 저장소>/09_백테스트/백테스트6")
    main(sys.argv[1])
