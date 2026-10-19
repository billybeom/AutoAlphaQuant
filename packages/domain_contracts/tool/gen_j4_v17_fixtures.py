#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.7(J-4 선행 M2 보강 · 01 §16 · §8 미결 46) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_j4_v17_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r12_v16_fixtures.py(계약 v1.6 · 그 스크립트는 v1.6 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 §3 · 135 → 141 = 신설 6 · 개정 0 · 버전 줄만 135)
  (a) 전 봉투의 "contract_version": "1.6.0" → "1.7.0" 한 줄 치환(다른 글자 불변 · 135건).
  (b) 신설 6 — m6/blind_review_queue_3 · _queue_empty · _card_before · _card_revealed ·
      _card_revealed_open · m6/blind_review_receipts_6.
  (c) §3-0 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 발주자 결정(2026-10-20 · K1~K24 권고대로) 반영:
  - K3 ⓓ — `JOURNAL_MISSING` 이 서 있는(J-3 작성 창이 열린) 결정은 큐에 넣지 않는다 → 설계서 초안의 행0
    `d_20260810_b_27`(safety_states `clear_deep_link` 대상)을 뺐다. 큐 = 설계서 §3-0 확정 표본(2026-10-20)
    결정 시각 오름차순(K4): c_28(2026-08-11 · journal_30 · 매수) → d_mf_0002(2026-08-25 · manual_fills_8 · 매수 ·
    본문 == journal_read_no_note) → d_mf_0004(2026-08-27 · manual_fills_8 · 매도).
  - K6 — 결과 문장 = 엔진 문장 · 금액(원) 0 · 수익률·보유기간·방향만(청산 표본 = 행0) · 미청산 = 행1
    «미청산 — 결과 미확정»(글자 = 설계서 §3-1 ④⑤ 확정판).
  - K24 — v1.7 = LIVE 만 · 모의투자(DRY_RUN) 기간의 큐 = 빈 문장(`blind_review_queue_empty` 가 그 장면도 맡는다).

멱등: 버전 치환은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
날짜·건수·id·수익률 값은 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_j4_v17_fixtures.py
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
# 계약 1.6.0 · 픽스처 135 의 기준 커밋(origin/main · infra PR #31 `tool/precheck.dart` · 계약 패키지 = 9c2b5af 와 같다).
BASE = '76c24040be4a4b98557c882c3443d7ff48232972'

OLD_VER = '"contract_version": "1.6.0"'
NEW_VER = '"contract_version": "1.7.0"'
BASE_FILES = 135
WANT_FILES = 141

NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.7.0",
    "generated_at": "2026-10-20T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20261020,
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
# 금지어(01 §10-1 · 03 §15).
FORBIDDEN = re.compile(r'추천|권유|자문|시그널')
# 사용자 문장 자리의 개발자 메모(H50).
DEV_MEMO = re.compile(r'화면이|화면은|화면·')
# 채점 전 카드의 blind 붕괴 거름망(설계서 §3-0 · C-43 ③) — 금액 · 백분율 · 손익 낱말.
BEFORE_MONEY = re.compile(r'\d[\d,]*\s*원')
BEFORE_PCT = re.compile(r'\d+(\.\d+)?\s*%')
BEFORE_WORDS = re.compile(r'손익|수익|평가액')
# 결과의 금액 꼴(K6 — 금액 0).
RESULT_MONEY = re.compile(r'[0-9][0-9,.]*\s*(억원|만원|원)|₩')
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
ROUTE_DECISION = 'aaq://journal/decision/'
ROUTE_DRAFT = 'aaq://journal/draft/'

# ── 이름 ─────────────────────────────────────────────────────────────────
QUEUE = 'm6/blind_review_queue_3.json'
EMPTY = 'm6/blind_review_queue_empty.json'
BEFORE = 'm6/blind_review_card_before.json'
REVEALED = 'm6/blind_review_card_revealed.json'
REVEALED_OPEN = 'm6/blind_review_card_revealed_open.json'
RECEIPTS = 'm6/blind_review_receipts_6.json'
NEW_FILES = [QUEUE, EMPTY, BEFORE, REVEALED, REVEALED_OPEN, RECEIPTS]
CARD_FILES = [QUEUE, BEFORE, REVEALED, REVEALED_OPEN]

