#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.33(E16j-b 계약 창 — X1 기기 이전 화면 · 01 §42) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_e16j_b_v133_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
관례는 gen_e16j_a_v132_fixtures.py 를 본떴다(그 스크립트는 그 판 재현용으로 그대로 둔다).

하는 일(설계서 `10_리뷰/2026-11-21_E16j-b계약창_계약v1.33_설계서.md` §3 · 375 → 390 = 신설 15 · 개정 0 · 버전 줄만 375)
  (a) 전 봉투의 "contract_version": "1.32.0" → "1.33.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 15 — 🆕 폴더 `x1/`:
      옛 폰 `X1PlanWizardVm` 6(시작 전 D-03 · 단계 막힘 · 강등 뒤 · 티켓 · 모의 거부 · 잠김) /
      새 폰 `X1RecoveryVm` 8(받기 스캔 · 비상 시작 전 · 펜싱 · 복원 거부 · 갭 위반 · 게이트 관찰 · 생체 대기 · RECOVERY_FULL) /
      결과 1(`SafetyActionResult` 목록 · id 6 전부).
  (c) 글자 = «(합성)» 표기 평문(엔진 VM 생산 = 01 §8 미결 218 전 — 원천 0) · D-03 카드 = 코어 `m8/emergency_card.json` 첫 행 그대로 ·
      금액 · 계좌 · 기기 id · 시크릿 · sha256 전체 0 · 수치(관찰 일수 · 넘김 · 마진 · TTL) = 엔진 글자 꼴만.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_e16j_b_v133_fixtures.py
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
# 계약 1.32.0 · 픽스처 375 의 기준 커밋(origin/main · v1.32 병합 PR #299 squash 268d6bff).
BASE = '268d6bff'
BASE_FRESH_REF = 'origin/main'

OLD_VER = '"contract_version": "1.32.0"'
NEW_VER = '"contract_version": "1.33.0"'
BASE_FILES = 375
WANT_FILES = 390

SRC_CARD = 'm8/emergency_card.json'

META = {
    'fixture_version': '0.1.0-draft', 'contract_version': '1.33.0', 'generated_at': '2026-11-21T09:00:00Z',
    'mode': 'LIVE', 'config_hash': 'cfg_fake_0000000000000000', 'seed': 20261121,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}
AS_OF = {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
         'stale_after_seconds': 93600, 'label': '이전 기준 2026-08-31 18:00'}

RUN = 'mig-20260831-1'
NEW_RUN = 'rec-20260901-1'
PLAN_STEPS = ['FREEZE', 'ORDERS_CLEARED', 'RECON_ZERO', 'BACKUP_CHECKSUM', 'DEMOTED', 'KEYS_DELETED', 'RETIRED',
              'SERVICE_STOPPED', 'TICKET_ISSUED']
PLAN_TITLES = ['(합성) 1 주문 동결', '(합성) 2 미체결 정리', '(합성) 3 대사 0', '(합성) 4 백업 · 체크섬', '(합성) 5 강등',
               '(합성) 6 키 삭제', '(합성) 7 은퇴 서명', '(합성) 8 서비스 종료', '(합성) 9 티켓 발급']
REC_STEPS = ['RESTORED', 'GAP_REBUILT', 'GOLDEN_SELF_TEST', 'CHECKLIST_CONFIRMED', 'BIOMETRIC_CONFIRMED']
REC_TITLES = ['(합성) 1 복원', '(합성) 2 공백 다시 세기', '(합성) 3 골든 자가시험', '(합성) 4 확인 목록', '(합성) 5 생체 확인']
REISSUE = [('KIS_APP_KEY', '(합성) 한국투자증권 앱키', True), ('MESSENGER_TOKEN', '(합성) 알림 메신저 토큰', True),
           ('WATCHDOG_PING_KEY', '(합성) 감시 핑 키', True), ('GITHUB_PAT', '(합성) 깃허브 접근 토큰', True),
           ('SUPABASE_SESSION', '(합성) Supabase 로그인', False), ('GOOGLE_ACCESS', '(합성) 구글 접근', False)]
WINDOW = '(합성) 감시 일시정지 — 08-31 18:00 열림 · 넘기면 알림'
RESTART = {'label': '(합성) 잔고를 이어받아 새로 시작하기', 'deep_link': 'aaq://onboarding/restart'}


def call(aid, args, label):
    return {'id': aid, 'args': dict(args), 'label': label}


