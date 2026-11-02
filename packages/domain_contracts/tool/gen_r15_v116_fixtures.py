#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.16(R15 선행 M2 보강 · 01 §25) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r15_v116_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r14_v115_fixtures.py(계약 v1.15 · 그 스크립트는 v1.15 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-03_R15선행_계약v1.16_설계서.md` §5 · 187 → 219 = 신설 32 · 개정 6 · 버전 줄만 181)
  (a) 전 봉투의 "contract_version": "1.15.0" → "1.16.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 6 —
      · `OnboardingStep` 표본 5(onboarding_fresh · onboarding_reconnect · m8/onboarding_finish ·
        m8/onboarding_fresh_advisory · m8/restart_lost_phone) — 행마다 `requirement_label`(등급 사전 1벌) ·
        `verified_until` 있는 행 `verified_until_text`(KST 날짜 + «까지» · EXPIRED 면 «에 만료됨») · 키 = 행 끝 ·
        🔴 `onboarding_fresh` 에 `gate` 를 넣지 않는다(C-15 `state` 축 walk · 설계서 G20).
      · m8/onboarding_mode_pick — `explain_line` 의 «권장» 낱말 정정(G4 · K14).
  (c) 신설 32 — R15a 7(O-00 · O-00b · 선택 결과) · R15b 10(O-01 목록 6 · O-02 상세 3 · 검증 결과) ·
      R15c 8(O-04 마무리 7 · DRY_RUN 결과) · R15d 7(R-01 4 · V-01 3).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 발주자 결정(2026-11-03 · ①~④) — VM 에 asOf 칸 0(봉투 `as_of` 만) · 링크 = `*DeepLink`/`LinkAction` ·
   «어디서 받나» = `where_text` 글자 · 체크섬 = M9 슬롯 · 시작 상태 선언 = ⑥ 단계 `link` 두 갈래 · X1 두 라우트.

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r15_v116_fixtures.py
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
# 계약 1.15.0 · 픽스처 187 의 기준 커밋(origin/main · R14 test-only 기록 — 계약 패키지 = PR #89 이후 무변경).
BASE = '267e867e9a68b2c7961ce7817dadb7c98dd8019f'

OLD_VER = '"contract_version": "1.15.0"'
NEW_VER = '"contract_version": "1.16.0"'
BASE_FILES = 187
WANT_FILES = 219

RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
RECOMMEND = re.compile(r'권장|추천')                      # K14 — O-00·O-00b 표본 + mode_pick
DEV_MEMO = re.compile(r'화면이|화면은|화면·')              # 사용자 문장 자리의 개발자 메모(H50)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6
OVERSEAS = re.compile(r'해외')                            # K17
STEP_ID = re.compile(r'^[orv]_[0-9]{2}[a-z]?$')           # K28
FIXED_SEGMENTS = {'start', 'mode', 'steps', 'finish', 'restart', 'pairing'}
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']

# ── 라우트(lib/src/navigation/app_links.dart 와 같은 글자 — C-33 ① 이 등록을 다시 본다) ──
R_MODE = 'aaq://onboarding/mode'
R_STEPS = 'aaq://onboarding/steps'
R_FINISH = 'aaq://onboarding/finish'
R_RESTART = 'aaq://onboarding/restart'
R_PAIRING = 'aaq://onboarding/pairing'
R_SIM_CASH = 'aaq://m5/sim-opening-cash'
R_SIM_LEDGER = 'aaq://ledger/sim-opening/'
R_X1_PLAN = 'aaq://x1/migration/plan'
R_X1_EMERGENCY = 'aaq://x1/migration/emergency'
R_HOLDINGS = 'aaq://holdings/overview'


def step_link(sid):
    return 'aaq://onboarding/' + sid


# ── 이름 ─────────────────────────────────────────────────────────────────
FRESH = 'onboarding_fresh.json'
RECONNECT = 'onboarding_reconnect.json'
FINISH_OLD = 'm8/onboarding_finish.json'
FRESH_ADV = 'm8/onboarding_fresh_advisory.json'
RESTART_OLD = 'm8/restart_lost_phone.json'
MODE_PICK = 'm8/onboarding_mode_pick.json'
STEP_REVISED = [FRESH, RECONNECT, FINISH_OLD, FRESH_ADV, RESTART_OLD]
REVISED = STEP_REVISED + [MODE_PICK]

