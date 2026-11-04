#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.17(R16 선행 M2 보강 + 엔진 E10 D11 · 01 §26) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r16_v117_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r15_v116_fixtures.py(계약 v1.16 · 그 스크립트는 v1.16 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-11-04_R16선행_계약v1.17_설계서.md` §5 · 219 → 240 = 신설 21 · 개정 3 · 버전 줄만 216)
  (a) 전 봉투의 "contract_version": "1.16.0" → "1.17.0" 한 줄 치환(다른 글자 불변).
  (b) 개정 3 —
      · m8/handbook_page_sleeve_b — blocks[1] 자리에 LIVE 블록 · 행 끝 outdated_notice·missing_label null ·
        as_of(결정 ④ R16b ⑨ — live 블록 ⇔ non-null) · 🔴 형제 키 `index` 삭제(K22).
      · m8/incident_token_expired — 형제 키 incident_alert.code MAINTENANCE_RESUME_FAILED → BROKER_AUTH_FAILED(K21 · P0 그대로).
      · journal_30 — je_0018(PREVENTED) 칩 code DUPLICATE_SUSPECTED → DUPLICATE_ORDER_PREVENTED(엔진 D11 ④ · label 무변경).
  (c) 신설 21 — R16a 12(D-01 배너 6 · D-02 런북 4 · D-03 카드 2) · R16b 5(B-01 목차 2 · B-02 페이지 3) ·
      R16c 2(H-03) · 엔진 D11 2(m6/journal_expired_1 · m8/alerts_stale_orders_held).
  (d) 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 글자 원천(G13) — 런북 = 03_실행/03_운영과_의사결정_프로토콜.md §10-5 ①~⑥ · 긴급 카드 = 06_시스템설계/04_안전장치.md §5-5 +
   §10-5 ⑥ · 목차 = 04 §8 8항목 이름. 배너·기기 리스크 = 엔진 상태 문구(흉내 글자 그대로).
🔴 asOf 0 예외(K20) — 문서·지속 상태 VM(배너·런북·카드·목차·live 없는 페이지)의 VM 객체에 as_of 키 0 · 봉투에만.

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r16_v117_fixtures.py
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
# 계약 1.16.0 · 픽스처 219 의 기준 커밋(origin/main · E13c1 #120 — 계약 패키지 = PR #96 이후 무변경).
BASE = 'ea06df2808cb950fc5f66e179fe8e7249c1a10d6'

OLD_VER = '"contract_version": "1.16.0"'
NEW_VER = '"contract_version": "1.17.0"'
BASE_FILES = 219
WANT_FILES = 240

RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
FORBIDDEN = re.compile(r'추천|권유|자문|시그널|매매 중단')   # 01 §10-1 · 03 §15
DEV_MEMO = re.compile(r'화면이|화면은|화면·')              # 사용자 문장 자리의 개발자 메모(H50)
PNL_KEY = re.compile(r'pnl|profit|return_pct|손익')       # C-6
ACCOUNT_LIKE = re.compile(r'[0-9]{6,}-[0-9]{2,}|계좌\s*[0-9]{8}')   # C-14 꼴
PHONE = re.compile(r'01[016-9]-?[0-9]{3,4}-?[0-9]{4}')    # C-51 ⑤ 개인 전화번호 꼴
LONG_ALNUM = re.compile(r'[A-Za-z0-9]{32,}')               # C-14 앱키 꼴
RUNBOOK_ID = re.compile(r'^[a-z][a-z0-9-]*$')              # K10
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']

# ── 라우트(lib/src/navigation/app_links.dart 와 같은 글자 — C-33 ① 이 등록을 다시 본다) ──
R_RUNBOOK = 'aaq://ops/runbooks/'
R_CARD = 'aaq://ops/emergency-card'
R_CREDENTIALS = 'aaq://settings/credentials'
R_ALERTS = 'aaq://alerts/inbox'
PRINT_SLOT = 'EMERGENCY_CARD_PRINT'                       # OpsSlotIds.emergencyCardPrint

# ── 이름 ─────────────────────────────────────────────────────────────────
SLEEVE_B = 'm8/handbook_page_sleeve_b.json'
TOKEN_EXP = 'm8/incident_token_expired.json'
JOURNAL_30 = 'journal_30.json'
REVISED = [SLEEVE_B, TOKEN_EXP, JOURNAL_30]

