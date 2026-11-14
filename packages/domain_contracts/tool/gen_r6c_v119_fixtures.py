#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.19(R6c 선행 M2 보강 + 엔진 E15i 굳은 몫 · 01 §28) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r6c_v119_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r6_v118_fixtures.py(계약 v1.18 · 그 스크립트는 v1.18 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-14_R6c선행_계약v1.19_설계서.md` §5 · 248 → 256 = 신설 8 · 개정 0 · 버전 줄만 248)
  (a) 전 봉투의 "contract_version": "1.18.0" → "1.19.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 8 — M9 S05 운용 관리 VM 7(`m9/operations_*`) + S05 동작 결과 1(`m9/operations_action_results`).
  (c) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*` · `check_*`.

🔴 레벨 5값 전수 — operations_sim_auto 전 `level` 키 · operations_action_results — 각 표본 안에서(«표본 동치» 방지).
🔴 체험 상태 4값 전수(operations_sim_auto) · 잡 상태 5값 전수 + FAILED 의 ACT·BLOCKED 둘 다(operations_sim_auto).
🔴 m9 신설 표본 전 문자열 «DRY_RUN» 0(G-63 확장) · 손익 낱말 0 · 금액 글자 0 · 토큰·URL 0 ·
   hold 표본의 모드 카드 글자에 «모의» 0(05 ⑩).
🔴 체험 글자 = 엔진 core_engine/lib/src/sim/sim_trial.dart 문장 꼴 · 승격 결과 headline = 엔진
   core_engine/lib/src/mode/live_promotion.dart `livePromotionHeadline` 꼴(합성).

멱등: 버전 치환은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r6c_v119_fixtures.py
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
# 계약 1.18.0 · 픽스처 248 의 기준 커밋(origin/main · E15e2 #161 — 계약 패키지 = PR #142 이후 무변경).
BASE = '175cbd52c268319f318d719ce498d2bd955b4348'

OLD_VER = '"contract_version": "1.18.0"'
NEW_VER = '"contract_version": "1.19.0"'
BASE_FILES = 248
WANT_FILES = 256

RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'(?<!이 )화면이|화면은|화면·')      # 사용자 문장 자리의 개발자 메모(H50 · «이 화면이» = 사용자 문장)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6
PNL_WORD = re.compile(r'수익률|평가액|손익')               # C-53 ③
MONEY = re.compile(r'[0-9][0-9,]*원')                      # C-53 ③
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PHONE = re.compile(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}')    # C-51 ⑤ 개인 전화번호 꼴
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
URL_LIKE = re.compile(r'https?://|github\.com|\.io/')      # 저장소 주소·URL 0
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}

# ── 라우트(lib/src/navigation/app_links.dart 와 같은 글자 — C-33 ① 이 등록을 다시 본다) ──
R = {
    'm5_handover_wizard': 'aaq://m5/handover-wizard',
    'm5_handover_gate': 'aaq://m5/handover-gate',
}

# ── 엔진 글자(labels/sim_codes.dart · settings_codes.dart 와 같은 글자 — C-53 ⑬ 이 다시 본다) ──
TRIAL_ITEMS = ['SIM_TRIAL_TWO_TRADING_WEEKS', 'SIM_TRIAL_MONTH_END_REBALANCE', 'SIM_TRIAL_RECONCILIATION',
               'SIM_TRIAL_RESUME', 'SIM_TRIAL_KILL_SWITCH']
TRIAL_STATE_LEVEL = {'PASSED': 'OK', 'AUTO_PASSED': 'OK', 'OPEN': 'WATCH', 'OPEN_WARN': 'INFO'}
JOB_STATUS = {'SUCCESS', 'LATE', 'FAILED', 'HOLIDAY', 'NONE'}
STOP_REASONS = {'PLANNED_MAINTENANCE', 'TROUBLESHOOTING'}
RUN_MODES = {'SIM_INTERNAL', 'SIM_BROKER', 'LIVE'}
OPERATING_MODES = {'AUTO_TRADE', 'ADVISORY'}
S05_IDS = {'RUNTIME_MODE_SWITCH_REQUEST', 'RUNTIME_OPERATING_MODE_SWITCH_REQUEST', 'RUNTIME_ENGINE_START',
           'RUNTIME_ENGINE_STOP', 'RUNTIME_LIVE_PROMOTION'}
RESULT_CODES = {
    # SettingsResultCodes(v1.18 3 + v1.19 2)
    'BIOMETRIC_UNAVAILABLE', 'CONNECTION_TEST_FAILED', 'SYNC_ALREADY_RUNNING', 'ENGINE_ALREADY_RUNNING',
    'ENGINE_ALREADY_STOPPED',
    # ModeStartupCodes · AdviceRejectCodes.modeCombinationDenied
    'SAF-405', 'CREDENTIAL_ENV_MISMATCH', 'MODE_COMBINATION_DENIED',
    # LiveObservationBlockCodes
    'LIVE_OBSERVATION_KILL_SWITCH', 'LIVE_OBSERVATION_TRADING_BLOCK', 'LIVE_OBSERVATION_UNKNOWN_ORDERS',
    'LIVE_OBSERVATION_NOT_ENOUGH_DAYS',
    # LivePromotionResultCodes
    'HANDOVER_SESSION_INVALID', 'LIVE_PROMOTION_NOT_OBSERVING', 'LIVE_PROMOTION_NOT_AUTO_TRADE',
    'LIVE_PROMOTION_CLOCK_BEHIND', 'LIVE_PROMOTION_ROLLED_BACK',
}

# ── 이름 ─────────────────────────────────────────────────────────────────
SIM_AUTO = 'm9/operations_sim_auto.json'
SIM_DONE = 'm9/operations_sim_complete.json'
LIVE_OBS = 'm9/operations_live_observe.json'
LIVE_PROMO = 'm9/operations_live_promotable.json'
LIVE_HOLD = 'm9/operations_live_hold_keys.json'
ADVISORY = 'm9/operations_advisory.json'
LOCKED = 'm9/operations_locked.json'
RESULTS = 'm9/operations_action_results.json'

VMS = [SIM_AUTO, SIM_DONE, LIVE_OBS, LIVE_PROMO, LIVE_HOLD, ADVISORY, LOCKED]
NEW_FILES = VMS + [RESULTS]
MODE_PICK = 'm8/onboarding_mode_pick.json'

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.19.0',
    'generated_at': '2026-11-14T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261114,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(label, observed='2026-08-31T09:00:00Z', trade_date='2026-08-31'):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': label}


AS5 = as_of('운용 기준 2026-08-31 09:00')
# 🔵 K23 — hold 표본만 미국 서머타임 종료 주간(DST 표식의 그럴듯함 · 합성).
AS5H = as_of('운용 기준 2026-11-02 09:00', '2026-11-02T09:00:00Z', '2026-11-02')
AS5R = as_of('동작 기준 2026-08-31')


# ────────────────────────────────────────────────────────────────────────
# 조각(§5-1 · 빈칸 = null · `{id, args, label}` = SettingsActionCall)
# ────────────────────────────────────────────────────────────────────────
def chip(label, level, promotion_label=None):
    return {'label': label, 'level': level, 'promotion_label': promotion_label}


CH_SIMI = chip('모의 · 내부 가상 체결 · 자동 매매', 'INFO')
CH_SIMB = chip('모의 · KIS 모의투자 서버 · 자동 매매', 'INFO')
CH_OBS1 = chip('실전 · 관찰 중 · 골든벡터 통과', 'WATCH', '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)')
CH_OBS2 = chip('실전 · 관찰 중 · 골든벡터 통과', 'WATCH', '승격 가능 — 무결 거래일을 채웠습니다(2/2)')
CH_HOLD = chip('실전 · 키 검증 대기', 'WATCH')
CH_ADV = chip('실전 · 투자 안내 · 골든벡터 통과', 'OK')


def call(id_, args, label):
    return {'id': id_, 'args': dict(args), 'label': label}


SW_LIVE = call('RUNTIME_MODE_SWITCH_REQUEST', {'run_mode': 'LIVE'}, '실전 전환 요청')
SW_OP_AUTO = call('RUNTIME_OPERATING_MODE_SWITCH_REQUEST', {'operating_mode': 'AUTO_TRADE'}, '자동 매매로 바꾸기 요청')
PROMO = call('RUNTIME_LIVE_PROMOTION', {}, '실전 집행으로 올리기')
START = call('RUNTIME_ENGINE_START', {}, '엔진 시작')
STOP_PM = call('RUNTIME_ENGINE_STOP', {'reason_code': 'PLANNED_MAINTENANCE'}, '계획 점검·업데이트')
STOP_TS = call('RUNTIME_ENGINE_STOP', {'reason_code': 'TROUBLESHOOTING'}, '이상 조사')

NOTICE_LIVE = '실전 전환을 요청하면 기존 계획이 무효화되고 다음 정규 사이클에 재계산됩니다.'

OBS_STATE = '실전 관찰 중 · 정기 리밸런싱 2026-09-01 09:10 전에 승격해야 첫 주문이 나갑니다'
OBS1 = {'observed_trading_days': 1, 'required_trading_days': 2, 'progress_text': '무결 거래일 1/2',
        'promotion_available': False, 'state_label': OBS_STATE}
OBS2 = {'observed_trading_days': 2, 'required_trading_days': 2, 'progress_text': '무결 거래일 2/2',
        'promotion_available': True, 'state_label': OBS_STATE}

MODE_KEYS = ['label', 'level', 'hold_label', 'observation', 'promotion_action', 'switch_notice_text', 'switch_actions']


def mode_card(*vals):
    assert len(vals) == len(MODE_KEYS)
    return dict(zip(MODE_KEYS, copy.deepcopy(list(vals))))


MODE_SIMI = mode_card('모의 · 내부 가상 체결', 'INFO', None, None, None, NOTICE_LIVE, [SW_LIVE])
MODE_SIMB = mode_card('모의 · KIS 모의투자 서버', 'INFO', None, None, None, NOTICE_LIVE, [SW_LIVE])
MODE_OBS1 = mode_card('실전 · 관찰 중', 'WATCH', None, OBS1, None, None, [])
MODE_OBS2 = mode_card('실전 · 관찰 중', 'WATCH', None, OBS2, PROMO, None, [])
MODE_HOLD = mode_card('실전 · 자동 주문', 'WATCH', '실키 검증 전 — 배치를 멈췄습니다. 키 관리에서 검증하면 다시 돕니다.',
                      None, None, None, [])
MODE_ADV = mode_card('실전 · 실계좌', 'OK', None, None, None, None, [])

TRUST_KEYS = ['grade', 'level', 'label', 'consequence_line', 'upgrade_hint', 'last_verified_on', 'action_deep_link']


def trust(*vals):
    assert len(vals) == len(TRUST_KEYS)
    return dict(zip(TRUST_KEYS, vals))


TR_SIMI = trust('RECONCILED', 'OK', '원장 정상 — 모의', '내부 가상 체결이라 대사 차이가 생기지 않습니다.', None, None, None)
TR_SIMB = trust('RECONCILED', 'OK', '모의 서버 대사 일치', '오늘 07:02 대사에서 차이 0건입니다.', None, '2026-08-31', None)
TR_LIVE = trust('RECONCILED', 'OK', '브로커 대사 일치', '오늘 07:02 대사에서 차이 0건입니다.', None, '2026-08-31', None)
TR_HOLD = trust('RECONCILED', 'OK', '브로커 대사 일치', '10월 30일 대사에서 차이 0건입니다.', None, '2026-10-30', None)
TR_ADV = trust('SELF_REPORTED', 'WATCH', '자가 기록 — 브로커 대조 없음', '마지막 실사 후 28일 — 이달 안에 실사하면 유지됩니다.',
               '대사 전용 키를 등록하면 대조가 켜집니다', '2026-08-03', None)


def gate(code, label, state):
    return {'code': code, 'label': label, 'state': state, 'blocked_reason_code': None}


SG_NA = gate('M5_11_WIZARD', '운영 방식 전환 위저드', 'NOT_APPLICABLE')
SG_PASS = gate('LEDGER_SELF_AUDIT', '원장 실사 31일 안', 'PASS')
SG_BLOCK = gate('BROKER_OPEN_ORDERS', '브로커 미체결 0건', 'BLOCK')

OMV_KEYS = ['current', 'label', 'explain_line', 'options', 'trust', 'switch_gates', 'switch_actions']
AUTO_EXPLAIN = '규칙이 정한 대로 앱이 주문을 냅니다.'


def omv(current, label, explain, tr, gates, actions, options):
    return dict(zip(OMV_KEYS, copy.deepcopy([current, label, explain, options, tr, gates, actions])))


TRIAL_CHECK_KEYS = ['item_code', 'label', 'detail_text', 'item_state', 'state_label', 'level']


def check(*vals):
    assert len(vals) == len(TRIAL_CHECK_KEYS)
    return dict(zip(TRIAL_CHECK_KEYS, vals))


TRIAL_PROG = {
    'headline': '모의 체험 진행 중 — 남은 항목 2개',
    'summary_text': '체험 9일 · 배치 6회 · 리밸런싱 0회 · 경보 2건 · 개입 0회',
    'checks': [
        check('SIM_TRIAL_TWO_TRADING_WEEKS', '연속 2거래주 정상 배치', '연속 정상 배치 6/10세션', 'OPEN', '아직', 'WATCH'),
        check('SIM_TRIAL_MONTH_END_REBALANCE', '월말 정기 리밸런싱 1회',
              '아직 없음 — 다음 정기 리밸런싱 2026-09-01 08:00 · 건너뛰면 경고 후 진행', 'OPEN_WARN', '아직 — 경고 후 진행',
              'INFO'),
        check('SIM_TRIAL_RECONCILIATION', '대사 0오차', '내부 가상 체결 — 브로커 대사 없음(자동 통과)', 'AUTO_PASSED', '자동 통과',
              'OK'),
        check('SIM_TRIAL_RESUME', 'X2 재개 1회 시연', '재개 1회 끝남', 'PASSED', '통과', 'OK'),
        check('SIM_TRIAL_KILL_SWITCH', '킬스위치 발동·재개 1회 연습', '아직 없음', 'OPEN', '아직', 'WATCH'),
    ],
}
TRIAL_DONE = {
    'headline': '체험 5항목을 모두 채웠습니다.',
    'summary_text': '체험 36일 · 배치 25회 · 리밸런싱 1회 · 경보 4건 · 개입 0회',
    'checks': [
        check('SIM_TRIAL_TWO_TRADING_WEEKS', '연속 2거래주 정상 배치', '연속 정상 배치 10세션 채움', 'PASSED', '통과', 'OK'),
        check('SIM_TRIAL_MONTH_END_REBALANCE', '월말 정기 리밸런싱 1회', '월말 계획 집행 확인', 'PASSED', '통과', 'OK'),
        check('SIM_TRIAL_RECONCILIATION', '대사 0오차', '대사 25회 · 불일치 0', 'PASSED', '통과', 'OK'),
        check('SIM_TRIAL_RESUME', 'X2 재개 1회 시연', '재개 1회 끝남', 'PASSED', '통과', 'OK'),
        check('SIM_TRIAL_KILL_SWITCH', '킬스위치 발동·재개 1회 연습', '발동 · 재개 연습 끝남', 'PASSED', '통과', 'OK'),
    ],
}


def cond(label, progress, level):
    return {'label': label, 'progress_text': progress, 'level': level}


RC1 = cond('주문 사고 0건', '충족', 'OK')
RC2 = cond('신호 일치율 100%', '충족', 'OK')
RC3 = cond('하트비트 결측 0건 · 접수 마감 위반 0건', '충족', 'OK')
RC4 = cond('저널 이탈률 사전 등록치 이하', '집계 중 — 기록 2건', 'INFO')
RC5 = cond('스트레스 이벤트 1회 통과', '아직 — 휴장 전후 · 월말 · DST 전환 · 조기폐장일 중 하나', 'INFO')
RC4OK = cond('저널 이탈률 사전 등록치 이하', '충족', 'OK')
RC5OK = cond('스트레스 이벤트 1회 통과', '충족 — 10월 30일 월말', 'OK')

RAMP_KEYS = ['level_label', 'level', 'conditions', 'empty_label', 'dst_notice_text']


def ramp(*vals):
    assert len(vals) == len(RAMP_KEYS)
    return dict(zip(RAMP_KEYS, copy.deepcopy(list(vals))))


RAMP_SIM = ramp('L1 · 최저 단계', 'INFO', [], '모의 계좌에서는 승급 조건을 세지 않습니다. 실전으로 바꾸면 L1 부터 셉니다.', None)
RAMP_L1 = ramp('L1 · 5% · 최저 단계', 'INFO', [RC1, RC2, RC3, RC4, RC5], None, None)
RAMP_DST = ramp('L2 · 15% — DST 주간이라 한 단계 낮춤(원래 L3)', 'WATCH', [RC1, RC2, RC3, RC4OK, RC5OK], None,
                '미국 서머타임 전환 주간이라 램프를 한 단계 낮춰 두었습니다. 주문 차단이 아니라 상태 표식입니다.')

JOB_KEYS = ['label', 'schedule_text', 'last_run_text', 'status_code', 'state_label', 'level', 'detail_line']


def job(*vals):
    assert len(vals) == len(JOB_KEYS)
    return dict(zip(JOB_KEYS, vals))


J_RECON = job('아침 대사', '평일 07:00 · 유예 2시간', '오늘 07:02 끝남', 'SUCCESS', '성공', 'OK', None)
J_ORDER_LATE = job('국내 주문', '평일 09:10 · 유예 1시간', '오늘 10:31 끝남', 'LATE', '지연 — 성공', 'WATCH',
                   '유예를 21분 넘겨 끝났습니다. 주문은 모두 나갔습니다.')
J_US_HOL = job('미국 데이터', '미국 거래일 다음 날 07:30 · 유예 2시간', '오늘 07:30 — 미국 휴장이라 본체를 돌리지 않았습니다',
               'HOLIDAY', '휴장', 'INFO', None)
J_DATA_FAIL = job('일별 데이터', '평일 18:30 · 유예 2시간', '8월 28일 18:30 실패', 'FAILED', '실패', 'ACT',
                  '시세를 받지 못했습니다. 다음 회차가 다시 받습니다.')
J_SNAP_FAIL = job('평가 스냅숏', '평일 20:30 · 유예 1시간', '8월 28일 20:31 실패', 'FAILED', '실패', 'BLOCKED',
                  '원장 해시를 기록하지 못했습니다. 다음 회차 전에 확인이 필요합니다.')
J_MONTH_NONE = job('월말 리밸런싱', '월말 다음 거래일 08:00 · 유예 1시간', '아직 돈 적 없음', 'NONE', '아직 없음', 'INFO', None)
J_ORDER_OK = job('국내 주문', '평일 09:10 · 유예 1시간', '오늘 09:12 끝남', 'SUCCESS', '성공', 'OK', None)
J_ORDER_OBS = job('국내 주문', '평일 09:10 · 유예 1시간', '오늘 09:12 끝남 — 관찰 중이라 주문을 내지 않았습니다', 'SUCCESS', '성공',
                  'OK', None)
J_CLOSE = job('장 마감 확인', '평일 15:45 · 유예 1시간', '오늘 15:46 끝남', 'SUCCESS', '성공', 'OK', None)
J_SIGNAL = job('일별 신호', '평일 20:00 · 유예 1시간', '8월 28일 20:01 끝남', 'SUCCESS', '성공', 'OK', None)
J_SNAP_OK = job('평가 스냅숏', '평일 20:30 · 유예 1시간', '8월 28일 20:31 끝남', 'SUCCESS', '성공', 'OK', None)
J_SNAP_LATE = job('평가 스냅숏', '평일 20:30 · 유예 1시간', '8월 28일 21:52 끝남', 'LATE', '지연 — 성공', 'WATCH', None)
J_DATA_OK = job('일별 데이터', '평일 18:30 · 유예 2시간', '8월 28일 18:34 끝남', 'SUCCESS', '성공', 'OK', None)
H_RECON = job('아침 대사', '평일 07:00 · 유예 2시간', '10월 30일 07:02 끝남', 'SUCCESS', '성공', 'OK', None)
H_ORDER = job('국내 주문', '평일 09:10 · 유예 1시간', '10월 30일 09:12 끝남', 'SUCCESS', '성공', 'OK',
              '키 검증 전까지 다음 회차를 돌리지 않습니다.')
H_SNAP = job('평가 스냅숏', '평일 20:30 · 유예 1시간', '10월 30일 21:52 끝남', 'LATE', '지연 — 성공', 'WATCH', None)

CTRL_KEYS = ['state_label', 'level', 'start_action', 'stop_prompt_text', 'stop_actions']


def ctrl(*vals):
    assert len(vals) == len(CTRL_KEYS)
    return dict(zip(CTRL_KEYS, copy.deepcopy(list(vals))))


CTRL_RUN = ctrl('돌고 있음 — 다음 잡: 평일 18:30 일별 데이터', 'OK', None,
                '엔진을 멈추는 까닭을 고르십시오. 킬스위치와 다릅니다 — 멈춘 동안 예약된 잡이 돌지 않습니다.', [STOP_PM, STOP_TS])
CTRL_STOP = ctrl('멈춤 — 10월 31일 22:10 계획 점검으로 멈췄습니다', 'WATCH', START, None, [])

UG_WAIT = {'state_label': '새 버전 대기 — 비거래 시간대에 바꿉니다',
           'body_text': '받아 둔 새 버전이 있습니다. 오늘 장이 끝나고 미체결이 없으면 바꿉니다.', 'level': 'INFO'}
UG_HOLD = {'state_label': '업데이트 보류 — 확인 안 된 주문이 있습니다',
           'body_text': '확인 안 된 주문 1건이 정리되면 다음 비거래 시간대에 바꿉니다.', 'level': 'WATCH'}

LRN = '지난 실전 전환 요청이 위저드 2단계(골든벡터 셀프테스트)에서 멈췄습니다. 셀프테스트를 다시 통과하면 다시 요청할 수 있습니다.'
LOCKED_LABEL = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'

VM_KEYS = ['status_chip', 'mode', 'operating_mode', 'trial', 'ramp', 'jobs', 'control', 'update_gate',
           'last_request_notice', 'locked_label', 'as_of']


def ops_vm(*vals):
    assert len(vals) == len(VM_KEYS)
    return dict(zip(VM_KEYS, copy.deepcopy(list(vals))))


def lock(vm):
    """K19 — 잠김 판: 동작 칸 5 비움 + 머리 한 줄(그 밖 바이트 같음)."""
    out = copy.deepcopy(vm)
    out['mode']['switch_actions'] = []
    out['mode']['promotion_action'] = None
    out['operating_mode']['switch_actions'] = []
    out['control']['start_action'] = None
    out['control']['stop_actions'] = []
    out['control']['stop_prompt_text'] = None
    out['locked_label'] = LOCKED_LABEL
    return out


def build_vms(options):
    """OMV 의 `options` = m8/onboarding_mode_pick 의 두 객체 글자 그대로(같은 엔진 문구 · 차례 AUTO_TRADE → ADVISORY)."""
    omv_simi = omv('AUTO_TRADE', '자동 매매', AUTO_EXPLAIN, TR_SIMI, [SG_NA], [], options)
    omv_simb = omv('AUTO_TRADE', '자동 매매', AUTO_EXPLAIN, TR_SIMB, [SG_NA], [], options)
    omv_live = omv('AUTO_TRADE', '자동 매매', AUTO_EXPLAIN + ' 관찰 중에는 주문을 내지 않습니다.', TR_LIVE, [SG_NA], [], options)
    omv_hold = omv('AUTO_TRADE', '자동 매매', AUTO_EXPLAIN, TR_HOLD, [SG_NA], [], options)
    omv_adv = omv('ADVISORY', '투자 안내(수동 매매)', '무엇을 살지 알려 드리고 주문은 직접 내십니다.', TR_ADV, [SG_PASS, SG_BLOCK],
                  [SW_OP_AUTO], options)
    live_promo = ops_vm(CH_OBS2, MODE_OBS2, omv_live, None, RAMP_L1, [J_RECON, J_ORDER_OBS, J_SNAP_OK, J_MONTH_NONE],
                        CTRL_RUN, None, None, None, AS5)
    return {
        SIM_AUTO: ops_vm(CH_SIMI, MODE_SIMI, omv_simi, TRIAL_PROG, RAMP_SIM,
                         [J_RECON, J_ORDER_LATE, J_US_HOL, J_DATA_FAIL, J_SNAP_FAIL, J_MONTH_NONE], CTRL_RUN, None,
                         None, None, AS5),
        SIM_DONE: ops_vm(CH_SIMB, MODE_SIMB, omv_simb, TRIAL_DONE, RAMP_SIM, [J_RECON, J_ORDER_OK, J_CLOSE, J_SIGNAL],
                         CTRL_RUN, UG_WAIT, LRN, None, AS5),
        LIVE_OBS: ops_vm(CH_OBS1, MODE_OBS1, omv_live, None, RAMP_L1, [J_RECON, J_ORDER_OBS, J_SNAP_OK, J_MONTH_NONE],
                         CTRL_RUN, None, None, None, AS5),
        LIVE_PROMO: live_promo,
        LIVE_HOLD: ops_vm(CH_HOLD, MODE_HOLD, omv_hold, None, RAMP_DST, [H_RECON, H_ORDER, H_SNAP], CTRL_STOP, UG_HOLD,
                          None, None, AS5H),
        ADVISORY: ops_vm(CH_ADV, MODE_ADV, omv_adv, None, RAMP_L1, [J_DATA_OK, J_SIGNAL, J_SNAP_LATE, J_MONTH_NONE],
                         CTRL_RUN, None, None, None, AS5),
        LOCKED: lock(live_promo),
    }


RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']


def result(*vals):
    """`retryable` 은 늘 false(버튼 = VM 의 호출뿐) — 마지막 칸은 적지 않는다."""
    assert len(vals) == len(RESULT_KEYS) - 1
    return dict(zip(RESULT_KEYS, vals + (False,)))


RESULT_ROWS = [
    result('ar_s05_01', 'RUNTIME_MODE_SWITCH_REQUEST', 'INFO', '실전 전환 요청을 받았습니다. 실전 전환 위저드로 넘어갑니다.', None,
           R['m5_handover_wizard']),
    result('ar_s05_02', 'RUNTIME_MODE_SWITCH_REQUEST', 'INFO', '안내 개시 요청을 받았습니다. 안내 개시 게이트로 넘어갑니다.', None,
           R['m5_handover_gate']),
    result('ar_s05_03', 'RUNTIME_OPERATING_MODE_SWITCH_REQUEST', 'INFO', '운영 방식 전환 요청을 받았습니다. 전환 위저드로 넘어갑니다.',
           None, R['m5_handover_wizard']),
    result('ar_s05_04', 'RUNTIME_ENGINE_STOP', 'OK', '엔진을 멈췄습니다. 다시 시작할 때까지 예약된 잡이 돌지 않습니다.', None, None),
    result('ar_s05_05', 'RUNTIME_ENGINE_STOP', 'INFO', '이미 멈춰 있습니다.', 'ENGINE_ALREADY_STOPPED', None),
    result('ar_s05_06', 'RUNTIME_ENGINE_START', 'INFO', '이미 돌고 있습니다.', 'ENGINE_ALREADY_RUNNING', None),
    result('ar_s05_07', 'RUNTIME_ENGINE_START', 'BLOCKED', '금지된 모드 조합이라 시작하지 않았습니다. 직전 조합을 그대로 둡니다.',
           'MODE_COMBINATION_DENIED', None),
    result('ar_s05_08', 'RUNTIME_ENGINE_START', 'ACT', '승인되지 않은 설정 변경이 있어 시작하지 않았습니다.', 'SAF-405', None),
    result('ar_s05_09', 'RUNTIME_ENGINE_START', 'BLOCKED', '저장된 키의 환경이 지금 모드와 달라 시작하지 않았습니다.',
           'CREDENTIAL_ENV_MISMATCH', None),
    result('ar_s05_10', 'RUNTIME_LIVE_PROMOTION', 'WATCH', '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)',
           'LIVE_OBSERVATION_NOT_ENOUGH_DAYS', None),
    result('ar_s05_11', 'RUNTIME_LIVE_PROMOTION', 'OK', '실전 집행으로 올렸습니다 — 다음 회차부터 실제 주문을 냅니다.', None, None),
    result('ar_s05_12', 'RUNTIME_LIVE_PROMOTION', 'BLOCKED', '생체 확인이 없어 올리지 않았습니다.', 'BIOMETRIC_UNAVAILABLE', None),
    result('ar_s05_13', 'RUNTIME_LIVE_PROMOTION', 'INFO', '실전 관찰 중이 아니라 올릴 것이 없습니다.', 'LIVE_PROMOTION_NOT_OBSERVING',
           None),
]


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_r6_v118_fixtures.py 와 같은 꼴)
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
    """봉투(v1.15~v1.18 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def mode_pick_options():
    env = json.loads(base_text(MODE_PICK))
    options = env['rows'][0]['options']
    assert [o['mode'] for o in options] == ['AUTO_TRADE', 'ADVISORY'], options
    return copy.deepcopy(options)


def new_files(vms):
    texts = {}
    for rel, vm in vms.items():
        texts[rel] = ser_envelope(vm_envelope([vm], vm['as_of']), False)
    texts[RESULTS] = ser_envelope(vm_envelope(RESULT_ROWS, AS5R), True)
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


def self_check_file(rel, s, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE' and env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    if new:
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
            assert not DEV_MEMO.search(v), '%s %s — 개발자 메모: %s' % (rel, path, v)
            assert not ACCOUNT_LIKE.search(v), '%s %s — 계좌꼴: %s' % (rel, path, v)
            assert not PHONE.search(v), '%s %s — 전화번호 꼴: %s' % (rel, path, v)
            assert not LONG_ALNUM.search(v), '%s %s — 앱키 꼴: %s' % (rel, path, v)
            assert not URL_LIKE.search(v), '%s %s — URL 꼴: %s' % (rel, path, v)
            assert 'DRY_RUN' not in v, '%s %s — DRY_RUN 글자: %s' % (rel, path, v)
            assert not PNL_WORD.search(v), '%s %s — 손익 낱말: %s' % (rel, path, v)
            assert not MONEY.search(v), '%s %s — 금액 글자: %s' % (rel, path, v)
            if v.startswith('aaq://'):
                assert v in R.values(), '%s %s — 라우트 글자: %s' % (rel, path, v)
        ks = set(keys(env))
        assert not any(PNL_KEY.search(k) for k in ks), rel
        # C-52 ⑥ · C-50 ⑨ walker 키 0 · 삭제·금지 칸 0(K3 · K7 · K17).
        for bad in ('action', 'actions', 'select_action', 'scope', 'contribution', 'handover_plan', 'target',
                    'is_viewer', 'action_available'):
            assert bad not in ks, (rel, bad)
        assert not any('force' in k for k in ks), rel
    return env


def check_call(a, id_, arg_keys):
    assert a['id'] == id_ and set(a['args']) == set(arg_keys) and a['label'], a


def check_vm(rel, vm):
    assert list(vm) == VM_KEYS, rel
    assert list(vm['mode']) == MODE_KEYS and list(vm['operating_mode']) == OMV_KEYS, rel
    assert list(vm['ramp']) == RAMP_KEYS and list(vm['control']) == CTRL_KEYS, rel
    assert all(list(j) == JOB_KEYS for j in vm['jobs']) and vm['jobs'], rel
    assert set(levels(vm)) <= LEVELS, rel
    m, o, c, r = vm['mode'], vm['operating_mode'], vm['control'], vm['ramp']
    # ④ 동작 호출 — 자리마다 id·args.
    for a in m['switch_actions']:
        check_call(a, 'RUNTIME_MODE_SWITCH_REQUEST', ['run_mode'])
        assert a['args']['run_mode'] in RUN_MODES, rel
    for a in o['switch_actions']:
        check_call(a, 'RUNTIME_OPERATING_MODE_SWITCH_REQUEST', ['operating_mode'])
        assert a['args']['operating_mode'] in OPERATING_MODES and a['args']['operating_mode'] != o['current'], rel
    if c['start_action'] is not None:
        check_call(c['start_action'], 'RUNTIME_ENGINE_START', [])
    reasons = []
    for a in c['stop_actions']:
        check_call(a, 'RUNTIME_ENGINE_STOP', ['reason_code'])
        reasons.append(a['args']['reason_code'])
    assert set(reasons) <= STOP_REASONS and len(reasons) == len(set(reasons)), rel
    if m['promotion_action'] is not None:
        check_call(m['promotion_action'], 'RUNTIME_LIVE_PROMOTION', [])
    # ⑤ 고지 짝.
    assert (m['switch_notice_text'] is not None) == bool(m['switch_actions']), rel
    # ⑥ 엔진 제어(잠김 밖 = 시작 xor 중지).
    assert bool(c['stop_actions']) == (c['stop_prompt_text'] is not None), rel
    if vm['locked_label'] is None:
        assert (c['start_action'] is not None) != bool(c['stop_actions']), rel
    else:
        assert not m['switch_actions'] and m['promotion_action'] is None and not o['switch_actions'], rel
        assert c['start_action'] is None and not c['stop_actions'] and c['stop_prompt_text'] is None, rel
    # ⑧ 관찰·승격.
    assert (m['observation'] is not None) == (vm['status_chip']['promotion_label'] is not None), rel
    if m['promotion_action'] is not None:
        assert m['observation']['promotion_available'] is True, rel
    # ⑨ 체험.
    t = vm['trial']
    if t is not None:
        assert list(t) == ['headline', 'summary_text', 'checks'] and t['checks'], rel
        codes = [x['item_code'] for x in t['checks']]
        assert codes == TRIAL_ITEMS, rel
        for x in t['checks']:
            assert list(x) == TRIAL_CHECK_KEYS and TRIAL_STATE_LEVEL[x['item_state']] == x['level'], (rel, x)
    # ⑩ 잡.
    for j in vm['jobs']:
        sc, lv = j['status_code'], j['level']
        assert sc in JOB_STATUS, (rel, j)
        want = {'SUCCESS': {'OK'}, 'LATE': {'WATCH'}, 'HOLIDAY': {'INFO'}, 'NONE': {'INFO'},
                'FAILED': {'ACT', 'BLOCKED'}}[sc]
        assert lv in want, (rel, j)
    # ⑪ 램프.
    assert (not r['conditions']) == (r['empty_label'] is not None), rel
    assert all(x['level'] in ('OK', 'INFO', 'WATCH') and list(x) == ['label', 'progress_text', 'level']
               for x in r['conditions']), rel
    if r['dst_notice_text'] is not None:
        assert r['level'] not in ('ACT', 'BLOCKED'), rel
    assert 'L0' not in r['level_label'], rel
    assert vm['as_of'] in (AS5, AS5H), rel


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert MODE_PICK in rels
    assert len(NEW_FILES) == 8 and len(set(NEW_FILES)) == 8

    vms = build_vms(mode_pick_options())
    out = new_files(vms)
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    vm = {rel: envs[rel]['rows'][0] for rel in VMS}
    for rel in VMS:
        assert len(envs[rel]['rows']) == 1, rel
        assert vm[rel]['as_of'] == envs[rel]['as_of'], rel
        check_vm(rel, vm[rel])
    # 전수 — sim_auto 레벨 5값 · 체험 상태 4값 · 잡 상태 5값 + FAILED ACT·BLOCKED.
    sa = vm[SIM_AUTO]
    assert set(levels(sa)) == LEVELS
    assert {x['item_state'] for x in sa['trial']['checks']} == set(TRIAL_STATE_LEVEL)
    assert {j['status_code'] for j in sa['jobs']} == JOB_STATUS
    assert {j['level'] for j in sa['jobs'] if j['status_code'] == 'FAILED'} == {'ACT', 'BLOCKED'}
    assert {a['args']['reason_code'] for a in sa['control']['stop_actions']} == STOP_REASONS
    assert all(x['item_state'] == 'PASSED' for x in vm[SIM_DONE]['trial']['checks'])
    # 갈래 — 체험 = SIM 두 벌만 · 관찰·승격 · hold · DST · 잠김 · 게이트 BLOCK.
    assert {rel for rel in VMS if vm[rel]['trial'] is not None} == {SIM_AUTO, SIM_DONE}
    assert vm[LIVE_OBS]['mode']['observation']['promotion_available'] is False
    assert vm[LIVE_OBS]['mode']['promotion_action'] is None
    assert vm[LIVE_PROMO]['mode']['observation']['promotion_available'] is True
    assert vm[LIVE_PROMO]['mode']['promotion_action'] is not None
    hold = vm[LIVE_HOLD]
    assert '모의' not in hold['mode']['label'] and '모의' not in hold['mode']['hold_label']
    assert hold['ramp']['dst_notice_text'] and hold['as_of'] == AS5H
    assert hold['control']['start_action'] is not None and not hold['control']['stop_actions']
    assert {rel for rel in VMS if vm[rel]['ramp']['dst_notice_text']} == {LIVE_HOLD}
    assert not vm[SIM_AUTO]['ramp']['conditions'] and not vm[SIM_DONE]['ramp']['conditions']
    assert vm[LIVE_OBS]['ramp']['conditions']
    assert vm[LOCKED] == lock(vm[LIVE_PROMO]) and vm[LOCKED]['locked_label'] == LOCKED_LABEL
    assert {rel for rel in VMS if vm[rel]['locked_label'] is not None} == {LOCKED}
    assert [g['state'] for g in vm[ADVISORY]['operating_mode']['switch_gates']] == ['PASS', 'BLOCK']
    assert vm[ADVISORY]['operating_mode']['switch_actions'] and vm[ADVISORY]['operating_mode']['current'] == 'ADVISORY'
    assert vm[SIM_DONE]['update_gate'] and vm[SIM_DONE]['last_request_notice']
    assert vm[SIM_AUTO]['status_chip'] == CH_SIMI
    # 동작 결과 — 13 · 레벨 5값 · 사전 · 넘김 = 전환 요청만 · 재시도 0 · id 5 전수.
    rs = envs[RESULTS]['rows']
    assert len(rs) == 13 and {r['level'] for r in rs} == LEVELS
    assert all(list(r) == RESULT_KEYS for r in rs)
    assert {r['id'] for r in rs} == S05_IDS
    assert all(r['reason_code'] is None or r['reason_code'] in RESULT_CODES for r in rs)
    assert all(r['retryable'] is False for r in rs)
    for r in rs:
        switch = r['id'] in ('RUNTIME_MODE_SWITCH_REQUEST', 'RUNTIME_OPERATING_MODE_SWITCH_REQUEST')
        assert (r['handoff_route'] is not None) == switch, r['action_run_id']
        assert r['handoff_route'] is None or r['handoff_route'] in R.values()
    assert {'ENGINE_ALREADY_RUNNING', 'ENGINE_ALREADY_STOPPED', 'SAF-405', 'CREDENTIAL_ENV_MISMATCH',
            'LIVE_OBSERVATION_NOT_ENOUGH_DAYS', 'LIVE_PROMOTION_NOT_OBSERVING'} <= {r['reason_code'] for r in rs}

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    assert n_version_only == BASE_FILES, n_version_only

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r6c_v119_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.19.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