START = 'm8/onboarding_start.json'
START_NV = 'm8/onboarding_start_no_viewer.json'
M_UNSEL = 'm8/onboarding_mode_unselected.json'
M_AUTO = 'm8/onboarding_mode_auto.json'
M_ADV = 'm8/onboarding_mode_advisory.json'
M_LOCK = 'm8/onboarding_mode_locked.json'
M_RES = 'm8/onboarding_mode_select_results.json'
S_FRESH = 'm8/onboarding_steps_fresh.json'
S_ADV = 'm8/onboarding_steps_advisory.json'
S_READY = 'm8/onboarding_steps_finish_ready.json'
S_WARN = 'm8/onboarding_steps_finish_ready_warn.json'
S_LOCK = 'm8/onboarding_steps_all_verified_locked.json'
S_EMPTY = 'm8/onboarding_steps_empty.json'
D_KIS = 'm8/onboarding_step_detail_kis_mock.json'
D_NOV = 'm8/onboarding_step_detail_no_verify.json'
D_MISS = 'm8/onboarding_step_detail_missing.json'
V_RES = 'm8/onboarding_verify_results.json'
F_AUTO = 'm8/onboarding_finish_auto.json'
F_AUTO_R = 'm8/onboarding_finish_auto_ready.json'
F_AUTO_D = 'm8/onboarding_finish_auto_declared.json'
F_ADV = 'm8/onboarding_finish_advisory.json'
F_ADV_D = 'm8/onboarding_finish_advisory_declared.json'
F_NOEXP = 'm8/onboarding_finish_no_expectation.json'
F_DONE = 'm8/onboarding_finish_done.json'
F_RES = 'm8/onboarding_finish_results.json'
R_LOST = 'm8/restart_vm_lost_phone.json'
R_OUT = 'm8/restart_vm_logged_out.json'
R_GAP7 = 'm8/restart_vm_gap7.json'
R_UNK = 'm8/restart_vm_unknown.json'
P_WAIT = 'm8/pairing_waiting.json'
P_OK = 'm8/pairing_ok.json'
P_FAIL = 'm8/pairing_fail.json'

STARTS = [START, START_NV]
MODES = [M_UNSEL, M_AUTO, M_ADV, M_LOCK]
STEPS = [S_FRESH, S_ADV, S_READY, S_WARN, S_LOCK, S_EMPTY]
DETAILS = [D_KIS, D_NOV, D_MISS]
FINISHES = [F_AUTO, F_AUTO_R, F_AUTO_D, F_ADV, F_ADV_D, F_NOEXP, F_DONE]
RESTARTS = [R_LOST, R_OUT, R_GAP7, R_UNK]
PAIRINGS = [P_WAIT, P_OK, P_FAIL]
RESULTS = [M_RES, V_RES, F_RES]
VMS = STARTS + MODES + STEPS + DETAILS + FINISHES + RESTARTS + PAIRINGS
NEW_FILES = VMS + RESULTS
R15A = STARTS + MODES + [M_RES]

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.16.0',
    'generated_at': '2026-11-03T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261103,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}
ONB_AS_OF = {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
             'stale_after_seconds': 93600, 'label': '온보딩 기준 2026-08-31'}

# ── 공용 글자(§5-0) ───────────────────────────────────────────────────────
MODE_HEAD = '운영 방식을 고르십시오. 고른 방식에 따라 다음 준비물 목록이 달라집니다.'
GAP_NOTICE = '투자 안내에서는 앱이 계좌를 읽지 못하므로, 기록하지 않은 매매는 시스템이 알 수 없습니다.'
HONESTY = ('규칙을 지켰을 때의 기대치는 전 계좌 세후 10.2% 안팎(최악 9.7%)입니다. 규칙 없이 사서 들고만 있었을 때'
           '(8.38% · 최대 낙폭 −35.05%)와 비교해 연 +2.75%p · 낙폭 22.5%p 차이가 규칙의 값입니다. '
           '투자 안내에서는 그 값을 지키는 주체가 사람입니다.')
LOCKED = '온보딩을 마쳐 운영 방식이 확정되었습니다. 바꾸려면 설정의 전환 절차를 거칩니다.'
WARN = '권장 단계가 남았습니다 — 진행은 막지 않습니다'
REQ_LABEL = {'REQUIRED': '필수', 'RECOMMENDED': '권장', 'OPTIONAL': '선택'}
MODE_PICK_OLD = '둘 중 하나를 고르셔야 다음으로 갑니다. 권장 표시는 없습니다.'
MODE_PICK_NEW = '둘 중 하나를 고르셔야 다음으로 갑니다. 어느 쪽도 미리 골라 두지 않았습니다.'


def gate(code, label, state):
    return {'code': code, 'label': label, 'state': state, 'blocked_reason_code': None}


G_PASS = gate('STEP_OPEN', '열렸습니다', 'PASS')
G_BLOCK = gate('STEP_ORDER', '앞 단계(모의 앱키)가 끝나야 열립니다', 'BLOCK')
G_UNK_CONN = gate('CONNECTION_STATE', '연결 상태를 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다', 'UNKNOWN')
G_NA = gate('TRACK_SCOPE', '자동 매매에서는 필요하지 않습니다', 'NOT_APPLICABLE')
G_UNK_LEDGER = gate('DEVICE_LEDGER', '기기 원장을 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다', 'UNKNOWN')

# ── 단계 행(§5-2 · 키 = `OnboardingStep` 선언 차례 · null 도 적는다) ─────────────────
STEP_KEYS = ['step_id', 'track', 'order', 'title', 'why_line', 'where_deep_link', 'estimated_seconds',
             'estimated_text', 'requirement', 'state', 'verification_label', 'verified_until', 'failure_reason_code',
             'requirement_label', 'warning_label', 'verified_until_text', 'failure_text', 'gate', 'detail_deep_link']


