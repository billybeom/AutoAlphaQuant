#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.15(R14 선행 M2 보강 · 01 §24) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r14_v115_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r13b_v113_fixtures.py(계약 v1.13 · 그 스크립트는 v1.13 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-10-30_R14선행_계약v1.15_설계서.md` §5 · 176 → 187 = 신설 11 · 개정 5 · 버전 줄만 171)
  (a) 전 봉투의 "contract_version": "1.14.0" → "1.15.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 5 —
      · alerts_12(K13·K14) — al_0001(EXIT_URGENT)·al_0003(P1) `ack` → null · 차례 = 1~6 · 10~12 · 7~9(등급 순).
      · m8/alerts_p0_ack(K14) — al_p0_01 = ORDER_OUTCOME_UNKNOWN(사다리 표본 보존 · ack 그대로).
      · m8/alerts_advice_9codes(K13) — 차례만 P0 3 → P1 4 → P2 2(등급 안 상대 차례 유지 · 값 무변경).
      · m8/watchdog_delayed · m8/watchdog_holiday(K3·K4·K15·K16) — 꼴 교체 = `WatchdogBoardVm` 1행 봉투 ·
        `slug` 키 0 → `check_id` · `level` · 실패 1행 · 휴장 행 = 성공 핑(OK·ok) · 형제 키 `holiday_notice` → VM 필드.
  (c) 신설 11 — 알림 센터 5 · 상세 3 · 확인 접수증 1(`m8/alert_ack_receipts_3`) · 워치독 2(paused · empty).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 발주자 결정(2026-10-30 · ①~④) — ② (a) N-02 = AlertDetailVm (b) W-01 = WatchdogBoardVm (c) slug 제거 → check_id.
   사다리 단계 줄 = 넣지 않음(AckState 무변경).

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r14_v115_fixtures.py
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
# 계약 1.14.0 · 픽스처 176 의 기준 커밋(origin/main · R5 test-only 기록 — 계약 패키지 = E8a PR #73 이후 무변경).
BASE = '1bb1a848ebc58b9816d9749a196dfc816d8b7f1d'

OLD_VER = '"contract_version": "1.14.0"'
NEW_VER = '"contract_version": "1.15.0"'
BASE_FILES = 176
WANT_FILES = 187

RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'화면이|화면은|화면·')              # 사용자 문장 자리의 개발자 메모(H50)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6
SLUG_LIKE = re.compile(r'^(sim|live)-(auto|advisory)-')   # K17
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
UI_LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}
LEVEL_OF_STATE = {'OK': 'OK', 'DELAYED': 'WATCH', 'FAILED': 'BLOCKED', 'PAUSED': 'INFO'}   # K16

# ── 이름 ─────────────────────────────────────────────────────────────────
A12 = 'alerts_12.json'
P0ACK = 'm8/alerts_p0_ack.json'
X9 = 'm8/alerts_advice_9codes.json'
WD_DELAYED = 'm8/watchdog_delayed.json'
WD_HOLIDAY = 'm8/watchdog_holiday.json'
REVISED = [A12, P0ACK, X9, WD_DELAYED, WD_HOLIDAY]

C_P0ACK = 'm8/alert_center_p0_ack.json'
C_DIGEST = 'm8/alert_center_digest.json'
C_EMPTY = 'm8/alert_center_empty.json'
C_P0ONLY = 'm8/alert_center_p0_only.json'
C_REORDER = 'm8/alert_center_p0_ack_reordered.json'
D_FULL = 'm8/alert_detail_full.json'
D_NOLINK = 'm8/alert_detail_no_link.json'
D_MISSING = 'm8/alert_detail_missing.json'
ACK3 = 'm8/alert_ack_receipts_3.json'
WD_PAUSED = 'm8/watchdog_paused.json'
WD_EMPTY = 'm8/watchdog_empty.json'
CENTERS = [C_P0ACK, C_DIGEST, C_EMPTY, C_P0ONLY, C_REORDER]
DETAILS = [D_FULL, D_NOLINK, D_MISSING]
BOARDS = [WD_DELAYED, WD_HOLIDAY, WD_PAUSED, WD_EMPTY]
NEW_FILES = CENTERS + DETAILS + [ACK3, WD_PAUSED, WD_EMPTY]

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.15.0',
    'generated_at': '2026-10-30T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261030,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}
