#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.37(M5 판 — 01 §46 · K317~K330) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_v137_m5_x7_x1_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_v135_contract_debts_fixtures.py 를 본떴다(그 스크립트는 그 판 재현용으로 그대로 둔다).

하는 일(01 §46 · 393 → 398 = 신설 5 · 개정 0 · 버전 줄만 393)
  (a) 전 봉투의 "contract_version": "1.36.0" → "1.37.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 5
      · `m5/self_audit_resolve_open.json`(K318 · K321) — `SelfAuditResolveVm` 1행: 플래그 섬 · 카운터 2 · 열린 자가 보고 차이 2(수량 =
        기준 `m6/self_report_diff_result.json` 결과 행 · 현금 = 아래 CASH 행) · 행 조치 «다시 실사하기» · 실사 링크 1 · 보관 1 · 일괄 확정.
      · `m5/self_audit_resolve_held_blocked.json`(K319) — 보관 2 · `LEDGER_INTEGRITY` 점검 중(확정 null · 막힘 문장) · 차이 0.
      · `m5/self_audit_resolve_clear.json` — 표식 없음 · 카운터 2(0) · 차이 0 · 보관 0(빈 문장들).
      · `m5/held_review_results.json`(K319) — `SafetyActionResult` 4행(확정 1 · 거부 3 = `HeldReviewResultCodes`).
      · `m6/self_report_cash_2.json`(K323 · 미결 225) — `SelfReportSession` 2행 = 기준 `m6/self_report_diff_result.json` 행 복사 +
        `result` 교체: ① 현금 축 차이 1(`CANON_SELF_REPORT` · `CASH` · 관측) ② 차이 0 · 현금 미대조 문장(허용 오차 값 없음).
  금액 = 합성 · 계좌번호 · 기기 원문 · 시크릿 0 · 새 수치(허용 오차 · 문턱 · TTL) 0.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_v137_m5_x7_x1_fixtures.py
