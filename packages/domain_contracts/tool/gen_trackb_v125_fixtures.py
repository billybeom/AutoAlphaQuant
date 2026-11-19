#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.25(트랙 B 선행 — 모의 체험 ④ X2 재개 · ⑤ 킬스위치 필수 화면 · 01 §34) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_trackb_v125_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r9_v124_fixtures.py(계약 v1.24 · 그 스크립트는 v1.24 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-19_트랙B선행_계약v1.25_설계서.md` §5 · 322 → 339 = 신설 17 · 개정 0 · 버전 줄만 322)
  (a) 전 봉투의 "contract_version": "1.24.0" → "1.25.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 17 — m5/ 킬스위치 화면 7(`kill_switch_off` · `_active_unrecorded` · `_cancel_read_failed` · `_recorded_waiting` ·
      `_recorded_ready` · `_locked` · `_active_locked`) · 발동 접수증 1(`kill_switch_activate_receipts`) · 재개 게이트 마감 1
      (`kill_resume_gate_off`) · 차단 보드 4(`block_board_clear` · `_kill_active` · `_resume_incomplete` · `_stopped`) ·
      x2/ 리포트 감싸개 3(`resume_report_screen_normal` · `_recovery_full` · `_empty`) · 게이트 마감 1(`resume_gate_clear`).
  (c) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `check_*` · 엔진 글자는 BASE 의 엔진 소스에 실제로 있는지 본다.

🔴 돈·수치 0 새로 정함(K159) — 48h · 7문항 · 취소 범위 = SPEC 글자 그대로 · 금액·수량·주문번호·intent id·기기 id 원문 0 ·
   종목 = «(합성) 6자리».
🔴 글자 출처(K159) — ⓐ 엔진 글자 칸 = 바이트 그대로(`killSwitchViewOf` · 플래그 사전 · `breakerLabelOf` · 사다리 · `KillAckAnswers`
   주석 · 게이지 = `safety_states` STOPPED 행 · 리포트 = `x2/resume_report_*` 원판 · 재개판 7문항 = `m5/kill_resume_gate_ready` 행) ·
   ⓑ SPEC 04 §3-6 «카드 ④(발동 뒤 기록)» 원문 7(01 §30 K38 정규화) · 03 §7-4 종이 카드 힌트 2 ⓒ 원천 0 칸 = «(합성) …».

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_trackb_v125_fixtures.py
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
# 계약 1.24.0 · 픽스처 322 의 기준 커밋(origin/main · E11p4l #254 — 계약 패키지 = PR #235 이후 무변경).
BASE = '85456ab22a308ed052c68104d43f8287f5c85c77'

OLD_VER = '"contract_version": "1.24.0"'
NEW_VER = '"contract_version": "1.25.0"'
BASE_FILES = 322
WANT_FILES = 339

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
# 화면·표본 어디에도 없어야 하는 키(C-59 ①).
FORBIDDEN_KEYS = {'intent_id', 'order_no', 'broker_order_no', 'quantity', 'remaining_qty', 'device_id', 'countdown',
                  'remaining_seconds', 'release_action', 'deactivate', 'prefill', 'example', 'journal_decision_id'}

