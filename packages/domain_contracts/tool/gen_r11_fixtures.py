#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.4(R11 선행 M2 보강) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r11_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r10_fixtures.py(계약 v1.3)를 본떴다.

하는 일(설계서 2026-09-30 §2 Δ3 · §3 «3. 픽스처 명세»)
  (a) 전 봉투의 "contract_version": "1.3.0" → "1.4.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 16건
      - 입금 계획 5: m7_deposit_plan_default·_limit·_expired(행 = DepositPreviewResult 래퍼) ·
        deposit_plan_1·deposit_plan_funding_1(행 = DepositPlan · 코어 전용).
      - 목표 경로 3: m7_goal_path_on·_hold·_realworld(GoalPathVm v1.4 · 봉투 lag_notice 삭제).
      - 월간 리포트 5: m7_monthly_2026_08·_gap 에 goal_deep_link 한 줄 ·
        _masked_integrity·_masked_recon·_pending 은 키 없음(버전 줄만).
      - 인출 3: m7_withdrawal_* 초안 행에 side_label·quantity_text 두 줄만(기계적 · 내용은 인출 규칙 결정 뒤 첫 minor).
  (c) 신설 7건
      m9/contribution_setting_default · m9/contribution_setting_no_limit_note ·
      m7/m7_deposit_plan_blocked · m7/m7_deposit_plan_input_rejected · m7/m7_deposit_plan_funding ·
      m7/m7_deposit_register_receipts_4 · m7/m7_goal_path_off
  (d) 규약을 스크립트 안에서 먼저 확인한다(어기면 멈춘다) — 금액 예시값 100000 하나 ·
      폐기 운영값 0(fixture_conventions_test 와 같은 정규식) · Σ 충당 + 잔여 == 입금액 ·
      슬리브별 매수 초안 합 ≤ 충당액 · 슬리브 B 는 연금 계좌 · previewNotice 는 «미리보기입니다» ·
      목표 경로 정규 자리·눈금·구간.

멱등: 개정 16건은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
정규 자리는 분수(Fraction)로 계산하고 마지막에만 소수 넷째 자리로 반올림한다.