def until_text(until, state):
    """`verified_until`(UTC) → KST 날짜 글자. 표본 시각은 전부 자정 UTC(= KST 09:00 같은 날)."""
    if until is None:
        return None
    assert until.endswith('T00:00:00Z'), until
    day = until[:10]
    return day + ('에 만료됨' if state == 'EXPIRED' else '까지')


def step(sid, order, title, why, secs, est, req, state, ver=None, until=None, fcode=None, ftext=None,
         warn=False, gate_=None, link=True):
    row = {
        'step_id': sid, 'track': 'FRESH', 'order': order, 'title': title, 'why_line': why,
        'where_deep_link': None, 'estimated_seconds': secs, 'estimated_text': est, 'requirement': req,
        'state': state, 'verification_label': ver, 'verified_until': until, 'failure_reason_code': fcode,
        'requirement_label': REQ_LABEL[req], 'warning_label': WARN if warn else None,
        'verified_until_text': until_text(until, state), 'failure_text': ftext,
        'gate': copy.deepcopy(gate_), 'detail_deep_link': step_link(sid) if link else None,
    }
    assert list(row) == STEP_KEYS
    return row


def with_(row, **kw):
    out = copy.deepcopy(row)
    for k, v in kw.items():
        assert k in out, k
        out[k] = v
    return out


F2_TITLE = 'KIS 모의 앱키 등록'
F2_WHY = '시세와 모의 주문에 쓰는 키입니다. 실전 키는 지금 넣지 않습니다.'
F3_TITLE = '계좌 매핑 · 절세계좌 판정'
F3_WHY = '슬리브와 계좌를 잇고 절세계좌 판정을 한 번 통과합니다.'
KIS_VER = '토큰 발급 + 모의 잔고 조회 1회'

F1 = step('o_01', 1, '기기 등록', '이 폰을 운영 기기로 등록합니다.', 180, '약 3분', 'REQUIRED', 'VERIFIED',
          ver='이 폰을 운영 기기로 등록함', until='2026-11-30T00:00:00Z')
F2 = step('o_02', 2, F2_TITLE, F2_WHY, 900, '약 15분', 'REQUIRED', 'IN_PROGRESS', ver=KIS_VER, gate_=G_PASS)
F3 = step('o_03', 3, F3_TITLE, F3_WHY, 600, '약 10분', 'REQUIRED', 'NOT_STARTED', gate_=G_BLOCK)
F4 = step('o_05', 4, '알림 권한', '안내와 경보를 놓치지 않게 합니다.', 120, '약 2분', 'RECOMMENDED', 'FAILED',
          fcode='PERMISSION_DENIED', ftext='알림 권한이 꺼져 있습니다. 휴대폰 설정에서 켠 뒤 다시 확인하십시오.', warn=True)
F5 = step('o_06', 5, '배터리 최적화 예외', '새벽 배치가 잠들지 않게 합니다.', 240, '약 4분', 'RECOMMENDED', 'NOT_STARTED',
          warn=True)
F6 = step('o_07', 6, 'Supabase 연결', '다른 기기가 읽을 기록을 올립니다.', 600, '약 10분', 'REQUIRED', 'NOT_STARTED',
          gate_=G_UNK_CONN)
F7 = step('o_08', 7, 'GitHub 데이터 저장소', '매일 기록을 보관합니다.', 600, '약 10분', 'REQUIRED', 'EXPIRED',
          ver='토큰으로 빈 커밋 1회', until='2026-08-30T00:00:00Z', fcode='TOKEN_EXPIRED',
          ftext='저장소 토큰이 만료되었습니다. 새로 발급해 다시 검증하십시오.')
F8 = step('o_09', 8, '알림 채널 · 워치독 채널', '안내를 못 받는 것도 사고입니다.', 480, '약 8분', 'REQUIRED', 'NOT_STARTED')
F9 = step('o_10', 9, 'healthchecks.io 연결', '폰이 멈추면 바깥에서 알려 줍니다.', 300, '약 5분', 'REQUIRED', 'NOT_STARTED')
F10 = step('o_11', 10, 'Android 권한 실측', '상시 알림 5분 생존과 정확 알람 1회를 확인합니다.', 420, '약 7분', 'REQUIRED',
           'NOT_STARTED')
F11 = step('o_12', 11, 'KIS 대사 전용 키', '잔고 대조에만 쓰는 키입니다.', 600, '약 10분', 'OPTIONAL', 'NOT_STARTED',
           gate_=G_NA)
F12 = step('o_13', 12, 'Google 캘린더(선택)', '일정에 기록을 남깁니다.', 300, '약 5분', 'OPTIONAL', 'NOT_STARTED',
           link=False)
A2 = step('o_02', 2, 'KIS 모의 앱키(시세)', '수기 기록의 가격 범위 검증에 시세가 필요합니다.', 900, '약 15분', 'REQUIRED',
          'NOT_STARTED')
