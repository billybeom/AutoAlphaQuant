#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""docs/ai-context/contracts_bundle.md 를 다시 뽑는다.

웹 채팅(저장소를 못 붙이는 자리) 전용 사본이다 — 정본은 packages/domain_contracts/ 의 코드다.
`domain_contracts/lib/` 가 바뀔 때마다 M2(Claude)가 돌린다:

    python tool/make_contracts_bundle.py            # 조립일 = 오늘
    python tool/make_contracts_bundle.py 2026-09-17 # 조립일 지정

담는 것 = 배럴 + lib/src/**/*.dart 중 생성물(*.freezed.dart · *.g.dart) 제외 원문.
순서 = 배럴 → lib/src 바로 아래 파일(가나다) → 하위 폴더(가나다) 안의 파일(가나다).
"""
import datetime
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'packages', 'domain_contracts', 'lib')
OUT = os.path.join(ROOT, 'docs', 'ai-context', 'contracts_bundle.md')


def is_source(name):
    return (name.endswith('.dart') and not name.endswith('.freezed.dart')
            and not name.endswith('.g.dart'))


def collect():
    files = [os.path.join(LIB, 'domain_contracts.dart')]
    src = os.path.join(LIB, 'src')
    files += sorted(os.path.join(src, n) for n in os.listdir(src)
                    if os.path.isfile(os.path.join(src, n)) and is_source(n))
    for sub in sorted(n for n in os.listdir(src) if os.path.isdir(os.path.join(src, n))):
        folder = os.path.join(src, sub)
        for base, _dirs, names in sorted(os.walk(folder)):
            files += sorted(os.path.join(base, n) for n in names if is_source(n))
    return files


def main():
    day = sys.argv[1] if len(sys.argv) > 1 else datetime.date.today().isoformat()
    files = collect()
    version = 'unknown'
    with io.open(os.path.join(LIB, 'src', 'contract_version.dart'), encoding='utf-8') as f:
        for line in f:
            if line.startswith('const String contractVersion'):
                version = line.split("'")[1]
    out = []
    out.append('# `contracts_bundle.md` — `domain_contracts` 공개 API 원문 (웹 채팅 첨부용)\n')
    out.append('> **저장소를 클론할 수 있으면 이 파일을 쓰지 마십시오.** 실제 코드(`packages/domain_contracts/`)가')
    out.append('> 최종 정본이고, 이것은 그 시점의 **사본**입니다. 웹 채팅처럼 저장소를 붙일 수 없는 자리에만 씁니다.')
    out.append('>')
    out.append('> 담은 것 = 배럴 `lib/domain_contracts.dart` + `lib/src/**/*.dart` 중 **생성물 제외** 원문')
    out.append('> (`*.freezed.dart`·`*.g.dart`는 `build_runner` 산출물이라 뺐습니다 — 필요하면 저장소에서 생성합니다).')
    out.append('> 담지 않은 것 = 픽스처 JSON · 계약 테스트 · DDL · 엔진 명세 · 청사진 HTML.')
    out.append('>')
    out.append('> 파일 %d개 · 계약 v%s · 조립일 %s(`python tool/make_contracts_bundle.py`). 각 절의 제목이 저장소 기준 파일 경로입니다.\n'
               % (len(files), version, day))
    for path in files:
        rel = os.path.relpath(path, ROOT).replace(os.sep, '/')
        with io.open(path, encoding='utf-8') as f:
            body = f.read().rstrip('\n')
        out.append('\n---\n')
        out.append('## `%s`\n' % rel)
        out.append('```dart')
        out.append(body)
        out.append('```')
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out) + '\n')
    print('contracts_bundle.md: %d files, contract v%s, %s' % (len(files), version, day))


if __name__ == '__main__':
    main()
