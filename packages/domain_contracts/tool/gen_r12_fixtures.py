#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.5(R12 선행 M2 보강 · 01 §15-3 · §8 미결 49) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_r12_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_r11_fixtures.py(계약 v1.4)를 본떴다.

하는 일(01 §15-3)
  (a) 전 봉투의 "contract_version": "1.4.0" → "1.5.0" 한 줄 치환(다른 글자 불변 · 122건).
  (b) 개정 2건 — 행 필드만 더한다(봉투 최상위 키 0 · 링크 키 추가 0):
      - rebalance_6: 6행 전부 `detail_deep_link`(S7-6a 행 → S7-6b) · as_of 이전 5행에
        `journal_timeline_link`(S7-6b 하단 버튼 → J-1 회차 조건). `re_20261030_01` 은 링크 없음
        (= 버튼 부재 표본 · 묶인 일지 행 0).
      - m7/m7_rebalance_detail_band: 같은 두 필드.
  (c) 신설 4건
      m6/journal_rebalance_scope_1 · m6/journal_rebalance_unknown ·
      m7/m7_rebalance_detail_advisory · m7/m7_rebalance_empty
  (d) 규약을 스크립트 안에서 먼저 확인한다(어기면 쓰기 전에 멈춘다) — 폐기 운영값 0 ·
      신설 파일의 금액 꼴 0(meta 블록 밖) · 링크 꼬리 == 그 행 event_id ·
      «N» = journal_30 에서 그 회차에 묶인 행 수(scope 회차) · scope.range 가 그 행 전부를 덮음.

«N» 의 작업 정의(01 §15-3 · 발주자 결정 ④ 2026-10-07): 그 회차에 묶인 일지 행 **전체** 수.
journal_30 에 행이 있는 회차는 re_20260803_01 하나다 — 그 회차만 journal_30 에서 센다. 나머지
회차의 «2»는 일지 표본 밖 회차의 합성값이다(journal_30 ↔ rebalance_6 은 의도 수준에서 짝이 아니다 ·
§8 미결 — 픽스처 README «계약 v1.5»).

