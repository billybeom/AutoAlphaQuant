#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.32(E16j-a 계약 창 — X5 정정 마법사 · 01 §41) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_e16j_a_v132_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
관례는 gen_e11k_d2_v131_fixtures.py · gen_trackb_v125_fixtures.py 를 본떴다(그 스크립트들은 그 판 재현용으로 그대로 둔다).

하는 일(설계서 `10_리뷰/2026-11-21_E16j-a계약창_계약v1.32_설계서.md` §5 · 367 → 375 = 신설 8 · 개정 0 · 버전 줄만 367)
  (a) 전 봉투의 "contract_version": "1.31.0" → "1.32.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 8 — 🆕 폴더 `x5/`(x2/ 선례):
      VM 7(`RepairWizardVm` · 1행 봉투) = 허브 둘(대상 2 · 빈) · diff 갈래 셋(기본 = 아무것도 안 하기 · 3단계 저널 · 실행 준비) ·
      무결성 갈래 1(새 기준점 준비) · 경계 X1 1(정정이 아니라 복구) / 결과 1(`SafetyActionResult` 목록).
  (c) 글자 = «(합성)» 표기 평문(엔진 VM 생산 = 01 §8 미결 217 전 — 원천 0) · diff 행 = 코어 `ledger_diffs_4.json` 첫 행 그대로 + `action_link` null ·
      금액 · 가격 · 계좌 · 시크릿 0 · 수치(냉각 · 체인 상한) = 엔진 글자 꼴만.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_e16j_a_v132_fixtures.py
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
# 계약 1.31.0 · 픽스처 367 의 기준 커밋(origin/main · v1.31 병합 PR #298 squash 922df462 + 병합 기록 06621fa1).
BASE = '06621fa1'
BASE_FRESH_REF = 'origin/main'

OLD_VER = '"contract_version": "1.31.0"'
NEW_VER = '"contract_version": "1.32.0"'
BASE_FILES = 367
WANT_FILES = 375

SRC_DIFFS = 'ledger_diffs_4.json'
SRC_RESULTS = 'm5/recon_clear_results.json'

META = {
    'fixture_version': '0.1.0-draft', 'contract_version': '1.32.0', 'generated_at': '2026-11-21T09:00:00Z',
    'mode': 'LIVE', 'config_hash': 'cfg_fake_0000000000000000', 'seed': 20261121,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}
AS_OF = {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
         'stale_after_seconds': 93600, 'label': '정정 기준 2026-08-31 18:00'}

HUB = 'aaq://x5/repair-wizard'
TARGET = 'aaq://x5/repair-wizard/'
HISTORY = {'label': '(합성) 정정 이력 보기', 'deep_link': 'aaq://ledger/repairs'}
X1_GUIDE = {'label': '(합성) 새 폰 복구 안내 보기', 'deep_link': 'aaq://x1/migration/emergency'}
NOTICE = '(합성) 정정은 되돌리지 않습니다 — 잘못 고치면 정정의 정정만 남습니다.'


def stage(n, title, state, level, lines, actions=(), journal=False):
    return {'title': title, 'state_label': state, 'level': level, 'lines': list(lines),
            'actions': list(actions), 'journal_form': journal}


def step_call(n, outcome='PASSED', label='(합성) 확인했습니다'):
    return {'id': 'INTERVENTION_STEP', 'args': {'session_id': 'iv_0001', 'stage': str(n), 'outcome': outcome}, 'label': label}


TITLES = ['(합성) 1 규칙 대비', '(합성) 2 카드 · 서약 다시 읽기', '(합성) 3 사전 저널', '(합성) 4 냉각', '(합성) 5 실행 창']


def stages_at(k):
    """k = 지금 차례 단계(1~5) · 6 = 전부 통과."""
    out = []
    for n in range(1, 6):
        if n < k:
            out.append(stage(n, TITLES[n - 1], '(합성) 통과', 'OK', []))
        elif n == k:
            if n == 3:
                out.append(stage(n, TITLES[n - 1], '(합성) 차례 — 저널 세 칸을 적으십시오', 'ACT',
                                 ['(합성) 무엇을 왜 고치는지 · 기대 결과 · 근거 규칙'], journal=True))
            elif n == 4:
                out.append(stage(n, TITLES[n - 1], '(합성) 냉각 중', 'WATCH', ['(합성) 08-30 18:00 부터 실행할 수 있습니다']))
            else:
                lines = {1: ['(합성) 규칙 대비 — 이 정정은 체결 기록을 바꿉니다'],
                         2: ['(합성) 서약 첫 문장 · 둘째 문장 · 셋째 문장을 다시 읽습니다'],
                         5: ['(합성) 실행 창이 열렸습니다']}[n]
                out.append(stage(n, TITLES[n - 1], '(합성) 차례', 'ACT', lines, actions=[step_call(n)]))
        else:
            out.append(stage(n, TITLES[n - 1], '(합성) 대기', 'INFO', []))
    if k == 6:
        out[4]['lines'] = ['(합성) 실행 창 — 08-31 23:59 까지']
    return out