B_TOKEN = 'm8/incident_banner_token_expired.json'
B_REJECT = 'm8/incident_banner_order_rejected.json'
B_NET = 'm8/incident_banner_network_down.json'
B_PHONE = 'm8/incident_banner_phone_down.json'
B_OTHER = 'm8/incident_banner_other.json'
B_NONE = 'm8/incident_banner_none.json'
RB_INDEX = 'm8/runbook_index.json'
RB_EMPTY = 'm8/runbook_index_empty.json'
RB_HOST = 'm8/runbook_host_lost.json'
RB_MISS = 'm8/runbook_missing.json'
CARD = 'm8/emergency_card.json'
CARD_NP = 'm8/emergency_card_no_print.json'
HB_INDEX = 'm8/handbook_index.json'
HB_INDEX_OUT = 'm8/handbook_index_outdated.json'
HB_PAGE_OUT = 'm8/handbook_page_outdated.json'
HB_PAGE_MISS = 'm8/handbook_page_missing.json'
HB_PAGE_ARCH = 'm8/handbook_page_archived.json'
DR_ITEMS = 'm8/device_risk_items.json'
DR_EMPTY = 'm8/device_risk_empty.json'
J_EXPIRED = 'm6/journal_expired_1.json'
A_STALE = 'm8/alerts_stale_orders_held.json'

BANNERS = [B_TOKEN, B_REJECT, B_NET, B_PHONE, B_OTHER, B_NONE]
RUNBOOK_INDEXES = [RB_INDEX, RB_EMPTY]
RUNBOOKS = [RB_HOST, RB_MISS]
CARDS = [CARD, CARD_NP]
HB_INDEXES = [HB_INDEX, HB_INDEX_OUT]
HB_PAGES_NEW = [HB_PAGE_OUT, HB_PAGE_MISS, HB_PAGE_ARCH]
DEVICE = [DR_ITEMS, DR_EMPTY]
R16A = BANNERS + RUNBOOK_INDEXES + RUNBOOKS + CARDS
R16B = HB_INDEXES + HB_PAGES_NEW
VMS = R16A + R16B + DEVICE
D11 = [J_EXPIRED, A_STALE]
NEW_FILES = VMS + D11
DOC_VMS = R16A + R16B                                     # K20 — VM 객체에 as_of 0

NEW_META = {
    'fixture_version': '0.1.0-draft',
    'contract_version': '1.17.0',
    'generated_at': '2026-11-04T09:00:00Z',
    'mode': 'LIVE',
    'config_hash': 'cfg_fake_0000000000000000',
    'seed': 20261104,
    'notice': '합성 데이터. 실계좌·실키 없음.',
}
CFG = NEW_META['config_hash']


def as_of(label, stale_label=None, observed='2026-08-31T09:00:00Z', trade_date='2026-08-31'):
    out = {'observed_at': observed, 'trade_date': trade_date, 'source': 'LOCAL_SQLITE',
           'stale_after_seconds': 93600, 'label': label}
    if stale_label is not None:
        out['stale_label'] = stale_label
    return out


AS_D = as_of('운영 기준 2026-08-31')
AS_B = as_of('핸드북 기준 2026-08-31')
AS_H_ENV = as_of('기기 점검 기준 2026-08-31 09:00')
AS_ALERT = as_of('알림 기준 2026-08-31')
AS_JOURNAL = as_of('체결 반영 2026-08-28', observed='2026-08-28T07:40:00Z', trade_date='2026-08-28')

# ────────────────────────────────────────────────────────────────────────
# R16a — D-01 배너(§5-1 · 흉내 7aa96e8 글자 그대로 · 엔진 상태 문구)
# ────────────────────────────────────────────────────────────────────────
BANNER_KEYS = ['kind', 'level', 'title', 'body_text', 'action_link']


def link_action(label, deep_link):
    return {'label': label, 'deep_link': deep_link}


def banner(kind, level, title, body, action=None):
    row = dict(zip(BANNER_KEYS, [kind, level, title, body, copy.deepcopy(action)]))
    return {'banner': row}