# ── 엔진 글자(BASE 엔진 소스에 실제로 있는지 check_engine_text 가 본다) ──
ENGINE_KILL = 'packages/core_engine/lib/src/safety/kill_switch.dart'
ENGINE_CHECKLIST = 'packages/core_engine/lib/src/safety/kill_checklist.dart'
ENGINE_SAFETY_TEXT = 'packages/core_engine/lib/src/safety/safety_text.dart'
ENGINE_ACTIVATION = 'packages/core_engine/lib/src/safety/kill_activation.dart'
OFF_LABEL = '킬스위치 꺼짐'
ON_LABEL = '킬스위치 작동 중 — 신규 주문을 막고 있습니다'
CHECKLIST_FIRST = '체크리스트를 먼저 마치십시오 — 마친 때부터 48시간을 셉니다'
CHECKLIST_DONE = '체크리스트 확인 12-23 10:20'            # `'체크리스트 확인 ${_kstMdHm(confirmed)}'` 꼴
ETA_WAIT = '해제 가능 예정 12-25 10:20'                   # `'해제 가능 예정 ${_kstMdHm(eta)}'` 꼴
ETA_READY = '해제 가능 — 재개 체크리스트를 진행하십시오'
ACK_QUERIED = '미체결 주문을 조회했다'                     # `KillAckAnswers` 주석 원문
ACK_CANCELLED = '전량 취소했다'
ACK_ZERO = '잔여 0 을 확인했다'
NOTE_LABEL = '1줄'
CANCEL_WIRES = ['CANCELLED', 'FAILED', 'UNKNOWN', 'NOT_CANCELLED_UNKNOWN_INTENT', 'IN_FLIGHT']   # `KillCancelOutcome` wire
FLAG_TEXT = {   # 엔진 `kFlagDictionary`(라벨 · 해제 문장)
    'RESUME_INCOMPLETE': ('재개 점검이 끝나지 않았습니다', '재개 점검이 끝나면 자동으로 풀립니다.'),
    'JOURNAL_MISSING': ('일지가 비어 있습니다', '일지를 채우면 자동으로 풀립니다.'),
}
BREAKER_NORMAL = '정상'
BREAKER_STOPPED = '정지'

# ── SPEC 04 §3-6 «카드 ④(발동 뒤 기록)» 원문 7(K38 정규화) · 03 §7-4 종이 카드 힌트 2 ──
SPEC_ITEMS = [
    '규칙이 지시한 행동은 무엇인가',
    '지금 끄는 것이 규칙인가 감정인가(감정 · 강도 · 수면)',
    '사전에 문서화한 시나리오인가(W번호 · 트리거 ID)',
    '재개 조건을 지금 적을 수 있는가',
    '끄는 범위',
    '재개 최소 대기 시작 시각(48h)',
    '저널 작성 완료(decision_id)',
]
HINT3 = '해당 없으면, 이것은 새로운 상황이 아니라 대개 새로운 감정이다.'
HINT5 = '전량 청산은 2단계 확인 + 대기 필요. 기본은 신규 진입 차단.'

# ── 이름 ─────────────────────────────────────────────────────────────────
KS_OFF = 'm5/kill_switch_off.json'
KS_UNREC = 'm5/kill_switch_active_unrecorded.json'
KS_READFAIL = 'm5/kill_switch_cancel_read_failed.json'
KS_WAIT = 'm5/kill_switch_recorded_waiting.json'
KS_READY = 'm5/kill_switch_recorded_ready.json'
KS_LOCKED = 'm5/kill_switch_locked.json'
KS_ACT_LOCKED = 'm5/kill_switch_active_locked.json'
KS_RECEIPTS = 'm5/kill_switch_activate_receipts.json'
GATE_OFF = 'm5/kill_resume_gate_off.json'
BB_CLEAR = 'm5/block_board_clear.json'
BB_KILL = 'm5/block_board_kill_active.json'
BB_RESUME = 'm5/block_board_resume_incomplete.json'
BB_STOPPED = 'm5/block_board_stopped.json'
RR_NORMAL = 'x2/resume_report_screen_normal.json'
RR_RECOVERY = 'x2/resume_report_screen_recovery_full.json'
RR_EMPTY = 'x2/resume_report_screen_empty.json'
RG_CLEAR = 'x2/resume_gate_clear.json'
KS_VMS = [KS_OFF, KS_UNREC, KS_READFAIL, KS_WAIT, KS_READY, KS_LOCKED, KS_ACT_LOCKED]
BB_VMS = [BB_CLEAR, BB_KILL, BB_RESUME, BB_STOPPED]
RR_VMS = [RR_NORMAL, RR_RECOVERY, RR_EMPTY]
NEW_FILES = KS_VMS + [KS_RECEIPTS, GATE_OFF] + BB_VMS + RR_VMS + [RG_CLEAR]

