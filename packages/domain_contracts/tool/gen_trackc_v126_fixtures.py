#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.26(트랙 C 선행 — 실전 커밋 필수 3묶음 · 01 §35) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_trackc_v126_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_trackb_v125_fixtures.py(계약 v1.25 · 그 스크립트는 v1.25 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-20_트랙C선행_계약v1.26_설계서.md` §5 · 339 → 359 = 신설 20 · 개정 2 · 버전 줄만 337)
  (a) 전 봉투의 "contract_version": "1.25.0" → "1.26.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 2 — `m5/block_board_kill_active` · `_resume_incomplete` 의 보드 행에 `"recon_clear": null` 한 칸(🆕 `BlockBoardRow.reconClear` ·
      키 차례 = `toJson` 선언 차례 · C-59 ① «표본 키 == toJson 키» · `_clear` · `_stopped` = 행 0 → 버전 줄만).
      다른 글자 불변(같은 직렬화기로 다시 쓴 원판 == 원판을 먼저 확인).
  (c) 신설 20 — m5/ 위저드 12(`handover_wizard_*`) · 규칙 변경 게이트 5(`rule_change_gate_*`) · 결과 2
      (`rule_change_request_results` · `recon_clear_results`) · 보드 RECON 1(`block_board_recon_mismatch`).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `check_*` · 엔진 글자는 BASE 의 엔진 소스에 실제로 있는지 본다.

🔴 돈·수치 0 새로 정함(설계서 머리) — 냉각 24h · 확정 기한 24h · 규칙 변경 냉각 30일 = SPEC·엔진 글자 그대로 · 관찰 거래일 = 기존
   표본 선례(2) · 금액·예수금·계좌번호 = 칸 0 · 확정 성공 문장(금액) = 표본 0(K175).
🔴 글자 출처 — ⓐ 엔진 글자 칸 = 바이트 그대로(`sim_to_auto.dart` 단계 제목·왜·상태 글자·머리 · 커밋 창 라벨 꼴 ·
   `safety_text.dart` 플래그 사전 · `ledger_views.dart` 원인 코드 라벨) · ⓑ 기존 표본 복사(체험 카드 = `m9/operations_sim_auto` ·
   사다리 = `m5/breaker_ladder_normal` · 잠김 문장 = v1.20~v1.25 표본) ⓒ 원천 0 칸 = «(합성) …».
🔴 봉투 `meta.mode` = `LIVE`(전 339 표본 선례 · v1.22 simToAuto 표본도 LIVE) — 모의/실전 갈래는 VM 글자가 말한다.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_trackc_v126_fixtures.py
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
# 계약 1.25.0 · 픽스처 339 의 기준 커밋(origin/main · E3d-2 #266 — 계약 패키지 = PR #256 이후 무변경).
BASE = '1fdeba99115e473a0b03e1f72fded8ba01fd2eaf'

OLD_VER = '"contract_version": "1.25.0"'
NEW_VER = '"contract_version": "1.26.0"'
BASE_FILES = 339
WANT_FILES = 359

FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'(?<!이 )화면이|화면은|화면·')      # 사용자 문장 자리의 개발자 메모(H50)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6
PNL_WORD = re.compile(r'평가손익|수익률|평가액|손익|세후')
MONEY = re.compile(r'[0-9][0-9,]*(?:억|만)?[0-9,]*원')
DIGIT_THEN_UNIT = re.compile(r'[0-9](?:원|만)')
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
URL_LIKE = re.compile(r'https?://|github\.com|\.io/')
LONG_DIGITS = re.compile(r'[0-9]{8,}')                     # 8자리 이상 숫자 0
COUNTDOWN = re.compile(r'카운트다운|해제 버튼')            # C-55 ⑰ 꼴
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}
# 표본 어디에도 없어야 하는 키(C-60 ⑬ · 금액·잔고·계좌·세션 밖 식별자).
FORBIDDEN_KEYS = {'amount', 'cash', 'pnl', 'krw', 'won', 'balance', 'account_no', 'countdown', 'remaining_seconds',
                  'decision_id', 'cleared_by', 'hash_before', 'hash_after', 'change_type'}

