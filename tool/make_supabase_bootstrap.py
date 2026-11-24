#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""packages/data_sync/lib/src/supabase/supabase_bootstrap_sources.dart(o_07 ① 부트스트랩 묶음의 원문 조각)를 다시 만든다.

조각 = ① `packages/domain_contracts/ddl/batch_d_supabase.sql`(계약 사본 · 원문 그대로) +
       ② `packages/data_sync/sql/supabase_lease_rpc.sql`(리스 RPC 본문 · E11k-e2 · 설계 13 §8 R221) +
       ④ `packages/data_sync/sql/supabase_read_model_push_rpc.sql`(읽기 모델 push RPC 본문 · E11l2 · 설계 13 §8 R254 · 01 §47).
셋째 조각 `rm_*` 은 E11l1 생성기가 같은 묶음(`SupabaseBootstrapSql.assemble`)에 넣는다 — 이 도구는 세 원문만 옮긴다.

🔴 원문을 고치면(계약 창 · E11k) 이 도구를 다시 돌린다 — data_sync 시험이 두 파일과 **바이트 대조**한다:

    python -I tool/make_supabase_bootstrap.py
"""
import hashlib
import io
import os
import sys

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCES = [
    ('kSupabaseBatchDSql', 'packages/domain_contracts/ddl/batch_d_supabase.sql',
     '① 배치 D — 계약 사본(01 §6-4) 원문 그대로'),
    ('kSupabaseLeaseRpcSql', 'packages/data_sync/sql/supabase_lease_rpc.sql',
     '② operator 리스 RPC 본문(06 M4-3 · 01 §6-4 리스 RPC 표 · R221)'),
    ('kSupabaseReadModelPushRpcSql', 'packages/data_sync/sql/supabase_read_model_push_rpc.sql',
     '④ 읽기 모델 push RPC 본문(06 M4-1 · 01 §47 push RPC 표 · R254)'),
]
OUT = os.path.join(ROOT, 'packages', 'data_sync', 'lib', 'src', 'supabase', 'supabase_bootstrap_sources.dart')


def dart_raw(text):
    if "'''" in text:
        raise SystemExit("원문에 ''' 가 있다 — 원시 문자열로 담을 수 없다")
    return "r'''\n" + text + "'''"


def main():
    if len(sys.argv) != 1:
        raise SystemExit('사용: make_supabase_bootstrap.py (인자 없음)')
    parts = []
    for const, rel, note in SOURCES:
        b = io.open(os.path.join(ROOT, *rel.split('/')), 'rb').read()
        if b'\r\n' in b:
            raise SystemExit('%s 가 CRLF 다 — 원문은 LF 여야 한다' % rel)
        parts.append((const, rel, note, b.decode('utf-8'), hashlib.sha256(b).hexdigest()))

    out = []
    out.append('// 🔴 생성 파일 — 손으로 고치지 않는다. `python -I tool/make_supabase_bootstrap.py` 로 다시 만든다.')
    out.append('//')
    out.append('// o_07 ① Supabase 부트스트랩 묶음의 원문 조각(설계 13 §8 R221 · E11k-e2) — 묶음 = `supabase_bootstrap.dart`.')
    for _const, rel, _note, _text, sha in parts:
        out.append('//    %s sha256 `%s`' % (rel, sha))
    out.append('// 🔴 data_sync 시험이 세 원문과 바이트 대조한다(갈라지면 시험이 실패).')
    out.append('')
    for const, rel, note, text, _sha in parts:
        out.append('/// %s — `%s`.' % (note, rel))
        out.append('const String %s = %s;' % (const, dart_raw(text)))
        out.append('')
    io.open(OUT, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
    print('supabase_bootstrap_sources.dart: 조각 %d · %d bytes' % (len(parts), os.path.getsize(OUT)))


if __name__ == '__main__':
    main()