def plan_rows(done_upto, current=None, block=None, block_lines=()):
    """done_upto = 끝난 단계 수 · current = 지금 차례 행 번호(0부터) · block = 그 행 막힘 코드."""
    rows = []
    for i, code in enumerate(PLAN_STEPS):
        lines, actions, bcode = [], [], None
        if i < done_upto:
            state, level = '(합성) 끝', 'OK'
            if code == 'DEMOTED':
                lines = ['(합성) 여기부터 되돌릴 수 없습니다']
        elif i == current:
            if block:
                state, level, bcode, lines = '(합성) 막힘', 'BLOCKED', block, list(block_lines)
            else:
                state, level = '(합성) 차례', 'ACT'
                actions = [call('X1_PLAN_STEP', {'run_id': RUN, 'step': code}, '(합성) 이 단계 진행')]
            if code == 'DEMOTED':
                lines = lines + ['(합성) 여기부터 되돌릴 수 없습니다']
            if PLAN_STEPS.index(code) < PLAN_STEPS.index('DEMOTED'):
                actions = actions + [call('X1_PLAN_ABORT', {'run_id': RUN, 'step': code}, '(합성) 이전 그만두기')]
        else:
            state, level = '(합성) 대기', 'INFO'
        rows.append({'code': code, 'title': PLAN_TITLES[i], 'state_label': state, 'level': level, 'lines': lines,
                     'block_code': bcode, 'actions': actions})
    return rows


def rec_rows(done_upto, current=None, block=None, block_lines=(), step_action=True):
    rows = []
    for i, code in enumerate(REC_STEPS):
        lines, actions, bcode = [], [], None
        if i < done_upto:
            state, level = '(합성) 끝', 'OK'
        elif i == current:
            if block:
                state, level, bcode, lines = '(합성) 막힘', 'BLOCKED', block, list(block_lines)
            else:
                state, level = '(합성) 차례', 'ACT'
                if step_action:
                    actions = [call('X1_RECOVERY_STEP', {'run_id': NEW_RUN, 'step': code}, '(합성) 이 단계 진행')]
        else:
            state, level = '(합성) 대기', 'INFO'
        rows.append({'code': code, 'title': REC_TITLES[i], 'state_label': state, 'level': level, 'lines': lines,
                     'block_code': bcode, 'actions': actions})
    return rows


def reissue_rows(received):
    rows = []
    for i, (code, label, secret) in enumerate(REISSUE):
        if i < received:
            rows.append({'code': code, 'label': label, 'state_label': '(합성) 받음', 'level': 'OK',
                         'reissue_slot_id': None, 'record_action': None})
        elif code == 'GOOGLE_ACCESS':
            rows.append({'code': code, 'label': label, 'state_label': '(합성) 해당 없음', 'level': 'INFO',
                         'reissue_slot_id': None, 'record_action': None})
        else:
            rows.append({'code': code, 'label': label, 'state_label': '(합성) 남음', 'level': 'ACT',
                         'reissue_slot_id': 'SECRET_X1_REISSUE' if secret else None,
                         'record_action': call('X1_REISSUE_RECORD', {'run_id': NEW_RUN, 'item': code}, '(합성) 새 값 기록')})
    return rows


def plan_vm(**kw):
    base = {'headline': '', 'level': 'INFO', 'reason_code': None, 'd03_card': None, 'start_action': None, 'rows': [],
            'window_text': None, 'warning_lines': [], 'ticket': None, 'done_label': None, 'locked_label': None, 'as_of': AS_OF}
    base.update(kw)
    return base


def rec_vm(**kw):
    base = {'headline': '', 'level': 'INFO', 'reason_code': None, 'kind_label': '', 'start_action': None,
            'recovery_code_slot_id': None, 'fencing': None, 'reissue': [], 'scan_slot_id': None, 'restore': None,
            'steps': [], 'gate': None, 'restart_link': None, 'window_text': None, 'notice_text': None,
            'done_label': None, 'locked_label': None, 'as_of': AS_OF}
    base.update(kw)
    return base


RESTORE_OK = {'headline': '(합성) 백업을 복원했습니다', 'level': 'OK', 'code': None,
              'lines': ['(합성) 백업 08-31 18:00 · 스키마 판 7 · 해시 판 2 · epoch 4'], 'chain_hash_text': '3f9a1c07'}
KIND_PLAN = '(합성) 계획 이전'
KIND_EMERGENCY = '(합성) 비상 이전'


