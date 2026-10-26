#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""lib/src/calendar/frozen_sessions.dart(동결 거래소 세션 표의 lib 자산)를 다시 만든다.

원천 = test/golden/vectors/sessions_xkrx.json · sessions_xnys.json(그 원천은 tool/gen_exchange_sessions.py —
exchange_calendars + 근거 있는 덮어쓰기). 이 도구는 표준 라이브러리만 쓴다(exchange_calendars 불필요) —
JSON 을 Dart 상수로 옮길 뿐 날짜를 하나도 바꾸지 않는다.

설계 13 §8 R23 D14(실전 KR 캘린더 = 동결 표를 test → lib 로 승격 · 연 1회 재생성) · R24 B2(E8b1).

    python -I packages/core_engine/tool/make_frozen_calendars.py

🔴 순서: 휴장 공지가 나오면 gen_exchange_sessions.py 의 CLOSED_OVERRIDES 에 근거와 함께 적고 → 그 도구를 돌리고 →
   이 도구를 돌린다. 시험(test/frozen_calendar_test.dart)이 lib 상수와 JSON 을 대조한다(갈라지면 실패).
"""
import hashlib
import io
import json
import os
import sys

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")

PKG = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VEC = os.path.join(PKG, "test", "golden", "vectors")
OUT = os.path.join(PKG, "lib", "src", "calendar", "frozen_sessions.dart")
MARKETS = [("kr", "xkrx"), ("us", "xnys")]
PER_LINE = 8


def dart_str(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def main():
    out = [
        "// 🔴 생성 파일 — 손으로 고치지 않는다. `python -I packages/core_engine/tool/make_frozen_calendars.py` 로 다시 만든다.",
        "//",
    ]
    body = []
    for market, mic in MARKETS:
        path = os.path.join(VEC, "sessions_%s.json" % mic)
        raw = open(path, "rb").read()
        doc = json.loads(raw.decode("utf-8"))
        meta, sessions = doc["meta"], doc["sessions"]
        assert meta["count"] == len(sessions), mic
        assert sessions == sorted(set(sessions)), mic
        out.append("// 원천 `test/golden/vectors/sessions_%s.json` sha256 `%s` · %s · 세션 %d" % (
            mic, hashlib.sha256(raw).hexdigest(), meta["source"], len(sessions)))
        name = mic.capitalize()
        packed = [d.replace("-", "") for d in sessions]
        body.append("")
        body.append("/// %s 세션(`yyyyMMdd` 를 이어 붙인 것 · %d개 · %s~%s)." % (
            mic.upper(), len(sessions), sessions[0], sessions[-1]))
        body.append("const String k%sSessionsPacked =" % name)
        for i in range(0, len(packed), PER_LINE):
            chunk = "".join(packed[i:i + PER_LINE])
            end = ";" if i + PER_LINE >= len(packed) else ""
            body.append("    '%s'%s" % (chunk, end))
        body.append("")
        body.append("/// %s 표가 덮는 범위(양 끝 포함 — 그 밖은 «모름»)." % mic.upper())
        body.append("const List<String> k%sCoverage = <String>[%s, %s];" % (
            name, dart_str(meta["requested_range"][0]), dart_str(meta["requested_range"][1])))
        body.append("")
        body.append("/// %s 표의 출처(라이브러리 판)." % mic.upper())
        body.append("const String k%sSource = %s;" % (name, dart_str(meta["source"])))
        body.append("")
        body.append("/// %s 덮어쓰기 휴장일(날짜 → 근거 · 설계 13 §8 R15)." % mic.upper())
        overrides = meta.get("closed_overrides") or {}
        if overrides:
            body.append("const Map<String, String> k%sClosedOverrides = <String, String>{" % name)
            for d in sorted(overrides):
                body.append("  %s: %s," % (dart_str(d), dart_str(overrides[d])))
            body.append("};")
        else:
            body.append("const Map<String, String> k%sClosedOverrides = <String, String>{};" % name)
    out.extend(body)
    text = "\n".join(out) + "\n"
    with io.open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)
    print("frozen_sessions.dart: %d bytes" % len(text.encode("utf-8")))


if __name__ == "__main__":
    main()
