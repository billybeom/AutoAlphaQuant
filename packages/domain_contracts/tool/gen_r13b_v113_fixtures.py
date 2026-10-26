#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.13(R13b 선행 2 M2 보강 · 01 §23) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r13b_v113_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r5r13_v112_fixtures.py(계약 v1.12 · 그 스크립트는 v1.12 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계 메모 `10_리뷰/2026-10-26_R13b선행_M2보강_설계메모.md` §5 · 174 → 176 = 신설 2 · 개정 1 · 버전 줄만 173)
  (a) 전 봉투의 "contract_version": "1.12.0" → "1.13.0" 한 줄 치환(다른 글자 불변 · 174건).
  (b) 개정 1 — m8/recon_board_diff 칸 5 줄 끝에 `"level"`(K6 — 같은 쌍의 ledger_diffs_4 `severity` 대응:
      CANON_BROKER MISMATCH = BLOCKED(ld_0001 BLOCKING «주문 차단») · CANON_SUPABASE LAG = WATCH(ld_0002 OBSERVATIONAL) ·
      CANON_GITHUB·CANON_CALENDAR OK = OK · CANON_SELF_REPORT(applicable false) = INFO). 라벨·코드·headline 불변.
  (c) 신설 2 —
      · m8/recon_board_ok(K5) = 개정된 recon_board_diff 원문 꼴 그대로에서 칸 줄·headline 줄만 바꾼다
        (드라이런 흉내 1dcbea3 의 글자 + 칸 `level` · 점검 4칸 OK «일치» OK · 자가보고 NOT_APPLICABLE «해당 없음» INFO ·
        headline «점검한 네 칸이 모두 일치합니다.»).
      · m8/ops_home_advice_suppressed_due(K7 ⓑ · K8) = m8/ops_home_advice_zero 원문에서 요약 6곳만 바꾼다
        (open_count 1 · due_today_count 1 · headline = 억제 갈래의 한 줄 전부 · level ACT · due_soon_label 신설(level 다음) ·
        has_suppressed_notice true 그대로) — 행·trust·as_of·batch_id 불변.
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 발주자 확정(2026-10-26 · R13b 발주자 확인 ①·⑭ · 설계 메모 🔴 K1·K2·K7 권고대로 · 나머지 기술 권고 권고대로).
  - K3 — 엔진 의무: applicable false ⇒ level INFO · BLOCKED 는 CANON_BROKER·CANON_SELF_REPORT 만(파생 3쌍 0).
  - K4 — headline 은 늘 엔진 문장(빈 글자 0 · 전부 일치 날 = 일치를 말하는 문장).
  - K7 ⓐ — 배분 notice_text null 표본 = 기존 m6/allocation_empty 재사용(신설 0 · 버전 줄만).
  🔵 meta 는 이웃 표본 값 그대로(generated_at 2026-09-06 · seed 20260906 — C-1 이 notice 를 01 §5 문장 하나로 고정한다).

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r13b_v113_fixtures.py
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
# 계약 1.12.0 · 픽스처 174 의 기준 커밋(origin/main · 엔진 PR #70 E8b2 — 계약 패키지 = v1.12 PR #68 fb67caf 와 같다).
BASE = 'fc25f77e2d9525686e2a713e11060c3818e5532c'

OLD_VER = '"contract_version": "1.12.0"'
NEW_VER = '"contract_version": "1.13.0"'
BASE_FILES = 174
WANT_FILES = 176

# fixture_conventions_test.dart `_retiredContributionValues` 와 같은 정규식(폐기 운영값).
RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'화면이|화면은|화면·')              # 사용자 문장 자리의 개발자 메모(H50)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6 — 홈 표본에 손익 키 0
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']

