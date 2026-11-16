#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.22(엔진 예고 2/2 — E13 나머지 · 사다리 · E14i 재개 · E15i 남은 몫 · F8 · 01 §31) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_v122_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_v121_fixtures.py(계약 v1.21 · 그 스크립트는 v1.21 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-17_계약v1.22_설계서.md` §5 · 283 → 298 = 신설 15 · 개정 2 · 버전 줄만 281)
  (a) 전 봉투의 "contract_version": "1.21.0" → "1.22.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 15 — m5/ 8(사다리 2 · E13 결과 1 · simToAuto 계획 4 · 위저드 결과 1) · 🆕 x2/ 6(재개 게이트 4 · 리포트 2) · m6/ 1(J-1 모의 거부).
  (c) 🔧 개정 2 — F8 `resume_report_1`(RECOVERY_DRY 정합 · K63) · `m9/handover_states` SIM_TO_AUTO 행 7단계(K59).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*` · `check_*`.

🔴 안전 수치 0 — 사다리 % · 거래일 · 냉각 24시간 · 갭 사다리는 엔진 글자 안에서만 옮긴다(새로 정하지 않는다).
🔴 엔진 글자가 있는 칸 = 엔진 함수 출력 그대로(원천 = origin/main 4f85259 · 구현 때 엔진 함수를 한 번 돌려 바이트 대조 —
   core `safety/breaker_ladder.dart` `breakerLadderOf(config: p0sBreakerConfig(), satelliteActive: false)` ·
   `mode/sim_to_auto.dart` `judgeSimToAuto` + `simToAutoPlan` · `mode/handover_session.dart` `handoverSessionHeadline` ·
   `mode/sim_to_auto_commit.dart` `simToAutoCommitHeadline` · `mode/sim_to_auto_switch.dart` 오케스트레이터 문구 ·
   `resume/resume_text.dart` 문장 함수 — 아래 `resume_*` 는 그 함수의 파이썬 거울이고 `self_check_engine_text` 가 엔진 출력 표본과 맞댄다).
🔴 E13 결과 headline · 위저드 fate 결과 · 계절 버튼 · 칩 label · 행 요약 · 리포트 링크 글자 = 합성(엔진 문장 0 — 엔진 숙제 · K64 · K68).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_v122_fixtures.py
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
# 계약 1.21.0 · 픽스처 283 의 기준 커밋(origin/main · R7b 병합 기록 — 계약 패키지 = PR #189 이후 README 만).
BASE = '4f85259fe0b873f30b454de5a162fd05999b530b'

OLD_VER = '"contract_version": "1.21.0"'
NEW_VER = '"contract_version": "1.22.0"'
BASE_FILES = 283
WANT_FILES = 298

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
COUNTDOWN = re.compile(r'카운트다운|남은 시간|해제 버튼')
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}
# VM 안 금지 키(C-56 ①) — 저널 id 노출 · 카운트다운 원값 · 해제 칸 · 프리필.
BAD_KEYS = ('decision_id', 'journal_decision_id', 'countdown', 'remaining_seconds', 'release_action', 'deactivate',
            'prefill', 'example')
# 🔴 J-1 모의 거부 행 한 벌만 — 가격 칸 3 의 «…원» 글자(J-1 행 꼴 · K66 · C-56 ⑬).
MONEY_KEYS_J1 = ('price_text', 'commission_text', 'tax_text')
# 🔴 «평가액» 은 엔진 재개 문장(`resumeGapLabel` «평가액 스냅샷 없음»)의 낱말 — 리포트 공백 label 한 칸만 예외.
PNL_WORD_OK_PATHS = ('unrecoverable_gaps',)

# ── 사전(labels/*.dart 와 같은 글자 — C-56 ②③⑧ 이 다시 본다) ──
STOPPED = {'STOPPED_NOT_ACTIVE', 'STOPPED_WAIT_20D', 'DECISION_ALREADY_MADE', 'POSTMORTEM_MISSING',
           'FAMILY_AGREEMENT_MISSING', 'JOURNAL_REQUIRED', 'STOPPED_NOT_ELIGIBLE'}
POSTMORTEM = {'INCIDENT_NOT_FOUND', 'POSTMORTEM_BLANK', 'POSTMORTEM_ALREADY_RECORDED'}
INTERVENTION = {'INTERVENTION_CLOSED', 'INTERVENTION_COOLING', 'INTERVENTION_EXPIRED', 'INTERVENTION_JOURNAL_MISSING',
                'INTERVENTION_STAGE_OUT_OF_ORDER', 'INTERVENTION_SESSION_OPEN'}
RULE_CHANGE = {'RULE_CHANGE_APPROVAL_FIELDS_MISSING', 'RULE_CHANGE_BASE_STALE', 'RULE_CHANGE_CONFIG_UNKNOWN',
               'RULE_CHANGE_COOLING', 'RULE_CHANGE_DD_LOCKED', 'RULE_CHANGE_DECIDED', 'RULE_CHANGE_FIELDS_MISSING',
               'RULE_CHANGE_JOURNAL_MISSING', 'RULE_CHANGE_NOT_FOUND', 'RULE_CHANGE_OUT_OF_WINDOW',
               'RULE_CHANGE_THIRD_PARTY_MISSING'}
DISCRETION = {'COUNT_EXCEEDED', 'DELTA_EXCEEDED', 'JOURNAL_MISSING'}
SEASONAL = {'SEASONAL_DECISION_MISSING', 'SEASONAL_NOT_ENTRY', 'SEASONAL_NOT_PENDING', 'SEASONAL_PAST_DUE'}
PW_REJECT = {'PLANNED_WORK_UNCHANGED', 'PLANNED_WORK_TERMINAL', 'PLANNED_WORK_PAST_DUE', 'PLANNED_WORK_NOT_DUE',
             'PLANNED_WORK_ILLEGAL', 'PLANNED_WORK_UNKNOWN'}
RESUME_REASON = ['DUE_PASSED', 'ADVISORY_PENDING', 'SAFETY_STOP', 'OBSERVING', 'RECON_MISMATCH_REMAINS',
                 'UNKNOWN_ORDERS_REMAIN', 'RESIDUAL_ORDERS_REMAIN', 'HUMAN_DECISION', 'CONSERVATIVE_DEFER',
                 'REEVALUATED_EMPTY', 'REEVALUATED', 'HUMAN_SKIP', 'HUMAN_REDUCED', 'HUMAN_AS_IS',
                 'REEVALUATION_FAILED']
HALT = {'ADVISORY_PENDING', 'SAFETY_STOP', 'OBSERVING', 'RECON_MISMATCH_REMAINS', 'UNKNOWN_ORDERS_REMAIN',
        'RESIDUAL_ORDERS_REMAIN', 'REEVALUATION_FAILED'}
SIM_RESULT = {'SIM_TO_AUTO_NOT_SIM_AUTO', 'SIM_TO_AUTO_SAFETY_BLOCK', 'SIM_TO_AUTO_TRIAL_INCOMPLETE',
              'SIM_TO_AUTO_GOLDEN_VECTOR_FAILED', 'SIM_TO_AUTO_LIVE_KEYS_FAILED', 'SIM_TO_AUTO_ACCOUNT_UNMAPPED',
              'SIM_TO_AUTO_COOLING', 'SIM_TO_AUTO_SESSION_EXPIRED', 'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE',
              'SIM_TO_AUTO_COMMIT_WINDOW'}
SIM_COMMIT = {'SIM_TO_AUTO_ALREADY_COMMITTED', 'SIM_TO_AUTO_ACCOUNT_PROBE_MISSING', 'SIM_TO_AUTO_SNAPSHOT_STALE',
              'SIM_TO_AUTO_HOLDINGS_NOT_ZERO', 'SIM_TO_AUTO_BROKER_ACTIVITY_TODAY', 'SIM_TO_AUTO_CASH_UNKNOWN',
              'SIM_TO_AUTO_ZERO_CASH', 'SIM_TO_AUTO_COMMIT_ROLLED_BACK', 'SIM_TO_AUTO_LEASE_MISMATCH',
              'SIM_LEDGER_FATE_SIM_CLOSED', 'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED', 'SIM_TO_AUTO_COMMIT_UNKNOWN'}
SESSION = {'HANDOVER_SESSION_OPEN', 'HANDOVER_SESSION_ROLLED_BACK'}
STEP_IDS = ['SIM_TO_AUTO_S%d' % n for n in range(1, 8)]
BIOMETRIC = 'BIOMETRIC_UNAVAILABLE'
TTU = 'TRUSTED_TIME_UNKNOWN'
JIT = 'JOURNAL_ID_TAKEN'
SESSION_INVALID = 'HANDOVER_SESSION_INVALID'
LEASE_INVALID = 'LEASE_INVALID'
SIM_BROKER = {'SIM_INVALID_ORDER', 'SIM_ORDER_NOT_FOUND', 'SIM_CANCEL_TOO_LATE'}
REPORT_ROUTE = 'aaq://x2/resume-report'   # AppRoutes.x2ResumeReport

E13_ALLOWED = {
    'STOPPED_DECISION': STOPPED | {JIT, BIOMETRIC},
    'INCIDENT_POSTMORTEM': POSTMORTEM | {BIOMETRIC},
    'RECON_CLEAR': {BIOMETRIC},
    'INTERVENTION_STEP': INTERVENTION | {TTU, BIOMETRIC},
    'DISCRETION_ADJUST': DISCRETION | {TTU, BIOMETRIC},
    'RULE_CHANGE_CANCEL': RULE_CHANGE | {TTU, BIOMETRIC},
    'RULE_CHANGE_APPROVE': RULE_CHANGE | {TTU, BIOMETRIC},
    'SEASONAL_WINDOW_CHOICE': SEASONAL | PW_REJECT | HALT | {BIOMETRIC},
}
HS_ALLOWED = {
    'HANDOVER_SIM_LEDGER_FATE': {'SIM_LEDGER_FATE_SIM_CLOSED', 'SIM_TO_AUTO_NOT_SIM_AUTO'},
    'HANDOVER_SESSION_START': SIM_RESULT | set(STEP_IDS) | SESSION | {BIOMETRIC},
    'HANDOVER_SESSION_CANCEL': {SESSION_INVALID},
    'HANDOVER_COMMIT': SIM_COMMIT | SIM_RESULT | set(STEP_IDS) | {SESSION_INVALID, LEASE_INVALID},
}

# ── 이름 ─────────────────────────────────────────────────────────────────
LAD_N = 'm5/breaker_ladder_normal.json'
LAD_S = 'm5/breaker_ladder_stopped.json'
E13 = 'm5/safety_action_results_e13.json'
H_READY = 'm5/handover_sim_to_auto_ready.json'
H_S3 = 'm5/handover_sim_to_auto_s3_blocked.json'
H_COOL = 'm5/handover_sim_to_auto_cooling.json'
H_FATE = 'm5/handover_sim_to_auto_fate_pending.json'
HS = 'm5/handover_sim_to_auto_action_results.json'
G_SP = 'x2/resume_gate_seasonal_pending.json'
G_CD = 'x2/resume_gate_conservative_defer.json'
G_RF = 'x2/resume_gate_reevaluation_failed.json'
G_LK = 'x2/resume_gate_locked.json'
R_FULL = 'x2/resume_report_recovery_full.json'
R_NORM = 'x2/resume_report_normal.json'
J1 = 'm6/journal_sim_broker_reject.json'

LADDERS = [LAD_N, LAD_S]
PLANS = [H_READY, H_S3, H_COOL, H_FATE]
GATES = [G_SP, G_CD, G_RF, G_LK]
REPORTS = [R_FULL, R_NORM]
NEW_FILES = LADDERS + [E13] + PLANS + [HS] + GATES + REPORTS + [J1]
F8 = 'resume_report_1.json'
HSTATES = 'm9/handover_states.json'

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.22.0',
    'generated_at': '2026-11-17T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261117,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(observed, trade_date, label, stale=93600):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': stale, 'label': label}


# §5-1 조각.
AS_L = as_of('2026-11-18T06:00:00Z', '2026-11-18', '안전 기준 2026-11-18 15:00')
AS_E = as_of('2026-11-18T07:00:00Z', '2026-11-18', '안전 기준 2026-11-18 16:00')
AS_H = as_of('2026-12-10T03:00:00Z', '2026-12-10', '전환 판정 2026-12-10 12:00', 300)   # 엔진 kHandoverPlanStaleAfter 5분
AS_HR = as_of('2026-12-10T03:05:00Z', '2026-12-10', '전환 기준 2026-12-10 12:05')
AS_X = as_of('2026-12-22T00:45:00Z', '2026-12-22', '재개 기준 2026-12-22 09:45')
LOCKED = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'   # v1.20·v1.21 표본과 같은 글자

# ── 엔진 글자 — 사다리(core `breakerLadderOf(config: p0sBreakerConfig(), satelliteActive: false)` 출력 · 4f85259) ──
LADDER_LEVELS = ['NORMAL', 'ALERT', 'REDUCED', 'HALTED', 'STOPPED']
LADDER_TEXT = [
    ('정상', 'dd > -15%', '—', '정상 운용'),
    ('경보', 'dd ≤ -15%', 'dd > -13% · 20거래일 유지', '알림 · 새틀라이트 신규 진입 · 증액 중단(지금은 대상 없음)'),
    ('축소 운용', 'dd ≤ -20%', 'dd ≥ -12% · 방향 점수 50 이상 · 20거래일 유지', '새틀라이트 × 0.5(지금은 대상 없음)'),
    ('중지', 'dd ≤ -25%', 'dd ≥ -15% · BULL 3일 연속 · 20거래일 유지', '새틀라이트 0%(지금은 대상 없음) · 슬리브 A 신규 매수 정지'),
    ('정지', 'dd ≤ -35%', '자동 해제 없음 — 20거래일 · SEV1 postmortem · 가족 합의 · 결정 A/B/C',
     '신규 주문 전면 중단 · 보유 유지 · 자동 청산 없음'),
]
LADDER_KEYS = ['level', 'label', 'trigger_text', 'release_text', 'action_text', 'current']

# ── 엔진 글자 — simToAuto 7단계(core `SimToAutoStep` · `judgeSimToAuto` 상태 글자 · `simToAutoPlan`) ──
PATH_LABEL = '모의투자 → 실전 자동 매매(관찰부터)'
STEP_TEXT = [
    ('모의 체험 확인', '체험 5항목을 채웠는지 엔진이 확인합니다'),
    ('계산 자가검사', '실전과 같은 계산인지 골든 벡터로 다시 확인합니다'),
    ('실전 키 확인', '실전 키를 등록하고 조회만으로 확인합니다 — 주문은 내지 않습니다'),
    ('계좌 연결', '전략 넷이 모두 실전 계좌에 연결됐는지 확인합니다'),
    ('모의 기록 처리', '모의 기록을 보관할지 지울지 고릅니다 — 실전 원장에는 남지 않습니다'),
    ('생체 확인', '생체 확인 1회로 전환을 시작합니다'),
    ('24시간 냉각', '생체 확인 뒤 24시간을 기다립니다 — 건너뛸 수 없습니다'),
]
S1_PASS = '체험 5항목 완료'
S2_PASS = '골든 벡터 통과'
S3_PASS = '실전 키 조회 확인'
S3_FAIL = '실전 키 조회가 실패했습니다'
S4_PASS = '전략 4개 모두 계좌 연결'   # kP0sSeedStrategies.length = 4
S5_KEEP = '모의 기록을 앱 밖 보관본으로 남깁니다'
S5_NONE = '고르기 전'
S6_NONE = '생체 확인 전'
S7_NONE = '생체 확인 뒤 시작합니다'
STEP_KEYS = ['step_id', 'order', 'title', 'why_line', 'state', 'state_label', 'blocked_reason_code']
PLAN_KEYS = ['path', 'path_label', 'steps', 'adoption_preview', 'as_of', 'handback_branch', 'branch_reason_label']

# ── 엔진 글자 — 위저드 결과(`handoverSessionHeadline` · `kHandoverCancelledHeadline` · `simToAutoCommitHeadline` · 오케스트레이터) ──
HS_TEXT = {
    'start_ok': '생체 확인 완료 — 24시간 냉각 뒤 2026-12-10 11:00부터 2026-12-11 11:00 전까지 확정할 수 있습니다.',
    BIOMETRIC: '생체 확인이 없어 전환을 시작하지 않았습니다.',
    'step_default': '앞 단계(1~5)를 모두 마친 뒤 생체 확인을 할 수 있습니다.',
    'HANDOVER_SESSION_OPEN': '이미 열린 전환 세션이 있습니다 — 그 세션을 마치거나 취소한 뒤 다시 시작해 주세요.',
    'HANDOVER_SESSION_ROLLED_BACK': '저장에 실패해 아무것도 바꾸지 않았습니다.',
    'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE': '시각을 확인할 수 없어 전환을 시작하지 않았습니다.',
    'SIM_TO_AUTO_NOT_SIM_AUTO': '모의투자 자동 매매 중일 때만 실전으로 옮길 수 있습니다.',
    'cancelled': '전환을 취소했습니다 — 지금 모드 그대로입니다.',
    SESSION_INVALID: '열려 있는 전환 세션이 아닙니다.',
    'commit_default': '아직 확정할 수 없습니다 — 전환 단계를 확인해 주세요.',
    'SIM_TO_AUTO_HOLDINGS_NOT_ZERO': '실전 계좌에 보유 종목이 있어 확정하지 않았습니다 — 기존 보유를 넘겨받는 경로로 진행해 주세요.',
    'SIM_TO_AUTO_SNAPSHOT_STALE': '계좌 조회가 오래됐습니다 — 다시 조회한 뒤 확정해 주세요.',
    'SIM_TO_AUTO_COMMIT_ROLLED_BACK': '저장에 실패해 아무것도 바꾸지 않았습니다 — 전환 세션을 닫았으니 처음부터 다시 진행해 주세요.',
    LEASE_INVALID: '이 기기의 발주권(리스)을 확인할 수 없어 확정하지 않았습니다.',
    'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED':
        '바깥 감시를 준비하지 못해 전환하지 않았습니다 — 바뀐 것은 없습니다. 잠시 뒤 다시 확정해 주세요.',
    'SIM_TO_AUTO_COMMIT_UNKNOWN': '확정 결과를 확인하지 못했습니다 — 앱을 다시 열어 상태를 확인해 주세요.',
}


# ── 엔진 문장 함수의 파이썬 거울(core `resume/resume_text.dart` · 4f85259) — 아래 self_check_engine_text 가 엔진 출력 표본과 맞댄다 ──
MODE_NAME = {'NORMAL': '평상', 'CONSERVATIVE': '보수', 'RECOVERY_DRY': '복구 관찰', 'RECOVERY_FULL': '안전 정지'}
VERDICT_LABEL = {'EXECUTED_AS_REEVALUATED': '재판정 값으로 집행 예정', 'EXPIRED': '만료', 'SUPERSEDED': '대체됨',
                 'BLOCKED': '차단', 'UNRECOVERABLE': '복구 불가'}


def month_day(d):
    _y, m, dd = d.split('-')
    return '%d월 %d일' % (int(m), int(dd))


def resume_mode_label(gap, mode):
    return '%d거래일 미실행 — %s' % (gap, MODE_NAME[mode])


def resume_planned_line(day):
    return '%s 계획됨' % month_day(day)


def resume_reason_line(code, due_by, today):
    return {
        'DUE_PASSED': '유효기한(%s)이 지났습니다' % month_day(due_by),
        'ADVISORY_PENDING': '안내 모드 재개 조건 결정을 기다립니다',
        'SAFETY_STOP': '안전 정지 — 기기와 원장 검증이 먼저입니다',
        'OBSERVING': '관찰 회차라 다음 회차에 재판정합니다',
        'RECON_MISMATCH_REMAINS': '대사 불일치가 남아 있어 미뤄 둡니다',
        'UNKNOWN_ORDERS_REMAIN': '결과를 모르는 주문이 남아 있어 미뤄 둡니다',
        'RESIDUAL_ORDERS_REMAIN': '처리 중인 주문이 남아 있어 미뤄 둡니다',
        'HUMAN_DECISION': '계절 진입은 직접 결정해야 합니다',
        'CONSERVATIVE_DEFER': '보수 모드라 다음 정기 회차로 넘겼습니다',
        'REEVALUATED_EMPTY': '%s 재판정 결과 할 일이 없습니다' % month_day(today),
        'REEVALUATED': '%s 재판정 값으로 다음 주문 회차에 넘겼습니다' % month_day(today),
        'HUMAN_SKIP': '직접 건너뛰었습니다',
        'HUMAN_REDUCED': '직접 축소 진입을 골랐습니다',
        'HUMAN_AS_IS': '직접 그대로 진입을 골랐습니다',
        'REEVALUATION_FAILED': '재판정에 필요한 자료가 없어 미뤄 둡니다',
    }[code]


TAIL = {
    'OBSERVING': '관찰 회차라 발주하지 않습니다.',
    'SAFETY_STOP': '안전 정지 — 매매하지 않습니다.',
    'ADVISORY_PENDING': '안내 모드 재개 조건 결정을 기다립니다.',
    'RECON_MISMATCH_REMAINS': '대사 불일치가 풀릴 때까지 매매를 멈춰 둡니다.',
    'UNKNOWN_ORDERS_REMAIN': '결과를 모르는 주문이 풀릴 때까지 매매를 멈춰 둡니다.',
    'RESIDUAL_ORDERS_REMAIN': '처리 중인 주문이 풀릴 때까지 매매를 멈춰 둡니다.',
    'REEVALUATION_FAILED': '재판정을 마치지 못해 매매를 멈춰 둡니다.',
}


def resume_counts(verdicts, gaps):
    n = {v: 0 for v in VERDICT_LABEL}
    for v in verdicts:
        n[v] += 1
    return {'executed': n['EXECUTED_AS_REEVALUATED'], 'expired': n['EXPIRED'], 'superseded': n['SUPERSEDED'],
            'blocked': n['BLOCKED'], 'unrecoverable': n['UNRECOVERABLE'] + gaps}


def resume_headline(gap, counts, halt):
    if halt is None:
        tail = '주문은 다음 주문 회차가 냅니다.' if counts['executed'] > 0 else '새로 낼 주문은 없습니다.'
    else:
        tail = TAIL[halt]
    return ('%d거래일 미실행: 재판정 %d / 만료 %d / 대체 %d / 차단 %d / 복구 불가 %d. %s'
            % (gap, counts['executed'], counts['expired'], counts['superseded'], counts['blocked'],
               counts['unrecoverable'], tail))


def resume_gap_label(dataset, frm, to):
    span = month_day(frm) if frm == to else '%s~%s' % (month_day(frm), month_day(to))
    what = '평가액 스냅샷' if dataset == 'equity_snapshot' else dataset
    return '%s %s 없음 — 복구 불가' % (span, what)


def self_check_engine_text():
    """파이썬 거울 == 엔진 출력 표본(구현 때 core 함수를 돌린 바이트 · 4f85259)."""
    c = resume_counts(['EXPIRED', 'BLOCKED', 'BLOCKED', 'BLOCKED', 'BLOCKED'], 1)
    assert resume_headline(7, c, 'OBSERVING') == \
        '7거래일 미실행: 재판정 0 / 만료 1 / 대체 0 / 차단 4 / 복구 불가 1. 관찰 회차라 발주하지 않습니다.'
    c = resume_counts(['BLOCKED', 'BLOCKED', 'EXPIRED'], 1)
    assert resume_headline(11, c, 'SAFETY_STOP') == \
        '11거래일 미실행: 재판정 0 / 만료 1 / 대체 0 / 차단 2 / 복구 불가 1. 안전 정지 — 매매하지 않습니다.'
    c = resume_counts(['EXECUTED_AS_REEVALUATED', 'SUPERSEDED', 'EXPIRED'], 0)
    assert resume_headline(2, c, None) == \
        '2거래일 미실행: 재판정 1 / 만료 1 / 대체 1 / 차단 0 / 복구 불가 0. 주문은 다음 주문 회차가 냅니다.'
    c = resume_counts(['BLOCKED'], 0)
    assert resume_headline(2, c, 'REEVALUATION_FAILED') == \
        '2거래일 미실행: 재판정 0 / 만료 0 / 대체 0 / 차단 1 / 복구 불가 0. 재판정을 마치지 못해 매매를 멈춰 둡니다.'
    assert resume_mode_label(7, 'RECOVERY_DRY') == '7거래일 미실행 — 복구 관찰'
    assert resume_mode_label(4, 'CONSERVATIVE') == '4거래일 미실행 — 보수'
    assert resume_planned_line('2026-12-08') == '12월 8일 계획됨'
    assert resume_reason_line('DUE_PASSED', '2026-12-19', '2026-12-22') == '유효기한(12월 19일)이 지났습니다'
    assert resume_reason_line('REEVALUATED', '2026-12-19', '2026-12-22') == '12월 22일 재판정 값으로 다음 주문 회차에 넘겼습니다'
    assert resume_gap_label('equity_snapshot', '2026-08-25', '2026-08-26') == '8월 25일~8월 26일 평가액 스냅샷 없음 — 복구 불가'


# ────────────────────────────────────────────────────────────────────────
# 신설 — 사다리
# ────────────────────────────────────────────────────────────────────────
def ladder(current):
    rows = []
    for lv, (label, trig, rel, act) in zip(LADDER_LEVELS, LADDER_TEXT):
        rows.append(dict(zip(LADDER_KEYS, [lv, label, trig, rel, act, lv == current])))
    return {'rows': rows, 'as_of': copy.deepcopy(AS_L)}


# ────────────────────────────────────────────────────────────────────────
# 신설 — simToAuto 계획(판정 시각 2026-12-10 12:00 KST · 엔진 `judgeSimToAuto` 4갈래 출력)
# ────────────────────────────────────────────────────────────────────────
def step(n, state, label, code=None):
    title, why = STEP_TEXT[n - 1]
    return dict(zip(STEP_KEYS, [STEP_IDS[n - 1], n, title, why, state, label, code]))


def plan(steps):
    return dict(zip(PLAN_KEYS, [
        'SIM_TO_AUTO', PATH_LABEL, steps, [], copy.deepcopy(AS_H), None, None]))


def steps_ready():
    return [step(1, 'PASS', S1_PASS), step(2, 'PASS', S2_PASS), step(3, 'PASS', S3_PASS), step(4, 'PASS', S4_PASS),
            step(5, 'PASS', S5_KEEP), step(6, 'PASS', '생체 확인 2026-12-09 11:00'),
            step(7, 'PASS', '냉각 끝 — 2026-12-11 11:00 전까지 확정하세요')]


def build_plans():
    return {
        H_READY: plan(steps_ready()),
        H_S3: plan([step(1, 'PASS', S1_PASS), step(2, 'PASS', S2_PASS),
                    step(3, 'BLOCK', S3_FAIL, 'SIM_TO_AUTO_LIVE_KEYS_FAILED'), step(4, 'PASS', S4_PASS),
                    step(5, 'UNKNOWN', S5_NONE), step(6, 'UNKNOWN', S6_NONE), step(7, 'UNKNOWN', S7_NONE)]),
        H_COOL: plan([step(1, 'PASS', S1_PASS), step(2, 'PASS', S2_PASS), step(3, 'PASS', S3_PASS),
                      step(4, 'PASS', S4_PASS), step(5, 'PASS', S5_KEEP),
                      step(6, 'PASS', '생체 확인 2026-12-09 14:00'),
                      step(7, 'BLOCK', '냉각 중 — 2026-12-10 14:00 이후 확정할 수 있습니다', 'SIM_TO_AUTO_COOLING')]),
        H_FATE: plan([step(1, 'PASS', S1_PASS), step(2, 'PASS', S2_PASS), step(3, 'PASS', S3_PASS),
                      step(4, 'PASS', S4_PASS), step(5, 'UNKNOWN', S5_NONE), step(6, 'UNKNOWN', S6_NONE),
                      step(7, 'UNKNOWN', S7_NONE)]),
    }


# ────────────────────────────────────────────────────────────────────────
# 신설 — 결과 표본
# ────────────────────────────────────────────────────────────────────────
RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']


def result(prefix, n, id_, level, headline, reason=None):
    return dict(zip(RESULT_KEYS, ['%s_%02d' % (prefix, n), id_, level, headline, reason, None, False]))


def build_e13():
    sd, pm, rc, iv, dj = 'STOPPED_DECISION', 'INCIDENT_POSTMORTEM', 'RECON_CLEAR', 'INTERVENTION_STEP', 'DISCRETION_ADJUST'
    cn, ap, sw = 'RULE_CHANGE_CANCEL', 'RULE_CHANGE_APPROVE', 'SEASONAL_WINDOW_CHOICE'
    rows = [
        (sd, 'OK', '(합성) 결정을 기록했습니다 — 정해진 다음 절차를 엔진이 이어 갑니다.', None),
        (sd, 'WATCH', '(합성) 아직 결정할 수 있는 날이 아닙니다 — 정해진 기간을 채운 뒤 다시 고르십시오.', 'STOPPED_WAIT_20D'),
        (sd, 'ACT', '(합성) 사건 사후 검토를 먼저 쓰십시오.', 'POSTMORTEM_MISSING'),
        (sd, 'ACT', '(합성) 가족 합의 확인이 없어 받지 않았습니다.', 'FAMILY_AGREEMENT_MISSING'),
        (sd, 'ACT', '(합성) 결정 전 기록 세 칸을 모두 채우십시오.', 'JOURNAL_REQUIRED'),
        (sd, 'BLOCKED', '(합성) 재가동 자격이 아직 없어 이 결정을 받지 않았습니다.', 'STOPPED_NOT_ELIGIBLE'),
        (sd, 'INFO', '(합성) 이번 정지 구간에는 이미 결정이 있습니다.', 'DECISION_ALREADY_MADE'),
        (sd, 'BLOCKED', '(합성) 저널 번호가 이미 쓰였습니다 — 다시 시도하십시오.', JIT),
        (pm, 'OK', '(합성) 사후 검토를 저장했습니다.', None),
        (pm, 'ACT', '(합성) 사후 검토 글이 비었습니다.', 'POSTMORTEM_BLANK'),
        (pm, 'INFO', '(합성) 이 사건의 사후 검토는 이미 있습니다.', 'POSTMORTEM_ALREADY_RECORDED'),
        (rc, 'OK', '(합성) 대사 불일치 표시를 풀었습니다.', None),
        (rc, 'BLOCKED', '(합성) 생체 확인을 할 수 없어 진행하지 않았습니다.', BIOMETRIC),
        (iv, 'OK', '(합성) 이 단계를 마쳤습니다 — 다음 단계로 넘어갑니다.', None),
        (iv, 'WATCH', '(합성) 아직 기다리는 단계입니다 — 정해진 시각 뒤에 다시 여십시오.', 'INTERVENTION_COOLING'),
        (iv, 'ACT', '(합성) 이 단계 전에 저널을 먼저 쓰십시오.', 'INTERVENTION_JOURNAL_MISSING'),
        (iv, 'BLOCKED', '(합성) 실행할 수 있는 때가 지났습니다 — 처음부터 다시 여십시오.', 'INTERVENTION_EXPIRED'),
        (dj, 'OK', '(합성) 재량 조정을 기록했습니다.', None),
        (dj, 'BLOCKED', '(합성) 올해 쓸 수 있는 재량 횟수를 다 썼습니다.', 'COUNT_EXCEEDED'),
        (dj, 'ACT', '(합성) 조정폭이 허용 범위를 벗어났습니다.', 'DELTA_EXCEEDED'),
        (cn, 'OK', '(합성) 규칙 변경 요청을 거두었습니다.', None),
        (cn, 'INFO', '(합성) 이 요청은 이미 결정됐습니다.', 'RULE_CHANGE_DECIDED'),
        (ap, 'OK', '(합성) 규칙 변경을 승인했습니다 — 정해진 때부터 적용됩니다.', None),
        (ap, 'WATCH', '(합성) 아직 기다리는 기간입니다 — 기간이 끝난 뒤 승인할 수 있습니다.', 'RULE_CHANGE_COOLING'),
        (ap, 'BLOCKED', '(합성) 낙폭이 커서 규칙 변경을 잠가 두었습니다.', 'RULE_CHANGE_DD_LOCKED'),
        (ap, 'ACT', '(합성) 제3자에게 알렸는지 확인하십시오.', 'RULE_CHANGE_THIRD_PARTY_MISSING'),
        (ap, 'BLOCKED', '(합성) 서버 시각을 확인하지 못해 승인하지 않았습니다.', TTU),
        (sw, 'OK', '(합성) 고른 대로 기록했습니다 — 다음 주문 회차가 이어 갑니다.', None),
        (sw, 'ACT', '(합성) 고를 수 있는 기한이 지났습니다.', 'SEASONAL_PAST_DUE'),
        (sw, 'BLOCKED', '(합성) 대사 불일치가 남아 있어 진입을 고르지 않았습니다.', 'RECON_MISMATCH_REMAINS'),
        (sw, 'INFO', '(합성) 그 작업을 찾지 못했습니다.', 'PLANNED_WORK_UNKNOWN'),
    ]
    return [result('ar_e13', i + 1, *r) for i, r in enumerate(rows)]


def build_hs():
    fate, start, cancel, commit = ('HANDOVER_SIM_LEDGER_FATE', 'HANDOVER_SESSION_START', 'HANDOVER_SESSION_CANCEL',
                                   'HANDOVER_COMMIT')
    t = HS_TEXT
    rows = [
        (fate, 'OK', '(합성) 모의 기록을 앱 밖 보관본으로 남기기로 했습니다.', None),
        (fate, 'INFO', '(합성) 모의 파일이 이미 닫혀 고른 것을 적지 않았습니다.', 'SIM_LEDGER_FATE_SIM_CLOSED'),
        (fate, 'BLOCKED', t['SIM_TO_AUTO_NOT_SIM_AUTO'], 'SIM_TO_AUTO_NOT_SIM_AUTO'),
        (start, 'OK', t['start_ok'], None),
        (start, 'BLOCKED', t[BIOMETRIC], BIOMETRIC),
        (start, 'ACT', t['step_default'], 'SIM_TO_AUTO_S5'),
        (start, 'ACT', t['step_default'], 'SIM_TO_AUTO_LIVE_KEYS_FAILED'),
        (start, 'INFO', t['HANDOVER_SESSION_OPEN'], 'HANDOVER_SESSION_OPEN'),
        (start, 'BLOCKED', t['HANDOVER_SESSION_ROLLED_BACK'], 'HANDOVER_SESSION_ROLLED_BACK'),
        (start, 'WATCH', t['SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE'], 'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE'),
        (cancel, 'OK', t['cancelled'], None),
        (cancel, 'INFO', t[SESSION_INVALID], SESSION_INVALID),
        (commit, 'WATCH', t['commit_default'], 'SIM_TO_AUTO_COOLING'),
        (commit, 'WATCH', t['commit_default'], 'SIM_TO_AUTO_COMMIT_WINDOW'),
        (commit, 'BLOCKED', t['SIM_TO_AUTO_HOLDINGS_NOT_ZERO'], 'SIM_TO_AUTO_HOLDINGS_NOT_ZERO'),
        (commit, 'ACT', t['SIM_TO_AUTO_SNAPSHOT_STALE'], 'SIM_TO_AUTO_SNAPSHOT_STALE'),
        (commit, 'BLOCKED', t['SIM_TO_AUTO_COMMIT_ROLLED_BACK'], 'SIM_TO_AUTO_COMMIT_ROLLED_BACK'),
        (commit, 'BLOCKED', t[LEASE_INVALID], LEASE_INVALID),
        (commit, 'BLOCKED', t['SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED'], 'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED'),
        (commit, 'WATCH', t['SIM_TO_AUTO_COMMIT_UNKNOWN'], 'SIM_TO_AUTO_COMMIT_UNKNOWN'),
    ]
    return [result('ar_hs', i + 1, *r) for i, r in enumerate(rows)]


# ────────────────────────────────────────────────────────────────────────
# 신설 — X2 재개 게이트 · 리포트(오늘 2026-12-22 · 엔진 문장 함수 거울)
# ────────────────────────────────────────────────────────────────────────
TODAY = '2026-12-22'
DUE = '2026-12-19'
GATE_KEYS = ['headline', 'mode_label', 'level', 'rows', 'report_link', 'locked_label', 'as_of']
GROW_KEYS = ['work_id', 'one_line', 'reason_code', 'reason_label', 'level', 'actions']
REPORT_LINK = {'label': '(합성) 재개 리포트 보기', 'deep_link': REPORT_ROUTE}
SEASON_LABELS = [('SKIP', '건너뛰기'), ('REDUCED', '축소 진입'), ('AS_IS', '그대로 진입')]   # 합성 · K64


def season_calls(work_id):
    return [{'id': 'SEASONAL_WINDOW_CHOICE', 'args': {'work_id': work_id, 'choice': c}, 'label': lbl}
            for c, lbl in SEASON_LABELS]


def grow(work_id, one_line, code, level, calls=False):
    return dict(zip(GROW_KEYS, [work_id, one_line, code, resume_reason_line(code, DUE, TODAY), level,
                                season_calls(work_id) if calls else []]))


def gate(gap, mode, level, rows, verdicts, halt):
    head = resume_headline(gap, resume_counts(verdicts, 0), halt)
    return dict(zip(GATE_KEYS, [head, resume_mode_label(gap, mode), level, rows, copy.deepcopy(REPORT_LINK), None,
                                copy.deepcopy(AS_X)]))


def build_gates():
    sp = gate(2, 'NORMAL', 'WATCH',
              [grow('pw_x2_01', '(합성) 슬리브 A 계절 진입(12월 회차)', 'HUMAN_DECISION', 'ACT', True),
               grow('pw_x2_02', '(합성) 슬리브 B 밴드 이탈 매수', 'DUE_PASSED', 'INFO')],
              ['BLOCKED', 'EXPIRED'], None)
    cd = gate(4, 'CONSERVATIVE', 'WATCH',
              [grow('pw_x2_03', '(합성) 슬리브 C 재매수', 'CONSERVATIVE_DEFER', 'INFO'),
               grow('pw_x2_04', '(합성) 슬리브 A 계절 진입(12월 회차)', 'HUMAN_DECISION', 'ACT', True)],
              ['SUPERSEDED', 'BLOCKED'], None)
    rf = gate(2, 'NORMAL', 'BLOCKED',
              [grow('pw_x2_05', '(합성) 슬리브 B 정기 리밸런싱', 'REEVALUATION_FAILED', 'BLOCKED')],
              ['BLOCKED'], 'REEVALUATION_FAILED')
    lk = copy.deepcopy(sp)
    lk['locked_label'] = LOCKED
    for r in lk['rows']:
        r['actions'] = []
    return {G_SP: sp, G_CD: cd, G_RF: rf, G_LK: lk}


REPORT_KEYS = ['resume_run_id', 'started_at', 'finished_at', 'gap_trading_days', 'mode', 'mode_label', 'phase',
               'counts', 'items', 'unrecoverable_gaps', 'headline']
ITEM_KEYS = ['work_id', 'one_line', 'planned_line', 'reevaluated_line', 'verdict_code', 'verdict_label']
GAP_KEYS = ['gap_id', 'dataset', 'from', 'to', 'recoverable', 'reason_code', 'label']


def item(work_id, one_line, planned_on, verdict, code, due_by, today):
    return dict(zip(ITEM_KEYS, [work_id, one_line, resume_planned_line(planned_on),
                                resume_reason_line(code, due_by, today), verdict, VERDICT_LABEL[verdict]]))


def gap_row(gap_id, frm, to):
    return dict(zip(GAP_KEYS, [gap_id, 'equity_snapshot', frm, to, False, 'RESUME_GAP',
                               resume_gap_label('equity_snapshot', frm, to)]))


def report(run_id, gap, mode, items, gaps, halt):
    counts = resume_counts([i['verdict_code'] for i in items], len(gaps))
    return dict(zip(REPORT_KEYS, [run_id, '2026-12-22T00:12:00Z', '2026-12-22T00:41:00Z', gap, mode,
                                  resume_mode_label(gap, mode), 'R8', counts, items, gaps,
                                  resume_headline(gap, counts, halt)]))


def build_reports():
    full = report('rr_x2_full_01', 11, 'RECOVERY_FULL', [
        item('pw_x2_11', '(합성) 슬리브 B 밴드 이탈 매수', '2026-12-08', 'BLOCKED', 'SAFETY_STOP', '2026-12-23', TODAY),
        item('pw_x2_12', '(합성) 슬리브 C 재매수', '2026-12-10', 'BLOCKED', 'SAFETY_STOP', '2026-12-24', TODAY),
        item('pw_x2_13', '(합성) 슬리브 A 트랜치 다음 단계', '2026-12-11', 'EXPIRED', 'DUE_PASSED', DUE, TODAY),
    ], [gap_row('gap_x2_01', '2026-12-07', '2026-12-21')], 'SAFETY_STOP')
    normal = report('rr_x2_normal_01', 2, 'NORMAL', [
        item('pw_x2_21', '(합성) 슬리브 B 정기 리밸런싱', '2026-12-17', 'EXECUTED_AS_REEVALUATED', 'REEVALUATED',
             '2026-12-24', TODAY),
        item('pw_x2_22', '(합성) 슬리브 C 밴드 안 점검', '2026-12-17', 'SUPERSEDED', 'REEVALUATED_EMPTY', '2026-12-24',
             TODAY),
        item('pw_x2_23', '(합성) 슬리브 A 트랜치 다음 단계', '2026-12-12', 'EXPIRED', 'DUE_PASSED', DUE, TODAY),
    ], [], None)
    return {R_FULL: full, R_NORM: normal}


# 🔧 F8 — resume_report_1 행(RECOVERY_DRY · gap 7 · 오늘 2026-08-31 · 엔진 DRY 판정 꼴 · K63).
F8_TODAY = '2026-08-31'


def build_f8(base_row):
    r = copy.deepcopy(base_row)
    old = {i['work_id']: i for i in r['items']}
    planned = {'pw_0001': '2026-08-21', 'pw_0002': '2026-08-24', 'pw_0003': '2026-08-25', 'pw_0004': '2026-08-27',
               'pw_0005': '2026-08-26'}
    items = []
    for wid in ['pw_0001', 'pw_0002', 'pw_0003', 'pw_0004', 'pw_0005']:
        if wid == 'pw_0002':   # 기한(08-28) 지남 = EXPIRED · DUE_PASSED
            items.append(item(wid, old[wid]['one_line'], planned[wid], 'EXPIRED', 'DUE_PASSED', '2026-08-28', F8_TODAY))
        else:                  # 그 밖 = 관찰 회차(멈춤 사유 OBSERVING) · BLOCKED
            items.append(item(wid, old[wid]['one_line'], planned[wid], 'BLOCKED', 'OBSERVING', '2026-09-04', F8_TODAY))
    gaps = [gap_row('gap_0001', '2026-08-20', '2026-08-28')]   # 갭 7세션(08-20~08-28 · 8-17 대체공휴일) = _recordUnrecoverable 꼴
    counts = resume_counts([i['verdict_code'] for i in items], len(gaps))
    r['gap_trading_days'] = 7
    r['mode'] = 'RECOVERY_DRY'
    r['mode_label'] = resume_mode_label(7, 'RECOVERY_DRY')
    r['counts'] = counts
    r['items'] = items
    r['unrecoverable_gaps'] = gaps
    r['headline'] = resume_headline(7, counts, 'OBSERVING')
    assert list(r) == REPORT_KEYS, list(r)
    return r


# 🔧 m9/handover_states SIM_TO_AUTO 행 — steps 3 → 7(ready 와 같은 7) · path_label 엔진 · adoption_preview [] (K59).
def build_hstates_row(base_row):
    r = copy.deepcopy(base_row)
    assert r['path'] == 'SIM_TO_AUTO'
    r['path_label'] = PATH_LABEL
    # 파일 꼴(옛 행)대로 null 인 blocked_reason_code 는 적지 않는다.
    r['steps'] = [{k: v for k, v in s.items() if not (k == 'blocked_reason_code' and v is None)} for s in steps_ready()]
    r['adoption_preview'] = []
    return r


# 신설 — J-1 모의 거부 행(journal_30 je_0009 꼴 · mode SIM_INTERNAL · 가상 체결 경로 SIMULATED · 제출 거부 = 주문번호 0).
def build_j1():
    return {
        'entry_id': 'je_sim_0001', 'mode': 'SIM_INTERNAL', 'trade_date': '2026-12-10', 'symbol': '069500',
        'symbol_label': '069500 KODEX 200', 'sleeve': 'A', 'side': 'BUY', 'side_label': '매수', 'quantity': 100,
        'price': '39220', 'commission': '0', 'tax': '0', 'quantity_text': '100주', 'price_text': '39,220원',
        'commission_text': '0원', 'tax_text': '0원', 'status': 'REJECTED', 'status_label': '거부',
        'status_tone': 'BLOCKED', 'visibility': 'AWAITING_CONFIRM', 'visibility_label': '확인 대기',
        'reasons': [{'code': 'SIM_INVALID_ORDER', 'label': '(합성) 모의 주문 수량·꼴이 맞지 않아 접수하지 않았습니다',
                     'tone': 'BLOCKED'}],
        'decision': {'decision_id': 'd_sim_a_0001', 'intent_id': 'i_s0001', 'config_hash': 'cfg_fake_0000000000000000'},
        'deviation': {'is_deviation': False, 'label': '규칙대로'},
        'account_alias': '(합성) 모의 계좌', 'fill_origin': 'SIMULATED', 'fill_kind': 'ORIGINAL',
        'backdate': {'trade_date': '2026-12-10', 'authored_at': '2026-12-10T00:10:00Z', 'backdate_trading_days': 0,
                     'is_backdated': False, 'label': '당일 기록', 'price_range_source_date': '2026-12-10',
                     'crosses_closed_period': False},
        'cost_source': 'ESTIMATED', 'cost_source_label': '추정치', 'origin_label': '모의 체결',
        'detail_deep_link': 'aaq://journal/decision/d_sim_a_0001',
        'as_of': as_of('2026-12-10T09:30:00Z', '2026-12-10', '체결 반영 18:30'),
    }


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_v121_fixtures.py 와 같은 꼴)
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
    """봉투(v1.15~v1.21 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def revise(rel, fix_rows, multi_rows=False):
    """기준 원문(버전 줄 올림)을 읽어 행만 고치고 같은 꼴로 다시 쓴다 — 고치기 전 재직렬화가 원문과 바이트 같아야 한다."""
    src = bump(base_text(rel), rel)
    env = json.loads(src)
    assert ser_envelope(env, multi_rows) == src, '%s — 직렬화 꼴이 원문과 다르다' % rel
    env['rows'] = fix_rows(env['rows'])
    return ser_envelope(env, multi_rows)


def new_files():
    texts = {}
    lads = {LAD_N: ladder('NORMAL'), LAD_S: ladder('STOPPED')}
    for rel, vm in lads.items():
        texts[rel] = ser_envelope(envelope([vm], vm['as_of']), False)
    for rel, vm in build_plans().items():
        texts[rel] = ser_envelope(envelope([vm], vm['as_of']), False)
    for rel, vm in build_gates().items():
        texts[rel] = ser_envelope(envelope([vm], vm['as_of']), False)
    for rel, vm in build_reports().items():
        texts[rel] = ser_envelope(envelope([vm], AS_X), False)
    texts[E13] = ser_envelope(envelope(build_e13(), AS_E), True)
    texts[HS] = ser_envelope(envelope(build_hs(), AS_HR), True)
    texts[J1] = ser_envelope(envelope([build_j1()], as_of('2026-12-10T09:30:00Z', '2026-12-10',
                                                           '체결 기준 2026-12-10 18:30')), False)
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


CHECKS = (('금지어', FORBIDDEN), ('개발자 메모', DEV_MEMO), ('계좌꼴', ACCOUNT_LIKE), ('전화번호 꼴', PHONE),
          ('앱키 꼴', LONG_ALNUM), ('URL 꼴', URL_LIKE), ('8자리 숫자', LONG_DIGITS), ('카운트다운·해제 버튼', COUNTDOWN))


def self_check_file(rel, s, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    if new:
        assert env['meta']['mode'] == 'LIVE', rel
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            last = path.rsplit('.', 1)[-1]
            for name, rx in CHECKS:
                if last == 'config_hash' and v == NEW_META['config_hash']:   # 봉투 meta 와 같은 가짜 hash(J-1 행 꼴)
                    continue
                assert not rx.search(v), '%s %s — %s: %s' % (rel, path, name, v)
            assert 'DRY_RUN' not in v, (rel, path, v)
            if not (rel == J1 and last in MONEY_KEYS_J1):
                assert not MONEY.search(v), '%s %s — 금액 글자: %s' % (rel, path, v)
            if not any(p in path for p in PNL_WORD_OK_PATHS):
                assert not PNL_WORD.search(v), '%s %s — 손익 낱말: %s' % (rel, path, v)
            if v.startswith('aaq://'):                                                  # 링크 = 라우트 상수만
                assert last in ('deep_link', 'detail_deep_link'), (rel, path, v)
        ks = set(keys(env['rows']))
        assert not any(PNL_KEY.search(k) for k in ks), rel
        if rel not in (E13, HS, J1):
            for bad in BAD_KEYS:
                assert bad not in ks, (rel, bad)
    return env


def check_ladder(rel, vm, current):
    assert list(vm) == ['rows', 'as_of'], rel
    assert [r['level'] for r in vm['rows']] == LADDER_LEVELS, rel
    assert [r['level'] for r in vm['rows'] if r['current']] == [current], rel
    for r, t in zip(vm['rows'], LADDER_TEXT):
        assert list(r) == LADDER_KEYS and (r['label'], r['trigger_text'], r['release_text'], r['action_text']) == t, rel
        assert all(isinstance(x, str) and x for x in t), rel


def check_plan(rel, vm):
    assert list(vm) == PLAN_KEYS and vm['path'] == 'SIM_TO_AUTO' and vm['path_label'] == PATH_LABEL, rel
    assert vm['adoption_preview'] == [] and vm['as_of']['stale_after_seconds'] == 300, rel
    st = vm['steps']
    assert [s['step_id'] for s in st] == STEP_IDS and [s['order'] for s in st] == list(range(1, 8)), rel
    assert [(s['title'], s['why_line']) for s in st] == STEP_TEXT, rel
    for s in st:
        assert list(s) == STEP_KEYS, rel
        assert s['state'] in ('PASS', 'BLOCK', 'UNKNOWN'), rel
        if s['state'] == 'BLOCK':
            assert s['blocked_reason_code'] in SIM_RESULT, rel
        elif s['state'] == 'PASS':
            assert s['blocked_reason_code'] is None, rel
        else:
            assert s['blocked_reason_code'] in (None, 'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE'), rel


def check_results(rows, allowed, prefix, n_want):
    assert len(rows) == n_want and all(list(r) == RESULT_KEYS for r in rows)
    assert [r['action_run_id'] for r in rows] == ['%s_%02d' % (prefix, i) for i in range(1, n_want + 1)]
    assert {r['id'] for r in rows} == set(allowed)
    assert all(r['handoff_route'] is None and r['retryable'] is False for r in rows)
    assert {r['level'] for r in rows} == LEVELS
    for r in rows:
        assert r['reason_code'] is None or r['reason_code'] in allowed[r['id']], r
        assert r['headline'], r


def check_gate(rel, vm):
    assert list(vm) == GATE_KEYS, rel
    assert vm['report_link']['deep_link'] == REPORT_ROUTE, rel
    assert re.match(r'^[0-9]+거래일 미실행 — (평상|보수|복구 관찰|안전 정지)$', vm['mode_label']), rel
    for r in vm['rows']:
        assert list(r) == GROW_KEYS and r['reason_code'] in RESUME_REASON, rel
        has = bool(r['actions'])
        assert has == (r['reason_code'] == 'HUMAN_DECISION' and vm['locked_label'] is None), rel
        for c in r['actions']:
            assert c['id'] == 'SEASONAL_WINDOW_CHOICE' and set(c['args']) == {'work_id', 'choice'}, rel
            assert c['args']['work_id'] == r['work_id'], rel
        if has:
            assert [c['args']['choice'] for c in r['actions']] == ['SKIP', 'REDUCED', 'AS_IS'], rel


def check_report(rel, row):
    assert list(row) == REPORT_KEYS, rel
    verdicts = [i['verdict_code'] for i in row['items']]
    assert 'UNRECOVERABLE' not in verdicts, rel
    assert row['counts'] == resume_counts(verdicts, len(row['unrecoverable_gaps'])), rel
    for i in row['items']:
        assert list(i) == ITEM_KEYS and i['verdict_label'] == VERDICT_LABEL[i['verdict_code']], rel
    for g in row['unrecoverable_gaps']:
        assert g['dataset'] == 'equity_snapshot' and g['reason_code'] == 'RESUME_GAP', rel
    if row['mode'] == 'RECOVERY_DRY':
        assert row['counts']['executed'] == 0 and 'EXECUTED_AS_REEVALUATED' not in verdicts, rel


def main():
    self_check_engine_text()
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert not any(r.startswith('x2/') for r in rels), 'BASE 에 x2/ 가 이미 있다'
    assert F8 in rels and HSTATES in rels
    assert len(NEW_FILES) == 15 and len(set(NEW_FILES)) == 15

    out = new_files()
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)
    # 🔧 개정 2.
    out[F8] = revise(F8, lambda rows: [build_f8(rows[0])])
    out[HSTATES] = revise(HSTATES, lambda rows: [build_hstates_row(r) if r['path'] == 'SIM_TO_AUTO' else r
                                                 for r in rows])

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    one = {rel: envs[rel]['rows'][0] for rel in LADDERS + PLANS + GATES + REPORTS}
    for rel, vm in one.items():
        assert len(envs[rel]['rows']) == 1, rel
        if 'as_of' in vm:
            assert vm['as_of'] == envs[rel]['as_of'], rel
    check_ladder(LAD_N, one[LAD_N], 'NORMAL')
    check_ladder(LAD_S, one[LAD_S], 'STOPPED')
    assert [dict(r, current=None) for r in one[LAD_N]['rows']] == [dict(r, current=None) for r in one[LAD_S]['rows']]
    for rel in PLANS:
        check_plan(rel, one[rel])
    assert all(s['state'] == 'PASS' for s in one[H_READY]['steps'])
    assert one[H_FATE]['steps'][4]['state'] == 'UNKNOWN' and one[H_FATE]['steps'][4]['blocked_reason_code'] is None
    hst = [r for r in envs[HSTATES]['rows'] if r['path'] == 'SIM_TO_AUTO'][0]
    assert [s['step_id'] for s in hst['steps']] == STEP_IDS and hst['adoption_preview'] == []
    assert [s['title'] for s in hst['steps']] == [t for t, _w in STEP_TEXT]
    check_results(envs[E13]['rows'], E13_ALLOWED, 'ar_e13', 31)
    check_results(envs[HS]['rows'], HS_ALLOWED, 'ar_hs', 20)
    assert all(r['reason_code'] is not None for r in envs[HS]['rows'] if r['id'] == 'HANDOVER_COMMIT')
    for rel in GATES:
        check_gate(rel, one[rel])
    sp, lk = copy.deepcopy(one[G_SP]), copy.deepcopy(one[G_LK])
    for r in sp['rows']:
        r['actions'] = []
    sp['locked_label'] = LOCKED
    assert sp == lk
    for rel in REPORTS:
        check_report(rel, one[rel])
    check_report(F8, envs[F8]['rows'][0])
    assert {one[R_FULL]['mode'], one[R_NORM]['mode'], envs[F8]['rows'][0]['mode']} == \
        {'RECOVERY_FULL', 'NORMAL', 'RECOVERY_DRY'}
    j = envs[J1]['rows']
    assert len(j) == 1 and j[0]['mode'] == 'SIM_INTERNAL' and j[0]['status'] == 'REJECTED'
    assert {c['code'] for c in j[0]['reasons']} <= SIM_BROKER

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    assert n_version_only == BASE_FILES - 2, n_version_only

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_v122_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 2 · 신설 %d) · contract 1.22.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
