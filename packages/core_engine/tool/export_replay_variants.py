# -*- coding: utf-8 -*-
"""E6d 재현 정답지 — 참조 엔진(백테스트6)의 S6 · S7 · 스트레스 3종 실행을 해시로 내보낸다.

골든 생성기 `exp/N2_golden_p0s.py` 와 같은 설정:
- S7 = `Config(preset="P0S")` · `ramp_months = 6`
- S6 = S7 에서 흡수처 조각(ABSORB — P0S 에만 있고 새틀 제거 조각이 아닌 것 = `pension_funding`)을 P0 기본값으로 되돌림
- delay1 = `b_sma_regime_assist` 에 `delay=1` · nogate = `f1_entry_gate_score = 0` · nocut = assist 없음 + `b_sma_floor = 0`
🔴 `market.build()` 는 캐시 번들을 읽기만 한다(없으면 멈춘다). 설계 저장소에 아무것도 쓰지 않는다.

실행(저장소 밖 가상환경 · 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/export_replay_variants.py <설계 저장소>/09_백테스트/백테스트6
산출: packages/core_engine/test/replay/fixtures/variants_parity.json

해시: 원장 문자 칸은 «date|sleeve|symbol|side|event|dir_state|breaker\\n» 줄 해시 · 수 칸(qty·price·gross·cost)과
일별 자산은 float64(리틀 엔디언) 해시(NaN = 0x7ff8000000000000).
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
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "replay" / "fixtures" / "variants_parity.json"
NAN = struct.pack("<Q", 0x7FF8000000000000)


def fhash(values) -> str:
    h = hashlib.sha256()
    for v in values:
        v = float(v)
        h.update(NAN if math.isnan(v) else struct.pack("<d", v))
    return h.hexdigest()


def main(bt6: str) -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, bt6)
    from engine import market as M
    from engine.backtest import Backtest
    from engine.config import Config, P0_PIECES, P0S_PIECES

    if not os.path.exists(M.CACHE):
        raise SystemExit(f"캐시 번들이 없다 — market.build() 가 새로 쓰게 되므로 멈춘다: {M.CACHE}")
    mkt = M.apply_p0_market(M.build())
    sat_off = {k for k in P0S_PIECES if k not in P0_PIECES and (
        k.startswith("alloc.satellite") or k == "satellite.max_positions" or k == "alloc.sleeve_c")}
    absorb = [k for k in P0S_PIECES if k not in P0_PIECES and k not in sat_off]

    def cfg_for(name):
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

    out = {}
    for name in ("S7_P0S", "S6_P0S_residual", "delay1", "nogate", "nocut"):
        res = Backtest(cfg_for(name), mkt).run()
        led, eq = res["ledger"], res["equity"]
        lines = "".join(f"{r.date.strftime('%Y-%m-%d')}|{r.sleeve}|{r.symbol}|{r.side}|{r.event}|{r.dir_state}|{r.breaker}\n"
                        for r in led.itertuples())
        out[name] = {
            "n_ledger": int(len(led)),
            "cost_krw_sum": float(led["cost_krw"].sum()),
            "ledger_text_sha256": hashlib.sha256(lines.encode()).hexdigest(),
            "ledger_num_sha256": {c: fhash(led[c].to_numpy(dtype=float)) for c in ("qty", "price", "gross_krw", "cost_krw")},
            "n_daily": int(len(eq)),
            "equity_sha256": fhash(eq["equity"].to_numpy(dtype=float)),
            "equity_last": float(eq["equity"].iloc[-1]),
        }
        print(f"{name:16} 원장 {len(led)} · 비용 {out[name]['cost_krw_sum']:,.2f} · 끝 자산 {out[name]['equity_last']:,.2f}")
    doc = {"meta": {"purpose": "참조 엔진 백테스트6 S6·S7·스트레스 3종 실행 해시 — E6d 대조", "absorb": absorb,
                    "generator": "packages/core_engine/tool/export_replay_variants.py"},
           "variants": out}
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    print("→", OUT.name)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("사용: export_replay_variants.py <설계 저장소>/09_백테스트/백테스트6")
    main(sys.argv[1])
