#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""packages/data_sync/lib/src/local/schema_v1_sql.dart(로컬 원장 스키마 v1 자산)를 다시 만든다.

자산 = ① 설계 저장소 `06_시스템설계/02_데이터모델.md` 의 ```sql 블록(1번 PRAGMA 블록 제외 — 연결 설정은
`openLedgerDatabase` 몫) + ② `packages/domain_contracts/ddl/` 의 배치 A·B·C·F(LIVE 판 원문 그대로).
설계 13 §8 R19 E9-10(`schema_version` = 1 · 02 기본 + A·B·C·F 한 판) · R20 Q0(첫 실기기 설치 때 동결).

🔴 CI 는 설계 저장소를 보지 못한다 — 그래서 02 는 이 도구로 옮겨 sha256 을 머리에 남기고, 배치 사본은
   data_sync 시험이 `domain_contracts/ddl/*.sql` 과 **바이트 대조**한다(갈라지면 시험이 실패).
🔴 02 를 고치는 SPEC 개정(E9b 등)이 들어오면 이 도구를 다시 돌린다:

    python -I tool/make_local_schema.py "C:/Work/클로드-백그라운드-작업/투자/06_시스템설계/02_데이터모델.md"

🔴 R20 Q2 — 02 v2.32 의 `executions.broker_order_no` 는 NOT NULL 이지만 v1 은 **NULL 허용**이다(수기 체결 ·
   배치 F 의 `fill_origin` CHECK «MANUAL ⇔ NULL»). 02 본문이 아직 NOT NULL 이면 그 한 줄만 바꾸고 머리에
   «정정 1» 로 남긴다. 02 가 개정되면(E9b) 정정은 0 이 되고 자산은 02 그대로다.
"""
import hashlib
import io
import os
import sys

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DDL = os.path.join(ROOT, 'packages', 'domain_contracts', 'ddl')
OUT = os.path.join(ROOT, 'packages', 'data_sync', 'lib', 'src', 'local', 'schema_v1_sql.dart')
BATCHES = [
    'batch_a_decision_mode.sql',
    'batch_b_plan_command.sql',
    'batch_c_x2_x5_local.sql',
    'batch_f_x7_advisory.sql',
]
Q2_OLD = '    broker_order_no TEXT NOT NULL,'
Q2_NEW = '    broker_order_no TEXT,                             -- 🔴 v1(R20 Q2) — 수기 체결은 NULL(배치 F CHECK)'


def sql_blocks(md):
    blocks, cur, start = [], None, None
    for i, ln in enumerate(md.split('\n'), 1):
        s = ln.strip()
        if cur is None and s.startswith('```sql'):
            cur, start = [], i + 1
        elif cur is not None and s.startswith('```'):
            blocks.append((start, i - 1, '\n'.join(cur)))
            cur = None
        elif cur is not None:
            cur.append(ln)
    return blocks


def dart_raw(text):
    if "'''" in text:
        raise SystemExit("원문에 ''' 가 있다 — 원시 문자열로 담을 수 없다")
    return "r'''\n" + text + "'''"


def main():
    if len(sys.argv) != 2:
        raise SystemExit('사용: make_local_schema.py <02_데이터모델.md 경로>')
    src = sys.argv[1]
    raw = io.open(src, 'rb').read()
    md = raw.decode('utf-8').replace('\r\n', '\n')
    blocks = sql_blocks(md)
    if len(blocks) != 9 or 'PRAGMA journal_mode' not in blocks[0][2]:
        raise SystemExit('02 의 sql 블록 꼴이 바뀌었다(9개 · 1번 = PRAGMA) — 도구를 다시 본다: %d' % len(blocks))
    base_parts = []
    for (a, b, text) in blocks[1:]:
        base_parts.append('-- ── 02_데이터모델.md L%d-%d ──\n%s\n' % (a, b, text))
    base = '\n'.join(base_parts)
    fixes = 0
    if base.count(Q2_OLD) == 1:
        base = base.replace(Q2_OLD, Q2_NEW)
        fixes = 1
    elif base.count(Q2_OLD) != 0:
        raise SystemExit('executions.broker_order_no 줄이 여러 번 나온다')
    batches = []
    for name in BATCHES:
        b = io.open(os.path.join(DDL, name), 'rb').read()
        if b'\r\n' in b:
            raise SystemExit('%s 가 CRLF 다 — 사본은 LF 여야 한다' % name)
        batches.append((name, b.decode('utf-8'), hashlib.sha256(b).hexdigest()))

    out = []
    out.append('// 🔴 생성 파일 — 손으로 고치지 않는다. `python -I tool/make_local_schema.py <02 경로>` 로 다시 만든다.')
    out.append('//')
    out.append('// 로컬 원장 스키마 v1 자산(설계 13 §8 R19 E9-10 · R20 Q0·Q2 · E9c).')
    out.append('// ① 02 기본 — 설계 저장소 `06_시스템설계/02_데이터모델.md` sha256 `%s`' % hashlib.sha256(raw).hexdigest())
    out.append('//    ```sql 블록 2~9(1번 PRAGMA 블록 제외 — 연결 설정은 `openLedgerDatabase`) · 정정 %d(R20 Q2 `executions.broker_order_no` NULL 허용)' % fixes)
    out.append('// ② 배치 — `packages/domain_contracts/ddl/` LIVE 판 원문(SIM 판은 `ledgerDdlFor`):')
    for name, _text, sha in batches:
        out.append('//    %s sha256 `%s`' % (name, sha))
    out.append('// 🔴 배치 사본은 data_sync 시험이 `domain_contracts/ddl` 과 바이트 대조한다.')
    out.append('')
    out.append('/// 02 기본 DDL(32표 · `schema_version` 포함) — 블록 2~9.')
    out.append('const String kBase02Sql = %s;' % dart_raw(base))
    out.append('')
    out.append('/// 적용 순서대로의 로컬 배치(새 설치 = A → B → C → F · `batch_e` 보관 · `batch_d` = Supabase).')
    out.append('const List<(String, String)> kLocalBatchSql = <(String, String)>[')
    for name, text, _sha in batches:
        # dart format 꼴(레코드 여러 줄) — 다시 만들어도 포맷 검사가 깨지지 않게.
        out.append("  (\n    '%s',\n    %s,\n  )," % (name, dart_raw(text)))
    out.append('];')
    out.append('')
    io.open(OUT, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
    print('schema_v1_sql.dart: 02 블록 %d · 배치 %d · 정정 %d · %d bytes' % (len(blocks) - 1, len(batches), fixes, os.path.getsize(OUT)))


if __name__ == '__main__':
    main()
