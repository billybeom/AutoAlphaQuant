#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.28(M9 `S04` 배분 화면 첫 판 · 보기 전용 · 01 §37) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_s04_v128_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
관례는 gen_trackc_v126_fixtures.py(계약 v1.26 · 그 스크립트는 v1.26 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-20_S04첫판_계약v1.28_설계서.md` §5 · 360 → 362 = 신설 2 · 개정 0 · 버전 줄만 360)
  (a) 전 봉투의 "contract_version": "1.27.0" → "1.28.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 2 — `m9/allocation_editor`(정본 P0S) · `m9/allocation_editor_stale`(같은 VM · 낡음 배너).
  (c) 🔴 글자 출처 = 엔진 시험 원문(BASE 의 `packages/core_engine/test/allocation_view_test.dart` 기대값)을 그대로 읽어 짓는다 —
      카드 4칸 · 묶음 머리 3 · 행 10(코드 · 이름 · 값 · 덧붙임) · 바꾸는 길 3. 엔진 시험이 바뀌면 이 생성기가 멈춘다(대조).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다).

🔴 돈·수치 0 새로 정함 — 비중 · 밴드 · 한도 · 금 상한 = 엔진 운영 설정 객체가 지은 글자 그대로(엔진 시험이 정본).
🔴 봉투 `meta.mode` = LIVE(전 표본 선례) · 낡음 = VM `as_of.stale_label` 만(봉투 `as_of` 에는 싣지 않는다 — `m9/backup_stale` 선례).

멱등: 언제나 기준 커밋(BASE)의 원문에서 다시 만든다(`git cat-file --batch`). 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_s04_v128_fixtures.py
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
# 계약 1.27.0 · 픽스처 360 의 기준 커밋(origin/main · #280 e13 표본 정정 — RECON 성공 글자 v1.26 글자로).
BASE = 'ccd88f3180235e0fd9ded9b774714d35544e2a71'

OLD_VER = '"contract_version": "1.27.0"'
NEW_VER = '"contract_version": "1.28.0"'
BASE_FILES = 360
WANT_FILES = 362

ENGINE_TEST = 'packages/core_engine/test/allocation_view_test.dart'
ENGINE_SRC = 'packages/core_engine/lib/src/ops/allocation_view.dart'

ED = 'm9/allocation_editor.json'
ED_STALE = 'm9/allocation_editor_stale.json'
NEW_FILES = [ED, ED_STALE]

ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
VM_KEYS = ['current', 'sections', 'change_path_lines', 'as_of']
CARD_KEYS = ['label', 'weights_text', 'backtest_text', 'honest_note_text']
SEC_KEYS = ['title', 'rows']
ROW_KEYS = ['code', 'label', 'value_text', 'note_text']
FORBIDDEN_KEYS = {'level', 'locked_label', 'empty_label', 'apply', 'apply_action', 'preview', 'draft', 'slider',
                  'select_action', 'presets', 'actions', 'pnl', 'profit', 'return_pct'}

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.28.0',
    'generated_at': '2026-11-20T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261120,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}

AS_OF = {'observed_at': '2026-11-20T09:30:00Z', 'trade_date': '2026-11-20', 'source': 'LOCAL_SQLITE',
         'stale_after_seconds': 93600, 'label': '설정 기준 2026-11-20 18:30'}
AS_OF_OLD = {'observed_at': '2026-11-19T03:30:00Z', 'trade_date': '2026-11-19', 'source': 'LOCAL_SQLITE',
             'stale_after_seconds': 93600, 'label': '설정 기준 2026-11-19 12:30'}
STALE_LABEL = '배분 설정을 다시 읽지 못한 지 오래됐습니다. 화면을 다시 열면 새로 읽습니다.'   # m9 낡음 표본 선례 꼴


def git(*args):
    return subprocess.check_output(['git', '-C', ROOT] + list(args)).decode('utf-8')


def lits(s):
    """Dart 글자 리터럴(작은따옴표) 이어 붙이기 — 인접 리터럴 = 한 글자."""
    return ''.join(re.findall(r"'((?:[^'\\]|\\.)*)'", s))


def camel_to_wire(name):
    return re.sub(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', '_', name).upper()


def engine_vm():
    """엔진 시험 원문 → VM(카드 · 묶음 · 행 · 바꾸는 길)."""
    t = git('show', '%s:%s' % (BASE, ENGINE_TEST))
    card = {}
    for key, field in (('label', 'label'), ('weights_text', 'weightsText'), ('backtest_text', 'backtestText'),
                       ('honest_note_text', 'honestNoteText')):
        m = re.search(r'v\.current\.%s,\s*((?:\'(?:[^\'\\]|\\.)*\'\s*)+),?\s*\)' % field, t)
        assert m, field
        card[key] = lits(m.group(1))
    m = re.search(r"s\.title\)\.toList\(\),\s*<String>\[(.*?)\]", t, re.S)
    titles = re.findall(r"'([^']*)'", m.group(1))
    assert titles == ['리밸런싱 밴드', '리스크 한도', '금 상한'], titles
    rows = []
    for m in re.finditer(r"expect\(rows\[AllocationViewRowCodes\.(\w+)\], <String, Object\?>\{(.*?)\}\);", t, re.S):
        body = m.group(2)
        f = {k: lits(v) for k, v in re.findall(r"'(section|label|value|note)':\s*((?:'(?:[^'\\]|\\.)*'\s*)+),", body)}
        assert set(f) == {'section', 'label', 'value', 'note'}, (m.group(1), f.keys())
        rows.append((f['section'], dict(zip(ROW_KEYS, [camel_to_wire(m.group(1)), f['label'], f['value'], f['note']]))))
    assert len(rows) == 10, len(rows)
    sections = []
    for title in titles:
        sections.append(dict(zip(SEC_KEYS, [title, [r for s, r in rows if s == title]])))
    assert [len(s['rows']) for s in sections] == [3, 5, 2]
    m = re.search(r"expect\(v\.changePathLines, <String>\[(.*?)\]\);", t, re.S)
    path = [lits(x) for x in re.findall(r"((?:'(?:[^'\\]|\\.)*'\s*)+),", m.group(1))]
    assert len(path) == 3, path
    return card, sections, path


def check_engine_codes():
    src = git('show', '%s:%s' % (BASE, ENGINE_SRC))
    codes = re.findall(r"static const String (\w+) = '([A-Z_]+)';", src.split('abstract final class AllocationViewRowCodes')[1].split('}')[0])
    assert len(codes) == 10
    for name, wire in codes:
        assert camel_to_wire(name) == wire, (name, wire)
    cols = re.findall(r"static const String \w+ = '(allocation_[a-z_]+)';", src)
    assert cols == ['allocation_label', 'allocation_weights_text', 'allocation_backtest_text', 'allocation_honest_note_text',
                    'allocation_sections', 'allocation_change_path_lines', 'allocation_as_of'], cols
    return [w for _, w in codes]


# ── 직렬화(gen_trackc_v126 와 같은 꼴) ──
def dumps(v):
    return json.dumps(v, ensure_ascii=False)


def is_scalar(v):
    return not isinstance(v, (dict, list))


def is_flat(v):
    return isinstance(v, dict) and all(
        is_scalar(x) or (isinstance(x, dict) and all(is_scalar(y) for y in x.values())) for x in v.values())


def inline(v):
    if isinstance(v, dict):
        if not v:
            return '{}'
        return '{ ' + ', '.join('%s: %s' % (dumps(k), inline(x)) for k, x in v.items()) + ' }'
    return dumps(v)


def pretty(v, ind, multi_rows=False):
    pad = '  ' * ind
    if isinstance(v, list):
        if not v:
            return '[]'
        return '[\n' + ',\n'.join(pad + '  ' + pretty(x, ind + 1, multi_rows) for x in v) + '\n' + pad + ']'
    if isinstance(v, dict):
        if is_flat(v) and not multi_rows:
            return inline(v)
        inner = []
        for k, x in v.items():
            if isinstance(x, dict) and is_flat(x):
                body = inline(x)
            else:
                body = pretty(x, ind + 1)
            inner.append(pad + '  ' + dumps(k) + ': ' + body)
        return '{\n' + ',\n'.join(inner) + '\n' + pad + '}'
    return dumps(v)


def ser_envelope(env, multi_rows):
    out = []
    for k, v in env.items():
        if k == 'meta':
            body = '{\n' + ',\n'.join('    %s: %s' % (dumps(a), dumps(b)) for a, b in v.items()) + '\n  }'
        elif k == 'rows':
            body = '[]' if not v else '[\n' + ',\n'.join('    ' + pretty(x, 2, multi_rows) for x in v) + '\n  ]'
        elif isinstance(v, dict):
            body = inline(v)
        else:
            body = dumps(v)
        out.append('  ' + dumps(k) + ': ' + body)
    return '{\n' + ',\n'.join(out) + '\n}\n'


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
    assert pos == len(raw)


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def check_base_fresh():
    try:
        mb = git('merge-base', 'HEAD', 'origin/main').strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다' % (mb[:8], BASE[:8]))


def keys(v):
    if isinstance(v, dict):
        for k, x in v.items():
            yield k
            yield from keys(x)
    elif isinstance(v, list):
        for x in v:
            yield from keys(x)


def main():
    check_base_fresh()
    codes = check_engine_codes()
    card, sections, path = engine_vm()
    assert [r['code'] for s in sections for r in s['rows']] == codes, '행 차례 ≠ 엔진 사전 차례'
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels))

    vm = dict(zip(VM_KEYS, [card, sections, path, copy.deepcopy(AS_OF)]))
    stale_as_of = dict(AS_OF_OLD, stale_label=STALE_LABEL)
    vm_stale = dict(zip(VM_KEYS, [copy.deepcopy(card), copy.deepcopy(sections), list(path), stale_as_of]))

    def env(row, env_as_of):
        return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
                'empty_label': None, 'has_more': False, 'rows': [copy.deepcopy(row)]}

    out = {ED: ser_envelope(env(vm, AS_OF), True), ED_STALE: ser_envelope(env(vm_stale, AS_OF_OLD), True)}
    for rel in rels:
        out[rel] = bump(_BASE_CACHE[rel], rel)

    # ── 자가 검사 ──
    assert len(out) == WANT_FILES
    for rel in NEW_FILES:
        s = out[rel]
        assert '\r' not in s and s.endswith('}\n')
        e = json.loads(s)
        assert list(e) == ENVELOPE_KEYS and e['meta'] == NEW_META
        v = e['rows'][0]
        assert list(v) == VM_KEYS and list(v['current']) == CARD_KEYS
        assert all(list(sec) == SEC_KEYS and all(list(r) == ROW_KEYS for r in sec['rows']) for sec in v['sections'])
        assert not (set(keys(e['rows'])) & FORBIDDEN_KEYS), rel
        assert all(x for x in v['current'].values())
    assert json.loads(out[ED])['rows'][0] == vm and json.loads(out[ED_STALE])['rows'][0] == vm_stale
    n_version_only = sum(1 for rel in rels if out[rel] == bump(_BASE_CACHE[rel], rel))
    assert n_version_only == BASE_FILES

    for rel, text in sorted(out.items()):
        p = FX + '/' + rel
        os.makedirs(os.path.dirname(p), exist_ok=True)
        io.open(p, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert on_disk == WANT_FILES, on_disk
    print('gen_s04_v128_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.28.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