def build(card):
    d03 = copy.deepcopy(card)
    return {
        'x1/plan_wizard_d03.json': plan_vm(
            headline='(합성) 이전을 시작하기 전에 긴급정지 카드를 한 번 봅니다', level='ACT', d03_card=d03,
            start_action=call('X1_PLAN_START', {}, '(합성) 봤습니다 — 이전 시작')),
        'x1/plan_wizard_blocked.json': plan_vm(
            headline='(합성) 미체결 주문이 남아 있습니다', level='BLOCKED', reason_code='OPEN_ORDERS_REMAIN',
            rows=plan_rows(1, current=1, block='OPEN_ORDERS_REMAIN', block_lines=['(합성) 미체결 1건 — 체결 또는 취소를 기다립니다']),
            window_text=WINDOW),
        'x1/plan_wizard_demoted.json': plan_vm(
            headline='(합성) 이 폰은 강등됐습니다 — 남은 단계를 마치십시오', level='ACT',
            rows=plan_rows(5, current=5), window_text=WINDOW,
            warning_lines=['(합성) 보내지 않은 기록 0건 · 초안 0건', '(합성) 유예 안에 새 폰 복원을 마치십시오']),
        'x1/plan_wizard_ticket.json': plan_vm(
            headline='(합성) 새 폰에서 이 QR 을 읽으십시오', level='ACT', rows=plan_rows(9), window_text=WINDOW,
            ticket={'headline': '(합성) 이전 티켓', 'ticket_slot_id': 'X1_TICKET_QR_DISPLAY', 'expires_text': '(합성) 18:45 까지 유효',
                    'lines': ['(합성) 백업 08-31 18:00 · 체인 3f9a1c07']}),
        'x1/plan_wizard_live_only.json': plan_vm(
            headline='(합성) 모의투자 중에는 기기 이전을 하지 않습니다 — 새 폰에서 새로 시작하십시오', level='INFO',
            reason_code='X1_LIVE_ONLY'),
        'x1/plan_wizard_locked.json': plan_vm(
            headline='(합성) 미체결 주문이 남아 있습니다', level='BLOCKED', reason_code='OPEN_ORDERS_REMAIN',
            rows=[dict(r, actions=[]) for r in plan_rows(1, current=1, block='OPEN_ORDERS_REMAIN',
                                                          block_lines=['(합성) 미체결 1건 — 체결 또는 취소를 기다립니다'])],
            window_text=WINDOW, locked_label='(합성) 생체 확인 뒤에 진행할 수 있습니다'),
        'x1/recovery_plan_scan.json': rec_vm(
            headline='(합성) 옛 폰에 뜬 QR 을 읽으십시오', level='ACT', kind_label=KIND_PLAN, scan_slot_id='X1_TICKET_QR_SCAN'),
        'x1/recovery_emergency_start.json': rec_vm(
            headline='(합성) 옛 폰을 잃어버렸을 때의 복구입니다 — 복구 코드를 붙여 넣으십시오', level='ACT',
            kind_label=KIND_EMERGENCY, start_action=call('X1_EMERGENCY_START', {}, '(합성) 비상 복구 시작'),
            recovery_code_slot_id='SECRET_X1_RECOVERY_CODE',
            notice_text='(합성) 시작하면 옛 폰은 더 이상 주문할 수 없습니다'),
        'x1/recovery_emergency_fencing.json': rec_vm(
            headline='(합성) 옛 폰의 권한이 끝나기를 기다리는 동안 키를 다시 받으십시오', level='WATCH',
            reason_code='FENCING_WAIT', kind_label=KIND_EMERGENCY,
            fencing={'headline': '(합성) 옛 폰 권한 만료 대기', 'level': 'WATCH', 'ends_at_text': '(합성) 09-01 21:10 부터',
                     'code': 'FENCING_WAIT', 'lines': ['(합성) 그 전에는 복원을 시작하지 않습니다']},
            reissue=reissue_rows(2)),
        'x1/recovery_restore_rejected.json': rec_vm(
            headline='(합성) 이 백업은 쓸 수 없습니다', level='BLOCKED', reason_code='RESTORE_ROLLBACK', kind_label=KIND_PLAN,
            restore={'headline': '(합성) 백업이 최신 기록보다 오래됐습니다', 'level': 'BLOCKED', 'code': 'RESTORE_ROLLBACK',
                     'lines': ['(합성) 백업 08-30 18:00 · 최신 기록은 08-31 입니다'], 'chain_hash_text': '9b2e44d1'}),
        'x1/recovery_gap_violation.json': rec_vm(
            headline='(합성) 공백 동안의 체결이 맞지 않습니다', level='BLOCKED', reason_code='X1_RECOVERY_IN_PROGRESS',
            kind_label=KIND_PLAN, restore=RESTORE_OK,
            steps=rec_rows(1, current=1, block='GAP_OVERSOLD', block_lines=['(합성) 069500 — 가진 것보다 많이 판 기록이 있습니다'])),
        'x1/recovery_gate_observing.json': rec_vm(
            headline='(합성) 실거래 재개 전 관찰 중입니다', level='WATCH', reason_code='X1_OBSERVING', kind_label=KIND_PLAN,
            restore=RESTORE_OK, steps=rec_rows(3, current=3, step_action=False),
            gate={'state_label': '(합성) 관찰 중', 'level': 'WATCH', 'gate_state_code': 'OBSERVING', 'code': 'X1_OBSERVING',
                  'observe_text': '(합성) 2/5 거래일', 'why_line': '(합성) 새 폰에서 매매 없이 며칠 지켜봅니다',
                  'action_line': None, 'checklist_lines': []}),
        'x1/recovery_gate_biometric.json': rec_vm(
            headline='(합성) 마지막으로 생체 확인을 합니다', level='ACT', reason_code='X1_BIOMETRIC_PENDING', kind_label=KIND_PLAN,
            restore=RESTORE_OK, steps=rec_rows(4, current=4),
            gate={'state_label': '(합성) 승인 대기', 'level': 'ACT', 'gate_state_code': 'AWAITING_APPROVAL',
                  'code': 'X1_BIOMETRIC_PENDING', 'observe_text': '(합성) 5/5 거래일',
                  'why_line': '(합성) 관찰과 확인 목록을 마쳤습니다', 'action_line': '(합성) 생체 확인으로 실거래를 다시 엽니다',
                  'checklist_lines': ['(합성) 보유 종목이 증권사와 같다', '(합성) 미체결 주문이 없다']}),
        'x1/recovery_full.json': rec_vm(
            headline='(합성) 공백이 너무 길어 기록을 이어 붙일 수 없습니다 — 잔고를 이어받아 새로 시작합니다', level='BLOCKED',
            reason_code='X1_RECOVERY_FULL', kind_label=KIND_EMERGENCY, restore=RESTORE_OK, restart_link=RESTART),
    }


