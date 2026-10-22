#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.12(R5·R13 선행 M2 보강 · 01 §21) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r5r13_v112_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_h6_v18_fixtures.py(계약 v1.8 · 그 스크립트는 v1.8 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-10-22_R5R13선행_계약v1.12_설계서.md` §5 · 159 → 174 = 신설 15 · 개정 22 · 버전 줄만 137)
  🆕 검증 반영(2026-10-22) — 건수는 **바이트 결과**로 센다: 설계서 §5 의 «개정 23 · 버전 줄만 136» 은 목록 크기였고,
     목록의 R8 `m6/advice_handover_cooling` 은 행 0 · 요약 새 필드 전부 부재(냉각 창 = 수기 기록 링크 null)라 결과가
     버전 줄 한 줄뿐이다 → 실측 = 개정 22 · 버전 줄만 137(목록 23 은 그대로 두고 둘을 함께 찍는다 · 아래 `main` 단언).
  (a) 전 봉투의 "contract_version": "1.11.0" → "1.12.0" 한 줄 치환(다른 글자 불변 · 136건 + 목록상 개정이지만 결과가
      같은 cooling 1건 = 137).
  (b) 개정 22(목록 23) — R1 ledger_diffs_4(+8 표시 키) · R2~R8 m6/advice_* 인박스 7벌(DETAIL 삭제 · deep_link · detail_deep_link ·
      side_label · expired_confirm_label · decision_link · prefill_* · close_reason_label · 요약 링크·현금 고지) ·
      R9~R10 advice_detail_* · R11 advice_skip_reasons(requires_note K22 · 예산 2종 deep_link) · R12~R13 fill_form_spec(_stale)
      (+sides · trade_date_options · skip_notice_text) · R14 fill_rejected_price(retry_code · prefilled_fields) ·
      R15 self_report_1(꼴 교체 → SelfReportSession) · R16 draft_records_x7(L-3 키 `<yyyy-MM>/<별칭>`) ·
      R17~R22 알림·리듬·안전 상태·인시던트(옛 링크 7곳 · 등급 5행 — 미결 114) · R23 ops_home_resume_gap7(resume_line).
  (c) 신설 15 — m6/ledger_repairs_4 · ledger_repairs_empty · ledger_diffs_cash_observe · self_report_diff_result ·
      self_report_session_closed · self_report_receipts_5 · manual_fill_receipts_7 · advice_skip_receipts_5 ·
      advice_defer_receipts_3 · fill_form_spec_blocked · safety_advice_blocked · advice_stale · advice_fills_ad0005 ·
      m7/ledger_trust_self_audit_due · m8/ops_rhythm_empty.
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 발주자 결정(2026-10-22 · 🔴 8건 K9·K14·K18·K30·K35·K36·K46·K47 전부 권고대로 · 나머지 기술 권고 권고대로) 반영:
  - K5·K6 — 액션 = RECORD·SKIP 만(DETAIL 삭제 · 상세 = detail_deep_link) · 뷰어 actions = [] 전 행.
  - K7·K36 ⓐ — `L-3` 링크 = `aaq://ledger/self-report/<yyyy-MM>/<계좌 별칭>` · 초안 키 `2026-08/연금저축`.
  - K13 — 만료 확인 카드 ≤3 · 맨 앞 · [RECORD, SKIP] · 확인 카드 밖 미분류 만료는 인박스 행에 없다(요약 링크로만).
    🔵 확인 카드의 RECORD 는 **누를 수 있다**(02 §3-6 「기록한다」(→ A-3) · 만료 뒤 기록 = 지연 이행으로 받는다 A4) —
       옛 행의 «유효기한이 지나 기록할 수 없습니다»(비활성)는 확인 카드에서 지운다 · 버튼 글자 = 02 «기록한다»·«안 했다».
  - K14 ⓐ — DEFER_ADVICE_CONFIRM 접수증 3행(거부 = DEFER_ALREADY_USED).
  - K22 — requires_note = 예산 코드 2종(PRICE_UNACCEPTABLE·INTENTIONAL_PAUSE)만 true · 그 둘만 deep_link = m5/intervention.
  - K23 — 옛 라벨 정정 0(필드만 더하는 개정은 라벨 무변경 · 새로 쓰는 표본만 SPEC 이름 · 짝 표본은 짝의 글자 그대로).
  - K32 — 등급 5행(alerts_12 al_0010·0011·0012 → P1 · alerts_digest al_d_03 = CONTRIBUTION_CHANGED 글자 · incident → P0).
  🔵 meta `notice` 는 C-1 이 01 §5 문장 하나로 고정한다 — 표식은 fixtures/README «계약 v1.12» 절과 이 주석에 둔다.

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
날짜·수량·가격·금액은 **합성 데이터**다(실계좌 아님 · 둥근 값 · 원천 픽스처끼리 맞댄다).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r5r13_v112_fixtures.py
"""
import copy
import datetime
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
# 계약 1.11.0 · 픽스처 159 의 기준 커밋(origin/main · 엔진 PR #67 E7b3 — 계약 패키지 = v1.11 PR #65 be99c82 와 같다).
BASE = 'f54f602f2ed712b71f9c2034b2f52c0a9a84d589'

OLD_VER = '"contract_version": "1.11.0"'
NEW_VER = '"contract_version": "1.12.0"'
BASE_FILES = 159
WANT_FILES = 174

NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.12.0",
    "generated_at": "2026-10-22T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20261022,
    "notice": "합성 데이터. 실계좌·실키 없음."
  },'''

# fixture_conventions_test.dart `_retiredContributionValues` 와 같은 정규식(폐기 운영값).
RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널')       # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'화면이|화면은|화면·')           # 사용자 문장 자리의 개발자 메모(H50)
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']

# ── 링크(엔진 완성 꼴만 · 설계서 §5-0) ─────────────────────────────────────
R_FILL = 'aaq://advice/fill/'
R_SKIP = 'aaq://advice/skip/'
R_DETAIL = 'aaq://advice/detail/'
R_HISTORY = 'aaq://advice/history'
R_DECISION = 'aaq://journal/decision/'
R_SELF_REPORT = 'aaq://ledger/self-report/'
R_REPAIR = 'aaq://x5/repair-wizard'
R_RESOLVE = 'aaq://m5/self-audit-resolve'
R_INTERVENTION = 'aaq://m5/intervention'
R_RESUME = 'aaq://x2/resume-report'
OLD_FILL = 'aaq://advice/fill'
OLD_SELF_REPORT = 'aaq://ledger/self-report'

# ── 이름 ─────────────────────────────────────────────────────────────────
N_REPAIRS4 = 'm6/ledger_repairs_4.json'
N_REPAIRS_EMPTY = 'm6/ledger_repairs_empty.json'
N_CASH_OBSERVE = 'm6/ledger_diffs_cash_observe.json'
N_SR_RESULT = 'm6/self_report_diff_result.json'
N_SR_CLOSED = 'm6/self_report_session_closed.json'
N_SR_RECEIPTS = 'm6/self_report_receipts_5.json'
N_MF_RECEIPTS = 'm6/manual_fill_receipts_7.json'
N_SKIP_RECEIPTS = 'm6/advice_skip_receipts_5.json'
N_DEFER_RECEIPTS = 'm6/advice_defer_receipts_3.json'
N_SPEC_BLOCKED = 'm6/fill_form_spec_blocked.json'
N_RHYTHM_EMPTY = 'm8/ops_rhythm_empty.json'
N_SAFETY_BLOCKED = 'm6/safety_advice_blocked.json'
N_STALE = 'm6/advice_stale.json'
N_FILLS_AD5 = 'm6/advice_fills_ad0005.json'
N_TRUST_DUE = 'm7/ledger_trust_self_audit_due.json'
NEW_FILES = [N_REPAIRS4, N_REPAIRS_EMPTY, N_CASH_OBSERVE, N_SR_RESULT, N_SR_CLOSED, N_SR_RECEIPTS, N_MF_RECEIPTS,
             N_SKIP_RECEIPTS, N_DEFER_RECEIPTS, N_SPEC_BLOCKED, N_RHYTHM_EMPTY, N_SAFETY_BLOCKED, N_STALE,
             N_FILLS_AD5, N_TRUST_DUE]

LEDGER_DIFFS4 = 'ledger_diffs_4.json'
ADVICE12 = 'm6/advice_12.json'
ADVICE_EMPTY = 'm6/advice_empty.json'
ADVICE_BLOCKED = 'm6/advice_blocked.json'
ADVICE_EXPIRED = 'm6/advice_expired_confirm.json'
ADVICE_VIEWER = 'm6/advice_viewer_4.json'
ADVICE_NO_ACTION = 'm6/advice_no_action.json'
ADVICE_COOLING = 'm6/advice_handover_cooling.json'
DETAIL_PARTIAL = 'm6/advice_detail_partial.json'
DETAIL_ONHOLD = 'm6/advice_detail_onhold.json'
SKIP_REASONS = 'm6/advice_skip_reasons.json'
FORM_SPEC = 'm6/fill_form_spec.json'
FORM_SPEC_STALE = 'm6/fill_form_spec_stale.json'
FILL_REJECTED = 'm6/fill_rejected_price.json'
SELF_REPORT1 = 'm6/self_report_1.json'
DRAFTS_X7 = 'm6/draft_records_x7.json'
ALERTS12 = 'alerts_12.json'
ALERTS_DIGEST = 'm8/alerts_digest.json'
ALERTS_9 = 'm8/alerts_advice_9codes.json'
RHYTHM_ROWS = 'm8/ops_rhythm_rows.json'
SAFETY_STATES = 'safety_states.json'
INCIDENT = 'm8/incident_token_expired.json'
RESUME_GAP7 = 'm8/ops_home_resume_gap7.json'
INBOX = [ADVICE12, ADVICE_EMPTY, ADVICE_BLOCKED, ADVICE_EXPIRED, ADVICE_VIEWER, ADVICE_NO_ACTION, ADVICE_COOLING]
DETAILS = [DETAIL_PARTIAL, DETAIL_ONHOLD]
REVISED = [LEDGER_DIFFS4] + INBOX + DETAILS + [SKIP_REASONS, FORM_SPEC, FORM_SPEC_STALE, FILL_REJECTED, SELF_REPORT1,
                                              DRAFTS_X7, ALERTS12, ALERTS_DIGEST, ALERTS_9, RHYTHM_ROWS, SAFETY_STATES,
                                              INCIDENT, RESUME_GAP7]
assert len(REVISED) == 23 and len(NEW_FILES) == 15

RECON_BOARD = 'm8/recon_board_diff.json'
DEPOSIT_PLAN1 = 'deposit_plan_1.json'
TRUST4 = 'm7/ledger_trust_4.json'
OPS_HOMES = ['m8/ops_home_normal.json', 'm8/ops_home_blocked.json', 'm8/ops_home_advice_open.json',
             'm8/ops_home_advice_zero.json', RESUME_GAP7]

# ── 문장(엔진 문장 예시 · 설계서 §4·§5 · 02 §3-6~§3-10·§5) ─────────────────
SIDE_LABEL = {'BUY': '매수', 'SELL': '매도'}
EXPIRED_CONFIRM = '혹시 이미 매매하셨나요?'
CONFIRM_RECORD = '기록한다'          # 02 §3-6 확인 카드 1탭 분류
CONFIRM_SKIP = '안 했다'
DECISION_LINK_LABEL = '결정 당시 근거 보기'
PREFILL_LABEL = '안내 수량({}주) 채우기'
CLOSE_REASON_LABEL = {
    'HANDOVER_CLOSED': '집행 주체 전환으로 회수된 안내입니다 — 사람 잘못이 아니며 재량 예산을 쓰지 않습니다',
}
MANUAL_ENTRY_LINK = {'label': '안내에 없는 매매를 기록합니다', 'deep_link': R_INTERVENTION}
# 🔵 «재량 예산 n회» 의 n = m8/ops_home_* 의 `discretion_budget_text`(«2회 중») 와 맞댄다(픽스처끼리).
MANUAL_ENTRY_NOTICE = '이 기록은 안내 밖 매매로 남고 이번 달 재량 예산 2회 중 1회를 씁니다'
CASH_NOTICE = {'is_estimate': True, 'label': '현금은 기록 기반 추정치입니다 · 마지막 확인 8/31',
               'last_confirmed_on': '2026-08-31'}
OVERDUE_LINK_LABEL = '미확인 만료 {}건 — 지난 안내에서 정리하십시오'
SKIP_NOTICE = '이 안내는 오늘로 닫히고, 다음 배치는 지금 보유 상태로 다시 계산합니다'
BUDGET_CODES = ('PRICE_UNACCEPTABLE', 'INTENTIONAL_PAUSE')   # 02 §3-9 표 · 06:238 — 예산 코드 2종
RETRY = {
    'OFF_HOUR_TRADE': '시간외·단주 신고로 다시 제출',
    'DUPLICATE_ACK': '같은 체결이 아닙니다 — 다시 제출',
}
STALE_LABEL = '엔진이 3거래일 멈춰 있습니다 — 안내의 유효성을 보증할 수 없습니다'

PAIR_AXIS_LABEL = {'QUANTITY': '수량', 'EXECUTION_ROW': '체결 건', 'CASH': '현금', 'CHAIN_HASH': '체인 해시'}
SEVERITY_LABEL = {'BLOCKING': '주문 차단', 'OBSERVATIONAL': '관측 항목 — 주문을 막지 않습니다'}
ROUTE_LABEL = {'AUTO': '자동 재동기화', 'APPROVAL': '승인 필요', 'X1_EMERGENCY': 'X1 비상'}
ORIGIN_LABEL = {
    'FILL_LAG': '체결 반영 지연',          # m6/journal_draft_spec_recon_clear 의 같은 code 칩 글자
    'MANUAL_ORDER': '수동 주문',
    'PUSH_LAG': '미러 전송 지연',
    'ARCHIVE_LAG': '아카이브 적체',
    'CAL_WRITE_FAILED': '캘린더 쓰기 실패',
    'EXTERNAL_CASHFLOW': '시스템 밖 입출금',
    'SELF_REPORT_CORRECTION': '실사 보고와 원장이 다름',
    'UNRECORDED_FILL': '기록되지 않은 체결',
}
ORIGIN_HANDBOOK = {'FILL_LAG': 'handbook://unknown/resolve'}   # 같은 칩의 기존 링크(지어내지 않는다)

ACCOUNTS = None   # main() 에서 fill_form_spec 의 accounts 로 채운다(별칭 = 링크 · 초안 키의 원천)


# ────────────────────────────────────────────────────────────────────────
# 파일 입출력
# ────────────────────────────────────────────────────────────────────────
def git(*args):
    return subprocess.check_output(['git', '-C', ROOT] + list(args)).decode('utf-8')


_BASE_CACHE = {}


def base_text(rel):
    if rel not in _BASE_CACHE:
        s = git('show', '%s:%s/%s' % (BASE, FX_REL, rel))
        assert '\r' not in s, rel
        _BASE_CACHE[rel] = s
    return _BASE_CACHE[rel]


def base_env(rel):
    return json.loads(base_text(rel))


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def meta_text(s):
    lines = s.split('\n')
    i = lines.index('  "meta": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '  },')
    return '\n'.join(lines[i:j + 1])


def body_without_meta(s):
    lines = s.split('\n')
    i = lines.index('  "meta": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '  },')
    return '\n'.join(lines[:i] + lines[j + 1:])


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def replace_once(s, rel, old, new):
    assert s.count(old) == 1, (rel, old, s.count(old))
    return s.replace(old, new, 1)


# ────────────────────────────────────────────────────────────────────────
# 렌더러 — gen_h6_v18_fixtures.py 와 같은 꼴(평평한 객체 = 한 줄 · 행 = 여러 줄 · 평평한 객체 목록 = 한 줄씩)
# ────────────────────────────────────────────────────────────────────────
def dumps(v):
    return json.dumps(v, ensure_ascii=False)


def is_flat(d):
    return all(not isinstance(v, (dict, list)) for v in d.values())


def inline(d):
    return '{ ' + ', '.join('%s: %s' % (dumps(k), dumps(v)) for k, v in d.items()) + ' }'


def rv(v, ind):
    pad = ' ' * ind
    if isinstance(v, dict):
        if v and is_flat(v):
            return inline(v)
        return '{\n' + ',\n'.join('%s  %s: %s' % (pad, dumps(k), rv(x, ind + 2))
                                  for k, x in v.items()) + '\n%s}' % pad
    if isinstance(v, list):
        if not v:
            return '[]'
        if all(not isinstance(x, (dict, list)) for x in v):
            return dumps(v)
        return '[\n' + ',\n'.join('%s  %s' % (pad, rv(x, ind + 2)) for x in v) + '\n%s]' % pad
    return dumps(v)


def rows_block(rows):
    if not rows:
        return '[]'
    out = []
    for r in rows:
        assert isinstance(r, dict)
        out.append('    {\n' + ',\n'.join('      %s: %s' % (dumps(k), rv(x, 6)) for k, x in r.items())
                   + '\n    }')
    return '[\n' + ',\n'.join(out) + '\n  ]'


def render(meta, env):
    body = []
    for k, v in env.items():
        if k == 'meta':
            continue
        if k == 'rows':
            body.append('  "rows": %s' % rows_block(v))
        else:
            body.append('  %s: %s' % (dumps(k), rv(v, 2)))
    return '{\n' + meta + '\n' + ',\n'.join(body) + '\n}\n'


def rerender(rel, env):
    """개정 — 기준 원문이 렌더러와 바이트 같다는 것을 먼저 확인하고(원문 꼴 보존) 바꾼 봉투를 다시 그린다."""
    s = base_text(rel)
    assert render(meta_text(s), base_env(rel)) == s, '%s — 렌더러 왕복이 원문과 다르다(텍스트 치환으로 고칠 것)' % rel
    return render(meta_text(bump(s, rel)), env)


def envelope(as_of, rows, empty_kind='NO_DATA', empty_label=None):
    return {'meta': None, 'as_of': as_of, 'empty_kind': empty_kind, 'empty_label': empty_label,
            'has_more': False, 'rows': rows}


def as_of(label, observed='2026-08-31T09:00:00Z', trade_date='2026-08-31'):
    return {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': label}


def with_after(d, after_key, items):
    """[after_key] 바로 뒤에 items(순서 있는 (키, 값) 목록)를 끼운다. after_key 가 없으면 끝에."""
    out = {}
    for k, v in d.items():
        out[k] = v
        if k == after_key:
            for nk, nv in items:
                out[nk] = nv
    if after_key not in d:
        for nk, nv in items:
            out[nk] = nv
    return out


def with_before(d, before_key, items):
    """[before_key] 바로 앞에 끼운다. 없으면 끝에."""
    out = {}
    for k, v in d.items():
        if k == before_key:
            for nk, nv in items:
                out[nk] = nv
        out[k] = v
    if before_key not in d:
        for nk, nv in items:
            out[nk] = nv
    return out


# ────────────────────────────────────────────────────────────────────────
# 안내 행(R2~R10 · N13) — K5·K6·K13·K16·K18·K19·K39
# ────────────────────────────────────────────────────────────────────────
def action(action_id, adv_id, label, enabled=True, disabled_reason=None):
    a = {'action_id': action_id, 'label': label, 'enabled': enabled}
    if disabled_reason is not None:
        a['disabled_reason_label'] = disabled_reason
    a['deep_link'] = (R_FILL if action_id == 'RECORD' else R_SKIP) + adv_id
    return a


def advice_row(r, viewer=False, confirm=False, record_only=False):
    r = copy.deepcopy(r)
    aid = r['advice_id']
    if viewer:
        acts = []
    elif confirm:
        acts = [action('RECORD', aid, CONFIRM_RECORD), action('SKIP', aid, CONFIRM_SKIP)]
    else:
        acts = []
        for a in r['actions']:
            if a['action_id'] == 'DETAIL':
                continue
            if record_only and a['action_id'] != 'RECORD':
                continue
            acts.append(action(a['action_id'], aid, a['label'], a['enabled'], a.get('disabled_reason_label')))
    r['actions'] = acts
    phone = not viewer
    if phone and r.get('side') is not None:
        r = with_after(r, 'side', [('side_label', SIDE_LABEL[r['side']])])
    if r.get('close_reason_code') is not None:
        r = with_after(r, 'close_reason_code', [('close_reason_label', CLOSE_REASON_LABEL[r['close_reason_code']])])
    tail = []
    if 'decision' in r:
        r = with_after(r, 'decision', [('decision_link', {'label': DECISION_LINK_LABEL,
                                                          'deep_link': R_DECISION + r['decision']['decision_id']})])
    tail.append(('detail_deep_link', R_DETAIL + aid))
    if confirm:
        tail.append(('expired_confirm_label', EXPIRED_CONFIRM))
    if (phone and r['effective_status'] in ('OPEN', 'PARTIAL') and isinstance(r.get('quantity'), int)
            and r['kind'] != 'NO_ACTION'):
        tail.append(('prefill_quantity_text', str(r['quantity'])))
        tail.append(('prefill_quantity_label', PREFILL_LABEL.format(r['quantity'])))
    return with_before(r, 'as_of', tail)


def summary_v112(s, manual_entry=False, cash=False, overdue_link_n=None):
    s = copy.deepcopy(s)
    tail = []
    if cash:
        tail.append(('cash_notice', dict(CASH_NOTICE)))
    if overdue_link_n:
        tail.append(('overdue_unrecorded_link', {'label': OVERDUE_LINK_LABEL.format(overdue_link_n),
                                                 'deep_link': R_HISTORY}))
    if manual_entry:
        tail.append(('manual_entry_link', dict(MANUAL_ENTRY_LINK)))
        tail.append(('manual_entry_notice_text', MANUAL_ENTRY_NOTICE))
    return with_before(s, 'as_of', tail)


def revise_inbox(rel):
    env = base_env(rel)
    viewer = rel == ADVICE_VIEWER
    rows = env['rows']
    confirm_ids = [r['advice_id'] for r in rows if r['effective_status'] == 'EXPIRED'] if not viewer else []
    if rel == ADVICE_EXPIRED:
        # +1 만료 행(ad_0203 — ad_0202 글자 복제 · id·decision 만 새로) → 확인 카드 3장(K13 · C16 «최대 3장»).
        extra = copy.deepcopy(rows[-1])
        assert extra['advice_id'] == 'ad_0202'
        extra['advice_id'] = 'ad_0203'
        extra['decision'] = dict(extra['decision'], decision_id='d_ad_0203', intent_id='i_ad_0203')
        rows = rows + [extra]
        confirm_ids = [r['advice_id'] for r in rows]
    assert len(confirm_ids) <= 3, (rel, confirm_ids)
    new_rows = [advice_row(r, viewer=viewer, confirm=r['advice_id'] in confirm_ids) for r in rows]
    if rel == ADVICE12:
        # 🔴 정렬 = 엔진(K13) — 확인 카드 → is_urgent → 나머지(기존 순서).
        cards = [r for r in new_rows if 'expired_confirm_label' in r]
        urgent = [r for r in new_rows if r['is_urgent'] and 'expired_confirm_label' not in r]
        rest = [r for r in new_rows if r not in cards and r not in urgent]
        new_rows = cards + urgent + rest
    env['rows'] = new_rows
    s = env['summary']
    if rel == ADVICE_EXPIRED:
        s = dict(s, overdue_unrecorded_count=4, headline=s['headline'].replace('2건', '4건'))
        assert s['headline'] == '확인하지 않은 만료 안내가 4건입니다.', s['headline']
    n_cards = len(confirm_ids)
    over = s['overdue_unrecorded_count'] - n_cards if s['overdue_unrecorded_count'] > n_cards else None
    env['summary'] = summary_v112(
        s,
        manual_entry=rel not in (ADVICE_VIEWER, ADVICE_COOLING),   # 뷰어·전환 냉각(autoTrade 로 넘어가는 창) = null
        cash=rel == ADVICE12,
        overdue_link_n=over)
    if rel == ADVICE_BLOCKED:
        return render_advice_blocked(env)
    return rerender(rel, env)


def render_advice_blocked(env):
    """advice_blocked 는 요약 `trust` 와 형제 키 `active_flags` 가 여러 줄 꼴이다 — 원문 꼴을 그대로 살린다."""
    rel = ADVICE_BLOCKED
    s = base_text(rel)
    out = render(meta_text(bump(s, rel)), env)
    trust_inline = '    "trust": %s,' % inline(env['summary']['trust'])
    lines = s.split('\n')
    i = lines.index('    "trust": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '    },')
    out = replace_once(out, rel, trust_inline, '\n'.join(lines[i:j + 1]))
    # 형제 키 active_flags — 원문 블록(마지막 키 · 뒤에 `}`)을 그대로.
    k = lines.index('  "active_flags": [')
    orig_flags = '\n'.join(lines[k:-2])
    new_flags = '  "active_flags": %s' % rv(env['active_flags'], 2)
    if new_flags != orig_flags:
        out = replace_once(out, rel, new_flags, orig_flags)
    # 원문과 같은 꼴인지(바뀐 행·요약 키 밖은 그대로) — 렌더러가 원문 블록을 다시 만들 수 있으면 같다.
    return out


def revise_detail(rel):
    env = base_env(rel)
    env['rows'] = [advice_row(r) for r in env['rows']]
    return rerender(rel, env)


def advice_stale():
    """N13 — advice_12 의 OPEN 2행(ad_0001·ad_0002) + 요약 stale_* · 행 actions = RECORD 만(K41)."""
    env = base_env(ADVICE12)
    rows = [advice_row(r, record_only=True) for r in env['rows'] if r['advice_id'] in ('ad_0001', 'ad_0002')]
    assert len(rows) == 2 and all(r['effective_status'] == 'OPEN' for r in rows)
    s = copy.deepcopy(env['summary'])
    s.update({'open_count': 2, 'due_today_count': 0, 'overdue_unrecorded_count': 0,
              'headline': '엔진이 멈춰 있어 안내 2건의 유효성을 보증할 수 없습니다.', 'level': 'WATCH'})
    s.pop('due_soon_label', None)
    s = with_before(s, 'as_of', [('stale_reason_code', 'BATCH_MISSING'), ('stale_label', STALE_LABEL)])
    s = summary_v112(s, manual_entry=True)
    e = envelope(env['as_of'], rows)
    e['summary'] = s
    return render(NEW_META, e)


# ────────────────────────────────────────────────────────────────────────
# 폼 사양·사유(R11~R13 · N10) — K12·K22·K37·K21
# ────────────────────────────────────────────────────────────────────────
def reason_v112(r):
    out = dict(r)
    out['requires_note'] = r['code'] in BUDGET_CODES
    if r['code'] in BUDGET_CODES:
        out['deep_link'] = R_INTERVENTION
    return out


def revise_reason_lines(s, rel):
    """사유 행은 한 줄짜리 평평한 객체다 — 줄 단위로 바꿔 원문 꼴을 보존한다."""
    out = []
    hits = 0
    for line in s.split('\n'):
        m = re.match(r'^(\s*)(\{ "code": .*\})(,?)$', line)
        if m and '"requires_note"' in line:
            r = json.loads(m.group(2))
            line = m.group(1) + inline(reason_v112(r)) + m.group(3)
            hits += 1
        out.append(line)
    assert hits == 6, (rel, hits)
    return '\n'.join(out)


def trade_date_options(spec):
    lo = datetime.date.fromisoformat(spec['min_trade_date'])
    hi = datetime.date.fromisoformat(spec['max_trade_date'])
    closed = set(spec['non_trading_dates'])
    out = []
    d = lo
    while d <= hi:
        iso = d.isoformat()
        if iso not in closed:
            out.append({'date': iso, 'label': '%d/%d(%s)' % (d.month, d.day, '월화수목금토일'[d.weekday()])})
        d += datetime.timedelta(days=1)
    return out


SIDES = [{'side': 'BUY', 'label': SIDE_LABEL['BUY']}, {'side': 'SELL', 'label': SIDE_LABEL['SELL']}]


def form_spec_new_keys_text(spec):
    """폼 사양 행에 더할 줄(append_only_notice 뒤 · 들여쓰기 6)."""
    return ('      "sides": %s,\n      "trade_date_options": %s,\n      "skip_notice_text": %s,'
            % (rv(SIDES, 6), rv(trade_date_options(spec), 6), dumps(SKIP_NOTICE)))


def revise_form_spec(rel):
    s = bump(base_text(rel), rel)
    s = revise_reason_lines(s, rel)
    spec = base_env(rel)['rows'][0]
    anchor = '      "append_only_notice": %s,' % dumps(spec['append_only_notice'])
    return replace_once(s, rel, anchor, anchor + '\n' + form_spec_new_keys_text(spec))


def revise_skip_reasons():
    rel = SKIP_REASONS
    return revise_reason_lines(bump(base_text(rel), rel), rel)


def form_spec_blocked():
    spec = copy.deepcopy(base_env(FORM_SPEC)['rows'][0])
    spec['skip_reasons'] = [reason_v112(r) for r in spec['skip_reasons']]
    spec = with_before(spec, 'as_of', [
        ('sides', SIDES), ('trade_date_options', trade_date_options(spec)), ('skip_notice_text', SKIP_NOTICE),
        ('blocked_text', '원장 정정이 끝날 때까지 기록을 제출할 수 없습니다'),
        ('banner_text', '원장 무결성 점검 중입니다 — 지금 남기는 기록은 보관되었다가 복구 뒤 확정됩니다'),
    ])
    return render(NEW_META, envelope(base_env(FORM_SPEC)['as_of'], [spec]))


def revise_fill_rejected():
    env = base_env(FILL_REJECTED)
    row = env['rows'][0]
    assert row['reject_reason_code'] == 'PRICE_OUT_OF_RANGE'
    env['rows'] = [dict(row, retry_code='OFF_HOUR_TRADE', retry_label=RETRY['OFF_HOUR_TRADE'])]
    env['preserved_input'] = dict(env['preserved_input'], prefilled_fields=['quantity'])   # G27 · A1 — 수량 1개뿐
    return rerender(FILL_REJECTED, env)


# ────────────────────────────────────────────────────────────────────────
# 원장 실사 L-3(R15 · R16 · N4 · N5 · N6) — K7·K8·K9·K36
# ────────────────────────────────────────────────────────────────────────
SPEC_SYMBOLS = ['069500', '133690', '411060', '0085P0']   # SPEC 유니버스 4(v1.8 대응표 01 §17-10)


def deposit_labels():
    out = {}

    def walk(n):
        if isinstance(n, dict):
            if 'symbol' in n and 'symbol_label' in n and 'sleeve' in n:
                out.setdefault(n['symbol'], (n['symbol_label'], n['sleeve']))
            for v in n.values():
                walk(v)
        elif isinstance(n, list):
            for v in n:
                walk(v)
    walk(base_env(DEPOSIT_PLAN1))
    return out


def session_row(**over):
    labels = deposit_labels()
    old = base_env(SELF_REPORT1)
    acct = ACCOUNTS[0]
    row = {
        'title_text': '8월 정기 실사',
        'notice_text': '실사 중에는 이 폰의 화면에서 보유 수량·금액이 가려집니다 · 원장 값은 제출 뒤에 보입니다',
        'as_of_trade_date_text': '2026-08-31 종가 기준으로 적으십시오',
        'symbols': [{'symbol': s, 'label': labels[s][0], 'sleeve': labels[s][1]} for s in SPEC_SYMBOLS],
        'account_label': acct['label'],
        'cash_hint_label': '원화 현금 — 원 단위까지 적으십시오',
        'declare_complete_label': '이것이 전부입니다',
        'session_closed_text': None,
        'blocked_text': None,
        'result': None,
        'trust': old['trust'],
        'as_of': old['as_of'],
    }
    row.update(over)
    return row


def self_report_link(yyyy_mm, alias):
    return R_SELF_REPORT + yyyy_mm + '/' + alias


def revise_self_report1():
    env = base_env(SELF_REPORT1)
    e = envelope(env['as_of'], [session_row()])
    return render(meta_text(bump(base_text(SELF_REPORT1), SELF_REPORT1)), e)


def self_report_diff_row():
    return {
        'diff_id': 'ld_sr_0001',
        'pair': 'CANON_SELF_REPORT',
        'axis': 'QUANTITY',
        'authored_date': '2026-08-31',
        'delta_label': '133690 수량 −3주 (원장 245 / 자가 보고 242)',
        'severity': 'OBSERVATIONAL',
        'candidate_origin_codes': ['UNRECORDED_FILL', 'SELF_REPORT_CORRECTION'],
        'status': 'OPEN',
        'route': 'APPROVAL',
        'evidence_hash': 'ev_4e1b7c90d2a8',
        'applicable': True,
    }


def self_report_result():
    second = ACCOUNTS[1]
    return session_row(result={
        'diffs': [display_diff(self_report_diff_row(), detected='2026-08-31 12:10', in_result=True)],
        'empty_label': None,
        'resolve_link': {'label': '차이 해소하기', 'deep_link': R_RESOLVE},
        'next_account_link': {'label': '다음 계좌 실사 — %s' % second['label'],
                              'deep_link': self_report_link('2026-08', second['alias'])},
    })


def receipts(kind, command_id, nonce, requested_at, expires_at, states):
    rows = []
    for st, label, code, retry in states:
        r = {'command_id': command_id, 'kind': kind, 'state': st, 'state_label': label,
             'requested_at': requested_at, 'expires_at': expires_at, 'nonce': nonce,
             'issued_by_device_id': 'dev_operator_01'}
        if code is not None:
            r['reject_reason_code'] = code
        if retry is not None:
            r['retry_code'] = retry
            r['retry_label'] = RETRY[retry]
        rows.append(r)
    return rows


KEEP = '입력값은 그대로 남아 있습니다'
HELD = '보류됨 — 원장 무결성 점검 중이라 보관했습니다. 복구 뒤 일괄 확정 단계에서 처리됩니다'


def sr_receipts():
    return receipts('SELF_REPORT_BALANCE', 'cmd_20260831_0061', 'n_5a9e2c7d41b0',
                    '2026-08-31T12:05:00Z', '2026-08-31T12:35:00Z', [
                        ('REQUESTED', '요청됨 — 엔진 수신 대기', None, None),
                        ('EXECUTED', '기록됨 — 실사 보고가 원장과 대조되었습니다', None, None),
                        ('REJECTED', '거부됨 — 열린 실사 세션이 없습니다. 화면을 다시 열어 실사를 시작하십시오. ' + KEEP,
                         'SELF_REPORT_OUTSIDE_SESSION', None),
                        ('REJECTED', '거부됨 — 현금 칸을 숫자로 적으십시오. ' + KEEP, 'INPUT_INVALID', None),
                        ('HELD_FOR_INTEGRITY', HELD, None, None),
                    ])


def mf_receipts():
    return receipts('RECORD_MANUAL_FILL', 'cmd_20260831_0071', 'n_c2f6a18e93d5',
                    '2026-08-31T11:50:00Z', '2026-08-31T12:20:00Z', [
                        ('REQUESTED', '요청됨 — 엔진 수신 대기', None, None),
                        ('EXECUTED', '기록됨 — 체결이 원장에 남았습니다', None, None),
                        ('REJECTED', '거부됨 — 24시간 안에 같은 안내·거래일·수량·가격의 기록이 있습니다. ' + KEEP,
                         'DUPLICATE_SUSPECTED', 'DUPLICATE_ACK'),
                        ('REJECTED', '거부됨 — 수량 칸을 확인하십시오. ' + KEEP, 'INPUT_INVALID', None),
                        ('HELD_FOR_INTEGRITY', HELD, None, None),
                        ('PENDING_LEASE_CONFIRM', '보류됨 — 운영 폰 리스를 확인한 뒤 처리됩니다. 기록은 보관했습니다', None, None),
                        ('STALE_CONTEXT', '보류됨 — 운영 맥락이 바뀌어 다시 확인합니다. 기록은 보관했습니다', None, None),
                    ])


def skip_receipts():
    return receipts('SKIP_ADVICE', 'cmd_20260831_0081', 'n_9b3d5e0f7a26',
                    '2026-08-31T12:40:00Z', '2026-08-31T13:10:00Z', [
                        ('REQUESTED', '요청됨 — 엔진 수신 대기', None, None),
                        ('EXECUTED', '기록됨 — 이 안내를 하지 않은 것으로 닫았습니다', None, None),
                        ('REJECTED', '거부됨 — 운영 폰 리스가 만료되었습니다. 리스를 다시 잡은 뒤 제출하십시오. ' + KEEP,
                         'LEASE_EXPIRED', None),
                        ('REJECTED', '거부됨 — 이미 닫힌 안내입니다. ' + KEEP, 'ADVICE_NOT_OPEN', None),
                        ('HELD_FOR_INTEGRITY', HELD, None, None),
                    ])


def defer_receipts():
    return receipts('DEFER_ADVICE_CONFIRM', 'cmd_20260831_0091', 'n_e47a0c3b9d18',
                    '2026-08-31T13:20:00Z', '2026-08-31T13:50:00Z', [
                        ('REQUESTED', '요청됨 — 엔진 수신 대기', None, None),
                        ('EXECUTED', '기록됨 — 이 확인은 내일 다시 묻습니다', None, None),
                        ('REJECTED', '거부됨 — 이 안내는 이미 한 번 미뤘습니다. 기록하거나 하지 않았다고 정리하십시오',
                         'DEFER_ALREADY_USED', None),
                    ])


def revise_drafts_x7():
    rel = DRAFTS_X7
    s = bump(base_text(rel), rel)
    s = replace_once(s, rel, '"target_id": "PERIODIC_AUDIT"', '"target_id": "%s/%s"' % ('2026-08', ACCOUNTS[0]['alias']))
    # 3행 lines[1] 379810 → 133690(R15 세션 종목 — 세션에 없는 종목 행은 복원 때 code 대조로 버려진다 01 §12-1-3).
    s = replace_once(s, rel, '"symbol": "379810",\n            "quantity_text": ""',
                     '"symbol": "133690",\n            "quantity_text": ""')
    return s


# ────────────────────────────────────────────────────────────────────────
# 원장 차이·정정(R1 · N1 · N2 · N3) — K24·K25·K26
# ────────────────────────────────────────────────────────────────────────
def pair_labels():
    return {c['pair']: c['label'] for c in base_env(RECON_BOARD)['rows'][0]['cells']}


STATUS_LABEL = {'ld_0001': '열림', 'ld_0002': '열림', 'ld_0003': '받아들임 · 2026-08-30', 'ld_0004': '해소됨 · 2026-08-29'}


def chip(code):
    c = {'code': code, 'label': ORIGIN_LABEL[code], 'tone': 'NEUTRAL'}
    if code in ORIGIN_HANDBOOK:
        c['detail_deep_link'] = ORIGIN_HANDBOOK[code]
    return c


def display_diff(r, detected=None, in_result=False, status_label=None):
    out = dict(r)
    out['pair_label'] = pair_labels()[r['pair']]
    out['axis_label'] = PAIR_AXIS_LABEL[r['axis']]
    out['severity_label'] = SEVERITY_LABEL[r['severity']]
    out['status_label'] = status_label or STATUS_LABEL.get(r['diff_id'], '열림')
    out['route_label'] = ROUTE_LABEL[r['route']]
    out['candidate_origins'] = [chip(c) for c in r['candidate_origin_codes']]
    out['detected_at_text'] = '탐지 ' + (detected or (r['authored_date'] + ' 09:00'))
    link = None
    if not in_result:
        if r['route'] == 'APPROVAL':
            link = {'label': '정정하기', 'deep_link': R_REPAIR}
        elif r['pair'] == 'CANON_SELF_REPORT':
            link = {'label': '다시 실사하기', 'deep_link': self_report_link('2026-08', ACCOUNTS[0]['alias'])}
    out['action_link'] = link
    return out


def revise_ledger_diffs4():
    env = base_env(LEDGER_DIFFS4)
    env['rows'] = [display_diff(r) for r in env['rows']]
    return rerender(LEDGER_DIFFS4, env)


def cash_observe():
    r = {
        'diff_id': 'ld_0005',
        'pair': 'CANON_BROKER',
        'axis': 'CASH',
        'authored_date': '2026-08-31',
        'delta_label': '원화 현금이 기록과 다릅니다 (정본 412,300원 / 브로커 413,500원)',
        'severity': 'OBSERVATIONAL',
        'candidate_origin_codes': ['EXTERNAL_CASHFLOW', 'FILL_LAG'],
        'status': 'OPEN',
        'route': 'AUTO',
        'evidence_hash': 'ev_c08d2f5a91e7',
        'applicable': True,
    }
    d = display_diff(r)
    assert d['action_link'] is None
    return render(NEW_META, envelope(base_env(LEDGER_DIFFS4)['as_of'], [d]))


def repair_rows():
    """N1 — 자동 재동기화 2 + 정본 정정 1 + 그 정정의 정정 1(02 §5-2 모의 데이터). 순서 = 엔진(원본 시간 역순 ·
    정정의 정정은 그 원본 바로 뒤)."""
    def row(rid, diff, direction, origin, decision, supersedes, recomputed, applied, label, target, stamp, ev,
            superseded=False):
        r = {'repair_id': rid, 'diff_id': diff, 'direction_code': direction,
             'direction_label': '파생 재생성 · 자동' if direction == 'DERIVED_RESYNC' else '정본 정정 · 승인',
             'origin_code': origin}
        if decision is not None:
            r['decision_id'] = decision
        r['evidence_hash'] = ev
        if supersedes is not None:
            r['supersedes'] = supersedes
        if recomputed is not None:
            r['recomputed_from'] = recomputed
        r['applied_at'] = applied
        r['label'] = label
        kst = datetime.datetime.fromisoformat(applied.replace('Z', '+00:00')) + datetime.timedelta(hours=9)
        r['applied_at_text'] = kst.strftime('%Y-%m-%d %H:%M') + ' 적용'   # 표시 시각 = 한국 시각(엔진 완성)
        r['direction_tone'] = 'NEUTRAL' if direction == 'DERIVED_RESYNC' else 'CAUTION'
        r['origin_label'] = ORIGIN_LABEL[origin]
        r['target_text'] = target
        r['decision_link'] = ({'label': DECISION_LINK_LABEL, 'deep_link': R_DECISION + decision}
                              if decision is not None else None)
        if superseded:
            r['superseded_label'] = '이후 정정됨'
        r['chain_stamp_text'] = stamp
        return r
    return [
        row('rp_0002', 'ld_0002', 'DERIVED_RESYNC', 'PUSH_LAG', None, None, None, '2026-08-30T02:15:00Z',
            '미러에 체결 2행을 다시 보냈습니다', '미러 체결 행 2건', 'chn_3b9e…41', 'ev_rp_6c2d90a1'),
        row('rp_0003', 'ld_0001', 'CANON_CORRECT', 'FILL_LAG', 'd_rp_0003', None, '2026-08-24',
            '2026-08-28T02:02:00Z', '브로커 기준으로 수량 정정 · 2026-08-24부터 재계산', '069500 수량 120 → 132주',
            'chn_7f3a…c2', 'ev_rp_1f84b7e3', superseded=True),
        row('rp_0004', 'ld_0001', 'CANON_CORRECT', 'MANUAL_ORDER', 'd_rp_0004', 'rp_0003', '2026-08-26',
            '2026-08-29T03:40:00Z', '수동 주문 반영으로 앞선 정정을 다시 정정 · 2026-08-26부터 재계산',
            '069500 수량 132 → 130주', 'chn_a21d…7e', 'ev_rp_d05c3a62'),
        row('rp_0001', 'ld_0004', 'DERIVED_RESYNC', 'CAL_WRITE_FAILED', None, None, None, '2026-08-28T01:30:00Z',
            '캘린더 이벤트 1건을 다시 썼습니다', '캘린더 이벤트 1건', 'chn_05e7…9b', 'ev_rp_8a1f42c0'),
    ]


# ────────────────────────────────────────────────────────────────────────
# 알림·리듬·안전 상태·인시던트·홈(R17~R23 · N11 · N12 · N15) — K31·K32·K44·K45
# ────────────────────────────────────────────────────────────────────────
AUDIT_LINK = None    # main() — self_report_link('2026-08', 첫 계좌)


def revise_alerts12():
    env = base_env(ALERTS12)
    by = {r['alert_id']: r for r in env['rows']}
    for aid in ('al_0010', 'al_0011', 'al_0012'):
        assert by[aid]['level'] == 'P2'
        by[aid]['level'] = 'P1'
    assert by['al_0005']['deep_link'] == OLD_FILL and by['al_0008']['deep_link'] == OLD_SELF_REPORT
    by['al_0005']['deep_link'] = R_FILL + 'ad_0002'
    by['al_0008']['deep_link'] = AUDIT_LINK
    assert by['al_0009']['code'] == 'CONTRIBUTION_CHANGED'
    by['al_0009']['deep_link'] = None       # «지금 변경» 버튼·딥링크를 만들지 않는다(alert_codes.dart)
    return rerender(ALERTS12, env)


def revise_alerts_digest():
    env = base_env(ALERTS_DIGEST)
    src = {r['alert_id']: r for r in base_env(ALERTS12)['rows']}['al_0009']
    rows = env['rows']
    assert rows[2]['alert_id'] == 'al_d_03' and rows[2]['grouped_count'] == 3
    d3 = rows[2]
    rows[2] = {'alert_id': d3['alert_id'], 'level': 'P2', 'raised_at': d3['raised_at'], 'code': src['code'],
               'title': src['title'], 'body_text': src['body_text'], 'action_line': src['action_line'],
               'grouped_count': d3['grouped_count'], 'deep_link': None}
    assert rows[1]['deep_link'] == OLD_SELF_REPORT
    rows[1]['deep_link'] = AUDIT_LINK
    return rerender(ALERTS_DIGEST, env)


def revise_alerts9():
    env = base_env(ALERTS_9)
    by = {r['alert_id']: r for r in env['rows']}
    assert by['al_x7_08']['deep_link'] == OLD_SELF_REPORT and by['al_x7_09']['deep_link'] == OLD_FILL
    by['al_x7_08']['deep_link'] = AUDIT_LINK
    by['al_x7_09']['deep_link'] = R_FILL + 'ad_0002'
    return rerender(ALERTS_9, env)


def revise_rhythm_rows():
    rel = RHYTHM_ROWS
    s = bump(base_text(rel), rel)
    return replace_once(s, rel, '"route": "%s" }' % OLD_SELF_REPORT,
                        '"route": "%s" }' % self_report_link('2026-09', ACCOUNTS[0]['alias']))


def revise_safety_states():
    rel = SAFETY_STATES
    s = bump(base_text(rel), rel)
    return replace_once(s, rel, '"clear_deep_link": "%s" }' % OLD_SELF_REPORT, '"clear_deep_link": "%s" }' % AUDIT_LINK)


def revise_incident():
    rel = INCIDENT
    s = bump(base_text(rel), rel)
    assert base_env(rel)['incident_alert']['code'] == 'MAINTENANCE_RESUME_FAILED'
    return replace_once(s, rel, '    "level": "P1",', '    "level": "P0",')


def revise_resume_gap7():
    env = base_env(RESUME_GAP7)
    line = {'label': env.pop('resume_headline'), 'deep_link': env.pop('resume_route')}
    assert line['deep_link'] == R_RESUME
    env['rows'] = [with_after(r, 'upcoming', [('resume_line', line)]) for r in env['rows']]
    return rerender(RESUME_GAP7, env)


def rhythm_empty():
    return render(NEW_META, envelope(as_of('운영 리듬 기준 2026-08-31'), [], empty_kind='NOT_LOADED',
                                     empty_label='운영 리듬을 아직 받지 못했습니다'))


def safety_advice_blocked():
    env = base_env(SAFETY_STATES)
    row = copy.deepcopy(env['rows'][1])
    assert row['breaker_level'] == 'ALERT'
    row['active_flags'] = copy.deepcopy(base_env(ADVICE_BLOCKED)['active_flags'])
    return render(NEW_META, envelope(env['as_of'], [row]))


def trust_self_audit_due():
    base = [r for r in base_env(TRUST4)['rows'] if r['grade'] == 'SELF_REPORTED'][0]
    row = {
        'grade': 'SELF_REPORTED',
        'level': base['level'],
        'label': base['label'],
        'consequence_line': '마지막 실사 후 31일 경과 — 이번 달 실사 1회로 등급이 유지됩니다',
        'upgrade_hint': base['upgrade_hint'],
        'last_verified_on': '2026-07-31',
        'action_deep_link': AUDIT_LINK,
    }
    return render(NEW_META, envelope(base_env(TRUST4)['as_of'], [row]))


def fills_ad0005():
    """N14 — `advice_detail_partial` ad_0005(20주 중 8주)의 체결 1행(짝 표본 = 그 행 글자 그대로 · K23 예외)."""
    a = base_env(DETAIL_PARTIAL)['rows'][0]
    tpl = base_env('m6/manual_fills_8.json')['rows'][0]
    assert a['advice_id'] == 'ad_0005' and a['recorded_quantity'] == 8
    chip_q = [c for c in a['recorded_deviation_chips'] if c['code'] == 'ADVICE_QTY_DEVIATION'][0]
    price = a['price_band']['reference']
    row = {
        'entry_id': 'mf_0101',
        'mode': 'LIVE',
        'trade_date': '2026-08-31',
        'executed_at': '2026-08-31T05:30:00Z',
        'symbol': a['symbol'],
        'symbol_label': a['symbol_label'],
        'sleeve': a['sleeve'],
        'side': a['side'],
        'side_label': SIDE_LABEL[a['side']],
        'quantity': a['recorded_quantity'],
        'price': price,
        'commission': '54',
        'tax': '0',
        'quantity_text': '%d주' % a['recorded_quantity'],
        'price_text': '{:,}원'.format(int(price)),
        'commission_text': '54원',
        'tax_text': '0원',
        'status': 'FILLED',
        'status_label': '체결',
        'status_tone': 'NEUTRAL',
        'visibility': 'SETTLED',
        'visibility_label': '확정',
        'reasons': copy.deepcopy(tpl['reasons']),
        'decision': {'decision_id': 'd_mf_0101', 'intent_id': 'i_mf_0101', 'config_hash': 'cfg_fake_0000000000000000'},
        'deviation': {'is_deviation': True, 'label': chip_q['label'], 'kind_code': chip_q['code']},
        'account_alias': a['account_alias'],
        'fill_origin': 'MANUAL',
        'fill_kind': 'ORIGINAL',
        'backdate': {'trade_date': '2026-08-31', 'authored_at': '2026-08-31T11:00:00Z', 'backdate_trading_days': 0,
                     'is_backdated': False, 'label': '당일 기록', 'price_range_source_date': '2026-08-31',
                     'crosses_closed_period': False},
        'cost_source': 'USER_ENTERED',
        'cost_source_label': '직접 입력',
        'origin_label': '수기 기록',
        'detail_deep_link': R_DECISION + 'd_mf_0101',
        'as_of': as_of('기록 반영 2026-08-31', observed='2026-08-31T09:30:00Z'),
        'advice_id': a['advice_id'],
    }
    assert set(row) == set(tpl), set(row) ^ set(tpl)
    return render(NEW_META, envelope(base_env('m6/manual_fills_8.json')['as_of'], [row]))


# ────────────────────────────────────────────────────────────────────────
# 자가 검사
# ────────────────────────────────────────────────────────────────────────
def strings(node, path=''):
    if isinstance(node, dict):
        for k, v in node.items():
            yield from strings(v, '%s.%s' % (path, k))
    elif isinstance(node, list):
        for i, v in enumerate(node):
            yield from strings(v, '%s[%d]' % (path, i))
    elif isinstance(node, str):
        yield path, node


def objects(node):
    if isinstance(node, dict):
        yield node
        for v in node.values():
            yield from objects(v)
    elif isinstance(node, list):
        for v in node:
            yield from objects(v)


def self_check_file(rel, s, new):
    assert '\r' not in s, rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE', rel
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel
    body = body_without_meta(s)
    for rx in RETIRED:
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    keys = list(env.keys())
    assert keys[:6] == ENVELOPE_KEYS, (rel, keys)
    if new:
        assert set(keys) <= set(ENVELOPE_KEYS) | {'summary'}, (rel, keys)
    for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
        if rel in NEW_FILES or rel in REVISED:
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
        if rel in NEW_FILES:
            assert not DEV_MEMO.search(v), '%s %s — 사용자 문장 자리의 개발자 메모: %s' % (rel, path, v)
        if v.startswith('aaq://'):
            assert v != OLD_FILL and v != OLD_SELF_REPORT, (rel, path, v)
            if v.startswith(R_SELF_REPORT):
                tail = v[len(R_SELF_REPORT):]
                assert re.fullmatch(r'\d{4}-\d{2}/[^/?#]+', tail), (rel, path, v)
                assert tail.split('/')[1] in {a['alias'] for a in ACCOUNTS}, (rel, path, v)
    return env


def main():
    global ACCOUNTS, AUDIT_LINK
    rels = base_files()
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels)
    ACCOUNTS = base_env(FORM_SPEC)['rows'][0]['accounts']
    assert [a['alias'] for a in ACCOUNTS] == ['연금저축', '일반'], ACCOUNTS
    AUDIT_LINK = self_report_link('2026-08', ACCOUNTS[0]['alias'])

    out = {}
    # ── 개정 목록 23(결과 = 개정 22 + 버전 줄만 1 · 아래 VERSION_ONLY_REVISED 단언) ──
    out[LEDGER_DIFFS4] = revise_ledger_diffs4()
    for rel in INBOX:
        out[rel] = revise_inbox(rel)
    for rel in DETAILS:
        out[rel] = revise_detail(rel)
    out[SKIP_REASONS] = revise_skip_reasons()
    out[FORM_SPEC] = revise_form_spec(FORM_SPEC)
    out[FORM_SPEC_STALE] = revise_form_spec(FORM_SPEC_STALE)
    out[FILL_REJECTED] = revise_fill_rejected()
    out[SELF_REPORT1] = revise_self_report1()
    out[DRAFTS_X7] = revise_drafts_x7()
    out[ALERTS12] = revise_alerts12()
    out[ALERTS_DIGEST] = revise_alerts_digest()
    out[ALERTS_9] = revise_alerts9()
    out[RHYTHM_ROWS] = revise_rhythm_rows()
    out[SAFETY_STATES] = revise_safety_states()
    out[INCIDENT] = revise_incident()
    out[RESUME_GAP7] = revise_resume_gap7()
    assert set(out) == set(REVISED)
    # ── 신설 15 ──
    rec_as_of = base_env('m6/journal_draft_receipts_5.json')['as_of']
    out[N_REPAIRS4] = render(NEW_META, envelope(as_of('정정 이력 기준 2026-08-31'), repair_rows()))
    out[N_REPAIRS_EMPTY] = render(NEW_META, envelope(as_of('정정 이력 기준 2026-08-31'), [],
                                                     empty_label='정정 이력이 없습니다'))
    out[N_CASH_OBSERVE] = cash_observe()
    out[N_SR_RESULT] = render(NEW_META, envelope(base_env(SELF_REPORT1)['as_of'], [self_report_result()]))
    out[N_SR_CLOSED] = render(NEW_META, envelope(base_env(SELF_REPORT1)['as_of'], [session_row(
        session_closed_text='실사 세션이 닫혔습니다 · 다시 시작하려면 화면을 다시 여십시오')]))
    out[N_SR_RECEIPTS] = render(NEW_META, envelope(as_of('실사 기준 2026-08-31'), sr_receipts()))
    out[N_MF_RECEIPTS] = render(NEW_META, envelope(as_of('기록 기준 2026-08-31'), mf_receipts()))
    out[N_SKIP_RECEIPTS] = render(NEW_META, envelope(as_of('기록 기준 2026-08-31'), skip_receipts()))
    out[N_DEFER_RECEIPTS] = render(NEW_META, envelope(as_of('기록 기준 2026-08-31'), defer_receipts()))
    out[N_SPEC_BLOCKED] = form_spec_blocked()
    out[N_RHYTHM_EMPTY] = rhythm_empty()
    out[N_SAFETY_BLOCKED] = safety_advice_blocked()
    out[N_STALE] = advice_stale()
    out[N_FILLS_AD5] = fills_ad0005()
    out[N_TRUST_DUE] = trust_self_audit_due()
    assert rec_as_of['trade_date'] == '2026-08-31'
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, new=rel in NEW_FILES) for rel, s in out.items()}
    # 옛 꼴 링크 0 · 개정 전 7곳(설계서 §4-1).
    old_hits = sum(1 for rel in rels for _p, v in strings(base_env(rel))
                   if v in (OLD_FILL, OLD_SELF_REPORT))
    assert old_hits == 7, old_hits
    # 안내 — DETAIL 0 · 링크 = 그 행 id · 확인 카드 ≤3 맨 앞 [RECORD, SKIP] · 뷰어 actions [].
    advice_files = INBOX + DETAILS + [N_STALE]
    for rel in advice_files:
        rows = envs[rel]['rows']
        cards = [i for i, r in enumerate(rows) if 'expired_confirm_label' in r]
        assert cards == list(range(len(cards))) and len(cards) <= 3, (rel, cards)
        for r in rows:
            aid = r['advice_id']
            assert r['detail_deep_link'] == R_DETAIL + aid
            for a in r['actions']:
                assert a['action_id'] in ('RECORD', 'SKIP'), (rel, aid)
                assert a['deep_link'] == (R_FILL if a['action_id'] == 'RECORD' else R_SKIP) + aid
            if 'expired_confirm_label' in r:
                assert [a['action_id'] for a in r['actions']] == ['RECORD', 'SKIP'], (rel, aid)
                assert r['effective_status'] == 'EXPIRED'
            if r['effective_status'] == 'EXPIRED' and rel in INBOX:
                assert 'expired_confirm_label' in r, (rel, aid)
            if r.get('defer_available'):
                assert 'expired_confirm_label' in r, (rel, aid)
            assert ('close_reason_label' in r) == ('close_reason_code' in r), (rel, aid)
            assert ('prefill_quantity_text' in r) == ('prefill_quantity_label' in r), (rel, aid)
            if 'prefill_quantity_text' in r:
                assert r['prefill_quantity_text'] == str(r['quantity']) and r['effective_status'] in ('OPEN', 'PARTIAL')
            if 'decision_link' in r:
                assert r['decision_link']['deep_link'] == R_DECISION + r['decision']['decision_id']
        if rel == ADVICE_VIEWER:
            for r in rows:
                assert r['actions'] == [] and not r['defer_available'] and 'decision_link' in r
                for k in ('side_label', 'prefill_quantity_text', 'prefill_quantity_label', 'expired_confirm_label'):
                    assert k not in r, (rel, k)
            assert 'manual_entry_link' not in envs[rel]['summary']
    a12 = [r['advice_id'] for r in envs[ADVICE12]['rows']]
    assert a12[:3] == ['ad_0010', 'ad_0011', 'ad_0003'], a12
    assert len(envs[ADVICE_EXPIRED]['rows']) == 3 and envs[ADVICE_EXPIRED]['summary']['overdue_unrecorded_count'] == 4
    assert 'overdue_unrecorded_link' in envs[ADVICE_EXPIRED]['summary']
    assert 'overdue_unrecorded_link' not in envs[ADVICE12]['summary']
    for r in envs[N_STALE]['rows']:
        assert [a['action_id'] for a in r['actions']] == ['RECORD']
    # 사유 — 세 픽스처의 같은 code 행 JSON 같음 · 예산 2종만 deep_link·requires_note.
    reasons = [envs[SKIP_REASONS]['rows']] + [envs[f]['rows'][0]['skip_reasons']
                                             for f in (FORM_SPEC, FORM_SPEC_STALE, N_SPEC_BLOCKED)]
    for lst in reasons:
        assert lst == reasons[0]
        for r in lst:
            assert r['requires_note'] == (r['code'] in BUDGET_CODES) == ('deep_link' in r)
    for f in (FORM_SPEC, FORM_SPEC_STALE, N_SPEC_BLOCKED):
        sp = envs[f]['rows'][0]
        assert sp['sides'] == SIDES and sp['skip_notice_text'] == SKIP_NOTICE
        assert [o['date'] for o in sp['trade_date_options']] == [o['date'] for o in trade_date_options(sp)]
        assert not set(o['date'] for o in sp['trade_date_options']) & set(sp['non_trading_dates'])
    # 원장 차이 — pair_label == 보드 · 후보 칩 순서 · 조치 링크.
    for f in (LEDGER_DIFFS4, N_CASH_OBSERVE):
        for r in envs[f]['rows']:
            assert r['pair_label'] == pair_labels()[r['pair']]
            assert [c['code'] for c in r['candidate_origins']] == r['candidate_origin_codes']
    assert sum(1 for r in envs[LEDGER_DIFFS4]['rows'] if r['action_link']) == 1
    # 정정 이력 — 정정의 정정 = 원본 바로 뒤 · 원본 superseded_label · diff_id ∈ ledger_diffs_4.
    reps = envs[N_REPAIRS4]['rows']
    diffs = {r['diff_id'] for r in envs[LEDGER_DIFFS4]['rows']}
    for i, r in enumerate(reps):
        assert r['diff_id'] in diffs
        if 'supersedes' in r:
            assert reps[i - 1]['repair_id'] == r['supersedes']
        nxt = reps[i + 1] if i + 1 < len(reps) else None
        assert ('superseded_label' in r) == (nxt is not None and nxt.get('supersedes') == r['repair_id'])
    # 리듬 — 홈 upcoming == 리듬 표 앞 행(C-47 ⑤).
    rhythm = envs[RHYTHM_ROWS]['rows']
    for f in OPS_HOMES:
        up = envs[f]['rows'][0]['upcoming']
        assert up == rhythm[:len(up)] and len(up) <= 3, f
    assert envs[RESUME_GAP7]['rows'][0]['resume_line']['deep_link'] == R_RESUME
    # 알림 등급 — 대조 대상 객체 28 · 다이제스트 전 행 P2.
    graded = [o for rel in out for o in objects(envs[rel]) if o.get('level') in ('P0', 'P1', 'P2') and 'code' in o]
    assert len(graded) == 28, len(graded)
    assert all(r['level'] == 'P2' for r in envs[ALERTS_DIGEST]['rows'])
    levels = [r['level'] for r in envs[ALERTS12]['rows']]
    assert (levels.count('P0'), levels.count('P1'), levels.count('P2')) == (2, 7, 3), levels
    # L-3 — 세션 기호 = 입금 정본 라벨 · 원장 수량 키 0 · 결과 쌍 = CANON_SELF_REPORT · 링크 null.
    labels = deposit_labels()
    for f in (SELF_REPORT1, N_SR_RESULT, N_SR_CLOSED):
        row = envs[f]['rows'][0]
        assert [s['label'] for s in row['symbols']] == [labels[s['symbol']][0] for s in row['symbols']]
        assert not any('quantity' in o for o in objects(row['symbols']))
        if row['session_closed_text'] is not None:
            assert row['result'] is None
        if row['result'] is not None:
            assert all(d['pair'] == 'CANON_SELF_REPORT' and d['action_link'] is None for d in row['result']['diffs'])
    dx = envs[DRAFTS_X7]['rows'][2]
    assert dx['key']['target_id'] == '2026-08/연금저축'
    assert {l['symbol'] for l in dx['self_report']['lines']} <= {s['symbol'] for s in envs[SELF_REPORT1]['rows'][0]['symbols']}
    # 접수증 — 거부 코드 사전 · 한 명령의 갈래.
    for f in (N_SR_RECEIPTS, N_MF_RECEIPTS, N_SKIP_RECEIPTS, N_DEFER_RECEIPTS, FILL_REJECTED):
        rows = envs[f]['rows']
        assert len({(r['command_id'], r['nonce'], r['issued_by_device_id'], r['kind']) for r in rows}) == 1, f
        for r in rows:
            assert ('reject_reason_code' in r) == (r['state'] == 'REJECTED'), f
            if 'retry_code' in r:
                assert r['state'] == 'REJECTED' and (r['reject_reason_code'], r['retry_code']) in (
                    ('PRICE_OUT_OF_RANGE', 'OFF_HOUR_TRADE'), ('DUPLICATE_SUSPECTED', 'DUPLICATE_ACK')), f
    assert not any(r.get('reject_reason_code') == 'LEASE_EXPIRED' for r in envs[N_MF_RECEIPTS]['rows'])
    # 진입 링크 표본 — 9b 실사 카드 · 리듬 분기 실사.
    assert envs[N_TRUST_DUE]['rows'][0]['action_deep_link'] == AUDIT_LINK

    # ── 건수(바이트 결과 기준 · 🆕 검증 반영) — 목록상 개정인데 결과가 버전 줄만인 파일 = cooling 하나 ──
    version_only_revised = sorted(rel for rel in REVISED if out[rel] == bump(base_text(rel), rel))
    assert version_only_revised == [ADVICE_COOLING], version_only_revised
    n_version_only = len(rels) - len(REVISED) + len(version_only_revised)
    n_revised = len(REVISED) - len(version_only_revised)
    assert (n_version_only, n_revised) == (137, 22), (n_version_only, n_revised)

    # ── 쓰기 ──
    for rel, s in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(s)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r5r13_v112_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d(목록 %d — 결과 버전 줄만 %s) · 신설 %d) · '
          '등급 대상 %d · contract 1.12.0' % (len(out), BASE_FILES, n_version_only, n_revised, len(REVISED),
                                             ', '.join(version_only_revised), len(NEW_FILES), len(graded)))


if __name__ == '__main__':
    main()
