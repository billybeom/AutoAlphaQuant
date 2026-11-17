#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.24(R9 선행 — M9 `S09` 백업·복원 · `S10` 진단 · `S12` 연간 리뷰 목차 · 01 §33) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r9_v124_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r8_v123_fixtures.py(계약 v1.23 · 그 스크립트는 v1.23 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-18_R9선행_계약v1.24_설계서.md` §5 · 305 → 322 = 신설 17 · 개정 0 · 버전 줄만 305)
  (a) 전 봉투의 "contract_version": "1.23.0" → "1.24.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 17 — m9/ `backup` · `_age_warn` · `_empty` · `_sim` · `_locked` · `_stale`(VM 6) · `backup_action_results`(결과 10행) ·
      `diagnostics_screen` · `_diff` · `_running` · `_locked` · `_stale`(VM 5) · `selftest_action_results`(결과 12행) ·
      `annual_review_index_open` · `_closed` · `_first_year` · `_stale`(VM 4).
  (c) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `check_*`.

🔴 돈·수치 0 새로 정함(K136) — 금액 글자 0 · 백업 나이 임계(엔진 `kBackupStaleAfter`)는 배지 문장에 숫자로 싣지 않는다 ·
   골든 총계(345/109)·196 = 0 · 경로·파일 이름·크기·시크릿 0 · 해시 = 합성 16진 8(영문 섞음).
🔴 글자 출처(K136) — ⓐ 엔진 글자 칸 = 바이트 그대로: `board` = `m8/recon_board_ok`·`_diff` `rows[0]`(m8 무수정) ·
   «골든벡터 판정 보류»(core `ops/settings_home.dart:125`) · «마지막 검증 MM-DD HH:mm» 꼴(core `safety/safety_text.dart:128`) ·
   S12 창 상태 글자 = `m7/m7_annual_*` 글자 · `LOCKED` = v1.20~v1.23 같은 글자 ⓑ VM 원천 0 칸 = 05 꼴 평문 ⓒ 결과 headline =
   «(합성) …» · 생체 = v1.20 꼴 ⓓ 결과 `level` = 합성.

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r9_v124_fixtures.py
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
# 계약 1.23.0 · 픽스처 305 의 기준 커밋(origin/main · R8a 조립 기록 — 계약 패키지 = PR #227 이후 무변경).
BASE = '01b0695cf3cce3bf561dc3f58a7763910a5b3266'

OLD_VER = '"contract_version": "1.23.0"'
NEW_VER = '"contract_version": "1.24.0"'
BASE_FILES = 305
WANT_FILES = 322

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
PNL_WORD = re.compile(r'평가손익|수익률|평가액|손익|세후')
MONEY = re.compile(r'[0-9][0-9,]*(?:억|만)?[0-9,]*원')    # C-57 ⑦ 와 같은 꼴
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PHONE = re.compile(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}')    # C-51 ⑤
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
URL_LIKE = re.compile(r'https?://|github\.com|\.io/')
LONG_DIGITS = re.compile(r'[0-9]{8,}')                     # 8자리 이상 숫자 0
LONG_HEX = re.compile(r'[0-9a-fA-F]{9,}')                  # C-58 ⑩ 16진 9자 이상 연속 0
PATH_LIKE = re.compile(r'[/\\]|\.sqlite|\.json|manifest|sha256')   # C-58 ⑩ 경로·파일 이름
SIZE_UNIT = re.compile(r'KB|MB|GB|바이트')                 # C-58 ⑩ 크기 단위
TOTALS = re.compile(r'345|109|196|%|[0-9]+\s*/\s*[0-9]+')   # C-58 ⑩ 총계·비율
DIGIT_THEN_UNIT = re.compile(r'[0-9](?:원|만)')            # K136 — 숫자 바로 뒤 «원»·«만» 0(띄어 쓴 «만듦» 은 허용)
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}

# ── 사전(labels/settings_codes.dart 와 같은 글자 — C-58 ⑤⑥⑦ 이 다시 본다) ──
BACKUP_CODES = ['X1_LIVE_ONLY', 'SNAPSHOT_NO_STAMP', 'SNAPSHOT_EXISTS', 'RESTORE_UNREADABLE', 'RESTORE_SCHEMA_SKEW',
                'RESTORE_SQLITE_INTEGRITY', 'RESTORE_CHAIN_INVALID', 'RESTORE_ROLLBACK']