# ── 엔진 글자(BASE 엔진 소스에 실제로 있는지 check_engine_text 가 본다) ──
ENGINE_S2A = 'packages/core_engine/lib/src/mode/sim_to_auto.dart'
ENGINE_SAFETY_TEXT = 'packages/core_engine/lib/src/safety/safety_text.dart'
ENGINE_LEDGER_VIEWS = 'packages/core_engine/lib/src/ops/ledger_views.dart'
PATH_LABEL = '모의투자 → 실전 자동 매매(관찰부터)'
STEPS = [   # (step_id, title, why) — 엔진 `SimToAutoStep`
    ('SIM_TO_AUTO_S1', '모의 체험 확인', '체험 5항목을 채웠는지 엔진이 확인합니다'),
    ('SIM_TO_AUTO_S2', '계산 자가검사', '실전과 같은 계산인지 골든 벡터로 다시 확인합니다'),
    ('SIM_TO_AUTO_S3', '실전 키 확인', '실전 키를 등록하고 조회만으로 확인합니다 — 주문은 내지 않습니다'),
    ('SIM_TO_AUTO_S4', '계좌 연결', '전략 넷이 모두 실전 계좌에 연결됐는지 확인합니다'),
    ('SIM_TO_AUTO_S5', '모의 기록 처리', '모의 기록을 보관할지 지울지 고릅니다 — 실전 원장에는 남지 않습니다'),
    ('SIM_TO_AUTO_S6', '생체 확인', '생체 확인 1회로 전환을 시작합니다'),
    ('SIM_TO_AUTO_S7', '24시간 냉각', '생체 확인 뒤 24시간을 기다립니다 — 건너뛸 수 없습니다'),
]
NOT_YET = '아직 확인 전'
S1_PASS = '체험 5항목 완료'
S2_PASS = '골든 벡터 통과'
S3_PASS = '실전 키 조회 확인'
S3_FAIL = '실전 키 조회가 실패했습니다'
S4_PASS = '전략 4개 모두 계좌 연결'                         # `'전략 ${kP0sSeedStrategies.length}개 모두 계좌 연결'` 꼴
S5_PENDING = '고르기 전'
S5_KEEP = '모의 기록을 앱 밖 보관본으로 남깁니다'
S6_PENDING = '생체 확인 전'
S7_PENDING = '생체 확인 뒤 시작합니다'
S7_TIME = '시각을 확인할 수 없어 기다립니다'
S7_EXPIRED = '확정 기한이 지났습니다 — 처음부터 다시 진행해 주세요'
HEAD_READY = '확정할 수 있습니다 — 확정하면 실전 관찰(주문 0)부터 시작합니다'
HEAD_NOT_SIM = '모의투자 자동 매매 중일 때만 실전으로 옮길 수 있습니다.'
ENGINE_S2A_TEXTS = [t for s in STEPS for t in s[1:]] + [
    NOT_YET, S1_PASS, S2_PASS, S3_PASS, S3_FAIL, S5_PENDING, S5_KEEP, S6_PENDING, S7_PENDING, S7_TIME, S7_EXPIRED,
    HEAD_READY, HEAD_NOT_SIM, PATH_LABEL, "'전략 ${kP0sSeedStrategies.length}개 모두 계좌 연결'",
    "'생체 확인 ${kstMinuteText(opened)}'", "'냉각 중 — ${kstMinuteText(coolEnd)} 이후 확정할 수 있습니다'",
    "'냉각 끝 — ${kstMinuteText(deadline)} 전까지 확정하세요'", "'${firstOpen.step.title} — ${firstOpen.label}'",
    "'정기 리밸런싱 $round 전 관찰 가능 $count거래일'",
    "'정기 리밸런싱 $round 전에 관찰 $n거래일을 채울 수 없습니다 — $round 09:10 뒤에 확정할 수 있습니다'",
]
RECON_LABEL = '브로커 원장과 어긋납니다'                      # `kFlagDictionary[RECON_MISMATCH]`
RECON_TEXT = '원인 코드를 골라 해소하십시오. /resume 으로는 풀리지 않습니다.'
JM_LABEL = '일지가 비어 있습니다'
JM_TEXT = '일지를 채우면 자동으로 풀립니다.'
ORIGIN_LABELS = [   # 엔진 `kOriginLabels`(브로커 계열 6 — `writableOriginCodesFor(canonBroker)` ∩ 자동 갈래 · 차례 = 엔진 사전)
    ('FILL_LAG', '체결 반영 지연'),
    ('MANUAL_ORDER', '수동 주문'),
    ('DB_ERROR', '원장 기록 오류'),
    ('BROKER_ERROR', '브로커 응답 오류'),
    ('EXTERNAL_CASHFLOW', '시스템 밖 입출금'),
    ('CORPORATE_ACTION', '분할 · 병합'),
]
BREAKER_NORMAL = '정상'

# ── 이름 ─────────────────────────────────────────────────────────────────
WZ = 'm5/handover_wizard_%s.json'
WZ_NAMES = ['trial_incomplete', 's3_blocked', 'fate_pending', 'start_ready', 'cooling', 'commit_ready',
            'window_blocked', 'expired', 'time_unknown', 'not_applicable', 'committed', 'locked']
WZ_VMS = [WZ % n for n in WZ_NAMES]
RG = 'm5/rule_change_gate_%s.json'
RG_NAMES = ['first_candidate', 'cooling', 'approvable', 'empty', 'locked']
RG_VMS = [RG % n for n in RG_NAMES]
RCQ_RESULTS = 'm5/rule_change_request_results.json'
RECON_RESULTS = 'm5/recon_clear_results.json'
BB_RECON = 'm5/block_board_recon_mismatch.json'
NEW_FILES = WZ_VMS + RG_VMS + [RCQ_RESULTS, BB_RECON, RECON_RESULTS]
# 보드 행이 있는 원판 2(`clear` · `stopped` = 행 0 → 버전 줄만 · main 이 확인한다).
REVISED = ['m5/block_board_kill_active.json', 'm5/block_board_resume_incomplete.json']
BOARD_NO_ROWS = ['m5/block_board_clear.json', 'm5/block_board_stopped.json']

SRC_TRIAL = 'm9/operations_sim_auto.json'
SRC_LADDER_NORMAL = 'm5/breaker_ladder_normal.json'
SRC_GATE_LOCKED = 'm5/kill_resume_gate_locked.json'
SRC_E13 = 'm5/safety_action_results_e13.json'
UNTOUCHED = [SRC_TRIAL, SRC_LADDER_NORMAL, SRC_GATE_LOCKED, SRC_E13]

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.26.0',
    'generated_at': '2026-11-20T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261120,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(observed, trade_date, label, stale=300):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': stale, 'label': label}