SRC_GATE_READY = 'm5/kill_resume_gate_ready.json'
SRC_LADDER_NORMAL = 'm5/breaker_ladder_normal.json'
SRC_LADDER_STOPPED = 'm5/breaker_ladder_stopped.json'
SRC_SAFETY = 'safety_states.json'
SRC_RR_NORMAL = 'x2/resume_report_normal.json'
SRC_RR_RECOVERY = 'x2/resume_report_recovery_full.json'
SRC_RECEIPTS = 'm5/kill_checklist_receipts.json'
SRC_GATE_LOCKED = 'm5/kill_resume_gate_locked.json'
UNTOUCHED = [SRC_GATE_READY, SRC_LADDER_NORMAL, SRC_LADDER_STOPPED, SRC_SAFETY, SRC_RR_NORMAL, SRC_RR_RECOVERY,
             SRC_RECEIPTS, SRC_GATE_LOCKED]

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.25.0',
    'generated_at': '2026-11-19T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261119,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(observed, trade_date, label):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': label}


# §5 조각(체험 기간 합성 — 발동 12-23 10:02 KST · 기록 10:20 · ETA 12-25 10:20).
AS_OFF = as_of('2026-12-21T09:00:00Z', '2026-12-21', '안전 기준 2026-12-21 18:00')
AS_ON = as_of('2026-12-23T01:05:00Z', '2026-12-23', '안전 기준 2026-12-23 10:05')
AS_WAIT = as_of('2026-12-23T02:00:00Z', '2026-12-23', '안전 기준 2026-12-23 11:00')
AS_READY = as_of('2026-12-25T03:00:00Z', '2026-12-25', '안전 기준 2026-12-25 12:00')
AS_RECEIPT = as_of('2026-12-23T01:03:00Z', '2026-12-23', '명령 기준 2026-12-23 10:03')
AS_BB_KILL = as_of('2026-12-23T20:30:00Z', '2026-12-24', '안전 기준 2026-12-24 05:30')
AS_BB_RESUME = as_of('2026-12-22T00:45:00Z', '2026-12-22', '안전 기준 2026-12-22 09:45')
AS_RR_EMPTY = as_of('2026-12-21T09:00:00Z', '2026-12-21', '재개 기준 2026-12-21 18:00')

LOCKED = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'   # v1.20~v1.24 표본과 같은 글자
ACTIVATE = '(합성) 킬스위치 켜기 — 신규 주문을 바로 막습니다'
PATHS = ['(합성) 이 폰: 이 버튼 — 네트워크를 기다리지 않고 막습니다',
         '(합성) 다른 기기: 뷰어·웹의 킬스위치 — 서버 명령으로 막습니다',
         '(합성) 기기를 쓸 수 없을 때: 긴급정지 카드 절차']
ACTIVATED = '(합성) 발동 12-23 10:02 · 운영 폰'
CANCEL_HEAD = '(합성) 미체결 3건 — 취소 1 · 결과 불명 1 · 제출 중 1. 불명은 다시 부르지 않았습니다.'
CANCEL_FAIL_HEAD = '(합성) 미체결 주문을 읽지 못했습니다 — 신규 주문 차단은 그대로입니다. 증권사 앱에서 미체결을 확인하십시오.'
CANCEL_ROWS = [
    {'symbol_text': '(합성) 069500', 'outcome_code': 'CANCELLED', 'outcome_label': '(합성) 취소 접수', 'level': 'OK'},
    {'symbol_text': '(합성) 360750', 'outcome_code': 'NOT_CANCELLED_UNKNOWN_INTENT',
     'outcome_label': '(합성) 주문 결과 불명 — 취소하지 않고 보고만 했습니다', 'level': 'WATCH'},
    {'symbol_text': '(합성) 132030', 'outcome_code': 'IN_FLIGHT',
     'outcome_label': '(합성) 제출 중이던 주문 — 결과를 기다립니다', 'level': 'WATCH'},
]
GATE_LINK = {'label': '(합성) 재개 게이트 보기', 'deep_link': 'aaq://m5/release-gate'}
NOTICE = '(합성) 이 기록은 주문을 내지 않습니다. 전량 청산을 골라도 앱은 팔지 않습니다 — 청산은 사람이 2단계로 확인합니다.'
FIXED6 = '(합성) 이 기록을 마친 시각이 시작 시각입니다 — 앱이 적습니다'
FIXED7 = '(합성) 기록을 마치면 저널이 함께 만들어집니다'
KILL_LINK = {'label': '(합성) 킬스위치', 'deep_link': 'aaq://m5/kill-switch'}
KILL_ROW_LINK = {'label': '(합성) 킬스위치 보기', 'deep_link': 'aaq://m5/kill-switch'}
STOPPED_LINK = {'label': '(합성) 재개 결정하기', 'deep_link': 'aaq://m5/stopped-decision'}
AUTO_KIND = '(합성) 자동으로 풀립니다'

