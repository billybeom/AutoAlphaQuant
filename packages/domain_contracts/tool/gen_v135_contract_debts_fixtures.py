#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.35(쌓인 계약 숙제 창 — 01 §44 · K290~K302) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_v135_contract_debts_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_e16j_b_v133_fixtures.py · gen_e11k_214_v134_fixtures.py 를 본떴다(그 스크립트들은 그 판 재현용으로 그대로 둔다).

하는 일(01 §44 · 390 → 393 = 신설 3 · 개정 1 · 버전 줄만 389)
  (a) 전 봉투의 "contract_version": "1.34.0" → "1.35.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 1(K293 · 미결 217 ③) — `ledger_diffs_4.json` 승인 행 `ld_0001` 의 L-1 조치 링크 `deep_link`
      "aaq://x5/repair-wizard" → "aaq://x5/repair-wizard/ld_0001"(대상 라우트 · 엔진 #314 가 내는 글자 · 그 한 곳만).
  (c) 신설 3
      · `safety_states_holds.json`(K295 · 미결 219) — `SafetyState` 2행 = 기준 `safety_states.json` 첫 행(NORMAL) 복사 +
        `holds` · `hold_labels` 한 짝씩(`LIVE_AWAITING_KEYS` = S05 `m9/operations_live_hold_keys` 의 `hold_label` 글자 그대로 ·
        `MIGRATION_IN_PROGRESS` = 표본 문장) · 칸 차례 = freezed 차례(`mode` 뒤 · `as_of` 앞).
      · `m6/journal_draft_receipts_reject_2.json`(K298) — `CommandReceipt` 2행(`JOURNAL_DRAFT` · `REJECTED` ·
        `JOURNAL_TARGET_UNKNOWN` · `JOURNAL_INPUT_INVALID`) = 기준 `m6/journal_draft_receipts_5.json` 의 REJECTED 행 꼴.
      · `x5/repair_input_results.json`(K291 · 미결 217 ①) — `SafetyActionResult` 1행(`REPAIR_CORRECT` · `REPAIR_AMOUNT_INVALID`) =
        `x5/repair_action_results.json` 꼴.
  금액 · 계좌번호 · 기기 원문 · 시크릿 0 · 수치(체인 상한 · 최소 글자) 0.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_v135_contract_debts_fixtures.py
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
# 계약 1.34.0 · 픽스처 390 의 기준 커밋(origin/main · E11q-q5c2 병합 PR #315 squash b967e798 — 픽스처 JSON = v1.34 3dfe0dad 와 같음).
BASE = 'b967e798'

OLD_VER = '"contract_version": "1.34.0"'
NEW_VER = '"contract_version": "1.35.0"'
BASE_FILES = 390
WANT_FILES = 393

META = {
    'fixture_version': '0.1.0-draft', 'contract_version': '1.35.0', 'generated_at': '2026-11-21T09:00:00Z',
    'mode': 'LIVE', 'config_hash': 'cfg_fake_0000000000000000', 'seed': 20261121,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}

# ── (b) 개정 ──
DIFFS = 'ledger_diffs_4.json'
HUB_LINK = '"deep_link": "aaq://x5/repair-wizard" }'
TARGET_ROW = 'ld_0001'
TARGET_LINK = '"deep_link": "aaq://x5/repair-wizard/%s" }' % TARGET_ROW

# ── (c) 신설 ──
SAFETY_SRC = 'safety_states.json'
SAFETY_NEW = 'safety_states_holds.json'
HOLD_KEYS_SRC = 'm9/operations_live_hold_keys.json'
HOLDS = [
    ('LIVE_AWAITING_KEYS', None),   # 글자 = S05 표본 hold_label 그대로(엔진 문장 사전 한 벌 · K295)
    ('MIGRATION_IN_PROGRESS', '기기 이전 중입니다 — 새 주문을 멈췄습니다. 이전을 마치거나 그만두면 다시 돕니다.'),
]

RECEIPTS_SRC = 'm6/journal_draft_receipts_5.json'
RECEIPTS_NEW = 'm6/journal_draft_receipts_reject_2.json'
REJECTS = [
    ('cmd_20261121_0101', 'n_5b0d2e7c91a4', 'JOURNAL_TARGET_UNKNOWN',
     '거부됨 — 이 저널 대상을 찾을 수 없습니다. 입력값은 그대로 남아 있습니다'),
    ('cmd_20261121_0102', 'n_8e13f6a2d07b', 'JOURNAL_INPUT_INVALID',
     '거부됨 — 근거 · 기대 결과 · 인용 규칙 · 메모 조건을 다시 확인하십시오. 입력값은 그대로 남아 있습니다'),
]

REPAIR_SRC = 'x5/repair_action_results.json'
REPAIR_NEW = 'x5/repair_input_results.json'
REPAIR_ROWS = [
    ('ar_rpr_12', 'REPAIR_CORRECT', 'BLOCKED', '(합성) 수량 · 가격 · 수수료 · 세금 가운데 읽을 수 없는 칸이 있습니다',
     'REPAIR_AMOUNT_INVALID', False),
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


def envelope(as_of_line, rows_text):
    head = ('{\n  "meta": {\n' + ',\n'.join('    "%s": %s' % (k, json.dumps(v, ensure_ascii=False)) for k, v in META.items())
            + '\n  },\n  "as_of": ' + as_of_line + ',\n  "empty_kind": "NO_DATA",\n  "empty_label": null,\n  "has_more": false,\n')
    return head + '  "rows": [\n' + rows_text + '\n  ]\n}\n'


def row_text(v):
    keys = list(v.keys())
    lines = ['    {']
    for i, k in enumerate(keys):
        comma = ',' if i < len(keys) - 1 else ''
        lines.append('      "%s": %s%s' % (k, inline(v[k]), comma))
    lines.append('    }')
    return '\n'.join(lines)


def revise_diffs(s):
    assert s.count(HUB_LINK) == 1, DIFFS
    env = json.loads(s)
    linked = [r['diff_id'] for r in env['rows'] if r.get('action_link')]
    assert linked == [TARGET_ROW], linked                       # 조치 링크 = 승인 행 하나뿐
    out = s.replace(HUB_LINK, TARGET_LINK, 1)
    assert len(out) == len(s) + len('/' + TARGET_ROW)
    return out


def safety_holds_text():
    src = json.loads(_BASE_CACHE[SAFETY_SRC])
    base_row = src['rows'][0]
    assert base_row['breaker_level'] == 'NORMAL' and 'holds' not in base_row, base_row
    keys_label = json.loads(_BASE_CACHE[HOLD_KEYS_SRC])['rows'][0]['mode']['hold_label']
    assert keys_label, HOLD_KEYS_SRC
    rows = []
    for code, label in HOLDS:
        r = {}
        for k, v in base_row.items():
            if k == 'as_of':
                r['holds'] = [code]
                r['hold_labels'] = [keys_label if label is None else label]
            r[k] = v
        assert list(r.keys())[-3:] == ['holds', 'hold_labels', 'as_of'], list(r.keys())
        rows.append(row_text(r))
    as_of_line = inline(src['as_of'])
    return envelope(as_of_line, ',\n'.join(rows))


def receipts_text():
    src = json.loads(_BASE_CACHE[RECEIPTS_SRC])
    rej = [r for r in src['rows'] if r['state'] == 'REJECTED']
    assert len(rej) == 1, rej
    tpl = rej[0]
    rows = []
    for cmd, nonce, code, label in REJECTS:
        r = dict(tpl)
        r['command_id'] = cmd
        r['nonce'] = nonce
        r['state_label'] = label
        r['reject_reason_code'] = code
        assert list(r.keys()) == list(tpl.keys())
        rows.append('\n'.join(['    {'] + [
            '      "%s": %s%s' % (k, json.dumps(v, ensure_ascii=False), ',' if i < len(r) - 1 else '')
            for i, (k, v) in enumerate(r.items())] + ['    }']))
    # 기준 봉투의 as_of 를 한 줄 꼴로(기준 파일은 여러 줄 — 새 파일은 x5 · x1 신설 꼴을 따른다).
    return envelope(inline(src['as_of']), ',\n'.join(rows))


def repair_text():
    src = json.loads(_BASE_CACHE[REPAIR_SRC])
    rows = []
    for rid, aid, level, headline, code, retry in REPAIR_ROWS:
        assert rid not in {r['action_run_id'] for r in src['rows']}, rid
        rows.append('\n'.join([
            '    {',
            '      "action_run_id": %s,' % json.dumps(rid),
            '      "id": %s,' % json.dumps(aid),
            '      "level": %s,' % json.dumps(level),
            '      "headline": %s,' % json.dumps(headline, ensure_ascii=False),
            '      "reason_code": %s,' % ('null' if code is None else json.dumps(code)),
            '      "handoff_route": null,',
            '      "retryable": %s' % ('true' if retry else 'false'),
            '    }']))
    return envelope(inline(src['as_of']), ',\n'.join(rows))


def main():
    check_base_fresh()
    rels = base_files()
    preload(rels)
    for rel in (SAFETY_NEW, RECEIPTS_NEW, REPAIR_NEW):
        assert rel not in _BASE_CACHE, rel
    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}
    out[DIFFS] = revise_diffs(out[DIFFS])
    out[SAFETY_NEW] = safety_holds_text()
    out[RECEIPTS_NEW] = receipts_text()
    out[REPAIR_NEW] = repair_text()

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    revised = 0
    for rel in rels:
        a, b = _BASE_CACHE[rel], out[rel]
        if a.replace(OLD_VER, NEW_VER, 1) != b:
            assert rel == DIFFS, rel
            revised += 1
    assert revised == 1, revised
    for rel in (SAFETY_NEW, RECEIPTS_NEW, REPAIR_NEW):
        env = json.loads(out[rel])
        assert env['meta']['contract_version'] == '1.35.0', rel
        assert out[rel].count(NEW_VER) == 1, rel
    holds = json.loads(out[SAFETY_NEW])['rows']
    assert all(len(r['holds']) == len(r['hold_labels']) == 1 for r in holds)
    assert [r['holds'][0] for r in holds] == [c for c, _ in HOLDS]

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_v135_contract_debts_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 3) · contract 1.35.0'
          % (len(out), BASE_FILES, BASE_FILES - revised, revised))


if __name__ == '__main__':
    main()
