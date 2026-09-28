#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.3(R10 선행 M2 보강) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r10_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.

하는 일
  (a) 전 봉투의 "contract_version": "1.2.0" → "1.3.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 4건(performance_24m · m7_perf_daily_gap · m7_disclosure_gate · m7_report_archive_18)
  (c) 신설 11건(m7/ 아래)
  (d) M2 기대 표(점 수 · 결측 순번 · 런 · 축 · 눈금 · 구간 start/end)를 화면에 찍는다.
      --table <경로> 를 주면 그 파일에도 적는다(기본 = 파일을 쓰지 않는다).

멱등: 개정 4건은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
수치는 전부 분수(Fraction)로 계산하고 마지막에만 소수 넷째 자리로 반올림한다(부동소수 오차 없음).

전제: git 이 있고, 저장소에 기준 커밋이 있다(얕은 클론이면 먼저 `git fetch --unshallow`).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r10_fixtures.py
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r10_fixtures.py --table <경로>
"""
import argparse
import io
import json
import os
import re
import subprocess
import sys
from decimal import Decimal
from fractions import Fraction

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
# 스크립트 자리 = <루트>/packages/domain_contracts/tool → 픽스처 = ../fixtures · 루트 = ../../..
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures')).replace(os.sep, '/')
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/')
FX_REL = os.path.relpath(FX, ROOT).replace(os.sep, '/')
# 계약 1.2.0 · 픽스처 104 의 기준 커밋(origin/main 에 있다).
BASE = 'c4c88191a9bd4fb5572074da37b2c9ccbe8e5d26'

OLD_VER = '"contract_version": "1.2.0"'
NEW_VER = '"contract_version": "1.3.0"'
MINUS = '\u2212'  # 빼기표(U+2212)


# ────────────────────────────────────────────────────────────────────────
# 파일 입출력
# ────────────────────────────────────────────────────────────────────────
def base_text(rel):
    out = subprocess.check_output(
        ['git', '-C', ROOT, 'show', '%s:%s/%s' % (BASE, FX_REL, rel)])
    s = out.decode('utf-8')
    assert '\r' not in s, rel
    return s


def read_disk(rel):
    s = io.open(FX + '/' + rel, encoding='utf-8', newline='').read()
    assert '\r' not in s, rel
    return s


def write_disk(rel, s):
    assert '\r' not in s
    assert s.endswith('}\n')
    json.loads(s)  # 문법 확인
    io.open(FX + '/' + rel, 'w', encoding='utf-8', newline='').write(s)


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


# ────────────────────────────────────────────────────────────────────────
# 수 다루기
# ────────────────────────────────────────────────────────────────────────
def fr(x):
    """Decimal·문자열·정수 → Fraction(정확)."""
    if x is None:
        return None
    return Fraction(str(x))


def r4(x):
    """소수 넷째 자리 반올림(반올림 = 0.5 는 0 에서 먼 쪽)."""
    x = Fraction(x)
    sign = -1 if x < 0 else 1
    n = (abs(x) * 10000 + Fraction(1, 2)).__floor__()
    return Fraction(sign * n, 10000)


def num(x):
    """JSON 숫자 글자. 소수점 아래 한 자리 이상("0.0" · "1.0" · "0.995")."""
    x = Fraction(x)
    assert 10000 % x.denominator == 0, x
    n = x.numerator * (10000 // x.denominator)
    sign = '-' if n < 0 else ''
    n = abs(n)
    ip, fp = divmod(n, 10000)
    fs = ('%04d' % fp).rstrip('0') or '0'
    return '%s%d.%s' % (sign, ip, fs)


def js(s):
    return json.dumps(s, ensure_ascii=False)


def floor_div(a, b):
    return (Fraction(a) / Fraction(b)).__floor__()


def ceil_div(a, b):
    return (Fraction(a) / Fraction(b)).__ceil__()


def choose_axis(values):
    """0 을 포함 · 눈금 간격 = {1,2,5}×10ⁿ · 눈금 수(양 끝 포함) ≤ 5 가 되는 가장 작은 간격."""
    assert values
    lo = min(min(values), Fraction(0))
    hi = max(max(values), Fraction(0))
    steps = []
    for n in range(-6, 3):
        for m in (1, 2, 5):
            steps.append(Fraction(m) * (Fraction(10) ** n))
    steps.sort()
    for step in steps:
        bottom = floor_div(lo, step) * step
        top = ceil_div(hi, step) * step
        if top == bottom:
            continue
        count = int((top - bottom) / step) + 1
        if count <= 5:
            return bottom, top, step, count
    raise AssertionError('축을 못 골랐다')


def pct_text(v, decimals):
    """백분율 글자. 음수는 U+2212."""
    p = Fraction(v) * 100
    scale = 10 ** decimals
    assert (p * scale).denominator == 1, (v, decimals)
    n = int(p * scale)
    sign = MINUS if n < 0 else ''
    n = abs(n)
    ip, fp = divmod(n, scale)
    if decimals == 0:
        return '%s%d%%' % (sign, ip)
    return '%s%d.%0*d%%' % (sign, ip, decimals, fp)


def date_text(date, granularity, is_last):
    y, m, _ = date.split('-')
    if granularity == 'DAILY':
        return date
    if granularity == 'MONTHLY':
        return '%d년 %d월' % (int(y), int(m))
    if granularity == 'YEARLY':
        if is_last and int(m) < 12:
            return '%d년(%d월까지)' % (int(y), int(m))
        return '%d년' % int(y)
    raise AssertionError(granularity)


# ────────────────────────────────────────────────────────────────────────
# 시리즈 1개의 표시 필드 계산
# ────────────────────────────────────────────────────────────────────────
class Series(object):
    pass


def compute(name, granularity, points, segments, bench_points=None):
    """points = [{date, value(Fraction|None), gap(str|None), token(str)}] ·
    segments = [{from, to, kind, label}] · bench_points = 같은 모양 또는 None."""
    s = Series()
    s.name = name
    s.granularity = granularity
    n = len(points)
    assert n >= 1
    if n == 1:
        xs = [Fraction(1, 2)]
        half = Fraction(1, 2)
    else:
        xs = [Fraction(i, n - 1) for i in range(n)]
        half = Fraction(1, 2) / (n - 1)
    assert r4(xs[0]) == (Fraction(1, 2) if n == 1 else 0)
    assert n == 1 or r4(xs[-1]) == 1

    vals = [p['value'] for p in points if p['value'] is not None]
    if bench_points is not None:
        assert len(bench_points) == n
        for a, b in zip(points, bench_points):
            assert a['date'] == b['date']
        vals += [p['value'] for p in bench_points if p['value'] is not None]
    bottom, top, step, count = choose_axis(vals)
    s.axis = (bottom, top, step, count)

    # 눈금
    tick_decimals = 0 if step >= Fraction(1, 100) else 1
    s.ticks = []
    for k in range(count):
        v = bottom + k * step
        s.ticks.append({
            'normalized': r4((v - bottom) / (top - bottom)),
            'label': pct_text(v, tick_decimals),
            'is_baseline': v == 0,
        })
    assert len(set(t['label'] for t in s.ticks)) == count
    assert sum(1 for t in s.ticks if t['is_baseline']) == 1

    # 구간 → 덮는 점
    s.segments = []
    owner = [None] * n
    for si, seg in enumerate(segments):
        idx = [i for i, p in enumerate(points)
               if seg['from'] <= p['date'] <= seg['to']]
        if not idx:
            raise SystemExit('멈춤: %s 의 구간 %s~%s 이 덮는 점이 없다'
                             % (name, seg['from'], seg['to']))
        assert idx == list(range(idx[0], idx[-1] + 1)), '구간이 덮는 점이 이어져 있지 않다'
        for i in idx:
            assert owner[i] is None, '%s: 점 %d 을 두 구간이 덮는다' % (name, i)
            owner[i] = si
        start = max(Fraction(0), xs[idx[0]] - half)
        end = min(Fraction(1), xs[idx[-1]] + half)
        d = dict(seg)
        d['start_normalized'] = r4(start)
        d['end_normalized'] = r4(end)
        d['first'] = idx[0]
        d['last'] = idx[-1]
        s.segments.append(d)
    assert all(o is not None for o in owner), '%s: 어느 구간에도 없는 점이 있다' % name
    for a, b in zip(s.segments, s.segments[1:]):
        assert a['start_normalized'] <= b['start_normalized']
        assert a['end_normalized'] <= b['start_normalized'], '구간이 겹친다'
    # 반올림한 값으로도 «날짜로 덮는 점» == «자리로 덮는 점»
    for d in s.segments:
        by_x = [i for i in range(n)
                if d['start_normalized'] <= r4(xs[i]) <= d['end_normalized']]
        assert by_x == list(range(d['first'], d['last'] + 1)), (name, d)

    def finish(plist, is_main):
        out = []
        for i, p in enumerate(plist):
            kind = segments[owner[i]]['kind']
            q = dict(p)
            q['x_normalized'] = r4(xs[i])
            q['date_text'] = date_text(p['date'], granularity, i == n - 1)
            if p['value'] is None:
                assert is_main, '벤치마크 결측은 이 스크립트가 다루지 않는다'
                q['y_normalized'] = None
                if kind == 'SIM_EXCLUDED':
                    q['value_text'] = '합산 제외'
                    assert p['gap'] == 'SIM_EXCLUDED'
                else:
                    assert kind == 'UNAVAILABLE', (name, i, kind)
                    q['value_text'] = '산출 불가'
                    assert p['gap'] in ('RESUME_GAP', 'EQUITY_SNAPSHOT_MISSING')
            else:
                if is_main:
                    assert kind in ('MEASURED', 'MANUAL_EXECUTED'), (name, i, kind)
                    assert p['gap'] is None
                q['y_normalized'] = r4((p['value'] - bottom) / (top - bottom))
                assert 0 <= q['y_normalized'] <= 1
                q['value_text'] = pct_text(p['value'], 2)
            out.append(q)
        for a, b in zip(out, out[1:]):
            assert a['x_normalized'] < b['x_normalized']
        return out

    s.points = finish(points, True)
    s.bench = finish(bench_points, False) if bench_points is not None else None
    assert any(p['y_normalized'] is not None for p in s.points)
    assert n <= 60
    return s


def runs(plist):
    out = []
    start = None
    for i, p in enumerate(plist):
        if p['y_normalized'] is not None:
            if start is None:
                start = i
        else:
            if start is not None:
                out.append((start, i - 1))
                start = None
    if start is not None:
        out.append((start, len(plist) - 1))
    return out


# ────────────────────────────────────────────────────────────────────────
# 글자로 내보내기(기존 픽스처의 손 모양을 본뜬다)
# ────────────────────────────────────────────────────────────────────────
def point_line(p, indent):
    parts = [
        '"date": %s' % js(p['date']),
        '"x_normalized": %s' % num(p['x_normalized']),
        '"date_text": %s' % js(p['date_text']),
        '"value_text": %s' % js(p['value_text']),
        '"y_normalized": %s' % ('null' if p['y_normalized'] is None
                                else num(p['y_normalized'])),
        '"value": %s' % p['token'],
    ]
    if p['gap'] is not None:
        parts.append('"gap_reason_code": %s' % js(p['gap']))
    return indent + '{ ' + ', '.join(parts) + ' }'


def segment_line(d, indent):
    return (indent + '{ "from": %s, "to": %s, "kind": %s, "label": %s, '
            '"start_normalized": %s, "end_normalized": %s }'
            % (js(d['from']), js(d['to']), js(d['kind']), js(d['label']),
               num(d['start_normalized']), num(d['end_normalized'])))


def tick_line(t, indent):
    return (indent + '{ "normalized": %s, "label": %s, "is_baseline": %s }'
            % (num(t['normalized']), js(t['label']),
               'true' if t['is_baseline'] else 'false'))


def block(key, lines, indent, comma=True):
    """"key": [ … ] 묶음. 비면 한 줄."""
    tail = ',' if comma else ''
    if not lines:
        return ['%s"%s": []%s' % (indent, key, tail)]
    out = ['%s"%s": [' % (indent, key)]
    for i, ln in enumerate(lines):
        out.append(ln + (',' if i < len(lines) - 1 else ''))
    out.append('%s]%s' % (indent, tail))
    return out


def header_lines(series_label, period_label, ticks, unavailable_label=None):
    ind = '      '
    out = [
        '%s"series_label": %s,' % (ind, js(series_label)),
        '%s"period_label": %s,' % (ind, js(period_label)),
    ]
    if unavailable_label is not None:
        out.append('%s"unavailable_label": %s,' % (ind, js(unavailable_label)))
    out += block('y_ticks', [tick_line(t, ind + '  ') for t in ticks], ind)
    return out


NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.3.0",
    "generated_at": "2026-09-28T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20260928,
    "notice": "합성 데이터. 실계좌·실키 없음."
  },'''


def as_of_inline(label):
    return ('{ "observed_at": "2026-08-31T09:00:00Z", "trade_date": "2026-08-31", '
            '"source": "LOCAL_SQLITE", "stale_after_seconds": 93600, "label": %s }'
            % js(label))


def envelope(as_of_label, row_texts):
    out = ['{', NEW_META,
           '  "as_of": %s,' % as_of_inline(as_of_label),
           '  "empty_kind": "NO_DATA",',
           '  "empty_label": null,',
           '  "has_more": false,',
           '  "rows": [']
    for i, r in enumerate(row_texts):
        out.append(r + (',' if i < len(row_texts) - 1 else ''))
    out += ['  ]', '}']
    return '\n'.join(out) + '\n'


PERF_AS_OF = '성과 기준 2026-08-31 종가'
DISCLOSURE_COMMON = {
    'interstitial_text': '수익률은 결과이지 목표가 아닙니다. 열람 기록이 남습니다.',
    'view_count_this_month': 2,
    'honest_expectation_line': '정직 기대는 백테스트 점추정보다 낮습니다.',
    'drawdown_caveat_line': '최대낙폭은 관측 하한이며 앞으로의 상한이 아닙니다.',
}
BENCH_LABEL = 'KOSPI 50% + S&P500(KRW) 50%'
BENCH_NOTE = 'KOSPI 50% + S&P500(원화 환산) 50% 고정 비중입니다.'


def perf_row(metric, granularity, cumulative, series_label, period_label,
             sample_size_line, s=None, unavailable_label=None,
             bench_label=None, bench_note=None):
    ind = '      '
    out = ['    {',
           '%s"metric": %s,' % (ind, js(metric)),
           '%s"granularity": %s,' % (ind, js(granularity)),
           '%s"cumulative": %s,' % (ind, 'true' if cumulative else 'false')]
    if s is None:
        assert unavailable_label is not None
        out += header_lines(series_label, period_label, [], unavailable_label)
        out += block('segments', [], ind)
        out += block('points', [], ind)
        out.append('%s"benchmark": null,' % ind)
    else:
        assert unavailable_label is None
        out += header_lines(series_label, period_label, s.ticks)
        out += block('segments',
                     [segment_line(d, ind + '  ') for d in s.segments], ind)
        out += block('points',
                     [point_line(p, ind + '  ') for p in s.points], ind)
        if s.bench is None:
            out.append('%s"benchmark": null,' % ind)
        else:
            out.append('%s"benchmark": {' % ind)
            out.append('%s  "label": %s,' % (ind, js(bench_label)))
            out += block('points',
                         [point_line(p, ind + '    ') for p in s.bench],
                         ind + '  ')
            out.append('%s  "composition_note": %s' % (ind, js(bench_note)))
            out.append('%s},' % ind)
    out += ['%s"disclosure": {' % ind,
            '%s  "sample_size_line": %s,' % (ind, js(sample_size_line)),
            '%s  "interstitial_text": %s,'
            % (ind, js(DISCLOSURE_COMMON['interstitial_text'])),
            '%s  "view_count_this_month": %d,'
            % (ind, DISCLOSURE_COMMON['view_count_this_month']),
            '%s  "honest_expectation_line": %s,'
            % (ind, js(DISCLOSURE_COMMON['honest_expectation_line'])),
            '%s  "drawdown_caveat_line": %s'
            % (ind, js(DISCLOSURE_COMMON['drawdown_caveat_line'])),
            '%s},' % ind,
            '%s"after_tax": null,' % ind,
            '%s"as_of": %s' % (ind, as_of_inline(PERF_AS_OF)),
            '    }']
    return '\n'.join(out)


# ────────────────────────────────────────────────────────────────────────
# 기준 픽스처 읽기
# ────────────────────────────────────────────────────────────────────────
def load_rows(rel):
    d = json.loads(base_text(rel), parse_float=Decimal)
    return d['rows']


def to_points(raw):
    out = []
    for p in raw:
        v = p.get('value')
        out.append({
            'date': p['date'],
            'value': fr(v),
            'gap': p.get('gap_reason_code'),
            'token': 'null' if v is None else str(v),
        })
    return out


def to_segments(raw):
    return [{'from': g['from'], 'to': g['to'], 'kind': g['kind'],
             'label': g['label']} for g in raw]


def mk_points(triples):
    """[(date, Fraction|None, gap)] → 점 목록(값 글자는 num 으로)."""
    out = []
    for date, v, gap in triples:
        out.append({'date': date, 'value': v, 'gap': gap,
                    'token': 'null' if v is None else num(v)})
    return out


# ────────────────────────────────────────────────────────────────────────
# 개정 — 성과 2건(줄 단위로 고친다 · 다른 줄은 한 글자도 안 바뀐다)
# ────────────────────────────────────────────────────────────────────────
POINT_RE = re.compile(
    r'^(\s*)\{ "date": "(\d{4}-\d{2}-\d{2})", "value": (null|-?[0-9.]+)'
    r'(?:, "gap_reason_code": "([A-Z_]+)")? \}(,?)$')
SEG_RE = re.compile(
    r'^(\s*)\{ "from": "(\d{4}-\d{2}-\d{2})", "to": "(\d{4}-\d{2}-\d{2})", '
    r'"kind": "([A-Z_]+)", "label": "([^"]*)" \}(,?)$')


def amend_perf(rel, labels):
    """labels = 행마다 (series_label, period_label)."""
    text = bump(base_text(rel), rel)
    rows = load_rows(rel)
    assert len(rows) == len(labels)
    computed = []
    for ri, row in enumerate(rows):
        bench = row.get('benchmark')
        s = compute('%s#%d' % (rel, ri), row['granularity'],
                    to_points(row['points']), to_segments(row['segments']),
                    to_points(bench['points']) if bench else None)
        computed.append(s)

    out = []
    ri = -1
    in_bench = False
    pi = 0
    si = 0
    n_points = 0
    n_segs = 0
    for line in text.split('\n'):
        if re.match(r'^\s*"metric": ', line):
            ri += 1
            in_bench = False
        if '"benchmark": {' in line:
            in_bench = True
        if '"composition_note"' in line:
            in_bench = False
        if re.match(r'^\s*"points": \[', line):
            pi = 0
        if re.match(r'^\s*"segments": \[', line):
            si = 0
        m = POINT_RE.match(line)
        if m:
            s = computed[ri]
            p = (s.bench if in_bench else s.points)[pi]
            assert p['date'] == m.group(2) and p['token'] == m.group(3), line
            assert p['gap'] == m.group(4)
            out.append(point_line(p, m.group(1)) + m.group(5))
            pi += 1
            n_points += 1
            continue
        m = SEG_RE.match(line)
        if m:
            d = computed[ri].segments[si]
            assert d['from'] == m.group(2) and d['label'] == m.group(5)
            out.append(segment_line(d, m.group(1)) + m.group(6))
            si += 1
            n_segs += 1
            continue
        out.append(line)
        if re.match(r'^      "cumulative": (true|false),$', line):
            out += header_lines(labels[ri][0], labels[ri][1], computed[ri].ticks)
    new = '\n'.join(out)
    want_points = sum(len(s.points) + (len(s.bench) if s.bench else 0)
                      for s in computed)
    assert n_points == want_points, (rel, n_points, want_points)
    assert n_segs == sum(len(s.segments) for s in computed)

    # 더하기만 했는지 확인 — 새 키를 빼면 기준과 같아야 한다
    def strip(o):
        if isinstance(o, dict):
            return {k: strip(v) for k, v in o.items()
                    if k not in ('x_normalized', 'y_normalized', 'date_text',
                                 'value_text', 'start_normalized',
                                 'end_normalized', 'series_label',
                                 'period_label', 'y_ticks')}
        if isinstance(o, list):
            return [strip(v) for v in o]
        return o
    old_obj = json.loads(base_text(rel), parse_float=Decimal)
    old_obj['meta']['contract_version'] = '1.3.0'
    assert strip(json.loads(new, parse_float=Decimal)) == old_obj, rel
    write_disk(rel, new)
    return computed


# ────────────────────────────────────────────────────────────────────────
# 개정 — 게이트 · 아카이브
# ────────────────────────────────────────────────────────────────────────
def amend_gate():
    rel = 'm7/m7_disclosure_gate.json'
    text = bump(base_text(rel), rel)
    old = '      "gate_open": false,'
    assert text.count(old) == 1
    write_disk(rel, text.replace(old, '      "gate_open": true,', 1))


REASON_NOT_GENERATED = '그달의 원장이 모자라 리포트를 만들지 않았습니다.'
REASON_SIM = '모의 기간의 리포트는 앱에서 열 수 없습니다.'


def archive_rows():
    months = []
    y, m = 2026, 8
    while (y, m) >= (2025, 3):
        months.append((y, m))
        m -= 1
        if m == 0:
            y, m = y - 1, 12
    assert len(months) == 18
    rows = []
    for (y, m) in months:
        ym = '%04d-%02d' % (y, m)
        row = [('yyyy_mm', ym), ('label', '%d년 %d월' % (y, m))]
        sim = (2025, 3) <= (y, m) <= (2025, 5)
        not_generated = ym in ('2026-07', '2026-06')
        row.append(('generated', not not_generated))
        row.append(('mode_label', '모의투자' if sim else '실전'))
        if not_generated:
            row.append(('reason_label', REASON_NOT_GENERATED))
        elif sim:
            row.append(('reason_label', REASON_SIM))
        else:
            row.append(('route', 'aaq://report/%s' % ym))
        section = {'2026-08': '2026년', '2025-12': '2025년',
                   '2025-05': '2025년 · 모의투자'}.get(ym)
        if section is not None:
            row.append(('section_label', section))
        rows.append(row)
    return rows


def amend_archive():
    rel = 'm7/m7_report_archive_18.json'
    text = bump(base_text(rel), rel)
    lines = text.split('\n')
    first = next(i for i, ln in enumerate(lines) if '{ "yyyy_mm"' in ln)
    last = max(i for i, ln in enumerate(lines) if '{ "yyyy_mm"' in ln)
    assert last - first + 1 == 18
    rows = archive_rows()
    new_lines = []
    for i, row in enumerate(rows):
        parts = []
        for k, v in row:
            parts.append('"%s": %s' % (k, ('true' if v else 'false')
                                       if isinstance(v, bool) else js(v)))
        new_lines.append('        { ' + ', '.join(parts) + ' }'
                         + (',' if i < len(rows) - 1 else ''))
    new = '\n'.join(lines[:first] + new_lines + lines[last + 1:])
    # 확인: 내림차순 · 달 18개가 기준과 같은 집합
    got = json.loads(new)['rows'][0]['rows']
    yms = [r['yyyy_mm'] for r in got]
    assert yms == sorted(yms, reverse=True)
    base_yms = [r['yyyy_mm'] for r in json.loads(base_text(rel))['rows'][0]['rows']]
    assert sorted(yms) == sorted(base_yms)
    for r in got:
        if not r['generated']:
            assert 'route' not in r and r.get('reason_label')
        if 'route' not in r:
            assert r.get('reason_label')
    assert 'section_label' in got[0]
    write_disk(rel, new)


# ────────────────────────────────────────────────────────────────────────
# 신설 11건
# ────────────────────────────────────────────────────────────────────────
HEADLINE = '수익률은 결과이지 목표가 아닙니다.'
GATE_AS_OF = '게이트 기준 2026-08-31'
ARCHIVE_AS_OF = '아카이브 기준 2026-08-31'


def gate_row(gate_open, headline, view_count_text, friction_line, route):
    ind = '      '
    out = ['    {',
           '%s"gate_open": %s,' % (ind, 'true' if gate_open else 'false'),
           '%s"headline": %s,' % (ind, js(headline)),
           '%s"view_count_text": %s,' % (ind, js(view_count_text))]
    if friction_line is not None:
        out.append('%s"friction_line": %s,' % (ind, js(friction_line)))
    if route is not None:
        out.append('%s"route": %s,' % (ind, js(route)))
    out.append('%s"as_of": %s' % (ind, as_of_inline(GATE_AS_OF)))
    out.append('    }')
    assert gate_open == (route is not None)
    return '\n'.join(out)


def new_gates():
    route = 'aaq://performance/explore'
    write_disk('m7/m7_disclosure_gate_first.json', envelope(GATE_AS_OF, [
        gate_row(True, HEADLINE, '이번 달에는 아직 열어 보지 않으셨습니다',
                 None, route)]))
    write_disk('m7/m7_disclosure_gate_frequent.json', envelope(GATE_AS_OF, [
        gate_row(True, HEADLINE, '이번 달 5번 열어 보셨습니다',
                 '자주 볼수록 규칙을 버리기 쉽습니다. 이 화면을 여는 것도 기록으로 남습니다.',
                 route)]))
    write_disk('m7/m7_disclosure_gate_closed.json', envelope(GATE_AS_OF, [
        gate_row(False, '원장 점검이 끝날 때까지 수익률 화면을 열 수 없습니다.',
                 '이번 달 2번 열어 보셨습니다', None, None)]))


def new_archive_empty():
    ind = '      '
    row = '\n'.join([
        '    {',
        '%s"rows": [],' % ind,
        '%s"empty_label": %s,' % (
            ind, js('아직 발행된 리포트가 없습니다 · 첫 리포트는 월 마감 뒤에 만들어집니다')),
        '%s"as_of": %s' % (ind, as_of_inline(ARCHIVE_AS_OF)),
        '    }'])
    write_disk('m7/m7_report_archive_empty.json', envelope(ARCHIVE_AS_OF, [row]))


def new_receipts():
    states = [
        ('REQUESTED', '요청됨 — 엔진 수신 대기'),
        ('EXECUTED', '기록됨 — 열람 기록이 남았습니다'),
        ('EXPIRED', '만료됨 — 유효 시간 안에 처리되지 않았습니다'),
        ('HELD_FOR_INTEGRITY', '보류됨 — 원장 무결성 점검 중이라 보관했습니다'),
    ]
    rows = []
    ind = '      '
    for state, label in states:
        rows.append('\n'.join([
            '    {',
            '%s"command_id": "cmd_20260831_0042",' % ind,
            '%s"kind": "DISCLOSURE_VIEW",' % ind,
            '%s"state": %s,' % (ind, js(state)),
            '%s"state_label": %s,' % (ind, js(label)),
            '%s"requested_at": "2026-08-31T10:00:00Z",' % ind,
            '%s"expires_at": "2026-08-31T10:30:00Z",' % ind,
            '%s"nonce": "n_5d2a8c1e9b40",' % ind,
            '%s"issued_by_device_id": "dev_operator_01"' % ind,
            '    }']))
    write_disk('m7/m7_disclosure_view_receipts_4.json',
               envelope(GATE_AS_OF, rows))


def new_perf(base24, base_daily):
    """base24 = performance_24m 의 기준 행들 · base_daily = m7_perf_daily_gap 의 기준 행."""
    made = []
    row0 = base24[0]
    cum = to_points(row0['points'])
    bench_cum = to_points(row0['benchmark']['points'])
    by_date = {p['date']: p for p in cum}
    sample24 = row0['disclosure']['sample_size_line']

    # N6 — 모의 3개월 + 실전 15개월(다시 누적)
    start = next(i for i, p in enumerate(cum) if p['date'] == '2025-03-31')
    base_i = next(i for i, p in enumerate(cum) if p['date'] == '2025-06-30')
    assert base_i - start == 3 and len(cum) - start == 18
    base_v = cum[base_i]['value']
    triples = []
    for i in range(start, len(cum)):
        if i < base_i:
            triples.append((cum[i]['date'], None, 'SIM_EXCLUDED'))
        else:
            v = r4((1 + cum[i]['value']) / (1 + base_v) - 1)
            triples.append((cum[i]['date'], v, None))
    assert triples[3][1] == 0 and triples[-1][1] == Fraction(686, 10000)
    s6 = compute('m7_perf_monthly_sim_split', 'MONTHLY', mk_points(triples), [
        {'from': '2025-03-03', 'to': '2025-05-30', 'kind': 'SIM_EXCLUDED',
         'label': '모의 — 합산 제외'},
        {'from': '2025-06-02', 'to': '2026-08-31', 'kind': 'MEASURED',
         'label': '측정 구간'},
    ])
    write_disk('m7/m7_perf_monthly_sim_split.json', envelope(PERF_AS_OF, [perf_row(
        'TWR', 'MONTHLY', True, '내 계좌 · 시간가중 · 누적',
        '%s ~ %s' % (s6.points[0]['date_text'], s6.points[-1]['date_text']),
        '관측 표본은 실전 15개월입니다. 모의 3개월은 합산하지 않습니다.', s6)]))
    made.append(s6)

    # N7 — 수동 집행 구간(결측 없음)
    daily = to_points(base_daily[0]['points'])
    fill = {13: Fraction(88, 10000), 14: Fraction(96, 10000)}
    triples = []
    for i, p in enumerate(daily):
        if p['value'] is None:
            assert i in fill
            triples.append((p['date'], fill[i], None))
        else:
            assert i not in fill
            triples.append((p['date'], p['value'], None))
    s7 = compute('m7_perf_daily_manual', 'DAILY', mk_points(triples), [
        {'from': '2026-08-03', 'to': '2026-08-07', 'kind': 'MEASURED',
         'label': '측정 구간'},
        {'from': '2026-08-10', 'to': '2026-08-14', 'kind': 'MANUAL_EXECUTED',
         'label': '수동 집행 구간'},
        {'from': '2026-08-17', 'to': '2026-08-31', 'kind': 'MEASURED',
         'label': '측정 구간'},
    ])
    write_disk('m7/m7_perf_daily_manual.json', envelope(PERF_AS_OF, [perf_row(
        'TWR', 'DAILY', True, '내 계좌 · 시간가중 · 누적',
        '%s ~ %s' % (s7.points[0]['date_text'], s7.points[-1]['date_text']),
        base_daily[0]['disclosure']['sample_size_line'], s7)]))
    made.append(s7)

    # N8 — 월별(비누적) · 벤치마크 있음
    def monthly(plist):
        out = []
        for i, p in enumerate(plist):
            if i == 0:
                out.append((p['date'], Fraction(0), None))
                continue
            prev = plist[i - 1]['value']
            if p['value'] is None or prev is None:
                out.append((p['date'], None, 'RESUME_GAP'))
            else:
                out.append((p['date'], r4((1 + p['value']) / (1 + prev) - 1), None))
        return out
    main_m = monthly(cum)
    bench_m = monthly(bench_cum)
    assert [d for d, v, g in main_m if v is None] == ['2025-03-31', '2025-04-30']
    assert all(v is not None for d, v, g in bench_m)
    s8 = compute('m7_perf_monthly_period', 'MONTHLY', mk_points(main_m), [
        {'from': '2024-09-30', 'to': '2025-02-28', 'kind': 'MEASURED',
         'label': '측정 구간'},
        {'from': '2025-03-01', 'to': '2025-04-30', 'kind': 'UNAVAILABLE',
         'label': '결측 — 재개 갭'},
        {'from': '2025-05-01', 'to': '2026-08-31', 'kind': 'MEASURED',
         'label': '측정 구간'},
    ], mk_points(bench_m))
    write_disk('m7/m7_perf_monthly_period.json', envelope(PERF_AS_OF, [perf_row(
        'TWR', 'MONTHLY', False, '내 계좌 · 시간가중 · 월별',
        '%s ~ %s' % (s8.points[0]['date_text'], s8.points[-1]['date_text']),
        sample24, s8, bench_label=BENCH_LABEL, bench_note=BENCH_NOTE)]))
    made.append(s8)

    # N9 — 연간 3점(누적)
    triples = [(d, by_date[d]['value'], None)
               for d in ('2024-12-31', '2025-12-31', '2026-08-31')]
    assert [v for d, v, g in triples] == [Fraction(74, 10000),
                                          Fraction(851, 10000),
                                          Fraction(1194, 10000)]
    s9 = compute('m7_perf_yearly', 'YEARLY', mk_points(triples), [
        {'from': '2024-09-30', 'to': '2026-08-31', 'kind': 'MEASURED',
         'label': '측정 구간'},
    ])
    write_disk('m7/m7_perf_yearly.json', envelope(PERF_AS_OF, [perf_row(
        'TWR', 'YEARLY', True, '내 계좌 · 시간가중 · 누적',
        '%s ~ %s' % (s9.points[0]['date_text'], s9.points[-1]['date_text']),
        '관측 표본은 3개 연도입니다(마지막 해는 8월까지).', s9)]))
    made.append(s9)

    # N10 — 불가(기록이 빔)
    write_disk('m7/m7_perf_unavailable_gap.json', envelope(PERF_AS_OF, [perf_row(
        'TWR', 'DAILY', True, '내 계좌 · 시간가중 · 누적',
        '2026-08-21 ~ 2026-08-31',
        '관측 표본이 없습니다. 이 기간은 산출할 수 없습니다.',
        unavailable_label='7거래일 동안 기록이 비어 이 기간의 수익률을 낼 수 없습니다.')]))

    # N11 — 차단 가림
    write_disk('m7/m7_perf_masked_integrity.json', envelope(PERF_AS_OF, [perf_row(
        'TWR', 'MONTHLY', True, '내 계좌 · 시간가중 · 누적',
        '2024년 9월 ~ 2026년 8월', sample24,
        unavailable_label='원장 무결성 점검 중에는 수익률을 보여 주지 않습니다.')]))
    return made


# ────────────────────────────────────────────────────────────────────────
# 기대 표
# ────────────────────────────────────────────────────────────────────────
def table(all_series):
    def rr(x):
        return ' · '.join('(%d,%d)' % ab for ab in x) or '없음'
    out = ['| 픽스처 | 점 수 | 결측 순번 | 본선 런 | 벤치마크 런 | 축(아래~위 · 간격) '
           '| 눈금 글자(자리) | 구간별 start~end |',
           '|---|---|---|---|---|---|---|---|']
    for s in all_series:
        miss = [str(i) for i, p in enumerate(s.points)
                if p['y_normalized'] is None]
        bottom, top, step, count = s.axis
        ticks = ' · '.join('%s(%s%s)' % (t['label'], num(t['normalized']),
                                         ' 기준선' if t['is_baseline'] else '')
                           for t in s.ticks)
        segs = ' / '.join('%s %s~%s [점 %d~%d]'
                          % (d['kind'], num(d['start_normalized']),
                             num(d['end_normalized']), d['first'], d['last'])
                          for d in s.segments)
        out.append('| `%s` | %d | %s | %s | %s | %s ~ %s · %s | %s | %s |' % (
            s.name, len(s.points), '·'.join(miss) or '없음', rr(runs(s.points)),
            rr(runs(s.bench)) if s.bench is not None else '없음',
            num(bottom), num(top), num(step), ticks, segs))
    out.append('| `m7_perf_unavailable_gap` | 0 | — | 없음 | 없음 | — | 없음 '
               '| 없음(`unavailable_label` 있음) |')
    out.append('| `m7_perf_masked_integrity` | 0 | — | 없음 | 없음 | — | 없음 '
               '| 없음(`unavailable_label` 있음) |')
    return '\n'.join(out) + '\n'


# ────────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(
        description='계약 v1.3 픽스처를 다시 만든다(멱등 · 손 계산 금지).')
    parser.add_argument(
        '--table', metavar='경로', default=None,
        help='M2 기대 표를 적을 파일(기본 = 쓰지 않는다 · 화면에만 찍는다)')
    args = parser.parse_args()
    assert FX_REL == 'packages/domain_contracts/fixtures', FX_REL
    assert os.path.isdir(FX), FX

    # (a) 전 봉투 버전 한 줄
    n_bumped = 0
    n_already = 0
    for dirpath, _, files in os.walk(FX):
        for f in files:
            if not f.endswith('.json'):
                continue
            p = os.path.join(dirpath, f)
            s = io.open(p, encoding='utf-8', newline='').read()
            assert '\r' not in s, p
            if s.count(OLD_VER) == 1 and s.count(NEW_VER) == 0:
                io.open(p, 'w', encoding='utf-8', newline='').write(
                    s.replace(OLD_VER, NEW_VER, 1))
                n_bumped += 1
            else:
                assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, p
                n_already += 1
    print('버전 치환: 바꿈 %d · 이미 1.3.0 %d' % (n_bumped, n_already))

    # (b) 개정 4
    base24 = load_rows('performance_24m.json')
    base_daily = load_rows('m7/m7_perf_daily_gap.json')
    a = amend_perf('performance_24m.json', [
        ('내 계좌 · 시간가중 · 누적', '2024년 9월 ~ 2026년 8월'),
        ('내 계좌 · 금액가중 · 누적', '2024년 9월 ~ 2026년 8월'),
    ])
    b = amend_perf('m7/m7_perf_daily_gap.json', [
        ('내 계좌 · 시간가중 · 누적', '2026-08-03 ~ 2026-08-31'),
    ])
    for s, lab in ((a[0], '2024년 9월 ~ 2026년 8월'),
                   (b[0], '2026-08-03 ~ 2026-08-31')):
        assert lab == '%s ~ %s' % (s.points[0]['date_text'],
                                   s.points[-1]['date_text'])
    amend_gate()
    amend_archive()

    # (c) 신설 11
    new_archive_empty()
    new_gates()
    new_receipts()
    made = new_perf(base24, base_daily)

    n = sum(1 for _, _, fs in os.walk(FX) for f in fs if f.endswith('.json'))
    print('픽스처 파일 수:', n)
    assert n == 115, n

    a[0].name = 'performance_24m 행 0(TWR)'
    a[1].name = 'performance_24m 행 1(MWR)'
    b[0].name = 'm7_perf_daily_gap'
    t = table(a + b + made)
    if args.table is not None:
        io.open(args.table, 'w', encoding='utf-8', newline='').write(t)
        print('기대 표를 적었다:', args.table)
    print(t)


if __name__ == '__main__':
    main()