BANNER_VMS = {
    B_TOKEN: banner('TOKEN_EXPIRED', 'BLOCKED', '증권사 접근 토큰이 만료되었습니다',
                    '주문이 멈춰 있습니다. 연결 설정에서 토큰을 다시 받으면 이어서 진행합니다.',
                    link_action('연결 설정 열기', R_CREDENTIALS)),
    B_REJECT: banner('ORDER_REJECTED', 'ACT', '주문 한 건이 거부되었습니다',
                     '증권사가 오늘 주문 한 건을 받지 않았습니다. 알림에서 원인을 확인하세요.',
                     link_action('알림 보기', R_ALERTS)),
    B_NET: banner('NETWORK_DOWN', 'WATCH', '네트워크 연결이 끊겼습니다',
                  '연결이 돌아오면 자동으로 다시 맞춥니다. 지금 할 일은 없습니다.'),
    B_PHONE: banner('PHONE_DOWN', 'BLOCKED', '폰 엔진 신호가 끊겼습니다',
                    '폰이 꺼졌거나 앱이 멈췄을 수 있습니다. 폰을 확인하세요. 자동 매매는 멈춘 상태로 봅니다.'),
    B_OTHER: banner('OTHER', 'INFO', '확인이 필요한 일이 있습니다', '자세한 내용은 운영 화면에서 확인하세요.'),
    B_NONE: {'banner': None},
}

# ────────────────────────────────────────────────────────────────────────
# R16a — D-02 런북 · D-03 카드(§5-1 · 원고 = 03_실행 §10-5 · 04_안전장치 §5-5 + §10-5 ⑥)
# ────────────────────────────────────────────────────────────────────────
LCN = '확인 표시는 이 화면에서만 보입니다. 저장되지 않고, 아무것도 실행하지 않습니다.'


def rb_row(title, summary, deep_link):
    return {'title': title, 'summary_text': summary, 'deep_link': deep_link}


def rb_step(order_text, text):
    return {'order_text': order_text, 'text': text}


HOST_LOST_TITLE = '운영 폰을 잃어버렸거나 고장 났을 때'
RB_ROWS = [
    rb_row(HOST_LOST_TITLE, '주문을 먼저 멈추고 새 폰으로 옮깁니다', R_RUNBOOK + 'host-lost'),
    rb_row('기록이 깨졌을 때', None, R_RUNBOOK + 'db-corrupt'),
    rb_row('증권사 연결이 오래 끊겼을 때', '정해 둔 시각이 지나면 손으로 주문합니다', R_RUNBOOK + 'broker-outage'),
    rb_row('계좌에 접근할 수 없을 때', '재발급 절차와 걸리는 날을 확인합니다', R_RUNBOOK + 'account-access'),
    rb_row('키가 새어 나갔을 때', None, R_RUNBOOK + 'secret-leak'),
    rb_row('오래 자리를 비우거나 크게 아플 때', '가족이 종이 카드로 멈춥니다', R_CARD),
]

HOST_LOST_STEPS = [
    rb_step('1.', '새 폰에 앱을 설치하고 복구 카드로 로그인합니다.'),
    rb_step('2.', '예전 폰을 잃어버린 경우의 이전 절차를 시작하고, 예전 폰의 권한이 끊길 때까지 기다립니다.'),
    rb_step('2-1.', '증권사 앱키를 새 폰의 키 금고에 다시 넣습니다.'),
    rb_step('3.', '백업에서 기록을 되살린 뒤 증권사 잔고와 맞춰 봅니다. 차이가 있으면 새 주문을 막아 둔 채로 둡니다.'),
    rb_step('4.', '하루 동안 모의 운영으로 돌려 본 다음 실제 주문을 다시 켭니다.'),
]

RUNBOOK_VMS = {
    RB_INDEX: {'rows': copy.deepcopy(RB_ROWS), 'empty_label': None},
    RB_EMPTY: {'rows': [], 'empty_label': '등록된 런북이 없습니다.'},
    RB_HOST: {'title': HOST_LOST_TITLE,
              'intro_text': '다시 세우기 전에 주문이 겹치지 않게 하는 것이 먼저입니다. 기록은 백업에서 되살립니다.',
              'steps': copy.deepcopy(HOST_LOST_STEPS), 'local_check_notice': LCN, 'missing_label': None},
    RB_MISS: {'title': '런북', 'intro_text': None, 'steps': [], 'local_check_notice': LCN,
              'missing_label': '이 런북은 지금 목록에 없습니다. 런북 목록에서 다시 고르십시오.'},
}

