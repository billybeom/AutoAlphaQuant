#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.31(E11k-d2 계약 창 — o_07 ③ Supabase 로그인 · 01 §40) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_e11k_d2_v131_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
관례는 gen_e11k_v129_fixtures.py(v1.29)를 본떴다 — 그 스크립트는 그 판 재현용으로 그대로 둔다.

하는 일(설계서 `10_리뷰/2026-11-21_E11k-d2계약창_계약v1.31_설계서.md` §4 · 365 → 367 = 신설 2 · 개정 0 · 버전 줄만 365)
  (a) 전 봉투의 "contract_version": "1.30.0" → "1.31.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 2 — v1.16 표본(같은 봉투 · 같은 줄 꼴)을 틀로 쓴다:
      · `m8/onboarding_step_detail_supabase_login.json` — o_07 ③ 상세(② 통과 뒤 · `IN_PROGRESS` · 🔴 VERIFIED 아님 ·
        검증 = `SUPABASE_SIGN_IN{}` · 슬롯 = `SECRET_SUPABASE_LOGIN` — 같은 단계에서 ② 슬롯 대신 · K241).
      · `m8/onboarding_supabase_signin_results.json` — 결과 9행(`ActionResult`) = 접수 1 + 인증 4(`SupabaseAuthResultCodes` 가운데
        로그인에서 나오는 것) + 전송 4(`SupabaseTimeResultCodes` 망 넷 — 한 벌).
  (c) 글자 = 05/04 문서 평문 · 이메일 · 비밀번호 · 주소 · 키 · 토큰 값 0(종류만) · 숫자 0.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_e11k_d2_v131_fixtures.py
