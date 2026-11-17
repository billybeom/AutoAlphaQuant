#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.23(R8a 선행 — M9 `S13` 월 납입 설정 · 01 §32) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r8_v123_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_v122_fixtures.py(계약 v1.22 · 그 스크립트는 v1.22 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-17_R8선행_계약v1.23_설계서.md` §5 · 298 → 305 = 신설 7 · 개정 0 · 버전 줄만 298)
  (a) 전 봉투의 "contract_version": "1.22.0" → "1.23.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 7 — m9/ `monthly_contribution` · `_pending` · `_no_record` · `_no_limit_note` · `_locked` · `_stale`(VM 6) ·
      `contribution_action_results`(결과 9행).
  (c) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*` · `check_*`.

🔴 돈 수치 0 새로 정함 — 금액 글자는 «10만원»(발주자 결정 2026-09-07 · 엔진 `defaultAmount`) · «0원»(05 «0 = 납입 중단 ·
   정상 값») · «10억원»(엔진 config 상한 자리값 `maxAmount` — `OVER_MAX` 엔진 문장 안) 셋뿐(K99).
   «9만원» 류 = C-32 ⑥ 폐기값(`fixture_conventions_test.dart`)이라 쓰지 않는다.
🔴 엔진 글자가 있는 칸 = 엔진 함수 출력 그대로(원천 = origin/main 33fe351 · 구현 때 엔진 함수를 한 번 돌려 바이트 대조 —
   core `ops/contribution_setting.dart` `contributionSettingOf(rows: 아래 행, todayKst: '2026-11-18',
   observedAtUtc: 2026-11-18T06:00Z, kr: frozenExchangeCalendar(Market.kr))` · `decideContributionChange` 거부 문장 7).
   아래 `VM_TEXT` · `REJECT_TEXT` 가 그 출력이고 `self_check_engine_text` 가 파이썬 거울과 맞댄다.
🔴 접수 headline «(합성) …» · 생체 headline · `change_label` «바꾸기» · `stale_label` · 결과 `level` = 합성(엔진 글자 0 · K101).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r8_v123_fixtures.py
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
# 계약 1.22.0 · 픽스처 298 의 기준 커밋(origin/main · E16t2a #224 — 계약 패키지 = PR #214 이후 무변경).
BASE = '33fe35129c8bb5c17eab5549985ce33cd7f92cb2'

OLD_VER = '"contract_version": "1.22.0"'
NEW_VER = '"contract_version": "1.23.0"'
BASE_FILES = 298
WANT_FILES = 305

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
PNL_WORD = re.compile(r'평가손익|수익률|평가액|손익')
MONEY = re.compile(r'[0-9][0-9,]*(?:억|만)?[0-9,]*원')    # C-57 ⑦ 와 같은 꼴
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PHONE = re.compile(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}')    # C-51 ⑤
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
URL_LIKE = re.compile(r'https?://|github\.com|\.io/')
LONG_DIGITS = re.compile(r'[0-9]{8,}')                     # 8자리 이상 숫자 0
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
LEVELS = {'OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'}
MONEY_OK = {'10만원', '0원', '10억원'}                     # K99 — 신설 7 의 금액 글자 집합 상한

# ── 사전(labels/settings_codes.dart · safety_codes.dart 와 같은 글자 — C-57 ④⑥ 이 다시 본다) ──
CONTRIBUTION = ['CONTRIBUTION_INPUT_BLANK', 'CONTRIBUTION_INPUT_NEGATIVE', 'CONTRIBUTION_INPUT_NOT_NUMBER',
                'CONTRIBUTION_INPUT_OVER_MAX', 'CONTRIBUTION_CLOCK_NOT_ADVANCED', 'CONTRIBUTION_UNCHANGED']
TTU = 'TRUSTED_TIME_UNKNOWN'
BIOMETRIC = 'BIOMETRIC_UNAVAILABLE'
ACTION_ID = 'SETTINGS_CONTRIBUTION_UPDATE'

# ── 이름 ─────────────────────────────────────────────────────────────────
MC = 'm9/monthly_contribution.json'
MC_PENDING = 'm9/monthly_contribution_pending.json'
MC_NO_RECORD = 'm9/monthly_contribution_no_record.json'
MC_NO_LIMIT = 'm9/monthly_contribution_no_limit_note.json'
MC_LOCKED = 'm9/monthly_contribution_locked.json'
MC_STALE = 'm9/monthly_contribution_stale.json'
RESULTS = 'm9/contribution_action_results.json'
VMS = [MC, MC_PENDING, MC_NO_RECORD, MC_NO_LIMIT, MC_LOCKED, MC_STALE]
NEW_FILES = VMS + [RESULTS]
UNTOUCHED = ['m9/contribution_setting_default.json', 'm9/contribution_setting_no_limit_note.json']

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.23.0',
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
AS_S13 = as_of('2026-11-18T06:00:00Z', '2026-11-18', '설정 기준 2026-11-18')   # 엔진 :234 · 26h = asOfStaleAfter
AS_S13R = as_of('2026-11-18T06:05:00Z', '2026-11-18', '동작 기준 2026-11-18')  # 결과 봉투(v1.20 «동작 기준» 꼴)
STALE_LABEL = '월 납입 설정을 다시 읽지 못한 지 오래됐습니다. 화면을 다시 열면 새로 읽습니다.'   # 합성(K101)
LOCKED = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.'   # v1.20·v1.21 표본과 같은 글자
CHANGE = '바꾸기'   # 합성(K101 · 버튼 글자 = 엔진·조립 몫)

# ── 엔진 입력 행(`operating_param_log` · 표본에는 싣지 않는다 — 아래 파이썬 거울과 엔진 대조의 입력) ──
#    (amount, changed_at UTC, effective_from = core `contributionEffectiveFrom`(frozen XKRX) · 뜻)
R_SET = (100000, '2026-09-07T01:00:00Z', '2026-10-01')          # 발주자 결정 «10만원»(실물 날짜)
R_PAUSED = (0, '2026-10-06T01:00:00Z', '2026-11-02')            # 납입 멈춤(합성 · 05 «0 = 정상 값» · 10-05 대체공휴일)
R_PAUSE_NEXT = (0, '2026-11-17T01:00:00Z', '2026-12-01')        # 다음 주기부터 멈춤 예정(합성)
TODAY = '2026-11-18'
NEXT_CYCLE = '2026-12-01'   # nextContributionDay(XKRX, 2026-11-18) — 11월 첫 세션 11-02 뒤라 12월 첫 세션
DEFAULT_AMOUNT = 100000     # 엔진 p0sContributionConfig().defaultAmount(발주자 2026-09-07)
EQUIVALENT_AMOUNT = 10 ** 5 - 3 * 10 ** 3   # 엔진 equivalentAmount(글자로 적지 않는다 — C-32 ⑥ 폐기값과 같은 숫자)
MAX_AMOUNT = 10 ** 9        # 엔진 maxAmount(config 상한 자리값 · 05 §8-16 발주자 숫자 대기)
PENSION_LIMIT = 18 * 10 ** 6
TAX_BAND = 9 * 10 ** 6


# ── 엔진 문장 함수의 파이썬 거울(core `ops/contribution_setting.dart` · `whatif/what_if_text.dart` wonText · 33fe351) ──
def won_text(n):
    """wonText 의 이 표본 범위 거울 — 0 · 만 단위 · 억 단위(나머지 0) 만."""
    if n == 0:
        return '0원'
    if n % 10 ** 8 == 0:
        return '%d억원' % (n // 10 ** 8)
    assert n % 10 ** 4 == 0 and n < 10 ** 8, n
    return '%d만원' % (n // 10 ** 4)


def month_day(ymd):
    return '%d월 %d일' % (int(ymd[5:7]), int(ymd[8:10]))


def setting_of(rows):
    """contributionSettingOf 의 거울 — rows = 위 행 튜플 목록(changed_at 차례 = 목록 차례)."""
    current = None
    pending = None
    for r in rows:
        if r[2] <= TODAY:
            if current is None or r[1] > current[1]:
                current = r
        elif pending is None or r[1] > pending[1]:
            pending = r
    if pending is not None and current is not None and not pending[1] > current[1]:
        pending = None
    amount = current[0] if current else DEFAULT_AMOUNT
    latest = max(rows, key=lambda r: r[1]) if rows else None
    if pending is not None:
        applies = '다음 납입 주기(%s)부터 %s이 적용됩니다.' % (month_day(pending[2]), won_text(pending[0]))
    else:
        applies = '다음 납입 주기(%s)부터 이 금액이 적용됩니다.' % month_day(NEXT_CYCLE)
    if latest is None:
        last = '변경 기록 없음(기본값)'
    else:
        before = [r for r in rows if r[1] < latest[1]]
        frm = max(before, key=lambda r: r[1])[0] if before else DEFAULT_AMOUNT
        day = latest[1][:10]   # 표본 행은 전부 KST 10:00 = UTC 01:00 → 같은 날
        last = ('최근 변경: %s · %s으로 정함' % (day, won_text(latest[0])) if frm == latest[0]
                else '최근 변경: %s · %s → %s' % (day, won_text(frm), won_text(latest[0])))
    eq = '12% 등가 납입액 대비 충족합니다.' if amount >= EQUIVALENT_AMOUNT else '12% 등가 납입액 대비 부족합니다.'
    if amount <= 0:
        pension = None
    elif amount * 12 > PENSION_LIMIT or amount * 12 > TAX_BAND:
        raise AssertionError('표본 범위 밖(한도 넘는 문장)')
    else:
        pension = '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.'
    return {
        'amount_text': won_text(amount),
        'amount_input_text': str(amount),
        'equivalent_note_text': eq,
        'applies_from_text': applies,
        'last_changed_text': last,
        'pension_limit_note_text': pension,
    }


# ── 엔진 출력(scratchpad 일회성 Dart 로 `contributionSettingOf` 를 돌린 바이트 · 33fe351) — 거울과 맞댄다 ──
VM_TEXT = {
    MC: {
        'amount_text': '10만원', 'amount_input_text': '100000',
        'equivalent_note_text': '12% 등가 납입액 대비 충족합니다.',
        'applies_from_text': '다음 납입 주기(12월 1일)부터 이 금액이 적용됩니다.',
        'last_changed_text': '최근 변경: 2026-09-07 · 10만원으로 정함',
        'pension_limit_note_text': '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.',
    },
    MC_PENDING: {
        'amount_text': '10만원', 'amount_input_text': '100000',
        'equivalent_note_text': '12% 등가 납입액 대비 충족합니다.',
        'applies_from_text': '다음 납입 주기(12월 1일)부터 0원이 적용됩니다.',
        'last_changed_text': '최근 변경: 2026-11-17 · 10만원 → 0원',
        'pension_limit_note_text': '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.',
    },
    MC_NO_RECORD: {
        'amount_text': '10만원', 'amount_input_text': '100000',
        'equivalent_note_text': '12% 등가 납입액 대비 충족합니다.',
        'applies_from_text': '다음 납입 주기(12월 1일)부터 이 금액이 적용됩니다.',
        'last_changed_text': '변경 기록 없음(기본값)',
        'pension_limit_note_text': '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.',
    },
    MC_NO_LIMIT: {
        'amount_text': '0원', 'amount_input_text': '0',
        'equivalent_note_text': '12% 등가 납입액 대비 부족합니다.',
        'applies_from_text': '다음 납입 주기(12월 1일)부터 이 금액이 적용됩니다.',
        'last_changed_text': '최근 변경: 2026-10-06 · 10만원 → 0원',
        'pension_limit_note_text': None,
    },
}
VM_ROWS = {MC: [R_SET], MC_PENDING: [R_SET, R_PAUSE_NEXT], MC_NO_RECORD: [], MC_NO_LIMIT: [R_SET, R_PAUSED]}

# ── 엔진 거부 문장(core `decideContributionChange` :320 · 323 · 326 · 332 · 338 · 346 · 351 출력 그대로) ──
REJECT_TEXT = {
    'CONTRIBUTION_INPUT_BLANK': '금액을 입력해 주세요.',
    'CONTRIBUTION_INPUT_NEGATIVE': '0원 이상으로 입력해 주세요.',
    'CONTRIBUTION_INPUT_NOT_NUMBER': '금액을 원 단위 숫자로 입력해 주세요.',
    'CONTRIBUTION_INPUT_OVER_MAX': '%s까지 입력할 수 있습니다.' % won_text(MAX_AMOUNT),
    TTU: '서버 시각을 확인하지 못해 지금은 바꿀 수 없습니다. 연결을 확인한 뒤 다시 시도해 주세요.',
    'CONTRIBUTION_CLOCK_NOT_ADVANCED': '방금 바뀐 기록이 있습니다. 잠시 뒤 다시 시도해 주세요.',
    'CONTRIBUTION_UNCHANGED': '지금 금액과 같습니다.',
}
OVER_MAX_ENGINE = '10억원까지 입력할 수 있습니다.'   # 엔진 출력 바이트(scratchpad 대조)

VM_KEYS = ['amount_text', 'amount_input_text', 'equivalent_note_text', 'applies_from_text', 'last_changed_text',
           'editable', 'pension_limit_note_text', 'as_of', 'locked_label', 'change_label']
RESULT_KEYS = ['action_run_id', 'id', 'level', 'headline', 'reason_code', 'handoff_route', 'retryable']
# 차례 = 구현 생체 → 엔진 판정 차례(빈칸 → 음수 → 숫자 아님 → 상한 → 신뢰 시각 → 시계 전진 → 같은 값) · 레벨 = 합성 5값 전수.
RESULT_PLAN = [
    ('OK', None, '(합성) 새 금액을 접수했습니다. 다음 납입 주기부터 적용됩니다.'),
    ('BLOCKED', BIOMETRIC, '생체 확인이 없어 바꾸지 않았습니다.'),
    ('ACT', 'CONTRIBUTION_INPUT_BLANK', None),
    ('ACT', 'CONTRIBUTION_INPUT_NEGATIVE', None),
    ('ACT', 'CONTRIBUTION_INPUT_NOT_NUMBER', None),
    ('ACT', 'CONTRIBUTION_INPUT_OVER_MAX', None),
    ('BLOCKED', TTU, None),
    ('WATCH', 'CONTRIBUTION_CLOCK_NOT_ADVANCED', None),
    ('INFO', 'CONTRIBUTION_UNCHANGED', None),
]


def self_check_engine_text():
    for rel, rows in VM_ROWS.items():
        assert setting_of(rows) == VM_TEXT[rel], (rel, setting_of(rows), VM_TEXT[rel])
    assert REJECT_TEXT['CONTRIBUTION_INPUT_OVER_MAX'] == OVER_MAX_ENGINE
    assert set(REJECT_TEXT) == set(CONTRIBUTION) | {TTU}


def vm(rel, as_of_vm=None, locked=False):
    text = VM_TEXT[rel]
    out = {k: None for k in VM_KEYS}
    for k, v in text.items():
        out[k] = v
    out['as_of'] = copy.deepcopy(as_of_vm or AS_S13)
    out['locked_label'] = LOCKED if locked else None
    out['change_label'] = None if locked else CHANGE
    out['editable'] = out['change_label'] is not None   # C-57 ③ 표식
    assert list(out) == VM_KEYS
    return out


def build_vms():
    stale = dict(copy.deepcopy(AS_S13), stale_label=STALE_LABEL)
    base = vm(MC)
    locked = vm(MC, locked=True)
    stale_vm = vm(MC, as_of_vm=stale)
    return {
        MC: base,
        MC_PENDING: vm(MC_PENDING),
        MC_NO_RECORD: vm(MC_NO_RECORD),
        MC_NO_LIMIT: vm(MC_NO_LIMIT),
        MC_LOCKED: locked,
        MC_STALE: stale_vm,
    }


def build_results():
    rows = []
    for n, (level, code, headline) in enumerate(RESULT_PLAN, 1):
        h = headline if headline is not None else REJECT_TEXT[code]
        rows.append(dict(zip(RESULT_KEYS, ['ar_s13_%02d' % n, ACTION_ID, level, h, code, None, False])))
    return rows


# ────────────────────────────────────────────────────────────────────────
# 직렬화(gen_v122_fixtures.py 와 같은 꼴 — VM 행은 키마다 한 줄 · 결과 행도 키마다 한 줄)
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
    """봉투(v1.15~v1.22 선례) — 최상위 as_of = 갈래 기준 글자 · 형제 키 0."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': copy.deepcopy(rows)}


def new_files():
    texts = {}
    for rel, row in build_vms().items():
        texts[rel] = ser_envelope(envelope([row], AS_S13), True)
    texts[RESULTS] = ser_envelope(envelope(build_results(), AS_S13R), True)
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


CHECKS = (('금지어', FORBIDDEN), ('개발자 메모', DEV_MEMO), ('계좌꼴', ACCOUNT_LIKE), ('전화번호 꼴', PHONE),
          ('앱키 꼴', LONG_ALNUM), ('URL 꼴', URL_LIKE), ('8자리 숫자', LONG_DIGITS), ('손익 낱말', PNL_WORD))


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
        assert env['meta'] == NEW_META, rel
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
            for name, rx in CHECKS:
                assert not rx.search(v), '%s %s — %s: %s' % (rel, path, name, v)
            assert 'DRY_RUN' not in v, (rel, path, v)
            assert not v.startswith('aaq://'), (rel, path, v)                          # 링크 칸 0
            for m in MONEY.findall(v):
                assert m in MONEY_OK, '%s %s — 금액 글자 %s' % (rel, path, m)          # K99
        ks = set(keys(env['rows']))
        assert not any(PNL_KEY.search(k) for k in ks), rel
    return env


def check_vm(rel, row):
    assert list(row) == VM_KEYS, rel
    assert row['editable'] == (row['change_label'] is not None), rel                 # C-57 ③
    if row['locked_label'] is not None:
        assert row['change_label'] is None, rel                                        # C-57 ②
    for k, v in VM_TEXT[{MC_LOCKED: MC, MC_STALE: MC}.get(rel, rel)].items():
        assert row[k] == v, (rel, k)


def check_results(rows):
    assert len(rows) == 9 and all(list(r) == RESULT_KEYS for r in rows)
    assert [r['action_run_id'] for r in rows] == ['ar_s13_%02d' % i for i in range(1, 10)]
    assert {r['id'] for r in rows} == {ACTION_ID}
    assert all(r['handoff_route'] is None and r['retryable'] is False for r in rows)
    assert {r['level'] for r in rows} == LEVELS
    assert {r['reason_code'] for r in rows} == set(CONTRIBUTION) | {TTU, BIOMETRIC, None}
    for r in rows:
        if r['reason_code'] in REJECT_TEXT:
            assert r['headline'] == REJECT_TEXT[r['reason_code']], r
        if r['reason_code'] is None:
            assert r['headline'].startswith('(합성)'), r


def main():
    self_check_engine_text()
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert all(u in rels for u in UNTOUCHED)
    assert len(NEW_FILES) == 7 and len(set(NEW_FILES)) == 7

    out = new_files()
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES) for rel, s in out.items()}
    one = {rel: envs[rel]['rows'][0] for rel in VMS}
    for rel in VMS:
        assert len(envs[rel]['rows']) == 1 and envs[rel]['as_of'] == AS_S13, rel
        check_vm(rel, one[rel])
    # C-57 ⑨ 변종 동치.
    lk = dict(one[MC_LOCKED], locked_label=None, change_label=CHANGE, editable=True)
    assert lk == one[MC] and one[MC_LOCKED]['locked_label'] == LOCKED
    st = dict(one[MC_STALE], as_of=AS_S13)
    assert st == one[MC] and one[MC_STALE]['as_of']['stale_label'] == STALE_LABEL
    assert sum(1 for rel in VMS if 'stale_label' in one[rel]['as_of']) == 1
    nr = dict(one[MC_NO_RECORD], last_changed_text=one[MC]['last_changed_text'])
    assert nr == one[MC] and one[MC_NO_RECORD]['last_changed_text'] == '변경 기록 없음(기본값)'
    # C-57 ⑧ 예정 = 지금 값 그대로.
    assert one[MC_PENDING]['amount_text'] == one[MC]['amount_text']
    ap = MONEY.findall(one[MC_PENDING]['applies_from_text'])
    assert len(ap) == 1 and ap[0] != one[MC_PENDING]['amount_text']
    for rel in VMS:
        if rel != MC_PENDING:
            assert not MONEY.findall(one[rel]['applies_from_text']), rel
    check_results(envs[RESULTS]['rows'])

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
    print('gen_r8_v123_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 %d) · contract 1.23.0'
          % (len(out), BASE_FILES, n_version_only, len(NEW_FILES)))


if __name__ == '__main__':
    main()