CARD_STEPS = [
    rb_step('1.', '증권사 앱에 로그인합니다.'),
    rb_step('2.', '자동주문 설정이 켜져 있으면 끕니다.'),
    rb_step('3.', '체결되지 않은 주문을 모두 취소합니다.'),
    rb_step('3-1.', '가진 종목은 급히 팔지 않아도 됩니다. 멈추기만 해도 충분합니다.'),
    rb_step('4.', '그래도 주문이 나가면 고객센터에 전화해 자동주문 차단을 요청합니다.'),
]


def card_vm(print_slot):
    return {'title': '자동매매 긴급 정지 카드', 'steps': copy.deepcopy(CARD_STEPS),
            'contact_line': '한국투자증권 고객센터 1544-5000 · 이 시스템을 아는 사람의 연락처는 종이에 직접 적어 둡니다.',
            'keep_on_paper_notice': '이 카드는 인쇄해서 가족이 아는 곳에 종이로 보관하세요. 계좌번호와 앱키는 이 카드에 없습니다.',
            'print_slot_id': print_slot}


CARD_VMS = {CARD: card_vm(PRINT_SLOT), CARD_NP: card_vm(None)}

# ────────────────────────────────────────────────────────────────────────
# R16b — B-01 목차 · B-02 페이지(§5-2 · 목차 = 04 §8 8항목 이름)
# ────────────────────────────────────────────────────────────────────────
ENTRY_KEYS = ['anchor', 'title', 'order', 'state', 'state_label', 'deep_link', 'children']


def entry(anchor, order, title, state='READY', state_label=None, deep_link='', children=()):
    if deep_link == '':
        deep_link = 'handbook://' + anchor
    return dict(zip(ENTRY_KEYS, [anchor, title, order, state, state_label, deep_link, list(children)]))


CHILDREN = [
    entry('sleeve-a', 1, '슬리브 A — 국내 지수 ETF'),
    entry('sleeve-b', 2, '슬리브 B — 해외 지수·금 ETF', deep_link='handbook://sleeves/sleeve-b'),
    entry('sleeve-c', 3, '슬리브 C — 방어 자산'),
    entry('satellite', 4, '새틀라이트 — 지금은 쓰지 않음', 'ARCHIVED', '보관됨'),
]
ENTRIES = [
    entry('structure', 1, '① 전략 구조'),
    entry('sleeves', 2, '② 슬리브별 편입 메커니즘', children=CHILDREN),
    entry('trading', 3, '③ 매매 메커니즘'),
    entry('safety', 4, '④ 안전장치 설명'),
    entry('glossary', 5, '⑤ 용어 사전'),
    entry('after-tax', 6, '⑥ 세후 표기 규약', 'PREPARING', '준비 중', None),
    entry('rejected-ideas', 7, '⑦ 기각 등록부', 'PREPARING', '준비 중', None),
    entry('rule-value', 8, '⑧ 규칙의 가치와 기대치의 한계', 'PREPARING', '준비 중', None),
]
OUTDATED = '설명이 규칙보다 뒤처졌습니다. 규칙이 바뀐 뒤 아직 고치지 않은 장이 있습니다 — 본문보다 지금 설정이 먼저입니다.'
BLOCK_KEYS = ['kind', 'text', 'deep_link', 'live']
PAGE_KEYS = ['anchor', 'title', 'blocks', 'config_hash', 'outdated_notice', 'missing_label', 'as_of']


def block(kind, text, deep_link=None, live=None):
    return dict(zip(BLOCK_KEYS, [kind, text, deep_link, copy.deepcopy(live)]))


def page(anchor, title, blocks, outdated=None, missing=None, as_of_=None):
    return dict(zip(PAGE_KEYS, [anchor, title, copy.deepcopy(blocks), CFG, outdated, missing, as_of_]))


HB_VMS = {
    HB_INDEX: {'entries': copy.deepcopy(ENTRIES), 'config_hash': CFG, 'outdated_notice': None},
    HB_INDEX_OUT: {'entries': copy.deepcopy(ENTRIES), 'config_hash': CFG, 'outdated_notice': OUTDATED},
    HB_PAGE_OUT: page('rebalance/band', '밴드 이탈 리밸런싱', [
        block('PARAGRAPH', '목표 비중에서 밴드만큼 벗어나면 리밸런싱이 걸립니다.'),
        block('CAUTION', '밴드 폭은 엔진 설정이 정합니다. 이 장의 설명이 설정보다 늦을 수 있습니다.', 'handbook://safety'),
    ], outdated=OUTDATED),
    HB_PAGE_MISS: page('rebalance/monthly', '핸드북', [],
                       missing='이 장은 핸드북에 없습니다. 목차에서 다른 장을 고르십시오.'),
    HB_PAGE_ARCH: page('satellite', '새틀라이트 — 지금은 쓰지 않음', [
        block('PARAGRAPH', '왜 없앴나 — 새틀라이트는 실측에서 수익을 보태지 못하고 위험과 규칙만 늘려 정본에서 뺐습니다. '
                           '이 장은 기록으로만 남깁니다.'),
    ]),
}

