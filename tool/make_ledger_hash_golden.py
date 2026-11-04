"""X5-1 정규 직렬화 골든 — Dart 와 독립된 구현(설계 13 §8 R51 H3~H9 · 표준 라이브러리만).

쓰는 곳: packages/core_engine/test/golden/vectors/ledger_hash_v1.json
실행:   py -3 -I -B tool/make_ledger_hash_golden.py
규칙 정본 = packages/core_engine/lib/src/ops/ledger_hash.dart 머리말 · 이 파일은 같은 규칙을 따로 구현해 대조한다.
값 표기(골든 안) = {"i": 정수} · {"d": "repr 문자열"} · {"s": "문자열"} · null.
"""
import hashlib
import json
import math
import os
import re
import sys
from datetime import datetime, timedelta, timezone
from decimal import Decimal

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', 'packages', 'core_engine', 'test', 'golden', 'vectors', 'ledger_hash_v1.json')

GENESIS = '0' * 64
ORDER = [
    'executions', 'trades', 'cash_flow', 'decision_log', 'rebalance_event', 'decision_journal',
    'order_intents', 'advice', 'advice_transition', 'external_holding', 'self_report_balance',
    'self_report_line', 'handover_session', 'operating_mode_transition', 'operating_param_log', 'ledger_event',
]


def canon_double(x):
    if math.isnan(x) or math.isinf(x):
        raise ValueError('not finite')
    if x == 0:
        return '0.0'
    s = format(Decimal(repr(x)), 'f')
    if '.' not in s:
        s += '.0'
    s = s.rstrip('0')
    if s.endswith('.'):
        s += '0'
    return s


def canon_string(s):
    out = ['"']
    short = {'"': '\\"', '\\': '\\\\', '\b': '\\b', '\f': '\\f', '\n': '\\n', '\r': '\\r', '\t': '\\t'}
    for ch in s:
        if ch in short:
            out.append(short[ch])
        elif ord(ch) < 0x20:
            out.append('\\u%04x' % ord(ch))
        else:
            out.append(ch)
    out.append('"')
    return ''.join(out)


def decode(v):
    if v is None:
        return None
    (k, x), = v.items()
    return {'i': int, 'd': float, 's': str}[k](x)


def canon_value(v):
    if v is None:
        return 'null'
    if isinstance(v, bool):
        raise TypeError('bool')
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        return canon_double(v)
    if isinstance(v, str):
        return canon_string(v)
    raise TypeError(type(v))


def canon_row(row):
    return '{' + ','.join(canon_string(k) + ':' + canon_value(row[k]) for k in sorted(row)) + '}'


ISO = re.compile(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,6}))?)?(Z|[+-]\d{2}:\d{2})$')


def kst_date(s):
    m = ISO.match(s)
    if not m:
        raise ValueError(s)
    y, mo, d, h, mi, sec, frac, off = m.groups()
    t = datetime(int(y), int(mo), int(d), int(h), int(mi), int(sec or 0), int((frac or '0').ljust(6, '0')))
    if off == 'Z':
        delta = timedelta(0)
    else:
        sign = 1 if off[0] == '+' else -1
        delta = sign * timedelta(hours=int(off[1:3]), minutes=int(off[4:6]))
    utc = t - delta
    return (utc + timedelta(hours=9)).strftime('%Y-%m-%d')


def day_hash(lines_by_table):
    buf = []
    for t in ORDER:
        for line in sorted(lines_by_table.get(t, []), key=lambda l: l.encode('utf-8')):
            buf.append(t + '\t' + line + '\n')
    return hashlib.sha256(''.join(buf).encode('utf-8')).hexdigest()


def row_counts(lines_by_table):
    return canon_row({t: len(lines_by_table.get(t, [])) for t in ORDER})


def chain(prev, day):
    return hashlib.sha256((prev + day).encode('ascii')).hexdigest()


I = lambda x: {'i': x}
D = lambda x: {'d': repr(float(x))}
S = lambda x: {'s': x}