ALERT_AS_OF = {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
               'stale_after_seconds': 93600, 'label': '알림 기준 2026-08-31'}
WD_AS_OF = dict(ALERT_AS_OF, label='워치독 기준 2026-08-31')
ACK_AS_OF = dict(ALERT_AS_OF, label='기록 기준 2026-08-31')

# ── 알림 행(§5-1 · 키 차례 고정) ──────────────────────────────────────────
ALERT_KEYS = ['alert_id', 'level', 'raised_at', 'code', 'title', 'body_text', 'action_line', 'grouped_count',
              'deep_link', 'ack', 'raised_at_text', 'grouped_text', 'detail_deep_link']


def alert(*vals):
    assert len(vals) == len(ALERT_KEYS), vals
    return dict(zip(ALERT_KEYS, vals))


def dl(aid):
    return 'aaq://alerts/detail/' + aid


P0A = alert('al_c_p0_01', 'P0', '2026-08-31T01:05:00Z', 'RECON_MISMATCH', '원장 대조가 어긋났습니다',
            '브로커 대조에서 차이가 두 번 났습니다.', '대조 보드를 여십시오.', 2, 'aaq://ledger/diffs',
            {'acked': False, 'state_label': '수신 확인 전 · 백업 채널로 보냈습니다', 'escalation_step': 1},
            '10:05', '2건', dl('al_c_p0_01'))
P0B = alert('al_c_p0_02', 'P0', '2026-08-31T01:20:00Z', 'ADVICE_REVOKED', '발행한 안내를 회수했습니다',
            '전환 커밋으로 미이행 안내가 회수되었습니다.', '회수 목록을 확인하십시오.', 1, 'aaq://advice/history',
            {'acked': True, 'acked_at': '2026-08-31T01:32:00Z', 'state_label': '수신 확인함', 'escalation_step': 0},
            '10:20', None, dl('al_c_p0_02'))
P0C = alert('al_c_p0_03', 'P0', '2026-08-31T02:00:00Z', 'ADVICE_EXIT_URGENT', '즉시 확인이 필요한 청산 안내',
            '손절선에 닿은 종목이 있습니다.', '지금 안내함을 여십시오.', 1, 'aaq://advice/inbox', None,
            '11:00', None, dl('al_c_p0_03'))
P1A = alert('al_c_p1_01', 'P1', '2026-08-31T00:10:00Z', 'ADVICE_ISSUED', '오늘의 안내가 도착했습니다',
            '새 안내 2건이 있습니다.', '안내함을 여십시오.', 1, 'aaq://advice/inbox', None,
            '09:10', None, dl('al_c_p1_01'))
P1B = alert('al_c_p1_02', 'P1', '2026-08-30T23:40:00Z', 'ADVICE_DUE_SOON', '유효기한이 오늘까지인 안내',
            '오늘 장 마감까지 유효한 안내가 있습니다.', '기한 전에 기록하십시오.', 1, 'aaq://advice/inbox', None,
            '08:40', None, dl('al_c_p1_02'))
P1C = alert('al_c_p1_03', 'P1', '2026-08-31T00:30:00Z', 'MAINTENANCE_WINDOW_OVERDUE', '유지보수 창을 넘겼습니다',
            '예정한 유지보수 창이 지났습니다.', '유지보수 화면을 여십시오.', 1, 'aaq://ops/maintenance', None,
            '09:30', None, None)
P2A = alert('al_c_p2_01', 'P2', '2026-08-30T03:00:00Z', 'ADVICE_EXPIRED', '만료된 안내',
            '기한이 지난 안내가 있습니다.', '지난 안내를 확인하십시오.', 1, 'aaq://advice/history', None,
            '12:00', None, dl('al_c_p2_01'))
P2B = alert('al_c_p2_02', 'P2', '2026-08-30T02:00:00Z', 'SELF_AUDIT_DUE', '분기 실사 기한',
            '분기 실사 기한이 다가옵니다.', '실사 일정을 확인하십시오.', 1, 'aaq://ledger/trust', None,
            '11:00', None, dl('al_c_p2_02'))