def vm(**kw):
    base = {'headline': '', 'level': 'INFO', 'reason_code': None, 'target_links': [], 'diff': None, 'target_lines': [],
            'do_nothing_default': False, 'origins': [], 'stages': [], 'do_nothing_action': None, 'correction': None,
            'baseline_label': None, 'notice_text': None, 'done_label': None, 'history_link': None, 'x1_guide_link': None,
            'locked_label': None, 'as_of': AS_OF}
    base.update(kw)
    return base


DIFF_ORIGINS = [{'origin_code': 'MISRECORDED_FILL', 'label': '(합성) 잘못 기록된 체결'},
                {'origin_code': 'MANUAL_ORDER', 'label': '(합성) 앱 밖 수동 주문'},
                {'origin_code': 'BROKER_ERROR', 'label': '(합성) 증권사 오류'}]
BASELINE_ORIGINS = [{'origin_code': 'CHAIN_BROKEN', 'label': '(합성) 스탬프 사슬 끊김'},
                    {'origin_code': 'DB_ERROR', 'label': '(합성) 저장 오류'}]
DO_NOTHING = {'id': 'REPAIR_ACCEPT', 'args': {'diff_id': 'ld_0001'}, 'label': '(합성) 아무것도 안 하기'}


def build(diff_row):
    d = copy.deepcopy(diff_row)
    d['action_link'] = None
    diff_lines = ['(합성) 08-28 체결 1건 — 증권사 9주 · 장부 10주']
    return {
        'x5/repair_hub_targets.json': vm(
            headline='(합성) 정정할 대상 2건 — 하나를 고르십시오', level='ACT',
            target_links=[{'label': '(합성) 체결 차이 — 08-28 탐지', 'deep_link': TARGET + 'ld_0001'},
                          {'label': '(합성) 장부 무결성 — 첫 어긋난 날 08-27', 'deep_link': TARGET + 'li_0001'}],
            history_link=HISTORY),
        'x5/repair_hub_empty.json': vm(
            headline='(합성) 정정할 대상이 없습니다', level='OK', done_label='(합성) 열린 차이와 무결성 표시가 없습니다',
            history_link=HISTORY),
        'x5/repair_diff_default.json': vm(
            headline='(합성) 체결 보고가 늦은 것으로 보입니다 — 기본은 아무것도 안 하기입니다', level='WATCH',
            diff=d, target_lines=diff_lines, do_nothing_default=True, origins=DIFF_ORIGINS, stages=stages_at(1),
            do_nothing_action=DO_NOTHING, notice_text=NOTICE, history_link=HISTORY),
        'x5/repair_diff_stage3.json': vm(
            headline='(합성) 정정 마찰 3단계 — 사전 저널', level='ACT',
            diff=d, target_lines=diff_lines, origins=DIFF_ORIGINS, stages=stages_at(3),
            do_nothing_action=DO_NOTHING, notice_text=NOTICE, history_link=HISTORY),
        'x5/repair_diff_ready.json': vm(
            headline='(합성) 정정을 실행할 수 있습니다', level='ACT',
            diff=d, target_lines=diff_lines, origins=DIFF_ORIGINS, stages=stages_at(6),
            do_nothing_action=DO_NOTHING,
            correction={'fills': [{'fill_ref': 'ex_0001', 'label': '(합성) 08-28 매수 체결 1건 · 10주'}],
                        'amend_allowed': True, 'notice_text': '(합성) 무효로 하거나 수량 · 가격을 다시 적습니다'},
            notice_text=NOTICE, history_link=HISTORY),
        'x5/repair_integrity_ready.json': vm(
            headline='(합성) 지난 기록이 스탬프와 다릅니다 — 새 기준점을 만들 수 있습니다', level='ACT',
            reason_code='CONTENT_MISMATCH', target_lines=['(합성) 첫 어긋난 날 08-27'], origins=BASELINE_ORIGINS,
            stages=stages_at(6), baseline_label='(합성) 새 기준점 만들기', notice_text=NOTICE, history_link=HISTORY),
        'x5/repair_boundary_x1.json': vm(
            headline='(합성) 원장 파일을 믿을 수 없습니다 — 정정이 아니라 새 폰 복구가 필요합니다', level='BLOCKED',
            reason_code='DB_OPEN_FAILED', x1_guide_link=X1_GUIDE, history_link=HISTORY),
    }


