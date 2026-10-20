# -*- coding: utf-8 -*-
"""거래소 세션 표 생성기 — exchange_calendars 의 XKRX·XNYS 세션을 JSON 으로 동결한다.

왜: Dart 에는 exchange_calendars 가 없고, KRX 휴장일은 음력 명절·임시공휴일이라 규칙으로 계산할 수
없다(05 §GV-12 «하드코딩 금지 — exchange_calendars 기준으로 검증»). 그래서 세션은 «데이터»로 받는다.
이 표는 시험·백테스트 재현용 기준 데이터이고, 실행 시점의 정본 대조(KIS 휴장일 API)는 별도다
(설계 저장소 11_앱설계/13_엔진레인_착수계획.md E4).

실행(저장소 밖 가상환경 — 설계 13 §8 R8):
    <venv>/Scripts/python.exe -I packages/core_engine/tool/gen_exchange_sessions.py
산출: packages/core_engine/test/golden/vectors/sessions_xkrx.json · sessions_xnys.json

🔴 이 표를 손으로 고치지 않는다. 버전을 올리면 다시 돌리고, 05 GV-12·12c 시험이 그대로 통과하는지 본다.
🔴 라이브러리가 빠뜨린 임시휴장은 아래 `CLOSED_OVERRIDES` 에 **근거와 함께** 적고 다시 돌린다(설계 13 §8 R15).
   근거 없는 날은 넣지 않는다 — 확인한 날만.
"""
from __future__ import annotations

import json
import pathlib
import sys
import warnings

import exchange_calendars as xc
import pandas as pd

START, END = "1999-12-01", "2027-12-31"
OUT = pathlib.Path(__file__).resolve().parents[1] / "test" / "golden" / "vectors"

# 라이브러리 판에 없는 휴장일 — {MIC: {날짜: 근거}}. 확인한 날만 넣는다.
CLOSED_OVERRIDES = {
    "XKRX": {
        "2026-06-03": "제9회 전국동시지방선거일 — 한국거래소 2026-05-20 휴장 공지(증권·파생·일반상품)",
        "2026-07-17": "제헌절(2026 공휴일 복원) — 같은 공지",
    },
}


def main() -> None:
    warnings.simplefilter("ignore")
    for mic in ("XKRX", "XNYS"):
        cal = xc.get_calendar(mic, start=START, end=END)
        library = [d.date().isoformat() for d in cal.sessions]
        closed = CLOSED_OVERRIDES.get(mic, {})
        missing = sorted(set(closed) - set(library))
        if missing:
            # 라이브러리가 이미 휴장으로 아는 날을 덮어쓰기에 남겨 두지 않는다 — 판을 올렸다는 신호다.
            raise SystemExit(f"{mic}: 덮어쓰기 날짜가 이미 휴장이다 — 목록에서 빼라: {missing}")
        sessions = [d for d in library if d not in closed]
        doc = {
            "meta": {
                "calendar": mic,
                "source": f"exchange_calendars {xc.__version__}",
                "pandas": pd.__version__,
                "python": sys.version.split()[0],
                "requested_range": [START, END],
                "first_session": sessions[0],
                "last_session": sessions[-1],
                "count": len(sessions),
                "generator": "packages/core_engine/tool/gen_exchange_sessions.py",
                "closed_overrides": closed,
            },
            "sessions": sessions,
        }
        path = OUT / f"sessions_{mic.lower()}.json"
        path.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n",
                        encoding="utf-8", newline="\n")
        print(mic, len(sessions), sessions[0], sessions[-1], "->", path.name)


if __name__ == "__main__":
    main()