P2C = alert('al_c_p2_03', 'P2', '2026-08-30T01:00:00Z', 'CONTRIBUTION_CHANGED', '월 납입 설정이 바뀌었습니다',
            '월 납입 운영값이 바뀌었습니다.', '설정을 확인하십시오.', 3, None, None,
            None, '3건', dl('al_c_p2_03'))

CENTER_EMPTY_LABEL = '새 알림이 없습니다. 이상이 생기면 바로 알립니다.'
DETAIL_MISSING_LABEL = '이 알림은 더 이상 없습니다. 알림 센터에서 최근 알림을 확인하십시오.'

# ── 워치독 보드(§5-4) ─────────────────────────────────────────────────────
LIMIT_NOTICE = 'healthchecks.io 자체 장애 때는 경보가 오지 않습니다 — 이메일 2차 채널로 받습니다.'
HOLIDAY_NOTICE = '휴장일의 쉼은 결측이 아닙니다.'
WD_EMPTY_LABEL = '등록된 워치독 체크가 아직 없습니다.'
NAME = {'wd_0001': '장 전 준비 배치', 'wd_0002': '주문 배치', 'wd_0003': '대사 배치', 'wd_0004': '아카이브 커밋',
        'wd_0005': '체결 확인 배치', 'wd_0006': '생존 신호'}


def check(cid, state_code, state_label, level, last_ping, grace=None, route=None):
    row = {'check_id': cid, 'label': NAME[cid], 'state_code': state_code, 'state_label': state_label,
           'level': level, 'last_ping_text': last_ping}
    if grace is not None:
        row['grace_text'] = grace
    if route is not None:
        row['route'] = route
    return row


DELAYED_ROWS = [
    check('wd_0001', 'OK', '정상', 'OK', '오늘 07:12에 확인'),
    check('wd_0002', 'DELAYED', '지연 중', 'WATCH', '오늘 09:31에 확인', '유예 30분 안입니다', 'aaq://ops/watchdog'),
    check('wd_0003', 'OK', '정상', 'OK', '오늘 16:05에 확인'),
    check('wd_0004', 'DELAYED', '지연 중', 'WATCH', '어제 23:40에 확인', '유예 24시간 안입니다', 'aaq://ops/watchdog'),
    check('wd_0005', 'FAILED', '실패', 'BLOCKED', '오늘 10:02에 실패 신호'),
    check('wd_0006', 'OK', '정상', 'OK', '5분 전에 확인'),
]
HOLIDAY_ROWS = [
    check('wd_0001', 'OK', '휴장일 확인 — 정상', 'OK', '오늘 07:12에 휴장 확인'),
    check('wd_0002', 'OK', '휴장일 확인 — 정상', 'OK', '오늘 09:05에 휴장 확인'),
    check('wd_0003', 'OK', '휴장일 확인 — 정상', 'OK', '오늘 16:05에 휴장 확인'),
    check('wd_0004', 'OK', '정상', 'OK', '오늘 00:10에 확인'),
    check('wd_0006', 'OK', '정상', 'OK', '3분 전에 확인'),
]
PAUSED_ROWS = [
    check('wd_0001', 'PAUSED', '유지보수로 일시정지', 'INFO', '오늘 07:12에 확인', '유지보수 창이 끝나면 다시 봅니다'),
    check('wd_0002', 'PAUSED', '유지보수로 일시정지', 'INFO', '오늘 09:05에 확인'),
    check('wd_0003', 'PAUSED', '유지보수로 일시정지', 'INFO', '어제 16:05에 확인'),
    check('wd_0004', 'OK', '정상', 'OK', '오늘 00:10에 확인'),
    check('wd_0006', 'OK', '정상', 'OK', '4분 전에 확인'),
]


def board(rows, as_of, empty_label=None, holiday=None, last_received=None):
    return {'rows': rows, 'as_of': as_of, 'empty_label': empty_label, 'holiday_notice': holiday,
            'limit_notice': LIMIT_NOTICE, 'last_received_text': last_received}