A4 = step('o_12', 4, 'KIS 대사 전용 키', '등록하지 않으면 원장 신뢰 등급이 자기 보고로 고정됩니다. 진행은 막지 않습니다.', 600,
          '약 10분', 'RECOMMENDED', 'NOT_STARTED', warn=True)
A10 = step('o_11', 10, 'Android 권한 실측', '무인 발주가 없어 위험이 낮지만, 배치가 안 돌면 안내도 나오지 않습니다.', 420,
           '약 7분', 'RECOMMENDED', 'NOT_STARTED', warn=True)
R2 = step('o_02', 2, F2_TITLE, F2_WHY, 900, '약 15분', 'REQUIRED', 'VERIFIED', ver=KIS_VER,
          until='2026-09-01T00:00:00Z')
R3 = step('o_03', 3, F3_TITLE, F3_WHY, 600, '약 10분', 'REQUIRED', 'VERIFIED', ver='절세계좌 판정 1회 통과')

STEPS_FRESH_ROWS = [F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12]
STEPS_ADV_ROWS = [
    F1, A2, with_(F3, gate=None), A4,
    with_(F4, order=5, state='NOT_STARTED', failure_reason_code=None, failure_text=None),
    with_(F6, gate=None),
    with_(F7, state='NOT_STARTED', verification_label=None, verified_until=None, verified_until_text=None,
          failure_reason_code=None, failure_text=None),
    F8, F9, A10,
]


def steps_vm(progress, rows, empty=None, finish=None):
    return {'progress_text': progress, 'rows': copy.deepcopy(rows), 'empty_label': empty, 'finish_deep_link': finish}


# ── O-00 · O-00b(§5-1) ────────────────────────────────────────────────────
def track(t, title, est, link):
    return {'track': t, 'title': title, 'estimated_text': est, 'deep_link': link}


T_FRESH = track('FRESH', '처음 시작하기', '약 60~90분', R_MODE)
T_RECON = track('RECONNECT', '기존 계정에서 다시 시작하기', '약 15분 + 대기', R_RESTART)
T_VIEWER = track('VIEWER_PAIRING', '이 폰은 조회만 할 거예요', 'QR 스캔 약 2분', R_PAIRING)
START_HEAD = '이 폰을 어떻게 쓸지 고르십시오.'


def mode_vm(options, selected=None, next_link=None, locked=None):
    return {'headline': MODE_HEAD, 'options': copy.deepcopy(options), 'selected': selected,
            'record_gap_notice': GAP_NOTICE, 'honesty_text': HONESTY, 'next_deep_link': next_link,
            'locked_label': locked}


RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']


def result(run_id, aid, level, headline, code=None, retryable=False):
    return dict(zip(RESULT_KEYS, [run_id, aid, level, headline, code, None, retryable]))


MODE_RESULTS = [
    result('ar_onb_0001', 'ONBOARDING_OPERATING_MODE_SELECT', 'OK', '운영 방식을 기록했습니다. 다음 단계 목록이 바뀝니다.'),
    result('ar_onb_0002', 'ONBOARDING_OPERATING_MODE_SELECT', 'BLOCKED',
           '온보딩을 마쳐 여기서는 바꿀 수 없습니다. 바꾸려면 설정의 전환 절차를 거칩니다.', 'ONBOARDING_CHOICE_COMMITTED'),
]
VERIFY_RESULTS = [
    result('ar_onb_0101', 'CREDENTIAL_VERIFY', 'OK', '토큰 발급과 잔고 조회를 확인했습니다.'),
    result('ar_onb_0102', 'CREDENTIAL_VERIFY', 'BLOCKED', '접근토큰은 1분에 한 번만 발급됩니다. 잠시 뒤 다시 시도하십시오.',
           'EGW00133', True),
    result('ar_onb_0103', 'CREDENTIAL_VERIFY', 'BLOCKED', '앱키가 거절되었습니다. 발급 화면에서 키를 다시 확인하십시오.',
           'CREDENTIAL_REJECTED'),
]
FINISH_RESULTS = [
    result('ar_onb_0401', 'ONBOARDING_DRY_RUN_START', 'OK', '모의 운영을 시작했습니다.'),
    result('ar_onb_0402', 'ONBOARDING_DRY_RUN_START', 'BLOCKED', '시작하지 못해 운영 방식 확정도 함께 되돌렸습니다.',
           'DRY_RUN_START_ROLLED_BACK'),
]

# ── O-02 상세(§5-2) ───────────────────────────────────────────────────────
DETAIL_MISSING = '이 단계는 지금 목록에 없습니다. 단계 목록에서 다시 고르십시오.'


def detail_vm(step_=None, missing=None, where=None, how=None, verify=None, slot=None):
    return {'step': copy.deepcopy(step_), 'missing_label': missing, 'where_text': where, 'how_text': how,
            'verify': copy.deepcopy(verify), 'secret_slot_id': slot}


def action(aid, args, label):
    return {'id': aid, 'args': dict(args), 'label': label}