"""
import io
import json
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures')).replace(os.sep, '/')
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/')
FX_REL = os.path.relpath(FX, ROOT).replace(os.sep, '/')
# 계약 1.30.0 · 픽스처 365 의 기준 커밋(origin/main · v1.30 병합 기록 d2e75eb7).
BASE = 'd2e75eb7'

OLD_VER = '"contract_version": "1.30.0"'
NEW_VER = '"contract_version": "1.31.0"'
BASE_FILES = 365
WANT_FILES = 367

SRC_DETAIL = 'm8/onboarding_step_detail_kis_mock.json'
SRC_RESULTS = 'm8/onboarding_verify_results.json'
NEW_DETAIL = 'm8/onboarding_step_detail_supabase_login.json'
NEW_RESULTS = 'm8/onboarding_supabase_signin_results.json'

STEP = {
    'step_id': 'o_07', 'track': 'FRESH', 'order': 6, 'title': 'Supabase 연결',
    'why_line': '다른 기기가 읽을 기록을 올립니다.',  # = m8/onboarding_steps_fresh o_07 행
    'where_deep_link': None, 'estimated_seconds': 600, 'estimated_text': '약 10분', 'requirement': 'REQUIRED',
    'state': 'IN_PROGRESS', 'verification_label': '서버 시각 확인됨 — 로그인과 SQL 단계가 남았습니다',  # = v1.29 ② 통과 상태
    'verified_until': None, 'failure_reason_code': None, 'requirement_label': '필수', 'warning_label': None,
    'verified_until_text': None, 'failure_text': None,
    'gate': {'code': 'STEP_OPEN', 'label': '열렸습니다', 'state': 'PASS', 'blocked_reason_code': None},
    'detail_deep_link': 'aaq://onboarding/o_07',
}
WHERE = 'Supabase 프로젝트의 Authentication 화면에서 만든 계정의 이메일과 비밀번호를 비밀번호 관리자에서 복사합니다.'
HOW = '이메일과 비밀번호로 한 번 로그인합니다. 비밀번호는 저장하지 않고 로그인 상태만 이 기기에 둡니다. SQL 실행은 다음 단계에서 합니다.'
VERIFY = {'id': 'SUPABASE_SIGN_IN', 'args': {}, 'label': '로그인'}
SLOT = 'SECRET_SUPABASE_LOGIN'

# (행 id · 레벨 · 문장 · 코드 · 다시 시도)
RESULTS = [
    ('ar_supa_0201', 'OK', '로그인했습니다. SQL 단계가 남았습니다.', None, False),
    ('ar_supa_0202', 'BLOCKED', '이메일과 비밀번호를 모두 붙여 넣으십시오.', 'SUPABASE_AUTH_INPUT_INVALID', False),
    ('ar_supa_0203', 'BLOCKED', '이메일 또는 비밀번호가 맞지 않습니다. 비밀번호 관리자의 값을 다시 확인하십시오.', 'SUPABASE_CREDENTIALS_REJECTED', False),
    ('ar_supa_0204', 'WATCH', '시도가 너무 잦습니다. 잠시 뒤 다시 로그인하십시오.', 'SUPABASE_RATE_LIMITED', True),
    ('ar_supa_0205', 'BLOCKED', '로그인 상태를 이 기기에 저장하지 못했습니다. 다시 로그인하십시오.', 'SUPABASE_AUTH_VAULT_FAILED', False),
    ('ar_supa_0206', 'BLOCKED', '연결 키가 거절되었습니다. 연결 단계를 다시 확인하십시오.', 'SUPABASE_UNAUTHORIZED', False),
    ('ar_supa_0207', 'WATCH', '서버가 응답하지 못했습니다. 잠시 뒤 다시 로그인하십시오.', 'SUPABASE_SERVER_ERROR', True),
    ('ar_supa_0208', 'BLOCKED', '예상하지 못한 응답입니다. 잠시 뒤 다시 로그인하십시오.', 'SUPABASE_BAD_RESPONSE', False),
    ('ar_supa_0209', 'WATCH', '연결되지 않았습니다. 망을 확인한 뒤 다시 로그인하십시오.', 'SUPABASE_NETWORK', True),
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
    try:
        mb = git('merge-base', 'HEAD', 'origin/main').strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다(BASE 상수 갱신)'
                         % (mb[:8], BASE[:8]))


def inline(v):
    return json.dumps(v, ensure_ascii=False, separators=(', ', ': '))


def detail_text(src):
    """틀(kis_mock)의 줄 꼴 그대로 — rows 안 다섯 줄만 바꾼다."""
    lines = src.split('\n')
    out = []
    for ln in lines:
        s = ln.strip()
        ind = ln[:len(ln) - len(ln.lstrip())]
        if s.startswith('"step": '):
            out.append(ind + '"step": ' + inline(STEP).replace('{"', '{ "').replace('"}', '" }')
                       .replace('}, "', ' }, "').replace('null}', 'null }') + ',')
        elif s.startswith('"where_text": '):
            out.append(ind + '"where_text": ' + json.dumps(WHERE, ensure_ascii=False) + ',')
        elif s.startswith('"how_text": '):
            out.append(ind + '"how_text": ' + json.dumps(HOW, ensure_ascii=False) + ',')
        elif s.startswith('"verify": '):
            out.append(ind + '"verify": { "id": "SUPABASE_SIGN_IN", "args": {}, "label": "로그인" },')
        elif s.startswith('"secret_slot_id": '):
            out.append(ind + '"secret_slot_id": "%s"' % SLOT)
        else:
            out.append(ln)
    return '\n'.join(out)


def results_text(src):
    head = src[:src.index('  "rows": [')]
    rows = []
    for rid, level, headline, code, retry in RESULTS:
        rows.append('\n'.join([
            '    {',
            '      "action_run_id": %s,' % json.dumps(rid),
            '      "id": "SUPABASE_SIGN_IN",',
            '      "level": %s,' % json.dumps(level),
            '      "headline": %s,' % json.dumps(headline, ensure_ascii=False),
            '      "reason_code": %s,' % ('null' if code is None else json.dumps(code)),
            '      "handoff_route": null,',
            '      "retryable": %s' % ('true' if retry else 'false'),
            '    }',
        ]))
    return head + '  "rows": [\n' + ',\n'.join(rows) + '\n  ]\n}\n'


def self_check(detail, results):
    d = json.loads(detail)
    row = d['rows'][0]
    assert row['step'] == STEP and row['verify'] == VERIFY and row['secret_slot_id'] == SLOT
    assert row['missing_label'] is None
    r = json.loads(results)
    assert [x['reason_code'] for x in r['rows']] == [c for _i, _l, _h, c, _r in RESULTS]
    assert all(x['id'] == 'SUPABASE_SIGN_IN' for x in r['rows'])
    for txt in (detail, results):
        assert 'sb_secret_' not in txt and 'eyJ' not in txt and '.supabase.co' not in txt and '@' not in txt   # 키 · 주소 · 이메일 값 0


def main():
    check_base_fresh()
    rels = base_files()
    preload(rels)
    assert NEW_DETAIL not in rels and NEW_RESULTS not in rels, 'BASE 목록이 낡았다'
    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}
    out[NEW_DETAIL] = detail_text(out[SRC_DETAIL])
    out[NEW_RESULTS] = results_text(out[SRC_RESULTS])
    self_check(out[NEW_DETAIL], out[NEW_RESULTS])
    assert len(out) == WANT_FILES, len(out)
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_e11k_d2_v131_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 2) · contract 1.31.0'
          % (len(out), BASE_FILES, BASE_FILES))


if __name__ == '__main__':
    main()
