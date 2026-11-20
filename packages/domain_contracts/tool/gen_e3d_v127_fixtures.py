#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.27(E3d 계약 창 — 엔진 등재 대기 알림 5 등재 · 01 §36) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_e3d_v127_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_trackc_v126_fixtures.py(계약 v1.26 · 그 스크립트는 v1.26 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-20_E3d계약창_계약v1.27_설계서.md` §4 · 359 → 360 = 신설 1 · 개정 0 · 버전 줄만 359)
  (a) 전 봉투의 "contract_version": "1.26.0" → "1.27.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 1 — `m8/alerts_engine_proposals_v127.json`(알림 목록 봉투 · 5행 · `AlertCodes.safetyWarn` 4 + `derivedSync` 1).
      글자 = 엔진 `core_engine/lib/src/safety/alert_text.dart` 의 `kAlertTexts` 원문 그대로(제목 · 무슨 일 · 할 일 · 링크) ·
      등급 = 엔진 `kAlertLevels`(`alert_rules.dart`) · 차례 = 등급 순(P0 → P2) · 같은 등급 안 = 늦은 것부터(v1.18 선례).
  (c) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 엔진 글자 · 등급 · 링크가 BASE 소스에 실제로 있는지 본다.

🔴 돈·수치 0 새로 정함 — 엔진 사전이 수치를 싣지 않는다(SAF 문턱 · 금액 = 칸 0).
🔴 봉투 `as_of` = v1.18 `m8/alerts_safety_resume` 와 같은 글자(알림 목록 기준 2026-08-31) · `meta.mode` = `LIVE`(전 359 표본 선례).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_e3d_v127_fixtures.py
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
# 계약 1.26.0 · 픽스처 359 의 기준 커밋(origin/main · E3d-4 #272 — 픽스처 JSON = PR #270 이후 무변경).
BASE = 'c1a755b38c431cebcd2fce53228b672ebcfc3c3b'

OLD_VER = '"contract_version": "1.26.0"'
NEW_VER = '"contract_version": "1.27.0"'
BASE_FILES = 359
WANT_FILES = 360

NEW_REL = 'm8/alerts_engine_proposals_v127.json'
SRC_ALERTS = 'm8/alerts_safety_resume.json'   # 봉투 as_of · 행 키 차례 선례(v1.18)

ENGINE_TEXT = 'packages/core_engine/lib/src/safety/alert_text.dart'
ENGINE_RULES = 'packages/core_engine/lib/src/safety/alert_rules.dart'
APP_LINKS = 'packages/domain_contracts/lib/src/navigation/app_links.dart'
ALERT_CODES = 'packages/domain_contracts/lib/src/labels/alert_codes.dart'

# (행 id · 코드 · 엔진 상수 · 등급 · 낸 시각) — 등급 순 · 같은 등급 안 = 늦은 것부터.
#   일간 셋 = 평가 잡 20:30 KST(11:30Z) · 306 = 월 잡(월말 다음 세션 08:00 KST) · FORK = 아카이브 잡.
ROWS = [
    ('al_ep_01', 'DERIVED_FORK', 'kDerivedForkAlertCode', 'P0', '2026-08-31T02:00:00Z'),
    ('al_ep_02', 'DEFENSIVE_FLOOR_BREACHED', 'kDefensiveFloorAlertCode', 'P1', '2026-08-28T11:30:03Z'),
    ('al_ep_03', 'GOLD_SHARE_HIGH', 'kGoldShareAlertCode', 'P1', '2026-08-28T11:30:02Z'),
    ('al_ep_04', 'FINANCIAL_INCOME_CAP_EXCEEDED', 'kFinancialIncomeAlertCode', 'P1', '2026-08-02T23:00:00Z'),
    ('al_ep_05', 'KRW_LIQUIDITY_LOW', 'kKrwLiquidityAlertCode', 'P2', '2026-08-28T11:30:01Z'),
]
CONST_NAMES = {'DERIVED_FORK': 'derivedFork', 'DEFENSIVE_FLOOR_BREACHED': 'defensiveFloorBreached',
               'GOLD_SHARE_HIGH': 'goldShareHigh', 'FINANCIAL_INCOME_CAP_EXCEEDED': 'financialIncomeCapExceeded',
               'KRW_LIQUIDITY_LOW': 'krwLiquidityLow'}

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.27.0',
    'generated_at': '2026-11-20T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261120,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}
ROW_KEYS = ['alert_id', 'level', 'raised_at', 'code', 'title', 'body_text', 'action_line', 'grouped_count',
            'deep_link', 'ack', 'raised_at_text', 'grouped_text', 'detail_deep_link']
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']

FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
MONEY = re.compile(r'[0-9][0-9,]*(?:억|만)?[0-9,]*원')
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_trackc_v126 와 같은 꼴)
# ────────────────────────────────────────────────────────────────────────
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
            if not v:
                body = '[]'
            else:
                body = '[\n' + ',\n'.join('    ' + pretty(x, 2, multi_rows) for x in v) + '\n  ]'
        elif isinstance(v, dict):
            body = inline(v)
        else:
            body = dumps(v)
        out.append('  ' + dumps(k) + ': ' + body)
    return '{\n' + ',\n'.join(out) + '\n}\n'