# ── 이름 ─────────────────────────────────────────────────────────────────
DIFF = 'm8/recon_board_diff.json'
N_OK = 'm8/recon_board_ok.json'
ZERO = 'm8/ops_home_advice_zero.json'
N_SDUE = 'm8/ops_home_advice_suppressed_due.json'
RHYTHM_ROWS = 'm8/ops_rhythm_rows.json'
LEDGER_DIFFS4 = 'ledger_diffs_4.json'
ALLOC_EMPTY = 'm6/allocation_empty.json'
NEW_FILES = [N_OK, N_SDUE]
REVISED = [DIFF]

PAIRS = ['CANON_BROKER', 'CANON_SUPABASE', 'CANON_GITHUB', 'CANON_CALENDAR', 'CANON_SELF_REPORT']
DERIVED = {'CANON_SUPABASE', 'CANON_GITHUB', 'CANON_CALENDAR'}
UI_LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}

# K6 — 대조 보드 칸 레벨(칸 순서 = PAIRS · ledger_diffs_4 같은 쌍 severity 대응).
DIFF_LEVELS = ['BLOCKED', 'WATCH', 'OK', 'OK', 'INFO']
# K5 — 전부 일치(점검 4칸 OK «일치» · 자가보고 해당 없음).
OK_STATES = [
    (True, 'OK', '일치', 'OK'),
    (True, 'OK', '일치', 'OK'),
    (True, 'OK', '일치', 'OK'),
    (True, 'OK', '일치', 'OK'),
    (False, 'NOT_APPLICABLE', '해당 없음', 'INFO'),
]
OK_HEADLINE = '점검한 네 칸이 모두 일치합니다.'
# K7 ⓑ · K8 — 억제 + 기한 라벨(억제 갈래 = headline 한 줄 전부 · dueSoonLabel 은 A-1 머리 몫).
SDUE_HEADLINE = '오늘은 새 매매 안내를 내지 않았습니다. 처리 중인 안내 1건이 오늘까지입니다.'
SDUE_DUE_SOON = '1건이 오늘까지입니다'


# ────────────────────────────────────────────────────────────────────────
# 파일 입출력
# ────────────────────────────────────────────────────────────────────────
def git(*args):
    return subprocess.check_output(['git', '-C', ROOT] + list(args)).decode('utf-8')


_BASE_CACHE = {}


def preload(rels):
    """기준 원문을 `git cat-file --batch` 한 번으로 읽는다(파일마다 `git show` 를 띄우면 Windows 에서 느리다)."""
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


def base_text(rel):
    if rel not in _BASE_CACHE:
        s = git('show', '%s:%s/%s' % (BASE, FX_REL, rel))
        assert '\r' not in s, rel
        _BASE_CACHE[rel] = s
    return _BASE_CACHE[rel]


def base_env(rel):
    return json.loads(base_text(rel))


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def replace_once(s, rel, old, new):
    assert s.count(old) == 1, (rel, old, s.count(old))
    return s.replace(old, new, 1)


def dumps(v):
    return json.dumps(v, ensure_ascii=False)


def cell_line(pair, label, applicable, state_code, state_label, level=None):
    """대조 보드 칸 한 줄(원문 꼴 — 8칸 들여쓰기 · 평평한 객체 한 줄)."""
    items = [('pair', pair), ('label', label), ('applicable', applicable), ('state_code', state_code),
             ('state_label', state_label)]
    if level is not None:
        items.append(('level', level))
    return '        { ' + ', '.join('%s: %s' % (dumps(k), dumps(v)) for k, v in items) + ' }'


# ────────────────────────────────────────────────────────────────────────
# 개정 · 신설
# ────────────────────────────────────────────────────────────────────────
def base_cells():
    cells = base_env(DIFF)['rows'][0]['cells']
    assert [c['pair'] for c in cells] == PAIRS, cells
    assert all(set(c) == {'pair', 'label', 'applicable', 'state_code', 'state_label'} for c in cells), cells
    return cells


def revise_diff():
    s = bump(base_text(DIFF), DIFF)
    for c, level in zip(base_cells(), DIFF_LEVELS):
        old = cell_line(c['pair'], c['label'], c['applicable'], c['state_code'], c['state_label'])
        new = cell_line(c['pair'], c['label'], c['applicable'], c['state_code'], c['state_label'], level)
        s = replace_once(s, DIFF, old + (',\n' if c['pair'] != PAIRS[-1] else '\n'),
                         new + (',\n' if c['pair'] != PAIRS[-1] else '\n'))
    return s