# §5 조각(갈래 A 일정 합성 — 체험 12-21~ · 생체 01-11 10:00 KST · 냉각 끝 01-12 10:00 · 기한 01-13 10:00 · 첫 승인 요청 12-10).
AS_TRIAL = as_of('2026-12-28T03:00:00Z', '2026-12-28', '전환 판정 2026-12-28 12:00')
AS_PRE = as_of('2027-01-08T03:00:00Z', '2027-01-08', '전환 판정 2027-01-08 12:00')
AS_COOL = as_of('2027-01-11T06:00:00Z', '2027-01-11', '전환 판정 2027-01-11 15:00')
AS_READY = as_of('2027-01-12T03:00:00Z', '2027-01-12', '전환 판정 2027-01-12 12:00')
AS_WINDOW = as_of('2027-01-28T03:00:00Z', '2027-01-28', '전환 판정 2027-01-28 12:00')
AS_EXPIRED = as_of('2027-01-10T03:00:00Z', '2027-01-10', '전환 판정 2027-01-10 12:00')
AS_NA = as_of('2026-12-20T03:00:00Z', '2026-12-20', '전환 판정 2026-12-20 12:00')
AS_DONE = as_of('2027-01-12T04:00:00Z', '2027-01-12', '전환 판정 2027-01-12 13:00')
AS_RC_REQ = as_of('2026-12-10T01:00:00Z', '2026-12-10', '규칙 변경 기준 2026-12-10 10:00', 93600)
AS_RC_COOL = as_of('2026-12-15T01:00:00Z', '2026-12-15', '규칙 변경 기준 2026-12-15 10:00', 93600)
AS_RC_OK = as_of('2027-01-09T03:00:00Z', '2027-01-09', '규칙 변경 기준 2027-01-09 12:00', 93600)
AS_RC_LIVE = as_of('2027-01-14T03:00:00Z', '2027-01-14', '규칙 변경 기준 2027-01-14 12:00', 93600)
AS_RC_RESULTS = as_of('2026-12-10T01:05:00Z', '2026-12-10', '명령 기준 2026-12-10 10:05', 93600)
AS_BB_RECON = as_of('2027-01-13T22:10:00Z', '2027-01-14', '안전 기준 2027-01-14 07:10', 93600)
AS_RECON_RESULTS = as_of('2027-01-13T22:20:00Z', '2027-01-14', '안전 기준 2027-01-14 07:20', 93600)

LOCKED = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'   # v1.20~v1.25 표본과 같은 글자
SESSION = 'hs_s2a_0111'
OPENED_1 = '생체 확인 2027-01-11 10:00'
COOLING_1 = '냉각 중 — 2027-01-12 10:00 이후 확정할 수 있습니다'
COOLED_1 = '냉각 끝 — 2027-01-13 10:00 전까지 확정하세요'
COOL_TEXT_1 = '(합성) 냉각 끝 2027-01-12 10:00'
DEADLINE_TEXT_1 = '(합성) 확정 기한 2027-01-13 10:00'
WINDOW_OK = '정기 리밸런싱 2027-02-01 전 관찰 가능 13거래일'
WINDOW_NO = '정기 리밸런싱 2027-02-01 전에 관찰 2거래일을 채울 수 없습니다 — 2027-02-01 09:10 뒤에 확정할 수 있습니다'
NOTICE_APPROVAL = '(합성) 승인된 설정이 없으면 확정할 수 없습니다 — 규칙 변경 게이트에서 첫 승인을 먼저 요청하십시오'
DONE = '(합성) 확정됨 — 실전 관찰 중(주문 0) · 승격은 운영 화면에서 합니다'

LINK_DIAG = {'label': '(합성) 자가검사 보기', 'deep_link': 'aaq://settings/diagnostics'}
LINK_KEYS = {'label': '(합성) 실전 키 등록', 'deep_link': 'aaq://settings/credentials'}
LINK_ACCOUNTS = {'label': '(합성) 계좌 연결 보기', 'deep_link': 'aaq://settings/accounts'}


def act(wire, args, label):
    return {'id': wire, 'args': dict(args), 'label': label}


A_KEEP = act('HANDOVER_SIM_LEDGER_FATE', {'fate': 'KEEP'}, '(합성) 앱 밖 보관본으로 남기기')
A_DISCARD = act('HANDOVER_SIM_LEDGER_FATE', {'fate': 'DISCARD'}, '(합성) 모의 기록 지우기')
A_START = act('HANDOVER_SESSION_START', {'path': 'SIM_TO_AUTO'}, '(합성) 생체 확인하고 전환 시작')
A_RESTART = act('HANDOVER_SESSION_START', {'path': 'SIM_TO_AUTO'}, '(합성) 처음부터 다시 시작')
A_CANCEL = act('HANDOVER_SESSION_CANCEL', {'handover_session_id': SESSION}, '(합성) 전환 취소')
A_COMMIT = act('HANDOVER_COMMIT', {'handover_session_id': SESSION}, '(합성) 확정하기')

WZ_KEYS = ['headline', 'level', 'reason_code', 'path_label', 'rows', 'trial', 'cooling_text', 'deadline_text',
           'window_text', 'notice_text', 'done_label', 'locked_label', 'as_of']
ROW_KEYS = ['step', 'level', 'link', 'actions']
STEP_KEYS = ['step_id', 'order', 'title', 'why_line', 'state', 'state_label', 'blocked_reason_code']
RG_KEYS = ['headline', 'level', 'window_text', 'candidates', 'rows', 'empty_label', 'locked_label', 'as_of']
CAND_KEYS = ['candidate_id', 'label', 'category_label', 'hash_text', 'request_label', 'notice_text']
QROW_KEYS = ['request_id', 'category_label', 'hash_text', 'requested_text', 'cooling_text', 'state_label', 'level',
             'approve_label', 'cancel']
BB_KEYS = ['headline', 'level', 'breaker_label', 'rows', 'gauges', 'ladder', 'stopped_decision_link', 'kill_switch_link',
           'empty_label', 'as_of']
BB_ROW_KEYS = ['row_id', 'label', 'set_at_text', 'clear_kind_label', 'clear_instruction', 'level', 'link', 'recon_clear']
FORM_KEYS = ['choices', 'notice_text']
RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']

# K169 단계별 허용 동작(C-60 ③과 같은 표).
ALLOWED = {
    'SIM_TO_AUTO_S2': {'SELFTEST_GOLDEN_RUN'},
    'SIM_TO_AUTO_S5': {'HANDOVER_SIM_LEDGER_FATE'},
    'SIM_TO_AUTO_S6': {'HANDOVER_SESSION_START'},
    'SIM_TO_AUTO_S7': {'HANDOVER_SESSION_CANCEL', 'HANDOVER_COMMIT'},
}
STATE_LEVEL = {'PASS': {'OK'}, 'BLOCK': {'BLOCKED', 'WATCH'}, 'UNKNOWN': {'INFO', 'WATCH'}}


# ────────────────────────────────────────────────────────────────────────
# 위저드 12
# ────────────────────────────────────────────────────────────────────────
def step(i, state, label, code=None):
    sid, title, why = STEPS[i]
    return dict(zip(STEP_KEYS, [sid, i + 1, title, why, state, label, code]))