# ────────────────────────────────────────────────────────────────────────
# 파일 입출력
# ────────────────────────────────────────────────────────────────────────
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


# ────────────────────────────────────────────────────────────────────────
# 엔진 글자 · 등급 · 링크(BASE 소스에서 읽고 확인)
# ────────────────────────────────────────────────────────────────────────
def routes():
    src = git('show', '%s:%s' % (BASE, APP_LINKS))
    return dict(re.findall(r"static const String (\w+) = '(aaq://[^']+)';", src))


def engine_texts():
    src = git('show', '%s:%s' % (BASE, ENGINE_TEXT))
    rts = routes()
    out = {}
    for _id, code, _const, _lv, _at in ROWS:
        m = re.search(r"  '%s': AlertText\(\n    '([^']*)',\n    '([^']*)',\n    '([^']*)',\n    AppRoutes\.(\w+),\n  \),"
                      % code, src)
        assert m, ('엔진 글자 없음', code)
        title, body, action, route = m.groups()
        assert route in rts, ('라우트 없음', code, route)
        out[code] = (title, body, action, rts[route])
    return out


def check_engine_levels():
    src = git('show', '%s:%s' % (BASE, ENGINE_RULES))
    for _id, _code, const, lv, _at in ROWS:
        line = '  %s: AlertLevel.%s,' % (const, lv.lower())
        assert line in src, ('엔진 등급 다름', const, lv)
    for _id, code, const, _lv, _at in ROWS:
        assert re.search(r"const String %s = '%s';" % (const, code),
                         git('show', '%s:packages/core_engine/lib/src/ops/%s' % (
                             BASE, 'derived_sync.dart' if code == 'DERIVED_FORK' else 'p0s_warn.dart'))), code


def check_contract_codes():
    """HEAD 의 계약 상수(이 판이 새로 넣은 것)와 같은 글자인지."""
    src = io.open(os.path.join(ROOT, ALERT_CODES), encoding='utf-8').read()
    for _id, code, _const, _lv, _at in ROWS:
        assert re.search(r"static const String %s =\s*'%s';" % (CONST_NAMES[code], code), src), code


def build(texts, src_env):
    rows = []
    for aid, code, _const, lv, at in ROWS:
        title, body, action, link = texts[code]
        rows.append({'alert_id': aid, 'level': lv, 'raised_at': at, 'code': code, 'title': title,
                     'body_text': body, 'action_line': action, 'grouped_count': 1, 'deep_link': link, 'ack': None,
                     'raised_at_text': None, 'grouped_text': None, 'detail_deep_link': None})
    env = {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(src_env['as_of']), 'empty_kind': 'NO_DATA',
           'empty_label': None, 'has_more': False, 'rows': rows}
    return env


def self_check(rel, s, env_src):
    assert '\r' not in s and s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert list(env.keys()) == ENVELOPE_KEYS, rel                                   # 형제 키 0(C-15 ⑥)
    assert env['meta'] == NEW_META, rel
    assert env['as_of'] == env_src['as_of'], rel
    order = {'P0': 0, 'P1': 1, 'P2': 2}
    lv = [order[r['level']] for r in env['rows']]
    assert lv == sorted(lv), rel                                                    # 등급 순
    for r in env['rows']:
        assert list(r.keys()) == ROW_KEYS == list(env_src['rows'][0].keys()), rel   # v1.18 행 키 차례
        for k in ('title', 'body_text', 'action_line'):
            v = r[k]
            for name, rx in (('금지어', FORBIDDEN), ('금액 글자', MONEY), ('계좌꼴', ACCOUNT_LIKE)):
                assert not rx.search(v), '%s %s %s — %s' % (rel, r['alert_id'], name, v)
            assert not v.startswith('aaq://'), (rel, v)
        assert r['deep_link'].startswith('aaq://'), rel
        assert not any(PNL_KEY.search(k) for k in r), rel
    return env


def main():
    check_base_fresh()
    check_engine_levels()
    check_contract_codes()
    texts = engine_texts()
    rels = base_files()
    preload(rels)
    assert NEW_REL not in rels, 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert SRC_ALERTS in rels
    src_env = json.loads(_BASE_CACHE[SRC_ALERTS])

    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}
    out[NEW_REL] = ser_envelope(build(texts, src_env), True)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    env = self_check(NEW_REL, out[NEW_REL], src_env)
    assert [r['code'] for r in env['rows']] == [c for _i, c, _k, _l, _a in ROWS]
    assert json.loads(ser_envelope(env, True)) == env                               # 직렬화 왕복
    n_version_only = sum(1 for rel in rels if out[rel] == bump(_BASE_CACHE[rel], rel))
    assert n_version_only == BASE_FILES, n_version_only

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_e3d_v127_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 1) · contract 1.27.0'
          % (len(out), BASE_FILES, n_version_only))


if __name__ == '__main__':
    main()