INTEGRITY_CODES = ['FORMAT_VERSION', 'DATE_GAP', 'CHAIN_BROKEN', 'DAY_HASH_MISMATCH', 'ROWS_BEFORE_FIRST_STAMP',
                   'ATTRIBUTION', 'SQLITE_INTEGRITY']
BIOMETRIC = 'BIOMETRIC_UNAVAILABLE'
ID_BACKUP = 'BACKUP_RUN_NOW'
ID_GOLDEN = 'SELFTEST_GOLDEN_RUN'
ID_INTEGRITY = 'SELFTEST_INTEGRITY_RUN'
NOT_CALLED = ['BACKUP_RESTORE_START', 'CALENDAR_SYNC_NOW', 'CALENDAR_REBACKFILL', 'CALENDAR_RECONNECT',
              'SETTINGS_GENERAL_UPDATE']   # C-58 ⑭

# ── 이름 ─────────────────────────────────────────────────────────────────
BK = 'm9/backup.json'
BK_AGE = 'm9/backup_age_warn.json'
BK_EMPTY = 'm9/backup_empty.json'
BK_SIM = 'm9/backup_sim.json'
BK_LOCKED = 'm9/backup_locked.json'
BK_STALE = 'm9/backup_stale.json'
BK_RESULTS = 'm9/backup_action_results.json'
DG = 'm9/diagnostics_screen.json'
DG_DIFF = 'm9/diagnostics_screen_diff.json'
DG_RUNNING = 'm9/diagnostics_screen_running.json'
DG_LOCKED = 'm9/diagnostics_screen_locked.json'
DG_STALE = 'm9/diagnostics_screen_stale.json'
ST_RESULTS = 'm9/selftest_action_results.json'
AR_OPEN = 'm9/annual_review_index_open.json'
AR_CLOSED = 'm9/annual_review_index_closed.json'
AR_FIRST = 'm9/annual_review_index_first_year.json'
AR_STALE = 'm9/annual_review_index_stale.json'
BK_VMS = [BK, BK_AGE, BK_EMPTY, BK_SIM, BK_LOCKED, BK_STALE]
DG_VMS = [DG, DG_DIFF, DG_RUNNING, DG_LOCKED, DG_STALE]
AR_VMS = [AR_OPEN, AR_CLOSED, AR_FIRST, AR_STALE]
NEW_FILES = BK_VMS + [BK_RESULTS] + DG_VMS + [ST_RESULTS] + AR_VMS
BOARD_OK = 'm8/recon_board_ok.json'
BOARD_DIFF = 'm8/recon_board_diff.json'
ANNUAL = {'open': 'm7/m7_annual_2026.json', 'closed': 'm7/m7_annual_offwindow.json',
          'first': 'm7/m7_annual_first_year.json'}
UNTOUCHED = [BOARD_OK, BOARD_DIFF] + list(ANNUAL.values()) + ['m9/settings_home.json']

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.24.0',
    'generated_at': '2026-11-18T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261118,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(label, stale_label=None):
    out = {'observed_at': '2026-11-18T06:00:00Z', 'trade_date': '2026-11-18', 'source': 'LOCAL_SQLITE',
           'stale_after_seconds': 93600, 'label': label}
    if stale_label is not None:
        out['stale_label'] = stale_label
    return out