def row(i, state, label, level, code=None, link=None, actions=()):
    return dict(zip(ROW_KEYS, [step(i, state, label, code), level, copy.deepcopy(link),
                               [copy.deepcopy(a) for a in actions]]))


def wz_vm(head, level, code, rows, trial=None, cool=None, deadline=None, window=None, notice=None, done=None,
          locked=None, asof=None):
    return dict(zip(WZ_KEYS, [head, level, code, PATH_LABEL, rows, copy.deepcopy(trial), cool, deadline, window,
                              notice, done, locked, copy.deepcopy(asof)]))


def pass_rows(n):
    """S1~S{n} 통과 행(엔진 글자)."""
    labels = [S1_PASS, S2_PASS, S3_PASS, S4_PASS, S5_KEEP, OPENED_1]
    return [row(i, 'PASS', labels[i], 'OK') for i in range(n)]


def trial_card():
    env = json.loads(base_text(SRC_TRIAL))
    return copy.deepcopy(env['rows'][0]['trial'])


def build_wizard():
    trial = trial_card()
    assert trial['headline'] == '모의 체험 진행 중 — 남은 항목 2개', trial['headline']
    tail_pending = [row(4, 'UNKNOWN', S5_PENDING, 'INFO'), row(5, 'UNKNOWN', S6_PENDING, 'INFO'),
                    row(6, 'UNKNOWN', S7_PENDING, 'INFO')]
    out = {}
    # 1 체험 미완 — S1 막힘(체험 머리 = S1 글자) · S2·S3 아직 · 동작 0.
    rows = [row(0, 'BLOCK', trial['headline'], 'BLOCKED', 'SIM_TO_AUTO_TRIAL_INCOMPLETE'),
            row(1, 'UNKNOWN', NOT_YET, 'INFO', link=LINK_DIAG),
            row(2, 'UNKNOWN', NOT_YET, 'INFO', link=LINK_KEYS),
            row(3, 'PASS', S4_PASS, 'OK')] + copy.deepcopy(tail_pending)
    out['trial_incomplete'] = wz_vm('%s — %s' % (STEPS[0][1], trial['headline']), 'BLOCKED',
                                    'SIM_TO_AUTO_TRIAL_INCOMPLETE', rows, trial=trial, asof=AS_TRIAL)
    # 2 S3 막힘 — S2 링크(자가검사) · S3 링크(키 등록).
    rows = [row(0, 'PASS', S1_PASS, 'OK'), row(1, 'PASS', S2_PASS, 'OK', link=LINK_DIAG),
            row(2, 'BLOCK', S3_FAIL, 'BLOCKED', 'SIM_TO_AUTO_LIVE_KEYS_FAILED', link=LINK_KEYS),
            row(3, 'PASS', S4_PASS, 'OK', link=LINK_ACCOUNTS)] + copy.deepcopy(tail_pending)
    out['s3_blocked'] = wz_vm('%s — %s' % (STEPS[2][1], S3_FAIL), 'BLOCKED', 'SIM_TO_AUTO_LIVE_KEYS_FAILED', rows,
                              asof=AS_PRE)
    # 3 fate 고르기 — S5 동작 2(세션 전 · 세션 id 0). 엔진 code = 첫 미통과 단계 id.
    rows = pass_rows(4) + [row(4, 'UNKNOWN', S5_PENDING, 'INFO', actions=(A_KEEP, A_DISCARD)),
                           row(5, 'UNKNOWN', S6_PENDING, 'INFO'), row(6, 'UNKNOWN', S7_PENDING, 'INFO')]
    out['fate_pending'] = wz_vm('%s — %s' % (STEPS[4][1], S5_PENDING), 'INFO', 'SIM_TO_AUTO_S5', rows, asof=AS_PRE)
    # 4 시작 — S6 동작 1(path 만) · 승인 config 고지.
    rows = pass_rows(5) + [row(5, 'UNKNOWN', S6_PENDING, 'INFO', actions=(A_START,)),
                           row(6, 'UNKNOWN', S7_PENDING, 'INFO')]
    out['start_ready'] = wz_vm('%s — %s' % (STEPS[5][1], S6_PENDING), 'INFO', 'SIM_TO_AUTO_S6', rows,
                               notice=NOTICE_APPROVAL, asof=AS_PRE)
    # 5 냉각 — S7 막힘(WATCH) · 취소 1 · 시각 글자 2.
    rows = pass_rows(6) + [row(6, 'BLOCK', COOLING_1, 'WATCH', 'SIM_TO_AUTO_COOLING', actions=(A_CANCEL,))]
    out['cooling'] = wz_vm('%s — %s' % (STEPS[6][1], COOLING_1), 'WATCH', 'SIM_TO_AUTO_COOLING', rows,
                           cool=COOL_TEXT_1, deadline=DEADLINE_TEXT_1, asof=AS_COOL)
    # 6 확정 가능 — S7 통과 · 확정 + 취소 · 커밋 창 글자.
    ready_rows = pass_rows(6) + [row(6, 'PASS', COOLED_1, 'OK', actions=(A_COMMIT, A_CANCEL))]
    out['commit_ready'] = wz_vm(HEAD_READY, 'OK', None, ready_rows, cool=COOL_TEXT_1, deadline=DEADLINE_TEXT_1,
                                window=WINDOW_OK, asof=AS_READY)
    # 7 커밋 창 막힘 — 7 통과 · 머리 = 창 라벨(엔진) · 확정 0 · 취소 1.
    rows = [row(i, 'PASS', l, 'OK') for i, l in enumerate([S1_PASS, S2_PASS, S3_PASS, S4_PASS, S5_KEEP,
                                                            '생체 확인 2027-01-27 11:00'])]
    rows.append(row(6, 'PASS', '냉각 끝 — 2027-01-29 11:00 전까지 확정하세요', 'OK', actions=(A_CANCEL,)))
    out['window_blocked'] = wz_vm(WINDOW_NO, 'BLOCKED', 'SIM_TO_AUTO_COMMIT_WINDOW', rows,
                                  cool='(합성) 냉각 끝 2027-01-28 11:00', deadline='(합성) 확정 기한 2027-01-29 11:00',
                                  window=WINDOW_NO, asof=AS_WINDOW)
    # 8 기한 지남 — S7 막힘 · S6 다시 시작 1.
    rows = pass_rows(5) + [row(5, 'PASS', '생체 확인 2027-01-08 10:00', 'OK', actions=(A_RESTART,)),
                           row(6, 'BLOCK', S7_EXPIRED, 'BLOCKED', 'SIM_TO_AUTO_SESSION_EXPIRED')]
    out['expired'] = wz_vm('%s — %s' % (STEPS[6][1], S7_EXPIRED), 'BLOCKED', 'SIM_TO_AUTO_SESSION_EXPIRED', rows,
                           asof=AS_EXPIRED)
    # 9 시각 모름 — S7 UNKNOWN(WATCH) · 취소 자리 그대로(K176 — 거부는 결과 원문).
    rows = pass_rows(6) + [row(6, 'UNKNOWN', S7_TIME, 'WATCH', 'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE',
                               actions=(A_CANCEL,))]
    out['time_unknown'] = wz_vm('%s — %s' % (STEPS[6][1], S7_TIME), 'WATCH', 'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE',
                                rows, cool=COOL_TEXT_1, deadline=DEADLINE_TEXT_1, asof=AS_COOL)
    # 10 전제 밖 — 행 0 · 머리만.
    out['not_applicable'] = wz_vm(HEAD_NOT_SIM, 'INFO', 'SIM_TO_AUTO_NOT_SIM_AUTO', [], asof=AS_NA)
    # 11 확정됨 — 행 그대로 · 동작 0 · 상태 문장.
    done_rows = copy.deepcopy(ready_rows)
    for r in done_rows:
        r['actions'] = []
    out['committed'] = wz_vm('(합성) 실전 관찰로 옮겼습니다', 'OK', None, done_rows, done=DONE, asof=AS_DONE)
    # 12 잠김 — 확정 가능 상태 + 잠김 · 모든 동작 0.
    locked_rows = copy.deepcopy(ready_rows)
    for r in locked_rows:
        r['actions'] = []
    out['locked'] = wz_vm(HEAD_READY, 'OK', None, locked_rows, cool=COOL_TEXT_1, deadline=DEADLINE_TEXT_1,
                          window=WINDOW_OK, locked=LOCKED, asof=AS_READY)
    assert list(out) == WZ_NAMES
    return {WZ % k: v for k, v in out.items()}


