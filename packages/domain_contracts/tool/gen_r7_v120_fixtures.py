#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.20(R7 선행 M2 보강 + 엔진 겹침 몫 · 01 §29) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r7_v120_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r6c_v119_fixtures.py(계약 v1.19 · 그 스크립트는 v1.19 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-15_R7선행_계약v1.20_설계서.md` §5 · 256 → 271 = 신설 15 · 개정 1 · 버전 줄만 255)
  (a) 전 봉투의 "contract_version": "1.19.0" → "1.20.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 15 — M9 S02 증권사 키 VM 4 + 결과 1 · S06 기기·접근 VM 5 + 결과 1 · S03 계좌 매핑 VM 3 + 결과 1.
  (c) 🔧 개정 1(엔진 겹침 몫 · K8) — m8/onboarding_step_detail_kis_mock 의 `verify.args.kind` "KIS_MOCK" → "KIS_PAPER"
      (바이트 치환 정확히 1회 · 슬롯 이름 `SECRET_KIS_MOCK` 그대로).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*` · `check_*`.

🔴 진짜 키·시크릿·계좌번호·금액 0 — 계좌 = 엔진 `maskAccount` «****» + 가짜 숫자 4 · 키 조각 0 · 기기 id = 불투명 가짜 글자.
🔴 레벨 5값 전수 = 화면별 VM 표본 합집합 + 결과 표본 3벌 각 5값(K34).
🔴 잠김 3벌 = 원판에서 화면별 «비우는 칸»만 비운 판(K35) · `device_access_stale` = VM `as_of.stale_label` 만 다른 판.
🔴 R7 결과 `handoff_route` 전부 null · `retryable` 전부 false(K33).
🔵 S03 선택지 타입 = `AccountMappingOption`(K39 — v1.12 `AccountOption` 과 이름 겹침 회피 · JSON 키는 설계 그대로).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r7_v120_fixtures.py
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
# 계약 1.19.0 · 픽스처 256 의 기준 커밋(origin/main · R6 test-only 기록 — 계약 패키지 = PR #163 이후 README 만).
BASE = '7320c9245b5789f5b5afe90b6026b4b751b595a9'

OLD_VER = '"contract_version": "1.19.0"'
NEW_VER = '"contract_version": "1.20.0"'
BASE_FILES = 256
WANT_FILES = 271

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
KEY_PIECE = re.compile(r'[A-Za-z0-9]{4}(…|\.\.\.)[A-Za-z0-9]{4}')   # 🆕 키 조각 꼴(K7)
LONG_DIGITS = re.compile(r'[0-9]{8,}')                     # 🆕 8자리 이상 숫자 0
MASKED = re.compile(r'^\*{4}[0-9]{4}$')                    # 🆕 엔진 maskAccount «뒤 4»
COUNTDOWN = re.compile(r'카운트다운|남은 시간')
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}

# ── 라우트(lib/src/navigation/app_links.dart 와 같은 글자 — C-33 ① · C-54 ⑰ 이 등록을 다시 본다) ──
R = {
    'm4_key_rotation': 'aaq://m4/key-rotation',
    'secret_leak': 'aaq://ops/runbooks/secret-leak',
    'x1_migration': 'aaq://x1/migration',
}

# ── 사전(labels/settings_codes.dart · onboarding_codes.dart 와 같은 글자 — C-54 ③④⑯ 가 다시 본다) ──
KINDS = ['KIS_LIVE', 'KIS_ISA', 'KIS_PAPER', 'KIS_RECONCILE']
SLOT_OF_KIND = {'KIS_LIVE': 'SECRET_KIS_LIVE', 'KIS_ISA': 'SECRET_KIS_ISA', 'KIS_PAPER': 'SECRET_KIS_MOCK',
                'KIS_RECONCILE': 'SECRET_KIS_RECONCILE'}
QR_SLOT = 'PAIRING_QR_DISPLAY'
RESULT_CODES = {'BIOMETRIC_UNAVAILABLE', 'WRONG_KEY_SET', 'MAPPING_VERIFY_FAILED', 'DEVICE_ALREADY_REVOKED',
                'CREDENTIAL_REJECTED', 'SAF309_DENY_TAXABLE_ACCOUNT'}
BAD_KEYS = ('masked_value', 'masked_text', 'register_action', 'app_lock', 'payload', 'token', 'qr_payload',
            'account_no', 'account_number', 'kind_code', 'account_kind', 'target', 'channel', 'actions',
            'secret_slot_id', 'countdown', 'ttl_seconds', 'action', 'verify', 'is_viewer', 'action_available')

# ── 이름 ─────────────────────────────────────────────────────────────────
CRED = 'm9/credentials.json'
CRED_SIM = 'm9/credentials_sim_sealed.json'
CRED_ADV = 'm9/credentials_advisory.json'
CRED_LOCK = 'm9/credentials_locked.json'
CRED_RES = 'm9/credential_action_results.json'
DEV = 'm9/device_access.json'
DEV_TICKET = 'm9/device_access_ticket.json'
DEV_NONE = 'm9/device_access_no_viewers.json'
DEV_STALE = 'm9/device_access_stale.json'
DEV_LOCK = 'm9/device_access_locked.json'
DEV_RES = 'm9/device_action_results.json'
ACC = 'm9/account_mapping.json'
ACC_UNMAP = 'm9/account_mapping_unmapped.json'
ACC_LOCK = 'm9/account_mapping_locked.json'
ACC_RES = 'm9/account_mapping_action_results.json'

S02_VMS = [CRED, CRED_SIM, CRED_ADV, CRED_LOCK]
S06_VMS = [DEV, DEV_TICKET, DEV_NONE, DEV_STALE, DEV_LOCK]
S03_VMS = [ACC, ACC_UNMAP, ACC_LOCK]
VMS = S02_VMS + S06_VMS + S03_VMS
RESULTS = [CRED_RES, DEV_RES, ACC_RES]
NEW_FILES = VMS + RESULTS
REVISED = 'm8/onboarding_step_detail_kis_mock.json'
REV_OLD = '"args": { "kind": "KIS_MOCK" }'
REV_NEW = '"args": { "kind": "KIS_PAPER" }'
RUNBOOK_INDEX = 'm8/runbook_index.json'
ONB_ADVISORY = 'm8/onboarding_steps_advisory.json'
ONB_VERIFY = 'm8/onboarding_verify_results.json'

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.20.0',
    'generated_at': '2026-11-15T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261115,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(label, stale_label=None):
    out = {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
           'stale_after_seconds': 93600, 'label': label}
    if stale_label is not None:
        out['stale_label'] = stale_label
    return out


AS7K = as_of('키 기준 2026-08-31 09:00')
AS7D = as_of('기기 기준 2026-08-31 09:00')
AS7DS = as_of('기기 기준 2026-08-31 09:00', '기기 목록이 오래됐습니다. 네트워크가 돌아오면 다시 받아 옵니다.')
AS7A = as_of('계좌 기준 2026-08-31 09:00')
AS7R = as_of('동작 기준 2026-08-31')


# ────────────────────────────────────────────────────────────────────────
# 조각(§5-1 · 빈칸 = null · `{id, args, label}` = SettingsActionCall · `{label, deep_link}` = LinkAction)
# ────────────────────────────────────────────────────────────────────────
def call(id_, args, label):
    return {'id': id_, 'args': dict(args), 'label': label}


def link(label, deep_link):
    return {'label': label, 'deep_link': deep_link}


V_LIVE_RE = call('CREDENTIAL_VERIFY', {'kind': 'KIS_LIVE'}, '다시 검증')
V_LIVE_SAVE = call('CREDENTIAL_VERIFY', {'kind': 'KIS_LIVE'}, '검증 후 저장')
V_ISA_RE = call('CREDENTIAL_VERIFY', {'kind': 'KIS_ISA'}, '다시 검증')
V_PAPER_RE = call('CREDENTIAL_VERIFY', {'kind': 'KIS_PAPER'}, '다시 검증')
V_PAPER_SAVE = call('CREDENTIAL_VERIFY', {'kind': 'KIS_PAPER'}, '검증 후 저장')
V_RECON_SAVE = call('CREDENTIAL_VERIFY', {'kind': 'KIS_RECONCILE'}, '검증 후 저장')
T_ISSUE = call('DEVICE_PAIRING_TICKET_CREATE', {}, 'QR 만들기')
R_VW1 = call('DEVICE_TOKEN_REVOKE', {'device_id': 'dev_vw_01'}, '연결 끊기')
R_VW2 = call('DEVICE_TOKEN_REVOKE', {'device_id': 'dev_vw_02'}, '연결 끊기')
M_VERIFY = call('ACCOUNT_VERIFY_MAPPING', {}, '전체 다시 검증')
MS_A_ISA = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'A', 'account_alias': 'ISA'}, 'ISA 로 바꾸기')
MS_B_PEN = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'B', 'account_alias': '연금저축'}, '연금저축으로 바꾸기')
MS_B_GEN = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'B', 'account_alias': '일반'}, '일반 위탁으로 바꾸기')
MS_C_PEN = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'C', 'account_alias': '연금저축'}, '연금저축으로 바꾸기')
MS_C_ISA = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'C', 'account_alias': 'ISA'}, 'ISA 로 바꾸기')
MS_C_GEN_PICK = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'C', 'account_alias': '일반'}, '일반 위탁으로 정하기')
MS_C_PEN_PICK = call('ACCOUNT_MAP_SLEEVE', {'sleeve': 'C', 'account_alias': '연금저축'}, '연금저축으로 정하기')
L_ROT = link('키 회전', R['m4_key_rotation'])
L_LEAK = link('키가 새어 나갔을 때', R['secret_leak'])
L_X1 = link('기기 이전 · 강등 · 비상 복구', R['x1_migration'])
LOCKED_LABEL = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'

# ── S02 카드 ─────────────────────────────────────────────────────────────
CARD_KEYS = ['alias', 'kind', 'kind_label', 'health_code', 'health_label', 'usage', 'usage_label', 'expires_text',
             'level', 'last_verified_text', 'requirement_label', 'why_line', 'seal_label', 'credential_slot_id',
             'verify_action', 'rotate_link']
HEAD_LIVE = ('kis_live', 'KIS_LIVE', '실전 · 위탁 01 + 연금저축 22')
HEAD_ISA = ('kis_isa', 'KIS_ISA', 'ISA 중개형')
HEAD_PAPER = ('kis_paper', 'KIS_PAPER', '모의투자')
HEAD_RECON = ('kis_reconcile', 'KIS_RECONCILE', '대사 전용')
FULL_ORDER = ('FULL', '주문 · 조회')
FULL_PAPER = ('FULL', '모의 주문 · 시세')
RECON_USE = ('RECONCILE_ONLY', '조회 전용')
SEAL_SIM = '모의투자 중 — 주문 경로 봉인됨'
SEAL_RECON = '대사 전용 — 주문 경로 봉인됨'
H_OK = ('OK', '정상')
H_NONE = ('NOT_REGISTERED', '미등록')


def card(head, health, use, expires, level, last, req, why, seal, slot, verify, rotate):
    vals = [head[0], head[1], head[2], health[0], health[1], use[0], use[1], expires, level, last, req, why, seal, slot,
            verify, rotate]
    return dict(zip(CARD_KEYS, copy.deepcopy(vals)))


C_LIVE_OK = card(HEAD_LIVE, H_OK, FULL_ORDER, '만료 2027-06-30', 'OK', '마지막 검증 08-31 08:40 · 통과', '필수', None, None,
                 None, V_LIVE_RE, None)
C_ISA_SOON = card(HEAD_ISA, ('EXPIRING', '만료 임박'), FULL_ORDER, '만료까지 20일 · 2026-09-20', 'WATCH',
                  '마지막 검증 08-31 08:41 · 통과', '필수', None, None, None, V_ISA_RE, L_ROT)
C_PAPER_BAD = card(HEAD_PAPER, ('INVALID', '검증 실패'), FULL_PAPER, '만료 2026-11-28', 'ACT',
                   '마지막 검증 08-31 08:42 · 거절(CREDENTIAL_REJECTED)', '선택', None, None, 'SECRET_KIS_MOCK',
                   V_PAPER_SAVE, None)
C_LIVE_SEAL = card(HEAD_LIVE, H_OK, FULL_ORDER, '만료 2027-06-30', 'INFO', '마지막 검증 08-31 08:40 · 통과',
                   '실전 전환 때 필수', None, SEAL_SIM, None, None, None)
C_ISA_SEAL = card(HEAD_ISA, H_OK, FULL_ORDER, '만료 2027-02-15', 'INFO', '마지막 검증 08-31 08:41 · 통과', '실전 전환 때 필수',
                  None, SEAL_SIM, None, None, None)
C_PAPER_EXP = card(HEAD_PAPER, ('EXPIRED', '만료'), FULL_PAPER, '만료됨 · 2026-08-30 — 모의 시세를 받지 못합니다', 'BLOCKED',
                   '마지막 검증 08-29 08:42 · 통과', '필수', None, None, 'SECRET_KIS_MOCK', V_PAPER_SAVE, None)
C_LIVE_OPT = card(HEAD_LIVE, H_NONE, FULL_ORDER, None, 'INFO', None, '선택', '투자 안내 모드에서는 주문 권한 키가 없어도 됩니다.',
                  None, 'SECRET_KIS_LIVE', V_LIVE_SAVE, None)
# 🔵 = 온보딩 m8/onboarding_steps_advisory `o_12` 의 why_line 과 같은 글자(같은 사실 한 문장 — main() 이 맞댄다).
RECON_WHY = '등록하지 않으면 원장 신뢰 등급이 자기 보고로 고정됩니다. 진행은 막지 않습니다.'
C_RECON_REC = card(HEAD_RECON, H_NONE, RECON_USE, None, 'INFO', None, '권장', RECON_WHY, SEAL_RECON, 'SECRET_KIS_RECONCILE',
                   V_RECON_SAVE, None)
C_PAPER_OK = card(HEAD_PAPER, H_OK, FULL_PAPER, '만료 2026-11-28', 'OK', '마지막 검증 08-31 08:42 · 통과', '필수', None, None,
                  None, V_PAPER_RE, None)

CRED_VM_KEYS = ['cards', 'mode_notice', 'leak_runbook_link', 'locked_label', 'as_of']
SIM_NOTICE = '모의투자 중입니다 — 실전 키의 주문 경로는 봉인돼 있습니다. 봉인은 실전 전환 절차에서만 풀립니다.'


def cred_vm(cards, notice):
    return dict(zip(CRED_VM_KEYS, copy.deepcopy([cards, notice, L_LEAK, None, AS7K])))


def lock_cred(vm):
    """K35 — S02 잠김: 카드 슬롯·검증·회전 비움 + 머리 한 줄(런북 링크 유지 · 그 밖 바이트 같음)."""
    out = copy.deepcopy(vm)
    for c in out['cards']:
        c['credential_slot_id'] = None
        c['verify_action'] = None
        c['rotate_link'] = None
    out['locked_label'] = LOCKED_LABEL
    return out


# ── S06 ──────────────────────────────────────────────────────────────────
ROW_KEYS = ['device_id', 'label', 'role_label', 'status_label', 'last_seen_text', 'level', 'revoke_action',
            'revoke_confirm_text']


def drow(*vals):
    assert len(vals) == len(ROW_KEYS)
    return dict(zip(ROW_KEYS, copy.deepcopy(list(vals))))


D_OP = drow('dev_op_01', '이 폰(운영)', '운영 기기', '사용 중', '지금', 'OK', None, None)
D_TAB = drow('dev_vw_01', '태블릿', '조회 전용', '연결됨', '08-31 07:55', 'OK', R_VW1,
             '태블릿의 조회 연결을 지금 끊습니다. 즉시 조회가 차단되고, 다시 쓰려면 QR 로 새로 연결해야 합니다.')
D_LAP = drow('dev_vw_02', '업무용 노트북(웹)', '조회 전용', '30일째 접속 없음 — 쓰지 않으면 연결을 끊으세요', '08-01 18:10', 'ACT',
             R_VW2, '업무용 노트북(웹)의 조회 연결을 지금 끊습니다. 즉시 조회가 차단됩니다.')
D_OLD = drow('dev_vw_03', '예전 휴대폰', '조회 전용', '연결 끊김', '07-10 21:30', 'INFO', None, None)
D_OP_WAIT = drow('dev_op_01', '이 폰(운영)', '운영 기기', '주문 대기 — 리스를 기다리는 중', '지금', 'WATCH', None, None)

PAIR_KEYS = ['headline', 'issue_action', 'qr_slot_id', 'expires_text']
P_ISSUE = dict(zip(PAIR_KEYS, ['조회 전용 기기를 하나 더 연결합니다.', copy.deepcopy(T_ISSUE), None, None]))
P_TICKET = dict(zip(PAIR_KEYS, ['조회 전용 기기에서 이 QR 을 스캔하세요. 다른 사람에게 보이지 마세요.', None, QR_SLOT,
                                '09:15 까지 유효']))

DEV_VM_KEYS = ['devices', 'lease_holder_label', 'lease_state_label', 'as_of', 'lease_eta_text', 'lease_level',
               'lease_epoch_text', 'migration_link', 'pairing', 'empty_label', 'locked_label']
LEASE_OK = ('이 폰(운영)', '유효 — 갱신 정상', '다음 갱신 09:25(서버 시각)', 'OK', '세대 3')
LEASE_WAIT = ('없음 — 이전 리스가 끝나기를 기다립니다', '리스 대기 — 비상 복구 뒤 주문이 멈춰 있습니다', '리스 얻기 예정 09:30(서버 시각)',
              'BLOCKED', None)
NO_VIEWERS = '연결된 조회 전용 기기가 없습니다.'


def dev_vm(rows, lease, pairing, empty):
    vals = [rows, lease[0], lease[1], AS7D, lease[2], lease[3], lease[4], L_X1, pairing, empty, None]
    return dict(zip(DEV_VM_KEYS, copy.deepcopy(vals)))


def lock_dev(vm):
    """K35 — S06 잠김: 행 폐기·확인 · 티켓 발급·QR·유효 · X1 링크 비움(티켓 머리 글자 유지)."""
    out = copy.deepcopy(vm)
    for r in out['devices']:
        r['revoke_action'] = None
        r['revoke_confirm_text'] = None
    out['pairing']['issue_action'] = None
    out['pairing']['qr_slot_id'] = None
    out['pairing']['expires_text'] = None
    out['migration_link'] = None
    out['locked_label'] = LOCKED_LABEL
    return out


# ── S03 ──────────────────────────────────────────────────────────────────
ACC_KEYS = ['label', 'kind_label', 'masked_number_text', 'check_text', 'badge_text', 'level']


def arow(*vals):
    assert len(vals) == len(ACC_KEYS)
    return dict(zip(ACC_KEYS, list(vals)))


# 🔵 위탁·연금저축 = 같은 종합계좌(8자리) · 상품코드만 다름 → 엔진 maskAccount(뒤 4) 글자가 같다(구분 = kind_label).
A_GEN = arow('일반 위탁', '위탁 01', '****4821', '잔고 확인 08-31 08:45', None, 'OK')
A_PEN = arow('연금저축', '연금저축 22', '****4821', '잔고 확인 08-31 08:45', None, 'OK')
A_ISA = arow('ISA', 'ISA 중개형', '****7730', '잔고 확인 08-28 08:45 — 3일 전', None, 'WATCH')
A_ISA_FAIL = arow('ISA', 'ISA 중개형', '****7730', '잔고 조회 실패 — ISA 키가 만료됐습니다', None, 'BLOCKED')
A_PAPER = arow('모의투자', '모의 01', '****5096', '모의 서버 잔고 확인 08-31 08:46', '실전 매핑 대상 아님', 'INFO')
A_DC = arow('퇴직연금 DC', 'DC 55', '****3307', None, '시스템 밖 자산(수동)', 'INFO')

NEXT_PLAN = '다음 회차 계획을 새 계좌 기준으로 다시 만듭니다.'
I_A_ISA = ['슬리브 A 와 POT 서브북의 주문 계좌가 ISA 로 바뀝니다.', '연금 납입 한도 집계에서 슬리브 A 의 몫이 빠집니다.',
           '성과 화면의 세후 표시 기준이 바뀔 수 있습니다.', NEXT_PLAN]
I_B_PEN = ['슬리브 B 의 주문 계좌가 연금저축으로 바뀝니다.', '연금 납입 한도 집계에 슬리브 B 가 더해집니다.', NEXT_PLAN]
I_C_PEN = ['슬리브 C 의 주문 계좌가 연금저축으로 바뀝니다.', '연금 납입 한도 집계에 슬리브 C 가 더해집니다.', NEXT_PLAN]
I_B_GEN = ['슬리브 B 의 주문 계좌가 일반 위탁으로 바뀝니다.', '일반 계좌라 매매차익에 세금이 붙습니다.', NEXT_PLAN]
I_C_ISA = ['슬리브 C 의 주문 계좌가 ISA 로 바뀝니다.', NEXT_PLAN]
I_C_GEN_PICK = ['슬리브 C 의 주문 계좌를 일반 위탁으로 정합니다.', '일반 계좌라 매매차익에 세금이 붙습니다.',
                '다음 회차부터 슬리브 C 의 주문을 냅니다.']
I_C_PEN_PICK = ['슬리브 C 의 주문 계좌를 연금저축으로 정합니다.', '연금 납입 한도 집계에 슬리브 C 가 더해집니다.',
                '다음 회차부터 슬리브 C 의 주문을 냅니다.']

OPT_KEYS = ['label', 'selected', 'impacts', 'blocked_text', 'select_action']


def opt(label, selected=False, impacts=(), blocked=None, action=None):
    return dict(zip(OPT_KEYS, copy.deepcopy([label, selected, list(impacts), blocked, action])))


O_PEN, O_ISA, O_GEN = '연금저축 · ****4821', 'ISA · ****7730', '일반 위탁 · ****4821'
MAP_KEYS = ['sleeve_label', 'account_label', 'subbook_line', 'status_line', 'level', 'options']


def mrow(*vals):
    assert len(vals) == len(MAP_KEYS)
    return dict(zip(MAP_KEYS, copy.deepcopy(list(vals))))


MAP_A = mrow('슬리브 A', '연금저축', 'POT 서브북도 이 계좌에서 운용합니다(절세계좌).', None, 'OK',
             [opt(O_PEN, True), opt(O_ISA, impacts=I_A_ISA, action=MS_A_ISA),
              opt(O_GEN, blocked='POT 서브북은 절세계좌에서만 운용합니다(SAF-309).')])
B_OPTS = [opt(O_ISA, True), opt(O_PEN, impacts=I_B_PEN, action=MS_B_PEN), opt(O_GEN, impacts=I_B_GEN, action=MS_B_GEN)]
MAP_B = mrow('슬리브 B', 'ISA', None, None, 'OK', B_OPTS)
MAP_C = mrow('슬리브 C', '일반 위탁', None, None, 'OK',
             [opt(O_GEN, True), opt(O_PEN, impacts=I_C_PEN, action=MS_C_PEN),
              opt(O_ISA, impacts=I_C_ISA, action=MS_C_ISA)])
MAP_B_FAIL = mrow('슬리브 B', 'ISA', None, 'ISA 잔고를 확인하지 못해 이 슬리브의 주문이 멈춰 있습니다.', 'BLOCKED', B_OPTS)
MAP_C_NONE = mrow('슬리브 C', None, None, '미지정 — 이 슬리브의 주문은 내지 않습니다.', 'ACT',
                  [opt(O_GEN, impacts=I_C_GEN_PICK, action=MS_C_GEN_PICK),
                   opt(O_PEN, impacts=I_C_PEN_PICK, action=MS_C_PEN_PICK),
                   opt(O_ISA, blocked='ISA 잔고를 확인하지 못해 지금은 고를 수 없습니다.')])

ACC_VM_KEYS = ['accounts', 'mappings', 'verify_action', 'locked_label', 'as_of']


def acc_vm(accounts, mappings):
    return dict(zip(ACC_VM_KEYS, copy.deepcopy([accounts, mappings, M_VERIFY, None, AS7A])))


def lock_acc(vm):
    """K35 — S03 잠김: 전체 검증 · 선택지 호출 · 영향 비움(그 밖 바이트 같음)."""
    out = copy.deepcopy(vm)
    out['verify_action'] = None
    for m in out['mappings']:
        for o in m['options']:
            o['select_action'] = None
            o['impacts'] = []
    out['locked_label'] = LOCKED_LABEL
    return out


# ── 결과(K33 — handoff_route null · retryable false) ────────────────────────
RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']


def result(run_id, id_, level, headline, reason=None):
    return dict(zip(RESULT_KEYS, [run_id, id_, level, headline, reason, None, False]))


def build_results(rejected_headline):
    """`ar_s02_05` headline = m8/onboarding_verify_results 의 CREDENTIAL_REJECTED 행 글자(같은 판정 · K32)."""
    return {
        CRED_RES: [
            result('ar_s02_01', 'CREDENTIAL_VERIFY', 'OK', '검증을 통과해 저장했습니다. 다음 회차부터 이 키를 씁니다.'),
            result('ar_s02_02', 'CREDENTIAL_VERIFY', 'INFO', '다시 검증했습니다 — 바뀐 것이 없습니다.'),
            result('ar_s02_03', 'CREDENTIAL_VERIFY', 'WATCH', '검증은 통과했습니다. 만료까지 20일 남아 키 회전을 준비할 때입니다.'),
            result('ar_s02_04', 'CREDENTIAL_VERIFY', 'ACT', '다른 환경의 키입니다 — 모의 칸에 실전 키를 넣었습니다. 저장하지 않았습니다.',
                   'WRONG_KEY_SET'),
            result('ar_s02_05', 'CREDENTIAL_VERIFY', 'BLOCKED', rejected_headline, 'CREDENTIAL_REJECTED'),
            result('ar_s02_06', 'CREDENTIAL_VERIFY', 'BLOCKED', '생체 확인이 없어 검증하지 않았습니다.', 'BIOMETRIC_UNAVAILABLE'),
        ],
        DEV_RES: [
            result('ar_s06_01', 'DEVICE_PAIRING_TICKET_CREATE', 'OK', 'QR 을 만들었습니다. 09:15 까지 스캔하세요.'),
            result('ar_s06_02', 'DEVICE_PAIRING_TICKET_CREATE', 'ACT', '서버에 닿지 못해 QR 을 만들지 못했습니다. 네트워크를 확인하세요.'),
            result('ar_s06_03', 'DEVICE_PAIRING_TICKET_CREATE', 'BLOCKED', '생체 확인이 없어 QR 을 만들지 않았습니다.',
                   'BIOMETRIC_UNAVAILABLE'),
            result('ar_s06_04', 'DEVICE_TOKEN_REVOKE', 'OK', '연결을 끊었습니다. 지금부터 그 기기의 조회가 차단됩니다.'),
            result('ar_s06_05', 'DEVICE_TOKEN_REVOKE', 'WATCH', '연결을 끊었습니다. 그 기기가 꺼져 있어 기기 쪽 표시는 다음 실행 때 바뀝니다.'),
            result('ar_s06_06', 'DEVICE_TOKEN_REVOKE', 'INFO', '이미 연결이 끊긴 기기입니다.', 'DEVICE_ALREADY_REVOKED'),
        ],
        ACC_RES: [
            result('ar_s03_01', 'ACCOUNT_MAP_SLEEVE', 'OK', '슬리브 B 를 연금저축에 연결했습니다. 다음 회차부터 이 계좌로 주문합니다.'),
            result('ar_s03_02', 'ACCOUNT_MAP_SLEEVE', 'INFO', '이미 그 계좌에 연결돼 있습니다.'),
            result('ar_s03_03', 'ACCOUNT_MAP_SLEEVE', 'BLOCKED', 'POT 서브북은 절세계좌에서만 운용합니다 — 일반 계좌로 바꾸지 않았습니다.',
                   'SAF309_DENY_TAXABLE_ACCOUNT'),
            result('ar_s03_04', 'ACCOUNT_MAP_SLEEVE', 'ACT', '잔고 조회를 확인하지 못해 바꾸지 않았습니다. 키 관리에서 먼저 검증하세요.',
                   'MAPPING_VERIFY_FAILED'),
            result('ar_s03_05', 'ACCOUNT_MAP_SLEEVE', 'BLOCKED', '생체 확인이 없어 바꾸지 않았습니다.', 'BIOMETRIC_UNAVAILABLE'),
            result('ar_s03_06', 'ACCOUNT_VERIFY_MAPPING', 'OK', '세 슬리브 모두 계좌 연결과 잔고 조회를 확인했습니다.'),
            result('ar_s03_07', 'ACCOUNT_VERIFY_MAPPING', 'WATCH', '확인했습니다. ISA 잔고 기준일이 3일 전이라 다음 조회 때 다시 봅니다.'),
            result('ar_s03_08', 'ACCOUNT_VERIFY_MAPPING', 'ACT', '슬리브 C 가 미지정이라 검증을 마치지 못했습니다.',
                   'MAPPING_VERIFY_FAILED'),
        ],
    }


def build_vms():
    cred = cred_vm([C_LIVE_OK, C_ISA_SOON, C_PAPER_BAD], None)
    dev = dev_vm([D_OP, D_TAB, D_LAP, D_OLD], LEASE_OK, P_ISSUE, None)
    dev_ticket = copy.deepcopy(dev)
    dev_ticket['pairing'] = copy.deepcopy(P_TICKET)
    dev_stale = copy.deepcopy(dev)
    dev_stale['as_of'] = copy.deepcopy(AS7DS)
    acc = acc_vm([A_GEN, A_PEN, A_ISA, A_PAPER, A_DC], [MAP_A, MAP_B, MAP_C])
    return {
        CRED: cred,
        CRED_SIM: cred_vm([C_LIVE_SEAL, C_ISA_SEAL, C_PAPER_EXP], SIM_NOTICE),
        CRED_ADV: cred_vm([C_LIVE_OPT, C_RECON_REC, C_PAPER_OK], None),
        CRED_LOCK: lock_cred(cred),
        DEV: dev,
        DEV_TICKET: dev_ticket,
        DEV_NONE: dev_vm([D_OP_WAIT], LEASE_WAIT, P_ISSUE, NO_VIEWERS),
        DEV_STALE: dev_stale,
        DEV_LOCK: lock_dev(dev),
        ACC: acc,
        ACC_UNMAP: acc_vm([A_GEN, A_PEN, A_ISA_FAIL, A_PAPER, A_DC], [MAP_A, MAP_B_FAIL, MAP_C_NONE]),
        ACC_LOCK: lock_acc(acc),
    }


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_r6c_v119_fixtures.py 와 같은 꼴)
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


def vm_envelope(rows, env_as_of):
    """봉투(v1.15~v1.19 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def new_files(vms, results):
    texts = {}
    for rel, vm in vms.items():
        env_as = AS7D if rel in S06_VMS else vm['as_of']   # 🔵 _stale = VM as_of 만 다르다(봉투 그대로)
        texts[rel] = ser_envelope(vm_envelope([vm], env_as), False)
    for rel, rows in results.items():
        texts[rel] = ser_envelope(vm_envelope(rows, AS7R), True)
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
            if k in ('level', 'lease_level'):
                yield x
            yield from levels(x)
    elif isinstance(v, list):
        for x in v:
            yield from levels(x)


def calls(v):
    """`{id, args, label}` 꼴 객체(어느 키 아래든)."""
    if isinstance(v, dict):
        if set(v) == {'id', 'args', 'label'}:
            yield v
        for x in v.values():
            yield from calls(x)
    elif isinstance(v, list):
        for x in v:
            yield from calls(x)


CHECKS = (('금지어', FORBIDDEN), ('개발자 메모', DEV_MEMO), ('계좌꼴', ACCOUNT_LIKE), ('전화번호 꼴', PHONE),
          ('앱키 꼴', LONG_ALNUM), ('URL 꼴', URL_LIKE), ('손익 낱말', PNL_WORD), ('금액 글자', MONEY),
          ('키 조각 꼴', KEY_PIECE), ('8자리 숫자', LONG_DIGITS), ('카운트다운', COUNTDOWN))


def self_check_file(rel, s, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    # 🔴 전 표본 — CREDENTIAL_VERIFY 의 kind ∈ 사전(개정 증명 · C-54 ③).
    for c in calls(env):
        if c['id'] == 'CREDENTIAL_VERIFY':
            assert c['args'].get('kind') in KINDS, (rel, c)
    if new:
        assert env['meta']['mode'] == 'LIVE', rel
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        assert env['as_of'].get('stale_label') is None, rel
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            for name, rx in CHECKS:
                assert not rx.search(v), '%s %s — %s: %s' % (rel, path, name, v)
            assert 'DRY_RUN' not in v and '앱 잠금' not in v, (rel, path, v)
            if v.startswith('aaq://'):
                assert v in R.values(), '%s %s — 라우트 글자: %s' % (rel, path, v)
        ks = set(keys(env['rows']))
        assert not any(PNL_KEY.search(k) for k in ks), rel
        for bad in BAD_KEYS + ('rows',):
            assert bad not in ks, (rel, bad)
    return env


def check_call(a, id_, arg_keys):
    assert a['id'] == id_ and set(a['args']) == set(arg_keys) and a['label'], a


def check_cred(rel, vm):
    assert list(vm) == CRED_VM_KEYS and vm['cards'], rel
    assert all(list(c) == CARD_KEYS for c in vm['cards']), rel
    assert set(levels(vm)) <= LEVELS, rel
    assert vm['leak_runbook_link'] == L_LEAK, rel
    ks = [c['kind'] for c in vm['cards']]
    assert len(ks) == len(set(ks)) and set(ks) <= set(KINDS), rel
    for c in vm['cards']:
        if c['verify_action'] is not None:
            check_call(c['verify_action'], 'CREDENTIAL_VERIFY', ['kind'])
            assert c['verify_action']['args']['kind'] == c['kind'], rel
        if c['credential_slot_id'] is not None:
            assert c['credential_slot_id'] == SLOT_OF_KIND[c['kind']] and c['verify_action'] is not None, rel
        if c['rotate_link'] is not None:
            assert c['rotate_link']['deep_link'] == R['m4_key_rotation'], rel
        assert (c['usage'] == 'RECONCILE_ONLY') == (c['kind'] == 'KIS_RECONCILE'), rel


def check_dev(rel, vm):
    assert list(vm) == DEV_VM_KEYS and vm['devices'], rel
    assert all(list(r) == ROW_KEYS for r in vm['devices']), rel
    assert list(vm['pairing']) == PAIR_KEYS, rel
    ids = [r['device_id'] for r in vm['devices']]
    assert len(ids) == len(set(ids)), rel
    assert any(r['revoke_action'] is None for r in vm['devices']), rel
    for r in vm['devices']:
        assert (r['revoke_action'] is None) == (r['revoke_confirm_text'] is None), rel
        if r['revoke_action'] is not None:
            check_call(r['revoke_action'], 'DEVICE_TOKEN_REVOKE', ['device_id'])
            assert r['revoke_action']['args']['device_id'] == r['device_id'], rel
    p = vm['pairing']
    if p['issue_action'] is not None:
        check_call(p['issue_action'], 'DEVICE_PAIRING_TICKET_CREATE', [])
    assert (p['qr_slot_id'] is None) == (p['expires_text'] is None), rel
    assert p['qr_slot_id'] in (None, QR_SLOT), rel
    if vm['locked_label'] is None:
        assert (p['issue_action'] is not None) != (p['qr_slot_id'] is not None), rel
    if vm['migration_link'] is not None:
        assert vm['migration_link']['deep_link'] == R['x1_migration'], rel
    assert (vm['empty_label'] is not None) == (len(vm['devices']) == 1), rel


def check_acc(rel, vm):
    assert list(vm) == ACC_VM_KEYS and vm['accounts'] and vm['mappings'], rel
    assert all(list(a) == ACC_KEYS for a in vm['accounts']), rel
    for a in vm['accounts']:
        assert MASKED.match(a['masked_number_text']), (rel, a)
    badge_labels = {a['label'] for a in vm['accounts'] if a['badge_text'] is not None}
    assert badge_labels, rel
    if vm['verify_action'] is not None:
        check_call(vm['verify_action'], 'ACCOUNT_VERIFY_MAPPING', [])
    sleeves = []
    sub = 0
    for m in vm['mappings']:
        assert list(m) == MAP_KEYS and 'POT' not in m['sleeve_label'], rel
        sel = [o for o in m['options'] if o['selected']]
        assert len(sel) <= 1 and (m['account_label'] is None) == (not sel), rel
        if m['account_label'] is None:
            assert m['status_line'] is not None, rel
        row_sleeves = set()
        for o in m['options']:
            assert list(o) == OPT_KEYS, rel
            assert not any(o['label'].startswith(b) for b in badge_labels), rel
            for piece in re.findall(r'[*0-9]{4,}', o['label']):
                assert MASKED.match(piece), (rel, o['label'])
            if o['selected'] or o['blocked_text'] is not None:
                assert o['select_action'] is None, rel
            assert bool(o['impacts']) == (o['select_action'] is not None), rel
            if o['select_action'] is not None:
                check_call(o['select_action'], 'ACCOUNT_MAP_SLEEVE', ['sleeve', 'account_alias'])
                assert o['select_action']['args']['sleeve'] in ('A', 'B', 'C'), rel
                assert o['select_action']['args']['account_alias'], rel
                row_sleeves.add(o['select_action']['args']['sleeve'])
        assert len(row_sleeves) <= 1, rel
        if row_sleeves:
            sleeves.append(row_sleeves.pop())
        if m['subbook_line'] is not None:
            sub += 1
            assert m['sleeve_label'].endswith('A'), rel
    assert len(sleeves) == len(set(sleeves)) and sub <= 1, rel


def without(vm, *names):
    out = copy.deepcopy(vm)
    for n in names:
        out.pop(n)
    return out


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    for need in (REVISED, RUNBOOK_INDEX, ONB_ADVISORY, ONB_VERIFY):
        assert need in rels, need
    assert len(NEW_FILES) == 15 and len(set(NEW_FILES)) == 15

    # 엔진 글자 맞대기 — 같은 사실 한 문장(K32 · §5-1).
    assert ('"deep_link": "%s"' % R['secret_leak']) in base_text(RUNBOOK_INDEX), 'runbook_index 의 유출 런북'
    assert ('"why_line": "%s"' % RECON_WHY) in base_text(ONB_ADVISORY), 'o_12 why_line'
    ver = json.loads(base_text(ONB_VERIFY))
    rej = [r['headline'] for r in ver['rows'] if r['reason_code'] == 'CREDENTIAL_REJECTED']
    assert len(rej) == 1, rej

    vms = build_vms()
    results = build_results(rej[0])
    out = new_files(vms, results)
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)
    assert out[REVISED].count(REV_OLD) == 1, REVISED
    out[REVISED] = out[REVISED].replace(REV_OLD, REV_NEW, 1)
    assert '"secret_slot_id": "SECRET_KIS_MOCK"' in out[REVISED], REVISED

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    vm = {rel: envs[rel]['rows'][0] for rel in VMS}
    for rel in VMS:
        assert len(envs[rel]['rows']) == 1, rel
    for rel in S02_VMS:
        assert vm[rel]['as_of'] == envs[rel]['as_of'] == AS7K, rel
        check_cred(rel, vm[rel])
    for rel in S06_VMS:
        assert envs[rel]['as_of'] == AS7D, rel
        assert vm[rel]['as_of'] == (AS7DS if rel == DEV_STALE else AS7D), rel
        check_dev(rel, vm[rel])
    for rel in S03_VMS:
        assert vm[rel]['as_of'] == envs[rel]['as_of'] == AS7A, rel
        check_acc(rel, vm[rel])
    # 레벨 5값 = 화면별 합집합(K34).
    for group in (S02_VMS, S06_VMS, S03_VMS):
        assert set().union(*(set(levels(vm[r])) for r in group)) == LEVELS, group
    # S02 갈래.
    assert {c['kind'] for r in S02_VMS for c in vm[r]['cards']} == set(KINDS)
    assert {r for r in S02_VMS if vm[r]['mode_notice'] is not None} == {CRED_SIM}
    for c in vm[CRED_SIM]['cards']:
        if c['kind'] in ('KIS_LIVE', 'KIS_ISA'):
            assert c['seal_label'] and c['credential_slot_id'] is None and c['verify_action'] is None, c
            assert c['rotate_link'] is None, c
    for c in vm[CRED_ADV]['cards']:
        if c['kind'] in ('KIS_RECONCILE', 'KIS_LIVE'):
            assert c['why_line'] and c['level'] not in ('ACT', 'BLOCKED'), c
        if c['kind'] == 'KIS_RECONCILE':
            assert c['seal_label'] and c['usage'] == 'RECONCILE_ONLY', c
    assert {r for r in VMS if vm[r]['locked_label'] is not None} == {CRED_LOCK, DEV_LOCK, ACC_LOCK}
    assert vm[CRED_LOCK] == lock_cred(vm[CRED])
    # S06 갈래.
    assert vm[DEV_LOCK] == lock_dev(vm[DEV])
    assert without(vm[DEV_TICKET], 'pairing') == without(vm[DEV], 'pairing') and vm[DEV_TICKET]['pairing'] == P_TICKET
    assert without(vm[DEV_STALE], 'as_of') == without(vm[DEV], 'as_of')
    assert vm[DEV]['lease_epoch_text'] is not None and vm[DEV_NONE]['lease_epoch_text'] is None
    assert {r for r in S06_VMS if vm[r]['empty_label'] is not None} == {DEV_NONE}
    # S03 갈래.
    assert vm[ACC_LOCK] == lock_acc(vm[ACC])
    assert any('SAF-309' in (o['blocked_text'] or '') for m in vm[ACC]['mappings'] for o in m['options'])
    assert any(m['account_label'] is None for m in vm[ACC_UNMAP]['mappings'])
    assert not any(m['account_label'] is None for m in vm[ACC]['mappings'])
    # 결과 — 벌마다 레벨 5값 · id 전수 · 사전 · 넘김·재시도 0(K33).
    want_ids = {CRED_RES: {'CREDENTIAL_VERIFY'}, DEV_RES: {'DEVICE_PAIRING_TICKET_CREATE', 'DEVICE_TOKEN_REVOKE'},
                ACC_RES: {'ACCOUNT_MAP_SLEEVE', 'ACCOUNT_VERIFY_MAPPING'}}
    seen_codes = set()
    for rel, n in ((CRED_RES, 6), (DEV_RES, 6), (ACC_RES, 8)):
        rs = envs[rel]['rows']
        assert len(rs) == n and {r['level'] for r in rs} == LEVELS, rel
        assert all(list(r) == RESULT_KEYS for r in rs), rel
        assert {r['id'] for r in rs} == want_ids[rel], rel
        assert all(r['handoff_route'] is None and r['retryable'] is False for r in rs), rel
        for r in rs:
            assert r['reason_code'] is None or r['reason_code'] in RESULT_CODES, r
            seen_codes.add(r['reason_code'])
    assert seen_codes - {None} == RESULT_CODES

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
    print('gen_r7_v120_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 1 · 신설 %d) · contract 1.20.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