# §5-1 조각.
STALE_TAIL = ' 다시 읽지 못한 지 오래됐습니다. 화면을 다시 열면 새로 읽습니다.'
AS_S09 = as_of('백업 기준 2026-11-18')
AS_S10 = as_of('진단 기준 2026-11-18')
AS_S12 = as_of('연간 점검 기준 2026-11-18')
AS_RESULT = as_of('동작 기준 2026-11-18')   # 결과 봉투(v1.20 «동작 기준» 꼴)
STALE_S09 = as_of(AS_S09['label'], '백업 정보를' + STALE_TAIL)
STALE_S10 = as_of(AS_S10['label'], '진단 정보를' + STALE_TAIL)
STALE_S12 = as_of(AS_S12['label'], '연간 리뷰 목차를' + STALE_TAIL)
LOCKED = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'   # v1.20~v1.23 표본과 같은 글자
RUN_BACKUP = {'id': ID_BACKUP, 'args': {}, 'label': '지금 백업'}
RUN_GOLDEN = {'id': ID_GOLDEN, 'args': {}, 'label': '골든벡터 실행'}
RUN_INTEGRITY = {'id': ID_INTEGRITY, 'args': {}, 'label': '무결성 자가진단 실행'}
LINK_X1 = {'label': '폰을 바꾸시나요? 기기 이전 안내 보기', 'deep_link': 'aaq://x1/migration'}
LINK_DIFFS = {'label': '차이 상세 보기', 'deep_link': 'aaq://ledger/diffs'}
LINK_PLEDGE = {'label': '본인 서약문 편집하기', 'deep_link': 'aaq://m5/pledge'}
NOTICE_LOCAL = '백업은 이 폰 안에만 있습니다. 폰을 잃어버리면 사본도 함께 잃습니다.'
NOTICE_SIM = '모의투자 원장은 백업하지 않습니다. 실전으로 전환한 뒤 실전 원장에서 만듭니다.'
P1 = {'code': 'rp_s09_01', 'label': '11-17 21:40 만듦 · 11-17 장부까지', 'chain_hash_text': '5e0c9a4f',
      'state_label': '복원 검증 통과'}
P2 = {'code': 'rp_s09_02', 'label': '11-10 20:05 만듦 · 11-10 장부까지', 'chain_hash_text': 'b71d03e8',
      'state_label': None}
EMPTY_POINTS = '아직 만든 복원 지점이 없습니다.'
AGE_BADGE = '마지막 백업이 오래됐습니다. 지금 백업을 눌러 주세요.'   # 🔴 숫자 0(임계 = 엔진 · K136)
G_PENDING_STATUS = '골든벡터 판정 보류'   # core `ops/settings_home.dart:125` 칩 글자의 꼬리(부분 문자열 그대로)
G_TITLE = '골든벡터 셀프테스트'
I_TITLE = '무결성 자가진단'
I_STATUS = '마지막 검증 11-18 03:10'   # core `safety/safety_text.dart:128` `checkpointLabelOf` 꼴
RECOMMEND = '앱 업데이트 후 · 기기 이전 후 · 실전 전환 직전에 한 번씩 확인해 주세요.'


def card(title, status, level, last_run, summary, run):
    return {'title': title, 'status_label': status, 'level': level, 'last_run_text': last_run,
            'summary_text': summary, 'run_action': copy.deepcopy(run)}


G_PENDING = card(G_TITLE, G_PENDING_STATUS, 'WATCH', None, '실행기를 준비하는 중이라 아직 돌릴 수 없습니다.', None)
G_PASS = card(G_TITLE, '통과', 'OK', '마지막 실행 11-17 09:00', '전량 통과', RUN_GOLDEN)
G_RUNNING = card(G_TITLE, '실행 중', 'INFO', '마지막 실행 11-17 09:00', None, None)
I_OK = card(I_TITLE, I_STATUS, 'OK', None, None, RUN_INTEGRITY)
ENTRIES4 = [
    {'label': '한 해의 결과 — 연간 리뷰', 'deep_link': 'aaq://report/annual'},
    {'label': '이행 갭', 'deep_link': 'aaq://ledger/execution-gap'},
    {'label': '리밸런싱 회차', 'deep_link': 'aaq://rebalance/history'},
    {'label': '하락 구간 맥락', 'deep_link': 'aaq://performance/drawdown'},
]
W_OPEN = '연간 점검 창이 열려 있습니다'                       # m7/m7_annual_2026
W_CLOSED = '연간 점검 창이 닫혀 있습니다. 자료는 읽기만 됩니다.'   # m7/m7_annual_offwindow
W_FIRST = '첫 해라 비교 대상이 없습니다'                       # m7/m7_annual_first_year
ROUTES = {'aaq://x1/migration', 'aaq://ledger/diffs', 'aaq://m5/pledge', 'aaq://report/annual',
          'aaq://ledger/execution-gap', 'aaq://rebalance/history', 'aaq://performance/drawdown'}