# ────────────────────────────────────────────────────────────────────────
# 규칙 변경 게이트 5 · 결과 2
# ────────────────────────────────────────────────────────────────────────
CAT = '(합성) 전략 규칙'
HASH = '(합성) 승인 없음 → 3f2a9c1d'
REQ_ID = 'rc_req_1210'


def rg_vm(head, level, window, cands, rows, empty=None, locked=None, asof=None):
    return dict(zip(RG_KEYS, [head, level, window, cands, rows, empty, locked, copy.deepcopy(asof)]))


def qrow(cooling, state, level, approve, cancel):
    return dict(zip(QROW_KEYS, [REQ_ID, CAT, HASH, '(합성) 12-10 10:05 요청', cooling, state, level, approve,
                                copy.deepcopy(cancel)]))


CANCEL_CALL = {'id': 'RULE_CHANGE_CANCEL', 'args': {'request_id': REQ_ID}, 'label': '(합성) 요청 거두기'}


def build_gate():
    cand = dict(zip(CAND_KEYS, ['cfg_cand_3f2a9c1d', '(합성) 지금 쓰는 설정 — 첫 승인', CAT, HASH,
                                '(합성) 첫 승인 요청', '(합성) 요청 뒤 30일 냉각이 끝나야 승인할 수 있습니다']))
    window_first = '(합성) 첫 승인은 12월 창 밖에서도 요청할 수 있습니다 — 냉각 30일은 그대로입니다'
    cool_text = '(합성) 냉각 중 — 01-09 10:05 이후 승인'
    out = {
        'first_candidate': rg_vm('(합성) 승인된 설정이 없습니다 — 실전 기동 전에 첫 승인이 필요합니다', 'ACT',
                                 window_first, [cand], [], asof=AS_RC_REQ),
        'cooling': rg_vm('(합성) 첫 승인 요청이 냉각 중입니다', 'WATCH', window_first, [],
                         [qrow(cool_text, '(합성) 냉각 중', 'WATCH', None, CANCEL_CALL)], asof=AS_RC_COOL),
        'approvable': rg_vm('(합성) 냉각이 끝났습니다 — 승인할 수 있습니다', 'ACT', window_first, [],
                            [qrow('(합성) 냉각 끝', '(합성) 승인할 수 있습니다', 'ACT', '(합성) 승인하기', CANCEL_CALL)],
                            asof=AS_RC_OK),
        'empty': rg_vm('(합성) 승인된 설정으로 돌고 있습니다', 'OK', None, [], [],
                       empty='(합성) 열린 요청이 없습니다 — 지금 설정은 승인되어 있습니다', asof=AS_RC_LIVE),
        'locked': rg_vm('(합성) 첫 승인 요청이 냉각 중입니다', 'WATCH', window_first, [],
                        [qrow(cool_text, '(합성) 냉각 중', 'WATCH', None, None)], locked=LOCKED, asof=AS_RC_COOL),
    }
    assert list(out) == RG_NAMES
    return {RG % k: v for k, v in out.items()}


def result(run_id, wire, level, headline, code):
    return dict(zip(RESULT_KEYS, [run_id, wire, level, headline, code, None, False]))


BIO_HEAD = '(합성) 생체 확인을 할 수 없어 진행하지 않았습니다.'   # `safety_action_results_e13` 과 같은 글자