# ── 고정 행(고정 투영 칸 전부 · 축 = 그 행의 칸 · self_report_line 은 부모) ──
EXEC = lambda eid, at, qty, price: {
    'execution_id': S(eid), 'broker_order_no': None, 'executed_at': S(at), 'quantity': I(qty), 'price': D(price),
    'commission': D(0.0), 'tax': D(-0.0), 'authored_at': S(at), 'fill_origin': S('MANUAL'), 'fill_kind': S('ORIGINAL'),
    'advice_id': None, 'reverses_fill_id': None, 'restates_fill_id': None, 'authored_by_device_id': S('dev-1'),
    'backdate_trading_days': I(0), 'cost_source': S('USER_ENTERED'), 'off_hour_trade': I(0), 'during_halt': I(0),
    'price_range_source_date': None,
}
DAYS = [
    ('2026-11-02', {
        'executions': [
            EXEC('E-2', '2026-11-02T00:10:00.000Z', 3, 15050.5),
            EXEC('E-1', '2026-11-01T15:00:00.000Z', 1, 100000.0),   # 한국 11-02 00:00 = 이 날
        ],
        'cash_flow': [{
            'flow_id': S('F-1'), 'trade_date': S('2026-11-02'), 'amount': D(100000.0), 'currency': S('KRW'),
            'kind': S('DEPOSIT'), 'note': S('월 납입 "10만" \\ 탭\t줄\n🔴 끝\x01'),
            'recorded_at': S('2026-11-02T14:59:59.999Z'),           # 한국 23:59:59.999 = 이 날
            'source_event_id': None, 'account_alias': S('main'),
        }],
        'decision_log': [{
            'decision_id': S('D-1'), 'created_at': S('2026-11-02T09:00:00+09:00'), 'trade_date': S('2026-11-02'),
            'mode': S('LIVE'), 'kind': S('REBALANCE'), 'strategy_id': S('P0S'), 'sleeve': None, 'symbol': None,
            'reason': S('월말 정기 리밸런싱 — 대상 3건 · 집행 2026-11-03'), 'reason_code': S('MONTHLY_REGULAR'),
            'tier': None, 'exit_kind': None, 'trigger_price': D(1e21), 'threshold_registered': D(-0.25),
            'rule_cited': None, 'regime_ref': S('2026-10-30'), 'config_hash': S('cfg_plan'),
            'parent_decision_id': None, 'journal_id': None,
        }],
        'operating_param_log': [{
            'row_id': I(7), 'param_key': S('monthly_contribution_krw'), 'value_text': S('100000'),
            'changed_at': S('2026-11-02T08:30:00+09:00'), 'effective_from': S('2026-11-25'),
            'action_run_id': S('run-1'), 'device_id': S('dev-1'),
        }],
        'self_report_balance': [{
            'report_id': S('R-1'), 'as_of_trade_date': S('2026-11-02'), 'account_alias': S('main'),
            'session_started_at': S('2026-11-02T10:00:00.000Z'), 'cash_krw': D(1.5e-7), 'declared_complete': I(1),
            'device_id': S('dev-1'), 'command_id': S('C-1'), 'reported_at': S('2026-11-02T10:05:00.000Z'),
        }],
        'self_report_line': [
            {'report_id': S('R-1'), 'symbol': S('133690'), 'quantity': I(1)},
            {'report_id': S('R-1'), 'symbol': S('069500'), 'quantity': I(3)},
        ],
    }),
    ('2026-11-03', {}),   # 행 없는 날 — 그래도 1행
    ('2026-11-04', {
        'executions': [EXEC('E-3', '2026-11-03T15:00:00.000Z', 2, 0.30000000000000004)],
        'order_intents': [{
            'intent_id': S('I-1'), 'idempotency_key': S('k-1'), 'created_at': S('2026-11-04T00:10:00.000Z'),
            'trade_date': S('2026-11-04'), 'market': S('KR'), 'account': S('main'), 'strategy_id': S('P0S_B'),
            'decision_id': S('B-REBAL-2026-10-30@2026-11-04'), 'symbol': S('133690'), 'side': S('BUY'),
            'order_type': S('LIMIT'), 'quantity': I(2), 'limit_price': D(1e16), 'sizing_binding': None,
            'config_hash': S('cfg_plan'), 'dry_run': I(0), 'mode': S('LIVE'), 'operating_mode': S('AUTO_TRADE'),
        }],
    }),
]
SR_AXIS = {'R-1': '2026-11-02T10:05:00.000Z'}

DOUBLES = [0.1, 1.0, -0.0, 0.0, 100.0, 1e16, 1e20, 1e21, 1.5e-7, 1e-7, 0.000001, 123456.789, 5e-324,
           1.7976931348623157e308, -2.5, 0.30000000000000004, 12345678901234567890.0, -1e-10, 2.0 ** 53]
STRINGS = ['', 'ascii', '따옴표 " 역슬래시 \\', '\b\f\n\r\t', '\x00\x01\x1f', '\x7f é 한글 🔴', '/ < > &']
AXES = ['2026-11-02T14:59:59.999Z', '2026-11-02T15:00:00.000Z', '2026-11-02T23:59:59+09:00',
        '2026-11-02T00:00:00-05:00', '2026-11-02T09:00Z', '2026-11-02T09:00:00.123456Z']


def main():
    days_out = []
    prev = GENESIS
    for date, tables in DAYS:
        lines = {}
        for t, rows in tables.items():
            for r in rows:
                row = {k: decode(v) for k, v in r.items()}
                axis = SR_AXIS[row['report_id']] if t == 'self_report_line' else row[
                    {'executions': 'authored_at', 'cash_flow': 'recorded_at', 'decision_log': 'created_at',
                     'operating_param_log': 'changed_at', 'self_report_balance': 'reported_at',
                     'order_intents': 'created_at'}[t]]
                assert kst_date(axis) == date, (t, axis, date)
                lines.setdefault(t, []).append(canon_row(row))
        dh = day_hash(lines)
        ch = chain(prev, dh)
        days_out.append({
            'date': date,
            'rows': tables,
            'lines': {t: sorted(v, key=lambda l: l.encode('utf-8')) for t, v in lines.items()},
            'day_hash': dh,
            'row_counts': row_counts(lines),
            'chain_hash': ch,
        })
        prev = ch
    out = {
        'about': 'X5-1 정규 직렬화 골든 v1 — tool/make_ledger_hash_golden.py(Python 독립 구현)가 만든다. 손으로 고치지 않는다.',
        'hash_format_version': 1,
        'genesis': GENESIS,
        'population': ORDER,
        'self_report_axis': SR_AXIS,
        'doubles': [{'value': repr(x), 'canonical': canon_double(x)} for x in DOUBLES],
        'strings': [{'value': s, 'canonical': canon_string(s)} for s in STRINGS],
        'axes': [{'value': a, 'kst_date': kst_date(a)} for a in AXES],
        'empty_day_hash': hashlib.sha256(b'').hexdigest(),
        'days': days_out,
        'stamp': {'chain': prev, 'display': 'chn_' + prev[:4] + '…' + prev[62:], 'carry': prev[:16]},
    }
    with open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=True, indent=1)
        f.write('\n')
    print('ok', OUT, prev)


if __name__ == '__main__':
    main()
