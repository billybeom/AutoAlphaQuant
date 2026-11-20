#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""E11q-c4(설계 13 §8 R189 뒤) 표본 정정 1건 생성 스크립트 — 손편집 금지 · 계약 1.27.0 유지.

자리: packages/domain_contracts/tool/gen_e11q_c4_e13_fix.py (M2 · 계약 v1.4 «정정 1건» 선례).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.

하는 일
  `m5/safety_action_results_e13.json` 의 RECON 해제 성공 행(`ar_e13_12` · id `RECON_CLEAR` · `reason_code` null) `headline` 한 줄을
  v1.22 합성 글자 «(합성) 대사 불일치 표시를 풀었습니다.» → v1.26 `m5/recon_clear_results` 성공 행(`ar_rcl_01`) 글자로 바꾼다.
  까닭 = 같은 (id, 코드 null) 결과가 두 표본에서 글자가 달랐다(v1.22 = 엔진 문장 0 시절 합성 · v1.26 = 사전 저널 함께 쓰기 판 글자).
  엔진 `reconClearActionResultOf`(core `safety/recon_clear.dart` `ReconClearTexts.cleared` · PR #278) = v1.26 글자 → 두 표본을 하나로.
  🔴 다른 글자 · 키 · 차례 · 줄 바꿈 불변(바이트 치환 · 다시 직렬화하지 않는다) · «(합성)» 표지 유지(엔진 대조는 표지를 떼고 본다).

규약을 쓰기 전에 먼저 확인한다(어기면 멈춘다):
  ① 기준 원문에 옛 줄이 정확히 한 번 · 그 줄이 `ar_e13_12` RECON_CLEAR 성공 행 안
  ② 새 글자 == BASE `m5/recon_clear_results.json` `ar_rcl_01` headline
  ③ 새 글자에서 «(합성) » 를 뗀 문장 == BASE 엔진 소스 `ReconClearTexts.cleared` 상수
  ④ 결과 JSON 이 읽히고 바뀐 줄 = 1 · 행 수 · 키 불변

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git show`). 몇 번을 돌려도 결과가 같다.
글자는 **합성 데이터**다(실계좌 아님).

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_e11q_c4_e13_fix.py
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
# 계약 1.27.0 · 엔진 RECON 해제 판(PR #278 squash) 이 들어간 origin/main.
BASE = 'e83361b3dc9261134df60a781d885daa1ceda333'

TARGET = 'm5/safety_action_results_e13.json'
SOURCE = 'm5/recon_clear_results.json'
ENGINE = 'packages/core_engine/lib/src/safety/recon_clear.dart'
OLD_LINE = '      "headline": "(합성) 대사 불일치 표시를 풀었습니다.",'
MARK = '(합성) '


def die(msg):
    print('🔴 멈춤:', msg)
    sys.exit(1)


def at_base(rel):
    out = subprocess.run(['git', 'show', f'{BASE}:{rel}'], cwd=ROOT, capture_output=True)
    if out.returncode != 0:
        die(f'BASE 에서 못 읽음: {rel}')
    return out.stdout.decode('utf-8')


def main():
    old = at_base(f'{FX_REL}/{TARGET}')
    if old.count(OLD_LINE) != 1:
        die(f'옛 줄이 한 번이 아니다({old.count(OLD_LINE)})')
    rows = json.loads(old)['rows']
    hit = [r for r in rows if r['headline'] == OLD_LINE.split('"headline": "')[1][:-2]]
    if len(hit) != 1 or (hit[0]['action_run_id'], hit[0]['id'], hit[0]['reason_code']) != ('ar_e13_12', 'RECON_CLEAR', None):
        die(f'옛 줄의 행이 RECON 성공 행이 아니다: {hit}')

    src = json.loads(at_base(f'{FX_REL}/{SOURCE}'))['rows']
    ok = [r for r in src if r['action_run_id'] == 'ar_rcl_01']
    if len(ok) != 1 or ok[0]['id'] != 'RECON_CLEAR' or ok[0]['reason_code'] is not None:
        die('v1.26 성공 행(ar_rcl_01)을 찾지 못함')
    new_text = ok[0]['headline']
    if not new_text.startswith(MARK):
        die('v1.26 성공 글자에 «(합성)» 표지가 없다')
    eng = re.search(r"static const String cleared\s*=\s*'([^']*)';", at_base(ENGINE))
    if eng is None or eng.group(1) != new_text[len(MARK):]:
        die(f'엔진 상수와 다르다: {eng and eng.group(1)!r} vs {new_text[len(MARK):]!r}')

    new_line = '      "headline": ' + json.dumps(new_text, ensure_ascii=False) + ','
    out = old.replace(OLD_LINE, new_line)

    after = json.loads(out)
    before = json.loads(old)
    if len(after['rows']) != len(before['rows']) or after['meta'] != before['meta']:
        die('행 수 · meta 가 바뀌었다')
    changed = [i for i, (a, b) in enumerate(zip(old.split('\n'), out.split('\n'))) if a != b]
    if len(changed) != 1 or len(old.split('\n')) != len(out.split('\n')):
        die(f'바뀐 줄 != 1: {changed}')
    for a, b in zip(before['rows'], after['rows']):
        if a.keys() != b.keys():
            die('키가 바뀌었다')
        if a != b and a['action_run_id'] != 'ar_e13_12':
            die(f'다른 행이 바뀌었다: {a["action_run_id"]}')

    with io.open(f'{FX}/{TARGET}', 'w', encoding='utf-8', newline='') as f:
        f.write(out)
    print(f'✅ 정정 1건 — {TARGET} 줄 {changed[0] + 1}: {new_text}')


if __name__ == '__main__':
    main()