def build_results():
    rcq = [
        result('ar_rcq_01', 'RULE_CHANGE_REQUEST', 'OK', '(합성) 첫 승인을 요청했습니다 — 30일 냉각 뒤 승인할 수 있습니다.', None),
        result('ar_rcq_02', 'RULE_CHANGE_REQUEST', 'ACT', '(합성) 사유와 되돌리는 방법을 적어 주십시오.',
               'RULE_CHANGE_FIELDS_MISSING'),
        result('ar_rcq_03', 'RULE_CHANGE_REQUEST', 'ACT', '(합성) 결정 저널 세 칸을 채워 주십시오.',
               'RULE_CHANGE_JOURNAL_MISSING'),
        result('ar_rcq_04', 'RULE_CHANGE_REQUEST', 'BLOCKED', '(합성) 이 설정 기록을 찾지 못했습니다.',
               'RULE_CHANGE_CONFIG_UNKNOWN'),
        result('ar_rcq_05', 'RULE_CHANGE_REQUEST', 'BLOCKED', '(합성) 서버 시각을 확인하지 못해 요청하지 않았습니다.',
               'TRUSTED_TIME_UNKNOWN'),
        result('ar_rcq_06', 'RULE_CHANGE_REQUEST', 'BLOCKED', '(합성) 같은 저널 번호가 이미 있어 요청하지 않았습니다.',
               'JOURNAL_ID_TAKEN'),
        result('ar_rcq_07', 'RULE_CHANGE_REQUEST', 'BLOCKED', BIO_HEAD, 'BIOMETRIC_UNAVAILABLE'),
    ]
    rcl = [
        result('ar_rcl_01', 'RECON_CLEAR', 'OK', '(합성) 대사 불일치 표시를 풀었습니다 — 결정 저널이 함께 남았습니다.', None),
        result('ar_rcl_02', 'RECON_CLEAR', 'INFO', '(합성) 풀 대사 불일치 표시가 없습니다.', 'RECON_NOT_BLOCKED'),
        result('ar_rcl_03', 'RECON_CLEAR', 'BLOCKED', '(합성) 이 원인 코드로는 풀 수 없습니다.',
               'RECON_ORIGIN_NOT_ALLOWED'),
        result('ar_rcl_04', 'RECON_CLEAR', 'ACT', '(합성) 결정 저널 세 칸을 채워 주십시오.', 'RECON_JOURNAL_MISSING'),
        result('ar_rcl_05', 'RECON_CLEAR', 'BLOCKED', '(합성) 같은 저널 번호가 이미 있어 풀지 않았습니다.',
               'JOURNAL_ID_TAKEN'),
        result('ar_rcl_06', 'RECON_CLEAR', 'BLOCKED', BIO_HEAD, 'BIOMETRIC_UNAVAILABLE'),
    ]
    return rcq, rcl


# ────────────────────────────────────────────────────────────────────────
# 보드 RECON 1 · 개정 4
# ────────────────────────────────────────────────────────────────────────
KILL_LINK = {'label': '(합성) 킬스위치', 'deep_link': 'aaq://m5/kill-switch'}   # v1.25 보드 표본과 같은 글자


def ladder_of(rel, asof):
    v = copy.deepcopy(json.loads(base_text(rel))['rows'][0])
    assert list(v) == ['rows', 'as_of'], rel
    v['as_of'] = copy.deepcopy(asof)
    return v


def build_board_recon():
    form = dict(zip(FORM_KEYS, [[{'origin_code': c, 'label': l} for c, l in ORIGIN_LABELS],
                                '(합성) 해제는 결정 저널과 함께 기록됩니다 — 주문을 내지 않습니다']))
    recon = dict(zip(BB_ROW_KEYS, ['RECON_MISMATCH', RECON_LABEL, '(합성) 01-14 07:05부터', '(합성) 원인 코드를 골라야 풀립니다',
                                   RECON_TEXT, 'BLOCKED', None, form]))
    journal = dict(zip(BB_ROW_KEYS, ['JOURNAL_MISSING', JM_LABEL, '(합성) 01-13 16:30부터', '(합성) 자동으로 풀립니다',
                                     JM_TEXT, 'ACT', {'label': '(합성) 일지 쓰기', 'deep_link': 'aaq://journal/draft/dj_rc_01'},
                                     None]))
    return dict(zip(BB_KEYS, ['(합성) 막힌 것 2 — 대사 불일치 · 일지', 'BLOCKED', BREAKER_NORMAL, [recon, journal], [],
                              ladder_of(SRC_LADDER_NORMAL, AS_BB_RECON), None, copy.deepcopy(KILL_LINK), None,
                              copy.deepcopy(AS_BB_RECON)]))