전제: git 이 있고, 저장소에 기준 커밋이 있다(얕은 클론이면 먼저 `git fetch --unshallow`).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r11_fixtures.py
"""
import datetime
import io
import json
import os
import re
import subprocess
import sys
from decimal import Decimal
from fractions import Fraction

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
# 스크립트 자리 = <루트>/packages/domain_contracts/tool → 픽스처 = ../fixtures · 루트 = ../../..
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures')).replace(os.sep, '/')
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/')
FX_REL = os.path.relpath(FX, ROOT).replace(os.sep, '/')
# 계약 1.3.0 · 픽스처 115 의 기준 커밋(origin/main 에 있다).
BASE = '52071952b56ccd509a30a4408d0063571fa17cdf'

OLD_VER = '"contract_version": "1.3.0"'
NEW_VER = '"contract_version": "1.4.0"'
WANT_FILES = 122

# fixture_conventions_test.dart `_retiredContributionValues` 와 같은 정규식(폐기 운영값).
RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
# 금액 예시값(월 납입 운영값의 픽스처 표본) — 하나만 쓴다(fixture_conventions_test 머리 주석).
EXAMPLE_AMOUNT = 100000

PENSION_ALIASES = ('연금저축', 'IRP')      # README «픽스처 계좌 별칭 표» · fixture_accounts.dart
ALL_ALIASES = ('연금저축', 'IRP', '일반')
PREVIEW_NOTICE = '미리보기입니다. 실제 입금이 확인되면 다시 계산합니다.'


# ────────────────────────────────────────────────────────────────────────
# 파일 입출력
# ────────────────────────────────────────────────────────────────────────
def base_text(rel):
    out = subprocess.check_output(
        ['git', '-C', ROOT, 'show', '%s:%s/%s' % (BASE, FX_REL, rel)])
    s = out.decode('utf-8')
    assert '\r' not in s, rel
    return s


def write_disk(rel, s):
    assert '\r' not in s
    assert s.endswith('}\n')
    json.loads(s)  # 문법 확인
    for rx in RETIRED:
        assert not rx.search(s), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    io.open(FX + '/' + rel, 'w', encoding='utf-8', newline='').write(s)


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def base_meta(rel):
    """기준 원문의 meta 블록(줄 그대로 · 버전만 올림)."""
    lines = bump(base_text(rel), rel).split('\n')
    i = lines.index('  "meta": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '  },')
    return '\n'.join(lines[i:j + 1])


NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.4.0",
    "generated_at": "2026-09-30T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20260930,
    "notice": "합성 데이터. 실계좌·실키 없음."
  },'''


# ────────────────────────────────────────────────────────────────────────
# 수 다루기
# ────────────────────────────────────────────────────────────────────────
class Dbl(object):
    """JSON double 로 적을 값(Fraction). 소수점 아래 한 자리 이상("0.0" · "0.1429")."""

    def __init__(self, x):
        self.x = Fraction(x)


def r4(x):
    """소수 넷째 자리 반올림(반올림 = 0.5 는 0 에서 먼 쪽)."""
    x = Fraction(x)
    sign = -1 if x < 0 else 1
    n = (abs(x) * 10000 + Fraction(1, 2)).__floor__()
    return Fraction(sign * n, 10000)


def num(x):
    x = Fraction(x)
    assert 10000 % x.denominator == 0, x
    n = x.numerator * (10000 // x.denominator)
    sign = '-' if n < 0 else ''
    n = abs(n)
    ip, fp = divmod(n, 10000)
    fs = ('%04d' % fp).rstrip('0') or '0'
    return '%s%d.%s' % (sign, ip, fs)


def won(n):
    """원 단위 글자(«19,150원»)."""
    return '{:,}원'.format(n)


def man(n):
    """만·천 단위 글자(«4만 2천원» · «10만원» · «6천원» · «1,800만원»)."""
    assert n > 0 and n % 1000 == 0, n
    m, rest = divmod(n, 10000)
    parts = []
    if m:
        parts.append('{:,}만'.format(m))
    if rest:
        parts.append('%d천' % (rest // 1000))
    return ' '.join(parts) + '원'


# ────────────────────────────────────────────────────────────────────────
# 글자로 내보내기(기존 픽스처의 손 모양을 본뜬다)
# ────────────────────────────────────────────────────────────────────────
# 값이 한 줄 객체로 적히는 키(기존 픽스처와 같은 모양).
INLINE_DICT = {'as_of', 'costs', 'blocked_action'}
# 원소가 한 줄 객체로 적히는 목록.
INLINE_ITEMS = {'allocations', 'reasons', 'funding_steps', 'planned', 'actual',
                'y_ticks', 'segments'}


def scalar(v):
    if v is None:
        return 'null'
    if v is True:
        return 'true'
    if v is False:
        return 'false'
    if isinstance(v, Dbl):
        return num(v.x)
    if isinstance(v, int):
        return str(v)
    assert isinstance(v, str), v
    return json.dumps(v, ensure_ascii=False)


def inline(v):
    if isinstance(v, dict):
        return '{ ' + ', '.join('%s: %s' % (json.dumps(k), inline(x))
                                for k, x in v.items()) + ' }'
    if isinstance(v, list):
        return '[' + ', '.join(inline(x) for x in v) + ']'
    return scalar(v)


def emit(v, ind, key=None):
    """여러 줄 모양. [ind] = 이 값이 놓인 줄의 들여쓰기(칸 수)."""
    pad = ' ' * ind
    if isinstance(v, dict):
        if key in INLINE_DICT:
            return inline(v)
        out = ['{']
        items = list(v.items())
        for i, (k, x) in enumerate(items):
            out.append('%s  %s: %s%s' % (pad, json.dumps(k), emit(x, ind + 2, k),
                                          ',' if i < len(items) - 1 else ''))
        out.append(pad + '}')
        return '\n'.join(out)
    if isinstance(v, list):
        if not v:
            return '[]'
        out = ['[']
        for i, x in enumerate(v):
            body = inline(x) if key in INLINE_ITEMS else emit(x, ind + 2)
            out.append('%s  %s%s' % (pad, body, ',' if i < len(v) - 1 else ''))
        out.append(pad + ']')
        return '\n'.join(out)
    return scalar(v)


def envelope(meta, as_of_d, rows):
    out = ['{', meta,
           '  "as_of": %s,' % inline(as_of_d),
           '  "empty_kind": "NO_DATA",',
           '  "empty_label": null,',
           '  "has_more": false,',
           '  "rows": [']
    for i, r in enumerate(rows):
        out.append('    ' + emit(r, 4) + (',' if i < len(rows) - 1 else ''))
    out += ['  ]', '}']
    return '\n'.join(out) + '\n'


def as_of(date, label, hhmm='09:00'):
    return {'observed_at': '%sT%s:00Z' % (date, hhmm), 'trade_date': date,
            'source': 'LOCAL_SQLITE', 'stale_after_seconds': 93600, 'label': label}


# ────────────────────────────────────────────────────────────────────────
# 입금 계획 — 종목·계좌(SPEC v2.27 · v2.29 · 설계 D9 ②)
# ────────────────────────────────────────────────────────────────────────
# 🔴 티커는 실제 국내 ETF, 수량·가격은 가공값(fixtures/README «대원칙»).
SYM = {
    '069500': ('069500 KODEX 200', 'A'),                 # A 자리표시자(README «값을 고를 때»)
    '133690': ('133690 TIGER 미국나스닥100', 'B'),       # SPEC v2.27 B 80
    '411060': ('411060 ACE KRX금현물', 'B'),             # SPEC v2.27 B 20
    '0085P0': ('0085P0 ACE 미국10년국채액티브', 'C'),    # SPEC v2.29 ② C UST10
}
PRICE = {'069500': 19150, '133690': 16380, '411060': 8940, '0085P0': 10250}
SLEEVE_LABEL = {'A': 'A · 국내 지수 ETF', 'B': 'B · 해외 지수·금 ETF', 'C': 'C · 방어 자산'}
CHIP_DEPOSIT = {'code': 'DEPOSIT_ROUTING', 'label': '월 납입 배분', 'tone': 'NEUTRAL',
                'detail_deep_link': 'handbook://plan/deposit'}
CHIP_FUNDING = {'code': 'PENSION_FUNDING', 'label': '연금 납입 조달', 'tone': 'NEUTRAL',
                'detail_deep_link': 'handbook://plan/deposit'}
BASIS_NOTE = '수수료·세금은 접수 전 추정치이며 체결 후 브로커 원장으로 대체됩니다.'


def allocation(sleeve, amount, alias, reason=None):
    d = {'sleeve': sleeve, 'label': SLEEVE_LABEL[sleeve], 'amount': str(amount),
         'amount_text': man(amount), 'account_alias': alias}
    if reason is not None:
        d['routing_reason_text'] = reason
    return d


def draft(symbol, alias, side, qty, chip, priced=True, pending=None):
    label, sleeve = SYM[symbol]
    d = {'symbol': symbol, 'symbol_label': label, 'sleeve': sleeve,
         'account_alias': alias, 'side': side,
         'side_label': '매수' if side == 'BUY' else '매도',
         'quantity': qty, 'quantity_text': '%d주' % qty}
    if priced:
        d['limit_price'] = str(PRICE[symbol])
        d['limit_price_text'] = won(PRICE[symbol])
    if pending is not None:
        d['pending_note_text'] = pending
    d['reasons'] = [chip]
    return d


def costs(total):
    if total == 0:
        return {'commission': '0', 'tax': '0', 'total': '0',
                'total_text': '주문이 없어 예상 비용이 없습니다', 'source': 'ESTIMATED',
                'source_label': '추정치', 'basis_note': BASIS_NOTE}
    return {'commission': str(total), 'tax': '0', 'total': str(total),
            'total_text': '약 %s' % won(total), 'source': 'ESTIMATED',
            'source_label': '추정치', 'basis_note': BASIS_NOTE}


def pension_limit(consumed, deadline_days, suggestion=None, funding_note=None):
    limit, credit = 18000000, 9000000
    if consumed >= limit:
        a = '올해 연금 합산 납입한도 %s을 모두 썼습니다.' % man(limit)
        t = '세액공제 대상 구간 %s도 모두 채웠습니다.' % man(credit)
    else:
        a = '올해 연금 합산 납입한도 %s 가운데 %s을 썼습니다(이번 입금 포함).' % (
            man(limit), man(consumed))
        t = '세액공제 대상 구간 %s 가운데 %s을 채웠습니다.' % (man(credit), man(consumed))
    d = {'annual_limit_text': a, 'tax_credit_text': t,
         'deadline_text': '올해 납입 마감(12월 31일)까지 %d일 남았습니다.' % deadline_days}
    if suggestion is not None:
        d['suggestion_text'] = suggestion
    if funding_note is not None:
        d['funding_note_text'] = funding_note
    return d


def days_to_year_end(date):
    d = datetime.date(*map(int, date.split('-')))
    return (datetime.date(d.year, 12, 31) - d).days


def plan(plan_id, trade_date, allocs, residual, drafts, cost_total, consumed,
         limit_card, warnings=(), orders_empty=None, register_blocked=None,
         funding=None):
    t = datetime.date(*map(int, trade_date.split('-')))
    nxt = t + datetime.timedelta(days=1)
    deposit = sum(int(a['amount']) for a in allocs) + residual
    assert deposit == EXAMPLE_AMOUNT, (plan_id, deposit)  # C-38 ⑤ · 예시값 하나
    # C-38 ⑥ 슬리브별 매수 초안 합 ≤ 충당액
    for a in allocs:
        buy = sum(x['quantity'] * int(x['limit_price']) for x in drafts
                  if x['sleeve'] == a['sleeve'] and x['side'] == 'BUY')
        assert buy <= int(a['amount']), (plan_id, a['sleeve'], buy)
    for x in drafts:
        if x['side'] == 'BUY':
            assert 'limit_price' in x, '매수 초안은 지정가가 있다(C-38 ⑥ 계산)'
            assert any(a['sleeve'] == x['sleeve'] for a in allocs), (plan_id, x['symbol'])
        assert x['account_alias'] in ALL_ALIASES
        if x['sleeve'] == 'B':
            assert x['account_alias'] in PENSION_ALIASES, 'SPEC v2.23 — B 는 연금 계좌'
    for a in allocs:
        assert a['account_alias'] in ALL_ALIASES
        if a['sleeve'] == 'B':
            assert a['account_alias'] in PENSION_ALIASES, 'SPEC v2.23 — B 는 연금 계좌'
    assert (orders_empty is not None) == (not drafts)
    d = {
        'plan_id': plan_id,
        'computed_at': '%sT21:05:00Z' % trade_date,
        'as_of_trade_date': trade_date,
        'expires_at': '%sT21:05:00Z' % nxt.isoformat(),
        'config_hash': 'cfg_fake_0000000000000000',
        'as_of': as_of(trade_date, '계획 기준 %s 종가' % trade_date),
        'deposit_amount': str(deposit),
        'deposit_amount_text': man(deposit),
        'allocations': allocs,
        'pension_limit_consumed': str(consumed),
    }
    if limit_card is not None:
        d['pension_limit'] = limit_card
    d['residual_krw_cash'] = str(residual)
    if residual:
        d['residual_krw_cash_text'] = '%s은 원화 현금으로 대기합니다(다음 리밸런싱 재원).' % man(residual)
    d['order_drafts_title'] = '주문 초안'
    d['order_drafts'] = drafts
    if orders_empty is not None:
        d['orders_empty_text'] = orders_empty
    d['costs'] = costs(cost_total)
    d['preview_notice'] = PREVIEW_NOTICE
    d['warning_lines'] = list(warnings)
    if register_blocked is not None:
        d['register_blocked_text'] = register_blocked
    if funding is not None:
        steps = funding
        assert steps, '조달 단계는 null 이거나 비지 않는다(C-38 ④)'
        for i, s in enumerate(steps):
            assert s['order'] == i + 1 and int(s['expected_proceeds']) > 0
    d['funding_steps'] = funding
    return d


def default_plan(plan_id, trade_date):
    """정상 — 연금 라우팅 · 잔여 = 원화 현금 대기(D2) · 한도 카드(제안·조달 안내 없음)."""
    allocs = [allocation('A', 20000, '연금저축'),
              allocation('B', 42000, '연금저축',
                         '해외 ETF 는 연금저축 계좌에서 삽니다(과세 이연).'),
              allocation('C', 32000, '일반')]
    drafts = [draft('069500', '연금저축', 'BUY', 1, CHIP_DEPOSIT),
              draft('133690', '연금저축', 'BUY', 2, CHIP_DEPOSIT),
              draft('411060', '연금저축', 'BUY', 1, CHIP_DEPOSIT),
              draft('0085P0', '일반', 'BUY', 3, CHIP_DEPOSIT)]
    return plan(plan_id, trade_date, allocs, 6000, drafts, 128, 620000,
                pension_limit(620000, days_to_year_end(trade_date)))


def limit_plan():
    """연 합산 납입한도 소진 — B 행 없음(0원 행도 없음 · SPEC v2.23) · A·C 를 일반 계좌로."""
    reason = '올해 연금 납입한도를 다 써서 일반 계좌로 보냅니다.'
    allocs = [allocation('A', 36000, '일반', reason),
              allocation('C', 58000, '일반', reason)]
    return plan(
        'pl_20261201_10', '2026-11-30', allocs, 6000, [], 0, 18000000,
        pension_limit(18000000, days_to_year_end('2026-11-30'),
                      suggestion='이번 입금은 일반 계좌로 넣도록 제안합니다.',
                      funding_note='내년 한도가 열린 뒤 연금 납입이 모자라면 일반 계좌의 '
                                   '방어 자산을 먼저 팔아 조달합니다.'),
        warnings=['올해 연금 납입한도를 다 써서 이번 달에는 슬리브 B 몫을 채우지 못합니다.'],
        orders_empty='계좌를 바꾸는 달에는 주문 초안을 만들지 않습니다. '
                     '일반 계좌 입금이 확인되면 다시 계산합니다.')


def expired_plan():
    p = default_plan('pl_20260829_10', '2026-08-28')
    p['register_blocked_text'] = ('이 계획은 만료되어 실입금을 등록할 수 없습니다. '
                                  '다시 계산해 새 계획을 받아 주세요.')
    # 키 순서를 DTO 순서로 되돌린다(register_blocked_text 는 funding_steps 앞).
    fs = p.pop('funding_steps')
    p['funding_steps'] = fs
    return p


def funding_plan():
    """납입 조달 발동 — 0원 단계 없음 · C 방어 자산 매도 초안 + 조달 칩 · 잔여 0."""
    allocs = [allocation('A', 20000, '연금저축'),
              allocation('B', 42000, '연금저축',
                         '해외 ETF 는 연금저축 계좌에서 삽니다(과세 이연).'),
              allocation('C', 38000, '일반')]
    sell_qty = 2
    drafts = [draft('069500', '연금저축', 'BUY', 1, CHIP_DEPOSIT),
              draft('133690', '연금저축', 'BUY', 2, CHIP_DEPOSIT),
              draft('411060', '연금저축', 'BUY', 1, CHIP_DEPOSIT),
              draft('0085P0', '일반', 'SELL', sell_qty, CHIP_FUNDING, priced=False,
                    pending='직전 매도 1건이 체결 확인 중이라 수량이 바뀔 수 있습니다.')]
    proceeds = sell_qty * PRICE['0085P0']  # 직전 종가 기준 추정(시장가 매도 초안)
    steps = [{'order': 1, 'source_sleeve': 'C', 'symbol': '0085P0',
              'symbol_label': SYM['0085P0'][0], 'quantity': sell_qty,
              'expected_proceeds': str(proceeds), 'rule_cited': '03 §5-5b',
              'label': '원화 현금이 모자라 방어 자산 %d주를 팔아 연금 납입을 조달합니다.' % sell_qty}]
    trade = '2026-09-30'
    return plan('pl_20261001_01', trade, allocs, 0, drafts, 128, 720000,
                pension_limit(720000, days_to_year_end(trade),
                              funding_note='원화 현금이 모자라 방어 자산을 먼저 팔아 조달합니다'
                                           '(연금 계좌 자산은 팔지 않습니다).'),
                funding=steps)


def plan_envelope_as_of(p):
    t = p['as_of_trade_date']
    return as_of(t, '계획 기준 %s 종가' % t)


def write_plan_core(rel, p):
    write_disk(rel, envelope(base_meta(rel), plan_envelope_as_of(p), [p]))


def write_preview(rel, rows, as_of_d, meta=None):
    for r in rows:
        keys = [k for k in ('plan', 'input_rejected_text', 'blocked_text') if k in r]
        assert len(keys) == 1, (rel, keys)  # C-38 ①
        if 'blocked_action' in r:
            assert 'blocked_text' in r
    write_disk(rel, envelope(meta or base_meta(rel), as_of_d, rows))


# ────────────────────────────────────────────────────────────────────────
# 목표 경로(GoalPathVm v1.4)
# ────────────────────────────────────────────────────────────────────────
GOAL_DATES = ['2024-12-31', '2025-03-31', '2025-06-30', '2025-09-30',
              '2025-12-31', '2026-03-31', '2026-06-30', '2026-08-31']
# 계획 경로(만원) — 엔진 몫의 합성값. 🔴 이 값에서 정규 자리·글자를 스크립트가 만든다.
GOAL_PLANNED = [2000, 2080, 2160, 2240, 2330, 2410, 2500, 2560]
GOAL_AS_OF_LABEL = '목표 경로 기준 2026-08-31'
GOAL_COMMON = {
    'honest_expectation_text': '정직 기대는 전 계좌 세후 연 10.2% 안팎입니다.',
    'honest_expectation_worst_text': '세금을 가장 불리하게 가정하면 연 9.7% 안팎입니다.',
    'disclaimer_text': '이 경로는 약속이 아니며 수익을 보증하지 않습니다.',
}
GOAL_BACKTEST = '계획 경로는 백테스트 기준 실행을 정직 기대 수익률로 낮춰 그렸습니다.'
GOAL_START = '당신의 현재 원금과 월 납입 설정에서 출발한 경로입니다.'


def date_text(date):
    y, m, _ = date.split('-')
    return '%d년 %d월' % (int(y), int(m))


def amount_text(man_value):
    return '{:,}만원'.format(man_value)


def goal_axis(values):
    """눈금 간격 = {1,2,5}×10ⁿ 만원 · 눈금 수(양 끝 포함) ≤ 5 가 되는 가장 작은 간격.
    금액 축이라 0 을 넣지 않는다(성과 시리즈와 다른 점 — 기준선 없음)."""
    lo, hi = min(values), max(values)
    steps = sorted(m * 10 ** n for n in range(0, 5) for m in (1, 2, 5))
    for step in steps:
        bottom = (lo // step) * step
        top = -((-hi) // step) * step
        if top == bottom:
            continue
        count = (top - bottom) // step + 1
        if count <= 5:
            return bottom, top, step, count
    raise AssertionError('축을 못 골랐다')


def goal_row(name, actual, judgement, basis, backtest, start, deviation=None,
             gaps=None):
    """actual = 만원 목록(None = 결측) · gaps = [{from, to, label}](UNAVAILABLE 띠)."""
    n = len(GOAL_DATES)
    assert len(actual) == n and len(GOAL_PLANNED) == n
    xs = [Fraction(i, n - 1) for i in range(n)]
    half = Fraction(1, 2) / (n - 1)
    vals = GOAL_PLANNED + [v for v in actual if v is not None]
    bottom, top, step, count = goal_axis(vals)
    assert count <= 5

    def y(v):
        return r4(Fraction(v - bottom, top - bottom))

    def point(i, v, gap=None):
        p = {'date': GOAL_DATES[i], 'x_normalized': Dbl(r4(xs[i])),
             'date_text': date_text(GOAL_DATES[i])}
        if v is None:
            p['value_text'] = '산출 불가'
            p['y_normalized'] = None
            p['value'] = None
            p['gap_reason_code'] = gap
        else:
            p['value_text'] = amount_text(v)
            p['y_normalized'] = Dbl(y(v))
            p['value'] = Dbl(v * 10000)
        return p

    segments = []
    owner = [None] * n
    for g in (gaps or []):
        idx = [i for i, d in enumerate(GOAL_DATES) if g['from'] <= d <= g['to']]
        assert idx and idx == list(range(idx[0], idx[-1] + 1))
        for i in idx:
            assert owner[i] is None and actual[i] is None, (name, i)
            owner[i] = g
        seg = {'from': g['from'], 'to': g['to'], 'kind': 'UNAVAILABLE', 'label': g['label'],
               'start_normalized': Dbl(r4(max(Fraction(0), xs[idx[0]] - half))),
               'end_normalized': Dbl(r4(min(Fraction(1), xs[idx[-1]] + half)))}
        # 반올림한 값으로도 «날짜로 덮는 점» == «자리로 덮는 점»
        by_x = [i for i in range(n)
                if seg['start_normalized'].x <= r4(xs[i]) <= seg['end_normalized'].x]
        assert by_x == idx, (name, by_x, idx)
        segments.append(seg)
    for i, v in enumerate(actual):
        assert (v is None) == (owner[i] is not None), (name, i)

    planned = [point(i, v) for i, v in enumerate(GOAL_PLANNED)]
    act = [point(i, v, 'RESUME_GAP' if v is None else None)
           for i, v in enumerate(actual)]
    ticks = [{'normalized': Dbl(r4(Fraction(k * step, top - bottom))),
              'label': amount_text(bottom + k * step), 'is_baseline': False}
             for k in range(count)]
    # 값 크기 순서 == 세로 자리 크기 순서(C-36 ⑪ 준용)
    pts = [(v, y(v)) for v in vals]
    for a in pts:
        for b in pts:
            assert (a[0] < b[0]) == (a[1] < b[1]), (name, a, b)
    row = {'yyyy_mm': '2026-08', 'judgement_text': judgement, 'basis_text': basis}
    if deviation is not None:
        row['deviation_text'] = deviation
    row.update({
        'period_label': '%s ~ %s' % (date_text(GOAL_DATES[0]), date_text(GOAL_DATES[-1])),
        'planned_label': '계획 경로',
        'actual_label': '실제 평가액',
        'planned': planned,
        'actual': act,
        'y_ticks': ticks,
        'segments': segments,
        'backtest_basis_text': backtest,
        'starting_capital_assumption_text': start,
    })
    row.update(GOAL_COMMON)
    row['as_of'] = as_of('2026-08-31', GOAL_AS_OF_LABEL)
    return row


def goal_hold_row():
    row = {'yyyy_mm': '2026-08',
           'judgement_text': '관측이 짧아 목표 경로 판정을 보류합니다(판정 유보).',
           'basis_text': '재개 점검 뒤 판정에 필요한 관측이 아직 쌓이지 않았습니다.',
           'period_label': '2026년 8월 기준',
           'planned_label': '계획 경로',
           'actual_label': '실제 평가액',
           'planned': [], 'actual': [], 'y_ticks': [], 'segments': [],
           'chart_unavailable_label': '관측이 모자라 경로를 그리지 않습니다. '
                                      '관측이 쌓이면 다시 그립니다.',
           'backtest_basis_text': GOAL_BACKTEST,
           'starting_capital_assumption_text': GOAL_START}
    row.update(GOAL_COMMON)
    row['as_of'] = as_of('2026-08-31', GOAL_AS_OF_LABEL)
    return row


def goal_texts_ok(rel, row):
    for k, v in row.items():
        if isinstance(v, str):
            assert '최악의 해' not in v, (rel, k)  # C-39 ⑥
            assert v.strip(), (rel, k)
    for p in row['planned'] + row['actual']:
        assert '%' not in p['value_text'], (rel, p)  # C-39 ⑥ 달성률 금지
    if rel.endswith('realworld.json'):
        for k, v in row.items():
            if isinstance(v, str):
                assert '1억' not in v, (rel, k)


def write_goal(rel, row, meta=None):
    goal_texts_ok(rel, row)
    write_disk(rel, envelope(meta or base_meta(rel), as_of('2026-08-31', GOAL_AS_OF_LABEL),
                             [row]))


# ────────────────────────────────────────────────────────────────────────
# 줄 단위 개정 — 월간 리포트 · 인출(다른 줄은 한 글자도 안 바뀐다)
# ────────────────────────────────────────────────────────────────────────
def amend_monthly(rel, link):
    text = bump(base_text(rel), rel)
    if link is not None:
        old = '      "config_hash": "cfg_fake_0000000000000000"\n    }\n  ]\n}\n'
        assert text.count(old) == 1, rel
        new = ('      "config_hash": "cfg_fake_0000000000000000",\n'
               '      "goal_deep_link": %s\n    }\n  ]\n}\n' % json.dumps(link))
        text = text.replace(old, new, 1)
        row = json.loads(text)['rows'][0]
        assert link == 'aaq://report/goal/%s' % row['yyyy_mm'], rel  # C-39 ⑦
    write_disk(rel, text)


SIDE_RE = re.compile(r'^(\s*)"side": "(BUY|SELL)",$')
QTY_RE = re.compile(r'^(\s*)"quantity": (\d+),$')


def amend_withdrawal(rel):
    text = bump(base_text(rel), rel)
    out = []
    n_side = n_qty = 0
    for line in text.split('\n'):
        out.append(line)
        m = SIDE_RE.match(line)
        if m:
            out.append('%s"side_label": "%s",' % (m.group(1),
                                                  '매수' if m.group(2) == 'BUY' else '매도'))
            n_side += 1
        m = QTY_RE.match(line)
        if m:
            out.append('%s"quantity_text": "%s주",' % (m.group(1), m.group(2)))
            n_qty += 1
    new = '\n'.join(out)
    drafts = [d for r in json.loads(new)['rows'] for d in r['order_drafts']]
    assert n_side == n_qty == len(drafts) > 0, (rel, n_side, n_qty, len(drafts))
    write_disk(rel, new)


# ────────────────────────────────────────────────────────────────────────
# 신설 — m9 설정 · 접수증
# ────────────────────────────────────────────────────────────────────────
def contribution_setting(with_limit_note):
    d = {'amount': str(EXAMPLE_AMOUNT),
         'amount_text': man(EXAMPLE_AMOUNT),
         'amount_input_text': str(EXAMPLE_AMOUNT),
         # 🔴 금액 없이 서술(설계 Δ3 · C-32 ⑥ · 01 §8 미결 75).
         'equivalent_note_text': '12% 등가 납입액 대비 충족합니다.',
         'applies_from_text': '다음 납입 주기(10월 1일)부터 이 금액이 적용됩니다.',
         'last_changed_text': '최근 변경: 2026-09-07',
         'as_of': as_of('2026-08-31', '설정 기준 2026-08-31')}
    if with_limit_note:
        d['pension_limit_note_text'] = '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.'
    return d


def register_receipts():
    states = [
        ('REQUESTED', '요청됨 — 엔진 수신 대기'),
        ('EXECUTED', '기록됨 — 실입금 등록이 원장에 남았습니다'),
        ('EXPIRED', '만료됨 — 유효 시간 안에 처리되지 않았습니다'),
        ('HELD_FOR_INTEGRITY', '보류됨 — 원장 무결성 점검 중이라 보관했습니다'),
    ]
    return [{'command_id': 'cmd_20260901_0051', 'kind': 'DEPOSIT_REGISTER',
             'state': s, 'state_label': label,
             'requested_at': '2026-09-01T10:00:00Z',
             'expires_at': '2026-09-01T10:30:00Z',
             'nonce': 'n_7c3e1a9f2b64',
             'issued_by_device_id': 'dev_operator_01'} for s, label in states]


# ────────────────────────────────────────────────────────────────────────
def main():
    assert FX_REL == 'packages/domain_contracts/fixtures', FX_REL
    assert os.path.isdir(FX), FX

    # (a) 전 봉투 버전 한 줄
    n_bumped = n_already = 0
    for dirpath, _, files in os.walk(FX):
        for f in files:
            if not f.endswith('.json'):
                continue
            p = os.path.join(dirpath, f)
            s = io.open(p, encoding='utf-8', newline='').read()
            assert '\r' not in s, p
            if s.count(OLD_VER) == 1 and s.count(NEW_VER) == 0:
                io.open(p, 'w', encoding='utf-8', newline='').write(
                    s.replace(OLD_VER, NEW_VER, 1))
                n_bumped += 1
            else:
                assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, p
                n_already += 1
    print('버전 치환: 바꿈 %d · 이미 1.4.0 %d' % (n_bumped, n_already))

    # (b) 개정 16
    # 입금 계획 — 코어 2(DepositPlan · ui 미사용)
    write_plan_core('deposit_plan_1.json', default_plan('pl_20260901_01', '2026-08-31'))
    funding = funding_plan()
    write_plan_core('deposit_plan_funding_1.json', funding)
    # 입금 계획 — 화면 3(DepositPreviewResult 래퍼)
    d = default_plan('pl_20260901_10', '2026-08-31')
    write_preview('m7/m7_deposit_plan_default.json', [{'plan': d}], plan_envelope_as_of(d))
    lp = limit_plan()
    write_preview('m7/m7_deposit_plan_limit.json', [{'plan': lp}], plan_envelope_as_of(lp))
    ep = expired_plan()
    # 봉투 as_of = 행 기준일(08-28 · 설계 D9 ④) · 봉투 신호(NOT_APPLICABLE)는 행 필드로 옮겼다(⑥).
    write_preview('m7/m7_deposit_plan_expired.json', [{'plan': ep}], plan_envelope_as_of(ep))
    # 목표 경로 3
    write_goal('m7/m7_goal_path_on.json', goal_row(
        'on', [2000, 2070, 2190, 2250, 2360, 2400, 2530, 2600],
        judgement='목표 경로를 따라가고 있습니다(유지).',
        basis='8월 말 평가액이 계획 경로의 허용 범위 안에 있습니다.',
        backtest=GOAL_BACKTEST, start=GOAL_START))
    write_goal('m7/m7_goal_path_hold.json', goal_hold_row())
    write_goal('m7/m7_goal_path_realworld.json', goal_row(
        'realworld', [2000, 2060, 2150, None, None, 2380, 2470, 2540],
        judgement='목표 경로를 따라가고 있습니다(유지).',
        basis='재개 갭 두 분기를 뺀 관측으로 판정했습니다.',
        backtest='백테스트 경로는 납입·인출을 넣지 않은 값이라 실전 경로와 다릅니다.',
        start='실전 조건 — 당신의 현재 원금과 월 납입 설정, 실제 입출금을 넣은 경로입니다.',
        gaps=[{'from': '2025-07-01', 'to': '2025-12-31', 'label': '결측 — 재개 갭'}]))
    # 월간 리포트 5
    amend_monthly('m7/m7_monthly_2026_08.json', 'aaq://report/goal/2026-08')
    amend_monthly('m7/m7_monthly_gap.json', 'aaq://report/goal/2026-08')
    amend_monthly('m7/m7_monthly_masked_integrity.json', None)
    amend_monthly('m7/m7_monthly_masked_recon.json', None)
    amend_monthly('m7/m7_monthly_pending.json', None)
    # 인출 3(기계적)
    for rel in ('m7/m7_withdrawal_general.json', 'm7/m7_withdrawal_pension_penalty.json',
                'm7/m7_withdrawal_shortfall.json'):
        amend_withdrawal(rel)

    # (c) 신설 7
    set_as_of = as_of('2026-08-31', '설정 기준 2026-08-31')
    write_disk('m9/contribution_setting_default.json',
               envelope(NEW_META, set_as_of, [contribution_setting(True)]))
    write_disk('m9/contribution_setting_no_limit_note.json',
               envelope(NEW_META, set_as_of, [contribution_setting(False)]))
    preview_as_of = as_of('2026-08-31', '미리보기 기준 2026-08-31')
    write_preview('m7/m7_deposit_plan_blocked.json', [
        {'blocked_text': '원장 무결성 점검 중에는 미리보기를 계산하지 않습니다.'},
        {'blocked_text': '재개 점검이 끝나지 않아 미리보기를 계산하지 않습니다. '
                         '재개 리포트를 먼저 확인해 주세요.',
         'blocked_action': {'label': '재개 리포트 보기',
                            'deep_link': 'aaq://x2/resume-report'}},
    ], preview_as_of, NEW_META)
    write_preview('m7/m7_deposit_plan_input_rejected.json', [
        {'input_rejected_text': '금액을 원 단위 숫자로 입력해 주세요.'},
    ], preview_as_of, NEW_META)
    fw = funding_plan()
    fw['register_blocked_text'] = ('브로커 잔고 대조가 끝나지 않아 이 계획으로는 '
                                   '입금을 등록할 수 없습니다.')
    fs = fw.pop('funding_steps')
    fw['funding_steps'] = fs
    write_preview('m7/m7_deposit_plan_funding.json', [{'plan': fw}],
                  plan_envelope_as_of(fw), NEW_META)
    write_disk('m7/m7_deposit_register_receipts_4.json',
               envelope(NEW_META, as_of('2026-09-01', '등록 기준 2026-09-01'),
                        register_receipts()))
    write_goal('m7/m7_goal_path_off.json', goal_row(
        'off', [2000, 2040, 2060, 2110, 2130, 2170, 2200, 2230],
        judgement='목표 경로보다 뒤처져 있습니다(이탈).',
        basis='8월 말 평가액이 계획 경로의 허용 범위 아래에 있습니다.',
        backtest=GOAL_BACKTEST, start=GOAL_START,
        deviation='계획선보다 뒤처져 있습니다. 규칙을 바꿀 근거는 아닙니다.'), NEW_META)

    # previewNotice 는 DepositPlan 픽스처 전부 같은 고지(C-38 ③ · 인출 제외)
    for p in (d, lp, ep, funding, fw):
        assert p['preview_notice'].startswith('미리보기입니다')

    n = sum(1 for _, _, fs in os.walk(FX) for f in fs if f.endswith('.json'))
    print('픽스처 파일 수:', n)
    assert n == WANT_FILES, n


if __name__ == '__main__':
    main()