멱등: 개정·치환은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r12_fixtures.py
"""
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
# 계약 1.4.0 · 픽스처 122 의 기준 커밋(origin/main · R12 선행 보강 (1)·(1b) 병합 기록 dbbd3ae).
BASE = 'dbbd3ae740f8f6c87a186e8398e74e697db38240'

OLD_VER = '"contract_version": "1.4.0"'
NEW_VER = '"contract_version": "1.5.0"'
BASE_FILES = 122
WANT_FILES = 126

# fixture_conventions_test.dart `_retiredContributionValues` 와 같은 정규식(폐기 운영값).
RETIRED = [
    re.compile(r'(?<![0-9])90000(?![0-9])'),
    re.compile(r'(?<![0-9])97000(?![0-9])'),
    re.compile(r'(?<![0-9])124000(?![0-9])'),
    re.compile(r'90_000|97_000|124_000'),
    re.compile(r'9만|9\.7만|12\.4만'),
]
# 신설 파일의 금액 꼴(meta 블록 밖). 최종 판정은 C-14(비밀·계좌) · C-32(금액) — 여기는 쓰기 전 거름망이다.
# 🔴 «8자리 이상 숫자열» 거름망은 두지 않는다 — 회차 id(`re_20260803_01`)·`meta.seed` 에 늘 걸리고,
#    C-14 가 일부러 피한 규칙이다(c14_fixture_secret_scan_test.dart «8자리 이상 연속 숫자를 그대로 잡으면…»).
MONEY = re.compile(r'[0-9][0-9,]*\s*(원|만원)')

ROUTE_JOURNAL_REBALANCE = 'aaq://journal/rebalance/:rebalanceEventId'
ROUTE_REBALANCE_EVENT = 'aaq://rebalance/event/:rebalanceEventId'

# 버튼 글자(엔진 문장 예시). 낱말 = 결정 ④ — 자동 갈래 «주문» · advisory 갈래 «기록»(행을 가리키는 말).
LINK_LABEL_LIVE = '이 회차의 주문 %d건'
LINK_LABEL_ADVISORY = '이 회차의 기록 %d건'
SYNTH_N = 2            # 일지 표본(journal_30) 밖 회차의 합성 N
SCOPE_EVENT = 're_20260803_01'
NO_LINK_EVENTS = {'re_20261030_01'}   # as_of 뒤 회차 · 묶인 일지 행 0 → 버튼 부재

NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.5.0",
    "generated_at": "2026-10-07T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20261007,
    "notice": "합성 데이터. 실계좌·실키 없음."
  },'''


# ────────────────────────────────────────────────────────────────────────
# 파일 입출력
# ────────────────────────────────────────────────────────────────────────
def git(*args):
    return subprocess.check_output(['git', '-C', ROOT] + list(args)).decode('utf-8')


def base_text(rel):
    s = git('show', '%s:%s/%s' % (BASE, FX_REL, rel))
    assert '\r' not in s, rel
    return s


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


def check(rel, s):
    assert '\r' not in s, rel
    assert s.endswith('}\n'), rel
    json.loads(s)  # 문법 확인
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    body = body_without_meta(s)
    for rx in RETIRED:
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)


def write_disk(rel, s, money_free=False):
    check(rel, s)
    if money_free:
        body = body_without_meta(s)
        assert not MONEY.search(body), '%s — 금액 꼴' % rel
    path = FX + '/' + rel
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, 'w', encoding='utf-8', newline='').write(s)


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def fill(pattern, value):
    assert pattern.count(':rebalanceEventId') == 1
    return pattern.replace(':rebalanceEventId', value)


def inline(obj):
    """기존 픽스처의 한 줄 객체 꼴({ "k": v, … })."""
    return '{ ' + ', '.join('%s: %s' % (json.dumps(k), json.dumps(v, ensure_ascii=False))
                            for k, v in obj.items()) + ' }'


# ────────────────────────────────────────────────────────────────────────
# 행 필드 더하기(글자 그대로 · order_intent_ids 줄 바로 뒤)
# ────────────────────────────────────────────────────────────────────────
ROW_ID = re.compile(r'^      "event_id": "([^"]+)",$')
INTENTS = re.compile(r'^      "order_intent_ids": \[.*\],$')


def add_row_links(s, rel, link_label):
    """각 행의 order_intent_ids 줄 뒤에 detail_deep_link(+ journal_timeline_link)를 넣는다."""
    out, cur, done = [], None, []
    for line in s.split('\n'):
        out.append(line)
        m = ROW_ID.match(line)
        if m:
            cur = m.group(1)
            continue
        if INTENTS.match(line):
            assert cur, rel
            if link_label is not None and cur not in NO_LINK_EVENTS:
                n = journal_rows(cur) if cur == SCOPE_EVENT else SYNTH_N
                link = {'label': link_label % n,
                        'deep_link': fill(ROUTE_JOURNAL_REBALANCE, cur)}
                out.append('      "journal_timeline_link": %s,' % inline(link))
            out.append('      "detail_deep_link": %s,' % json.dumps(fill(ROUTE_REBALANCE_EVENT, cur)))
            done.append(cur)
            cur = None
    assert done, rel
    return '\n'.join(out), done


# ────────────────────────────────────────────────────────────────────────
# journal_30 (기준 원문 · LIVE 세계)
# ────────────────────────────────────────────────────────────────────────
_J30 = None


def j30_rows():
    global _J30
    if _J30 is None:
        _J30 = json.loads(base_text('journal_30.json'))['rows']
    return _J30


def journal_rows(event_id):
    return sum(1 for r in j30_rows() if r.get('rebalance_event_id') == event_id)


def journal_dates(event_id):
    return sorted(r['trade_date'] for r in j30_rows() if r.get('rebalance_event_id') == event_id)


# ────────────────────────────────────────────────────────────────────────
# 신설 4건
# ────────────────────────────────────────────────────────────────────────
def new_envelope(as_of, rows_text, empty_label=None):
    return '\n'.join([
        '{',
        NEW_META,
        '  "as_of": %s,' % inline(as_of),
        '  "empty_kind": "NO_DATA",',
        '  "empty_label": %s,' % (json.dumps(empty_label, ensure_ascii=False) if empty_label else 'null'),
        '  "has_more": false,',
        rows_text,
        '}',
        '',
    ])


def gen_scope_1():
    env = json.loads(base_text('journal_30.json'))
    dates = journal_dates(SCOPE_EVENT)
    assert dates, SCOPE_EVENT
    scope = {
        'rebalance_event_id': SCOPE_EVENT,
        'label': '2026-08-03 월 납입 배분 회차',
        'range': {'from': dates[0], 'to': dates[-1], 'preset_code': None,
                  'label': '%s ~ %s' % (dates[0], dates[-1]), 'is_default': False},
    }
    assert SCOPE_EVENT not in scope['label']
    rows = '  "rows": [\n    %s\n  ]' % inline(scope).replace(
        '"range": {', '"range": { ').replace('"is_default": false}', '"is_default": false }')
    return new_envelope(env['as_of'], rows)


def gen_unknown():
    env = json.loads(base_text('journal_30.json'))
    empty = json.loads(base_text('m6/journal_empty.json'))['empty_label']
    label = '이 회차에 묶인 기록이 없습니다'
    assert label != empty
    return new_envelope(env['as_of'], '  "rows": []', label)


def gen_rebalance_empty():
    env = json.loads(base_text('rebalance_6.json'))
    return new_envelope(env['as_of'], '  "rows": []', '아직 리밸런싱 회차가 없습니다')


def gen_advisory(band_text_new):
    """band 의 거울 — 같은 event_id · 링크 글자만 «기록» · meta 는 신설 꼴."""
    lines = band_text_new.split('\n')
    i = lines.index('  "meta": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '  },')
    s = '\n'.join(lines[:i] + NEW_META.split('\n') + lines[j + 1:])
    live = LINK_LABEL_LIVE % SYNTH_N
    adv = LINK_LABEL_ADVISORY % SYNTH_N
    assert s.count(json.dumps(live, ensure_ascii=False)) == 1
    return s.replace(json.dumps(live, ensure_ascii=False), json.dumps(adv, ensure_ascii=False))


# ────────────────────────────────────────────────────────────────────────
def main():
    rels = base_files()
    written = 0
    band_new = None
    for rel in rels:
        s = bump(base_text(rel), rel)
        if rel == 'rebalance_6.json':
            s, ids = add_row_links(s, rel, LINK_LABEL_LIVE)
            assert len(ids) == 6, ids
        elif rel == 'm7/m7_rebalance_detail_band.json':
            s, ids = add_row_links(s, rel, LINK_LABEL_LIVE)
            assert ids == ['re_20260601_01'], ids
            band_new = s
        write_disk(rel, s)
        written += 1
    assert band_new
    write_disk('m6/journal_rebalance_scope_1.json', gen_scope_1(), money_free=True)
    write_disk('m6/journal_rebalance_unknown.json', gen_unknown(), money_free=True)
    write_disk('m7/m7_rebalance_empty.json', gen_rebalance_empty(), money_free=True)
    write_disk('m7/m7_rebalance_detail_advisory.json', gen_advisory(band_new), money_free=True)
    written += 4
    on_disk = sum(1 for b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert written == WANT_FILES == on_disk, (written, on_disk)
    print('gen_r12_fixtures: %d files (기준 %d + 신설 4 · 개정 2) · contract 1.5.0' % (written, BASE_FILES))


if __name__ == '__main__':
    main()