def recon_ok(diff_revised):
    s = diff_revised
    for c, level, (applicable, code, label, ok_level) in zip(base_cells(), DIFF_LEVELS, OK_STATES):
        old = cell_line(c['pair'], c['label'], c['applicable'], c['state_code'], c['state_label'], level)
        new = cell_line(c['pair'], c['label'], applicable, code, label, ok_level)
        s = replace_once(s, N_OK, old, new)
    old_headline = base_env(DIFF)['rows'][0]['headline']
    s = replace_once(s, N_OK, '      "headline": %s,\n' % dumps(old_headline),
                     '      "headline": %s,\n' % dumps(OK_HEADLINE))
    return s


def suppressed_due():
    s = bump(base_text(ZERO), ZERO)
    summary = base_env(ZERO)['advice_summary']
    assert summary['has_suppressed_notice'] is True and summary['open_count'] == 0, summary
    assert summary['due_today_count'] == 0 and summary['level'] == 'INFO' and 'due_soon_label' not in summary
    s = replace_once(s, N_SDUE, '    "open_count": 0,\n', '    "open_count": 1,\n')
    s = replace_once(s, N_SDUE, '    "due_today_count": 0,\n', '    "due_today_count": 1,\n')
    s = replace_once(s, N_SDUE, '    "headline": %s,\n' % dumps(summary['headline']),
                     '    "headline": %s,\n' % dumps(SDUE_HEADLINE))
    s = replace_once(s, N_SDUE, '    "level": "INFO",\n',
                     '    "level": "ACT",\n    "due_soon_label": %s,\n' % dumps(SDUE_DUE_SOON))
    return s


# ────────────────────────────────────────────────────────────────────────
# 자가 검사
# ────────────────────────────────────────────────────────────────────────
def strings(v, path='$'):
    if isinstance(v, dict):
        for k, x in v.items():
            yield from strings(x, '%s.%s' % (path, k))
    elif isinstance(v, list):
        for i, x in enumerate(v):
            yield from strings(x, '%s[%d]' % (path, i))
    elif isinstance(v, str):
        yield path, v


def keys(v):
    if isinstance(v, dict):
        for k, x in v.items():
            yield k
            yield from keys(x)
    elif isinstance(v, list):
        for x in v:
            yield from keys(x)


def self_check_file(rel, s, new):
    assert '\r' not in s, rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE', rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    assert list(env.keys())[:6] == ENVELOPE_KEYS, (rel, list(env.keys()))
    if rel in NEW_FILES or rel in REVISED:
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
            if new:
                assert not DEV_MEMO.search(v), '%s %s — 사용자 문장 자리의 개발자 메모: %s' % (rel, path, v)
        assert not any(PNL_KEY.search(k) for k in keys(env)), rel
    return env