LIVE_BLOCK = block('LIVE', '현재 상태 — 엔진이 지금 보고 있는 값입니다.', None,
                   {'label': '금 비중이 상한에 가깝습니다', 'level': 'WATCH'})
SLEEVE_B_AS_OF = as_of('현재 상태 기준 2026-08-31 09:00', '현재 상태 값이 오래됐습니다. 엔진이 다시 보내면 바뀝니다.')

# ────────────────────────────────────────────────────────────────────────
# R16c — H-03(§5-3 · 흉내 236b9a6 글자 그대로)
# ────────────────────────────────────────────────────────────────────────
DR_KEYS = ['label', 'current_text', 'threshold_text', 'action_text', 'last_checked_text', 'level']
GT = '이 항목들은 비상 복구가 아니라 계획 교체의 신호입니다. 임계에 닿기 전에 교체·정리 일정을 잡으세요.'
AS_H = as_of('기기 점검 기준 2026-08-31 09:00', '기기 점검 값이 오래됐습니다. 폰에서 앱을 열면 다시 잽니다.')


def dr(*vals):
    return dict(zip(DR_KEYS, vals))


DR_ROWS = [
    dr('저장공간', '남은 공간 3.1GB', '임계 2GB 미만', '오래된 아카이브를 PC로 옮기세요', '마지막 점검 08-31 08:55', 'WATCH'),
    dr('로그 로테이션', '로그 412MB · 7일분', '임계 1GB 또는 30일', '조치 필요 없음', '마지막 점검 08-31 08:55', 'OK'),
    dr('배터리 열화', '최대 용량 78%', '임계 80% 미만', '배터리 교체 또는 예비 폰 준비를 계획하세요', '마지막 점검 08-31 06:00', 'ACT'),
    dr('OS 보안 지원 종료일', '지원 종료 2027-03', '임계 종료 6개월 전', '새 폰 이전 일정을 잡으세요(X1 기기 이전)',
       '마지막 점검 08-30 21:00', 'INFO'),
    dr('기기 온도', '현재 47도', '임계 45도 넘음', '충전기를 빼고 그늘로 옮기세요', '마지막 점검 08-31 08:55', 'BLOCKED'),
]
DR_VMS = {
    DR_ITEMS: {'rows': copy.deepcopy(DR_ROWS), 'guidance_text': GT, 'empty_label': None, 'as_of': copy.deepcopy(AS_H)},
    DR_EMPTY: {'rows': [], 'guidance_text': GT,
               'empty_label': '점검할 기기 항목을 아직 받지 못했습니다. 폰에서 앱을 열면 다시 잽니다.',
               'as_of': copy.deepcopy(AS_H)},
}

