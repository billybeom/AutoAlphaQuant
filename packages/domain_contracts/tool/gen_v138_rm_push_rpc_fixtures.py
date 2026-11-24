#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""계약 v1.38(읽기 모델 push RPC 표 — 01 §47 · 13 R251) 픽스처 생성 스크립트 — 손 계산 금지.

자리: packages/domain_contracts/tool/gen_v138_rm_push_rpc_fixtures.py (M2 소유 · 화면 담당은 고치지 않는다).
픽스처는 이 스크립트 옆 폴더(../fixtures)에서 찾는다 — 어느 폴더에서 불러도 같다.
관례는 gen_v136_read_model_fixtures.py(버전 줄만 판)를 본떴다(그 스크립트는 그 판 재현용으로 그대로 둔다).

하는 일(01 §47 · 398 → 398 = 신설 0 · 개정 0 · 버전 줄만 398)
  (a) 전 봉투의 "contract_version": "1.37.0" → "1.38.0" 한 줄 치환(다른 글자 불변).
  (b) 신설 0 — 이 판은 RPC 표 글자(`schema/supabase_rpc.dart`) · 거부 사전 2 만 더한다(K336 · 화면 0).

멱등: 언제나 **기준 커밋(BASE)의 원문**에서 다시 만든다(`git cat-file --batch`).
몇 번을 돌려도 결과가 같다 — 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다.

쓰는 법(저장소 루트에서):
    PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_v138_rm_push_rpc_fixtures.py
"""
import io
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding='utf-8')

HERE = os.path.dirname(os.path.abspath(__file__))
FX = os.path.normpath(os.path.join(HERE, '..', 'fixtures')).replace(os.sep, '/')
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..')).replace(os.sep, '/')
FX_REL = os.path.relpath(FX, ROOT).replace(os.sep, '/')
# 계약 1.37.0 · 픽스처 398 의 기준 커밋(origin/main · 계약 v1.37 병합 기록 773ba68d — 픽스처 JSON = v1.37 f3270253 과 같음).
BASE = '773ba68d'

OLD_VER = '"contract_version": "1.37.0"'
NEW_VER = '"contract_version": "1.38.0"'
BASE_FILES = 398
WANT_FILES = 398


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


def base_files():
    out = git('ls-tree', '-r', '--name-only', BASE, FX_REL + '/')
    rels = [p[len(FX_REL) + 1:] for p in out.split('\n') if p.endswith('.json')]
    assert len(rels) == BASE_FILES, len(rels)
    return rels


def bump(s, rel):
    assert s.count(OLD_VER) == 1, rel
    return s.replace(OLD_VER, NEW_VER, 1)


def check_base_fresh():
    """rebase 뒤 밑동(merge-base HEAD origin/main)의 픽스처 트리가 BASE 와 다르면 멈춘다."""
    try:
        mb = git('merge-base', 'HEAD', 'origin/main').strip()
    except subprocess.CalledProcessError:
        return
    want = git('rev-parse', '%s:%s' % (BASE, FX_REL)).strip()
    got = git('rev-parse', '%s:%s' % (mb, FX_REL)).strip()
    assert want == got, ('BASE 가 낡았다 — 밑동 %s 의 픽스처 트리가 BASE %s 와 다르다(BASE 상수 갱신)'
                         % (mb[:8], BASE[:8]))


def main():
    check_base_fresh()
    rels = base_files()
    preload(rels)
    out = {rel: bump(_BASE_CACHE[rel], rel) for rel in rels}

    # ── 자가 검사(쓰기 전) ──
    assert len(out) == WANT_FILES, len(out)
    for rel in rels:
        a, b = _BASE_CACHE[rel], out[rel]
        assert len(a) == len(b) and a.replace(OLD_VER, NEW_VER, 1) == b, rel      # 버전 줄 한 곳만

    # ── 쓰기 ──
    for rel, text in sorted(out.items()):
        path = FX + '/' + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    on_disk = sum(1 for _b, _d, ns in os.walk(FX) for n in ns if n.endswith('.json'))
    assert len(out) == WANT_FILES == on_disk, (len(out), on_disk)
    print('gen_v138_rm_push_rpc_fixtures: %d files (기준 %d · 버전 줄만 %d · 개정 0 · 신설 0) · contract 1.38.0'
          % (len(out), BASE_FILES, len(out)))


if __name__ == '__main__':
    main()