# ── 접수증(§5-2 · 키 차례 = m6/advice_defer_receipts_3) ────────────────────
def receipt(state, label, reason=None):
    r = {'command_id': 'cmd_20260831_0201', 'kind': 'ALERT_ACK', 'state': state, 'state_label': label,
         'requested_at': '2026-08-31T10:00:00Z', 'expires_at': '2026-08-31T10:30:00Z', 'nonce': 'n_a1c4e0b7f233',
         'issued_by_device_id': 'dev_operator_01'}
    if reason is not None:
        r['reject_reason_code'] = reason
    return r


ACK_ROWS = [
    receipt('REQUESTED', '요청됨 — 엔진 수신 대기'),
    receipt('EXECUTED', '수신 확인을 기록했습니다 — 승급 알림을 멈췄습니다'),
    receipt('REJECTED', '거부됨 — 이 알림은 확인할 수 없습니다. 알림 센터를 다시 여십시오', 'INPUT_INVALID'),
]


# ────────────────────────────────────────────────────────────────────────
# 직렬화 — 저장소 원문 꼴(meta 여러 줄 · 평평한 객체 한 줄 · 목록·VM 여러 줄 · 들여쓰기 2)
# ────────────────────────────────────────────────────────────────────────
def dumps(v):
    return json.dumps(v, ensure_ascii=False)


def is_scalar(v):
    return not isinstance(v, (dict, list))


def is_flat(v):
    """한 줄로 쓰는 객체 — 값이 스칼라이거나 스칼라만 가진 객체(목록 0)."""
    return isinstance(v, dict) and all(
        is_scalar(x) or (isinstance(x, dict) and all(is_scalar(y) for y in x.values())) for x in v.values())


def inline(v):
    if isinstance(v, dict):
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


def base_text(rel):
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


def bumped_env(rel):
    env = base_env(rel)
    assert env['meta']['contract_version'] == '1.14.0', rel
    env['meta']['contract_version'] = '1.15.0'
    return env