KIS_VERIFY = action('CREDENTIAL_VERIFY', {'kind': 'KIS_MOCK'}, '검증 실행')
DRY_RUN = action('ONBOARDING_DRY_RUN_START', {}, '모의 운영 시작')

# ── O-04(§5-3 · 키 = `OnboardingFinishStage` 선언 차례) ───────────────────────
STAGE_KEYS = ['title', 'state', 'gate', 'lines', 'expectation_line', 'slot_id', 'link', 'action']


def stage(title, state, lines=(), gate_=None, exp=None, slot=None, link=None, act=None):
    row = {'title': title, 'state': state, 'gate': copy.deepcopy(gate_), 'lines': list(lines),
           'expectation_line': exp, 'slot_id': slot, 'link': copy.deepcopy(link), 'action': copy.deepcopy(act)}
    assert list(row) == STAGE_KEYS
    return row


def link_action(label, deep_link):
    return {'label': label, 'deep_link': deep_link}


T1, T2, T3, T4, T5, T6 = ('P0S 프로파일 확인', '본인 서약문 3문장', '생체 서명', '골든벡터 셀프테스트', '복구 카드 발급',
                          '모의 운영(DRY_RUN) 시작')
S1_LINES = ['배분 A 20% · B 42% · 새틀라이트 0%(꺼짐) · 나머지 C', '금 상한 8%(설정값)', '설정 해시 cfg_fake_0000000000000000']
EXPECT = '규칙을 지켰을 때의 기대치는 전 계좌 세후 10.2% 안팎(최악 9.7%)입니다.'
RAMP = '운영 램프 L1 · 모의투자(내부 시뮬레이션)'
END_AUTO = '종착: 모의 · 자동 매매 · 실행'
END_ADV = '종착: 모의 · 투자 안내 · 실행'
DECLARED = '시작 상태를 선언했습니다'
G_STAGE_ORDER = gate('STAGE_ORDER', '앞 단계를 마치면 열립니다', 'BLOCK')

S1 = stage(T1, 'VERIFIED', S1_LINES, exp=EXPECT)
S1N = stage(T1, 'VERIFIED', S1_LINES)
S2O = stage(T2, 'NOT_STARTED', slot='PLEDGE_WRITE')
S3B = stage(T3, 'NOT_STARTED', gate_=G_STAGE_ORDER)
S4U = stage(T4, 'NOT_STARTED', gate_=gate('SELFTEST_READY',
                                          '셀프테스트 준비 상태를 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다',
                                          'UNKNOWN'))
S5N = stage(T5, 'NOT_STARTED', gate_=gate('RECOVERY_CARD', '이 계정에는 복구 카드가 이미 있어 다시 발급하지 않습니다',
                                          'NOT_APPLICABLE'))
S6B = stage(T6, 'NOT_STARTED', [RAMP, END_AUTO], gate_=G_STAGE_ORDER)
S2V = stage(T2, 'VERIFIED')
S3V = stage(T3, 'VERIFIED')
S4V = stage(T4, 'VERIFIED', ['통과 12/전체 12'])
S5V = stage(T5, 'VERIFIED', ['프로젝트 ref: ref-fake-aaq', '계정 이메일: owner@example.invalid',
                             '데이터 저장소: github.com/fake-owner/aaq-data', '복구 코드: FAKE-WXYZ-ABCD-EFGH',
                             '종이에 옮겨 적은 뒤 체크섬을 입력하십시오.'])
S6A_L = stage(T6, 'NOT_STARTED', [RAMP, END_AUTO], link=link_action('가상 초기금 넣기', R_SIM_CASH))
S6A_A = stage(T6, 'NOT_STARTED', [RAMP, END_AUTO, DECLARED], act=DRY_RUN)
S6V_L = stage(T6, 'NOT_STARTED', [RAMP, END_ADV], link=link_action('시작 보유·현금 선언하기', R_SIM_LEDGER + '연금저축'))
S6V_A = stage(T6, 'NOT_STARTED', [RAMP, END_ADV, DECLARED], act=DRY_RUN)
S6D = stage(T6, 'VERIFIED', [RAMP, END_AUTO, DECLARED])
FINISH_HEAD = '마무리 여섯 단계를 순서대로 진행합니다.'
DONE_LABEL = '모의투자를 시작했습니다. 이제 앱은 모의투자 모드로 돕니다.'
DONE_CHECKS = [{'label': '전 키 1회 호출', 'state': 'VERIFIED'}, {'label': '워치독 첫 핑', 'state': 'VERIFIED'},
               {'label': '워치독 체크 active 확인', 'state': 'IN_PROGRESS'}, {'label': 'GitHub 첫 커밋', 'state': 'VERIFIED'},
               {'label': '상시 알림(FGS) 생존', 'state': 'NOT_STARTED'}]
STAGE_SLOTS = ['PLEDGE_WRITE', 'BIOMETRIC_SIGN', 'SELFTEST_RUN', 'RECOVERY_CHECKSUM']


