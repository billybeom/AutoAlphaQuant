#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.18(R6 선행 M2 보강 + 엔진 등재형 · 01 §27) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r6_v118_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r16_v117_fixtures.py(계약 v1.17 · 그 스크립트는 v1.17 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-13_R6선행_계약v1.18_설계서.md` §5 · 240 → 248 = 신설 8 · 개정 1 · 버전 줄만 239)
  (a) 전 봉투의 "contract_version": "1.17.0" → "1.18.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 1 — m8/incident_token_expired: 안쪽 연결 4행의 `action_available` 키 삭제 + `detail_line` null · `level` ·
      `actions` · `channel_picker` null(키 차례 = 01 §27 `ConnectionRow`) · VM `locked_label` null ·
      🔴 `status_code` 글자 무변경 · 형제 키 `incident_alert` 무변경(미결 165 해소 — 등록부 `_connectionsVm` 바인딩).
  (c) 신설 8 — R6a 3(M9 S01 설정 홈) · R6b 3 + 동작 결과 1(M9 S07 연결 관리) · 엔진 등재형 알림 1.
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 레벨 5값 전수 — settings_home 카드 11 · connections 행 5 · settings_action_results 5 — 각 표본 안에서(«표본 동치» 방지).
🔴 m9 신설 표본 전 문자열 «DRY_RUN» 0(G-63 확장) · 손익 낱말 0 · 금액 글자 0 · 토큰·URL 0.
🔴 알림 글자 = 엔진 core_engine/lib/src/safety/alert_text.dart 의 제안 6 초안 그대로(등급 = kAlertLevels).

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r6_v118_fixtures.py
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
# 계약 1.17.0 · 픽스처 240 의 기준 커밋(origin/main · E14c1 #139 — 계약 패키지 = PR #123 이후 무변경).
BASE = '3d4c79eb8fed02a43e91690cf782308cc94c215b'

OLD_VER = '"contract_version": "1.17.0"'
NEW_VER = '"contract_version": "1.18.0"'
BASE_FILES = 240
WANT_FILES = 248

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
PNL_WORD = re.compile(r'수익률|평가액|손익')               # C-52 ⑬
MONEY = re.compile(r'[0-9][0-9,]*원')                      # C-52 ⑬
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PHONE = re.compile(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}')    # C-51 ⑤ 개인 전화번호 꼴
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
URL_LIKE = re.compile(r'https?://|github\.com|\.io/')      # 저장소 주소·URL 0
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}

# ── 라우트(lib/src/navigation/app_links.dart 와 같은 글자 — C-33 ① 이 등록을 다시 본다) ──
R = {
    'general': 'aaq://settings/general',
    'credentials': 'aaq://settings/credentials',
    'accounts': 'aaq://settings/accounts',
    'operations': 'aaq://settings/operations',
    'contribution': 'aaq://settings/contribution',
    'devices': 'aaq://settings/devices',
    'connections': 'aaq://settings/connections',
    'calendar': 'aaq://settings/calendar',
    'backup': 'aaq://settings/backup',
    'diagnostics': 'aaq://settings/diagnostics',
    'allocation': 'aaq://settings/allocation',
    'annual_review': 'aaq://settings/annual-review',
    'watchdog': 'aaq://ops/watchdog',
    'block_board': 'aaq://m5/block-board',
    'resume_gate': 'aaq://x2/resume-gate',
    'resume_report': 'aaq://x2/resume-report',
}
PHONE_ONLY = {R[k] for k in ('credentials', 'accounts', 'operations', 'devices', 'calendar', 'backup',
                             'diagnostics', 'contribution')}

# ── 이름 ─────────────────────────────────────────────────────────────────
TOKEN_EXP = 'm8/incident_token_expired.json'
REVISED = [TOKEN_EXP]

HOME = 'm9/settings_home.json'
HOME_NR = 'm9/settings_home_no_review.json'
HOME_VW = 'm9/settings_home_viewer.json'
CONN = 'm9/connections.json'
CONN_TG = 'm9/connections_telegram.json'
CONN_LK = 'm9/connections_locked.json'
RESULTS = 'm9/settings_action_results.json'
ALERTS = 'm8/alerts_safety_resume.json'

HOMES = [HOME, HOME_NR, HOME_VW]
CONNS = [CONN, CONN_TG, CONN_LK]
NEW_FILES = HOMES + CONNS + [RESULTS, ALERTS]
M9_NEW = HOMES + CONNS + [RESULTS]

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.18.0',
    'generated_at': '2026-11-13T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261113,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}


