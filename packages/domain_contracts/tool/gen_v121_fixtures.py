#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.21(엔진 예고 1/2 — M5 안전 쓰기 포트 + 체험 길 · 01 §30) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_v121_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r7_v120_fixtures.py(계약 v1.20 · 그 스크립트는 v1.20 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-15_계약v1.21_설계서.md` §5 · 271 → 283 = 신설 12 · 개정 1 · 버전 줄만 270)
  (a) 전 봉투의 "contract_version": "1.20.0" → "1.21.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 12 — 🆕 m5/ 폴더: M5-2 재개 게이트 VM 7 · 서약 VM 3 · 안전 동작 결과 1(14행) · 발동 기록 접수증 1(7행).
  (c) 🔧 개정 1(F3 · K19) — safety_states 의 `"ramp_level": "L0"` → `"L1"`(바이트 치환 정확히 1회 · v1 엔진 발행 집합 L1~L5).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*` · `check_*`.

🔴 안전 수치 0 — 48시간 · 7문항 · 12월은 엔진·SPEC 글자 안에서만 옮긴다(새로 정하지 않는다).
🔴 엔진 글자가 있는 칸(게이트 머리 · ETA · 확인 전 막힘 · 냉각 게이지 · 6번 재생) = 엔진 글자 그대로
   (core `safety/kill_switch.dart` `killSwitchViewOf` · `safety/safety_text.dart` COOLDOWN 게이지).
🔴 7문항·선택지 글자 = SPEC v2.40 `06_시스템설계/04_안전장치.md` §3-6 «재개판» 원문(설계 저장소 · 앱 저장소 밖 파일 —
   아래 상수에 정규화 규칙 K38 로 옮겨 박는다: 굵게·🔴·백틱 제거 · 6번 괄호 설계 메모 제거 · 3·4번 선택지 분리 · 그 밖 원문).
   엔진이 문안을 정하면(엔진 먼저 정할 것 ②) 이 상수와 표본을 개정한다.
🔴 결과 headline · 접수증 state_label · 재생(1~5번) · 답 · 서약 줄 = 합성(엔진 문장 0 · 실제 사용자 글 0 — K42).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_v121_fixtures.py
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
# 계약 1.20.0 · 픽스처 271 의 기준 커밋(origin/main · R7a 조립 기록 — 계약 패키지 = PR #187 이후 README 만).
BASE = '83c3d4401c499866b920f450cbbbd07ddedac24a'

OLD_VER = '"contract_version": "1.20.0"'
NEW_VER = '"contract_version": "1.21.0"'
BASE_FILES = 271
WANT_FILES = 283

RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'(?<!이 )화면이|화면은|화면·')      # 사용자 문장 자리의 개발자 메모(H50)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6
PNL_WORD = re.compile(r'수익률|평가액|손익')
MONEY = re.compile(r'[0-9][0-9,]*원')
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PHONE = re.compile(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}')    # C-51 ⑤
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
URL_LIKE = re.compile(r'https?://|github\.com|\.io/')
LONG_DIGITS = re.compile(r'[0-9]{8,}')                     # 8자리 이상 숫자 0
COUNTDOWN = re.compile(r'카운트다운|남은 시간|해제 버튼')    # 🆕 «해제 버튼» 0(K15)
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}
# 🆕 m5/ VM 안 금지 키(C-55 ①) — 카운트다운 원값 · 해제 버튼 칸 · 저널 id 노출 · 프리필.
BAD_KEYS = ('decision_id', 'journal_decision_id', 'countdown', 'remaining_seconds', 'eta_utc', 'release_action',
            'resume_action', 'deactivate', 'prefill', 'example')

# ── 사전(labels/safety_codes.dart · settings_codes.dart 와 같은 글자 — C-55 ②③⑬ 이 다시 본다) ──
KILL_CODES = {'KILL_ACK_INCOMPLETE', 'KILL_ACK_MISMATCH', 'KILL_CHECKLIST_ITEM_MISSING', 'KILL_SWITCH_NOT_ACTIVE',
              'RESUME_CHECKLIST_DONE', 'RESUME_CHECKLIST_INCOMPLETE', 'RESUME_CHECKLIST_NOT_CONFIRMED',
              'RESUME_CONDITION_UNMET', 'RESUME_ITEM_MISSING', 'RESUME_ITEM_OUT_OF_ORDER', 'RESUME_TOO_SOON',
              'RESUME_TRUSTED_TIME_UNKNOWN'}
COMMON_CODES = {'TRUSTED_TIME_UNKNOWN', 'JOURNAL_ID_TAKEN'}
PLEDGE_CODES = {'PLEDGE_ALREADY_WRITTEN', 'PLEDGE_JOURNAL_MISSING', 'PLEDGE_NOT_WRITTEN', 'PLEDGE_OUT_OF_WINDOW',
                'PLEDGE_SENTENCES_MISSING', 'PLEDGE_UNCHANGED'}
GAUGE_CODES = {'DD_RECOVERY', 'HOLD', 'BULL_STREAK', 'COOLDOWN'}
BIOMETRIC = 'BIOMETRIC_UNAVAILABLE'
RESUME_ROW_CODES = {c for c in KILL_CODES if c.startswith('RESUME_')} | {'KILL_SWITCH_NOT_ACTIVE', 'JOURNAL_ID_TAKEN',
                                                                         BIOMETRIC}
PLEDGE_ROW_CODES = PLEDGE_CODES | {'TRUSTED_TIME_UNKNOWN', BIOMETRIC}
RECEIPT_REJECTS = {'KILL_CHECKLIST_ITEM_MISSING', 'KILL_ACK_INCOMPLETE', 'KILL_ACK_MISMATCH', 'KILL_SWITCH_NOT_ACTIVE',
                   'TRUSTED_TIME_UNKNOWN', 'JOURNAL_ID_TAKEN'}
SAFETY_IDS = {'KILL_SWITCH_RESUME', 'PLEDGE_WRITE', 'PLEDGE_EDIT'}

# ── 이름 ─────────────────────────────────────────────────────────────────
G_NC = 'm5/kill_resume_gate_not_confirmed.json'
G_W = 'm5/kill_resume_gate_waiting.json'
G_TU = 'm5/kill_resume_gate_time_unknown.json'
G_R = 'm5/kill_resume_gate_ready.json'
G_IP = 'm5/kill_resume_gate_in_progress.json'
G_CU = 'm5/kill_resume_gate_condition_unmet.json'
G_L = 'm5/kill_resume_gate_locked.json'
P_W = 'm5/pledge_written.json'
P_NW = 'm5/pledge_not_written.json'
P_EW = 'm5/pledge_edit_window.json'
RES = 'm5/safety_action_results.json'
RCP = 'm5/kill_checklist_receipts.json'

GATES = [G_NC, G_W, G_TU, G_R, G_IP, G_CU, G_L]
PLEDGES = [P_W, P_NW, P_EW]
VMS = GATES + PLEDGES
NEW_FILES = VMS + [RES, RCP]
REVISED = 'safety_states.json'
REV_OLD = '"ramp_level": "L0"'
REV_NEW = '"ramp_level": "L1"'

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.21.0',
    'generated_at': '2026-11-15T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261115,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(observed, trade_date, label):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': label}


# §5-1 조각(빈칸 = null).
AS_NC = as_of('2026-11-16T02:00:00Z', '2026-11-16', '안전 기준 2026-11-16 11:00')
AS_W = as_of('2026-11-17T12:00:00Z', '2026-11-17', '안전 기준 2026-11-17 21:00')
AS_R = as_of('2026-11-18T06:00:00Z', '2026-11-18', '안전 기준 2026-11-18 15:00')
AS_RC = as_of('2026-11-16T05:05:00Z', '2026-11-16', '명령 기준 2026-11-16 14:05')
AS_P = as_of('2026-11-16T03:00:00Z', '2026-11-16', '서약 기준 2026-11-16 12:00')
AS_PD = as_of('2026-12-03T03:00:00Z', '2026-12-03', '서약 기준 2026-12-03 12:00')

# ── 엔진 글자(core `safety/kill_switch.dart` killSwitchViewOf :149-165 · `safety_text.dart` COOLDOWN :267-292) ──
HEAD = '킬스위치 작동 중 — 신규 주문을 막고 있습니다'
NOT_CONFIRMED = '체크리스트를 먼저 마치십시오 — 마친 때부터 48시간을 셉니다'
ETA_WAIT = '해제 가능 예정 11-18 14:00'                 # 확인 11-16 14:00 KST + 48h
ETA_UNKNOWN = '서버 시각을 확인하지 못해 해제 시각을 셀 수 없습니다'
ETA_READY = '해제 가능 — 재개 체크리스트를 진행하십시오'
CONFIRMED_AT = '체크리스트 확인 11-16 14:00'           # 엔진 «체크리스트 확인 MM-dd HH:mm»


def gauge(normalized, value_text):
    return {'code': 'COOLDOWN', 'label': '냉각 기간', 'normalized': normalized, 'value_text': value_text}


G_WAIT = gauge(0.65, '남은 17시간')    # 확인 11-16 14:00 · 관측 11-17 21:00 = 31h 경과 · 남은 시간 올림 = 17
G_UNK = gauge(0.0, '신뢰 시각 확인 중')
G_DONE = gauge(1.0, '냉각 완료')

# ── SPEC v2.40 04 §3-6 «재개판» 7문항(정규화 K38 · 출처 = 설계 저장소 06_시스템설계/04_안전장치.md :701-707) ──
LABELS = [
    '그때 적은 «규칙이 지시한 행동»을 다시 읽었다 — 지금 규칙은 무엇을 지시하는가',
    '그때의 감정 · 수면 기록을 다시 읽었다 — 지금 상태(감정 · 강도 · 수면)는',
    '그때 짚은 시나리오가 지금 어떻게 됐는가',
    '그때 적은 재개 조건이 지금 충족됐는가',
    '발동 동안 생긴 일(미체결 취소 결과 · 체결 · 남은 UNKNOWN)을 확인했다',
    '확인 시각부터 48h 가 지났음을 확인했다',
    '재개 저널을 썼다 — 사전 필드 3 · decision_id',
]
UNMET_TEXT = '미충족이면 재개하지 않는다'   # SPEC 같은 표 «막는가» 열(4번)


def choice(label, scenario=None, condition=None):
    return {'label': label, 'scenario': scenario, 'condition': condition}


CH3 = [choice('해소됨', 'RESOLVED'), choice('진행 중', 'ONGOING'), choice('해당 없었음', 'NOT_APPLICABLE')]
CH4 = [choice('충족', condition='MET'), choice('미충족', condition='UNMET')]

# 발동 때 답 재생(합성 · 6번 = 엔진 글자 꼴 · 7번 = null).
REPLAY = [
    '그때 적은 행동: 신규 진입을 멈추고 규칙 W3 를 다시 읽는다',
    '그때: 불안 · 강도 7 · 수면 4시간',
    '그때 짚은 시나리오: W3',
    '그때 적은 재개 조건: 급락 뉴스가 정리되고 체결 오류가 0 이다',
    '그때 고른 범위: 신규 진입 차단만',
    CONFIRMED_AT,
    None,
]
ANSWERS = [
    '지금 규칙: 신규 진입 차단 유지 · 월말 계획대로',
    '지금: 담담 · 강도 2 · 수면 7시간',
    '해소됨',
    '미충족',
]
LOCKED = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'   # v1.20 표본과 같은 글자
PL = [
    '합성 서약 1 — 정해진 날에만 규칙대로 주문한다.',
    '합성 서약 2 — 하락 구간에서 규칙을 바꾸지 않는다.',
    '합성 서약 3 — 킬스위치를 누른 뒤에는 체크리스트부터 마친다.',
]

GATE_KEYS = ['readiness_label', 'level', 'eta_text', 'cooldown', 'items', 'next_item_no', 'blocked_text',
             'locked_label', 'as_of']
ROW_KEYS = ['item_no', 'label', 'replay_text', 'answered_text', 'level', 'choices']
CHOICE_KEYS = ['label', 'scenario', 'condition']
PLEDGE_KEYS = ['lines', 'status_line', 'replay_notice', 'editable', 'locked_label', 'as_of']
RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']
RECEIPT_KEYS = ['command_id', 'kind', 'state', 'state_label', 'requested_at', 'expires_at', 'nonce',
                'issued_by_device_id']


def row(n, replay, answered, level):
    ch = CH3 if n == 3 else CH4 if n == 4 else []
    return dict(zip(ROW_KEYS, [n, LABELS[n - 1], replay, answered, level, copy.deepcopy(ch)]))


def gate(level, eta, cooldown, items, next_no, blocked, locked, a):
    return dict(zip(GATE_KEYS, [HEAD, level, eta, copy.deepcopy(cooldown), items, next_no, blocked, locked,
                                copy.deepcopy(a)]))


def pledge(lines, editable, a):
    return dict(zip(PLEDGE_KEYS, [list(lines), None, None, editable, None, copy.deepcopy(a)]))


def build_vms():
    rows_none = [row(n, None, None, 'INFO') for n in range(1, 8)]
    rows_replay = [row(n, REPLAY[n - 1], None, 'INFO') for n in range(1, 8)]
    vms = {
        G_NC: gate('ACT', None, None, rows_none, None, NOT_CONFIRMED, None, AS_NC),
        G_W: gate('WATCH', ETA_WAIT, G_WAIT, rows_replay, None, None, None, AS_W),
        G_TU: gate('BLOCKED', ETA_UNKNOWN, G_UNK, copy.deepcopy(rows_replay), None, None, None, AS_W),
        G_R: gate('INFO', ETA_READY, G_DONE, copy.deepcopy(rows_replay), 1, None, None, AS_R),
    }
    ip = copy.deepcopy(vms[G_R])
    for i in range(3):
        ip['items'][i]['answered_text'] = ANSWERS[i]
        ip['items'][i]['level'] = 'OK'
    ip['next_item_no'] = 4
    vms[G_IP] = ip
    cu = copy.deepcopy(ip)
    cu['items'][3]['answered_text'] = ANSWERS[3]
    cu['items'][3]['level'] = 'BLOCKED'
    cu['level'] = 'BLOCKED'
    cu['next_item_no'] = None
    cu['blocked_text'] = UNMET_TEXT
    vms[G_CU] = cu
    lk = copy.deepcopy(vms[G_R])
    lk['next_item_no'] = None
    lk['locked_label'] = LOCKED
    vms[G_L] = lk
    vms[P_W] = pledge(PL, False, AS_P)
    vms[P_NW] = pledge([], False, AS_P)
    vms[P_EW] = pledge(PL, True, AS_PD)
    return vms


def result(n, id_, level, headline, reason=None):
    return dict(zip(RESULT_KEYS, ['ar_m5_%02d' % n, id_, level, headline, reason, None, False]))


def build_results():
    kr, pw, pe = 'KILL_SWITCH_RESUME', 'PLEDGE_WRITE', 'PLEDGE_EDIT'
    return [
        result(1, kr, 'OK', '재개 체크리스트 7번까지 마쳤습니다 — 킬스위치를 풀었습니다. 다음 회차부터 규칙대로 움직입니다.'),
        result(2, kr, 'INFO', '3번 답을 받았습니다 — 4번으로 넘어갑니다.'),
        result(3, kr, 'WATCH', '아직 기다리는 중입니다 — 해제 가능 예정 11-18 14:00.', 'RESUME_TOO_SOON'),
        result(4, kr, 'ACT', '2번 칸이 비었습니다 — 감정 · 강도 · 수면을 모두 적으십시오.', 'RESUME_ITEM_MISSING'),
        result(5, kr, 'ACT', '앞 문항을 먼저 마치십시오 — 지금 차례는 4번입니다.', 'RESUME_ITEM_OUT_OF_ORDER'),
        result(6, kr, 'BLOCKED', '재개 조건이 충족되지 않았습니다 — 재개하지 않습니다.', 'RESUME_CONDITION_UNMET'),
        result(7, kr, 'BLOCKED', '서버 시각을 확인하지 못해 재개를 막았습니다.', 'RESUME_TRUSTED_TIME_UNKNOWN'),
        result(8, kr, 'ACT', '발동 뒤 체크리스트를 먼저 마치십시오.', 'RESUME_CHECKLIST_NOT_CONFIRMED'),
        result(9, kr, 'BLOCKED', '생체 확인을 할 수 없어 진행하지 않았습니다.', BIOMETRIC),
        result(10, pw, 'OK', '서약 첫 판을 저장했습니다.'),
        result(11, pw, 'ACT', '세 문장을 모두 적어야 저장합니다.', 'PLEDGE_SENTENCES_MISSING'),
        result(12, pe, 'WATCH', '서약은 12월에만 고칠 수 있습니다 — 지금 판을 그대로 둡니다.', 'PLEDGE_OUT_OF_WINDOW'),
        result(13, pe, 'INFO', '지금 판과 같습니다 — 새 판을 만들지 않았습니다.', 'PLEDGE_UNCHANGED'),
        result(14, pe, 'BLOCKED', '서버 시각을 확인하지 못해 저장하지 않았습니다.', 'TRUSTED_TIME_UNKNOWN'),
    ]


def receipt(n, state, label, reject=None):
    out = dict(zip(RECEIPT_KEYS, ['cmd_kc_%02d' % n, 'KILL_CHECKLIST_CONFIRM', state, label, '2026-11-16T05:00:00Z',
                                  '2026-11-16T05:30:00Z', 'n_kc5d0e2a7b%02d' % n, 'dev_operator_01']))
    if reject is not None:
        out['reject_reason_code'] = reject
    return out


def build_receipts():
    return [
        receipt(1, 'EXECUTED', '확인됨 — 지금부터 48시간을 셉니다'),
        receipt(2, 'REJECTED', '거부됨 — 7항목 중 빈칸이 있습니다. 입력값은 그대로 남아 있습니다',
                'KILL_CHECKLIST_ITEM_MISSING'),
        receipt(3, 'REJECTED', '거부됨 — 확인 3항목을 모두 체크하십시오', 'KILL_ACK_INCOMPLETE'),
        receipt(4, 'REJECTED', '거부됨 — 엔진이 본 미체결 주문이 남아 있습니다. 다시 조회하십시오', 'KILL_ACK_MISMATCH'),
        receipt(5, 'REJECTED', '거부됨 — 킬스위치가 꺼져 있습니다', 'KILL_SWITCH_NOT_ACTIVE'),
        receipt(6, 'REJECTED', '거부됨 — 서버 시각을 확인하지 못했습니다. 잠시 뒤 다시 확인하십시오', 'TRUSTED_TIME_UNKNOWN'),
        receipt(7, 'REJECTED', '거부됨 — 저널 번호가 이미 쓰였습니다', 'JOURNAL_ID_TAKEN'),
    ]


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_r7_v120_fixtures.py 와 같은 꼴)
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


def base_text(rel):
    return _BASE_CACHE[rel]


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def envelope(rows, env_as_of):
    """봉투(v1.15~v1.20 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def new_files(vms, results, receipts):
    texts = {}
    for rel, vm in vms.items():
        texts[rel] = ser_envelope(envelope([vm], vm['as_of']), False)
    texts[RES] = ser_envelope(envelope(results, AS_R), True)
    texts[RCP] = ser_envelope(envelope(receipts, AS_RC), True)
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


def levels(v):
    if isinstance(v, dict):
        for k, x in v.items():
            if k == 'level':
                yield x
            yield from levels(x)
    elif isinstance(v, list):
        for x in v:
            yield from levels(x)


def gauges(v):
    """`release_progress[]` 원소 · `cooldown` 객체(C-55 ⑭ 와 같은 걷기)."""
    if isinstance(v, dict):
        for k, x in v.items():
            if k == 'release_progress' and isinstance(x, list):
                yield from x
            elif k == 'cooldown' and isinstance(x, dict):
                yield x
            yield from gauges(x)
    elif isinstance(v, list):
        for x in v:
            yield from gauges(x)


def ramp_levels(v):
    if isinstance(v, dict):
        for k, x in v.items():
            if k == 'ramp_level':
                yield x
            yield from ramp_levels(x)
    elif isinstance(v, list):
        for x in v:
            yield from ramp_levels(x)


CHECKS = (('금지어', FORBIDDEN), ('개발자 메모', DEV_MEMO), ('계좌꼴', ACCOUNT_LIKE), ('전화번호 꼴', PHONE),
          ('앱키 꼴', LONG_ALNUM), ('URL 꼴', URL_LIKE), ('손익 낱말', PNL_WORD), ('금액 글자', MONEY),
          ('8자리 숫자', LONG_DIGITS), ('카운트다운·해제 버튼', COUNTDOWN))


def self_check_file(rel, s, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    # 🔴 전 표본 — 게이지 코드 ∈ 사전(C-55 ⑭) · ramp_level ≠ L0(F3 · C-55 ⑲).
    for g in gauges(env):
        assert g['code'] in GAUGE_CODES, (rel, g)
    for r in ramp_levels(env):
        assert r != 'L0', rel
    if new:
        assert env['meta']['mode'] == 'LIVE', rel
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        assert env['as_of'].get('stale_label') is None, rel
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            for name, rx in CHECKS:
                assert not rx.search(v), '%s %s — %s: %s' % (rel, path, name, v)
            assert 'DRY_RUN' not in v, (rel, path, v)
            assert not v.startswith('aaq://'), (rel, path, v)                       # 링크 0
        ks = set(keys(env['rows']))
        assert not any(PNL_KEY.search(k) for k in ks), rel
        if rel in VMS:
            for bad in BAD_KEYS + ('rows',):
                assert bad not in ks, (rel, bad)
    return env


def check_gate(rel, vm):
    assert list(vm) == GATE_KEYS, rel
    assert vm['readiness_label'] == HEAD, rel
    items = vm['items']
    assert [r['item_no'] for r in items] == list(range(1, 8)), rel
    assert [r['label'] for r in items] == LABELS, rel
    for r in items:
        assert list(r) == ROW_KEYS, rel
        want = CH3 if r['item_no'] == 3 else CH4 if r['item_no'] == 4 else []
        assert r['choices'] == want, rel
        for c in r['choices']:
            assert list(c) == CHOICE_KEYS and (c['scenario'] is None) != (c['condition'] is None), rel
    answered = [r['answered_text'] is not None for r in items]
    n_ans = sum(answered)
    assert answered == [True] * n_ans + [False] * (7 - n_ans), rel
    assert vm['next_item_no'] in (None,) + tuple(range(1, 8)), rel
    if vm['next_item_no'] is not None:
        assert vm['next_item_no'] == n_ans + 1, rel
        assert vm['blocked_text'] is None and vm['locked_label'] is None, rel
    if vm['locked_label'] is not None:
        assert vm['next_item_no'] is None, rel
    replays = [r['item_no'] for r in items if r['replay_text'] is not None]
    assert set(replays) <= set(range(1, 7)), rel
    assert items[6]['replay_text'] is None, rel
    if vm['cooldown'] is not None:
        assert vm['cooldown']['code'] == 'COOLDOWN', rel
    assert set(levels(vm)) <= LEVELS, rel


def check_pledge(rel, vm):
    assert list(vm) == PLEDGE_KEYS, rel
    assert len(vm['lines']) in (0, 3), rel
    if vm['editable']:
        assert len(vm['lines']) == 3, rel
    if vm['locked_label'] is not None:
        assert vm['editable'] is False, rel
    assert vm['status_line'] is None and vm['replay_notice'] is None, rel
    for i, line in enumerate(vm['lines']):
        assert re.match(r'^합성 서약 %d — ' % (i + 1), line), (rel, line)


def without(vm, *names):
    out = copy.deepcopy(vm)
    for n in names:
        out.pop(n)
    return out


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert not any(r.startswith('m5/') for r in rels), 'BASE 에 m5/ 가 이미 있다'
    assert REVISED in rels
    assert len(NEW_FILES) == 12 and len(set(NEW_FILES)) == 12

    vms = build_vms()
    results = build_results()
    receipts = build_receipts()
    out = new_files(vms, results, receipts)
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)
    assert out[REVISED].count(REV_OLD) == 1, REVISED
    out[REVISED] = out[REVISED].replace(REV_OLD, REV_NEW, 1)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    vm = {rel: envs[rel]['rows'][0] for rel in VMS}
    for rel in VMS:
        assert len(envs[rel]['rows']) == 1, rel
        assert vm[rel]['as_of'] == envs[rel]['as_of'], rel
    for rel in GATES:
        check_gate(rel, vm[rel])
    for rel in PLEDGES:
        check_pledge(rel, vm[rel])
    # 게이트 갈래(§5-2 · C-55 ⑥~⑨).
    assert set().union(*(set(levels(vm[r])) for r in GATES)) == LEVELS
    assert {r for r in GATES if vm[r]['locked_label'] is not None} == {G_L}
    assert {r: vm[r]['next_item_no'] for r in GATES if vm[r]['next_item_no'] is not None} == {G_R: 1, G_IP: 4}
    assert vm[G_NC]['cooldown'] is None and vm[G_NC]['eta_text'] is None and vm[G_NC]['blocked_text'] == NOT_CONFIRMED
    assert all(r['replay_text'] is None for r in vm[G_NC]['items'])
    for r in (G_W, G_R):
        assert sum(1 for x in vm[r]['items'] if x['replay_text'] is not None) == 6, r
    assert 0 < vm[G_W]['cooldown']['normalized'] < 1 and vm[G_TU]['cooldown']['normalized'] == 0
    assert vm[G_R]['cooldown']['normalized'] == 1
    assert vm[G_CU]['items'][3]['level'] == 'BLOCKED' and vm[G_CU]['blocked_text'] == UNMET_TEXT
    assert without(vm[G_L], 'next_item_no', 'locked_label') == without(vm[G_R], 'next_item_no', 'locked_label')
    # 서약 갈래.
    assert vm[P_NW]['lines'] == [] and vm[P_EW]['editable'] is True and vm[P_W]['editable'] is False
    # 결과 — id 전수 · 사전 · 묶음마다 레벨 5값 · 넘김·재시도 0.
    rs = envs[RES]['rows']
    assert len(rs) == 14 and all(list(r) == RESULT_KEYS for r in rs)
    assert {r['id'] for r in rs} == SAFETY_IDS
    assert all(r['handoff_route'] is None and r['retryable'] is False for r in rs)
    resume = [r for r in rs if r['id'] == 'KILL_SWITCH_RESUME']
    pledge_rows = [r for r in rs if r['id'] != 'KILL_SWITCH_RESUME']
    assert {r['level'] for r in resume} == LEVELS and {r['level'] for r in pledge_rows} == LEVELS
    for r in resume:
        assert r['reason_code'] is None or r['reason_code'] in RESUME_ROW_CODES, r
    for r in pledge_rows:
        assert r['reason_code'] is None or r['reason_code'] in PLEDGE_ROW_CODES, r
    # 접수증 — kind 하나 · 거부 사유 = 킬스위치 ∪ 공용 6 · 재개 코드 0.
    cs = envs[RCP]['rows']
    assert len(cs) == 7 and {c['kind'] for c in cs} == {'KILL_CHECKLIST_CONFIRM'}
    assert {c.get('reject_reason_code') for c in cs if c['state'] == 'REJECTED'} == RECEIPT_REJECTS
    assert all('reject_reason_code' not in c for c in cs if c['state'] != 'REJECTED')
    assert sum(1 for c in cs if c['state'] == 'EXECUTED') >= 1

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    assert n_version_only == BASE_FILES - 1, n_version_only

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_v121_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 1 · 신설 %d) · contract 1.21.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