JOURNAL_30 = 'journal_30.json'
MANUAL_FILLS = 'm6/manual_fills_8.json'
SAFETY = 'safety_states.json'
BADGES = 'm6/journal_badges_2.json'
READ_FILES = ['m6/journal_read_written.json', 'm6/journal_read_no_note.json',
              'm6/journal_read_not_written.json']
SPEC_FILES = ['m6/journal_draft_spec_discretion.json', 'm6/journal_draft_spec_recon_clear.json']

# ── 문장(엔진 문장 예시 · 설계서 §2-3·§3-1 · 03_실행 §8-3) ────────────────
AS_OF_LABEL = '리뷰 기준 2026-08-31'
PROMPT = '결과를 보기 전에 이 결정의 과정을 채점합니다'
STATE_WRITTEN = '저널 작성됨'
EMPTY_LABEL = '리뷰할 결정이 없습니다'            # 02:789 — K24 DRY_RUN 기간에도 이 문장
LINK_LABEL = '이 결정 보기'                       # journal_read_* 의 decision_link 와 같은 글자
CHOICES = [{'score': 1, 'label': '예'}, {'score': 0, 'label': '아니오'}]
# 03_실행 §8-3 의 5문항(키 전용 · 사전 등재 0) — 받은 순서 그대로.
QUESTIONS = [
    ('PIT_INFO_ONLY', '결정 시점에 가용했던 정보만 썼는가'),
    ('RULE_FOLLOWED', '규칙이 지시한 대로 했는가'),
    ('PIT_INPUT', '입력 데이터가 그때 알 수 있었던 값(PIT)이었는가'),
    ('FALSIFIER_WRITTEN', '사전에 반증 조건(이러면 내가 틀린 것)을 적었는가'),
    ('WRITTEN_AT_DECISION', '저널을 결정 시점에 작성했는가'),
]

# 큐 3행(결정 시각 오름차순 · K4) — (decision_id, 원천 일지 파일, 근거 줄 5(None = 줄 부재), 저널 본문 출처).
C28 = 'd_20260811_c_28'
MF2 = 'd_mf_0002'
MF4 = 'd_mf_0004'
EXCLUDED_K3D = 'd_20260810_b_27'   # 설계서 초안 행0 — JOURNAL_MISSING 대상이라 큐 제외(K3 ⓓ)

