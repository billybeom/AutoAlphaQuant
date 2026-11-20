#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""K208(v1.28 · 통합 담당 결정 · 설계 13 §8 R196) 표본 신설 1 — 손편집 금지 · 계약 버전 1.28.0 유지.

자리: packages/domain_contracts/tool/gen_e11q_c1b_k208_fixture.py
하는 일: `m9/credentials_sim_sealed.json`(v1.20 · 바꾸지 않는다 — ui_settings 골든 · 위젯 시험이 그 표본을 그린다) 원문에서
  실전(`kis_live`) 카드 한 줄만 «SIM 미등록 = 봉인 표시 그대로 + 칸(`SECRET_KIS_LIVE`) + «검증 후 저장»(`credentialVerify{KIS_LIVE}`
  · 조회만)» 으로 바꾸고 봉투 `generated_at` · `seed` 를 이 판 값으로 바꿔 `m9/credentials_sim_unregistered.json` 을 만든다.
  ISA 카드(통과 = 동작 0) · 모의 카드 · 머리 줄 · 런북 링크 = 원문 그대로.
쓰기 전 확인(어기면 멈춘다): 바꿀 줄이 정확히 1회씩 · 결과가 JSON · 카드 3장 · 새 카드 = 봉인 + 칸 + 검증 · 통과 카드 = 동작 0.
멱등: 원문에서 다시 만든다 — 몇 번 돌려도 결과가 같다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_e11q_c1b_k208_fixture.py
"""
import json
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures'))
SRC = os.path.join(FX, 'm9', 'credentials_sim_sealed.json')
DST = os.path.join(FX, 'm9', 'credentials_sim_unregistered.json')

OLD_LIVE = (
    '        { "alias": "kis_live", "kind": "KIS_LIVE", "kind_label": "실전 · 위탁 01 + 연금저축 22", '
    '"health_code": "OK", "health_label": "정상", "usage": "FULL", "usage_label": "주문 · 조회", '
    '"expires_text": "만료 2027-06-30", "level": "INFO", "last_verified_text": "마지막 검증 08-31 08:40 · 통과", '
    '"requirement_label": "실전 전환 때 필수", "why_line": null, "seal_label": "모의투자 중 — 주문 경로 봉인됨", '
    '"credential_slot_id": null, "verify_action": null, "rotate_link": null },'
)
NEW_LIVE = (
    '        { "alias": "kis_live", "kind": "KIS_LIVE", "kind_label": "실전 · 위탁 01 + 연금저축 22", '
    '"health_code": "NOT_REGISTERED", "health_label": "미등록", "usage": "FULL", "usage_label": "주문 · 조회", '
    '"expires_text": null, "level": "INFO", "last_verified_text": null, '
    '"requirement_label": "실전 전환 때 필수", "why_line": null, "seal_label": "모의투자 중 — 주문 경로 봉인됨", '
    '"credential_slot_id": "SECRET_KIS_LIVE", '
    '"verify_action": { "id": "CREDENTIAL_VERIFY", "args": { "kind": "KIS_LIVE" }, "label": "검증 후 저장" }, '
    '"rotate_link": null },'
)
SWAPS = [
    (OLD_LIVE, NEW_LIVE),
    ('    "generated_at": "2026-11-15T09:00:00Z",', '    "generated_at": "2026-11-20T09:00:00Z",'),
    ('    "seed": 20261115,', '    "seed": 20261120,'),
]


def fail(msg):
    sys.exit('멈춤: ' + msg)


def main():
    with open(SRC, encoding='utf-8', newline='') as f:
        text = f.read()
    for old, new in SWAPS:
        n = text.count(old)
        if n != 1:
            fail('바꿀 줄이 %d 번 있다: %s' % (n, old[:60]))
        text = text.replace(old, new, 1)
    env = json.loads(text)
    if env['meta']['contract_version'] != '1.28.0':
        fail('계약 버전이 1.28.0 이 아니다')
    cards = env['rows'][0]['cards']
    if [c['kind'] for c in cards] != ['KIS_LIVE', 'KIS_ISA', 'KIS_PAPER']:
        fail('카드 차례가 다르다')
    live, isa = cards[0], cards[1]
    if not (live['seal_label'] and live['credential_slot_id'] == 'SECRET_KIS_LIVE'
            and live['verify_action'] == {'id': 'CREDENTIAL_VERIFY', 'args': {'kind': 'KIS_LIVE'}, 'label': '검증 후 저장'}):
        fail('새 실전 카드 꼴이 아니다')
    if isa['health_code'] != 'OK' or isa['verify_action'] is not None or isa['credential_slot_id'] is not None:
        fail('통과 카드에 동작이 있다')
    if env['rows'][0]['mode_notice'] is None:
        fail('SIM 머리 줄이 없다')
    with open(DST, 'w', encoding='utf-8', newline='') as f:
        f.write(text)
    print('썼다:', os.path.relpath(DST, os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/'))


main()