KS_KEYS = ['state_label', 'level', 'activated_text', 'activate_label', 'path_lines', 'cancel_headline', 'cancel_rows',
           'checklist_state_label', 'form', 'eta_text', 'gate_link', 'locked_label', 'as_of']
FORM_KEYS = ['items', 'ack_queried_label', 'ack_cancelled_label', 'ack_remaining_zero_label', 'note_label',
             'notice_text']
ITEM_KEYS = ['item_no', 'label', 'hint_text', 'fixed_text', 'choices']
CHOICE_KEYS = ['label', 'reason_kind', 'scope']
CANCEL_KEYS = ['symbol_text', 'outcome_code', 'outcome_label', 'level']
BB_KEYS = ['headline', 'level', 'breaker_label', 'rows', 'gauges', 'ladder', 'stopped_decision_link', 'kill_switch_link',
           'empty_label', 'as_of']
BB_ROW_KEYS = ['row_id', 'label', 'set_at_text', 'clear_kind_label', 'clear_instruction', 'level', 'link']
RR_KEYS = ['report', 'period_text', 'phase_label', 'empty_label', 'as_of']


def choice(label, reason=None, scope=None):
    return {'label': label, 'reason_kind': reason, 'scope': scope}


def form():
    items = []
    for n, label in enumerate(SPEC_ITEMS, 1):
        items.append({
            'item_no': n,
            'label': label,
            'hint_text': {3: HINT3, 5: HINT5}.get(n),
            'fixed_text': {6: FIXED6, 7: FIXED7}.get(n),
            'choices': {2: [choice('규칙', reason='RULE'), choice('감정', reason='EMOTION')],
                        5: [choice('신규 진입 차단만', scope='NEW_ENTRIES_ONLY'),
                            choice('전량 청산', scope='LIQUIDATE_ALL')]}.get(n, []),
        })
    return {'items': items, 'ack_queried_label': ACK_QUERIED, 'ack_cancelled_label': ACK_CANCELLED,
            'ack_remaining_zero_label': ACK_ZERO, 'note_label': NOTE_LABEL, 'notice_text': NOTICE}


def ks_vm(state, level, activated, activate, paths, head, rows, checklist, frm, eta, gate, locked, asof):
    return dict(zip(KS_KEYS, [state, level, activated, activate, copy.deepcopy(paths), head, copy.deepcopy(rows),
                              checklist, copy.deepcopy(frm), eta, copy.deepcopy(gate), locked, copy.deepcopy(asof)]))


def build_kill_switch():
    off = ks_vm(OFF_LABEL, 'OK', None, ACTIVATE, PATHS, None, [], None, None, None, None, None, AS_OFF)
    unrec = ks_vm(ON_LABEL, 'ACT', ACTIVATED, None, [], CANCEL_HEAD, CANCEL_ROWS, CHECKLIST_FIRST, form(), None, None,
                  None, AS_ON)
    readfail = ks_vm(ON_LABEL, 'ACT', ACTIVATED, None, [], CANCEL_FAIL_HEAD, [], CHECKLIST_FIRST, form(), None, None,
                     None, AS_ON)
    wait = ks_vm(ON_LABEL, 'WATCH', ACTIVATED, None, [], CANCEL_HEAD, CANCEL_ROWS, CHECKLIST_DONE, None, ETA_WAIT,
                 GATE_LINK, None, AS_WAIT)
    ready = ks_vm(ON_LABEL, 'INFO', ACTIVATED, None, [], CANCEL_HEAD, CANCEL_ROWS, CHECKLIST_DONE, None, ETA_READY,
                  GATE_LINK, None, AS_READY)
    locked = dict(off, locked_label=LOCKED)
    act_locked = dict(unrec, form=None, locked_label=LOCKED)
    return {KS_OFF: off, KS_UNREC: unrec, KS_READFAIL: readfail, KS_WAIT: wait, KS_READY: ready, KS_LOCKED: locked,
            KS_ACT_LOCKED: act_locked}