def as_of(label, observed='2026-08-31T09:00:00Z', trade_date='2026-08-31'):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': label}


AS1 = as_of('설정 기준 2026-08-31 09:00')
AS7 = as_of('연결 기준 2026-08-31 09:00')
AS_RESULT = as_of('동작 기준 2026-08-31')
AS_ALERT = as_of('알림 기준 2026-08-31')


# ────────────────────────────────────────────────────────────────────────
# R6a — M9 S01 설정 홈(§5-1)
# ────────────────────────────────────────────────────────────────────────
CARD_KEYS = ['code', 'title', 'level', 'status_label', 'attention_text', 'route']


def card(*vals):
    assert len(vals) == len(CARD_KEYS)
    return dict(zip(CARD_KEYS, vals))


C1 = card('SET_GENERAL', '알림·방해금지·화면', 'OK', 'P1 묶음 · 22:00–07:00 조용히', None, R['general'])
C2 = card('SET_CREDENTIALS', '증권사 키', 'ACT', '3벌 중 1벌 만료 임박', '1', R['credentials'])
C3 = card('SET_ACCOUNTS', '계좌·매핑', 'OK', '정상', None, R['accounts'])
C4 = card('SET_OPERATIONS', '운용 관리', 'WATCH', '실전 · 관찰 중', None, R['operations'])
C5 = card('SET_CONTRIBUTION', '월 납입', 'INFO', '다음 납입 주기부터 새 값이 적용됩니다', None, R['contribution'])
C6 = card('SET_DEVICES', '기기·접근', 'INFO', '기기 2대 · 조회 전용 1대', None, R['devices'])
C7 = card('SET_CONNECTIONS', '연결', 'BLOCKED', '5개 중 3개 확인 필요', '3', R['connections'])
C8 = card('SET_CALENDAR', '구글 캘린더', 'INFO', '연결 안 됨', None, R['calendar'])
C9 = card('SET_BACKUP', '백업·복원', 'OK', '마지막 백업 08-31 03:10', None, R['backup'])
C10 = card('SET_DIAGNOSTICS', '진단', 'OK', '골든벡터 통과 · 08-31', None, R['diagnostics'])
C11 = card('SET_ALLOCATION', '전략·배분', 'OK', 'balanced(P0S)', None, R['allocation'])
C4_NR = dict(C4, level='OK', status_label='실전 · 자동 주문 중')

OPS_LABEL = '운영 · 들어갈 때 생체 인증'


def group(tier, label, cards):
    return {'tier': tier, 'label': label, 'cards': copy.deepcopy(cards)}


G1 = group('GENERAL', '일반', [C1])
G2 = group('OPERATIONAL', OPS_LABEL, [C2, C3, C4, C5, C6, C7, C8, C9, C10])
G2_NR = group('OPERATIONAL', OPS_LABEL, [C2, C3, C4_NR, C5, C6, C7, C8, C9, C10])
G2_VW = group('OPERATIONAL', OPS_LABEL, [C7])
G3 = group('RULE', '규칙 · 12월 창에서만 적용', [C11])

CH1 = {'label': '실전 · 관찰 중 · 골든벡터 통과', 'level': 'WATCH',
       'promotion_label': '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)'}
CH2 = {'label': '실전 · 자동 주문 중 · 골든벡터 통과', 'level': 'OK', 'promotion_label': None}
AR = {'label': '12월 연간 리뷰가 열렸습니다', 'deep_link': R['annual_review']}


def home(chip, link, groups):
    return {'status_chip': copy.deepcopy(chip), 'annual_review_link': copy.deepcopy(link),
            'groups': copy.deepcopy(groups), 'as_of': copy.deepcopy(AS1)}


HOME_VMS = {
    HOME: home(CH1, AR, [G1, G2, G3]),
    HOME_NR: home(CH2, None, [G1, G2_NR, G3]),
    HOME_VW: home(CH1, AR, [G1, G2_VW, G3]),
}


# ────────────────────────────────────────────────────────────────────────
# R6b — M9 S07 연결 관리(§5-2)
# ────────────────────────────────────────────────────────────────────────
ROW_KEYS = ['target', 'label', 'status_code', 'status_label', 'last_ok_text', 'detail_line', 'level', 'actions',
            'route', 'channel_picker']


