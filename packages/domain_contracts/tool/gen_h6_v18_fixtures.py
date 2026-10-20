#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.8(R4 선행 M2 보강 · 01 §17 · 화면 ID `H6-1`~`H6-3`) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_h6_v18_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_j4_v17_fixtures.py(계약 v1.7 · 그 스크립트는 v1.7 재현용으로 그대로 둔다)를 본떴다.

하는 일(설계서 `10_리뷰/2026-10-20_R4선행_계약v1.8_설계서.md` §3 · 141 → 159 = 신설 18 · 개정 3 · 버전 줄만 138)
  (a) 전 봉투의 "contract_version": "1.7.0" → "1.8.0" 한 줄 치환(다른 글자 불변 · 138건).
  (b) 개정 3 — holdings_6(행 = 미결 82 대응표 6행 + v1.8 표시 키 · pnl 3행 · 트랜치 B 만 · 배지 대응) ·
      m6/external_holdings_2(+quantity_text 만 · 줄 삽입) · m7/realized_alloc_S7(+sleeve_label 만 · 줄 삽입).
  (c) 신설 18 — m6/holdings_overview_{normal, recon, integrity, empty, pnl, viewer} ·
      m6/holding_detail_{with_stops, no_stop, pnl, recon, integrity} ·
      m6/allocation_{in_band, out_of_band, tranche_progress, parking_large, integrity, recon, empty}.
  (d) §3-0 규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다) — 아래 `self_check_*`.

🔴 발주자 결정(2026-10-20 K1~K5 · 2026-10-21 K14·K15·K16·K17·K27·K29 — 전부 권고대로) 반영:
  - K4 — 미결 82(보유 몫): 종목 라벨 = 입금 픽스처(deposit_plan_1) 이름 · `379810`·`132030`·`357870` 0 ·
    C 금 행 없음(C 금 종목 미확정 — 지어내지 않는다) · POT = B 와 같은 종목 2행(`holdingId` 의 존재 이유 표본).
  - K5 — 손익 펼침 열람 기록 없음 → `disclosure_note` = «전일 종가 기준 · 평가 손익»(«열람 기록» 글자 0).
  - K14 — 시스템 밖 자산 = `ExternalHoldingRow`(+quantity_text) · INTEGRITY 에서도 가리지 않는다 · 뷰어 ⑱ = external 없음.
  - K15 — 뷰어 ⑱ = pnl_toggle_label 없음(토글 부재).
  - K16 ⓓ — ⑥ holding_detail_with_stops = 보존 경로 표본(TIER_1B 1행 · 골든 아님) · 골든 = ⑮ h62_integrity.
  - K17 — POT 행 = A 카드 펼침 안 맨 끝 · sub_book_label «POT 서브북 · A 하위(연금저축)» 상시.
  - K18 — SMA 트랜치 = B 행에만(같은 단계) · B·POT 금 행 상한 배지(SAF-208·SAF-209) 0 · 숫자 합성(세후·골든 4자리 0).
  - K27 — 밴드 행 = B 만(A·C·POT·CASH = sleeve_weight·band_state·gauge 없음 + band_note_text) ·
    표본 날짜 2026-08-31 = 계절 캘린더 미반영 합성(SPEC 시점 정합 = 미결 108).
    🔵 설계서 §3-0 은 이 표식을 meta `notice` 에 두라 했으나 C-1 이 `meta.notice` 를 01 §5 문장 하나로 고정한다
       («합성 데이터. 실계좌·실키 없음.») — 표식은 fixtures/README «계약 v1.8» 절과 이 주석에 둔다(⑥ 의 «보존 경로» 도 같다).
  - K29(2026-10-21 · 칩 빼기 = 권고 ⓑ′) — INTEGRITY·L-3 가림판의 보유 행 `sma_tranches` = [](칩 부재).