def build_receipts():
    base = json.loads(base_text(SRC_RECEIPTS))['rows'][0]
    keys = list(base)
    assert keys == ['command_id', 'kind', 'state', 'state_label', 'requested_at', 'expires_at', 'nonce',
                    'issued_by_device_id'], keys
    phone = dict(zip(keys, ['cmd_ks_01', 'KILL_SWITCH_ACTIVATE', 'EXECUTED', '(합성) 켜짐 — 신규 주문을 막았습니다',
                            '2026-12-23T01:02:00Z', '2026-12-23T01:32:00Z', 'n_ks5d0e2a7b01', 'dev_operator_01']))
    viewer = dict(zip(keys, ['cmd_ks_02', 'KILL_SWITCH_ACTIVATE', 'REQUESTED',
                             '(합성) 요청됨 — 운영 폰이 받으면 막습니다', '2026-12-23T01:02:00Z',
                             '2026-12-23T01:32:00Z', 'n_ks5d0e2a7b02', 'dev_viewer_01']))
    return [phone, viewer]


def build_gate_off():
    g = copy.deepcopy(json.loads(base_text(SRC_GATE_READY))['rows'][0])
    g['readiness_label'] = OFF_LABEL
    g['level'] = 'OK'
    g['eta_text'] = None
    g['cooldown'] = None
    for it in g['items']:
        it['replay_text'] = None
        it['answered_text'] = None
        it['level'] = 'INFO'
    g['next_item_no'] = None
    g['blocked_text'] = None
    g['locked_label'] = None
    g['as_of'] = copy.deepcopy(AS_READY)
    return g


def ladder_of(rel, asof):
    v = copy.deepcopy(json.loads(base_text(rel))['rows'][0])
    assert list(v) == ['rows', 'as_of'], rel
    v['as_of'] = copy.deepcopy(asof)
    return v


def bb_row(row_id, label, set_at, kind, instruction, level, link):
    return dict(zip(BB_ROW_KEYS, [row_id, label, set_at, kind, instruction, level, copy.deepcopy(link)]))


def bb_vm(head, level, breaker, rows, gauges, ladder, stopped, empty, asof):
    return dict(zip(BB_KEYS, [head, level, breaker, rows, copy.deepcopy(gauges), ladder, copy.deepcopy(stopped),
                              copy.deepcopy(KILL_LINK), empty, copy.deepcopy(asof)]))


def stopped_gauges():
    rows = json.loads(base_text(SRC_SAFETY))['rows']
    st = [r for r in rows if r['breaker_level'] == 'STOPPED']
    assert len(st) == 1
    return copy.deepcopy(st[0]['release_progress'])