BK_KEYS = ['last_backup_text', 'age_badge_text', 'level', 'notice_text', 'run_action', 'locked_label', 'points',
           'points_empty_label', 'migration_link', 'as_of']
DG_KEYS = ['golden', 'integrity', 'board', 'diffs_link', 'recommend_text', 'locked_label', 'as_of']
AR_KEYS = ['year_label', 'window_state_label', 'entries', 'pledge_link', 'as_of']
RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']

# §5-2 결과 표 — 차례 = 구현 생체 → `take` 차례 · 레벨 = 합성 5값 전수(K136 ⓓ).
BACKUP_PLAN = [
    ('OK', None, '(합성) 이 폰 안에 복원 지점을 하나 만들었습니다.'),
    ('BLOCKED', BIOMETRIC, '생체 확인이 없어 백업하지 않았습니다.'),
    ('INFO', 'X1_LIVE_ONLY', '(합성) 모의투자 원장은 백업하지 않습니다. 실전 원장에서만 만듭니다.'),
    ('INFO', 'SNAPSHOT_NO_STAMP', '(합성) 아직 마감된 장부가 없어 백업할 것이 없습니다.'),
    ('INFO', 'SNAPSHOT_EXISTS', '(합성) 같은 시각의 복원 지점이 이미 있습니다. 잠시 뒤 다시 눌러 주세요.'),
    ('ACT', 'RESTORE_UNREADABLE', '(합성) 만든 사본을 다시 읽지 못해 지웠습니다. 저장 공간을 확인해 주세요.'),
    ('ACT', 'RESTORE_SCHEMA_SKEW', '(합성) 장부 형식이 앱과 달라 백업을 멈췄습니다. 앱을 업데이트해 주세요.'),
    ('BLOCKED', 'RESTORE_SQLITE_INTEGRITY', '(합성) 장부 파일 점검에서 오류가 나와 백업을 멈췄습니다.'),
    ('BLOCKED', 'RESTORE_CHAIN_INVALID', '(합성) 장부 사슬이 맞지 않아 백업을 멈췄습니다. 진단 화면에서 무결성을 확인해 주세요.'),
    ('WATCH', 'RESTORE_ROLLBACK', '(합성) 바깥 아카이브와 아직 맞춰지지 않아 백업을 미뤘습니다. 그날 아카이브가 끝난 뒤 다시 눌러 주세요.'),
]
INTEGRITY_HEAD = '(합성) 정본 자가 대조가 어긋나 신규 주문을 막았습니다 — '
INTEGRITY_TAIL = {
    'FORMAT_VERSION': '해시 형식 판이 다릅니다.',
    'DATE_GAP': '장부 날이 이어지지 않습니다.',
    'CHAIN_BROKEN': '해시 사슬이 끊겼습니다.',
    'DAY_HASH_MISMATCH': '다시 센 하루 해시가 다릅니다.',
    'ROWS_BEFORE_FIRST_STAMP': '첫 마감 앞 날에 기록이 끼어들었습니다.',
    'ATTRIBUTION': '기록을 날짜에 나누지 못했습니다.',
    'SQLITE_INTEGRITY': '장부 파일 점검에서 오류가 나왔습니다.',
}
SELFTEST_PLAN = [
    (ID_GOLDEN, 'OK', None, '(합성) 골든벡터 셀프테스트를 전량 통과했습니다.'),
    (ID_GOLDEN, 'ACT', None, '(합성) 골든벡터 셀프테스트에서 불일치가 나왔습니다. 실전 전환과 업데이트를 멈추고 확인해 주세요.'),
    (ID_GOLDEN, 'BLOCKED', BIOMETRIC, '생체 확인이 없어 실행하지 않았습니다.'),
    (ID_INTEGRITY, 'OK', None, '(합성) 정본 자가 대조가 일치합니다.'),
    (ID_INTEGRITY, 'BLOCKED', BIOMETRIC, '생체 확인이 없어 점검하지 않았습니다.'),
] + [(ID_INTEGRITY, 'BLOCKED', c, INTEGRITY_HEAD + INTEGRITY_TAIL[c]) for c in INTEGRITY_CODES]