# 새 합성 본문 2벌(작성됨 · 메모 있음 — c_28 · d_mf_0004). d_mf_0002 = journal_read_no_note 본문 그대로(메모 없음).
BODY_C28 = {
    'written_at_text': '2026-08-11 13:55 작성',
    'rule_cited_label': '재량 예산(롤링 12개월 4회) 안에서 조정',
    'rationale_before': ('[합성] 월간 정기 리밸런싱 주문이 장중 연결 끊김으로 나가지 않아 같은 수량을 수기로 넣는다.\n'
                         '[합성] 규칙이 정한 수량과 슬리브는 바꾸지 않고 주문 경로만 바꾼다.\n'
                         '[합성] 이 수기 기록은 롤링 12개월 재량 예산 4회 중 1회째로 센다.'),
    'expected_outcome': ('[합성] 같은 거래일 안에 정기 리밸런싱 수량이 그대로 체결된다. '
                         '다음 거래일까지 체결이 확인되지 않으면 이 판단이 틀린 것으로 본다.'),
    'note': '[합성] 다음 정기 회차 전에 연결 끊김 원인을 운영 점검표에 적는다.',
}
BODY_MF4 = {
    'written_at_text': '2026-08-27 13:50 작성',
    'rule_cited_label': '재량 예산(롤링 12개월 4회) 안에서 조정',
    'rationale_before': ('[합성] 안내가 정한 매도 수량을 그대로 따르되 체결은 증권사 앱에서 직접 넣는다.\n'
                         '[합성] 안내 수량을 늘리거나 줄이지 않고 남은 보유분은 그대로 둔다.'),
    'expected_outcome': ('[합성] 안내 유효 시간 안에 같은 수량으로 매도가 체결되고 이행 갭이 생기지 않는다. '
                         '장 마감까지 체결되지 않으면 이 판단이 틀린 것으로 본다.'),
    'note': '[합성] 매도 뒤 현금은 다음 정기 회차의 배분에 맡긴다.',
}
ROWS = [
    (C28, JOURNAL_30, [
        '입력 데이터 기준 2026-08-10 · 결정 2026-08-11 09:05',
        '이탈 기록: 수기 기록 — 재량 예산 차감',
        '입력 스냅샷 2026-08-10 장 마감 값 · 이후 수정 기록 없음',
        None,
        '저널 작성 2026-08-11 13:55 · 주문 2026-08-11 14:39',
    ], BODY_C28),
    (MF2, MANUAL_FILLS, [
        '입력 데이터 기준 2026-08-24 · 결정 2026-08-25 09:00',
        '이탈 기록: 수기 기록 — 재량 예산 차감',
        '입력 스냅샷 2026-08-24 장 마감 값 · 이후 수정 기록 없음',
        None,
        '저널 작성 2026-08-25 20:10 · 체결 2026-08-25 14:30',
    ], 'm6/journal_read_no_note.json'),
    (MF4, MANUAL_FILLS, [
        '입력 데이터 기준 2026-08-26 · 결정 2026-08-27 09:00',
        '이탈 기록: 수기 기록 — 재량 예산 차감',
        '입력 스냅샷 2026-08-26 장 마감 값 · 이후 수정 기록 없음',
        None,
        '저널 작성 2026-08-27 13:50 · 체결 2026-08-27 14:30',
    ], BODY_MF4),
]

# 결과 2벌(K6 확정 — 금액 0 · 수익률·보유기간·방향 · 미청산 · 글자 = 설계서 §3-1 ④⑤).
RESULT_CLOSED = {
    'process_score_text': '과정 점수 4점 — 좋은 결정(4점 이상)',
    'outcome_text': '결과: 수익률 +0.6% · 보유 12거래일',
    'detail_lines': ['방향: 저널의 기대와 같음'],
}
RESULT_OPEN = {
    'process_score_text': '과정 점수 3점 — 좋은 결정 기준(4점) 미만',
    'outcome_text': '미청산 — 결과 미확정',   # 02:789
    'detail_lines': [],
}

# 접수증 6행(설계서 §3-1 ⑥ · K11) — 한 명령의 갈래.
RECEIPT_HEAD = {
    'command_id': 'cmd_20260831_0041',
    'kind': 'BLIND_REVIEW_SCORE',
}
RECEIPT_TAIL = {
    'requested_at': '2026-08-31T09:20:00Z',
    'expires_at': '2026-08-31T09:50:00Z',
    'nonce': 'n_8d41f07b2e96',
    'issued_by_device_id': 'dev_operator_01',
}
RECEIPT_STATES = [
    ('REQUESTED', '전송 대기 — 연결되면 엔진에 보냅니다', None),
    ('HELD_FOR_INTEGRITY', '보류됨 — 원장 무결성 점검 중이라 보관했습니다. 복구 뒤 일괄 확정 단계에서 처리됩니다', None),
    ('EXECUTED', '기록됨 — 과정 점수가 저장되었습니다', None),
    ('EXPIRED', '만료됨 — 유효 시간 안에 처리되지 않았습니다. 고른 답은 그대로 남아 있습니다', None),
    ('REJECTED', '거부됨 — 답이 카드의 문항과 맞지 않습니다. 고른 답은 그대로 남아 있습니다',
     'BLIND_REVIEW_ANSWERS_INVALID'),
    ('REJECTED', '거부됨 — 이 결정은 이미 채점되었습니다. 먼저 기록된 채점이 유지됩니다',
     'BLIND_REVIEW_ALREADY_SCORED'),
]
REJECT_CODES = {'BLIND_REVIEW_ALREADY_SCORED', 'BLIND_REVIEW_ANSWERS_INVALID'}


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


