#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.6(R12 선행 M2 보강 · 01 §15-4) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r12_v16_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r12_fixtures.py(계약 v1.5 · 그 스크립트는 v1.5 재현용으로 그대로 둔다)를 본떴다.

하는 일(보강안 §3 · 126 → 135 = 신설 9 · 개정 14 · 개명 1 · 버전 줄만 112)
  (a) 전 봉투의 "contract_version": "1.5.0" → "1.6.0" 한 줄 치환(다른 글자 불변 · 112건).
  (b) 개정 14 — rebalance_6(거래일 내림차순 · 행 as_of = 봉투 관측 시각 · SleeveWeight.label 규칙 ·
      thresholds) · m7_rebalance_detail_band · m7_rebalance_detail_advisory · m7_annual_2026 ·
      m7_annual_first_year · aftertax_ladder_1 · execution_gap_1/cant/wont/mixed(래퍼 `{report, as_of}`) ·
      m7_monthly_2026_08/gap/masked_recon(⑧ 링크 = 그 달) · + 개명 1(m7_next_rebalance_d6 →
      m7_next_rebalance_countdown · «D-1»).
  (c) 신설 9 — m7_rebalance_preview_default/in_band/blocked · m7_next_rebalance_none ·
      m7_rebalance_sim · m7_annual_offwindow · execution_gap_empty/not_applicable/masked_recon.
  (d) §3-0 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