def finish_vm(stages, done=None, checks=()):
    return {'headline': FINISH_HEAD, 'stages': copy.deepcopy(stages), 'done_label': done,
            'checks': copy.deepcopy(list(checks))}


# ── R-01 · V-01(§5-4) ─────────────────────────────────────────────────────
RESTART_HEAD = '기존 계정에서 다시 시작합니다'
INHERIT = '킬스위치와 차단 플래그는 켜진 그대로 이어받습니다.'
OLD_PHONE = '구 폰: 거실 폰(Android)'


def restart_vm(login=None, ledger=None, lease=None, branches=(), inherit=None):
    return {'headline': RESTART_HEAD, 'login_slot_id': login, 'ledger_lines': copy.deepcopy(ledger),
            'lease_gate': copy.deepcopy(lease), 'branches': copy.deepcopy(list(branches)), 'inherit_notice': inherit}


def pairing_vm(headline, scanner, res):
    return {'headline': headline, 'scanner_slot_id': scanner, 'result': copy.deepcopy(res)}


def pairing_result(level, headline, code=None, next_link=None):
    return {'level': level, 'headline': headline, 'reason_code': code, 'next_link': copy.deepcopy(next_link)}


PAIR_HEAD = '조회 전용 기기 연결'


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
    assert env['meta']['contract_version'] == '1.15.0', rel
    env['meta']['contract_version'] = '1.16.0'
    return env