def build_board():
    as_stopped = json.loads(base_text(SRC_LADDER_STOPPED))['as_of']
    clear = bb_vm('(합성) 막힌 것 없음 — 규칙대로 돌고 있습니다', 'OK', BREAKER_NORMAL, [], [],
                  ladder_of(SRC_LADDER_NORMAL, AS_OFF), None, '(합성) 지금 막힌 것이 없습니다', AS_OFF)
    kill = bb_vm('(합성) 막힌 것 1 — 킬스위치', 'BLOCKED', BREAKER_NORMAL,
                 [bb_row('KILL_SWITCH', ON_LABEL, '(합성) 12-23 10:02부터', '(합성) 재개 게이트로만 풀립니다', ETA_WAIT,
                         'BLOCKED', KILL_ROW_LINK)],
                 [{'code': 'COOLDOWN', 'label': '냉각 기간', 'normalized': 0.4, 'value_text': '(합성) 남은 29시간'}],
                 ladder_of(SRC_LADDER_NORMAL, AS_BB_KILL), None, None, AS_BB_KILL)
    ri_label, ri_text = FLAG_TEXT['RESUME_INCOMPLETE']
    jm_label, jm_text = FLAG_TEXT['JOURNAL_MISSING']
    resume = bb_vm('(합성) 막힌 것 2 — 재개 점검 · 일지', 'BLOCKED', BREAKER_NORMAL,
                   [bb_row('RESUME_INCOMPLETE', ri_label, '(합성) 12-22 09:12부터', AUTO_KIND, ri_text, 'BLOCKED',
                           {'label': '(합성) 재개 화면 보기', 'deep_link': 'aaq://x2/resume-gate'}),
                    bb_row('JOURNAL_MISSING', jm_label, '(합성) 12-22 06:30부터', AUTO_KIND, jm_text, 'ACT',
                           {'label': '(합성) 일지 쓰기', 'deep_link': 'aaq://journal/draft/dj_x2_01'})],
                   [], ladder_of(SRC_LADDER_NORMAL, AS_BB_RESUME), None, None, AS_BB_RESUME)
    stopped = bb_vm('(합성) 서킷브레이커 정지 단계 — 신규 주문을 전면 중단했습니다', 'BLOCKED', BREAKER_STOPPED, [],
                    stopped_gauges(), ladder_of(SRC_LADDER_STOPPED, as_stopped), STOPPED_LINK, None, as_stopped)
    return {BB_CLEAR: clear, BB_KILL: kill, BB_RESUME: resume, BB_STOPPED: stopped}


def build_report():
    out = {}
    for rel, src in ((RR_NORMAL, SRC_RR_NORMAL), (RR_RECOVERY, SRC_RR_RECOVERY)):
        env = json.loads(base_text(src))
        rep = copy.deepcopy(env['rows'][0])
        assert rep['started_at'] == '2026-12-22T00:12:00Z' and rep['finished_at'] == '2026-12-22T00:41:00Z', src
        out[rel] = dict(zip(RR_KEYS, [rep, '(합성) 12-22 09:12 ~ 09:41', '(합성) 재개 마침', None,
                                      copy.deepcopy(env['as_of'])]))
    out[RR_EMPTY] = dict(zip(RR_KEYS, [None, None, None,
                                       '(합성) 아직 재개한 적이 없습니다 — 엔진이 거래일을 건너뛰고 다시 켜지면 여기에 결과가 남습니다',
                                       copy.deepcopy(AS_RR_EMPTY)]))
    return out