def body_without_meta(s):
    lines = s.split('\n')
    i = lines.index('  "meta": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '  },')
    return '\n'.join(lines[:i] + lines[j + 1:])


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


# ────────────────────────────────────────────────────────────────────────
# 렌더러 — gen_r12_v16_fixtures.py 와 같은 꼴(평평한 객체 = 한 줄 · 행 = 여러 줄 · 평평한 객체 목록 = 한 줄씩)
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


def render(env):
    body = []
    for k, v in env.items():
        if k == 'meta':
            continue
        if k == 'rows':
            body.append('  "rows": %s' % rows_block(v))
        else:
            body.append('  %s: %s' % (dumps(k), rv(v, 2)))
    return '{\n' + NEW_META + '\n' + ',\n'.join(body) + '\n}\n'


def envelope(rows, empty_label=None):
    return {'meta': None, 'as_of': as_of(), 'empty_kind': 'NO_DATA', 'empty_label': empty_label,
            'has_more': False, 'rows': rows}


# ────────────────────────────────────────────────────────────────────────
# 행 만들기
# ────────────────────────────────────────────────────────────────────────
def as_of():
    return {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': AS_OF_LABEL}


def entry_of(decision_id, rel):
    hits = [r for r in base_env(rel)['rows'] if r['decision']['decision_id'] == decision_id]
    assert len(hits) == 1, (decision_id, rel, len(hits))
    return hits[0]


def read_body(decision_id, rel):
    hits = [r for r in base_env(rel)['rows'] if r['decision_id'] == decision_id]
    assert len(hits) == 1, (decision_id, rel)
    assert hits[0]['body'] is not None, (decision_id, rel)
    return hits[0]['journal_state_label'], copy.deepcopy(hits[0]['body'])


def card_row(decision_id, src, evidence, body_src):
    e = entry_of(decision_id, src)
    if isinstance(body_src, str):
        state_label, body = read_body(decision_id, body_src)
    else:
        state_label, body = STATE_WRITTEN, copy.deepcopy(body_src)
    questions = []
    for (qid, text), ev in zip(QUESTIONS, evidence):
        q = {'question_id': qid, 'text': text}
        if ev is not None:
            q['evidence_text'] = ev
        q['choices'] = copy.deepcopy(CHOICES)
        questions.append(q)
    return {
        'decision_id': decision_id,
        'title_text': '%s · %s · %s 결정' % (e['trade_date'], e['symbol_label'], e['side_label']),
        'prompt_text': PROMPT,
        'context_chips': copy.deepcopy(e['reasons']),
        'deviation': copy.deepcopy(e['deviation']),
        'journal_state_label': state_label,
        'journal': body,
        'questions': questions,
        'as_of': as_of(),
    }


def with_result(row, result):
    out = {}
    for k, v in row.items():
        if k == 'as_of':
            r = dict(result)
            r['decision_link'] = {'label': LINK_LABEL, 'deep_link': ROUTE_DECISION + row['decision_id']}
            out['result'] = r
        out[k] = copy.deepcopy(v)
    return out


def receipt_rows():
    rows = []
    for state, label, code in RECEIPT_STATES:
        r = dict(RECEIPT_HEAD)
        r['state'] = state
        r['state_label'] = label
        r.update(RECEIPT_TAIL)
        if code is not None:
            r['reject_reason_code'] = code
        rows.append(r)
    return rows


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


def existing_chip_codes(rels):
    """기존 픽스처의 사유 칩 코드 집합(`reasons`·`context_chips` 목록 안 `code`)."""
    codes = set()
    for rel in rels:
        for d in walk_dicts(base_env(rel)):
            for k in ('reasons', 'context_chips'):
                for c in d.get(k) or []:
                    if isinstance(c, dict) and 'code' in c:
                        codes.add(c['code'])
    return codes


def journal_missing_targets():
    """K3 ⓓ — `JOURNAL_MISSING` 깃발의 해제 링크가 가리키는 결정(J-3 작성 창이 열린 결정)."""
    out = set()
    for d in walk_dicts(base_env(SAFETY)):
        if d.get('flag_id') == 'JOURNAL_MISSING':
            link = d['clear_deep_link']
            assert link.startswith(ROUTE_DRAFT), link
            out.add(link[len(ROUTE_DRAFT):])
    assert out, 'JOURNAL_MISSING 표본을 못 읽었다'
    return out


def self_check_file(rel, s, new=False):
    assert '\r' not in s, rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE', rel    # C-15 — 봉투 meta.mode 전량 LIVE
    body = body_without_meta(s)
    for rx in RETIRED:
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    keys = list(env.keys())
    assert keys[:6] == ENVELOPE_KEYS, (rel, keys)
    if new:
        assert keys == ENVELOPE_KEYS, (rel, keys)   # 봉투 최상위 키 추가 0
    else:
        assert keys == list(base_env(rel).keys()), rel
    return env


def self_check_content(rel, env, chip_codes):
    if env['rows']:
        assert env['empty_kind'] == 'NO_DATA' and env['empty_label'] is None, rel
    for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
        assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
        assert not DEV_MEMO.search(v), '%s %s — 사용자 문장 자리의 개발자 메모: %s' % (rel, path, v)
    if rel not in CARD_FILES:
        return
    for row in env['rows']:
        assert row['as_of'] == env['as_of'], rel   # 행 as_of == 봉투(관측 시각 · 픽스처는 같은 값)
        for c in row['context_chips']:
            assert c['code'] in chip_codes, (rel, c['code'])   # C-5 는 칩 code 를 보지 않는다 — 여기서 본다
            link = c.get('detail_deep_link')
            assert link is None or link.startswith('handbook://'), (rel, link)   # K8 — 채점 전 앱 안 링크 0
        qids = [q['question_id'] for q in row['questions']]
        assert 3 <= len(qids) <= 5 and len(set(qids)) == len(qids), rel
        for q in row['questions']:
            scores = [c['score'] for c in q['choices']]
            assert len(scores) >= 2 and len(set(scores)) == len(scores), rel
            assert q.get('evidence_text', 'x'), rel
        before = {k: v for k, v in row.items() if k != 'result'}
        for path, v in strings(before):
            assert not BEFORE_MONEY.search(v), '%s %s — 채점 전 금액: %s' % (rel, path, v)
            assert not BEFORE_PCT.search(v), '%s %s — 채점 전 백분율: %s' % (rel, path, v)
            assert not BEFORE_WORDS.search(v), '%s %s — 채점 전 손익 낱말: %s' % (rel, path, v)
        if 'result' in row:
            res = row['result']
            for path, v in strings(res):
                assert not RESULT_MONEY.search(v), '%s %s — 결과 금액(K6): %s' % (rel, path, v)
            assert res['decision_link']['deep_link'] == ROUTE_DECISION + row['decision_id'], rel


# ────────────────────────────────────────────────────────────────────────
def main():
    rels = base_files()
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'

    # ── 신설 ──
    rows = [card_row(*r) for r in ROWS]
    out = {
        QUEUE: render(envelope(rows)),
        EMPTY: render(envelope([], EMPTY_LABEL)),
        BEFORE: render(envelope([copy.deepcopy(rows[0])])),
        REVEALED: render(envelope([with_result(rows[0], RESULT_CLOSED)])),
        REVEALED_OPEN: render(envelope([with_result(rows[1], RESULT_OPEN)])),
        RECEIPTS: render(envelope(receipt_rows())),
    }
    # ── 버전 줄만 ──
    for rel in rels:
        out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, new=rel in NEW_FILES) for rel, s in out.items()}
    chip_codes = existing_chip_codes(rels)
    for rel in NEW_FILES:
        self_check_content(rel, envs[rel], chip_codes)
    queue = envs[QUEUE]['rows']
    # K4 — 결정 시각 오름차순(제목의 날짜 = 일지 행 trade_date).
    dates = [r['title_text'].split(' · ')[0] for r in queue]
    assert dates == sorted(dates), dates
    # K3 ⓓ — JOURNAL_MISSING 대상 결정은 큐에 없다(설계서 초안 행0 b_27 제외).
    missing = journal_missing_targets()
    assert EXCLUDED_K3D in missing, missing
    assert not ({r['decision_id'] for r in queue} & missing), missing
    # 대기 행 = result 키 부재 · ③ == ① 행0 · ④ − result == ③ 행 · ⑤ − result == ① 행1.
    assert all('result' not in r for r in queue)
    assert envs[BEFORE]['rows'] == [queue[0]]
    for rel, idx in ((REVEALED, 0), (REVEALED_OPEN, 1)):
        row = envs[rel]['rows'][0]
        assert {k: v for k, v in row.items() if k != 'result'} == queue[idx], rel
    assert envs[REVEALED]['rows'][0]['result']['outcome_text'] != \
        envs[REVEALED_OPEN]['rows'][0]['result']['outcome_text']
    # 저널 정합 — 같은 결정의 journal_read_* 본문·상태 글자 == 카드 · 미작성 픽스처에만 있는 결정은 큐에 없다.
    written = {}
    not_written = set()
    for rel in READ_FILES:
        for r in base_env(rel)['rows']:
            if r['body'] is None:
                not_written.add(r['decision_id'])
            else:
                written[r['decision_id']] = (r['journal_state_label'], r['body'])
    n_read = 0
    for r in queue:
        assert r['journal'] is not None, r['decision_id']   # K3 ⓓ — 작성 뒤에만 큐에 들어온다
        if r['decision_id'] in written:
            assert (r['journal_state_label'], r['journal']) == written[r['decision_id']], r['decision_id']
            n_read += 1
        assert r['decision_id'] not in not_written or r['decision_id'] in written, r['decision_id']
    assert n_read >= 1, '저널 읽기 픽스처와 맞대는 표본이 없다'
    # 같은 결정의 J-3 스펙이 있으면 문맥·이탈 == 스펙(설계서 §3-0 — v1.7 큐에는 해당 결정 없음).
    for rel in SPEC_FILES:
        for s in base_env(rel)['rows']:
            for r in queue:
                if r['decision_id'] == s['decision_id']:
                    assert (r['context_chips'], r['deviation']) == (s['context_chips'], s['deviation']), rel
    # 일지 행 정합(C-43 ⑦ⓒ) — 문맥 칩 == 그 결정의 일지 행 reasons · 이탈 배지 == 그 행 deviation.
    for decision_id, src, _ev, _b in ROWS:
        e = entry_of(decision_id, src)
        r = next(x for x in queue if x['decision_id'] == decision_id)
        assert (r['context_chips'], r['deviation']) == (e['reasons'], e['deviation']), decision_id
    # 큐 = 설계서 §3-0 확정 표본(행 순서까지).
    assert [r['decision_id'] for r in queue] == [C28, MF2, MF4], [r['decision_id'] for r in queue]
    # 배지 «리뷰 대기 n건» == 큐 행 수(C-43 ⑤).
    badge = [b for b in base_env(BADGES)['rows'] if b['badge_code'] == 'BLIND_REVIEW_PENDING']
    assert len(badge) == 1 and badge[0]['label'] == '리뷰 대기 %d건' % len(queue), badge
    # 접수증 — 6행 · 한 명령 · 거부 사유 2종 모두.
    rec = envs[RECEIPTS]['rows']
    assert len(rec) == 6 and len({(r['command_id'], r['nonce'], r['issued_by_device_id']) for r in rec}) == 1
    assert {r['reject_reason_code'] for r in rec if r['state'] == 'REJECTED'} == REJECT_CODES
    assert all('reject_reason_code' not in r for r in rec if r['state'] != 'REJECTED')

    # ── 쓰기 ──
    for rel, s in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(s)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_j4_v17_fixtures: %d files (기준 %d · 버전 줄만 %d · 신설 %d) · 큐 %d행(%s) · 접수증 %d행 · '
          'contract 1.7.0'
          % (len(out), BASE_FILES, len(rels), len(NEW_FILES), len(queue),
             ' → '.join(r['decision_id'] for r in queue), len(rec)))


if __name__ == '__main__':
    main()