def vm_envelope(vm):
    """VM 1행 봉투(v1.15 선례) — 최상위 as_of = 온보딩 기준(🔴 VM 에는 asOf 칸이 없다 · K10)."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(ONB_AS_OF), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': [vm]}


def list_envelope(rows):
    env = vm_envelope(None)
    env['rows'] = copy.deepcopy(rows)
    return env


# ────────────────────────────────────────────────────────────────────────
# 개정
# ────────────────────────────────────────────────────────────────────────
def revise_steps(rel):
    """`OnboardingStep` 표본 — 행 끝에 `requirement_label` · (`verified_until` 있으면) `verified_until_text`."""
    env = bumped_env(rel)
    assert ser_envelope(base_env(rel), True) == base_text(rel), rel + ' — 직렬화 꼴이 원문과 다르다'
    for r in env['rows']:
        assert 'requirement_label' not in r and 'verified_until_text' not in r and 'gate' not in r, rel
        r['requirement_label'] = REQ_LABEL[r['requirement']]
        t = until_text(r.get('verified_until'), r['state'])
        if t is not None:
            r['verified_until_text'] = t
    return ser_envelope(env, True)


def revise_mode_pick():
    s = bump(base_text(MODE_PICK), MODE_PICK)
    assert s.count(MODE_PICK_OLD) == 1
    return s.replace(MODE_PICK_OLD, MODE_PICK_NEW, 1)


# ────────────────────────────────────────────────────────────────────────
# 신설
# ────────────────────────────────────────────────────────────────────────
def new_files():
    opts = base_env(MODE_PICK)['rows'][0]['options']
    assert [o['mode'] for o in opts] == ['AUTO_TRADE', 'ADVISORY']
    vms = {
        START: {'headline': START_HEAD, 'tracks': [T_FRESH, T_RECON], 'viewer_track': T_VIEWER},
        START_NV: {'headline': START_HEAD, 'tracks': [T_FRESH, dict(T_RECON, deep_link=None)], 'viewer_track': None},
        M_UNSEL: mode_vm(opts),
        M_AUTO: mode_vm(opts, 'AUTO_TRADE', R_STEPS),
        M_ADV: mode_vm(opts, 'ADVISORY', R_STEPS),
        M_LOCK: mode_vm(opts, 'ADVISORY', None, LOCKED),
        S_FRESH: steps_vm('1/12 완료', STEPS_FRESH_ROWS),
        S_ADV: steps_vm('1/10 완료', STEPS_ADV_ROWS),
        S_READY: steps_vm('3/3 완료', [F1, R2, R3], finish=R_FINISH),
        S_WARN: steps_vm('3/4 완료', [F1, R2, R3, with_(F5, order=4)], finish=R_FINISH),
        S_LOCK: steps_vm('3/3 완료', [with_(F1, gate=copy.deepcopy(G_UNK_LEDGER)), R2, R3]),
        S_EMPTY: steps_vm('0/0 완료', [], '받은 준비물 목록이 없습니다. 운영 방식을 고른 뒤 다시 여십시오.'),
        D_KIS: detail_vm(F2, None, '한국투자증권 KIS Developers 누리집의 모의투자 메뉴에서 앱키와 앱시크릿을 발급받습니다.',
                         '토큰을 한 번 발급하고 모의 잔고를 한 번 조회해 확인합니다.', KIS_VERIFY, 'SECRET_KIS_MOCK'),
        D_NOV: detail_vm(F5, None, '휴대폰 설정 → 배터리 → 앱 최적화 제외에서 이 앱을 고릅니다.',
                         '다음 새벽 배치가 깨어나면 엔진이 확인합니다.'),
        D_MISS: detail_vm(None, DETAIL_MISSING),
        F_AUTO: finish_vm([S1, S2O, S3B, S4U, S5N, S6B]),
        F_AUTO_R: finish_vm([S1, S2V, S3V, S4V, S5V, S6A_L]),
        F_AUTO_D: finish_vm([S1, S2V, S3V, S4V, S5V, S6A_A]),
        F_ADV: finish_vm([S1, S2V, S3V, S4V, S5V, S6V_L]),
        F_ADV_D: finish_vm([S1, S2V, S3V, S4V, S5V, S6V_A]),
        F_NOEXP: finish_vm([S1N, S2O, S3B, S4U, S5N, S6B]),
        F_DONE: finish_vm([S1, S2V, S3V, S4V, S5V, S6D], DONE_LABEL, DONE_CHECKS),
        R_LOST: restart_vm(None, [OLD_PHONE, '마지막 접속: 2026-08-29 21:40', '리스 남은 시간: 약 3시간'],
                           gate('X3_LEASE', '리스를 확인했습니다', 'PASS'),
                           [link_action('구 폰이 옆에 있어요 — 계획 이전(QR)', R_X1_PLAN),
                            link_action('잃어버렸어요 — 비상 이전', R_X1_EMERGENCY)], INHERIT),
        R_OUT: restart_vm('RECOVERY_LOGIN'),
        R_GAP7: restart_vm(None, [OLD_PHONE, '마지막 접속: 2026-08-20 08:10', '마지막 접속 뒤 7일이 지났습니다'],
                           gate('X3_LEASE', '리스가 끝나 이 경로로는 이어받을 수 없습니다', 'BLOCK'),
                           [link_action('신규 온보딩으로 진행하고 잔고 이어받기', R_MODE)], INHERIT),
        R_UNK: restart_vm(None, [OLD_PHONE, '마지막 접속: 확인하지 못함'],
                          gate('X3_LEASE', '리스 상태를 확인하지 못했습니다 — 확인될 때까지 진행할 수 없습니다', 'UNKNOWN')),
        P_WAIT: pairing_vm('운영 폰에 뜬 QR 코드를 비추십시오.', 'VIEWER_QR_SCAN', None),
        P_OK: pairing_vm(PAIR_HEAD, None, pairing_result('OK', '연결되었습니다. 이 기기는 보기만 합니다.', None,
                                                         link_action('보유현황 보기', R_HOLDINGS))),
        P_FAIL: pairing_vm(PAIR_HEAD, 'VIEWER_QR_SCAN',
                           pairing_result('BLOCKED', '폐기된 연결 코드입니다. 운영 폰에서 새로 발급하십시오.',
                                          'PAIRING_TOKEN_REVOKED')),
    }
    texts = {rel: ser_envelope(vm_envelope(vm), False) for rel, vm in vms.items()}
    for rel, rows in ((M_RES, MODE_RESULTS), (V_RES, VERIFY_RESULTS), (F_RES, FINISH_RESULTS)):
        texts[rel] = ser_envelope(list_envelope(rows), True)
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


def step_objs(v):
    """`OnboardingStep` 객체 — `step_id` + `track` + `requirement` 를 가진 것(전환 단계 `HandoverStep` 등은 빼고)."""
    if isinstance(v, dict):
        if 'step_id' in v and 'track' in v and 'requirement' in v:
            yield v
        for x in v.values():
            yield from step_objs(x)
    elif isinstance(v, list):
        for x in v:
            yield from step_objs(x)


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
    if touched:
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
            if new:
                assert not DEV_MEMO.search(v), '%s %s — 개발자 메모: %s' % (rel, path, v)
                assert not OVERSEAS.search(v), '%s %s — 해외: %s' % (rel, path, v)
        assert not any(PNL_KEY.search(k) for k in keys(env)), rel
    for r in step_objs(env):                                                   # C-50 ⑥
        sid = r['step_id']
        assert STEP_ID.match(sid) and sid not in FIXED_SEGMENTS, (rel, sid)
        assert r['requirement_label'] == REQ_LABEL[r['requirement']], (rel, sid)
        if r.get('verified_until') is not None:
            assert r.get('verified_until_text') == until_text(r['verified_until'], r['state']), (rel, sid)
        if r.get('detail_deep_link') is not None:
            assert r['detail_deep_link'] == step_link(sid), (rel, sid)
        if new:
            assert list(r) == STEP_KEYS, (rel, sid)
            assert r['where_deep_link'] is None, (rel, sid)
            assert (r['failure_reason_code'] is None) or (r['failure_text'] is not None), (rel, sid)
            assert r['state'] != 'FAILED' or r['failure_text'] is not None, (rel, sid)
            assert (r['requirement'] == 'RECOMMENDED' and r['state'] != 'VERIFIED') == (r['warning_label'] is not None)
            assert r['gate'] is None or r['gate']['blocked_reason_code'] is None, (rel, sid)
            assert sid not in ('o_00', 'o_04'), (rel, sid)
    return env


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels)
    assert len(NEW_FILES) == 32 and len(set(NEW_FILES)) == 32

    out = {rel: revise_steps(rel) for rel in STEP_REVISED}
    out[MODE_PICK] = revise_mode_pick()
    out.update(new_files())
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES or rel in REVISED, rel in NEW_FILES)
            for rel, s in out.items()}
    vm = {rel: envs[rel]['rows'][0] for rel in VMS}
    for rel in VMS:
        assert len(envs[rel]['rows']) == 1 and 'as_of' not in vm[rel], rel                # K10
    # K14 — O-00·O-00b 7벌 + mode_pick: «권장»·«추천» 0.
    for rel in R15A + [MODE_PICK]:
        for path, v in strings({k: x for k, x in envs[rel].items() if k != 'meta'}):
            assert not RECOMMEND.search(v), '%s %s — 권장 낱말: %s' % (rel, path, v)
    # O-00 — 계정 축 2 · 조회 갈래 한 칸.
    for rel in STARTS:
        assert [t['track'] for t in vm[rel]['tracks']] == ['FRESH', 'RECONNECT'], rel
    assert vm[START]['viewer_track']['track'] == 'VIEWER_PAIRING' and vm[START_NV]['viewer_track'] is None
    # O-00b — options = mode_pick 과 같은 값 · 고른 뒤에만 다음 · 잠금.
    opts = envs[MODE_PICK]['rows'][0]['options']
    for rel in MODES:
        m = vm[rel]
        assert m['options'] == opts, rel
        if m['locked_label'] is not None:
            assert m['selected'] is not None and m['next_deep_link'] is None, rel
        elif m['selected'] is not None:
            assert m['next_deep_link'] == R_STEPS, rel
        else:
            assert m['next_deep_link'] is None, rel
    # O-01 — 빈 ⇔ 행 0 · finish 조건 · 차례.
    for rel in STEPS:
        s = vm[rel]
        assert (s['empty_label'] is not None) == (not s['rows']), rel
        assert [r['order'] for r in s['rows']] == list(range(1, len(s['rows']) + 1)), rel
        if s['finish_deep_link'] is not None:
            assert s['finish_deep_link'] == R_FINISH, rel
            assert all(r['state'] == 'VERIFIED' for r in s['rows'] if r['requirement'] == 'REQUIRED'), rel
            assert all(r['gate'] is None or r['gate']['state'] in ('PASS', 'NOT_APPLICABLE') for r in s['rows']), rel
    fresh = vm[S_FRESH]['rows']
    assert {r['state'] for r in fresh} == {'NOT_STARTED', 'IN_PROGRESS', 'VERIFIED', 'FAILED', 'EXPIRED'}
    assert {r['gate']['state'] for r in fresh if r['gate']} == {'PASS', 'BLOCK', 'UNKNOWN', 'NOT_APPLICABLE'}
    lock = vm[S_LOCK]['rows']
    assert all(r['state'] == 'VERIFIED' for r in lock) and any(r['gate'] and r['gate']['state'] == 'UNKNOWN'
                                                               for r in lock)
    # O-02 — 목록과 같은 객체.
    by_id = {r['step_id']: r for r in fresh}
    assert vm[D_KIS]['step'] == by_id['o_02'] and vm[D_NOV]['step'] == by_id['o_06']
    # O-04 — 6단계 · 칸 자리.
    for rel in FINISHES:
        st = vm[rel]['stages']
        assert len(st) == 6, rel
        for i, x in enumerate(st):
            assert i == 0 or x['expectation_line'] is None, rel
            assert x['slot_id'] is None or (1 <= i <= 4 and x['slot_id'] == STAGE_SLOTS[i - 1]), rel
            assert i == 5 or (x['link'] is None and x['action'] is None), rel
        six = st[5]
        assert six['link'] is None or six['action'] is None, rel
        if six['action'] is not None:
            assert all(x['state'] == 'VERIFIED' for x in st[:5]) and six['action']['id'] == 'ONBOARDING_DRY_RUN_START'
        if six['link'] is not None:
            want = R_SIM_LEDGER if 'advisory' in rel else R_SIM_CASH
            assert six['link']['deep_link'].startswith(want), rel
        assert (vm[rel]['done_label'] is not None) == bool(vm[rel]['checks']), rel
    # 결과 — [0] OK · 나머지 BLOCKED · handoff 0.
    for rel in RESULTS:
        rows = envs[rel]['rows']
        assert rows[0]['level'] == 'OK' and rows[0]['reason_code'] is None, rel
        assert all(r['level'] == 'BLOCKED' and r['reason_code'] for r in rows[1:]), rel
        assert all(r['handoff_route'] is None and list(r) == RESULT_KEYS for r in rows), rel

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    n_revised = sum(1 for rel in rels if out[rel] != bump(base_text(rel), rel))
    assert (n_version_only, n_revised) == (181, 6), (n_version_only, n_revised)

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r15_v116_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · contract 1.16.0'
          % (len(out), BASE_FILES, n_version_only, n_revised, len(NEW_FILES)))


if __name__ == '__main__':
    main()