def call(id_, args, label):
    return {'id': id_, 'args': dict(args), 'label': label}


def T(x):
    return call('CONNECTION_TEST', {'target': x}, '연결 테스트')


def S(x):
    return call('CONNECTION_SYNC_NOW', {'target': x}, '지금 동기화')


def row(*vals):
    assert len(vals) == len(ROW_KEYS)
    return dict(zip(ROW_KEYS, copy.deepcopy(list(vals))))


WATCHDOG_LINE = '생존 신호 경보는 이 선택과 따로 텔레그램이나 이메일로 갑니다.'
PK = {
    'label': '받을 채널',
    'options': [
        {'code': 'TELEGRAM', 'label': '텔레그램', 'selected': False,
         'select_action': call('NOTIFY_CHANNEL_SELECT', {'channel': 'TELEGRAM'}, '텔레그램으로 바꾸기')},
        {'code': 'KAKAO', 'label': '카카오톡', 'selected': True, 'select_action': None},
    ],
    'capability_notice': '카카오톡은 보내기만 됩니다. 메시지로 자동 매매를 멈출 수 없으니, '
                         '멈출 때는 앱의 정지 버튼이나 웹 화면을 쓰십시오.',
    'token_badge_text': '카카오 연결 만료 3일 전 — 다시 연결해 주세요',
    'watchdog_channel_line': WATCHDOG_LINE,
}
PT = {
    'label': '받을 채널',
    'options': [
        {'code': 'TELEGRAM', 'label': '텔레그램', 'selected': True, 'select_action': None},
        {'code': 'KAKAO', 'label': '카카오톡', 'selected': False,
         'select_action': call('NOTIFY_CHANNEL_SELECT', {'channel': 'KAKAO'}, '카카오톡으로 바꾸기')},
    ],
    'capability_notice': '텔레그램은 메시지로 자동 매매를 멈출 수 있습니다(/stop).',
    'token_badge_text': None,
    'watchdog_channel_line': WATCHDOG_LINE,
}

R1 = row('SUPABASE', '미러(Supabase)', 'LAGGED', '일부 지연', '2분 전에 성공', '9개 표 중 1개 지연 — 보유현황', 'WATCH',
         [T('SUPABASE'), S('SUPABASE')], None, None)
R2 = row('GITHUB_ARCHIVE', '아카이브(GitHub)', 'FAILED', '올리기 실패', '어제 23:40에 마지막으로 성공',
         '마지막 커밋 3f2a9c1 · 접근 토큰 만료 2027-02-28', 'ACT', [T('GITHUB_ARCHIVE'), S('GITHUB_ARCHIVE')], None, None)
R3 = row('NOTIFY_CHANNEL', '알림 채널', 'OK', '정상', '08:55 시험 발송 성공', None, 'OK',
         [call('CONNECTION_TEST', {'target': 'NOTIFY_CHANNEL'}, '시험 발송')], None, PK)
R4 = row('HEALTHCHECKS', '생존 신호(healthchecks)', 'FAILED', '신호 끊김', '3시간 전에 마지막 수신', '체크 6개 중 1개 유예 초과',
         'BLOCKED', [], R['watchdog'], None)
R5 = row('CALENDAR', '구글 캘린더', 'NOT_SET', '연결 안 됨', '연결한 적 없음', None, 'INFO', [], R['calendar'], None)

R1_OK = dict(copy.deepcopy(R1), status_code='OK', status_label='정상', last_ok_text='1분 전에 성공', detail_line=None,
             level='OK')
R2_OK = dict(copy.deepcopy(R2), status_code='OK', status_label='정상', last_ok_text='오늘 08:40 커밋',
             detail_line='마지막 커밋 7b1e0d4 · 접근 토큰 만료 2027-02-28', level='OK')
R3_TG = dict(copy.deepcopy(R3), channel_picker=copy.deepcopy(PT))
R4_OK = dict(copy.deepcopy(R4), status_code='OK', status_label='정상', last_ok_text='2분 전에 수신',
             detail_line='체크 6개 모두 정상', level='OK')

LOCKED_LABEL = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'


def locked(r):
    out = copy.deepcopy(r)
    out['actions'] = []
    if out['channel_picker'] is not None:
        for o in out['channel_picker']['options']:
            o['select_action'] = None
    return out


def conns(rows, locked_label=None):
    return {'rows': copy.deepcopy(rows), 'as_of': copy.deepcopy(AS7), 'locked_label': locked_label}