# ────────────────────────────────────────────────────────────────────────
# 엔진 D11 2(§5-4)
# ────────────────────────────────────────────────────────────────────────
JE_EXPIRED = {
    'entry_id': 'je_exp_01', 'mode': 'LIVE', 'trade_date': '2026-08-28', 'executed_at': None,
    'symbol': '379810', 'symbol_label': '379810 KODEX 미국S&P500', 'sleeve': 'B', 'side': 'BUY',
    'side_label': '매수', 'quantity': 12, 'price': '17650', 'commission': '0', 'tax': '0',
    'quantity_text': '12주', 'price_text': '17,650원', 'commission_text': '0원', 'tax_text': '0원',
    'status': 'EXPIRED', 'status_label': '마감 실효 · 다음 거래일로 이월', 'status_tone': 'NEUTRAL',
    'visibility': 'SETTLED', 'visibility_label': '확정',
    'reasons': [{'code': 'DAY_END_EXPIRED', 'label': '장 마감까지 체결되지 않아 다음 거래일 주문으로 넘겼습니다',
                 'tone': 'NEUTRAL'}],
    'decision': {'decision_id': 'd_20260828_b_21', 'intent_id': 'i_0021', 'broker_order_no': '2026-08-28:0000004821',
                 'execution_id': None, 'config_hash': CFG},
    'deviation': {'is_deviation': False, 'label': '규칙대로'},
    'account_alias': '연금저축', 'fill_origin': 'BROKER', 'fill_kind': 'ORIGINAL', 'advice_id': None,
    'backdate': {'trade_date': '2026-08-28', 'authored_at': '2026-08-28T07:00:00Z', 'backdate_trading_days': 0,
                 'is_backdated': False, 'label': '당일 기록', 'price_range_source_date': '2026-08-28',
                 'crosses_closed_period': False},
    'cost_source': 'ESTIMATED', 'cost_source_label': '추정치', 'origin_label': '브로커 체결',
    'rebalance_event_id': None, 'detail_deep_link': 'aaq://journal/decision/d_20260828_b_21',
    'as_of': as_of('체결 반영 2026-08-28 16:40', observed='2026-08-28T07:40:00Z', trade_date='2026-08-28'),
}
ALERT_STALE = {
    'alert_id': 'al_stale_01', 'level': 'P1', 'raised_at': '2026-08-31T00:10:00Z', 'code': 'STALE_ORDERS_HELD',
    'title': '지난 주문이 남아 있어 오늘 주문을 보류했습니다',
    'body_text': '오늘 체결 조회에 지난 거래일 주문이 보입니다. 같은 종목을 두 번 사지 않도록 이 계좌의 오늘 주문을 내지 않았습니다.',
    'action_line': '증권사 앱에서 지난 주문이 남아 있는지 확인하십시오.', 'grouped_count': 1, 'deep_link': None,
    'ack': None, 'raised_at_text': None, 'grouped_text': None, 'detail_deep_link': None,
}

# ── 개정 글자 ─────────────────────────────────────────────────────────────
TOKEN_OLD = '"code": "MAINTENANCE_RESUME_FAILED"'
TOKEN_NEW = '"code": "BROKER_AUTH_FAILED"'
J30_OLD = '{ "code": "DUPLICATE_SUSPECTED", "label": "같은 결정의 주문이 이미 접수되었습니다", "tone": "PREVENTED" }'
J30_NEW = '{ "code": "DUPLICATE_ORDER_PREVENTED", "label": "같은 결정의 주문이 이미 접수되었습니다", "tone": "PREVENTED" }'


# ────────────────────────────────────────────────────────────────────────
# 직렬화 — 저장소 원문 꼴(meta 여러 줄 · 평평한 객체 한 줄 · 목록·VM 여러 줄 · 들여쓰기 2) · gen_r15_v116 과 같다
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


def base_env(rel):
    return json.loads(base_text(rel))


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def vm_envelope(vm, env_as_of):
    """VM 1행 봉투(v1.15·v1.16 선례) — 최상위 as_of = 갈래 기준 글자."""
    return {'meta': copy.deepcopy(NEW_META), 'as_of': copy.deepcopy(env_as_of), 'empty_kind': 'NO_DATA',
            'empty_label': None, 'has_more': False, 'rows': [copy.deepcopy(vm)]}


# ────────────────────────────────────────────────────────────────────────
# 개정
# ────────────────────────────────────────────────────────────────────────
def revise_sleeve_b():
    env = base_env(SLEEVE_B)
    assert env['meta']['contract_version'] == '1.16.0'
    assert list(env) == ENVELOPE_KEYS + ['index'], list(env)
    # 직렬화 꼴 확인 — 형제 키 `index` 를 뺀 원문이 같은 꼴로 다시 써지는가.
    no_index = {k: v for k, v in env.items() if k != 'index'}
    head = base_text(SLEEVE_B).split(',\n  "index": ', 1)[0] + '\n}\n'
    assert ser_envelope(no_index, True) == head, '직렬화 꼴이 원문과 다르다'
    no_index['meta']['contract_version'] = '1.17.0'
    row = no_index['rows'][0]
    assert list(row) == ['anchor', 'title', 'blocks', 'config_hash'] and len(row['blocks']) == 4
    assert row['blocks'][2]['deep_link'] == 'handbook://rebalance/band'
    row['blocks'].insert(1, copy.deepcopy(LIVE_BLOCK))
    row['outdated_notice'] = None
    row['missing_label'] = None
    row['as_of'] = copy.deepcopy(SLEEVE_B_AS_OF)
    return ser_envelope(no_index, True)


