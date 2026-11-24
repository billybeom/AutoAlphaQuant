#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.39(01 §48 · 13 R269 — 미결 230 · 238 · 리뷰 3차 등재) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_v139_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_v137_m5_x7_x1_fixtures.py(신설 판)를 본떴다(그 스크립트는 그 판 재현용으로 그대로 둔다).

하는 일(01 §48 · 398 → 402 = 신설 4 · 개정 1 · 나머지 버전 줄만)
  (a) 전 봉투의 "contract_version": "1.38.0" → "1.39.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 1 — m8/restart_vm_gap7(K349 ⑤ ⑥ · 13 R267 L3 · L7): 분기 = 먼저 비상 이전(옛 폰 회수 뒤에만 첫 클레임이 선다) ·
      고지 = 새로 시작은 킬스위치 · 차단 플래그 · 기록을 이어받지 않는다(승계 구현 0 — 거짓 고지 정정).
  (c) 신설 4 — M5-4 postmortem 목록 3(빈 · SEV2 쓸 차례 · SEV1 씀 + SEV2 기한 넘김) + D-01 배너 1(postmortem 기한 · 조치 = m5Postmortem).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_v139_fixtures.py
"""
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
# 계약 1.38.0 · 픽스처 398 의 기준 커밋(origin/main · E11l2c-3 #351 — 픽스처 JSON = v1.38 7f83be8b 과 같음).
BASE = 'd5191391'

OLD_VER = '"contract_version": "1.38.0"'
NEW_VER = '"contract_version": "1.39.0"'
BASE_FILES = 398
WANT_FILES = 402

META = {
    'fixture_version': '0.1.0-draft', 'contract_version': '1.39.0', 'generated_at': '2026-11-25T09:00:00Z',
    'mode': 'LIVE', 'config_hash': 'cfg_fake_0000000000000000', 'seed': 20261125,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}

AS_OF = {'observed_at': '2026-09-01T09:00:00Z', 'trade_date': '2026-09-01', 'source': 'LOCAL_SQLITE',
         'stale_after_seconds': 93600, 'label': '운영 기준 2026-09-01 18:00'}

GAP7 = 'm8/restart_vm_gap7.json'
PM_EMPTY = 'm5/postmortem_list_empty.json'
PM_DUE = 'm5/postmortem_list_due.json'
PM_WRITTEN_OVERDUE = 'm5/postmortem_list_written_overdue.json'
BANNER_PM = 'm8/incident_banner_postmortem_due.json'
NEW_FILES = (PM_EMPTY, PM_DUE, PM_WRITTEN_OVERDUE, BANNER_PM)

M5_POSTMORTEM = 'aaq://m5/postmortem'
M5_STOPPED = 'aaq://m5/stopped-decision'
X1_EMERGENCY = 'aaq://x1/migration/emergency'

GAP7_OLD_BRANCH = '{ "label": "신규 온보딩으로 진행하고 잔고 이어받기", "deep_link": "aaq://onboarding/mode" }'
GAP7_NEW_BRANCH = '{ "label": "먼저 비상 이전으로 옛 폰을 끊고 새로 시작하기", "deep_link": "%s" }' % X1_EMERGENCY
GAP7_OLD_NOTICE = '"inherit_notice": "킬스위치와 차단 플래그는 켜진 그대로 이어받습니다."'
GAP7_NEW_NOTICE = ('"inherit_notice": "새로 시작하면 옛 폰의 킬스위치 · 차단 플래그 · 기록을 이어받지 않습니다 — '
                   '온보딩을 처음부터 다시 합니다."')

FORM = {
    'prompt_text': '(합성) 무슨 일이 있었고, 다음에는 무엇을 바꾸겠습니까?',
    'hint_text': '(합성) 원인 · 영향 · 바꿀 것 — 숫자보다 사실을 적습니다',
    'notice_text': '(합성) 한 번만 씁니다 — 고칠 일은 새 저널로 남깁니다',
    'button_label': 'postmortem 저장',
}

ROW_SEV2_DUE = {
    'incident_id': 'SEV2-MANUAL_ORDER-20260901',
    'title': '(합성) 수동 주문 1건',
    'severity_label': 'SEV2',
    'level': 'ACT',
    'occurred_text': '09-01 10:12 발생',
    'due_text': '기한 09-08 10:12',
    'overdue': False,
    'state_label': '쓸 차례',
    'written_text': None,
    'form': FORM,
    'next_link': None,
}

ROW_SEV1_WRITTEN = {
    'incident_id': 'SEV1-BREAKER_STOPPED-20260828',
    'title': '(합성) 서킷브레이커 STOPPED',
    'severity_label': 'SEV1',
    'level': 'BLOCKED',
    'occurred_text': '08-28 14:02 발생',
    'due_text': None,
    'overdue': False,
    'state_label': '썼습니다 — STOPPED 결정이 닫습니다',
    'written_text': '(합성) 낙폭이 정지 문턱을 넘어 신규 주문을 멈췄다 · 보유는 그대로 · 다음 달 계획 전에 재개 사다리를 다시 본다',
    'form': None,
    'next_link': {'label': 'STOPPED 결정으로', 'deep_link': M5_STOPPED},
}

ROW_SEV2_OVERDUE = {
    'incident_id': 'SEV2-MANUAL_ORDER-20260820',
    'title': '(합성) 수동 주문 1건',
    'severity_label': 'SEV2',
    'level': 'ACT',
    'occurred_text': '08-20 09:41 발생',
    'due_text': '기한이 지났습니다(08-27 09:41)',
    'overdue': True,
    'state_label': '쓸 차례',
    'written_text': None,
    'form': FORM,
    'next_link': None,
}


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


def pm_vm(rows, headline, level, empty_label=None):
    assert (len(rows) == 0) == (empty_label is not None)
    for r in rows:
        assert r['incident_id']
        assert r['form'] is None or r['written_text'] is None, r['incident_id']
        assert r['next_link'] is None or r['next_link']['deep_link'] == M5_STOPPED
    return {'headline': headline, 'level': level, 'rows': rows, 'empty_label': empty_label, 'as_of': AS_OF}


def banner_text():
    b = {'banner': {
        'kind': 'OTHER', 'level': 'ACT',
        'title': '(합성) 써야 할 postmortem 이 있습니다',
        'body_text': '(합성) 수동 주문 사건의 postmortem 을 기한 09-08 10:12 까지 써야 합니다.',
        'action_link': {'label': 'postmortem 쓰기', 'deep_link': M5_POSTMORTEM},
    }}
    return envelope('    ' + inline(b))


def gap7(s):
    assert s.count(GAP7_OLD_BRANCH) == 1 and s.count(GAP7_OLD_NOTICE) == 1, GAP7
    return s.replace(GAP7_OLD_BRANCH, GAP7_NEW_BRANCH).replace(GAP7_OLD_NOTICE, GAP7_NEW_NOTICE)


def main():
    check_base_fresh()
    rels = base_files()
    preload(rels)
    for rel in NEW_FILES:
        assert rel not in _BASE_CACHE, rel
    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}
    out[GAP7] = gap7(out[GAP7])
    out[PM_EMPTY] = envelope(row_text(pm_vm(
        [], '(합성) 써야 할 postmortem 이 없습니다', 'OK', '(합성) 열린 사건 가운데 postmortem 을 쓸 것이 없습니다')))
    out[PM_DUE] = envelope(row_text(pm_vm(
        [ROW_SEV2_DUE], '(합성) 써야 할 postmortem 1건', 'ACT')))
    out[PM_WRITTEN_OVERDUE] = envelope(row_text(pm_vm(
        [ROW_SEV1_WRITTEN, ROW_SEV2_OVERDUE], '(합성) 기한이 지난 postmortem 1건', 'ACT')))
    out[BANNER_PM] = banner_text()
    assert len(out) == WANT_FILES, len(out)
    for rel, text in out.items():
        json.loads(text)
        path = os.path.join(FX, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(text)
    print('픽스처 %d(신설 %d · 개정 1)' % (len(out), len(NEW_FILES)))


if __name__ == '__main__':
    main()