CONN_VMS = {
    CONN: conns([R1, R2, R3, R4, R5]),
    CONN_TG: conns([R1_OK, R2_OK, R3_TG, R4_OK]),
    CONN_LK: conns([locked(r) for r in (R1, R2, R3, R4, R5)], LOCKED_LABEL),
}

RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']


def result(*vals):
    assert len(vals) == len(RESULT_KEYS)
    return dict(zip(RESULT_KEYS, vals))


RESULT_ROWS = [
    result('ar_m9_01', 'CONNECTION_TEST', 'OK', '미러(Supabase) 연결이 정상입니다.', None, None, False),
    result('ar_m9_02', 'CONNECTION_TEST', 'ACT', '아카이브(GitHub)에 연결하지 못했습니다. 접근 토큰을 다시 등록하십시오.',
           'CONNECTION_TEST_FAILED', None, False),
    result('ar_m9_03', 'CONNECTION_SYNC_NOW', 'INFO', '이미 동기화 중입니다. 끝나면 이 화면이 바뀝니다.',
           'SYNC_ALREADY_RUNNING', None, False),
    result('ar_m9_04', 'NOTIFY_CHANNEL_SELECT', 'WATCH', '알림 채널을 카카오톡으로 바꿨습니다. 메시지로 자동 매매를 멈출 수는 없습니다.',
           None, None, False),
    result('ar_m9_05', 'CONNECTION_SYNC_NOW', 'BLOCKED', '생체 인증이 없어 바꿀 수 없습니다. 이 화면을 다시 열어 인증하십시오.',
           'BIOMETRIC_UNAVAILABLE', None, False),
]


# ────────────────────────────────────────────────────────────────────────
# 엔진 등재형 — 알림 6(§5-3 · 글자 = 엔진 alert_text.dart 제안 6 초안 그대로)
# ────────────────────────────────────────────────────────────────────────
ALERT_KEYS = ['alert_id', 'level', 'raised_at', 'code', 'title', 'body_text', 'action_line', 'grouped_count',
              'deep_link', 'ack', 'raised_at_text', 'grouped_text', 'detail_deep_link']


def alert(alert_id, level, raised_at, code, title, body, action_line, deep_link):
    return dict(zip(ALERT_KEYS, [alert_id, level, raised_at, code, title, body, action_line, 1, deep_link, None,
                                 None, None, None]))


ALERT_ROWS = [
    alert('al_sr_01', 'P0', '2026-08-31T00:30:00Z', 'BREAKER_STOPPED', '서킷브레이커가 정지 단계에 들어갔습니다',
          '드로다운이 정지 기준에 닿아 신규 주문을 전면 중단했습니다. 보유는 그대로입니다.',
          '3일 안에 postmortem 을 쓰십시오.', R['block_board']),
    alert('al_sr_02', 'P0', '2026-08-31T00:20:00Z', 'LEDGER_INTEGRITY_BROKEN', '원장 무결성 검사에 실패했습니다',
          '지난 날의 해시가 기록과 맞지 않아 모든 신규 주문을 막았습니다.',
          '차단 보드에서 복구 절차를 여십시오.', R['block_board']),
    alert('al_sr_03', 'P0', '2026-08-31T00:10:00Z', 'RESUME_TRADING_HALTED', '재개 뒤 매매를 멈춰 두었습니다',
          '재개 점검이 끝나지 않아 모든 신규 주문을 막아 두었습니다.',
          '재개 화면에서 막힌 이유와 할 일을 확인하십시오.', R['resume_gate']),
    alert('al_sr_04', 'P1', '2026-08-31T00:25:00Z', 'STOPPED_RELEASE_ELIGIBLE', '정지 단계 재개 자격을 충족했습니다',
          '회복 조건을 채워 재개 결정을 할 수 있습니다. 자동으로 풀리지 않습니다.',
          '재개 결정 전에 postmortem 과 가족 합의를 확인하십시오.', R['block_board']),
    alert('al_sr_05', 'P1', '2026-08-31T00:15:00Z', 'RESUME_COMPLETED', '재개를 마쳤습니다',
          '멈춰 있던 동안의 계획을 다시 판정했습니다. 주문은 다음 주문 회차가 냅니다.',
          '재개 리포트에서 항목별 결과를 확인하십시오.', R['resume_report']),
    alert('al_sr_06', 'P2', '2026-08-31T00:05:00Z', 'RESUME_DATA_GAP', '되살릴 수 없는 기록 공백이 있습니다',
          '멈춰 있던 동안의 기록 가운데 소급할 수 없는 것은 비운 채로 둡니다.',
          '재개 리포트에서 빈 구간을 확인하십시오.', R['resume_report']),
]
ENGINE_LEVEL = {'BREAKER_STOPPED': 'P0', 'LEDGER_INTEGRITY_BROKEN': 'P0', 'RESUME_TRADING_HALTED': 'P0',
                'STOPPED_RELEASE_ELIGIBLE': 'P1', 'RESUME_COMPLETED': 'P1', 'RESUME_DATA_GAP': 'P2'}

