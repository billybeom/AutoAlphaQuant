#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""docs/ai-context/fixtures_README.md(팩 사본)를 다시 만든다.

사본 = 머리 한 줄 + 정본(packages/domain_contracts/fixtures/README.md) + 부록(디스크 실측 파일 목록).
픽스처가 늘거나 정본 README 가 바뀔 때마다 M2(Claude)가 돌린다:

    python tool/make_fixtures_readme_copy.py 2026-09-17
"""
import datetime
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FX = os.path.join(ROOT, 'packages', 'domain_contracts', 'fixtures')
OUT = os.path.join(ROOT, 'docs', 'ai-context', 'fixtures_README.md')


def main():
    day = sys.argv[1] if len(sys.argv) > 1 else datetime.date.today().isoformat()
    with io.open(os.path.join(FX, 'README.md'), encoding='utf-8') as f:
        canon = f.read().rstrip('\n')
    groups = {}
    for base, _dirs, names in os.walk(FX):
        for n in names:
            if not n.endswith('.json'):
                continue
            rel = os.path.relpath(os.path.join(base, n), FX).replace(os.sep, '/')
            folder = rel.split('/')[0] if '/' in rel else '(루트)'
            groups.setdefault(folder, []).append((rel, os.path.getsize(os.path.join(base, n))))
    total_n = sum(len(v) for v in groups.values())
    total_b = sum(b for v in groups.values() for _r, b in v)
    out = ['> **사본 · 정본은 `packages/domain_contracts/fixtures/README.md`.** 부록의 파일 목록은 조립 시점 실측입니다.',
           '', canon, '',
           '## 부록 — 실제 픽스처 파일 목록 (%d개, %s 실측)' % (total_n, day), '',
           '경로 기준 `packages/domain_contracts/fixtures/`. 이 목록은 조립 시점의 실물이며, 명세가 부르는 파일명과 다르면 **실물이 맞습니다**.']
    for folder in sorted(groups, key=lambda k: (k != '(루트)', k)):
        rows = sorted(groups[folder])
        out += ['', '### %s — %d개' % (folder, len(rows)), '', '| 파일 | 바이트 |', '|---|---:|']
        out += ['| `%s` | %s |' % (rel, format(size, ',d')) for rel, size in rows]
    out += ['', '**합계 %d개 · %s 바이트.** `fixtures/README.md` 1부는 이 표에 세지 않습니다 (JSON 픽스처만 셉니다).'
            % (total_n, format(total_b, ',d'))]
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out) + '\n')
    print('fixtures_README.md: %d files, %s bytes' % (total_n, format(total_b, ',d')))


if __name__ == '__main__':
    main()