def check_board(env, rel):
    rows = env['rows']
    assert len(rows) == 1, rel
    cells = rows[0]['cells']
    assert len(cells) == 5 and [c['pair'] for c in cells] == PAIRS, rel
    for c in cells:
        assert set(c) == {'pair', 'label', 'applicable', 'state_code', 'state_label', 'level'}, (rel, c)
        assert c['level'] in UI_LEVELS, (rel, c)
        if not c['applicable']:
            assert c['level'] == 'INFO', (rel, c)                         # K3 ⓐ
        if c['level'] == 'BLOCKED':
            assert c['pair'] not in DERIVED, (rel, c)                      # K3 ⓑ
        assert c['state_label'].strip(), (rel, c)
    assert rows[0]['headline'].strip(), rel                               # K4
    return cells


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels) and ZERO in rels and ALLOC_EMPTY in rels

    out = {}
    out[DIFF] = revise_diff()
    out[N_OK] = recon_ok(out[DIFF])
    out[N_SDUE] = suppressed_due()
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, new=rel in NEW_FILES) for rel, s in out.items()}
    # 대조 보드 — 칸 5 · 쌍 5값 · 해당 없음 = INFO · 파생 BLOCKED 0 · headline 늘(K3·K4).
    diff_cells = check_board(envs[DIFF], DIFF)
    ok_cells = check_board(envs[N_OK], N_OK)
    assert [c['level'] for c in diff_cells] == DIFF_LEVELS
    assert all(c['level'] == 'OK' for c in ok_cells if c['applicable'])  # 전부 일치
    assert any(not c['applicable'] for c in ok_cells)
    assert any(c['applicable'] and c['level'] != 'OK' for c in diff_cells)
    assert {c['pair']: c['label'] for c in ok_cells} == {c['pair']: c['label'] for c in diff_cells}  # 쌍 글자 한 벌
    assert envs[N_OK]['rows'][0]['headline'] != envs[DIFF]['rows'][0]['headline']
    assert envs[N_OK]['as_of'] == envs[DIFF]['as_of'] and envs[N_OK]['rows'][0]['as_of'] == envs[DIFF]['rows'][0]['as_of']
    # 개정은 level 만 — 칸에서 level 을 빼면 기준 원문과 같다 · 다른 키 불변.
    stripped = json.loads(out[DIFF])
    for c in stripped['rows'][0]['cells']:
        del c['level']
    stripped['meta']['contract_version'] = '1.12.0'
    assert stripped == base_env(DIFF)
    # K6 — 같은 쌍의 차이 행 severity 와 대응(BLOCKING ⇒ BLOCKED · OBSERVATIONAL ⇒ WATCH).
    sev = {}
    for r in envs[LEDGER_DIFFS4]['rows']:
        sev.setdefault(r['pair'], r['severity'])
    assert sev.get('CANON_BROKER') == 'BLOCKING' and sev.get('CANON_SUPABASE') == 'OBSERVATIONAL', sev
    # 억제 + 기한 — has_suppressed_notice ∧ due_soon_label ∧ open_count ≠ 0 · 행 = zero 행 그대로.
    sd = envs[N_SDUE]
    s = sd['advice_summary']
    assert s['has_suppressed_notice'] is True and s['due_soon_label'] and s['open_count'] != 0, s
    assert s['level'] == 'ACT' and s['headline'] != s['due_soon_label'] and s['headline'].strip()
    assert list(s.keys()) == [k for k in base_env('m8/ops_home_advice_open.json')['advice_summary'].keys()], list(s)
    zero = envs[ZERO]
    assert sd['rows'] == zero['rows'] and sd['as_of'] == zero['as_of']
    assert {k: v for k, v in s.items() if k not in ('open_count', 'due_today_count', 'headline', 'level',
                                                     'due_soon_label')} == \
        {k: v for k, v in zero['advice_summary'].items() if k not in ('open_count', 'due_today_count', 'headline',
                                                                      'level')}
    up = sd['rows'][0]['upcoming']
    assert up == envs[RHYTHM_ROWS]['rows'][:len(up)] and len(up) <= 3      # C-47 ⑤
    # 재사용 — allocation_empty = 행 0 · notice_text 없음 · empty_label 있음(K7 ⓐ · 버전 줄만).
    ae = envs[ALLOC_EMPTY]
    assert len(ae['rows']) == 1, ALLOC_EMPTY
    av = ae['rows'][0]
    assert av['rows'] == [] and av['empty_label'] and 'notice_text' not in av, av
    assert out[ALLOC_EMPTY] == bump(base_text(ALLOC_EMPTY), ALLOC_EMPTY)

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    n_revised = sum(1 for rel in rels if out[rel] != bump(base_text(rel), rel))
    assert (n_version_only, n_revised) == (173, 1), (n_version_only, n_revised)

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r13b_v113_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · contract 1.13.0'
          % (len(out), BASE_FILES, n_version_only, n_revised, len(NEW_FILES)))


if __name__ == '__main__':
    main()