# ── 개정 — incident_token_expired 행별 새 칸(§5-2 · 🔴 status_code 무변경) ──
#    🔵 route — 원문에 있던 두 행(BROKER_KIS · GITHUB_ARCHIVE)은 그대로 · 없던 행은 null 을 적고(키 차례 = §4-3) ·
#       HEALTHCHECKS 만 `opsWatchdog`(K-g «행 1 + W-01 링크» · C-52 ⑤ 가 연결 4벌 전부에서 본다).
TOKEN_REV = {
    'BROKER_KIS': ('BLOCKED', [T('BROKER_KIS')], None),
    'SUPABASE': ('OK', [], None),
    'GITHUB_ARCHIVE': ('WATCH', [S('GITHUB_ARCHIVE')], None),
    'HEALTHCHECKS': ('OK', [], R['watchdog']),
}


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_r16_v117_fixtures.py 와 같은 꼴)
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
    """봉투(v1.15~v1.17 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


# ────────────────────────────────────────────────────────────────────────
# 개정
# ────────────────────────────────────────────────────────────────────────
def revise_token_expired():
    s = bump(base_text(TOKEN_EXP), TOKEN_EXP)
    env = json.loads(s)
    assert list(env) == ENVELOPE_KEYS + ['incident_alert'], list(env)
    assert len(env['rows']) == 1
    vm = env['rows'][0]
    assert list(vm) == ['rows', 'as_of'], list(vm)
    new_rows = []
    for r in vm['rows']:
        assert 'action_available' in r and 'level' not in r, r['target']
        level, actions, route = TOKEN_REV[r['target']]
        assert route is None or 'route' not in r, r['target']
        out = {}
        for k in ROW_KEYS:
            if k in ('detail_line', 'channel_picker'):
                out[k] = None
            elif k == 'level':
                out[k] = level
            elif k == 'actions':
                out[k] = copy.deepcopy(actions)
            elif k == 'route':
                out[k] = r.get('route', route)
            else:
                out[k] = r[k]
        assert set(r) - {'action_available'} <= set(out), r['target']
        new_rows.append(out)
    assert [x['target'] for x in new_rows] == list(TOKEN_REV)
    assert [x['status_code'] for x in new_rows] == ['TOKEN_EXPIRED', 'OK', 'LAG', 'OK']
    new_vm = {'rows': new_rows, 'as_of': vm['as_of'], 'locked_label': None}
    # 봉투 `rows` 덩어리만 갈아 끼운다(meta·as_of·형제 키 `incident_alert` 의 글자 꼴 그대로).
    head, rest = s.split('\n  "rows": [\n', 1)
    old_rows, tail = rest.split('\n  ],\n  "incident_alert": ', 1)
    assert json.loads('[' + old_rows + ']') == env['rows']
    return head + '\n  "rows": [\n    ' + pretty(new_vm, 2) + '\n  ],\n  "incident_alert": ' + tail


def new_files():
    texts = {}
    for vms, env_as_of in ((HOME_VMS, AS1), (CONN_VMS, AS7)):
        for rel, vm in vms.items():
            texts[rel] = ser_envelope(vm_envelope([vm], env_as_of), False)
    texts[RESULTS] = ser_envelope(vm_envelope(RESULT_ROWS, AS_RESULT), True)
    texts[ALERTS] = ser_envelope(vm_envelope(ALERT_ROWS, AS_ALERT), True)
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


def self_check_file(rel, s, touched, new):
    assert '\r' not in s and not s.startswith('﻿'), rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE' and env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    for rx in RETIRED:
        body = s.split('  },\n', 1)[1]
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    if touched:
        assert list(env.keys())[:6] == ENVELOPE_KEYS, (rel, list(env.keys()))
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
            if new:
                assert not DEV_MEMO.search(v), '%s %s — 개발자 메모: %s' % (rel, path, v)
                assert not ACCOUNT_LIKE.search(v), '%s %s — 계좌꼴: %s' % (rel, path, v)
                assert not PHONE.search(v), '%s %s — 전화번호 꼴: %s' % (rel, path, v)
                assert not LONG_ALNUM.search(v), '%s %s — 앱키 꼴: %s' % (rel, path, v)
                assert not URL_LIKE.search(v), '%s %s — URL 꼴: %s' % (rel, path, v)
                if rel in M9_NEW:
                    assert 'DRY_RUN' not in v, '%s %s — DRY_RUN 글자: %s' % (rel, path, v)
                    assert not PNL_WORD.search(v), '%s %s — 손익 낱말: %s' % (rel, path, v)
                    assert not MONEY.search(v), '%s %s — 금액 글자: %s' % (rel, path, v)
                if v.startswith('aaq://'):
                    assert v in R.values(), '%s %s — 라우트 글자: %s' % (rel, path, v)
        assert not any(PNL_KEY.search(k) for k in keys(env)), rel
        assert 'action_available' not in set(keys(env)), rel
        assert 'is_viewer' not in set(keys(env)), rel
        assert 'action' not in set(keys(env)), rel                                # C-50 ⑨ walker 키 0
    if new:
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
    return env


def check_home(vm, rel):
    tiers = [g['tier'] for g in vm['groups']]
    order = ['GENERAL', 'OPERATIONAL', 'RULE']
    assert tiers == sorted(set(tiers), key=order.index), (rel, tiers)
    codes = [c['code'] for g in vm['groups'] for c in g['cards']]
    assert len(codes) == len(set(codes)), rel
    for g in vm['groups']:
        assert g['cards'], rel
        for c in g['cards']:
            assert list(c) == CARD_KEYS and c['route'] in R.values() and c['level'] in LEVELS, (rel, c['code'])
    assert 'DRY_RUN' not in vm['status_chip']['label']
    if vm['annual_review_link'] is not None:
        assert vm['annual_review_link']['deep_link'] == R['annual_review']
    assert vm['as_of']['label'] == AS1['label']


def check_conns(vm, rel):
    targets = [r['target'] for r in vm['rows']]
    assert len(targets) == len(set(targets)), rel
    pickers = [r for r in vm['rows'] if r['channel_picker'] is not None]
    if rel != TOKEN_EXP:
        assert len(pickers) == 1 and pickers[0]['target'] == 'NOTIFY_CHANNEL', rel
    for r in vm['rows']:
        sc, lv = r['status_code'], r['level']
        assert (sc == 'OK') == (lv == 'OK'), (rel, r['target'])
        if sc == 'NOT_SET':
            assert lv == 'INFO', (rel, r['target'])
        if sc == 'FAILED':
            assert lv in ('ACT', 'BLOCKED'), (rel, r['target'])
        if sc == 'LAGGED':
            assert lv in ('WATCH', 'ACT'), (rel, r['target'])
        for a in r['actions']:
            assert a['id'] in ('CONNECTION_TEST', 'CONNECTION_SYNC_NOW') and a['args'] == {'target': r['target']}, rel
        if r['target'] == 'HEALTHCHECKS':
            assert not r['actions'] and r['route'] == R['watchdog'], rel
        p = r['channel_picker']
        if p is not None:
            assert sum(1 for o in p['options'] if o['selected']) == 1, rel
            for o in p['options']:
                if o['selected']:
                    assert o['select_action'] is None, rel
                elif vm['locked_label'] is None:
                    sa = o['select_action']
                    assert sa['id'] == 'NOTIFY_CHANNEL_SELECT' and sa['args'] == {'channel': o['code']}, rel
                else:
                    assert o['select_action'] is None, rel
            assert p['capability_notice'] and p['watchdog_channel_line'], rel
    if vm.get('locked_label') is not None:
        assert all(not r['actions'] for r in vm['rows']), rel


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels)
    assert len(NEW_FILES) == 8 and len(set(NEW_FILES)) == 8

    out = {TOKEN_EXP: revise_token_expired()}
    out.update(new_files())
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES or rel in REVISED, rel in NEW_FILES)
            for rel, s in out.items()}
    vm = {rel: envs[rel]['rows'][0] for rel in HOMES + CONNS + [TOKEN_EXP]}
    for rel in HOMES + CONNS:
        assert len(envs[rel]['rows']) == 1, rel
        assert vm[rel]['as_of'] == envs[rel]['as_of'], rel
    # S01 — 묶음 차례 · 카드 11 · 레벨 5값 전수 · 주의 있음/없음 · 칩·링크 갈래 · 뷰어 ⊂ 원판.
    for rel in HOMES:
        check_home(vm[rel], rel)
    home_cards = [c for g in vm[HOME]['groups'] for c in g['cards']]
    assert len(home_cards) == 11 and {c['level'] for c in home_cards} == LEVELS
    assert any(c['attention_text'] for c in home_cards) and any(c['attention_text'] is None for c in home_cards)
    assert vm[HOME]['status_chip']['promotion_label'] and vm[HOME_NR]['status_chip']['promotion_label'] is None
    assert vm[HOME_NR]['annual_review_link'] is None and vm[HOME]['annual_review_link'] is not None
    by_code = {c['code']: c for c in home_cards}
    for c in (c for g in vm[HOME_VW]['groups'] for c in g['cards']):
        assert by_code[c['code']] == c and c['route'] not in PHONE_ONLY, c['code']
    assert vm[HOME_VW]['status_chip'] == vm[HOME]['status_chip']
    assert vm[HOME_VW]['annual_review_link'] == vm[HOME]['annual_review_link']
    # S07 — 짝 규칙 · 행 5 레벨 5값 · 텔레그램 행 4(캘린더 0) · 잠김 = 동작 칸 0 · 개정 표본.
    for rel in CONNS + [TOKEN_EXP]:
        check_conns(vm[rel], rel)
        for r in vm[rel]['rows']:
            assert ROW_KEYS == list(r), (rel, r['target'])
    assert len(vm[CONN]['rows']) == 5 and {r['level'] for r in vm[CONN]['rows']} == LEVELS
    assert any(r['detail_line'] for r in vm[CONN]['rows'])
    assert len(vm[CONN_TG]['rows']) == 4 and 'CALENDAR' not in [r['target'] for r in vm[CONN_TG]['rows']]
    assert all(r['level'] == 'OK' for r in vm[CONN_TG]['rows'])
    pk = [r['channel_picker'] for r in vm[CONN]['rows'] if r['channel_picker']][0]
    pt = [r['channel_picker'] for r in vm[CONN_TG]['rows'] if r['channel_picker']][0]
    assert pk['token_badge_text'] and pt['token_badge_text'] is None
    assert pk['capability_notice'] != pt['capability_notice']
    assert vm[CONN_LK]['locked_label'] and vm[CONN]['locked_label'] is None and vm[CONN_TG]['locked_label'] is None
    assert [locked(r) for r in vm[CONN]['rows']] == vm[CONN_LK]['rows']
    assert vm[TOKEN_EXP]['locked_label'] is None
    assert any(r['actions'] for r in vm[TOKEN_EXP]['rows'])
    assert envs[TOKEN_EXP]['incident_alert']['code'] == 'BROKER_AUTH_FAILED'
    # 동작 결과 — 5 · 레벨 5값 · 코드 3 + null 2 · 넘김 0 · 재시도 0.
    rs = envs[RESULTS]['rows']
    assert len(rs) == 5 and {r['level'] for r in rs} == LEVELS
    assert sorted(r['reason_code'] for r in rs if r['reason_code']) == sorted(
        ['BIOMETRIC_UNAVAILABLE', 'CONNECTION_TEST_FAILED', 'SYNC_ALREADY_RUNNING'])
    assert all(r['handoff_route'] is None and r['retryable'] is False for r in rs)
    assert all(list(r) == RESULT_KEYS for r in rs)
    # 알림 — 6 코드 전수 각 1 · 등급 = 엔진 · 등급 순.
    al = envs[ALERTS]['rows']
    assert sorted(a['code'] for a in al) == sorted(ENGINE_LEVEL)
    assert all(ENGINE_LEVEL[a['code']] == a['level'] for a in al)
    assert [a['level'] for a in al] == sorted(a['level'] for a in al)

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    n_revised = sum(1 for rel in rels if out[rel] != bump(base_text(rel), rel))
    assert (n_version_only, n_revised) == (239, 1), (n_version_only, n_revised)

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r6_v118_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · contract 1.18.0'
          % (len(out), BASE_FILES, n_version_only, n_revised, len(NEW_FILES)))


if __name__ == '__main__':
    main()