# ────────────────────────────────────────────────────────────────────────
# VM 짓기
# ────────────────────────────────────────────────────────────────────────
def backup_vm(last, badge, level, notice, run, locked, points, empty, link, asof):
    out = dict(zip(BK_KEYS, [last, badge, level, notice, copy.deepcopy(run), locked, copy.deepcopy(points), empty,
                             copy.deepcopy(link), copy.deepcopy(asof)]))
    assert list(out) == BK_KEYS
    return out


def build_backup():
    base = backup_vm('마지막 백업 11-17 21:40', None, 'OK', NOTICE_LOCAL, RUN_BACKUP, None, [P1, P2], None, LINK_X1,
                     AS_S09)
    age = dict(copy.deepcopy(base), last_backup_text='마지막 백업 11-10 20:05', age_badge_text=AGE_BADGE,
               level='WATCH', points=[copy.deepcopy(P2)])
    empty = dict(copy.deepcopy(base), last_backup_text='아직 백업한 적이 없습니다', level='INFO', points=[],
                 points_empty_label=EMPTY_POINTS)
    sim = dict(copy.deepcopy(base), last_backup_text='백업 기록 없음', level='INFO', notice_text=NOTICE_SIM,
               run_action=None, points=[], points_empty_label=EMPTY_POINTS, migration_link=None)
    locked = dict(copy.deepcopy(base), run_action=None, migration_link=None, locked_label=LOCKED)
    stale = dict(copy.deepcopy(base), as_of=copy.deepcopy(STALE_S09))
    out = {BK: base, BK_AGE: age, BK_EMPTY: empty, BK_SIM: sim, BK_LOCKED: locked, BK_STALE: stale}
    for v in out.values():
        assert list(v) == BK_KEYS
    return out


def diag_vm(golden, integrity, board, link, recommend, locked, asof):
    out = dict(zip(DG_KEYS, [copy.deepcopy(golden), copy.deepcopy(integrity), copy.deepcopy(board),
                             copy.deepcopy(link), recommend, locked, copy.deepcopy(asof)]))
    assert list(out) == DG_KEYS
    return out


def build_diag(board_ok, board_diff):
    base = diag_vm(G_PENDING, I_OK, board_ok, None, RECOMMEND, None, AS_S10)
    diff = diag_vm(G_PASS, I_OK, board_diff, LINK_DIFFS, None, None, AS_S10)
    running = diag_vm(G_RUNNING, I_OK, board_ok, None, None, None, AS_S10)
    locked = copy.deepcopy(diff)
    locked['golden']['run_action'] = None
    locked['integrity']['run_action'] = None
    locked['locked_label'] = LOCKED
    stale = dict(copy.deepcopy(base), as_of=copy.deepcopy(STALE_S10))
    return {DG: base, DG_DIFF: diff, DG_RUNNING: running, DG_LOCKED: locked, DG_STALE: stale}


def ar_vm(year, window, entries, pledge, asof):
    out = dict(zip(AR_KEYS, [year, window, copy.deepcopy(entries), copy.deepcopy(pledge), copy.deepcopy(asof)]))
    assert list(out) == AR_KEYS
    return out


def build_annual():
    base = ar_vm('2026년 연간 리뷰', W_OPEN, ENTRIES4, LINK_PLEDGE, AS_S12)
    return {
        AR_OPEN: base,
        AR_CLOSED: ar_vm('2025년 연간 리뷰', W_CLOSED, ENTRIES4, None, AS_S12),
        AR_FIRST: ar_vm('2026년 연간 리뷰', W_FIRST, ENTRIES4[:2], None, AS_S12),
        AR_STALE: dict(copy.deepcopy(base), as_of=copy.deepcopy(STALE_S12)),
    }