def build_gate_clear():
    env = json.loads(base_text(SRC_RR_NORMAL))
    return {'headline': '(합성) 재개 점검을 마쳤습니다 — 막힌 계획이 없습니다',
            'mode_label': env['rows'][0]['mode_label'], 'level': 'OK', 'rows': [],
            'report_link': {'label': '(합성) 재개 리포트 보기', 'deep_link': 'aaq://x2/resume-report'},
            'locked_label': None, 'as_of': copy.deepcopy(env['as_of'])}


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_r9_v124_fixtures.py 와 같은 꼴)
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
    """봉투(v1.15~v1.24 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def new_files():
    texts = {}
    vms = {}
    vms.update(build_kill_switch())
    vms[GATE_OFF] = build_gate_off()
    vms.update(build_board())
    vms.update(build_report())
    vms[RG_CLEAR] = build_gate_clear()
    for rel, row in vms.items():
        texts[rel] = ser_envelope(envelope([row], row['as_of']), True)
    texts[KS_RECEIPTS] = ser_envelope(envelope(build_receipts(), AS_RECEIPT), True)
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
        # `report` = 엔진 원판 바이트 복사(check_report 가 원판과 같음을 본다) — 낱말 검사 밖(원판 공백 라벨 «평가액 스냅샷»).
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}, skip=('meta', 'deep_link', 'report')):
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
    """엔진 글자 칸이 BASE 엔진 소스에 실제로 있는지(K159 ⓐ) — 시각 꼴은 앞부분만."""
    kill = git('show', '%s:%s' % (BASE, ENGINE_KILL))
    for t in (OFF_LABEL, ON_LABEL, CHECKLIST_FIRST, ETA_READY, '체크리스트 확인 ${', '해제 가능 예정 ${'):
        assert t in kill, t
    ck = git('show', '%s:%s' % (BASE, ENGINE_CHECKLIST))
    for t in (ACK_QUERIED, ACK_CANCELLED, ACK_ZERO, '/// ' + NOTE_LABEL + '.'):
        assert t in ck, t
    act = git('show', '%s:%s' % (BASE, ENGINE_ACTIVATION))
    for w in CANCEL_WIRES:
        assert "('%s')" % w in act, w
    st = git('show', '%s:%s' % (BASE, ENGINE_SAFETY_TEXT))
    for label, text in FLAG_TEXT.values():
        assert "'%s'" % label in st and "'%s'" % text in st, label
    assert "BreakerLevel.normal => '정상'" in st and "BreakerLevel.stopped => '정지'" in st
    labels = git('show', '%s:packages/domain_contracts/lib/src/enums/safety.dart' % BASE)
    for w in ('RULE', 'EMOTION', 'NEW_ENTRIES_ONLY', 'LIQUIDATE_ALL'):
        assert "@JsonValue('%s')" % w in labels, w


def check_base_fresh():
    """rebase 뒤 밑동(merge-base HEAD origin/main)의 픽스처 트리가 BASE 와 다르면 멈춘다(gen_r9_v124 와 같은 규칙)."""
    try:
        mb = git('merge-base', 'HEAD', 'origin/main').strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다(BASE 상수 갱신)'
                         % (mb[:8], BASE[:8]))


def check_kill_switch(one):
    for rel in KS_VMS:
        r = one[rel]
        assert list(r) == KS_KEYS, rel
        off = r['state_label'] == OFF_LABEL
        assert r['state_label'] in (OFF_LABEL, ON_LABEL), rel                                   # C-59 ③
        assert (r['activate_label'] is not None) == off, rel                                    # C-59 ②
        if off:
            assert all(r[k] is None for k in ('activated_text', 'cancel_headline', 'checklist_state_label', 'form',
                                              'eta_text', 'gate_link')), rel
            assert r['cancel_rows'] == [], rel
        else:
            assert r['activated_text'] is not None and r['path_lines'] == [], rel
        if r['form'] is not None:                                                               # C-59 ④
            assert not off and r['checklist_state_label'] == CHECKLIST_FIRST and r['locked_label'] is None, rel
            assert r['gate_link'] is None and r['eta_text'] is None, rel
        if r['gate_link'] is not None:
            assert r['gate_link']['deep_link'] == 'aaq://m5/release-gate' and r['form'] is None, rel
            assert r['checklist_state_label'] == CHECKLIST_DONE, rel
        for c in r['cancel_rows']:
            assert list(c) == CANCEL_KEYS and c['outcome_code'] in CANCEL_WIRES and c['level'] in LEVELS, rel
            assert re.fullmatch(r'\(합성\) [0-9]{6}', c['symbol_text']), rel
    # 폼(C-59 ⑤).
    f = one[KS_UNREC]['form']
    assert list(f) == FORM_KEYS
    assert [i['label'] for i in f['items']] == SPEC_ITEMS
    for it in f['items']:
        n = it['item_no']
        assert list(it) == ITEM_KEYS
        assert (it['choices'] != []) == (n in (2, 5)), n
        assert (it['fixed_text'] is not None) == (n in (6, 7)), n
        assert (it['hint_text'] is not None) == (n in (3, 5)), n
        for c in it['choices']:
            assert list(c) == CHOICE_KEYS and ((c['reason_kind'] is None) != (c['scope'] is None)), c
        assert '끄지 않는다' not in (it['hint_text'] or ''), n
    assert one[KS_READFAIL]['form'] == f
    # 잠김 비대칭(C-59 ⑥).
    assert dict(one[KS_LOCKED], locked_label=None) == one[KS_OFF]
    assert one[KS_LOCKED]['activate_label'] == ACTIVATE
    assert dict(one[KS_ACT_LOCKED], locked_label=None, form=f) == one[KS_UNREC]
    assert [rel for rel in KS_VMS if one[rel]['locked_label'] is not None] == [KS_LOCKED, KS_ACT_LOCKED]
    # 후보 읽기 실패 = 행 0 ∧ 머리.
    assert one[KS_READFAIL]['cancel_rows'] == [] and one[KS_READFAIL]['cancel_headline'] == CANCEL_FAIL_HEAD


def check_board(one, envs):
    for rel in BB_VMS:
        r = one[rel]
        assert list(r) == BB_KEYS, rel
        assert r['kill_switch_link'] == KILL_LINK, rel                                         # C-59 ⑩
        if r['empty_label'] is not None:
            assert r['rows'] == [], rel
        cur = [x for x in r['ladder']['rows'] if x['current']]
        assert len(cur) == 1 and cur[0]['label'] == r['breaker_label'], rel                    # C-59 ⑪
        for row in r['rows']:
            assert list(row) == BB_ROW_KEYS, rel
            if row['row_id'] in FLAG_TEXT:
                assert (row['label'], row['clear_instruction']) == FLAG_TEXT[row['row_id']], rel
        for g in r['gauges']:
            assert g['code'] in ('DD_RECOVERY', 'HOLD', 'BULL_STREAK', 'COOLDOWN'), rel
        if r['stopped_decision_link'] is not None:
            assert r['stopped_decision_link']['deep_link'] == 'aaq://m5/stopped-decision'
            assert r['breaker_label'] == BREAKER_STOPPED
    assert one[BB_CLEAR]['ladder']['rows'] == json.loads(base_text(SRC_LADDER_NORMAL))['rows'][0]['rows']
    assert one[BB_STOPPED]['ladder']['rows'] == json.loads(base_text(SRC_LADDER_STOPPED))['rows'][0]['rows']


def check_report(one):
    for rel in RR_VMS:
        r = one[rel]
        assert list(r) == RR_KEYS, rel
        assert (r['report'] is None) == (r['empty_label'] is not None), rel                   # C-59 ⑭
        if r['report'] is not None:
            assert r['period_text'] is not None and r['phase_label'] is not None, rel
    assert one[RR_NORMAL]['report'] == json.loads(base_text(SRC_RR_NORMAL))['rows'][0]
    assert one[RR_RECOVERY]['report'] == json.loads(base_text(SRC_RR_RECOVERY))['rows'][0]
    g = one[RG_CLEAR]
    assert g['rows'] == [] and g['level'] == 'OK' and g['report_link']['deep_link'] == 'aaq://x2/resume-report'


def check_gate_off(one):
    g = one[GATE_OFF]
    ready = json.loads(base_text(SRC_GATE_READY))['rows'][0]
    assert list(g) == list(ready)
    assert [i['label'] for i in g['items']] == [i['label'] for i in ready['items']]
    assert [i['choices'] for i in g['items']] == [i['choices'] for i in ready['items']]
    assert all(i['replay_text'] is None and i['answered_text'] is None for i in g['items'])
    assert g['readiness_label'] == OFF_LABEL and g['next_item_no'] is None and g['blocked_text'] is None


def main():
    check_base_fresh()
    check_engine_text()
    load_routes()
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert all(u in rels for u in UNTOUCHED)
    assert len(NEW_FILES) == 17 and len(set(NEW_FILES)) == 17
    assert json.loads(base_text(SRC_GATE_LOCKED))['rows'][0]['locked_label'] == LOCKED

    out, vms = new_files()
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    one = {rel: envs[rel]['rows'][0] for rel in vms}
    for rel in vms:
        assert len(envs[rel]['rows']) == 1, rel
        assert envs[rel]['as_of'] == one[rel]['as_of'], rel                                   # VM as_of == 봉투
        assert one[rel] == vms[rel], rel                                                        # 직렬화 왕복
    check_kill_switch(one)
    check_board(one, envs)
    check_report(one)
    check_gate_off(one)
    rec = envs[KS_RECEIPTS]['rows']
    assert len(rec) == 2 and all(r['kind'] == 'KILL_SWITCH_ACTIVATE' and 'reject_reason_code' not in r for r in rec)
    assert {r['state'] for r in rec} == {'EXECUTED', 'REQUESTED'}

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
    print('gen_trackb_v125_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.25.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