멱등: 버전 치환·개정은 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show BASE:경로`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.
날짜·수량·가격·비중·금액은 **합성 데이터**다(실계좌 아님 · 총자산 5,000만원 가정의 둥근 값).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_h6_v18_fixtures.py
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
# 계약 1.7.0 · 픽스처 141 의 기준 커밋(origin/main · 엔진 PR #46 — 계약 패키지 = v1.7 PR #32 0905377 와 같다).
BASE = 'f46e72f3858c09b175f0636dfb455d00f4009ee6'

OLD_VER = '"contract_version": "1.7.0"'
NEW_VER = '"contract_version": "1.8.0"'
BASE_FILES = 141
WANT_FILES = 159

NEW_META = '''  "meta": {
    "fixture_version": "0.1.0-draft",
    "contract_version": "1.8.0",
    "generated_at": "2026-10-21T09:00:00Z",
    "mode": "LIVE",
    "config_hash": "cfg_fake_0000000000000000",
    "seed": 20261021,
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
DIGIT = re.compile(r'[0-9]')
ENVELOPE_KEYS = ['meta', 'as_of', 'empty_kind', 'empty_label', 'has_more', 'rows']
ROUTE_DECISION = 'aaq://journal/decision/'
ROUTE_DETAIL = 'aaq://holdings/detail/'
ROUTE_ALLOCATION = 'aaq://holdings/allocation'

# ── 이름 ─────────────────────────────────────────────────────────────────
OV_NORMAL = 'm6/holdings_overview_normal.json'
OV_RECON = 'm6/holdings_overview_recon.json'
OV_INTEGRITY = 'm6/holdings_overview_integrity.json'
OV_EMPTY = 'm6/holdings_overview_empty.json'
OV_PNL = 'm6/holdings_overview_pnl.json'
OV_VIEWER = 'm6/holdings_overview_viewer.json'
DT_WITH_STOPS = 'm6/holding_detail_with_stops.json'
DT_NO_STOP = 'm6/holding_detail_no_stop.json'
DT_PNL = 'm6/holding_detail_pnl.json'
DT_RECON = 'm6/holding_detail_recon.json'
DT_INTEGRITY = 'm6/holding_detail_integrity.json'
AL_IN_BAND = 'm6/allocation_in_band.json'
AL_OUT_OF_BAND = 'm6/allocation_out_of_band.json'
AL_TRANCHE = 'm6/allocation_tranche_progress.json'
AL_PARKING = 'm6/allocation_parking_large.json'
AL_INTEGRITY = 'm6/allocation_integrity.json'
AL_RECON = 'm6/allocation_recon.json'
AL_EMPTY = 'm6/allocation_empty.json'
OVERVIEWS = [OV_NORMAL, OV_RECON, OV_INTEGRITY, OV_EMPTY, OV_PNL, OV_VIEWER]
DETAILS = [DT_WITH_STOPS, DT_NO_STOP, DT_PNL, DT_RECON, DT_INTEGRITY]
ALLOCATIONS = [AL_IN_BAND, AL_OUT_OF_BAND, AL_TRANCHE, AL_PARKING, AL_INTEGRITY, AL_RECON, AL_EMPTY]
NEW_FILES = OVERVIEWS + DETAILS + ALLOCATIONS

HOLDINGS_6 = 'holdings_6.json'
EXTERNAL_2 = 'm6/external_holdings_2.json'
REALIZED_S7 = 'm7/realized_alloc_S7.json'
REVISED = [HOLDINGS_6, EXTERNAL_2, REALIZED_S7]

JOURNAL_30 = 'journal_30.json'
JOURNAL_MASKED = 'm6/journal_masked_integrity.json'
SLEEVE_CATALOG = 'sleeve_catalog_4.json'
DEPOSIT_PLANS = ['deposit_plan_1.json', 'm7/m7_deposit_plan_default.json']

# ── 문장(엔진 문장 예시 · 설계서 §2-3·§3 · 02 §4) ─────────────────────────
MASKED = '숨김'                       # m6/journal_masked_integrity 의 quantity_text 와 같은 글자(자가 검사)
ASOF_HOLD_LABEL = '잔고 기준 2026-08-31 종가 · 엔진은 일 1회 배치'   # 02 §2-1 갈래 B
ASOF_ALLOC_LABEL = '배분 기준 2026-08-31 종가'
DISCLOSURE = '전일 종가 기준 · 평가 손익'   # K5 — «열람 기록» 글자 0
PNL_TOGGLE = '종목 손익'                   # 접힘·펼침 표시는 아이콘(설계서 §2-7) — 글자는 그대로
EXTERNAL_TITLE = '시스템 밖 자산(수동)'
EXTERNAL_NOTICE = '비중 계산에서 빠집니다'
ALLOC_LINK = {'label': '비중 보기', 'deep_link': ROUTE_ALLOCATION}
OV_EMPTY_LABEL = '보유 종목이 없습니다 · 다음 트랜치 판정 2026-09-30(SMA 신호)'
SUB_BOOK = 'POT 서브북 · A 하위(연금저축)'                       # K17
PENDING = '반영 대기 +12주'                                     # 02 §2-1 갈래 C
ENTRY_LINK_LABEL = '매수 결정 보기'                              # 02 §4-2
NO_STOP = '이 슬리브는 개별 손절선을 쓰지 않습니다 — 리밸런싱 규칙으로 관리'   # 02 §4-2 «문구 M2»
RECENT_EMPTY = '이 보유의 최근 체결이 없습니다'
ALLOC_NOTICE = '회계 기준입니다 — POT 는 A 에 포함됩니다'
AL_EMPTY_LABEL = '배분 현황이 없습니다 · 첫 입금이 반영되면 엔진이 채웁니다'
# A 행 원장 열 주석(02:1348 «엔진 열 = C 에 POT 합산» 의 뜻). 🔵 설계서 §3-1 ⑩ 의 «이 화면은 회계 기준입니다» 는
# H50(사용자 문장 자리의 개발자 메모 «화면은») 거름망에 걸려 «여기 비중은» 으로 적는다.
# 🔴 realized_alloc_S7 A 행 문장(«엔진 열에서는 POT 를 A 에 합산»)은 02 와 반대라 옮기지 않는다(미결 109).
A_ENGINE_NOTE = '엔진 원장 열에서는 POT 가 C 쪽에 합산됩니다 — 여기 비중은 회계 기준입니다'
B_PARKING_NOTE = '신호가 켜지지 않은 몫은 파킹 ETF 에 둡니다.'
NO_TRANCHE = '해당 없음'               # realized_alloc_S7 POT·CASH 글자 — 트랜치 = B 규칙
BAND_IN = '밴드 내'
BAND_NEAR = '경계 근접'
BAND_OUT = '밴드 이탈 — 다음 배치에서 리밸런싱 대상'   # 🔴 실행 예고 아님

# 손절선(⑥ — holdings_6 A 행 stop_line 옛 값 그대로 · TIER 2 원천 없음 → TIER_1B 1행).
STOP_TIER_CODES = {'TIER_1A', 'TIER_1B', 'TIER_2'}   # lib/src/labels/exit_kind.dart `StopTierCodes.values`


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


def meta_text(s):
    lines = s.split('\n')
    i = lines.index('  "meta": {')
    j = next(k for k in range(i, len(lines)) if lines[k] == '  },')
    return '\n'.join(lines[i:j + 1])


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def insert_after(s, rel, anchor, line):
    """`anchor` 줄(정확히 1회) 바로 뒤에 같은 들여쓰기로 `line` 을 넣는다(원문 꼴 보존)."""
    lines = s.split('\n')
    hits = [i for i, l in enumerate(lines) if l.strip() == anchor]
    assert len(hits) == 1, (rel, anchor, len(hits))
    i = hits[0]
    indent = lines[i][:len(lines[i]) - len(lines[i].lstrip())]
    lines.insert(i + 1, indent + line)
    return '\n'.join(lines)


# ────────────────────────────────────────────────────────────────────────
# 렌더러 — gen_j4_v17_fixtures.py 와 같은 꼴(평평한 객체 = 한 줄 · 행 = 여러 줄 · 평평한 객체 목록 = 한 줄씩)
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


def envelope(as_of, rows):
    return {'meta': None, 'as_of': as_of, 'empty_kind': 'NO_DATA', 'empty_label': None,
            'has_more': False, 'rows': rows}


def as_of(label):
    return {'observed_at': '2026-08-31T09:00:00Z', 'trade_date': '2026-08-31', 'source': 'LOCAL_SQLITE',
            'stale_after_seconds': 93600, 'label': label}


# ────────────────────────────────────────────────────────────────────────
# 보유 행(미결 82 대응표 — 설계서 §3-0 · K4) — holdings_6 = ⑤ 와 같은 6행(pnl 3행 포함)
# ────────────────────────────────────────────────────────────────────────
def base_holding(symbol):
    hits = [r for r in base_env(HOLDINGS_6)['rows'] if r['symbol'] == symbol]
    assert len(hits) == 1, symbol
    return hits[0]


def label_of(symbol):
    """입금 정본(deposit_plan_1)의 종목 라벨 — §3-0 대응표의 원천(C-44 ⑨)."""
    hits = set()
    for rel in DEPOSIT_PLANS:
        def walk(n):
            if isinstance(n, dict):
                if n.get('symbol') == symbol and 'symbol_label' in n:
                    hits.add(n['symbol_label'])
                for v in n.values():
                    walk(v)
            elif isinstance(n, list):
                for v in n:
                    walk(v)
        walk(base_env(rel))
    assert len(hits) == 1, (symbol, hits)
    return hits.pop()


def gate_of(old_symbol, code):
    """옛 holdings_6 행의 배지 글자 그대로(E14 — 지어내지 않음)."""
    hits = [g for g in base_holding(old_symbol)['gates'] if g['code'] == code]
    assert len(hits) == 1, (old_symbol, code)
    return dict(hits[0])


ROW_AS_OF = base_holding('069500')['as_of']                 # 옛 holdings_6 행 as_of 그대로
MONTHLY = base_holding('069500')['entry_reasons']           # 옛 행 사유 칩 그대로(6행 공통)
assert all(r['entry_reasons'] == MONTHLY for r in base_env(HOLDINGS_6)['rows'])
# B 트랜치 2/3(같은 슬리브 단계 — 두 B 행 동일 · K18). 글자 꼴 = 옛 holdings_6 «n/3 단계».
B_TRANCHES = [
    {'step_no': 1, 'filled': True, 'label': '1/3 단계', 'filled_on': '2026-08-03'},
    {'step_no': 2, 'filled': True, 'label': '2/3 단계', 'filled_on': '2026-08-17'},
    {'step_no': 3, 'filled': False, 'label': '3/3 단계'},
]


def holding(hid, symbol, sleeve, account, qty, price, entry_date, decision_id, intent_id,
            tranches, gates, weight, pending=None, sub_book=None, stop_line=None):
    r = {'holding_id': hid, 'symbol': symbol, 'symbol_label': label_of(symbol), 'sleeve': sleeve,
         'account_alias': account, 'quantity': qty, 'quantity_text': '{:,}주'.format(qty)}
    if pending is not None:
        r['pending_text'] = pending
    r.update({'avg_price': str(price), 'avg_price_text': '{:,}원'.format(price), 'entry_date': entry_date,
              'entry_decision': {'decision_id': decision_id, 'intent_id': intent_id,
                                 'config_hash': 'cfg_fake_0000000000000000'},
              'entry_reasons': copy.deepcopy(MONTHLY), 'sma_tranches': copy.deepcopy(tranches),
              'gates': copy.deepcopy(gates), 'weight_text': '비중 %s%%' % weight})
    if sub_book is not None:
        r['sub_book_label'] = sub_book
    r.update({'scope': 'MANAGED', 'scope_label': '시스템 관리', 'as_of': copy.deepcopy(ROW_AS_OF)})
    if stop_line is not None:
        r['stop_line'] = copy.deepcopy(stop_line)
    r['detail_deep_link'] = ROUTE_DETAIL + hid
    return r


def pnl(raw, pct):
    """손익 표시 문자열 — 원값과 같은 수(합성) · 음수 = U+2212."""
    sign = '+' if raw >= 0 else '−'
    return {'unrealized_pnl': str(raw), 'pnl_pct': pct, 'disclosure_note': DISCLOSURE,
            'pnl_text': '%s%s원' % (sign, '{:,}'.format(abs(raw))),
            'pnl_pct_text': '%s%.2f%%' % (sign, abs(pct) * 100)}


OLD_A = base_holding('069500')
R_A = holding('h_0001', '069500', 'A', '연금저축', 212, 38410, '2026-08-03', 'd_20260803_a_01', 'i_h001',
              [], [gate_of('069500', 'SAF-301')], '16.6', stop_line=OLD_A['stop_line'])
R_B1 = holding('h_0002', '133690', 'B', '연금저축', 636, 17590, '2026-08-03', 'd_20260803_b_02', 'i_h002',
               B_TRANCHES, [gate_of('379810', 'SAF-201')], '22.7', pending=PENDING)
R_B2 = holding('h_0003', '411060', 'B', '연금저축', 125, 22400, '2026-08-05', 'd_20260805_b_03', 'i_h003',
               B_TRANCHES, [gate_of('379810', 'SAF-201')], '5.6')
R_C = holding('h_0004', '0085P0', 'C', '일반', 352, 51190, '2026-08-04', 'd_20260804_c_04', 'i_h004',
              [], [gate_of('0085P0', 'SAF-302')], '35.9')
R_P1 = holding('h_0005', '133690', 'POT', '연금저축', 30, 17800, '2026-08-10', 'd_20260810_pot_06', 'i_h006',
               [], [gate_of('357870', 'SAF-401')], '1.1', sub_book=SUB_BOOK)
R_P2 = holding('h_0006', '411060', 'POT', '연금저축', 21, 22600, '2026-08-10', 'd_20260810_pot_07', 'i_h007',
               [], [gate_of('357870', 'SAF-401')], '0.9', sub_book=SUB_BOOK)
PNL = {'h_0001': pnl(158420, 0.0193), 'h_0002': pnl(158860, 0.0142), 'h_0004': pnl(-81080, -0.0045)}


def with_pnl(row):
    r = copy.deepcopy(row)
    if r['holding_id'] in PNL:
        r['pnl'] = copy.deepcopy(PNL[r['holding_id']])
    return r


def recon_row(row):
    """RECON_MISMATCH 대상 행 — 수량·비중·반영 대기 글자 끝 «?»(02 §2-2 · 01 §11-2 «120주?»)."""
    r = copy.deepcopy(row)
    for k in ('quantity_text', 'weight_text', 'pending_text'):
        if k in r:
            r[k] = r[k] + '?'
    return r


def integrity_row(row):
    """LEDGER_INTEGRITY(·L-3 실사 세션) — 수량·매수가·비중 «숨김» · 반영 대기 칩 부재(설계서 §3-1 ③) ·
    SMA 트랜치 칩 부재(✅ K29 2026-10-21 발주자 «칩 빼기» = 권고 ⓑ′ — `sma_tranches: []` · 기하 null 과 같은 꼴 ·
    카드 머리 `tranche_state_text` «숨김» 과 맞춘다)."""
    r = copy.deepcopy(row)
    for k in ('quantity_text', 'avg_price_text', 'weight_text'):
        r[k] = MASKED
    r.pop('pending_text', None)
    r['sma_tranches'] = []
    return r


RECON_TARGET = 'h_0002'   # 설계서 §3-1 ② — RECON 대상 1종목(133690 B 행)


# ────────────────────────────────────────────────────────────────────────
# 배분 행(회계 기준 · 총자산 5,000만원 가정 — 설계서 §3-1 ⑩~⑰ · K27)
# ────────────────────────────────────────────────────────────────────────
def alloc(sleeve, label, dep, park, dep_r, park_r, tranche, dep_pct, park_pct, parent=None,
          engine_note=None, park_note=None, weight=None, band=None, gauge=None, note=None, chips=()):
    r = {'sleeve': sleeve, 'sleeve_label': label, 'basis': 'ACCOUNTING', 'deployed_text': dep,
         'parking_text': park, 'deployed_ratio': dep_r, 'parking_ratio': park_r, 'tranche_state_text': tranche,
         'deployed_pct_text': dep_pct, 'parking_pct_text': park_pct}
    if parent is not None:
        r['parent_sleeve'] = parent
    if engine_note is not None:
        r['engine_column_note'] = engine_note
    if park_note is not None:
        r['parking_note_text'] = park_note
    if weight is not None:
        r['sleeve_weight'] = weight
        r['band_state'], r['band_state_label'] = band
        r['gauge'] = gauge
    if note is not None:
        r['band_note_text'] = note
    r['state_chips'] = [dict(c) for c in chips]
    return r


def b_weight(cur, label_tail):
    """B 밴드(SPEC `core_band.sleeve_b_band` ±3%p · 목표 42%) — v1.6 완성 문장 꼴(rebalance_6)."""
    return {'sleeve': 'B', 'basis': 'ACCOUNTING', 'weight': cur, 'target_weight': 0.42, 'band_low': 0.39,
            'band_high': 0.45, 'label': 'B %.1f%% (목표 42.0%%, %s)' % (cur * 100, label_tail)}


def b_gauge(actual):
    """게이지 눈금 = 목표 ± 6%p(36%~48%) — 엔진이 고른 눈금(합성)."""
    return {'actual_normalized': actual, 'target_normalized': 0.5, 'band_low_normalized': 0.25,
            'band_high_normalized': 0.75}


POT_ENGINE_NOTE = next(r for r in base_env(REALIZED_S7)['rows'] if r['sleeve'] == 'POT')['engine_column_note']
ENTRY_DEFER_CHIP = {'code': 'F1_ENTRY_DEFER', 'label': '10월 진입 보류 — 11월 재판정', 'tone': 'NEUTRAL',
                    'detail_deep_link': 'handbook://sleeve-a/entry-gate'}   # K13 · 01:1400

AL_A = alloc('A', '슬리브 A', '830만원', '20만원', 0.976, 0.024, NO_TRANCHE, '16.6%', '0.4%',
             engine_note=A_ENGINE_NOTE, note='A 19.0% · 목표 20.0% — 계절 슬리브 · 밴드 판정 없음')
AL_POT = alloc('POT', 'POT 서브북 (A 하위)', '101만원', '0원', 1.0, 0.0, NO_TRANCHE, '2.0%', '0.0%', parent='A',
               engine_note=POT_ENGINE_NOTE, note='POT 2.0% — A 에 포함(회계 기준)')
AL_B = alloc('B', '슬리브 B', '1,415만원', '715만원', 0.664, 0.336, 'B 트랜치 2/3 — SMA 신호 2개 점등', '28.3%',
             '14.3%', park_note=B_PARKING_NOTE, weight=b_weight(0.426, '편차 +0.6%p, 밴드 여유 2.4%p'),
             band=('IN_BAND', BAND_IN), gauge=b_gauge(0.55))
AL_C = alloc('C', '슬리브 C', '1,794만원', '25만원', 0.986, 0.014, NO_TRANCHE, '35.9%', '0.5%',
             note='C 36.4% · 목표 잔여 — 게이지 없음')
AL_CASH = alloc('CASH', '원화 현금 대기', '0원', '100만원', 0.0, 1.0, NO_TRANCHE, '0.0%', '2.0%',
                note='원화 현금 대기 2.0% — 유휴가 아닙니다')
IN_BAND_ROWS = [AL_A, AL_POT, AL_B, AL_C, AL_CASH]


def replace_rows(rows, **by_sleeve):
    return [copy.deepcopy(by_sleeve.get(r['sleeve'], r)) for r in rows]


OUT_ROWS = replace_rows(
    IN_BAND_ROWS,
    B=alloc('B', '슬리브 B', '1,595만원', '715만원', 0.69, 0.31, 'B 트랜치 2/3 — SMA 신호 2개 점등', '31.9%', '14.3%',
            park_note=B_PARKING_NOTE, weight=b_weight(0.462, '편차 +4.2%p, 밴드 상단 1.2%p 초과'),
            band=('OUT_OF_BAND', BAND_OUT), gauge=b_gauge(0.85)),
    C=alloc('C', '슬리브 C', '1,615만원', '25만원', 0.985, 0.015, NO_TRANCHE, '32.3%', '0.5%',
            note='C 32.8% · 목표 잔여 — 게이지 없음'))
TRANCHE_ROWS = replace_rows(
    IN_BAND_ROWS,
    A=alloc('A', '슬리브 A', '830만원', '20만원', 0.976, 0.024, NO_TRANCHE, '16.6%', '0.4%',
            engine_note=A_ENGINE_NOTE, note='A 19.0% · 목표 20.0% — 계절 슬리브 · 밴드 판정 없음',
            chips=[ENTRY_DEFER_CHIP]),
    B=alloc('B', '슬리브 B', '2,010만원', '210만원', 0.905, 0.095, 'B 트랜치 3/3 — SMA 신호 3개 점등', '40.2%', '4.2%',
            park_note='새로 들어온 납입금이 다음 배치를 기다립니다.',
            weight=b_weight(0.444, '편차 +2.4%p, 밴드 여유 0.6%p'), band=('NEAR_EDGE', BAND_NEAR),
            gauge=b_gauge(0.7)),
    C=alloc('C', '슬리브 C', '1,705만원', '25만원', 0.986, 0.014, NO_TRANCHE, '34.1%', '0.5%',
            note='C 34.6% · 목표 잔여 — 게이지 없음'))
PARKING_ROWS = replace_rows(
    IN_BAND_ROWS,
    B=alloc('B', '슬리브 B', '705만원', '1,410만원', 0.333, 0.667, 'B 트랜치 1/3 — SMA 신호 1개 점등', '14.1%', '28.2%',
            park_note='투자분 트랜치 1/3 — 신호가 켜지지 않은 몫은 파킹 ETF 에 둡니다 · 미달이 아닙니다',
            weight=b_weight(0.423, '편차 +0.3%p, 밴드 여유 2.7%p'), band=('IN_BAND', BAND_IN),
            gauge=b_gauge(0.525)),
    C=alloc('C', '슬리브 C', '1,810만원', '25만원', 0.986, 0.014, NO_TRANCHE, '36.2%', '0.5%',
            note='C 36.7% · 목표 잔여 — 게이지 없음'))


def integrity_alloc(row):
    """INTEGRITY — 금액·%·트랜치·밴드 글자 «숨김» · 기하·sleeve_weight 부재(null) · 원장 열 주석은 그대로(문장)."""
    r = {k: v for k, v in row.items() if k not in ('sleeve_weight', 'band_state', 'band_state_label', 'gauge')}
    for k in ('deployed_text', 'parking_text', 'tranche_state_text', 'deployed_pct_text', 'parking_pct_text'):
        r[k] = MASKED
    r['deployed_ratio'] = None
    r['parking_ratio'] = None
    r['band_note_text'] = MASKED
    out = {}
    for k in ['sleeve', 'sleeve_label', 'basis', 'deployed_text', 'parking_text', 'deployed_ratio',
              'parking_ratio', 'tranche_state_text', 'deployed_pct_text', 'parking_pct_text', 'parent_sleeve',
              'engine_column_note', 'parking_note_text', 'band_note_text', 'state_chips']:
        if k in r:
            out[k] = r[k]
    assert set(out) == set(r), (set(r) - set(out))
    return out


def recon_alloc(row):
    """RECON — 기하·band_state 유지 · 금액·% 글자 끝 «?»(설계서 §3-1 ⑯ · K10)."""
    r = copy.deepcopy(row)
    for k in ('deployed_text', 'parking_text', 'deployed_pct_text', 'parking_pct_text'):
        r[k] = r[k] + '?'
    r['sleeve_weight']['label'] = r['sleeve_weight']['label'] + '?'
    return r


INTEGRITY_ROWS = [integrity_alloc(r) for r in IN_BAND_ROWS]
RECON_ROWS = replace_rows(IN_BAND_ROWS, B=recon_alloc(AL_B))


def alloc_vm(rows, notice=ALLOC_NOTICE, empty=None):
    vm = {'rows': copy.deepcopy(rows)}
    if notice is not None:
        vm['notice_text'] = notice
    if empty is not None:
        vm['empty_label'] = empty
    vm['as_of'] = as_of(ASOF_ALLOC_LABEL)
    return vm


# ────────────────────────────────────────────────────────────────────────
# 보유현황(H6-1) · 종목 상세(H6-2)
# ────────────────────────────────────────────────────────────────────────
def catalog_titles():
    rows = [r for r in base_env(SLEEVE_CATALOG)['rows'] if r.get('rolls_up_to') is None]
    return {r['sleeve']: r['label'] for r in sorted(rows, key=lambda r: r['order'])}


TITLES = catalog_titles()   # A·B·C(POT 4번째 행은 카드가 아니다)
assert list(TITLES) == ['A', 'B', 'C'], TITLES


def external_rows():
    """external_holdings_2 개정본의 행(+quantity_text) — 섹션 행 == 등록 목록 행(K14)."""
    return [dict(r, **{}) for r in json.loads(revise_external())['rows']]


def overview(card_rows, allocs, external=True, toggle=True, pnl_on=False):
    cards = []
    for sleeve in TITLES:
        rows = [with_pnl(r) if pnl_on else copy.deepcopy(r) for r in card_rows[sleeve]]
        cards.append({'sleeve': sleeve, 'title_text': TITLES[sleeve],
                      'allocation': copy.deepcopy(next(a for a in allocs if a['sleeve'] == sleeve)),
                      'rows': rows})
    vm = {'cards': cards}
    if external:
        vm['external'] = {'title_text': EXTERNAL_TITLE, 'notice_text': EXTERNAL_NOTICE, 'rows': external_rows()}
    vm['allocation_link'] = dict(ALLOC_LINK)
    if toggle:
        vm['pnl_toggle_label'] = PNL_TOGGLE
    vm['as_of'] = as_of(ASOF_HOLD_LABEL)
    return vm


CARD_ROWS = {'A': [R_A, R_P1, R_P2], 'B': [R_B1, R_B2], 'C': [R_C]}   # 카드 안 = 비중 내림차순 · POT 맨 끝(K17)
RECON_CARD_ROWS = {s: [recon_row(r) if r['holding_id'] == RECON_TARGET else r for r in rows]
                   for s, rows in CARD_ROWS.items()}
INTEGRITY_CARD_ROWS = {s: [integrity_row(r) for r in rows] for s, rows in CARD_ROWS.items()}


def journal_rows(rel, entry_ids):
    by_id = {r['entry_id']: r for r in base_env(rel)['rows']}
    return [copy.deepcopy(by_id[e]) for e in entry_ids]


SL_A = {'tier_code': 'TIER_1B', 'tier_label': OLD_A['stop_line']['label'],
        'level': OLD_A['stop_line']['absolute_stop'],
        'level_text': '{:,}원'.format(int(OLD_A['stop_line']['absolute_stop'])),
        'is_active': True, 'basis_label': '매수가 대비 −10.0%'}


def detail(row, sleeve_label, stop_lines, recent, toggle=True):
    vm = {'holding': copy.deepcopy(row), 'sleeve_label': sleeve_label,
          'entry_decision_link': {'label': ENTRY_LINK_LABEL,
                                  'deep_link': ROUTE_DECISION + row['entry_decision']['decision_id']},
          'stop_lines': copy.deepcopy(stop_lines)}
    if not stop_lines:
        vm['no_stop_line_text'] = NO_STOP
    vm['recent_entries'] = copy.deepcopy(recent)
    if not recent:
        vm['recent_empty_label'] = RECENT_EMPTY
    if toggle:
        vm['pnl_toggle_label'] = PNL_TOGGLE
    vm['as_of'] = as_of(ASOF_HOLD_LABEL)
    return vm


# ────────────────────────────────────────────────────────────────────────
# 개정 3
# ────────────────────────────────────────────────────────────────────────
def revise_holdings6():
    rows = [with_pnl(r) for r in (R_A, R_B1, R_B2, R_C, R_P1, R_P2)]
    env = base_env(HOLDINGS_6)
    env['rows'] = rows
    return render(bump(meta_text(base_text(HOLDINGS_6)), HOLDINGS_6), env)


EXTERNAL_QTY_TEXT = {'ex_0001': '40주', 'ex_0002': '15주'}


def revise_external():
    s = bump(base_text(EXTERNAL_2), EXTERNAL_2)
    for r in base_env(EXTERNAL_2)['rows']:
        assert EXTERNAL_QTY_TEXT[r['external_id']] == '{:,}주'.format(r['quantity'])
    s = insert_after(s, EXTERNAL_2, '"quantity": 40,', '"quantity_text": "40주",')
    s = insert_after(s, EXTERNAL_2, '"quantity": 15,', '"quantity_text": "15주",')
    return s


S7_SLEEVE_LABELS = {'A': '슬리브 A', 'B': '슬리브 B', 'C': '슬리브 C', 'POT': 'POT 서브북 (A 하위)',
                    'CASH': '원화 현금 대기'}


def revise_realized():
    s = bump(base_text(REALIZED_S7), REALIZED_S7)
    for sleeve, label in S7_SLEEVE_LABELS.items():
        s = insert_after(s, REALIZED_S7, '"sleeve": "%s",' % sleeve, '"sleeve_label": %s,' % dumps(label))
    return s


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


def self_check_file(rel, s, new=False):
    assert '\r' not in s, rel
    assert s.endswith('}\n'), rel
    env = json.loads(s)
    assert s.count(NEW_VER) == 1 and s.count(OLD_VER) == 0, rel
    assert env['meta']['mode'] == 'LIVE', rel    # C-15 — 봉투 meta.mode 전량 LIVE
    assert env['meta']['notice'] == '합성 데이터. 실계좌·실키 없음.', rel   # C-1 — 01 §5 문장 하나
    body = body_without_meta(s)
    for rx in RETIRED:
        assert not rx.search(body), '%s — 폐기 운영값 %s' % (rel, rx.pattern)
    keys = list(env.keys())
    assert keys[:6] == ENVELOPE_KEYS, (rel, keys)
    if new:
        assert keys == ENVELOPE_KEYS, (rel, keys)   # 봉투 최상위 키 추가 0
        assert len(env['rows']) == 1, rel           # VM 픽스처 = rows 1행(unknown_board_2 선례)
        assert env['rows'][0]['as_of'] == env['as_of'], rel
    else:
        assert keys == list(base_env(rel).keys()), rel
    return env


def self_check_content(rel, env):
    for path, v in strings({k: v for k, v in env.items() if k != 'meta'}):
        if rel in NEW_FILES or rel == HOLDINGS_6:
            assert not FORBIDDEN.search(v), '%s %s — 금지어: %s' % (rel, path, v)
        if rel in NEW_FILES:
            assert not DEV_MEMO.search(v), '%s %s — 사용자 문장 자리의 개발자 메모: %s' % (rel, path, v)
        assert '열람 기록' not in v or not path.endswith('disclosure_note'), (rel, path)   # K5


def all_holding_rows(env, rel):
    vm = env['rows'][0] if rel != HOLDINGS_6 else None
    if rel == HOLDINGS_6:
        return env['rows']
    if rel in OVERVIEWS:
        return [r for c in vm['cards'] for r in c['rows']]
    if rel in DETAILS:
        return [vm['holding']]
    return []


def main():
    rels = base_files()
    assert not (set(NEW_FILES) & set(rels)), 'BASE 목록이 낡았다(신설 파일이 이미 있다)'
    assert set(REVISED) <= set(rels)

    vm = {
        OV_NORMAL: overview(CARD_ROWS, IN_BAND_ROWS),
        OV_RECON: overview(RECON_CARD_ROWS, RECON_ROWS),
        OV_INTEGRITY: overview(INTEGRITY_CARD_ROWS, INTEGRITY_ROWS),
        OV_EMPTY: {'cards': [], 'empty_label': OV_EMPTY_LABEL, 'as_of': as_of(ASOF_HOLD_LABEL)},
        OV_PNL: overview(CARD_ROWS, IN_BAND_ROWS, pnl_on=True),
        OV_VIEWER: overview(CARD_ROWS, IN_BAND_ROWS, external=False, toggle=False),
        DT_WITH_STOPS: detail(R_A, TITLES['A'], [SL_A], journal_rows(JOURNAL_30, ['je_0020', 'je_0015', 'je_0011'])),
        DT_NO_STOP: detail(R_B1, TITLES['B'], [], []),
        DT_PNL: detail(with_pnl(R_B1), TITLES['B'], [], []),
        DT_RECON: detail(recon_row(R_B1), TITLES['B'], [], []),
        DT_INTEGRITY: detail(integrity_row(R_A), TITLES['A'],
                             [dict(SL_A, level_text=MASKED, basis_label=MASKED)],
                             journal_rows(JOURNAL_MASKED, ['je_0006', 'je_0001'])),
        AL_IN_BAND: alloc_vm(IN_BAND_ROWS),
        AL_OUT_OF_BAND: alloc_vm(OUT_ROWS),
        AL_TRANCHE: alloc_vm(TRANCHE_ROWS),
        AL_PARKING: alloc_vm(PARKING_ROWS),
        AL_INTEGRITY: alloc_vm(INTEGRITY_ROWS),
        AL_RECON: alloc_vm(RECON_ROWS),
        AL_EMPTY: alloc_vm([], notice=None, empty=AL_EMPTY_LABEL),
    }
    out = {}
    for rel, v in vm.items():
        out[rel] = render(NEW_META, envelope(as_of(ASOF_ALLOC_LABEL if rel in ALLOCATIONS else ASOF_HOLD_LABEL),
                                             [v]))
    out[HOLDINGS_6] = revise_holdings6()
    out[EXTERNAL_2] = revise_external()
    out[REALIZED_S7] = revise_realized()
    for rel in rels:
        if rel not in out:
            out[rel] = bump(base_text(rel), rel)

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    envs = {rel: self_check_file(rel, s, new=rel in NEW_FILES) for rel, s in out.items()}
    for rel in NEW_FILES + REVISED:
        self_check_content(rel, envs[rel])
    v = {rel: envs[rel]['rows'][0] for rel in NEW_FILES}
    # 가림 글자 == m6/journal_masked_integrity 의 quantity_text(픽스처끼리) · 숫자 0.
    masked = {r['quantity_text'] for r in base_env(JOURNAL_MASKED)['rows']}
    assert masked == {MASKED}, masked
    # 미결 82(K4) — 라벨 = 입금 정본 · 옛 종목 0.
    for rel in OVERVIEWS + DETAILS + [HOLDINGS_6]:
        for r in all_holding_rows(envs[rel], rel):
            assert r['symbol_label'] == label_of(r['symbol']), (rel, r['symbol'])
            assert r['symbol'] not in ('379810', '132030', '357870'), rel
            assert r['scope'] == 'MANAGED', rel
            assert r['detail_deep_link'] == ROUTE_DETAIL + r['holding_id'], rel
            if rel in (OV_INTEGRITY, DT_INTEGRITY):
                assert r['sma_tranches'] == [], (rel, r['holding_id'])                            # K29
            else:
                assert (r['sma_tranches'] != []) == (r['sleeve'] == 'B'), (rel, r['holding_id'])   # K18
            if r['sleeve'] in ('B', 'POT'):
                assert not {g['code'] for g in r['gates']} & {'SAF-208', 'SAF-209'}, rel        # E14
            assert (r['sleeve'] == 'POT') == ('sub_book_label' in r), rel                        # K17
            if 'pnl' in r:
                assert '열람 기록' not in r['pnl']['disclosure_note'], rel
    # holdings_6 == ⑤ 의 같은 holding_id 행(C-44 ④ — pnl 3행 포함) · 6행 중 pnl 3(C-6).
    h6 = envs[HOLDINGS_6]['rows']
    assert len(h6) == 6 and sum(1 for r in h6 if 'pnl' in r) == 3
    pnl_rows = {r['holding_id']: r for c in v[OV_PNL]['cards'] for r in c['rows']}
    assert {r['holding_id']: r for r in h6} == pnl_rows
    # B·POT 같은 종목(holdingId 의 존재 이유).
    assert {r['symbol'] for r in h6 if r['sleeve'] == 'B'} == {r['symbol'] for r in h6 if r['sleeve'] == 'POT'}
    # ⑤ − pnl == ① · ⑱ − 토글·섹션 == ①.
    strip_pnl = copy.deepcopy(v[OV_PNL])
    for c in strip_pnl['cards']:
        for r in c['rows']:
            r.pop('pnl', None)
    assert strip_pnl == v[OV_NORMAL]
    assert {k: x for k, x in v[OV_NORMAL].items() if k not in ('pnl_toggle_label', 'external')} == v[OV_VIEWER]
    # 카드 allocation == 배분 표본의 같은 슬리브 행(① ↔ ⑩ · ② ↔ ⑯ · ③ ↔ ⑭).
    for ov, al in ((OV_NORMAL, AL_IN_BAND), (OV_RECON, AL_RECON), (OV_INTEGRITY, AL_INTEGRITY),
                   (OV_PNL, AL_IN_BAND), (OV_VIEWER, AL_IN_BAND)):
        by = {r['sleeve']: r for r in v[al]['rows']}
        for c in v[ov]['cards']:
            assert c['allocation'] == by[c['sleeve']], (ov, c['sleeve'])
    # 배분 — 밴드 행 = B 만(K27) · 순서 A → POT → B → C → CASH · 비율 짝.
    for rel in ALLOCATIONS:
        rows = v[rel]['rows']
        if rel == AL_EMPTY:
            assert rows == [] and v[rel]['empty_label'], rel
            continue
        assert [r['sleeve'] for r in rows] == ['A', 'POT', 'B', 'C', 'CASH'], rel
        for r in rows:
            assert ('sleeve_weight' in r) == (r['sleeve'] == 'B' and rel != AL_INTEGRITY), (rel, r['sleeve'])
            assert ('band_note_text' in r) != ('sleeve_weight' in r), (rel, r['sleeve'])
            assert (r['deployed_ratio'] is None) == (r['parking_ratio'] is None), rel
            if r['deployed_ratio'] is not None:
                assert abs(r['deployed_ratio'] + r['parking_ratio'] - 1.0) < 1e-9, (rel, r['sleeve'])
            if 'gauge' in r:
                g = r['gauge']
                assert 0 <= g['band_low_normalized'] <= g['target_normalized'] <= g['band_high_normalized'] <= 1
            for word in ('잔여', '남은', '초기', '진행률'):
                assert word not in r['tranche_state_text'], (rel, r['sleeve'])
            if rel == AL_INTEGRITY:
                for k in ('deployed_text', 'parking_text', 'deployed_pct_text', 'parking_pct_text',
                          'tranche_state_text', 'band_note_text'):
                    assert r[k] == MASKED and not DIGIT.search(r[k]), rel
            elif 'band_note_text' in r:
                assert '%' in r['band_note_text'], (rel, r['sleeve'])
    assert any(r.get('band_state') == 'OUT_OF_BAND' for r in v[AL_OUT_OF_BAND]['rows'])
    assert not any(r.get('band_state') == 'OUT_OF_BAND' for r in v[AL_IN_BAND]['rows'])
    # RECON 배분 = 기하·band_state 유지(⑩ 과 같다) · 대상 행만 «?».
    for a, b in zip(v[AL_RECON]['rows'], v[AL_IN_BAND]['rows']):
        for k in ('deployed_ratio', 'parking_ratio', 'gauge', 'band_state'):
            assert a.get(k) == b.get(k), (a['sleeve'], k)
        assert any(s.endswith('?') for _p, s in strings(a)) == (a['sleeve'] == 'B'), a['sleeve']
    # RECON 보유 = 대상 행만 «?» · 그 밖 행은 ① 과 같다.
    for c_r, c_n in zip(v[OV_RECON]['cards'], v[OV_NORMAL]['cards']):
        for a, b in zip(c_r['rows'], c_n['rows']):
            if a['holding_id'] == RECON_TARGET:
                assert a['quantity_text'].endswith('?') and a['pending_text'].endswith('?')
            else:
                assert a == b and not any(s.endswith('?') for _p, s in strings(a))
    # INTEGRITY 보유 — 시스템 밖 수량은 그대로(K14).
    assert v[OV_INTEGRITY]['external'] == v[OV_NORMAL]['external']
    # 상세 ↔ 목록(C-44 ④) · 이력 = 원천 JSON 그대로 · 시간 역순 · 같은 보유.
    pairs = {DT_WITH_STOPS: R_A, DT_NO_STOP: R_B1, DT_PNL: R_B1, DT_RECON: recon_row(R_B1),
             DT_INTEGRITY: integrity_row(R_A)}
    for rel, row in pairs.items():
        h = {k: x for k, x in v[rel]['holding'].items() if k != 'pnl'}
        assert h == row, rel
        assert v[rel]['entry_decision_link']['deep_link'] == ROUTE_DECISION + row['entry_decision']['decision_id']
        for e in v[rel]['recent_entries']:
            assert (e['symbol'], e['sleeve']) == (row['symbol'], row['sleeve']), rel
        dates = [e['trade_date'] for e in v[rel]['recent_entries']]
        assert dates == sorted(dates, reverse=True), rel
        for sl in v[rel]['stop_lines']:
            assert sl['tier_code'] in STOP_TIER_CODES, rel
    assert v[DT_PNL]['holding']['pnl'] == pnl_rows['h_0002']['pnl']
    assert re.sub(r'[^0-9]', '', v[DT_WITH_STOPS]['stop_lines'][0]['level_text']) == \
        OLD_A['stop_line']['absolute_stop']
    assert v[DT_INTEGRITY]['stop_lines'][0]['level_text'] == MASKED
    # 시스템 밖 섹션 행 == external_holdings_2 개정본 행.
    assert v[OV_NORMAL]['external']['rows'] == envs[EXTERNAL_2]['rows']
    # 카드 = 카탈로그 순 · 제목 = 카탈로그 라벨.
    assert [(c['sleeve'], c['title_text']) for c in v[OV_NORMAL]['cards']] == list(TITLES.items())

    # ── 쓰기 ──
    for rel, s in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(s)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_h6_v18_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 %d · 신설 %d) · holdings_6 %d행(pnl %d) · '
          '배분 %d벌 · contract 1.8.0'
          % (len(out), BASE_FILES, len(rels) - len(REVISED), len(REVISED), len(NEW_FILES), len(h6),
             sum(1 for r in h6 if 'pnl' in r), len(ALLOCATIONS)))


if __name__ == '__main__':
    main()