멱등: 개정·치환은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
날짜·건수·id·금액 가중 값은 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r12_v16_fixtures.py
"""
import copy
import io
import json
import os
import re
import subprocess
import sys
from decimal import ROUND_HALF_UP, Decimal

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures')).replace(os.sep, '/')
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/')
FX_REL = os.path.relpath(FX, ROOT).replace(os.sep, '/')
# 계약 1.5.0 · 픽스처 126 의 기준 커밋(origin/main · R12 선행 보강 (2) 병합 기록 542d13c).
BASE = '542d13cea8565b910182bbc080c2ebd14dc5ccda'

OLD_VER = '"contract_version": "1.5.0"'
NEW_VER = '"contract_version": "1.6.0"'
BASE_FILES = 126
WANT_FILES = 135

NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.6.0",
    "generated_at": "2026-10-08T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20261008,
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
# 금지어(01 §10-1 · 03 §15) — R12 신설·개정 픽스처의 전 문자열.
FORBIDDEN = re.compile(r'추천|권유|자문|시그널')
# 사용자 문장 자리의 개발자 메모(H50) — «화면이 …하지 않습니다» 류.
DEV_MEMO = re.compile(r'화면이|화면은|화면·')
# 금액 꼴(meta 블록 밖) — 금액을 싣지 않는 신설 파일의 거름망(최종 판정은 C-14·C-32).
MONEY = re.compile(r'[0-9][0-9,]*\s*(원|만원)')
# decimal 정규형 금액 문자열(`"16380"`).
DECIMAL_CANON = re.compile(r'^(0|[1-9][0-9]*)$')
# 픽스처 계좌 별칭(정본 = fixtures/README.md · test/contracts/support/fixture_accounts.dart).
PENSION_ALIASES = {'연금저축', 'IRP'}
ACCOUNT_ALIASES = PENSION_ALIASES | {'일반'}
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']

ROUTE_REBALANCE_EVENT = 'aaq://rebalance/event/:rebalanceEventId'
ROUTE_GAP = 'aaq://ledger/execution-gap'
ROUTE_GAP_MONTH = 'aaq://ledger/execution-gap/:yyyyMm'
ROUTE_PREVIEW = 'aaq://rebalance/preview'
ROUTE_RESUME_REPORT = 'aaq://x2/resume-report'

# ── 이름 ─────────────────────────────────────────────────────────────────
R6 = 'rebalance_6.json'
BAND = 'm7/m7_rebalance_detail_band.json'
ADVISORY = 'm7/m7_rebalance_detail_advisory.json'
EMPTY_TL = 'm7/m7_rebalance_empty.json'
D6 = 'm7/m7_next_rebalance_d6.json'
COUNTDOWN = 'm7/m7_next_rebalance_countdown.json'
NONE = 'm7/m7_next_rebalance_none.json'
SIM = 'm7/m7_rebalance_sim.json'
PV_DEFAULT = 'm7/m7_rebalance_preview_default.json'
PV_IN_BAND = 'm7/m7_rebalance_preview_in_band.json'
PV_BLOCKED = 'm7/m7_rebalance_preview_blocked.json'
ANNUAL = 'm7/m7_annual_2026.json'
ANNUAL_FIRST = 'm7/m7_annual_first_year.json'
ANNUAL_OFF = 'm7/m7_annual_offwindow.json'
LADDER = 'm7/aftertax_ladder_1.json'
GAP_1 = 'm7/execution_gap_1.json'
GAP_CANT = 'm7/execution_gap_cant.json'
GAP_WONT = 'm7/execution_gap_wont.json'
GAP_MIXED = 'm7/execution_gap_mixed.json'
GAP_EMPTY = 'm7/execution_gap_empty.json'
GAP_NA = 'm7/execution_gap_not_applicable.json'
GAP_MASKED = 'm7/execution_gap_masked_recon.json'
TRUST_4 = 'm7/ledger_trust_4.json'
MONTHLY_LINKED = ['m7/m7_monthly_2026_08.json', 'm7/m7_monthly_gap.json',
                  'm7/m7_monthly_masked_recon.json']
MONTHLY_UNLINKED = ['m7/m7_monthly_masked_integrity.json', 'm7/m7_monthly_pending.json']

NEW_FILES = [PV_DEFAULT, PV_IN_BAND, PV_BLOCKED, NONE, SIM, ANNUAL_OFF, GAP_EMPTY, GAP_NA, GAP_MASKED]
REVISED = [R6, BAND, ADVISORY, ANNUAL, ANNUAL_FIRST, LADDER, GAP_1, GAP_CANT, GAP_WONT, GAP_MIXED] \
    + MONTHLY_LINKED
RENAMED = {D6: COUNTDOWN}
# R12 표시 픽스처(신설 + 개정 + 개명 · 월간 3벌은 링크만 바뀌어 메모 검사 밖).
R12_CONTENT = NEW_FILES + [R6, BAND, ADVISORY, ANNUAL, ANNUAL_FIRST, LADDER,
                           GAP_1, GAP_CANT, GAP_WONT, GAP_MIXED, COUNTDOWN]
# SleeveWeight 를 싣는 R12 픽스처(C-31 ⓐ 확장 · basis = ACCOUNTING).
SLEEVE_FILES = [R6, BAND, ADVISORY, SIM, PV_DEFAULT, PV_IN_BAND]

# ── 문장(엔진 문장 예시 · 보강안 §3-1·§3-2 글자 그대로) ────────────────────
OBSERVED_LABEL = '자료 기준 2026-08-31'
BAND_SUMMARY = '슬리브 B 가 목표에서 5.8%p 벗어나 밴드 상단(47.0%)을 넘어 리밸런싱했습니다.'
SEASONAL_COMPARE = {
    'metric_key': 'trend_score_kr', 'metric_label': '추세 점수', 'observed_text': '0.42',
    'threshold_text': '0.35 이상', 'passed': True, 'verdict_label': '진입 게이트 통과',
}
ADVISORY_LINK_LABEL = '이 회차의 기록 2건'
COUNTDOWN_D_DAY = 'D-1'
COUNTDOWN_NOTICE = '예정일은 거래일 달력으로 정해집니다.'
NONE_LABEL = '예정된 리밸런싱 회차가 아직 없습니다.'
SIM_MODE_LABEL = '모의'
SIM_SECTION_LABEL = '모의투자 회차'
PV_AS_OF_LABEL = '초안 기준 2026-08-31 종가'
PV_NOTICE = '미리보기입니다. 회차일 종가로 다시 계산하며 주문을 내지 않습니다.'
PV_COST_NOTE = '수수료·세금은 가정 비율의 추정치이며 체결 뒤 실측으로 바뀝니다.'
PV_EMPTY_TEXT = '모든 슬리브가 밴드 안이라 이번 회차에 낼 초안이 없습니다.'
PV_WARNING = '예정일까지 가격이 움직이면 초안이 생길 수 있습니다.'
PV_BLOCKED_0 = '원장 무결성 점검 중에는 리밸런싱 초안을 계산하지 않습니다.'
PV_BLOCKED_1 = '재개 점검이 끝나지 않아 초안을 계산하지 않습니다. 재개 리포트를 먼저 확인해 주세요.'
PV_CHIP = {'code': 'REBALANCE_BAND', 'label': 'B 목표 대비 이탈 조정', 'tone': 'NEUTRAL',
           'detail_deep_link': 'handbook://rebalance/band'}
REFERENCE_ONLY_LABEL = '골든 참고치입니다. 실계좌로 산출한 값이 아닙니다.'
LADDER_BASIS = {
    '세율 가정과 계좌 배치는 엔진 설정에서 옵니다. 화면이 곱하지 않습니다.':
        '세율 가정과 계좌 배치는 엔진 설정에서 옵니다.',
    '계좌 배치가 갈래를 정합니다(SAF-309). 화면·인자로 고르지 않습니다.':
        '계좌 배치가 갈래를 정합니다.',
}
ANNUAL_LINE_OLD = '월간 13항목에는 넣지 않습니다.'
ANNUAL_LINE_NEW = '월간 리포트에는 세후를 싣지 않습니다.'
OFF_WINDOW_LABEL = '연간 점검 창이 닫혀 있습니다. 자료는 읽기만 됩니다.'
GAP_WONT_ADVICE = ('고르지 않고 안 한 달입니다. 자동 매매로 옮기는 것을 제안하지 않습니다 — 사후 blind 리뷰와 '
                   '연간 리뷰의 반증 조건 점검에서 규칙 쪽을 다시 봅니다.')
# 금액 가중 이행률(합성 · 스크립트 고정).
GAP_WEIGHTED = {GAP_1: 85, GAP_CANT: 61, GAP_WONT: 55, GAP_MIXED: 52}
GAP_EMPTY_LABEL = '이 기간에는 발행된 안내가 없습니다.'
GAP_NA_LABEL = '자동 매매 구간이라 안내 이행 리포트가 없습니다. 지난 안내 구간의 리포트는 그대로 남습니다.'


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


# ────────────────────────────────────────────────────────────────────────
# 렌더러 — 기존 픽스처의 꼴(평평한 객체 = 한 줄 · 행 = 여러 줄 · 평평한 객체 목록 = 한 줄씩)
# 🔵 기준 원문을 이 렌더러로 다시 쓰면 rebalance_6·band·advisory·d6·annual 2벌·사다리·이행 갭 3벌이
#    글자 그대로 같다(이행 갭 mixed 의 trust 만 한 줄로 접힌다).
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


def envelope(as_of, rows, extra=None):
    env = {'meta': None, 'as_of': as_of, 'empty_kind': 'NO_DATA', 'empty_label': None,
           'has_more': False, 'rows': rows}
    if extra:
        env.update(extra)
    return env


def render_revised(rel, env):
    """개정 — 기준 원문의 meta 블록(버전만 올림)을 그대로 쓴다."""
    return render(bump(meta_text(base_text(rel)), rel), env)


def render_new(env):
    return render(NEW_META, env)


# ────────────────────────────────────────────────────────────────────────
# SleeveWeight.label 생성 규칙(보강안 §3-0 · 코드 정본 rebalance.dart «목표 대비 편차·밴드 여유»)
# ────────────────────────────────────────────────────────────────────────
def pct(x):
    return (Decimal(repr(x)) * 100).quantize(Decimal('0.1'), rounding=ROUND_HALF_UP)


def signed_pp(d):
    if d == 0:
        return '0.0%p'
    return ('+%s%%p' % d) if d > 0 else ('−%s%%p' % (-d))


def sleeve_label(w):
    cur, tgt = pct(w['weight']), pct(w['target_weight'])
    lo, hi = pct(w['band_low']), pct(w['band_high'])
    if cur > hi:
        tail = '밴드 상단 %s%%p 초과' % (cur - hi)
    elif cur < lo:
        tail = '밴드 하단 %s%%p 초과' % (lo - cur)
    else:
        tail = '밴드 여유 %s%%p' % min(cur - lo, hi - cur)
    return '%s %s%% (목표 %s%%, 편차 %s, %s)' % (w['sleeve'], cur, tgt, signed_pp(cur - tgt), tail)


def relabel(weights):
    out = []
    for w in weights:
        w = dict(w)
        assert w['basis'] == 'ACCOUNTING', w
        w['label'] = sleeve_label(w)
        out.append(w)
    return out


def weights(spec):
    """(sleeve, weight) 목록 → SleeveWeight 행(목표·밴드 = rebalance_6 의 슬리브 값 · 라벨 = 규칙)."""
    bands = {w['sleeve']: w for w in base_env(R6)['rows'][0]['before']}
    out = []
    for sleeve, weight in spec:
        b = bands[sleeve]
        out.append({'sleeve': sleeve, 'basis': 'ACCOUNTING', 'weight': weight,
                    'target_weight': b['target_weight'], 'band_low': b['band_low'],
                    'band_high': b['band_high'], 'label': ''})
    total = sum(Decimal(repr(w)) for _s, w in spec)
    assert total == 1, (spec, total)
    return relabel(out)


# ────────────────────────────────────────────────────────────────────────
# 리밸런싱 회차(S7-6a/b)
# ────────────────────────────────────────────────────────────────────────
def observed_as_of():
    a = dict(base_env(R6)['as_of'])
    assert a['observed_at'] == '2026-08-31T09:00:00Z' and a['trade_date'] == '2026-08-31', a
    a['label'] = OBSERVED_LABEL
    return a


def event_row(src, trigger, thresholds, as_of, mode_label=None, section_label=None):
    row = {'event_id': src['event_id'], 'mode': src['mode']}
    if mode_label is not None:
        row['mode_label'] = mode_label
    if section_label is not None:
        row['section_label'] = section_label
    for k in ('trade_date', 'kind', 'kind_label'):
        row[k] = src[k]
    row['before'] = relabel(src['before'])
    row['after'] = relabel(src['after'])
    row['trigger'] = trigger
    row['thresholds'] = thresholds
    row['order_intent_ids'] = src['order_intent_ids']
    if 'journal_timeline_link' in src:
        row['journal_timeline_link'] = src['journal_timeline_link']
    row['detail_deep_link'] = src['detail_deep_link']
    row['as_of'] = as_of
    if 'quality' in src:
        row['quality'] = src['quality']
    return row


def band_compare(band_src):
    """E3 대조 행 — B 목표 대비 이탈폭(관측) ↔ 등록 임계(threshold_registered) · 값은 행에서 계산."""
    b = next(w for w in band_src['before'] if w['sleeve'] == 'B')
    dev = pct(b['weight']) - pct(b['target_weight'])
    reg = band_src['trigger']['threshold_registered']
    thr = pct(reg)
    assert dev > thr
    assert Decimal(band_src['trigger']['raw_values']['band_breach_width']) * 100 == dev
    return {'metric_key': 'band_breach_width', 'metric_label': 'B 목표 대비 이탈폭',
            'observed_text': '%s%%p' % dev, 'threshold_text': '%s%%p 초과' % thr,
            'passed': True, 'verdict_label': '발동'}


def rebalance_rows():
    """rebalance_6 의 6행(내림차순)과 band 행(상세 픽스처와 JSON 동일)."""
    live = base_env(R6)['rows']
    band_base = base_env(BAND)['rows'][0]
    as_of = observed_as_of()
    rows, band_row = [], None
    for src in live:
        kind = src['kind']
        if kind == 'BAND':
            assert src['event_id'] == band_base['event_id'] == 're_20260601_01'
            for k in ('before', 'after', 'order_intent_ids', 'journal_timeline_link',
                      'detail_deep_link', 'quality'):
                assert src[k] == band_base[k], k
            trig = dict(band_base['trigger'])
            trig['summary'] = BAND_SUMMARY
            row = event_row(src, trig, [band_compare(band_base)], as_of)
            band_row = row
        elif kind == 'SEASONAL':
            trig = dict(src['trigger'])
            assert trig['threshold_registered'] == 0.35
            assert trig['raw_values']['trend_score_kr'] == SEASONAL_COMPARE['observed_text']
            row = event_row(src, trig, [dict(SEASONAL_COMPARE)], as_of)
        else:
            assert kind in ('MONTHLY_REGULAR', 'DEPOSIT'), kind
            trig = {k: v for k, v in src['trigger'].items() if k != 'threshold_registered'}
            row = event_row(src, trig, [], as_of)
        rows.append(row)
    rows.sort(key=lambda r: r['trade_date'], reverse=True)
    assert band_row is not None
    return rows, band_row


def sim_rows(as_of):
    live = {r['event_id']: r for r in base_env(R6)['rows']}
    out = []
    for i, (date, src_id) in enumerate([('2026-08-03', 're_20260803_01'),
                                        ('2026-07-01', 're_20260701_01')]):
        src = live[src_id]
        eid = 're_sim_%s_01' % date.replace('-', '')
        fake = {
            'event_id': eid, 'mode': 'SIM_INTERNAL', 'trade_date': date,
            'kind': 'MONTHLY_REGULAR', 'kind_label': '월간 정기',
            'before': src['before'], 'after': src['after'],
            'order_intent_ids': ['i_%s_1' % eid, 'i_%s_2' % eid],
            'detail_deep_link': ROUTE_REBALANCE_EVENT.replace(':rebalanceEventId', eid),
        }
        trig = {'config_hash': src['trigger']['config_hash'],
                'raw_values': dict(src['trigger']['raw_values']),
                'summary': '월간 정기 판정으로 %s 모의투자 회차를 실행했습니다.' % date}
        out.append(event_row(fake, trig, [], as_of, mode_label=SIM_MODE_LABEL,
                             section_label=SIM_SECTION_LABEL if i == 0 else None))
    return out


# ────────────────────────────────────────────────────────────────────────
# 다음 회차·미리보기(S7-6c)
# ────────────────────────────────────────────────────────────────────────
def countdown_env():
    env = base_env(D6)
    row = env['rows'][0]
    assert row['expected_date_text'] == '2026년 9월 1일' and row['d_day_text'] == 'D-6', row
    assert row['preview_route'] == ROUTE_PREVIEW
    row['d_day_text'] = COUNTDOWN_D_DAY
    row['notice_text'] = COUNTDOWN_NOTICE
    row['as_of'] = env['as_of']
    return env


def none_env():
    as_of = base_env(D6)['as_of']
    return envelope(as_of, [{'empty_label': NONE_LABEL, 'as_of': as_of}])


def preview_as_of():
    a = dict(observed_as_of())
    a['label'] = PV_AS_OF_LABEL
    return a


def preview_head(as_of):
    return {'plan_id': 'pv_re_20260901_01', 'planned_date': '2026-09-01',
            'planned_date_text': '2026년 9월 1일 회차', 'as_of': as_of}


def draft(symbol, label, sleeve, side, side_label, qty, price, price_text):
    return {'symbol': symbol, 'symbol_label': label, 'sleeve': sleeve, 'account_alias': '연금저축',
            'side': side, 'side_label': side_label, 'quantity': qty, 'quantity_text': '%d주' % qty,
            'limit_price': price, 'limit_price_text': price_text, 'reasons': [dict(PV_CHIP)]}


def costs(c, t, total, total_text):
    return {'commission': c, 'tax': t, 'total': total, 'total_text': total_text,
            'source': 'ESTIMATED', 'source_label': '추정치', 'basis_note': PV_COST_NOTE}


def preview_default_env():
    as_of = preview_as_of()
    p = preview_head(as_of)
    p['before'] = weights([('A', 0.188), ('B', 0.437), ('C', 0.318), ('POT', 0.038), ('CASH', 0.019)])
    p['after'] = weights([('A', 0.198), ('B', 0.424), ('C', 0.318), ('POT', 0.04), ('CASH', 0.02)])
    p['order_drafts_title'] = '주문 초안'
    p['order_drafts'] = [
        draft('133690', '133690 TIGER 미국나스닥100', 'B', 'SELL', '매도', 2, '16380', '16,380원'),
        draft('069500', '069500 KODEX 200', 'A', 'BUY', '매수', 1, '19150', '19,150원'),
    ]
    p['costs'] = costs('128', '0', '128', '약 128원')
    p['preview_notice'] = PV_NOTICE
    p['warning_lines'] = []
    return envelope(as_of, [{'preview': p}])


def preview_in_band_env():
    as_of = preview_as_of()
    p = preview_head(as_of)
    w = [('A', 0.199), ('B', 0.421), ('C', 0.32), ('POT', 0.04), ('CASH', 0.02)]
    p['before'] = weights(w)
    p['after'] = weights(w)
    p['order_drafts_title'] = '주문 초안'
    p['order_drafts'] = []
    p['orders_empty_text'] = PV_EMPTY_TEXT
    p['costs'] = costs('0', '0', '0', '예상 비용 없음')
    p['preview_notice'] = PV_NOTICE
    p['warning_lines'] = [PV_WARNING]
    return envelope(as_of, [{'preview': p}])


def preview_blocked_env():
    return envelope(preview_as_of(), [
        {'blocked_text': PV_BLOCKED_0},
        {'blocked_text': PV_BLOCKED_1,
         'blocked_action': {'label': '재개 리포트 보기', 'deep_link': ROUTE_RESUME_REPORT}},
    ])


# ────────────────────────────────────────────────────────────────────────
# 연간 리뷰(S7-7) · 세후 사다리
# ────────────────────────────────────────────────────────────────────────
def ladder_env():
    env = base_env(LADDER)

    def fix(lad):
        assert lad['is_reference_only'] is True
        assert lad['basis_note'] in LADDER_BASIS, lad['basis_note']
        out = {}
        for k, v in lad.items():
            out[k] = LADDER_BASIS[v] if k == 'basis_note' else v
            if k == 'is_reference_only':
                out['reference_only_label'] = REFERENCE_ONLY_LABEL
        return out

    assert len(env['rows']) == 1
    env['rows'] = [fix(env['rows'][0])]
    env['counterfactual'] = fix(env['counterfactual'])
    return env


def annual_row(src, ladder, year=None, year_label=None, code=None, label=None):
    row = {}
    for k, v in src.items():
        if k == 'year':
            row['year'] = year or v
            row['year_label'] = year_label or ('%s년 연간 리뷰' % v)
        elif k == 'window_state_code':
            row[k] = code or v
        elif k == 'window_state_label':
            row[k] = label or v
        elif k == 'sections':
            secs = []
            for s in v:
                s = dict(s)
                if s['code'] in ('B_AFTERTAX', 'C_EXECUTION'):
                    s.pop('route', None)   # 갈 곳 없는 버튼 · ㉟ 제3 진입 0(K16)
                s['lines'] = [ANNUAL_LINE_NEW if x == ANNUAL_LINE_OLD else x for x in s['lines']]
                secs.append(s)
            row[k] = secs
        else:
            row[k] = v
    row['after_tax'] = copy.deepcopy(ladder['rows'][0])
    row['after_tax_counterfactual'] = copy.deepcopy(ladder['counterfactual'])
    return row


def annual_env(rel, ladder):
    env = base_env(rel)
    assert len(env['rows']) == 1
    env['rows'] = [annual_row(env['rows'][0], ladder)]
    return env


def annual_off_env(ladder):
    env = base_env(ANNUAL)
    src = env['rows'][0]
    row = annual_row(src, ladder, year='2025', year_label='2025년 연간 리뷰', code='CLOSED',
                     label=OFF_WINDOW_LABEL)
    return envelope(env['as_of'], [row])


# ────────────────────────────────────────────────────────────────────────
# 이행 갭(S7-10)
# ────────────────────────────────────────────────────────────────────────
INT_KEYS = ['issued', 'filled', 'partial', 'skipped', 'lapsed', 'revoked', 'late_filled',
            'backdated_count', 'self_report_correction_count']


def count_lines(r, q=None):
    def n(k):
        return '?' if q else r[k]
    return ['안내 %s건' % n('issued'),
            '이행 %s건 · 부분 이행 %s건 · 지연 이행 %s건' % (n('filled'), n('partial'), n('late_filled')),
            '건너뜀 %s건 · 만료 %s건 · 철회 %s건' % (n('skipped'), n('lapsed'), n('revoked'))]


def correction_lines(r, q=None):
    if q:
        return ['소급 기록 ?건', '자가 보고 정정 ?건']
    if r['backdated_count'] == 0 and r['self_report_correction_count'] == 0:
        return []
    return ['소급 기록 %d건' % r['backdated_count'],
            '자가 보고 정정 %d건' % r['self_report_correction_count']]


PRICE_GAP = re.compile(r'^권장가 대비 (\+[0-9]+bp)$')
RATE = re.compile(r'^이행률 ([0-9]+)%$')


def gap_env(rel):
    env = base_env(rel)
    assert len(env['rows']) == 1
    src = env['rows'][0]
    rep = {}
    for k, v in src.items():
        if k in ('mode_advice_line', 'as_of'):
            continue
        if k == 'compliance_rate_label':
            m = RATE.match(v)
            assert m, v
            late = src['late_filled']
            head = '이행률 %s%%(건수%s)' % (m.group(1), ' · 지연 이행 %d건 포함' % late if late else '')
            rep[k] = '%s · %d%%(금액 가중)' % (head, GAP_WEIGHTED[rel])
        elif k == 'price_gap_label':
            m = PRICE_GAP.match(v)
            assert m, v
            rep[k] = '안내 대비 중앙값 %s(불리)' % m.group(1)
        else:
            rep[k] = v
    rep['count_lines'] = count_lines(src)
    rep['correction_lines'] = correction_lines(src)
    # B21 3갈래: cant = ⓐ 유지 · wont = ⓑ 문장 안 언급 · _1·mixed = 키 삭제(null · ⓒ·정상 달).
    assert 'mode_advice_line' in src, rel
    if rel == GAP_CANT:
        rep['mode_advice_line'] = src['mode_advice_line']
    elif rel == GAP_WONT:
        rep['mode_advice_line'] = GAP_WONT_ADVICE
    rep['as_of'] = src['as_of']
    env['rows'] = [{'report': rep, 'as_of': rep['as_of']}]
    return env


def gap_masked_env():
    env1 = base_env(GAP_1)
    src = env1['rows'][0]
    trust = next(r for r in base_env(TRUST_4)['rows'] if r['grade'] == 'DRIFTING')
    rep = {'range': src['range'], 'period_label': src['period_label']}
    for k in INT_KEYS[:7]:
        rep[k] = src[k]
    rep['compliance_rate_label'] = '이행률 ?'
    rep['median_delay_label'] = '기록까지 중앙값 ?'
    rep['price_gap_label'] = '안내 대비 중앙값 ?bp'
    rep['amend_chain_max_label'] = '정정 체인 최대 ?회'
    rep['skip_reason_buckets'] = []
    rep['selective_execution_chips'] = []
    rep['backdated_count'] = src['backdated_count']
    rep['self_report_correction_count'] = src['self_report_correction_count']
    rep['trust'] = copy.deepcopy(trust)
    rep['count_lines'] = count_lines(src, q=True)
    rep['correction_lines'] = correction_lines(src, q=True)
    rep['as_of'] = src['as_of']
    assert rep['period_label'] == '2026년 8월'
    return envelope(env1['as_of'], [{'report': rep, 'as_of': rep['as_of']}])


def gap_empty_env(kind, label):
    as_of = base_env(GAP_1)['as_of']
    return envelope(as_of, [{'empty_kind': kind, 'empty_label': label, 'as_of': as_of}])


# ────────────────────────────────────────────────────────────────────────
# 월간 리포트 ⑧ 링크(S7-1 → S7-10 그 달) — 글자 치환(다른 글자 불변)
# ────────────────────────────────────────────────────────────────────────
def monthly_text(rel):
    s = bump(base_text(rel), rel)
    env = json.loads(s)
    yyyy_mm = env['rows'][0]['yyyy_mm']
    assert yyyy_mm == '2026-08', (rel, yyyy_mm)
    old = '"detail_deep_link": "%s"' % ROUTE_GAP
    assert s.count(old) == 1, rel
    return s.replace(old, '"detail_deep_link": "%s"' % ROUTE_GAP_MONTH.replace(':yyyyMm', yyyy_mm))


# ────────────────────────────────────────────────────────────────────────
# 규약 자가 검사(§3-0) — 어기면 쓰기 전에 멈춘다
# ────────────────────────────────────────────────────────────────────────
def strings(node, path=''):
    if isinstance(node, str):
        yield path, node
    elif isinstance(node, dict):
        for k, v in node.items():
            yield from strings(v, '%s.%s' % (path, k) if path else k)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            yield from strings(v, '%s[%d]' % (path, i))


def walk_dicts(node):
    if isinstance(node, dict):
        yield node
        for v in node.values():
            yield from walk_dicts(v)
    elif isinstance(node, list):
        for v in node:
            yield from walk_dicts(v)


def self_check_file(rel, s, new=False):
    assert '\r' not in s, rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE', rel    # C-15 — 봉투 meta.mode 전량 LIVE(SIM 은 행 mode)
    body = body_without_meta(s)
    for rx in RETIRED:
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    keys = list(env.keys())
    assert keys[:6] == ENVELOPE_KEYS, (rel, keys)
    if new:
        assert keys == ENVELOPE_KEYS, (rel, keys)   # 봉투 최상위 키 추가 0
        # 새 파일 이름에 값 금지(03 §15 · 폴더 접두 `m7_` 밖 숫자 0).
        assert not re.search(r'[0-9]', re.sub(r'^m7_', '', os.path.basename(rel))), rel
    else:
        assert keys == list(json.loads(base_text(rel if rel not in RENAMED.values() else D6)).keys()), rel
    return env


def self_check_content(rel, env):
    if env['rows']:
        assert env['empty_kind'] == 'NO_DATA' and env['empty_label'] is None, rel
    for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
        assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
        assert not DEV_MEMO.search(v), '%s %s — 사용자 문장 자리의 개발자 메모: %s' % (rel, path, v)
    for d in walk_dicts(env['rows']):
        if 'preview_notice' in d:
            assert d['preview_notice'].startswith('미리보기입니다'), rel
        if 'account_alias' in d:
            assert d['account_alias'] in ACCOUNT_ALIASES, (rel, d['account_alias'])
            if d.get('sleeve') == 'B':
                assert d['account_alias'] in PENSION_ALIASES, (rel, d)
        for k in ('limit_price', 'commission', 'tax', 'total'):
            if k in d and d[k] is not None:
                assert isinstance(d[k], str) and DECIMAL_CANON.match(d[k]), (rel, k, d[k])
        if 'limit_price' in d:
            assert (d.get('limit_price_text') is None) == (d['limit_price'] is None), rel
        if 'preview' in d or 'blocked_text' in d or 'report' in d or 'empty_kind' in d:
            assert all(v is not None for v in d.values()), '%s — 래퍼에는 있는 키만 싣는다' % rel


def self_check_sleeves(rel, env):
    n = 0
    for d in walk_dicts(env['rows']):
        if 'target_weight' in d:
            assert d['basis'] == 'ACCOUNTING', rel
            assert d['label'] == sleeve_label(d), (rel, d['label'])
            assert '%' in d['label'], rel
            n += 1
    assert n > 0, rel
    return n


# ────────────────────────────────────────────────────────────────────────
def main():
    rels = base_files()
    assert set(RENAMED) <= set(rels) and not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다'
    assert not (set(RENAMED.values()) & set(rels))

    out = {}
    # ── 개정 ──
    r6_rows, band_row = rebalance_rows()
    obs = observed_as_of()
    out[R6] = render_revised(R6, envelope(obs, r6_rows))
    out[BAND] = render_revised(BAND, envelope(obs, [band_row]))
    adv_row = copy.deepcopy(band_row)
    base_adv = base_env(ADVISORY)['rows'][0]
    assert base_adv['journal_timeline_link']['label'] == ADVISORY_LINK_LABEL
    adv_row['journal_timeline_link'] = dict(band_row['journal_timeline_link'],
                                            label=ADVISORY_LINK_LABEL)
    out[ADVISORY] = render_revised(ADVISORY, envelope(obs, [adv_row]))
    ladder = ladder_env()
    out[LADDER] = render_revised(LADDER, ladder)
    out[ANNUAL] = render_revised(ANNUAL, annual_env(ANNUAL, ladder))
    out[ANNUAL_FIRST] = render_revised(ANNUAL_FIRST, annual_env(ANNUAL_FIRST, ladder))
    for rel in (GAP_1, GAP_CANT, GAP_WONT, GAP_MIXED):
        out[rel] = render_revised(rel, gap_env(rel))
    for rel in MONTHLY_LINKED:
        out[rel] = monthly_text(rel)
    # ── 개명 ──
    out[COUNTDOWN] = render(bump(meta_text(base_text(D6)), D6), countdown_env())
    # ── 신설 ──
    out[SIM] = render_new(envelope(obs, sim_rows(obs)))
    out[NONE] = render_new(none_env())
    out[PV_DEFAULT] = render_new(preview_default_env())
    out[PV_IN_BAND] = render_new(preview_in_band_env())
    out[PV_BLOCKED] = render_new(preview_blocked_env())
    out[ANNUAL_OFF] = render_new(annual_off_env(ladder))
    out[GAP_EMPTY] = render_new(gap_empty_env('NO_DATA', GAP_EMPTY_LABEL))
    out[GAP_NA] = render_new(gap_empty_env('NOT_APPLICABLE', GAP_NA_LABEL))
    out[GAP_MASKED] = render_new(gap_masked_env())
    # ── 버전 줄만 ──
    untouched = [r for r in rels if r not in out and r not in RENAMED]
    for rel in untouched:
        out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(untouched) == 112, len(untouched)
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, new=rel in NEW_FILES) for rel, s in out.items()}
    for rel in R12_CONTENT:
        self_check_content(rel, envs[rel])
    for rel in MONTHLY_LINKED + MONTHLY_UNLINKED:
        for path, v in strings({k: v for k, v in envs[rel].items() if k != 'meta'}):
            assert not FORBIDDEN.search(v), (rel, path)
    sleeves = sum(self_check_sleeves(rel, envs[rel]) for rel in SLEEVE_FILES)
    for rel in NEW_FILES:
        if rel not in (PV_DEFAULT, PV_IN_BAND):   # 미리보기 2벌만 금액 표기를 싣는다
            assert not MONEY.search(body_without_meta(out[rel])), '%s — 금액 꼴' % rel
    # rebalance_6 의 band 행 == 상세 픽스처 행(JSON 전체 · C-41 ⑤)
    r6 = envs[R6]['rows']
    assert [r['trade_date'] for r in r6] == sorted((r['trade_date'] for r in r6), reverse=True)
    assert next(r for r in r6 if r['event_id'] == 're_20260601_01') == envs[BAND]['rows'][0]
    assert all(r['as_of'] == envs[R6]['as_of'] for r in r6)
    # 사다리 사본 = 원천 하나(C-41 ⑥)
    for rel in (ANNUAL, ANNUAL_FIRST, ANNUAL_OFF):
        row = envs[rel]['rows'][0]
        assert row['after_tax'] == envs[LADDER]['rows'][0], rel
        assert row['after_tax_counterfactual'] == envs[LADDER]['counterfactual'], rel
        assert row['year'] in row['year_label'], rel
    # 월간 ⑧ 링크가 없는 2벌은 그대로
    for rel in MONTHLY_UNLINKED:
        assert ROUTE_GAP not in out[rel], rel

    # ── 쓰기 ──
    for rel, s in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(s)
    for old in RENAMED:
        p = FX + '/' + old
        if os.path.exists(p):
            os.remove(p)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r12_v16_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d(개명 %d 포함) · 신설 %d) · '
          'SleeveWeight 라벨 %d · contract 1.6.0'
          % (len(out), BASE_FILES, len(untouched), len(REVISED) + len(RENAMED), len(RENAMED),
             len(NEW_FILES), sleeves))


if __name__ == '__main__':
    main()