RESULTS = [
    ('ar_rpr_01', 'REPAIR_ACCEPT', 'OK', '(합성) 받아들였습니다 — 차이를 그대로 둡니다', None, False),
    ('ar_rpr_02', 'REPAIR_CORRECT', 'OK', '(합성) 정정을 기록했습니다 — 포지션을 다시 셌습니다', None, False),
    ('ar_rpr_03', 'REPAIR_CORRECT', 'BLOCKED', '(합성) 방금 다시 대사한 결과가 달라졌습니다 — 처음부터 다시 보십시오', 'REPAIR_DELTA_CHANGED', False),
    ('ar_rpr_04', 'REPAIR_CORRECT', 'BLOCKED', '(합성) 종목이나 매수 · 매도는 바꿀 수 없습니다', 'AMEND_SYMBOL_OR_SIDE_CHANGE', False),
    ('ar_rpr_05', 'REPAIR_CORRECT', 'WATCH', '(합성) 냉각이 끝나지 않았습니다', 'INTERVENTION_COOLING', False),
    ('ar_rpr_06', 'REPAIR_BASELINE', 'OK', '(합성) 새 기준점을 만들었습니다 — 무결성 표시를 풀었습니다', None, False),
    ('ar_rpr_07', 'REPAIR_BASELINE', 'BLOCKED', '(합성) 무결성 표시가 서 있지 않습니다', 'BASELINE_FLAG_NOT_SET', False),
    ('ar_rpr_08', 'REPAIR_BASELINE', 'BLOCKED', '(합성) 처음 어긋난 날을 알 수 없습니다', 'BASELINE_FIRST_BAD_DATE_UNKNOWN', False),
    ('ar_rpr_09', 'INTERVENTION_JOURNAL', 'OK', '(합성) 사전 저널을 남겼습니다', None, False),
    ('ar_rpr_10', 'INTERVENTION_JOURNAL', 'BLOCKED', '(합성) 지금은 저널 단계가 아닙니다', 'INTERVENTION_STAGE_OUT_OF_ORDER', False),
    ('ar_rpr_11', 'REPAIR_CORRECT', 'BLOCKED', '(합성) 생체 확인을 쓸 수 없습니다', 'BIOMETRIC_UNAVAILABLE', False),
]


def git(*args):
    return subprocess.check_output(['git', '-C', ROOT] + list(args)).decode('utf-8')


_BASE_CACHE = {}


def preload(rels):
    req = ''.join('%s:%s/%s\n' % (BASE, FX_REL, rel) for rel in rels).encode('utf-8')
    raw = subprocess.run(['git', '-C', ROOT, 'cat-file', '--batch'], input=req, stdout=subprocess.PIPE, check=True).stdout
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
        mb = git('merge-base', 'HEAD', BASE_FRESH_REF).strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다' % (mb[:8], BASE[:8]))


def inline(v):
    """한 줄 꼴(`{ "k": v }` · 빈 `{}` 그대로) — 기존 표본과 같은 줄 꼴."""
    t = json.dumps(v, ensure_ascii=False, separators=(', ', ': '))
    t = re.sub(r'\{(?!\})', '{ ', t)
    return re.sub(r'(?<!\{)\}', ' }', t)


def envelope(rows_text):
    head = ('{\n  "meta": {\n' + ',\n'.join('    "%s": %s' % (k, json.dumps(v, ensure_ascii=False)) for k, v in META.items())
            + '\n  },\n  "as_of": ' + inline(AS_OF) + ',\n  "empty_kind": "NO_DATA",\n  "empty_label": null,\n  "has_more": false,\n')
    return head + '  "rows": [\n' + rows_text + '\n  ]\n}\n'


def vm_text(v):
    keys = list(v.keys())
    lines = ['    {']
    for i, k in enumerate(keys):
        comma = ',' if i < len(keys) - 1 else ''
        lines.append('      "%s": %s%s' % (k, inline(v[k]), comma))
    lines.append('    }')
    return envelope('\n'.join(lines))


def results_text():
    rows = []
    for rid, aid, level, headline, code, retry in RESULTS:
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
    return envelope(',\n'.join(rows))


def main():
    check_base_fresh()
    rels = base_files()
    preload(rels)
    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}
    diff_row = json.loads(_BASE_CACHE[SRC_DIFFS])['rows'][0]
    assert diff_row['diff_id'] == 'ld_0001' and diff_row['action_link']['deep_link'] == HUB
    new = {rel: vm_text(v) for rel, v in build(diff_row).items()}
    new['x5/repair_action_results.json'] = results_text()
    for rel, txt in new.items():
        assert rel not in rels, rel
        json.loads(txt)                                                      # 꼴 확인
        for bad in ('원', '계좌번호', 'sb_secret_', 'eyJ'):
            assert bad not in txt or bad == '원' and '원장' in txt or bad != '원', (rel, bad)
        out[rel] = txt
    assert len(out) == WANT_FILES, len(out)
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_e16j_a_v132_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.32.0'
          % (len(out), BASE_FILES, BASE_FILES, len(new)))


if __name__ == '__main__':
    main()