RESULTS = [
    ('ar_x1_01', 'X1_PLAN_START', 'OK', '(합성) 이전을 시작했습니다', None, False),
    ('ar_x1_02', 'X1_PLAN_START', 'INFO', '(합성) 모의투자 중에는 기기 이전을 하지 않습니다', 'X1_LIVE_ONLY', False),
    ('ar_x1_03', 'X1_PLAN_STEP', 'OK', '(합성) 단계를 마쳤습니다', None, False),
    ('ar_x1_04', 'X1_PLAN_STEP', 'BLOCKED', '(합성) 미체결 주문이 남아 있습니다', 'OPEN_ORDERS_REMAIN', True),
    ('ar_x1_05', 'X1_PLAN_ABORT', 'OK', '(합성) 이전을 그만뒀습니다', None, False),
    ('ar_x1_06', 'X1_PLAN_ABORT', 'BLOCKED', '(합성) 강등 뒤에는 되돌릴 수 없습니다', 'X1_PAST_NO_RETURN', False),
    ('ar_x1_07', 'X1_EMERGENCY_START', 'OK', '(합성) 비상 복구를 시작했습니다', None, False),
    ('ar_x1_08', 'X1_EMERGENCY_START', 'BLOCKED', '(합성) 비상 선언이 확인되지 않았습니다', 'EMERGENCY_NOT_DECLARED', False),
    ('ar_x1_09', 'X1_REISSUE_RECORD', 'OK', '(합성) 새 값을 기록했습니다', None, False),
    ('ar_x1_10', 'X1_REISSUE_RECORD', 'BLOCKED', '(합성) 옛 키를 다시 쓸 수 없습니다 — 새로 발급하십시오', 'KEY_REUSED', False),
    ('ar_x1_11', 'X1_RECOVERY_STEP', 'OK', '(합성) 복구 단계를 마쳤습니다', None, False),
    ('ar_x1_12', 'X1_RECOVERY_STEP', 'BLOCKED', '(합성) 골든 자가시험이 실패했습니다', 'X1_GOLDEN_FAILED', False),
    ('ar_x1_13', 'X1_RECOVERY_STEP', 'BLOCKED', '(합성) 이 백업은 쓸 수 없습니다', 'RESTORE_ROLLBACK', False),
    ('ar_x1_14', 'X1_RECOVERY_STEP', 'BLOCKED', '(합성) 생체 확인을 쓸 수 없습니다', 'BIOMETRIC_UNAVAILABLE', False),
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
    card = json.loads(_BASE_CACHE[SRC_CARD])['rows'][0]
    assert 'keep_on_paper_notice' in card and card.get('print_slot_id') == 'EMERGENCY_CARD_PRINT', card.keys()
    new = {rel: vm_text(v) for rel, v in build(card).items()}
    new['x1/x1_action_results.json'] = results_text()
    for rel, txt in new.items():
        assert rel not in rels, rel
        json.loads(txt)                                                      # 꼴 확인
        for bad in ('sb_secret_', 'eyJ', 'device_id', 'sha256'):   # D-03 카드 = 기존 표본 복사(«계좌번호와 앱키는 …» 안내 글자)
            assert bad not in txt, (rel, bad)
        out[rel] = txt
    assert len(out) == WANT_FILES, len(out)
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_e16j_b_v133_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.33.0'
          % (len(out), BASE_FILES, BASE_FILES, len(new)))


if __name__ == '__main__':
    main()