def build_results(prefix, plan):
    return [dict(zip(RESULT_KEYS, ['%s_%02d' % (prefix, n), aid, level, headline, code, None, False]))
            for n, (aid, level, code, headline) in enumerate(plan, 1)]


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_r8_v123_fixtures.py 와 같은 꼴 — VM 행은 키마다 한 줄 · 결과 행도 키마다 한 줄)
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
    """봉투(v1.15~v1.23 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def board_of(rel):
    env = json.loads(base_text(rel))
    assert len(env['rows']) == 1, rel
    return env['rows'][0]


def new_files():
    texts = {}
    env_as_of = {}
    for rel, row in build_backup().items():
        env_as_of[rel] = AS_S09
    vms = dict(build_backup())
    diag = build_diag(board_of(BOARD_OK), board_of(BOARD_DIFF))
    vms.update(diag)
    for rel in diag:
        env_as_of[rel] = AS_S10
    annual = build_annual()
    vms.update(annual)
    for rel in annual:
        env_as_of[rel] = AS_S12
    for rel, row in vms.items():
        texts[rel] = ser_envelope(envelope([row], env_as_of[rel]), True)
    texts[BK_RESULTS] = ser_envelope(
        envelope(build_results('ar_s09', [(ID_BACKUP,) + p for p in BACKUP_PLAN]), AS_RESULT), True)
    texts[ST_RESULTS] = ser_envelope(envelope(build_results('ar_s10', SELFTEST_PLAN), AS_RESULT), True)
    return texts


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


CHECKS = (('금지어', FORBIDDEN), ('개발자 메모', DEV_MEMO), ('계좌꼴', ACCOUNT_LIKE), ('전화번호 꼴', PHONE),
          ('앱키 꼴', LONG_ALNUM), ('URL 꼴', URL_LIKE), ('8자리 숫자', LONG_DIGITS), ('손익 낱말', PNL_WORD),
          ('16진 9자', LONG_HEX), ('경로·파일 이름', PATH_LIKE), ('크기 단위', SIZE_UNIT), ('총계·비율', TOTALS),
          ('금액 글자', MONEY), ('숫자 뒤 원·만', DIGIT_THEN_UNIT))


def self_check_file(rel, s, new):
    assert '\r' not in s and not s.startswith('\ufeff'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    if new:
        assert env['meta'] == NEW_META, rel
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            for name, rx in CHECKS:
                assert not rx.search(v), '%s %s — %s: %s' % (rel, path, name, v)
            assert 'DRY_RUN' not in v, (rel, path, v)
            assert not v.startswith('aaq://'), (rel, path, v)                          # 링크 = deep_link 칸만
            for nc in NOT_CALLED:
                assert nc not in v, (rel, path, v)                                     # C-58 ⑭
        for d in deep_links(env['rows']):
            assert d in ROUTES, (rel, d)
        ks = set(keys(env['rows']))
        assert not any(PNL_KEY.search(k) for k in ks), rel
    return env


def check_results(rows, prefix, ids, codes):
    n = len(rows)
    assert all(list(r) == RESULT_KEYS for r in rows)
    assert [r['action_run_id'] for r in rows] == ['%s_%02d' % (prefix, i) for i in range(1, n + 1)]
    assert {r['id'] for r in rows} == ids
    assert all(r['handoff_route'] is None and r['retryable'] is False for r in rows)
    assert {r['reason_code'] for r in rows} == codes, {r['reason_code'] for r in rows} ^ codes
    for r in rows:
        if r['reason_code'] != BIOMETRIC:
            assert r['headline'].startswith('(합성)'), r


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert all(u in rels for u in UNTOUCHED)
    assert len(NEW_FILES) == 17 and len(set(NEW_FILES)) == 17
    # 창 상태 글자 = m7 표본 글자(K136 ⓐ).
    for key, want in (('open', W_OPEN), ('closed', W_CLOSED), ('first', W_FIRST)):
        assert json.loads(base_text(ANNUAL[key]))['rows'][0]['window_state_label'] == want, key

    out = new_files()
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    one = {rel: envs[rel]['rows'][0] for rel in BK_VMS + DG_VMS + AR_VMS}
    for rel in BK_VMS + DG_VMS + AR_VMS:
        assert len(envs[rel]['rows']) == 1, rel
        vm_as_of = dict(one[rel]['as_of'])
        vm_as_of.pop('stale_label', None)
        assert envs[rel]['as_of'] == vm_as_of, rel                                  # VM as_of == 봉투(오래됨 = + stale_label)
        assert ('stale_label' in one[rel]['as_of']) == (rel in (BK_STALE, DG_STALE, AR_STALE)), rel
        assert 'stale_label' not in envs[rel]['as_of'], rel
    # S09 — 키 · 잠김 · 빈 지점 · 해시 · args.
    for rel in BK_VMS:
        r = one[rel]
        assert list(r) == BK_KEYS, rel
        if r['locked_label'] is not None:
            assert r['run_action'] is None, rel                                      # C-58 ②
        assert (r['points'] == []) == (r['points_empty_label'] is not None), rel     # C-58 ③
        for p in r['points']:
            assert re.fullmatch(r'[0-9a-f]{8}', p['chain_hash_text']) and re.search(r'[a-f]', p['chain_hash_text'])
            assert re.fullmatch(r'rp_s09_\d\d', p['code'])
        if r['run_action'] is not None:
            assert r['run_action']['args'] == {}
        assert not re.search(r'[0-9]', r['age_badge_text'] or ''), rel               # V18 — 배지 숫자 0
    assert [r for r in BK_VMS if one[r]['locked_label'] is not None] == [BK_LOCKED]
    # S10 — 보드 = m8 rows[0](K136 ⓐ · C-58 ⑨).
    for rel in DG_VMS:
        r = one[rel]
        assert list(r) == DG_KEYS, rel
        want = board_of(BOARD_DIFF) if rel in (DG_DIFF, DG_LOCKED) else board_of(BOARD_OK)
        assert r['board'] == want, rel
        if r['locked_label'] is not None:
            assert r['golden']['run_action'] is None and r['integrity']['run_action'] is None, rel
        for c in ('golden', 'integrity'):
            if r[c]['run_action'] is not None:
                assert r[c]['run_action']['args'] == {}
    assert [r for r in DG_VMS if one[r]['locked_label'] is not None] == [DG_LOCKED]
    assert G_PENDING_STATUS in '라이브 · 자동매매 · 골든벡터 판정 보류'                     # 엔진 칩 꼬리(부분 문자열)
    assert re.fullmatch(r'마지막 검증 \d\d-\d\d \d\d:\d\d', I_STATUS)
    # S12 — 서약 링크 = OPEN(원판)만 · 목차 링크 = M7.
    for rel in AR_VMS:
        r = one[rel]
        assert list(r) == AR_KEYS, rel
        assert (r['pledge_link'] is not None) == (rel in (AR_OPEN, AR_STALE)), rel
        assert all(e['deep_link'] in ROUTES - {'aaq://m5/pledge', 'aaq://x1/migration', 'aaq://ledger/diffs'}
                   for e in r['entries'])
        for path, v in strings({k: v for k, v in r.items() if k not in ('as_of', 'year_label')}):
            assert not re.search(r'[0-9]', v), (rel, path, v)                        # C-58 ⑪
    # 변종 동치(C-58 ⑬).
    lk = dict(one[BK_LOCKED], run_action=RUN_BACKUP, migration_link=LINK_X1, locked_label=None)
    assert lk == one[BK]
    dl = copy.deepcopy(one[DG_LOCKED])
    dl['golden']['run_action'] = RUN_GOLDEN
    dl['integrity']['run_action'] = RUN_INTEGRITY
    dl['locked_label'] = None
    assert dl == one[DG_DIFF]
    for st, base, asof in ((BK_STALE, BK, AS_S09), (DG_STALE, DG, AS_S10), (AR_STALE, AR_OPEN, AS_S12)):
        assert dict(one[st], as_of=asof) == one[base], st
    # 결과.
    check_results(envs[BK_RESULTS]['rows'], 'ar_s09', {ID_BACKUP}, set(BACKUP_CODES) | {BIOMETRIC, None})
    assert len(envs[BK_RESULTS]['rows']) == 10
    assert {r['level'] for r in envs[BK_RESULTS]['rows']} == LEVELS
    st_rows = envs[ST_RESULTS]['rows']
    assert len(st_rows) == 12
    check_results(st_rows, 'ar_s10', {ID_GOLDEN, ID_INTEGRITY}, set(INTEGRITY_CODES) | {BIOMETRIC, None})
    assert {r['reason_code'] for r in st_rows if r['id'] == ID_GOLDEN} == {BIOMETRIC, None}
    assert all(r['level'] == 'BLOCKED' for r in st_rows if r['reason_code'] in INTEGRITY_CODES)

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
    print('gen_r9_v124_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.24.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