"""
import copy
import io
import json
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures')).replace(os.sep, '/')
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/')
FX_REL = os.path.relpath(FX, ROOT).replace(os.sep, '/')
# 계약 1.36.0 · 픽스처 393 의 기준 커밋(origin/main · E220b 병합 PR #329 squash 2ce2eee3 — 픽스처 JSON = v1.36 542dd644 와 같음).
BASE = '2ce2eee3'

OLD_VER = '"contract_version": "1.36.0"'
NEW_VER = '"contract_version": "1.37.0"'
BASE_FILES = 393
WANT_FILES = 398

META = {
    'fixture_version': '0.1.0-draft', 'contract_version': '1.37.0', 'generated_at': '2026-11-24T09:00:00Z',
    'mode': 'LIVE', 'config_hash': 'cfg_fake_0000000000000000', 'seed': 20261124,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}

AS_OF = {'observed_at': '2026-09-01T09:00:00Z', 'trade_date': '2026-09-01', 'source': 'LOCAL_SQLITE',
         'stale_after_seconds': 93600, 'label': '실사 기준 2026-09-01 18:00'}

SR_SRC = 'm6/self_report_diff_result.json'
RESOLVE_OPEN = 'm5/self_audit_resolve_open.json'
RESOLVE_BLOCKED = 'm5/self_audit_resolve_held_blocked.json'
RESOLVE_CLEAR = 'm5/self_audit_resolve_clear.json'
HELD_RESULTS = 'm5/held_review_results.json'
CASH_NEW = 'm6/self_report_cash_2.json'
NEW_FILES = (RESOLVE_OPEN, RESOLVE_BLOCKED, RESOLVE_CLEAR, HELD_RESULTS, CASH_NEW)

L3_LINK = 'aaq://ledger/self-report/2026-08/연금저축'
L3_LINK_GENERAL = 'aaq://ledger/self-report/2026-08/일반'
SR_ROUTE_LABEL = '다시 실사로 해소'          # K320 — 자가 보고 차이의 경로 글자(자동 재동기화 · 승인 필요 아님)
REAUDIT = {'label': '다시 실사하기', 'deep_link': L3_LINK}

CASH_ROW = {
    'diff_id': 'ld_sr_0002',
    'pair': 'CANON_SELF_REPORT',
    'axis': 'CASH',
    'authored_date': '2026-08-31',
    'delta_label': '원화 현금이 기록과 다릅니다 (원장 412,300원 / 자가 보고 405,300원)',
    'severity': 'OBSERVATIONAL',
    'candidate_origin_codes': ['EXTERNAL_CASHFLOW', 'UNRECORDED_FILL', 'SELF_REPORT_CORRECTION'],
    'status': 'OPEN',
    'route': 'AUTO',
    'evidence_hash': 'ev_9c27e1d4b083',
    'applicable': True,
    'pair_label': '자가 보고 대조',
    'axis_label': '현금',
    'severity_label': '관측 항목 — 주문을 막지 않습니다',
    'status_label': '열림',
    'route_label': SR_ROUTE_LABEL,
    'candidate_origins': [
        {'code': 'EXTERNAL_CASHFLOW', 'label': '시스템 밖 입출금', 'tone': 'NEUTRAL'},
        {'code': 'UNRECORDED_FILL', 'label': '기록되지 않은 체결', 'tone': 'NEUTRAL'},
        {'code': 'SELF_REPORT_CORRECTION', 'label': '실사 보고와 원장이 다름', 'tone': 'NEUTRAL'},
    ],
    'detected_at_text': '탐지 2026-08-31 12:10',
    'action_link': None,
}

CASH_NOT_COMPARED = ('수량은 원장과 맞습니다 · 현금은 허용 오차가 정해지기 전이라 대조하지 않았습니다(적은 값은 기록에 남습니다)')

COUNTERS_OPEN = [
    '미처리 갭 — 기록 없이 닫힌 안내 뒤 6거래일(안내가 없던 날은 세지 않습니다)',
    '실사 갭 — 일반 위탁 계좌 마지막 실사 뒤 63일',
]
COUNTERS_CLEAR = [
    '미처리 갭 — 0거래일',
    '실사 갭 — 마지막 실사 뒤 1일',
]

HELD_ROWS = [
    {'command_id': 'cmd_20260902_0101', 'kind_label': '수기 체결 기록',
     'summary_text': '(합성) 069500 매수 3주 · 2026-09-02 체결', 'received_at_text': '2026-09-02 10:14 접수',
     'state_label': '보관 — 무결성 점검 뒤 확정'},
    {'command_id': 'cmd_20260902_0102', 'kind_label': '정기 실사 제출',
     'summary_text': '(합성) 2026-08 연금저축 계좌 실사', 'received_at_text': '2026-09-02 10:31 접수',
     'state_label': '보관 — 무결성 점검 뒤 확정'},
]

HELD_RESULT_ROWS = [
    ('ar_held_01', 'OK', '(합성) 보관된 명령 1건을 확정했습니다 — 보통 접수 규칙으로 처리합니다', None, False),
    ('ar_held_02', 'WATCH', '(합성) 그 사이 보관 명령이 바뀌었습니다 — 화면을 다시 읽고 확정하십시오', 'HELD_REVIEW_STALE', True),
    ('ar_held_03', 'BLOCKED', '(합성) 원장 무결성 점검이 끝나야 확정할 수 있습니다', 'HELD_REVIEW_INTEGRITY_ACTIVE', False),
    ('ar_held_04', 'BLOCKED', '(합성) 확정 요청의 꼴이 맞지 않습니다 — 화면의 확정 버튼만 받습니다', 'HELD_REVIEW_ARGS_INVALID', False),
]


def git(*args):
    return subprocess.check_output(['git', '-C', ROOT] + list(args)).decode('utf-8')


_BASE_CACHE = {}


def preload(rels):
    req = ''.join('%s:%s/%s\n' % (BASE, FX_REL, rel) for rel in rels).encode('utf-8')
    raw = subprocess.run(['git', '-C', ROOT, 'cat-file', '--batch'], input=req, stdout=subprocess.PIPE,
                         check=True).stdout
    pos = 0
    for rel in rels:
        nl = raw.index(b'\n', pos)
        head = raw[pos:nl].decode('utf-8').split(' ')
        assert len(head) == 3 and head[1] == 'blob', (rel, head)
        size = int(head[2])
        s = raw[nl + 1:nl + 1 + size].decode('utf-8')
        assert '\r' not in s, rel
        _BASE_CACHE[rel] = s
        pos = nl + 1 + size + 1
    assert pos == len(raw), (pos, len(raw))


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def check_base_fresh():
    """rebase 뒤 밑동(merge-base HEAD origin/main)의 픽스처 트리가 BASE 와 다르면 멈춘다."""
    try:
        mb = git('merge-base', 'HEAD', 'origin/main').strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다(BASE 상수 갱신)'
                         % (mb[:8], BASE[:8]))


def inline(v):
    """한 줄 꼴(`{ "k": v }` · 빈 `{}` 그대로) — 기존 표본과 같은 줄 꼴."""
    t = json.dumps(v, ensure_ascii=False, separators=(', ', ': '))
    t = re.sub(r'\{(?!\})', '{ ', t)
    return re.sub(r'(?<!\{)\}', ' }', t)


def envelope(rows_text):
    head = ('{\n  "meta": {\n' + ',\n'.join('    "%s": %s' % (k, json.dumps(v, ensure_ascii=False)) for k, v in META.items())
            + '\n  },\n  "as_of": ' + inline(AS_OF) + ',\n  "empty_kind": "NO_DATA",\n  "empty_label": null,\n  "has_more": false,\n')
    return head + '  "rows": [\n' + rows_text + '\n  ]\n}\n'


def row_text(v):
    """VM 한 행 — 최상위 키마다 한 줄(목록 · 객체는 원소마다 한 줄)."""
    keys = list(v.keys())
    lines = ['    {']
    for i, k in enumerate(keys):
        comma = ',' if i < len(keys) - 1 else ''
        val = v[k]
        if isinstance(val, list) and val and isinstance(val[0], dict):
            lines.append('      "%s": [' % k)
            for j, e in enumerate(val):
                lines.append('        %s%s' % (inline(e), ',' if j < len(val) - 1 else ''))
            lines.append('      ]%s' % comma)
        else:
            lines.append('      "%s": %s%s' % (k, inline(val), comma))
    lines.append('    }')
    return '\n'.join(lines)


def sr_qty_row():
    """기준 L-3 결과의 수량 차이 행 → M5-13 행(조치 = 다시 실사 · 경로 = 관측 AUTO · 글자 = K320)."""
    src = json.loads(_BASE_CACHE[SR_SRC])
    diffs = src['rows'][0]['result']['diffs']
    assert len(diffs) == 1 and diffs[0]['pair'] == 'CANON_SELF_REPORT' and diffs[0]['axis'] == 'QUANTITY', diffs
    r = copy.deepcopy(diffs[0])
    r['route'] = 'AUTO'
    r['route_label'] = SR_ROUTE_LABEL
    r['action_link'] = REAUDIT
    return r


def resolve_vm(kind):
    base = {
        'headline': None, 'level': None, 'flag_line': None,
        'release_rule_text': '(합성) 대응 계좌의 실사가 모두 0오차로 통과하면 엔진이 스스로 풉니다 · 수동 해제는 없습니다',
        'counter_lines': None, 'diffs': [], 'diffs_empty_label': None, 'audit_links': [],
        'held_commands': [], 'held_empty_label': None, 'confirm_held': None, 'held_blocked_text': None,
        'as_of': AS_OF,
    }
    if kind == 'open':
        cash = copy.deepcopy(CASH_ROW)
        cash['action_link'] = REAUDIT
        base.update({
            'headline': '(합성) 신규 진입 안내가 멈춰 있습니다 — 원장 실사가 필요합니다',
            'level': 'ACT',
            'flag_line': '(합성) 원장 미검증 · 09-01부터 · 청산 · 방어 안내는 그대로 냅니다',
            'counter_lines': COUNTERS_OPEN,
            'diffs': [sr_qty_row(), cash],
            'audit_links': [{'label': '일반 위탁 계좌 실사 하기', 'deep_link': L3_LINK_GENERAL}],
            'held_commands': [HELD_ROWS[0]],
            'confirm_held': {'id': 'HELD_COMMANDS_CONFIRM', 'args': {'review_id': 'hr_20260902_01'},
                             'label': '보관된 명령 1건 확정'},
        })
    elif kind == 'blocked':
        base.update({
            'headline': '(합성) 보관된 명령 2건 — 무결성 점검 중',
            'level': 'WATCH',
            'flag_line': '(합성) 원장 미검증 표식이 없습니다',
            'counter_lines': COUNTERS_CLEAR,
            'diffs_empty_label': '(합성) 열린 자가 보고 차이가 없습니다',
            'held_commands': HELD_ROWS,
            'held_blocked_text': '(합성) 원장 무결성 점검이 끝나야 확정할 수 있습니다',
        })
    else:
        base.update({
            'headline': '(합성) 원장 실사로 해소할 것이 없습니다',
            'level': 'OK',
            'flag_line': '(합성) 원장 미검증 표식이 없습니다',
            'counter_lines': COUNTERS_CLEAR,
            'diffs_empty_label': '(합성) 열린 자가 보고 차이가 없습니다',
            'held_empty_label': '(합성) 보관된 명령이 없습니다',
        })
    assert None not in (base['headline'], base['level'], base['flag_line'], base['counter_lines']), kind
    return base


def held_results_text():
    rows = []
    for rid, level, headline, code, retry in HELD_RESULT_ROWS:
        rows.append('\n'.join([
            '    {',
            '      "action_run_id": %s,' % json.dumps(rid),
            '      "id": "HELD_COMMANDS_CONFIRM",',
            '      "level": %s,' % json.dumps(level),
            '      "headline": %s,' % json.dumps(headline, ensure_ascii=False),
            '      "reason_code": %s,' % ('null' if code is None else json.dumps(code)),
            '      "handoff_route": null,',
            '      "retryable": %s' % ('true' if retry else 'false'),
            '    }']))
    return envelope(',\n'.join(rows))


def cash_text():
    src = json.loads(_BASE_CACHE[SR_SRC])
    base_row = src['rows'][0]
    assert base_row['result'] is not None and base_row['cash_hint_label'], SR_SRC
    rows = []
    for variant in ('diff', 'not_compared'):
        r = copy.deepcopy(base_row)
        if variant == 'diff':
            r['result'] = {'diffs': [CASH_ROW], 'empty_label': None,
                           'resolve_link': {'label': '차이 해소하기', 'deep_link': 'aaq://m5/self-audit-resolve'},
                           'next_account_link': r['result']['next_account_link']}
        else:
            r['result'] = {'diffs': [], 'empty_label': CASH_NOT_COMPARED, 'resolve_link': None,
                           'next_account_link': r['result']['next_account_link']}
        r['as_of'] = AS_OF
        rows.append(row_text(r))
    return envelope(',\n'.join(rows))


def main():
    check_base_fresh()
    rels = base_files()
    preload(rels)
    for rel in NEW_FILES:
        assert rel not in _BASE_CACHE, rel
    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}
    out[RESOLVE_OPEN] = envelope(row_text(resolve_vm('open')))
    out[RESOLVE_BLOCKED] = envelope(row_text(resolve_vm('blocked')))
    out[RESOLVE_CLEAR] = envelope(row_text(resolve_vm('clear')))
    out[HELD_RESULTS] = held_results_text()
    out[CASH_NEW] = cash_text()

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    for rel in rels:
        assert _BASE_CACHE[rel].replace(OLD_VER, NEW_VER, 1) == out[rel], rel
    for rel in NEW_FILES:
        env = json.loads(out[rel])
        assert env['meta']['contract_version'] == '1.37.0', rel
        assert out[rel].count(NEW_VER) == 1, rel
        assert '\r' not in out[rel], rel
    vms = [json.loads(out[r])['rows'][0] for r in (RESOLVE_OPEN, RESOLVE_BLOCKED, RESOLVE_CLEAR)]
    for vm in vms:
        assert (vm['diffs_empty_label'] is None) == bool(vm['diffs'])
        assert (vm['held_empty_label'] is None) == bool(vm['held_commands'])
        assert not (vm['confirm_held'] and vm['held_blocked_text'])
        assert len(vm['counter_lines']) in (0, 2)
    cash = json.loads(out[CASH_NEW])['rows']
    assert [len(r['result']['diffs']) for r in cash] == [1, 0]

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_v137_m5_x7_x1_fixtures: %d files (기준 %d · 버전 줄만 %d · 신설 %d) · contract 1.37.0'
          % (len(out), BASE_FILES, BASE_FILES, len(NEW_FILES)))


if __name__ == '__main__':
    main()