def revise_board(rel):
    """`m5/block_board_*` 원판 → 행마다 `recon_clear: null`(끝 칸) — 다른 글자 불변."""
    env = json.loads(base_text(rel))
    assert ser_envelope(env, True) == base_text(rel), ('직렬화기가 원판을 그대로 못 쓴다', rel)
    for vm in env['rows']:
        for r in vm['rows']:
            assert list(r) == BB_ROW_KEYS[:-1], (rel, list(r))
            r['recon_clear'] = None
    return bump(ser_envelope(env, True), rel), env


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_trackb_v125 와 같은 꼴 — 원판 바이트 재현을 revise_board 가 확인한다)
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
    """봉투(v1.15~v1.25 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def new_files():
    texts = {}
    vms = {}
    vms.update(build_wizard())
    vms.update(build_gate())
    vms[BB_RECON] = build_board_recon()
    for rel, r in vms.items():
        texts[rel] = ser_envelope(envelope([r], r['as_of']), True)
    rcq, rcl = build_results()
    texts[RCQ_RESULTS] = ser_envelope(envelope(rcq, AS_RC_RESULTS), True)
    texts[RECON_RESULTS] = ser_envelope(envelope(rcl, AS_RECON_RESULTS), True)
    return texts, vms


# ────────────────────────────────────────────────────────────────────────
# 자가 검사
# ────────────────────────────────────────────────────────────────────────
def strings(v, path='$', skip=('meta', 'deep_link')):
    if isinstance(v, dict):
        for k, x in v.items():
            if k in skip:
                continue
            yield from strings(x, '%s.%s' % (path, k), skip)
    elif isinstance(v, list):
        for i, x in enumerate(v):
            yield from strings(x, '%s[%d]' % (path, i), skip)
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


def deep_links(v):
    if isinstance(v, dict):
        for k, x in v.items():
            if k == 'deep_link':
                yield x
            else:
                yield from deep_links(x)
    elif isinstance(v, list):
        for x in v:
            yield from deep_links(x)


_ROUTE_RX = []


def load_routes():
    src = git('show', '%s:packages/domain_contracts/lib/src/navigation/app_links.dart' % BASE)
    for r in re.findall(r"'(aaq://[^']+)'", src):
        _ROUTE_RX.append(re.compile('^' + re.sub(r':[A-Za-z]+', r'[^/]+', re.escape(r).replace('\\:', ':')) + '$'))
    assert len(_ROUTE_RX) >= 84, len(_ROUTE_RX)


def is_route(link):
    return any(rx.match(link) for rx in _ROUTE_RX)


CHECKS = (('금지어', FORBIDDEN), ('개발자 메모', DEV_MEMO), ('계좌꼴', ACCOUNT_LIKE), ('앱키 꼴', LONG_ALNUM),
          ('URL 꼴', URL_LIKE), ('8자리 숫자', LONG_DIGITS), ('손익 낱말', PNL_WORD), ('금액 글자', MONEY),
          ('숫자 뒤 원·만', DIGIT_THEN_UNIT), ('카운트다운·해제 버튼', COUNTDOWN))


def self_check_file(rel, s, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    if new:
        assert env['meta'] == NEW_META, rel
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            for name, rx in CHECKS:
                assert not rx.search(v), '%s %s — %s: %s' % (rel, path, name, v)
            assert 'DRY_RUN' not in v, (rel, path, v)
            assert not v.startswith('aaq://'), (rel, path, v)                          # 링크 = deep_link 칸만
        for d in deep_links(env['rows']):
            assert is_route(d), (rel, d)
        ks = set(keys(env['rows']))
        assert not any(PNL_KEY.search(k) for k in ks), rel
        assert not (ks & FORBIDDEN_KEYS), (rel, ks & FORBIDDEN_KEYS)
    return env


def check_engine_text():
    """엔진 글자 칸이 BASE 엔진 소스에 실제로 있는지 — 시각 꼴은 보간 원문으로."""
    s2a = git('show', '%s:%s' % (BASE, ENGINE_S2A))
    for t in ENGINE_S2A_TEXTS:
        assert t in s2a, t
    st = git('show', '%s:%s' % (BASE, ENGINE_SAFETY_TEXT))
    for t in (RECON_LABEL, RECON_TEXT, JM_LABEL, JM_TEXT):
        assert "'%s'" % t in st, t
    lv = git('show', '%s:%s' % (BASE, ENGINE_LEDGER_VIEWS))
    names = {'FILL_LAG': 'fillLag', 'MANUAL_ORDER': 'manualOrder', 'DB_ERROR': 'dbError', 'BROKER_ERROR': 'brokerError',
             'EXTERNAL_CASHFLOW': 'externalCashflow', 'CORPORATE_ACTION': 'corporateAction'}
    for code, label in ORIGIN_LABELS:
        assert "OriginCodes.%s: '%s'," % (names[code], label) in lv, code
    oc = git('show', '%s:packages/domain_contracts/lib/src/labels/origin_codes.dart' % BASE)
    for code, _ in ORIGIN_LABELS:
        assert "= '%s';" % code in oc, code
    cmd = git('show', '%s:packages/domain_contracts/lib/src/enums/command.dart' % BASE)
    for w in ('HANDOVER_SIM_LEDGER_FATE', 'HANDOVER_SESSION_START', 'HANDOVER_SESSION_CANCEL', 'HANDOVER_COMMIT',
              'RULE_CHANGE_CANCEL', 'RECON_CLEAR'):
        assert "@JsonValue('%s')" % w in cmd, w
    ds = git('show', '%s:packages/data_sync/lib/src/local/rule_change_store.dart' % BASE)
    assert "kRuleChangeRequestKind = 'RULE_CHANGE_REQUEST'" in ds          # 새 id wire == ds 요청 kind(설계서 §8-4)


def check_base_fresh():
    """rebase 뒤 밑동(merge-base HEAD origin/main)의 픽스처 트리가 BASE 와 다르면 멈춘다(gen_trackb_v125 와 같은 규칙)."""
    try:
        mb = git('merge-base', 'HEAD', 'origin/main').strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다(BASE 상수 갱신)'
                         % (mb[:8], BASE[:8]))


def check_wizard(one):
    for rel in WZ_VMS:
        v = one[rel]
        assert list(v) == WZ_KEYS, rel
        assert v['level'] in LEVELS and v['path_label'] == PATH_LABEL, rel
        rows = v['rows']
        assert len(rows) in (0, 7), rel
        assert (len(rows) == 0) == (rel == WZ % 'not_applicable'), rel
        if rows:
            assert [r['step']['step_id'] for r in rows] == [s[0] for s in STEPS], rel
        frozen = v['locked_label'] is not None or v['done_label'] is not None
        for r in rows:
            assert list(r) == ROW_KEYS and list(r['step']) == STEP_KEYS, rel
            sid = r['step']['step_id']
            assert r['level'] in STATE_LEVEL[r['step']['state']], (rel, sid)
            ids = {a['id'] for a in r['actions']}
            assert ids <= ALLOWED.get(sid, set()), (rel, sid, ids)
            if frozen:
                assert not r['actions'], (rel, sid)
            for a in r['actions']:
                if a['id'] in ('HANDOVER_SESSION_CANCEL', 'HANDOVER_COMMIT'):
                    assert a['args'] == {'handover_session_id': SESSION}, (rel, a)
                elif a['id'] == 'HANDOVER_SIM_LEDGER_FATE':
                    assert list(a['args']) == ['fate'] and a['args']['fate'] in ('KEEP', 'DISCARD'), (rel, a)
                elif a['id'] == 'HANDOVER_SESSION_START':
                    assert a['args'] == {'path': 'SIM_TO_AUTO'}, (rel, a)
            if 'HANDOVER_COMMIT' in ids:
                assert r['step']['state'] == 'PASS' and v['reason_code'] is None, rel
            link = r['link']
            if link is not None:
                want = {'SIM_TO_AUTO_S2': 'aaq://settings/diagnostics', 'SIM_TO_AUTO_S3': 'aaq://settings/credentials',
                        'SIM_TO_AUTO_S4': 'aaq://settings/accounts'}
                assert link['deep_link'] == want.get(sid), (rel, sid, link)
    assert one[WZ % 'committed']['done_label'] is not None and one[WZ % 'locked']['locked_label'] == LOCKED
    assert one[WZ % 'commit_ready']['window_text'] == WINDOW_OK
    assert one[WZ % 'window_blocked']['headline'] == WINDOW_NO == one[WZ % 'window_blocked']['window_text']
    assert one[WZ % 'trial_incomplete']['trial'] is not None


def check_gate(one):
    for rel in RG_VMS:
        v = one[rel]
        assert list(v) == RG_KEYS and v['level'] in LEVELS, rel
        for c in v['candidates']:
            assert list(c) == CAND_KEYS, rel
        for r in v['rows']:
            assert list(r) == QROW_KEYS and r['level'] in LEVELS, rel
            if r['cancel'] is not None:
                assert r['cancel']['id'] == 'RULE_CHANGE_CANCEL' and r['cancel']['args'] == {'request_id': r['request_id']}
        if v['locked_label'] is not None:
            assert not v['candidates'] and all(r['cancel'] is None and r['approve_label'] is None for r in v['rows'])
    assert len(one[RG % 'first_candidate']['candidates']) == 1 and not one[RG % 'first_candidate']['rows']
    assert one[RG % 'cooling']['rows'][0]['approve_label'] is None
    assert one[RG % 'approvable']['rows'][0]['approve_label'] is not None
    e = one[RG % 'empty']
    assert not e['candidates'] and not e['rows'] and e['empty_label'] is not None


def check_board(one, envs):
    v = one[BB_RECON]
    assert list(v) == BB_KEYS, v.keys()
    for r in v['rows']:
        assert list(r) == BB_ROW_KEYS, r.keys()
        assert (r['recon_clear'] is not None) == (r['row_id'] == 'RECON_MISMATCH'), r['row_id']
    form = v['rows'][0]['recon_clear']
    assert list(form) == FORM_KEYS and form['choices'], form
    oc = git('show', '%s:packages/domain_contracts/lib/src/labels/origin_codes.dart' % BASE)
    for c in form['choices']:
        assert list(c) == ['origin_code', 'label'] and "'%s'" % c['origin_code'] in oc
    for rel in REVISED:
        for vm in envs[rel]['rows']:
            for r in vm['rows']:
                assert list(r) == BB_ROW_KEYS and r['recon_clear'] is None, rel


def check_results(envs):
    rc = git('show', '%s:packages/domain_contracts/lib/src/labels/safety_codes.dart' % BASE)
    for rel, wire, codes in ((RCQ_RESULTS, 'RULE_CHANGE_REQUEST', None),
                             (RECON_RESULTS, 'RECON_CLEAR', {'RECON_NOT_BLOCKED', 'RECON_ORIGIN_NOT_ALLOWED',
                                                             'RECON_JOURNAL_MISSING'})):
        rows = envs[rel]['rows']
        for r in rows:
            assert list(r) == RESULT_KEYS and r['id'] == wire and r['level'] in LEVELS, rel
            assert r['handoff_route'] is None and r['retryable'] is False, rel
            if r['reason_code'] is None:
                assert r['level'] == 'OK', rel
        got = [r['reason_code'] for r in rows if r['reason_code']]
        assert len(got) == len(set(got)), rel
        for c in got:
            if codes and c in codes:
                continue
            assert c in ('TRUSTED_TIME_UNKNOWN', 'JOURNAL_ID_TAKEN', 'BIOMETRIC_UNAVAILABLE') or "'%s'" % c in rc, (rel, c)
    assert sum(1 for r in envs[RCQ_RESULTS]['rows'] if r['reason_code'] is None) == 1
    assert sum(1 for r in envs[RECON_RESULTS]['rows'] if r['reason_code'] is None) == 1


def main():
    check_base_fresh()
    check_engine_text()
    load_routes()
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert all(u in rels for u in UNTOUCHED + REVISED + BOARD_NO_ROWS)
    assert all(not vm['rows'] for rel in BOARD_NO_ROWS for vm in json.loads(base_text(rel))['rows'])
    assert len(NEW_FILES) == 20 and len(set(NEW_FILES)) == 20
    assert json.loads(base_text(SRC_GATE_LOCKED))['rows'][0]['locked_label'] == LOCKED
    assert any(r['headline'] == BIO_HEAD for r in json.loads(base_text(SRC_E13))['rows'])

    out, vms = new_files()
    revised_envs = {}
    for rel in rels:
        if rel in REVISED:
            out[rel], revised_envs[rel] = revise_board(rel)
        else:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    one = {rel: envs[rel]['rows'][0] for rel in vms}
    for rel in vms:
        assert len(envs[rel]['rows']) == 1, rel
        assert envs[rel]['as_of'] == one[rel]['as_of'], rel                                   # VM as_of == 봉투
        assert one[rel] == vms[rel], rel                                                        # 직렬화 왕복
    check_wizard(one)
    check_gate(one)
    check_board(one, envs)
    check_results(envs)

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    assert n_version_only == BASE_FILES - len(REVISED), n_version_only

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_trackc_v126_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · contract 1.26.0'
          % (len(out), BASE_FILES, n_version_only, len(REVISED), len(NEW_FILES)))


if __name__ == '__main__':
    main()