def revise_token_expired():
    s = bump(base_text(TOKEN_EXP), TOKEN_EXP)
    assert s.count(TOKEN_OLD) == 1
    return s.replace(TOKEN_OLD, TOKEN_NEW, 1)


def revise_journal_30():
    s = bump(base_text(JOURNAL_30), JOURNAL_30)
    assert s.count(J30_OLD) == 1 and s.count('"DUPLICATE_SUSPECTED"') == 1
    return s.replace(J30_OLD, J30_NEW, 1)


def new_files():
    texts = {}
    for vms, env_as_of in ((BANNER_VMS, AS_D), (RUNBOOK_VMS, AS_D), (CARD_VMS, AS_D), (HB_VMS, AS_B),
                           (DR_VMS, AS_H_ENV)):
        for rel, vm in vms.items():
            texts[rel] = ser_envelope(vm_envelope(vm, env_as_of), False)
    for rel, row, env_as_of in ((J_EXPIRED, JE_EXPIRED, AS_JOURNAL), (A_STALE, ALERT_STALE, AS_ALERT)):
        texts[rel] = ser_envelope(vm_envelope(row, env_as_of), True)
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
                if v.startswith('handbook://'):
                    assert len(v) > len('handbook://'), (rel, path)
        assert not any(PNL_KEY.search(k) for k in keys(env)), rel
    if new:
        assert list(env.keys()) == ENVELOPE_KEYS, (rel, list(env.keys()))          # 형제 키 0(C-15 ⑥)
        assert len(env['rows']) == 1, rel
    return env