def vm_envelope(as_of, vm, meta=None):
    """VM 1행 봉투(선례 m8/recon_board_ok) — 최상위 as_of = VM as_of."""
    return {'meta': copy.deepcopy(meta or NEW_META), 'as_of': copy.deepcopy(as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': [vm]}


# ────────────────────────────────────────────────────────────────────────
# 개정
# ────────────────────────────────────────────────────────────────────────
def reorder(rows, ids):
    by = {r['alert_id']: r for r in rows}
    assert sorted(by) == sorted(ids) and len(by) == len(rows), (sorted(by), ids)
    return [by[i] for i in ids]


def revise_alerts12():
    env = bumped_env(A12)
    rows = env['rows']
    by = {r['alert_id']: r for r in rows}
    assert by['al_0001']['code'] == 'ADVICE_EXIT_URGENT' and by['al_0001']['ack'] is not None
    assert by['al_0003']['level'] == 'P1' and by['al_0003']['ack'] is not None
    by['al_0001']['ack'] = None
    by['al_0003']['ack'] = None
    env['rows'] = reorder(rows, ['al_0001', 'al_0002', 'al_0003', 'al_0004', 'al_0005', 'al_0006',
                                 'al_0010', 'al_0011', 'al_0012', 'al_0007', 'al_0008', 'al_0009'])
    return ser_envelope(env, True)


def revise_p0ack():
    env = bumped_env(P0ACK)
    r = env['rows'][0]
    assert r['alert_id'] == 'al_p0_01' and r['code'] == 'ADVICE_EXIT_URGENT' and r['ack']['escalation_step'] == 2
    r['code'] = 'ORDER_OUTCOME_UNKNOWN'
    r['title'] = '주문 결과를 확인하지 못했습니다'
    r['body_text'] = '증권사 응답이 끊겨 주문 2건의 체결 여부를 모릅니다.'
    r['action_line'] = '미확인 주문 보드를 여십시오.'
    r['deep_link'] = 'aaq://journal/unknown-board'
    return ser_envelope(env, True)


def revise_9codes():
    env = bumped_env(X9)
    env['rows'] = reorder(env['rows'], ['al_x7_02', 'al_x7_05', 'al_x7_06', 'al_x7_01', 'al_x7_03', 'al_x7_07',
                                        'al_x7_09', 'al_x7_04', 'al_x7_08'])
    return ser_envelope(env, True)


def revise_board(rel, rows, holiday, last_received):
    env = base_env(rel)
    meta = dict(env['meta'], contract_version='1.15.0')
    assert all('slug' in r for r in env['rows']), rel
    out = vm_envelope(env['as_of'], board(rows, env['as_of'], None, holiday, last_received), meta)
    return ser_envelope(out, False)


# ────────────────────────────────────────────────────────────────────────
# 신설
# ────────────────────────────────────────────────────────────────────────
def center(pinned, sections, empty_label=None):
    return {'as_of': ALERT_AS_OF, 'pinned': pinned, 'sections': sections, 'empty_label': empty_label}


def section(header, rows, digest_label, digest_rows):
    return {'header_text': header, 'rows': rows, 'digest_label': digest_label, 'digest_rows': digest_rows}


def new_files():
    today = section('오늘', [P1A, P1B], None, [])
    out = {
        C_P0ACK: vm_envelope(ALERT_AS_OF, center([P0A, P0B, P0C], [today])),
        C_DIGEST: vm_envelope(ALERT_AS_OF, center([], [section('오늘', [P1C], None, []),
                                                       section('2026-08-30', [], 'P2 3건', [P2A, P2B, P2C])])),
        C_EMPTY: vm_envelope(ALERT_AS_OF, center([], [], CENTER_EMPTY_LABEL)),
        C_P0ONLY: vm_envelope(ALERT_AS_OF, center([P0A, P0B, P0C], [])),
        C_REORDER: vm_envelope(ALERT_AS_OF, center([P0B, P0A, P0C], [today])),
        D_FULL: vm_envelope(ALERT_AS_OF, {'as_of': ALERT_AS_OF, 'item': P0A, 'missing_label': None}),
        D_NOLINK: vm_envelope(ALERT_AS_OF, {'as_of': ALERT_AS_OF, 'item': P2C, 'missing_label': None}),
        D_MISSING: vm_envelope(ALERT_AS_OF, {'as_of': ALERT_AS_OF, 'item': None,
                                             'missing_label': DETAIL_MISSING_LABEL}),
        WD_PAUSED: vm_envelope(WD_AS_OF, board(PAUSED_ROWS, WD_AS_OF, None, None, '마지막 수신 17:56')),
        WD_EMPTY: vm_envelope(WD_AS_OF, board([], WD_AS_OF, WD_EMPTY_LABEL, None, None)),
    }
    texts = {rel: ser_envelope(env, False) for rel, env in out.items()}
    ack = vm_envelope(ACK_AS_OF, None)
    ack['rows'] = ACK_ROWS
    texts[ACK3] = ser_envelope(ack, True)
    return texts


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


def alert_objs(v):
    if isinstance(v, dict):
        if 'alert_id' in v:
            yield v
        for x in v.values():
            yield from alert_objs(x)
    elif isinstance(v, list):
        for x in v:
            yield from alert_objs(x)


def self_check_file(rel, s, touched, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE' and env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    assert list(env.keys())[:6] == ENVELOPE_KEYS, (rel, list(env.keys()))
    assert 'slug' not in set(keys(env)), rel                                   # K4 — 전 픽스처
    if touched:
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
            if new:
                assert not DEV_MEMO.search(v), '%s %s — 개발자 메모: %s' % (rel, path, v)
        assert not any(PNL_KEY.search(k) for k in keys(env)), rel
    for a in alert_objs(env):                                                  # K14 · ⑦
        if a.get('ack') is not None:
            assert a['level'] == 'P0' and a['code'] != 'ADVICE_EXIT_URGENT', (rel, a['alert_id'])
        if a.get('grouped_text') is not None:
            assert a['grouped_count'] > 1, (rel, a['alert_id'])
        if a.get('detail_deep_link') is not None:
            assert a['detail_deep_link'] == dl(a['alert_id']), (rel, a['alert_id'])
    return env


def check_center(vm, rel):
    assert list(vm) == ['as_of', 'pinned', 'sections', 'empty_label'], rel
    assert all(a['level'] == 'P0' for a in vm['pinned']), rel
    for sec in vm['sections']:
        assert list(sec) == ['header_text', 'rows', 'digest_label', 'digest_rows'], rel
        assert sec['header_text'].strip() and (sec['rows'] or sec['digest_rows']), rel
        assert all(a['level'] == 'P1' for a in sec['rows']), rel
        assert all(a['level'] == 'P2' for a in sec['digest_rows']), rel
        assert (sec['digest_label'] is not None) == bool(sec['digest_rows']), rel
    assert (vm['empty_label'] is not None) == (not vm['pinned'] and not vm['sections']), rel
    for a in alert_objs(vm):
        assert list(a) == ALERT_KEYS, (rel, a['alert_id'])
        assert (a['grouped_text'] is not None) == (a['grouped_count'] > 1), (rel, a['alert_id'])
        if a['raised_at_text'] is not None:                                     # KST = UTC + 9h
            hh, mm = int(a['raised_at'][11:13]), a['raised_at'][14:16]
            assert a['raised_at_text'] == '%02d:%s' % ((hh + 9) % 24, mm), (rel, a['alert_id'])


def check_board(vm, rel):
    assert list(vm) == ['rows', 'as_of', 'empty_label', 'holiday_notice', 'limit_notice', 'last_received_text'], rel
    ids = [r['check_id'] for r in vm['rows']]
    assert len(ids) == len(set(ids)), rel
    for r in vm['rows']:
        assert list(r)[:6] == ['check_id', 'label', 'state_code', 'state_label', 'level', 'last_ping_text'], rel
        assert set(r) <= {'check_id', 'label', 'state_code', 'state_label', 'level', 'last_ping_text',
                          'grace_text', 'route'}, rel
        assert not SLUG_LIKE.search(r['check_id']) and '://' not in r['check_id'], rel
        assert r['level'] in UI_LEVELS and LEVEL_OF_STATE[r['state_code']] == r['level'], (rel, r)
    assert (vm['empty_label'] is not None) == (not vm['rows']), rel
    assert vm['limit_notice'] is not None, rel
    assert (vm['last_received_text'] is not None) == bool(vm['rows']), rel


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels)
    # 직렬화 꼴 자체 검사 — 개정 알림 3파일의 기준 원문을 그대로 다시 쓸 수 있어야 한다.
    for rel in (A12, P0ACK, X9):
        assert ser_envelope(base_env(rel), True) == base_text(rel), rel
    assert base_env(WD_HOLIDAY)['holiday_notice'] == HOLIDAY_NOTICE

    out = {
        A12: revise_alerts12(),
        P0ACK: revise_p0ack(),
        X9: revise_9codes(),
        WD_DELAYED: revise_board(WD_DELAYED, DELAYED_ROWS, None, '마지막 수신 17:58'),
        WD_HOLIDAY: revise_board(WD_HOLIDAY, HOLIDAY_ROWS, HOLIDAY_NOTICE, '마지막 수신 17:57'),
    }
    out.update(new_files())
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES or rel in REVISED, rel in NEW_FILES)
            for rel, s in out.items()}
    vms = {rel: envs[rel]['rows'][0] for rel in CENTERS + DETAILS + BOARDS}
    for rel in CENTERS + DETAILS + BOARDS:
        assert len(envs[rel]['rows']) == 1 and envs[rel]['as_of'] == vms[rel]['as_of'], rel
    for rel in CENTERS:
        check_center(vms[rel], rel)
    for rel in BOARDS:
        check_board(vms[rel], rel)
    # 센터 — 빈 1 · P0만 = p0_ack 의 pinned · 재발행 = 집합 같고 차례 다름 · [0] = 확인됨.
    p0ack = vms[C_P0ACK]
    assert vms[C_P0ONLY]['pinned'] == p0ack['pinned'] and vms[C_P0ONLY]['sections'] == []
    re_ = vms[C_REORDER]
    assert [a['alert_id'] for a in re_['pinned']] != [a['alert_id'] for a in p0ack['pinned']]
    assert sorted(a['alert_id'] for a in re_['pinned']) == sorted(a['alert_id'] for a in p0ack['pinned'])
    assert re_['pinned'][0] == p0ack['pinned'][1] and re_['pinned'][0]['ack']['acked'] is True
    assert re_['sections'] == p0ack['sections']
    assert any(a['ack'] and not a['ack']['acked'] for a in p0ack['pinned'])
    assert any(a['code'] == 'ADVICE_EXIT_URGENT' and a['ack'] is None for a in p0ack['pinned'])
    # 상세 — item XOR missing · 센터 같은 객체.
    for rel in DETAILS:
        d = vms[rel]
        assert list(d) == ['as_of', 'item', 'missing_label'] and (d['item'] is None) != (d['missing_label'] is None)
    assert vms[D_FULL]['item'] == p0ack['pinned'][0]
    assert vms[D_NOLINK]['item'] == vms[C_DIGEST]['sections'][1]['digest_rows'][2]
    # 접수증 3갈래.
    ack = envs[ACK3]['rows']
    assert [r['state'] for r in ack] == ['REQUESTED', 'EXECUTED', 'REJECTED']
    assert ack[2]['reject_reason_code'] == 'INPUT_INVALID' and all('reject_reason_code' not in r for r in ack[:2])
    assert list(ack[2]) == list(base_env('m6/advice_defer_receipts_3.json')['rows'][2])
    # 워치독 — 실패 ≥1 · 휴장 고지 = holiday 만 · 휴장 행 PAUSED 0 · 자기 링크 2.
    assert any(r['state_code'] == 'FAILED' for r in vms[WD_DELAYED]['rows'])
    assert all(r['state_code'] != 'PAUSED' for r in vms[WD_HOLIDAY]['rows'])
    assert sum(r['state_code'] == 'PAUSED' for r in vms[WD_PAUSED]['rows']) == 3
    assert [rel for rel in BOARDS if vms[rel]['holiday_notice'] is not None] == [WD_HOLIDAY]
    assert [r.get('route') for r in vms[WD_DELAYED]['rows'] if r.get('route')] == ['aaq://ops/watchdog'] * 2
    assert 'holiday_notice' not in envs[WD_HOLIDAY]
    for rel in BOARDS:                                                           # 이름은 체크마다 한 벌
        for r in vms[rel]['rows']:
            assert r['label'] == NAME[r['check_id']], (rel, r)
    # 알림 개정 — 차례 = 등급 순 · al_0001 ack null 이어도 P0 점(al_0002 미확인) 그대로 · 요약 불변.
    lv = {'P0': 0, 'P1': 1, 'P2': 2}
    for rel in (A12, X9):
        seq = [lv[r['level']] for r in envs[rel]['rows']]
        assert seq == sorted(seq), rel
    a12 = envs[A12]['rows']
    assert [r['level'] for r in a12].count('P1') == 7 and [r['level'] for r in a12].count('P2') == 3
    assert [r['alert_id'] for r in a12[:6]] == ['al_000%d' % i for i in range(1, 7)]
    assert a12[1]['ack'] and not a12[1]['ack']['acked']
    assert a12[3]['level'] == 'P1' and a12[3].get('ack') is None
    p0 = envs[P0ACK]['rows']
    assert p0[0]['ack']['escalation_step'] == 2 and p0[1]['ack']['acked'] is True
    # 개정 알림 3 — 차례·지정 칸 밖은 기준과 같다.
    for rel in (A12, P0ACK, X9):
        got = {r['alert_id']: r for r in envs[rel]['rows']}
        for r in base_env(rel)['rows']:
            g = dict(got[r['alert_id']])
            if rel == A12 and r['alert_id'] in ('al_0001', 'al_0003'):
                g['ack'] = r['ack']
            if rel == P0ACK and r['alert_id'] == 'al_p0_01':
                for k in ('code', 'title', 'body_text', 'action_line', 'deep_link'):
                    g[k] = r[k]
            assert g == r, (rel, r['alert_id'])

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    n_revised = sum(1 for rel in rels if out[rel] != bump(base_text(rel), rel))
    assert (n_version_only, n_revised) == (171, 5), (n_version_only, n_revised)

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r14_v115_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · contract 1.15.0'
          % (len(out), BASE_FILES, n_version_only, n_revised, len(NEW_FILES)))


if __name__ == '__main__':
    main()