def main():
    rels = base_files()
    preload(rels)
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels)
    assert len(NEW_FILES) == 21 and len(set(NEW_FILES)) == 21

    out = {SLEEVE_B: revise_sleeve_b(), TOKEN_EXP: revise_token_expired(), JOURNAL_30: revise_journal_30()}
    out.update(new_files())
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, rel in NEW_FILES or rel in REVISED, rel in NEW_FILES)
            for rel, s in out.items()}
    vm = {rel: envs[rel]['rows'][0] for rel in NEW_FILES + [SLEEVE_B]}
    for rel in DOC_VMS:                                                         # K20
        assert 'as_of' not in vm[rel] or vm[rel]['as_of'] is None, rel
    # 배너 — 종류 5 전수 · OK 0 · 조치 있음 ≥1 · 없음 ≥1 · 최대 1건.
    kinds = [vm[r]['banner']['kind'] for r in BANNERS if vm[r]['banner'] is not None]
    assert sorted(kinds) == sorted(['PHONE_DOWN', 'NETWORK_DOWN', 'TOKEN_EXPIRED', 'ORDER_REJECTED', 'OTHER'])
    assert [r for r in BANNERS if vm[r]['banner'] is None] == [B_NONE]
    assert all(vm[r]['banner']['level'] in ('BLOCKED', 'ACT', 'WATCH', 'INFO') for r in BANNERS if r != B_NONE)
    acts = [vm[r]['banner']['action_link'] for r in BANNERS if r != B_NONE]
    assert any(a is not None for a in acts) and any(a is None for a in acts)
    for r in BANNERS:
        if vm[r]['banner'] is not None:
            assert list(vm[r]['banner']) == BANNER_KEYS, r
    # 런북 — 행 6 · id 꼴 · ⑥ = 카드 · 요약 null ≥1 · 빈 문장 조건 · 비순번 단계.
    rows = vm[RB_INDEX]['rows']
    assert len(rows) == 6 and rows[5]['deep_link'] == R_CARD
    ids = [x['deep_link'][len(R_RUNBOOK):] for x in rows[:5]]
    assert all(x['deep_link'].startswith(R_RUNBOOK) for x in rows[:5]) and all(RUNBOOK_ID.match(i) for i in ids)
    assert len(set(ids)) == 5 and any(x['summary_text'] is None for x in rows)
    for r in RUNBOOK_INDEXES:
        assert (vm[r]['empty_label'] is not None) == (not vm[r]['rows']), r
    host = vm[RB_HOST]
    assert host['steps'] and host['missing_label'] is None and host['intro_text'] is not None
    assert any(s_['order_text'] != '%d.' % (i + 1) for i, s_ in enumerate(host['steps']))
    miss = vm[RB_MISS]
    assert not miss['steps'] and miss['intro_text'] is None and miss['missing_label'] is not None
    # 카드 — 인쇄 이름 있음/없음 · 비순번 · 공개 번호만.
    assert vm[CARD]['print_slot_id'] == PRINT_SLOT and vm[CARD_NP]['print_slot_id'] is None
    assert any(s_['order_text'] != '%d.' % (i + 1) for i, s_ in enumerate(vm[CARD]['steps']))
    # 목차 — 8 · 차례 · 자식 4(보관됨 [3]) · 준비 중 [5..7] · 자식 [1] 링크 ≠ 앵커 · 두 벌 같은 entries.
    for r in HB_INDEXES:
        e = vm[r]['entries']
        assert [x['order'] for x in e] == list(range(1, 9)), r
        assert len(e[1]['children']) == 4 and e[1]['children'][3]['state'] == 'ARCHIVED'
        assert all(x['state'] == 'PREPARING' and x['deep_link'] is None and x['state_label'] for x in e[5:8])
        for x in e + e[1]['children']:
            assert list(x) == ENTRY_KEYS, (r, x['anchor'])
            if x['state'] == 'READY':
                assert x['state_label'] is None and x['deep_link'] is not None
            else:
                assert x['state_label'] is not None
        assert e[1]['children'][1]['deep_link'] != 'handbook://' + e[1]['children'][1]['anchor']
    assert vm[HB_INDEX]['entries'] == vm[HB_INDEX_OUT]['entries']
    assert vm[HB_INDEX]['outdated_notice'] is None and vm[HB_INDEX_OUT]['outdated_notice'] is not None
    # 페이지 — missing ⇔ blocks 0 · live ⇔ as_of · 해시 = meta · sleeve_b 형제 키 0.
    for r in HB_PAGES_NEW + [SLEEVE_B]:
        p = vm[r]
        assert (p['missing_label'] is not None) == (not p['blocks']), r
        assert any(b.get('live') for b in p['blocks']) == (p.get('as_of') is not None), r
        assert p['config_hash'] == envs[r]['meta']['config_hash'], r
    for r in HB_INDEXES:
        assert vm[r]['config_hash'] == envs[r]['meta']['config_hash'], r
    sb = vm[SLEEVE_B]
    assert len(sb['blocks']) == 5 and sb['blocks'][1]['live'] and sb['blocks'][3].get('deep_link')
    assert 'index' not in envs[SLEEVE_B]
    assert vm[HB_PAGE_ARCH]['anchor'] == vm[HB_INDEX]['entries'][1]['children'][3]['anchor']
    # 기기 리스크 — 행 5 · 등급 5값 전수 · 빈 문장 조건 · as_of 있음.
    assert sorted(x['level'] for x in vm[DR_ITEMS]['rows']) == sorted(['OK', 'INFO', 'WATCH', 'ACT', 'BLOCKED'])
    for r in DEVICE:
        assert (vm[r]['empty_label'] is not None) == (not vm[r]['rows']) and vm[r]['as_of'], r
    # D11.
    assert vm[J_EXPIRED]['status'] == 'EXPIRED' and vm[J_EXPIRED]['executed_at'] is None
    assert [c['code'] for c in vm[J_EXPIRED]['reasons']] == ['DAY_END_EXPIRED']
    assert vm[A_STALE]['code'] == 'STALE_ORDERS_HELD' and vm[A_STALE]['level'] == 'P1'
    j30 = [x for x in envs[JOURNAL_30]['rows'] if x['status'] == 'PREVENTED']
    assert len(j30) == 1 and [c['code'] for c in j30[0]['reasons']] == ['DUPLICATE_ORDER_PREVENTED']
    assert envs[TOKEN_EXP]['incident_alert']['code'] == 'BROKER_AUTH_FAILED'
    assert envs[TOKEN_EXP]['incident_alert']['level'] == 'P0'

    # ── 건수(바이트 결과 기준) ──
    n_version_only = sum(1 for rel in rels if out[rel] == bump(base_text(rel), rel))
    n_revised = sum(1 for rel in rels if out[rel] != bump(base_text(rel), rel))
    assert (n_version_only, n_revised) == (216, 3), (n_version_only, n_revised)

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_r16_v117_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · contract 1.17.0'
          % (len(out), BASE_FILES, n_version_only, n_revised, len(NEW_FILES)))


if __name__ == '__main__':
    main()
